// COMPLETE
/**
 * This module provides base functionality for IO operations. It is used to
 * output the rendered image as a file.
 */
module lib.core.file;

/// @enum Syscall numbers
enum Syscall
{
    READ = 0,
    WRITE = 1,
    OPEN = 2,
    CLOSE = 3
}

/// @enum File flags
enum FileFlags
{
    WRONLY = 0x1,
    CREAT = 0x40,
    TRUNC = 0x200
}

/// @enum File permissions
enum FilePermissions
{
    o644 = 420
}

/// @func sys_open - Opens a file
///
/// @param path - the path to the desired file
/// @param flags - the desired attributes of the file descriptor
/// @param mode - the permissions to set if the file is created
///
/// @returns - the file descriptor of the opened file, or -1 on failure
int sys_open(const char* path, int flags, int mode)
{
    int fd;
    asm
    {
        mov EAX, Syscall.OPEN;
        mov RDI, path;
        mov ESI, flags;
        mov EDX, mode;
        syscall;
        mov fd, EAX;
    }
    return fd;
}

/// @func sys_write - Writes data to an open file
///
/// @param fd - the file descriptor of the desired file
/// @param buf - a pointer to the initial byte of data to write
/// @param count - the number of bytes to write
///
/// @returns - the number of bytes written, or -1 on failure
ptrdiff_t sys_write(int fd, const void* buf, size_t count)
{
    ptrdiff_t ret;
    asm
    {
        mov EAX, Syscall.WRITE;
        mov EDI, fd;
        mov RSI, buf;
        mov RDX, count;
        syscall;
        mov ret, RAX;
    }
    return ret;
}

/// @func sys_write - Closes a file
///
/// @param fd - the file descriptor of the desired file
///
/// @returns - 0 on success, or -1 on failure
int sys_close(int fd)
{
    int ret;
    asm
    {
        mov EAX, Syscall.CLOSE;
        mov EDI, fd;
        syscall;
        mov ret, EAX;
    }
    return ret;
}
