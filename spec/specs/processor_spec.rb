require 'spec_helper'

# Test the shared Processor class
describe HumanComputer::Processor do
  let(:processor) { HumanComputer::SimulatedProcessor.new }

  it 'should calculate 1+1' do
    processor.boot('add')
    processor.run
    expect(processor.memory.read('00001110')).to eq '00000010' # 2!
  end

  it 'should output "hello, world"' do
    processor.boot('hello_world')
    # Location in memory where letters are initialised
    expect(processor.memory.read('00101001')).to eq '01101000' # h
    expect(processor.memory.read('00110100')).to eq '01100100' # d
    processor.run
    # Location in memory where letters are output to
    expect(processor.memory.read('00111001')).to eq '01101000' # h
    expect(processor.memory.read('01000100')).to eq '01100100' # d
  end
end
