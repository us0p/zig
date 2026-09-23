# A clone of GNU cat in zig
Learning project to practice system programing with Zig.

## Requirements
1. **Read a file**: The application must accept a file path as a 
command-line argument and output the file's contents exactly as they 
appear.
2. **Multiple files**: The application must accept multiple file paths. The
output must be the contents of the files in argument order.
3. **Standard input**: If no file is provided, `zcat` must read form 
`stdin`. It should also support iteractive input, the progarm should 
continue reading until `stdin` reacher EOF.
4. **Binary files**: The progam must treat input as raw bytes, not text. 
Don't build the application around stirngs.
5. **Large files**: The application must be able to process files larger 
than available RAM. For example, a 10GB file should be processable on a 
machine with 4GB of RAM. Don't load the entire file into memory.
6. **Missing files**: If a specified file doesn't exist, the application 
must:
    1. Report an error.
    2. Continue processing subsequent files, if possible.
    3. Exit with a non-zero status.

## Non-functional requirements
1. **Streaming**: Memory usage should remain approximately constant 
regardless of input file size.
2. **Avoid dependencies and complications**: Use only zig internals and 
don't focus on threads or async.
3. **Linux first**: Should focus on Linux to start, then expand to others.

## Open Questions
- What's the point of sentinel values? And why are they used in Array, 
Slices, and Pointers?
- Why do zig have allocators? How are they different from standard memory 
allocation like in C? How do I chose between allocators?
- Why do we have pointer to many items in zig when we already have slices? When should I use one or the other? What's the underlying difference?
- What are Zig string formatting patterns?
- How do I define interfaces in Zig?
- Why do we have to assign a buffer to a `Io.File.Reader` when while 
calling the read methods we also need to pass another buffer for them?
- How do I track the ammount of memory my program consumes during runtime?

## Follow up points
- Make program compatible with Unix and Windows OS.
