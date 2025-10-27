package com.example.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizationRequestResolver;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestResolver;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${auth0.audience:}")
    private String audience;

    // Raw domain (e.g. dev-abc123.us.auth0.com). Empty if not configured.
    @Value("${AUTH0_DOMAIN:}")
    private String auth0Domain;

    private boolean isDomainConfigured(String domain) {
        if (domain == null || domain.isBlank()) return false;
        String lower = domain.toLowerCase();
        return !lower.contains("example.invalid") && !lower.equals("your_domain") && !lower.equals("changeme");
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http,
                                                   ClientRegistrationRepository clientRegistrationRepository,
                                                   OAuth2LoginSuccessHandler successHandler) throws Exception {
        // @formatter:off
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/", "/login", "/css/**", "/js/**", "/images/**", "/error", "/api/public", "/debug/oauth2/clients").permitAll()
                // allow health and metrics for k8s probes and monitoring
                .requestMatchers("/actuator/health", "/actuator/health/**", "/actuator/info", "/actuator/prometheus").permitAll()
                // allow registration endpoint (demo only)
                .requestMatchers("/api/auth/register").permitAll()
                .requestMatchers("/api/private").authenticated()
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .defaultAuthenticationEntryPointFor(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED), new AntPathRequestMatcher("/api/**"))
            )
            .oauth2Login(oauth2 -> {
                oauth2.loginPage("/login");
                oauth2.successHandler(successHandler);
                OAuth2AuthorizationRequestResolver base =
                        new DefaultOAuth2AuthorizationRequestResolver(clientRegistrationRepository, "/oauth2/authorization");
                if (audience != null && !audience.isBlank() && isDomainConfigured(auth0Domain) && base instanceof DefaultOAuth2AuthorizationRequestResolver def) {
                    def.setAuthorizationRequestCustomizer(builder ->
                        builder.additionalParameters(params -> params.put("audience", audience))
                    );
                    oauth2.authorizationEndpoint(cfg -> cfg.authorizationRequestResolver(def));
                }
            })
            .oauth2Client(Customizer.withDefaults())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .deleteCookies("JSESSIONID")
            )
            .csrf(csrf -> csrf
                .ignoringRequestMatchers(new AntPathRequestMatcher("/api/**"))
            );
        // @formatter:on

        return http.build();
    }
}
