# This Dockerfile was compiled based on the following references:
# https://www.cinqict.nl/blog/building-a-jenkins-development-docker-image
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code
# https://www.jenkins.io/doc/book/installing/docker/

# Setting the base image
FROM jenkins/jenkins:lts

USER jenkins

# Disable setup wizard so we can configure jenkins programmatically
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Add groovy script to Jenkins hook
#COPY --chown=jenkins:jenkins init.groovy.d/ /var/jenkins_home/init.groovy.d/