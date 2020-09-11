package com.ionos.resources.controller;

import io.micronaut.core.annotation.Introspected;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Introspected
public class UserUpdateCommand {

    /*
    @NotNull
    private Long id;
    */

    @NotBlank
    private String name;

    private int age;

    public UserUpdateCommand() {
        super();
    }

    public UserUpdateCommand(String name, int age) {
        this();
        this.name = name;
        this.age = age;
    }

    /*
    public UserUpdateCommand(Long id, String name, int age) {
        this();
        this.id = id;
        this.name = name;
        this.age = age;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
    */

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

}
