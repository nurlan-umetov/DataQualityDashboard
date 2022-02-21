# 1st Build Step
FROM openjdk:15-oracle as build

ARG prop=dev

WORKDIR /workspace/app

# Source
COPY src src
COPY inst/shinyApps/www/ src/main/resources/static/

# Maven
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN tr -d '\015' <./mvnw >./mvnw.sh && mv ./mvnw.sh ./mvnw && chmod 770 mvnw

RUN ./mvnw install -DskipTests -P${prop}

# 2nd Run Step
FROM openjdk:15-oracle
VOLUME /tmp

EXPOSE 8001

ARG JAR_FILE=/workspace/app/target/*.jar
COPY --from=build ${JAR_FILE} app.jar
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar /app.jar ${0} ${@}"]

