import Vapor

class GameServer {
    let queue = DispatchQueue(label: "hi")
    var sockets = [WebSocket]()
    var text = ""
}

let gameServer = GameServer()


func fire() {
    gameServer.queue.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
        
        var message = "."
        if !gameServer.text.isEmpty {
            message = gameServer.text
            gameServer.text = ""
        }
        
        for socket in gameServer.sockets {
            socket.send(message)
        }
        
        fire()
    })
}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
 
    //    let serverConfig = NIOServerConfig.default(hostname: "127.0.0.1")
    //    services.register(serverConfig)
    
    let wss = NIOWebSocketServer.default()
    
    wss.get("echo") { ws, req in
        
        gameServer.sockets.append(ws)
        
        ws.onText { ws, text in
            gameServer.text.append("\(text),")
        }
        
    }
    
    // Register our server
    services.register(wss, as: WebSocketServer.self)
    
    fire()
}
