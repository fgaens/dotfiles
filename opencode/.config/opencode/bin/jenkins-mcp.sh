#!/bin/sh
set -eu

jenkins_username="$(security find-generic-password -a "$USER" -s opencode-jenkins-user -w)"
jenkins_password="$(security find-generic-password -a "$USER" -s opencode-jenkins-token -w)"
export jenkins_username jenkins_password

exec npx -y jenkins-mcp --read-only --jenkins-url https://jenkins.fednot.be
