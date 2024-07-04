#INCLUDE "MDTP020.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTP020   � Autor � Ricardo Dal Ponte     � Data � 26/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 5:                     ���
���          �Acidentes por Parte Atingida                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MDTP020()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MDTP020()
Local aRetPanel  := {}
Local aCabec     := {STR0001,STR0002,STR0003} //"Parte Atingida"###"Descri��o"###"Quantidade"
Local aAlign     := {"LEFT","LEFT","RIGHT"}
Private aValores := {}
Private cAliasQry  := GetNextAlias()

Pergunte("MDTP020",.F.)

cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_CODPAR, TOI.TOI_DESPAR, COUNT(*) AS QTDE "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   LEFT JOIN "+RetSqlName("TOI")+" TOI ON TOI.TOI_FILIAL = '"+xFilial("TOI")+"' "
cQuery += "   AND TOI.TOI_CODPAR = TNC.TNC_CODPAR "
cQuery += "   AND TOI.D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND   TNC.TNC_CODPAR  <> ''"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TNC.TNC_FILIAL, TNC.TNC_CODPAR, TOI.TOI_DESPAR"
cQuery += "   ORDER BY QTDE DESC, TOI.TOI_DESPAR"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

While !Eof()
   Aadd(aValores,{TNC_CODPAR,TOI_DESPAR,QTDE})

   dbSelectArea(cAliasQry)
   dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

If Len(aValores) = 0
   Aadd(aValores,{"","",0})
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRetPanel := {/*cClick*/, aCabec, aValores, aAlign}

Return aRetPanel