#!/bin/bash

fmt=`tput setaf 45`
end="\e[0m\n"
err="\e[31m"
scss="\e[32m"

echo -e "${fmt}\nChecking environment variables / Проверяем переменные окружения${end}" && sleep 1

if [ -z "$BENEFICIARY_ADDRESS" ]; then
  echo -e "${err}\nYou have not set BENEFICIARY_ADDRESS, please set the variable and try again / Вы не установили BENEFICIARY_ADDRESS, пожалуйста, установите переменную и попробуйте снова${end}" && sleep 1
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
  sudo wget https://raw.githubusercontent.com/fackNode/requirements/main/docker.sh && sudo chmod +x docker.sh && ./docker.sh
fi

echo -e "${fmt}\nCreating directory, installing validator.env / Создаем директорию, загружаем validator.env${end}" && sleep 1

mkdir elixir && cd elixir

wget https://files.elixir.finance/validator.env

echo -e "${fmt}\nSeting your values in Dockerfile/ Устанавливаем ваши значения в Dockerfile${end}" && sleep 1

sed -i "s/STRATEGY_EXECUTOR_IP_ADDRESS=.*/STRATEGY_EXECUTOR_IP_ADDRESS=$(curl -s eth0.me)/" validator.env
sed -i "s/STRATEGY_EXECUTOR_DISPLAY_NAME=.*/STRATEGY_EXECUTOR_DISPLAY_NAME=$VALIDATOR_NAME/" validator.env
sed -i "s/STRATEGY_EXECUTOR_BENEFICIARY=.*/STRATEGY_EXECUTOR_BENEFICIARY=$BENEFICIARY_ADDRESS/" validator.env
sed -i "s/SIGNER_PRIVATE_KEY=.*/SIGNER_PRIVATE_KEY=$PRIVATE_KEY/" validator.env

echo -e "${fmt}\nBuilding the Docker image / Собираем Docker образ${end}" && sleep 1

docker pull elixirprotocol/validator:v3

docker run -d \
  --env-file validator.env \
  --name elixir \
  --restart unless-stopped \
  elixirprotocol/validator:v3

cd $HOME

if docker ps -a | grep -q 'elixir'; then
  echo -e "${fmt}\nNode installed correctly / Нода установлена корректно${end}" && sleep 1
else
  echo -e "${err}\nNode installed incorrectly / Нода установлена некорректно${end}" && sleep 1
  exit 1;
fi

echo -e "${scss}\n[SUCCESS] Opening validator logs, you can close logs with CTRL + C / Открываем логи валидатора, вы можете закрыть логи используя CTRL + C${end}" && sleep 3

docker logs elixir -f

