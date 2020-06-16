# SLAE32 Assignement N°7 - Crypters

This Shellcode Crypter is using RC4 Cipher to encrypt and decrypt the payload directly in memory. 

The RC4 key is not known both by crypter and stub, it will be bruteforced at stub run time `CRC32(Random(Length=4))`. Feel free to increase the length of the random key, notice it might increase considerably the time before shellcode gets decrypted.

When payload is decrypted at runtime, the stub will create a new executable memory region and copy the decrypted shellcode to that region before execution.

It means, it doesn't requires the stack to be executable.

Payload is stored at the EOF of the generated stub. 

To compile both stub and crypter you will need Lazarus IDE to be installed on your Linux machine.

On Ubuntu / Debian you can use the following command:

local@user:$ `sudo apt install lazarus`

## Usage

local@user:$ `Crypter/dist/crypter <shellcode> <outputfile>`

### Example

local@user:$ `Crypter/dist/crypter "\x31\xc0\x50\x68\x62\x61\x73\x68\x68\x69\x6e\x2f\x2f\x68\x2f\x2f\x2f\x62\x89\xe3\x66\xb8\x2d\x63\x50\x31\xc0\x89\xe2\x50\x68\x73\x73\x77\x64\x68\x63\x2f\x70\x61\x68\x20\x2f\x65\x74\x68\x2f\x63\x61\x74\x68\x2f\x62\x69\x6e\x89\xe6\x50\x56\x52\x53\x89\xe1\x50\x89\xe2\xb0\x0b\xcd\x80" /tmp/encrypted_payload`

![Command Result](https://i.ibb.co/XjX2Wm3/Screenshot-2020-06-16-at-17-51-39.png)

local@user:$ `/tmp/encrypted_payload`

![Command Result](https://i.ibb.co/t888tNH/Screenshot-2020-06-16-at-17-52-13.png)

## Compile Instructions

### `Build.py`

**Build.py** script is designed to compile both **stub** and **crypter** but not only. 

When a new **stub** program version is generated, the script will embed the raw stub directly inside the **crypter**.

This is required since the **crypter** program is completely standalone, the **stub** is embedded inside.

local@user:$ `cd Crypter && python3 build.py`

#### Example Output

````
phrozen@ubuntu:~/SLAE32/SLAE-Exam/Level7/git/slae32-crypters$ cd Crypter && python3 build.py
[*] Compile stub project...
Hint: (11030) Start of reading config file /etc/fpc.cfg
Hint: (11031) End of reading config file /etc/fpc.cfg
Free Pascal Compiler version 3.0.4+dfsg-18ubuntu2 [2018/08/29] for i386
Copyright (c) 1993-2017 by Florian Klaempfl and others
(1002) Target OS: Linux for i386
(3104) Compiling stub.dpr
(3104) Compiling ../shared/unteof.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/unteof.pas(92,47) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
(3104) Compiling ../shared/untrc4.pas
(3104) Compiling ../shared/untcrc32.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untcrc32.pas(113,43) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untcrc32.pas(113,61) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untcrc32.pas(113,37) Warning: (4056) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,13) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,31) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,7) Warning: (4056) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,56) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,74) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untrc4.pas(244,50) Warning: (4056) Conversion between ordinals and pointers is not portable
(3104) Compiling ../shared/untfunctions.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untfunctions.pas(30,37) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untfunctions.pas(30,55) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/../shared/untfunctions.pas(30,31) Warning: (4056) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/stub.dpr(43,30) Hint: (4079) Converting the operands to "Int64" before doing the add could prevent overflow errors.
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/stub/stub.dpr(31,5) Note: (5025) Local variable "n" not used
(9015) Linking stub
/usr/bin/ld.bfd: warning: link.res contains output sections; did you forget -T?
(1008) 836 lines compiled, 0.2 sec
(1021) 4 warning(s) issued
(1022) 12 hint(s) issued
(1023) 1 note(s) issued
[+] Stub project successfully built.
[*] Patch stub file on crypter project...
[*] Finding tags locations
[+] Tags found. tag_begin=433, tag_end=6263778
[*] Generate stub array...
[*] Patch stub source file...
[+] Stub source file successfully patched.
[*] Compile crypter project...
Hint: (11030) Start of reading config file /etc/fpc.cfg
Hint: (11031) End of reading config file /etc/fpc.cfg
Free Pascal Compiler version 3.0.4+dfsg-18ubuntu2 [2018/08/29] for i386
Copyright (c) 1993-2017 by Florian Klaempfl and others
(1002) Target OS: Linux for i386
(3104) Compiling crypter.dpr
(3104) Compiling /home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas
(3104) Compiling /home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untcrc32.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untcrc32.pas(113,43) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untcrc32.pas(113,61) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untcrc32.pas(113,37) Warning: (4056) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,13) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,31) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,7) Warning: (4056) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,56) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,74) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untrc4.pas(244,50) Warning: (4056) Conversion between ordinals and pointers is not portable
(3104) Compiling /home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untfunctions.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untfunctions.pas(30,37) Hint: (4055) Conversion between ordinals and pointers is not portable
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untfunctions.pas(30,55) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/untfunctions.pas(30,31) Warning: (4056) Conversion between ordinals and pointers is not portable
(3104) Compiling /home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/unttypes.pas
(3104) Compiling /home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/unteof.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/shared/unteof.pas(92,47) Hint: (4035) Mixing signed expressions and longwords gives a 64bit result
(3104) Compiling untlocalfunctions.pas
(3104) Compiling untstub.pas
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/crypter/crypter.dpr(33,61) Hint: (5092) Variable "AShellcode" of a managed type does not seem to be initialized
/home/phrozen/SLAE32/SLAE-Exam/Level7/git/slae32-crypters/Crypter/crypter/crypter.dpr(49,75) Hint: (5058) Variable "ASignature" does not seem to be initialized
(9015) Linking crypter
/usr/bin/ld.bfd: warning: link.res contains output sections; did you forget -T?
(1008) 78238 lines compiled, 0.8 sec
(1021) 4 warning(s) issued
(1022) 13 hint(s) issued
[+] Crypter project successfully built.
[*] copy crypter to "dist" directory...
[*] doing some cleanup...
[+] Crypter successfully compiled and is ready for use!
[*] Have fun :-)
````
