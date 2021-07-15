ATM2 keyboard microcontroller src code and etc.

Borrowed from a version made by Caro which in turn looks like disassembled from original binary image from honey soft.

Short-time objectives:

 - move completely to AT89S52 without supporting older KR1816VE31/51 chips, as well as dropping support for external ROM.
 - only 11.0592 MHz quartz support
 - add 115200 baudrate
 - use extra indirect memory of AT89S52 for larger serial buffers/stack/etc.
 - correct real-time clocks as they seem to lag because now timer is reinitialized to a constant after some timekeeping task

