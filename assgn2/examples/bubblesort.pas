program bubblesort;

  const maximum = 20;
  
  var x: array [1..maximum] of integer; {array to sort}
    outer, inner, size: integer;

  procedure order (var x, y: integer);
    var h: integer;
  begin
    if x > y then begin h := x; x := y; y := h end
  end;

begin
  {Read unsorted numbers}
  read (size); outer := 1;
  while (outer <= size) and  (outer <= maximum) do
    begin read (x[outer]); outer := outer + 1 end;

  {Sort the array}
  outer := 1;
  while outer < size do
    begin inner := 1;
      while inner <= size - outer do
        begin
          order (x[inner], x[inner+1]);
          inner := inner + 1
        end;
      outer := outer + 1
    end;

  {Print the sorted array}
  outer := 1;
  while outer <= size do
    begin write (x[outer]); outer := outer + 1 end
end.
