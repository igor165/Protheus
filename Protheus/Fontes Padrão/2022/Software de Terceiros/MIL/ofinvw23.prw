// �����������������ͻ
// � Versao � 2      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW23.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW23   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o do Layout referente aquisi��o de Autos   			|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW23(lEnd, cArquivo)
//
Local nCurArq

Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}
//
aAdd(aLayoutFN0, {"C",	3	,0,	001," "}) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	5	,0,	004," "}) // "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	179, 0,	009," "}) // "CABE�ALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188," "}) // "LAYOUT VERS�O (Fixo: 040501)"})

aAdd(aLayoutFN1, {	"C",3,0,001," "}) //"TIPO DE REGISTRO (FCR)"})
aAdd(aLayoutFN1, {	"N",5,0,004," "}) //"SUB-C�DIGO DO REGISTRO (Fixo=32101)"})
aAdd(aLayoutFN1, {	"N",6,0,009," "}) //"N�MERO DA NOTA FISCAL FATURA"})
aAdd(aLayoutFN1, {	"N",2,0,015," "}) //"SUFIXO DA NOTA"})
aAdd(aLayoutFN1, {	"D",8,0,017," "}) //"DATA DE EMISS�O (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"D",8,0,025," "}) //"DATA DO PRIMEIRO VENCIMENTO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"D",8,0,033," "}) //"DATA DO SEGUNDO VENCIMENTO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"N",15,2,041," "}) //"VALOR DA DUPLICATA"})
aAdd(aLayoutFN1, {	"N",15,2,056," "}) //"VALOR PAGO"})
aAdd(aLayoutFN1, {	"N",15,2,071," "}) //"SALDO DEVEDOR"})
aAdd(aLayoutFN1, {	"N",15,2,086," "}) //"VALOR DO ADICIONAL PAGO"})
aAdd(aLayoutFN1, {	"N",15,2,101," "}) //"VALOR DO ACR�SCIMO"})
aAdd(aLayoutFN1, {	"C",2,0,116," "}) //"C�DIGO DE CONDI��O DA NOTA FISCAL"})
aAdd(aLayoutFN1, {	"D",8,0,118," "}) //"DATA DA OPERA��O (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"C",4,0,126," "}) //"TIPO DE DOCUMENTO"})
aAdd(aLayoutFN1, {	"C",40,0,130," "}) //"DESCRI��O DO TIPO DE DOCUMENTO"})
aAdd(aLayoutFN1, {	"C",24,0,170," "}) //"BRANCOS"})

aAdd(aLayoutFN2, {"C",	3	,0,	001," "}) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	5	,0,	004," "}) // "SUB-C�DIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	185 ,0,	009," "}) // "CABE�ALHO FINAL A SER IMPRESSO"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// La�o em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o pr�ximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	//
	nPos = Len(cArquivo)
	if nPos = 0
		lAbort = .t.
		return
	endif
	// Processamento para Arquivos TXT planos
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		loop
	endif
	//
	nTotRec := FT_FLastRec()
	//
	nLinhArq := 0
	While !FT_FEof()
		cStr := FT_FReadLN()
		nLinhArq++
		// Informa��es extra�das da linha do arquivo de importa��o ficam no vetor aInfo
		if Left(cStr,8)=="FCR32100"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,8)=="FCR32101"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,8)=="FCR32102"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,8) $ "FCR32100.FCR32101.FCR32102"
			GrvInfo(aInfo)
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa��o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
Local ni
//
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif
if aInfo[2] == 32100
	For ni := 1 to Len(Alltrim(aInfo[3])) STEP 70
		@li ++ ,1 psay SUBS(Alltrim(aInfo[3]),ni,70)
	next
elseif aInfo[2] == 32101
	cSufixoNF := IIF(aInfo[4] == 0,STR0021,IIF(aInfo[4] == 1,STR0022,STR0023))
	@li++ ,1 psay  Alltrim(STR(aInfo[3])) + " - " + cSufixoNF
	@li++ ,1 psay  STR0024 + dtoc(aInfo[5])
	@li++ ,1 psay  STR0025 + dtoc(aInfo[6])
	@li++ ,1 psay  STR0026 + dtoc(aInfo[7])
	@li++ ,1 psay  STR0027 + dtoc(aInfo[14])
	@li++ ,1 psay  STR0028 + Transform(aInfo[8],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0029 + Transform(aInfo[9],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0030 + Transform(aInfo[10],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0031 + Transform(aInfo[11],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0032 + Transform(aInfo[12],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0033 + Alltrim(aInfo[13])
	@li++ ,1 psay  aInfo[15] + " - " + aInfo[16]
elseif aInfo[2] == 32102
	For ni := 1 to Len(Alltrim(aInfo[3])) STEP 70
		@li ++ ,1 psay SUBS(Alltrim(aInfo[3]),ni,70)
	next
endif

return
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 ���
����������������������������������������������������������������������������͹��
���Descricao� Monta vetores a partir de uma descri��o de layout e da linha de���
���         � importa��o EDI                                                 ���
����������������������������������������������������������������������������͹��
��� Retorno � aRet - Valores extra�dos da linha                              ���
���         �        Se der erro o vetor retorna {}                          ���
����������������������������������������������������������������������������͹��
���Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) ���
���         � aLayout[n,2] = Tamanho do Campo                                ���
���         � aLayout[n,3] = Quantidade de Decimais do Campo                 ���
���         � aLayout[n,4] = Posi��o Inicial do Campo na Linha               ���
���         �                                                                ���
���         � cLinhaEDI    = Linha para extra��o das informa��es             ���
����������������������������������������������������������������������������͹��
���                                                                          ���
���  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    ���
���                                                                          ���
���  aAdd(aLayout,{"C",10,0,1})                                              ���
���  aAdd(aLayout,{"C",20,0,11})                                             ���
���  aAdd(aLayout,{"N",5,2,31})                                              ���
���  aAdd(aLayout,{"N",4,0,36})                                              ���
���                        1         2         3                             ���
���               123456789012345678901234567890'123456789                    ���
���  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    ���
���                                                                          ���
���  No caso acima o retorno seria:                                          ���
���  aRet[1] - "Jose Silva"                                                  ���
���  aRet[2] - "Vendedor Externo"                                            ���
���  aRet[3] - 123,12                                                        ���
���  aRet[4] - 1234                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2

for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	if nPosIni + nTamanho - 1 > Len(cLinhaEDI)
		return {}
	endif
	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto) / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,4)
		if ctod(cStrTexto) == ctod("  /  /  ")
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
