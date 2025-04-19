> [!IMPORTANT]
> DOCS NOT FINISHED
> 

# EaglerServerXVelocity
Scripts to get your EaglerServer up and running without a hassle
> [!IMPORTANT]
> Follow the step by step to use EaglerCux
> 
### Setup
I made this to be run in docker so the instruction will be based on a flat ubuntu docker image until I care enough to actually make a docker image 

## Installing deps
**Updating/Installing:**
```bash
apt update -y && apt install sudo python3 pip nano ranger curl unzip zip tmux
```
## Installing java
**Installing SDKMAN:**
```bash
curl -s "https://get.sdkman.io" | bash
```
**Installing Java:**
```bash
sdk install java 17.0.9-amzn
```

# Create the tmux sessions
```bash
tmux new -s server
```
```bash
tmux new -s velocity
```
```bash
tmux new -s limbo
```
## Commands to start the server
```bash
tmux a -t server
cd server
chmod +x server.sh
./server.sh
```
## Commands to start the Velocity proxy
```bash
tmux a -t velocity
cd velocity
chmod +x velocity.sh
./velocity.sh
```
## Commands to start Limbo/nLogin (Verify your players)
```bash
tmux a -t limbo
cd limbo
chmod +x limbo.sh
./limbo.sh
```

## Misc Information
#### tmux cheat sheet
**Creating session**
```bash
tmux new -s <session_name>
```
**Connecting to session**
```bash
tmux a -t <session_name>
```
**Exiting a session**
```
hit control + B and then hit D
```
**Scroll Mode**
```
hit control + B and then hit [
```
You can exit scroll mode by hitting `Q`

#### How to be an operator/admin in the server?

1.) Go to the Server/Backend - > First tab

2.) then type "op username" without "" and change the username to yours
