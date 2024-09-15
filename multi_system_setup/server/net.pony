use "net"

actor Main
  new create(env: Env) =>
    var ip: String = ""
    var port: String = ""
    try
      let n = env.args(1)?.u64()?
      let k = env.args(2)?.u64()?
      ip = env.args(3)?
      port = env.args(4)?
      let max_client_num = env.args(5)?.u64()?

      env.out.print("Creating TCP listener")
      let auth = TCPListenAuth(env.root)
      let notify = recover Listener(env, n, k, ip, port, max_client_num) end
      let listener = TCPListener(auth, consume notify, ip, port)
      
      match listener
      | let l: TCPListener =>
        env.out.print("TCP server started successfully on " + ip + ":" + port)
      end
    else
      env.out.print("Error parsing arguments or starting TCP server")
      env.out.print("Usage: program <n> <k> <ip> <port> <max_client_num>")
    end