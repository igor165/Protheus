// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW33.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW33   | Autor | Luis Delorme          | Data | 07/11/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW F50 LISTAS VK - REVISÕES VWBR. AUTO / CAM      +##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW33(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayF50 := {}
Local aLayF501 := {}
//
aAdd(aLayF50, {'C',3,0,1,' '}) // TIPO DE REGISTRO (Fixo=F50)
aAdd(aLayF50, {'N',3,0,4,' '}) // SUB-CÓDIGO DO REGISTRO (Fixo=000)
aAdd(aLayF50, {'C',2,0,7,' '}) // CÓDIGO DO REGISTRO DA LISTA
aAdd(aLayF50, {'N',5,0,9,' '}) // NÚMERO DO DEALER
aAdd(aLayF50, {'N',5,0,14,' '}) // NÚMERO DA SOLICITAÇÃO DE GARANTIA (SG) / OS
aAdd(aLayF50, {'N',1,0,19,' '}) // VERSÃO DA SG
aAdd(aLayF50, {'C',3,0,20,' '}) // TMA DO VEÍCULO
aAdd(aLayF50, {'C',3,0,23,' '}) // IMC DO VEÍCULO
aAdd(aLayF50, {'C',1,0,26,' '}) // CÓDIGO DO ANO DO MODELO DO VEÍCULO
aAdd(aLayF50, {'D',6,0,27,' '}) // DATA DA VENDA (ddmmaa)
aAdd(aLayF50, {'D',6,0,33,' '}) // DATA DO REPARO (ddmmaa)
aAdd(aLayF50, {'N',6,0,39,' '}) // NÚMERO DO AVISO DE LANÇAMENTO
aAdd(aLayF50, {'D',6,0,45,' '}) // DATA DA NOTA DE CRÉDITO (ddmmaa)
aAdd(aLayF50, {'C',17,0,51,' '}) // NÚMERO DO CHASSI DO VEÍCULO
aAdd(aLayF50, {'C',1,0,68,' '}) // TIPO DE GARANTIA
aAdd(aLayF50, {'C',1,0,69,' '}) // CÓDIGO DE LANÇAMENTO
aAdd(aLayF50, {'C',3,0,70,' '}) // CÓDIGO DA MENSAGEM DO LAUDO DA SG
aAdd(aLayF50, {'N',6,0,73,' '}) // QUILOMETRAGEM
aAdd(aLayF50, {'C',1,0,79,' '}) // COMBUSTÍVEL
aAdd(aLayF50, {'C',6,0,80,' '}) // NÚMERO DE AUTORIZAÇÃO
aAdd(aLayF50, {'C',1,0,86,' '}) // RECONSIDERAÇÃO
aAdd(aLayF50, {'C',1,0,87,' '}) // PEÇA CAUSADORA
aAdd(aLayF50, {'C',3,0,88,' '}) // LAUDO DA PEÇA
aAdd(aLayF50, {'C',2,0,91,' '}) // CÓDIGO DO DEFEITO
aAdd(aLayF50, {'C',3,0,93,' '}) // CÓDIGO DO FORNECEDOR / LOCAL NO VEÍCULO
aAdd(aLayF50, {'C',8,0,96,' '}) // CÓDIGO DE OPERAÇÃO DE SERVIÇO
aAdd(aLayF50, {'N',5,2,104,' '}) // UNIDADE DE TEMPO - MÃO-DE-OBRA
aAdd(aLayF50, {'N',8,3,109,' '}) // TAXA DE MÃO-DE-OBRA
aAdd(aLayF50, {'N',2,0,117,' '}) // QUANTIDADE DE PEÇA
aAdd(aLayF50, {'C',20,0,119,' '}) // NÚMERO DA PEÇA
aAdd(aLayF50, {'N',8,3,139,' '}) // PREÇO UNITÁRIO DA PEÇA (BRASIL)
aAdd(aLayF50, {'N',8,3,147,' '}) // VALOR DA PEÇA ADICIONAL
aAdd(aLayF50, {'N',5,2,155,' '}) // UNIDADE DE TEMPO - MÃO-DE-OBRA ADICIONAL
aAdd(aLayF50, {'N',8,3,160,' '}) // VALOR TOTAL DE PEÇAS
aAdd(aLayF50, {'N',8,3,168,' '}) // VALOR TOTAL DE MÃO-DE-OBRA
aAdd(aLayF50, {'C',1,0,176,' '}) // MARCA (Fixo=0)
aAdd(aLayF50, {'C',6,0,177,' '}) // RESERVA1
aAdd(aLayF50, {'I',6,0,183,' '}) // DATA DE DEVOLUÇÃO DA PEÇA (aammdd)
aAdd(aLayF50, {'N',3,1,189,' '}) // TAXA DE IPI
aAdd(aLayF50, {'C',1,0,192,' '}) // PART CLASS - Origem da Peça
aAdd(aLayF50, {'C',1,0,193,' '}) // CÓDIGO DO DESTINO

aAdd(aLayF501, {'C',3,0,1,' '}) // TIPO DE REGISTRO (Fixo=F50)
aAdd(aLayF501, {'N',3,0,4,' '}) // SUB-CÓDIGO DO REGISTRO (Fixo=001)
aAdd(aLayF501, {'C',2,0,7,' '}) // CÓDIGO DO REGISTRO DA LISTA
aAdd(aLayF501, {'N',5,0,9,' '}) // NÚMERO DO DEALER
aAdd(aLayF501, {'N',5,0,14,' '}) // NÚMERO DA SOLICITAÇÃO DE GARANTIA (SG) / OS
aAdd(aLayF501, {'N',2,0,19,' '}) // CÓDIGO DE REVISÃO
aAdd(aLayF501, {'I',6,0,21,' '}) // DATA DA REVISÃO (aammdd)
aAdd(aLayF501, {'N',6,0,27,' '}) // QUILOMETRAGEM
aAdd(aLayF501, {'C',17,0,33,' '}) // NÚMERO DO CHASSI DO VEÍCULO
aAdd(aLayF501, {'N',9,2,50,' '}) // VALOR PAGO
aAdd(aLayF501, {'C',1,0,59,' '}) // STATUS DA REVISÃO
aAdd(aLayF501, {'C',15,0,60,' '}) // CÓDIGO DA MENSAGEM DO ERRO
aAdd(aLayF501, {'C',6,0,75,' '}) // NÚMERO DA NOTA FISCAL
aAdd(aLayF501, {'I',6,0,81,' '}) // DATA DO CRÉDITO / DÉBITO (aammdd)
aAdd(aLayF501, {'N',6,0,87,' '}) // NÚMERO DA NOTA DE LANÇAMENTO
aAdd(aLayF501, {'C',1,0,93,' '}) // CÓDIGO DE LANÇAMENTO
aAdd(aLayF501, {'N',5,2,94,' '}) // HORAS
aAdd(aLayF501, {'C',95,0,99,' '}) // BRANCOS


//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// Laço em cada arquivo
aTudo := {}
aTudo2 := {}
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	//
	nPos = Len(cArquivo)
	if nPos = 0
		loop
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
		if Left(cStr,6)=="F50000"
			aInfo := ExtraiEDI(aLayF50,cStr)
			aAdd(aTudo,{aInfo[13], aInfo[12], aInfo[4], aInfo[5], aInfo[6], aInfo[15], aInfo[21], aInfo[14], aInfo[7],;
			aInfo[10],aInfo[11],aInfo[18],aInfo[37],aInfo[24], aInfo[25], aInfo[29], aInfo[30], aInfo[41], aInfo[26], aInfo[27],;
			aInfo[27] * aInfo[28], aInfo[33], aInfo[33] * aInfo[28], aInfo[29] * aInfo[31], aInfo[32], aInfo[3],IIF(aInfo[3]=="04",aInfo[17],aInfo[23])  } )
		elseif Left(cStr,6)=="F50001"
			aInfo := ExtraiEDI(aLayF501,cStr)
			aAdd(aTudo2, {aInfo[14], aInfo[15], aInfo[4], aInfo[6], aInfo[5], aInfo[9], aInfo[7], aInfo[8], aInfo[10], aInfo[12]})
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next

//aSort(aTudo, {
// Trabalhar com aInfo gravando as informações
GrvInfo(aInfo)
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
Cabec1 := " "
Cabec2 := " "
NomeProg := "OFINVW33"
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso

//                       8              6                   6                9
aSort(aTudo,,,{|x,y| x[26] + dtos(x[1]) + strzero(x[2],6) + strzero(x[3],6) + strzero(x[4],9) < y[26] + dtos(y[1]) + strzero(y[2],6) + strzero(y[3],6) + strzero(y[4],9)})
//
cChaveIni = space(100)
//
nContSeq = 0
cTipLista := SPACE(10)

aTot3 := {0, 0, 0, 0, 0, 0, 0 }

cAntLista := ""
for nCntFor := 1 to Len(aTudo)
	if(nCntFor==1)
		cAntLista := aTudo[nCntFor,26]
	endif
	if cTipLista != aTudo[nCntFor,26]
		cAntLista := cTipLista
		cTipLista := aTudo[nCntFor,26]
		cChaveIni = space(100)
	endif
	if Left(cChaveIni,20) != dtos(aTudo[nCntFor,1]) + strzero(aTudo[nCntFor,2],6) + strzero(aTudo[nCntFor,3],6)
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
		@li++,1 psay STR0002
		@li++,1 psay STR0003
		@li++,1 psay STR0004+dtoc(aTudo[nCntFor,1])
		@li++,1 psay STR0005 + STRZERO(aTudo[nCntFor,2],6) + SPACE(28)+ STR0006
		li++
		@li++,1 psay STR0007+strzero(aTudo[nCntFor,3],7)
		li++
		li++
		@li++,1 psay STR0008+IIF(cAntLista $"04.05",STR0009,"")
		@li++,1 psay STR0010
		li++
		nContSeq = 0
		cChaveIni := dtos(aTudo[nCntFor,1]) + strzero(aTudo[nCntFor,2],6) + strzero(aTudo[nCntFor,3],6) + SPACE(6)
	endif
	if cChaveIni != dtos(aTudo[nCntFor,1]) + strzero(aTudo[nCntFor,2],6) + strzero(aTudo[nCntFor,3],6) + strzero(aTudo[nCntFor,4],9)
		if nCntFor != 1
			if aTudo[nCntFor,26] == "03"
				@li++,1 psay repl("- ",63)
				@li++,1 psay SPACE(11) + ;
				STRZERO(aTot3[1],2) + "  "+ SPACE(31)+;
				Transform(aTot3[2],"@E 9999.99") + " "+;
				Transform(aTot3[3],"@E 99,999,999.99") + " "+;
				Transform(aTot3[4],"@E 9999.99") + " "+;
				Transform(aTot3[5],"@E 99,999,999.99") + " "+;
				Transform(aTot3[6],"@E 99,999,999,999.99") + " "+;
				Transform(aTot3[7],"@E 99,999,999,999.99")
				aTot3 := {0, 0, 0, 0, 0, 0, 0 }
			endif
		endif
		cChaveIni := dtos(aTudo[nCntFor,1]) + strzero(aTudo[nCntFor,2],6) + strzero(aTudo[nCntFor,3],6) + strzero(aTudo[nCntFor,4],9)
		nTotalVet = 0
		nVLoop := nCntFor
		while nVLoop <= Len(aTudo) .and. cChaveIni == dtos(aTudo[nVLoop,1]) + strzero(aTudo[nVLoop,2],6) + strzero(aTudo[nVLoop,3],6)+ strzero(aTudo[nVLoop,4],9)
			nTotalVet += aTudo[nVLoop,25]+aTudo[nVLoop,24]+aTudo[nVLoop,23]+aTudo[nVLoop,21]
			nVLoop++
		enddo
		li++
		@li++,1 psay ;
		Right(STR(aTudo[nCntFor,4]),6) + "  "+;
		STRZERO(aTudo[nCntFor,5],3) + " "+;
		aTudo[nCntFor,6] + "  "+;
		aTudo[nCntFor,7] + "  "+;
		aTudo[nCntFor,8] + " "+;
		aTudo[nCntFor,9] + "  "+;
		Left(dtoc(aTudo[nCntFor,10]),6)+Right(dtoc(aTudo[nCntFor,10]),2) + "  "+;
		Left(dtoc(aTudo[nCntFor,11]),6)+Right(dtoc(aTudo[nCntFor,11]),2) + "  "+;
		STRZERO(aTudo[nCntFor,12],7) + "  "+;
		Left(aTudo[nCntFor,13] +SPACE(37),37) + " " +;
		Transform(nTotalVet,"@E 99,999,999,999.99")
		nContSeq = 0
	endif
	nContSeq++
	@li++,1 psay " " + ;
	strzero(nContSeq,2)+" "+;
	aTudo[nCntFor,14] + " "+;
	aTudo[nCntFor,15] + " "+;
	STRZERO(aTudo[nCntFor,16],2) + "  "+;
	aTudo[nCntFor,17] + " "+;
	aTudo[nCntFor,18] + "  "+;
	aTudo[nCntFor,19] + " "+;
	Transform(  aTudo[nCntFor,20],"@E 99.99") + " "+;
	Transform(  aTudo[nCntFor,21],"@E 99,999,999.99") + " "+;
	Transform(  aTudo[nCntFor,22],"@E 9999.99") + " "+;
	Transform(  aTudo[nCntFor,23],"@E 99,999,999.99") + " "+;
	Transform(  aTudo[nCntFor,24],"@E 99,999,999,999.99") + " "+;
	Transform(  aTudo[nCntFor,25],"@E 99,999,999,999.99") + " " +;
	IIF(aTudo[nCntFor,26] $ "04.05",aTudo[nCntFor,27], "" )
	aTot3[1] += aTudo[nCntFor,16]
	aTot3[2] += aTudo[nCntFor,20]
	aTot3[3] += aTudo[nCntFor,21]
	aTot3[4] += aTudo[nCntFor,22]
	aTot3[5] += aTudo[nCntFor,23] 
	aTot3[6] += aTudo[nCntFor,24]
	aTot3[7] += aTudo[nCntFor,25]
	if li > 65
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
	endif
next
if cTipLista == "03"
	@li++,1 psay repl("- ",63)
	@li++,1 psay SPACE(11) + ;
	STRZERO(aTot3[1],2) + "  "+ SPACE(31)+;
	Transform(aTot3[2],"@E 9999.99") + " "+;
	Transform(aTot3[3],"@E 99,999,999.99") + " "+;
	Transform(aTot3[4],"@E 9999.99") + " "+;
	Transform(aTot3[5],"@E 99,999,999.99") + " "+;
	Transform(aTot3[6],"@E 99,999,999,999.99") + " "+;
	Transform(aTot3[7],"@E 99,999,999,999.99")
endif

nTot3 :=0
cChaveIni = space(100)
for nCntFor := 1 to Len(aTudo2)
	if cChaveIni != dtos(aTudo2[nCntFor,1]) + strzero(aTudo2[nCntFor,2],6) + strzero(aTudo2[nCntFor,3],6)
		if nCntFor != 1
  			@li++,76 psay Transform(  aTudo2[nCntFor,9],"@E 99,999,999.99")
	  	endif
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
		@li++,1 psay STR0002
		@li++,1 psay STR0003
		@li++,1 psay STR0011+dtoc(aTudo2[nCntFor,1])
		@li++,1 psay STR0005 + STRZERO(aTudo2[nCntFor,2],6) + SPACE(28)+ STR0006
		li++
		@li++,1 psay STR0007+strzero(aTudo2[nCntFor,3],7)
		li++
		li++
		@li++,1 psay STR0012
		li++
		cChaveIni := dtos(aTudo2[nCntFor,1]) + strzero(aTudo2[nCntFor,2],6) + strzero(aTudo2[nCntFor,3],6) + SPACE(6)
		nTot3 :=0
	endif
	@li++,1 psay  ;
	STRZERO(aTudo2[nCntFor,4],2) + "    " + ;
	STRZERO(aTudo2[nCntFor,5],6) + "       " + ;
	aTudo2[nCntFor,6] + "                " + ;
	Left(dtoc(aTudo2[nCntFor,7]),6)+Right(dtoc(aTudo2[nCntFor,7]),2) + "  " + ;
	STRZERO(aTudo2[nCntFor,8],7) + "      " + ;
	Transform(  aTudo2[nCntFor,9],"@E 99,999,999.99")
	nTot3 += aTudo2[nCntFor,9]
	if li > 65
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
	endif
next
if Len(aTudo2) > 0
	@li++,76 psay Transform(  nTot3,"@E 99,999,999.99")
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
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,2)
		if ctod(cStrTexto) == ctod("  /  /  ")
			ncValor := ctod(cStrTexto)
		endif
		ncValor := ctod(cStrTexto)
	elseif Alltrim(cTipo) == "I"
		cStrTexto := Right(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Left(cStrTexto,2)
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
