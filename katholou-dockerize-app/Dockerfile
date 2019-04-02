FROM alpine:3.8

ENV JAVA_DISTRIBUTION openjdk
ENV JAVA_VERSION 8

RUN apk add "$JAVA_DISTRIBUTION$JAVA_VERSION" --update \
        ; ln -s "/usr/lib/jvm/java-1.$JAVA_VERSION-openjdk/bin/javac" /usr/bin/javac

COPY java-WebServer-0.1-jar-with-dependencies.jar /app.jar

EXPOSE 55555

CMD ["java", "-jar", "app.jar", "55555"]