grammar Pascal0;

@members {
    int indent_level = 0;

    void print(String line) {
       System.out.println("Indent level: " + indent_level + ": " + line);
    }
}

program     : 'program' Ident ('(' Ident (',' Ident)* ')')? ';' declarations compoundstatement ;

selector            : ('.' Ident | '[' expression ']')* ;
expression          : simpleexpression (('=' | '<>' | '<' | '<=' | '>' | '>=') simpleexpression)* ;
simpleexpression    : ('+' | '-')? term (('+' | '-' | 'or') term)* ;

factor              : Ident selector | Integer | '(' expression ')' | 'not' factor ;
term                : factor (('*' | 'div' | 'mod' | 'and') factor)* ;

assignment          : Ident selector ':=' expression ;
actualparameters    : '(' (expression (',' expression)*)? ')' ;
procedurecall       : Ident selector (actualparameters)? ;
begin               : 'begin' { indent_level++; } ;
end                 : 'end' { indent_level--; } ;
compoundstatement   : begin statement (';' statement)* end ;
ifstatement         : 'if' expression 'then' statement ('else' statement)? ;
whilestatement      : 'while' expression 'do' statement ;
statement           : (assignment { print($assignment.text); } |
                       procedurecall {  print($procedurecall.text); } |
                       compoundstatement {  print($compoundstatement.text); } |
                       ifstatement {  print($ifstatement.text); } |
                       whilestatement { print($whilestatement.text); }) ;

identlist           : Ident (',' Ident)* ;
arraytype           : 'array' '[' expression '..' expression ']' 'of' type ;
fieldlist           : (identlist ':' type)? ;
recordtype          : 'record' fieldlist (';' fieldlist)* 'end' ;
type                : Ident | arraytype | recordtype ;
fpsection           : ('var')? identlist ':' type ;
formalparameters    : '(' (fpsection (';' fpsection)*)? ')' ;
proceduredeclaration     : 'procedure' Ident (formalparameters)? ';' declarations compoundstatement ;
declarations        : ('const' (Ident '=' expression ';')*)?
                      ('type' (Ident '=' type ';')*)?
                      ('var' (identlist ':' type ';')*)?
                      (proceduredeclaration ';')* ? ;

Ident               : LETTER (LETTER | DIGIT)* ;
Integer             : DIGIT+ ;
fragment LETTER     : [a-zA-Z] ;
fragment DIGIT      : [0-9] ;

WS                  : [ \t\n\r]+ -> skip ;
