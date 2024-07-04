
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'
#Include 'FWEditPanel.CH'
#Include "TOTVS.CH"
#define MODEL_FIELD_VALID_USER 15
#define __NPOSTQTDRECE  01
#define __NPOSTQTDNF	02

Static cTitulo 		:= "Pesagem do Gado"
Static cCamposCab  	:= GetMv('MV_XFLDPSG',.F.,"ZI_FILIAL|ZI_NUM|ZI_CHVNF|ZI_PLACA|ZI_MOTORIS|ZI_PESOCAM|ZI_TARACAM|ZI_QTDLIQ|ZI_MEDRECE|ZI_MEDNF|ZI_OBS|ZI_CORRETA|ZI_DTDIGPE")
Static bVK_F10      := { || AtBalanca(FwModelActive(),FWViewActive() ) }
Static cNumPes		:= ""

/*/{Protheus.doc} User Function LIVIO001
      (Tela de inclusao de informaçoes para pesagem)
      @type  Function
      @author André A. Alves 
      @since 28/10/2020
      @version 2.0
	  @modifications
	  João Vitor Ribeiro Modificou todo o fonte, colocando o mesmo em MVC !
	  e efetuando melhorias solicitadas pelo cliente em 10/07/2021
/*/
User Function LIVIO001()
	Local cAliasQry   	:= "SZI"
	Local aArea       	:= GetArea()
	Local aSeek			:= {}
	Private lFocus    	:= .F.

	//Atalhos.
	SetKey(VK_F10	, bVK_F10	)

	oBrowse := FWMBrowse():New()
	oBrowse:SetMenuDef('LIVIO001')
	oBrowse:SetAlias( cAliasQry )
	oBrowse:SetDescription( cTitulo)
	oBrowse:AddLegend('ZI_QTDNF - ZI_QTDRECE > 0 ','BR_VERMELHO',"Qtd Gado NF x Rec - Diferentes")
	oBrowse:AddLegend('ZI_QTDNF - ZI_QTDRECE <= 0','BR_VERDE',"Qtd Gado NF x Rec - Iguais")

	aAdd(aSeek,{FWSX3Util():GetDescription( "ZI_CHVNF" ),{{"","C",TAMSX3("ZI_CHVNF")[1],0,FWSX3Util():GetDescription( "ZI_CHVNF" ) ,PesqPict("SZI","ZI_CHVNF")}} } )
	aAdd(aSeek,{FWSX3Util():GetDescription( "ZI_NUM" ),{{"","C",TAMSX3("ZI_NUM")[1],0,FWSX3Util():GetDescription( "ZI_NUM" ) ,PesqPict("SZI","ZI_NUM")}} } )

	oBrowse:SetSeek(.T., aSeek)
	oBrowse:Activate()

	SetKey(VK_F10,{|| Nil })

	RestArea(aArea)

Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'            OPERATION 1                      ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LIVIO001'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.LIVIO001'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Efetivar'   ACTION 'VIEWDEF.LIVIO001'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'U_ImpMotE()'        OPERATION 7                      ACCESS 0
	ADD OPTION aRotina TITLE 'Legendas'   ACTION 'U_LegZam'           OPERATION 6                      ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.LIVIO001'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRotina

User function LegZam()
	Local aLegenda := {}
	//Monta as cores
	AADD(aLegenda, {"BR_VERDE"      , "Qtd Gado NF x Rec - Iguais"})
	AADD(aLegenda, {"BR_VERMELHO"   , "Qtd Gado NF x Rec - Diferentes"})

	BrwLegenda(cTitulo, "Legenda", aLegenda)
Return .T.

Static Function ModelDef()
	Local oModel      as Object
	Local oStrField   := TempStruct(1)
	Local oStrGrid    := FWFormStruct(1, "SZI")
	Local aSZIRel     := {}
	Local bLinePost   := { |oGriddModel,nLine| LinhaOk(oGriddModel, nLine)}

	oStrField:SetProperty('ZI_NUM'	,MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD ,"U_GetNumPs()") )
	oStrField:SetProperty("ZI_NUM"	,MODEL_FIELD_WHEN, {||.F.})

	oStrField:SetProperty("ZI_PLACA"	,MODEL_FIELD_WHEN, {|| .T. })
	oStrField:SetProperty("ZI_MOTORIS"	,MODEL_FIELD_WHEN, {|| .T. })
	oStrField:SetProperty("ZI_MEDRECE"	,MODEL_FIELD_WHEN, {|| .F. })
	oStrField:SetProperty("ZI_MEDNF"	,MODEL_FIELD_WHEN, {|| .F. })
	oStrField:SetProperty("ZI_QTDLIQ"	,MODEL_FIELD_WHEN, {|| .F. })

	//Bloqueia tudo e libera conforme necessidade.
	oStrGrid:SetProperty("*"   			,MODEL_FIELD_WHEN, {||.F.})
	oStrGrid:SetProperty("ZI_QTDRECE" 	,MODEL_FIELD_WHEN, {||.T.})
	oStrGrid:SetProperty("ZI_TIPO" 		,MODEL_FIELD_WHEN, {||.T.})

	//Remove validações de usuario para funçõe simplementadas neste fonte
	oStrField:SetProperty("ZI_CHVNF"	, MODEL_FIELD_VALID_USER , "")

	//Gatilhos
	oStrField:AddTrigger("ZI_TARACAM","ZI_QTDLIQ",{|| .T.},{ |oModel| oModel:GetValue('ZI_PESOCAM')  - oModel:GetValue('ZI_TARACAM') } )
	oStrGrid:AddTrigger("ZI_TARACAM","ZI_QTDLIQ" ,{|| .T.},{ |oModel| oModel:GetValue('ZI_PESOCAM')  - oModel:GetValue('ZI_TARACAM') } )

	oStrGrid:AddTrigger("ZI_PESOCAM","ZI_DTHRP1" ,{|| .T.},{ | |Left(FWTimeStamp(2),TamSx3("ZI_DTHRP1")[01]) } )
	oStrGrid:AddTrigger("ZI_TARACAM","ZI_DTHRP2" ,{|| .T.},{ | |Left(FWTimeStamp(2),TamSx3("ZI_DTHRP2")[01]) } )

	oStrGrid:AddTrigger("ZI_PESOCAM","ZI_PEMAN1" ,{|| .T.},{ | | "M" } )
	oStrGrid:AddTrigger("ZI_TARACAM","ZI_PEMAN2" ,{|| .T.},{ | | "M" } )

	//Estrutura de Grid, alias Real presente no dicionário de dados
	oModel := MPFormModel():New('MDLLIVIO001',/**/ ,{ |oModel| TudoOk(oModel) } , /*{ |oModel| CommitMdl(oModel) } */,{ |oModel| CancelMdl(oModel) } )

	oModel:addFields("FORMCAB", /*cOwner*/, oStrField, /*bPre*/ , /*bPost*/, { |oFieldModel, lCopy | loadField(oFieldModel, lCopy)})
	oModel:SetPrimaryKey({})

	oModel:addGrid("SZIDETAIL", "FORMCAB", oStrGrid, /*bLinePre*/, bLinePost, /*bPre*/,/* bPostLine*/, { |oMdl| loadGrid(oMdl)} )
	//Adiciona o relacionamento de Filho, Pai
	aAdd(aSZIRel, {'ZI_FILIAL', 'Iif(!INCLUI, SZI->ZI_FILIAL, FWxFilial("SZI"))'} )
	aAdd(aSZIRel, {'ZI_NUM'   , 'Iif(!INCLUI, SZI->ZI_NUM,  U_GetNumPs() )'} )
	//Criando o relacionamento
	oModel:SetRelation('SZIDETAIL', aSZIRel, SZI->(IndexKey(2))) // ZI_FILIAL + ZI_NUM
	oModel:GetModel('SZIDETAIL'):SetNoInsertLine(.T.) //Nao inseri linhas de pagamento manualmente,
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('SZIDETAIL'):SetUniqueLine({"ZI_CHVNF","ZI_DOC","ZI_SERIE","ZI_FORNEC","ZI_LOJAF","ZI_COD","ZI_ITEM"})

	oModel:setDescription( cTitulo )
	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro da " + cTitulo)

	oModel:AddCalc( 'TOTAIS', 'FORMCAB', 'SZIDETAIL', 'ZI_QTDNF'  , 'T_QTDNF'   , 'SUM',,, FWSX3Util():GetDescription( "ZI_QTDNF" ),, TamSX3("ZI_QTDNF" )[1],TamSX3("ZI_QTDNF" )[2] )
	oModel:AddCalc( 'TOTAIS', 'FORMCAB', 'SZIDETAIL', 'ZI_QTDRECE', 'T_QTDRECE' , 'SUM',,, FWSX3Util():GetDescription( "ZI_QTDRECE" ),,TamSX3("ZI_QTDRECE" )[1],TamSX3("ZI_QTDRECE" )[2] )

	oModel:AddCalc( 'TOTAIS', 'FORMCAB', 'SZIDETAIL', 'ZI_TMITREC', 'T_TMITREC'  , 'SUM',,, FWSX3Util():GetDescription( "ZI_TMITREC" ),,TamSX3("ZI_TMITREC" )[1],TamSX3("ZI_TMITREC" )[2] )

	oModel:AddCalc( 'TOTAIS', 'FORMCAB', 'SZIDETAIL', 'ZI_TMITNF', 'T_TMITNF'  , 'SUM',,, FWSX3Util():GetDescription( "ZI_TMITNF" ),,TamSX3("ZI_TMITNF" )[1],TamSX3("ZI_TMITNF" )[2] )

Return oModel

Static Function ViewDef()
	local oView       := FwFormView():New()
	local oModel      := ModelDef()
	local oStrCab     := TempStruct(2)
	local oStrGrid    := FWFormStruct(2, "SZI")
	Local aFldCab	  := StrTokArr(cCamposCab,"|")
	Local nX

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView       := FWFormView():New()
	oTotais 	:= FWCalcStruct( oModel:GetModel( 'TOTAIS') )
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStrCab, "FORMCAB")
	oView:AddGrid('VIEW_SZI' ,oStrGrid,'SZIDETAIL',, /*{ || FocusCab(oModel,oView)}*/)
	oView:AddField("VIEW_TOTAIS", oTotais, "TOTAIS")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID',47)
	oView:CreateHorizontalBox('TOTAIS',13)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_SZI','GRID')
	oView:SetOwnerView('VIEW_TOTAIS','TOTAIS')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - '+ cTitulo)
	oView:EnableTitleView('VIEW_SZI','Itens - '+ cTitulo)
	oView:EnableTitleView('VIEW_TOTAIS','TOTAIS ')
	//Tratativa padrão para fechar a tela
	// oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	oStrCab:RemoveField('ZI_FILIAL')
	oStrGrid:RemoveField('ZI_FILIAL')
	oStrGrid:RemoveField('ZI_NUM')
	oStrGrid:RemoveField('ZI_PLACA')
	oStrGrid:RemoveField('ZI_MOTORIS')
	oStrGrid:RemoveField('ZI_PESOCAM')
	oStrGrid:RemoveField('ZI_TARACAM')
	oStrGrid:RemoveField('ZI_QTDLIQ')
	oStrGrid:RemoveField('ZI_OBS')
	oStrGrid:RemoveField('ZI_MEDNF')
	oStrGrid:RemoveField('ZI_MEDRECE')

	oView:SetViewCanActivate( { | oModel | ValidInic(oModel) } )
	// oView:SetCloseOnOk({ |oView|  lNegocOk := if(FWIsInCallStack("BUTTONOKACTION"),U_Negoc001(oView,"2"),.T.) })
	// oView:SetAfterViewActivate({ | oView | VldPosIn(oView) })
	oView:SetProgressBar(.T.) //Ativa ou desativa o uso da MsgRun na carga do formulario.

	//Modifico as propriedades da View da Grid
	oView:SetViewProperty('*', 'SETLAYOUT',{FF_LAYOUT_HORZ_DESCR_TOP,5}) //FF_LAYOUT_HORZ_DESCR_TOP top!
	oView:SetViewProperty("*", "SETCOLUMNSEPARATOR", {1} )

	//Cabeçalho
	oStrCab:SetProperty("ZI_NUM"     ,MVC_VIEW_ORDEM,'01')
	oStrCab:SetProperty("ZI_CHVNF"   ,MVC_VIEW_ORDEM,'02')
	oStrCab:SetProperty("ZI_PESOCAM" ,MVC_VIEW_ORDEM,'03')
	oStrCab:SetProperty("ZI_TARACAM" ,MVC_VIEW_ORDEM,'04')
	oStrCab:SetProperty("ZI_QTDLIQ"  ,MVC_VIEW_ORDEM,'06')
	oStrCab:SetProperty("ZI_MEDNF"   ,MVC_VIEW_ORDEM,'07')
	oStrCab:SetProperty("ZI_MEDRECE" ,MVC_VIEW_ORDEM,'08')
	oStrCab:SetProperty("ZI_PLACA"   ,MVC_VIEW_ORDEM,'09')
	oStrCab:SetProperty("ZI_MOTORIS" ,MVC_VIEW_ORDEM,'10')
	oStrCab:SetProperty("ZI_OBS" 	 ,MVC_VIEW_ORDEM,'11')

	//itens
	oStrGrid:SetProperty("ZI_CHVNF"   ,MVC_VIEW_ORDEM,'01')
	oStrGrid:SetProperty("ZI_DOC"     ,MVC_VIEW_ORDEM,'02')
	oStrGrid:SetProperty("ZI_SERIE"   ,MVC_VIEW_ORDEM,'03')
	oStrGrid:SetProperty("ZI_FORNEC"  ,MVC_VIEW_ORDEM,'04')
	oStrGrid:SetProperty("ZI_LOJAF"   ,MVC_VIEW_ORDEM,'05')
	oStrGrid:SetProperty("ZI_EMISNF"  ,MVC_VIEW_ORDEM,'06')
	oStrGrid:SetProperty("ZI_DIGNF"   ,MVC_VIEW_ORDEM,'07')
	oStrGrid:SetProperty("ZI_ITEM"    ,MVC_VIEW_ORDEM,'08')
	oStrGrid:SetProperty("ZI_COD"     ,MVC_VIEW_ORDEM,'09')
	oStrGrid:SetProperty("ZI_DESC"    ,MVC_VIEW_ORDEM,'10')
	oStrGrid:SetProperty("ZI_QTDNF"   ,MVC_VIEW_ORDEM,'11')
	oStrGrid:SetProperty("ZI_QTDRECE" ,MVC_VIEW_ORDEM,'12')
	oStrGrid:SetProperty("ZI_TIPO"	  ,MVC_VIEW_ORDEM,'13')
	oStrGrid:SetProperty('ZI_TMITREC' ,MVC_VIEW_ORDEM,'14')
	oStrGrid:SetProperty('ZI_TMITNF'  ,MVC_VIEW_ORDEM,'15')

	//Ajusta largura dos campos.
	oStrGrid:SetProperty('ZI_CHVNF'		,   MVC_VIEW_WIDTH,  300)
	oStrGrid:SetProperty("ZI_DOC"		,   MVC_VIEW_WIDTH,  080)
	oStrGrid:SetProperty("ZI_SERIE"		,   MVC_VIEW_WIDTH,  060)
	oStrGrid:SetProperty("ZI_ITEM"		,   MVC_VIEW_WIDTH,  080)
	oStrGrid:SetProperty("ZI_COD"		,   MVC_VIEW_WIDTH,  100)
	oStrGrid:SetProperty("ZI_DESC"		,   MVC_VIEW_WIDTH,  250)
	oStrGrid:SetProperty("ZI_FORNEC"	,   MVC_VIEW_WIDTH,  080)
	oStrGrid:SetProperty("ZI_LOJAF" 	,   MVC_VIEW_WIDTH,  080)
	oStrGrid:SetProperty("ZI_QTDNF"		,   MVC_VIEW_WIDTH,  100)
	oStrGrid:SetProperty("ZI_QTDRECE"   ,   MVC_VIEW_WIDTH,  100)
	oStrGrid:SetProperty("ZI_TIPO"   	,   MVC_VIEW_WIDTH,  200)

	//Botões
	oView:AddUserButton( "Balança - (10)" , 'CLIPS', 	{ || AtBalanca(FwModelActive(),FWViewActive()) } )
	//Acao de campo.
	//Cabecalho
	//oView:SetFieldAction('ZI_CHVNF'   ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	//oView:SetFieldAction("ZI_PLACA"   ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	//oView:SetFieldAction("ZI_MOTORIS" ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	//oView:SetFieldAction("ZI_PESOCAM" ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	//oView:SetFieldAction("ZI_TARACAM" ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	//oView:SetFieldAction("ZI_OBS" 	  ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	// if SZI->(FieldPos('ZI_CORRETA')) > 0
	// 	oView:SetFieldAction("ZI_CORRETA" 	  ,{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
	// Endif
	// oView:SetFieldAction("ZI_QTDRECE" ,{ |oView, cIDView, cField, xValue| CalcMed1(FWModelActive(),FWViewActive() ) } )
	For nX := 1 To Len(aFldCab)
		if SZI->(FieldPos(aFldCab[nX])) > 0
			oView:SetFieldAction(aFldCab[nX],{ |oView, cIDView, cField, xValue| CabForItem(oView, cIDView, cField, xValue) } )
		Endif
	Next nX

Return oView

User Function GetNPesg()
	Local aAreaSZI    := SZI->(GetArea())
	Local cRet        := GetSxeNum("SZI","ZI_NUM" )

	SZI->(DbSetOrder(2))
	While .T.
		IF SZI->(DbSeek(FwFilial('SZI') + cRet ))
			ConfirmSX8()
			cRet   :=  GetSxeNum("SZI","ZI_NUM" )
		Else
			Exit
		EndIF
	EndDo
	RestArea(aAreaSZI)
Return cRet

Static Function ValidInic(oModel)
	Local lRet 		 := .T.
	Local nOperation := oModel:GetOperation()

	cNumPes 	:= SZI->ZI_NUM
	if nOperation == MODEL_OPERATION_INSERT
		cNumPes := U_GetNPesg()
	EndIF

Return lRet

Static Function LinhaOk(oGriddModel, nLine)
	Local lRet 			:= .T.
	Local oModel		:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()

	if nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		CalcMed1(FWModelActive(),FWViewActive())
	Endif

Return lRet

Static function LoadGrid(oModel)
	local aData 		as array
	local cAlias 		as char
	local cWorkArea 	as char
	local cTablename 	as char
	Local cWhere 		:= ""
	Local aStru 		:= SZI->( DBStruct() )
	Local nT,nI

	if Empty(cNumPes)
		cWhere += "% R_E_C_N_O_ = "+cValToChar(SZI->(Recno()))+"  %"
	Else
		cWhere += "% ZI_FILIAL = '"+SZI->ZI_FILIAL+"' AND ZI_NUM = '"+cNumPes+"' %"
	Endif

	cWorkArea   := Alias()
	cAlias      := GetNextAlias()
	cTablename  := "%" + RetSqlName('SZI') + "%"

	BeginSql Alias cAlias
	
	// column ZI_DIGNF 	as Date
    // column ZI_EMISNF 	as Date
	// column ZI_DTDIGPE 	as Date

    SELECT *, R_E_C_N_O_ RECNO
      	FROM %exp:cTablename%
    	WHERE D_E_L_E_T_ = ' '
		AND	%Exp:cWhere%
	EndSql

	nT := len( aStru )
	For nI := 1 to nT
		If ( aStru[nI][2] $ 'DNL' )
			TCSetField( cAlias , aStru[nI, 1], aStru[nI, 2], aStru[nI, 3], aStru[nI,4] )
		Endif
	Next

	aData := FwLoadByAlias(oModel, cAlias, 'SZI', "RECNO", /*lCopy*/, .T.)

	(cAlias)->(DBCloseArea())

	if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
		DBSelectArea(cWorkArea)
	endif

return aData

Static function TudoOk(oModel)
	Local lRet 			:= .T.
	Local nOperation	:= oModel:GetOperation()

	if nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		CalcMed1(FWModelActive(),FWViewActive())
	Endif

Return lRet

Static function CommitMdl(oModel)
	Local lRet 		:= .T.

	Begin Transaction
		lRet := FwFormCommit(oModel)
		If lRet
			ConfirmSX8()
		Else
			DisarmTransaction()
			RollBackSX8()
		EndIf
	End Transaction

Return lRet

Static function CancelMdl(oModel)
	Local lRet := .T.
	//Caso seja inclusao, retorno o numero do controle de ID.
	if oModel:GetOperation() == MODEL_OPERATION_INSERT//Atendimento
		RollBackSX8()
	EndIf
Return lRet

Static Function loadField(oFieldModel, lCopy)
	Local aLoad   := array(2)
	Local oStruct := TempStruct(1) // Cabe?alho da Venda
	Local i
	Local aEstrCampos := oStruct:GetFields()
	/*/*GetFields()
	aRetorno Array com a estrutura de metadado dos campos da classe
	[n] Array com os campos
	[n][01] ExpC: Titulo
	[n][02] ExpC: Tooltip
	[n][03] ExpC: IdField
	[n][04] ExpC: Tipo
	[n][05] ExpN: Tamanho
	[n][06] ExpN: Decimal
	[n][07] ExpB: Valid
	[n][08] ExpB: When
	[n][09] ExpA: Lista de valores ( Combo )
	[n][10] ExpL: Obrigatório
	[n][11] ExpB: Inicializador padrão
	[n][12] ExpL: Campo chave
	[n][13] ExpL: Campo atualizável
	[n][14] ExpL: Campo virtual
	[n][15] ExpC: Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
	/*/

	aLoad[1] := {}
	aLoad[2] := 0

	// For i := 1 to Len(aEstrCampos)
	// 	// If AllTrim(aEstrCampos[i, MODEL_FIELD_IDFIELD ] ) ==  'ZI_NUM'
	// 	// 	aAdd(aLoad[1],cNumPes ) //dados
	// 	// Else
	// 	Do Case
	// 	Case aEstrCampos[i,MODEL_FIELD_TIPO] $ "C-M"
	// 		aAdd(aLoad[1],'' ) //dados
	// 	Case aEstrCampos[i,MODEL_FIELD_TIPO] == "N"
	// 		aAdd(aLoad[1],0 ) //dados
	// 	Case aEstrCampos[i,MODEL_FIELD_TIPO] == "D"
	// 		aAdd(aLoad[1],StoD('') ) //dados
	// 	EndCase
	// 	// EndIf
	// Next i

	For i := 1 to Len(aEstrCampos)
		If SZI->(FieldPos(aEstrCampos[i,03])) > 0 .And. Alltrim(aEstrCampos[i,03]) != 'ZI_CHVNF'
			aAdd(aLoad[1],SZI->(&(aEstrCampos[i,03])) ) //dados
		Else
			Do Case
			Case aEstrCampos[i,04] $ "C-M"
				aAdd(aLoad[1],Space(aEstrCampos[i,05]) ) //dados
			Case aEstrCampos[i,04] == "N"
				aAdd(aLoad[1],0 ) //dados
			Case aEstrCampos[i,04] == "D"
				aAdd(aLoad[1],StoD('') ) //dados
			EndCase
		EndIf
	Next i

Return aLoad

// Static Function FocusCab(oModel,oView)
// 	// oModelZZ6 := oModel:GetModel('GRIDZZ6')
// 	if lFocus
// 		oView:GetViewObj("FORMCAB")[3]:getFWEditCtrl("ZI_CHVNF"):oCtrl:SetFocus()
// 		lFocus := .F.
// 	endif
// Return

Static function CabForItem(oView, cIDView, cField, xValue)
	Local oModel      := FWModelActive()
	Local oMdlCab	  := oModel:GetModel('FORMCAB')
	Local oMdlGrid    := oModel:GetModel('SZIDETAIL')
	Local oStrGrd     := oMdlGrid:GetStruct()
	Local nX
	Local aSaveLine   := FWSaveRows()

	if cIDView != 'VIEW_SZI'
		if AllTrim(cField) ==  "ZI_CHVNF"
			if Empty(oModel:GetValue('FORMCAB','ZI_NUM'))
				cNumPes := U_GetNPesg()
				oModel:LoadValue('FORMCAB','ZI_NUM',cNumPes)
			Endif
			if oMdlGrid:SeekLine( { { "ZI_CHVNF" , xValue }  } )
				MsgInfo('Chave:' + Alltrim(xvalue)  + ' já inserido!','CabForitem')
			Else
				// //Libera o campo.
				oStrGrd:SetProperty('ZI_FILIAL' , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty('ZI_NUM'    , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty('ZI_CHVNF'  , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_DOC"    , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_SERIE"  , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_FORNEC" , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_LOJAF"  , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_COD"    , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_ITEM"   , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_EMISNF" , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_DIGNF"  , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_QTDNF"  , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_DESC"   , MODEL_FIELD_WHEN, {|| .T. })

				oStrGrd:SetProperty("ZI_PESOCAM"   , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_TARACAM"   , MODEL_FIELD_WHEN, {|| .T. })
				oStrGrd:SetProperty("ZI_QTDLIQ"    , MODEL_FIELD_WHEN, {|| .T. })
				oMdlGrid:SetNoInsertLine(.F.)

				SF1->( DbSetOrder(8) )//F1_FILIAL+F1_CHVNFE
				SD1->( DbSetOrder(1) )//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				SB1->( DbSetOrder(1) )

				if SF1->( DbSeek( FWxFilial( 'SF1' ) + xValue ) ) .And. SD1->( Dbseek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )
					While !SD1->(Eof()) .And. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)  == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
						iF SB1->(Dbseek(FwFilial('SB1') +  SD1->D1_COD) ) .And. AllTrim(SB1->B1_GRUPO) == '0501'
							if !Empty(oMdlGrid:GetValue('ZI_CHVNF') ) .Or. oMdlGrid:IsDeleted()
								oMdlGrid:GoLine( oMdlGrid:AddLine())
							EnDIf

							oMdlGrid:SetValue('ZI_FILIAL' ,FWxFilial('SZI'))
							oMdlGrid:SetValue('ZI_NUM'    ,oModel:GetValue('FORMCAB','ZI_NUM') )
							oMdlGrid:SetValue('ZI_CHVNF'  ,xValue           )
							oMdlGrid:SetValue("ZI_DOC"   , SD1->D1_DOC      )
							oMdlGrid:SetValue("ZI_SERIE" , SD1->D1_SERIE    )
							oMdlGrid:SetValue("ZI_FORNEC", SD1->D1_FORNECE  )
							oMdlGrid:SetValue("ZI_LOJAF" , SD1->D1_LOJA     )
							oMdlGrid:SetValue("ZI_COD"   , SD1->D1_COD      )
							oMdlGrid:SetValue("ZI_ITEM"  , SD1->D1_ITEM     )
							oMdlGrid:SetValue("ZI_EMISNF", SD1->D1_EMISSAO  )
							oMdlGrid:SetValue("ZI_DIGNF" , SD1->D1_DTDIGIT  )
							oMdlGrid:SetValue("ZI_QTDNF" , SD1->D1_QUANT    )
							oMdlGrid:SetValue("ZI_DESC"  , SB1->B1_DESC     )

							//preenche campos com os dados salvos anteriormente
							oMdlGrid:SetValue('ZI_PESOCAM' ,oMdlCab:GetValue('ZI_PESOCAM'))
							oMdlGrid:SetValue('ZI_TARACAM' ,oMdlCab:GetValue('ZI_TARACAM'))
							oMdlGrid:SetValue('ZI_QTDLIQ'  ,oMdlCab:GetValue('ZI_QTDLIQ'))
						Endif
						SD1->(DbSkip())
					EndDo
					cChaveNfe := xValue
				Else
					MsgInfo('Chave:' + Alltrim(xvalue)  + ' não encontrada!','CabForitem')
				EndIF
				oMdlGrid:SetNoInsertLine(.T.)
			Endif
			// //Bloqueia
			oStrGrd:SetProperty('ZI_FILIAL' , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty('ZI_NUM'    , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty('ZI_CHVNF'  , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_DOC"    , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_SERIE"  , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_FORNEC" , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_LOJAF"  , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_COD"    , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_ITEM"   , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_EMISNF" , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_DIGNF"  , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_QTDNF"  , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_DESC"   , MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_PESOCAM", MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_TARACAM", MODEL_FIELD_WHEN, {|| .F. })
			oStrGrd:SetProperty("ZI_QTDLIQ" , MODEL_FIELD_WHEN, {|| .F. })

			lFocus := .T.
			oMdlCab:SetValue('ZI_CHVNF','' )
		Else
			oStrGrd:SetProperty(cField , MODEL_FIELD_WHEN, {|| .T. })
			For nX := 1 To oMdlGrid:Length(.T.)
				oMdlGrid:GoLine( nX )
				oMdlGrid:SetValue(cField  ,xValue )
			Next nX
			oStrGrd:SetProperty(cField, MODEL_FIELD_WHEN, {|| .F. })
			//Dispara calculo do peso liquido
			if AllTrim(cField) == 'ZI_TARACAM'
				CalcMed1(oModel,oView)
			Endif
		Endif

		FwRestRows( aSaveLine )
		oView:Refresh()
	Endif

Return

/*/
	f - Peso do caminhão vazio para informar a tara; (ZA_TARACAM)
	g - quantidade do gado realmente recebido (campo digitado após recebimento e informação da tara) (ZA_QTDRECE)
	h - quantidade do gado informado em nota (trazer do lançamento da nota no momento que informar a numeração da nota. (Campo D1_QUANT) (ZA_QTDNF)
	i - media do peso do gado recebido (cálculo feito pelo sistema (item f - item g) / item h)              ZA_MEDRECE := ((ZA_TARACAM - ZA_QTDRECE) / ZA_QTDNF)
	j - media do peso do gado informado em nota (cálculo feito pelo sistema (item f - item g) / item i)     ZA_MEDNF := ((ZA_TARACAM - ZA_QTDRECE) / ZA_MEDRECE)
	Mantido o mesmo nome da user function continda na validação de campo do campo ZI_QTDRECE.
/*/
Static Function CalcMed1(oModel, oView, aTotais )
	Local aSaveLine	:= FWSaveRows()
	Local nX
	Local oMdlCab	:= oModel:GetModel('FORMCAB')
	Local oMdlGrid	:= oModel:GetModel('SZIDETAIL')
	Local oStrCab   := oMdlCab:GetStruct()
	Local oStrGrd   := oMdlGrid:GetStruct()
	Local nQTDRECE	:= 0
	Local nQTDNF	:= 0
	Local nPesoLiq	:= oMdlCab:GetValue('ZI_QTDLIQ')
	Local nFatorNF	:= 0
	Local nFatorRec := 0
	Local lZerado	:= .F.
	Local lZera1	:= .F.
	Local lZera2	:= .F.
	Default aTotais	:= TotalGrd(oMdlGrid,{'ZI_QTDRECE','ZI_QTDNF','ZI_QTDLIQ'})

	nQTDRECE	:= aTotais[__NPOSTQTDRECE]
	nQTDNF		:= aTotais[__NPOSTQTDNF]

	iF nQTDRECE == 0
		// MsgStop('Quantidade recebida zerada, para o processo de calculo este campo deve ser maior que zero.' ,'CalcMed1')
		lZerado	:= .T.
	Endif

	iF nQTDNF == 0
		// MsgStop('Quantidade Nota fiscal zerada, para o processo de calculo este campo deve ser maior que zero.' ,'CalcMed1')
		lZerado	:= .T.
	Endif

	if !lZerado
		nFatorRec:= Round(nPesoLiq / nQTDRECE, TamSx3('ZI_MEDRECE')[02])
		nFatorNF := Round(nPesoLiq / nQTDNF, TamSx3('ZI_MEDNF')[02])

		//Cabeçalho
		oStrCab:SetProperty('ZI_MEDRECE'    , MODEL_FIELD_WHEN, {|| .T. })
		oStrCab:SetProperty('ZI_MEDNF'      , MODEL_FIELD_WHEN, {|| .T. })

		oMdlCab:SetValue('ZI_MEDRECE'       , nFatorRec)
		oMdlCab:SetValue('ZI_MEDNF'         , nFatorNF)

		oStrCab:SetProperty('ZI_MEDRECE'    , MODEL_FIELD_WHEN, {|| .F. })
		oStrCab:SetProperty('ZI_MEDNF'      , MODEL_FIELD_WHEN, {|| .F. })

		//Itens
		oStrGrd:SetProperty('ZI_MEDRECE'    , MODEL_FIELD_WHEN, {|| .T. })
		oStrGrd:SetProperty('ZI_MEDNF'      , MODEL_FIELD_WHEN, {|| .T. })
		oStrGrd:SetProperty('ZI_TMITREC'    , MODEL_FIELD_WHEN, {|| .T. })
		oStrGrd:SetProperty('ZI_TMITNF'     , MODEL_FIELD_WHEN, {|| .T. })

		For nX := 1 To oMdlGrid:Length(.T.)
			oMdlGrid:GoLine(nX)
			iF nQTDRECE == 0
				MsgStop('Campo ' + FWSX3Util():GetDescription( "ZI_QTDRECE" ) + ' zerado, para o calculo o campo deve ser maior que zero.' )
				lZera1	:= .T.
			Endif
			iF nQTDNF == 0
				MsgStop('Campo ' + FWSX3Util():GetDescription( "ZI_QTDNF" ) + ' zerado, para o calculo o campo deve ser maior que zero.' )
				lZera2	:= .T.
			Endif

			oMdlGrid:SetValue('ZI_MEDRECE',nFatorRec )
			oMdlGrid:SetValue('ZI_MEDNF'  ,nFatorNF )

			oMdlGrid:SetValue('ZI_TMITREC', oMdlGrid:GetValue('ZI_MEDRECE')   * oMdlGrid:GetValue('ZI_QTDRECE') )
			oMdlGrid:SetValue('ZI_TMITNF' , oMdlGrid:GetValue('ZI_MEDNF')    * oMdlGrid:GetValue('ZI_QTDNF') )

			if lZera1 .Or. lZera2
				Exit
			Endif

		Next nX

		For nX := 1 To oMdlGrid:Length(.T.)
			oMdlGrid:GoLine(nX)
			if lZera1
				oMdlGrid:SetValue('ZI_MEDRECE', 0)
			Endif
			if lZera2
				oMdlGrid:SetValue('ZI_MEDNF'  , 0)
			Endif
		Next nX

		oStrGrd:SetProperty('ZI_MEDRECE' , MODEL_FIELD_WHEN, {|| .F. })
		oStrGrd:SetProperty('ZI_MEDNF'   , MODEL_FIELD_WHEN, {|| .F. })
		oStrGrd:SetProperty('ZI_TMITREC' , MODEL_FIELD_WHEN, {|| .f. })
		oStrGrd:SetProperty('ZI_TMITNF'  , MODEL_FIELD_WHEN, {|| .f. })

	Endif

	FwRestRows( aSaveLine )

	oView:Refresh()

Return

Static Function AtBalanca(oModel,oView)
	Local oMdlCab	      := oModel:GetModel('FORMCAB')
	Local nOpc
	Local _nPesoLido
	Local lPesagManu        := .F.
	Local nPeso1            := 0
	Local nPeso2            := 0
	Local aParBal           := AGRX003E( .t., 'OGA050001' )

	if Len(aParBal) > 1 .And. !Empty(aParBal[01])
		if oMdlCab:GetValue('ZI_PESOCAM')  == 0
			nOpc := 1
		Elseif oMdlCab:GetValue('ZI_TARACAM')  == 0
			nOpc := 2
		Else
			if MsgYesNo('Peso e tara do caminhão preenchidos, deseja informar o peso do caminhão novamente?')
				nOpc := 1
			Else
				nOpc := 2
			Endif
		Endif

		AGRX003A( @_nPesoLido,.T., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpc )

		IF _nPesoLido > 0
			if nOpc == 1
				oMdlCab:SetValue('ZI_PESOCAM',_nPesoLido ) //SZIPE1 //nOpc ==1
				CabForItem(oView, 'VIEW_CAB', 'ZI_PESOCAM', _nPesoLido)
				CabForItem(oView, 'VIEW_CAB', 'ZI_DTHRP1',  Left(FWTimeStamp(2),TamSx3("ZI_DTHRP1")[01]))
				if SZI->(FieldPos("ZI_PEMAN1"))
					CabForItem(oView, 'VIEW_CAB', 'ZI_PEMAN1',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Elseif nOpc == 2
				oMdlCab:SetValue('ZI_TARACAM',_nPesoLido )  //SZIPES //nOpc ==2
				CabForItem(oView, 'VIEW_CAB', 'ZI_TARACAM', _nPesoLido)
				CabForItem(oView, 'VIEW_CAB', 'ZI_DTHRP2',  Left(FWTimeStamp(2),TamSx3("ZI_DTHRP2")[01]))
				if SZI->(FieldPos("ZI_PEMAN2"))
					CabForItem(oView, 'VIEW_CAB', 'ZI_PEMAN2',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Endif
		ELSE
			MsgAlert('Peso retornado da balança inválido.')
		EndIF
	EndIF

	oView:Refresh()
Return

Static Function TempStruct(nOpc)
	Local oStruct
	Local nX
	Local oStrModelo 	:= FWFormStruct(nOpc,'SZI', { |cCampo|  AllTrim(cCampo) $ cCamposCab  })
	Local aStruct		:= oStrModelo:GetFields()

	if nOpc == 1
		// Estrutura Fake de Field
		oStruct := FWFormModelStruct():New()
		oStruct:addTable("", {"ZI_NUM"}, '', {|| ""})
	Elseif nOpc == 2
		// Estrutura Fake de Field
		oStruct := FWFormViewStruct():New()
	Endif

	For nX := 1 To Len(aStruct)
		oStruct:addField(;
			aStruct[nX,01],; //[01] ExpC: Titulo
		aStruct[nX,02],; //[02] ExpC: Tooltip
		aStruct[nX,03],; //[03] ExpC: IdField
		aStruct[nX,04],; //[04] ExpC: Tipo
		aStruct[nX,05],; //[05] ExpN: Tamanho
		aStruct[nX,06],; //[06] ExpN: Decimal
		aStruct[nX,07],; //[07] ExpB: Valid
		aStruct[nX,08],; //[08] ExpB: When
		aStruct[nX,09],; //[09] ExpA: Lista de valores ( Combo )
		aStruct[nX,10],; //[10] ExpL: Obrigatório
		aStruct[nX,11],; //[11] ExpB: Inicializador padrão
		aStruct[nX,12],; //[12] ExpL: Campo chave
		aStruct[nX,13],; //[13] ExpL: Campo atualizável
		aStruct[nX,14],; //[14] ExpL: Campo virtual
		aStruct[nX,15])  //[15] ExpC: Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
	Next nX

Return oStruct

User Function GetNumPs
return cNumPes

Static Function TotalGrd(oMdlGrid,aCampos)
	Local aRet := Array(Len(aCampos))
	Local nX
	Local nY

	For nX := 1 To oMdlGrid:Length(.T.)
		oMdlGrid:Goline(nX)
		For nY := 1 To Len(aCampos)
			if ValType(aRet[nY]) == 'U'
				aRet[nY] := 0
			EndIF
			aRet[nY] += oMdlGrid:GetValue(aCampos[nY])
		Next nY
	Next nX

Return aRet

