Unit BufferedFile;

INTERFACE

Const   BufferSize = 4096;

TYPE

  TBufferInfo = Record
        buf     : pchar;
        Start   : Longint;    // File Postion for the Start of the Buffer
        Size    : Longint;    // Data Size within the Buffer
        Index   : Longint;    // Current Cursor Position
  end;

  TFileInfo = Record
        f       : file;
        Name    : ShortString;
        Size    : Integer;
        Closed  : Boolean;
        ClosePos: Integer;
        eof     : Boolean;
  end;

  pBufferedFile = ^TBufferedFile;
  TBufferedFile = Object
        fi      : TFileInfo;
        bi      : TBufferInfo;
        procedure Init;
        procedure Done;
        function OpenFile(const fn:string):boolean;
        function CreateFile(const fn:string):Boolean;
        procedure CloseFile;
        procedure ReloadBuf;
        procedure ReadData(var b;len:longint;Var Idx:Integer);
        procedure WriteBuf;
        procedure WriteData(const b;len:longint);
        procedure WriteByte( b:byte;len:longint );
        function TempOpen:boolean;
        procedure TempClose;
  end;



IMPLEMENTATION

procedure TBufferedFile.Init;
begin
  fi.Closed:=True;
  GetMem( bi.buf,BufferSize );
end;


procedure TBufferedFile.Done;
begin
  CloseFile;
  if assigned(bi.buf) then FreeMem(bi.buf,BufferSize);
end;


function TBufferedFile.OpenFile(const fn:string):boolean;
begin
  Result:=false;

  Assign(fi.f,fn);
  filemode:=$0;
  {$I-} reset(fi.f,1); {$I+}
  if ioresult<>0 then exit;

  fi.Name:=fn;
  fi.Closed:=false;
  fi.Size:=filesize(fi.f);
  fi.eof:=False;

 //reset buffer
  bi.Start:=0;
  bi.Size:=0;
  bi.Index:=0;

  Result:=true;
end;

function TBufferedFile.CreateFile(const fn:string):boolean;
begin
  CreateFile:=false;

  Assign(fi.f,fn);
  fileMode:=2;
  {$I-} rewrite(fi.f,1); {$I+}
  if ioresult<>0 then exit;

  //Mode:=2;
  fi.Name:=fn;
  fi.Closed:=false;
  fi.Size:=0;
  fi.eof:=False;

 //reset buffer
  bi.Start:=0;
  bi.Size:=BufferSize; // get the max size
  bi.Index:=0;

  CreateFile:=True;
end;


procedure TBufferedFile.CloseFile;
begin
 if not(fi.Closed) then begin
    Close(fi.f);
    fi.Closed:=true;
 end;
end;


procedure TBufferedFile.ReloadBuf;
begin // Load data to buffer
 Inc( bi.Start, bi.Size );
 blockread( fi.f, bi.buf^, BufferSize, bi.Size );
 if (bi.Size=0) then fi.eof:=True;
 bi.Index:=0;
end;

procedure TBufferedFile.ReadData(var b;len:longint;Var Idx:Integer);
 var    p       : pchar;
        left    : longint;
begin
 if (fi.eof) then exit;
 p:=pchar(@b);
 Idx:=0;
 while (len>0) do begin
     left:=bi.Size-bi.Index;
     if (len>left) then begin
        if (left<>0) then begin
            move( bi.buf[bi.Index], p[idx], left );
            dec(len,left);
            inc(idx,left);
        end;
        ReloadBuf;
        if (bi.Size=0) then exit; // End of file is reached
     end
     else begin
        move(bi.buf[bi.Index],p[idx],len);
        inc(bi.Index,len);
        inc(idx,len);
        exit;
     end;
 end;
end;

procedure TBufferedFile.WriteBuf;
begin
  blockwrite(fi.f,bi.buf^,bi.Index);
  Inc(bi.Start,bi.Index);
  bi.Index:=0;
end;

procedure TBufferedFile.WriteData(const b;len:longint);
 Var    p       : pchar;
        left,idx: longint;
begin
 p:=pchar(@b);
 idx:=0;
 while len>0 do begin
    left:=bi.Size-bi.Index;
    if (len>left) then begin
        move(p[idx],bi.buf[bi.Index],left);
        dec(len,left);
        inc(idx,left);
        inc(bi.Index,left);
        writebuf;
    end
    else begin
        move(p[idx],bi.buf[bi.Index],len);
        inc(bi.Index,len);
        exit;
    end;
 end;
end;

procedure TBufferedFile.WriteByte( b:byte;len:longint );
 Var    left    : longint;
begin
 while len>0 do begin
    left:=bi.Size-bi.Index;
    if (len>left) then begin
        FillChar(bi.buf[bi.Index],Left,b);
        dec(len,left);
        inc(bi.Index,left);
        writebuf;
    end
    else begin
        FillChar(bi.buf[bi.Index],Len,b);
        inc(bi.Index,len);
        exit;
    end;
 end;
end;

function TBufferedFile.TempOpen:boolean;
begin
  Result:=false;
  Assign(fi.f,fi.Name);
  filemode:=$0;
  {$I-} reset(fi.f,1); {$I+}
  Seek(fi.f,fi.ClosePos);
  if ioresult<>0 then exit;
  fi.Closed:=false;
  Result:=true;
end;

procedure TBufferedFile.TempClose;
begin
 if not(fi.Closed) then begin
    fi.ClosePos:=FilePos(fi.f);
    close(fi.f);
    fi.Closed:=true;
 end;
end;

end.

