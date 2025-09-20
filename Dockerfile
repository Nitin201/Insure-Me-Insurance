# Use OpenJDK 11 as base image
FROM openjdk:11

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file directly (update the name if needed)
COPY selenium-insure-me-runnable.jar app.jar

# Expose the port your Spring Boot app will run on
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
