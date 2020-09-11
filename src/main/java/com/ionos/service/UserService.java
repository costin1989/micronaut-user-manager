package com.ionos.service;

import com.ionos.model.User;
import com.ionos.resources.controller.SortingAndOrderArguments;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;
import java.util.Optional;

public interface UserService {

    Optional<User> findById(@NotNull Long id);

    List<User> findAll(@NotNull SortingAndOrderArguments args);

    User save(@NotBlank String name, int age);

    int update(@NotNull Long id, @NotBlank String name, int age);

    void deleteById(@NotNull Long id);

}
