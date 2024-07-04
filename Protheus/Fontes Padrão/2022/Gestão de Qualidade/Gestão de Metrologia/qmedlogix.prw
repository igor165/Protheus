#include "protheus.ch" 
#include "qmedlogix.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMEDLOGIX �Autor  �Denis Martins       � Data �  07/14/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Unidade de Medida - Tabela DE - PARA						  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �QMEDLOGIX                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QMEDLOGIX()

dbSelectArea("QNA")
dbSetOrder(1)

If GetMv("MV_QALOGIX") == "1"
	AxCadastro("QNA",STR0001,"QMDELOGIX()","QTUNLOGIX()") //"Unidade Medida - Logix"        
Else 
	MsgStop(STR0002)  //"Esta rotina e utilizada somente quando da integracao com o Logix."
Endif	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMDELOGIX �Autor  �Microsiga           � Data �  07/14/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se pode realizar a delecao						  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QMEDLOGIX                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QMDELOGIX()
Local lRetl := .T.    
Local cQuery
Local aArea := GetArea()
Local cIndex	
Local cChave

cIndex := ""	
cChave := ""

cQuery := "SELECT B1_UM FROM "+RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQuery += " B1_UM = '"+QNA->QNA_UNIMED+"' AND "
cQuery += " D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SB1LGX")

If SB1LGX->(!EOF())
	lRetl := .F.
EndIf

SB1LGX->(DbCloseArea())


If !lRetl
	MessageDlg(STR0004) //"Unidade de medida ja utilizada em Produto(s). Nao podera ser excluida."
Endif

SB1->(DbSetOrder(1))
RestArea(aArea)
Return lRetl

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QTUNLOGIX �Autor  �Denis Martins		 � Data �  07/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Consiste as unidades de medidas - Protheus e Logix		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QTUNLOGIX                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QTUNLOGIX()
Local lRetn := .T.
If Type("M->QNA_TIPOPE") <> "U"
	If M->QNA_TIPOPE == "1" //Se unidade de medida...
        If Empty(M->QNA_UNIMED) .or. Empty(M->QNA_UNLGIX)
			MsgStop(STR0005)  //"Preencha os campos Unidade de Medida e Unidade de Medida - Logix"
			lRetn:=.f.
		EndIf
	EndIf
Endif	   
Return lRetn   