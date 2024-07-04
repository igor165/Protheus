#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAP020  � Autor � Rafael Diogo Richter  � Data �07/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Array para o Painel On-line do tipo 5:                ���
���          �- Metas Alcancadas por Objetivos                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAP020() 										   	  			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = { cClick, aCabec, aValores }                       ���
���          � cClick   = Funcao p/ execucao do duplo-click no browse     ���
���          � aCabec   = Array contendo o cabecalho                      ���
���          � aValores = Array contendo os valores da lista       		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAP020()
Local cAliasTrb := ''
Local aCabec := {}
Local aValores := {}
Local aRetPanel := {}
Local lQuery := .F.

dbSelectArea("TBH")
dbSetOrder(1)

dbSelectArea("TBI")
dbSetOrder(1)

dbSelectArea("TAA")
dbSetOrder(1)

aCabec := {"Objetivo","Descri��o","Respons�vel","Nome","Metas"}

#IFDEF TOP
	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT TBH_CODOBJ, TBH_DESCRI, TBH_RESPON, QAA_NOME,(SELECT COUNT(TBI_OBJETI)
			FROM %Table:TBI% TBI
	 		WHERE TBI.TBI_FILIAL = %xFilial:TBI%
	 			AND TBI.%NotDel%
	 			AND TBI.TBI_OBJETI = TBH.TBH_CODOBJ
	 			AND TBI.TBI_META IN (SELECT TAA_CODPLA FROM %Table:TAA% TAA
	 				WHERE TAA.TAA_FILIAL = %xFilial:TAA%
	 					AND TAA.%NotDel%
	 					AND TAA.TAA_CODPLA = TBI.TBI_META
	 					AND TAA.TAA_META <= TAA.TAA_QTDATU
	 					AND TAA.TAA_PERCEN = 100 ) GROUP BY TBI.TBI_OBJETI) nMetas
		FROM %Table:TBH% TBH
		LEFT JOIN %Table:QAA% QAA ON QAA.QAA_FILIAL = %xFilial:QAA%
			AND QAA.%NotDel%
			AND QAA.QAA_MAT = TBH.TBH_RESPON
		WHERE TBH.TBH_FILIAL = %xFilial:TBH%
			AND TBH.%NotDel%
		ORDER BY TBH_CODOBJ
	EndSql

#ELSE

	dbSelectArea("TBH")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		nMetas := 0
		dbSelectArea("TBI")
		dbSetOrder(1)
		dbSeek(xFilial("TBI")+TBH->TBH_CODOBJ)
		While !Eof() .And. TBI->TBI_FILIAL == xFilial("TBI") .And. TBI->TBI_OBJETI == TBH->TBH_CODOBJ
			dbSelectArea("TAA")
			dbSetOrder(1)
			dbSeek(xFilial("TAA")+TBI->TBI_META)
			If TAA->TAA_META <= TAA->TAA_QTDATU .And. TAA->TAA_PERCEN == 100
				nMetas++
			EndIf
			dbSelectArea("TBI")
			dbSkip()
		End
		dbSelectArea("QAA")
		dbSetOrder(1)
		dbSeek(xFilial("QAA")+TBH->TBH_RESPON)
		aAdd(aValores, {TBH->TBH_CODOBJ, TBH->TBH_DESCRI, TBH->TBH_RESPON, QAA->QAA_NOME, nMetas})

		dbSelectArea("TBH")
		dbSkip()
	End
#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		(cAliasTrb)->(aAdd(aValores, {TBH_CODOBJ, TBH_DESCRI, TBH_RESPON, QAA_NOME, nMetas}))
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TBH")
	dbSetOrder(1)
EndIf

If Empty(aValores)
	aAdd(aValores, {'', '', '', '', 0})
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRetPanel := { Nil, aCabec, aValores }

Return aRetPanel