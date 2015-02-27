program multiply;

  var x,y,z: integer;

begin
  read(x); read(y); z := 0;
  while x > 0 do
    begin
      if x mod 2 = 1 then z := z + y;
      y := 2 * y; x := x div 2
    end;
  write(x); write(y); write(z); writeln
end.
