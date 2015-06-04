require 'spec_helper'

describe Process do
  describe 'Process memory' do
    it 'should calculate the dimensions for a memory grid' do
      pid = Fabricate :pid
      expect(pid.memory.dimensions).to eq(x: 88, y: 12)
    end
  end
end
