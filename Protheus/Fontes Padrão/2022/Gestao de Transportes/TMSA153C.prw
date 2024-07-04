#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153C.ch'

Static lUndelDLE := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA153C()
MVC Contrato de demandas 
@author  Gustavo Krug
@since   13/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMSA153C()
PRIVATE lMsErroAuto := .F.
Return

/*---------------------------------------------------
MenuDef
---------------------------------------------------*/
Static Function Menudef()
Local aRotina := {}

	aAdd(aRotina, {STR0001,'VIEWDEF.TMSA153C', 0, 3, 0, NIL}) //Incluir
	aAdd(aRotina, {STR0002,'VIEWDEF.TMSA153C', 0, 4, 0, NIL}) //Alterar
	aAdd(aRotina, {STR0003,'VIEWDEF.TMSA153C', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0004,'VIEWDEF.TMSA153C', 0, 5, 0, NIL}) //Excluir
	aAdd(aRotina, {STR0005,'VIEWDEF.TMSA153C', 0, 9, 0, NIL}) //Copiar
	aAdd(aRotina, {STR0006,'T153SUSP()', 0, 4, 0, NIL}) //Suspender Contrato
	aAdd(aRotina, {STR0007,'T153RETM()', 0, 4, 0, NIL}) //Retomar Contrato
	aAdd(aRotina, {STR0008,'T153ENCE()', 0, 4, 0, NIL}) //Encerrar Contrato
	aAdd(aRotina, {STR0010,'TMA154Par(3, DL7->DL7_COD, , , , DL7->DL7_CLIDEV, DL7->DL7_LOJDEV, 1)', 0, 2, 0, NIL}) //Tracking 
	
Return aRotina

/*---------------------------------------------------
ModelDef
---------------------------------------------------*/
Static Function ModelDef()
Local oModel  := nil
Local oStruDL7 := FWFormStruct(1, "DL7")
Local oStruDLE := FWFormStruct(1, "DLE")
Local oStrDLM := FWFormStruct(1, "DLM")
Local oStrDLN := FWFormStruct(1, "DLN")

Local bPre       := {|oModel| T153PreCrt(oModel)}
Local bPost      := {|oModel| T153PosCrt(oModel)}
Local bCommit    := {|oModel| T153GrvCrt(oModel)}

Local bLnPreGRD  := {|oModel,nLine,cOpera, cCampo, nVal| T153LnPreGRD (oModel, nLine, cOpera, cCampo, nVal) }
Local bLnPostGRD := {|oModel| T153LnPGRD(oModel)}
Local bPreValGRD := {|oModel,nLine,cOpera, cCampo | T153PrVlGR(oModel, nLine, cOpera, cCampo) }

Local bLnPreOri  := {| oDlOri,nLine,cOpera, cCampo, nVal| T153LnPreOri (oDlOri, nLine, cOpera, cCampo, nVal) }
Local bLnPreDes  := {| oDlDes,nLine,cOpera, cCampo, nVal| T153LnPreDes (oDlDes, nLine, cOpera, cCampo, nVal) }
Local bPreReg1   := {| oDlReg,nLine,cOpera,cCampo | T153PreReg (oDlReg, nLine, cOpera, cCampo,"1") }
Local bPreReg2   := {| oDlReg,nLine,cOpera,cCampo | T153PreReg (oDlReg, nLine, cOpera, cCampo,"2") }

	oStruDL7:AddField(												 ;	// Ord. Tipo Desc.
	STR0057															,;	// 	[01]  C   Titulo do campo 		//STR0057- 'Tipo Veículo Operacional' 
	STR0057															,;	// 	[02]  C   ToolTip do campo		//STR0057- 'Tipo Veículo Operacional' 
	"DL7_TIPVEI"													,;	// 	[03]  C   Id do Field
	"C"																,;	// 	[04]  C   Tipo do campo
	9																,;	// 	[05]  N   Tamanho do campo
	0																,;	// 	[06]  N   Decimal do campo
	NIL 															,;	// 	[07]  B   Code-block de validação do campo
	NIL																,;	// 	[08]  B   Code-block de validação When do campo
	NIL																,;	//	[09]  A   Lista de valores permitido do campo
	.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	NIL																,;	//	[11]  B   Code-block de inicializacao do campo
	.F.																,;	//	[12]  L   Indica se trata-se de um campo chave
	.F.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.																)	// 	[14]  L   Indica se o campo é virtual

	oStruDLE:AddField(												 ;	// Ord. Tipo Desc.
	STR0059															,;	// 	[01]  C   Titulo do campo		//STR0059- 'Tipo Veículo Meta'
	STR0059															,;	// 	[02]  C   ToolTip do campo		//STR0059- 'Tipo Veículo Meta'	
	"DLE_TIPVEI"													,;	// 	[03]  C   Id do Field
	"C"																,;	// 	[04]  C   Tipo do campo
	9																,;	// 	[05]  N   Tamanho do campo
	0																,;	// 	[06]  N   Decimal do campo
	NIL																,;	// 	[07]  B   Code-block de validação do campo
	NIL																,;	// 	[08]  B   Code-block de validação When do campo
	NIL																,;	//	[09]  A   Lista de valores permitido do campo
	.F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	NIL																,;	//	[11]  B   Code-block de inicializacao do campo
	.F.																,;	//	[12]  L   Indica se trata-se de um campo chave
	.F.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.																)	// 	[14]  L   Indica se o campo é virtual

	oModel := MPFormModel():New('TMSA153C',bPre, bPost, bCommit)
	oModel:SetDescription(STR0011) //Contratos de demandas
	
	oModel:SetVldActivate( { |oModel| TMSA153CVL(oModel) } )
	
	oStruDL7:AddTrigger("DL7_UM", "DL7_UM", {||.T.}, {|oModel|T153DL7UM(oModel)})
	oStruDLE:AddTrigger("DLE_CODGRD", "DLE_CODGRD", {||.T.}, {|oModel|T153DLEGRD(oModel)})
	
	oStrDLN:SetProperty("DLN_CODREG", MODEL_FIELD_OBRIGAT ,.F.)
		
	// Denife WHEN do campo Tipo de Veículo na tabela Grupo de Região de Demandas(DLE_TIPVEI)
	oStruDLE:SetProperty("DLE_TIPVEI", MODEL_FIELD_WHEN,{||.F.})
	oStruDLE:SetProperty("DLE_CODGRD", MODEL_FIELD_WHEN,{|oModel|T153WHENCD(oModel)}) 
	
	oStruDLE:SetProperty('DLE_DESGRD',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'T153IniDLe("DLE_DESGRD")'))
	
	oModel:AddFields('MASTER_DL7',nil,oStruDL7)
	oModel:SetPrimaryKey({"DL7_FILIAL","DL7_COD"})	
	
	oModel:AddGrid('GRID_DLE','MASTER_DL7',oStruDLE,bLnPreGRD,bLnPostGRD,bPreValGRD)
	oModel:AddGrid('GRID_ORI','GRID_DLE'  ,oStrDLM,bLnPreOri,,bPreReg1,/*bPostOri*/)
	oModel:AddGrid('GRID_DES','GRID_DLE'  ,oStrDLN,bLnPreDes,,bPreReg2,/*bPostDes*/)
		
	oModel:GetModel('GRID_DLE'):SetOptional(.T.)
	oModel:GetModel('GRID_ORI'):SetOptional(.T.)
	oModel:GetModel('GRID_DES'):SetOptional(.T.)
	
	oModel:GetModel('MASTER_DL7'):SetFldNoCopy({'DL7_COD','DL7_INIVIG','DL7_FIMVIG','DL7_QTDTOT','DL7_QTDSLD','DL7_QTDDEM','DL7_QTDPLN','DL7_QTDPRG','DL7_QTDVIA','DL7_QTDDEX','DL7_QTDREC','DL7_QTDRCL','DL7_STATUS','DL7_QTDENC','DL7_QTDCAN','DL7_QTDBLQ','DL7_QTDREP'})
	oModel:GetModel('GRID_DLE'):SetFldNoCopy({'DLE_QTD'})
	oModel:GetModel('GRID_ORI'):SetFldNoCopy({'DLM_QTD'})
	
	oModel:SetRelation( 'GRID_DLE', { { 'DLE_FILIAL', 'xFilial( "DLE" )' }, { 'DLE_CRTDMD', 'DL7_COD' }}, DLE->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'GRID_ORI', { { 'DLM_FILIAL', 'xFilial( "DLM" )' }, { 'DLM_CRTDMD', 'DLE_CRTDMD' },{ 'DLM_CODGRD', 'DLE_CODGRD' }}, DLM->( IndexKey( 1 ) ) ) 
	oModel:SetRelation( 'GRID_DES', { { 'DLN_FILIAL', 'xFilial( "DLN" )' }, { 'DLN_CRTDMD', 'DLE_CRTDMD' },{ 'DLN_CODGRD', 'DLE_CODGRD' }}, DLN->( IndexKey( 1 ) ) ) 

	oModel:GetModel( 'GRID_DLE' ):SetUniqueLine( { 'DLE_CODGRD'} )
	oModel:GetModel( 'GRID_ORI' ):SetUniqueLine( { 'DLM_CODREG'} )	
	oModel:GetModel( 'GRID_DES' ):SetUniqueLine( { 'DLN_CODREG'} )
	
	oModel:SetDeActivate({||aTipVeiDL7 := {}, aTipVeiDLE := {}, aDbTipVei1 := {}, aDbTipVei2 := {}})
Return oModel

/*---------------------------------------------------
ViewDef
---------------------------------------------------*/
Static Function ViewDef()
Local oModel   	:= FWLoadModel('TMSA153C')
Local oStruDL7 	:= FWFormStruct(2,'DL7')
Local oStruDLE 	:= FWFormStruct(2,'DLE')
Local oStrDLM 	:= FWFormStruct(2,'DLM')
Local oStrDLN 	:= FWFormStruct(2,'DLN')
Local bPictVar 	:= FwBuildFeature( STRUCT_FEATURE_PICTVAR, "'<<F3>>'" )
Local cFunction := "TMSA153C"

IIf(ExistFunc('FwPdLogUser'),FwPdLogUser(cFunction),)

	oStruDL7:AddField(													;
	"DL7_TIPVEI"		     											,;	// [01]  C   Nome do Campo
	cValToChar(Len(oStruDL7:aFields)+2)									,;	// [02]  C   Ordem - Soma 2 por conta do campo filial que não é exibido.
	STR0057																,;	// [03]  C   Titulo do campo		//STR0057- 'Tipo Veículo Operacional' 
	STR0057																,;	// [04]  C   Descricao do campo		//STR0057- 'Tipo Veículo Operacional' 
	{STR0058}															,;	// [05]  A   Array com Help			//STR0058- 'Tipo de Veículo Operacional.'
	"C"																	,;	// [06]  C   Tipo do campo
	"@!"																,;	// [07]  C   Picture
	bPictVar															,;	// [08]  B   Bloco de Picture Var
	"DL73"																,;	// [09]  C   Consulta F3
	.T.																	,;	// [10]  L   Indica se o campo é alteravel
	NIL																	,;	// [11]  C   Pasta do campo
	NIL																	,;	// [12]  C   Agrupamento do campo
	NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
	NIL																	,;	// [15]  C   Inicializador de Browse
	.T.																	,;	// [16]  L   Indica se o campo é virtual
	NIL																	,;	// [17]  C   Picture Variavel
	.F.																	)	// [18]  L   Indica pulo de linha após o campo

	oStruDLE:AddField(													;
	"DLE_TIPVEI"		     											,;	// [01]  C   Nome do Campo
	cValToChar(Len(oStruDLE:aFields)+1)									,;	// [02]  C   Ordem
	STR0059																,;	// [03]  C   Titulo do campo		//STR0059- 'Tipo Veículo Meta'
	STR0059																,;	// [04]  C   Descricao do campo		//STR0059- 'Tipo Veículo Meta'
	{STR0060}															,;	// [05]  A   Array com Help			//STR0060- 'Tipo de Veículo da Meta.'
	"C"																	,;	// [06]  C   Tipo do campo
	"@!"																,;	// [07]  C   Picture
	bPictVar															,;	// [08]  B   Bloco de Picture Var
	"DLE2"																,;	// [09]  C   Consulta F3
	.T.																	,;	// [10]  L   Indica se o campo é alteravel
	NIL																	,;	// [11]  C   Pasta do campo
	NIL																	,;	// [12]  C   Agrupamento do campo
	NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
	NIL																	,;	// [15]  C   Inicializador de Browse
	.T.																	,;	// [16]  L   Indica se o campo é virtual
	NIL																	,;	// [17]  C   Picture Variavel
	.T.																	)	// [18]  L   Indica pulo de linha após o campo

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_DL7', oStruDL7, 'MASTER_DL7' )	
	
	oStruDLE:SetProperty( 'DLE_SEQ', MVC_VIEW_CANCHANGE, .F. ) 
	oStrDLM:SetProperty( 'DLM_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	oStrDLN:SetProperty( 'DLN_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	
	//remove o campo da grid desejada
	oStruDLE:RemoveField( 'DLE_CRTDMD' ) 
	
	oStrDLM:RemoveField( 'DLM_CRTDMD' )
	oStrDLM:RemoveField( 'DLM_CODGRD' )
	
	oStrDLN:RemoveField( 'DLN_CRTDMD' )		
	oStrDLN:RemoveField( 'DLN_CODGRD' )
			
	oView:CreateHorizontalBox('BOX_FORM',42)
	oView:CreateHorizontalBox('BOX_MID',29)
	oView:CreateHorizontalBox('BOX_DOWN',29)
	
	oView:CreateVerticalBox('BOX_ORI',50,'BOX_DOWN')	
	oView:CreateVerticalBox('BOX_DES',50,'BOX_DOWN')	

	oView:AddGrid('GRID_DLE', oStruDLE, 'GRID_DLE')
	oView:AddGrid('GRID_ORI', oStrDLM, 'GRID_ORI')
	oView:AddGrid('GRID_DES', oStrDLN, 'GRID_DES')
	
	oView:AddIncrementField( 'GRID_DLE', 'DLE_SEQ' )
	oView:AddIncrementField( 'GRID_ORI', 'DLM_SEQREG' )
	oView:AddIncrementField( 'GRID_DES', 'DLN_SEQREG' )
	
	oView:EnableTitleView('GRID_DLE', STR0012) //Grupo de Regiões da Demanda
	oView:EnableTitleView('GRID_ORI', STR0013) //Região Origem 
	oView:EnableTitleView('GRID_DES', STR0014) //Região Destino
	
	oView:SetOwnerView( 'VIEW_DL7', 'BOX_FORM')
	oView:SetOwnerView( 'GRID_DLE', 'BOX_MID')
	oView:SetOwnerView( 'GRID_ORI', 'BOX_ORI')
	oView:SetOwnerView( 'GRID_DES', 'BOX_DES')
	
	oView:SetViewProperty( 'GRID_DLE', "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )
	
	oView:SetAfterViewActivate({|oView| AfterVwAct(oView) })

Return oView
                                                                                           
//------------------------------------------------------------------------
/*/{Protheus.doc} T153C_DATA()
Valida se data informada é inferior a data atual
Função utilizada no dicionário - valid dos campos DL7_INIVIG e DL7_FIMVIG
@author  author
@since   date
@version version
/*/
//------------------------------------------------------------------------
Function T153C_DATA()
	Local lRet := .T.

	If !Empty(M->DL7_FIMVIG) .AND. !Empty(M->DL7_INIVIG)
		If M->DL7_FIMVIG < M->DL7_INIVIG                                                                                                                                                                                                       
			Help( ,1, 'TMSA153C4',, '', 1, 0 )	//"Data de fim de vigência não pode ser anterior ao início da vigência do Contrato de Demandas."
			lRet := .F.
		EndIf
		If lRet
			lRet:= TMA153CVLD()
		EndIf
	Endif
 Return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} T153DL7UM()
Gatilho do campo DL7_UM para apagar dados das quantidades de acordo com o tipo de unidade informado.
@author  Marlon Augusto Heiber
@since   11/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153DL7UM(oModel)
Local oModelAux := oModel:GetModel('MASTER_DL7')
Local oModelDLM	:= oModelAux:GetModel('GRID_ORI')
Local oModelDLE	:= oModelAux:GetModel('GRID_DLE')
Local nX 		:= 0
Local nY		:= 0
Local oView 	:= FwViewActive()
	
	If M->DL7_UM == "1" //Peso
		For nX := 1 To oModelDLE:GetQtdLine()
			oModelDLE:GoLine(nX)
			If oModelDLE:GetValue("DLE_QTD", nX) > 0 
				oModelDLE:LoadValue("DLE_QTD", 0)
				oModelDLE:ClearField("DLE_QTD", nX)
			EndIf
		Next nX
	Else
		For nX := 1 To oModelDLE:GetQtdLine()
			oModelDLE:GoLine(nX)
			If oModelDLE:GetValue("DLE_QTD", nX) > 0 
				oModelDLE:LoadValue("DLE_QTD", 0)
				oModelDLE:ClearField("DLE_QTD", nX)
			EndIf
			For nY := 1 to oModelDLM:GetQtdLine()
				oModelDLM:GoLine(nY)
				//A validação de > 0 serve para que a carga automática de regiões ao informar o grupo apague corretamente a primeira linha (senão marca apenas como deletada)
				If oModelDLM:GetValue("DLM_QTD", nY) > 0 
					oModelDLM:LoadValue("DLM_QTD", 0)
					oModelDLM:ClearField("DLM_QTD", nY)
				EndIf
			Next nY
			oModelDLM:GoLine(1)
		Next nX
	EndIf
	
	oModel:LoadValue("DL7_QTDTOT",0)
	
	oModel:LoadValue("DL7_QTDSLD",TMCalcQtd("SALDO", 0, 1))
	oModel:LoadValue("DL7_QTDDEX",TMCalcQtd("EXTRA", 0, 1))

	oModelDLE:GoLine(1)
	
	If !IsBlind()
		oView:Refresh('GRID_DLE')
		oView:Refresh('GRID_ORI')	
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T153LnPreOri()
Função de pré-validação do submodelo, é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.
@author  Marlon Augusto Heiber
@since   10/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153LnPreOri (oModelGrid, nLine, cOpera, cCampo, nVal) 
Local lRet       := .T.
Local oModelDLE  := oModelGrid:GetModel( 'GRID_DLE' )
Local nOperation := oModelGrid:GetOperation()
Local nQtdTotDLM := 0
Local nX         := 0
Local nLintemp   := oModelGrid:GetLine()
Local bWhen      := Nil
Local cDL7UM     := oModelGrid:GetModel('MASTER_DL7'):GetModel('MASTER_DL7'):GetValue('DL7_UM')
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE	
		If cOpera == "SETVALUE"	.And. cCampo == 'DLM_QTD' .And. cDL7UM == '1'
			//Somatório das quantidades das Regiões, para repasse aos Grupos de Regiões
			For nX := 1 to oModelGrid:GetQtdLine()
				If !oModelGrid:IsDeleted(nX)  
					If nLine == nX  //Como a função é chamada na pré validação, o valor do campo é o passado por parâmetro
						nQtdTotDLM += nVal
					Else
						nQtdTotDLM += oModelGrid:GetValue("DLM_QTD", nX) 
					EndIf
				EndIf
			Next nX

			If nQtdTotDLM >= 0  

				//Atualização da Quantidade do Grupo de Regiões					
				bWhen := oModelDLE:GetModel('GRID_DLE'):GetStruct():GetProperty("DLE_QTD", MODEL_FIELD_WHEN)
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN,{||.T.})
				If !oModelDLE:SetValue("GRID_DLE","DLE_QTD",nQtdTotDLM)
					lRet:= .F.
				Endif
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN, bWhen)
				
			EndIf
			
			oModelGrid:GoLine(nLintemp)  //Retorna para a linha que estava posicionado
		ElseIf  cOpera == "DELETE" 	
			If cDL7UM == '1'
				nQtdTotDLM := oModelDLE:GetValue("GRID_DLE","DLE_QTD") - oModelGrid:GetValue("DLM_QTD")
				bWhen := oModelDLE:GetModel('GRID_DLE'):GetStruct():GetProperty("DLE_QTD", MODEL_FIELD_WHEN)
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN,{||.T.})
				If !oModelDLE:SetValue("GRID_DLE","DLE_QTD",nQtdTotDLM)
					lRet:= .F.
				Endif
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN, bWhen)
			EndIf

		ElseIf cOpera == "UNDELETE"
						
			If oModelDLE:GetModel('GRID_DLE'):IsDeleted() 					
				If !lUndelDLE
					lRet := .F.						
					Help( ,, 'HELP',, STR0015, 1, 0,,,,,, {STR0016} ) //"Não é possível desfazer a exclusão de regiões de grupos de regiões excluídos." / "Desfaça a exclusão do grupo de regiões para ter acesso às regiões."
				EndIf
			EndIF
			If cDL7UM == '1' .AND. lRet
				nQtdTotDLM := oModelDLE:GetValue("GRID_DLE","DLE_QTD") + oModelGrid:GetValue("DLM_QTD")
					
				bWhen := oModelDLE:GetModel('GRID_DLE'):GetStruct():GetProperty("DLE_QTD", MODEL_FIELD_WHEN)
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN,{||.T.})
				If !oModelDLE:SetValue("GRID_DLE","DLE_QTD",nQtdTotDLM)
					If !oModelDLE:LoadValue("GRID_DLE","DLE_QTD",nQtdTotDLM)
						lRet := .F.
					EndIF	
				Endif
				oModelDLE:GetModel('GRID_DLE'):GetStruct():SetProperty("DLE_QTD", MODEL_FIELD_WHEN, bWhen)
			EndIf
		EndIf
	EndIf

Return lRet                  

//-------------------------------------------------------------------
/*/{Protheus.doc} T153LnPreDes()
Função de pré-validação do submodelo, é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.
@author  Wander Horongoso
@since   14/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153LnPreDes (oModelGrid, nLine, cOpera, cCampo, nVal) 
Local lRet       := .T.
Local oModelDLE  := oModelGrid:GetModel( 'GRID_DLE' )
Local nOperation := oModelGrid:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE	
		If cOpera == "UNDELETE"
			If oModelDLE:GetModel('GRID_DLE'):IsDeleted() 					
				If !lUndelDLE
					lRet := .F.						
					Help( ,, 'HELP',, STR0015, 1, 0,,,,,, {STR0016} ) //"Não é possível desfazer a exclusão de regiões de grupos de regiões excluídos." / "Desfaça a exclusão do grupo de regiões para ter acesso às regiões."
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} T153PreCrt()
Função de pré-validação do submodelo, é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.
@author  Wander Horongoso
@since   14/06/2018
@version 12.1.17
/*/
Function T153PreCrt (oModel) 
Local lRet       := .T.
Local oModelDLE  := oModel:GetModel( 'GRID_DLE' )
Local oModelDL7  := oModel:GetModel('MASTER_DL7')
Local nOperation := oModel:GetOperation()
Local ln1DL7     := .F. //Se é o primeiro momento que ele está alterando o tipo de veículo, recebe .T.
Local ln1DLE     := .F. //Se é o primeiro momento que ele está alterando o tipo de veículo, recebe .T.
Local aAreaDLF   := DLF->(GetArea("DLF"))

DLF->(DbSetOrder(1))

If nOperation <> MODEL_OPERATION_INSERT .OR. oModel:isCopy()
	if oModel:isCopy()
		oModelDL7:LoadValue("DL7_QTDSLD",0) //zera o saldo quando é em copia.
		oModelDL7:LoadValue("DL7_QTDDEX",0) //zera o extra quando é em copia.
	EndIF
	If DLF->(DbSeek(xFilial('DLF') + DL7->DL7_COD))
		While DLF->(!EoF()) .OR. DL7->DL7_COD == DLF->DLF_CRTDMD
			If (DL7->DL7_COD == DLF->DLF_CRTDMD .AND. Empty(DLF->DLF_CODGRD))
				IF aScan(aDbTipVei1, DLF->DLF_TIPVEI) <= 0
					AAdd(aDbTipVei1, DLF->DLF_TIPVEI)
                    ln1DL7 := .T.
                EndIf
            ElseIf (DLE->DLE_CRTDMD == DLF->DLF_CRTDMD)
            	IF aScan(aDbTipVei2, {|x| x[1]+x[2] == AllTrim(DLF->DLF_CODGRD) + AllTrim(DLF->DLF_TIPVEI)  }) <= 0
            		AAdd(aDbTipVei2, {AllTrim(DLF->DLF_CODGRD), AllTrim(DLF->DLF_TIPVEI)})
                    ln1DLE := .T.
                EndIf
            EndIf
            DLF->(DbSkip())
        EndDo
		If ln1DL7
			aTipVeiDL7 := AClone(aDbTipVei1)
		EndIf
		If ln1DLE
			aTipVeiDLE := AClone(aDbTipVei2)
		EndIf
	EndIf
EndIf

RestArea(aAreaDLF)	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153PreReg()
Função de pré-validação do submodelo, é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.
@author  Wander Horongoso
@since   14/06/2018
@version 12.1.17
/*/
Function T153PreReg (oModelGrid, nLine, cOpera, cCampo, cGrid) 
	Local oModelAux := oModelGrid:GetModel()
	Local oModelDLE := oModelAux:GetModel('GRID_DLE')
	Local oModelDL7 := oModelAux:GetModel('MASTER_DL7')
		
	Local nOperation := oModelGrid:GetOperation()
	
	Local cCodReg := ''
	
	Local aAreaDLG := DLG->(GetArea("DLG"))
	
	Local lRet := .T.

	If cGrid == "1"
		cCodReg    := oModelGrid:GetValue('DLM_CODREG') 
	ElseIf cGrid == "2"
		cCodReg    := oModelGrid:GetValue('DLN_CODREG') 
	EndIf

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE	 
		If(cOpera == "CANSETVALUE" .OR. cOpera == "DELETE" .OR. cOpera == 'ADDLINE') .AND. !oModelDLE:IsInserted()
			If lRet .AND. !(oModelGrid:IsDeleted()) .AND. oModelDL7:GetValue('DL7_META') == '1'
				DLG->(DbSetOrder(1))
				If DLG->(DbSeek(xFilial("DLG") + oModelDL7:GetValue('DL7_COD') + (oModelDLE:GetValue('DLE_CODGRD')))) .AND. (FunName() == "TMSA153")
					Help( ,, 'HELP',, STR0051, 1, 0,,,,,,) //"Não é possível Incluir/Alterar/Excluir região caso o grupo de regiões tenha meta cadastrada"
					lRet := .F.                                                                                                                                                                                                                                                                                                                                                                                                                       
				EndIf
			EndIf
			If  lRet .AND. cOpera == "DELETE"  .AND. (FunName() == "TMSA153")
				If VldRegDmd(oModelDL7:GetValue('DL7_COD'), oModelDLE:GetValue("DLE_CODGRD"), cCodReg  )
					Help( ,, 'HELP',,STR0052, 1, 0,,,,,,) //"Não é possível excluir região com demanda vinculada ao contrato que utiliza esta Região."                                                                                                                                                                                                                                                                                                                                                                                                                          
					lRet := .F.
				endif							
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaDLG)	
	
	Iif(!(FunName() == "TMSA153") .AND. cGrid = "2",SetFunName("TMSA153"),)
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldRegDmd
Valida a utilização da Região de Origem do Contrato em alguma Demanda vinculada ao mesmo Contrato.
@type Function
@author André Luiz Custódio
@version 12.1.17
@since 31/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function VldRegDmd(cCrtDmd, cCodGrpReg, cCodReg)
	Local lRet      := .F.
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ''

	cQuery += " SELECT DISTINCT '1' EXISTE "
	cQuery += "   FROM " + RetSqlName('DLA') + " DLA, "
	cQuery += "        " + RetSqlName('DL8') + " DL8  "
	cQuery += "  WHERE DLA.DLA_FILIAL = '" + xFilial("DLA") + "'"
	cQuery += "    AND DLA.DLA_CODREG = '"+cCodReg+"'"
	cQuery += "    AND DLA.DLA_CODDMD = DL8.DL8_COD   "
	cQuery += "    AND DLA.DLA_PREVIS =  '1' "	
	cQuery += "    AND DLA.D_E_L_E_T_ = ' '  "
	cQuery += "    AND DL8.DL8_FILIAL = '" + xFilial("DL8") + "'"	
	cQuery += "    AND DL8.DL8_CRTDMD = '"+cCrtDmd+"'"
	cQuery += "    AND DL8.DL8_CODGRD = '"+cCodGrpReg+"' "
	cQuery += "    AND DL8.D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

	if (cAliasQry)->EXISTE = '1'
		lRet := .T.
	endif 

	(cAliasQry)->( DbCloseArea() )	

	if !lRet

	    cAliasQry := GetNextAlias()

		cQuery := " SELECT DISTINCT '1' EXISTE "
		cQuery += "   FROM " + RetSqlName('DLL') + " DLL, "
		cQuery += "        " + RetSqlName('DL8') + " DL8  "
		cQuery += "  WHERE DLL.DLL_FILIAL = '" + xFilial("DLL") + "'"
		cQuery += "    AND DLL.DLL_CODREG = '"+cCodReg+"'"
		cQuery += "    AND DLL.DLL_CODDMD = DL8.DL8_COD   "
		cQuery += "    AND DLL.DLL_PREVIS =  '1' "	
		cQuery += "    AND DLL.D_E_L_E_T_ = ' '  "
		cQuery += "    AND DL8.DL8_FILIAL = '" + xFilial("DL8") + "'"	
		cQuery += "    AND DL8.DL8_CRTDMD = '"+cCrtDmd+"'"
		cQuery += "    AND DL8.DL8_CODGRD = '"+cCodGrpReg+"' "
		cQuery += "    AND DL8.D_E_L_E_T_ = ' '  "
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

		if (cAliasQry)->EXISTE = '1'
			lRet := .T.
		endif 

		(cAliasQry)->( DbCloseArea() )	

	endif

Return lRet
                
//-------------------------------------------------------------------
/*/{Protheus.doc} T153PosCrt
Realiza a validação tudo OK após clicar em confirmar.
@author  Wander Horongoso	
@since   31/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153PosCrt(oModel)
Local lRet		:= .T.
Local lGrpReg 	:= .F.
Local oModelDLE := oModel:GetModel('GRID_DLE')
Local nOperation:= oModel:GetOperation()
Local nX		:= 0
Local aAreaDLG  := DLG->(GetArea("DLG"))
Local cContradoD:= DL7->DL7_COD

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		For nX := 1 to oModelDLE:GetQtdLine()
			oModelDLE:GoLine(nX)
			If !oModelDLE:IsDeleted(nX) .AND. !Empty(oModelDLE:GetValue("DLE_CODGRD"))
				lGrpReg := .T.//Encontrada uma linha não deletada com a grupo de regiao informado	
				Exit		
			Endif
		Next nX
		
		If !lGrpReg 
			FwClearHLP() 
			oModel:SetErrorMessage (,,,,,STR0018) //Nenhum grupo de regiões de demanda informado.
			lRet := .F.
		Endif

		If lRet .AND. !TMA153CVLD()
			lRet := .F.
		EndIf
	Endif
	
	If lRet .AND. nOperation == MODEL_OPERATION_DELETE
		DLG->(DbSetOrder(1))
		DLG->(DbGoTop())
		If DLG->(DbSeek(xFilial('DLG') + cContradoD))
			While DLG->(!EoF()) .AND. DLG->DLG_CODCRT == cContradoD
				RecLock('DLG',.F.)
				DLG->(DBDelete())
				MsUnlock('DLG')	
				DLG->(DbSkip())
			EndDo
		EndIf
	EndIf
	
	RestArea(aAreaDLG)	
	
Return lRet
  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} T153GrvCrt
Realiza a gravação dos registros.
@author  Marlon Augusto Heiber	
@since   08/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153GrvCrt(oModel)
Local lRet		 := .T.
Local nOperation := oModel:GetOperation()
Local nX		 := 0
Local nPos  	 := 0
Local nSize 	 := 0
Local nSpaceGRD  := 0
Local oModelDL7  := oModel:GetModel('MASTER_DL7')
Local oModelDLE  := oModel:GetModel('GRID_DLE')
Local aUpdDL7	 := {}	
Local aDelDL7	 := {}
Local aUpdDLE	 := {}	
Local aDelDLE	 := {}
Local aDLENotDel := {}
Local aAreaDLG   := DLG->(GetArea("DLG"))

	//Efetua a gravação dos registros no banco
	Begin Transaction
		If lRet
			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				If __lSX8
					ConfirmSX8()
				EndIf			
			EndIf
			
			If oModel:GetOperation() == MODEL_OPERATION_DELETE 
				TmIncTrk('1', DL7->DL7_FILIAL, DL7->DL7_COD, , , 'X', , )//Tracking da Exclusão de Contrato de Demanda
			EndIf
			
			lRet := FwFormCommit(oModel)
			
			If oModel:GetValue('MASTER_DL7','DL7_META') == '2' .And. lRet
				TM153CMeta(oModel)			
			EndIf
			
			If lRet .AND. oModel:GetOperation() == MODEL_OPERATION_INSERT
				TmIncTrk('1', DL7->DL7_FILIAL, DL7->DL7_COD, , , 'I', , ) //Tracking da Inclusão de Contrato de Demanda
				
				// Inclusão Tipos de veículos dos campos DL7_TIPVEI e DLE_TIPVEI na tabela DLF - Tipos de Veículos da Gestão de Demandas
				//Grava registros do campo DL7_TIPVEI
				If !Empty(aTipVeiDL7)
					For nX := 1 To Len(aTipVeiDL7)
						If nOperation == MODEL_OPERATION_INSERT
							RecLock('DLF',.T.)
							DLF->DLF_FILIAL := oModelDL7:GetValue('DL7_FILIAL')
							DLF->DLF_CRTDMD := oModelDL7:GetValue('DL7_COD')
							DLF->DLF_TIPVEI := AllTrim(aTipVeiDL7[nX]) 
							MsUnlock()
						EndIf
					Next nX
					//Limpa variáveis private
					aTipVeiDL7 := {}
					aDbTipVei1 := {} 
				EndIf

				DbSelectArea('DLC')
				DLC->(DbSetOrder(1))
				DLC->(dbGoTop())
				While DLC->(!Eof())
					//Grava registros do campo DLE_TIPVEI
					If !Empty(aTipVeiDLE)
						For nX := 1 To Len(aTipVeiDLE)
							If aTipVeiDLE[nX][1] == AllTrim(DLC->DLC_COD)
								If nOperation == MODEL_OPERATION_INSERT
									RecLock('DLF',.T.)
									DLF->DLF_FILIAL := oModelDL7:GetValue('DL7_FILIAL')
									DLF->DLF_CRTDMD := oModelDL7:GetValue('DL7_COD')
									DLF->DLF_CODGRD := AllTrim(aTipVeiDLE[nX][1]) 
									DLF->DLF_TIPVEI := AllTrim(aTipVeiDLE[nX][2])
									MsUnlock()
								EndIf
							EndIf
						Next nX
					EndIf
					DLC->(DBSkip())
				EndDo
				DLC->(DbCloseArea())
				//Limpa variáveis private
				aTipVeiDLE := {}
				aDbTipVei2 := {}
			EndIf

			// Alterar Tipos de veículos dos campos DL7_TIPVEI e DLE_TIPVEI na tabela DLF - Tipos de Veículos da Gestão de Demandas
			If lRet .AND. oModel:GetOperation() == MODEL_OPERATION_UPDATE
				DbSelectArea('DLF')
				DLF->(DbSetOrder(1))

				//Grava registros não deletados para o caso de um registro ser deletado e reinserido em outra linha do grid
				For nX := 1 to oModelDLE:GetQtdLine()
					oModelDLE:GoLine(nX)
					If !oModelDLE:IsDeleted(nX)
						AADD(aDLENotDel, AllTrim(oModelDLE:GetValue('DLE_CODGRD')))
					Endif
				Next nX

				//Remove do array registros deletados do grid Grupo de Regiões 
				For nX := 1 to oModelDLE:GetQtdLine()
					oModelDLE:GoLine(nX)
					If oModelDLE:IsDeleted(nX) .AND. aScan(aDLENotDel, AllTrim(oModelDLE:GetValue('DLE_CODGRD'))) <= 0
						nPos := aScan(aTipVeiDLE, {|x| x[1] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) })
						While nPos > 0
							If nPos > 0
								ADel(aTipVeiDLE,nPos)
								nSize := (Len(aTipVeiDLE) - 1)
								ASize(aTipVeiDLE,nSize)
								nPos := aScan(aTipVeiDLE, {|x| x[1] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) })
							Else 
								Exit
							EndIf
						EndDo
					Endif
				Next nX

				//Contrato de Demandas (Tabela DL7)//
				//O que foi adicionado ao alterar	
				For nX := 1 To Len(aTipVeiDL7)
					If  !Empty(aTipVeiDL7[nX]) .AND. !aScan(aDbTipVei1, aTipVeiDL7[nX]) > 0
						AAdd(aUpdDL7, aTipVeiDL7[nX])
					EndIf
				Next nX
				
				//O que foi removido ao alterar	
				If !Empty(aTipVeiDL7)		
					For nX := 1 To Len(aDbTipVei1)
						If !aScan(aTipVeiDL7, aDbTipVei1[nX]) > 0
							AAdd(aDelDL7, aDbTipVei1[nX])
						EndIf
					Next nX
				Else
					aDelDL7 := aClone(aDbTipVei1)
				EndIf

				//Grava registros inseridos ao alterar
				If !Empty(aUpdDL7)
					For nX := 1 To Len(aUpdDL7)				
						RecLock('DLF',.T.)
						DLF->DLF_FILIAL := oModelDL7:GetValue('DL7_FILIAL')
						DLF->DLF_CRTDMD := oModelDL7:GetValue('DL7_COD')
						DLF->DLF_TIPVEI := AllTrim(aUpdDL7[nX]) 
						MsUnlock()
					Next nX
				EndIf

				//Deleta registros inseridos ao alterar
				If !Empty(aDelDL7)
					For nX := 1 To Len(aDelDL7)				
						If DLF->(MsSeek(xFilial('DLF') + oModelDL7:GetValue('DL7_COD') + Space(Len(DLF_CODGRD)) + aDelDL7[nX]))
							RecLock('DLF',.F.)
							DLF->(DBDelete())
							MsUnlock()
						EndIf
					Next nX
				EndIf

				//Limpa variáveis private
				aDbTipVei1 := {}
				aTipVeiDL7 := {}
				aUpdDL7    := {}
				aDelDL7    := {}

				//Grupo de Regiões de Demanda (Tabela DLE)//
				//O que foi inserido ao alterar
				For nX := 1 To Len(aTipVeiDLE)
					If aScan(aDbTipVei2, {|x| x[1] + x[2] == (aTipVeiDLE[nX][1] + aTipVeiDLE[nX][2])}) <= 0
						AAdd(aUpdDLE, {aTipVeiDLE[nX][1], aTipVeiDLE[nX][2]} )
					EndIf
				Next nX

				//O que foi removido ao alterar
				If !Empty(aTipVeiDLE)
					For nX := 1 To Len(aDbTipVei2)
						If aScan(aTipVeiDLE, {|x| x[1]+x[2] == aDbTipVei2[nx][1] + aDbTipVei2[nx][2]  }) <= 0
							AAdd(aDelDLE, {aDbTipVei2[nX][1], aDbTipVei2[nX][2] }) 
						EndIf
					Next nX
				Else
					aDelDLE := aClone(aDbTipVei2)
				EndIf
				
				//Grava registros inseridos ao alterar
				If !Empty(aUpdDLE)
					For nX := 1 To Len(aUpdDLE)				
						RecLock('DLF',.T.)
						DLF->DLF_FILIAL := oModelDL7:GetValue('DL7_FILIAL')
						DLF->DLF_CRTDMD := oModelDL7:GetValue('DL7_COD')
						DLF->DLF_CODGRD := AllTrim(aUpdDLE[nX][1])
						DLF->DLF_TIPVEI := AllTrim(aUpdDLE[nX][2]) 
						MsUnlock()
					Next nX
				EndIf

				//Deleta registros inseridos ao alterar
				If !Empty(aDelDLE)
					For nX := 1 To Len(aDelDLE)		
						nSpaceGRD := (Len(oModelDLE:GetValue('DLE_CODGRD')) - Len(aDelDLE[nX][1]))
						If DLF->(MsSeek(xFilial('DLF') + oModelDL7:GetValue('DL7_COD') + (aDelDLE[nX][1] + Space(nSpaceGRD)) + aDelDLE[nX][2]))
							RecLock('DLF',.F.)
							DLf->(DBDelete())
							MsUnlock()
						EndIf
					Next nX
				EndIf

				// Limpa variáveis private
				aDbTipVei2 := {}
				aTipVeiDLE := {}
				aUpdDLE    := {}
				aDelDLE    := {}
			EndIf
			// Excluir Tipos de veículos dos campos DL7_TIPVEI e DLE_TIPVEI na tabela DLF - Tipos de Veículos da Gestão de Demandas
			If lRet .AND. oModel:GetOperation() == MODEL_OPERATION_DELETE
				If DLF->(DbSeek(xFilial('DLF') + oModelDL7:GetValue('DL7_COD')))
					While DLF->(!EoF()) .AND. DLF->DLF_CRTDMD == oModelDL7:GetValue('DL7_COD')
						RecLock('DLF',.F.)
						DLF->(DBDelete())
						MsUnlock()
						DLF->(DbSkip())
					EndDo
				EndIf
				//Limpa variáveis private
				aTipVeiDL7 := {}
				aTipVeiDLE := {}
				aDbTipVei1 := {}
				aDbTipVei2 := {}
			EndIf
			
			If oModelDL7:GetValue('DL7_META') == '1'
				If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 
					DLG->(DbSetOrder(1))
					DLG->(DbGoTop())
					For nX:= 1 to oModelDLE:Length()
						oModelDLE:SetLine(nX)
						If oModelDLE:IsDeleted() .AND.  !oModelDLE:IsInserted()
							If DLG->(DbSeek(xFilial('DLG') + oModelDL7:GetValue('DL7_COD') + oModelDLE:GetValue('DLE_CODGRD')))
								While DLG->(!EoF()) .AND. DLG->DLG_CODCRT == oModelDL7:GetValue('DL7_COD') .AND. DLG->DLG_CODGRD == oModelDLE:GetValue('DLE_CODGRD')
									RecLock('DLG',.F.)
									DLG->(DBDelete())
									MsUnlock('DLG')
									DLG->(DbSkip())
								EndDo
							EndIf
						EndIf
					Next nX
				EndIf
			EndIF	
			If !lRet
				VarInfo("",oModel:GetErrorMessage())
				DisarmTransaction()
				lRet := .F.
				Break
			EndIf				
		EndIf
	End Transaction
	
	RestArea(aAreaDLG)	
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} T153LnPGRD
Realiza a validação da linha do grupo de região de demanda
@author  Wander Horongoso	
@since   31/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153LnPGRD(oModel)
Local lRet		 := .T.
Local lRegiao 	 := .F.
Local oModelDLM  := oModel:GetModel('GRID_DLE'):GetModel('GRID_ORI')
Local nOperation := oModel:GetOperation()
Local nX		 := 0

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		For nX := 1 to oModelDLM:GetQtdLine()
			oModelDLM:GoLine(nX)
			If !oModelDLM:IsDeleted(nX) .AND. !Empty(oModelDLM:GetValue("DLM_CODREG"))
				lRegiao := .T.//Encontrada uma linha não deletada com a regiao de origem informada	
				Exit		
			Endif
		Next nX

		If !lRegiao 
			Help( ,, 'HELP',, STR0019, 1, 0 ) //"Nenhuma região origem informada para o grupo de regiões de demanda."
			lRet := .F.
		Endif
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153SUSP()
Efetua suspensão do contrato
@author  Gustavo Baptista
@since   26/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153SUSP()

	Local cTemp:= GetNextAlias()
	Local nCont:= 0
	Local cQuery:=''
	Local oModelDL7
	Local lYesNo := .T.
	Local lBlind := IsBlind()

	Default aJustif:= {}
	
	If DL7->DL7_STATUS <> '1' //O Contrato de Demandas não pode estar suspenso ou encerrado. 

		Help( ,, 'HELP',, STR0022 , 1, 0 ) //"Não é possível suspender um contrato que não está ativo."

	Else
	
		cQuery := " SELECT COUNT(DL8_COD) Contador "
		cQuery += " FROM " + RetSqlName('DL8') + " DL8 "
		cQuery += " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery += " AND DL8.DL8_CRTDMD = '" + DL7->DL7_COD + "'"
		cQuery += " AND DL8.DL8_STATUS = '1' "
		cQuery += " AND DL8.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
		nCont:= (cTemp)->Contador
		
		(cTemp)->(DBCLOSEAREA())
		
		If nCont > 0 //Não pode existir demanda em aberto (Demanda sem Planejamento de Demanda)
			Help( ,, 'HELP',, STR0023, 1, 0 )//"Não é possível suspender um contrato que possui demandas sem planejamento."
		Else 
			If !lBlind
				lYesNo := MSGYESNO(STR0024,STR0025)//"Deseja realmente suspender o contrato? " "Confirmação"
			EndIf
			If lYesNo
				If !lBlind
					aJustif:= TMSMotDmd() //chamar tela de justificativa
				EndIf
				If Len(aJustif) > 0
					TmIncTrk('1', DL7->DL7_FILIAL, DL7->DL7_COD, '', , 'S', aJustif[1], aJustif[2])
					oModelDL7 := FWLoadModel('TMSA153C')
					oModelDL7:SetOperation(MODEL_OPERATION_UPDATE)
					oModelDL7:Activate()
					oModelDL7:SetValue("MASTER_DL7","DL7_STATUS",'2')	
					If oModelDL7:VldData()        
						oModelDL7:CommitData()  
						MsgInfo(STR0026) //"Contrato foi suspenso."
					Else
						VarInfo("",oModelDL7:GetErrorMessage()) 
					EndIf 
					oModelDL7:DeActivate()
				Endif
			Endif
		Endif
	Endif
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} T153RETM()
Efetua retomada do contrato
@author  Gustavo Baptista
@since   26/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153RETM()
Local oModelDL7
Local lYesNo := .T.
	
	if DL7->DL7_STATUS <> '2' //O Contrato de Demandas só pode estar suspenso.

		Help( ,, 'HELP',, STR0027 , 1, 0 ) //"Não é possível retomar um contrato que não está suspenso."

	else
			If !IsBlind()
				lYesNo := MSGYESNO(STR0028,STR0025)//"Deseja realmente RETOMAR o contrato? " "Confirmação"
			EndIf
			If lYesNo
				If !IsBlind()
					aJustif:= TMSMotDmd() //chamar tela de justificativa
				EndIf
				if Len(aJustif) > 0
					TmIncTrk('1', DL7->DL7_FILIAL, DL7->DL7_COD, '', , 'R', aJustif[1], aJustif[2])
					
					oModelDL7 := FWLoadModel('TMSA153C')
					oModelDL7:SetOperation(MODEL_OPERATION_UPDATE)
					oModelDL7:Activate()
					oModelDL7:SetValue("MASTER_DL7","DL7_STATUS",'1')	
					If oModelDL7:VldData()        
						oModelDL7:CommitData()  
				
						MsgInfo(STR0029) //"Contrato foi retomado."
			
					Else
						VarInfo("",oModelDL7:GetErrorMessage())  
					EndIf 
				oModelDL7:DeActivate()
			endif
		endif
	endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T153ENCE()
Efetua encerramento do contrato
@author  Gustavo Baptista
@since   26/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function T153ENCE()

	Local cTemp:= GetNextAlias()
	Local nCont:= 0
	Local cQuery:=''
	Local oModelDL7
	Local lYesNo := .T.

	Default aJustif:= {} 
	
	if DL7->DL7_STATUS == '3' //O Contrato de Demandas não pode estar encerrado.

		Help( ,, 'HELP',, STR0030, 1, 0 ) //"Não é possível encerrar um contrato que já está encerrado."

	else
	
		cQuery := " SELECT COUNT(DL8_COD) Contador "
		cQuery += " FROM " + RetSqlName('DL8') + " DL8 "
		cQuery += " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery += " AND DL8.DL8_CRTDMD = '" + DL7->DL7_COD + "'"
		cQuery += " AND DL8.DL8_PLNDMD = ' ' "
		cQuery += " AND DL8.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
		nCont:= (cTemp)->Contador
		
		(cTemp)->(DBCLOSEAREA())
		
		If nCont > 0 //Não pode existir demanda em aberto (Demanda sem Planejamento de Demanda)
			Help( ,, 'HELP',, STR0031, 1, 0 )//"Não é possível encerrar um contrato que possui demandas sem planejamento."
		Else 
			If !IsBlind()
				lYesNo := MSGYESNO(STR0032,STR0025)//"Deseja realmente encerrar o contrato? " "Confirmação"
			EndIf
			If lYesNo
				If !IsBlind()
					aJustif:= TMSMotDmd() //chamar tela de justificativa
				EndIf
				If Len(aJustif) > 0
					TmIncTrk('1', DL7->DL7_FILIAL, DL7->DL7_COD, '', , 'E', aJustif[1], aJustif[2])
					
					oModelDL7 := FWLoadModel('TMSA153C')
					oModelDL7:SetOperation(MODEL_OPERATION_UPDATE)
					oModelDL7:Activate()
					oModelDL7:SetValue("MASTER_DL7","DL7_STATUS",'3')	
					If oModelDL7:VldData()        
						oModelDL7:CommitData()  
						
						MsgInfo(STR0033)//"Contrato foi encerrado."
			
					Else
						VarInfo("",oModelDL7:GetErrorMessage())  
					EndIf 
					oModelDL7:DeActivate()
				EndIf 
			
			EndIf 
		
		EndIf 
		
	EndIf 

Return


/*/{Protheus.doc} TMA153CVLD
//Valida os intervalos de datas de vigência
@author gustavo.baptista
@since 09/05/2018
@version 1.0
@return ${return}, ${true or false}

@type function
/*/
Function TMA153CVLD()
Local cQuery := ''
Local cAliasQry := GetNextAlias()	
Local lRet := .T.
Local cCod := ''
Local dIniVig := nil
Local dFimVig := nil

Local cMsgMeta := ''
Local nCntGRD := 0
Local nTotal := 0
Local cCodGRD1 := ''
Local cCodGRD2 := ''

	If !Empty(M->DL7_FIMVIG) .AND. !Empty(M->DL7_INIVIG) .AND. !Empty(M->DL7_ABRANG) .and. !Empty(M->DL7_TIPCTR) .and. !Empty(M->DL7_CLIDEV) .and. !Empty(M->DL7_LOJDEV)
		If INCLUI .Or. ALTERA
			//verificar se existe um contrato ativo para o mesmo cliente/ tipo de contrato e no mesmo período
			cQuery:= " select DL7_COD, DL7_INIVIG, DL7_FIMVIG, DL7_STATUS from " + RetSqlName('DL7')+ " DL7 "
			cQuery+= " where DL7.DL7_FILIAL = '" + xFilial('DL7') + "'"
			cQuery+= "   and DL7.DL7_CLIDEV = '" + M->DL7_CLIDEV  + "'"
			cQuery+= "   and DL7.DL7_LOJDEV = '" + M->DL7_LOJDEV + "'"
			cQuery+= "   and DL7.DL7_STATUS <> '3'"		
			cQuery+= "   and DL7.DL7_TIPCTR = '" + M->DL7_TIPCTR + "'"	
			cQuery+= "   and DL7.DL7_COD <> '" + M->DL7_COD + "'"
			cQuery+= " and (( '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_INIVIG) "
			cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_FIMVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_FIMVIG) " 
			cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_FIMVIG) "
			cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' >= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' <= DL7.DL7_FIMVIG)) "
			cQuery+= " and D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )

			cCod   := (cAliasQry)->DL7_COD
			dIniVig:= (cAliasQry)->DL7_INIVIG
			dFimVig:= (cAliasQry)->DL7_FIMVIG

			(cAliasQry)->(DBCLOSEAREA())

			If !Empty(cCod) // se encontrou algum registro nos intervalos, dá alerta
				Help( ,, 'HELP',, STR0034+ cCod +STR0035+ DtoC(StoD(dIniVig)) +' - '+ DtoC(StoD(dFimVig))+".", 1, 0 ) //O período de vigência do contrato atual coincidiu com contrato: 
				lRet := .F.
			Else // se não encontrou, deve verificar se a abrangência é apenas por cliente. Depois sim altera o status para ativo ( se a data for maior que hoje, senão, desabilita)
				if M->DL7_ABRANG == '2'	
					cQuery:= " select DL7_COD, DL7_INIVIG, DL7_FIMVIG, DL7_STATUS from " + RetSqlName('DL7')+ " DL7 "
					cQuery+= " where DL7.DL7_FILIAL = '" + xFilial('DL7') + "'"
					cQuery+= "   and DL7.DL7_CLIDEV = '" + M->DL7_CLIDEV  + "'"

					cQuery+= "   and DL7.DL7_ABRANG = '2'"

					cQuery+= "   and DL7.DL7_STATUS <> '3'"		
					cQuery+= "   and DL7.DL7_TIPCTR = '" + M->DL7_TIPCTR + "'"	
					cQuery+= "   and DL7.DL7_COD <> '" + M->DL7_COD + "'"
					cQuery+= " and (( '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_INIVIG) "
					cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_FIMVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_FIMVIG) " 
					cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' <= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' >= DL7.DL7_FIMVIG) "
					cQuery+= "	or (  '"+ DTOS(M->DL7_INIVIG) +"' >= DL7.DL7_INIVIG AND  '"+ DTOS(M->DL7_FIMVIG) +"' <= DL7.DL7_FIMVIG)) "
					cQuery+= " and D_E_L_E_T_ = ' ' "
					
					cQuery := ChangeQuery(cQuery)
		
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
					
					cCod   := (cAliasQry)->DL7_COD
					dIniVig:= (cAliasQry)->DL7_INIVIG
					dFimVig:= (cAliasQry)->DL7_FIMVIG
					
					(cAliasQry)->(DBCLOSEAREA())
				endif
				
				If !Empty(cCod) // se encontrou algum registro nos intervalos, dá alerta
					Help( ,, 'HELP',, STR0034+ cCod +STR0035+ DtoC(StoD(dIniVig)) +' - '+ DtoC(StoD(dFimVig))+".", 1, 0 ) //O período de vigência do contrato atual coincidiu com contrato: 
					lRet := .F.
				else
					If M->DL7_INIVIG <= dDataBase .AND. M->DL7_FIMVIG >= dDataBase
						If M->DL7_STATUS == '4'
							M->DL7_STATUS := '1'
						EndIf
					Else
						M->DL7_STATUS := '4'
					EndIf
				endif
			EndIf
			
			If lRet
				//Verificar se existe alguma meta fora da vigência do contrato.			
				cQuery := " select DLG_CODGRD, count(DLG_SEQ) TOTAL from " + RetSqlName('DLG') + " DLG "
				cQuery += " where DLG.DLG_FILIAL = '" + xFilial('DLG') + "'"
				cQuery += " and DLG.DLG_CODCRT = '" + M->DL7_COD + "'"
				cQuery += " and (DLG.DLG_DATINI < '" + DTOS(M->DL7_INIVIG) + "' or DLG.DLG_DATFIM > '" + DTOS(M->DL7_FIMVIG) + "')" 
				cQuery += " and D_E_L_E_T_ = ' ' "
				cQuery += " group by DLG.DLG_CODGRD "
				cQuery += " having count(DLG_SEQ) > 0 "
	
				cQuery := ChangeQuery(cQuery)
	
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
				
				(cAliasQry)->(DbGoTop())
				while !(cAliasQry)->(Eof())
					
					nTotal  += (cAliasQry)->TOTAL
					nCntGRD += 1
					
					If nCntGRD == 1
						cCodGRD1 := (cAliasQry)->DLG_CODGRD
					ElseIf nCntGRD == 2
						cCodGRD2 := (cAliasQry)->DLG_CODGRD
					EndIf
				
					(cAliasQry)->(dbSkip())
				EndDo
								
				If nCntGRD > 0

					cMsgMeta := STR0036 + cValToChar(nTotal)
					
					Iif (nTotal == 1, cMsgMeta += STR0037, cMsgMeta += STR0038) // meta / metas
					
					If nCntGRD == 1
						cMsgMeta += STR0039 + cCodGRD1 //do grupo de região
					Else
						cMsgMeta += STR0040 //dos grupos de região
						If nCntGRD == 2
							cMsgMeta += cCodGRD1 + STR0043 + cCodGRD2 // e  
						Else						
							cMsgMeta += cCodGRD1 + ", " + cCodGRD2 + STR0041 // e outros
						EndIf
					EndIf
					
					cMsgMeta += STR0042 // fora deste período.
					
					Help( ,, 'HELP',, cMsgMeta, 1, 0)
					lRet := .F.
				EndIf
	
				(cAliasQry)->(dbCloseArea())
			EndIf			
			
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153LnPreGRD()
Função de pós-validação do submodelo. É invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor no Grid de Grupos de Regiões somente quando o Contrato for por Peso.
@author  Aluizio Fernando Habizenreuter
@since   08/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153LnPreGRD (oModelGrid, nLine, cOpera, cCampo, nVal) 
Local oModelDL7  := oModelGrid:GetModel('MASTER_DL7')
Local oModelDLE  := oModelDL7:GetModel('GRID_DLE')
Local oModelOri  := oModelDL7:GetModel('GRID_ORI')
Local oModelDes  := oModelDL7:GetModel('GRID_DES')
Local oStruDLE   := oModelDLE:GetStruct()
Local aChgLinOri := oModelOri:GetLinesChanged()
Local aChgLinDes := oModelDes:GetLinesChanged()
Local nOperation := oModelGrid:GetOperation()
Local nQtdTotDLE := 0
Local nX         := 0
Local nLintemp   := oModelGrid:GetLine()
Local lWhen	 	 := .F.	
Local lRet       := .T.
Local oView	:= FwViewActivate()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		If cOpera == "CANSETVALUE" .And. cCampo = 'DLE_TIPVEI'
			IIF(Empty(oModelDLE:GetValue('DLE_CODGRD')) .Or. oModelDL7:GetValue('MASTER_DL7','DL7_META') == '2', lWhen := .F., lWhen := .T.)
			oStruDLE:SetProperty("DLE_TIPVEI", MODEL_FIELD_WHEN,{||lWhen})
		EndIf

		If cOpera == "SETVALUE" .And. cCampo = 'DLE_QTD'
			//Somatório das quantidades das Regiões, para repasse aos Grupos de Regiões
			For nX := 1 to oModelGrid:GetQtdLine()
				If !oModelGrid:IsDeleted(nX) 
					If nX == nLine
						nQtdTotDLE += nVal
					Else						
						nQtdTotDLE += oModelGrid:GetValue("DLE_QTD", nX)
					EndIf 
				EndIf
			Next nX

			If nQtdTotDLE >= 0
				//Atualização da Quantidade do Grupo de Regiões
				oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.T.})
				If !oModelDL7:SetValue("MASTER_DL7","DL7_QTDTOT",nQtdTotDLE)
					lRet:= .F.
				Endif
				oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.F.})
			Endif
			oModelGrid:GoLine(nLintemp)  //Retorna para a linha que estava posicionado
		ElseIf  cOpera == "DELETE" 	
			If oModelDL7:GetValue("MASTER_DL7","DL7_UM") == '2'
				nQtdTotDLE := oModelDL7:GetValue("MASTER_DL7","DL7_QTDTOT") - oModelGrid:GetValue("DLE_QTD")
				oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.T.})
				If !oModelDL7:SetValue("MASTER_DL7","DL7_QTDTOT",nQtdTotDLE)
					lRet:= .F.
				Endif
				oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.F.})
				oModelOri:DelAllLine()
			Else
				For nX := 1 to oModelOri:GetQtdLine()
					If !oModelOri:IsDeleted(nX)  
						oModelOri:SetLine(nX)
						oModelOri:DeleteLine()
					EndIf
				Next nX
			EndIF			
			
			oModelDes:DelAllLine()
			oModelOri:ALINESCHANGED := aChgLinOri
			oModelDes:ALINESCHANGED := aChgLinDes
			oModelOri:SetLine(1)
			oModelDes:SetLine(1)	
			oModelOri:SetNoInsertLine(.T.) 
			oModelDes:SetNoInsertLine(.T.) 	

		ElseIf cOpera == "UNDELETE"
			
			lUndelDLE := .T.
			
			For nX := 1 to oModelOri:GetQtdLine()
				oModelOri:SetLine(nX)
				oModelOri:UnDeleteLine()
			Next nX
					
			For nX := 1 to oModelDes:GetQtdLine()
				oModelDes:SetLine(nX)
				oModelDes:UnDeleteLine()	
			Next nX
			
			lUndelDLE := .F.
									
			oModelOri:aLinesChanged := aChgLinOri
			oModelDes:aLinesChanged := aChgLinDes
			oModelOri:SetLine(1)
			oModelDes:SetLine(1)
			oModelOri:SetNoInsertLine(.F.) 
			oModelDes:SetNoInsertLine(.F.)
			
			nQtdTotDLE := oModelDL7:GetValue("MASTER_DL7","DL7_QTDTOT") + oModelGrid:GetValue("DLE_QTD")
			oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.T.})
			If !oModelDL7:SetValue("MASTER_DL7","DL7_QTDTOT",nQtdTotDLE)
				lRet:= .F.
			Endif
			oModelDL7:GetModel('MASTER_DL7'):GetStruct():SetProperty("DL7_QTDTOT", MODEL_FIELD_WHEN,{||.F.})
			oView:Refresh('GRID_DLE') 
			oView:Refresh('GRID_ORI')		
			oView:Refresh('GRID_DES')					
		EndIf
	Endif

	If lRet
		oModelDL7:GetErrorMessage(.T.)
	EndIf	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153DLEGRD()
Gatilho do campo DLE_CODGRD para carregar as regiões a partir do último contrato criado.
@author  Wander Horogoso
@since   07/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153DLEGRD(oModel)
Local oModelDL7  := oModel:GetModel('MASTER_DL7')
Local oModelOri  := oModelDL7:GetModel('GRID_ORI')
Local oModelDes  := oModelDL7:GetModel('GRID_DES')
Local cTemp      := GetNextAlias()
Local cQuery     := ''
Local cGrid      := ''
Local lAddLn     := .F.
Local nSeq       := 0
Local nX         := 0
Local nY         := 0
Local nNewLine	 := 0
Local aArea      := DLM->(GetArea())

If !(Empty(M->DLE_CODGRD))

	//Limpa Grid de origem.
	If !(oModelOri:IsEmpty())
		oModelOri:SetNoInsertLine(.F.)
		nNewLine := oModelOri:AddLine()
		oModelOri:GoLine( nNewLine )
		oModelOri:LineShift(1,nNewLine)
		oModelOri:GoLine( nNewLine )
		For nY := oModelOri:Length()+1 To 2 Step -1 
	        oModelOri:GoLine(nY)
	        oModelOri:DeleteLine(.T.,.T.)                
	    Next    
	    oModelOri:GoLine(1)
	    oModelOri:UnDeleteLine()
	 EndIf
	//Limpa Grid de Destino
	If !(oModelDes:IsEmpty())
		oModelDes:SetNoInsertLine(.F.)
		nNewLine := oModelDes:AddLine()
		oModelDes:GoLine( nNewLine )
		oModelDes:LineShift(1,nNewLine)
		oModelDes:GoLine( nNewLine )
		For nY := oModelDes:Length()+1 To 2 Step -1 
	        oModelDes:GoLine(nY)
	        oModelDes:DeleteLine(.T.,.T.)                
	    Next    
	    oModelDes:GoLine(1)
	    oModelDes:UnDeleteLine()
	EndIf
	
   	For nX := 1 To 2 
   		lAddLn := .F.
		nSeq := 0	
   		
   		
		Iif (nX == 1, cGrid := 'GRID_ORI', cGrid := 'GRID_DES')
		
		oModelDL7:GetModel(cGrid):SetNoInsertLine(.F.) //Sem isto ocorre error.log no Addline quando é primeiro tentado alterar algum registro e reproduz um return .F. e depois entra incluindo e informa um Grp. de Região.

		if nX == 1
		    // Busca regiões de Origem p/ o Grupo de Regiões da Gestão de Demandas
			cQuery := " SELECT DISTINCT(DLJ_CODREG) CODREG  FROM "+ RetSqlName('DLJ') + " DLJ "
			cQuery += " WHERE DLJ.DLJ_FILIAL = '" + xFilial("DLJ") + "'"
			cQuery += " AND DLJ.DLJ_CODGRD = '" + M->DLE_CODGRD + "'"
			cQuery += " AND DLJ.D_E_L_E_T_ = ' ' "
		else
		    // Busca regiões de Destino p/ o Grupo de Regiões da Gestão de Demandas
			cQuery := " SELECT DISTINCT(DLK_CODREG) CODREG  FROM "+ RetSqlName('DLK') + " DLK "
			cQuery += " WHERE DLK.DLK_FILIAL = '" + xFilial("DLK") + "'"
			cQuery += " AND DLK.DLK_CODGRD = '" + M->DLE_CODGRD + "'"
			cQuery += " AND DLK.D_E_L_E_T_ = ' ' "
		endif 
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
   		
   		While (cTemp)->(!EoF())   		
		   
		   If nX == 1 
	 			IiF (lAddLn, oModelDL7:GetModel(cGrid):AddLine(), lAddLn := .T.)
	
	   			nSeq += 1
	   			oModelDL7:SetValue(cGrid, 'DLM_CODREG', (cTemp)->CODREG)
	   			oModelDL7:SetValue(cGrid, 'DLM_SEQREG', Padl(cValToChar(nSeq), 2, '0'))
	   		Else
				IiF (lAddLn, oModelDL7:GetModel(cGrid):AddLine(), lAddLn := .T.)
	
	   			nSeq += 1
	   			oModelDL7:SetValue(cGrid, 'DLN_CODREG', (cTemp)->CODREG)
	   			oModelDL7:SetValue(cGrid, 'DLN_SEQREG', Padl(cValToChar(nSeq), 2, '0'))	   		
	   		EndIf

   			(cTemp)->(DbSkip())
		EndDo

		(cTemp)->(DbCloseArea())
		
		oModelDL7:GetModel(cGrid):SetLine(1)
		oModelDL7:GetModel(cGrid):aLinesChanged := {}
	Next nX	   						
	
	RestArea(aArea)
EndIf
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T153TIPVEI
//Cria uma tela MVC para selecionar as filiais.
@author  Gustavo Krug
@since   30/05/2018
@version 12.1.17
@param nOpc, type "N", Parâmetro define se função está sendo chamada pelo F3 do campo DL7_TIPVEI ou DLE_TIPVEI
/*/
//-------------------------------------------------------------------
Function T153TIPVEI(nOpc)
Local aBotoes     := {} //Botoes da tela
Local aStructBrw  := {} //Estrutura da tela
Local aCamposBrw  := {} //Campos que compoem a tela
Local aColsBrw    := {} //Colunas que compoem a tela
Local aCatVei 	  := RetSX3Box(GetSX3Cache("DUT_CATVEI","X3_CBOX"),,,1)
Local oModel 	  := FwModelActive()
Local oModelDLE   := oModel:GetModel('GRID_DLE')
Local nOperation  := oModel:GetOperation()
Local nX          := 1

 	Aadd(aCamposBrw,"TTV_TIPVEI")
	Aadd(aCamposBrw,"TTV_DESCRI")
	Aadd(aCamposBrw,"TTV_CATVEI")

	Aadd(aStructBrw, {"MARK",       "C",   1, 0})
	Aadd(aStructBrw, {"TTV_TIPVEI", "C",  TAMSX3("DUT_TIPVEI")[1], 0})
	Aadd(aStructBrw, {"TTV_DESCRI", "C",  TAMSX3("DUT_DESCRI")[1], 0})
	Aadd(aStructBrw, {"TTV_CATVEI", "C",  TAMSX3("DUT_DESCRI")[1], 0})

	oBrwCol:= FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| TTV_TIPVEI }"))
	oBrwCol:SetTitle('Tipo de Veículo')
	oBrwCol:SetSize(TAMSX3("DUT_TIPVEI")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("@!")
	oBrwCol:SetReadVar("TTV_TIPVEI")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol:= FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| TTV_DESCRI }"))
	oBrwCol:SetTitle('Descrição')
	oBrwCol:SetSize(20)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("@!")
	oBrwCol:SetReadVar("TTV_DESCRI")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| TTV_CATVEI }"))
	oBrwCol:SetTitle('Categoria')
	oBrwCol:SetSize(15)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("@!")
	oBrwCol:SetReadVar("TTV_CATVEI")
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cTemp := GetNextAlias()
		oTempTable := FWTemporaryTable():New(cTemp)
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"TTV_TIPVEI"})
		oTempTable:Create()
	EndIf
		
	DbSelectArea("DUT")
	DUT->(DBSetOrder(1))
	
	DbSeek(xFilial('DUT'))
	While DUT->(!EoF()) .AND. DUT->DUT_FILIAL == xFilial('DUT')
		For nX := 1 To Len(aCatVei)
			If aScan(aCatVei[nX],DUT->DUT_CATVEI) > 0
				Exit
			EndIf
		Next nX

		If (aScan(aTipVeiDL7, AllTrim(DUT->DUT_TIPVEI)) > 0 .OR. nOpc == 1) .AND. DUT->DUT_CATVEI <> '2'
			RecLock(cTemp,.T.)
			(cTemp)->TTV_TIPVEI := AllTrim(DUT->DUT_TIPVEI)
			(cTemp)->TTV_DESCRI := AllTrim(DUT->DUT_DESCRI)
			(cTemp)->TTV_CATVEI := AllTrim(aCatVei[nX][3])
			MsUnlock()
		EndIf
		DUT->(DbSkip())
	EndDo

	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	If nOpc == 1 
		oDlgMan:SetTitle(STR0045) //Tipos de Veículos
	ElseIf nOpc == 2
		oDlgMan:SetTitle(STR0045 + STR0046) //Tipos de Veículos do Controle de Metas Detalhado
	EndIf
	oDlgMan:SetEscClose(.T.)
	oDlgMan:SetSize(300, 400)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()	

	oFWLayer := FWLayer():New()                
	oFWLayer:Init(oPnlModal, .F., .F.)          

	oFWLayer:AddLine('LIN', 100, .F.)           
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') 
	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias((cTemp))
 	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:DisableDetails()
   	oMarkBrw:DisableLocate() 
   	oMarkBrw:DisableReport()	
	If nOpc == 1
		oMarkBrw:SetDescription(STR0044 + STR0045) //Selecione os Tipos de Veículos
	ElseIf nOpc == 2
		oMarkBrw:SetDescription(STR0044 + STR0045 + STR0046) //Selecione os Tipos de Veículos do Controle de Metas Detalhado
	EndIf
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	If nOpc == 1
		bConfir := {|| T153SelTip("DL7"), oDlgMan:DeActivate() }
		If nOperation == MODEL_OPERATION_INSERT
			bCancel := {|| oDlgMan:DeActivate()}
		Else
			bCancel := {|| aTipVeiDL7 := aClone(aDbTipVei1),  oDlgMan:DeActivate()}
		EndIf
	ElseIf nOpc == 2
		bConfir := {|| T153SelTip("DLE"), oDlgMan:DeActivate() }
		If nOperation == MODEL_OPERATION_INSERT
			bCancel := {|| oDlgMan:DeActivate()}
		Else
			bCancel := {|| aTipVeiDLE := aClone(aDbTipVei2),  oDlgMan:DeActivate()}
		EndIf
	EndIf
	    
	//-- Cria botoes de operacao 
	Aadd(aBotoes, {"", STR0047, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0048, bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aBotoes)
	
	oMarkBrw:Activate()
	
	If nOpc == 1
		While (cTemp)->(!Eof()) 
			If aScan(aTipVeiDL7,Trim((cTemp)->TTV_TIPVEI)) > 0 
				oMarkBrw:MarkRec() 
			EndIf
			(cTemp)->(dbSkip())
		EndDo
	EndIf

	If nOpc == 2	
		While (cTemp)->(!Eof()) 
			If aScan(aTipVeiDLE, {|x| x[1]+x[2] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) + Trim((cTemp)->TTV_TIPVEI) }) > 0
				oMarkBrw:MarkRec() 
			EndIf
			(cTemp)->(dbSkip())
		EndDo
	EndIf
	
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	oDlgMan:Activate()

	//-- Ao finalizar, elimina tabelas temporarias
	(cTemp)->(DbCloseArea())
	If File(cTemp+GetDBExtension())
		FErase(cTemp+GetDBExtension())
	EndIf 
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} T153SelTip()
//Alimenta array com todos os Tipos de Veículos marcados                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 com as filiais selecionadas pelo usuario.
@author  Gustavo Krug
@since   30/05/2018
@version 12.1.17
@param cAlias, "C", Define qual o Alias que será utilizado
@param lConfirm, "L", Define se função atualizará os dados do array
/*/
//-------------------------------------------------------------------
Function T153SelTip(cAlias)
Local aArea     := GetArea()
Local nX        := 1
Local oModel := FwModelActive()
Local nOperation := oModel:GetOperation()
Local oModelDLE := oModel:GetModel('GRID_DLE')
Local nPos := 0
Local nSize := 0
	
	DbSelectArea(cTemp)
	(cTemp)->(dbGoTop())
	
	//Incluir Contrato de Demandas
	If nOperation == MODEL_OPERATION_INSERT
		While (cTemp)->(!EoF())	
			If cAlias == "DL7"
				If !Empty(MARK)
					If aScan(aTipVeiDL7, AllTrim((cTemp)->TTV_TIPVEI)) <= 0
						AAdd(aTipVeiDL7,AllTrim((cTemp)->TTV_TIPVEI)) 
					EndIf
				Else
					If aScan(aTipVeiDLE, {|x| x[2] == AllTrim((cTemp)->TTV_TIPVEI)}) > 0 
						Help( ,, 'HELP',,STR0053 + AllTrim((cTemp)->TTV_TIPVEI) + STR0054, 1, 0,,,,,,{STR0055}) //"Tipo de veículo xx está vinculados a um Grupo de Regiões." / "Remova o tipo de veículo do Grupo de Regiões primeiro para remover o tipo de veículo do contrato."
					Else
						nPos := aScan(aTipVeiDL7, AllTrim((cTemp)->TTV_TIPVEI))
						If nPos > 0
							ADel(aTipVeiDL7,nPos)
							nSize := (Len(aTipVeiDL7) - 1)
							ASize(aTipVeiDL7,nSize)
						EndIf
					EndIf
				EndIf
			ElseIf cAlias == "DLE"
				If !Empty(MARK)
					If aScan(aTipVeiDLE, {|x| x[1]+x[2] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) + AllTrim((cTemp)->TTV_TIPVEI) }) <= 0 
						AAdd(aTipVeiDLE, {AllTrim(oModelDLE:GetValue('DLE_CODGRD')), AllTrim((cTemp)->TTV_TIPVEI) })
					EndIf
				Else
					nPos := aScan(aTipVeiDLE, {|x| x[1]+x[2] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) + AllTrim((cTemp)->TTV_TIPVEI) })
					If nPos > 0
						ADel(aTipVeiDLE,nPos)
						nSize := (Len(aTipVeiDLE) - 1)
						ASize(aTipVeiDLE,nSize)
					EndIf
				EndIf
			EndIf

			(cTemp)->(DbSkip())
		EndDo
	EndIf

	//Alterar Contrato de Demandas
	If nOperation == MODEL_OPERATION_UPDATE 
		While(cTemp)->(!EoF())
			If cAlias == "DL7"
				nPos := aScan(aTipVeiDL7, AllTrim((cTemp)->TTV_TIPVEI))
				If !Empty(MARK) .And. nPos <= 0
					AAdd(aTipVeiDL7,AllTrim((cTemp)->TTV_TIPVEI)) 
				ElseIf Empty(MARK) .And. nPos > 0 
					If aScan(aTipVeiDLE, {|x| x[2] == AllTrim((cTemp)->TTV_TIPVEI)}) > 0
						Help( ,, 'HELP',,STR0053 + AllTrim((cTemp)->TTV_TIPVEI) + STR0054, 1, 0,,,,,,{STR0055}) //"Tipo de veículo xx está vinculados a um Grupo de Regiões." / "Remova o tipo de veículo do Grupo de Regiões primeiro para remover o tipo de veículo do contrato." 
					Else
						ADel(aTipVeiDL7,nPos)
						nSize := (Len(aTipVeiDL7) - 1)
						ASize(aTipVeiDL7,nSize)
					EndIf
				EndIf
			ElseIf cAlias == "DLE"
				nPos := aScan(aTipVeiDLE, {|x| x[1]+x[2] == AllTrim(oModelDLE:GetValue('DLE_CODGRD')) + AllTrim((cTemp)->TTV_TIPVEI) })
				If !Empty(MARK) .And. nPos <= 0
					AAdd(aTipVeiDLE, {AllTrim(oModelDLE:GetValue('DLE_CODGRD')), AllTrim((cTemp)->TTV_TIPVEI) })
				ElseIf Empty(MARK) .And. nPos > 0
					ADel(aTipVeiDLE,nPos)
					nSize := (Len(aTipVeiDLE) - 1)
					ASize(aTipVeiDLE,nSize)
				EndIf
			EndIf
			(cTemp)->(DbSkip())
		EndDo
	EndIf
		
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T153PrVlGR
Pré-validação do submodelo (Grupo de Região da Demanda). 
O bloco é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.  
@author  Marlon Augusto Heiber
@since   28/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153PrVlGR(oModel, nLine, cOpera, cCampo)
	Local lRet 		:= .T.
	Local oModelAux	:= oModel:GetModel('MASTER_DL7')
	Local oModelDL7	:= oModelAux:GetModel('MASTER_DL7')
	Local nOperation:= oModel:GetOperation()
	Local aAreaDLG  := DLG->(GetArea("DLG"))
	Local cCrtDmd   := oModelDL7:GetValue('DL7_COD')
	Local cGrpReg   := oModel:GetValue('DLE_CODGRD')

	If nOperation == MODEL_OPERATION_UPDATE 
		If cOpera == "CANSETVALUE" .AND. !(oModel:IsInserted(oModel:GetLine())) .AND. !(oModel:IsDeleted())
			If lRet .AND. oModelDL7:GetValue('DL7_META') == '1'  //Não permitir alterar Grupo de Região caso haja meta cadastrada.
				DLG->(DbSetOrder(1))
				If DLG->(DbSeek(xFilial("DLG") + cCrtDmd + (oModel:GetValue('DLE_CODGRD'))))
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If cOpera == "DELETE"
		If lRet  //Não permitir deletar Grupo de Região caso haja demanda cadastrada.
			if GrpRegDmd(cCrtDmd, cGrpReg) .AND. !oModel:IsInserted(nLine)
				Help( ,, 'HELP',,STR0056, 1, 0,,,,,,{STR0050}) //"Não é possível excluir Grupo de Região com Demandas vinculadas ao contrato que utilizam este Grupo de Região." 
				lRet := .F.			
			EndIf	
		EndIf
		IiF(lRet,SetFunName("T153PrVlGR"),) //Conseguiu deletar, muda o nome da função para ser identificada na validação dos grids de região.
	EndIf

	RestArea(aAreaDLG)	

Return lRet
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrpRegDmd
Valida a utilização do Grupo de Regiões do Contrato em alguma Demanda vinculada ao mesmo Contrato.
@type Function
@author André Luiz Custódio
@version 12.1.17
@since 31/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function GrpRegDmd(cCrtDmd, cCodGrpReg)
	Local lRet      := .F.
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ''

	cQuery += " SELECT DISTINCT '1' EXISTE "
	cQuery += "   FROM  " + RetSqlName('DL8') + " DL8  "
	cQuery += "  WHERE DL8.DL8_FILIAL = '" + xFilial("DL8") + "'"
	cQuery += "    AND DL8.DL8_CRTDMD = '"+cCrtDmd+"'"
	cQuery += "    AND DL8.DL8_CODGRD = '"+cCodGrpReg+"'"
	cQuery += "    AND DL8.D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

	if (cAliasQry)->EXISTE = '1'
		lRet := .T.
	endif 

	(cAliasQry)->( DbCloseArea() )	

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153CVL
Valid Activate da rotina TMSA153C
@type Static Function
@author Marlon Augusto Heiber
@version 12.1.17
@since 25/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA153CVL(oModel)
	Local lRet 		 := .T.	
	Local cCrtDmd    := DL7->DL7_COD
	Local cDemanda	 := ""
	Local nOperation := oModel:GetOperation()
			
	If nOperation == MODEL_OPERATION_DELETE 
		If lRet
			cDemanda := TMS153ConD(cCrtDmd)
			If Len(cDemanda) >  TamSX3('DL8_COD')[1]
				Help( ,, 'HELP',,STR0049, 1, 0,,,,,,{STR0050})  //Não é possível excluír Contrato de Demanda com Demanda vinculada ao contrato. - Verifique no cadastro de Demandas ou Planejamento de Demandas a(s) Demanda(s) vinculada(s) a este contrato.
				lRet := .F.
			EndIf	
		EndIf
    Endif 
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS153ConD
//Função que retorna demandas vinculadas ao contrato informado. 
@author Marlon Agusto Heiber
@since 25/06/2018
@Param cCrtDmd - Caractere - Códigos do contrato de demanda
@return cDemandas - Caractere - Códigos das demandas 
/*/
//-------------------------------------------------------------------
Function TMS153ConD(cCrtDmd)
Local cQuery 	:= ''
Local cTemp 	:= GetNextAlias() 
Local cDemandas := ""
	
	cQuery := " SELECT DL8_COD FROM " + RetSqlName('DL8') + " DL8 "
	cQuery += " WHERE DL8_FILIAL = '" + xFilial("DL8") + "'"
	cQuery += " AND DL8_CRTDMD = '" + cCrtDmd + "'"
	cQuery += " AND D_E_L_E_T_ = ' ' "	
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
	While (cTemp)->(!Eof()) .AND. !Empty((cTemp)->DL8_COD)
		cDemandas += (cTemp)->DL8_COD + ";"     	
		(cTemp)->(dbSkip())	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
Return cDemandas

//-----------------------------------------------------------------------
/*/{Protheus.doc} TM153CMeta()
Cadastrada a meta generica para contratos que não utilizam meta detalhada
@author  Ruan Ricardo Salvador
@since   25/06/2018
@version 12.1.17
/*/
//-----------------------------------------------------------------------
Static Function TM153CMeta(oModel)
Local oModelDL7 := oModel:GetModel('MASTER_DL7')
Local oModelDLE := oModel:GetModel('GRID_DLE')
Local nX        := 0

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModelDLE:Length(.T.) >= 1
		For nX:= 1 to oModelDLE:GetQTDLine()
			oModelDLE:SetLine(nX)
			If !oModelDLE:IsDeleted() 
				RecLock('DLG',.T.)
					DLG->DLG_CODCRT := oModelDL7:GetValue('DL7_COD')
					DLG->DLG_CODGRD := oModelDLE:GetValue('DLE_CODGRD')
					DLG->DLG_SEQ    := '001'
					DLG->DLG_DATINI := oModelDL7:GetValue('DL7_INIVIG')
					DLG->DLG_DATFIM := oModelDL7:GetValue('DL7_FIMVIG')
					DLG->DLG_QTD    := oModelDLE:GetValue('DLE_QTD')
				MsUnlock('DLG')
			EndIf
		Next nX
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		For nX:= 1 to oModelDLE:GetQTDLine()
			oModelDLE:SetLine(nX)
			If DLG->(DbSeek(xFilial('DLG')+oModelDL7:GetValue('DL7_COD')+oModelDLE:GetValue('DLE_CODGRD')))
				If oModelDLE:IsDeleted() 
					RecLock('DLG',.F.)
						DLG->(DBDelete())
					MsUnlock('DLG')
				Else
					RecLock('DLG',.F.)
						DLG->DLG_DATINI := oModelDL7:GetValue('DL7_INIVIG')
						DLG->DLG_DATFIM := oModelDL7:GetValue('DL7_FIMVIG')
						DLG->DLG_QTD    := oModelDLE:GetValue('DLE_QTD')
					MsUnlock('DLG')
				EndIf
			ENDIF
		Next nX
		
		For nX:= 1 to oModelDLE:GetQTDLine()
			oModelDLE:SetLine(nX)
			If !(DLG->(DbSeek(xFilial('DLG')+oModelDL7:GetValue('DL7_COD')+oModelDLE:GetValue('DLE_CODGRD'))))
				If !oModelDLE:IsDeleted()
					RecLock('DLG',.T.)
						DLG->DLG_CODCRT := oModelDL7:GetValue('DL7_COD')
						DLG->DLG_CODGRD := oModelDLE:GetValue('DLE_CODGRD')
						DLG->DLG_SEQ    := '001'
						DLG->DLG_DATINI := oModelDL7:GetValue('DL7_INIVIG')
						DLG->DLG_DATFIM := oModelDL7:GetValue('DL7_FIMVIG')
						DLG->DLG_QTD    := oModelDLE:GetValue('DLE_QTD')
					MsUnlock('DLG')
				EndIf
			EndIf 
		Next nX
	EndIf 

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} TM153CVld()
Validações do campos DL7
@author  Ruan Ricardo Salvador
@since   27/06/2018
@version 12.1.17
/*/
//-----------------------------------------------------------------------
Function TM153CVld(cCampo)
Local oModel := FWModelActive() 
Local lRet   := .T.
	
	Do Case
		case cCampo == 'DL7_META'
			If oModel:GetValue('MASTER_DL7','DL7_META') == '2' .And. !Empty(aTipVeiDLE)
				ASize(aTipVeiDLE,0)
			EndIf
		Otherwise
			lRet := .T.
	EndCase
	
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine()
Propriedade da View executada na mudança de linhas dos grids.
@author  Marlon Augusto Heiber
@since   03/07/2018
@version 12.1.17
/*/
//-----------------------------------------------------------------------
Static Function ChangeLine(oView, oModel)
Local lRet 		 := .T.
Local oModelDLE  := oModel:GetModel('GRID_DLE')
Local oModelOri  := oModel:GetModel('GRID_ORI')
Local oModelDes  := oModel:GetModel('GRID_DES')
Local aAreaDLG   := {}
	
	If DL7->DL7_META = '1' .AND. !(oModel:isCopy())
		aAreaDLG   := DLG->(GetArea("DLG"))
		DLG->(DbSetOrder(1))
		If DLG->(DbSeek(xFilial("DLG") + DL7->DL7_COD + (oModelDLE:GetValue('DLE_CODGRD')))) .OR. oModelDLE:IsDeleted()
			oModelOri:SetNoInsertLine(.T.) 
			oModelDes:SetNoInsertLine(.T.)	
		Else	
			If !oModelDLE:IsDeleted()
				oModelOri:SetNoInsertLine(.F.) 
				oModelDes:SetNoInsertLine(.F.)
			EndIf
		EndIf
		RestArea(aAreaDLG)	
	Else //tratamento para quando o registro estiver deletado não permitir incluir linhas na grid de regiões.
		If oModelDLE:IsDeleted()
			oModelOri:SetNoInsertLine(.T.) 
			oModelDes:SetNoInsertLine(.T.)	
		ElseIf  !oModelDLE:IsDeleted()
			oModelOri:SetNoInsertLine(.F.) 
			oModelDes:SetNoInsertLine(.F.)	
		EndIf
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA153DVL
Validação após ativar a view (clicar em incluir, alterar ou excluir) 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 05/06/2018
/*/
//-------------------------------------------------------------------
Static Function AfterVwAct(oView) 	
Local oModel 	 := Nil         	// Recebe o Model 
Local oModelDLE  := Nil 			// Recebe o Model 
Local oModelOri  := Nil 			// Recebe o Model 
Local oModelDes  := Nil 			// Recebe o Model 
Local nOperation := oView:GetOperation()
Local lRet 		 := .T.	
Local aAreaDLG   := {}

    //Bloqueia ou não a adição de linha quando utiliza meta detalhada e possui meta cadastrada no primeiro registro. Tratativa de desbloqueio é realizada na View na função ChangeLine().
	If nOperation == MODEL_OPERATION_UPDATE	
		If DL7->DL7_META = '1'
			aAreaDLG   := DLG->(GetArea("DLG"))
			DLG->(DbSetOrder(1))
			oModel	   := oView:GetModel()
			oModelDLE  := oModel:GetModel('GRID_DLE')  
			If DLG->(DbSeek(xFilial("DLG") + DL7->DL7_COD + (oModelDLE:GetValue('DLE_CODGRD',1))))	
				oModelOri  := oModel:GetModel('GRID_ORI')
				oModelDes  := oModel:GetModel('GRID_DES')
				oModelOri:SetNoInsertLine(.T.) 
				oModelDes:SetNoInsertLine(.T.)
			Else
				oModelOri  := oModel:GetModel('GRID_ORI')
				oModelDes  := oModel:GetModel('GRID_DES')
				oModelOri:SetNoInsertLine(.F.) 
				oModelDes:SetNoInsertLine(.F.)			
			EndIf
			RestArea(aAreaDLG)	
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153IniDLe
Inicializador de campos TMSA153C
@type Function
@author Marlon Augusto Heiber
@version 12.1.17
@since 06/07/2018
/*/
//-------------------------------------------------------------------
Function T153IniDLe(cCampo)
Local cRet		:= ''
Local oModel	:= FWModelActive()
Local oModelDLE := oModel:GetModel('GRID_DLE')

	If cCampo ==  'DLE_DESGRD'
		cRet := IIF(INCLUI, "", POSICIONE("DLC",1,XFILIAL("DLC")+DLE->DLE_CODGRD,"DLC_DESCRI")) 
	EndIf

	If oModelDLE:GetLine() > 0
		cRet := ''
	EndIf

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153WHENDM
Bloco When do campo DLE_CODGRD - código demanda. 
@type function
@author Natalia Maria Neves
@version 12.1.17
@since 12/07/2018
/*/
//-------------------------------------------------------------------------------------------------
Function T153WHENCD(oModel)
Local oModelDL9 := oModel:GetModel('MASTER_DL7')
Local oModelDMD := oModelDL9:GetModel('GRID_DLE')
Local lWhen := .T.

	If !(oModel:GetOperation() = MODEL_OPERATION_INSERT)  
		If oModelDMD:IsInserted(oModelDMD:GetLine())
			lWhen := .T.
		Else
			lWhen := .F.
		EndIf
	EndIf
Return lWhen

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153CVal
Validação de campo - DL7_CLIDEV e DL7_LOJDEV
Usado no X3_VALID (dicionário de dados) dos campos da tabela DL7.

@type function
@author ana.olegini
@version 12.1.17
@since 10/09/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TM153CVal(cCampo)
	Local lRet := .T.
		
	If cCampo == "DL7_CLIDEV"
		If !Empty(M->DL7_CLIDEV)
			lRet := ExistCpo("SA1",M->DL7_CLIDEV) 
			If lRet .AND. !Empty(M->DL7_LOJDEV)
				lRet := ExistCpo("SA1",M->DL7_CLIDEV+M->DL7_LOJDEV)
			EndIf
		Else
			M->DL7_LOJDEV := ''
			M->DL7_NOMDEV := ''
		EndIf
	Endif
	If lRet .AND. cCampo == "DL7_LOJDEV"
		If !Empty(M->DL7_LOJDEV)
			lRet := ExistCpo("SA1",M->DL7_CLIDEV+M->DL7_LOJDEV) 
		EndIf
	Endif
	
Return lRet 
