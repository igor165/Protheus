// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 4      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW24.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW24   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação do Layout referente aquisição a Prazo    			|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW24(lEnd, cArquivo)
//
Local nCurArq
//
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}

Private nAnt := 0

aAdd(aLayoutFN0, {"C",	3	,0,	001," " }) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	5	,0,	004," " }) // "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	179, 0,	009," " }) // "CABEÇALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188," " }) // "LAYOUT VERSÃO (Fixo: 040501)"})

aAdd(aLayoutFN1, {	"C",3,0,001," " }) // "TIPO DE REGISTRO (FCR)"				   })
aAdd(aLayoutFN1, {	"N",5,0,004," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=32001)"	   })
aAdd(aLayoutFN1, {	"N",6,0,009," " }) // "NÚMERO DA NOTA FISCAL FATURA"			   })
aAdd(aLayoutFN1, {	"N",2,0,015," " }) // "SUFIXO DA NOTA"						   })
aAdd(aLayoutFN1, {	"N",1,0,017," " }) // "TIPO DA NOTA"							   })
aAdd(aLayoutFN1, {	"D",8,0,018," " }) // "DATA DE EMISSÃO (ddmmaaaa)"			   })
aAdd(aLayoutFN1, {	"D",8,0,026," " }) // "DATA DO PRIMEIRO VENCIMENTO (ddmmaaaa)"  })
aAdd(aLayoutFN1, {  "D",8,0,034," " }) // "DATA DO SEGUNDO VENCIMENTO (ddmmaaaa)"    })
aAdd(aLayoutFN1, {	"N",15,2,042," " }) //"VALOR DA DUPLICATA"					   })
aAdd(aLayoutFN1, {	"N",15,2,057," " }) //"VALOR PAGO"							   })
aAdd(aLayoutFN1, {	"N",15,2,072," " }) //"SALDO DEVEDOR"						   })
aAdd(aLayoutFN1, {	"D",8,0,087," " }) // "DATA DO PAGAMENTO (ddmmaaaa)"			   })
aAdd(aLayoutFN1, {	"C",4,0,095," " }) // "TIPO DE DOCUMENTO"					   })
aAdd(aLayoutFN1, {	"N",6,0,099," " }) // "NÚMERO DO DN INTERNO"					   })
aAdd(aLayoutFN1, {	"N",1,0,105," " }) // "FÁBRICA NÚMERO"						   })
aAdd(aLayoutFN1, {	"C",88,0,106," " }) //"BRANCOS"								   })

aAdd(aLayoutFN2, {"C",	3	,0,	001," " }) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	5	,0,	004," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	185 ,0,	009," " }) // "CABEÇALHO FINAL A SER IMPRESSO"})
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
		if Left(cStr,8)=="FCR32000"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,8)=="FCR32001"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,8)=="FCR32002"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,8) $ "FCR32000.FCR32001.FCR32002"
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
Titulo := STR0038
Cabec1 := " "
Cabec2 := ""
cCab := STR0039
NomeProg := "OFINVW24"
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if aInfo[2] == 32000
	if nAnt == 32002 .or.nAnt == 32001
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li ++ ,1 psay " "
	endif 
	@li ++ ,1 psay Alltrim(aInfo[3])
	nAnt := 32000
elseif aInfo[2] == 32001
	if nAnt != 32001
		@li ++ ,1 psay cCab
	endif
	cSufixoNF := IIF(aInfo[4] == 0,STR0021,IIF(aInfo[4] == 1,STR0022,STR0023))
	cTipoNF := IIF(aInfo[5] == 1,STR0024,IIF(aInfo[5] == 2,STR0025,IIF(aInfo[5] == 2,STR0026,STR0027)))
	@li ++ ,1 psay  ;
	STRZERO(aInfo[3],9)  + "  " +  Left(dtoc(aInfo[6])+space(10),10) + " " +  Left(dtoc(aInfo[7])+space(10),10) + " " + Left(dtoc(aInfo[8])+space(10),10) + " " + Left(dtoc(aInfo[12])+space(10),10) + " " + ;
	Transform(aInfo[9],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[10],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[11],"@E 999,999,999,999.99") + " " + ;
	aInfo[13] + " " + STRZERO(aInfo[14],6) + " " + cTipoNF + " " + cSufixoNF +" "+ strzero(aInfo[15],1)
	nAnt := 32001
elseif aInfo[2] == 32002
	@li ++ ,1 psay Alltrim(aInfo[3])
	nAnt := 32002
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
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
