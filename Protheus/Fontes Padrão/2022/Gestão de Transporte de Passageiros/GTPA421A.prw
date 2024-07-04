#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

STATIC oMdlG6X	

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421A
Rotina responsável pelo vínculo de Cheque com a Ficha de Remessa.


@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------

Function GTPA421A(oModel, lAuto)
Default lAuto := .F.

oMdlG6X := oModel 

	If !(lAuto)
		FWExecView( '' , "VIEWDEF.GTPA421A", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Seleção de Localidade"
						{|| .T. } ,/*bPre*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
	Else
		GA421AAuto()
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421
Definição de Modelo do Cadastro de Vinculo de Cheque com a Ficha
de Remessa.


@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruGZD	 := FWFormStruct(1,"GZD")	//Tabela de Cheque
Local oStruGZDFk := FWFormStruct(1,"GZD")	
Local oModel     := Nil
Local bCommit    := { |oModel| GTPVincChq(oModel) }
Local bVldActiv  := {|| G421VldAct() }
	
	oModel := MPFormModel():New('GTPA421A', {|oModel| GTP421OK(oModel)}, /*bValid*/, bCommit, /*bCancel*/ )
	
	oStruGZD:AddField("","","GZD_CHECK","L",1,0,Nil,Nil,Nil,Nil,Nil) //"Check para selecionar o Cheque
	
	oModel:AddFields('GZDMASTER',/*cPai*/,oStruGZDFk)
	
	oModel:addGrid('GZDDETAIL','GZDMASTER',oStruGZD,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
	
	oStruGZDFk:SetProperty('*'  , MODEL_FIELD_OBRIGAT, .F. )
	oStruGZDFk:SetProperty('*'  , MODEL_FIELD_VALID  , {|| .T. } )
	
	oStruGZD:SetProperty('*'  , MODEL_FIELD_OBRIGAT, .F. )
	oStruGZD:SetProperty('*'  , MODEL_FIELD_VALID  , {|| .T. } )
	
	oModel:GetModel('GZDMASTER'):SetOnlyQuery(.T.)
	
	oModel:SetVldActivate(bVldActiv)
	oModel:SetActivate( {|oModel| InitDados(oModel) } )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421
Definição da View da rotina de Vínculo de Cheque com a Ficha de
Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView	    := FWFormView():New()
Local oModel    := FWLoadModel('GTPA421A')
Local oStruGZD  := FWFormStruct(2,"GZD")	//Grid de Cheque 
Local oStruGZDB := FWFormStruct(2,"GZD")	//Tabela de Cheque
Local aRemFieldB:= {'GZD_NUMERO','GZD_BANCO','GZD_BCOAGE','GZD_VALOR','GZD_DTEMIS','GZD_FICHAR','GZD_DTDEPO','GZD_CONTA', 'GZD_OBSERV','GZD_CODIGO' }
Local aRemField := {'GZD_AGENCI','GZD_NAGENC','GZD_FICHAR'}
Local nX        := 0
Local nY        := 0

	For nX := 1 to len(aRemFieldB)
		oStruGZDB:RemoveField(aRemFieldB[nX])
	Next nX
	
	For nY := 1 to len(aRemField)
		oStruGZD:RemoveField(aRemField[nY])
	Next nY
	
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_GZDB' ,oStruGZDB, 'GZDMASTER' )
	
	oStruGZD:AddField("GZD_CHECK","01",''	,''	,{''}	,"CHECK",,Nil,Nil,.F.,Nil) //Campo check box para grid

	oView:AddGrid('VIEW_GZD',oStruGZD,'GZDDETAIL')
	
	oView:CreateHorizontalBox('FLDSGZD', 20)
	oView:CreateHorizontalBox('GRIDGZD', 80)
	
	oView:SetDescription('Vínculo de Cheque com Ficha de Remessa')


	oView:SetOwnerView('VIEW_GZDB','FLDSGZD')
	oView:SetOwnerView('VIEW_GZD' ,'GRIDGZD')
	
	oStruGZDB:SetProperty("GZD_AGENCI", MVC_VIEW_CANCHANGE, .F.)
	oStruGZDB:SetProperty("GZD_NAGENC", MVC_VIEW_CANCHANGE, .F.)
	
	oStruGZD:SetProperty("GZD_CHECK"  , MVC_VIEW_CANCHANGE, .T.)
	oStruGZD:SetProperty("GZD_CODIGO" , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_NUMERO" , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_BANCO"  , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_BCOAGE" , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_CONTA"  , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_VALOR"  , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_DTEMIS" , MVC_VIEW_CANCHANGE, .F.)
	oStruGZD:SetProperty("GZD_DTDEPO" , MVC_VIEW_CANCHANGE, .F.)
	
	oView:SetCloseOnOk({||.T.})
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Rotina resonsável pela inicialização de dados. Irá trazer os 
cheques disponiveis para a Ficha de Remessa.


@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function InitDados(oModel)

Local cAliasTmp	 := GetNextAlias()
Local cNumFich   := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_NUMFCH')
Local cAgencia   := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_AGENCI')
Local dDataIni   := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_DTINI')
Local dDataFin   := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_DTFIN')
Local oMdlHeader := oModel:GetModel('GZDMASTER')
Local oMdlDetail := oModel:GetModel('GZDDETAIL')
Local aChqVinc   := {}
Local nI 		 := 1
Local cExpr      := ''

	oMdlHeader:LoadValue('GZD_AGENCI', cAgencia)
	oMdlHeader:LoadValue('GZD_NAGENC', Posicione('GI6', 1, xFilial('GI6')+cAgencia, 'GI6_DESCRI'))

	cExpr := "%(GZD_FICHAR = '' OR GZD_FICHAR = '" + cNumFich + "')%"
	
	BeginSql  Alias cAliasTmp
	
	 SELECT *
	    FROM %Table:GZD% GZD 
	    WHERE GZD_FILIAL  = %xFilial:GZD%
	    AND	  GZD.%NotDel%
	    AND   GZD.GZD_AGENCI =  %Exp:cAgencia%
	    AND   GZD_DTDEPO <> ''
	    AND   %Exp:cExpr%
	    AND  (GZD_DTEMIS  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%  
	    OR    GZD_DTDEPO  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)% )

	EndSql
		
	While !(cAliasTmp)->(EOF())
	
		If !Empty(oMdlDetail:GetValue('GZD_NUMERO'))  
			oMdlDetail:AddLine(.T.)
		EndIf	
		
        oMdlDetail:SetValue('GZD_CODIGO', (cAliasTmp)->GZD_CODIGO)
		oMdlDetail:SetValue('GZD_AGENCI', (cAliasTmp)->GZD_AGENCI )
		oMdlDetail:SetValue('GZD_NUMERO', (cAliasTmp)->GZD_NUMERO )
		oMdlDetail:SetValue('GZD_BANCO' , (cAliasTmp)->GZD_BANCO  )
		oMdlDetail:SetValue('GZD_BCOAGE', (cAliasTmp)->GZD_BCOAGE )
		oMdlDetail:SetValue('GZD_CONTA' , (cAliasTmp)->GZD_CONTA )
		oMdlDetail:SetValue('GZD_VALOR' , (cAliasTmp)->GZD_VALOR  )
		oMdlDetail:SetValue('GZD_DTEMIS', StoD((cAliasTmp)->GZD_DTEMIS) )
		oMdlDetail:SetValue('GZD_FICHAR', (cAliasTmp)->GZD_FICHAR )
		oMdlDetail:SetValue('GZD_DTDEPO', StoD((cAliasTmp)->GZD_DTDEPO) )
		oMdlDetail:SetValue('GZD_CHECK', !Empty((cAliasTmp)->GZD_FICHAR))
						
		(cAliasTmp)->(DbSkip())
		
	EndDo
	(cAliasTmp)->(DBCloseArea())


	// Caso o vinculo ja esteja feito no modelo a tela devera ser atualizada
	aChqVinc := GTPA421GetChq()

	// Se existir algum cheque preenchido
	If (aChqVinc != nil)
		For nI := 1 to Len(aChqVinc)
			oMdlDetail:GoLine(1)
			// Procurar pelo chque do modelo no vinculo
			If oMdlDetail:SeekLine({{'GZD_CODIGO',aChqVinc[nI][1]}})
				// Preenche o check do status do vinculo do cheque
				oMdlDetail:SetValue('GZD_CHECK', aChqVinc[nI][4])
				// Se o valor estiver preenchido
				If (aChqVinc[nI][4])	
					// Preenche com o valor da ficha
					oMdlDetail:SetValue('GZD_FICHAR', cNumFich)
				Else
					// Limpa a ficha
					oMdlDetail:SetValue('GZD_FICHAR', "")
				EndIf
			EndIf
		Next
	EndIf
	
	oMdlDetail:SetNoInsertLine(.T.)// Não permite inclusao no grid
	oMdlDetail:SetNoDeleteLine(.T.)// Não permite deletar a linha
	   																								                                                  
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GTP421OK
Função para realizar a gravação do modelo Principal.


@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function GTP421OK(oModel)
Local nOperation	:= oModel:GetOperation() // Operação de ação sobre o Modelo
Local cField
Local oField 
	
	If nOperation == MODEL_OPERATION_INSERT
	
		// Define que houve modificação, pois na View e no Model não são feitas alterações na GTPA421A
		oField := oModel:GetModel('GZDMASTER')
		cField := oField:GetValue('GZD_AGENCI')
		oField:LoadValue('GZD_AGENCI',cField)
		
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A421DtBetw
Função responsável para verificar se a data de Depósito está entre
o período da Ficha de Remessa ou após o período.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function A421DtBetw(dDataDepo, dDataIni, dDataFin)
Local lRet := .F.
	
	lRet := dDataDepo >= dDataIni .And. dDataDepo <= dDataFin
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPVincChq(oModel)
Função responsável por passar os cheques a serem vinculados para
o modelo principal

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 24/08/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function GTPVincChq(oModel)
Local oGridGZD := oModel:GetModel('GZDDETAIL')
Local aChqVinc := {}
Local dDataIni := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_DTINI')
Local dDataFin := oMdlG6X:GetModel('G6XMASTER'):GetValue('G6X_DTFIN')
Local nX       := 0
Local nValor   := 0 
Local bVinc

	For nX := 1 to oGridGZD:Length()
		
		//If oGridGZD:GetValue("GZD_CHECK", nX)
			bVinc := oGridGZD:GetValue("GZD_CHECK", nX)
			dDataDepo := oGridGZD:GetValue("GZD_DTDEPO", nX)
			If A421DtBetw(dDataDepo, dDataIni, dDataFin)
				cTipo := 'R'
			Else 
				cTipo := 'D'
			EndIf
			cCodigo := oGridGZD:GetValue("GZD_CODIGO", nX)
			nValor  := oGridGZD:GetValue("GZD_VALOR" , nX)
			AAdd(aChqVinc, {cCodigo, cTipo, nValor, bVinc})
		//EndIf
	Next

	GTPA421SetChq(aChqVinc)

Return .T.

Static Function G421VldAct()
Local lRet := .T.

oMdlG6X	:= FwModelActive()

Return lRet

/*/{Protheus.doc} GA421AAuto()
Função utilizada para automacao ADVPR	
@type function
@author flavio.martins
@since 12/03/2020
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA421AAuto()
Local oModel := FwLoadModel('GTPA421A')

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
 
GTP421OK(oModel)

oModel:GetModel('GZDDETAIL'):GoLine(1)
oModel:GetModel('GZDDETAIL'):SetValue('GZD_CHECK', .T.)

oModel:GetModel('GZDDETAIL'):GoLine(2)
oModel:GetModel('GZDDETAIL'):SetValue('GZD_CHECK', .T.)

If oModel:VldData()
	oModel:CommitData()
Endif

oModel:DeActivate()

Return