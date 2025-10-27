package com.example.service;

import com.example.model.Login;
import com.example.repository.LoginRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LoginService {
    @Autowired
    private LoginRepository loginRepository;

    public Login save(Login login) {
        return loginRepository.save(login);
    }
}

