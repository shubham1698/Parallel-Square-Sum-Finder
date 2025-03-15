#Parallel-Square-Sum-Finder

This project implements a parallelized algorithm for finding perfect squares that are sums of consecutive squares using the actor model.

## Work Unit Size

we are dividing the problem by worker size which we have predefined and kept it as 8.
We chose this work unit size because it balances the workload across the available workers and minimizes idle time. Larger work unit sizes lead to fewer task switches, reducing the overhead, while smaller sizes allow for better load balancing across cores.

### Performance Consideration:

In our tests, this size allowed all cores to be used efficiently without overloading any single worker or leaving too many idle. Adjustments were made based on CPU usage analysis and trial runs with different values of `n` and `k`.

## Results for `n=1000000 k=4`

- **Number of workers created**: 8 workers

- **Total results found**: 0

- **Time Taken**:  

  - **User time**: 0.29 seconds  

  - **System time**: 0.01 seconds  

  - **CPU usage**: 433%  

  - **Total time**: 0.069 seconds (real time)

### Explanation:

- The high CPU usage percentage (433%) indicates that multiple cores were effectively utilized in parallel, suggesting good parallelism.

- The `user` time reflects the time spent by the CPU executing the user-level code, while the `system` time represents the time spent on system-level operations.

- Despite good CPU utilization, no results were found for the problem size `n = 1000000` and `k = 4`.

## Largest Problem Solved

The largest problem we managed to solve was:

```plaintext

<filename> 1000000 4

```

This was done in **0.069 seconds**, demonstrating efficient parallelization. Larger problem sizes could also be solved, but this configuration provided a good balance between complexity and performance.

## Running Instructions

To run the program, use the following format:

for single machines:

```for single machines

<filename> <n> <k>

```
### following are the screenshots for different number of workers:

#### 4 worker

![4 workers.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/4%20workers.jpeg?raw=true)

#### 8 worker

![8 workers.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/8%20workers.jpeg?raw=true)

#### 16 worker

![16 workers.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/16%20workers.jpeg?raw=true)

#### single machine on a different computer

![single machine.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/single%20machine.jpeg?raw=true)

#### largest values

![largestval2.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/largestval2.jpeg?raw=true)

![largestval.jpeg](https://github.com/shubham1698/dosp-project1/blob/main/largestval.jpeg?raw=true)


for multiple machines:

```for multiple machines

<filename> <n> <k> <ip> <port> <max_client_num>

```
where:

- `n` is the upper limit of the range to check.

- `k` is the number of consecutive squares to sum.

- `ip` is the ip of the system on which the server runs

- `port` is the port to which we want to connect

- `max_client_num` is the max number of clients 


For example:

```bash

<filename> 1000000 4

```

Where:

- `n` is the upper limit of the range to check.

- `k` is the number of consecutive squares to sum.

## Conclusion

This implementation efficiently divides the problem into work units and leverages parallelism using actors. The results demonstrate good utilization of CPU cores, and the system scales well with the problem size. Further optimization can focus on reducing overhead for small workloads and improving parallel efficiency for larger problem sets.


## Multi-Machine TCP Client-Server System

### Overview

This project implements a multi-machine TCP client-server system, where the server distributes computational tasks to multiple clients, and the clients process these tasks and send the results back to the server. The system is designed for performing calculations related to perfect squares that are sums of consecutive squares.

### Components

The system consists of the following main components:

1\. **Client (`client.pony`)**

2\. **Server (`server.pony`, `listener.pony`, `net.pony`, `client_handler.pony`)**

### Server Architecture

The server is responsible for managing incoming client connections and distributing computational tasks across multiple clients. It is divided into several classes:

1\. **`Listener`**: A TCP listener that accepts incoming client connections. It assigns each client to a `ClientHandler`.

2\. **`ClientHandler`**: Handles communication with a specific client. It manages receiving messages from the client and closing the connection when the client disconnects.

3\. **`Server`**: The core of the system. It manages all connected clients, distributes tasks once all clients have connected, and handles incoming messages from the clients.

### Client Architecture

The client connects to the server, receives a computational task, performs the calculation, and sends the result back to the server. The client is structured into the following parts:

1\. **`ClientSide`**: Implements the client logic. It manages connecting to the server, sending data to the server, receiving tasks, and processing the tasks.

2\. **`TaskMaster`**: The actor responsible for dividing the computational task into subtasks, distributing them to workers, and aggregating the results.

3\. **`TaskSlave`**: Performs the actual calculation for a subtask and reports the result back to the `TaskMaster`.

### System Workflow

1\. **Server Start-Up**

   - The server is started by invoking the `Main` actor from the `net.pony` file. The server begins listening for incoming TCP connections on the specified IP and port.

   - The server distributes computational tasks after all clients have connected.

2\. **Client Start-Up**

   - Clients are started by invoking the `ClientSide` class, which attempts to connect to the server.

   - Once a connection is established, the client sends a greeting and waits for a task to be assigned by the server.

3\. **Task Distribution**

   - When all expected clients have connected, the server splits the main task into smaller chunks. Each chunk is a range of numbers that the clients will process to find perfect squares that are sums of consecutive squares.

   - The server sends each client a message formatted as `TASK:<start>:<end>:<window_size>`, where:

     - `start` is the starting number for the computation.

     - `end` is the ending number for the computation.

     - `window_size` is the number of consecutive squares to sum.

4\. **Task Execution**

   - Upon receiving the task, the client processes the numbers in the given range using the `TaskMaster` and `TaskSlave` actors. Each `TaskSlave` checks if the sum of consecutive squares is a perfect square and reports any valid results back to the `TaskMaster`.

   - Once all workers have completed their tasks, the client sends the final result back to the server.

5\. **Result Handling**

   - The server receives the results from all clients and may further aggregate or display the results.

### How to Run the System

1\. **Server Setup**

   - Compile and run the server by passing the required arguments to the `Main` actor in `net.pony`:

   ```bash

./server <n> <k> <ip> <port> <max_client_num>

```

     - `<n>`: The upper limit of the range to search for perfect squares.

     - `<k>`: The number of consecutive squares to sum.

     - `<ip>`: The IP address on which the server listens.

     - `<port>`: The port on which the server listens.

     - `<max_client_num>`: The number of clients expected to connect.

2\. **Client Setup**

   - Compile and run the client by invoking the `ClientSide` class:


  ```bash

./client <server_ip> <server_port>

```

     - `<server_ip>`: The IP address of the server to connect to.

     - `<server_port>`: The port of the server to connect to.

### Example

1\. **Server**:

 ```bash

./server 100 4 127.0.0.1 8080 2

```

   This starts the server to distribute a task to find perfect squares that are sums of four consecutive squares in the range from 1 to 100, listening on `127.0.0.1:8080`, and expecting two clients to connect.

2\. **Client 1**:

 ```bash

./client 127.0.0.1 8080

```


3\. **Client 2**:

 ```bash

./client 127.0.0.1 8080

```


Once both clients are connected, the server will distribute the tasks, and the clients will process them and send back their results.

### Key Features

- **Concurrency**: The system leverages Pony's actor model to handle multiple clients concurrently. Each task is split across multiple `TaskSlave` actors for parallel processing.

- **Resilience**: The server and clients handle connection errors and client disconnections gracefully.

- **Task Distribution**: The server dynamically divides the computational load among connected clients, ensuring balanced task allocation.

### Dependencies

- **Pony**: This project uses the Pony programming language, which offers powerful concurrency and error-handling features.



