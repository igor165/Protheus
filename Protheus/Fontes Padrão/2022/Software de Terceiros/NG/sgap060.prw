#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAP060  � Autor � Rafael Diogo Richter  � Data �09/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Array para o Painel On-line do tipo 1:                ���
���          �- Dias sem ocorrencias do Plano Emergencial                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAP060() 										   	  			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {{cText1,cValor,nColorValor,bClick},...}           ���
���          � cTexto1     = Texto da Coluna                       		  ���
���          � cValor      = Valor a ser exibido (string)          		  ���
���          � nColorValor = Cor do valor no formato RGB (opcional)       ���
���          � bClick      = Funcao executada no click do valor (opcional)���
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
Function SGAP060()
Local cAliasTrb := ''
Local nDias := 0
Local aRetPanel := {}
Local lQuery := .F.
Local dDtOco := CTOD("  /  /    ")

dbSelectArea("TBV")
dbSetOrder(1)

#IFDEF TOP

	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT MAX(TBV_DATA) AS 'DTOCO'
		FROM %Table:TBV% TBV
		WHERE TBV.TBV_FILIAL = %xFilial:TBV%
			AND TBV.%NotDel%
	EndSql

#ELSE

	dbSelectArea("TBV")
	dbSetOrder(1)
	dbGoTop()
	While !Eof() .And. xFilial("TBV") == TBV->TBV_FILIAL
		dDtOco := If(TA0->TA0_DATA > dDtOco, TA0->TA0_DATA, dDtOco)

		dbSelectArea("TBV")
		dbSkip()
	End

#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		nDias := dDataBase - STOD((cAliasTrb)->DTOCO)
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TBV")
	dbSetOrder(1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Monta mensagem                                                          �
//��������������������������������������������������������������������������
cMensagem := "Dias sem Ocorr�ncias do P.E." + chr(13)+chr(10)
cMensagem += chr(13)+chr(10)
cMensagem += "Mostra a quantidade de dias em que a empresa" + chr(13)+chr(10)
cMensagem += "est� sem ocorr�ncias do Plano Emergencial" + chr(13)+chr(10)
cMensagem += chr(13)+chr(10)
cMensagem += "Resultado : Data Base / Data da �ltima ocorr�ncia"

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aAdd(aRetPanel, {"Quantidade de Dias:", Transform(nDias,"@E 999,999"), CLR_HRED, , {|| MsgInfo(cMensagem)}})

Return aRetPanel