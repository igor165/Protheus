// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW30.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW30   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o do Layout referente a Tipos de Doc do C/C         |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW30(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}
//
Private nAnt := 0
//
aAdd(aLayoutFN0, {"C",	3	,0,	001," " }) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	5	,0,	004," " }) //  "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	179, 0,	009," " }) //  "CABE�ALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188," " }) //  "LAYOUT VERS�O (Fixo: 040501)"})

aAdd(aLayoutFN1, { "C",3 ,0,001," " }) // "TIPO DE REGISTRO" })
aAdd(aLayoutFN1, { "N",5 ,0,004," " }) // "SUB-C�DIGO DO REGISTRO" })
aAdd(aLayoutFN1, { "C",4 ,0,009," " }) // "TIPO DE DOCUMENTO" })
aAdd(aLayoutFN1, { "C",50,0,013," " }) // "DESCRI巴O DO TIPO DE DOCUMENTO" })
aAdd(aLayoutFN1, { "C",4 ,0,063," " }) // "TIPO DO DOCUMENTO" })
aAdd(aLayoutFN1, { "C",50,0,067," " }) // "DESCRI巴O DO TIPO DE DOCUMENTO" })
aAdd(aLayoutFN1, { "C",4 ,0,117," " }) // "TIPO DO DOCUMENTO" })
aAdd(aLayoutFN1, { "C",50,0,121," " }) // "DESCRI巴O DO TIPO DE DOCUMENTO" })
aAdd(aLayoutFN1, { "C",4 ,0,171," " }) // "TIPO DO DOCUMENTO" })
aAdd(aLayoutFN1, { "C",50,0,175," " }) // "DESCRI巴O DO TIPO DE DOCUMENTO" })
aAdd(aLayoutFN1, { "C",9 ,0,220," " }) // "BRANCOS" })

aAdd(aLayoutFN2, {"C",	3	,0,	001, " " }) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	5	,0,	004, " " }) // "SUB-C�DIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	185,0,	009, " " }) // "CABE�ALHO FINAL A SER IMPRESSO"})
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
		if Left(cStr,8)=="FLH60000"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,8)=="FLH60001"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,8)=="FLH60002"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,8) $ "FLH60002.FLH60001.FLH60000"
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
##|Fun��o    | ImprimeRel | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa艫o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
Titulo := STR0021
Cabec1 := " "
Cabec2 := ""
cCab := " "
NomeProg := "OFINVW29"
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
	nAnt := 0
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif

if aInfo[2] == 60000
	if nAnt != 60000 .and. nAnt != 0
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li ++ ,1 psay " "
	endif
	@li ++ ,1 psay aInfo[3]
	nAnt := 60000
elseif aInfo[2] == 60001
	@li++,1 psay  ;
	Iif(!Empty(aInfo[3]), aInfo[3] + " - " + aInfo[4], SPACE(47) ) + ;
	Iif(!Empty(aInfo[5]), aInfo[5] + " - " + aInfo[6], SPACE(47) ) + ;
	Iif(!Empty(aInfo[7]), aInfo[7] + " - " + aInfo[8], SPACE(47) ) + ;
	Iif(!Empty(aInfo[9]), aInfo[9] + " - " + aInfo[10], SPACE(47) )
elseif aInfo[2] == 60002
	@li ++ ,1 psay aInfo[3]
endif

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
臼�               123456789012345678901234567890'123456789                    艮�
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
cLinhaEDI +=SPACE(100)
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
