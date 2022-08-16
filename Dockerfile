# This Dockerfile was compiled based on the following references:
# https://www.cinqict.nl/blog/building-a-jenkins-development-docker-image
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code
# https://www.jenkins.io/doc/book/installing/docker/

# Setting the base image
FROM jenkins/jenkins:lts

USER jenkins

# Disable setup wizard so we can configure jenkins programmatically
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"

# Configure plugins based on suggested defaults in https://github.com/jenkinsci/jenkins/blob/master/core/src/main/resources/jenkins/install/platform-plugins.json
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt

# Note that the install-plugins.sh script is now deprecated 
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Copy config as code yaml to appropriate location in jenkins
COPY casc.yaml /var/jenkins_home/casc.yaml

COPY --chown=jenkins:jenkins jobs/number-guesser.groovy /var/jenkins_home/jobdsl/number-guesser.groovy


# Add groovy script to Jenkins hook
#COPY --chown=jenkins:jenkins init.groovy.d/ /var/jenkins_home/init.groovy.d/