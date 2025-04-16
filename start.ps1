# PowerShell script to build and run the Docker container

Write-Host "🧱 Starting the Leipzig Corpora Viewer project..."

# Navigate to the script's directory
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Build and start the containers using docker-compose
docker-compose up --build

Write-Host "✅ Containers are up and running!"
Write-Host "You can now access the DbGate interface at http://localhost:3000"