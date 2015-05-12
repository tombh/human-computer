[![Build Status](https://travis-ci.org/tombh/human-computer.svg)](https://travis-ci.org/tombh/human-computer)
[![Code Climate](https://codeclimate.com/github/tombh/human-computer/badges/gpa.svg)](https://codeclimate.com/github/tombh/human-computer)

# A Human Computer

This is an application to facilitate a Turing Complete human computer. The guiding principle is
that the functioning of this computer should be possible without an actual electronic computer.
For example using just pieces of card and a pencil.

A human should not have to do anything more complex than the following tasks:
* Compare 2 symbols: are they the same or different?
* Derive the opposite of a symbol.
* Fetch cards from a specific position on a large grid.
* Place cards onto a specific position on the same grid.

Therefore this application should do no more than enable these tasks in an efficient manner and
to make the tasks available to a global audience.

The computer's architecture is based on a [One Instruction Set Computer](http://en.wikipedia.org/wiki/One_instruction_set_computer) using the [SUBLEQ](https://esolangs.org/wiki/Subleq)
operation. SUBLEQ stands for Subtract and Branch if Less then or Equal to zero. All other commands
like; addition, moving bytes, etc, are built up from this single command. A slightly modified
version of SUBLEQ is used here, where negative memory addresses are understood as
indirect addresses, or pointers. This modification (and many other insights) is thanks to Lawrence
Woodman from [Tech Tinkering](http://techtinkering.com/2009/05/15/improving-the-standard-subleq-oisc-architecture/).

Currently this computer can only operate through its test suite. The road map includes an API
where you can request instructions, submit results and view snapshots of memory. Once there is an
API then we can create a web-based GUI to allow humans to easily carry out single CPU cycles.

Things to consider for development;
* Means of overcoming human errors. Require each instruction to be carried out by 2 humans?
* Improving the efficiency of the CPU. Hello World is currently 155 cycles.
* What programs can this run? Is something like Tetris possible?
* How should output be displayed? In the main memory, or through a seperate 'monitor' grid?
