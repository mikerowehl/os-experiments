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

int_handler:
  // mov $0x123abc, 0x0 // this places magic value "0x123abc" at the beginning of memory
  pusha
  mov $0x00, %eax
  in $0x60, %al
  mov $kb_table, %ebx
  mov $0x00, %ah
  mov (%ebx,%eax), %dl
int_end:
  mov $0x0f, %dh
  mov %dx, 0xB8000 
  mov $0x20, %al
  out %al, $0x20
  popa
  iret

kb_table:
  .byte 0x00 // 0
  .byte 0x1b // 1
  .byte 0x31 // 2
  .byte 0x32 // 3
  .byte 0x33 // 4
  .byte 0x34 // 5
  .byte 0x35 // 6
  .byte 0x36
  .byte 0x37
  .byte 0x38
  .byte 0x39
  .byte 0x30
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31
  .byte 0x31

.p2align 4
idt:
  .skip 50*8

idtr:
  .word (50*8)-1
  .long idt

.globl do_test
do_test:
  lidt idtr
  mov $int_handler, %eax
  mov %ax, idt+33*8
  movw $0x08, idt+33*8+2 // replace 0x20 with your code section selector
  movw $0x8e00, idt+33*8+4
  shr $16, %eax
  mov %ax, idt+33*8+6
  // int $33

.set PICU1, 0x20
.set PICU2, 0xa0

setup8259:
  mov $0x11, %al
  out %al, $PICU1
  push %eax
  pop %eax
  out %al, $PICU2
  push %eax
  pop %eax
  mov $0x20, %al
  out %al,$PICU1+1
  push %eax
  pop %eax
  mov $0x28, %al
  out %al, $PICU2+1
  push %eax
  pop %eax
  mov $0x04, %al
  out %al,$PICU1+1
  push %eax
  pop %eax
  mov $0x02, %al
  out %al,$PICU2+1
  push %eax
  pop %eax
  mov $0x01, %al
  out %al,$PICU1+1
  push %eax
  pop %eax
  out %al,$PICU2+1
  push %eax
  pop %eax
  mov $0xfd, %al
  out %al,$PICU1+1
  push %eax
  pop %eax
  mov $0xff, %al
  out %al,$PICU2+1
  push %eax
  pop %eax
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
