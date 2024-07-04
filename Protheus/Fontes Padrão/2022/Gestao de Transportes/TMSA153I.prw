#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153I.ch'

Static cUmDmd	:= ''
Static cCdDemd  := ''
Static cSqDemd  := ''


/*/{Protheus.doc} TMSA153I
Fracionamento de demanda
@type function 
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Function TMSA153I(cCodDmd, cSeqDmd)
	Local cTempDL8 	:= GetNextAlias()
	Local cTempDLA 	:= GetNextAlias()
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0015},{.T., STR0016},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"#"Cancelar" 
	Local oModel 	:= Nil
	Local nX 		:= 1
	Local lBlind	:= IsBlind()
	
	Private aRegOri := {}
	Private nQtdLin := 1
		
	Default cCodDmd := ''
	Default cSeqDmd := ''

	cCdDemd	:= cCodDmd
	cSqDemd := cSeqDmd

	If 	!Empty(cCodDmd) .And. !Empty(cSeqDmd)

		TM153IQry(@cTempDL8, @cTempDLA,"")
		cUmDmd := (cTempDL8)->DL8_UM
		
		oModel := FWLoadModel('TMSA153I')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetVldActivate({ |oModel, nLine, cAction| T153IVlAct(oModel,nLine, cAction) })
			
		//Atribui valor
		oModel:LoadValue("MASTER_DL8","DL8_COD",(cTempDL8)->DL8_COD)
		oModel:LoadValue("MASTER_DL8","DL8_SEQ",(cTempDL8)->DL8_SEQ)
		oModel:LoadValue("MASTER_DL8","DL8_QTD",(cTempDL8)->DL8_QTD)
		oModel:LoadValue("MASTER_DL8","DL8_FRAC",0)
		
		If (cTempDL8)->DL8_UM = '1'	
			oModel:GetModel('GRID_ORI'):SetNoInsertLine(.F.)
		EndIF
		//Atribui valor as regioes de origem
		While (cTempDLA)->(!EOF())
			If (cTempDL8)->DL8_UM = '1'
				Iif(nX != 1, oModel:GetModel("GRID_ORI"):AddLine(),)
				Aadd(aRegOri,{(cTempDLA)->DLA_SEQREG,(cTempDLA)->DLA_CODREG})
				oModel:SetValue("GRID_ORI","DLA_SEQREG",(cTempDLA)->DLA_SEQREG)
				oModel:SetValue("GRID_ORI","DLA_CODREG",(cTempDLA)->DLA_CODREG)
				oModel:SetValue("GRID_ORI","DLA_QTD", 0)
				oModel:LoadValue("GRID_ORI","DLA_NOMREG",Posicione("DUY",1,xFilial("DUY")+(cTempDLA)->DLA_CODREG,"DUY_DESCRI"))
				nX++
			EndIf
			(cTempDLA)->(dbSkip())
		EndDo
		If (cTempDL8)->DL8_UM = '1'
			oModel:GetModel('GRID_ORI'):SetNoInsertLine(.T.)
		EndIf
		(cTempDLA)->(dbCloseArea())	
	
		If !lBlind	
			FWExecView(STR0001+ (cTempDL8)->DL8_COD + STR0002 + (cTempDL8)->DL8_SEQ,'TMSA153I',MODEL_OPERATION_INSERT,/*oDlg*/, { || .T. },{ || .T.  },65,aButtons,{ || .T. },/*cOperatId*/,/*cToolBar*/,oModel)	//'Fracionamento demanda: '#' Seq.: '
		EndIf
		(cTempDL8)->(dbCloseArea())
	Endif	
//--Retorno para automação deverá enviar o modelo de dados.
Return ( If( lBlind, oModel, "" ) )

/*/{Protheus.doc} Menudef
Menu da rorina
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0 
/*/
Static Function Menudef()
	Local aRotina := {}

	aAdd(aRotina, {STR0003, 'VIEWDEF.TMSA153I', 0, 3, 0, NIL}) //Incluir
Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruDL8 		:= MdoStruDL8()
	Local oStruDMD 		:= MdoStruDMD()
	Local oStruDLA 		:= MdoStruDLA()
	
	Local bLinePreOri 	:= {| oModel, nLine, cOpera, cCampo, nVal| T153ILOri (oModel, nLine, cOpera, cCampo, nVal) }
	Local bLinePreDmd 	:= {| oModel, nLine, cOpera, cCampo, nVal| T153ILDmd (oModel, nLine, cOpera, cCampo, nVal) }
	
	Local bPostDl8 := {| oModel| T153IPost(oModel)}
	Local bCommit  := {| oModel| TM153ICmt(oModel)}
			
	Default cUmDmd := '1'
	
	//Cria model principal - Cabecalho
	oModel := MPFormModel():New( 'TMSA153I',/*bPre*/,bPostDl8, bCommit,/*bCancel*/)
		
	oModel:SetDescription(STR0004) //Fracionamento de demanda
		
	//Field principal
	oModel:AddFields('MASTER_DL8',Nil,oStruDL8)
	
	//Adiciona os grids
	oModel:AddGrid('GRID_DEMAN','MASTER_DL8' ,oStruDMD , bLinePreDmd,/*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bload*/)
	oModel:SetRelation( 'GRID_DEMAN'  , { {'DMD_SEQ', 'DL8_SEQ'}}, DLA->( IndexKey( 1 )))
	
	oModel:GetModel('GRID_DEMAN'):SetDescription(STR0006) //Demandas
	
	//Grid nao obrigatorio 
	oModel:GetModel('GRID_DEMAN'):SetOptional(.T.)
	
	oModel:SetOnlyQuery('GRID_DEMAN',.T.)
	
	//Controle de nao repeticao de linha
	oModel:GetModel( 'GRID_DEMAN' ):SetUniqueLine( { 'DMD_SEQ' } )
	
	If cUmDmd == '1'
		oModel:AddGrid('GRID_ORI'  ,'GRID_DEMAN' ,oStruDLA, bLinePreOri,/*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bload*/)
		oModel:GetModel('GRID_ORI'):SetOptional(.T.)
		oModel:SetRelation( 'GRID_ORI'  , { {'DLA_SEQDMD', 'DMD_SEQ'}}, DLA->( IndexKey( 1 )))
		oModel:SetOnlyQuery('GRID_ORI',.T.)
		oModel:GetModel('GRID_ORI'):SetNoInsertLine(.T.)
		oModel:GetModel('GRID_ORI'):SetNoDeleteLine(.T.)
	EndIf
		
	oModel:SetPrimaryKey({}) 

Return oModel

/*/{Protheus.doc} ViewDef
View
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function ViewDef()
	Local oModel   := FWLoadModel('TMSA153I')
	Local oStruDL8 := VwStruDL8()
	Local oStruDMD := VwStruDMD()
	Local oStruDLA := VwStruDLA()
	
	Default cUmDmd := '1'

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_DL8', oStruDL8, 'MASTER_DL8' )
	
	If cUmDmd == '1'
		oView:CreateHorizontalBox('BOX_UP',15)
		oView:CreateHorizontalBox('BOX_MD',45)
		oView:CreateHorizontalBox('BOX_DW',40)
		
		oView:AddGrid('GRID_ORI', oStruDLA, 'GRID_ORI')
		oView:EnableTitleView('GRID_ORI', STR0005) //Origens
		
		oView:AddIncrementField( 'GRID_ORI', 'DLA_SEQREG' )
		oView:SetOwnerView( 'GRID_ORI', 'BOX_DW')
		
		oView:SetNoDeleteLine('GRID_ORI')
		oView:SetNoInsertLine('GRID_ORI')
	Else
		oView:CreateHorizontalBox('BOX_UP',15)
		oView:CreateHorizontalBox('BOX_MD',85)
	EndIf
	
	//Cria grid de demandas
	oView:AddGrid('GRID_DEMAN', oStruDMD, 'GRID_DEMAN')
	oView:EnableTitleView('GRID_DEMAN', STR0006) //Demandas
	
	oView:AddIncrementField( 'GRID_DEMAN', 'DMD_SEQ' )
	
	oView:SetOwnerView( 'VIEW_DL8', 'BOX_UP')
	oView:SetOwnerView( 'GRID_DEMAN', 'BOX_MD')
	
	oView:SetViewProperty( 'GRID_DEMAN', "CHANGELINE", {{ |oView| T153IPDmd(oView) }} )
	oView:SetViewProperty( '*', 'GRIDNOORDER')
	
Return oView

/*/{Protheus.doc} MdoStruDL8
Estrutura da tabela DL8
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function MdoStruDL8() 
	Local oStruDL8 := FWFormStruct(1, 'DL8')
	
	/* Ordem do parametros AddField
	[01]  C   Titulo do campo  
	[02]  C   ToolTip do campo
	[03]  C   Id do Field
	[04]  C   Tipo do campo
	[05]  N   Tamanho do campo
	[06]  N   Decimal do campo
	[07]  B   Code-block de validação do campo
	[08]  B   Code-block de validação When do campo
	[09]  A   Lista de valores permitido do campo
	[10]  L   Indica se o campo tem preenchimento obrigatório
	[11]  B   Code-block de inicializacao do campo
	[12]  L   Indica se trata-se de um campo chave
	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	[14]  L   Indica se o campo é virtual*/
	
	oStruDL8:AddField(STR0007, STR0007, "DL8_COD", "C", TAMSX3("DL8_COD")[1], 0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)
					 
	oStruDL8:AddField(STR0008, STR0008, "DL8_SEQ", "C", TAMSX3("DL8_SEQ")[1], 0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)
					 
	oStruDL8:AddField(STR0009, STR0009, "DL8_QTD", "N", TAMSX3("DL8_QTD")[1], 0,	 NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)				 
	
	oStruDL8:AddField(STR0010, STR0010, "DL8_FRAC", "N", TAMSX3("DL8_QTD")[1], 0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)
					 
Return oStruDL8

/*/{Protheus.doc} MdoStruDMD
Estrutura da tabela DMD
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function MdoStruDMD() 
	Local oStruDMD := FWFormModelStruct():New()

    oStruDMD:AddTable( '' , { 'DMD1' } , "Fracionammento de Demandas" , {|| ''} )
	
	oStruDMD:AddField(STR0010, STR0010, "DMD_SEQ", "C", TAMSX3("DL8_SEQ")[1], 0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .F.)
					 
	oStruDMD:AddField(STR0011, STR0011, "DMD_QTD", "N", TAMSX3("DL8_QTD")[1], 0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .F.)			 

Return oStruDMD

/*/{Protheus.doc} MdoStruDLA
Estrutura da tabela DLA
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function MdoStruDLA() 
	Local oStruDLA := FWFormStruct(1, 'DLA')
	
	oStruDLA:RemoveField('DLA_DTPREV')
	oStruDLA:RemoveField('DLA_HRPREV')
	oStruDLA:RemoveField('DLA_CODCLI')
	oStruDLA:RemoveField('DLA_LOJA')
	oStruDLA:RemoveField('DLA_PREVIS')
	
	If cUmDmd == '1'
		oStruDLA:SetProperty('DLA_QTD', MODEL_FIELD_WHEN,{||.T.})
	EndIf
		
Return oStruDLA

/*/{Protheus.doc} VwStruDL8
Estrutuda da tabela DL8                  
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function VwStruDL8()
	Local oStruDL8 := FWFormStruct(2, 'DL8')
	
	/* Ordem do parametros AddField
	[01]  C   Nome do Campo
	[02]  C   Ordem
	[03]  C   Titulo do campo//"Descrição"
	[04]  C   Descricao do campo//"Descrição"
	[05]  A   Array com Help
	[06]  C   Tipo do campo
	[07]  C   Picture
	[08]  B   Bloco de Picture Var
	[09]  C   Consulta F3
	[10]  L   Indica se o campo é alteravel
	[11]  C   Pasta do campo
	[12]  C   Agrupamento do campo
	[13]  A   Lista de valores permitido do campo (Combo)
	[14]  N   Tamanho maximo da maior opção do combo
	[15]  C   Inicializador de Browse
	[16]  L   Indica se o campo é virtual
	[17]  C   Picture Variavel
	[18]  L   Indica pulo de linha após o campo*/

	oStruDL8:AddField("DL8_QTD", "01", STR0009, STR0009, NIL, "C", "@!", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
	
	oStruDL8:AddField("DL8_FRAC", "02", STR0010, STR0010, NIL, "N", "@!", NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
					
	oStruDL8:SetProperty( 'DL8_FRAC', MVC_VIEW_CANCHANGE, .F. )					
	
Return oStruDL8

/*/{Protheus.doc} VwStruDMD
Estrutuda da tabela DMD
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function VwStruDMD()
	Local oStruDMD := FWFormViewStruct():New()
	Local cMascQtd := ''
		
	oStruDMD:AddField("DMD_SEQ", "01", STR0008, STR0008, NIL, "C", "@!", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL)
	
	IIf(cUmDmd == '1', cMascQtd := "@E 999,999,999.9999", cMascQtd := "@E 999,999,999")
	
	oStruDMD:AddField("DMD_QTD", "02", STR0011, STR0011, {STR0014}, "N", cMascQtd, NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL)
	
	If cUmDmd == '1'		
		oStruDMD:SetProperty( 'DMD_QTD', MVC_VIEW_CANCHANGE, .F. )
	EndIf
Return oStruDMD

/*/{Protheus.doc} VwStruDLA
Estrutuda da tabela DLA
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Static Function VwStruDLA()
	Local oStruDLA := FWFormStruct(2, 'DLA')
	
	oStruDLA:RemoveField('DLA_CODDMD')
	oStruDLA:RemoveField('DLA_SEQDMD')
	oStruDLA:RemoveField('DLA_DTPREV')
	oStruDLA:RemoveField('DLA_HRPREV')
	oStruDLA:RemoveField('DLA_CODCLI')
	oStruDLA:RemoveField('DLA_LOJA')
	oStruDLA:RemoveField('DLA_NOMCLI')
	oStruDLA:RemoveField('DLA_PREVIS')
	
	oStruDLA:SetProperty( 'DLA_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	oStruDLA:SetProperty( 'DLA_CODREG', MVC_VIEW_CANCHANGE, .F. )
	
Return oStruDLA

//-------------------------------------------------------------------
/*/{Protheus.doc} T153IVlAct()
Valida Activate do Model
@author  Gustavo Krug
@since   10/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153IVlAct(oModel,nLine, cAction)
Local lRet := .T.
	If DL8->DL8_UM == "2".AND. DL8->DL8_QTD <= 1
		Help( ,, 'HELP',,STR0032, 1, 0 ) //Não é possível fracionar uma demanda de unidade de medida 'Quantidade de veículo' que possua apenas um veículo
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} T153ILPre
Pre validacao da linha do grid Origens 
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Function T153ILOri (oModel, nLine, cOpera, cCampo, nVal)
	Local oModelDMD  := oModel:GetModel( 'GRID_DEMAN' )
	Local nLintemp   := oModel:GetLine()
	Local nQtd := 0
	Local nX   := 0
	
	Local lRet := .T.
	
	If cOpera == "SETVALUE" .AND. cCampo == 'DLA_QTD'
		For nX := 1 to oModel:GetQtdLine()
			If !oModel:IsDeleted(nX)  
				//Valor informado para fracionar não pode ser negativo
				lRet := Positivo(nVal)
				If lRet
					If nLine == nX
						nQtd += nVal
					Else
						nQtd += oModel:GetValue("DLA_QTD", nX) 
					EndIf
				EndIf
			EndIf
		Next nX

		If lRet .AND. nQtd >= 0  
			oModelDMD:SetValue("GRID_DEMAN","DMD_QTD",nQtd)
		EndIf
		oModel:GoLine(nLintemp)
	EndIf

Return lRet

/*/{Protheus.doc} T153ILDmd
Pre validacao da linha do grid Demanda 
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Function T153ILDmd(oModel, nLine, cOpera, cCampo, nVal)	
	Local oModelCab  := oModel:GetModel( 'GRID_DEMAN' )
	Local nLintemp   := oModel:GetLine()
	Local nQtd := 0
	Local nX   := 0
	
	Local lRet := .T.
	
	If cOpera == "SETVALUE" .And. cCampo == 'DMD_QTD'
		For nX := 1 to oModel:GetQtdLine()
			If !oModel:IsDeleted(nX)  
			//Valor informado para fracionar não pode ser negativo
				lRet := Positivo(nVal)
				If lRet
					If nLine == nX
						nQtd += nVal
					Else
						nQtd += oModel:GetValue("DMD_QTD", nX) 
					EndIf
				EndIf
			EndIf
		Next nX

		If lRet .AND. nQtd >= 0  
			oModelCab:SetValue("MASTER_DL8","DL8_FRAC",nQtd)
		EndIf
		oModel:GoLine(nLintemp)
	ElseIf cOpera == "DELETE"
		If oModel:GetLine() == 1
			Help( ,, 'HELP',,STR0013, 1, 0 ) //Nao e possivel excluir a demanda original
			lRet := .F.
		Else
			nQtd := oModelCab:GetValue("MASTER_DL8","DL8_FRAC") - oModel:GetValue("DMD_QTD")
			oModelCab:SetValue("MASTER_DL8","DL8_FRAC",nQtd)
		EndIf
	ElseIf cOpera == "UNDELETE"
		nQtd := oModelCab:GetValue("MASTER_DL8","DL8_FRAC") + oModel:GetValue("DMD_QTD")
		oModelCab:SetValue("MASTER_DL8","DL8_FRAC",nQtd)
	EndIf
	
Return lRet

/*/{Protheus.doc} T153IPDmd
Carga de dados na origem 
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Function T153IPDmd(oView)
	Local oModelAux := Nil
	Local oModelDmd := Nil
	Local oModelOri := Nil
	
	Local nQtd := 0
	Local nLin := 0
	Local nX := 0

	Local lRet := .T.
	
	If cUmDmd == '1'
		oModelAux := FWModelActive()
		oModelDmd := oModelAux:GetModel('GRID_DEMAN')
		oModelOri := oModelAux:GetModel('GRID_ORI')
		
		nQtd := oModelDmd:GetQtdLine()
		nLin := oModelDmd:GetLine()

		If nQtd > nQtdLin .And. nQtd == nLin
			nQtdLin++
			oModelOri:SetNoInsertLine(.F.)
				
			//Atribui valor as regioes de origem
			For nX := 1 To Len(aRegOri)
				Iif(nX != 1, oModelOri:AddLine(),)
				oModelOri:SetValue("DLA_SEQREG",aRegOri[nX][1])
				oModelOri:SetValue("DLA_CODREG",aRegOri[nX][2])
				oModelOri:SetValue("DLA_QTD", 0)
				oModelOri:LoadValue("DLA_NOMREG",Posicione("DUY",1,xFilial("DUY")+aRegOri[nX][2],"DUY_DESCRI"))
			Next nX
				
			oModelOri:SetNoInsertLine(.T.)
			oModelOri:SetLine(1)
			If !IsBlind()
				oView:Refresh('GRID_ORI')
			EndIf
		ElseIf nQtd < nQtdLin
			nQtdLin-- 
		EndIf
	EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} T153IPost
Bloco de codigo de pos-validacao do modelo
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function T153IPost(oModel)
Local lRet := .T.
Local oModelDMD := oModel:GetModel('GRID_DEMAN')

	If lRet .AND. oModel:GetValue('MASTER_DL8','DL8_QTD') != oModel:GetValue('MASTER_DL8','DL8_FRAC') 
		FWClearHLP()
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0012, "", "", "") //'Quantidade fracionado difere da quantidade da demanda original'
		lRet := .F.
	Endif

	If lRet .AND. oModelDMD:Length(.T.) == 1
		FWClearHLP()
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0033, "", "", "") //"Existe apenas uma demanda. Não será feito fracionamento."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} TM153ICmt
//Função de Commit do modelo de dados

@author ana.olegini
@since 27/09/2018
@param  oModel, object, objeto do modelo de dados
@return lRetorno, retorno de verdadeiro ou falso
/*/
Function TM153ICmt(oModel)
	Local lRetorno 	:= .T.
	
	//--Função de fracionamento
	lRetorno := TM153IDem( oModel )
	
	If .NOT. lRetorno
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0017, STR0018, "", "")	//"Não foi possível Confirmar o fracionamento."#"Por Favor, verifique as informações!"
	EndiF 

	If lRetorno .AND. !IsBlind() // Altera mensagem padrao de registro incluido com sucesso.
		oView := FwViewActive()
		oView:SetInsertMessage(STR0019,STR0020) //"Gerar Fracionamento"#"Fracionamento gerado com sucesso."
		oView:ShowInsertMsg(.T.)
	EndIf

Return lRetorno

/*/{Protheus.doc} TM153IDem
//Função de fracionamento das demandas

@author ana.olegini
@since 27/09/2018
@param  oModel, object, objeto do modelo de dados
@return lRetorno, retorno de verdadeiro ou falso
/*/
Function TM153IDem( oModel )
	Local nIndex	:= DL8->(IndexOrd())	
	Local aAreaDL7	:= DL7->(GetArea())
	Local aAreaDL8	:= DL8->(GetArea())
	Local cTempDL8 	:= GetNextAlias()
	Local cTempDLA 	:= GetNextAlias()
	Local cTempDLL	:= GetNextAlias()
	Local lRetorno	:= .T.

	Local aErro		:= {}
	Local cMsg		:= ""
	Local nX		:= 0
	Local nY		:= 0
	Local nContOri  := 1
	Local nContDes  := 1
	Local nQtdTot   := 0
	Local nQtdDmd   := 0
	Local nSeq      := ''
	
	Local oModelDMD := oModel:GetModel('GRID_DEMAN')	//--Modelo Field TMSA153I
	Local oModelORI := oModel:GetModel('GRID_ORI')		//--Modelo Grid  TMSA153I
	
	TM153IQry(@cTempDL8, @cTempDLA ,@cTempDLL)

	Begin Transaction
		//--Quantidades de demandas
		For nX:= 1 to oModelDMD:Length()
			oModelDMD:GoLine(nX)
			If .NOT. oModelDMD:IsDeleted(nX) 		
				nQtdTot += oModelDMD:GetValue("DMD_QTD", nX)	
			EndIf 
		Next nX
		//--Valida se a quantidade total é diferente da demanda original
		If nQtdTot <> oModel:GetValue('MASTER_DL8','DL8_QTD')
			Help( ,, STR0030,, STR0031 , 1, 0 ) //"HELP"#"Quantidade total difere da quantidade da demanda original."
			lRetorno:= .F.
			DisarmTransaction()
			Break			
		EndIf
		
		If lRetorno
			oModelDL8 := FWLoadModel('TMSA153A')
			oMdFldDL8 := oModelDL8:GetModel('MASTER_DL8')	//Field
			oMdGrdORI := oModelDL8:GetModel('GRID_ORI')		//Grid Origem
			oMdGrdDES := oModelDL8:GetModel('GRID_DES')		//Grid Destino
			
			For nX := 1 to oModelDMD:GetQtdLine()
				oModelDMD:GoLine(nX)
				If !oModelDMD:IsDeleted(nX) .AND. !Empty(oModelDMD:GetValue("DMD_QTD", nX))
					//--Realiza a alteração do registro pai
					If nX == 1
						oModelDL8:SetOperation( MODEL_OPERATION_UPDATE )
						oModelDL8:Activate()						
						nSeq := TM153ISeq()
						oMdFldDL8:LoadValue("DL8_MARK"	 , " ")
						oMdFldDL8:LoadValue("DL8_QTD", oModelDMD:GetValue("DMD_QTD", nX) )
												
						If oMdFldDL8:GetValue("DL8_UM") == '1'	//- 1=Peso
							For nY:= 1 to oMdGrdORI:GetQtdLine()
								oMdGrdORI:GoLine(nY)
								oModelDL8:SetValue('GRID_ORI',"DLA_QTD", oModelORI:GetValue("DLA_QTD", nY) )
							Next nY
							oMdGrdORI:SetLine(1)	
						EndIf
					
					//--Realiza a inclusao do registro filho			
					Else 
						//--Insere a nova demanda
						oModelDL8:SetOperation(MODEL_OPERATION_INSERT)
						//--Retira as validações gerais
						oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
						oModelDL8:GetModel('GRID_ORI'  ):GetStruct():SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
						oModelDL8:GetModel('GRID_DES'  ):GetStruct():SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
						//--Retira os modos de edição 
						oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.T.})
						oModelDL8:GetModel('GRID_ORI'  ):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.T.})
						oModelDL8:GetModel('GRID_DES'  ):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.T.})
						oModelDL8:Activate()
						
						//--Field
						oMdFldDL8:SetValue("DL8_FILIAL"	 , FWxFilial("DL8"))
						nSeq := Soma1(nSeq)
						oMdFldDL8:LoadValue("DL8_COD"	 , cCdDemd)
						oMdFldDL8:LoadValue("DL8_SEQ"    , nSeq	  )
						oMdFldDL8:LoadValue("DL8_CRTDMD" , (cTempDL8)->DL8_CRTDMD)
						oMdFldDL8:LoadValue("DL8_CODGRD" , (cTempDL8)->DL8_CODGRD)
						oMdFldDL8:LoadValue("DL8_TIPVEI" , (cTempDL8)->DL8_TIPVEI)
						oMdFldDL8:SetValue("DL8_CLIDEV"	 , (cTempDL8)->DL8_CLIDEV)
						oMdFldDL8:SetValue("DL8_LOJDEV"	 , (cTempDL8)->DL8_LOJDEV)
						oMdFldDL8:LoadValue("DL8_UM"	 , (cTempDL8)->DL8_UM)						
						oMdFldDL8:SetValue("DL8_FILGER"  , (cTempDL8)->DL8_FILGER)
						oMdFldDL8:SetValue("DL8_DATPRV"  , StoD((cTempDL8)->DL8_DATPRV))
						oMdFldDL8:SetValue("DL8_HORPRV"  , (cTempDL8)->DL8_HORPRV)
						oMdFldDL8:SetValue("DL8_FILEXE"  , (cTempDL8)->DL8_FILEXE)
								
						oMdFldDL8:GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
						oMdFldDL8:LoadValue("DL8_QTD"	 , oModelDMD:GetValue("DMD_QTD", nX) )													
						oMdFldDL8:SetValue("DL8_STATUS" ,'1')							
						
						//Rollback da numeração SX8 feito neste ponto pois após o commit não funciona
						DL8->(RollBackSX8())

						cMsg := MSMM( (cTempDL8)->DL8_CODOBS ,/*nTam*/,/*nLin*/,/*cString*/,3,/*nTamSize*/,/*lWrap*/,/*cAlias*/,/*cCpoChave*/,/*cRealAlias*/,/*lSoInclui*/)

						(cTempDLA)->(dbGoTop())
						//--Grid Origem
						While (cTempDLA)->(!EOF())
							cGridReg := "GRID_ORI"
							If nContOri > 1
								oModelDL8:GetModel(cGridReg):AddLine()
							EndIf
							oModelDL8:SetValue(cGridReg,"DLA_FILIAL", 	FWxFilial("DLA"))
							oModelDL8:SetValue(cGridReg,"DLA_CODDMD", 	cCdDemd)
							oModelDL8:SetValue(cGridReg,"DLA_SEQDMD", 	nSeq)
							oModelDL8:SetValue(cGridReg,"DLA_SEQREG", 	StrZero(nContOri,TamSx3("DLA_SEQREG")[1])) 
							oModelDL8:SetValue(cGridReg,"DLA_CODREG", 	(cTempDLA)->DLA_CODREG)
							oModelDL8:SetValue(cGridReg,"DLA_CODCLI", 	(cTempDLA)->DLA_CODCLI)
							oModelDL8:SetValue(cGridReg,"DLA_LOJA " , 	(cTempDLA)->DLA_LOJA)
							oModelDL8:SetValue(cGridReg,"DLA_DTPREV",	StoD((cTempDLA)->DLA_DTPREV))
							oModelDL8:SetValue(cGridReg,"DLA_HRPREV",	(cTempDLA)->DLA_HRPREV)
							oModelDL8:SetValue(cGridReg,"DLA_PREVIS",	(cTempDLA)->DLA_PREVIS)

							If oMdFldDL8:GetValue("DL8_UM") == '1'	//- 1=Peso
								For nY:= 1 to oMdGrdORI:GetQtdLine()
									oMdGrdORI:GoLine(nY)
									oModelDL8:SetValue('GRID_ORI',"DLA_QTD", oModelORI:GetValue("DLA_QTD", nY) )
								Next nY
								oMdGrdORI:SetLine(1)	
							EndIf
							
							nContOri ++
							(cTempDLA)->(dbSkip())
						EndDo	
						
						(cTempDLL)->(dbGoTop())
						//--Grid Destino
						While (cTempDLL)->(!EOF())
							cGridReg := "GRID_DES"
							If nContDes > 1
								oModelDL8:GetModel(cGridReg):AddLine()
							EndIf
							oModelDL8:SetValue(cGridReg,"DLL_FILIAL", FWxFilial("DLL"))
							oModelDL8:SetValue(cGridReg,"DLL_CODDMD", cCdDemd)
							oModelDL8:SetValue(cGridReg,"DLL_SEQDMD", nSeq   )
							oModelDL8:SetValue(cGridReg,"DLL_SEQREG", (cTempDLL)->DLL_SEQREG) 
							oModelDL8:SetValue(cGridReg,"DLL_CODREG", (cTempDLL)->DLL_CODREG)
							oModelDL8:SetValue(cGridReg,"DLL_DTPREV", StoD((cTempDLL)->DLL_DTPREV))
							oModelDL8:SetValue(cGridReg,"DLL_HRPREV", (cTempDLL)->DLL_HRPREV)
							oModelDL8:SetValue(cGridReg,"DLL_PREVIS", (cTempDLL)->DLL_PREVIS)	
							nContDes ++
							(cTempDLL)->(dbSkip())
						EndDo				
					
						nContOri := 1
						nContDes := 1
					EndIf //Fim 1
					
					//--Valida o modelo de dados
					If oModelDL8:VldData() 
						If oModelDL8:CommitData()
							nQtdDmd ++
							If nQtdDmd >= oModelDMD:GetQTDLine()
								nQtdDmd   := 0
							EndIf
							
							//--GRAVA o campo MEMO separadamente ao utilizar o modelo de dados para gravação
							//--a sequencia do memo é duplicada, ou seja a função MSMM cria um novo registro
							//--porém o modelo de dados salva o código do registro pai e deleta o novo.
							//--Não é necessario realizar a gravação atraves do modelo de dados
							If .NOT. Empty(cMsg) 
								oModelDL8:DeActivate()
								//--Posiciona no regsitro que foi incluido e realiza a gravação do campo memo
								DL8->(DbSetOrder(1))
								DL8->( DbSeek(xFilial('DL8')+cCdDemd+nSeq))								
								MSMM( DL8->DL8_CODOBS, , , cMsg, 1, , ,"DL8", "DL8_CODOBS" ) 
							EndIf
						Else 
							lRetorno := .F.
							aErro 	 := oModel:GetErrorMessage()
							DisarmTransaction()
							Break
						EndIf
					Else 
						lRetorno := .F.
						aErro 	 := oModel:GetErrorMessage()
						DisarmTransaction()
						Break
					EndIf //Fim 2
					oModelDL8:DeActivate()
				EndIf
				//No ponto onde é chamado o Activate do Model "TMSA153A", são efetuados os Locks. Porém, antes não era feito nenhum Unlock. 
				//Este trecho visa efetuar o Unlock das Demandas geradas, de modo que outros usuários possam utilizá-las. 
				If !Empty(cCdDemd) .And. !Empty(cSqDemd)
					TMUnLockDmd('TMSA153A_' + FWxFilial("DL8") + cCdDemd + cSqDemd,.T.)
				EndIf				
			Next nX
			
		EndIf
	End Transaction
	
	//--Apresenta as mensagens de erro do modelo de dados
	If .NOT. lRetorno
		If .Not. Empty(aErro)
			AutoGrLog( STR0021 	+ ' [' + AllToChar( aErro[1] ) + ']' )	//'Id do submodelo de origem'
			AutoGrLog( STR0022	+ ' [' + AllToChar( aErro[2] ) + ']' )	//'Id do campo de origem'
			AutoGrLog( STR0023 	+ ' [' + AllToChar( aErro[3] ) + ']' )	//'Id do submodelo de erro'
			AutoGrLog( STR0024	+ ' [' + AllToChar( aErro[4] ) + ']' )	//'Id do campo de erro'
			AutoGrLog( STR0025	+ ' [' + AllToChar( aErro[5] ) + ']' )	//'Id do erro'
			AutoGrLog( STR0026 	+ ' [' + AllToChar( aErro[6] ) + ']' )	//'Mensagem do problema
			AutoGrLog( STR0027	+ ' [' + AllToChar( aErro[7] ) + ']' )	//'Mensagem da solução'
			AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[8] ) + ']' )	//'Valor atribuido'
			AutoGrLog( STR0029	+ ' [' + AllToChar( aErro[9] ) + ']' )	//'Valor anterior'
			MostraErro()
		EndIf
	EndIf

	(cTempDL8)->(dbCloseArea())
	(cTempDLA)->(dbCloseArea())
	(cTempDLL)->(dbCloseArea())
	
	RestArea( aAreaDL7 )
	RestArea( aAreaDL8 )	
	DL8->(DbSetOrder(nIndex))
Return lRetorno


/*/{Protheus.doc} TM153IQry
// Função de queries 
@author  ana.olegini
@since   01/10/2018
/*/
Function TM153IQry(cTempDL8, cTempDLA ,cTempDLL)
	Local cQuery	:= ""

	If .NOT. Empty(cTempDL8)
		cQuery  := "  SELECT DL8.DL8_COD,    DL8.DL8_SEQ,    DL8.DL8_QTD,    DL8.DL8_UM,     DL8.DL8_CRTDMD,"
		cQuery  += "         DL8.DL8_CLIDEV, DL8.DL8_LOJDEV, DL8.DL8_CODGRD, DL8.DL8_TIPVEI, DL8.DL8_CODOBS,"
		cQuery  += "         DL8.DL8_FILGER, DL8.DL8_DATPRV, DL8.DL8_HORPRV, DL8.DL8_FILEXE "
		cQuery  += "    FROM "+RetSqlName('DL8')+ " DL8 "
		cQuery  += "   WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery  += "     AND DL8.DL8_COD = '" + cCdDemd + "'"
		cQuery  += "     AND DL8.DL8_SEQ = '" + cSqDemd + "'"
		cQuery  += "     AND DL8.D_E_L_E_T_ = ' '"
		cQuery  := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDL8, .F., .T. )
	EndIf
	
	If .NOT. Empty(cTempDLA)
		//Busca as regioes de origem da demanda
		cQuery  := "  SELECT DLA.DLA_SEQDMD, DLA.DLA_SEQREG, "
		cQuery  += "         DLA.DLA_CODREG, DLA.DLA_DTPREV, DLA.DLA_HRPREV, "
		cQuery  += "         DLA.DLA_QTD, DLA.DLA_PREVIS, DLA.DLA_CODCLI, DLA.DLA_LOJA "
		cQuery  += "    FROM "+RetSqlName('DLA')+ " DLA "
		cQuery  += "   WHERE DLA.DLA_FILIAL = '" + xFilial('DLA') + "'"
		cQuery  += "     AND DLA.DLA_CODDMD = '" + (cTempDL8)->DL8_COD + "'"
		cQuery  += "     AND DLA.DLA_SEQDMD = '" + (cTempDL8)->DL8_SEQ + "'"
		cQuery  += "     AND DLA.D_E_L_E_T_ = ' '"
		cQuery  := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDLA, .F., .T. ) 
	EndIf

	If .NOT. Empty(cTempDLL)
		//Busca as regioes de origem da demanda
		cQuery  := "  SELECT DLL.DLL_SEQDMD, DLL.DLL_SEQREG, "
		cQuery  += "         DLL.DLL_CODREG, DLL.DLL_PREVIS, "
		cQuery  += "         DLL.DLL_DTPREV, DLL.DLL_HRPREV  "
		cQuery  += "    FROM "+RetSqlName('DLL')+ " DLL "
		cQuery  += "   WHERE DLL.DLL_FILIAL = '" + FWxFilial('DLL') + "'"
		cQuery  += "     AND DLL.DLL_CODDMD = '" + (cTempDL8)->DL8_COD + "'"
		cQuery  += "     AND DLL.DLL_SEQDMD = '" + (cTempDL8)->DL8_SEQ + "'"
		cQuery  += "     AND DLL.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDLL, .F., .T. ) 
	EndIf
Return

/*/{Protheus.doc} TM153ISeq
// Função busca a sequencia maxima da DL8

@author  ana.olegini
@since   02/10/2018
/*/
Function TM153ISeq()
	Local cSeqMax := ""
	Local cQuery  := ""
	Local cQryDL8 := GetNextAlias()

	cQuery  := "  SELECT MAX(DL8_SEQ) SEQMAX"
	cQuery  += "    FROM "+RetSqlName('DL8')+ " DL8 "
	cQuery  += "   WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
	cQuery  += "     AND DL8.DL8_COD = '" + cCdDemd + "'"
	cQuery  += "     AND DL8.D_E_L_E_T_ = ' '"
	cQuery  := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDL8, .F., .T. )
	cSeqMax := (cQryDL8)->SEQMAX
	(cQryDL8)->(dbCloseArea())
Return cSeqMax

