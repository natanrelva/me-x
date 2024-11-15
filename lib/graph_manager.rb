require_relative './graph'
require_relative './log_parser'
require 'sqlite3'

class GraphManager
  attr_reader :graph

  def initialize(graph = Graph.new, batch_size = 10, db_path = 'graph.db')
    @graph = graph || Graph.new # Ensure graph is always initialized
    @log_parser = LogParser.new
    @log_buffer = []
    @batch_size = batch_size
    @db = SQLite3::Database.new(db_path)
    setup_database
    @metrics_history = []
  end

  def setup_database
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS nodes (
        id TEXT PRIMARY KEY,
        number INTEGER,
        x REAL,
        y REAL
      );
    SQL

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS edges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source TEXT,
        target TEXT,
        distance REAL
      );
    SQL
  end

  def process_log(log)
    @log_buffer << log
    process_batch if @log_buffer.size >= @batch_size
  end

  def process_batch
    @log_buffer.each do |log|
      begin
        event = @log_parser.parse(log)
        case event[:type]
        when :add_node
          @graph.add_node
        when :add_edge
          create_edge(event[:source], event[:target])
        else
          puts "Unhandled event type: #{event[:type]}"
        end
      rescue RuntimeError => e
        puts "Error processing log: #{e.message}"
      end
    end
    @log_buffer.clear
  end
  

  def record_metrics
    @metrics_history << { timestamp: Time.now, metrics: @graph.metrics }
  end

  def metrics_history
    @metrics_history
  end

  def save_graph
    @db.execute("DELETE FROM nodes")
    @db.execute("DELETE FROM edges")

    @graph.nodes.each do |node|
      @db.execute("INSERT INTO nodes (id, number, x, y) VALUES (?, ?, ?, ?)", [node[:id], node[:number], node[:x], node[:y]])
    end

    @graph.edges.each do |edge|
      @db.execute("INSERT INTO edges (source, target, distance) VALUES (?, ?, ?)", [edge[:source], edge[:target], edge[:distance]])
    end
  end

  def load_graph
    @graph.clear_graph

    @db.execute("SELECT * FROM nodes") do |row|
      @graph.nodes << { id: row[0], number: row[1], x: row[2], y: row[3], connections: [] }
    end

    @db.execute("SELECT * FROM edges") do |row|
      @graph.edges << { source: row[1], target: row[2], distance: row[3] }
    end
  end

  private

  def create_edge(source_id, target_id)
    source = @graph.nodes.find { |node| node[:id] == source_id }
    target = @graph.nodes.find { |node| node[:id] == target_id }

    if source && target
      distance = Math.sqrt((source[:x] - target[:x])**2 + (source[:y] - target[:y])**2)
      if distance < 150
        @graph.edges << { source: source[:id], target: target[:id], distance: distance }
      end
    else
      puts "Source or target node not found for edge: #{source_id} -> #{target_id}"
    end
  end
end
