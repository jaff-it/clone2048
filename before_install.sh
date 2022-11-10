#!/bin/bash

# Check Docker
docker --version
aws --version

AWS_DEFAULT_REGION=$(grep ' AWS_DEFAULT_REGION' buildspec.yml | awk -F '"' '{print $2}')
AWS_ACCOUNT_ID=$(grep ' AWS_ACCOUNT_ID' buildspec.yml | awk -F '"' '{print $2}')
ECR_REPO_NAME=$(grep ' ECR_REPO_NAME' buildspec.yml | awk -F '"' '{print $2}')
ECR_IMAGE_TAG=$(grep ' ECR_IMAGE_TAG' buildspec.yml | awk -F '"' '{print $2}')

echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo "ECR_REPO_NAME: $ECR_REPO_NAME"
echo "ECR_IMAGE_TAG: $ECR_IMAGE_TAG"

aws ecr get-login-password --region $AWS_DEFAULT_REGION| docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$ECR_IMAGE_TAG

CONTAINER=$(docker ps -f name=2048 -q)
if [[ $(echo $CONTAINER | wc -m) != 0 ]]
then
  docker stop $CONTAINER
fi

docker run -d --rm --name 2048 -p 8385:80 $ECR_REPO_NAME:$ECR_IMAGE_TAG