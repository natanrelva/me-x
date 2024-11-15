require 'rspec'
require_relative '../lib/log_parser'

RSpec.describe LogParser do
  let(:parser) { LogParser.new }

  describe '#parse' do
    it 'parses add_node event' do
      log = '{"event": "add_node", "id": "N5"}'
      parsed = parser.parse(log)
      expect(parsed).to eq({ type: :add_node, id: 'N5' })
    end

    it 'parses transition event' do
      log = '{"event": "transition", "source": "N2", "target": "N3"}'
      parsed = parser.parse(log)
      expect(parsed).to eq({ type: :add_edge, source: 'N2', target: 'N3' })
    end

    it 'raises an error for unknown event type' do
        log = '{"event": "unknown_event"}'
  
    # Expect the LogParser to raise a RuntimeError for unknown event types
        expect { parser.parse(log) }.to raise_error(RuntimeError, 'Unknown event type: unknown_event')
    end
  end
end
