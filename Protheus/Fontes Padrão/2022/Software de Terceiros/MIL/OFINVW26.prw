// �����������������ͻ
// � Versao � 2      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW26.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW26   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o do Layout referente a Posi��o do Fundo Apolo      |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW26(lEnd, cArquivo)
//
Local nCurArq
//
//
Local aLayoutFA1 := {}
Local aLayoutFA2 := {}
//
aAdd(aLayoutFA1, { "C", 3, 0, 001," " }) // "TIPO DE REGISTRO (FA1)" })
aAdd(aLayoutFA1, { "N", 14, 2, 004," " }) //  "TOTAL ABERTO DIA" })
aAdd(aLayoutFA1, { "C", 1, 0, 018," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14, 2, 019," " }) //  "TOTAL DISPON�VEL DIA" })
aAdd(aLayoutFA1, { "C", 1, 0, 033," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14, 2, 034," " }) //  "TOTAL DO FUNDO DIA" })
aAdd(aLayoutFA1, { "C", 1,0, 048," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 049," " }) //  "DESCONTO DO DIA" })
aAdd(aLayoutFA1, { "C", 1,0, 063," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 064," " }) //  "DESCONTO DO FUNDO" })
aAdd(aLayoutFA1, { "C", 1,0, 078," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 079," " }) //  "DESCONTO DO PRAZO" })
aAdd(aLayoutFA1, { "C", 1,0, 093," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 094," " }) //  "DESCONTO FROTISTA" })
aAdd(aLayoutFA1, { "C", 1,0, 108," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 109," " }) //  "PAGAMENTOS DO FUNDO" })
aAdd(aLayoutFA1, { "C", 1,0, 123," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "N", 14,2, 124," " }) //  "FATURAMENTO DO FUNDO" })
aAdd(aLayoutFA1, { "C", 1,0, 138," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA1, { "C", 55,0, 139," " }) //  "BRANCOS" })

aAdd(aLayoutFA2, { "C",3, 0, 001," " }) //  "TIPO DE REGISTRO (FA2)" })
aAdd(aLayoutFA2, { "N",14, 2, 004, " " }) // "CANCELAMENTO DO FUNDO" })
aAdd(aLayoutFA2, { "C",1, 0, 018," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14,2, 019," " }) //  "CANCELAMENTO DESCONTO" })
aAdd(aLayoutFA2, { "C",1, 0, 033," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14, 2, 034, " " }) // "CANC. DESCONTO DO FUNDO" })
aAdd(aLayoutFA2, { "C",1, 0, 048," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14, 2, 049," " }) //  "RESUL. L�Q.DISTRIBU�DO	" })
aAdd(aLayoutFA2, { "C",1, 0, 063," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14 , 2, 064," " }) // "EM ABERTO FUNDO ATUAL" })
aAdd(aLayoutFA2, { "C",1, 0, 078," " }) //  "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14 , 2, 079," " }) // "DISPON�VEL ATUAL" })
aAdd(aLayoutFA2, { "C",1, 0, 093," " }) //   "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14 , 2, 094," " }) // "TOTAL FUNDO ATUAL" })
aAdd(aLayoutFA2, { "C",1, 0, 108," " }) //   "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "N",14, 2, 109," " }) //  "MULTAS DO FUNDO"  })
aAdd(aLayoutFA2, { "C",1, 0, 123," " }) //   "SINAL (+  ou  -)"  })
aAdd(aLayoutFA2, { "N",14, 2, 124," " }) //  "ADICIONAL / COMPLEMENTO" })
aAdd(aLayoutFA2, { "C",1, 0, 138," " }) //   "SINAL (+  ou  -)" })
aAdd(aLayoutFA2, { "C",55 ,0, 139," " }) //  "BRANCOS" })

aAdd(aIntCab,{STR0020,"C",145,"@!"})
aAdd(aIntCab,{STR0021,"N",45,"@E 9999,999,999,999.99"})
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
		if Left(cStr,3)=="FA1"
			aInfo := ExtraiEDI(aLayoutFA1,cStr)
		elseif Left(cStr,3)=="FA2"
			aInfo := ExtraiEDI(aLayoutFA2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,3) $ "FA1.FA2"
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
##|Fun��o    | ImprimeRel | Autor | Luis Delorme          | Data | 17/03/13 |##
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
if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0019 + Alltrim(STR(nLinhArq))
endif
//
if aInfo[1] == "FA1"
	@li ++ ,1 psay STR0022 + Transform(aInfo[2] * IIF(aInfo[3]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0023 + Transform(aInfo[4] * IIF(aInfo[5]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0024 + Transform(aInfo[6] * IIF(aInfo[7]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0025 + Transform(aInfo[8] * IIF(aInfo[9]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0026 + Transform(aInfo[10] * IIF(aInfo[11]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0027 + Transform(aInfo[12] * IIF(aInfo[13]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0028 + Transform(aInfo[14] * IIF(aInfo[15]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0029 + Transform(aInfo[16] * IIF(aInfo[17]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0030 + Transform(aInfo[18] * IIF(aInfo[19]=="-", -1,1),"@E 999,999,999,999.99")
elseif aInfo[1] == "FA2"
	@li ++ ,1 psay STR0031 + Transform(aInfo[2] * IIF(aInfo[3]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0032 + Transform(aInfo[4] * IIF(aInfo[5]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0033 + Transform(aInfo[6] * IIF(aInfo[7]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0034 + Transform(aInfo[8] * IIF(aInfo[9]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0035 + Transform(aInfo[10] * IIF(aInfo[11]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0036 + Transform(aInfo[12] * IIF(aInfo[13]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0037 + Transform(aInfo[14] * IIF(aInfo[15]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0038 + Transform(aInfo[16] * IIF(aInfo[17]=="-", -1,1),"@E 999,999,999,999.99")
	@li ++ ,1 psay STR0039 + Transform(aInfo[18] * IIF(aInfo[19]=="-", -1,1),"@E 999,999,999,999.99")
endif
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
���               123456789012345678901234567890'123456789                    ���
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
//
return aRet
