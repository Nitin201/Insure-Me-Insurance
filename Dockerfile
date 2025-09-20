# Use OpenJDK 11 as base image
FROM openjdk:11

# Set working directory
WORKDIR /app

# Copy your pre-built JAR file
COPY selenium-insure-me-runnable.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
