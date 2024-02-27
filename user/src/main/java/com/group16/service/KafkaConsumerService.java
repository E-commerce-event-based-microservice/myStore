package com.group16.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.group16.model.User;

@Service
public class KafkaConsumerService {

    @KafkaListener(topics = "${spring.kafka.topic.name}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(User message) {
        System.out.println("Received Message: " + message.toString());
    }
}