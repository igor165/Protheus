#INCLUDE "Average.ch"
#Include "TOPCONN.ch"
#Include "Totvs.ch"
//#Include "EICAP114.ch"

/*
Programa  : EICAP114.PRW
Objetivo  : Realizar a baixa de titulos FFC de Importação.
Autor     : MPG - Miguel Prado Gontijo
Data      : 24/01/2018
Parametros: 
Uso       : 
*/
Function EICAP114(cTabAlias,aCambioBx)
Local lRet      := .F.
Local cMsg      := "Integração EAI - Estorno do título financeiro. Aguarde..."
Private cAlias  := cTabAlias
Private aCambio := aCambioBx

If ! Empty( (cAlias)->WB_SEQLOTE )
    MsAguarde({|| lRet:= EasyEnvEAI("EICAP114", 3 )}, cMsg )
EndIf

RETURN lRet


/*
Função      : IntegDef()
Objetivo    : Efetua integração com Logix 
Autor       : MPG - Miguel Prado Gontijo
Data        : 24/01/2018
*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)

Local oEasyIntEAI

   oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("2.001")
	oEasyIntEAI:oMessage:SetMainAlias("SWB")
	oEasyIntEAI:SetModule("EIC",17)

	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP114SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP114RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*
Função      : AP114SEND()
Objetivo    : Envio das parcelas de Cambio
Autor       : MPG - Miguel Prado Gontijo
Data        : 24/01/2018
*/
Function AP114SEND(oMessage) 

Local oXml       := EXml():New()
Local oBusCont   := ENode():New()
Local oBusinReq  := ENode():New() 
Local oRec       := ENode():New()
Local aOrd       := SaveOrd({"SWB"})

SWB->(dbGoTo(aCambio[1]))

oBusinReq:SetField("Operation"  ,"EICAP114")

oBusCont:SetField("CompanyId"         ,EICEmpFLogix())
oBusCont:SetField("BranchId"          ,EICFilFLogix())
oBusCont:SetField("BatchPaymentNumber",(cAlias)->WB_SEQLOTE) 

oRec:SetField("BusinessRequest",oBusinReq)
oRec:SetField("BusinessContent",oBusCont)
oXml:AddRec(oRec)

RestOrd(aOrd,.T.)

Return oXml

/*
Função      : AP114RESP()
Objetivo    : Retorno das parcelas de Cambio
Autor       : MPG - Miguel Prado Gontijo
Data        : 24/01/2018
*/
Function AP114RESP(oMessage)

Local oRetCont  := oMessage:GetRetContent()
Local aOrd      := SaveOrd({"SWB"})
Local cSeqLote
Local cFil
Local aArray
Local nZ

If isCpoInXML(oRetCont, "_OriginInternalID")
    cSeqLote := EasyGetXMLinfo(,oRetCont,"_OriginInternalID")
    cFil     := FWFilial()
    aArray   := AP114SWB(cFil,cSeqLote)
    If Len(aArray) > 0
        For nZ := 1 To Len(aArray)
            SWB->(dbGoTo( aArray[nz] ))
            SWB->(RecLock("SWB",.F.))
            SWB->WB_SEQBX   := ""
            SWB->WB_SEQLOTE := ""
            SWB->(MSUNLOCK())
        Next
    EndIf
        
EndIf

RestOrd(aOrd,.T.)

Return oMessage

/*
Função      : AP114SWB()
Objetivo    : Retorno das parcelas de Cambio
Autor       : MPG - Miguel Prado Gontijo
Data        : 24/01/2018
*/
Static Function AP114SWB(cFil,cSeqLote)

Local cQuery    := ""
Local aRet      := {}
Local bBlock    := {|| aAdd( aRet, TRBSWB->RECNOSWB ) }
Local cDel, cRecno

If TcSrvType() == "AS/400"
    cRecno   := "@RECNO@"
    cDel     := "@DELETED@"
Else
    cRecno   := "R_E_C_N_O_"
    cDel     := "D_E_L_E_T_"
EndIf

cQuery += " SELECT SWB."+cRecno+" RECNOSWB FROM "+RetSQLName("SWB")+" SWB " + CRLF
cQuery += " WHERE SWB."+cDel+" <> '*' " + CRLF
cQuery += " AND SWB.WB_SEQLOTE = '"+cSeqLote+"' " + CRLF
cQuery += " AND SWB.WB_FILIAL = '"+cFil+"' "

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS "TRBSWB" NEW

If( TRBSWB->( ! EOF() ) , TRBSWB->( DbEval( bBlock ) ) , )

TRBSWB->( DbCloseArea() )

Return aRet