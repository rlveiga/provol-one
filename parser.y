%{
int yylex(); /* remove warning relacionado a C99 */
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>

int variaveis[26]; /* assumindo variaveis de um caracter de A-Z */
/* TODO int getValue(char symbol); */ /* retorna valor de uma variavel dado simbolo */
/* TODO int updateValue(char symbol, int value); */ /* atualiza valor de uma variavel dado o simbolo e novo valor */
%}

%start line
%union {char id; int number;}

%token programa
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

%type <number> line init
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
       cmds atribuicao {;}
  ;

atribuicao : variavel '=' variavel { printf("%c recebeu o valor de %c\n", $1, $3); } |
             variavel '=' valor { printf("%c recebeu o valor de %d\n", $1, $3); }
%%

int main(void) { return yyparse(); }
void yyerror(char *err) { fprintf(stderr, "%s\n", err); }