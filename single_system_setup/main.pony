use "math"

actor Worker
  let coordinator: Coordinator tag
  let start_value: U64
  let end_value: U64
  let k: U64

  new create(c: Coordinator tag, start: U64, end': U64, k': U64) =>
    coordinator = c
    start_value = start
    end_value = end'
    k = k'
    coordinator.worker_created(start, end')

  be calculate_sum() =>
    //coordinator.worker_started(start_value)
    var i: U64 = start_value
    var isFirstTime = true
    var sum: U64 = 0
    while i <= end_value do
      var j: U64 = 0
      if isFirstTime then
          while j < k do
            sum = sum + ((i + j) * (i + j))
            j = j + 1
          end
          isFirstTime=false
      else
          sum=sum-((i-1)*(i-1))
          sum =sum+((i+(k-1))*(i+(k-1)))
      end
      let root = int_sqrt(sum)
      if (root * root) == sum then
        coordinator.report_result(i)
      end
      i = i + 1
    end
    coordinator.worker_finished(start_value)

  fun int_sqrt(n: U64): U64 =>
    var x: U64 = n
    var y: U64 = (x + 1) / 2
    while y < x do
      x = y
      y = (x + (n / x)) / 2
    end
    x

actor Coordinator
  var count: U64 = 0
  var workers_finished: U64 = 0
  var total_workers: U64 = 0
  let coord_env: Env

  new create(env': Env) =>
    coord_env = env'
    coord_env.out.print("Coordinator created")

  be start(n: U64, k: U64) =>
    coord_env.out.print("Starting calculation for n=" + n.string() + ", k=" + k.string())
    let max_concurrent_workers: U64 = 8
    let work_unit_size: U64 = (n / max_concurrent_workers).max(1)
    var i: U64 = 1
    while i <= n do
      let end_value = ((i + work_unit_size) - 1).min(n)
      let worker = Worker(this, i, end_value, k)
      worker.calculate_sum()
      total_workers = total_workers + 1
      i = i + work_unit_size
    end
    coord_env.out.print("Total workers created: " + total_workers.string())

  be worker_created(start_val: U64, end_val: U64) =>
    coord_env.out.print("Worker created: " + start_val.string() + " to " + end_val.string())

  be worker_started(start_value: U64) =>
    coord_env.out.print("Worker started: " + start_value.string())

  be report_result(start_value: U64) =>
    coord_env.out.print("Result found: " + start_value.string())
    count = count + 1

  be worker_finished(start_value: U64) =>
    workers_finished = workers_finished + 1
    coord_env.out.print("Worker finished: " + start_value.string())
    coord_env.out.print("Total finished: " + workers_finished.string() + "/" + total_workers.string())
    if workers_finished == total_workers then
      coord_env.out.print("All workers finished")
      coord_env.out.print("Total results found: " + count.string())
      coord_env.out.print("Completed")
    end

actor Main
  new create(env: Env) =>
    env.out.print("Program started")
    try
      let args = env.args
      env.out.print("Arguments count: " + args.size().string())
      if args.size() < 3 then
        env.out.print("Usage: lukas <n> <k>")
        return
      end
      env.out.print("Parsing arguments")
      let n = args(1)?.u64()?
      let k = args(2)?.u64()?
      env.out.print("Creating coordinator")
      let coordinator = Coordinator(env)
      env.out.print("Starting calculation")
      coordinator.start(n, k)
    else
      env.out.print("Error in argument parsing")
      env.out.print("Usage: lukas <n> <k>")
    end