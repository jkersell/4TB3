%{
#include <stdio.h>
%}

%%
[/]\*.*\*[/] ;

[/]{2}.*$    ;

[^/"]+        printf(yytext);

\"(\\.|[^"])*\" printf(yytext);
%%
