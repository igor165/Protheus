#INCLUDE "UBAA100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} UBAA100
//Cadastro de alerta de emblocamento físico
@author bruna.rocio
@since 19/07/2017
@version undefined
@type function
/*/
Function UBAA100()
	Local aArea 	:= GetArea()
	Local oBrowse
	
	Private _cRet

	If .Not. TableInDic('N7P')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif	
	
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('N7P')
	oBrowse:SetMenuDef('UBAA100')
	oBrowse:SetDescription(STR0001) //#Alerta de Emblocamento Físico
	oBrowse:Activate()

	RestArea(aArea)
Return Nil


/*/{Protheus.doc} MenuDef
//Menu da rotina
@author bruna.rocio
@since 19/07/2017
@version undefined
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.UBAA100' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.UBAA100' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.UBAA100' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.UBAA100' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.UBAA100' OPERATION 8 ACCESS 0    // 'Imprimir'

Return aRotina


/*/{Protheus.doc} ModelDef
//Definição do model da rotina
@author bruna.rocio
@since 19/07/2017
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruN7P 		:= FwFormStruct( 1, "N7P" )
	Local oStruN7T 		:= FwFormStruct( 1, "N7T" )

	oModel := MPFormModel():New('UBAA100',/*bPre*/ , /*bPos*/, {|oModel| GrvModelo(oModel)} )

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN7P', /*cOwner*/, oStruN7P )

	oModel:SetPrimaryKey( { "N7P_FILIAL", "N7P_SAFRA"} )
	oModel:GetModel( 'MdFieldN7P' ):SetDescription(STR0001) //Alerta de Emblocamento Físico

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGrdN7T', 'MdFieldN7P', oStruN7T)

	oStruN7T:SetProperty('N7T_FRDINI' , MODEL_FIELD_TAMANHO , TamSX3('N7T_FRDINI')[1])
	oStruN7T:SetProperty('N7T_FRDFIM' , MODEL_FIELD_TAMANHO , TamSX3('N7T_FRDFIM')[1])
    
	oModel:GetModel( 'MdGrdN7T'):SetDescription(STR0001)

	//-------------------------------------
	// Seta preenchimento opcional da Grid
	//-------------------------------------
	oModel:GetModel( "MdGrdN7T"):SetOptional( .T. )

	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGrdN7T', {{ 'N7T_FILIAL', 'xFilial( "N7T" )' }, { 'N7T_SAFRA', 'N7P_SAFRA' }})

	//-------------------------------------
	// Altera descricao no modelo
	//-------------------------------------
	oModel:SetDescription(STR0001) //Alerta de Emblocamento Físico

	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate() // Inicializa os campos conforme o pergunte

Return oModel


/*/{Protheus.doc} ViewDef
//Definição da view da rotina
@author bruna.rocio
@since 19/07/2017
@version undefined
@type function
/*/
Static Function ViewDef()
	Local oStruN7P		:= FWFormStruct(2,"N7P")
	Local oStruN7T 		:= FWFormStruct(2,'N7T')
	Local oModel   		:= FWLoadModel( "UBAA100" )
	Local oView    		:= FWFormView():New()

	oView:SetModel( oModel )

	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( "VwFieldN7P", oStruN7P, "MdFieldN7P" )

	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N7T', oStruN7T, 'MdGrdN7T' )

	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------
	oStruN7P:RemoveField('N7P_ID')

	oStruN7T:RemoveField('N7T_DTINCL')
	oStruN7T:RemoveField('N7T_HRINCL')

	//----------------------
	//Cria o Box Horizontal
	//----------------------
	oView:CreateHorizontalBox( 'CABEC', 20 )
	oView:CreateHorizontalBox( 'GRID', 80 )

	//----------------------
	//Seta owner da view
	//----------------------
	oView:SetOwnerView( "VwFieldN7P", "CABEC" )
	oView:SetOwnerView( 'VIEW_N7T', 'GRID' )

	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_N7T', 'N7T_IDRANG' )

	oView:EnableTitleView( "VwFieldN7P" )

	oView:SetCloseOnOk( {||.t.} )
Return oView


/*{Protheus.doc} UBAA100VLD
Valida os campos. SX3.

@author 	silvana.torres
@since 		31/07/2017
@version 	1.0
*/
Function UBAA100VLD()
	Local oModel   	:= FWModelActive()
	Local oModelN7P := oModel:GetModel('MdFieldN7P')
	Local oStruN7T 	:= oModel:GetModel('MdGrdN7T')
	Local lRet      := .T.
	
	Local oGridVT   
	Local cFil
	Local cSaf

	If oStruN7T:GetValue("N7T_STATUS") == "2"
	   Help("",1,,,STR0009 /*"Não pode ser alterado fardo inicial e final para registros com status de e-mail enviado."*/,1)
	   lRet := .F.
	EndIf

	dbSelectArea('DXI')
	dbSetOrder(1)
		
	if !IsInCallStack("U070GrvGrd")
		if IsInCallStack("UBAA070") 
			oGridVT   := oModel:GetModel('UBAA070_VT') 
			
			cFil   := oGridVT:GetValue('VT_FILIAL')
			cSaf   := oGridVT:GetValue('VT_CODSAF')
		else
			cFil   := cFilAnt
			cSaf   := oModelN7P:GetValue('N7P_SAFRA')			
		endIf
		
		If ("N7T_FRDINI" $ ReadVar() ) 
			DXI->(DbSeek(cFil+cSaf+oStruN7T:GetValue("N7T_FRDINI")))
		elseIf ("N7T_FRDFIM" $ ReadVar() ) 
			DXI->(DbSeek(cFil+cSaf+oStruN7T:GetValue("N7T_FRDFIM")))
		endIf
		
		If ("N7T_FRDINI" $ ReadVar()  .or. "N7T_FRDFIM" $ ReadVar())  
			if DXI->(Eof())
				lRet := .F.
			endIf
		endIf
	endIF

	If !Empty(oStruN7T:GetValue("N7T_FRDFIM")) .And. lRet .And. !IsInCallStack("U070GrvGrd") 
		If val(substr(oStruN7T:GetValue('N7T_FRDINI'),14,6)) > val(substr(oStruN7T:GetValue('N7T_FRDFIM'),14,6))
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0007, STR0008, "", "") /*Faixa inválida*/ /*Informe um fardo inicial menor que o valor final"*/
			lRet := .F.
		ElseIf val(substr(oStruN7T:GetValue('N7T_FRDINI'),14,6)) = val(substr(oStruN7T:GetValue('N7T_FRDFIM'),14,6))
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0007, STR0008, "", "") /*Faixa inválida*/ /*Informe um fardo inicial menor que o valor final"*/
			lRet := .F.
		Endif
	EndIf

	//Preenche a data e hr de atualização
	If lRet
		oStruN7T:SetValue("N7T_DATATU", DDATABASE)
		oStruN7T:SetValue("N7T_HORATU", TIME() )
	EndIf
	
Return lRet


/*{Protheus.doc} UBAA100EMA
Valida o email.

@author 	carlos.augusto
@since 		06/09/2017
@version 	1.0
*/
Function UBAA100EMA()
	Local oModel   	:= FWModelActive()
	Local oStruN7P 	:= oModel:GetModel('MdFieldN7P')
	Local lRet      := .T.
	Local lMailOk   := .T.
	Local aEmails
	Local nX
	Local cMensagem := ""
	Local cFil
	Local cSaf

	aEmails := StrTokArr(AllTrim(oStruN7P:GetValue("N7P_EMAIL")), ';')

	If Len(aEmails) > 0
		For nX := 1 to Len(aEmails)	
			lRet := IsEmail (aEmails[nX])
			If !lRet
				lMailOk	:= .F.
				cMensagem := cMensagem + aEmails[nX] + "<br>"
			EndIf
		Next nX

		If !lMailOk
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0010, STR0011 + cMensagem, "", "") /*Campo de e-mail inserido incorretamente.*/ /*Favor corrigir o(s) e-mail(s): */
		EndIf
	Else
		If IsInCallStack("UBAA070") 
			cFil   := oModel:GetValue('MdFieldN7P','N7P_FILIAL' )
			cSaf   := oModel:GetValue('MdFieldN7P','N7P_SAFRA' )

			dbSelectArea('N7T')
			dbSetOrder(1)
			If !Empty(MsSeek(cFil+cSaf))
			   oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0012, STR0013 + cMensagem, "", "") 
			   lRet	:= .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GrvModelo
//GrvModelo
@author francisco.nunes
@since 11/01/2019
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)

	Local lRet    	 := .T.
	Local nX      	 := 0
	Local oMldN7P	 := oModel:GetModel('MdFieldN7P')
	Local oMldN7T 	 := oModel:GetModel('MdGrdN7T')
	Local nOperation := oModel:GetOperation() 

	If nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE
		
		For nX := 1 to oMldN7T:Length()
			oMldN7T:GoLine(nX)
			
			If ((oMldN7T:IsDeleted() .AND. nOperation == MODEL_OPERATION_UPDATE) .OR. (nOperation == MODEL_OPERATION_DELETE)) .AND.;
			   .Not. Empty(oMldN7T:GetValue("N7T_DTENV"))
				
				DbSelectArea("N7T")
				N7T->(DbSetOrder(1)) //N7T_FILIAL+N7T_SAFRA+N7T_IDRANG
				If N7T->(DbSeek(oMldN7P:GetValue("N7P_FILIAL")+oMldN7P:GetValue("N7P_SAFRA")+oMldN7T:GetValue("N7T_IDRANG")))
					If RecLock("N7T", .F.)
						N7T->N7T_DATATU := dDatabase
						N7T->N7T_HORATU := Time()
						N7T->(MsUnlock())
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	If lRet
		lRet := FWFormCommit(oModel)
	EndIF
	
Return lRet
