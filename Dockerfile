FROM eclipse-temurin:17-jdk-jammy

ARG JAR_FILE=build/libs/assignment-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8090

ENV JAVA_OPTS="-Xmx256m -Xms128m"

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]