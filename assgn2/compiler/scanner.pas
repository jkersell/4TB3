unit scanner;
interface

  const
    IdLen = 31; {number of significant characters in identifiers}

  type
    Symbol = (null, TimesSym, DivSym, ModSym, AndSym, PlusSym, MinusSym,
      OrSym, EqlSym, NeqSym, LssSym, GeqSym, LeqSym, GtrSym, PeriodSym,
      CommaSym, ColonSym, RparenSym, RbrakSym, OfSym, ThenSym, DoSym,
      LparenSym, LbrakSym, NotSym, BecomesSym, NumberSym, IdentSym,
      SemicolonSym, EndSym, ElseSym, IfSym, WhileSym, ArraySym, RecordSym,
      ConstSym, TypeSym, VarSym, ProcedureSym, BeginSym, ProgramSym,
      EofSym);
    Identifier = string[IdLen];

  var
    sym: Symbol; {next symbol}
    val: integer; {value of number if sym = NumberSym}
    id: Identifier; {string for identifier if sym = IdentSym}
    error: Boolean; {whether an error has occurred so far}

  procedure Mark (msg: string);

  procedure Warn (msg: string);

  procedure GetSym;

implementation

  const
    KW = 20; {number of keywords}

  type
    KeyTable = array [1..KW] of
      record sym: Symbol; id: Identifier end;

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

  procedure Number;
  begin val := 0; sym := NumberSym;
    repeat
      if val <= maxint - (ord (ch) - ord ('0')) div 10 then
        val := 10 * val + (ord (ch) - ord ('0'))
      else
        begin Mark ('number too large'); val := 0 end;
      GetChar
    until not (ch in ['0'..'9'])
  end;

  procedure Ident;
    var len, k: integer;
  begin len := 0;
    repeat
      if len < IdLen then begin len := len + 1; id[len] := ch; end;
      GetChar
    until not (ch in  ['A'..'Z', 'a'..'z', '0'..'9']);
    setlength(id, len); k := 1;
    while (k <= KW) and (id <> keyTab[k].id) do k := k + 1;
    if k <= KW then sym := keyTab[k].sym else sym := IdentSym
  end;

  {My implementation requires that nested comments be properly terminated. The other option
  is to terminate on the first closing parenthesis but the assignment makes it seem like that
  is not what is desired.}
  procedure comment;
    var nest: integer = 1;
  begin GetChar;
    while (not eof (source)) and (nest <> 0) do
    begin
      if ch = '{' then
      begin
        nest := nest + 1;
        if nest = 2 then Warn ('nested comment');
      end
      else
      begin
        if ch = '}' then nest := nest - 1;
      end;
      GetChar;
    end;
    if eof (source) then Mark ('comment not terminated')
    else GetChar;
  end;

  procedure Mark (msg: string);
  begin
    if (lastline > errline) or (lastpos > errpos) then
      writeln ('error: line ', lastline:1, ' pos ', lastpos:1, ' ', msg);
    errline := lastline; errpos := lastpos; error := true
  end;

  procedure Warn (msg: string);
  begin
    writeln ('warning: line ', lastline:1, ' pos ', lastpos:1, ' ', msg);
  end;

  procedure GetSym;
  begin {first skip white space}
    while not eof (source) and (ch <= ' ') do GetChar;
    if eof (source) then sym := EofSym
    else
      case ch of
        '*': begin GetChar; sym := TimesSym end;
        '+': begin GetChar; sym := PlusSym end;
        '-': begin GetChar; sym := MinusSym end;
        '=': begin GetChar; sym := EqlSym end;
        '<': begin GetChar;
               if ch = '=' then
                 begin GetChar; sym := LeqSym end
               else if ch = '>' then
                 begin GetChar; sym := NeqSym end
               else sym := LssSym
             end;
        '>': begin GetChar;
               if ch = '=' then
                 begin GetChar; sym := GeqSym end
               else sym := GtrSym
             end;
        ';': begin GetChar; sym := SemicolonSym end;
        ',': begin GetChar; sym := CommaSym end;
        ':': begin GetChar;
               if ch = '=' then
                 begin GetChar; sym := BecomesSym end
               else sym := ColonSym
             end;
        '.': begin GetChar; sym := PeriodSym end;
        '(': begin GetChar; sym := LparenSym end;
        ')': begin GetChar; sym := RparenSym end;
        '[': begin GetChar; sym := LbrakSym end;
        ']': begin GetChar; sym := RbrakSym end;
        '0'..'9': Number;
        'A' .. 'Z', 'a'..'z': Ident;
        '{': begin comment; GetSym end;
      otherwise
        begin GetChar; sym := null end
      end
  end;

begin
  line := 1; lastline := 1; errline := 1;
  pos := 0; lastpos := 0; errpos := 0;
  error := false;
  keyTab[1].sym := DoSym; keyTab[1].id := 'do';
  keyTab[2].sym := IfSym; keyTab[2].id := 'if';
  keyTab[3].sym := OfSym; keyTab[3].id := 'of';
  keyTab[4].sym := OrSym; keyTab[4].id := 'or';
  keyTab[5].sym := AndSym; keyTab[5].id := 'and';
  keyTab[6].sym := NotSym; keyTab[6].id := 'not';
  keyTab[7].sym := EndSym; keyTab[7].id := 'end';
  keyTab[8].sym := ModSym; keyTab[8].id := 'mod';
  keyTab[9].sym := VarSym; keyTab[9].id := 'var';
  keyTab[10].sym := ElseSym; keyTab[10].id := 'else';
  keyTab[11].sym := ThenSym; keyTab[11].id := 'then';
  keyTab[12].sym := TypeSym; keyTab[12].id := 'type';
  keyTab[13].sym := ArraySym; keyTab[13].id := 'array';
  keyTab[14].sym := BeginSym; keyTab[14].id := 'begin';
  keyTab[15].sym := ConstSym; keyTab[15].id := 'const';
  keyTab[16].sym := WhileSym; keyTab[16].id := 'while';
  keyTab[17].sym := RecordSym; keyTab[17].id := 'record';
  keyTab[18].sym := ProcedureSym; keyTab[18].id := 'procedure';
  keyTab[19].sym := DivSym; keyTab[19].id := 'div';
  keyTab[20].sym := ProgramSym; keyTab[20].id := 'program';
  if paramcount > 0 then
    begin fn := paramstr (1); assign (source, fn); reset (source);
      GetChar
    end
  else Mark ('name of source file expected')

end.

