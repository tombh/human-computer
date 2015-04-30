require 'spec_helper'

describe Assembler do
  let(:assembler) { Assembler.new }

  def assemble_subtract
    assembler.assemble do
      sub :arg1, :arg2
      mem :arg1, 1
      mem :arg2, 2
    end
  end

  it 'should reserve the first address for zero' do
    assemble_subtract
    expect(assembler.data['00000000']).to eq '00000000'
  end

  it 'should convert a DSL command to bytecode' do
    assemble_subtract
    expect(assembler.data['00000001']).to eq '00000100'
    expect(assembler.data['00000010']).to eq '00000101'
    expect(assembler.data['00000011']).to eq '00000100'
    expect(assembler.data['00000100']).to eq '00000001'
    expect(assembler.data['00000101']).to eq '00000010'
  end
end
