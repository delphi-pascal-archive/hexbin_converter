unit FilePath;

INTERFACE

PROCEDURE SplitFile(Const Path:ShortString;Var Dir,Name,Ext:ShortString);
function SetfExt(Const Path:ShortString;NewExt:ShortString):ShortString;

IMPLEMENTATION


PROCEDURE SplitFile(Const Path:ShortString;Var Dir,Name,Ext:ShortString);
 Var L:Byte Absolute Path;
     i:Byte;
     DirEndPos,PointPos:Byte;
Begin
 DirEndPos:=0;
 PointPos:=0;
 For i:=1 To L Do
  Case Path[I] of
   '\':Begin DirEndPos:=i;PointPos:=0;End;
   '.':PointPos:=i;
  End;
 if DirEndPos>1 Then Dir:=Copy(Path,1,DirEndPos) Else Dir:='';
 if PointPos>1 Then
   Begin
     Name:=Copy(Path, DirEndPos+1,PointPos-DirEndPos-1);
     Ext:=Copy(Path, PointPos+1,L-PointPos);
   End
   Else Begin
     Name:=Copy(Path, DirEndPos+1,L-DirEndPos);
     Ext:='';
   End;
End;

function SetfExt(Const Path:ShortString;NewExt:ShortString):ShortString;
 Var    i          :Byte;
        PointPos   :Byte;
        Ext        :ShortString;
Begin
 PointPos:=0;
 Ext:='';
 For i:=1 To Length(Path) Do
  Case Path[I] of
   '\':PointPos:=0;
   '.':PointPos:=i;
  End;
 if PointPos>1 Then
  begin
   Ext:=Copy(Path, PointPos+1,Length(Path)-PointPos);
   if (Ext='')
    then Result:=Copy(Path,1,PointPos-1)+NewExt
    else Result:=Path;
  end
  else Result:=Path+NewExt;
End;


end.
