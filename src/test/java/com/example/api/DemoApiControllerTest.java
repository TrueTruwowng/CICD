package com.example.api;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class DemoApiControllerTest {

    @Autowired
    MockMvc mockMvc;

    @Test
    void publicEndpointShouldReturn200() throws Exception {
        mockMvc.perform(get("/api/public"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.message").value("Public endpoint accessible without authentication"));
    }

    @Test
    void privateEndpointShouldReturn401WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/private"))
            .andExpect(status().isUnauthorized());
    }
}
