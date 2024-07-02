#!/bin/bash

cd src

# Create the lambda_package directory if it does not exist
if [ ! -d "lambda_package" ]; then
  mkdir lambda_package
fi

# Install dependencies into the lambda_package directory
pip install -r requirements.txt --target=lambda_package

cp lambda_function.py lambda_package/lambda_function.py

# Navigate to the lambda_package directory and create the zip package
cd lambda_package
zip -r ../../lambda.zip .