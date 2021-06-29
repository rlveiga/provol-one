# provol-one
Python code generator using Lex/Yacc for INF1022 - Analisadores Léxicos e Sintáticos

## On running the program:
- Make sure both `lex` and `yacc` are available on the command line
- Run `chmod +x ./run.sh && ./run.sh`

## Examples
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
