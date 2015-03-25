unit scanner;
interface

  const
    IdLen = 31; {number of significant characters in identifiers}

  type
    Symbol = (null, TableStartSym, TableEndSym, RowStartSym, RowEndSym, CellStartSym, CellEndSym, ContentsSym, UnknownSym, EofSym);
    Contents = string[IdLen];

  var
    sym: Symbol; {next symbol}
    val: integer; {value of number if sym = NumberSym}
    cont: Contents; {string to hold contents of a cell}
    tag: Contents; {string to hold a tag}
    error: Boolean; {whether an error has occurred so far}

  procedure Mark (msg: string);

  procedure GetSym;

implementation

  const
    KW = 6; {number of keywords}

  type
    KeyTable = array [1..KW] of
      record sym: Symbol; id: Contents end;

  var
    ch: char;
    line, lastline, errline: integer;
    pos, lastpos, errpos: integer;
    keyTab: KeyTable;
    fn: string[255]; {name of source file}
    source: text; {source file}

  procedure GetChar;
  begin
    lastpos := pos;
    if eoln (source) then begin pos := 0; line := line + 1 end
    else begin lastline:= line; pos := pos + 1 end;
    read (source, ch)
  end;

  procedure getCell;
    var len, k: integer;
  begin len := 0;
    repeat
      if len < IdLen then begin len := len + 1; cont[len] := ch; end;
      GetChar
    until not (ch in  ['A'..'Z', 'a'..'z', '0'..'9']);
    setlength(cont, len); k := 1;
    while (k <= KW) and (cont <> keyTab[k].id) do k := k + 1;
    if k <= KW then sym := keyTab[k].sym else sym := ContentsSym;
  end;

  procedure getTag;
    var len, k: integer;
  begin len := 0;
    repeat
      if len < IdLen then begin len := len + 1; tag[len] := ch; end;
      GetChar
    until not (ch = '>');
    setlength(tag, len); k := 1;
    while (k <= KW) and (cont <> keyTab[k].id) do k := k + 1;
    if k <= KW then sym := keyTab[k].sym else sym := UnknownSym;
  end;

  procedure Mark (msg: string);
  begin
    if (lastline > errline) or (lastpos > errpos) then
      writeln ('error: line ', lastline:1, ' pos ', lastpos:1, ' ', msg);
    errline := lastline; errpos := lastpos; error := true
  end;

  procedure GetSym;
  begin {first skip white space}
    while not eof (source) and (ch <= ' ') do GetChar;
    if eof (source) then sym := EofSym
    else
    case ch of
      '<': begin GetChar; getTag; end;
      'A' .. 'Z', 'a'..'z', '0'..'9': getCell;
    otherwise
      begin GetChar; sym := null end
    end
  end;

begin
  line := 1; lastline := 1; errline := 1;
  pos := 0; lastpos := 0; errpos := 0;
  error := false;
  keyTab[1].sym := TableStartSym; keyTab[1].id := 'TABLE';
  keyTab[2].sym := TableEndSym; keyTab[2].id := '/TABLE';
  keyTab[3].sym := RowStartSym; keyTab[3].id := 'TR';
  keyTab[4].sym := RowEndSym; keyTab[4].id := '/TR';
  keyTab[5].sym := CellStartSym; keyTab[5].id := 'TD';
  keyTab[6].sym := CellEndSym; keyTab[6].id := '/TD';
  if paramcount > 0 then
  begin fn := paramstr (1); assign (source, fn); reset (source);
    GetChar
  end
  else Mark ('name of source file expected')

end.
