package com.ionos.service.repository;

import com.ionos.model.User;
import com.ionos.service.UserService;
import com.ionos.resources.controller.SortingAndOrderArguments;
import com.ionos.settings.ApplicationConfiguration;
import io.micronaut.transaction.annotation.ReadOnly;

import javax.inject.Singleton;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Singleton
public class UserServiceImpl implements UserService {

    private final EntityManager entityManager;

    private final ApplicationConfiguration applicationConfiguration;

    private final static List<String> VALID_PROPERTY_NAMES = Arrays.asList("id", "name", "age");

    public UserServiceImpl(EntityManager entityManager, ApplicationConfiguration applicationConfiguration) {
        super();
        this.entityManager = entityManager;
        this.applicationConfiguration = applicationConfiguration;
    }

    @Override
    @ReadOnly
    public Optional<User> findById(@NotNull Long id) {
        return Optional.ofNullable(entityManager.find(User.class, id));
    }

    @ReadOnly
    public List<User> findAll(@NotNull SortingAndOrderArguments args) {
        String qlString = "SELECT u FROM User AS u";
        if (args.getOrder().isPresent() && args.getSort().isPresent() && VALID_PROPERTY_NAMES.contains(args.getSort().get())) {
            qlString += " ORDER BY u." + args.getSort().get() + " " + args.getOrder().get().toLowerCase();
        }
        TypedQuery<User> query = entityManager.createQuery(qlString, User.class);
        query.setMaxResults(args.getMax().orElseGet(applicationConfiguration::getMax));
        args.getOffset().ifPresent(query::setFirstResult);

        return query.getResultList();
    }

    @Override
    @Transactional
    public User save(@NotBlank String name, int age) {
        User user = new User(name, age);
        entityManager.persist(user);
        return user;
    }

    @Override
    @Transactional
    public int update(@NotNull Long id, @NotBlank String name, int age) {
        return entityManager.createQuery("UPDATE User u SET name = :name, age = :age WHERE id = :id")
                .setParameter("name", name)
                .setParameter("age", age)
                .setParameter("id", id)
                .executeUpdate();
    }

    @Override
    @Transactional
    public void deleteById(@NotNull Long id) {
        findById(id).ifPresent(entityManager::remove);
    }

}
