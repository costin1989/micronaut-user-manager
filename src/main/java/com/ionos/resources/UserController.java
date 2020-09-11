package com.ionos.resources;

import com.ionos.model.User;
import com.ionos.service.UserService;
import com.ionos.resources.controller.SortingAndOrderArguments;
import com.ionos.resources.controller.UserSaveCommand;
import com.ionos.resources.controller.UserUpdateCommand;
import io.micronaut.http.HttpHeaders;
import io.micronaut.http.HttpResponse;
import io.micronaut.http.annotation.Body;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Delete;
import io.micronaut.http.annotation.Get;
import io.micronaut.http.annotation.Post;
import io.micronaut.http.annotation.Put;
import io.micronaut.scheduling.TaskExecutors;
import io.micronaut.scheduling.annotation.ExecuteOn;

import javax.validation.Valid;
import java.net.URI;
import java.util.List;

@ExecuteOn(TaskExecutors.IO)
@Controller("/users")
public class UserController {

    private final UserService service;

    public UserController(UserService service) {
        this.service = service;
    }

    @Get("/{id}")
    public User show(long id) {
        return service.findById(id)
                .orElse(null);
    }

    @Get(value = "/list{?args*}")
    public List<User> list(@Valid SortingAndOrderArguments args) {
        return service.findAll(args);
    }

    @Post
    public HttpResponse<User> save(@Body @Valid UserSaveCommand cmd) {
        User user = service.save(cmd.getName(), cmd.getAge());

        return HttpResponse
                .created(user)
                .headers(headers -> headers.location(location(user.getId())));
    }

    @Put("/{id}")
    public HttpResponse update(long id, @Body @Valid UserUpdateCommand command) {
        //int numberOfEntitiesUpdated = service.update(command.getId(), command.getName(), command.getAge());
        int numberOfEntitiesUpdated = service.update(id, command.getName(), command.getAge());

        return HttpResponse
                .noContent()
                //.header(HttpHeaders.LOCATION, location(command.getId()).getPath());
                .header(HttpHeaders.LOCATION, location(id).getPath());
    }

    @Delete("/{id}")
    public HttpResponse delete(long id) {
        service.deleteById(id);
        return HttpResponse.noContent();
    }

    private URI location(long id) {
        return URI.create("/users/" + id);
    }

}
