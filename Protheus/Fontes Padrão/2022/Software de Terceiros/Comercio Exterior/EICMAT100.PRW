#Include 'Protheus.ch'
#Include "AVERAGE.CH"
#Include "FWMVCDEF.CH"
#Include "APWizard.CH"
#Include "EEC.cH"
#Include "FILEIO.CH"
#Include "EICMAT100.CH"

//Integração
#Define MATRIZ        "MAT"

//Serviços
#Define ENV_MAT       "EMA"

//Status
#Define GERADOS       "GER"
#Define ENVIADOS	  "ENV"
#Define CANCELADOS	  "CAN"
#Define PROCESSADOS	  "PRO"

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : EICMAT100()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Chamada principal para rotina da Matriz de Tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function EICMAT100()
Local oBrwMAT
Private cImportador := SYT->YT_COD_IMP
Private aRotina := {}

//CRIAÇÃO DA MBROWSE
oBrwMAT := FWMBrowse():New() //Instanciando a Classe
oBrwMAT:SetAlias("EJB") //Informando o Alias
oBrwMAT:SetMenuDef("EICMAT100") //Nome do fonte do MenuDef
oBrwMAT:SetDescription(STR0001) // "Matriz de Tributação" //Descrição a ser apresentada no Browse

If !Empty(EJB->(DBFilter()))
   EJB->(DBCLEARFILTER())
EndIf

If !Empty(cImportador)
   oBrwMAT:SetFilterDefault( "EJB_FILIAL + EJB_IMPORT == xFilial('EJB')+AvKey(cImportador,'EJB_IMPORT')")
EndIf

oBrwMAT:Activate()

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*

Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"          OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICMAT100" OPERATION 2 ACCESS 0 // "Visualizar"         
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICMAT100" OPERATION 3 ACCESS 0 // "Incluir"            
ADD OPTION aRotina TITLE STR0005 ACTION "MAT100Altera()"    OPERATION 4 ACCESS 0 // "Alterar"            
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICMAT100" OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "EICINTMATR()"      OPERATION 6 ACCESS 0 // "Envio da Matriz"    

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJB := FWFormStruct(1,"EJB",,)
Local bPosValidacao := {|oModel| MAT100Valid('MANUT',oModel)} 
Local bGridValidacao := {|oModel| MAT100IMP(oModel)} 

oModel := MPFormModel():New("EICMAT100",bGridValidacao,bPosValidacao,/*bCommit*/,/*bCancel*/)

oStruEJB:AddField(AVSX3("EJB_IMPORT",AV_TITULO) , "" , "EJB_IMPORT" , AVSX3("EJB_IMPORT",AV_TIPO) , AVSX3("EJB_IMPORT",AV_TAMANHO) , AVSX3("EJB_IMPORT",AV_DECIMAL), ;
                  AVSX3("EJB_IMPORT",AV_VALID), AVSX3("EJB_IMPORT",AV_WHEN) , {} , Nil ,  , Nil , Nil , .F.)

oModel:AddFields("EJBMASTER", /*nOwner*/, oStruEJB)

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) // "Matriz de Tributação"
oModel:GetModel("EJBMASTER"):SetDescription(STR0001) // "Matriz de Tributação" //Título da Capa

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICMAT100")

//Cria a estrutura a ser usada na View
Local oStruEJB := FWFormStruct(2,"EJB",,)

Local oView

INCLUI := oModel:getOperation() == INCLUIR
ALTERA := oModel:getOperation() == ALTERAR
EXCLUI := oModel:getOperation() == EXCLUIR

//Cria o objeto de View  
oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJB", oStruEJB, "EJBMASTER")

//Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("SUPERIOR", 100/*,,,"IDFOLDER","IDSHEET01"*/)

//Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView("VIEW_EJB", "SUPERIOR")

//Liga a identificação do componente
oView:EnableTitleView("VIEW_EJB", STR0001, RGB(240,248,255)) // "Matriz de Tributação"

Return oView 

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : MAT100Valid()
Parametros : cOpc   - Opção de validação
             oModel - Objeto Model
Retorno    : lRet
Objetivos  : Validação da Matriz de tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function MAT100Valid(cOpc,oModel)
Local oModelEJB 
Local lRet := .T.
Local aOrd := SaveOrd({'EJC','EJB'})
Local cDest := ""
Local cCodTri := ""
Local cMsg := ""
Local aQuery := {}
Local cQuery := ""
Local i 

If !(ValType(oModel) == "O")
   oModel := FWModelActive()
EndIf
oModelEJB := oModel:GetModel("EJBMASTER")
cMsg := STR0008 + AllTrim(oModelEJB:GetValue("EJB_CODMAT")) + STR0009 + ENTER // "A Matriz " + " está vinculada aos itens: "

Do Case
   
   Case AllTrim(Upper(cOpc)) == 'MANUT'
      If ChkFile("SW1") .And. ChkFile("SW8") .And. SW1->(FieldPos("W1_CODMAT")) > 0 .And. SW8->(FieldPos("W8_CODMAT")) > 0 

         If oModel:getOperation() == EXCLUIR
            #IfDef TOP      

               aAdd(aQuery,{"SW1","W1_FILIAL = '" + xFilial("SW1") + "' and W1_CODMAT = '" + oModelEJB:GetValue("EJB_CODMAT") + "'" , " - SI."})
               aAdd(aQuery,{"SW8","W8_FILIAL = '" + xFilial("SW8") + "' and W8_CODMAT = '" + oModelEJB:GetValue("EJB_CODMAT") + "'" , " - Invoice."})               

               If Select("Work") > 0
                  Work->(DBCloseArea())
               EndIf
 
               For i := 2 To Len(aQuery)
                  cQuery := ChangeQuery("SELECT COUNT(*) AS QRY_TOTAL " +;
                                        "FROM " + RetSqlName(aQuery[i][1])+" " +;
                                        "WHERE D_E_L_E_T_ <> '*' AND " + aQuery[i][2];
                                        )
                  DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"Work",.T.,.T.)
                  If Work->QRY_TOTAL > 0
                     cMsg := cMsg + aQuery[i][3] + ENTER
                     lRet := .F.
                  EndIf
                  Work->(DBCLOSEAREA())
               Next

               If !lRet 
                  EasyHelp(cMsg,STR0010)
               EndIf

            #EndIf
         ElseIf oModel:getOperation() == INCLUIR
            EJB->(DbSetOrder(1))
            If EJB->(DbSeek(xFilial("EJB") + AvKey(SYT->YT_COD_IMP,"EJB_IMPORT")  + oModelEJB:GetValue("EJB_CODMAT")))
               EasyHelp(STR0008 + AllTrim(oModelEJB:GetValue("EJB_CODMAT")) + STR0011,STR0010) // "A Matriz " + " ja esta cadastrada no sistema."
               lRet := .F.
            EndIf
         EndIf
      
      EndIf
   
   Case AllTrim(Upper(cOpc)) == 'DATA'
      If !Empty(oModelEJB:GetValue("EJB_DTINI")) .And. !Empty(oModelEJB:GetValue("EJB_DTFIM")) .And. oModelEJB:GetValue("EJB_DTINI") > oModelEJB:GetValue("EJB_DTFIM")
         Help(,,"",,STR0012,1,0) // "Informe a data de Vigência do benefício maior que sua data inicial"
         lRet := .F.
      EndIf
   
   Case AllTrim(Upper(cOpc)) == 'CODTRIBUTA' .Or. AllTrim(Upper(cOpc)) == 'DESTINO'
      EJC->(DbSetOrder(1))
      If !Empty(cDest := oModelEJB:GetValue("EJB_DESTIN")) .And. !Empty(cCodTri := oModelEJB:GetValue("EJB_CODTRI")) .And. EJC->(DbSeek(xFilial('EJC')+cCodTri)) .And. !(EJC->EJC_DESTIN == cDest)
         Help(,,"",,STR0013 + EJC->EJC_DESTIN + ".",1,0) // "Código de Tributação SUFRAMA esta relacionado a destinação "
         lRet := .F.
      EndIf
   Case AllTrim(Upper(cOpc)) == 'CODMAT'
      If oModel:getOperation() == INCLUIR .Or. oModel:getOperation() == ALTERAR
         EJB->(DbSetOrder(1))
         If EJB->(DbSeek(xFilial("EJB") + AvKey(SYT->YT_COD_IMP,"EJB_IMPORT") + oModelEJB:GetValue("EJB_CODMAT")))
            Help(,,"",,STR0008 + AllTrim(oModelEJB:GetValue("EJB_CODMAT")) + STR0011,1,0)
            lRet := .F.
         EndIf
      EndIf
End Case

RestOrd(aOrd,.T.)

Return lRet 

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : MAT100VldSX5()
Parametros : cTabela - Tabela da SX5
             cAlias  - Alias da tabela
Retorno    : lRet
Objetivos  : Validação da Destinação e Industrialização do cadastro de Matriz de Tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function MAT100VldSX5(cTabela,cAlias)
Local lRet := .T.
Local aOrd := SaveOrd("SX5")
Local cChave := ""

If cAlias == "EJB" .And. cTabela == "ZT"
   cChave := M->EJB_DESTIN
ElseIf cAlias == "EJB" .And. cTabela == "ZU"
   cChave := M->EJB_UTILIZ
ElseIf cAlias == "EJC" .And. cTabela == "ZT"
   cChave := M->EJC_DESTIN
EndIf

SX5->(DbSetOrder(1))
If !Empty(cChave) .And. !(lRet := SX5->(DBSeek(xFilial("SX5") + cTabela + cChave)))
   EasyHelp(STR0014,STR0010) // "Não existe esta informação cadastrado."
EndIf

RestOrd(aOrd,.T.)

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : MAT100IMP()
Parametros : oModel - Objeto do Modelo
Retorno    : .T.
Objetivos  : Validação da Grid
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function MAT100IMP(oModel)
Local oModelEJB

If !(ValType(oModel) == "O")
   oModel := FWModelActive()
EndIf
oModelEJB := oModel:GetModel("EJBMASTER")

If Type("cImportador") == "C" .And. !Empty(cImportador) .And. (oModel:getOperation() == INCLUIR .Or. oModel:getOperation() == ALTERAR)
   oModelEJB:SetValue("EJB_IMPORT", cImportador )
EndIf  

Return .T.

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : MAT100Altera()
Parametros : Nil
Retorno    : Nil
Objetivos  : Chamada na alteração da Matriz de Tributação, para que seja fechada a tela.
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function MAT100Altera()
Local lOk := .F.
Local oModel := FWModelActive()

lOk := ( FWExecView(STR0015,'EICMAT100', MODEL_OPERATION_UPDATE,, { || .T. } ) == 0 ) // "Alteração Matriz de Tributação"
If lOk
   MsgInfo(STR0016,STR0010) // "Registro alterado com sucesso."
EndIf

Return nil

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : EICINTMATR()
Parametros : Nil
Retorno    : Nil
Objetivos  : Chamada da Integraçao da Matriz de Tributação do Importador
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function EICINTMATR()
Local lRet := .F.
Private oEICMATRIZ

   If Type("cImportador") == "C" .And. !Empty(cImportador)
      //NCF - 17/01/2012 - Permitir acesso a central quando TSS estiver configurado
      Do While !(lRet := EICIsReady() .AND. EICIsReady(,2))
         If !MsgYesNo("Não foi possível se conectar ao TSS com sucesso. Deseja configurar os parâmetros de conexão?") .Or. (lRet := EICSPEDDAI())
		    EXIT
		 EndIf
      EndDo
	
      If lRet 
         oEICMATRIZ := EICMATRIZ():New(STR0017, STR0018, STR0019, STR0018, STR0019, STR0018, , , , ,cImportador) // "Matriz de Tributação do Importador", "Serviços", "Ações"
         oEICMATRIZ:SetServicos()
         oEICMATRIZ:Show()
      EndIf

   EndIf

Return nil

/*-----------------------------------------------------------------------------------------------------------------------
Classe     : EICMATRIZ
Objetivos  : Classe responsavel pela Integração da Matriz de Tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Class EICMATRIZ From AvObject

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
    Data    cHora            // Hora que o arquivo foi alterado o Status
    Data    dData            // Data que o arquivo foi alterado o Status
    Data    cImportador      // Codigo do Importador
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
    Method EnviarMATRIZ(cWork)
    Method CancelarMATRIZ(cWork)
    Method ProcessarMATRIZ(cWork)
    Method CreateXML()
    Method GravaEJD()
    Method ViewXML()
    Method EICSPED()
    Method EICXSDVersao()
    Method LoadMatriz()

End Class

Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction,cImportador) Class EICMATRIZ

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
   Self:oUserParams     := EASYUSERCFG():New("EICMATRIZ")

   Self:cHora           := ""
   Self:dData           := cToD("")
   Self:cXML            := ""
   Self:cFileXML        := ""
   Self:cImportador     := AvKey(cImportador,"EJD_CHAVE")
   Self:aVersoes        := {"1.00"}
   Self:cVersao         := "" // If ( EasyGParam("MV_MTVERSA",.T.) .And. !Empty(EasyGParam("MV_MTVERSA",,"")) , EasyGParam("MV_MTVERSA") , "" )
   Self:aServices 		:= {}
   Self:cId             := ""
   
   //Campos para o arquivo gerado
   Self:aCposGer := {"EJD_ARQUIV", "EJD_USERGE", "EJD_DATAGE", "EJD_HORAGE" }

   //Campos para o arquivo enviado
   Self:aCposEnv := {"EJD_ARQUIV", "EJD_USEREN", "EJD_DATAEN", "EJD_HORAEN" }
   
   //Campos para o arquivo processado
   Self:aCposPro := {"EJD_ARQUIV", "EJD_USERPR", "EJD_DATAPR", "EJD_HORAPR" }
   
   //Campos para o arquivo cancelados   
   Self:aCposCan := {"EJD_ARQUIV", "EJD_USERCA", "EJD_DATACA", "EJD_HORACA" }

   Self:SetDiretorios()

Return Self

/*-----------------------------------------------------------------------------------------------------------------------
Método     : SetServicos()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel por configurar a Central de Integração
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method SetServicos() Class EICMATRIZ
Local oSrvENV_MAT
Local aSrvENV_MAT := {ENV_MAT + GERADOS , ENV_MAT + ENVIADOS}

   // Serviço de exportação DI
   oSrvENV_MAT := EECSISSRV():New(STR0007 , "EJD", STR0020 , ENV_MAT , 1, "NORMAS", "NORMAS", , , "EJD_FILIAL + EJD_INTEG + EJD_SERVIC + EJD_ARQUIV + EJD_STATUS", "xFilial('EJD') + 'MAT' + EJD_SERVIC + EJD_ARQUIV + EJD_STATUS", "") // "Envio da Matriz" , "Controle de integração - MATRIZ"
   oSrvENV_MAT:AddFolder(STR0021 , GERADOS     , MATRIZ + ENV_MAT + GERADOS     + Self:cImportador , Self:aCposGer,"Folder5","Folder6",,,"{|oMsSelect| oEICMATRIZ:ViewXML(oMsSelect)}")  // "Gerado"
   oSrvENV_MAT:AddFolder(STR0022 , ENVIADOS    , MATRIZ + ENV_MAT + ENVIADOS    + Self:cImportador , Self:aCposEnv,"Folder5","Folder6",,,"{|oMsSelect| oEICMATRIZ:ViewXML(oMsSelect)}")  // "Enviados"
   oSrvENV_MAT:AddFolder(STR0023 , CANCELADOS  , MATRIZ + ENV_MAT + CANCELADOS  + Self:cImportador , Self:aCposCan,"Folder5","Folder6",,,"{|oMsSelect| oEICMATRIZ:ViewXML(oMsSelect)}")  // "Cancelados"
   oSrvENV_MAT:AddFolder(STR0024 , PROCESSADOS , MATRIZ + ENV_MAT + PROCESSADOS + Self:cImportador , Self:aCposPro,"Folder5","Folder6",,,"{|oMsSelect| oEICMATRIZ:ViewXML(oMsSelect)}")  // "Processados"
   //NCF - 17/01/2012 - Exibir todas as ações   
   oSrvENV_MAT:AddAction(STR0025 , "GERDI"  , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|cWork, cID| cId := GetId(cId), Self:GerarXML(cWork,"WK_"+ENV_MAT + ENVIADOS,"WK_"+ENV_MAT + CANCELADOS,"WK_"+ENV_MAT + PROCESSADOS, cID) } , GERADOS , "BMPINCLUIR", "BMPINCLUIR") // "Gerar XML"
   oSrvENV_MAT:AddAction(STR0026 , "ENVDI"  , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|cWork, cID| cId := GetId(cId), Self:EnviarMATRIZ(cWork, cID)}                         , GERADOS , "MSGFORWD"  , "MSGFORWD") // "Enviar"
   oSrvENV_MAT:AddAction(STR0027 , "CANDI"  , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|cWork, cID| cId := GetId(cId), Self:CancelarMATRIZ(cWork, cID)}                       , GERADOS , "EXCLUIR"   , "EXCLUIR") // "Cancelar"
   oSrvENV_MAT:AddAction(STR0028 , "PRODI"  , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|cWork, cID| cId := GetId(cId), Self:ProcessarMATRIZ(cWork, cID)}                      , GERADOS , "SDURECALL" , "SDURECALL") // "Processar"
   oSrvENV_MAT:AddAction(STR0029 , "CONFIG" , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|| Self:EditConfigs()}                                    , ""      , "NCO"       , "NCO") // "Config. Diretorio"
   oSrvENV_MAT:AddAction(STR0030 , "CFGXSD" , {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|| Self:EICXSDVersao()}                                   , ""      , "NCO"       , "NCO") // "Config. Versao XSD"
   oSrvENV_MAT:AddAction(STR0031 , "CFGSPED", {"RAIZ", ENV_MAT, ENV_MAT + GERADOS, ENV_MAT + ENVIADOS, ENV_MAT + CANCELADOS, ENV_MAT + PROCESSADOS}, {|| Self:EICSPED()}                                        , ""      , "NCO"       , "NCO") // "Config. TSS"

   // Adicionando todos os serviços
   aAdd(Self:aServices, oSrvENV_MAT)

Return Nil

//NCF - 17/01/2013
//GetId(cId) - Ajusta o Id da pasta selecionada
Static Function GetId(cId)

	cId := Alltrim(StrTran(cId, "oS", ""))
	
	If cId <> "RAIZ"
		cId := Left(cId, 6)
	Else
		MsgInfo("Selecione uma pasta válida para execução da ação.", "Aviso")
		cId := ""
	EndIf

Return cId

/*-----------------------------------------------------------------------------------------------------------------------
Método     : Show()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel por apresentar a Central de Integração
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method Show() Class EICMATRIZ
Local aServicos := {}
Local aAcoes  := {}
Local nInc

   For nInc := 1 To Len(Self:aServices)
      aAdd(aServicos, Self:aServices[nInc]:RetService())
      aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
   Next
   //NCF - 17/01/2013
   AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .F.,Nil,Nil,.F.)

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : SetDiretorios()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel configuração dos diretorios para tratamento do arquivos
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method SetDiretorios() Class EICMATRIZ

   SetDirAtua() //LRS - 11/07/2018

   Self:cDirGerados  := "\comex\matriz\gerados\"
   Self:cDirEnviados := "\comex\matriz\enviados\"
   Self:cDirCancelados := "\comex\matriz\cancelados\"
   Self:cDirProcessados := "\comex\matriz\processados\"
   Self:cDirRoot     := GetSrvProfString("ROOTPATH","")
   Self:cDirStart    := GetSrvProfString("STARTPATH","")
   Self:cDirTemp     := GetTempPath()
   Self:cDirXML      := Self:oUserParams:LoadParam("XMLDIRLOC", "","EICMATRIZ")

Return Nil

Function SetDirAtua(o)

If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {nModulo,{|o| SetDirUPDT(o)}} }
   oUpd:Init(,.T.)
EndIF

Return Nil 

Static Function SetDirUPDT(o)

   o:TableStruct("DIRETORIO",{"CAMINHO_DIRETORIO"})
   o:TableData("DIRETORIO",{"\comex\matriz\gerados"},.F.)
   o:TableData("DIRETORIO",{"\comex\matriz\enviados"},.F.)
   o:TableData("DIRETORIO",{"\comex\matriz\cancelados"},.F.)
   o:TableData("DIRETORIO",{"\comex\matriz\processados"},.F.)

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EditConfigs()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel configuração do diretorio que o usuario ira informar
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EditConfigs() Class EICMATRIZ
Local nLin        := 15, nCol := 12
Local lRet        := .F.
Local bOk         := {|| lRet := .T., oDlg:End() }
Local bCancel     := {|| oDlg:End() }
Local oDlg
Local cDirXML     := Self:cDirXML
Local cTitulo     := STR0032 + cUserName // "Configurações para o usuário: " 
Local bSetFileXML := {|| cDirXML := cGetFile("",STR0033, 0, cDirXML,,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) } // "Diretório local para importação de arquivos do XML"

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 445,785 OF oMainWnd PIXEL

    @ nLin, 6 To 55, 189 Label STR0034 Of oDlg Pixel
    nLin += 10
	@ nLin,nCol Say STR0033 Size 160,08 PIXEL OF oDlg // "Diretório local para importação de arquivos de XML"
    nLin += 10
	@ nLin,nCol MsGet cDirXML Size 150,08 PIXEL OF oDlg
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileXML) SIZE 10,10 PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      Self:cDirXML := cDirXML
      Self:oUserParams:SetParam("XMLDIRLOC", cDirXML , "EICMATRIZ")
   EndIf

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : GerarXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela validação e tratamento do arquivo XML da Matriz de Tributação
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method GerarXML(cWorkGe,cWorkEn,cWorkCa,cWorkPro,cID) Class EICMATRIZ
Local lRet := .F.

Private cPathDest:= "\SIGAADV\"
Private lEmail := .F.

Begin Sequence
   //NCF - 17/01/2012
   If cID <> ENV_MAT + GERADOS
      MsgInfo("Opção inválida para a pasta selecionada", "Aviso")
      Break
   EndIf

   Self:cHora := Time()
   Self:dData := dDataBase
   Self:cFileXML := AllTrim(Self:cImportador)+"_"+DToS(Self:dData)+"_"+StrTran(Self:cHora, ":","_")+".xml"

   If Empty(Self:cDirXML)
      MsgInfo(STR0035,STR0010) // "Configure um diretorio para importação do arquivo XML."
      Break
   EndIf

   Self:cVersao :=  EasyGParam("MV_MTVERSA",,"")
   If Empty(Self:cVersao)
      MsgInfo(STR0036,STR0010) // "Configure a versão do XSD."
      Break  
   EndIf
   
   Self:cId  := GeraId()
   Self:oXML := Self:LoadMatriz(Self:cId) 
   Self:cXML := AssinatDigital("TOTVS",Self:oXML:GetXML(),2,Self:cVersao)
      
   If Empty(Self:cXML)
      MsgInfo(STR0037,STR0010) // "Arquivo não pode ser gerado."  
      Break
   EndIf
 
   If !Self:CreateXML()
      Break
   Else
      MsgInfo(STR0038,STR0010) // "Arquivo gerado com sucesso."
   EndIf

   Self:GravaEJD(GERADOS,{"EJD_USERGE", "EJD_DATAGE", "EJD_HORAGE"})
   
   lRet := .T.

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : CreateXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela criacao do arquivo XML da Matriz de Tributação
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method CreateXML() Class EICMATRIZ
Local nHdl
Local lRet := .F.

Begin Sequence

   If File(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)
      FErase(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)
   EndIf

   nHdl := EasyCreateFile(Self:cDirRoot+Self:cDirGerados+Self:cFileXML)

   If !(nHdl > 0)
      MsgInfo(STR0039+Self:cFileXML,STR0010) // "Não foi possivel criar o arquivo: "
      Break
   EndIf

   If FWrite(nHdl,Self:cXML,Len(Self:cXML)) <> Len(Self:cXML)
      MsgInfo(STR0039+Self:cFileXML,STR0010) // "Não foi possivel criar o arquivo: "
      Break
   EndIf
   
   fClose(nHdl) 

   lRet := CopiaArq(Self:cDirRoot+Self:cDirGerados+Self:cFileXML,Self:cDirXML+Self:cFileXML)
   
End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : EnviarMATRIZ()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel enviado do arquivo XML, porem tera que ser importado no site manualmente. Somente seria o tratamento
             do Status do arquivo
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method EnviarMATRIZ(cWork, cID) Class EICMATRIZ
Local lRet := .F.

Begin Sequence
   //NCF - 17/01/2013 
   If cID <> ENV_MAT + GERADOS
      MsgInfo("Opção inválida para a pasta selecionada", "Aviso")
      Break
   EndIf

   If !(lRet :=MAT100ExiArq(cWork))
      Break
   EndIf
   
   lRet := MsgYesNo(STR0040,STR0010) // "O arquivo foi importado com sucesso?"

   If lRet
      Self:cFileXML := (cWork)->EJD_ARQUIV
      Self:cHora := Time()
      Self:dData := dDataBase
      
      If CopiaArq(Self:cDirRoot+Self:cDirGerados+Self:cFileXML,Self:cDirRoot+Self:cDirEnviados+Self:cFileXML,.T.)
         Self:GravaEJD(ENVIADOS,{"EJD_USEREN", "EJD_DATAEN", "EJD_HORAEN"})
      EndIf
   EndIf

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Método     : ProcessarMATRIZ()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel processamento do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method ProcessarMATRIZ(cWork,cID) Class EICMATRIZ

Begin Sequence
   //NCF - 17/01/2013 
   If cID <> ENV_MAT + ENVIADOS
      MsgInfo("Opção inválida para a pasta selecionada", "Aviso") 
      Break
   EndIf

   If !MAT100ExiArq(cWork)
      Break
   EndIf

   If MsgYesNo(STR0041 + AllTrim((cWork)->EJD_ARQUIV) +"?",STR0010) // "Deseja processar o arquivo "
      Self:cFileXML := (cWork)->EJD_ARQUIV
      Self:cHora := Time()
      Self:dData := dDataBase

      If CopiaArq(Self:cDirRoot+Self:cDirEnviados+Self:cFileXML,Self:cDirRoot+Self:cDirProcessados+Self:cFileXML,.T.)
         Self:GravaEJD(PROCESSADOS,{"EJD_USERPR", "EJD_DATAPR", "EJD_HORAPR"})
      EndIf
   EndIf

End Sequence

Return Nil

/*-----------------------------------------------------------------------------------------------------------------------
Método     : CancelarMATRIZ()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel cancelamento do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method CancelarMATRIZ(cWork, cID) Class EICMATRIZ
Local lRet := .T.
Local cDir := ""

Begin Sequence
   //NCF - 17/01/2013 
   If !(cID $ ENV_MAT + GERADOS + "/" + ENV_MAT + ENVIADOS + "/" + ENV_MAT + PROCESSADOS)
      MsgInfo("Opção inválida para a pasta selecionada", "Aviso")
      Break
   EndIf

   If !(lRet := MAT100ExiArq(cWork))
      Break
   EndIf

   Self:cFileXML := (cWork)->EJD_ARQUIV
   Self:cHora := Time()
   Self:dData := dDataBase

   If MsgYesNo(STR0042 + AllTrim(Self:cFileXML)+"?",STR0010) // "Deseja cancelar o arquivo: "
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
Método     : LoadMatriz()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel criação do objeto da Matriz de Tributação
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Method LoadMatriz(cId) Class EICMATRIZ
Local oXml := EXml():New()
Local oEnviMatrizDIe := ENode():New()
Local oMatrizDIe := ENode():New()
Local oInfMatrizDIe := ENode():New()
Local oTagMatriz := ENode():New()
Local nOrdEJB := EJB->(IndexOrd())
Local nRecEJB := EJB->(Recno())
 
   oInfMatrizDIe:SetField(EAtt():New("versao",Self:cVersao))
   oInfMatrizDIe:SetField(EAtt():New("Id","MatrizDIe"+cId))

   oImportador := ENode():New()
   oImportador:SetField("tipoImportador","1")
   oImportador:SetField("cdImportador", SYT->YT_INSCR_E)
   oInfMatrizDIe:SetField("Importador",oImportador)  
   
   EJB->(DbSetOrder(1)) // EJB_FILIAL + EJB_IMPORT + EJB_CODMAT
   EJB->(DbSeek(xFilial('EJB')+AvKey(SYT->YT_COD_IMP,"EJB_IMPORT")))
   Do While EJB->(!Eof()) .And. EJB->EJB_FILIAL == xFilial('EJB') .And. EJB->EJB_IMPORT == SYT->YT_COD_IMP  

      If EJB->EJB_ATIVO == "1"
         oItemMatriz:= ENode():New()
         oItemMatriz:SetField("cdNcmProdFinal"        , EJB->EJB_NCM    )   
         oItemMatriz:SetField("cdSuframa"             , EJB->EJB_PRDSUF )
         oItemMatriz:SetField("cdDestinacao"          , EJB->EJB_DESTIN )
         oItemMatriz:SetField("cdUtilizacao"          , EJB->EJB_UTILIZ )
         oItemMatriz:SetField("cdTributacao"          , EJB->EJB_CODTRI )
         oItemMatriz:SetField("numDecreto"            , EJB->EJB_NUMDEC )
         oItemMatriz:SetField("tpDocumentoConcessivo" , EJB->EJB_TPDOC  ) 
         oItemMatriz:SetField("numDocumentoConcessivo", EJB->EJB_NUMDOC )
         oItemMatriz:SetField("dtInicioBeneficio"     , DTOS(EJB->EJB_DTINI)  ) 
         oItemMatriz:SetField("dtFimBeneficio"        , DTOS(EJB->EJB_DTFIM)  )
         oInfMatrizDIe:SetField("ItemMatriz",oItemMatriz) 
      EndIf

      EJB->(DbSkip())
   EndDo

   oTagMatriz:SetField("InfMatrizDIe",oInfMatrizDIe)
   //oTagMatriz:SetField("Signature","")
   oMatrizDIe:SetField("MatrizDIe",oTagMatriz)
   oMatrizDIe:SetField(EAtt():New("versao",Self:cVersao))
   oMatrizDIe:SetField(EAtt():New("xmlns","http://www.sefaz.am.gov.br/die"))
   oMatrizDIe:SetField(EAtt():New("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance"))
   oMatrizDIe:SetField(EAtt():New("xsi:schemaLocation","http://www.sefaz.am.gov.br/die enviMatrizDIe_v"+Self:cVersao+".xsd"))
   oEnviMatrizDIe:SetField("enviMatrizDIe",oMatrizDIe)

   oXml:AddRec(oEnviMatrizDIe)   

   EJB->(DbSetOrder(nOrdEJB))
   EJB->(DbGoTo(nRecEJB))

Return oXml

Method EICSPED() Class EICMATRIZ

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
Method EICXSDVersao() Class EICMATRIZ
Local nLin    := 15
Local nCol    := 12
Local lRet    := .F.
Local bOk     := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cVersao := Self:cVersao
Local cTitulo := STR0043 + cUserName // "Configurações para o usuário: "

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 445,785 OF oMainWnd PIXEL

    @ nLin, 6 To 55, 189 Label STR0044 Of oDlg Pixel // "Preferências"
    nLin += 10
	@ nLin,nCol Say STR0045 Size 160,08 PIXEL OF oDlg // "Versão dos arquivos de XML"
    nLin += 10
	@ nLin,nCol COMBOBOX cVersao ITEMS Self:aVersoes Size 150,08 PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If !Empty(cVersao) .And. lRet
      Self:cVersao := DAIXsdVersao("TOTVS",cVersao,2)
      If !Empty(Self:cVersao) .And. !PutMV("MV_MTVERSA",Self:cVersao)
         MsgInfo(STR0046,STR0010) // "Versão não configurada com sucesso."
      EndIf
   EndIf

Return Nil
 
/*-----------------------------------------------------------------------------------------------------------------------
Método     : ViewXML()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela visualização do arquivo XML
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/   
Method ViewXML(oMsSelect) Class EICMATRIZ
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

   If !(lRet := MAT100ExiArq(cWork))
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
         MsgInfo(StrTran(STR0047 + '###' + STR0048, "###", cArqXML), STR0010) // "Erro ao excluir o arquivo " + " do diretório temporário. Não será possível prosseguir."
         Break
      EndIf
   EndIf

   //Copia do Servidor para o diretório temporário
   If !CpyS2T(cDir+cArqXML, Self:cDirTemp, .T.) 
      MsgInfo(StrTran(STR0049 + '###' + STR0048, "###", cArqXML), STR0010) // "Erro ao copiar o arquivo " + " para o diretório temporário. Não será possível prosseguir."
      Break
   EndIf 
   
   //Executa o browser para visualizar o XML
   If ShellExecute("open", Self:cDirTemp + RetFileName(cArqXML) + SubStr(cArqXML,Rat(".",cArqXML)), "", "", 1 ) <= 32
      MsgInfo(STR0050, STR0010) // "Erro na abertura do arquivo."
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
Method GravaEJD(cStatus,aCampos) Class EICMATRIZ
Local lSeek
Local cStIni := ""

If cStatus == CANCELADOS
   EJD->(DbSetOrder(2)) // EJD_FILIAL + EJD_CHAVE + EJD_ARQUIV
   lSeek := EJD->(DbSeek(xFilial("EJD")+MATRIZ+AvKey(Self:cImportador,"EJD_CHAVE")+AvKey(Self:cFileXML,"EJD_ARQUIV")))
Else
   If cStatus == ENVIADOS .Or. cStatus == GERADOS
      cStIni := GERADOS
   ElseIf cStatus == PROCESSADOS
      cStIni := ENVIADOS
   EndIf
   EJD->(DbSetOrder(1)) // EJD_FILIAL + EJD_SERVIC + EJD_STATUS + EJD_CHAVE + EJD_ARQUIV
   lSeek := EJD->(DbSeek(xFilial("EJD")+MATRIZ+AvKey(ENV_MAT,"EJD_SERVIC")+AvKey(cStIni,"EJD_STATUS")+AvKey(Self:cImportador,"EJD_CHAVE")+AvKey(Self:cFileXML,"EJD_ARQUIV")))
EndIf

If RecLock("EJD",!lSeek)
   EJD->EJD_FILIAL    := xFilial("EJD")
   EJD->EJD_INTEG     := MATRIZ
   EJD->EJD_SERVIC    := ENV_MAT
   EJD->EJD_STATUS    := cStatus
   EJD->EJD_ARQUIV    := Self:cFileXML
   EJD->&(aCampos[1]) := cUserName
   EJD->&(aCampos[2]) := Self:dData
   EJD->&(aCampos[3]) := Self:cHora
   EJD->EJD_CHAVE     := Self:cImportador
   EJD->EJD_ID        := Self:cId
   EJD->(MsUnLock())
EndIf

Return Nil

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
      MsgInfo(StrTran(STR0051 + '###' + STR0052, "###", cArqOri), STR0010) // "O arquivo " + "  não foi encontrado. Não será possível executar a rotina."
      Break
   EndIf
   
   __CopyFile(cArqOri, cArqDest)
   
   If !File(cArqDest)
      MsgInfo(StrTran(STR0051 + '###' + STR0052, "###", cArqDest), STR0010) // "O arquivo " + "  não foi encontrado. Não será possível executar a rotina."
      Break
   EndIf

   If lDelArqOri
      If FErase(cArqOri) <> 0
         MsgInfo(StrTran(STR0051 + '###' + STR0053, "###", cArqOri), STR0010) // "O arquivo " + " não foi excluído."
         Break
      EndIf
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

/*-----------------------------------------------------------------------------------------------------------------------
Função     : MAT100ExiArq()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Responsavel pela validação da existencia de arquivo nas pastas
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Static Function MAT100ExiArq(cWork)
Local lRet := .T.

Begin Sequence

   If (cWork)->(BOF()) .And. (cWork)->(EOF())
      MsgInfo(STR0054,STR0010) // "Não existe nenhum arquivo."
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet

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
   cCond := "EJD->EJD_FILIAL == '" + cFil + "' .And. EJD->EJD_INTEG == '" + MATRIZ + "'"
   EJD->(DBSetFilter({|| &cCond}, cCond )) 

   EJD->(DbSetOrder(3))
   EJD->(DbGoBOttom())
   cId := PadL(AllTrim(Str(Val(EJD->EJD_ID) + 1)),14,"0")

   If !Empty(EJD->(DBFilter()))
      EJD->(DBCLEARFILTER())   
   EndIf
   
   EJD->(DbSetOrder(nOrd))
   EJD->(DbGoTo(nRec))

Return cId

Function VldCodMun()
Local lRet := .T.

If Empty(M->YT_ESTADO)
   MsgInfo(STR0055,STR0010) // "Preencha o campo 'Estado' para que apareçam os codigos IBGE dos municípios relacionado ao Estado."
Else
   lRet := ExistCpo('CC2',AvKey(M->YT_ESTADO,"CC2_EST")+M->YT_CODMUN)
EndIf

Return lRet