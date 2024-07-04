#INCLUDE "JURA012.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA012
Juiz

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA012()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQH" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQH" )
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

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA012", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA012", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA012", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA012", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA012", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Juiz

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel      := FWLoadModel( "JURA012" )
Local oStructNQH := FWFormStruct( 2, "NQH" )  
Local oStructNTD := FWFormStruct( 2, "NTD" )  
                                               
//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
oStructNTD:RemoveField('NTD_CODJUI')  

JurSetAgrp( 'NQH',, oStructNQH )

oView := FWFormView():New()     

oView:SetModel( oModel )
oView:SetDescription( STR0007 ) //"Juiz"

oView:AddField("JURA012_MASTER" , oStructNQH, "NQHMASTER" )
oView:AddGrid( "JURA012_DETAIL" , oStructNTD, "NTDDETAIL" )     

oView:CreateHorizontalBox( "FORMMASTER" , 60 )
oView:CreateHorizontalBox( "FORMDETAIL" , 40 )

oView:SetOwnerView( "NQHMASTER" , "FORMMASTER" )   
oView:SetOwnerView( "NTDDETAIL" , "FORMDETAIL" )   
                                                    
oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Juiz

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0

@obs NQHMASTER - Dados do Juiz

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQH := FWFormStruct( 1, "NQH" ) 
Local oStructNTD := FWFormStruct( 1, "NTD" ) 
                                              
oStructNTD:RemoveField("NTD_CODJUI")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA012", /*Pre-Validacao*/, {|oX| JURA012TOK(oX)} /*Pos-Validacao*/,{|oX|JA012Commit(oX)} /*Commit*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Juiz"

oModel:AddFields("NQHMASTER", NIL, oStructNQH, /*Pre-Validacao*/, /*Pos-Validacao*/ )   
oModel:AddGrid( "NTDDETAIL", "NQHMASTER" /*cOwner*/, oStructNTD, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel("NQHMASTER"):SetDescription( STR0009 ) //"Dados de Juiz"
oModel:GetModel("NTDDETAIL"):SetDescription( STR0009 ) //"Dados de Juiz"     

oModel:SetRelation("NTDDETAIL", {{"NTD_FILIAL", "XFILIAL('NTD')" }, {"NTD_CODJUI", "NQH_COD" }}, NTD->( IndexKey( 1 )))   
                                                 
oModel:GetModel("NTDDETAIL" ):SetUniqueLine( { "NTD_CCOMAR","NTD_CFORO","NTD_CVARA" } )
oModel:GetModel("NTDDETAIL"):SetDelAllLine( .T. ) 

oModel:SetOptional( "NTDDETAIL" , .T. )

JurSetRules( oModel, "NTDDETAIL",, "NTD" )

Return oModel
               
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA012TOK
Valida informações ao salvar.
Uso no cadastro de Juiz.

@param 	oFormField  	FormField a ser verificado	
@Return lRet	 	   .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 18/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA012TOK(oModel)
Local lRet       := .T.
Local lRetL2N    := .T.
Local lRetL3N    := .T.
Local oModelGrid := oModel:GetModel("NTDDETAIL")
Local nCt

For nCt := 1 To oModelGrid:GetQtdLine()
	
	oModelGrid:GoLine( nCt )
	
	If !oModelGrid:IsDeleted()    
		If !Empty(oModelGrid:GetValue('NTD_CCOMAR')) .And. (Empty(oModelGrid:GetValue('NTD_CFORO')) .Or. Empty(oModelGrid:GetValue('NTD_CVARA')))
			JurMsgErro(STR0011+RetTitle('NTD_CCOMAR')+", "+RetTitle('NTD_CFORO')+", "+RetTitle('NTD_CVARA'))
			lRet := .F.
			Exit
		ElseIf !Empty(oModelGrid:GetValue('NTD_CFORO'))
			lRetL2N:= JURA12L2OK()
			If !lRetL2N
				Exit
			EndIf
		ElseIf !Empty(oModelGrid:GetValue('NTD_CVARA'))
			lRetL3N:= JURA12L3OK()
			If !lRetL3N
				Exit
			EndIf
		EndIf			
	EndIf
	
Next

If lRet
	If (!lRetL2N).Or.(!lRetL3N)
		lRet:=.F.
	Else
		lRet:=.T.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA12L2OK
Valida se o campo de Localização de 2. Nivel está vinculado ao de
Comarca e se o digitado é da instância conforme o tipo de juiz
Localização de 2. nivel de 1. instância = Juiz de 1.instancia
Localização de 2. nivel de 2. instância = Desembargador
Localização de 2. nivel de Trib. Superior = Ministro
Uso no cadastro de Juiz.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Clóvis Eduardo Teixeira
@since 28/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA12L2OK()
Local lRet        	:= .F.
Local aArea       	:= GetArea()
Local aAreaNQC    := NQC->( GetArea() )
Local oModel      := FWModelActive()     
Local oModelGrid  := oModel:GetModel("NTDDETAIL")
Local cComarca   	:= oModelGrid:GetValue("NTD_CCOMAR")
Local cLoc2N    	  := oModelGrid:GetValue("NTD_CFORO")

NQC->( dbSetOrder( 3 ) )

	If NQC->( dbSeek( xFilial( 'NQC' ) + cLoc2N ) )
		
		While !NQC->( EOF() ) .AND. xFilial( 'NQC' ) + cLoc2N == NQC->NQC_FILIAL + NQC->NQC_COD
			If cComarca == NQC->NQC_CCOMAR
		    lRet := .T.
			Endif
			NQC->( dbSkip() )
		End
		
		If !lRet
			JurMsgErro(STR0010+RetTitle('NTD_CFORO'))
			lRet := .F.
		EndIf
	Else
		If !lRet
			JurMsgErro(STR0010+RetTitle('NTD_CFORO'))
			lRet := .F.
		EndIf
	Endif

RestArea( aAreaNQC )
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA12L3OK
Valida se o campo de Localização de 3. Nivel está vinculado ao de
Localização de 2. Nivel
Uso no cadastro de Juiz.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Clóvis Eduardo Teixeira
@since 28/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA12L3OK()
Local lRet       	:= .F.
Local aArea      	:= GetArea()
Local aAreaNQE   	:= NQE->( GetArea() )
Local oModel     	:= FWModelActive() 
Local oModelGrid  := oModel:GetModel("NTDDETAIL")
Local cLoc2N       := oModelGrid:GetValue("NTD_CFORO")
Local cLoc3N       := oModelGrid:GetValue("NTD_CVARA")

NQE->( dbSetOrder( 1 ) )

	IF NQE->( dbSeek( xFilial( 'NQE' ) + cLoc3N ) )			
	
		While !NQE->( EOF() ) .AND. xFilial( 'NQE' ) + cLoc3N == NQE->NQE_FILIAL + NQE->NQE_COD
			If cLoc2N == NQE->NQE_CLOC2N
		lRet := .T.
			Endif
			NQE->( dbSkip() )
		End
		
		If !lRet
			JurMsgErro(STR0010+RetTitle('NTD_CVARA'))
			lRet := .F.
		EndIf
	Else
		If !lRet
			JurMsgErro(STR0010+RetTitle('NTD_CVARA'))
			lRet := .F.
		EndIf
	EndIf
	
RestArea( aAreaNQE )
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA12NQC
Filtra consulta padrão de localização de 2. nível pelo tipo de juiz
conforme a instancia do processo e comarca
Localização de 2. nivel de 1. instância = Juiz de 1.instancia
Localização de 2. nivel de 2. instância = Desembargador
Localização de 2. nivel de Trib. Superior = Ministro
Uso no cadastro de Juiz.

@Return cRet Filtro da consulta
@sample

@author Clóvis Eduardo Teixeira
@since 16/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA12NQC()
Local cRet := "@#@#"
	cRet := "@#NQC->NQC_CCOMAR == '"+FwFldGet('NTD_CCOMAR')+"'@#"
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA12NQE
Filtra consulta padrão de localização de 3. nível pelo campo de
localização de 2. nível
Uso no cadastro de Juiz.

@Return cRet Filtro da consulta
@sample

@author Clóvis Eduardo Teixeira
@since 16/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA12NQE()
Local cRet := "@#@#"
	cRet := "@#NQE->NQE_CLOC2N == '"+FwFldGet('NTD_CFORO')+"'@#"
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA012Commit
Commit de dados de Juiz

@author Jorge Luis Branco Martins Junior
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA012Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQHMASTER","NQH_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQH',cCod)
	EndIf

Return lRet