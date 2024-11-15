require 'erb'
require 'json'
require 'webrick'

# Função para verificar se um número é primo de forma otimizada
def primo?(n)
  return false if n <= 1
  return true if n == 2
  return false if n.even?
  (3..Math.sqrt(n).to_i).step(2).none? { |i| n % i == 0 }
end

# Função para calcular distância Euclidiana entre dois pontos
def distancia(x1, y1, x2, y2)
  Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
end

class Grafo
  attr_accessor :nodes, :links, :next_id

  def initialize
    @nodes = []
    @links = []
    @next_id = 2 # Começamos a partir de 2, pois 1 não é primo
  end

  # Adiciona um nó ao grafo com um número primo associado
  def adicionar_no
    id = "N#{@next_id}"
    num = @next_id
    @next_id += 1
    @nodes << { id: id, num: num, x: rand(800), y: rand(600), connections: [] }
  end

  # Gerador de função matemática para criar arestas entre nós, baseado na proximidade
  def gerar_arestas
    @nodes.each do |source|
      @nodes.each do |target|
        next if source == target

        # Usar a distância Euclidiana para conectar nós próximos
        dist = distancia(source[:x], source[:y], target[:x], target[:y])
        if dist < 150 && !source[:connections].include?(target[:id])
          source[:connections] << target[:id]
          @links << { source: source[:id], target: target[:id], dist: dist }
        end
      end
    end
  end

  # Método de meta-programação para conectar os nós dinamicamente com base em seu comportamento
  def conectar_comportamento
    @nodes.each do |node|
      define_singleton_method(:conectar_vizinhos) do
        gerar_arestas
      end
      node[:connections] = []
    end
  end

  # Método para gerar o HTML e simular o fluxo contínuo
  def gerar_html
    template = erb_template
    server = iniciar_servidor

    # Iniciar servidor e enviar conteúdo de forma incremental
    server.mount_proc '/' do |req, res|
      res['Content-Type'] = 'text/html'
      res.body = template
    end

    trap('INT') { server.shutdown }
    server.start
  end

  private

  # ERB Template que define o HTML do grafo
  def erb_template
    <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Visualização de Grafo com Conexões Dinâmicas</title>
      <script src="https://d3js.org/d3.v7.min.js"></script>
      <style>
        svg { width: 100%; height: 600px; }
        .node { fill: lightblue; stroke: black; stroke-width: 1.5px; }
        .link { stroke: #999; stroke-width: 2px; opacity: 0.6; }
        text { font-family: Arial, sans-serif; font-size: 12px; }
      </style>
    </head>
    <body>
      <h1>Visualização de Grafo com Conexões Dinâmicas</h1>
      <svg id="graph"></svg>
      <script>
        let nodes = [];
        let links = [];

        const width = 800;
        const height = 600;

        const svg = d3.select("#graph").attr("width", width).attr("height", height);

        const simulation = d3.forceSimulation(nodes)
          .force("link", d3.forceLink(links).id(d => d.id).distance(150))
          .force("charge", d3.forceManyBody().strength(-100))
          .force("center", d3.forceCenter(width / 2, height / 2));

        function updateGraph() {
          // Atualizar links
          const link = svg.selectAll(".link")
            .data(links)
            .join("line")
            .attr("class", "link");

          // Atualizar nós
          const node = svg.selectAll(".node")
            .data(nodes)
            .join("circle")
            .attr("class", "node")
            .attr("r", 20)
            .call(d3.drag()
              .on("start", dragstart)
              .on("drag", dragged)
              .on("end", dragend));

          // Atualizar títulos dos nós
          node.append("title").text(d => d.id);

          // Adicionar textos com IDs dos nós
          svg.selectAll("text")
            .data(nodes)
            .join("text")
            .attr("x", d => d.x)
            .attr("y", d => d.y)
            .attr("dy", -25)
            .attr("text-anchor", "middle")
            .text(d => d.id);

          simulation.nodes(nodes);
          simulation.force("link").links(links);
          simulation.alpha(1).restart();
        }

        function adicionarNoEAtualizar() {
          let novoNo = { id: "N" + (nodes.length + 1), x: Math.random() * width, y: Math.random() * height };
          nodes.push(novoNo);

          // Gerar novas arestas com base na proximidade
          links = [];
          nodes.forEach((source, i) => {
            nodes.slice(i + 1).forEach(target => {
              const dist = Math.sqrt(Math.pow(target.x - source.x, 2) + Math.pow(target.y - source.y, 2));
              if (dist < 150) {
                links.push({ source: source, target: target });
              }
            });
          });

          updateGraph();
        }

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

        setInterval(adicionarNoEAtualizar, 2000);

        simulation.on("tick", () => {
          svg.selectAll(".link")
            .attr("x1", d => d.source.x)
            .attr("y1", d => d.source.y)
            .attr("x2", d => d.target.x)
            .attr("y2", d => d.target.y);

          svg.selectAll(".node")
            .attr("cx", d => d.x)
            .attr("cy", d => d.y);
          
          svg.selectAll("text")
            .attr("x", d => d.x)
            .attr("y", d => d.y);
        });
      </script>
    </body>
    </html>
    HTML
  end

  # Inicializar o servidor WEBrick
  def iniciar_servidor
    WEBrick::HTTPServer.new(:Port => 8000)
  end
end

# Criando o grafo
grafo = Grafo.new
grafo.adicionar_no
grafo.adicionar_no
grafo.adicionar_no

# Gerando as arestas com base na proximidade dos nós
grafo.gerar_arestas

# Gerando o HTML em fluxo e iniciando o servidor
grafo.gerar_html
puts "Servidor iniciado em http://localhost:8000. Acesse no navegador."
