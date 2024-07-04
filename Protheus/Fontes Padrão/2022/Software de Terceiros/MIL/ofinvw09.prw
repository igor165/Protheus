// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW09.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW09   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG4 - C.R. / Créditos/Débitos G & AT   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW09(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG4 := {}
//
aAdd(aLayFG4, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG4)"})
aAdd(aLayFG4, {"C",4,0,4," " }) 	// "SUBCÓDIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG4, {"N",6,0,8," " }) 	// "NÚMERO DO DEALER"})
aAdd(aLayFG4, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,16," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG4, {"N",2,0,21," " }) 	// "CÓDIGO DA REVISÃO"})
aAdd(aLayFG4, {"C",17,0,23," " }) 	// "NÚMERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,40," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO/DÉBITO"})
aAdd(aLayFG4, {"D",8,0,46," " }) 	// "DATA DO LANÇAMENTO CRÉDITO/DÉBITO (ddmmaaaa)"})
aAdd(aLayFG4, {"N",15,3,54," " }) 	// "VALOR A SER CREDITADO/DEBITADO (em Reais)"})
aAdd(aLayFG4, {"N",2,0,69," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,71," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG4, {"N",2,0,76," " }) 	// "CÓDIGO DA REVISÃO"})
aAdd(aLayFG4, {"C",17,0,78," " }) 	// "NÚMERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,95," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO/DÉBITO"})
aAdd(aLayFG4, {"D",8,0,101," " }) 	// "DATA DO LANÇAMENTO CRÉDITO/DÉBITO"})
aAdd(aLayFG4, {"N",15,3,109," " }) 	// "VALOR A SER CREDITADO/DEBITADO"})
aAdd(aLayFG4, {"N",2,0,124," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,126," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG4, {"N",2,0,131," " }) 	// "CÓDIGO DA REVISÃO"})
aAdd(aLayFG4, {"C",17,0,133," " }) 	// "NÚMERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,150," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO/DÉBITO"})
aAdd(aLayFG4, {"D",8,0,156," " }) 	// "DATA DO LANÇAMENTO CRÉDITO/DÉBITO"})
aAdd(aLayFG4, {"N",15,3,164," " }) 	// "VALOR A SER CREDITADO/DEBITADO"})
aAdd(aLayFG4, {"C",15,0,179," " }) 	// "BRANCOS"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// Laço em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
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
		// Informações extraídas da linha do arquivo de importação ficam no vetor aInfo
		if Left(cStr,3)=="FG4"
			aInfo := ExtraiEDI(aLayFG4,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3)=="FG4"
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
##|Fun‡…o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa o resultado da importação                           |##
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
NomeProg := "OFINVW09"
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
for nCntFor := 4 to 18 STEP 7
	if !Empty(aInfo[nCntFor + 3])
		cTipReg := STR0001
		cTipReg := IIF(aInfo[nCntFor] == 5,STR0002,cTipReg)
		cTipReg := IIF(aInfo[nCntFor] == 6,STR0003,cTipReg)
		@ li++,1 psay dtoc(aInfo[nCntFor+5]) + SPACE(5) +;
		strzero(aInfo[nCntFor+4],6) + SPACE(5) +;
		strzero(aInfo[nCntFor+1],5) + SPACE(5) +;
		STRZERO(aInfo[nCntFor+2],2) + SPACE(5) +;
		aInfo[nCntFor+3] + SPACE(5) +;
		Transform(aInfo[nCntFor+6],"@E 999,999,999,99.999") + SPACE(5) + cTipReg
	endif
next
//
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ ExtraiEDI º Autor ³ Luis Delorme             º Data ³ 26/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Monta vetores a partir de uma descrição de layout e da linha deº±±
±±º         ³ importação EDI                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno ³ aRet - Valores extraídos da linha                              º±±
±±º         ³        Se der erro o vetor retorna {}                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) º±±
±±º         ³ aLayout[n,2] = Tamanho do Campo                                º±±
±±º         ³ aLayout[n,3] = Quantidade de Decimais do Campo                 º±±
±±º         ³ aLayout[n,4] = Posição Inicial do Campo na Linha               º±±
±±º         ³                                                                º±±
±±º         ³ cLinhaEDI    = Linha para extração das informações             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                          º±±
±±º  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    º±±
±±º                                                                          º±±
±±º  aAdd(aLayout,{"C",10,0,1})                                              º±±
±±º  aAdd(aLayout,{"C",20,0,11})                                             º±±
±±º  aAdd(aLayout,{"N",5,2,31})                                              º±±
±±º  aAdd(aLayout,{"N",4,0,36})                                              º±±
±±º                        1         2         3                             º±±
±±º               123456789012345678901234567890'123456789                   º±±
±±º  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    º±±
±±º                                                                          º±±
±±º  No caso acima o retorno seria:                                          º±±
±±º  aRet[1] - "Jose Silva"                                                  º±±
±±º  aRet[2] - "Vendedor Externo"                                            º±±
±±º  aRet[3] - 123,12                                                        º±±
±±º  aRet[4] - 1234                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
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