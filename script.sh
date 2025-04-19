#!/bin/bash

# EaglerServerXVelocity Automation Script
# This script automates the setup and management of Eagler servers in Docker

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed. Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        print_message "Docker installed successfully! You may need to log out and log back in for changes to take effect."
        return 1
    else
        print_message "Docker is already installed."
        return 0
    fi
}

# Function to initialize the environment inside Docker container
init_environment() {
    print_message "Initializing environment within Docker container..."
    
    # Enter the Docker container and run commands
    docker exec -it mc-server bash -c '
        echo "Installing system dependencies..."
        apt update && apt install -y sudo nano ranger curl unzip zip tmux
        
        echo "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        
        echo "Initializing SDKMAN..."
        source "/root/.sdkman/bin/sdkman-init.sh"
        
        echo "Installing Java 17.0.9-amzn..."
        bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk install java 17.0.9-amzn"
        
        echo "Environment setup complete!"
    '
    
    if [ $? -eq 0 ]; then
        print_message "Environment initialization completed successfully!"
    else
        print_error "Environment initialization failed!"
        exit 1
    fi
}

# Function to start all servers using tmux sessions
start_servers() {
    print_message "Starting servers using tmux sessions..."
    
    # Start Velocity server
    docker exec -it mc-server bash -c '
        cd /data/eagler-server
        tmux new-session -d -s velocity
        tmux send-keys -t velocity "cd velocity && chmod +x velocity.sh && ./velocity.sh" C-m
        echo "Velocity server started!"
    '
    
    # Start main server
    docker exec -it mc-server bash -c '
        cd /data/eagler-server
        tmux new-session -d -s server
        tmux send-keys -t server "cd server && chmod +x server.sh && ./server.sh" C-m
        echo "Main server started!"
    '
    
    # Start Limbo server
    docker exec -it mc-server bash -c '
        cd /data/eagler-server
        tmux new-session -d -s limbo
        tmux send-keys -t limbo "cd limbo && chmod +x limbo.sh && ./limbo.sh" C-m
        echo "Limbo server started!"
    '
    
    print_message "All servers started successfully!"
    print_message "To attach to a server, use: docker exec -it mc-server tmux a -t [velocity|server|limbo]"
}

# Function to create a backup of the server folder
backup_servers() {
    current_date=$(date +%Y-%m-%d)
    backup_name="mc-servers-backup-${current_date}.zip"
    
    print_message "Creating backup: $backup_name"
    
    docker exec -it mc-server bash -c "cd /data && zip -r ${backup_name} eagler-server"
    
    if [ $? -eq 0 ]; then
        print_message "Backup created successfully at: ./persistent-storage-folder/${backup_name}"
    else
        print_error "Backup creation failed!"
        exit 1
    fi
}

# Function to check if the Docker container is running
check_container_running() {
    if [ "$(docker ps -q -f name=mc-server)" ]; then
        return 0
    else
        return 1
    fi
}

# Function to start Docker Compose
start_docker_compose() {
    print_message "Starting Docker Compose services..."
    
    # Check if we're in the directory with docker-compose.yml
    if [ ! -f "docker-compose.yml" ]; then
        print_warning "docker-compose.yml not found in current directory."
        print_message "Please navigate to the directory containing docker-compose.yml and try again."
        exit 1
    fi
    
    # Run docker compose up (modern approach)
    docker compose up -d
    
    if [ $? -eq 0 ]; then
        print_message "Docker Compose services started successfully!"
    else
        print_error "Failed to start Docker Compose services!"
        exit 1
    fi
}

# Function to wait for container to be ready
wait_for_container() {
    print_message "Waiting for container to be fully started..."
    sleep 5  # Give the container time to initialize
}

# Display help message
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --init      Check for Docker, start container, and initialize environment"
    echo "  --start     Start all Minecraft servers in tmux sessions"
    echo "  --backup    Create a backup of all server data"
    echo "  --help      Display this help message"
    echo ""
}

# Main script execution
case "$1" in
    --init)
        check_docker
        start_docker_compose
        wait_for_container
        init_environment
        ;;
    --start)
        if ! check_container_running; then
            print_warning "Docker container is not running. Starting it now..."
            start_docker_compose
            wait_for_container
        fi
        start_servers
        ;;
    --backup)
        if ! check_container_running; then
            print_error "Docker container is not running. Please start it first with --init or --start"
            exit 1
        fi
        backup_servers
        ;;
    --help)
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

exit 0
