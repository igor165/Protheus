#INCLUDE "MDTP050.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTP050   � Autor � Ricardo Dal Ponte     � Data � 29/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 5:                     ���
���          �Ocorrencias de Doencas Ocupacionais                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MDTP050()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MDTP050()
Local aRetPanel  := {}
Local aCabec     := {STR0001,STR0002,STR0003} //"CID"###"Descri��o da Doen�a"###"Qtde. Ocorr�ncias"
Local aAlign     := {"LEFT","LEFT","RIGHT"}
Private aValores := {}
Private cAliasQry  := ""

Pergunte("MDTP050",.F.)

cAliasQry  := GetNextAlias()
cQuery := " SELECT TNA.TNA_FILIAL, TNA.TNA_CID, TMR.TMR_DOENCA, COUNT(*) AS QTDE "
cQuery += " FROM "+RetSqlName("TNA")+" TNA "
cQuery += "   LEFT JOIN "+RetSqlName("TMR")+" TMR ON TMR.TMR_FILIAL = '"+xFilial("TMR")+"' "
cQuery += "   AND TMR.TMR_CID = TNA.TNA_CID "
cQuery += "   AND TMR.D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNA.TNA_FILIAL   = '"+xFilial("TNA")+"' "
cQuery += "   AND  (TNA.TNA_DTINIC  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNA.TNA_DTFIM   <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND TNA.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TNA.TNA_FILIAL, TNA.TNA_CID, TMR.TMR_DOENCA"
cQuery += "   ORDER BY QTDE DESC, TMR.TMR_DOENCA"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

While !Eof()
   Aadd(aValores,{TNA_CID,TMR_DOENCA,QTDE})

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