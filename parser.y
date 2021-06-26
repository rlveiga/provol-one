%{
int yylex(); /* remove warning relacionado a C99 */
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>

int valoresArray[26]; /* assumindo variaveis de um caracter de A-Z */
int getValue(char symbol); /* retorna valor de uma variavel dado simbolo */
void setValue(char symbol, int value); /* atualiza valor de uma variavel dado o simbolo e novo valor */
%}

%start line
%union {char id; int number;}

%token programa
%token print
%token ENTRADA
%token SAIDA
%token ENQUANTO
%token FACA
%token FIM
%token COMMA
%token <id> variavel
%token <number> valor
%token INC
%token ZERA

%type <number> line init expressao
%type <id> varlist_entrada varlist_saida cmds atribuicao

%%

line	: programa init {;}

init  : ENTRADA varlist_entrada SAIDA varlist_saida cmds {;}
	;

varlist_entrada : variavel { printf("Program has input %c\n", $1);} |
                  varlist_entrada COMMA variavel { printf("Program has input %c\n", $3);}
  ;

/* Should update to accept only a single return variable for C program */
varlist_saida : variavel { printf("Program will return %c\n", $1);} |
                  varlist_saida COMMA variavel { printf("Program will return %c\n", $3);}
  ;

cmds : atribuicao {;} |
       cmds atribuicao {;} |
       print variavel { printf("%d\n", getValue($2)); } |
       cmds print variavel { printf("%d\n", getValue($3)); }
  ;

atribuicao : variavel '=' variavel { setValue($1, getValue($3)); } |
             variavel '=' valor { setValue($1, $3); } |
             variavel '=' expressao { setValue($1, $3); }
  ;

expressao : valor '+' valor { $$ = $1 + $3; } |
            variavel '+' variavel { $$ = getValue($1) + getValue($3); } |
            variavel '+' valor { $$ = getValue($1) + $3; } |
            valor '+' variavel { $$ = $1 + getValue($3); }
  ;
%%

int getValue(char symbol) {
  int index = symbol - 65;

  return valoresArray[index]; 
}

void setValue(char symbol, int value) {
  int index = symbol - 65;

  valoresArray[index] = value;
}

int main(void) { return yyparse(); }
void yyerror(char *err) { fprintf(stderr, "%s\n", err); }