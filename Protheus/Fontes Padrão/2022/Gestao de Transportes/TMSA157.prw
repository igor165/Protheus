#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'tmsa157.ch'

Static cFieldsDA3 := "DA3_PLACA|DA3_COD|DA3_DESC|DA3_TIPVEI|DA3_FILATU|DA3_GSTDMD|DA3_FROVEI|DA3_STATUS|DA3_ATIVO|DA3_DESCFO|DA3_DESCMO" 

/*/{Protheus.doc} TMSA157
//Tela que sera exibida para a alteração dos campos e DA3_GSTDMD e DA3_FILATU
@author gustavo.baptista
@since 01/06/2018
@version 1.0
@type function
/*/
Function TMSA157(nFiltro, cCodVei)

	Local aCamposBrw   :={}
	Local aColsBrw     :={}
	Local aSX3Prop     := {}	
	Local oBrwCol      := Nil
	Local nx           := 0
	Local lMVITMSDMD   := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
	Local lRet         := .T.
	Local lLGPD        := FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr')
	Local cNomeDA4     := ""
	Local cNomeSA2     := ""
	
	Default nFiltro    := 1
	Default cCodVei    := ''
	
    Private oBrowse157
	Private cRetF3Esp  := ''
	
	//Limpa atalhos de teclas 
	TClearFKey()

	If lLGPD
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DA4_NOME"} )) == 0		
			cNomeDA4:= Replicate('*',TamSX3('DA4_NOME')[1])
		EndIf
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A2_NOME"} )) == 0		
			cNomeSA2:= Replicate('*',TamSX3('A2_NOME')[1])
		EndIf
	EndIf

	If lMVITMSDMD
		If nFiltro == 1
			If !Pergunte("TMSA157",.T.)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			aCamposBrw:= StrTOKARR( cFieldsDA3 , '|' )
	
			For nX := 1 To Len(aCamposBrw)
				aSX3Prop := TamSX3(aCamposBrw[nX]) 
				oBrwCol := FWBrwColumn():New()
				oBrwCol:SetType(aSX3Prop[3]) //tipo
				
				If aCamposBrw[nx] == "DA3_GSTDMD" 
					oBrwCol:SetData(&("{|| Iif(!Empty(DA3->DA3_GSTDMD),RetSX3Box(GetSX3Cache('"+aCamposBrw[nX]+"','X3_CBOX'),,,1)[&(DA3->"+aCamposBrw[nX]+")][3], ' ' )}"))
				ElseIf aCamposBrw[nx] == "DA3_FROVEI" 
					oBrwCol:SetData(&("{|| Iif(!Empty(DA3->DA3_FROVEI),RetSX3Box(GetSX3Cache('"+aCamposBrw[nX]+"','X3_CBOX'),,,1)[&(DA3->"+aCamposBrw[nX]+")][3], ' ' )}"))
				ElseIf aCamposBrw[nx] == "DA3_STATUS" .OR. aCamposBrw[nx] == "DA3_ATIVO"  
					oBrwCol:SetData(&("{||RetSX3Box(GetSX3Cache('"+aCamposBrw[nX]+"','X3_CBOX'),,,1)[&(DA3->"+aCamposBrw[nX]+")][3]}"))
				ElseIf aCamposBrw[nx] == "DA3_TIPVEI"
					oBrwCol:SetData(&("{||Posicione('DUT', 1, xFilial('DUT') +  DA3->DA3_TIPVEI, 'DUT_DESCRI') }"))
				ElseIf aCamposBrw[nx] == "DA3_DESCFO"
					oBrwCol:SetData(&("{||Iif(Empty(cNomeSA2),Posicione('SA2',1,XFILIAL('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR,'A2_NOME'),cNomeSA2) }"))
				ElseIf aCamposBrw[nx] == "DA3_DESCMO"
					oBrwCol:SetData(&("{||Iif(Empty(cNomeDA4),Posicione('DA4',1,XFILIAL('DA4')+DA3->DA3_MOTORI,'DA4_NOME'),cNomeDA4) }"))
				Else
					oBrwCol:SetData(&("{|| DA3->"+aCamposBrw[nX]+" }"))
				EndIf
				 
				oBrwCol:SetTitle(GetSx3Cache(aCamposBrw[nX],'X3_TITULO')) //Titulo
				oBrwCol:SetSize(aSX3Prop[1]) //Tamanho 
				oBrwCol:SetDecimal(0)  //Decimal
				oBrwCol:SetPicture(x3Picture(aCamposBrw[nX])) //Picture
				oBrwCol:SetReadVar(aCamposBrw[nX])
				AAdd(aColsBrw, oBrwCol)
			Next nX	
	
			oBrowse157 := FWMBrowse():New()
			oBrowse157:SetAlias('DA3')
			oBrowse157:SetColumns(aColsBrw)
			oBrowse157:SetOnlyFields({""})
			oBrowse157:SetDescription(STR0001) //Disponibilidade de Recursos
			oBrowse157:SetMenuDef('TMSA157')   
						
			TMA157Par(nFiltro, cCodVei)
			oBrowse157:Activate()
			SetKey( VK_F5, Nil )

		EndIf
	Else
		Help( ,, 'HELP',, STR0007, 1, 0 ) //Necessario ativar o parametro MV_ITMSDMD para utilizar esta rotina.
	Endif

	If FwIsInCallStack("TMSA155")
		//Limpa atalhos
		TClearFKey()
		//Recria atalhos da rotina de Recursos quando executada 
		SetKey(VK_F5,{ ||TMA155Filt("", .T.)})
		SetKey(VK_F12,{ ||TMA155Par(.T.)} )
	EndIf 

Return


/*/{Protheus.doc} MenuDef
//Botoes do menu
@author gustavo.baptista
@since 01/06/2018
@version 1.0
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TMSA157' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMSA157' OPERATION 4 ACCESS 0 // Alterar

Return aRotina

/*/{Protheus.doc} ModelDef
//Modelo de dados
@author gustavo.baptista
@since 01/06/2018
@version 1.0
@type function
/*/
Static Function ModelDef()
	Local oStruDA3 := FWFormStruct(1, 'DA3',{|cCampo| ALLTRIM(cCampo) $ cFieldsDA3 })
	Local oModel	:= MPFormModel():New('TMSA157', /*bPre*/, /*{|oModel| vldPos(oModel)}*/, , /*bCancel*/) 
	
	oStruDA3:RemoveField('DA3_FILATU')
	
	oStruDA3:AddField(STR0004						   ,;	// 	[01]  C   Titulo do campo  
					    STR0004						   ,;	// 	[02]  C   ToolTip do campo
					    'DA3_FILATU'		     			,;	// 	[03]  C   Id do Field
					    'C'								,;	// 	[04]  C   Tipo do campo
					    TAMSX3("DA3_FILATU")[1]			,;	// 	[05]  N   Tamanho do campo
					    0									,;	// 	[06]  N   Decimal do campo
					    NIL								,;	// 	[07]  B   Code-block de validação do campo
					    NIL								,;	// 	[08]  B   Code-block de validação When do campo
					    NIL								,;	//	[09]  A   Lista de valores permitido do campo
					    .F.								,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					    NIL								,;	//	[11]  B   Code-block de inicializacao do campo
					    NIL								,;	//	[12]  L   Indica se trata-se de um campo chave
					    NIL								,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					    .F.								)	// 	[14]  L   Indica se o campo é virtual
	
	
	oStruDA3:SetProperty('*', MODEL_FIELD_WHEN,{||.F.})
	oStruDA3:SetProperty('DA3_FILATU', MODEL_FIELD_WHEN,{|oModel|tm157When(oModel,"DA3_FILATU")})
	oStruDA3:SetProperty('DA3_GSTDMD', MODEL_FIELD_WHEN,{|oModel|tm157When(oModel,"DA3_GSTDMD")})
	
	oStruDA3:SetProperty('DA3_FILATU',MODEL_FIELD_VALID ,{|oModel|Vazio() .Or. vldFilAnt(oModel) })

	//Descricao
	oModel:SetDescription(STR0005) //Veiculos

	//Field master
	oModel:addFields('MASTER_DA3',nil,oStruDA3)
	 
	oModel:SetActivate(   { || TM157ACTIN() } )
	oModel:SetDeActivate( { || TM157ACTFM() } )

Return oModel

/*/{Protheus.doc} ViewDef
//View
@author gustavo.baptista
@since 01/06/2018
@version 1.0
@type function
/*/
Static Function ViewDef()
	Local oModel   := FWLoadModel('TMSA157')
	Local oStruDA3 := FWFormStruct(2, 'DA3',{|cCampo| ALLTRIM(cCampo) $ cFieldsDA3 })
	Local oView
	
	oStruDA3:RemoveField('DA3_FILATU')
	
	oStruDA3:AddField("DA3_FILATU"		     			,;	// [01]  C   Nome do Campo
					    '15'								,;	// [02]  C   Ordem
					    STR0004			     			,;	// [03]  C   Titulo do campo//"Descrição"
					    STR0004    						,;	// [04]  C   Descricao do campo//"Descrição"
					    NIL								,;	// [05]  A   Array com Help
					    "C"								,;	// [06]  C   Tipo do campo
					    "@!"								,;	// [07]  C   Picture
					    NIL								,;	// [08]  B   Bloco de Picture Var
					    Nil 								,;	// [09]  C   Consulta F3
					    .T.								,;	// [10]  L   Indica se o campo é alteravel
					    NIL								,;	// [11]  C   Pasta do campo
					    NIL								,;	// [12]  C   Agrupamento do campo
					    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
					    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
					    NIL								,;	// [15]  C   Inicializador de Browse
					    .F.								,;	// [16]  L   Indica se o campo é virtual
					    NIL								,;	// [17]  C   Picture Variavel
					    NIL							   )	// [18]  L   Indica pulo de linha após o campo
	
	
	oStruDA3:SetProperty('DA3_FILATU', MVC_VIEW_LOOKUP,'XM0')
	
	oStruDA3:SetProperty('DA3_PLACA', MVC_VIEW_ORDEM,'01')
	oStruDA3:SetProperty('DA3_COD',   MVC_VIEW_ORDEM,'02')
	oStruDA3:SetProperty('DA3_TIPVEI',MVC_VIEW_ORDEM,'03')
	oStruDA3:SetProperty('DA3_DESC',  MVC_VIEW_ORDEM,'04')
	oStruDA3:SetProperty('DA3_DESCFO', MVC_VIEW_ORDEM,'05')
	oStruDA3:SetProperty('DA3_FROVEI', MVC_VIEW_ORDEM,'06')
	oStruDA3:SetProperty('DA3_FROVEI', MVC_VIEW_ORDEM,'07')
	oStruDA3:SetProperty('DA3_DESCMO', MVC_VIEW_ORDEM,'08')
	oStruDA3:SetProperty('DA3_STATUS', MVC_VIEW_ORDEM,'09')
	oStruDA3:SetProperty('DA3_ATIVO',  MVC_VIEW_ORDEM,'10')
	oStruDA3:SetProperty('DA3_FILATU', MVC_VIEW_ORDEM,'11')
	oStruDA3:SetProperty('DA3_GSTDMD', MVC_VIEW_ORDEM,'12')
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	//Seta o model para a view
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_DA3', oStruDA3, 'MASTER_DA3' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('BOX_MAIN', 100,,/*lPixel*/)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_DA3', 'BOX_MAIN' )
	
Return oView

/*/{Protheus.doc} vldFilAnt
//Valida se a filial digitada existe na SM0
@author gustavo.baptista
@since 22/08/2018
@version 1.0
@return ${return}, ${Retorna sim ou não}
@param oModel, object, descricao
@type function
/*/
Static Function vldFilAnt(oModel)

	Local lRet := .T.
	Local aAreaSM0   := SM0->(GetArea())

	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	
	//Procura pelo Numero da Empresa e Filial.
	If !DbSeek(cEmpAnt+oModel:GetValue('DA3_FILATU'))
		lRet := .F.
	EndIf

	RestArea(aAreaSM0)

Return lRet

/*/{Protheus.doc} tm157When
//Verifica se permite alterar o campo ou nao
@author gustavo.baptista
@since 22/08/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param cField, characters, Campo que será habilitado ou não
@type function
/*/
Static Function tm157When(oModel,cField)
	Local cTempQry:= GetNextAlias()
	Local cQuery := " "
	
	Local lRet:= .T.
	
	If cField == "DA3_FILATU"
		If oModel:GetValue("DA3_FROVEI") == '1' //Permite alterar somente se o veículo for diferente de "Próprio(1)".
			lRet:= .F.
		ElseIf oModel:GetValue("DA3_STATUS") != '2' //Permite alterar somente se o status do veículo estiver "Em filial(2)"
			lRet:= .F.
		EndIf
	EndIf
	
	//Nao permitir alterar os campos se o veículo estiver em algum planejamento que está com status <> de "Encerrado(4)" e <> "Recusado(5)"  
	If lRet
		cQuery:= " SELECT Count(DL9_CODVEI) nCount "
		cQuery+= "   FROM "+RetSqlName('DL9')+" DL9 "
		cQuery+= "  WHERE DL9_FILIAL = '" + xFilial('DL9') + "'"
		cQuery+= "    AND DL9_CODVEI = '"+oModel:GetValue("DA3_COD")+"'"
		cQuery+= "    AND (DL9_STATUS <> '4' And DL9_STATUS <> '5') "
		cQuery+= "    AND D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery(cQuery)
					
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempQry, .F., .T. )
		
		iF (cTempQry)->(nCount) > 0
			lRet:= .F.
		EndIf
		(cTempQry)->(DbCloseArea())
	EndIf
	
Return lRet

/*/{Protheus.doc} TMA157Par
//parametros do browse
@author gustavo.baptista
@since 22/08/2018
@version 1.0
@type function
/*/
Function TMA157Par(nOpc, cCodVei)
		
	If nOpc == 1 
		SetKey(VK_F5,{ ||TMA157Par(2)} )
		oBrowse157:SetFilterDefault(TMA157Filt())
	ElseIf nOpc == 2
		If Pergunte('TMSA157',.T.)
			oBrowse157:SetFilterDefault(TMA157Filt()) 
			oBrowse157:Refresh(.T.)
		EndIf
	ElseIf nOpc == 3 
		If !Empty(cCodVei)
			oBrowse157:SetFilterDefault("@DA3_COD = '" + cCodVei + "'") 
			oBrowse157:Refresh(.T.)
		EndIf
	EndIf		
	
Return Nil

/*/{Protheus.doc} TMA157Filt
//Filtro da tela de alteração de veículos
@author gustavo.baptista
@since 22/08/2018
@version 1.0
@type function
/*/
Function TMA157Filt()
	Local cRet    := " "
	Local cFilais := " "
	Local cTipVei := " "

	Local aFilial := STRTOKARR(MV_PAR01, ";")
	Local aTipVei := STRTOKARR(MV_PAR03, ";")
	
	Local nX := 0
	
	If !(Empty(MV_PAR01)) .AND. AllTrim(aFilial[1]) <> STR0006 //Todos
		For nX := 1 to len(aFilial)
			cFilais += "'" + AllTrim(aFilial[nX]) + "'"
			If nX < Len(aFilial)
				cFilais += ','
			EndIf 
		Next nX
	EndIf
	
	If !(Empty(MV_PAR03)) .AND. AllTrim(aTipVei[1]) <> STR0006 //Todos
		For nX := 1 to len(aTipVei)
			cTipVei += "'" + AllTrim(aTipVei[nX]) + "'"
			If nX < Len(aTipVei)
				cTipVei += ','
			EndIf 
		Next nX
	EndIf
	
	If !Empty(cFilais)
		cRet := "@DA3_FILATU IN (" + Alltrim(cFilais) + ")"
	EndIf
	
	If !Empty(MV_PAR02)
		if Empty(cRet)
			cRet := "@DA3_PLACA  = '" +  Alltrim(MV_PAR02) + "'"
		else
			cRet += " AND DA3_PLACA  = '" +  Alltrim(MV_PAR02) + "'"
		endif		
	EndIf
	
	If !Empty(cTipVei)
		if Empty(cRet)
			cRet := "@DA3_TIPVEI IN (" +  Alltrim(cTipVei) + ")"
		else
			cRet += " AND DA3_TIPVEI IN (" +  Alltrim(cTipVei) + ")"
		endif
	EndIf

	If !Empty(MV_PAR04) .AND. !Empty(MV_PAR06) .OR. (Empty(MV_PAR04) .AND. !Empty(MV_PAR06)) .OR. (!Empty(MV_PAR04) .AND. Empty(MV_PAR06))
		if Empty(cRet)
			cRet := "@(DA3_CODFOR >= '" + MV_PAR04 + "' AND DA3_CODFOR <= '" + MV_PAR06 + "' ) "
		else
			cRet += " AND ( DA3_CODFOR >= '" + MV_PAR04 + "' AND DA3_CODFOR <= '" + MV_PAR06 + "' ) "
		endif
	EndIf

	If !Empty(MV_PAR05) .AND. !Empty(MV_PAR07) .OR. (Empty(MV_PAR05) .AND. !Empty(MV_PAR07)) .OR. (!Empty(MV_PAR05) .AND. Empty(MV_PAR07))	
		if Empty(cRet)
			cRet += "@(DA3_LOJFOR >= '" + MV_PAR05 + "' AND DA3_LOJFOR <= '" + MV_PAR07 + "')"
		else
			cRet += " AND (DA3_LOJFOR >= '" + MV_PAR05 + "' AND DA3_LOJFOR <= '" + MV_PAR07 + "')"
		endif
	EndIf
	
	If !Empty(MV_PAR08) .AND. (Alltrim(Str(MV_PAR08)) $ "1|2")
		if Empty(cRet)
			cRet := "@DA3_GSTDMD  = '" + Alltrim(Str(MV_PAR08)) + "'"
		else
			cRet += " AND DA3_GSTDMD = '" + Alltrim(Str(MV_PAR08)) + "'"
		endif
	EndIf
	
	If !Empty(MV_PAR09) .AND. (Alltrim(Str(MV_PAR09)) $ "1|2|3")
		if Empty(cRet)
			cRet := "@DA3_FROVEI = '" + Alltrim(Str(MV_PAR09)) + "'"
		else
			cRet += " AND DA3_FROVEI = '" + Alltrim(Str(MV_PAR09)) + "'"
		endif
	EndIf

Return cRet

/*/{Protheus.doc} TM157ACTIN
->Função ao inicializar o activate do modelo de dados
->Desabilita o F5 ao incluir/alterar/visualizar
@author ana.laura
@since 01/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function TM157ACTIN()

	SetKey( VK_F5, Nil )

Return .T.

/*/{Protheus.doc} TM157ACTFM
->Função executada no Deactivate do modelo de dados
->Habilita novamente o F5 no browser
@author natalia.neves
@since 01/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function TM157ACTFM()
	If .NOT. FwIsInCallStack("TMSA155")
		SetKey(VK_F5,{ ||TMA157Par(2)} )
	EndIf

Return .T.

