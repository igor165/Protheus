#INCLUDE "MDTP080.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTP080   � Autor � Ricardo Dal Ponte     � Data � 02/04/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 1:                     ���
���          �Dias Perdidos em Acidentes de Trabalho                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MDTP080()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MDTP080()
Local aRetPanel  := {}
Private aValores := {}
Private cAliasQry  := ""

Pergunte("MDTP080",.F.)

cAliasQry  := GetNextAlias()
cQuery := " SELECT TNC.TNC_QTAFAS, TNC.TNC_HRTRAB "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nTTDIAS  := 0
nTTHORAS := 0

While !Eof()
   nTTDIAS  += TNC_QTAFAS
   nTTHORAS += P080CONV(TNC_HRTRAB)

   dbSelectArea(cAliasQry)
   dbSkip()
End

nTTDIAS  += Round(nTTHORAS/8,1)

dbSelectArea(cAliasQry)
dbCloseArea()

Aadd(aRetPanel,{STR0003, Transform(nTTDIAS,"@E 999,999.9"),,{}} ) //"Dias Perdidos"
Return aRetPanel

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �P080CONV  | Autor �Ricardo Dal Ponte      � Data � 02/04/07 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Converte de horas para decimal(para utilizar em calculos)  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTP080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function P080CONV(cHora)//
	Local nHora, nMin, nPonto
	If (nPonto := AT(":",cHora)) > 0
		nHora := val(substr(cHora,1,nPonto-1))
		nMin  := val(substr(cHora,nPonto+1))
		Return nHora + ((nMin * (10/6))/100)
	Endif
Return 0