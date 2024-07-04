#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PCPA125.ch'

Static lExisHWX   := AliasInDic("HWS")
Static lExisSMC   := AliasInDic("SMC")
Static lExisSMJ   := AliasInDic("SMJ")
Static lExisOxPar := Nil
Static lExisOxCro := Nil
Static lMaqHidden := .F.
Static lEmpHidden := .F.

/*/{Protheus.doc} PCPA125
//Rotina de Programa x Usuarios
@author Thiago Zoppi
@since 12/05/2018
@version 1.0
/*/
Function PCPA125()
	Local oBrowse

	If !AliasInDic("SOX") .Or. !AliasInDic("SOY") .Or. !AliasInDic("SOZ")
		Help( ,, 'PCPA125',, STR0007, 1, 0 ) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	Else
		oBrowse := BrowseDef()
		oBrowse:Activate()
	EndIf
Return 

//PARA ADAPTAR AO MVC LOCALIZADO 
Static Function BrowseDef()
	Local oBrowse := FWMBrowse():New()	

	oBrowse:SetAlias('SOX')
	oBrowse:SetDescription(STR0040) //Formulários do APP Minha Produção
	oBrowse:SetMenuDef('PCPA125')
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0023 ACTION 'VIEWDEF.PCPA125' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.PCPA125' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0025 ACTION 'VIEWDEF.PCPA125' OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0026 ACTION 'VIEWDEF.PCPA125' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina  

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Thiago Zoppi
@since 11/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local oStruSOX   := FWFormStruct(1,'SOX')
	Local oStruSOY   := FWFormStruct(1,'SOY')
	Local oStruSOZ   := FWFormStruct(1,'SOZ')
	Local oStruHWS   := Nil
	Local oStruSMC   := Nil
	Local oStruSMJ   := Nil
	Local oStrSMJPms := Nil
	Local oEvent     := PCPA125EVDEF():New()	

	oModel := MPFormModel():New('PCPA125')
	oModel:SetDescription(STR0001) //Formulario do Apontamento de Producao 

	oStruSOX:SetProperty('OX_PRGAPON', MODEL_FIELD_NOUPD  , .T.)  
	oStruSOX:SetProperty('OX_FORM'   , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_IMAGEM' , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_DESCR'  , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_PRGAPON', MODEL_FIELD_VALID  , { || VldPrgApon(oModel)} )

	dbSelectArea("SOX")
	If SOX->(FieldPos("OX_CRONOM")) >  0
		oStruSOX:SetProperty('OX_CRONOM', MODEL_FIELD_VALID, { || VldCronom(oModel)} )
	EndIf

	oStruSOY:SetProperty('OY_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
	oStruSOY:SetProperty('OY_CODBAR' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))
	oStruSOY:SetProperty('OY_EDITA'  , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))
	oStruSOY:SetProperty('OY_VALPAD' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))

	oStruSOZ:SetProperty('OZ_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
	oStruSOZ:SetProperty('OZ_DESCGRP', MODEL_FIELD_OBRIGAT, .F.)

	oModel:addFields('OXMASTER',, oStruSOX)
	oModel:getModel('OXMASTER'):SetDescription(STR0003) //Cabecalho 
	
	oModel:addGrid('DETAIL_SOY', 'OXMASTER', oStruSOY)
	oModel:addGrid('DETAIL_SOZ', 'OXMASTER', oStruSOZ)
	oModel:getModel('DETAIL_SOY'):SetDescription(STR0004) //Detalhes de Campos
	oModel:getModel('DETAIL_SOZ'):SetDescription(STR0005) //Detalhes Usuarios

	If lExisHWX
		oStruHWS := FWFormModelStruct():New()
		
		oStruHWS:AddTable("HWS", {"HWS_CDMQ"}, STR0008 ) //"Máquina"
		oStruHWS:AddIndex(1, "01", "HWS_CDMQ", STR0008, "", "", .T. ) //"Máquina"
		
		oStruHWS:AddField(""     ,"" , "MARCA"   , "L", 1 , 0, Nil, Nil     , Nil, Nil, {|| .F.}, Nil, Nil, .T.)
		oStruHWS:AddField(STR0008, "", "HWS_CDMQ", "C", 10, 0, Nil, {|| .F.}, Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Máquina"
		oStruHWS:AddField(STR0009, "", "HWS_DSMQ", "C", 40, 0, Nil, {|| .F.}, Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Descrição"

		oModel:addGrid('DETAIL_HWS', 'OXMASTER', oStruHWS,,,,, {||LoadHWS( oStruHWS, .f. )} )

		oModel:getModel('DETAIL_HWS'):SetDescription(STR0010) //"Detalhes Maquina"
		oModel:getModel('DETAIL_HWS'):SetOnlyQuery(.T.)
		oModel:getModel('DETAIL_HWS'):SetOptional(.T.)

		oModel:getModel('DETAIL_HWS'):SetNoInsertLine(.T.)
		oModel:getModel('DETAIL_HWS'):SetNoDeleteLine(.T.)
	EndIf
	
	If lExisSMC	
		oStruSMC := FWFormStruct(1, 'SMC')
		
		oStruSMC:SetProperty('MC_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
		oStruSMC:SetProperty('MC_TIPO'   , MODEL_FIELD_OBRIGAT, .F.)
		
		If oStruSMC:HasField("MC_TABELA")
			oStruSMC:SetProperty('MC_TABELA' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnTAB(a,b)"))
			oStruSMC:SetProperty('MC_VALPAD' , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "A125VldPAD(a,b,c,d)"))
		EndIf

		oModel:addGrid('DETAIL_SMC', 'OXMASTER', oStruSMC,, {|| LinePosSMC(oModel)},, {|| LinePosSMC(oModel)})
		oModel:getModel('DETAIL_SMC'):SetDescription(STR0019) //Detalhes de Campos customizaveis

		oModel:getModel('DETAIL_SMC'):SetNoInsertLine(.T.)
		oModel:getModel('DETAIL_SMC'):SetNoDeleteLine(.T.)
		oModel:GetModel("DETAIL_SMC"):SetUniqueLine({"MC_CODFORM","MC_CAMPO"})
	EndIf
	
	If lExisSMJ
		//Struct do formulário de empenhos com os campos de permissão
		oStrSMJPms := FWFormStruct(1, 'SMJ', {|x| "|"+AllTrim(x)+"|" $ "|MJ_VISUAL|MJ_INCLUI|MJ_ALTERA|MJ_EXCLUI|"})
		
		oStrSMJPms:AddTrigger("MJ_INCLUI", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
		oStrSMJPms:AddTrigger("MJ_ALTERA", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
		oStrSMJPms:AddTrigger("MJ_EXCLUI", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
		
		oModel:addFields('SMJ_PERMISSAO',"OXMASTER", oStrSMJPms)
		oModel:getModel('SMJ_PERMISSAO'):SetDescription(STR0029) //"Formulário de empenhos - Permissões"
		oModel:getModel('SMJ_PERMISSAO'):SetOnlyQuery(.T.)


		//Struct do formulário de empenhos com os campos do formulário.
		oStruSMJ := FWFormStruct(1, 'SMJ')
		oStruSMJ:SetProperty('MJ_CODFORM', MODEL_FIELD_OBRIGAT, .F.)

		oModel:addGrid('DETAIL_SMJ', 'OXMASTER', oStruSMJ)
		oModel:getModel('DETAIL_SMJ'):SetOptional(.T.)
		//Altera propriedades de validação/edição da tabela SMJ
		A125PropMJ(oModel:getModel('DETAIL_SMJ'), oStruSMJ, "ADICIONAR")

		oModel:getModel('DETAIL_SMJ'):SetDescription(STR0030)
	EndIf

	oModel:SetPrimaryKey({'OX_FILIAL','OX_FORM' })
	oModel:SetRelation('DETAIL_SOZ', { { 'OZ_FILIAL' , 'xFilial("SOZ")'	}, { 'OZ_CODFORM', 'OX_FORM' } }, SOZ->(IndexKey(1)) )
	oModel:SetRelation('DETAIL_SOY', { { 'OY_FILIAL' , 'xFilial("SOY")'	}, { 'OY_CODFORM', 'OX_FORM' } }, 'OY_FILIAL+OY_CODFORM+OY_CAMPO' )
	
	If lExisHWX
		oModel:SetRelation('DETAIL_HWS', { { 'HWS_FILIAL', 'xFilial("HWS")'	}, { 'HWS_FORM'  , 'OX_FORM' } }, HWS->(IndexKey(1)) )
	EndIf
	
	If lExisSMC
		oModel:SetRelation('DETAIL_SMC', { { 'MC_FILIAL' , 'xFilial("SMC")'	}, { 'MC_CODFORM', 'OX_FORM' } }, SMC->(IndexKey(1)) )
	EndIf

	If lExisSMJ
		oModel:SetRelation('DETAIL_SMJ'   , { { 'MJ_FILIAL' , 'xFilial("SMJ")'	}, { 'MJ_CODFORM', 'OX_FORM' } }, SMJ->(IndexKey(1)) )
		oModel:SetRelation('SMJ_PERMISSAO', { { 'MJ_FILIAL' , 'xFilial("SMJ")'	}, { 'MJ_CODFORM', 'OX_FORM' } }, SMJ->(IndexKey(1)) )
	EndIf

	//ATIVAR EVENTOS
	oModel:InstallEvent("PCPA125EVDEF", /*cOwner*/, oEvent)

	If lExisHWX
		oModel:SetActivate( {|oModel| LoadHWS(oStruHWS, .t.) } )
	Endif

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Thiago Zoppi
@since 11/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel( 'PCPA125' )
	Local oStruSOX   := FWFormStruct(2, 'SOX')
	Local oStruSOY   := FWFormStruct(2, 'SOY')
	Local oStruSOZ   := FWFormStruct(2, 'SOZ')
	Local oStruHWS   := Nil
	Local oStruSMC   := Nil
	Local oStruSMJ   := Nil
	Local oStrSMJPms := Nil
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_SOX', oStruSOX, 'OXMASTER'  )
	oView:AddGrid('VIEW_SOY' , oStruSOY, 'DETAIL_SOY')
	oView:AddGrid('VIEW_SOZ' , oStruSOZ ,'DETAIL_SOZ')
	
	//REMOVER CAMPOS
	oStruSOY:RemoveField('OY_CODFORM')
	oStruSOZ:RemoveField('OZ_CODFORM')

	//ALTERAR PROPRIEDADES DOS CAMPOS 
	oStruSOY:SetProperty('OY_CAMPO'	 , MVC_VIEW_CANCHANGE, .F.)
	oStruSOY:SetProperty('OY_DESCAMP', MVC_VIEW_CANCHANGE, .F.)
	oStruSOX:SetProperty('OX_IMAGEM' , MVC_VIEW_TITULO   , STR0002) // Titulo do campo Imagem "Icone" 
	oStruSOX:SetProperty('OX_PRGAPON', MVC_VIEW_TITULO   , STR0041) // "Tipo Formul."

	If lExisHWX
		oStruHWS := FWFormViewStruct():New()

		oStruHWS:AddField("MARCA"   ,"01", ""     , ""     , {}, "L", "@BMP", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
		oStruHWS:AddField("HWS_CDMQ","02", STR0008, ""     , {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Máquina"
		oStruHWS:AddField("HWS_DSMQ","03", STR0009, STR0011, {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Descrição" ###"Descrição da Maquina"
		
		oView:AddGrid('VIEW_HWS', oStruHWS, 'DETAIL_HWS')
	EndIf
	
	If lExisSMC
		oStruSMC := FWFormStruct(2, 'SMC')
		oStruSMC:RemoveField('MC_CODFORM')
		oStruSMC:SetProperty("MC_DESCAMP", MVC_VIEW_PICT, "")

		oView:AddGrid('VIEW_SMC', oStruSMC, 'DETAIL_SMC')
	EndIf

	If lExisSMJ
		//Struct do formulário de empenhos com os campos de permissão
		oStrSMJPms := FWFormStruct(2, 'SMJ', {|x| "|" + AllTrim(x) + "|" $ "|MJ_VISUAL|MJ_INCLUI|MJ_ALTERA|MJ_EXCLUI|"})
		oView:AddField('VIEW_SMJ_PERM', oStrSMJPms, 'SMJ_PERMISSAO')

		//Struct do formulário de empenhos com os campos do formulário.
		oStruSMJ := FWFormStruct(2, 'SMJ')
		oStruSMJ:RemoveField('MJ_VISUAL')
		oStruSMJ:RemoveField('MJ_INCLUI')
		oStruSMJ:RemoveField('MJ_ALTERA')
		oStruSMJ:RemoveField('MJ_EXCLUI')
		oStruSMJ:RemoveField('MJ_CODFORM')

		oView:AddGrid('VIEW_SMJ', oStruSMJ, 'DETAIL_SMJ')
	EndIf

	oView:CreateHorizontalBox( 'BOX2', 140, , .T.) //Define o tamanho deste box como PIXELS
	oView:CreateHorizontalBox( 'BOX1', 100)
	oView:CreateVerticalBox( 'BOX_MESTRE', 100, 'BOX2')
	
	oView:CreateFolder('FOLDER5', 'BOX1')
	oView:AddSheet('FOLDER5', 'SHEET_CAMPOS'  , STR0017) //"Campos"
	oView:AddSheet('FOLDER5', 'SHEET_USUARIOS', STR0018) //"Usuarios"
	
	oView:CreateHorizontalBox('BOX_USUARIOS', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_USUARIOS')
	oView:CreateHorizontalBox('BOX_CAMPOS'  , 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_CAMPOS')
	
	oView:SetOwnerView('VIEW_SOX', 'BOX_MESTRE')
	oView:SetOwnerView('VIEW_SOZ', 'BOX_USUARIOS')
	oView:SetOwnerView('VIEW_SOY', 'BOX_CAMPOS')
	
	If lExisHWX
		oView:AddSheet('FOLDER5', 'SHEET_MAQUINAS', STR0016) //"Maquinas"
		oView:CreateHorizontalBox('BOX_MAQUINAS', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_MAQUINAS')
		oView:SetOwnerView('VIEW_HWS', 'BOX_MAQUINAS')
	EndIf

	If lExisSMC
		oView:AddSheet('FOLDER5', 'SHEET_CMP_CUSTOM', STR0020) //"Campos Customizados"
		oView:CreateHorizontalBox('BOX_CMP_CUSTOM', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_CMP_CUSTOM')
		oView:SetOwnerView('VIEW_SMC', 'BOX_CMP_CUSTOM')
	EndIf

	If lExisSMJ
		oView:AddSheet('FOLDER5', 'SHEET_EMPENHOS', STR0031) //"Empenhos"

		oView:CreateHorizontalBox('BOX_EMPENHOS_PERM', 70, /*"owner"*/, .T., 'FOLDER5', 'SHEET_EMPENHOS')
		oView:SetOwnerView('VIEW_SMJ_PERM','BOX_EMPENHOS_PERM')
		
		oView:CreateHorizontalBox('BOX_EMPENHOS_FORM', 100, /*"owner"*/, .F., 'FOLDER5', 'SHEET_EMPENHOS')
		oView:SetOwnerView('VIEW_SMJ','BOX_EMPENHOS_FORM')
	EndIf

	oView:SetAfterViewActivate({|oView| avalShtFld(oView)})

Return oView

// ---------------------------------------------------------
/*/{Protheus.doc} LoadHWS
Carrega grid para edica das informacoes
@author Marcos Wagner Jr.
@since 12/05/2020
@version 1.0
/*/
// ---------------------------------------------------------
Static Function LoadHWS(oStrHWS, lActivate)
	Local aLoad      := {}
	Local cQuery     := ""
	Local cAliasTmp  := ""
	Local nI         := 0
	Local nField     := 0
	Local oModel     := FwModelActive()
	Local oModelGrd  := oModel:GetModel('DETAIL_HWS')

	If lActivate .Or. oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == '4'
		cAliasTmp := GetNextAlias()
		HWS->(dbSetOrder(1))

		cQuery := " SELECT CYB.CYB_CDMQ, CYB.CYB_DSMQ "
		cQuery +=   " FROM " + RetSQLName("CYB") + " CYB "
		cQuery +=  " WHERE CYB.CYB_FILIAL = '" + xFilial("CYB") + "'"
		cQuery +=    " AND CYB.D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTmp, .F., .T.)
		
		While (cAliasTmp)->(!EoF())

			nField++
			aAdd(aLoad,{ nField ,{} } )

			If oModel:GetOperation() == 3
				aAdd(aLoad[nField, 2], .F.  )
			Else				
				If HWS->(dbSeek(xFilial('HWS')+SOX->OX_FORM+(cAliasTmp)->CYB_CDMQ))
					aAdd(aLoad[nField][2], .T. )
				Else
					aAdd(aLoad[nField][2], .F. )
				EndIf
			EndIf

			AAdd(aLoad[nField][2], (cAliasTmp)->CYB_CDMQ )
			AAdd(aLoad[nField][2], (cAliasTmp)->CYB_DSMQ )

			(cAliasTmp)->(DbSkip())
		EndDO
		(cAliasTmp)->(dbCloseArea())
	EndIf

	If lActivate .AND. oModel:GetOperation() == 3

		For nI := 1 to Len(aLoad)
			oModelGrd:SetNoInsertLine(.F.)
			oModelGrd:SetNoDeleteLine(.F.)

			oModelGrd:InitLine()
			oModelGrd:GoLine(1)

			If nI > 1
				oModelGrd:AddLine()
			Endif

			oModelGrd:GoLine(oModelGrd:Length())
			oModelGrd:LoadValue("MARCA"    ,aLoad[nI][2][1])
			oModelGrd:LoadValue("HWS_CDMQ" ,SubStr(aLoad[nI][2][2],1,10))
			oModelGrd:LoadValue("HWS_DSMQ" ,aLoad[nI][2][3])

			oModelGrd:SetNoInsertLine(.T.)
			oModelGrd:SetNoDeleteLine(.T.)
			oModelGrd:GoLine(1)
		Next
	EndIf

Return aLoad

Static Function VldPrgApon(oModel)
	Local aFolder     := {}
	Local cProgApont  := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local cFolderAtu  := ""
	Local lCronometr  := .F.
	Local oView       := FwViewActive()

	aFolder    := oView:GetFolderActive("FOLDER5", 2)
	cFolderAtu := aFolder[2]

	If lExisOxPar == Nil .Or. lExisOxCro == Nil
		dbSelectArea('SOX')
		lExisOxPar := If (SOX->(FieldPos("OX_PARADA")) >  0, .T., .F.)
		lExisOxCro := If (SOX->(FieldPos("OX_CRONOM")) >  0, .T., .F.)
	EndIf

	If oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == "2" .Or. oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == "5"
		Help(NIL, NIL, "PCPA125", NIL, STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL ) //"Apontamento não Implementado "
		oModel:GetModel("OXMASTER"):setValue("OX_PRGAPON","1") 
	EndIf

	If cProgApont == "3" .Or. cProgApont == "4"
		If lExisOxCro
			lCronometr := IIF((oModel:GetModel("OXMASTER"):GetValue("OX_CRONOM")) == "1", .T., .F.)
		EndIf

		If !lCronometr .And. lExisOxCro 
			oModel:GetModel("OXMASTER"):ClearField("OX_TPPROG")
		EndIf
	Else
		If lExisOxPar  
			oModel:GetModel("OXMASTER"):ClearField("OX_PARADA")
		EndIf
		If lExisOxCro
			oModel:GetModel("OXMASTER"):ClearField("OX_CRONOM")
			oModel:GetModel("OXMASTER"):ClearField("OX_TPPROG")
		EndIf	
	EndIf

	If cProgApont == '4'		
		If lMaqHidden
			oView:SelectFolder('FOLDER5', STR0016, 2) //"Maquinas"
			oView:SelectFolder('FOLDER5', cFolderAtu,2) //Permanece folder atual
			lMaqHidden := .F.
		EndIf
	Else
		If !lMaqHidden
			oView:HideFolder( 'FOLDER5', STR0016, 2) //"Maquinas"
			If cFolderAtu == STR0016
				oView:SelectFolder('FOLDER5', STR0017,2) //"Campos"
			Else
				oView:SelectFolder('FOLDER5', cFolderAtu,2) //Permanece folder atual
			EndIf
			lMaqHidden := .T.
		EndIf
	EndIf

	If cProgApont == "6"
		If !lEmpHidden
			oView:HideFolder( 'FOLDER5', STR0031, 2) //"Empenhos"
			If cFolderAtu == STR0031
				oView:SelectFolder('FOLDER5', STR0017,2) //"Campos"
			Else
				oView:SelectFolder('FOLDER5', cFolderAtu,2) //Permanece folder atual
			EndIf
			lEmpHidden := .T.
		EndIf
	Else
		If lEmpHidden
			oView:SelectFolder('FOLDER5', STR0031, 2) //"Empenhos"
			oView:SelectFolder('FOLDER5', cFolderAtu,2) //Permanece folder atual
			lEmpHidden := .F.
		EndIf	
	EndIf

Return .T.

Static Function VldCronom(oModel)
	Local cProgApont  := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local lCronometr  := .F.

	If lExisOxCro == Nil
		dbSelectArea('SOX')
		lExisOxCro := If (SOX->(FieldPos("OX_CRONOM")) >  0, .T., .F.)
	EndIf

	If cProgApont == '3' .Or. cProgApont == '4'
		If lExisOxCro
			lCronometr := IIF((oModel:GetModel("OXMASTER"):GetValue("OX_CRONOM")) == "1", .T., .F.)	
		EndIf

		If !lCronometr .And. lExisOxCro
			oModel:GetModel("OXMASTER"):ClearField("OX_TPPROG")
		EndIf
	EndIf

Return .T.

Function PCPA125EPa()
	Local lRet       := .F.
	Local oModel     := FWModelActive()
	Local cProgApont := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")

	If cProgApont == "3" .Or. cProgApont == "4"
		lRet := .T.
	EndIf

Return lRet

Function PCPA125ETp()
	Local lRet       := .T.
	Local oModel     := FWModelActive()

	If oModel:GetModel("OXMASTER"):GetValue("OX_CRONOM") != '1'
		lRet := .F.
		oModel:GetModel("OXMASTER"):ClearField("OX_TPPROG")
	EndIf

Return lRet

/*/{Protheus.doc} LinePosSMC
Validação de obrigatoriedade do campo descrição.
@type  Static Function
@author Christopher.miranda
@since 19/10/2020
/*/
Static Function LinePosSMC(oModel)
	Local lRet 		:= .T.
	Local oMdlSMC	:= oModel:GetModel("DETAIL_SMC")

	If oMdlSMC:GetValue("MC_VISIVEL") == "1" .And. Empty(oMdlSMC:GetValue("MC_DESCAMP"))
		Help(' ',1,"Help" ,,STR0021,2,0,,,,,,{STR0022})
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} atuVisEmp
Função chamada pela trigger dos campos MJ_INCLUI, MJ_ALTERA e MJ_EXCLUI para atualizar o valor do campo MJ_VISUAL

@type  Static Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel    , Object   , Referência do modelo de dados
@param cCmpOrigem, Character, Campo de origem que executou a trigger
@param cValor    , Character, Conteúdo do campo de origem
@return cValVisu , Character, Valor para o campo MJ_VISUAL
/*/
Static Function atuVisEmp(oModel, cCmpOrigem, cValor)
	Local cValVisu := oModel:GetValue("MJ_VISUAL")
	If cValor == "1" .And. cValVisu == "2"
		cValVisu := "1" 
	EndIf
Return cValVisu

/*/{Protheus.doc} A125WhnEmp
Função de avaliação de WHEN para o campo MJ_EDITA.

@type  Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnEmp(oModel, cCampo)
	Local lRet := .T.

	If "|" + AllTrim(oModel:GetValue("MJ_CAMPO")) + "|" $ "|D4_DTVALID|D4_OPORIG|D4_POTENCI|D4_PRODUTO|"
		lRet := .F.
	EndIf

	If lRet .And. ;
	   cCampo == "MJ_VALPAD" .And.;
	   AllTrim(oModel:GetValue("MJ_CAMPO")) == "D4_OPERAC" .And.;
	   oModel:GetModel():GetModel("OXMASTER"):GetValue("OX_PRGAPON") $ "|1|5|"
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} A125VldEmp
Função de validação para o campo MJ_EDITA.

@type  Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cField, Character, Campo que está sendo validado
@param cValue, Character, Valor do campo que está sendo validado
@param nLine , Numeric  , Linha da grid que está sendo manipulada
@return lRet , Logic    , Indica se o conteúdo do campo está válido ou não
/*/
Function A125VldEmp(oModel, cField, cValue, nLine)
	Local cTipoApon := oModel:GetModel():GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local lRet      := .T.

	If AllTrim(oModel:GetValue("MJ_CAMPO")) == "D4_OPERAC" .And. cValue == "1" .And. cTipoApon $ "|1|5|"
		Help(' ', 1, "Help",, STR0032,; //"Propriedade 'Editável' inválida para o campo 'D4_OPERAC'."
		     2, 0, , , , , , {STR0033}) //"O campo 'D4_OPERAC' somente pode ser editável quando o tipo de programa de apontamento for diferente de 'Produção simples' e 'Produção por item'."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} A125PropMJ
Adiciona ou remove as propriedades de validação da estrutura de dados da tabela SMJ.

@type  Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oModel , Object   , Objeto do modelo de dados
@param oStruct, Object   , Objeto da estrutura de dados 
@param cOperac, Character, Indica se deve REMOVER ou ADICIONAR as propriedades.
@Return Nil
/*/
Function A125PropMJ(oModel, oStruct, cOperac)
	If cOperac == "ADICIONAR"
		oStruct:SetProperty('MJ_CAMPO' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".F.") )
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnEmp(a,b)"))
		oStruct:SetProperty('MJ_VALPAD', MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnEmp(a,b)"))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "A125VldEmp(a,b,c,d)")) 

		oModel:SetNoInsertLine(.T.)
		oModel:SetNoDeleteLine(.T.)

	ElseIf cOperac == "REMOVER"
		oStruct:SetProperty('MJ_CAMPO' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_VALPAD', MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ".T."))

		oModel:SetNoInsertLine(.F.)
		oModel:SetNoDeleteLine(.F.)
	EndIf
Return Nil

/*/{Protheus.doc} avalShtFld
Avalia a exibição da folder de Máquinas na abertura da VIEW

@type  Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oView , Object   , Objeto da view
@Return Nil
/*/
Static Function avalShtFld(oView)
	Local aFolder    := {}
	Local oModel     := oView:GetModel()

	If lExisHWX
		lMaqHidden := .F.

		If oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") != "4"
			aFolder := oView:GetFolderActive("FOLDER5", 2)

			//Esconde a folder de Máquinas
			oView:HideFolder( 'FOLDER5', STR0016, 2) //"Maquinas"

			//Seleciona a folder que estava selecionada anteriormente
			oView:SelectFolder('FOLDER5', aFolder[2],2) //Permanece folder atual

			lMaqHidden := .T.
		EndIf
	EndIf

	lEmpHidden := .F.

	If oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == "6"
		aFolder := oView:GetFolderActive("FOLDER5", 2)

		//Esconde a folder de Empenhos
		oView:HideFolder( 'FOLDER5', STR0031, 2) //"Empenhos"

		//Seleciona a folder que estava selecionada anteriormente
		oView:SelectFolder('FOLDER5', aFolder[2],2) //Permanece folder atual

		lEmpHidden := .T.
	EndIf

Return

/*/{Protheus.doc} A125WhnTAB
Função de avaliação de WHEN para o campo MC_TABELA.

@type  Function
@author renan.roeder
@since 03/11/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnTAB(oModel, cCampo)
	Local lRet    := .F.

	If "CustomFieldList" $ oModel:GetValue("MC_TIPO")
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} A125VldPAD
Função de validação para o campo MC_VALPAD.

@type  Function
@author renan.roeder
@since 03/11/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cField, Character, Campo que está sendo validado
@param cValue, Character, Valor do campo que está sendo validado
@param nLine , Numeric  , Linha da grid que está sendo manipulada
@return lRet , Logic    , Indica se o conteúdo do campo está válido ou não
/*/
Function A125VldPAD(oModel, cField, cValue, nLine)
	Local lRet      := .T.
	Local cTabela   := ""
	Local aDadosSX5 := {}

	If "CustomFieldList" $ oModel:GetValue("MC_TIPO", nLine)
		cTabela   := AllTrim(oModel:GetValue("MC_TABELA", nLine))
		aDadosSX5 := FWGetSX5(cTabela, RTrim(cValue))

		If !Empty(cTabela) .And. Len(aDadosSX5) == 0
			Help(' ',1,"Help" ,, STR0035 + "'" + RTrim(cValue) + "'" + STR0036 + "'" + cTabela + "'.",; //"O Valor Padrão '" + AllTrim(cValue) + "' não pertence a Tabela '" + cTabela + "'."
					2,0,,,,,,{STR0037})	//"O Valor Padrão deve pertencer a tabela selecionada."
			lRet := .F.
		EndIf
	EndIf

Return lRet
