#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

#MAINTAINER Muhammad Edwin < edwin at redhat dot com >

#LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5"
#LABEL JAVA_VERSION="11"

#RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

#WORKDIR /work/
#COPY target/*.jar /work/application.jar

#EXPOSE 8080
#CMD ["java", "-jar", "application.jar"]
# Use the official Nginx image as base
FROM nginx:latest

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy a sample index.html to the container
COPY index.html .

# Expose port 80 to access the Nginx server
EXPOSE 80

# Run Nginx in the background and output logs
CMD ["sh", "-c", "nginx && tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log"]
