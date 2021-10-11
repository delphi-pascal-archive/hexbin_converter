unit HexFile;

interface
uses    BufferedFile;

TYPE

  HexRecord = Record
        RecLen  : BYTE;
        Offset  : WORD;
        RecTyp  : BYTE;
        Data    : Array[0..255] of Byte;
        CheckSum: BYTE;
  end;

  RecLBA = Record
    case integer of
        0:( LBA       : Cardinal );
        1:( LLBA,ULBA : WORD );
  end;

  THexFile = Object(TBufferedFile)
        LBA     : RecLBA;
        EIP     : Cardinal;
        Err     : Boolean;
        ErrSum  : Integer;
        CurChar : char;
        Rec     : HexRecord;
        procedure init;
        function ReadChar:Char;
        procedure ReadLine;
        procedure WriteLine;
        procedure WriteULBA;
        procedure WriteEND;
  end;

implementation

function CalcSum(b:pointer;Len:Integer):Integer;
 Var    p   : Pchar;
        i   : Integer;
        Sum : Integer;
begin
 p:=pchar(b);
 Sum:=0;
 for i:=0 to (len-1) do
    Sum:=Sum+ ord( p[i] );
 CalcSum:=Sum;
end;

{###########################################################################}
function Hex2Long(C:Char):Byte;
Begin
 Case C of
     '0'..'9': Result:= ord(C) - Ord('0');
     'a'..'f': Result:= ord(C) - Ord('a') +10;
     'A'..'F': Result:= ord(C) - Ord('A') +10;
 End;
End;

{###########################################################################}
Const HexChars:Array[0..15]OF char='0123456789ABCDEF';

FUNCTION Hex8(n:byte):ShortString;
Begin
  Hex8[0]:=Char(2);
  Hex8[1]:=HexChars[n shr 4];
  Hex8[2]:=HexChars[n and $F];
End;

FUNCTION Hex16(n:Word):ShortString;
Begin
  Hex16[0]:= Char(4);
  Hex16[1]:= HexChars[(N shr 12)       ];
  Hex16[2]:= HexChars[(N shr  8) and $F];
  Hex16[3]:= HexChars[(N shr  4) and $F];
  Hex16[4]:= HexChars[(N       ) and $F];
End;


{###########################################################################}
{###########################################################################}

procedure THexFile.init;
begin
 inherited init;
 LBA.LBA:=0;
 Err:=False;
 ErrSum:=0;
 CurChar:=#26;
 FillChar(Rec, Sizeof(Rec), 0);
end;

function THexFile.ReadChar:Char;
begin
 if (fi.eof) then exit;
 if (bi.Size>bi.Index) then begin
    CurChar:=bi.buf[bi.Index];
    inc(bi.Index);
 end
 else begin
    ReloadBuf;
    if (fi.eof)
        then CurChar:=#26 // End of file is reached
        else CurChar:=ReadChar;
 end;
 ReadChar:=CurChar;
end;


procedure THexFile.ReadLine;
 Var    i       : Byte;
        Sum     : Byte;

 function ReadHexByte:byte;
  var    i       : Byte;
 begin
  if not(Curchar in['0'..'9','a'..'f','A'..'F']) then begin
    Err:=True;
    Exit;
  end;
  i:= Hex2Long(CurChar)*$10 + Hex2Long(ReadChar);
  ReadHexByte:=i;
  Sum:=Sum+i;
  ReadChar;
 end;

 function ReadHexWord:Word;
 begin
  ReadHexWord:= ReadHexByte*$100 + ReadHexByte;
 end;

begin
 Err:=False;
 Sum:=0;

 // Skip EmptyLines
 ReadChar;
 while (CurChar in[#00,#13,#10])do begin
    ReadChar;
    if (fi.eof) then begin
        Err:=True;
        exit;
    end;
 end;

 //Record Mark
 if CurChar<>':' Then Exit;
 ReadChar;
 //RecLen
 Rec.RecLen:=ReadHexByte;
 if Err then Exit;
 //Offset
 Rec.Offset:=ReadHexWord;
 if Err then Exit;
 //RecTyp
 Rec.RecTyp:=ReadHexByte;
 if Err then Exit;
 //Data
 case Rec.RecTyp of
  0:begin
        LBA.LLBA:=Rec.Offset;
        if (Rec.RecLen>0) then
        for i:=0 to (Rec.RecLen-1) do begin
            Rec.Data[i]:=ReadHexByte;
            if Err then Exit;
        end;
    end;
  4:begin
        if Rec.RecLen<>2 then begin
            Err:=true;
            Exit;
        end;
        LBA.ULBA:=ReadHexWord;
        if err then Exit;
    end;
  5:begin
        if Rec.RecLen<>4 then begin
            Err:=true;
            Exit;
        end;
        EIP:=ReadHexWord*$10000+ReadHexWord;
        if err then Exit;
    end;
 end;

 //CheckSum
 Rec.CheckSum:=ReadHexByte;
 if err then Exit;
 if Sum<>0 then Inc(ErrSum);
 //if not(fi.eof) and not(Curchar in[#00,#10,#13]) then Err:=True;
end;

procedure THexFile.WriteLine;
 Var    i   : Byte;
        s   : String;
begin
 S:= ':'+ Hex8(Rec.RecLen) + Hex16(Rec.Offset) + Hex8(Rec.RecTyp);
 if (Rec.RecLen>0) then
    for i:=0 to (Rec.RecLen-1) do S:=S+Hex8(Rec.Data[i]);
 S:=S+Hex8(Rec.CheckSum)+#$0D#$0A;
 WriteData(S[1], Length(s));
 if (Rec.RecTyp=0) then LBA.LLBA:=Rec.Offset+Rec.RecLen;
end;

procedure THexFile.WriteULBA;
 Var    i   : Byte;
        s   : String;
begin
 i:=6+CalcSum(@LBA.ULBA,2);
 S:=':02000004'+Hex16(LBa.ULBA)+Hex8(-i)+#$0D#$0A;
 WriteData(S[1], Length(s));
end;

procedure THexFile.WriteEND;
 Var    s   : String;
begin
 S:=':00000001FF'#$0D#$0A;
 WriteData(S[1], Length(s));
end;

end.
