{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

*******************************************************************************}

unit UntLocalFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UntTypes;

function ShellcodeStr2ByteArray(AShellcodeString : String; var AShellcode : TByteArray) : Boolean;
function RandomString(ALength : Integer) : String;

implementation

{-------------------------------------------------------------------------------
  String Shellcode to Byte Array (\x00\x01\x02)
-------------------------------------------------------------------------------}
function ShellcodeStr2ByteArray(AShellcodeString : String; var AShellcode : TByteArray) : Boolean;
var AValue : Integer;
    i      : Integer;
begin
  result := False;
  ///

  AShellcodeString := Trim(AShellcodeString);

  if odd(Length(AShellcodeString)) then
    Exit();
  ///

  try
   SetLength(AShellcode, (Length(AShellcodeString) div 4));

   FillChar(AShellcode[0], Length(AShellcode), #0);

   for i := 0 to Length(AShellcode) -1 do begin
     if (Copy(AShellcodeString, 1, 2) <> '\x') then
        raise Exception.Create('');
     ///

     Delete(AShellcodeString, 1, 2);

     if NOT TryStrToInt('$' + Copy(AShellcodeString, 1, 2), AValue) then
        raise Exception.Create('');
     ///

     Delete(AShellcodeString, 1, 2);

     AShellcode[i] := AValue;
   end;

   ///
   result := True;
  except
    SetLength(AShellcode, 0);
  end;
end;

{-------------------------------------------------------------------------------
  Generate Random String
-------------------------------------------------------------------------------}
function RandomString(ALength : Integer) : String;
const ATokenChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var   i : integer;
begin
  result := '';

  randomize();
  ///

  for i := 1 to ALength do begin
      result := result + ATokenChars[random(length(ATokenChars))+1];
  end;
end;

end.

