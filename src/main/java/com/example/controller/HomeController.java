package com.example.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

@Controller
public class HomeController {

    @Value("${AUTH0_DOMAIN:}")
    private String auth0Domain;

    // Fallback: read authorization-uri to infer domain if AUTH0_DOMAIN not explicitly provided
    @Value("${spring.security.oauth2.client.provider.auth0.authorization-uri:}")
    private String auth0AuthorizationUri;

    @Value("${spring.security.oauth2.client.registration.google.client-id:}")
    private String googleClientId;

    @Value("${spring.security.oauth2.client.registration.github.client-id:}")
    private String githubClientId;

    private boolean isAuth0Configured() {
        // Priority: explicit domain variable
        if (auth0Domain != null && !auth0Domain.isBlank()) {
            String lower = auth0Domain.toLowerCase();
            return !lower.contains("example.invalid") && !lower.equals("your_domain") && !lower.equals("changeme");
        }
        // Fallback: parse from authorization-uri if present
        if (auth0AuthorizationUri != null && !auth0AuthorizationUri.isBlank()) {
            // Expect pattern: https://<tenant>/authorize
            if (auth0AuthorizationUri.contains(".auth0.com") && !auth0AuthorizationUri.contains("example.invalid")) {
                return true;
            }
        }
        return false;
    }

    private boolean isGoogleConfigured() {
        return googleClientId != null && !googleClientId.isBlank() && !googleClientId.startsWith("changeme");
    }

    private boolean isGithubConfigured() {
        return githubClientId != null && !githubClientId.isBlank() && !githubClientId.startsWith("changeme");
    }

    private void applyProviderFlags(Model model) {
        model.addAttribute("auth0Configured", isAuth0Configured());
        model.addAttribute("googleConfigured", isGoogleConfigured());
        model.addAttribute("githubConfigured", isGithubConfigured());
    }

    private String firstNonNull(Map<String, Object> map, String... keys) {
        if (map == null) return null;
        for (String k : keys) {
            Object v = map.get(k);
            if (v instanceof String s && !s.isBlank()) return s;
        }
        return null;
    }

    @GetMapping("/")
    public String index(Model model, Authentication authentication) {
        if (authentication != null) {
            Object principal = authentication.getPrincipal();
            if (principal instanceof OidcUser user) {
                model.addAttribute("profile", user.getClaims());
                model.addAttribute("userName", user.getFullName() != null ? user.getFullName() : user.getPreferredUsername());
            } else if (principal instanceof OAuth2User user) {
                model.addAttribute("profile", user.getAttributes());
                // Try common attribute keys for a friendly display name
                String name = (String) user.getAttributes().getOrDefault("name",
                        user.getAttributes().getOrDefault("login",
                                user.getAttributes().getOrDefault("username",
                                        user.getAttributes().getOrDefault("email", "User"))));
                model.addAttribute("userName", name);
            }
        }
        applyProviderFlags(model);
        return "index";
    }

    @GetMapping("/login")
    public String login(Model model) {
        // Only need provider flags; user is anonymous here normally
        applyProviderFlags(model);
        return "login";
    }

    @GetMapping("/profile")
    public String profile(Model model, Authentication authentication) {
        if (authentication != null) {
            Object principal = authentication.getPrincipal();
            Map<String,Object> source = null;
            if (principal instanceof OidcUser user) {
                source = user.getClaims();
                model.addAttribute("profile", source);
                model.addAttribute("idToken", user.getIdToken().getTokenValue());
                model.addAttribute("providerType", "OIDC");
            } else if (principal instanceof OAuth2User user) {
                source = user.getAttributes();
                model.addAttribute("profile", source);
                model.addAttribute("idToken", "(Không có ID Token cho nhà cung cấp này)");
                model.addAttribute("providerType", "OAuth2");
            }
            if (source != null) {
                String picture = firstNonNull(source, "picture", "avatar_url", "image", "profile_image_url", "profile_image");
                String displayName = firstNonNull(source, "name", "full_name", "login", "preferred_username", "nickname", "username");
                String email = firstNonNull(source, "email");
                String issuer = firstNonNull(source, "iss");
                String subject = firstNonNull(source, "sub", "id");
                model.addAttribute("pictureUrl", picture);
                model.addAttribute("displayName", displayName);
                model.addAttribute("primaryEmail", email);
                model.addAttribute("issuer", issuer);
                model.addAttribute("subject", subject);
            }
        }
        return "profile";
    }
}
