FROM openjdk:17-oracle
#CMD ["./mvnw", "clean", "package"]
ARG JAR_FILE_PATH=target/*.jar
COPY ${JAR_FILE_PATH} spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]

FROM openjdk:17-oracle

ARG JAR_FILE=target/*.jar

# Kaniko는 wildcard 처리할 때 쉘이 필요하므로 아래 방식이 안정적
RUN mkdir /app
WORKDIR /app

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

