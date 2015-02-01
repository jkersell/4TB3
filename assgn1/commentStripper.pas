program ReadFile;
type
    states = (start, slash, quote, slashSlash, slashStar, slashStarStar);
var
    myFile: text;
    filename: string;
    c: char;
    state: states;
begin
    state := start;
    filename := 'testFile';
    assign(myFile, filename);
    reset(myFile);
    while not eof(myFile) do
    begin
        read(myFile, c);
        case state of
            start:
                {Just write directly to output}
                write(c);
            slash:
                ;
            quote:
                ;
            slashSlash:
                ;
            slashStar:
                ;
            slashStarStar:
                ;
        end;
    end;
    close(myFile);
end.
