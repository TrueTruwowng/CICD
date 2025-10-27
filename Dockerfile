# Use official OpenJDK image for Java 21
FROM eclipse-temurin:21-jre-alpine
VOLUME /tmp
# Copy the built jar from target directory
COPY target/untitled-1.0-SNAPSHOT.jar app.jar
# Run the jar
ENTRYPOINT ["java","-jar","/app.jar"]
