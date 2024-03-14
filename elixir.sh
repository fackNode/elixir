#!/bin/bash

fmt=`tput setaf 45`
end="\e[0m\n"
err="\e[31m"
scss="\e[32m"

echo -e "${fmt}\nSetting up dependencies / Проверяем переменные окружения${end}" && sleep 1

if [ -z "$ADDRESS" ]; then
  echo -e "${err}\nYou have not set ADDRESS, please set the variable and try again / Вы не установили ADDRESS, пожалуйста, установите переменную и попробуйте снова${end}" && sleep 1
  exit 1;
fi

if [ -z "$PRIVATE_KEY" ]; then
  echo -e "${err}\nYou have not set PRIVATE_KEY, please set the variable and try again / Вы не установили PRIVATE_KEY, пожалуйста, установите переменную и попробуйте снова${end}" && sleep 1
  exit 1;
fi

if [ -z "$VALIDATOR_NAME" ]; then
  echo -e "${err}\nYou have not set VALIDATOR_NAME, please set the variable and try again / Вы не установили VALIDATOR_NAME, пожалуйста, установите переменную и попробуйте снова${end}" && sleep 1
  exit 1;
fi

echo -e "${fmt}\nAll variables is set / Все переменные установленны${end}" && sleep 1

echo -e "${fmt}\nSetting up dependencies / Устанавливаем необходимые зависимости${end}" && sleep 1

cd $HOME
sudo apt update
sudo apt install curl ca-certificates curl gnupg lsb-release jq -y < "/dev/null"
                
if ! command -v docker &> /dev/null && ! command -v docker-compose &> /dev/null; then
  sudo wget https://raw.githubusercontent.com/fackNode/requirements/main/docker.sh && chmod +x docker.sh && ./docker.sh
fi

echo -e "${fmt}\nCreating directory, installing Dockerfile / Создаем директорию, загружаем Dockerfile${end}" && sleep 1

mkdir elixir && cd elixir

wget https://files.elixir.finance/Dockerfile

echo -e "${fmt}\nSeting your values in Dockerfile/ Устанавливаем ваши значения в Dockerfile${end}" && sleep 1

sed -i "s/ENV ADDRESS=.*/ENV ADDRESS=$ADDRESS/" Dockerfile
sed -i "s/ENV PRIVATE_KEY=.*/ENV PRIVATE_KEY=$PRIVATE_KEY/" Dockerfile
sed -i "s/ENV VALIDATOR_NAME=.*/ENV VALIDATOR_NAME=$VALIDATOR_NAME/" Dockerfile

echo -e "${fmt}\nBuilding the Docker image / Собираем Docker образ${end}" && sleep 1

docker build . -f Dockerfile -t elixir-validator

echo -e "${fmt}\nStarting validator / Запускаем валидатора${end}" && sleep 1

docker run -d --restart unless-stopped --name ev elixir-validator

cd $HOME

if docker ps -a | grep -q 'ev'; then
  echo -e "${fmt}\nNode installed correctly / Нода установлена корректно${end}" && sleep 1
else
  echo -e "${err}\nNode installed incorrectly / Нода установлена некорректно${end}" && sleep 1
  exit 1;
fi

echo -e "${scss}\n[SUCCESS] Opening validator logs, you can close logs with CTRL + C / Открываем логи валидатора, вы можете закрыть логи используя CTRL + C${end}" && sleep 3

# rm elixir.sh

docker logs ev -f

