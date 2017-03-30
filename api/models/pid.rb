# Represents a running program. 'Process/process' seems to conflict, even when namespaced, so just use
# 'Pid/pid'
class Pid
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :addresses

  # The human-readable name of the program
  field :name

  # The name of the class used to store the process' memory
  field :memory_class

  # The size of a byte (both word and address size). Typically 8 bits per byte
  # 8 bits can only address 128 bytes of memory (using signed bytes)
  # A bigger word size would mean more work for a human. So let's consider increasing the address
  # size whilst keeping the word size the same.
  field :byte_size, type: Integer, default: 8

  # Ensure class is cast to a string
  def memory_class=(class_name)
    self[:memory_class] = class_name.to_s
  end

  #
  def memory
    memory_class.constantize.new id
  end
end
