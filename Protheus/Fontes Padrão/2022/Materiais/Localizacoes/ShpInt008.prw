#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ShpInt008
    (long_description)
    @type  Function
    @author Yves Oliveira
    @since 13/04/2020
    /*/
Function ShpInt008()
    Local oBrowse
    Private cTitle := STR0088//"Product Grid Setup"
    
    If !IntegraShp()
	    Return .F. 
    Endif

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias("A1M")
    oBrowse:SetDescription(cTitle)
    oBrowse:SetFilterDefault("A1M_GRADE <> '2'")
    oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 13/04/2020
    /*/
Static Function MenuDef()
    Local aRotina := {}

    aAdd( aRotina, { STR0070, "VIEWDEF.SHPINT008", 0, 2, 0, NIL } )//"Visualizar"
    aAdd( aRotina, { STR0071, "VIEWDEF.SHPINT008", 0, 3, 0, NIL } )//"Incluir"
    aAdd( aRotina, { STR0072, "VIEWDEF.SHPINT008", 0, 4, 0, NIL } )//"Alterar"
    aAdd( aRotina, { STR0073, "INTEGSHP(.F.)", 0, 4, 0, NIL } )//"Integrate"
    aAdd( aRotina, { STR0099, "Processa( { || INTEGSHP(.T.)  })", 0, 5, 0, NIL } )//"Integrate"
    

Return aRotina

/*/{Protheus.doc} ModelDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 13/04/2020
    /*/
Static Function ModelDef(param_name)
    Local oStruA1M  := FWFormStruct( 1, "A1M", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruA1K  := FWFormStruct( 1, "A1K", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruA1E  := FWFormStruct( 1, "A1E", /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel    := Nil
    Local cModelA1M := "A1MMASTER"
    Local cModelA1K := "A1KDETAIL"
    Local cModelA1E := "A1EDETAIL"
    Local cTitleA1M := STR0075//"Grid"
    Local cTitleA1K := STR0087//"Products"
    Local cTitleA1E := STR0076//"Images"
    Local bVldLine  := {|oModel, nLine| VldPrdGrid(oModel, nLine)}
    Local bPosVld   := {|oModel| ModelOk(oModel)}

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( FunName(), /*bPreValidacao*/, bPosVld/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    
    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( cModelA1M, NIL, oStruA1M )

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
    oModel:AddGrid( cModelA1K, cModelA1M, oStruA1K, /*bLinePre*/, bVldLine/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
    oModel:AddGrid( cModelA1E, cModelA1M, oStruA1E, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( cModelA1K, { { "A1K_FILIAL", "xFilial('A1K')" } , { "A1K_CODPAI", "A1M_COD" } } , A1K->( IndexKey( 1 ) ) )
    // Liga o controle de nao repeticao de linha
    oModel:GetModel(cModelA1K):SetUniqueLine( { "A1K_FILIAL","A1K_COD" } )
    
    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( cModelA1E, { { "A1E_FILIAL", "xFilial('A1E')" } , { "A1E_COD", "A1M_COD" } } , A1E->( IndexKey( 1 ) ) )
    // Liga o controle de nao repeticao de linha
    oModel:GetModel(cModelA1E):SetUniqueLine( { "A1E_FILIAL","A1E_COD", "A1E_URL" } )
    
    oModel:SetPrimaryKey( { "A1M_FILIAL", "A1M_COD" } )

    // Não permite excluir linha
    oModel:GetModel(cModelA1K):SetNoDeleteLine(.T.)
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
   	
    oStruA1M:SetProperty("A1M_COD"    , MODEL_FIELD_VALID , {|| VAZIO() .OR. !ShpExisA1M(M->A1M_COD) })
   	 //Fim - Marcos Morais - 27/05/2020 
   	 
    oStruA1M:SetProperty("A1M_GRADE" , MODEL_FIELD_INIT, {|| "1"})    
   
Return oModel

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 13/04/2020
    /*/
Static Function ViewDef()
    // Cria a estrutura a ser usada na View
    Local oStruA1M  := FWFormStruct( 2, "A1M" )
    Local oStruA1K  := FWFormStruct( 2, "A1K" )
    Local oStruA1E  := FWFormStruct( 2, "A1E" )
    Local cViewA1M  := "VIEW_A1M"
    Local cViewA1K  := "VIEW_A1K"
    Local cViewA1E  := "VIEW_A1E"
    Local cModelA1M := "A1MMASTER"
    Local cModelA1K := "A1KDETAIL"
    Local cModelA1E := "A1EDETAIL"
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
    oView:AddGrid(cViewA1K , oStruA1K, cModelA1K)
    oView:AddGrid(cViewA1E , oStruA1E, cModelA1E)
    

    // Criar "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox(cBoxGrid , 30)
    oView:CreateHorizontalBox(cBoxProd , 40) 
    oView:CreateHorizontalBox(cBoxImage, 30) 


    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView(cViewA1M, cBoxGrid)
    oView:SetOwnerView(cViewA1K, cBoxProd)
    oView:SetOwnerView(cViewA1E, cBoxImage)
    

    oView:EnableTitleView(cViewA1K)
    oView:EnableTitleView(cViewA1E)
    
    oView:AddIncrementField(cViewA1K, 'A1K_SEQUEN')
    oView:AddIncrementField(cViewA1E, 'A1E_SEQUEN')

    oStruA1M:SetProperty("A1M_COD", MVC_VIEW_LOOKUP , "SB4")
        
Return oView


/*/{Protheus.doc} VldPrdGrid
    (long_description)
    @type  Static Function
    @author Yves Oliveira
    @since 14/04/2020
    /*/
Static Function VldPrdGrid(oModel, nLine)
    Local lOk      := .T.
    Local cProduct := ""
    Local cError   := ""

    cProduct := oModel:GetValue("A1K_COD")
    cCodPai  := M->A1M_COD
    If !Empty(cProduct)
        lOk := ShpIsGrid(cProduct)
        If !lOk
            cError := STR0074 + ": " + cProduct//"The product does not belong to a grid."
            oModel:GetModel():SetErrorMessage(cError)
            Help( ,, 'Help',, cError, 1, 0 )
            Return lOk            
        EndIf
        //Verifica se existe o produto em outra configuração de grade.
        lOk := ShpInOGrid(cProduct, cCodPai)
        If lOk
            cError := STR0096 + ": " + cProduct//"The product already belongs to a grid."
            oModel:GetModel():SetErrorMessage(cError)
            Help( ,, 'Help',, cError, 1, 0 )
            Return !lOk    
        Else
            lOk := .T.    
        EndIf        
    EndIf

Return lOk

/*/{Protheus.doc} ModelOk
    Function to validate post fill model
    @type  Static Function
    @author Yves Oliveira
    @since 17/04/2020
    /*/
Static Function ModelOk(oModel)
    Local lRet       := .T.
    Local oModA1K    := oModel:GetModel("A1KDETAIL")
    Local cCurrGroup := ""
    Local cRefGroup  := ""
    Local cProduct   := ""
    Local nI         := 0

    For nI := 1 To oModA1K:Length()
        oModA1K:GoLine( nI )
        cProduct   := oModA1K:GetValue("A1K_COD")
        cCurrGroup := GetAdvFVal("SB1","B1_GRUPO", xFilial("SB1") + cProduct ,1)
        If Empty(cRefGroup)
            cRefGroup := cCurrGroup
        EndIf
        If cRefGroup <> cCurrGroup
            lRet := .F.
            Help( ,, 'Help',, STR0077, 1, 0 )//"All products must be in the same group."
            Exit
        EndIf
    Next nI
    
Return lRet
