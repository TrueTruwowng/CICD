package com.example.controller;

import org.springframework.http.MediaType;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;

/**
 * Simple diagnostic endpoint to inspect which OAuth2 client registrations are active at runtime.
 * Does NOT expose client secrets.
 */
@RestController
public class OAuth2DebugController {

    private final List<ClientRegistration> registrations = new ArrayList<>();

    public OAuth2DebugController(ClientRegistrationRepository repository) {
        // ClientRegistrationRepository is either InMemory or a custom impl.
        // We try to iterate known ids by reflection if necessary.
        if (repository instanceof Iterable<?> iterable) {
            for (Object o : iterable) {
                if (o instanceof ClientRegistration cr) {
                    registrations.add(cr);
                }
            }
        }
    }

    @GetMapping(value = "/debug/oauth2/clients", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Map<String, Object>> list() {
        List<Map<String, Object>> out = new ArrayList<>();
        for (ClientRegistration cr : registrations) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("registrationId", cr.getRegistrationId());
            map.put("clientId", mask(cr.getClientId()));
            map.put("redirectUri", cr.getRedirectUri());
            map.put("authorizationGrantType", cr.getAuthorizationGrantType().getValue());
            map.put("scopes", cr.getScopes());
            map.put("authorizationUri", cr.getProviderDetails().getAuthorizationUri());
            map.put("tokenUri", cr.getProviderDetails().getTokenUri());
            String jwk = cr.getProviderDetails().getJwkSetUri();
            if (jwk != null) map.put("jwkSetUri", jwk);
            String userInfo = cr.getProviderDetails().getUserInfoEndpoint().getUri();
            if (userInfo != null && !userInfo.isBlank()) map.put("userInfoUri", userInfo);
            out.add(map);
        }
        return out;
    }

    private String mask(String clientId) {
        if (clientId == null || clientId.length() < 6) return clientId;
        return clientId.substring(0, 4) + "***" + clientId.substring(clientId.length() - 3);
    }
}

