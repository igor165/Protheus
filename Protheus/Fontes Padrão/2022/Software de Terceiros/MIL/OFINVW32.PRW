// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW32.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW32   | Autor | Luis Delorme          | Data | 07/11/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FG5 - Peças a Devolver CTG             |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW32(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG5 := {}
//       
aAdd(aLayFG5, {'C',3,0,1,' '}) // TIPO DE REGISTRO (FG5)
aAdd(aLayFG5, {'C',4,0,4,' '}) // SUBCÓDIGO DO REGISTRO (Fixo:Comu)
aAdd(aLayFG5, {'N',6,0,8,' '})// NÚMERO DO DEALER
aAdd(aLayFG5, {'N',2,0,14,' '}) // TIPO DO REGISTRO
aAdd(aLayFG5, {'N',6,0,16,' '}) // NÚMERO DO LANÇAMENTO CRÉDITO
aAdd(aLayFG5, {'D',8,0,22,' '}) // DATA DO LANÇAMENTO CRÉDITO (ddmmaaaa)
aAdd(aLayFG5, {'N',5,0,30,' '}) // NÚMERO DA ORDEM DE SERVIÇO

aAdd(aLayFG5, {'N',2,0,35,' '}) // QUANTIDADE DE PEÇA
aAdd(aLayFG5, {'C',20,0,37,' '}) // NÚMERO DA PEÇA
aAdd(aLayFG5, {'D',8,0,57,' '}) // DATA DA DEVOLUÇÃO (ddmmaaaa)
aAdd(aLayFG5, {'C',1,0,65,' '}) // CÓDIGO DE ENVIO DA PEÇA

aAdd(aLayFG5, {'N',2,0,66,' '} )// QUANTIDADE DE PEÇA
aAdd(aLayFG5, {'C',20,0,68,' '}) // NÚMERO DA PEÇA
aAdd(aLayFG5, {'D',8,0,88,' '}) // DATA DA DEVOLUÇÃO
aAdd(aLayFG5, {'C',1,0,96,' '}) // CÓDIGO DE ENVIO DA PEÇA
aAdd(aLayFG5, {'N',2,0,97,' '}) // QUANTIDADE DE PEÇA
aAdd(aLayFG5, {'C',20,0,99,' '}) // NÚMERO DA PEÇA
aAdd(aLayFG5, {'D',8,0,119,' '}) // DATA DA DEVOLUÇÃO
aAdd(aLayFG5, {'C',1,0,127,' '})// CÓDIGO DE ENVIO DA PEÇA
aAdd(aLayFG5, {'N',2,0,128,' '}) // QUANTIDADE DE PEÇA
aAdd(aLayFG5, {'C',20,0,130,' '}) // NÚMERO DA PEÇA
aAdd(aLayFG5, {'D',8,0,150,' '}) // DATA DA DEVOLUÇÃO
aAdd(aLayFG5, {'C',1,0,158,' '}) // CÓDIGO DE ENVIO DA PEÇA
aAdd(aLayFG5, {'N',2,0,159,' '}) // QUANTIDADE DE PEÇA
aAdd(aLayFG5, {'C',20,0,161,' '}) // NÚMERO DA PEÇA
aAdd(aLayFG5, {'D',8,0,181,' '}) // DATA DA DEVOLUÇÃO
aAdd(aLayFG5, {'C',1,0,189,' '}) // CÓDIGO DE ENVIO DA PEÇA
aAdd(aLayFG5, {'C',4,0,190,' '}) // BRANCOS
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
		if Left(cStr,3)=="FG5"
			aInfo := ExtraiEDI(aLayFG5,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,3)=="FG5"
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
Titulo := STR0001
Cabec1 := STR0002
Cabec2 := " "
NomeProg := "OFINVW32"
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
if !Empty(aInfo[5])
	for nCntFor := 8 to 24 step 4
		if !Empty(aInfo[nCntFor + 1])
			@ li++,1 psay ;
			Left(dtoc(aInfo[6])+space(10),10) + SPACE(3)+;
			STRZERO(aInfo[5],6) + SPACE(3)+;
			STRZERO(aInfo[7],5) + SPACE(3)+;
			aInfo[nCntFor + 1] + SPACE(3)+;
			Right(STR(aInfo[nCntFor]),5) + SPACE(3)+;
			Left(dtoc(aInfo[nCntFor+2])+space(10),10) + SPACE(3)+;
			aInfo[nCntFor + 3]
		endif
	next
endif

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