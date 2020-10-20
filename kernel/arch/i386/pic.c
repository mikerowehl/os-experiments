#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <kernel/tty.h>
#include "io.h"

struct IDT_entry{
	unsigned short int offset_lowerbits;
	unsigned short int selector;
	unsigned char zero;
	unsigned char type_attr;
	unsigned short int offset_higherbits;
};

static const uint8_t PIC1 = 0x20;
static const uint8_t PIC1_CMD = PIC1 + 0;
static const uint8_t PIC1_DATA = PIC1 + 1;
static const uint8_t PIC2 = 0xa0;
static const uint8_t PIC2_CMD = PIC2 + 0;
static const uint8_t PIC2_DATA = PIC2 + 1;

static const uint8_t PIC_INIT_CMD = 0x11;
static const uint8_t PIC_MASTER = 0x04; // Tells master slave at irq2
static const uint8_t PIC_SLAVE = 0x02; // Tells slave to cascade
static const uint8_t PIC_8086 = 0x01; // 8086 PIC handling mode

extern struct IDT_entry idt[256];

struct interrupt_frame
{
	unsigned short int ip;
	unsigned short int cs;
	unsigned short int flags;
	unsigned short int sp;
	unsigned short int ss;
};

static const uint8_t key_table[128] =
{
	0x00, 0x1b, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x2d, 0x3d, 0x08, 0x09, /* 0x00 - 0x0f */
	0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6f, 0x70, 0x5b, 0x5d, 0x0d, 0x00, 0x61, 0x73, /* 0x10 - 0x0f */
	0x64, 0x66, 0x67, 0x68, 0x6a, 0x6b, 0x6c, 0x3b, 0x27, 0x60, 0x00, 0x5c, 0x7a, 0x78, 0x63, 0x76, /* 0x20 - 0x0f */
	0x62, 0x6e, 0x6d, 0x2c, 0x2e, 0x2f, 0x00, 0x2a, 0x00, 0x20, 0x00, 0x0f, 0x10, 0x11, 0x12, 0x13, /* 0x30 - 0x0f */
	0x14, 0x15, 0x16, 0x17, 0x18, 0x00, 0x00, 0x86, 0x81, 0x85, 0xad, 0x83, 0x9f, 0x84, 0xab, 0x8b, /* 0x40 - 0x0f */
	0x82, 0x8c, 0x8e, 0xff, 0x1c, 0x00, 0x00, 0x19, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x50 - 0x0f */
	0x0e, 0x0b, 0x02, 0x0c, 0x03, 0x00, 0x04, 0x06, 0x01, 0x05, 0x7f, 0xaf, 0x8d, 0x00, 0x00, 0x00, /* 0x60 - 0x0f */
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x70 - 0x0f */
};

__attribute__((interrupt)) void keyboard_int_handler(struct interrupt_frame* frame)
{
	unsigned char key;
	// unsigned char* screen = 0xb8000;

	key = inb(0x60);
	if ((key & 0x80) == 0) {
		terminal_putchar(key_table[key & 0x7f]);
	}
	outb(PIC1_CMD, 0x20);
}

void keyboard_int_setup()
{
	unsigned long keyboard_address;
	keyboard_address = (unsigned long)keyboard_int_handler;
	idt[0x21].offset_lowerbits = keyboard_address & 0xffff;
	idt[0x21].selector = 0x08;
	idt[0x21].zero = 0;
	idt[0x21].type_attr = 0x8e;
	idt[0x21].offset_higherbits = (keyboard_address & 0xffff0000) >> 16;
}

// offsets are the interrupt number where each PIC will map once configured.
// On reboot the PICs are mapped to an area the processor wants to use for
// protected mode. So we shift the interrupts up higher.
void pic_initialize(int offset1, int offset2)
{
	keyboard_int_setup();

	outb(PIC1_CMD, PIC_INIT_CMD);
	io_wait();
	outb(PIC2_CMD, PIC_INIT_CMD);
	io_wait();
	outb(PIC1_DATA, offset1);
	io_wait();
	outb(PIC2_DATA, offset2);
	io_wait();
	outb(PIC1_DATA, PIC_MASTER);
	io_wait();
	outb(PIC2_DATA, PIC_SLAVE);
	io_wait();
	outb(PIC1_DATA, PIC_8086);
	io_wait();
	outb(PIC2_DATA, PIC_8086);
	// Now setup the initial interrupt masks explicitly, keyboard only
	outb(PIC1_DATA, 0xfd);
	io_wait();
	outb(PIC2_DATA, 0xff);
	io_wait();
}

