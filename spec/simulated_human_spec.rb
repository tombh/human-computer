require 'spec_helper'

describe SimulatedHuman do
  let(:computer) { HumanComputer.new }
  let(:human) { SimulatedHuman.new(computer) }
  let(:assembler) { Assembler.new }

  # Convert a binary array into an addressable memory hash
  def make_memory_addressable(program)
    assembler.data = program
    assembler.make_memory_addressable
    assembler.data
  end

  it 'should flip a byte' do
    expect(human.flip '00000000').to eq '11111111'
    expect(human.flip '11111111').to eq '00000000'
    expect(human.flip '11001110').to eq '00110001'
  end

  it 'should add 2 bits with carry' do
    table = [
      %w(0 0 0  0 0),
      %w(1 0 0  1 0),
      %w(0 1 0  1 0),
      %w(1 1 0  0 1),
      %w(0 0 1  1 0),
      %w(1 0 1  0 1),
      %w(0 1 1  0 1),
      %w(1 1 1  1 1)
    ]

    table.each do |row|
      sum, carry = human.full_adder row[0], row[1], row[2]
      expectation = [row[0], row[1], row[2], sum, carry]
      expect(expectation).to eq row
    end
  end

  it 'should add 2 unsigned bytes using the boolean adder' do
    examples = [
      %w(00000000 00000000 00000000 0),
      %w(00000001 00000001 00000010 0),
      %w(00001111 00010011 00100010 0),
      %w(01001111 01010011 10100010 0),
      %w(11111101 00000001 11111110 0),
      %w(11111111 11111111 11111110 1)
    ]

    examples.each do |row|
      sum, carry = human.add row[0], row[1]
      expectation = [row[0], row[1], sum, carry]
      expect(expectation).to eq row
    end
  end

  it 'should subtract 2 signed bytes' do
    examples = [
      %w(00000000 00000000 00000000 0),
      %w(00000010 00000010 00000000 1),
      %w(11111101 00101010 11010011 1),
      %w(00000000 00101010 11010110 0)
    ]

    examples.each do |row|
      result, carry = human.subtract row[0], row[1]
      expectation = [row[0], row[1], result, carry]
      expect(expectation).to eq row
    end
  end

  it 'should carry out the SUBLEQ without a branch' do
    # 2 - 1 = 1 so just goto next instruction
    ram = [
      # program
      '00000000', # Always 0
      '00000100', # location 4
      '00000101', # location 5
      '11111111', # goto (which should be ignored)
      # data
      '00000001', # 1
      '00000010'  # 2
    ]
    computer.memory = make_memory_addressable ram

    human.subleq
    expect(computer.memory['00000101']).to eq '00000001'
    # Result is not negative so program_counter should just be incremented by 3
    expect(computer.program_counter).to eq '00000100'
  end

  it 'should carry out the SUBLEQ with a branch' do
    # 1 - 4 = -3 so branch to 11111111
    ram = [
      # program
      '00000000', # Always 0
      '00000100', # location 4
      '00000101', # location 5
      '11111111', # goto
      # data
      '00000100', # 4
      '00000001'  # 1
    ]
    computer.memory = make_memory_addressable ram

    human.subleq
    expect(computer.memory['00000101']).to eq '11111101' # -3
    # Result is negative so program_counter should point to the 'goto' argument
    expect(computer.program_counter).to eq '11111111'
  end
end
