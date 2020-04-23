# Ayuda Digital - Jenkins Dind

Official Docker Jenkins combined with Official Docker DIND.

## Objective

To have a Jenkins docker image allowed to run docker inside using "docker:dind" project.

The "ayudadigital/jenkins-dind" image will be builded like a lego, based on two projects:

- [Jenkins](https://github.com/jenkinsci/docker) Official Docker image project.
- [Docker Dind](https://github.com/docker-library/docker) Official Image project.

## Requirements

If you want to run the image:

- [Docker](https://www.docker.com) installed.

If you want to build the image:

- Linux or Mac as the base OS for the build.
- [Docker](https://www.docker.com) installed.
- [TIC para Bien devcontrol](https://github.com/ayudadigital/devcontrol) installed.

## Usage

### Build

Build the Jenkins DIND docker image with:

```console
$ devcontrol build
```

Then wait for the task to complete.

#### Upgrade

You can change the Jenkins version number in the "jenkins-version.ini" file:

```console
cat jenkins-version.ini
JENKINS_VERSION=2.204.3
JENKINS_SHA=aa35f86e92812b511fd97f52e22b1e35965ef984f5eb60215b70b5914f9dc9ea
```

Open <https://updates.jenkins-ci.org/download/war/> URL and look for the SHA-256 hash string of the version you want. Then place both values (version number and jenkins WAR file SHA-256 string) in the `jenkins-version.ini` file.

Once this info was changed, you can do the build as it is explained in this document.

### Run

To start a Jenkins Dind container follow the same instructions as in the [Jenkins](https://github.com/jenkinsci/docker) project, but changing "jenkins/jenkins:lts" docker image reference with "ayudadigital/jenkins-dind" and adding the `--privileged` flag.

After the container starts, you can view the `jenkins` and `docker` processes running and you can run a docker container within the running container, even with the `jenkins` user.

```console
$ docker run --privileged -d -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 ayudadigital/jenkins-dind
77660364c9b551adae737868b94b96f56ff4f7087c7175956e12f245572973f1
$ docker exec -ti 77660364c9b5 bash
bash-5.0# ps faux
PID   USER     TIME  COMMAND
    1 root      0:00 /sbin/tini -- /usr/local/bin/tpb-jenkins-dind.sh
    6 root      0:00 {tpb-jenkins-} /bin/bash -e /usr/local/bin/tpb-jenkins-dind.sh
    7 root      0:00 dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2376 --tlsverify --tlscacert /certs/server/ca.pem --tlscert /certs/server/cert.pem --tlskey /certs/server/key.pem
   60 root      0:00 containerd --config /var/run/docker/containerd/containerd.toml --log-level info
  193 jenkins   0:00 /sbin/tini -- /usr/local/bin/jenkins.sh
  194 root      0:00 tail -f /dev/null
  195 jenkins   0:31 java -Duser.home=/var/jenkins_home -jar /usr/share/jenkins/jenkins.war
  301 root      0:00 bash
  306 root      0:00 ps faux
bash-5.0# su - jenkins
77660364c9b5:~$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete 
Digest: sha256:451ce787d12369c5df2a32c85e5a03d52cbcef6eb3586dd03075f3034f10adcd
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

## Credits

Give credits to the Openjdk, Docker and Jenkins project.
