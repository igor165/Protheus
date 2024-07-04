#INCLUDE "MDTP070.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTP070   � Autor � Ricardo Dal Ponte     � Data � 29/03/7007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 1:                     ���
���          �Planos de Acoes da CIPA (Abertas/Fechadas)                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MDTP070()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MDTP070()
Local aRetPanel  := {}
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aValores := {}
Private cAliasQry  := ""

SG90PLACAO()//Adequa��o do Plano de A��o

Pergunte("MDTP070",.F.)

//APTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT " + cAliasPA + "." + aFieldPA[20]
cQuery += " FROM "+RetSqlName("TNN")+" TNN "
cQuery += "   JOIN "+RetSqlName("TNV")+" TNV ON TNV.TNV_FILIAL = '"+xFilial("TNV")+"' "
cQuery += "   AND TNV.TNV_MANDAT = TNN.TNN_MANDAT "
cQuery += "   AND TNV.D_E_L_E_T_ <> '*' "
cQuery += "   JOIN "+RetSqlName( cAliasPA )+ " " + cAliasPA + " ON " + cAliasPA + "." + aFieldPA[1] + " = '" + xFilial( cAliasPA ) + "' "
cQuery += "   AND " + cAliasPA + "." + aFieldPA[2] + " = TNV.TNV_CODPLA "
cQuery += "   AND " + cAliasPA + ".D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNN.TNN_FILIAL = '"+xFilial("TNN")+"' "
cQuery += "   AND  TNN.TNN_MANDAT  = '"+AllTrim(MV_PAR01)+"'"
cQuery += "   AND TNN.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nTTABER := 0
nTTFECH := 0

While (cAliasQry)->( !Eof() )
	If (cAliasQry)->( &(aFieldPA[20]) ) < 100
		nTTABER += 1
	Else
		nTTFECH += 1
	Endif

	dbSelectArea(cAliasQry)
	dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

Aadd(aRetPanel,{STR0002, Transform(nTTABER,"@E 999,999"),,{}} ) //"Aberto(s)"
Aadd(aRetPanel,{STR0003, Transform(nTTFECH,"@E 999,999"),,{}} ) //"Fechado(s)"
Return aRetPanel