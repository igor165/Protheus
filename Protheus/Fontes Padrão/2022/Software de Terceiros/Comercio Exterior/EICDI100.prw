#Include "AVERAGE.CH"
#Include "APWizard.CH"
#Include "EEC.CH"
#Include "Protheus.CH"
#Include "FILEIO.CH"
#Include "FWBROWSE.CH"
#Include "EICDI100.CH"
#Include "TOPCONN.ch"

#Define ENTER CHR(13)+CHR(10)

//Serviços 
#Define INT_DI        "DI"
#Define INT_LI        "LI"
#Define INT_DSI       "DS"
//Status
#Define GERADOS       "GER"
#Define ENVIADOS      "ENV"
#Define PROCESSADOS   "PRO"
#Define CANCELADOS    "CAN"
//Ação INI
#Define ANALISE					"A"
#Define REGISTRO					"R"
#Define DI_CONSULTA				"G"
#Define ENVIO						"R"
#Define CONSULTA_ANUENCIA		"C"
#Define CONSULTA_DIAGNOSTICO	"D"

/*
Funcao     : EICDI100()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Central de Integração Siscomex WEB Importação
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:15
*/
*--------------------*
Function EICDI100()
*--------------------*
Private EICINTSISWEB
Private aItens := {}
Private cAcao := "", cLog := "", cNrTransmis := "", cIdLI := "", cNrTraDI := "", cNrDI := ""

AvlSX3Buffer(.T.)

If ChkFile("EV0") .AND. FindFunction("H_ADICAO_DI") .AND. FindFunction("H_CAPA_DI") .AND. FindFunction("H_LISISCOMEX")
   EICINTSISWEB := EICINTSISWEB():New(STR0001, STR0002, STR0003, STR0002, STR0003, STR0002)  //"Controle de Integrações Siscomex WEB Importação"  ## "Serviços"  ## "Ações"
   EICINTSISWEB:SetServicos()
   EICINTSISWEB:Show()
Else
   MsgStop(STR0004, STR0005)  // "Esse ambiente não está preparado para executar a nova rotina de integrações Siscomex WEB Importação." ## "Atenção"
EndIf

AvlSX3Buffer(.F.)

Return NIL

*---------------------------------*
Class EICINTSISWEB From AvObject
*---------------------------------*
    Data 	cName
    Data 	cSrvName
    Data 	cActName
    Data 	cTreeSrvName
    Data 	cTreeAcName
    Data 	cPanelName
    Data	cID
    Data 	bOk
    Data 	bCancel
    Data 	cIconSrv
    Data 	cIconAction
    
    Data	aServices
    Data	aCampos
    
    Data	aCposGerDI
    Data	aCposEnvDI
    Data	aCposProDI
    Data	aCposCanDI
    Data	aCposGerLI
    Data	aCposEnvLI
    Data	aCposProLI
    Data	aCposCanLI
    
    Data   cDirGerados
    Data   cDirEnviados
    Data   cDirProcessados
    Data   cDirCancelados
    Data   cDirUser
    Data   cDirJava
    Data   cPrxUrl
    Data   cPrxPrt
    Data   cPrxUsr
    Data   cPrxPss
    
    Data   oUserParams
    
    Data lErro
    
    Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Constructor
    Method GerarArq(cWork,cTipoInt)
    Method ProcessArq(cWork,cTipoInt)
    Method CancelarArq(cWork,cTipoInt)
    Method SetServicos()
    Method SetDiretorios()
    Method EditConfigs()
    Method CriarDir()
    Method Show()
    Method GeraINI(cAcao, cServico)
    Method GravaEV0(cArquivo, cServico, cStatus)
    Method GravaEVC(aValores, aErros)
    Method GravaSWP(aValores)
    Method GravaSW6(lErro)
    Method VisualReg(cWork,cTipoInt)  // GFP - 07/04/2015
    Method Imprimir(cWork,cTipoInt)   // GFP - 07/04/2015
   
End Class

/*
Método     : New()
Classe     : EICINTSISWEB
Parametros : cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction
Retorno    : Self
Objetivos  : Inicialização das variaveis
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:36
*/
*--------------------------------------------------------------------------------------------------------------------------------------*
Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Class EICINTSISWEB
*--------------------------------------------------------------------------------------------------------------------------------------*

   Self:cName			:= cName
   Self:cSrvName		:= cSrvName
   Self:cActName		:= cActName
   Self:cTreeSrvName	:= cTreeSrvName
   Self:cTreeAcName	:= cTreeAcName
   Self:cPanelName	:= cPanelName
   Self:bOk			   := bOk
   Self:bCancel		:= bCancel
   Self:cIconSrv		:= cIconSrv
   Self:cIconAction	:= cIconAction
   Self:cID          := ""
   Self:lErro        := .F.
   Self:oUserParams	:= EASYUSERCFG():New("EICDI100")
   Self:cDirUser     := If(!Empty(Self:oUserParams:LoadParam("DIRLOCAL","","EICDI100")),Self:oUserParams:LoadParam("DIRLOCAL"), GetTempPath(.T.))
   Self:cDirJava     := If(!Empty(Self:oUserParams:LoadParam("DIRTEMP","","EICDI100")),Self:oUserParams:LoadParam("DIRTEMP"), "")
   
   Self:cPrxUrl      := If(!Empty(Self:oUserParams:LoadParam("PROXYURL","","EICDI100")),Self:oUserParams:LoadParam("PROXYURL"), AllTrim(EasyGParam("MV_EIC0053",,"")))
   Self:cPrxPrt      := If(!Empty(Self:oUserParams:LoadParam("PROXYPRT","","EICDI100")),Self:oUserParams:LoadParam("PROXYPRT"), AllTrim(EasyGParam("MV_EIC0054",,"")))
   Self:cPrxUsr      := If(!Empty(Self:oUserParams:LoadParam("PROXYUSR","","EICDI100")),Self:oUserParams:LoadParam("PROXYUSR"), AllTrim(EasyGParam("MV_EIC0055",,"")))
   Self:cPrxPss      := If(!Empty(Self:oUserParams:LoadParam("PROXYPSS","","EICDI100")),Self:oUserParams:LoadParam("PROXYPSS"), AllTrim(EasyGParam("MV_EIC0056",,"")))
      
   Self:aServices 	:= {}
   Self:aCampos		:= {}
   
   Self:aCposGerDI   := {"EV0_ARQUIV", "EV0_USERGE", "EV0_DATAGE", "EV0_HORAGE" }
   Self:aCposEnvDI   := {"EV0_ARQUIV", "EV0_USEREN", "EV0_DATAEN", "EV0_HORAEN" }
   Self:aCposProDI   := {"EV0_ARQUIV", "EV0_USERPR", "EV0_DATAPR", "EV0_HORAPR" }
   Self:aCposCanDI   := {"EV0_ARQUIV", "EV0_USERCA", "EV0_DATACA", "EV0_HORACA" }
   
   Self:aCposGerLI   := {"EV0_ARQUIV", "EV0_USERGE", "EV0_DATAGE", "EV0_HORAGE" }
   Self:aCposEnvLI   := {"EV0_ARQUIV", "EV0_USEREN", "EV0_DATAEN", "EV0_HORAEN" }
   Self:aCposProLI   := {"EV0_ARQUIV", "EV0_USERPR", "EV0_DATAPR", "EV0_HORAPR" }
   Self:aCposCanLI   := {"EV0_ARQUIV", "EV0_USERCA", "EV0_DATACA", "EV0_HORACA" }

   Self:SetDiretorios()
   Self:CriarDir()

Return Self

/*
Método     : SetServicos()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Inicialização dos Serviços
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:36
*/
*------------------------------------------*
Method SetServicos() Class EICINTSISWEB
*------------------------------------------*
Local oSrvENV_DI, oSrvENV_LI
Local aSrvENV_DI  := {"RAIZ", INT_DI + GERADOS , INT_DI + PROCESSADOS, INT_DI + CANCELADOS}
Local aSrvTodos   := {"RAIZ", INT_DI + GERADOS , INT_DI + PROCESSADOS, INT_DI + CANCELADOS, INT_LI + GERADOS , INT_LI + PROCESSADOS, INT_LI + CANCELADOS, INT_DSI + GERADOS , INT_DSI + PROCESSADOS, INT_DSI + CANCELADOS}

//EVD_FILIAL+EVD_LOTE+EVD_PGI_NU+EVD_SEQLI
EVD->(DbSetOrder(2)) //LGS - 09/11/2015
EV1->(DbSetOrder(2)) //MCF - 06/11/2015

// Integração de DI
//oSrvEnv_DI := EECSISSRV():New(STR0006, "EV0", STR0007 , INT_DI ,1, "NORMAS", "NORMAS","EV0" ,STR0008)  //"Decl. de Importação (DI)"  ## "Lote" ## "Registros" 
oSrvEnv_DI := EECSISSRV():New(STR0006, "EV0", STR0007 , INT_DI ,1, "NORMAS", "NORMAS","EV1" ,STR0008,"EV1_FILIAL+EV1_LOTE","xFilial('EV1')+EV0_ARQUIV",,{"EV1_LOTE","EV1_HAWB"})  //"Decl. de Importação (DI)"  ## "Lote" ## "Registros"

// Folders da Integração de DI
oSrvENV_DI:AddFolder(STR0009  , GERADOS     , INT_DI + GERADOS     , Self:aCposGerDI,"Folder5","Folder6")  //"Gerados"
oSrvENV_DI:AddFolder(STR0011  , PROCESSADOS , INT_DI + PROCESSADOS , Self:aCposProDI,"Folder5","Folder6")  //"Processados"
oSrvENV_DI:AddFolder(STR0012  , CANCELADOS  , INT_DI + CANCELADOS  , Self:aCposCanDI,"Folder5","Folder6")  //"Cancelados"

//Ações da Integração de DI
oSrvENV_DI:AddAction(STR0013  , "Act011" , {"RAIZ",INT_DI + GERADOS , INT_LI + GERADOS, INT_DSI + GERADOS } , {|a,b| Self:GerarArq(a,b)}    , , "avg_iadd"   , "avg_iadd" )  //"Gerar arquivo"
oSrvENV_DI:AddAction(STR0015  , "Act013" , {"RAIZ",INT_DI + GERADOS , INT_LI + GERADOS, INT_DSI + GERADOS } , {|a,b| Self:ProcessArq(a,b)}  , , "avg_iproc"  , "avg_iproc" ) //"Processar arquivo"
oSrvENV_DI:AddAction(STR0016  , "Act014" , {"RAIZ",INT_DI + GERADOS , INT_LI + GERADOS, INT_DSI + GERADOS } , {|a,b| Self:CancelarArq(a,b)} , , "avg_idel"   , "avg_idel"  ) //"Cancelar arquivo"
oSrvENV_DI:AddAction(STR0037  , "Act015" , aSrvENV_DI                                                       , {||    Self:EditConfigs()}    , , "avg_iopt"   , "avg_iopt"  ) //"Configurações"     
oSrvENV_DI:AddAction(STR0096  , "Act016" , aSrvTodos                                                        , {|a,b| Self:VisualReg(a,b)}   , , "NOTE"       , "NOTE"      ) //"Visualizar Registro"
oSrvENV_DI:AddAction(STR0097  , "Act017" , aSrvTodos                                                        , {|a,b| Self:Imprimir(a,b)}    , , "PMSPRINT"   , "PMSPRINT"  ) //"Imprimir"

// Integração de LI
//oSrvEnv_LI := EECSISSRV():New(STR0042, "EV0" , STR0043 , INT_LI ,1, "NORMAS", "NORMAS","EV0" ,STR0044)  //"Lic. de Importação (LI)"  ## "Lote" ## "Registros"
oSrvEnv_LI := EECSISSRV():New(STR0042, "EV0" , STR0007 , INT_LI ,1, "NORMAS", "NORMAS","EVD" ,STR0008,"EVD_FILIAL+EVD_LOTE","xFilial('EVD')+EV0_ARQUIV",,{"EVD_LOTE","EVD_PGI_NU","EVD_SEQLI"})  //"Lic. de Importação (LI)"  ## "Lote" ## "Registros"  

// Folders da Integração de LI
oSrvEnv_LI:AddFolder(STR0009  , GERADOS     , INT_LI + GERADOS     , Self:aCposGerLI,"Folder5","Folder6")  //"Gerados"
oSrvEnv_LI:AddFolder(STR0011  , PROCESSADOS , INT_LI + PROCESSADOS , Self:aCposProLI,"Folder5","Folder6")  //"Processados"
oSrvEnv_LI:AddFolder(STR0012  , CANCELADOS  , INT_LI + CANCELADOS  , Self:aCposCanLI,"Folder5","Folder6")  //"Cancelados" 

// Integração de DSI
//oSrvENV_DSI := EECSISSRV():New(STR0116, "EV0" , STR0117, INT_DSI ,1, "NORMAS", "NORMAS","EV0" ,STR0044)  //"Decl. Simpl. de Importação (DSI)"  ##  "Declaração Simplificada de Importação"  ##  "Detalhe"
oSrvENV_DSI := EECSISSRV():New(STR0116, "EV0" , STR0117, INT_DSI ,1, "NORMAS", "NORMAS","EV1" ,STR0008,"EV1_FILIAL+EV1_LOTE","xFilial('EV1')+EV0_ARQUIV",,{"EV1_LOTE","EV1_HAWB"})  //"Decl. Simpl. de Importação (DSI)"  ##  "Declaração Simplificada de Importação"  ##  "Detalhe"

// Folders da Integração de LI
oSrvENV_DSI:AddFolder(STR0009  , GERADOS     , INT_DSI + GERADOS     , Self:aCposGerLI,"Folder5","Folder6")  //"Gerados"
oSrvENV_DSI:AddFolder(STR0011  , PROCESSADOS , INT_DSI + PROCESSADOS , Self:aCposProLI,"Folder5","Folder6")  //"Processados"
oSrvENV_DSI:AddFolder(STR0012  , CANCELADOS  , INT_DSI + CANCELADOS  , Self:aCposCanLI,"Folder5","Folder6")  //"Cancelados" 

// Adição de todos os serviços
aAdd(Self:aServices, oSrvENV_DI)
aAdd(Self:aServices, oSrvENV_LI)
aAdd(Self:aServices, oSrvENV_DSI)

Return NIL

/*
Método     : SetDiretorios()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Seleção de diretórios
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 26/01/2015 :: 11:29
*/
*-----------------------------------------*
Method SetDiretorios() Class EICINTSISWEB
*-----------------------------------------*

If IsSrvUnix()
   Self:cDirGerados     := "/comex/SiscomexWeb/gerados/"
   Self:cDirEnviados    := "/comex/SiscomexWeb/enviados/"
   Self:cDirProcessados := "/comex/SiscomexWeb/processados/"
   Self:cDirCancelados  := "/comex/SiscomexWeb/cancelados/"
Else
   Self:cDirGerados     := "\comex\SiscomexWeb\gerados\"
   Self:cDirEnviados    := "\comex\SiscomexWeb\enviados\"
   Self:cDirProcessados := "\comex\SiscomexWeb\processados\"
   Self:cDirCancelados  := "\comex\SiscomexWeb\cancelados\"
EndIf   

Return

/*
Método     : CriarDir()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Criação de diretórios
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 26/01/2015 :: 11:29
*/
*-------------------------------------*
Method CriarDir() Class EICINTSISWEB
*-------------------------------------*
Local cCaminho := "\SiscomexWeb\Aplicativo\SiscomexWeb\"
Local cServidor := "\comex\SiscomexWeb\"
Local cPastaUser := AllTrim(Upper(GetComputerName()))

Begin Sequence

   If ExistDir(cCaminho)
      If !ExistDir(cCaminho + cPastaUser)
         If MakeDir(cCaminho + cPastaUser) <> 0
            MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
            Break
         EndIf
      EndIf
      If !ExistDir(cCaminho + AllTrim(GetComputerName()) + "\Gerados")
         If MakeDir(cCaminho + AllTrim(GetComputerName()) + "\Gerados") <> 0
            MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
            Break
         EndIf
      EndIf
   EndIf
   If !ExistDir(cServidor)
      If MakeDir(cServidor) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(Self:cDirGerados)
      If MakeDir(Self:cDirGerados) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(Self:cDirEnviados)
      If MakeDir(Self:cDirEnviados) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(Self:cDirProcessados)
      If MakeDir(Self:cDirProcessados) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(Self:cDirProcessados+"\extrato_li")
      If MakeDir(Self:cDirProcessados+"\extrato_li") <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(Self:cDirCancelados)
      If MakeDir(Self:cDirCancelados) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf

End Sequence

Return

/*
Método     : EditConfigs()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Edição de configurações do usuario
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 05/02/2015 :: 08:15
*/
*-----------------------------------------*
Method EditConfigs() Class EICINTSISWEB
*-----------------------------------------*
Local nLin := 40, nCol := 12
Local lRet := .F.
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cDirTrans := Self:oUserParams:LoadParam("DIRLOCAL","","EICDI100") 
Local cDirJava  := Self:oUserParams:LoadParam("DIRTEMP","","EICDI100")
Local cPrxUrl   := If(!Empty(Self:oUserParams:LoadParam("PROXYURL","","EICDI100")),Self:oUserParams:LoadParam("PROXYURL"), AllTrim(EasyGParam("MV_EIC0053",,"")))
Local cPrxPrt   := If(!Empty(Self:oUserParams:LoadParam("PROXYPRT","","EICDI100")),Self:oUserParams:LoadParam("PROXYPRT"), AllTrim(EasyGParam("MV_EIC0054",,"")))
Local cPrxUsr   := If(!Empty(Self:oUserParams:LoadParam("PROXYUSR","","EICDI100")),Self:oUserParams:LoadParam("PROXYUSR"), AllTrim(EasyGParam("MV_EIC0055",,"")))
Local cPrxPss   := If(!Empty(Self:oUserParams:LoadParam("PROXYPSS","","EICDI100")),Self:oUserParams:LoadParam("PROXYPSS"), AllTrim(EasyGParam("MV_EIC0056",,"")))

Local bSetFileTra := {|| cDirTrans := cGetFile("",STR0040, 0, cDirTrans,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }  //"Diretório local para transmissão de arquivos"
Local bSetFileJav := {|| cDirJava  := cGetFile(,STR0041, 0, "\" ,.F., GETF_LOCALHARD,.T.) }  //"Diretório local onde encontra-se o executável 'Java.exe'."

   
   cPrxUrl := If(Empty(cPrxUrl), Space(100), cPrxUrl)
   cPrxPrt := If(Empty(cPrxPrt), Space(6)  , cPrxPrt)
   cPrxUsr := If(Empty(cPrxUsr), Space(50) , cPrxUsr)
   cPrxPss := If(Empty(cPrxPss), Space(50) , cPrxPss)
   
   DEFINE MSDIALOG oDlg TITLE STR0038 + cUserName FROM 320,400 TO 820,785 OF oMainWnd PIXEL  //"Configurações para o usuário: "

      @ nLin, 6 To 111, 181 Label STR0039 Of oDlg Pixel  //"Preferências"
      nLin += 10
      @ nLin,nCol Say STR0040 Size 160,08 PIXEL OF oDlg  //"Diretório local para transmissão de arquivos"
      nLin += 10
      @ nLin,nCol MsGet cDirTrans Size 150,08 PIXEL WHEN .F. OF oDlg
      @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileTra) SIZE 10,10 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0041 Size 160,08 PIXEL OF oDlg  //"Diretório local onde encontra-se o executável 'Java.exe'."
      nLin += 10
      @ nLin,nCol MsGet cDirJava Size 150,08 PIXEL WHEN .F. OF oDlg
      @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileJav) SIZE 10,10 PIXEL OF oDlg	

      nLin += 25
      @ nLin, 6 To 240, 181 Label STR0083 Of oDlg Pixel  //"Configurações de Proxy"
      nLin += 10
      @ nLin,nCol Say STR0084 Size 160,08 PIXEL OF oDlg  //"URL:"
      nLin += 10
      @ nLin,nCol MsGet cPrxUrl Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0085 Size 160,08 PIXEL OF oDlg  //"Porta:"
      nLin += 10
      @ nLin,nCol MsGet cPrxPrt Size 150,08 PIXEL OF oDlg
      
      nLin += 20
      @ nLin,nCol Say STR0086 Size 160,08 PIXEL OF oDlg  //"Usuário:"
      nLin += 10
      @ nLin,nCol MsGet cPrxUsr Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0087 Size 160,08 PIXEL OF oDlg  //"Senha:"
      nLin += 10
      @ nLin,nCol MsGet cPrxPss Size 150,08 PIXEL OF oDlg


   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      cDirTrans := iif(!Empty(cDirTrans) .AND. Right(cDirTrans,1,0) <> "\",cDirTrans+"\",cDirTrans)
      Self:oUserParams:SetParam("DIRLOCAL", If(!Empty(cDirTrans),cDirTrans,GetTempPath(.T.)),"EICDI100")
      Self:oUserParams:SetParam("DIRTEMP" , cDirJava ,"EICDI100")
      Self:oUserParams:SetParam("PROXYURL", If(!Empty(cDirTrans),cPrxUrl,AllTrim(EasyGParam("MV_EIC0053",,""))),"EICDI100")
      Self:oUserParams:SetParam("PROXYPRT", If(!Empty(cDirTrans),cPrxPrt,AllTrim(EasyGParam("MV_EIC0054",,""))),"EICDI100")
      Self:oUserParams:SetParam("PROXYUSR", If(!Empty(cDirTrans),cPrxUsr,AllTrim(EasyGParam("MV_EIC0055",,""))),"EICDI100")
      Self:oUserParams:SetParam("PROXYPSS", If(!Empty(cDirTrans),cPrxPss,AllTrim(EasyGParam("MV_EIC0056",,""))),"EICDI100")      
      
      Self:cDirUser := cDirTrans
      Self:cDirJava := cDirJava
      Self:cPrxUrl  := cPrxUrl
      Self:cPrxPrt  := cPrxPrt
      Self:cPrxUsr  := cPrxUsr
      Self:cPrxPss  := cPrxPss
   EndIf

Return Nil

/*
Método     : Show()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe Tela
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:53
*/
*-----------------------------------*
Method Show() Class EICINTSISWEB
*-----------------------------------*
Local aServicos := {}
Local aAcoes  := {}
Local nInc := 0

For nInc := 1 To Len(Self:aServices)
   aAdd(aServicos, Self:aServices[nInc]:RetService())
   aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
Next

DbSelectArea("EV0")
IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"FILTRO_EV0"),)
AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .T.,"{|cID| DI100VisDet(cID) }",,.F.)


Return NIL

/*
Método     : GerarArq()
Classe     : EICINTSISWEB
Parametros : Tipo de Integração
Retorno    : Nenhum
Objetivos  : Geração de arquivo XML para integração
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:57
*/
*--------------------------------------------*
Method GerarArq(cWork,cTipoInt) Class EICINTSISWEB
*--------------------------------------------*
Local bGeraArq := {|| GeracaoArq(@cArquivo,cServico)}
Local cArquivo := ""
Local cServico := /*If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS"))) //*/ Left(AllTrim(cTipoInt),2)

Begin Sequence

   //RMD - 16/07/19 - Possibilita a execução da consulta de DI mesmo que não tenha sido registrada pelo Sistema (o envio será barrado de acordo com o parâmetro na tela da geração)
   /*If cServico == INT_DI .AND. !EasyGParam("MV_TEM_DI",,.F.)
      MsgInfo(STR0023, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DI' estiver habilitado." ## "Atenção"
      Return NIL
   Else*/If cServico == INT_DSI .AND. !EasyGParam("MV_TEM_DSI",,.F.)
      MsgInfo(STR0121, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DSI' estiver habilitado." ## "Atenção"
      Return NIL
   EndIf

   If !TelaGets(GERADOS,cServico)
      Break
   EndIf

   // Tratamento de geração de arquivo para integração
   Processa(bGeraArq, STR0019, STR0020, .T.) //"Geração de arquivo" ## "Gerando o arquivo para a integração..."

   If !Empty(cArquivo) .And. Valtype(cArquivo) == "C"
      Self:GravaEV0(cArquivo, cServico, GERADOS)
   Else
      MsgInfo(STR0017,STR0005)  //"Arquivo não pode ser gerado."  ## "Atenção"
   EndIf

End Sequence

Return NIL
/*
Método     : DI100VisDet()
Classe     : 
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Chama função para abrir o extrato da li
Autor      : Miguel Prado Gontijo - MPG
Data/Hora  : 19/03/2019
*/
Function DI100VisDet(cID)

if select("SWP") == 0
   chkfile("SWP")
endif

if valtype(cID) == "O" .and. cID:oBrowse:cAlias == "EVD" .and. SWP->( dbsetorder(1) , dbSeek( xfilial("SWP")+EVD->(EVD_PGI_NUM+EVD_SEQLI) ) ) //"WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI+WP_NR_MAQ"
   GI400PDF()
endif

Return .T.

/*
Método     : ProcessarArq()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Processamento de arquivo XML retornado
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/01/2015 :: 17:57
*/
*-------------------------------------------------*
Method ProcessArq(cWork,cTipoInt) Class EICINTSISWEB
*-------------------------------------------------*
Local cServico , cArquivo
Local cDirArquivo := Self:cDirUser
Local cIntegrador := "tr-sw-web-solution-siscomexweb.jar"
Local cCmd := "", cArqRet := "", i
Local lTransmite := .F., lRet := .F.
Local aArquivos := {}

Private aALLErros := {}

Begin Sequence

   if empty(self:cDirJava) .or. !file(self:cDirJava)
      aAllErros := {STR0143} //"O executável JAVA.EXE não foi encontrado no diretório configurado. Revise as configurações antes de prosseguir."
      Break
   endif

   cServico := Left(AllTrim(cTipoInt), 2)//If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS")))
   //RMD - 16/07/19 - Possibilita a execução da consulta de DI mesmo que não tenha sido registrada pelo Sistema (o envio será barrado de acordo com o parâmetro na tela da geração)
   /*If cServico == INT_DI .AND. !EasyGParam("MV_TEM_DI",,.F.)
      MsgInfo(STR0023, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DI' estiver habilitado." ## "Atenção"
      Return NIL
   Else*/If cServico == INT_DSI .AND. !EasyGParam("MV_TEM_DSI",,.F.)
      MsgInfo(STR0121, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DSI' estiver habilitado." ## "Atenção"
      Return NIL
   EndIf
   
   If cServico == "RAIZ"
      Break
   Else
      cArquivo := AllTrim((cWork)->EV0_ARQUIV)
      If Empty(cArquivo)
         Break
      EndIf
   EndIf
   
   If !MsgYesNo(STR0046 + cArquivo + STR0047,STR0005)  //"Deseja transmitir o lote XXXXXXXXXXX gerado?"  ##  "Atenção"
      Break
   EndIf
   
   EV0->(DbSetOrder(2))  //EV0_FILIAL+EV0_SERVIC+EV0_ARQUIV+EV0_STATUS
   EV0->(DbSeek(xFilial("EV0")+AvKey(cServico,"EV0_SERVIC")+AvKey(cArquivo,"EV0_ARQUIV")))
  
   If !ExistDir(cDirArquivo+"SiscomexWeb\")
      If MakeDir(cDirArquivo+"SiscomexWeb\") <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(cDirArquivo+"SiscomexWeb\"+GetComputerName())
      If MakeDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()) <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Gerado\")
      If MakeDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Gerado\") <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   If !ExistDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\")
      If MakeDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\") <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   //*** RMD - 22/05/18 - Cria o diretório e arquivo de configuração para a nova versão do integrador, a partir de Maio/2018
   If !ExistDir(cDirArquivo+"ConfiguracoesWeb\")
      If MakeDir(cDirArquivo+"ConfiguracoesWeb\") <> 0
         MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
         Break
      EndIf
   EndIf
   cBuffer := ''
   cBuffer += '[url-development]' + ENTER
   cBuffer += 'url=http://localhost:8089/' + ENTER
   cBuffer += '' + ENTER
   cBuffer += '[url-training]' + ENTER
   cBuffer += 'url=https://www1c.siscomex.receita.fazenda.gov.br/' + ENTER
   cBuffer += '' + ENTER
   cBuffer += '[url-production]' + ENTER
   cBuffer += 'url=https://www1c.siscomex.receita.fazenda.gov.br/' + ENTER
   cBuffer += '' + ENTER
   cBuffer += '##' + ENTER
   cBuffer += '## SOBREPOSICAO PARA CONFIGURAÇÃO DO TIMER' + ENTER
   cBuffer += '##' + ENTER
   cBuffer += '## Exemplo:' + ENTER
   cBuffer += '##' + ENTER
   cBuffer += '## [get-li]' + ENTER
   cBuffer += '## get-li.1 = { "afterSleep": 1000, "beforeSleep": 1000 }' + ENTER
   cBuffer += '## get-li.2 = { "afterSleep": 1000, "beforeSleep": 1000 }' + ENTER
   cBuffer += '##' + ENTER
   cBuffer += '' + ENTER
   cBuffer += '[get-li]' + ENTER
   cBuffer += 'get-li.1 = { "afterSleep": 1000, "beforeSleep": 1000 }' + ENTER
   cBuffer += 'get-li.3 = { "afterSleep": 1000, "beforeSleep": 1000 }' + ENTER

   If !File(cDirArquivo+"ConfiguracoesWeb\WebNavigation-SiscomexImportacao-Enviroment.ini")
      hFile := EasyCreateFile(cDirArquivo+"ConfiguracoesWeb\WebNavigation-SiscomexImportacao-Enviroment.ini")	
      If hFile == -1
         MsgInfo(STR0025 + " (" + cDirArquivo+"ConfiguracoesWeb\WebNavigation-SiscomexImportacao-Enviroment.ini" + ")",STR0005) //O arquivo não pode ser criado. ## "Atenção"
	   cArquivo := ""
	   Break
	EndIf
      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
	   MsgInfo(STR0026 + " (" + cDirArquivo+"ConfiguracoesWeb\WebNavigation-SiscomexImportacao-Enviroment.ini" + ")",STR0005) //O arquivo não pode ser gravado. ## "Atenção"
	   Break
	EndIf
	FClose(hFile)
   EndIf
     
   If File(GetClientDir()+cIntegrador)
      Do While .T.
         If AvCpyFile(GetClientDir()+cIntegrador,cDirArquivo+cIntegrador,,.F.)
            Exit
         EndIf
      EndDo
   Else
      MsgInfo(STR0049,STR0005)  //"Não foi possível localizar o integrador. Favor verificar." ## "Atenção"
      Break
   EndIf

   If File(Self:cDirGerados+cArquivo+"\"+cArquivo+".zip")
      Do While .T.
         If AvCpyFile(Self:cDirGerados+cArquivo+"\"+cArquivo+".zip",cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Gerado\"+cArquivo+".zip",,.F.)
            Exit
         EndIf
      EndDo
   Else
      MsgInfo(STR0048,STR0005)  //"Não foi possível localizar o arquivo de integração gerado."  ## "Atenção"
      Break
   EndIf
   
   If ExistDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\")
      aArquivos := {}
      aArquivos := directory(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.*") // aDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.*",aArquivos)
      If Len(aArquivos) # 0
         For i := 1 To Len(aArquivos)
            FErase(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\"+aArquivos[i][1])
         Next i
      EndIf
   EndIf
      
   Processa({|| lTransmite := Integra(cArquivo)},STR0052) //"Efetuando transmissão do arquivo solicitado..."
   If lTransmite
      If !ExistDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\")
         MsgInfo(STR0060,STR0005)  //"Não foi possível localizar a pasta de retorno de arquivos." ## "Atenção"
         Break
      EndIf
      
      aArquivos := {}
      aArquivos:= directory(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.ZIP") //aDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.ZIP",aArquivos)
      If Len(aArquivos) # 0
         For i := 1 To Len(aArquivos)
            If Upper(aArquivos[i][1]) == Upper(AllTrim(EV0->EV0_ARQUIV)+".zip")
               If AvCpyFile(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\"+aArquivos[i][1],EICINTSISWEB:cDirProcessados+aArquivos[i][1],,.T.)
                  EasyUnZip(aArquivos[i][1], /*GetSrvProfString("ROOTPATH","")+*/EICINTSISWEB:cDirProcessados, cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\",.F.)
                  Exit
               EndIf
            EndIf
         Next i
      EndIf
      cNumLI := ""
      aArquivos := {}
      cLog := ""
      aArquivos := directory(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.*") // aDir(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\*.*",aArquivos)
      If Len(aArquivos) # 0
         For i := 1 To Len(aArquivos)
            If Right(aArquivos[i][1],3) == "ZIP"
               If EasyUnZip(aArquivos[i][1], cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\", EICINTSISWEB:cDirProcessados,.F.)
                  cArqRet := EICINTSISWEB:cDirProcessados+Left(aArquivos[i][1],Len(aArquivos[i][1])-3)+"INI"
                  lRet := .F.
                  If File(cArqRet)
                     Processa({|| lRet := RetornoArq(cArqRet,cServico)},STR0053) //"Efetuando leitura do retorno do arquivo solicitado..."
                  EndIf
                  If lRet
                     if empty(cNumLI)
                        SWP->( dbsetorder(1) , dbSeek( xfilial("SWP")+EVD->(EVD_PGI_NUM+EVD_SEQLI)))
                        cNumLI := SWP->WP_REGIST + ".pdf"
                     endif
                     if file( EICINTSISWEB:cDirProcessados+cNumLI )
                        if file( EICINTSISWEB:cDirProcessados+"\extrato_li\"+ cNumLI )
                           FErase( EICINTSISWEB:cDirProcessados+"\extrato_li\"+ cNumLI )
                        endif
                        AvCpyFile( EICINTSISWEB:cDirProcessados + cNumLI , EICINTSISWEB:cDirProcessados+"\extrato_li\"+ cNumLI,,.T.)
                     endif
                  endif
               endif
            EndIf
            FErase(cDirArquivo+"SiscomexWeb\"+GetComputerName()+"\Retorno\"+aArquivos[i][1])
         Next i
      EndIf

      If lRet
         Self:GravaEV0(cArquivo, cServico, PROCESSADOS)
      EndIf
   Else
      MsgInfo(STR0051,STR0005)  //"Não foi possível efetuar a integração do arquivo selecionado."  ## "Atenção"
   EndIf

End Sequence

If len(aALLErros) > 0
   cAllError := ""
   for i := 1 to len(aALLErros)
      cAllError += aALLErros[i] + ENTER
   next
   EECView( cAllError )
endif

Return NIL

/*
Método     : CancelarArq()
Classe     : EICINTSISWEB
Parametros : Tipo de Integração
Retorno    : Nenhum
Objetivos  : Cancelamento de arquivo
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 04/02/2015 : 08:30
*/
*-----------------------------------------------*
Method CancelarArq(cWork,cTipoInt) Class EICINTSISWEB
*-----------------------------------------------*
Local cServico, cArquivo
Local aArquivos := {}, i

Begin Sequence
   
   cServico := Left(AllTrim(cTipoInt), 2)//If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS")))
   
   /*If cServico == INT_DI .AND. !EasyGParam("MV_TEM_DI",,.F.)
      MsgInfo(STR0023, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DI' estiver habilitado." ## "Atenção"
      Return NIL
   Else*/If cServico == INT_DSI .AND. !EasyGParam("MV_TEM_DSI",,.F.)
      MsgInfo(STR0121, STR0005)  //"Esta rotina está disponível apenas para cenários em que o parâmetro 'MV_TEM_DSI' estiver habilitado." ## "Atenção"
      Return NIL
   EndIf
   
   If cServico == "RAIZ"
      Break
   Else
      cArquivo := AllTrim((cWork)->EV0_ARQUIV)
      If Empty(cArquivo)
         Break
      EndIf
   EndIf
   
   If !MsgYesNo(STR0029,STR0005)  //"Confirma o cancelamento do arquivo?" ## "Atenção"
      Break
   EndIf
   If !ExistDir(Self:cDirGerados+AllTrim(cArquivo))
      MsgInfo(STR0062,STR0005)  //"Não foi possível localizar o arquivo solicitado para o cancelamento." ## "Atenção"
      Break
   EndIf
      
   aArquivos := {}
   aArquivos := directory(Self:cDirGerados+AllTrim(cArquivo)+"\*.*")  //aDir(Self:cDirGerados+AllTrim(cArquivo)+"\*.*",aArquivos)
   If Len(aArquivos) # 0
      For i := 1 To Len(aArquivos)
         Do While .T.
            If !ExistDir(Self:cDirCancelados+AllTrim(cArquivo))
               If MakeDir(Self:cDirCancelados+AllTrim(cArquivo)) <> 0
                  MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
                  Break
               EndIf
            EndIf
            If AvCpyFile(Self:cDirGerados+AllTrim(cArquivo)+"\"+aArquivos[i][1],Self:cDirCancelados+AllTrim(cArquivo)+"\"+aArquivos[i][1],,.T.)
               Exit
            EndIf
         EndDo
      Next i
      DirRemove(Self:cDirGerados+AllTrim(cArquivo))
   EndIf
   Self:GravaEV0(cArquivo, cServico, CANCELADOS)
End Sequence

Return NIL

/*
Método     : GravaEV0()
Classe     : EICINTSISWEB
Parametros : cArquivo - Arquivo XML, cServiço - Serviço, cStatus - Status de Operação
Retorno    : Nenhum
Objetivos  : Gravação da tabela EV0
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 28/01/2015 : 08:43
*/
*---------------------------------------------------------------*
Method GravaEV0(cArquivo, cServico, cStatus) Class EICINTSISWEB
*---------------------------------------------------------------*
Local lNew := .F.

Begin Sequence

   EV0->(DbSetOrder(2))  //EV0_FILIAL+EV0_SERVIC+EV0_ARQUIV+EV0_STATUS
   lNew := !EV0->(DbSeek(xFilial("EV0")+AvKey(cServico,"EV0_SERVIC")+AvKey(cArquivo,"EV0_ARQUIV")))

   If EV0->(RecLock("EV0",lNew))
      EV0->EV0_FILIAL := xFilial("EV0")
      EV0->EV0_SERVIC    := cServico
      EV0->EV0_STATUS    := cStatus
      EV0->EV0_ARQUIV    := Upper(cArquivo)
      
      If cStatus == GERADOS
         EV0->EV0_USERGE := cUserName
         EV0->EV0_DATAGE := dDataBase
         EV0->EV0_HORAGE := Time()
      ElseIf cStatus == PROCESSADOS
         EV0->EV0_USERPR := cUserName
         EV0->EV0_DATAPR := dDataBase
         EV0->EV0_HORAPR := Time()
         EV0->EV0_ERROS  := cLog
      Else // cStatus == CANCELADOS
         EV0->EV0_USERCA := cUserName
         EV0->EV0_DATACA := dDataBase
         EV0->EV0_HORACA := Time()
      EndIf
      EV0->(MsUnlock())
   EndIf
   IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GRAVA_EV0"),)
End Sequence

Return NIL

/*
Método     : GravaEVC()
Classe     : EICINTSISWEB
Parametros : aValores - Valores para gravação
Retorno    : Nenhum
Objetivos  : Gravação da tabela EVC dos processos de DI
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/02/2015 :: 11:19
*/
*----------------------------------------------------*
Method GravaEVC(aValores, aErros) Class EICINTSISWEB
*----------------------------------------------------*
Local lError := If(Len(aErros) # 0, .T., .F.)
Local nLoop := 1, i, cDI
Local lRet := .F., lExbMsgAlert := .F. 

if lError .and. !empty(FwX2Unico("EVC")) .and. EVC->(FieldPos('EVC_SEQ')) > 0
   nLoop := Len(aErros)
endif

Begin Sequence

   For i := 1 To nLoop
      If EVC->(RecLock("EVC",.T.))
         EVC->EVC_FILIAL	:=	xFilial("EVC")
         EVC->EVC_LOTE	:=	EV0->EV0_ARQUIV
         EVC->EVC_MOTIVO	:=	If(aScan(aValores, {|x| x[1] == "motivoTransmissao"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "motivoTransmissao"})][2],"")
         EVC->EVC_TRANSM	:=	If(aScan(aValores, {|x| x[1] == "numeroTransmissao"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "numeroTransmissao"})][2],"")
         EVC->EVC_PROTOC	:=	If(aScan(aValores, {|x| x[1] == "protocolo"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "protocolo"})][2],"")
         EVC->EVC_RETIFI	:=	If(aScan(aValores, {|x| x[1] == "retificacao"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "retificacao"})][2],"")
         EVC->EVC_STATUS	:=	If(aScan(aValores, {|x| x[1] == "status"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "status"})][2],"")
         EVC->EVC_TX_STA	:=	If(aScan(aValores, {|x| x[1] == "textoStatus"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "textoStatus"})][2],"")
         If Empty(EVC->EVC_TRANSM) .AND. !Empty(EVC->EVC_PROTOC)
            EVC->EVC_TRANSM	:= EVC->EVC_PROTOC
         EndIf
         EVC->EVC_HAWB  :=  If(aScan(aValores, {|x| x[1] == "processo"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "processo"})][2],"")
         If lError
            If (nPos := aScan(aValores, {|x| x[1] == "origem"})) <> 0 .AND. aValores[nPos][2] == "INI"
               EVC->EVC_MENSAG	:=	aErros[i][2]
            Else
               EVC->EVC_ADICAO	:=	aErros[i][1]
               EVC->EVC_MENSAG	:=	aErros[i][2]
               EVC->EVC_STAT_A	:=	aErros[i][3]
            EndIf
         Else
            cDI := If(aScan(aValores, {|x| x[1] == "numeroDI"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "numeroDI"})][2],"")
            cDI := STRTRAN(cDI, "/", "")
            cDI := STRTRAN(cDI, "-", "")
            If !Empty(cDI)
               EVC->EVC_DI_NUM	:=	cDI
            EndIf
         EndIf
         If EVC->EVC_STATUS == "07" .AND. Upper("Em Processamento") $ Upper(EVC->EVC_TX_STA)
            lError := .T.
         EndIf
         EVC->EVC_DATAPR	:=	If(aScan(aValores, {|x| x[1] == "dataProcessamento"}) <> 0, STOD(aValores[aScan(aValores, {|x| x[1] == "dataProcessamento"})][2]),CTOD(""))
         if EVC->(FieldPos('EVC_SEQ')) > 0
            EVC->EVC_SEQ := strZero(i, avSx3("EVC_SEQ",AV_TAMANHO) )
         endif
         EVC->(MsUnlock())
      EndIf
      lRet := .T.
   Next i

   If cAcao <> ANALISE
      EICINTSISWEB:GravaSW6(lError)
   EndIf
   If !lError
      //EECView(MontaMsg(1))
      cMontaMsg := MontaMsg(1)
      If aScan(aALLErros, cMontaMsg) == 0
         aadd( aALLErros , MontaMsg(1) )
      endif
   Else
      //EECView(MontaMsg(2))
      aadd( aALLErros , MontaMsg(2) )
      For i := 1 To Len(aErros)
         // Caso sejam exibidos apenas Mensagens de Alerta, o sistema pode registrar a DI, com o aval do usuario.
         If Len(aErros[i]) > 2 .AND. (aErros[i][3] == "C" .OR. aErros[i][3] == "M")  //AAF 01/02/2017 - Adicionada verificação para falha de integração, que é impeditiva.
            lExbMsgAlert := .T.
         Else
            lExbMsgAlert := .F.
            Exit
         EndIf
      Next i
      If cAcao == REGISTRO .AND. lExbMsgAlert
         If MsgNoYes(STR0127 + ENTER + STR0128,STR0005)  // "Todos as mensagens exibidas são 'Não Impeditivas' (Amarelo)." ## "Deseja prosseguir com o registro automático para os processos deste lote?" ## "Atenção"
            EV1->(DbSetOrder(2))
            EV1->(DbSeek(xFilial("EV1")+AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")))
            Do While EV1->(!Eof()) .AND. EV1->EV1_FILIAL == xFilial("EV1") .AND. EV1->EV1_LOTE == AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")
               If SW6->(DbSeek(xFilial("SW6")+EV1->EV1_HAWB))
                  If SW6->(Reclock("SW6",.F.))
                     SW6->W6_REGAL := "S"
                     SW6->(MsUnlock())
                  EndIf
               EndIf
               EV1->(DbSkip())
            EndDo
            MsgInfo(STR0129,STR0005)  // "Favor gerar um novo lote para o registro automático dos processos." ## "Atenção"
         EndIf
         lExbMsgAlert := .F.
      EndIf
   EndIf
   
   IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GRAVA_EVC"),)
End Sequence

Return lRet

/*
Método     : GravaSWP()
Classe     : EICINTSISWEB
Parametros : aValores - Valores para gravação
Retorno    : Nenhum
Objetivos  : Gravação das informações de Retorno da LI
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/02/2015 :: 11:19
*/
*--------------------------------------------------*
Method GravaSWP(aValores) Class EICINTSISWEB
*--------------------------------------------------*
Local cTipo := aValores[1]
Local lError := aValores[2]
Local aStat := {}
Local cChave := ""
Local i, lRet := .T.

if select("SX5") == 0 
   chkfile( "SX5" )
endif

Begin Sequence
   
   ChkFile("SWP")//ChkFile("SWP",.T.)
   cChave := AvKey(SubStr(aValores[4],1,Len(aValores[4])-Len(SWP->WP_SEQ_LI)),"WP_PGI_NUM") + AvKey(SubStr(aValores[4],Len(aValores[4])-(Len(SWP->WP_SEQ_LI)-1),Len(aValores[4])),"WP_SEQ_LI")
   
   SWP->(DbSetOrder(1))  //WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI+WP_NR_MAQ
   If !SWP->(DbSeek(xFilial("SWP")+cChave))
      lRet := .F.
      Break
   EndIf
   
   Do Case
      Case cTipo == ENVIO
         aStat := FWGetSX5( "W0" , aValores[6] )
         Begin Transaction
            If SWP->(RecLock("SWP",.F.))
                  SWP->WP_ARQ    := aValores[3]
                  SWP->WP_REGIST := aValores[5]
                  SWP->WP_CDSTA  := aValores[6]
                  SWP->WP_STAT   := aStat[1][4] //AllTrim(Posicione("SX5",1,xFilial("SX5")+"W0"+aValores[6],"X5_DESCRI")) 
                  SWP->WP_PROT   := aValores[7]
                  SWP->WP_TRANSM := CTOD(aValores[8])
                  SWP->WP_LOTE   := EV0->EV0_ARQUIV
                  SWP->WP_ERROS := alltrim(aValores[9])
                  SWP->WP_IDLI   := aValores[10]
                  SWP->(MsUnlock())
            EndIf
         End Transaction
      
      Case cTipo == CONSULTA_ANUENCIA
         aStat := FWGetSX5( "W0" , aValores[5]  )
         Begin Transaction
            If SWP->(RecLock("SWP",.F.))
               SWP->WP_REGIST := aValores[3]
               SWP->WP_CDSTA  := aValores[5]
               SWP->WP_STAT   := aStat[1][4] //AllTrim(Posicione("SX5",1,xFilial("SX5")+"W0"+aValores[5],"X5_DESCRI")) 
               SWP->WP_TRANSM := CTOD(aValores[6])
               SWP->WP_CANCEL := CTOD(aValores[7])
               SWP->WP_DTSITU := CTOD(aValores[8])
               SWP->WP_VENCTO := CTOD(aValores[9])
               SWP->WP_LOTE   := EV0->EV0_ARQUIV
               
               For i := 1 To Len(aValores[10])
                  cChave := xFilial("EIT")+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI+AvKey(aValores[10][i][1],"EIT_NUMERO")
                  //EIT_FILIAL+EIT_PGI_NU+EIT_SEQ_LI+EIT_NUMERO
                  If EIT->(RecLock("EIT",!EIT->(DbSetOrder(1),DbSeek(cChave))))
                     aStat := FWGetSX5( "W0" , aValores[10][i][4] )
                     EIT->EIT_FILIAL := xFilial("EIT")
                     EIT->EIT_PGI_NU := SWP->WP_PGI_NUM
                     EIT->EIT_SEQ_LI := SWP->WP_SEQ_LI
                     EIT->EIT_NUMERO := aValores[10][i][1]
                     EIT->EIT_ORGAO  := aValores[10][i][2]
                     EIT->EIT_TRATA  := aValores[10][i][3]
                     EIT->EIT_CDSTA  := aValores[10][i][4]
                     EIT->EIT_STAT   := aStat[1][4] //AllTrim(Posicione("SX5",1,xFilial("SX5")+"W0"+aValores[10][i][4],"X5_DESCRI"))
                     EIT->EIT_DTANU  := CTOD(aValores[10][i][5])
                     EIT->EIT_DTVAL  := CTOD(aValores[10][i][6])
                     EIT->EIT_TEXTO  := aValores[10][i][7]
                     EIT->(MsUnlock())
                  EndIf
               Next i
               SWP->WP_ERROS := alltrim(aValores[11])
               SWP->(MsUnlock())
            EndIf
         End Transaction

      Case cTipo == CONSULTA_DIAGNOSTICO

         If SWP->(RecLock("SWP",.F.))
            SWP->WP_CDSTA  := aValores[3]
            SWP->WP_STAT   := AllTrim(Posicione("SX5",1,xFilial("SX5")+"W0"+aValores[3],"X5_DESCRI")) 
            SWP->WP_PROT   := aValores[5]
            SWP->WP_REGIST := aValores[6]
            SWP->WP_TRANSM := CTOD(aValores[7])
            SWP->WP_LOTE   := EV0->EV0_ARQUIV
            If lError
               SWP->WP_ERROS := aValores[8]
            EndIf         
            SWP->(MsUnlock())
         EndIf

   End Case
   IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GRAVA_SWP"),)
End Sequence

If !lRet
   MsgInfo(STR0074,STR0005)  //"Erro na gravação das informações de retorno." ## "Atenção"
Else
   aAreaSWP := SWP->(getarea())
   If !lError
      //EECView(MontaMsg(3))
      aadd( aALLErros , MontaMsg(3) )
   Else
      //EECView(MontaMsg(4))
      aadd( aALLErros , MontaMsg(4) )
      lRet := .F.
   EndIf
   restarea(aAreaSWP)
EndIf

Return lRet

/*
Método     : GravaSW6()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Atualização das informações na tabela SW6
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/02/2015 :: 14:18
*/
*-------------------------------------*
Method GravaSW6(lError, lEVC, aValores) Class EICINTSISWEB
*-------------------------------------*
Private cURFDesp, cTxSitDesp, cFiscal
Default lEVC := .T.

If lEVC
EV1->(DbSetOrder(2))
EV1->(DbSeek(xFilial("EV1")+AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")))
Do While EV1->(!Eof()) .AND. EV1->EV1_FILIAL == xFilial("EV1") .AND. EV1->EV1_LOTE == AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")
   If !lError
      If EV1->(Reclock("EV1",.F.))
         EV1->EV1_DI_NUM := EVC->EVC_DI_NUM
         EV1->(MsUnlock())
      EndIf
   EndIf   
   SW6->(DbSeek(xFilial("SW6")+EV1->EV1_HAWB))
   If SW6->(Reclock("SW6",.F.))
      If !lError
         If SW6->W6_CURRIER == "1"
            SW6->W6_DIRE  := EVC->EVC_DI_NUM
         Else
            SW6->W6_DI_NUM  := EVC->EVC_DI_NUM
         EndIf
         SW6->W6_DTREG_D := EVC->EVC_DATAPR
      EndIf
      SW6->W6_IDLOTE  := EV0->EV0_ARQUIV
      SW6->(MsUnlock())
   EndIf
   
   EV1->(DbSkip())
EndDo
Else
   EV1->(DbSetOrder(2))
   If aScan(aValores, {|x| x[1] == "processo"}) <> 0
      EV1->(DbSeek(xFilial("EV1")+AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")+AvKey(aValores[aScan(aValores, {|x| x[1] == "processo"})][2], "EV1_HAWB")))
      While EV1->(!Eof() .And. EV1_FILIAL+EV1_LOTE+EV1_HAWB == xFilial("EV1")+AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")+AvKey(aValores[aScan(aValores, {|x| x[1] == "processo"})][2], "EV1_HAWB"))
         If EV1->(FieldPos("EV1_FILORI")) == 0 .Or. aScan(aValores, {|x| x[1] == "filial"}) == 0 .Or. EV1->EV1_FILORI == AvKey(aValores[aScan(aValores, {|x| x[1] == "filial"})][2], "EV1_FILORI")
            If SW6->(DbSeek(If(EV1->(FieldPos("EV1_FILORI")) > 0 .And. !Empty(EV1->EV1_FILORI), EV1->EV1_FILORI, xFilial("SW6"))+EV1->EV1_HAWB))
               cMsg := ""
               If Len(aAllErros) == 0
                  cMsg += "======= " + STR0057 + " =======" + ENTER  //"Os processos abaixo foram atualizados: "
                  cMsg += ENTER
               EndIf
               cMsg += STR0058 + SW6->W6_HAWB   + ENTER	//"Processo: "
               RegToMemory("SW6", .F., .F., .F.)
               SW6->(RecLock("SW6", .F.))
               If Empty(If(SW6->W6_CURRIER == "1", SW6->W6_DIRE, SW6->W6_DI_NUM))
                  If SW6->W6_CURRIER == "1"
                     SW6->W6_DIRE  := StrTran(StrTran(If(aScan(aValores, {|x| x[1] == "numeroDI"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "numeroDI"})][2],""), "/", ""), "-", "")
                  Else
                     SW6->W6_DI_NUM  := StrTran(StrTran(If(aScan(aValores, {|x| x[1] == "numeroDI"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "numeroDI"})][2],""), "/", ""), "-", "")
                  EndIf
                  SW6->W6_DTREG_D := If(aScan(aValores, {|x| x[1] == "dataProcessamento"}) <> 0, STOD(aValores[aScan(aValores, {|x| x[1] == "dataProcessamento"})][2]),CTOD(""))
               EndIf
               cMsg += If(EV0->EV0_SERVIC == INT_DI,STR0059,STR0118) + Transform(If(SW6->W6_CURRIER == "1",SW6->W6_DIRE,SW6->W6_DI_NUM),AvSX3("W6_DI_NUM",6)) + ENTER	//"Número DI: " ## "Número DSI: "
               If aScan(aValores, {|x| x[1] == "canal"}) <> 0//RMD - 30/10/19 - Confirma se o canal foi retornado antes de atualizar
                  SW6->W6_CANAL := RetCodCanal(aValores[aScan(aValores, {|x| x[1] == "canal"})][2])
                  cMsg += "Canal: " + aValores[aScan(aValores, {|x| x[1] == "canal"})][2] + ENTER
               EndIf
               If !Empty(cURFDesp := If(aScan(aValores, {|x| x[1] == "urf_despacho"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "urf_despacho"})][2],""))
                  cMsg += "URF Despacho: " + cURFDesp + ENTER
               EndIf
               If !Empty(cTxSitDesp := If(aScan(aValores, {|x| x[1] == "texto_sit_desp"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "texto_sit_desp"})][2],""))
                  cMsg += "Situação do Despacho: " + cTxSitDesp + ENTER
               EndIf
               If !Empty(cFiscal := If(aScan(aValores, {|x| x[1] == "fiscal_responsavel"}) <> 0, aValores[aScan(aValores, {|x| x[1] == "fiscal_responsavel"})][2],""))
                  cMsg += "Fiscal Responsável: " + cFiscal + ENTER
               EndIf
               SW6->(MsUnlock())
               aadd( aALLErros , cMsg)
            EndIf
         EndIf
         EV1->(DbSkip())
      EndDo
   EndIf
EndIf
IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GRAVA_SW6"),)
Return NIL

Static Function RetCodCanal(cCanal)
Local cCod := ""

   cCanal := Upper(cCanal)

   Do Case
      Case cCanal == "VERMELHO"
         cCod := "1"
      Case cCanal == "AMARELO"
         cCod := "2"
      Case cCanal == "VERDE"
         cCod := "3"
      Case cCanal == "CINZA"
         cCod := "4"
   End Case

Return cCod


/*
Função      : TelaGets()
Parametros  : Nenhum
Retorno     : lRet - .T./.F.
Objetivos   : Montagem de seleção de embarques 
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/01/2015 :: 11:05
*/
*----------------------------------------*
Static Function TelaGets(cTipo,cServico)
*----------------------------------------*
Local oDlg, oBrowse, oColumn, oSay1, oTotPanel, oBtAnalise, oBtIntegra, oEnvio, oBtCAnue, oBtCDiag, oBtDiagDI
Local cAlias := If(cServico == INT_DI .OR. cServico == INT_DSI, "SW6",If(cServico == INT_LI, "SW4","SW6"))
Local aCampos     := {}
Local bOk         := {|| nOpca := 1,oDlg:End()}
Local bCancel     := {|| aItens := {},lRet := .F.,oDlg:End()}
Local bMarca   
Local bMarcaTodos := {|oBrowse| If(!Empty(aItens),aItens:={},aItens := MarkAllItens(cServico,cAcao)),oBrowse:Refresh(.T.)}
Local nInc, nPos, nOpca := 0
Local lRet := .T.
Local aIndices := {}
Local lConsulta := .T. // If(cServico == INT_LI, MsgYesNo("Deseja consultar status de LIs já integradas?", "Aviso"), .F.) //RMD - 08/12/17 - Se estiver na pasta de Enviados considera que vai consultar o status da LI
Local lW6_TRANSMIS := SW6->(FieldPos("W6_TRANSM")) > 0
Private cQuery := ""

Begin Sequence
   cAcao := ""
   If cServico == INT_DI .OR. cServico == INT_DSI

      DEFINE MSDIALOG oDlg TITLE STR0030 FROM 0,0 TO 9,45  // "Ação"

         @ 8,8 SAY STR0031 PIXEL  //"Qual ação você deseja executar?"

         @ 2.5,2  BUTTON oBtAnalise PROMPT STR0032 SIZE 55,13 When EasyGParam("MV_TEM_DI",,.F.)/*RMD - 16/07/19*/ ACTION (cAcao := ANALISE, oDlg:End())   //"Análise"
      
         @ 2.5,16 BUTTON oBtIntegra PROMPT STR0034 SIZE 55,13 When EasyGParam("MV_TEM_DI",,.F.)/*RMD - 16/07/19*/ ACTION (cAcao := REGISTRO, oDlg:End())  //"Registro"
         
         @ 2.5,30 BUTTON oBtDiagDI  PROMPT STR0095 SIZE 55,13 ACTION (cAcao := DI_CONSULTA, oDlg:End())  //"Consulta"     
      
         oBtAnalise:cToolTip := STR0033  //"Análise de arquivo"
         oBtIntegra:cToolTip := STR0035  //"Registro de arquivo"
         oBtDiagDI:cToolTip :=  STR0094  //"Consulta de Procotolo" 

      ACTIVATE MSDIALOG oDlg CENTERED

   ElseIf cServico == INT_LI

      DEFINE MSDIALOG oDlg TITLE STR0030 FROM 0,0 TO 9,32  // "Ação"

         @ 8,8 SAY STR0031 PIXEL  //"Qual ação você deseja executar?"

         @ 2.5,2  BUTTON oBtEnvio PROMPT STR0067 SIZE 55,13 ACTION (cAcao := ENVIO, oDlg:End()) WHEN .t.  // !lConsulta  //"Envio"
      
         @ 2.5,16 BUTTON oBtCAnue PROMPT STR0068 SIZE 55,13 ACTION (cAcao := CONSULTA_ANUENCIA, oDlg:End()) WHEN .t. //lConsulta  //"Consulta Anuencia"
      
         //@ 2.5,30 BUTTON oBtCDiag PROMPT STR0069 SIZE 55,13 ACTION (cAcao := CONSULTA_DIAGNOSTICO, oDlg:End()) WHEN lConsulta  //"Consulta Diagnostico"
      
         oBtEnvio:cToolTip := STR0070  //"Envio de arquivo"
         oBtCAnue:cToolTip := STR0071  //"Consulta de anuencia de arquivo"
         //oBtCDiag:cToolTip := STR0072  //"Consulta de diagnostico de arquivo"

      ACTIVATE MSDIALOG oDlg CENTERED

   EndIf

   If empty(cAcao)
      lRet := .F.
      Break
   EndIf

   if cAcao == ENVIO .Or. cAcao == ANALISE .Or. cAcao == REGISTRO
      lConsulta := .F.
   endif

   (cAlias)->(DbSetOrder(1))

   //Carrega os campos a serem apresentados no Browse de acordo com Alias
   aCampos := If(cServico == INT_DI .OR. cServico == INT_DSI, {"W6_HAWB","W6_DT_HAWB"},If(cServico == INT_LI, {"WP_PGI_NUM","WP_SEQ_LI","WP_REGIST","W4_PGI_DT"},))  // GFP - 06/04/2015
      If (cServico == INT_DI .OR. cServico == INT_DSI) .And. lConsulta
      aAdd(aCampos, Nil)
      aIns(aCampos, 1)
      aCampos[1] := "W6_FILIAL"
      aAdd(aCampos, "W6_DI_NUM")
      aAdd(aCampos, "W6_DTREG_D")
      If SW6->(FieldPos("W6_TRANSM")) > 0
         aAdd(aCampos, "W6_TRANSM")
      EndIf
   EndIf

   //Cria Work para apresentar no FWBROWSE
   If cServico == INT_DI .OR. cServico == INT_DSI                                                                                     
      cQuery += " SELECT DISTINCT W6_FILIAL, W6_HAWB, W6_DT_HAWB, W6_DI_NUM, W6_DTREG_D" + If(SW6->(FieldPos("W6_TRANSM")) > 0, ", W6_TRANSM", "") + " FROM " + RetSqlName("SW6") + " WHERE " + If(!lConsulta, "W6_FILIAL = '" + xFilial("SW6") + "' AND ", "")
      If !lConsulta
         cQuery += " ((W6_TIPOFEC='DI' AND W6_DT_EMB <> ' ') OR (W6_TIPOFEC='DIN' AND W6_DT_EMB <> ' ') OR (W6_TIPOFEC='DA' AND W6_DT_EMB <> ' '))" + " AND W6_DI_NUM = ' '" //THTS - 08/08/2017 - TE-6128
      Else
         If SW6->(FieldPos("W6_TRANSM")) > 0
            cQuery += "(W6_TRANSM <> ' ' Or W6_DI_NUM <> ' ') And W6_DT_ENCE = ' ' And (W6_VERSAO = '00' Or W6_VERSAO = ' ') "
         Else
            cQuery += "W6_DI_NUM <> ' ' And W6_DT_ENCE = ' ' And (W6_VERSAO = '00' Or W6_VERSAO = ' ') "
         EndIf
      EndIf
      cQuery += If(cServico == INT_DSI," AND W6_DSI = '1'","")
      cQuery += " AND D_E_L_E_T_ <> '*' "

      cQuery += if( SW6->(ColumnPos("W6_TIPOREG")) > 0, " AND W6_TIPOREG <> '2' ", "")

      aIndices := {"W6_HAWB"}
   ElseIf cServico == INT_LI
      cQuery += " SELECT DISTINCT SWP.WP_FILIAL, SWP.WP_PGI_NUM, SWP.WP_SEQ_LI, SW4.W4_PGI_DT, SWP.WP_REGIST, SWP.WP_CDSTA FROM " + RetSqlName("SWP") + " SWP "  // GFP - 06/04/2015 - Ajustado filtro para exibir quebras de LI.
      cQuery += " INNER JOIN " + RetSqlName("SW4") + " SW4 ON SW4.W4_FILIAL = SWP.WP_FILIAL AND SW4.W4_PGI_NUM = SWP.WP_PGI_NUM "
      cQuery += " WHERE SWP.WP_FILIAL = '" + xFilial("SWP")  + "' AND SW4.W4_FILIAL = '" + xFilial("SW4")  + "' " + If(lConsulta, "AND SWP.WP_REGIST <> ' ' ", "AND SWP.WP_REGIST = ' ' ")
      cQuery += " AND SW4.D_E_L_E_T_ <> '*' AND SWP.D_E_L_E_T_ <> '*' "
      cQuery += " ORDER BY SWP.WP_PGI_NUM, SWP.WP_SEQ_LI "      
      aIndices := {"WP_PGI_NUM","WP_SEQ_LI","WP_REGIST","WP_PGI_NUM+W4_PGI_DT","WP_SEQ_LI+WP_PGI_NUM"}
   EndIf

   If Empty(cQuery)
      cAcao := ""
      Break
   EndIf

   If Select("TMP") > 0
      TMP->(dbClosearea())
   EndIf

   If(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"CONSULTA_PROCESSOS"),)
   cAliQry := EasyWkQuery(cQuery,"TMP",aIndices,,,!(cServico == INT_DI .And. lConsulta))

   If cServico == INT_DI .And. lConsulta
      While (cAliQry)->(!Eof())
         TMP->(DBAPPEND())
         TMP->W6_FILIAL := (cAliQry)->W6_FILIAL
         TMP->W6_HAWB := (cAliQry)->W6_HAWB
         TMP->W6_DT_HAWB := (cAliQry)->W6_DT_HAWB
         TMP->W6_DI_NUM := (cAliQry)->W6_DI_NUM
         TMP->W6_DTREG_D := (cAliQry)->W6_DTREG_D
         If lW6_TRANSMIS
            TMP->W6_TRANSM := (cAliQry)->W6_TRANSM
         EndIf
         (cAliQry)->(DbSkip())
      EndDo
      (cAliQry)->(DbCloseArea())
   EndIf

   nInc := 1
   Do While nInc <= Len(aCampos)
      If !TMP->(FieldPos(aCampos[nInc])) > 0
         aDel(aCampos,nInc)
         aSize(aCampos,Len(aCampos)-1)   
         nInc--
      EndIf
      nInc++
   EndDo 
   aItens := {} 
   
   If TMP->(EOF()) .And. TMP->(BOF())
      MsgInfo(STR0088,STR0005) //"Não foram localizados registros para transmissão." ## "Atenção"
      lRet := .F.
   Else
      if cServico == INT_DI .OR. cServico == INT_DSI
         aSeek := {}
         /* Campos usados na pesquisa */
       //aAdd(aPesq, {STR0011                         , {{"",                           "C",                              255,                                0,                             "", "@!"} }, 1 } )
         AAdd(aSeek, {AvSx3("W6_HAWB", AV_TITULO)  , {{"", AvSx3("W6_HAWB", AV_TIPO) , AvSx3("W6_HAWB", AV_TAMANHO) , AvSx3("W6_HAWB", AV_DECIMAL) , AvSx3("W6_HAWB", AV_TITULO),     } }, 1 } )
         aFilter := {}
         /* Campos usados no filtro */
         AAdd(aFilter, {"W6_FILIAL"  , AvSx3("W6_FILIAL" , AV_TITULO)  , AvSx3("W6_FILIAL" , AV_TIPO) , AvSx3("W6_FILIAL" , AV_TAMANHO) , AvSx3("W6_FILIAL" , AV_DECIMAL), ""})
         AAdd(aFilter, {"W6_HAWB" , AvSx3("W6_HAWB", AV_TITULO)  , AvSx3("W6_HAWB", AV_TIPO) , AvSx3("W6_HAWB", AV_TAMANHO) , AvSx3("W6_HAWB", AV_DECIMAL), ""})
         AAdd(aFilter, {"W6_DT_HAWB"  , AvSx3("W6_DT_HAWB" , AV_TITULO)  , AvSx3("W6_DT_HAWB" , AV_TIPO) , AvSx3("W6_DT_HAWB" , AV_TAMANHO) , AvSx3("W6_DT_HAWB" , AV_DECIMAL), ""})
         AAdd(aFilter, {"W6_DI_NUM"  , AvSx3("W6_DI_NUM" , AV_TITULO)  , AvSx3("W6_DI_NUM" , AV_TIPO) , AvSx3("W6_DI_NUM" , AV_TAMANHO) , AvSx3("W6_DI_NUM" , AV_DECIMAL), ""})
         AAdd(aFilter, {"W6_DTREG_D"  , AvSx3("W6_DTREG_D" , AV_TITULO)  , AvSx3("W6_DTREG_D" , AV_TIPO) , AvSx3("W6_DTREG_D" , AV_TAMANHO) , AvSx3("W6_DTREG_D" , AV_DECIMAL), ""})
         If SW6->(FieldPos("W6_TRANSM")) > 0
            AAdd(aFilter, {"W6_TRANSM"  , AvSx3("W6_TRANSM" , AV_TITULO)  , AvSx3("W6_TRANSM" , AV_TIPO) , AvSx3("W6_TRANSM" , AV_TAMANHO) , AvSx3("W6_TRANSM" , AV_DECIMAL), ""})
         EndIf
      ElseIf cServico == INT_LI
         aSeek := {}
         /* Campos usados na pesquisa */
       //aAdd(aPesq, {STR0011                         , {{"",                           "C",                              255,                                0,                             "", "@!"} }, 1 } )
         AAdd(aSeek, {AvSx3("WP_SEQ_LI" , AV_TITULO)+"-"+AvSx3("WP_PGI_NUM" , AV_TITULO) , {{"", AvSx3("WP_SEQ_LI" , AV_TIPO) , AvSx3("WP_SEQ_LI" , AV_TAMANHO) , AvSx3("WP_SEQ_LI" , AV_DECIMAL) , AvSx3("WP_SEQ_LI" , AV_TITULO),     },{"", AvSx3("WP_PGI_NUM" , AV_TIPO) , AvSx3("WP_PGI_NUM" , AV_TAMANHO) , AvSx3("WP_PGI_NUM" , AV_DECIMAL) , AvSx3("WP_PGI_NUM" , AV_TITULO),     } }, 1 } )
         AAdd(aSeek, {AvSx3("WP_PGI_NUM", AV_TITULO)  , {{"", AvSx3("WP_PGI_NUM", AV_TIPO) , AvSx3("WP_PGI_NUM", AV_TAMANHO) , AvSx3("WP_PGI_NUM", AV_DECIMAL) , AvSx3("WP_PGI_NUM", AV_TITULO),     } }, 2 } )
         AAdd(aSeek, {AvSx3("WP_SEQ_LI" , AV_TITULO)  , {{"", AvSx3("WP_SEQ_LI" , AV_TIPO) , AvSx3("WP_SEQ_LI" , AV_TAMANHO) , AvSx3("WP_SEQ_LI" , AV_DECIMAL) , AvSx3("WP_SEQ_LI" , AV_TITULO),     } }, 3 } )
         AAdd(aSeek, {AvSx3("WP_REGIST" , AV_TITULO)  , {{"", AvSx3("WP_REGIST" , AV_TIPO) , AvSx3("WP_REGIST" , AV_TAMANHO) , AvSx3("WP_REGIST" , AV_DECIMAL) , AvSx3("WP_REGIST" , AV_TITULO),     } }, 4 } )
         AAdd(aSeek, {AvSx3("WP_PGI_NUM", AV_TITULO)+"-"+AvSx3("W4_PGI_DT" , AV_TITULO)  , {{"", AvSx3("WP_PGI_NUM" , AV_TIPO) , AvSx3("WP_PGI_NUM" , AV_TAMANHO) , AvSx3("WP_PGI_NUM" , AV_DECIMAL) , AvSx3("WP_PGI_NUM" , AV_TITULO),     },{"", AvSx3("W4_PGI_DT" , AV_TIPO) , AvSx3("W4_PGI_DT" , AV_TAMANHO) , AvSx3("W4_PGI_DT" , AV_DECIMAL) , AvSx3("W4_PGI_DT" , AV_TITULO),     } }, 5 } )
         aFilter := {}
         /* Campos usados no filtro */
         AAdd(aFilter, {"WP_FILIAL"  , AvSx3("WP_FILIAL" , AV_TITULO)  , AvSx3("WP_FILIAL" , AV_TIPO) , AvSx3("WP_FILIAL" , AV_TAMANHO) , AvSx3("WP_FILIAL" , AV_DECIMAL), ""})
         AAdd(aFilter, {"WP_PGI_NUM" , AvSx3("WP_PGI_NUM", AV_TITULO)  , AvSx3("WP_PGI_NUM", AV_TIPO) , AvSx3("WP_PGI_NUM", AV_TAMANHO) , AvSx3("WP_PGI_NUM", AV_DECIMAL), ""})
         AAdd(aFilter, {"WP_SEQ_LI"  , AvSx3("WP_SEQ_LI" , AV_TITULO)  , AvSx3("WP_SEQ_LI" , AV_TIPO) , AvSx3("WP_SEQ_LI" , AV_TAMANHO) , AvSx3("WP_SEQ_LI" , AV_DECIMAL), ""})
         AAdd(aFilter, {"WP_REGIST"  , AvSx3("WP_REGIST" , AV_TITULO)  , AvSx3("WP_REGIST" , AV_TIPO) , AvSx3("WP_REGIST" , AV_TAMANHO) , AvSx3("WP_REGIST" , AV_DECIMAL), ""})
         AAdd(aFilter, {"W4_PGI_DT"  , AvSx3("W4_PGI_DT" , AV_TITULO)  , AvSx3("W4_PGI_DT" , AV_TIPO) , AvSx3("W4_PGI_DT" , AV_TAMANHO) , AvSx3("W4_PGI_DT" , AV_DECIMAL), ""})
      endif
   
      bMarca := {|| If( ValidaReg(.F.,cServico,cAcao), If((nPos := aScan(aItens,TMP->(Recno())))==0, Aadd(aItens,TMP->(Recno())), (aDel(aItens,nPos), aSize(aItens, Len(aItens)-1))),.T.)}
      DEFINE MSDIALOG oDlg TITLE If(cServico == INT_DI .OR. cServico == INT_DSI,STR0018,If(cServico == INT_LI,STR0063,"")) FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  //"Seleção de Embarque/Desembaraço"  ## "Seleção de Pedidos de Licença de Importação"

         //DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TMP" OF oDlg
         oBrowse := FWMBrowse():New()
         oBrowse:SetOwner( oDlg )
         oBrowse:SetAlias( "TMP" )
         oBrowse:SetDataTable()
         oBrowse:SetInsert( .F. )

         oBrowse:AddMarkColumns(	{ || If(aScan(aItens, TMP->(Recno())) == 0, 'LBNO', 'LBOK') }, bMarca, bMarcaTodos ) //Coluna de marcacao

         //   ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, TMP->(Recno())) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowse
         aColumns := {}
         For nInc := 1 To Len(aCampos)
            //ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
            //Adiciona as colunas do Browse
            oColumn := FWBrwColumn():New()   //Cria objeto
            oColumn:SetData( &("{ ||" + "TMP->" + aCampos[nInc] + " }") ) //Define valor
            oColumn:SetEdit( .F. )	                              //Indica se é editavel
            oColumn:SetTitle( AvSx3(aCampos[nInc], AV_TITULO) )   //Define titulo
            oColumn:SetType( AvSx3(aCampos[nInc], AV_TIPO ) )     //Define tipo
            oColumn:SetSize( AvSx3(aCampos[nInc], AV_TAMANHO) )	//Define tamanho
            oColumn:SetPicture( AvSx3(aCampos[nInc], AV_PICTURE) )//Define picture
            aadd( aColumns , oColumn )
         Next
         oBrowse:SetColumns( aColumns )

         if cServico == INT_LI
            if lConsulta
               oBrowse:AddFilter( "Não deferidos" , "(WP_CDSTA <> '05')" , .f. , .T. , "TMP" , .F. , , "XB" )
            endif
            oBrowse:SetAlias("TMP")
         endif
            /* Pesquisa */
            oBrowse:SetSeek(.T.,aSeek)

            oBrowse:SetAlias("TMP")//RMD - 17/07/19 - Senão a opção de filtros não aparece
            /* Filtro */
            oBrowse:SetUseFilter()
            oBrowse:SetFieldFilter(aFilter)
            oBrowse:lCanCancelFilter := .T.


         //ACTIVATE FWBROWSE oBrowse
         oBrowse:Activate()
         oDlg:lMaximized := .T.

      ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
   EndIf

if lRet .and. len(aItens) == 0
   lRet := .F.
endif

End Sequence

Return lRet //!Empty(cAcao)

/*
Função      : MarkAllItens()
Parametros  : cServico - Serviço de Integração
Retorno     : aItens - Registros marcados
Objetivos   : Marcar todos os registros de tela.
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/01/2015 :: 14:06
*/
*--------------------------------------*
Static Function MarkAllItens(cServico,cAcao)
*--------------------------------------*
Local aItens := {}, aOrd := SaveOrd("EE8")
TMP->(DbGoTop())
While TMP->(!Eof())
   If cServico == INT_DI .OR. cServico == INT_LI
      If ValidaReg(.T.,cServico,cAcao)
         aAdd(aItens, TMP->(Recno()))
      EndIf
   ElseIf cServico == INT_DSI
      aAdd(aItens, TMP->(Recno()))
   EndIf
   TMP->(DbSkip())
EndDo

RestOrd(aOrd, .T.)
Return aItens

/*
Método     : GeraINI()
Classe     : EICINTSISWEB
Parametros : Ação
Retorno    : Nenhum
Objetivos  : Geração do arquivo INI
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 04/02/2015 :: 11:31
*/
*-------------------------------------------*
Method GeraINI(cIdLote,cServico) Class EICINTSISWEB
*-------------------------------------------*
Local hFile, cBuffer := "", cArquivo := ""

Begin Sequence

   If cServico == INT_DI .OR. cServico == INT_DSI
      cArquivo := AllTrim(EV1->EV1_HAWB)
   ElseIf cServico == INT_LI
      cArquivo := AllTrim(EVD->EVD_PGI_NU)+AllTrim(EVD->EVD_SEQLI)
   EndIf
   AjustaNome(@cArquivo)
   //*** Cria o arquivo
	hFile := EasyCreateFile(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".ini", FC_READONLY)
	
	If hFile == -1
		MsgInfo(STR0025,STR0005) //O arquivo não pode ser criado. ## "Atenção"
		Break
	EndIf
	
	If cServico == INT_DI .OR. cServico == INT_DSI
		If cServico == INT_DI
		   cBuffer += "[SISCOMEXWEB]"												+ ENTER
		   If cAcao == REGISTRO
		      If EV1->EV1_REGAL == "S"
		         cBuffer += "REG_DIAG_AMARELO = S"								+ ENTER
		      Else
		         cBuffer += "REG_DIAG_AMARELO = N"								+ ENTER
		      EndIf
		   EndIf
		Else
		   cBuffer += "[SISCOMEXWEBDSI]"											+ ENTER
		EndIf
		If cAcao == DI_CONSULTA
		   If cServico == INT_DI
		      cBuffer += "PROCESSO_DI = "	+ EV1->EV1_HAWB						+ ENTER //(***numero do processo***)
		   Else
		      cBuffer += "PROCESSO_DSI = "	+ EV1->EV1_HAWB						+ ENTER //(***numero do processo***)
		   EndIf
         If EV1->(FieldPos("EV1_FILORI")) > 0
            cBuffer += "FILIAL_PROCESSO = " + EV1->EV1_FILORI + ENTER //Filial do Processo
         EndIf
         If cServico == INT_DSI .Or. Empty(cNrDI)
		      cBuffer += "NUM_TRANSMISSAO = " + cNrTraDI						+ ENTER
		      cBuffer += "[DIAGNOSTICO]" 											+ ENTER
		      cBuffer += "FLAG=S" 														+ ENTER
         Else//RMD - 01/07/19 - Se for integração de DI e já possuir o número, consulta o status da DI, e não da transmissão
		      cBuffer += "NUM_DI = " + cNrDI						            + ENTER
		      cBuffer += "[DESEMBARACO]" 											+ ENTER
		      cBuffer += "FLAG=S" 														+ ENTER
         EndIf
		Else
		   cBuffer += "ARQUIVO_ENVIO = " + cArquivo + ".xml" 					+ ENTER //(***nome do arquivo de envio xml***)
		   If cServico == INT_DI
		      cBuffer += "PROCESSO_DI = "	+ EV1->EV1_HAWB						+ ENTER //(***numero do processo***)
		   Else
		      cBuffer += "PROCESSO_DSI = "	+ EV1->EV1_HAWB						+ ENTER //(***numero do processo***)
		   EndIf
		   cBuffer += "CNPJ_IMPORTADOR = "											+ ENTER
   		   cBuffer += ENTER
		   cBuffer += "[REGISTRO]" 													+ ENTER
		   cBuffer += "TIPO_ENVIO = " + cAcao 										+ ENTER  //(A = Análise e R = Registro***)
		   cBuffer += "MODO_ENVIO = XML" 											+ ENTER
		   cBuffer += ENTER
		EndIf
	ElseIf cServico == INT_LI		
		If cAcao == ENVIO
		   cBuffer += "[SISCOMEXWEBLI]"		 															+ ENTER
		   cBuffer += "ARQUIVO_ENVIO_LI = "+ cArquivo + ".xml"										+ ENTER
		   cBuffer += "IDENTIFICACAO_LI = "+ cArquivo 												+ ENTER
		   cBuffer += "NUMERO_PROCESSO = "+ AllTrim(EVD->EVD_PGI_NU)+AllTrim(EVD->EVD_SEQLI)	+ ENTER
         cBuffer += "CNPJ_IMPORTADOR = "+ AllTrim(EVD->EVD_CGCIMP)								+ ENTER
         cBuffer += ENTER
		   cBuffer += "[REGISTRO]"		 																+ ENTER
		   cBuffer += "FLAG = S" 					 													+ ENTER
		ElseIf cAcao == CONSULTA_ANUENCIA
		   cBuffer += "[SISCOMEXWEBLI]"	                                                                                                + ENTER
		   cBuffer += "NUMERO_PROCESSO = "+ AllTrim(EVD->EVD_PGI_NU)+AllTrim(EVD->EVD_SEQLI)	+ ENTER
         cBuffer += "NUM_LI = "+ AllTrim(Posicione("SWP", 1, xFilial("SWP")+EVD->(EVD_PGI_NU+EVD_SEQLI), "WP_REGIST"))					      + ENTER//RMD
         cBuffer += + ENTER
         cBuffer += "[PDF]"                                                                                                               + ENTER
         cBuffer += "FLAG = S" 					 													+ ENTER
          cBuffer += ENTER
          cBuffer += "[CONSULTA_LI]"	 																+ ENTER
		   cBuffer += "FLAG = S" 					 													+ ENTER
		ElseIf cAcao == CONSULTA_DIAGNOSTICO
		   cBuffer += "[SISCOMEXWEBLI]"		 															+ ENTER
		   cBuffer += "NUM_TRANSMISSAO = "+ AllTrim(EVD->EVD_PGI_NU)								+ ENTER
          cBuffer += ENTER
          cBuffer += "[DIAGNOSTICO]"	 																+ ENTER
		   cBuffer += "FLAG = S" 					 													+ ENTER
		EndIf
		cBuffer += ENTER
	EndIf
	cBuffer += "[WebClientOptions]"		 									+ ENTER
	If !Empty(EICINTSISWEB:cPrxUrl) //.AND.  !Empty(EICINTSISWEB:cPrxPrt)
	   cBuffer += "proxy.enabled=TRUE"		 								+ ENTER
	   cBuffer += "proxy.type=DEFAULT"		 								+ ENTER
	   cBuffer += "proxy.host="+AllTrim(EICINTSISWEB:cPrxUrl)			+ ENTER
	   cBuffer += "proxy.port="+AllTrim(EICINTSISWEB:cPrxPrt)			+ ENTER
	   cBuffer += "proxy.user="+AllTrim(EICINTSISWEB:cPrxUsr)			+ ENTER
	   cBuffer += "proxy.pass="+AllTrim(EICINTSISWEB:cPrxPss)			+ ENTER
	Else
	   cBuffer += "proxy.enabled=FALSE"		 							+ ENTER
	EndIf

	IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GERA_INI"),)

	If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		Break
	EndIf
	FClose(hFile)
    cArquivo += ".ini"
End Sequence

Return

/*
Metodo     : VisualReg()
Classe     : EICINTSISWEB
Parametros : Ação
Retorno    : Nenhum
Objetivos  : Visualização de Registro
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 01/04/2015 :: 13:56
*/
*--------------------------------------------------*
Method VisualReg(cWork,cTipoInt) Class EICINTSISWEB
*--------------------------------------------------*
Local aNomeFolders := {}, aPosTela  := {}
Local oDlg, oEnch
Local oFld, oFldAdi, oFldAcr, oFldDed, oFldDes, oFldNom, oFldDVi, oFldMer, oFldIDe, oFldPVi, oFldPag, oFldImp, oFldEmb, oFldMcs, oFldIte, oFldAnu, oFldAco
Local oMsSelAdi, oMsSelAcr, oMsSelDed, oMsSelDes, oMsSelNom, oMsSelDVi, oMsSelMer, oMsSelIDe, oMsSelPVi, oMsSelPag, oMsSelImp, oMsSelEmb, oMsSelMcs, oMsSelIte, oMsSelAnu, oMsSelAco
Local cAliasOld := Alias(), aOrd := SaveOrd({"EV0","EV1","EV2","EV3","EV4","EV5","EV6","EV7","EV8","EV9","EVA","EVB","EVC","EVD","EVE","EVF","EVG","EVH","EVI","EVK"})
Local cCpoCapa  := "", cCpoDet   := "", cAliasWK := ""
Local cServico	:= ""

PRIVATE lInvert := .F.

Begin Sequence

   cServico := Left(AllTrim(cTipoInt), 2)//If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS"))) 
   If cServico == "RAIZ"
      Break
   EndIf

   If Select(cWork) == 0 .Or. IsVazio(cWork)
      MsgInfo(STR0110, STR0005) //"Não existem processos para visualizar." ## "Atenção"
      Break
   EndIf
   
   If cServico == INT_DI
      aNomeFolders  := {STR0098,STR0099,STR0100,STR0101,STR0102,STR0103,STR0104,STR0105,STR0106,STR0107,STR0113,STR0114,STR0115,"Acordos"} //"Adições" ## "Acréscimos" ## "Deduções" ## "Destaques" ## "Nomenclaturas" ## "Doc. Vinculados" ## "Mercadorias" ## "Inst. Despacho" ## "Proc. Vinculados" ## "Pagamentos" ## "Impostos" ## "Embalagens" ## "Mercosul" ## "Acordos"
   ElseIf cServico == INT_LI
      aNomeFolders  := {STR0108,STR0109,STR0101} //"Itens" ## "Anuências" ## "Destaques"
   ElseIf cServico == INT_DSI
      aNomeFolders  := {STR0122,STR0113,STR0107,STR0114} //"Bens" ## "Impostos" ## "Pagamentos" ## "Embalagens"
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0111 FROM 0,0 TO DLG_LIN_FIM*0.9, DLG_COL_FIM*0.7 OF oMainWnd PIXEL  //"Detalhes do Registro"
      aPosTelaUp  := PosDlgUp(oDlg)
      aPosTelaDown:= PosDlgDown(oDlg)	
      If cServico == INT_DI .OR. cServico == INT_DSI
         oEnch := MsMGet():New("EV1", EV1->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
      ElseIf cServico == INT_LI
         oEnch := MsMGet():New("EVD", EVD->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
      EndIf
      oEnch:oBox:Align := CONTROL_ALIGN_TOP
   
      //Criação do Folder.
      oFld := TFolder():New(aPosTelaDown[1]+35,aPosTelaDown[2]-1,aNomeFolders,aNomeFolders,oDlg,,,,.T.,.F.,aPosTelaDown[4],aPosTelaDown[4]-260)
      oFld:Align := CONTROL_ALIGN_ALLCLIENT
   
      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
      If cServico == INT_DI .OR. cServico == INT_DSI
         EV2->(DbSetOrder(2))
         EV3->(DbSetOrder(2))
         EV4->(DbSetOrder(2))
         EV5->(DbSetOrder(2))
         EV6->(DbSetOrder(2))
         EV7->(DbSetOrder(2))
         EV8->(DbSetOrder(2))
         EV9->(DbSetOrder(2))
         EVA->(DbSetOrder(2))
         EVB->(DbSetOrder(2))
         EVC->(DbSetOrder(1))
         EVD->(DbSetOrder(1))
         EVE->(DbSetOrder(1))
         EVF->(DbSetOrder(1))
         EVG->(DbSetOrder(1))
         EVH->(DbSetOrder(1))
         EVI->(DbSetOrder(1))
         EVK->(DbSetOrder(1))
   
         EV2->(DbSeek(xFilial("EV2")+AvKey(EV1->EV1_LOTE,"EV2_LOTE")+AvKey(EV1->EV1_HAWB,"EV2_HAWB")))
         EV3->(DbSeek(xFilial("EV3")+AvKey(EV1->EV1_LOTE,"EV3_LOTE")+AvKey(EV1->EV1_HAWB,"EV3_HAWB")+AvKey(EV2->EV2_ADICAO,"EV3_ADICAO")))
         EV4->(DbSeek(xFilial("EV4")+AvKey(EV1->EV1_LOTE,"EV4_LOTE")+AvKey(EV1->EV1_HAWB,"EV4_HAWB")+AvKey(EV2->EV2_ADICAO,"EV4_ADICAO")))
         EV5->(DbSeek(xFilial("EV5")+AvKey(EV1->EV1_LOTE,"EV5_LOTE")+AvKey(EV1->EV1_HAWB,"EV5_HAWB")+AvKey(EV2->EV2_ADICAO,"EV5_ADICAO")))
         EV6->(DbSeek(xFilial("EV6")+AvKey(EV1->EV1_LOTE,"EV6_LOTE")+AvKey(EV1->EV1_HAWB,"EV6_HAWB")+AvKey(EV2->EV2_ADICAO,"EV6_ADICAO")))
         EV7->(DbSeek(xFilial("EV7")+AvKey(EV1->EV1_LOTE,"EV7_LOTE")+AvKey(EV1->EV1_HAWB,"EV7_HAWB")+AvKey(EV2->EV2_ADICAO,"EV7_ADICAO")))
         EV8->(DbSeek(xFilial("EV8")+AvKey(EV1->EV1_LOTE,"EV8_LOTE")+AvKey(EV1->EV1_HAWB,"EV8_HAWB")+AvKey(EV2->EV2_ADICAO,"EV8_ADICAO")))
         EV9->(DbSeek(xFilial("EV9")+AvKey(EV1->EV1_LOTE,"EV9_LOTE")+AvKey(EV1->EV1_HAWB,"EV9_HAWB")))
         EVA->(DbSeek(xFilial("EVA")+AvKey(EV1->EV1_LOTE,"EVA_LOTE")+AvKey(EV1->EV1_HAWB,"EVA_HAWB")))
         EVB->(DbSeek(xFilial("EVB")+AvKey(EV1->EV1_LOTE,"EVB_LOTE")+AvKey(EV1->EV1_HAWB,"EVB_HAWB")))
         EVG->(DbSeek(xFilial("EVG")+AvKey(EV1->EV1_HAWB,"EVG_HAWB")+AvKey(EV1->EV1_LOTE,"EVG_LOTE")+AvKey(EV2->EV2_ADICAO,"EVG_ADICAO")))
         EVH->(DbSeek(xFilial("EVH")+AvKey(EV1->EV1_HAWB,"EVH_HAWB")+AvKey(EV1->EV1_LOTE,"EVH_LOTE")+AvKey(EV2->EV2_ADICAO,"EVH_ADICAO")))
         EVI->(DbSeek(xFilial("EVI")+AvKey(EV1->EV1_HAWB,"EVI_HAWB")+AvKey(EV1->EV1_LOTE,"EVI_LOTE")+AvKey(EV2->EV2_ADICAO,"EVI_ADICAO")))
         EVK->(DbSeek(xFilial("EVK")+AvKey(EV1->EV1_HAWB,"EVK_HAWB")+AvKey(EV1->EV1_LOTE,"EVK_LOTE")+AvKey(EV2->EV2_ADICAO,"EVK_ADICAO")))

         If cServico == INT_DI

            oFldAdi   := oFld:aDialogs[1]
            oFldAcr   := oFld:aDialogs[2]  
            oFldDed   := oFld:aDialogs[3] 
            oFldDes   := oFld:aDialogs[4] 
            oFldNom   := oFld:aDialogs[5] 
            oFldDVi   := oFld:aDialogs[6] 
            oFldMer   := oFld:aDialogs[7] 
            oFldIDe   := oFld:aDialogs[8] 
            oFldPVi   := oFld:aDialogs[9] 
            oFldPag   := oFld:aDialogs[10]
            oFldImp   := oFld:aDialogs[11]
            oFldEmb   := oFld:aDialogs[12]
            oFldMcs   := oFld:aDialogs[13]
            oFldAco   := oFld:aDialogs[14]
            aPosTela  := PosDlg(oFldAdi)
         
            // Filtro para exibição da msSelect para Adições
            cCpoCapa := "xFilial('EV2') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV2_FILIAL + EV2_LOTE + EV2_HAWB"
            oMsSelAdi := MsSelect():New("EV2",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldAdi)
            oMsSelAdi:oBrowse:Hide()
            oMsSelAdi:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelAdi:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelAdi:oBrowse:Refresh()
            oMsSelAdi:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Acréscimos
            cCpoCapa := "xFilial('EV3') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV3_FILIAL + EV3_LOTE + EV3_HAWB"
            oMsSelAcr := MsSelect():New("EV3",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldAcr)
            oMsSelAcr:oBrowse:Hide()
            oMsSelAcr:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelAcr:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelAcr:oBrowse:Refresh()
            oMsSelAcr:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Deduções
            cCpoCapa := "xFilial('EV4') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV4_FILIAL + EV4_LOTE + EV4_HAWB"
            oMsSelDed := MsSelect():New("EV4",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDed)
            oMsSelDed:oBrowse:Hide()
            oMsSelDed:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelDed:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelDed:oBrowse:Refresh()
            oMsSelDed:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Destaques
            cCpoCapa := "xFilial('EV5') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV5_FILIAL + EV5_LOTE + EV5_HAWB"
            oMsSelDes := MsSelect():New("EV5",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDes)
            oMsSelDes:oBrowse:Hide()
            oMsSelDes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelDes:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelDes:oBrowse:Refresh()
            oMsSelDes:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Doc. Vinculados
            cCpoCapa := "xFilial('EV6') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV6_FILIAL + EV6_LOTE + EV6_HAWB"
            oMsSelDVi := MsSelect():New("EV6",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDVi)
            oMsSelDVi:oBrowse:Hide()
            oMsSelDVi:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelDVi:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelDVi:oBrowse:Refresh()
            oMsSelDVi:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Mercadorias
            cCpoCapa := "xFilial('EV7') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV7_FILIAL + EV7_LOTE + EV7_HAWB"
            oMsSelMer := MsSelect():New("EV7",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldMer)
            oMsSelMer:oBrowse:Hide()
            oMsSelMer:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelMer:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelMer:oBrowse:Refresh()
            oMsSelMer:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Nomenclaturas
            cCpoCapa := "xFilial('EV8') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV8_FILIAL + EV8_LOTE + EV8_HAWB"
            oMsSelNom := MsSelect():New("EV8",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldNom)
            oMsSelNom:oBrowse:Hide()
            oMsSelNom:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelNom:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelNom:oBrowse:Refresh()
            oMsSelNom:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Instr. Despachos
            cCpoCapa := "xFilial('EV9') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV9_FILIAL + EV9_LOTE + EV9_HAWB"
            oMsSelIDe := MsSelect():New("EV9",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldIDe)
            oMsSelIDe:oBrowse:Hide()
            oMsSelIDe:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelIDe:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelIDe:oBrowse:Refresh()
            oMsSelIDe:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Pagamentos
            cCpoCapa := "xFilial('EVA') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVA_FILIAL + EVA_LOTE + EVA_HAWB"
            oMsSelPag := MsSelect():New("EVA",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldPag)
            oMsSelPag:oBrowse:Hide()
            oMsSelPag:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelPag:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelPag:oBrowse:Refresh()
            oMsSelPag:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Proc. Vinculados
            cCpoCapa := "xFilial('EVB') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVB_FILIAL + EVB_LOTE + EVB_HAWB"
            oMsSelPVi := MsSelect():New("EVB",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldPVi)
            oMsSelPVi:oBrowse:Hide()
            oMsSelPVi:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelPVi:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelPVi:oBrowse:Refresh()
            oMsSelPVi:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Impostos
            cCpoCapa := "xFilial('EVG') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVG_FILIAL + EVG_LOTE + EVG_HAWB"
            oMsSelImp := MsSelect():New("EVG",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldImp)
            oMsSelImp:oBrowse:Hide()
            oMsSelImp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelImp:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelImp:oBrowse:Refresh()
            oMsSelImp:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Embalagens
            cCpoCapa := "xFilial('EVH') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVH_FILIAL + EVH_LOTE + EVH_HAWB"
            oMsSelEmb := MsSelect():New("EVH",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldEmb)
            oMsSelEmb:oBrowse:Hide()
            oMsSelEmb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelEmb:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelEmb:oBrowse:Refresh()
            oMsSelEmb:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Mercosul
            cCpoCapa := "xFilial('EVI') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVI_FILIAL + EVI_LOTE + EVI_HAWB"
            oMsSelMcs := MsSelect():New("EVI",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldMcs)
            oMsSelMcs:oBrowse:Hide()
            oMsSelMcs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelMcs:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelMcs:oBrowse:Refresh()
            oMsSelMcs:oBrowse:Show()
            
            // Filtro para exibição da msSelect para Acordos Tarifarios
            cCpoCapa := "xFilial('EVK') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVK_FILIAL + EVK_LOTE + EVK_HAWB"
            oMsSelAco := MsSelect():New("EVK",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldAco)
            oMsSelAco:oBrowse:Hide()
            oMsSelAco:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelAco:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelAco:oBrowse:Refresh()
            oMsSelAco:oBrowse:Show()
         
         ElseIf cServico == INT_DSI
         
            oFldAdi   := oFld:aDialogs[1]
            oFldImp   := oFld:aDialogs[2]
            oFldPag   := oFld:aDialogs[3]
            oFldEmb   := oFld:aDialogs[4]
            aPosTela  := PosDlg(oFldAdi)
         
            // Filtro para exibição da msSelect para Adições
            cCpoCapa := "xFilial('EV2') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EV2_FILIAL + EV2_LOTE + EV2_HAWB"
            oMsSelAdi := MsSelect():New("EV2",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldAdi)
            oMsSelAdi:oBrowse:Hide()
            oMsSelAdi:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelAdi:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelAdi:oBrowse:Refresh()
            oMsSelAdi:oBrowse:Show()    
         
            // Filtro para exibição da msSelect para Pagamentos
            cCpoCapa := "xFilial('EVA') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVA_FILIAL + EVA_LOTE + EVA_HAWB"
            oMsSelPag := MsSelect():New("EVA",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldPag)
            oMsSelPag:oBrowse:Hide()
            oMsSelPag:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelPag:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelPag:oBrowse:Refresh()
            oMsSelPag:oBrowse:Show()         
         
             // Filtro para exibição da msSelect para Impostos
            cCpoCapa := "xFilial('EVG') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVG_FILIAL + EVG_LOTE + EVG_HAWB"
            oMsSelImp := MsSelect():New("EVG",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldImp)
            oMsSelImp:oBrowse:Hide()
            oMsSelImp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelImp:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelImp:oBrowse:Refresh()
            oMsSelImp:oBrowse:Show()
         
            // Filtro para exibição da msSelect para Embalagens
            cCpoCapa := "xFilial('EVH') + EV1->EV1_LOTE + EV1->EV1_HAWB"
            cCpoDet  := "EVH_FILIAL + EVH_LOTE + EVH_HAWB"
            oMsSelEmb := MsSelect():New("EVH",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldEmb)
            oMsSelEmb:oBrowse:Hide()
            oMsSelEmb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
            oMsSelEmb:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
            oMsSelEmb:oBrowse:Refresh()

         EndIf

      ElseIf cServico == INT_LI
         EV5->(DbSetOrder(3))
         EVE->(DbSetOrder(1))
         EVF->(DbSetOrder(1))

         EV5->(DbSeek(xFilial("EV5")+AvKey(EVD->EVD_LOTE,"EV5_LOTE")+AvKey(EVD->EVD_PGI_NU,"EV5_PGI_NU")))
         EVE->(DbSeek(xFilial("EVE")+AvKey(EVD->EVD_PGI_NU,"EVE_PGI_NU")+AvKey(EVD->EVD_LOTE,"EVE_LOTE")))
         EVF->(DbSeek(xFilial("EVF")+AvKey(EVD->EVD_PGI_NU,"EVF_PGI_NU")+AvKey(EVD->EVD_LOTE,"EVF_LOTE")))
         
         oFldIte   := oFld:aDialogs[1]
         oFldAnu   := oFld:aDialogs[2]
         oFldDes   := oFld:aDialogs[3]
         aPosTela  := PosDlg(oFldIte)
      
         // Filtro para exibição da msSelect para Itens
         cCpoCapa := "xFilial('EVF') + EVD->EVD_PGI_NU + EVD->EVD_LOTE"
         cCpoDet  := "EVF_FILIAL + EVF_PGI_NU + EVF_LOTE"
         oMsSelIte := MsSelect():New("EVF",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldIte)
         oMsSelIte:oBrowse:Hide()
         oMsSelIte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         oMsSelIte:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
         oMsSelIte:oBrowse:Refresh()
         oMsSelIte:oBrowse:Show()

         // Filtro para exibição da msSelect para Anuencia
         cCpoCapa := "xFilial('EVE') + EVD->EVD_PGI_NU + EVD->EVD_LOTE"
         cCpoDet  := "EVE_FILIAL + EVE_PGI_NU + EVE_LOTE"
         oMsSelAnu := MsSelect():New("EVE",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldAnu)
         oMsSelAnu:oBrowse:Hide()
         oMsSelAnu:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         oMsSelAnu:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
         oMsSelAnu:oBrowse:Refresh()
         oMsSelAnu:oBrowse:Show()
         
         // Filtro para exibição da msSelect para Destaques
         cCpoCapa := "xFilial('EV5') + EVD->EVD_LOTE + EVD->EVD_PGI_NU"
         cCpoDet  := "EV5_FILIAL + EV5_LOTE + EV5_PGI_NU"
         oMsSelDes := MsSelect():New("EV5",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDes)
         oMsSelDes:oBrowse:Hide()
         oMsSelDes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         oMsSelDes:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
         oMsSelDes:oBrowse:Refresh()
         oMsSelDes:oBrowse:Show()  
      EndIf
      
   ACTIVATE MSDIALOG oDlg Centered
   DbSelectArea(cAliasOld)
   
End Sequence

RestOrd(aOrd,.T.)
Return Nil


/*
Método     : Imprimir()
Classe     : EICINTSISWEB
Parametros : Ação
Retorno    : Nenhum
Objetivos  : Impressão de registro
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 07/04/2015 :: 09:49
*/
*------------------------------------------*
Method Imprimir(cWork,cTipoInt) Class EICINTSISWEB
*------------------------------------------*
Local nOP := 0, nTipoRel := 1 , cServico := ""
Local oDlg
Begin Sequence
   
   cServico := Left(AllTrim(cTipoInt), 2)//If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS"))) 
   
   If cServico # "LI" //LGS-09/11/2015
      Processa({|| ImprimeRel(cWork, nTipoRel, cTipoInt)}, STR0132, STR0133, .T.)
   Else
      DEFINE MSDIALOG oDlg TITLE STR0134 FROM 000, 000  TO 150, 280 COLORS 0, 16777215 PIXEL
          oPanel:= tPanel():New(01,01,"",oDlg,,,,,,100,100)
          oPanel:Align := CONTROL_ALIGN_ALLCLIENT
          
          @ 005, 005 GROUP oGroup1 TO 071, 132 PROMPT STR0135 OF oPanel PIXEL
          @ 014, 009 GROUP oGroup2 TO 048, 127 PROMPT STR0136 OF oPanel PIXEL
          @ 024, 015 RADIO nTipoRel ITEMS STR0137,STR0138 SIZE 092, 020 OF oPanel PIXEL
          
          @ 053, 046 BUTTON STR0139 ACTION {||oDlg:End(),nOP := 1} SIZE 039,012 PIXEL OF oPanel //Imprimir
          @ 053, 088 BUTTON STR0140 ACTION {||oDlg:End()         } SIZE 039,012 PIXEL OF oPanel //Cancelar
      ACTIVATE MSDIALOG oDlg CENTERED
      If nOP == 1
         //"Impressão de Relatório" ## "Imprimindo relatório para conferência..."
         Processa({|| ImprimeRel(cWork, nTipoRel, cTipoInt)}, STR0132, STR0133, .T.)
      EndIf
   EndIf
End Sequence
Return Nil

/*
Função      : GeracaoArq()
Parametros  : Nome do arquivo // Tipo de serviço
Retorno     : Nenhum
Objetivos   : Geração de arquivo para integração
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 27/01/2015 :: 08:31
*/
*--------------------------------------------*
Static Function GeracaoArq(cArquivo,cServico)
*--------------------------------------------*
Local hFile, i, j, k
Local cBuffer := "", cIdLote := "", cDirUser := If(!Empty(EICINTSISWEB:cDirUser),EICINTSISWEB:cDirUser,GetTempPath(.T.))
Local cUMde := "", nQtdMerc := 0, nVLMCV := 0, nVlTotPesoL := 0, nTamDesc := AvSx3("W8_DESC_VM",3)
Local lSuframa := AvFlags("SUFRAMA")
Local lExiste_Midia := EasyGParam("MV_SOFTWAR",,"N") == "N"
Local lIntDraw := EasyGParam("MV_EIC_EDC",,.F.)
Local lExisteWP_AC, lInfOrgAnu
Local tBate1vez:=.T.,nPesTotPLI:=0,MDesFrePLI:=0, PGI_Chave:='',nVlTotLocEnt := 0
Local lSegInc := SW4->(FIELDPOS("W4_SEGINC")) # 0 .AND. SW4->(FIELDPOS("W4_SEGURO")) # 0 .AND. SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0
Local lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Local lW4_Fre_Inc := SW4->( FieldPos("W4_FREINC" ) ) > 0
Local lPartNum := EasyGParam("MV_EICPNUM",,.F.)
Local mMemo := "", cMemo := "", cPaisProc := "", cURFEnt := ""
Local oError := AvObject():New()
Local aArqsZIP := {}, aArquivos := {}, aProcOrg := {}
Local cUni410 := "", cTx_Conv := ""
Local nPesTotLI:=0,nPesTotItem:=0,MDesFreLI:=0,MSeq:=0
Local lTemNVE := EIM->(FIELDPOS("EIM_CODIGO")) # 0 .AND.;
                 SW8->(FIELDPOS("W8_NVE"))     # 0 .AND.;
                 EIJ->(FIELDPOS("EIJ_NVE"))    # 0 .AND.;
                 SIX->(dbSeek("EIM2"))
Local lMERCODI := (EasyGParam("MV_MERCODI",,.F.) .AND. ;
                  SW6->(FIELDPOS("W6_DEMERCO")) # 0 .AND. SW6->(FIELDPOS("W6_REINIC")) # 0 .AND. SW6->(FIELDPOS("W6_REFINAL")) # 0 .AND.;
                  EIJ->(FIELDPOS("EIJ_DEMERC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REINIC")) # 0 .AND. EIJ->(FIELDPOS("EIJ_REFINA")) # 0 .AND.;
                  EIJ->(FIELDPOS("EIJ_IDCERT")) # 0 .AND. EIJ->(FIELDPOS("EIJ_PAISEM")) # 0 .AND. EIJ->(FIELDPOS("EIJ_DICERT")) # 0 .AND.;
                  EIJ->(FIELDPOS("EIJ_ITDICE")) # 0 .AND. EIJ->(FIELDPOS("EIJ_QTDCER")) # 0 )
Local lAUTPCDI := DI500AUTPCDI()
Local lQbgOperaca:= EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0 //AWR - 20/12/2004
Local nTotal_IPI:=nTotal_II:=nTot_VLMLERS:=nItem:=0,nTotal:=10,nSeqAdi:=0
Local cTipoVia,nHdl,nSair
Local nTotal_PIS:=nTotal_COF:=nTotC_PIS:=nTotC_COF:=nAliqICMS:=0
Local cTmpTabEIM,cFilEIM,cFaseEIM,cWhereCond,lEIMAdicInf
Private cLoteAlt := ""
Private cTextoDesc:= ""

Begin Sequence
   
   SX3->(DbSetOrder(2))
   lExisteWP_AC := SX3->(DbSeek("WP_AC"))
   lInfOrgAnu := SX3->(DBSEEK("B1_ORG_ANU")) .AND. SX3->(DBSEEK("B1_PRO_ANU"))
   
   SW6->(DbSetOrder(1))  //W6_FILIAL+W6_HAWB
   SW8->(DbSetOrder(4))  //W8_FILIAL+W8_HAWB+W8_ADICAO
   SW9->(DbSetOrder(1))  //W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
   SW3->(DbSetOrder(8))  //W3_FILIAL+W3_PO_NUM+W3_POSICAO
   SW2->(DBSETORDER(1))  //W2_FILIAL+W2_PO_NUM
   EIJ->(DbSetOrder(1))  //EIJ_FILIAL+EIJ_HAWB+EIJ_ADICAO+EIJ_PO_NUM
   If ChkFile("EJ9")//ChkFile("EJ9",.F.)
      EJ9->(DbSetOrder(1))  //EJ9_FILIAL+EJ9_HAWB+EJ9_ADICAO+EJ9_DEMERC
   EndIf
   SYQ->(DbSetOrder(1))  //YQ_FILIAL+YQ_VIA
   EIN->(DbSetOrder(1))  //EIN_FILIAL+EIN_HAWB+EIN_ADICAO
   EIL->(DbSetOrder(1))  //EIL_FILIAL+EIL_HAWB+EIL_ADICAO
   EIK->(DbSetOrder(1))  //EIK_FILIAL+EIK_HAWB+EIK_ADICAO
   SA2->(DbSetOrder(1))  //A2_FILIAL+A2_COD+A2_LOJA
   SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
   SAH->(DbSetOrder(1))  //AH_FILIAL+AH_UNIMED
   EIM->(DbSetOrder(1))  //EIM_FILIAL+EIM_HAWB+EIM_ADICAO
   SY4->(DbSetOrder(1))  //Y4_FILIAL+Y4_COD
   EIF->(DbSetOrder(1))  //EIF_FILIAL+EIF_HAWB+EIF_CODIGO+EIF_DOCTO+EIF_SEQUEN
   SYT->(DbSetOrder(1))  //YT_FILIAL+YT_COD_IMP
   EII->(DbSetOrder(1))  //EII_FILIAL+EII_HAWB+EII_CODIGO
   EIG->(DbSetOrder(1))  //EIG_FILIAL+EIG_HAWB+EIG_CODIGO
   EIH->(dbSetOrder(1))  //EIH_FILIAL+EIH_HAWB
   SA4->(DbSetorder(1))  //A4_FILIAL+A4_COD
   EE6->(DbSetOrder(1))
   
   SW4->(DbSetOrder(1))  //W4_FILIAL+W4_PGI_NUM
   SWP->(DbSetOrder(1))  //WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI+WP_NR_MAQ
   SW5->(DBSetOrder(7))  //W5_FILIAL+W5_PGI_NUM+W5_SEQ_LI+STR(W5_SEQ, 2, 0)+W5_COD_I+STR(W5_PRECO, 15, 5)
   SJ5->(DbSetOrder(1))  //J5_FILIAL+J5_DE+J5_PARA+J5_COD_I
   SYR->(DbSetOrder(1))  //YR_FILIAL+YR_VIA+YR_ORIGEM+YR_DESTINO+YR_TIPTRAN
   
   EV1->(DbSetOrder(2))
   EV2->(DbSetOrder(2))
   EV3->(DbSetOrder(2))
   EV4->(DbSetOrder(2))
   EV5->(DbSetOrder(2))
   EV6->(DbSetOrder(2))
   EV7->(DbSetOrder(2))
   EV8->(DbSetOrder(2))
   EV9->(DbSetOrder(2))
   EVA->(DbSetOrder(2))
   EVB->(DbSetOrder(2))
   EVC->(DbSetOrder(1))
   EVD->(DbSetOrder(2))
   EVE->(DbSetOrder(1))
   EVF->(DbSetOrder(1))
   EVG->(DbSetOrder(1))
   EVH->(DbSetOrder(1))
   EVI->(DbSetOrder(1))
   EVK->(DbSetOrder(1))
      
   cIdLote := GetSXENum("EV0","EV0_ARQUIV")
   ConfirmSx8()
   
   cLoteAlt := cIdLote
   IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"ALTERA_NUMERACAO"),)
   cIdLote := cLoteAlt
   
   aArqsZIP := {}
   
   For i := 1 To Len(aItens)
      TMP->(DbGoTo(aItens[i]))
      
      If cServico == INT_DI
      
         aItens[i] := TMP->(W6_FILIAL+W6_HAWB)
         If !SW6->(DbSeek(aItens[i]))
            MsgInfo(STR0021,STR0005)  //"Erro ao localizar o processo de embarque" ## "Atenção"
            Break
         EndIf
      
         If cAcao <> DI_CONSULTA .And. !EIJ->(DbSeek(xFilial("EIJ")+SW6->W6_HAWB))
            MsgInfo(STR0024,STR0005)  //"Erro ao localizar as adições do processo de embarque" ## "Atenção"
            Break
         EndIf
         
         cNrTraDI := ""
         cNrDI := ""
         If cAcao == DI_CONSULTA
            EVC->(DbSetorder(2))
            If EVC->(DbSeek(xFilial("EVC")+SW6->W6_HAWB+SW6->W6_IDLOTE)) .And. !Empty(EVC->EVC_TRANSM)//EVC_FILIAL + EVC_HAWB + EVC_LOTE
               cNrTraDI := EVC->EVC_TRANSM
            ElseIf SW6->(FieldPos("W6_TRANSM")) > 0
               cNrTraDI := SW6->W6_TRANSM
            EndIf
            //RMD - 01/07/19 - Caso já possua o número da DI, guarda para utilizar na consulta
            If !Empty(SW6->W6_DI_NUM)
               cNrDI := SW6->W6_DI_NUM
            EndIf
            EVC->(DbSetOrder(1))
            If Empty(cNrTraDI) .And. Empty(cNrDI)
               MsgInfo(STR0093,STR0005) //"Não foram localizados transmissões anteriores para este processo." ## "Atenção"
               Break
            EndIf
         EndIf
         
         nVlTotPesoL := 0
            
         If !ExistDir(EICINTSISWEB:cDirGerados + cIdLote)
            If MakeDir(EICINTSISWEB:cDirGerados + cIdLote) <> 0
               MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
            EndIf
         EndIf
      
         EV1->(RecLock("EV1",.T.))
         EV1->EV1_FILIAL := xFilial("EV1")
         EV1->EV1_HAWB   := SW6->W6_HAWB
         If EV1->(FieldPos("EV1_FILORI")) > 0
            EV1->EV1_FILORI := SW6->W6_FILIAL
         EndIf
         EV1->EV1_LOTE   := cIdLote
         EV1->EV1_REGAL  := SW6->W6_REGAL
         //RMD - 16/07/19 - Se for consulta não gera as tabelas complementares, já que a consuta é feita somente pelo número da Transmissão ou da DI
         If cAcao <> DI_CONSULTA
         
         nVlTotLocEnt := 0
         DO While !EIJ->(Eof()) .And.;
		     EIJ->EIJ_FILIAL==xFilial("EIJ").AND.; 
 		     EIJ->EIJ_HAWB  ==SW6->W6_HAWB
            IF EIJ->EIJ_ADICAO == "MOD"
               EIJ->(DBSKIP())
               LOOP
            ENDIF         

            nVlTotPesoL+= Round(EIJ->EIJ_PESOL,5)
      
            nAcrecimo:=nDeducao:=0 
   
            nAcMoeNeg := 0
            nDeMoeNeg := 0
            EIN->(DBSEEK(xFilial("EIN")+EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO))
            DO WHILE EIN->(!EOF()) .AND. EIN->EIN_HAWB  ==EIJ->EIJ_HAWB   .AND.;
                                   EIN->EIN_ADICAO==EIJ->EIJ_ADICAO .AND.;
                                   EIN->EIN_FILIAL==xFilial("EIN")
               IF EIN->EIN_TIPO == '1'
                  nAcrecimo+=EIN->EIN_VLMMN
                  nAcMoeNeg+=EIN->EIN_VLMLE
               ELSE
                  nDeducao +=EIN->EIN_VLMMN
                  nDeMoeNeg+=EIN->EIN_VLMLE
               ENDIF
               EIN->(DBSKIP())
            ENDDO                                                    

            nVlTotLocEnt+=EIJ->EIJ_VLMMN+(nAcrecimo-nDeducao)
   
            EIJ->(DBSKIP())

         ENDDO 
         
         EIJ->(DbSeek(xFilial("EIJ")+SW6->W6_HAWB))
         Do While EIJ->(!Eof()) .AND. EIJ->EIJ_FILIAL == xFilial("EIJ") .AND. EIJ->EIJ_HAWB == SW6->W6_HAWB
            //nVlTotPesoL += Round(EIJ->EIJ_PESOL,5)
            cPaisProc   := EIJ->EIJ_PAISPR
            cURFEnt     := EIJ->EIJ_URFENT  
         
            IF EIJ->EIJ_ADICAO == "MOD" // GFP - 24/04/2015
               EIJ->(DBSKIP())
               LOOP
            ENDIF  
            
            EV2->(RecLock("EV2",.T.))
         
            If EIN->(DbSeek(xFilial("EIN")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
               Do While !EIN->(Eof()) .AND. EIN->EIN_FILIAL == xFilial("EIN") .AND.; 
                        EIN->EIN_HAWB == EIJ->EIJ_HAWB .AND. EIN->EIN_ADICAO == EIJ->EIJ_ADICAO
                  If EIN->EIN_TIPO = "1"
                     cCodEIN := EIN->EIN_CODIGO
                     If Left(cCodEIN, 1) == "0"
                        cCodEIN := IncSpace(Right(cCodEIN, 1), 2, .F.)
                     EndIf   
                     If RecLock("EV3",.T.)
                        EV3->EV3_FILIAL := xFilial("EV3")
                        EV3->EV3_HAWB   := SW6->W6_HAWB
                        EV3->EV3_ADICAO := EIJ->EIJ_ADICAO
                        EV3->EV3_LOTE   := cIdLote
                        EV3->EV3_ACRES  := cCodEIN
                        EV3->EV3_DESC   := EIN->EIN_DESC
                        EV3->EV3_MOE    := Posicione("SYF",1,xFilial("SYF")+EIN->EIN_FOBMOE,"YF_COD_GI")
                        EV3->EV3_DEMOE  := Posicione("SYF",1,xFilial("SYF")+EIN->EIN_FOBMOE,"YF_DESC_SI")
                        EV3->EV3_VLMLE  := SetTamanho(EIN->EIN_VLMLE,13,2)
                        EV3->EV3_VLMMN  := SetTamanho(EIN->EIN_VLMMN,13,2)
                        EV3->(MsUnlock())
                     EndIf             
                  EndIf
                  EIN->(DbSkip())
               EndDo        
            EndIf
         
            EV2->EV2_FILIAL := xFilial("EV2")
            EV2->EV2_HAWB   := SW6->W6_HAWB
            EV2->EV2_LOTE   := cIdLote
         
            If ChkFile("EJ9")//ChkFile("EJ9",.F.) 
               If EJ9->(DbSeek(xFilial("EJ9")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
                  Do While !EJ9->(Eof()) .AND. EJ9->EJ9_FILIAL == xFilial("EJ9") .AND.; 
                           EJ9->EJ9_HAWB == SW6->W6_HAWB .AND. EJ9->EJ9_ADICAO == EIJ->EIJ_ADICAO
                     If lMERCODI .AND. !EMPTY(EJ9->EJ9_DEMERC)   
                        If RecLock("EVI",.T.)
                           EVI->EVI_FILIAL := xFilial("EVI")
                           EVI->EVI_HAWB   := SW6->W6_HAWB
                           EVI->EVI_ADICAO := EIJ->EIJ_ADICAO
                           EVI->EVI_LOTE   := cIdLote
                           EVI->EVI_DICERT := EJ9->EJ9_DICERT
                           EVI->EVI_DEMERC := EJ9->EJ9_DEMERC
                           EVI->EVI_ITDICE := EJ9->EJ9_ITDICE
                           EVI->EVI_PAISEM := EJ9->EJ9_PAISEM
                           EVI->EVI_QTDCER := SetTamanho(EJ9->EJ9_QTDCER,9,5)
                           EVI->EVI_REFIN := EJ9->EJ9_REFINA
                           EVI->EVI_REINI := EJ9->EJ9_REINIC

                           EVI->(MsUnlock())
                          
                       
                        EndIf
                     EndIf
                     EJ9->(DbSkip())
                  EndDo
               EndIf
            ElseIf lMERCODI .AND. !EMPTY(EIJ->EIJ_DEMERC)
               If RecLock("EVI",.T.)
                  EVI->EVI_FILIAL := xFilial("EVI")
                  EVI->EVI_HAWB   := SW6->W6_HAWB
                  EVI->EVI_ADICAO := EIJ->EIJ_ADICAO
                  EVI->EVI_LOTE   := cIdLote
                  EVI->EVI_DICERT := EIJ->EIJ_DICERT
                  EVI->EVI_DEMERC := EIJ->EIJ_DEMERC
                  EVI->EVI_ITDICE := EIJ->EIJ_ITDICE
                  EVI->EVI_PAISEM := EIJ->EIJ_PAISEM
                  EVI->EVI_QTDCER := SetTamanho(EIJ->EIJ_QTDCER,9,5)
                  EVI->EVI_REFIN := EIJ->EIJ_REFINA
                  EVI->EVI_REINI := EIJ->EIJ_REINIC

                  EVI->(MsUnlock())
               EndIf
            EndIf

            EV2->EV2_INCOTE := EIJ->EIJ_INCOTE
            EV2->EV2_LOCVEN := EIJ->EIJ_LOCVEN
            EV2->EV2_METVAL := EIJ->EIJ_METVAL
            EV2->EV2_DEMET  := ""
            EV2->EV2_MOE1   := Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOEDA,"YF_COD_GI")
            EV2->EV2_DEMO1  := Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOEDA,"YF_DESC_SI")
            EV2->EV2_VLMLE  := SetTamanho(EIJ->EIJ_VLMLE,13,2)
            EV2->EV2_VLMMN  := SetTamanho(EIJ->EIJ_VLMMN,13,2)
         
            EV2->EV2_TIPCOB := EIJ->EIJ_TIPCOB
            EV2->EV2_DECON  := Posicione("SJ6",1,xFilial("SJ6")+EIJ->EIJ_TIPCOB,"J6_DESC")
            EV2->EV2_INSTFI := EIJ->EIJ_INSTFI
            EV2->EV2_DEINFI := Posicione("SJ7",1,xFilial("SJ7")+EIJ->EIJ_INSTFI,"J7_DESC")
            EV2->EV2_MOTIVO := EIJ->EIJ_MOTIVO
            EV2->EV2_DEMOT  := Posicione("SJ8",1,xFilial("SJ8")+EIJ->EIJ_MOTIVO,"J8_DESC")
            EV2->EV2_NRROF  := EIJ->EIJ_NRROF
            EV2->EV2_VLRCB  := ""

            EV2->EV2_PAISPR := EIJ->EIJ_PAISPR
            EV2->EV2_DEPAPR := Posicione("SYA",1,xFilial("SYA")+EIJ->EIJ_PAISPR,"YA_DESCR")
            EV2->EV2_URFENT := EIJ->EIJ_URFENT
            EV2->EV2_DEUFEN := Posicione("SJ0",1,xFilial("SJ0")+EIJ->EIJ_URFENT,"J0_DESC")
            SYQ->(dbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA))
            EV2->EV2_VIA    := SubStr(SYQ->YQ_COD_DI,1,1)
            EV2->EV2_DEVIA  := SYQ->YQ_DESCR
            EV2->EV2_APLME  := ""
            EV2->EV2_NALANC := EIJ->EIJ_NALANC
            EV2->EV2_NALASH := EIJ->EIJ_NALASH
            EV2->EV2_TEC    := EIJ->EIJ_TEC
            EV2->EV2_CONDI  := ""
            EV2->EV2_QT_EST := SetTamanho(EIJ->EIJ_QT_EST,9,5)
            EV2->EV2_UMEST  := ""
            EV2->EV2_DENCM  := Posicione("SYD",1,xFilial("SYD")+EIJ->EIJ_TEC,"YD_DESC_P")
            EV2->EV2_PESOL  := SetTamanho(EIJ->EIJ_PESOL,10,5)
         
            EV2->EV2_SUALII := If(lSuframa,SetTamanho(EIJ->EIJ_ALR_II,5,0),"")
            EV2->EV2_IDSUF  := SetTamanho(0,6,2)
            EV2->EV2_VLDES  := SetTamanho(0,13,2)
            EV2->EV2_VLDSU  := SetTamanho(0,13,2)
            EV2->EV2_VLRSU  := If(lSuframa,SetTamanho(EIJ->EIJ_VL_II,13,2),"")
            EV2->EV2_VLRES  := If(lSuframa,SetTamanho(EIJ->EIJ_VL_II,13,2),"")

            If EIN->(DbSeek(xFilial("EIN")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
               Do While !EIN->(Eof()) .AND. EIN->EIN_FILIAL == xFilial("EIN") .AND.; 
                        EIN->EIN_HAWB == EIJ->EIJ_HAWB .AND. EIN->EIN_ADICAO == EIJ->EIJ_ADICAO
                  If EIN->EIN_TIPO = "2"
                     cCodEIN := EIN->EIN_CODIGO
                     If Left(cCodEIN, 1) == "0"
                        cCodEIN := IncSpace(Right(cCodEIN, 1), 2, .F.)
                     EndIf 
                     If RecLock("EV4",.T.)
                        EV4->EV4_FILIAL := xFilial("EV4")
                        EV4->EV4_HAWB   := SW6->W6_HAWB
                        EV4->EV4_ADICAO := EIJ->EIJ_ADICAO
                        EV4->EV4_LOTE   := cIdLote
                        EV4->EV4_DEDU   := cCodEIN
                        EV4->EV4_DESC   := EIN->EIN_DESC
                        EV4->EV4_MOE    := Posicione("SYF",1,xFilial("SYF")+EIN->EIN_FOBMOE,"YF_COD_GI")
                        EV4->EV4_DEMOE  := Posicione("SYF",1,xFilial("SYF")+EIN->EIN_FOBMOE,"YF_DESC_SI")
                        EV4->EV4_VLMLE  := SetTamanho(EIN->EIN_VLMLE,13,2)
                        EV4->EV4_VLMMN  := SetTamanho(EIN->EIN_VLMMN,13,2)
                        EV4->(MsUnlock())
                     EndIf
                  EndIf
                  EIN->(DbSkip())
               EndDo        
            EndIf

            If EIL->(DbSeek(xFilial("EIL")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
               Do While !EIL->(Eof()) .AND. EIL->EIL_FILIAL == xFilial("EIL") .AND.; 
                        EIL->EIL_HAWB == EIJ->EIJ_HAWB .AND. EIL->EIL_ADICAO == EIJ->EIJ_ADICAO
                  If RecLock("EV5",.T.)
                     EV5->EV5_FILIAL := xFilial("EV5")
                     EV5->EV5_HAWB   := SW6->W6_HAWB
                     EV5->EV5_ADICAO := EIJ->EIJ_ADICAO
                     EV5->EV5_LOTE   := cIdLote
                     EV5->EV5_DESTAQ := EIL->EIL_DESTAQ
                     EV5->(MsUnlock())
                  EndIf          
                  EIL->(DbSkip())
               EndDo        
            EndIf

            If EIK->(DbSeek(xFilial("EIK")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
               Do While !EIK->(Eof()) .AND. EIK->EIK_FILIAL == xFilial("EIK") .AND.; 
                        EIK->EIK_HAWB == EIJ->EIJ_HAWB .AND. EIK->EIK_ADICAO == EIJ->EIJ_ADICAO
                  If RecLock("EV6",.T.)
                     EV6->EV6_FILIAL := xFilial("EV6")
                     EV6->EV6_HAWB   := SW6->W6_HAWB
                     EV6->EV6_ADICAO := EIJ->EIJ_ADICAO
                     EV6->EV6_LOTE   := cIdLote
                     EV6->EV6_TIPVIN := EIK->EIK_TIPVIN
                     EV6->EV6_DOCVIN := EIK->EIK_DOCVIN
                     EV6->(MsUnlock())
                  EndIf          
                  EIK->(DbSkip())
               EndDo        
            EndIf

            SW8->(DbSeek(xFilial("SW8")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
            SA2->(dbSeek(xFilial("SA2")+SW8->W8_FABR+EICRetLoja("SW8", "W8_FABLOJ")))
            EV2->EV2_MUN1   := If(EIJ->EIJ_FABFOR == "2",SA2->A2_MUN,"")
            EV2->EV2_ENDCO1 := If(EIJ->EIJ_FABFOR == "2",SA2->A2_ENDCOMP,"")
            EV2->EV2_EST1   := If(EIJ->EIJ_FABFOR == "2",SA2->A2_ESTADO,"")
            EV2->EV2_END1   := If(EIJ->EIJ_FABFOR == "2",SA2->A2_END,"")
            EV2->EV2_NOME1  := If(EIJ->EIJ_FABFOR == "2",SA2->A2_NOME,"")
            EV2->EV2_NREND1 := If(EIJ->EIJ_FABFOR == "2",SA2->A2_NR_END,"")
            SA2->(DbSeek(xFilial("SA2")+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")))	
            EV2->EV2_MUN2   := SA2->A2_MUN
            EV2->EV2_ENDCO2 := SA2->A2_ENDCOMP
            EV2->EV2_EST2   := SA2->A2_ESTADO
            EV2->EV2_END2   := SA2->A2_END
            EV2->EV2_NOME2  := SA2->A2_NOME
            EV2->EV2_NREND2 := SA2->A2_NR_END
            EV2->EV2_VLFRET := If(AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE"),SetTamanho(0,13,2),SetTamanho(EIJ->EIJ_VLFRET,13,2))
            EV2->EV2_VFREMN := SetTamanho(EIJ->EIJ_VFREMN,13,2)
         
            EV2->EV2_ACO_II := EIJ->EIJ_ACO_II         
            EV2->EV2_TACOII := EIJ->EIJ_TACOII

            EV2->EV2_FUNREG := EIJ->EIJ_FUNREG
            EV2->EV2_MOTADI := EIJ->EIJ_MOTADI
            EV2->EV2_REGTRI := EIJ->EIJ_REGTRI

            If !Empty(AllTrim(EIJ->EIJ_ASSVIC))
               If RecLock("EVK",.T.)
                  EVK->EVK_FILIAL := xFilial("EVK")
                  EVK->EVK_HAWB   := SW6->W6_HAWB
                  EVK->EVK_ADICAO := EIJ->EIJ_ADICAO
                  EVK->EVK_LOTE   := cIdLote
                  EVK->EVK_ASSVIC := EIJ->EIJ_ASSVIC
                  EVK->EVK_ANOVIC := EIJ->EIJ_ANOVIC
                  EVK->EVK_ATOVIC := EIJ->EIJ_ATOVIC
                  EVK->EVK_EX_VIC := EIJ->EIJ_EX_VIC
                  EVK->EVK_NROVIC := EIJ->EIJ_NROVIC
                  EVK->EVK_ORGVIC := EIJ->EIJ_ORGVIC
                  EVK->(MsUnlock())
               EndIf
            EndIf
            If !Empty(AllTrim(EIJ->EIJ_ASSVIB))
               If RecLock("EVK",.T.)
                  EVK->EVK_FILIAL := xFilial("EVK")
                  EVK->EVK_HAWB   := SW6->W6_HAWB
                  EVK->EVK_ADICAO := EIJ->EIJ_ADICAO
                  EVK->EVK_LOTE   := cIdLote
                  EVK->EVK_ASSVIC := EIJ->EIJ_ASSVIB
                  EVK->EVK_ANOVIC := EIJ->EIJ_ANOVIB
                  EVK->EVK_ATOVIC := EIJ->EIJ_ATOVIB
                  EVK->EVK_EX_VIC := EIJ->EIJ_EX_VIB
                  EVK->EVK_NROVIC := EIJ->EIJ_NROVIB
                  EVK->EVK_ORGVIC := EIJ->EIJ_ORGVIB
                  EVK->(MsUnlock())
               EndIf
           EndIf
			 If !Empty(AllTrim(EIJ->EIJ_ASSII))
			    If RecLock("EVK",.T.)
                  EVK->EVK_FILIAL := xFilial("EVK")
                  EVK->EVK_HAWB   := SW6->W6_HAWB
                  EVK->EVK_ADICAO := EIJ->EIJ_ADICAO
                  EVK->EVK_LOTE   := cIdLote
                  EVK->EVK_ASSVIC := EIJ->EIJ_ASSII
                  EVK->EVK_ANOVIC := EIJ->EIJ_ANO_II
                  EVK->EVK_ATOVIC := EIJ->EIJ_ATO_II
                  EVK->EVK_EX_VIC := EIJ->EIJ_EX_II
                  EVK->EVK_NROVIC := EIJ->EIJ_NRATII
                  EVK->EVK_ORGVIC := EIJ->EIJ_ORG_II
                  EVK->(MsUnlock())
               EndIf
            EndIf
			 If !Empty(AllTrim(EIJ->EIJ_ASSIPI))
			    If RecLock("EVK",.T.)
                  EVK->EVK_FILIAL := xFilial("EVK")
                  EVK->EVK_HAWB   := SW6->W6_HAWB
                  EVK->EVK_ADICAO := EIJ->EIJ_ADICAO
                  EVK->EVK_LOTE   := cIdLote
                  EVK->EVK_ASSVIC := EIJ->EIJ_ASSIPI
                  EVK->EVK_ANOVIC := EIJ->EIJ_ANOIPI
                  EVK->EVK_ATOVIC := EIJ->EIJ_ATOIPI
                  EVK->EVK_EX_VIC := EIJ->EIJ_EX_IPI
                  EVK->EVK_NROVIC := EIJ->EIJ_NROIPI
                  EVK->EVK_ORGVIC := EIJ->EIJ_ORGIPI
                  EVK->(MsUnlock())
               EndIf
            EndIf
			 If !Empty(AllTrim(EIJ->EIJ_ASSDUM))
			    If RecLock("EVK",.T.)
                  EVK->EVK_FILIAL := xFilial("EVK")
                  EVK->EVK_HAWB   := SW6->W6_HAWB
                  EVK->EVK_ADICAO := EIJ->EIJ_ADICAO
                  EVK->EVK_LOTE   := cIdLote
                  EVK->EVK_ASSVIC := EIJ->EIJ_ASSDUM
                  EVK->EVK_ANOVIC := EIJ->EIJ_ANODUM
                  EVK->EVK_ATOVIC := EIJ->EIJ_ATODUM
                  EVK->EVK_EX_VIC := EIJ->EIJ_EX_NCM
                  EVK->EVK_NROVIC := EIJ->EIJ_NRODUM
                  EVK->EVK_ORGVIC := EIJ->EIJ_ORGDUM
                  EVK->(MsUnlock())
               EndIf
			 EndIf
            SW8->(DbSeek(xFilial("SW8")+SW6->W6_HAWB+EIJ->EIJ_ADICAO))
            Do While SW8->(!Eof()) .AND. SW8->W8_FILIAL == xFilial("SW8") .AND.;
                     SW8->W8_HAWB == SW6->W6_HAWB .AND. SW8->W8_ADICAO == EIJ->EIJ_ADICAO
            
               SB1->(DbSeek(xFilial("SB1")+SW8->W8_COD_I))      
               SW9->(DbSeek(xFilial("SW9")+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+EIJ->EIJ_HAWB))    
        
               cUMde := BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN,SW8->W8_CC+SW8->W8_SI_NUM, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))
               SAH->(DbSetOrder(1))  //AH_FILIAL+AH_UNIMED
               SAH->(DBSEEK(xFilial("SAH")+cUMde))
            
               If lExiste_Midia .AND. SB1->B1_MIDIA $ cSim
                  SW2->(DBSEEK(xFILIAL("SW2")+SW8->W8_PO_NUM))
                  nQtdMerc := SW8->W8_QTDE * SB1->B1_QTMIDIA
                  nVLMCV:=DI500Trans(((SW2->W2_VLMIDIA * nQtdMerc)+SW8->W8_FRETEIN) /nQtdMerc,7)
               Else                                         
                  nQtdMerc := SW8->W8_QTDE
                  nVLMCV := DI500RetVal("ITEM_INV", "TAB", .T.)
                  nVLMCV := DI500Trans(nVLMCV/nQtdMerc,7)
               EndIf
            
               mMemo := ""
               cMemo := ""
               If !EMPTY(SW8->W8_DESC_DI)
                  mMemo := MSMM(SW8->W8_DESC_DI,AvSx3("W8_DESC_VM",3)) 
               EndIf
               If EMPTY(mMemo)
                  mMemo := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3)) 
               EndIf
               If EasyGParam("MV_PN_DI",,.F.)
                  mMemo+= " - " + ALLTRIM(TRANS(SW8->W8_COD_I,AVSX3("B1_COD",6)))
                  SW3->(DbSeek(xFilial("SW3")+SW8->W8_PO_NUM+SW8->W8_POSICAO))
                  If !Empty(SW3->W3_PART_N)   
                     mMemo+= " - " + SW3->W3_PART_N
                  ElseIf EICSFabFor(xFilial("SA5")+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))
                     mMemo+= " - "+ ALLTRIM(SA5->A5_CODPRF)
                  EndIf    
               EndIf
		        mMemo := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
		        cMemo := ""
               For j := 1 To MlCount(mMemo,AvSx3("W8_DESC_VM",3))
                  cMemo += AllTrim(MemoLine(mMemo,AvSx3("W8_DESC_VM",3),j)) + " "
               Next j
            
               If RecLock("EV7",.T.)
                  EV7->EV7_FILIAL := xFilial("EV7")
                  EV7->EV7_HAWB   := SW6->W6_HAWB
                  EV7->EV7_ADICAO := EIJ->EIJ_ADICAO
                  EV7->EV7_LOTE   := cIdLote
                  EV7->EV7_DESC   := cMemo
                  EV7->EV7_QTD    := SetTamanho(nQtdMerc,9,5)
                  EV7->EV7_UM     := LEFT(SAH->AH_DESCPO,20)
                  EV7->EV7_VLTOT  := SetTamanho(0,11,2)
                  EV7->EV7_VLUNI  := SetTamanho(nVLMCV,13,7)
                  EV7->EV7_NRSEQ  := SW8->W8_SEQ_ADI
                  EV7->(MsUnlock())
               EndIf   
               SW8->(DbSkip())
            EndDo
            
            //NCF - 07/04/2020 - Gravação da EV8 com base na EIM
            cTmpTabEIM := GetNextAlias()
            cFilEIM    := GetFilEIM("DI")
            cFaseEIM   := AvKey('DI','EIM_FASE')

            EIM->(DbSetOrder(3)) // EIM_FILIAL+EIM_FASE+EIM_HAWB+EIM_CODIGO+EIM_NCM
            lEIMAdicInf := EIM->(   DbSeek( cFilEIM + cFaseEIM + EIJ->EIJ_HAWB + EIJ->EIJ_NVE + EIJ->EIJ_TEC )  .And. !Empty(EIM_ADICAO)   )
            cWhereCond := If( lEIMAdicInf , "% EIM_ADICAO = '"+EIJ->EIJ_ADICAO+"' %" , "% EIM_CODIGO = '"+EIJ->EIJ_NVE+"' %" )
            BeginSQL Alias cTmpTabEIM
               SELECT EIM_NIVEL, EIM_ATRIB, EIM_ESPECI, EIM_ADICAO, EIM_CODIGO
               FROM %table:EIM% EIM
               WHERE EIM.%NotDel%
               AND EIM.EIM_FILIAL = %Exp:cFilEIM%
               AND EIM.EIM_HAWB   = %Exp:EIJ->EIJ_HAWB%
               AND %Exp:cWhereCond%
               AND EIM.EIM_FASE   = %Exp:cFaseEIM%
               ORDER BY EIM_NIVEL, EIM_ATRIB, EIM_ESPECI
            EndSql
            DO WHILE (cTmpTabEIM)->(!Eof())
               If RecLock("EV8",.T.)
                  EV8->EV8_FILIAL := xFilial("EV8")
                  EV8->EV8_HAWB   := SW6->W6_HAWB
                  EV8->EV8_ADICAO := EIJ->EIJ_ADICAO
                  EV8->EV8_LOTE   := cIdLote
                  EV8->EV8_NIVEL  := (cTmpTabEIM)->EIM_NIVEL
                  EV8->EV8_ATRIB  := (cTmpTabEIM)->EIM_ATRIB
                  EV8->EV8_ESPECI := (cTmpTabEIM)->EIM_ESPECI
                  EV8->(MsUnlock())
               EndIf   
               (cTmpTabEIM)->(DbSkip()) 
            ENDDO
            (cTmpTabEIM)->(DbCloseArea())

            EV2->EV2_ADICAO := EIJ->EIJ_ADICAO
            EV2->EV2_DINUM  := ""
            EV2->EV2_NROLI  := EIJ->EIJ_NROLI
            EV2->EV2_PAIPRO := SW6->W6_PAISPRO
         
            EV2->EV2_FUN_PC := EIJ->EIJ_FUN_PC
            EV2->EV2_REG_PC := EIJ->EIJ_REG_PC
            EV2->EV2_DFPC   := Posicione("SJY",1,xFilial("SJY")+EIJ->EIJ_FUN_PC,"JY_DESC")
            EV2->EV2_FRB_PC := EIJ->EIJ_FRB_PC
            EV2->EV2_DERPC  := Posicione("SJZ",1,xFilial("SJZ")+EIJ->EIJ_FRB_PC,"JZ_DESC")
            EV2->EV2_FABFOR := EIJ->EIJ_FABFOR
            EV2->EV2_VSEGLE := If(AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEGURO"),SetTamanho(0,13,2),SetTamanho(EIJ->EIJ_VSEGLE,13,2))
            EV2->EV2_VSEGMN := SetTamanho(EIJ->EIJ_VSEGMN,13,2)
            EV2->EV2_NRSEQ  := ""
            EV2->EV2_COMVEN := ""
            EV2->EV2_APLME  := EIJ->EIJ_APLICM
            EV2->EV2_FRMOE  := If(AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE"),"",Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOEFRE,"YF_COD_GI"))
            EV2->EV2_SEMOE  := If(AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEGURO"),"",Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOESEG,"YF_COD_GI"))

            SW8->(dbSeek( xFilial("SW8") + EIJ->EIJ_HAWB + EIJ->EIJ_ADICAO ))
            SA2->(dbSeek( xFilial("SA2") + SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ") ))
            EV2->EV2_PAIAME := SA2->A2_PAIS            
            nRecSA2 := SA2->(Recno())
              
            SA2->(dbSeek( xFilial("SA2") + SW8->W8_FABR+EICRetLoja("SW8", "W8_FABLOJ") ))	
            If EIJ->EIJ_FABFOR == "2"
               EV2->EV2_PAIOME := SA2->A2_PAIS
            ElseIf EIJ->EIJ_FABFOR == "1"
               SA2->(DbGoTo(nRecSA2))
               EV2->EV2_PAIOME := SA2->A2_PAIS
            Else
               If EIJ->(FieldPos("EIJ_PAISOR")) > 0 .And. !Empty(EIJ->EIJ_PAISOR)
                  EV2->EV2_PAIOME := EIJ->EIJ_PAISOR
               Else
                  EV2->EV2_PAIOME := SA2->A2_PAIS
               EndIf
            EndIf
            
            EV2->EV2_VINCCO := EIJ->EIJ_VINCCO
            EV2->EV2_BENSEN := If(EIJ->EIJ_BENSEN="1","S","N")
            EV2->EV2_MATUSA := If(EIJ->EIJ_MATUSA="1","S","N")
            EV2->EV2_IDCERT := IF(Empty(EIJ->EIJ_IDCERT),"1",EIJ->EIJ_IDCERT)
            EV2->EV2_COMPLE := EIJ->EIJ_COMPLE
            EV2->EV2_VLM360 := SetTamanho(EIJ->EIJ_VLM360,13,2)
          
            // II
            If EVG->(RecLock("EVG",.T.))
               EVG->EVG_FILIAL := xFilial("EVG")
               EVG->EVG_HAWB   := SW6->W6_HAWB
               EVG->EVG_ADICAO := EIJ->EIJ_ADICAO
               EVG->EVG_LOTE   := cIdLote
               EVG->EVG_IDIMP  := "1"
               EVG->EVG_TPIMP  := EIJ->EIJ_TPAII
               EVG->EVG_BASE   := SetTamanho(EIJ->EIJ_BAS_II,13,2)
               EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALI_II,3,2)
               EVG->EVG_VLIPTA := SetTamanho(EIJ->EIJ_VL_II,13,2)
               EVG->EVG_UNUESP := ""
               EVG->EVG_QTRIPI := SetTamanho(0,5,0)
               EVG->EVG_QTAES  := SetTamanho(0,9,0)
               EVG->EVG_ALIPES := SetTamanho(0,5,5)
               EVG->EVG_VLIPES := SetTamanho(0,13,2)
               EVG->EVG_REGIPI := SetTamanho(0,1,0)
               EVG->EVG_ALRED  := SetTamanho(EIJ->EIJ_ALR_II,3,2)
               EVG->EVG_PERRED := SetTamanho(EIJ->EIJ_PR_II,3,2)
               EVG->EVG_ALAT   := SetTamanho(EIJ->EIJ_ALA_II,3,2)
               EVG->EVG_VLIIAC := SetTamanho(EIJ->EIJ_VLR_II,13,2)
               EVG->EVG_VLIPTD := SetTamanho(EIJ->EIJ_DEVII,13,2)
               EVG->EVG_VLIPTR := SetTamanho(EIJ->EIJ_VLARII,13,2)
               EVG->EVG_NCTIPI := "0" 
               EVG->EVG_TPRECE := "0"

               EVG->(MsUnlock())
            EndIf
            
            // IPI
            If EVG->(RecLock("EVG",.T.))
               EVG->EVG_FILIAL := xFilial("EVG")
               EVG->EVG_HAWB   := SW6->W6_HAWB
               EVG->EVG_ADICAO := EIJ->EIJ_ADICAO
               EVG->EVG_LOTE   := cIdLote
               EVG->EVG_IDIMP  := "2"
               EVG->EVG_TPIMP  := EIJ->EIJ_TPAIPI
               EVG->EVG_BASE   := SetTamanho(EIJ->EIJ_BASIPI,13,2)
               EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALAIPI,3,2)
               EVG->EVG_VLIPTA := SetTamanho(EIJ->EIJ_VLAIPI,13,2)
               EVG->EVG_UNUESP := EIJ->EIJ_UNUIPI
               EVG->EVG_QTRIPI := SetTamanho(EIJ->EIJ_QTRIPI,5,0)
               EVG->EVG_QTAES  := SetTamanho(EIJ->EIJ_QTUIPI,9,0)
               EVG->EVG_ALIPES := SetTamanho(EIJ->EIJ_ALUIPI,5,5)
               EVG->EVG_VLIPES := SetTamanho(0,13,2)
               EVG->EVG_REGIPI := EIJ->EIJ_REGIPI
               EVG->EVG_ALRED  := SetTamanho(EIJ->EIJ_ALRIPI,3,2)
               EVG->EVG_PERRED := SetTamanho(EIJ->EIJ_PRIPI,3,2)
               EVG->EVG_ALAT   := SetTamanho(0,3,2)
               EVG->EVG_VLIIAC := SetTamanho(0,13,2)
               EVG->EVG_VLIPTD := SetTamanho(EIJ->EIJ_VLDIPI,13,2)
               EVG->EVG_VLIPTR := SetTamanho(EIJ->EIJ_VLAIPI,13,2)
               EVG->EVG_NCTIPI := EIJ->EIJ_NCTIPI
               EVG->EVG_TPRECE := EIJ->EIJ_TPRECE       
               EVG->(MsUnlock())
            EndIf
            
            nBasePIS := nVlAdVal := nVlEspec := 0
            If Empty(EIJ->EIJ_PRB_PC)      //Redução na Base de Calculo
               nBasePIS := EIJ->EIJ_BASPIS
            Else
               nBasePIS := EIJ->EIJ_BR_PIS //Base Reduzida
            EndIf
            
            IF EIJ->EIJ_TPAPIS = '1'
               nVlAdVal := nBasePIS * (EIJ->EIJ_ALAPIS/100)
            ELSE
               nVlEspec := EIJ->EIJ_QTUPIS * EIJ->EIJ_ALUPIS
            ENDIF
            
            // PIS
            If EVG->(RecLock("EVG",.T.))
               EVG->EVG_FILIAL := xFilial("EVG")
               EVG->EVG_HAWB   := SW6->W6_HAWB
               EVG->EVG_ADICAO := EIJ->EIJ_ADICAO
               EVG->EVG_LOTE   := cIdLote
               EVG->EVG_IDIMP  := "5"
               EVG->EVG_TPIMP  := EIJ->EIJ_TPAPIS
               EVG->EVG_BASE   := SetTamanho(nBasePIS,13,2)
               EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALAPIS,3,2)
               EVG->EVG_VLIPTA := SetTamanho(nVlAdVal,13,2)
               EVG->EVG_UNUESP := EIJ->EIJ_UNUPIS
               EVG->EVG_QTRIPI := SetTamanho(0,5,0)
               EVG->EVG_QTAES  := SetTamanho(EIJ->EIJ_QTUPIS,9,0)
               EVG->EVG_ALIPES := SetTamanho(EIJ->EIJ_ALUPIS,5,5)
               EVG->EVG_VLIPES := SetTamanho(nVlEspec,13,2)
               EVG->EVG_REGIPI := SetTamanho(0,1,0)
               EVG->EVG_ALRED  := SetTamanho(EIJ->EIJ_REDPIS,3,2)
               EVG->EVG_PERRED := SetTamanho(EIJ->EIJ_PRB_PC,3,2)
               EVG->EVG_ALAT   := SetTamanho(0,3,2)
               EVG->EVG_VLIIAC := SetTamanho(0,13,2)
               EVG->EVG_VLIPTD := SetTamanho(EIJ->EIJ_VLDPIS,13,2)
               EVG->EVG_VLIPTR := SetTamanho(EIJ->EIJ_VLRPIS,13,2)
               EVG->EVG_NCTIPI := SetTamanho(0,2,0)
               EVG->EVG_TPRECE := SetTamanho(0,2,0)    
               EVG->(MsUnlock())
            EndIf
            
            nBaseCOF := nVlAdVal := nVlEspec := 0
            If Empty(EIJ->EIJ_PRB_PC) //Redução na Base de Calculo
               nBaseCOF := EIJ->EIJ_BASCOF
            Else
               nBaseCOF := EIJ->EIJ_BR_COF //Base Reduzida
            EndIf

            IF EIJ->EIJ_TPACOF = '1'
               nVlAdVal := nBaseCOF * (EIJ->EIJ_ALACOF/100)
            ELSE
               nVlEspec := EIJ->EIJ_QTUCOF * EIJ->EIJ_ALUCOF
            ENDIF
            
            // COFINS
            If EVG->(RecLock("EVG",.T.))
               EVG->EVG_FILIAL := xFilial("EVG")
               EVG->EVG_HAWB   := SW6->W6_HAWB
               EVG->EVG_ADICAO := EIJ->EIJ_ADICAO
               EVG->EVG_LOTE   := cIdLote
               EVG->EVG_IDIMP  := "6"
               EVG->EVG_TPIMP  := EIJ->EIJ_TPACOF
               EVG->EVG_BASE   := SetTamanho(nBaseCOF,13,2)
               EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALACOF,3,2)
               EVG->EVG_VLIPTA := SetTamanho(nVlAdVal,13,2)
               EVG->EVG_UNUESP := EIJ->EIJ_UNUCOF
               EVG->EVG_QTRIPI := SetTamanho(0,5,0)
               EVG->EVG_QTAES  := SetTamanho(EIJ->EIJ_QTUCOF,9,0)
               EVG->EVG_ALIPES := SetTamanho(EIJ->EIJ_ALUCOF,5,5)
               EVG->EVG_VLIPES := SetTamanho(nVlEspec,13,2)
               EVG->EVG_REGIPI := SetTamanho(0,1,0)
               EVG->EVG_ALRED  := SetTamanho(EIJ->EIJ_REDCOF,3,2)
               EVG->EVG_PERRED := SetTamanho(EIJ->EIJ_PRB_PC,3,2)
               EVG->EVG_ALAT   := SetTamanho(0,3,2)
               EVG->EVG_VLIIAC := SetTamanho(0,13,2)
               EVG->EVG_VLIPTD := SetTamanho(EIJ->EIJ_VLDCOF,13,2)
               EVG->EVG_VLIPTR := SetTamanho(EIJ->EIJ_VLRCOF,13,2)
               EVG->EVG_NCTIPI := SetTamanho(0,2,0)
               EVG->EVG_TPRECE := SetTamanho(0,2,0)          
               EVG->(MsUnlock())
            EndIf
            
            // ANTI DUMPING
            If EVG->(RecLock("EVG",.T.))
               EVG->EVG_FILIAL := xFilial("EVG")
               EVG->EVG_HAWB   := SW6->W6_HAWB
               EVG->EVG_ADICAO := EIJ->EIJ_ADICAO
               EVG->EVG_LOTE   := cIdLote
               EVG->EVG_IDIMP  := "3"
               EVG->EVG_TPIMP  := EIJ->EIJ_TPADUM
               EVG->EVG_BASE   := SetTamanho(EIJ->EIJ_BAD_AD,13,2)
               EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALADDU,3,2)
               EVG->EVG_VLIPTA := SetTamanho(0,13,2)
               EVG->EVG_UNUESP := EIJ->EIJ_UNE_AD
               EVG->EVG_QTRIPI := SetTamanho(0,5,0)
               EVG->EVG_QTAES  := SetTamanho(EIJ->EIJ_BAE_AD,9,0) //EIJ->EIJ_UNE_AD
               EVG->EVG_ALIPES := SetTamanho(EIJ->EIJ_ALEADU,5,5)
               EVG->EVG_VLIPES := SetTamanho(0,13,2)
               EVG->EVG_REGIPI := SetTamanho(0,1,0)
               EVG->EVG_ALRED  := SetTamanho(0,3,2)
               EVG->EVG_PERRED := SetTamanho(0,3,2)
               EVG->EVG_ALAT   := SetTamanho(0,3,2)
               EVG->EVG_VLIIAC := SetTamanho(0,13,2)
               EVG->EVG_VLIPTD := SetTamanho(EIJ->EIJ_VLD_DU,13,2)
               EVG->EVG_VLIPTR := SetTamanho(EIJ->EIJ_VLR_DU,13,2)
               EVG->EVG_NCTIPI := SetTamanho(0,2,0)
               EVG->EVG_TPRECE := SetTamanho(0,2,0)       
               EVG->(MsUnlock())
            EndIf

            EV2->(MsUnlock())
			
            EIJ->(DbSkip())
         EndDo

         EIJ->(dbSeek(xFilial("EIJ")+SW6->W6_HAWB))
         DO While !EIJ->(Eof()) .And.;
	         	 EIJ->EIJ_FILIAL==xFilial("EIJ").AND.; 
          		 EIJ->EIJ_HAWB  ==SW6->W6_HAWB
            IF EIJ->EIJ_ADICAO == "MOD"
               EIJ->(DBSKIP())
               LOOP
            ENDIF         
   
            IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_FRETE") //EIJ->EIJ_INCOTE $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
               //nVlTotLocEnt-= NoRound( EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN) * SW6->W6_TX_FRET / nVlTotPesoL,2) //Trunca na 2a casa decimal. //NCF - 23/05/2012 - Siscomex está considerando arredondado
               nVlTotLocEnt-= DI500Trans(EIJ->EIJ_PESOL * SW6->(W6_VLFREPP+W6_VLFRECC-W6_VLFRETN) * SW6->W6_TX_FRET / nVlTotPesoL,2)
            ENDIF

            IF AvRetInco(EIJ->EIJ_INCOTE,"CONTEM_SEG")  //EIJ->EIJ_INCOTE $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
               nVlTotLocEnt -= EIJ->EIJ_VSEGMN
            ENDIF

            EIJ->(DBSKIP())
         ENDDO

         If EIF->(DbSeek(xFilial("EIF")+SW6->W6_HAWB))
            Do While !EIF->(Eof()) .AND. EIF->EIF_FILIAL == xFilial("EIF") .AND.; 
                     EIF->EIF_HAWB == SW6->W6_HAWB
               If RecLock("EV9",.T.)
                  EV9->EV9_FILIAL := xFilial("EV9")
                  EV9->EV9_HAWB   := SW6->W6_HAWB
                  EV9->EV9_LOTE   := cIdLote
                  EV9->EV9_CODIN  := EIF->EIF_CODIGO
                  EV9->EV9_DESCIN := EIF->EIF_DOCTO
                  If EV9->(FieldPos("EV9_SEQUEN")) > 0
                        EV9->EV9_SEQUEN := EIF->EIF_SEQUEN //THTS - 06/09/2017 - Para evitar erro de chave duplicada
                  EndIf
                  EV9->(MsUnlock())
               EndIf               
               EIF->(DbSkip())
            EndDo        
         EndIf
         
         EV1->EV1_ARMAZ  := SW6->W6_ARMAZEM
         EV1->EV1_REC_AL := SW6->W6_REC_ALF
         EV1->EV1_DEREAL := Posicione("SJA",1,xFilial("SJA")+SW6->W6_REC_ALF,"JA_DESCR")
         EV1->EV1_SETOR  := SW6->W6_SETORRA
         EV1->EV1_PROIMP := SW6->W6_PRO_IMP
         EV1->EV1_TPOPCA := ""
         EV1->EV1_DEOPCA := "" 
         EV1->EV1_CGCOUT := SW6->W6_CGC_OUT
         EV1->EV1_CHEG   := DtoS(SW6->W6_CHEG)
         SY4->(dbSeek(xFilial("SY4")+SW6->W6_AGENTE))
         EV1->EV1_CGCAG  := SY4->Y4_CGC
         EV1->EV1_PAISPR := SW6->W6_PAISPRO
         EV1->EV1_PS_BR  := SetTamanho(SW6->W6_PESO_BR,10,5)
         EV1->EV1_PS_LQ  := SetTamanho(nVlTotPesoL,10,5)
         EV1->EV1_UFRENT := cURFEnt
         EV1->EV1_DEUFEN := Posicione("SJ0",1,xFilial("SJ0")+cURFEnt,"J0_DESC")

         EV1->EV1_COLOC  := Posicione("SYR",1,xFilial("SYR")+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST,"YR_CID_ORI")
         EV1->EV1_COID   := SYR->YR_CID_ORI
         EV1->EV1_COIDM  := LEFT(SW6->W6_PRCARGA,18)
         EV1->EV1_COTPCD := SW6->W6_TIPOCON
         EV1->EV1_COTPDE := ""
         EV1->EV1_COUTIL := SW6->W6_UTILCON 
         EV1->EV1_DTDESE := DtoS(SW6->W6_DT_DESE)
         EV1->EV1_DTREG  := DtoS(SW6->W6_DTREG_D)
         EV1->EV1_TPDCH  := SW6->W6_TIPODOC
         EV1->EV1_DEDCH  := ""
         EV1->EV1_NUDCH  := SW6->W6_IDEMANI
         EV1->EV1_INSDES := ""

         EV1->EV1_VLFRCC := SetTamanho(SW6->W6_VLFRECC,13,2)
         EV1->EV1_FRTERN := SetTamanho(SW6->W6_VLFRETN,13,2)
         EV1->EV1_VLFRPP := SetTamanho(SW6->W6_VLFREPP,13,2)
         EV1->EV1_FRTORS := SetTamanho(ValorFrete(SW6->W6_HAWB,,,1,),13,2)
         SYT->(DbSeek(xFilial("SYT")+SW6->W6_IMPORT))
         EV1->EV1_CDTPIM := SYT->YT_TIPO
         EV1->EV1_CPFREP := SYT->YT_CPF_REP
         EV1->EV1_IMPBAI := SYT->YT_BAIRRO
         EV1->EV1_IMPCEP := SYT->YT_CEP
         EV1->EV1_IMPEND := Left(SYT->YT_ENDE,40)
         EV1->EV1_IMPCID := SYT->YT_CIDADE
         EV1->EV1_IMPENR := SetTamanho(SYT->YT_NR_END,6,0)
         EV1->EV1_IMPUF  := Alltrim(SYT->YT_ESTADO)
         EV1->EV1_IMPNOM := SYT->YT_NOME
         EV1->EV1_NOMREP := ""
         EV1->EV1_IMPNRO := SYT->YT_CGC
         
         mMemo := ""
         cMemo := ""
         mMemo := MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3))
         //mMemo := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
         cMemo := ""
         For k := 1 To MlCount(mMemo,AvSx3("W6_VM_COMP",3))
            cMemo += AllTrim(MemoLine(mMemo,AvSx3("W6_VM_COMP",3),k)) + ENTER
         Next k
         
         EV1->EV1_INFCOM := cMemo //MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3)) 
         EV1->EV1_TODODE := SetTamanho(0,13,2)
         EV1->EV1_TOEMRS := SetTamanho(nVlTotLocEnt,13,2)
         EV1->EV1_MODDES := SW6->W6_MODAL_D
         EV1->EV1_DI_NUM := SW6->W6_DI_NUM
         EV1->EV1_OPFUND := If(SW6->W6_FUNDAP="1","S","N")
         EV1->EV1_MOEFRE := Posicione("SYF",1,xFilial("SYF")+SW6->W6_FREMOED,"YF_COD_GI")
         EV1->EV1_MOESEG := Posicione("SYF",1,xFilial("SYF")+SW6->W6_SEGMOED,"YF_COD_GI")
         EV1->EV1_CDTRA  := If(cAcao == ANALISE,"1","2")
         EV1->EV1_PAIIM  := SYT->YT_PAIS
         EV1->EV1_COMIMP := If(SYT->(FieldPos("YT_COMPEND")) # 0,SYT->YT_COMPEND,"")
         EV1->EV1_TELIMP := SYT->YT_TEL_IMP
         SYQ->(dbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA))
         EV1->EV1_AGECA  := IF(!SubStr(SYQ->YQ_COD_DI,1,1)='9',"1","")
         EV1->EV1_TPPAG  := If(Empty(SW6->W6_CTAPGTO),"2","1")
         SA4->(DbSeek(xFilial("SA4") + SW6->W6_TRANSIN))
         EV1->EV1_NMIMP  := SA4->A4_NOME
         EV1->EV1_CONTA  := If(cAcao == REGISTRO,SW6->W6_CTAPGTO,"")
		  EV1->EV1_URFENT := SW6->W6_URF_ENT

        If EII->(DbSeek(xFilial("EII")+SW6->W6_HAWB))
           Do While !EII->(Eof()) .AND. EII->EII_FILIAL == xFilial("EII") .AND.; 
                     EII->EII_HAWB == SW6->W6_HAWB//EIJ->EIJ_HAWB
               If RecLock("EVA",.T.)
                  EVA->EVA_FILIAL := xFilial("EVA")
                  EVA->EVA_HAWB   := SW6->W6_HAWB
                  EVA->EVA_LOTE   := cIdLote
                  EVA->EVA_AGENCI := SubStr(SW6->W6_AGEPGTO,1,4)
                  EVA->EVA_BANCO  := SW6->W6_BCOPGTO            
                  EVA->EVA_CODREC := EII->EII_CODIGO
                  EVA->EVA_CONTA  := If(cAcao == REGISTRO,SW6->W6_CTAPGTO,"")
                  EVA->EVA_DT_PG  := DtoS(EII->EII_DT_PAG)
                  EVA->EVA_NMTPG  := ""
                  EVA->EVA_NRRET  := ""
                  EVA->EVA_VLJUR  := SetTamanho(0,7,2)//SetTamanho(nVlTotLocEnt,13,2)
                  EVA->EVA_VLMUL  := SetTamanho(0,7,2)//SetTamanho(nVlTotLocEnt,13,2)
                  EVA->EVA_VLREC  := SetTamanho(EII->EII_VLTRIB,13,2)
                  EVA->(MsUnlock())
               EndIf               
               EII->(DbSkip())
            EndDo        
         EndIf
      
         If EIG->(DbSeek(xFilial("EIG")+SW6->W6_HAWB))
            Do While !EIG->(Eof()) .AND. EIG->EIG_FILIAL == xFilial("EIG") .AND.; 
                     EIG->EIG_HAWB == SW6->W6_HAWB//EIJ->EIJ_HAWB
               If RecLock("EVB",.T.)
                  EVB->EVB_FILIAL := xFilial("EVB")
                  EVB->EVB_HAWB   := SW6->W6_HAWB
                  EVB->EVB_LOTE   := cIdLote
                  EVB->EVB_CODPV  := EIG->EIG_CODIGO
                  EVB->EVB_DESPV  := EIG->EIG_NUMERO          
                  EVB->(MsUnlock())
               EndIf               
               EIG->(DbSkip())
            EndDo        
         EndIf

         EV1->EV1_SEGMOE  := Posicione("SYF",1,xFilial("SYF")+SW6->W6_SEGMOED,"YF_COD_GI")
         EV1->EV1_SEGDEM  := Posicione("SYF",1,xFilial("SYF")+SW6->W6_SEGMOED,"YF_DESC_SI")
         EV1->EV1_SETOMO  := SetTamanho(SW6->W6_VL_USSE,13,2)
         EV1->EV1_SETORS  := SetTamanho(SW6->W6_VLSEGMN,13,2)
         EV1->EV1_SEQRET  := ""
         EV1->EV1_SITENT  := ""
         EV1->EV1_TPDECL  := SW6->W6_TIPODES
         EV1->EV1_DETPDE  := ""
         EV1->EV1_TOTADI  := SetTamanho(SW6->W6_QTD_ADI,3,0)
         EV1->EV1_URFDES  := SW6->W6_URF_DES
         EV1->EV1_DESURF  := Posicione("SJ0",1,xFilial("SJ0")+SW6->W6_URF_DES,"J0_DESC")
         SYQ->(dbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA))
         EV1->EV1_CODVIA  := SubStr(SYQ->YQ_COD_DI,1,1)
         EV1->EV1_MODVIA  := If(SW6->W6_MULTIMO="1","S","N")
         EV1->EV1_DESVIA  := SYQ->YQ_DESCR
         EV1->EV1_NOMTRA  := ""
         EE6->(DbSeek(xFilial("EE6")+SW6->W6_IDENTVE))
		  EV1->EV1_NMVEIC  := If(SubStr(SYQ->YQ_COD_DI,1,1)<>"7",LEFT(EE6->EE6_NOME,30),)
         EV1->EV1_NRVEIC  := If(Substr(SYQ->YQ_COD_DI,1,1)=="7",SW6->W6_IDENTVE,)
         EV1->EV1_CDPATR  := SW6->W6_PAISVEI
         EV1->EV1_DEPATR  := ""
         EV1->EV1_MAWB    := SW6->W6_MAWB
         EV1->EV1_DTEMB   := DTOS(SW6->W6_DT_EMB)
         EV1->(MsUnlock())
         
         If EIH->(dbSeek(xFilial("EIH")+SW6->W6_HAWB))
            Do While !EIH->(Eof()) .AND. EIH->EIH_FILIAL == xFilial("EIH") .AND.; 
                     EIH->EIH_HAWB == SW6->W6_HAWB
               If EVH->(RecLock("EVH",.T.))
                  EVH->EVH_FILIAL := xFilial("EVH")
                  EVH->EVH_HAWB   := SW6->W6_HAWB
                  EVH->EVH_LOTE   := cIdLote
                  EVH->EVH_TPEMB  := EIH->EIH_CODIGO
                  EVH->EVH_QTDVOL := SetTamanho(EIH->EIH_QTDADE,5,0)           
                  EVH->(MsUnlock())
               EndIf               
               EIH->(DbSkip())
            EndDo      
         EndIf

         If ChkFile("EJ9")//ChkFile("EJ9",.F.) 
            If EJ9->(DbSeek(xFilial("EJ9")+SW6->W6_HAWB))
               Do While !EJ9->(Eof()) .AND. EJ9->EJ9_FILIAL == xFilial("EJ9") .AND.; 
                        EJ9->EJ9_HAWB == SW6->W6_HAWB .AND. Empty(EJ9->EJ9_ADICAO)
                  If lMERCODI .AND. !EMPTY(EJ9->EJ9_DEMERC)
                     If RecLock("EVI",.T.)
                        EVI->EVI_FILIAL := xFilial("EVI")
                        EVI->EVI_HAWB   := SW6->W6_HAWB
                        EVI->EVI_ADICAO := ""
                        EVI->EVI_LOTE   := cIdLote
                        EVI->EVI_NUM    := EJ9->EJ9_DEMERC
                        EVI->EVI_REFIN  := EJ9->EJ9_REFINA
                        EVI->EVI_REINI  := EJ9->EJ9_REINIC
                        EVI->(MsUnlock())
                     EndIf
                  EndIf
                  EJ9->(DbSkip())
               EndDo
            EndIf
         ElseIf lMERCODI .AND. !EMPTY(SW6->W6_DEMERCO)
            If RecLock("EVI",.T.)
               EVI->EVI_FILIAL := xFilial("EVI")
               EVI->EVI_HAWB   := SW6->W6_HAWB
               EVI->EVI_ADICAO := ""
               EVI->EVI_LOTE   := cIdLote
               EVI->EVI_NUM    := SW6->W6_DEMERCO
               EVI->EVI_REFIN  := SW6->W6_REFINAL
               EVI->EVI_REINI  := SW6->W6_REINIC
               EVI->(MsUnlock())
            EndIf
         EndIf
      EndIf
		
         cArquivo := AllTrim(EV1->EV1_HAWB)
         AjustaNome(@cArquivo)
         EV1->(DbSeek(xFilial("EV1")+AvKey(cIdLote,"EV1_LOTE")+AvKey(SW6->W6_HAWB,"EV1_HAWB")))
         EV2->(DbSeek(xFilial("EV2")+AvKey(cIdLote,"EV2_LOTE")+AvKey(EV1->EV1_HAWB,"EV2_HAWB")))
         EV3->(DbSeek(xFilial("EV3")+AvKey(cIdLote,"EV3_LOTE")+AvKey(EV1->EV1_HAWB,"EV3_HAWB")))
         EV4->(DbSeek(xFilial("EV4")+AvKey(cIdLote,"EV4_LOTE")+AvKey(EV1->EV1_HAWB,"EV4_HAWB")))
         EV5->(DbSeek(xFilial("EV5")+AvKey(cIdLote,"EV5_LOTE")+AvKey(EV1->EV1_HAWB,"EV5_HAWB")))
         EV6->(DbSeek(xFilial("EV6")+AvKey(cIdLote,"EV6_LOTE")+AvKey(EV1->EV1_HAWB,"EV6_HAWB")))
         EV7->(DbSeek(xFilial("EV7")+AvKey(cIdLote,"EV7_LOTE")+AvKey(EV1->EV1_HAWB,"EV7_HAWB")))
         EV8->(DbSeek(xFilial("EV8")+AvKey(cIdLote,"EV8_LOTE")+AvKey(EV1->EV1_HAWB,"EV8_HAWB")))
         EV9->(DbSeek(xFilial("EV9")+AvKey(cIdLote,"EV9_LOTE")+AvKey(EV1->EV1_HAWB,"EV9_HAWB")))
         EVA->(DbSeek(xFilial("EVA")+AvKey(cIdLote,"EVA_LOTE")+AvKey(EV1->EV1_HAWB,"EVA_HAWB")))
         EVB->(DbSeek(xFilial("EVB")+AvKey(cIdLote,"EVB_LOTE")+AvKey(EV1->EV1_HAWB,"EVB_HAWB")))
         EVG->(DbSeek(xFilial("EVG")+AvKey(EV1->EV1_HAWB,"EVG_HAWB")+AvKey(cIdLote,"EVG_LOTE")))
         EVH->(DbSeek(xFilial("EVH")+AvKey(EV1->EV1_HAWB,"EVH_HAWB")+AvKey(cIdLote,"EVH_LOTE")))
         EVI->(DbSeek(xFilial("EVI")+AvKey(EV1->EV1_HAWB,"EVI_HAWB")+AvKey(cIdLote,"EVI_LOTE")))
         EVK->(DbSeek(xFilial("EVK")+AvKey(EV1->EV1_HAWB,"EVK_HAWB")+AvKey(cIdLote,"EVK_LOTE")))

      ElseIf cServico == INT_DSI

         aItens[i] := TMP->(W6_FILIAL+W6_HAWB)
         If !SW6->(DbSeek(aItens[i]))
            MsgInfo(STR0021,STR0005)  //"Erro ao localizar o processo de embarque" ## "Atenção"
            Break
         EndIf
         
         If !EIJ->(DbSeek(xFilial("EIJ")+SW6->W6_HAWB))
            MsgInfo(STR0024,STR0005)  //"Erro ao localizar as adições do processo de embarque" ## "Atenção"
            Break
         EndIf
         
         cNrTraDI := ""
         cNrDI := ""
         If cAcao == DI_CONSULTA
            EVC->(DbSetorder(2))
            If EVC->(DbSeek(xFilial("EVC")+SW6->W6_HAWB+SW6->W6_IDLOTE)) //EVC_FILIAL + EVC_HAWB + EVC_LOTE
               cNrTraDI := EVC->EVC_TRANSM
            EndIf
            EVC->(DbSetOrder(1))
            If Empty(cNrTraDI)
               MsgInfo(STR0093,STR0005) //"Não foram localizados transmissões anteriores para este processo." ## "Atenção"
               Break
            EndIf
         EndIf
            
         If !ExistDir(EICINTSISWEB:cDirGerados + cIdLote)
            If MakeDir(EICINTSISWEB:cDirGerados + cIdLote) <> 0
               MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
            EndIf
         EndIf
      
         SB1->(dbSetOrder(1))
         SW7->(dbSetOrder(4))
         SW2->(dbSetOrder(1)) /* W2_FILIAL+W2_PO_NUM            */
         SA2->(dbSetOrder(1)) /* A2_FILIAL+A2_COD+A2_LOJA       */
         SYT->(dbSetOrder(1)) /* YT_FILIAL+YT_COD_IMP           */
         SYQ->(dbSetOrder(1)) /* QY_FILIAL+YQ_VIA               */
         SYD->(dbSetOrder(1))
         SAH->(dbSetOrder(1))
         SYF->(dbSetOrder(1)) /* YF_FILIAL+YF_MOEDA             */
         EIL->(dbSetOrder(1)) /* EIL_FILIAL+EIL_HAWB+EIL_ADICAO */
         
         SYT->(dbSeek(xFilial("SYT")+SW6->W6_IMPORT  ))
         SYQ->(dbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA ))
         
         EV1->(RecLock("EV1",.T.))
         EV1->EV1_FILIAL := xFilial("EV1")
         EV1->EV1_HAWB   := SW6->W6_HAWB
         EV1->EV1_LOTE   := cIdLote
         EV1->EV1_CDTRA  := If(cAcao == ANALISE,"1","2")
         EV1->EV1_QTADI  := cValToChar(SW6->W6_QTD_ADI)  //QT_BEM_DSI
         
         //Work_Capa->TIPO_MANUT:="I"
         EV1->EV1_TIPODE := cValToChar(Val(SW6->W6_TIPODES))      //CD_TIPO_NATUREZA
         //Work_Capa->CD_DSI_MIC:=LEFT(SW6->W6_HAWB,LEN(Work_Capa->CD_DSI_MIC))//CD_DSI_MICRO
         //Work_Capa->DT_CRIACAO:=DTOC(ddatabase)+" "+TIME()//DT_CRIACAO
         EV1->EV1_CDTPIM := SYT->YT_TIPO              //CD_TIPO_IMPORTADOR
         EV1->EV1_IMPNRO := SYT->YT_CGC               //NR_IMPORTADOR
         //Work_Capa->IN_REPR_LE:=(SW6->W6_CURRIER="1")     //IN_REPR_LEGAL
         IF VAL(SYT->YT_TIPO) > 2
            EV1->EV1_IMPNOM := SYT->YT_NOME           //NM_IMPORTADOR
            EV1->EV1_TELIMP := SYT->YT_TEL_IMP        //NR_TEL_IMPORTADOR
            EV1->EV1_IMPEND := SYT->YT_ENDE           //ED_LOGR_IMPORTADOR
            EV1->EV1_IMPENR := STR(SYT->YT_NR_END,6)  //ED_NR_IMPORTADOR
            EV1->EV1_IMPBAI := SYT->YT_BAIRRO         //ED_COMPL_IMPO
            //Work_Capa->ED_BA_IMPO:=SYT->YT_BAIRRO   //ED_BA_IMPORTADOR
            EV1->EV1_IMPCID := SYT->YT_CIDADE         //ED_MUN_IMPORTADOR
            EV1->EV1_IMPUF  := Alltrim(SYT->YT_ESTADO)         //ED_UF_IMPORTADOR
            EV1->EV1_IMPCEP := SYT->YT_CEP            //ED_CEP_IMPORTADOR
            EV1->EV1_PAIIM  := SYT->YT_PAIS           //CD_PAIS_IMPORTADOR
            EV1->EV1_CPFREP := SYT->YT_CPF_REP        //NR_CPF_REPR_LEGAL
         ENDIF
         SY4->(dbSeek(xFilial("SY4")+SW6->W6_AGENTE))
         EV1->EV1_CGCAG  := SY4->Y4_CGC               //NR_EMP_DECLARANTE
         EV1->EV1_PAISPR := SW6->W6_PAISPRO           //CD_PAIS_PROC_CARGA
         EV1->EV1_REC_AL := SW6->W6_REC_ALF           //CD_RECINTO_ALFAND
         EV1->EV1_SETOR  := SW6->W6_SETORRA           //CD_SETOR_ARMAZENAM
         EV1->EV1_PS_BR  := SetTamanho(SW6->W6_PESO_BR,10,5)//PB_CARGA
         EV1->EV1_PS_LQ  := SetTamanho(SW6->W6_PESOL,10,5) //PL_CARGA
         EV1->EV1_URFDES := SW6->W6_URF_DES           //CD_URF_DESPACHO
         EV1->EV1_COIDM  := SW6->W6_PRCARGA           //NR_IDENT_CARGA
         EV1->EV1_DTEMB  := StrTran(DTOC(SW6->W6_DT_EMB),"/","")      //DT_EMBARQUE - DD/MM/AAAA
         
         IF (cTipoVia := LEFT(SYQ->YQ_COD_DI,1)) == "A"
            EV1->EV1_CODVIA  := "10"                                   //CD_VIA_TRANSP_CARGA
         ELSE
            EV1->EV1_CODVIA  := STRZERO(VAL(LEFT(SYQ->YQ_COD_DI,1)),2) //CD_VIA_TRANSP_CARGA
         ENDIF
         IF !(cTipoVia $ "8,A")
            EV1->EV1_COTPCD := SW6->W6_TIPOCON        //CD_TIPO_DCTO_CARGA
         ENDIF
         
         EV1->EV1_NUDCH  := LEFT(SW6->W6_IDEMANI,LEN(EV1->EV1_NUDCH))//NR_TERMO_ENTRADA
         EV1->EV1_MAWB   := LEFT(SW6->W6_MAWB   ,LEN(EV1->EV1_MAWB)) //NR_DCTO_CARGA_MAST
         EV1->EV1_HOUSE  := LEFT(SW6->W6_HOUSE  ,LEN(EV1->EV1_HOUSE))//NR_DCTO_CARGA_HOUSE
         
         If !Empty(SW6->W6_FREMOED)
            IF SYF->(DBSEEK(xFilial("SYF")+SW6->W6_FREMOED))
               EV1->EV1_MOEFRE := SYF->YF_COD_GI                          //CD_MOEDA_FRETE
               EV1->EV1_FRTOMO := SetTamanho(ValorFrete(SW6->W6_HAWB,,,2),13,2)//VL_TOT_FRETE_MNEG
               EV1->EV1_FRTORS := SetTamanho(ValorFrete(SW6->W6_HAWB,,,1),13,2)//VL_TOTAL_FRETE_MN//Real
            ENDIF
         EndIf
         If !Empty(SW6->W6_SEGMOED)
            IF SYF->(DBSEEK(xFilial("SYF")+SW6->W6_SEGMOED))
               EV1->EV1_SEGMOE  := SYF->YF_COD_GI             //CD_MOEDA_SEGURO
               EV1->EV1_SETOMO  := SetTamanho(SW6->W6_VL_USSE,13,2)//VL_TOT_SEGURO_MNEG
               EV1->EV1_SETORS  := SetTamanho(SW6->W6_VLSEGMN,13,2)//VL_TOTAL_SEG_MN
            ENDIF
         EndIf
         EV1->EV1_DTDSE := StrTran(DTOC(SW6->W6_DT_DSE),"/","") //DT_DSE_MANUAL
         EV1->EV1_ULDSE := SW6->W6_UL_DSE       //CD_UL_DSE_MANUAL
         EV1->EV1_NRDSE := SW6->W6_NR_DSE       //NR_DSE
         EV1->EV1_NRDDE := SW6->W6_NR_DDE       //NR_DDE
         EV1->EV1_NRPRC := SW6->W6_NR_PROC      //NR_PROCESSO_EXPO
         
         EV1->EV1_CONTA  := SW6->W6_CTAPGTO
         EV1->EV1_INFCOM := MSMM(SW6->W6_COMPLEM,AvSx3("W6_VM_COMP",3))//TX_INFO_COMPL

         EIH->(dbSetOrder(1)) /* EIH_FILIAL+EIH_HAWB+EIH_CODIGO */
         EIH->(dbSeek(xFilial("EIH")+SW6->W6_HAWB))
         DO While !EIH->(Eof()) .And. EIH->EIH_FILIAL == xFilial("EIH") .And. EIH->EIH_HAWB == SW6->W6_HAWB
            //Work_Vol->TIPO_MANUT:="I"
            //Work_Vol->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
            //Work_Vol->NR_SEQUENC:=nItem                //NR_SEQUENCIAL
            If EVH->(RecLock("EVH",.T.))
               EVH->EVH_FILIAL := xFilial("EVH")
               EVH->EVH_HAWB   := SW6->W6_HAWB
               EVH->EVH_LOTE   := cIdLote
               EVH->EVH_TPEMB  := EIH->EIH_CODIGO
               EVH->EVH_QTDVOL := SetTamanho(EIH->EIH_QTDADE,5,0)
               EVH->(MsUnlock())
            EndIf               
            EIH->(DBSKIP())
         ENDDO
         
         EII->(dbSetOrder(1)) /* EII_FILIAL+EII_HAWB+EII_CODIGO */
         EII->(dbSeek(xFilial("EII")+SW6->W6_HAWB))
         DO While !EII->(Eof()) .And. EII->EII_FILIAL == xFilial("EII") .And. EII->EII_HAWB == SW6->W6_HAWB
            //Work_Pgto->TIPO_MANUT:="I"
            //Work_Pgto->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
            If RecLock("EVA",.T.)
               EVA->EVA_FILIAL := xFilial("EVA")
               EVA->EVA_HAWB   := SW6->W6_HAWB
               EVA->EVA_LOTE   := cIdLote
               EVA->EVA_AGENCI := SubStr(SW6->W6_AGEPGTO,1,4)
               EVA->EVA_BANCO  := SW6->W6_BCOPGTO            
               EVA->EVA_CODREC := EII->EII_CODIGO
               EVA->EVA_VLREC  := SetTamanho(EII->EII_VLTRIB,13,2)
               EVA->(MsUnlock())
            EndIf               
            EII->(DbSkip())
         ENDDO

         nItem := 0
         EIJ->(dbSetOrder(1))
         SW8->(dbSetOrder(4))
         SW8->(dbSeek(xFilial("SW8")+SW6->W6_HAWB))
         nSeqAdi := 0
         DO While !SW8->(Eof()) .AND. SW8->W8_FILIAL == xFilial("SW8") .And. SW8->W8_HAWB == SW6->W6_HAWB

            EIJ->(dbSeek(xFilial("EIJ")+SW6->W6_HAWB+SW8->W8_ADICAO))
            SYD->(dbSeek(xFilial("SYD")+SW8->W8_TEC))//EIJ->EIJ_TEC))
            EIL->(dbSeek(xFilial("EIL")+EIJ->EIJ_HAWB+EIJ->EIJ_ADICAO))
            SA2->(dbSeek(xFilial("SA2")+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")))
            SAH->(DBSEEK(xFilial("SAH")+SYD->YD_UNID))//EIJ->EIJ_UM_EST))
            SW7->(DBSEEK(xFilial("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
            SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
            SYF->(DBSEEK(xFilial("SYF")+SW2->W2_MOEDA))
            SB1->(DBSEEK(xFilial("SB1")+SW8->W8_COD_I))
   
            cUMde := BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN,SW8->W8_CC+SW8->W8_SI_NUM, EICRetLoja("SW8", "W8_FABLOJ"), EICRetLoja("SW8", "W8_FORLOJ"))

            lGravaBag:=.T.
            IF SW6->W6_TIPODES == "10" .AND. EIJ->EIJ_REGTRI $ "2,3"
               lGravaBag := .F.
            ENDIF

            nSeqAdi++
            EV2->(RecLock("EV2",.T.))

            EV2->EV2_FILIAL := xFilial("EV2")
            EV2->EV2_HAWB   := SW6->W6_HAWB
            EV2->EV2_LOTE   := cIdLote
            EV2->EV2_NRADI  := cValToChar(nSeqAdi)

            nItem++
            //Work_Item->TIPO_MANUT:="I"
            //Work_Item->CD_DSI_MIC:=Work_Capa->CD_DSI_MIC//CD_DSI_MICRO
            EV2->EV2_ADICAO := cValToChar(nItem)    //NR_BEM
            EV2->EV2_REGTRI := EIJ->EIJ_REGTRI      //CD_REGIME_TRIBUTAR
            EV2->EV2_FUNREG := EIJ->EIJ_FUNREG      //CD_FUND_LEG_REGIME
            IF SW6->W6_TIPODES # "10"
               EV2->EV2_MOTADI := EIJ->EIJ_MOTADI   //CD_MOTIVO_FUND_LEG
            ENDIF
            EV2->EV2_TECCL  := cValToChar(VAL(EIJ->EIJ_TEC_CL)) //IN_CLASSIFICACAO
            EV2->EV2_FRMOE  := Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOEFRE,"YF_COD_GI")
            EV2->EV2_SEMOE  := Posicione("SYF",1,xFilial("SYF")+EIJ->EIJ_MOESEG,"YF_COD_GI")
            
            IF lGravaBag
               IF EIJ->EIJ_TEC_CL = "0"
                  EV2->EV2_TEC := SW8->W8_TEC              //CD_MERCADORIA //EIJ->EIJ_TEC
               ELSEIF EIJ->EIJ_TEC_CL = "1"
                  EV2->EV2_TEC := SUBSTR(SW8->W8_TEC,1,4)  //CD_MERCADORIA //EIJ->EIJ_TEC
               ENDIF
               EV2->EV2_DENCM  := SYD->YD_DESC_P              //NM_DESCRICAO_MERC
               EV2->EV2_MERCO  := If(EIJ->EIJ_MERCOS=="1","1","0") //IN_MERCOSUL
               EV2->EV2_PAIOME := SA2->A2_PAIS                //CD_PAIS_ORIG_MERC
               IF SW6->W6_TIPODES # "10" .AND. (SW6->W6_TIPODES # "09" .OR. EIJ->EIJ_TEC_CL = "0")
                  EV2->EV2_DESTAQ := EIL->EIL_DESTAQ             //CD_DESTAQUE_NCM
                  EV2->EV2_NMEST  := SUBSTR(SAH->AH_DESCPO,1,20) //NM_UN_MEDID_ESTAT
                  EV2->EV2_QT_EST := SetTamanho(EIJ->EIJ_QT_EST,9,5) //QT_UN_ESTATISTICA
               ENDIF
               SAH->(DBSEEK(xFilial("SAH")+cUMde))                       
               EV2->EV2_NMCOM  := SUBSTR(SAH->AH_DESCPO,1,20)     //NM_UN_MEDID_COMERC
               EV2->EV2_QTCOM  := SetTamanho(SW8->W8_QTDE,9,5)        //QT_MERC_UN_COMERC
               EV2->EV2_MATUSA := If(EIJ->EIJ_MATUSA == "1","1","0")//IN_MATERIAL_USADO
               EV2->EV2_MOE1   := SYF->YF_COD_GI                  //CD_MOEDA_NEGOCIADA
               EV2->EV2_VULOEM := SetTamanho((SW8->W8_VLMLE/SW8->W8_QTDE),13,2)//VL_UNID_LOC_EMB
               EV2->EV2_VMLOEM := SetTamanho(SW8->W8_VLMLE,11,2)               //VL_MERC_LOC_EMB
            ENDIF
            
            EV2->EV2_PLBEM    := SetTamanho((SW8->W8_QTDE*SW7->W7_PESO),10,5) //PL_BEM
            EV2->EV2_VMEMN    := SetTamanho(SW8->W8_FOBTOTR,13,2)             //VL_MERC_EMB_MN
            IF lGravaBag
               EV2->EV2_VFRMN  := SetTamanho(SW8->W8_VLFREMN,13,2)            //VL_FRETE_MERC_MN
               EV2->EV2_VSGMN  := SetTamanho(SW8->W8_VLSEGMN,13,2)            //VL_SEG_MERC_MN
               nValAdua := SW8->W8_FOBTOTR + SW8->W8_VLFREMN + SW8->W8_VLSEGMN
               EV2->EV2_VLADUA := SetTamanho(nValAdua,11,2)   //VL_ADUANEIRO
            ENDIF

            mMemo := ' '
            IF !EMPTY(SW8->W8_DESC_DI)
               mMemo:= MSMM(SW8->W8_DESC_DI,AvSx3("W8_DESC_VM",3)) 
            ENDIF
            IF EMPTY(mMemo)
               mMemo:= MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3)) 
            ENDIF
            EV2->EV2_COMPLE := mMemo  //TX_DESC_DET_MERC
         
            IF lAUTPCDI
               nAliqICMS := SYD->YD_ICMS_RE

               IF lQbgOperaca .AND. !EMPTY(SW8->W8_OPERACA)
                  SWZ->(DBSETORDER(2))
                  IF SWZ->(DBSEEK(xFilial("SWZ")+SW8->W8_OPERACA))
                     IF EMPTY(SWZ->WZ_RED_CTE)
                        nAliqICMS:= SWZ->WZ_AL_ICMS
                     ELSE
                        nAliqICMS:= SWZ->WZ_RED_CTE
                     ENDIF
                  ENDIF   
               ENDIF
               EV2->EV2_VLICMS := SetTamanho(nAliqICMS,13,2) 
               EV2->EV2_FUN_PC := SW8->W8_REG_PC
               EV2->EV2_FRB_PC := SW8->W8_FUN_PC
            ENDIF
	
            nTot_VLMLERS += SW8->W8_FOBTOTR

            //Work_Tri->TIPO_MANUT:="I"
            //Work_Tri->CD_DSI_MIC:=Work_Item->CD_DSI_MIC  //CD_DSI_MICRO
            
            // II
            IF EIJ->EIJ_REGTRI # "2" // Imunidade
               If EVG->(RecLock("EVG",.T.))
                  EVG->EVG_FILIAL := xFilial("EVG")
                  EVG->EVG_HAWB   := SW6->W6_HAWB
                  EVG->EVG_ADICAO := cValToChar(nItem)            //NR_BEM
                  EVG->EVG_LOTE   := cIdLote
                  EVG->EVG_IDIMP  := "1"
                  EVG->EVG_BASE   := SetTamanho(nValAdua,13,2)  //VL_BASE_CALC_ADVAL_II
                  EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALI_II,3,2)  //VL_BASE_CALC_ADVAL_II
                  EVG->EVG_VLIPTD := SetTamanho(SW8->W8_VLDEVII,13,2)  //VL_IMPOSTO_DEVIDO_II
                  EVG->EVG_VLIPTR := SetTamanho(SW8->W8_VLII,13,2)     //VL_IPT_A_RECOLHER_II    
                  EVG->(MsUnlock())
               EndIf
            ENDIF
               
            //IPI
            IF !EIJ->EIJ_REGTRI $ "2,7" // Imunidade,Tributacao simples
                If EVG->(RecLock("EVG",.T.))
                  EVG->EVG_FILIAL := xFilial("EVG")
                  EVG->EVG_HAWB   := SW6->W6_HAWB
                  EVG->EVG_ADICAO := cValToChar(nItem)            //NR_BEM
                  EVG->EVG_LOTE   := cIdLote
                  EVG->EVG_IDIMP  := "2"
                  EVG->EVG_BASE   := SetTamanho(nValAdua + SW8->W8_VLII,13,2)//VL_BASE_CALC_ADVAL_IPI
                  EVG->EVG_ALNAD  := SetTamanho(EIJ->EIJ_ALAIPI,3,2)     //PC_ALIQ_NORM_ADVAL_IPI
                  EVG->EVG_VLIPTD := SetTamanho(SW8->W8_VLDEIPI,13,2)     //VL_IMPOSTO_DEVIDO_IPI
                  EVG->EVG_VLIPTR := SetTamanho(SW8->W8_VLIPI,13,2)       //VL_IPT_A_RECOLHER_IPI
                  EVG->(MsUnlock())
               EndIf
            ENDIF
   
            //PIS / COFINS
            IF lAUTPCDI
               If EVG->(RecLock("EVG",.T.))
                  EVG->EVG_FILIAL := xFilial("EVG")
                  EVG->EVG_HAWB   := SW6->W6_HAWB
                  EVG->EVG_ADICAO := cValToChar(nItem)               //NR_BEM
                  EVG->EVG_LOTE   := cIdLote
                  EVG->EVG_IDIMP  := "5"
                  EVG->EVG_BASE   := SetTamanho(SW8->W8_BASPIS,13,2)
                  EVG->EVG_ALNAD  := SetTamanho(SW8->W8_PERPIS,3,2)
                  EVG->EVG_VLIPTA := SetTamanho(SW8->W8_VLUPIS,5,5)
                  EVG->EVG_UNUESP := EIJ->EIJ_UNUPIS
                  EVG->EVG_QTRIPI := SetTamanho(EIJ->EIJ_QTUPIS,5,0)
                  IF EIJ->EIJ_TPAPIS == "1"
                     EVG->EVG_VLIIAC:= SetTamanho(SW8->W8_BASPIS * (SW8->W8_PERPIS/100),13,2) 
                  ELSE
                     EVG->EVG_VLIIAC:= SetTamanho(SW8->W8_VLUPIS * EIJ->EIJ_QTUPIS,13,2)
                  ENDIF
                  EVG->EVG_VLIPTD := SetTamanho(SW8->W8_VLDEPIS,13,2)
                  EVG->EVG_VLIPTR := SetTamanho(SW8->W8_VLRPIS,13,2)
                  EVG->(MsUnlock())
               EndIf
               
               If EVG->(RecLock("EVG",.T.))
                  EVG->EVG_FILIAL := xFilial("EVG")
                  EVG->EVG_HAWB   := SW6->W6_HAWB
                  EVG->EVG_ADICAO := cValToChar(nItem)               //NR_BEM
                  EVG->EVG_LOTE   := cIdLote
                  EVG->EVG_IDIMP  := "6"
                  EVG->EVG_BASE   := SetTamanho(SW8->W8_BASCOF,13,2)
                  EVG->EVG_ALNAD  := SetTamanho(SW8->W8_PERCOF,3,2)
                  EVG->EVG_VLIPTA := SetTamanho(SW8->W8_VLUCOF,5,5)
                  EVG->EVG_UNUESP := EIJ->EIJ_UNUCOF
                  EVG->EVG_QTRIPI := SetTamanho(EIJ->EIJ_QTUCOF,5,0)
                  IF EIJ->EIJ_TPACOF == "1"
                     EVG->EVG_VLIIAC:= SetTamanho(SW8->W8_BASCOF * (SW8->W8_PERCOF/100),13,2) 
                  ELSE
                     EVG->EVG_VLIIAC:= SetTamanho(SW8->W8_VLUCOF * EIJ->EIJ_QTUCOF,13,2)
                  ENDIF
                  EVG->EVG_VLIPTD := SetTamanho(SW8->W8_VLDECOF,13,2)
                  EVG->EVG_VLIPTR := SetTamanho(SW8->W8_VLRCOF,13,2)
                  EVG->(MsUnlock())
               EndIf
            ENDIF

            nTotal_II  += SW8->W8_VLII
            nTotAL_IPI += SW8->W8_VLIPI
            IF lAUTPCDI
               nTotal_PIS += SW8->W8_VLRPIS
               nTotal_COF += SW8->W8_VLRCOF
               IF EIJ->EIJ_TPAPIS == "1"
                  nTotC_PIS += (SW8->W8_BASPIS * (SW8->W8_PERPIS/100) )
               ELSE
                  nTotC_PIS += SW8->W8_VLUPIS * EIJ->EIJ_QTUPIS 
               ENDIF
               IF EIJ->EIJ_TPACOF == "1"
                  nTotC_COF += (SW8->W8_BASCOF * (SW8->W8_PERCOF/100) )
               ELSE
                  nTotC_COF += SW8->W8_VLUCOF * EIJ->EIJ_QTUCOF 
               ENDIF
            ENDIF
   
            SWP->(DbSetOrder(1))  //WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI+WP_NR_MAQ
            If SWP->(DBSEEK(xFilial("SWP")+SW8->W8_PGI_NUM+SW8->W8_SEQ_LI))
               EV2->EV2_REGLSI := SWP->WP_REGIST
            EndIf
                        
            EV2->(MsUnlock())
            SW8->(DBSKIP())
         ENDDO

         EV1->EV1_TORSDE := SetTamanho(nTot_VLMLERS,13,2)            //VL_TOTAL_MLE_MN
         EV1->EV1_VLTOII := SetTamanho(nTotal_II,13,2)               //VL_TOTAL_II_A_REC
         EV1->EV1_VLTOIP := SetTamanho(nTotAL_IPI,13,2)              //VL_TOTAL_IPI_A_REC
         EV1->EV1_VLTPTR := SetTamanho(nTotAL_II + nTotAL_IPI,13,2)  //VL_TOT_TRIB_A_REC
         IF lAUTPCDI
            EV1->EV1_VLTPI1 := SetTamanho(nTotC_PIS,13,2)   //VL_TOTAL_PIS_CALC
            EV1->EV1_VLTCO1 := SetTamanho(nTotC_COF,13,2)   //VL_TOTAL_COFINS_CALC
            EV1->EV1_VLTPI2 := SetTamanho(nTotal_PIS,13,2)  //VL_TOTAL_PIS_A_REC
            EV1->EV1_VLTCO2 := SetTamanho(nTotal_COF,13,2)  //VL_TOTAL_COFINS_A_REC
         ENDIF
         
         EV1->(MsUnlock())

         cArquivo := AllTrim(EV1->EV1_HAWB)
         AjustaNome(@cArquivo)
         EV1->(DbSeek(xFilial("EV1")+AvKey(cIdLote,"EV1_LOTE")+AvKey(SW6->W6_HAWB,"EV1_HAWB")))
         EV2->(DbSeek(xFilial("EV2")+AvKey(cIdLote,"EV2_LOTE")+AvKey(EV1->EV1_HAWB,"EV2_HAWB")))
         EV3->(DbSeek(xFilial("EV3")+AvKey(cIdLote,"EV3_LOTE")+AvKey(EV1->EV1_HAWB,"EV3_HAWB")))
         EV4->(DbSeek(xFilial("EV4")+AvKey(cIdLote,"EV4_LOTE")+AvKey(EV1->EV1_HAWB,"EV4_HAWB")))
         EV5->(DbSeek(xFilial("EV5")+AvKey(cIdLote,"EV5_LOTE")+AvKey(EV1->EV1_HAWB,"EV5_HAWB")))
         EV6->(DbSeek(xFilial("EV6")+AvKey(cIdLote,"EV6_LOTE")+AvKey(EV1->EV1_HAWB,"EV6_HAWB")))
         EV7->(DbSeek(xFilial("EV7")+AvKey(cIdLote,"EV7_LOTE")+AvKey(EV1->EV1_HAWB,"EV7_HAWB")))
         EV8->(DbSeek(xFilial("EV8")+AvKey(cIdLote,"EV8_LOTE")+AvKey(EV1->EV1_HAWB,"EV8_HAWB")))
         EV9->(DbSeek(xFilial("EV9")+AvKey(cIdLote,"EV9_LOTE")+AvKey(EV1->EV1_HAWB,"EV9_HAWB")))
         EVA->(DbSeek(xFilial("EVA")+AvKey(cIdLote,"EVA_LOTE")+AvKey(EV1->EV1_HAWB,"EVA_HAWB")))
         EVB->(DbSeek(xFilial("EVB")+AvKey(cIdLote,"EVB_LOTE")+AvKey(EV1->EV1_HAWB,"EVB_HAWB")))
         EVG->(DbSeek(xFilial("EVG")+AvKey(EV1->EV1_HAWB,"EVG_HAWB")+AvKey(cIdLote,"EVG_LOTE")))
         EVH->(DbSeek(xFilial("EVH")+AvKey(EV1->EV1_HAWB,"EVH_HAWB")+AvKey(cIdLote,"EVH_LOTE")))
         EVI->(DbSeek(xFilial("EVI")+AvKey(EV1->EV1_HAWB,"EVI_HAWB")+AvKey(cIdLote,"EVI_LOTE")))      
      
      ElseIf cServico == INT_LI
      
         aItens[i] := TMP->(WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI)   // GFP - 06/04/2015 - Ajustado para considerar quebras de LI.
         If !SW4->(DbSeek(aItens[i]))
            MsgInfo(STR0064,STR0005)  //"Erro ao localizar o pedido de licença de importação." ## "Atenção"
            Break
         EndIf

         If !SWP->(DbSeek(aItens[i]))
            MsgInfo(STR0064,STR0005)  //"Erro ao localizar o pedido de licença de importação." ## "Atenção"
            Break
         EndIf

         If !ExistDir(EICINTSISWEB:cDirGerados + cIdLote)
            If MakeDir(EICINTSISWEB:cDirGerados + cIdLote) <> 0
               MsgInfo(STR0036,STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
            EndIf
         EndIf
         
         EV5->(DbSetOrder(4))  // GFP - 03/06/2015
         
         EVD->(RecLock("EVD",.T.))
         EVD->EVD_FILIAL	:= xFilial("EVD")
         EVD->EVD_LOTE	:= cIdLote
         EVD->EVD_PGI_NU	:= SWP->WP_PGI_NUM
         EVD->EVD_SEQLI	:= SWP->WP_SEQ_LI
         EVD->EVD_CDORI	:= "1"
         EVD->EVD_INSALD	:= "0"
         EVD->EVD_INSELD	:= "0"
         
         MAusenciafa := "1"  ;  Testa := .T.
         Peso_L := Qtde_Est := Vlr_Moeda := Vlr_Usd := 0

         MDespesas := 0
         
         IF EasyGParam("MV_RATEIO") $ cSim
            MDespesas:= SW4->W4_INLAND + SW4->W4_PACKING - SW4->W4_DESCONT
            IF SW4->(FIELDPOS("W4_OUT_DES")) # 0 
               MDespesas+=SW4->W4_OUT_DES
            ENDIF                           
            IF lSegInc .AND. SW4->W4_SEGINC $ cNao .AND.  AvRetInco(AllTrim(SW4->W4_INCOTER),"CONTEM_SEG")
               MDespesas+=SW4->W4_SEGURO
            ENDIF
         ENDIF

         IF lW4_Fre_Inc .Or. EasyGParam("MV_RAT_FRE") $ cSim
            MDesFrePLI  := SW4->W4_FRETEIN
         ENDIF

         IF PGI_Chave # SWP->WP_PGI_NUM .OR. tBate1vez
            nPesTotPLI:=0
            IF lW4_Fre_Inc .Or. EasyGParam("MV_RAT_FRE") $ cSim
         
               SW5->(DBSEEK(xFilial("SW5")+SWP->WP_PGI_NUM))
         
               DO WHILE SWP->WP_PGI_NUM=SW5->W5_PGI_NUM .AND. !SW5->(EOF()).AND.;
                        xFilial("SW5")==SW5->W5_FILIAL
            
                  IF SW5->W5_SEQ # 0
                     SW5->(DBSKIP()) ; LOOP
                  ENDIF
            
                  SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))
            
                  nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO)         
                  nPesTotPLI += SW5->W5_QTDE * nPesoItem
                        
                  SW5->(DBSKIP())
                 
               ENDDO
               SW5->( DBSEEK( xFilial("SW5") + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI) )
            ENDIF
      
            PGI_Chave := SWP->WP_PGI_NUM
            tBate1vez :=.F.
         ENDIF

         cFob_Cli := 0
         nFob:=0
         WHILE ! SW5->(EOF()) .AND.;
                 SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .AND.;
                 SW5->W5_FILIAL==xFilial("SW5")

            IF SW5->W5_SEQ # 0
               SW5->(DBSKIP()) ; LOOP
            ENDIF
            SJ5->(DBSETORDER(1))
            SB1->(DBSETORDER(1))
            SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))
            SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
          
            nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO)
            nPesTotLI+= SW5->W5_QTDE * nPesoItem //<< PESO
            cFob_Cli += SW5->W5_QTDE * SW5->W5_PRECO+nFob
            SW5->(DBSKIP())
         ENDDO

         cFob_Aux := cFob_Cli
         MDesFreLI := (MDesFrePLI*(NPesTotLI/IF(NPesTotPLI<=0,1,NPesTotPLI) ))
         MDespesas := (MDespesas * (cFob_Cli/SW4->W4_FOB_TOT))

         cFob_Cli  += MDespesas
         If !lW4_Fre_Inc  .Or.  ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTER),"CONTEM_FRETE") )
            cFob_Cli += MDesFreLI
         EndIf
         
         SW5->(DBSEEK(xFilial("SW5")+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI)) 
         WHILE ! SW5->(EOF()) .AND. SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .AND. SW5->W5_FILIAL==xFilial("SW5")

            IF SW5->W5_SEQ # 0
               SW5->(DBSKIP()) ; LOOP
            ENDIF

            SW2->(DBSEEK(xFilial("SW2")+SW5->W5_PO_NUM))

            cUni410 := BUSCA_UM(SW5->W5_COD_I+SW5->W5_FABR +SW5->W5_FORN,SW5->W5_CC+SW5->W5_SI_NUM,,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
            SAH->(DbSetOrder(1))  //AH_FILIAL+AH_UNIMED
            SAH->(DBSEEK(xFilial("SAH")+cUni410))
            SYG->(DBSEEK(xFilial("SYG")+SW2->W2_IMPORT+SW5->W5_FABR+EICRetLoja("SW5","W5_FABLOJ")+SW5->W5_COD_I))
            SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))

            cTx_Conv := 1
            If cUni410 # SWP->WP_UNID
               IF AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
                  cTx_Conv:=B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
               ELSEIF SJ5->(DBSEEK(xFilial("SJ5")+AVKEY(cUni410,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+SW5->W5_COD_I))
                  cTx_Conv := SJ5->J5_COEF
               ELSEIF SJ5->(DBSEEK(xFilial("SJ5")+AVKEY(cUni410,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA"))) 
                  DO WHILE !SJ5->(EOF()) .AND. SJ5->J5_FILIAL  == xFilial("SJ5") .AND.;
                                            SJ5->J5_DE      == AVKEY(cUni410,"J5_DE") .AND.;
                                            SJ5->J5_PARA    == AVKEY(SWP->WP_UNID,"J5_PARA")
                     IF EMPTY(SJ5->J5_COD_I)
                        cTx_Conv := SJ5->J5_COEF
                        EXIT
                     ENDIF
                     SJ5->(dbSkip())
                  ENDDO
               ENDIF
            ENDIF   

            IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
               cFornAux   := SW2->W2_EXPORTA
               nValParid  := SW2->W2_PARID_U
               If EICLoja()
                  cForLojAux := SW2->W2_EXPLOJ
               EndIf
            ELSE
               cFornAux:= SW2->W2_FORN
               nValParid:=1 
               cForLojAux := SW2->W2_FORLOJ
            ENDIF
            MAusenciafa := IF(SWP->(FIELDPOS("WP_TIPFAB")) # 0,SWP->WP_TIPFAB,MAusenciafa)
            IF Testa
               IF SW5->W5_FABR # cFornAux .OR. IIF(EICLoja(),SW5->W5_FABLOJ # cForLojAux,.F.)
                  IF EMPTY(SW5->W5_FABR_01) .OR. IF(EICLoja(),EICEmptyLJ("SW5","W5_FAB1LOJ"),.F.)
                     MAusenciafa:="2"
                  ELSE
                     MAusenciafa:="3"  ;  Testa := .F.
                  ENDIF
               ENDIF
            ENDIF

            If lInfOrgAnu .And. SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))
               If (aScan(aProcOrg, {|x| x[1] == SB1->B1_PRO_ANU .AND. x[2] == SB1->B1_ORG_ANU})) = 0
                  Aadd(aProcOrg, {SB1->B1_PRO_ANU, SB1->B1_ORG_ANU})
               Endif         
            EndIf

            nPesTotItem:= SW5->W5_QTDE*If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO)

            nFob := SW5->W5_QTDE*SW5->W5_PRECO     
            cValor_Tot := nFob + (MDespesas * (nFob/cFob_Aux))
            If !lW4_Fre_Inc .Or. ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTER),"CONTEM_FRETE") )
               cValor_Tot += MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI))    
            EndIf

            cValor_Uni := cValor_Tot / SW5->W5_QTDE
            cFob_Cli   -= SW5->W5_QTDE * cValor_Uni

            If UPPER(cUni410) = UPPER(SWP->WP_UNID)
               nQtdNCM := Round(SW5->W5_QTDE,5)
            ElseIf AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
               nQtdNCM := Round(SW5->W5_QTDE*If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO),5)    // LDR OS - 1240/03
            Else
               nQtdNCM := Round(SW5->W5_QTDE * cTx_Conv,5)
            ENDIF

            nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO)
            Peso_L += SW5->W5_QTDE * nPesoItem
            Qtde_Est += nQtdNCM

            Vlr_MoeIt := SW5->W5_QTDE * cValor_Uni
            Vlr_Moeda += Vlr_MoeIt
            

            If lW4_Fre_Inc .And.  AvRetInco(AllTrim(SW4->W4_INCOTER),"CONTEM_FRETE")
               Vlr_Moeda -= MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI))
               Vlr_MoeIt -= MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI))
            EndIf

            IF lSegInc .AND. SW4->W4_SEGINC $ cSim .AND. AvRetInco(AllTrim(SW4->W4_INCOTER),"CONTEM_SEG")
               Vlr_Moeda -= (SW4->W4_SEGURO * (nFob/SW4->W4_FOB_TOT))
               Vlr_MoeIt -= (SW4->W4_SEGURO * (nFob/SW4->W4_FOB_TOT))
            ENDIF

            Vlr_Usd   += SW5->W5_QTDE * cValor_Uni * nValParid

            cDescricaoItem := iif(lPartNum .And. len(alltrim(SA5->A5_PARTOPC)) > 0,"P/N.: "+alltrim(SA5->A5_PARTOPC)+" - ","") + MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3))

            IF Len(cDescricaoItem)> 3900 .OR. Len(EV7->EV7_DESC) > 3900
	            MsgInfo(STR0142,STR0005)  //LRS - 17/08/2016
	            Break
            EndIF

            cTextoDesc := AllTrim(cDescricaoItem) + " " //+ chr(13)+chr(10)     
            cTextoDesc += SA5->A5_CODPRF + " " //+ chr(13)+chr(10)
            cTextoDesc += iif(SYG->(EoF()),"",STR0080 + SYG->YG_REG_MIN + " " + STR0081 + DtoC(SYG->YG_VALIDA) )  //"Registro N.: " ### "Validade: "
            
            cTextoDesc := STRTRAN(cTextoDesc,CHR(13)+CHR(10)," ")
            
            IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"DESCRICAO_ITEM"),)
            
            cTextoDesc := STRTRAN(cTextoDesc,"<","")
            cTextoDesc := STRTRAN(cTextoDesc,">","")
            
            ++MSeq //LRS - 02/01/201
            IF MSeq > EICParISUF()  //EasyGParam("MV_NR_ISUF",,78) 
               Mseq := 0               
            EndIF
            EVF->(RecLock("EVF",.T.))
            EVF->EVF_FILIAL	:= xFilial("EVF")
            EVF->EVF_LOTE	:= cIdLote
            EVF->EVF_PGI_NU	:= SW5->W5_PGI_NUM
            EVF->EVF_SEQLI  := SW5->W5_SEQ_LI
            EVF->EVF_SEQIT	:= PADL(MSeq, avsx3("EVF_SEQIT",AV_TAMANHO) ,"0") // 
            EVF->EVF_QTMEU	:= SetPict(ORI100Numero(SW5->W5_QTDE,09,5,.T.,.T.))  //,5
            EVF->EVF_NMMEU	:= SAH->AH_DESCPO
            EVF->EVF_VLUNCO	:= SetPict(ORI100Numero(cValor_Uni,13,7,.T.,.T.)) //,7
            EVF->EVF_VLTOT	:= SetPict(ORI100Numero(SW5->W5_QTDE*cValor_Uni,13,7,.T.,.T.))  //,7
            EVF->EVF_DEDETM	:= cTextoDesc
            EVF->EVF_CDPROD	:= ""
            EVF->EVF_VLQUN  := SetPict(ORI100Numero(If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO),10,5,.T.,.T.))
            EVF->EVF_VLQTO  := SetPict(ORI100Numero(nPesTotItem,10,5,.T.,.T.))
            EVF->EVF_VLLEU  := SetPict(ORI100Numero(Vlr_MoeIt/SW5->W5_QTDE,13,7,.T.,.T.))
            EVF->EVF_VLTO2  := SetPict(ORI100Numero(Vlr_MoeIt,13,7,.T.,.T.))
            EVF->EVF_QTUNME := SetPict(ORI100Numero(nQtdNCM,09,5,.T.,.T.))
            If lIntDraw .and. lExisteWP_AC .and. !Empty(Alltrim(SW5->W5_SEQSIS))
               EVF->EVF_NRITDR	:= SW5->W5_SEQSIS
               EVF->EVF_QTPRDR	:= SetPict(ORI100Numero( nQtdNCM,09,5,.T.,.T.))  //,5
               EVF->EVF_VLPRDR	:= SetPict(ORI100Numero( (nFob),13,2,.T.,.T.)) //,2
            EndIf
            EVF->(MsUnlock())

            SW5->(DBSKIP())
         ENDDO
         
         IF ROUND(cFob_Cli,2) # 0
            Vlr_Moeda-= SW5->W5_QTDE * cValor_Uni // JBS-19/01/2005 * nValParid RJB 16/07/2004 v 5.08
            Vlr_Usd  -= SW5->W5_QTDE * cValor_Uni * nValParid
            Vlr_Moeda+= SW5->W5_QTDE * (cValor_Uni+cFob_Cli) // JBS-19/01/2005 * nValParid RJB 16/07/2004 v 5.08
            Vlr_Usd  += SW5->W5_QTDE * (cValor_Uni+cFob_Cli) * nValParid
         ENDIF
         
         EVD->EVD_NRIDEN:= strtran(strtran(AllTrim(SWP->WP_PGI_NUM),"/",""),"\","")+AllTrim(SWP->WP_SEQ_LI) 
         EVD->EVD_TPIMP	:= "1"
         SYT->(DbSeek(xFilial("SYT")+SW2->W2_IMPORT))
         EVD->EVD_NRIMP	:= SYT->YT_CGC
         EVD->EVD_CPFIM	:= ""
         EVD->EVD_CGCIMP := SYT->YT_CGC
         EVD->EVD_UFMER	:= PADL(SW4->W4_URF_CHE,7,"0")
         IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
            SA2->(DBSEEK(xFilial("SA2")+SW2->W2_EXPORTA+EICRetLoja("SW2","W2_EXPLOJ")))
         ELSE
            SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
         ENDIF
         EVD->EVD_NOMFOR	:= SA2->A2_NOME
         EVD->EVD_LOGFOR	:= SA2->A2_END
         EVD->EVD_NREND1	:= SA2->A2_NR_END
         EVD->EVD_COEND1	:= SA2->A2_ENDCOMP
         EVD->EVD_CIDFOR	:= SA2->A2_MUN
         EVD->EVD_URFFOR	:= SA2->A2_ESTADO
         EVD->EVD_PAISFO	:= PADL(SA2->A2_PAIS,3,"0")
         EVD->EVD_NCMMER	:= SWP->WP_NCM
         SYR->(DBSEEK(xFilial("SYR")+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
         EVD->EVD_PAISPR	:= IF(!EMPTY(SWP->WP_PAIS_PR),PADL(SWP->WP_PAIS_PR,3,"0"),PADL(SYR->YR_PAIS_OR,3,"0"))
         
         IF MAusenciafa == "1"                          
            EVD->EVD_PAISOR    := PADL(SA2->A2_PAIS,3,"0")
            EVD->EVD_COEND2     := SA2->A2_ENDCOMP
         ELSEIF MAusenciafa == "2"  
            SA2->(DBSEEK(xFilial("SA2")+SWP->WP_FABR + EICRetLoja("SWP","WP_FABLOJ")))
            EVD->EVD_NOMFAB     := SA2->A2_NOME
            EVD->EVD_LOGFAB     := SA2->A2_END
            EVD->EVD_NREND2     := PADL(SA2->A2_NR_END,6,"0")
            EVD->EVD_CIDFAB     := SA2->A2_MUN
            EVD->EVD_UFFAB      := SA2->A2_ESTADO // VI
            EVD->EVD_PAISOR    := PADL(SA2->A2_PAIS,3,"0")
            EVD->EVD_COEND2     := SA2->A2_ENDCOMP
         ELSE
            EVD->EVD_PAISOR    := PADL(SWP->WP_PAISORI,3,"0")
         ENDIF

         EVD->EVD_AUSFAB	:= MAusenciafa  //IF(SWP->(FIELDPOS("WP_TIPFAB")) # 0,SWP->WP_TIPFAB,MAusenciafa)
         SA2->(DBSEEK(xFilial("SA2")+SWP->WP_FABR + EICRetLoja("SWP","WP_FABLOJ")))
         EVD->EVD_PAISO2 := PADL(SWP->WP_PAISORI,3,"0")
         EVD->EVD_NALADI	:= SWP->WP_NALADI
         EVD->EVD_NALASH	:= SWP->WP_NAL_SH
         EVD->EVD_PESOL	:= SetPict(ORI100Numero(Peso_L,10,05,.T.,.T.))  //,7
         EVD->EVD_QTUNME	:= SetPict(ORI100Numero(Qtde_Est,09,05,.T.,.T.))  //,5
         EVD->EVD_MOENEG	:= Posicione("SYF",1,xFilial("SYF")+SW2->W2_MOEDA,"YF_COD_GI")
         
         nQtDias := 0
         IF !EMPTY(SW4->W4_COND_PA)
            SY6->(DBSEEK(xFilial("SY6")+SW4->W4_COND_PA+STR(SW4->W4_DIAS_PA, AvSX3("Y6_DIAS_PA", AV_TAMANHO))))
         ELSE
            IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ") 
               SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX, AvSX3("Y6_DIAS_PA", AV_TAMANHO))))
            ELSE
               SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA, AvSX3("Y6_DIAS_PA", AV_TAMANHO))))
            ENDIF
         ENDIF
         
         IF SY6->Y6_TIPOCOB == "1"
            IF SY6->Y6_DIAS_PA = -1
	   	      nQtDias  := STRZERO(0, AvSX3("Y6_DIAS_PA", AV_TAMANHO))
            ELSEIF SY6->Y6_DIAS_PA >= 900
	   	      nY6 := 1
	   	      While nY6 <= 10
	   		      IF nY6 > 1 .AND. &("SY6->Y6_DIAS_"+STRZERO(nY6,2)) == 0
	   			      IF &("SY6->Y6_DIAS_"+STRZERO(nY6-1,2)) > 0
	   			         nQtDias := STRZERO(&("SY6->Y6_DIAS_"+STRZERO(nY6-1,2)), AvSX3("Y6_DIAS_" + StrZero(nY6-1,2), AV_TAMANHO))
	   			      Else
	   			         nQtDias := Space(AvSX3("Y6_DIAS_" + StrZero(nY6-1,2), AV_TAMANHO))
	   			      Endif
	   			      nY6 := 99	//Encontrou a parcela
	   		      ENDIF
	   		      nY6 += 1
	   	      Enddo
	   	      IF nY6 == 11	//Se todas estavam preenchidas, pega a última
	   			   nQtDias := STRZERO(SY6->Y6_DIAS_10, AvSX3("Y6_DIAS_10", AV_TAMANHO))
	   	      ENDIF
            Else
   		      nQtDias  := IF(EMPTY(SY6->Y6_DIAS_PA),SPACE(AvSX3("Y6_DIAS_PA", AV_TAMANHO)),STRZERO(SY6->Y6_DIAS_PA, AvSX3("Y6_DIAS_PA", AV_TAMANHO)))
   	      Endif
         ELSE
            nQtDias  := SPACE(AvSX3("Y6_DIAS_PA", AV_TAMANHO))
         ENDIF

         EVD->EVD_DILIPA	:= cValToChar(nQtDias)
         EVD->EVD_INCOTE	:= IF(!EMPTY(SW4->W4_INCOTER),SW4->W4_INCOTER,SW2->W2_INCOTER)
         EVD->EVD_VLMENE	:= SetPict(ORI100Numero(Vlr_Moeda,13,02,.T.,.T.)) //,2
         EVD->EVD_MATUSA	:= SWP->WP_IDLI
         EVD->EVD_BEENC	:= "0"
         //IF SWP->(FieldPos("WP_CONDME")) # 0
            EVD->EVD_CONMER	:= "N"   //"S" = Sim; "N" = Não
         //ENDIF
         SYD->(DbSeek(xFilial("SYD")+SWP->WP_NCM))
         SAH->(DbSetOrder(1)) //AH_FILIAL+AH_UNIMED
         If !SAH->(DbSeek(xFilial("SAH")+SYD->YD_UNID))
            SAH->(DbSetOrder(3)) //AH_FILIAL+AH_COD_SIS
            SAH->(DbSeek(xFilial("SAH")+SYD->YD_UNID))
         EndIf
         EVD->EVD_UNEST	:= SAH->AH_DESCPO
         EVD->EVD_COMUNI	:= SW4->W4_COMUNIC
         EVD->EVD_DTATU	:= DTOC(dDataBase)
         
         mMemo := ""
         cMemo := ""
         mMemo := MSMM(SW4->W4_DESC_GE,AVSX3("W4_VM_DESG",03))
         mMemo := STRTRAN(mMemo,CHR(13)+CHR(10),' ')
         For k := 1 To MlCount(mMemo,AvSx3("W4_VM_DESG",3))
            cMemo += AllTrim(MemoLine(mMemo,AvSx3("W4_VM_DESG",3),k))
         Next k

         EVD->EVD_INFCOM	:= cMemo  //MSMM(SW4->W4_DESC_GE,AVSX3("W4_VM_DESG",03))
         EVD->EVD_CDACT	:= SW4->W4_ACO_TAR
         EVD->EVD_ACOALA	:= IF(EMPTY(SWP->WP_ALADI),SPACE(3),PADL(SWP->WP_ALADI,3,"0"))
         SY8->(DBSEEK(xFilial("SY8")+SW4->W4_REGIMP))
         If lW4_Reg_Tri
            EVD->EVD_REGTRI	:= SWP->WP_REG_TRI
            EVD->EVD_FLREG	:= IIF(SWP->WP_FUN_REG == "A9", Space(2), SWP->WP_FUN_REG)
         Else
            EVD->EVD_REGTRI	:= SY8->Y8_REG_TRI
            EVD->EVD_FLREG	:= If(SW4->W4_REGIMP="A9",SPACE(2),SW4->W4_REGIMP)
         EndIf
         EVD->EVD_COBCAM	:= SY6->Y6_TIPOCOB
         EVD->EVD_MODAL	:= IF(SY6->Y6_TIPOCOB = "1" .OR. SY6->Y6_TIPOCOB = "2", PADL(SY6->Y6_TABELA,2,"0"), SPACE(2))
         EVD->EVD_ORGFIN	:= IF(SY6->Y6_TIPOCOB = "3", PADL(SY6->Y6_INST_FI,2,"0"), SPACE(2))
         EVD->EVD_MOTCAM	:= IF(SY6->Y6_TIPOCOB = "4", PADL(SY6->Y6_MOTIVO,2,"0"), SPACE(2))
         EVD->EVD_AGSECE	:= SW4->W4_AGSECEX
         EVD->EVD_URFDES	:= PADL(SW4->W4_URF_DES,7,"0")
         EVD->EVD_LISUBS	:= SWP->WP_SUBST
         
         If lIntDraw .and. lExisteWP_AC .and. !Empty(Alltrim(SWP->WP_AC))
            ED0->(dbSetOrder(2))
            If ED0->(dbSeek(xFilial("ED0")+SWP->WP_AC))
               If ED0->ED0_MODAL == "2"      //Para Isençao
                  EVD->EVD_REGDRA := "3"
                  EVD->EVD_FLREG:= "16"  //Fundamento Legal referente ao Drawback TAN
               ElseIf ED0->ED0_TIPOAC == "06"
                  EVD->EVD_REGDRA := "1"
                  EVD->EVD_FLREG:= "16"  //Fundamento Legal referente ao Drawback TAN
               Else
                  EVD->EVD_REGDRA := "2"
               EndIf
               EVD->EVD_REGTRI := If(ED0->ED0_MODAL == "2", "3", "5")
            EndIf
            ED0->(dbSetOrder(1))
         Else
            EVD->EVD_REGDRA := "3"
         EndIf
         If EVD->EVD_REGDRA == "3"
            EVD->EVD_ATOCON   := If(lIntDraw .and. lExisteWP_AC .and. Empty(Alltrim(SW4->W4_ATO_CON)), SUBSTR( SWP->WP_AC, 1, 13 ), SUBSTR( SW4->W4_ATO_CON, 1, 13 ))
         Else
            EVD->EVD_NRREDR   := If(lIntDraw .and. lExisteWP_AC .and. Empty(Alltrim(SW4->W4_ATO_CON)), SUBSTR( SWP->WP_AC, 1, 11 ), SUBSTR( SW4->W4_ATO_CON, 1, 11 ))
         EndIf

         EVD->(MsUnlock())
         
         If Len(aProcOrg) # 0
            For j := 1 To Len(aProcOrg)
               EVE->(RecLock("EVE",.T.))
               EVE->EVE_FILIAL	:= xFilial("EVE")
               EVE->EVE_LOTE	:= cIdLote
               EVE->EVE_PGI_NU	:= SWP->WP_PGI_NUM
               EVE->EVE_SEQLI  := SWP->WP_SEQ_LI
               EVE->EVE_PROANU	:= aProcOrg[j][1]
               EVE->EVE_ORGANU	:= aProcOrg[j][2]
               EVE->(MsUnlock())
            Next j
         EndIf
         
         Inicio := 1
         For j := 1 To 10
            IF EMPTY(SUBSTR(SWP->WP_DESTAQ,Inicio,3))
               Inicio+=3
               LOOP
            ENDIF
            If RecLock("EV5",.T.)
               EV5->EV5_FILIAL := xFilial("EV5")
               EV5->EV5_PGI_NU := SWP->WP_PGI_NUM
               EV5->EV5_SEQLI  := SWP->WP_SEQ_LI
               EV5->EV5_LOTE   := cIdLote
               EV5->EV5_DESTAQ := SUBSTR(SWP->WP_DESTAQ,Inicio,3)
               EV5->(MsUnlock())
            EndIf
            Inicio+=3
         Next j       

         cArquivo := AllTrim(SWP->WP_PGI_NUM)+AllTrim(SWP->WP_SEQ_LI)
         AjustaNome(@cArquivo)
         //EVD->(DbSeek(xFilial("EVD")+AvKey(SW4->W4_PGI_NUM,"EVD_PGI_NU")+AvKey(cIdLote,"EVD_LOTE")))
         EVD->(DbSeek(xFilial("EVD")+AvKey(cIdLote,"EVD_LOTE")+AvKey(SWP->WP_PGI_NUM,"EVD_PGI_NU")+AvKey(SWP->WP_SEQ_LI,"EVD_SEQLI")))
         EV5->(DbSeek(xFilial("EV5")+AvKey(cIdLote,"EV5_LOTE")+AvKey(EVD->EVD_PGI_NU,"EV5_PGI_NU")+AvKey(SWP->WP_SEQ_LI,"EV5_SEQLI")))
         EVE->(DbSeek(xFilial("EVE")+AvKey(EVD->EVD_PGI_NU,"EVE_PGI_NU")+AvKey(cIdLote,"EVE_LOTE")+AvKey(SWP->WP_SEQ_LI,"EVE_SEQLI")))
         EVF->(DbSeek(xFilial("EVF")+AvKey(EVD->EVD_PGI_NU,"EVF_PGI_NU")+AvKey(cIdLote,"EVD_LOTE")+AvKey(SWP->WP_SEQ_LI,"EVF_SEQLI")))

      EndIf
      	
      IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"GERA_ARQUIVO"),)
      
      AjustaNome(@cArquivo)
      //RMD - 16/07/19 - Se for consulta não gera o XML, já que a consuta é feita somente pelo número da Transmissão ou da DI
	   If cAcao <> DI_CONSULTA
	      //*** Cria o arquivo XML
         hFile := EasyCreateFile(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml", FC_READONLY)
      
         If hFile == -1
            MsgInfo(STR0025,STR0005) //O arquivo não pode ser criado. ## "Atenção"
            cArquivo := ""
            Break
         EndIf
      EndIf
   
      If cServico == INT_DI .And. cAcao <> DI_CONSULTA
   
         cBuffer :=  '<?xml version="1.0" encoding="utf-8"?>'+ENTER
         cBuffer +=  '<listaDeclaracoesTransmissao>'+ENTER
         cBuffer +=  '<declaracao>'+ENTER

	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf
		  
		   Do While EV2->(!Eof()) .AND. EV2->EV2_FILIAL == xFilial("EV2") .AND. EV2->EV2_HAWB == EV1->EV1_HAWB .AND. EV2->EV2_LOTE == EV1->EV1_LOTE
            cBuffer :=  H_ADICAO_DI() 
            cBuffer := EncodeUTF8(cBuffer)
		      cBuffer := StrTran(cBuffer,"&","e")

            If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
               MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
               FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
               cArquivo := ""
               Break
            EndIf
            
            EV2->(DbSkip())
         EndDo
 
         cBuffer :=  H_CAPA_DI()
         cBuffer := EncodeUTF8(cBuffer)
         cBuffer := StrTran(cBuffer,"&","e")

	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf

         cBuffer :=  '</declaracao>'+ENTER
         cBuffer +=  '</listaDeclaracoesTransmissao>'
      
	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf
		  
	   ElseIf cServico == INT_DSI
          
          cBuffer :=  '<?xml version="1.0" encoding="ISO-8859-1"?>'+ENTER			
          cBuffer +=  '<listaDeclaracoesSimplificadas>'+ENTER				
          cBuffer +=  '<declaracao>'+ENTER
	
	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf
		  
		  Do While EV2->(!Eof()) .AND. EV2->EV2_FILIAL == xFilial("EV2") .AND. EV2->EV2_HAWB == EV1->EV1_HAWB .AND. EV2->EV2_LOTE == EV1->EV1_LOTE
            cBuffer :=  H_BEM_DSI() 
            cBuffer := EncodeUTF8(cBuffer)
		     cBuffer := StrTran(cBuffer,"&","e")

			  If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
				  MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
				  FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
				  cArquivo := ""
				  Break
			  EndIf				 
			 
            EV2->(DbSkip())
          EndDo
		  
		  cBuffer :=  H_CAPA_DSI()
		  cBuffer := EncodeUTF8(cBuffer)
		  cBuffer := StrTran(cBuffer,"&","e")

	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf

		  cBuffer :=  '</declaracao>'+ENTER
		  cBuffer +=  '</listaDeclaracoesSimplificadas>'
		  
	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf	   
	   
	   ElseIf cServico == INT_LI
	      cBuffer :=  H_LISISCOMEX()
	      cBuffer := StrTran(cBuffer,"&","e")

	      If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		      MsgInfo(STR0026,STR0005) //O arquivo não pode ser gravado. ## "Atenção"
		      FErase(EICINTSISWEB:cDirGerados + cIdLote + "\" + cArquivo+".xml")
		      cArquivo := ""
		      Break
	      EndIf
	   EndIf
	   
	   //*** Cria o arquivo INI
	   EICINTSISWEB:GeraINI(cIdLote,cServico)
	   
	   FClose(hFile)
      aArquivos := {}
      
      // Monta ZIP do Processo (Zipinho)
      If EasyZIP(cArquivo, EICINTSISWEB:cDirGerados + cIdLote+"\", cDirUser, oError, .T.)
         aAdd(aArqsZIP, cArquivo)
         ExcluiArqs(EICINTSISWEB:cDirGerados + cIdLote,".ZIP")
         lRet := .F.
         For k := 1 To 15
            If !ExistDir(EICINTSISWEB:cDirGerados + cIdLote+"_BKP\")
               lRet := .T.
               Exit
            EndIf
         Next k
         If lRet
            MakeDir(EICINTSISWEB:cDirGerados + cIdLote+"_BKP\")
         EndIf
         Do While .T.
            If AvCpyFile(EICINTSISWEB:cDirGerados + cIdLote+"\"+cArquivo+".zip",/*GetSrvProfString("ROOTPATH","")+*/EICINTSISWEB:cDirGerados + cIdLote+"_BKP\"+cArquivo+".zip",,.T.)
               Exit
            EndIf
         EndDo
      EndIf      
   Next i
   
   lRet := .F.
   For i := 1 To 15
      If ExistDir(EICINTSISWEB:cDirGerados + cIdLote+"_BKP\")
         lRet := .T.
         Exit
      EndIf
   Next i
      
   If lRet   
      aArquivos := directory(EICINTSISWEB:cDirGerados + cIdLote+"_BKP\*.*")  //aDir(/*GetSrvProfString("ROOTPATH","")+*/EICINTSISWEB:cDirGerados + cIdLote+"_BKP\*.*",aArquivos)
      If Len(aArquivos) # 0
         For i := 1 To Len(aArquivos)
            Do While .T.
               If AvCpyFile(EICINTSISWEB:cDirGerados + cIdLote+"_BKP\"+aArquivos[i][1],/*GetSrvProfString("ROOTPATH","")+*/EICINTSISWEB:cDirGerados + cIdLote+"\"+aArquivos[i][1],,.T.)
                  Exit
               EndIf
            EndDo
         Next i
      EndIf
      DirRemove(/*GetSrvProfString("ROOTPATH","")+*/EICINTSISWEB:cDirGerados + cIdLote+"_BKP\")
   EndIf
   
   // Monta ZIP do Lote (ZIPAO)
   If Len(aArqsZIP) # 0
      EasyZIP(cIdLote, EICINTSISWEB:cDirGerados + cIdLote+"\", cDirUser, oError, .F.)
      cArquivo := cIdLote  // Alteração de variavel para gravação na tabela EV0
      MsgInfo(STR0045 + cIdLote + STR0028,STR0005)  //"Lote " + XXXXXXXX + " gerado com sucesso." ## "Atenção"   
   EndIf
End Sequence

Return NIL

/*
Função      : ExcluiArqs()
Parametros  : cDiretorio - Diretorio para analise
              cExt - Extensão de exceção
Retorno     : Nenhum
Objetivos   : Exclusão de arquivos de um diretorio
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 05/02/2015 :: 15:07
*/
*--------------------------------------------*
Static Function ExcluiArqs(cDiretorio, cExt)
*--------------------------------------------*
Local aArquivos := {}, i

aArquivos := directory(cDiretorio+"\*.*") // aDir(cDiretorio+"\*.*",aArquivos)
If Len(aArquivos) # 0
   For i := 1 To Len(aArquivos)
      If Right(AllTrim(aArquivos[i][1]),4) <> cExt
         Do While .T.
            If FErase(/*GetSrvProfString("ROOTPATH","")+*/cDiretorio+"\"+aArquivos[i][1]) == 0
               Exit
            EndIf
         EndDo
      EndIf
   Next i
EndIf

Return NIL

/*
Função      : Integra()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criação de arquivo .bat para iniciar transmissão do arquivo
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 05/02/2015 :: 15:07
*/
*---------------------------------*
Static Function Integra(cArquivo)
*---------------------------------*
Local cBat := ""
Local nHandler := 0
Local lRet := .T.
//WHRS TE-3920 498114 / MTRADE-134 - Transmissão de LI ao Siscomex, temporizador 60 minutos
Local cPathEnd := GetTempPath(.T.)

Private lEnd := .F.

if !Empty(EICINTSISWEB:cDirUser)
	cPathEnd := EICINTSISWEB:cDirUser
endIf

If File(cPathEnd+"SiscomexwebFim.txt")
   FErase(cPathEnd+"SiscomexwebFim.txt") 
EndIF

cBat += "Echo Executando Integrador "+ chr(13)+chr(10)
cBat += "cd " + EICINTSISWEB:cDirUser + chr(13)+chr(10)

cBat += If(!Empty(EICINTSISWEB:cDirJava),'"'+AllTrim(EICINTSISWEB:cDirJava)+'"',"Java")		// Chamada do executavel 'Java.exe'
cBat += " -jar tr-sw-web-solution-siscomexweb.jar"										// Chamada do integrador
/* RMD - 22/05/18 - Removida a gravação do arquivo LOG.TXT, pois a execução já cria uma subpasta chamada "Logs" com os logs de execução
cBat += " .\SiscomexWeb\"+GetComputerName()+"\Gerado\"+cArquivo+".zip"				// Caminho + arquivo
cBat += " >> log.txt"+ chr(13)+chr(10)														// Gravação do Log
*/
cBat += " .\SiscomexWeb\"+GetComputerName()+"\Gerado\"+cArquivo+".zip" + ENTER
cBat += "Echo Fim da integracao"+ chr(13)+chr(10)
cBat += "Echo > SiscomexwebFim.txt" //LRS - 03/08/2016

nHandler := EasyCreateFile(GetTempPath(.T.)+"IntegJava.bat")
FWrite(nHandler, cBat)
FClose(nHandler) 
//LRS - 03/08/2016 - Nopado WaitRun e colocado ShellExecute para não travar caso o Ini tenha timeout
shellExecute("Open", "C:\Windows\System32\cmd.exe", ' /k "'  + GetTempPath(.T.)+'IntegJava.bat"', "C:\", 0 )
Processa({|| lRet := CONWriteWEB((cPathEnd+"SiscomexwebFim.txt")) }, "Aguarde o final da integração..." , "", .T.)
/*   
If WaitRun(GetTempPath(.T.)+"IntegJava.bat") <> 0
   MsgInfo(STR0050,STR0005)  //"Foram encontrados erros durante a integração do arquivo selecionado com o Siscomex."  ##  "Atenção"
   lRet := .F.
EndIf      
*/
FErase(GetTempPath(.T.)+"IntegJava.bat") 
Return lRet

/*
Função      : RetornoArq()
Parametros  : Arquivo de retorno
Retorno     : .T./.F.
Objetivos   : Leitura do arquivo de retorno da integração
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 09/02/2015 :: 09:13
*/
*--------------------------------------------*
Static Function RetornoArq(cArquivo,cServico)
*--------------------------------------------*
Local aValores := {}, aErros := {}, aBuffer := {}, aSiscomex := {}, aGravaRet := {}, aAnuencia := {}, aAnuencias := {}, aRetA := {}
Local cNomeArq := cArquivo
Local cError := "", cWarning := "", cTag1 := "", cTipo := ""
Local oFilho, oMensag, oStatus, oRetorno
Local i, j
Local lRet := .T.
Local lError := .F.

Begin Sequence
   If cServico == INT_DI .OR. cServico == INT_DSI
      Do Case
      Case Len(aBuffer := EasyGetINI(cNomeArq, "[DIAGNOSTICO]","[",.T.)) # 0
         cTipo := DI_CONSULTA
         cNrTransmis := ""
         If cServico == INT_DI
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEB]","[",.T.)
         Else
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEBDSI]","[",.T.)
         EndIf
         //aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEB]","[",.T.)
         cNrTransmis := StrTran(aBuffer[aScan(aBuffer, "NUM_TRANSMISSAO")],"NUM_TRANSMISSAO = ","")
         
         If !Empty(cNrTransmis)
            cNomeArq := SubStr(cNomeArq,1,RAT("\",cNomeArq))+AllTrim(cNrTransmis)+".XML"
            
            //MCF - 10/06/2016 - Tratamento no nome do XML
            If !File(cNomeArq)
               If At("-", cNrTransmis) <> 0
                  cNrTransmis := StrTran(cNrTransmis,"-","")
                  cNomeArq := SubStr(cNomeArq,1,RAT("\",cNomeArq))+AllTrim(cNrTransmis)+".XML"
               EndIf     
            EndIf
            
            oRetorno := XmlParserFile( cNomeArq, "", @cError, @cWarning )

            If ValType(oRetorno) <> "O"
               MsgInfo(STR0073,STR0005)  //"Arquivo XML de retorno não encontrado." ## "Atenção"
               lRet := .F.
               Break
            EndIf
   
            oRetorno := oRetorno:_LISTADIAGNOSTICO:_DIAGNOSTICO

            For i := 1 To XMLChildCount(oRetorno)
               oFilho := XmlGetChild(oRetorno, i)
               cTag1 := If(cServico == INT_DI,"_ADICAO","_BEM")
               If ValType(oFilho) <> "A"
                  If oFilho:RealName <> "erros"
                     aAdd(aValores, {oFilho:RealName, oFilho:Text})
                  ElseIf ValType(XMLChildEx(oFilho, cTag1)) == "O" .AND.;
                       ValType(XMLChildEx(oFilho, "_MENSAGEM")) == "O" .AND.;
                       ValType(XMLChildEx(oFilho, "_STATUS")) == "O"
                     oAdicao := XMLChildEx(oFilho, cTag1)
                     oMensag := XMLChildEx(oFilho, "_MENSAGEM")
                     oStatus := XMLChildEx(oFilho, "_STATUS")
                     If !Empty(oAdicao) .AND. !Empty(oMensag:Text) .AND. !Empty(oStatus:Text)
                        aAdd(aErros, {oAdicao:Text, oMensag:Text, oStatus:Text})
                     EndIf
                  EndIf
               Else
                  For j := 1 To Len(oFilho)
                     oAdicao := XMLChildEx(oFilho[j], cTag1)
                     oMensag := XMLChildEx(oFilho[j], "_MENSAGEM")
                     oStatus := XMLChildEx(oFilho[j], "_STATUS")
                     If !Empty(oAdicao) .AND. !Empty(oMensag:Text) .AND. !Empty(oStatus:Text)
                        aAdd(aErros, {oAdicao:Text, oMensag:Text, oStatus:Text})
                     EndIf
                  Next j
               EndIf
            Next i
         EndIf

      Case Len(aBuffer := EasyGetINI(cNomeArq, "[DESEMBARACO]","[",.T.)) # 0
         cTipo := DI_CONSULTA
         If aScan(aBuffer, "CANAL") > 0
            aAdd(aValores, {"canal",StrTran(aBuffer[aScan(aBuffer, "CANAL")],"CANAL = ","")})
         EndIf
         If aScan(aBuffer, "URF_DESPACHO") > 0
            aAdd(aValores, {"urf_despacho",StrTran(aBuffer[aScan(aBuffer, "URF_DESPACHO")],"URF_DESPACHO = ","")})
         EndIf
         If aScan(aBuffer, "TEXTO_SIT_DESP") > 0
            aAdd(aValores, {"texto_sit_desp",StrTran(aBuffer[aScan(aBuffer, "TEXTO_SIT_DESP")],"TEXTO_SIT_DESP = ","")})
         EndIf
         If aScan(aBuffer, "FISCAL_RESPONSAVEL") > 0
            aAdd(aValores, {"fiscal_responsavel",StrTran(aBuffer[aScan(aBuffer, "FISCAL_RESPONSAVEL")],"FISCAL_RESPONSAVEL = ","")})
         EndIf
         If cServico == INT_DI
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEB]","[",.T.)
            aAdd(aValores, {"num_di",StrTran(aBuffer[aScan(aBuffer, "NUM_DI")],"NUM_DI = ","")})
            aAdd(aValores, {"processo",StrTran(aBuffer[aScan(aBuffer, "PROCESSO_DI")],"PROCESSO_DI = ","")})
         Else
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEBDSI]","[",.T.)
            aAdd(aValores, {"processo",StrTran(aBuffer[aScan(aBuffer, "PROCESSO_DSI")],"PROCESSO_DSI = ","")})
         EndIf
         If aScan(aBuffer, "FILIAL_PROCESSO") > 0
            aAdd(aValores, {"filial",StrTran(aBuffer[aScan(aBuffer, "FILIAL_PROCESSO")],"FILIAL_PROCESSO = ","")})
         EndIf

         if ( cServico == INT_DI .and. len(aValores) == 2 .and. aValores[1][1] == "num_di" .and.  aValores[2][1] == "processo" ) .or. (cServico == INT_DSI .and. len(aValores) == 1 .and. aValores[1][1] == "processo" )
            aAdd( aALLErros , STR0144 + ENTER + STR0145 ) // "Não foi possível prosseguir com a Integração" ### "A autenticação via certificado digital foi cancelada pelo usuário ou houve falha de comunicação com o SISCOMEX."
            lRet := .F.
            Break    
         endif

      Case Len(aBuffer := EasyGetINI(cNomeArq, "[REGISTRO]","[",.T.)) # 0
         cNrTransmis := ""
         cAcao := ""   
         aBuffer := EasyGetINI(cNomeArq, "[REGISTRO]","[",.T.)
         lError := aScan(aBuffer, "ERRO") # 0
         cAcao := StrTran(aBuffer[aScan(aBuffer, "TIPO_ENVIO")],"TIPO_ENVIO = ","") 
         aAdd(aValores, {"acao", cAcao})
         If cServico == INT_DI
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEB]","[",.T.)
            aAdd(aValores, {"processo",StrTran(aBuffer[aScan(aBuffer, "PROCESSO_DI")],"PROCESSO_DI = ","")})
         Else
            aBuffer := EasyGetINI(cNomeArq, "[SISCOMEXWEBDSI]","[",.T.)
            aAdd(aValores, {"processo",StrTran(aBuffer[aScan(aBuffer, "PROCESSO_DSI")],"PROCESSO_DSI = ","")})
         EndIf
         aBuffer := EasyGetINI(cNomeArq, "[REGISTRO]","[",.T.)
         If lError
            cErro := StrTran(aBuffer[aScan(aBuffer, "ERRO")],"ERRO = ","")
            aAdd(aValores, {"origem", "INI"})
            aAdd(aErros, {"erro", cErro})
         Else
            nPos := aScan(aBuffer, "NUM_TRANSMISSAO")
            if nPos > 0
               cNrTransmis := StrTran(aBuffer[nPos],"NUM_TRANSMISSAO = ","")
               If !Empty(cNrTransmis)
                  //aAdd(aValores, {"numeroTransmissao",cNrTransmis})
                  //If cServico == INT_DSI
                  //   cNrTransmis := SubStr(cNrTransmis,1, Len(cNrTransmis)-1)+"-"+SubStr(cNrTransmis,Len(cNrTransmis),1000)
                  //EndIf
                  cNomeArq := SubStr(cNomeArq,1,RAT("\",cNomeArq))+AllTrim(cNrTransmis)+".XML"
                  oRetorno := XmlParserFile( cNomeArq, "", @cError, @cWarning )
         
                  If ValType(oRetorno) <> "O"
                     MsgInfo(STR0073,STR0005)  //"Arquivo XML de retorno não encontrado." ## "Atenção"
                     lRet := .F.
                     Break
                  EndIf
      
                  oRetorno := oRetorno:_LISTADIAGNOSTICO:_DIAGNOSTICO

                  For i := 1 To XMLChildCount(oRetorno)
                     oFilho := XmlGetChild(oRetorno, i)
                     cTag1 := If(cServico == INT_DI,"_ADICAO","_BEM")
                     If ValType(oFilho) <> "A"
                        If oFilho:RealName <> "erros"
                           aAdd(aValores, {oFilho:RealName, oFilho:Text})
                        ElseIf ValType(XMLChildEx(oFilho, cTag1)) == "O" .AND.;
                           ValType(XMLChildEx(oFilho, "_MENSAGEM")) == "O" .AND.;
                           ValType(XMLChildEx(oFilho, "_STATUS")) == "O"
                           oAdicao := XMLChildEx(oFilho, cTag1)
                           oMensag := XMLChildEx(oFilho, "_MENSAGEM")
                           oStatus := XMLChildEx(oFilho, "_STATUS")
                           If !Empty(oAdicao) .AND. !Empty(oMensag:Text) .AND. !Empty(oStatus:Text)
                              aAdd(aErros, {oAdicao:Text, oMensag:Text, oStatus:Text})
                           EndIf
                        EndIf
                     Else
                        For j := 1 To Len(oFilho)
                           oAdicao := XMLChildEx(oFilho[j], cTag1)
                           oMensag := XMLChildEx(oFilho[j], "_MENSAGEM")
                           oStatus := XMLChildEx(oFilho[j], "_STATUS")
                           If !Empty(oAdicao) .AND. !Empty(oMensag:Text) .AND. !Empty(oStatus:Text)
                           aAdd(aErros, {oAdicao:Text, oMensag:Text, oStatus:Text})
                           EndIf
                        Next j
                     EndIf
                  Next i
                  If aScan(aValores,{|x| x[1] == "numeroTransmissao"}) == 0
                     aAdd(aValores, {"numeroTransmissao",cNrTransmis})
                  EndIf
               Else
                  MsgInfo(STR0073,STR0005)  //"Arquivo XML de retorno não encontrado." ## "Atenção"
                  lRet := .F.
                  Break
               EndIf
            else
               aAdd( aALLErros , STR0144 + ENTER + STR0145 ) // "Não foi possível prosseguir com a Integração" ### "A autenticação via certificado digital foi cancelada pelo usuário ou houve falha de comunicação com o SISCOMEX."
               lRet := .F.
               Break         
            endif
         EndIf
      End Case
      If cTipo <> DI_CONSULTA
         EICINTSISWEB:GravaEVC(aValores,aErros)
      Else
         EICINTSISWEB:GravaSW6(, .F., aValores)
      EndIf
   
   ElseIf cServico == INT_LI

      Do Case
         // rotina para validar o retorno da consulta da LI
         Case Len(aBuffer := EasyGetINI(cNomeArq, "[CONSULTA_LI]","[",.T.)) # 0
            
            /* posição dos arrays que serão gravados na SWP quando for consulta LI
            aGravaRet[1] - Tipo
            aGravaRet[2] - Contem Erros (.T./.F.)
            aGravaRet[3] - Numero LI
            aGravaRet[4] - Numero PLI
            aGravaRet[5] - Status
            aGravaRet[6] - Data de Registro
            aGravaRet[7] - Data de Cancelamento
            aGravaRet[8] - Data de Situação
            aGravaRet[9] - Data de Validade
            aGravaRet[10] - Anuncias
               aGravaRet[10][1] - Anuencia X
               aGravaRet[10][2] - Codigo Orgao
               aGravaRet[10][3] - Tratamento
               aGravaRet[10][4] - Situação de Anuencia
               aGravaRet[10][5] - Data de Anuencia
               aGravaRet[10][6] - Data de Validade
               aGravaRet[10][7] - Texto de Anuencia
              aGravaRet[11] - Erros encontrados
            */

            cTipo := CONSULTA_ANUENCIA
            aSiscomex := EasyGetINI(cNomeArq, "[SISCOMEXWEBLI]","[",.T.)
            cErros := ""
            If len(aErros := EasyGetINI(cNomeArq, "[LISTA_ERRO]","[",.T.)) # 0
               lError := .T.
               For j := 2 To Len(aErros)
                  cErros += aErros[j] + ENTER
               Next j
            endif

            aAdd(aGravaRet, cTipo)                                                                                   // [1] - Tipo
            aAdd(aGravaRet, lError)                                                                                   // [2] - Contem Erros (.T./.F.)
            if !lError
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "NUM_LI")]           ,"NUM_LI = "            ,""))    // [3] - Numero LI
               aAdd(aGravaRet, StrTran(aSiscomex[aScan(aSiscomex, "NUMERO_PROCESSO")]  ,"NUMERO_PROCESSO = "   ,""))    // [4] - Numero PLI
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "STATUS")]           ,"STATUS = "            ,""))    // [5] - Status
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "DATA_REGISTRO")]    ,"DATA_REGISTRO = "     ,""))    // [6] - Data de Registro
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "DATA_CANCELAMENTO")],"DATA_CANCELAMENTO = " ,""))    // [7] - Data de Cancelamento
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "DATA_SITUACAO")]    ,"DATA_SITUACAO = "     ,""))    // [8] - Data de Situação
               aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer    , "DATA_VALIDADE")]    ,"DATA_VALIDADE = "     ,""))    // [9] - Data de Validade

               For j := 1 To 500
                  aAnuencia := EasyGetINI(cNomeArq, "[ANUENCIA_"+cValToChar(j)+"]","[",.T.)
                  aRetA := {}
                  If Len(aAnuencia) # 0

                     aAdd(aRetA, "ANUENCIA "+cValToChar(j))                                                               // [10][1] - Anuencia X
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "COD_ORGAO")]         ,"COD_ORGAO = "         ,""))   // [10][2] - Codigo Orgao
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "TRATAMENTO")]        ,"TRATAMENTO = "        ,""))   // [10][3] - Tratamento
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "SITUACAO_ANUENCIA")] ,"SITUACAO_ANUENCIA = " ,""))   // [10][4] - Situação de Anuencia
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "DATA_ANUENCIA")]     ,"DATA_ANUENCIA = "     ,""))   // [10][5] - Data de Anuencia
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "DATA_VALIDADE")]     ,"DATA_VALIDADE = "     ,""))   // [10][6] - Data de Validade
                     aAdd(aRetA, StrTran(aAnuencia[aScan(aAnuencia, "TEXTO_ANUENCIA")]    ,"TEXTO_ANUENCIA = "    ,""))   // [10][7] - Texto de Anuencia
                  
                     aAdd(aAnuencias, aRetA)
                  Else
                     Exit
                  EndIf
               Next j
            
               aAdd(aGravaRet, aAnuencias)                           // 10
               cNumLI := aGravaRet[3]+".pdf"
            else
               aAdd(aGravaRet, StrTran(aSiscomex[aScan(aSiscomex, "NUM_LI")]  ,"NUM_LI = "   ,""))                      // [3] - Numero LI
               aAdd(aGravaRet, StrTran(aSiscomex[aScan(aSiscomex, "NUMERO_PROCESSO")]  ,"NUMERO_PROCESSO = "   ,""))    // [4] - Numero PLI
               aAdd(aGravaRet, "-1")  // [5] - Status
               aAdd(aGravaRet, "")  // [6] - Data de Registro
               aAdd(aGravaRet, "")  // [7] - Data de Cancelamento
               aAdd(aGravaRet, "")  // [8] - Data de Situação
               aAdd(aGravaRet, "")  // [9] - Data de Validade
               aAdd(aGravaRet, {})  // [10] - Anuências
            endif

            aAdd(aGravaRet, cErros)                               // 11

         // Rotina para quando for envio de registro da LI
         Case Len(aBuffer := EasyGetINI(cNomeArq, "[REGISTRO]","[",.T.)) # 0
              
            /*
            aGravaRet[1] - Tipo
            aGravaRet[2] - Contem Erros (.T./.F.)
            aGravaRet[3] - Nome do arquivo de envio
            aGravaRet[4] - Numero PLI
            aGravaRet[5] - Numero LI
            aGravaRet[6] - Status
            aGravaRet[7] - Protocolo
            aGravaRet[8] - Data de Registro
            aGravaRet[9] - Erros encontrados
            
            if aScan(aBuffer, "NUM_LI") == 0 .and. aScan(aBuffer, "STATUS") == 0
               lError := .T.
               cErros := "Ocorreram erros no registro da LI, favor realizar o processo novamente." + ENTER
               lRet := .F.
               Break
            endif
            */

            aSiscomex := EasyGetINI(cNomeArq, "[SISCOMEXWEBLI]","[",.T.)
            cTipo := ENVIO
            cIdLI := ""
            If (nPos := aScan(aBuffer, "ID_LI")) # 0
               cIdLI := StrTran(aBuffer[nPos],"ID_LI = ","")  
            EndIf

            cErros := ""
            If len(aErros := EasyGetINI(cNomeArq, "[LISTA_ERRO]","[",.T.)) # 0
               lError := .T.
               For j := 2 To Len(aErros)
                  cErros += aErros[j] + ENTER
               Next j
            Else
               lError := .F.
            endif
         
            aAdd(aGravaRet, cTipo)
            aAdd(aGravaRet, lError)
            aAdd(aGravaRet, StrTran(aSiscomex[aScan(aSiscomex, "ARQUIVO_ENVIO_LI")],"ARQUIVO_ENVIO_LI = ",""))
            aAdd(aGravaRet, StrTran(aSiscomex[aScan(aSiscomex, "NUMERO_PROCESSO")],"NUMERO_PROCESSO = ",""))
            If !lError
            	   If (nPos := aScan(aBuffer, { |x| "NUM_LI" $ alltrim(x) } )) # 0
               		aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer, "NUM_LI")],"NUM_LI = ",""))
                  else
                     aAdd(aGravaRet, "" )
                     cErros += "Arquivo de retorno sem a numeração da LI" + ENTER
               	EndIf
               	If (nPos := aScan(aBuffer, { |x| "STATUS" $ alltrim(x) } )) # 0	
               		aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer, "STATUS")],"STATUS = ",""))
                  else
                     aAdd(aGravaRet, "" )
                     cErros += "Arquivo de retorno sem o status da LI" + ENTER
               	EndIf	
               	If (nPos := aScan(aBuffer, { |x| "NUM_TRANSMISSAO" $ alltrim(x) } )) # 0
               		aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer, "NUM_TRANSMISSAO")],"NUM_TRANSMISSAO = ",""))
                  else
                     aAdd(aGravaRet, "" )
                     cErros += "Arquivo de retorno sem o numero de transmissão da LI" + ENTER
               	EndIf
               	If (nPos := aScan(aBuffer, { |x| "DATA_REGISTRO" $ alltrim(x) } )) # 0	
               		aAdd(aGravaRet, StrTran(aBuffer[aScan(aBuffer, "DATA_REGISTRO")],"DATA_REGISTRO = ",""))
                  else
                     aAdd(aGravaRet, "" )
                     cErros += "Arquivo de retorno sem a data de registro da LI" + ENTER
               	EndIf
               	if !empty(cErros)
                     cErros := STR0144 + ENTER + STR0145 + ENTER + cErros // "Não foi possível prosseguir com a Integração" ### "A autenticação via certificado digital foi cancelada pelo usuário ou houve falha de comunicação com o SISCOMEX."
                     aGravaRet[2] := .T.
               	endif
            else
               aAdd(aGravaRet, "")  // NUM_LI
               aAdd(aGravaRet, "")  // STATUS
               aAdd(aGravaRet, "")  // PROTOCOLO
               aAdd(aGravaRet, "")  // DATA_REGISTRO
            endif

            aAdd(aGravaRet, cErros)

            If (nPos := aScan(aBuffer, { |x| "ID_LI" $ alltrim(x) } )) # 0
               cIdLI := StrTran(aBuffer[nPos],"ID_LI = ","")  
            EndIf
            aAdd(aGravaRet, cIdLI )
      End Case
      
      // Ponto de entrada para customização do retorno do arquivo
      if EasyEntryPoint("EICDI100")
         Execblock("EICDI100",.F.,.F.,"LEITURA_RETORNO")
      endif

      // após as leituras grava a SWP
      lRet := EICINTSISWEB:GravaSWP(aGravaRet)
   EndIf
End Sequence

Return lRet

/*
Função      : MontaMsg()
Parametros  : nTipo:: 1 - Aceite // 2 - Rejeição
Retorno     : cMsg - Mensagem de erro
Objetivos   : Montagem de mensagem de transmissão
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 09/02/2015 :: 14:31
*/
*-------------------------------*
Static Function MontaMsg(nTipo)
*-------------------------------*
Local cMsg := ""

EVC->(DbSetOrder(1))
EVC->(DbSeek(xFilial("EVC")+AvKey(EV0->EV0_ARQUIV,"EVC_LOTE")))

EV1->(DbSetOrder(2))
EV1->(DbSeek(xFilial("EV1")+AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")))

SWP->(DbSetOrder(6))
SWP->(DbSeek(xFilial("SWP")+AvKey(EV0->EV0_ARQUIV,"WP_LOTE")))

If nTipo == 1 
   cMsg += "======= " + STR0057 + " =======" + ENTER  //"Os processos abaixo foram atualizados: "
   cMsg += ENTER
   If !Empty(EVC->EVC_TRANSM)
      cMsg += STR0090 + AllTrim(EVC->EVC_TRANSM) + ENTER  //"Número de Transmissão: "
      cMsg += ENTER
   EndIf
   Do While EV1->(!Eof()) .AND. EV1->EV1_FILIAL == xFilial("EV1") .AND. EV1->EV1_LOTE == AvKey(EV0->EV0_ARQUIV,"EV1_LOTE")
      //SW6->(DbSeek(xFilial("SW6")+EV1->EV1_HAWB))
      SW6->(DbSeek(If(EV1->(FieldPos("EV1_FILORI")) > 0 .And. !Empty(EV1->EV1_FILORI), EV1->EV1_FILORI, xFilial("SW6"))+EV1->EV1_HAWB))
      cMsg += STR0058 + SW6->W6_HAWB   + ENTER	//"Processo: "
      If cAcao <> ANALISE .AND. ((SW6->W6_CURRIER <> "1" .AND. !Empty(SW6->W6_DI_NUM)) .OR. (SW6->W6_CURRIER == "1" .AND. !Empty(SW6->W6_DIRE)))
         cMsg += If(EV0->EV0_SERVIC == INT_DI,STR0059,STR0118) + Transform(If(SW6->W6_CURRIER == "1",SW6->W6_DIRE,SW6->W6_DI_NUM),AvSX3("W6_DI_NUM",6)) + ENTER	//"Número DI: " ## "Número DSI: "
      Else
         cMsg += If(EV0->EV0_SERVIC == INT_DI,STR0076,STR0119) + ENTER  //"Preenchimento da Declaração de Importação está Ok." ## "Preenchimento da Declaração Simplificada de Importação está Ok."
      EndIf
      If !Empty(SW6->W6_CANAL)
         cMsg += "Canal: " + SW6->W6_CANAL + ENTER
      EndIf
      cMsg += ENTER
      EV1->(DbSkip())
   EndDo
ElseIf nTipo == 2
   cMsg += "======= " + STR0054 + " =======" + ENTER  //"O arquivo de retorno possui erros de integração originados no Siscomex."
   cMsg += ENTER
   cMsg += STR0090 + AllTrim(EVC->EVC_TRANSM) + ENTER  //"Número de Transmissão: "
   cMsg += ENTER
   Do While EVC->(!Eof()) .AND. EVC->EVC_FILIAL == xFilial("EVC") .AND. EVC->EVC_LOTE == AvKey(EV0->EV0_ARQUIV,"EVC_LOTE")
      If EVC->EVC_STATUS == "07" .AND. Upper("Em Processamento") $ Upper(EVC->EVC_TX_STA)
         cMsg += STR0089 + ENTER  //"Aviso Impeditivo:"
         cMsg += EVC->EVC_TX_STA + ENTER
      Else
         cMsg += If(EVC->EVC_STAT_A == "C ",STR0091,If(EVC->EVC_STAT_A == "M ",STR0092,STR0089)) + ENTER  // "Aviso de Alerta:" ## "Atenção:" ## "Aviso Impeditivo:"
         cMsg += If(EV0->EV0_SERVIC == INT_DI,STR0055,STR0120)  + EVC->EVC_ADICAO	 + ENTER	//"Adição: " ### "Bem: "
         cMsg += STR0056  + EVC->EVC_MENSAG	 + ENTER	//"Mensagem: "
         cMsg += ENTER
      EndIf
      EVC->(DbSkip())
   EndDo
ElseIf nTipo == 3
   cMsg += "======= " + STR0057 + " =======" + ENTER  //"Os processos abaixo foram atualizados: "
   cMsg += ENTER
   Do While SWP->(!Eof()) .AND. SWP->WP_FILIAL == xFilial("SWP") .AND. SWP->WP_LOTE == AvKey(EV0->EV0_ARQUIV,"WP_LOTE")
      cMsg += STR0058 + AllTrim(SWP->WP_PGI_NUM) + "/" + AllTrim(SWP->WP_SEQ_LI) + ENTER	//"Processo: "
      cMsg += STR0075 + SWP->WP_REGIST + ENTER	//"Número LI: "
      cMsg += "Status:" + SWP->WP_STAT + ENTER
      cMsg += ENTER
      SWP->(DbSkip())
   EndDo
ElseIf nTipo == 4
   cMsg += "======= " + STR0054 + " =======" + ENTER  //"O arquivo de retorno possui erros de integração originados no Siscomex."
   cMsg += ENTER
   Do While SWP->(!Eof()) .AND. SWP->WP_FILIAL == xFilial("SWP") .AND. SWP->WP_LOTE == AvKey(EV0->EV0_ARQUIV,"WP_LOTE")
      cMsg += STR0058  + AllTrim(SWP->WP_PGI_NUM) +  "/" + AllTrim(SWP->WP_SEQ_LI) + ENTER	//"Processo: "
      cMsg += "Erros: "+ SWP->WP_ERROS + ENTER  	//"Erros: "
      cMsg += ENTER
      SWP->(DbSkip())
   EndDo
EndIf
IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"MONTA_MENSAGEM"),)
Return cMsg

/*
Função      : LeLog()
Parametros  : cArquivo - Arquivo.zip
				cDir - Diretorio onde encontra-se o arquivo
Retorno     : cTexto - Log armazenado
Objetivos   : Leitura de log de retorno
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/02/2015 :: 18:12
*/
*---------------------------------------*
Static Function LeLog(cArquivo,cDir)
*---------------------------------------*
Local cTexto := "", aTexto := {}, i

aTexto := EasyGetINI(cDir+cArquivo, "ResultadoValidacaoXmlTransmissaoTag","</table>[\n]",.T.)

If Len(aTexto) # 0
   For i := 1 To Len(aTexto)
      cTexto += aTexto[i]
   Next i
EndIf

Return cTexto

/*
Função      : SetTamanho()
Parametros  : nConteudo - Valor a converter (Exemplo: 6.5)
				nTamanho - Tamanho do Inteiro (Exemplo: 13)
				nDecimal - Tamanho do Decimal (Exemplo: 2)
Retorno     : Tag montada para o Siscomex (Exemplo: 000000000000650)
Objetivos   : Montagem de tags de valores para o Siscomex
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/02/2015 :: 18:10
*/
*-------------------------------------------------------*
Static Function SetTamanho(nConteudo,nTamanho,nDecimal)
*-------------------------------------------------------*
Return StrTran(StrZero(nConteudo,nTamanho+nDecimal+If(nDecimal # 0,1,0),nDecimal),".","")

/*
Função      : ValidaReg()
Parametros  : lBlind - Deixa de exibir mensagem de erro das validações
Objetivos   : Validação do registro para marcação
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 27/02/2015 :: 07:18
*/
*----------------------------------------*
Static Function ValidaReg(lBlind,cServico,cAcao)
*----------------------------------------*
Local aTipoEnv := {STR0077,STR0078} //"1 - Analise" ## "2 - Registro"
Private cTipoEnv := aTipoEnv[1]
Private lRet := .F.

If cServico == INT_DI
   SW6->(DbSeek(TMP->(W6_FILIAL+W6_HAWB)))
   If cAcao == ANALISE .Or. cAcao == REGISTRO
      lRet := DI500ValGerTXT(.T.,lBlind)
   ElseIf cAcao == DI_CONSULTA
      lRet := .T.
   EndIf
ElseIf cServico == INT_LI 
   SWP->(DbSetOrder(1))//RMD - 05/02/17
   SWP->(DbSeek(TMP->(WP_FILIAL+WP_PGI_NUM+WP_SEQ_LI)))
   IF cAcao == ENVIO
      lRet := GI400ValGerArq()
   elseif cAcao == CONSULTA_ANUENCIA
      lRet := .t.
   endif
EndIf

IF(EasyEntryPoint("EICDI100"),Execblock("EICDI100",.F.,.F.,"VALIDA_REGISTRO"),)
Return lRet 

/*
Função      : SetPict()
Parametros  : cValor - Valor a ser convertido
Objetivos   : Ajusta picture de valores para montagem de xml LI
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 05/03/2015 :: 14:05
*/
*------------------------------*
Static Function SetPict(cValor)      
*------------------------------*
Local cInteiro := cValtoChar(Val(SubStr(cValor,1,At(",",cValor)-1)))
Local cDecimal := SubStr(cValor,At(",",cValor),1000)
Return AllTrim(Transform(Val(cInteiro), "@E 999,999,999,999"))+cDecimal

/*
Função      : AjustaNome()
Parametros  : Nome do Arquivo a ajustar
Objetivos   : Ajusta nome do arquivo
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 19/03/2015 :: 08:41
*/
*-----------------------------------*
Static Function AjustaNome(cArquivo)
*-----------------------------------*
cArquivo := StrTran(cArquivo,"/","")
cArquivo := StrTran(cArquivo,"\","")
cArquivo := StrTran(cArquivo,":","")
cArquivo := StrTran(cArquivo,"*","")
cArquivo := StrTran(cArquivo,'"',"")
cArquivo := StrTran(cArquivo,"<","")
cArquivo := StrTran(cArquivo,">","")
cArquivo := StrTran(cArquivo,"|","")
cArquivo := StrTran(cArquivo,"+","")
cArquivo := StrTran(cArquivo," ","_")
Return cArquivo

/*
Função      : ImprimeRel()
Parametros  : Servço ativo na arvore
Objetivos   : Efetua a geração do relatorio do processo
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 07/05/2015 :: 14:39
*/
*-----------------------------------*
Static Function ImprimeRel(cWork,nTipoRel, cTipoInt)
*-----------------------------------*
Local cServico := "", cLote := ""
Local cFile:= "Relatorio_Conferencia.html"
Local nHandle := 0
Local aOrd := SaveOrd({"EV0","EV1","EVD"})
Private nPagina := 1
Default nTipoRel := 1

Begin Sequence

   If Select(cWork) == 0 .or. IsVazio(cWork) .or. empty(EV0->EV0_ARQUIVO)
      MsgInfo(STR0123, STR0005) //"Não existem processos para impressão." ## "Atenção"
      Break
   EndIf
      
   cServico := Left(AllTrim(cTipoInt), 2)//If("DI" $ cWork, "DI",If("LI" $ cWork, "LI",If("RAIZ" $ cWork, "RAIZ","DS"))) 
   If cServico == "RAIZ"
      Break
   ElseIf cServico == "DI"
      if cWork == "EV0" .and. !empty(EV1->EV1_HAWB) .and. EV1->( ! eof() ) .and. SW6->( dbsetorder(1),dbseek( xFilial("SW6")+EV1->EV1_HAWB ))  //EV1->(dbsetorder(1),dbseek( xFilial("EV1")+cLote ))
         DI501DIConf()
      endif
      // MsgInfo(STR0130,STR0005)// "Esta ação não está disponivel para o serviço de DI. Favor utilizar o relatorio disponivel na manutenção de Desembaraço." ## "Atenção"
      Break
   ElseIf cServico == "DS"
      MsgInfo(STR0131,STR0005)// "Esta ação não está disponivel para o serviço de DSI." ## "Atenção"
      Break
   EndIf
   
   If File(GetTempPath(.T.)+cFile)
      FErase(GetTempPath(.T.)+cFile)
   EndIf
   
   nHandle := EasyCreateFile(GetTempPath(.T.)+cFile)
   
   cLote := (cWork)->&("EV0_ARQUIV")
   EV0->(DbSetOrder(3))
   EV0->(DbSeek(xFilial("EV0")+AvKey(cLote,"EV0_ARQUIV")))
   Do Case
      Case nTipoRel == 1 .And. cServico == INT_LI //LGS-09/11/2015
           EV5->(DbSetOrder(3))
           EVE->(DbSetOrder(1))
           EVF->(DbSetOrder(1))
           EV5->(DbSeek(xFilial("EV5")+AvKey(cLote,"EV5_LOTE")+AvKey(EVD->EVD_PGI_NU,"EV5_PGI_NU")))
           EVE->(DbSeek(xFilial("EVE")+AvKey(EVD->EVD_PGI_NU,"EVE_PGI_NU")+AvKey(cLote,"EVE_LOTE")+AvKey(EVD->EVD_SEQLI,"EVE_SEQLI")))
           EVF->(DbSeek(xFilial("EVF")+AvKey(EVD->EVD_PGI_NU,"EVF_PGI_NU")+AvKey(cLote,"EVD_LOTE")+AvKey(EVD->EVD_SEQLI,"EVF_SEQLI")))
           
           FSEEK(nHandle, 0, FS_END)
           If FWrite(nHandle,H_RELLI()) == 0
              MsgInfo(STR0126, STR0005)  //"Erro de Abertura do arquivo." ## "Atenção"
              Break
           EndIf  
      
      Case nTipoRel == 2 .And. cServico == INT_LI //LGS-09/11/2015
           EV5->(DbSetOrder(3))
           EVE->(DbSetOrder(1))
           EVF->(DbSetOrder(1))
           
           EVD->(DbGoTop())
           EVD->(DbSeek(xFilial("EVD") + AvKey(cLote,"EVD_LOTE") ))
           Do While EVD->(!Eof()) .And. EVD->EVD_LOTE ==  EV0->EV0_ARQUIV
              EV5->(DbSeek(xFilial("EV5")+AvKey(cLote,"EV5_LOTE")+AvKey(EVD->EVD_PGI_NU,"EV5_PGI_NU")))
              EVE->(DbSeek(xFilial("EVE")+AvKey(EVD->EVD_PGI_NU,"EVE_PGI_NU")+AvKey(cLote,"EVE_LOTE")+AvKey(EVD->EVD_SEQLI,"EVE_SEQLI")))
              EVF->(DbSeek(xFilial("EVF")+AvKey(EVD->EVD_PGI_NU,"EVF_PGI_NU")+AvKey(cLote,"EVD_LOTE")+AvKey(EVD->EVD_SEQLI,"EVF_SEQLI")))
              
              FSEEK(nHandle, 0, FS_END)
              If FWrite(nHandle,H_RELLI()) == 0
                 MsgInfo(STR0126, STR0005)  //"Erro de Abertura do arquivo." ## "Atenção"
                 Break
              EndIf 
              nPagina++
              EVD->(DbSkip())
           EndDo
   EndCase
   
   FClose(nHandle)
   ShellExecute("open", GetTempPath(.T.)+cFile,"", "", 1)
   EV1->(DBClearFilter())
   EVD->(DBClearFilter())

End Sequence

RestOrd(aOrd,.T.)
Return NIL

*------------------------------------------------------------------------------------* 
// Funcao   : CONWriteWEB()
// Data     : 03/08/2016
// Autor    : Lucas Raminelli
*------------------------------------------------------------------------------------* 
Static Function CONWriteWEB(cFileName)
*------------------------------------------------------------------------------------* 

Local cMensagem := ""
Local lCreate   := .T.
Local nHandle   := 0
Local nSeconds  := 0
Local nTimeOut  := 0

   cMensagem := "Tempo máximo para execução"

   nSeconds := 60*60  // Define o tempo máximo que o sistema aguardará a execução do conversor.exe
   nTimeOut := Seconds()+nSeconds

   ProcRegua(nSeconds)

   Begin Sequence

      nHandle := F_ERROR
 
      // Tenta abrir o arquivo em modo exclusivo
      Do While !File(cFileName)  .Or.  ( nHandle := EasyOpenFile( cFileName, FO_EXCLUSIVE ) ) == F_ERROR

         // Se o cliente cancelar ou o exceder o tempo
         If lEnd  .Or.  nTimeOut <= Seconds()
            lCreate := .F.
            Break
         EndIf

         nHour   := Int( nSeconds / 3600 )
         nMinute := Int( ( nSeconds - (nHour*3600) ) / 60 )
         nSecond := Int( nSeconds - (nHour*3600) - (nMinute*60) )
         IncProc(cMensagem+" ("+StrZero(nHour,2)+":"+StrZero(nMinute,2)+":"+StrZero(nSecond,2)+")")

         AvDelay(1)
         nSeconds--

      EndDo
   
      If nHandle != F_ERROR
         FClose( nHandle )
      EndIf
      
   End Sequence


Return lCreate

Static Function EasyWkQuery(cQuery,cAliasWk,aIndices,aNotCmposSX3, bCond, lAppend)
Local nInc, nPos
Local aArray   := {}
Local aFileWk  := {}
Local cWork    := E_Create(,.F.)
Local aCamposOld := {}  // GFP - 29/08/2014
Local lGeraCpos := .F.  // GFP - 29/08/2014
//Local cAlias   := ""  // GFP - 30/04/2014
Default aNotCmposSX3 := {}
Default lAppend := .T.

If Type("aCampos") == "U"    // GFP - 19/09/2014
   aCampos := {}
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cWork, .F.)

SX3->(DbSetOrder(2))//X3_CAMPO

If Type("cAlias") == "U" .AND. Len(aCampos) # 0 .AND. Type("aCampos[1]") == "U"   // GFP - 29/08/2014
   aCamposOld := aClone(aCampos)
   aCampos := {}
   lGeraCpos := .T.
EndIf

FOR nInc := 1 TO (cWork)->(FCount())

   If "R_E_C_N_O_" $  (cWork)->(FIELDNAME(nInc)) //FSM - 31/10/2012
      loop
   EndIf

   //If !( "R_E_C_N_O_" $  (cWork)->(FIELDNAME(nInc)) .Or. "R_E_C_D_E"  $  (cWork)->(FIELDNAME(nInc)) )
   If SX3->(DbSeek((cWork)->(FIELDNAME(nInc))))
      //TCSetField(cWork, (cWork)->(FIELDNAME(nInc)), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TIPO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TAMANHO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_DECIMAL) )

      AADD(aArray,{(cWork)->(FIELDNAME(nInc)), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TIPO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TAMANHO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_DECIMAL)})
      If lGeraCpos   // GFP - 29/08/2014
         AADD(aCampos,(cWork)->(FIELDNAME(nInc)))
      EndIf

   ElseIf (nPos:= aScan(aNotCmposSX3,{|x| AllTrim(x[1]) == AllTrim((cWork)->(FIELDNAME(nInc)))   }))  >  0

      AADD(aArray,{aNotCmposSX3[nPos][1], aNotCmposSX3[nPos][2], aNotCmposSX3[nPos][3], aNotCmposSX3[nPos][4]})

   EndIf

   If Len(aArray) > 0 .And. aArray[Len(aArray)][2] <> "C"
      TCSetField(cWork, aArray[Len(aArray)][1], aArray[Len(aArray)][2], aArray[Len(aArray)][3], aArray[Len(aArray)][4])
   EndIf

NEXT nInc

If !TETempBanco() .And. aScan(aArray,{|x|  x[1] == "R_E_C_N_O_" }) == 0
  AADD(aArray,{"R_E_C_N_O_", "N", 7, 0})
EndIf

AADD(aFileWk,E_CriaTrab(,aArray,cAliasWk))

If ValType(aIndices) <> "A"
   aIndices := {aArray[1][1]}
EndIf

For nInc := 1 To Len(aIndices)
   AADD(aFileWk,E_Create(,.F.))
   IndRegua(cAliasWk,aFileWk[1+nInc]+TEOrdBagExt(),aIndices[nInc])
Next nInc

For nInc := 1 To Len(aIndices)
   DBSETINDEX(aFileWk[1+nInc]+TEOrdBagExt())
Next nInc
If lAppend
   (cWork)->(dbGoTop())
   While (cWork)->(!EOF())
      If bCond == NIL .OR. Eval(bCond,cWork)
         (cAliasWk)->(DBAPPEND())
         AVReplace(cWork,cAliasWk)
      EndIf

      (cWork)->(dbSkip())
   EndDo

   If Select(cWork) > 0
      (cWork)->(DbCloseArea())
   EndIf
EndIf

(cAliasWk)->(dbGoTop())
aCampos := If(Len(aCamposOld) # 0,aClone(aCamposOld),aCampos)  // GFP - 29/08/2014

Return cWork
