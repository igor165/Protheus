#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "OGA850.CH"


/*{Protheus.doc} OGA850
//TODO Descrição auto-gerada.
@author thiago.rover
@since 12/07/2018
@version undefined

@type function*/
Function OGA850()

	Local oMBrowse	:= Nil
	Private lSetOrd 	:= .F.

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NBQ" )
	oMBrowse:SetMenuDef( "OGA850" )
	oMBrowse:SetDescription( STR0001 ) //"Cadastro de Regiões"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

 Return( Nil )


/*{Protheus.doc} MenuDef
Função de Menu
@author thiago.rover
@since 12/07/2018
@version undefined

@type function*/
Static Function MenuDef()

	Local aRotina := {}
	aAdd( aRotina, { STR0002 , 'VIEWDEF.OGA850', 0, 2, 0, NIL } )// Visualisar
	aAdd( aRotina, { STR0003 , 'VIEWDEF.OGA850', 0, 3, 0, NIL } )// Incluir
	aAdd( aRotina, { STR0004 , 'VIEWDEF.OGA850', 0, 4, 0, NIL } )// Alterar
	aAdd( aRotina, { STR0005 , 'VIEWDEF.OGA850', 0, 5, 0, NIL } )// Excluir 
	aAdd( aRotina, { STR0006 , 'VIEWDEF.OGA850', 0, 8, 0, NIL } )// Imprimir

Return aRotina



/*{Protheus.doc} ModelDef
Função do Modelo
@author thiago.rover
@since 12/07/2018
@version undefined

@type function*/
Static Function ModelDef()

	Local oStruNBQ 	:= FWFormStruct( 1, "NBQ")
	Local oStruNBR 	:= FWFormStruct( 1, "NBR")
	Local oModel   := MPFormModel():New("OGA850", , , /*{|oModel| GravaDados(oModel)}*/) // Instancia o Model
	
	oStruNBR:AddTrigger( "NBR_ESTADO", "NBR_CODMUN", { || .T. }, { | x | fTrgNBR( x ) } )
	oStruNBR:AddTrigger( "NBR_ESTADO", "NBR_NOMMUN", { || .T. }, { | x | fTrgNBR( x ) } )
	
	oModel:SetDescription( STR0007 ) //"Cadastro de Regiões"
	//NBQ - TABELA MESTRE
	oModel:AddFields( 'NBQOGA850', /*cOwner*/, oStruNBQ, /*bPre*/,/*bPost*//*{| oModel | OGA850POS( oModel )}*/)// validações pre, pos modelo 
	oModel:SetPrimaryKey( { "NBQ_FILIAL", "NBQ_CODREG" } )
	oModel:GetModel( 'NBQOGA850' ):SetDescription( STR0001 )  //"Cadastro de Regiões"
	
    //NBR - TABELA FILHA DE NBQ
    oModel:AddGrid( 'NBROGA850', 'NBQOGA850', oStruNBR ,/*bPre*/,/*bPost*/{| oModel | OGA850POS( oModel ) })// validações pre, pos modelo 
	oModel:GetModel( 'NBROGA850' ):SetDescription( STR0008 )  //"Relacionamento entre tabelas"
	oModel:GetModel( 'NBROGA850' ):SetUniqueLine( { "NBR_CODREG", "NBR_ESTADO", "NBR_CODMUN" } )
	oModel:GetModel( 'NBROGA850' ):SetOptional( .T. )
	oModel:SetRelation('NBROGA850', { { 'NBR_FILIAL', 'xFilial( "NBR" )' }, { 'NBR_CODREG', 'NBQ_CODREG' } }, NBR->( IndexKey( 1 ) ) )

Return ( oModel )


/*{Protheus.doc} ViewDef
Função da View 
@author thiago.rover
@since 12/07/2018
@version undefined

@type function*/
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( "OGA850" )
	Local oView    	:= FWFormView():New()

	Local oStruNBQ	:= FWFormStruct( 2, "NBQ" )
	Local oStruNBR	:= FWFormStruct( 2, "NBR" )
	
	oStruNBQ:RemoveField( "NBQ_FILIAL" )
	oStruNBR:RemoveField( "NBR_CODREG" )
	
    oView:SetModel( oModel )
	oView:AddField("OGA850_NBQ", oStruNBQ  , "NBQOGA850")
	oView:AddGrid ("OGA850_NBR", oStruNBR  , "NBROGA850")
	
	oView:CreateVerticallBox("TELANOVA" , 100)
	
	oView:CreateHorizontalBox("SUPERIOR" , 30, "TELANOVA")
	oView:CreateHorizontalBox("INFERIOR" , 70, "TELANOVA")

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox("DIREITA" , 50, "INFERIOR")
	oView:CreateVerticalBox("ESQUERDA" , 50, "INFERIOR")

	oView:SetOwnerView("OGA850_NBQ", "SUPERIOR")
	oView:SetOwnerView("OGA850_NBR", "INFERIOR")
	
	oView:EnableTitleView("OGA850_NBQ")
	oView:EnableTitleView("OGA850_NBR")

    oView:SetCloseOnOk( {||.T.} )

Return (oView) 


/*{Protheus.doc} OGA850POS
Função de pos-validação
@author thiago.rover
@since 16/07/2018
@version undefined

@type function*/
Static Function OGA850POS(oModel)
	
	Local oModelNBR	  := oModel:GetModel( "NBROGA850" )
	Local nX          := 0
	Local lRet        := .T.
	Local cCodEstado  := ""
	
	For nX := 1 to oModelNBR:Length()

		cCodEstado := ALLTRIM(oModelNBR:GetValue('NBR_ESTADO' , nX) )
		
		If cCodEstado == ""	
			 Help('',1,STR0009,,STR0010,1,0) //#"Ajuda"#"Não é permitido salvar linha(s) vazia(s)"
			 lRet := .f.
		EndIf
	Next nX

Return lRet

/*{Protheus.doc} OGA850ValUser()
(Função de validação da Grid NBR)
@type function
@author thiago.rover
@since 23/01/2018
@version 1.0
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function OGA850ValUser() //Projeto SLC
	Local oModel      := FwModelActive()
	Local oModelNBR	  := oModel:GetModel( "NBROGA850" )
	Local nX          := 0
	Local aGrid       := {}
	Local lRet        := .T.
	Local cCodEstado  := ""
	Local cCodMun     := ""

	For nX := 1 to oModelNBR:Length()

		cCodEstado   := ALLTRIM(oModelNBR:GetValue('NBR_ESTADO' , nX) )
		cCodMun      := ALLTRIM(oModelNBR:GetValue('NBR_CODMUN' , nX) )
		
		If ASCAN(aGrid, { |x| x[1] == cCodEstado .and. x[2] == cCodMun })		
			Help("" ,1 ,".OGA850000001.") //".OGA850000001."###"Operação não permitida pois o municipio já foi informado"	
		    lRet := .F.
		    Exit
		EndIf

		//considera todas as linhas, ate mesmo as deletadas. Caso delete uma linha e tente informar uma linha igual a deletada não irá permitir, pois basta remover o delete.
		aAdd(aGrid, {cCodEstado,;
					 cCodMun } ) 	

	Next nX
	
Return lRet


/*{Protheus.doc} fTrgNBR
Função que limpa os campos no gatilho
@author thiago.rover
@since 16/07/2018
@version undefined

@type function*/
Static Function fTrgNBR()
Return lRetorno := ""
