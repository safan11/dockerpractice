# Use a lightweight Java runtime
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file into the container
COPY restapi2-0.0.1-SNAPSHOT.jar myapp.jar

# Run the application
CMD ["java", "-jar", "myapp.jar"]
