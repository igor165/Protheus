#include "protheus.ch"

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �M100TIM   �Autor  �Rubens Joao Pante      � Data �  23/01/01   ���
����������������������������������������������������������������������������͹��
���Descricao �Executa a funcao propria a cada pais para o calculo do Timbre  ���
����������������������������������������������������������������������������Ĵ��
���Uso       �MATA101                                                        ���
����������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ���
����������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                      ���
����������������������������������������������������������������������������Ĵ��
���              �        �      �                                           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function M100TIM(cCalculo,nItem,aInfo)
Local aItemInfo, aImposto, nDesconto, lXFis,xRet
Local aCfg		:= {}
Local dDtProc	:= Ctod("//")
Local nMoeda	:= 1
Local nTxMoeda	:= 1

If Type("dDEmissao")=="D"
	dDtProc := dDEmissao
Else
	dDtProc:= dDatabase
Endif

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If lXFis
	xRet:=M100TIMFIS(cCalculo,nItem,aInfo)
Else
	aItemINFO := ParamIxb[1]
	aImposto  := ParamIxb[2]
	//mesmo tratamento da impgener
	If Substr(cModulo,1,3) $ "FAT|OMS"
		If Type("L468NPED")=="L" .And. !l468NPed
			nMoeda	 := SF2->F2_MOEDA
			nTxMoeda := SF2->F2_TXMOEDA
		Else
			nMoeda   := SC5->C5_MOEDA
			nTxMoeda := SC5->C5_TXMOEDA
		Endif
		If nMoeda > 1 .and. nTxMoeda <= 1
			nTxMoeda := RecMoeda(dDataBase,nMoeda)
		Endif
	Endif
	//Tira os descontos se for pelo liquido .Bruno
	If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
		nDesconto	:=	aImposto[18]
	Else
		nDesconto	:=	0
	Endif
	aCfg := M100TimCfg(aImposto[1],,dDtProc,.T.,.F.)
	aImposto[2] := aCfg[1]
		aImposto[3] := (aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto)
	
	nMinimo := xMoeda(aImposto[3],nMoeda,1,,,,nTxMoeda)
	
	If nMinimo > aCfg[2]
		aImposto[4] := aImposto[3] * (aImposto[2]/100)
	Else
		aImposto[4] := 0
	Endif
	xRet:=aImposto
Endif
Return xRet
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �M100TIMFIS�Autor  �Rubens Joao Pante      � Data �  23/01/01   ���
����������������������������������������������������������������������������͹��
���Descricao �Executa a funcao propria a cada pais para o calculo do Timbre  ���
���          �Alterado para ser utilizado juntamente a MATXFIS()             ���
����������������������������������������������������������������������������Ĵ��
���Uso       �MATA101                                                        ���
����������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ���
����������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                      ���
����������������������������������������������������������������������������Ĵ��
���              �        �      �                                           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function M100TIMFIS(cCalculo,nItem,aInfo)
Local nVRet		:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local nMoeda	:= 1
Local nTxMoeda	:= 1
Local nMinimo	:= 0
Local aCfg		:= {}
Local dDtProc	:= Ctod("//")

If Type("dDEmissao")=="D"
	dDtProc := dDEmissao
Else
	dDtProc:= dDatabase
Endif

Do Case
	Case cCalculo=="A"
		aCfg := M100TimCfg(aInfo[1],,dDtProc)
		nVRet := aCfg[1]
	Case cCalculo=="B"	
		aCfg := M100TimCfg(aInfo[1],,dDtProc,,.T.)
		nVRet := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If aCfg[4] == "S"
			nVRet -= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Case cCalculo=="V"
		aCfg := M100TimCfg(aInfo[1],MaFisRet(nItem,"IT_TES"),dDtProc,.T.,.T.)
		nVRet := 0
		nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
		If aCfg[3] == "T"
	      	nBase := MaRetBasT(aInfo[2],nItem,nAliq)
		Else 
			nBase := MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
		Endif
		nMoeda := MaFisRet(,"NF_MOEDA")
		If nMoeda > 1
			nTxMoeda := MaFisRet(,"NF_TXMOEDA")
			nMinimo := xMoeda(nBase,nMoeda,1,,,,nTxMoeda)
		Else
			nMinimo := nBase
		Endif
		If nMinimo > aCfg[2]
			nVRet:=(nBase * nAliq) / 100
		Endif
EndCaSe
Return(nVRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100TIMCFG�Autor  �Marcello            �Fecha � 05/08/2009  ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica a configuracao do imposto (aliquota, valor minimo  ���
���          �etc).                                                       ���
���          �Parametros: cImposto - codigo do imposto                    ���
���          �            cTes     - TES                                  ���
���          �            dRefer   - data de referencia para verificacao  ���
���          �            lVal     - indica se verifica a aliquota e      ���
���          �                       minimo                               ���
���          �            lCalc    - indica se verifica se o calculo      ���
���          �                       sera sobre item ou total, liquido ou ���
���          �                       sera sobre item ou total, liquido ou ���
���          �                       bruto                                ���
���          �Retorno: array com 4 itens                                  ���
���          �                1 - aliquota                                ���
���          �                2 - valor minimo                            ���
���          �                3 - calculo (I = item ou T = total)         ���
���          �                4 - Liquido (S = liquido N = bruto)         ���
�������������������������������������������������������������������������͹��
���Uso       � M100TIM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100TimCfg(cImposto,cTes,dRefer,lVal,lCalc)
Local nAlq		:= 0
Local nMin		:= 0
Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local cSobre	:= "I"
Local cValor	:= "S"
Local cQuery	:= ""
Local cAliasSFF	:= ""
Local cFilSFF	:= xFilial("SFF")
Local lVerif	:= .F.
Local aRet		:= {}
Local aArea		:= {}

Default cImposto	:= ""
Default cTes		:= ""
Default dRefer		:= dDatabase
Default lCalc		:= .F.
Default lVal		:= .T.

aArea := GetArea()
SFB->(dbSetOrder(1))
If lVal
	If SFB->(dbSeek(xFilial("SFB")+cImposto))
		If SFB->FB_FLAG != "1"
			SFB->(RecLock("SFB",.F.))
			SFB->FB_FLAG := "1"
			SFB->(MSUnlock())
		Endif
		nAlq := SFB->FB_ALIQ
		If SFB->FB_TABELA == "S"
			cQuery := ""
			cAliasSFF := ""
			lVerif := .F.
			#IFDEF TOP
				cQuery := "select FF_ALIQ,FF_FXDE from " + RetSqlName("SFF")
				cQuery += " where FF_FILIAL = '" + cFilSFF + "'"
				cQuery += " and FF_IMPOSTO = '" + cImposto + "'"
				cQuery += " and FF_DATAVLD >= '" + Dtos(dRefer) + "'"
				cQuery += " and D_E_L_E_T_=''"
				cAliasSFF := GetNextAlias()
				cQuery:=ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSFF,.F.,.T.)
				(cAliasSFF)->(DbGoTop())
				If !((cAliasSFF)->(Eof()))
					nAlq := (cAliasSFF)->FF_ALIQ
					nMin := (cAliasSFF)->FF_FXDE
				Endif
				DbSelectArea(cAliasSFF)
				DbCloseArea()
			#ELSE
				SFF->(DbSetOrder(9))
				If SFF->(DbSeek(cFilSFF + cImposto))
					lVerif := .F.
					While !lVerif .And. (SFF->FF_FILIAL == cFilSFF) .And. (FF_IMPOSTO == cImposto)
						If dRefer <= SFF->FF_DATAVLD
							lVerif := .T.
							nAlq := SFF->FF_ALIQ
							nMin := SFF->FF_FXDE
						Endif
						SFF->(DbSkip())
					Enddo
				Endif
			#ENDIF
		Endif
	Endif
Endif
If lCalc
	nOrdSFC := (SFC->(IndexOrd()))
	nRegSFC := (SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC") + cTES + cImposto)))
		cSobre := SFC->FC_CALCULO
		cValor := SFC->FC_LIQUIDO
	Endif
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
Endif
aRet := {nAlq,nMin,cSobre,cValor}
RestArea(aArea)
Return(aClone(aRet))
