// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW07.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW07   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG2 - Créditos/Débitos G & AT          |##
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
aAdd(aLayFG2, {"C",4,0,4," " }) 	// "SUBCÓDIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG2, {"N",6,0,8," " }) 	// "NÚMERO DO DEALER"})
aAdd(aLayFG2, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,16," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG2, {"N",6,0,21," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",6,0,27," " }) 	// "NÚMERO DA NOTA FISCAL (Informada na SG)"})
aAdd(aLayFG2, {"D",8,0,33," " }) 	// "DATA DO LANÇAMENTO CRÉDITO / DÉBITO (ddmmaaaa)"})
aAdd(aLayFG2, {"N",15,3,41," " }) 	// "VALOR A SER CREDITADO / DEBITADO (em Reais)"})
aAdd(aLayFG2, {"N",3,0,56," " }) 	// "CÓDIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,59," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,61," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG2, {"N",6,0,66," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",6,0,72," " }) 	// "NÚMERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,78," " }) 	// "DATA DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",15,3,86," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,101," " }) 	// "CÓDIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,104," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,106," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG2, {"N",6,0,111," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",6,0,117," " }) 	// "NÚMERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,123," " }) 	// "DATA DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",15,3,131," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,146," " }) 	// "CÓDIGO DO ESTORNO / LAUDO"})
aAdd(aLayFG2, {"N",2,0,149," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG2, {"N",5,0,151," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG2, {"N",6,0,156," " }) 	// "NÚMERO DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",6,0,162," " }) 	// "NÚMERO DA NOTA FISCAL"})
aAdd(aLayFG2, {"D",8,0,168," " }) 	// "DATA DO LANÇAMENTO CRÉDITO / DÉBITO"})
aAdd(aLayFG2, {"N",15,3,176," " }) 	// "VALOR A SER CREDITADO / DEBITADO"})
aAdd(aLayFG2, {"N",3,0,191," " }) 	// "CÓDIGO DO ESTORNO / LAUDO"})
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
		if Left(cStr,3)=="FG2"
			aInfo := ExtraiEDI(aLayFG2,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
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
NomeProg := "OFINVW07"
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
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