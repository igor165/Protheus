#INCLUDE "UBAA040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} UBAA040
@author 	carlos.augusto
@since 		06/02/2017
@version 	1.0
*/  
Function UBAA040()
    Local oBrowse
    Private _cPicture	:= ""
    Private _nTamTemp	:= Nil
    Private _nPrecTemp	:= Nil

	If !N76->(ColumnPos('N76_CODIGO'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('N76')
	oBrowse:SetMenuDef('UBAA040')
    oBrowse:SetDescription(STR0001) //#Cadastro de Contaminantes
	oBrowse:Activate()
	
Return( Nil )


/*{Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@author 	carlos.augusto
@since 		17/03/2017
@version 	1.0
*/  
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruN76 		:= FwFormStruct( 1, "N76" )
	Local oStruN77Lt 	:= FwFormStruct( 1, "N77" )
	Local oStruN77Fa 	:= FwFormStruct( 1, "N77" )
	Local bGrdVld   := {|oItemCont, nLine, cAction, cField, xValueNew, xValueOld | UBAA040NOD(oItemCont, nLine, cAction, cField, xValueNew, xValueOld)}

	oModel := MPFormModel():New('UBAA040',/*bPre*/,{|oModel| UBAA040POS(oModel)}, {|oModel| UBAA040GRV(oModel)})

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN76', /*cOwner*/, oStruN76 )

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGrdN77Lt', 'MdFieldN76', oStruN77Lt,/*bLinePre*/, /*bLinePost*/,bGrdVld,bGrdVld)
	oModel:GetModel( 'MdGrdN77Lt' ):SetUniqueLine( {'N77_RESULT'} )
	
	oModel:AddGrid( 'MdGridN77Fa', 'MdFieldN76', oStruN77Fa,/*bLinePre*/,/*bLinePost*/,bGrdVld,bGrdVld)
	//-------------------------------------
	// Seta campos obrigatorios
	//-------------------------------------

	oStruN77Lt:SetProperty( 'N77_RESULT' , MODEL_FIELD_OBRIGAT , .T.)
	oStruN77Fa:SetProperty( 'N77_RESULT' , MODEL_FIELD_OBRIGAT , .T.)
	oStruN77Fa:SetProperty( 'N77_FAIINI' , MODEL_FIELD_OBRIGAT , .F.)
	oStruN77Fa:SetProperty( 'N77_FAIFIM' , MODEL_FIELD_OBRIGAT , .T.)

	//-------------------------------------
	// Seta linha unica da grid
	//-------------------------------------
	oModel:GetModel( 'MdGridN77Fa' ):SetUniqueLine( {'N77_RESULT'} )
	
	//-------------------------------------
	// Seta preenchimento opcional da Grid
	//-------------------------------------
	oModel:GetModel( "MdGridN77Fa"):SetOptional( .T. )
	oModel:GetModel( "MdGrdN77Lt" ):SetOptional( .T. )

	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGridN77Fa', { { 'N77_FILIAL', 'xFilial( "N77" )' }, { 'N77_CODCTM', 'N76_CODIGO' } })
	oModel:SetRelation( 'MdGrdN77Lt' , { { 'N77_FILIAL', 'xFilial( "N77" )' }, { 'N77_CODCTM', 'N76_CODIGO' } })

	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate({|oModel|InitUBA040(oModel)}) // Inicializa os campos conforme o pergunte
Return oModel


/*{Protheus.doc} ViewDef
Define a estrutura da tela e a divisao em grupos

@author 	carlos.augusto
@since 		17/03/2017
@version 	1.0
*/  
Static Function ViewDef()
    Local oModel 		:= FWLoadModel('UBAA040')
    Local oStruN76 		:= FWFormStruct(2,'N76')
    Local oStruN77Fa 	:= FWFormStruct(2,'N77')
    Local oStruN77Lt 	:= FWFormStruct(2,'N77')
	Local oView			:= Nil

    oView := FWFormView():New()
    oView:SetModel(oModel)

	//------------------
	//Instancia a View
	//------------------
	oView := FwFormView():New()

	//------------------------
	//Seta o modelo de dados
	//------------------------
	oView:SetModel( oModel )

	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_N76', oStruN76, 'MdFieldN76' )
	
	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------
	
	oStruN76:RemoveField("N76_DATINC")
	oStruN76:RemoveField("N76_HORINC")
	oStruN76:RemoveField("N76_DATATU")
	oStruN76:RemoveField("N76_HORATU")
		
	oStruN77Fa:RemoveField("N77_DATINC")
	oStruN77Fa:RemoveField("N77_HORINC")
	oStruN77Fa:RemoveField("N77_DATATU")
	oStruN77Fa:RemoveField("N77_HORATU")
	
	oStruN77Lt:RemoveField("N77_DATINC")
	oStruN77Lt:RemoveField("N77_HORINC")
	oStruN77Lt:RemoveField("N77_DATATU")
	oStruN77Lt:RemoveField("N77_HORATU")
	
	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N77FA', oStruN77Fa, 'MdGridN77Fa' )
	oView:AddGrid( 'VIEW_N77LT', oStruN77Lt, 'MdGrdN77Lt' )
	
	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------

	oStruN77Lt:RemoveField( "N77_FAIINI" )
	oStruN77Lt:RemoveField( "N77_FAIFIM" )
		
	//----------------------
	//Cria o Box Horizontal
	//----------------------
	oView:CreateHorizontalBox( 'CABEC', 60 )
	oView:CreateHorizontalBox( 'GRID', 40 )

	// ------------
	// Cria Folder
	// ------------
	oView:CreateFolder( 'GRADES', 'GRID')
	oView:AddSheet( 'GRADES', 'PASTA01', STR0002)
	oView:AddSheet( 'GRADES', 'PASTA02', STR0003)
	
	// ----------
	// Cria Box
	// ----------
	oView:CreateHorizontalBox( 'PASTALISTA', 100, , , 'GRADES', 'PASTA01' )
	oView:CreateHorizontalBox( 'PASTAFAIXA', 100, , , 'GRADES', 'PASTA02' )

	//----------------------
	//Seta owner da view
	//----------------------
	oView:SetOwnerView( 'VIEW_N76', 'CABEC' )
	oView:SetOwnerView( 'VIEW_N77LT', 'PASTALISTA' )
	oView:SetOwnerView( 'VIEW_N77FA', 'PASTAFAIXA' )

	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_N77FA', 'N77_SEQ' )
	oView:AddIncrementField( 'VIEW_N77LT', 'N77_SEQ' )

	oStruN76:AddGroup( 'GRUPO01', STR0014, '', 2 ) //Outros
	oStruN76:AddGroup( 'GRUPO02', STR0012, '', 2 ) //Tipo de Dados
	oStruN76:AddGroup( 'GRUPO03', STR0013, '', 2 ) //Valores

	oStruN76:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

	oStruN76:SetProperty( 'N76_CODIGO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruN76:SetProperty( 'N76_NMCON'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruN76:SetProperty( 'N76_DESCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruN76:SetProperty( 'N76_SITCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruN76:SetProperty( 'N76_DISPWS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruN76:SetProperty( 'N76_NIVPRO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')

    oStruN76:SetProperty( 'N76_TPCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO03')
    oStruN76:SetProperty( 'N76_TMCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO03')
    oStruN76:SetProperty( 'N76_VLPRC' , MVC_VIEW_GROUP_NUMBER, 'GRUPO03')


    
Return oView

/*{Protheus.doc} MenuDef
Opcoes de menu

@author 	carlos.augusto
@since 		17/03/2017
@version 	1.0
*/  
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.UBAA040' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.UBAA040' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.UBAA040' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.UBAA040' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.UBAA040' OPERATION 8 ACCESS 0    // 'Imprimir'

Return aRotina


/*{Protheus.doc} UBAA040POS
Validação das informações para confirmação dos dados. Executado antes de salvar

@author 	carlos.augusto
@since 		17/03/2017
@version 	1.0
*/  
Function UBAA040POS(oModel)
	Local nOperation 	:= oModel:GetOperation()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local oStruN77Lt 	:= oModel:GetModel( 'MdGrdN77Lt' )
	Local oStruN77Fa 	:= oModel:GetModel( 'MdGridN77Fa' )
	Local nI
	Local nX 			
	Local nDelLin		:= 0
	Local oGrid
	Local lRet			:= .T.
	Local nSeq
	Local nUltLinNotDel := 1
	Local cMensagem 	:= ""
	Local nLinAt        := oStruN77Fa:GetLine()
	
	If nOperation == 3
		If oModelN76:GetValue('N76_TPCON') == '4'
			oGrid  := oStruN77Lt
		ElseIf oModelN76:GetValue('N76_TPCON') == '5'
			oGrid  := oStruN77Fa
		EndIf
				
		If oModelN76:GetValue('N76_TPCON') == '4' .Or. oModelN76:GetValue('N76_TPCON') == '5'
		// Realiza reordenação devido a linhas deletadas
			For nI := 1 To oGrid:Length()
				If !Empty(oGrid:GetValue("N77_RESULT",1))
																								
					If oGrid:IsDeleted(nI)
						nDelLin++
					Else
						
						//Valida se existem valores com mascara estourada
						If oModelN76:GetValue('N76_TPCON') == '5' .And.;
						   (oModelN76:GetValue('N76_TMCON') < Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIINI'),_cPicture), ","), "."))) .Or.;
						   oModelN76:GetValue('N76_TMCON') < Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIFIM'),_cPicture), ","), "."))))
						   oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0036, STR0034, "", "")
						   //#"Existem itens com valores maiores ao Tamanho Total preenchido." 
						   //#"Favor preencher o campo Tamanho Total com um valor maior ou deletar os itens."
							lRet := .F.
						EndIf	
						 
						oGrid:GoLine(nI)
						nSeq := Val(oGrid:GetValue("N77_SEQ")) - nDelLin
						oGrid:LoadValue("N77_SEQ", PadL(AllTrim(Str(nSeq)), TamSx3('N77_SEQ')[1], "0"))
						
					EndIf
				Else //#"Cadastro incompleto para o tipo de resultado lista ou faixa.", "Favor preencher pelo menos um item da pasta relacionada ao tipo de resultado."
					oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0019, STR0020, "", "")
					lRet := .F.
				EndIf
			Next
			
			//Validacao dos valrores do grid. Necessario caso o usuario delete linhas, altere valores e retorne linhas
			If lRet
				For nX := 1 To  oStruN77Fa:Length()
					oStruN77Fa:Goline( nX )
					If !oStruN77Fa:IsDeleted() .AND. nLinAt <> nX
						
						//Inicial maior do que final
						If (!Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt)) .And. !Empty(oStruN77Fa:GetValue('N77_FAIFIM',nLinAt))) .And. ;
						   (oStruN77Fa:GetValue('N77_FAIINI',nLinAt) 		>=    oStruN77Fa:GetValue('N77_FAIFIM',nLinAt))	 
							cMensagem := STR0010 + cValToChar(nLinAt)
						Else
						
							//Verifica inicial digitada
							If (!Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt))) .And. ;
								(oStruN77Fa:GetValue('N77_FAIINI',nLinAt) >= oStruN77Fa:GetValue('N77_FAIINI',nX)) .And. ;
								(oStruN77Fa:GetValue('N77_FAIINI',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX))
								cMensagem := STR0010 + cValToChar(nLinAt)
								Exit
							EndIf
		
							//Verifica final digitada
							If !Empty(oStruN77Fa:GetValue('N77_FAIFIM',nLinAt)) .And. ;
								(((oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) >= oStruN77Fa:GetValue('N77_FAIINI',nX)) .And. ;
								  (oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX))) .Or.;
								 ((oStruN77Fa:GetValue('N77_FAIINI',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX)) .And.;
								  (oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) >= oStruN77Fa:GetValue('N77_FAIFIM',nX))))
								cMensagem := STR0010 + cValToChar(nLinAt)
								Exit
							EndIf
		
							//Se nao e a primeira linha e o valor inicial esta zerado
							If Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt))
								oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0039, STR0040, "", "")
								//#"Valor inicial inválido." "Favor preencher o valor inicial."
							EndIf
						EndIf
					nUltLinNotDel := nX
					EndIf
				Next nX
			EndIf

			If !Empty(cMensagem) //# Faixa de valores inválida na linha:, "Favor corrigir intervalo de valores."
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", cMensagem, STR0011, "", "") 
				lRet := .F.
			EndIf
			
			
			If lRet .And. oModelN76:GetValue('N76_TPCON') == '5'
				If oModelN76:GetValue('N76_TMCON') == 0
					oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0021, STR0022, "", "")   
					//#"O campo tamanho não foi preenchido.",//#"Favor inserir um tamanho para os valores."
					lRet := .F.																								
				EndIf
			EndIf
		EndIf
		
		If lRet .And. oModelN76:GetValue('N76_TPCON') == '2'
			If oModelN76:GetValue('N76_TMCON') == 0
				//"O campo tamanho não foi preenchido." "Favor inserir um tamanho máximo de texto."
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0021, STR0023, "", "")
			lRet := .F.
			EndIf
		EndIf
		
		If lRet .And. oModelN76:GetValue('N76_TPCON') == '1'
			If oModelN76:GetValue('N76_TMCON') == 0
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0021, STR0022, "", "")
				//"O campo tamanho não foi preenchido.""Favor inserir um tamanho para os valores." 
			lRet := .F.
			EndIf
		EndIf
	EndIf
			
	If nOperation == 5
		dbSelectArea('NPX')
		dbSetOrder(3)
		If dbSeek(FwXFilial('NPX')+oModelN76:GetValue('N76_CODIGO')+ oModelN76:GetValue('N76_TPCON') + "1")
			//#"Não é possível realizar a exclusão. O contaminante já foi utilizado em lançamento."
			//#"Você pode inativá-lo."
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0017, STR0018, "", "")
			lRet := .F.
		EndIf
	EndIf
		
Return lRet


/*{Protheus.doc} UBAA040GRV
Gravação dos dados do contaminante

@author 	francisco.nunes
@since 		25/06/2018
@version 	1.0
*/  
Function UBAA040GRV(oModel)
	Local nOperation := oModel:GetOperation()
	Local oModelN76  := oModel:GetModel('MdFieldN76')
	Local oModelN77L := oModel:GetModel('MdGrdN77Lt')
	Local oModelN77F := oModel:GetModel('MdGridN77Fa')
	Local oModelN77  := {} 
	Local nI		 := 0
	Local lDeleta	 := .F.
	Local lRet		 := .T.
	Local aAreaN76	 := ""
	Local aAreaN77	 := ""
	
	If oModelN76:GetValue('N76_TPCON') $ '4|5'
		If oModelN76:GetValue('N76_TPCON') == '4'
			oModelN77  := oModelN77L
		ElseIf oModelN76:GetValue('N76_TPCON') == '5'
			oModelN77  := oModelN77F
		EndIf
	EndIf
	
	If nOperation = MODEL_OPERATION_INSERT
		oModelN76:SetValue('N76_DATINC', dDatabase)
		oModelN76:SetValue('N76_HORINC', Time())
			
		If oModelN76:GetValue('N76_TPCON') $ '4|5'
			For nI := 1 To oModelN77:Length()			
				If !oModelN77:IsDeleted(nI)
					oModelN77:GoLine(nI)
					oModelN77:SetValue('N77_DATINC', dDatabase)
					oModelN77:SetValue('N77_HORINC', Time())
				EndIf											
			Next nI
		EndIf
	ElseIf nOperation = MODEL_OPERATION_UPDATE .OR. nOperation = MODEL_OPERATION_DELETE
		
		If nOperation = MODEL_OPERATION_UPDATE
			oModelN76:SetValue('N76_DATATU', dDatabase)
			oModelN76:SetValue('N76_HORATU', Time())
			
		ElseIf nOperation = MODEL_OPERATION_DELETE
			aAreaN76 := N76->(GetArea())
				
			DbSelectArea("N76")
			N76->(DbSetOrder(1)) // N76_FILIAL+N76_CODIGO
			If N76->(DbSeek(FWxFilial("N76")+oModelN76:GetValue("N76_CODIGO")))
				If RecLock("N76", .F.)
					N76->N76_DATATU := dDatabase
					N76->N76_HORATU := Time()
					N76->(MsUnlock())
				EndIf
			EndIf
			
			RestArea(aAreaN76)
		EndIf
		
		If oModelN76:GetValue('N76_TPCON') $ '4|5'
		
			aAreaN77 := N77->(GetArea())
			
			DbSelectArea("N77")
				
			For nI := 1 To oModelN77:Length()			
				oModelN77:GoLine(nI)
				
				lDeleta := .F.
				
				If nOperation = MODEL_OPERATION_UPDATE .AND. oModelN77:IsDeleted(nI)
					lDeleta := .T.
				ElseIf nOperation = MODEL_OPERATION_DELETE
					lDeleta := .T.
				EndIf
				
				If lDeleta			
					N77->(DbSetOrder(1)) // N77_FILIAL+N77_CODCTM+N77_SEQ
					If N77->(DbSeek(FWxFilial("N77")+oModelN76:GetValue("N76_CODIGO")+oModelN77:GetValue("N77_SEQ")))
						If RecLock("N77", .F.)
							N77->N77_DATATU := dDatabase
							N77->N77_HORATU := Time()
							N77->(MsUnlock())
						EndIf
					EndIf
				EndIf
			Next nI
			
			RestArea(aAreaN77)
		EndIf							
	EndIf
		
	FWFormCommit(oModel)

Return lRet

/*{Protheus.doc} InitUBA040
Controla a exibicao das abas. Executado ao iniciar tela.

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Function InitUBA040(oModel)
	Local nOperation 	:= oModel:GetOperation()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local ovieAtual 	:= FWViewActive()
	Local lRet			:= .T.

	//Validações do UBAA040API
	if !(IsInCallStack("AlteraContaminant") .And. IsInCallStack("DeleteContaminant")) .And. !(IsInCallStack("UBAA040_09") .Or. IsInCallStack("UBAA040_10"))
		_cPicture	:= ""
	    _nTamTemp	:= Nil
	    _nPrecTemp	:= Nil
		
		If nOperation != 3 .And. oModelN76:GetValue('N76_TPCON') == '4'
			ovieAtual:HideFolder("GRADES",STR0003,2)
		ElseIf nOperation != 3 .And. oModelN76:GetValue('N76_TPCON') == '5'
			ovieAtual:HideFolder("GRADES",STR0002,2)
		EndIf
	endIf
	
Return lRet

/*{Protheus.doc} UBAA40WH76
Valida a edicao dos campos do formulario. Executado pelos campos na N76 (WHEN)

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Function UBAA40WH76()
	Local lRet 		:= .F.
	Local oModel	:= FwModelActive()
	Local oModelN76 := oModel:GetModel( 'MdFieldN76' )

	If oModelN76:GetValue('N76_TPCON') == '1'

		If "N76_TMCON"  $ ReadVar() .Or. "N76_VLPRC"  $ ReadVar()
			Return .T.
		EndIf
			
	ElseIf oModelN76:GetValue('N76_TPCON') == '1' .And. ;
		!("N76_TMCON"  $ ReadVar())  .And.;
		!("N76_VLPRC"  $ ReadVar()) 
		Return .F.
	EndIf
	
	If oModelN76:GetValue('N76_TPCON') == '2' .And. ;
		("N76_TMCON" $ ReadVar())
		Return .T.
	ElseIf oModelN76:GetValue('N76_TPCON') == '2' .And. ;
		!("N76_TMCON"  $ ReadVar())
		Return .F.
	EndIf
	
	If oModelN76:GetValue('N76_TPCON') == '3' .And. ;
		("N76_TMCON" $ ReadVar()  .Or. ;
		 "N76_VLPRC" $ ReadVar())
		Return .F.
	EndIf
	
	If oModelN76:GetValue('N76_TPCON') == '5' .And. ;
		("N76_TMCON" $ ReadVar()  .Or. ;
		 "N76_VLPRC" $ ReadVar())
		Return .T.
	ElseIf oModelN76:GetValue('N76_TPCON') == '5' .And. ;	
		(!("N76_TMCON" $ ReadVar())  .And. ;
		!("N76_VLPRC" $ ReadVar()))
		Return .F.
	EndIf
	
Return lRet

/*{Protheus.doc} UBAA40WH77
Valida a edicao dos campos do browse. Executado pelos campos da N77 (WHEN)

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Function UBAA40WH77()
	Local lRet 		:= .F.
	Local oModel	:= FwModelActive()
	Local oModelN76 := oModel:GetModel( 'MdFieldN76' )
	Local ovieAtual := FWViewActive()
	Local nFolder 	:= 0
	
	if !IsInCallStack("INCLUDECONTAMINANT") .and. !(IsInCallStack("UBAA040_04") .Or. IsInCallStack("UBAA040_05"))
		if VALTYPE(ovieAtual) == 'O'
			aFolders := ovieAtual:GetFolderActive("GRADES", 2)
			If !Empty(aFolders) 
				nFolder := aFolders[1]
			EndIf
		endif
		If ("N77_FAIINI" $ ReadVar() .Or. "N77_FAIFIM" $ ReadVar()) .And.;
			oModelN76:GetValue('N76_TMCON') == 0
			Return .F.
		EndIf
		
		If nFolder == 2 .And. oModelN76:GetValue('N76_TPCON') == '5' .And. ;
			("N77_FAIINI" $ ReadVar() .Or. "N77_FAIFIM" $ ReadVar() .Or. "N77_RESULT" $ ReadVar())
			Return .T.
		EndIf
		
		If nFolder == 1 .And. oModelN76:GetValue('N76_TPCON') == '4' .And. "N77_RESULT" $ ReadVar() //Habilita cpo
			Return .T.
		ElseIf oModelN76:GetValue('N76_TPCON') == '4' .And. ("N77_FAIINI" $ ReadVar() .Or. "N77_FAIFIM" $ ReadVar()) //Inter. Process
			Return .F.
		EndIf
		
		If "N77_FAIINI" $ ReadVar() .Or. "N77_FAIFIM" $ ReadVar() .And.;
			oModelN76:GetValue('N76_TMCON') == 0
		
			Return .F.
		EndIf
	else
		//Sempre retorna TRUE para a API
		lRet := .T.
	endIf
	
Return lRet


/*{Protheus.doc} UBAA040RES
Ao clicar no combo de resultados, este metodo e executado.
Informa para o metodo ResetFld quais campos terao seus valores reiniciados

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Function UBAA040RES()
	Local lRet 			:= .T.
	Local oModel   		:= FWModelActive()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local aGet := {}
	Local ovieAtual := FWViewActive()
	
	if !IsInCallStack("INCLUDECONTAMINANT")
		Do Case
	
			Case oModelN76:GetValue('N76_TPCON') == '1'	
				aGet := {"MdGrdN77Fa","MdGrdN77Lt"}
				
			Case oModelN76:GetValue('N76_TPCON') == '2'
				aGet := {'N76_TMCON','N76_VLPRC',"MdGrdN77Fa","MdGrdN77Lt"}
		
			Case oModelN76:GetValue('N76_TPCON') == '3'
				aGet := {'N76_TMCON','N76_VLPRC',"MdGrdN77Fa","MdGrdN77Lt"}
				
			Case oModelN76:GetValue('N76_TPCON') == '4'
				aGet := {'N76_TMCON','N76_VLPRC',"MdGrdN77Fa"}
				if VALTYPE(ovieAtual) == 'O'
					ovieAtual:SelectFolder("GRADES",STR0002,2)
				endif
				
			Case oModelN76:GetValue('N76_TPCON') == '5'
				If oModelN76:GetValue('N76_TMCON') > 14
					aGet := {'N76_TMCON','N76_VLPRC',"MdGrdN77Lt"}
				Else
					 aGet := {'N76_VLPRC',"MdGrdN77Lt"}				 
				EndIf
				if VALTYPE(ovieAtual) == 'O'
					ovieAtual:SelectFolder("GRADES",STR0003,2)
					ovieAtual:Refresh()
				endif

			Otherwise
				Return .T.
	
		EndCase
			
		If !Empty(aGet)
			ResetFld(aGet)
		EndIf
	endIf
Return lRet
	
/*{Protheus.doc} UBAA040VLD
Valida os campos. SX3.

@author 	carlos.augusto
@since 		24/03/2017
@version 	1.0
*/ 	
Function UBAA040VLD()
	Local lRet  		:= .T.
	Local oModel   		:= FWModelActive()
	Local ovieAtual 	:= FWViewActive()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local oStruN77Fa 	:= oModel:GetModel( 'MdGridN77Fa' )
	Local nX
	Local cMensagem 	:= "" 
	Local lRefresh 		:= .F.
	Local nUltLinNotDel := 1
	Local aSaveLines	:= FWSaveRows()
	Local lTxt			:= .T.
	Local nLinAt        := oStruN77Fa:GetLine()

	//Validacao de faixa. Valor inicial e Final
	If ("N77_FAIINI" $ ReadVar() .Or. "N77_FAIFIM" $ ReadVar()) .And. oModelN76:GetValue('N76_TPCON') == '5'	
	
		For nX := 1 To  oStruN77Fa:Length()
			oStruN77Fa:Goline( nX )
			If !oStruN77Fa:IsDeleted() .AND. nLinAt <> nX
				
				//Inicial maior do que final
				If (!Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt)) .And. !Empty(oStruN77Fa:GetValue('N77_FAIFIM',nLinAt))) .And. ;
				   (oStruN77Fa:GetValue('N77_FAIINI',nLinAt) 		>=    oStruN77Fa:GetValue('N77_FAIFIM',nLinAt))	 
					cMensagem := STR0010 + cValToChar(nLinAt)
				Else
				
					//Verifica inicial digitada
					If (!Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt))) .And. ;
						(oStruN77Fa:GetValue('N77_FAIINI',nLinAt) >= oStruN77Fa:GetValue('N77_FAIINI',nX)) .And. ;
						(oStruN77Fa:GetValue('N77_FAIINI',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX))
						cMensagem := STR0010 + cValToChar(nLinAt)
						Exit
					EndIf

					//Verifica final digitada
					If !Empty(oStruN77Fa:GetValue('N77_FAIFIM',nLinAt)) .And. ;
						(((oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) >= oStruN77Fa:GetValue('N77_FAIINI',nX)) .And. ;
						  (oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX))) .Or.;
						 ((oStruN77Fa:GetValue('N77_FAIINI',nLinAt) <= oStruN77Fa:GetValue('N77_FAIFIM',nX)) .And.;
						  (oStruN77Fa:GetValue('N77_FAIFIM',nLinAt) >= oStruN77Fa:GetValue('N77_FAIFIM',nX))))
						cMensagem := STR0010 + cValToChar(nLinAt)
						Exit
					EndIf

					//Se nao e a primeira linha e o valor inicial esta zerado
					If Empty(oStruN77Fa:GetValue('N77_FAIINI',nLinAt))
						oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0039, STR0040, "", "")
						//#"Valor inicial inválido." "Favor preencher o valor inicial."
					EndIf
				EndIf
			nUltLinNotDel := nX
			EndIf
		Next nX
		FWRestRows(aSaveLines)
	EndIf
	
	
	If !Empty(cMensagem) //# Faixa de valores inválida na linha:, "Favor corrigir intervalo de valores."
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", cMensagem, STR0011, "", "") 
		Return .F.
	EndIf
	
	//Se digitou em tamanho, e texto e maior do que 254
	If ("N76_TMCON" $ ReadVar()  .And. (oModelN76:GetValue('N76_TPCON') == '2' .And. oModelN76:GetValue('N76_TMCON') > 254))
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0024, STR0025, "", "")
		Return .F.
	EndIf
	
	//Se digitou em precisao. Tipo e numero ou faixa e precisao maior do que 5
	If "N76_VLPRC" $ ReadVar()
		If (oModelN76:GetValue('N76_TPCON') == '1' .Or. oModelN76:GetValue('N76_TPCON') == '5') .And. oModelN76:GetValue('N76_VLPRC') > 5
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0024, STR0026, "", "") 
			Return .F.
		//Se precisao maior do que zero e tamanho zero
		ElseIf (oModelN76:GetValue('N76_TPCON') == '1' .Or. oModelN76:GetValue('N76_TPCON') == '5') .And.;
		 		(oModelN76:GetValue('N76_VLPRC') > 0 .And. oModelN76:GetValue('N76_TMCON') <= 0)
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0027, STR0028, "", "") 
			Return .F.
		EndIf
	EndIf
	
	//Se digiou em tamanho. E tipo e numero ou faixa e tamanho maior que 14
	If ("N76_TMCON" $ ReadVar()  .And. (oModelN76:GetValue('N76_TPCON') == '1' .Or. oModelN76:GetValue('N76_TPCON') == '5') .And. oModelN76:GetValue('N76_TMCON') > 14)
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "",STR0024, STR0031, "", "") 
		Return .F.
	EndIf
	
	//Se digitou em tamanho. E tipo e numero ou faixa. Se nao e o primeiro preenchimento e 
	//valor da precisao e maior ou igual ao tamanho digitado
	If ("N76_TMCON" $ ReadVar()  .And. (oModelN76:GetValue('N76_TPCON') == '1' .Or. oModelN76:GetValue('N76_TPCON') == '5') .And.;
	 	(!Empty(_nTamTemp)) .And. oModelN76:GetValue('N76_VLPRC') >= oModelN76:GetValue('N76_TMCON'))
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0038, STR0037, "", "") 
		Return .F.
	EndIf	
	
	//Se digitou em precisao. E tipo e numero ou faixa. E precisao maior ou igual ao tamanho
	If "N76_VLPRC" $ ReadVar() .And.  (oModelN76:GetValue('N76_TPCON') == '1' .Or. oModelN76:GetValue('N76_TPCON') == '5') .And.; 
		(oModelN76:GetValue('N76_VLPRC') >= oModelN76:GetValue('N76_TMCON'))
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0029, STR0030, "", "")
		Return .F.
	EndIf
	
	//Se digitou em tamanho e tamanho maior do que zero. Se o tamanho atual digitado e maior do que o tamanho de algum valor no grid
	If ("N76_TMCON" $ ReadVar() .And. oModelN76:GetValue('N76_TMCON') > 0) .And.;
	   (oModelN76:GetValue('N76_TMCON') - oModelN76:GetValue('N76_VLPRC')) < MaxTam()
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0036, STR0034, "", "")
		Return .F.
	EndIf
	
	//Se aumentou precisao, mas existem valores que ocupam a mascara inteira
	If "N76_VLPRC" $ ReadVar() .And. oModelN76:GetValue('N76_VLPRC') > 0 .And. ;
		!Empty(_nPrecTemp)  .And. (_nPrecTemp < oModelN76:GetValue('N76_VLPRC')) .And.;
		(oModelN76:GetValue('N76_TMCON')  - MaxTotal() == 0)
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0035, STR0034, "", "")
		Return .F.
		
	EndIf
	
	
	//Validacoes para atualizar mascara e atualizar o valor de tamanho total e precisao anterior. Atualiza grid com nova mascara
	If ("N76_TMCON" $ ReadVar() .Or. "N76_VLPRC" $ ReadVar()) .And. (oModelN76:GetValue('N76_TMCON') > 0) 
	
		aPicture := AGRGerPic(oModelN76:GetValue('N76_TMCON') , oModelN76:GetValue('N76_VLPRC'), lTxt)
		
		If !Empty(aPicture) .And. (aPicture[1]) 
			_cPicture :=	aPicture[2]
		EndIf
		
		If (!Empty(_nTamTemp) .And. (_nTamTemp != oModelN76:GetValue('N76_TMCON'))) .Or.;
			(!Empty(_nPrecTemp) .And. (_nPrecTemp != oModelN76:GetValue('N76_VLPRC')))
			lRefresh := .T.
		ElseIf "N76_TMCON" $ ReadVar()
			_nTamTemp  := oModelN76:GetValue('N76_TMCON')
		ElseIf "N76_VLPRC" $ ReadVar()
			_nPrecTemp := oModelN76:GetValue('N76_VLPRC')
			lRefresh := .T.
		EndIf
		
		if VALTYPE(ovieAtual) == 'O'
			IF lRefresh
				oStruN77Fa:Goline( 1 )
				ovieAtual:Refresh()
			EndIf
		EndIf
	EndIf
	

	
Return lRet


/*{Protheus.doc} ResetFld
Limpa campos do formulario quando é alterado o tipo de dado
Deleta ou recupera itens de lista ou faixa

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Static Function ResetFld(aGet)
	Local oModel   		:= FWModelActive()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local oStruN77Lt 	:= oModel:GetModel( 'MdGrdN77Lt' )
	Local oStruN77Fa 	:= oModel:GetModel( 'MdGridN77Fa' )
	Local nX
	Local nI
	Local aValTam		:= {}
	Local nRespRec		:= 0 //Recuperar linhas?  1 Sim, 2 Nao
	Local lPerg			:= .T. //Perguntar recuperar linhas?=
	
	
	For nX := 1 To Len(aGet)
	
		Do Case

		Case "N76_TMCON" $ aGet[nX] .And. oModelN76:GetValue('N76_TPCON') != "3"
			oModelN76:LoadValue("N76_TMCON", 0)
			
		Case "N76_TMCON" $ aGet[nX] .And. oModelN76:GetValue('N76_TPCON') == "3"
			oModelN76:LoadValue("N76_TMCON", 8)

		Case "N76_VLPRC" $ aGet[nX]
			oModelN76:LoadValue("N76_VLPRC", 0)
				
		Case "MdGrdN77Lt" $ aGet[nX]
			For nI := 1 To  oStruN77Lt:Length()
				If !Empty(oStruN77Lt:GetValue('N77_RESULT')) .And.;
					oModelN76:GetValue('N76_TPCON') != "4" 
					oStruN77Lt:Goline( nI )
					oStruN77Lt:DeleteLine()
				EndIf
			Next nI
			
		     //#"recuperar todas as linhas da faixa?"
			For nI := 1 To  oStruN77Fa:Length()
				oStruN77Fa:Goline( nI )
				
				If oStruN77Fa:IsDeleted() .And.; 
				   (!Empty(oStruN77Fa:GetValue('N77_RESULT')) 	.Or.;
				   !Empty(oStruN77Fa:GetValue('N77_FAIINI')) 	.Or.;
				   !Empty(oStruN77Fa:GetValue('N77_FAIFIM'))) 	.And.;
				   oModelN76:GetValue('N76_TPCON') == "5" 
				
					If lPerg
						nRespRec := IIF(ApMsgYesNo(STR0016),1,2) //#"Deseja recuperar todas as linhas da faixa?" 
						lPerg	 := .F.
					EndIf
				EndIf
				
				If nRespRec == 1
					oStruN77Fa:UnDeleteLine()
					//Recupera valor tamanho e precisao
					If nI == 1 .And. !Empty(oStruN77Fa:GetValue('N77_FAIINI')) .And. oModelN76:GetValue('N76_TMCON') == 0
						If !Empty(_cPicture) .And. AT(".", _cPicture) > 0
							aValTam := StrTokArr(_cPicture, "." )
						EndIf
						oModelN76:LoadValue("N76_TMCON", Len(  STRTRAN(   STRTRAN(_cPicture, ",") , "."))     -3)
						If Len(aValTam) > 1
							oModelN76:LoadValue("N76_VLPRC", Len(aValTam[2]))
						EndIf
					EndIf
				ElseIf nRespRec == 2
					Exit
				EndIf
				
			Next nI
		
		Case "MdGrdN77Fa" $ aGet[nX]
			For nI := 1 To  oStruN77Fa:Length()
				If (!Empty(oStruN77Fa:GetValue('N77_RESULT')) 	.Or.;
				    !Empty(oStruN77Fa:GetValue('N77_FAIINI')) 	.Or.;
			        !Empty(oStruN77Fa:GetValue('N77_FAIFIM'))) .And.;
			        oModelN76:GetValue('N76_TPCON') != "5"
					oStruN77Fa:Goline( nI )
					oStruN77Fa:DeleteLine()
				EndIf
			Next nI
			
			//Se for Faixa, recupera as LISTAS
			For nI := 1 To  oStruN77Lt:Length()
				If !Empty(oStruN77Lt:GetValue('N77_RESULT')) .And.;
					oModelN76:GetValue('N76_TPCON') == "4"
					oStruN77Lt:Goline( nI )

					If lPerg
						nRespRec := IIF(ApMsgYesNo(STR0015),1,2) //#"Deseja recuperar todas as linhas da lista?"
						lPerg	 := .F.
					EndIf
			
					If nRespRec == 1
						oStruN77Lt:UnDeleteLine()
						ElseIf nRespRec == 2
						Exit
					EndIf
				EndIf
			Next nI
		
		Otherwise
			Return

	EndCase
	Next nX
	
Return 

/*{Protheus.doc} UBAA040PIC
Altera picture valor inicial e final. Validacao incluida no picture variavel. SX3

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Function UBAA040PIC()
	Local oModel   		:= FWModelActive()
	Local oModelN76 	:= oModel:GetModel( 'MdFieldN76' )
	Local nTamTotal
	Local nTamPrec
	Local aPicture		:= {}
	Local lTxt			:= .T.
	
	nTamPrec 			:= oModelN76:GetValue('N76_VLPRC')
	nTamTotal			:= oModelN76:GetValue('N76_TMCON')
		
	If nTamTotal > 0 .And. (oModelN76:GetValue('N76_TPCON') == '5' .Or. oModelN76:GetValue('N76_TPCON') == '1')
		aPicture := AGRGerPic(nTamTotal, nTamPrec, lTxt)
	ElseIf oModelN76:GetValue('N76_TPCON') == '5'	
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0032, STR0033, "", "")
	EndIf
	
	If !Empty(aPicture) .And. aPicture[1]
		_cPicture := aPicture[2]
	EndIf

Return _cPicture

/*{Protheus.doc} MaxTam
Pesquisa maior valor inteiro.

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Static Function MaxTam()
	Local nI
	Local oModel   		:= FWModelActive()
	Local oStruN77Fa 	:= oModel:GetModel( 'MdGridN77Fa' )	
	Local nMaxTam		:= 0
	
	For nI := 1 To  oStruN77Fa:Length()
		If (!Empty(oStruN77Fa:GetValue('N77_FAIINI')) 	.Or.;
	        !Empty(oStruN77Fa:GetValue('N77_FAIFIM')))
	        If !oStruN77Fa:IsDeleted()
				oStruN77Fa:Goline( nI )
				If nMaxTam < Len(cValToChar(NOROUND(oStruN77Fa:GetValue('N77_FAIINI'), 0)))
				   nMaxTam := Len(cValToChar(NOROUND(oStruN77Fa:GetValue('N77_FAIINI'), 0)))
				 EndIf
				If nMaxTam < Len(cValToChar(NOROUND(oStruN77Fa:GetValue('N77_FAIFIM'), 0)))
				   nMaxTam := Len(cValToChar(NOROUND(oStruN77Fa:GetValue('N77_FAIFIM'), 0)))
				 EndIf			 
			EndIf
		EndIf
	Next nI
			
Return nMaxTam


/*{Protheus.doc} MaxTotal
Pesquisa maior valor total.

@author 	carlos.augusto
@since 		20/03/2017
@version 	1.0
*/ 
Static Function MaxTotal()
	Local nI
	Local oModel   		:= FWModelActive()
	Local oStruN77Fa 	:= oModel:GetModel( 'MdGridN77Fa' )	
	Local nMaxTam		:= 0
	
	For nI := 1 To  oStruN77Fa:Length()
		If (!Empty(oStruN77Fa:GetValue('N77_FAIINI')) 	.Or.;
	        !Empty(oStruN77Fa:GetValue('N77_FAIFIM')))
	        If !oStruN77Fa:IsDeleted()
				oStruN77Fa:Goline( nI )
				If nMaxTam < Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIINI'),_cPicture), ","), ".")))
					nMaxTam := Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIINI'),_cPicture), ","), ".")))
				 EndIf
				If nMaxTam < Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIFIM'),_cPicture), ","), ".")))
					nMaxTam := Len(AllTrim(STRTRAN(STRTRAN(Transform(oStruN77Fa:GetValue('N77_FAIFIM'),_cPicture), ","), ".")))
				 EndIf			 
			EndIf
		EndIf
	Next nI
			
Return nMaxTam

Function UBAA040NOD(oItemCont, nLine, cAction, cField, xValueNew, xValueOld)
	Local ovieAtual  := FWViewActive()
	Local oModel  	 := FWModelActive()
	Local oModelN76  := oModel:GetModel( 'MdFieldN76' )
	Local oStruN77Lt := oModel:GetModel( 'MdGrdN77Lt' )
	Local oStruN77Fa := oModel:GetModel( 'MdGridN77Fa' )
    Local nFolder 	 := 0
    Local lRet       := .T.

    if !IsInCallStack("INCLUDECONTAMINANT")
		if VALTYPE(ovieAtual) == 'O'
			aFolders := ovieAtual:GetFolderActive("GRADES", 2)
			If !Empty(aFolders) 
				nFolder := aFolders[1]
			EndIf
			
			If (cAction == "UNDELETE")  
				//Se for tipo 1=Numerico; 2=Texto; 3=Data
				If oModelN76:GetValue('N76_TPCON') == "1" .Or. oModelN76:GetValue('N76_TPCON') == "2" .Or. oModelN76:GetValue('N76_TPCON') == "3" 
				If (nFolder == 1 .And. oStruN77Lt:IsDeleted()) .Or. (nFolder == 2 .And. oStruN77Fa:IsDeleted())
						lRet := .F.
						oItemCont:GetModel():SetErrorMessage(oItemCont:GetId(), , oItemCont:GetId(), "", "", STR0041 /* "Para o tipo de resultado selecionado não pode ativar linhas deletadas." */, "", "", "")
				EndIf   
							
				//Se for tipo 4=Lista e folder faixa
				ElseIf oModelN76:GetValue('N76_TPCON') == "4" .And. nFolder == 2
					If oStruN77Fa:IsDeleted()
							lRet := .F.
							oItemCont:GetModel():SetErrorMessage(oItemCont:GetId(), , oItemCont:GetId(), "", "", STR0041 /* "Para o tipo de resultado selecionado não pode ativar linhas deletadas." */, "", "", "")
						EndIf   
			
				
				//Se for tipo 5=Faixa e folder lista
				ElseIf oModelN76:GetValue('N76_TPCON') == "5" .And. nFolder == 1
					If oStruN77Lt:IsDeleted()
							lRet := .F.
							oItemCont:GetModel():SetErrorMessage(oItemCont:GetId(), , oItemCont:GetId(), "", "", STR0041  /* "Para o tipo de resultado selecionado não pode ativar linhas deletadas." */, "", "", "")
						EndIf   
				EndIf	
			EndIf
		endif
	endIf
	
Return lRet

