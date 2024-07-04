#INCLUDE "AGRA640.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cRet :='' 
Static __cCampDX7 := "DX7_MIC,DX7_ETIQ,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_CG,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI,DX7_DATREC,DX7_HORREC,DX7_DATENV,DX7_HORENV,DX7_MATU" 
Static __nTamData := 0
Static __lTemCont := .F.

//-----------------------------------------------------------------------------------------------------------
// Cadastro de LAYOUT
//-----------------------------------------------------------------------------------------------------------
Function AGRA640()
	Local oBrowse
	Local aArea := GetArea()
	
	If DX1->(ColumnPos('DX1_CONTAM')) > 0
		__lTemCont := .T.
	endIf
	
	//Ajuste de base campo tipo de layout HVI/ Contaminante
	If DX2->(ColumnPos('DX2.DX2_TIPO')) > 0
		AjusTipHVI()
	endIf
	
	//Instancia o objeto Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DX1')
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Layout de importação de arquivos"
	//Ativa o Browse
	oBrowse:Activate()

	RestArea(aArea)
Return NIL

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.AGRA640' 	OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.AGRA640' 	OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.AGRA640'	OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.AGRA640'	OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//============================================================
// Retorna o modelo de Dados da rotina de Cadastro de Layout
//============================================================
Static Function ModelDef()

	Local oModel   	:= Nil
	Local oStruDX1 	:= FwFormStruct( 1, "DX1" )//Layout
	Local oStruDX2H	:= FwFormStruct( 1, "DX2" )//Estrutura do Layout de importação
	Local oStruDX2C	:= FwFormStruct( 1, "DX2" )//Estrutura do Layout de importação
	Local bGrdVld   := {|oItemCont, nLine, cAction, cField, xValueNew, xValueOld | A640NODEL(oItemCont, nLine, cAction, cField, xValueNew, xValueOld)}

	If IsBlind() 
		__lTemCont := .T.
	Endif

	oModel := MpFormModel():New( 'AGRA640',/*bPre*/,,{|oModel| AGRA640GRV(oModel)}, /*bCancel*/ )

	oModel:SetDescription( STR0006 ) //'Modelo de dados do Layout do arquivo de importação'

	oModel:AddFields( 'CABEC', /*cOwner*/, oStruDX1 )
	oModel:GetModel( "CABEC" ):SetDescription( STR0007 ) //'Dados do Layout'

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'ITEM_HVI', 'CABEC', oStruDX2H)
	oModel:GetModel( "ITEM_HVI" ):SetDescription( STR0008 ) //'Dados dos Itens do Layout'	
	
	//Controle de campo duplicado
	oModel:GetModel( 'ITEM_HVI' ):SetUniqueLine( { 'DX2_CAMPO' } )
	
	if __lTemCont
		// Adição dos botões de Baixo e Cima para ordenação
		oStruDX2C:AddField('BTN BAIXO', "UP3",  'DX2_MOVUP', 'BT' , 1 , 0, {|| AGRA640MOV(1)} , NIL , NIL, NIL, {||"UP3"}  , NIL, .F., .T.)
		oStruDX2C:AddField('BTN CIMA' , "DOWN3",'DX2_MOVDW', 'BT' , 1 , 0, {|| AGRA640MOV(2)} , NIL , NIL, NIL, {||"DOWN3"}, NIL, .F., .T.)
		
		oModel:AddGrid( 'ITEM_CONT', 'CABEC', oStruDX2C,/*bLinePre*/, /*bLinePost*/, bGrdVld, bGrdVld)
		
		oModel:SetRelation( 'ITEM_HVI', { { 'DX2_FILIAL', 'xFilial( "DX2" )' }, { 'DX2_LAYOUT', 'DX1_CODIGO' }, {'DX2_TIPO','"1"'} }, DX2->( IndexKey( 2 ) ) )
		oModel:SetRelation( 'ITEM_CONT',{ { 'DX2_FILIAL', 'xFilial( "DX2" )' }, { 'DX2_LAYOUT', 'DX1_CODIGO' }, {'DX2_TIPO','"2"'} }, DX2->( IndexKey( 3 ) ) )
		
		oModel:GetModel( 'ITEM_CONT'):SetUniqueLine( { 'DX2_NOME' } )
		oModel:GetModel( "ITEM_CONT" ):SetOptional( .T. )
		
		//-------------------------------------
		// Valid para DX2_CAMPO
		//-------------------------------------
		oStruDX2C:SetProperty( 'DX2_CAMPO' , MODEL_FIELD_VALID ,  {|| .T.})
		
		//-------------------------------------
		// Obrigatoriedades
		//-------------------------------------
		oStruDX2C:SetProperty('DX2_CAMPO',  MODEL_FIELD_OBRIGAT, .F. )
		oStruDX2C:SetProperty('DX2_TIPRES', MODEL_FIELD_OBRIGAT, .T. )
		oStruDX2C:SetProperty('DX2_NOME',   MODEL_FIELD_OBRIGAT, .T. )
		
		//-------------------------------------
		// Trigger para DX1_CONTAM
		//-------------------------------------
		oStruDX1:SetProperty( 'DX1_CONTAM' , MODEL_FIELD_WHEN ,  {|| AGRA640CON() })
		
		// valida tipo campo dependendo (des)habilita o campo decimal/ tamanho
		oStruDX2C:SetProperty( 'DX2_TIPRES', MODEL_FIELD_VALID , {|| AGRA640VlT() })
		oStruDX2C:SetProperty( 'DX2_INICIO', MODEL_FIELD_INIT,   {|| AGRA640PAD() })
	else
		oModel:SetRelation( 'ITEM_HVI', { { 'DX2_FILIAL', 'xFilial( "DX2" )' }, { 'DX2_LAYOUT', 'DX1_CODIGO' } }, DX2->( IndexKey( 1 ) ) )
	endIf

	//-------------------------------------
	// Seta preenchimento opcional da Grid
	//-------------------------------------
	oModel:GetModel( "ITEM_HVI"):SetOptional( .T. )
	
	oStruDX2H:SetProperty( 'DX2_NOME', MODEL_FIELD_VALID , {|| AGRA640NM() .And. AGRA640DAT()  })
    
	oStruDX2H:SetProperty( 'DX2_TAM'   , MODEL_FIELD_WHEN  , {|| AGRA640TMH() })

	oModel:SetPrimaryKey( {"DX1_FILIAL","DX1_CODIGO"} )

	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate({|oModel|AGRA640ACT(oModel)})

Return oModel

//=======================================================
// Retorna a View (tela) da rotina de Cadastro de Layout
//=======================================================
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA640" )
	Local oStruDX1 	:= FwFormStruct( 2, "DX1" ) // Layout
	Local oStruDX2H
	Local oStruDX2C := FwFormStruct( 2, "DX2" ) // Estrutura do Layout
	
	If __lTemCont
		oStruDX2H := FwFormStruct( 2, "DX2", {|cCampo|!AllTrim(cCampo)$"DX2_CAMPO"} )
	Else
		oStruDX2H := FwFormStruct( 2, "DX2")
	EndIf
	
	oView := FwFormView():New()

	oView:SetModel( oModel )

	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_DX1', oStruDX1, 'CABEC' )

	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_DX2_H' , oStruDX2H, 'ITEM_HVI')

	if __lTemCont
		oView:AddGrid( 'VIEW_DX2_C' , oStruDX2C, 'ITEM_CONT')
		
		oView:CreateHorizontalBox( 'SUPERIOR', 40 )
		oView:CreateHorizontalBox( 'INFERIOR', 60 )
	else
		oView:CreateHorizontalBox( 'SUPERIOR', 25 )
		oView:CreateHorizontalBox( 'INFERIOR', 75 )
	endIf

	// ------------
	// Cria Folder
	// ------------
	oView:CreateFolder( 'GRADES', 'INFERIOR')
	oView:AddSheet( 'GRADES', 'PASTA01', STR0012) /* HVI */

	// ----------
	// Cria Box
	// ----------
	oView:CreateHorizontalBox( 'PASTA_HVI', 100, , , 'GRADES', 'PASTA01' )

	oView:SetOwnerView( 'VIEW_DX1',   'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DX2_H', 'PASTA_HVI' )
	
	if __lTemCont
		// Adiciona na View os botões de Baixo e Cima para reordenação
		oStruDX2C:AddField("DX2_MOVUP", '01', "- ", "UP3",   {} , 'BT','@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
		oStruDX2C:AddField("DX2_MOVDW", '02', "+ ", "DOWN3", {} , 'BT','@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
		
		oView:AddSheet( 'GRADES', 'PASTA02', STR0013) /* Análise de Qualidade e Contaminantes */
		oView:CreateHorizontalBox( 'PASTA_CONT', 100, , , 'GRADES', 'PASTA02' )
		oView:SetOwnerView( 'VIEW_DX2_C', 'PASTA_CONT' )
		
		//-------------------------------------
	    // Valida aba selecionada de acordo com tipo layout
	    oView:SetVldFolder({|cID,nOldSheet, nSelSheet| ValidAba(cID,nOldSheet,nSelSheet)})
		//-------------------------------------
		
		//-------------------------------------
		// Altera ordem de colunas
		//-------------------------------------
		oStruDX2C:SetProperty("DX2_ITEM",  MVC_VIEW_ORDEM,'03')
		oStruDX2C:SetProperty("DX2_TIPRES",MVC_VIEW_ORDEM,'04')
		oStruDX2C:SetProperty("DX2_NOME"  ,MVC_VIEW_ORDEM,'05')
		oStruDX2C:SetProperty("DX2_INICIO",MVC_VIEW_ORDEM,'06')
		oStruDX2C:SetProperty("DX2_TAM"   ,MVC_VIEW_ORDEM,'07')
		oStruDX2C:SetProperty("DX2_DECIMA",MVC_VIEW_ORDEM,'08')
		oStruDX2C:SetProperty("DX2_COLUNA",MVC_VIEW_ORDEM,'09')
		
		oStruDX2C:RemoveField("DX2_FORM")
		oStruDX2C:RemoveField("DX2_OPE")
		oStruDX2C:RemoveField("DX2_CAMPO")	
		
		oView:AddIncrementField('VIEW_DX2_C', 'DX2_ITEM')
		oView:AddIncrementField('VIEW_DX2_C', 'DX2_COLUNA')
	endif
	
	oStruDX2H:SetProperty( 'DX2_NOME' , MVC_VIEW_LOOKUP, 'DX7ES1' ) 

	// Remove campos da estrutura do modelo de dados
	oStruDX2H:RemoveField("DX2_LAYOUT")
	oStruDX2H:RemoveField("DX2_TIPRES")
	oStruDX2H:RemoveField("DX2_DECIMA")

	// Seta o Campo incremental da Grid
	oView:AddIncrementField( 'VIEW_DX2_H', 'DX2_ITEM' )

Return oView

/*/{Protheus.doc} AGRA640GRV
@author carlos.augusto
@since 18/09/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRA640GRV(oModel)

	Local nOperac 	:= oModel:GetOperation()
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local oModelDX1 := oModel:GetModel( 'CABEC' )
	Local oGridCont := oModel:GetModel('ITEM_CONT')
	Local oGridHVI 	:= oModel:GetModel('ITEM_HVI')
	Local nX
	Local nCol
	Local nW
	Local cTmpColumn
	
	If nOperac == MODEL_OPERATION_INSERT .Or. nOperac == MODEL_OPERATION_UPDATE

		if __lTemCont
			If oModelDX1:GetValue('DX1_TIPO') == "1" //HVI
				lRet := .F.
				For nX := 1 to oGridHVI:Length()
					oGridHVI:GoLine(nX)
					If !oGridHVI:IsDeleted() .And. oGridHVI:GetValue('DX2_CAMPO') = "DX7_ETIQ"
						lRet := .T.
					EndIf
				Next nX
				If !lRet
					oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0017 /* "Campo etiqueta não preenchido." */, STR0018 /* "É necessário inserir o campo etiqueta para salvar o layout." */, "", "")
				EndIf
				
				//Deleta as linhas do contaminante caso tenham sido preenchidas.
				For nX := 1 to oGridCont:Length()
					oGridCont:GoLine(nX)
					If !oGridCont:IsDeleted() 
						oGridCont:DeleteLine()
					EndIf
				Next nX
				
				
				//Valida numero de coluna repetida na aba HVI
				If oModelDX1:GetValue('DX1_SPRDOR') $ "1|2"
					While lRet
						For nX := 1 To oGridHVI:Length()
							oGridHVI:GoLine( nX )
							If !oGridHVI:IsDeleted()
								nCol := oGridHVI:GetValue( "DX2_COLUNA")
								For nW := nX+1 To oGridHVI:Length()
									oGridHVI:GoLine( nW )
									IF nCol = oGridHVI:GetValue( "DX2_COLUNA") .And. !oGridHVI:IsDeleted()
										oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0027 /* Ajuda */, STR0028 /* "Não pode haver dois campos utilizando a mesma numeração de coluna!" */, "", "")
										lRet := .F.
										Exit
									EndIf	
								Next nW
							EndIf
							If lRet = .F.
								Exit
							EndIf
						Next nX	
						If nX > oGridHVI:Length()
							Exit
						EndIf
					EndDo
				EndIf
	
			ElseIf oModelDX1:GetValue('DX1_TIPO') == "2" //Contaminante
			
				oGridCont:GoLine(1)
				If Empty(oGridCont:GetValue('DX2_CAMPO'))
					lRet := .F.
					oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0019 /* "Contaminante não selecionado." */, STR0020/*"É necessário escolher um contaminante para salvar o layout." */, "", "")
				EndIf
				
				IF lRet
					lRet := .F.
					For nX := 1 to oGridCont:Length()
						oGridCont:GoLine(nX)
						If !oGridCont:IsDeleted() .And. oGridCont:GetValue('DX2_CAMPO') = "CODUNICO"
							lRet := .T.
						EndIf
					Next nX
					If !lRet
						oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0037 /* "Campo código de barras não preenchido." */, STR0038 /* "É necessário inserir o campo código de barras para salvar o layout." */, "", "")
					EndIf
				EndIf
				
				//Deleta as linhas do HVI caso tenham sido preenchidas.
				For nX := 1 to oGridHVI:Length()
					oGridHVI:GoLine(nX)
					If !oGridHVI:IsDeleted() 
						oGridHVI:DeleteLine()
					EndIf
				Next nX
				
				//Valida numero de coluna repetida na aba Contaminantes
				If oModelDX1:GetValue('DX1_SPRDOR') $ "1|2"
					While lRet
						For nX := 1 To oGridCont:Length()
							oGridCont:GoLine( nX )
							If !oGridCont:IsDeleted()
								nCol := oGridCont:GetValue( "DX2_COLUNA")
								For nW := nX+1 To oGridCont:Length()
									oGridCont:GoLine( nW )
									IF nCol = oGridCont:GetValue( "DX2_COLUNA") .And. !oGridCont:IsDeleted()
										oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0027 /* Ajuda */, STR0028 /* "Não pode haver dois campos utilizando a mesma numeração de coluna!" */, "", "")
										lRet := .F.
										Exit
									EndIf	
								Next nW
							EndIf
							If lRet = .F.
								Exit
							EndIf
						Next nX	
						If nX > oGridCont:Length()
							Exit
						EndIf
					EndDo
				EndIf
				
				//Iteracao no grid de contaminantes para gerar o DX2_CAMPO. 			
				For nX := 1 to oGridCont:Length()
					oGridCont:GoLine(nX)
					If !oGridCont:IsDeleted() 
		
						If oGridCont:GetValue("DX2_ITEM") != "01" .And.;
							oGridCont:GetValue("DX2_ITEM") != "02"  .And.;
							oGridCont:GetValue("DX2_ITEM") != "03"
							cTmpColumn := GeraDX2CPO(oGridCont:GetValue('DX2_NOME'),nX)
							oGridCont:GoLine(nX)
							oGridCont:LoadValue('DX2_CAMPO', cTmpColumn)
						EndIf
						
					EndIf
				Next nX
	
			EndIf
		else
			lRet := .F.
			For nX := 1 to oGridHVI:Length()
				oGridHVI:GoLine(nX)
				If !oGridHVI:IsDeleted() .And. oGridHVI:GetValue('DX2_CAMPO') = "DX7_ETIQ"
					lRet := .T.
				EndIf
			Next nX
			If !lRet
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0017 /* "Campo etiqueta não preenchido." */, STR0018 /* "É necessário inserir o campo etiqueta para salvar o layout." */, "", "")
			EndIf			
			
			//Valida numero de coluna repetida na aba HVI
			If oModelDX1:GetValue('DX1_SPRDOR') $ "1|2"
				While lRet
					For nX := 1 To oGridHVI:Length()
						oGridHVI:GoLine( nX )
						If !oGridHVI:IsDeleted()
							nCol := oGridHVI:GetValue( "DX2_COLUNA")
							
							if nCol > 0
								For nW := nX+1 To oGridHVI:Length()
									oGridHVI:GoLine( nW )
									IF nCol = oGridHVI:GetValue( "DX2_COLUNA") .And. !oGridHVI:IsDeleted()
										oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0027 /* Ajuda */, STR0028 /* "Não pode haver dois campos utilizando a mesma numeração de coluna!" */, "", "")
										lRet := .F.
										Exit
									EndIf	
								Next nW
							else
								oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0027 /* Ajuda */, "Não podem haver campos sem informar a numeração da coluna." /* "Não pode haver dois campos utilizando a mesma numeração de coluna!" */, "", "")
								lRet := .F.
								Exit
							endIf
						EndIf
						If lRet = .F.
							Exit
						EndIf
					Next nX	
					If nX > oGridHVI:Length()
						Exit
					EndIf
				EndDo
			EndIf
		EndIf	
	elseIf nOperac == MODEL_OPERATION_INSERT
		if __lTemCont
			If oModelDX1:GetValue('DX1_TIPO') == "2" .And. Empty(oModelDX1:GetValue('DX1_CONTAM'))
				
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0029 /* "Campo contaminante não preenchido." */, STR0030 /* "Favor selecionar um contaminante." */, "", "")
				lRet := .F.
			EndIf
		endIf
	EndIf

	If lRet
		lRet := oModel:VldData()
	EndIf

	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	if lRet
		lRet := FWFormCommit(oModel)
	endIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA640FLD
//Exibe a aba de acordo com o tipo selecionado
@author carlos.augusto
@since 15/09/2017
@type function
/*/
Function AGRA640FLD()
	Local ovieAtual := FWViewActive()
	Local oModel   	:= FWModelActive()
	Local oModelDX1 := oModel:GetModel( 'CABEC' )
	Local oGridCont := oModel:GetModel('ITEM_CONT')
	Local oGridHVI 	:= oModel:GetModel('ITEM_HVI')
	Local nX

	if __lTemCont
		If oModelDX1:GetValue('DX1_TIPO') == "1" //HVI
			ovieAtual:SelectFolder("GRADES", STR0012,2)
			oModelDX1:LoadValue('DX1_CONTAM', Space(TAMSX3("DX1_CONTAM")[1]))
			oModelDX1:LoadValue('DX1_DESCON', Space(TAMSX3("DX1_DESCON")[1]))
	
			//Deleta as linhas do contaminante caso tenham sido preenchidas.
			For nX := 1 to oGridCont:Length()
				oGridCont:GoLine(nX)
				If !oGridCont:IsDeleted() 
					oGridCont:DeleteLine()
				EndIf
			Next nX
	
			//Voltam as linhas do HVI para ativas caso tenham sido deletadas anteriormente.
			For nX := 1 to oGridHVI:Length()
				oGridHVI:GoLine(nX)
				If oGridHVI:IsDeleted() 
					oGridHVI:UnDeleteLine()
				EndIf
			Next nX
			
		ElseIf oModelDX1:GetValue('DX1_TIPO') == "2" //Contaminante
			If ! IsBlind()
				ovieAtual:SelectFolder("GRADES",STR0013,2)
			EndIf
			//Deleta as linhas do HVI caso tenham sido preenchidas.
			For nX := 1 to oGridHVI:Length()
				oGridHVI:GoLine(nX)
				If !oGridHVI:IsDeleted() 
					oGridHVI:DeleteLine()
				EndIf
			Next nX
	
			//Voltam as linhas do contaminantes para ativas caso tenham sido deletadas anteriormente.
			For nX := 1 to oGridCont:Length()
				oGridCont:GoLine(nX)
				If oGridCont:IsDeleted() 
					oGridCont:UnDeleteLine()
				EndIf
			Next nX
		EndIf
	endIf

Return .T.

/*/{Protheus.doc} AGRA640INI
//Inicializa as tres primeiras linhas
@author carlos.augusto
@since 15/09/2017
@version undefined
@type function
/*/
Function AGRA640INI()
	Local aArea		:= GetArea()
	Local oModel  	:= FWModelActive()
	Local aLines    := FwSaveRows()
	Local oMdlCnt 	:= oModel:GetModel('ITEM_CONT')
	Local oModelDX1 := oModel:GetModel( 'CABEC' )
	Local lRet    	:= .T.
	Local oGridCont := oModel:GetModel('ITEM_CONT')
	Local lGridVaz	:= .T.
	Local oView 	:= FWViewActive()
	Local nLimitador:= 1
	Local nBarras	:= TAMSX3("DXJ_CODBAR")[1]
	Local nUltPos	:= 1

	If IsBlind() 
		If Valtype(oGridCont)!= 'U'
			lGridVaz	:= IIF (oGridCont:Length() >= 3,.F.,.T.)
		EndIf
	ElseIf Valtype(oGridCont)!= 'U'
		lGridVaz	:= IIF (oGridCont:Length() >= 3,.F.,.T.)
	Endif


	//Linha 1
	If ! IsBlind() 
		oMdlCnt:GoLine(1)

		oMdlCnt:SetValue('DX2_ITEM', "01")
		oMdlCnt:SetValue('DX2_CAMPO', "CODUNICO")
		oMdlCnt:LoadValue('DX2_NOME', STR0014) /* Código de Barras */

	If oModelDX1:GetValue('DX1_SPRDOR') == "3" .or. oModelDX1:GetValue('DX1_SPRDOR') == ""
		oMdlCnt:LoadValue('DX2_INICIO', nUltPos)
		oMdlCnt:LoadValue('DX2_TAM', nBarras)
	Else
		oMdlCnt:LoadValue('DX2_COLUNA', 1)
	EndIf
	
	oMdlCnt:SetValue('DX2_TIPRES', "1")
	nUltPos := nBarras
	
	//Linha 2
	If lGridVaz
		oMdlCnt:AddLine()
	EndIf
	DbSelectArea("N76")
	dbSetOrder(1)
	If MsSeek(FwXFilial('N76')+oModelDX1:GetValue('DX1_CONTAM'))
		oMdlCnt:GoLine(2)
		oMdlCnt:SetValue('DX2_ITEM', "02")
		oMdlCnt:SetValue('DX2_CAMPO',"RESCONT")
		oMdlCnt:LoadValue('DX2_NOME', STR0016) /* Pegajosidade */
		
		If oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == ""
			oMdlCnt:LoadValue('DX2_INICIO', nUltPos + nLimitador)			
			If N76->N76_TPCON == "4"
				oMdlCnt:LoadValue('DX2_TAM', TAMSX3("N77_RESULT")[1])
				oMdlCnt:LoadValue('DX2_DECIMA', N76->N76_VLPRC )
				nUltPos += TAMSX3("N77_RESULT")[1]
			Else
				oMdlCnt:LoadValue('DX2_TAM', N76->N76_TMCON)
				oMdlCnt:LoadValue('DX2_DECIMA', N76->N76_VLPRC )
				nUltPos += N76->N76_TMCON
			EndIf
		Else
			oMdlCnt:LoadValue('DX2_COLUNA',2)
		EndIf	
		
		If N76->N76_TPCON == "4" .Or. N76->N76_TPCON == "2" //Lista ou Texto
			oMdlCnt:SetValue('DX2_TIPRES',"1")
		ElseIf N76->N76_TPCON == "3" //Data
			oMdlCnt:SetValue('DX2_TIPRES',"3")
		Else
			oMdlCnt:SetValue('DX2_TIPRES',"2")
		EndIf
	EndIf

	//Linha 3
	If lGridVaz
		oMdlCnt:AddLine()
	EndIf
	oMdlCnt:GoLine(3)
	oMdlCnt:SetValue('DX2_ITEM', "03")
	oMdlCnt:SetValue('DX2_CAMPO', "DATA")
	oMdlCnt:LoadValue('DX2_NOME', STR0015 ) /* Data de Lançamento */
	
	If __nTamData = 0
		DefTamData()
	EndIf
	
	If oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == ""
		If N76->N76_TPCON == "4"
			oMdlCnt:LoadValue('DX2_TAM', __nTamData)
			oMdlCnt:LoadValue('DX2_INICIO', nUltPos + nLimitador)
			nUltPos += __nTamData
		Else
			oMdlCnt:LoadValue('DX2_INICIO', nUltPos + nLimitador)
			oMdlCnt:LoadValue('DX2_TAM', __nTamData)
			nUltPos += __nTamData
		EndIf
	Else
		oMdlCnt:LoadValue('DX2_COLUNA',3)
	EndIf
	
	oMdlCnt:SetValue('DX2_TIPRES',"3")
	EndIf
	_nInicio := nUltPos

	RestArea(aArea)
	If !IsBlind() 
		oView:Refresh('ITEM_CONT')
	Endif
       FwRestRows(aLines)
	
Return lRet


/*/{Protheus.doc} AGRA640CON
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 15/09/2017
@version undefined

@type function
/*/
Function AGRA640CON()
	Local lRet := .T.
	Local oModel   	:= FWModelActive()
	Local oModelDX1 := oModel:GetModel( 'CABEC' )

	If oModelDX1:GetValue('DX1_TIPO') == "1" .OR. ! MODEL_OPERATION_INSERT
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ValidAba
//Essa função valida a aba de acordo com o tipo de layout informado
@author marina.muller
@since 15/09/2017
@param cID, characters, descricao
@type function
/*/
Static Function ValidAba(cID,nOldSheet,nSelSheet)
	Local oModel   := FWModelActive()
	Local oModDX1  := oModel:GetModel( 'CABEC' )
	Local lRet 	   := .T.

	//HVI
	If oModDX1:GetValue('DX1_TIPO') == "1"
		If nSelSheet == 2
			lRet := .F.
		EndIf
		//Contaminante
	ElseIf oModDX1:GetValue('DX1_TIPO') == "2"
		If nSelSheet == 1
			lRet := .F.
		EndIf
	ElseIf Empty(oModDX1:GetValue('DX1_TIPO'))
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} A640NODEL
//Função usada no bloco de código de pré-validação do submodelo da grid de layout de contaminantes.
@author brunosilva
@since 18/09/2017
@version undefined
@param oItemCont, , Model
@param nLine, numeric, Número da linha posicionada no grid
@param cAction, characters, Ação realizada
@param cField, characters, Campo posicionado
@param xValueNew, , Valor novo
@param xValueOld, , Valor antigo
@type function
/*/
Function A640NODEL(oItemCont, nLine, cAction, cField, xValueNew, xValueOld)
	Local lRet      := .T.
	Local ovieAtual := FWViewActive()
	Local oModel  	:= FWModelActive()
	Local oModDX1   := oModel:GetModel( 'CABEC' )	
	Local oModDX2C 	:= oModel:GetModel('ITEM_CONT')
	Default nLine   := 0
	
	if nLine > 0 .AND. cAction == "DELETE"
		If AllTrim(oModDX2C:GetValue('DX2_CAMPO', nLine)) == "CODUNICO" .OR. ;
		   AllTrim(oModDX2C:GetValue('DX2_CAMPO', nLine)) == "RESCONT"  .OR. ;
		   AllTrim(oModDX2C:GetValue('DX2_CAMPO', nLine)) == "DATA" 
		   
		   If !IsInCallStack("AGRA640GRV") .And. (oModDX1:GetValue('DX1_TIPO') == '2')	
				lRet := .F.
				oItemCont:GetModel():SetErrorMessage(oItemCont:GetId(), , oItemCont:GetId(), "", "", STR0025 /* "Operação não permitida." */, STR0026 /* "Os campos Código de Barras, Pegajosidade e Data de Lançamento não podem ser excluídos." */, "", "")
			Else
				ovieAtual:Refresh()
			EndIf
		EndIf
	EndIF
	
Return lRet


/*/{Protheus.doc} AGRA640ACT
//Esconde folder na alteracao
@author carlos.augusto
@since 18/09/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRA640ACT(oModel)
	Local nOperation 	:= oModel:GetOperation()
	Local oModDX1  		:= oModel:GetModel( 'CABEC' )
	Local ovieAtual 	:= FWViewActive()
	Local lRet			:= .T.

	if __lTemCont
		If ! IsBlind()
			If nOperation != 3 .And. (oModDX1:GetValue('DX1_TIPO') == '1' .Or. Empty(oModDX1:GetValue('DX1_TIPO')))
				ovieAtual:HideFolder("GRADES", STR0013,2)
			ElseIf nOperation != 3 .And. oModDX1:GetValue('DX1_TIPO') == '2'
				ovieAtual:HideFolder("GRADES",STR0012,2)
			EndIf
		EndIf	

		//Altera campos obrigatorios e when de acordo com o tipo de separador
		AGRA640CAM()
	endIf

Return lRet


/*/{Protheus.doc} AGRA640VlT
//Valida se o campo tamanho terá valor default dependendo do preenchimento do tipo
@author marina.muller
@since 18/09/2017
@type function
/*/
Function AGRA640VlT()
	Local aLines    := FwSaveRows()
	Local oModel	:= FWModelActive()
	Local oStruDX2C := oModel:GetModel('ITEM_CONT')
	Local lRet 		:= .T.
	Local oModelDX1 := oModel:GetModel( 'CABEC' )

	nLinha := oStruDX2C:GetLine()
    oStruDX2C:GoLine(nLinha)
    
	If __nTamData = 0
		DefTamData()
	EndIf
    		
    If nLinha > 3
    
		//3 - Data
		If (oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == "") .And.;
		   oStruDX2C:GetValue('DX2_TIPRES') == "3"
		   oStruDX2C:LoadValue('DX2_TAM', __nTamData)
		EndIf
	EndIf	
	
	FwRestRows(aLines)

Return lRet



/*/{Protheus.doc} AGRA640COM
//Zera colunas DX2_INICIO, DX2_TAM, DX2_DECIMA, preenche DX2_COLUNA quando for sem separador
//Preenche colunas DX2_INICIO, DX2_TAM, DX2_DECIMA, zera DX2_COLUNA quando for com separador
@author carlos.augusto
@since 28/09/2017
@version undefined

@type function
/*/
Function AGRA640COM()
	Local lRet    	:= .T.
	Local oModel  	:= FWModelActive()
	Local oModelDX1 := oModel:GetModel( 'CABEC' )	
	Local oGridCont := oModel:GetModel('ITEM_CONT')
	Local oGridHVI 	:= oModel:GetModel('ITEM_HVI')
	Local nX
	Local oView 	:= FWViewActive()
	
	Private _nInicio	:= 1
	
	//Altera campos obrigatorios e when de acordo com o tipo de separador
	AGRA640CAM()
	
	If oModelDX1:GetValue('DX1_SPRDOR') $ "1|2"
		If oModelDX1:GetValue('DX1_TIPO') == '1'
			For nX := 1 to oGridHVI:Length()
				oGridHVI:GoLine(nX)
				If !Empty(oGridHVI:GetValue("DX2_CAMPO"))
					oGridHVI:LoadValue("DX2_COLUNA",nX)
					oGridHVI:LoadValue("DX2_INICIO",0)
					oGridHVI:LoadValue("DX2_TAM",0)
					oGridHVI:LoadValue("DX2_DECIMA",0)
				EndIf
			Next nX
		ElseIf oModelDX1:GetValue('DX1_TIPO') == '2'
			For nX := 1 to oGridCont:Length()
				oGridCont:GoLine(nX)
				oGridCont:LoadValue("DX2_INICIO",0)
				oGridCont:LoadValue("DX2_TAM",0)
				oGridCont:LoadValue("DX2_DECIMA",0)
				oGridCont:LoadValue("DX2_COLUNA",nX)
			Next nX
		EndIf
	ElseIf oModelDX1:GetValue('DX1_SPRDOR') $ "3|"

		If __nTamData = 0
			DefTamData()
		EndIf

		//Contaminante
		If oModelDX1:GetValue('DX1_TIPO') == '2'
			AGRA640INI()
			
			For nX := 1 to oGridCont:Length()
				oGridCont:GoLine(nX)
				oGridCont:LoadValue("DX2_COLUNA",0)
				If nX > 3
					oGridCont:LoadValue("DX2_INICIO",_nInicio + 1)
					If oGridCont:GetValue('DX2_TIPRES') == "1"
						oGridCont:LoadValue("DX2_TAM",TamSx3("NPX_RESTXT")[1])
						_nInicio += TamSx3("NPX_RESTXT")[1]
					EndIf
					If oGridCont:GetValue('DX2_TIPRES') == "2"
						oGridCont:LoadValue("DX2_TAM",TamSx3("NPX_RESNUM")[1] + 1)
						_nInicio += TamSx3("NPX_RESNUM")[1]
					EndIf
					If oGridCont:GetValue('DX2_TIPRES') == "3"
						oGridCont:LoadValue("DX2_TAM", __nTamData + 1)
						_nInicio += __nTamData
					EndIf
					oGridCont:LoadValue("DX2_DECIMA",0)
				EndIf

			Next nX
		//HVI
		Else
			_nInicio := 0
			For nX := 1 to oGridHVI:Length()
				oGridHVI:GoLine(nX)
				oGridHVI:LoadValue("DX2_INICIO",_nInicio + 1)
				If TamSx3(oGridHVI:GetValue('DX2_CAMPO') )[3] == "D"
					If __nTamData = 0
						DefTamData()
					EndIf
					oGridHVI:LoadValue("DX2_TAM" ,__nTamData)
				Else
					oGridHVI:LoadValue("DX2_TAM",TamSx3(oGridHVI:GetValue('DX2_CAMPO') )[1])
					oGridHVI:LoadValue("DX2_DECIMA",TamSx3(oGridHVI:GetValue('DX2_CAMPO') )[2])
				EndIf
				
				oGridHVI:LoadValue("DX2_COLUNA",0)
				If TamSx3(oGridHVI:GetValue('DX2_CAMPO') )[3] == "D"
					_nInicio += __nTamData
				Else
					_nInicio += TamSx3(oGridHVI:GetValue('DX2_CAMPO') )[1]
				EndIf
				

			Next nX
		EndIf
	EndIf
	If !IsBlind() 
		oView:Refresh()
	EndIf
Return lRet


/*/{Protheus.doc} AGRA640CAM
//Altera obrigatoriedade e permissao de alteracao conforme separador
@author carlos.augusto
@since 28/09/2017
@version undefined

@type function
/*/
Static Function AGRA640CAM()
	Local lRet    	:= .T.
	Local oModel  	:= FWModelActive()
	Local oModelDX1 := oModel:GetModel( 'CABEC' )	

	If IsBlind() 
		__lTemCont := .T.
	Endif

	If oModelDX1:GetValue('DX1_SPRDOR') $ "1|2"
	
		if __lTemCont
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_OBRIGAT,.T.)
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_OBRIGAT,.F.)				
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_OBRIGAT,.F.)
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_WHEN,{|| .T.})		
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_WHEN,{|| .F.})
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_WHEN,{|| .F.})
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_DECIMA', MODEL_FIELD_WHEN,{|| .F.})	
		endIf
		
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_OBRIGAT,.T.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_OBRIGAT,.F.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_OBRIGAT,.F.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_WHEN,{|| .T.})
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_WHEN,{|| .F.})
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_WHEN,{|| .F.})	

	ElseIf oModelDX1:GetValue('DX1_SPRDOR') $ "3|"	
		if __lTemCont
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_OBRIGAT,.F.)
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_OBRIGAT,.T.)		
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_OBRIGAT,.T.)	
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_WHEN,{|| .F.})
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_WHEN,{|| .T.})
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_WHEN,{|| .T.})
			oModel:GetModel("ITEM_CONT"):GetStruct():SetProperty('DX2_DECIMA', MODEL_FIELD_WHEN,{|| .T.})
		endIf
		
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_OBRIGAT,.F.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_OBRIGAT,.T.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_OBRIGAT,.T.)
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_COLUNA', MODEL_FIELD_WHEN,{|| .F.})
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_INICIO', MODEL_FIELD_WHEN,{|| .T.})
		oModel:GetModel("ITEM_HVI"):GetStruct():SetProperty('DX2_TAM', MODEL_FIELD_WHEN,{|| .T.})
	EndIf

Return lRet


/*/{Protheus.doc} AGRA640DAT
//Na aba HVI, quando for selecionados os campos DX7_DATENV, DX7_DATREC alterar tamanho para 8 e os campos
DX7_HORENV, DX7_HORREC alterar tamanho para 5
@author carlos.augusto
@since 28/09/2017
@version undefined

@type function
/*/
Function AGRA640DAT()
	Local aLines    := FwSaveRows()
	Local oModel	:= FWModelActive()
	Local oStruDX2H := oModel:GetModel('ITEM_HVI')
	Local lRet 		:= .T.
	Local oModelDX1 := oModel:GetModel( 'CABEC' )

	If (oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == "") .AND. !Empty(FwFldGet('DX2_CAMPO'))
		If TamSx3(oStruDX2H:GetValue('DX2_CAMPO') )[3] == "D"
			If __nTamData = 0
				DefTamData()
			EndIf
			oStruDX2H:LoadValue('DX2_TAM', __nTamData)
		Else
			oStruDX2H:LoadValue('DX2_TAM', TAMSX3(oStruDX2H:GetValue('DX2_CAMPO'))[1])
		EndIf
	EndIf	
	
	FwRestRows(aLines)

Return lRet

/*/{Protheus.doc} AGRA640TMH
//Na aba HVI, quando for selecionados os campos DX7_DATENV, DX7_DATREC, DX7_HORENV, DX7_HORREC bloquear a alteracao de tamanho
@author carlos.augusto
@since 28/09/2017
@version undefined

@type function
/*/
Function AGRA640TMH()
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oStruDX2H := oModel:GetModel('ITEM_HVI')
	Local oModelDX1 := oModel:GetModel( 'CABEC' )

	If (oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == "") .And. ;
		(oStruDX2H:GetValue('DX2_CAMPO') == "DX7_DATENV" .OR. oStruDX2H:GetValue('DX2_CAMPO') == "DX7_DATREC" .OR. ;
		 oStruDX2H:GetValue('DX2_CAMPO') == "DX7_HORENV" .OR. oStruDX2H:GetValue('DX2_CAMPO') == "DX7_HORREC")
		lRet := .F.
	EndIf

Return lRet



/*/{Protheus.doc} AGRA640PAD
//Inicializa o campo DX2_INICIO
@author carlos.augusto
@since 29/09/2017
@version undefined
@type function
/*/
Function AGRA640PAD() 
	Local oModel	:= FWModelActive()
	Local aLines    := FwSaveRows()
	Local oStruDX2C := oModel:GetModel('ITEM_CONT')
	Local oModelDX1 := oModel:GetModel( 'CABEC' )
	Local nValor	:= 0

	nLinha := oStruDX2C:GetLine()
    		
    If nLinha >= 3 .And. (oModelDX1:GetValue('DX1_SPRDOR') == "3" .Or. oModelDX1:GetValue('DX1_SPRDOR') == "")
    	nValor := oStruDX2C:GetValue('DX2_INICIO', oStruDX2C:GetLine()) + oStruDX2C:GetValue('DX2_TAM', oStruDX2C:GetLine())
	EndIf	
	
	FwRestRows(aLines)
	

Return nValor


/*/{Protheus.doc} GeraDX2CPO
//Gerar nomes para colunas personalizadas
Caso ja exista, soma 1 no nome da coluna (AAA + 1 = AAB)
@author carlos.augusto
@since 02/10/2017
@version undefined
@type function
/*/
Static Function GeraDX2CPO(cCampo, nLinAtual)
	Local oModel  	:= FWModelActive()
	Local oGridCont := oModel:GetModel('ITEM_CONT')
	Local nX
	
	Local cSemEsp 	:= StrTran(cCampo, " ", "")
	Local cNomeCpo	:= ""
	
	If Len(cSemEsp) <= 10
		cNomeCpo := cSemEsp
	Else
		cNomeCpo := Substr(cSemEsp,1,10)
	EndIf
	
	For nX := 1 to oGridCont:Length()
		oGridCont:GoLine(nX)
		
		If oGridCont:GetValue("DX2_ITEM") != "01" .And.;
			oGridCont:GetValue("DX2_ITEM") != "02"  .And.;
			oGridCont:GetValue("DX2_ITEM") != "03"
		
			/* Nao comparar a mesma linha / ver se a coluna tera o mesmo nome */
			If nX != nLinAtual .And. Substr(StrTran(oGridCont:GetValue("DX2_NOME", nX), " ", ""),1,10) = Substr(StrTran(cCampo, " ", ""),1,10)
				/* Se ainda nao gravou nome e/mas ja encontrou outro nome que seria igual, soma1 no atual para ficar diferente.
				Somara 1 ate que o DX2_CAMPO de outro campo esteja vazio. Isso no caso de 3 ou mais nomes iguais ate o decimo caracter  */
				If (Empty(oGridCont:GetValue("DX2_CAMPO", nLinAtual)) .And. !Empty(oGridCont:GetValue("DX2_CAMPO", nX)))
					cNomeCpo := Soma1(oGridCont:GetValue("DX2_CAMPO", nX))
				/* Se ainda nao gravou nome e nao tem outro igual, mantem nome criado no inicio */
				ElseIf (Empty(oGridCont:GetValue("DX2_CAMPO", nLinAtual)) .And. Empty(oGridCont:GetValue("DX2_CAMPO", nX)))
					exit
				EndIf
			EndIf
		EndIf
	Next nX

Return cNomeCpo



/*/{Protheus.doc} AGRA640TMV
//Valida o campo tamanho quando contaminantes
@author carlos.augusto
@since 03/10/2017
@version undefined
@type function
/*/
Function AGRA640TMV()
	Local lRet 		:= .T.
	Local oModel  	:= FWModelActive()
	Local oStruDX2C := oModel:GetModel('ITEM_CONT')
	Local oModDX1  	:= oModel:GetModel( 'CABEC' )
	
	If oModDX1:GetValue('DX1_TIPO') == '2'
		//STR0031 = O tamanho definido ultrapassa a capacidade do campo:
		//STR0032 = Favor informar um número menor ou igual a:
		If oStruDX2C:GetValue('DX2_TIPRES') == "1" .And. (oStruDX2C:GetValue('DX2_TAM') > TamSX3("NPX_RESTXT")[1])
			lRet := .F.
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0031 + cValToChar(TamSX3("NPX_RESTXT")[1]), STR0032 + cValToChar(TamSX3("NPX_RESTXT")[1]) , "", "")
		ElseIf oStruDX2C:GetValue('DX2_TIPRES') == "2"  .And. (oStruDX2C:GetValue('DX2_TAM') > TamSX3("NPX_RESNUM")[1])
			lRet := .F.
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0031 + cValToChar(TamSX3("NPX_RESNUM")[1]), STR0032 + cValToChar(TamSX3("NPX_RESNUM")[1]) , "", "")
		ElseIf oStruDX2C:GetValue('DX2_TIPRES') == "3"  .And. (oStruDX2C:GetValue('DX2_TAM') > __nTamData)
			lRet := .F.
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0031 + cValToChar(__nTamData), STR0032 + cValToChar(__nTamData) , "", "")
		EndIf 
	EndIf
	
Return lRet


/*/{Protheus.doc} AGRA640DCV
//Valida o campo decimal. 
Busca na SX3 o tamanho maximo. 
Valida Decimal apenas para numerico
@author carlos.augusto
@since 03/10/2017
@version undefined

@type function
/*/
Function AGRA640DCV()
	Local lRet 		:= .T.
	Local oModel  	:= FWModelActive()
	Local oStruDX2C := oModel:GetModel('ITEM_CONT')
	Local oModDX1  	:= oModel:GetModel( 'CABEC' )
	
	If oModDX1:GetValue('DX1_TIPO') == '2'
	
		If oStruDX2C:GetValue('DX2_TIPRES') == "2"  .And. (oStruDX2C:GetValue('DX2_DECIMA') > TamSX3("NPX_RESNUM")[2])
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0033 /*"O decimal definido ultrapassa a capacidade do campo: "*/;
			+ cValToChar(TamSX3("NPX_RESNUM")[2]), STR0034 /*"Favor informar um número menor ou igual a: " */ + cValToChar(TamSX3("NPX_RESNUM")[2]) , "", "")
			lRet := .F.
		EndIf
		
		If oStruDX2C:GetValue('DX2_TIPRES') != "2" .And. oStruDX2C:GetValue('DX2_DECIMA') > 0
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0035 /*"O tipo de resultado não é numérico."*/, STR0036 /*"Favor manter o campo zerado." */ , "", "")
			lRet := .F.
		EndIf
		
	EndIf
	
Return lRet


/*{Protheus.doc} AGRA640NM
(Valid para o campo de HVI)
@type function
@author carlos.augusto
@since 04/05/2017
@version 1.0
*/
Function AGRA640NM()
	Local lRet 		:= .T.
	Local oStruDX2	:= Nil
	Local nIt		:= 0
	
	oStruDX2 := FwFormStruct(1, "DX7", {|cCampo| ALLTRIM(cCampo) $ __cCampDX7}) // Obtem a estrutura da DX7
	
	For nIt := 1 To Len(oStruDX2:AFIELDS)	// Percore os campos da DX7
		// Compara os Titulos dos campos a fim de encontrar o campo informado na tela	 
		If UPPER(AllTrim(oStruDX2:AFIELDS[nIt][1])) == UPPER(AllTrim(FwFldGet("DX2_NOME")))
			// Se os valor encontrado é diferente do que contem no campo, preenche o campo
			If AllTrim(oStruDX2:AFIELDS[nIt][3]) != AllTrim(FwFldGet("DX2_CAMPO")) 
				FwFldPut('DX2_CAMPO', oStruDX2:AFIELDS[nIt][3], , , , .T.)
				lRet := .T.
				Exit
			Else // Senão o valor ja está contido no campo
				lRet := .T.
				Exit
			EndIf
		Else // Caso não encontrar o campo, o valor informado é invalido
			lRet := .F.
		EndIf
	Next nIt
	If Empty(FwFldGet("DX2_NOME")) // Se o campo informado estiver vazio, limpa o campo hvi
		FwFldPut('DX2_CAMPO', "", , , , .T.)
		lRet := .T.
	
	EndIf	
	
Return lRet

//
// Retorna o conteudo escolhido na consulta
//
Function AGRA640F3() 
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local aCpos     := {}       	//Array com os dados
	Local aRet      := {}       	//Array do retorno da opcao selecionada
	Local oDlg                  	//Objeto Janela
	Local oLbx                  	//Objeto List box
	Local cTitulo   := STR0009	 //"Tabela DX7"
	Local cNoCpos   := "DX7_FILIAL|DX7_LAB|DX7_UNI|DX7_SAFRA"
	Local lRet 		:= .F.
	Local aCampos   := {}
	Local nX        := 0
		    
	//Obtém os campos não virtuais da tabela
	aCampos := FWSX3Util():GetAllFields( "DX7", .F. ) 

	//Carrega o vetor com os campos da tabela selecionada
	For nX := 1 To Len(aCampos)
		If X3USADO(aCampos[nX]) .AND. !AllTrim(aCampos[nX]) $ cNoCpos
		   aAdd( aCpos, { aCampos[nX], FWSX3Util():GetDescription(aCampos[nX])  } )
	   EndIf
	Next nX
	
	If Len( aCpos ) > 0
	
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
		   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0010, STR0011  SIZE 230,95 OF oDlg PIXEL	 //"Campo"###"Titulo"
	
		   oLbx:SetArray( aCpos )
		   oLbx:bLine     	:= {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
		   oLbx:bLDblClick 	:= {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}} 	                   
	
		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
	
		oModel:SetValue('ITEM_HVI', 'DX2_CAMPO', IIF(Len(aRet) > 0, aRet[1],"") )	
		oModel:SetValue('ITEM_HVI', 'DX2_NOME' , IIF(Len(aRet) > 0, aRet[2],"") )	
		 
		If Len(aRet) > 0  
			lRet := .T.
			SX3->(dbSetOrder(2))
			SX3->(dbSeek(aRet[1]))
		EndIf
		
	EndIf	
	
	oView:Refresh()
Return lRet

/*/{Protheus.doc} AjusTipHVI
Ajuste dos registros sem o tipo do layout (HVI/Contaminante)
@author silvana.torres / marina.muller
@since 11/12/2017
@version undefined

@type function
/*/
Static Function AjusTipHVI() 

	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cAliasDX2 := GetNextAlias() 
	Local cAliasDX1 := GetNextAlias()
	
	//ajuste da DX2
	BeginSql Alias cAliasDX2
	  Select DX2_FILIAL, DX2_LAYOUT, DX2_ITEM, DX2_TIPO
	    From %table:DX2% DX2
	   where DX2.%notDel%
	     and DX2.DX2_TIPO = ''
	EndSql
	
	If (cAliasDX2)->(!Eof())
		(cAliasDX2)->(dbGoTop())
		While (cAliasDX2)->(!Eof())
			
			dbSelectArea('DX2')
			dbSetOrder(1)        //DX2_FILIAL+DX2_LAYOUT+DX2_ITEM+DX2_CAMPO
			If MsSeek((cAliasDX2)->DX2_FILIAL+(cAliasDX2)->DX2_LAYOUT+(cAliasDX2)->DX2_ITEM)
	
				If RecLock('DX2',.F.)
					DX2->DX2_TIPO 	:= '1'   //1=HVI 
					DX2->(MsUnlock())
				Endif
			Endif
			
			(cAliasDX2)->(dbSkip())
		EndDo
		(cAliasDX2)->(dbCloseArea())
	EndIf
		
	//ajuste da DX1
	BeginSql Alias cAliasDX1
	  Select DX1_FILIAL, DX1_CODIGO
	    From %table:DX1% DX1
	   where DX1.%notDel%
	     and DX1.DX1_TIPO = ''
	EndSql

	If (cAliasDX1)->(!Eof())
		(cAliasDX1)->(dbGoTop())
	
		While (cAliasDX1)->(!Eof())
			
			dbSelectArea('DX1')
			dbSetOrder(1)        //DX1_FILIAL+DX1_CODIGO
			If MsSeek((cAliasDX1)->DX1_FILIAL+(cAliasDX1)->DX1_CODIGO)
	
				If RecLock('DX1',.F.)
					DX1->DX1_TIPO 	:= '1'       //1=HVI
					DX1->(MsUnlock())
				Endif
			Endif
			
			(cAliasDX1)->(dbSkip())
		EndDo
		(cAliasDX1)->(dbCloseArea())
	EndIf
		
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} AGRA640MOV
//Função para reposicionar a coluna (Logica importada da funcao UBAA020MOV)
@author silvana.torres
@since 03/09/2018
@version undefined
@param nTipo, numeric, descricao
@type function
/*/
Static Function AGRA640MOV(nTipo)
	Local oView     := FWViewActive() // View que se encontra Ativa
	Local oModel    := FWModelActive() // Model que se encontra Ativo
	Local oModelDX1 := oModel:GetModel( 'CABEC' )
	Local oModelDX2	:= oModel:GetModel('ITEM_CONT') // Submodelo da Grid
	Local nLinhaOld := oView:GetLine('ITEM_CONT') // Linha atualmente posicionada
	Local cLinAtu	:= oModelDX2:GetValue("DX2_COLUNA", nLinhaOld) // Pega o valor da Ordem na linha atual

	If nTipo == 1 // Para cima

		If nLinhaOld != 1

			oModelDX2:LoadValue("DX2_COLUNA", oModelDX2:GetValue("DX2_COLUNA", nLinhaOld - 1)) // Seta o valor da linha de cima para atual
			oModelDX2:GoLine(nLinhaOld - 1) // Move o posicionamento para a linha de cima
			oModelDX2:LoadValue("DX2_COLUNA", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oView:LineShift('ITEM_CONT',nLinhaOld ,nLinhaOld - 1) // Realiza a troca de linhas
			oModelDX2:GoLine(nLinhaOld - 1)

		EndIf

	Else // Para baixo

		If nLinhaOld < oView:Length('ITEM_CONT')

			oModelDX2:LoadValue("DX2_COLUNA", oModelDX2:GetValue("DX2_COLUNA", nLinhaOld + 1)) // Seta o valor da linha de baixo para atual
			oModelDX2:GoLine(nLinhaOld + 1) // Move o posicionamento para a linha de baixo
			oModelDX2:LoadValue("DX2_COLUNA", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oModelDX2:GoLine(nLinhaOld)
			oView:LineShift('ITEM_CONT',nLinhaOld,nLinhaOld + 1) // Realiza a troca de linhas
			oModelDX2:GoLine(nLinhaOld)

		EndIf
	EndIf
	
	If oModelDX1:GetValue('DX1_SPRDOR') == "3"	
		A640Recalc()
	EndIf

	oView:Refresh('ITEM_CONT') // Atualiza a SubView da Grid

	If nTipo == 1
		oModelDX2:GoLine(nLinhaOld - 1)
	Else
		oModelDX2:GoLine(nLinhaOld + 1)
	Endif

Return .T.


/*/{Protheus.doc} A640Recalc
Recalcula o campo início com base no tamanho
@author silvana.torres
@since 04/09/2018
@version undefined

@type function
/*/
Static Function A640Recalc()

	Local oModel    := FWModelActive() // Model que se encontra Ativo
	Local oGridCont	:= oModel:GetModel('ITEM_CONT') // Submodelo da Grid	
	Local nX		:= 0
	Local nIniAnt	:= 0
	Local nTamAnt	:= 0
	Local lPrim		:= .T.

	For nX := 1 to oGridCont:Length()
		oGridCont:GoLine(nX)
		If !Empty(oGridCont:GetValue("DX2_NOME")) .AND. .NOT. oGridCont:IsDeleted()
		 	If lPrim == .T.
		 		lPrim 	:= .F.
		 		oGridCont:LoadValue("DX2_INICIO",1)
		 	Else
		 		oGridCont:LoadValue("DX2_INICIO",(nIniAnt + nTamAnt))
		 	EndIf
		 	
			nIniAnt := oGridCont:GetValue("DX2_INICIO")
		 	nTamAnt	:= oGridCont:GetValue("DX2_TAM")
		EndIf
	Next nX
			
Return .T.


/*/{Protheus.doc} DefTamData
//Definir tamanho do campo data
@author carlos.augusto
@since 26/03/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function DefTamData()
	
	//"O padrão do campo data é AAAAMMDD com tamanho 8 (nas importações). 
	//Deseja alterar o padrão do campo para DD/MM/AAAA com tamanho 10 (nas importações)?"
	//"Definir tamanho do campo data"
        If IsBlind() 
		__nTamData := 10
	Else
		If MsgYesNo(STR0039, STR0040)
			__nTamData := 10
		Else
			__nTamData := 8
		EndIf
	Endif
Return