require 'faye/websocket'
require 'eventmachine'
require_relative '../lib/graph_manager'

class WebSocketServer
  def initialize(port = 3000)
    @port = port
    @graph_manager = GraphManager.new
  end

  def start
    EM.run do
      puts "WebSocket server running on port #{@port}"

      EM::WebSocket.run(host: '0.0.0.0', port: @port) do |ws|
        ws.onopen { puts 'Client connected' }
        ws.onmessage { |msg| handle_message(ws, msg) }
        ws.onclose { puts 'Client disconnected' }
      end
    end
  end

  private

  def handle_message(ws, msg)
    @graph_manager.process_log(msg)
    ws.send(JSON.dump({ nodes: @graph_manager.graph.nodes, edges: @graph_manager.graph.edges }))
  end
end
