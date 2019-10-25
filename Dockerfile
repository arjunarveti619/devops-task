#Building spring-petclinic image
FROM anapsix/alpine-java
LABEL maintainer="arjunarveti619@gmail.com"
COPY /target/spring-petclinic-*.jar /home/spring-petclinic.jar
CMD ["java","-jar","/home/spring-petclinic.jar"]
