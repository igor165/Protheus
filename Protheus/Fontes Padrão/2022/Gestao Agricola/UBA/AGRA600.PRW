#INCLUDE "AGRA600.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "PARMTYPE.ch"

Static aPerBal
Static lTransf

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600
Romaneio de entrada
@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: GENERICO
@type function
------------------------------------------------------------------------------------------ **/
Function AGRA600()
	Local oBrowse := Nil
	Local bKeyF11 := { || aPerBal := AGRX003E( .T., "AGRA60001" ) }
	Local bKeyF12 := { || Pergunte('AGRA60002', .T.) }

	Private lTRFA600  	:= .F.
	Private cUserBenf 	:= A655GETUNB()// Busca a unidade de beneficiamento
	Private __lNovSafra 	:= .T.

	if TamSX3("DXM_SAFRA")[1] = 6
		__lNovSafra := .F.
	endIf

	If aPerBal == Nil
		aPerBal := AGRX003E( .F., "AGRA60001" )
	Endif

	//---------------
	//Seta tecla F11
	//---------------
	SetKey( VK_F11, bKeyF11 )

	//---------------
	//Seta tecla F12
	//---------------
	SetKey( VK_F12, bKeyF12 )

	//------------------------------
	//Instacia o objeto do browser
	//------------------------------
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DXM')
	oBrowse:SetDescription( STR0001 )  //"Romaneio de entrada"
	If !Empty(cUserBenf)
		oBrowse:SetFilterDefault( " DXM_CODUNB == '" + cUserBenf + "' " )
	Endif

	//------------------
	//Adiciona lengedas
	//------------------
	oBrowse:AddLegend( "DXM->DXM_STATUS == '1'"	,"YELLOW"	, OemToAnsi( STR0002 ) ) //"Em Aberto"
	oBrowse:AddLegend( "DXM->DXM_STATUS == '2'"	,"RED"		, OemToAnsi( STR0003 ) ) //"Encerrado"
	oBrowse:AddLegend( "DXM->DXM_STATUS == '3'"	,"BLACK"	, OemToAnsi( STR0004 ) ) //"Cancelado"

	//----------------
	//Ativa o Browser
	//----------------
	oBrowse:Activate()

	//-------------------------------
	//Retira ação da tecla F11 e F12
	//-------------------------------
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)
Return

/** ------------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina
@param: Nil
@author: Equipe Agroindustria
@since: 08/11/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGRA600' 	OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.AGRA600' 	OPERATION 3  ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.AGRA600' 	OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0008 Action 'AGRA600E'		 	OPERATION 7  ACCESS 0 //"Encerrar"
	ADD OPTION aRotina Title STR0009 Action 'AGRA600C'			OPERATION 9  ACCESS 0 //"Cancelar"
	ADD OPTION aRotina Title STR0010 Action 'AGRAR600'		 	OPERATION 8  ACCESS 0 //"Imprimir"
	ADD OPTION aRotina Title STR0040 Action 'AGRA602'		 	OPERATION 4  ACCESS 0 //"Complemento"
	ADD OPTION aRotina Title STR0049 Action 'AGRA600T'          OPERATION 10 ACCESS 0 //"Transferencia"
	If ExistBlock('AG600MNU')
		aRet := ExecBlock('AG600MNU',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf	
Return aRotina

/** ------------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Menu Padrao da Rotina

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXM 	:= FwFormStruct( 1, "DXM" ) // Romaneio de entrada
	Local oStruDX0 	:= FwFormStruct( 1, "DX0" ) // Itens do Romaneio de Entrada
	
	//-----------------------------------
	// Instancia o modelo de dados 
	//-----------------------------------

	oStruDXM:AddField(/*cTitulo*/'Rom Orig.',;
	/*cTooltip*/ 'Romaneio de Origem',;
	/*cIdField*/'DXM_ROMORI',;
	/*cTipo*/'C',;
	/*nTamanho*/6,;
	/*nDecimal*/0,;
	/*bValid*/ ,;
	/*bWhen*/{||INCLUI},;
	/*aValues*/,;
	/*lObrigat*/ .F.,;
	/*bInit*/,;
	/*lKey*/,;
	/*lNoUpd */,;
	/*lVirtual */ .T.)

	If GetRpoRelease() <= "12.1.2210" //apos a release P12.1.2210 o ajuste deverá estar no dicionario SX7
		oStruDX0:AddTrigger( "DX0_FARDAO", "DX0_CODPRO", { || .t. }, { | oStr | fTrgDXOFrd( oStr ) } )
		oStruDX0:SetProperty("DX0_FAZ" , MODEL_FIELD_WHEN, { || .T. }) 
	EndIf

	oModel:= MPFormModel():New( 'AGRA600',/*PreModelo*/,{|oMdl| AGRA600POS(oMdl)},{ |oMdl| AGRA600GRV( oMdl ) }, /*bCancel*/ )
	oModel:SetDescription( STR0011 ) //"Modelo de dados do Romaneio de Entrada"
	
	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldDXM', /*cOwner*/, oStruDXM )
	oModel:GetModel( 'MdFieldDXM' ):SetDescription( STR0012 ) //"Dados do Romaneio de Entrada"


	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid( 'MdGridDX0', 'MdFieldDXM', oStruDX0, ,{|oMdGrid| AGRA600LOK(oMdGrid)} )
	oModel:GetModel( 'MdGridDX0' ):SetDescription( STR0013 ) //"Dados dos Itens do Romaneio de entrada"

	//-------------------------------------
	// Seta linha unica da grid
	//-------------------------------------
	oModel:GetModel( 'MdGridDX0' ):SetUniqueLine( {'DX0_FARDAO'} )

	//-------------------------------------
	// Seta preenchimento opcional da Grid
	//-------------------------------------
	oModel:GetModel( "MdGridDX0" ):SetOptional( .T. )

	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGridDX0', { { 'DX0_FILIAL', 'fwxFilial( "DX0" )' }, { 'DX0_CODROM', 'DXM_CODIGO' }})

	//-------------------------------------
	// Valida a ativação do model
	//-------------------------------------
	oModel:SetVldActivate( { |oModel| A600VLDACT( oModel ) } )

	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate( { |oModel| A600ACTIVE( oModel ) } )
Return oModel

/*/{Protheus.doc} fTrgDXOFrd
Função de gatilho para campos release P12.1.033 e P12.1.2210 em substituição gatilho dicionario com erro
@type function
@version P12
@author claudineia.reinert
@since 06/06/2022
@param oStrModel, object, Objeto do modelo
@return Character, Valor do campo
/*/
Static Function fTrgDXOFrd( oStrModel, cCampo )
	Local oModel	:= oStrModel:GetModel()
	Local oGridDXM	:= oModel:GetModel( "MdFieldDXM" )
	Local oGridDX0	:= oModel:GetModel( "MdGridDX0" )
	Local cRet		:= ""
	
	If !Empty(oGridDX0:GetValue( "DX0_FARDAO" ))
		dbselectarea("DXL")
		DXL->(dbSelectArea("DXL"))
		DXL->(dbSetOrder(1))
		If DXL->(DBSeek(FwxFilial("NJJ")+oGridDX0:GetValue("DX0_FARDAO")+oGridDXM:GetValue("DXM_SAFRA")+oGridDXM:GetValue("DXM_PRDTOR")+oGridDXM:GetValue("DXM_LJPRO")+oGridDXM:GetValue("DXM_FAZ")))
			//usa valores da DXM para filtrar pois valor dos campos na DX0 ainda não foram preenchidos, e há validação na consulta do fardão para buscar fardões para a safra, produtor e fazenda da DXM
			oGridDX0:SetValue("DX0_CODPRO",	DXL->DXL_CODPRO)
			oGridDX0:SetValue("DX0_TALHAO" ,	DXL->DXL_TALHAO)
			oGridDX0:SetValue("DX0_CODVAR" ,	DXL->DXL_CODVAR)
			oGridDX0:SetValue("DX0_FAZ"    ,	DXL->DXL_FAZ)
			If GetRpoRelease() >= "12.1.033"				
				oGridDX0:SetValue("DX0_SAFRA",	DXL->DXL_SAFRA)
				oGridDX0:SetValue("DX0_PRDTOR",	DXL->DXL_PRDTOR)
				oGridDX0:SetValue("DX0_LOJA"  ,	DXL->DXL_LJPRO)
			EndIF
			
			cRet := DXL->DXL_CODPRO
		EndIf
	
	EndIf	

Return cRet

/*/{Protheus.doc} AGRA600X71
Função de retorno do valor X7_CHAVE do gatilho do campo DX0_FARDAO no dicionario SX7, a partir da release 12.1.2310
@type function
@version P12
@author claudineia.reinert
@since 06/06/2022
@return Character, Valor do campo
/*/
Function AGRA600X71()
	//monta a chave seguindo filtro A600FDFLTR que consta na consulta do campo DX0_FARDAO
	Local cChave := FwxFilial("DXL")+FwFldGet("DX0_FARDAO")+FwFldGet("DXM_SAFRA")+FwFldGet("DXM_PRDTOR")+FwFldGet("DXM_LJPRO")+FwFldGet("DXM_FAZ")
			
Return cChave

/** ------------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Menu Padrao da Rotina

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA600" )
	Local oStruDXM 	:= FwFormStruct( 2, "DXM" , {|cCampo| !(cCampo $ "DXM_STATUS") }) // Romaneio de entrada
	Local oStruDX0 	:= FwFormStruct( 2, "DX0" , {|cCampo| !(cCampo $ "DX0_CODROM|DX0_TIPROM|DX0_CODUNI|DX0_NRROM ") }) // Itens do Romaneio de entrada
	Local cOrdem    

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
	oView:AddField( 'VIEW_DXM', oStruDXM, 'MdFieldDXM' )

	If !IsInCallStack('AGRA600T')	

		if __lNovSafra
			cOrdem := '06'
		else		
			cOrdem := '05'
		endIf

		oStruDXM:AddField(/*cIdField*/"DXM_ROMORI",;
		/*cOrdem*/cOrdem,;
		/*cTitulo*/'Rom Orig.',;
		/*cDescric*/'Romaneio Origem',;
		/*aHelp*/,;
		/*cType*/"Get",;
		/*cPicture*/"@!",;
		/*bPictVar*/,;
		/*cLookUp*/'DXMORI',;
		/*lCanChange*/.T.,;
		/*cFolder*/,;
		/*cGroup*/,;
		/*aComboValues*/ ,;
		/*nMaxLenCombo*/,;
		/*cIniBrow*/,;
		/*lVirtual*/.T.,;
		/*cPictVar*/,;
		/*lInsertLine*/.F.,;
		/*nWidth*/)
	Else			

		lTRFA600 := .T.		
		oStruDXM:RemoveField( "DXM_ORIGEM" )		
		oStruDXM:RemoveField( "DXM_NOTA" )
		oStruDXM:RemoveField( "DXM_SERIE" )
		oStruDXM:RemoveField( "DXM_ITEMNF" )
		oStruDXM:RemoveField( "DXM_OP" )
		oStruDXM:RemoveField( "DXM_NUMDOC" )
		oStruDXM:RemoveField( "DXM_VLFISC" )
		oStruDXM:RemoveField( "DXM_NFCOMP" )
		oStruDXM:RemoveField( "DXM_SRCOMP" )

		oStruDXM:SetProperty('DXM_CODUNB',MVC_VIEW_ORDEM,CVALTOCHAR(Len(oStruDXM:GetFields())+4))

	Endif		

	oStruDXM:SetProperty("DXM_MODPS1" ,MVC_VIEW_ORDEM,'26')
	oStruDXM:SetProperty("DXM_MODPS2" ,MVC_VIEW_ORDEM,'27')

	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------
	If !Empty(cUserBenf)
		oStruDXM:RemoveField( "DXM_CODUNB" )
	Endif	
	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_DX0', oStruDX0, 'MdGridDX0' )
	oStruDX0:RemoveField('DX0_CODUNB')
	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_DX0', 'DX0_ITEM' )

	//----------------------
	//Cria o Box Horizontal
	//----------------------
	oView:CreateHorizontalBox( 'CABEC', 70 )
	oView:CreateHorizontalBox( 'GRID', 30 )

	oStruDXM:SetProperty("DXM_TIPMOV",MVC_VIEW_CANCHANGE,.F.)

	//----------------------
	//Seta owner da view
	//----------------------
	oView:SetOwnerView( 'VIEW_DXM', 'CABEC' )
	oView:SetOwnerView( 'VIEW_DX0', 'GRID' )

	oView:SetViewAction("DELETELINE",{|oView| ReCalcRateio(oView)})
	oView:SetViewAction("AfterAddLine",{|oView| ReAtuRateio(oView)})

	//-----------------
	//Adiciona botão
	//-----------------
	oView:AddUserButton( STR0014, '', {|oView| AGRA600P(oView)} ) //"Pesagem"

	//-- PONTO DE ENTRADA - Botão View - DAGROOGP-1490
	If (ExistBlock("AGRA600BUT"))
		oView := ExecBlock("AGRA600BUT",.F.,.F.,{oView})
	EndIf
	/*	
	User Function AGRA600BUT()
	Local oView := PARAMIXB[1] // View do OGA245

	//Adiciona botão
	oView:AddUserButton( "Botão de Usuário", '', {|oView| U_USRBUTTON(oView)} ) //"Botão de Usuário"
	Return ( oView )

	User Function USRBUTTON(oView)
	MSGINFO("Botão de Usuário!")
	Return .T. 
	*/

Return oView

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A600VLDACT
Validação da ativação do model

@param: Nil
@author: Equipe Agroindustria
@since: 20/11/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function A600VLDACT(oModel)
	Local aArea		:= GetArea()
	Local lRet		:= .T.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Do Case
			Case IsIncallStack("AGRA600E")
			If DXM->DXM_STATUS == "2" // Status "2" = Encerrado
				lRet := .F.
				Help("",1,STR0015,,STR0016,1) //"Atenção!"###"Este romaneio já está Encerrado!"
			ElseIf DXM->DXM_STATUS == "3" // Status "3" = Cancelado
				lRet := .F.

				Help("",1,STR0015,,STR0017,1) //"Atenção!"###"Este romaneio foi Cancelado!"
			EndIf
			Case IsIncallStack("AGRA600C")
			If DXM->DXM_STATUS == "3" // Status "3" = Cancelado
				lRet := .F.
				Help("",1,STR0015,,STR0018,1) //"Atenção!"###"Este romaneio já está Cancelado!"
			EndIf
			OtherWise
			If DXM->DXM_STATUS == "2" // Status "2" = Encerrado
				lRet := .F.
				Help("",1,STR0015,,STR0019,1) //"Atenção!"###"Este romaneio está Encerrado!"
			ElseIf DXM->DXM_STATUS == "3" // Status "3" = Cancelado
				lRet := .F.
				Help("",1,STR0015,,STR0020,1) //"Atenção!"###"Este romaneio está Cancelado!"
			EndIf
		EndCase
	EndIf

	RestArea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A600ACTIVE
Validação da ativação do model

@param: oModel - Modelo de dados da rotina
@author: Equipe Agroindustria
@since: 19/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function A600ACTIVE(oModel)
	Local aArea	 := GetArea()
	Local lRet	 := .T.

	Pergunte("AGRA60001",.F.)

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If !Empty(MV_PAR02)
			FwFldPut( "DXM_SAFRA" , MV_PAR02 ) // Safra
		Endif
		If !Empty(MV_PAR03)
			FwFldPut( "DXM_PRDTOR", MV_PAR03 ) // Produtor
		Endif
		If !Empty(MV_PAR04)
			FwFldPut( "DXM_LJPRO" , MV_PAR04 ) // Loja
		Endif
		If !Empty(MV_PAR05)
			FwFldPut( "DXM_FAZ"   , MV_PAR05 ) // Fazenda
		Endif
		If !Empty(MV_PAR06)
			FwFldPut( "DXM_LOCAL" , MV_PAR06 ) // Local
		Endif
		If !Empty(MV_PAR07)
			FwFldPut( "DXM_PSLONA", MV_PAR07 ) // Peso lona
		Endif
		If !Empty(cUserBenf)
			FwFldPut( "DXM_CODUNB", cUserBenf ) 
		Endif 

		If IsInCallStack("AGRA600T")
			oModel:GetModel("MdFieldDXM"):LoadValue('DXM_TIPMOV','2')
			lTransf := .T.
		Else
			oModel:GetModel("MdFieldDXM"):LoadValue('DXM_TIPMOV','1')
			lTransf := .F.
		Endif		
	EndIf

	RestArea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600P
Rotina de Pesagem

@param: oView - Modelo de interface da rotina
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600P(oView)
	Local oModel 		:= FWModelActive()
	Local aAreaAtu 		:= GetArea()
	Local cStatus		:= oModel:GetValue( 'MdFieldDXM', 'DXM_STATUS' )
	Local lRet 			:= .T.
	Local nPsBrut		:= oModel:GetValue( 'MdFieldDXM', 'DXM_PSBRUT' )
	Local nPsTara		:= oModel:GetValue( 'MdFieldDXM', 'DXM_PSTARA' )
	Local nPsLona		:= oModel:GetValue( 'MdFieldDXM', 'DXM_PSLONA' )
	Local lPeso1        := Empty( nPsBrut )
	Local lPeso2        := Empty( nPsTara )
	Local nX          	:= 0 
	Local nY            := 0
	Local nTam        	:= 0
	Local nPerc       	:= 0
	Local nTotal      	:= 0
	Local nResto      	:= 0
	Local oGridDX0		:= oModel:GetModel('MdGridDX0')
	Local nPsLiqu		:= 0
	Local nPsFisc		:= 0
	Local lPesagManu    := .F.
	Local oDlg 		    := Nil
	Local oCombo	    := Nil
	Local oTButt	    := Nil
	Local cCombo	    := ""
	Local nItem		    := 1

	//------------------------------------------------------
	// Se o romaneio estiver finalizado, desativa a pesagem 
	//------------------------------------------------------
	If cStatus == "1" .OR. cStatus == "0"

		If Empty(aPerBal[1])
			Help("",1,"AGRA600BAL",,STR0021,1) //"Não existe balança configurada para este usuário!"
			lRet := .F.
		EndIf

		If lRet 

			If nPsBrut > 0 .and. nPsTara > 0 //temos as duas pesagens 
				oDlg 	:= TDialog():New(0,0,50,300,'',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
				oCombo 	:= TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0072, STR0073}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , 'cCombo' ) //"Primeira Pesagem"###"Segunda Pesagem"
				oTButt 	:= TButton():New( 001, 104, STR0074, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma"
				oDlg:Activate( , , , .t., { | | .T. }, , { || } )

				If nItem = 1
					lPeso1 := .t.
					lPeso2 := .f.
				ElseIf nItem = 2
					lPeso1 := .f.
					lPeso2 := .t.
				EndIf
			EndIf  

			//first pass
			If lPeso1
				//----------------------------
				// Apresenta tela de pesagem
				//----------------------------

				AGRX003A( @nPsBrut,.T., aPerBal, , @lPesagManu)

				If !Empty(nPsBrut)
					oModel:LoadValue( 'MdFieldDXM', 'DXM_PSBRUT',nPsBrut )
					oModel:LoadValue( 'MdFieldDXM', 'DXM_MODPS1', IIf( lPesagManu, "M", "A" ) )
				EndIf	

			ElseIf lPeso2 //second pass
				//---------------------------
				// Apresenta tela de pesagem
				//---------------------------
				AGRX003A( @nPsTara,.T. , aPerBal, , @lPesagManu )

				If !Empty(nPsTara)
					oModel:LoadValue( 'MdFieldDXM', 'DXM_PSTARA', nPsTara )
					oModel:LoadValue( 'MdFieldDXM', 'DXM_MODPS2', IIf( lPesagManu, "M", "A" ) )
				EndIf
			EndIf	

			If !Empty(nPsBrut) .And. !Empty(nPsTara)
				If nPsBrut > nPsTara
					oModel:LoadValue( 'MdFieldDXM', 'DXM_PSLIQU',(nPsBrut - nPsTara - nPsLona))
				Else
					oModel:LoadValue( 'MdFieldDXM', 'DXM_PSLIQU',(nPsTara - nPsBrut - nPsLona))
				Endif


				//Inicio da atualização do peso líquido do fardão no romaneio
				nPsLiqu := oModel:GetValue( 'MdFieldDXM', 'DXM_PSLIQU' )
				nPsFisc := oModel:GetValue( 'MdFieldDXM', 'DXM_PSFISC' )

				For nY := 1 to oGridDX0:Length()
					oGridDX0:GoLine( nY )
					If !oGridDX0:isDeleted()
						nTam ++
					Endif
				Next nY


				nPerc  := Round((100 / nTam), 2)
				nTotal := Round((nPerc * nTam),2)

				If nTotal <> 100
					nResto := 100 - nTotal
				Endif

				For nX := 1 to oGridDX0:Length()
					oGridDX0:GoLine( nX )

					If !oGridDX0:IsDeleted() 
						If nX = 1
							oGridDX0:LoadValue("DX0_RATEIO", (nPerc + nResto))
							nPsRat    := ( (nPsLiqu/100) * (nPerc + nResto) )
							nPsRatFis := ( (nPsFisc/100) * (nPerc + nResto) )
						Else
							oGridDX0:LoadValue("DX0_RATEIO", nPerc)
							nPsRat := ( (nPsLiqu/100) * nPerc )
							nPsRatFis := ( (nPsFisc/100) * nPerc )
						Endif

						//--------------------------------------------------------
						// Atualiza o peso liquido e fiscal do fardao no romaneio
						//--------------------------------------------------------
						oGridDX0:LoadValue("DX0_PSLIQU", round(nPsRat,1))
						oGridDX0:LoadValue("DX0_PSFISC", round(nPsRatFis,1))
					Endif
				Next nX		
				//Final da atualização do peso líquido do fardão no romaneio

			EndIf
		EndIf
	Endif

	If !IsInCallStack("AGRA600E")
		oView:SetModiFied()
		oView:Refresh()
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600GRV
Grava os dados

@param: oModel - Modelo de dados da rotina
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function AGRA600GRV(oModel)
	Local oFieldDXM		:= oModel:GetModel('MdFieldDXM')
	Local oGridDX0		:= oModel:GetModel('MdGridDX0')
	Local lRet 			:= .T.
	Local nPsLiqu		:= oFieldDXM:GetValue("DXM_PSLIQU")
	Local nPsFisc       := oFieldDXM:GetValue("DXM_PSFISC")
	Local nPsRat	    := 0
	Local nX			:= 0
	Local nOperation	:= oModel:GetOperation()

	If IsInCallStack("AGRA600C")
		nOperac := 5
	EndIf

	dbClearFilterAll()
	//Recalcula o rateio antes da transação

	Begin Transaction
		//----------------------------------------------------
		// Rateia o peso da carga entre os itens do romaneio
		//----------------------------------------------------
		If lRet .And. nOperation # MODEL_OPERATION_DELETE .And. !IsInCallStack("AGRA600C")
			If oFieldDXM:GetValue("DXM_ORIGEM") = '1'
				oFieldDXM:LoadValue("DXM_NOTA"  , "")
				oFieldDXM:LoadValue("DXM_SERIE" , "")
				oFieldDXM:LoadValue("DXM_VLFISC", 0 )
				oFieldDXM:LoadValue("DXM_PSFISC", 0 )
			EndIf

			For nX := 1 to oGridDX0:Length()
				oGridDX0:GoLine( nX )

				If	!oGridDX0:IsDeleted() .And. !Empty(oGridDX0:GetValue("DX0_FARDAO", nX))

					//-----------------------------
					// Valida o registro do fardão 
					//-----------------------------
					lRet := AGRA600VFD()

					If .Not.(lRet := AGRA600VFD())
						DisarmTransaction()
						break
					EndIf

					//---------------------------------------
					// Calcula o percetual de rateio do item
					//---------------------------------------
					nPsRat    := ( (nPsLiqu/100) * oGridDX0:GetValue("DX0_RATEIO", nX) )
					nPsRatFis := ( (nPsFisc/100) * oGridDX0:GetValue("DX0_RATEIO", nX) )

					//----------------------------------------------------
					// Atualiza o peso liquido do fardao no romaneio
					//----------------------------------------------------
					oGridDX0:LoadValue("DX0_PSLIQU", round(nPsRat,1))
					oGridDX0:LoadValue("DX0_PSFISC", round(nPsRatFis,1))

					IF Rateio(oGridDX0) = 0 
						oGridDX0:SetValue("DX0_RATEIO",(100/oGridDX0:Length(.T.)))
						nRateio += round((100/oGridDX0:Length(.T.)),TamSX3("DX0_RATEIO")[2])
						If nX = oGridDX0:Length(.T.) .And. round(nRateio,1) != 100
							oGridDX0:SetValue("DX0_RATEIO", ((round((100/oGridDX0:Length(.T.)),TamSX3("DX0_RATEIO")[2])+100)-nRateio) )
							nRateio := 100
						EndIf
					EndIf

					DXL->(dbSelectArea("DXL"))
					DXL->(dbClearFilter())
					DXL->(dbSetOrder(1))

					//Revisar todos os dbSeek para verificar se tem a fazenda
					If DXL->(MsSeek(fwxFilial("DXL")+oGridDX0:GetValue("DX0_FARDAO")+oFieldDXM:GetValue("DXM_SAFRA")+oFieldDXM:GetValue("DXM_PRDTOR")+;
					oFieldDXM:GetValue("DXM_LJPRO")+oFieldDXM:GetValue("DXM_FAZ")))

						If FwFldGet('DXM_TIPMOV') = '2' //Saída					 
							If RecLock("DXL",.F.)
								DXL->DXL_CODROM := ""
								DXL->DXL_STATUS := '1' //Previsto
								DXL->DXL_PSESTI := DXL->DXL_PSLIQU
								DXL->DXL_PSLIQU := 0
								DXL->DXL_RDMTO  := 0
								DXL->DXL_CODUNB := ""

								MsUnlock("DXL")	
							Endif
						Else
							If RecLock("DXL",.F.)
								DXL->DXL_CODROM := oFieldDXM:GetValue("DXM_CODIGO")
								DXL->DXL_LOCAL  := oFieldDXM:GetValue("DXM_LOCAL")
								DXL->DXL_PSLIQU := oGridDX0:GetValue("DX0_PSLIQU", nX)
								DXL->DXL_PSFISC := oGridDX0:GetValue("DX0_PSFISC", nX)

								If Empty(cUserBenf)
									DXL->DXL_CODUNB := oFieldDXM:GetValue("DXM_CODUNB")
								Else
									DXL->DXL_CODUNB := cUserBenf
								Endif

								IF DXL_STATUS < "4"
									If !IsInCallStack("AGRA600E")
										DXL->DXL_STATUS := "2" //Status "2"=Em Romaneio de Entrada
									Else
										DXL->DXL_STATUS := "3" //Status "3"=Disponível
									EndIf
								Elseif DXL->DXL_STATUS = "5"
									dbSelectArea("DXI")
									dbsetorder(2)
									MsSeek(fwxFilial("DXI") + DXL->DXL_CODIGO)
									nPsFardo := 0
									While !Eof() .and. fwxFilial("DXI") = DXI->DXI_FILIAL .and. DXL->DXL_CODIGO = DXI->DXI_FARDAO
										nPsFardo += DXI->DXI_PSLIQU
										dbSkip()
									endDo
									DXL->DXL_RDMTO := (nPsFardo / DXL->DXL_PSLIQU)*100
								EndIF
								MsUnlock()
							Endif
						Endif	
					Endif

					//----------------------------------------------------
					// Atualiza o usuário da unidade de beneficiamento
					//----------------------------------------------------
					If Empty(cUserBenf)
						oGridDX0:LoadValue("DX0_CODUNB",oFieldDXM:GetValue("DXM_CODUNB"))
					Else
						oGridDX0:LoadValue("DX0_CODUNB",cUserBenf)
					Endif	
				Else

					DXL->(dbSelectArea("DXL"))
					DXL->(dbClearFilter())
					DXL->(dbSetOrder(1))

					If DXL->(dbSeek(xFilial("DXL")+oGridDX0:GetValue("DX0_FARDAO",nX)+oFieldDXM:GetValue("DXM_SAFRA")+oFieldDXM:GetValue("DXM_PRDTOR")+;
					oFieldDXM:GetValue("DXM_LJPRO")))

						If RecLock("DXL",.F.)
							DXL->DXL_CODROM := ""
							DXL->DXL_STATUS := '1'
							DXL->DXL_PSLIQU := 0
							DXL->DXL_CODUNB := ""
							MsUnlock("DXL")		
						Endif		
					Endif												
				EndIf
			Next

			//--Verifica todos os fardoes do romaneio para liberar os fardoes que nao estao mais vinculados
			lRet := AGRA600VIC(oModel)

		ElseIf nOperac == MODEL_OPERATION_DELETE
			If AGRIFDBSEEK("DX0",oFieldDXM:GetValue("DXM_CODIGO"),1,.f.)
				While  (!eof() .and. fwxFilial("DX0")  = DX0->DX0_FILIAL .and.  DX0->DX0_CODROM =  DXM->DXM_CODIGO )
					If	AGRIFDBSEEK("DXL",DX0->DX0_FARDAO+DXM->DXM_SAFRA+DXM->DXM_PRDTOR+DXM->DXM_LJPRO+DXM->DXM_FAZ ,1,.f.)
						If Reclock("DXL",.F.)
							DXL->DXL_CODROM := ""
							DXL->DXL_STATUS := '1'
							DXL->DXL_PSLIQU := 0
							DXL->DXL_CODUNB := ""
							MSunlock("DXL")
						Endif	
					EndIf
					dbselectarea("DX0")
					dbSkip()
				EndDo
			Endif	
		EndIf

		If lRet
			FWFormCommit( oModel )
		EndIf
	End Transaction
Return lRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600E
Fecha o Romaneio de Entrada

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600E()
	Local oModel  	:= FwloadModel("AGRA600")
	Local oFieldDXM	:= oModel:GetModel("MdFieldDXM")
	Local oGridDX0	:= oModel:GetModel("MdGridDX0")
	Local aErro		:= {}
	Local cNumOP	:= ""
	Local cProduto  := ""
	Local cCliFor 	:= ""
	Local cLjCliFor	:= ""
	Local cTipo		:= ""
	Local cUM       := ""
	Local cTM       := SuperGetMV("MV_AGRTMRQ",.F.,"")
	Local cNF       := "" 
	Local cSerie    := ""
	Local nTotProd  := 0
	Local cTab  	:= ""
	Local lGerEstoq := .t. //valor padrão sempre gera movimentação no estoque pelo ERP
	Local lAG600STQ := .t. // variavel recebe valor do PE AG600STQ

	If NJ0->(ColumnPos("NJ0_ID")) > 0 //Troca de Produtor para Entidade
		cTab := "NJ0"					
	Else
		cTab := "DX8"
	EndIf

	oModel:SetOperation( 4 )

	If lRet:= oModel:Activate()

		If Round(Rateio(oGridDX0),0) < 100
			Help("",1,STR0037,,STR0038,1) //"Atenção"###"O total de rateio da carga entre os itens não pode ser inferior a 100%"
			Return .f.
		EndIf

		/**
		A validação é diferente de saída para casos onde o romaneio já foi registrado antes da aplicação de dicionário
		da atualização de processo
		**/

		if __lNovSafra
			cProduto := oFieldDXM:GetValue("DXM_CODPRO")		
		else
			cProduto := Posicione("NN1",1,fwxFilial("NN1")+oFieldDXM:GetValue("DXM_SAFRA"),"NN1_CODPRO")
		endIf

		cUM      := Posicione("SB1",1,fwxFilial("SB1")+cProduto,"B1_UM")

		If FwFldGet('DXM_TIPMOV') # '2' 

			/*************************************************************
			Validações para Romaneio de Entrada
			**************************************************************/

			//----------------------------------------------
			// Abre a tela de pessagem da tara.
			//----------------------------------------------
			If FwFldGet("DXM_PSLIQU") <= 0 .And. FwFldGet("DXM_PSBRUT") != 0 .And. FwFldGet("DXM_PSTARA") = 0
				AGRA600P(ViewDef())
				lRet := AGRA600GRV(oModel)
			EndIf

			If lRet .And. FwFldGet("DXM_PSLIQU") <= 0
				lRet := .F.
				Help("",1,STR0015,,STR0023,1) //"Atenção!"###"O peso do fardão está zerado!"
			EndIf

			//--------------------------------------------------------------------------------------
			// Quando entrada via documento fiscal, valida se existe vinculo da nota com o romaneio 
			//--------------------------------------------------------------------------------------
			If lRet .And. FwFldGet("DXM_ORIGEM") == "2"
				If Empty(FwFldGet("DXM_NOTA")) .Or. Empty(FwFldGet("DXM_SERIE")) .Or. ;
				FwFldGet("DXM_VLFISC") = 0  .Or. FwFldGet("DXM_PSFISC") = 0
					lRet := .F.
					Help("",1,STR0015,,STR0076,1) //"Atenção!"###"O campo DXM_NOTA está vazio!"
				EndIf

				//Usa o produtor para localizar, pois, estamos tratando a DXM
				DXM->(dbSetOrder(3))
				If lRet .And. DXM->(MsSeek(fwxFilial("DXM")+FwFldGet("DXM_NOTA")+FwFldGet("DXM_SERIE")+FwFldGet("DXM_PRDTOR")+FwFldGet("DXM_LJPRO")))

					While .Not. DXM->( Eof() ) .And.; 
					DXM->( DXM_FILIAL ) == FWxFilial("DXM")       .And. ;
					DXM->( DXM_NOTA )   == FwFldGet("DXM_NOTA")   .And. ; 
					DXM->( DXM_SERIE )  == FwFldGet("DXM_SERIE")  .And. ;
					DXM->( DXM_PRDTOR ) == FwFldGet("DXM_PRDTOR") .And. ; 
					DXM->( DXM_LJPRO )  == FwFldGet("DXM_LJPRO")

						If DXM->( DXM_CODIGO ) != FwFldGet("DXM_CODIGO") .And. (DXM->DXM_STATUS <> "3")
							lRet := .F.
							Help("",1,STR0015,,STR0036,1) //"Atenção!"###"A Nota Fiscal selecionada já foi vinculada a um romaneio entrada!"
						EndIf
						DXM->( dbSkip() )
					EndDo
				EndIf


				//-------------------------------------------------
				// Busca cliente e fornecedor amarrado ao produtor
				//-------------------------------------------------


				cTipo := If(oFieldDXM:GetValue("DXM_PROPRI") == "1" .AND. oFieldDXM:GetValue("DXM_ORIGEM") == "2", "N", "B")
				If cTab == "NJ0"
					dbSelectArea("NJ0")
					dbSetOrder(1)
					If MsSeek(fwxFilial("NJ0")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
						cCliFor 	:= If(cTipo == "N", NJ0->NJ0_CODFOR, NJ0->NJ0_CODCLI )
						cLjCliFor	:= If(cTipo == "N", NJ0->NJ0_LOJFOR, NJ0->NJ0_LOJCLI )
					EndIf
					NJ0->(DbCloseArea())
				ElseIf cTab == "DX8"
					dbSelectArea("DX8")
					dbSetOrder(1)
					If dbSeek(xFilial("DX8")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
						cCliFor 	:= If(cTipo == "N", DX8->DX8_FORNEC, DX8->DX8_CLIENT )
						cLjCliFor	:= If(cTipo == "N", DX8->DX8_LJFOR, DX8->DX8_LJCLI )
					EndIf
					DX8->(DbCloseArea())
				EndIf


				SF1->(dbSetOrder(1))
				If lRet .And. SF1->(MsSeek(fwxFilial("SF1")+FwFldGet("DXM_NOTA")+FwFldGet("DXM_SERIE")+cCliFor+cLjCliFor))
					If FwFldGet("DXM_PSFISC") != SF1->F1_PLIQUI
						lRet := .F.
						Help("",1,STR0015,,STR0077,1) //"Atenção!"###"A Nota Fiscal selecionada já foi vinculada a um romaneio entrada!"
					EndIf

					If FwFldGet("DXM_VLFISC") != SF1->F1_VALBRUT
						lRet := .F.
						Help("",1,STR0015,,STR0078,1) //"Atenção!"###"A Nota Fiscal selecionada já foi vinculada a um romaneio entrada!"
					EndIf
				Else
					If lRet
						lRet := .F.
						Help("",1,STR0015,,STR0079 + FwFldGet("DXM_NOTA") + STR0080 +FwFldGet("DXM_SERIE") + STR0081 + cCliFor + STR0082 + cLjCliFor,1) //"Atenção!"###"A Nota Fiscal selecionada já foi vinculada a um romaneio entrada!"
					EndIf
				EndIf

			EndIf
		Endif	

		If lRet
			Begin Transaction
				//------------------------------------
				// Movimentação interna de Produção
				//------------------------------------
				If lRet .And. FwFldGet('DXM_TIPMOV') # '2' //Entrada
					If FwFldGet("DXM_PROPRI") == "1" .And. FwFldGet("DXM_ORIGEM") == "1" 

						AGR605VLDPR(oModel, "AGRA601", @nTotProd)

						lGerEstoq := .t.

						//Ponto de Entrada AG600STQ - define se gera a movimentação de estoque pelo ERP/Romaneio
						If ExistBlock('AG600STQ')
							lAG600STQ := ExecBlock('AG600STQ', .F.,.F.,{oModel})
							
							If ValType( lAG600STQ ) == "L"
								lGerEstoq := lAG600STQ		
							EndIf

						Endif

						If nTotProd > 0 

							IF lGerEstoq
								//-------------------------
								// Gera ordem de produção
								//-------------------------
								lRet := A600GERAOP(@cNumOP, oModel, cProduto, 3, nTotProd)

								//-------------------------
								// Faz o apontamento da OP 
								//-------------------------
								If lRet
									Processa({|| lRet := A600APROD(cNumOP, oModel, cProduto, 3, nTotProd) }, STR0026, STR0025 ) //"Atualizando estoque..."###"Aguarde"
								EndIf
							EndIF

						Endif

						If lRet
							oFieldDXM:SetValue("DXM_STATUS","2") //Status "2"=Encerrado
							If ( lRet := oModel:VldData() )
								//--------------------------------------------------------------------------------------
								// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
								//--------------------------------------------------------------------------------------
								oModel:CommitData()
							EndIf

							If !lRet
								aErro := oModel:GetErrorMessage()
							EndIf
						Else 
							DisarmTransaction()
						EndIf

					ElseIf FwFldGet("DXM_ORIGEM") == "2" //se documento de entrada
						If lRet
							oFieldDXM:SetValue("DXM_STATUS","2") //Status "2"=Encerrado
							If ( lRet := oModel:VldData() )
								//--------------------------------------------------------------------------------------
								// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
								//--------------------------------------------------------------------------------------
								oModel:CommitData()
							EndIf

							If !lRet
								aErro := oModel:GetErrorMessage()
							EndIf
						EndIf
					EndIf 
				ElseIf FwFldGet('DXM_TIPMOV') = '2' //Saída
					//Rotina para transferência de fardões entre filiais

					Pergunte('AGRA60002', .F.)

					If MV_PAR01 = 1 //Interna
						If lRet := SF5->(MsSeek(fwxFilial("SF5")+cTM))
							lRet := SF5->F5_TIPO $ "R"
						EndIf

						If !lRet
							Help("",1,"A240TM")
						EndIf

						DX0->(dbSelectArea('DX0'))
						DX0->(dbSetOrder(1))
						If DX0->(MsSeek(fwxFilial('DX0')+FwFldGet('DXM_CODIGO')))
							While !DX0->(Eof())                  .And. ;
							DX0->DX0_FILIAL = fwxFilial('DX0') .And. ;
							DX0->DX0_CODROM = FwFldGet('DXM_CODIGO')
								If lRet

									//-------------------------------------
									// Busca o proximo numero de documento
									//-------------------------------------
									cNumDoc := NextNumDoc()	

									//Efetua movimentação interna
									lRet := TransfIntern(cTM, DX0->DX0_CODPRO, DX0->DX0_PSLIQU, FwFldGet('DXM_LOCAL'), 3 /*Inclusão*/, FwFldGet('DXM_CODIGO'), cNumDoc)

									If lRet
										DXL->(dbSelectArea('DXL'))
										DXL->(dbSetOrder(1))
										If DXL->(MsSeek(fwxFilial('DXL')+DX0->DX0_FARDAO+FwFldGet('DXM_SAFRA')+FwFldGet('DXM_PRDTOR')+FwFldGet('DXM_LJPRO')+FwFldGet('DXM_FAZ')))

											If RecLock('DXL',.f.)
												DXL->DXL_STATUS := '1' //Previsto 
												DXL->DXL_PSESTI := DXL->DXL_PSLIQU
												DXL->DXL_PSLIQU := 0
												DXL->DXL_RDMTO  := 0
											Endif

											dbSelectArea('SD3')
											dbSetOrder(2)
											If MsSeek(FwXFilial('SD3')+PADR(cNumDoc,TamSX3('D3_DOC')[1],' ')+;
											PADR(DX0->DX0_CODPRO,TamSX3('D3_COD')[1],' '))

												RegToMemory('DXL',.f.,.f.)

												lRet := AGR605GRAVA( )
											Endif																
										Endif
									Else
										DisarmTransaction()
									Endif

								Endif	
								DX0->(dbSkip())
							EndDo
						Endif
						DX0->(DbCloseArea())

						If lRet
							If lRet
								oFieldDXM:SetValue("DXM_STATUS","2") //Status "2"=Encerrado
								If ( lRet := oModel:VldData() )
									//--------------------------------------------------------------------------------------
									// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
									//--------------------------------------------------------------------------------------
									oModel:CommitData()
								EndIf

								If !lRet
									aErro := oModel:GetErrorMessage()
								EndIf
							EndIf
						EndIf

					ElseIf MV_PAR01 = 2 .And. cTab == "NJ0"//Fiscal Considerando Entidade.
						NJ0->(dbSelectArea('NJ0'))
						NJ0->(dbSetOrder(1))
						If NJ0->(MsSeek(FwXFilial('NJ0')+FwFldGet('DXM_PRDTOR')+FwFldGet('DXM_LJPRO')))

							If !Empty(NJ0->NJ0_CODCLI)

								//Gerar Pedido
								cNumPed := GetSXENum('SC5','C5_NUM')

								If lRet
									//Função para criação de pedido
									Processa({|| lRet := AGRCRTPED(cNumPed, /*Contrato*/, NJ0->NJ0_CODCLI, NJ0->NJ0_LOJCLI, FwFldGet('DXM_PSLIQU'), SuperGetMv("MV_CONDPAD"),;
									cProduto, FwFldGet('DXM_LOCAL'), cUM, MV_PAR02, GetPrice(cProduto, FwFldGet('DXM_LOCAL')),;
									"AGRA600" )},STR0053,STR0054) //"Aguarde..."###"Gerando pedido de venda..."

									If lRet 
										DX0->(dbSelectArea('DX0'))
										DX0->(dbSetOrder(1))
										If DX0->(MsSeek(fwxFilial('DX0')+FwFldGet('DXM_CODIGO')))
											While !DX0->(Eof())                     .And. ;
											DX0->DX0_FILIAL = fwxFilial('DX0') .And. ;
											DX0->DX0_CODROM = FwFldGet('DXM_CODIGO')
												If lRet
													SetFunName("AGRA600")

													DXL->(dbSelectArea('DXL'))
													DXL->(dbSetOrder(1))
													If DXL->(MsSeek(fwxFilial('DXL')+DX0->DX0_FARDAO+FwFldGet('DXM_SAFRA')+FwFldGet('DXM_PRDTOR')+FwFldGet('DXM_LJPRO')+FwFldGet('DXM_FAZ')))

														If AGR605VLDPR( oModel, "AGRA600", @nTotProd)
															RegToMemory('DXL',.f.,.f.)

															lRet := AGR605GRVPD( , DX0->DX0_CODPRO, , FwFldGet('DXM_LOCAL'), , , , cNumPed, DX0->DX0_PSLIQU )
														Endif	
													Endif

												Endif											

												DX0->(dbSkip())
											EndDo
										Endif

										If lRet
											If !IsBlind()
												Processa({|| lRet := LiberaPed(cNumPed,NJ0->NJ0_CODCLI)},STR0053,STR0058) //"Aguarde..."###"Liberando pedido de venda..."
											Else

												lRet := LiberaPed(cNumPed,NJ0->NJ0_CODCLI)
											EndIf
										Else
											DisarmTransaction()
										Endif	
									Endif																		
								Endif 
							Else
								//###"Erro"###
								//###'O produto informado não possui código de Cliente e Loja vinculado'###
								//###'Cliente e Loja são necessários para a transferência fiscal, por favor, verifique seu cadastro de produtor!'###
								oModel:SetErrorMessage(,,,, STR0055, STR0056, STR0057)      
								lRet := .F.
							Endif	

							If !lRet
								DisarmTransaction()
							EndIf												
						Endif
						NJ0->(DbCloseArea())
					ElseIf MV_PAR01 = 2 .And. cTab == "DX8"
						DX8->(dbSelectArea('DX8'))
						DX8->(dbSetOrder(1))
						If DX8->(DbSeek(FwXFilial('DX8')+FwFldGet('DXM_PRDTOR')+FwFldGet('DXM_LJPRO')))

							If !Empty(DX8->DX8_CLIENT)

								//Gerar Pedido
								cNumPed := GetSXENum('SC5','C5_NUM')

								If lRet
									//Função para criação de pedido
									Processa({|| lRet := AGRCRTPED(cNumPed, /*Contrato*/, DX8->DX8_CLIENT, DX8->DX8_LJCLI, FwFldGet('DXM_PSLIQU'), SuperGetMv("MV_CONDPAD"),;
									cProduto, FwFldGet('DXM_LOCAL'), cUM, MV_PAR02, GetPrice(cProduto, FwFldGet('DXM_LOCAL')),;
									"AGRA600" )},STR0053,STR0054) //"Aguarde..."###"Gerando pedido de venda..."

									If lRet 
										DX0->(dbSelectArea('DX0')) 
										DX0->(dbSetOrder(1))
										If DX0->(MsSeek(xFilial('DX0')+FwFldGet('DXM_CODIGO')))
											While !DX0->(Eof())                     .And. ;
											DX0->DX0_FILIAL = xFilial('DX0') .And. ;
											DX0->DX0_CODROM = FwFldGet('DXM_CODIGO')
												If lRet
													SetFunName("AGRA600")

													DXL->(dbSelectArea('DXL'))
													DXL->(dbSetOrder(1))
													If DXL->(MsSeek(xFilial('DXL')+DX0->DX0_FARDAO+FwFldGet('DXM_SAFRA')+FwFldGet('DXM_PRDTOR')+FwFldGet('DXM_LJPRO')+FwFldGet('DXM_FAZ')))

														If AGR605VLDPR( oModel, "AGRA600", @nTotProd)
															RegToMemory('DXL',.f.,.f.)

															lRet := AGR605GRVPD( , DX0->DX0_CODPRO, , FwFldGet('DXM_LOCAL'), , , , cNumPed, DX0->DX0_PSLIQU )
														Endif	
													Endif

												Endif											

												DX0->(dbSkip())
											EndDo
										Endif

										If lRet
											Processa({|| lRet := LiberaPed(cNumPed,DX8->DX8_CLIENT)},STR0053,STR0058) //"Aguarde..."###"Liberando pedido de venda..."
										Else
											DisarmTransaction()
										Endif	
									Endif																		
								Endif 
							Else
								//###"Erro"###
								//###'O produto informado não possui código de Cliente e Loja vinculado'###
								//###'Cliente e Loja são necessários para a transferência fiscal, por favor, verifique seu cadastro de produtor!'###
								oModel:SetErrorMessage(,,,, STR0055, STR0056, STR0057)      
								lRet := .F.
							Endif	

							If !lRet
								DisarmTransaction()
							EndIf												
						Endif
						DX8->(DbCloseArea())	
					Endif

					If !lRet
						aErro := oModel:GetErrorMessage()
					EndIf										

				EndIf

				If !lRet
					DisarmTransaction()
				EndIf	

			End Transaction()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	Pergunte('AGRA60002', .F.)

	//Gera Log de Erro
	If !Empty(aErro)
		If !IsBlind()
			AutoGrLog( STR0027 	+ ' [' + AllToChar( aErro[3] ) + ']' ) //"Formulario de Erro: "
			AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[4] ) + ']' ) //"Campo: "
			AutoGrLog( STR0029	+ ' [' + AllToChar( aErro[6] ) + ']' ) //"Erro: "
			AutoGrLog( STR0030	+ ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor Atribuido: "
			MostraErro()
		Endif

	ElseIf DXM->DXM_TIPMOV = '2' .And.; //Saída
	MV_PAR01 = 2                //Fiscal

		If cTab == "DX8"
			DX8->(dbSelectArea("DX8"))
			DX8->(dbSetOrder(1))
			If DX8->(MSSeek(FwXFilial("DX8")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO")))

				If cTab =='DX8' .And. !Empty(DX8->DX8_CLIENT)

					If lRet

						//Gerar Nota
						MsAguarde({|| lRet := AGREMTNF( cNumPed, "AGRA600" )},STR0053,STR0059) //"Aguarde..."###"Gerando documento fiscal..."

						If lRet
							Begin Transaction
								DbSelectArea('SC5')
								DbSetOrder(1)
								If MsSeek(FwXFilial('SC5')+cNumPed)
									cNF    := SC5->C5_NOTA
									cSerie := SC5->C5_SERIE
								Endif

								DX0->(dbSelectArea('DX0'))
								DX0->(dbSetOrder(1))
								If DX0->(MsSeek(fwxFilial('DX0')+oFieldDXM:GetValue("DXM_CODIGO")))
									While !DX0->(Eof())                      .And. ;
									DX0->DX0_FILIAL = FWxFilial('DX0')  .And. ;
									DX0->DX0_CODROM = oFieldDXM:GetValue("DXM_CODIGO")
										If lRet

											DXL->(dbSelectArea('DXL'))
											DXL->(dbSetOrder(1))
											If DXL->(MsSeek(fwxFilial('DXL')+DX0->DX0_FARDAO+oFieldDXM:GetValue("DXM_SAFRA")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO")+oFieldDXM:GetValue("DXM_FAZ")))

												RegToMemory('DXL',.f.,.f.)			

												//Grava a Nota Fiscal e Série
												lRet := AGR605GRVNF( DX0->DX0_FARDAO, oFieldDXM:GetValue("DXM_SAFRA"), cNF, cSerie, "AGRA600" )
											Endif	
										Endif											

										DX0->(dbSkip())
									EndDo
								Endif	
								If lRet
									If lRet
										oFieldDXM:SetValue("DXM_STATUS","2") //Status "2"=Encerrado
										If ( lRet := oModel:VldData() )
											//--------------------------------------------------------------------------------------
											// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
											//--------------------------------------------------------------------------------------
											oModel:CommitData()
										EndIf

										If !lRet
											aErro := oModel:GetErrorMessage()
										EndIf
									EndIf
								EndIf

							End Transaction()
						EndIf
					Endif
				Endif
			Endif
			DX8->(DbCloseArea())
		ElseIf cTab == "NJ0"
			NJ0->(dbSelectArea("NJ0"))
			NJ0->(dbSetOrder(1))
			If NJ0->(MSSeek(FwXFilial("NJ0")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO")))

				If cTab =='NJ0' .And. !Empty(NJ0->NJ0_CODCLI)

					If lRet
						If ! IsBlind()
							//Gerar Nota
							MsAguarde({|| lRet := AGREMTNF( cNumPed, "AGRA600" )},STR0053,STR0059) //"Aguarde..."###"Gerando documento fiscal..."
						Else
							lRet := AGREMTNF( cNumPed, "AGRA600" )
						EndIf
						If lRet
							Begin Transaction
								DbSelectArea('SC5')
								DbSetOrder(1)
								If MsSeek(FwXFilial('SC5')+cNumPed)
									cNF    := SC5->C5_NOTA
									cSerie := SC5->C5_SERIE
								Endif

								DX0->(dbSelectArea('DX0'))
								DX0->(dbSetOrder(1))
								If DX0->(MsSeek(fwxFilial('DX0')+oFieldDXM:GetValue("DXM_CODIGO")))
									While !DX0->(Eof())                      .And. ;
									DX0->DX0_FILIAL = FWxFilial('DX0')  .And. ;
									DX0->DX0_CODROM = oFieldDXM:GetValue("DXM_CODIGO")
										If lRet

											DXL->(dbSelectArea('DXL'))
											DXL->(dbSetOrder(1))
											If DXL->(MsSeek(fwxFilial('DXL')+DX0->DX0_FARDAO+oFieldDXM:GetValue("DXM_SAFRA")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO")+oFieldDXM:GetValue("DXM_FAZ")))

												RegToMemory('DXL',.f.,.f.)			

												//Grava a Nota Fiscal e Série
												lRet := AGR605GRVNF( DX0->DX0_FARDAO, oFieldDXM:GetValue("DXM_SAFRA"), cNF, cSerie, "AGRA600" )
											Endif	
										Endif											

										DX0->(dbSkip())
									EndDo
								Endif	
								If lRet
									If lRet
										oFieldDXM:SetValue("DXM_STATUS","2") //Status "2"=Encerrado
										If ( lRet := oModel:VldData() )
											//--------------------------------------------------------------------------------------
											// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
											//--------------------------------------------------------------------------------------
											oModel:CommitData()
										EndIf

										If !lRet
											aErro := oModel:GetErrorMessage()
										EndIf
									EndIf
								EndIf

							End Transaction()
						EndIf
					Endif
				Endif
			Endif
			NJ0->(DbCloseArea())						
		EndIf	 	 

		If !Empty(aErro)
			AutoGrLog( STR0027 	+ ' [' + AllToChar( aErro[3] ) + ']' ) //"Formulario de Erro: "
			AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[4] ) + ']' ) //"Campo: "
			AutoGrLog( STR0029	+ ' [' + AllToChar( aErro[6] ) + ']' ) //"Erro: "
			AutoGrLog( STR0030	+ ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor Atribuido: "
			MostraErro()
		Endif
	EndIf      	
Return

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600C
Cancela o Romaneio de Entrada

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
@type function 
------------------------------------------------------------------------------------------ **/
Function AGRA600C()
	Local oModel  	:= FwloadModel("AGRA600")
	Local oFieldDXM	:= Nil
	Local oGridDX0	:= Nil
	Local aErro		:= {}
	Local cNumOP	:= ""
	Local cNumDoc	:= ""
	Local cProduto  := ""
	Local nX		:= 0
	Local lRet 		:= .T.
	Local cTM       := ""
	Local lExcEstq 	:= .T.  //valor padrão sempre exclui movimentação do estoque do ERP
	Local lAG600STQ := .t. // variavel recebe valor do PE AG600STQ

	oModel:SetOperation( 4 )

	If lRet := oModel:Activate()
		oFieldDXM	:= oModel:GetModel('MdFieldDXM')
		oGridDX0	:= oModel:GetModel('MdGridDX0')
		cNumOP		:= FwFldGet("DXM_OP")
		cNumDoc		:= FwFldGet("DXM_NUMDOC")

		//Valida se fardos já foram beneficiados  e não deixa efetuar o cancelamento
		If lRet .And. FwFldGet('DXM_TIPMOV') <> '2'
			For nX := 1 to oGridDX0:Length()
				oGridDX0:GoLine( nX )
				If !AGRA600VFD()
					Exit
				elseif DXL->DXL_STATUS > '3'
					Help("",1,STR0015,,STR0041,1)
					lRet := .f.
					exit
				endif	
			next	
		endif

		If lRet
			if __lNovSafra
				cProduto := oFieldDXM:GetValue("DXM_CODPRO")
			else
				cProduto := Posicione("NN1",1,fwxFilial("NN1")+oFieldDXM:GetValue("DXM_SAFRA"),"NN1_CODPRO")
			endIf
		EndIf

		If lRet
			If ! IsBlind()
				lRet := Aviso (STR0015,STR0031,{STR0032,STR0033},1) == 1 //"Atenção!"###"O cancelamento do romaneio fará com que os movimentos de entrada do fardão sejam estornados., 
			EndIf		                                                         // Deseja realmente cancelar o romaneio?"###"Sim"###"Não"
		EndIf

		If lRet
			Begin Transaction
				If oFieldDXM:GetValue('DXM_TIPMOV') = '2' //Saída

					cTM := SuperGetMV("MV_AGRTMDV",.F.,"")

					If lRet := SF5->(MsSeek(fwxFilial("SF5")+cTM))
						lRet := SF5->F5_TIPO $ "D"
					EndIf

					If !lRet
						Help("",1,"A240TM")
					EndIf

					If lRet
						For nX := 1 to oGridDX0:Length()
							oGridDX0:GoLine( nX )

							DXB->(dbSelectArea('DXB'))
							DXB->(dbSetOrder(1))
							If DXB->(MsSeek(FwXFilial('DXB')+oGridDX0:GetValue("DX0_FARDAO")+oFieldDXM:GetValue('DXM_SAFRA')+oFieldDXM:GetValue('DXM_PRDTOR')+oFieldDXM:GetValue('DXM_LJPRO')+oFieldDXM:GetValue('DXM_FAZ')+"AGRA600"))
								If Empty(DXB->DXB_NUMPED) //Transferência Interna

									//------------------------------------
									// Estorno de Transferência Interna
									//------------------------------------
									lRet := TransfIntern(cTM, DXB->DXB_CODPRO, DXB->DXB_QUANT, DXB->DXB_LOCAL, 6 /*Estorno*/, oFieldDXM:GetValue('DXM_CODIGO'), DXB->DXB_DOC)

									If !lRet
										DisarmTransaction()
									EndIf								
								Else //Transferência Fiscal

									//------------------------------------
									// Estorno de Transferência Fiscal
									//------------------------------------
									dbSelectArea('SF2')
									dbSetOrder(1)
									If MsSeek(FwXFilial('SF2')+DXB->DXB_DOCNF+DXB->DXB_SERIE)			
										//Deleta o documento fiscal do complemento 			
										MsAguarde({||lRet := AGRDLDOCFIS(DXB->DXB_DOCNF,DXB->DXB_SERIE)},STR0037,STR0068) //"ATENCAO"###"Busca do Documento Fiscal"
										If !lRet
											DisarmTransaction()
										Else

											dbSelectArea('SC5')
											dbSetOrder(1)
											If MsSeek(FwXFilial('SC5')+DXB->DXB_NUMPED)
												//Delete o pedido do complemento
												MsAguarde({||lRet := AGRDLPDVEN(DXB->DXB_NUMPED)},STR0037,STR0069) //"ATENCAO"###"Busca do Pedido de Venda"

												If !lRet
													DisarmTransaction()
												EndIf 
											Endif	

										EndIf

									Endif	


								Endif
							Endif
						Next	
					EndIf

				Else //Entrada

					lExcEstq := .t.

					//Ponto de Entrada AG600STQ - define se exclui a movimentação de estoque 
					If ExistBlock('AG600STQ')
						lAG600STQ := ExecBlock('AG600STQ', .F.,.F.,{oModel})
						
						If ValType( lAG600STQ ) == "L"
							lExcEstq := lAG600STQ		
						EndIf

					Endif

					//---------------------------------------------------------
					// Estorna a movimentação de estoque gerada pela romaneio
					//---------------------------------------------------------
					IF lExcEstq
						If !Empty(cNumOP)
							Processa({|| lRet := A600APROD(cNumOP, oModel, cProduto,5) } ,STR0026,STR0034) //"Estonando movimentos de estoque gerados pelo Romaneio..."###"Aguarde"
						ElseIf !Empty(cNumDoc)
							AgrHelp(STR0015,STR0085, STR0086) //#####"A função de estorno para o tipo de movimentação gerada neste romaneio foi descontinuada.","Contate o suporte do produto.")
							lRet := .F.
						EndIf
					EndIF
				Endif	

				If lRet
					oFieldDXM:SetValue("DXM_STATUS","3")	// Status "3"=Cancelado
					oFieldDXM:SetValue("DXM_NFCOMP","") 	//NOTA COMPLEMENTO
					oFieldDXM:SetValue("DXM_SRCOMP","")		// SERIE NOTA COMPLEMENTO	

					If ( lRet := oModel:VldData() )
						//---------------------------------------------------------------------------------------
						// Se o dados foram validados com sucesso, faz-se a gravação efetiva dos dados (commit)
						//---------------------------------------------------------------------------------------
						oModel:CommitData()
					EndIf

					If !lRet
						aErro := oModel:GetErrorMessage()
					EndIf
				EndIf

				If lRet
					For nX := 1 to oGridDX0:Length()
						oGridDX0:GoLine( nX )

						//-----------------------------
						// Valida o registro do fardão 
						//-----------------------------
						DXL->(dbSelectArea("DXL"))
						DXL->(dbSetOrder(1))
						DXL->(DBClearFilter())

						If DXL->(MsSeek(FwXFilial("DXL")+oGridDX0:GetValue("DX0_FARDAO")+oFieldDXM:GetValue('DXM_SAFRA')+oFieldDXM:GetValue('DXM_PRDTOR')+oFieldDXM:GetValue('DXM_LJPRO')+oFieldDXM:GetValue('DXM_FAZ')))		

							If RecLock("DXL",.F.)
								DXL->DXL_PSLIQU := 0
								IF DXL->DXL_STATUS < "4"
									DXL->DXL_STATUS := "1" //Status "1"=Previsto
								EndIF
								DXL->DXL_CODROM := ""
								DXL->DXL_CODUNB := ""
								MsUnLock()
							Endif
							lRet := AGR605DEL(oGridDX0:GetValue("DX0_FARDAO"), oFieldDXM:GetValue('DXM_SAFRA'), oFieldDXM:GetValue('DXM_PRDTOR'), oFieldDXM:GetValue('DXM_LJPRO'), oFieldDXM:GetValue('DXM_FAZ'), "AGRA600")

							If lRet
								DbSelectArea('DX0')
								DbSetOrder(1)
								If (MsSeek(FwXFilial('DX0') + oGridDX0:GetValue("DX0_CODROM" )+ oGridDX0:GetValue("DX0_ITEM") ))
									If RecLock('DX0', .F.)
										DbDelete()
										MsUnlock()
									Endif
								Endif
								dbGoTop()
								MsSeek((FwXFilial('DX0') + oGridDX0:GetValue("DX0_CODROM" )+ oGridDX0:GetValue("DX0_ITEM") ))
							EndIf	
						EndIf

					Next nX
				EndIf	

				If !lRet
					DisarmTransaction()
				EndIf

			End Transaction()
		EndIf

	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	If !Empty(aErro)
		If ! IsBlind()
			AutoGrLog( STR0027 	+ ' [' + AllToChar( aErro[3] ) + ']' ) //"Formulario de Erro: "
			AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[4] ) + ']' ) //"Campo: "
			AutoGrLog( STR0029	+ ' [' + AllToChar( aErro[6] ) + ']' ) //"Erro: "
			AutoGrLog( STR0030	+ ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor Atribuido: "
			MostraErro()
		EndIf	
	EndIf

Return

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A600GERAOP
Gera ordem de produção

@param: cNumOP - Numero da Ordem de Produção
@param: oModel - Modelo de dados da rotina
@param: cProduto - Código do produto
@param: nOperac - Código da operação 3=Inclusao, 5=Exclusão
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function A600GERAOP(cNumOP, oModel, cProduto, nOperac, nTotProd)
	Local oFieldDXM		:= oModel:GetModel("MdFieldDXM")
	Local aArea 		:= GetArea()
	Local aAreaDXM		:= DXM->(GetArea())
	Local aVetor		:= {}
	Local nModuloOld  	:= nModulo

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.
	//-----------------------------
	// Salva as Variaveis publicas
	//-----------------------------
	SaveInter()
	//-----------------------
	// Seta modulo para PCP
	//-----------------------
	nModulo := 10
	//-------------------------------
	// Adiciona os dados em um vetor
	//-------------------------------

	cNumOP := GetSXENum('SC2','C2_NUM')
	SC2->(dbSetOrder(1))
	While SC2->(MsSeek(FwXFilial("SC2")+cNumOP))
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cNumOP := GetSxENum("SC2","C2_NUM")
	EndDo

	AADD(aVetor, {"C2_NUM"		, cNumOP							,Nil})
	AADD(aVetor, {"C2_ITEM"		, "01"		   						,Nil})
	AADD(aVetor, {"C2_SEQUEN" 	, "001"								,Nil})
	AADD(aVetor, {"C2_PRODUTO"	, cProduto							,Nil})
	AADD(aVetor, {"C2_QUANT"  	, nTotProd	                        ,Nil})
	AADD(aVetor, {"C2_LOCAL"  	, oFieldDXM:GetValue("DXM_LOCAL")	,Nil})
	AADD(aVetor, {"C2_DATPRI" 	, ddatabase							,Nil})
	AADD(aVetor, {"C2_DATPRF" 	, ddatabase							,Nil})
	AADD(aVetor, {"C2_EMISSAO"	, ddatabase     					,Nil})
	AADD(aVetor, {"C2_TPOP"  	, "F"           					,Nil})
	AADD(aVetor, {"C2_AGLUT"  	, "N"           					,Nil})
	AADD(aVetor, {'AUTEXPLODE'	, 'N'								,Nil})

	/* Permite manipular os dados antes executar a rotina automatica para criar a ordem de produção	*/
	If ExistBlock("AGR600OP")
		aRet := ExecBlock("AGR600OP",.F.,.F.,{aVetor})
		If ValType(aRet) == "A"
			aVetor := aClone(aRet)
		EndIf
	EndIf

	//-----------------------------
	// Executa a rotina automatica
	//-----------------------------
	MSExecAuto({|x,y| mata650(x,y)},aVetor,nOperac) // 3=Inclusao, 5=Exclusão

	If lMsErroAuto
		MostraErro()
		RollBackSx8()
	Else
		cNumOP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
		ConfirmSx8()
	EndIf

	nModulo := nModuloOld

	RestInter()  //Restaura as variaveis publicas
	RestArea(aAreaDXM)
	RestArea(aArea)
Return(!lMsErroAuto)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A600APROD
Aponta a ordem de produção para gerar saldos em estoque do produto

@param: cNumOP - Numero da Ordem de Produção
@param: oModel - Modelo de dados da rotina
@param: cProduto - Código do produto
@param: nOperac - Código da operação 3=Inclusao, 5=Exclusão
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function A600APROD(cNumOP, oModel, cProduto, nOperac, nTotProd)
	Local oFieldDXM	 := oModel:GetModel("MdFieldDXM")
	Local aMata      := {}
	Local aVetor	 := {}
	Local cNumDoc    := ""
	Local cTM        := SuperGetMV("MV_AGRTMPR",.F.,"")
	Local nModuloOld := nModulo

	Default cNumOP	 := CriaVar("D3_OP")
	Default nTotProd := oFieldDXM:GetValue("DXM_PSLIQU")
	//---------------------------------------------------------
	// Busca o numero do documento de movimentação de estoque
	//---------------------------------------------------------
	If nOperac == 3
		cNumDoc   := NextNumDoc()
	Else
		cNumDoc	  := oFieldDXM:GetValue("DXM_NUMDOC")
	EndIf

	//---------------------------------
	// Posiciona no codigo do produto
	//---------------------------------
	Posicione("SB1",1,FwXFilial("SB1")+cProduto,"B1_COD")

	//-------------------------------
	// Adiciona os dados em um vetor
	//-------------------------------
	AADD(aMata, {"D3_TM"     , cTM           						,Nil})
	AADD(aMata, {"D3_COD"    , SB1->B1_COD  						,Nil})
	AADD(aMata, {"D3_UM"     , SB1->B1_UM    						,Nil})
	AADD(aMata, {"D3_QUANT"  , nTotProd                         	,Nil})
	AADD(aMata, {"D3_LOCAL"  , oFieldDXM:GetValue("DXM_LOCAL")	,Nil})
	AADD(aMata, {"D3_DOC"    , cNumDoc       						,Nil})
	AADD(aMata, {"D3_OP"     , cNumOP	        					,Nil})
	AADD(aMata, {"D3_EMISSAO", dDataBase     						,Nil})
	AADD(aMata, {"AUTPRTOTAL", "S"           						,Nil})

	//---------------------------------
	// Quando produto controlar rastro
	//---------------------------------
	If Rastro(SB1->B1_COD)
		AADD(aMata, {"D3_LOTECTL", oFieldDXM:GetValue('DXM_CODIGO'), Nil})
		If nOperac == 3
			AADD(aMata, {"D3_DTVALID", dDataBase+SB1->B1_PRVALID	, Nil})
		EndIf
	EndIf

	/* Permite manipular os dados antes de executar a rotina automatica de apontamento da produção 	*/
	If ExistBlock("AGR600PR")
		aRet := ExecBlock("AGR600PR",.F.,.F.,{aMata})
		If ValType(aRet) == "A"
			aMata := aClone(aRet)
		EndIf
	EndIf

	//-----------------------
	// Seta modulo para PCP
	//-----------------------
	nModulo := 10

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	If  nOperac = 5
		DbSelectArea("SD3")
		DbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
		MsSeek(FwXFilial("SD3") + cNumOP + SB1->B1_COD + oFieldDXM:GetValue("DXM_LOCAL"))
	Endif
	//-----------------------------
	// Executa rotina a automatica
	//-----------------------------
	MsExecAuto( { |x,y| MATA250(x,y)},aMata,nOperac ) // 3=Inclusao, 5=Exclusao

	If nOperac == 5 .And. !lMsErroAuto
		AADD(aVetor,{"C2_NUM" 		, Substr(cNumOP,1 ,TamSx3("C2_NUM")[1]), NIL}) //Numero da OP
		AADD(aVetor,{"C2_ITEM"		, SubStr(cNumOP,TamSx3("C2_NUM")[1]+1,TamSx3("C2_ITEM")[1]), NIL}) //Item da OP
		AADD(aVetor,{"C2_SEQUEN"	, SubStr(cNumOP,TamSx3("C2_ITEM")[1]+1,TamSx3("C2_SEQUEN")[1]), NIL}) //Sequencia da OP
		//-----------------------------
		// Executa rotina a automatica
		//-----------------------------
		MSExecAuto({|x,y| mata650(x,y)},aVetor,nOperac)
	Endif

	nModulo := nModuloOld

	If lMsErroAuto
		MostraErro()
	ElseIf 	nOperac == 3
		oFieldDXM:SetValue("DXM_OP",cNumOP)			//Relaciona a OP ao Romaneio
		oFieldDXM:SetValue("DXM_NUMDOC",cNumDoc)	//Relaciona o numero do documento da movimentação de estoque ao romaneio
	EndIf

Return(!lMsErroAuto)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} NextNumDoc()
Retorna o proximo numero de documento disponivel

@param: Nil
@author: Equipe Agroindustria
@since: 26/11/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= ""
	Local cMay		:= ""

	//----------------------------------------------------
	//Inicializa o numero do Documento com o ultimo + 1 
	//----------------------------------------------------
	dbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	cNumDoc := A261RetINV(cNumDoc)
	dbSetOrder(2)
	MsSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		dbSkip()
	EndDo

	RestArea( aAreaAtu )
Return( cNumDoc )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600F3
Filtro da consulta padrão para retornar as notas fiscais de entrada

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600F3()
	Local aArea		:= GetArea()
	Local oModel	:= FWModelActive()
	Local oFieldDXM	:= oModel:GetModel('MdFieldDXM')
	Local cTipo		:= If(oFieldDXM:GetValue("DXM_PROPRI") == "1" .AND. oFieldDXM:GetValue("DXM_ORIGEM") == "2", "N", "B") // Tipo da nota fiscal de entrada
	Local cLocal	:= oFieldDXM:GetValue('DXM_LOCAL')
	Local cProduto	
	Local cCliFor	:= ""
	Local cLjCliFor := ""

	if __lNovSafra
		cProduto := oFieldDXM:GetValue('DXM_CODPRO')
	else
		cProduto := Posicione("NN1",1,FwXFilial("NN1")+oFieldDXM:GetValue('DXM_SAFRA'),"NN1_CODPRO")
	endIf

	If NJ0->(ColumnPos("NJ0_ID")) > 0 //Troca de Produtor para Entidade
		cTab := "NJ0"					
	Else
		cTab := "DX8"
	EndIf

	//-------------------------------------------------
	// Busca cliente e fornecedor amarrado ao produtor
	//-------------------------------------------------

	If cTab == "NJ0"
		dbSelectArea("NJ0")
		dbSetOrder(1)
		If MsSeek(fwxFilial("NJ0")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
			cCliFor 	:= If(cTipo == "N", NJ0->NJ0_CODFOR, NJ0->NJ0_CODCLI )
			cLjCliFor	:= If(cTipo == "N", NJ0->NJ0_LOJFOR, NJ0->NJ0_LOJCLI )
		EndIf
	ElseIf cTab =="DX8"
		dbSelectArea("DX8")
		dbSetOrder(1)
		If dbSeek(xFilial("DX8")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
			cCliFor 	:= If(cTipo == "N", DX8->DX8_FORNEC, DX8->DX8_CLIENT )
			cLjCliFor	:= If(cTipo == "N", DX8->DX8_LJFOR, DX8->DX8_LJCLI )
		EndIf
	EndIf

	dbSelectArea("SD1")
	cRet := '@#D1_FILIAL=="'+FwXFilial("SD1")+'" .And. D1_FORNECE=="'+cCliFor+'" .And. D1_LOJA=="'+cLjCliFor+'"
	cRet +=	'.And. D1_COD=="'+cProduto+'" .And. D1_LOCAL=="'+cLocal+'"@#'

	RestArea(aArea)
Return cRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A600FDFLTR
Filtro da consulta de Fardão disponíveis para associação em Romaneios de Entrada e Romaneios 
de Transferência/Saída

@param: Nil
@author: Bruna Fagundes Rocio
@since: 30/08/2016
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function A600FDFLTR()
	Local aArea  := GetArea()
	Local cRet   := ""

	If FwFldGet('DXM_TIPMOV') = '1' //Entrada
		cRet := '@#(Empty(DXL->DXL_CODROM) .And. DXL->DXL_STATUS = "1" .And. (DXL->(DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ) = M->(DXM_SAFRA+DXM_PRDTOR+DXM_LJPRO+DXM_FAZ)))@#'
	Else
		cRet := '@#(!Empty(DXL->DXL_CODROM) .And. DXL->DXL_STATUS = "3" .And. (DXL->(DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ) = M->(DXM_SAFRA+DXM_PRDTOR+DXM_LJPRO+DXM_FAZ)))@#'
	Endif

	RestArea(aArea)
Return cRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600NFE
Validaçao da nota fiscal de entrada

@param: Nil
@author: Equipe Agroindustria
@since: 21/08/2012
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600NFE()
	Local aArea 	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oFieldDXM	:= oModel:GetModel("MdFieldDXM")
	Local lRet 		:= .T.

	// -------------------------------------------                                                  
	// Valida digitação manual da nota de entrada
	// -------------------------------------------   
	If ! IsBlind()                                                
		If !IsInCallStack("GETLKRET")
			lRet := .F.
			oFieldDXM:LoadValue("DXM_NOTA"  , "")
			oFieldDXM:LoadValue("DXM_SERIE" , "")
			oFieldDXM:LoadValue("DXM_VLFISC", 0 )
			oFieldDXM:LoadValue("DXM_PSFISC", 0 )
			Help("",1,STR0015,,STR0035,1) //"Atenção!"###"Para selecionar a nota fiscal é necessário pressionar a tecla [F3]."
		EndIf
	EndIf
	RestArea(aArea)
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA600VFD
Validação do código do fardão

@param:  Nil
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
/*/
//------------------------------------------------------------------------------------------
Function AGRA600VFD()
	Local oModel 	:= FwModelActive()
	Local oFieldDXM := oModel:GetModel("MdFieldDXM")
	Local oGridDX0  := oModel:GetModel("MdGridDX0")
	Local cFardao	:= oGridDX0:GetValue("DX0_FARDAO")
	Local cSafra	:= oFieldDXM:GetValue("DXM_SAFRA")
	Local cProdutor := oFieldDXM:GetValue("DXM_PRDTOR")
	Local cLjPro	:= oFieldDXM:GetValue("DXM_LJPRO")
	Local cFazenda  := oFieldDXM:GetValue("DXM_FAZ")
	Local lRet 	    := .T.
	Local cProduto

	if __lNovSafra
		cProduto  := oFieldDXM:GetValue("DXM_CODPRO")
	endIf

	DXL->(dbSelectArea("DXL"))
	DXL->(dbSetOrder(1))
	DXL->(DBClearFilter())

	If !DXL->(MsSeek(FwXFilial("DXL")+cFardao+cSafra+cProdutor+cLjPro+cFazenda))		
		AgrHelp(STR0015,STR0070+cFardao+STR0083,STR0084) //##O Fardão ##" é invalido para o item do romaneio de entrada." ##"Informe o Fardão conforme informações de safra, entidade, loja e fazenda do romaneio."
		lRet := .F.
	EndIf

	if __lNovSafra
		If lRet .And. DXL->DXL_CODPRO != cProduto
			oModel:SetErrorMessage( , , , , , STR0070+cFardao+STR0071)
			lRet := .F.		
		EndIf
	endIf

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600RFD
Rateio dos Fardões associados ao romaneio

@param:  Nil
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600RFD()
	Local oModel 	  := FwModelActive()
	Local oFieldDXM   := oModel:GetModel("MdFieldDXM")
	Local oGridDX0    := oModel:GetModel("MdGridDX0")
	Local cFardao	  := oGridDX0:GetValue("DX0_FARDAO")
	Local cSafra	  := oFieldDXM:GetValue("DXM_SAFRA")
	Local cProdutor   := oFieldDXM:GetValue("DXM_PRDTOR")
	Local cLjPro	  := oFieldDXM:GetValue("DXM_LJPRO")
	Local cFazenda    := oFieldDXM:GetValue("DXM_FAZ")
	Local nPsLiqu	  := oFieldDXM:GetValue("DXM_PSLIQU")
	Local nPsFisc     := oFieldDXM:GetValue("DXM_PSFISC")
	Local nLinha 	  := oGridDX0:GetLine()
	Local lRet 	      := .T.
	Local nX          := 0
	Local nY          := 0 
	Local nTam        := 0
	Local nPerc       := 0
	Local nTotal      := 0
	Local nResto      := 0
	Local oView       := FwViewActive()

	If FwFldGet('DXM_TIPMOV') = '2' //Saída 
		dbSelectArea("DXL")
		dbSetOrder(1)
		MsSeek(FwXFilial("DXL")+cFardao+cSafra+cProdutor+cLjPro+cFazenda)
		If Empty(DXL->DXL_CODROM)
			Help("",1,STR0035,,STR0065,1)
			lRet := .F.
		Else
			If DXL->DXL_STATUS != '3' //Disponível
				Help("",1,STR0035,,STR0066,1)
				lRet := .F.
			Endif			
		EndIf	 
	Else //Entrada
		dbSelectArea("DXL")
		dbSetOrder(1)
		MsSeek(FwXFilial("DXL")+cFardao+cSafra+cProdutor+cLjPro+cFazenda)
		If !empty(DXL->DXL_CODROM)
			Help("",1,STR0035,,STR0067,1) //Fardão já lançado em romaneio
			lRet := .F.
		EndIf   	
	Endif

	If lRet
		For nY := 1 to oGridDX0:Length()
			oGridDX0:GoLine( nY )
			If !oGridDX0:isDeleted()
				nTam ++
			Endif
		Next nY

		nPerc  := Round((100 / nTam), 2)
		nTotal := Round((nPerc * nTam),2)

		If nTotal <> 100
			nResto := 100 - nTotal
		Endif

		For nX := 1 to oGridDX0:Length()
			oGridDX0:GoLine( nX )

			If !oGridDX0:IsDeleted() 
				If nX = 1
					oGridDX0:LoadValue("DX0_RATEIO", (nPerc + nResto))
					nPsRat    := ( (nPsLiqu/100) * (nPerc + nResto) )
					nPsRatFis := ( (nPsFisc/100) * (nPerc + nResto) )
				Else
					oGridDX0:LoadValue("DX0_RATEIO", nPerc)
					nPsRat := ( (nPsLiqu/100) * nPerc )
					nPsRatFis := ( (nPsFisc/100) * nPerc )
				Endif

				//--------------------------------------------------------
				// Atualiza o peso liquido e fiscal do fardao no romaneio
				//--------------------------------------------------------
				oGridDX0:LoadValue("DX0_PSLIQU", round(nPsRat,1))
				oGridDX0:LoadValue("DX0_PSFISC", round(nPsRatFis,1))
			Endif
		Next nX		
	Endif
	If  .NOT.IsBlind()
		ReAtuRateio(oView)
	EndIf
	oGridDX0:GoLine(nLinha)
Return(lRet)


/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600POS
Pos Validação do modelo de dados da rotina

@param:  oModel - Modelo de dados da rotina
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function AGRA600POS(oModel)
	Local oFieldDXM   := oModel:GetModel("MdFieldDXM")
	Local lRet		 := .T.
	Local nOperac	 := oModel:GetOperation()
	Local cTipo		 := If(FwFldGet("DXM_PROPRI") == "1" .AND. FwFldGet("DXM_ORIGEM") == "2", "N", "B") // Tipo da nota fiscal de entrada
	Local cCliFor	 := ""
	Local cLjCliFor  := ""
	Local cAlDXMNF   := GetNextAlias()
	Local cTab  	:= ""

	If NJ0->(ColumnPos("NJ0_ID")) > 0 //Troca de Produtor para Entidade
		cTab := "NJ0"					
	Else
		cTab := "DX8"
	EndIf
	If IsInCallStack("AGRA600C")
		nOperac := 5
	EndIf

	//-------------------------------------------------
	// Busca cliente e fornecedor amarrado ao produtor
	//-------------------------------------------------
	If cTab == "NJ0"
		dbSelectArea("NJ0")
		dbSetOrder(1)
		If MsSeek(fwxFilial("NJ0")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
			cCliFor 	:= If(cTipo == "N", NJ0->NJ0_CODFOR, NJ0->NJ0_CODCLI )
			cLjCliFor	:= If(cTipo == "N", NJ0->NJ0_LOJFOR, NJ0->NJ0_LOJCLI )
		EndIf
		NJ0->(DbCloseArea())
	ElseIf cTab == "DX8"
		dbSelectArea("DX8")
		dbSetOrder(1)
		If dbSeek(xFilial("DX8")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO"))
			cCliFor 	:= If(cTipo == "N", DX8->DX8_FORNEC, DX8->DX8_CLIENT )
			cLjCliFor	:= If(cTipo == "N", DX8->DX8_LJFOR, DX8->DX8_LJCLI )
		EndIf
		DX8->(DbCloseArea())
	EndIf


	If nOperac # MODEL_OPERATION_DELETE

		lRet := .T.
		If FwFldGet('DXM_TIPMOV') = '1' /* Entrada */ 

			If !Empty(FwFldGet('DXM_ROMORI'))

				dbSelectArea('DXM')
				dbSetOrder(1)
				If MsSeek(FwXFilial('DXM')+FwFldGet('DXM_ROMORI'))
					If DXM->DXM_TIPMOV # '2' //Diferente de Saída
						lRet := .F.
						Help("",1,STR0037,,STR0060,1) //"Atenção"###"É necessário que o tipo do Romaneio Origem ser do tipo Saída."
					ElseIf DXM->DXM_STATUS # '2' //Diferente de Encerrado
						lRet := .F.
						Help("",1,STR0037,,STR0061,1) //"Atenção"###"É necessário que o Romaneio Origem tenha seu status como Encerrado."
					Endif
				Endif
			EndIf

			If FwFldGet('DXM_ORIGEM') = '2' /* Doc. Entrada */
				If Empty(FwFldGet('DXM_NOTA')) .Or. Empty(FwFldGet('DXM_SERIE'))
					lRet := .F.
					Help("",1,STR0037,,STR0062,1) //"Atenção"###"A origem selecionada é Documento de Entrada. Por favor, informe nota e série."
				Else

					DXM-> (dbSetOrder(3))
					If DXM->(dbSeek(xFilial("DXM")+;
						oFieldDXM:GetValue("DXM_NOTA")+;
						oFieldDXM:GetValue("DXM_SERIE")+;
						oFieldDXM:GetValue("DXM_ITEMNF")+;
						oFieldDXM:GetValue("DXM_PRDTOR")+;
						oFieldDXM:GetValue("DXM_LJPRO")))

						While !DXM->(Eof()) .AND. ;
							DXM->DXM_NOTA = oFieldDXM:GetValue("DXM_NOTA") .AND. ;
							DXM->DXM_SERIE = oFieldDXM:GetValue("DXM_SERIE") .AND.;
							DXM->DXM_ITEMNF =  oFieldDXM:GetValue("DXM_ITEMNF") .AND.;
							DXM->DXM_PRDTOR = oFieldDXM:GetValue("DXM_PRDTOR") .AND.;
							DXM->DXM_LJPRO =  oFieldDXM:GetValue("DXM_LJPRO")
					
							If  nOperac <> 4 .AND. DXM->DXM_STATUS <> '3'
								Help("",1,STR0015,,STR0036,1,0,,,,,,{STR0075}) //Atenção."A Nota Fiscal selecionada já foi vinculada a um romaneio entrada!"  "Informe o número de outro Documento de Entrada"    
								Return lRet := .F.
							EndIf
							DXM->(dbSkip())
						EndDo   
					EndIf

					//Tratado com produtor pois esta é a informação gravada na DXM, 
					//contra verificações na tabela origem, deve ser verificado se faz uso de
					//cliente ou fornecedor (formulário próprio)
					BeginSql Alias cAlDXMNF
						Select * From %table:DXM% DXM
						WHERE DXM.%notDel% 
						AND DXM.DXM_FILIAL = %xFilial:DXM%
						AND DXM.DXM_NOTA   = %exp:FwFldGet('DXM_NOTA')%
						AND DXM.DXM_SERIE  = %exp:FwFldGet('DXM_SERIE')%
						AND DXM.DXM_PRDTOR = %exp:FwFldGet('DXM_PRDTOR')%
						AND DXM.DXM_LJPRO  = %exp:FwFldGet('DXM_LJPRO')%
					EndSql

					DbGoTop()
					If (cAlDXMNF)->(Reccount()) > 0 .And. (cAlDXMNF)->(!Eof()) .And. !Empty(DXM->DXM_PSLIQU)
						lRet := .F.
						Help("",1,STR0037,,STR0063,1) //"Atenção"###"Nota já associada a um romaneio de entrada."
					Else
						dbSelectArea('SD1')
						dbSetOrder(1)
						If !MsSeek(FwXFilial('SD1')+FwFldGet('DXM_NOTA')+FwFldGet('DXM_SERIE')+cCliFor+cLjCliFor)
							lRet := .F.
							Help("",1,STR0037,,STR0064,1) //"Atenção"###"Nota informada não existe. Por favor, informe um documento válido."
						Endif
					EndIf

					(cAlDXMNF)->(dbCloseArea())
				EndIf
			EndIf
		Endif
	Endif

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA600LOK
Validação linha OK

@param:  Nil
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function AGRA600LOK(oGrid)
	Local lRet 			:= .T.
	Local nOperac	    := oGrid:GetOperation()

	// Se opcao de MENU cancelar, trata operacao como EXCLUIR
	If IsInCallStack("AGRA600C")
		nOperac := 5
	EndIf

	// Se operacao diferente de EXCLUIR
	If nOperac # MODEL_OPERATION_DELETE
		If Rateio(oGrid) > 100
			lRet := .F.
			Help("",1,STR0037,,STR0039,1) //"Atenção"###"O total de rateio da carga entre os itens não pode ser superior a 100%"
		EndIf
	EndIf

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} Rateio
Retorna o soma do percentual de rateio da caraga entre os itens

@param:  oGrid - Modelo de dados da Grid
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Static Function Rateio(oGrid)
	Local nRateio := 0
	Local nX	  := 0

	For nX := 1 To oGrid:Length(.T.)
		nRateio += oGrid:GetValue("DX0_RATEIO",nX)
	Next nX
Return(nRateio)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} Rateio
Retorna o soma do percentual de rateio da carga entre os itens

@param:  oGrid - Modelo de dados da Grid
@author: Equipe Agroindustria
@since:  20/03/2013
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGRA600T()

	FWExecView('', 'VIEWDEF.AGRA600', MODEL_OPERATION_INSERT, , {|| .T. })
Return .T.

Function A600ROMORI()

Return .T.

/** ------------------------------------------------------------------------------------------
{Protheus.doc} Validação Safra para preenchimento automático dos campos do Romaneio de Origem
para o romaneio de transferencia

@author: Bruna Fagundes Rocio
@since:  29/08/2016
@Uso: AGRA600
------------------------------------------------------------------------------------------ **/
Function AGR600VLDS()
	Local aArea   := GetArea()
	Local oModel  := FWModelActive()
	Local oGrdDX0 := oModel:GetModel('MdGridDX0')

	If FwFldGet('DXM_TIPMOV') = '1' //Saída

		dbSelectArea('DXM')
		dbSetOrder(1)
		If MsSeek(FwXFilial('DXM')+FwFldGet('DXM_ROMORI'))

			FwFldPut('DXM_PRDTOR',DXM->DXM_PRDTOR)
			FwFldPut('DXM_LJPRO' ,DXM->DXM_LJPRO)
			FwFldPut('DXM_NMPDTR',Posicione('NJ0',1,FwXFilial('NJ0')+DXM->DXM_PRDTOR+DXM->DXM_LJPRO,'NJ0_NOME'))
			FwFldPut('DXM_FAZ'   ,DXM->DXM_FAZ)
			FwFldPut('DXM_LOCAL' ,DXM->DXM_LOCAL)
			FwFldPut('DXM_PLACA' ,DXM->DXM_PLACA)

		Endif

		DX0->(dbSelectArea('DX0'))
		DX0->(dbSetOrder(1))
		If DX0->(MsSeek(FwXFilial('DX0')+FwFldGet('DXM_ROMORI')))
			While !DX0->(Eof())                    .And.;
			DX0->DX0_FILIAL = FwXFilial('DX0') .And.;
			DX0->DX0_CODROM = FwFldGet('DXM_ROMORI')

				oGrdDX0:AddLine()

				oGrdDX0:SetValue('DX0_CODROM',FwFldGet('DXM_CODIGO'))
				oGrdDX0:SetValue('DX0_ITEM'  ,oGrdDX0:Length()+1)
				oGrdDX0:LoadValue('DX0_FARDAO',DX0->DX0_FARDAO)
				oGrdDX0:SetValue('DX0_CODPRO',DX0->DX0_CODPRO)
				oGrdDX0:SetValue('DX0_CODVAR',DX0->DX0_CODVAR)
				oGrdDX0:SetValue('DX0_TALHAO',DX0->DX0_TALHAO)

				DX0->(dbSkip())
			EndDo
		EndIf
	Endif

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} TransfIntern
//
@author bruna.rocio
@since 01/09/2016
@version undefined
@param cTM, character, TM para movimentação (Transferencia ou Devolução)
@param cProduto, character, produto alvo da movimentação
@param nQuant, numeric, quantidade a ser movimentada
@param cLocal, character, local da transferencia do produto
@param nOperac, numeric, indica a operação a ser executada (3 = Inclusão, 5 = Estorno)
@param cRomaneio, character, indica o código do romaneio
@type function
/*/
Static Function TransfIntern(cTM, cProduto, nQuant, cLocal, nOperac, cRomaneio, cNumDoc)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local aMata 	:= {}
	Local aItens    := {}
	Local aCab		:= {}
	Local nModuloOld := nModulo
	Local dValid	:= CTOD("")
	Local nx		:= 0

	//------------------------------
	// Seta o modulo para estoque³
	//------------------------------
	nModulo := 4

	AADD(aCab,{"D3_FILIAL" 	,	FwXFilial("SD3")		,Nil} )
	AADD(aCab,{"D3_DOC"    	,	cNumDoc		 		,Nil} )
	AADD(aCab,{"D3_TM" 		,	cTM					,Nil} )
	AADD(aCab,{"D3_EMISSAO" ,  ddatabase				, Nil } ) // Data de Emissão

	AADD( aItens, {} )
	AADD(aTail(aItens),{"D3_COD"    	,cProduto		 		,Nil} )
	AADD(aTail(aItens),{"D3_QUANT"  	,nQuant					,Nil} )
	AADD(aTail(aItens),{"D3_LOCAL"  	,cLocal			 		,Nil} )
	AADD(aTail(aItens),{"D3_LOCALIZ"	,CriaVar("D3_LOCALIZ")	,Nil} )
	
	If Rastro(cProduto)
		If 	SB1->(MsSeek(FwXFilial("SB1")+cProduto))
			dValid := dDatabase+SB1->B1_PRVALID
		EndIf
		AADD(aTail(aItens), {"D3_LOTECTL",cRomaneio					,Nil} )
		AADD(aTail(aItens), {"D3_NUMLOTE",CriaVar("D3_NUMLOTE")		,Nil} )
		AADD(aTail(aItens), {"D3_DTVALID",dValid					,Nil} )
	EndIf

	If	nOperac == 6 //Estorno
		dbSelectArea('SD3')
		SD3->( dbSetOrder( 2 ) )
		If SD3->( dbSeek( xFilial( "SD3" ) + cNumDoc +  cProduto) ) //POSICIONA NO REGISTRO A SER ESTORNADO
			If SD3->D3_ESTORNO == "S"
				nModulo := nModuloOld
				Return .T. //registro já estornado, trata estorno manual, retorna .T. para cancelar O romaneio de transferencia
			EndIf
		EndIf
	Endif

	//----------------------------------------------------------------------------------- 
	//	Permite manipular os dados antes de executar a rotina automatica de movimentação
	//	 interna para transferência interna de fardão
	//-----------------------------------------------------------------------------------
	If ExistBlock("AGR600TRI")
		If GetRpoRelease() <= "12.1.033"
			//trata para não mexer no PE quando release 33 e inferiores
			aMata := {}
			aMata := aClone(aCab)
			For nx := 1 To Len(aItens[1]) //aItens tem apenas um array de itens
				Aadd( aMata, aItens[1][nX])
			Next nx
			aRet := ExecBlock("AGR600TRI",.F.,.F.,{aMata})
			If ValType(aRet) == "A" 
				aCab := {}
				aItens := {} 
				AADD( aItens, {} )
				For nx := 1 To Len(aRet)	
					If UPPER( Alltrim( aRet[nx][1] ) ) $ "D3_FILIAL|D3_DOC|D3_TM|D3_EMISSAO"
						Aadd(aCab, aRet[nX])
					Else
						Aadd(aTail(aItens), aRet[nX])
					EndIf
				Next nx
			EndIf
		Else
			//apartir da release P12.1.2210 o PE é ajustado para tratar os 2 array em separado, cabeçalho e itens.
			aRet := ExecBlock("AGR600TRI",.F.,.F.,{aCab,aItens})
			If ValType(aRet) == "A" .AND. Len(aRet) > 1
				aCab 	:= aClone(aRet[1])
				aItens 	:= aClone(aRet[2])
			EndIf
		EndIf
	EndIf

	Private	lMSErroAuto := .F.
	Private	lMSHelpAuto := .T.

	MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItens,nOperac)

	If lMSErroAuto
		lRet := .F.
		MostraErro()	
	EndIf

	nModulo := nModuloOld

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} LiberaPed
//Função para liberação de pedido de venda
@author bruna.rocio
@since 02/09/2016
@version undefined
@param cNumPed, characters, descricao
@type function
/*/
Static Function LiberaPed(cNumPed,cCliente)
	Local aArea := GetArea()
	Local lRet  := .T.

	//Variaveis privadas utilizadas nas rotinas MATA	
	Private lTransf     := .f.
	Private lLiber      := .t.
	Private lSugere     := .f.
	Private bFiltraBrw  := {|| Nil}

	//Verifica se gera o estoque bloqueado
	If SuperGetMv("MV_GERABLQ")=="S" .And. lRet
		Pergunte("MTALIB",.F.)
		//³ mv_par01 Ordem Processmento ?  Ped.+Item /Dt.Entrega+Ped.+Item         ³
		//³ mv_par02 Pedido de          ?                                          ³
		//³ mv_par03 Pedido ate         ?                                          ³
		//³ mv_par04 Cliente de         ?                                          ³
		//³ mv_par05 Cliente ate        ?                                          ³
		//³ mv_par06 Dta Entrega de     ?                                          ³
		//³ mv_par07 Dta Entrega ate    ?                                          ³
		//³ mv_par08 Liberar            ? Credito/Estoque Credito                  ³
		MV_PAR01 := 1
		MV_PAR02 := cNumPed  
		MV_PAR03 := cNumPed
		MV_PAR04 := cCliente
		MV_PAR05 := cCliente
		MV_PAR06 := dDatabase
		MV_PAR07 := dDatabase
		MV_PAR08 := 1

		//Cria a SC9 e Libera Estoque															
		MsAguarde({|| lRet := a440Proces(,,,@lRet)},"Aguarde...","Liberando pedido de venda...") //"Aguarde..."###"Liberando pedido de venda..."
	Endif

	If lRet
		//Verifica se gera o crédito bloqueado		
		If SuperGetMv("MV_BLOQUEI")
			//Avalia e Libera Crédito
			dbSelectArea("SC9")
			dbSetOrder(1)
			If MsSeek(FwXFilial("SC9")+cNumPed)
				If !(SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  ")
					//Função de Liberação de Crédito
					A450LibMan()
				Endif
			Endif	
		Endif						
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetPrice
//Retorno de Valor Unitário para o Pedido
@author bruna.rocio
@since 09/09/2016
@version undefined
@param cNota, characters, descricao
@param cSerie, characters, descricao
@type function
/*/
Static Function GetPrice(cProduto, cLocal)
	Local aArea := GetArea()
	Local nVlUn := 0

	dbSelectArea('SB2')
	dbSetOrder(1)
	If MsSeek(FwXFilial('SB2')+cProduto+cLocal)
		nVlUn := SB2->B2_CM1
	Endif

	RestArea(aArea)
Return nVlUn


/*/{Protheus.doc} ReAtuRateio
//Realiza o recalculo do rateio na exclusão de um item do romaneio e atualiza as linhas da grid
@author bruna.rocio
@since 30/06/2017
@version undefined
@param oView, object, descricao
@type function
/*/
Static Function ReCalcRateio(oView)
	Local oModel 	  := FwModelActive()
	Local oFieldDXM   := oModel:GetModel("MdFieldDXM")
	Local oGridDX0    := oModel:GetModel("MdGridDX0")
	Local nPsLiqu	  := oFieldDXM:GetValue("DXM_PSLIQU")
	Local nPsFisc     := oFieldDXM:GetValue("DXM_PSFISC")
	Local lRet 	      := .T.
	Local nX          := 0
	Local nY          := 0 
	Local nTam        := 0
	Local nPerc       := 0
	Local nTotal      := 0
	Local nResto      := 0
	Local aSaveLines     := FWSaveRows()

	For nY := 1 to oGridDX0:Length()
		oGridDX0:GoLine( nY )
		If !oGridDX0:isDeleted()
			nTam ++
		Endif
	Next nY

	nPerc  := Round((100 / nTam), 2)
	nTotal := Round((nPerc * nTam),2)

	If nTotal <> 100
		nResto := 100 - nTotal
	Endif

	For nX := 1 to oGridDX0:Length()
		oGridDX0:GoLine( nX )

		If !oGridDX0:IsDeleted() 
			If nX = 1
				oGridDX0:LoadValue("DX0_RATEIO", (nPerc + nResto))
				nPsRat    := ( (nPsLiqu/100) * (nPerc + nResto) )
				nPsRatFis := ( (nPsFisc/100) * (nPerc + nResto) )
			Else
				oGridDX0:LoadValue("DX0_RATEIO", nPerc)
				nPsRat := ( (nPsLiqu/100) * nPerc )
				nPsRatFis := ( (nPsFisc/100) * nPerc )
			Endif

			//--------------------------------------------------------
			// Atualiza o peso liquido e fiscal do fardao no romaneio
			//--------------------------------------------------------
			oGridDX0:LoadValue("DX0_PSLIQU", round(nPsRat,1))
			oGridDX0:LoadValue("DX0_PSFISC", round(nPsRatFis,1))
		Endif

	Next nX		

	FWRestRows(aSaveLines)
	oView:Refresh('VIEW_DX0')	
Return(lRet)


/*/{Protheus.doc} ReAtuRateio
//Atualiza as linhas após a inserção de um novo fardão nos itens do romaneio
@author joaquim.burjack
@since 02/07/2017
@version undefined
@param oView, object, descricao
@type function
/*/
Static Function ReAtuRateio(oView)
	Local aSaveLines     := FWSaveRows()
	Local lRet			 := .T.

	FWRestRows(aSaveLines)
	oView:Refresh('VIEW_DX0')	
Return(lRet)


/*/{Protheus.doc} AGRA600VIC
//Verifica todos os fardoes do romaneio para liberar os fardoes que nao estao mais vinculados
@author ana.olegini
@since  10/08/2018
@version undefined
@param oModel, object, Modelo de dados 
@type function
/*/
Function AGRA600VIC(oModel)
	Local lRetorno	:= .T.
	Local nX		:= 0
	Local aDXL		:= {}
	Local aDX0		:= {}
	Local cQuery	:= ""
	Local cTempDXL	:= GetNextAlias()
	Local oFieldDXM	:= oModel:GetModel('MdFieldDXM')
	Local oGridDX0	:= oModel:GetModel('MdGridDX0')	

	//--Busca todos os fardoes salvos do romaneio 
	cQuery := " SELECT * "
	cQuery +=   " FROM " + RetSqlName("DXL") + " DXL"
	cQuery +=  " WHERE DXL.D_E_L_E_T_ 	= '' "
	cQuery +=    " AND DXL.DXL_FILIAL 	= '"+ FWxFilial("DXL") +"'"
	cQuery +=    " AND DXL_CODROM 		= '"+ oFieldDXM:GetValue("DXM_CODIGO") +"'"
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTempDXL,.T.,.T.)
	While .Not. (cTempDXL)->(Eof()) .AND. (cTempDXL)->DXL_FILIAL == FWxFilial("DXL")
		AAdd(aDXL, { (cTempDXL)->DXL_FILIAL , (cTempDXL)->DXL_CODIGO })
		(cTempDXL)->( dbSkip() )
	EndDo
	(cTempDXL)->(dbCloseArea())

	//--Busca todos os fardoes atuais do romaneio
	For nX := 1 TO oGridDX0:Length()
		oGridDX0:GoLine( nX )
		If	.NOT. oGridDX0:IsDeleted()
			AAdd(aDX0, { oGridDX0:GetValue("DX0_FARDAO") })
		EndIf
	Next nX

	//--Realiza tratamento dos fardoes 
	//--Os fardoes que não estiverem no array aDX0 serão desvinculados do romaneio
	For nX := 1 TO Len(aDXL)
		If aScan( aDX0, { |x| AllTrim( x[1] ) ==  AllTrim(aDXL[nX][2]) } ) == 0
			DXL->(dbSelectArea("DXL"))
			DXL->(dbClearFilter())
			DXL->(dbSetOrder(1))
			If DXL->(MsSeek(FWxFilial("DXL")+ aDXL[nX][2] +oFieldDXM:GetValue("DXM_SAFRA")+oFieldDXM:GetValue("DXM_PRDTOR")+oFieldDXM:GetValue("DXM_LJPRO")))
				If RecLock("DXL",.F.)
					DXL->DXL_CODROM := ""
					DXL->DXL_STATUS := '1'	//--Previsto
					DXL->DXL_PSLIQU := 0
					DXL->DXL_CODUNB := ""
					MsUnlock("DXL")		
				Endif					
			EndIf
		EndIf
	Next nX
	DXL->(dbCloseArea())

Return(lRetorno)
