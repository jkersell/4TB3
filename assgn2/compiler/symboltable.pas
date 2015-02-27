unit symboltable;
interface

uses scanner;

  type
    Class = (HeadClass, VarClass, ParClass, ConstClass, FieldClass, TypeClass,
      ProcClass, SProcClass, RegClass, EmitClass, CondClass);
    Form = (Bool, Int, Arry, Rcrd);
  
    Objct = ^ObjDesc;
    Typ = ^TypeDesc;

    Item = record
      mode: Class;
      lev: integer;
      tp: Typ;
      a, b, c, r, o: integer;
      indirect: boolean; {requires indirect addressing?}
      parSize: integer {parameter size, if procedure}
    end;

    ObjDesc = record
      cls: Class;
      lev: integer;
      next, dsc: Objct;
      tp: Typ;
      name: Identifier;
      val: integer;
      isAParam: boolean;
      parSize: integer
    end;

    TypeDesc = record
      form: Form;
      fields: Objct; {for records}
      base: Typ; {for arrays}
      lower, size, len: integer {for arrays}
    end;

  var
    topScope: Objct; {current scope, where search for an identifier starts}
    guard: Objct; {topScope and universe are linked lists, end with guard}
    boolType, intType: Typ; {predefined types}

  procedure NewObj (var obj: Objct; cls: Class);
  procedure Find (var obj: Objct);
  procedure FindField (var obj: Objct; list: Objct);
  function IsParam (obj: Objct): boolean;
  procedure OpenScope;
  procedure CloseScope;
  procedure PreDef (cl: Class; n: integer; name: Identifier; tp: Typ);

implementation
  var
    universe: Objct; {final scope with only predefined identifiers}  

  procedure NewObj (var obj: Objct; cls: Class);
    var n, x: Objct;
  begin x := topScope; guard^.name := id; {set sentinel for search}
    while x^.next^.name <> id do x := x^.next;
    if x^.next = guard then
      begin
        new (n); n^.lev := 0; n^.name := id; n^.cls := cls; n^.next := guard;
        x^.next := n; obj := n
      end
    else begin obj := x^.next; Mark ('mult def') end
  end;

  procedure Find (var obj: Objct);
    var s, x: Objct;
  begin s := topScope; guard^.name := id;
    while true do
      begin x := s^.next;
        while x^.name <> id do x := x^.next;
        if x <> guard then begin obj := x; break end;
        if s = universe then
          begin obj := x; Mark ('undef'); break end;
        s := s^.dsc
      end
  end;

  procedure FindField (var obj: Objct; list: Objct);
  begin guard^.name := id;
    while list^.name <> id do list := list^.next;
    obj := list
  end;

  function IsParam (obj: Objct): boolean;
  begin IsParam := obj^.isAParam
  end;

  procedure OpenScope;
    var s: Objct;
  begin new (s); s^.lev := 0; s^.cls := HeadClass; s^.dsc := topScope;
    s^.next := guard; topScope := s
  end;

  procedure CloseScope;
  begin topScope := topScope^.dsc
  end;

  procedure PreDef (cl: Class; n: integer; name: Identifier; tp: Typ);
    var obj: Objct;
  begin new (obj); obj^.lev := 0;
    obj^.cls := cl; obj^.val := n; obj^.name := name;
    obj^.tp := tp; obj^.dsc := nil;
    obj^.next := topScope^.next; topScope^.next := obj
  end;

begin
  new (guard); guard^.lev := 0; guard^.cls := VarClass; guard^.tp := intType; guard^.val := 0;
  topScope := nil; OpenScope; universe := topScope 

end.

