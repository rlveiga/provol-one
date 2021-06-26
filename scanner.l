%{
  #include "y.tab.h"
%}
%%
"Programa" { return programa; }
"ENTRADA" { return ENTRADA; }
"SAIDA"   { return SAIDA; }
"print"   { return print; }
","       { return COMMA; }
[=+]       { return yytext[0]; }
[A-Z]+    { yylval.id = yytext[0]; return variavel; }
[0-9]+    { yylval.number = atoi(yytext); return valor; }
[ \t\n]   { ; }
.		      { printf("Syntax error\n"); }
%%
int yywrap (void) { return 1; }
