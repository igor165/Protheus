#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'gtpa701.CH'
#INCLUDE 'FWEditPanel.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA701
Reajuste de tarifas por Orgao
@sample 	 GTPA701()
@param oModel, objeto, (modelo do GTPA000)
@param cTpCalc, character, ( 1=Coeficiente; 2=Valor Fixo; 3=Não Calcular )
@param cTpReaj, character, ( 1=GQD_RJTTAR; 2=GQD_RJTPED; 3=GQD_RJTTAX )
@return	 Nil
@author	 Yuki Shiroma
@since	 07/11/2017
@version	 P12
/*///------------------------------------------------------------------------------
Function GTPA701(oModel, cTpCalc, cTpReaj )
	
	Local lRet	:= .T.
	Local nI	:= 1
	
		oMdl000		:= oModel
		cTpCalS		:= cTpCalc
		cTpReajS	:= cTpReaj
		
		//Verifica se pode realiazar o cadastro de reajuste
		If !Empty(cTpCalS) .and. cTpCalS != "3"
			
			//Verifica fica se possui categoria para realizar o cadastro de reajuste 
			For nI	:= 1 To oMdl000:GetModel("G5FDETAIL"):Length()
				oMdl000:GetModel("G5FDETAIL"):GoLine(nI)
	
				If !oMdl000:GetModel("G5FDETAIL"):IsDeleted()
					If Empty(oMdl000:GetModel("G5FDETAIL"):GetValue("G5F_CODGYR"))
						Help( ,, 'Help',"GTPA701", STR0003, 1, 0 )//"Categoria não foi preenchida, Opção Inválida"
						Exit
					Else
						//Abre o tela de reajuste
						FWExecView( STR0001 , "VIEWDEF.GTPA701", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Reajuste de Preço"
						{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
						Exit
					EndIf
				EndIf
			Next 	
		Else
			Help( ,, 'Help',"GTPA701", STR0004, 1, 0 )//"Não é possivel realizar o cadastro de reajuste, selecione outra opção"
		EndIf
		
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()

@return		oModel 		Objeto do Model

@author		Yuki Shiroma
@since		07/11/2017
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruG5H	:= FWFormStruct(1,'G5H')//Reajuste de Preço
	Local oStruG5HA	:= FWFormStruct(1,'G5H')//Reajuste de Preço
	Local oStruG5HB	:= FWFormStruct(1,'G5H')//Reajuste de Preço
	Local oStruG5F	:= FWFormStruct(1,'G5F')//Categoria X Orgão
	Local oStruCalc	:= FWFormModelStruct():New()
	Local bCommit	:= ( { |oModel| TP701GRV(oModel) } )
	Local bLinePre	:= ( { |oMdlG5HD,nLine,cAcao,cCampo|P701PreLn(oMdlG5HD,nLine,cAcao,cCampo) } )
	Local bPosValid	:= { |oModel| TP701TdOK(oModel)}
	Local oModel	:= nil

	/* "Solução" aplicada em caráter emergencial, fonte precisa ser refatorado! */
	If !FwIsInCallStack('GTPA000') .Or. FwIsInCallStack('GTPXFUN_002')
		Private cTpCalS  := "1"
	Endif

	oModel := MPFormModel():New('GTPA701', /*bPreValidacao*/, bPosValid, bCommit, /*bCancel*/ )

		If	cTpCalS == "1"
			oStruCalc:AddTable("CAL",{},STR0001)// "Reajuste de Preço"
			GA701Struct( oStruCalc )
		ElseIf cTpCalS == "2"
			oStruG5HA:AddTrigger("G5H_KMMIN", "G5H_QUILOM"  ,{ || .T. }, { |oMdlG5H| A701TrigKmM(oMdlG5H) } )
		EndIf
		
		oModel:AddFields('G5HMASTER',/*cOwner*/,oStruG5H)
		oModel:AddGrid('G5FDETAIL','G5HMASTER',oStruG5F)
		oModel:AddFields('G5HFIELD','G5FDETAIL',oStruG5HA)
		
		If	cTpCalS == "1"
			oModel:AddFields('G5HDETAIL','G5HFIELD',oStruG5HB)
			oModel:AddFields('CALCFIELD','G5HDETAIL',oStruCalc)
		ElseIf cTpCalS == "2"
			oModel:AddGrid('G5HDETAIL','G5HFIELD',oStruG5HB, bLinePre, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
		EndIf
			//Relacionamento 
		oModel:SetRelation('G5FDETAIL',{{ 'G5F_FILIAL','xFilial( "G5H" )'},{'G5F_CODGI0','G5H_CODORG'},{'G5F_CODGQC','G5H_TPLIN '}, {'G5F_CODGYR','G5H_CODG5F'}},G5F->(IndexKey(1)))
		
		oModel:SetRelation('G5HFIELD',{ {'G5H_CODG5F','G5F_CODGYR'}},G5H->(IndexKey(1)))
		
		oModel:SetRelation('G5HDETAIL',{{ 'G5H_FILIAL','xFilial( "G5H" )'},{'G5H_CODORG','G5H_CODORG' },{'G5H_TPLIN','G5H_TPLIN' },{'G5H_CODG5F','G5H_CODG5F' }},G5H->(IndexKey(1)))
		
			//Set Optinal 
		oModel:GetModel('G5FDETAIL'):SetOptional(.T.)
		
		oModel:GetModel('G5HDETAIL'):SetOptional(.T.)
		
		oModel:SetDescription(STR0001)//"Reajuste de Preço"
		oModel:GetModel('G5HMASTER'):SetDescription(STR0002)//Reajuste
		
			//Inicialização dos dados
		oModel:SetActivate( {|oModel| PA701Init(oModel)} )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 Yuki Shiroma
@since	 07/11/2017
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:= ModelDef()
	Local oView		:= FWFormView():New()
	Local oStruGH5	:= FWFormStruct(2, 'G5H',{|cCampo| AllTrim(cCampo)+"|" $ "G5H_CODORG|G5H_DESCOR|G5H_SIGLA|G5H_TPLIN|G5H_DESTPL|G5H_TPREAJ|G5H_DTVIGE|"})
	Local oStruGH5A	:= FWFormStruct(2, 'G5H',{|cCampo| AllTrim(cCampo)+"|" $ "G5H_KMMIN|G5H_QUILOM|"})
	Local oStruGH5B	:= nil
	Local oStruG5F	:= FWFormStruct(2, 'G5F',{|cCampo| AllTrim(cCampo)+"|" $ "G5F_CODGYR|G5F_DSCGYR|G5F_VLRMIN|"})
	Local oStruCalc	:= FWFormViewStruct():New()

	oStruG5F:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

	If IsBlind()
		cTpCalS  := "1"
		cTpReajS := "1"
	Endif
	
	//Verifica se foi selecionado reaguste tipo 1=Coeficiente ou 2=Valor Fixo 
	If cTpCalS == "2"
		oStruG5F:RemoveField('G5F_VLRMIN')
		oStruGH5B	:= FWFormStruct(2, 'G5H',{|cCampo| AllTrim(cCampo)+"|" $ "G5H_KMINI|G5H_KMFIM|G5H_VALOR|"})
	ElseIf cTpCalS == "1"
		If cTpReajS <> '1'
			oStruG5F:RemoveField('G5F_VLRMIN')
		Else
			oStruG5F:SetProperty("G5F_VLRMIN",MVC_VIEW_CANCHANGE,.T.)
		Endif
		oStruGH5B	:= FWFormStruct(2, 'G5H',{|cCampo| AllTrim(cCampo)+"|" $ "G5H_FORMUL|"})
		GA701Struct( oStruCalc, .T. )
	EndIf

	oView:SetModel(oModel)

	oView:SetDescription(STR0001)

	oView:AddField('VIEW_G5H' ,oStruGH5,'G5HMASTER')
	//Verifica se foi selecionado reaguste tipo Coeficiente ou Valor Fixo 
	If cTpCalS == "2"
		oView:AddField('VIEW_G5HA' ,oStruGH5A,'G5HFIELD')
		oView:AddGrid('VIEW_G5HB' ,oStruGH5B,'G5HDETAIL')
	ElseIf cTpCalS == "1"
		oView:AddField('VIEW_G5HB' ,oStruGH5B,'G5HDETAIL')
		oView:AddField(	'VIEW_CALC', oStruCalc	, 'CALCFIELD')
	EndIf

	oView:AddGrid('VIEW_G5F' ,oStruG5F,'G5FDETAIL')

	oView:CreateHorizontalBox('SUPERIOR', 35)
	oView:CreateHorizontalBox('INFERIOR', 65)

	oView:CreateVerticalBox('INFERESQ', 50,'INFERIOR')
	oView:CreateVerticalBox('INFERDIR', 50,'INFERIOR')
	//Verifica se foi selecionado reaguste tipo Coeficiente ou Valor Fixo 
	If cTpCalS == "2"
		oView:CreateHorizontalBox('INFDIRSUP', 20, 'INFERDIR')
		oView:CreateHorizontalBox('INFDIRINF', 80, 'INFERDIR')
	ElseIf cTpCalS == "1"
		oView:SetViewProperty( "CALCFIELD", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP,1, 0  } )
		oView:SetViewProperty( "G5HDETAIL", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP,1, 0 } )
		oView:CreateVerticalBox('INFDIRBT', 30, 'INFERDIR')
		oView:CreateVerticalBox('INFDIRME', 20, 'INFERDIR')
		oView:CreateVerticalBox('INFDIRFR', 50, 'INFERDIR')
	EndIf

	oView:SetOwnerView('VIEW_G5H','SUPERIOR')

	//Verifica se foi selecionado reaguste tipo Coeficiente ou Valor Fixo 
	If cTpCalS == "2"
		oView:SetOwnerView('VIEW_G5HA','INFDIRSUP')
		oView:SetOwnerView('VIEW_G5HB','INFDIRINF')
	ElseIf cTpCalS == "1"
		oView:AddOtherObject("VIEW_BUTTON", {|oPanel| InsButton(oPanel)})
		oView:SetOwnerView('VIEW_CALC','INFDIRBT')
		oView:SetOwnerView('VIEW_BUTTON','INFDIRME')
		oView:SetOwnerView('VIEW_G5HB','INFDIRFR')
	EndIf
	oView:SetOwnerView('VIEW_G5F','INFERESQ')

	oView:EnableTitleView('VIEW_G5H',STR0001)//"Reajuste de preço"

	//Verifica se foi selecionado reaguste tipo Coeficiente ou Valor Fixo 
	If cTpCalS == "2"
		oView:EnableTitleView('VIEW_G5HA',STR0005)//"Intervalos"
	ElseIf cTpCalS == "1"
		oView:EnableTitleView('VIEW_CALC',STR0006)//"Formulas"
		oView:EnableTitleView('VIEW_G5HB',"_")//"Trechos da Linha"
		oView:EnableTitleView('VIEW_BUTTON',"_")//"Trechos da Linha"
	EndIf
	oView:EnableTitleView('VIEW_G5F',STR0007)//"Categorias"

Return oView
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PA701Init()
Carrega os horários na grid com base nas informações preenchidas no cabeçalho.
@sample	InitDados()
@author	Inovação
@since		13/02/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function PA701Init(oModel)

	Local oMdlG5F	:= oModel:GetModel("G5FDETAIL")
	Local oMdlG5H	:= oModel:GetModel("G5HMASTER")
	Local oMdlG5HA	:= oModel:GetModel("G5HDETAIL")
	Local oMdlG5HB	:= oModel:GetModel("G5HFIELD")
	Local nI		:= 1
	Local nY		:= 1
	Local nA		:= 1
	Local nB		:= 1

	/* "Solução" aplicada em caráter emergencial, fonte precisa ser refatorado! */
	If !FwIsInCallStack('GTPA000')
		Private oMdl000  := FwLoadModel("GTPA000")
		Private cTpReajS := "1"
		Private cTpCalS  := "1"

		oMdl000:SetOperation(MODEL_OPERATION_INSERT)
		oMdl000:Activate()
	Endif

		//Realizando carga do cabeçalho
		oMdlG5H:SetValue("G5H_CODORG", oMdl000:GetModel("GI0MASTER"):GetValue("GI0_COD"))
		oMdlG5H:SetValue("G5H_DESCOR", oMdl000:GetModel("GI0MASTER"):GetValue("GI0_DESCRI"))
		oMdlG5H:SetValue("G5H_SIGLA", oMdl000:GetModel("GI0MASTER"):GetValue("GI0_SIGLA"))
		oMdlG5H:SetValue("G5H_TPLIN", oMdl000:GetModel("GQDDETAIL"):GetValue("GQD_CODGQC"))
		oMdlG5H:SetValue("G5H_DESTPL", Posicione('GQC',1,xFilial('GQC') + oMdl000:GetModel("GQDDETAIL"):GetValue("GQD_CODGQC"),'GQC_DESCRI'))
		oMdlG5H:SetValue("G5H_TPREAJ", cTpReajS)
		oMdlG5H:SetValue("G5H_TPCALR", cTpCalS)
		oMdlG5H:SetValue("G5H_DTVIGE", oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_DTVIGE"))
	
		//Realizando a carga da grid de categoria
		For nI	:= 1 to oMdl000:GetModel("G5FDETAIL"):Length()
			oMdl000:GetModel("G5FDETAIL"):GoLine(nI)
			If !Empty(oMdlG5F:GetValue("G5F_CODGYR"))
				oMdlG5F:AddLine()
			EndIf
	
			oMdlG5F:SetValue("G5F_CODGYR", oMdl000:GetModel("G5FDETAIL"):GetValue("G5F_CODGYR"))
			oMdlG5F:SetValue("G5F_DSCGYR", oMdl000:GetModel("G5FDETAIL"):GetValue("G5F_DSCGYR"))
			If cTpCalS == "1"
				oMdlG5F:SetValue("G5F_VLRMIN", oMdl000:GetModel("G5FDETAIL"):GetValue("G5F_VLRMIN"))
			EndIf
		Next
	
		//Realiza a carga do grid do valor fixo caso houver alguma carga
		If !Empty(oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODIGO"))
			For nY	:= 1 to oMdlG5F:Length()
				oMdlG5F:GoLine(nY)
				If !oMdlG5F:IsDeleted()
					For nB	:= 1 To oMdl000:GetModel("G5HDETAIL"):Length()
						oMdl000:GetModel("G5HDETAIL"):GoLine(nB)
						If oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_TPREAJ") == cTpReajS .And. ;
								oMdlG5F:GetValue("G5F_CODGYR") == oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODG5F") .And. !oMdl000:GetModel("G5HDETAIL"):IsDeleted()
							//Carregado cabeçalho da grid
							oMdlG5HB:LoadValue("G5H_KMMIN",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_KMMIN"))
							oMdlG5HB:LoadValue("G5H_QUILOM",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_QUILOM"))
							oMdlG5HB:SetValue("G5H_CODORG",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODORG"))
							oMdlG5HB:SetValue("G5H_TPLIN",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_TPLIN"))
							oMdlG5HB:SetValue("G5H_CODG5F",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODG5F"))
						EndIf
					Next
					If cTpCalS == "2" //Verifica tipo de calculo
						For nA	:= 1 to oMdl000:GetModel("G5HDETAIL"):Length()
							oMdl000:GetModel("G5HDETAIL"):GoLine(nA)
	
							If oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODG5F") == oMdlG5F:GetValue("G5F_CODGYR",nY) .AND. oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_TPREAJ") == cTpReajS;
									.AND. !oMdl000:GetModel("G5HDETAIL"):IsDeleted()
	
								If !Empty(oMdlG5HA:GetValue("G5H_CODIGO"))
									oMdlG5HA:AddLine()
								EndIf
	
								oMdlG5HA:SetValue("G5H_CODIGO",GETSXENUM("G5H","G5H_CODIGO"))
								oMdlG5HA:SetValue("G5H_CODORG",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODORG"))
								oMdlG5HA:SetValue("G5H_TPLIN",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_TPLIN"))
								oMdlG5HA:LoadValue("G5H_KMINI",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_KMINI"))
								oMdlG5HA:LoadValue("G5H_KMFIM",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_KMFIM"))
								oMdlG5HA:LoadValue("G5H_VALOR",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_VALOR"))
								oMdlG5HA:SetValue("G5H_CODG5F",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODG5F"))
	
							EndIf
						Next
					ElseIf cTpCalS == "1" //Verifica tipo de calculo
						For nA	:= 1 to oMdl000:GetModel("G5HDETAIL"):Length()
							oMdl000:GetModel("G5HDETAIL"):GoLine(nA)
							oMdl000:GetModel("G5FDETAIL"):GoLine(nA)
							If !oMdl000:GetModel("G5HDETAIL"):IsDeleted() .And. oMdl000:GetModel("G5HDETAIL"):SeekLine({ ;
									{'G5H_CODG5F', oMdlG5F:GetValue("G5F_CODGYR",nY)},{"G5H_TPREAJ",cTpReajS} })
	
								oMdlG5HA:SetValue("G5H_CODIGO",GETSXENUM("G5H","G5H_CODIGO"))
								oMdlG5HA:SetValue("G5H_CODORG",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODORG"))
								oMdlG5HA:SetValue("G5H_TPLIN",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_TPLIN"))
								oMdlG5HA:LoadValue("G5H_FORMUL",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_FORMUL"))
								oMdlG5HA:SetValue("G5H_CODG5F",oMdl000:GetModel("G5HDETAIL"):GetValue("G5H_CODG5F"))
								Exit
							EndIf
						Next
					EndIf
				EndIf
			Next
		EndIf
	
		oMdlG5F:SetNoInsertLine()
		oMdlG5F:SetNoDeleteLine()
		oMdlG5F:GoLine(1)
		
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP701GRV()
Realiza carga de dados para submodelo da tela de orgão concedente 

@sample	TP701GRV()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function TP701GRV(oModel)

	Local lRet		:= .T.
	Local oMdlG5H	:= oModel:GetModel("G5HDETAIL")
	Local oMdlG5HF	:= oModel:GetModel("G5HFIELD")
	Local oMdlG5FM	:= oModel:GetModel("G5HMASTER")
	Local oMdlG5F	:= oModel:GetModel("G5FDETAIL")
	Local oM000G5H	:= nil
	Local oM000G5F	:= nil
	Local nI
	Local nY
	Local lDel		:= .F.

	/* "Solução" aplicada em caráter emergencial, fonte precisa ser refatorado! */
	If !FwIsInCallStack('GTPA000')
	
		Private oMdl000  := FwLoadModel("GTPA000")
		Private cTpReajS := "1"
		Private cTpCalS  := "1"
		oM000G5H	:= oMdl000:GetModel("G5HDETAIL")
		oM000G5F	:= oMdl000:GetModel("G5FDETAIL")

		oMdl000:SetOperation(MODEL_OPERATION_INSERT)
		oMdl000:Activate()

	else

		oM000G5H	:= oMdl000:GetModel("G5HDETAIL")
		oM000G5F	:= oMdl000:GetModel("G5FDETAIL")		

	Endif



		//Realiza a deleção dos dados antigos
		If !Empty(oM000G5H:GetValue("G5H_CODIGO"))
			While oM000G5H:SeekLine({{'G5H_TPREAJ',cTpReajS}})
				oM000G5H:DeleteLine()
			End
			nY	:= 1
			lDel := .T.
		EndIf
		//Realiza carga no submodelo da tela anterior 
		If cTpCalS == "2"
			For nY	:= 1 to oMdlG5F:Length()
				oMdlG5F:GoLine(nY)
				For nI	:= 1 to oMdlG5H:Length()
					If !oMdlG5H:IsDeleted(nI)
						If !Empty(oM000G5H:GetValue("G5H_CODIGO"))
							oM000G5H:addLine()
						EndIf
						oM000G5H:SetValue("G5H_CODIGO", GETSXENUM("G5H","G5H_CODIGO"))
						oM000G5H:SetValue("G5H_SIGLA", oMdlG5FM:GetValue("G5H_SIGLA"))
						oM000G5H:SetValue("G5H_TPREAJ", oMdlG5FM:GetValue("G5H_TPREAJ"))
						oM000G5H:SetValue("G5H_TPCALR", oMdlG5FM:GetValue("G5H_TPCALR"))
						oM000G5H:LoadValue("G5H_KMMIN", oMdlG5HF:GetValue("G5H_KMMIN"))
						oM000G5H:LoadValue("G5H_QUILOM", oMdlG5HF:GetValue("G5H_QUILOM"))
						oM000G5H:SetValue("G5H_KMINI", oMdlG5H:GetValue("G5H_KMINI", nI))
						oM000G5H:SetValue("G5H_KMFIM", oMdlG5H:GetValue("G5H_KMFIM", nI))
						oM000G5H:SetValue("G5H_VALOR", oMdlG5H:GetValue("G5H_VALOR", nI))
						oM000G5H:SetValue("G5H_CODG5F", oMdlG5F:GetValue("G5F_CODGYR", nY))
						oM000G5H:SetValue("G5H_DTVIGE", oMdlG5FM:GetValue("G5H_DTVIGE"))
					EndIf
				Next
			Next
		ElseIf cTpCalS == "1"
			For nY	:= 1 to oMdlG5F:Length()
				oMdlG5F:GoLine(nY)
				oM000G5F:GoLine(nY)
				oM000G5F:LoadValue("G5F_VLRMIN", oMdlG5F:GetValue("G5F_VLRMIN"))
				If !Empty(oM000G5H:GetValue("G5H_CODIGO"))
					oM000G5H:addLine()
				EndIf
				oM000G5H:SetValue("G5H_CODIGO", GETSXENUM("G5H","G5H_CODIGO"))
				oM000G5H:SetValue("G5H_SIGLA", oMdlG5FM:GetValue("G5H_SIGLA"))
				oM000G5H:SetValue("G5H_TPREAJ", oMdlG5FM:GetValue("G5H_TPREAJ"))
				oM000G5H:SetValue("G5H_TPCALR", oMdlG5FM:GetValue("G5H_TPCALR"))
				oM000G5H:LoadValue("G5H_FORMUL", oMdlG5H:GetValue("G5H_FORMUL"))
				oM000G5H:SetValue("G5H_CODG5F", oMdlG5F:GetValue("G5F_CODGYR", nY))
				oM000G5H:SetValue("G5H_DTVIGE", oMdlG5FM:GetValue("G5H_DTVIGE"))
			Next
		EndIf
		
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P701PreLn()
Pre validação no grid 
@sample	P701PreLn()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function P701PreLn(oMdlG5HD,nLine,cAcao,cCampo)
	
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oMdlG5HF	:= oModel:GetModel("G5HFIELD")
	
			//Verifica se a primeira linha o km inicio está com valor 0
		If nLine == 1 .And. cAcao == "SETVALUE" .And. cCampo == "G5H_KMINI"
			If FwFldGet("G5H_KMINI", nLine)  != 0
				Help( ,, 'Help',"P701PreLn", STR0008, 1, 0 )//"O valor do KM inicio da primeira linha deve ser igual a 0"
				lRet	:= .F.
			EndIf
		EndIf
		
			//Verifica se caso opção valor minimo estiver "sim" verifica se está sendo respeitado o valor de km minimo
			//Verifica se km fim e maior que km inicio
		If	cAcao == "SETVALUE" .And. cCampo == "G5H_KMFIM"
			If FwFldGet("G5H_KMFIM",nLine) >= oMdlG5HD:GetValue("G5H_KMINI",nLine)
				If oMdlG5HF:GetValue("G5H_KMMIN") == "1" .And. cAcao == "SETVALUE"
					If !((FwFldGet("G5H_KMFIM",nLine) - oMdlG5HD:GetValue("G5H_KMINI")) >= oMdlG5HF:GetValue("G5H_QUILOM"))
						Help( ,, 'Help',"TP701LinOk", STR0009 + STR(oMdlG5HF:GetValue("G5H_QUILOM")) + STR0010, 1, 0 )//"Valor minímo deve ser maior " # " Km"
						lRet	:= .F.
					EndIf
				EndIf
			Else
				Help( ,, 'Help',"P701PreLn", STR0011, 1, 0 )//"O valor do Km Final deve ser maior que o valor do Km Início"
				lRet	:= .F.
			EndIf
		EndIf
			//Verifica se o valor inicial e maior que valor final da ultima linha
		If	cAcao == "SETVALUE" .And. cCampo == "G5H_KMINI"
			If nLine != 1
				If !(FwFldGet("G5H_KMINI",nLine) > oMdlG5HD:GetValue("G5H_KMFIM",nLine-1))
					Help( ,, 'Help',"TP701LinOk", STR0031, 1, 0 )//"Valor inicial deve ser maior que valor final da linha anterior"
					lRet	:= .F.
				EndIf
			EndIf
		EndIf
			//Permite deleção da ultima linha
		If	cAcao == "DELETE"
			If oMdlG5HD:Length(.T.) != nLine .And. !oMdlG5HD:IsDeleted()
				Help( ,, 'Help',"TP701LinOk", STR0032, 1, 0 )//"Só é póssivel apagar ultima linha do grid"
				lRet	:= .F.
			EndIf
		EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P701PreLn()
Pre validação no grid 
@sample	InitDados()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function GA701Struct(oStruct, lView)

	Local aArea   := GetArea()
	
	DEFAULT lView := .F.

	//-------------------------------+
	// lView = .T. - Estrutura Model |
	//-------------------------------+
	If !lView
		
		oStruct:AddField( ;       // Ord. Tipo Desc.
						"Campo"    ,; // [01] C Titulo do campo##"Venda/Reemb?"
						"Campo"    ,; // [02] C ToolTip do campo
						"CAL_CAMPO"   ,; // [03] C identificador (ID) do Field
						"C"     ,; // [04] C Tipo do campo
						1      ,; // [05] N Tamanho do campo
						0      ,; // [06] N Decimal do campo
						{|| .T.}   ,; // [07] B Code-block de validação do campo
						NIL     ,; // [08] B Code-block de validação When do campo
						Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						.F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
						Nil , ; // [11] B Code-block de inicializacao do campo
						NIL     ,; // [12] L Indica se trata de um campo chave
						NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )        // [14] L Indica se o campo é virtual

		oStruct:AddField( ;       // Ord. Tipo Desc.
						"Valor"    ,; // [01] C Titulo do campo##"Venda/Reemb?"
						"Valor"    ,; // [02] C ToolTip do campo
						"CAL_VALOR"   ,; // [03] C identificador (ID) do Field
						"N"     ,; // [04] C Tipo do campo
						10      ,; // [05] N Tamanho do campo
						6      ,; // [06] N Decimal do campo
						{|| .T.}   ,; // [07] B Code-block de validação do campo
						NIL     ,; // [08] B Code-block de validação When do campo
						Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						.F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
						Nil , ; // [11] B Code-block de inicializacao do campo
						NIL     ,; // [12] L Indica se trata de um campo chave
						NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )        // [14] L Indica se o campo é virtual

		oStruct:AddField( ;       // Ord. Tipo Desc.
					"Operador"    ,; // [01] C Titulo do campo##"Venda/Reemb?"
					"Operador"    ,; // [02] C ToolTip do campo
					"CAL_OPERA"   ,; // [03] C identificador (ID) do Field
					"C"     ,; // [04] C Tipo do campo
					1      ,; // [05] N Tamanho do campo
					0      ,; // [06] N Decimal do campo
					{|| .T.}   ,; // [07] B Code-block de validação do campo
					NIL     ,; // [08] B Code-block de validação When do campo
					Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
					.F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
					Nil , ; // [11] B Code-block de inicializacao do campo
					NIL     ,; // [12] L Indica se trata de um campo chave
					NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )        // [14] L Indica se o campo é virtual      
			
					oStruct:AddField( ;       // Ord. Tipo Desc.
					"Parentese"    ,; // [01] C Titulo do campo##"Venda/Reemb?"
					"Parentese"    ,; // [02] C ToolTip do campo
					"CAL_PAREN"   ,; // [03] C identificador (ID) do Field
					"C"     ,; // [04] C Tipo do campo
					1      ,; // [05] N Tamanho do campo
					0      ,; // [06] N Decimal do campo
					{|| .T.}   ,; // [07] B Code-block de validação do campo
					NIL     ,; // [08] B Code-block de validação When do campo
					Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
					.F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
					Nil , ; // [11] B Code-block de inicializacao do campo
					NIL     ,; // [12] L Indica se trata de um campo chave
					NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )        // [14] L Indica se o campo é virtual
					
	Else
		//------------------------------+
		// lView = .F. - Estrutura View |
		//------------------------------+	
		oStruct:AddField( ; // Ord. Tipo Desc.
						"CAL_CAMPO"   ,; // [01] C Nome do Campo
						"01"    ,; // [02] C Ordem
						"Campo"    ,; // [03] C Titulo do campo -->"Venda/Reemb?"
						""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
						{}      ,; // [05] A Array com Help
						"COMBO"      ,; // [06] C Tipo do campo
						"@!"     ,; // [07] C Picture
						NIL     ,; // [08] B Bloco de Picture Var
						""      ,; // [09] C Consulta F3
						.T.     ,; // [10] L Indica se o campo é editável
						NIL     ,; // [11] C Pasta do campo
						NIL     ,; // [12] C Agrupamento do campo
						{ "", "1=Km Asfalto", "2=Km Terra", "3=Tarifa",;
						"4=Km Total", "5=Km Pedagio", "6=Taxa","7=Pedagio" } , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
						NIL     ,; // [15] C Inicializador de Browse
						.T.     ,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve
				
						oStruct:AddField( ; // Ord. Tipo Desc.
						"CAL_VALOR"   ,; // [01] C Nome do Campo
						"02"    ,; // [02] C Ordem
						"Valor"    ,; // [03] C Titulo do campo -->"Venda/Reemb?"
						""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
						{}      ,; // [05] A Array com Help
						"VALOR"      ,; // [06] C Tipo do campo
						"@E 999.999999"     ,; // [07] C Picture
						NIL     ,; // [08] B Bloco de Picture Var
						""      ,; // [09] C Consulta F3
						.T.     ,; // [10] L Indica se o campo é editável
						NIL     ,; // [11] C Pasta do campo
						NIL     ,; // [12] C Agrupamento do campo
						{} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
						NIL     ,; // [15] C Inicializador de Browse
						.T.     ,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve

		oStruct:AddField( ; // Ord. Tipo Desc.
						"CAL_OPERA"   ,; // [01] C Nome do Campo
						"03"    ,; // [02] C Ordem
						"Operador"    ,; // [03] C Titulo do campo -->"Venda/Reemb?"
						""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
						{}      ,; // [05] A Array com Help
						"COMBO"      ,; // [06] C Tipo do campo
						"@!"     ,; // [07] C Picture
						NIL     ,; // [08] B Bloco de Picture Var
						""      ,; // [09] C Consulta F3
						.T.     ,; // [10] L Indica se o campo é editável
						NIL     ,; // [11] C Pasta do campo
						NIL     ,; // [12] C Agrupamento do campo
						{ "", "1=Adição(+)", "2=Subtração(-)", "3=Multiplicação(*)",;
						"4=Divisão(/)", "5=Exponencial(^)" } , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
						NIL     ,; // [15] C Inicializador de Browse
						.T.     ,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve
				
						oStruct:AddField( ; // Ord. Tipo Desc.
						"CAL_PAREN"   ,; // [01] C Nome do Campo
						"04"    ,; // [02] C Ordem
						"Parentese"    ,; // [03] C Titulo do campo -->"Venda/Reemb?"
						""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
						{}      ,; // [05] A Array com Help
						"COMBO"      ,; // [06] C Tipo do campo
						"@!"     ,; // [07] C Picture
						NIL     ,; // [08] B Bloco de Picture Var
						""      ,; // [09] C Consulta F3
						.T.     ,; // [10] L Indica se o campo é editável
						NIL     ,; // [11] C Pasta do campo
						NIL     ,; // [12] C Agrupamento do campo
						{ "", "1=Abrir '('", "2=Fecha ')'" } , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
						NIL     ,; // [15] C Inicializador de Browse
						.T.     ,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve


	EndIf

	RestArea(aArea)


	Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P701PreLn()
Pre validação no grid 
@sample	InitDados()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function InsButton( oPanel )

	//-- Insere botao no objeto oPanel
	@ 22, 010 Button STR0012 	Size 40, 15 Message STR0012		Pixel; // "Inserir"
	Action  (InsFormula("1")) of oPanel

	//-- Insere botao no objeto oPanel
	@ 54, 010 Button STR0012 	Size 40, 15 Message STR0012		Pixel; // "Inserir"
	Action  (InsFormula("2")) of oPanel

	//-- Insere botao no objeto oPanel
	@ 87, 010 Button STR0012 	Size 40, 15 Message STR0012		Pixel; // "Inserir"
	Action  (InsFormula("3")) of oPanel

	//-- Insere botao no objeto oPanel
	@ 118, 010 Button STR0012 	Size 40, 15 Message STR0012		Pixel; // "Inserir"
	Action  (InsFormula("4")) of oPanel

	//-- Insere botao no objeto oPanel
	@ 149, 010 Button STR0013 	Size 40, 15 Message STR0013		Pixel; // "Limpar Tudo"
	Action  (InsFormula("5")) of oPanel

Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P701PreLn()
Pre validação no grid 
@sample	InitDados()
@author	Inovação
@since		07/11/2017
@version	P12
@param cOp, caracter, 1=Inserir campo,2=Inserir Valor, 3=Inserir Operador, 4=Inserir Parentese, 5=Limpar tudo
/*///-----------------------------------------------------------------------------------------
Static Function InsFormula( cOp )

	Local oModel	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oMdlG5H	:= oModel:GetModel("G5HDETAIL")
	Local oMdlCal	:= oModel:GetModel("CALCFIELD")
	Local cValor	:= ""	
	
		//Prenchimento do campo memo de acordo com opção selecionada
		If cOp == "1"//1=Inserir campo
	
			If oMdlCal:GetValue("CAL_CAMPO") == "1"
			
				cValor	:= "GI4_KMASFA"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "2"
			
				cValor	:= "GI4_KMTERR"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "3"
			
				cValor	:= "GI4_TAR"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "4"
			
				cValor	:= "GI4_KM"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "5"
			
				cValor	:= "GI4_KMPED"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "6"
			
				cValor	:= "GI4_TAX"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			ElseIf oMdlCal:GetValue("CAL_CAMPO") == "7"
			
				cValor	:= "GI4_PED"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + "[" + "|" + cValor + "|" + "]")
			
			Else
			
				Help( ,, 'Help',"InsFormula", STR0032, 1, 0 )//"Selecione uma opção"
			
			EndIf
	
			oMdlCal:ClearField('CAL_CAMPO')
	
		ElseIf cOp == "2"//2=Inserir Valor
			
			If oMdlCal:GetValue("CAL_VALOR") <> 0
			
				cValor	:= AllTrim(Str(oMdlCal:GetValue("CAL_VALOR")))
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
			
			Else
			
				Help( ,, 'Help',"InsFormula", STR0033, 1, 0 )//"Digite um valor maior que Zero"
			
			EndIf
			
			oMdlCal:ClearField('CAL_VALOR')
		ElseIf cOp == "3"//3=Inserir Operador
		
			If oMdlCal:GetValue("CAL_OPERA") == "1"
		
				cValor	:= "+"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
		
			ElseIf oMdlCal:GetValue("CAL_OPERA") == "2"
		
				cValor	:= "-"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
		
			ElseIf oMdlCal:GetValue("CAL_OPERA") == "3"
		
				cValor	:= "*"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
		
			ElseIf oMdlCal:GetValue("CAL_OPERA") == "4"
		
				cValor	:= "/"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
		
			ElseIf oMdlCal:GetValue("CAL_OPERA") == "5"
		
				cValor	:= "^"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
		
			Else
		
				Help( ,, 'Help',"InsFormula", STR0032, 1, 0 )//"Selecione uma opção"
		
			EndIf
	
			oMdlCal:ClearField('CAL_OPERA')
	
		ElseIf cOp == "4"//4=Inserir Parentese
		
			If oMdlCal:GetValue("CAL_PAREN") == "1"
				cValor	:= "("
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
			ElseIf oMdlCal:GetValue("CAL_PAREN") == "2"
				cValor	:= ")"
				oMdlG5H:LoadValue("G5H_FORMUL",oMdlG5H:GetValue("G5H_FORMUL") + cValor)
			Else
				Help( ,, 'Help',"InsFormula", STR0032, 1, 0 )//"Selecione uma opção"
			EndIf
	
			oMdlCal:ClearField('CAL_PAREN')
			
		ElseIf cOp == "5"//Limpar tudo
	
			If !Empty(oMdlG5H:GetValue("G5H_FORMUL"))
			
				If MsgYesNo( STR0041 )//"Deseja apagar formula do coeficiete?"
			
					oMdlG5H:LoadValue("G5H_FORMUL", "")
			
				EndIf
			
			EndIf
	
		EndIf
	
		oView:Refresh()	
			
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A701TrigKmM()
Realiza limpeza do campo ao alterar para km min para opção 2
@sample	InitDados()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Function A701TrigKmM(oMdlG5H)
	
	Local nQuilo
	
	If oMdlG5H:GetValue("G5H_KMMIN") == "2"
		nQuilo	:= 0
	ElseIf oMdlG5H:GetValue("G5H_KMMIN") == "1"
		nQuilo	:= oMdlG5H:GetValue("G5H_QUILOM")
	EndIf

Return nQuilo
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP701TdOK()
Pre valid
@sample	TP701TdOK()
@author	Inovação
@since		07/11/2017
@version	P12
/*///-----------------------------------------------------------------------------------------
Static Function TP701TdOK(oModel)

	Local lRet		:=	.T.
	Local oMdlG5H	:= oModel:GetModel("G5HDETAIL")
	Local nG5H		:= 1

		//Verificar se os valores da grid está Ok
	If oMdlG5H:ClassName() == "FWFORMGRID"
		For nG5H	:= 1 To oMdlG5H:Length()
			oMdlG5H:GoLine(nG5H)
			If  !oMdlG5H:GetValue("G5H_KMINI", nG5H ) < oMdlG5H:GetValue("G5H_KMFIM", nG5H )
				Help( ,, 'Help',"TP701TdOK", STR0033 + STR(nG5H) + STR0034, 1, 0 ) //"Linha " " Km Inicial deve ser maior que Km Final"
				lRet	:= .F.
			EndIf
		Next
	Endif

Return lRet
