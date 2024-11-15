require 'json'

class LogParser
  def parse(log)
    parsed = JSON.parse(log, symbolize_names: true)

    case parsed[:event]
    when 'add_node'
      { type: :add_node, id: parsed[:id] }
    when 'transition'
      { type: :add_edge, source: parsed[:source], target: parsed[:target] }
    else
      raise "Unknown event type: #{parsed[:event]}"
    end
  end
end
