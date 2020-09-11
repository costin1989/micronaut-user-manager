package com.ionos.resources.controller;

import io.micronaut.core.annotation.Introspected;

import javax.validation.constraints.NotBlank;

@Introspected
public class UserSaveCommand {

    @NotBlank
    private String name;

    private int age;

    public UserSaveCommand() {
        super();
    }

    public UserSaveCommand(String name, int age) {
        this();
        this.name = name;
        this.age = age;
    }

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
