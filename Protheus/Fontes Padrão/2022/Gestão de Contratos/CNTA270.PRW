#INCLUDE "CNTA270.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CN270VldDt� Autor � Aline Sebrian         � Data �26/10/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida data prevista do cronograma cont�bil.               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN270VldDt()
Local lRet       := .T.
Local nTot       := 0
Local nAtual     := 0
Local dData  	 := &(Readvar())
Local lVldVige   := GetNewPar("MV_CNFVIGE","N") == "N"
Local dInicio	 := CtoD("")
Local dFim	 	 := CtoD("")
Local oModel		:= FWModelActive()
Local oModelCNW		:= Nil
Local lMVC			:= ValType(oModel) <> "U"

If lMVC
	oModelCNW 	:= oModel:GetModel("CNWDETAIL")

	nTot       	:= oModelCNW:Length()
	nAtual     	:= oModelCNW:nLine
	dInicio	 	:= FWFldGet("CN9_DTINIC")
	dFim		:= FWFldGet("CN9_DTFIM")
	If (nAtual < nTot)
		oModelCNW:GoLine( nAtual+1 )

		If oModelCNW:GetValue("CNW_DTPREV") <= dData //�Verifica se a previsao ultrapassa a proxima parcela se houver  �
			lRet := .F.
		EndIf

		oModelCNW:GoLine( nAtual )

	ElseIf lVldVige .AND. ( dData < dInicio .OR. dData > dFim )
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN270VldVal � Autor � Marcelo Custodio      � Data �26.12.2005���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida alteracao no valor de parcela                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �CN270VldVal()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA270                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CN270VldVal()
Local lRet := .T.
Return lRet
