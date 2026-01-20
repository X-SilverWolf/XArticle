# Linux Tools Install

## SSH Server

Install SSH used: sudo apt install ssh

```bash
systemctl enable ssh.service
```

 used to create an SSH service.

## C++ Base Tools

```bash
sudo apt install gcc g++ gdb
```

## VS Code connects to Linux without  password

1. Windows creates the ssh key used:  

```bash
    ssh-keygen -t ed25519 -f  ${FileNamePath}$
```

1. Take the public key and append to Linux Server:

   > "~/.ssh/authorized_keys"

2. Open VSCode ssh config file

> Host 192.168.12.128(VM)
  HostName 192.168.12.128
  User xsilver
  IdentityFile ${private key path}$
  PreferredAuthentications publickey

### Add more ssh files

  ```
  $ eval "$(ssh-agent -s)"  # open the ssh agent
   ssh-add ~/.ssh/y${SSH_KEY} # Add the private key
  ```
