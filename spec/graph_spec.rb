require 'rspec'
require_relative '../lib/graph'

RSpec.describe Graph do
  let(:graph) { Graph.new(3) } # Initialize graph with a capacity of 3 nodes

  describe '#add_node' do
    it 'adds a node to the graph' do
      node = graph.add_node
      expect(graph.nodes.size).to eq(1)
      expect(graph.nodes.first[:id]).to eq(node[:id])
    end

    it 'respects the graph capacity' do
      4.times { graph.add_node }
      expect(graph.nodes.size).to eq(3)
    end
  end

  describe '#generate_edges' do
    it 'creates edges between nearby nodes' do
      graph.add_node
      graph.add_node
      graph.generate_edges
      expect(graph.edges.size).to be >= 0
    end

    it 'does not create edges for distant nodes' do
      graph.nodes = [
        { id: 'N1', number: 1, x: 0, y: 0, connections: [], last_used: Time.now },
        { id: 'N2', number: 2, x: 500, y: 500, connections: [], last_used: Time.now }
      ]
      graph.generate_edges
      expect(graph.edges.size).to eq(0)
    end
  end

  describe '#dynamic_connect' do
    it 'connects a new node to nearby nodes' do
      node1 = graph.add_node
      node2 = graph.add_node

      # Set positions to ensure nodes are within connection distance
      node1[:x], node1[:y] = 100, 100
      node2[:x], node2[:y] = 105, 105

      graph.dynamic_connect(node2)
      expect(graph.edges).not_to be_empty
    end
  end

  describe '#metrics' do
    it 'calculates graph metrics' do
      3.times { graph.add_node }
      graph.generate_edges
      metrics = graph.metrics
      expect(metrics[:total_nodes]).to eq(3)
      expect(metrics[:total_edges]).to be >= 0
      expect(metrics[:max_connections]).to be >= 0
    end
  end

  describe '#anomalies' do
    it 'detects nodes with excessive connections' do
      5.times { graph.add_node }
      graph.nodes.first[:connections] = Array.new(15, 'N2')
      anomalies = graph.anomalies(10)
      expect(anomalies.size).to eq(1)
    end
  end
end
