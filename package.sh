#!/bin/bash

cd src
pip install -r requirements.txt --target=lambda_package

cd lambda_package
zip -r ../../lambda.zip .
cd ..
zip -g ../../lambda.zip lambda_function.py