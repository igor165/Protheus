#INCLUDE "agra650.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cUserBenf := ""
Static __lTemCodUni := .F.
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/**---------------------------------------------------------------------
{Protheus.doc} AGRA650
Manutenção de blocos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
@type function
---------------------------------------------------------------------**/
Function AGRA650()
	Private oBrowse  := Nil

	__cUserBenf := A655GETUNB()// Busca a unidade de beneficiamento

	//Instancia o objeto Browse
	oBrowse :=  FWMBrowse():New()
	oBrowse:SetAlias('DXD')
	oBrowse:SetDescription( STR0001 ) //"Manutenção de Blocos"

	If !Empty(__cUserBenf)
		oBrowse:SetFilterDefault( " DXD_CODUNB = '" + A655GETUNB() + "' " )
	Endif

	If DXD->(ColumnPos("DXD_STATUS")) > 0
		//Adiciona lengedas
		oBrowse:AddLegend( "DXD->DXD_STATUS == '1'", "GREEN"	, AGRTxtBox('1','DXD_STATUS') 	) //"Vazio"
		oBrowse:AddLegend( "DXD->DXD_STATUS == '2'", "YELLOW"	, AGRTxtBox('2','DXD_STATUS')	) //"Iniciado"
		oBrowse:AddLegend( "DXD->DXD_STATUS == '3'", "RED"	    , AGRTxtBox('3','DXD_STATUS')	) //"Finalizado"
		oBrowse:AddLegend( "DXD->DXD_STATUS == '4'", "BLUE"	    , AGRTxtBox('4','DXD_STATUS')	) //"Emb. Fisico Finalizado "
		oBrowse:AddLegend( "DXD->DXD_STATUS == '5'", "WHITE"	, AGRTxtBox('5','DXD_STATUS')	) //"Emb. Fisico Iniciado"
	else
		oBrowse:AddLegend( "DXD_QTDVNC = 0"			, "GREEN"	, STR0002 	) //"Vazio"
		oBrowse:AddLegend( "DXD_QTDVNC < DXD_QTDMAX", "YELLOW"	, STR0003	) //"Iniciado"
		oBrowse:AddLegend( "DXD_QTDVNC = DXD_QTDMAX", "RED"	    , STR0004	) //"Finalizado"
	endIf

	//Acerta código único nos registros que estiverem vazios
	If DXD->(ColumnPos("DXD_CODUNI")) > 0
		__lTemCodUni := .T.
		AGRA650CDU()
	EndIf

	//Acerta status nos registros que não tiverem informação nesse campo
	If DXD->(ColumnPos("DXD_STATUS")) > 0
		AGRA650STS()
	EndIf

	//Ativa o Browse
	oBrowse:Activate()
	SetKey( K_CTRL_F8, Nil )
	SetKey( VK_F12, Nil )
Return

/**---------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrão da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0005		Action 'VIEWDEF.AGRA650' 	OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0006		Action 'VIEWDEF.AGRA650' 	OPERATION 3  ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0007		Action 'VIEWDEF.AGRA650'	OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0008		Action 'VIEWDEF.AGRA650'	OPERATION 5  ACCESS 0 //"Excluir"
	ADD OPTION aRotina Title STR0009		Action 'AGRA650PRc'			OPERATION 4  ACCESS 0 //"Reclassificar"
	ADD OPTION aRotina Title STR0010		Action 'AGRA650BLC(1)'		OPERATION 4  ACCESS 0 //"Incluir Fardos"
	ADD OPTION aRotina Title STR0038	    Action 'AGRA650BLC(3)'		OPERATION 4  ACCESS 0 //"Consulta Fardos"
	ADD OPTION aRotina Title STR0011		Action 'AGRA650BLC(2)'		OPERATION 4  ACCESS 0 //"Excluir Fardos"
	ADD OPTION aRotina Title STR0049 		Action 'A650FchBl'   		OPERATION 11 ACCESS 0	//"Fechar Bloco"
	ADD OPTION aRotina Title STR0050 		Action 'A650HistBl'  		OPERATION 12 ACCESS 0	//"Histórico Bloco"	
		
	IF __lnewNeg
		ADD OPTION aRotina Title STR0039	Action 'AGRA650BLT()'		OPERATION 10 ACCESS 0 //"Imprimir bloco
		ADD OPTION aRotina Title STR0047	Action 'AGRA650BLR()'		OPERATION 9  ACCESS 0 //"Imprimir etiqueta
		ADD OPTION aRotina Title STR0054 Action 'A650EmblFis' OPERATION 13 ACCESS 0 //"Emblocar Fis."
	Else
		ADD OPTION aRotina Title "Imprimir"	Action 'AGRAR650'			OPERATION 8 ACCESS 0 //"Imprimir
	EndIf
		
Return aRotina

/**---------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina Cadastro de Romaneios

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXD 	:= FwFormStruct( 1, "DXD" )//Bloco

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA650',{ |oModel| AGRA650PRE(oModel) } ,  , { |oModel| AGRA650GRV(oModel) }, /*bCancel*/ )
	oModel:SetDescription( STR0012 ) //"Modelo de dados dos Blocos"

	// Adiciona os campos da Field
	oModel:AddFields( 'CABEC', /*cOwner*/, oStruDXD, {|oFieldModel, cAction, cIDField, xValue|PreValDXD(oFieldModel, cAction, cIDField, xValue)} )
	oModel:GetModel( "CABEC" ):SetDescription( STR0013 ) //"Dados do bloco"

	// Seta chave primaria
	oModel:SetPrimaryKey( {"DXD_FILIAL","DXD_SAFRA","DXD_CODIGO"} )

	oModel:SetVldActivate( { | oModel | A650ACTIVE(oModel) } )
Return oModel

/**---------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina manutenção de blocos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA650" )
	Local oStruDXD 	:= FwFormStruct( 2, "DXD", {|cCampo| !(cCampo $ 'DXD_STATUS')} )//Bloco

	//------------------
	// Instancia a View
	//------------------
	oView := FwFormView():New()

	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------
	If !Empty(__cUserBenf)
		oStruDXD:RemoveField( "DXD_CODUNB" )
	Endif

	oStruDXD:RemoveField("DXD_DATATU")
	oStruDXD:RemoveField("DXD_HORATU")

	If !__lnewNeg
		oStruDXD:RemoveField("DXD_QTDVNC")
		oStruDXD:RemoveField("DXD_FDINI")
		oStruDXD:RemoveField("DXD_FDFIN")
		oStruDXD:RemoveField("DXD_PCTFOR")
		oStruDXD:RemoveField("DXD_CODREG")
		oStruDXD:RemoveField("DXD_CODUNI")
		oStruDXD:RemoveField("DXD_LOTE")
		oStruDXD:RemoveField("DXD_NMLOT")
		oStruDXD:RemoveField("DXD_LOCLIZ")
		oStruDXD:RemoveField("DXD_TIPEMB")
	EndIF

	//-------------
	//Seta o Model
	//-------------
	oView:SetModel( oModel )

	//----------------------------
	// Adiciona os campos da View
	//----------------------------
	oView:AddField( 'VIEW_DXD', oStruDXD, 'CABEC' )

	//------------
	// Cria o Box
	//------------
	oView:CreateHorizontalBox( 'TOTAL', 100 )

	//------------
	// Seta Owner
	//------------
	oView:SetOwnerView( 'VIEW_DXD', 'TOTAL' )

Return oView

/*/{Protheus.doc} PreValDXD
Pre-validação dos campos do modelo de dados DXD
@type function
@version P12
@author claudineia.reinert
@since 10/05/2022
@param oFieldModel, object, modelo de dados DXD
@param cAction, character, ação executada
@param cIDField, character, identificação do campo
@param xValue, variant, valor do campo
@return Logical, Valor logico verdadeiro(.T.) ou falso(.F.) referente a validação
/*/
Static Function PreValDXD(oFieldModel, cAction, cIDField, xValue)
	Local lRet 		:= .T.
	Local nFardos 	:= 0 
	Local nOper	  	:= oFieldModel:getModel():GetOperation()

	If nOper != MODEL_OPERATION_INSERT .AND. cAction == "SETVALUE" .AND. cIDField $ "DXD_QTDMAX" 
		nFardos := AGRA650QTD() //qtd fardos vinculado no bloco
		If xValue < nFardos   //se quantidade maxima menor que a qtd vinculada
			lRet := .F.
			Agrhelp(STR0014 , STR0059 + "("+cValToChar(nFardos)+")." , STR0060) //##Atenção ##"Quantidade máxima informada é menor que a quantidade de fardos vinculados ao bloco" ##"É necessario excluir fardos para ajustar este campo."
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AGRA650CDU
//Função faz acerto do código único nos registros que estiverem vazios
@author marina.muller
@since 11/12/2017
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA650CDU()
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local cAliasDXD   := GetNextAlias()
	Local cCodUni     := ""

	BeginSql Alias cAliasDXD
		SELECT DXD_FILIAL, DXD_SAFRA, DXD_CODIGO
		FROM %Table:DXD% DXD
		WHERE DXD.%NotDel%
		AND (DXD.DXD_CODUNI IS NULL
		OR  DXD.DXD_CODUNI = '')
	EndSQL

	(cAliasDXD)->(dbGoTop())
	While (cAliasDXD)->(!Eof())
		// gera código único para registro
		cCodUni := AGRCodeUni("DXD", (cAliasDXD)->DXD_SAFRA, (cAliasDXD)->DXD_CODIGO, "BL")

		dbSelectArea('DXD')
		dbSetOrder(1)
		If MsSeek((cAliasDXD)->DXD_FILIAL+(cAliasDXD)->DXD_SAFRA+(cAliasDXD)->DXD_CODIGO)
			RecLock("DXD",.F.)
			DXD->DXD_CODUNI := cCodUni
			MsUnLock()
		EndIf

		(cAliasDXD)->(dbSkip())
	EndDo
	(cAliasDXD)->( dbCloseArea() )
	RestArea( aSaveArea )

Return lRet

/*/{Protheus.doc} AGRA650STS
//Função faz acerto do campo status nos registros que estiverem vazios
@author silvana.torres
@since 20/01/2018
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA650STS()
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local cAliasDXD   := GetNextAlias()

	BeginSql Alias cAliasDXD
		SELECT DXD_FILIAL, DXD_SAFRA, DXD_CODIGO
		FROM %Table:DXD% DXD
		WHERE DXD.%NotDel%
		AND (DXD.DXD_STATUS IS NULL
		OR  DXD.DXD_STATUS = '')
	EndSQL

	(cAliasDXD)->(dbGoTop())
	While (cAliasDXD)->(!Eof())
		dbSelectArea('DXD')
		dbSetOrder(1)
		If MsSeek((cAliasDXD)->DXD_FILIAL+(cAliasDXD)->DXD_SAFRA+(cAliasDXD)->DXD_CODIGO)
			RecLock("DXD",.F.)

			if DXD->DXD_QTDVNC = 0
				DXD->DXD_STATUS := "1"
			elseif DXD->DXD_QTDVNC < DXD->DXD_QTDMAX
				DXD->DXD_STATUS := "2"
			elseif DXD->DXD_QTDVNC = DXD->DXD_QTDMAX
				DXD->DXD_STATUS := "3"

				// Atualiza a data e hora de alteração para alterar/incluir o bloco no aplicativo do Beneficiamento
				DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()
			endIf

			MsUnLock()
		EndIf

		(cAliasDXD)->(dbSkip())
	EndDo
	(cAliasDXD)->( dbCloseArea() )
	RestArea( aSaveArea )

Return lRet

/**---------------------------------------------------------------------
{Protheus.doc} A650ACTIVE
Valida a ativação do modelo de dados

@param: oModel - Modelo de dados da rotina
@author: Aecio Ferreira Gomes
@since: 28/12/2012
@Uso: AGRA650
@type function
---------------------------------------------------------------------**/
Static Function A650ACTIVE(oModel)
	Local lRet		:= .T.
	Local cQry		:= ""
	Local cAliasQry := ""
	Local nOperac := oModel:GetOperation()

	If nOperac == MODEL_OPERATION_DELETE

		cAliasQry := GetNextAlias()

		cQry := "SELECT COUNT(DISTINCT DXI_ETIQ) QTD "
		cQry += "FROM " + RetSqlName("DXI") + " DXI "
		cQry += "WHERE DXI.DXI_FILIAL 	= 	'"+xFilial("DXI")+"' "
		cQry += "AND DXI.DXI_BLOCO 		= 	'"+DXD->DXD_CODIGO+"' "
		cQry += "AND DXI.DXI_SAFRA 		= 	'"+DXD->DXD_SAFRA+"' "
		cQry += "AND DXI.DXI_CODRES 	<> 	'' "
		cQry += "AND DXI.D_E_L_E_T_ 	= 	''"

		cQry := ChangeQuery( cQry )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		If (cAliasQry)->QTD	 > 0
			Help(,,STR0014,, STR0015,1,0) //"Atenção"###"Existem fardos pertencentes a este Bloco reservados para um contrato, este Bloco não pode ser excluido!"
			lRet := .F.
		EndIf

	EndIf
Return(lRet)

/*/{Protheus.doc} AGRA650BLC
Retorna a View (tela) da rotina manutenção de blocos
@type function
@version P12 
@author Aecio Ferreira Gomes
@since 21/08/2012
@param nOpc, numeric, opção de ações da função 1-incluir/3-consultar/2-excluir fardos
/*/
Function AGRA650BLC(nOpc)
	Local oModel 	:= FWLoadModel("AGRA650")
	Local oAux 		:= oModel:GetModel("CABEC")
	Local oBrw		:= Nil
	Local oDlg		:= Nil
	Local oFWL		:= Nil
	Local oSize		:= Nil
	Local oWind		:= Nil
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aArea		:= GetArea()
	Local aPergs	:= {}
	Local aRet		:= {}
	Local cAliasQry	:= ""
	Local cQry		:= ""
	Local nOpcA     := 0
	Local lRet		:= .T.
	Local cRetpe    := ""
	Local lAG650QRY := ExistBlock('AG650QRY')
	Local lAG650VBL := ExistBlock('AG650VBL')
	Local lExec

	Private oOK			:= LoadBitmap(GetResources(),'LBOK')
	Private oNo   		:= LoadBitmap(GetResources(),'LBNO')
	Private nQtde		:= 0
	Private lMarcaTudo 	:= .F.

	//-------------------------
	// Ativa o modelo de dados
	//-------------------------
	lRet := oModel:Activate()
	
	/*********************************************
	 Ponto de entrada para fazer validações ao 
	 tentar incluir /consultar/excluir fardos, 
	 para determinar se aquele bloco poderá sofrer
	 manutenção dependendo da opção selecionada. - Solicitado pela BF
	 **********************************************/
	If lAG650VBL
		lExec := ExecBlock('AG650VBL', .F., .F., {nOpc, oModel})
		If ValType(lExec) == "L"
			lRet := lExec 
		Endif
	Endif
	
	//------------------------------------
	// se o campo variedade estiver vazio
	//------------------------------------
	If lRet .And. nOpc == 1
		//---------------------------------------
		// Adciona perguntas ao array da parambox
		//---------------------------------------
		aAdd( aPergs ,{1,STR0040, CriaVar("DXI_CODIGO", .F.),"@!",'.T.',,'.T.',TamSX3("DXI_CODIGO")[1],.F.}) //"Fardo De	"
		aAdd( aPergs ,{1,STR0041,CriaVar("DXI_CODIGO", .F.),"@!",'.T.',,'.T.',TamSX3("DXI_CODIGO")[1],.F.}) //"Fardo Ate "

		if Empty(FwFldGet("DXD_CODVAR"))
			aAdd( aPergs ,{1,STR0016, CriaVar("DXI_CODVAR", .F.),"@!",'.T.','NNV','.T.',TamSX3("DXI_CODVAR")[1],.F.}) //"Variedade De	"
			aAdd( aPergs ,{1,STR0017, CriaVar("DXI_CODVAR", .F.),"@!",'.T.','NNV','.T.',TamSX3("DXI_CODVAR")[1],.F.}) //"Variedade Ate "
		EndIf

		aAdd( aPergs ,{1,STR0037,CriaVar("DXI_PRENSA", .F.) ,"@!",'.T.',,'.T.',TamSX3("DXI_PRENSA")[1],.F.})
		//--------------------------------------
		// Chama tela de parametros da parambox
		//--------------------------------------
		lRet := ParamBox(aPergs ,STR0018,@aRet) //"Parametros "
	EndIf

	//---------------------
	// Opção Incluir Fardos
	//---------------------
	If lRet .And. nOpc == 1

		If lRet

			cAliasQry := GetNextAlias()

			cQry := "SELECT * FROM "+ RetSqlName("DXI") + " DXI "
			cQry += "WHERE DXI.DXI_FILIAL	= '"+xFilial("DXI")+"' "
			cQry += "AND DXI.DXI_CLACOM 	= '"+oAux:GetValue('DXD_CLACOM')+"' "
			cQry += "AND DXI.DXI_SAFRA		= '"+oAux:GetValue('DXD_SAFRA')+"' "

			//--------------------------------------------------------------------------------
			// Caso o campo Produtor esteja em branco, considera todos os produtores
			//--------------------------------------------------------------------------------
			IF !Empty(oAux:GetValue('DXD_PRDTOR'))
				cQry += "AND DXI.DXI_PRDTOR		= '"+oAux:GetValue('DXD_PRDTOR')+"' "
			endif
			if !Empty(oAux:GetValue('DXD_LJPRO'))
				cQry += "AND DXI.DXI_LJPRO		= '"+oAux:GetValue('DXD_LJPRO')+"' "
			endif
			//--------------------------------------------------------------------------------
			// Caso o campo Fazenda esteja em branco, considera todas as fazendas do produtor
			//--------------------------------------------------------------------------------
			If !Empty( oAux:GetValue('DXD_FAZ') )
				cQry += "AND DXI.DXI_FAZ		= '"+oAux:GetValue('DXD_FAZ')+"' "
			EndIf

			//--------------------------------------------------------------------
			// Considera as perguntas somente se o campo Variedade estiver vazio
			//--------------------------------------------------------------------
			If !Empty(oAux:GetValue("DXD_CODVAR"))
				cQry += "AND DXI.DXI_CODVAR = '"+oAux:GetValue("DXD_CODVAR")+"' "
				cQry += "AND DXI_PRENSA  = '"+aRet[3]+"'"
			Else
				cQry += "AND DXI.DXI_CODVAR BETWEEN '"+aRet[3]+"' AND '"+aRet[4]+"' "
				if (!Empty(aRet[5]), cQry += "AND DXI_PRENSA  = '"+aRet[5]+"'",)
				EndIf

				//--------------------------------------------------------------------
				// Considera as perguntas somente se o campo Fardo não estiver vazio
				//--------------------------------------------------------------------
				cQry += "AND DXI.DXI_CODIGO BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
				cQry += "AND DXI.DXI_BLOCO	= '' "

				If !Empty(oAux:GetValue('DXD_CODUNB'))
					cQry += "AND DXI.DXI_CODUNB	= '"+oAux:GetValue('DXD_CODUNB')+"' "
				endif

				cQry += "AND DXI.D_E_L_E_T_	= '' "
				cQry += "ORDER BY DXI.DXI_CODIGO"

			//Ponto de Entrada.
				If lAG650QRY
					cRetpe := ExecBlock('AG650QRY', .F. , .F., {cQry, nOpc, oModel})
					If ValType(cRetpe) == 'C'
						cQry:= cRetpe
					EndIf
				EndIf

				cQry := ChangeQuery( cQry )

				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

				//Seleciona a tabela
				dbSelectArea(cAliasQry)
				dbGoTop()
				If (cAliasQry)->(Eof()) .AND. Empty((cAliasQry)->DXI_SAFRA)
					Help(,,STR0014,, STR0044,1,0)//"Atenção"##"Não existem fardos pendentes para blocagem conforme os dados de classificação comercial, produtor, loja e fazenda informados no bloco"
					lRet := .F.
				EndIf
			EndIf
		//---------------------
		// Opção Excluir Fardos
		//---------------------
		ElseIf lRet .And. nOpc == 2
			cAliasQry := GetNextAlias()
			cQry := " SELECT SUM(DXQ_QUANT) AS QTDFRD "
			cQry += " FROM "+ RetSqlName("DXQ") + " DXQ "

			if FwModeAccess("DXQ", 3 ) == "C"
				cQry += "WHERE	DXQ.DXQ_FILORG 	= 	'"+FWxFilial("DXQ")+"' " 
			else
				cQry += "WHERE	DXQ.DXQ_FILIAL 	= 	'"+FWxFilial("DXQ")+"' "
			endif

			cQry += "AND	DXQ.DXQ_BLOCO 	= 	'"+oAux:GetValue('DXD_CODIGO')+"' "
			cQry += "AND	DXQ.DXQ_SAFRA 	= 	'"+oAux:GetValue('DXD_SAFRA')+"' "
			cQry += "AND	DXQ.D_E_L_E_T_ 	= '' "

			cQry := ChangeQuery( cQry )

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

			If DXD->DXD_STATUS = '3' .and. !(cAliasQry)->(Eof()) .and. oAux:GetValue('DXD_QTDVNC') = (cAliasQry)->(QTDFRD) 
				Help(,,STR0014,, STR0053,1,0) //O bloco está vinculado à uma reserva. Não é possível desvincular fardos do bloco!"
				lRet := .F.
			else
				cAliasQry := GetNextAlias()
				cQry := "SELECT * FROM "+ RetSqlName("DXI") + " DXI "
				cQry += "WHERE	DXI.DXI_FILIAL 	= 	'"+xFilial("DXI")+"' "
				cQry += "AND	DXI.DXI_BLOCO 	= 	'"+oAux:GetValue('DXD_CODIGO')+"' "
				cQry += "AND	DXI.DXI_SAFRA 	= 	'"+oAux:GetValue('DXD_SAFRA')+"' "
				cQry += "AND	DXI.D_E_L_E_T_ 	= '' "

			//Ponto de Entrada
				If lAG650QRY
					cRetpe := ExecBlock('AG650QRY', .F. , .F., {cQry, nOpc, oModel})
					If ValType(cRetpe) == 'C'
						cQry:= cRetpe
					EndIf
				EndIf
				cQry := ChangeQuery( cQry )

				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

				If (cAliasQry)->(Eof())
					Help(,,STR0014,, STR0019,1,0) //"Não foram encontratos fardos disponiveis para desvincular do bloco!"
					lRet := .F.
				EndIf
			EndIf
		ElseIf lRet .And. nOpc == 3

			cAliasQry := GetNextAlias()
			cQry := "SELECT * FROM "+ RetSqlName("DXI") + " DXI "
			cQry += "WHERE	DXI.DXI_FILIAL 	= 	'"+xFilial("DXI")+"' "
			cQry += "AND	DXI.DXI_BLOCO 	= 	'"+oAux:GetValue('DXD_CODIGO')+"' "
			cQry += "AND	DXI.DXI_SAFRA 	= 	'"+oAux:GetValue('DXD_SAFRA')+"' "
			cQry += "AND	DXI.D_E_L_E_T_ 	= '' "

			//Ponto de Entrada
			If lAG650QRY
				cRetpe := ExecBlock('AG650QRY', .F. , .F., {cQry, nOpc, oModel})
				If ValType(cRetpe) == 'C'
					cQry:= cRetpe
				EndIf
			EndIf

			cQry := ChangeQuery( cQry )

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

			If (cAliasQry)->(Eof()) .AND. Empty((cAliasQry)->DXI_CLACOM)
				Help(,,STR0014,, STR0035,1,0) //"Não foram encontratos fardos disponiveis para consulta do bloco!"
				lRet := .F.
			EndIf
		EndIf

		If lRet
			DEFINE MSDIALOG oDlg TITLE STR0020 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL //"Blocagem de Fardos"

			// Instacia o componete TFont para definir o tamanho da  fonte
			oFont := TFont():New('Arial',,-12,.T.)

			//----------------------------------------------------------------------------------------------
			// Monta Browse de Fardos pendentes para seleção na coluna esquerda da divisão do panel inferior
			// Cria janela no panel para adicionar posteriormente o Browse
			//----------------------------------------------------------------------------------------------
			oFWL := FWLayer():New()
			oFWL:init( oDlg, .F. )
			oFWL:addCollumn( "TOTAL", 100,.T. )
			oFWL:addWindow( "TOTAL", "W1", If (nOpc == 1,STR0021, STR0022),90, .F., .F. ) //"Marque os itens e confirme para adicionar no bloco"###"Marque os itens e confirme para retirar do Bloco"
			oWind := oFWL:getWinPanel ( "TOTAL", "W1" )

			//---------------------
			// Calcula dimenssoes
			//---------------------
			oSize := FwDefSize():New(.T.)
			oSize:AddObject( "PANEL",  100,100, .T., .T. ) // Totalmente dimensionavel
			oSize:SetWindowSize({0,0,oWind:NHEIGHT,oWind:NWIDTH})
			oSize:lProp 	:= .T.
			oSize:aMargins  := { 3, 3, 3, 3 }
			oSize:Process()

			//------------------------
			//Cria o Browse na janela
			//------------------------
			aHeader	:= AGRMontaHd("DXI")
			oBrw:= MSNewGetDados():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],oSize:aPosObj[1,3],oSize:aPosObj[1,4],0,'','','',{},,,,,,oWind,aHeader,aCols)
			oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrw:oBrowse:bldblclick := {|| MarcaUm(@oBrw, nOpc)}
			AGRMTACOLS(@oBrw, cAliasQry)

			cCss := "QPushButton{ border-radius: 3px;border: 1px solid #000000; background-color: #6E7D81;  }"
			oBotTodos := TButton():New(0,0,'',oWind,{|| (lMarcaTudo := !lMarcaTudo, MarcaTudo(lMarcaTudo,oBrw,nOpc))},8,14.5,,,.F.,.T.,.F.,,.F.,,,.F.)
			oBotTodos:SetCSS( cCss )

			ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If( A650VLDOK(oBrw, nOpc), (nOpcA:= 1, oDlg:End()), .F.)},{|| nOpcA:= 2, oDlg:End()})

			If nOpcA == 1 .And. nOpc != 3
				Begin Transaction
				AGRGrvBlc(oBrw, nOpc)
				End Transaction
			EndIf
		EndIf

	RestArea(aArea)
Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRMontaHd
Monta a estrutura do aHeader para MsNewGetdados

@param: cAlias - Alias da Tabela para montagem da estrutura de dados
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
@type function
---------------------------------------------------------------------**/
Static Function AGRMontaHd(cAlias)
	Local aArea 	:= GetArea()
	Local aAHeader	:= {}
	Local nX    	:= 0
	Local aStruct	:= {}

	aStruct := (cAlias)->(DbStruct())
	Aadd(aAHeader, {" ","MARCA",'@BMP',2,0,".T." ,,"C","",,,})
	Aadd(aAHeader, {" ","LEG",'@BMP',2,0,".T." ,,"C","",,,})
	For nX := 1 To Len(aStruct)
		If cAlias == "DXI" .And. !(Alltrim(aStruct[nX,1]) $ "DXI_CODIGO|DXI_PSLIQU|DXI_SAFRA|DXI_ETIQ|DXI_CLAVIS|DXI_CLACOM|DXI_PRENSA")
			Loop
		EndIf
		If X3USADO(aStruct[nX,1]) .and. cNivel >= AGRRETNIV(aStruct[nX,1]) .and. AGRRETCTXT(cAlias, aStruct[nX,1]) # "V"
			Aadd(aAHeader,{Trim(RetTitle(aStruct[nX,1])),;
			aStruct[nX,1],;
			X3PICTURE(aStruct[nX,1]),;
			aStruct[nX,3],;
			aStruct[nX,4],;
			.T.,;
			"",;
			aStruct[nX,2],;
			"",;
			"" })
		EndIf
		DbSkip()

	Next nX

	RestArea(aArea)
Return(aAHeader)

/**---------------------------------------------------------------------
{Protheus.doc} A650VLDOK
Validação da confirmação da tela de inclusão e exclusão de fardos

@param: 	oBrowse - Browse da rotina
@param: 	nOpc - Operação da Rotina 1=Incluir Fardos; 2= Excluir Fardos
@author: 	Aecio Ferreira Gomes
@since: 	28/12/2012
@Uso: 		Generico
---------------------------------------------------------------------**/
Static Function A650VLDOK(oBrowse, nOpc)
	Local lRet		:= .T.
	Local nCont 	:= 0
	Local nQtdVinc  := AGRA650QTD() // Quantidade de fardos vinculados
	Local nX		:= 0

	If nOpc == 1
		//--------------------------------------
		// Soma a quantidade de fardos marcados
		//--------------------------------------
		For nX:= 1 To Len(oBrowse:aCols)
			If oBrowse:aCols[nX,1]:CNAME == "LBNO"
				Loop
			EndIf
			nCont ++
		Next nX

		//-------------------------------------
		// Valida a capacidade máxima do bloco
		//-------------------------------------
		If (nQtdVinc+nCont) > DXD->DXD_QTDMAX
			Help(,,STR0023,, STR0024,1,0) //"Capacidade Máxima"###"A quantidade de fardos marcados superou a capacidade máxima do bloco"
			lRet := .F.
		EndIf
	EndIf
Return lRet

/**---------------------------------------------------------------------
{Protheus.doc} AGRGrvBlc
Atualiza tabela de dados dos itens Blocados

@param: oBrw - Browse da rotina
@param: nOpc - Operação da Rotina 1=Incluir Fardos; 2=Excluir Fardos
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function AGRGrvBlc(oBrw, nOpc)
	Local aAreaDXI	:= DXI->(GetArea())
	Local aHeader	:= oBrw:aHeader
	Local aCols		:= oBrw:aCols
	Local nX		:= 0
	Local nPosEtiq	:= aScan(aHeader, {|x| Alltrim(x[2]) == "DXI_ETIQ"})
	Local nPosSafra	:= aScan(aHeader, {|x| Alltrim(x[2]) == "DXI_SAFRA"})
	Local cFdIni    := ""
	Local cFdFin	:= ""
	Local cAliasQry	:= ""
	Local cQry		:= ""
	Local cBloco	:= ""

	//-------------------------------------------
	// Faz o relacionamento entre o bloco e fardo
	//-------------------------------------------
	DXI->(dbSetOrder(1))
	For nX:= 1 To Len(aCols)
		If aCols[nX,1]:CNAME == "LBNO"
			Loop
		EndIf
		If DXI->(dbSeek(xFilial("DXI")+aCols[nX,nPosSafra]+aCols[nX,nPosEtiq]))
			RecLock("DXI", .F.)

			cBloco := If(nOpc == 1,DXD->DXD_CODIGO,CriaVar("DXI_BLOCO",.F.) )

			If DXI->(ColumnPos("DXI_DATATU")) > 0
				// Caso modifique o bloco do fardo, atualiza a data de alteração para alterar o fardo
				// no aplicativo do Beneficiamento					
				If DXI->DXI_BLOCO != cBloco
					DXI->DXI_DATATU := dDatabase
					DXI->DXI_HORATU := Time()
				EndIf
			endIf

			DXI->DXI_BLOCO := cBloco 			
			
			If DXI->(ColumnPos("DXI_STATUS")) > 0
				IF nOpc == 1
					DXI->DXI_STATUS := "30"
				ELSEIF nOpc == 2
					IF DXI->DXI_STATUS = "30"
						DXI->DXI_STATUS := "20"
					ENDIF
				ENDIF
			endIf

			if DXI->(ColumnPos("DXI_CODREG")) > 0
				DXI->DXI_CODREG := If(nOpc == 2,"",DXD->DXD_CODREG )
				DXI->DXI_TIPEMB := If(nOpc == 2,"",DXD->DXD_TIPEMB )
			endIf

			MsUnlock()
		EndIf
	Next nX

	if DXD->(ColumnPos("DXD_FDINI")) > 0
		cAliasQry := GetNextAlias()
		cQry := "SELECT MIN(DXI.DXI_CODIGO) AS FDINI "
		cQry += "  FROM "+ RetSqlName("DXI") + " DXI "
		cQry += " WHERE	DXI.DXI_FILIAL 	= 	'"+xFilial("DXI")+"' "
		cQry += "   AND	DXI.DXI_BLOCO 	= 	'" + DXD->DXD_CODIGO + "' "
		cQry += "   AND	DXI.DXI_SAFRA 	= 	'" + DXD->DXD_SAFRA + "' "

		If !Empty(DXD->DXD_CODUNB)
			cQry += "AND DXI.DXI_CODUNB = '"+DXD->DXD_CODUNB+"' "
		Endif

		cQry += "   AND	DXI.D_E_L_E_T_ 	= '' "

		cQry := ChangeQuery( cQry )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		If !(cAliasQry)->(Eof())
			cFdIni := (cAliasQry)->FDINI
		EndIf

		cAliasQry := GetNextAlias()
		cQry := "SELECT MAX(DXI.DXI_CODIGO) AS FDFIN "
		cQry += "  FROM "+ RetSqlName("DXI") + " DXI "
		cQry += " WHERE	DXI.DXI_FILIAL 	= 	'"+xFilial("DXI")+"' "
		cQry += "   AND	DXI.DXI_BLOCO 	= 	'" + DXD->DXD_CODIGO + "' "
		cQry += "   AND	DXI.DXI_SAFRA 	= 	'" + DXD->DXD_SAFRA + "' "

		If !Empty(DXD->DXD_CODUNB)
			cQry += "AND DXI.DXI_CODUNB = '"+DXD->DXD_CODUNB+"' "
		Endif

		cQry += "   AND	DXI.D_E_L_E_T_ 	= '' "

		cQry := ChangeQuery( cQry )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		If !(cAliasQry)->(Eof())
			cFdFin := (cAliasQry)->FDFIN
		EndIf
	endIf

	//-------------------------------------------
	// Atualiza a quantidade de fardos do bloco
	//-------------------------------------------
	RecLock("DXD",.F.)
	DXD->DXD_QTDVNC := AGRA650QTD()

	if DXD->(ColumnPos("DXD_FDINI")) > 0 .AND. DXD->(ColumnPos("DXD_STATUS")) > 0
		DXD->DXD_FDINI  := cFdIni
		DXD->DXD_FDFIN  := cFdFin
	
		if DXD->DXD_QTDVNC = 0
			// Atualiza a data e hora de alteração para excluir o bloco no aplicativo do Beneficiamento
			// Apenas quando o status for 3 - Finalizado, pois o bloco estará no app apenas neste caso
			If DXD->DXD_STATUS == "3"
				DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()
			EndIf
	
			DXD->DXD_STATUS := "1"
		elseif DXD->DXD_QTDVNC < DXD->DXD_QTDMAX
			// Atualiza a data e hora de alteração para excluir o bloco no aplicativo do Beneficiamento
			// Apenas quando o status for 3 - Finalizado, pois o bloco estará no app apenas neste caso	
			If DXD->DXD_STATUS == "3"
				DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()
			EndIf
	
			DXD->DXD_STATUS := "2"
		elseif DXD->DXD_QTDVNC = DXD->DXD_QTDMAX
			DXD->DXD_STATUS := "3"	
	
			// Atualiza a data e hora de alteração para altear/incluir o bloco no aplicativo do Beneficiamento			
			DXD->DXD_DATATU	:= dDatabase
			DXD->DXD_HORATU := Time()		
		endIf
	endIf

	DXD->(MsUnlock())

	RestArea(aAreaDXI)
Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRMTACOLS
Carrega aCols

@param: oBrowse - Browse da rotina
@param: cAlias - Arquivo temporario com os dados filtrados
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function AGRMTACOLS(oBrowse, cAlias)
	Local aHeader	:= oBrowse:aHeader
	Local aCols		:= {}
	Local aArea		:= GetArea()
	Local nI, nLen	:= 0
	Local oVerde	:= LoadBitmap( GetResources(), "br_verde_ocean" )
	Local oVermelho	:= LoadBitmap( GetResources(), "br_vermelho_ocean" )

	While (cAlias)->(!Eof())

		AADD(aCols,Array(Len(aHeader)+1))
		nLen := Len(aCols)

		For nI:= 1 To Len(aHeader)
			If aHeader[nI,2] == "MARCA"
				aCols[nLen,nI] := oNo
			ElseIf aHeader[nI,2] == "LEG"
				aCols[nLen,nI] := If(Empty((cAlias)->DXI_CODRES),oVerde,oVermelho)
			Else
				aCols[nLen,nI] := (cAlias)->&(aHeader[nI,2])
			EndIf
		Next nI
		aCols[nLen][Len(aCols[nLen])]:= .F.

		(cAlias)->(DbSkip())
	End

	oBrowse:SetArray(aCols)
	oBrowse:Refresh()
	RestArea(aArea)
	(cAlias)->(DbCloseArea())
Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRA650QTD
Retorna a quantidade de fardos pertencentes ao bloco

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Function AGRA650QTD()
	Local cAliasQry := GetNextAlias()
	Local cQry 		:= ""
	Local nRet      := 0
	Local aArea 	:= GetArea()

	cQry := "SELECT COUNT(DISTINCT DXI_ETIQ) TOTAL "
	cQry += "FROM " + RetSqlName("DXI") + " DXI "
	cQry += "WHERE DXI.DXI_FILIAL = '"+xFilial("DXI")+"' "
	cQry += "AND DXI.DXI_SAFRA = '"+DXD->DXD_SAFRA+"' "
	cQry += "AND DXI.DXI_BLOCO = '"+DXD->DXD_CODIGO+"' "
	If !Empty(DXD->DXD_CODUNB)
		cQry += "AND DXI.DXI_CODUNB = '"+DXD->DXD_CODUNB+"' "
	Endif
	cQry += "AND DXI.D_E_L_E_T_ = ''"

	cQry := ChangeQuery( cQry )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	nRet:= (cAliasQry)->TOTAL

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
Return(nRet)

/**---------------------------------------------------------------------
{Protheus.doc} MarcaTudo
Marca/Desmaca Todos

@param: lMark - Indica se marca ou desmarca tudo
@param: oBrw - Browser da Rotina
@param: nOpc - Operação da Rotina 1=Incluir Fardos; 2= Excluir Fardos
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function MarcaTudo(lMark, oBrw, nOpc)
	Local nPosEtiq	:= aScan(oBrw:aHeader, {|x| Alltrim(x[2]) == "DXI_ETIQ"})
	Local nPosSafra	:= aScan(oBrw:aHeader, {|x| Alltrim(x[2]) == "DXI_SAFRA"})
	Local nX 		:= 0

	For nX := 1 To Len(oBrw:aCols)
		If lMark
			// ------------------------------------------------------------------
			// Caso o fardo esteja reserva para um contrato não pode ser marcado
			// ------------------------------------------------------------------
			If nOpc == 2 .And. DXI->(dbSeek(xFilial("DXI")+oBrw:aCols[nX,nPosSafra]+oBrw:aCols[nX,nPosEtiq]))
				If !Empty(DXI->DXI_CODRES)
					Loop
				Endif
			EndIf

			oBrw:aCols[nX,1] := oOK
		Else
			oBrw:aCols[nX,1] := oNo
		EndIf
	Next nX

	oBrw:ForceRefresh()
Return

/**---------------------------------------------------------------------
{Protheus.doc} MarcaUm
Marca/Desmarca posicionado

@param: oBrw - Browser da Rotina
@param: nOpc - Operação da Rotina 1=Incluir Fardos; 2= Excluir Fardos
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA650
---------------------------------------------------------------------**/
Static Function MarcaUm(oBrw, nOpc)
	Local lRet		:= .T.
	Local nPosEtiq	:= aScan(oBrw:aHeader, {|x| Alltrim(x[2]) == "DXI_ETIQ"})
	Local nPosSafra	:= aScan(oBrw:aHeader, {|x| Alltrim(x[2]) == "DXI_SAFRA"})

	If oBrw:ACOLS[oBrw:NAT,1]:CNAME == "LBNO"

		If nOpc == 2 .And. DXI->(dbSeek(xFilial("DXI")+oBrw:aCols[oBrw:NAT,nPosSafra]+oBrw:aCols[oBrw:NAT,nPosEtiq]))
			If !Empty(DXI->DXI_CODRES)
				Help(,,STR0014,, STR0025,1,0) //"Atenção"###"Este Fardo está reservado para um contrato e não pode ser excluido do Bloco"
				lRet := .F.
			Endif
		EndIf

		If lRet
			oBrw:ACols[oBrw:NAT,1] := oOK
		EndIf
	Else
		oBrw:ACols[oBrw:NAT,1] := oNo
	EndIf

	oBrw:Refresh()
Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRA650PRc
Prepara a chamada da função de reclassificação dos fardos

@param: 	Nil
@author: 	Daniel Maniglia A. Silva
@since: 	08/06/2010
@Uso: 		Generico
---------------------------------------------------------------------**/
Function AGRA650PRc
	Local cOldCla	:= DXD->DXD_CLACOM
	Local cCodigo	:= DXD->DXD_CODIGO
	Local cSafra	:= DXD->DXD_SAFRA
	Local cCodUnb	:= DXD->DXD_CODUNB
	Local cFilOrg	:= xFilial("DXI")

	AGRA650RCL(cFilOrg,cOldCla,,,cCodigo,cSafra,cCodUnb,,.F.)
Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRA650RCL
Reclassificação comercial do bloco

@param: 	cOldCla -> Classificação atual
cCodDXP -> Código da Reserva
cCodDXD -> Código do Bloco
cSafra  -> Safra
cCodUnb -> Código UNB
cStatus -> Status atual do takeup (aprovado ou aguardando aprovação)
lTakeUp -> Se a chamada da função de reclassificação esta sendo feita no TAKEUP
@author: 	Aecio Gomes
@since: 	08/06/2010
@Uso: 		Generico
---------------------------------------------------------------------**/
Function AGRA650RCL(cFilOrg,cOldCla,cCodDXP,cItemRes, cCodDXD,cSafra,cCodUnb,cStatus,lTakeUp)
	Local nOpcX		:= 0
	Local cNewCla	:= Space(TamSX3("DXD_CLACOM")[1])
	Local lRet		:= .T.
	Local nTotFdos	:= 0
	Local cQry		:= ""
	Local cAliasQry := GetNextAlias()

	Default lTakeUp := .F. //identifica se a chamada da função AGRA650RCL foi realizada pelo
	//AGRA720- Agenda de Take-UP

	cQry := "SELECT COUNT(DISTINCT DXI_ETIQ) QTD "
	cQry += "FROM " + RetSqlName("DXI") + " DXI "
	cQry += "WHERE DXI_FILIAL = '"+cFilOrg+"' "
	cQry += "AND DXI_BLOCO 	= 	'"+cCodDXD+"' "
	cQry += "AND DXI_SAFRA 	= 	'"+cSafra+"' "
	cQry += "AND DXI_CODUNB	= 	'"+cCodUnb+"' "
	If lTakeUp
		cQry += "AND DXI_CODRES <> 	'' AND DXI_CODRES <> '"+cCodDXP+"' " //deve desconsiderar a reserva que está sendo "takeupada"
	Else
		cQry += "AND DXI_CODRES <> 	'' "
	EndIf
	cQry += "AND D_E_L_E_T_ = 	''"

	cQry := ChangeQuery( cQry )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	If (cAliasQry)->QTD	 > 0
		Help( , , STR0014, , STR0026, 1, 0 ) //"Atenção"###"Este bloco não pode ser reclassificado pois existem fardos pertencentes ao bloco reservados para um contrato"
		lRet := .F.
	EndIf

	If lTakeUp .AND. cStatus == "2" //takeup já aprovado
		Help( , , STR0014, , STR0046, 1, 0 ) //"Atenção"###"Este bloco não pode ser reclassificado pois o TakeUp já está aprovado"
		lRet := .F.
	EndIf

	If lRet
		oDlg 	:= TDialog():New( 0, 0, 140, 240, STR0027,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Reclassificação dos Fardos"

		oSay1 	:= TSay():New( 10, 05, { || STR0028 }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 80, 09 ) //"Classificação Atual: "
		oGet1	:= TGet():New( 10, 80, bSetGet( cOldCla ), oDlg, 30, 009, PesqPict( "DXD", "DXD_CLACOM" ) ,{|| .t. },,,,,, .t.,,, {|| .f. },,, {|| },,, "DXA" )
		oSay2 	:= TSay():New( 25, 05, { || STR0029 }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 80, 09 ) //"Digite Nova Classificação: "
		oGet2	:= TGet():New( 25, 80, bSetGet( cNewCla ), oDlg, 30, 009, PesqPict( "DXD", "DXD_CLACOM" ) ,{|| Vazio() .Or. ExistCpo( "DXA", cNewCla) },,,,,, .t.,,, {|| .T.},,,{|| },,, "DXA" )

		oTButt1 := TButton():New( 50, 020, STR0030 , oDlg, { || nOpcX := 1, oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirmar"
		oTButt2 := TButton():New( 50, 070, STR0031  , oDlg, { || nOpcX := 0, oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Cancelar"

		oDlg:Activate( , , , .t. ,{|| ( ( nOpcX==1 .And. .Not. Empty( cNewCla ) .And. cNewCla <> cOldCla .AND. (ExistCpo( "DXA", cNewCla )) ) .Or. nOpcX==0 ) }, , { ||                    } )

		If nOpcX == 1

			BEGIN TRANSACTION

				DXI->( dbSetOrder( 4 ) )
				If DXI->( dbSeek( cFilOrg + cSafra + cCodDXD ))

					While DXI->(!Eof() .And. DXI_FILIAL+DXI_BLOCO == cFilOrg+ cCodDXD .And. DXI_SAFRA = cSafra)

						If lTakeUp
							If Empty( DXI->DXI_CODRES ) .OR. DXI->DXI_CODRES == cCodDXP
								RecLock( "DXI", .F. )
								DXI->DXI_CLACOM := cNewCla
								DXI->(MsUnLock())
							EndIf
						Else
							If Empty( DXI->DXI_CODRES )
								RecLock( "DXI", .F. )
								DXI->DXI_CLACOM := cNewCla
								DXI->(MsUnLock())
								nTotFdos++
							Else
								DisarmTransaction()
							EndIf
						EndIF

						DXI->( dbSkip() )
					EndDo
					If .NOT. lTakeUp
						MsgInfo( "[ " + Transform( nTotFdos, PesqPict( "DXD", "DXD_QTDVNC" ) ) + STR0032, STR0045 ) //" ] fardos foram Recalssificados ..."###"Reclassificação de Fardos"
					EndIf
				EndIf

				If lTakeUp //se chamada no takeup, deve posicionar na DXD
					DbSelectArea("DXD")
					DbSetOrder(1)
					DXD->( dbSeek(cFilOrg + cSafra + cCodDXD) )
				EndIF

				RecLock( "DXD", .F. )
				DXD->DXD_CLACOM := cNewCla
				DXD->(MsUnLock())

				If lTakeUp //caso tenha que atualizar o takeup

					//Atatualiza a DXQ - Itens da reserva
					DXQ->( dbSetOrder( 1 ) )
					If DXQ->( dbSeek( cFilOrg + cCodDXP + cItemRes))
						RecLock( "DXQ", .F. )
						DXQ->DXQ_TIPO := cNewCla
						DXQ->(MsUnLock())
						DXQ->( dbSkip() )

					EndIf
				EndIf
			END TRANSACTION()
		EndIf
	EndIf

Return

/**---------------------------------------------------------------------
{Protheus.doc} AGRA650CPO
Validação de campos

@author: Aecio Ferreira Gomes
@since: 02/05/2013
@Uso: AGRA650
---------------------------------------------------------------------**/
Function AGRA650CPO()
	Local oModel   := FwModelActive()
	Local lRet		:= .T.
	Local aArea		:= GetArea()

	Do Case
	CASE "DXD_SAFRA" $ ReadVar()
		if TamSX3("DXD_SAFRA")[1] = 6
			lRet := Vazio() .Or. ExistCPO("NN1")
		else
			lRet := Vazio() .Or. ExistCPO("NJU")
		endif

		If lRet .And. DXD->(ColumnPos("DXD_CODUNI")) > 0
			//montagem e atribuição do código único
			If Alltrim(oModel:GetValue("CABEC","DXD_SAFRA")) != "" .And. Alltrim(oModel:GetValue("CABEC","DXD_CODIGO")) != ""
				oModel:LoadValue("CABEC","DXD_CODUNI",AGRCodeUni("DXD", oModel:GetValue("CABEC","DXD_SAFRA"), oModel:GetValue("CABEC","DXD_CODIGO"), "BL"))
			Else
				oModel:LoadValue("CABEC","DXD_CODUNI","")
			EndIf
		EndIf

	CASE "DXD_CODVAR" $ ReadVar()
		If !Empty(M->DXD_CODVAR)
			if TamSX3("DXD_SAFRA")[1] = 6
				dbSelectArea("NN1")
				lRet := ExistCPO("NNV", Posicione("NN1",1,xFilial("NN1")+M->DXD_SAFRA,"NN1_CODPRO")+M->DXD_CODVAR,1)
			else
				lRet := ExistCPO("NNV", M->DXD_CODVAR,2)
			endIf
		EndIf

	CASE "DXD_CODIGO" $ ReadVar()
		lRet := ExistChav("DXD", M->DXD_SAFRA+M->DXD_CODIGO,1,"EXISTCHAV")

		If lRet .And. DXD->(ColumnPos("DXD_CODUNI")) > 0
			//montagem e atribuição do código único
			If Alltrim(oModel:GetValue("CABEC","DXD_SAFRA")) != "" .And. Alltrim(oModel:GetValue("CABEC","DXD_CODIGO")) != ""
				oModel:LoadValue("CABEC","DXD_CODUNI",AGRCodeUni("DXD", oModel:GetValue("CABEC","DXD_SAFRA"), oModel:GetValue("CABEC","DXD_CODIGO"), "BL"))
			Else
				oModel:LoadValue("CABEC","DXD_CODUNI","")
			EndIf
		EndIf

	EndCase

	RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} AGRA650PRE
//Função de pré-modelo
@author bruna.rocio
@since 14/03/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRA650PRE(oModel)
	Local nOperac := oModel:GetOperation()
	Local lRet    := .T.

	__cUserBenf := A655GETUNB()

	//Campo Unidade de Beneficiamento
	If nOperac == MODEL_OPERATION_INSERT .And. !Empty(__cUserBenf)
		oModel:loadValue( "CABEC", "DXD_CODUNB", __cUserBenf )
	Endif
Return lRet

/*{Protheus.doc} AGRA650GRV
//Função para salvar os dados do bloco

@author bruna.rocio
@since 26/06/2018
@version undefined
@param oModel, object, descricao
@type function
*/
Static Function AGRA650GRV(oModel)
	Local nOperation := oModel:GetOperation()
	Local oModelDXD	 := oModel:GetModel('CABEC')
	Local lRet    	 := .T.
	Local cStatus	 := ""

	If nOperation = MODEL_OPERATION_INSERT .AND. oModelDXD:GetValue("DXD_STATUS") == "3"

		// Caso a operação seja de inserção e o bloco estiver com status "3 - Finalizado",
		// grava a data e hora de inserção, pois o aplicativo do Beneficiamento apenas considera os
		// blocos com status 3 - Finalizado
		oModelDXD:SetValue('DXD_DATATU', dDatabase)
		oModelDXD:SetValue('DXD_HORATU', Time())

	ElseIf nOperation = MODEL_OPERATION_UPDATE .AND. oModelDXD:IsModified()

		// Caso a operação seja de atualização, verifica se atualizou algum campo na DXD no model
		// E também se o status do bloco era "3 - Finalizado"
		// Apenas é gravado a data e hora de atualização nesta situação, pois apenas nesta situação (status 3 - Finalizado)
		// o aplicativo do Beneficiamento poderá conter o bloco e precisará ser atualizado
		aAreaDXD := DXD->(GetArea())

		DbSelectArea("DXD")
		DXD->(DbSetOrder(1)) // DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
		If DXD->(DbSeek(FWxFilial("DXD")+oModelDXD:GetValue("DXD_SAFRA")+oModelDXD:GetValue("DXD_CODIGO")))
			cStatus := DXD->DXD_STATUS
		EndIf

		RestArea(aAreaDXD)

		If cStatus == "3"
			oModelDXD:SetValue('DXD_DATATU', dDatabase)
			oModelDXD:SetValue('DXD_HORATU', Time())
		EndIf

		If cStatus == "2" .and. oModelDXD:GetValue("DXD_QTDVNC") > 0 .and. oModelDXD:GetValue("DXD_QTDMAX") = oModelDXD:GetValue("DXD_QTDVNC")
			oModelDXD:SetValue('DXD_STATUS', "3")
			oModelDXD:SetValue('DXD_DATATU', dDatabase)
			oModelDXD:SetValue('DXD_HORATU', Time())
		ElseIf oModelDXD:GetValue("DXD_QTDVNC") > 0 .and. oModelDXD:GetValue("DXD_QTDMAX") > oModelDXD:GetValue("DXD_QTDVNC")
			oModelDXD:SetValue('DXD_STATUS', "2")
		EndIf

	EndIf

	FWFormCommit(oModel)

Return lRet


/*/{Protheus.doc} AGRA650BLR
//Essa função passa filtro feito no browse para relatório de etiquetas
@author marina.muller / carlos.augusto
@since 23/10/2017
@version 6
@return ${return}, ${return_description}

@type function
/*/
Function AGRA650BLR()
	AGRAR650A(oBrowse:FWFilter():GetFilter())

Return .T.

/*/{Protheus.doc} AGRA650BLT
//Essa função passa filtro feito no browse para relatório de blocos
@author marina.muller
@since 23/10/2017
@version 6
@return ${return}, ${return_description}

@type function
/*/
Function AGRA650BLT()
	AGRAR650B(,,,oBrowse:FWFilter():GetFilter())

Return .T.

/*/{Protheus.doc} A650FchBl
//Função para fechar um bloco manualmente
@author silvana.torres
@since 22/01/2018
@version undefined

@type function
/*/
Function A650FchBl()

	If DXD->DXD_STATUS == "2"

		//#O bloco não atingiu a capacidade máxima. Deseja fechá-lo?##Atenção
		If AGRGRAVAHIS(STR0051,"DXD",DXD_FILIAL+DXD_SAFRA+DXD_CODIGO,"F") = 1
			If RecLock( "DXD", .F. )
				DXD->( DXD_STATUS ) := "3"

				// Atualiza a data e hora de alteração para alterar/incluir o bloco no aplicativo do Beneficiamento
				DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()

				DXD->( MsUnLock() )
			EndIf

		EndIf
	Else
		Help("",1,STR0014,, STR0052,1,0)//#Atenção##Só é permitido fechar malas com status Iniciado!
	EndIf

Return .T.

/*/{Protheus.doc} A650EmblFis
Função para emblocar fisicamente
@author silvana.torres
@since 20/08/2018
@version undefined

@type function
/*/
Function A650EmblFis()


	If DXD->DXD_STATUS == "3" //Finalizado

		If MsgYesNo(STR0055 + DXD->DXD_CODIGO + STR0056, STR0057)//"Essa rotina atualizará os fardos contidos no bloco " //" de modo que o sistema entenda que estes já foram movidos fisicamente. Deseja continuar?"//"Emblocamento Físico"

			If RecLock( "DXD", .F. )
				DXD->( DXD_STATUS ) := "4"

				// Atualiza a data e hora de alteração para excluir o bloco no aplicativo do Beneficiamento
				DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()

				DXD->( MsUnLock() )

				DXI->(dbSelectArea('DXI'))
				DXI->(dbSetOrder(4))
				If DXI->(MsSeek(FWxFilial("DXI")+DXD->DXD_SAFRA+DXD->DXD_CODIGO))

					While .Not. DXI->( Eof() ) .And.;
							DXI->( DXI_FILIAL ) == FWxFilial("DXI")    .And. ;
							DXI->( DXI_SAFRA)   == DXD->DXD_SAFRA   	.And. ;
							DXI->( DXI_BLOCO)   == DXD->DXD_CODIGO

						If RecLock( "DXI", .F. )
							DXI->DXI_EMBFIS := '1' //SIM

							// Atualiza a data e hora de alteração para excluir o fardo no aplicativo do Beneficiamento
							DXI->DXI_DATATU := dDatabase
							DXI->DXI_HORATU := Time()

							DXI->(msUnLock())
						EndIf
						DXI->(dbSkip())
					EndDo
				EndIF
				DXI->(dbCloseArea())
			EndIf

		EndIf
	Else
		Help("",1,STR0014,, STR0058,1,0)//#Atenção##Só é permitido emblocar fisicamente blocos com status Finalizado!
	EndIf

Return .T.

/*/{Protheus.doc} A650HistBl
//Apresenta o histórico do Bloco
@author silvana.torres
@since 22/01/2018
@version undefined

@type function
/*/
Function A650HistBl()

	Local cChaveI := "DXD->("+Alltrim(AGRSEEKDIC("SIX","DXD1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("DXD",cChaveA)
Return
