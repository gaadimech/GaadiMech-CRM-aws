#!/bin/bash

# Clean up previous deployment
rm -rf deployment/*

# Create necessary directories
mkdir -p deployment/.ebextensions
mkdir -p deployment/static
mkdir -p deployment/templates
mkdir -p deployment/migrations

# Copy application files
cp application.py deployment/
cp requirements.txt deployment/
cp Procfile deployment/
cp -r migrations/* deployment/migrations/
cp -r static/* deployment/static/
cp -r templates/* deployment/templates/
cp -r .ebextensions/* deployment/.ebextensions/

# Remove unnecessary files
find deployment -type d -name "__pycache__" -exec rm -rf {} +
find deployment -type f -name "*.pyc" -delete
find deployment -type f -name ".DS_Store" -delete

# Create deployment zip
cd deployment
zip -r ../deployment.zip . -x "*.pyc" "*.pyo" "*.pyd" "__pycache__/*" "*.so" "*.egg" "*.egg-info" "*.DS_Store"
cd ..

echo "Deployment package created as deployment.zip" 