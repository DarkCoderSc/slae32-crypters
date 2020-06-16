{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

*******************************************************************************}

program crypter;

uses UntRC4, SysUtils, UntCRC32, UntFunctions, UntTypes, UntEOF,
     UntLocalFunctions, UntStub;

var ARC4              : TRC4;
    ASignature        : Cardinal;
    AShellcode        : TByteArray;
    APassphrase       : String;
    APassphraseLength : Cardinal = 4;
    AEOF              : TEOF;

{-------------------------------------------------------------------------------
  Entry Point
-------------------------------------------------------------------------------}
begin
  if (ParamCount <> 2) then begin
    WriteLn('Usage: ./crypter <shellcode:"\x<opcode>"> <output_file>');
  end else begin
    try
       {
          Load Shellcode
       }
       if NOT ShellcodeStr2ByteArray(ParamStr(1), AShellcode) then
          raise Exception.Create('Wrong shellcode format. Example: "\x01\x02\x03\x04..."');
       ///

       {
          Generate random RC4 passphrase
       }
       APassphrase := RandomString(APassphraseLength);
       APassphrase := CRC32h(@APassphrase[1], (Length(APassphrase) * SizeOf(Char)));

      {
        Encrypt Shellcode
      }
      ARC4 := TRC4.Create(APassphrase);
      try
        Writeln(APassphrase);
        if NOT ARC4.Encrypt(@AShellcode[0], Length(AShellcode), ASignature) then
            raise Exception.Create('Error while encrypting shellcode.');

        WriteLn('Encrypted Shellcode:');
        DumpMemory(@AShellcode[0], Length(AShellcode));
        WriteLn('---');
      finally
        FillChar(APassphrase[1], (Length(APassphrase) * SizeOf(Char)), #0);

        if Assigned(ARC4) then
           FreeAndNil(ARC4);
      end;

      {
        Extract Stub
      }
      if NOT ExtractStub(ParamStr(2)) then
         raise Exception.Create('Could not extract stub.');


      {
        Append Shellcode and Signature to Stub EOF
      }
      AEOF := TEOF.Create(ParamStr(2), TEOFMode.eofWrite);
      try
        AEOF.Add(@AShellCode[0], Length(AShellcode));

        AEOF.Add(@APassphraseLength, SizeOf(Cardinal));

        AEOF.Add(@ASignature, SizeOf(Cardinal));

        ///
        writeln(Format('Stub successfully generated, location=[%s]', [ParamStr(2)]));
      finally
        if Assigned(AEOF) then
           FreeAndNil(AEOF);
      end;
    except
      on E : Exception do
        WriteLn(stderr, E.Message);
    end;
  end;

end.
