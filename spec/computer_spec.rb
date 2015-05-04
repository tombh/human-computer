require 'spec_helper'

describe Computer do
  let(:computer) { Computer.new }

  it 'should calculate 1+1' do
    computer.load('add')
    computer.run
    expect(computer.memory['00001110']).to eq '00000010' # 2!
  end

  it 'should output "hello, world"' do
    computer.load('hello_world')
    # Location in memory where letters are initialised
    expect(computer.memory['00101001']).to eq '01101000' # h
    expect(computer.memory['00110100']).to eq '01100100' # d
    computer.run
    # Location in memory where letters are outputted to
    expect(computer.memory['00111001']).to eq '01101000' # h
    expect(computer.memory['01000100']).to eq '01100100' # d
  end
end
