# os-experiments

Just some hacking around I'm doing with low level PC dev. This is really the
[Meaty Skeleton](https://wiki.osdev.org/Meaty_Skeleton) sample from the OSDev
wiki. I've just been jamming some tests and experiments into it while trying
to understand how things work. I put it into a repo just to try to keep track
of it. I recommend going back to the OSDev wiki instead of trying to work off
anything in this repo.

## Building

I've been building with a containerized cross-compile toolchain I have
published as [ktool](https://github.com/mikerowehl/ktool):

    ktool ./clean.sh
    ktool ./build.sh
    ktool ./iso.sh
    qemu-system-i386 -cdrom ./myos.iso
