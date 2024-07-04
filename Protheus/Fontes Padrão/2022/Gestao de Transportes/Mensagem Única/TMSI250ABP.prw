#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI250ABP  � Autor � TIAGO DOS SANTOS   � Data � 13-10-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - SOLICITA BAIXA TITULO     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI250ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI250(cXML,nType,cMsgType,cVersion)
Local  aResult  := {}
Local  cRotina  := "TMSA250"//XX4->XX4_ROTINA

default  cVersion := "1.000"

      If type("oDTClass") == "U"
          private oDTClass := TransportDocumentClass():New()
      EndIf 

      //| Define o tipo da mensagem.
      //| 2-CONTRATO CARRETEIRO; 401-CONTRATO CARRETEIRO - FRETE PAGAR - NORMAL
      //| oDTClass:setTipoMsg("2","201")
      oDTClass:cVersion := cVersion
      
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
