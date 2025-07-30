module lib.base.file;

enum SYS_READ = 0;
enum SYS_WRITE = 1;
enum SYS_OPEN = 2;
enum SYS_CLOSE = 3;

enum O_WRONLY = 0x1;
enum O_CREAT = 0x40;
enum O_TRUNC = 0x200;

int sys_open(const char* path, int flags, int mode)
{
    int fd;
    asm
    {
        mov RAX, SYS_OPEN;
        mov RDI, path;
        mov RSI, flags;
        mov RDX, mode;
        syscall;
        mov fd, RAX;
    }
    return fd;
}

ptrdiff_t sys_write(int fd, const void* buf, size_t count)
{
    ptrdiff_t ret;
    asm
    {
        mov RAX, SYS_WRITE;
        mov RDI, fd;
        mov RSI, buf;
        mov RDX, count;
        syscall;
        mov ret, RAX;
    }
    return ret;
}

int sys_close(int fd)
{
    int ret;
    asm
    {
        mov RAX, SYS_CLOSE;
        mov RDI, fd;
        syscall;
        mov ret, RAX;
    }
    return ret;
}

// TODO: UNIT TESTS
