# User Manager Application

- **_Web API CRUD Operations_**

  - **GET**
    * ```
      curl -X "GET" "http://localhost:8080/users/list"
      ```
  - **GET**
    * ```
      curl -X "GET" "http://localhost:8080/users/1"
      ```
  - **GET**
    * ```
      curl -X "GET" "http://localhost:8080/users/list?sort=age&order=desc"
      ```
  - **GET**
    * ```
      curl -X "GET" "http://localhost:8080/users/list?sort=name&order=asc&offset=1"
      ```
  - **POST**
    * ```
      curl -X "POST" "http://localhost:8080/users" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d $'{
          "name": "Amalia Piscupescu",
          "age": 35
        }'
      ```
  - **PUT**
    * ```
      curl -X "PUT" "http://localhost:8080/users" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d $'{
          "id": 1,
          "name": "Amalia Protopopescu",
          "age": 35
        }'
      ```
  - **DELETE**
    * ```
      curl -X "DELETE" "http://localhost:8080/users/1"
      ``` 

&nbsp;
  
- **_Consul_**

  - [http://localhost:8500](http://localhost:8500)