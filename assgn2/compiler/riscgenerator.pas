{$I+} {$R+} {$S+} {$W-}

unit riscgenerator;

interface

uses RISC, Scanner, symboltable;

var
    curlev, pc: integer;

  procedure FixLink (L: integer);

  procedure IncLevel (n: integer);

  procedure MakeConstItem (var x: Item; tp: Typ; val: integer);

  procedure MakeItem (var x: Item; y: Objct);

  procedure Field (var x: Item; y: Objct);

  procedure Index (var x, y: Item);

  procedure Op1 (op: Symbol; var x: Item);

  procedure Op2 (op: Symbol; var x, y: Item);

  procedure Relation (op: Symbol; var x, y: Item);

  procedure Store (var x, y: Item);

  procedure Parameter (var x: Item; ftyp: Typ; cls: Class);

  procedure CJump (var x: Item);

  procedure BJump (L: integer);

  procedure FJump (var L: integer);

  procedure Call (var x: Item);

  procedure IOCall (var x, y: Item);

  procedure Header (size: integer);

  procedure Enter (size: integer);

  procedure Return (size: integer);

  procedure Open;

  procedure Close;

  procedure Load;

  procedure Decode;

implementation

  const maxRel = 200;

    ADDOP = 0; SUBOP = 1; MULOP = 2; DIVOP = 3; MODOP = 4; CMPOP = 5;
    OROP = 8; ANDOP = 9; BICOP = 10; XOROP = 11; LSHOP = 12; ASHOP = 13;
    CHKOP = 14; ADDIOP = 16; SUBIOP = 17; MULIOP = 18; DIVIOP = 19;
    MODIOP = 20; CMPIOP = 21; ORIOP = 24; ANDIOP = 25; BICIOP = 26;
    XORIOP = 27; LSHIOP = 28; ASHIOP = 29; CHKIOP = 30; LDWOP = 32;
    LDBOP = 33; POPOP = 34; STWOP = 36; STBOP = 37; PSHOP = 38; BEQOP = 40;
    BNEOP = 41; BLTOP = 42; BGEOP = 43; BLEOP = 44; BGTOP = 45; BSROP = 46;
    JSROP = 48; RETOP = 49; RDOP = 50; WRDOP = 51; WRLOP = 52;

    FP = 29; SP = 30; LNK = 31;   {reserved registers}

  var
    relx: integer;
    entry: integer;
    regs: set of 0..31; { used registers }
    code: Memory;
    rel: array [0..maxRel - 1] of integer;
    mnemo: array [0..53, 0..4] of char;  {for decoder}

  procedure GetReg (var r: integer);
    var i: integer;
  begin i := 1;
    while (i < FP) and (i in regs) do i := i + 1;
    regs := regs + [i]; r := i
  end;

  procedure Put (op, a, b, c: longint);
  begin {emit instruction}
    code[pc] := longint(((((op shl 5) + a) shl 5) + b) shl 16) + (c and $0000FFFF);
    pc := pc + 1
  end;

  procedure TestRange (x: integer);
  begin {16-bit entity}
    if (x >= $8000) or (x < -$8000) then Mark ('value too large')
  end;

  procedure loadItem (var x: Item);
    var r: integer;
  begin {x.mode <> RegClass}
    if x.mode = VarClass then
      begin
        if x.lev = 0 then
          begin rel[relx] := pc; relx := relx + 1 end;
        GetReg (r); Put (LDWOP, r, x.r, x.a);

       regs := regs - [x.r]; x.r := r
      end
    else if x.mode = ConstClass then
      if x.a = 0 then x.r := 0 else
        begin TestRange (x.a); GetReg (x.r); Put (ADDIOP, x.r, 0, x.a) end;
    x.mode := RegClass
  end;

  procedure loadBool (var x: Item);
  begin
    if x.tp^.form <> Bool then Mark ('Boolean?');
    loadItem (x); x.mode := CondClass; x.a := 0; x.b := 0; x.c := 1
  end;

  procedure PutOp (cd: integer; var x, y: Item);
    var r: integer;
  begin
    if x.mode <> RegClass then loadItem (x);
    if x.r = 0 then
      begin GetReg (x.r); r := 0 end
    else r := x.r;
    if y.mode = ConstClass then
      begin TestRange (y.a); Put (cd+16, r, x.r, y.a) end
    else
      begin
        if y.mode <> RegClass then loadItem (y);
        Put (cd, x.r, r, y.r); regs := regs - [y.r]
      end
  end;

  function power (x, y: integer): integer;
  begin
    power := x;
    while y > 1 do begin power := power * x; y := y - 1 end;
  end;

  function negated (cond: integer): integer;
  begin
    if odd (cond) then negated := cond - 1 else negated := cond + 1
  end;

  function merged (L0, L1: integer): integer;
    var L2, L3: integer;
  begin
    if L0 <> 0 then
      begin
        L2 := L0;
        while true do
          begin
            L3 := code[L2] and $0000FFFF;
            if L3 = 0 then break;
            L2 := L3
          end;
        code[L2] := code[L2] - L3 + L1; merged := L0
      end
    else merged := L1
  end;

  procedure fix (at, fixwith: integer);
  begin {first mask out lower 16 bits}
    code[at] := longint(code[at] and $FFFF0000) or (fixwith and $0000FFFF)
  end;

  procedure FixLink (L: integer);
    var L1: integer;
  begin
    while L <> 0 do
      begin L1 := code[L] and $0000FFFF; fix (L, pc-L); L := L1 end
  end;

  (*-----------------------------------------------*)

  procedure IncLevel (n: integer);
  begin curlev := curlev + n
  end;

  procedure MakeConstItem (var x: Item; tp: Typ; val: integer);
  begin x.mode := ConstClass; x.tp := tp; x.a := val;
    x.r := 0 {to simplify register deallocation in Relation}
  end;

  procedure asmPowr(var x, y : Item);
  begin
      Put(PSHOP, 6, SP, 4);
      Put(PSHOP, 5, SP, 4);
      Put(PSHOP, 4, SP, 4);
      Put(PSHOP, 3, SP, 4);
      Put(PSHOP, 2, SP, 4);
      Put(PSHOP, 1, SP, 4);

      if x.mode <> RegClass then loadItem(x);
      Put(ADDOP, 1, x.r, 0);

      if y.mode = ConstClass then
      begin
        TestRange(y.a);
        Put(ADDIOP, 2, 0, y.a)
      end
      else begin
        if y.mode <> RegClass then loadItem(y);
        Put(ADDOP, 2, y.r, 0);
      end;

      Put(ADDOP, 3, 0, 0);
      Put(ADDIOP, 5, 0, 1);
      Put(ADDIOP, 6, 0, 1);
      Put(MODIOP, 4, 2, 2);
      Put(BNEOP, 4, 5, 2);
      Put(MULOP, 6, 6, 1);
      Put(DIVIOP, 2, 2, 2);
      Put(BEQOP, 2, 3, 3);
      Put(MULOP, 1, 1, 1);
      Put(BEQOP, 0, 0, -6);
      Put(POPOP, 1, SP, 4);
      Put(POPOP, 2, SP, 4);
      Put(POPOP, 3, SP, 4);
      Put(POPOP, 4, SP, 4);
      Put(POPOP, 5, SP, 4);

      if x.r <> 6 then
      begin
        if x.r = 0 then
        begin
          GetReg (x.r);
        end;
        Put(ADDOP, x.r, 0, 6);
        Put(POPOP, 6, SP, 4);
      end;
  end;

  procedure MakeItem (var x: Item; y: Objct);
    var r: integer;
  begin x.mode := y^.cls; x.tp := y^.tp; x.lev := y^.lev; x.a := y^.val;
    if y^.lev = 0 then x.r := 0
    else if y^.lev = curlev then x.r := FP
    else begin Mark ('level!'); x.r := 0 end;
    if y^.cls = ParClass then
      begin GetReg (r); Put (LDWOP, r, x.r, x.a); x.mode := VarClass;
        x.r := r; x.a := 0
      end
  end;

  procedure Field (var x: Item; y: Objct);   { x := x.y }
  begin x.a := x.a + y^.val; x.tp := y^.tp
  end;

  procedure Index (var x, y: Item);   { x := x[y] }
  begin
    if y.tp <> intType then Mark ('index not integer');
    if y.mode = ConstClass then
      begin
        if (y.a < x.tp^.lower) or (y.a >= x.tp^.len + x.tp^.lower) then
          Mark ('bad index');
        x.a := x.a + (y.a - x.tp^.lower) * x.tp^.base^.size
      end
    else
      begin
        if y.mode <> RegClass then loadItem (y);
        Put (SUBIOP, y.r, y.r, x.tp^.lower);
        Put (CHKIOP, y.r, 0, x.tp^.len);
        Put (MULIOP, y.r, y.r, x.tp^.base^.size);
        if x.r <> 0 then
          begin Put (ADDOP, y.r, x.r, y.r); regs := regs - [x.r] end;
        x.r := y.r
      end;
    x.tp := x.tp^.base
  end;

  procedure Op1 (op: Symbol; var x: Item);   { x := op x }
    var t: integer;
  begin
    if op = MinusSym then
      if x.tp^.form <> Int then Mark ('bad type')
      else if x.mode = ConstClass then x.a := -x.a
      else
        begin
          if x.mode = VarClass then loadItem (x);
          Put (SUBOP, x.r, 0, x.r)
        end
    else if op = NotSym then
      begin
        if x.mode <> CondClass then loadBool (x);
        x.c := negated (x.c); t := x.a; x.a := x.b; x.b := t
      end
    else if op = AndSym then
      begin
        if x.mode <> CondClass then loadBool (x);
        Put (BEQOP + negated (x.c), x.r, 0, x.a); regs := regs - [x.r];
        x.a := pc-1; FixLink (x.b); x.b := 0
      end
    else if op = OrSym then
      begin
        if x.mode <> CondClass then loadBool (x);
        Put (BEQOP + x.c, x.r, 0, x.b); regs := regs - [x.r];
        x.b := pc-1; FixLink (x.a); x.a := 0
      end
  end;

  procedure Op2 (op: Symbol; var x, y: Item);   (* x := x op y *)
  begin
    if (x.tp^.form = Int) and (y.tp^.form = Int) then
      if (x.mode = ConstClass) and (y.mode = ConstClass) then
        {overflow checks missing}
        if op = PlusSym then x.a := x.a + y.a
        else if op = MinusSym then x.a := x.a - y.a
        else if op = TimesSym then x.a := x.a * y.a
        else if op = PowrSym then x.a := power(x.a, y.a)
        else if op = DivSym then x.a := x.a div y.a
        else if op = ModSym then x.a := x.a mod y.a
        else Mark ('bad type')
      else
        if op = PlusSym then PutOp (ADDOP, x, y)
        else if op = MinusSym then PutOp (SUBOP, x, y)
        else if op = TimesSym then PutOp (MULOP, x, y)
        else if op = PowrSym then asmPowr(x, y)
        else if op = DivSym then PutOp (DIVOP, x, y)
        else if op = ModSym then PutOp (MODOP, x, y)
        else Mark ('bad type')
    else if (x.tp^.form = Bool) and (y.tp^.form = Bool) then
      begin
        if y.mode <> CondClass then loadBool (y);
        if op = OrSym then
          begin x.a := y.a; x.b := merged (y.b, x.b); x.c := y.c end
        else if op = AndSym then
          begin x.a := merged (y.a, x.a); x.b := y.b; x.c := y.c end
      end
    else Mark ('bad type')
  end;

  procedure Relation (op: Symbol; var x, y: Item);   { x := x ? y }
  begin
    if (x.tp^.form <> Int) or (y.tp^.form <> Int) then Mark ('bad type')
    else
      begin
        if (y.mode = ConstClass) and (y.a = 0) then loadItem (x)
        else PutOp (CMPOP, x, y);
        x.c := ord (op) - ord (EqlSym); regs := regs - [y.r]
      end;
    x.mode := CondClass; x.tp := boolType; x.a := 0; x.b := 0
  end;

  procedure Store (var x, y: Item); { x := y }
  begin
    if (x.tp^.form in [Bool, Int]) and (x.tp^.form = y.tp^.form) then
      begin
        if y.mode = CondClass then
          begin
            Put (BEQOP + negated (y.c), y.r, 0, y.a);
            regs := regs - [y.r]; y.a := pc - 1;
            FixLink (y.b); GetReg (y.r);
            Put (ADDIOP, y.r, 0, 1); Put (BEQOP, 0, 0, 2);
            FixLink (y.a); Put (ADDIOP, y.r, 0, 0)
          end
        else if y.mode <> RegClass then loadItem (y);
        if x.mode = VarClass then
          begin
            if x.lev = 0 then
              begin rel[relx] := pc; relx := relx + 1 end ;
            Put (STWOP, y.r, x.r, x.a)
          end
        else Mark ('illegal assignment');
        regs := regs - [x.r, y.r]
      end
    else Mark ('incompatible assignment')
  end;

  procedure Parameter (var x: Item; ftyp: Typ; cls: Class);
    var r: integer;
  begin
    if x.tp = ftyp then
      if cls = ParClass then {VAR parameter}
        begin
          if x.mode = VarClass then
            if x.a <> 0 then
              begin
                if x.lev = 0 then
                  begin rel[relx] := pc; relx := relx + 1 end ;
                GetReg (r); Put (ADDIOP, r, x.r, x.a)
              end
            else r := x.r
          else Mark ('illegal parameter mode');
          Put (PSHOP, r, SP, 4); regs := regs - [r]
        end
      else {value parameter}
        begin
          if x.mode <> RegClass then loadItem (x);
          Put (PSHOP, x.r, SP, 4); regs := regs - [x.r]
        end
    else Mark ('bad parameter type')
  end;

  (*---------------------------------*)

  procedure CJump (var x: Item);
  begin
    if x.tp^.form = Bool then
      begin
        if x.mode <> CondClass then loadBool (x);
        Put (BEQOP + negated(x.c), x.r, 0, x.a); regs := regs - [x.r];
        FixLink (x.b); x.a := pc - 1
      end
    else begin Mark ('Boolean?'); x.a := pc end
  end;

  procedure BJump (L: integer);
  begin Put (BEQOP, 0, 0, L-pc)
  end;

  procedure FJump (var L: integer);
  begin Put (BEQOP, 0, 0, L); L := pc-1
  end;

  procedure Call (var x: Item);
  begin Put (BSROP, 0, 0, x.a - pc)
  end;

  procedure IOCall (var x, y: Item);
    var z: Item;
  begin
    if x.a < 3 then
      if y.tp^.form <> Int then Mark ('Integer?');
    if x.a = 1 then
      begin
        GetReg (z.r); z.mode := RegClass; z.tp := intType;
        Put (RDOP, z.r, 0, 0); Store (y, z)
      end
    else if x.a = 2 then
      begin loadItem (y); Put (WRDOP, 0, 0, y.r); regs := regs - [y.r] end
    else Put (WRLOP, 0, 0, 0)
  end;

  procedure Header (size: integer);
  begin
    entry := pc; Put (ADDIOP, SP, 0, MemSize - size);  {init SP}
    Put (PSHOP, LNK, SP, 4)
  end;

  procedure Enter (size: integer);
  begin
    Put (PSHOP, LNK, SP, 4);
    Put (PSHOP, FP, SP, 4);
    Put (ADDOP, FP, 0, SP);
    Put (SUBIOP, SP, SP, size)
  end;

  procedure Return (size: integer);
  begin
    Put (ADDOP, SP, 0, FP);
    Put (POPOP, FP, SP, 4);
    Put (POPOP, LNK, SP, size+4);
    Put (RETOP, 0, 0, LNK)
  end;

  procedure Open;
  begin curlev := 0; pc := 0; relx := 0; regs := []
  end;

  procedure Close;
  begin Put (POPOP, LNK, SP, 4); Put (RETOP, 0, 0, LNK);
  end;

  (*-------------------------------------------*)

  procedure Decode;
    var i, cd, a: longint;
  begin
    writeln ('entry', entry*4 :6); i := 0;
    while i < pc do
      begin
        cd := code[i]; a := (cd and $0000FFFF);
        if a >= $8000 then a := a - $10000; {sign extension}
        write (4*i :4, '    ', mnemo[(cd shr 26) and $0000003F]);
        write ('    ', (cd shr 21) and $0000001F :4);
        write (',', (cd shr 16) and $0000001F :4);
        writeln (',', a :8); i := i + 1
      end;
    writeln ('reloc'); i := 0;
    while i < relx do
      begin
        write (rel[i]*4 :5); i := i + 1;
        if i mod 16 = 0 then writeln
      end ;
    writeln;
  end;

  procedure Load;
    var i, k: integer;
  begin i := 0; {relocate}
    while i < relx do
      begin
        k := rel[i]; i := i + 1;
        code[k] := longint(code[k] and $FFFF0000) or
          ((code[k] + MemSize) and $0000FFFF)
      end;
    LoadCode (code, pc);
    writeln ('  code loaded');
    if paramcount > 2 then Decode;
    Execute (entry*4)
  end;

begin
  new (boolType); boolType^.form := Bool; boolType^.size := 4;
  new (intType); intType^.form := Int; intType^.size := 4;
  mnemo[ADDOP] := 'ADD ';
  mnemo[SUBOP] := 'SUB ';
  mnemo[MULOP] := 'MUL ';
  mnemo[DIVOP] := 'DIV ';
  mnemo[MODOP] := 'MOD ';
  mnemo[CMPOP] := 'CMP ';
  mnemo[OROP] := 'OR  ';
  mnemo[ANDOP] := 'AND ';
  mnemo[BICOP] := 'BIC ';
  mnemo[XOROP] := 'XOR ';
  mnemo[LSHOP] := 'LSH ';
  mnemo[ASHOP] := 'ASH ';
  mnemo[CHKOP] := 'CHK ';
  mnemo[ADDIOP] := 'ADDI';
  mnemo[SUBIOP] := 'SUBI';
  mnemo[MULIOP] := 'MULI';
  mnemo[DIVIOP] := 'DIVI';
  mnemo[MODIOP] := 'MODI';
  mnemo[CMPIOP] := 'CMPI';
  mnemo[ORIOP] := 'ORI ';
  mnemo[ANDIOP] := 'ANDI';
  mnemo[BICIOP] := 'BICI';
  mnemo[XORIOP] := 'XORI';
  mnemo[LSHIOP] := 'LSHI';
  mnemo[ASHIOP] := 'ASHI';
  mnemo[CHKIOP] := 'CHKI';
  mnemo[LDWOP] := 'LDW ';
  mnemo[LDBOP] := 'LDB ';
  mnemo[POPOP] := 'POP ';
  mnemo[STWOP] := 'STW ';
  mnemo[STBOP] := 'STB ';
  mnemo[PSHOP] := 'PSH ';
  mnemo[BEQOP] := 'BEQ ';
  mnemo[BNEOP] := 'BNE ';
  mnemo[BLTOP] := 'BLT ';
  mnemo[BGEOP] := 'BGE ';
  mnemo[BLEOP] := 'BLE ';
  mnemo[BGTOP] := 'BGT ';
  mnemo[BSROP] := 'BSR ';
  mnemo[JSROP] := 'JSR ';
  mnemo[RETOP] := 'RET ';
  mnemo[RDOP] := 'READ';
  mnemo[WRDOP] := 'WRD ';
  mnemo[WRLOP] := 'WRL '
end.
