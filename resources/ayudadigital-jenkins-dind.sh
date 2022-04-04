#!/bin/bash -e

# Ensure the docker socket does not exist
rm -f /var/run/docker.sock

# Start docker in the background
/usr/local/bin/dockerd-entrypoint.sh &

# Enable the docker daemon for jenkins user access
while [ ! -S /var/run/docker.sock ]
do
  sleep 2
done
chmod 666 /var/run/docker.sock

# Start jenkins in the background
sudo -u jenkins -E env "HOME=/var/jenkins_home" bash -c "/sbin/tini -s -- /usr/local/bin/jenkins.sh $@" &

# Container main proccess. Allow docker & jenkins processes to be restarted
tail -f /dev/null
