#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAP030  � Autor � Rafael Diogo Richter  � Data �07/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Array para o Painel On-line do tipo 3:                ���
���          �- Percentual de Metas Alcancadas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAP030() 										   	  			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cText1,cValor,cLegenda,nColorValor,cClick,nPosIni,���
���          � nPosFim,nPos}                                              ���
���          � cText1      = Texto da Barra                         		  ���
���          � cValor      = Valor a ser exibido (string)                 ���
���          � cLegenda    = Nome da Legenda                              ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)       ���
���          � cClick      = Funcao executada no click do valor (opcional)���
���          � nPosIni     = Valor Inicial                      		     ���
���          � nPosFim     = Valor Final                                  ���
���          � nPos        = Valor da Barra                               ���
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
Function SGAP030()
Local cAliasTrb := ''
Local cMensagem := ""
Local nPerc := 0
Local nValMAlc := 0
Local nValTot := 0
Local lQuery := .F.

dbSelectArea("TAA")
dbSetOrder(1)

#IFDEF TOP
	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT COUNT(TAA_CODPLA) nValTot, (SELECT COUNT(TAA_CODPLA)
			FROM %Table:TAA% TAA
			WHERE TAA.TAA_FILIAL = %xFilial:TAA%
				AND TAA.%NotDel%
				AND TAA.TAA_META <= TAA.TAA_QTDATU
				AND TAA.TAA_PERCEN = 100) nValMAlc
		FROM %Table:TAA% TAA2
		WHERE TAA2.TAA_FILIAL = %xFilial:TAA%
			AND TAA2.%NotDel% GROUP BY TAA_FILIAL
	EndSql

#ELSE

	nValTot := 0
	nValMAlc := 0
	dbSelectArea("TAA")
	dbSetOrder(1)
	dbSeek(xFilial("TAA"))
	While !Eof() .And. TAA->TAA_FILIAL == xFilial("TAA")
		nValTot++
		If TAA->TAA_META <= TAA->TAA_QTDATU .And. TAA->TAA_PERCEN == 100
			nValMAlc++
		EndIf
		dbSelectArea("TAA")
		dbSkip()
	End

#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		nValTot := (cAliasTrb)->nValTot
		nValMAlc := (cAliasTrb)->nValMAlc
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TAA")
	dbSetOrder(1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Calcula percentual                                                      �
//��������������������������������������������������������������������������
nPerc  := Round( ((nValMAlc * 100) / nValTot),0)

//������������������������������������������������������������������������Ŀ
//�Monta mensagem                                                          �
//��������������������������������������������������������������������������
cMensagem := "% de Metas Alcan�adas" + chr(13)+chr(10)
cMensagem += chr(13)+chr(10)
cMensagem += "Representa o % do Total de Metas cadastradas" + chr(13)+chr(10)
cMensagem += "Resultado %: (Metas Alcan�adas * 100) / Total de Metas"

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRetPanel := { "Metas Alcan�adas", AllTrim(Str(nPerc))+"%","% do Total de Metas",CLR_BLUE,{ || MsgInfo(cMensagem) },0,100,nPerc }

Return aRetPanel