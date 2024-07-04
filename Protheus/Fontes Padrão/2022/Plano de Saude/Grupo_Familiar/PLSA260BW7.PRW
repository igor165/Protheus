#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BW7
Funcao para abrir a tela de Cobertura da Familia - Grupos de Quantidades
@author Totver
@since 10/09/19
@version P12
/*/
//-----------------------------------------------------------------------
Function PLSA260BW7(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BW7' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BW7 
@author  Totver
@version P12
@since   10/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BW7 
@author  Totver
@version P12
@since   10/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,"BA1")
	Local oStruBW7 		:= FWFormStruct(1,"BW7")
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBW7	:= {"BW7_CODINT","BW7_CODEMP","BW7_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
		
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BW7')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBW7)
		oStruBW7 := CriaCampMVC(1,oStruBW7,aCamposBW7[nNx]) 
	Next
    
	oModel:addFields("BA1MASTER" , ,oStruBA1) 
   	oModel:AddGrid(  "BW7DETAIL" , "BA1MASTER", oStruBW7)
	
	oModel:GetModel( "BW7DETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BW7DETAIL', { { "BW7_FILIAL" 	, "xFilial( 'BW7' )" },;
									{"BW7_CODINT" , "BA1_CODINT" },;
									{"BW7_CODEMP" , "BA1_CODEMP" },;
									{"BW7_MATRIC" , "BA1_MATRIC"} },;									
									BW7->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( "BA1MASTER" ):SetDescription( "Familia" )
    oModel:GetModel( "BW7DETAIL" ):SetDescription( "Grupo de Quantidades" )

	oModel:GetModel( "BA1MASTER" ):SetOnlyQuery(.T.)
    oModel:GetModel( "BA1MASTER" ):SetOnlyView(.T.)	
	    
    oModel:SetPrimaryKey( { "BW7_FILIAL", "BW7_CODINT", "BW7_CODEMP", "BW7_MATRIC","BW7_CODGRU" } )
    oStruBW7:setProperty("BW7_CODGRU", MODEL_FIELD_VALID ,{ || ExistCpo("BW2",BG9->BG9_CODINT+oModel:GetValue("BW7DETAIL", "BW7_CODGRU"),1) })

    // .And. PLSVldGD()
	
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   10/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|"})
	Local oStruBW7 := FWFormStruct(2,"BW7")
    Local oModel   := FWLoadModel("PLSA260BW7")
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField( "VIEW_BA1" , oStruBA1, "BA1MASTER")
    oView:AddGrid(  "VIEW_BW7" , oStruBW7, "BW7DETAIL")        
    
    oStruBA1:SetNoFolder()
   	oStruBW7:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 25)
	oView:CreateHorizontalBox("INFERIOR", 75)
	
	oView:EnableTitleView("VIEW_BW7","Grupo de Quantidades")
	
	oView:SetOwnerView( "VIEW_BA1", "SUPERIOR")
	oView:SetOwnerView( "VIEW_BW7", "INFERIOR")
	
	oView:EnableTitleView("VIEW_BA1","Familia")
	oView:EnableTitleView("VIEW_BW7","Grupo de Quantidades")

Return oView