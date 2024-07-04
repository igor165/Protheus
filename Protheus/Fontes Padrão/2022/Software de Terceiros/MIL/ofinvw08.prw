// �����������������ͻ
// � Versao � 3      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW08.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW08   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o VW Assunto FG3 - Consist. Cup.Rev. e VT           |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW08(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG3 := {}
//
aAdd(aLayFG3, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG3)"})
aAdd(aLayFG3, {"C",4,0,4," " }) 	// "SUBC�DIGO DO REGISTRO (Fixo: Comu)"})
aAdd(aLayFG3, {"N",6,0,8," " }) 	// "N�MERO DO DEALER"})
aAdd(aLayFG3, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG3, {"N",5,0,16," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG3, {"C",3,0,21," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,24," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,27," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,30," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,33," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,36," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,39," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,42," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,45," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,48," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,51," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,54," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,57," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,60," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,63," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,66," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,69," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,72," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,75," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,78," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"N",5,0,81," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG3, {"C",3,0,86," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,89," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,92," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,95," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,98," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,101," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,104," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,107," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,110," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,113," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,116," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,119," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,122," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,125," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,128," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,131," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,134," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,137," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,140," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",3,0,143," " }) 	// "C�DIGO DA CONSIST�NCIA"})
aAdd(aLayFG3, {"C",48,0,146," " }) 	// "BRANCOS"})
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
		if Left(cStr,3)=="FG3"
			aInfo := ExtraiEDI(aLayFG3,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,3)=="FG3"
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
Local nCntFor
Titulo := STR0002
Cabec1 := STR0003
Cabec2 := " "
NomeProg := "OFINVW08"
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
if !Empty(aInfo[5])
	@li ,1 psay  STRZERO(aInfo[5],5)
	cStrTot := ""
	for nCntFor := 6 to 25
		if !Empty(aInfo[nCntFor])
			cStrTot += aInfo[nCntFor]+", "
		endif
		if Len(cStrTot) > 220
			@li ++ ,10 psay Left(cStrTot,Len(cStrTot)-2)
			cStrTot := ""
		endif
		if li > 65
			li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		endif
	next
	if Len(cStrTot) > 0
		@li ++ ,10 psay Left(cStrTot,Len(cStrTot)-2)
	endif
endif
//
if !Empty(aInfo[26])
	@li ,1 psay  STRZERO(aInfo[26],5)
	cStrTot := ""
	for nCntFor := 27 to 46
		if !Empty(aInfo[nCntFor])
			cStrTot += aInfo[nCntFor]+", "
		endif
		if Len(cStrTot) > 220
			@li ++ ,10 psay Left(cStrTot,Len(cStrTot)-2)
			cStrTot := ""
		endif
		if li > 65
			li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		endif
	next
	if Len(cStrTot) > 0
		@li ++ ,10 psay Left(cStrTot,Len(cStrTot)-2)
	endif
endif
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
���               123456789012345678901234567890'123456789                   ���
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
			ncValor := ctod(cStrTexto)
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet