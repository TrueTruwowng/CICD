package com.example.api;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class DemoApiController {

    @GetMapping("/api/public")
    public Map<String, Object> publicEndpoint() {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "Public endpoint accessible without authentication");
        return data;
    }

    @GetMapping("/api/private")
    public Map<String, Object> privateEndpoint(Authentication authentication) {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "Private endpoint secured via OIDC / JWT");
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            data.put("subject", jwt.getSubject());
            data.put("claims", jwt.getClaims());
        } else if (authentication != null) {
            data.put("principal", authentication.getPrincipal().toString());
        }
        return data;
    }
}

