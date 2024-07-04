// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW06.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW06   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG1 - SGs Erradas - G & AT             |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW06(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG1 := {}
//
aAdd(aLayFG1, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG1)"})
aAdd(aLayFG1, {"C",4,0,4," " }) 	// "SUBCÓDIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG1, {"N",6,0,8," " }) 	// "NÚMERO DO DEALER (00dndn)"})
aAdd(aLayFG1, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO (Fixo:01 SG's Erradas)"})
aAdd(aLayFG1, {"N",5,0,16," " }) 	// "NÚMERO DA ORDEM DE SERVIÇO"})
aAdd(aLayFG1, {"C",3,0,21," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,24," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,25," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,27," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,30," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,31," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,33," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,36," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,37," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,39," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,42," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,43," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,45," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,48," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,49," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,51," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,54," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,55," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,57," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,60," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,61," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,63," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,66," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,67," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,69," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,72," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,73," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,75," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,78," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,79," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,81," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,84," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,85," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,87," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,90," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,91," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,93," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,96," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,97," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,99," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,102," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,103," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,105," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,108," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,109," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,111," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,114," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,115," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,117," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,120," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,121," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,123," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,126," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,127," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,129," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,132," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,133," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,135," " }) 	// "CÓDIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,138," " }) 	// "CÓDIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,139," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",53,0,141," " }) 	// "BRANCOS"})
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
		if Left(cStr,3)=="FG1"
			aInfo := ExtraiEDI(aLayFG1,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3) $ "FG1"
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
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Titulo := STR0004
Cabec1 := STR0005
Cabec2 := " "
NomeProg := "OFINVW06"

if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0001 + Alltrim(STR(nLinhArq))
endif
//

for nCntFor := 6 to 63 STEP 3
	if !Empty(aInfo[nCntFor])
		@li ++ ,1 psay STRZERO(aInfo[5],5) + space(10) +aInfo[nCntFor] + space(10)+STRZERO(aInfo[nCntFor + 1],1)+space(10) + aInfo[nCntFor + 2]
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