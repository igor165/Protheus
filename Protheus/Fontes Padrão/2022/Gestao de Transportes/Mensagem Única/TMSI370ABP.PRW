#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI070ABP  � Autor � TIAGO DOS SANTOS   � Data � 23-09-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - CUSTOS DE TRANSPORTE-     ���
���          � INDENIZACAO.                                                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI070ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI370ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA370"
Local    cXmlRet      := ""
Local    cAsinc       := "1"
Local    cTipoDocto   := "3"    //| OCORRENCIAS
Local    cSubTipDoc   := "301"  //| INDENIZACAO

Default  cVersion     := "1.000"

If type("oDTClass") == "U"
    private oDTClass := TransportDocumentClass():New()
EndIf 

oDTClass:cVersion := cVersion

//-- Trata o Envio/Recebimento do XML
If nType == TRANS_SEND
    aResult := oDTClass:Send()
    
ElseIf nType == TRANS_RECEIVE
    aResult := oDTClass:Receive(cXML,cMsgType)
    
EndIf

//- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,oDTClass:cEntityName)

Return aResult
