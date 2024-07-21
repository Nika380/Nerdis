# Nerdis
## Minimal Redis Clone

Nerdis is a minimalistic Redis clone designed to mimic some of the core functionalities of Redis, including basic data operations and master-slave replication.

### Features
- **Data Commands**:
  - `GET`: Retrieve the value of a key.
  - `SET`: Set the value of a key, with optional expiration.
- **Replication**:
  - Handles replication with master-slave configuration.
  - Runs write commands from master to all replicas.
- **Other Commands**:
  - `INFO`: Provides replication info.
  - `PING`: Test if a connection is still alive.
  - `ECHO`: Echoes back the input.

### How To Start the Application

#### Master Node
To start the master node, use the following command:
```sh
crystal src/nerdis.cr --port 4444
```

#### Slave  Node
To start a slave node, use the following command, specifying the master node's address and port:
```sh
crystal src/nerdis.cr --port 2222 --replicaof "localhost 4444"
```
## Commands Supported
```sh
GET key
```
```sh
SET key
SET key value px 3000 # Set Value With Expiration
```
```sh
INFO replication # Returns Node Info
```
```sh
PING 
```
```sh
ECHO message
```
## Replication
Nerdis supports master-slave replication. When a slave node connects to the master, a handshake is initiated. The master node then propagates write commands (e.g., SET) to all connected slave nodes to ensure data consistency.

## How To Run Commands
### Connect Node With Redis Cli
```sh
redis-cli -p 4444
```