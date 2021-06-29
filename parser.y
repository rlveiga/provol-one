%{
int yylex(); /* remove warning relacionado a C99 */
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE *output_file;

int valoresArray[26]; /* assumindo variaveis de um caracter de A-Z */

int getValue(char symbol); /* retorna valor de uma variavel dado simbolo */
void setValue(char symbol, int value); /* atualiza valor de uma variavel dado o simbolo e novo valor */
void incrementValue(char symbol);
void zeroValue(char symbol);

int tabCount = 1;

int shouldWriteFunctionDeclaration = 1;

int parametersCount = 0;
char functionParameters[10]; /* Accepts up to 10 parameters */

void addFunctionParameter(char symbol);

int returnSymbolCount = 0;
char returnSymbols[10]; /* Accepts up to 10 return values */

void addReturnSymbol(char symbol);

void writeAttributionCommandChar(char symbolA, char symbolB);
void writeAttributionCommandInt(char symbolA, int value);
void writeIncCommand(char symbolA);
void writeZeraCommand(char symbolA);
void writeWhileStatement(char symbol);
void writeIfStatement(char symbolA, char* condition, char symbolB);

void onProgramEnd();
%}

%start line
%union {char id; int number;}

%token programa
%token print
%token ENTRADA
%token SAIDA
%token ENQUANTO
%token SE
%token FACA
%token FIM
%token COMMA
%token IS
%token <id> variavel
%token <number> valor
%token INC
%token ZERA

%type <number> line init expressao
%type <id> varlist_entrada varlist_saida cmds atribuicao enquanto_condicao se_condicao
%%

line	: programa init {;}

init  : ENTRADA varlist_entrada SAIDA varlist_saida cmds FIM { onProgramEnd(); }
	;

varlist_entrada : variavel { addFunctionParameter($1); } |
                  varlist_entrada COMMA variavel { addFunctionParameter($3); }
  ;

varlist_saida : variavel { addReturnSymbol($1); } |
                varlist_saida COMMA variavel { addReturnSymbol($3); }
  ;

cmds : atribuicao {;} |
       cmds atribuicao {;} |
       print variavel { printf("%d\n", getValue($2)); } |
       cmds print variavel { printf("%d\n", getValue($3)); } |
       ENQUANTO enquanto_condicao FACA cmds FIM { tabCount--; } |
       cmds ENQUANTO enquanto_condicao FACA cmds FIM { tabCount--; } |
       SE se_condicao FACA cmds FIM { printf("Current tab count %d\n", tabCount); tabCount = tabCount - 1; printf("New tab count %d\n", tabCount); } |
       cmds SE se_condicao FACA cmds FIM { printf("Current tab count %d\n", tabCount); tabCount = tabCount - 1; printf("New tab count %d\n", tabCount); } |
       INC '(' variavel ')' { incrementValue($3); writeIncCommand($3); } |
       cmds INC '(' variavel ')' { incrementValue($4); writeIncCommand($4); } |
       ZERA '(' variavel ')' { zeroValue($3); writeZeraCommand($3); } |
       cmds ZERA '(' variavel ')' { zeroValue($4); writeZeraCommand($4); }
  ;

enquanto_condicao : variavel { writeWhileStatement($1); }
  ;

se_condicao : variavel IS variavel { writeIfStatement($1, "==", $3); }
  ;

atribuicao : variavel '=' variavel { setValue($1, getValue($3)); writeAttributionCommandChar($1, $3); } |
             variavel '=' valor { setValue($1, $3); writeAttributionCommandInt($1, $3); } |
             variavel '=' expressao { setValue($1, $3); writeAttributionCommandInt($1, $3); }
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

void addFunctionParameter(char symbol) {
  functionParameters[parametersCount] = symbol;
  parametersCount++;
}

void writeFunctionDeclaration() {
  if(shouldWriteFunctionDeclaration) {
    fprintf(output_file, "def main(");

    for(int i = 0; i < parametersCount; i++) {
      fputc(functionParameters[i], output_file);

      if(i != parametersCount - 1) {
        fprintf(output_file, ", ");
      }

      else {
        fprintf(output_file, "):\n\t");
      }
    }

    shouldWriteFunctionDeclaration = 0;
  }
}

void writeAttributionCommandChar(char symbolA, char symbolB) {  
  printf("Using tab of size %d\n", tabCount);
  fprintf(output_file, "%c = %c\n", symbolA, symbolB);

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void writeAttributionCommandInt(char symbolA, int value) {  
  fprintf(output_file, "%c = %d\n", symbolA, value);

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void writeWhileStatement(char symbol) {  
  fprintf(output_file, "while %c:\n", symbol);

  tabCount++;

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void writeIfStatement(char symbolA, char* condition, char symbolB) {  
  fprintf(output_file, "if %c %s %c:\n", symbolA, condition, symbolB);

  tabCount++;

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void writeIncCommand(char symbol) {  
  fprintf(output_file, "%c += 1\n", symbol);

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void writeZeraCommand(char symbol) {  
  fprintf(output_file, "%c = 0\n", symbol);

  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
}

void addReturnSymbol(char symbol) {
  writeFunctionDeclaration();

  returnSymbols[returnSymbolCount] = symbol;
  returnSymbolCount++;
}

void onProgramEnd() {
  fprintf(output_file, "\n\treturn ");

  for(int i = 0; i < returnSymbolCount; i++) {
    fputc(returnSymbols[i], output_file);

    if(i != returnSymbolCount - 1) {
      fprintf(output_file, ", ");
    }
  }

  fclose(output_file);
}

int main(void) {
  output_file = fopen("./outputs/generated.py", "w");

  return yyparse(); 
}

void yyerror(char *err) { fprintf(stderr, "%s\n", err); }