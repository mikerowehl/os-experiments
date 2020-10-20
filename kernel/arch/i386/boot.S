# Declare constants for the multiboot header.
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a header as in the Multiboot Standard.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Reserve a stack for the initial thread.
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:
# The kernel entry point.
.section .text
.global _start
.type _start, @function
_start:
  lgdt (gdt_pointer)
  jmp $8, $set_segs
set_segs:
  mov $DATA_SEG, %eax
  mov %eax, %ds
  mov %eax, %es
  mov %eax, %fs
  mov %eax, %gs
  mov %eax, %ss

  movl $stack_top, %esp

  call do_test

  # Call the global constructors.
  call _init

  # Transfer control to the main kernel.
  call kernel_main

  # Hang if kernel_main unexpectedly returns.
  cli
1:
  hlt
  jmp 1b
.size _start, . - _start

.p2align 4
.globl idt
idt:
  .skip 50*8

idtr:
  .word (50*8)-1
  .long idt

.globl do_test
do_test:
  lidt idtr
  sti
  ret

gdt_start:
.byte 0x00, 0x00
.byte 0x00, 0x00
.byte 0x00, 0x00
.byte 0x00, 0x00
gdt_code:
.byte 0xff, 0xff
.byte 0x00, 0x00
.byte 0x00, 0b10011010
.byte 0b11001111, 0x00
gdt_data:
.byte 0xff, 0xff
.byte 0x00, 0x00
.byte 0x00, 0b10010010
.byte 0b11001111, 0x00
gdt_end:
gdt_pointer:
.word gdt_end - gdt_start
.long gdt_start

.set CODE_SEG, gdt_code - gdt_start
.set DATA_SEG, gdt_data - gdt_start
