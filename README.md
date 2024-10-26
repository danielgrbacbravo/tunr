# tunr

**tunr** is a ZSH script that automates SSH connections through a specific network and/or VPN service, checking network connection status and handling service connections as needed.

<p align="center">
  <img src="assets/local.gif" alt="Local" width="200"/>
  <img src="assets/vpn.gif" alt="VPN" width="200"/>
</p>

## Features

- Checks if you’re connected to the target SSID before establishing the SSH connection.
- Connects to a VPN (or other specified service) automatically if not on the target network.
- Provides feedback on connection status to the target network, VPN service, and SSH host.
- Uses `gum` to show loading animations for connection steps.
- Automatically disconnects from the VPN service once the SSH session ends.

## Prerequisites

- **ZSH** as your shell.
- **gum** (optional, for connection animations).
- **airport** command (Mac-specific) to check the current SSID.
- **networksetup** command for managing VPN/PPP connections.
- A configured VPN or PPP service on your machine that you can connect to with `networksetup`.

## Installation and Setup

1. **Clone the repository** (or place the `tunr.sh` and `tunr_setup.sh` files into your desired directory):
   ```sh
   git clonehttps://github.com/danielgrbacbravo/tunr.git
   ```

2. **Configure `.zshrc`** to include `tunr`:

   Open `.zshrc` in your text editor:
   ```sh
   nano ~/.zshrc
   ```
   or
   ```sh
   code ~/.zshrc
   ```

   Add the following at the end of the file, adjusting the path as needed:
   ```sh
   export TUNR_DIR="/path/to/clone/repo"

   # Source setup and main script functions
   [ -f "$TUNR_DIR/tunr_setup.sh" ] && source "$TUNR_DIR/tunr_setup.sh" &&\
   [ -f "$TUNR_DIR/tunr.sh" ] && source "$TUNR_DIR/tunr.sh"
   ```

3. **Reload `.zshrc`** to activate changes:
   ```sh
   source ~/.zshrc
   ```

4. **Customize SSH Alias** (optional):
   You can set a shortcut alias for running `tunr`. Edit the script to replace `$ssh_alias` with your chosen alias and `$service`, `$server_ssh_host`, `$server_ssh_port`, and `$target_network` with your configuration.

5. **Customize VPN/Service and Network Settings**:
   - Replace `service_name` in `connect_service`, `disconnect_service`, and `service_status` functions with the actual name of your VPN or service.
   - Set the target network SSID in `target_ssid` variable in `ssh_via_service` as needed.

---

## Usage

Use the alias you set up (or manually call `ssh_via_service`) to connect via the network/VPN service:

```sh
$ssh_alias
```

## Functions Overview

- `show_network_connection_status` – Displays the current network status.
- `show_service_connection_status` – Shows whether you’re connected to the specified service.
- `is_on_network` – Checks if the system is connected to the specified network SSID.
- `connect_service` – Connects to a VPN or PPP service.
- `disconnect_service` – Disconnects from the VPN/PPP service.
- `service_status` – Checks if the specified service is currently connected.
- `ssh_to_host` – SSH into the specified host on a specific port.
- `ssh_via_service` – Main function to check network, connect to service, and SSH.

## Notes

- The script assumes `networksetup -getairportnetwork` isn’t available on Mac, using `airport -I` instead to obtain the SSID. Adjust if needed.
- This script is tailored for MacOS and may require adaptation for Linux or other Unix systems due to different networking command usage.

## License

This project is licensed under the MIT License.
