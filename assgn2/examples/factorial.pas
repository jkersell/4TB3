program factorial;

  var y, z: integer;

  procedure fact (n: integer; var f: integer);
  begin
    if n = 0 then f := 1
    else
      begin fact (n - 1, f); f := f * n end
  end;

begin
  read (y);
  fact (y, z);
  write (z)
end.


