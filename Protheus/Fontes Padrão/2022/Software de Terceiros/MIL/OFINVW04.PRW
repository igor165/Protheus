// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW04.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW04   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG9 - Tempo Padrão de Reparo           |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW04(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG9 := {}
//
aAdd(aLayFG9, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG9)"})
aAdd(aLayFG9, {"C",4,0,4," " }) 	// "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayFG9, {"N",1,0,8," " }) 	// "CÓDIGO DE MANUTENÇÃO"})
aAdd(aLayFG9, {"C",8,0,9," " }) 	// "CÓDIGO DE OPERAÇÃO DE SERVIÇO"})
aAdd(aLayFG9, {"C",3,0,17," " }) 	// "TMA (CÓDIGO DO MODELO)"})
aAdd(aLayFG9, {"C",3,0,20," " }) 	// "IMC (ACABAMENTO)"})
aAdd(aLayFG9, {"N",4,2,23," " }) 	// "TEMPO DE REPARO (CENTEZIMAL)"})
aAdd(aLayFG9, {"C",30,0,27," " }) 	// "DESCRIÇÃO DA PEÇA E/OU ATIVIDADE"})
aAdd(aLayFG9, {"C",30,0,57," " }) 	// "OBSERVAÇÕES-CÓDIGO OPERAÇÃO DE SERVIÇO"})
aAdd(aLayFG9, {"N",1,0,87," " }) 	// "CÓDIGO DE MANUTENÇÃO"})
aAdd(aLayFG9, {"C",8,0,88," " }) 	// "CÓDIGO DE OPERAÇÃO DE SERVIÇO"})
aAdd(aLayFG9, {"C",3,0,96," " }) 	// "TMA (CÓDIGO DO MODELO)"})
aAdd(aLayFG9, {"C",3,0,99," " }) 	// "IMC (ACABAMENTO)"})
aAdd(aLayFG9, {"N",4,2,102," " }) 	// "TEMPO DE REPARO"})
aAdd(aLayFG9, {"C",30,0,106," " }) 	// "DESCRIÇÃO DA PEÇA E/OU ATIVIDADE"})
aAdd(aLayFG9, {"C",30,0,136," " }) 	// "OBSERVAÇÕES-CÓDIGO OPERAÇÃO DE SERVIÇO"})
aAdd(aLayFG9, {"C",22,0,166," " }) 	// "BRANCOS"})
aAdd(aLayFG9, {"N",6,0,188," " }) 	// "DATA DA VERSÃO (Fixo=251000)"})
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
		if Left(cStr,3)=="FG9"
			aInfo := ExtraiEDI(aLayFG9,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3) $ "FG9"
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
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0001 + Alltrim(STR(nLinhArq))
endif
//
if (!Empty(aInfo[4]))
	cTipoTPR := STR0002
	cTipoTPR := IIF(aInfo[2]=="TPR1",STR0003,cTipoTPR)
	cTipoTPR := IIF(aInfo[2]=="TPR2",STR0004,cTipoTPR)
	//
	cCodManu := STR0002
	cCodManu := IIF(aInfo[3]==0,STR0005,cCodManu)
	cCodManu := IIF(aInfo[3]==1,STR0006,cCodManu)
	cCodManu := IIF(aInfo[3]==2,STR0007,cCodManu)
	cCodManu := IIF(aInfo[3]==3,STR0008,cCodManu)
	//
	@li ++ ,1 psay cTipoTPR + "/" + cCodManu + " "+ aInfo[4]+"/"+aInfo[5]+"/"+aInfo[6]+STR0009+Transform(aInfo[7],"@E 99.99") + " - "  + Left(aInfo[8],25) //  +" - "+Left(aInfo[9],20)
	//
	if aInfo[2]=="TPR1"
		DBSelectArea("VIG")
		reclock("VIG",.t.)
		VIG->VIG_FILIAL := xFilial("VI6")
		VIG->VIG_CODMAR := FG_MARCA("VOLKS",,.f.)
		VIG->VIG_CODMAN := Alltrim(STR(aInfo[3]))
		VIG->VIG_CODSER := aInfo[4]
		VIG->VIG_SEGMOD := aInfo[5]
		VIG->VIG_IMC 	:= aInfo[6]
		VIG->VIG_TEMPAD := aInfo[7]
		VIG->VIG_DESSER := aInfo[8]
		msunlock()
	endif
endif
//
if (!Empty(aInfo[12]))
	cTipoTPR := STR0002
	cTipoTPR := IIF(aInfo[2]=="TPR1",STR0003,cTipoTPR)
	cTipoTPR := IIF(aInfo[2]=="TPR2",STR0004,cTipoTPR)
	//
	cCodManu := STR0002
	cCodManu := IIF(aInfo[10]==0,STR0005,cCodManu)
	cCodManu := IIF(aInfo[10]==1,STR0006,cCodManu)
	cCodManu := IIF(aInfo[10]==2,STR0007,cCodManu)
	cCodManu := IIF(aInfo[10]==3,STR0008,cCodManu)
	//
	@li ++ ,1 psay cTipoTPR + "/" + cCodManu + " "+ aInfo[11]+"/"+aInfo[12]+"/"+aInfo[13]+STR0009+Transform(aInfo[14],"@E 99.99")+ " - " + Left(aInfo[15],25) // +" - "+Left(aInfo[16],20)
	//
	if aInfo[2]=="TPR1"
		DBSelectArea("VIG")
		reclock("VIG",.t.)
		VIG->VIG_FILIAL := xFilial("VI6")
		VIG->VIG_CODMAR := FG_MARCA("VOLKS",,.f.)
		VIG->VIG_CODMAN := Alltrim(STR(aInfo[10]))
		VIG->VIG_CODSER := aInfo[11]
		VIG->VIG_SEGMOD := aInfo[12]
		VIG->VIG_IMC 	:= aInfo[13]
		VIG->VIG_TEMPAD := aInfo[14]
		VIG->VIG_DESSER := aInfo[15]
		msunlock()
	endif
	//
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
±±º               123456789012345678901234567890'123456789                    º±±
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