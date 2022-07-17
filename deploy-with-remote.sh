#!/bin/bash -eu

repo_path=/home/isucon/isucon10-qualify
branch=${1:-master} # default: master

echo 'running deploy to this server'
git -C ${repo_path} pull origin main
git -C ${repo_path} switch ${branch}
${repo_path}/deploy.sh

echo 'running deploy to other servers, isucon12-02 and isucon12-03'
echo ''
echo '[NOTE] Before expecting this process to work well, you need to prepare /etc/hosts for alias isucon12-02, isucon12-03'
echo ''
for srv in "isucon12-02" "isucon12-03"
do
  echo 'starting for '${srv}
  ssh isucon@${srv} git -C ${repo_path} pull origin ${branch} || ssh isucon@${srv} git clone https://github.com/t2-isucon/isucon10-qualify.git
  ssh isucon@${srv} git -C ${repo_path} switch ${branch}
  ssh isucon@${srv} ${repo_path}/deploy.sh
  echo 'finished for '${srv}
done