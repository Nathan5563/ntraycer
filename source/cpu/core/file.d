// COMPLETE
/**
 * This module provides base functionality for IO operations. It is used to
 * output the rendered image as a file.
 *
 * Cross-platform support:
 * - Linux: Uses direct x86-64 syscalls for file I/O
 * - Windows: Uses kernel32.dll API functions via dynamic linking
 */
module cpu.core.file;

version (linux)
{
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

    /// @func sys_close - Closes a file
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
}
else version (Windows)
{
    /// Windows API types
    private alias HANDLE = void*;
    private alias DWORD = uint;
    private alias BOOL = int;
    private alias LPCSTR = const(char)*;
    private alias LPCVOID = const(void)*;
    private alias LPDWORD = DWORD*;

    /// Windows constants
    private enum HANDLE INVALID_HANDLE_VALUE = cast(HANDLE) -1;
    private enum DWORD GENERIC_WRITE = 0x40000000;
    private enum DWORD CREATE_ALWAYS = 2;
    private enum DWORD FILE_ATTRIBUTE_NORMAL = 0x80;

    /// Windows API function bindings (kernel32.dll)
    private extern (Windows) @nogc nothrow
    {
        HANDLE CreateFileA(
            LPCSTR lpFileName,
            DWORD dwDesiredAccess,
            DWORD dwShareMode,
            void* lpSecurityAttributes,
            DWORD dwCreationDisposition,
            DWORD dwFlagsAndAttributes,
            HANDLE hTemplateFile
        );

        BOOL WriteFile(
            HANDLE hFile,
            LPCVOID lpBuffer,
            DWORD nNumberOfBytesToWrite,
            LPDWORD lpNumberOfBytesWritten,
            void* lpOverlapped
        );

        BOOL CloseHandle(HANDLE hObject);
    }

    /// @enum File flags (Windows - provided for API compatibility)
    enum FileFlags
    {
        WRONLY = 0x1,
        CREAT = 0x40,
        TRUNC = 0x200
    }

    /// @enum File permissions (Windows - provided for API compatibility, not used)
    enum FilePermissions
    {
        o644 = 420
    }

    /// Internal storage to map integer "file descriptors" to Windows HANDLEs
    private __gshared HANDLE[256] handleTable;
    private __gshared int nextFd = 3; // Start after stdin, stdout, stderr

    /// @func sys_open - Opens a file (Windows implementation)
    ///
    /// @param path - the path to the desired file
    /// @param flags - the desired attributes (compatibility, uses Windows semantics)
    /// @param mode - the permissions (ignored on Windows)
    ///
    /// @returns - a file descriptor (index into handle table), or -1 on failure
    int sys_open(const char* path, int flags, int mode)
    {
        HANDLE hFile = CreateFileA(
            path,
            GENERIC_WRITE,
            0,                          // No sharing
            null,                       // Default security
            CREATE_ALWAYS,              // Create new or overwrite existing
            FILE_ATTRIBUTE_NORMAL,      // Normal file
            null                        // No template
        );

        if (hFile == INVALID_HANDLE_VALUE)
        {
            return -1;
        }

        // Store handle and return pseudo file descriptor
        int fd = nextFd++;
        if (fd >= 256)
        {
            CloseHandle(hFile);
            return -1;
        }
        handleTable[fd] = hFile;
        return fd;
    }

    /// @func sys_write - Writes data to an open file (Windows implementation)
    ///
    /// @param fd - the file descriptor of the desired file
    /// @param buf - a pointer to the initial byte of data to write
    /// @param count - the number of bytes to write
    ///
    /// @returns - the number of bytes written, or -1 on failure
    ptrdiff_t sys_write(int fd, const void* buf, size_t count)
    {
        if (fd < 0 || fd >= 256 || handleTable[fd] is null)
        {
            return -1;
        }

        DWORD bytesWritten = 0;
        BOOL success = WriteFile(
            handleTable[fd],
            buf,
            cast(DWORD) count,
            &bytesWritten,
            null
        );

        if (!success)
        {
            return -1;
        }
        return cast(ptrdiff_t) bytesWritten;
    }

    /// @func sys_close - Closes a file (Windows implementation)
    ///
    /// @param fd - the file descriptor of the desired file
    ///
    /// @returns - 0 on success, or -1 on failure
    int sys_close(int fd)
    {
        if (fd < 0 || fd >= 256 || handleTable[fd] is null)
        {
            return -1;
        }

        BOOL success = CloseHandle(handleTable[fd]);
        handleTable[fd] = null;

        return success ? 0 : -1;
    }
}
else
{
    static assert(false, "Unsupported platform: only Linux and Windows are supported");
}
