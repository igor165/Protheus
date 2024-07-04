// �����������������ͻ
// � Versao � 3      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW31.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW31   | Autor | Thiago                | Data | 02/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | FA3 - Nota Fiscal e Nota de D�bito em Aberto.                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW31(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayoutFA3 := {}
//
aAdd(aLayoutFA3, { "C", 3 , 0, 001," " }) // "TIPO DE REGISTRO (FA3)" })
aAdd(aLayoutFA3, { "N", 9 , 0, 004," " }) // "N�MERO DA NOTA" })
aAdd(aLayoutFA3, { "N", 2 , 0, 013," " }) // "SUFIXO DA NOTA" })
aAdd(aLayoutFA3, { "N", 1 , 0, 015," " }) // "TIPO DA NOTA" })
aAdd(aLayoutFA3, { "D", 8 , 0, 016," " }) // "DATA DE EMISS�O" })
aAdd(aLayoutFA3, { "D", 8 , 0, 024," " }) // "DATA DO VENCIMENTO" })
aAdd(aLayoutFA3, { "N",15 , 2, 032," " }) // "VALOR DA NOTA" })
aAdd(aLayoutFA3, { "N",15 , 2, 047," " }) // "SALDO DEVEDOR" })
aAdd(aLayoutFA3, { "N",15 , 2, 062," " }) // "VALOR DO DESCONTO" })
aAdd(aLayoutFA3, { "N",15 , 2, 077," " }) // "VALOR DO ACR�SCIMO" })
aAdd(aLayoutFA3, { "D", 8 , 0, 092," " }) // "DATA PAGAMENTO PARCIAL" })
aAdd(aLayoutFA3, { "N", 6 , 0, 100," " }) // "DOCUMENTO DA BANC�RIA" })
aAdd(aLayoutFA3, { "D", 8 , 0, 106," " }) // "DATA DO PRIMEIRO VENCIMENTO" })
aAdd(aLayoutFA3, { "C", 1 , 0, 114," " }) // "N�MERO DA F�BRICA" })
aAdd(aLayoutFA3, { "C", 1 , 0, 115," " }) // "SITUA��O DA NOTA" })
aAdd(aLayoutFA3, { "C", 4 , 0, 116," " }) // "TIPO DE DOCUMENTO" })
aAdd(aLayoutFA3, { "C",40 , 0, 120," " }) // "DESCRI��O DO TIPO DE DOCUMENTO" })
aAdd(aLayoutFA3, { "C",34 , 0, 160," " }) // "BRANCOS" })
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
		if Left(cStr,3)=="FA3"
			aInfo := ExtraiEDI(aLayoutFA3,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,3)=="FA3"
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
//
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Titulo := STR0055
Cabec1 := STR0056
Cabec2 := ""
NomeProg := "OFINVW31"

cSufNota := "N/D"
cSufNota := IIF(aInfo[3]==00,STR0021,cSufNota)
cSufNota := IIF(aInfo[3]==01,STR0022,cSufNota)
cSufNota := IIF(aInfo[3]>=02 .AND. aInfo[4] <=30,STR0023,cSufNota)
cSufNota := IIF(aInfo[3]==22,STR0024,cSufNota)
cSufNota := IIF(aInfo[3]==44,STR0025,cSufNota)
cSufNota := IIF(aInfo[3]==55,STR0026,cSufNota)
cSufNota := IIF(aInfo[3]==66,STR0027,cSufNota)
cSufNota := IIF(aInfo[3]==77,STR0028,cSufNota)
cSufNota := IIF(aInfo[3]==88,STR0029,cSufNota)
cSufNota := IIF(aInfo[3]==99,STR0030,cSufNota)

cTipNota := "N/D"
cTipNota := IIF(aInfo[4]==1,STR0031,cTipNota)
cTipNota := IIF(aInfo[4]==2,STR0032,cTipNota)
cTipNota := IIF(aInfo[4]==3,STR0033,cTipNota)
cTipNota := IIF(aInfo[4]==6,STR0034,cTipNota)

cFabrica := "N/D"
cFabrica := IIF(VAL(aInfo[14])==1,STR0035,cFabrica)
cFabrica := IIF(VAL(aInfo[14])==53,STR0036,cFabrica)
cFabrica := IIF(VAL(aInfo[14])==4,STR0037,cFabrica)
cFabrica := IIF(VAL(aInfo[14])==5,STR0038,cFabrica)

cSituaNF := IIF(aInfo[15]=="I",STR0039,STR0040)

if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0041 + Alltrim(STR(nLinhArq))
endif
//
cData :=  Left(dtoc(aInfo[5])+SPACE(10),10)
cDt := Left(dtoc(aInfo[6])+SPACE(10),10)
cDtParc := Left(dtoc(aInfo[11])+SPACE(10),10)
cDtVento := Left(dtoc(aInfo[13])+SPACE(10),10)
/*
@li ++ ,1 psay STR0042 + Alltrim(str(aInfo[2]))+ "/" + cSufNota+ "("+cTipNota+")"
@li ++ ,1 psay STR0043 + cData + " / "+ cDt
@li ++ ,1 psay STR0044 + cDtParc
@li ++ ,1 psay STR0045 + cDtVento
@li ++ ,1 psay STR0046 + Transform(aInfo[7],"@E 999,999,999,999.99")
@li ++ ,1 psay STR0047 + Transform(aInfo[8],"@E 999,999,999,999.99")
@li ++ ,1 psay STR0048 + Transform(aInfo[9],"@E 999,999,999,999.99")
@li ++ ,1 psay STR0049 + Transform(aInfo[10],"@E 999,999,999,999.99")
@li ++ ,1 psay STR0050 + Alltrim(str(aInfo[12]))
@li ++ ,1 psay STR0051 + cFabrica
@li ++ ,1 psay STR0052 + cSituaNF
@li ++ ,1 psay STR0053 + aInfo[16]
@li ++ ,1 psay STR0054 + aInfo[17]
*/

@li ++ ,1 psay  cData + "  "+ cDt + "  "+ cDtParc + "  " + cDtVento + "  " + strzero(aInfo[2],9) +;
Transform(aInfo[7],"@E 999,999,999,999.99")+" "+Transform(aInfo[8],"@E 999,999,999,999.99")+" "+Transform(aInfo[9],"@E 999,999,999,999.99")+" "+;
Transform(aInfo[10],"@E 999,999,999,999.99")+" "+strzero(aInfo[12],6)+ " "+ cSufNota+ " "+cTipNota+" "+cFabrica+" "+cSituaNF+" "+Alltrim(aInfo[16])+" "+Alltrim(aInfo[17])

//
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
		if ctod(cStrTexto) == ctod("  /  /  ") .and. cStrTexto != "00/00/0000"
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
