// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW10.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW10   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FL3 - Lista de Preços de Peças         |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW10(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFL3 := {}
//
aAdd(aLayFL3, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FL3)"})
aAdd(aLayFL3, {"C",20,0,4," " }) 	// "NÚMERO DA PEÇA (Volkswagen)"})
aAdd(aLayFL3, {"C",13,0,24," " }) 	// "DESCRIÇÃO RESUMIDA DA PEÇA"})
aAdd(aLayFL3, {"N",11,2,37," " }) 	// "PREÇO PÚBLICO"})
aAdd(aLayFL3, {"N",11,2,48," " }) 	// "PREÇO REPOSIÇÃO"})
aAdd(aLayFL3, {"N",11,2,59," " }) 	// "PREÇO GARANTIA"})
aAdd(aLayFL3, {"C",3,0,70," " }) 	// "PART CLASS"})
aAdd(aLayFL3, {"N",7,0,73," " }) 	// "QUANTIDADE MÍNIMA - VENDA 1"})
aAdd(aLayFL3, {"N",7,0,80," " }) 	// "QUANTIDADE MÍNIMA - VENDA 2"})
aAdd(aLayFL3, {"N",7,0,87," " }) 	// "QUANTIDADE MÍNIMA - VENDA 3"})
aAdd(aLayFL3, {"C",2,0,94," " }) 	// "GRUPO DE DESCONTO"})
aAdd(aLayFL3, {"C",10,0,96," " }) 	// "CLASSIFICAÇÃO FISCAL"})
aAdd(aLayFL3, {"N",4,2,106," " }) 	// "TAXA DE IPI"})
aAdd(aLayFL3, {"N",7,3,110," " }) 	// "PESO"})
aAdd(aLayFL3, {"C",1,0,118," " }) 	// "PEÇA DSH (DIRECT SHIPMENT)"})
aAdd(aLayFL3, {"N",5,4,119," " }) 	// "FATOR DE DESCONTO (FD)"})
aAdd(aLayFL3, {"C",50,0,124," " }) 	// "DESCRIÇÃO EXPANDIDA DA PEÇA"})
aAdd(aLayFL3, {"C",1,0,174," " }) 	// "IMPOSTO PIS"})
aAdd(aLayFL3, {"C",1,0,175," " }) 	// "IMPOSTO COFINS"})
aAdd(aLayFL3, {"C",1,0,176," " }) 	// "TIPO DO ITEM (Número da Peça)"})
aAdd(aLayFL3, {"C",11,0,177," " }) 	// "BRANCOS"})
aAdd(aLayFL3, {"N",6,0,188," " }) 	// "VERSÃO DO LAYOUT (FIXO: 190706)"})
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
		if Left(cStr,3)=="FL3"
			aInfo := ExtraiEDI(aLayFL3,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3)=="FL3"
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
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
@li++,1 psay aInfo[2] + " - "+ aInfo[3]
@li++,1 psay STR0001 +Transform(aInfo[4],"@E 999,999,999.99") + STR0002 +Transform(aInfo[5],"@E 999,999,999.99") + STR0003 +Transform(aInfo[6],"@E 999,999,999.99")
//
DBSelectArea("VE5")
DBSetOrder(1)
nFPGar := 1
if DBSeek(xFilial("VE5") + FG_MARCA("VOLKS",,.f.) + aInfo[11])
	nFPGar := VE5->VE5_FRPGAR
endif

DBSelectArea("VI3")
reclock("VI3",.t.)
VI3_FILIAL := xFilial("VI3")
VI3_TIPREG := "FL3"
VI3_CODITE := aInfo[2]
VI3_DESCRI := aInfo[3]
VI3_PREPLU := aInfo[4]
VI3_PREREP := aInfo[5]
VI3_PREGAR := aInfo[6] * nFPGar
VI3_PARGLA := aInfo[7]
VI3_QTMIN1 := aInfo[8]
VI3_QTMIN2 := aInfo[9]
VI3_QTMIN3 := aInfo[10]
VI3_GRUDST := aInfo[11]
VI3_CLAFIS := aInfo[12]
VI3_ALQIPI := aInfo[13]
VI3_PESITE := aInfo[14]
// VI3_ITEFIS := aInfo[15]
VI3_ITEDSH := aInfo[15]
VI3_CODFAB := aInfo[2]
VI3_CODMAR := FG_MARCA("VOLKS",,.f.)
VI3_FATDES := aInfo[16]
VI3_DESEXP := aInfo[17]
VI3_MONOFA := IIF(aInfo[18]="I","S","")
if FieldPos("VI3_TIPITE") > 0
	VI3_TIPITE := aInfo[20]
endif
msunlock()
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
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet