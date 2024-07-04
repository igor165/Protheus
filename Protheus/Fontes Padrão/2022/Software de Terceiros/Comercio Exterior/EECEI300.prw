#Include "MsObject.ch"
#Include "AVERAGE.CH"
#Include "APWizard.CH"
#Include "EEC.CH"
#Include "Protheus.CH"
#Include "FILEIO.CH"

#Define ENTER CHR(13)+CHR(10)

#Define CAPA		"1"
#Define CAPA_DET	"2"

/** Serviços */
#Define ENV_RE		"RE"
#Define ENV_DE		"DE"

/** Status  */
#Define NAO_ENVIADO	"N"
#Define ENVIADO		"E"
#Define RECEBIDO		"R"
#Define PROCESSADO	"P"
#Define CANCELADO		"C"

#Define EXT_XML		".xml"
#Define EXT_XSL		".xsl"
#Define XML_ISO_8859_1 "<?xml version='1.0' encoding='ISO-8859-1' ?>"
#Define XML_UTF_8 '<?xml version="1.0" encoding="UTF-8"?>'

#Define XML_STYLE "<?xml-stylesheet type='text/xsl' href='Rel_Impressao_RE.xsl'?>"
#Define XML_STYLE_DE '" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="lote.xsd" version="1.3">' //LGS-02/03/2016 - Mudança de Layout 1.2

Function EECEI300()
Private oINTSIS
Private lSrvDDE := EWJ->(FieldPos("EWJ_SERVIC")) > 0

	oINTSIS := EECINTSIS():New("Central de Integrações Siscomex", "Siscomex", "Ações", "Serviços", "Ações", "Serviços")
	oINTSIS:SetServices()
	oINTSIS:Show()

Return Nil

Class EECINTSIS From AvObject

	Data	aServices
	Data 	cName
    Data 	cSrvName
    Data 	cActName
    Data 	cTreeSrvName
    Data 	cTreeAcName
    Data 	cPanelName
    Data 	bOk
    Data 	bCancel
    Data 	cIconSrv
    Data 	cIconAction
    
    /** Serviço RE */
    Data 	cDirNotSent
    Data	cDirSent
    Data	cDirReceived
    Data	cDirProcessed
    Data	cDirRel
    Data	cDirRec
    
    /** Serviço DDE */
    Data	cDEDirNotSent
    Data	cDEDirSent
    Data	cDEDirCanceled
    
    Data	cTempDir
    Data	cDETempDir
    
    Data	cFileTemp
    
    Data 	cIdAtu
    Data	cSrvAtu
    
    Data	oUserParams


	Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Constructor
	Method SetServices()
	Method Show()
	Method SetDirectories()
	Method SendFileRE()
	Method CopyLote2T()
	Method ClearTemp()
	Method GetReturnRE()
	Method SetIdAtu(cId)
	Method ProcRetRe()
	Method GerNewRE()
	Method GetNewId()
	Method AltNumLote(cWork)
	Method CancelLote(cWork)
	Method VisEmbarque(cWork)
	Method EditConfigs()
    Method SetTemp()
    Method Imprimir()
    
End Class

Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Class EECINTSIS

   Self:cName			:= cName
   Self:cSrvName		:= cSrvName
   Self:cActName		:= cActName
   Self:cTreeSrvName	:= cTreeSrvName
   Self:cTreeAcName		:= cTreeAcName
   Self:cPanelName		:= cPanelName
   Self:bOk				:= bOk
   Self:bCancel			:= bCancel
   Self:cIconSrv		:= cIconSrv
   Self:cIconAction		:= cIconAction
   Self:aServices 		:= {}
   Self:oUserParams		:= EASYUSERCFG():New()
   
   Self:cIdAtu			:= ""
   Self:cSrvAtu			:= ""
   Self:cFileTemp		:= ""
   
   Self:SetDirectories()

Return Self

Method SetIdAtu(cId, cIdSel) Class EECINTSIS

   If ValType(cId) == "C"
      Self:cIdAtu := cID
   EndIf
   If ValType(cIdSel) == "C"
      Self:cSrvAtu := cIDSel
   EndIf

Return Nil

Method SetServices() Class EECINTSIS
Local nSetOrder //Usado para montar o setorder das tabelas 
Local oSrvRE, oSrvDE
Local aCposNE, aCposEnv, aCposRec, aCposProc
Local aDECposNE, aDECposEnv, aDECposCanc
Local aMenuSrv  := {} //AAF 22/07/2015 - Inicializar como array.
Local aSrvRE    := {"RAIZ", ENV_RE, ENV_RE+NAO_ENVIADO, ENV_RE+ENVIADO, ENV_RE+RECEBIDO, ENV_RE+PROCESSADO}
Local aTodosSrv := {"RAIZ", ENV_RE+NAO_ENVIADO, ENV_RE+ENVIADO, ENV_RE+RECEBIDO, ENV_RE+PROCESSADO,;
							ENV_DE+NAO_ENVIADO, ENV_DE+ENVIADO, ENV_DE+RECEBIDO, ENV_DE+PROCESSADO} 
   /** Serviço RE */
   If lSrvDDE
      nSetOrder := 4
      /** Para o serviço de 'RE' consideramos que o campo EWJ_SERVIC vazio é RE, assim não é preciso atualizar a base dos clientes. */
      AAdd(aMenuSrv,{ "  "+NAO_ENVIADO, "  "+ENVIADO, "  "+RECEBIDO, "  "+PROCESSADO, "  "+CANCELADO })
   Else
      nSetOrder := 2
      AAdd(aMenuSrv,{ NAO_ENVIADO, ENVIADO, RECEBIDO, PROCESSADO, CANCELADO })
   EndIf
   aCposNE   := {"EWJ_ID", "EWJ_PREEMB", "EWJ_ARQENV", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}   
   aCposEnv  := {"EWJ_ID", "EWJ_PREEMB", "EWJ_LOTE", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE", "EWJ_DATAG" , "EWJ_HORAG", "EWJ_USERG"}
   aCposRec  := {"EWJ_ID", "EWJ_PREEMB", "EWJ_LOTE", "EWJ_ARQREC", "EWJ_DATAR", "EWJ_HORAR", "EWJ_USERR", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE" , "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}   
   aCposProc := {"EWJ_ID", "EWJ_PREEMB", "EWJ_LOTE", "EWJ_ARQREC", "EWJ_DATAP", "EWJ_HORAP", "EWJ_USERP", "EWJ_DATAR" , "EWJ_HORAR", "EWJ_USERR", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}      
   aCposProc := {"EWJ_ID", "EWJ_PREEMB", "EWJ_LOTE", "EWJ_ARQREC", "EWJ_DATAP", "EWJ_HORAP", "EWJ_USERP", "EWJ_DATAR" , "EWJ_HORAR", "EWJ_USERR", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}
   
   oSrvRe:= EECSISSRV():New("Registro de Exportação" , "EWJ", "Lotes", ENV_RE , nSetOrder, "NORMAS", "NORMAS", "EWK", "Agrupamentos", "EWK_FILIAL+EWK_ID", "xFilial('EWK')+EWJ_ID", "oINTSIS:SetIdAtu(EWJ_ID, cIdSel)")
   
   oSrvRe:AddFolder("Não enviados" , NAO_ENVIADO	, aMenuSrv[1][1] ,aCposNE    ,"Folder5","Folder6")
   oSrvRe:AddFolder("Enviados"     , ENVIADO		, aMenuSrv[1][2] ,aCposEnv   ,"Folder5","Folder6")
   oSrvRe:AddFolder("Recebidos"    , RECEBIDO		, aMenuSrv[1][3] ,aCposRec   ,"Folder5","Folder6")
   oSrvRe:AddFolder("Processados"  , PROCESSADO	, aMenuSrv[1][4] ,aCposProc  ,"Folder5","Folder6")
   oSrvRe:AddFolder("Cancelados"   , CANCELADO	, aMenuSrv[1][5] ,aCposProc  ,"Folder5","Folder6")
   
   /** Serviço DDE */
   If lSrvDDE
      aMenuSrv :={}
      AAdd(aMenuSrv,{ ENV_DE+NAO_ENVIADO, ENV_DE+ENVIADO, ENV_DE+CANCELADO })      
      aDECposNE  := {"EWJ_ID", "EWJ_ARQENV", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}
      aDECposEnv := {"EWJ_ID", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}
      aDECposCanc:= {"EWJ_ID", "EWJ_ARQENV", "EWJ_DATAE", "EWJ_HORAE", "EWJ_USERE", "EWJ_DATAG", "EWJ_HORAG", "EWJ_USERG"}
   
	  oSrvDe:= EECSISSRV():New("Despacho de Exportação", "EWJ", "Lotes", ENV_DE , nSetOrder, "NORMAS", "NORMAS", "EEX", "Agrupamentos", "xFilial('EWJ')+EEX_ID", "xFilial('EWJ')+EWJ_ID", "oINTSIS:SetIdAtu(EWJ_ID, cIdSel)")
	  
	  oSrvDe:AddFolder("Não enviados" , NAO_ENVIADO	, aMenuSrv[1][1] ,aDECposNE  ,"Folder5","Folder6")
	  oSrvDe:AddFolder("Enviados"     , ENVIADO		, aMenuSrv[1][2] ,aDECposEnv ,"Folder5","Folder6")
	  oSrvDe:AddFolder("Cancelados"   , CANCELADO		, aMenuSrv[1][3] ,aDECposCanc,"Folder5","Folder6")
   EndIf
   
   /** Botoes - Ações */
   oSrvRe:AddAction("Novo Arquivo",      "GER", aTodosSrv, {|     | oINTSIS:GerNewRE() }        , NAO_ENVIADO, "BMPINCLUIR", "BMPINCLUIR") //RE - DDE
   oSrvRe:AddAction("Enviar",            "TEL", aTodosSrv, {|cWork| oINTSIS:SendFileRe(cWork) } , ENVIADO    , "MSGFORWD"  , "MSGFORWD")   //RE - DDE
   oSrvRe:AddAction("Receber",           "ENV", aSrvRE   , {|     | oINTSIS:GetReturnRE() }     , RECEBIDO   , "OPEN"      , "OPEN")       //RE
   oSrvRe:AddAction("Processar",         "RET", aSrvRE   , {|cWork| oINTSIS:ProcRetRe(cWork) }  , PROCESSADO , "SDURECALL" , "SDURECALL")  //RE
   oSrvRe:AddAction("Alterar Lote",      "ALT", aSrvRE   , {|cWork| oINTSIS:AltNumLote(cWork) } , ""         , "NOTE"      , "NOTE")       //RE
   oSrvRe:AddAction("Visualiza Embarque","VIS", aTodosSrv, {|cWork| oINTSIS:VisEmbarque(cWork) }, ""         , "NOTE"      , "NOTE")       //RE - DDE
   oSrvRe:AddAction("Cancelar Lote",     "CAN", aTodosSrv, {|cWork| oINTSIS:CancelLote(cWork) } , ""         , "EXCLUIR"   , "EXCLUIR")    //RE - DDE
   oSrvRe:AddAction("Configurações",     "CFG", aTodosSrv, {|     | oINTSIS:EditConfigs() }     , ""         , "NCO"       , "NCO")        //RE - DDE
   oSrvRe:AddAction("Imprimir",          "IMP", aSrvRE   , {|     | oINTSIS:Imprimir() }        , ""         , "PMSPRINT"  , "PMSPRINT")   //RE
   
   aAdd(Self:aServices, oSrvRE)
   If lSrvDDE
      aAdd(Self:aServices, oSrvDE)
   EndIf

Return Nil

Method Show() Class EECINTSIS
Local aServicos := {}
Local aAcoes  := {}
Local nInc

   For nInc := 1 To Len(Self:aServices)
      aAdd(aServicos, Self:aServices[nInc]:RetService())
      aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
   Next

   //RMD - 15/09/12 - Incluída opção para não atualizar a árvore de ações a cada troca de pasta.
   AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .T.,"{|| EI300VisDet() }","{|oMsSelect| EI300VLote(oMsSelect)}", .F.)

Return Nil

Method SetDirectories() Class EECINTSIS

    Self:cDirNotSent		:= "\comex\easylink\siscomex\re\naoenviados\"
    Self:cDirSent			:= "\comex\easylink\siscomex\re\enviados\"
    Self:cDirReceived	:= "\comex\easylink\siscomex\re\recebidos\"
    Self:cDirProcessed	:= "\comex\easylink\siscomex\re\processados\"
    Self:cDirRel			:= "\comex\easylink\siscomex\re\relatorio\"
    Self:cDirRec			:= "\comex\easylink\siscomex\re\recursos\"
    
    Self:cDEDirNotSent	:= "\comex\easylink\siscomex\dde\naoenviados\"
    Self:cDEDirSent		:= "\comex\easylink\siscomex\dde\enviados\"
    Self:cDEDirCanceled	:= "\comex\easylink\siscomex\dde\cancelados\"

    Self:cTempDir		:= SetTempDir(Self:oUserParams:LoadParam("DIRTEMP",  "%TEMP%"),"RE")
    Self:cDETempDir	:= SetTempDir(Self:oUserParams:LoadParam("DEDIRTEMP",  "%TEMP%"),"DE")

Return Nil


/*
Função     : SetTempDir()
Objetivos  : Define o diretório temporário com base no parâmetro "DIRTEMP"
Parâmetros : Se o conteúdo for %TEMP%, altera para GetTempPath()
             Se o conteúdo for um diretório, utiliza este diretório
Retorno    : Retorna o diretório para ser atribuido na variável cTempDir
Autor      : Diogo Felipe dos Santos - DFS
Data       : 18/01/2011
*/

Static Function SetTempDir(cTempDir,cSrv)
Local cDir    := ""
Local cPasta  := ""
Default cSrv  := "RE"

	If cSrv == "DE"
	   cPasta := "sigaeec_int_dde\"
	Else
	   cPasta := "sigaeec_int_re\"
	EndIf

   If Empty(cTempDir) .Or. AllTrim(cTempDir) == "%TEMP%"
      cDir := GetTempPath() + cPasta
   Else
      cDir := cTempDir + cPasta
   EndIf

Return cDir

Method CopyLote2T(cArqOri) Class EECINTSIS
Local lRet := .F., cLocal := ""
Local cSrvSel := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)

Begin Sequence

   If !File(cArqOri)
      MsgInfo(StrTran("O arquivo '###' não foi encontrado. Não será possível executar a rotina de envio.", "###", Self:cIdAtu + EXT_XML), "Aviso")
      Break
   EndIf
   
   If !Self:SetTemp()
      Self:cFileTemp := ""
      Break
   EndIf

   If !Self:ClearTemp()
      MsgInfo(StrTran("O arquivo temporário '###' já existe e não foi possível substituí-lo. Não será possível executar a rotina.", "###", Self:cFileTemp), "Atenção")
      Self:cFileTemp := ""
      Break
   EndIf

   If cSrvSel == "DE"
      cLocal := Self:cDETempDir
      If !lIsDir( cLocal )
         MakeDir (cLocal)
      EndIf
   Else
      cLocal := Self:cTempDir
   EndIf
   
   If !CpyS2T(cArqOri, cLocal, .T.)
      MsgInfo(StrTran("Erro ao copiar o arquivo '###' para o diretório temporário. Não será possível prosseguir.", "###", cArqOri), "Atenção")
      Self:cFileTemp := ""
      Break
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

Method SetTemp() Class EECINTSIS
Local lRet := .T.

   If !lIsDir(Self:cTempDir) .And. !(MakeDir(Self:cTempDir) == 0)
      MsgInfo(StrTran("Erro ao criar o diretório temporário '###'. Não será possível executar a rotina de envio.", "###", Self:cTempDir), "Atenção")
      lRet := .F.
   EndIf

Return lRet

Method ClearTemp() Class EECINTSIS
Local lRet := .T.          
  
  If File(Self:cFileTemp)
     lRet := (FErase(Self:cFileTemp) == 0)
  EndIf
 
Return lRet

Method GetReturnRE() Class EECINTSIS
Local cDir := Self:oUserParams:LoadParam("DIRLOCAL", "c:\LOTES\")
Local aFiles := {}
Local nInc
Local cFile, oFile
Local cError := "", cWarning := ""
Local nOk := 0

Self:ResetError()

Begin Sequence

   If Right(AllTrim(Self:cSrvAtu), 1) <> RECEBIDO .And. Right(AllTrim(Self:cSrvAtu), 1) <> ENVIADO   //FSM - 05/12/11
      MsgInfo("Selecione a pasta 'Itens Recebidos' para receber novos arquivos.", "Aviso")
      Break
   EndIf

   aFiles1 := Directory(cDir + "*.xml")
   aFiles2 := Directory(cDir + "*.")
   aEval(aFiles1, {|x| aAdd(aFiles, x) })
   aEval(aFiles2, {|x| aAdd(aFiles, x) })

   EWJ->(DbSetOrder(1))
   
   For nInc := 1 To Len(aFiles)
      If !CpyT2S(cDir + aFiles[nInc][1], Self:cDirReceived, .T.)
         Self:Error("Não foi possível copiar o arquivo de retorno do Siscomex "+AllTrim(cDir+aFiles[nInc][1])+" para o servidor ("+AllTrim(Self:cDirReceived)+")")
         Loop
      EndIf
      cFile := Self:cDirReceived + aFiles[nInc][1]
      oFile := XmlParserFile(cFile , "_" , @cError, @cWarning)
      
      If ValType(oFile) <> "O"
         Self:Error("Não foi possível ler arquivo de retorno do Siscomex "+AllTrim(cDir+aFiles[nInc][1])+". Este não é um XML válido.") 
         
      ElseIf !(ValType(oResposta := XmlChildEx(oFile, "_RESPOSTA_LOTE")) == "O" .And. ValType(oID := XmlChildEx(oResposta, "_ID_ARQUIVO")) == "O" .AND.;
               ValType(oDt := XmlChildEx(oResposta, "_DT_HORA_PROCESSAMENTO")) == "O" .And. ValType(oRE := XmlChildEx(oResposta, "_RE")) $ "A/O" )
               
         Self:Error("Não foi possível ler arquivo "+AllTrim(aFiles[nInc][1])+". Este XML não contém os dados de retorno do Siscomex.")
         
      ElseIf !EWJ->(DbSeek(xFilial()+oId:Text))
         Self:Error("Não foi possível ler o retorno do arquivo "+AllTrim(aFiles[nInc][1])+". O ID do Lote enviado não está cadastrado.")
         
      ElseIf EWJ->EWJ_STATUS <> ENVIADO
         Self:Error("Não foi possível carregar o retorno do arquivo "+AllTrim(aFiles[nInc][1])+". O Lote não está com status Enviado.")
         
      Else
         
         EWJ->(RecLock("EWJ", .F.))
         EWJ->EWJ_STATUS := RECEBIDO
         EWJ->EWJ_ARQREC := aFiles[nInc][1]
         EWJ->EWJ_DATAR  := dDataBase
         EWJ->EWJ_HORAR  := Time()
         EWJ->EWJ_USERR  := cUserName
         EWJ->(MsUnlock())

         If !(FRename(cDir + aFiles[nInc][1], cDir + aFiles[nInc][1] + ".ok") == 0)
            Self:Error("Não foi possível renomear o arquivo "+AllTrim(aFiles[nInc][1])+" para "+aFiles[nInc][1]+".ok .")
         EndIf
         ++nOk
         Loop
      EndIf
      
      If !(FRename(cDir + aFiles[nInc][1], cDir + aFiles[nInc][1]+".err") == 0)      
         Self:Error("Não foi possível renomear o arquivo "+AllTrim(aFiles[nInc][1])+" para "+aFiles[nInc][1]+".err .")
      EndIf
   Next
   
   If Len(aFiles) == 0
      MsgInfo(StrTran("Não foram encontrados novos arquivos no diretório '###'.", "###", cDir), "Aviso")
   Else
      MsgInfo(StrTran("Resultado da importação de arquivos do diretório '###'.", "###", cDir) + ENTER;
                      + "Arquivos importados: " + AllTrim(Str(nOk)) + ENTER;
                      + "Arquivos não importados (erro): " + AllTrim(Str(Len(Self:aError))), "Aviso")
      If Self:lError .AND. MsgYesNo("Deseja visualizar os erros ocorridos?", "Aviso")
         Self:ShowErrors()
      EndIf
      If nOk > 0 .And. MsgYesNo("Deseja processar os arquivos recebidos?", "Aviso")
         Self:ProcRetRe()
      EndIf
   EndIf          
   
   //DFS - 28/02/13 - Ponto de entrada para disparar ação ao receber o re do Siscomex
   If EasyEntryPoint("EECEI300")
      ExecBlock("EECSI100",.F.,.F.,"DDE_AVERBADA")
   Endif       
   
End Sequence

Return Nil

Method SendFileRE(cWork) Class EECINTSIS
Local oDlg, oDlg1, oDlg2
Local nLin := 10
Local cFile
Local cLote := CriaVar("EWJ_LOTE")
Local oBold := TFont():New(,,,, .T.)
Local lRet := .F., lEnv := .F., lRetDE := .F.
Local bValidEnv		:= {|| If(lEnv .And. Empty(cLote), lRet := !MsgYesNo("O número do lote não foi informado. Deseja manter o status do item como 'Não enviado?'", "Atenção"),), oWizard:oModal:oOwner:End() }
Local bValidCancel	:= {|| If(MsgYesNo("Confirma o cancelamento do envio?", "Aviso"), Eval(bValidEnv), .F.) } 
Local bValidLote	:= {|| If(Empty(cLote),(MsgInfo("É necessário informar o número do lote para prosseguir.", "Atenção"), .F.), lRet := .T.) }
local bValidFinish  := {|| .T.}
Local cSrvSel       := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)
Local cTitulo := cTexto := ""
Private oWizard

Begin Sequence

   If Right(AllTrim(Self:cSrvAtu), 1) <> NAO_ENVIADO
      MsgInfo("Selecione a pasta 'Itens não Enviados' e selecione um lote para enviar .", "Aviso")
      Break
   EndIf
       
   If Select(cWork) == 0 .Or. IsVazio(cWork)
      MsgInfo("Não existem arquivos pendentes para envio.", "Aviso")
      Break
   EndIf

   If cSrvSel == "DE"
      
      bValidFinish := {|| .T., lRet := .T.}
      
      Self:cFileTemp := Self:cDETempDir + Self:cIdAtu + EXT_XML
      If !Self:CopyLote2T(Self:cDEDirNotSent + Self:cIdAtu + EXT_XML)
         Break
      EndIf
      cTitulo := "Wizard de Envio de Declaração de Despacho de Exportação"
      cTexto  := "Esta rotina irá apresentar roteiro para envio de arquivos de lote de declaração de despacho de exportação." 
      
   Else
   
      Self:cFileTemp := Self:cTempDir + Self:cIdAtu + EXT_XML
      If !Self:CopyLote2T(Self:cDirNotSent + Self:cIdAtu + EXT_XML)
         Break
      EndIf
      cTitulo := "Wizard de Envio de Registro de Exportação"
      cTexto  := "Esta rotina irá apresentar roteiro para envio de arquivos de lote de registro de exportação." 
      
   EndIf
   
   cFile := Self:cFileTemp
   
   DEFINE WIZARD oWizard	TITLE cTitulo;
							HEADER "Início";
							MESSAGE "Apresentação";
							TEXT cTexto;
							PANEL NEXT {|| .T. };
							FINISH {|| .T.}
   
      oWizard:oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

      CREATE PANEL oWizard HEADER "Definição do arquivo do lote"		MESSAGE "Passo 1:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	{|| .T. };
																		EXEC	{|| oGet1:SetFocus() }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "SEL_FILE"
      
      @ 25, 10 Say "Copie a localização do arquivo, clicando no botão ao lado do campo abaixo:" Of oPanel Pixel
      @ 40, 10 Get oGet1 Var cFile Size 210,12 Of oPanel Pixel
      oBtn1 := TBtnBmp2():New(81,438,26,26,"COPYUSER",,,,{||Alert("Botão 01")},oPanel,,,.T. )
      oBtn1:cDefaultAct := "COPY"
      oGet1:SelectAll()

      CREATE PANEL oWizard HEADER "Upload do arquivo no portal Siscomex Exportação"	MESSAGE "Passo 2:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	{|| .T. };
																		EXEC	{|| .T. }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "SEND_FILE"
      
      If cSrvSel == "DE"
         @20, 10 Say "Para enviar lotes de Declaração de Exportação (DE) por estrutura própria, deve-se acessar a funcionalidade" + ENTER +;
                     'através do menu principal "Declaração de Exportação"/"Estrutura Própria"/"Transmitir lote".' + ENTER +;
                     "Cole a localização do arquivo no campo destacado abaixo e confirme:" Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel

         @ 052, 18 BitMap ResName "AVG_ENVDE" Size 595, 141 NoBorder Of oPanel Pixel
      
      Else
         @20, 10 Say "No navegador, acesse o Siscomex Exportação Web e navegue até a página 'Transmissão RE por estrutura " + ENTER +;
                     "própria." + ENTER +;
                     "Cole a localização do arquivo no campo destacado abaixo e confirme:" Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel
         
         @ 052, 18 BitMap ResName "AVG_ENVRE1" Size 595, 141 NoBorder Of oPanel Pixel
      
      EndIf
      
      If cSrvSel <> "DE"
         CREATE PANEL oWizard HEADER "Retorno do lote"					MESSAGE "Passo 3:";
																		PANEL;
																		BACK	{|| .T. }; //LRS - 09/11/2017
																		NEXT 	bValidLote;
																		FINISH	bValidLote;
																		EXEC {|| lEnv := .T., oGet2:SetFocus() }
																		oPanel       := oWizard:oMPanel[Len(oWizard:oMPanel)]
																		oPanel:cName := "RET_LOTE"

         oGet2 := EI300TelaL(oPanel, @cLote)
       EndIf
       
       CREATE PANEL oWizard HEADER "Retorno do lote"					MESSAGE "Final:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	bValidFinish
																		oPanel       := oWizard:oMPanel[Len(oWizard:oMPanel)]
																		oPanel:cName := "FINAL"
		If cSrvSel == "DE"
		   @20, 10 Say "Envio do lote " + cValToChar(Self:cIdAtu) +" de declaração de despacho de exportação, finalizado. " Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel

		Else
		   @20, 10 Say "Envio finalizado. Para retornar o número do RE, consulte a disponibilidade de arquivo de " + ENTER +;
		               "retorno do lote a partir da opção 'Resultado do Processamento do Lote de Estrutura Própria', conforme imagem abaixo." + ENTER +;
		               "De posse do arquivo de retorno, utilize a opção 'Receber'." Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel
		   @ 052, 18 BitMap ResName "AVG_ENVRE3" Size 595, 141 NoBorder Of oPanel Pixel
		
		EndIF      


   oWizard:oCancel:bAction := bValidCancel
   oWizard:oDlg:Owner():lEscClose:= .F.

   ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

   If File(Self:cFileTemp)
      Self:ClearTemp()
   EndIf
   Self:cFileTemp := ""
   
   If lRet
      If cSrvSel == "DE"  //LRS - 22/09/2015 - Passando o quinto parãmetro na function AvCpyFile
         AvCpyFile(Self:cDEDirNotSent + Self:cIdAtu + EXT_XML, Self:cDEDirSent + Self:cIdAtu + EXT_XML,, .T., .T.)
      Else
         AvCpyFile(Self:cDirNotSent + Self:cIdAtu + EXT_XML, Self:cDirSent + Self:cIdAtu + EXT_XML,, .T., .T.)
      EndIf
      Begin Transaction
         EWJ->(DbSetOrder(1))
         EWJ->(DbSeek(xFilial()+Self:cIdAtu))
         EWJ->(RecLock("EWJ", .F.))
         EWJ->EWJ_STATUS := ENVIADO
         EWJ->EWJ_DATAE  := dDataBase
         EWJ->EWJ_HORAE  := Time()
         EWJ->EWJ_USERE  := cUserName
         EWJ->EWJ_LOTE   := cLote
         EWJ->(MsUnlock())
         
         If cSrvSel <> "DE"
            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial()+EWJ->EWJ_PREEMB))
               EEC->(RecLock("EEC",.F.))
               EEC->EEC_STASIS := SI_RS //Aguardando retorno para siscomex
               EEC->(MsUnlock())
            EndIf
         EndIf
         
      End Transaction
   EndIf

End Sequence

Return Nil

Method ProcRetRe(cWork) Class EECINTSIS
Local oFile, cDataHora, dDataHora
Local cError := "", cWarning := "", cNCM := ""
Local nInc
Local cSeqRE, cRE, cStatus, cErroRE, cTratAdmRE
Local lRetOk := .T.

   EWJ->(DbGoTop())
   EWJ->(DbSetOrder(2))   
   If !EWJ->(DbSeek(xFilial()+RECEBIDO))
      MsgInfo("Não existem arquivos recebidos disponíveis para processamento.", "Aviso")
      Break
   EndIf
     
   While EWJ->(!Eof() .And. xFilial() == EWJ_FILIAL .And. EWJ_STATUS == RECEBIDO)

      lRetOk := .T.
      oFile := XmlParserFile(Self:cDirReceived + EWJ->EWJ_ARQREC , "_" , @cError, @cWarning)
      If ValType(oFile) <> "O" .Or. ValType(XmlChildEx(oFile, "_RESPOSTA_LOTE")) <> "O" .Or. ValType(XmlChildEx(oFile:_RESPOSTA_LOTE, "_RE")) == "U"
         MsgInfo(StrTran("Foi encontrado um erro na estrutura do arquivo '###'.", "###", AllTrim(EWJ->EWJ_ARQREC)) + ENTER +;
                 StrTran("O retorno do Lote '###' não poderá ser processado, e o seu status será alterado para 'Enviado' até que seja recebido novo arquivo de retorno.", "###", AllTrim(EWJ->EWJ_LOTE)), "Aviso")
         EWJ->(RecLock("EWJ", .F.))
         EWJ->EWJ_STATUS := ENVIADO
         EWJ->EWJ_ARQREC := ""
         EWJ->EWJ_DATAR  := CToD("")
         EWJ->EWJ_HORAR  := ""
         EWJ->EWJ_USERR  := ""
         EWJ->(MsUnlock())
         EWJ->(DbSkip())
         Loop
      EndIf

      If ValType(oFile:_RESPOSTA_LOTE:_RE) == "A"
         aRE := oFile:_RESPOSTA_LOTE:_RE
      Else
         aRE := {oFile:_RESPOSTA_LOTE:_RE}
      EndIf
      
      cDataHora := oFile:_RESPOSTA_LOTE:_DT_HORA_PROCESSAMENTO:Text //2010-11-01 17:49:56.0
      dDataHora := CTod(SubStr(cDataHora,9,2)+"/"+SubStr(cDataHora,6,2)+"/"+Left(cDataHora,4))
      
      For nInc := 1 To Len(aRE)
         cSeqRE		:= StrZero(Val(aRe[nInc]:_Seq:Text), AvSx3("EWK_SEQRE", AV_TAMANHO))
         cRE		:= aRe[nInc]:_NUMERO_RE:Text
         lRetOK     := lRetOk .And. !Empty(cRE)
         cStatus	:= aRe[nInc]:_STATUS:Text
         cErroRE	:= GetErrosVld(aRe[nInc]:_ERRO_VALIDACAO)
         cTratAdmRE	:= GetTratAdm(aRe[nInc]:_TRATAMENTO_ADMINISTRATIVO)
         
         EWK->(DbSetOrder(1))
         If EWK->(DbSeek(xFilial()+EWJ->EWJ_ID+cSeqRE))
            EWK->(RecLock("EWK", .F.))
               EWP->(DbSetOrder(2))
               EE9->(DbSetOrder(3))
               EWP->(DbSeek(xFilial()+EWJ->EWJ_ID+EWK->EWK_SEQRE))
               While EWP->(!Eof() .And. EWP_FILIAL+EWP_ID+EWP_SEQRE == xFilial()+EWJ->EWJ_ID+EWK->EWK_SEQRE)
                  If EE9->(DbSeek(xFilial()+EWJ->EWJ_PREEMB+EWP->EWP_SEQEMB))
                     EE9->(RecLock("EE9", .F.))
                     If !Empty(cRE)
                        EWK->EWK_NRORE	:= cRE
                        EE9->EE9_RE 	:= cRE
                        EE9->EE9_DTRE   := dDataHora
                        If EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0  // GFP - 17/12/2015
                           If Empty(EE9->EE9_PERIE) 
                              cNCM := Posicione('SB1',1,xFilial('SB1') + EE9->EE9_COD_I ,'B1_POSIPI')
                              EE9->EE9_PERIE := Posicione('SYD',1,xFilial('SYD') + AvKey(cNCM,"YD_TEC") ,'YD_PER_IE')
                           EndIf
                           EE9->EE9_BASIE := AE100GatIE('EE9_BASIE',1,"EE9")
                           EE9->EE9_VLRIE := AE100GatIE('EE9_VLRIE',2,"EE9")
                        EndIf
                     Else
                        EE9->EE9_ID 	:= ""
                        EE9->EE9_SEQRE	:= ""
                     EndIf
                     
                     //DFS - 21/03/13 - Ponto de entrada para manipular o retorno da Data e Número do RE
                     If EasyEntryPoint("EECEI300")
                        ExecBlock("EECEI300",.F.,.F.,{"PE_RE_DT"}) 
                     Endif
             		     		 
                     EE9->(MsUnlock())
                  EndIf
                  EWP->(DbSkip())
               EndDo
            EWK->EWK_STATUS := cStatus
            EWK->EWK_DTRE   := dDataHora
            If EWK->(FieldPos("EWK_TRAADM")) > 0
               EWK->EWK_TRAADM := cTratAdmRE
            Else
               MSMM(EWK->EWK_CODADM,,,,EXCMEMO)
               MSMM(,AVSX3("EWK_TRAADM",AV_TAMANHO),,cTratAdmRE,INCMEMO,,,"EWK","EWK_CODADM")
            EndIf
            If EWK->(FieldPos("EWK_ERROS")) > 0
               EWK->EWK_ERROS  := cErroRE
            Else
               MSMM(EWK->EWK_CODERR,,,,EXCMEMO)
               MSMM(,AVSX3("EWK_ERROS",AV_TAMANHO),,cErroRE,INCMEMO,,,"EWK","EWK_CODERR")
            EndIf
            EWK->(MsUnlock())
         EndIf
      Next     
      
      EWJ->(RecLock("EWJ", .F.))
      EWJ->EWJ_STATUS := PROCESSADO
      EWJ->EWJ_DATAP  := dDataBase
      EWJ->EWJ_HORAP  := Time()
      EWJ->EWJ_USERP  := cUserName
      EWJ->(MsUnlock())
      
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(xFilial()+EWJ->EWJ_PREEMB))
         EEC->(RecLock("EEC",.F.))
         If lRetOk //Todos RE's forem aceitos
            EEC->EEC_STASIS := SI_SF //Siscomex finalizado
         Else
            EEC->EEC_STASIS := SI_ER //Erro retorno Siscomex
         EndIf
         EEC->(MsUnlock())
      EndIf
      EWJ->(DbSkip())
   EndDo

Return Nil

Static Function GetTratAdm(oRe)
Local aMsg := {}, aDet := {}, xNod, nInc, nInc1, cRet := ""

   If ValType(xNod := XmlChildEx(oRE, "_DETALHE_TRATAMENTO")) == "O"
      aMsg := {xNod}
   ElseIf ValType(xNod) == "A"
      aMsg := xNod
   EndIf
   
   For nInc := 1 To Len(aMsg)
      cRet += "Órgão: " + aMsg[nInc]:_ORGAO:Text + ENTER
      cRet += "Status Anuência: " + aMsg[nInc]:_STATUS_ANUENCIA:Text + ENTER
      cRet += "Mensagem: " + ENTER
      If ValType(xNod := XMLChildEx(aMsg[nInc], "_MENSAGEM")) == "A"
         aDet := xNod
      ElseIf ValType(xNod) == "A"
         aDet := {xNod}
      Else
         aDet := {}
      EndIf
      For nInc1 := 1 To Len(aDet)
         cRet += aDet[nInc1]:Text + ENTER
      Next      
      cRet += ENTER
   Next

Return cRet

Static Function GetErrosVld(oRE)
Local aMsg := {}, nInc, cRet := ""

   If ValType(xNod := XmlChildEx(oRE, "_MSG")) == "O"
      aMsg := {xNod}
   ElseIf ValType(xNod) == "A"
      aMsg := xNod
   EndIf
   
   For nInc := 1 To Len(aMsg)
      cRet += aMsg[nInc]:Text + ENTER
   Next

Return cRet

Method AltNumLote(cWork) Class EECINTSIS
Local oDlg
Local bOk := {|| If(Empty(cLote), MsgInfo("Número do lote não informado.", "Aviso"), (lRet := .T., oDlg:End())) }
Local cLote
Local lRet := .F.

Begin Sequence

   If Select(cWork) == 0 .Or. IsVazio(cWork)
      MsgInfo("Não existem arquivos disponíveis para alteração do número do lote.", "Aviso")
      Break
   EndIf
   
   If Right(AllTrim(Self:cSrvAtu), 1) <> ENVIADO
      MsgInfo("Selecione a pasta 'Itens Enviados' para alterar números de lote.", "Aviso")
      Break
   EndIf
   
   cLote := (cWork)->EWJ_LOTE

   DEFINE MSDIALOG oDlg TITLE "Alteração do número do lote" FROM 0,0 TO 277, 578 OF oMainWnd PIXEL 

      EI300TelaL(oDlg, @cLote)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, {|| oDlg:End() }) CENTERED
   
   If lRet
      EWJ->(DbSetOrder(1))
      EWJ->(DbSeek(xFilial()+(cWork)->EWJ_ID))
      EWJ->(RecLock("EWJ", .F.))
      EWJ->EWJ_LOTE := cLote
      EWJ->(MsUnlock())
   EndIf

End Sequence

Return Nil

Method CancelLote(cWork) Class EECINTSIS
Local cMsg := ""
Local cSrvSel := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)
Local lDelEEX := .F.
Local aDelDDE := {}
local i

Begin Sequence

   If Select(cWork) == 0 .Or. IsVazio(cWork)
      MsgInfo("Não existem lotes selecionados para cancelar.", "Aviso")
      Break
   
   ElseIf cSrvSel == "DE"
      
      Do Case
         Case EWJ->EWJ_STATUS == NAO_ENVIADO
              cMsg := "Essa operação não poderá ser revertida e será necessário gerar um novo lote de integração DDE."
         
         Case EWJ->EWJ_STATUS == ENVIADO
              cMsg := "Este lote de integração DDE já foi enviado ao SISCOMEX, e pode já estar gerado no SISCOMEX. Pode ser necessario cancelar a DDE manualmente no SISCOMEX."
      EndCase
      
      If !MsgYesNo(cMsg + Chr(13)+Chr(10) + "Tem certeza que deseja cancelar o Lote com ID "+AllTrim((cWork)->EWJ_ID)+"?","Aviso")
         Break
      EndIf
      
      EWJ->(DbSetOrder(1))
      EEX->(DbSetOrder(4))
      EEZ->(DbSetOrder(3))
      EWY->(DbSetOrder(1))
      If EWJ->(DbSeek(xFilial()+AvKey((cWork)->EWJ_ID,"EWJ_ID")+AvKey(cSrvSel,"EWJ_SERVIC")))
         
         Do Case
            Case EWJ->EWJ_STATUS == NAO_ENVIADO //LRS - 22/09/2015 - Passando o quinto parãmetro na function AvCpyFile
                 AvCpyFile(Self:cDEDirNotSent + Self:cIdAtu + EXT_XML, Self:cDEDirCanceled + Self:cIdAtu + EXT_XML,, .T., .T.)
            
            Case EWJ->EWJ_STATUS == ENVIADO
                 AvCpyFile(Self:cDEDirSent + Self:cIdAtu + EXT_XML, Self:cDEDirCanceled + Self:cIdAtu + EXT_XML,, .T., .T.)
         EndCase
         
         lDelEEX := EEX->(DbSeek(xFilial("EEX")+EWJ->EWJ_ID))         
         EWJ->(RecLock("EWJ", .F.))
         EWJ->EWJ_STATUS := CANCELADO
         EWJ->(MsUnlock())
         
         If lDelEEX
            Do While EEX->(!Eof()) .And. EEX->EEX_ID == EWJ->EWJ_ID
               AAdd(aDelDDE,{EEX->EEX_PREEMB,EEX->EEX_ID})
               EEX->(DbSkip())
            EndDo
            
            If !Empty(aDelDDE)
               EEX->(DbSetOrder(1))
               For i:=1 To Len(aDelDDE)
                   If EEX->(DbSeek(xFilial("EEX")+AvKey(aDelDDE[i][1],"EEX_PREEMB")+AvKey(aDelDDE[i][2],"EEX_ID")))
                      RecLock("EEX", .F.)
                      EEX->(dbDelete())
                      EEX->(MsUnlock())
                   EndIf
                   If EEZ->(DbSeek(xFilial("EEZ")+AvKey(aDelDDE[i][1],"EEZ_PREEMB")+AvKey(aDelDDE[i][2],"EEZ_ID")))
                      Do While EEZ->(!Eof()) .And. EEZ->EEZ_PREEMB == AvKey(aDelDDE[i][1],"EEZ_PREEMB");
                                             .And. EEZ->EEZ_ID == AvKey(aDelDDE[i][2],"EEZ_ID")
                         RecLock("EEZ", .F.)
                         EEZ->(dbDelete())
                         EEZ->(MsUnlock())
                         EEZ->(DbSkip())
                      EndDo
                   EndIf
                   If EWY->(DbSeek(xFilial("EWJ")+AvKey(aDelDDE[i][2],"EWY_ID")+AvKey(aDelDDE[i][1],"EWY_PREEMB")))
                      Do While EWY->(!Eof()) .And. EWY->EWY_PREEMB == AvKey(aDelDDE[i][1],"EWY_PREEMB");
                                             .And. EWY->EWY_ID == AvKey(aDelDDE[i][2],"EWY_ID")
                         RecLock("EWY", .F.)
                         EWY->(dbDelete())
                         EWY->(MsUnlock())
                         EWY->(DbSkip())
                      EndDo
                   EndIf                   
               Next
            EndIf            
         EndIf            
      EndIf   
      
   Else//cSrvSel == "RE" 
      EWJ->(DbSetOrder(1))
      EWK->(DbSetOrder(1))
      EWP->(DbSetOrder(2))
      EE9->(DbSetOrder(3))
      EEC->(DbSetOrder(1))
      If EWJ->(DbSeek(xFilial()+(cWork)->EWJ_ID))
      /* FSM - 05/12/11 */
         Do Case
         
            Case EWJ->EWJ_STATUS == NAO_ENVIADO
                 cMsg := "Essa operação não poderá ser revertida e será necessário gerar um novo lote para o processo "+AllTrim((cWork)->EWJ_PREEMB)+"."

            Case EWJ->EWJ_STATUS == ENVIADO
                 cMsg := "Este lote já foi enviado ao SISCOMEX, e pode possuir REs já gerados no SISCOMEX. Pode ser necessario cancelar os REs manualmente no SISCOMEX."

            Case EWJ->EWJ_STATUS == RECEBIDO
                 cMsg := "Este lote não foi processado no Easy. Pode ser necessário cancelar os REs manualmente no SISCOMEX."

            Case EWJ->EWJ_STATUS == PROCESSADO
                 cMsg := "Essa operação não poderá ser revertida e será necessário gerar um novo lote para o processo "+AllTrim((cWork)->EWJ_PREEMB)+"."
                 If EWK->(DbSeek(xFilial()+EWJ->EWJ_ID))

                    While EWK->(!EOF()) .And. EWK->EWK_FILIAL == EWJ->EWJ_FILIAL .And. EWJ->EWJ_ID == EWK->EWK_ID
                          IF !Empty(EWK->EWK_NRORE)
                             cMsg := "Existe(m) RE(s) ja gerado(s) no SISCOMEX. É necessário cancelar o(s) RE(s) manualmente no SISCOMEX."
                             Exit
                          EndIf
                          EWK->(DBSkip())
                    EndDo
                    
                 EndIf
         EndCase

         If !MsgYesNo(cMsg + Chr(13)+Chr(10) + "Tem certeza que deseja cancelar o Lote com ID "+AllTrim((cWork)->EWJ_ID)+"?","Aviso")
            Break 
         Else
            EWJ->(RecLock("EWJ", .F.))
            EWJ->EWJ_STATUS := CANCELADO
            EWJ->(MsUnlock())
            
            If EWK->(DbSeek(xFilial()+EWJ->EWJ_ID))
               While EWK->(!Eof() .And. EWK_FILIAL+EWK_ID == xFilial()+(cWork)->EWJ_ID)
                     EWP->(DbSeek(xFilial()+EWJ->EWJ_ID+EWK->EWK_SEQRE))
                     
                     While EWP->(!Eof() .And. EWP_FILIAL+EWP_ID+EWP_SEQRE == xFilial()+EWJ->EWJ_ID+EWK->EWK_SEQRE)
                           If EE9->(DbSeek(xFilial()+EWJ->EWJ_PREEMB+EWP->EWP_SEQEMB)) .And. EE9->(EE9_ID+EE9_SEQRE) == EWK->(EWK_ID+EWK_SEQRE)
                              If EE9->(RecLock("EE9", .F.))
                                 EE9->EE9_ID    := ""
                                 EE9->EE9_SEQRE := ""
                                 If EWJ->(FieldPos("EWJ_TIPO")) == 0 .Or. EWJ->EWJ_TIPO = "I" .Or. Empty(EWJ->EWJ_TIPO)//WFS 29/11/13 - Manter os dados da última integração, caso o arquivo de lote da alteração tenha sido cancelado sem que o envio tenha sido realizado 
                                 	EE9->EE9_RE    := ""
                                 	EE9->EE9_DTRE  := CToD("  /  /  ")
                                 EndIf
                                 EE9->(MsUnlock())
                              EndIf
                           EndIf
                           EWP->(DbSkip())
                     EndDo
                     
                    EWK->(DbSkip())
               EndDo

               If EEC->(DbSeek(xFilial()+EWJ->EWJ_PREEMB))
                  EEC->(RecLock("EEC",.F.))
                  
                  If EWJ->(FieldPos("EWJ_TIPO")) == 0 .Or. EWJ->EWJ_TIPO = "I" .Or. Empty(EWJ->EWJ_TIPO)//WFS 29/11/13 - Manter os dados da última integração, caso o arquivo de lote da alteração tenha sido cancelado sem que o envio tenha sido realizado
                  	 EEC->EEC_STASIS := SI_LS //Aguardando envio para siscomex
                  Else
                     EEC->EEC_STASIS := SI_SF  //Quando o arquivo da alteração for cancelado sem envio, volta o status para finalizado, para que na próxima geração de arquivo seja respeitado o agrupamento de RE
                  EndIf                  
                  EEC->(MsUnlock())
               EndIf
            
            EndIf
         EndIf
         
      EndIf
      
   EndIf

End Sequence   

Return Nil

Method VisEmbarque(cWork) Class EECINTSIS
Local cSrvSel := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)
Local cPreemb := Space(AvSX3("EEC_PREEMB",3))

Begin Sequence
   
   If Select(cWork) == 0 .Or. IsVazio(cWork)
      MsgInfo("Não existem processos para visualizar.", "Aviso")
      Break
   EndIf
   
   EEC->(DbSetOrder(1))
   
   If cSrvSel == "DE"
      cPreemb := EI300Lotes( (cWork)->EWJ_ID )
      If !Empty(cPreemb)
         If EEC->(DbSeek(xFilial()+AvKey(cPreemb,"EEC_PREEMB") ))
            EECAE100(EEC->(Recno()), VISUALIZAR)
         Else
            MsgInfo("Processo não encontrado.", "Aviso")
         EndIf
      EndIf  
   
   Else            
      If EEC->(DbSeek(xFilial()+(cWork)->EWJ_PREEMB))
         EECAE100(EEC->(Recno()), VISUALIZAR)
      Else
         MsgInfo("Processo não encontrado.", "Aviso")
      EndIf
   EndIf

End Sequence

Return Nil

Function EI300TelaL(oDlg, cLote)
Local oGet

      @ 20, 10 Say "O número de controle do Lote é exibido após o envio do arquivo, conforme destacado na imagem abaixo:" Of oDlg Pixel
      @ 32, 10 Say "Copie este número no campo ao lado para relacioná-lo ao arquivo:" Of oDlg Pixel
      @ 31, 180 Get oGet Var cLote Size 50,8 Of oDlg Pixel
      @ 052, 18 BitMap ResName "AVG_ENVRE2" Size 599, 151 NoBorder Of oDlg Pixel

Return oGet

Method GerNewRE() Class EECINTSIS                                               	
Local cErros     := ""
Local cSrvSel    := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)
Local hFile
Local cWKCarga1, cWKCarga2, aSemSx3
Local nRecAntes
Local nRecIndex
Private cIDBkp   // RMD - 23/11/2012 - Declarado variavel com o objetivo de armazenar a numeração gerada para que a mesma não seja alterada por programas abaixo do EECSI100 e/ou pontos de entradas.
Private cID
Private cTipoArq	:= "I" //wfs - 29/11/13 - Tipo de arquivo: Inclusão ou Alteração. Quando Alteração, a variável será atualizada EECSI101 
Private nVia		:= 0
Private lReOK		:= .F.
Private lRelXML	:= .F.
Private lNfeObrigat 
Private aProcRec := {}


Begin Sequence

   If Right(AllTrim(Self:cSrvAtu), 1) <> NAO_ENVIADO 
      MsgInfo("Selecione a pasta 'Itens não Enviados' para gerar um novo lote.", "Aviso")
      Break
   EndIf
      
   If cSrvSel == "DE"
      //Begin Transaction
      cID := Self:GetNewID("DE")         
      //Grava Informações do arquivo
      EWJ->(RecLock("EWJ", .T.))
      EWJ->EWJ_FILIAL	:= xFilial("EWJ")
      EWJ->EWJ_STATUS	:= NAO_ENVIADO
      EWJ->EWJ_ID		:= cID
      EWJ->EWJ_ARQENV	:= cId + EXT_XML
      EWJ->EWJ_DATAG	:= dDataBase
      EWJ->EWJ_HORAG	:= Time()
      EWJ->EWJ_USERG	:= cUserName
      EWJ->EWJ_SERVIC	:= cSrvSel
      If EWJ->(FieldPos("EWJ_TIPO")) > 0
         EWJ->EWJ_TIPO := cTipoArq
      EndIf
      EWJ->(MsUnlock())
      //End Transaction
      If !Si400TelaGets(cSrvSel)
         //Begin Transaction
         EEX->(DbSetOrder(4)) //EEX_FILIAL+EEX_ID
         EEZ->(DbSetOrder(3)) //EEZ_FILIAL+EEZ_PREEMB+EEZ_ID
         EWY->(DbSetOrder(1)) //EWY_FILIAL + EWY_ID + EWY_PREEMB + EWY_SEQ_RE
         lDelEEX := EEX->(DbSeek(xFilial("EEX")+EWJ->EWJ_ID))
         lDelEEZ := EEZ->(DbSeek(xFilial("EEX")+EEX->EEX_PREEMB+EEX->EEX_ID))
         lDelEWY := EWY->(DbSeek(xFilial("EEX")+EWJ->EWJ_ID))
         
         If lDelEEZ
            Do While EEZ->(!Eof()) .And. EEZ->EEZ_PREEMB == EEX->EEX_PREEMB;
                                   .And. EEZ->EEZ_ID == EEX->EEX_ID
                  RecLock("EEZ", .F.)
                  EEZ->(dbDelete())
                  EEZ->(MsUnlock())
                  EEZ->(DbSkip())
            EndDo
         EndIf
         If lDelEWY
            Do While EWY->(!Eof()) .And. EWY->EWY_PREEMB == EEX->EEX_PREEMB;
                                   .And. EWY->EWY_ID == EEX->EEX_ID
                  RecLock("EWY", .F.)
                  EWY->(dbDelete())
                  EWY->(MsUnlock())
                  EWY->(DbSkip())
            EndDo
         EndIf
         If lDelEEX
            RecLock("EEX", .F.)
            EEX->(dbDelete())
            EEX->(MsUnlock())
         EndIf
         
         RecLock("EWJ",.F.)
         EWJ->(dbDelete())
         EWJ->(DbSkip())   
         //End Transaction
         Break
      Else
         //Gera XML DE-Web
         If !lIsDir(EasyGParam("MV_AVG0135",,"\comex\easylink\xml"))
            SetMv("MV_AVG0135","\comex\easylink\xml")
         EndIf
         If !File("\comex\easylink\siscomex\dde\naoenviados")
            CriaDirEasyLink()
         EndIf
         EEX->(DbSetOrder(4))
         EEZ->(DbSetOrder(3))
         EWY->(DbSetOrder(1))
         aSemSx3	:= {}
         AADD(aSemSx3,{"WKESP" , AvSx3("EEX_ESP1" , AV_TIPO), AvSx3("EEX_ESP1" , AV_TAMANHO), AvSx3("EEX_ESP1" , AV_DECIMAL)})//1
         AADD(aSemSx3,{"WKEMB" , AvSx3("EEX_EMB1" , AV_TIPO), AvSx3("EEX_EMB1" , AV_TAMANHO), AvSx3("EEX_EMB1" , AV_DECIMAL)})//2
         AADD(aSemSx3,{"WKQTD" , AvSx3("EEX_QTD1" , AV_TIPO), AvSx3("EEX_QTD1" , AV_TAMANHO), AvSx3("EEX_QTD1" , AV_DECIMAL)})//3
         AADD(aSemSx3,{"WKMARK", AvSx3("EEX_MARK1", AV_TIPO), AvSx3("EEX_MARK1", AV_TAMANHO), AvSx3("EEX_MARK1", AV_DECIMAL)})//4
         AADD(aSemSx3,{"WKPESB", AvSx3("EEX_PESB1", AV_TIPO), AvSx3("EEX_PESB1", AV_TAMANHO), AvSx3("EEX_PESB1", AV_DECIMAL)})//5
         AADD(aSemSx3,{"WKRECNO" ,"N",15,0})
         
         cWKCarga1:=E_CriaTrab(,aSemSx3,"WCarga1")
         //MFR 18/12/2018 OSSME-1974
         IndRegua("WCarga1",cWKCarga1+TeOrdBagExt(),"WKRECNO")
         cWKCarga2:=E_CriaTrab(,aSemSx3,"WCarga2")
         IndRegua("WCarga2",cWKCarga2+TeOrdBagExt(),"WKRECNO")
         
         If FindFunction("H_DDE_ADC")
            hFile := EasyCreateFile(Self:cDEDirNotSent + cId + EXT_XML, FC_READONLY)
            cBuffer := XML_UTF_8
            cBuffer += '<lote idArquivo="'+ EWJ->EWJ_ID + XML_STYLE_DE
            If EEX->(DbSeek(xFilial("EEX")+ EWJ->EWJ_ID))
               Do While EEX->(!Eof()) .And. EEX->EEX_ID == EWJ->EWJ_ID
                  
                  Si400Cargas()//CARREGA AS WORKS DE CARGA PARA GERAR AS TAGS NO XML
                  //LGS-08/01/2016 - Utilizado para montar a TAG <obrigatoria> ou <dispensada> no aph
                  lNfeObrigat := EEZ->(DbSeek(xFilial("EEZ")+EEX->(EEX_PREEMB+EEX_ID)))
                  EWY->(DbSeek(xFilial("EWJ")+EEX->(EEX_ID+EEX_PREEMB))) 
                  cBuffer += H_DDE_ADC()
                  EEX->(DbSkip())
               EndDo
            EndIf
            cBuffer += '</lote>'
         Else
            MsgInfo("Função H_DDE_ADC não encontrado no repositorio de objetos do sistema","Atenção")
            Break
         EndIf
         
         cBuffer := EncodeUTF8(cBuffer)
         cBuffer := StrTran(cBuffer,"&","e")
         cBuffer := StrTran(cBuffer,"	","")
         cBuffer := StrTran(cBuffer, CHR(13)+CHR(10) ,"")
         cBuffer := StrTran(cBuffer, '#ENTER#', CHR(13)+CHR(10))
         
         If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
            MsgInfo("arquivo não pode ser gravado.","Atenção")
            FErase(Self:cDEDirNotSent + Self:cIdAtu + EXT_XML)
            cId := ""
            Break
         EndIf
         
         If SELECT("WCarga1") # 0
            WCarga1->(E_ERASEARQ(cWKCarga1))
         EndIf
         If SELECT("WCarga2") # 0
            WCarga2->(E_ERASEARQ(cWKCarga2))
         EndIf
         
         FClose(hFile)
      EndIf
      
   Else //cSrvSel == "RE"
      Begin Transaction
         //Executa agrupamentos
         cID := Self:GetNewID("RE")//Qdo é RE o campo EWJ_SERVIC é gravado vazio com tamanho 2, '  '
         cIDBkp := cID    // RMD - 23/11/2012
         
         EECSI100(2, cID)
         cID := cIDBkp    // RMD - 23/11/2012
         
         If !lReOK
            DisarmTransaction()
         EndIf
        
        // Alterando o status siscomex para Aguardando liberacao para siscomex. EJA - 27/11/2017
         nRecAntes := EEC->(Recno())
         For nRecIndex := 1 To Len(aProcRec)
            EEC->(DbGoTo(aProcRec[nRecIndex]))
            EEC->(RecLock("EEC", .F.))
            EEC->EEC_STASIS := SI_AS
            EEC->EEC_LIBSIS := cToD("  /  /  ")
            EEC->(MsUnlock())
         Next
         EEC->(DbGoTo(nRecAntes))

         If !lReOK
            Break
         EndIf
         
         ConfirmSX8()
         // BAK - Funções retiradas do UENOVOEX - 08/11/2011
         AtuEasyLink()
         If EED->(FieldPos("EED_CODVIN")) > 0 // Verificando se a carga do campo EED_CODVIN da tabela EED foi realizada
            EED->(DBSetOrder(1))
            If EED->(DBSeek(xFilial("EED") + AvKey("80117", "EED_ENQCOD"))) .And. Empty(EED->EED_CODVIN)
               AtuEED()
            EndIf
         EndIf
         
         If !lIsDir(EasyGParam("MV_AVG0135",,"\comex\easylink\xml"))
            SetMv("MV_AVG0135","\comex\easylink\xml")
         EndIf
         cFile := EasyGParam("MV_AVG0135",,"\comex\easylink\xml") + "\" + "novoex_novo_re.xml"
         
         //LGS-06/11/2014 - Retirado validação para força a criação do arquivo sempre atualizado na pasta.
         //If !File(cFile) .Or. AtualXMLEasyLink(cFile) //Verifica se o arquivo existe ou deve ser atualizado
            CriaXMLEasyLink(cFile)
         //EndIf
         If !File("\comex\easylink\siscomex\re\naoenviados")
            CriaDirEasyLink()
         EndIf
         
         //Grava XML
         If !AvStAction("100",,, @cErros)
            cErros := "Não foi possível gerar o arquivo de integração." + ENTER +;
                      "Verifique abaixo as mensagens encontradas na execução do serviço:" + ENTER +;
                      cErros
            EECView(cErros, "Atenção")
            DisarmTransaction()
         Else
            //Grava Informações do arquivo
            EWJ->(RecLock("EWJ", .T.))
            EWJ->EWJ_FILIAL	:= xFilial("EWJ")
            EWJ->EWJ_STATUS	:= NAO_ENVIADO
            EWJ->EWJ_ID		:= cID
            EWJ->EWJ_ARQENV	:= cId + EXT_XML
            EWJ->EWJ_PREEMB	:= Posicione("EWK", 1, xFilial("EWK")+cId, "EWK_PREEMB")
            EWJ->EWJ_DATAG		:= dDataBase
            EWJ->EWJ_HORAG		:= Time()
            EWJ->EWJ_USERG		:= cUserName
            If EWJ->(Fieldpos("EWJ_SERVIC"))>0
               EWJ->EWJ_SERVIC	:= Space(AvSX3("EWJ_SERVIC",3)) //LGS-28/05/2015
            EndIf
            If EWJ->(FieldPos("EWJ_TIPO")) > 0
               EWJ->EWJ_TIPO := cTipoArq
            EndIf
            EWJ->(MsUnlock())
            //OAP - Gravação do campo Memo
            MsMM(,AVSX3("EWJ_ERROS",3),,cErrosNEX,1,,,"EWJ","EWJ_CODERR") //Inclusão
         EndIf
      End Transaction
   EndIf
End Sequence
//cErrosNEX := cMsgAux
Return Nil

Method GetNewId(cServ) Class EECINTSIS                  
Local cID := ""
Local nRec, nPos, aFiliais := {}, aEWJ := {RetSQLName("EWJ")}, i
Default cServ := "RE"

   If cServ == "DE"
      cID := GetSXENum("EEX", "EEX_ID")
   Else
      cID := GetSXENum("EWJ", "EWJ_ID")
   EndIf 

    aFiliais := FWAllGrpCompany()

    //THTS - 01/08/2018
    For i := 1 To Len(aFiliais)
        If aScan(aEWJ, {|X| AllTrim(Upper(X)) == AllTrim(Upper(RetFullName("EWJ", aFiliais[i]))) }) == 0 .AND. MsFile(Alltrim(RetFullName("EWJ", aFiliais[i])))
            aAdd(aEWJ, RetFullName("EWJ", aFiliais[i]))
        EndIf
    Next

   For i := 1 To Len(aEWJ)
      If EWJ->(FieldPos("EWJ_SERVIC"))>0
         If cServ == "RE"
            cQry:=ChangeQuery("Select Max(EWJ_ID) ID FROM "+aEWJ[i]+" where EWJ_SERVIC = '  ' AND D_E_L_E_T_ = ' '")
         Else
            cQry:=ChangeQuery("Select Max(EWJ_ID) ID FROM "+aEWJ[i]+" where EWJ_SERVIC = 'DE' AND D_E_L_E_T_ = ' '")
         EndIf
      Else
         cQry:=ChangeQuery("Select Max(EWJ_ID) ID FROM "+aEWJ[i]+" where D_E_L_E_T_ = ' '")
      EndIf
   
      If Select("WKID") > 0
         WKID->(dbCloseArea())
      EndIf
   
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WKID", .F., .T.)
      cID := If(Val(WKID->ID) >= Val(cID),StrZero(Val(WKID->ID)+1,AvSx3("EWJ_ID", AV_TAMANHO)),cID)
   
      WKID->(dbCloseArea())
   Next i 
   
   /*
   EWJ->(DbSetOrder(1))
   While EWJ->(DbSeek(xFilial()+cId))
      cId := Self:GetNewId()
   EndDo
   */
   
Return cID

Method EditConfigs() Class EECINTSIS
Local cSrvSel := SubStr(Right(AllTrim(Self:cSrvAtu), 3),1,2)
Local nLin    := 15, nCol := 12
Local lRet    := .F.
Local bOk     := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cTitulo := "Configurações para o usuário: " + cUserName
Local cDirRec := ""
Local cDirEnv := ""
Local bSetFileRec
Local bSetFileEnv

   //SetKey(VK_F3, bChooseFile)
   If cSrvSel == "DE"
      cDirRec := Self:oUserParams:LoadParam("DEDIRLOCAL", "c:\LOTES_DE\")
      cDirEnv := Self:oUserParams:LoadParam("DEDIRTEMP",  "%TEMP%")
   Else
      cDirRec := Self:oUserParams:LoadParam("DIRLOCAL", "c:\LOTES\")
      cDirEnv := Self:oUserParams:LoadParam("DIRTEMP",  "%TEMP%")
   EndIf
   
   bSetFileRec := {|| cDirRec := cGetFile("","Diretório local para importação de arquivos de lote", 0, cDirRec,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }
   bSetFileEnv := {|| cDirEnv := cGetFile("","Diretório temporário para envio de arquivos de lote", 0, cDirEnv,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }
   cDirRec := cDirRec + Space( 40 - Len(cDirRec) ) 
   cDirEnv := cDirEnv + Space( 40 - Len(cDirEnv) )

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 260,400 TO 500,785 OF oMainWnd PIXEL

   	oPanel:= tPanel():New(01,01,"",oDlg,,,,,,100,100)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    @ nLin, 6 To 81, 181 Label "Preferências" OF oPanel PIXEL
    
    If cSrvSel <> "DE"
       nLin += 10
       @ nLin,nCol Say "Diretório local para importação de arquivos" Size 160,08 OF oPanel PIXEL
       nLin += 10
       @ nLin,nCol MsGet cDirRec Size 150,08 OF oPanel PIXEL
       @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileRec) SIZE 10,10 OF oPanel PIXEL
    EndIf
		
	
	//DFS - 18/01/11 - Inclusão de botão para salvar o envio de arquivos em diretório selecionado
    nLin += 20
    @ nLin,nCol Say "Diretório temporário para envio de arquivos" Size 160,08 OF oPanel PIXEL
    nLin += 10
    @ nLin,nCol MsGet cDirEnv Size 150,08 OF oPanel PIXEL
    @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileEnv) SIZE 10,10 OF oPanel PIXEL
	

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   //SetKey(VK_F3, Nil)   

   If lRet
      If cSrvSel == "DE"
         Self:oUserParams:SetParam("DEDIRLOCAL", cDirRec)
         Self:oUserParams:SetParam("DEDIRTEMP", cDirENV) //DFS - 18/01/11 - Criado parâmetro interno "DIRTEMP" para guardar este parâmetro. O valor default é %TEMP%
         Self:cDETempDir	:= SetTempDir(cDirENV,"DE") //DFS - 18/01/11 - Alterado o conteúdo do atributo cTempDir
      Else
         Self:oUserParams:SetParam("DIRLOCAL", cDirRec)
         Self:oUserParams:SetParam("DIRTEMP", cDirENV) //DFS - 18/01/11 - Criado parâmetro interno "DIRTEMP" para guardar este parâmetro. O valor default é %TEMP%
         Self:cTempDir		:= SetTempDir(cDirENV,"RE") //DFS - 18/01/11 - Alterado o conteúdo do atributo cTempDir
      EndIf
   EndIf

Return Nil

Method Imprimir() Class EECINTSIS
//Obtem o número do RE a partir do registro posicionado no browse inferior.
Local cRE          := Left(EWK->EWK_NRORE, 7)
Local cErros       := ""
Local cNomeXsl     := "Rel_Impressao_RE"
Private lRelXML    := .T. 
Private cID        := Self:cIdAtu
Private nVlrVenda  := 0
Private nLocEmbar  := 0
Private nQtdMedCom := 0
Private nQtdMedEst := 0
Private nQtdkgLiq  := 0
Private cTipoArq   := "I"

Begin Sequence

   //Valida se houve número de RE retornado.
   If Empty(cRE)
      MsgInfo("Registro de Exportação não gerado para esta solicitação.", "Aviso")
      Break
   EndIf

   //Filtra a tabela EWK pelo número do RE.
   cFilter := "SubStr(EWK->EWK_NRORE, 1, 7) == cRE"
   EWK->(DbSetFilter(&("{|| " + cFilter + "}"), cFilter))
   
   //Gera o XML a ser visualizado.
   If !AvStAction("100",,, @cErros)
      cErros := "Não foi possível gerar o arquivo de impressão." + ENTER +;
                "Verifique abaixo as mensagens encontradas na execução do serviço:" + ENTER +;
                cErros
      EECView(cErros, "Atenção")
      Break
   EndIf

   //Checa a pasta temporária e cria se necessário
   If !Self:SetTemp()
      Break
   EndIf
   
   //Gera o XSL.
   If !GeraRelXsl(Self:cDirRec + cNomeXsl + EXT_XSL)
      cErros := "Não foi possível gerar o arquivo de xsl."
      EECView(cErros, "Atenção")
      Break
   EndIf

   //Define o nome do arquivo XSL no diretório temporário
   Self:cFileTemp := Self:cTempDir + cNomeXsl + EXT_XSL
   
   //Apaga o arquivo XSL existente no diretório Temporario
   Self:ClearTemp() 
   
   //Copia do Servidor para o diretório temporário
   Self:CopyLote2T(Self:cDirRec + cNomeXsl + EXT_XSL)  

   //Define o nome do arquivo XML no diretório temporário
   Self:cFileTemp  := Self:cTempDir + Self:cIdAtu + EXT_XML 
   
   //Apaga o arquivo XML existente no diretório Temporario
   Self:ClearTemp()
   
   //Copia do Servidor para o diretório temporário
   Self:CopyLote2T(Self:cDirRel + Self:cIdAtu + EXT_XML)      
   
   //Executa o browser para visualizar o XML
   If ShellExecute("open", Self:cFileTemp, "", "", 1) <= 32
      MsgInfo("Erro na exibição do arquivo.", "Aviso")
   EndIf
   
   //Apagar o arquivo da pasta relatório
   Self:cFileTemp := Self:cDirRec + cNomeXsl + EXT_XSL

   //Apaga o arquivo XSL existente no diretório Temporario
   Self:ClearTemp()
   
   Self:cFileTemp := Self:cDirRel + Self:cIdAtu + EXT_XML
   //Apaga o arquivo XML existente no diretório Temporario
   Self:ClearTemp()
  
   //Limpa o filtro.   
   EWK->(DbClearFilter())

End Sequence

Return Nil

Static Function GeraRelXSL(cDirArq)
Local lRet := .T.
Local cArqXML:= ""

Begin Sequence

   cArqXml  := CarregaXsl(SubStr(cDirArq,Rat("\",cDirArq)+1,Len(cDirArq)))

   If Empty(cArqXml)
      lRet:= .F.
      Break
   EndIF   

   nHandler := EasyCreateFile(cDirArq)
   FWrite(nHandler,cArqXml)
   FClose(nHandler)

End Sequence

Return lRet

Static Function CarregaXsl(cNomeArq)
Local cXSL := ""

Begin Sequence
   
   Do Case
      Case cNomeArq $ "Rel_Impressao_RE.xsl"
               cXSL += "<?xml version='1.0' encoding='ISO-8859-1' ?>"+CHR(13)+CHR(10)
         cXSL += "<xsl:stylesheet version = " + Chr(34) + "2.0" + Chr(34) + " xmlns:xsl = " + Chr(34) + "http://www.w3.org/1999/XSL/Transform" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<xsl:template match = " + Chr(34) + "/" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "<html>"+CHR(13)+CHR(10)
         cXSL += "<STYLE Type=" + Chr(34) + "Text/css" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += ".folha{"+CHR(13)+CHR(10)
         cXSL += "page-break-after:always;"+CHR(13)+CHR(10)
         cXSL += "}"+CHR(13)+CHR(10)
         cXSL += "</STYLE>"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "<body>"+CHR(13)+CHR(10)
         cXSL += "<div class=" + Chr(34) + "folha" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<table width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "1" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "center" + Chr(34) + "><h2>Impressão de Registro de Exportação</h2></div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<hr noshade=" + Chr(34) + "noshade" + Chr(34) + " color=" + Chr(34) + "gray" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " align=" + Chr(34) + "left" + Chr(34) + " size=" + Chr(34) + "5" + Chr(34) + " />"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "180" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número do RE:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "506" + Chr(34) + " ><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/numero-re" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">CNPJ/CPF do Exportador:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/cpf-cnpj-exportador" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Nome do Exportador:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/nome-exportador" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Situação atual do RE:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/status-re" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Data do Registro de RE:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/data-hora-re" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<br />"+CHR(13)+CHR(10)
         cXSL += "<table  style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " height=" + Chr(34) + "35" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "959" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Operação com Cobertura Cambial?</div></th>"+CHR(13)+CHR(10)
         cXSL += "<xsl:if test=" + Chr(34) + "lote/registro-exportacao/re-base/valor-com-cobertura != 0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "123" + Chr(34) + ">SIM</td>"+CHR(13)+CHR(10)
         cXSL += "</xsl:if>"+CHR(13)+CHR(10)
         cXSL += "<xsl:if test=" + Chr(34) + "lote/registro-exportacao/re-base/valor-com-cobertura = 0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "123" + Chr(34) + ">NAO</td>"+CHR(13)+CHR(10)
         cXSL += "</xsl:if>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Enquadramentos da Operação</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<xsl:for-each select = " + Chr(34) + "lote/registro-exportacao[1]/enquadramento" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "180" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "codigo-enquadramento" + Chr(34) + "/></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "506" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-enquadramento" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</xsl:for-each>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<br />"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "283" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "> Data Limite:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "799" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/data-limite" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">% da Margem Não Sacada:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/percentual-margem-nao-sacada" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número do Processo:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/numero-processo" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Vinculações</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "283" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número do RC:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "799" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/rc-vinculado" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número do RV:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/rv-vinculado" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número do RE Vinculado:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/re-vinculado" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Número da DI Vinculado:</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/di-vinculado" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "</div>"+CHR(13)+CHR(10)
         cXSL += "<div class=" + Chr(34) + "folha" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<h2>Dados Gerais</h2>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Dados do Importador</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<p>Nome do Importador</p>"+CHR(13)+CHR(10)
         cXSL += "</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/nome-importador" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<p>Endereço do Importador</p>"+CHR(13)+CHR(10)
         cXSL += "</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/endereco-importador" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<p>País do Importador</p>"+CHR(13)+CHR(10)
         cXSL += "</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/pais-importador" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-pais-importador" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Dados da Operação de Exportação</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">País de Destino Final</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/pais-destino" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-pais-destino" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Instrumento de Negociação</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/instrumento-comercial/codigo-instrumento" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/instrumento-comercial/descricao-codigo-instrumento" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Unidade RF de Despacho</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/orgao-rf-despacho" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-orgao-rf-despacho" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Unidade RF de Embarque</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/orgao-rf-embarque" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-orgao-rf-embarque" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Condição de Venda</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/condicao-venda" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-condicao-venda" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Modalidade de Pagamento</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/modalidade-pagamento" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-modalidade-pagamento" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Moeda</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/moeda" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/descricao-moeda" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor da Margem Não Sacada</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/re-base/valor-margem-nao-sacada" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor do Financiamento</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/valor-financiamento" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor com Cobertura</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/re-base/valor-com-cobertura" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor sem Cobertura Cambial</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "lote/registro-exportacao/re-base/valor-sem-cobertura" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor Em Consignação</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select=" + Chr(34) + "lote/registro-exportacao/re-base/valor-consignacao" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Valor Total da Operação</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select=" + Chr(34) + "lote/registro-exportacao/re-base/valor-total-operacao" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "</div>"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "<xsl:for-each select = " + Chr(34) + "lote/registro-exportacao" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<div class=" + Chr(34) + "folha" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<h2><div align=" + Chr(34) + "left" + Chr(34) + ">Dados da Mercadoria - Anexo: <xsl:value-of select=" + Chr(34) + "anexo-re" + Chr(34) + "/></div></h2>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Mercadoria</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "951" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">O exportador é o único fabricante?</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "131" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-condicao-fabricante" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Mercadoria</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "mercadoria-destaque" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Descrição</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-mercadoria-destaque" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>  <tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Naladi</div></th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "naladi" + Chr(34) + "/> - <xsl:value-of select = " + Chr(34) + "descricao-naladi" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "center" + Chr(34) + "><i>Complemento do Registro de Exportação</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "951" + Chr(34) + " height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Prazo de Pagamento (Em Dias)</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "131" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "prazo-pagamento" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "Center" + Chr(34) + "><i>Itens de Mercadoria</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "7%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Código</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "20%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Descrição</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "15%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Valor Condição de Venda</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "15%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Valor Local Embarque</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "14%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Qt. Unid. Comercializa</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "14%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Qtd. Und. Estatística</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "15%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Qtd. Peso Líquido</th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<table width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<xsl:for-each select = " + Chr(34) + "item-mercadoria" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "7%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "seq-item-re" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "20%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "15%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-condicao-venda" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "15%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-local-embarque" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "14%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "quantidade-comercializada" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "14%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "quantidade-estatistica" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "15%" + Chr(34) + " align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "numero-peso-liquido" + Chr(34) + "/></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</xsl:for-each>"+CHR(13)+CHR(10)
         cXSL += "<hr noshade=" + Chr(34) + "noshade" + Chr(34) + " color=" + Chr(34) + "black" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " align=" + Chr(34) + "left" + Chr(34) + " size=" + Chr(34) + "1" + Chr(34) + " />"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "Center" + Chr(34) + "><i>Dados Consolidados de Itens de Mercadoria</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "26%" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "></th>"+CHR(13)+CHR(10)
         cXSL += "<td colspan=" + Chr(34) + "2" + Chr(34) + " bgcolor=" + Chr(34) + "#CCCCCC" + Chr(34) + " ><div align=" + Chr(34) + "center" + Chr(34) + "><strong>Valor</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th scope=" + Chr(34) + "row" + Chr(34) + "></th>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "44%" + Chr(34) + "><div align=" + Chr(34) + "right" + Chr(34) + "><strong>Na Condição de Venda</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td width=" + Chr(34) + "30%" + Chr(34) + "><div align=" + Chr(34) + "right" + Chr(34) + "><strong>No Local de Embarque</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "right" + Chr(34) + ">Preço Total</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-consolidado-condicao-venda-rel" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-consolidado-local-embarque-rel" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th scope=" + Chr(34) + "row" + Chr(34) + "></th>"+CHR(13)+CHR(10)
         cXSL += "<td colspan=" + Chr(34) + "2" + Chr(34) + " bgcolor=" + Chr(34) + "#CCCCCC" + Chr(34) + "><div align=" + Chr(34) + "center" + Chr(34) + "><strong>Mercadoria</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th scope=" + Chr(34) + "row" + Chr(34) + "></th>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><strong>Quantidade</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><strong>Unidade</strong></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Un. Medida na Comercialização</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-consolidado-qtd-comercializada-rel" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-unidade-medida-comercial" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Un. Medida Estatística</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-consolidado-qtd-estatistica-rel" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-unidade-medida-estatistica" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th height=" + Chr(34) + "34" + Chr(34) + " scope=" + Chr(34) + "row" + Chr(34) + "><div align=" + Chr(34) + "left" + Chr(34) + ">Quilograma Líquido</div></th>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-consolidado-peso-liquido-rel" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "right" + Chr(34) + ">QUILOGRAMA</div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "Center" + Chr(34) + "><i>Comissao do Agente</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "26%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Percentual (%)</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "23%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Valor</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "51%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Forma de Pagamento</th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "percentual-comissao-agente" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-comissao-agente" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "descricao-tipo-comissao" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "</div>"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "<div class=" + Chr(34) + "folha" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "Center" + Chr(34) + "><i>Drawback</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "14%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">CNPJ/CPF</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "9%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">NCM</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "18%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Ato Concessório</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "13%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Item</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "14%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Qtd.</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "16%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Valor c/ Cob. Cambial</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "16%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Valor s/ Cob. Cambial</th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<xsl:for-each select = " + Chr(34) + "drawback" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "cnpj" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "ncm" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "ato-concessorio" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "item-ato-concessorio" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "quantidade" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "vl-moeda-re-com-cobertura-cambial" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "vl-moeda-re-sem-cobertura-cambial" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</xsl:for-each>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "<h3 align=" + Chr(34) + "Center" + Chr(34) + "><i>Dados do Fabricante</i></h3>"+CHR(13)+CHR(10)
         cXSL += "<table style=" + Chr(34) + "border-style:solid;border-color:black;border-width:thin" + Chr(34) + " width=" + Chr(34) + "100%" + Chr(34) + " border=" + Chr(34) + "0" + Chr(34) + " cellspacing=" + Chr(34) + "0" + Chr(34) + " cellpadding=" + Chr(34) + "0" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "14%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">CNPJ/CPF</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "5%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">UF</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "16%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Quantidade</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "25%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Peso Líquido (Kg)</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "23%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Vl Moeda RE Local Embarque</th>"+CHR(13)+CHR(10)
         cXSL += "<th width=" + Chr(34) + "17%" + Chr(34) + " scope=" + Chr(34) + "col" + Chr(34) + ">Observação</th>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "<xsl:for-each select = " + Chr(34) + "fabricante" + Chr(34) + ">"+CHR(13)+CHR(10)
         cXSL += "<tr>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "cpf-cnpj" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "sigla-uf-fabric" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "qtd-estatistica-fabric" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "peso-liquido-fabric" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "valor-moeda-local-embarque" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "<td><div align=" + Chr(34) + "center" + Chr(34) + "><xsl:value-of select = " + Chr(34) + "obs-fabric" + Chr(34) + "/></div></td>"+CHR(13)+CHR(10)
         cXSL += "</tr>"+CHR(13)+CHR(10)
         cXSL += "</xsl:for-each>"+CHR(13)+CHR(10)
         cXSL += "</table>"+CHR(13)+CHR(10)
         cXSL += "</div>"+CHR(13)+CHR(10)
         cXSL += "</xsl:for-each>"+CHR(13)+CHR(10)
         cXSL += ""+CHR(13)+CHR(10)
         cXSL += "</body>"+CHR(13)+CHR(10)
         cXSL += "</html>"+CHR(13)+CHR(10)
         cXSL += "</xsl:template>"+CHR(13)+CHR(10)
         cXSL += "</xsl:stylesheet>"+CHR(13)+CHR(10)

   End Case

End Sequence

Return cXSL
/* 
==================================================================================================================
Função     : EI300VisDet
Parametros :
Objetivo   : Apresentar em forma organizada em Folders todas as informações sobre Mercadorias,Fabricantes e DrawBack
*            dos anexos da RE
Autor      : Clayton Fernandes
Data       : 07/01/2011
==================================================================================================================
*/
Function EI300VisDet()
Local aNomeFolders  := {"Mercadorias","Fabricantes","DrawBack"}
Local aPosTela  := {}
Local oDlg
Local oFld
Local oEnch
Local oMsSelMer
Local oMsSelFab
Local oMsSelDrB
Local cAliasOld := Alias()
Local cCpoCapa  := ""
Local cCpoDet   := ""
Local cAliasWK	:= ""
Local lDEWeb	:= If(cAliasOld == "EEX", .T., .F.)
Local i
PRIVATE lInvert := .F.

   DEFINE MSDIALOG oDlg TITLE "Detalhes do item" FROM 0,0;
                                                 TO DLG_LIN_FIM*0.9, DLG_COL_FIM*0.7;
                                                 OF oMainWnd PIXEL
   aPosTelaUp  := PosDlgUp(oDlg)
   aPosTelaDown:= POsDlgDown(oDlg)
   If lDEWeb
      aEEX01	:= {}
      aNomeFolders := {"Notas Fiscais","RE do Lote"}
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EEX"))
      Do While SX3->(!Eof()) 
         If SX3->X3_ARQUIVO == "EEX" .And. Empty(SX3->X3_RELACAO) .And.;
                                          !Empty(SX3->X3_FOLDER) .And.;
                                           SX3->X3_CAMPO <> "EEX_CNPJ_R" 
            AAdd(aEEX01,Alltrim(SX3->X3_CAMPO))
         EndIf
         SX3->(DbSkip())
      EndDo
      oEnch := MsMGet():New("EEX", EEX->(Recno()), VISUALIZAR,,,,aEEX01, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
   Else
      oEnch := MsMGet():New("EWK", EWK->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
   EndIf
   oEnch:oBox:Align := CONTROL_ALIGN_TOP
   
   //Criação do Folder.
   oFld := TFolder():New(aPosTelaDown[1]+35,aPosTelaDown[2]-1,aNomeFolders,aNomeFolders,oDlg,,,,.T.,.F.,aPosTelaDown[4],aPosTelaDown[4]-260)
   oFld:Align := CONTROL_ALIGN_ALLCLIENT
   
   If !lDEWeb	   
	   aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
	   oFldMer   := oFld:aDialogs[1]
	   oFldFab   := oFld:aDialogs[2]
	   oFldDrB   := oFld:aDialogs[3]  
	   aPosTela  := PosDlg(oFldMer)
	  
	   // Filtro para exibição da msSelect para Mercadorias
	   cCpoCapa := "xFilial('EWL')+EWK->EWK_ID+EWK->EWK_SEQRE"
	   cCpoDet  := "EWL_FILIAL + EWL_ID + EWL_SEQRE"
	   oMsSelMer := MsSelect():New("EWL",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldMer)
	   oMsSelMer:oBrowse:Hide()
	   oMsSelMer:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	   oMsSelMer:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
	   oMsSelMer:bAval := {|| EWL->(If(Eval(oMsSelMer:oBrowse:bInRange),EI300EncVis("EWL"),))}
	   oMsSelMer:oBrowse:Refresh()
	   oMsSelMer:oBrowse:Show()
	  
	   // Filtro para exibição da msSelect para Fabricantes
	   cCpoCapa := "xFilial('EWO')+EWK->EWK_ID+EWK->EWK_SEQRE"
	   cCpoDet  := "EWO_FILIAL + EWO_ID + EWO_SEQRE"
	   oMsSelFab := MsSelect():New("EWO",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldFab)
	   oMsSelFab:oBrowse:Hide()
	   oMsSelFab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	   oMsSelFab:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
	   oMsSelFab:bAval := {|| EWO->(If(Eval(oMsSelFab:oBrowse:bInRange),EI300EncVis("EWO"),))}
	   oMsSelFab:oBrowse:Refresh()
	   oMsSelFab:oBrowse:Show()
	 
	   // Filtro para exibição da msSelect para DrawBack
	   cCpoCapa := "xFilial('EWM')+EWK->EWK_ID+EWK->EWK_SEQRE"
	   cCpoDet  := "EWM_FILIAL + EWM_ID + EWM_SEQRE"
	   oMsSelDrB := MsSelect():New("EWM",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDrB)
	   oMsSelDrB:oBrowse:Hide()
	   oMsSelDrb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	   oMsSelDrB:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
	   oMsSelDrB:bAval := {|| EWM->(If(Eval(oMsSelDrB:oBrowse:bInRange),EI300EncVis("EWM"),))}
	   oMsSelDrB:oBrowse:Refresh()
	   oMsSelDrB:oBrowse:Show()
   Else
      aEEZ01 := {}
      AADD(aEEZ01,{"EEZ_PREEMB",,AVSX3("EEZ_PREEMB",5),AVSX3("EEZ_PREEMB",6)})
      AADD(aEEZ01,{"EEZ_CNPJ"  ,,AVSX3("EEZ_CNPJ"  ,5),AVSX3("EEZ_CNPJ"  ,6)})
      AADD(aEEZ01,{"EEZ_NF"    ,,AVSX3("EEZ_NF"    ,5),AVSX3("EEZ_NF"    ,6)})
      AADD(aEEZ01,{"EEZ_SER"   ,,AVSX3("EEZ_SER"   ,5),AVSX3("EEZ_SER"   ,6)})
      AADD(aEEZ01,{"EEZ_CHVNFE",,AVSX3("EEZ_CHVNFE",5),AVSX3("EEZ_CHVNFE",6)})
      
      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
      oFldNF	:= oFld:aDialogs[1]
      oFldRE	:= oFld:aDialogs[2]
      aPosTela:= PosDlg(oFldNf)
      
      cCpoCapa := "xFilial('EEX')+EEX->EEX_PREEMB+EEX->EEX_ID
      cCpoDet  := "EEZ_FILIAL + EEZ_PREEMB + EEZ_ID"
      oMsSelNF := MsSelect():New("EEZ",,,aEEZ01,.F.,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldNF)
      oMsSelNF:oBrowse:Hide()
      oMsSelNF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelNF:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelNF:oBrowse:Refresh()
      oMsSelNF:oBrowse:Show()

      cCpoCapa := "xFilial('EEX')+EEX->EEX_ID+EEX->EEX_PREEMB"
      cCpoDet  := "EWY_FILIAL + EWY_ID + EWY_PREEMB"
      oMsSelRE := MsSelect():New("EWY",,,,.F.,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldRE)
      oMsSelRE:oBrowse:Hide()
      oMsSelRE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelRE:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelRE:oBrowse:Refresh()
      oMsSelRE:oBrowse:Show()
   EndIf
   

ACTIVATE MSDIALOG oDlg Centered

DbSelectArea(cAliasOld)


Return Nil

/* 
==================================================================================================================
Função     : EI300EncVis
Parametros : cAlias
Objetivo   : apresentação das informações em uma enchoice para Fabricante e Mercadoria e uma Enchoice com Select 
*            para DrawBack
Autor      : Clayton Fernandes
Data       : 07/01/2011
==================================================================================================================
*/
Function EI300EncVis(cAlias)
Local oDlg
Local cTitulo
Local aPosTelaUp
Local aPosTelaDown 
Local cCpoCapa
Local cCpoDet
Local oEnchoice   

      If cAlias == "EWM"
         cTitulo := "Detalhes do DrawBack"
      ElseIf cAlias == "EWO"
         cTitulo := "Detalhes do Fabricante"
      ElseIf cAlias == "EWL"
         cTitulo := "Detalhes da Mercadoria"
      Else
         cTitulo := "Detalhes das notas fiscais do DrawBack"
      EndIf   
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0;
                                                 TO DLG_LIN_FIM*0.7, DLG_COL_FIM*0.7;
                                                 OF oMainWnd PIXEL

      If cAlias == "EWM"
         aPosTelaUp  := PosDlgUp(oDlg)
         aPosTelaDown:= POsDlgDown(oDlg)
         oEnchoice := MsMGet():New(cAlias, (cAlias)->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2],aPosTelaUp[3],aPosTelaUp[4]})   
         oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT
         
         cCpoCapa := "xFilial('EWN')+EWM->EWM_ID+EWM->EWM_SEQRE"
         cCpoDet  := "EWN_FILIAL + EWN_ID + EWN_SEQRE"
         oMsSelDrB := MsSelect():New("EWN",,,,@lInvert,,aPosTelaDown,,,)
         oMsSelDrB:oBrowse:Hide()
         oMsSelDrB:bAval := {|| EWN->(If(Eval(oMsSelDrB:oBrowse):bInRange,EI300EncVis("EWN"),))}
         oMsSelDrB:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
         oMsSelDrB:oBrowse:Align := CONTROL_ALIGN_BOTTOM
         oMsSelDrB:oBrowse:Refresh()
         oMsSelDrB:oBrowse:Show()
      Else
         oEnchoice := MsMGet():New(cAlias, (cAlias)->(Recno()), VISUALIZAR,,,,, {1,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
         oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT
      EndIf


   ACTIVATE MSDIALOG oDLG Centered

Return Nil

Class EECSISSRV

	Data cTipo
	Data cName
	Data cAlias
	Data cAliasName
	Data cID
	Data cIconOpen
	Data cIconClose
	Data cAliasDet
	Data cDetName
	Data cRelIndex
	Data cRelKey
	Data cExecAc
	Data aFolders
	Data aActions

	Data aCampos
	Data nOrdem
	Data aCposDet   // GFP - 07/04/2015  

	Method New(cName, cAlias, cAliasName, cID, nOrdem, cIconOpen, cIconClose, cAliasDet, cDetName, cRelIndex, cRelKey, cExecAc, aCamposDet) Constructor   // GFP - 07/04/2015  
	Method AddFolder(cName, cID, cKey, aCampos, cIconOpen, cIconClose, cCampoMark, bCampoMark, bAvalCapa, bAvalDetail)
	Method AddAction(cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose)
	Method RetService()
	Method RetActions()

End Class

Method New(cName, cAlias, cAliasName, cID, nOrdem, cIconOpen, cIconClose, cAliasDet, cDetName, cRelIndex, cRelKey, cExecAc, aCamposDet) Class EECSISSRV   // GFP - 07/04/2015  

	If ValType(cAliasDet) <> "C"
	   Self:cTipo := CAPA
	Else
       Self:cTipo := CAPA_DET
	EndIf
	Self:cName			:= cName
	Self:cAlias			:= cAlias
	Self:cAliasName		:= cAliasName
	Self:cID			:= cId
	Self:cIconOpen		:= cIconOpen
	Self:cIconClose		:= cIconClose
	//*** VER
	Self:aCampos		:= {} 
	Self:nOrdem			:= nOrdem
	//***
	If Self:cTipo == CAPA_DET
	   	Self:cAliasDet		:= cAliasDet
		Self:cDetName		:= cDetName
		Self:cRelIndex		:= cRelIndex
		Self:cRelKey		:= cRelKey
	EndIf
	Self:cExecAc		:= cExecAc
	Self:aFolders		:= {}
	Self:aActions		:= {}
	Self:aCposDet    := If(ValType(aCamposDet) <> "A",{},aCamposDet)   // GFP - 07/04/2015  

Return Self

Method AddFolder(cName, cID, cKey, aCampos, cIconOpen, cIconClose, cCampoMark, bCampoMark, bAvalCapa, bAvalDetail) Class EECSISSRV
                                                        
   //aAdd(Self:aFolders, {cName, cID, cKey, aCampos, cIconOpen, cIconClose, cCampoMark, bCampoMark})
   // BAK - 13/04/2011 - Alteração realizada pra adicionar no vetor aServ da função AvCentIntegracao(),
   //                    o código de bloco do bAval para a capa ou detalhe, localizado 
   //                    na posição aServ[i][4][j][9] (capa) e aServ[i][4][j][10] (detalhe)
   aAdd(Self:aFolders, {cName, cID, cKey, aCampos, cIconOpen, cIconClose, cCampoMark, bCampoMark, bAvalCapa, bAvalDetail})

Return Nil

Method RetService() Class EECSISSRV
Local aSrv

	aSrv := {Self:cName, Self:cAlias, Self:cID, Self:aFolders, Self:aCampos, Self:nOrdem, Self:cIconOpen, Self:cIconClose, Self:cAliasName, Self:cAliasDet, Self:cDetName, Self:cRelIndex, Self:cRelKey, Self:cExecAc, Self:aCposDet}   // GFP - 07/04/2015  

Return aSrv

Method RetActions() Class EECSISSRV

Return Self:aActions

Method AddAction(cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose) Class EECSISSRV

   aAdd(Self:aActions, {cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose})

Return Nil

Class EASYUSERCFG
    
    Data cOwner
    Data cParam
    Data cUser
    
    Data cRotOri
    Data cType
    Data xCont
    Data cCodFilial//RMD - 01/06/18
    
	Method New(cOwner, cUser, cCodFilial) //RMD - 01/06/18
	Method LoadParam(cParam, xDefault, cRotina, lForceUser)//RMD - 01/06/18
	Method SetType()
	Method SetParam(cParam, xValue, cRotina)
    Method GetFilial()
	
End Class

Method New(cOwner, cUser, cCodFilial) Class EASYUSERCFG
Default cOwner := ProcName(1)
Default cUser  := cUserName

	Self:cOwner		:= cOwner
	Self:cUser		:= AvKey(cUser, "EWQ_USER")
    Self:cCodFilial := cCodFilial
	
	Self:cParam		:= ""
	Self:cRotOri	:= ""
	Self:cType		:= ""
	Self:xCont		:= Nil

Return Self

Method LoadParam(cParam, xDefault, cRotina, lForceUser) Class EASYUSERCFG
Default cRotina := Self:cOwner
Default lForceUser := .F.

   Self:cParam		:= AvKey(cParam, "EWQ_PARAM")
   Self:cRotOri		:= AvKey(cRotina, "EWQ_ROTORI")
   Self:cType		:= ValType(xDefault)
   Self:xCont		:= xDefault

   EWQ->(DbSetOrder(1))
   If EWQ->(DbSeek(Self:GetFilial()/*xFilial()*/+Self:cUser+Self:cRotOri+Self:cParam))
      Self:cType := EWQ->EWQ_TIPO
      Self:xCont := AvConvert(AvSX3("EWQ_XCONT",AV_TIPO),EWQ->EWQ_TIPO,,EWQ->EWQ_XCONT)
   ElseIf !lForceUser//RMD - 01/06/18 - Não busca um conteúdo default para o parâmetro caso este parametro seja informado
      EWQ->(DbSetOrder(2))
      If EWQ->(DbSeek(Self:GetFilial()/*xFilial()*/+Self:cRotOri+Self:cParam))
         Self:cType := EWQ->EWQ_TIPO
         Self:xCont := AvConvert(AvSX3("EWQ_XCONT",AV_TIPO),EWQ->EWQ_TIPO,,EWQ->EWQ_XCONT)
      Else
         Self:SetParam(Self:cParam, Self:xCont, Self:cRotOri)
      EndIf
   EndIf
   Self:SetType()
Return Self:xCont


Method SetType() Class EASYUSERCFG
//Seta o conteúdo do parâmetro para o tipo definido (a partir de caractere)
   If Self:cType == "C"
      Self:xCont := AllTrim(Self:xCont)
   EndIf
   /*If Self:cType <> "C"
      Self:xCont := &(Self:xCont)
   EndIf*/
Return Nil


Method SetParam(cParam, xValue, cRotina) Class EASYUSERCFG
Default cRotina := Self:cOwner

   Self:cParam		:= AvKey(cParam, "EWQ_PARAM")
   Self:cRotOri		:= AvKey(cRotina, "EWQ_ROTORI")
   Self:cType		:= ValType(xValue)
   Self:xCont		:= xValue
   
   EWQ->(DbSetOrder(1))
   If EWQ->(DbSeek(Self:GetFilial()/*xFilial()*/+Self:cUser+Self:cRotOri+Self:cParam))
      Self:cType := EWQ->EWQ_TIPO
      EWQ->(RecLock("EWQ", .F.))
      EWQ->EWQ_XCONT	:= xValueToChar(Self:xCont)
      EWQ->(MsUnlock())
   Else
      EWQ->(RecLock("EWQ", .T.))
      EWQ->EWQ_FILIAL	:= Self:GetFilial()/*xFilial("EWQ")*/
      EWQ->EWQ_USER		:= Self:cUser
      EWQ->EWQ_ROTORI	:= Self:cRotOri
      EWQ->EWQ_PARAM	:= Self:cParam
      EWQ->EWQ_TIPO		:= Self:cType
      EWQ->EWQ_XCONT	:= xValueToChar(Self:xCont)
      EWQ->(MsUnlock())
   EndIf
   
Return Self:xCont

Method GetFilial() Class EASYUSERCFG
Local cCodFilial

    If Self:cCodFilial <> Nil
        cCodFilial := Self:cCodFilial
    Else
        cCodFilial := xFilial("EWQ")
    EndIf

Return cCodFilial

Static Function xValueToChar(xValue)
Return AvConvert(ValType(xValue),AvSX3("EWQ_XCONT",AV_TIPO),AvSX3("EWQ_XCONT",AV_TAMANHO),xValue)

Function EI100QtdRE(cId)
Local nQtdRE := 0
Local aOrd := SaveOrd("EWK")

   cId := AvKey(cId, "EWK_ID")
   EWK->(DbSetOrder(1))
   EWK->(DbSeek(xFilial()+cId))
   While EWK->(!Eof() .And. EWK_FILIAL+EWK_ID == xFilial("EWK")+cId)
      ++nQtdRE
      EWK->(DbSkip())
   EndDo
   RestOrd(aOrd, .T.)

Return AllTrim(Str(nQtdRE))

Function EI300SaveXML(cDirOut, cNomFile, cXML, lRelXML)
Local nHandler := EasyCreateFile(cDirOut + cNomFile + EXT_XML)
Local cXMLINS := ""
Local nAt1, nAt2
Default lRelXML := .F.
   
   If !lRelXML
      cXMLINS := " xmlns = 'http://www.serpro.gov.br/exportacaoweb/schema/LoteRegistroExportacao.html' " +;
                 "xmlns:xsi = 'http://www.w3.org/2001/XMLSchema-instance' " +;
                 "xsi:schemaLocation = 'http://www.serpro.gov.br/exportacaoweb/schema/LoteRegistroExportacao.html LoteRegistroExportacao.xsd'"
   EndIF

   If (nAt1 := At("idArquivo", cXML)) > 0
      nAt2 := At(">", SubStr(cXML, nAt1))
      cXML := Left(cXML, nAt1+nAt2-2) + cXMLINS + SubStr(cXML, nAt1+nAt2-1)
   EndIf

   If lRelXML
      cXML := XML_STYLE + cXML
   EndIf

   cXML := XML_ISO_8859_1 + cXML
   FWrite(nHandler, cXML)
   FClose(nHandler)

Return Nil

Function EI300REStatus(cCodStatus)
Local nPos, aStatus, cStatus

aStatus := {{01, 'Pendente'},;
            {02, 'Deferido'},;
            {03, 'Em Análise'},;
            {04, 'Em Exigência'},;
            {05, 'Indeferido'},;
            {06, 'Vencido'},;
            {07, 'Cancelado'},;
            {08, 'Em Despacho'},;
            {09, 'Averbado'},;
            {10, 'Deferido Judicialmente'},;
            {11, 'Indeferido Judicialmente'},;
            {-1, 'Sem retorno do Siscomex'},;
            {99, 'Erro no Registro do RE'}}

If (nPos := aScan(aStatus,{|X| X[1] == Val(cCodStatus)})) > 0
   cStatus := aStatus[nPos][2]
Else
   cStatus := "STATUS INDETERMINADO"
EndIf

Return cStatus
/* 
==================================================================================================================
Função     : EI300VLote
Parametros :
Objetivo   : Apresentar em forma organizada em Folders todas as informações sobre Mercadorias,Fabricantes e DrawBack
*            dos anexos da RE
Autor      : Olliver Adami Pedroso
Data       : 07/01/2011
Revisão    : Bruno Akyo Kubagawa / 28 de Abril de 2011
==================================================================================================================
*/
Function EI300VLote(oMsSelect)
Local aPosTelaUp  := {}
Local oDlg
Local oMemo
Local oEnch
Local cMemo  := ""
Local cAlias := oMsSelect:oBrowse:cAlias
Local aMostra := {"EWJ_STATUS","EWJ_ID","EWJ_ARQENV","EWJ_PREEMB","EWJ_DATAG","EWJ_HORAG","EWJ_USERG","EWJ_DATAE","EWJ_HORAE","EWJ_USERE","EWJ_ARQREC","EWJ_DATAR","EWJ_HORAR","EWJ_USERR","EWJ_DATAP","EWJ_HORAP","EWJ_USERP","EWJ_LOTE"}
Local oFont := TFont():New("Courier New",09,15)           
PRIVATE lInvert := .F.

Begin Sequence
   If Empty(AvKey((cAlias)->EWJ_ID,"EWJ_ID"))
      Break
   EndIf

   EWJ->(dbSetOrder(1))
   If EWJ->(DbSeek(xFilial("EWJ") + AvKey((cAlias)->EWJ_ID,"EWJ_ID") )) .And. EWJ->(FieldPos("EWJ_CODERR")) > 0
      cMemo := MSMM(EWJ->EWJ_CODERR,AVSX3("EWJ_ERROS",AV_TAMANHO),,,LERMEMO)
   EndIf
   
   DEFINE MSDIALOG oDlg TITLE "Detalhes do Lote" FROM 0,0;
                                                 TO DLG_LIN_FIM*0.9, DLG_COL_FIM*0.61;
                                                 OF oMainWnd PIXEL
      aPosTelaUp   := PosDlgUp(oDlg)
      oEnch := MsMGet():New("EWJ", EWJ->(Recno()), VISUALIZAR,,,,aMostra, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
      //oEnch := EnChoice("EWJ", EWJ->(Recno()), VISUALIZAR,,,,aMostra, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3]-20,aPosTelaUp[4]},)
      @ 106.5,0.2 Get oMemo Var cMemo MEMO FONT oFont Size 304.2,138.5 Of oDlg Pixel
      oEnch:oBox:Align := CONTROL_ALIGN_TOP
      oMemo:Align := CONTROL_ALIGN_ALLCLIENT
      oMemo:lWordWrap := .F.
      oMemo:EnableVScroll(.T.)
      oMemo:EnableHScroll(.T.)
   ACTIVATE MSDIALOG oDlg Centered

End Sequence

Return Nil

Static Function AtuEasyLink()

   EYA->(DbSetOrder(1))
   If !EYA->(DbSeek(xFilial()+"100"))
      EYA->(RecLock("EYA", .T.))
      EYA->EYA_FILIAL := xFilial("EYA")
      EYA->EYA_CODINT := "100"
      EYA->EYA_NOMINT := "SigaEEC - NovoEX"
      EYA->EYA_COND   := "EECFlags('NOVOEX')"
      EYA->(MsUnlock())
   EndIf

   EYB->(DbSetOrder(1))
   If !EYB->(DbSeek(xFilial()+"100"))
      EYB->(RecLock("EYB", .T.))
      EYB->EYB_FILIAL := xFilial("EYB")
      EYB->EYB_CODAC  := "100"
      EYB->EYB_DESAC  := "Envio RE NovoEx"
      EYB->(MsUnlock())
   EndIf

   EYC->(DbSetOrder(1))
   If !EYC->(DbSeek(xFilial()+"100"+"100"+"001"))
      EYC->(RecLock("EYC", .T.))
      EYC->EYC_FILIAL := xFilial("EYC")
      EYC->EYC_CODAC  := "100"
      EYC->EYC_CODINT := "100"
      EYC->EYC_CODEVE := "001"
      EYC->EYC_CODSRV := "100"
      EYC->(MsUnlock())
   EndIf

   EYD->(DbSetOrder(1))
   If !EYD->(DbSeek(xFilial()+"XML"))
      EYD->(RecLock("EYD", .T.))
      EYD->EYD_FILIAL := xFilial("EYD")
      EYD->EYD_NAME   := "XML"
      EYD->EYD_TYPE   := "X"
      EYD->EYD_SIZE   := 100
      EYD->(MsUnlock())
   EndIf

   EYD->(DbSetOrder(1))
   If !EYD->(DbSeek(xFilial()+"SRV_STATUS"))
      EYD->(RecLock("EYD", .T.))
      EYD->EYD_FILIAL := xFilial("EYD")
      EYD->EYD_NAME   := "SRV_STATUS"
      EYD->EYD_TYPE   := "L"
      EYD->EYD_SIZE   := 3
      EYD->(MsUnlock())
   EndIf

   EYE->(DbSetOrder(1))   
   If !EYE->(DbSeek(xFilial()+"100"+"100"))
      EYE->(RecLock("EYE", .T.))
      EYE->EYE_FILIAL := xFilial("EYE")
      EYE->EYE_ARQXML := "novoex_novo_re.xml"
      EYE->EYE_CODINT := "100"
      EYE->EYE_CODSRV := "100"
      EYE->EYE_DESSRV := "Geração de novo RE - NovoEX"
      EYE->(MsUnlock())
   EndIf
   
Return nil

Static Function CriaXMLEasyLink(cFile)
Local cXML := ""
Local nHandler
   
Begin Sequence

   If Empty(cFile)
      Break
   EndIf 

   nHandler := EasyCreateFile(cFile)
   
   cXML += "<EASYLINK>"+CHR(13)+CHR(10)
   cXML += "<SERVICE>"+CHR(13)+CHR(10)
   cXML += "<ID>100</ID>"+CHR(13)+CHR(10)
   cXML += "<DATA_SELECTION>"+CHR(13)+CHR(10)
   cXML += "<XML ELINKINFO = " + Chr(34) + "'DICTAGS_OFF'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<lote idArquivo = " + Chr(34) + "cId" + Chr(34) + " tipoArquivo=" + Chr(34) + "cTipoArq" + Chr(34)+" >"+CHR(13)+CHR(10)
   cXML += "<qtdREs>EI100QtdRE(cId)</qtdREs>"+CHR(13)+CHR(10)
   cXML += "<ALIAS>" + Chr(34) + "EWK" + Chr(34) + "</ALIAS>"+CHR(13)+CHR(10)
   cXML += "<ORDER>1</ORDER>"+CHR(13)+CHR(10)
   cXML += "<SEEK>xFilial(" + Chr(34) + "EWK" + Chr(34) + ")+cId</SEEK>"+CHR(13)+CHR(10)
   cXML += "<WHILE COND = 'EWK->(EWK_FILIAL+EWK_ID) == xFilial(" + Chr(34) + "EWK" + Chr(34) + ")+cId' REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<IF_01  COND = " + Chr(34) + "lRelXML == .F." + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<registro-exportacao>"+CHR(13)+CHR(10)
   
   //wfs 29/11/13
   cXML += "<IF_20 COND = " + Chr(34) + "!Empty(EWK->EWK_NRORE)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<numero-re>EWK->EWK_NRORE</numero-re>"
   cXML += "</IF_20>"+CHR(13)+CHR(10)
   
   cXML += "<adicao-re-lote>if(cTipoArq == 'I' .And. EWK->(FieldPos('EWK_ANEXO')>0 .AND. Val(EWK_ANEXO)>=1)," + Chr(34) + "S" + Chr(34) + "," + Chr(34) + "N" + Chr(34) + ")</adicao-re-lote>"+CHR(13)+CHR(10)  // GFP - 17/01/2014
   cXML += "<nr-processo-exportador>AllTrim(EWK->EWK_PREEMB)</nr-processo-exportador>"+CHR(13)+CHR(10)
   cXML += "<IF_01 COND = " + Chr(34) + "EWK->EWK_TIPEXP == 'F'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cpf-exportador>AllTrim(EWK->EWK_CGCEXP)</cpf-exportador>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "EWK->EWK_TIPEXP == 'J'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cnpj-exportador>AllTrim(EWK->EWK_CGCEXP)</cnpj-exportador>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<IF_03 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN1)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN1)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_03>"+CHR(13)+CHR(10)
   cXML += "<IF_04 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN2)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN2)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_04>"+CHR(13)+CHR(10)
   cXML += "<IF_05 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN3)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN3)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_05>"+CHR(13)+CHR(10)
   cXML += "<IF_06 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN4)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN4)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_06>"+CHR(13)+CHR(10)
   cXML += "<IF_07 COND = " + Chr(34) + "!Empty(EWK->EWK_DTLIM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<data-limite>AllTrim(DToC(EWK->EWK_DTLIM))</data-limite>"+CHR(13)+CHR(10)
   cXML += "</IF_07>"+CHR(13)+CHR(10)
   cXML += "<IF_08 COND = " + Chr(34) + "!Empty(EWK->EWK_MARSAC)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<percentual-margem-nao-sacada>AllTrim(STR(EWK->EWK_MARSAC))</percentual-margem-nao-sacada>"+CHR(13)+CHR(10)
   cXML += "</IF_08>"+CHR(13)+CHR(10)
   cXML += "<IF_09 COND = " + Chr(34) + "!Empty(EWK->EWK_GDRPRO)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<numero-processo>AllTrim(Str(EWK->EWK_GDRPRO))</numero-processo>"+CHR(13)+CHR(10)
   cXML += "</IF_09>"+CHR(13)+CHR(10)
   cXML += "<IF_10 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMRC)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<rc-vinculado>AllTrim(EWK->EWK_NUMRC)</rc-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_10>"+CHR(13)+CHR(10)
   cXML += "<IF_11 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMRV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<rv-vinculado>AllTrim(EWK->EWK_NUMRV)</rv-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_11>"+CHR(13)+CHR(10)
   cXML += "<IF_12 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMREV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<re-vinculado>AllTrim(EWK->EWK_NUMREV)</re-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_12>"+CHR(13)+CHR(10)
   cXML += "<IF_13 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMDIV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<di-vinculado>AllTrim(EWK->EWK_NUMDIV)</di-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_13>"+CHR(13)+CHR(10)
   cXML += "<nome-importador>AllTrim(EWK->EWK_NOMIMP)</nome-importador>"+CHR(13)+CHR(10)
   cXML += "<endereco-importador>AllTrim(EWK->EWK_ENDIMP)</endereco-importador>"+CHR(13)+CHR(10)
   cXML += "<pais-destino>AllTrim(EWK->EWK_PAISDE)</pais-destino>"+CHR(13)+CHR(10)
   cXML += "<pais-importador>AllTrim(EWK->EWK_PAISIM)</pais-importador>"+CHR(13)+CHR(10)
   cXML += "<IF_14 COND = " + Chr(34) + "!Empty(EWK->EWK_INSCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<instrumento-comercial>"+CHR(13)+CHR(10)
   cXML += "<tipo-instrumento>AllTrim(EWK->EWK_TPINST)</tipo-instrumento>"+CHR(13)+CHR(10)
   cXML += "<codigo-instrumento>AllTrim(EWK->EWK_INSCOM)</codigo-instrumento>"+CHR(13)+CHR(10)
   cXML += "</instrumento-comercial>"+CHR(13)+CHR(10)
   cXML += "</IF_14>"+CHR(13)+CHR(10)
   cXML += "<orgao-rf-despacho>AllTrim(EWK->EWK_RFDESP)</orgao-rf-despacho>"+CHR(13)+CHR(10)
   cXML += "<orgao-rf-embarque>AllTrim(EWK->EWK_RFEMB)</orgao-rf-embarque>"+CHR(13)+CHR(10)
   cXML += "<condicao-venda>AllTrim(EWK->EWK_INCOTE)</condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<modalidade-pagamento>AllTrim(EWK->EWK_MODPAG)</modalidade-pagamento>"+CHR(13)+CHR(10)
   cXML += "<moeda>AllTrim(EWK->EWK_MOEDA)</moeda>"+CHR(13)+CHR(10)
   cXML += "<re-base>"+CHR(13)+CHR(10)
   cXML += "<valor-sem-cobertura>AllTrim(Str(EWK->EWK_VLSCOB))</valor-sem-cobertura>"+CHR(13)+CHR(10)
   cXML += "<valor-com-cobertura>AllTrim(Str(EWK->EWK_VLCCOB))</valor-com-cobertura>"+CHR(13)+CHR(10)
   cXML += "<valor-consignacao>AllTrim(Str(EWK->EWK_VLCONS))</valor-consignacao>"+CHR(13)+CHR(10)
   cXML += "</re-base>"+CHR(13)+CHR(10)
   cXML += "<IF_15 COND = " + Chr(34) + "EWK->EWK_VLFINA > 0" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<valor-financiamento>AllTrim(Str(EWK->EWK_VLFINA))</valor-financiamento>"+CHR(13)+CHR(10)
   cXML += "</IF_15>"+CHR(13)+CHR(10)
   cXML += "<condicao-fabricante>AllTrim(EWK->EWK_EXPFAB)</condicao-fabricante>"+CHR(13)+CHR(10)
   cXML += "<mercadoria-destaque>AllTrim(EWK->EWK_NCM)</mercadoria-destaque>"+CHR(13)+CHR(10)
   cXML += "<IF_16 COND = " + Chr(34) + "!Empty(EWK->EWK_NALADI)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<naladi>AllTrim(EWK->EWK_NALADI)</naladi>"+CHR(13)+CHR(10)
   cXML += "</IF_16>"+CHR(13)+CHR(10)
   cXML += "<descricao-unidade-medida-comercial>AllTrim(EWK->EWK_UMCOM)</descricao-unidade-medida-comercial>"+CHR(13)+CHR(10)
   cXML += "<prazo-pagamento>AllTrim(Str(EWK->EWK_PRAZO))</prazo-pagamento>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_01>" + Chr(34) + "EWL" + Chr(34) + "</ALIAS_01>"+CHR(13)+CHR(10)
   cXML += "<ORDER_01>1</ORDER_01>"+CHR(13)+CHR(10)
   cXML += "<SEEK_01>xFilial(" + Chr(34) + "EWL" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_01>"+CHR(13)+CHR(10)
   
   /*LGS-12/03/2014 - Incluido validacao do EWL_MUNICO para validar se o item deve ser montado na TAG <item-mercadoria> ou <item-mercadoria-unico>
                      Se nao tiver o campo no dicionario de dados o sistema segue montando o item na TAG <item-mercadoria> como é feito.*/
   cXML += "<IF_21 COND = " + Chr(34) + "EWL->(FIELDPOS('EWL_MUNICO')) == 0" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWL->(EWL_FILIAL+EWL_ID+EWL_SEQRE) == xFilial('EWL')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(Str(EWL->EWL_VLVEND))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(Str(EWL->EWL_VLFOB))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(Str(EWL->EWL_QTD))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(Str(EWL->EWL_QTDNCM))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(Str(EWL->EWL_PESO))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria>"+CHR(13)+CHR(10)   
   cXML += "<SKIP>" + Chr(34) + "EWL" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</IF_21>"+CHR(13)+CHR(10)

   cXML += "<IF_22 COND = " + Chr(34) + "EWL->(FIELDPOS('EWL_MUNICO')) > 0" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWL->(EWL_FILIAL+EWL_ID+EWL_SEQRE) == xFilial('EWL')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<IF_23 COND = " + Chr(34) + "EWL->EWL_MUNICO == 1" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(Str(EWL->EWL_VLVEND))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(Str(EWL->EWL_VLFOB))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(Str(EWL->EWL_QTD))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(Str(EWL->EWL_QTDNCM))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(Str(EWL->EWL_PESO))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria>"+CHR(13)+CHR(10)   
   cXML += "</IF_23>"+CHR(13)+CHR(10)
   cXML += "<IF_24 COND = " + Chr(34) + "EWL->EWL_MUNICO == 2" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria-unico>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(Str(EWL->EWL_VLVEND))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(Str(EWL->EWL_VLFOB))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(Str(EWL->EWL_QTD))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(Str(EWL->EWL_QTDNCM))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(Str(EWL->EWL_PESO))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria-unico>"+CHR(13)+CHR(10)   
   cXML += "</IF_24>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWL" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</IF_22>"+CHR(13)+CHR(10)
   
   cXML += "<IF_17 COND = " + Chr(34) + "!Empty(EWK->EWK_PERCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<percentual-comissao-agente>AllTrim(Str(EWK->EWK_PERCOM))</percentual-comissao-agente>"+CHR(13)+CHR(10)
   cXML += "</IF_17>"+CHR(13)+CHR(10)
   cXML += "<IF_18 COND = " + Chr(34) + "!Empty(EWK->EWK_TIPCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<tipo-comissao>AllTrim(EWK->EWK_TIPCOM)</tipo-comissao>"+CHR(13)+CHR(10)
   cXML += "</IF_18>"+CHR(13)+CHR(10)
   cXML += "<categoria-cota>AllTrim(EWK->EWK_CATCOT)</categoria-cota>"+CHR(13)+CHR(10)  // GFP - 15/04/2014
   cXML += "<IF_19 COND = " + Chr(34) + "!Empty(If(EWK->(FieldPos('EWK_OBS'))==0,Msmm(EWK->EWK_CODOBS),EWK->EWK_OBS))" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<observacao>AllTrim(If(EWK->(FieldPos('EWK_OBS'))==0,Msmm(EWK->EWK_CODOBS),EWK->EWK_OBS))</observacao>"+CHR(13)+CHR(10)
   cXML += "</IF_19>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_02>" + Chr(34) + "EWM" + Chr(34) + "</ALIAS_02>"+CHR(13)+CHR(10)
   cXML += "<ORDER_02>1</ORDER_02>"+CHR(13)+CHR(10)
   cXML += "<SEEK_02>xFilial(" + Chr(34) + "EWM" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_02>"+CHR(13)+CHR(10)
   cXML += "<WHILE_02 COND = " + Chr(34) + "EWM->(EWM_FILIAL+EWM_ID+EWM_SEQRE) == xFilial('EWM')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<drawback>"+CHR(13)+CHR(10)
   cXML += "<cnpj>AllTrim(EWM->EWM_CNPJ)</cnpj>"+CHR(13)+CHR(10)
   cXML += "<ncm>AllTrim(EWM->EWM_NCM)</ncm>"+CHR(13)+CHR(10)
   cXML += "<ato-concessorio>AllTrim(EWM->EWM_ATO)</ato-concessorio>"+CHR(13)+CHR(10)
   cXML += "<item-ato-concessorio>AllTrim(EWM->EWM_SEQSIS)</item-ato-concessorio>"+CHR(13)+CHR(10)
   cXML += "<vl-moeda-re-com-cobertura-cambial>AllTrim(Str(EWM->EWM_VLCCOB))</vl-moeda-re-com-cobertura-cambial>"+CHR(13)+CHR(10)
   cXML += "<vl-moeda-re-sem-cobertura-cambial>AllTrim(Str(EWM->EWM_VLSCOB))</vl-moeda-re-sem-cobertura-cambial>"+CHR(13)+CHR(10)
   cXML += "<quantidade>AllTrim(Str(EWM->EWM_QTDE))</quantidade>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_01>" + Chr(34) + "EWN" + Chr(34) + "</ALIAS_01>"+CHR(13)+CHR(10)
   cXML += "<ORDER_01>1</ORDER_01>"+CHR(13)+CHR(10)
   cXML += "<SEEK_01>xFilial(" + Chr(34) + "EWN" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)+EWM->EWM_SEQDB</SEEK_01>"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWN->(EWN_FILIAL+EWN_ID+EWN_SEQRE+EWN_SEQDB) == xFilial('EWM')+EWK->(EWK_ID+EWK_SEQRE)+EWM->EWM_SEQDB" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<nota-fiscal>"+CHR(13)+CHR(10)
   cXML += "<numero>AllTrim(EWN->EWN_NF)</numero>"+CHR(13)+CHR(10)
   cXML += "<data>AllTrim(DToC(EWN->EWN_DATA))</data>"+CHR(13)+CHR(10)
   cXML += "<quantidade-exportada>AllTrim(Str(EWN->EWN_QTD))</quantidade-exportada>"+CHR(13)+CHR(10)
   cXML += "<valor>AllTrim(Str(EWN->EWN_VALOR))</valor>"+CHR(13)+CHR(10)
   cXML += "</nota-fiscal>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWN" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</drawback>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWM" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_02>"+CHR(13)+CHR(10)
   cXML += "<indicador-ccptc>" + Chr(34) + "N" + Chr(34) + "</indicador-ccptc>"+CHR(13)+CHR(10)
   cXML += "<indicador-insumo-ccptc>" + Chr(34) + "N" + Chr(34) + "</indicador-insumo-ccptc>"+CHR(13)+CHR(10)
   cXML += "<indicador-ccrom>" + Chr(34) + "N" + Chr(34) + "</indicador-ccrom>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_03>" + Chr(34) + "EWO" + Chr(34) + "</ALIAS_03>"+CHR(13)+CHR(10)
   cXML += "<ORDER_03>1</ORDER_03>"+CHR(13)+CHR(10)
   cXML += "<SEEK_03>xFilial(" + Chr(34) + "EWO" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_03>"+CHR(13)+CHR(10)
   cXML += "<WHILE_03 COND = " + Chr(34) + "EWO->(EWO_FILIAL+EWO_ID+EWO_SEQRE) == xFilial('EWO')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<fabricante>"+CHR(13)+CHR(10)
   cXML += "<cpf-cnpj>AllTrim(EWO->EWO_CGC)</cpf-cnpj>"+CHR(13)+CHR(10)
   cXML += "<sigla-uf-fabric>AllTrim(EWO->EWO_UF)</sigla-uf-fabric>"+CHR(13)+CHR(10)
   cXML += "<qtd-estatistica-fabric>AllTrim(Str(EWO->EWO_QTD))</qtd-estatistica-fabric>"+CHR(13)+CHR(10)
   cXML += "<peso-liquido-fabric>AllTrim(Str(EWO->EWO_PESO))</peso-liquido-fabric>"+CHR(13)+CHR(10)
   cXML += "<valor-moeda-local-embarque>AllTrim(Str(EWO->EWO_VALOR))</valor-moeda-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<obs-fabric>AllTrim(EWO->EWO_OBS)</obs-fabric>"+CHR(13)+CHR(10)
   cXML += "</fabricante>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWO" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_03>"+CHR(13)+CHR(10)
   cXML += "</registro-exportacao>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "lRelXML == .T." + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<registro-exportacao>"+CHR(13)+CHR(10)

   //wfs 29/11/13
   cXML += "<IF_20 COND = " + Chr(34) + "!Empty(EWK->EWK_NRORE)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<numero-re>EWK->EWK_NRORE</numero-re>"
   cXML += "</IF_20>"+CHR(13)+CHR(10)
   
   cXML += "<adicao-re-lote>if(cTipoArq == 'I' .And. EWK->(FieldPos('EWK_ANEXO')>0 .AND. Val(EWK_ANEXO)>1)," + Chr(34) + "S" + Chr(34) + "," + Chr(34) + "N" + Chr(34) + ")</adicao-re-lote>"+CHR(13)+CHR(10)
   cXML += "<nr-processo-exportador>AllTrim(EWK->EWK_PREEMB)</nr-processo-exportador>"+CHR(13)+CHR(10)
   cXML += "<numero-re>AllTrim(Left(EWK->EWK_NRORE,7))</numero-re>"+CHR(13)+CHR(10)
   cXML += "<anexo-re>AllTrim(EWK->EWK_ANEXO)</anexo-re>"+CHR(13)+CHR(10)
   cXML += "<status-re>AllTrim(EI300REStatus(EWK->EWK_STATUS))</status-re>"+CHR(13)+CHR(10)
   cXML += "<data-hora-re>AllTrim(DToC(EWK->EWK_DTRE))</data-hora-re>"+CHR(13)+CHR(10)
   cXML += "<IF_01 COND = " + Chr(34) + "EWK->EWK_TIPEXP == 'F'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cpf-cnpj-exportador>AllTrim(Transform(EWK->EWK_CGCEXP," + Chr(34) + "@R 999.999.999-99" + Chr(34) + "))</cpf-cnpj-exportador>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "EWK->EWK_TIPEXP == 'J'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cpf-cnpj-exportador>AllTrim(Transform(EWK->EWK_CGCEXP," + Chr(34) + "@R 99.999.999/9999-99" + Chr(34) + "))</cpf-cnpj-exportador>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<nome-exportador>AllTrim(Posicione(" + Chr(34) + "SA2" + Chr(34) + ",3,xFilial(" + Chr(34) + "SA2" + Chr(34) + ")+AvKey(EWK->EWK_CGCEXP," + Chr(34) + "A2_COD" + Chr(34) + ")," + Chr(34) + "A2_NOME" + Chr(34) + "))</nome-exportador>"+CHR(13)+CHR(10)
   cXML += "<IF_03 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN1)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN1)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "<descricao-enquadramento>AllTrim(Posicione(" + Chr(34) + "EED" + Chr(34) + ",1,xFilial(" + Chr(34) + "EED" + Chr(34) + ")+AvKey(EWK->EWK_CODEN1," + Chr(34) + "EED_ENQCOD" + Chr(34) + ")," + Chr(34) + "EED_DESC" + Chr(34) + "))</descricao-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_03>"+CHR(13)+CHR(10)
   cXML += "<IF_04 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN2)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN2)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "<descricao-enquadramento>AllTrim(Posicione(" + Chr(34) + "EED" + Chr(34) + ",1,xFilial(" + Chr(34) + "EED" + Chr(34) + ")+AvKey(EWK->EWK_CODEN2," + Chr(34) + "EED_ENQCOD" + Chr(34) + ")," + Chr(34) + "EED_DESC" + Chr(34) + "))</descricao-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_04>"+CHR(13)+CHR(10)
   cXML += "<IF_05 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN3)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN3)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "<descricao-enquadramento>AllTrim(Posicione(" + Chr(34) + "EED" + Chr(34) + ",1,xFilial(" + Chr(34) + "EED" + Chr(34) + ")+AvKey(EWK->EWK_CODEN3," + Chr(34) + "EED_ENQCOD" + Chr(34) + ")," + Chr(34) + "EED_DESC" + Chr(34) + "))</descricao-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_05>"+CHR(13)+CHR(10)
   cXML += "<IF_06 COND = " + Chr(34) + "!Empty(EWK->EWK_CODEN4)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<enquadramento>"+CHR(13)+CHR(10)
   cXML += "<codigo-enquadramento>AllTrim(EWK->EWK_CODEN4)</codigo-enquadramento>"+CHR(13)+CHR(10)
   cXML += "<descricao-enquadramento>AllTrim(Posicione(" + Chr(34) + "EED" + Chr(34) + ",1,xFilial(" + Chr(34) + "EED" + Chr(34) + ")+AvKey(EWK->EWK_CODEN4," + Chr(34) + "EED_ENQCOD" + Chr(34) + ")," + Chr(34) + "EED_DESC" + Chr(34) + "))</descricao-enquadramento>"+CHR(13)+CHR(10)
   cXML += "</enquadramento>"+CHR(13)+CHR(10)
   cXML += "</IF_06>"+CHR(13)+CHR(10)
   cXML += "<IF_07 COND = " + Chr(34) + "!Empty(EWK->EWK_DTLIM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<data-limite>AllTrim(DToC(EWK->EWK_DTLIM))</data-limite>"+CHR(13)+CHR(10)
   cXML += "</IF_07>"+CHR(13)+CHR(10)
   cXML += "<IF_08 COND = " + Chr(34) + "!Empty(EWK->EWK_MARSAC)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<percentual-margem-nao-sacada>AllTrim(TransForm(EWK->EWK_MARSAC," + Chr(34) + "@E 999.99" + Chr(34) + "))</percentual-margem-nao-sacada>"+CHR(13)+CHR(10)
   cXML += "</IF_08>"+CHR(13)+CHR(10)
   cXML += "<IF_09 COND = " + Chr(34) + "!Empty(EWK->EWK_GDRPRO)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<numero-processo>AllTrim(Str(EWK->EWK_GDRPRO))</numero-processo>"+CHR(13)+CHR(10)
   cXML += "</IF_09>"+CHR(13)+CHR(10)
   cXML += "<IF_10 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMRC)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<rc-vinculado>AllTrim(TransForm(EWK->EWK_NUMRC," + Chr(34) + "@R 99/9999999" + Chr(34) + "))</rc-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_10>"+CHR(13)+CHR(10)
   cXML += "<IF_11 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMRV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<rv-vinculado>AllTrim(TransForm(EWK->EWK_NUMRV," + Chr(34) + "@R 99/9999999" + Chr(34) + "))</rv-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_11>"+CHR(13)+CHR(10)
   cXML += "<IF_12 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMREV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<re-vinculado>AllTrim(TransForm(EWK->EWK_NUMREV," + Chr(34) + "@R 99/9999999-999 " + Chr(34) + "))</re-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_12>"+CHR(13)+CHR(10)
   cXML += "<IF_13 COND = " + Chr(34) + "!Empty(EWK->EWK_NUMDIV)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<di-vinculado>AllTrim(EWK->EWK_NUMDIV)</di-vinculado>"+CHR(13)+CHR(10)
   cXML += "</IF_13>"+CHR(13)+CHR(10)
   cXML += "<nome-importador>AllTrim(EWK->EWK_NOMIMP)</nome-importador>"+CHR(13)+CHR(10)
   cXML += "<endereco-importador>AllTrim(EWK->EWK_ENDIMP)</endereco-importador>"+CHR(13)+CHR(10)
   cXML += "<pais-destino>AllTrim(EWK->EWK_PAISDE)</pais-destino>"+CHR(13)+CHR(10)
   cXML += "<pais-importador>AllTrim(EWK->EWK_PAISIM)</pais-importador>"+CHR(13)+CHR(10)
   cXML += "<descricao-pais-destino>AllTrim(Posicione(" + Chr(34) + "SYA" + Chr(34) + ",1,xFilial(" + Chr(34) + "SYA" + Chr(34) + ")+AvKey(EWK->EWK_PAISDE," + Chr(34) + "YA_CODGI" + Chr(34) + ")," + Chr(34) + "YA_DESCR" + Chr(34) + "))</descricao-pais-destino>"+CHR(13)+CHR(10)
   cXML += "<descricao-pais-importador>AllTrim(Posicione(" + Chr(34) + "SYA" + Chr(34) + ",1,xFilial(" + Chr(34) + "SYA" + Chr(34) + ")+AvKey(EWK->EWK_PAISIM," + Chr(34) + "YA_CODGI" + Chr(34) + ")," + Chr(34) + "YA_DESCR" + Chr(34) + "))</descricao-pais-importador>"+CHR(13)+CHR(10)
   cXML += "<IF_14 COND = " + Chr(34) + "!Empty(EWK->EWK_INSCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<instrumento-comercial>"+CHR(13)+CHR(10)
   cXML += "<tipo-instrumento>AllTrim(EWK->EWK_TPINST)</tipo-instrumento>"+CHR(13)+CHR(10)
   cXML += "<codigo-instrumento>AllTrim(EWK->EWK_INSCOM)</codigo-instrumento>"+CHR(13)+CHR(10)
   cXML += "<descricao-codigo-instrumento>AllTrim(Posicione(" + Chr(34) + "EEE" + Chr(34) + ",1,xFilial(" + Chr(34) + "EEE" + Chr(34) + ")+AvKey(EWK->EWK_INSCOM," + Chr(34) + "EEE_INSCOD" + Chr(34) + ")," + Chr(34) + "EEE_DESC" + Chr(34) + "))</descricao-codigo-instrumento>"+CHR(13)+CHR(10)
   cXML += "</instrumento-comercial>"+CHR(13)+CHR(10)
   cXML += "</IF_14>"+CHR(13)+CHR(10)
   cXML += "<orgao-rf-despacho>AllTrim(EWK->EWK_RFDESP)</orgao-rf-despacho>"+CHR(13)+CHR(10)
   cXML += "<descricao-orgao-rf-despacho>AllTrim(Posicione(" + Chr(34) + "SJ0" + Chr(34) + ",1,xFilial(" + Chr(34) + "SJ0" + Chr(34) + ")+AvKey(EWK->EWK_RFDESP," + Chr(34) + "J0_CODIGO" + Chr(34) + ")," + Chr(34) + "J0_DESC" + Chr(34) + "))</descricao-orgao-rf-despacho>"+CHR(13)+CHR(10)
   cXML += "<orgao-rf-embarque>AllTrim(EWK->EWK_RFEMB)</orgao-rf-embarque>"+CHR(13)+CHR(10)
   cXML += "<descricao-orgao-rf-embarque>AllTrim(Posicione(" + Chr(34) + "SJ0" + Chr(34) + ",1,xFilial(" + Chr(34) + "SJ0" + Chr(34) + ")+AvKey(EWK->EWK_RFEMB," + Chr(34) + "J0_CODIGO" + Chr(34) + ")," + Chr(34) + "J0_DESC" + Chr(34) + "))</descricao-orgao-rf-embarque>"+CHR(13)+CHR(10)
   cXML += "<condicao-venda>AllTrim(EWK->EWK_INCOTE)</condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<descricao-condicao-venda>AllTrim(Posicione(" + Chr(34) + "SYJ" + Chr(34) + ",1,xFilial(" + Chr(34) + "SYJ" + Chr(34) + ")+AvKey(EWK->EWK_INCOTE," + Chr(34) + "YJ_COD" + Chr(34) + ")," + Chr(34) + "YJ_DESCR" + Chr(34) + "))</descricao-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<modalidade-pagamento>AllTrim(EWK->EWK_MODPAG)</modalidade-pagamento>"+CHR(13)+CHR(10)
   cXML += "<descricao-modalidade-pagamento>AllTrim(Posicione(" + Chr(34) + "EEF" + Chr(34) + ",1,xFilial(" + Chr(34) + "EEF" + Chr(34) + ")+AvKey(EWK->EWK_MODPAG," + Chr(34) + "EEF_COD" + Chr(34) + ")," + Chr(34) + "EEF_DESC" + Chr(34) + "))</descricao-modalidade-pagamento>"+CHR(13)+CHR(10)
   cXML += "<moeda>AllTrim(EWK->EWK_MOEDA)</moeda>"+CHR(13)+CHR(10)
   cXML += "<descricao-moeda>AllTrim(Posicione(" + Chr(34) + "SYF" + Chr(34) + ",3,xFilial(" + Chr(34) + "SYF" + Chr(34) + ")+AvKey(EWK->EWK_MOEDA," + Chr(34) + "EEF_COD" + Chr(34) + ")," + Chr(34) + "YF_DESC_SI" + Chr(34) + "))</descricao-moeda>"+CHR(13)+CHR(10)
   cXML += "<valor-financiamento>AllTrim(TransForm(EWK->EWK_VLFINA," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-financiamento>"+CHR(13)+CHR(10)
   cXML += "<re-base>"+CHR(13)+CHR(10)
   cXML += "<valor-margem-nao-sacada>AllTrim(TransForm(((EWK->EWK_MARSAC/100)/(1-(EWK->EWK_MARSAC/100)))*EWK->EWK_VLCCOB," + Chr(34) + "@E 999,999,999,999.99" + Chr(34) + "))</valor-margem-nao-sacada>"+CHR(13)+CHR(10)
   cXML += "<valor-sem-cobertura>AllTrim(TransForm(EWK->EWK_VLSCOB," + Chr(34) + "@E 999,999,999,999.99" + Chr(34) + "))</valor-sem-cobertura>"+CHR(13)+CHR(10)
   cXML += "<valor-com-cobertura>AllTrim(TransForm(EWK->EWK_VLCCOB," + Chr(34) + "@E 999,999,999,999.99" + Chr(34) + "))</valor-com-cobertura>"+CHR(13)+CHR(10)
   cXML += "<valor-consignacao>AllTrim(TransForm(EWK->EWK_VLCONS," + Chr(34) + "@E 999,999,999,999.99" + Chr(34) + "))</valor-consignacao>"+CHR(13)+CHR(10)
   cXML += "<valor-total-operacao>AllTrim(TransForm(EWK->EWK_VLSCOB+EWK->EWK_VLCCOB+EWK->EWK_VLCONS," + Chr(34) + "@E 999,999,999,999.99" + Chr(34) + "))</valor-total-operacao>"+CHR(13)+CHR(10)
   cXML += "</re-base>"+CHR(13)+CHR(10)
   cXML += "<condicao-fabricante>AllTrim(EWK->EWK_EXPFAB)</condicao-fabricante>"+CHR(13)+CHR(10)
   cXML += "<descricao-condicao-fabricante>AllTrim(BSCXBOX(" + Chr(34) + "EWK_EXPFAB" + Chr(34) + ",EWK->EWK_EXPFAB))</descricao-condicao-fabricante>"+CHR(13)+CHR(10)
   cXML += "<mercadoria-destaque>AllTrim(EWK->EWK_NCM)</mercadoria-destaque>"+CHR(13)+CHR(10)
   cXML += "<descricao-mercadoria-destaque>AllTrim(Posicione(" + Chr(34) + "SYD" + Chr(34) + ",1,xFilial(" + Chr(34) + "SYD" + Chr(34) + ")+Left(EWK->EWK_NCM,8)," + Chr(34) + "YD_DESC_P" + Chr(34) + "))</descricao-mercadoria-destaque>"+CHR(13)+CHR(10)
   cXML += "<descricao-unidade-medida-comercial>AllTrim(Posicione(" + Chr(34) + "SAH" + Chr(34) + ",1,xFilial(" + Chr(34) + "SAH" + Chr(34) + ")+Left(EWK->EWK_UMCOM,2)," + Chr(34) + "SAH->AH_DESCPO" + Chr(34) + "))</descricao-unidade-medida-comercial>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_01>" + Chr(34) + "SYD" + Chr(34) + "</ALIAS_01>"+CHR(13)+CHR(10)
   cXML += "<ORDER_01>1</ORDER_01>"+CHR(13)+CHR(10)
   cXML += "<SEEK_01>xFilial(" + Chr(34) + "SYD" + Chr(34) + ")+Left(EWK->EWK_NCM,8)</SEEK_01>"+CHR(13)+CHR(10)
   cXML += "<descricao-unidade-medida-estatistica>AllTrim(Posicione(" + Chr(34) + "SAH" + Chr(34) + ",1,xFilial(" + Chr(34) + "SAH" + Chr(34) + ")+AvKey(SYD->YD_UNID," + Chr(34) + "AH_UNIMED" + Chr(34) + ")," + Chr(34) + "SAH->AH_DESCPO" + Chr(34) + "))</descricao-unidade-medida-estatistica>"+CHR(13)+CHR(10)
   cXML += "<IF_15 COND = " + Chr(34) + "!Empty(EWK->EWK_NALADI)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<naladi>AllTrim(EWK->EWK_NALADI)</naladi>"+CHR(13)+CHR(10)
   cXML += "<descricao-naladi>AllTrim(Posicione(" + Chr(34) + "SJ1" + Chr(34) + ",1,xFilial(" + Chr(34) + "SJ1" + Chr(34) + ")+AvKey(EWK->EWK_NALADI," + Chr(34) + "J1_CODIGO" + Chr(34) + ")," + Chr(34) + "J1_DESC" + Chr(34) + "))</descricao-naladi>"+CHR(13)+CHR(10)
   cXML += "</IF_15>"+CHR(13)+CHR(10)
   cXML += "<prazo-pagamento>AllTrim(Str(EWK->EWK_PRAZO))</prazo-pagamento>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_01>" + Chr(34) + "EWL" + Chr(34) + "</ALIAS_01>"+CHR(13)+CHR(10)
   cXML += "<ORDER_01>1</ORDER_01>"+CHR(13)+CHR(10)
   cXML += "<SEEK_01>xFilial(" + Chr(34) + "EWL" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_01>"+CHR(13)+CHR(10)
   cXML += "<CMD_01>nVlrVenda := 0</CMD_01>"+CHR(13)+CHR(10)
   cXML += "<CMD_02>nLocEmbar := 0</CMD_02>"+CHR(13)+CHR(10)
   cXML += "<CMD_03>nQtdMedCom := 0</CMD_03>"+CHR(13)+CHR(10)
   cXML += "<CMD_04>nQtdMedEst := 0</CMD_04>"+CHR(13)+CHR(10)
   cXML += "<CMD_05>nQtdkgLiq := 0</CMD_05>"+CHR(13)+CHR(10)

   /*LGS-12/03/2014 - Incluido validacao do EWL_MUNICO para validar se o item deve ser montado na TAG <item-mercadoria> ou <item-mercadoria-unico>
                      Se nao tiver o campo no dicionario de dados o sistema segue montando o item na TAG <item-mercadoria> como é feito.*/
   cXML += "<IF_21 COND = " + Chr(34) + "EWL->(FIELDPOS('EWL_MUNICO')) == 0" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWL->(EWL_FILIAL+EWL_ID+EWL_SEQRE) == xFilial('EWL')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "<seq-item-re>AllTrim(EWL->EWL_SEQITE)</seq-item-re>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(TransForm(EWL->EWL_VLVEND," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(TransForm(EWL->EWL_VLFOB," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(TransForm(EWL->EWL_QTD," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(TransForm(EWL->EWL_QTDNCM," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(TransForm(EWL->EWL_PESO," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "<CMD_01>nVlrVenda += EWL->EWL_VLVEND</CMD_01>"+CHR(13)+CHR(10)
   cXML += "<CMD_02>nLocEmbar += EWL->EWL_VLFOB</CMD_02>"+CHR(13)+CHR(10)
   cXML += "<CMD_03>nQtdMedCom += EWL->EWL_QTD</CMD_03>"+CHR(13)+CHR(10)
   cXML += "<CMD_04>nQtdMedEst += EWL->EWL_QTDNCM</CMD_04>"+CHR(13)+CHR(10)
   cXML += "<CMD_05>nQtdkgLiq += EWL->EWL_PESO</CMD_05>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWL" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</IF_21>"+CHR(13)+CHR(10)
   
   cXML += "<IF_22 COND = " + Chr(34) + "EWL->(FIELDPOS('EWL_MUNICO')) > 0" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWL->(EWL_FILIAL+EWL_ID+EWL_SEQRE) == xFilial('EWL')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<IF_23 COND = " + Chr(34) + "EWL->EWL_MUNICO == 1" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "<seq-item-re>AllTrim(EWL->EWL_SEQITE)</seq-item-re>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(TransForm(EWL->EWL_VLVEND," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(TransForm(EWL->EWL_VLFOB," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(TransForm(EWL->EWL_QTD," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(TransForm(EWL->EWL_QTDNCM," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(TransForm(EWL->EWL_PESO," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "<CMD_01>nVlrVenda += EWL->EWL_VLVEND</CMD_01>"+CHR(13)+CHR(10)
   cXML += "<CMD_02>nLocEmbar += EWL->EWL_VLFOB</CMD_02>"+CHR(13)+CHR(10)
   cXML += "<CMD_03>nQtdMedCom += EWL->EWL_QTD</CMD_03>"+CHR(13)+CHR(10)
   cXML += "<CMD_04>nQtdMedEst += EWL->EWL_QTDNCM</CMD_04>"+CHR(13)+CHR(10)
   cXML += "<CMD_05>nQtdkgLiq += EWL->EWL_PESO</CMD_05>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria>"+CHR(13)+CHR(10)
   cXML += "</IF_23>"+CHR(13)+CHR(10)
   cXML += "<IF_24 COND = " + Chr(34) + "EWL->EWL_MUNICO == 2" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<item-mercadoria-unico>"+CHR(13)+CHR(10)
   cXML += "<seq-item-re>AllTrim(EWL->EWL_SEQITE)</seq-item-re>"+CHR(13)+CHR(10)
   cXML += "<descricao>AllTrim(EWL->EWL_DESCR)</descricao>"+CHR(13)+CHR(10)
   cXML += "<valor-condicao-venda>AllTrim(TransForm(EWL->EWL_VLVEND," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-condicao-venda>"+CHR(13)+CHR(10)
   cXML += "<valor-local-embarque>AllTrim(TransForm(EWL->EWL_VLFOB," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<quantidade-comercializada>AllTrim(TransForm(EWL->EWL_QTD," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-comercializada>"+CHR(13)+CHR(10)
   cXML += "<quantidade-estatistica>AllTrim(TransForm(EWL->EWL_QTDNCM," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade-estatistica>"+CHR(13)+CHR(10)
   cXML += "<numero-peso-liquido>AllTrim(TransForm(EWL->EWL_PESO," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</numero-peso-liquido>"+CHR(13)+CHR(10)
   cXML += "<CMD_01>nVlrVenda += EWL->EWL_VLVEND</CMD_01>"+CHR(13)+CHR(10)
   cXML += "<CMD_02>nLocEmbar += EWL->EWL_VLFOB</CMD_02>"+CHR(13)+CHR(10)
   cXML += "<CMD_03>nQtdMedCom += EWL->EWL_QTD</CMD_03>"+CHR(13)+CHR(10)
   cXML += "<CMD_04>nQtdMedEst += EWL->EWL_QTDNCM</CMD_04>"+CHR(13)+CHR(10)
   cXML += "<CMD_05>nQtdkgLiq += EWL->EWL_PESO</CMD_05>"+CHR(13)+CHR(10)
   cXML += "</item-mercadoria-unico>"+CHR(13)+CHR(10)
   cXML += "</IF_24>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWL" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</IF_22>"+CHR(13)+CHR(10)   
   
   cXML += "<valor-consolidado-condicao-venda-rel>AllTrim(TransForm(nVlrVenda," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-consolidado-condicao-venda-rel>"+CHR(13)+CHR(10)
   cXML += "<valor-consolidado-local-embarque-rel>AllTrim(TransForm(nLocEmbar," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-consolidado-local-embarque-rel>"+CHR(13)+CHR(10)
   cXML += "<valor-consolidado-qtd-comercializada-rel>AllTrim(TransForm(nQtdMedCom," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-consolidado-qtd-comercializada-rel>"+CHR(13)+CHR(10)
   cXML += "<valor-consolidado-qtd-estatistica-rel>AllTrim(TransForm(nQtdMedEst ," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-consolidado-qtd-estatistica-rel>"+CHR(13)+CHR(10)
   cXML += "<valor-consolidado-peso-liquido-rel>AllTrim(TransForm(nQtdkgLiq ," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-consolidado-peso-liquido-rel>"+CHR(13)+CHR(10)
   cXML += "<IF_16 COND = " + Chr(34) + "!Empty(EWK->EWK_PERCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<percentual-comissao-agente>AllTrim(TransForm(EWK->EWK_PERCOM," + Chr(34) + "@E 999.99" + Chr(34) + "))</percentual-comissao-agente>"+CHR(13)+CHR(10)
   cXML += "<valor-comissao-agente>AllTrim(TransForm((EWK->EWK_PERCOM*nVlrVenda)," + Chr(34) + "@E 999,999,999,999,999.99" + Chr(34) + "))</valor-comissao-agente>"+CHR(13)+CHR(10)
   cXML += "</IF_16>"+CHR(13)+CHR(10)
   cXML += "<IF_17 COND = " + Chr(34) + "!Empty(EWK->EWK_TIPCOM)" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<tipo-comissao>AllTrim(EWK->EWK_TIPCOM)</tipo-comissao>"+CHR(13)+CHR(10)
   cXML += "<descricao-tipo-comissao>AllTrim(BSCXBOX(" + Chr(34) + "EEC_TIPCOM" + Chr(34) + ",EWK->EWK_TIPCOM))</descricao-tipo-comissao>"+CHR(13)+CHR(10)
   cXML += "</IF_17>"+CHR(13)+CHR(10)
   cXML += "<categoria-cota>AllTrim(EWK->EWK_CATCOT)</categoria-cota>"+CHR(13)+CHR(10)  // GFP - 15/04/2014
   cXML += "<IF_18 COND = " + Chr(34) + "!Empty(If(EWK->(FieldPos('EWK_OBS'))==0,Msmm(EWK->EWK_CODOBS),EWK->EWK_OBS))" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<observacao>AllTrim(If(EWK->(FieldPos('EWK_OBS'))==0,Msmm(EWK->EWK_CODOBS),EWK->EWK_OBS))</observacao>"+CHR(13)+CHR(10)
   cXML += "</IF_18>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_02>" + Chr(34) + "EWM" + Chr(34) + "</ALIAS_02>"+CHR(13)+CHR(10)
   cXML += "<ORDER_02>1</ORDER_02>"+CHR(13)+CHR(10)
   cXML += "<SEEK_02>xFilial(" + Chr(34) + "EWM" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_02>"+CHR(13)+CHR(10)
   cXML += "<WHILE_02 COND = " + Chr(34) + "EWM->(EWM_FILIAL+EWM_ID+EWM_SEQRE) == xFilial('EWM')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<drawback>"+CHR(13)+CHR(10)
   cXML += "<IF_01 COND = " + Chr(34) + "Len(AllTrim(EWM->EWM_CNPJ))!=14" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cnpj>AllTrim(TransForm(EWM->EWM_CNPJ," + Chr(34) + "@R 999.999.999-99" + Chr(34) + "))</cnpj>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "Len(AllTrim(EWM->EWM_CNPJ))==14" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cnpj>AllTrim(TransForm(EWM->EWM_CNPJ," + Chr(34) + "@R 99.999.999/9999-99" + Chr(34) + "))</cnpj>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<ncm>AllTrim(EWM->EWM_NCM)</ncm>"+CHR(13)+CHR(10)
   cXML += "<ato-concessorio>AllTrim(EWM->EWM_ATO)</ato-concessorio>"+CHR(13)+CHR(10)
   cXML += "<item-ato-concessorio>AllTrim(EWM->EWM_SEQSIS)</item-ato-concessorio>"+CHR(13)+CHR(10)
   cXML += "<vl-moeda-re-com-cobertura-cambial>AllTrim(TransForm(EWM->EWM_VLCCOB," + Chr(34) + "@E 9,999,999,999,999.99" + Chr(34) + "))</vl-moeda-re-com-cobertura-cambial>"+CHR(13)+CHR(10)
   cXML += "<vl-moeda-re-sem-cobertura-cambial>AllTrim(TransForm(EWM->EWM_VLSCOB," + Chr(34) + "@E 9,999,999,999,999.99" + Chr(34) + "))</vl-moeda-re-sem-cobertura-cambial>"+CHR(13)+CHR(10)
   cXML += "<quantidade>AllTrim(TransForm(EWM->EWM_QTDE," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</quantidade>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_01>" + Chr(34) + "EWN" + Chr(34) + "</ALIAS_01>"+CHR(13)+CHR(10)
   cXML += "<ORDER_01>1</ORDER_01>"+CHR(13)+CHR(10)
   cXML += "<SEEK_01>xFilial(" + Chr(34) + "EWN" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)+EWM->EWM_SEQDB</SEEK_01>"+CHR(13)+CHR(10)
   cXML += "<WHILE_01 COND = " + Chr(34) + "EWN->(EWN_FILIAL+EWN_ID+EWN_SEQRE+EWN_SEQDB) == xFilial('EWM')+EWK->(EWK_ID+EWK_SEQRE)+EWM->EWM_SEQDB" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<nota-fiscal>"+CHR(13)+CHR(10)
   cXML += "<numero>AllTrim(EWN->EWN_NF)</numero>"+CHR(13)+CHR(10)
   cXML += "<data>AllTrim(DToC(EWN->EWN_DATA))</data>"+CHR(13)+CHR(10)
   cXML += "<quantidade-exportada>AllTrim(Str(EWN->EWN_QTD))</quantidade-exportada>"+CHR(13)+CHR(10)
   cXML += "<valor>AllTrim(Str(EWN->EWN_VALOR))</valor>"+CHR(13)+CHR(10)
   cXML += "</nota-fiscal>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWN" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_01>"+CHR(13)+CHR(10)
   cXML += "</drawback>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWM" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_02>"+CHR(13)+CHR(10)
   cXML += "<indicador-ccptc>" + Chr(34) + "N" + Chr(34) + "</indicador-ccptc>"+CHR(13)+CHR(10)
   cXML += "<indicador-insumo-ccptc>" + Chr(34) + "N" + Chr(34) + "</indicador-insumo-ccptc>"+CHR(13)+CHR(10)
   cXML += "<indicador-ccrom>" + Chr(34) + "N" + Chr(34) + "</indicador-ccrom>"+CHR(13)+CHR(10)
   cXML += "<ALIAS_03>" + Chr(34) + "EWO" + Chr(34) + "</ALIAS_03>"+CHR(13)+CHR(10)
   cXML += "<ORDER_03>1</ORDER_03>"+CHR(13)+CHR(10)
   cXML += "<SEEK_03>xFilial(" + Chr(34) + "EWO" + Chr(34) + ")+EWK->(EWK_ID+EWK_SEQRE)</SEEK_03>"+CHR(13)+CHR(10)
   cXML += "<WHILE_03 COND = " + Chr(34) + "EWO->(EWO_FILIAL+EWO_ID+EWO_SEQRE) == xFilial('EWO')+EWK->(EWK_ID+EWK_SEQRE)" + Chr(34) + " REPL = " + Chr(34) + "'1'" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<fabricante>"+CHR(13)+CHR(10)
   cXML += "<IF_01 COND = " + Chr(34) + "Len(AllTrim(EWO->EWO_CGC))!=14" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cpf-cnpj>AllTrim(TransForm(EWO->EWO_CGC," + Chr(34) + "@R 999.999.999-99" + Chr(34) + "))</cpf-cnpj>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "Len(AllTrim(EWO->EWO_CGC))==14" + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<cpf-cnpj>AllTrim(TransForm(EWO->EWO_CGC," + Chr(34) + "@R 99.999.999/9999-99" + Chr(34) + "))</cpf-cnpj>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<sigla-uf-fabric>AllTrim(EWO->EWO_UF)</sigla-uf-fabric>"+CHR(13)+CHR(10)
   cXML += "<qtd-estatistica-fabric>AllTrim(TransForm(EWO->EWO_QTD," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</qtd-estatistica-fabric>"+CHR(13)+CHR(10)
   cXML += "<peso-liquido-fabric>AllTrim(TransForm(EWO->EWO_PESO," + Chr(34) + "@E 999,999,999.99999" + Chr(34) + "))</peso-liquido-fabric>"+CHR(13)+CHR(10)
   cXML += "<valor-moeda-local-embarque>AllTrim(TransForm(EWO->EWO_VALOR," + Chr(34) + "@E 9,999,999,999,999.99" + Chr(34) + "))</valor-moeda-local-embarque>"+CHR(13)+CHR(10)
   cXML += "<obs-fabric>AllTrim(EWO->EWO_OBS)</obs-fabric>"+CHR(13)+CHR(10)
   cXML += "</fabricante>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWO" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE_03>"+CHR(13)+CHR(10)
   cXML += "</registro-exportacao>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<SKIP>" + Chr(34) + "EWK" + Chr(34) + "</SKIP>"+CHR(13)+CHR(10)
   cXML += "</WHILE>"+CHR(13)+CHR(10)
   cXML += "</lote>"+CHR(13)+CHR(10)
   cXML += "</XML>"+CHR(13)+CHR(10)
   cXML += "</DATA_SELECTION>"+CHR(13)+CHR(10)
   cXML += "<DATA_SEND>"+CHR(13)+CHR(10)
   cXML += "<IF_01 COND = " + Chr(34) + "lRelXML == .F." + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<CMD>EI300SaveXML(oINTSIS:cDirNotSent, cID, #TAG XML#,lRelXML)</CMD>"+CHR(13)+CHR(10)
   cXML += "</IF_01>"+CHR(13)+CHR(10)
   cXML += "<IF_02 COND = " + Chr(34) + "lRelXML == .T." + Chr(34) + ">"+CHR(13)+CHR(10)
   cXML += "<CMD>EI300SaveXML(oINTSIS:cDirRel, cID, #TAG XML#,lRelXML)</CMD>"+CHR(13)+CHR(10)
   cXML += "</IF_02>"+CHR(13)+CHR(10)
   cXML += "<SEND>" + Chr(34) + "" + Chr(34) + "</SEND>"+CHR(13)+CHR(10)
   cXML += "</DATA_SEND>"+CHR(13)+CHR(10)
   cXML += "<DATA_RECEIVE>"+CHR(13)+CHR(10)
   cXML += "<SRV_STATUS>.T.</SRV_STATUS>"+CHR(13)+CHR(10)
   cXML += "</DATA_RECEIVE>"+CHR(13)+CHR(10)
   cXML += "</SERVICE>"+CHR(13)+CHR(10)
   cXML += "</EASYLINK>"+CHR(13)+CHR(10)   
   
   FWrite(nHandler, cXML)
   FClose(nHandler)

End Sequence
  
Return 

Static Function CriaDirEasyLink()
Local cDiretorio := ""
Local cDir       := ""
Local nFol, nDir
Local aFolders   := { {"\comex","\easylink"},;
                      {"\comex","\easylink","\xml"},;
                      {"\comex","\easylink","\xml","\log"},;  
                      {"\comex","\easylink","\siscomex"},;
                      {"\comex","\easylink","\siscomex","\re"},;
                      {"\comex","\easylink","\siscomex","\re","\naoenviados"},;
                      {"\comex","\easylink","\siscomex","\re","\enviados"},;
                      {"\comex","\easylink","\siscomex","\re","\recebidos"},;
                      {"\comex","\easylink","\siscomex","\re","\processados"},;
                      {"\comex","\easylink","\siscomex","\re","\relatorio"},;
                      {"\comex","\easylink","\siscomex","\re","\recursos"},;
                      {"\comex","\easylink","\siscomex","\dde"},;
                      {"\comex","\easylink","\siscomex","\dde","\naoenviados"},;
                      {"\comex","\easylink","\siscomex","\dde","\enviados"},;
                      {"\comex","\easylink","\siscomex","\dde","\cancelados"}}

   For nFol := 1 to Len (aFolders) 
      cDiretorio := ""
      For nDir := 1 to Len(aFolders[nFol])
         If !lIsDir(cDiretorio + aFolders[nFol][nDir])
            If !(aFolders[nFol][nDir] $ cDir)
               cDir += '  ' +  cDiretorio + aFolders[nFol][nDir] + CHR(13) + CHR(10)
            endIf
            MakeDir(cDiretorio + aFolders[nFol][nDir])
         EndIf
         cDiretorio += aFolders[nFol][nDir]
      Next nDir
   Next nFol
                             
Return nil

/*
Funcao      : AtuEED ()
Parametros  : o
Retorno     : lRet
Objetivos   : Inclusão de dados de relacionamento entre os enquadramentos.
Autor       : Olliver Adami Pedroso
Data/Hora   : 19/01/2011
Revisao     : Bruno Akyo Kubagawa 
Data/Hora   : 11/08/2011
Obs.        : Retirado função do UENOVOEX
*/
Static Function AtuEED(o)

Local lRet := .T.
Local nInc, lInclui, nCont, aEED:= {}

Begin Sequence

   If (Select("EED") == 0 .And. !ChkFile("EED"))
      Break
   EndIf
   //        EED_FILIAL, EED_ENQCOD   , EED_DESC                                                                                                                                                                                                                                                                , EED_DESABI   , EED_CODVIN 
 AAdd(aEED, { "  "     , "80000"      , "EXPORTACAO NORMAL"                                                                                                                                                                                                                                                     , "1"          , "80000;80101;80102;80107;80111;80112;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80001"      , "REGISTRO SIMPLIFICADO"                                                                                                                                                                                                                                                 , "1"          , "80001;80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80101"      , "CONSUMO E USO A BORDO EM MOEDA ESTRANGEIRA"                                                                                                                                                                                                                            , "2"          , "90013"})
 AAdd(aEED, { "  "     , "80102"      , "EXPORTACAO EM CONSIGNACAO, EXCETO CAP. 6 A 8"                                                                                                                                                                                                                          , "2"          , ""})
 AAdd(aEED, { "  "     , "80103"      , "EXP. SUJEITA A LAUDO DE ANALISE -SEM RETENCAO"                                                                                                                                                                                                                         , "1"          , "80101;80102;80103;80104;80107;80111;80112;80114;80115;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80104"      , "EXP. COM MARGEM NAO SACADA"                                                                                                                                                                                                                                            , "2"          , ""})
 AAdd(aEED, { "  "     , "80106"      , "EXPORTACAO DE MATERIAL USADO EXCETO AS OPERACOES ENQUADRADAS NO CODIGO 80120"                                                                                                                                                                                          , "1"          , "80101;80102;80104;80106;80107;80111;80112;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80107"      , "DEPOSITO ALFANDEGADO CERTIFICADO - DAC"                                                                                                                                                                                                                                , "2"          , "81301;81501;81502;81503;90001;99132;"})
 AAdd(aEED, { "  "     , "80111"      , "VENDA NO MERCADO INTERNO A NAO RESIDENTE NO PAIS - CAPITULO 71 DA NCM - SOMENTE OS PRODUTOS MENCIONADOS EM PORTARIA ESPECIFICA DA SECEX"                                                                                                                               , "2"          , ""})
 AAdd(aEED, { "  "     , "80112"      , "PRODUTOS DO CAPITULO 71 DA NCM - VENDAS EM LOJAS FRANCAS A PASSAGEIROS COM DESTINO AO EXTERIOR"                                                                                                                                                                        , "2"          , ""})
 AAdd(aEED, { "  "     , "80113"      , "COTA HILTON-CARNE BOVINA 'IN NATURA' PARA UNIAO EUROPEIA."                                                                                                                                                                                                             , "1"          , "80101;80102;80104;80107;80111;80112;80113;80115;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;"})
 AAdd(aEED, { "  "     , "80114"      , "EXPORTACAO EM CONSIGNACAO EXCLUSIVAMENTE PARA OS CAPITULOS 6 A 8"                                                                                                                                                                                                      , "1"          , "80101;80102;80103;80104;80107;80111;80112;80114;80115;80140;80150;80160;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80115"      , "VENDA A PRAZO NO MERCADO INTERNO DO CAPITULO 71 DA NCM"                                                                                                                                                                                                                , "2"          , ""})
 AAdd(aEED, { "  "     , "80116"      , "SGP - SISTEMA GERAL DE PREFERENCIA"                                                                                                                                                                                                                                    , "1"          , "80101;80102;80104;80107;80111;80112;80115;80116;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80117"      , "DEVOLUCAO ANTES DA DI -VEICULO(P.MF306/95)"                                                                                                                                                                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80117;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80118"      , "DEVOLUCAO ANTES DA DI -OUTRAS(P.MF306/95)"                                                                                                                                                                                                                             , "1"          , "80101;80102;80104;80107;80111;80112;80115;80118;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80119"      , "REGIME AUTOMOTIVO - PORT. MICT/MF1(05.01.96) E DECRETO N. 1761, DE 26.12.95"                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80119;80140;80150;80160;80190;81101;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80120"      , "EXPORTACAO DE MATERIAL NACIONALIZADO (IDENTIFICAR SE NOVO OU USADO)"                                                                                                                                                                                                   , "1"          , "80101;80102;80104;80107;80111;80112;80115;80120;80140;80150;80160;80190;81101;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80130"      , "MEDIDA PROVISORIA N.1990-28(ART.17)E INSTRUCAO NORMATIVA N.017, DE 16.02.2000, DA SRF"                                                                                                                                                                                 , "1"          , "80101;80102;80104;80107;80111;80112;80115;80130;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;"})
 AAdd(aEED, { "  "     , "80140"      , "REPETRO-EXPORTACAO COM COBERTURA CAMBIAL"                                                                                                                                                                                                                              , "2"          , ""})
 AAdd(aEED, { "  "     , "80150"      , "VENDA COM PAGAMENTO EM MOEDA ESTRANGEIRA DE LIVRE CONVERSIBILIDADE REALIZADA A EMPRESA SEDIADA NO EXTERIOR, PARA SER TOTALMENTE INCORPORADO, NO TERRITORIO NACIONAL, A PRODUTO FINAL EXPORTADO PARA O BRASIL - LEI 9826, ARTIGO 6,  INCISO 'II'"                       , "2"          , ""})
 AAdd(aEED, { "  "     , "80160"      , "VENDA COM PAGAMENTO EM MOEDA ESTRANGEIRA DE LIVRE CONVERSIBILIDADE REALIZADA A ORGAO OU ENTIDADE DE GOVERNO ESTRANGEIRO OU ORGANISMO INTERNACIONAL DE QUE O BRASIL SEJA MEMBRO, PARA SER ENTREGUE, NO PAIS, A ORDEM DO COMPRADOR - LEI 9826, ARTIGO 6, INCISO 'III'"   , "2"          , ""})
 AAdd(aEED, { "  "     , "80170"      , "EXPORTAÇÃO DEFINITIVA DE BENS (NOVOS OU USADOS)QUE SAIRAM DO PAIS AO AMPARO DE REGISTRO DE EXPORTAÇÃO TEMPORÁRIA"                                                                                                                                                      , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80170;80190;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80180"      , "EXPORTACAO DE PRODUTOS ORGANICOS"                                                                                                                                                                                                                                      , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80180;80190;81101;81102;81103;81104;99121;"})
 AAdd(aEED, { "  "     , "80190"      , "ENERGIA ELETRICA"                                                                                                                                                                                                                                                      , "2"          , ""})
 AAdd(aEED, { "  "     , "80200"      , "COTA FRANGO - UNIAO EUROPEIA"                                                                                                                                                                                                                                          , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81101;81102;81103;81104;81600;81700;90003;99121;"})
 AAdd(aEED, { "  "     , "80280"      , "PRODUTO NAO GENETICAMENTE MODIFICADO, EXCLUSIVAMENTE PARA SOJA, MILHO E SEUS DERIVADOS"                                                                                                                                                                                , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;80280;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "80300"      , "COTA 30 - FRANGO UNIAO EUROPEIA"                                                                                                                                                                                                                                       , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;80300;81101;81102;81103;81104;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "81101"      , "DRAWBACK SUSPENSAO COMUM"                                                                                                                                                                                                                                              , "2"          , ""})
 AAdd(aEED, { "  "     , "81102"      , "DRAWBACK SUSPENSAO GENERICO"                                                                                                                                                                                                                                           , "2"          , ""})
 AAdd(aEED, { "  "     , "81103"      , "DRAWBACK SUSPENSAO INTERMEDIARIO"                                                                                                                                                                                                                                      , "2"          , ""})
 AAdd(aEED, { "  "     , "81104"      , "DRAWBACK SUSPENSAO SOLIDARIO"                                                                                                                                                                                                                                          , "2"          , ""})
 AAdd(aEED, { "  "     , "81301"      , "EXPORTACAO SUJEITA A REGISTRO DE VENDA"                                                                                                                                                                                                                                , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81301;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "81501"      , "PROEX/EQUALIZACAO (BANCO DO BRASIL)"                                                                                                                                                                                                                                   , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81501;81502;81503;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "81502"      , "PROEX/FINANCIAMENTO (BANCO DO BRASIL)"                                                                                                                                                                                                                                 , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81501;81502;81503;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "81503"      , "FINANCIAMENTO COM RECURSOS PROPRIOS(DECEX)"                                                                                                                                                                                                                            , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81501;81502;81503;81600;81700;99121;"})
 AAdd(aEED, { "  "     , "81600"      , "ENERGIA ELETRICA/POTENCIA"                                                                                                                                                                                                                                             , "2"          , ""})
 AAdd(aEED, { "  "     , "81700"      , "MERCADORIA OBJETO DE AUTORIZAÇÃO DE MOVIMENTAÇÃO DE BENS SUBMETIDOS AO RECOF(AMBRA), NA FORMA DA IN SRF 417 DE 20/04/2004"                                                                                                                                             , "2"          , ""})
 AAdd(aEED, { "  "     , "90001"      , "S/COBERTURA - EXPORTAÇÃO TEMPORÁRIA DE RECIPIENTE/EMBALAGEM REUTILIZÁVEIS"                                                                                                                                                                                             , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81600;81700;90001;99121;"})
 AAdd(aEED, { "  "     , "90002"      , "S/COBERTURA-EMPRESTIMO OU ALUGUEL"                                                                                                                                                                                                                                     , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90002;99121;"})
 AAdd(aEED, { "  "     , "90003"      , "S/COBERTURA-FEIRAS E EXPOSICOES"                                                                                                                                                                                                                                       , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;80200;81600;81700;90003;90009;99121;"})
 AAdd(aEED, { "  "     , "90005"      , "S/COB.MATERIAL A SER SUBMETIDO A CONSERTO, MANUTENCAO, REPARO,REVISAO OU INSPECAO(EXCETO AS OPERACOES ENQUADRADAS NO COD. 90115)"                                                                                                                                      , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90005;99121;"})
 AAdd(aEED, { "  "     , "90006"      , "S/COBERTURA-EXPORTACAO DE MATERIAS PRIMAS OU INSUMOS PARA FINS DE BENEFICIAMENTO OU TRANSFORMACAO -EXCETO O CODIGO 90014"                                                                                                                                              , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80180;80190;81600;81700;90006;99121;"})
 AAdd(aEED, { "  "     , "90007"      , "S/COBERTURA-MINERIOS E METAIS ENVIADOS PARA O EXTERIOR PARA FINS DE RECUPERACAO OU BENEFICIAMENTO"                                                                                                                                                                     , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90007;99121;"})
 AAdd(aEED, { "  "     , "90008"      , "90008 S/COBERTURA-ANIMAIS REPRODUTORES P/COBRICAO"                                                                                                                                                                                                                     , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81502;81600;81700;90008;99121;"})
 AAdd(aEED, { "  "     , "90009"      , "S/COBERTURA-EXPORTACAO DE OBRAS DE ARTE"                                                                                                                                                                                                                               , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90003;90009;99121;"})
 AAdd(aEED, { "  "     , "90010"      , "S/COBERTURA-EXPORTACAO DE MATERIAL DESTINADO A TESTES,EXAMES OU PESQUISAS COM FINALIDADE INDUSTRIAL OU CIENTIFICA"                                                                                                                                                     , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90010;99121;"})
 AAdd(aEED, { "  "     , "90011"      , "S/COBERTURA-ARRENDAMENTO OPERACIONAL - PRAZO > 360 DIAS - AMORTIZACAO < 75% - COM RETORNO"                                                                                                                                                                             , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90011;99121;"})
 AAdd(aEED, { "  "     , "90012"      , "S/COBERTURA-ARRENDAMENTO OPERACIOMAL - PRAZO ATE 360 DIAS - AMORTIZACAO <75% - COM RETORNO"                                                                                                                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90012;99121;"})
 AAdd(aEED, { "  "     , "90013"      , "EXPORTACAO DE FERRAMENTAS DESTINADAS AS ATIVIDADES DE MANUTENCAO E ASSISTENCIA TECNICA DE AERONAVES EXPORTADAS DE FABRICACAO NACIONAL ESTACIONADAS NO EXTERIOR"                                                                                                        , "1"          , "80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90013;99121;"})
 AAdd(aEED, { "  "     , "90014"      , "S/COBERTURA-EXPORTACAO DE MATERIAS-PRIMAS OU INSUMOS PARA FINS DE BENEFICIAMENTO OU TRANSFORMACAO -COMMODITIES AGRICOLAS"                                                                                                                                              , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90014;99121;"})
 AAdd(aEED, { "  "     , "90099"      , "OUTRAS EXPORTACOES S/COBERTURA COM RETORNO, NÃO ENQUADRADAS EM OUTROS COGIGOS(CITAR AMPARO LEGAL, SE HOUVER, OU JUSTIFICATIVA)"                                                                                                                                        , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90099;"})
 AAdd(aEED, { "  "     , "90115"      , "AERONAVE OU MATERIAL AERONAUTICO A SER SUBMETIDO A CONSERTO, MANUTENCAO, REPARO, REVISAO OU INSPECAO NO EXTERIOR"                                                                                                                                                      , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;90115;99121;"})
 AAdd(aEED, { "  "     , "99101"      , "S/COBERTURA-MERCADORIA PARA FINS DE DIVULGACAO COMERCIAL E TESTES NO EXTERIOR"                                                                                                                                                                                         , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99101;99121;"})
 AAdd(aEED, { "  "     , "99103"      , "S/COBERTURA-COMPLEMENTACAO(PESO/QUANTIDADE)"                                                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99103;99121;"})
 AAdd(aEED, { "  "     , "99104"      , "S/COBERTURA-DOACOES"                                                                                                                                                                                                                                                   , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99104;99121;"})
 AAdd(aEED, { "  "     , "99106"      , "S/COBERTURA-INDENIZACAO DE MERCADORIA SEM DEVOLUCAO DA EXPORTADA ORIGINALMENTE"                                                                                                                                                                                        , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99106;99121;"})
 AAdd(aEED, { "  "     , "99107"      , "S/COBERTURA-BENS DE HERANCA"                                                                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99107;99121;"})
 AAdd(aEED, { "  "     , "99108"      , "REEXPORTACAO DE MERCADORIA ADMITIDA TEMPORARIAMENTE - EXCETO AS OPERACOES ENQUADRADAS NO CODIGO 99123 E 99132"                                                                                                                                                         , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99108;99121;"})
 AAdd(aEED, { "  "     , "99109"      , "PARTES/PECAS DEST.REP.NAVIOS BAND.BRAS.EXT."                                                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99109;99121;"})
 AAdd(aEED, { "  "     , "99110"      , "S/COBERTURA-MATERIAL PARA MANUTENCAO DE ROTA DE VOO DE EMPRESA AEREA BRASILEIRA NO EXTERIOR"                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99110;99121;"})
 AAdd(aEED, { "  "     , "99111"      , "S/COBERTURA-SOBRESSALENTE (CONTRATO DE GARANTIA)"                                                                                                                                                                                                                      , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99111;99121;"})
 AAdd(aEED, { "  "     , "99112"      , "S/COBERTURA-INVESTIMENTO DE CAPITAL BRASILEIRO NO EXTERIOR"                                                                                                                                                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99103;99112;99121;"})
 AAdd(aEED, { "  "     , "99114"      , "INDENIZACAO EM MERCAD., COM DEV. DA EXPORTADA ORIGINALMENTE"                                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99114;99121;"})
 AAdd(aEED, { "  "     , "99115"      , "S/COBERTURA-COMBUSTIVEIS E OLEOS LUBRIFICANTES DESTINADOS A SUPRIR EVENTUAIS NECESSIDADES DE EMBARCACOES E AERONAVES DE EMPRESAS BRASILEIRAS QUE MANTENHAM LINHAS INTERNACIONAIS REGULARES"                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99115;99121;"})
 AAdd(aEED, { "  "     , "99116"      , "S/COBERTURA-FILMES CINEMATOGRAFICOS E VIDEO TEIPES NACIONAIS PARA EXIBICAO NO EXTERIOR A BASE DE 'ROYALTY'"                                                                                                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99116;99121;"})
 AAdd(aEED, { "  "     , "99121"      , "S/COB-CONSUMO E USO A BORDO-MOEDA NACIONAL, EXCLUSIVAMENTE EMBARCAçõES E AERONAVES DE BANDEIRA BRASILEIRA, DE TRáFEGO INTERNACIONAL"                                                                                                                                   , "2"          , ""})
 AAdd(aEED, { "  "     , "99122"      , "BRASILEIRA, DE TRáFEGO INTERNACIONAL"                                                                                                                                                                                                                                  , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99122;"})
 AAdd(aEED, { "  "     , "99123"      , "S/COB.REEXPORTACAO DE AERONAVES E/OU MATERIAL AERONAUTICO ADMITIDOS TEMPORARIAMENTE,INCLUSIVE P/ CONSERTO E REVISAO"                                                                                                                                                   , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99123;"})
 AAdd(aEED, { "  "     , "99124"      , "REEXP.DE MERCAD.ADM.ENTREP.ADUAN.,ENTREP.IND, DEA, DEP.AFIANCADO E DEP.ADUAN.DISTRIB"                                                                                                                                                                                  , "1"          , "80101;80102;80104;80107;80111;80112;80115;80118;80140;80150;80160;80190;81600;81700;99121;99124;"})
 AAdd(aEED, { "  "     , "99125"      , "S/COB.-DEV. ANTES DA DI-VEICULO(P.MF306/95)"                                                                                                                                                                                                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99125;"})
 AAdd(aEED, { "  "     , "99127"      , "S/COB.-DEV.ANTES DA DI - OUTRAS (P.MF306/95)"                                                                                                                                                                                                                          , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99127;"})
 AAdd(aEED, { "  "     , "99128"      , "S/COB - ARREND.FINANC.PZ>360D-AMORTIZ.>=75% S/RETORNO"                                                                                                                                                                                                                 , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99128;"})
 AAdd(aEED, { "  "     , "99129"      , "S/COB - ARREND.FINANC.PZ ATE 360D -AMORTIZ >= 75% - S/RETORNO"                                                                                                                                                                                                         , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99129;"})
 AAdd(aEED, { "  "     , "99130"      , "S/COBERTURA - MEDIDA PROVISORIA N.1990 -28(ART.17)E INSTRUCAO NORMATIVA N.017, DE 16.02.2000, DA SRF"                                                                                                                                                                  , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99130;"})
 AAdd(aEED, { "  "     , "99131"      , "EXPORTACAO DE PARTES, PECAS, COMPONENTES E ACESSORIOS, OBJETOS DE GARANTIA CONTRATUAL, DESTINADAS AS ATIVIDADES DE MANUTENCAO E ASSISTENCIA TECNICA DE AERONAVES EXPORTADAS DE FABRICACAO NACIONAL,ESTACIONADAS NO EXTERIOR"                                           , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99131;"})
 AAdd(aEED, { "  "     , "99132"      , "S/COBERTURA - REEXPORTAÇÃO DE RECIPIENTE/EMBALAGEM REUTILIZÁVEIS ADMITIDOS TEMPORARIAMENTE"                                                                                                                                                                            , "1"          , "80101;80102;80104;80111;80112;80115;80140;80150;80160;80190;81600;81700;90001;99121;99132;"})
 AAdd(aEED, { "  "     , "99199"      , "OUTRAS EXPORTACOES S/COBERTURA SEM RETORNO NÃO ENQUADRADAS EM OUTROS CODIGOS(CITAR AMPARO LEGAL,SE HOUVER)"                                                                                                                                                            , "1"          , "80101;80102;80104;80107;80111;80112;80115;80140;80150;80160;80190;81600;81700;99121;99199;"})


   EED->(DBSetOrder(1))
   For nInc:= 1 To Len(aEED)
      lInclui:= !EED->(DBSeek(xFilial("EED") + AvKey(aEED[nInc][2], "EED_ENQCOD")))
      EED->(RecLock("EED", lInclui))
      For nCont:= 1 To EED->(FCount())
         If nCont > Len(aEED[nInc])
            Exit
         EndIf
         If aEED[nInc][nCont] <> Nil
            EED->(FieldPut(nCont, aEED[nInc][nCont]))
         EndIf
      Next
      EED->(MsUnlock())
   Next

End Sequence

Return lRet

/*
Funcao      : AtualXMLEasyLink ()
Parametros  : 
Retorno     : lRet
Objetivos   : Verifica se o arquivo precisa ser atualizado
Autor       : wfs
Data/Hora   : 
Revisao     :  
Data/Hora   : 
Obs.        : 
*/
Static Function AtualXMLEasyLink(cArq)
Local aArq:= {} 
Local lRet:= .F.

Begin Sequence

	aArq:= Directory(cArq)

	//Data de corte
	If aArq[1][3] < StoD("20131204") .And. dDataBase >= StoD("20131204") 
		lRet:= .T.
		Break
	EndIf


End Sequence

Return lRet

*----------------------------------------*
Static Function EI300Lotes(cId)
*----------------------------------------*
Local oDlg, oBrowse
Local cPreemb := Space(AvSX3("EEC_PREEMB",3)) 
Local aCampos := {}
Local aSemSx3 := {}
Local nBotao
Private cMrcProc:=GetMark()
Private oMark2

	AADD(aSemSX3,{"WK_FLAG"   ,"C",2,0})
	AADD(aSemSX3,{"WK_PREEMB" ,AvSx3("EEC_PREEMB", AV_TIPO),AvSx3("EEC_PREEMB", AV_TAMANHO),AvSx3("EEC_PREEMB", AV_DECIMAL)})
	AADD(aSemSX3,{"WK_CNPJ"   ,AvSx3("EEX_CNPJ"  , AV_TIPO),AvSx3("EEX_CNPJ"  , AV_TAMANHO),AvSx3("EEX_CNPJ"  , AV_DECIMAL)})
	AADD(aSemSX3,{"WK_LOTE"   ,AvSx3("EWJ_ID"    , AV_TIPO),AvSx3("EWJ_ID"    , AV_TAMANHO),AvSx3("EWJ_ID"    , AV_DECIMAL)})
	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})
	cFileItens:=E_CriaTrab(,aSemSX3,"WkItemLote")
    //MFR 18/12/2018 OSSME-1974
	IndRegua("WkItemLote",cFileItens+TeOrdBagExt(),"WK_PREEMB+WK_LOTE")    
	AADD(aCampos,{"WK_FLAG",,"" ,})
	AADD(aCampos,{"WK_PREEMB",,AVSX3("EEC_PREEMB",5),AVSX3("EEC_PREEMB",6)})
	AADD(aCampos,{"WK_CNPJ"  ,,AVSX3("EEX_CNPJ"  ,5),AVSX3("EEX_CNPJ"  ,6)})
	AADD(aCampos,{"WK_LOTE"  ,,AVSX3("EWJ_ID"    ,5),AVSX3("EWJ_ID"    ,6)})
	
	EEX->( DbSetOrder(4) )
	EEX->(DbSeek(xFilial("EEX")+AvKey(cId,"EEX_ID") ))
	Do While EEX->(!Eof()) .And. EEX->EEX_ID == AvKey(cId,"EEX_ID")
	   WkItemLote->(DBAPPEND())
	   WkItemLote->WK_PREEMB := EEX->EEX_PREEMB
	   WkItemLote->WK_CNPJ   := EEX->EEX_CNPJ
	   WkItemLote->WK_LOTE   := EEX->EEX_ID
	   WkItemLote->WKRECNO   := RECNO()
	   EEX->(DbSkip())
	EndDo
	
	DEFINE MSDIALOG oDlg TITLE "Itens do lote de declaração de despacho" FROM 0,0 TO 277,578 OF oMainWnd PIXEL 
		WkItemLote->(DBGOTOP())
		oMark2:= MsSelect():New("WkItemLote","WK_FLAG","",aCampos,.F.,@cMrcProc,{0,0,0,0},,,oDlg)
		oMark2:bAval        :={|| EI300MkProc( WkItemLote->WKRECNO ) }
		oMark2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
		oDlg:lMaximized := .F.
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End(),nBotao:=5}, {|| oDlg:End() }) CENTERED
	
	If nBotao == 5
	   WkItemLote->(DBGOTOP())
	   Do While WkItemLote->(!Eof())
	      If !Empty(WkItemLote->WK_FLAG)
	         cPreemb := WkItemLote->WK_PREEMB
	         Exit
	      EndIf
	      WkItemLote->( DbSkip() )
	   EndDo
	EndIF
	
	WkItemLote->((E_EraseArq(cFileItens)))

Return cPreemb

*----------------------------------------*
Static Function EI300MkProc(nRec)
*----------------------------------------*
WkItemLote->( DbGoTo(nRec) )
If Empty(WkItemLote->WK_FLAG)
   WkItemLote->WK_FLAG:=@cMrcProc
Else
   WkItemLote->WK_FLAG:=""
EndIf

WkItemLote->(DBGOTOP())
Do While WkItemLote->(!Eof())
   If WkItemLote->WKRECNO <> nRec
      WkItemLote->WK_FLAG:=""
   EndIf
   WkItemLote->(DbSkip())
EndDo
WkItemLote->(DBGOTOP())
oMark2:oBrowse:Refresh()
Return .T.
