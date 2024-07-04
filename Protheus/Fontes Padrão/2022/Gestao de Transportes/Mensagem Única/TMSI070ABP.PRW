#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSI070ABP  ³ Autor ³ TIAGO DOS SANTOS   ³ Data ³ 23-09-2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ INTEGRACAO EAI GERA TITULO PAGAR - CONTROLE DE DIARIAS       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSI070ABP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSI070ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA070"
Local    aAdapter     := {}
default  cVersion     := "1.000"

      If type("oDTClass") == "U"
          private oDTClass := TransportDocumentClass():New()
      EndIf

      aAdapter := FwAdapterInfo(cRotina, oDTClass:cEntityName)

      If Len(aAdapter) > 0
        cVersion := aAdapter[/*ADAPTER_INFO_VERSION*/8]
      EndIf

      //| Define o tipo da mensagem.
      //| 4-SEGURO;401-PREMIACAO
      If Empty(oDTClass:cTIPOMSG)
         oDTClass:SetTipoMsg("5","501") //| 5-CUSTO DE TRANSP.;501-CUSTO TRANSP - NORM
      EndIf
      oDTClass:cVersion := cVersion
      
      //- Trata o Envio/Recebimento do XML
      If   nType == TRANS_SEND
           aResult := oDTClass:send()
           
      ElseIf nType == TRANS_RECEIVE
           aResult := oDTClass:receive(cXML,cMsgType)
           
      EndIf
      
      //- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
      //- Gatilha o campo XX4_MODEL
      AAdd(aResult,oDTClass:cEntityName)

      aSize(aAdapter, 0)
	  aAdapter := Nil

Return aResult