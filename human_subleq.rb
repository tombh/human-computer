require 'simulated_human'

# Proof of concept for human-based SUBLEQ computer.
# The fundamental principle to follow is: it should be possible to play as a board game.
class HumanSubleq
  attr_accessor(
    :memory,
    :program_counter
  )

  def intialize
    # This would be a large board with lots of cells or a pannable google maps-style map of cells
    @memory = {
      '00000000' => '00000000'
    }

    # TODO; Load macros and program

    # Where the first instruction is located
    @program_counter = '00000001'

    @human = SimulatedHuman.new @memory, @program_counter

    # Run
    loop { @human.subleq }
  end
end
