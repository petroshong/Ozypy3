#!/bin/bash
# Shell script to start the frontend development server
# This script handles port conflicts and provides a better developer experience

# Set the base directory path (project root)
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FRONTEND_DIR="$BASE_DIR/frontend"
CONFIG_FILE="$FRONTEND_DIR/env.development"

# Load environment variables from env.development if it exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Loading configuration from $CONFIG_FILE"
    # Load variables but don't export them to environment
    ENV_CONFIG=$(grep -v '^#' "$CONFIG_FILE" | xargs -L 1 echo)
    
    # Get PORT value if defined
    CONFIGURED_PORT=$(grep -v '^#' "$CONFIG_FILE" | grep "^PORT=" | cut -d= -f2)
fi

# Default to port 3000 if not configured
if [ -z "$CONFIGURED_PORT" ]; then
    CONFIGURED_PORT=3000
fi

echo "Configured port: $CONFIGURED_PORT"

# Function to check if a port is in use
is_port_in_use() {
    if command -v lsof > /dev/null; then
        lsof -i:"$1" > /dev/null 2>&1
        return $?
    elif command -v netstat > /dev/null; then
        netstat -tuln | grep ":$1 " > /dev/null 2>&1
        return $?
    else
        # Fallback to direct TCP connection test
        (echo > /dev/tcp/localhost/$1) > /dev/null 2>&1
        return $?
    fi
}

# Function to find a free port starting from the specified port
find_free_port() {
    local start_port=$1
    local max_port=$((start_port + 20))
    local port=$start_port
    
    while [ "$port" -le "$max_port" ]; do
        if ! is_port_in_use "$port"; then
            echo "$port"
            return 0
        fi
        echo "Port $port is in use, trying port $((port + 1))..."
        port=$((port + 1))
    done
    
    echo "Could not find a free port between $start_port and $max_port" >&2
    echo "$start_port"  # Return original port if no free ports found
    return 1
}

# Function to get the process using a specific port
get_process_on_port() {
    local port=$1
    
    if command -v lsof > /dev/null; then
        lsof -i:"$port" -t
    elif command -v netstat > /dev/null && command -v grep > /dev/null && command -v awk > /dev/null; then
        netstat -tuln | grep ":$port " | awk '{print $7}' | cut -d/ -f1
    else
        echo ""
    fi
}

# Find a free port starting from the configured port
FREE_PORT=$(find_free_port "$CONFIGURED_PORT")

if [ "$FREE_PORT" != "$CONFIGURED_PORT" ]; then
    echo "Port $CONFIGURED_PORT is in use, using port $FREE_PORT instead."
    
    # Ask if the user wants to update the env.development file
    read -p "Do you want to update env.development with the new port? (y/n) " UPDATE_ENV_FILE
    
    if [ "$UPDATE_ENV_FILE" = "y" ] || [ "$UPDATE_ENV_FILE" = "Y" ]; then
        if [ -f "$CONFIG_FILE" ]; then
            # Check if PORT is already in the file
            if grep -q "^PORT=" "$CONFIG_FILE"; then
                # Replace the existing PORT line
                sed -i.bak "s/^PORT=.*/PORT=$FREE_PORT/" "$CONFIG_FILE" && rm "$CONFIG_FILE.bak"
                echo "Updated env.development with PORT=$FREE_PORT"
            else
                # Append PORT if not found
                echo "PORT=$FREE_PORT" >> "$CONFIG_FILE"
                echo "Added PORT=$FREE_PORT to env.development"
            fi
        else
            # Create the file if it doesn't exist
            echo "PORT=$FREE_PORT" > "$CONFIG_FILE"
            echo "Created env.development with PORT=$FREE_PORT"
        fi
    fi
fi

# Check for processes on the port and offer to kill them
PROCESSES=$(get_process_on_port "$FREE_PORT")

if [ -n "$PROCESSES" ]; then
    echo "Found these processes running on port $FREE_PORT:"
    
    for PID in $PROCESSES; do
        if command -v ps > /dev/null; then
            PROCESS_INFO=$(ps -p "$PID" -o pid,comm | grep -v PID)
            echo "$PROCESS_INFO"
        else
            echo "PID: $PID"
        fi
    done
    
    read -p "Do you want to kill these processes? (y/n) " KILL_PROCESSES
    
    if [ "$KILL_PROCESSES" = "y" ] || [ "$KILL_PROCESSES" = "Y" ]; then
        for PID in $PROCESSES; do
            kill -9 "$PID" 2>/dev/null
            echo "Killed process with PID: $PID"
        done
    else
        echo "Attempting to use port $FREE_PORT anyway..."
    fi
fi

# Set the environment variable for the port
export PORT="$FREE_PORT"

# Navigate to the frontend directory
cd "$FRONTEND_DIR" || exit 1

# Use either pnpm or npm based on what's available
if command -v pnpm > /dev/null; then
    # Run the development server with pnpm
    echo "Starting development server on port $FREE_PORT with pnpm..."
    pnpm run dev
else
    # Run the development server with npm
    echo "Starting development server on port $FREE_PORT with npm..."
    npm run dev
fi 