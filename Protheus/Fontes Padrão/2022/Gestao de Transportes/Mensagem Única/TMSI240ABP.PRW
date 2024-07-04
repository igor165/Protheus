#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSI240ABP  ³ Autor ³ TIAGO DOS SANTOS   ³ Data ³ 23-09-2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ INTEGRACAO EAI GERA TITULO PAGAR - ADIANTAMENTO FRETE        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSI240ABP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSI240ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA240"
Local    cAsinc       := "1"
Local    cXmlRet      := ""

Default  cVersion     := "1.000"

If type("oDTClass") == "U"
    private oDTClass := TransportDocumentClass():New()
EndIf 

    
//| Define o tipo da mensagem.
//| 4-SEGURO;401-PREMIACAO
//oDTClass:SetTipoMsg("1","101") //| 1-VIAGEM;101-VIAGEM ADIANTAMENTO
oDTClass:cVersion := cVersion

//- Trata o Envio/Recebimento do XML
If   nType == TRANS_SEND
    aResult := oDTClass:Send() // TMI240SND()
    
ElseIf nType == TRANS_RECEIVE
    aResult := oDTClass:Receive(cXML,cMsgType) //TMI240REC(cXML,cMsgType)
    
EndIf

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,oDTClass:cEntityName)

Return aResult
