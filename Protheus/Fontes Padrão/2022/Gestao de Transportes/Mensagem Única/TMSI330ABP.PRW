#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI330ABP  � Autor � TIAGO DOS SANTOS   � Data � 23-09-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - FECHAMENTO SEGURO         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI330ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI330ABP(cXML,nType,cMsgType,cVersion)
     Local    aResult      := {}
     Local    cRotina      := "TMSA330"

     private  cEntityName  := "TRANSPORTDOCUMENT"
     default  cVersion     := "1.000"

     If type("oDTClass") == "U"
          private oDTClass := TransportDocumentClass():New()
     EndIf

     oDTClass:cVersion     := cVersion

     //- Trata o Envio/Recebimento do XML
     If     nType == TRANS_SEND
          aResult := oDTClass:Send() //**Envio

     ElseIf nType == TRANS_RECEIVE
          aResult := oDTClass:Receive(cXML,cMsgType)  //**Recebimento

     EndIf

     //- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
     //- Gatilha o campo XX4_MODEL
     AAdd(aResult,oDTClass:cEntityName)

Return aResult
