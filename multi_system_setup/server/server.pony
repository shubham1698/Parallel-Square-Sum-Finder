use "net"
use "collections"

class ClientHandler is TCPConnectionNotify
  let _env: Env
  let _server: Server tag
  var _max_client_num:U64=0

  new iso create(env: Env, server: Server tag, max_client_num:U64) =>
    _env = env
    _max_client_num=max_client_num
    _server = server

  fun ref accepted(conn: TCPConnection ref) =>
    _env.out.print("Connection accepted")
    _server.client_connected(conn,_max_client_num)

  fun ref received(conn: TCPConnection ref, data: Array[U8] val, times: USize): Bool =>
    let msg = String.from_array(data)
    _server.handle_message(conn, msg)
    true

  fun ref closed(conn: TCPConnection ref) =>
    _env.out.print("Connection closed")
    _server.client_disconnected(conn)

  fun ref connect_failed(conn: TCPConnection ref) =>
    _env.out.print("Connection closed")

actor Server
  let _env: Env
  let _n: U64
  let _k: U64
  var _current_start: U64 = 1
  let _clients: Array[TCPConnection tag] = Array[TCPConnection tag]

  new create(env: Env, n: U64, k: U64) =>
    _env = env
    _n = n
    _k = k

  be client_connected(conn: TCPConnection tag,max_client_num:U64) =>
    _clients.push(conn)
    _env.out.print("Client added to server. Total clients: " + _clients.size().string())
    conn.write("Server says hi".array())

    if _clients.size() == max_client_num.usize() then
      _env.out.print("Both clients connected. Distributing tasks...")
      distribute_tasks()
    end

  be client_disconnected(conn: TCPConnection tag) =>
    try
      let index = _clients.find(conn)?
      _clients.delete(index)?
      _env.out.print("Client removed from server. Total clients: " + _clients.size().string())
    end

  be handle_message(conn: TCPConnection tag, msg: String) =>
    _env.out.print("Received message: " + msg)

  fun ref distribute_tasks() =>
    let end_value = _n
    let chunk_size = end_value / _clients.size().u64()

    for client in _clients.values() do
      let end_task_value: U64 = ((_current_start + chunk_size) - 1).min(end_value)
      let task_message:String = "TASK:" + _current_start.string() + ":" + end_task_value.string() + ":" + _k.string()
      _env.out.print("Sending task to client: " + task_message)

      client.write(task_message.array())

      _current_start = end_task_value + 1
    end