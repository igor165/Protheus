#INCLUDE "AGRA510.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __maxIdN95 := STRZERO(0,TamSX3("N95_CODIGO")[1]) //Controle de id da N95
Static __lCopia	  := .F.

Function AGRA510()
    Local oBrowse
    
	If .Not. TableInDic('N92')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('N92')
	oBrowse:SetMenuDef('AGRA510')
    oBrowse:SetDescription(STR0001) //#Cadastro de Tipo de Operação de Romaneio
	oBrowse:Activate()
	
Return( Nil )


/*/{Protheus.doc} ModelDef
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruN92 	:= FwFormStruct( 1, "N92" )
	Local oStruNCB 	:= FwFormStruct( 1, "NCB" )
	Local oStruN93 	:= FwFormStruct( 1, "N93" )
	Local oStruN94 	:= FwFormStruct( 1, "N94" )
	Local oStruN95 	:= FwFormStruct( 1, "N95" )
	Local bLinePre := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRX510PRE( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }
	oModel := MPFormModel():New('AGRA510',/*bPre*/ ,/*{|oModel| PosValid(oModel)}bPos*/, {|oModel| GrvModelo(oModel)})

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN92', /*cOwner*/, oStruN92 )
	
	//-------------------------------------
	// Adiciona a estrutura da Grid NCB
	//-------------------------------------
	oModel:AddGrid( 'MdGridNCB', 'MdFieldN92', oStruNCB,/*bLinePre*/, /*bLinePost*/)
	oModel:SetRelation( 'MdGridNCB', { { 'NCB_FILIAL', 'FWxFilial( "NCB" )' }, { 'NCB_CODTO', 'N92_CODIGO' }},  NCB->( IndexKey( 1 )))
	oModel:GetModel('MdGridNCB'):SetUniqueLine({"NCB_FILIAL","NCB_CODPRO"})
	oModel:GetModel( "MdGridNCB"):SetOptional(.T.)
	
	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGridN93', 'MdFieldN92', oStruN93,/*bLinePre*/, /*bLinePost*/)
	oModel:SetRelation( 'MdGridN93', { { 'N93_FILIAL', 'fwxFilial( "N93" )' }, { 'N93_CODTO', 'N92_CODIGO' }},  N93->( IndexKey( 1 )))
	oModel:GetModel('MdGridN93'):SetUniqueLine({"N93_FILIAL","N93_CODIGO"}) 
	oModel:SetPrimaryKey({})
	
	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN94', 'MdGridN93', oStruN94,/*bLinePre*/, /*bLinePost*/)
	oModel:SetRelation( 'MdFieldN94', { { 'N94_FILIAL', 'fwxFilial( "N94" )' }, { 'N94_CODTO', 'N92_CODIGO' } , { 'N94_CODETP', 'N93_CODIGO' } }, N94->( IndexKey( 1 )))
	oModel:SetPrimaryKey({})
	oModel:GetModel( "MdFieldN94"):SetOptional( .F. )

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGridN95', 'MdGridN93', oStruN95, bLinePre/*bLinePre*/, /*bLinePost*/)
	oModel:SetRelation( 'MdGridN95', { { 'N95_FILIAL', 'fwxFilial( "N95" )' }, { 'N95_CODTO', 'N92_CODIGO' } , { 'N95_CODETP', 'N93_CODIGO' } }, N95->( IndexKey( 2 )))
	oModel:GetModel('MdGridN95'):SetUniqueLine({"N95_FILIAL","N95_CODIGO"}) 
	oModel:SetPrimaryKey({})
	//oModel:SetPrimaryKey({"N95_FILIAL","N95_CODIGO"})
 
	
	// Adição dos botões de Baixo e Cima para ordenação
  	oStruN95:AddField('BTN BAIXO', "UP3", 'N95_MOVUP' 	, 'BT' , 1 , 0, {|| AGRA510MOV(1)} , NIL , NIL, NIL, {||"UP3"}, NIL, .F., .T.)
  	oStruN95:AddField('BTN CIMA', "DOWN3",'N95_MOVDW' 	, 'BT' , 1 , 0, {|| AGRA510MOV(2)} , NIL , NIL, NIL, {||"DOWN3"}, NIL, .F., .T.)
	
Return oModel



/*/{Protheus.doc} ViewDef
@author carlos.augusto
@since 24/04/2018
@version undefined
@type function
/*/
Static Function ViewDef()
    Local oModel 	:= FWLoadModel('AGRA510')
    Local oStruN92	:= FWFormStruct(2,'N92')
    Local oStruNCB	:= FWFormStruct(2,'NCB')
    Local oStruN93	:= FWFormStruct(2,'N93')
    Local oStruN94	:= FWFormStruct(2,'N94')
    Local oStruN95	:= FWFormStruct(2,'N95')
	Local oView		:= Nil

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

	//-----------------------
	// Remove campos da view
	//-----------------------
	oStruNCB:RemoveField("NCB_CODTO")
	oStruN93:RemoveField("N93_CODETP")
	oStruN94:RemoveField("N94_CODIGO")
	oStruN94:RemoveField("N94_CODTO")
	oStruN94:RemoveField("N94_CODETP")
	oStruN95:RemoveField("N95_CODTO")
	oStruN95:RemoveField("N95_CAMPO")
    oStruN95:RemoveField("N95_CODIGO")
   
	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_N92',  oStruN92,  'MdFieldN92' )
	
	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_NCB', oStruNCB, 'MdGridNCB' )
	
	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N93', oStruN93, 'MdGridN93' )
	
	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_N94',  oStruN94,  'MdFieldN94' )

	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N95', oStruN95, 'MdGridN95' )

	//---------------------------------------------
	//Tamanho de cada view
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'VIEW_HOR', 100 )
	oView:CreateVerticalBox( 'VIEW_VERT', 100, 'VIEW_HOR' )
	
	//Cabeçalho
	oView:CreateHorizontalBox( 'N92_VIEW', 25, 'VIEW_VERT' )
	
	//---------------------------------------------	
	//Grid de Produtos
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'NCB_VIEW' , 15, 'VIEW_VERT'  )
	oView:CreateFolder('FLD_NCB','NCB_VIEW')
	oView:AddSheet('FLD_NCB','PASTA_NCB', STR0021 ) //Produtos 
	oView:CreateHorizontalBox( 'NCB_PN', 100, , , 'FLD_NCB', 'PASTA_NCB')

	//---------------------------------------------	
	//Grid de Etapas
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'N93_VIEW' , 25, 'VIEW_VERT'  )
	oView:CreateFolder('FLD_N93','N93_VIEW')
	oView:AddSheet('FLD_N93','PASTA_N93', STR0007 ) //Campos dos Dados da Etapa 
	oView:CreateHorizontalBox( 'N93_PN', 100, , , 'FLD_N93', 'PASTA_N93')

	//---------------------------------------------
	//Folder de campos
	//---------------------------------------------				
	oView:CreateHorizontalBox( 'N94_VIEW' , 20, 'VIEW_VERT'  )
	
	//---------------------------------------------	
	//Grid de Campos
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'N95_VIEW' , 15, 'VIEW_VERT'  )
	oView:CreateFolder('FLD_N95','N95_VIEW')
	oView:AddSheet('FLD_N95','PASTA_N95', STR0009 ) //Campos dos Dados da Etapa 
	oView:CreateHorizontalBox( 'N95_PN', 100, , , 'FLD_N95', 'PASTA_N95')
	
	// Adiciona na View os botões de Baixo e Cima para reordenação
	oStruN95:AddField( "N95_MOVUP"  ,'02' , "- ", "UP3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )
	oStruN95:AddField( "N95_MOVDW"  ,'03' , "+ ", "DOWN3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	oView:SetOwnerView( 'VIEW_N92', 'N92_VIEW' )
	oView:SetOwnerView( 'VIEW_NCB', 'NCB_PN' )
	oView:SetOwnerView( 'VIEW_N93', 'N93_PN' )
	oView:SetOwnerView( 'VIEW_N94', 'N94_VIEW' )
	oView:SetOwnerView( 'VIEW_N95', 'N95_PN' )

	oView:SetContinuousForm(.T.)
	
	// Seta o Campo incremental da Grid
	oView:AddIncrementField( 'VIEW_N93', 'N93_ORDEM' )
	oView:AddIncrementField( 'VIEW_N93', 'N93_CODIGO' )
	oView:AddIncrementField( 'VIEW_N95', 'N95_ORDEM' )
    
    oView:EnableControlBar(.T.)
    
    oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| VldFolder(cFolderID, nOldSheet, nSelSheet)})
    
Return oView


/*/{Protheus.doc} MenuDef
@author carlos.augusto
@since 20/04/2018
@version undefined
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.AGRA510' OPERATION 2  ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.AGRA510' OPERATION 3  ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.AGRA510' OPERATION 4  ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.AGRA510' OPERATION 5  ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.AGRA510' OPERATION 8  ACCESS 0    // 'Imprimir'
	ADD OPTION aRotina TITLE STR0011 ACTION 'A500Copy' 		  OPERATION 9  ACCESS 0    // 'Copiar'                                           
	ADD OPTION aRotina TITLE STR0024 ACTION 'AGRX510B' 		  OPERATION 10 ACCESS 0    // 'DE/PARA'

Return aRotina


/*/{Protheus.doc} GrvModelo
@author carlos.augusto
@since 20/04/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)
	Local lRet	  		:= .T.
	Local oModelN95		:= oModel:GetModel("MdGridN95")
	Local oModelN92		:= oModel:GetModel("MdFieldN92")
	Local oModelN93		:= oModel:GetModel("MdGridN93")
	Local nOperation	:= oModel:GetOperation()
	Local cTipoPrinc	:= oModelN92:GetValue("N92_TIPO")
	Local nI
	Local nOrdem
	Local nDelLin			:= 0
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
		If oModelN92:GetValue("N92_MOVORI") .And. cTipoPrinc != "A" 
			//#'Para marcar a opção Mov.Origem é necessário informar o Tipo de Controle como "A" = Entrada por Transferência"'
			oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0018, STR0016, "", "")
			lRet := .F.
		EndIf
	
		If lRet
		//Renovar ID N95
			For nI := 1 To oModelN95:Length()
			
				If oModelN95:IsDeleted(nI)
					nDelLin++
				Else
					oModelN95:GoLine(nI)
					nOrdem := oModelN95:GetValue("N95_ORDEM") - nDelLin
					oModelN95:LoadValue("N95_ORDEM", nOrdem)
					
					__maxIdN95 := soma1(__maxIdN95)
					If Empty(oModelN95:GetValue("N95_CODIGO"))
						oModelN95:LoadValue("N95_CODIGO", __maxIdN95)
					EndIf
				EndIf
			Next nI
		EndIf
		
		if lRet
			//Verifica se existe etapa com ponto de controle sem pergunta vinculada.
			For nI := 1 To oModelN93:Length()
				If oModelN93:IsDeleted(nI)
					loop
				Else
					oModelN93:GoLine(nI)
					if EMPTY(oModelN93:GetValue("N93_CDPTCT"))
						loop
					else
						if EMPTY(oModelN93:GetValue("N93_CDPERG"))
							lRet := .F.
							oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0022, STR0023, "", "")
						endIf
					endIf
				EndIf
			
			Next nI
		endIf
	EndIf
	
	If lRet 
		lRet := FWFormCommit(oModel)
	EndIf
	
Return lRet


/*/{Protheus.doc} AGRA510MOV
//Logica importada da funcao UBAA020MOV
@author carlos.augusto/roney.maia
@since 18/04/2018
@version undefined
@param nTipo, numeric, descricao
@type function
/*/
Static Function AGRA510MOV(nTipo)
	Local oView     	 := FWViewActive() // View que se encontra Ativa
	Local oModel    	 := FWModelActive() // Model que se encontra Ativo
	Local oModelN95	 := oModel:GetModel('MdGridN95') // Submodelo da Grid
	Local nLinhaOld 	 := oView:GetLine('MdGridN95') // Linha atualmente posicionada
	Local cLinAtu	  	 := oModelN95:GetValue("N95_ORDEM", nLinhaOld) // Pega o valor da Ordem na linha atual

	If nTipo == 1 // Para cima

		If nLinhaOld != 1

			oModelN95:LoadValue("N95_ORDEM", oModelN95:GetValue("N95_ORDEM", nLinhaOld - 1)) // Seta o valor da linha de cima para atual
			oModelN95:GoLine(nLinhaOld - 1) // Move o posicionamento para a linha de cima
			oModelN95:LoadValue("N95_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oView:LineShift('MdGridN95',nLinhaOld ,nLinhaOld - 1) // Realiza a troca de linhas
			oModelN95:GoLine(nLinhaOld - 1)

		EndIf

	Else // Para baixo

		If nLinhaOld < oView:Length('MdGridN95')

			oModelN95:LoadValue("N95_ORDEM", oModelN95:GetValue("N95_ORDEM", nLinhaOld + 1)) // Seta o valor da linha de baixo para atual
			oModelN95:GoLine(nLinhaOld + 1) // Move o posicionamento para a linha de baixo
			oModelN95:LoadValue("N95_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oModelN95:GoLine(nLinhaOld)
			oView:LineShift('MdGridN95',nLinhaOld,nLinhaOld + 1) // Realiza a troca de linhas
			oModelN95:GoLine(nLinhaOld)

		EndIf
	EndIf

	oView:Refresh('MdGridN95') // Atualiza a SubView da Grid

	If nTipo == 1
		oModelN95:GoLine(nLinhaOld - 1)
	Else
		oModelN95:GoLine(nLinhaOld + 1)
	Endif

Return .T.


/*/{Protheus.doc} AGRA510ADD
//Acionada no Valid no campo da N94
@author marina.muller/carlos.augusto
@since 23/01/2018
@version 1.0
@param cCampoN94, characters, descricao
@type function
/*/
Function AGRA510ADD(cCampoN94)
	Local oModel   	  := FWModelActive()
	Local nOperac     := oModel:GetOperation()
	Local lRet	      := .T.
	Local oStrNJJ 	  := FwFormStruct( 1, "NJJ" )	
	Local aCposNJJ	  := oStrNJJ:GetFields()
	Local nY
	Local nX
	Local nZ
	Local oModelN94   := oModel:GetModel('MdFieldN94')
	Local oModelN95   := oModel:GetModel('MdGridN95')
	Local aCposMdN95  := {}
	Local nTamGrid
	Local aDadBas    := {"NJJ_CODROM","NJJ_CODSAF","NJJ_CODPRO","NJJ_DESPRO","NJJ_UM1PRO","NJJ_LOCAL","NJJ_CODENT","NJJ_LOJENT","NJJ_NOMENT","NJJ_DATA","NJJ_CODUNB","NJJ_TOETAP","NJJ_QTDFAR"}
	Local aQtdCPes   := {"NJJ_PSSUBT","NJJ_PSLIQU","NJJ_PSDESC","NJJ_PSBASE","NJJ_PSEXTR","NJJ_PESEMB","NJJ_PESO3","NJJ_DIFFIS","NJJ_PESO1","NJJ_DATPS1","NJJ_HORPS1","NJJ_MODPS1","NJJ_PESO2","NJJ_DATPS2","NJJ_HORPS2","NJJ_MODPS2","NJJ_STSPES"}
	Local aAnaQua	 := {"NJJ_TABELA","NJJ_STSCLA","NJJ_LIBQLD","NJJ_QPAREC","NJJ_QUSUAR"}
	Local aTransp	 := {"NJJ_CODTRA","NJJ_NOMTRA","NJJ_PLACA" ,"NJJ_CGC" ,"NJJ_CODMOT","NJJ_NOMMOT","NJJ_TPFRET","NJJ_ENTENT","NJJ_ENTLOJ"}
	Local aQtSPes	 := {"NJJ_PSSUBT","NJJ_PSLIQU","NJJ_PSDESC","NJJ_PSBASE","NJJ_PSEXTR","NJJ_PESEMB","NJJ_PESO3"}
	Local aAgend     := {"NJJ_DTAGEN","NJJ_HRAGEN","NJJ_NRAGEN"}
	Local aLavoura   := {"NJJ_FAZ","NJJ_NMFAZ","NJJ_TALHAO","NJJ_DESTAL","NJJ_CODVAR","NJJ_DESVAR","NJJ_ORDCLT"}
	Local aDadFis    := {"NJJ_TPFORM","NJJ_DOCEMI","NJJ_DOCNUM","NJJ_DOCSER","NJJ_DOCESP","NJJ_EST","NJJ_CHVNFE","NJJ_QTDFIS","NJJ_VLRUNI","NJJ_VLRTOT","NJJ_FRETE","NJJ_SEGURO","NJJ_DESPES","NJJ_NFPNUM","NJJ_NFPSER","NJJ_MSGNFS","NJJ_TES","NJJ_STAFIS"}

	If nOperac == MODEL_OPERATION_INSERT .Or. nOperac == MODEL_OPERATION_UPDATE

		Do Case
			
			Case cCampoN94 == "N94_DADBAS"  //Dados Básicos
				aCposMdN95 := aDadBas 
			
			Case cCampoN94 == "N94_QTCPES" //Quantidade com Pesagem
				aCposMdN95 := aQtdCPes        

			Case cCampoN94 == "N94_ANAQUA" //Analise Qualidade
				aCposMdN95 := aAnaQua	             

			Case cCampoN94 == "N94_DADTRA" //Transporte
				aCposMdN95 := aTransp
			
			Case cCampoN94 == "N94_QTSPES" //Quantidade Sem Pesagem
				aCposMdN95 := aQtSPes 	   
	
			Case cCampoN94 == "N94_DADAGD" //Agendamento
				aCposMdN95 := aAgend 	

			Case cCampoN94 == "N94_DADLAV" //Lavoura
				aCposMdN95 := aLavoura   
			
			Case cCampoN94 == "N94_DADFIS" //Fiscal
				aCposMdN95 := aDadFis	
			
			OtherWise
		EndCase 
		
		//Quando um campo for marcado
		If oModelN94:GetValue(cCampoN94)

			//Se o campo ja esta no grid, recuperar a linha deletada.
			//Quando encontra, remove no array aCposMdN95
			For nY := 1 to len(aCposMdN95)
				For nX := 1 to oModelN95:Length()
					oModelN95:GoLine(nX)
					If __maxIdN95 < oModelN95:GetValue("N95_CODIGO")
						__maxIdN95 := oModelN95:GetValue("N95_CODIGO")
					EndIf
					If .Not. Empty(aCposMdN95[nY]) .And. (AllTrim(oModelN95:GetValue("N95_CAMPO")) = AllTrim(aCposMdN95[nY]))
						If oModelN95:IsDeleted()
							oModelN95:UnDeleteLine()
						EndIf
						ADel(aCposMdN95, nY)
						nY -= 1
						exit
					EndIf
				Next nX
				If Empty(aCposMdN95)
					exit
				EndIf
			Next nY

			//Tamanho total do GRID em tela
			nTamGrid := oModelN95:Length()

			//For no array aCposMdN95 que tem apenas os campos que serao adicionados
			For nY := 1 to len(aCposMdN95)
				If .Not. Empty(aCposMdN95[nY]) .And. .Not. Empty(oModelN95:GetValue("N95_TITULO"))
					oModelN95:AddLine()
					nTamGrid += 1
				EndIf
				oModelN95:GoLine(nTamGrid) //Ir para a linha que tenho em tela, nao para o array de campos
				If Empty(oModelN95:GetValue("N95_TITULO"))
					oModelN95:LoadValue("N95_CAMPO" , aCposMdN95[nY]) //Campo possui o valid AGRA510TIT(Nao disparar)
					
					For nZ := 1 to len(aCposNJJ)
						If AllTrim(aCposNJJ[nZ][3]) = AllTrim(aCposMdN95[nY])
							oModelN95:LoadValue("N95_TITULO", aCposNJJ[nZ][1])					
							oModelN95:LoadValue("N95_DESCPO", aCposNJJ[nZ][2])
							oModelN95:LoadValue("N95_OBRIGA", "2")	
						EndIf
					Next nZ
					
					__maxIdN95 := soma1(__maxIdN95)
					oModelN95:LoadValue("N95_CODIGO", __maxIdN95)
					
				EndIf
			Next nY
			
		//Quando um campo for desmarcado deletar
		Else
			For nY := 1 to len(aCposMdN95)
				If .Not. Empty(aCposMdN95[nY])
					For nX := 1 to oModelN95:Length()
						oModelN95:GoLine(nX)
						If __maxIdN95 < oModelN95:GetValue("N95_CODIGO")
							__maxIdN95 := oModelN95:GetValue("N95_CODIGO")
						EndIf
						If oModelN95:GetValue("N95_TITULO") = AGRTITULO2(aCposMdN95[nY],"NJJ")
							If .Not. oModelN95:IsDeleted()
								oModelN95:DeleteLine()
							EndIf
						EndIf
					Next nX
				EndIf
			Next nY
		EndIf
	EndIf     		      
	oModelN95:GoLine(1)	
Return lRet


/*/{Protheus.doc} AGRA510TIT
//Valid N95_TITULO
@author carlos.augusto
@since 20/04/2018
@version undefined
@type function
/*/
Function AGRA510TIT()
	Local oModel   	  := FWModelActive()
	Local oModelN95   := oModel:GetModel('MdGridN95')
	Local nLinha	  := oModelN95:GetLine()
	Local cCampo	  := oModelN95:GetValue("N95_CAMPO")
	Local aSaveLines  := FWSaveRows()
	Local lRet	      := .T.
	Local nX
	
	FwClearHLP()
	
	If .Not. Empty(oModelN95:GetValue("N95_TITULO"))
		For nX := 1 to oModelN95:Length()
			oModelN95:GoLine(nX)
			If (nLinha != nX) .And. AllTrim(oModelN95:GetValue("N95_CAMPO")) = AllTrim(cCampo) .And. .Not. oModelN95:IsDeleted()
				Help('', 1, STR0012, , STR0013 + cValToChar(nX), 1 ) //Atencao-"Campo encontrado na linha: "
				lRet := .F.
				exit
			EndIf
		Next nX
	EndIf
	
	FwRestRows(aSaveLines)
	oModelN95:GoLine(nLinha)
Return lRet

/*/{Protheus.doc} AGRA510N94
//Ao alterar o numero da ordem, gera o código para N94
@author carlos.augusto
@since 12/12/2017
@version undefined
@type function
/*/
Function AGRA510N94()
	Local oModel 	:= FWModelActive()
	Local oN94		:= oModel:GetModel( "MdFieldN94" )
	Local cN94Cod

	If ALTERA .And. Empty(oN94:getValue("N94_CODIGO"))
		cN94Cod := GetSXENum('N94','N94_CODIGO')
		oN94:LoadValue("N94_CODIGO", cN94Cod)
	ElseIf INCLUI .And. Empty(oN94:getValue("N94_CODIGO"))
		cN94Cod := GetSXENum('N94','N94_CODIGO')
		oN94:LoadValue("N94_CODIGO", cN94Cod)
	EndIf

Return .T.


/*/{Protheus.doc} VldFolder
//Exibe alerta para o usuario
@author carlos.augusto
@since 24/04/2018
@version undefined
@param cFolderID, characters, descricao
@param nOldSheet, numeric, descricao
@param nSelSheet, numeric, descricao
@type function
/*/
Static Function VldFolder(cFolderID, nOldSheet, nSelSheet)
	Local lRet 			:= .T.
	Local oModel		:= FwViewActive()
	Local oModelN92		:= oModel:GetModel("MdFieldN92")
	Local nOperation	:= oModel:GetOperation()
	Local cTipoPrinc	:= oModelN92:GetValue("N92_TIPO")
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		If nSelSheet = 3
			lRet := cTipoPrinc == "A" .Or. cTipoPrinc == "B"
		EndIf
		If .Not. lRet
			//#''Para preencher os dados da aba Transf., o Tipo de Controle deve ser A = Entrada por Transferência ou B = Saída por Transferência. ' 
			MsgAlert(STR0014)
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} A500Copy
//Função para copia do modelo de dados
@author ana.olegini
@since 	07/06/2018
@version 12.1.21

@return oModel, Modelo de dados
/*/
Function A500Copy()
	Local aArea        := GetArea()
	Local cTitulo      := STR0011 //"Copiar"
	Local cPrograma    := "AGRA510"
	Local nOperation   := MODEL_OPERATION_INSERT
	
	//--Varivavel de copia
	__lCopia := .T.
	
	//--Realiza a carga do modelo de dados
	oModel := FWLoadModel(cPrograma)
	oModel:SetOperation(nOperation) 	//--Inclusão
	oModel:Activate(.T.) 				//--Ativa o modelo com os dados posicionados
	
	//--Busca proxima numeracao a ser utilizada
	cCodCd := GetSXENum("N92", "N92_CODIGO")
	oModel:SetValue("MdFieldN92", "N92_CODIGO",  cCodCd)

	//--Executando a visualização dos dados para manipulação
	nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	__lCopia := .F.
	oModel:DeActivate()
	
	//Se a cópia for confirmada
	If nRet == 0
		//--Salva numeração
		ConfirmSX8()
	Else
		//--Retorna numeração
		RollBackSx8()	
	EndIf
	
	RestArea(aArea)
Return oModel