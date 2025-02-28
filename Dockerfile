# 1st Build Step
FROM openjdk:17-alpine as build

WORKDIR /workspace/app

# Source
COPY src src
COPY inst/shinyApps/www/css src/main/resources/static/css
COPY inst/shinyApps/www/htmlwidgets src/main/resources/static/htmlwidgets
COPY inst/shinyApps/www/img src/main/resources/static/img
COPY inst/shinyApps/www/js src/main/resources/static/js
COPY inst/shinyApps/www/vendor src/main/resources/static/vendor
COPY inst/shinyApps/www/favicon.ico src/main/resources/static/favicon.ico
COPY inst/shinyApps/www/index.html src/main/resources/static/index.html

# Maven
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN tr -d '\015' <./mvnw >./mvnw.sh && mv ./mvnw.sh ./mvnw && chmod 770 mvnw

RUN ./mvnw package

# 2nd Run Step
FROM openjdk:17-alpine

RUN apk update \
    && apk add openssh-server \
    && export ROOTPASS=$(head -c 12 /dev/urandom |base64 -) && echo "root:$ROOTPASS" | chpasswd

COPY sshd_config /etc/ssh/

VOLUME /tmp

ARG JAR_FILE=/workspace/app/target/*.jar
COPY --from=build ${JAR_FILE} app.jar

EXPOSE 8001

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar /app.jar ${0} ${@}"]

