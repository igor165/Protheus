#INCLUDE "JURA250.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA250
Follow-ups Automáticos 

@author Beatriz Gomes
@since 16/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA250()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )      //Regras de Follow-up Automatico 
	oBrowse:SetAlias( "O0J" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0J" )
	JurSetBSize( oBrowse )
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef 
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Beatriz Gomes
@since 16/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA250", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA250", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA250", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA250", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA250", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Follow-ups Automáticos

@author Beatriz Gomes
@since 16/01/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  := FWLoadModel( "JURA250" )
	Local oStructO0J := FWFormStruct( 2, "O0J" )
	Local oStructO0K := FWFormStruct( 2, "O0K" )

	If (oStructO0K:HasField( "O0K_CFWAUT" ))
		oStructO0K:RemoveField('O0K_CFWAUT')
	Endif 
	JurSetAgrp( 'O0J',, oStructO0J)
	
	oView := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 ) 
	
	oView:AddField( "JURA250_MASTER" , oStructO0J, "O0JMASTER"  )
	oView:AddGrid(  "JURA250_DETAIL" , oStructO0K, "O0KDETAIL" )
	
	oView:CreateHorizontalBox( "FORMMASTER" , 30 )
	oView:CreateHorizontalBox( "FORMDETAIL" , 70 )
		
	oView:SetOwnerView( "O0JMASTER" , "FORMMASTER" )
	oView:SetOwnerView( "O0KDETAIL" , "FORMDETAIL" )
	
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Follow-ups Automáticos

@author Beatriz Gomes
@since 16/01/2018
@version 1.0

@obs O0JMASTER - Dados do Follow-ups Automáticos
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructO0J := FWFormStruct( 1, "O0J" )
	Local oStructO0K := FWFormStruct( 1, "O0K" ) 
		
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	If (oStructO0K:HasField( "O0K_CFWAUT" ))
		oStructO0K:RemoveField('O0K_CFWAUT')
	Endif 
	
	oModel:= MPFormModel():New( "JURA250", /*Pre-Validacao*/, {|oX| JA250TOK(oX)}, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0007 )//"Modelo de Dados"  
	 
	oModel:AddFields( "O0JMASTER", /*NIL*/, oStructO0J, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid( "O0KDETAIL", "O0JMASTER" /*cOwner*/, oStructO0K, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModel:GetModel("O0JMASTER"):SetDescription( STR0009 )  //"Regra do Follow-up Automático
	oModel:GetModel("O0KDETAIL"):SetDescription( STR0011  ) //modelos disparados
	
	oModel:SetPrimaryKey( { "O0JMASTER", "O0J_COD" } )
	oModel:SetPrimaryKey( { "O0KDETAIL", "O0K_COD" } ) 
	
	oModel:SetRelation("O0KDETAIL", {{"O0K_FILIAL", "XFILIAL('O0K')" }, {"O0K_CFWAUT", "O0J_COD" }}, O0K->( IndexKey( 1 ))) // O0K_FILIAL + O0K_COD + O0K_CFWAUT
	
	oModel:GetModel( "O0KDETAIL" ):SetUniqueLine( { "O0K_CODMOD" } )
	oModel:GetModel("O0KDETAIL"):SetDelAllLine( .T. ) 

	oModel:SetOptional( "O0KDETAIL" , .T. )
		
	JurSetRules( oModel, "O0KDETAIL",, "O0K" )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA250TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author leandro.silva
@since 03/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA250TOK(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local cTpAss    := FwFldGet('O0J_TIPOAS')
Local cArea     := FwFldGet('O0J_CAREAJ')
Local cAssunto  := FwFldGet('O0J_COBJET')
Local nCt       := 0
Local oModelGrid := oModel:GetModel("O0KDETAIL")
 
	If oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4
		
		If oModel:GetOperation() == 3
			O0J->( dbSetOrder(2) )
			IF (O0J->( dbSeek(xFilial("O0J")+cTpAss + cArea + cAssunto) ))
				lRet := .F.
				JurMsgErro(STR0008,,STR0010) //"Já existem registros com as informações utilizadas"
			EndIF
		EndIF
		
	For nCt := 1 To oModelGrid:GetQtdLine()
	
		oModelGrid:GoLine( nCt )
		
		If !oModelGrid:IsDeleted()    
			If Empty(oModel:GetValue('O0KDETAIL','O0K_CODMOV'))
				JurMsgErro(STR0012+RetTitle('O0K_CODMOV'))
				lRet := .F.
			ElseIf Empty(oModel:GetValue('O0KDETAIL','O0K_CODMOD'))
				JurMsgErro(STR0012+RetTitle('O0K_CODMOD'))
				lRet := .F.
			EndIf			
		EndIf
	Next
EndIf

RestArea(aArea)
		
Return(lRet)
