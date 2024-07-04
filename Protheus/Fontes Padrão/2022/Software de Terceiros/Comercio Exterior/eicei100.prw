#Include "AVERAGE.CH"
#Include "APWizard.CH"
#Include "EEC.cH"
#Include "eicei100.ch"
#Include "Protheus.CH"
#Include "FILEIO.CH"


//Serviços
#Define ENV_PO        "EPO"
#Define ENV_DI        "EDI"
#Define REC_NUMERARIO "RNU"
#Define REC_DESPESAS  "RDE"
#Define REC_NF        "RNF"
//Status
#Define GERADOS       "GER"
#Define ENVIADOS	    "ENV"
#Define RECEBIDOS     "REC"
#Define INTEGRADOS    "INT"
#Define REJEITADOS    "REJ"

Function EICEI100()
Private EICIDESPAC

//LGS-08/04/2014
SX3->(DbSetOrder(2))
If SX3->(DbSeek("EWZ_STATUS"))
	If SX3->X3_TAMANHO < 3
    	MsgInfo("Esse ambiente precisa ser atualizado com o Update UISDMOIK","Informação")
    EndIf
EndIf

If FindFunction("EECEI300") .And. ChkFile("EWQ") .And. ChkFile("EWZ")
   EICIDESPAC := EICIDESPAC():New("Controle de Integrações com Despachante", "Serviços", "Ações", "Serviços", "Ações", "Serviços")
   EICIDESPAC:SetServicos()
   EICIDESPAC:Show()
Else
   MsgStop("Esse ambiente não está preparado para executar a nova rotina de integração com despachante.", "Atenção")
EndIf

Return nil

// Classe EICIDESPAC
Class EICIDESPAC From AvObject

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
    
	Data	aServices
    
	Data	aCposGer
	Data	aCposEnv
	Data	aCposRec
	Data	aCposPrc
    Data    aCposRecNF
    Data    aCposPrcNF
    
    //* FSY - 24/09/2013 - Objeto para ser utilizada nos campos da tela de integração
    Data aCposGerPO
    Data aCposGerDI
    Data aCposEnvPO
    Data aCposEnvDI
    //* FSY - 24/09/2013
    
    Data    cDirGerados
    Data    cDirEnviados
    Data    cDirRecebidos
    Data    cDirRejeitados
    Data    cDirProcessados
	Data    cDirRoot
	Data    cDirNumerario
	Data    cDirDespesas
	Data    cDirNF
    Data    cFile

    Data    oUserParams

	Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Constructor
	Method SetServicos()
	Method Show()
  	Method SetDiretorios()   
    Method GerarArq(cFaseOR102)
    Method EnviarEmail(cWork)
    Method ReceberArq(cWork,cServico)
    Method ProcessarArq(cWork,cServico)
    Method EditConfigs()
    Method GravaEWZ(cArquivo, cServico, cStatus, aDesp)
    Method ViewCapa(oMsSelect)
   
End Class

Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Class EICIDESPAC

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
   Self:oUserParams     := EASYUSERCFG():New("EICIDESPAC")
   Self:cFile           := ""

   Self:aServices 		:= {}
   
   //* FSY - 24/09/2013 - Adicionado campo e validação para "EWZ_PO_NUM", "EWZ_HAWB"
   If FieldPos("EWZ_PO_NUM") > 0  .And. FieldPos("EWZ_HAWB") > 0
      Self:aCposGerPO := {"EWZ_PO_NUM", "EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
      Self:aCposEnvPO := {"EWZ_PO_NUM", "EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      Self:aCposGerDI := {"EWZ_HAWB"  , "EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
      Self:aCposEnvDI := {"EWZ_HAWB"  , "EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      Self:aCposEnv   := {"EWZ_PO_NUM", "EWZ_HAWB","EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      Self:aCposGer   := {"EWZ_PO_NUM", "EWZ_HAWB","EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
   Else
      Self:aCposGerPO := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
      Self:aCposEnvPO := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      Self:aCposGerDI := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
      Self:aCposEnvDI := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      //Campos para o arquivo enviado
      Self:aCposEnv   := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USEREN", "EWZ_DATAEN", "EWZ_HORAEN" }
      //Campos para o arquivo gerado
      Self:aCposGer   := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERGE", "EWZ_DATAGE", "EWZ_HORAGE" }
   End If
   //* FSY - 24/09/2013
   
   //Campos para o arquivo recebido numerario ou despesas
   Self:aCposRec   := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERRE", "EWZ_DATARE", "EWZ_HORARE" }
   //Campos para o arquivo processado numerario ou despesas
   Self:aCposPrc   := {"EWZ_ARQUIV", "EWZ_NOMEDE" , "EWZ_EMAIL", "EWZ_USERPR", "EWZ_DATAPR", "EWZ_HORAPR" }
   //Campos para o arquivo recebido nota fiscal
   Self:aCposRecNF := {"EWZ_ARQUIV", "EWZ_USERRE", "EWZ_DATARE", "EWZ_HORARE"}
   //Campos para o arquivo recebido nota fiscal
   Self:aCposPrcNF := {"EWZ_ARQUIV", "EWZ_USERPR", "EWZ_DATAPR", "EWZ_HORAPR"}

   Self:SetDiretorios()

Return Self

Method SetServicos() Class EICIDESPAC
Local nInc := 0   // GFP - 01/07/2013
Local oSrvENV_PO
Local oSrvENV_DI
Local oSrvREC_DESPESAS
Local oSrvREC_NF  

Local aSrvENV_PO := {ENV_PO + GERADOS , ENV_PO + ENVIADOS}
Local aSrvENV_DI := {ENV_DI + GERADOS , ENV_DI + ENVIADOS}
Local aSrvREC_NUMERARIO := {REC_NUMERARIO + RECEBIDOS, REC_NUMERARIO + INTEGRADOS, REC_NUMERARIO + REJEITADOS}
Local aSrvREC_DESPESAS  := {REC_DESPESAS + RECEBIDOS, REC_DESPESAS + INTEGRADOS, REC_DESPESAS + REJEITADOS}
Local aSrvREC_NF := {REC_NF + RECEBIDOS, REC_NF + INTEGRADOS, REC_NF + REJEITADOS}

//Variavel para a funcao EICIN100
Private cFuncao     := ""

//Permite a inclusão de novas ações
Private aActions := {}

   // Serviço de exportação PO
   oSrvENV_PO := EECSISSRV():New("Envio de PO" , "EWZ", "Controle de integração com despachante", ENV_PO , 1, "NORMAS", "NORMAS", , , "EWZ_FILIAL + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "xFilial('EWZ') + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "")
   //Folders para serviço de exportação PO
   oSrvENV_PO:AddFolder("Gerados"  , GERADOS , ENV_PO + GERADOS , Self:aCposGerPO,"Folder5","Folder6")
   oSrvENV_PO:AddFolder("Enviados" , ENVIADOS, ENV_PO + ENVIADOS, Self:aCposEnvPO,"Folder5","Folder6")

   // Serviço de exportação DI
   oSrvENV_DI := EECSISSRV():New("Envio de Embarque" , "EWZ", "Controle de integração com despachante", ENV_DI , 1, "NORMAS", "NORMAS", , , "EWZ_FILIAL + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "xFilial('EWZ') + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "")
   //Folders para serviço de exportação DI
   oSrvENV_DI:AddFolder("Gerados"  , GERADOS , ENV_DI + GERADOS , Self:aCposGerDI,"Folder5","Folder6")
   oSrvENV_DI:AddFolder("Enviados" , ENVIADOS, ENV_DI + ENVIADOS, Self:aCposEnvDI,"Folder5","Folder6")

   // Serviço de recebimento de numerario
   oSrvREC_NUMERARIO := EECSISSRV():New("Recebimento de numerario" , "EWZ", "Controle de integração com despachante", REC_NUMERARIO , 1, "NORMAS", "NORMAS", , , "EWZ_FILIAL + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "xFilial('EWZ') + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "")
   //Folders para serviço de recebimento de numerario
   oSrvREC_NUMERARIO:AddFolder("Recebidos"  , RECEBIDOS  , REC_NUMERARIO + RECEBIDOS  , Self:aCposRec,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'NU', EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_NUMERARIO:AddFolder("Integrados" , INTEGRADOS , REC_NUMERARIO + INTEGRADOS , Self:aCposPrc,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'NU', EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_NUMERARIO:AddFolder("Rejeitados" , REJEITADOS , REC_NUMERARIO + REJEITADOS , Self:aCposPrc,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'NU', EICIDESPAC:ViewCapa(oMsSelect)}")

   // Serviço de recebimento de despesas
   oSrvREC_DESPESAS  := EECSISSRV():New("Recebimento de despesas" , "EWZ", "Controle de integração com despachante", REC_DESPESAS , 1, "NORMAS", "NORMAS", , , "EWZ_FILIAL + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "xFilial('EWZ') + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "")
   //Folders para serviço de recebimento de despesas
   oSrvREC_DESPESAS:AddFolder("Recebidos"  , RECEBIDOS  , REC_DESPESAS + RECEBIDOS  , Self:aCposRec,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'DE' , EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_DESPESAS:AddFolder("Integrados" , INTEGRADOS , REC_DESPESAS + INTEGRADOS , Self:aCposPrc,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'DE' , EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_DESPESAS:AddFolder("Rejeitados" , REJEITADOS , REC_DESPESAS + REJEITADOS , Self:aCposPrc,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'DE' , EICIDESPAC:ViewCapa(oMsSelect)}")
   
   // Serviço de recebimento de NF
   oSrvREC_NF := EECSISSRV():New("Recebimento de NF" , "EWZ", "Controle de integração com despachante", REC_NF , 1, "NORMAS", "NORMAS", , , "EWZ_FILIAL + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "xFilial('EWZ') + EWZ_SERVIC + EWZ_STATUS + EWZ_ARQUIV", "")
   //Folders para serviço de recebimento de NF
   oSrvREC_NF:AddFolder("Recebidos"  , RECEBIDOS  , REC_NF + RECEBIDOS  , Self:aCposRecNF,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'FE' ,EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_NF:AddFolder("Integrados" , INTEGRADOS , REC_NF + INTEGRADOS , Self:aCposPrcNF,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'FE' ,EICIDESPAC:ViewCapa(oMsSelect)}")
   oSrvREC_NF:AddFolder("Rejeitados" , REJEITADOS , REC_NF + REJEITADOS , Self:aCposPrcNF,"Folder5","Folder6",,,"{|oMsSelect| cFuncao := 'FE' ,EICIDESPAC:ViewCapa(oMsSelect)}")

   //TRP - 17/12/12
   // Ação para o serviço de exportação PO
   oSrvENV_PO:AddAction("Int. PO"        , "INTPO"    , {"RAIZ", ENV_PO + GERADOS} , {|cWork, cId| cId := GetId(cId), If(!Empty(cID), Self:GerarArq("PO"),) }                 , GERADOS , "SduRecall", "SduRecall")
   // Ação para o serviço de exportação DI
   oSrvENV_PO:AddAction("Int. DI"        , "INTDI"    , {"RAIZ", ENV_DI + GERADOS} , {|cWork, cId| cId := GetId(cId), If(!Empty(cID), Self:GerarArq("DI"),) }                , GERADOS , "SduRecall", "SduRecall")
   //Recebimento de Numerário e Despesas Efetivas
   oSrvENV_PO:AddAction("Receber arquivos", "REC_NUM"  , {"RAIZ", REC_NUMERARIO + RECEBIDOS, REC_DESPESAS + RECEBIDOS, REC_NF + RECEBIDOS} , {|cWork, cId| cId := GetId(cId), If(!Empty(cID), Self:ReceberArq(cWork,cId),) }   , RECEBIDOS, "bmppost", "bmppost")
   oSrvENV_PO:AddAction("Processar"      , "PROCNUM"  , {"RAIZ", REC_NUMERARIO + RECEBIDOS, REC_DESPESAS + RECEBIDOS, REC_NF + RECEBIDOS} , {|cWork, cId| cId := GetId(cId), If(!Empty(cID), Self:ProcessarArq(cWork,cId),) } , RECEBIDOS , "SduRecall", "SduRecall")
   
   //Gerais
   If GetRemoteType() <> 5
      oSrvREC_NUMERARIO:AddAction("Configuração"   , "CONFIG"   , {"RAIZ", ENV_PO, ENV_DI, REC_NUMERARIO, REC_DESPESAS}   , {|| Self:EditConfigs()}                  , ""      , "AVG_IOPT", "AVG_IOPT")   
   EndIf
   oSrvENV_PO:AddAction("Enviar email"   , "ENVMAILPO", {"RAIZ", ENV_PO + GERADOS, ENV_DI + GERADOS} , {|cWork, cID| cId := GetId(cId), If(!Empty(cID), Self:EnviarEmail(cWork,cId),) } , GERADOS , "bmppost", "bmppost")
   
   // GFP - 01/07/2013 - Ponto de Entrada para criação de Ações
   IF(EasyEntryPoint("EICEI100"),ExecBlock("EICEI100",.F.,.F.,"ADICIONA_ACOES"),)
   For nInc := 1 To Len(aActions)
      /*
         Actions -> {{"Título", "ID", "IMAGEM", "cAcao"}}
         cAcao -> Função que receberá como parâmetro: 
			1 - Work contendo os registros filtrados (exibidos na tela), da tabela EWZ
			
         	2 - Id da pasta atual, no formato IIIPPP, onde:
	         	III - Integração:
					"EPO" - Envio de PO;
					"EDI" - Envio de DI;
					"RNU" - Recebimento do numerário;
					"RDE" - Recebimento de despesas;
					"RNF" - Recebimento de NF.
				PPP - Pasta:
					"GER" - Gerados;
					"ENV" - Enviados;
					"REC" - Recebidos;
					"INT" - Integrados;
					"REJ" - Rejeitados.
         
         Exemplo: cAcao = FuncaoTeste. 
         A chamada será feita da seguinte maneira caso o usuário clique na opção no momento em que estiver visualizando a pasta Itens Gerados para o PO:
         	FuncaoTeste("WORKXXX", "EPOGER")
      */
      oSrvENV_PO:AddAction(aActions[nInc][1], aActions[nInc][2], {"RAIZ", REC_NUMERARIO + RECEBIDOS, REC_DESPESAS + RECEBIDOS, REC_NF + RECEBIDOS} , {|cWork, cId| cId := GetId(cId), If(!Empty(cID), &(aActions[nInc][4] + "(" + cWork + "," + cId + ")") ,) } , RECEBIDOS , aActions[nInc][3], aActions[nInc][3])
   Next
     
   // Adicionando todos os serviços
   aAdd(Self:aServices, oSrvENV_PO)
   aAdd(Self:aServices, oSrvENV_DI)
   aAdd(Self:aServices, oSrvREC_NUMERARIO)
   aAdd(Self:aServices, oSrvREC_DESPESAS)
   aAdd(Self:aServices, oSrvREC_NF)


Return Nil

//TRP - 17/12/12
//GetId(cId) - Ajusta o Id da pasta selecionada
Static Function GetId(cId)

	cId := Alltrim(StrTran(cId, "oS", ""))
	
	If cId <> "RAIZ"
		cId := Left(cId, 3)
	Else
		MsgInfo("Selecione uma pasta válida para execução da ação.", "Aviso")
		cId := ""
	EndIf

Return cId

Method Show() Class EICIDESPAC
Local aServicos := {}
Local aAcoes  := {}
Local nInc

   For nInc := 1 To Len(Self:aServices)
      aAdd(aServicos, Self:aServices[nInc]:RetService())
      aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
   Next

   AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .F.,,,.F.)

Return Nil

Method SetDiretorios() Class EICIDESPAC 
Private cDirGerados     := "" //RRV - 27/09/2012 - Variáveis necessárias para criação dos diretórios utilizados na integração do arquivo. 
Private cDirEnviados    := ""
Private cDirRecebidos   := ""
Private cDirRejeitados  := ""
Private cDirProcessados := ""

Private oUpdAtu

   // GFP - 09/08/2012 - Tratamento para ambientes Linux
   If IsSrvUnix()
      Self:cDirGerados     := "/comex/intdespachante/gerados/"
      Self:cDirEnviados    := "/comex/intdespachante/enviados/"
      Self:cDirRecebidos   := "/comex/intdespachante/recebidos/"
      Self:cDirRejeitados  := "/comex/intdespachante/rejeitados/"
      Self:cDirProcessados := "/comex/intdespachante/integrados/"
   Else
      Self:cDirGerados     := "\comex\IntDespachante\gerados\"
      Self:cDirEnviados    := "\comex\IntDespachante\enviados\"
      Self:cDirRecebidos   := "\comex\IntDespachante\recebidos\"
      Self:cDirRejeitados  := "\comex\IntDespachante\rejeitados\"
      Self:cDirProcessados := "\comex\IntDespachante\integrados\"
   EndIf   
   
   //RRV - 27/09/2012
   If FindFunction("AvUpdate01") 
      oUpdAtu := AvUpdate01():New()
      cDirGerados     := Self:cDirGerados
      cDirEnviados    := Self:cDirEnviados
      cDirRecebidos   := Self:cDirRecebidos
      cDirRejeitados  := Self:cDirRejeitados
      cDirProcessados := Self:cDirProcessados
   EndIf

   If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
      oUpdAtu:aChamados := {{nModulo,{|o| CriaDir(o)}}}
      oUpdAtu:Init(,.T.)
   EndIf

   Self:cDirRoot        := GetSrvProfString("ROOTPATH","")
   Self:cDirNumerario   := Self:oUserParams:LoadParam("NUMDIRLOC", "","EICIDESPAC")
   Self:cDirDespesas    := Self:oUserParams:LoadParam("DSPDIRLOC", "","EICIDESPAC")
   Self:cDirNF          := Self:oUserParams:LoadParam("NFDIRLOC", "","EICIDESPAC")

Return Nil

Method EditConfigs() Class EICIDESPAC
Local nLin          := 15, nCol := 12
Local lRet          := .F.
Local bOk           := {|| lRet := .T., oDlg:End() }
Local bCancel       := {|| oDlg:End() }
Local oDlg
Local cDirNumerario := Self:cDirNumerario
Local cDirDespesas  := Self:cDirDespesas
Local cDirNF        := Self:cDirNF
Local cTitulo       := "Configurações para o usuário: " + cUserName
Local bSetFileNum   := {|| cDirNumerario := cGetFile("","Diretório local para importação de arquivos do despachante", 0, cDirNumerario,,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }
Local bSetFileDes   := {|| cDirDespesas  := cGetFile("","Diretório local para importação de arquivos do despachante", 0, cDirNumerario,,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }
Local bSetFileNF    := {|| cDirNF        := cGetFile("","Diretório local para importação de arquivos do despachante", 0, cDirNumerario,,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 580,785 OF oMainWnd PIXEL
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ nLin, 6 To 94, 189 Label "Preferências" Of oPanel Pixel
    nLin += 10
	@ nLin,nCol Say "Diretório local para importação de arquivos de numerario" Size 160,08 PIXEL OF oPanel
    nLin += 10
	@ nLin,nCol MsGet cDirNumerario Size 150,08 PIXEL OF oPanel
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileNum) SIZE 10,10 PIXEL OF oPanel

    nLin += 12
	@ nLin,nCol Say "Diretório local para importação de arquivos de despesas" Size 160,08 PIXEL OF oPanel
    nLin += 10
	@ nLin,nCol MsGet cDirDespesas Size 150,08 PIXEL OF oPanel
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileDes) SIZE 10,10 PIXEL OF oPanel

    nLin += 12
	@ nLin,nCol Say "Diretório local para importação de arquivos de nota fiscal" Size 160,08 PIXEL OF oPanel
    nLin += 10
	@ nLin,nCol MsGet cDirNF Size 150,08 PIXEL OF oPanel
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileNF) SIZE 10,10 PIXEL OF oPanel

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      Self:cDirNumerario := cDirNumerario
      Self:cDirDespesas  := cDirDespesas
      Self:cDirNF        := cDirNF
      Self:oUserParams:SetParam("NUMDIRLOC", cDirNumerario , "EICIDESPAC")
      Self:oUserParams:SetParam("DSPDIRLOC", cDirDespesas  , "EICIDESPAC")
      Self:oUserParams:SetParam("NFDIRLOC" , cDirNF        , "EICIDESPAC")
   EndIf

Return Nil

Method GerarArq(cFase) Class EICIDESPAC

Local cArquivo       := ""
Local cServico       := ""
Local aDesp          := {}
Private cFaseOR102   := cFase // Variavel a ser tratada na função EICOR102(), para definir a fase //MCF - 13/04/2015
Private cCodDeEI100  := "" // Variavel a ser tratada na função Ori100Main()
Private cDespEI100   := "" // Variavel a ser tratada na função Ori100Main()
Private cEmailEI100  := "" // Variavel a ser tratada na função Ori100Main()

Begin Sequence
   
   If cFaseOR102 == "PO"
      cServico := ENV_PO
   Else
      cServico := ENV_DI
   EndIf

   // A geração do arquivo esta definida na função Ori100Main(), onde foram realizado tratamentos para indicar o diretorio
   cArquivo := EICOR102()

   If !Empty(cArquivo) .And. Valtype(cArquivo) == "C"
      aDesp := {cCodDeEI100, cDespEI100, cEmailEI100}
      Self:GravaEWZ(cArquivo, cServico, GERADOS,aDesp)
   Else
      MsgInfo("Arquivo não gerado.","Atenção")
      If Select("TRB") > 0
         TRB->(DBCloseArea())
      EndIf
   EndIf

End Sequence

Return Nil

Method EnviarEmail(cWork,cServico) Class EICIDESPAC

Local oServer
Local lRet     := .F.
Local aDesp := {}
Private cSmtpServer    := If (Empty(EasyGParam("MV_RELSERV")), AllTrim(EasyGParam("MV_WFSMTP")), AllTrim(EasyGParam("MV_RELSERV"))) //  RRV 19/09/2012
Private cAccount       := ""//:= If (Empty(EasyGParam("MV_RELACNT")), AllTrim(EasyGParam("MV_RELAUSR")), AllTrim(EasyGParam("MV_RELACNT"))) //  RRV 19/09/2012
Private cPassword      := If (Empty(EasyGParam("MV_RELPSW")), AllTrim(EasyGParam("MV_RELAPSW")), AllTrim(EasyGParam("MV_RELPSW"))) //  RRV 19/09/2012
Private lAutentica     := EasyGParam("MV_RELAUTH",,.F.)
Private nTryConnection := EasyGParam("MV_WFTCONN",,1)
Private nTimeout       := EasyGParam("MV_RELTIME",,120) //  RRV 19/09/2012
Private cUserAuth      := AllTrim(EasyGParam("MV_RELAUSR"))
Private cPswAuth       := AllTrim(EasyGParam("MV_RELAPSW"))
Private cSmtpPort      := EasyGParam("MV_PORSMTP",,25)
Private lEnvioPadrao := .T.
Private lNewRet := .F.
Private cToNew := ""
Private oMessage

//*FSY - 23/09/2013 - Se nao existir e se for vazio considerar como 2
If EasyGParam("MV_AVG0228",,'"2"') == "2" 

   cAccount := UsrRetMail(RetCodUsr())

Else

   If Empty(EasyGParam("MV_RELACNT"))
      cAccount := AllTrim(EasyGParam("MV_RELAUSR"))
   Else
      cAccount := AllTrim(EasyGParam("MV_RELACNT"))
   End If

End If
//*FSY - 23/09/2013
Begin Sequence

   If Empty((cWork)->EWZ_ARQUIV)
      MsgInfo("Selecione um registro para ser enviado.","Atenção")
      Break
   EndIf

   //If Empty(cSmtpServer) .Or. Empty(cAccount) /*.Or. Empty(cPassword)*/ Or. Empty(lAutentica) .Or. Empty(nTimeout)     // Nopado por GFP - 07/08/2012
   //Parâmetros para conexão
   If Empty(cSmtpServer) .Or. Empty(cAccount) //  RRV 19/09/2012
      MsgInfo("Verificar os parâmentos para conexão com o servidor SMTP.","Atenção")
      Break
   EndIf

   //Parâmetros para autenticação
   If lAutentica .And. (Empty(cUserAuth) .Or. Empty(cPswAuth)) //  RRV 19/09/2012
      MsgInfo("Verificar os parâmentos para autenticação com o servidor SMTP.","Atenção")
      Break   
   EndIf

   //120 segundos
   If Empty(nTimeout) //  RRV 19/09/2012
      nTimeout:= 120
   EndIf
   
   If Empty(nTryConnection) //  RRV 19/09/2012
      nTryConnection:= 1
   EndIf

   If EasyEntryPoint("EICEI100")
      ExecBlock("EICEI100",.F.,.F.,"ENVIAREMAIL")
   EndIf

    if !lEnvioPadrao
        lRet := lNewRet
    EndIf

   If lEnvioPadrao .And. MsgYesNo("Deseja enviar o arquivo '" + AllTrim(Upper((cWork)->EWZ_ARQUIV ))+ "' ?","Atenção")
      // Objeto para tratamento com conexao SMTP
      oServer := EasyServerSMTP():New(cSmtpServer,cSmtpPort,cAccount,cPassword,lAutentica,nTryConnection,nTimeout,cUserAuth,cPswAuth)
      If oServer:ConectarSMTP()
         If !lAutentica .Or. oServer:AuthSMTP()// RRV - 20/09/2012 - Verifica se o usuário possui server de e-mail com autenticação
            // Objeto para tratamento do email de envio
            oMessage := EasyMessageSMTP():New(,(cWork)->EWZ_EMAIL)
            oMessage:SetObjServer(oServer)
            
            //*FSY - 23/09/2013 - Ajuste para preencher assunto e o texto do e-mail automatimente.
            If cServico == ENV_DI .And. FieldPos("EWZ_HAWB") > 0
               oMessage:cAssunto   += AllTrim("Envio de processo ao despachante. Processo: "+AllTrim(Upper((cWork)->EWZ_HAWB)) ) //"Envio de processo ao despachante. Processo: "
               oMessage:cTextoMail += "O arquivo anexo contém informações referente envio do processo "+AllTrim(Upper((cWork)->EWZ_HAWB))+" ao despachante "+AllTrim(Upper((cWork)->EWZ_NOMEDE)) // "O arquivo anexo contém informações referente envio do processo " # " ao despachante "
            Elseif cServico == ENV_PO .And. FieldPos("EWZ_PO_NUM") > 0
               oMessage:cAssunto   += AllTrim("Envio de processo ao despachante. Processo: "+AllTrim(Upper((cWork)->EWZ_PO_NUM)) )// "Envio de processo ao despachante. Processo: "
               oMessage:cTextoMail += "O arquivo anexo contém informações referente envio do processo "+AllTrim(Upper((cWork)->EWZ_PO_NUM))+" ao despachante "+AllTrim(Upper((cWork)->EWZ_NOMEDE)) // "O arquivo anexo contém informações referente envio do processo " # " ao despachante "
            Endif   
            oMessage:cTextoMail += Chr(13)+Chr(10)+"Arquivo: "+AllTrim(Upper((cWork)->EWZ_ARQUIV ))+" Enviado em: "+DTOC(dDataBase)+"  "+Time()
            //*FSY - 23/09/2013
            
            IF(EasyEntryPoint("EICEI100"),ExecBlock("EICEI100",.F.,.F.,"ADICIONA_ASSUNTO"),)
            
            If File(Self:cDirGerados+(cWork)->EWZ_ARQUIV)

               // Anexando o arquivo ao email
               If oMessage:SetAnexo(Self:cDirGerados+(cWork)->EWZ_ARQUIV)

                  // View para informações do email
                  If !oMessage:ViewMail()
                     MsgInfo("Email não enviado." + If(!Empty(oMessage:cErro), ENTER + oMessage:cErro, ""),"Atenção")
                  Else
                     MsgInfo("Email enviado com sucesso.","Atenção")
                     lRet := .T.
                  EndIf
               Else
                  MsgInfo("Erro ao anexar o arquivo." + ENTER + oMessage:cErro,"Atenção")
               EndIf
            Else
               MsgInfo("Arquivo não encontrado.","Atenção")
            EndIf
         Else
            MsgInfo("Erro na autenticação." + ENTER + oServer:cErro,"Atenção") // RRV - 20/09/2012 - Retorna o erro ao usuário
         EndIf

         If !oServer:DesconecSMTP()
            MsgInfo("Erro ao desconectar do servidor de envio de e-mail." + ENTER + oServer:cErro,"Atenção")
         EndIf
      Else
         MsgInfo("Erro ao conectar no SMTP." + ENTER + oServer:cErro,"Atenção")
      EndIf
   EndIf

   // Efetua a copiar do arquivo do diretorio gerado para o diretorio enviado, e a gravação da tabela de controle
   If lRet .And. CopiaArq(Self:cDirGerados+(cWork)->EWZ_ARQUIV,Self:cDirEnviados+(cWork)->EWZ_ARQUIV,.T.)
      aDesp := {(cWork)->EWZ_CODDES, (cWork)->EWZ_NOMEDE ,If(lEnvioPadrao, oMessage:oMessage:cTo, cToNew)}
      Self:GravaEWZ((cWork)->EWZ_ARQUIV, cServico, ENVIADOS,aDesp)
   EndIf

End Sequence

Return lRet

Method ReceberArq(cWork,cServico) Class EICIDESPAC
Local lRet      := .F.
Local nInc      := 0
Local cDir      := ""
Local cFileDtHr := ""
Local cFileOK   := ""
Local cArqWebApp    := ""
Local cDrive, cNome, cExt := ""
Local lIsWebApp := GetRemoteType() == 5
//Local cStatus   := ""
Local aDesp     := {}
Local aFilesIt  := {}
Local cMsg
Begin Sequence 

   Do Case
      Case cServico == REC_NUMERARIO 
         cDir := Self:cDirNumerario
      Case cServico == REC_DESPESAS 
         cDir := Self:cDirDespesas
      Case cServico == REC_NF 
         cDir := Self:cDirNF  
   End Case
      
   If !lIsWebApp
      If Empty(cDir)
         MsgInfo(STR0002,STR0001) //"Defina um diretorio local para importação de arquivos do serviço." ## "Atenção"
         Break
      EndIf
      
      // Guardando todos os arquivos com extensao .TXT do diretorio definido pelo usuario para recebimento
      aFiles := Directory(cDir + "*.txt")
      If Empty(aFiles)
         MsgInfo(STR0003,STR0001) //"Não existe arquivos para ser recebidos no diretorio local." ## "Atenção"
         Break
      Endif
   Else      
      cArqWebApp := cGetFile("",STR0004, 0, cArqWebApp,,GETF_LOCALHARD, .F.) //"Diretório local para importação de arquivos do despachante"  
      If AT(".TXT",UPPER(cArqWebApp)) > 0
         SplitPath( cArqWebApp, @cDrive, @cDir, @cNome, @cExt ) 
         aFiles   := {}   
         aFilesIt  := {}
         aAdd(aFilesIt, cNome+cExt) 
         aAdd(aFiles, aFilesIt)          
      Else
         MsgInfo(STR0005) //"O formato do arquivo escolhido não é permitido. Escolha arquivo de formato txt"
         Break
      Endif   
   Endif

   For nInc := 1 To Len(aFiles) 
      If !lIsWebApp     
         // Guarda o caminho completo
         cFileRec := cDir + AllTrim(aFiles[nInc][1])
      Else
         cFileRec := cDrive + cDir + AllTrim(aFiles[nInc][1])
      EndIf
      If Upper(Self:cDirRecebidos) $ Upper(cFileRec)      // GFP - 12/04/2013
         MsgInfo(STR0006 + ENTER +; //"O diretório informado em 'Configurações' não é válido."
                 STR0007,STR0001) //"Informe um diretório local para importação de arquivos do serviço."## "Atenção"
         Break
      EndIf

      // Guardando somente o nome do arquivo
      Self:cFile := aFiles[nInc][1]

      //MFR 30/09/2021 OSSME-6228
      If Len(Self:cFile) > AvSx3("EWZ_ARQUIV", AV_TAMANHO)
         cMsg:= StrTran(STR0020,'####',Alltrim(Str(Len(Self:cFile)))) 
         cMsg:= StrTran(cMSg,'$$$$', Alltrim(Str(AvSx3("EWZ_ARQUIV", AV_TAMANHO)))) 
         EasyHelp(cMsg, STR0022, STR0021) //O tamanho ( ####) do nome do arquivo  excede o tamanho ( $$$$) do campo EWZ_ARQUIV. Altere o nome do arquivo para menor ou altere o tamanho do campo EWZ_ARQUIV para maior pelo configurador"
         Break
      EndIf         
      // Verificando se o arquivo ja foi recebido
      EWZ->(DbSetOrder(2))
      If EWZ->(DbSeek(xFilial("EWZ")+AvKey(cServico,"EWZ_SERVIC")+AvKey(Self:cFile,"EWZ_ARQUIV")))
         MsgInfo(STR0008 + AllTrim(Self:cFile) + STR0009,STR0001) //"O arquivo " # "Atenção" 
         Break
      EndIf

      // Salvando do local para o servidor
      If !CpyT2S(cFileRec, Self:cDirRecebidos, .T.)
         MsgInfo(StrTran(STR0010, "###", Self:cDirRecebidos), STR0001) //"Erro ao copiar o arquivo '###' para o diretório. Não será possível prosseguir." ### "Atenção"
         Break
      EndIf

      
      //Adicionando ao nome do arquivo a data e a hora, sendo chave unica //RRV - 04/10/2012 - Ajuste para gerar com extensão minuscula.
      cFileDtHr := SubStr(Self:cFile,1,At(".",Self:cFile)-1) + "_" + DToS(dDataBase) + "_" + StrTran(Time(),":","") + ".txt"      
      If !(FRename(Self:cDirRecebidos+Self:cFile, Self:cDirRecebidos + cFileDtHr) == 0)
         MsgInfo(STR0011+AllTrim(Self:cFile)+STR0012 + AllTrim(cFileDtHr) + ".") //"Não foi possível renomear o arquivo " + "para"
      EndIf
      
      // Get dos dados do despachante, somente para o serviço numerario e despesas
      If cServico == REC_NUMERARIO .Or. cServico == REC_DESPESAS
         aDesp := GetDespachante(cServico,Self:cDirRecebidos + cFileDtHr)
         If Empty(aDesp)
            Break
         EndIf
      EndIf

      If !lIsWebApp
         //Renomeando a extensao do arquivo local
         cFileOK := Left(cFileRec, Len(cFileRec) - 4) + ".OK"
         If !(FRename(cFileRec, cFileOK) == 0)
            MsgInfo(STR0013+AllTrim(cFileRec)+STR0012 + AllTrim(cFileOK) + ".")
         EndIf
      Else
         FErase(cDrive + cDir + AllTrim(Self:cFile) ) //".txt"   
      EndIf

      // Gravando na tabela de controle da nova integração com despachante
      If !Self:GravaEWZ(cFileDtHr, cServico, RECEBIDOS, aDesp)
         Break
      EndIf

      lRet := .T.
   Next

End Sequence

Return lRet

Method ProcessarArq(cWork,cServico) Class EICIDESPAC

Local lRet     := .T.
Local nOpcao   := 0
Local aDesp    := {}
Local cDestino := ""
Local cStatus  := ""
Local cFileOld := ""
Private cFileEICEI100 := ""  // Variavel para guardar o nome do txt da nova integração para ser tratada na função IN100Integ()
Private cStatusEI100  := Nil // Variavel para verificar o status (aceito ou rejeitado) do arquivo na função IN100Integ()
Private lPrvEI100     := .F. // Variavel para verificar se é .T. - para integração ou .F. - para previa na função IN100Integ()

Begin Sequence

   Do Case
      Case cServico == REC_NUMERARIO .Or. cServico == REC_DESPESAS
         aDesp  := {(cWork)->EWZ_CODDES,(cWork)->EWZ_NOMEDE,(cWork)->EWZ_EMAIL}
         nOpcao := 10
         If cServico == REC_NUMERARIO
            nOpcao := 13
         EndIf
      Case cServico == REC_NF
         aDesp  := {(cWork)->EWZ_CODDES,(cWork)->EWZ_NOMEDE,(cWork)->EWZ_EMAIL}
         nOpcao := 12                  
      Otherwise
         Return Nil
   EndCase

   If Empty((cWork)->EWZ_ARQUIV)
      MsgInfo(STR0014,STR0001) //"Selecione um registro para ser processado." ## "Atenção
      Break
   Else 
      cFileEICEI100 := (cWork)->EWZ_ARQUIV
   EndIf

   // Alterando a extensao do arquivo na variavel para que seja possivel mover o arquivo // RRV - 04/10/2012 - Ajuste para gerar arquivo com extensão minuscula.
   cFileOld := StrTran((cWork)->EWZ_ARQUIV, ".txt", ".old") //RRV - 27/09/2012
   EWZ->(DbSetOrder(2))
   If EWZ->(DbSeek(xFilial("EWZ") + AvKey(cServico,"EWZ_SERVIC") + AvKey(cFileOld,"EWZ_ARQUIV")))
      cStatus := If (EWZ->EWZ_STATUS == REJEITADOS, "rejeitado", "integrado")
      lRet := MsgYesNo(STR0015 + AllTrim(Upper((cWork)->EWZ_ARQUIV)) + STR0016 + AllTrim(cStatus)+ STR0017 + AllTrim(EWZ->EWZ_USERPR) + "'."+;
      ENTER + STR0018,STR0001) //"Deseja processar o arquivo novamente?" # "Atenção"
   EndIf

   If lRet

      EICIN100(nOpcao,,.T.)
      If Type("cStatusEI100") == "C"

         If lPrvEI100
            (cWork)->(DbGoTop())
            Break
         EndIf

         If cStatusEI100 == "T"
            cDestino := Self:cDirProcessados+cFileOld
            cStatus  := INTEGRADOS
         Else
            cDestino := Self:cDirRejeitados+cFileOld
            cStatus  := REJEITADOS
         EndIf

         If !CopiaArq(Self:cDirRecebidos+cFileOld,cDestino,.T.)
            Break
         EndIf
            
         // Gravando na tabela de controle da nova integração com despachante
         If !Self:GravaEWZ((cWork)->EWZ_ARQUIV, cServico, cStatus, aDesp)
            Break
         EndIf

      EndIf

   EndIf

End Sequence

Return nil

Method GravaEWZ(cArquivo, cServico, cStatus, aDesp) Class EICIDESPAC
Local i       := 0
Local lRet    := .T.
Local cSeek   := "" 
Local lNew    := .T.
Default aDesp := {}

Begin Sequence

   Do Case 

      // Servico de Numerario ou Despesas ou NF para status de recebidos
      Case cStatus == RECEBIDOS
         aCampos := Self:aCposRec
         If cServico == REC_NF
            aCampos := Self:aCposRecNF
         EndIf

      // Servico de Numerario ou Despesas ou NF para status de integrados ou rejeitados
      Case cStatus == INTEGRADOS .Or. cStatus == REJEITADOS
         aCampos  := Self:aCposPrc
         EWZ->(DbSetOrder(1))
         lNew := !EWZ->(DbSeek(xFilial("EWZ")+AvKey(cServico,"EWZ_SERVIC")+AvKey(RECEBIDOS,"EWZ_STATUS")+AvKey(cArquivo,"EWZ_ARQUIV")))
         cArquivo := StrTran(cArquivo, ".txt", ".old") //RRV - 27/09/2012
         If cServico == REC_NF
            aCampos := Self:aCposPrcNF
         End

      // Servico de PO ou DI para status de gerados
      Case cStatus == GERADOS
         aCampos := Self:aCposGer

      // Servico de PO ou DI para status de enviados
      Case cStatus == ENVIADOS
         aCampos := Self:aCposEnv
         EWZ->(DbSetOrder(1))
         lNew := !EWZ->(DbSeek(xFilial("EWZ")+AvKey(cServico,"EWZ_SERVIC")+AvKey(GERADOS,"EWZ_STATUS")+AvKey(cArquivo,"EWZ_ARQUIV")))
         If cServico == ENV_DI
            cProcesso := SW6->W6_HAWB
         ElseIf cServico == ENV_PO
            cProcesso := SW2->W2_PO_NUM 
         End If
         


   End Case

   If RecLock("EWZ", lNew)
      EWZ->EWZ_FILIAL    := xFilial("EWZ")
      EWZ->EWZ_SERVIC    := cServico
      EWZ->EWZ_STATUS    := cStatus
      EWZ->EWZ_ARQUIV    := cArquivo //RRV - 27/09/2012
      EWZ->&(aCampos[AScan(aCampos,"EWZ_USER")]) := cUserName
      EWZ->&(aCampos[AScan(aCampos,"EWZ_DATA")]) := dDataBase
      EWZ->&(aCampos[AScan(aCampos,"EWZ_HORA")]) := Time()
      If Len(aDesp) > 0
         EWZ->EWZ_CODDES    := aDesp[1]
         EWZ->EWZ_NOMEDE    := aDesp[2]
         EWZ->EWZ_EMAIL     := aDesp[3]
      EndIf
      //* FSY - 24/09/2013 - trecho para gravar o numero do PO e da DI
       //MFR 27/01/2021 OSSME-5499
      If lNew
         If cServico == ENV_DI .And. FieldPos("EWZ_HAWB") > 0  
            EWZ->EWZ_HAWB    := SW6->W6_HAWB
         ElseIf cServico == ENV_PO .And. FieldPos("EWZ_PO_NUM") > 0
            EWZ->EWZ_PO_NUM  := SW2->W2_PO_NUM 
         Endif
      EndIf
      //* FSY - 24/09/2013
      EWZ->(MsUnLock())
   EndIf

End Sequence

Return lRet

Method ViewCapa(oMsSelect) Class EICIDESPAC
Local cWork        := ""
Local cAreaH       := ""
Local cAreaD       := ""
Local cTipoArq     := ""
Local aPosUp       := {}
Local aPosDown     := {}
Local aDados       := {}
Local oSelectCapa
Local oSelectDet
Local oSelectRod
Local oDlg
Local bCancel      := {||oDlg:End()}
Local bOk          := {||oDlg:End()}

Private cFileNameH := ""
Private cFileNameD := ""

// Variaveis utilizadas nas funções: IN100NFE() , IN100DespDespachante(), IN100NU()
Private LEN_MSG     := 80
Private cPict13_3   := '@E 999,999,999.999'
Private cPict15_2   :='@E 999,999,999,999.99'
Private cPict17_2   :='@E 99,999,999,999,999.99'
Private cPict05_2   :='@E 99.99'
Private cPict11_4   :='@E 999,999.9999'
Private cPict15_4   :='@E 9,999,999,999.9999'
Private cPict15_8   :='@E 999,999.99999999'
Private cPict18_8   :='@E 999,999,999.99999999'
Private TB_Cols     := {}
Private TB_Col_D    := {}
Private TBRCols     := {}
Private bStatus     := {|x| If(x=Nil,('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK')="T",('Int_'+cFuncao)->&('N'+cFuncao+'INT_OK'):=x)}
Private bMessage    := &("{|p| Int_"+cFuncao+"->(if(p==NIL,"+'N'+cFuncao+'Msg'+","+'N'+cFuncao+'Msg'+" := p)) }")//FIELDWBLOCK('N'+cFuncao+'Msg'   ,SELECT('Int_'+cFuncao))
Private nTamPosicao := AVSX3("W3_POSICAO",3)
Private lMV_PIS_EIC := EasyGParam("MV_PIS_EIC",,.F.)
Private cTitNFE     := "Nota Fiscal de Entrada"
Private CAD_DI      := 'DI'
Private bTipo       := &("{|p| Int_"+cFuncao+"->(if(p==NIL,"+'N'+cFuncao+'TIPO'+","+'N'+cFuncao+'TIPO'+" := p)) }")//FIELDWBLOCK('N'+cFuncao+'TIPO'  ,SELECT('Int_'+cFuncao))
Private bStaIte     := {|| ('Int_'+cFuncao)->&('N'+cFuncao+'ITEM_OK')="T"}
Private _PictItem   := ALLTRIM(X3PICTURE("B1_COD")) 
Private cPictcom    := "@E 999,999,999.99999"

Begin Sequence

If ValType(oMsSelect) == "O"
   cWork  := oMsSelect:oBrowse:cAlias
   cArquivo := (cWork)->EWZ_ARQUIV

   If Empty(cArquivo)
      MsgInfo("Não há nenhum arquivo para visualização","Atenção")
      Break
   EndIf

   If Right(cWork,Len(RECEBIDOS)) == RECEBIDOS
      cDir := Self:cDirRecebidos
      cTipoArq := "recebido"  
   ElseIf Right(cWork,Len(INTEGRADOS)) == INTEGRADOS
      cDir := Self:cDirProcessados
      cTipoArq := "integrado"
   ElseIf Right(cWork,Len(REJEITADOS)) == REJEITADOS
      cDir := Self:cDirRejeitados
      cTipoArq := "rejeitado"
   EndIf 
   
   // Tratamento para criação da work como tambem preenchimento das mesmas.
   aDados := SetDadosSrv(cWork,Self:cDirRoot + cDir + cArquivo)
   If Empty(aDados)
      Break
   EndIf

   cAreaH := aDados[1]
   cAreaD := aDados[2]

   DEFINE MSDIALOG oDlg TITLE "Visualização do arquivo " + cTipoArq FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      aPosUp      := PosDlgUp(oDlg)
      aPosDown    := PosDlgDown(oDlg)
      oSelectCapa := MsSelect():New( cAreaH ,,,TB_Cols ,,,aPosUp)
      oSelectDet  := MsSelect():New( cAreaD ,,,TB_Col_D,,,aPosDown)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

EndIf

End Sequence

If !Empty(cFileNameH) .Or. !Empty(cFileNameD)
   If Select(cAreaH) > 0
      //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
      (cAreaH)->(E_EraseArq(cFileNameH))
      FErase(cFileNameH + TEOrdBagExt())
   EndIf
   If Select(cAreaD) > 0
      //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
      (cAreaD)->(E_EraseArq(cFileNameD))
      FErase(cFileNameD + TEOrdBagExt())
   EndIf
EndIf

Return nil

Static Function GetDespachante(cServico, cArquivo)
Local aRet := {}
Local hFile      := 0
Local nTamArq    := 0
Local nPos       := 0
Local nCpo       := 0
Local cBuffer    := ""
Local cCodDesp   := ""
Local cNomeDesp  := ""
Local cEmailDesp := ""
Local cQuery     := ""
Local nOldArea   := SELECT()
Private aEstruDef := {}
Private lMV_GRCPNFE:= EasyGParam("MV_GRCPNFE",,.F.)

Begin Sequence

   // Abrindo o arquivo para buscar o código do despachante
   hFile:= FOpen(cArquivo, FO_READ)
   If hFile == -1
      MsgInfo(StrTran("O arquivo 'XXX' não pode ser aberto.","XXX", cArquivo))
      Break
   EndIf

   //Lê o tamanho do arquivo e retorna à posição inicial
   nTamArq := FSeek(hFile, 0, FS_END)
   FSeek(hFile, 0)
   If FRead(hFile, @cBuffer, nTamArq) <> nTamArq
      MsgInfo(StrTran("O arquivo 'XXX' não pode ser aberto.","XXX", cArquivo))
      Break
   EndIf

   FCLOSE(hFile)

   // Guardando o código do despachante de acordo com o arquivo recebido do despachante
   // Obs: o código do despachante se localiza na posição 37 do arquivo txt.
   nPos := 1
   If cServico == REC_NUMERARIO 
      In100DefEstru("NU")
      nCpo := aScan(aEstruDef,{|X| X[1] == "NNUDESP" })         
   ElseIf cServico == REC_DESPESAS
      In100DefEstru("DH")
      nCpo := aScan(aEstruDef,{|X| X[1] == "NDHDESP" })
   EndIf
   aEval(aEstruDef,{|X| nPos += X[3] },,nCpo-1)
      
   cCodDesp := SubStr(cBuffer,nPos,aEstruDef[nCpo][3])
   SY5->(DbSetOrder(1))
   ChkFile("SYU")
   If !Empty(cCodDesp) .And. SY5->(DbSeek(xFilial("SY5")+AvKey(cCodDesp,"Y5_COD")))
      cNomeDesp   := SY5->Y5_NOME
      cEmailDesp  := SY5->Y5_EMAIL
   ElseIf Len(SY5->Y5_COD) > aEstruDef[nCpo][3] .And. Len(SY5->Y5_COD) == Len(SYU->YU_EASY)

      If Select("REFDESPROC") > 0
         REFDESPROC->(DbCloseArea())
      EndIf      
      cQuery := "SELECT * FROM "+RetSQLName("SY5")+" SY5"
      cQuery += " INNER JOIN "+RetSQLName("SYU")+" SYU"
      cQuery += " ON SY5.Y5_FILIAL = SYU.YU_FILIAL"
      cQuery += " AND SY5.Y5_COD = SYU.YU_EASY"
      cQuery += " AND SYU.YU_GIP_1 = '"+cCodDesp+"'"
      cQuery += " AND SYU.YU_TIP_CAD = '5'" //LRS - 01/10/2017
      cQuery += " AND SY5.D_E_L_E_T_ = ' '"
      cQuery += " AND SYU.D_E_L_E_T_ = ' '" 
      
      EasyWkQuery(cQuery,"REFDESPROC",,,)
      
      If REFDESPROC->(EasyRecCount()) == 0
         MsgInfo("Não foi encontrado o código do despachante na relação DE/PARA."+CHR(13)+CHR(10)+;
                 "Verifique as informações na tabela e também o tamanho dos campos relacionados!","Atenção")
         Break        
      ElseIf REFDESPROC->(EasyRecCount()) > 1
         MsgInfo("Foi encontrada mais de uma referência para este despachante "+CHR(13)+CHR(10)+;
                 "na tabela DE/PARA. Ajuste a referência na tabela para prosseguir!","Atenção")
         Break
      Else
         cCodDesp    := REFDESPROC->Y5_COD
         cNomeDesp   := REFDESPROC->Y5_NOME
         cEmailDesp  := REFDESPROC->Y5_EMAIL      
      EndIf
      REFDESPROC->(DBCloseArea())
      DBSELECTAREA(nOldArea)  
   Else
      MsgInfo("Não foi encontrado o código do despachante.","Atenção")
      Break
   EndIf
      
   aRet := {cCodDesp, cNomeDesp, cEmailDesp}

End Sequence

Return aClone(aRet)

Static Function SetDadosSrv(cWork,cArquivo)
Local aEstrutH    := {}
Local aEstrutD    := {}
Local aDados      := {}
Local cNumerario  := ""
Local cDespesas   := ""
Local cNF         := ""
Local cAreaH      := ""
Local cAreaD      := ""
Local nDel        := 0
Private aEstruDef := {}
Private lMV_GRCPNFE:= EasyGParam("MV_GRCPNFE",,.F.)

Begin Sequence

   cNumerario   := SubStr(cWork,At(REC_NUMERARIO,cWork),Len(REC_NUMERARIO))
   cDespesas    := SubStr(cWork,At(REC_DESPESAS,cWork),Len(REC_DESPESAS))
   cNF          := SubStr(cWork,At(REC_NF,cWork),Len(REC_NF))
 
   If !File(cArquivo)
      MsgInfo("Arquivo não encontrado.","Atenção")
      Break
   EndIf

   // Renomeando arquivo processados (integrados ou rejeitados) //RRV - 04/10/2012 - Ajuste para geração do arquivo com extensão minuscula.
   cFile := AltExtensao(cArquivo,".old",".txt")
   If Empty(cFile)
      Break
   EndIf
   DBSelectArea("EWZ")

   Do Case
      Case cNumerario == REC_NUMERARIO

         //In100DefEstru("NG") // Arquivo GERAL do Recebimento de numerário
         In100DefEstru("NU") // Arquivo do Recebimento de numerário
         aEstrutH  := aClone(aEstruDef)
         aEstruDef := {}
         In100DefEstru("DN") // Arquivo de Detalhes do Recebimento de numerário
         aEstrutD  := aClone(aEstruDef)
         aEstruDef := {}

         cAreaH := "Int_NU"
         cAreaD := "Int_DN"

         If Select(cAreaH) > 0
            Int_NU->(DBCloseArea())
         EndIf

         cFileNameH  := E_CriaTrab(,aEstrutH,cAreaH)   
         Append From (cFile) SDF For NNUTIPOREG == "NU"

         //Carrega os vetores TB_COLW e TB_COL_D
         IN100NU()

         If Empty(TB_Cols) .And. Empty(TB_Col_D)
            aDados       := {}
            Break
         EndIf

         If Select(cAreaD) > 0
            Int_DN->(DbCloseArea())
         EndIf
         cFileNameD := E_CriaTrab(,aEstrutD,cAreaD)   
         Append From (cFile) SDF For NDNTIPO == "DN"

         aAdd(aDados,cAreaH)
         aAdd(aDados,cAreaD)

      Case cDespesas == REC_DESPESAS

         //In100DefEstru("DE") // Arquivo de Despesas do Despachante.
         In100DefEstru("DH") // Arquivo de Despesas do Despachante 2.
         aEstrutH  := aClone(aEstruDef)
         aEstruDef := {}

         In100DefEstru("DD") // Arquivo de Despesas do Despachante - 4
         aEstrutD := aClone(aEstruDef)
         aEstruDef := {}

         cAreaH := "Int_DspHe"
         cAreaD := "Int_DspDe"

         If Select(cAreaH) > 0
            Int_DspHe->(DBCloseArea())
         EndIf

         cFileNameH  := E_CriaTrab(,aEstrutH,cAreaH)   
         Append From (cFile) SDF For NDHTIPOREG == "DI"

         If Select(cAreaD) > 0
            Int_DspDe->(DbCloseArea())
         EndIf
         cFileNameD := E_CriaTrab(,aEstrutD,cAreaD)   
         Append From (cFile) SDF For NDDTIPOREG == "DE"

         //Carrega os vetores TB_COLW e TB_COL_D
         IN100DespDespachante()

         If Empty(TB_Cols) .And. Empty(TB_Col_D)
            aDados       := {}
            Break
         EndIf

         aAdd(aDados,cAreaH)
         aAdd(aDados,cAreaD)

      Case cNF == REC_NF

         //In100DefEstru("FG") // Arquivo GERAL da Nota
         In100DefEstru("FE") // Arquivo de Nota
         aEstrutH  := aClone(aEstruDef)
         aEstruDef := {}
         In100DefEstru("FD") // Arquivo de Detalhes da Nota
         aEstrutD  := aClone(aEstruDef)
         aEstruDef := {}
         
         cAreaH := "Int_FE"
         cAreaD := "Int_FD"

         If Select(cAreaH) > 0
            Int_FE->(DBCloseArea())
         EndIf

         cFileNameH  := E_CriaTrab(,aEstrutH,cAreaH)   
         Append From (cFile) SDF For NFETIPO == "1"

         //Carrega os vetores TB_COLW e TB_COL_D
         IN100NFE()

         If Empty(TB_Cols) .And. Empty(TB_Col_D)
            aDados       := {}
            Break
         EndIf

         If Select(cAreaD) > 0
            Int_FD->(DbCloseArea())
         EndIf
         cFileNameD := E_CriaTrab(,aEstrutD,cAreaD)   
         Append From (cFile) SDF For NFDTIPO == "2"

         aAdd(aDados,cAreaH)
         aAdd(aDados,cAreaD)
      
      OtherWise
         aDados := {}
         Break  
   End Case

   // Renomeando arquivo processados (integrados ou rejeitados) //RRV - 04/10/2012 - Ajuste para geração do arquivo com extensão minuscula
   If Right(cWork,Len(INTEGRADOS)) == INTEGRADOS .Or. Right(cWork,Len(REJEITADOS)) == REJEITADOS
      If Empty(AltExtensao(cFile,".txt",".old"))
         Break
      EndIf
   EndIf

   If Right(cWork,Len(RECEBIDOS)) == RECEBIDOS

      // Retirando os campos de Status e Mensagem na visualização do arquivo recebido
      nPosStatus := aScan(TB_Cols,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0 
         If(aDel(TB_Cols,nPosStatus) != Nil   , nDel++,)
      EndIf
      nPosMsg    := aScan(TB_Cols,{|X| UPPER(X[3])=="MENSAGEM"})
      If nPosMsg <> 0 
         If(aDel(TB_Cols,nPosMsg) != Nil , nDel++,)
      EndIf
      aSize(TB_Cols,Len(TB_Cols)-nDel)

      nDel := 0
      nPosStatus := aScan(TB_Col_D,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0 
         If(aDel(TB_Col_D,nPosStatus) != Nil   , nDel++,)
      EndIf
      nPosMsg    := aScan(TB_Col_D,{|X| UPPER(X[3])=="MENSAGEM"})
      If nPosMsg <> 0 
         If(aDel(TB_Col_D,nPosMsg) != Nil , nDel++,)
      EndIf
      aSize(TB_Col_D,Len(TB_Col_D)-nDel)

   ElseIf Right(cWork,Len(INTEGRADOS)) == INTEGRADOS

      // Alterando os campos de Status para aceito na visualização do arquivo integrados
      nPosStatus := aScan(TB_Cols,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0 
         TB_Cols[aScan(TB_Cols,{|X| UPPER(X[3])=="STATUS"})] := {{|| "ACEITO"   }, "", "Status" } 
      EndIf
      
      nPosStatus := aScan(TB_Col_D,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0
         TB_Col_D[aScan(TB_Col_D,{|X| UPPER(X[3])=="STATUS"})] := {{|| "ACEITO" }, "", "Status" } 
      EndIf

   ElseIf Right(cWork,Len(REJEITADOS)) == REJEITADOS

      // Alterando os campos de Status para rejeitado na visualização do arquivo rejeitados
      nPosStatus := aScan(TB_Cols,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0       
         TB_Cols[aScan(TB_Cols,{|X| UPPER(X[3])=="STATUS"})] := { {|| "REJEITADO"  }, "", "Status" } 
      EndIf

      nPosStatus := aScan(TB_Col_D,{|X| UPPER(X[3])=="STATUS"})
      If nPosStatus <> 0       
         TB_Col_D[aScan(TB_Col_D,{|X| UPPER(X[3])=="STATUS"})] := {{|| "REJEITADO" }, "", "Status" } 
      EndIf

   EndIf   

End Sequence

Return aClone(aDados)

Static Function AltExtensao(cArquivo,cDeExt,cParaExt)
Local cFileDes := ""

cDeExt   := Lower(cDeExt)
cParaExt := Lower(cParaExt)

Begin Sequence
   // Renomeando arquivo processados (integrados ou rejeitados)
   If At(cDeExt,cArquivo) > 0
      cFileDes := StrTran(cArquivo,  cDeExt, cParaExt)
      If !(FRename(cArquivo,cFileDes) == 0)
         MsgInfo("Não foi possível renomear o arquivo " + cArquivo + " para " + cFileDes + ".")
         Break
      EndIf
   Else
      cFileDes := cArquivo
   EndIf
End Sequence

Return cFileDes

Static Function CopiaArq(cArqOri,cArqDest,lDelArqOri)
Local lRet := .F.
Default lDelArqOri := .F.
Begin Sequence

   If !File(cArqOri)
      MsgInfo(StrTran("O arquivo '###' não foi encontrado. Não será possível executar a rotina.", "###", cArqOri), "Aviso")
      Break
   EndIf
   
   __CopyFile(cArqOri, cArqDest)
   
   If !File(cArqDest)
      MsgInfo(StrTran("O arquivo '###' não foi encontrado. Não será possível executar a rotina.", "###", cArqDest), "Aviso")
      Break
   EndIf

   If lDelArqOri
      If FErase(cArqOri) <> 0
         MsgInfo(StrTran("O arquivo '###' não foi excluído.", "###", cArqOri), "Aviso")
         Break
      EndIf
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

/*
Funcao      : CriaDir
Parametros  : Objeto da classe AvUpdate01
Retorno     : Nenhum
Objetivos   : Criação dos diretórios para nova integração com despachante, caso não exista.
Autor       : Raphael Rodrigues Ventura
Data/Hora   : 27/09/2012 - 14:34:49
*/

Static Function CriaDir(o)
      
o:TableData('DIRETORIO',{cDirGerados},,.F.)
o:TableData('DIRETORIO',{cDirEnviados},,.F.)
o:TableData('DIRETORIO',{cDirRecebidos},,.F.)
o:TableData('DIRETORIO',{cDirRejeitados},,.F.)
o:TableData('DIRETORIO',{cDirProcessados},,.F.)

Return Nil
