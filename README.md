# CS 2080 Team-M3 Project: Multi-Server LAMP Stack Automation (But Docker)

Brianna told me about this, figured I would give it a crack before 3300. Same stuff, but instead of using Vagrant and Ansible, I used Digital Ocean and Dockerization. I additionally added security support.

Group Members:
* pexx

## Project Structure
- `test.sh`: Legit the entire project.

## Prerequisites
- [Digital Ocean](https://www.digitalocean.com/)
- [Docker](https://hub.docker.com/)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Setup

1. Clone this repository

```bash
git clone https://github.com/pex-x/Unix2080Work.git
cd Unix2080Work
chmod +777 test.sh
./test.sh
```
That is seriously it. Nothing special.

## Server Details

### Database Server (db)
- Runs MySQL server
- Stores scripts table with file paths

### Application Server (app)
- Runs Apache and dealers choice of PHP, Python, or Perl.
- Choose what you want, it's all automated and secured.

## Usage

### Accessing the Servers
Publish webpages, custom scripts, or do anything, but you can access it all via a public IP.

## Customization

- Modify the `Vagrantfile` to change VM configurations.
- Update `playbook.yml` to alter server setups or add new features.
- Edit the Python script on the auth server to change how scripts are fetched and executed.

## Troubleshooting

If you encounter issues:
1. Ensure all prerequisites are correctly installed.
2. Check that the IP addresses in the Vagrantfile match those in your virtual network.
3. Verify that the MySQL server is configured to accept remote connections.
4. Check firewall settings to ensure necessary ports are open.

## Contributing

Contributions to improve the project are welcome. Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature.
3. Commit your changes.
4. Push to the branch.
5. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/rukhat/Multi-Server-LAMP-Stack-Automation/blob/main/LICENSE) file for details

### Prerequisites
- A Digital Ocean container running Ubuntu 22.04 or any other distro.
- SSH access to the server

### Step-by-Step Setup

1. **Start a Digital Ocean Container and Run the Script.**
