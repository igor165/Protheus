#Include "Average.ch"
#Include "totvs.ch"
#include "FWADAPTEREAI.CH"
#include "XMLXFUN.CH"

Function EasyMessage(cXML, nTypeTrans, cTypeMessage)
Local oMessage

	oMessage := EasyMsgBusiness():New(cXML, nTypeTrans, cTypeMessage)

Return oMessage

CLASS EasyMessage FROM AvObject

	//Construtor da Classe
	METHOD New(xMessage) CONSTRUCTOR
	
	//Define o tipo da transação (SEND ou RECEIVE)
	// ABSTRATO METHOD SetTypeTrans
	METHOD GetTypeTrans()
	
	//Define a Transação (Nome da mensagem)
	//ABSTRATO METHOD SetTransaction()
	METHOD GetTransaction()
	
	//Define o tipo da mensagem (Mensagem ou Resposta)
	//ABSTRATO METHOD SetTypeMessage()
	METHOD GetTypeMessage()
	
	//Informa se a transação é de recebimento
	METHOD IsReceive()
	//Informa se a transação é de envio
	METHOD IsSend()
	
	METHOD IsMessage()
	METHOD IsResponse()
	METHOD IsWhois()

	//Define a versão da mensagem
	METHOD SetVersion(cVersion)
	METHOD GetVersion()
	METHOD SetWhois()
	
	//Define o Evento (INCLUIR/ALTERAR/EXCLUIR)
	//ABSTRATO METHOD SetOperation()
	METHOD GetOperation()
	
	//METHOD SetMenu(aMenu)
	//METHOD GetMEnu()
	
	//Define o alias da tabela principal
	METHOD SetMainAlias(cAlias)
	METHOD GetMainAlias()
	
	//Verifica se a chave única existe na tabela de acordo com o array de negócio
	METHOD HasUniqueKey()

	//Adiciona array com dados de negócio (ExecAuto)
	METHOD SetContentList(cAlias, aList)
	METHOD GetContentList(cAlias)
	
	METHOD GetXMLContentList(cAlias)
	
	//Adiciona registros no array de dados de negócio
	METHOD AddInList(cAlias, aData)
	
	//Executa o adapter da mensagem
	METHOD CallAdapter(cAdapter)
	
	//Define a função de negócio
	METHOD SetBFunction(bBFunction)
	METHOD GetBFunction() 
	
	//Executa função da regra de negócios
	METHOD ExecBFunction()
	
	METHOD GetEAutoArray()
	METHOD SetExec()
	METHOD GetExec() 
	Method GetExecParam()
	
	Data xMessage
	Data cTypeTrans
	Data cTypeMessage
	Data cVersion
	//Data aMenu
	Data cTransaction
	Data nOperation
	Data cMainAlias
	Data aContent
	Data bBFunction
	Data nExec
	
EndClass

METHOD GetExec() Class EasyMessage
Return Self:nExec

METHOD SetExec(nExec) Class EasyMessage
If ValType(nExec) == "N"
   Self:nExec := nExec
Else
   Self:nExec++
EndIf
Return Nil

METHOD GetEAutoArray(cAlias) Class EasyMessage
Local oTab, aRet := {}

//Self:SetExec() - NCF -27/12/201
oTab := Self:GetContentList("RECEIVE"):GetRec(Self:GetExec()):GetFieldCont(cAlias)

If ValType(oTab) == "O" .AND. GetClassName(oTab) $ "ETAB/EREC"
   If cAlias == Self:GetMainAlias()
       If GetClassName(oTab) == "ETAB" .AND. oTab:RecCount() == 1
   	      aRet := oTab:GetReg(1):GetEAutoArray()
   	   ElseIf GetClassName(oTab) == "EREC"
          aRet := oTab:GetEAutoArray()
       Else
          //ERRO
       EndIf
   Else
      aRet := oTab:GetEAutoArray()
   EndIf
Else
   //ERRO
EndIf

Return aClone(aRet)

METHOD New() Class EasyMessage
_Super:New()
	Self:xMessage		:= ""
	Self:cTypeTrans		:= ""
	Self:cTypeMessage	:= ""
	Self:cVersion		:= ""
	Self:cTransaction	:= ""
	Self:nOperation		:= 0
	Self:cMainAlias		:= ""
	Self:aContent		:= {}
	//Self:aMenu          := {}
	Self:nExec          := 0

Return Self

*--------------------------------------------*
METHOD SetVersion(cVersion) Class EasyMessage
*--------------------------------------------*

   If ValType(cVersion) == "C"
      Self:cVersion := cVersion
   Else
      //Error
   EndIf

Return 

METHOD GetTransaction() CLASS EasyMessage
Return Self:cTransaction

*-------------------------------------*
METHOD GetVersion() Class EasyMessage
*--------------------------------------*
Local cRet := ""
Local cAux := Self:cVersion

Do While At("|",cAux) > 0
   cRet += Transform(val(SubStr(cAux,0,At("|",cAux)-1)),"9.999")+"|"
   cAux := SubStr(cAux,At("|",cAux)+1,Len(cAux))
End Do
cRet += Transform(val(cAux),"9.999")

Return cRet

METHOD GetTypeTrans() Class EasyMessage
Return Self:cTypeTrans

*---------------------------------*
METHOD GetTypeMessage() CLASS EasyMessage
*---------------------------------* 
Return Self:cTypeMessage

*---------------------------------*
METHOD GetOperation() Class EasyMessage
*---------------------------------*
Return Self:nOperation

METHOD SetMainAlias(cAlias) Class EasyMessage

	Self:cMainAlias 	:= cAlias

Return Nil
*--------------------------------------*
METHOD GetMainAlias() Class EasyMessage 
*--------------------------------------*
Return Self:cMainAlias 

*--------------------------------------*
METHOD HasUniqueKey() Class EasyMessage  
*--------------------------------------*
Local lRet := .F.

	lRet := EasySeekAuto( Self:GetMainAlias(), Self:GetEAutoArray(Self:GetMainAlias()) , , ,Self)

Return lRet 

*------------------------------------------------*
METHOD GetContentList(cAlias) Class EasyMessage
*------------------------------------------------*
Local xRet
Local nPos

	If ValType(cAlias) == "C"
		nPos := aScan(Self:aContent, {|x| Upper(AllTrim(x[1])) == Upper(AllTrim(cAlias)) })
		If nPos > 0
		   xRet := Self:aContent[nPos][2]
		EndIf
	Else
		xRet := Self:aContent
	EndIf
	
Return xRet  

*------------------------------------------------*
METHOD GetXMLContentList(cAlias) Class EasyMessage
*------------------------------------------------*
Return Self:GetContentList(cAlias):GetXML()

*------------------------------------------------*
METHOD AddInList(cAlias, xData) Class EasyMessage
*------------------------------------------------*
Local nPos
    
   If (nPos := aScan(Self:aContent, {|x| Upper(AllTrim(x[1])) == Upper(AllTrim(cAlias)) })) == 0
      aAdd(Self:aContent, {cAlias, NIL} )
      nPos := Len(Self:aContent)
   EndIf
   Self:aContent[nPos][2] := xData
 	
Return Nil

*-----------------------------------*
METHOD IsReceive() Class EasyMessage 
*-----------------------------------*
Return Self:GetTypeTrans() == "RECEIVE"

*---------------------------*
METHOD IsSend() Class EasyMessage
*---------------------------*
Return Self:cTypeTrans == "SEND"

METHOD IsMessage() Class EasyMessage
Return Self:GetTypeMessage() == "MESSAGE"

METHOD IsResponse() Class EasyMessage
Return Self:GetTypeMessage() == "RESPONSE"     

METHOD IsWhois() Class EasyMessage
Return Self:GetTypeMessage() == "WHOIS"

*----------------------------------------*
METHOD CallAdapter(cAdapter,cTipoRet) Class EasyMessage
*----------------------------------------*
Local aRetAdap := {}

   bAdapter := &("{|oMessage| " + cAdapter + "(oMessage) }")	
   oRetAdap := Eval(bAdapter, Self)
   Self:AddInList(cTipoRet,oRetAdap)

Return

*--------------------------------------------------*
METHOD SetBFunction(bBFunction) CLASS EasyMessage
*--------------------------------------------------*

	If ValType(bBFunction) == "B"
		Self:bBFunction := bBFunction
	Else
		Self:Warning("Método SetBFunction: Função Inválida - " + cFunction)
	EndIf

Return

*---------------------------------*
METHOD GetBFunction() Class EasyMessage 
*---------------------------------*
Local bRet
Local bParFunc := Self:GetExecParam("BFUNCTION")

   If ValType(bParFunc) == "B"
      bRet := bParFunc
   Else
      bRet := Self:bBFunction
   EndIf
 
Return bRet

METHOD GetExecParam(cParam) Class EasyMessage
Local xRet, nPos
Local aParams := Self:GetEAutoArray("PARAMS")

If !Empty(aParams) .And. ( nPos := aScan(aParams, {|x| ValType(x[1]) == "C" .And. UPPER(x[1]) == cParam } ) ) > 0
   xRet := aParams[nPos][2]
EndIf

Return xRet

*---------------------------------------*
METHOD ExecBFunction() Class EasyMessage
*---------------------------------------*
Local oXmlErro 
Local cMsgRet
Local cFilialAtu  := cFilAnt
Local lDelRegInex := .F.
// *** Variáveis necessárias para chamada do ExecAuto
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.
// *** 
    cMsgRet := ""
    
    If !Empty(Self:GetExecParam("CFILANT"))
       cFilAnt := Self:GetExecParam("CFILANT")
    EndIf 
    
    cParamAlias := Self:GetExecParam("CMAINALIAS")
    If !Empty(cParamAlias)
        Self:SetMainAlias(cParamAlias)    
    EndIf
    
	Self:SetOperation()
	//NCF - 29/01/2013 - Nao retornar Msg de erro quando a operação for de exclusão de um registro inexistente no Easy
	If Self:GetOperation() == 5 
	   lDelRegInex := !Self:HasUniqueKey()
	EndIf
	If !Self:HasErrors() .And. !lDelRegInex
	   
	   //AAF 11/08/2014 - Capturar o primeiro error.log, evitando mensagem de retorno diferente do erro, caso o erro aconteça dentro de um begin/end sequence.
	   Private bOldErBlock := ErrorBlock()
	   Private oCatchErLog := NIL
	   
	   ErrorBlock({|oErr| if(type("oCatchErLog")=="U",oCatchErLog := oErr,),Eval(bOldErBlock,oErr)})
	   
	   Eval(Self:GetBFunction(), Self)	                                                         //Roda ExecAuto
	   
	   ErrorBlock(bOldErBlock)
	   
//	   If Valtype(oCatchErLog)=="O"
//	      Eval(bOldErBlock,oCatchErLog)
//       elseIf lMSErroAuto
		If lMSErroAuto
		  aEval(GetAutoGRLog(), {|x| cMsgRet += AvgXMLEncoding(x)+ENTER })		
          If (oXMLErro := Self:GetContentList("RESPONSE")) == NIL
             oXMLErro := EXml():New()
          EndIf
          oNode := ENode():New()
          //oNode:SetField(EAtt():New("type","error"))
          //oNode:SetField(EAtt():New("code",oXMLErro:RecCount()+1))
          oNode:SetField("",cMsgRet)
          
          //oErr := ETag():New("Message",oNode)
          //oErr := ETag():New("",oNode)
          oXMLErro:AddRec(oNode)
          VarInfo("oXMLErro",oXMLErro:GetXML())
          Self:AddInList("RESPONSE", oXMLErro)
		  Self:lError := .T.
	   EndIf
	EndIf
	
    cFilAnt := cFilialAtu

Return Nil                                    

METHOD SetWhois(oMessage) Class EasyMessage
Local oXml  

	//oXml := Etag():New("Version", Self:GetVersion())
	oXml := Etag():New("", Self:GetVersion()) //A tag Version não existe no XSD.
 
Return oXml 
