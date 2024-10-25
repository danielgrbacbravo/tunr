#!/bin/zsh

command -v brew >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
command -v gum >/dev/null 2>&1 || brew install gum

show_network_connection_status() {
    local target_ssid="$1"
    local ssh_host="$2"
    local is_connected="$3"

    # Conditional message based on connection status using && and ||
    if [ "$is_connected" = true ]; then
        echo -e "\e[1mOn target network\e[0m \e[3m$target_ssid\e[0m.\n\e[32mDirect connection to\e[0m \e[1m$ssh_host\e[0m\n"
    else
        echo -e "\e[1mNot on target network\e[0m \e[3m$target_ssid\e[0m.\n\e[31mNo direct connection to\e[0m \e[1m$ssh_host\e[0m.\n"
    fi
}

show_service_connection_status() {
    local service_name="$1"
    local is_connected="$2"

    # Conditional message based on connection status using && and ||
    if [ "$is_connected" = true ]; then
        echo -e "\e[32mConnected to\e[0m \e[1m$service_name\e[0m.\n"
    else
        echo -e "\e[31mNot connected to\e[0m \e[1m$service_name\e[0m.\n"
    fi
}


# print functions using gum

is_on_network() {
  local target_ssid="$1"  # The SSID you want to check against
  local current_ssid

  # Get the current SSID
  # Seqoia workaround
  # since networksetup -getairportnetwork en0 doesn't work
  current_ssid=$(airport -I | awk -F ': ' '/ SSID/ {print $2}')

  # Check if the current SSID matches the target SSID
  [[ "$current_ssid" == "$target_ssid" ]] && return 0 || return 1
}

connect_service(){
  local service_name="${1:-your-service-name}"
  networksetup -connectpppoeservice "$service_name"
}

# Function to disconnect from a specified service (e.g., VPN)
disconnect_service(){
  local service_name="${1:-your-service-name}"
  networksetup -disconnectpppoeservice "$service_name"
}

# Function to check the status of a specified service
# returns 0 if connected, 1 if not connected
service_status() {
  local service_name="${1:-your-service-name}"
  [[ "$(networksetup -showpppoestatus "$service_name")" == "connected" ]] && return 0 || return 1
}

# Function to SSH into the specified host
ssh_to_host() {
  local ssh_host="$1"
  local ssh_port="${2:-22}"  # Default SSH port is 22
  ssh -p "$ssh_port" "$ssh_host"
}

# Main SSH connection function that checks network and connects via the service
ssh_via_service() {
  local service_name="${1:-your-service-name}"
  local ssh_host="$2"
  local ssh_port="${3:-22}"  # Default SSH port is 22
  local target_ssid="${4:-YourSSID}"  # Specify your target SSID here


  is_on_network "$target_ssid" && {
    show_network_connection_status "$target_ssid" "$ssh_host" true
    ssh_to_host "$ssh_host" "$ssh_port"
  } || {

    show_network_connection_status "$target_ssid" "$ssh_host" false
    connect_service "$service_name" && {
    gum spin --spinner dot --title "Connecting to Service ..." -- sleep 2 &&  # Wait for service to connect
      service_status "$service_name" && {
        show_service_connection_status "$service_name" true
        ssh_to_host "$ssh_host" "$ssh_port" &&
        disconnect_service "$service_name" &&
        show_service_connection_status "$service_name" false
      } || echo "Service connection failed"
    } || echo "Failed to connect to the VPN service."
  }
}

alias lmm='ssh_via_service "daniel-apartment" "daiigr@192.168.2.7" 22 "LAN Solo"'
