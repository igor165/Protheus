#INCLUDE "AGRA700.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

/** -------------------------------------------------------------------------------------
{Protheus.doc}
Pesagem Avulsa

@param: 	Nil
@author: 	Aécio Ferreira Gomes
@since: 	29/04/2013
@Uso: 		UBA
------------------------------------------------------------------------------------- **/
Function AGRA700()
	Local cPerg         := "AGRA70001"
	Local bKeyF12 		:= { || aPerBal := AGRX003E( .T., cPerg ) }
	Local oBrowse 		:= Nil
		
	Private aPesagem1 	:= {}
	Private aPesagem2 	:= {}
	Private aPerBal	  	:= AGRX003E( .F., cPerg)
	
	// Seta acao para tecla F12
	SetKey( VK_F12, bKeyF12   ) // F12

	// Instancia o Browser
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "DX9" )
	oBrowse:SetDescription( STR0001 )  //"Pesagem Avulsa"
	oBrowse:DisableDetails()

	// Adiciona Legendas no Browser
	oBrowse:AddLegend( " DX9_STATUS == '1'"	, "GREEN"	, Alltrim(AGRTxtBox('1','DX9_STATUS') )	)
	oBrowse:AddLegend( " DX9_STATUS == '2'"	, "YELLOW"	, Alltrim(AGRTxtBox('2','DX9_STATUS') )	)
	oBrowse:AddLegend( " DX9_STATUS == '3'"	, "RED"		, Alltrim(AGRTxtBox('3','DX9_STATUS') )	)

	// Ativa o Browser
	oBrowse:Activate()

	// Retira acao da teclha de atalho f12
	SetKey( VK_F12 , Nil )

Return()


/** -------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 29/04/2013
@Uso: AGRA700
------------------------------------------------------------------------------------- **/
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0003, 'VIEWDEF.AGRA700', 0, 2, 0, NIL } ) //'Visualizar'
	aAdd( aRotina, { STR0004, 'VIEWDEF.AGRA700', 0, 3, 0, NIL } ) //'Incluir'
	aAdd( aRotina, { STR0005, 'VIEWDEF.AGRA700', 0, 4, 0, NIL } ) //'Alterar'
	aAdd( aRotina, { STR0006, 'VIEWDEF.AGRA700', 0, 5, 0, NIL } ) //'Excluir'
	aAdd( aRotina, { STR0007, 'VIEWDEF.AGRA700', 0, 8, 0, NIL } ) //'Imprimir'
	aAdd( aRotina, { STR0008, 'VIEWDEF.AGRA700', 0, 9, 0, NIL } ) //'Copiar'

Return( aRotina )

/** -------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de dados para a rotina

@author: 	Aécio Ferreira Gomes
@since: 	29/04/2013
@Uso: 		AGRA700
------------------------------------------------------------------------------------- **/
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruDX9 		:= FwFormStruct( 1, "DX9" )
	Local bKey_ALT_P 	:= { || Pesagem() }

	// Instacia o modelo de dados
	oModel:= MpFormModel():New( "AGRA700",/*bPre*/, /*bPro*/, { |oModel| GrvModelo(oModel) } )
	
	// Adiciona a estrutura dos campos da field no modelo de dados
	oModel:AddFields( "MDFIELDDX9", , oStruDX9 )
	oModel:SetDescription( STR0002 ) //"Modelo de Dados da Pesagem Avulsa"
	oModel:GetModel( "MDFIELDDX9" ):SetDescription( STR0001 )  //"Pesagem Avulsa"

	// Seta chave primaria
	oModel:SetPrimaryKey({"DX9_FILIAL", "DX9_CODIGO"})

Return( oModel  )

/** -------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: 	Nil
@author: 	Aécio Ferreira Gomes
@since: 	29/04/2013
@Uso: 		AGRA700
------------------------------------------------------------------------------------- **/
Static Function ViewDef()

	Local oView	:= Nil
	Local oModel	:= FwLoadModel( "AGRA700" )
	Local oStruDX9	:= FwFormStruct( 2, "DX9" )

	// Remove campos da estrutura
	oStruDX9:RemoveField( "DX9_STATUS" )

	// Instancia a View
	oView := FwFormView():New()
	oView:SetModel( oModel )

	// Adiciona a estrutura ao modelo
	oView:AddField( "VIEW_DX9", oStruDX9, "MDFIELDDX9" )

	// Cria Box
	oView:CreateHorizontalBox( "TOTAL", 100 )

	// Seta o Owner da View
	oView:SetOwnerView( "VIEW_DX9", "TOTAL" )

	// Adiciona os botoes na tela
	oView:AddUserButton( "Pesagem" , 'CLIPS', {|x| Pesagem( x ) } )

Return(oView)

/** -------------------------------------------------------------------------------------
{Protheus.doc} GrvModelo
Gravação do modelo de dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 29/04/2013
@Uso: AGRA700
------------------------------------------------------------------------------------- **/
Static Function GrvModelo(oModel)
	Local lRet 			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlDX9		:= oModel:GetModel( "MDFIELDDX9" )
	
	//Para operacao exclusao nao entra
	If nOperation <> MODEL_OPERATION_DELETE

		If Empty( oMdlDX9:GetValue("DX9_PESO1") ) .And. Empty( oMdlDX9:GetValue("DX9_PESO2") ) 
			oMdlDX9:SetValue("DX9_STATUS", "1")		// Pendente
		ElseIf Empty( oMdlDX9:GetValue("DX9_PESO1") ) .Or. Empty( oMdlDX9:GetValue("DX9_PESO2") ) 
			oMdlDX9:SetValue("DX9_STATUS", "2") 	// Em Andamento
		Else
			oMdlDX9:SetValue("DX9_STATUS", "3")  	// Finalizada
		EndIf
		
	ENDIF 
	
	lRet := oModel:VldData() 
	
	If  lRet
		lRet := FwFormCommit( oModel )
	endIf
	
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} Pesagem
Rotina de pesagem (integracao com a balança)

@param: 	oView - Modelo de visualização da rotina
@return:	.T. ou .F.
@author: 	Aécio Ferreira Gomes
@since: 	24/03/2013
@Uso: 		AGRA700
------------------------------------------------------------------------------------- **/
Static Function Pesagem( oView )
	Local oModel	:= FWModelActive()
	Local oMdlDX9	:= oModel:GetModel( "MDFIELDDX9" )
	Local oDlg 		:= Nil
	Local oCombo	:= Nil
	Local cCombo	:= ""
	
	Local lPeso1  	:= FwFldGet( "DX9_PESO1" ) == 0
	Local lPeso2  	:= FwFldGet( "DX9_PESO2" ) == 0
	Local lPeso3  	:= FwFldGet( "DX9_PESO1" ) > 0 .And. FwFldGet( "DX9_PESO2" ) > 0
	Local lRetRom	:= .T.

	Local nItem		:= 1
	Local nPeso		:= 0

	Default oView 	:= FwViewActive()
	
	//*Verifica se já existe romaneio
	lRetRom := A700TICKET(FwFldGet("DX9_CODIGO"))
	
	//If INCLUI .Or. ALTERA .And. !aPerBal[ 4 ]
	If (INCLUI .Or. ALTERA) .AND. !aPerBal[4] .AND. lRetRom = .F.
		If lPeso3 //Ja possui as duas pesagens
			oDlg 	:= TDialog():New(0,0,24,300,'',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
			oCombo 	:= TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0009, STR0010}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , 'cCombo' ) //"Primeira Pesagem"###"Segunda Pesagem" //"Primeira Pesagem"###"Segunda Pesagem"
			oTButt 	:= TButton():New( 001, 104, STR0011, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma" //"Confirma"
			oDlg:Activate( , , , .t., { | | .T. }, , { || } )
 		
			If nItem = 1
				lPeso1 := .T.
				lPeso2 := .F.
			ElseIf nItem = 2
				lPeso1 := .F.
				lPeso2 := .T.
			EndIf
		EndIf

		If lPeso1 //Primeira Pesagem
			// Apresenta tela de pesagem
			AGRX003A( @nPeso, , aPerBal )
			
			If !Empty(nPeso)
				oMdlDX9:SetValue( "DX9_DATPS1", dDataBase )
				oMdlDX9:SetValue( "DX9_HORPS1", Substr( Time(), 1, 5 ) )
				oMdlDX9:SetValue( "DX9_PESO1" , nPeso )
				
				Aadd( aPesagem1, { dDataBase, Substr( Time(), 1, 5 ), nPeso } )
			EndIf
			
		ElseIf lPeso2 //Segunda Pesagem
			// Apresenta tela de pesagem
			AGRX003A( @nPeso, , aPerBal )
			
			If !Empty(nPeso)
				oMdlDX9:SetValue( "DX9_DATPS2", dDataBase )
				oMdlDX9:SetValue( "DX9_HORPS2", Substr( Time(), 1, 5 ) )
				oMdlDX9:SetValue( "DX9_PESO2" , nPeso )
				
				Aadd( aPesagem2,{ dDataBase, Substr( Time(), 1, 5 ), nPeso })
			EndIf
		EndIf
	Else
		lRetRom := .T. 
		Help( , , STR0012, , STR0014, 1, 0 ) 
		Return(.F.)     
	EndIf

	oView:SetModified()
	oView:Refresh()
Return(.T.)

/**-------------------------------------------------------------------------------------
{Protheus.doc} A700TICKET()
Indica se o ticket de pesagem está vinculado a algum romaneio 

@param: cTicket	- Código identificador da pesagem avulsa
@author: Ana Laura Olegini
@since: 01/06/2015
@Uso: AGRA700
-------------------------------------------------------------------------------------**/
Static Function A700TICKET(cTicket)
	Local aArea	:= GetArea()
	Local lRet	:= .F.

	Private cQryPes := GetNextAlias()	

	cQuery := " SELECT * "
	cQuery +=   " FROM "+ RetSqlName("DXS") + " DXS "
	cQuery +=  " WHERE DXS.DXS_FILIAL   = '" + xFilial( 'DXS' ) + "'" 
	cQuery +=    " AND DXS.DXS_TICKET   = '" + cTicket + "'"
	cQuery +=    " AND DXS.DXS_STATUS   = '1' "
	cQuery +=  " ORDER BY DXS.DXS_CODIGO "
	cQuery := ChangeQuery(cQuery)
	If Select(cQryPes) <> 0
		(cQryPes)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQryPes,.T.,.T.)

	(cQryPes)->(dbGotop())	
		lRet := (cQryPes)->(!Eof())	
	(cQryPes)->(dbCloseArea())
	
	RestArea(aArea)
Return(lRet)