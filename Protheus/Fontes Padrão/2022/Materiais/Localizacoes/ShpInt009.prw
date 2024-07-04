#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE MODEL_A1M "A1MMASTER"
#DEFINE MODEL_A1K "A1KDETAIL"
#DEFINE MODEL_A1E "A1EDETAIL"

#DEFINE VIEW_A1M "VIEW_A1M"
#DEFINE VIEW_A1K "VIEW_A1K"
#DEFINE VIEW_A1E "VIEW_A1E"

/*/{Protheus.doc} ShpInt009
    (long_description)
    @type  Function
    @author Yves Oliveira
    @since 29/04/2020
    /*/
Function ShpInt009()
    Local oBrowse
    Private cTitle := STR0089//"Product Setup"
   
    If !IntegraShp()
	    Return .F. 
    Endif

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias("A1M")
    oBrowse:SetDescription(cTitle)
    oBrowse:SetFilterDefault("A1M_GRADE == '2'")
    oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 29/04/2020
    /*/
Static Function MenuDef()
    Local aRotina := {}

    aAdd( aRotina, { STR0070, "VIEWDEF.SHPINT009", 0, 2, 0, NIL } )//"Visualizar"
    aAdd( aRotina, { STR0071, "VIEWDEF.SHPINT009", 0, 3, 0, NIL } )//"Incluir"
    aAdd( aRotina, { STR0072, "VIEWDEF.SHPINT009", 0, 4, 0, NIL } )//"Alterar"
    
    aAdd( aRotina, { STR0073, "INTEGSHP(.F.)", 0, 4, 0, NIL } )//"Integrate"
    aAdd( aRotina, { STR0073 + " all", "Processa( { || INTEGSHP(.T.)  })", 0, 5, 0, NIL } )//"Integrate"
   
Return aRotina

/*/{Protheus.doc} ModelDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 29/04/2020
    /*/
Static Function ModelDef(param_name)
    Local oStruA1M  := FWFormStruct( 1, "A1M", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruA1K  := FWFormStruct( 1, "A1K", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruA1E  := FWFormStruct( 1, "A1E", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel    := Nil
    Local cModelA1M := MODEL_A1M
    Local cModelA1K := MODEL_A1K
    Local cModelA1E := MODEL_A1E
    Local cTitleA1M := STR0075//"Grid"
    Local cTitleA1K := STR0087//"Products"
    Local cTitleA1E := STR0076//"Images"
    Local aAux      := {}

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( FunName(), /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    aAux := FwStruTrigger("A1M_COD" ,;// Campo Dominio
						  "A1M_DESC" ,;// Campo de Contradominio
						  "StaticCall(SHPINT009,FillProd,FwFldGet('A1M_COD'))",;// Regra de Preenchimento
						  .F.,;// Se posicionara ou nao antes da execucao do gatilhos
						  "",;// Alias da tabela a ser posicionada
						  0,; // Ordem da tabela a ser posicionada
						  "",;// Chave de busca da tabela a ser posicionada
						  Nil,;// Condicao para execucao do gatilho
						  "01")// Sequencia do gatilho (usado para identificacao no caso de erro)
    oStruA1M:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

    aAux := FwStruTrigger("A1M_COD" ,;// Campo Dominio
						  "A1M_DESC" ,;// Campo de Contradominio
						  "SB1->B1_DESC",;// Regra de Preenchimento
						  .F.,;// Se posicionara ou nao antes da execucao do gatilhos
						  "SB1",;// Alias da tabela a ser posicionada
						  1,; // Ordem da tabela a ser posicionada
						  "M->A1M_COD",;// Chave de busca da tabela a ser posicionada
						  Nil,;// Condicao para execucao do gatilho
						  "02")// Sequencia do gatilho (usado para identificacao no caso de erro)
    oStruA1M:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
    
    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( cModelA1M, NIL, oStruA1M )

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
    oModel:AddFields( cModelA1K, cModelA1M, oStruA1K, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
    oModel:AddGrid( cModelA1E, cModelA1M, oStruA1E, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( cModelA1K, { { "A1K_FILIAL", "xFilial('A1K')" } , { "A1K_CODPAI", "A1M_COD" } } , A1K->( IndexKey( 1 ) ) )
    
    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( cModelA1E, { { "A1E_FILIAL", "xFilial('A1E')" } , { "A1E_COD", "A1M_COD" } } , A1E->( IndexKey( 1 ) ) )
    // Liga o controle de nao repeticao de linha
    oModel:GetModel(cModelA1E):SetUniqueLine( { "A1E_FILIAL","A1E_COD", "A1E_URL" } )
    
    oModel:SetPrimaryKey( { "A1M_FILIAL", "A1M_COD" } )

    // Não permite excluir linha
    oModel:GetModel(cModelA1E):SetNoDeleteLine(.T.)
    
    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription( cTitle )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( cModelA1M ):SetDescription(cTitleA1M)
    oModel:GetModel( cModelA1K ):SetDescription(cTitleA1K)    
    oModel:GetModel( cModelA1E ):SetDescription(cTitleA1E)    

    oModel:GetModel(cModelA1E):SetOptional(.T.)   

   //Inicio - Marcos Morais - 27/05/2020 
    
    // validacoes de campo
	//A1K_SQLTIT
	bVlKSQLTIT := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1K_SQLTIT)' )
	//A1K_SQLPES
	bVlKSQLPES := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1K_SQLPES)' )	
	//A1M_SQLTIT	
	bVlMSQLTIT := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1M_SQLTIT)' )		
	//A1M_SQLMAR	
	bVlMSQLMAR := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1M_SQLMAR)' )		
	//A1M_SQLHTM	
	bVlMSQLHTM := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1M_SQLHTM)' )		
	//A1M_SQLTP	
	bVlMSQLTP  := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1M_SQLTP)' )		
	//A1M_SQLTAG
	bVlMSQLTAG := FWBuildFeature( STRUCT_FEATURE_VALID, 'ShpChkSql(M->A1M_SQLTAG)' )	
		
   	oStruA1K:SetProperty('A1K_SQLTIT' , MODEL_FIELD_VALID, bVlKSQLTIT)
	oStruA1K:SetProperty('A1K_SQLPES' , MODEL_FIELD_VALID, bVlKSQLPES)   
   	oStruA1M:SetProperty('A1M_SQLTIT' , MODEL_FIELD_VALID, bVlMSQLTIT)  
   	oStruA1M:SetProperty('A1M_SQLMAR' , MODEL_FIELD_VALID, bVlMSQLMAR)
	oStruA1M:SetProperty('A1M_SQLHTM' , MODEL_FIELD_VALID, bVlMSQLHTM)   
   	oStruA1M:SetProperty('A1M_SQLTP'  , MODEL_FIELD_VALID, bVlMSQLTP) 
   	oStruA1M:SetProperty('A1M_SQLTAG' , MODEL_FIELD_VALID, bVlMSQLTAG)    	
   	//Fim - Marcos Morais - 27/05/2020 
   	 
    oStruA1M:SetProperty("A1M_GRADE" , MODEL_FIELD_INIT, {|| "2"})
    oStruA1M:SetProperty("A1M_COD"   , MODEL_FIELD_VALID , {|| ExistCpo("SB1") .And. VldNotGrid(FwFldGet('A1M_COD')) .AND. !ShpExisA1M(M->A1M_COD) })
    oStruA1K:SetProperty("A1K_SEQUEN", MODEL_FIELD_INIT, {|| "001"}) 
    
    
Return oModel

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 29/04/2020
    /*/
Static Function ViewDef()
    // Cria a estrutura a ser usada na View
    Local oStruA1M  := FWFormStruct( 2, "A1M" )
    Local oStruA1K  := FWFormStruct( 2, "A1K" )
    Local oStruA1E  := FWFormStruct( 2, "A1E" )
    Local cViewA1M  := VIEW_A1M
    Local cViewA1K  := VIEW_A1K
    Local cViewA1E  := VIEW_A1E
    Local cModelA1M := MODEL_A1M
    Local cModelA1K := MODEL_A1K
    Local cModelA1E := MODEL_A1E
    Local cBoxGrid  := "GRID"
    Local cBoxProd  := "PRODUCT"
    Local cBoxImage := "IMAGE"

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel := FWLoadModel( FunName() )
    Local oView  := Nil 

    oStruA1E:RemoveField("A1E_COD")

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField(cViewA1M , oStruA1M, cModelA1M)

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oView:AddField(cViewA1K , oStruA1K, cModelA1K)
    oView:AddGrid(cViewA1E , oStruA1E, cModelA1E)
    

    // Criar "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox(cBoxGrid , 30)
    oView:CreateHorizontalBox(cBoxProd , 40) 
    oView:CreateHorizontalBox(cBoxImage, 30) 

    /*oView:CreateVerticalBox( 'EMBAIXOESQ', 93, 'PEDIDO' )
    oView:CreateVerticalBox( 'EMBAIXODIR', 07, 'PEDIDO' )*/   

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView(cViewA1M, cBoxGrid)
    oView:SetOwnerView(cViewA1K, cBoxProd)
    oView:SetOwnerView(cViewA1E, cBoxImage)
    

    oView:EnableTitleView(cViewA1M)
    oView:EnableTitleView(cViewA1K)
    oView:EnableTitleView(cViewA1E)
    
    oView:AddIncrementField(cViewA1E, 'A1E_SEQUEN')

    oStruA1M:SetProperty("A1M_COD"   , MVC_VIEW_LOOKUP , "SB1")
    oStruA1K:SetProperty("A1K_COD"   , MVC_VIEW_CANCHANGE , .F.)
    
    //oStruA1K:SetProperty("A1K_CODPAI", MVC_VIEW_CANCHANGE , .F.)
    oStruA1K:SetProperty("A1K_SEQUEN", MVC_VIEW_CANCHANGE , .F.)
        
Return oView

/*/{Protheus.doc} IntegShp
    Run Shopify integration
    @type  Static Function
    @author Yves Oliveira
    @since 29/04/2020
    /*/
Static Function IntegShp()
    
    Local cMessage := ""
    Local cSearch  := xFilial("A1K") + A1M->A1M_COD
    Local oInt     := Nil
    Local lOk      := .T.
    Local aArea    := {}
    DbSelectArea("A1K")
    A1K->(DbSetOrder(2))//A1K_FILIAL+A1K_CODPAI
    A1K->(DbSeek(cSearch))

    While !A1K->(Eof()) .And. A1K->(A1K_FILIAL + A1K_CODPAI) == cSearch .And. lOk
        aArea := A1K->(GetArea())
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
        If SB1->(DbSeek(xFilial("SB1") + A1K->A1K_COD))
            oInt := ShpInteg():New()
	        cMessage := AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC)
            MsgRun( cMessage, STR0001, {|| lOk := oInt:intProduct(SB1->(Recno()))  } )//"Integrating with Shopify..."

        EndIf
        RestArea(aArea)
        A1K->(DbSkip()) 
    EndDo
    If lOk
        MSGINFO( STR0069, "" )//"Process finished!"
    EndIf
Return


/*/{Protheus.doc} FillProd
    Fill the product variant
    @type  Static Function
    @author Yves Oliveira
    @since 30/04/2020
    /*/
Static Function FillProd(cProduct)
    Local oModel  := FWModelActive()
	Local oModA1K := oModel:GetModel(MODEL_A1K)
	
    oModA1K:SetValue("A1K_COD", cProduct)

Return

/*/{Protheus.doc} VldNotGrid
    Validate that the product does not belongs to a grid
    @type  Static Function
    @author Yves Oliveira
    @since 30/04/2020
    /*/
Static Function VldNotGrid(cProduct)    
    Local lOk    := .T.
    Local cError := ""

    If ShpIsGrid(cProduct)
        lOk := .F.
        cError := STR0090 + ": " + cProduct//"The product belongs to a grid."
        Help( ,, 'Help',, cError, 1, 0 )
    EndIf
 
Return lOk
