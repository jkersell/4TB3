program ReadFile;

var
    myFile: text;
    filename: string;
    c: char;
begin
    filename := 'testFile';
    assign(myFile, filename);
    reset(myFile);
    while not eof(myFile) do
    begin
        read(myFile, c);
        write(c);
    end;
    close(myFile);
end.
