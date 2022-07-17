#!/bin/bash -eu

repo_path=/home/isucon/isucon10-qualify
branch=${1:-master} # default: master

echo 'running deploy to this server'
git -C ${repo_path} switch master
git -C ${repo_path} pull origin master
git -C ${repo_path} fetch --all
git -C ${repo_path} branch -D ${branch} || true
git -C ${repo_path} switch ${branch}
${repo_path}/deploy.sh

echo 'running deploy to other servers, isucon12-02 and isucon12-03'
echo ''
echo '[NOTE] Before expecting this process to work well, you need to prepare /etc/hosts for alias isucon12-02, isucon12-03'
echo ''
for srv in "isucon12-02" "isucon12-03"
do
  echo 'starting for '${srv}
  ssh -T isucon@${srv} git -C ${repo_path} switch master || ssh isucon@${srv} git clone https://github.com/t2-isucon/isucon10-qualify.git
  ssh -T isucon@${srv} git -C ${repo_path} pull origin master
  ssh -T isucon@${srv} git -C ${repo_path} fetch --all
  ssh -T isucon@${srv} git -C ${repo_path} branch -D ${branch} || true
  ssh -T isucon@${srv} git -C ${repo_path} switch ${branch}
  ssh -T isucon@${srv} ${repo_path}/deploy.sh
  echo 'finished for '${srv}
done
