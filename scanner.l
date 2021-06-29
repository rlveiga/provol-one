%{
  #include "y.tab.h"
%}
%%
"Programa"      { return programa; }
"ENTRADA"       { return ENTRADA; }
"SAIDA"         { return SAIDA; }
"ENQUANTO"      { return ENQUANTO; }
"SE"            { return SE; }
"SENAO"         { return SENAO; }
"FACA"          { return FACA; }
"VEZES"         { return VEZES; }
"INC"           { return INC; }
"ZERA"          { return ZERA; }
"FIM"           { return FIM; }
","             { return COMMA; }
"=="            { return IS; }
"!="            { return ISNOT; }
"<"             { return LESSTHAN; }
"<="            { return LESSTHANEQ; }
">"             { return GREATERTHAN; }
">="            { return GREATERTHANEQ; }
[=+\-*/()]      { return yytext[0]; }
[A-Z]+          { yylval.id = yytext[0]; return variavel; }
[0-9]+          { yylval.number = atoi(yytext); return valor; }
[ \t\n]         { ; }
.		            { printf("Syntax error\n"); }
%%
int yywrap (void) { return 1; }
