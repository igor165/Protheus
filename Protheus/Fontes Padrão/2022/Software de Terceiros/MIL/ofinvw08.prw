// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW08.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW08   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG3 - Consist. Cup.Rev. e VT           |##
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
aAdd(aLayFG3, {"C",4,0,4," " }) 	// "SUBCÓDIGO DO REGISTRO (Fixo: Comu)"})
aAdd(aLayFG3, {"N",6,0,8," " }) 	// "NÚMERO DO DEALER"})
aAdd(aLayFG3, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG3, {"N",5,0,16," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG3, {"C",3,0,21," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,24," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,27," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,30," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,33," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,36," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,39," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,42," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,45," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,48," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,51," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,54," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,57," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,60," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,63," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,66," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,69," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,72," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,75," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,78," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"N",5,0,81," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG3, {"C",3,0,86," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,89," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,92," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,95," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,98," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,101," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,104," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,107," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,110," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,113," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,116," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,119," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,122," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,125," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,128," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,131," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,134," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,137," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,140," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",3,0,143," " }) 	// "CÓDIGO DA CONSISTÊNCIA"})
aAdd(aLayFG3, {"C",48,0,146," " }) 	// "BRANCOS"})
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
		if Left(cStr,3)=="FG3"
			aInfo := ExtraiEDI(aLayFG3,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
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
Titulo := STR0002
Cabec1 := STR0003
Cabec2 := " "
NomeProg := "OFINVW08"
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
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