#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAP050  � Autor � Rafael Diogo Richter  � Data �08/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Array para o Painel On-line do tipo 5:                ���
���          �- Qtde de documentos a serem lidos                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAP050() 										   	  			     ���
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
Function SGAP050()
Local cAliasTrb := ''
Local aCabec := {}
Local aValores := {}
Local aRetPanel := {}
Local lQuery := .F.
Local cUsu := PadR( Upper( SubStr( cUsuario, 7, 15 ) ), 15 )

dbSelectArea("TAQ")
dbSetOrder(1)

dbSelectArea("QDH")
dbSetOrder(1)

aCabec := {"Documento","Revis�o","T�tulo"}

#IFDEF TOP
	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT TAQ_ORDEM, QDH_RV, QDH_TITULO
		FROM %Table:TAQ% TAQ
		LEFT JOIN %Table:QDH% QDH ON QDH.QDH_FILIAL = %xFilial:QDH%
			AND QDH.%NotDel%
			AND QDH.QDH_DOCTO = TAQ.TAQ_ORDEM
		WHERE TAQ.TAQ_FILIAL = %xFilial:TAQ%
			AND TAQ.%NotDel%
			AND TAQ.TAQ_TIPO = '2'
			AND (TAQ.TAQ_USUARI = %Exp:cUsu% OR RTRIM(TAQ.TAQ_USUARI) = '*')
			AND TAQ.TAQ_USUFIM = ' '
		ORDER BY TAQ_ORDEM
	EndSql

#ELSE

	dbSelectArea("TAQ")
	dbSetOrder(1)
	dbSeek(xFilial("TAQ")+PadR( Upper( SubStr( cUsuario, 7, 15 ) ), 15 ))
	While !Eof() .And. TAQ->TAQ_FILIAL == xFilial("TAQ") .And. TAQ->TAQ_USUARI == cUsu .Or.;
		AllTrim(TAQ->TAQ_USUARI) == "*"
		
		If Empty(TAQ->TAQ_USUFIM)	.And. TAQ->TAQ_TIPO == "2"
			dbSelectArea("QDH")
			dbSetOrder(1)
			dbSeek(xFilial("QDH")+TAQ->TAQ_ORDEM)
	
			aAdd(aValores, {QDH->QDH_DOCTO, QDH->QDH_RV, QDH->QDH_TITULO})
		EndIf

		dbSelectArea("TAQ")
		dbSkip()
	End
#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		(cAliasTrb)->(aAdd(aValores, {TAQ_ORDEM, QDH_RV, QDH_TITULO}))
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("QDH")
	dbSetOrder(1)
EndIf

If Empty(aValores)
	aAdd(aValores, {' ', ' ', ' ', ' ', 0})
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRetPanel := { { || SGAP050Le() }, aCabec, aValores }

Return aRetPanel

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �SGAP050Le � Autor � Rafael Diogo Richter  � Data � 08/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visuliza o documento pendente e finaliza.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �SGAP050Le()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGASGA                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function SGAP050Le()

Return .T.