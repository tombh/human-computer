require 'spec_helper'

describe Computer do
  let(:computer) { Computer.new }

  it 'should calculate 1+1' do
    computer.load('add')
    computer.run
    expect(computer.memory['00001110']).to eq '00000010'
  end
end
