#include <stdio.h>

#include <kernel/tty.h>

unsigned char inPortB (unsigned short _port) {
    unsigned char rv;
    __asm__ __volatile__ ("inb %1, %0" : "=a" (rv) : "dN" (_port));
    return rv;
}

void kernel_main(void) {
	unsigned char keyIn;
	unsigned char charOut;

	terminal_initialize();
	printf("Hello, kernel World!\n");
	while (1) {
		keyIn = inPortB(0x60);
		charOut = (unsigned char)'a' + (keyIn - 0x1e);
		terminal_putchar(charOut);
	}
}
