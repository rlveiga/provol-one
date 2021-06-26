%{
int yylex(); /* remove warning relacionado a C99 */
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int valoresArray[26]; /* assumindo variaveis de um caracter de A-Z */
int getValue(char symbol); /* retorna valor de uma variavel dado simbolo */
void setValue(char symbol, int value); /* atualiza valor de uma variavel dado o simbolo e novo valor */
void incrementValue(char symbol);
void zeroValue(char symbol);

char functionDeclaration[100] =  "def main(";

int parametersCount = 0;
char functionParameters[10]; /* Accepts up to 10 parameters */

void addFunctionParameter(char symbol);
void formatFunctionDeclaration();
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

varlist_entrada : variavel { addFunctionParameter($1); } |
                  varlist_entrada COMMA variavel { addFunctionParameter($3); }
  ;

/* Should update to accept only a single return variable for C program */
varlist_saida : variavel { formatFunctionDeclaration(); } |
                  varlist_saida COMMA variavel { formatFunctionDeclaration(); }
  ;

cmds : atribuicao {;} |
       cmds atribuicao {;} |
       print variavel { printf("%d\n", getValue($2)); } |
       cmds print variavel { printf("%d\n", getValue($3)); } |
       INC '(' variavel ')' { incrementValue($3); } |
       cmds INC '(' variavel ')' { incrementValue($4); } |
       ZERA '(' variavel ')' { zeroValue($3); } |
       cmds ZERA '(' variavel ')' { zeroValue($4); }
  ;

atribuicao : variavel '=' variavel { setValue($1, getValue($3)); } |
             variavel '=' valor { setValue($1, $3); } |
             variavel '=' expressao { setValue($1, $3); }
  ;

expressao : valor '+' valor { $$ = $1 + $3; } |
            variavel '+' variavel { $$ = getValue($1) + getValue($3); } |
            variavel '+' valor { $$ = getValue($1) + $3; } |
            valor '+' variavel { $$ = $1 + getValue($3); } |
            valor '-' valor { $$ = $1 - $3; } |
            variavel '-' variavel { $$ = getValue($1) - getValue($3); } |
            variavel '-' valor { $$ = getValue($1) - $3; } |
            valor '-' variavel { $$ = $1 - getValue($3); } |
            valor '*' valor { $$ = $1 * $3; } |
            variavel '*' variavel { $$ = getValue($1) * getValue($3); } |
            variavel '*' valor { $$ = getValue($1) * $3; } |
            valor '*' variavel { $$ = $1 * getValue($3); } |
            valor '/' valor { $$ = $1 / $3; } |
            variavel '/' variavel { $$ = getValue($1) / getValue($3); } |
            variavel '/' valor { $$ = getValue($1) / $3; } |
            valor '/' variavel { $$ = $1 / getValue($3); }
  ;
%%

void addFunctionParameter(char symbol) {
  functionParameters[parametersCount] = symbol;
  parametersCount++;
}

void formatFunctionDeclaration() {
  int currentIndex = 9;

  for(int i = 0; i < parametersCount; i++) {
    strncat(functionDeclaration, &functionParameters[i], 1);

    if(i != parametersCount - 1) {
      strncat(functionDeclaration, ", ", 2);
    }

    else {
      strncat(functionDeclaration, "):", 2);
    }
  }

  printf("%s\n", functionDeclaration);
}

int getValue(char symbol) {
  int index = symbol - 65;

  return valoresArray[index]; 
}

void setValue(char symbol, int value) {
  int index = symbol - 65;

  valoresArray[index] = value;
}

void incrementValue(char symbol) {
  int newValue = getValue(symbol) + 1;
  setValue(symbol, newValue);
}

void zeroValue(char symbol) {
  setValue(symbol, 0);
}

int main(void) { return yyparse(); }
void yyerror(char *err) { fprintf(stderr, "%s\n", err); }