
package com.javeriya;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@SpringBootApplication
@Controller
public class StartApplication {

    @GetMapping("/")
    public String index(final Model model) {
        model.addAttribute("title", "I have successfully built a Spring Boot application using Maven");
        model.addAttribute("msg", "       This application is deployed onto Kubernetes using Argo CD");
        return "index"; // Renders index.html from templates directory
    }

    @GetMapping("/description")
    public String description(final Model model) {
        model.addAttribute("title", "Description");
        model.addAttribute("msg", " ");
        return "description"; // Renders description.html from templates directory
    }

    @GetMapping("/contact")
    public String contact(final Model model) {
        model.addAttribute("title", "Contact Us");
        model.addAttribute("msg", "         Get in touch with us for more information.");
        return "contact"; // Renders contact.html from templates directory
    }

    public static void main(String[] args) {
        SpringApplication.run(StartApplication.class, args);
    }
}

