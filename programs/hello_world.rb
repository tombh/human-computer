# =========================================================================
# Very simple program to move a string from one place in memory to another.
# Currently uses 155 cycles.
# =========================================================================

# Program
# -------
lbl :loop

# Outputs character pointed to by :character_address
mov :character_address.resolve, :output_address.resolve

# Move pointers one byte along
add :one, :character_address
add :one, :output_address

# Halts program if character at pointer is <= 0
jle :character_address.resolve, :end

# Repeat from the beginning
jmp :loop

# End program
lbl :end
fin

# Data storage
# ------------
hello = "hello, world\n"
# Used for incrementing
mem :one, 1
# Store the output string
mem :hello, hello
# Save the memory location of the beginning of the hello string
mem :character_address, :hello
# Save the memory location of the start of our reserved output memory
mem :output_address, :output
# Location of output, or our 'monitor'. Reserve the memory to the size of the hello world string
mem :output, ' ' * hello.length
