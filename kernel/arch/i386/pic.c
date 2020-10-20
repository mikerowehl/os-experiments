#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
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

__attribute__((interrupt)) void keyboard_int_handler(struct interrupt_frame* frame)
{
	unsigned char key;
	unsigned char* screen = 0xb8000;

	key = inb(0x60);
	*screen = 0x31;
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

