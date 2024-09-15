# dosp-project1

# Lukas Algorithm

This project implements a parallelized algorithm for finding perfect squares that are sums of consecutive squares using the actor model.

## Work Unit Size

The work unit size refers to the number of sub-problems that a worker processes in one request from the coordinator (boss). Based on our tests, the optimal work unit size for best performance is determined by the following formula:

```plaintext

work_unit_size = (n / max_concurrent_workers).max(1)

```

Where:

- `n` is the total number of sub-problems to solve.

- `max_concurrent_workers` is the maximum number of workers (set to 8 in our implementation).

We chose this work unit size because it balances the workload across the available workers and minimizes idle time. Larger work unit sizes lead to fewer task switches, reducing the overhead, while smaller sizes allow for better load balancing across cores.

### Performance Consideration:

In our tests, this size allowed all cores to be used efficiently without overloading any single worker or leaving too many idle. Adjustments were made based on CPU usage analysis and trial runs with different values of `n` and `k`.

## Results for `lukas 1000000 4`

- **Number of workers created**: 8 workers

- **Total results found**: 0

- **Time taken **:  

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

lukas 1000000 4

```

This was done in **0.069 seconds**, demonstrating efficient parallelization. Larger problem sizes could also be solved, but this configuration provided a good balance between complexity and performance.

## Running Instructions

To run the program, use the following format:

```bash

./lukas <n> <k>

```

For example:

```bash

./lukas 1000000 4

```

Where:

- `n` is the upper limit of the range to check.

- `k` is the number of consecutive squares to sum.

## Conclusion

This implementation efficiently divides the problem into work units and leverages parallelism using actors. The results demonstrate good utilization of CPU cores, and the system scales well with the problem size. Further optimization can focus on reducing overhead for small workloads and improving parallel efficiency for larger problem sets.
