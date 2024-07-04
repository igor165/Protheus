#Include "MSOBJECT.CH"
#Include "AVERAGE.CH" 
#Include "APWizard.CH"
#Include "EEC.CH"
#Include "Protheus.CH"
#Include "FILEIO.CH"
#Include "FWBROWSE.CH"
#Include "EASYWORKFLOW.CH"

#DEFINE EMAIL_ENVIADO		"10001"
#DEFINE EMAIL_RESPONDIDO	"10002"
#DEFINE EMAIL_TIMEOUT		"10003"

#Define FORMULARIO		"1"
#Define EMAIL_ANEXO		"2"
#Define EMAIL_LINK		"3"

#Define WEB_PROTHEUS    "1"
#Define WEB_OTHER       "2"

/*
Função..: EasyWorkFlow
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 10/01/2011
Objetivo: Componente de WorkFlow
Parâmetros: -
*/
Function EasyWorkFlow(); Return Nil

Class EasyWorkFlow

   Data cPROCESSO
   Data cTipo
   Data cNOME
   Data cHTMLWF
   Data cHTMLI
   Data cHTMAN
   Data cHTMLLocal
   Data cDESTINATARIOS
   Data cCOPIA
   Data cCOPIAOCULTA
   Data cASSUNTO
   Data nTIMEOUTDIAS
   Data nTIMEOUTHRS
   Data nTIMEOUTMINS
   Data cFUNC_ENVIO
   Data cFUNC_VARS
   Data cFUNC_RET
   Data cDirHTMLA
   Data cDirHTML
   Data cServer
   Data cID
   Data aVals
   Data cChave
   Data cTipoRet
   Data cTipoSrv
   
   Method New(cProcesso) Constructor
   Method SetProcesso(cProcesso)
   Method RetProcesso()
   Method RetName()
   Method RetHTML()
   Method LoadProcesso()
   Method Send()
   Method Receive(oWF)
   Method TimeOutDia()
   Method TimeOutHora()
   Method TimeOutMin()
   Method SetID(cID)
   Method RetID()
   Method AddVal(cValName, xValue)
   Method RegistraWF()
   Method SetChave()
   Method RetChave()
   Method LoadChave()
   Method LoadVars()
   Method Anexa()
   Method RetEmp()
   Method RetFil()
   Method RetFuncLink()
   Method RetSRV()
   Method RetDirHtm()
   Method RetVal(cValName)
   Method RetDesc() 
   Method RetTypeSrv()
   Method RetTipoEnv()
   Method RetDestinat()
   Method CriaHTML(cNome)

EndClass

Method New(cProcesso, cChave) Class EasyWorkFlow
Default cProcesso := ""

   Self:cPROCESSO		:= ""
   Self:cTipo			:= ""
   Self:cTipoRet        := ""
   Self:cNOME			:= ""
   Self:cHTMLWF			:= ""
   Self:cHTMLI          := ""
   Self:cHTMAN          := ""
   Self:cHTMLLocal		:= ""
   Self:cDESTINATARIOS	:= ""
   Self:cCOPIA			:= ""
   Self:cCOPIAOCULTA	:= ""
   Self:cASSUNTO		:= ""
   Self:nTIMEOUTDIAS    := 0
   Self:nTIMEOUTHRS     := 0
   Self:nTIMEOUTMINS    := 0
   Self:cFUNC_ENVIO		:= ""
   Self:cFUNC_VARS		:= ""
   Self:cFUNC_RET       := ""
   Self:cDirHTMLA		:= EasyGParam("MV_HTMLWFA",,"\SYSTEM\EASYWORKFLOW\")  //Diretório onde será salvo o arquivo HTML para ser anexado ao email.
   Self:cDirHTML        := EasyGParam("MV_HTMLWF" ,,"C:\Easyworkflow\") //Pasta onde será salvo o arquivo HTML para ser lido quando  servidor Web qualquer.
   Self:cServer         := EasyGParam("MV_EASYSRV",,"http://localhost:8080") //Endereco do servidor
   Self:cID				:= ""
   Self:aVals			:= {}
   Self:cTipoSrv        := ""
   
   If !Empty(cProcesso)
      Self:SetProcesso(cProcesso)
   EndIf
   If !Empty(cChave)
      Self:SetChave(cChave)
   EndIf

Return Self
/*************************************************

*************************************************/
Method LoadChave(cID) Class EasyWorkFlow

   If cID == Nil
      cID:= Substr(WFA->WFA_IDENT,1,5)
   Endif
   
   Self:SetID(cID)
   
   EJ8->(DbSetOrder(1))
   
   If EJ8->(DbSeek(xFilial("EJ8")+Self:RetID()))
      Self:SetChave(EJ8->EJ8_CHAVE)
      If Empty(Self:cProcesso)
         Self:SetProcesso(EJ8->EJ8_PROCES)
      EndIf
   EndIf
   
Return Nil
/*************************************************

*************************************************/
Method SetChave(cChave) Class EasyWorkFlow
   
   Self:cChave := cChave

Return Nil
/*************************************************

*************************************************/
Method RetChave() Class EasyWorkFlow

Return Self:cChave
/*************************************************

*************************************************/
Method SetProcesso(cProcesso) Class EasyWorkFlow

   If !Empty(cProcesso)
      Self:cProcesso := cProcesso
      Self:LoadProcesso()
   EndIf

Return Nil
/*************************************************

*************************************************/
Method RetProcesso() Class EasyWorkFlow
Return Self:cProcesso
/*************************************************

*************************************************/
Method RetName() Class EasyWorkFlow
Return Self:cNOME
/*************************************************

*************************************************/
Method RetHTML(cTipo) Class EasyWorkFlow
Local cHTML := ""
Default cTipo := Self:cTipo
   
   // GFP - 10/05/2011 :: 17h59
   TRY
      Do Case
         Case cTipo == FORMULARIO
            cHTML := &(Self:cHTMLWF+"()")
         Case cTipo == EMAIL_ANEXO
            cHTML := &(Self:cHTMAN+"()")
         Case cTipo == EMAIL_LINK                
            cHTML := &(Self:cHTMLI+"()")
      End Case
   CATCH oError
      MsgAlert(STR0002, STR0001)  // "Não foi possível carregar o HTML!" ## "Atenção"
   ENDTRY

Return cHTML
/*************************************************

*************************************************/
Method LoadProcesso() Class EasyWorkFlow

  If !Empty(Self:RetProcesso()) .And. EJ7->(DbSeek(xFilial("EJ7")+Self:RetProcesso()))
      Self:cNOME			:= EJ7->EJ7_DESC
      Self:cTipo			:= EJ7->EJ7_TIPO
      Self:cTipoRet         := EJ7->EJ7_TIPORE
      Self:cHTMLWF			:= &(EJ7->EJ7_HTML)  // GFP - 02/09/2013
      If Empty(EJ7->EJ7_HTMLI)
         Self:cHTMLI        := "H_EASYWFLINK"
      Else
         Self:cHTMLI        := EJ7->EJ7_HTMLI
      Endif
      If Empty(EJ7->EJ7_HTMAN)
         Self:cHTMAN        := "H_EASYWFANEXO"
      Else
         Self:cHTMAN        := EJ7->EJ7_HTMAN
      Endif
      Self:cDESTINATARIOS	:= EJ7->EJ7_VMDEST
      Self:cCOPIA			:= EJ7->EJ7_COPIA
      Self:cCOPIAOCULTA	    := EJ7->EJ7_COPOC
      Self:cASSUNTO		    := EJ7->EJ7_ASSUNT
      Self:nTIMEOUTDIAS	    := EJ7->EJ7_TIMEOU
      Self:nTIMEOUTHRS	    := EJ7->EJ7_TIMEHR
      Self:nTIMEOUTMINS	    := EJ7->EJ7_TIMEMI
      Self:cFUNC_ENVIO		:= EJ7->EJ7_FUNCEN
      Self:cFUNC_RET        := EJ7->EJ7_FUNCRE
      Self:cFUNC_VARS       := EJ7->EJ7_FUNCVA
      Self:cTipoSrv         := EJ7->EJ7_TIPSRV
      If !Empty(EJ7->EJ7_SERVID)
         Self:cServer       := EJ7->EJ7_SERVID
      Endif
  EndIf

Return Nil
/*************************************************

*************************************************/
Method TimeOutDia() Class EasyWorkFlow
Return Self:nTIMEOUTDIAS
/*************************************************

*************************************************/
Method TimeOutHora() Class EasyWorkFlow
Return Self:nTIMEOUTHRS
/*************************************************

*************************************************/
Method TimeOutMin() Class EasyWorkFlow
Return Self:nTIMEOUTMINS
/*************************************************

*************************************************/
Method SetID(cID) Class EasyWorkFlow
   If ValType(cID) == "C"
      Self:cID := cID
   EndIf
Return Nil
/*************************************************

*************************************************/
Method RetID() Class EasyWorkFlow
Return Self:cID
/*************************************************

*************************************************/
Method RetEmp() Class EasyWorkFlow
Return SM0->M0_CODIGO
/*************************************************

*************************************************/
Method RetFil() Class EasyWorkFlow
Return SM0->M0_CODFIL
/*************************************************

*************************************************/
Method RetFuncLink() Class EasyWorkFlow
Local cFuncLink:=""

cFuncLink:= Self:cHTMLWF

Return cFuncLink
/*************************************************

*************************************************/
Method RetDesc() Class EasyWorkFlow
Local cDesc:=""

cDesc:= Self:cNOME

Return cDesc
/*************************************************

*************************************************/
Method RetSRV() Class EasyWorkFlow
Local cSrv:= ""

cSrv:= Self:cServer 

Return cSrv
/*************************************************

*************************************************/
Method RetDirHtm() Class EasyWorkFlow
Local cDir:= ""

cDir:= STRTRAN(Self:cDirHTML,"\","")

Return cDir
/*************************************************

*************************************************/
Method RetTypeSrv() Class EasyWorkFlow
Local cTypeSrv:= ""

cTypeSrv:= Self:cTipoSrv

Return cTypeSrv
/*************************************************

*************************************************/
Method CriaHTML(cNome) Class EasyWorkFlow
Local nHandler := 0

If !File("\system\"+cNome)
   nHandler := EasyCreateFile("\system\"+cNome)
   FClose(nHandler)
EndIf

Return "\system\"+cNome
/*************************************************

*************************************************/
Method Send() Class EasyWorkFlow

Local cFuncTimeOut:= ""
Private oWorkFlow := Self, oBKWorkFlow := Self //MCF - 28/04/2016
Private cArq := "", cArqHtml:= "workflow.htm"
Private oHtml, oProcess
Private cVrs := "1"

If Empty(Self:RetProcesso())
   Return Nil
EndIf

//Instancia o objeto do WorkFlow
oProcess := TWFProcess():New(Self:RetProcesso(), Self:RetName())
Self:SetID(oProcess:fProcessID)
cArq := Self:CriaHTML(cArqHtml)

oProcess:NewTask(Self:cNOME,cArq)

//Define o nome do arquivo HTML local (para os casos onde a página será salva)
Self:cHtmlLocal := CriaTrab(,.f.)+".HTM"

//Chama classe de HTML para tratamento das variáveis
oHtml := TWFHtml():New()

//Carrega as variáveis
Self:LoadVars()

cHTML := Self:RetHtml(FORMULARIO)
If Empty(cHTML)  // GFP - 05/08/2015
   Return NIL
EndIf
oHtml:LoadStream(cHTML)
oProcess:oHTML := oHtml

// Definindo o Assunto do E-mail (propriedade cSubject):
oProcess:cSubject := Self:cASSUNTO

// Definindo o(s) Destinatário(s) do E-mail (propriedade cTo):
oProcess:cTo := Self:cDESTINATARIOS

// Definindo o(s) Destinatário(s) com cópia do E-mail (propriedade cCC):
oProcess:cCC := Self:cCOPIA

//Definindo o(s) Destinatário(s) com cópia oculta do E-mail (propriedade cBCC):
oProcess:cBCC := Self:cCOPIAOCULTA

// Definindo o corpo da mensagem, caso não queira utilizar HTML atachado ao e-mail (propriedade cBody):
// Ex: oProcess:cBody := "Testando..."

// Definindo a Função ADVPL de Retorno (propriedade bReturn):
oProcess:bReturn := "EasyWFRet()"

Self:RegistraWF()

// Definindo a Função e o tempo de TimeOut.
cFuncTimeOut:= "EasyWFTimeOut()"
oProcess:bTimeOut := {{cFuncTimeOut, Self:TimeOutDia(), Self:TimeOutHora(), Self:TimeOutMin()}}

If cVrs == "1"

    If Self:cTipo == EMAIL_ANEXO
        cHTML := Self:RetHTML(FORMULARIO)
        Self:Anexa(Self:cDirHTMLA, cHTML)
        oProcess:AttachFile(Self:cDirHTMLA+Self:cHTMLLocal)
    EndIf

    //Salvar o HTML no diretório informado no parâmetro MV_HTMLWF para ser utilizado quando servidor Web qualquer. 
    IF Self:cTipoSrv == WEB_OTHER
        cHTML := Self:RetHTML(FORMULARIO)
        Self:Anexa(Self:cDirHTML, cHTML)
    ENDIF 

ElseIf cVrs == "2"

    //Carrega as variáveis
    Self:LoadVars()

    If Self:cTipo == EMAIL_ANEXO
        cHTML := oProcess:oHtml:cBuffer
        Self:Anexa(Self:cDirHTMLA, cHTML)
        oProcess:AttachFile(Self:cDirHTMLA+Self:cHTMLLocal)
    EndIf

    //Salvar o HTML no diretório informado no parâmetro MV_HTMLWF para ser utilizado quando servidor Web qualquer. 
    IF Self:cTipoSrv == WEB_OTHER
        cHTML := oProcess:oHtml:cBuffer
        Self:Anexa(Self:cDirHTML, cHTML)
    ENDIF

EndIf

//Envia o Email
oProcess:Start()

EJ8->(DbSetOrder(2))
If EJ8->(DbSEEK(xFilial("EJ8")+Self:RetChave()))
   EJ8->(RecLock("EJ8", .F.))
   EJ8->EJ8_IDENT := WFA->WFA_IDENT
   EJ8->(MsUnlock())
Endif

//Registra o envio
bExecEnv := &("{|oEasyWorkFlow| " + AllTrim(Self:cFUNC_ENVIO) + "(oEasyWorkFlow)}")
Eval(bExecEnv, Self)

//Grava a rastrabilidade de status EMAIL ENVIADO
RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,oProcess:fProcCode, EMAIL_ENVIADO)  //EMAIL ENVIADO

Return Nil
/*************************************************

*************************************************/
Method RegistraWF() Class EasyWorkFlow

   EJ8->(DbSetOrder(2))
   If EJ8->(DbSEEK(xFilial("EJ8")+Self:RetChave()))
      EJ8->(RecLock("EJ8", .F.))
      EJ8->EJ8_ID := Self:RetId()
      EJ8->(MsUnlock())
   Else
      EJ8->(RecLock("EJ8", .T.))
      EJ8->EJ8_FILIAL:= xFilial("EJ8")
      EJ8->EJ8_ID := Self:RetId()
      EJ8->EJ8_CHAVE := Self:RetChave()
      EJ8->EJ8_PROCES := Self:RetProcesso()
      EJ8->(MsUnlock())
   Endif

Return Nil
/*************************************************

*************************************************/
Method Anexa(cDirStart, cHTML) Class EasyWorkFlow
Local cFile

   cFile:= EasyCreateFile(cDirStart + Self:cHTMLLocal)
   Fwrite(cFile, cHTML)
   FClose(cFile)

Return Nil
/*************************************************

*************************************************/
Method Receive(oWF) Class EasyWorkFlow

   bExecRet := &("{|oWF| " + AllTrim(Self:cFUNC_RET) + "(oWF)}")
   Eval(bExecRet, oWF)
   
   //Coloco mais um ponto de rastreabilidade, usando o Status 10002. "Email Respondido"
   RastreiaWF(oWF:fProcessID+"."+oWF:fTaskID,oWF:fProcCode, EMAIL_RESPONDIDO)

Return Nil
/*************************************************

*************************************************/
Method AddVal(cValName, xValue) Class EasyWorkFlow

   aAdd(Self:aVals, {cValName, ToString(xValue)})

Return Nil
/*************************************************

*************************************************/
Method RetVal(cValName) Class EasyWorkFlow
Local cRet := ""

   If (nPos := aScan(Self:aVals, {|x| x[1] == cValName })) > 0
      cRet := Self:aVals[nPos][2]
   EndIf

Return cRet
/*************************************************

*************************************************/
Method LoadVars() Class EasyWorkFlow

   //*** Substitui os campos do HTML de acordo com a regra de negócio
   bExecEnv := &("{|oEasyWorkFlow| " + AllTrim(Self:cFUNC_VARS) + "(oEasyWorkFlow)}")
   Eval(bExecEnv, Self)
   //***

Return Nil
/*************************************************

*************************************************/
Method RetDestinat() Class EasyWorkFlow
Local cDESTINATARIOS := ""

cDESTINATARIOS := Self:cDESTINATARIOS

Return cDESTINATARIOS
/*************************************************

*************************************************/
Method RetTipoEnv() Class EasyWorkFlow
Local cTipo := ""

cTipo:= Self:cTipo

Return cTipo
/*************************************************

*************************************************/
*-------------------------------*
Static Function ToString(xValue)
*-------------------------------*
Local cValue := ""

   Do Case
      Case ValType(xValue) == "C"
         cValue := AllTrim(xValue)
         
      Case ValType(xValue) == "N"
         cValue := AllTrim(Str(xValue))
      
      Case ValType(xValue) == "D"
         cValue := DToC(xValue)

      Case ValType(xValue) == "L"
         If xValue
            cValue := "sim"
         Else
            cValue := "não"
         EndIf

   End Case

Return cValue
/*************************************************

*************************************************/
*----------------------------*
Function EasyWFRet(oProcess)
*----------------------------*
cProc:= oProcess:FPROCCODE

Private oObj := EasyWorkFlow():New(cProc)
oObj:Receive(oProcess)

Return Nil
/*************************************************

*************************************************/
*-------------------------------*
Function EasyWFTimeOut(oProcess)
*-------------------------------*

RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,oProcess:fProcCode, EMAIL_TIMEOUT)

Return Nil
/*************************************************

*************************************************/
*--------------------*
Function EasyIniWF()
*--------------------*
If Type("oWorkFlow") <> "O" .AND. Type("oBKWorkFlow") == "O"
   oRet := oBKWorkFlow
ElseIf Type("oWorkFlow") <> "O"
   RpcSetType(3)
   RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)  // GFP - 04/08/2015
      
   oRet := EasyWorkFlow():New()
   oRet:LoadChave(HTTPGET->ID)   
   oRet:LoadVars()
Else
   oRet := oWorkFlow
EndIf

Return oRet
/*************************************************

*************************************************/
*------------------------------------------------------------------------------------*
User Function EasyRetorno(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)
*------------------------------------------------------------------------------------*
Local cMailId := "" 
RpcSetType(3)
RpcSetEnv(__aProcParms[2][2],__aProcParms[3][2],,,'EIC')
DBSELECTAREA("EJ8")
EJ8->(DbSetOrder(1))
If EJ8->(DBseek(xFilial("EJ8")+Alltrim(__aProcParms[1][2])))
   cMailId := "WF"+Alltrim(EJ8->EJ8_IDENT)
Endif
WFRETURN({SM0->M0_CODIGO,SM0->M0_CODFIL,{{"WFMailID",cMailId},{"WFEMPRESA",SM0->M0_CODIGO},{"WFFILIAL",SM0->M0_CODFIL}}},,.T.)
Return STR0004  // "Dados enviados ao Protheus." 


/*
Função..: EasyGroupWF
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 10/01/2011
Objetivo: Funcão para envio de WorkFlows por fases
Revisão.: Guilherme Fernandes Pilan - GFP
Data....: 26/09/2012
Objetivo: Ajuste para que função seja schedulada.
*/
//
*-----------------------------------*
Function EasyGroupWF(cFase,aChaves,lEnvia,cEmp,cFil,lSchedule)
*-----------------------------------* 
Local lEasyWorkFlow 
Local i, uChaves
Default aChaves := {}
Default lEnvia  := !Empty(aChaves)
Default lSchedule := .F.                                   

If lSchedule //cEmp <> Nil .AND. cFil <> Nil
   RpcSetType(3)
   RpcSetEnv(cEmp,cFil)
EndIf

lEasyWorkFlow:= EasyGParam("MV_EASYWF",,.F.)

// GFP - 10/05/2011 :: 17h59
   If lEasyWorkFlow
      
      If Empty(aChaves)
         DbSelectArea("EJ7")
         EJ7->(DbSetOrder(2))
         If EJ7->(DbSeek(xFilial("EJ7")+ Alltrim(cFase)))
            Do While EJ7->(!EOF()) .AND. EJ7->EJ7_FILIAL == xFilial("EJ7") .AND. Alltrim(EJ7->EJ7_FASE) == Alltrim(cFase)
               If EJ7->EJ7_ATIVO == "1"
                  TRY
                  uChaves:= &(EJ7->EJ7_CHAVES)
                    If !Empty(uChaves)
                        If ValType(uChaves) == "A"
                           For i := 1 To Len(uChaves)
                              If ValType(uChaves[i]) == "C"
                                 aAdd(aChaves,{EJ7->EJ7_COD,uChaves[i]})
                              EndIf
                           Next i
   	                    ElseIf ValType(uChaves) == "C"
                           aAdd(aChaves,{EJ7->EJ7_COD,uChaves})
                        Else
                           BREAK
                        EndIf
                    EndIf
                  CATCH
                     MsgAlert(STR0003+ AllTrim(EJ7->EJ7_DESC), STR0001)  //"Não foi possível enviar o Workflow de " ## "Atenção"
                  ENDTRY
               Endif
               EJ7->(DbSkip())
            Enddo 
         EndIf
      EndIf

      If lEnvia
         EJ7->(dbSetOrder(1))
         If !lSchedule
            For i:=1 to Len(aChaves)
               If EJ7->(dbSeek(xFilial("EJ7")+AvKey(aChaves[i][1],"EJ7_COD")))
                  oWorkFlow := EasyWorkFlow():New(aChaves[i][1], aChaves[i][2])
                  oWorkFlow:Send()
               EndIf
            Next i
         ElseIf !Empty(aChaves)
            oWorkFlow := EasyWorkFlow():New(aChaves[1][1], aChaves[1][2])
            oWorkFlow:Send()
         EndIf
      EndIf
   Endif

If lSchedule 
   RpcClearEnv()
EndIf

Return aChaves

/*
Função..: EasyExecWF
Autor...: Guilherme Fernandes Pilan - GFP
Data....: 02/09/2013
Objetivo: Função para montagem de HTML para envio via e-mail.
*/
*-----------------------------------*
Function EasyExecWF(cAPH)
*-----------------------------------*
Local cHtml := ""

If EXISTUSRPAGE(cAPH)
   cHtml := "L_"+cAPH
Else
   cHtml := "H_"+cAPH
EndIf

Return cHtml