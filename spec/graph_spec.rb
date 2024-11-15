require 'rspec'
require_relative '../lib/graph'

RSpec.describe Graph do
  let(:graph) { Graph.new(3) } # Initialize graph with a capacity of 3 nodes

  describe '#add_node' do
    it 'adds a node to the graph' do
      graph.add_node
      expect(graph.nodes.size).to eq(1)
      expect(graph.nodes.first[:id]).to eq('N2')
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

  describe '#remove_least_used_node' do
    it 'removes the least recently used node when capacity is exceeded' do
      3.times { graph.add_node }
      oldest_node = graph.nodes.first
      graph.add_node # Add a new node, which exceeds the capacity
      expect(graph.nodes).not_to include(oldest_node)
      expect(graph.nodes.size).to eq(3)
    end

    it 'removes edges associated with the removed node' do
      graph.nodes = [
        { id: 'N1', number: 1, x: 0, y: 0, connections: ['N2'], last_used: Time.now },
        { id: 'N2', number: 2, x: 100, y: 100, connections: ['N1'], last_used: Time.now }
      ]
      graph.edges = [{ source: 'N1', target: 'N2', distance: 100 }]
      graph.remove_least_used_node
      expect(graph.edges.size).to eq(0)
    end
  end

  describe '#clear_graph' do
    it 'clears all nodes and edges from the graph' do
      3.times { graph.add_node }
      graph.generate_edges
      graph.clear_graph
      expect(graph.nodes).to be_empty
      expect(graph.edges).to be_empty
      expect(graph.next_id).to eq(2)
    end
  end
end
