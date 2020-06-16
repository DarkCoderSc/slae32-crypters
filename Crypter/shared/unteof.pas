{*******************************************************************************

        Jean-Pierre LESUEUR (@DarkCoderSc)
        www.phrozen.io
        SLAE32 - Assignment N°7 Crypters.
        Compiled with Lazarus.

*******************************************************************************}

unit UntEOF;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
  TEOFMode = (eofRead, eofWrite, eofBoth);
  ///

  TEOF = class
  private
    FFileName : String;
    FFile     : TFileStream;
  public
    {@C}
    constructor Create(AFileName : String; AMode : TEOFMode);
    destructor Destroy(); override;

    {@M}
    function Add(pData : Pointer; ADataSize : Cardinal) : Boolean;
    function Get(AIndex : Cardinal; var outDataSize : Cardinal) : Pointer;

    {@G}
    property FileName : String read FFileName;
  end;

implementation

{-------------------------------------------------------------------------------
    ___constructor
-------------------------------------------------------------------------------}
constructor TEOF.Create(AFileName : String; AMode : TEOFMode);
var AFileMode : Word;
begin
    FFileName := AFileName;

    FFile := nil;

    if NOT FileExists(FFileName) then
        raise Exception.Create('File not found!');

    case AMode of
        eofRead  : AFileMode := fmOpenRead;
        eofWrite : AFileMode := fmOpenWrite;
        eofBoth  : AFileMode := fmOpenReadWrite;

        else begin
          raise Exception.Create('Invalid EOF Mode!');
        end;
    end;

    ///
    FFile := TFileStream.Create(AFileName, AFileMode);
end;

{-------------------------------------------------------------------------------
    ___destructor
-------------------------------------------------------------------------------}
destructor TEOF.Destroy();
begin
    if Assigned(FFile) then
        FreeAndNil(FFile);

    ///
    inherited Destroy();
end;

{-------------------------------------------------------------------------------
    Append Data to End Of File
-------------------------------------------------------------------------------}
function TEOF.Add(pData : Pointer; ADataSize : Cardinal) : Boolean;
begin
    result := False;
    ///

    FFile.Seek(0, TSeekOrigin.soEnd); // EOF
    ///

    if (FFile.Write(PByte(PData)^, ADataSize) <> ADataSize) then
        Exit();

    if (FFile.Write(ADataSize, SizeOf(Cardinal)) <> SizeOf(Cardinal)) then
        Exit();

    ///
    result := True;
end;

{-------------------------------------------------------------------------------
    Read Data from End Of File
-------------------------------------------------------------------------------}
function TEOF.Get(AIndex : Cardinal; var outDataSize : Cardinal) : Pointer;
var ASegmentSize : Integer;
    AOffset      : Integer;

  function GetIndexOffset() : Integer;
    var I            : Integer;
        ACurOffset   : Integer;
    begin
        result := 0;
        ///

        ACurOffset := 0;
        ASegmentSize := 0;

        for I := 0 to AIndex -1 do begin
          FFile.Seek(-(ACurOffset + SizeOf(Cardinal)), TSeekOrigin.soEnd);

          if (FFile.Read(ASegmentSize, SizeOf(Cardinal)) <> SizeOf(Cardinal)) then
              break;


          ///
          Inc(ACurOffset, (ASegmentSize + SizeOf(Cardinal)));
        end;

        if (ASegmentSize > 0) then
            result := -(ACurOffset);
    end;

begin
    result := nil;
    ///

    outDataSize := 0;

    AOffset := GetIndexOffset();

    if (AOffset = 0) or (ASegmentSize = 0) then
        Exit();
    ///

    FFile.Seek(AOffset, TSeekOrigin.soEnd);

    result := GetMem(ASegmentSize);

    if (FFile.Read(PByte(result)^, ASegmentSize) <> ASegmentSize) then begin
        FreeMem(result, ASegmentSize);

        Exit();
    end;

    ///
    outDataSize := ASegmentSize;
end;

end.

