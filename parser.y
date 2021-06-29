%{
int yylex(); /* remove warning relacionado a C99 */
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE *output_file;

int valoresArray[26]; /* assumindo variaveis de um caracter de A-Z */

int tabCount = 1;

int shouldWriteFunctionDeclaration = 1; /* evita problema de declaração duplicada */
char currentAttributionSymbol; /* auxilia na escrita de atribuições */

int parametersCount = 0;
char functionParameters[10]; /* aceita até 10 parametros */

void addFunctionParameter(char symbol);

int returnSymbolCount = 0;
char returnSymbols[10]; /* aceita até 10 valores de retorno */

void addReturnSymbol(char symbol);

void writeAttributionCommandChar(char symbolA, char symbolB);
void writeAttributionCommandInt(char symbolA, int value);
void writeAttributionCommandExpressionIntInt(int valueA, char* expression, int valueB);
void writeAttributionCommandExpressionCharChar(char symbolA, char* expression, char symbolB);
void writeAttributionCommandExpressionIntChar(int valueA, char* expression, char symbol);
void writeAttributionCommandExpressionCharInt(char symbol, char* expression, int value);
void writeIncCommand(char symbolA);
void writeZeraCommand(char symbolA);
void writeWhileStatement(char symbol);
void writeIfStatement(char symbolA, char* condition, char symbolB);
void writeIfStatementCharInt(char symbol, char* condition, int value);
void writeIfStatementIntChar(int value, char* condition, char symbol);
void writeElseStatement();
void writeForStatement(int numrept);

void onProgramEnd();
%}

%start line
%union {char id; int number;}

%token programa
%token ENTRADA
%token SAIDA
%token ENQUANTO
%token SE
%token SENAO
%token FACA
%token VEZES
%token FIM
%token COMMA
%token IS
%token ISNOT
%token LESSTHAN
%token LESSTHANEQ
%token GREATERTHAN
%token GREATERTHANEQ
%token <id> variavel
%token <number> valor
%token INC
%token ZERA

%type <number> line init
/* %type <number> expressao */
%type <id> varlist_entrada varlist_saida cmds atribuicao enquanto_condicao se_condicao
%%

line	: programa init {;}

init  : ENTRADA varlist_entrada SAIDA varlist_saida cmds FIM { onProgramEnd(); }
	;

/* uso de varlist_entrada e varlist_saida facilita a escrita da declaração de função e seu retorno */
varlist_entrada : variavel { addFunctionParameter($1); } |
                  varlist_entrada COMMA variavel { addFunctionParameter($3); }
  ;

varlist_saida : variavel { addReturnSymbol($1); } |
                varlist_saida COMMA variavel { addReturnSymbol($3); }
  ;

cmds : atribuicao {;} |
       cmds atribuicao {;} |
       ENQUANTO enquanto_condicao FACA cmds FIM { tabCount--; } |
       cmds ENQUANTO enquanto_condicao FACA cmds FIM { tabCount--; } |
       FACA valor VEZES { writeForStatement($2); } cmds FIM { tabCount--; } |
       cmds FACA valor VEZES { writeForStatement($3); } cmds FIM { tabCount--; } |
       SE se_condicao FACA cmds FIM { tabCount--; } |
       cmds SE se_condicao FACA cmds FIM { tabCount--; } |
       SE se_condicao FACA cmds FIM { tabCount--; } SENAO { writeElseStatement(); } cmds FIM { tabCount--; } |
       cmds SE se_condicao FACA cmds FIM { tabCount--; } SENAO { writeElseStatement(); } cmds FIM { tabCount--; } |
       INC '(' variavel ')' { writeIncCommand($3); } |
       cmds INC '(' variavel ')' { writeIncCommand($4); } |
       ZERA '(' variavel ')' { writeZeraCommand($3); } |
       cmds ZERA '(' variavel ')' { writeZeraCommand($4); }
  ;

enquanto_condicao : variavel { writeWhileStatement($1); }
  ;

se_condicao : variavel IS variavel { writeIfStatement($1, "==", $3); } |
              variavel IS valor { writeIfStatementCharInt($1, "==", $3); } |
              valor IS variavel { writeIfStatementIntChar($1, "==", $3); } |
              variavel ISNOT variavel { writeIfStatement($1, "!=", $3); } |
              variavel ISNOT valor { writeIfStatementCharInt($1, "!=", $3); } |
              valor ISNOT variavel { writeIfStatementIntChar($1, "!=", $3); } |
              variavel LESSTHAN variavel { writeIfStatement($1, "<", $3); } |
              variavel LESSTHAN valor { writeIfStatementCharInt($1, "<", $3); } |
              valor LESSTHAN variavel { writeIfStatementIntChar($1, "<", $3); } |
              variavel LESSTHANEQ variavel { writeIfStatement($1, "<=", $3); } |
              variavel LESSTHANEQ valor { writeIfStatementCharInt($1, "<=", $3); } |
              valor LESSTHANEQ variavel { writeIfStatementIntChar($1, "<=", $3); } |
              variavel GREATERTHAN variavel { writeIfStatement($1, ">", $3); } |
              variavel GREATERTHAN valor { writeIfStatementCharInt($1, ">", $3); } |
              valor GREATERTHAN variavel { writeIfStatementIntChar($1, ">", $3); } |
              variavel GREATERTHANEQ variavel { writeIfStatement($1, ">=", $3); } |
              variavel GREATERTHANEQ valor { writeIfStatementCharInt($1, ">=", $3); } |
              valor GREATERTHANEQ variavel { writeIfStatementIntChar($1, ">=", $3); }
  ;

atribuicao : variavel '=' variavel { writeAttributionCommandChar($1, $3); } |
             variavel '=' valor { writeAttributionCommandInt($1, $3); } /* |
              variavel '=' expressao { currentAttributionSymbol = $1; } */
  ;

/* removi o uso de expressoes pois apresentavam um problema, não consegui escrever o lado esquerdo da atribuicao */
/* expressao : valor '+' valor { writeAttributionCommandExpressionIntInt($1, "+", $3); } |
            variavel '+' variavel { writeAttributionCommandExpressionCharChar($1, "+", $3); } |
            variavel '+' valor { writeAttributionCommandExpressionCharInt($1, "+", $3); } |
            valor '+' variavel { writeAttributionCommandExpressionIntChar($1, "+", $3); } |
            valor '-' valor { writeAttributionCommandExpressionIntInt($1, "-", $3); } |
            variavel '-' variavel { writeAttributionCommandExpressionCharChar($1, "-", $3); } |
            variavel '-' valor { writeAttributionCommandExpressionCharInt($1, "-", $3); } |
            valor '-' variavel { writeIfStatementIntChar($1, "-", $3); } |
            valor '*' valor { writeAttributionCommandExpressionIntInt($1, "*", $3); } |
            variavel '*' variavel { writeAttributionCommandExpressionCharChar($1, "*", $3); } |
            variavel '*' valor { writeAttributionCommandExpressionCharInt($1, "*", $3); } |
            valor '*' variavel { writeIfStatementIntChar($1, "*", $3); } |
            valor '/' valor { writeAttributionCommandExpressionIntInt($1, "/", $3); } |
            variavel '/' variavel { writeAttributionCommandExpressionCharChar($1, "/", $3); } |
            variavel '/' valor { writeAttributionCommandExpressionCharInt($1, "/", $3); } |
            valor '/' variavel { writeIfStatementIntChar($1, "/", $3); }
  ; */
%%

// Identação é fundamental na interpretação de Python
void createTabIndentation() {
  for(int i = 0; i < tabCount; i++) {
    fprintf(output_file, "\t");
  }
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
        fprintf(output_file, "):\n");
      }
    }

    shouldWriteFunctionDeclaration = 0;
  }
}

void writeAttributionCommandChar(char symbolA, char symbolB) {
  createTabIndentation();  

  fprintf(output_file, "%c = %c\n", symbolA, symbolB);
}

void writeAttributionCommandInt(char symbolA, int value) {  
  createTabIndentation();

  fprintf(output_file, "%c = %d\n", symbolA, value);
}


void writeAttributionCommandExpressionIntInt(int valueA, char* expression, int valueB) {
  createTabIndentation();

  fprintf(output_file, "%c = %d %s %d\n", currentAttributionSymbol, valueA, expression, valueB);
}

void writeAttributionCommandExpressionCharChar(char symbolA, char* expression, char symbolB) {
  createTabIndentation();

  fprintf(output_file, "%c = %c %s %c\n", currentAttributionSymbol, symbolA, expression, symbolB);
}

void writeAttributionCommandExpressionCharInt(char symbol, char* expression, int value) {
  createTabIndentation();

  fprintf(output_file, "%c = %c %s %d\n", currentAttributionSymbol, symbol, expression, value);
}


void writeAttributionCommandExpressionIntChar(int value, char* expression, char symbol) {
  createTabIndentation();

  fprintf(output_file, "%c = %d %s %c\n", currentAttributionSymbol, value, expression, symbol);
}

void writeWhileStatement(char symbol) {  
  createTabIndentation();

  fprintf(output_file, "while %c:\n", symbol);

  tabCount++;
}

void writeIfStatement(char symbolA, char* condition, char symbolB) {  
  createTabIndentation();

  fprintf(output_file, "if %c %s %c:\n", symbolA, condition, symbolB);

  tabCount++;
}

void writeIfStatementCharInt(char symbol, char* condition, int value) {  
  createTabIndentation();

  fprintf(output_file, "if %c %s %d:\n", symbol, condition, value);

  tabCount++;
}

void writeIfStatementIntChar(int value, char* condition, char symbol) {  
  createTabIndentation();

  fprintf(output_file, "if %d %s %c:\n", value, condition, symbol);

  tabCount++;
}

void writeElseStatement() {  
  createTabIndentation();

  fprintf(output_file, "else:\n");

  tabCount++;
}

void writeForStatement(int numrept) {
  createTabIndentation();

  fprintf(output_file, "for i in range(%d):\n", numrept);

  tabCount++;
}

void writeIncCommand(char symbol) {  
  createTabIndentation();

  fprintf(output_file, "%c += 1\n", symbol);
}

void writeZeraCommand(char symbol) {  
  createTabIndentation();

  fprintf(output_file, "%c = 0\n", symbol); 
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
  exit(1);
}

int main(void) {
  output_file = fopen("./outputs/generated.py", "w");

  return yyparse(); 
}

void yyerror(char *err) { fprintf(stderr, "%s\n", err); }