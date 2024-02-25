package com.group16.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.group16.model.User;

// is indeed not necessary to put the annotation on interfaces that extend JpaRepository
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

}