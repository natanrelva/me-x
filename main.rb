# graph_builder.rb
require 'json'
require 'erb'

class Graph
  def initialize
    @nodes = []
    @edges = []
  end

  # Adiciona um nó ao grafo com nome, descrição e comportamentos
  def add_node(name, description = "Sem descrição")
    node = { id: name, description: description, behaviors: [] }
    @nodes << node
    node
  end

  # Cria uma aresta entre dois nós
  def add_edge(node1, node2)
    @edges << { source: node1[:id], target: node2[:id] }
  end

  # Atribui um comportamento a um nó
  def add_behavior(node_name, behavior)
    node = @nodes.find { |n| n[:id] == node_name }
    if node
      node[:behaviors] << behavior
    else
      puts "Nó #{node_name} não encontrado."
    end
  end

  # Descrição de um nó
  def describe_node(node_name)
    node = @nodes.find { |n| n[:id] == node_name }
    if node
      node[:description]
    else
      "Nó #{node_name} não encontrado."
    end
  end

  # Exibe o grafo em formato JSON
  def to_json
    { nodes: @nodes, links: @edges }.to_json
  end
end

def generate_html(graph)
  html_template = <<-HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Graph Visualization</title>
    <script src="https://d3js.org/d3.v6.min.js"></script>
    <style>
      svg { width: 100%; height: 600px; border: 1px solid black; }
      .node { fill: lightblue; stroke: black; stroke-width: 1.5px; cursor: pointer; }
      .link { stroke: gray; stroke-width: 1.5px; }
    </style>
  </head>
  <body>
    <h1>Interactive Graph Visualization</h1>
    <svg id="graph"></svg>
  
    <script>
      const graphData = <%= graph.to_json %>;
  
      const width = 800;
      const height = 600;
      const svg = d3.select("#graph").attr("width", width).attr("height", height);
  
      const simulation = d3.forceSimulation(graphData.nodes)
        .force("link", d3.forceLink(graphData.links).id(d => d.id).distance(200))
        .force("charge", d3.forceManyBody().strength(-500))
        .force("center", d3.forceCenter(width / 2, height / 2));
  
      const link = svg.append("g").selectAll(".link")
        .data(graphData.links)
        .enter().append("line")
        .attr("class", "link");
  
      const node = svg.append("g").selectAll(".node")
        .data(graphData.nodes)
        .enter().append("circle")
        .attr("class", "node")
        .attr("r", 20)
        .call(d3.drag()
          .on("start", dragstart)
          .on("drag", dragged)
          .on("end", dragend));
  
      node.append("title").text(d => d.id);
  
      simulation.on("tick", function() {
        link.attr("x1", d => d.source.x).attr("y1", d => d.source.y)
            .attr("x2", d => d.target.x).attr("y2", d => d.target.y);
        node.attr("cx", d => d.x).attr("cy", d => d.y);
      });
  
      function dragstart(event, d) {
        if (!event.active) simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      }
  
      function dragged(event, d) {
        d.fx = event.x;
        d.fy = event.y;
      }
  
      function dragend(event, d) {
        if (!event.active) simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      }
    </script>
  </body>
  </html>
  HTML

  File.open("interactive_graph.html", "w") do |file|
    file.puts ERB.new(html_template).result(binding)
  end
  puts "Arquivo HTML gerado: interactive_graph.html"
end

# Instanciando o grafo
graph = Graph.new

# Loop de interação no terminal
while true
  puts "Comandos disponíveis:"
  puts "1. add_node <NodeName> <Description> - Adiciona um nó"
  puts "2. add_edge <Node1> <Node2> - Cria uma aresta entre dois nós"
  puts "3. add_behavior <NodeName> <Behavior> - Atribui um comportamento a um nó"
  puts "4. describe <NodeName> - Descreve o nó"
  puts "5. show - Exibe o grafo atual em JSON"
  puts "6. quit - Sai do programa"

  print "Digite um comando: "
  input = gets.chomp

  case input
  when /add_node (\w+) (.+)/
    node_name = $1
    description = $2
    graph.add_node(node_name, description)
    generate_html(graph)
  when /add_edge (\w+) (\w+)/
    node1 = graph.instance_variable_get(:@nodes).find { |n| n[:id] == $1 }
    node2 = graph.instance_variable_get(:@nodes).find { |n| n[:id] == $2 }
    
    if node1 && node2
      graph.add_edge(node1, node2)
      generate_html(graph)
    else
      puts "Nós não encontrados!"
    end
  when /add_behavior (\w+) (.+)/
    node_name = $1
    behavior = $2
    graph.add_behavior(node_name, behavior)
    puts "Comportamento '#{behavior}' adicionado ao nó #{node_name}."
  when /describe (\w+)/
    node_name = $1
    puts graph.describe_node(node_name)
  when "show"
    puts graph.to_json
  when "quit"
    break
  else
    puts "Comando inválido!"
  end
end
