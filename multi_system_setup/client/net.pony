use "net"

actor Main
  new create(env: Env) =>
    var ip: String = ""
    var port: String = ""
    try
    env.out.print("Client starting")
    ip = env.args(1)?
    port= env.args(2)?
    TCPConnection(
      TCPConnectAuth(env.root),
      ClientSide(env),
      ip,  // Ensure you are connecting to the correct host
      port)       // Ensure you are connecting to the correct port
 else
      env.out.print("Error connecting tp TCP server on " + ip + ":" + port)
    end
