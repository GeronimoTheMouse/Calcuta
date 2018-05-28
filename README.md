# Calcuta Calculator

## Information

Calcuta is a simple two-number calculator, written exclusively in x86 assembly (NASM). Besides basic input/output which was carried out through the standard C library functions,
everything else is coded from scratch, including the atof function. Calcuta is meant to run in the Windows operating system, but with a few modifications
it should work in the Linux family of operating systems as well.

## Compile & Run

To compile the project under Windows, first you need to [install NASM](https://www.nasm.us "nasm homepage"). 
Then, run in your command line: `nasm -f win32 "Calcuta Calculator.asm"` to create your object file. Finally, 
link the object file with the linker of your choice. If you plan on using gcc, you can simply run the following command: `gcc "Calcuta Calculator.obj" -o calcuta`

