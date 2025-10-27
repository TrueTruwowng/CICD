package com.example.controller;

import com.example.model.Login;
import com.example.service.LoginService;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {
    private final LoginService loginService;

    public AuthController(LoginService loginService) {
        this.loginService = loginService;
    }

    @PostMapping("/register")
    public ResponseEntity<Login> register(@RequestBody Login login) {
        // NOTE: For production, hash sensitive data before saving
        Login saved = loginService.save(login);
        return ResponseEntity.ok(saved);
    }
}

