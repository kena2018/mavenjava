# ---------- Stage 1: Build the Maven project ----------
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy only pom.xml to download dependencies first (caching optimization)
COPY pom.xml .

# Pre-download dependencies
RUN mvn dependency:go-offline

# Copy the entire project
COPY src ./src

# Build the project and skip tests (faster for CI/CD)
RUN mvn clean package -DskipTests

# ---------- Stage 2: Run the application ----------
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR (assuming only one JAR is present)
COPY --from=build /app/target/*.jar app.jar

# Expose default Spring Boot port (change if needed)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
