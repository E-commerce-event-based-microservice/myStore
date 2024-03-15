# Step 1: Build the entire Maven project
FROM maven:3.8.1-jdk-11 as builder
COPY . /user/src/app
WORKDIR /user/src/app
RUN mvn clean package -DskipTests

# Step 2: Build specific service image (for user service, for example)
FROM openjdk:11-jre-slim
COPY --from=builder /user/src/app/user/target/user-*.jar /app/user-service.jar
ENTRYPOINT ["java", "-jar", "/app/user-service.jar"]