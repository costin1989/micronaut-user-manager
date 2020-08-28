FROM openjdk:14-alpine
COPY target/micronaut-user-manager-*.jar micronaut-user-manager.jar
EXPOSE 8080
CMD ["java", "-Dcom.sun.management.jmxremote", "-Xmx128m", "-jar", "micronaut-user-manager.jar"]