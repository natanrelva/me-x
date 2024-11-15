class Graph
  attr_accessor :nodes, :edges, :next_id, :capacity

  def initialize(capacity = 10)
    @nodes = []
    @edges = []
    @next_id = 2
    @capacity = capacity
  end

  def add_node
    remove_least_used_node if @nodes.size >= @capacity

    id = "N#{@next_id}"
    number = @next_id
    @next_id += 1

    node = { id: id, number: number, x: rand(800), y: rand(600), connections: [], last_used: Time.now }
    @nodes << node
    node
  end

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

  def remove_least_used_node
    least_used_node = @nodes.min_by { |node| node[:last_used] }
    @edges.reject! { |edge| edge[:source] == least_used_node[:id] || edge[:target] == least_used_node[:id] }
    @nodes.delete(least_used_node)
  end

  def dynamic_connect(node)
    @nodes.each do |target|
      next if node == target
      distance = Math.sqrt((node[:x] - target[:x])**2 + (node[:y] - target[:y])**2)
      if distance < 100
        node[:connections] << target[:id]
        @edges << { source: node[:id], target: target[:id], distance: distance }
      end
    end
  end

  def metrics
    {
      total_nodes: @nodes.size,
      total_edges: @edges.size,
      max_connections: @nodes.map { |node| node[:connections].size }.max || 0,
      avg_connections: @nodes.map { |node| node[:connections].size }.sum.to_f / (@nodes.size.nonzero? || 1)
    }
  end

  def anomalies(threshold = 10)
    @nodes.select { |node| node[:connections].size > threshold }
  end

  def cluster_nodes
    @nodes.group_by { |node| node[:number] % 5 }
  end
end
