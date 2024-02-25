package com.group16.controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.Mapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.group16.model.User;
import com.group16.service.UserService;



// @Restcontroller make this class's object as beans
@RestController
// @RequestMapping(path = "api/user")
public class UserController {
    private final UserService userService;
    

    // if the target bean has only one constructor then @Autowired is not needed
    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/users")
    User addUser(@RequestBody User newUser) {
        return userService.addUser(newUser);
    }

    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        
        return userService.getUser(id);
    }
}
