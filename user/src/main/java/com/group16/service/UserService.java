package com.group16.service;

import org.springframework.stereotype.Service;
import com.group16.model.User;
import com.group16.repository.UserRepository;

// @Service makes this class as a bean class
@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User addUser(User newUser) {
         return userRepository.save(newUser);
    }
   public User getUser(long id){
        return userRepository.findById(id).orElse(null);
    }

}
