// �����������������ͻ
// � Versao � 3      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW10.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW10   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o VW Assunto FL3 - Lista de Pre�os de Pe�as         |##
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
aAdd(aLayFL3, {"C",20,0,4," " }) 	// "N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFL3, {"C",13,0,24," " }) 	// "DESCRI��O RESUMIDA DA PE�A"})
aAdd(aLayFL3, {"N",11,2,37," " }) 	// "PRE�O P�BLICO"})
aAdd(aLayFL3, {"N",11,2,48," " }) 	// "PRE�O REPOSI��O"})
aAdd(aLayFL3, {"N",11,2,59," " }) 	// "PRE�O GARANTIA"})
aAdd(aLayFL3, {"C",3,0,70," " }) 	// "PART CLASS"})
aAdd(aLayFL3, {"N",7,0,73," " }) 	// "QUANTIDADE M�NIMA - VENDA 1"})
aAdd(aLayFL3, {"N",7,0,80," " }) 	// "QUANTIDADE M�NIMA - VENDA 2"})
aAdd(aLayFL3, {"N",7,0,87," " }) 	// "QUANTIDADE M�NIMA - VENDA 3"})
aAdd(aLayFL3, {"C",2,0,94," " }) 	// "GRUPO DE DESCONTO"})
aAdd(aLayFL3, {"C",10,0,96," " }) 	// "CLASSIFICA��O FISCAL"})
aAdd(aLayFL3, {"N",4,2,106," " }) 	// "TAXA DE IPI"})
aAdd(aLayFL3, {"N",7,3,110," " }) 	// "PESO"})
aAdd(aLayFL3, {"C",1,0,118," " }) 	// "PE�A DSH (DIRECT SHIPMENT)"})
aAdd(aLayFL3, {"N",5,4,119," " }) 	// "FATOR DE DESCONTO (FD)"})
aAdd(aLayFL3, {"C",50,0,124," " }) 	// "DESCRI��O EXPANDIDA DA PE�A"})
aAdd(aLayFL3, {"C",1,0,174," " }) 	// "IMPOSTO PIS"})
aAdd(aLayFL3, {"C",1,0,175," " }) 	// "IMPOSTO COFINS"})
aAdd(aLayFL3, {"C",1,0,176," " }) 	// "TIPO DO ITEM (N�mero da Pe�a)"})
aAdd(aLayFL3, {"C",11,0,177," " }) 	// "BRANCOS"})
aAdd(aLayFL3, {"N",6,0,188," " }) 	// "VERS�O DO LAYOUT (FIXO: 190706)"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// La�o em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o pr�ximo arquivo
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
		// Informa��es extra�das da linha do arquivo de importa��o ficam no vetor aInfo
		if Left(cStr,3)=="FL3"
			aInfo := ExtraiEDI(aLayFL3,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
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
##|Fun��o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa��o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
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
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 ���
����������������������������������������������������������������������������͹��
���Descricao� Monta vetores a partir de uma descri��o de layout e da linha de���
���         � importa��o EDI                                                 ���
����������������������������������������������������������������������������͹��
��� Retorno � aRet - Valores extra�dos da linha                              ���
���         �        Se der erro o vetor retorna {}                          ���
����������������������������������������������������������������������������͹��
���Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) ���
���         � aLayout[n,2] = Tamanho do Campo                                ���
���         � aLayout[n,3] = Quantidade de Decimais do Campo                 ���
���         � aLayout[n,4] = Posi��o Inicial do Campo na Linha               ���
���         �                                                                ���
���         � cLinhaEDI    = Linha para extra��o das informa��es             ���
����������������������������������������������������������������������������͹��
���                                                                          ���
���  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    ���
���                                                                          ���
���  aAdd(aLayout,{"C",10,0,1})                                              ���
���  aAdd(aLayout,{"C",20,0,11})                                             ���
���  aAdd(aLayout,{"N",5,2,31})                                              ���
���  aAdd(aLayout,{"N",4,0,36})                                              ���
���                        1         2         3                             ���
���               123456789012345678901234567890'123456789                   ���
���  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    ���
���                                                                          ���
���  No caso acima o retorno seria:                                          ���
���  aRet[1] - "Jose Silva"                                                  ���
���  aRet[2] - "Vendedor Externo"                                            ���
���  aRet[3] - 123,12                                                        ���
���  aRet[4] - 1234                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
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