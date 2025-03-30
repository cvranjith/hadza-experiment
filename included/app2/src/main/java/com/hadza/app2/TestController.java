package com.hadza.app2;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @GetMapping("/hello")
    public String hello(@RequestParam(value="name", defaultValue = "there") String name){
        return "App2 says: Hello "+ name;
    }
}
