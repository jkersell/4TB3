program arithmetic;

  var x, y, q, r: integer;

  procedure QuotRem (x, y: integer; var q, r: integer);
  begin q := 0; r := x;
    while r >= y do { q*y+r=x and r>=y }
      begin r := r - y; q := q + 1
      end
  end;

begin
    {{}My implementation {requires that nested comments be properly terminated. The other option
    is to terminate on the first closing parenthesis but the} assignment {makes it seem like that
    is} not {what} is{} desired.{}}
  read (x); read (y);
  QuotRem (x, y, q, r);
  write (q); write (r); writeln
end.
