require 'spec_helper'

describe Assembler do
  let(:assembler) { Assembler.new }

  def assemble_subtract
    assembler.assemble do
      # Not actually a valid program, because there is no `fin`
      sub :arg1, :arg2
      mem :arg1, 1
      mem :arg2, 2
    end
  end

  it 'should convert a binary number to its signed negative opposite' do
    negative = assembler.convert_binary_to_signed_negative '00000001'
    expect(negative).to eq '11111111'
    negative = assembler.convert_binary_to_signed_negative '00000010'
    expect(negative).to eq '11111110'
    negative = assembler.convert_binary_to_signed_negative '01111111'
    expect(negative).to eq '10000001'
  end

  it 'should reserve the first address for zero' do
    assemble_subtract
    expect(assembler.data['00000000']).to eq '00000000'
  end

  it 'should cast a string' do
    assembler.assemble { mem :string, 'abc' }
    expect(assembler.data).to eq(
      '00000000' => '00000000',
      '00000001' => '01100001', # a
      '00000010' => '01100010', # b
      '00000011' => '01100011', # c
      '00000100' => '00000000'  # zero-terminated
    )
  end

  it 'should create a label' do
    assembler.assemble do
      lbl :here
      jmp :here
    end
    expect(assembler.data).to eq(
      '00000000' => '00000000',
      # label exists here
      '00000001' => '00000000', # jmp arg1
      '00000010' => '00000000', # jmp arg2
      '00000011' => '00000001', # jmp goto
    )
  end

  it 'should create 2 labels' do
    assembler.assemble do
      lbl :here
      jmp :here
      lbl :there
      jmp :there
    end
    expect(assembler.data['00000011']).to eq '00000001'
    expect(assembler.data['00000110']).to eq '00000100'
  end

  it 'should assemble resolve-flagged symbols as indirect memory references' do
    assembler.assemble do
      jmp :here_address.resolve
      mem :here, 1
      mem :here_address, :here
    end
    expect(assembler.data).to eq(
      '00000000' => '00000000',
      '00000001' => '00000000',
      '00000010' => '00000000',
      '00000011' => '11111011', # starts with '1' so jmp to a memory pointer
      '00000100' => '00000001', # mem :here
      '00000101' => '00000100'  # mem :here_address
    )
  end

  it 'should convert a DSL command to bytecode' do
    assemble_subtract
    expect(assembler.data).to eq(
      '00000000' => '00000000',
      '00000001' => '00000100', # sub arg1 (points to address 100)
      '00000010' => '00000101', # sub arg2 (points to address 101)
      '00000011' => '00000100', # goto (forced to next instruction)
      '00000100' => '00000001', # mem :arg1
      '00000101' => '00000010'  # mem :arg2
    )
  end
end
