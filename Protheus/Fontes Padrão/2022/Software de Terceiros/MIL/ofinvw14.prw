// 浜様様様曜様様様様�
// � Versao � 2      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW14.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW14   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o VW Assunto FP8 - Back Order Cancelado             |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW14(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFP8 := {}
Private cPedAnt := "inicial"
//
aAdd(aLayFP8, {"C",3,0,1,"TIPO DE REGISTRO (FP6)"})
aAdd(aLayFP8, {"N",7,0,4,"NUMERO DO PEDIDO VOLKSWAGEN"})
aAdd(aLayFP8, {"N",2,0,11,"TIPO DE PEDIDO"})
aAdd(aLayFP8, {"C",13,0,13,"NUMERO DO PEDIDO REVENDEDOR"})
aAdd(aLayFP8, {"D",8,0,26,"DATA DO PROCESSAMENTO (ddmmaaaa)"})
aAdd(aLayFP8, {"C",20,0,34,"N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP8, {"N",7,0,54,"QUANTIDADE BACK ORDER"})
aAdd(aLayFP8, {"N",11,2,61,"VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP8, {"C",20,0,72,"N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP8, {"N",7,0,92,"QUANTIDADE BACK ORDER"})
aAdd(aLayFP8, {"N",11,2,99,"VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP8, {"C",20,0,110,"N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP8, {"N",7,0,130,"QUANTIDADE BACK ORDER"})
aAdd(aLayFP8, {"N",11,2,137,"VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP8, {"C",46,0,148,"BRANCOS"})
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
		if Left(cStr,3)=="FP8"
			aInfo := ExtraiEDI(aLayFP8,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,3)=="FP8"
			GrvInfo(aInfo)
		endif
		//
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
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
for nCntFor := 6 to 12 step 3
	//
	cTipPed := STR0001
	cTipPed := IIF(aInfo[3]==1,STR0002,cTipPed)
	cTipPed := IIF(aInfo[3]==3,STR0003,cTipPed)
	cTipPed := IIF(aInfo[3]==4,STR0004,cTipPed)
	cTipPed := IIF(aInfo[3]==5,STR0005,cTipPed)
	cTipPed := IIF(aInfo[3]==6,STR0006,cTipPed)
	cTipPed := IIF(aInfo[3]==8,STR0007,cTipPed)
	cTipPed := IIF(aInfo[3]==9,STR0008,cTipPed)
	cTipPed := IIF(aInfo[3]==11,STR0009,cTipPed)
	cTipPed := IIF(aInfo[3]==12,STR0010,cTipPed)
	cTipPed := IIF(aInfo[3]==0,STR0011,cTipPed)
	//
	if cPedAnt != STRZERO(aInfo[2],7)
		@li++,1 psay cTipPed + "  " + STRZERO(aInfo[2],7) + " / " + aInfo[4] + STR0012 + dtoc(aInfo[5])
		cPedAnt := STRZERO(aInfo[2],7)
	endif
	//
	if !Empty(aInfo[nCntFor])
		@li++,1 psay aInfo[nCntFor] + STR0013 + STRZERO(aInfo[nCntFor+1],7) + STR0014 + Alltrim(Transform(aInfo[nCntFor+2],"@E 999,999,999.99"))
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
臼�               123456789012345678901234567890123456789                    艮�
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