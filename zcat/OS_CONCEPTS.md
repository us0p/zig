## OS concepts
This file contain all the OS concepts that `zcat` use or interact with 
during execution.

## Processes
- Running instance of a program. The program is a static file. A process is
the program loaded into memory and given resources by the OS.
- Every process gets from the kernel:
    - An unique PID.
    - Virtual address space (code, data, heap, stack) isolated from other 
    processes.
    - CPU state: registers, program counter, stack pointer.
    - A table of open file descriptors (stdin/out/err at minimum)
    - Environment variables, current working directory, user/group 
    ownership.
- Processes are created by duplicating an existing process in Unix-like 
systems. Both processes run the same code with separate memory.
- PID 1 `init/systemd` is the parent of all processes.
- The parent's PID is PPID.
- A child almost always immediatelly calls `exec()` to replace its memory 
with a different program (you fork the original process and then execute a 
different program with it). This is what bash does everytime we run a 
command, it forks itself and tem uses `exec()` to replace the memory with 
another program, e.g.: `/bin/ls`.
- An **orphan** is a child process without a parent. This happens whent he 
parent dies before its child. The child then gets *reparented* to PID 1 so 
it isn't parentless.
- A **zombie** is a child process that exited but its exit status was never
collected by the parent. It'll show as a `defunct` process in `ps` command 
and will linger around until the parent collects it, or the parent itself 
exits, at which point the init reaps it.
- Process exit status is a 1 byte integer and it's used to tell the parent 
if the child process succeeded or not.
- All non-zero exit status are considered failures (this is not OS 
standard, just an universal practice). The specific non-zero value often 
signals what when wrong. Similar to HTTP status codes.
- The parent can know about the child exit code with `wait()/waitpid()` and
in doing so, it prevents a **zombie** process.

## File Descriptors
- It's a non-negative number(index) that's used by a process to access 
input/output resources (files).
- When a process opens a new resource, the kernel assigns the lowest 
unused integer, starting at 3.
- Each process has its own FD table. The File Descriptor number is 
simply the array index of this table. Each entry points to a slot in 
the global system file table which tracks current metadata for every 
open session like cursor position and access mode.
- When a process is forked the child proces inherits an exact copy of 
the parent's file descriptor table. Since they point to the exact same 
entries in the global file table, parent and child share the same file 
offset.

### Operations
Programs interact with file descriptors using low-level system calls:  
- **open/create**: Opens/create a file resource and returns a new file 
descriptor integer. Separate calls create different FDs since we 
have multiple references to the same file, each one has its own 
file offset which is tracked by the global system file table.
- **read**: Pulls data from a given file descriptor using its file 
offset which determines "where" into the file we're currently 
reading and stores it into a buffer.
- **write**: Also uses a file offset to write data from a memory buffer
into a file descriptor at the respective file offset.
- **close**: Closes the handle and frees up the integer for future use.

## Standard Streams
- A stream is an abstraction for a sequential, ordered flow of bytes 
between a source and a destination. The consumer doesn't know what's on the
other end. The interface is the same for both ends. You read bytes from it 
or write bytes to it. With that we have 
**uniform I/O regardless of context**, allowing programs to be simpler 
withouth having to provide specific implementations for what's on the other
side.
- In unix, everything is a file, every I/O source/sink is exposed through 
the same interface, identified by a file descriptor (which in this case is 
not an actual file on disk). You can confirm with `ls -la /proc/$$/fd/`.
- `stdin`, `stdout` and `stderr` are the three default data streams of 
the process that act as communication channels between the program and the 
environment. They're not special on the OS level, the OS sees then as just 
file descriptors opened before every process execution.
- These streams are started automatically by the OS Process.
- Each stream has its own file descriptor:
    - `stdin`: 0
    - `stdout`: 1
    - `stderr`: 2
- We use the pipe to redirect the contents of one stream into the other. 
To do that, the shell's pipe duplicates input from fd1 and output from fd0 
to the respective process withouth them knowing they're not talking to a 
terminal (they rely on the same interface).
- `stdout` and `stderr` are split so that they can be treated separately.
- It's POSIX convention that a well behaved program always open fd 0, 1 and
2 **before** doing anything else. Withouth this, a file opened by a program
will get the lowest free descriptor, probably getting one of the stream's 
descriptor. Another program trying to use that would corrupt the file.

## Buffered I/O
- Instead of reading/writing many times from a file in disk, we use a 
transient buffer that will batch the operations to a certain threshold and 
then flush all of them at once. By doing that we avoid performing 
repetivive **syscalls**.
- syscalls are expense because they need to switch from user mode to kernel
mode. The kernel has several validation that it needs to perform before 
switching back. Usually disk operations are orders of magnitude slower than
memory which also impacts performance if you're frequently interacting with
it.
- A syscall moving 1 byte costs almost the same as one moving `8KB`. Data 
copying is not the bottleneck. By trading memory for fewer, larger syscalls
we can increase the throughput for many-small-operations workloads.
- Instead of writing one at the time, we use the buffer to accumulate data 
and once it's full, we flush it.
- Note that this applies both to reads and writes, instead of reading 1 
byte at the time, we request one large chunk from disk and then we take 
bytes from that chunk.
- Buffering is not applied only in user's space, but also in the kernel's 
**page cache**. This is a kernel level buffer that receives the data your 
application flushes and returns immediately. The actual disk write happens 
later unless your force it by synching.
- Flushing your application buffer doesn't guarantee durability (disk 
persistence). For that, you need to flush **and** to sync.
- By Unix standard, buffering mode varies according to the stream:
    - **Unbuffered**: when writting to `stderr`. Every write is a immediate
    syscall. We want errors visible as soon as possible.
    - **Linbe-buffered**: when writting to stdout from a terminal. Every 
    new line (`\n`) flushes the input.
    - **Fully buffered**: when redirecting stdout to a file/pipe. Flush 
    happends only when buffer fills. Maximum thoughput since there's no 
    human interaction.

## End Of File (EOF)
- Special signal telling a program that no more data is left to read.
- It's a negative integer value returned by system functions when a 
read operation hits the end of a stream or file.
- It's a control code, not an actual printable text character.

## File Offsets
- Created by the kernel once a file is opened and named as 
**open file description**, it contains a single integer which is the 
**file offset**, which indicates the **byte position** where the next 
read/write will start.
- The offset doesn't live in your process file descriptor table. It lives 
in the **open file description**, a separate, system-wide kernel structure.
- proces fd table -> open file dedscription table -> filesystem.
- Each read/write transfer bytes starting from the offset, and advances the
offset by the number of bytes transferred.
- Seeking is the process of changing the offset directly, without 
transferring data.
- This abstraction exists so that sequential access can be stateless so 
that you don't need to keep passing a position argument everytime you 
read/write.
- For concurrent program execution writing to the same shared offset you 
might want to combine seeking with read/write operations to leave the 
shared offset untouched.
- Pipes and sockets aren't seekable because data is a transient stream, not
an addressable, persistent array of bytes.
