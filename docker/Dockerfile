FROM node:10

# Install needed items for all other images.
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl git python build-essential xvfb apt-transport-https
RUN npm install -g pm2

# Fetch LL code
RUN wget https://github.com/LearningLocker/learninglocker/archive/v7.0.0.zip
RUN unzip v7.0.0.zip -d /usr/local/
RUN mv /usr/local/learninglocker-7.0.0/ /usr/local/learninglocker/
# Make directory available for Learninglocker user.
RUN groupadd learninglocker
RUN useradd -r -g learninglocker -d /usr/local/learninglocker/ learninglocker
# Copy env files
COPY ./docker/dockerfile.env /usr/local/learninglocker/.env
# Stuff for running learninglocker at startup and build time.
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Chown of items so they can be read by non-privileged user.
RUN chown -R learninglocker:learninglocker /usr/local/learninglocker
RUN chown -R learninglocker:learninglocker /usr/local/lib/node_modules

USER learninglocker
WORKDIR /usr/local/learninglocker/

# Items we want in all images.
RUN pm2 install pm2-logrotate
RUN pm2 set pm2-logrotate:compress true

# Build needed items.
RUN yarn install
RUN yarn build-all

EXPOSE 3000
EXPOSE 8080
VOLUME /tmp/
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash", "-c", "pm2 logs" ]
