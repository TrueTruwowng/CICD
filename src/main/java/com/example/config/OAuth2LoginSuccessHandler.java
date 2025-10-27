package com.example.config;

import com.example.model.Login;
import com.example.service.LoginService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import java.io.IOException;
import java.util.Map;

@Component
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final LoginService loginService;

    public OAuth2LoginSuccessHandler(LoginService loginService) {
        this.loginService = loginService;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        try {
            Object principal = authentication.getPrincipal();
            Login login = new Login();
            if (principal instanceof OidcUser user) {
                Map<String, Object> claims = user.getClaims();
                login.setUsername(firstNonBlank(
                        user.getFullName(),
                        asString(claims.get("preferred_username")),
                        asString(claims.get("nickname")),
                        asString(claims.get("name"))
                ));
                login.setEmail(asString(claims.get("email")));
                login.setProvider("OIDC");
                login.setProfileImage(firstNonBlank(
                        asString(claims.get("picture")),
                        asString(claims.get("avatar_url"))
                ));
            } else if (principal instanceof OAuth2User user) {
                Map<String, Object> attrs = user.getAttributes();
                login.setUsername(firstNonBlank(
                        asString(attrs.get("name")),
                        asString(attrs.get("login")),
                        asString(attrs.get("username")),
                        asString(attrs.get("email"))
                ));
                login.setEmail(asString(attrs.get("email")));
                login.setProvider("OAuth2");
                login.setProfileImage(firstNonBlank(
                        asString(attrs.get("avatar_url")),
                        asString(attrs.get("picture"))
                ));
            }
            if (StringUtils.hasText(login.getUsername()) || StringUtils.hasText(login.getEmail())) {
                loginService.save(login);
            }
        } catch (Exception ignored) {
            // Do not block login flow if persistence fails.
        }
        response.sendRedirect("/");
    }

    private String asString(Object v) { return v == null ? null : String.valueOf(v); }
    private String firstNonBlank(String... vals) {
        if (vals == null) return null;
        for (String s : vals) {
            if (StringUtils.hasText(s)) return s;
        }
        return null;
    }
}

