#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#Include 'CFGX049B.CH'

#Define cCposG1	"FOP_CODIGO|FOP_IDELIN|FOP_HEADET|FOP_CHALIN|FOP_IDESEG|FOP_DESSEG|FOP_CONARQ|FOP_SEQUEN|FOP_VERARQ"
#Define cCposG2 "FOP_CODIGO|FOP_IDELIN|FOP_HEADET|FOP_CHALIN|FOP_IDESEG|FOP_DESMOV|FOP_POSINI|FOP_POSFIM|FOP_DECIMA|FOP_CONARQ|FOP_BANCO|FOP_SEQUEN"

/*/ {Protheus.doc} CFGX049B03()
Fun��o que realiza a cria��o da tela de cadastro da tabela tela de cadastro da tabela FOP.
@author	Francisco Oliveira
@since		11/08/2017
@version	P12
@Function  CFGX049B02
@Return
@param
*/

Function CFGX049B03()

	Local oBrowse	:= NIL

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FOZ' )
	oBrowse:SetDescription(STR0060) // "Configura��o Arquivos CNAB"

	//Legenda
	oBrowse:AddLegend("FOZ_EDITAV = '1'", "RED"  , "Arquivo Editado"  ) //"Arquivo Editado"
	oBrowse:AddLegend("FOZ_EDITAV = '2'", "GREEN", "Arquivo Original" ) //"Arquivo Original"

	oBrowse:Activate()

Return Nil

/*/ {Protheus.doc} MenuDef()
Fun��o que inclu� as op��es do menu na tela de cadastro da tabela FOP
@author	Francisco Oliveira
@since		11/08/2017
@version	P12
@Function  MenuDef()
@Return	aRotina: Objeto com todas as op��es inseridas no menu.
@param
*/

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0043	ACTION 'VIEWDEF.CFGX049B03'	OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0061	ACTION 'VIEWDEF.CFGX049B03' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0062	ACTION 'VIEWDEF.CFGX049B03' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0063	ACTION 'VIEWDEF.CFGX049B03' OPERATION 5 ACCESS 0 // 'Excluir'

Return aRotina

/*/ {Protheus.doc} ModelDef()
Fun��o que realiza o tratamento de toda a camada de neg�cio para inclus�o/altera��o e exclus�o da tabela FOP.
@author	Francisco Oliveira
@since		11/08/2017
@version	P12
@Function  ModelDef()
@Return	oModel: Objeto com todos os campos do modelo de dados.
@param
*/

Static Function ModelDef()

	Local oStrCabFOZ	:= FWFormStruct( 1, 'FOZ')
	Local oStrGrdFOP 	:= FWFormStruct( 1, 'FOP', {|cCampo|Alltrim(cCampo) $ (cCposG1)} )
	Local oStrIteFOP 	:= FWFormStruct( 1, 'FOP', {|cCampo|Alltrim(cCampo) $ (cCposG2)} )

	Local aLoadGrd1	:= {{"FOP_IDELIN", "1", MVC_LOADFILTER_EQUAL }}
	Local aLoadGrd2	:= {{"FOP_IDELIN", "2", MVC_LOADFILTER_EQUAL }}

	Local bVldAlt	:= {|oGridModel, nLine, cAction, cCpoPos, cVlrCpo| fbPost(oGridModel, nLine, cAction, cCpoPos, cVlrCpo)}
	Local bVldTri	:= {|oMdlTrig, cCpoTrig, cVlrTrig| bfVldTri(oMdlTrig, cCpoTrig, cVlrTrig)}
	Local lNewIndFOP:= Len(FWSIXUtil():GetAliasIndexes("FOP")[1] )>2

	oStrGrdFOP:AddTrigger( "FOP_HEADET" , "FOP_HEADET" , , bVldTri )
	oStrGrdFOP:AddTrigger( "FOP_CHALIN" , "FOP_CHALIN" , , bVldTri )
	oStrGrdFOP:AddTrigger( "FOP_IDESEG" , "FOP_IDESEG" , , bVldTri )

	oStrCabFOZ:SetProperty("FOZ_CODIGO" , MODEL_FIELD_WHEN, {|| .F.    } )
	oStrCabFOZ:SetProperty("FOZ_MODULO" , MODEL_FIELD_WHEN, {|| Inclui } )
	oStrCabFOZ:SetProperty("FOZ_TIPO"   , MODEL_FIELD_WHEN, {|| Inclui } )
	oStrCabFOZ:SetProperty("FOZ_BANCO"  , MODEL_FIELD_WHEN, {|| Inclui } )

	oStrGrdFOP:SetProperty("*" , MODEL_FIELD_OBRIGAT, .F.  )
	oStrIteFOP:SetProperty("*" , MODEL_FIELD_OBRIGAT, .F.  )
	//oStrGrdFOP:SetProperty("FOP_CONARQ" , MODEL_FIELD_OBRIGAT, .F.  )

	oStrGrdFOP:SetProperty("FOP_IDELIN" , MODEL_FIELD_WHEN, {|| .F. } )

	oStrIteFOP:SetProperty("FOP_IDELIN" , MODEL_FIELD_WHEN, {|| .F. } )
	oStrIteFOP:SetProperty("FOP_HEADET" , MODEL_FIELD_WHEN, {|| .F. } )
	oStrIteFOP:SetProperty("FOP_CHALIN" , MODEL_FIELD_WHEN, {|| .F. } )
	oStrIteFOP:SetProperty("FOP_IDESEG" , MODEL_FIELD_WHEN, {|| .F. } )

	//oModel := MPFormModel():New( 'CFGX049B03')
	oModel := MPFormModel():New( 'CFGX049B03',/*<bPre >*/,/*<bPost >*/,{|oModel|CFGX049B3G(oModel)},/*<bCancel >*/)

	oModel:AddFields( 'FOZMASTER', /*cOwner*/, oStrCabFOZ )
	oModel:AddGrid(   'FOPGRD1'  ,'FOZMASTER', oStrGrdFOP )
	oModel:AddGrid(	  'FOPGRD2'  ,'FOPGRD1'  , oStrIteFOP,/*BLINEPRE*/, /*BLINEPOST*/, bVldAlt /*BPREVAL*/, /*BPOSVAL*/,/*bLoad*/)

	oModel:GetModel("FOPGRD1"):SetLoadFilter( aLoadGrd1, /*cLoadFilter*/ )
	oModel:GetModel("FOPGRD2"):SetLoadFilter( aLoadGrd2, /*cLoadFilter*/ )

	oModel:SetRelation( 'FOPGRD1', { { 'FOP_FILIAL', 'xFilial("FOP")'}, {'FOP_CODIGO', 'FOZ_CODIGO'} }, FOP->( IndexKey( 1 ) ) )
	If lNewIndFOP
		oModel:SetRelation( 'FOPGRD2', { { 'FOP_FILIAL', 'xFilial("FOP")'}, {'FOP_CODIGO', 'FOP_CODIGO'}, {'FOP_IDELIN', '2'}, {'FOP_HEADET', 'FOP_HEADET'}, {'FOP_CHALIN', 'FOP_CHALIN'}, {'FOP_IDESEG', 'FOP_IDESEG'}}, FOP->(IndexKey(1))  )
	Else
		oModel:SetRelation( 'FOPGRD2', { { 'FOP_FILIAL', 'xFilial("FOP")'}, {'FOP_CODIGO', 'FOP_CODIGO'}, {'FOP_IDELIN', '2'}, {'FOP_HEADET', 'FOP_HEADET'}, {'FOP_CHALIN', 'FOP_CHALIN'}, {'FOP_IDESEG', 'FOP_IDESEG'}}, FOP->( 'FOP_FILIAL+FOP_CODIGO+FOP_IDELIN+FOP_HEADET+FOP_CHALIN+FOP_IDESEG' ) )
	EndIf

	oStrGrdFOP:SetProperty('FOP_IDELIN',MODEL_FIELD_INIT, {||"1"} )

	oStrIteFOP:SetProperty('FOP_IDELIN',MODEL_FIELD_INIT, {|oModel|fbInitPad(oModel, 1)} )
	oStrIteFOP:SetProperty('FOP_HEADET',MODEL_FIELD_INIT, {|oModel|fbInitPad(oModel, 2)} )
	oStrIteFOP:SetProperty('FOP_CHALIN',MODEL_FIELD_INIT, {|oModel|fbInitPad(oModel, 3)} )
	oStrIteFOP:SetProperty('FOP_IDESEG',MODEL_FIELD_INIT, {|oModel|fbInitPad(oModel, 4)} )

	oModel:SetPrimaryKey( { "FOZ_FILIAL", "FOZ_CODIGO" } )
	oModel:GetModel("FOZMASTER"):SetDescription(STR0064) // "Cadastro Arquivos CNAB"
	oModel:GetModel("FOPGRD1"):SetDescription(STR0064) // "Cadastro Arquivos CNAB"

Return oModel

/*/ {Protheus.doc} Viewdef()
Fun��o que realiza o tratamento de toda a camada de visualiza��o da tabela FOP.
@author	Francisco Oliveira
@since		11/08/2017
@version	P12
@Function  Viewdef()
@Return	oView: Objeto com todos os campos para a cria��o da tela
@param
*/

Static Function Viewdef()

	Local oModel   		:= FWLoadModel( 'CFGX049B03' )
	Local oStrCabFOZ	:= FWFormStruct( 2, 'FOZ')
	Local oStrGrdFOP 	:= FWFormStruct( 2, 'FOP', {|cCampo|Alltrim(cCampo) $ (cCposG1)} )
	Local oStrIteFOP 	:= FWFormStruct( 2, 'FOP', {|cCampo|Alltrim(cCampo) $ (cCposG2)} )

	Local oView    	:= FWFormView():New()

	oView:SetModel( oModel )

	oStrGrdFOP:RemoveField("FOP_CODIGO")
	oStrIteFOP:RemoveField("FOP_CODIGO")
	oStrIteFOP:RemoveField("FOP_BANCO")

	oView:AddField( 'VIEW_CAB' , oStrCabFOZ, 'FOZMASTER' )
	oView:AddGrid ( 'VIEW_GRD1', oStrGrdFOP, 'FOPGRD1' )
	oView:AddGrid ( 'VIEW_GRD2', oStrIteFOP, 'FOPGRD2' )

	oView:CreateHorizontalBox( 'SUPERIOR', 10)
	oView:CreateHorizontalBox( 'MEIO'	 , 25)
	oView:CreateHorizontalBox( 'INFERIOR', 65)

	oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRD1'	, 'MEIO'     )
	oView:SetOwnerView( 'VIEW_GRD2'	, 'INFERIOR' )

Return oView



Static Function fbInitPad(oGridModel, nRefen, cAction )

	Local aAreaFOP	:= FOP->(GetArea('FOP'))
	Local aSaveLines:= FWSaveRows()
	Local oMdlGrd1	:= oGridModel:GetModel():GetModel("FOPGRD1")
	Local cRetInit	:= ""

	If nRefen == 1
		cRetInit := "2"
	ElseIf nRefen == 2
		cRetInit := oMdlGrd1:GetValue("FOP_HEADET")
	ElseIf nRefen == 3
		cRetInit := oMdlGrd1:GetValue("FOP_CHALIN")
	ElseIf nRefen == 4
		cRetInit := oMdlGrd1:GetValue("FOP_IDESEG")
	Endif

	FWRestRows( aSaveLines )
	RestArea(aAreaFOP)

Return cRetInit


Static Function fbPost(oGridModel, nLine, cAction, cCpoPos, cVlrCpo)

	Local lRet		:= .T.
	Local oMdlGrd2	:= oGridModel:GetModel():GetModel("FOPGRD2")
	Local cPosIni	:= oMdlGrd2:GetValue("FOP_POSINI")
	Local nLinPos	:= oMdlGrd2:nLine
	Local oMdlAct	:= FwModelActive()

	If cAction == "ADDLINE"

		If oMdlGrd2:GetValue("FOP_POSFIM") < oMdlGrd2:GetValue("FOP_POSINI")
			oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSFIM", "", "FOP_POSFIM", "oMdlGrd2", STR0140, STR0141) //"O valor do campo Posi��o Final n�o pode ser menor do que o campo Posi��o Inicial." ---  "Digite um valor maior que o valor do campo Posi��o Inicial."
			lRet	:= .F.
		Else
			If ! Empty(oMdlGrd2:GetValue("FOP_DESMOV")) .Or. ! Empty(oMdlGrd2:GetValue("FOP_CONARQ")) .Or.;
					! Empty(oMdlGrd2:GetValue("FOP_POSINI")) .Or. ! Empty(oMdlGrd2:GetValue("FOP_POSINI")) .Or. ! Empty(oMdlGrd2:GetValue("FOP_DECIMA"))
				If nLinPos > 0
					If nLinPos == 1
						If cPosIni > oMdlGrd2:GetValue("FOP_POSFIM")
							oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSINI", "", "FOP_POSINI", "oMdlGrd2", STR0142, STR0143) // "O valor do campo Posi��o Inicial n�o pode ser maior do que o campo Posi��o Final." -- "Digite um valor menor que o valor do campo Posi��o Final."
							oMdlGrd2:GoLine(nLinPos )
							lRet	:= .F.
						Endif
					ElseIf nLinPos > 1
						oMdlGrd2:GoLine(nLinPos - 1)
						If oMdlGrd2:GetValue("FOP_POSFIM") > cPosIni
							oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSINI", "", "FOP_POSINI", "oMdlGrd2", STR0144, STR0145) //"O valor do campo Posi��o Inicial n�o pode ser menor do que o campo Posi��o Final da linha anterior."  ----- "Digite um valor maior que o valor do campo Posi��o Final."
							oMdlGrd2:GoLine(nLinPos )
							lRet	:= .F.
						Else
							oMdlGrd2:GoLine(nLinPos)
						Endif
					Endif
				Endif
			Else
				oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSFIM", "", "FOP_POSFIM", "oMdlGrd2", STR0146, STR0147) // "Existe campo de preenchimento obrigat�rio vazio." ----- "Favor rever os campos anteriores."
				lRet	:= .F.
			Endif
		Endif
	Endif

	If cAction == "SETVALUE"
		If cCpoPos == "FOP_POSINI"
			If nLinPos > 1
				oMdlGrd2:GoLine(nLinPos - 1)
				If Val(oMdlGrd2:GetValue("FOP_POSFIM")) + 1 == Val(cVlrCpo)
					oMdlGrd2:GoLine(nLinPos )
				Else
					oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSINI", "", "FOP_POSINI", "oMdlGrd2", STR0148, STR0149) //"O valor do campo Posi��o Inicial � diferente do valor necessario para valida��o."  ----- "Favor rever o valor digitado no campo Posi��o Inicial."
					oMdlGrd2:GoLine(nLinPos )
					lRet := .F.
				Endif
			ElseIf nLinPos == 1
				If cVlrCpo != "001"
					If Aviso(STR0035, STR0150 + CRLF + STR0079, {"Sim","N�o"}, 3) == 2 // "O valor do campo Posi��o Inicial � diferente de 001."  ---- "Deseja continuar?."
						oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSINI", "", "FOP_POSINI", "oMdlGrd2", STR0150, STR0151) //"O valor do campo Posi��o Inicial � diferente de 001."   ----- "Para continuar preencha o campo Posi��o Inical com 001."
						lRet := .F.
						Return lRet
					Endif
				Endif
			Endif
		ElseIf cCpoPos == "FOP_POSFIM"
			If Val(cVlrCpo) < Val(oMdlGrd2:GetValue("FOP_POSINI"))
				oMdlAct:SetErrorMessage("oMdlGrd2", "FOP_POSFIM", "", "FOP_POSFIM", "oMdlGrd2", STR0140, STR0141) // "O valor do campo Posi��o Final n�o pode ser menor do que o campo Posi��o Inicial." --- "Digite um valor maior que o valor do campo Posi��o Inicial"
				lRet := .F.
			Endif
		Endif
	Endif

Return lRet


Static Function bfVldTri(oMdlTrig, cCpoTrig, cVlrTrig)

	Local oMdlGrd2	:= oMdlTrig:GetModel():GetModel("FOPGRD2")

	If oMdlGrd2:nLine == 1
		oMdlGrd2:LoadValue(cCpoTrig, cVlrTrig)
	Endif

Return cVlrTrig


Static Function CFGX049B3G(oModel)

	Local nGrd1, nGrd2
	Local oMdlFOZ   := oModel:GetModel("FOZMASTER")
	Local oMdlGrv1	:= oModel:GetModel("FOPGRD1")
	Local oMdlGrv2	:= oModel:GetModel("FOPGRD2")
	Local lRet		:= .T.
	Local cVersao   := oMdlGrv1:GetValue('FOP_VERARQ')
	Local aCposGrv1 := Nil
	Local aCposGrv2 := Nil
	Local nI        := 0
	Local cChaveFOP	:= ""

	//Validando dados
	If (oModel:VldData())

		aCposGrv1 := oMdlGrv1:GetStruct():GetFields()
		aCposGrv2 := oMdlGrv2:GetStruct():GetFields()
		cChaveFOP := FWxFilial('FOP') + oMdlFOZ:GetValue('FOZ_BANCO') + cVersao + oMdlFOZ:GetValue('FOZ_MODULO') + oMdlFOZ:GetValue('FOZ_TIPO')

		FOP->(DBSetOrder(03)) //FOP_FILIAL+FOP_BANCO+FOP_VERARQ+FOP_PAGREC+FOP_REMRET+FOP_SEQUEN
		For nGrd1 := 1 To oMdlGrv1:Length()
			oMdlGrv1:GoLine(nGrd1)
			//Posicionando no Registro
			If (FOP->(DBSeek( cChaveFOP + oMdlGrv1:GetValue('FOP_SEQUEN'))))
				//Alterar o registro
				If (RecLock('FOP', .F.))
					For nI := 01 To Len(aCposGrv1)
						FOP->&(aCposGrv1[nI, 03]) := oMdlGrv1:GetValue(aCposGrv1[nI, 03])
					Next nI
					FOP->(MsUnlock())
				EndIf
			EndIf
			
			For nGrd2 := 1 To oMdlGrv2:Length()
				oMdlGrv2:GoLine(nGrd2)
				//Posicionando no Registro
				If (FOP->(DBSeek( cChaveFOP + oMdlGrv2:GetValue('FOP_SEQUEN'))))
					//Alterar o registro
					If (RecLock('FOP', .F.))
						For nI := 01 To Len(aCposGrv2)
							FOP->&(aCposGrv2[nI, 03]) := oMdlGrv2:GetValue(aCposGrv2[nI, 03])
						Next nI
						FOP->(MsUnlock())
					EndIf
				EndIf
			Next nGrd2
		Next nGrd1

		FwFreeArray(aCposGrv1)
		FwFreeArray(aCposGrv2)

	EndIf
Return lRet




