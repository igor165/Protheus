#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAP010  � Autor � Rafael Diogo Richter  � Data �06/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Array para o Painel On-line do tipo 5:                ���
���          �- Ocorrencias por Plano Emergencial                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAP010() 										   	  			     ���
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
Function SGAP010()
Local cAliasTrb := ''
Local aCabec := {}
Local aValores := {}
Local aRetPanel := {}
Local lQuery := .F.

dbSelectArea("TBB")
dbSetOrder(1)

dbSelectArea("TBV")
dbSetOrder(1)

aCabec := {"Plano","Descri��o","Respons�vel","Nome","Ocorr�ncias"}

#IFDEF TOP
	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT TBB_DESPLA, TBB_RESPON, QAA_NOME,TBB_CODPLA ,(SELECT COUNT(TBV_CODPLA) FROM %Table:TBV% TBV
	 		WHERE TBV.TBV_FILIAL = %xFilial:TBV%
	 			AND TBV.TBV_CODPLA = TBB.TBB_CODPLA GROUP BY TBV.TBV_CODPLA) nOco
		FROM %Table:TBB% TBB
		LEFT JOIN %Table:QAA% QAA ON QAA.QAA_FILIAL = %xFilial:QAA%
			AND QAA.%NotDel%
			AND QAA.QAA_MAT = TBB.TBB_RESPON
		WHERE TBB.TBB_FILIAL = %xFilial:TBB%
			AND TBB.%NotDel%
		ORDER BY TBB_CODPLA
	EndSql

#ELSE

	dbSelectArea("TBB")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		nOco := 0
		dbSelectArea("TBV")
		dbSetOrder(1)
		dbSeek(xFilial("TBV")+TBB->TBB_CODPLA)
		While !Eof() .And. TBV->TBV_FILIAL == xFilial("TBV") .And. TBV->TBV_CODPLA == TBB->TBB_CODPLA
			nOco ++
			dbSelectArea("TBV")
			dbSkip()
		End
		dbSelectArea("QAA")
		dbSetOrder(1)
		dbSeek(xFilial("QAA")+TBB->TBB_RESPON)
		aAdd(aValores, {TBB->TBB_CODPLA, TBB->TBB_DESPLA, TBB->TBB_RESPON, QAA->QAA_NOME, nOco})

		dbSelectArea("TBB")
		dbSkip()
	End
#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		(cAliasTrb)->(aAdd(aValores, {TBB_CODPLA, TBB_DESPLA, TBB_RESPON, QAA_NOME, nOco})) 
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TBV")
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