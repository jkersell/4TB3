program arithmetic;

  var x, y, q, r: integer;

  procedure QuotRem (x, y: integer; var q, r: integer);
  begin q := 0; r := x;
    while r >= y do { q*y+r=x and r>=y }
      begin r := r - y; q := q + 1
      end
  end;

begin
    {{z := p;} this code fails so it's commented twice to make sure it's really gone}
  read (x); read (y);
  QuotRem (x, y, q, r);
  write (q); write (r); writeln
end.
