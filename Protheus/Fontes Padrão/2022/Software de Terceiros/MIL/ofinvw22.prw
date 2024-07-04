// �����������������ͻ
// � Versao � 3      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW22.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW22   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o do Layout referente a NFs fat.debitadas em C/C    |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW22(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}

Private nAnt := 0
aAdd(aLayoutFN0, {"C",	3	,0,	001, " " }) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	4	,0,	004, " " }) //  "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	180, 0,	008,  " " }) // "CABE�ALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188,  " " }) // "LAYOUT VERS�O (Fixo: 040501)"})

aAdd(aLayoutFN1, {	"C",	3	,0,	001, " " }) // "TIPO DE REGISTRO (FCR)"				})
aAdd(aLayoutFN1, {	"N",	4	,0,	004, " " }) // "SUB-C�DIGO DO REGISTRO (Fixo=7501)"	})
aAdd(aLayoutFN1, {	"N",	6	,0,	008, " " }) // "N�MERO DA NOTA FISCAL FATURA"		})
aAdd(aLayoutFN1, {	"N",	2	,0,	014, " " }) // "SUFIXO DA NOTA"						})
aAdd(aLayoutFN1, {	"N",	1	,0,	016, " " }) // "TIPO DA NOTA"						})
aAdd(aLayoutFN1, {	"N",	1	,0,	017, " " }) // "F�BRICA N�MERO"						})
aAdd(aLayoutFN1, {	"D",	8	,0,	018, " " }) // "DATA DE EMISS�O (ddmmaaaa)"			})
aAdd(aLayoutFN1, {	"D",	8	,0,	026, " " }) // "DATA DO ENCARGO INICIAL (ddmmaaaa)"	})
aAdd(aLayoutFN1, {	"D",	8	,0,	034, " " }) // "DATA DO PAGAMENTO (ddmmaaaa)"		})
aAdd(aLayoutFN1, {	"N",	15	,2,	042, " " }) // "VALOR NOTA FISCAL FATURA"			})
aAdd(aLayoutFN1, {	"N",	15	,2,	057, " " }) // "VALOR DO DESCONTO"				    })
aAdd(aLayoutFN1, {	"N",	15	,2,	072, " " }) // "VALOR MULTA"						    })
aAdd(aLayoutFN1, {	"N",	15	,2,	087, " " }) // "VALOR JUROS MORA"					})
aAdd(aLayoutFN1, {	"N",	15	,2,	102, " " }) // "VALOR CORRE��O MONET�RIA"			})
aAdd(aLayoutFN1, {	"C",	4	,0,	117, " " }) // "TIPO DE DOCUMENTO"				    })
aAdd(aLayoutFN1, {	"C", 	40	,0,	121, " " }) // "DESCRI��O DO TIPO DE DOCUMENTO"		})
aAdd(aLayoutFN1, {	"C",	33	,0,	161, " " }) // "BRANCOS"							    })

aAdd(aLayoutFN2, {"C",	3	,0,	001, " " }) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	4	,0,	004, " " }) // "SUB-C�DIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	186,0,	008,  " " }) //"CABE�ALHO FINAL A SER IMPRESSO"})
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
		if Left(cStr,7)=="FCR7500"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,7)=="FCR7501"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,7)=="FCR7502"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,7) $ "FCR7500.FCR7501.FCR7502"
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
//
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Titulo := STR0039
Cabec1 := " "
Cabec2 := ""
cCab := STR0040
NomeProg := "OFINVW22"
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
	nAnt := 0
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif
//
if aInfo[2] == 7500
		@li ++ ,1 psay aInfo[3]
		nAnt := 7500
elseif aInfo[2] == 7501
	if nAnt != 7501
		@li ++ ,1 psay cCab
	endif
	cSufixoNF := IIF(aInfo[4] == 0,STR0021,IIF(aInfo[4] == 1,STR0022,STR0023))
	cTipoNF := IIF(aInfo[5] == 1,STR0024,IIF(aInfo[5] == 2,STR0025,IIF(aInfo[5] == 2,STR0026,STR0027)))
	@li ++ ,1 psay  ;
	STRZERO(aInfo[3],9)  + "  " +  Left(dtoc(aInfo[7])+space(10),10) + " " + Left(dtoc(aInfo[8])+space(10),10) + " " + Left(dtoc(aInfo[9])+space(10),10) + " " + ;
	Transform(aInfo[10],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[11],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[12],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[13],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[14],"@E 999,999,999,999.99") + " " + ;
	aInfo[15] + " " + cTipoNF+ " " + cSufixoNF + " " + strzero(aInfo[6],1) + " " + aInfo[16] 
	nAnt := 7501
elseif aInfo[2] == 7502
		@li ++ ,1 psay aInfo[3]
		nAnt := 7502
endif

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
		MsgStop(STR0037+ aInfo[1]+STRZERO(aInfo[2],5) + " - " + STRZERO(nCntFor,3))
		return {}
	endif
	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				MsgStop(STR0038+ aInfo[1] + " - " + STRZERO(nCntFor,3))
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
