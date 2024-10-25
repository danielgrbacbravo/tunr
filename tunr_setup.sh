#!/bin/zsh
command -v brew >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
command -v gum >/dev/null 2>&1 || brew install gum

# get all the networkservices and create a array of them
# command refernce networksetup -listallnetworkservices

# Check if the required variables are set using && and ||

set_service_var(){
networkservices=($(networksetup -listallnetworkservices | grep -v "denotes"))
service=$(gum choose --header "choose your VPN config"  "${networkservices[@]}")
export service
}


set_target_network_var(){
current_ssid=$(ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}')
gum confirm "is $current_ssid your target network?" && \
  target_network=$current_ssid || target_network=$(gum input --header "enter your target network")
export target_network
}

set_ssh_host(){
server_ssh_host=$(gum input --header "SSH Hostname" --placeholder "host@ip")
export server_ssh_host
}


set_ssh_port(){
server_ssh_port=$(gum input --header "SSH Port" --placeholder "22")
export server_ssh_port
}


set_ssh_alias(){
 ssh_alias=$(gum input --header "SSH alias (command to connect)" --placeholder "my-lil-server")
 export ssh_alias
}

clear_all_variables() {
echo "clearing all variables"
  service=""
  target_network=""
  server_ssh_host=""
  server_ssh_port=""
  ssh_alias=""
}


[[ -z "$service" ]] && set_service_var
[[ -z "$target_network" ]] && set_target_network_var
[[ -z "$server_ssh_host" ]] && set_ssh_host
[[ -z "$server_ssh_port" ]] && set_ssh_port
[[ -z "$ssh_alias"       ]] && set_ssh_alias

alias tunr_clear="clear_all_variables"
