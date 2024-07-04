// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW23.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW23   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação do Layout referente aquisição de Autos   			|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW23(lEnd, cArquivo)
//
Local nCurArq

Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}
//
aAdd(aLayoutFN0, {"C",	3	,0,	001," "}) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	5	,0,	004," "}) // "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	179, 0,	009," "}) // "CABEÇALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188," "}) // "LAYOUT VERSÃO (Fixo: 040501)"})

aAdd(aLayoutFN1, {	"C",3,0,001," "}) //"TIPO DE REGISTRO (FCR)"})
aAdd(aLayoutFN1, {	"N",5,0,004," "}) //"SUB-CÓDIGO DO REGISTRO (Fixo=32101)"})
aAdd(aLayoutFN1, {	"N",6,0,009," "}) //"NÚMERO DA NOTA FISCAL FATURA"})
aAdd(aLayoutFN1, {	"N",2,0,015," "}) //"SUFIXO DA NOTA"})
aAdd(aLayoutFN1, {	"D",8,0,017," "}) //"DATA DE EMISSÃO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"D",8,0,025," "}) //"DATA DO PRIMEIRO VENCIMENTO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"D",8,0,033," "}) //"DATA DO SEGUNDO VENCIMENTO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"N",15,2,041," "}) //"VALOR DA DUPLICATA"})
aAdd(aLayoutFN1, {	"N",15,2,056," "}) //"VALOR PAGO"})
aAdd(aLayoutFN1, {	"N",15,2,071," "}) //"SALDO DEVEDOR"})
aAdd(aLayoutFN1, {	"N",15,2,086," "}) //"VALOR DO ADICIONAL PAGO"})
aAdd(aLayoutFN1, {	"N",15,2,101," "}) //"VALOR DO ACRÉSCIMO"})
aAdd(aLayoutFN1, {	"C",2,0,116," "}) //"CÓDIGO DE CONDIÇÃO DA NOTA FISCAL"})
aAdd(aLayoutFN1, {	"D",8,0,118," "}) //"DATA DA OPERAÇÃO (ddmmaaaa)"})
aAdd(aLayoutFN1, {	"C",4,0,126," "}) //"TIPO DE DOCUMENTO"})
aAdd(aLayoutFN1, {	"C",40,0,130," "}) //"DESCRIÇÃO DO TIPO DE DOCUMENTO"})
aAdd(aLayoutFN1, {	"C",24,0,170," "}) //"BRANCOS"})

aAdd(aLayoutFN2, {"C",	3	,0,	001," "}) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	5	,0,	004," "}) // "SUB-CÓDIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	185 ,0,	009," "}) // "CABEÇALHO FINAL A SER IMPRESSO"})
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
		if Left(cStr,8)=="FCR32100"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,8)=="FCR32101"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,8)=="FCR32102"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,8) $ "FCR32100.FCR32101.FCR32102"
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
Local ni
//
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif
if aInfo[2] == 32100
	For ni := 1 to Len(Alltrim(aInfo[3])) STEP 70
		@li ++ ,1 psay SUBS(Alltrim(aInfo[3]),ni,70)
	next
elseif aInfo[2] == 32101
	cSufixoNF := IIF(aInfo[4] == 0,STR0021,IIF(aInfo[4] == 1,STR0022,STR0023))
	@li++ ,1 psay  Alltrim(STR(aInfo[3])) + " - " + cSufixoNF
	@li++ ,1 psay  STR0024 + dtoc(aInfo[5])
	@li++ ,1 psay  STR0025 + dtoc(aInfo[6])
	@li++ ,1 psay  STR0026 + dtoc(aInfo[7])
	@li++ ,1 psay  STR0027 + dtoc(aInfo[14])
	@li++ ,1 psay  STR0028 + Transform(aInfo[8],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0029 + Transform(aInfo[9],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0030 + Transform(aInfo[10],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0031 + Transform(aInfo[11],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0032 + Transform(aInfo[12],"@E 9999,999,999,999.99")
	@li++ ,1 psay  STR0033 + Alltrim(aInfo[13])
	@li++ ,1 psay  aInfo[15] + " - " + aInfo[16]
elseif aInfo[2] == 32102
	For ni := 1 to Len(Alltrim(aInfo[3])) STEP 70
		@li ++ ,1 psay SUBS(Alltrim(aInfo[3]),ni,70)
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
