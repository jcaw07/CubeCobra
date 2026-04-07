#!/bin/sh

# Address dubious ownership git error for Windows
git config --global --add safe.directory /home/node/app

# Ensure DynamoDB tables exist (they are lost when LocalStack restarts)
TABLE=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url=http://localstack:4566 dynamodb list-tables 2>/dev/null | grep LOCAL_CUBECOBRA)

if [ -z "$TABLE" ]; then
  echo "DynamoDB tables missing — running CDK deploy..."
  cd /home/node/app/packages/cdk
  NODE_PATH=/home/node/app/packages/cdk/node_modules \
    node /home/node/app/node_modules/aws-cdk-local/bin/cdklocal bootstrap \
    --context environment=local --context version=1.0.0
  NODE_PATH=/home/node/app/packages/cdk/node_modules \
    node /home/node/app/node_modules/aws-cdk-local/bin/cdklocal deploy \
    --context environment=local --context version=1.0.0 --require-approval never
  cd /home/node/app
  echo "DynamoDB tables created."
else
  echo "DynamoDB tables present — skipping CDK."
fi

npm run dev --workspace=packages/server & npm run start --workspace=packages/client
