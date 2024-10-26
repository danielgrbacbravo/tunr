#!/bin/zsh

# Load Homebrew and Gum, if not installed
command -v brew >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
command -v gum >/dev/null 2>&1 || brew install gum

# Load variables from .tunr_env if it exists
[ -f ~/.tunr_env ] && source ~/.tunr_env

# Functions to set each required variable and save to .tunr_env

set_service_var(){
    networkservices=($(networksetup -listallnetworkservices | grep -v "denotes"))
    service=$(gum choose --header "choose your VPN config" "${networkservices[@]}")
    export service
    save_variable_to_env "service" "$service"
}

set_target_network_var(){
    current_ssid=$(ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}')
    gum confirm "is $current_ssid your target network?" && \
    target_network=$current_ssid || target_network=$(gum input --header "enter your target network")
    export target_network
    save_variable_to_env "target_network" "$target_network"
}

set_ssh_host(){
    server_ssh_host=$(gum input --header "SSH Hostname" --placeholder "host@ip")
    export server_ssh_host
    save_variable_to_env "server_ssh_host" "$server_ssh_host"
}

set_ssh_port(){
    server_ssh_port=$(gum input --header "SSH Port" --placeholder "22")
    export server_ssh_port
    save_variable_to_env "server_ssh_port" "$server_ssh_port"
}

set_ssh_alias(){
    ssh_alias=$(gum input --header "SSH alias (command to connect)" --placeholder "my-lil-server")
    export ssh_alias
    save_variable_to_env "ssh_alias" "$ssh_alias"
}

# Function to save variables to .tunr_env
save_variable_to_env() {
    local var_name="$1"
    local var_value="$2"
    # Ensure unique variable entry, then append or update it
    grep -q "^export $var_name=" ~/.tunr_env && \
        sed -i '' "s/^export $var_name=.*/export $var_name=\"$var_value\"/" ~/.tunr_env || \
        echo "export $var_name=\"$var_value\"" >> ~/.tunr_env
}

# Function to clear all variables from the environment and .tunr_env
clear_all_variables() {
    echo "Clearing all variables"
    unset service target_network server_ssh_host server_ssh_port ssh_alias

    # Remove the variables file
    rm -f ~/.tunr_env
}

# Prompt to set variables only if they are unset
[[ -z "$service" ]] && set_service_var
[[ -z "$target_network" ]] && set_target_network_var
[[ -z "$server_ssh_host" ]] && set_ssh_host
[[ -z "$server_ssh_port" ]] && set_ssh_port
[[ -z "$ssh_alias" ]] && set_ssh_alias

# Alias to clear all variables
alias tunr_clear="clear_all_variables"
