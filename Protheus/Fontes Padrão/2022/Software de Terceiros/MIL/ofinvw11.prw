// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW11.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW11   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FP5 - Reconhecimento do Pedido de Pecas|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW11(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFP5 := {}
Private cPedAnt := "inicial"
//
aAdd(aLayFP5, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FP5)"})
aAdd(aLayFP5, {"N",7,0,4," " }) 	// "NUMERO DO PEDIDO VOLKSWAGEN"})
aAdd(aLayFP5, {"N",2,0,11," " }) 	// "TIPO DO PEDIDO"})
aAdd(aLayFP5, {"C",13,0,13," " }) 	// "NUMERO DO PEDIDO REVENDEDOR"})
aAdd(aLayFP5, {"D",8,0,26," " }) 	// "DATA DO PROCESSAMENTO (ddmmaaaa)"})
aAdd(aLayFP5, {"D",8,0,34," " }) 	// "DATA DA ALOCAÇÃO (ddmmaaaa)"})
aAdd(aLayFP5, {"C",20,0,42," " }) 	// "NUMERO DA PEÇA"})
aAdd(aLayFP5, {"N",7,0,62," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,69," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,76," " }) 	// "STATUS CÓDIGO DE CONSISTÊNCIA"})
aAdd(aLayFP5, {"C",20,0,77," " }) 	// "NUMERO DA PEÇA"})
aAdd(aLayFP5, {"N",7,0,97," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,104," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,111," " }) 	// "STATUS CÓDIGO DE CONSISTÊNCIA"})
aAdd(aLayFP5, {"C",20,0,112," " }) 	// "NUMERO DA PEÇA"})
aAdd(aLayFP5, {"N",7,0,132," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,139," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,146," " }) 	// "STATUS CÓDIGO DE CONSISTÊNCIA"})
aAdd(aLayFP5, {"C",41,0,147," " }) 	// "BRANCOS"})
aAdd(aLayFP5, {"N",6,0,188," " }) 	// "VERSÃO DO LAYOUT (FIXO: 220800)"})
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
		if Left(cStr,3)=="FP5"
			aInfo := ExtraiEDI(aLayFP5,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3)=="FP5"
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
Local nCntFor
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
for nCntFor := 7 to 15 step 4
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
		@li++,1 psay cTipPed + "  " + STRZERO(aInfo[2],7) + " / " + aInfo[4] + STR0012 + dtoc(aInfo[5]) + STR0013 + dtoc(aInfo[6])
		cPedAnt := STRZERO(aInfo[2],7)
	endif
	//
	cStaCon := STR0014
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="A", STR0015, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="B", STR0016, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="C", STR0017, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="D", STR0018, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="E", STR0019, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="F", STR0020, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="G", STR0021, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="H", STR0022, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="I", STR0023, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="J", STR0024, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="K", STR0025, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="L", STR0026, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="Z", STR0027, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="P", STR0028, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="Q", STR0029, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="V", STR0030, cStaCon)
	//
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]==" ", STR0031, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="R", STR0032, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="S", STR0033, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="T", STR0034,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="U", STR0035,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="M", STR0036,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="N", STR0037,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="O", STR0038,cStaCon)
	//
	if !Empty(aInfo[nCntFor])
		@li++,1 psay aInfo[nCntFor] + STR0039 + STRZERO(aInfo[nCntFor+1],7) + "/" + STRZERO(aInfo[nCntFor+2],7)+ " " + cStaCon
	endif
	if li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
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
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet