program risccompiler (input, output);

uses scanner, symboltable, riscgenerator, risc;

  const
    WordSize = 4;

    {first/follow sets}
    MoreExp = [EqlSym, NeqSym, LssSym, GeqSym, LeqSym, GtrSym];
    MoreSimpleExp = [PlusSym, MinusSym, OrSym];
    MoreTerm = [PowrSym, TimesSym, DivSym, ModSym, AndSym];
    FirstFactor = [IdentSym, NumberSym, LparenSym, NotSym];
    FollowFactor = [TimesSym, DivSym, ModSym, AndSym, OrSym, PlusSym,
      MinusSym, EqlSym, NeqSym, LssSym, LeqSym, GtrSym, GeqSym, CommaSym,
      SemicolonSym, ThenSym, ElseSym, RparenSym, DoSym, PeriodSym, EndSym];
    DeclSyms = [ConstSym, TypeSym, VarSym, ProcedureSym];
    StrongSyms = [ConstSym, TypeSym, VarSym, ProcedureSym, WhileSym, IfSym,
      BeginSym, EofSym];
    FirstStatement = [IdentSym, IfSym, WhileSym, BeginSym];
    FollowStatement = [SemicolonSym, EndSym, ElseSym, BeginSym];
    FirstType = [IdentSym, RecordSym, ArraySym, LparenSym];
    FollowType = [SemicolonSym];
    FollowDecl = [BeginSym, EndSym, ProcedureSym, EofSym];
    FollowProcCall = [SemicolonSym, EndSym, ElseSym, IfSym, WhileSym];

  procedure expression (var x: Item); forward;
  procedure statement; forward;

  procedure selector (var x: Item);
    var y: Item; obj: Objct;
  begin
    while (sym = LbrakSym) or (sym = PeriodSym) do
      if sym = LbrakSym then
        begin GetSym; expression (y);
          if x.tp^.form = Arry then Index (x, y) else Mark ('not an array');
          if sym = RbrakSym then GetSym else Mark (']?')
        end
      else
        begin GetSym;
          if sym = IdentSym then
            if x.tp^.form = Rcrd then
              begin FindField (obj, x.tp^.fields); GetSym;
                if obj <> guard then Field (x, obj) else Mark ('undef')
              end
            else Mark ('not a record')
          else Mark ('ident?')
        end
  end;

  procedure factor (var x: Item);
    var obj: Objct;
  begin {sync}
    if not (sym in FirstFactor) then
      begin Mark ('factor?');
        repeat GetSym until sym in FirstFactor + StrongSyms + FollowFactor
      end;
    if sym = IdentSym then
      begin Find (obj); GetSym; MakeItem (x, obj); selector (x) end
    else if sym = NumberSym then
      begin MakeConstItem (x, intType, val); GetSym end
    else if sym = LparenSym then
      begin
        GetSym; expression (x);
        if sym = RparenSym then GetSym else Mark (')?')
      end
    else if sym = NotSym then
      begin GetSym; factor (x); Op1 (NotSym, x) end
    else begin Mark ('factor?'); MakeItem (x, guard) end
  end;

  procedure term (var x: Item);
    var y: Item; op: Symbol;
  begin factor (x);
    while sym in MoreTerm do
      begin
        op := sym; GetSym;
        if op = AndSym then Op1 (op, x);

        if op = PowrSym then
          expression(y)
        else
          factor (y);
        Op2 (op, x, y);
      end
  end;

  procedure SimpleExpression (var x: Item);
    var y: Item; op: Symbol;
  begin
    if sym = PlusSym then begin GetSym; term (x) end
    else if sym = MinusSym then
      begin GetSym; term (x); Op1 (MinusSym, x) end
    else term (x);
    while sym in MoreSimpleExp do
      begin op := sym; GetSym;
        if op = OrSym then Op1 (op, x);
        term (y); Op2 (op, x, y)
      end
  end;

  procedure expression (var x: Item);
    var y: Item; op: Symbol;
  begin SimpleExpression (x);
    if sym in MoreExp then
      begin op := sym; GetSym;
        SimpleExpression (y); Relation (op, x, y)
      end
  end;

  procedure param (var fp: Objct);
    var x: Item;
  begin expression (x);
    if IsParam (fp) then
      begin Parameter (x, fp^.tp, fp^.cls); fp := fp^.next end
    else Mark ('too many parameters')
  end;

  procedure CompoundStatement;
  begin
    if sym <> EndSym then {don't try when CompoundStatement is empty}
      begin statement;
        while sym <> EndSym do
          begin
            if sym = SemicolonSym then {skip}
              repeat GetSym until sym <> SemicolonSym
            else Mark (';?');
            if sym <> EndSym then statement;
            if sym in DeclSyms then
              begin Mark ('end?'); break end
          end;
      end;
  end;

  procedure statement;
    var par, obj: Objct; x, y: Item; L: integer;

    procedure sparam (var x: Item);
    begin
      if sym = LparenSym then GetSym else Mark ('(?');
      expression (x);
      if sym = RparenSym then GetSym else Mark (')?')
    end;

  begin { statement }
    obj := guard; {sync}
    if not (sym in FirstStatement) then
      begin Mark ('statement?');
        repeat GetSym
        until sym in FirstStatement + StrongSyms + FollowStatement
      end;
    if sym = IdentSym then
      begin Find (obj); GetSym; MakeItem (x, obj);
        if x.mode in [VarClass, ParClass, FieldClass] then
          begin selector (x);
            if sym = BecomesSym then
              begin GetSym; expression (y); Store (x, y)
              end
            else if sym = EqlSym then
              begin Mark (':= ?'); GetSym; expression (y) end
            else Mark (':=?')
          end
        else if obj^.cls = ProcClass then
          begin par := obj^.dsc;
            if sym = LparenSym then
              begin GetSym;
                if sym = RparenSym then GetSym
                else
                  while true do
                    begin param (par);
                      if sym = CommaSym then GetSym
                      else if sym = RparenSym then
                        begin GetSym; break end
                      else if sym in FollowProcCall + StrongSyms then break
                      else Mark (') or , ?')
                    end
              end;
            if obj^.val < 0 then Mark ('forward call')
            else if not IsParam (par) then Call (x)
            else Mark ('too few parameters')
          end
        else if obj^.cls = SProcClass then
          begin MakeItem (x, obj);
            if obj^.val <= 2 then sparam (y);
            IOCall (x, y);
          end
        else Mark ('invalid assignment or statement')
      end
    else if sym = IfSym then
      begin GetSym; expression (x); CJump (x);
        if sym = ThenSym then GetSym else Mark ('then?');
        statement;
        if sym = ElseSym then
          begin GetSym; l := 0; FJump (L); FixLink (x.a); statement; FixLink (L) end
        else FixLink (x.a)
      end
    else if sym = WhileSym then
      begin GetSym; L := pc; expression (x); CJump (x);
        if sym = DoSym then GetSym else Mark ('do ?');
        statement; BJump (L); FixLink (x.a)
      end
    else if sym = BeginSym then
      begin GetSym; CompoundStatement;
        if sym = EndSym then GetSym else Mark ('end?')
      end;
  end;

  procedure SkipIdents; {skip optional identifiers in program claus}
  begin
    if sym = IdentSym then
      begin GetSym;
        while sym = CommaSym do
          begin GetSym;
            if sym = RparenSym then break;
            if sym = IdentSym then GetSym else Mark ('ident?')
          end
      end
    else Mark ('ident?')
  end;

  procedure IdentList (cls: Class; var first: Objct);
    var obj: Objct;
  begin
    if sym = IdentSym then
      NewObj (first, cls); GetSym;
      while sym = CommaSym do
        begin GetSym;
          if sym = IdentSym then
            begin NewObj (obj, cls); GetSym end
          else Mark ('ident?')
        end;
      if sym = ColonSym then GetSym else Mark (':?')
  end;

  procedure EnumList (cls: Class; var first: Objct);
    var obj: Objct;
  begin
    if sym = IdentSym then
      NewObj (first, cls); GetSym;
      while sym = CommaSym do
        begin GetSym;
          if sym = IdentSym then
            begin NewObj (obj, cls); GetSym end
          else Mark ('ident?')
        end;
  end;

  procedure TypeDecl (var t: Typ);
    var obj, first: Objct; x, y: Item; tp: Typ;
  begin t := intType; {sync}
    if not (sym in FirstType) then
      begin Mark ('type?');
        repeat GetSym until sym in FirstType + FollowType + StrongSyms
      end ;
    if sym = IdentSym then
      begin Find (obj); GetSym;
        if obj^.cls = TypeClass then t := obj^.tp else Mark ('type?')
      end
    else if sym = ArraySym then
      begin GetSym;
        if sym = LbrakSym then GetSym else Mark ('[?');
        expression (x);
        if (x.mode <> ConstClass) or (x.a < 0) then Mark ('bad index');
        if sym = PeriodSym then GetSym else Mark ('.?');
        if sym = PeriodSym then GetSym else Mark ('.?');
        expression (y);
        if (y.mode <> ConstClass) or (y.a < x.a) then Mark ('bad index');
        if sym = RbrakSym then GetSym else Mark (']?');
        if sym = OfSym then GetSym else Mark ('of?');
        TypeDecl (tp); new (t); t^.form := Arry; t^.base := tp;
        t^.lower := x.a;
        t^.len := (y.a - x.a) + 1; t^.size := t^.len * tp^.size
      end
    else if sym = LparenSym then
      begin GetSym;
        new (t); t^.form := Rcrd; t^.size := 0;
        if sym = IdentSym then
          begin EnumList (ConstClass, first); obj := first;
            while obj <> guard do
              begin obj^.tp := t; obj^.val := t^.size;
                t^.size := t^.size + obj^.tp^.size; obj := obj^.next
              end;
          end;
        if sym = RparenSym then GetSym else Mark (')');
      end
    else if sym = RecordSym then
      begin GetSym;
        new (t); t^.form := Rcrd; t^.size := 0; OpenScope;
        repeat
            if sym = IdentSym then
              begin IdentList (FieldClass, first); TypeDecl (tp); obj := first;
                while obj <> guard do
                  begin obj^.tp := tp; obj^.val := t^.size;
                    t^.size := t^.size + obj^.tp^.size; obj := obj^.next
                  end
              end;
            if sym = SemicolonSym then GetSym
            else if sym = IdentSym then Mark ('; ?')
        until not (sym in [SemicolonSym, IdentSym]);
        t^.fields := topScope^.next; CloseScope;
        if sym = EndSym then GetSym else Mark ('end?')
      end
    else Mark ('ident?')
  end;

  procedure declarations (var varsize: integer);
    var obj, first: Objct;
      x: Item; tp: Typ;
  begin {sync}
    if not (sym in DeclSyms+FollowDecl) then
      begin Mark ('declaration?');
        repeat GetSym until sym in DeclSyms+FollowDecl
      end;
    repeat
      if sym = ConstSym then
        begin GetSym;
          while sym = IdentSym do
            begin NewObj (obj, ConstClass); GetSym;
              if sym = EqlSym then GetSym else Mark ('=?');
              expression (x);
              if x.mode = ConstClass then
                begin obj^.val := x.a; obj^.tp := x.tp end
              else Mark ('expression not constant');
              if sym = SemicolonSym then GetSym else Mark (';?')
            end
        end;
      if sym = TypeSym then
        begin GetSym;
          while sym = IdentSym do
            begin NewObj (obj, TypeClass); GetSym;
              if sym = EqlSym then GetSym else Mark ('=?');
              TypeDecl (obj^.tp);
              if sym = SemicolonSym then GetSym else Mark (';?')
            end
        end;
      if sym = VarSym then
        begin GetSym;
          while sym = IdentSym do
            begin IdentList (VarClass, first); TypeDecl (tp); obj := first;
              while obj <> guard do
                begin obj^.tp := tp; obj^.lev := curlev;
                  varsize := varsize + obj^.tp^.size;
                  obj^.val := -varsize; obj^.isAParam := false;
                  obj := obj^.next
                end ;
              if sym = SemicolonSym then GetSym else Mark ('; ?')
            end
        end;
      if sym in [ConstSym, TypeSym, VarSym] then
        Mark ('illegal declaration order')
    until not (sym in [ConstSym, TypeSym, VarSym])
  end;

  procedure ProcedureDecl;
    const marksize = 8;
    var proc, obj: Objct;
      locblksize, parblksize: integer;

    procedure FPSection;
      var obj, first: Objct; tp: Typ; parsize: integer;
    begin
      if sym = VarSym then
        begin GetSym; IdentList (ParClass, first) end
      else IdentList (VarClass, first);
      if sym = IdentSym then
        begin Find (obj); GetSym;
          if obj^.cls = TypeClass then tp := obj^.tp
          else begin Mark ('type?'); tp := intType end
        end
      else begin Mark ('ident?'); tp := intType end;
      if first^.cls = VarClass then
        begin parsize := tp^.size;
          if tp^.form in [Arry, Rcrd] then Mark ('no struct params')
        end
      else parsize := WordSize;
      obj := first;
      while obj <> guard do
        begin obj^.tp := tp;
          parblksize := parblksize + parsize;
          obj := obj^.next
        end
    end;

  begin { ProcedureDecl }
    GetSym;
    if sym = IdentSym then
      begin
        NewObj (proc, ProcClass); GetSym; parblksize := marksize;
        IncLevel (1); OpenScope; proc^.val := -1;
        if sym = LparenSym then
          begin GetSym;
            if sym = RparenSym then GetSym
            else
              begin FPSection;
                while sym = SemicolonSym do
                  begin GetSym; FPSection end ;
                if sym = RparenSym then GetSym else Mark (')?')
              end
          end;
        obj := topScope^.next; locblksize := parblksize;
        while obj <> guard do
          begin
            obj^.lev := curlev;
            if obj^.cls = ParClass then locblksize := locblksize - WordSize
            else locblksize := locblksize - obj^.tp^.size;
            obj^.val := locblksize; obj^.isAParam := true; obj := obj^.next
          end ;
        proc^.dsc := topScope^.next;
        if sym = SemicolonSym then GetSym else Mark (';?');
        locblksize := 0; declarations (locblksize);
        while sym = ProcedureSym do
          begin ProcedureDecl;
            if sym = SemicolonSym then GetSym else Mark (';?')
          end ;
        proc^.val := pc; Enter (locblksize);
        if sym = BeginSym then begin GetSym; CompoundStatement end;
        if sym = EndSym then GetSym else Mark ('end?');
        Return (parblksize - marksize); CloseScope; IncLevel (-1)
      end
  end;

  procedure MainProgram;
    var progid: Identifier; varsize: integer;
  begin write ('  compiling ');
    if sym = ProgramSym then
      begin GetSym; Open; OpenScope; varsize := 0;
        if sym = IdentSym then
          begin progid := id; GetSym; writeln (progid) end
        else Mark ('ident?');
        if sym = LparenSym then
          begin GetSym; SkipIdents;
            if sym = RparenSym then GetSym else Mark (')? ')
          end;
        if sym = SemicolonSym then GetSym else Mark (';?');
        declarations (varsize);
        while sym = ProcedureSym do
          begin ProcedureDecl;
            if sym = SemicolonSym then GetSym else Mark (';?')
          end;
        Header (varsize);
        if sym = BeginSym then begin GetSym; CompoundStatement end;
        if sym = EndSym then GetSym else Mark ('end?');
        if sym <> PeriodSym then Mark ('. ?');
        CloseScope;
        if not error then
          begin Close; writeln ('  code generated', pc :6) end
      end
    else Mark ('program?')
  end;

  procedure Compile;
  begin GetSym; MainProgram
  end;

  procedure Init;
   begin writeln ('Pascal0 Compiler');
    OpenScope;
    PreDef (TypeClass, 1, 'boolean', boolType);
    PreDef (TypeClass, 2, 'integer', intType);
    PreDef (ConstClass, 1, 'true', boolType);
    PreDef (ConstClass, 0, 'false', boolType);
    PreDef (SProcClass, 1, 'read', nil);
    PreDef (SProcClass, 2, 'write', nil);
    PreDef (SProcClass, 3, 'writeln', nil)
  end;

begin {Parser}
  Init; Compile; if not error then Load
end.
