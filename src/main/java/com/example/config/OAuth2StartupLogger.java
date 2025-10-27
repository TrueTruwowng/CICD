package com.example.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Logs which OAuth2 client registrations are active at startup and flags placeholder values.
 */
@Component
public class OAuth2StartupLogger implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(OAuth2StartupLogger.class);
    private final List<ClientRegistration> registrations = new ArrayList<>();

    public OAuth2StartupLogger(ClientRegistrationRepository repository) {
        if (repository instanceof Iterable<?> iterable) {
            for (Object o : iterable) {
                if (o instanceof ClientRegistration cr) {
                    registrations.add(cr);
                }
            }
        }
    }

    @Override
    public void run(ApplicationArguments args) {
        if (registrations.isEmpty()) {
            log.warn("No OAuth2 client registrations are active. Configure at least one provider.");
            return;
        }
        log.info("Detected {} OAuth2 client registration(s):", registrations.size());
        for (ClientRegistration cr : registrations) {
            String registrationId = cr.getRegistrationId();
            String clientId = cr.getClientId();
            boolean placeholder = clientId == null || clientId.isBlank() || clientId.startsWith("changeme");
            log.info(" - {} (clientId='{}'{} scope={})", registrationId,
                mask(clientId), placeholder ? " PLACEHOLDER" : "", cr.getScopes());
            if (placeholder) {
                log.warn("   -> '{}' clientId still placeholder. Set environment variables before starting: {}_CLIENT_ID / {}_CLIENT_SECRET", registrationId, envKey(registrationId), envKey(registrationId));
            }
            if ("auth0".equals(registrationId)) {
                // Provide additional hints for Auth0
                log.info("   Auth0 endpoints authorizationUri={} tokenUri={} jwkSetUri={} ",
                        cr.getProviderDetails().getAuthorizationUri(),
                        cr.getProviderDetails().getTokenUri(),
                        cr.getProviderDetails().getJwkSetUri());
            }
        }
    }

    private String envKey(String registrationId) {
        return registrationId.toUpperCase();
    }

    private String mask(String clientId) {
        if (clientId == null || clientId.length() < 6) return clientId;
        return clientId.substring(0,4) + "***" + clientId.substring(clientId.length()-3);
    }
}

