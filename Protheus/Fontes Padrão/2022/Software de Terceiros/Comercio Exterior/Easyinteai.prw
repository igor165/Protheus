#include 'totvs.ch'
#include "FWADAPTEREAI.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#include "XMLXFUN.CH"
#include "average.ch"

Static aEasyBuffer  := {}
Static lBufferiza   := .F.
Static aFuncParam   := {}
Static aDadosInteg  := {}  

CLASS EasyIntEAI FROM AvObject

	//Construtor da Classe
	METHOD New(cXML, nTypeTrans, cTypeMessage) CONSTRUCTOR
	
	//Define os adapters
	METHOD SetAdapter(cTypeMessage, cTypeTrans, cFunction)
	METHOD GetAdapter(cTypeTrans)
    
    //Define o módulo onde serão executadas as operações
    METHOD SetModule(cMod,nMod)
     
	METHOD GetResult()
	METHOD GetReturnMessage()
	
	//Executa a transação
	METHOD Execute()
              
	
	DATA bBFunction
	DATA aAdapterList
	DATA oMessage
	DATA aError
	DATA aSucess
	

ENDCLASS


//-----------------------------------------------------------------
METHOD New(cXML, nTypeTrans, cTypeMessage) CLASS EasyIntEAI
_Super:New()

    // BAK - Verifica se ja esta numa transacao
    /*If InTransaction()
       EndTran()
    EndIf*/             //NCF - 11/07/2014 - Nopado - Controle transferido para o Adapter

    VarInfo("cXML",cXML)
	Self:bBFunction		:= {|| Nil }
	Self:aAdapterList   := {}
	Self:oMessage		:= EasyMessage(cXML, nTypeTrans, cTypeMessage)
	Self:SetAdapter("RECEIVE", "WHOIS", "Self:SetWhois") //Self - EasyMessage

Return Self

*-----------------------------------------------*
METHOD SetAdapter(cTypeMessage, cTypeTrans, cFunction) CLASS EasyIntEAI
*-----------------------------------------------*
Local nPos

	If (nPos := aScan(Self:aAdapterList, {|x| x[1]+x[2] == cTypeMessage+cTypeTrans })) == 0
		aAdd( Self:aAdapterList, {cTypeMessage, cTypeTrans, Nil } )
		nPos := Len(Self:aAdapterList)
	EndIf
	
	Self:aAdapterList[nPos][3] := cFunction

Return

*---------------------------------------*
METHOD GetAdapter(cTypeTrans) Class EasyIntEAI
*---------------------------------------*
Local cRet := ""

	If (nPos := aScan(Self:aAdapterList, {|x| x[1] == cTypeTrans   .And.  x[2] == Self:oMessage:GetTypeMessage() })) > 0
		cRet := Self:aAdapterList[nPos][3]
	EndIf

Return cRet


*--------------------------------------------------*
METHOD SetModule(cMod,nMod) CLASS EasyIntEAI
*--------------------------------------------------*
Default cMod := cModulo
Default nMod := nModulo

If ValType(cMod) == "C" .And. ValType(nMod) == "N"
   If Self:oMessage:IsReceive() //AAF 26/01/2015 - Só definir um módulo em caso de recebimento. Se for envio, o sistema ja tem o módulo setado.
      cModulo := cMod
      nModulo := nMod
      SetX3Uso(.F.)
   EndIf
EndIf

Return

*----------------------------*
METHOD Execute(lExecOnError) Class EasyIntEAI 
*----------------------------*
Local i
Local oXmlErro  := EXml():New()
Local oLogErro  := ENode():New() 
Default lExecOnError := .F.

    //RECEBIMENTO
	If Self:oMessage:IsReceive()
		If Self:oMessage:IsMessage()
                
           If !Self:oMessage:HasErrors()
              //Executa do adapter de Recebimento de Business
			  Self:oMessage:CallAdapter(Self:GetAdapter("RECEIVE"),"RECEIVE")
			   	
			  For i := 1 To Self:oMessage:GetContentList("RECEIVE"):RecCount()
			     If !Self:oMessage:HasErrors()
				    Self:oMessage:SetExec()
			   	    Self:oMessage:ExecBFunction()
				 EndIf
			  Next i
			    
		      Self:oMessage:CallAdapter(Self:GetAdapter("RESPOND"),"RESPONSE")
		   Else
		      aEval(  Self:oMessage:aError , {|x| oLogErro:SetField('MESSAGE',AvgXMLEncoding(x)) })
              oXmlErro:AddRec(oLogErro)
              
              Self:oMessage:AddInList("RESPONSE", oXmlErro)
              Self:lError := .T.
		   EndIf
        
	    ElseIf Self:oMessage:IsResponse()
	       //Executa o adapter de recebimento de Response
	        If lExecOnError .OR. !Self:oMessage:HasErrors()
	           Self:oMessage:CallAdapter(Self:GetAdapter("RESPOND"),"RESPONSE")
	        EndIf
	    
	    ElseIf Self:oMessage:IsWhois()
	        //Executa o adapter de recebimento de Whois
	        If !Self:oMessage:HasErrors()    
	           Self:oMessage:CallAdapter(Self:GetAdapter("RECEIVE"),"WHOIS")
	        EndIf
	    EndIf
	     
    //ENVIO	    
    ElseIf Self:oMessage:IsSend()
       If Self:oMessage:IsMessage()       
          lEAIResponse := .F.
          //Executa o adapter de Envio da Business
          Self:oMessage:CallAdapter(Self:GetAdapter("SEND"),"SEND")       
       EndIf
	EndIf 

Return 

*-------------------------------*
METHOD GetResult() Class EasyIntEAI
*-------------------------------*
Local cSeq := ""
Local cCargo := ""
Local cOwner := ""
Local dData := ""
Local cHora := ""
Local cRotina := ""
Local cUserId := ""
Local cMensagem := ""
Local i := 0

VarInfo("GetResult",{!Self:oMessage:HasErrors(), Self:GetReturnMessage()})

If Type("lEAIResponse") == "L" .AND. Self:oMessage:IsResponse()
   lEAIResponse := .T.
EndIf

If Self:oMessage:IsResponse() .AND. Self:oMessage:HasErrors()
   If Type("oAvObjEAI") == "O"
      oAvObjEAI:Error(Self:oMessage:aError)
   EndIf
ElseIf Len(Self:oMessage:aWarning) > 0

   For i := 1 To Len(Self:oMessage:aWarning)
      cMensagem += Self:oMessage:aWarning[i] + Space(1)
   Next
   
   cChanel  := "002" //FW_EV_CHANEL_ENVIRONMENT
   cModules := "003" //FW_EV_CATEGORY_MODULES
   cLevel   := 1 //FW_EV_LEVEL_INFO
   cEvent   := "006"
   if IsCpoInXML(Self:oMessage:oXML:_TotvsMessage:_MessageInformation:_UUID,"Text")
      cCargo   := Self:oMessage:oXML:_TotvsMessage:_MessageInformation:_UUID:Text
   endif
   
   // MPG - 06/11/2018 - Retirar a leitura das tabelas de framework (XX4, XXD, SXH)
   EventInsert(cChanel,cModules,cEvent,cLevel,cCargo,'Falhou',cMensagem,.T.)
EndIf

Return {!Self:oMessage:HasErrors(), Self:GetReturnMessage()}

*-------------------------------------*
METHOD GetReturnMessage() Class EasyIntEAI 
*-------------------------------------*
Local cMessage := ""
   
   	If Self:oMessage:IsReceive()
		If Self:oMessage:IsMessage()
		   cMessage += Self:oMessage:GetXMLContentList("RESPONSE")
		ElseIf Self:oMessage:IsWhois()
		   cMessage += Self:oMessage:GetXMLContentList("WHOIS") 
	    //ElseIf Self:oMessage:IsResponse()
	    //   cMessage += Self:oMessage:GetXMLContentList("RESPOND")  
	    EndIf 
    ElseIf Self:oMessage:IsSend()
       If Self:oMessage:IsMessage()
          cMessage += Self:oMessage:GetXMLContentList("SEND")       
       EndIf
	EndIf 
	
Return EncodeUTF8(cMessage)

Function EasyEAIBuffer(cPar,bOnError,lContinue)
Local lRet := .T.
Local i
Local lRetIntedef := .F.
Local cFuncName := ""
Local nOpc := 0
Local oErrors := AvObject():New()
Private oAvObjEAI
Private nEAIRecNo:= 0
Private aEAIRecnos := {}
Default lContinue := .T.



If AllTrim(Upper(cPar)) == "INICIO"
   lBufferiza := .T.
   aEasyBuffer := {}
ElseIf AllTrim(Upper(cPar)) == "FIM"
   lBufferiza  := .F.
   //NCF - 30/10/2014 - Ordenar integrações financeiras
   If IsInCallStack("AF200Man") .and. aScan(aEasyBuffer,{|x| x[1] $ 'EECAF229|EECAF520'}) == 0
      aSort(aEasyBuffer,,, {|x, y| x[1] < y[1]  })   
   EndIf 
   
   aOldPos := GetTablePos()
   //For i := 1 To Len(aEasyBuffer)
   //   cFuncName := aEasyBuffer[i][1]
   //   nOpc := aEasyBuffer[i][2]
      
   //   SetTablePos(aEasyBuffer[i][3])
   Do While Len(aEasyBuffer) > 0
      cFuncName := aEasyBuffer[1][1]
      nOpc      := aEasyBuffer[1][2]
      SetTablePos( aEasyBuffer[1][3] )
         
      oAvObjEAI := AvObject():New()

      lRetIntedef := EasyEnvEAI(cFuncName,nOpc)

      If oAvObjEAI:HasErrors()
         oErrors:Error(oAvObjEAI:aError)
      EndIf
      
      If !lRetIntedef .AND. ValType(bOnError) == "B"
          Eval(bOnError,cFuncName,nOpc)
      EndIf
            
      lRet := lRet .AND. lRetIntedef
      
      //If lRet
         aDel( aEasyBuffer,1)
         aSize(aEasyBuffer, Len(aEasyBuffer)-1) 
      //EndIf
      
      If !lRet .AND. !lContinue
         EXIT
      EndIf
      
   EndDo
   //Next i
   
   If !lRet
      oErrors:ShowErrors()
   EndIf

   SetTablePos(aOldPos)
EndIf

Return lRet

Function EasyEnvEAI(cFuncName,nOpc,lForcaBuff)
Local cFuncOld := FunName()
Local lRet := .T.
Local aIntegdef := {}
Local lMostraErros := .F.
Local aOrd
Private nEAIEvent
Default lForcaBuff := .F.
lRecall := If( Type('lRecall') == 'U', .F. , lRecall )   //NCF - 15/05/2014

If Type("oAvObjEAI") <> "O"
   Private oAvObjEAI := AvObject():New()
   lMostraErros := .T.
EndIf

If lBufferiza
   aAdd(aEasyBuffer,{cFuncName,nOpc,GetTablePos()})
ElseIf lForcaBuff
   aSize( aEasyBuffer, Len(aEasyBuffer)+1 )         //coloca nulo na última posicao
   aIns(  aEasyBuffer, 2)                           //coloca nulo na posicao posterior à que está em execução e descarta ultima posição
   aEasyBuffer[2] := {cFuncName,nOpc,GetTablePos()} //adiciona o adapter na posicao atual  
Else
    nEAIEvent := nOpc
    //IniAuto(cFuncName)
    //EvalTrigger()
    //Iniauto(cFuncOld)
    If FindFunction("SetRotInteg")
       SetRotInteg(cFuncName)
    Else
       SetFunName(cFuncName)
    EndIf
    
    Private lEAIResponse := NIL //Detectar se ocorrer alguma falha que não execute o adapter de response
    aIntegdef := FWIntegDef(cFuncName,EAI_MESSAGE_BUSINESS,TRANS_SEND,"")
    
	if !aIntegdef[1] .and. !empty(aIntegdef[2])
        cMsg      := alltrim(aIntegdef[2])
        oAvObjEAI:Error(cMsg)
    endif
    
    If FindFunction("SetRotInteg")
       SetRotInteg(cFuncOld)
    Else
       SetFunName(cFuncOld)
    EndIf
    lRet := !oAvObjEAI:HasErrors()
    
    If lMostraErros .And. !lRet
       oAvObjEAI:ShowErrors()
    EndIf

EndIf

Return lRet

*---------------------------------------------------------*
FUNCTION EasyRecEAI(cFuncName,nOpc,cXmlRec) 
*---------------------------------------------------------*
Local aArea       := GetArea()
Local nTamFunName := Len( cFuncName ) 
Local aRetorno    := {}
Local cXML        := cXmlRec 
Private nEAIEvent := nOpc
Default cFuncName  := FunName()

if fwhaseai(cFuncName)
    aRetorno := &( "STATICCALL(" + cFuncName + ", IntegDef,'" + cXML + "', '" + TRANS_RECEIVE + "', '" + EAI_MESSAGE_BUSINESS + "')")
endif

RestArea( aArea )

Return aRetorno
/**************************************************************************
*                                                                         *
**************************************************************************/
Static Function GetTablePos()
Local aPos := {}, i := 1

For i := 1 To 511
   If !Empty(Alias(i))
      aAdd(aPos,{Alias(i),(Alias(i))->(RecNo())})
   EndIf
Next i

Return aPos
/**************************************************************************
*                                                                         *
**************************************************************************/
Static Function SetTablePos(aPos)
Local i

For i := 1 To Len(aPos)
   If ChkFile(aPos[i][1])
      (aPos[i][1])->(dbGoTo(aPos[i][2]))
   EndIf
Next i

Return Nil
/**************************************************************************
*                                                                         *
**************************************************************************/
//Função para uso em DEBUG de integração XML
User Function EASYTEAI()
Local cFile   := ""
Local aValida := {}
Local aRet

Do While (cFile := cGetFile("Arquivo XML |*.xml","XML Integração EAI",1,"C:\",.F.,/* nOptions */),!Empty(cFile) .AND. Empty(aValida := ValidaXML(cFile)))
EndDo

If !Empty(aValida)
   RpcSetType(3)
   RpcSetEnv(aValida[2],aValida[3])
   
   Private oAvObjEAI := AvObject():New()
   lMostraErros := .T.
   
   aRet := EasyRecEAI(aValida[4],aValida[5],aValida[1])
   
   If !aRet[1]
      oAvObjEAI:Error(aRet[2])
   Else
      Alert("Integração ocorrida com sucesso")
   EndIf
   
   oAvObjEAI:ShowErrors(.T.)
EndIf

Return Nil
/**************************************************************************
*                                                                         *
**************************************************************************/
Static Function ValidaXML(cFile)
Local aRet    := {}
Local cError  := ""
Local cWarning:= ""
Local cXML
Local aAux :={}

If !File(cFile) .OR. Empty(cXML := MemoRead(cFile))
   Alert(cError)
ElseIf (oXML := XmlParser(cXML, "_", @cError, @cWarning),!Empty(cError))
   Alert(cError)
ElseIf ValType(oXML) <> "O" .OR. !("XML" $ GetClassName(oXML))
   Alert("Erro na leitura do arquivo XML: "+ cWarning)
ElseIf Type("oXML:_TOTVSMESSAGE") <> "O" .OR. Type("oXML:_TOTVSMESSAGE:_MessageInformation") <> "O" .OR. Type("oXML:_TOTVSMESSAGE:_BusinessMessage") <> "O"
   Alert("Arquivo informado não está no formato TOTVSMESSAGE")
ElseIf Type("oXML:_TOTVSMESSAGE:_MessageInformation:_SourceApplication") <> "O" .OR.Type("oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId") <> "O" .OR. Type("oXML:_TOTVSMESSAGE:_MessageInformation:_BranchId") <> "O"
   Alert("Arquivo não possui sistema, empresa ou filial de origem em seu cabeçalho.")
ElseIf Type("oXML:_TOTVSMESSAGE:_MessageInformation:_Transaction") <> "O" .OR. Empty(oXML:_TOTVSMESSAGE:_MessageInformation:_Transaction:TEXT)
   Alert("Transação não definida no cabeçalho do arquivo XML")

    //MPG - 06/11/2018 - Armazenar dados em Array para evitar loops repetitivos na tabela XXD
elseif oXML:_TOTVSMESSAGE:_MessageInformation:_Product <> nil .or. empty(oXML:_TOTVSMESSAGE:_MessageInformation:_Product:text)
    Alert("Referência da relação de/para de filiais não definido, verifique o cadastro no configurador.")
elseif oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId <> nil .or. empty(oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId:text)
    Alert("Company Id não informado no XML verifique!")
elseif oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID <> nil .or. empty(oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID:text)
    Alert("Branch Id não informado no XML verifique!")
Else
    
   cApp := alltrim(oXML:_TOTVSMESSAGE:_MessageInformation:_Product:_name:text) //oXML:_TOTVSMESSAGE:_MessageInformation:_SourceApplication:TEXT
   cEmp := AllTrim(oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId:TEXT)
   cFil := AllTrim(oXML:_TOTVSMESSAGE:_MessageInformation:_BranchId:TEXT)
   aAux := FWEAIEMPFIL(cEmp,cFil,cApp)

    if len(aAux) > 0
      cEmp := aAux[1]
      cFil := aAux[2]
    endif
   
   cTransacao := Upper(oXML:_TOTVSMESSAGE:_MessageInformation:_Transaction:TEXT)
    if fwhaseai(cTransacao)
         nEvent := 3
         
         If Type("oXML:_TOTVSMESSAGE:_BusinessMessage:_BusinessEvent") == "O" .AND. Type("oXML:_TOTVSMESSAGE:_BusinessMessage:_BusinessEvent:_Event") == "O"
            If Upper(AllTrim(oXML:_TOTVSMESSAGE:_BusinessMessage:_BusinessEvent:_Event:TEXT)) == "DELETE"
               nEvent := 5
            EndIf
         EndIf
         
         aRet := {StrTran(StrTran(cXML,Chr(13),""),Chr(10),""),cEmp,cFil,cTransacao,nEvent} // GetRotInteg( ) XX4->XX4_ROTINA
    else
        Alert("Não existe adapter cadastrado para a transação "+AllTrim(cTransacao))
    endif
   
EndIf

Return aRet
/*
Funcao     : EasyEAIOrd()
Parametros : cAdapter - Nome da rotina Adapter de integração
             nOption  - Operação executada pelo Adapter
             cTable   - Tabela onde será verificado o campo critério
             cCpoOrd  - O campo do qual o dado contido servirá com critério de ordenação
             lOrdNamAdp - Ordena os adapters no array por nome após executada ordenações anteriores
Retorno    : Nenhum
Objetivos  : Ordernar o array dos adapters de integração para que ordem de execução dos 
             adapters que executam a mesma operação possam ser ordenados por algum critério
             específico conforme o dado contido em um campo.  
Autor      : Nilson Cesar - NCF
Data/Hora  : 01/09/2014 - 08:30
*/
Function EasyEAIOrd( cAdapter, nOption, cTable, cCpoOrd , lOrdNamAdp)

Local aOrigPos := {}
Local aOrdPos  := {}
Local aOrd     := {}
Local xDado    := ""
Local i
Default lOrdNamAdp := .F.

//NCF - 15/05/2015
If lOrdNamAdp
   aSort( aEasyBuffer , , , {|x,y|   x[1]  > y[1]    } )
EndIf

For i:=1 to Len(aEasyBuffer)

   If aEasyBuffer[i][1] == cAdapter .and. aEasyBuffer[i][2] == nOption      
	  If ( nPosTable := aScan(aEasyBuffer[i][3], {|x| x[1] == cTable }) ) > 0	
         SaveOrd(cTable)
         &(cTable)->(DbGoto(  aEasyBuffer[i][3][nPosTable][2]     ))
         If &(cTable)->(!Eof()) .And. &(cTable)->(!Bof())		 
		    If &(cTable)->(FieldPos(cCpoOrd)) > 0  .And. !Empty(  xDado := &(cTable+"->"+&(cTable)->(cCpoOrd))   )
		       aAdd( aOrigPos , {i,xDado,aEasyBuffer[i][3]} )   
		    EndIf
		 EndIf
      EndIf
      RestOrd(aOrd,.T.)
   EndIf

Next i

If Len(aOrigPos) > 0
   aOrdPos := aClone(aOrigPos)
   ASort( aOrdPos, , , {|x,y|x[2] > y[2]})
   
   For i:=1 to Len(aOrdPos)
      aEasyBuffer[aOrigPos[i][1]][3] := aclone(aOrdPos[i][3])
   Next i
EndIf

Return
/*
Funcao     : EnvEAISetParams()
Parametros : cFuncName - Nome da rotina para o qual o parâmetro será armazenado
             xParam    - Parâmetro a ser armazenado
Retorno    : lRet - Retorna .T. quando o parametro e funcao foi armazenado com sucesso, 
                   .F. caso contrário (quando um dos dos parametros passados é invalido ou nulo)
Objetivos  : Armazenar o parâmetro para a função selecionada  
Autor      : Nilson Cesar - NCF
Data/Hora  : 11/03/2016 - 10:00
*/
Function EnvEAISetParams(cFuncName,xParam)
Local lRet := .F.
Local nTamIni := Len(aFuncParam) 
Local nPos
  
If ValType(cFuncName) == 'C' .And. FindFunction(cFuncName) .And. ValType(xParam) <> 'U'
   
   /*If( nPos := aScan(aFuncParam,{|x| x[1] == cFuncName })  ) > 0
      aFuncParam[nPos][2] := xParam
      If !lRet
         lRet := .T.
      EndIf
   Else*/
      aAdd(aFuncParam, {cFuncName,xParam} )
   //EndIf
   
EndIf 

If /*!lRet .And.*/ Len(aFuncParam) > nTamIni
   lRet := .T.
EndIf

Return lRet
/*
Funcao     : EnvEAIGetParams()
Parametros : cFuncName - Nome da rotina para o qual o parâmetro está armazenado
Retorno    : xRet - parâmetro de tipo livre armazenado pela função na área de transferência da 
                    integração via EAI ou Nulo caso não seja encontrada a função no array aFuncParam.
Objetivos  : Retornar o parâmetro armazenado para a função selecionada  
Autor      : Nilson Cesar - NCF
Data/Hora  : 11/03/2016 - 10:00
*/
Function EnvEAIGetParams(cFuncName)

Local xRet:= NIL
Local nPos

If ( nPos := aScan(aFuncParam,{|x| x[1] == cFuncName }) ) > 0
   If ValType(aFuncParam[nPos][2]) == 'A'
      xRet := aClone(aFuncParam[nPos][2])
   Else
      xRet := aFuncParam[nPos][2]
   EndIf
   aDel(aFuncParam,nPos)
   ASize(aFuncParam,Len(aFuncParam)-1)
EndIf         

Return xRet
/*
Funcao     : EnvEAIResetParam()
Parametros : Nenhum
Retorno    : .T.
Objetivos  : Resetar array de parametros das funções  
Autor      : Nilson Cesar - NCF
Data/Hora  : 11/03/2016 - 10:00
*/
Function EnvEAIResetParam()
aFuncParam := {}
Return .T.
/*
Funcao     : GetDataInt()
Parametros : 
Retorno    : aDadosRet
Objetivos  : Retornar aDataInteg - Array com informações guardadas pelo Adapter
Autor      : Nilson Cesar - NCF
Data/Hora  : 30/05/2016 - 08:30
*/
Function GetDataInt()
Return aClone(aDadosInteg)
/*
Funcao     : SetDataInt()
Parametros : aInfo - { { cRotinaAdapter1, cRecnoRegistro1 } , { cRotinaAdapter2, cRecnoRegistro2 }, ... } 
Retorno    : .T. se conseguiu e .F. caso contrário
Objetivos  : Salvar array de informações do adapter
Autor      : Nilson Cesar - NCF
Data/Hora  : 30/05/2016 - 08:30
*/  
Function SetDataInt(aInfo)
Local lRet := .F.

If ValType(aInfo) == "A"
   aAdd(aDadosInteg,aInfo)
   lRet := .T.
EndIf

Return lRet
/*
Funcao     : DelDataInt()
Parametros : 
Retorno    : .T. se conseguiu e .F. caso contrário
Objetivos  : deletar posição no array de informações do adapter
Autor      : Nilson Cesar - NCF
Data/Hora  : 30/05/2016 - 08:30
*/
Function DelDataInt(nPos)
Local   lRet := .F.
Default nPos := 0

If nPos <> 0 .And. nPos <= Len(aDadosInteg)
   aDel(aDadosInteg, nPos)
   aSize(aDadosInteg, Len(aDadosInteg)-1 )
   lRet := .T.
EndIf

Return lRet