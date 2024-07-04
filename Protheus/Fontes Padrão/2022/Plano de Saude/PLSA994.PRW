#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA994.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA994

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------
Function PLSA994()

    Local oBrowse

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( 'B7G' )
    oBrowse:SetDescription( STR0001 ) //"Configurações Integrações"
    oBrowse:SetMenuDef( 'PLSA994' )

    oBrowse:Activate()

Return NIL            


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------         
Static Function MenuDef()

    Private aRotina := {}
  
    aAdd( aRotina, { STR0002 , 'PesqBrw'         , 0, 1, 0, .T. } ) //"Pesquisar"
    aAdd( aRotina, { STR0003 , 'VIEWDEF.PLSA994' , 0, 2, 0, NIL } ) //"Visualizar"
    aAdd( aRotina, { STR0004 , 'VIEWDEF.PLSA994' , 0, 3, 0, NIL } ) //"Incluir"
    aAdd( aRotina, { STR0005 , 'VIEWDEF.PLSA994' , 0, 4, 0, NIL } ) //"Alterar"
    aAdd( aRotina, { STR0006 , 'VIEWDEF.PLSA994' , 0, 5, 0, NIL } ) //"Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------                  
Static Function ModelDef()

	Local oModel	
	Local oStruB7G := FWFormStruct( 1, 'B7G' )
	
	// Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA994',,{ |oModel| PLGrv994( oModel ) } )
		
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'B7GMASTER',NIL, oStruB7G )
	oModel:SetPrimaryKey( {"B7G_CODOPE"} )
	
	oModel:SetDescription( STR0001 ) //"Configurações Integrações"
    oModel:GetModel( 'B7GMASTER' ):SetDescription( STR0001 ) //"Configurações Integrações"
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author  PLS TEAM
@version P11
@since   01/10/13
/*/
//-------------------------------------------------------------------     
Static Function ViewDef()  

    Local oModel := FWLoadModel( 'PLSA994' ) 
    Local oStruB7G := FWFormStruct( 2, 'B7G' ) 
    Local oView := FWFormView():New()
    
    // Define qual o Modelo de dados será utilizado na View 
    oView:SetModel( oModel ) 
    oView:AddField( 'VIEW_B7G', oStruB7G, 'B7GMASTER' ) 
    
    oView:CreateHorizontalBox( 'TELA' , 100 ) //Criar um "box" horizontal para receber algum elemento da view    
    oView:SetOwnerView( 'VIEW_B7G', 'TELA' ) //Relaciona o identificador (ID) da View com o "box" para exibição  

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} IncMatProc
Processo ao inclusao da matricula do solicitante

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//------------------------------------------------------------------- 
Static Function PLGrv994(oModel)

    Local oModelB7G  := oModel:GetModel( 'B7GMASTER' )  
    Local lRet       := .T.
    Local cPassMensU := Alltrim(oModelB7G:GetValue("B7G_MSPASS"))
    Local cPassMensC := ''

    //Criptografia de senha para Mensageria
    if !Empty(cPassMensU)
        oPassKey := PLMensCont():New()
        cPassMensC := oPassKey:cryptKey(cPassMensU)
        if Alltrim(cPassMensC) != Alltrim(B7G->B7G_MSPASS)
            oModel:SetValue( 'B7GMASTER', 'B7G_MSPASS', cPassMensC )
        endIf
    endIf

Return lRet