# provol-one
Gerador de código Python utilizando Lex/Yacc para o Trabalho Final de INF1022 - Analisadores Léxicos e Sintáticos

https://github.com/rlveiga/provol-one

## Como rodar o programa:
- Garanta que `lex` e `yacc` estão disponíveis pela linha de comando\
- Clone este repositório
- Na pasta do projeto clonado, rode `chmod +x ./run.sh && ./run.sh`
- Rode `./parser` e comece a escrever o programa Provol-One desejado

O arquivo `run.sh` gera os arquivo `y.tab.c`, `y.tab.h`, `y.tab.o`, `lex.yy.c`, `lex.yy.o` e o executável `parser`

## Exemplos
1. Programa Provol-One utilizando condições **se/senão** (if/then) e **repetição** (for...in)
```
Programa ENTRADA X, Y
SAIDA R
SE X == Y FACA
FACA 10 VEZES
INC(R)
FIM
FIM
SENAO
ZERA(R)
FIM
FIM
```

Arquivo gerado (./outputs/generated.py):

```python
def main(X, Y):
	if X == Y:
		for i in range(10):
			R += 1
	else:
		R = 0

	return R
```

2. Programa Provol-One utilizando condição **enquanto** (while)
```
Programa ENTRADA A
SAIDA B
B = 0
ENQUANTO A FACA
INC(B)
SE A == B FACA
ZERA(A)
FIM
FIM
FIM
```

Arquivo gerado

```python
def main(A):
	B = 0
	while A:
		B += 1
		if A == B:
			A = 0

	return B
```
