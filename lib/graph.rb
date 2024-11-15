class Graph
  attr_accessor :nodes, :edges, :next_id, :capacity

  def initialize(capacity = 10)
    @nodes = []        # List of nodes
    @edges = []        # List of edges
    @next_id = 2       # Start IDs from 2
    @capacity = capacity # Maximum number of nodes allowed
  end

  # Add a node to the graph, respecting the capacity
  def add_node
    remove_least_used_node if @nodes.size >= @capacity

    id = "N#{@next_id}"
    number = @next_id
    @next_id += 1

    node = { id: id, number: number, x: rand(800), y: rand(600), connections: [], last_used: Time.now }
    @nodes << node
  end

  # Generate edges between nodes based on proximity
  def generate_edges
    @nodes.each do |source|
      @nodes.each do |target|
        next if source == target

        distance = Math.sqrt((source[:x] - target[:x])**2 + (source[:y] - target[:y])**2)
        if distance < 150 && !source[:connections].include?(target[:id])
          source[:connections] << target[:id]
          @edges << { source: source[:id], target: target[:id], distance: distance }
        end
      end
    end
  end

  # Remove the least recently used node (based on last_used)
  def remove_least_used_node
    least_used_node = @nodes.min_by { |node| node[:last_used] }
    @edges.reject! { |edge| edge[:source] == least_used_node[:id] || edge[:target] == least_used_node[:id] }
    @nodes.delete(least_used_node)
  end

  # Clear all nodes and edges from the graph
  def clear_graph
    @nodes.clear
    @edges.clear
    @next_id = 2
  end
end
