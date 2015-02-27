program fibonacci;

  var n: integer;

  procedure fib (a, b, i, n: integer);
  begin
    if i < n then
      begin write (a + b); fib (a + b, a, i + 1, n) end
  end;

begin
  read (n);
  fib (0, 1, 0, n)
end.
