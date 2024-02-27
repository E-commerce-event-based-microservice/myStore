package com.group16.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.group16.model.User;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class KafkaProducerService {

    // private static final String TOPIC = "userEvents";
    @Value("${spring.kafka.topic.name}")
    private String topicName;

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

   

    public void sendMessage(User message) {
        this.kafkaTemplate.send(topicName, message);

    }
    
    // private ObjectMapper objectMapper = new ObjectMapper();
     
    // public void sendMessage(User user) {
    //     try {
    //         String userAsString = objectMapper.writeValueAsString(user);
    //         kafkaTemplate.send(TOPIC, userAsString);
    //     } catch (JsonProcessingException e) {
    //         // Handle the exception properly - perhaps log it or throw a custom exception
    //         e.printStackTrace();
    //     }
    // }
}