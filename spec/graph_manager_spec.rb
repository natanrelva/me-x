require 'rspec'
require_relative '../lib/graph_manager'

RSpec.describe GraphManager do
  let(:graph) { Graph.new } # Explicitly initialize a graph
  let(:graph_manager) { GraphManager.new(graph, 1) } # Provide the graph and set batch_size to 1

  describe '#process_log' do
    it 'adds a node to the graph when receiving add_node event' do
      log = '{"event": "add_node", "id": "N5"}'
      expect { graph_manager.process_log(log) }.to change { graph_manager.graph.nodes.size }.by(1)
    end

    it 'creates an edge between nodes when receiving transition event' do
      graph_manager.graph.nodes = [
        { id: 'N2', number: 2, x: 0, y: 0, connections: [], last_used: Time.now },
        { id: 'N3', number: 3, x: 80, y: 80, connections: [], last_used: Time.now }
      ]
      log = '{"event": "transition", "source": "N2", "target": "N3"}'
      expect {
        graph_manager.process_log(log)
        graph_manager.process_batch # Manually process the batch
      }.to change { graph_manager.graph.edges.size }.by(1)
    end

    it 'handles unknown events gracefully' do
      log = '{"event": "unknown_event"}'
      expect { graph_manager.process_log(log) }.not_to raise_error
    end
  end

  describe '#process_batch' do
    it 'processes logs in batches' do
      log1 = '{"event": "add_node"}'
      log2 = '{"event": "add_node"}'
      expect(graph_manager.graph.nodes.size).to eq(0)
      graph_manager.process_log(log1)
      graph_manager.process_log(log2)
      graph_manager.process_batch
      expect(graph_manager.graph.nodes.size).to eq(2)
    end
  end

  describe '#record_metrics' do
    it 'records metrics over time' do
      graph_manager.graph.add_node
      graph_manager.record_metrics
      expect(graph_manager.metrics_history.size).to eq(1)
    end
  end

  describe '#save_graph and #load_graph' do
    it 'saves and loads graph state' do
      graph_manager.graph.add_node
      graph_manager.graph.add_node
      graph_manager.graph.generate_edges
      graph_manager.save_graph

      new_manager = GraphManager.new
      new_manager.load_graph
      expect(new_manager.graph.nodes.size).to eq(graph_manager.graph.nodes.size)
      expect(new_manager.graph.edges.size).to eq(graph_manager.graph.edges.size)
    end
  end
end
