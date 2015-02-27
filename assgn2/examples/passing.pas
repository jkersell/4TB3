program passing;

{Demonstrates passing value and reference params}

  var q : array [1..5] of integer; 

  procedure third (z : integer);
  begin
    z := z + 84
  end;

  procedure second (var y : integer);
  begin
    y := y + 4;
    third (y)
  end;

  procedure first (var x : integer);
  begin
    x := x + 9;
    second (x)
  end;

begin
  q[4] := 0;
  first (q[4]);
  write (q[4])
end.

