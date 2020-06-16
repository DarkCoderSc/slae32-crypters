{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

        Description: RC4 Cipher Delphi Implementation.

                     Supports signature checking (Encrypt / Decrypt).

                     If you don't want to use signature, just use RC4() for both
                     encryption & decryption.

                     Doesn't leave key in memory on Free().

        Ref: https://en.wikipedia.org/wiki/RC4

*******************************************************************************}

unit UntRC4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UntCRC32;

type
  TReason = (
                    rUnknown,
                    rSuccess,
                    rCipherError,
                    rWrongPassphrase
  );

  T256    = array[0..256-1] of byte;
  TKey    = array of byte;
  PKey    = ^TKey;

  TRC4 = class
  private
    FPassphrase : String;
    FKeyPtr     : PKey;
    FArrS       : T256;
    FKeySize    : Integer;
    FPRGA_i     : Integer;
    FPRGA_j     : Integer;

    {@M}
    procedure KSA();
    function PRGA() : Byte;
    procedure InitializeRC4();

    procedure InitializeKey();
    procedure FreeKey();

    function GetKeySize() : Byte;
  public
    {@C}
    constructor Create(APassphrase : String);
    destructor Destroy(); override;

    {@M}
    function RC4(pBuffer : Pointer; ABufferSize : Cardinal) : Boolean;
    function Encrypt(pBuffer : Pointer; ABufferSize : Cardinal; var ASignature : Cardinal) : Boolean;
    function Decrypt(pBuffer : Pointer; ABufferSize : Cardinal; ASignature : Cardinal) : TReason;

    procedure UpdatePassphrase(APassphrase : String);

    {@G}
    property KeySize : Byte read GetKeySize;
  end;

implementation

{-------------------------------------------------------------------------------
  ___constructor
-------------------------------------------------------------------------------}
constructor TRC4.Create(APassphrase : String);
begin
  if (Length(Trim(APassphrase)) = 0) then
     Exit();
  ///

  if Length(APassphrase) > 256 then
    FPassphrase := Copy(APassphrase, 0, 256) // We are limited to 2048 bits
  else
    FPassphrase := APassphrase;

  ///
  InitializeKey();
end;

{-------------------------------------------------------------------------------
  ___destructor
-------------------------------------------------------------------------------}
destructor TRC4.Destroy();
begin
  FreeKey();

  FillChar(FArrS, Length(FArrS), #0);

  ///
  inherited Destroy();
end;

{-------------------------------------------------------------------------------
 Finalize / Free Key
-------------------------------------------------------------------------------}
procedure TRC4.FreeKey();
begin
  if (Assigned(FKeyPtr)) and (FKeySize > 0) then begin
    FillChar(FKeyPtr, FKeySize, #0); // Securely erase key from memory.

    FreeMem(FKeyPtr, FKeySize); // Memory region is available.

    ///
    FKeyPtr  := nil;
    FKeySize := 0;
  end;
end;

{-------------------------------------------------------------------------------
 Initialize Key
-------------------------------------------------------------------------------}
procedure TRC4.InitializeKey();
var i : Integer;
begin
  self.FreeKey();
  ///

  FKeySize := (Length(FPassphrase) * SizeOf(Byte));

  FKeyPtr := GetMemory(FKeySize);

  for i := 0 to FKeySize -1 do begin
      TKey(FKeyPtr)[i] := ord(FPassphrase[i + 1]);
  end;

  ///
  FillByte(FPassphrase[1], (Length(FPassphrase) * SizeOf(Char)), 0); // Secure
end;

{-------------------------------------------------------------------------------
 Requires to key to be initialized
-------------------------------------------------------------------------------}
procedure TRC4.UpdatePassphrase(APassphrase : String);
begin
  FPassphrase := APassphrase;

  self.InitializeKey();
end;

{-------------------------------------------------------------------------------
 Initialize RC4 Array (S)
-------------------------------------------------------------------------------}
procedure TRC4.InitializeRC4();
var i : Integer;
begin
  FillChar(FArrS, Length(FArrS), #0);
  ///

  for i := 0 to length(FArrS) -1 do begin
     FArrS[i] := i;
  end;
end;

{-------------------------------------------------------------------------------
  Initialize Key (KSA)
-------------------------------------------------------------------------------}
procedure TRC4.KSA();
var i, j  : Integer;
    AByte : Byte;
begin
  j := 0;
  for i := 0 to length(FArrS) -1 do begin
     j := (j + FArrS[i] + TKey(FKeyPtr)[i mod FKeySize]) mod 256;

     AByte    := FArrS[i];
     FArrS[i] := FArrS[j];
     FArrS[j] := AByte;
  end;
end;

{-------------------------------------------------------------------------------
  Pseudo Random Generation Algotithm (PRGA)
-------------------------------------------------------------------------------}
function TRC4.PRGA() : Byte;
var AByte : Byte;
begin
  result := 0;
  ///

  FPRGA_i := (FPRGA_i + 1) mod 256;
  FPRGA_j := (FPRGA_j + FArrS[FPRGA_i]) mod 256;

  AByte          := FArrS[FPRGA_i];
  FArrS[FPRGA_i] := FArrS[FPRGA_j];
  FArrS[FPRGA_j] := AByte;

  ///
  result := FArrS[(FArrS[FPRGA_i] + FArrS[FPRGA_j]) mod 256];
end;

{-------------------------------------------------------------------------------
  Encrypt's / Decrypt memory region.
-------------------------------------------------------------------------------}
function TRC4.RC4(pBuffer : Pointer; ABufferSize : Cardinal) : Boolean;
var APRGA : Byte;
    i     : Integer;
begin
  result := False;
  ///

  if NOT Assigned(pBuffer) then
    Exit();

  if (ABufferSize = 0) then
    Exit();

  if (NOT Assigned(FKeyPtr)) or (FKeySize = 0) then
    Exit();
  ///

  FPRGA_i := 0;
  FPRGA_j := 0;

  {
    Prepare RC4 Cipher
  }
  InitializeRC4();

  self.KSA();

  {
    Encrypt / Decrypt Routine
  }
  for i := 0 to ABufferSize -1 do begin
      APRGA := self.PRGA();
      ///

      PByte(Cardinal(pBuffer) + i)^ := APRGA xor PByte(Cardinal(pBuffer) + i)^;
  end;

  ///
  result := True;
end;

{-------------------------------------------------------------------------------
  Encrypt / Decrypt (Support Signature - CRC32)
-------------------------------------------------------------------------------}

function TRC4.Encrypt(pBuffer : Pointer; ABufferSize : Cardinal; var ASignature : Cardinal) : Boolean;
begin
  result := False;
  ///

  ASignature := 0;

  ASignature := CRC32(pBuffer, ABufferSize);

  result := self.RC4(pBuffer, ABufferSize);
end;

function TRC4.Decrypt(pBuffer : Pointer; ABufferSize : Cardinal; ASignature : Cardinal) : TReason;
var b : Boolean;
begin
  result := rUnknown;
  ///

  b := self.RC4(pBuffer, ABufferSize);

  if b then begin
    if (CRC32(pBuffer, ABufferSize) = ASignature) then
      result := rSuccess
    else
      result := rWrongPassphrase;
  end else
    result := rCipherError;
end;

{-------------------------------------------------------------------------------
  Getters / Setters
-------------------------------------------------------------------------------}

function TRC4.GetKeySize() : Byte;
begin
  result := (FKeySize * 8);
end;

end.

