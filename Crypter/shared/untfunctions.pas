{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

*******************************************************************************}

unit UntFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure DumpMemory(pBuffer : Pointer; ABufferSize : Cardinal);

implementation

{-------------------------------------------------------------------------------
      Dump Memory Byte by Byte
-------------------------------------------------------------------------------}
procedure DumpMemory(pBuffer : Pointer; ABufferSize : Cardinal);
var i : Integer;
begin
  for i := 0 to ABufferSize -1 do begin
    Write(Format('0x%.2x, ', [PByte(Cardinal(pBuffer) + i)^]));

  end;
  WriteLn('');
end;

end.

