package com.group16.controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.Mapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

// import com.group16.model.User;
// import com.group16.service.KafkaProducerService;
// import com.group16.service.UserService;



// @Restcontroller make this class's object as beans
@RestController
// @RequestMapping(path = "gateway")
public class GatewayController {
    

    // if the target bean has only one constructor then @Autowired is not needed
    @Autowired
    public GatewayController() {
        
    }

    @GetMapping("/rest/hello")
    public String getHello() {
        return "heeeey";
    }
    

   
    
}
