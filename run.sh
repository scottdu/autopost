#!/bin/bash

backend_dir=/tmp/bots-data-dashboard
frontend_dir=/tmp/dashboard

git_sync() {
  if [[ ! -d $backend_dir ]]; then
    echo
    echo 'git clone.....'
    echo
    pushd /tmp
    git clone git@github.nike.com:bm-tools/bots-data-dashboard.git
    popd
  else
    echo
    echo 'git pull.....'
    echo
    pushd $backend_dir
    git pull origin master
    popd
  fi

  echo
  echo '--- backend project syncronized!(后端代码已同步) ---'
  echo

  if [[ ! -d $frontend_dir ]]; then
    echo 'git clone...'
    pushd /tmp
    git clone git@github.nike.com:bm-tools/dashboard.git
    popd
  else
    echo 'git pull...'
    pushd $frontend_dir
    git pull origin master
    popd
  fi

  echo
  echo '--- frontend project syncronized!(前端代码已同步) ---'
  echo

}

npm_install() {
  if [[ -d $frontend_dir ]]; then
    pushd $frontend_dir
    npm install
    popd
  else
    echo
    echo 'Oops! no project existed(啊呀！项目不存在)'
    echo
    exit 1
  fi
}

front_build() {
  if [[ -d $frontend_dir ]]; then
    pushd $frontend_dir
    npm run build
    popd
  else
    echo
    echo 'Oops! no project existed(啊呀！项目不存在)'
    echo
    exit 1
  fi
  echo
  echo 'finish building....'
  echo
}

mvn_install() {
  if [[ -d $backend_dir ]]; then
    pushd $backend_dir
    mvn clean install -Dmaven.test.skip
    popd
  else
    echo
    echo 'Oops! no project existed(啊呀！项目不存在)'
    echo
    exit 1
  fi
  echo
  echo 'finish building....'
}

deploy_to_ec2() {
  if [[ -f "$backend_dir/src/test/resources/nike_scottdu.pem" ]]; then
    pushd $backend_dir
    chmod 400 src/test/resources/nike_scottdu.pem
    source "$backend_dir/start.sh"
    popd
  else
    echo
    echo 'Oops! you have not pem file!!!!'
    echo
    exit 1
  fi
}

clear;

while :; do
  echo
  echo "........OneKey deploy(一键发布)......"
  echo
  echo "1. Update Coding(更新代码)"
  echo
  echo "2. Build Frontend Project(打包构建前端代码)"
  echo
  echo "3. npm install(安装前端依赖)"
  echo
  echo "4. Build Backend Project(打包后端工程)"
  echo
  echo "5. Deploy to EC2(发布到EC2上)"
  echo
  echo "6. Auto Build And Deploy(自动更新项目并发布到EC2上)"
  echo
  read -p "$(echo -e "请选择序号:")" choose
  case $choose in
  1)
    git_sync
    break
    ;;
  2)
    front_build
    break
    ;;
  3)
    npm_install
    break
    ;;
  4)
    mvn_install
    break
    ;;
  5)
    deploy_to_ec2
    break
    ;;
  6)
    git_sync
    npm_install
    front_build
    mvn_install
    deploy_to_ec2
    break
    ;;
  *)
    error
    ;;
  esac
done
