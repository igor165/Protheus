// �����������������ͻ
// � Versao � 2      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW12.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW12   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o VW Assunto FP6 - Status do Backorder              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW12(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFP6 := {}
Private cPedAnt := "inicial"
//
aAdd(aLayFP6, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FP6)"})
aAdd(aLayFP6, {"N",7,0,4," " }) 	// "NUMERO DO PEDIDO VOLKSWAGEN"})
aAdd(aLayFP6, {"N",2,0,11," " }) 	// "TIPO DE PEDIDO"})
aAdd(aLayFP6, {"C",13,0,13," " }) 	// "NUMERO DO PEDIDO REVENDEDOR"})
aAdd(aLayFP6, {"D",8,0,26," " }) 	// "DATA DO PROCESSAMENTO (ddmmaaaa)"})
aAdd(aLayFP6, {"C",20,0,34," " }) 	// "N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP6, {"N",7,0,54," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP6, {"N",11,2,61," " }) 	// "VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP6, {"C",20,0,72," " }) 	// "N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP6, {"N",7,0,92," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP6, {"N",11,2,99," " }) 	// "VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP6, {"C",20,0,110," " }) 	// "N�MERO DA PE�A (Volkswagen)"})
aAdd(aLayFP6, {"N",7,0,130," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP6, {"N",11,2,137," " }) 	// "VALOR BACK ORDER UNITARIO"})
aAdd(aLayFP6, {"C",1,0,148," " }) 	// "IDENTIFICA��O DO TIPO DE BACK ORDER"})
aAdd(aLayFP6, {"C",45,0,149," " }) 	// "BRANCOS"})
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
		if Left(cStr,3)=="FP6"
			aInfo := ExtraiEDI(aLayFP6,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,3)=="FP6"
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
Local nCntFor
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
for nCntFor := 6 to 12 step 3
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
	cStaCon := STR0012
	cStaCon := IIF(aInfo[15]=="A", STR0013 ,cStaCon)
	cStaCon := IIF(aInfo[15]=="B", STR0014 ,cStaCon)
	cStaCon := IIF(aInfo[15]=="C", STR0015 ,cStaCon)
	cStaCon := IIF(aInfo[15]=="D", STR0016 ,cStaCon)
	cStaCon := IIF(aInfo[15]=="F", STR0017 ,cStaCon)
	//
	if cPedAnt != STRZERO(aInfo[2],7)
		@li++,1 psay cTipPed + "  " + STRZERO(aInfo[2],7) + " / " + aInfo[4] + STR0018 + dtoc(aInfo[5]) + " "+cStaCon
		cPedAnt := STRZERO(aInfo[2],7)
	endif
	//
	if !Empty(aInfo[nCntFor])
		@li++,1 psay aInfo[nCntFor] + STR0019 + STRZERO(aInfo[nCntFor+1],7) + STR0020 + Transform(aInfo[nCntFor+2],"@E 999,999,999.99")
	endif
next
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
���               123456789012345678901234567890123456789                    ���
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