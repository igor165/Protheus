#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "UBAA120.CH"

/*/{Protheus.doc} UBAA120
//Função inicial apontamento de parada
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function UBAA120()
	Local oBrowse

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetAlias("DXE")
	oBrowse:SetDescription(STR0001)	//"Apontamento de parada"
	oBrowse:SetOnlyFields( { 'DXE_FILIAL', 'DXE_CODIGO', 'DXE_DESCRI' } )

	oBrowse:AddLegend({||  GridLegend(DXE->DXE_FILIAL, DXE->DXE_CODIGO)}, "BLUE", STR0007) //2 - finalizado
	oBrowse:AddLegend({|| !GridLegend(DXE->DXE_FILIAL, DXE->DXE_CODIGO)}, "RED",  STR0008) //1 - andamento

	oBrowse:Activate()
	
Return

/*/{Protheus.doc} MenuDef
//Função opções de menu
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.UBAA120" OPERATION 2 ACCESS 0	//"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.UBAA120" OPERATION 4 ACCESS 0	//"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.UBAA120" OPERATION 8 ACCESS 0	//"Imprimir"

Return aRotina

/*/{Protheus.doc} ModelDef
//Função criação do modelo
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oModel 	 := Nil
	Local oStruDXE   := FWFormStruct( 1, 'DXE' )
	Local oStruNC5   := FWFormStruct( 1, 'NC5' ) 
    Local bLinePre   := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| UBAA120PRE(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
    Local bGrdVld    := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| UBAA120DEL(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
    
    //Cria o modelo 	
	oModel := MPFormModel():New( 'UBAA120',/*bPre*/,{|oModel| UBAA120Pos(oModel)}/*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:SetDescription( STR0001 ) //"Apontamento de parada"

	//-----------------------------------------------
	// Adiciona estrutura da GRID o campo de legenda
	//-----------------------------------------------
	oStruNC5:AddField(STR0009 /*Status*/, STR0009 /*Status*/, 'NC5_STSLEG', 'BT' , 1 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.) 
    
	//------------------------------------------------
	// Inicializa legenda no GRID
	//------------------------------------------------
	oStruNC5:SetProperty( 'NC5_STSLEG' , MODEL_FIELD_INIT , {|| UBAA120INL()})

	// Adiciona a estrutura da Field
	oModel:AddFields( 'MdFieldDXE', /*cOwner*/, oStruDXE )
	
	// Adiciona a estrutura da Grid
	oModel:AddGrid( "MdFieldNC5", "MdFieldDXE", oStruNC5, bLinePre/*bLinePre*/, /*bLinePost*/, bGrdVld, bGrdVld)
	oModel:GetModel("MdFieldNC5" ):SetOptional(.T.)

	// Seta relacionamento
	oModel:SetRelation( 'MdFieldNC5', {{'NC5_FILIAL', 'fwxFilial("NC5")'}, {'NC5_CONJTO', 'DXE_CODIGO'}}, NC5 ->(IndexKey( 2 ) ) )

Return oModel

/*/{Protheus.doc} ViewDef
//Função criação da view
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel 	:= FWLoadModel('UBAA120')
	Local oStruDXE	:= FWFormStruct(2,'DXE')
	Local oStruNC5	:= FWFormStruct(2,'NC5')

	//Instância modelo de visualização
	oView := FwFormView():New()

	//Seta o modelo de dados
	oView:SetModel( oModel )
	oView:SetDescription( STR0001 ) //"Apontamento de parada"

	//-----------------------
	// Adiciona na View o botão de Legenda
	//-----------------------
	oStruNC5:AddField( "NC5_STSLEG" ,'01' , STR0009 /*Status*/, STR0009 /*Status*/, {} , 'BT' ,'@BMP',NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )
	
	//seta posição dos registros do GRID na tela
	oStruNC5:SetProperty("NC5_STSLEG",MVC_VIEW_ORDEM,'01')
	oStruNC5:SetProperty("NC5_CODMOT",MVC_VIEW_ORDEM,'02')
	oStruNC5:SetProperty("NC5_TURNO",MVC_VIEW_ORDEM, '03')
	oStruNC5:SetProperty("NC5_DTINI",MVC_VIEW_ORDEM, '04')
	oStruNC5:SetProperty("NC5_HRINI",MVC_VIEW_ORDEM, '05')
	oStruNC5:SetProperty("NC5_DTTER",MVC_VIEW_ORDEM, '06')
	oStruNC5:SetProperty("NC5_HRTER",MVC_VIEW_ORDEM, '07')
	oStruNC5:SetProperty("NC5_OBSPAR",MVC_VIEW_ORDEM,'08')
	oStruNC5:SetProperty("NC5_CODUSU",MVC_VIEW_ORDEM,'09')
	
	//remove campo da view DXE
	oStruDXE:RemoveField("DXE_CODPRO")
	oStruDXE:RemoveField("DXE_DESCPR")
	oStruDXE:RemoveField("DXE_CODSAI")
	oStruDXE:RemoveField("DXE_UBA")
	oStruDXE:RemoveField("DXE_NMUBA")
	oStruDXE:RemoveField("DXE_LOCAL")
	oStruDXE:RemoveField("DXE_PSITEM")
	oStruDXE:RemoveField("DXE_PSBAL")
	oStruDXE:RemoveField("DXE_PSMIN")
	oStruDXE:RemoveField("DXE_PSMAX")
	oStruDXE:RemoveField("DXE_RDMIN")
	oStruDXE:RemoveField("DXE_RDMAX")
	oStruDXE:RemoveField("DXE_RDMED")
	oStruDXE:RemoveField("DXE_DTINIB")
	oStruDXE:RemoveField("DXE_DTFINB")
	oStruDXE:RemoveField("DXE_NUMSER")
	oStruDXE:RemoveField("DXE_KGPHR")
	oStruDXE:RemoveField("DXE_HRPROD")
	oStruDXE:RemoveField("DXE_FRDDIA")

	//remove campo da view NC5
	oStruNC5:RemoveField("NC5_CODIGO")
	oStruNC5:RemoveField("NC5_CONJTO")
	oStruNC5:RemoveField("NC5_DSCJTO")
	oStruNC5:RemoveField("NC5_STATUS")

	//seta campo da view DXE para não editável
	oStruDXE:SetProperty( 'DXE_CODIGO', MVC_VIEW_CANCHANGE, .F.)
	oStruDXE:SetProperty( 'DXE_DESCRI', MVC_VIEW_CANCHANGE, .F.)
	
	//Adiciona os campos na estrutura do modelo de dados
	oView:AddField("VIEW_DXE", oStruDXE, "MdFieldDXE")

	//Adiciona ao view um formulário do tipo FWFormGrid
	oView:AddGrid( "VIEW_NC5", oStruNC5, "MdFieldNC5" )

	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR", 15)
	oView:CreateHorizontalBox( "INFERIOR", 85)

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "VIEW_DXE", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NC5", "INFERIOR" )

Return oView

/*/{Protheus.doc} GridLegend
//Função inicializa legenda do browse
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilDXE, characters, descricao
@param cConjto, characters, descricao
@type function
/*/
Static Function GridLegend(cFilDXE, cConjto)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	NC5->(dbSelectArea('NC5'))
	NC5->(dbSetOrder(2))
	
	If NC5->(MsSeek(cFilDXE+cConjto)) //NC5_FILIAL+NC5_CONJTO
	   While !NC5->(Eof())                       .And. ;
	         cFilDXE == NC5->NC5_FILIAL          .And. ;
	         cConjto == NC5->NC5_CONJTO
	                                                                                                            
	   	  If NC5->NC5_STATUS == "1" //1 - andamento  
	   	     lRet := .F.
	   	     Exit
	   	  EndIf
	   	  	
	      NC5->(dbSkip())
	   EndDo  
	EndIf                                                                                                          
	NC5->(dbCloseArea())
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} UBAA120INL
//Função inicializa legenda
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function UBAA120INL()
	Local aArea     := GetArea()
	Local cValor    := ""
	
	If NC5->NC5_STATUS == "2"  //2 - finalizado
		cValor := "BR_VERDE"
	Else                       //1 - andamento
		cValor := "BR_VERMELHO"
	EndIf

	RestArea(aArea)

Return cValor

/*/{Protheus.doc} UBAA120TER
//Função valida preenchimento data e hora término e atualiza status para finalizado
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function UBAA120TER()
	Local aLines    := FwSaveRows()
	Local lRet	    := .T.
	Local oModel	:= FWModelActive()
	Local oStruNC5  := oModel:GetModel('MdFieldNC5')
	Local lRestExec := .F.
	
	If FindFunction("AGRIsRest")
	   lRestExec := AGRIsRest()
	EndIf

	
	//se data término for menor que data início apresenta mensagem
	If oStruNC5:GetValue('NC5_DTTER', AGR120Line(lRestExec)) < oStruNC5:GetValue('NC5_DTINI', AGR120Line(lRestExec)) 
	   lRet := .F.
	   oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0021, STR0022, "") //"Data término menor que data início.","Informe data término maior ou igual data início." 
	
	//se data término for igual data início valida preenchimento da hora
	ElseIf oStruNC5:GetValue('NC5_DTTER', AGR120Line(lRestExec)) == oStruNC5:GetValue('NC5_DTINI', AGR120Line(lRestExec))
	    
	    //se hora término não for vazia e diferente "  :  "
	    If !Empty(oStruNC5:GetValue('NC5_HRTER', AGR120Line(lRestExec))) .And. oStruNC5:GetValue('NC5_HRTER', AGR120Line(lRestExec)) <> "  :  "
		    
		    //se hora término for menor ou igual que hora início apresenta mensagem
		    If oStruNC5:GetValue('NC5_HRTER', AGR120Line(lRestExec)) <= oStruNC5:GetValue('NC5_HRINI', AGR120Line(lRestExec))
		    	lRet := .F.
		    	oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0023, STR0024, "") //"Hora término menor ou igual hora início.","Informe hora término maior hora início." 
		    EndIf
		EndIf    
	EndIf

	If lRet
		If !Empty(oStruNC5:GetValue('NC5_DTTER', AGR120Line(lRestExec))) .And. !Empty(oStruNC5:GetValue('NC5_HRTER', AGR120Line(lRestExec))) 
		   oStruNC5:LoadValue("NC5_STATUS", "2")       //seta valor do status para finalizado
		   oStruNC5:LoadValue("NC5_STSLEG","BR_VERDE") //seta legenda com bolinha verde
		EndIf
	EndIf	
	
	FwRestRows(aLines)
	
Return lRet

/*/{Protheus.doc} UBAA120PRE
//Função inicializa legenda do GRID
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function UBAA120PRE(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local aLegenda 	:= {}
	Local lRet	    := .T.

	If cIDField == "NC5_STSLEG" .AND. cAction != "SETVALUE"
	    aLegenda := {{ "BR_VERDE",     STR0007  },;  //2 - finalizado
	                 { "BR_VERMELHO", STR0008  }}    //1 - andamento

		BrwLegenda(STR0010 /*Legenda*/, STR0010 /*Legenda*/, aLegenda)
	EndIf

Return lRet

/*/{Protheus.doc} UBAA120Pos
//Função valida o preenchimento dos campos obrigatórios
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function UBAA120Pos(oModel)
	Local lRet	    := .T.
	Local nI
	Local oMdlNC5	:= oModel:GetModel('MdFieldNC5')
	Local lRestExec := .F.
	
	If FindFunction("AGRIsRest")
	   lRestExec := AGRIsRest()
	EndIf

	If .Not. lRestExec
		//inclui array com os registros selecionados em tela
		For nI := 1 To oMdlNC5:Length()
			oMdlNC5:GoLine(nI)
	
			If !(oMdlNC5:IsDeleted())
				lRet := VldCampos(oModel)
				If .Not. lRet
					exit
				Endif
			EndIf   
		Next nI	
	Else
		If oModel:GetOperation() != 5
			lRet := VldCampos(oModel)
		EndIf
		If lRet
			lRet := AGRVldCjnt(oModel) //Valida existencia do conjunto 
		EndIf 
	EndIf

	Return lRet

/*/{Protheus.doc} UBAA120DEL
//Função valida para não permitir excluir linha quando apontamento estiver finalizado
@author marina.muller
@since 16/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function UBAA120DEL(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet      := .T.
	Local oModel	:= FWModelActive()
	
	If cAction == "DELETE"
		//se status do apontamento for finalizado não deixa excluir linha
		If oGridModel:GetValue("NC5_STATUS") == "2"
			lRet := .F.
			oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0019, STR0020, "") //"Apontamento finalizado não pode ser excluído.","Somente podem ser excluído apontamentos em andamento."
		EndIf
	EndIf
	
Return lRet


/*/{Protheus.doc} AGR120Line
//Retorna a posicao do apontamento.
//Se for por rest sera sempre 1. Se nao, pega pelo modelo 
@author carlos.augusto
@since 17/08/2018
@version undefined
@type function
/*/
Static Function AGR120Line(lRestExec)
	Local oModel	:= FWModelActive()
	Local oStruNC5  := oModel:GetModel('MdFieldNC5')
	Local nLinha	:= 0
	
	If lRestExec
		nLinha := 1
	Else
		nLinha := oStruNC5:GetLine()
	EndIf
Return nLinha


/*/{Protheus.doc} VldCampos
//Validacao de campos
@author carlos.augusto
@since 17/08/2018
@version undefined
@type function
/*/
Static Function VldCampos(oModel)
	Local lRet	    := .T.
	Local oMdlNC5	:= oModel:GetModel('MdFieldNC5')

   If Empty(oMdlNC5:GetValue("NC5_CODMOT"))
       lRet := .F.
       oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0011, STR0012, "") //"Motivo de parada não preenchido.","Necessário informar motivo de parada." 
   EndIf
   
   If Empty(oMdlNC5:GetValue("NC5_TURNO"))
       lRet := .F.
       oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0013, STR0014, "") //"Turno não preenchido.","Necessário informar turno." 
   EndIf

   If Empty(oMdlNC5:GetValue("NC5_DTINI"))
       lRet := .F.
       oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0015, STR0016, "") //"Data inicial não preenchida.","Necessário informar data inicial."
   EndIf

   If Empty(oMdlNC5:GetValue("NC5_HRINI")) .Or. oMdlNC5:GetValue("NC5_HRINI") == "  :  " 
       lRet := .F.
       oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0017, STR0018, "") //"Hora inicial não preenchida.", "Necessário informar hora inicial."
   EndIf
		   
Return lRet


/*/{Protheus.doc} AGRVldCjnt
//Valida conjunto
@author carlos.augusto
@since 17/08/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRVldCjnt(oModel)
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local oMdlNC5	:= oModel:GetModel('MdFieldNC5')
	
	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If .Not. DXE->(DbSeek(FWxFilial('DXE') + oMdlNC5:GetValue("NC5_CONJTO")))
		lRet := .F.
		oModel:SetErrorMessage( , , oModel:GetId(), "", "", STR0025 + FWxFilial('DXE'), STR0026, "") //"Conjunto não cadastrado para a filial. "Verifique o cadastro de conjuntos.
	EndIf
	DXE->(DbCloseArea())
	RestArea(aArea)
Return lRet