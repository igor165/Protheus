#INCLUDE "JURA258.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA258
Redutores

@author leandro.silva
@since 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA258()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )      //Redutores
	oBrowse:SetAlias( "O0Q" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0Q" )
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

@author leandro.silva
@since 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA258", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA258", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA258", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA258", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA258", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Redutores

@author leandro.silva
@since 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  	 := FWLoadModel( "JURA258" )
	Local oStructO0Q := FWFormStruct( 2, "O0Q" )
			
	JurSetAgrp( 'O0Q',, oStructO0Q )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 )		//"Redutores" 
	
	//Adiciona quebra de linha para melhor posicionamento dos campos 
	If oStructO0Q:HasField("O0Q_COD")
		oStructO0Q:SetProperty('O0Q_COD',MVC_VIEW_INSERTLINE,.T.)
	Endif

	If oStructO0Q:HasField("O0Q_DTIPAS")
		oStructO0Q:SetProperty('O0Q_DTIPAS',MVC_VIEW_INSERTLINE,.T.)
	Endif

	If oStructO0Q:HasField("O0Q_DAREAJ")
		oStructO0Q:SetProperty('O0Q_DAREAJ',MVC_VIEW_INSERTLINE,.T.)
	Endif

	If oStructO0Q:HasField("O0Q_DOBJET")
		oStructO0Q:SetProperty('O0Q_DOBJET',MVC_VIEW_INSERTLINE,.T.)
	Endif
	
	oView:AddField( "JURA258_FIELD", oStructO0Q, "O0QMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100)
	oView:SetOwnerView( "JURA258_FIELD", "FORMFIELD" )
	oView:EnableTitleView( "JURA258_FIELD"  )
	
	oView:EnableControlBar( .T. )
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Redutores 

@author leandro.silva
@since 12/04/2018
@version 1.0

@obs O0QMASTER - Dados dos Redutores
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO0Q := FWFormStruct( 1, "O0Q" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA258", /*Pre-Validacao*/, {|oX| JA258OK(oX)}, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0007 )		//"Modelo de Dados"                 			
	
	oModel:AddFields( "O0QMASTER", NIL, oStructO0Q, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "O0QMASTER" ):SetDescription( STR0008 ) 	     //"Dados dos Redutores" 		
	JurSetRules( oModel, 'O0QMASTER',, 'O0Q' ) 						
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA258TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author leandro.silva
@since 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA258OK(oModel)

	Local lRet      := .T.
	Local aArea     := GetArea()
	Local aAreaO0Q  := O0Q->( GetArea() )
	Local cDtVigDe  := DtoS(oModel:GetValue("O0QMASTER","O0Q_DTVIGD"))
	Local cDtVigAte := DtoS(oModel:GetValue("O0QMASTER","O0Q_DTVIGA"))
	Local cPerCre   := oModel:GetValue("O0QMASTER","O0Q_PERCRE")
	
	If oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4
		
		If JA258VldRed(oModel) 
			lRet := .F.
			JurMsgErro(STR0009,,STR0010) //"Já existem registros com as informações utilizadas"   //"Verifique os seguintes campos: ..."
		EndIf
		
		If lRet
			If cDtVigAte < cDtVigDe
				lRet := .F.
				JurMsgErro(STR0011,,STR0012) //"Já existem registros com as informações utilizadas"   //"Verifique os seguintes campos: ..."
			EndIf
		EndIf
		If lRet 
			If cPerCre <= 0 
				lRet := .F.
				JurMsgErro(STR0013,,STR0014) //"Já existem registros com as informações utilizadas"   //"Verifique os seguintes campos: ..."
			EndIf
		EndIf

	EndIf

	RestArea(aAreaO0Q)	
	RestArea(aArea)
		
Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA258VldRed
Valida Já existem registros com as informações utilizadas

@param  oModel   Model a ser verificado
@Return lRet    .T./.F. Existe regitro ou nao
@author Brenno Gomes 
@since 17/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA258VldRed(oModel)
	Local lRet      := .F.
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()
	Local cCod      := oModel:GetValue("O0QMASTER","O0Q_COD")
	Local cAssunto  := oModel:GetValue("O0QMASTER","O0Q_TIPOAS")
	Local cArea     := oModel:GetValue("O0QMASTER","O0Q_CAREAJ")
	Local cObj      := oModel:GetValue("O0QMASTER","O0Q_COBJET")
	Local cDtVigDe  := DtoS(oModel:GetValue("O0QMASTER","O0Q_DTVIGD"))
	Local cDtVigAte := DtoS(oModel:GetValue("O0QMASTER","O0Q_DTVIGA"))
	
	
		cQuery := "SELECT *"
		cQuery += "FROM " + RetSqlName("O0Q")
		cQuery += "WHERE  O0Q_TIPOAS = '" +cAssunto +"'"
		cQuery +=        " AND O0Q_CAREAJ = '" + cArea +"'"
		cQuery +=        " AND O0Q_COBJET = '" + cObj +"'"
		cQuery +=        " AND ( ('"+ cDtVigDe +"' >= O0Q_DTVIGD " 
		cQuery +=                " AND '"+ cDtVigDe +"' <= O0Q_DTVIGA ) "
		cQuery +=               " OR ( '"+ cDtVigAte +"' >= O0Q_DTVIGD " 
		cQuery +=                    " AND '"+ cDtVigAte +"' <= O0Q_DTVIGA ) "
		cQuery +=               " OR ('"+cDtVigDe +"' < O0Q_DTVIGD "
		cQuery +=                    " AND O0Q_DTVIGA < '"+cDtVigAte +"' ) )"
		cQuery +=        " AND O0Q_COD <> '" + cCod + "'"
		cQuery +=        " AND D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)
		
		If !(cAlias)->(EOF())
			lRet := .T.
		EndIf
		
		(cAlias)->( dbcloseArea() )
	
Return lRet



