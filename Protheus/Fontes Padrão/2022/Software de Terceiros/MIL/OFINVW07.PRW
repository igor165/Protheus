// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW07.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW07   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o VW Assunto FG2 - Cr�ditos/D�bitos G & AT          |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW07(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG2 := {}
//
aAdd(aLayFG2, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG2)"})
aAdd(aLayFG2, {"C",4,0,4," " }) 	// "SUBC�DIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG2, {"N",6,0,8," " }) 	// "N�MERO DO DEALER"})
aAdd(aLayFG2, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,16," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG2, {"N",6,0,21," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",6,0,27," " }) 	// "N�MERO DA NOTA FISCAL (Informada na SG)"})
aAdd(aLayFG2, {"D",8,0,33," " }) 	// "DATA DO LAN�AMENTO CR�DITO / D�BITO (ddmmaaaa)"})
aAdd(aLayFG2, {"N",15,3,41," " }) 	// "VALOR A SER CREDITADO / DEBITADO (em Reais)"})
aAdd(aLayFG2, {"N",3,0,56," " }) 	// "C�DIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,59," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,61," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG2, {"N",6,0,66," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",6,0,72," " }) 	// "N�MERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,78," " }) 	// "DATA DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",15,3,86," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,101," " }) 	// "C�DIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,104," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,106," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG2, {"N",6,0,111," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",6,0,117," " }) 	// "N�MERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,123," " }) 	// "DATA DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",15,3,131," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,146," " }) 	// "C�DIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,149," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,151," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG2, {"N",6,0,156," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",6,0,162," " }) 	// "N�MERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,168," " }) 	// "DATA DO LAN�AMENTO CR�DITO / D�BITO"})
aAdd(aLayFG2, {"N",15,3,176," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,191," " }) 	// "C�DIGO DO ESTORNO / LAUDO"})
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
		// Informa苺es extra�das da linha do arquivo de importa艫o ficam no vetor aInfo
		if Left(cStr,3)=="FG2"
			aInfo := ExtraiEDI(aLayFG2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,3)=="FG2"
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
##|Descri��o | Processa o resultado da importa艫o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
Local nCntFor
Titulo := STR0009
Cabec1 := STR0010
Cabec2 := " "
NomeProg := "OFINVW07"
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
for nCntFor := 4 to 25 STEP 7
	if !Empty(aInfo[nCntFor])
		@li ++ ,1 psay ;
		Left(dtoc(aInfo[nCntFor + 4])+space(10),10) + space(5) + ;
		STRZERO(aInfo[nCntFor+1],5) + space(5) +;
		STRZERO(aInfo[nCntFor+2],6) + space(5) +;
		STRZERO(aInfo[nCntFor+3],6) + space(5) +;
		STRZERO(aInfo[nCntFor],2) + space(5) +;
		Transform(aInfo[nCntFor+5],"@E 99,999,999,999.999") + space(5) +;
		Alltrim( STR(aInfo[nCntFor+6]) )
	endif
next
//
return
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様冤様様様様様僕様様様冤様様様様様様様様様様様様曜様様様冤様様様様融臼
臼�Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 艮�
臼麺様様様様慷様様様様様瞥様様様詫様様様様様様様様様様様様擁様様様詫様様様様郵臼
臼�Descricao� Monta vetores a partir de uma descri艫o de layout e da linha de艮�
臼�         � importa艫o EDI                                                 艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼� Retorno � aRet - Valores extra�dos da linha                              艮�
臼�         �        Se der erro o vetor retorna {}                          艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼�Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) 艮�
臼�         � aLayout[n,2] = Tamanho do Campo                                艮�
臼�         � aLayout[n,3] = Quantidade de Decimais do Campo                 艮�
臼�         � aLayout[n,4] = Posi艫o Inicial do Campo na Linha               艮�
臼�         �                                                                艮�
臼�         � cLinhaEDI    = Linha para extra艫o das informa苺es             艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼�                                                                          艮�
臼�  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    艮�
臼�                                                                          艮�
臼�  aAdd(aLayout,{"C",10,0,1})                                              艮�
臼�  aAdd(aLayout,{"C",20,0,11})                                             艮�
臼�  aAdd(aLayout,{"N",5,2,31})                                              艮�
臼�  aAdd(aLayout,{"N",4,0,36})                                              艮�
臼�                        1         2         3                             艮�
臼�               123456789012345678901234567890'123456789                   艮�
臼�  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    艮�
臼�                                                                          艮�
臼�  No caso acima o retorno seria:                                          艮�
臼�  aRet[1] - "Jose Silva"                                                  艮�
臼�  aRet[2] - "Vendedor Externo"                                            艮�
臼�  aRet[3] - 123,12                                                        艮�
臼�  aRet[4] - 1234                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2
cLinhaEDI += SPACE(100)
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
		if ctod(cStrTexto) == stod("  /  /  ")
			ncValor := ctod(cStrTexto)
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet