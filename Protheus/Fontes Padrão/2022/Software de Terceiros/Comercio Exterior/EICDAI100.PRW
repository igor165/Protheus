#Include "AVERAGE.CH"
#Include "APWizard.CH"
#Include "EEC.cH"
#Include "Protheus.CH"
#Include "FILEIO.CH"
#Include "EICDAI100.CH"

//Integração
#Define DAI           "DAI"

//Serviços
#Define ENV_DI        "EDI"

//Status
#Define GERADOS       "GER"
#Define ENVIADOS	  "ENV"
#Define CANCELADOS	  "CAN"
#Define PROCESSADOS	  "PRO"

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : EICDAI100()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Chamada principal para o tratamento do arquivo XML da Declaração Amazonense de Importação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function EICDAI100()
Local lRet := .T.
Local aOrd := SaveOrd({"SW7","SW2","SYT"})
Private oEICDAI

Begin Sequence

   SW7->(dbSetOrder(1))
   SW2->(dbSetOrder(1))
   SYT->(dbSetOrder(1))

   SW7->(dbSeek(xFilial("SW7")+SW6->W6_HAWB))
   SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
   SYT->(dbSeek(xFilial("SYT")+SW2->W2_IMPORT))    
   
   If (!EICIsReady() .Or. !EICIsReady(,2))
      lRet := EICSPEDDAI()
   EndIf

   If lRet .And. Empty(SW6->W6_DI_NUM)
      MsgInfo( STR0001 + AllTrim(SW6->W6_HAWB) + STR0002,STR0003) // "Processo " +  + " não possui numero de DI.", "Atenção"
   ElseIf lRet 
      oEICDAI := EICDAI():New(STR0004 , STR0005 , STR0006 , STR0005, STR0006, STR0005, , , , ,SW6->W6_HAWB,SW6->W6_DI_NUM) // "Declaração Amazonense de Importação - DAI", "Serviços", "Ações"
      oEICDAI:SetServicos()
      oEICDAI:Show()
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return nil

/*-----------------------------------------------------------------------------------------------------------------------
Classe     : EICDAI
Objetivos  : Classe responsavel pelo tratamento do arquivo XML da Declaração Amazonense de Importação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Class EICDAI From AvObject

	Data 	cName            // Descrição do cabeçalho da Central de Integrações
    Data 	cSrvName         // Título do cabeçalho da Tree do Serviço
    Data 	cActName         // Título do cabeçalho da Tree do Ação
    Data 	cTreeSrvName     // Descrição do cabeçalho da Tree do Serviço
    Data 	cTreeAcName      // Descrição do cabeçalho da Tree do Ação
    Data 	cPanelName       // Titulo Principal
    Data 	bOk              // Code block do botão confirmar
    Data 	bCancel          // Code block do botão cancelar
    Data 	cIconSrv         // Ícone do Serviços
    Data 	cIconAction      // Ícone do Ações
    
	Data	aServices        // Vetor com todos os serviços disponiveis
    
	Data	aCposGer         // Vetor com os campos que serão apresentados todos os campos na pasta gerados
	Data	aCposEnv         // Vetor com os campos que serão apresentados todos os campos na pasta enviados
    Data    aCposCan         // Vetor com os campos que serão apresentados todos os campos na pasta cancelados
    Data    aCposPro         // Vetor com os campos que serão apresentados todos os campos na pasta processados

    Data    cDirGerados      // Diretório onde serão armazenados os arquivos com status gerados
    Data    cDirEnviados     // Diretório onde serão armazenados os arquivos com status enviados
    Data    cDirCancelados   // Diretório onde serão armazenados os arquivos com status cancelados
    Data    cDirProcessados  // Diretório onde serão armazenados os arquivos com status processados
    Data    cDirXML          // Diretório onde serão armazenados os arquivos gerados, o usuario informa o diretório
	Data    cDirRoot         // Diretório do RootPath
    Data    cDirStart        // Diretório do StartPath
    Data    cDirTemp         // Diretório Temp do usuario
    Data    cHawb            // Número do processo
    Data    cRetif           // Retificação - 1 / Não retificação - 0
    Data    cNumDI           // Número da DI
    Data    cHora            // Hora que o arquivo foi alterado o Status
    Data    dData            // Data que o arquivo foi alterado o Status
    Data    cInscricao       // Número de recibo gerado pelo site SEFAZ-Am
    Data    cXML             // String do arquivo XML
    Data    oXml             // Objeto do arquivo XML
    Data    cFileXML         // Nome do arquivo XML que será gerado
    Data    cVersao          // Versão do arquivo XML
    Data    aVersoes         // Quais versões o arquivo pode possuir
    Data    cId              // ID do arquivo XML
    
    Data    oUserParams      // Objeto responsável pela configuração do diretorio em que o usuario informou

	Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Constructor
	Method SetServicos()
  	Method SetDiretorios()   	
    Method Show()
    Method EditConfigs()
    Method GerarXML()
    Method EnviarDAI(cWork)
    Method CancelarDAI(cWork)
    Method ProcessarDAI(cWork)
    Method CreateXML()
    Method GravaEJD()
    Method ViewXML()
    Method EICSPED()
    Method EICXSDVersao()

End Class

Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction, cHawb, cNumDI) Class EICDAI

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
   Self:oUserParams     := EASYUSERCFG():New("EICDAI")
   Self:cHawb           := AvKey(cHawb,"EJD_CHAVE")
   Self:cNumDI          := cNumDI
   Self:cHora           := ""
   Self:dData           := cToD("")
   Self:cXML            := ""
   Self:cFileXML        := ""
   Self:cRetif          := "0"
   Self:cInscricao      := ""
   Self:oXml            := Nil
   Self:cVersao         := "" // MV_DIEVERS 
   Self:cId             := ""
   Self:aServices 		:= {}
   Self:aVersoes        := {"2.00","2.01"}

   //Campos para o arquivo gerado
   Self:aCposGer := {"EJD_ARQUIV", "EJD_CHAVE" , "EJD_DI_NUM", "EJD_RETIFI" , "EJD_USERGE", "EJD_DATAGE", "EJD_HORAGE" }

   //Campos para o arquivo enviado
   Self:aCposEnv := {"EJD_ARQUIV", "EJD_INSCRI" , "EJD_CHAVE" , "EJD_DI_NUM", "EJD_RETIFI" , "EJD_USEREN", "EJD_DATAEN", "EJD_HORAEN" }
   
   //Campos para o arquivo processado
   Self:aCposPro := {"EJD_ARQUIV", "EJD_INSCRI" , "EJD_CHAVE" , "EJD_DI_NUM", "EJD_RETIFI" , "EJD_USERPR", "EJD_DATAPR", "EJD_HORAPR" }
   
   //Campos para o arquivo cancelados   
   Self:aCposCan := {"EJD_ARQUIV", "EJD_INSCRI" , "EJD_CHAVE" , "EJD_DI_NUM", "EJD_USERCA", "EJD_DATACA", "EJD_HORACA" }

   Self:SetDiretorios()

Return Self

/*-----------------------------------------------------------------------------------------------------------------------
Método     : SetServicos()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel por configurar a criação da Central de Integração
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method SetServicos() Class EICDAI
Local oSrvENV_DI
Local aSrvENV_DI := {ENV_DI + GERADOS , ENV_DI + ENVIADOS}

   // Serviço de exportação DI
   oSrvENV_DI := EECSISSRV():New(STR0007 , "EJD" , STR0008 , ENV_DI , 1, "NORMAS", "NORMAS", , , "EJD_FILIAL + EJD_INTEG + EJD_SERVIC + EJD_ARQUIV + EJD_STATUS", "xFilial('EJD') + 'DAI' + EJD_SERVIC + EJD_ARQUIV + EJD_STATUS", "") // "Envio da DAI","Controle de integração - DAI"
   oSrvENV_DI:AddFolder(STR0009 , GERADOS     , DAI + ENV_DI + GERADOS     + Self:cHawb, Self:aCposGer,"Folder5","Folder6",,,"{|oMsSelect| oEICDAI:ViewXML(oMsSelect)}") // "Gerado"       
   oSrvENV_DI:AddFolder(STR0010 , ENVIADOS    , DAI + ENV_DI + ENVIADOS    + Self:cHawb, Self:aCposEnv,"Folder5","Folder6",,,"{|oMsSelect| oEICDAI:ViewXML(oMsSelect)}") // "Enviados"
   oSrvENV_DI:AddFolder(STR0011 , CANCELADOS  , DAI + ENV_DI + CANCELADOS  + Self:cHawb, Self:aCposCan,"Folder5","Folder6",,,"{|oMsSelect| oEICDAI:ViewXML(oMsSelect)}") // "Cancelados"   
   oSrvENV_DI:AddFolder(STR0012 , PROCESSADOS , DAI + ENV_DI + PROCESSADOS + Self:cHawb, Self:aCposPro,"Folder5","Folder6",,,"{|oMsSelect| oEICDAI:ViewXML(oMsSelect)}") // "Processados"
      
   oSrvENV_DI:AddAction(STR0013 , "GERDI"  , {ENV_DI + GERADOS}                                        , {|cWork| Self:GerarXML(cWork,"WK_"+ENV_DI + ENVIADOS,"WK_"+ENV_DI + CANCELADOS,"WK_"+ENV_DI + PROCESSADOS) } , GERADOS , "BMPINCLUIR", "BMPINCLUIR") // "Gerar XML"
   oSrvENV_DI:AddAction(STR0014 , "ENVDI"  , {ENV_DI + GERADOS}                                        , {|cWork| Self:EnviarDAI(cWork)}                         , GERADOS , "MSGFORWD"  , "MSGFORWD") // "Enviar"             
   oSrvENV_DI:AddAction(STR0015 , "CANDI"  , {ENV_DI + GERADOS,ENV_DI + ENVIADOS,ENV_DI + PROCESSADOS} , {|cWork| Self:CancelarDAI(cWork)}                       , GERADOS , "EXCLUIR"   , "EXCLUIR") // "Cancelar"           
   oSrvENV_DI:AddAction(STR0016 , "PRODI"  , {ENV_DI + ENVIADOS}                                       , {|cWork| Self:ProcessarDAI(cWork)}                      , GERADOS , "SDURECALL" , "SDURECALL") // "Processar"
   oSrvENV_DI:AddAction(STR0017 , "CONFIG" , {"RAIZ", ENV_DI}                                          , {|| Self:EditConfigs()}                                 , ""      , "NCO"       , "NCO") // "Config. Diretorio"
   oSrvENV_DI:AddAction(STR0018 , "CFGXSD" , {"RAIZ", ENV_DI}                                          , {|| Self:EICXSDVersao()}                                , ""      , "NCO"       , "NCO") // "Config. Versao XSD" 
   oSrvENV_DI:AddAction(STR0019 , "CFGSPED", {"RAIZ", ENV_DI}                                          , {|| Self:EICSPED()}                                     , ""      , "NCO"       , "NCO") // "Config. TSS"

   // Adicionando todos os serviços
   aAdd(Self:aServices, oSrvENV_DI)

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : Show()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel por apresentar a Central de Integração
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method Show() Class EICDAI
Local aServicos := {}
Local aAcoes  := {}
Local nInc

   For nInc := 1 To Len(Self:aServices)
      aAdd(aServicos, Self:aServices[nInc]:RetService())
      aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
   Next

   AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .F.)

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : SetDiretorios()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel configurar os diretorios responsaveis pelo armazenamento do arquivo conforme seu Status
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method SetDiretorios() Class EICDAI

SetDirAtu()

Self:cDirGerados  := "\comex\DAI\gerados\"
Self:cDirEnviados := "\comex\DAI\enviados\"
Self:cDirCancelados := "\comex\DAI\cancelados\"
Self:cDirProcessados := "\comex\DAI\processados\"
Self:cDirRoot     := GetSrvProfString("ROOTPATH","")
Self:cDirStart    := GetSrvProfString("STARTPATH","")
Self:cDirTemp     := GetTempPath()
Self:cDirXML      := Self:oUserParams:LoadParam("XMLDIRLOC", "","EICDAI")

Return Nil

//LRS - 28/02/2018

Function SetDirAtu(o)

If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {nModulo,{|o| SetDirUPD(o)}} }
   oUpd:Init(,.T.)
EndIF

Return Nil 

Static Function SetDirUPD(o)

o:TableStruct("DIRETORIO",{"CAMINHO_DIRETORIO"})
o:TableData("DIRETORIO",{"\comex\DAI\gerados"},.F.)
o:TableData("DIRETORIO",{"\comex\DAI\enviados"},.F.)
o:TableData("DIRETORIO",{"\comex\DAI\cancelados"},.F.)
o:TableData("DIRETORIO",{"\comex\DAI\processados"},.F.)


Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EditConfigs()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel configurar o diretorio que o usuario irá informar.
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EditConfigs() Class EICDAI
Local nLin        := 15, nCol := 12
Local lRet        := .F.
Local bOk         := {|| lRet := .T., oDlg:End() }
Local bCancel     := {|| oDlg:End() }
Local oDlg
Local cDirXML     := Self:cDirXML
Local cTitulo     := STR0020 + cUserName //  "Configurações para o usuário: "
Local bSetFileXML := {|| cDirXML := cGetFile("",STR0021, 0, cDirXML,,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) } // "Diretório local para importação de arquivos do XML"

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 445,785 OF oMainWnd PIXEL

    @ nLin, 6 To 55, 189 Label STR0022 Of oDlg Pixel // "Preferências" 
    nLin += 10
	@ nLin,nCol Say STR0021 Size 160,08 PIXEL OF oDlg // "Diretório local para importação de arquivos de XML"
    nLin += 10
	@ nLin,nCol MsGet cDirXML Size 150,08 PIXEL OF oDlg
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileXML) SIZE 10,10 PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      Self:cDirXML := cDirXML
      Self:oUserParams:SetParam("XMLDIRLOC", cDirXML , "EICDAI")
   EndIf

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : GerarXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela geração e validação do arquivo XML da Declaração Amazonense de Importação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method GerarXML(cWorkGe,cWorkEn,cWorkCa,cWorkPro) Class EICDAI
Local lRet := .F.

Private cPathDest:= "\SIGAADV\"
Private lEmail := .F.

Begin Sequence

   Self:cHora := Time()
   Self:dData := dDataBase
   Self:cFileXML := AllTrim(Self:cHawb)+"_"+AllTrim(Self:cNumDI)+"_"+DToS(Self:dData)+"_"+StrTran(Self:cHora, ":","_")+".xml"

   If Empty(Self:cDirXML)
      MsgInfo(STR0023,STR0003) // "Configure um diretorio para importação do arquivo XML.","Atenção"
      Break
   EndIf

   Self:cVersao :=  EasyGParam("MV_DAIVERS",,"")
   If Empty(Self:cVersao)
      MsgInfo(STR0024,STR0003) // "Configure a versão do XSD."
      Break  
   EndIf

   If !((cWorkGe)->(BOF()) .And. (cWorkGe)->(EOF()))
      MsgInfo(STR0025 + AllTrim(Self:cHawb) + STR0026 + AllTrim(Self:cNumDI)+"."+CHR(13)+CHR(10)+; // "Já possui arquivo gerado para esse processo: " + " com a DI: "
              STR0027 , STR0003) // "Realize o envio ou cancelamento do mesmo.","Atenção"
      Break
   EndIf

   If !((cWorkEn)->(BOF()) .And. (cWorkEn)->(EOF())) .Or. !((cWorkPro)->(BOF()) .And. (cWorkPro)->(EOF())) .Or. !((cWorkCa)->(BOF()) .And. (cWorkCa)->(EOF())) 
      If MsgYesNo(STR0028 + AllTrim(Self:cFileXML) + STR0029,STR0003) //  "O arquivo " + " é uma retificação?","Atenção"
         Self:cRetif := "1"
      EndIf
   EndIf

   Self:oXML := EXml():New()
   Self:cId := GeraId()
   DI500GeraTxt("1",@Self:oXML,Self:cRetif,Self:cVersao,Self:cId)
   Self:cXML := AssinatDigital("TOTVS",Self:oXML:GetXML(),1,Self:cVersao)

   If Empty(Self:cXML)
      MsgInfo(STR0030,STR0003) // "Arquivo não pode ser gerado.","Atenção"
      Break
   EndIf
   
   If !DAI100VldXML(Self:oXML,Self:cXML)
      Break
   EndIf

   If !Self:CreateXML()
      Break
   Else
      MsgInfo(STR0031,STR0003) // "Arquivo gerado com sucesso.","Atenção"
   EndIf

   Self:GravaEJD(GERADOS,{"EJD_USERGE", "EJD_DATAGE", "EJD_HORAGE"})
   
   lRet := .T.

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : CreateXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela criação do arquivo XML da Declaração Amazonense de Importação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method CreateXML() Class EICDAI
Local nHdl
Local lRet := .F.

Begin Sequence

   If File(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)
      FErase(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)
   EndIf

   nHdl := EasyCreateFile(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)

   If !(nHdl > 0)
      MsgInfo(STR0032+Self:cFileXML,STR0003) // "Não foi possivel criar o arquivo: ","Atenção"
      Break
   EndIf

   If FWrite(nHdl,Self:cXML,Len(Self:cXML)) <> Len(Self:cXML)
      MsgInfo(STR0032+Self:cFileXML,STR0003) // "Não foi possivel criar o arquivo: ","Atenção"
      Break
   EndIf
   
   fClose(nHdl) 

   lRet := CopiaArq(Self:cDirRoot+Self:cDirGerados+Self:cFileXML,Self:cDirXML+Self:cFileXML)
   
End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EnviarDAI()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela manutenção de envio do arquivo XML, porem o arquivo deverá ser importado manualmente no site.
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EnviarDAI(cWork) Class EICDAI
Local oDlg, oDlg1, oDlg2
Local nLin := 10
Local oBold := TFont():New(,,,, .T.)
Local lRet := .F., lEnv := .F.
Local cInscricao := Space(AvSX3("EJD_INSCRI",AV_TAMANHO))
Local bCancelXML := {|| lRet := .F. , oWizardDAI:oDlg:End() }
Local bValidXML	:= {|| If ( Empty(cInscricao),(MsgInfo(STR0033,STR0003),lEnv :=  .F.), lEnv := .T.) } // "É necessário informar o número do recibo para prosseguir.", "Atenção"

Private oWizardDAI

Begin Sequence

   If !(lRet :=DAI100ExiArq(cWork))
      Break
   EndIf
   
   DEFINE WIZARD oWizardDAI	TITLE  STR0034 ; // "Wizard de Envio de Declaração Amazonense de Importação"
							HEADER STR0035 ; // "Início"
							MESSAGE STR0036 ; // "Apresentação"
							TEXT STR0037 ; // "Esta rotina irá apresentar roteiro para envio de arquivos de Declaração Amazonense de Importação."
							PANEL NEXT {|| .T. };
							FINISH {|| .T.}
   
      oWizardDAI:oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
      
      CREATE PANEL oWizardDAI HEADER STR0038 	MESSAGE STR0039 ; // "Upload do arquivo XML","Passo 1:"
												PANEL;
												BACK	{|| .T. };
												NEXT	{|| .T. };
												FINISH	{|| .T. };
												EXEC	{|| .T. }
                                                oPanel := oWizardDAI:oMPanel[Len(oWizardDAI:oMPanel)]
                                                oPanel:cName := "SEND_FILE"

      @20, 10 Say STR0040 + ENTER +; // "No navegador, acesse o site da Secretaria de Estado da Fazenda e navegue até a página 'Enviar Arquivo  de DI em XML'."
                  STR0041 Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel // "Indique a localização do arquivo no campo destacado abaixo e importe:"
      @ 052, 18 BitMap ResName "AVG_ENVDAI1" Size 595, 141 NoBorder Of oPanel Pixel

      CREATE PANEL oWizardDAI HEADER STR0042	MESSAGE STR0043; // "Retorno da importação do XML","Passo 2:"
												PANEL;
												BACK    {|| lEnv := .F. , .T.};
												NEXT 	bValidXML;
												FINISH	bValidXML;
												EXEC {|| lEnv := .T., oGet2:SetFocus() }
												oPanel       := oWizardDAI:oMPanel[Len(oWizardDAI:oMPanel)]
												oPanel:cName := "RET_INSCRI"

         oGet2 := TelaInscri(oPanel, @cInscricao)

      CREATE PANEL oWizardDAI HEADER STR0042	MESSAGE STR0044; // "Retorno da importação do XML","Final:"
												PANEL;
												BACK    {|| .F. };
												NEXT 	{|| .T. };
												FINISH	{|| lRet := .T. }
												oPanel       := oWizardDAI:oMPanel[Len(oWizardDAI:oMPanel)]
												oPanel:cName := "FINAL"

      @ 052, 18 Say STR0045 Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel // "Envio finalizado."

   oWizardDAI:oCancel:bAction := bCancelXML
   oWizardDAI:oDlg:Owner():lEscClose:= .F.

   ACTIVATE WIZARD oWizardDAI CENTERED VALID {|| .T. }

   If lRet .And. lEnv
      Self:cFileXML := (cWork)->EJD_ARQUIV
      Self:cHora := Time()
      Self:dData := dDataBase
      Self:cInscricao := cInscricao
      
      If CopiaArq(Self:cDirRoot+Self:cDirGerados+Self:cFileXML,Self:cDirRoot+Self:cDirEnviados+Self:cFileXML,.T.)
         Self:GravaEJD(ENVIADOS,{"EJD_USEREN", "EJD_DATAEN", "EJD_HORAEN"})
      EndIf
   EndIf

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : ProcessarDAI()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela manutenção do Status processado do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method ProcessarDAI(cWork) Class EICDAI

Begin Sequence

   If !DAI100ExiArq(cWork)
      Break
   EndIf

   If MsgYesNo(STR0046 + AllTrim((cWork)->EJD_ARQUIV) + STR0047 + AllTrim((cWork)->EJD_INSCRI)+"?",STR0003 ) // "Deseja processar o arquivo " + " com numero de recibo " , "Atenção"
      Self:cFileXML := (cWork)->EJD_ARQUIV
      Self:cHora := Time()
      Self:dData := dDataBase
      Self:cInscricao := (cWork)->EJD_INSCRI
      If CopiaArq(Self:cDirRoot+Self:cDirEnviados+Self:cFileXML,Self:cDirRoot+Self:cDirProcessados+Self:cFileXML,.T.)
         Self:GravaEJD(PROCESSADOS,{"EJD_USERPR", "EJD_DATAPR", "EJD_HORAPR"})
      EndIf
   EndIf

End Sequence

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : CancelarDAI()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela manutenção do Status cancelado do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method CancelarDAI(cWork) Class EICDAI
Local lRet := .T.
Local cDir := ""

Begin Sequence

   If !(lRet := DAI100ExiArq(cWork))
      Break
   EndIf

   Self:cFileXML := (cWork)->EJD_ARQUIV
   Self:cHora := Time()
   Self:dData := dDataBase
   Self:cInscricao := (cWork)->EJD_INSCRI
   
   If MsgYesNo(STR0048+AllTrim(Self:cFileXML)+"?",STR0003) // "Deseja cancelar o arquivo: ","Atenção"
      If (cWork)->EJD_STATUS == GERADOS
         cDir := Self:cDirGerados
      ElseIf (cWork)->EJD_STATUS == ENVIADOS
         cDir := Self:cDirEnviados
      ElseIf (cWork)->EJD_STATUS == PROCESSADOS
         cDir := Self:cDirProcessados
      EndIf

      If CopiaArq(Self:cDirRoot+cDir+Self:cFileXML,Self:cDirRoot+Self:cDirCancelados+Self:cFileXML,.T.)
         Self:GravaEJD(CANCELADOS,{"EJD_USERCA", "EJD_DATACA", "EJD_HORACA"})
      EndIf
   EndIf

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EICSPED()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela configuração do Certificado Digital
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EICSPED() Class EICDAI

If PswAdmin(,,RetCodUsr()) == 0
   EICSPEDDAI()
Else
   Help( "", 1, "SEMPERM" )
EndIf

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EICXSDVersao()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela configuração da versão do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EICXSDVersao() Class EICDAI

Local nLin    := 15
Local nCol    := 12
Local lRet    := .F.
Local bOk     := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cVersao := Self:cVersao
Local cTitulo := STR0049 + cUserName// "Configurações para o usuário: "
//Local nOrdSW7 := SW7->(IndexOrd())
//Local nOrdSW2 := SW2->(IndexOrd())
//Local nOrdSYT := SYT->(IndexOrd())
//Local nRecSW7 := SW7->(Recno())
//Local nRecSW2 := SW2->(Recno())
//Local nRecSYT := SYT->(Recno())

   //SW7->(dbSetOrder(1))
   //SW2->(dbSetOrder(1))
   //SYT->(dbSetOrder(1))

   //SW7->(dbSeek(xFilial("SW7")+AvKey(Self:cHawb,"W7_HAWB")))
   //SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
   //SYT->(dbSeek(xFilial("SYT")+SW2->W2_IMPORT))    

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 445,785 OF oMainWnd PIXEL

    @ nLin, 6 To 55, 189 Label STR0050 Of oDlg Pixel // "Preferências"
    nLin += 10
	@ nLin,nCol Say STR0051 Size 160,08 PIXEL OF oDlg // "Versão dos arquivos de XML"
    nLin += 10
	@ nLin,nCol COMBOBOX cVersao ITEMS Self:aVersoes Size 150,08 PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If !Empty(cVersao) .And. lRet
      Self:cVersao := DAIXsdVersao("TOTVS",cVersao,1)
      If !Empty(Self:cVersao) .And. !PutMV("MV_DAIVERS",Self:cVersao) 
         MsgInfo(STR0052,STR0003) // "Versão não configurada com sucesso.","Atenção"
      EndIf
   EndIf

   //SW7->(DbSetOrder(nOrdSW7))
   //SW7->(DbGoTo(nRecSW7))
   //SW2->(DbSetOrder(nOrdSW2))
   //SW2->(DbGoTo(nRecSW2))
   //SYT->(DbSetOrder(nOrdSYT))
   //SYT->(DbGoTo(nRecSYT))

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : ViewXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela visualização do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method ViewXML(oMsSelect) Class EICDAI
Local cWork := ""
Local cArqXML := ""
Local cDir := ""
Local lRet := .F.

Begin Sequence
   
   If ValType(oMsSelect) == "U"
      Break
   EndIf
   
   cWork  := oMsSelect:oBrowse:cAlias
   cArqXML := (cWork)->EJD_ARQUIV

   If !(lRet := DAI100ExiArq(cWork))
      Break
   EndIf

   If (cWork)->EJD_STATUS == GERADOS
      cDir := Self:cDirGerados
   ElseIf (cWork)->EJD_STATUS == ENVIADOS
      cDir := Self:cDirEnviados
   ElseIf (cWork)->EJD_STATUS == CANCELADOS
      cDir := Self:cDirCancelados    
   ElseIf (cWork)->EJD_STATUS == PROCESSADOS
      cDir := Self:cDirProcessados
   EndIf

   If File(Self:cDirTemp+cArqXML)
      If FErase(Self:cDirTemp+cArqXML) == -1 
         MsgInfo(StrTran(STR0053 + '###' + STR0054 , "###", cArqXML), STR0003 ) // "Erro ao excluir o arquivo " + " do diretório temporário. Não será possível prosseguir." , "Atenção"
         Break
      EndIf
   EndIf

   //Copia do Servidor para o diretório temporário
   If !CpyS2T(cDir+cArqXML, Self:cDirTemp, .T.) 
      MsgInfo(StrTran(STR0055 + '###' + STR0056 , "###", cArqXML), STR0003 ) //"Erro ao copiar o arquivo " + " para o diretório temporário. Não será possível prosseguir." , "Atenção"
      Break
   EndIf 
   
   //Executa o browser para visualizar o XML
   If ShellExecute("open", Self:cDirTemp + RetFileName(cArqXML) + SubStr(cArqXML,Rat(".",cArqXML)), "", "", 1 ) <= 32
      MsgInfo(STR0057, STR0003 ) // "Erro na abertura do arquivo.", "Atenção"
   Else
      lRet := .T.
   EndIf
   
End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : GravaEJD()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela gravação na tabela EJD
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method GravaEJD(cStatus,aCampos) Class EICDAI
Local lSeek
Local cStIni := ""

If cStatus == CANCELADOS
   EJD->(DbSetOrder(2)) // EJD_FILIAL + EJD_CHAVE + EJD_ARQUIV
   lSeek := EJD->(DbSeek(xFilial("EJD")+DAI+AvKey(Self:cHawb,"EJD_CHAVE")+AvKey(Self:cFileXML,"EJD_ARQUIV")))
Else
   If cStatus == ENVIADOS .Or. cStatus == GERADOS
      cStIni := GERADOS
   ElseIf cStatus == PROCESSADOS
      cStIni := ENVIADOS
   EndIf
   EJD->(DbSetOrder(1)) // EJD_FILIAL + EJD_SERVIC + EJD_STATUS + EJD_CHAVE + EJD_ARQUIV
   lSeek := EJD->(DbSeek(xFilial("EJD")+DAI+AvKey(ENV_DI,"EJD_SERVIC")+AvKey(cStIni,"EJD_STATUS")+AvKey(Self:cHawb,"EJD_CHAVE")+AvKey(Self:cFileXML,"EJD_ARQUIV")))
EndIf

If RecLock("EJD",!lSeek)
   EJD->EJD_FILIAL    := xFilial("EJD")
   EJD->EJD_INTEG     := DAI
   EJD->EJD_SERVIC    := ENV_DI
   EJD->EJD_STATUS    := cStatus
   EJD->EJD_ARQUIV    := Self:cFileXML
   EJD->&(aCampos[1]) := cUserName
   EJD->&(aCampos[2]) := Self:dData
   EJD->&(aCampos[3]) := Self:cHora
   EJD->EJD_CHAVE     := Self:cHawb
   EJD->EJD_DI_NUM    := Self:cNumDI
   EJD->EJD_RETIFI    := Self:cRetif
   EJD->EJD_INSCRI    := Self:cInscricao 
   EJD->(MsUnLock())
EndIf

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Função     : TelaInscri()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel apresentação da tela para informar o numero de inscrição
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function TelaInscri(oDlg, cInscri)
Local oGet

      //@ 20, 10 Say "O número da inscrição é exibido após o envio correto do arquivo, conforme destacado na imagem abaixo:" Of oDlg Pixel
      @ 20, 10 Say STR0058 Of oDlg Pixel // "O número do recido é exibido após o envio correto do arquivo."
      @ 32, 10 Say STR0059 Of oDlg Pixel // "Copie este número no campo ao lado para relacioná-lo ao arquivo:"
      @ 31, 180 Get oGet Var cInscri Size 50,8 PICTURE "999999999999999" Of oDlg Pixel
      //@ 052, 18 BitMap ResName "AVG_ENVRE2" Size 599, 151 NoBorder Of oDlg Pixel

Return oGet

/*-----------------------------------------------------------------------------------------------------------------------
Função     : CopiaArq()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela copia do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function CopiaArq(cArqOri,cArqDest,lDelArqOri)
Local lRet := .F.
Default lDelArqOri := .F.

Begin Sequence

   If !File(cArqOri)
      MsgInfo(StrTran(STR0060 + '###' + STR0061, "###", cArqOri), STR0003) // "O arquivo " + " não foi encontrado. Não será possível executar a rotina.","Atenção"
      Break
   EndIf
   
   __CopyFile(cArqOri, cArqDest)
   
   If !File(cArqDest)
      MsgInfo(StrTran(STR0060 + '###' + STR0061, "###", cArqDest), STR0003) // "O arquivo " + " não foi encontrado. Não será possível executar a rotina.","Atenção"
      Break
   EndIf

   If lDelArqOri
      If FErase(cArqOri) <> 0
         MsgInfo(StrTran(STR0060 + '###' + STR0062 , "###", cArqOri), STR0003) // "O arquivo " + " não foi excluído.","Atenção"
         Break
      EndIf
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Função     : DAI100ExiArq()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela validação da existencia de arquivo nas pastas
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DAI100ExiArq(cWork)
Local lRet := .T.

Begin Sequence

   If (cWork)->(BOF()) .And. (cWork)->(EOF())
      MsgInfo(STR0063,STR0003) // "Não existe nenhum arquivo.","Atenção"
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Função     : DAI100VldXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela validação do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DAI100VldXML(oXML,cXML)
Local lRet := .T.
Local aXML := DAI100aXML()
Local i
Local nPosTag
Local cTags := STR0064 + CHR(13) + CHR(10) // "Não foram preenchidos as seguintes informações: "
Local cFimXML := ""
Local cMsg := ""
Local cInfo := ""

Begin Sequence

   For i := 1 To Len(aXML)
      nPosTag := At(aXML[i][1],cXML)
      If nPosTag > 0 
         cFimXML := SubStr(cXML,nPosTag + Len(aXML[i][1]) + 1 ,Len(cXML))
         cInfo := SubStr(cXML,nPosTag + Len(aXML[i][1]) + 1 ,At("<",cFimXML)-1)
      EndIf
   
      If Empty(cInfo)
         cTags += " - " + aXML[i][2] + CHR(13) + CHR(10)
         lRet := .F.
      EndIf
   Next

   cMsg += cTags
   
   If !lRet
      EecView(cMsg)
      Break
   EndIf

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Função     : DAI100aXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela estrutura do XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function DAI100aXML()
Local aXML := {}
   aAdd(aXML,{"tipoDIe"               ,STR0065 }) // "Tipo de DI"
   aAdd(aXML,{"nrDocumento"           ,STR0066 }) // "Número do Documento"
   aAdd(aXML,{"dtDocumento"           ,STR0067 }) // "Data do Documento"
   aAdd(aXML,{"numRetificacao"        ,STR0068 }) // "Retificação"
   aAdd(aXML,{"vlFob"                 ,STR0069 }) // "Valor FOB"
   aAdd(aXML,{"UFImportador"          ,STR0070 }) // "UF do Importador"
   aAdd(aXML,{"vlTaxaDolar"           ,STR0071 }) // "Taxa do dólar"
   aAdd(aXML,{"vlPesoLiquido"         ,STR0072 }) // "Peso Líquido em Kg"
   aAdd(aXML,{"cdRecintoAduaneiro"    ,STR0073 }) // "Código do Recinto Aduaneiro SEFAZ-AM"
   aAdd(aXML,{"cdPaisProcedencia"     ,STR0074 }) // "Código do País de Procedência"
   aAdd(aXML,{"qtdeAdicoes"           ,STR0075 }) // "Quantidade de Adições"
   aAdd(aXML,{"numAdicao"             ,STR0076 }) // "Número da Adição"
   aAdd(aXML,{"tipoImportador"        ,STR0077 }) // "Tipo do Importador"
   aAdd(aXML,{"nomeImportador"        ,STR0078 }) // "Nome do Importador"
   aAdd(aXML,{"nomeFornecedor"        ,STR0079 }) // "Fornecedor"
   aAdd(aXML,{"cdDestinacao"          ,STR0080 }) // "Destinação"
   aAdd(aXML,{"cdUtilizacao"          ,STR0081 }) // "Utilização"
   aAdd(aXML,{"cdTributacao"          ,STR0082 }) // "Cod. Tributação"
   aAdd(aXML,{"vlBcIcms"              ,"BC ICMS"})
   aAdd(aXML,{"vlCm"                  ,"CM"})
   aAdd(aXML,{"vlIcms"                ,"ICMS"})
   aAdd(aXML,{"numItem"               ,STR0083 }) // "Número do Item da Adição"
   aAdd(aXML,{"cdNcmItem"             ,STR0084 }) // "NCM do item da adição"
   aAdd(aXML,{"txDescricaoDestalhada" ,STR0085 }) // "Descrição Detalhada da Mercadoria"
   aAdd(aXML,{"qtdItem"               ,STR0086 }) // "Quantidade"
   aAdd(aXML,{"unidadeMedida"         ,STR0087 }) // "Unidade de Medida"
   aAdd(aXML,{"vlUnitario"            ,STR0088 }) // "Valor Unitário"
   aAdd(aXML,{"vlTotal"               ,STR0089 }) // "Valor Total"
   aAdd(aXML,{"tpVeiculo"             ,STR0090 }) // "Tipo de Veículo"
   aAdd(aXML,{"idVeiculo"             ,STR0091 }) // "Identificação do Veículo"
   aAdd(aXML,{"nrLacre"               ,STR0092 }) // "Número do Lacre"
Return aClone(aXML)

/*-----------------------------------------------------------------------------------------------------------------------
Função     : GeraId()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel geração do Id do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function GeraId()
Local cId := ""
Local cQuery := ""
Local nOrd := EJD->(IndexOrd())
Local nRec := EJD->(Recno())

   If !Empty(EJD->(DBFilter()))
      EJD->(DBCLEARFILTER())   
   EndIf

   cFil := xFilial("EJD") 
   cCond := "EJD->EJD_FILIAL == '" + cFil + "' .And. EJD->EJD_INTEG == '" + DAI + "'"
   EJD->(DBSetFilter({|| &cCond}, cCond )) 

   EJD->(DbSetOrder(3))
   EJD->(DbGoBOttom())
   cId := PadL(AllTrim(Str(Val(EJD->EJD_ID) + 1)),10,"0")

   If !Empty(EJD->(DBFilter()))
      EJD->(DBCLEARFILTER())   
   EndIf
   
   EJD->(DbSetOrder(nOrd))
   EJD->(DbGoTo(nRec))

Return cId