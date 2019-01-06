FROM gitlab/gitlab-runner:ubuntu as builder

FROM yuikns/argcv:latest

# Copy binary execution
COPY --from=builder /usr/bin/gitlab-runner /gitlab-runner

# Installation for the gitlab-runner is not required
# RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh |  bash  && \
#       yum update -y && \
#       yum install gitlab-runner -y && \
#       /usr/share/gitlab-runner/post-install

# Install required packages
RUN dnf install sudo procps hostname -y && \
    dnf clean all

RUN mkdir -p /app 

RUN useradd gitlab-runner

RUN chown -R gitlab-runner:gitlab-runner /app

RUN echo "ALL        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/all

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

USER gitlab-runner

CMD ["/gitlab-runner" ,"run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
# CMD ["/gitlab-runner" ,"run", "--user=root", "--working-directory=/home"]
# CMD ["/gitlab-runner" ,"run", "--working-directory=/home/gitlab-runner"]

