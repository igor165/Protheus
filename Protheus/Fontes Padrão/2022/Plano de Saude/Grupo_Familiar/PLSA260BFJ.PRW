#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFJ
Funcao para abrir a tela de Cobertura da Familia - Classe de carência
@author DEV TOTVS
@since 10/09/19
@version P12
/*/
//-----------------------------------------------------------------------
Function PLSA260BFJ(lAutomato)

	Local oBrowse
	Default lAutomato := .F.
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFJ' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFJ 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFJ 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()		

	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,"BA1")
	Local oStruBFJ 		:= FWFormStruct(1,"BFJ")
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBFJ	:= {"BFJ_CODINT","BFJ_CODEMP","BFJ_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BFJ')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBFJ)
		oStruBFJ := CriaCampMVC(1,oStruBFJ,aCamposBFJ[nNx]) 
	Next
    
	oModel:addFields("BA1MASTER" , ,oStruBA1) 
   	oModel:AddGrid(  "BFJDETAIL" , "BA1MASTER", oStruBFJ)
	
	oModel:GetModel( "BFJDETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BFJDETAIL', { { "BFJ_FILIAL" 	, "xFilial( 'BFJ' )" },;
									{"BFJ_CODINT" , "BA1_CODINT" },;
									{"BFJ_CODEMP" , "BA1_CODEMP" },;
									{"BFJ_MATRIC" , "BA1_MATRIC"} },;									
									BFJ->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( "BA1MASTER" ):SetDescription( "Familia" )
    oModel:GetModel( "BFJDETAIL" ):SetDescription( "Classe de Carência" )

	oModel:GetModel( "BA1MASTER" ):SetOnlyQuery(.T.)
    oModel:GetModel( "BA1MASTER" ):SetOnlyView(.T.)	

	oModel:GetModel( 'BFJDETAIL' ):SetUniqueLine( { 'BFJ_CLACAR' } )
	    
    oModel:SetPrimaryKey( { "BFJ_FILIAL", "BFJ_CODINT", "BFJ_CODEMP", "BFJ_MATRIC","BFJ_CLACAR" } )

    oStruBFJ:setProperty("BFJ_CLACAR", MODEL_FIELD_VALID ,{ || BFJValid("BFJ_CLACAR")})
	
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef() 

	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|"})
	Local oStruBFJ := FWFormStruct(2,"BFJ")
    Local oModel   := FWLoadModel("PLSA260BFJ")
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField("VIEW_BA1" , oStruBA1, "BA1MASTER")
    oView:AddGrid( "VIEW_BFJ" , oStruBFJ, "BFJDETAIL")        
    
    oStruBA1:SetNoFolder()
   	oStruBFJ:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 20)
	oView:CreateHorizontalBox("INFERIOR", 80)
	
	oView:EnableTitleView("VIEW_BFJ","Classe de Carência")
	
	oView:SetOwnerView( "VIEW_BA1", "SUPERIOR")
	oView:SetOwnerView( "VIEW_BFJ", "INFERIOR")
	
	oView:EnableTitleView("VIEW_BA1","Familia")
	oView:EnableTitleView("VIEW_BFJ","Classe de Carência")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} BFJValid
X3_VALID dos campos da tabela BFJ
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------

Static Function BFJValid(cCampo)
	
	Local lRet 		:= .F.
	Local oModel	:= FWModelActive() // Carrega o Modelo Ativo

	If cCampo == "BFJ_CLACAR"
		lRet := BDL->(ExistCpo("BDL",PLSINTPAD()+oModel:GetValue("BFJDETAIL","BFJ_CLACAR"),1))
	EndIf
	
Return lRet