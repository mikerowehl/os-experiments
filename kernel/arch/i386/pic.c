#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include "io.h"


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

// offsets are the interrupt number where each PIC will map once configured.
// On reboot the PICs are mapped to an area the processor wants to use for
// protected mode. So we shift the interrupts up higher.
void pic_initialize(int offset1, int offset2)
{
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
