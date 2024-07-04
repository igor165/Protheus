// �����������������ͻ
// � Versao � 2      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW11.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW11   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o VW Assunto FP5 - Reconhecimento do Pedido de Pecas|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW11(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFP5 := {}
Private cPedAnt := "inicial"
//
aAdd(aLayFP5, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FP5)"})
aAdd(aLayFP5, {"N",7,0,4," " }) 	// "NUMERO DO PEDIDO VOLKSWAGEN"})
aAdd(aLayFP5, {"N",2,0,11," " }) 	// "TIPO DO PEDIDO"})
aAdd(aLayFP5, {"C",13,0,13," " }) 	// "NUMERO DO PEDIDO REVENDEDOR"})
aAdd(aLayFP5, {"D",8,0,26," " }) 	// "DATA DO PROCESSAMENTO (ddmmaaaa)"})
aAdd(aLayFP5, {"D",8,0,34," " }) 	// "DATA DA ALOCA��O (ddmmaaaa)"})
aAdd(aLayFP5, {"C",20,0,42," " }) 	// "NUMERO DA PE�A"})
aAdd(aLayFP5, {"N",7,0,62," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,69," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,76," " }) 	// "STATUS C�DIGO DE CONSIST�NCIA"})
aAdd(aLayFP5, {"C",20,0,77," " }) 	// "NUMERO DA PE�A"})
aAdd(aLayFP5, {"N",7,0,97," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,104," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,111," " }) 	// "STATUS C�DIGO DE CONSIST�NCIA"})
aAdd(aLayFP5, {"C",20,0,112," " }) 	// "NUMERO DA PE�A"})
aAdd(aLayFP5, {"N",7,0,132," " }) 	// "QUANTIDADE PEDIDA"})
aAdd(aLayFP5, {"N",7,0,139," " }) 	// "QUANTIDADE BACK ORDER"})
aAdd(aLayFP5, {"C",1,0,146," " }) 	// "STATUS C�DIGO DE CONSIST�NCIA"})
aAdd(aLayFP5, {"C",41,0,147," " }) 	// "BRANCOS"})
aAdd(aLayFP5, {"N",6,0,188," " }) 	// "VERS�O DO LAYOUT (FIXO: 220800)"})
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
		if Left(cStr,3)=="FP5"
			aInfo := ExtraiEDI(aLayFP5,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,3)=="FP5"
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
if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++,1 psay " "
endif
//
for nCntFor := 7 to 15 step 4
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
	if cPedAnt != STRZERO(aInfo[2],7)
		@li++,1 psay cTipPed + "  " + STRZERO(aInfo[2],7) + " / " + aInfo[4] + STR0012 + dtoc(aInfo[5]) + STR0013 + dtoc(aInfo[6])
		cPedAnt := STRZERO(aInfo[2],7)
	endif
	//
	cStaCon := STR0014
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="A", STR0015, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="B", STR0016, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="C", STR0017, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="D", STR0018, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="E", STR0019, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="F", STR0020, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="G", STR0021, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="H", STR0022, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="I", STR0023, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="J", STR0024, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="K", STR0025, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="L", STR0026, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="Z", STR0027, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="P", STR0028, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="Q", STR0029, cStaCon)
	cStaCon := IIF(aInfo[3]==0 .AND. aInfo[nCntFor + 3]=="V", STR0030, cStaCon)
	//
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]==" ", STR0031, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="R", STR0032, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="S", STR0033, cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="T", STR0034,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "01.03.04.05.06.11.12" .and. aInfo[nCntFor + 3]=="U", STR0035,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="M", STR0036,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="N", STR0037,cStaCon)
	cStaCon := IIF(STRZERO(aInfo[3],2) $ "08.09" .and. aInfo[nCntFor + 3]=="O", STR0038,cStaCon)
	//
	if !Empty(aInfo[nCntFor])
		@li++,1 psay aInfo[nCntFor] + STR0039 + STRZERO(aInfo[nCntFor+1],7) + "/" + STRZERO(aInfo[nCntFor+2],7)+ " " + cStaCon
	endif
	if li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li++,1 psay " "
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