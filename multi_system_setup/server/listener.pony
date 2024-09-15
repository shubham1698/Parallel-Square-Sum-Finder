use "net"
use "files"

class Listener is TCPListenNotify
  let _env: Env
  var _count_num_client: U64 = 0
  var _host: String = ""
  var _service: String = ""
  var _max_client_num:U64=0
  let _server: Server tag

  new create(env: Env, n: U64, k: U64,ip:String,port:String,max_client_num:U64) =>
        
    _env = env
    _server = Server(_env, n, k)
    _host=ip
    _service=port
    _max_client_num=max_client_num


  fun ref listening(listen: TCPListener ref) =>
    _env.out.print("Listening on " + _host + ":" + _service)

  fun ref not_listening(listen: TCPListener ref) =>
    _env.out.print("Not listening")
    listen.close()

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    _count_num_client = _count_num_client + 1
    _env.out.print("Client connected. Total clients: " + _count_num_client.string())
    
    // Return a new ClientHandler instance, passing the server reference
    recover iso ClientHandler(_env, _server,_max_client_num) end

  fun ref closed(listen: TCPListener ref) =>
    _env.out.print("Listener closed")