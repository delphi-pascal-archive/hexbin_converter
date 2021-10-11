unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    ButHexBin: TButton;
    ButBinHex: TButton;
    ButExit: TButton;
    procedure ButHexBinClick(Sender: TObject);
    procedure ButBinHexClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses    BufferedFile,HexFile,FilePath;
{$R *.dfm}

Var     ExecDir : ShortString;

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


procedure TForm1.ButHexBinClick(Sender: TObject);
 Var    fHex    : THexFile;
        fBin    : TBufferedFile;
        S       : String;
        LBA     : Integer;
begin
 OpenDialog1.Filter:='Hex File (*.hex)|*.hex';
 OpenDialog1.FileName:='';
 if not OpenDialog1.Execute Then exit;
 if not fileExists(OpenDialog1.FileName) then Exit;
 s:=OpenDialog1.FileName;

 fHex.Init; fHex.OpenFile(S);
 fBin.Init; fBin.CreateFile(S+'.bin');

 LBA:=0;
 while not(fHex.fi.eof) do begin
    fHex.ReadLine;
    if fHex.Err then Break;
    case fHex.Rec.RecTyp of
        0: begin
            if ( LBA>fHex.LBA.LBA ) then begin
                fBin.WriteBuf;
                Seek( fBin.fi.f, fHex.LBA.LBA );
            end
            else if ( LBA<fHex.LBA.LBA ) then begin
                fBin.WriteByte(0, fHex.LBA.LBA-LBA);
            end;
            case (fHex.Rec.RecTyp) of
                0: fBin.WriteData(fHex.Rec.Data,fHex.Rec.RecLen);
                else Break;
            end;
        end;
        4,5: ;
        else Break;
    end;
    LBA := fHex.LBA.LBA + fHex.Rec.RecLen;
 end;


 fHex.Done;
 fBin.WriteBuf;
 fBin.Done;
 if fHex.Err then
    Application.MessageBox('Source File contains Error', 'Hex-Bin',MB_Ok+MB_ICONERROR)
 else if (fHex.ErrSum>0) then
    Application.MessageBox('Binary file Created'#13'But Hex file contains CheckSum Error', 'Hex-Bin',MB_Ok+MB_ICONWARNING)
 else Application.MessageBox('Binary file Created', 'Hex-Bin',MB_Ok+MB_ICONINFORMATION);
end;

procedure TForm1.ButBinHexClick(Sender: TObject);
 Var    fHex    : THexFile;
        fBin    : TBufferedFile;
        S       : String;
        rt,i    : Integer;
        LBA     : Integer;
        StartIdx:Byte;
begin
 OpenDialog1.Filter:='Bin (*.bin)|*.bin';
 OpenDialog1.FileName:='';
 if not OpenDialog1.Execute Then exit;
 if not fileExists(OpenDialog1.FileName) then Exit;
 s:=OpenDialog1.FileName;
 fBin.Init; fBin.OpenFile(S);
 fHex.Init; fHex.CreateFile(S+'.hex');
 LBA:=0;
 fBin.ReadData(fHex.Rec.Data,16,rt);
 while not(fBin.fi.eof) do begin
    if  (fHex.LBA.ULBA<>LBA div $10000) then begin
        fHex.LBA.ULBA:=LBA div $10000;
        fHex.WriteULBA;
    end;
   // Optimize
    StartIdx:=0;
    while (fHex.Rec.Data[StartIdx]=0) do begin
        Inc(StartIdx);
        if (StartIdx=Rt) then Break;
    end;
    if (StartIdx<Rt) then begin
        if Odd(StartIdx) then Dec(StartIdx);
        i:=Rt-StartIdx;
        if i<=8 then begin
            fHex.Rec.RecLen:=i;
            for i:=StartIdx to (Rt-1) do fHex.Rec.Data[i-StartIdx]:=fHex.Rec.Data[i];
            fHex.Rec.Offset:=LBA+StartIdx;
        end
        else begin
            fHex.Rec.RecLen:=Rt;
            fHex.Rec.Offset:=LBA;
        end;
        fHex.Rec.RecTyp:=0;
        fHex.Rec.CheckSum:= -CalcSum(@fHex.Rec,fHex.Rec.RecLen+5);
        fHex.WriteLine;
    end;
    LBA:=LBA+Rt;
    fBin.ReadData(fHex.Rec.Data,16,rt);
 end;

 fHex.WriteEND;
 fHex.WriteBuf;

 fBin.Done;
 fHex.Done;
 Application.MessageBox('Hex file created!', 'Hex-Bin',MB_Ok+MB_ICONINFORMATION);
end;


procedure TForm1.FormCreate(Sender: TObject);
 Var Name,Ext:ShortString;
begin
 SplitFile(Paramstr(0),ExecDir,Name,Ext);
 OpenDialog1.InitialDir:=ExecDir;
end;

procedure TForm1.ButExitClick(Sender: TObject);
begin
 Application.Terminate;
end;

end.
