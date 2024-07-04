#INCLUDE "AGRA520.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGRA520
//Rotina de Gestão de Pendências Físicas/Fiscais
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA520()
	Local oBrowse
	Local bKeyF12 := { || Pergunte('AGRA520001', .T.) }

	If .Not. TableInDic('N9B')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('N9B')
	oBrowse:SetMenuDef('AGRA520')
	oBrowse:SetDescription(STR0001) //#Gestor de Pendências

	//---------------
	//Seta tecla F12
	//---------------
	SetKey( VK_F12, bKeyF12 )

	oBrowse:AddLegend({||  GridLegend(N9B->N9B_FILIAL, N9B->N9B_CODSAF, N9B->N9B_CODENT, N9B->N9B_LOJENT, N9B->N9B_CODPRO)}, "BLUE", STR0008) //Sem Pendências
	oBrowse:AddLegend({|| !GridLegend(N9B->N9B_FILIAL, N9B->N9B_CODSAF, N9B->N9B_CODENT, N9B->N9B_LOJENT, N9B->N9B_CODPRO)}, "RED",  STR0009) //Com Pendências

	oBrowse:Activate()

	//-------------------------------
	//Retira ação da tecla F12
	//-------------------------------
	SetKey(VK_F12,Nil)

Return( Nil )


/*/{Protheus.doc} ModelDef
//Camada de Modelo da Rotina
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oModel   	 := Nil
	Local oStruN9B 	 := FwFormStruct( 1, "N9B" )
	Local oStruN9C 	 := FwFormStruct( 1, "N9C" )
	Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRA520LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}	

	oModel := MPFormModel():New('AGRA520',/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)

	//-----------------------------------------------
	// Adiciona estrutura da GRID o campo de legenda
	//-----------------------------------------------
	oStruN9C:AddField(STR0010 /*Status*/, STR0010 /*Status*/, 'N9C_STSLEG', 'BT' , 1 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.) 

	//------------------------------------------------
	// Inicializa legenda no GRID de pendências
	//------------------------------------------------
	oStruN9C:SetProperty( 'N9C_STSLEG' , MODEL_FIELD_INIT , {|| AGRA520INL()})

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN9B', /*cOwner*/, oStruN9B )

	//------------------------------------------------
	// Desabilita modo edição dos campos
	//------------------------------------------------
	oStruN9B:SetProperty('N9B_CODSAF', MODEL_FIELD_WHEN,{|| .F. })
	oStruN9B:SetProperty('N9B_CODPRO', MODEL_FIELD_WHEN,{|| .F. })

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGridN9C', 'MdFieldN9B', oStruN9C, bLinePre/*bLinePre*/, /*bLinePost*/)

	//------------------------------------------------
	// Bloqueia inclusão/exclusão linhas GRID
	//------------------------------------------------
	oModel:GetModel('MdGridN9C'):SetNoInsertLine(.T.)
	oModel:GetModel('MdGridN9C'):SetNoDeleteLine(.T.)

	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGridN9C', { { 'N9C_FILIAL', 'fwxFilial( "N9C" )' }, { 'N9C_CODSAF', 'N9B_CODSAF' }, { 'N9C_CODENT', 'N9B_CODENT' }, { 'N9C_LOJENT', 'N9B_LOJENT' }, { 'N9C_CODPRO', 'N9B_CODPRO' }},  N9C->( IndexKey( 1 )))
	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate()

Return oModel


/*/{Protheus.doc} ViewDef
//Camada de View da Rotina
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oModel 	:= FWLoadModel('AGRA520')
	Local oStruN9B	:= FWFormStruct(2,'N9B')
	Local oStruN9C	:= FWFormStruct(2,'N9C')
	Local oView		:= Nil

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
	oStruN9B:RemoveField("N9B_CODENT")
	oStruN9B:RemoveField("N9B_LOJENT")

	oStruN9C:RemoveField("N9C_FILIAL")
	oStruN9C:RemoveField("N9C_CODSAF")
	oStruN9C:RemoveField("N9C_CODENT")
	oStruN9C:RemoveField("N9C_LOJENT")
	oStruN9C:RemoveField("N9C_STATUS")
	oStruN9C:RemoveField("N9C_FILORI")
	oStruN9C:RemoveField("N9C_CODPRO")
	oStruN9C:RemoveField("N9C_PESLIQ")
	oStruN9C:RemoveField("N9C_FILROM")
	oStruN9C:RemoveField("N9C_ROMORI")

	//-----------------------
	// Adiciona na View o botão de Legenda
	//-----------------------
	oStruN9C:AddField( "N9C_STSLEG" ,'01' , STR0010, STR0010 , {} , 'BT' ,'@BMP',NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. ) //Status

	//-----------------------
	// Mostra os campos da tela em uma determinada ordem
	//-----------------------
	oStruN9B:SetProperty("N9B_CODSAF",MVC_VIEW_ORDEM,'01')
	oStruN9B:SetProperty("N9B_CODPRO",MVC_VIEW_ORDEM,'02')
	oStruN9B:SetProperty("N9B_FISICO",MVC_VIEW_ORDEM,'03')
	oStruN9B:SetProperty("N9B_FISCAL",MVC_VIEW_ORDEM,'04')

	oStruN9C:SetProperty("N9C_OK",    MVC_VIEW_ORDEM,'01')
	oStruN9C:SetProperty("N9C_STSLEG",MVC_VIEW_ORDEM,'02')
	oStruN9C:SetProperty("N9C_ITEM",  MVC_VIEW_ORDEM,'03')
	oStruN9C:SetProperty("N9C_CODROM",MVC_VIEW_ORDEM,'04')
	oStruN9C:SetProperty("N9C_TPPEN", MVC_VIEW_ORDEM,'05')
	oStruN9C:SetProperty("N9C_QTDPEN",MVC_VIEW_ORDEM,'06')

	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_N9B', oStruN9B, 'MdFieldN9B' )

	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N9C', oStruN9C, 'MdGridN9C' )

	//---------------------------------------------
	//Tamanho de cada view
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'MAIN', 100 )
	oView:CreateVerticalBox( 'UNICO', 100, 'MAIN' )

	//Cabeçalho
	oView:CreateHorizontalBox( 'CABEC', 30, 'UNICO' )

	//Grid de pendências
	oView:CreateHorizontalBox( 'GRID' , 70, 'UNICO'  )
	oView:CreateFolder('FOLDER1','GRID')
	oView:AddSheet('FOLDER1','ABAETAPA', STR0007 ) //pendências
	oView:CreateHorizontalBox( 'BOXETAPA', 100, , , 'FOLDER1', 'ABAETAPA')

	oView:SetOwnerView( 'VIEW_N9B', 'CABEC' )
	oView:SetOwnerView( 'VIEW_N9C', 'BOXETAPA' )

	//-----------------
	//Adiciona botão
	//-----------------
	oView:AddUserButton(STR0003,  '', {|oModel,oView| PendFisica(oModel,oView)} ) //"Solucionar Pend. Física"
	oView:AddUserButton(STR0005,  '', {|oModel,oView| PendFiscal(oModel,oView)} ) //"Solucionar Pend. Fiscal"

Return oView


/*/{Protheus.doc} MenuDef
//Camada de Menu da Rotina
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.AGRA520' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'AGRA520ALT' OPERATION 4 ACCESS 0         // 'Alterar '

Return aRotina



/*/{Protheus.doc} AGRA520ALT
//Função acionada na opção alterar passa array com os botões visiveis em tela 
@author marina.muller
@since 07/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA520ALT()
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0016},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //botão fechar

	FWExecView(STR0001 /*Gestor de Pendências*/,"AGRA520",4,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,/*nPercReducao*/,aButtons,{|| bCancelOpe()})

Return .T. 


/*/{Protheus.doc} bCancelOpe
//Função acionada no botão FECHAR desabilita validação preenchimento da view
@author marina.muller
@since 07/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function  bCancelOpe()
	Local oView := FwViewActive()

	oView:oModel:lModify := .F.
	oView:lModify := .F.

Return .T.


/*/{Protheus.doc} AGRA520INL
//Função inicializa legenda no GRID de pendências
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA520INL()
	Local aArea     := GetArea()
	Local cValor    := ""

	If N9C->N9C_STATUS == "1"        //1 - aberta
		If N9C_TPPEN = "2" // Complemento fiscal 
			if N9C_FILIAL == N9C_FILROM
				cValor := "BR_VERMELHO"
			Else
				cValor = "BR_PRETO"
			endIf
		ElseIf N9C_TPPEN = "4" // Devolução fiscal
			if N9C_FILIAL = N9C_FILROM
				cValor = "BR_PRETO"
			Else
				cValor := "BR_VERMELHO"
			endIf
		Else
			cValor := "BR_VERMELHO" 
		endIf
	ElseIf N9C->N9C_STATUS == "2"    //2 - finalizada
		cValor := "BR_VERDE"
	EndIf

	RestArea(aArea)

Return cValor

/*/{Protheus.doc} AGRA520INK
// Responsável por validar o checkbox.
// Somente fica disponível para selecionar caso pendência possa ser solucionada pelo usuário logado
// e se ela estiver com status = 1(aberta).
@author brunosilva
@since 25/04/2018
@version undefined

@type function
/*/
Function AGRA520INK()
	Local oModel	:= FwViewActive()
	Local oModelN9C := oModel:GetModel("MdGridN9C")
	Local aArea     := GetArea()
	Local lMarca    := .T.

	If oModelN9C:GetValue("N9C_STATUS") == "1"        //1 - aberta
		If oModelN9C:GetValue("N9C_TPPEN") == "2" // Complemento fiscal 
			if oModelN9C:GetValue("N9C_FILIAL") == oModelN9C:GetValue("N9C_FILROM")
				lMarca := .T.
			Else
				lMarca = .F.
			endIf
		ElseIf oModelN9C:GetValue("N9C_TPPEN") == "4" // Devolução fiscal
			if oModelN9C:GetValue("N9C_FILIAL") == oModelN9C:GetValue("N9C_FILROM")
				lMarca = .F.
			Else
				lMarca := .T.
			endIf
		Else
			lMarca := .T. 
		endIf
	ElseIf oModelN9C:GetValue("N9C_STATUS") == "2"    //2 - finalizada
		lMarca := .F.
	EndIf

	RestArea(aArea)

Return lMarca



/*/{Protheus.doc} AGRA520LEG
//Função mostra explicação das legendas quando clica em cima da bolinha
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
/*/
Function AGRA520LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local aLegenda 	:= {}
	Local lRet			:= .T.

	If cIDField == "N9C_STSLEG" .AND. cAction != "SETVALUE"
	    aLegenda := {{ "BR_VERDE"   , STR0012 },; // 2 - Finalizada
	                 { "BR_VERMELHO", STR0011 },; // 1- Aberta
	                 { "BR_PRETO"   , STR0028 }}  // Solução não autorizada para esta filial

		BrwLegenda(STR0015 /*Legenda*/, STR0015 /*Legenda*/, aLegenda)
	EndIf

Return lRet


/*/{Protheus.doc} ValidPend
//Função verifica se não foi marcado nenhum registro no GRID para ser processado
//Função verifica se foi marcado algum registro diferente da pendência que está sendo solucionada 
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cTpPend, characters, descricao
@param oModel, object, descricao
@type function
/*/
Static Function ValidPend(cTpPend, oModel)
	Local lRet	  := .T.
	Local lPend   := .T.
	Local nX
	Local nY
	Local nPosicao   := 0
	Local oGridN9C   := oModel:GetModel('MdGridN9C')

	//este loop verificar se foi marcado algum registro no GRID para processamento
	For nX := 1 to oGridN9C:Length()
		oGridN9C:GoLine(nX)

		//verifica se pendência está aberta (status = 1)
		If oGridN9C:GetValue("N9C_STATUS") == "1"

			//verifica se checkbox do GRID está marcado
			If oGridN9C:GetValue("N9C_OK") == .T.
				lPend := .F.
				Exit
			EndIf
		EndIf		   
	Next nX

	//Não encontrou registros marcados na GRID com status aberto
	If lPend
		ApMsgAlert(STR0013) //"Não foram marcadas pendências com status aberto para Solução."
		lRet := .F.
	EndIf

	If lRet
		//este loop verificar se foi marcado algum registro tipo diferente pendência solucionada
		For nY := 1 to oGridN9C:Length()
			oGridN9C:GoLine(nY)

			//verifica se pendência está aberta (status = 1)
			If oGridN9C:GetValue("N9C_STATUS") == "1"

				//verifica se checkbox do GRID está marcado
				If oGridN9C:GetValue("N9C_OK") == .T.

					//verifica o tipo da pendência física/fiscal
					nPosicao := Ascan(cTpPend,{|x| ALLTRIM(x) == ALLTRIM(oGridN9C:GetValue("N9C_TPPEN"))})

					//encontrou algum registro com pendência diferente da que está sendo solucionada
					If nPosicao == 0
						ApMsgAlert(STR0014) //"Foram marcados registros com tipo pendência diferente da opção de Solução serão desconsiderados."
						Exit
					EndIf	
				EndIf
			EndIf		   
		Next nY
	EndIf	

Return lRet


/*/{Protheus.doc} PendFisica
//Função chama solução de pendências físicas
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function PendFisica(oModel, oView)
	
	Local aArea			:= GetArea()
	Local lRet	    	:= .T.
	Local nX
	Local oGridN9C  	:= oModel:GetModel('MdGridN9C')
	Local oModN9B   	:= oModel:GetModel('MdFieldN9B')
	Local cTpPend   	:= StrTokArr('1|3','|')  // 1=Complemento Fisico; 3=Devolucao Fisica;
	Local nValComp  	:= 0
	Local nValDevo  	:= 0
	Local nValPesLiq  	:= 0
	Local nValPend 		:= 0
	Local aPendN9C  	:= {}
	Local aRomStatus	:= {}
	Local cMensagem		:= ""
	

	//chama função que valida se foi marcado no GRID alguma pendência diferente da solucionada    
	lRet := ValidPend(cTpPend, oModel)

	If lRet
		For nX := 1 to oGridN9C:Length()
			oGridN9C:GoLine(nX)

			//pendência = aberta (status = 1) e 1=Complemento Fisico ou 3=Devolucao Fisica
			If oGridN9C:GetValue("N9C_STATUS") == "1" .And. oGridN9C:GetValue("N9C_TPPEN") $ "1|3" .AND.; 
			   oGridN9C:GetValue("N9C_OK")
			   
				aPendN9C  	:= {}
			   				   	
			   	If oGridN9C:GetValue("N9C_TPPEN") == "1" //Complemento Fisico
			   		nValComp 	= oGridN9C:GetValue("N9C_QTDPEN")      			   				   
			   	Else //Devolucao Fisica
			   		nValDevo 	= oGridN9C:GetValue("N9C_QTDPEN")
			   		nValPesLiq 	= oGridN9C:GetValue("N9C_PESLIQ")
			   		
					If nValDevo < 0
					   nValDevo := -(nValDevo) //se o valor da devolução for negativo converte para positivo
					Endif
			   	EndIf
			   
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_CODROM")})  //1 - romaneio
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_ITEM")})    //2 - item da pendência
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILORI")})  //3 = filial origem da pendência
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILROM")})  //4 = filial romaneio origem 
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_ROMORI")})  //5 = romaneio origem
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILIAL")})  //6 = filial romaneio
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_TPPEN")})   //7 = tipo pendencia
			   	aAdd(aPendN9C,{oGridN9C:GetValue("N9C_CODPRO")})  //8 = produto
			   
			   	//-- INICIO TRANSAÇÃO PROCESSAMEMTO --//
			   	Begin Transaction
					If aPendN9C[7][1] == "1" //Complemento Fisico
					    nValPend := nValComp
					    lRet := AGRX500PCF(aPendN9C, nValPend, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oModN9B:GetValue("N9B_CODPRO")) 
					ElseIf aPendN9C[7][1] == "3" //Devolucao Fisica 
					    nValPend := nValDevo
					    lRet := AGRX500SPD(aPendN9C, nValPesLiq, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oGridN9C:GetValue("N9C_CODPRO"))	 
					EndIf
		    	
					If lRet .And. nValPend <> 0 
					   //desconta a pendência da quantidade física na N9B 
					   lRet := AGRA520Qtd(oModel, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oModN9B:GetValue("N9B_CODPRO"), nValPend, "FISICA", oModN9B:GetValue("N9B_FILIAL"))
					EndIf
					
					If .Not. lRet
						DisarmTransaction()
					Endif	 
				End Transaction
				//-- FINAL TRANSAÇÃO PROCESSAMEMTO --//
				
				//Apos realizar o processamento do ITEM do for, saberei se deu certo
				aAdd(aRomStatus, {oGridN9C:GetValue("N9C_CODROM"), lRet})
			EndIf
			
			
		Next nX
	Endif

	//Se algum deu certo, o grid deve ser atualizado! E se algum deu erro, este devera ser informado
	For nX := 1 to Len(aRomStatus)
		If aRomStatus[nX][2]
			lRet := .T.
			AtualizaPainel(oModel, aRomStatus)
		Else
			If Empty(cMensagem)
				cMensagem := STR0027 //"Não foi possível solucionar a(s) pendência(s) do(s) Romaneio(s): "
			EndIf
			cMensagem += aRomStatus[nX][1] + "; "
		EndIf
	Next nX
	
	If Empty(cMensagem) .And. lRet
		ApMsgAlert(STR0017) //"Processo realizado com sucesso."
	Else
		ApMsgAlert(cMensagem)
	EndIf

	oView:Refresh('VIEW_N9C')
	oView:Refresh('VIEW_N9B')
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} PendFiscal
//Função chama solução de pendências fiscais
@author marina.muller
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function PendFiscal(oModel, oView)
	
	Local aArea			:= GetArea()
	Local lRet	    	:= .T.
	Local nX
	Local oGridN9C  	:= oModel:GetModel('MdGridN9C')
	Local oModN9B   	:= oModel:GetModel('MdFieldN9B')
	Local nValComp  	:= 0
	Local nValDevo  	:= 0
	Local nValPend  	:= 0
	Local nValPesLiq 	:= 0 
	Local aPendN9C  	:= {}
	Local cTpPend   	:= StrTokArr('2|4','|')  // 2=Complemento Fiscal; 4=Devolucao Fiscal
	Local cEntOri   	:= ''
	Local cLojOri   	:= ''
	Local aAreaNJ0		:= NJ0->( GetArea() )
	Local lAlgodao		:= .F.
	Local cFilDest		:= ""
	Local aRomStatus	:= {}
	Local cMensagem		:= ""

	Private __cNNTFil := "" //variavel carregada na transferencia entre filiais
	Private __cNNTCod := "" //variavel carregada na transferencia entre filiais
		
	//chama função que valida se foi marcado no GRID alguma pendência diferente da solucionada    
	lRet := ValidPend(cTpPend, oModel)
    
    If lRet
		For nX := 1 to oGridN9C:Length()
			oGridN9C:GoLine(nX)
	
			//verifica se pendência está aberta (status = 1) e 2=Complemento Fiscal; 4=Devolucao Fiscal e verifica se checkbox do GRID está marcado
			If oGridN9C:GetValue("N9C_STATUS") == "1" .And. oGridN9C:GetValue("N9C_TPPEN") $ "2|4" .AND.;
			   oGridN9C:GetValue("N9C_OK") == .T.
			   
				aPendN9C  	:= {}
			   
			   	If oGridN9C:GetValue("N9C_TPPEN") == "2" //Complemento Fiscal
			   		nValComp 		= oGridN9C:GetValue("N9C_QTDPEN")      			   				   
			   	Else //Devolucao Fiscal
			   		nValDevo 		= oGridN9C:GetValue("N9C_QTDPEN")
			   		nValPesLiq 	= oGridN9C:GetValue("N9C_PESLIQ")
			      
			      	//se o valor da devolução for negativo converte para positivo
			      	If nValDevo < 0
			      		nValDevo := -(nValDevo)
			      	Endif
			    EndIf

			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_CODROM")})  //1 - romaneio
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_ITEM")})    //2 - item da pendência
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILORI")})  //3 = filial origem da pendência
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILROM")})  //4 = filial romaneio origem 
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_ROMORI")})  //5 = romaneio origem
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_FILIAL")})  //6 = filial romaneio
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_TPPEN")})   //7 = tipo pendencia
			    aAdd(aPendN9C,{oGridN9C:GetValue("N9C_CODPRO")})  //8 = produto
			   
			    lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+aPendN9C[8][1],"B5_TPCOMMO")== '2',.T.,.F.)
			   
			    //-- INICIO TRANSAÇÃO PROCESSAMEMTO --//
			    Begin Transaction
			    
					If aPendN9C[7][1] == "2" //Complemento Fiscal 
					    nValPend := nValComp  
					    lRet := AGRX500SCF(aPendN9C, nValPend, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oModN9B:GetValue("N9B_CODPRO"), oModel)
					    
					    /*if lAlgodao
							lRet := AX520APFar(oGridN9C:GetValue("N9C_FILROM"), oGridN9C:GetValue("N9C_ROMORI"), nValPend) //ajusta o peso do fardão
					    endIf*/
					ElseIf aPendN9C[7][1] == "4" //Devolucao Fiscal  
					    nValPend := nValDevo
					EndIf			
			
					If lRet .And. nValPend <> 0
					    dbSelectArea('NJ0')
						NJ0->(dbSetOrder(5))
						If NJ0->(MsSeek(FWxFilial('NJ0')+oModN9B:GetValue("N9B_FILIAL"))) 
							cEntOri := NJ0->NJ0_CODENT
							cLojOri := NJ0->NJ0_LOJENT
						EndIf
						RestArea(aAreaNJ0)
		
				    	If aPendN9C[7][1] == "4"
							//Gera PV e NF com tipo de devolução com a quantidade da pendencia.			
							MsgRun( STR0022, STR0021, {||lRet := AGRX520PED(oGridN9C:GetValue('N9C_FILIAL'), oGridN9C:GetValue('N9C_CODROM'), nValPend, oGridN9C:GetValue('N9C_CODENT'), oGridN9C:GetValue('N9C_LOJENT'), oGridN9C:GetValue('N9C_ROMORI'))}) //"Aguarde" //"Solucionando pendência."
							
							if lRet .AND. AGRA520Qtd(oModel, oGridN9C:GetValue("N9C_CODSAF"), cEntOri, cLojOri, oModN9B:GetValue("N9B_CODPRO"), nValPend, "FISCAL", oGridN9C:GetValue("N9C_FILROM"))
								//Se não conseguir atualizar o status da pendencia da ORIGEM
								// Se conseguir, prossegue.
								If AGRX500STT(aPendN9C, oGridN9C:GetValue("N9C_CODSAF"), cEntOri, cLojOri, "ORIGEM")
											
									/****************ATUALIZA DESTINO******************/
									//Atualiza a quantidade no destino
									if AGRA520Qtd(oModel, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oModN9B:GetValue("N9B_CODPRO"), nValPend, "FISCAL", oModN9B:GetValue("N9B_FILIAL"))			    	
										//Atualiza o status da pendencia do DESTINO
										If !(AGRX500STT(aPendN9C, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), "DESTINO"))
											lRet := .F.
										EndIf
									Else //Deu erro na atualização da quantidade no DESTINO
										lRet := .F.
									EndIF
									/****************ATUALIZA DESTINO******************/
									
								Else //Deu erro na atualização do status na ORIGEM.
									lRet := .F.
								EndIf	
							Else //Deu erro na atualização da quantidade na ORIGEM
								lRet := .F.
							EndIf
						else
							dbSelectArea('NJ0')
							NJ0->(dbSetOrder(1))
							If NJ0->(MsSeek(FWxFilial('NJ0')+oGridN9C:GetValue("N9C_CODENT")+oGridN9C:GetValue("N9C_LOJENT"))) 
								cFilDest := NJ0->NJ0_CODCRP
							EndIf
							RestArea(aAreaNJ0)
							
							if AGRA520Qtd(oModel, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), oModN9B:GetValue("N9B_CODPRO"), nValPend, "FISCAL", oGridN9C:GetValue("N9C_FILROM"))
								//Se não conseguir atualizar o status da pendencia da ORIGEM
								// Se conseguir, prossegue.
								If AGRX500STT(aPendN9C, oGridN9C:GetValue("N9C_CODSAF"), oGridN9C:GetValue("N9C_CODENT"), oGridN9C:GetValue("N9C_LOJENT"), "ORIGEM")
											
									/****************ATUALIZA DESTINO******************/
									//Atualiza a quantidade no destino
									if AGRA520Qtd(oModel, oGridN9C:GetValue("N9C_CODSAF"), cEntOri, cLojOri, oModN9B:GetValue("N9B_CODPRO"), nValPend, "FISCAL", cFilDest)			    	
										//Atualiza o status da pendencia do DESTINO
										If !(AGRX500STT(aPendN9C, oGridN9C:GetValue("N9C_CODSAF"), cEntOri , cLojOri, "DESTINO"))
											lRet := .F.
										EndIf
									Else //Deu erro na atualização da quantidade no DESTINO
										lRet := .F.
									EndIF
									/****************ATUALIZA DESTINO******************/
									
								Else //Deu erro na atualização do status na ORIGEM.
									lRet := .F.
								EndIf	
							Else //Deu erro na atualização da quantidade na ORIGEM
								lRet := .F.
							EndIf
						EndIf
					EndIf
					
					If .NOT. lRet  
						DisarmTransaction()		
					EndIf	
				End Transaction
				//-- FINAL TRANSAÇÃO PROCESSAMEMTO --//
	
				aAdd(aRomStatus, {oGridN9C:GetValue("N9C_CODROM"), lRet})			
			EndIf		   
		Next nX	   
	EndIf	

	//Se algum deu certo, o grid deve ser atualizado! E se algum deu erro, este devera ser informado
	For nX := 1 to Len(aRomStatus)
		If aRomStatus[nX][2]
			lRet := .T.
			AtualizaPainel(oModel, aRomStatus)
		Else
			If Empty(cMensagem)
				cMensagem := STR0027 //"Não foi possível solucionar a(s) pendência(s) do(s) Romaneio(s): "
			EndIf
			cMensagem += aRomStatus[nX][1] + "; "
		EndIf
	Next nX
	
	If Empty(cMensagem) .And. lRet
		ApMsgAlert(STR0017) //"Processo realizado com sucesso."
	ElseIf .Not. Empty(cMensagem)
		ApMsgAlert(cMensagem)
	EndIf

	oView:Refresh('VIEW_N9C')
	oView:Refresh('VIEW_N9B')
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} AGRA520Qtd
//Função atualiza a quantidade fisica/fiscal após processamento das pendências
@author marina.muller
@since 12/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRA520Qtd(oModel, cSafra, cEntidade, cLojEnt, cProduto, nValPend, cTipo, cFilPen) 
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oModN9B := oModel:GetModel('MdFieldN9B')

	DbSelectArea('N9B')
	N9B->(DbSetOrder(1))
    
    If N9B->(MsSeek(cFilPen+cSafra+cEntidade+cLojEnt+cProduto)) //filial+safra+entidade+loja+produto
		If RecLock( "N9B",.F.)
			If cTipo == "FISICA"      //desconta valor da pendência física da quantidade 
			   If N9B->N9B_FISICO > 0
			      N9B->N9B_FISICO := N9B->N9B_FISICO - nValPend 
			   Else   
			      N9B->N9B_FISICO := N9B->N9B_FISICO + nValPend
			   Endif
			   oModN9B:LoadValue( "N9B_FISICO", N9B->N9B_FISICO) //seta valor da quantidade física
			
			ElseIf cTipo == "FISCAL"  //desconta valor da pendência fiscal da quantidade
			   If N9B->N9B_FISCAL > 0 
			      N9B->N9B_FISCAL := N9B->N9B_FISCAL - nValPend
			   Else
			      N9B->N9B_FISCAL := N9B->N9B_FISCAL + nValPend
			   EndIf      
			   oModN9B:LoadValue( "N9B_FISCAL", N9B->N9B_FISCAL) //seta valor da quantidade fiscal
			EndIf
			N9B->( msUnLock() )
		Else 
		    lRet := .F.
		EndIf
	EndIf
	
	N9B->(dbCloseArea())	
		
    If !(lRet) 
       Help( ,, STR0020,, STR0019, 1, 0) //'Erro'###"Problema atualização quantidade física/fiscal."
    EndIf      	
	
	RestArea(aArea)
	
Return lRet

 /*/{Protheus.doc} AtualizaPainel
//Atualiza o grid na N9C
@author carlos.augusto
@since 09/04/2018
@version undefined
@type function
/*/
Static Function AtualizaPainel(oModel, aRomStatus)
	Local aLines  	:= FwSaveRows()
	Local oGridN9C  := oModel:GetModel('MdGridN9C')
	Local nX, nY
	Local lRet := .T.
	
	For nX := 1 to oGridN9C:Length()
		oGridN9C:GoLine(nX)

		//verifica se pendência está aberta (status = 1)
		If oGridN9C:GetValue("N9C_STATUS") == "1"  

			//verifica se checkbox do GRID está marcado
			If oGridN9C:GetValue("N9C_OK") == .T.
				lRet := .T.
				For nY := 1 to Len(aRomStatus)
					If aRomStatus[nY][1] == oGridN9C:GetValue("N9C_CODROM")
						If .Not. aRomStatus[nY][2]
							lRet := .F.
							exit
						EndIf
					EndIf
				Next nY
				
				If lRet
					oGridN9C:LoadValue("N9C_STATUS", "2") //seta valor do status para finalizado
					oGridN9C:LoadValue("N9C_STSLEG","BR_VERDE") //seta legenda com bolinha verde
					oGridN9C:LoadValue("N9C_OK",.F.)
				EndIf
			EndIf
		EndIf		   
	Next nX
	FwRestRows(aLines)
Return 


/*/{Protheus.doc} GridLegend
//Função para encontrar a legenda de acordo com as pendências em aberto/fechado
@author marina.muller
@since 23/04/2018
@return ${return}, ${return_description}
@type function
/*/
Static Function GridLegend(cFilN9B, cSafra, cEntidade, cLojaEntid, cProduto)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	N9C->(dbSelectArea('N9C'))
	N9C->(dbSetOrder(1))
	
	If N9C->(MsSeek(cFilN9B+cSafra+cEntidade+cLojaEntid+cProduto)) //FILIAL+SAFRA+ENTIDADE+LOJA+PRODUTO
	   While !N9C->(Eof())                       .And. ;
	         cFilN9B == N9C->N9C_FILIAL          .And. ;
	         cSafra == N9C->N9C_CODSAF           .And. ;
	         cEntidade == N9C->N9C_CODENT        .And. ;
	         cLojaEntid == N9C->N9C_LOJENT       .And. ;
	         cProduto == N9C->N9C_CODPRO
	                                                                                                            
	   	  If N9C->N9C_STATUS == "1" //status pendência aberta  
	   	     lRet := .F.
	   	     Exit
	   	  EndIf
	   	  	
	      N9C->(dbSkip())
	   EndDo  
	EndIf                                                                                                          
	N9C->(dbCloseArea())
	
	RestArea(aArea)
Return lRet
