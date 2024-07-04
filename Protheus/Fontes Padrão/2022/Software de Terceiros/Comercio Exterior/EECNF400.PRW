#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EEC.CH"
#INCLUDE "EECNF400.CH"
#Include "TOPCONN.CH"

#Define SOMAR    1
#Define SUBTRAIR 2
#Define ENTER CHR(13)+CHR(10)

Function EECNF400(aCapaAuto,aItensAuto,nOpcAuto,aNFRem)
Local oBrowse
Local oAvObject := AvObject():New()
Private aRotina
Private lNF400Auto := ValType(aCapaAuto) <> "U" .Or. ValType(aItensAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private aItensDev  := {}
Private lProcDevIt := .F.
Private lNFLoteExp := AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO")

If !lNF400Auto
   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("EEM") //Informando o Alias 
   oBrowse:SetMenuDef("EECNF400") //Nome do fonte do MenuDef
   oBrowse:SetDescription(STR0001) // "Nota fiscal de Saída" //Descrição a ser apresentada no Browse
   oBrowse:Activate()
Else
   //Definições de WHEN dos campos
   INCLUI := nOpcAuto == INCLUIR
   ALTERA := nOpcAuto == ALTERAR
   EXCLUI := nOpcAuto == EXCLUIR
   
   
   addLinpos(aItensAuto, "EES_FATSEQ", nOpcAuto, "EES")
   addLinpos(aNFRem, "EYY_D1ITEM", nOpcAuto, "EYY")

   delItensSai(aCapaAuto, nOpcAuto)

   FWMVCRotAuto(ModelDef(), "EEM", nOpcAuto, {{"EEMMASTER",aCapaAuto}, {"EESDETAIL",aItensAuto},  {"EYYDETAIL",aNFRem}})
EndIf

Return Nil

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EECNF400" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EECNF400" OPERATION 4 ACCESS 0 //"Alterar"

If !EasyGParam("MV_EECFAT",,.F.)
   ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EECNF400" OPERATION 3 ACCESS 0 //"Incluir"
   ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EECNF400" OPERATION 5 ACCESS 0 //"Excluir"
EndIf

Return aClone(aRotina)

// Cria a estrutura a ser usada no Modelo de Dados
Static Function ModelDef()
Local oStruEEM := FWFormStruct( 1, "EEM", , /*lViewUsado*/ )
Local oStruEES := FWFormStruct( 1, "EES", , /*lViewUsado*/ )
Local oStruEYY := FWFormStruct( 1, "EYY", , /*lViewUsado*/ )
Local oStruEK6
Local oModel
Local bCommit  := {|oModel| NF400COMMIT(oModel)}
Local bCancel  := {||.T.}
Local bPosValidacao := {|oModel| NF400CalcVal(oModel) }
Local aCampos := {}
Local nI, nPos
Local lNF400Auto := If(Type("lNF400Auto")=="L",lNF400Auto,.F.)
Local lNFLoteExp := If(Type("lNFLoteExp")=="L",lNFLoteExp,AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO"))

// Criação do Modelo
oModel := MPFormModel():New( "EECNF", /*bPreValidacao*/, bPosValidacao, bCommit, bCancel )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("EEMMASTER", /*cOwner*/ ,oStruEEM )

oStruEEM:SetProperty ('EEM_NRNF', MODEL_FIELD_WHEN, {||NF400When("EEM_NRNF")})
oStruEEM:SetProperty ('EEM_SERIE', MODEL_FIELD_WHEN, {||NF400When("EEM_SERIE")})
oStruEEM:SetProperty ('EEM_DTNF', MODEL_FIELD_WHEN, {||NF400When("EEM_DTNF")})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("EESDETAIL","EEMMASTER", oStruEES, /*bLinePre*/ ,/*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oStruEYY:RemoveField("EYY_DESFOR")
oModel:AddGrid("EYYDETAIL","EESDETAIL", oStruEYY,, {|oModel| IniCpoEYY(oModel) },  , ,  )
oModel:GetModel("EYYDETAIL"):SetOptional( .T. )

//Modelo de relação entre Capa(EEM) e detalhe(EES)
oModel:SetRelation("EESDETAIL",GetConfig("RELACAO"), EES->(IndexKey(1)))

//Modelo de relação entre Item (EES) e notas de entrada (EYY)
If lNF400Auto
    aRelacao := {{"EYY_FILIAL","xFilial('EES')"},;
                   {"EYY_PREEMB","EES_PREEMB"},;
                   {"EYY_NFSAI" ,"EEM_NRNF"},;
                   {"EYY_SERSAI","EEM_SERIE"}}
Else
    aRelacao := {{"EYY_FILIAL","xFilial('EES')"},;
                   {"EYY_PREEMB","EES_PREEMB"},;
                   {"EYY_PEDIDO","EES_PEDIDO"},;
                   {"EYY_SEQUEN","EES_SEQUEN"},;
                   {"EYY_NFSAI" ,"EEM_NRNF"},;
                   {"EYY_SERSAI","EEM_SERIE"}}

   If EYY->(FieldPos("EYY_SQFNFS")) > 0
      aAdd(aRelacao, {"EYY_SQFNFS","EES_FATSEQ"})
   EndIf
                   
EndIf
//If(Select("EYY") <= 0 , ChkFile("EYY"),)
oModel:SetRelation("EYYDETAIL",aRelacao  , EYY->(IndexKey(1)))

oModel:SetPrimaryKey( { "EEM_FILIAL", "EEM_PREEMB", "EEM_TIPOCA", "EEM_NRNF", "EEM_SERIE"} )
//oModel:GetModel("EESDETAIL"):SetUniqueLine( { "EES_PREEMB", "EES_NRNF", "EES_SERIE", "EES_PEDIDO", "EES_SEQUEN", "EES_FATSEQ" } )
oModel:GetModel("EESDETAIL"):SetUniqueLine({"EES_PEDIDO", "EES_SEQUEN", "EES_FATSEQ"} )                                        //NCF - 29/04/2015

aCampos := { "EYY_PREEMB", "EYY_SEQEMB", "EYY_NFSAI", "EYY_SERSAI", "EYY_PEDIDO", "EYY_SEQUEN", "EYY_FASE", "EYY_NFENT", "EYY_SERENT", "EYY_FORN", "EYY_FOLOJA", "EYY_D1ITEM"}

If EYY->(FieldPos("EYY_SQFNFS")) > 0
   aAdd(aCampos, "EYY_SQFNFS")
EndIf 

oModel:GetModel("EYYDETAIL"):SetUniqueLine(aCampos)
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) // "Nota fiscal de Saída"

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel("EEMMASTER"):SetDescription(STR0007) //"Controle de Notas Fiscais"
oModel:GetModel("EESDETAIL"):SetDescription(STR0008) // "Notas Fiscais por Itens"
oModel:GetModel("EYYDETAIL"):SetDescription( If(!lNFLoteExp,STR0047,STR0048))  //"Notas Fiscais de Remessa"/"Notas Fiscais de Entrada por Item"

If lNFLoteExp
   oStruEK6 := FWFormStruct( 1, "EK6", , /*lViewUsado*/ )
   oModel:AddGrid("EK6DETAIL","EESDETAIL", oStruEK6,, {|oModel| IniCpoEK6(oModel), If( EK6LinhaOK(), SetPropEK6(.F.) , .F. ) },  , ,  )
   oModel:GetModel("EK6DETAIL"):SetOptional( .T. )
   //Modelo de relação entre Item (EES) e notas de formação de lote (EK6)
   aRelESSEK6 := {{"EK6_FILIAL","xFilial('EES')"},{"EK6_PREEMB","EES_PREEMB"},{"EK6_PDNFSD","EES_PEDIDO"},{"EK6_SQPDNF","EES_SEQUEN"},;
                   {"EK6_NFSD"  ,"EEM_NRNF"  },{"EK6_SENFSD","EEM_SERIE" },{"EK6_SQFTSD","EES_FATSEQ"}}
   oModel:SetRelation("EK6DETAIL",aRelESSEK6, EK6->(IndexKey(2)))
   aCposPKEK6 := {"EK6_FILIAL "," EK6_PREEMB "," EK6_NFSD "," EK6_SENFSD "," EK6_PDNFSD "," EK6_SQPDNF "," EK6_SQFTSD "," EK6_NF "," EK6_SERIE "," EK6_CLIENT "," EK6_LOJACL "," EK6_COD_I "," EK6_ITEM"}                  
   oModel:GetModel("EK6DETAIL"):SetUniqueLine(aCposPKEK6)
   oModel:GetModel("EK6DETAIL"):SetDescription(STR0049) // "Notas Fiscais de formação de Lote de Exportação por item"
EndIf

Return oModel

Static Function ViewDef()
Local oStruEEM := FWFormStruct( 2, "EEM" )
Local oStruEES := FWFormStruct( 2, "EES" )
Local oStruEYY := FWFormStruct( 2, "EYY" )
Local oStruEK6
Local oView
Local oModel   := FWLoadModel( "EECNF400" )
//Local oCalcNF

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oStruEEM := SetRemove(oStruEEM,{"EEM_TIPOCA","EEM_RIEXST"})
oStruEEM := SetGrupo(SetStruct(oStruEEM,GetConfig("ORDEM_EEM"),.F.),GetConfig("GRUPO"))
oView:AddField("VIEW_EEM",oStruEEM, "EEMMASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oStruEES := SetRemove(oStruEES,{"EES_PREEMB","EES_NRNF","EES_SERIE","EES_DTNF","EES_CNPJ"})
oStruEES := SetStruct(oStruEES,GetConfig("ORDEM_EES"),.F.)
oView:AddGrid("VIEW_EES",oStruEES , "EESDETAIL")

oStruEYY := SetRemove(oStruEYY,{"EYY_PREEMB", "EYY_NFSAI", "EYY_SERSAI", "EYY_PEDIDO", "EYY_SEQUEN", "EYY_FASE", "EYY_NROMEX", "EYY_DTMEX", "EYY_RE", "EYY_SEQEMB", "EYY_DESFOR"})
oStruEYY:SetProperty( 'EYY_D1ITEM' , MVC_VIEW_CANCHANGE, .T.)
oStruEYY:SetProperty( 'EYY_D1PROD' , MVC_VIEW_CANCHANGE, .T.)
oView:AddGrid("VIEW_EYY",oStruEYY , "EYYDETAIL")

If lNFLoteExp

   oStruEK6 := FWFormStruct( 2, "EK6" )
   oStruEK6 := SetRemove(oStruEK6,{"EK6_PREEMB", "EK6_NFSD", "EK6_SENFSD", "EK6_PDNFSD", "EK6_SQPDNF", "EK6_SQFTSD", "EK6_QTUMIT", "EK6_SEQEMB"})
   oStruEK6:SetProperty( 'EK6_ITEM' , MVC_VIEW_CANCHANGE, .T.)
   oStruEK6:SetProperty( 'EK6_COD_I' , MVC_VIEW_CANCHANGE, .T.)
   oView:AddGrid("VIEW_EK6",oStruEK6 , "EK6DETAIL")

   // Criar "box" horizontal para receber algum elemento da view
   oView:CreateHorizontalBox( "ACIMA"  , 40)
   oView:CreateHorizontalBox( "MEIO"   , 30)
   oView:CreateHorizontalBox( "ABAIXO" , 30)

   // Criar "box" vertical para receber algum elemento da view
   oView:CreateVerticalBox( 'ABAIXO_ESQ', 50, 'ABAIXO' )
   oView:CreateVerticalBox( 'ABAIXO_DIR', 50, 'ABAIXO' )

   // Relaciona o ID da View com o "box" para exibição
   oView:SetOwnerView( "VIEW_EEM", "ACIMA"  )
   oView:SetOwnerView( "VIEW_EES", "MEIO" )
   oView:SetOwnerView( "VIEW_EYY", "ABAIXO_ESQ" )
   oView:SetOwnerView( "VIEW_EK6", "ABAIXO_DIR" )

   oView:EnableTitleView( "VIEW_EYY", STR0050 , RGB(240, 248, 255 )) //"NF Remessa Compra - Exportação Indireta"
   oView:EnableTitleView( "VIEW_EK6", STR0051 , RGB(240, 248, 255 )) //"NF Remessa Venda - Formação de Lote"
   
   If EasyGParam("MV_EECFAT",,.F.)  
      oView:SetViewProperty('VIEW_EEM', 'ONLYVIEW')
      oView:SetViewProperty('VIEW_EES', 'ONLYVIEW')
      oView:SetViewProperty('VIEW_EYY', 'ONLYVIEW')
   EndIf
Else

   // Criar "box" horizontal para receber algum elemento da view
   oView:CreateHorizontalBox( "ACIMA"  , 50)
   oView:CreateHorizontalBox( "ABAIXO" , 50)

   // Criar "box" vertical para receber algum elemento da view
   oView:CreateVerticalBox( 'ABAIXO_ESQ', 70, 'ABAIXO' )
   oView:CreateVerticalBox( 'ABAIXO_DIR', 30, 'ABAIXO' )

   // Relaciona o ID da View com o "box" para exibição
   oView:SetOwnerView( "VIEW_EEM", "ACIMA"  )
   oView:SetOwnerView( "VIEW_EES", "ABAIXO_ESQ" )
   oView:SetOwnerView( "VIEW_EYY", "ABAIXO_DIR" )
   
   oView:EnableTitleView( "VIEW_EYY", STR0047 , RGB(240, 248, 255 )) //"Notas Fiscais de Remessa"
EndIf

// Liga a identificação do componente
oView:EnableTitleView( "VIEW_EEM", STR0007 , RGB(240, 248, 255 )) //"Controle de Notas Fiscais"
oView:EnableTitleView( "VIEW_EES", STR0008 , RGB(240, 248, 255 )) // "Notas Fiscais por Itens"

If lNFLoteExp
   oView:EnableTitleView( "VIEW_EK6", STR0052 , RGB(240, 248, 255 )) //"Notas Fiscais de Remessa"
EndIf
//Acrescenta um novo botão à "Ações Relacionadas"
//If EEM->EEM_TIPONF == "2"                                              //NCF - 08/05/2014 - Opção disponível apenas para notas complementares
   oView:addUserButton( STR0028 ,"",{ |oModel| NF400Emb(oModel)  },"") //"Embarque"
//EndIf
//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Bruno Akyo Kubagawa - BAK
* Data: 30/11/2011 - 15:00 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
Local oBusinessCont
	
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	If !oEasyIntEAI:oMessage:HasErrors()
	   oBusinessCont := oEasyIntEAI:oMessage:GetMsgContent()
	   
	   If IsCpoInXML(oBusinessCont,"_VendorCode") .AND. !Empty(EasyGetXMLinfo(, oBusinessCont, "_VendorCode"))
          Return NF100IntDef(cXML, nTypeTrans, cTypeMessage, oEasyIntEAI)
       EndIf    
    EndIf
    	
	oEasyIntEAI:oMessage:SetVersion("1.000|1.001")
	oEasyIntEAI:oMessage:SetMainAlias("EEM")
	
	//oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECNF400(oEasyMessage:GetEAutoArray("EEM"),EasyEAutItens("EEM", "EES", oEasyMessage:GetEAutoArray("EEM"),oEasyMessage:GetEAutoArray("EES"), "EEM_FILIAL+EEM_PREEMB+EEM_NRNF+EEM_SERIE","EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN+EES_FATSEQ", 1), oEasyMessage:GetOperation(), oEasyMessage:GetEAutoArray("EYY"))} )
    oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECNF400(oEasyMessage:GetEAutoArray("EEM"), oEasyMessage:GetEAutoArray("EES"), oEasyMessage:GetOperation(), oEasyMessage:GetEAutoArray("EYY"))} )
	oEasyIntEAI:SetModule("EEC",29)
    
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "NF400ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "NF400ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	// ***
	// *** Envio
	//oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AT170ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	//oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AT170ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

Function NF400ARECB(oMessage) 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oExecAuto := EExecAuto():New()
Local oRec      := ERec():New()
Local oTab      := ETab():New()
Local oItem
Local oRemessa  := ETab():New()
Local oItemRem
Local oParams   := ERec():New()
Local lObrigat  := .T.
Local nCont := 0
Local nContRem
Local cPedido
Local cExpCod
Local cSequencia
Local cSituation
Local lCostCenterCode := .F.
Local aOrdEE7
Local aOrdEE8
Local i
Local oCodItem
Local cTipoNF := "1"
//	AddArrayXML(oRec,              , oBusinessCont,"_CompanyId"        , lObrigat)  // Empresa
//	AddArrayXML(oRec, "EEM_FILIAL" , oBusinessCont,"_BranchId"         , lObrigat)  // Filial
   oRec:SetField(    "EEM_PREEMB" , AvKey("","EEM_PREEMB"))                        // Processo Embarque - Campo da chave
   oRec:SetField(    "EEM_TIPOCA" , AvKey("N","EEM_TIPOCA"))                       // Tipo de cadastro - Campo da chave
   AddArrayXML(oRec, "EEM_NRNF"   , oBusinessCont,"_InvoiceNumber"    , lObrigat)  // Número da Nota Fiscal - Campo da chave
   oRec:SetField(    "EEM_TIPONF" , AvKey("1","EEM_TIPONF"))                       // Tipo da Nota - Campo da chave - 1=Saida;2=Complementar;3=Credito;4=Despesa;5=DevoluþÒo
   If !Empty( EasyGetXMLinfo(, oBusinessCont, "_InvoiceSerie") )                      //NCF - 08/06/2016 - Solcitação de Cliente observado que há casos onde a Nota do Logix não possui Série e admite-se um inicializador padrão no Protheus.
      AddArrayXML(oRec, "EEM_SERIE"  , oBusinessCont,"_InvoiceSerie"     , lObrigat)  // Serie da Nota Fiscal - Campo da chave
   EndIf
//	AddArrayXML(oRec,              , oBusinessCont,"_InvoiceSubSerie"  , lObrigat)  // Sub-Serie da Nota Fiscal   
   AddArrayXML(oRec, "EEM_MODNF"  , oBusinessCont,"_InvoiceModel"     , !lObrigat) // Modelo da Nota Fiscal
   cSituation := EasyGetXMLinfo(, oBusinessCont, "_InvoiceSituation")              // Situação da Nota Fiscal (1-Ativa 2-Inativa)   
   /*If "2" $ cSituation // 2 - Inativa - Delete
      oParams:SetField("nOpc",5)
   EndIf*/

   cExpCod :=  EasyGetXMLinfo(, oBusinessCont, "_CompanyId")
 
   dData :=  EasyTimeStamp( EasyGetXMLinfo(, oBusinessCont, "_IssueDate") , .F.)
   oRec:SetField(    "EEM_DTNF"   , dData)                                          // Data de Emissão

   AddArrayXML(oRec, "EEM_VLMERC" , oBusinessCont,"_ValueofGoods"    , lObrigat)    // Valor da Mercadoria
   AddArrayXML(oRec, "EEM_VLFRET" , oBusinessCont,"_FreightAmount"   , !lObrigat)   // Valor do frete
   AddArrayXML(oRec, "EEM_VLSEGU" , oBusinessCont,"_InsuranceAmount" , !lObrigat)   // Valor do Seguro                   //NCF - 25/06/2013 - O valor do seguro vindo do ERP Externo deve ser considerado na somatória para ser validado o campo "EEM_VLNF"
   //oRec:SetField("EEM_VLSEGU",000000000000.0000)                                    // Valor para somatoria dos itens
   oRec:SetField("EEM_OUTROS",000000000000.0000)                                    // Valor para somatoria dos itens
   AddArrayXML(oRec, "EEM_DESCON" , oBusinessCont,"_DiscountAmount"  , lObrigat)    // Valor do Desconto 
   AddArrayXML(oRec, "EEM_VLNF"   , oBusinessCont,"_InvoiceAmount"   , lObrigat)    // Valor da Nota Fiscal
   AddArrayXML(oRec, "EEM_TXTB"   , oBusinessCont,"_CurrencyRate"    , lObrigat)    // Taxa da Moeda Utilizada para Calcular o Valor da Nota Fiscal

   //THTS - 28/11/2017 - Adicionada a chave da Nota ao campo EEM_CHVNFE
   AddArrayXML(oRec, "EEM_CHVNFE"   , oBusinessCont,"_ElectronicAccessKey"    , lObrigat)    // Chave da NFE

   If IsCpoInXML(oBusinessCont,"_ListOfItens") .And. IsCpoInXML(oBusinessCont:_ListOfItens,"_ITEM")
       //Verificando se ha mais de um item:
      If ValType(oBusinessCont:_ListOfItens:_Item) <> "A"
         XmlNode2Arr(oBusinessCont:_ListOfItens:_Item, "_ITEM")
      EndIf

      lCostCenterCode := EES->(FieldPos('EES_CCERP')) > 0 
      For nCont := 1 To Len(oBusinessCont:_ListOfItens:_Item)

          oItem := ERec():New()
          oItem:SetField(      "EES_NR_CON" , AvKey("","EES_NR_CON"))
          oItem:SetField(      "EES_PREEMB" , AvKey("","EES_PREEMB"))                                                    // Campo da chave 
          oItem:SetField(      "EES_NRNF"   , AvKey(EasyGetXMLinfo(, oBusinessCont, "_InvoiceNumber"),"EES_NRNF"))       // Número da Nota Fiscal - Campo da chave 
          oItem:SetField(      "EES_SERIE"  , AvKey(EasyGetXMLinfo(, oBusinessCont, "_InvoiceSerie"),"EES_SERIE"))       // Serie da Nota Fiscal - Campo da chave 
          AddArrayXML(oItem,   "EES_FATSEQ" , oBusinessCont:_ListOfItens:_Item[nCont] , "_InvoiceSequence", lObrigat)    // Sequência da Nota Fiscal Faturamento  - Campo da chave 

          //AddArrayXML(oItem,   "EES_PEDIDO" , oBusinessCont:_ListOfItens:_Item[nCont] , "_OrderNumber"    , lObrigat)  // Número do Pedido que Originou o Item da Nota - Campo da cahve
          cPedido := EasyGetXMLinfo(, oBusinessCont:_ListOfItens:_Item[nCont], "_OrderNumber")

          If EES->(FieldPos("EES_PEDERP")) > 0
             oItem:AddField("EES_PEDERP", AvKey(cPedido, "EES_PEDERP"))
          EndIf
          
          If cPedido <> '0'
             If !EasyGParam("MV_EEC0009",.T.) .Or. AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) == "#EE7_PEDIDO#" .Or. Empty(EasyGParam("MV_EEC0009",,""))
                If AVFLAGS("EEC_LOGIX_PREPED")
                   aOrdEE7 := SaveOrd({"EE7"})
                   EE7->(DbSetOrder(11))
                   EE7->(DbSeek(xFilial("EE7")+AvKey(cPedido,"EE7_PEDERP")))
                   cPedido := EE7->EE7_PEDIDO
                   RestOrd(aOrdEE7)
                EndIf
             
                oItem:SetField(      "EES_PEDIDO" , cPedido)
             Else
                cPed := StrTran(AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) ,"#EE7_PEDIDO#",cPedido)
                cPedido := StrTran(AllTrim(Upper(cPed)) ,"#EE7_FORN#"  ,cExpCod)
                oItem:SetField(      "EES_PEDIDO" , cPedido)
             EndIf
          Else
             oItem:SetField(      "EES_PEDIDO" , cPedido)
          EndIf
          
		  If Empty(oItem:GetValue("EES_PEDERP")) .OR. AllTrim(oItem:GetValue("EES_PEDERP")) == "0"
		     oRec:SetField("EEM_TIPONF" , AvKey("2","EEM_TIPONF"), .T.) //Nota Complementar pois não tem pedido
			 cSequencia := AllTrim(Str(nCont))
             cTipoNF := "2"
		  Else
		     cSequencia := AllTrim(EasyGetXMLinfo(, oBusinessCont:_ListOfItens:_Item[nCont], "_OrdemItem"))
		  EndIf
		  
          cSequencia := PadL(cSequencia,AvSx3("EES_SEQUEN",AV_TAMANHO))
          oItem:SetField(      "EES_SEQUEN" , cSequencia)                                                                // Sequência do Item do Pedido que Gerou o Item da Nota - Campo da chave

          If cTipoNF == "1"//Nota Saida
             aOrdEE8 := SaveOrd({"EE8"})
             EE8->(DbSetOrder(1))
             If EE8->(DbSeek(xFilial("EE8") + AvKey(cPedido,"EE8_PEDIDO") + AvKey(cSequencia,"EE8_SEQUEN")))
                oItem:SetField(      "EES_COD_I" , EE8->EE8_COD_I)
             Else
                AddArrayXML(oItem,   "EES_COD_I"  , oBusinessCont:_ListOfItens:_Item[nCont] , "_ItemCode"       , !lObrigat)   // Código do Item
             EndIf
             RestOrd(aOrdEE8)
          Else
             AddArrayXML(oItem,   "EES_COD_I"  , oBusinessCont:_ListOfItens:_Item[nCont] , "_ItemCode"       , !lObrigat)   // Código do Item
          EndIf

          AddArrayXML(oItem,   "EES_QTDE"   , oBusinessCont:_ListOfItens:_Item[nCont] , "_Quantity"       , !lObrigat)   // Quantidade do Item
          //AddArrayXML(oItem,                , oBusinessCont:_ListOfItens:_Item[nCont] , "_UnitofMeasureCode", lObrigat)  // Código da Unidade de Medida
          //AddArrayXML(oItem,                , oBusinessCont:_ListOfItens:_Item[nCont] , "_UnityPrice"       , lObrigat)  // Preço Unitário do Item
          AddArrayXML(oItem,   "EES_VLMERC" , oBusinessCont:_ListOfItens:_Item[nCont] , "_GrossValue"     , lObrigat)    // Valor Líquido do Item. (Quantidade x Preço Unitário x Taxa da Moeda)      
          AddArrayXML(oItem,   "EES_VLFRET" , oBusinessCont:_ListOfItens:_Item[nCont] , "_FreightValue"   , !lObrigat)   // Valor do Frete Unitário
          AddArrayXML(oItem,   "EES_VLSEGU" , oBusinessCont:_ListOfItens:_Item[nCont] , "_InsuranceValue" , !lObrigat)   // Valor do Seguro Unitário                //NCF - 25/06/2013 - O valor do seguro vindo do ERP Externo deve ser considerado na somatória para ser validado o campo "EES_VLNF"
          //oItem:SetField(      "EES_VLSEGU",000000000000.0000)                                                           // Valor para somatoria dos itens
          oItem:SetField(      "EES_VLOUTR",000000000000.0000)                                                           // Valor para somatoria dos itens
          AddArrayXML(oItem,   "EES_DESCON"  , oBusinessCont:_ListOfItens:_Item[nCont] , "_DiscountValue"  , lObrigat)   // Valor do Desconto Unitário
          AddArrayXML(oItem,   "EES_VLNF"    , oBusinessCont:_ListOfItens:_Item[nCont] , "_NetValue"       , lObrigat)   // Valor Total Unitário
          If lCostCenterCode .And. IsCpoInXML(oBusinessCont:_ListOfItens:_Item[nCont],"_AreAndLineOfBusinessCode")
             AddArrayXML(oItem,   "EES_CCERP"    , oBusinessCont:_ListOfItens:_Item[nCont] , "_AreAndLineOfBusinessCode"       , lObrigat)
          EndIf
          AddArrayXML(oItem,   "EES_QTDORI"   , oBusinessCont:_ListOfItens:_Item[nCont] , "_Quantity"      , .F.)        // Quantidade do Item

          // EJA - 17/11/2017 - Nota Fiscal de Remessa
          If IsCpoInXML(oBusinessCont:_ListOfItens:_Item[nCont],"_ListOfRelatedInvoicesItem") .And. IsCpoInXML(oBusinessCont:_ListOfItens:_Item[nCont]:_ListOfRelatedInvoicesItem,"_RelatedInvoicesItem")

                If ValType(oBusinessCont:_ListOfItens:_Item[nCont]:_ListOfRelatedInvoicesItem:_RelatedInvoicesItem) <> "A"
                    XmlNode2Arr(oBusinessCont:_ListOfItens:_Item[nCont]:_ListOfRelatedInvoicesItem:_RelatedInvoicesItem, "_RelatedInvoicesItem")
                EndIf
                addRemXML(;
                    oRemessa,;
                    oBusinessCont:_ListOfItens:_Item[nCont]:_ListOfRelatedInvoicesItem:_RelatedInvoicesItem,;
                    oItem,;
                    oRec;
                )
          EndIf

          oTab:AddRec(oItem)
       Next
   EndIf

   //NCF - 24/10/2013 - Verificação dos itens para determinação do Tipo de Nota Integrada
   /*
   nPos_TipoNF := aScan(oRec:aFields,        {|x| Alltrim(UPPER(x:cField))  == "EEM_TIPONF"  } )
   lIsNFC := .F.
   For i:=1 To Len(oTab:Arec)
      nPos_Ped    := aScan(oTab:Arec[i]:aFields,{|x| Alltrim(UPPER(x:cField))  == "EES_PEDIDO"  } )
      nPos_Seq    := aScan(oTab:Arec[i]:aFields,{|x| Alltrim(UPPER(x:cField))  == "EES_SEQUEN"  } )
      If Alltrim(oTab:AREC[1]:aFields[nPos_Ped]:xContent) == '0' //.And. Alltrim(oTab:AREC[1]:aFields[nPos_Seq]:xContent) == '0'   
         oTab:AREC[1]:aFields[nPos_Seq]:xContent := PadL(i,AvSx3("EES_SEQUEN",AV_TAMANHO))
         lIsNFC := .T.     
      EndIf
      If lIsNFC 
         oRec:aFields[nPos_TipoNF]:xContent := '2'
      EndIf 
   NExt i
   */
   
   If "2" $ cSituation // 2 - Inativa - Delete                                                                        
      //NCF - 05/11/2014 - Precisa localizar o Código do Embarque para exclusão/cancelamento pois a NF pode estar vinculada a um Embarque
      nOrd   := EEM->(IndexOrd())
      nRecno := EEM->(Recno())
      EEM->(DbSetOrder(4))
      If EEM->(DbSeek( xFilial("EEM")+AvKey(EasyGetXMLinfo(, oBusinessCont, "_InvoiceNumber"),"EEM_NRNF")+AvKey(EasyGetXMLinfo(, oBusinessCont, "_InvoiceSerie"),"EEM_SERIE")+AvKey("N","EEM_TIPOCA") ))
         If !Empty(EEM->EEM_PREEMB)
            oRec:SetField(    "EEM_PREEMB" , EEM->EEM_PREEMB , .T.) 
         EndIf   
      EndIf
      If nOrd == 0              //NCF - 29/06/2015
         EEM->(DbSetOrder(1))
      EndIf
      EEM->(DbGoTo(nRecno))   
      
      oParams:SetField("nOpc",5)
      oExecAuto:SetField("PARAMS",oParams)
   EndIf

   oExecAuto:SetField("EEM",oRec)
   oExecAuto:SetField("EES",oTab)
   oExecAuto:SetField("EYY",oRemessa)

   oBatch:AddRec(oExecAuto)

Return oBatch

Function NF400ARESB(oMessage) 
Local oXml      := EXml():New()

   If oMessage:HasErrors()      
      oXMl := oMessage:GetContentList("RESPONSE")
   EndIf
    
Return oXml

/*
 * EJA - 21/11/2017
 * Adiciona ao objeto oRemessa notas fiscais de remessa a partir do array de XML aRelInv.
 * oItem (Item da Nota fiscal de saída) e oRec (capa da nota fiscal de saída) são necessários para 
 * adicionar a as notas fiscais de remessa.
 */
Static Function addRemXML(oRemessa, aRelInv, oItem, oRec)

   Local oItemRem := Nil
   Local nContRem
   Local lObrigat := .T.

   For nContRem := 1 To Len(aRelInv)

      oItemRem := ERec():New()
      oItemRem:SetField("EYY_NFSAI", oRec:GetValue("EEM_NRNF"))
      oItemRem:SetField("EYY_SERSAI", oRec:GetValue("EEM_SERIE"))
      oItemRem:SetField("EYY_PREEMB", oItem:GetValue("EES_PREEMB"))
      AddArrayXML(oItemRem, "EYY_NFENT", aRelInv[nContRem], "_InvoiceNumber", !lObrigat)
      AddArrayXML(oItemRem, "EYY_SERENT", aRelInv[nContRem], "_InvoiceSerie", !lObrigat)
      AddArrayXML(oItemRem, "EYY_FORN", aRelInv[nContRem], "_CustomerCode", !lObrigat)
      oItemRem:SetField("EYY_FOLOJA", AvKey(".","EE7_FOLOJA"))
      AddArrayXML(oItemRem, "EYY_QUANT", aRelInv[nContRem], "_Quantity", !lObrigat)
      AddArrayXML(oItemRem, "EYY_D1ITEM", aRelInv[nContRem], "_InvoiceSequence", !lObrigat)
      AddArrayXML(oItemRem, "EYY_D1PROD", aRelInv[nContRem], "_ItemCode", !lObrigat)
      AddArrayXML(oItemRem, "EYY_CHVNFE", aRelInv[nContRem], "_ElectronicAccessKey", !lObrigat)
      oItemRem:SetField("EYY_SEQUEN", oItem:GetValue("EES_SEQUEN"))
      oItemRem:SetField("EYY_PEDIDO", oItem:GetValue("EES_PEDIDO"))

      If EYY->(FieldPos("EYY_SQFNFS")) > 0
         oItemRem:SetField("EYY_SQFNFS", oItem:GetValue("EES_FATSEQ"))
      EndIf

      oRemessa:AddRec(oItemRem)

   Next
    
Return

/*
Programa  : GetConfig
Objetivo  : Retornar configurações
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      : 
*/
Static Function GetConfig(cId)
Local aConfiDados := SetAll()
Local nPos := 0
Local aConfig := {}

   If (nPos := aScan(aConfiDados,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(cId)) })) > 0
      aConfig := aConfiDados[nPos][2]
   EndIf

Return aClone(aConfig)

/*
Programa  : SetAll
Objetivo  : Setar ordem de campos, estruturas, gatilhos.
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      : 
*/
Static Function SetAll()
Local aDados := {}
Local aFieldsEEM := {"EEM_NRNF","EEM_SERIE","EEM_DTNF","EEM_TIPONF","EEM_PREEMB",;
                     "EEM_VLMERM","EEM_VLFREM","EEM_VLSEGM","EEM_OUTROM","EEM_VLNFM","EEM_TXTB",;
                     "EEM_VLMERC","EEM_VLFRET","EEM_VLSEGU","EEM_OUTROS","EEM_VLNF","EEM_CHVNFE"}
Local aFieldsEES := {"EES_PEDIDO","EES_SEQUEN","EES_FATSEQ","EES_COD_I","EES_QTDE",;
                     "EES_VLMERM","EES_VLFREM","EES_VLSEGM","EES_VLOUTM","EES_VLNFM",;
                     "EES_NR_CON","EES_VLMERC","EES_VLFRET","EES_VLSEGU","EES_VLOUTR","EES_VLNF"}                                   //NCF - 29/04/2015
Local aGrupos := {{'GRUPO01', STR0030 , '', 1 ,{"EEM_NRNF","EEM_SERIE","EEM_DTNF","EEM_TIPONF","EEM_CF","EEM_CNPJ","EEM_PREEMB"}},;
                  {'GRUPO02', STR0031 , '', 1 ,{"EEM_VLMERM","EEM_VLFREM","EEM_VLSEGM","EEM_OUTROM","EEM_VLNFM","EEM_TXTB","EEM_TXFRET","EEM_TXSEGU","EEM_TXOUDE"},;
                  {'GRUPO03', STR0032 , '', 1 ,{"EEM_VLMERC","EEM_VLFRET","EEM_VLSEGU","EEM_OUTROS","EEM_VLNF"}}}}
Local aRelacao := {{"EES_FILIAL","xFilial('EEM')"},;
                   {"EES_PREEMB","EEM_PREEMB"},;
                   {"EES_NRNF","EEM_NRNF"},;
                   {"EES_SERIE","EEM_SERIE"}}
                   
aAdd(aDados,{"ORDEM_EEM",aFieldsEEM})
aAdd(aDados,{"ORDEM_EES",aFieldsEES})
aAdd(aDados,{"GRUPO",aGrupos})
aAdd(aDados,{"RELACAO",aRelacao})

Return aClone(aDados)

/*
Programa  : SetGrupo
Objetivo  : Setar o grupo
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      : 
*/
Static Function SetRemove(oStruct,aCampos)
Local i := 0

For i := 1 To Len(aCampos)
   oStruct:RemoveField(aCampos[i])
Next

Return oStruct
/*
Programa  : SetGrupo
Objetivo  : Setar o grupo
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      : 
*/
Static Function SetGrupo(oStruct,aGrupo)
Local i := 0
Local j := 0

Begin Sequence

   If Empty(aGrupo)
      Break
   EndIf
   
   For i := 1 To Len(aGrupo)
      oStruct:AddGroup( aGrupo[i][1], aGrupo[i][2], aGrupo[i][3], aGrupo[i][4])
      If ValType(aGrupo[i][5]) == "A"
         For j := 1 To Len(aGrupo[i][5])
            oStruct:SetProperty(aGrupo[i][5][j],MVC_VIEW_GROUP_NUMBER,aGrupo[i][1])
         Next
      EndIf
   Next

End Sequence

Return oStruct

/*
Programa  : SetStruct
Objetivo  : Setar a estrutura da view ou modelo
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      : 
*/
Static Function SetStruct(oStruct,aFields,lModel)
Local aCampos := oStruct:aFields
Local aRet := {}
Local nPos := 0
Local i := 0
Local aGatilhos := {}

Begin Sequence 

   If Empty(aCampos)
      Break
   Endif

   If lModel
      nPosCampo := 3
   Else
      nPosCampo := 1
   EndIf
 
   For i := 1 To Len(aFields)
      nPos := aScan(aCampos,{|X| AllTrim(Upper(X[nPosCampo])) == AllTrim(Upper(aFields[i]))})
      If nPos > 0
         If !lModel
            aCampos[nPos][2] := If( i < 10 ,"0"+AllTrim(Str(i)),AllTrim(Str(i)) )
         EndIf
         aAdd(aRet,aCampos[nPos])
         aDel(aCampos,nPos)
         aSize(aCampos,Len(aCampos)-1)
      EndIf
   Next

   For i := 1 To Len(aCampos)
      If !lModel
         aCampos[i][2] := If( Len(aFields)+i < 10 ,"0"+AllTrim(Str(Len(aFields)+i)),AllTrim(Str(Len(aFields)+i)) )
      EndIf
      aAdd(aRet,aCampos[i])
   Next

   oStruct:aFields := aClone(aRet)
   
End Sequence

Return oStruct

/*
Programa   : NF400Emb
Objetivo   : Seleção de embarque.
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function NF400Emb(oMdl)
Local cPreemb := ""         
Local oMdlField := oMdl:GetModel():GetModel("EEMMASTER")
Local oMdlGride := oMdl:GetModel():GetModel("EESDETAIL")
Local i
Private cEvNFEmb := ""

Begin Sequence
      //NCF - 04/11/2014
   If /*EEM->EEM_TIPONF*/oMdl:GetModel():GetValue("EEMMASTER","EEM_TIPONF" ) <> "2" 
      MsgAlert("Opção válida apenas para Notas Complementares!","Aviso")
      Break
   Else
      If oMdl:GetOperation() <> 4
         MsgAlert("Opção válida apenas em modo de alteração!","Aviso")
         Break         
      EndIf
   EndIf
      //NCF - 04/11/2014   
   If /*!Empty(EEM->EEM_PREEMB)*/ !Empty(oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB" ))
      If MsgYesNo("Esta Nota já está vinculada a um processo! "+;
                  "Deseja desfazer esta vinculação?","Aviso")
         cPreemb := Avkey("","EEM_PREEMB")
         
      Else
         Break
      EndIf     
   Else
      cPreemb := NF400EscEmb()
   EndIf 
   /*
   If Empty(cPreemb) .And. !lDesvNFEMB
      Break
   EndIf
   */
   If !NF400IsNFC(oMdl,cPreemb,"EESDETAIL")
      //If Len(oMdl:GetModel():GetModel("EESDETAIL"):aCols) > 0
         DelRegistro(oMdl,cPreemb,"EESDETAIL")
      //EndIf
      AddRegistro(oMdl,cPreemb)
   Else
      //NCF - 05/05/2014 - Gravar embarque nos itens da NF Comp. inclusos junto a própria
      For i := 1 To oMdlGride:GetQtdLine()
         oMdlGride:GoLine(i)
         If !oMdlGride:isDeleted()
            oMdlGride:LoadValue("EES_PREEMB",cPreemb) //NCF - 05/05/2014 - força a gravação pois o campo é chave para NF de saída     
         EndIf
      Next   
   EndIf
   
   If (nPos := aScan(oMdlField:aDataModel[1],{|X| AllTrim(Upper(X[1])) == "EEM_PREEMB" })) > 0
      //oMdlField:aDataModel[1][nPos][2] := AvKey(cPreemb,"EEM_PREEMB")
      oMdlField:LoadValue("EEM_PREEMB",cPreemb) 
   EndIf

End Sequence

Return nil

/*
Programa   : NF400EscEmb
Objetivo   : Tela de seleção de embarque.
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function NF400EscEmb()
Local nOrd := EEC->(IndexOrd())
Local nRecno := EEC->(Recno())
Local cPreemb := AvKey("","EEC_PREEMB")   
Local nInferior := 200
Local nDireita := 380
Local nLin := 4
Local nCol := 2
Local oDlg
Local lRet := .F.
Local bOk := {|| lRet := NF400VldEmb(cPreemb), If(lRet,oDlg:End(),nil)}
Local bCancel := {|| lRet := .F., oDlg:End()}

Begin Sequence

   Define MsDialog oDlg Title STR0029 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd 
 	  @ nLin   ,nCol SAY STR0028
      @ nLin++ ,nCol+6 MSGET cPreemb SIZE 100,08 OF oDlg F3 "EECA"
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   
   /*If lRet
      If !Empty(cPreemb)
         cPreemb := EEC->EEC_PREEMB
      EndIf
   EndIf*/

   EEC->(DbSetOrder(nOrd))
   EEC->(DbGoTo(nRecno))
   
End Sequence

Return cPreemb

/*
Programa   : NF400VldEmb
Objetivo   : TValidar se o embarque existe.
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function NF400VldEmb(cPreemb)
Local lRet := .T.

   Begin Sequence   
   
      DO CASE
         CASE !Empty(cPreemb) .And. Empty(EEM->EEM_PREEMB)
            cEvNFEmb := "03"  //Vincula
         CASE Empty(cPreemb) .And. !Empty(EEM->EEM_PREEMB)
            cEvNFEmb := "05"  //Desvincula
         CASE AvKey(cPreemb,"EEM_PREEMB") <> EEM->EEM_PREEMB
            cEvNFEmb := "04"  //Altera o vínculo
         OTHERWISE
            Break
      ENDCASE
      
      If cEvNFEmb $ "03/04" 
         EEC->(DbSetOrder(1)) // EEC_FILIAL+EEC_PREEMB
         If !EEC->(DbSeek(xFilial("EEC")+AvKey(cPreemb,"EEM_PREEMB")))
            EasyHelp(STR0011,STR0009) //"O processo de embarque não cadastrado."
            lRet := .F.
         EndIf
      Else
         If cEvNFEmb == "05" 
            If !MsgYesNo(STR0046) //"Deseja desvincular o embarque desta Nota?"
               lRet := .F.
            EndIf
         Else
            lRet := .F.
         EndIf
      EndIf   
   End Sequence

Return lRet

/*
Programa   : NF400COMMIT
Objetivo   : Gravação das tabelas EEM e EES
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function NF400COMMIT(oMdl)
Local cPreemb := oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB" )
Local cTipoCa := oMdl:GetModel():GetValue("EEMMASTER","EEM_TIPOCA" )
Local cTipoNf := oMdl:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )
Local cNOTA  := oMdl:GetModel():GetValue("EEMMASTER","EEM_NRNF" )

//RMD - 25/02/15 - Projeto Chave NF
Local cSerie   := oMdl:GetModel():GetValue("EEMMASTER","EEM_SERIE" )
Local cCNPJ    := oMdl:GetModel():GetValue("EEMMASTER","EEM_CNPJ" )

Local nOrd   := EEM->(IndexOrd())
Local nRecno := EEM->(Recno())
Local lFailDevIt := .F.
Local lLock, i
Local cMsgDevIt := ""

Begin Transaction  

   /*
   If oMdl:GetOperation() == 5
      If !Empty(cPreemb)
         If EasyGParam("MV_EEC_ECO",,.F.)
            AE100EstCon("ESTORNA_NF",cPreemb)
         EndIf
      EndIf
   EndIf
   */
   
   FWFormCommit(oMdl)
   
   //*** RMD - 25/02/15 - Projeto Chave NF
   If oMdl:GetOperation() == 3
      EEM->(DbSetOrder(3))//EEM_FILIAL+EEM_CNPJ+EEM_NRNF+EEM_SERIE
      If EEM->(DbSeek(xFilial("EEM")+AvKey(cCNPJ,"EEM_CNPJ")+AvKey(cNota,"EEM_NRNF")+AvKey(cSerie,"EEM_SERIE")))
         EEM->(RecLock("EEM", .F.))
         SerieNfId("EEM",1,"EEM_SERIE",EEM->EEM_DTNF,EEM->EEM_MODNF,EEM->EEM_SERIE)
         EEM->(MsUnlock())
         
         EES->(DbSetOrder(3))
         EES->(DbSeek(xFilial()+AvKey(cCNPJ,"EES_CNPJ")+AvKey(cNota,"EES_NRNF")+AvKey(cSerie,"EES_SERIE")))
         While EES->(!Eof() .And. EES_FILIAL+EES_CNPJ+EES_NRNF+EES_SERIE == xFilial()+AvKey(cCNPJ,"EES_CNPJ")+AvKey(cNota,"EES_NRNF")+AvKey(cSerie,"EES_SERIE"))
            EES->(RecLock("EES", .F.))
            SerieNfId("EES",1,"EES_SERIE",EEM->EEM_DTNF,EEM->EEM_MODNF,EES->EES_SERIE)
            EES->(MsUnlock())
            EES->(DbSkip())
         EndDo
      EndIf
   EndIf
   //***

   If oMdl:GetOperation() <> 5
      EEM->(DbSetOrder(1))
      If EEM->(DbSeek(xFilial("EEM")+AvKey(cPreemb,"EEM_PREEMB")+AvKey(cTipoCa,"EEM_TIPOCA")+AvKey(cNOTA,"EEM_NRNF")+AvKey(cTipoNf,"EEM_TIPONF")))
         EEM->(RecLock("EEM",.F.))
         EEM->EEM_TIPOCA := EEM_NF
         EEM->(MsUnLock())
      EndIf
/*    //NCF - 04/11/2014  
      If !lNF400Auto //.And. IsInCallStack("NF400Emb")                                                                             //NCF - 07/05/2014 - Ajuste para não impactar a integração de NF complementar.
         EEM->(DbSetOrder(nOrd))
         EEM->(DbGoto(nRecno))
         If EEM->EEM_TIPONF == '2' .And. NF400IsNFC(oMdl,"","EESDETAIL") .And. EEM->EEM_PREEMB <> AllTrim(oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB")) 
            EEM->(RecLock("EEM",.F.))                                                                                            //NCF - 17/04/2014 - No cliente Tanac o lock está sendo exigido.
            EEM->EEM_PREEMB := AvKey( oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB") ,"EEM_PREEMB")
            EEM->(MsUnLock())                 
         EndIf
      EndIf
*/      
      //Verifica se houve devolução total de item de nota vinculada a embarque
      /*
      EES->(DbSetOrder(1))
      EE9->(DbSetOrder(2))
      EES->(DbSeek(xFilial()+cPreemb+AvKey(cNOTA,"EES_NRNF")))
      While EES->(!Eof() .And. xFilial("EES")+cPreemb+AvKey(cNOTA,"EES_NRNF") == EES_FILIAL+EES_PREEMB+EES_NRNF)
         If EES->EES_QTDE == 0 
            If EE9->(DbSeek(xFilial("EE9")+EES->(EES_PREEMB+EES_PEDIDO+EES_SEQUEN)))
               Do While EE9->(!Eof()) .and. EE9->EE9_FILIAL == xFilial("EE9") .And. EE9->(EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN) == EES->(EES_PREEMB+EES_PEDIDO+EES_SEQUEN)  
                  //Desvincula a Nota do item do embarque quando a quantidade a devolução for total
                  If AvKey(EE9->EE9_NF,"EES_PREEMB") == EES->EES_NRNF .And. AvKey(EE9->EE9_SERIE,"EES_SERIE") == EES->EES_SERIE
         	         If EE9->(RecLock("EE9", .F.))
         		        EE9->EE9_NF    := ""
         		        EE9->EE9_SERIE := ""
         	            EE9->(MsUnlock())
            	     EndIf
            	  EndIf   
                  EE9->(DbSkip())
               EndDo
            EndIf	
         EndIf
         EES->(DbSkip())
      EndDo
      */
      If Len(aItensDev) > 0
         Begin Sequence
            If ChkFile("EEC") .And. ChkFile("EE9")
                  i:=1 //For i:=1 to Len(aItensDev)
                  If !Empty(aItensDev[i][2])
                     EEC->(DbSetOrder(1))
                     EEC->(DbSeek(xFilial("EEC")+AvKey(aItensDev[i][2],"EEC_PREEMB")))
                  
                     If !(lLock := EEC->(IsLocked()))
                        RecLock("EEC",.F.)
                        aRetorno := DesNfItEmb(aItensDev[i])
                        DesNfItRem(AvKey(aItensDev[i][2],"EYY_PREEMB"),cTipoCa,cNota,cSerie,cTipoNf,cCNPJ) //THTS - 30/11/2017 - Desvincula todas as notas do Embarque
                        cMsgDevIt+= aRetorno[2]
                        If !aRetorno[1]
                           lFailDevIt := .T.
                           Break
                        EndIf
                     Else
                        cMsgDevIt := "Não foi possível desvincular as Notas fiscais dos itens, pois o processo de embarque: "+ aItensDev[i][2] +;
                                     "está em uso por outro usuário do sistema."
                        lFailDevIt := .T.
                        Break                 
                     EndIf
                                   
                     If !lLock
                        EEC->(MsUnLock())
                     EndIf                    
                  EndIf
               //Next i
            EndIf
         End Sequence
         
         If InTransaction() .And. lFailDevIt
            DisarmTransaction()
            EECView(cMsgDevIt,"Falha no Processamento!")
         Else
            EECView(cMsgDevIt,"Log do Processamento")
         EndIf 
          
      EndIf
      
   EndIf
   
   EEM->(DbSetOrder(nOrd))
   
End Transaction 
If( Type("aItensDev")=='A', aItensDev:={} , )
Return .T.

/*
Programa   : AddRegistro
Objetivo   : Adiciona registro na grid
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function AddRegistro(oModel,xInfo)
Local lRet := .T.
Local oMdlGride := oModel:GetModel("EESDETAIL")
Local nOrd := EE9->(IndexOrd())
Local nRecno := EE9->(Recno())

Begin Sequence

    oMdlGride:GoLine(1)
    EE9->(DbSetOrder(3)) //EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
    EE9->(DBSeek(xFilial("EE9")+AvKey(xInfo,"EE9_PREEMB")))
    Do While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9") .And. EE9->EE9_PREEMB == AvKey(xInfo,"EE9_PREEMB"))
       //oMdlGride:AddLine()
       ForceAddLine(oMdlGride)
       oMdlGride:LoadValue("EES_PREEMB",EE9->EE9_PREEMB)
       If NF400IsNFC(oMdlGride,"","EESDETAIL")
          oMdlGride:LoadValue("EES_PEDIDO",AvKey("0","EES_PEDIDO"))
       Else 
          oMdlGride:LoadValue("EES_PEDIDO",EE9->EE9_PEDIDO)
       EndIf 
       oMdlGride:LoadValue("EES_SEQUEN",EE9->EE9_SEQUEN)       
       oMdlGride:LoadValue("EES_COD_I",EE9->EE9_COD_I)
       oMdlGride:LoadValue("EES_QTDE",EE9->EE9_SLDINI)
       EE9->(DbSkip())
    EndDo
    
    oMdlGride:GoLine(1)
    oMdlGride:DeleteLine()    //NCF - 22/04/2014 - Apagar a primeira linha em branco para não ser validada
    EE9->(DbSetOrder(nOrd))
    EE9->(DbGoTo(nRecno))

End Sequence

Return lRet

/*
Programa   : DelRegistro
Objetivo   : Deleta registro na grid
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function DelRegistro(oModel,cPreemb,cIdGride)
Local lRet := .T.
Local oMdlGride := oModel:GetModel():GetModel(cIdGride)
Local i := 0

Begin Sequence

   aSize(oMdlGride:aDataModel,1)
   aSize(oMdlGride:aCols,1)
   For i := 1 To Len(oMdlGride:aDataModel[1][1][1])
      If ValType(oMdlGride:aDataModel[1][1][1][i]) == "C"
         oMdlGride:aDataModel[1][1][1][i] := Space(Len(oMdlGride:aDataModel[1][1][1][i]))
         //oMdlGride:aCols[1][i] := Space(Len(oMdlGride:aDataModel[1][1][1][i]))
      ElseIf ValType(oMdlGride:aDataModel[1][1][1][i]) == "D"
         oMdlGride:aDataModel[1][1][1][i] := cToD("")
         //oMdlGride:aCols[1][i] := cToD("")
      ElseIf ValType(oMdlGride:aDataModel[1][1][1][i]) == "N"
         oMdlGride:aDataModel[1][1][1][i] := 0
         //oMdlGride:aCols[1][i] := 0
      ElseIf ValType(oMdlGride:aDataModel[1][1][1][i]) == "L"
         oMdlGride:aDataModel[1][1][1][i] := .F.      
         //oMdlGride:aCols[1][i] := .F.
      EndIf
      If i < (Len(oMdlGride:aDataModel[1][1][1])-1)
         oMdlGride:aDataModel[1][1][2][i] := .F.      
      EndIf
   Next
   oMdlGride:aDataModel[1][2] := .F.
   oMdlGride:aDataModel[1][3] := .F.
   oMdlGride:aDataModel[1][5] := {}
   oMdlGride:aDataModel[1][6] := .F.

End Sequence

Return lRet

/*
Programa   : NF400CalcVal
Objetivo   : Validação da somatória dos valores dos campos: EES_VLNF, EES_VLNFM, EES_VLFRET, 
             EES_VLFREM, EES_VLSEGU, EES_VLSEGM, EES_VLOUTR, EES_VLOUTM
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function NF400CalcVal(oMdl)
Local lRet := .F.
Local nSomaItReais  := 0
Local nSomaItMoeda  := 0
Local nSomaFrReais  := 0
Local nSomaFrMoeda  := 0
Local nSomaSeReais  := 0
Local nSomaSeMoeda  := 0
Local nSomaOuDReais := 0
Local nSomaOuDMoeda := 0
Local nSomaDesc     := 0
Local nQtdRemes     := 0 //THTS - 29//11/2017 - Tratamento de Devolucao de NF
Local i := 0
Local nY
Local oMdlGride := oMdl:GetModel():GetModel("EESDETAIL")
Local oMdlRemes := oMdl:GetModel():GetModel("EYYDETAIL")
Local nOpc := oMdl:GetOperation()
Local nQtdeLinEES

Begin Sequence

   If oMdl:GetOperation() == 5
      nOrd   := EEM->(IndexOrd())
      nRecno := EEM->(Recno())
      If AVFlags("EEC_LOGIX")
         EEM->(DbSetOrder(4))
         If EEM->(DbSeek(xFilial("EEM")+oMdl:GetModel():GetValue("EEMMASTER","EEM_NRNF" )+oMdl:GetModel():GetValue("EEMMASTER","EEM_SERIE" )+AvKey("N","EEM_TIPOCA")+oMdl:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )))
            If !Empty(EEM->EEM_PREEMB)
               EasyHelp('A Nota Fiscal No.: '+Alltrim(EEM->EEM_NRNF)+' Serie: '+Alltrim(EEM->EEM_SERIE)+' esta vinculada ao processo de embarque: '+Alltrim(EEM->EEM_PREEMB)+' e por isso nao pode ser cancelada!' ,STR0009)
               EEM->(DbSetOrder(nOrd))
               EEM->(DbGoTo(nRecno))
               Break
            EndIf   
         EndIf
      EndIf
      EEM->(DbSetOrder(nOrd))
      EEM->(DbGoTo(nRecno))
   EndIf
      
   If !NF400IsNFC(oMdl,"","EESDETAIL")

      For i := 1 To oMdlGride:GetQtdLine()
         oMdlGride:GoLine(i)
         If !oMdlGride:isDeleted()
            nSomaItReais  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLNF")
            nSomaItMoeda  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLNFM")
            nSomaFrReais  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLFRET")
            nSomaFrMoeda  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLFREM")
            nSomaSeReais  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLSEGU")
            nSomaSeMoeda  += oMdl:GetModel():GetValue("EESDETAIL","EES_VLSEGM")
            nSomaOuDReais += oMdl:GetModel():GetValue("EESDETAIL","EES_VLOUTR")
            nSomaOuDMoeda += oMdl:GetModel():GetValue("EESDETAIL","EES_VLOUTM")
            nSomaDesc     += oMdl:GetModel():GetValue("EESDETAIL","EES_DESCON")

            //THTS - 29/11/2017 - Tratamento de Devolucao de NF
            If !oMdlRemes:IsEmpty() .And. lHasItRem(oMdlRemes)//Existe remessa para o Item
                For nY := 1 To oMdlRemes:GetQtdLine()
                    oMdlRemes:GoLine(nY)
                    If !oMdlRemes:IsDeleted()
                        nQtdRemes += oMdl:GetModel():GetValue("EYYDETAIL","EYY_QUANT")
                    EndIf
                Next
                If (nQtdeLinEES := EESSumQtd(oMdlGride,oMdlGride:GetLine()) ) > 0 .And. nQtdeLinEES <> nQtdRemes //A quantidade ja foi subtraida a quantidade devolvida
                    EasyHelp(STR0038 + Alltrim(Str(i)) + STR0039 + ; //"Divergência entre a quantidade do item #### da Nota Fiscal e a quantidade das Notas de Remessa."
                             STR0040 + Alltrim(Str(  nQtdeLinEES )) +" e "+; //Quantidade no Item:
                             STR0041 + Alltrim(Str(nQtdRemes)) +")",STR0009) //Quantidade na Remessa:
                    Break
                EndIf
                nQtdRemes := 0
            EndIf
         EndIf
      Next 
      If EasyGParam("MV_AVG0102",,.T.)

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_VLFRET") <> nSomaFrReais  
                EasyHelp(STR0020,STR0009) //"Divergência entre capa e itens no Frete R$."
                Break
            EndIf

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_VLFREM") <> nSomaFrMoeda  
                EasyHelp(STR0021,STR0009) //"Divergência entre capa e itens no Frete na Moeda."
                Break
            EndIf

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_VLSEGU") <> nSomaSeReais 
                EasyHelp(STR0022,STR0009) //"Divergência entre capa e itens no Seguro R$."
                Break
            EndIf

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_VLSEGM") <> nSomaSeMoeda  
                EasyHelp(STR0023,STR0009) //"Divergência entre capa e itens no Seguro na Moeda."
                Break
            EndIf

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_OUTROS") <> nSomaOuDReais 
                EasyHelp(STR0024,STR0009) //"Divergência entre capa e itens no Total outras Desp. R$."
                Break
            EndIf
        
            If oMdl:GetModel():GetValue("EEMMASTER","EEM_OUTROM") <> nSomaOuDMoeda  
                EasyHelp(STR0025,STR0009) //"Divergência entre capa e itens no Total outras Desp. na Moeda."
                Break
            EndIf
        
            If (oMdl:GetModel():GetValue("EEMMASTER","EEM_VLNF") - nSomaDesc) <> nSomaItReais
                EasyHelp(STR0026,STR0009)//"Divergência entre capa e itens no Valor da NF R$." 
                Break
            EndIf

            If oMdl:GetModel():GetValue("EEMMASTER","EEM_VLNFM") <> nSomaItMoeda
                EasyHelp(STR0027,STR0009)//"Divergência entre capa e itens no Valor da NF na Moeda." 
                Break
            EndIf
        
            If nOpc == 5
                If !Empty(oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB"))
                    EasyHelp(STR0036 + AllTrim(oMdl:GetModel():GetValue("EEMMASTER","EEM_PREEMB")) + STR0037,STR0009)
                    Break   
                EndIf
            EndIf   

      EndIf
   EndIf
   oMdlGride:GoLine(1)
   lRet := .T. 
   
End Sequence

Return lRet

/*
Programa   : NF400Valid
Objetivo   : Validação de campos da tabela EEM e EES
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Function NF400Valid(cCampo)
Local lRet := .F.
Local oModel := FWModelActive()
//Local cCampo := AllTrim(Upper(ReadVar()))
Local xInfo := ""
Local nOrd := 0
Local nRecno := 0
Local nTotal := 0
Local cPedido := "" 
Local nFrete  := 0
Local nSeguro := 0
Local nVlMerc := 0
Local nVlOutr := 0
Local nVlDesc := 0
Local cPreemb := ""
Local cTipoCa := ""
Local cTipoNf := ""
Local aOrdEEM
Default cCampo := AllTrim(Upper(ReadVar()))

Begin Sequence

   If Valtype(oModel) <> "O"
      lRet := .T.  // GFP - 30/01/2014
      Break
   EndIf

   xInfo := &(cCampo)
   cCampo := SubStr(cCampo,At(">",cCampo)+1,Len(cCampo))

   Do Case
      // Campos da EEM
      Case cCampo == "EEM_NRNF"
         If oModel:GetOperation() == 3
            nOrd := EEM->(IndexOrd())
            nRecno := EEM->(Recno())
            EEM->(DbSetOrder(1)) // EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA+EEM_NRNF+EEM_TIPONF
            cPreemb := oModel:GetModel():GetValue("EEMMASTER","EEM_PREEMB" )
            cTipoCa := oModel:GetModel():GetValue("EEMMASTER","EEM_TIPOCA" )
            cTipoNf := oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )
            If EEM->(DbSeek(xFilial("EEC")+AvKey(cPreemb,"EEM_PREEMB")+AvKey(cTipoCa,"EEM_TIPOCA")+AvKey(xInfo,"EEM_NRNF")+AvKey(cTipoNf,"EEM_TIPONF")))
               EasyHelp(STR0010,STR0009) // "O número da nota ja cadatrada no sistema.","Atenção"
               Break
            EndIf
            If AvFlags("EEC_LOGIX") .And. !Empty(oModel:GetModel():GetValue("EEMMASTER","EEM_SERIE")) //NCF - 16/05/2014 - Quando integrado ao Logix, não permitir lançamento de Notas já lançadas porém não vinculadas a embarques.
               aOrdEEM := SaveOrd("EEM")
               EEM->(DbSetOrder(4)) // EEM_FILIAL+EEM_NRNF+EEM_SERIE+EEM_TIPOCA+EEM_TIPONF
               //If EEM->(DbSeek(xFilial("EEM")+oModel:GetModel():GetValue("EEMMASTER","EEM_PREEMB" )+AvKey("N","EEM_TIPOCA")+oModel:GetModel():GetValue("EEMMASTER","EEM_NRNF" )+oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )))
               If EEM->(DbSeek(xFilial("EEM")+oModel:GetModel():GetValue("EEMMASTER","EEM_NRNF" )+oModel:GetModel():GetValue("EEMMASTER","EEM_SERIE" )+AvKey("N","EEM_TIPOCA")+oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )))   
                  EasyHelp(STR0010,STR0009)
                  Break   
               EndIf
               RestOrd(aOrdEEM)
            EndIf
            EEM->(DbSetOrder(nOrd))
            EEM->(DbGoTo(nRecno))
         EndIf
      
      Case cCampo == "EEM_SERIE" //MCF - 22/10/2015
         If oModel:GetOperation() == 3 .And. AvFlags("EEC_LOGIX")
            aOrdEEM := SaveOrd("EEM")
            EEM->(DbSetOrder(4)) // EEM_FILIAL+EEM_NRNF+EEM_SERIE+EEM_TIPOCA+EEM_TIPONF
            If EEM->(DbSeek(xFilial("EEM")+oModel:GetModel():GetValue("EEMMASTER","EEM_NRNF" )+oModel:GetModel():GetValue("EEMMASTER","EEM_SERIE" )+AvKey("N","EEM_TIPOCA")+oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )))
               EasyHelp(STR0010,STR0009)
               Break
            EndIf
            RestOrd(aOrdEEM)
         EndIf
                
      Case cCampo == "EEM_VLNF"
         If EasyGParam("MV_AVG0102",,.T.)
            nFrete  := oModel:GetModel():GetValue("EEMMASTER","EEM_VLFRET")
            nSeguro := oModel:GetModel():GetValue("EEMMASTER","EEM_VLSEGU")
            nVlMerc := oModel:GetModel():GetValue("EEMMASTER","EEM_VLMERC")
            nVlOutr := oModel:GetModel():GetValue("EEMMASTER","EEM_OUTROS")
            nVlDesc := oModel:GetModel():GetValue("EEMMASTER","EEM_DESCON")
            nTotal := nFrete + nSeguro + nVlMerc + nVlOutr - nVlDesc
            If nTotal <> xInfo
               EasyHelp(STR0013,STR0009) //"O total da NF não confere com a soma dos valores de mercadoria, valor do frete, valor do seguro e outros."
               Break
            EndIf
         EndIf
	
     Case cCampo == "EEM_CNPJ"
         nOrd := SA2->(IndexOrd())
         nRecno := SA2->(Recno())
         SA2->(DbSetOrder(3))
         If !SA2->(DbSeek(xFilial("SA2")+AvKey(xInfo,"EEM_CNPJ")))
            EasyHelp(STR0015,STR0009) //"O CNPJ informado não contem no cadastro de Fornecedores/Exportadores."
            Break
         EndIf
         SA2->(DbSetOrder(nOrd))
         SA2->(DbGoTo(nRecno))
         
      // Campos da EES
      Case cCampo == "EES_VLNF"
         If EasyGParam("MV_AVG0102",,.T.)
            nFrete  := oModel:GetModel():GetValue("EESDETAIL","EES_VLFRET" )
            nSeguro := oModel:GetModel():GetValue("EESDETAIL","EES_VLSEGU" )
            nVlMerc := oModel:GetModel():GetValue("EESDETAIL","EES_VLMERC" )
            nVlOutr := oModel:GetModel():GetValue("EESDETAIL","EES_VLOUTR" )
            nVlDesc := oModel:GetModel():GetValue("EESDETAIL","EES_DESCON")
            nTotal := nFrete + nSeguro + nVlMerc + nVlOutr - nVlDesc
            If nTotal <> xInfo
               EasyHelp(STR0017,STR0009) //"O total do item da NF não confere com a soma dos valores de mercadoria, valor do frete, valor do seguro e outros."
               Break
            EndIf
         EndIf
      Case cCampo == "EES_PREEMB"
         If !Empty(xInfo)
            nOrd := EEC->(IndexOrd())
            nRecno := EEC->(Recno())
            EEC->(DbSetOrder(1)) // EEC_FILIAL+EEC_PREEMB
            If !EEC->(DbSeek(xFilial("EE8")+AvKey(xInfo,"EEC_PREEMB")))
               EasyHelp(STR0035,STR0009) //"O embarque informado não existe."
               Break
            EndIf
            EEC->(DbSetOrder(nOrd))
            EEC->(DbGoTo(nRecno))
         EndIF

      Case cCampo == "EES_PEDIDO"
         If Alltrim(xInfo) <> "0" //NCF - 24/10/2013 - Código do Pedido = "0" => NF Complementar(integra com código de Pedido = "0")
            If !(oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" ) == '2')
               nOrd := EE8->(IndexOrd())
               nRecno := EE8->(Recno())
               EE8->(DbSetOrder(1)) // EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN+EE8_COD_I
               If !EE8->(DbSeek(xFilial("EE8")+AvKey(xInfo,"EES_PEDIDO")))
                  EasyHelp(STR0018,STR0009) //"O pedido informado não existe."
                  Break
               EndIf
               EE8->(DbSetOrder(nOrd))
               EE8->(DbGoTo(nRecno)) 
            Else
               If !lNF400Auto       //NCF - 05/11/2014                  
                  MsgAlert(STR0045) //'Para Nota Fiscal Complementar o Pedido deve ser informado com o código "0"!'
                  If Valtype(M->EES_PEDIDO) == 'C'
                     M->EES_PEDIDO := '0'
                  EndIf
                  If Valtype(oModel:GetModel():GetModel("EESDETAIL")) == 'O'
                     oModel:GetModel():GetModel("EESDETAIL"):SetValue("EES_PEDIDO",'0')
                  EndIf
                  Break
               EndIf               
            EndIf                 
         EndIf
      Case cCampo == "EES_SEQUEN"
         If Alltrim(oModel:GetModel():GetValue("EESDETAIL","EES_PEDIDO" )) <> "0" //NCF - 24/10/2013 Sequencia do item no Pedido = "0" => NF Complementar(integra com número de Sequência do Pedido = "0")
            nOrd := EE8->(IndexOrd())
            nRecno := EE8->(Recno())
            EE8->(DbSetOrder(1)) // EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN+EE8_COD_I
            cPedido := oModel:GetModel():GetValue("EESDETAIL","EES_PEDIDO" )
            If !EE8->(DbSeek(xFilial("EE8")+AvKey(cPedido,"EES_PEDIDO")+AvKey(xInfo,"EES_SEQUEN")))
               EasyHelp(STR0019,STR0009) //"A sequencia do pedido informado não existe."
               Break
            EndIf
            EE8->(DbSetOrder(nOrd))
            EE8->(DbGoTo(nRecno))
         EndIf
      Case cCampo == "EEM_TIPONF"
         If oModel:GetOperation() == 3 .And. EasyGParam('MV_EECI010',,.F.) //NCF - 16/05/2014 - Quando integrado ao Logix, não permitir lançamento de Notas já lançadas porém não vinculadas a embarques.
            aOrdEEM := SaveOrd("EEM")
            EEM->(DbSetOrder(1))
            If EEM->(DbSeek(xFilial("EEM")+oModel:GetModel():GetValue("EEMMASTER","EEM_PREEMB" )+AvKey("N","EEM_TIPOCA")+oModel:GetModel():GetValue("EEMMASTER","EEM_NRNF" )+oModel:GetModel():GetValue("EEMMASTER","EEM_TIPONF" )))
               EasyHelp(STR0010,STR0009) 
               Break   
            EndIf
            RestOrd(aOrdEEM,.T.)
         EndIf
      Case cCampo == "EES_QTDDEV"
         If xInfo > oModel:GetModel():GetValue("EESDETAIL","EES_QTDORI")
            EasyHelp(STR0044,STR0009) //"Quantidade devolvida não pode ser maior que a quantidade original."
            Break
         EndIf
         
      Case cCampo == "EYY_QUANT" //THTS - 05/12/2017 - A quantidade do item de remessa nao pode ser zero
         If xInfo <= 0
            EasyHelp(STR0042 + Alltrim(Str(xInfo)) + STR0043,STR0009) //"Não é permitido informar a quantidade "#### " para o item de Remessa. Neste caso, a linha do item deve ser excluída."
            Break
         EndIf

      Case cCampo == "EK6_CLIENT"
         If Empty(oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT"))
            EasyHelp("Cód. Cliente não informado!") //Cód. Cliente não informado!
         Else
            If !ExistCpo("SA1", AvKey( oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT"),"A1_COD") , 1 ) 
               EasyHelp(STR0057+" '"+ oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT") + "'",STR0009) //Código do cliente inválido: Cliente
               Break
            EndIf   
         EndIf
         
      Case cCampo == "EK6_LOJACL"
         If Empty(oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT"))
            EasyHelp(STR0058,STR0009) //Cód. Cliente não informado!
            Break
         Else
            If !ExistCpo("SA1", AvKey( oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT"),"A1_COD" ) + AvKey( oModel:GetModel():GetValue("EK6DETAIL","EK6_LOJACL") ,"A1_LOJA" ), 1 )
               EasyHelp(STR0059+" '"+ oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT") + " Loja " + oModel:GetModel():GetValue("EK6DETAIL","EK6_LOJACL") + "'",STR0009) //Cód. da Loja inválida para este cliente: Cliente ####  Loja #####    
               Break
            Else
               If SA1->( dbsetorder(1), dbseek( xfilial() + oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT")+oModel:GetModel():GetValue("EK6DETAIL","EK6_LOJACL") ) ) .and. SA1->A1_MSBLQL == "1"
                  EasyHelp(STR0060+" '"+ oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT") + " Loja " + oModel:GetModel():GetValue("EK6DETAIL","EK6_LOJACL") + "'",STR0009) //Código de cliente/loja inativo/bloqueado: Cliente    
                  Break
               EndIf
            EndIf   
         EndIf

      Case cCampo == "EK6_COD_I"
         If !ExistCpo("SB1", AvKey( oModel:GetModel():GetValue("EK6DETAIL","EK6_COD_I"),"B1_COD" ), 1 )
            EasyHelp(STR0061+" '"+oModel:GetModel():GetValue("EK6DETAIL","EK6_COD_I")+"'",STR0009) //Código do produto inválido:
            Break
         EndIf

      Case cCampo == "EK6_UMNF"
         If !ExistCpo("SAH", AvKey( oModel:GetModel():GetValue("EK6DETAIL","EK6_UMNF"),"AH_UNIMED") )
            EasyHelp(STR0062+" '"+oModel:GetModel():GetValue("EK6DETAIL","EK6_UMNF")+"'",STR0009) //Unidade de medida inválida:
            Break
         EndIf

      Case cCampo == "EK6_CFOP"
         If !ExistCpo("SX5","13" + oModel:GetModel():GetValue("EK6DETAIL","EK6_CFOP"))
            EasyHelp(STR0063+" '"+oModel:GetModel():GetValue("EK6DETAIL","EK6_CFOP")+"'",STR0009) //CFOP Inválido:
            Break
         EndIf

      Case cCampo == "EK6_QUANT"
         If oModel:GetModel():GetValue("EK6DETAIL","EK6_QUANT") <= 0
            EasyHelp(STR0064,STR0009) //Quantidade vinculada não pode ser menor ou igual a zero !
            Break
         EndIf
         /*
         aEQtdEk6 := GetInfoEK6(1)
         If aEQtdEk6[2] > aEQtdEk6[1] //IF(EasyGParam("MV_EECFAT",,.F.),NF400QtSD2(SD2->D2_QUANT),aEQtdEk6[2]) > aEQtdEk6[1]
            EasyHelp(STR0065,STR0009)  //Quantidade vinculada somente nesta remessa ou somada às quantidades vinculadas nas outras remessas não pode ser maior que a quantidade do item na nota fiscal de exportação! 
            Break
         EndIf
         */
      Case cCampo == "EK6_CHVNFE"
         If Empty( oModel:GetModel():GetValue("EK6DETAIL","EK6_CHVNFE") )
            EasyHelp(STR0066,STR0009) //Chave eletrônica SEFAZ da nota de formação de lote de exportação vinculada deve ser informada!
            Break
         EndIf
      
      Case cCampo == "EK6_ITEM"
         cChvIteAtu := Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_NF"    )) + ;
                       Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_SERIE" )) + ;
                       Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_CLIENT")) + ;
                       Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_LOJACL")) + ;
                       Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_COD_I" )) + ;
                       Alltrim(oModel:GetModel():GetValue("EK6DETAIL","EK6_ITEM"  ))
         aEQtdEk6  := GetInfoEK6(2)
         If (nPos := aScan( aEQtdEk6 , cChvIteAtu ) ) > 0
            If nPos == oModel:GetModel('EK6DETAIL'):GetLine() 
               If nPos < oModel:GetModel('EK6DETAIL'):GetQtdLine() 
                  If (nPos2 := aScan( aEQtdEk6 , cChvIteAtu , nPos+1 ) ) > 0
                     EasyHelp(STR0067) //Este item da nota já foi vinculado anteriormente! Selecione outro item de nota fiscal para vincular!
                     Break
                  EndIf
               EndIf
            Else
               EasyHelp(STR0067) //Este item da nota já foi vinculado anteriormente! Selecione outro item de nota fiscal para vincular!
               Break               
            EndIf
         EndIf

   End Case

   lRet := .T.

End Sequence

Return lRet

/*
Programa   : NF400Gatilho
Objetivo   : Realizar o gatilho
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Function NF400Gatilho()
Local xRet   := ""
Local cCpo   := AllTrim(Upper(ReadVar()))
Local oModel := FWModelActive()
Local nOrd   := 0
Local nRecno := 0

Begin Sequence

   If ValType(oModel) <> "O"
      Break
   EndIf

   cCpo := SubStr(cCpo,At(">",cCpo)+1,Len(cCpo))
   Do Case
      Case "EES_SEQUEN" == cCpo
         nOrd := EE8->(IndexOrd())
         nRecno := EE8->(Recno())
         EE8->(DbSetOrder(1))
         If EE8->(DbSeek(xFilial("EE8")+AvKey(oModel:GetModel():GetValue("EESDETAIL","EES_PEDIDO"),"EE8_PEDIDO") + AvKey(M->EES_SEQUEN,"EE8_SEQUEN")))
            xRet := EE8->EE8_COD_I
         Else 
            If Alltrim(oModel:GetModel():GetValue("EESDETAIL","EES_PEDIDO" )) <> "0"    //NCF - 24/10/2013 Sequencia do item no Pedido = "0" => NF Complementar(integra com número de Sequência do Pedido = "0")
               EasyHelp(STR0019,STR0009)
            EndIf
         EndIf
         EE8->(DbSetOrder(nOrd))
         EE8->(DbGoTo(nRecno))
   
      // Gatilho para limpar os campos
      Case cCpo $ "EES_PEDIDO"
         Break

   End Case

End Sequence

Return xRet

/*
Programa   : FiltroEE8
Objetivo   : Realizar o filtro dos itens do pedido
Retorno    : Logico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 26/09/2011
Obs.       :
*/
Function FiltroEE8()
Local cFiltro := ""
Local oModel := FWModelActive()
Local cPedido := AvKey(oModel:GetModel():GetValue("EESDETAIL","EES_PEDIDO"),"EE8_PEDIDO")

cFiltro := "'" + AllTrim(Upper(cPedido)) + "' == AllTrim(Upper(EE8->EE8_PEDIDO))"

Return &(cFiltro)  

/*
Programa   : NF400IsNFC(oModel,cPreemb,cIdGride)
Parâmetros : oModel   -> Modelo Ativo
             cPreemb  -> Código do Prcesso de Embarque
             cIdGride -> Identificador do Gride
Objetivo   : Verificar se a Nota é complementar.
Retorno    : Logico
Autor      : Nilson César C. Filho
Data/Hora  : 24/10/2013
Obs.       :
*/
Function NF400IsNFC(oModel,cPreemb,cIdGride)

Local oMdlGride := oModel:GetModel():GetModel(cIdGride)
Local lIsNFComp := .F.
Local nPos_Ped := aScan(oMdlGride:aHeader,{|x|    Alltrim(UPPER(x[2]))  == "EES_PEDIDO"    } )
Local nPos_Seq := aScan(oMdlGride:aHeader,{|x|    Alltrim(UPPER(x[2]))  == "EES_SEQUEN"    } )
Local oCapaNF  := oModel:GetModel():GetModel("EEMMASTER")
Local i

//For i:= 1 To Len(oMdlGride:aCols)                   //NCF - 04/11/2014 - Verificr se na capa indica como NF Comp. (Inc. e Vinc. manual)
   //If Alltrim(oMdlGride:aCols[i][nPos_Ped]) == '0' .Or. If(!lNF400Auto .And. ValType(oCapaNF:aDataModel) == 'A', oCapaNF:aDataModel[1][aScan(oCapaNF:aDataModel[1],{|y|Alltrim(UPPER(y[1]))=="EEM_TIPONF"})][2] == '2',.F.)//.And. Alltrim(oMdlGride:aCols[i][nPos_Seq]) == '0'
   If Alltrim(oMdlGride:aDataModel[1][1][1][nPos_Ped]) == '0' .Or. If(!lNF400Auto .And. ValType(oCapaNF:aDataModel) == 'A', oCapaNF:aDataModel[1][aScan(oCapaNF:aDataModel[1],{|y|Alltrim(UPPER(y[1]))=="EEM_TIPONF"})][2] == '2',.F.)
      lIsNFComp := .T.
      //EXIT
   EndIf 
//Next i

Return lIsNFComp

/*
Programa   : NF400Info(cInfo)
Parâmetros : 
Objetivo   : 
Retorno    :
Autor      : Nilson César C. Filho
Data/Hora  : 
Obs.       :
*/
Function NF400Info(cInfo)

Local oModel, oModelEEM, oModelEES
Local xRet 
Local aRetorno
Default cInfo := ""

If Substr(cInfo,1,3) == "EEM"
   oModel    := FWModelActive()
   oModelEEM := oModel:GetModel("EEMMASTER")
EndIf

If Substr(cInfo,1,3) == "EES"
   oModel    := FWModelActive()
   oModelEES := oModel:GetModel("EESDETAIL")
EndIf 

Do Case 

   Case cInfo == "EES_QTDDEV"

      nPosItDev := aScan(aItensDev, {|x|   x[1] ==  oModelEES:GetValue("EES_FILIAL") .and. ;
                                           x[2] ==  oModelEES:GetValue("EES_PREEMB") .and. ;
                                           x[3] ==  oModelEES:GetValue("EES_COD_I")  .and. ;
                                           x[4] ==  oModelEES:GetValue("EES_PEDIDO") .and. ;
                                           x[5] ==  oModelEES:GetValue("EES_SEQUEN")        })
                                           
      If !Empty(oModelEES:GetValue("EES_PREEMB")) .And. oModelEES:GetValue("EES_QTDDEV") <= oModelEES:GetValue("EES_QTDORI") //THTS - 28//11/2017
         If nPosItDev == 0
            If MsgYesNo("Confirma a devolução de quantidade deste item nesta Nota?"            +CHR(13)+CHR(10)+;
                        "Se SIM, o sistema irá desvincular dos itens no embarque todas notas " +CHR(13)+CHR(10)+;
                        "fiscais que faturam seu saldo e restaurar a quantidade original "     +CHR(13)+CHR(10)+;
                        "selecionada do Pedido para possibilitar a re-comparação "             +CHR(13)+CHR(10)+;
                        "de Notas x embarque onde ocorrerá o reajuste dos saldos faturados."   +CHR(13)+CHR(10)+;
                        "O vínculo entre estas notas e o embarque será mantido!" ,"ATENCAO")    

               aAdd(aItensDev , { oModelEES:GetValue("EES_FILIAL"),;
                                  oModelEES:GetValue("EES_PREEMB"),;
                                  oModelEES:GetValue("EES_COD_I" ),;
                                  oModelEES:GetValue("EES_PEDIDO"),;
                                  oModelEES:GetValue("EES_SEQUEN"),;
                                  oModelEES:GetValue("EES_QTDE"),;                                                                
                                  oModelEES:GetValue("EES_QTDDEV") } )
                                  
               xRet := oModelEES:GetValue("EES_QTDORI") - oModelEES:GetValue("EES_QTDDEV") 
            Else
               xRet := oModelEES:GetValue("EES_QTDORI")
               oModel:GetModel():GetModel("EESDETAIL"):SetValue("EES_QTDDEV",  0) 
            EndIf        
         Else
            aItensDev[nPosItDev][6] := oModelEES:GetValue("EES_QTDE")
            aItensDev[nPosItDev][7] := oModelEES:GetValue("EES_QTDDEV")
			xRet := oModelEES:GetValue("EES_QTDORI") - oModelEES:GetValue("EES_QTDDEV")
         EndIf     
         //xRet := oModelEES:GetValue("EES_QTDORI") - oModelEES:GetValue("EES_QTDDEV")          
      Else      
         If nPosItDev > 0 
            aDel( aItensDev, nPosItDev )
            aSize( aItensDev, Len(aItensDev) -1 ) 
         EndIf
         xRet := oModelEES:GetValue("EES_QTDORI") - oModelEES:GetValue("EES_QTDDEV")               
      EndIf
      
   Case cInfo == "EES_QTDE"
      If oModelEES:GetValue("EES_QTDORI") == 0 
         xRet := oModelEES:GetValue("EES_QTDE")
      Else
         xRet := oModelEES:GetValue("EES_QTDORI")
      EndIf         
	  
   Case cInfo == "EES_VALDEV"
	  xRet := oModelEES:GetValue("EES_QTDDEV") * oModelEES:GetValue("EES_VLMERC") / oModelEES:GetValue("EES_QTDORI")
	  
EndCase

Return xRet  

Static Function ForceAddLine(oModelGrid)
Local lDel := .F.

If oModelGrid:Length() >= oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If !oModelGrid:IsDeleted()
      oModelGrid:DeleteLine()
      lDel := .T.
   EndIf
   oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If lDel
      oModelGrid:UnDeleteLine()
   EndIf
   oModelGrid:GoLine(oModelGrid:Length())
EndIf

Return .T.


/*
Programa   : NF400When(cInfo)
Parâmetros : 
Objetivo   : 
Retorno    :
Autor      : Nilson César C. Filho
Data/Hora  : 
Obs.       :
*/
Function NF400When(cInfo)
Local xRet
Default cInfo := ""


If Substr(cInfo,1,3) == "EEM"
    oModel    := FWModelActive()
    oModelEEM := oModel:GetModel("EEMMASTER")

    If cInfo == "EEM_NRNF" .OR. cInfo == "EEM_SERIE" .OR. cInfo == "EEM_DTNF"
        xRet := oModel:GetOperation() == MODEL_OPERATION_INSERT
    EndIf

EndIf

If Substr(cInfo,1,3) == "EES"
   oModel    := FWModelActive()
   oModelEES := oModel:GetModel("EESDETAIL")
EndIf

If Substr(cInfo,1,3) == "EK6"
   oModel    := FWModelActive()
   oModelEES := oModel:GetModel("EK6DETAIL")
EndIf

Do Case 

   Case cInfo == "EES_COD_I"
      xRet := Alltrim(oModelEES:GetValue("EES_PEDIDO")) == '0'
   
   Case Substr(cInfo,1,3) == "EK6"
      aEK6WHEN := {"EK6_SERIE","EK6_CLIENT","EK6_LOJACL","EK6_COD_I","EK6_ITEM", "EK6_CHVNFE", "EK6_UMNF", "EK6_CFOP"} 
      If aScan( aEK6WHEN , cInfo ) > 0
         xRet := !EasyGParam("MV_EECFAT",,.F.)
      Else
         xRet := .T.
      EndIf     
       
EndCase

Return xRet   
                      
/*
Programa   : DesNfItEmb(aChave)
Parâmetros : aChave - Array com a chave do item na NF
Objetivo   : Desvincular do item do embarque Nfs que faturam parcialmente
             o item da chave
Retorno    : aRet, onde:
             aRet[1] - Resultado do Processamento
             aRet[2] - Mensagem de aviso
Autor      : Nilson César C. Filho
Data/Hora  : 13/04/2015
Obs.       :
*/
Static Function DesNfItEmb(aChave)

Local cMsg := ""
Local lRet := .T.  
Local aRet := { .F., cMsg }
Local cQuery,cSelect,cFrom,cWhere
Local aIndexes := {"EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN+EE9_SEQEMB"}
Local cEES_Tab := RetSQLName("EES")
Local cEE9_Tab := RetSQLName("EE9")
Local i,j
Local aItenSld := {}
Local aNotSX3 := {{"RECNO","N",10,0}}
cSelect  := "SELECT EE9.R_E_C_N_O_ RECNO,EE9.*"                                                                                       
cFrom := " FROM "+cEE9_Tab+" EE9 INNER JOIN "+cEES_Tab+" EES "+;
           "ON EES_FILIAL = EE9_FILIAL"+;
         " AND EES_PREEMB = EE9_PREEMB"+;
         " AND EES_COD_I  = EE9_COD_I" +;
         " AND EES_PEDIDO = EE9_PEDIDO"+;
         " AND EES_SEQUEN = EE9_SEQUEN"+;
         " AND EES_NRNF   = EE9_NF"    +;
         " AND EES_SERIE  = EE9_SERIE" +;
         " AND EE9.D_E_L_E_T_ <> '*'"      

cWhere :=     " WHERE EES_FILIAL = '"+AvKey(aChave[1],"EES_FILIAL")+"'"+;
              " AND EES_PREEMB = '"  +AvKey(aChave[2],"EES_PREEMB")+"'"+;
              " AND EES.D_E_L_E_T_ <> '*'"+;
              " ORDER BY EE9_FILIAL, EE9_PREEMB, EE9_PEDIDO, EE9_SEQUEN , EE9_SEQEMB  ASC" 
          
cQuery := cSelect+cFrom+cWhere
cQuery := ChangeQuery(cQuery)
EasyWkQuery(cQuery,"REGEE9",aIndexes,aNotSX3,)

If REGEE9->(EasyRecCount()) >= 1

   REGEE9->(DbSetOrder(1))
   REGEE9->(DbGoTop())     

   Do While REGEE9->(!Eof())
      If ( nPos := aScan(aItenSld,   {|x| x[1]==REGEE9->EE9_FILIAL .And. x[2]==REGEE9->EE9_PREEMB .And. ;
                                          x[3]==REGEE9->EE9_PEDIDO .And. x[4]==REGEE9->EE9_SEQUEN })) > 0 
         aItenSld[nPos][6]  += REGEE9->EE9_SLDINI
         aItenSld[nPos][7]  += REGEE9->EE9_PRCTOT
         aItenSld[nPos][8]  += REGEE9->EE9_PRCINC
         aItenSld[nPos][9]  += REGEE9->EE9_PSLQTO
         aItenSld[nPos][10] += REGEE9->EE9_PSBRTO                    
      Else          
         aAdd( aItenSld, {REGEE9->EE9_FILIAL,; 
                          REGEE9->EE9_PREEMB,;
                          REGEE9->EE9_PEDIDO,;
                          REGEE9->EE9_SEQUEN,;
                          REGEE9->EE9_COD_I ,;
                          REGEE9->EE9_SLDINI,; 
                          REGEE9->EE9_PRCTOT,;
                          REGEE9->EE9_PRCINC,;
                          REGEE9->EE9_PSLQTO,;
                          REGEE9->EE9_PSBRTO,;
                          {{REGEE9->EE9_NF,REGEE9->EE9_SLDINI}},;
                          REGEE9->(Recno()) })
         nPos := Len(aItenSld)
      EndIF
      
      If aScan( aItenSld[nPos][11] , {|x| x[1] == REGEE9->EE9_NF  }) == 0
         aAdd(aItenSld[nPos][11],{REGEE9->EE9_NF,REGEE9->EE9_SLDINI} )     
      EndIf
         
      REGEE9->(DbSkip())   
   EndDo
   
   REGEE9->(DbGoTop())
   Do While REGEE9->(!Eof())
      EE9->(DbGoto(REGEE9->RECNO)) 
      cKeyLastIt  := REGEE9->(EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN)

      If EE9->(!Eof()) .and. EE9->(!Bof()) 
         EE9->(RecLock("EE9",.F.))
         EE9->(DbDelete())   
         EE9->(MsUnlock())       
      EndIf
      REGEE9->(DbSkip())
   EndDo
   
   For i:=1 To Len(aItenSld)
      REGEE9->(DbGoTo(aItenSld[i][12]))
      EE9->(RecLock("EE9",.T.))
      AvReplace("REGEE9","EE9")
      EE9->EE9_SLDINI := aItenSld[i][6] 
      EE9->EE9_PRCTOT := aItenSld[i][7]
      EE9->EE9_PRCINC := aItenSld[i][8]
      EE9->EE9_PSLQTO := aItenSld[i][9]
      EE9->EE9_PSBRTO := aItenSld[i][10]
      EE9->EE9_NF     := ""
      EE9->EE9_SERIE  := ""
      IF !EMPTY(EE9->EE9_QE)
         IF (EE9->EE9_SLDINI%EE9->EE9_QE)==0
            EE9->EE9_QTDEM1:=Int(Round((EE9->EE9_SLDINI/EE9->EE9_QE),10)) 
         Else
            EE9->EE9_QTDEM1:=Int(Round((EE9->EE9_SLDINI/EE9->EE9_QE),10))+1 
         EndIf
      EndIf      
      EE9->(msUnlock())
      
      //Monta Msg de saída no EECVIEW
      cMsg += "[ITEM: "      +Alltrim(aItenSld[i][5])+;
          "] | [PEDIDO: "    +Alltrim(aItenSld[i][3])+;
          "] | [SEQ.PEDIDO: "+Alltrim(aItenSld[i][4])+;
          "] | [EMBARQUE: "  +Alltrim(aItenSld[i][2])+"]"+CHR(13)+CHR(10) +;
          "Notas de Saída desvinculadas:" +CHR(13)+CHR(10)
      For  j:=1 To Len(aItenSld[i][11])
         cMsg+= "Nota: "+ Alltrim(aItenSld[i][11][j][1]) +"  Qtde.Fat: "+ Alltrim(cValTochar(aItenSld[i][11][j][2])) +CHR(13)+CHR(10)   
      Next j 
      cMsg+= CHR(13)+CHR(10)                 
   Next i
Else
   cMsg += "Não foram encontrados itens com notas fiscais para desvinculação"+CHR(13)+CHR(10)+;
           "no processo de embarque ["+aChave[2]+"] ao qual esta nota está "+CHR(13)+CHR(10)+;
           "vinculada!"   
EndIf

If select("REGEE9") > 0
   REGEE9->(dbClosearea())
EndIf

aRet := { lRet, cMsg }

Return aRet

Static Function IniCpoEYY(oModel)
Local oModelPrinc := oModel:GetModel()

If Empty(oModel:GetValue("EYY_PREEMB"))
    oModel:SetValue("EYY_PREEMB", AvKey(M->EEM_PREEMB,"EYY_PREEMB"))
EndIf
If Empty(oModel:GetValue("EYY_NFSAI"))
    oModel:SetValue("EYY_NFSAI" , AvKey(oModelPrinc:GetValue("EESDETAIL","EES_NRNF"),"EYY_NFSAI"))
EndIf
If Empty(oModel:GetValue("EYY_SERSAI"))
    oModel:SetValue("EYY_SERSAI", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_SERIE"),"EYY_SERSAI"))
EndIf
If Empty(oModel:GetValue("EYY_PEDIDO"))
    oModel:SetValue("EYY_PEDIDO", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_PEDIDO"),"EYY_PEDIDO"))
EndIf
If Empty(oModel:GetValue("EYY_SEQUEN"))
    oModel:SetValue("EYY_SEQUEN", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_SEQUEN"),"EYY_SEQUEN"))
EndIf
If EYY->(FieldPos("EYY_SQFNFS")) > 0 .And. Empty(oModel:GetValue("EYY_SQFNFS"))
    oModel:SetValue("EYY_SQFNFS", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_FATSEQ"),"EYY_SQFNFS"))
EndIf
If Empty(oModel:GetValue("EYY_FASE"))
    oModel:SetValue("EYY_FASE"  , AvKey("Q","EYY_FASE"))
EndIf

Return .T.

Static Function IniCpoEK6(oModel)
Local oModelPrinc := oModel:GetModel()

If Empty(oModel:GetValue("EK6_PREEMB"))
    oModel:SetValue("EK6_PREEMB", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_PREEMB"),"EK6_PREEMB"))
EndIf
If Empty(oModel:GetValue("EK6_NFSD"))
    oModel:SetValue("EK6_NFSD" , AvKey(oModelPrinc:GetValue("EESDETAIL","EES_NRNF"),"EK6_NFSD"))
EndIf
If Empty(oModel:GetValue("EK6_SENFSD"))
    oModel:SetValue("EK6_SENFSD", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_SERIE"),"EK6_SENFSD"))
EndIf
If Empty(oModel:GetValue("EK6_PDNFSD"))
    oModel:SetValue("EK6_PDNFSD", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_PEDIDO"),"EK6_PDNFSD"))
EndIf
If Empty(oModel:GetValue("EK6_SQPDNF"))
    oModel:SetValue("EK6_SQPDNF", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_SEQUEN"),"EK6_SQPDNF"))
EndIf
If Empty(oModel:GetValue("EK6_SQFTSD"))
    oModel:SetValue("EK6_SQFTSD", AvKey(oModelPrinc:GetValue("EESDETAIL","EES_FATSEQ"),"EK6_SQFTSD"))
EndIf

Return .T.



// Adiciona um atributo LINPOS para cada item do array. O array é um conjunto de itens para o MSExecAuto
Static Function addLinpos(aItens, cAttr, nOpcAuto, cAlias)

    Local i := 0
    Local nIndexAtr := 0
    Local aUmItem := {}

    if nOpcAuto != 4 && nOpcAuto != 5
        Return
    EndIf
    if aItens == Nil
        Return
    EndIf

    For i := 1 To Len(aItens)
        nIndexAtr := getExecInd(aUmItem, cAttr)
        addOneLinp(aUmItem, cAttr, nIndexAtr)
    Next

Return

// Retorna o índice que tenha o attributo cAttr do array aItem
Static Function getExecInd(aItem, cAttr)
    Return aScan(aItem, {|x| x[1] == cAttr})

// Retorna o valor de um atributo cAttr de um array aItem do execauto
Static Function execVal(aItem, cAttr)
    Local ind := getExecInd(aItem, cAttr)
    Return If(ind != 0, AvKey(aItem[ind][2], cAttr), AvKey("", cAttr))

Static Function addOneLinp(aUmItem, cAttr, nIndexAtr)
    If(nIndexAtr != 0)
        aAdd(aUmItem, {"LINPOS", cAttr, aUmItem[nIndexAtr][2]})
    EndIf
Return

Static Function delItensSai(aItem, nOpcAuto)

    If nOpcAuto != 4
        Return
    EndIf

    EES->(DbSetOrder(1))
    EYY->(DbSetOrder(3))

    while nexEES_EEM(aItem)

        while nexEYY_EEM()
            EYY->(Reclock("EYY", .F.))
            EYY->(DbDelete())
            EYY->(MsUnlock())
        EndDo

        EES->(Reclock("EES", .F.))
        EES->(DbDelete())
        EES->(MsUnlock())
    EndDo
    //EndIf

Return

Static Function nexEES_EEM(aItem)
Return EES->(DbSeek(;
                xFilial("EES") +;
                execVal(aItem, "EEM_PREEMB") +;
                execVal(aItem, "EEM_NRNF") +;
                execVal(aItem, "EEM_SERIE") +;
                execVal(aItem, "EEM_PEDIDO");
            ))

Static Function nexEYY_EEM()

Return EYY->(DbSeek(;
                xFilial("EYY") +;
                AvKey(EES->EES_PREEMB, "EES_PREEMB") +;
                AvKey(EES->EES_PEDIDO, "EES_PEDIDO") +;
                AvKey(EES->EES_SEQUEN, "EES_SEQUEN") +;
                AvKey(EES->EES_NRNF, "EES_NRNF") +;
                AvKey(EES->EES_SERIE, "EES_SERIE");
            ))

/*
Funcao      : DesNfItRem(cEmbarque)
Parametros  : Codigo do embarque, Tipo Cad. NF/Invoice, Numero NF, Serie NF, Tipo NF, CNPJ
Retorno     : nenhum
Objetivos   : Desvincular a Nota, os itens da nota e as notas de remessa do Embarque quando realizada uma devolucao
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora   : 30/11/2017
Obs.        :
*/
Static Function DesNfItRem(cEmbarque,cTipoCa,cNota,cSerie,cTipoNf,cCNPJ)
Local aOrd:= SaveOrd({"EEM","EES","EYY"})

EEM->(DbSetOrder(1)) //EEM_FILIAL, EEM_PREEMB, EEM_TIPOCA, EEM_NRNF, EEM_TIPONF
EES->(DbSetOrder(1)) //EES_FILIAL, EES_PREEMB, EES_NRNF, EES_SERIE, EES_PEDIDO, EES_SEQUEN, EES_FATSEQ
EYY->(dbSetOrder(1)) //EYY_FILIAL, EYY_PREEMB, EYY_SEQEMB, EYY_NFSAI, EYY_SERSAI, EYY_D1ITEM

While EEM->(DbSeek(xFilial("EEM") + AvKey(cEmbarque,"EEM_PREEMB")))
    EEM->(RecLock("EEM",.F.))
    EEM->EEM_PREEMB := " "
    EEM->(MsUnLock())
End


While EES->(dbSeek(xFilial("EES") + AvKey(cEmbarque,"EES_PREEMB")))
    EES->(RecLock("EES", .F.))
    EES->EES_PREEMB := " "
    EES->(MsUnlock())
End


While EYY->(dbSeek(xFilial("EYY") +  AvKey(cEmbarque,"EYY_PREEMB")))
    RecLock("EYY",.F.)
    EYY->EYY_PREEMB := " "
    EYY->(MsUnlock())
End

RestOrd(aOrd,.T.)
Return


/*
Função     : NF400SD2F3()
Objetivo   : Montas consulta padrão dos itens da notas fiscais de saída (SD2) para seleção 
             de notas fiscais de saída que se caracterizam como lote de exportação.
Parâmetros : Nenhum
Retorno    : campos chave da nota (D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, D2_QUANT, F2_CHVNFE)
Autor      : Nilson César (adaptada da função AE110SD1F3, fonte: EECAE110)
Data       : nov/2018
Revisão    :
*/
Function NF400SD2F3()
Local aEnchoice:= {}
Local nCont
Local oDlg, oMsMget, oBrowse
Local aDados:= {}
Local aSeek := {}
Local bOk:= {|| If( ValOkF3(aCampos, aDados[oBrowse:nAt]) , ( GrvDados(aCampos, aDados[oBrowse:nAt]), lRet:= .T.,  oDlg:End() ) , ) }
Local bCancel:= {|| lRet:= .F., lExecConPad1:= .T., oDlg:End()}
Local lRet:= .T.
Local oModel
Local oModelEES
Private cTitulo:= STR0053 //"Itens de Notas Fiscais de Saída para formação de lote"
Private aCampos:= {}
Private aFilter:= {}
Private aSaldoNFS := {}

oModel    := FWModelActive()
oModelEES := oModel:GetModel("EESDETAIL")

Begin Sequence

   If !Empty( EasyGParam("MV_EEC0057",,"") )
      cTitulo += ", " + " que possuem CFOP's :" //" que possuem CFOP's :"
      cTitulo += Alltrim( EasyGParam("MV_EEC0057",,"") ) 
   EndIf

   /* Campos que serão exibidos na parte inferior */
   aCampos:= {"D2_DOC", "D2_SERIE", "D2_CLIENTE", "D2_LOJA", "D2_COD" , "D2_ITEM" , "D2_QUANT", "D2_EMISSAO", "D2_TES" , "D2_UM", "D2_CF", "F2_CHVNFE","R_E_C_N_O_"}

   /* Campos usados na pesquisa */
   AAdd(aSeek, {AvSx3("D2_DOC"   , AV_TITULO), {{"", AvSx3("D2_DOC"   , AV_TIPO), AvSx3("D2_DOC"   , AV_TAMANHO), AvSx3("D2_DOC"   , AV_DECIMAL), AvSx3("D2_DOC"    , AV_TITULO)}}})
   AAdd(aSeek, {AvSx3("D2_CLIENTE", AV_TITULO), {{"", AvSx3("D2_CLIENTE", AV_TIPO), AvSx3("D2_CLIENTE", AV_TAMANHO), AvSx3("D2_CLIENTE", AV_DECIMAL), AvSx3("D2_CLIENTE" , AV_TITULO)}}})

   /* Campos usados no filtro */
   AAdd(aFilter, {AvSx3("D2_DOC"    , AV_TITULO)  , AvSx3("D2_DOC"    , AV_TITULO) , AvSx3("D2_DOC"    , AV_TIPO) , AvSx3("D2_DOC"    , AV_TAMANHO) , AvSx3("D2_DOC"    , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_SERIE"  , AV_TITULO)  , AvSx3("D2_SERIE"  , AV_TITULO) , AvSx3("D2_SERIE"  , AV_TIPO) , AvSx3("D2_SERIE"  , AV_TAMANHO) , AvSx3("D2_SERIE"  , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_CLIENTE", AV_TITULO)  , AvSx3("D2_CLIENTE", AV_TITULO) , AvSx3("D2_CLIENTE", AV_TIPO) , AvSx3("D2_CLIENTE", AV_TAMANHO) , AvSx3("D2_CLIENTE", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_LOJA"   , AV_TITULO)  , AvSx3("D2_LOJA"   , AV_TITULO) , AvSx3("D2_LOJA"   , AV_TIPO) , AvSx3("D2_LOJA"   , AV_TAMANHO) , AvSx3("D2_LOJA"   , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_COD"    , AV_TITULO)  , AvSx3("D2_COD"    , AV_TITULO) , AvSx3("D2_COD"    , AV_TIPO) , AvSx3("D2_COD"    , AV_TAMANHO) , AvSx3("D2_COD"    , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_ITEM"   , AV_TITULO ) , AvSx3("D2_ITEM"   , AV_TITULO) , AvSx3("D2_ITEM"   , AV_TIPO) , AvSx3("D2_ITEM"   , AV_TAMANHO) , AvSx3("D2_ITEM"   , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_EMISSAO", AV_TITULO)  , AvSx3("D2_EMISSAO", AV_TITULO) , AvSx3("D2_EMISSAO", AV_TIPO) , AvSx3("D2_EMISSAO", AV_TAMANHO) , AvSx3("D2_EMISSAO", AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_CF"     , AV_TITULO)  , AvSx3("D2_CF"     , AV_TITULO) , AvSx3("D2_CF"     , AV_TIPO) , AvSx3("D2_CF"     , AV_TAMANHO) , AvSx3("D2_CF"     , AV_DECIMAL), ""})
   AAdd(aFilter, {AvSx3("D2_UM"     , AV_TITULO)  , AvSx3("D2_UM"     , AV_TITULO) , AvSx3("D2_UM"     , AV_TIPO) , AvSx3("D2_UM"     , AV_TAMANHO) , AvSx3("D2_UM"     , AV_DECIMAL), ""})

   /* Retorna os dados que serão exibidos na parte inferior. */
   aDados:= RetSD2(aCampos,oModelEES)

   /* Se não houver dados, redefine a ação do botão OK. */
   If Len(aDados) == 0
      bOk:= bCancel
   EndIf

   Define MsDialog oDlg Title STR0049 From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel //"Notas fiscais de saída"

      oBrowse:= FWBrowse():New(oDlg)

         oBrowse:SetDataArray()
         oBrowse:SetArray(aDados)
         oBrowse:SetDescription(cTitulo)

         For nCont:= 1 To Len(aCampos)
            If aCampos[nCont] <> "R_E_C_N_O_"
               If aCampos[nCont] == "D2_QUANT"                                              //"Saldo Qtde. da Nota Fiscal"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0054 Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               ElseIf aCampos[nCont] == "D2_UM"                                             //"Unidade de Medida da NF"
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title STR0055 Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               Else
                  Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title AvSx3(aCampos[nCont], AV_TITULO) Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
               EndIf
            EndIf
         Next

         /* Pesquisa */
         oBrowse:SetSeek(, aSeek)

         /* Filtro */
         oBrowse:SetUseFilter()
         oBrowse:SetFieldFilter(aFilter)

      oBrowse:Activate()

	Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))

    //SetPropEK6(.F.)

End Sequence

Return lRet

/*
Função     : RetSD2()
Objetivo   : Listar as notas fiscais de saída que podem ser usadas para vinculação ao processo de exportação
Parâmetros : aCampos - campos a serem considerados no retorno de dados
Retorno    : aDados - array as notas fiscais que podem ser exibidas
Autor      : Nilson César (adaptada da função RetSD1, fonte: EECAE110)
Data       : nov/2018
Revisão    :
*/
Static Function RetSD2(aCampos,oModel)
Local cWhere:= "", cDelete:= "", cPrefixo:= ""
Local nCont, nPos
Local aDados:= {}, aReg:= {}
Local aArea:= GetArea()
Local nSldUsado
Local nPosCpoUMD, nPosCpoSld
Local cUnidPara := ""
Local cNcm      := ""

Private cQuery := ""

Begin Sequence

   DBSelectArea("SD2")

   If TcSrvType() <> "AS/400"
      cDelete := " And D2.D_E_L_E_T_ <> '*' And F2.D_E_L_E_T_ <> '*' "
   EndIf

   cQuery:= "Select "
   For nCont:= 1 To Len(aCampos)

      If nCont > 1
         cQuery += ", "
      EndIf

      If aCampos[nCont] == "R_E_C_N_O_"
         cPrefixo:= "D2."
      ElseIf SubStr(aCampos[nCont], 1, 1) == "S"
         cPrefixo:= SubStr(aCampos[nCont], 1, 3) + "."
      Else
         cPrefixo:= SubStr(aCampos[nCont], 1, 2) + "."
      EndIf
      cQuery +=  ( cPrefixo + aCampos[nCont] )
   Next

   //   cQuery += " ,F2.F2_CHVNFE"
   cQuery += " From " + RetSqlName("SD2") + " D2"
   cQuery += " Inner Join " + RetSqlName("SF2") + " F2" 
   cQuery += " On D2.D2_DOC = F2.F2_DOC"
   cQuery += " And D2.D2_SERIE = F2.F2_SERIE"
   cQuery += " And D2.D2_CLIENTE = F2.F2_CLIENTE"
   cQuery += " And D2.D2_LOJA = F2.F2_LOJA"

   cWhere := " Where D2.D2_FILIAL = '" + SD2->(xFilial())+"'"
   cWhere += " And F2.F2_FILIAL = '" + SF2->(xFilial())+"'"
   cWhere += " And D2.D2_COD = '"      + oModel:GetValue("EES_COD_I")  + "'"
   cWhere += " And F2.F2_HAWB = ''"

   If !Empty(EasyGParam("MV_EEC0057",,""))
      cWhere  += " And D2.D2_CF IN ('" + StrTran( Alltrim(EasyGParam("MV_EEC0057",,"")) , "," , "','" ) + "')"
   EndIf

   //aChvSD2 := {"D2_FILIAL", "D2_DOC" , "D2_SERIE" , "D2_CLIENTE" , "D2_LOJA" , "D2_COD" , "D2_ITEM"}
   //cWhereAux := GetStrQry( aChvSD2,GetInfoEK6(2) )
   //CWhere    += cWhereAux
   /* Montagem da Query */
   cQuery += (cWhere + cDelete)

   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery Alias "SD2TMP" New

   For nCont:= 1 To Len(aCampos)
      If aCampos[nCont] <> "R_E_C_N_O_"
         If AvSx3(aCampos[nCont], AV_TIPO) == "N"
            TcSetField("SD2TMP", aCampos[nCont], "N", AvSx3(aCampos[nCont], AV_TAMANHO), AvSx3(aCampos[nCont], AV_DECIMAL))
         ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "C"
            TcSetField("SD2TMP", aCampos[nCont], "C", AvSx3(aCampos[nCont], AV_TAMANHO))
         ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "D"
            TcSetField("SD2TMP", aCampos[nCont], "D")
         EndIf
      EndIf
   Next

   nPosCpoUMD := aScan(aCampos,"D2_UM")
   nPosCpoSld := aScan(aCampos,"D2_SLDEXP")

   /* Array com os registros a serem exibidos. */
   SD2TMP->(DBGoTop())
   While SD2TMP->(!Eof())

      /* Atualização do saldo.
         Serão abatidas as quantidades associadas ao processo em edição. */
      nSldUsado:= 0
      If (nPos:= AScan(aSaldoNFS, {|x| x[1] == SD2TMP->R_E_C_N_O_})) > 0
         nSldUsado:= aSaldoNFS[nPos][2]
      EndIf

      /* Se o saldo se mantiver superior a 0, será exibido */
      If (SD2TMP->D2_QUANT - nSldUsado) > 0
         aReg:= {}
         For nCont:= 1 To SD2TMP->(FCount())
            If SD2TMP->(FieldName(nCont)) <> "D2_QUANT"
               AAdd(aReg, SD2TMP->&(FieldName(nCont)))
            Else
               AAdd(aReg, SD2TMP->&(FieldName(nCont)) - nSldUsado)
            EndIf
         Next
         AAdd(aDados, AClone(aReg))
      EndIf

      SD2TMP->(DBSkip())
   EndDo

   SD2TMP->(DBCloseArea())

End Sequence

RestArea(aArea)
Return AClone(aDados)


/*
Função     : GrvDados()
Objetivo   : Atualizar os dados da work WK_NFRem, controlar o saldo usado e
             posicionar a SD2 para retorno das demais informações
             - Deve controlar a inclusão/ exclusão da linha na work, de acordo com o  saldo
               vindo da tabela SD2
             - Deve controlar o saldo do item usado, para atualização da tabela SD2
             com o saldo que estiver vindo da
Parâmetros : aCampos - campos exibidos na consulta padrão
             aDados - array as informações da linha posicionada
Retorno    :
Autor      : Nilson César (adaptada da função GrvDados, fonte: EECAE110)
Data       : Nov/2018
Revisão    :
*/
Static Function GrvDados(aCampos, aDados)
Local lRet:= .T.
Local nPos:= 0
Local nRecNoSD2
Local nQuantidade, nQtdeUMEmb , nQtdeUMNFe
Local cUMPesItEmb, cUMNFeIt, nQtdeBxSD2, i
Local oModel
Local oModelEK6
Local aCpoChvEES := {"EES_PREEMB" ,"EES_PEDIDO" , "EES_SEQUEN" , "EES_NRNF" , "EES_SERIE"  , "EES_FATSEQ"} //{ "EK6_PREEMB" , "EK6_PDNFSD" , "EK6_SQPDNF" , "EK6_NFSD" , "EK6_SENFSD" , "EK6_SQFTSD" }
Local aChaveEES := {}

oModel    := FWModelActive()
oModelEK6 := oModel:GetModel("EK6DETAIL")
oModelEES := oModel:GetModel("EESDETAIL")

Begin Sequence

   If Len(aDados) == 0
      Break
   EndIf

   nRecNoSD2  := aDados[AScan(aCampos, "R_E_C_N_O_")]
   nQtdeBxSD2 := SD2->D2_QUANT

   //SaldoTmpSD2(nRecNoSD2 , nQtdeBxSD2 , SUBTRAIR)
   //SaldoTmpSD2(nRecNoSD2 , nQtdeBxSD2 , SOMAR   )

   SD2->(DBGoTo(nRecNoSD2))

   SetPropEK6(.T.)

   /* Atualiza os valores da linha da EK6 */
   oModelEK6:LoadValue("EK6_NF"    ,SD2->D2_DOC)
   oModelEK6:LoadValue("EK6_SERIE" ,SD2->D2_SERIE)
   oModelEK6:LoadValue("EK6_CLIENT",SD2->D2_CLIENTE)
   oModelEK6:LoadValue("EK6_LOJACL",SD2->D2_LOJA)
   oModelEK6:LoadValue("EK6_COD_I" ,SD2->D2_COD)
   oModelEK6:LoadValue("EK6_ITEM"  ,SD2->D2_ITEM)
   oModelEK6:LoadValue("EK6_CHVNFE",Posicione("SF2", 1 , xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) ,"F2_CHVNFE") )
   oModelEK6:LoadValue("EK6_QUANT" ,NF400QtSD2(SD2->D2_QUANT))
   oModelEK6:LoadValue("EK6_UMNF"  ,SD2->D2_UM)
   oModelEK6:LoadValue("EK6_CFOP"  ,SD2->D2_CF)

   For i := 1 To Len(aCpoChvEES)
      aAdd(aChaveEES, oModelEES:GetValue(aCpoChvEES[i]))
   NExt i

End Sequence

Return lRet

/*
Função     : SaldoTmpSD2()
Objetivo   : Atualizar o array aSaldoNFS com os dados em edição da tabela SD2
Parâmetros : - Quantidade consumida do item da nota de entrada
             - RecNo do registro da tabela SD2
             - nOperacao: SOMAR = 1; SUBTRAIR = 2
Retorno    :
Autor      : Nilson César (adaptada da função SaldoTmpSD1, fonte: EECAE110)
Data       : Nov/2018
Revisão    :
*/
Static Function SaldoTmpSD2(nRecNoSD2, nQuantidade, nOperacao)
Local nPos
Default nQuantidade:= 0
Default nRecNoSD2:= 0
Default nOperacao:= SOMAR

Begin Sequence

   If nRecNoSD2 == 0
      Break
   EndIf

   /* agrega no recno da SD2 ou adiciona no array de controle */
   If nOperacao == SOMAR
      nPos:= AScan(aSaldoNFS, {|x| x[1] == nRecNoSD2})
      If nPos > 0
         aSaldoNFS[nPos][2] += nQuantidade
      Else
         AAdd(aSaldoNFS, {nRecNoSD2, nQuantidade})
      EndIf
   EndIf

   /* abate a quantidade substituida ou deletada da work */
   If nOperacao == SUBTRAIR
      nPos:= AScan(aSaldoNFS, {|x| x[1] == nRecNoSD2})
      If nPos > 0
         aSaldoNFS[nPos][2] -= nQuantidade
      EndIf
   EndIf

End Sequence
Return

/*
Função     : ValOkF3()
Objetivo   : Validar a vinculação via F3-Consulta
Parâmetros : Nenhum
Retorno    : lRet - resultado da validação
Autor      : Nilson César (adaptada da função ValOkF3, fonte: EECAE110)
Data       : Nov/2018
Revisão    :
*/
Static Function ValOkF3(aCampos, aDados)

Local lRet := .T.
Local aQtdEESEK6

If EasyGParam("MV_EECFAT",,.F.) .And. !EK6CHVNFE(xFilial("SF2"), aDados[AScan(aCampos, "D2_DOC")], aDados[AScan(aCampos, "D2_SERIE")], aDados[AScan(aCampos, "D2_CLIENTE")], aDados[AScan(aCampos, "D2_LOJA")])
   lRet := .F.
EndIf

Return lRet

/*
Função     : EK6CHVNFE
Objetivo   : Retorna .T. quando existir a chave da nota (F1_CHVNFE) e .F. quando nao existir ou quando nao for possivel verificar (fatam informacoes)
Parâmetros : cFilialSF2,cDocSF2,cSerieSF2,cClienSF2,cLojaSF2 - dados da chave parra posicionamento da nota fiscal de saida
             cChaveNFS - código default da chave eletrônica da SEFAZ para a NF.
Retorno    : .T. - Posicionou SF1 e existe F1_CHVNFE; .F. nao posicionou ou nao existe a informacao F1_CHVNFE
Autor      : Nilson César (adaptada da função EYYCHVNFE, fonte: EECAE110)
Data       : Nov/2018
*/
Static Function EK6CHVNFE(cFilialSF2,cDocSF2,cSerieSF2,cClienSF2,cLojaSF2,cChaveNFS)
Local lRet        := .T.
Local aAreaSF2    := SF2->(GetArea())

Default cChaveNFS := ""

If !Empty(cFilialSF2) .And. !Empty(cDocSF2) .And. !Empty(cSerieSF2) .And. !Empty(cClienSF2) .And. !Empty(cLojaSF2)
  SF2->(dbSetOrder(1))//F2_FILIAL + F2_DOC + F2_SERIE + F2_FORNECE + F2_LOJA + F2_TIPO
  If !AvFlags("EEC_LOGIX") .And. SF2->(DbSeek(AvKey(cFilialSF2,"F2_FILIAL") + AvKey(cDocSF2,"F2_DOC") + AvKey(cSerieSF2,"F2_SERIE") + AvKey(cClienSF2,"F2_CLIENTE") + AvKey(cLojaSF2,"F2_LOJA")))

    If Empty(SF2->F2_CHVNFE)
      MsgInfo( STR0056, STR0001) //"Esta nota fiscal não pode ser associada, pois não há chave de registro da Nota Fiscal na Sefaz. Efetue a transmissão para a Sefaz para efetuar a associação ao embarque." #### "Atenção"
      cChaveNFS := ""
      lRet := .F.
    Else
      cChaveNFS := SF2->F2_CHVNFE
    EndIf

  EndIf
EndIf

RestArea(aAreaSF2)
Return lRet

/*
Função     : lHasItRem
Objetivo   : Verificar se há registros validos no arquivo de modelo das notas fiscais de remessa
Parâmetros : oMdlremess - objeto oModel a verificar
Retorno    : .T. - Caso haja um ou mais registros com pelo ao menos o campo de NF informado; 
             .F. - Caso não exista nenhuma linha ou apenas linhas em branco (sem número de NF informado)
Autor      : Nilson César 
Data       : Nov/2018
*/
Static Function lHasItRem(oMdlRemes)
Local lRet := .F.
Local i := 1

If oMdlRemes:GetQtdLine() >= 1
   Do While i <= oMdlRemes:GetQtdLine()
      oMdlRemes:GoLine(i)
      If !oMdlRemes:IsDeleted()
         If !Empty( oMdlRemes:GetModel():GetValue("EYYDETAIL","EYY_NFENT") )
            lRet := .T.
            Exit
         EndIf
      EndIf
      i++
   EndDo   
EndIf

Return lRet

/*
Função     : GetInfoEK6
Objetivo   : 
Parâmetros : 
Retorno    : 1 - Array(Numerico) - Somatoria de quantidade de item nas notas de form. lote exp. vinculadas 
             2 - Array(caracter) - Chaves dos itens nas notas notas de form. lote exp. vinculadas
Autor      : Nilson César 
Data       : Nov/2018
*/
Static Function GetInfoEK6(nTipo)

Local oModel    := FWModelActive()
Local oModelEK6 := oModel:GetModel("EK6DETAIL")
Local oModelEES := oModel:GetModel("EESDETAIL")
Local nLinPos   := oModelEK6:GetLine()
Local aChaves   := {}
Local aChavLine := {}
Local aVincLine := {}
Local nEQtdeLine:= 0
Local i
Local nSldAntLin := oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_QUANT")
Default nTipo := 1

If oModelEK6:GetQtdLine() >= 1
   For i:=1 To oModelEK6:GetQtdLine()
      oModelEK6:GoLine(i)
      If !oModelEK6:IsDeleted() .And. If( nTipo == 2, i <> nLinPos , .T.) //Desconsidera linhas deletadas e a linha atual quando a busca é pelas chaves.
         If !Empty( oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_NF") )
            nEQtdeLine += oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_QUANT")
            aAdd(aChavLine,  Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_NF"    )) + ;
                             Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_SERIE" )) + ;
                             Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_CLIENT")) + ;
                             Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_LOJACL")) + ;
                             Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_COD_I" )) + ;
                             Alltrim(oModelEK6:GetModel():GetValue("EK6DETAIL","EK6_ITEM"  ))   )
         EndIf
      EndIf
   Next i  
EndIf

aVincLine := { oModelEES:GetModel():GetValue("EESDETAIL","EES_QTDE"  )  , nEQtdeLine  }

oModelEK6:GoLine(nLinPos)

Return If( nTipo == 1, aclone(aVincLine) , aClone( aChavLine )   )

/*
Função     : NF400QtSD2
Objetivo   : Retornar a quantidade do item que pode ser vinculada
Parâmetros : 
Retorno    : nQuant - quantidade calculada possível de retornar
Autor      : Nilson César 
Data       : Nov/2018
*/
Function NF400QtSD2(nQtdeSD2)

Local aQtdVinc   := GetInfoEK6(1)
Local nQuant     := 0
Local nSldMax    := aQtdVinc[1]
Local nSldUtiliz := aQtdVinc[2]
Local nSldVincul := nQtdeSD2
Local nMaxVinc   := aQtdVinc[1] - aQtdVinc[2]
/*
If nMaxVinc >= nSldVincul
   nQuant := nSldVincul
Else
   nQuant := nSldVincul +  ( nMaxVinc - nSldVincul )
EndIf
*/
   nQuant := nQtdeSD2
Return nQuant


Static Function SetPropEK6(lEnable)

Local oModel    := FWModelActive()
Local oEstModEK6 := oModel:GetModel("EK6DETAIL"):OFORMMODELSTRUCT
Local nI, bBlock

If EasyGParam("MV_EECFAT",,.F.)
   bBlock := FwBuildFeature(STRUCT_FEATURE_WHEN, If(lEnable,".T.",".F.") ) 
   For nI := 1 to Len(oEstModEK6:aFields)
      If !(oEstModEK6:aFields[nI][3] $ "EK6_FILIAL|EK6_NF|EK6_QUANT")
         oEstModEK6:SetProperty( oEstModEK6:aFields[nI][3] , MODEL_FIELD_WHEN , bBlock )
      EndIf
   Next nI
EndIf

Return .T.

Static Function EK6LinhaOK()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local oModelEK6 := oModel:GetModel("EK6DETAIL")
Local oEstModEK6:= oModel:GetModel("EK6DETAIL"):OFORMMODELSTRUCT
Local aCposNoVal:= {"EK6_FILIAL","EK6_QTUMIT","EK6_SEQEMB"}
Local i

If !EasyGParam("MV_EECFAT",,.F.)
   aAdd(aCposNoVal,"EK6_PREEMB")
   aAdd(aCposNoVal,"EK6_NFSD")
   aAdd(aCposNoVal,"EK6_SENFSD")
   aAdd(aCposNoVal,"EK6_SQFTSD")   
EndIf

Begin Sequence
   For i := 1 to Len(oEstModEK6:aFields)
      If aScan( aCposNoVal , oEstModEK6:aFields[i][3] ) == 0
         cTipoCpo := oEstModEK6:GetProperty( oEstModEK6:aFields[i][3] , MODEL_FIELD_TIPO   )
         cTitlCpo := oEstModEK6:GetProperty( oEstModEK6:aFields[i][3] , MODEL_FIELD_TITULO )
         Do case
            Case cTipoCpo == "C"
               If !( lRet := !Empty( oModelEK6:GetValue( oEstModEK6:aFields[i][3] ) ) )
                  EasyHelp("Campo '"+cTitlCpo+"' não informado!")
                  Break
               EndIf
            Case cTipoCpo == "N"
               If !( lRet := oModelEK6:GetValue( oEstModEK6:aFields[i][3] )  > 0 )
                  EasyHelp("Campo '"+cTitlCpo+"' zerado!")
                  Break
               EndIf
            Case cTipoCpo == "D"
               If !( lRet := EMpty( DToS(oModelEK6:GetValue( oEstModEK6:aFields[i][3] )) ) )
                  EasyHelp("Data no campo '"+cTitlCpo+"' não informada!")
                  Break
               EndIf
         EndCase
      EndIf       
   Next i

   If EasyGParam("MV_EECFAT",,.F.)
      aAreaSD2 := GetArea("SD2")
      SD2->(DbSetOrder(3))
      If !(lRet := SD2->(DbSeek( xFilial("SD2") + AvKey( oModelEK6:GetValue("EK6_NF"),     "D2_DOC"    ) + ;
                                                  AvKey( oModelEK6:GetValue("EK6_SERIE"),  "D2_SERIE"  ) + ;
                                                  AvKey( oModelEK6:GetValue("EK6_CLIENT"), "D2_CLIENTE") + ;
                                                  AvKey( oModelEK6:GetValue("EK6_LOJACL"), "D2_LOJA"   ) + ;
                                                  AvKey( oModelEK6:GetValue("EK6_COD_I"),  "D2_COD"    ) + ;
                                                  AvKey( oModelEK6:GetValue("EK6_ITEM"),   "D2_ITEM"   ))) )
         EasyHelp("Item de nota fiscal de saída não localizado com os dados informados!"+ENTER+;
                  "Verifique os valores informados nos campos 'Nota Fiscal', 'Série' , 'Cliente', 'Loja', 'Cód.Produto' e 'Item' !")
         RestArea(aAreaSD2)
         Break
      EndIf
      RestArea(aAreaSD2)
   EndIf

End Sequence

Return lRet


Static function EESSumQtd(oMdlGride,nPos)
Local i
Local nQtde := 0
Local cChaveEES

oMdlGride:GoLine(nPos)
cChaveEES := oMdlGride:GetValue("EES_PREEMB") + oMdlGride:GetValue("EES_NRNF") + oMdlGride:GetValue("EES_SERIE") + oMdlGride:GetValue("EES_PEDIDO") + oMdlGride:GetValue("EES_SEQUEN")

For i := 1 To oMdlGride:GetQtdLine()
   oMdlGride:GoLine(i)
   If !oMdlGride:isDeleted() .And. cChaveEES == (oMdlGride:GetValue("EES_PREEMB") + oMdlGride:GetValue("EES_NRNF") + oMdlGride:GetValue("EES_SERIE") + oMdlGride:GetValue("EES_PEDIDO") + oMdlGride:GetValue("EES_SEQUEN"))
      nQtde += oMdlGride:GetValue("EES_QTDE")
   EndIf
Next i

Return nQtde
