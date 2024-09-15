use "net"
use "promises"

class ClientSide is TCPConnectionNotify
  let _env: Env
  var _conn:( TCPConnection|None) =None

  new iso create(env: Env) =>
    _env = env

  fun ref connecting(conn: TCPConnection ref, count: U32) =>
    _env.out.print("Connecting... attempt " + count.string())

  fun ref connected(conn: TCPConnection ref) =>
    try
      (let host, let service) = conn.remote_address().name()?
      _env.out.print("Connected to " + host + ":" + service)
      conn.set_nodelay(true)
      conn.set_keepalive(10)
      conn.write("Client says hi")
      _conn = conn
    else
      _env.out.print("Connection failed")
    end

fun ref process_data_and_get_result(data: String,conn: TCPConnection ref) =>
  
  let promise: Promise[String] = Promise[String]

  let task_actor = TaskMaster(_env)
  
  task_actor.perform_task(data, promise)
  promise.next[None]({(result: String) =>
           match _conn
    | let c: TCPConnection =>
      c.write(("Received result from client: " + result).array())
    | None =>
      _env.out.print("No connection available to send the result.")
       end
  })
  
  _env.out.print("Data sent to actor for processing")

  fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
    _env.out.print("Received data from server")

    let msg = String.from_array(consume data)
    _env.out.print("Received message: " + msg)

    process_data_and_get_result(msg,conn)

    true

  fun ref closed(conn: TCPConnection ref) =>
    _env.out.print("Client closed connection")

  fun ref connect_failed(conn: TCPConnection ref) =>
    _env.out.print("Connection failed")



actor TaskMaster
  let _env:Env
  var count: U64 = 0
  var workers_finished: U64 = 0
  var final_result:String=""
  var total_workers: U64 = 0
  var _promise:( Promise[String]|None) =None

  new create(env:Env)=>
      _env=env

  be perform_task(data: String, promise: Promise[String]) =>
     _promise = promise
    let parts: Array[String] val = data.split(":")
    try
      let start_val: String = parts(1)? // "1"
      let end_value_server: String = parts(2)? // "10"
      let window_size: String = parts(3)? // "4"
      let max_concurrent_workers: U64 = 8
      let work_unit_size: U64 = (end_value_server.u64()? / max_concurrent_workers).max(1)
      var i: U64 = start_val.u64()?
    
      _env.out.print("Starting calculation for n=" + end_value_server + ", k=" + window_size)
      
      while i <= end_value_server.u64()? do
        let end_value:U64 = ((i + work_unit_size) - 1).min(end_value_server.u64()?)
        let worker = TaskSlave(this, i, end_value, window_size.u64()?)
        worker.calculate_sum()
        total_workers = total_workers + 1
        i = i + work_unit_size
      end
    else
      _env.out.print("Error")
    end
  
  be report_result(start_value: U64) =>
    _env.out.print("Result found: " + start_value.string())
    final_result=final_result+" "+start_value.string()
    count = count + 1

  be worker_finished(start_value: U64) =>
    workers_finished = workers_finished + 1
    if workers_finished == total_workers then
      _env.out.print("All workers finished")
      _env.out.print("Task Completed")
      match _promise
        | let p: Promise[String] => p(final_result)
        | None => _env.out.print("No promise to fulfill.")
    end
    end


actor TaskSlave
  let taskMaster: TaskMaster tag
  let start_value: U64
  let end_value: U64
  let k: U64

  new create(c: TaskMaster tag, start: U64, end': U64, k': U64) =>
    taskMaster = c
    start_value = start
    end_value = end'
    k = k'

  be calculate_sum() =>
    
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
        taskMaster.report_result(i)
      end
      i = i + 1
    end
    taskMaster.worker_finished(start_value)

  fun int_sqrt(n: U64): U64 =>
    var x: U64 = n
    var y: U64 = (x + 1) / 2
    while y < x do
      x = y
      y = (x + (n / x)) / 2
    end
    x

