#Include 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA677.CH'
#INCLUDE "XMLXFUN.CH"
#Include "fileio.ch"
#Include "FWEVENTVIEWCONSTS.CH"

#DEFINE OPER_INCLUI		3
#DEFINE OPER_ALTERA		4
#DEFINE OPER_CONFER		7
#DEFINE OPER_LIBFIN		10
#DEFINE OPER_ESTFIN		11
#DEFINE OPER_FINMX		12
#DEFINE OPER_ENVWF		13

Static __nOper 			:= 0 // Operacao da rotina
Static __cProcPrinc  	:= "FINA677"
Static __lConfirmar     := .T.
Static __lConfReprova 	:= .F.
Static __lBTNEstornar	:= .F.
Static aUser			:= {}
Static lWhenItem		:= .F.
Static lWhenTot			:= .F.
Static lWhenTaxa		:= .F.
Static lWhenUUID		:= .T.
Static lAuto			:= .F.
Static lEstorna			:= .F.
Static __cRetLocal      := ""
Static __cRetDespes     := ""
Static __cRetDescDp     := ""
Static lRetXML			:= .F.
Static a_UUIDRFC		:= {}
Static cMoveArq			:= "\SYSTEM\FIN677_"+DtoS(DATE())+StrTran(TIME(),":","")+".XML"	// Diretorio que o XML sera movido
Static _oFINA6771 		:= Nil
Static lMobile			:= IsInCallStack('NewXPense') .or. IsInCallStack('NewItem') .or. IsInCallStack('UpdXpense') .or. IsInCallStack('DelXpense') .or. IsInCallStack('DelItem')
Static lAutomato		
Static __ferror			:= ""
Static __lHTML	        := (GetRemoteType() == 5)
Static __lLibOk			:= .F.

//Static para contingência do uso da função MTFLUIGATV
Static __lMTFLUIGATV := FindFunction("MTFLUIGATV")

//	Legenda do GRID
Static __aLegendaItem := { 	{"CLIPS"     , STR0192, "9"} } 	//	"Despesa Salva com Anexo"
Static __aExcluirTmp := {}
																	
//-------------------------------------------------------------------
/*/{Protheus.doc} FINA677
Manutenção de prestação de contas de viagem
@author Jose Domingos
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA677()
Local oBrowse
Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local lRet 		:= .T.
Local nX := 0

// Incluido por causa da rotina MSDOCUMENT, o MVC não precisa de nenhuma variável private
Private cCadastro	:= STR0001 //"Prestação de Contas"
Private aRotina		:= MenuDef()
Private cFiltro		:= ""

If !lDefTop

	Help("  ",1,"FIN677TOP",,STR0042,1,0) //"Função disponível apenas para ambientes TopConnect"
	Return
	
EndIf

ChkFile("AC9")
ChkFile("ACB")
ChkFile("FLF")
ChkFile("FLE") 

//Valida e retorna filtro de visao do usuário do adiantamento de viagens
lRet := F677FilBrowse (@cFiltro)
If lRet
	SetKey (VK_F12,{|| pergunte("F677REC",.T.)})
	
	dbSelectArea('FLF')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FLF' )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetFilterDefault( cFiltro )

	//Legenda
	oBrowse:AddLegend( "FLF_STATUS == '1'", "GREEN"		, STR0002 ) //"Em aberto"
	oBrowse:AddLegend( "FLF_STATUS == '2'", "YELLOW"	, STR0003 ) //"Em conferência sem bloqueio"
	oBrowse:AddLegend( "FLF_STATUS == '3'", "ORANGE"	, STR0004 ) //"Em conferência com bloqueio"
	oBrowse:AddLegend( "FLF_STATUS == '4'", "PINK"		, STR0005 ) //"Em avaliação do gestor"
	oBrowse:AddLegend( "FLF_STATUS == '5'", "BLACK"		, STR0006 ) //"Reprovada"
	oBrowse:AddLegend( "FLF_STATUS == '6'", "BLUE"		, STR0007 ) //"Aprovada"
	oBrowse:AddLegend( "FLF_STATUS == '7'", "RED"		, STR0008 ) //"Em avaliação do financeiro"
	oBrowse:AddLegend( "FLF_STATUS == '8'", "BROWN"		, STR0009 ) //"Finalizada"
	oBrowse:AddLegend( "FLF_STATUS == '9'", "WHITE"		, STR0010 ) //"Faturada"

	oBrowse:Activate()
	//	Elimina arquivos Temporários usados na visualização dos Anexos
	For nX := 1 To Len(__aExcluirTmp)
		fErase(__aExcluirTmp[nX])
	Next
	__aExcluirTmp := {}

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@author Jose Domingos
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aUserMenu := {}
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011	ACTION 'VIEWDEF.FINA677'	OPERATION  2	ACCESS 0  	//"Visualizar"
ADD OPTION aRotina TITLE STR0012	ACTION 'F677INCLUI'			OPERATION  3	ACCESS 0 	//"Prestação Avulsa"
ADD OPTION aRotina TITLE STR0013	ACTION 'F677ALTER'			OPERATION  4	ACCESS 0 	//"Alterar"
ADD OPTION aRotina TITLE STR0014	ACTION 'VIEWDEF.FINA677'	OPERATION  5	ACCESS 0  	//"Excluir"
ADD OPTION aRotina TITLE STR0015	ACTION 'F677ENVCON'			OPERATION  6	ACCESS 0 	//"Enc. p/ Confer."
ADD OPTION aRotina TITLE STR0016	ACTION 'F677CONFER'			OPERATION  7	ACCESS 0 	//"Conferir"
ADD OPTION aRotina TITLE STR0157	ACTION 'F677ENVWF'			OPERATION  7	ACCESS 0 	//"Reenvio WF"
ADD OPTION aRotina TITLE STR0017	ACTION 'F677APROVA'			OPERATION  8	ACCESS 0  	//"Aprovação"
ADD OPTION aRotina TITLE STR0018	ACTION 'VIEWDEF.FINA677HIS'	OPERATION  2	ACCESS 0  	//"Hist. Aprovação"
ADD OPTION aRotina TITLE STR0019	ACTION 'F677LIBFIN'			OPERATION 10 	ACCESS 0  	//"Liberar Financ."
ADD OPTION aRotina TITLE STR0020	ACTION 'F677ESTFIN'			OPERATION 11 	ACCESS 0  	//"Estornar Lib."
ADD OPTION aRotina TITLE STR0021	ACTION 'F677FINMX'			OPERATION 12 	ACCESS 0  	//"Conf. Moeda Extr."
ADD OPTION aRotina Title STR0102	ACTION 'FN693AFAT'			OPERATION  4 	ACCESS 0   //"Faturar"
ADD OPTION aRotina Title STR0142	ACTION 'FINA692A'			OPERATION 14 	ACCESS 0
ADD OPTION aRotina Title STR0103	ACTION 'FN693ADEL'			OPERATION  5 	ACCESS 0   //"Estornar Fatura"
ADD OPTION aRotina TITLE STR0122	ACTION 'FINR677'			OPERATION 13 	ACCESS 0   //"Relatório"

// Ponto de entrada para acrescentar botões no menu
If ExistBlock('F677USERMENU')   
      aUserMenu := ExecBlock( 'F677USERMENU')
      If ValType( aUserMenu ) == 'A'
            aEval( aUserMenu, { |aAux| aAdd( aRotina, aAux ) } )
      EndIf
EndIf

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel	:= NIL
Local oStr1		:= FWFormStruct(1,'FLF')
Local oStr2		:= FWFormStruct(1,'FLE')
Local oStr3		:= FWFormStruct(1,'FLD')
Local oStr4		:= FWFormStruct(1,'FLF')
Local oStr5		:= FWFormStruct(1,'FO7')
Local cMoedD	:= cValToChar(f677GetMoeda(1))
Local cMoedE	:= cValToChar(f677GetMoeda(2)) 
Local cSimbM1	:= Iif( SUPERGETMV("MV_SIMB1", .F., "1") == "", "1" , SUPERGETMV("MV_SIMB1", .F., "1"))
Local cSimbM2	:= Iif( SUPERGETMV("MV_SIMB" + cMoedD, .F., "2") == "", "2" , SUPERGETMV("MV_SIMB" + cMoedD, .F., "2"))
Local cSimbM3	:= Iif( SUPERGETMV("MV_SIMB" + cMoedE, .F., "3") == "", "3" , SUPERGETMV("MV_SIMB" + cMoedE, .F., "3"))
Local lMobile	:= IsInCallStack('NewXPense') .or. IsInCallStack('NewItem') .or. IsInCallStack('UpdXpense') .or. IsInCallStack('DelXpense') .or. IsInCallStack('DelItem')


oModel := MPFormModel():New('FINA677',,{||F677TUDOOK()},{ |oModel| F677AGRVMD( oModel ) })
oModel:SetDescription(STR0001) //"Prestação de Contas"

oModel:addFields('FLFMASTER',,oStr1,,{||F677VALFLF()},)
//	Criando campos Virtuais para tratar os Anexos
If __nOper  != MODEL_OPERATION_DELETE
	AddFieldV(1, oStr2, "FLE_STATUS")
	AddFieldV(1, oStr2, "FLE_ANEXO")
	AddFieldV(1, oStr2, "FLE_FILE")
	AddFieldV(1, oStr2, "FLE_RECNO")
EndIf
oModel:addGrid('FLEDETAIL','FLFMASTER',oStr2,,{||F677LPOS()},,{||F677DETOK()})
oModel:addGrid('FLDDETAIL','FLFMASTER',oStr3,,,,,)
oModel:addGrid('AUXDETAIL','FLFMASTER',oStr4)
oModel:AddGrid('FO7DETAIL','FLFMASTER',oStr5)

oModel:SetRelation('FLDDETAIL', { { 'FLD_FILIAL', 'FLF_FILIAL' }, { 'FLD_VIAGEM', 'FLF_VIAGEM' }, { 'FLD_PARTIC', 'FLF_PARTIC' } }, FLD->(IndexKey(1)) )
oModel:SetRelation('FLEDETAIL', { { 'FLE_FILIAL', 'xFilial("FLE")' }, { 'FLE_TIPO', 'FLF_TIPO' }, { 'FLE_PRESTA', 'FLF_PRESTA' }, { 'FLE_PARTIC', 'FLF_PARTIC' } }, FLE->(IndexKey(1)) )
oModel:SetRelation('AUXDETAIL', { { 'FLF_FILIAL', 'FLF_FILIAL' }, { 'FLF_TIPO', 'FLF_TIPO' }, { 'FLF_PRESTA', 'FLF_PRESTA' }, { 'FLF_PARTIC', 'FLF_PARTIC' } }, FLF->(IndexKey(1)) )
oModel:SetRelation('FO7DETAIL', { { 'FO7_FILIAL', 'xFilial("FO7")'},{'FO7_TPVIAG','FLF_TIPO'},{'FO7_PRESTA','FLF_PRESTA'},{'FO7_PARTIC','FLF_PARTIC'}}, FO7->(IndexKey(2)))

oModel:getModel('FLFMASTER'):SetDescription(STR0001) //"Prestação de Contas"
oModel:getModel('FLEDETAIL'):SetDescription('FLEDETAIL')
oModel:getModel('AUXDETAIL'):SetDescription('AUXDETAIL')
oModel:getModel('FLDDETAIL'):SetOnlyQuery(.T.)

oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLDDETAIL', 'FLD_VALAPR', 'ADIANT1', 'SUM', {|oModel| F677Moeda(oModel,'1',"FLD")}, /*bInitValue*/,STR0022+" "+cSimbM1  /*cTitle*/, /*bFormula*/) // "Adiantam."//"(R$)"
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_TOTAL', 'TOTAL1'  , 'SUM', {|oModel| F677Moeda(oModel,'1',"FLE")}, /*bInitValue*/,STR0023+" "+cSimbM1 /*cTitle*/, /*bFormula*/) //'Despesas (R$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_VALREE', 'VALREE1', 'SUM', {|oModel| F677Moeda(oModel,'1',"FLE")}, /*bInitValue*/,STR0024+" "+cSimbM1 /*cTitle*/, /*bFormula*/) //'Reembols. (R$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_DESCON', 'DESCON1', 'SUM', {|oModel| F677Desco(oModel,'1',"FLE")}, /*bInitValue*/,STR0025+" "+cSimbM1 /*cTitle*/, /*bFormula*/) //'Desconto (R$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'AUXDETAIL', 'FLF_TDESP1', 'SALDO1', 'FORMULA', /*bCondition*/, /*bInitValue*/,STR0026+" "+cSimbM1 /*cTitle*/, {|oModel| F677SALDO(oModel,'1')} /*bFormula*/)

oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLDDETAIL', 'FLD_VALAPR', 'ADIANT2', 'SUM', {|oModel| F677Moeda(oModel,'2|9',"FLD")}, /*bInitValue*/,STR0022+" "+cSimbM2 /*cTitle*/, /*bFormula*/) //'Adiantam. (US$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_TOTAL', 'TOTAL2'  , 'FORMULA', /*bCondicao*/, /*bInitValue*/,STR0023+" "+cSimbM2  /*cTitle*/,{|oModel| F677SUMUSD(oModel,'FLE_TOTAL')}) //'Despesas (US$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_VALREE', 'VALREE2', 'SUM', {|oModel| F677Moeda(oModel,'2|9',"FLE")}, /*bInitValue*/,STR0024+" "+cSimbM2  /*cTitle*/, /*bFormula*/) //'Reembols. (US$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_DESCON', 'DESCON2', 'SUM', {|oModel| F677Desco(oModel,'2|9',"FLE")}, /*bInitValue*/,STR0025+" "+cSimbM2  /*cTitle*/, /*bFormula*/) //'Desconto (US$)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'AUXDETAIL', 'FLF_TDESP2', 'SALDO2', 'FORMULA', /*bCondicao*/, /*bInitValue*/,STR0026+" "+cSimbM2  /*cTitle*/, {|oModel| F677SALDO(oModel,'2')}) //'Saldo (US$)'

oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLDDETAIL', 'FLD_VALAPR', 'ADIANT3', 'SUM', {|oModel| F677Moeda(oModel,'3',"FLD")}, /*bInitValue*/,STR0022+" "+cSimbM3 /*cTitle*/, /*bFormula*/) //'Adiantam. (€)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_TOTAL', 'TOTAL3'  , 'SUM', {|oModel| F677Moeda(oModel,'3',"FLE")}, /*bInitValue*/,STR0023+" "+cSimbM3 /*cTitle*/, /*bFormula*/) //'Despesas (€)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_VALREE', 'VALREE3', 'SUM', {|oModel| F677Moeda(oModel,'3',"FLE")}, /*bInitValue*/,STR0024+" "+cSimbM3 /*cTitle*/, /*bFormula*/) //Reembols. (€)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'FLEDETAIL', 'FLE_DESCON', 'DESCON3', 'SUM', {|oModel| F677Desco(oModel,'3',"FLE")}, /*bInitValue*/,STR0025+" "+cSimbM3 /*cTitle*/, /*bFormula*/) //'Desconto (€)'
oModel:AddCalc( 'TOTAL', 'FLFMASTER', 'AUXDETAIL', 'FLF_TDESP3', 'SALDO3', 'FORMULA', /*bCondicao*/, /*bInitValue*/,STR0026+" "+cSimbM3/*cTitle*/, {|oModel| F677SALDO(oModel,'3')}) //'Saldo (€)'

oModel:getModel('FLEDETAIL'):SetOptional(.T.)
oModel:getModel('FLEDETAIL'):SetUniqueLine( {"FLE_ITEM"} )
oModel:getModel('FLDDETAIL'):SetOptional(.T.)
oModel:getModel('AUXDETAIL'):SetOptional(.T.)
oModel:getModel('FO7DETAIL'):SetOptional(.T.)
oModel:getModel('FLDDETAIL'):SetNoInsertLine( .T. )
oModel:getModel('FLDDETAIL'):SetNoUpdateLine( .T. )
oModel:getModel('FLDDETAIL'):SetNoDeleteLine( .T. )
oModel:getModel('AUXDETAIL'):SetOnlyQuery(.T.)

If lAuto .or. lAutomato
	oStr1:SetProperty('*' , MODEL_FIELD_WHEN , {|| .T. } )
Else

	oStr3:AddField(STR0030,STR0030,"FLDSTATUS","C",16,0,{|| .T.},NIL,{},NIL,FwBuildFeature( STRUCT_FEATURE_INIPAD,"F667STATUS(FLD->FLD_STATUS)"),NIL,NIL,.T.) // "Status"

	If __nOper == OPER_CONFER
		oStr1:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
		oStr1:SetProperty('FLF_OBCONF' , MODEL_FIELD_WHEN , {|| .T. } )
		oStr1:SetProperty('FLF_FATCLI' , MODEL_FIELD_WHEN , {|| .T. } )
		oStr1:SetProperty('FLF_FATEMP' , MODEL_FIELD_WHEN , {|| .T. } )

		oStr2:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )

		oStr2:SetProperty('FLE_DESCON' , MODEL_FIELD_WHEN , {|| .T. } )
		oStr2:SetProperty('FLE_DETDES' , MODEL_FIELD_WHEN , {|| .T. } )

		oModel:getModel('FLEDETAIL'):SetNoInsertLine( .T. )
		oModel:getModel('FLEDETAIL'):SetNoDeleteLine( .T. )

	Else
		oStr1:SetProperty('FLF_OBCONF' , MODEL_FIELD_WHEN , {|| .F. } )
		oStr2:SetProperty('FLE_DESCON' , MODEL_FIELD_WHEN , {|| .F. } )
		oStr2:SetProperty('FLE_DETDES' , MODEL_FIELD_WHEN , {|| .F. } )
		If lMobile	// Se vem do app, permite edicao
			lWhenItem := .T.
		EndIf
		oStr2:SetProperty('FLE_ITEM' , MODEL_FIELD_WHEN , {|| lWhenItem } )
		oStr2:SetProperty('FLE_TOTAL' , MODEL_FIELD_WHEN , {|| F677When(oModel,'FLE_TOTAL') } )
		oStr2:SetProperty('FLE_TXCONV' , MODEL_FIELD_WHEN , {|| F677When(oModel,'FLE_TXCONV') } )
		oStr2:SetProperty('FLE_LOCAL' , MODEL_FIELD_WHEN , {|| F677When(oModel,'FLF_NACION') } ) 
		oStr2:SetProperty('FLE_DESPES' , MODEL_FIELD_WHEN , {|| F677When(oModel,'FLE_LOCAL') } )
		If cPaisLoc == "MEX"
			oStr2:SetProperty('FLE_UUID' , MODEL_FIELD_WHEN , {|| F677When(oModel,'FLE_UUID') } )
		EndIf
	EndIf

	oStr1:SetProperty( "FLF_PARTIC",	MODEL_FIELD_INIT,	{|| aUser[1] }  )
	oStr1:SetProperty('FLF_DSCLVL' ,	MODEL_FIELD_INIT	,{|oModel| Posicione("CTH",1,xFilial("CTH")+oModel:GetValue("FLF_CLVL"),"CTH_DESC01") })
	oStr1:SetProperty('FLF_DSITCT' ,	MODEL_FIELD_INIT	,{|oModel| Posicione("CTD",1,xFilial("CTD")+oModel:GetValue("FLF_ITECTA"),"CTD_DESC01")})
	//
	oStr2:AddTrigger( "FLE_QUANT",		"FLE_TOTAL",		{|| .T. }, {|| F677QUANT() }  )
	oStr2:AddTrigger( "FLE_MOEDA",		"FLE_MOEDA",		{|| .T. }, {|| F677TxMoed()}  )
	oStr2:AddTrigger( "FLE_DESPES",		"FLE_VALUNI",		{|| .T. }, {|| F677VALUNI() }  )
	oStr2:AddTrigger( "FLE_DESPES",		"FLE_CONTA",		{|| .T. }, {|| F677BCENT('1') }  )
	oStr2:AddTrigger( "FLE_DESPES",		"FLE_CUSTO",		{|| .T. }, {|| F677BCENT('2') }  )
	oStr2:AddTrigger( "FLE_DESPES",		"FLE_ITECTB",		{|| .T. }, {|| F677BCENT('3') }  )
	oStr2:AddTrigger( "FLE_DESPES",		"FLE_CLVL",		{|| .T. }, {|| F677BCENT('4') }  )						
	oStr2:AddTrigger( "FLE_DATA",		"FLE_VALUNI",		{|| .T. }, {|| F677VALUNI() }  )
	
	If	__nOper == OPER_ENVWF
		oModel:lModify := .T.
	EndIf
	
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel 		:= ModelDef()
Local oStr1		:= FWFormStruct(2, 'FLF')
Local oStr2		:= FWFormStruct(2, 'FLE')
Local oStr3		:= FWFormStruct(2, 'FLD')
Local oStr4		:= FWCalcStruct( oModel:GetModel('TOTAL') )
Local oStr5 	:= FWFormStruct(2, 'FO7')


oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FLFMASTER' , oStr1,'FLFMASTER' )
oView:AddGrid('FLEDETAIL' , oStr2,'FLEDETAIL')

//	Adicionando os Campos Virtuais na Grid
If __nOper  != MODEL_OPERATION_DELETE
	AddFieldV(2, oStr2, "FLE_ANEXO" , 2)
	oView:SetViewProperty("FLEDETAIL", "ENABLENEWGRID")
	oView:SetViewProperty("FLEDETAIL", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| DbClick(oFormulario, cFieldName, nLineGrid, nLineModel)}})
Endif

oView:CreateHorizontalBox( 'BOXFORM1', 26)
oView:CreateHorizontalBox( 'DETAIL', 51)

oView:CreateFolder( 'FOLDER', 'DETAIL')
oView:AddSheet('FOLDER','DESPES',STR0023) // "Despesas"

oView:AddGrid('FLDDETAIL' , oStr3,'FLDDETAIL')
oView:AddSheet('FOLDER','ADIANT',STR0031)  //"Adiantamento"

oView:AddSheet('FOLDER','TITULOS',STR0161) //"Financeiro"
oView:AddGrid('VIEWFO7', oStr5	 ,'FO7DETAIL')

oStr3:RemoveField( 'FLD_PARCEL' )
oStr3:RemoveField( 'FLD_TITULO' )
oStr3:RemoveField( 'FLD_TIPO' )
oStr3:RemoveField( 'FLD_PREFIX' )
oStr3:RemoveField( 'FLD_LOJA' )
oStr3:RemoveField( 'FLD_FORNEC' )
oStr3:RemoveField( 'FLD_OBSAPR' )
oStr3:RemoveField( 'FLD_NOMEAP' )
oStr3:RemoveField( 'FLD_APROV' )
oStr3:RemoveField( 'FLD_NOMESO' )
oStr3:RemoveField( 'FLD_SOLIC' )
oStr3:RemoveField( 'FLD_NOMEPA' )
oStr3:RemoveField( 'FLD_PARTIC' )
oStr3:RemoveField( 'FLD_ITEM' )
oStr3:RemoveField( 'FLD_STATUS' )
//Remove campos do detail FO7.
oStr5:RemoveField('FO7_CODIGO')
oStr5:RemoveField('FO7_PRESTA')
oStr5:RemoveField('FO7_TPVIAG')
//
oStr3:AddField( 'FLDSTATUS','1',STR0030,STR0030,, 'Get',,,,.F.,,,,,,.T. ) // "Status"
oStr3:RemoveField( 'FLD_VIAGEM' )
oView:CreateHorizontalBox( 'BOXFORM10', 100,, , 'FOLDER', 'ADIANT')

oView:SetOwnerView('FLDDETAIL','BOXFORM10')
//
oView:CreateHorizontalBox( 'BOXTIT', 100,, , 'FOLDER', 'TITULOS')
oView:SetOwnerView('VIEWFO7','BOXTIT')
oView:SetViewProperty('VIEWFO7' , 'ONLYVIEW' )
oView:EnableTitleView('VIEWFO7' , STR0162 ) 
//
oView:SetViewProperty('FLDDETAIL' , 'ONLYVIEW' )
oView:EnableTitleView('FLDDETAIL' , STR0031)  //"Adiantamento"

oStr2:RemoveField( 'FLE_PARTIC' )
oStr2:RemoveField( 'FLE_PRESTA' )
oStr2:RemoveField( 'FLE_VALUNI' )
oStr2:RemoveField( 'FLE_TIPO' )
oStr2:RemoveField( 'FLE_LA' )
//
oStr2:SetProperty("FLE_LOCAL" , MVC_VIEW_ORDEM , StrZero(Val(oStr2:GetProperty("FLE_DESPES", MVC_VIEW_ORDEM)) - 1,2) ) 
//
oView:CreateHorizontalBox( 'BOXFORM8', 100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'DESPES')

oView:SetOwnerView('FLFMASTER','BOXFORM1')
oView:SetOwnerView('FLEDETAIL','BOXFORM8')

oView:EnableTitleView('FLFMASTER' , STR0001) // "Prestação de Contas"
oView:EnableTitleView('FLEDETAIL' , STR0023) // "Despesas"

oStr1:RemoveField('FLF_TDESP1')
oStr1:RemoveField('FLF_TVLRE1')
oStr1:RemoveField('FLF_TDESP2')
oStr1:RemoveField('FLF_TVLRE2')
oStr1:RemoveField('FLF_TDESP3')
oStr1:RemoveField('FLF_TVLRE3')
oStr1:RemoveField('FLF_TDESC1')
oStr1:RemoveField('FLF_TDESC2')
oStr1:RemoveField('FLF_TDESC3')
oStr1:RemoveField('FLF_TADIA1')
oStr1:RemoveField('FLF_TADIA2')
oStr1:RemoveField('FLF_TADIA3')
oStr1:RemoveField('FLF_MOTVFL')
oStr1:RemoveField('FLF_RECPAG')
oStr1:RemoveField('FLF_TIPTIT')
oStr1:RemoveField('FLF_TITULO')
oStr1:RemoveField('FLF_PARCEL')
oStr1:RemoveField('FLF_CLIFOR')
oStr1:RemoveField('FLF_FLOJA')
oStr1:RemoveField('FLF_PREFIX')
oStr1:RemoveField('FLF_DTBAIX')
oStr1:RemoveField('FLF_DOC')
oStr1:RemoveField('FLF_SERIE')

oView:AddIncrementField('FLEDETAIL', 'FLE_ITEM' )

oView:AddField('TOTALIZADOR', oStr4,'TOTAL')
oView:CreateHorizontalBox( 'TOTAL', 23,,.F.)
oView:CreateVerticalBox( 'BOXFORM9', 100, 'TOTAL')
oView:SetOwnerView('TOTALIZADOR','BOXFORM9')

oView:EnableTitleView('TOTALIZADOR' , STR0032) //"Totalizador"

oView:SetFieldAction('FLF_CLVL', {|oView, cIDView, cField, xValue| F677DesCtb(oView, cIDView, cField, xValue)})
oView:SetFieldAction('FLF_ITECTA', {|oView, cIDView, cField, xValue| F677DesCtb(oView, cIDView, cField, xValue)})

If !lAuto
	oModel:SetVldActivate( {|oModel| F677AVLMod(oModel) } )
	oModel:SetActivate( {|oModel| F677LoadMod(oModel) } )
EndIf

oView:SetCloseOnOk({||.T.})

If  __nOper == OPER_CONFER
	oView:AddUserButton( STR0033, 'OK', {|oView| F677REPROVA(oView) } )	 // "Reprovar"
EndIf

If  __nOper == OPER_FINMX
	oView:AddUserButton( IIF(__lBTNEstornar,STR0098,STR0034), 'OK', {|oView|  F677CONFMX(oView) } )	 // "Confirmar"//"Estornar
EndIf


If  __nOper == OPER_ALTERA .Or.  __nOper == OPER_INCLUI .Or.  __nOper == OPER_CONFER
	oView:AddUserButton(STR0100, 'OK', {|oView|  F677RECALC(oView) } )	// "Recalcula"
EndIf

If __nOper == OPER_ALTERA
	oView:AddUserButton(STR0179, "OK", {|oView| F677AltSrNt(oView) } )	//STR0179 "Alt. Serie e Nota"
EndIf

If  __nOper == OPER_LIBFIN
	oView:AddUserButton( STR0084, 'OK', {|oView|  F677LibOK(oView,.F.) } )	// "Liberar Finaceiro"
	oView:AddUserButton( STR0115, 'OK', {|oView|  F677LibOK(oView,.T.) } )	// "Abonar"
EndIf

//Habilita opção para o substituto da prestação de contas alterar o viajante da avulsa
If __nOper == OPER_INCLUI
	If RD0->(FieldPos("RD0_USRPRE")) > 0
		oView:AddUserButton( "Alt. Viajante", 'OK', {|oView|  F677AltVjt(oView) } )	
	EndIf
EndIf

oView:AddUserButton(STR0186, 'OK', {|oView| BrwLegenda(,, __aLegendaItem)})	//	###"Legendas"
//If __nOper <> OPER_INCLUI  
	//oView:AddUserButton(STR0180, 'OK', {|oView| F677Doc(oView)}) //	###"Todos Comprovantes"
//EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F667FilBrowse
Filtro da Browse

@author Jose Domingos

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F677FilBrowse (cFiltro)


Local cUsuarios	:= ""
Local cStatus		:= ""
Local cParticDe	:= PAD(" ", Len(FLF->FLF_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local cParticAte	:= PAD("ZZ", Len(FLF->FLF_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local nParCont	:= 0
Local nX			:= 0
Local nY			:= 0
Local lContinua 	:= .T.
Local lTodos		:= .F.
Local aPerguntas	:= {}
Local aUsers		:= {}
Local aUserCft	:= {}
Local aParam		:= {}
Local dDataIni	:= FirstDay(dDataBase)
Local dDataFim	:= LastDay(dDataBase)
Local lF677Fil 		:= ExistBlock("F677FilBrw")

DEFAULT cFiltro := ""

//Valida acesso do usuário
aUsers := FN683PARTI()

//Usuario sem qualquer acesso
If Alltrim(aUsers[1]) == "NO"
	Help("  ",1,"NO_ACCESSS_677",,STR0041,1,0) // "Usuário sem acesso para manipular adiantamentos de viagem."
	lContinua := .F.
ElseIf Alltrim(aUsers[1]) == "ALL"
	lTodos := .T.
Else
	dbSelectArea("RD0")
	aAreaRD0 := RD0->(GetArea())
	RD0->(dbSetOrder(1))
	
	For nX := 1 to Len(aUsers)
		cUsuarios += Alltrim(aUsers[nX])+"|"
		
		//Valida se o usuário possui um substituto para a prestação de contas, e permite o acesso
		aUserCft := F677GetUPC(aUsers[nX])
		For nY := 1 to Len(aUserCft)	
			cUsuarios += Alltrim(aUserCft[nY]) +"|" //seta o participante do qual ele é substituto para a prestação de contas
		Next nY

	Next nX
Endif

If lContinua
	aPerguntas := { { 1, STR0035	, cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;
					{ 1, STR0036	, cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;
					{ 1, STR0037 	, dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;
					{ 1, STR0038	, dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.},;
					{ 9, STR0030    , 100, 12 , .T. },;
					{ 5, STR0002	, .T., 100,, .T. },;
					{ 5, STR0003	, .T., 100,, .T. },;
					{ 5, STR0004	, .T., 100,, .T. },;
					{ 5, STR0005	, .T., 100,, .T. },;
					{ 5, STR0006	, .T., 100,, .T. },;
					{ 5, STR0007	, .T., 100,, .T. },;
					{ 5, STR0008	, .T., 100,, .T. },;
					{ 5, STR0009	, .T., 100,, .T. },;
					{ 5, STR0010    , .T., 100,, .T. }}

	lContinua := ParamBox( aPerguntas,STR0039+" - "+STR0001,aParam,{||.T.},,,,,,FunName(),.T.,.T.) //"Parâmetros"//"Prestação de Contas"

	//-----------------------------------------------------------
	// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
	//-----------------------------------------------------------
	If lContinua
		For nParCont := 1 To Len(aParam)
			&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
		Next nParCont

		cParticDe	:= mv_par01
		cParticAte	:= mv_par02
		dDataIni	:= mv_par03
		dDataFim	:= mv_par04

		//Valida se selecionou algum Status para filtro
		//Caso contrário, sai da rotina
		If !mv_par06 .and. !mv_par07 .and.!mv_par08 .and.!mv_par09 .and.!mv_par10 .and.!mv_par11 .and.!mv_par12 .and. !mv_par13 .and. !mv_par14
			cFiltro := ""
			lContinua := .F.
		Endif
	Endif

Endif

If lContinua

	//Participantes De/Até
	//Usuario tem acesso irrestrito
	If lTodos
		cFiltro := "FLF_PARTIC >= '"+ cParticDe + "' .and. FLF_PARTIC <= '"+ cParticAte + "' .and. "
	Else
		cFiltro := "FLF_PARTIC $ '" + cUsuarios + "' .and. "
	Endif

	//Datas de inicio da viagem
	cFiltro += "DTOS(FLF_DTINI) >= '"+ DTOS(dDataIni) + "' .and. "
	cFiltro += "DTOS(FLF_DTINI) <= '"+ DTOS(dDataFim) + "' "

	/*/
		Status:
		1 = Em aberto
		2 = Em conferência
		3 = Com bloqueio
		4 = Em avaliação
		5 = Reprovada
		6 = Aprovada
		7 = Liberado pagto
		8 = Finalizada
		9 = Faturada
	/*/

	//Se não forem selecionados todos os status, avalio cada um deles
	If !(mv_par06 .and. mv_par07 .and. mv_par08 .and. mv_par09 .and. mv_par10 .and. mv_par11 .and. mv_par12 .and.  mv_par13 .and.  mv_par14)

		If mv_par06
			cStatus += "1|"
		Endif

		If mv_par07
			cStatus += "2|"
		Endif

		If mv_par08
			cStatus += "3|"
		Endif

		If mv_par09
			cStatus += "4|"
		Endif

		If mv_par10
			cStatus += "5|"
		Endif

		If mv_par11
			cStatus += "6|"
		Endif

		If mv_par12
			cStatus += "7|"
		Endif

		If mv_par13
			cStatus += "8|"
		Endif

		If mv_par14
			cStatus += "9|"
		Endif

		//Monta a expressao de filtro
		If !Empty(cStatus)
			If !Empty(cFiltro)
				cFiltro += " .and. "
			Endif
			cFiltro += "FLF_STATUS $ '"+ cStatus+"' "
		Endif
	Endif
	
	If lF677Fil
		 cFiltro := ExecBlock("F677FilBrw",.F.,.F.,{cFiltro})
	EndIf
	
Endif

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} F677LoadMod
Carrega o Model

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F677LoadMod(oModel,nOper)

Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local oModelFO7		:= oModel:GetModel("FO7DETAIL")
Local aSaveLines	:= {}
Local nX			:= 0
Local cChave := ""
Local lMobile		:= IsInCallStack('NewXPense') .or. IsInCallStack('NewItem') .or. IsInCallStack('UpdXpense') .or. IsInCallStack('DelXpense') .or. IsInCallStack('DelItem')

Default nOper		:= 0

If nOper <> 0
	__nOper := nOper
EndIf

If Empty(aUser) .OR. lMobile // Não remover o lMobile: thread no rest não finaliza e a variável static aUser mantém o primeiro usuario que acessou a thread se não tiver o registro vai cair para outro usuário.
	FINXUser(__cUserId,@aUser,.T.)
Endif

If __nOper == OPER_INCLUI

	If lMobile	// Se vem do app, ativa o model
		oModel:Activate()
	EndIf
	oModel:LoadValue('FLFMASTER','FLF_NOMEPA' , aUser[2] )

Else
	
	For nX := 1 To oModelFO7:Length()
	
		oModelFO7:SetLine( nX )
		//
		If !Empty(oModelFO7:GetValue('FO7_RECPAG'))
			If oModelFO7:GetValue('FO7_RECPAG') == 'P' //Pagar.
				oModelFO7:LoadValue('FO7_NOME',Posicione("SA2",1,xFilial("SA2") + oModelFO7:GetValue("FO7_CLIFOR") + oModelFO7:GetValue("FO7_LOJA"),"A2_NOME"))
			Else //Receber.
				oModelFO7:LoadValue('FO7_NOME',Posicione("SA1",1,xFilial("SA1") + oModelFO7:GetValue("FO7_CLIFOR") + oModelFO7:GetValue("FO7_LOJA"),"A1_NOME"))
			EndIf
		EndIf
	
	Next nX
EndIf

//	Carga dos Campos Virtuais conforme os registros gravados
If oModel:GetOperation() <> MODEL_OPERATION_DELETE .And. __nOper != OPER_INCLUI
	aSaveLines  := FWSaveRows()
	For nX := 1 To oModelFLE:Length()
		oModelFLE:GoLine(nX)
		If !oModelFLE:IsDeleted() .And. !Empty(oModelFLE:GetValue('FLE_PRESTA'))
			cChave := PosMsDoc("FLE", oModelFLE)[1]
			oModelFLE:LoadValue('FLE_STATUS', Iif(AC9->(Eof()), "3", "4"))	//	3=Gravado; 4=Gravado com Anexo
			oModelFLE:LoadValue('FLE_ANEXO' , Iif(oModelFLE:GetValue('FLE_STATUS') == "3", " ", "CLIPS"))
			oModelFLE:LoadValue('FLE_RECNO' , FLE->(Recno()))
		EndIf
	Next
	FWRestRows(aSaveLines)
EndIf

If __nOper == OPER_ALTERA .And. lEstorna
	aSaveLines  := FWSaveRows()
	For nX := 1 To oModelFLE:Length()
		oModelFLE:GoLine( nX )
		If !oModelFLE:IsDeleted()
			oModelFLE:LoadValue('FLE_DESCON' , 0 )
			oModelFLE:LoadValue('FLE_DETDES' , "" )
   		Endif
   	Next
   	FWRestRows(aSaveLines)
	lEstorna := .F.
EndIf

If __nOper == OPER_CONFER
	oModel:LoadValue('FLFMASTER','FLF_OBCONF' , Space(TamSx3("FLF_PRESTA")[1]) )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F667AVLMod
Inicializador do Model

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F677AVLMod(oModel)

Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local cUserConf		:= ""
Local aAreaRD0		:= {}
Local cWfId			:= ""
Local lFa677UPr		:= .T.	

If  (__nOper == 0 .And. nOperation == MODEL_OPERATION_DELETE) .Or. __nOper == OPER_ALTERA;
	 .Or. __nOper == OPER_INCLUI .Or. __nOper == OPER_CONFER

	If Empty(aUser)
		lRet := FINXUser(__cUserId,@aUser,.T.)
	Endif

	If lRet .And. ((__nOper == 0 .And. nOperation == MODEL_OPERATION_DELETE) .Or. __nOper == OPER_ALTERA)
		dbSelectArea("RD0")
		RD0->(dbSetOrder(1))
		aAreaRD0 := RD0->(GetArea())
		
		If RD0->(dbSeek(xFilial("RD0")+FLF->FLF_PARTIC))	
			cUserConf := RD0->RD0_USRPRE //seta um usuário substituto para a prestação, caso o participante não faça a própria prestação de contas
		EndIf
		
		If ExistBlock("FA677UPR")
			lFa677UPr := ExecBlock("FA677UPR",.F.,.F.)
		EndIf
		
		RD0->(RestArea(aAreaRD0))
		//Somente o viajante ou usuário substituto associado à ele podem efetuar a prestação de contas do participante
		If (aUser[1] <> FLF->FLF_PARTIC) .And. (Empty(cUserConf) .Or. (!Empty(cUserConf) .And. aUser[1] <> cUserConf)) 
			If !lFa677UPr
				lRet := .F.
				Help(" ",1,"F677PCDEL",,STR0043 ,1,0) 
			EndIf
		EndIf
		
		If nOperation == MODEL_OPERATION_DELETE .AND. (FLF->FLF_STATUS != "1" .OR. FLF->FLF_TIPO != '2')
			lRet := .F.
			Help(" ",1,"F677PCDEL",,STR0166 ,1,0) 
		EndIf
	EndIf
EndIf

If lRet .And. ((nOperation == MODEL_OPERATION_DELETE  .AND. __nOper == 0) .AND. FLF->FLF_STATUS != "1")	//Status = Em aberto
	Help(" ",1,"F677ADTDEL",,STR0044 ,1,0) // "Não é possivel excluir prestação de contas com esse status."
	lRet := .F.
EndIf

If lRet .And. __nOper == OPER_ALTERA
	If  !(FLF->FLF_STATUS $ "1|4|5|6")	//Status = Em aberto, Em Avaliação, Reprovada, Aprovada
		Help(" ",1,"F677ADTDEL",,STR0045 ,1,0) // "Não é possivel alterar prestação de contas com esse status."
		lRet := .F.
	ElseIf FLF->FLF_STATUS $ "4|5|6"
		If MsgYesNo(STR0046) // "Esta operação irá estornar todo o processo de aprovações e a prestação voltará para o status em aberto. Deseja continuar?"
			lEstorna := .T.
			cWfId := FLF->FLF_WFKID
			If !Empty(cWfId) .AND. !MsgYesNo(STR0169)
				Help(" ",1,"F677NOALT",,STR0047 ,1,0) //"Alteração cancelada."
				lRet 	 := .F.
				lEstorna := .F.
			Endif
		Else
			Help(" ",1,"F677NOALT",,STR0047 ,1,0) //"Alteração cancelada."
			lRet := .F.
		Endif
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} F677VALUNI
Pesquisa Valor Unitário no tipo de despesa

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677VALUNI()

Local aArea			:= GetArea()
Local oModel		:= FWModelActive()
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local cDespesa		:= oModelFLE:GetValue("FLE_DESPES")
Local dData			:= oModelFLE:GetValue("FLE_DATA")
Local nValUnit		:= 0
Local cAliasTrb		:= GetNextAlias()
Local cVazio		:= ' '

DbSelectArea("FLS")
BeginSql Alias cAliasTrb
	SELECT FLS_VALUNI VALUNI
	FROM %table:FLS% FLS
  	WHERE FLS_FILIAL = %xFilial:FLS%
   		AND FLS_CODIGO = %exp:cDespesa%
   		AND FLS_DTINI <= %exp:dData%
   		AND (FLS_DTFIM >= %exp:dData% OR FLS_DTFIM = %exp:cVazio%)
   		AND FLS.%notDel%
EndSql

If (cAliasTrb)->(!Eof()) .And. (cAliasTrb)->VALUNI > 0
	nValUnit := (cAliasTrb)->VALUNI
EndIf

If ( Select(cAliasTrb) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf

RestArea(aArea)

Return nValUnit

/*/{Protheus.doc} F677Moeda
Validação da Moeda

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677Moeda(oModel,cMoeda,cTabela)

Local lRet 			:= .T.
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local oModelFLD		:= oModel:GetModel("FLDDETAIL")

If cTabela == "FLE"
	lRet := oModelFLE:GetValue("FLE_MOEDA") $ cMoeda
ElseIf cTabela == "FLD"
	lRet := oModelFLD:GetValue("FLD_MOEDA") $ cMoeda .And. oModelFLD:GetValue("FLD_STATUS") == "4"
EndIf

Return lRet



/*/{Protheus.doc} F677Desco
Condição para totalizador do desconto

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677Desco(oModel,cMoeda,cTabela)

Local lRet 			:= .F.

If !(__nOper == OPER_ALTERA)
	lRet := F677Moeda(oModel,cMoeda,cTabela)
EndIf

Return lRet

/*/{Protheus.doc} F677SALDO
Fornula do Saldo

@author Jose Domingos
@since 23/10/2013
@version 1.0
/*/
Function F677SALDO(oModel,cMoeda)

Local nRet				:= 0
Local oModelTotal		:= oModel:GetModel("TOTAL")

If cMoeda == '1'
	nRet := (oModelTotal:GetValue("VALREE1") - oModelTotal:GetValue("DESCON1")) - oModelTotal:GetValue("ADIANT1")
ElseIf cMoeda == '2'
	nRet := (oModelTotal:GetValue("VALREE2") - oModelTotal:GetValue("DESCON2")) - oModelTotal:GetValue("ADIANT2")
ElseIf cMoeda == '3'
	nRet := (oModelTotal:GetValue("VALREE3") - oModelTotal:GetValue("DESCON3")) - oModelTotal:GetValue("ADIANT3")
EndIf

Return nRet

/*/{Protheus.doc} F677QUANT
Validação da Quantidade

@author Jose Domingos
@since 23/10/2013
@version 1.0
/*/
Function F677QUANT()

Local oModel		:= FWModelActive()
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local nQuant		:= oModelFLE:GetValue("FLE_QUANT")
Local nValUnit		:= oModelFLE:GetValue("FLE_VALUNI")
Local nTotal		:= 0

nTotal :=  nQuant * nValUnit
lWhenTot := .T.

Return nTotal


/*/{Protheus.doc} F677When
Definição do Modo de Edição dos campos

@author Jose Domingos
@since 23/10/2013
@version 1.0
/*/
Function F677When(oModel, cCampo)

Local lRet 			:= .T.
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local lMobile		:= IsInCallStack('NewXPense') .or. IsInCallStack('NewItem') .or. IsInCallStack('UpdXpense') .or. IsInCallStack('DelXpense') .or. IsInCallStack('DelItem')

If cCampo == 'FLE_TOTAL'
	If lMobile
		lWhenTot  := .T.
	EndIf
	lRet :=  lWhenTot .Or. (oModelFLE:GetValue("FLE_VALUNI") <= 0)
	lWhenTot	:= .F.
ElseIf cCampo == 'FLE_TXCONV'
	If lMobile
		lWhenTaxa := .T.
	EndIf
	lRet := lWhenTaxa .Or. oModelFLE:GetValue("FLE_MOEDA") == '9'
	lWhenTaxa	:= .F.
ElseIf cCampo == "FLE_UUID"
	If Empty(oModelFLE:GetValue("FLE_RFC")) 
		lWhenUUID	:= .T.
	Else
		lWhenUUID	:= .F.
	EndIf
	lRet := lWhenUUID
EndIf

Return lRet

/*/{Protheus.doc} F677LPOS
Pos Validação da linha de despesa

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677LPOS()
Local lRet 			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local oModelFLF		:= oModel:GetModel("FLFMASTER")
Local cMoeda		:= oModelFLE:GetValue("FLE_MOEDA")
Local nTxRet		:= oModelFLE:GetValue("FLE_TXCONV")
Local dData			:= oModelFLE:GetValue("FLE_DATA")
Local dDtIini		:= oModelFLF:GetValue("FLF_DTINI")
Local dDtFim		:= oModelFLF:GetValue("FLF_DTFIM")
Local cUUID			:= ""
Local cRFC			:= ""
Local oView 		:= FWViewActive()

pergunte("F677REC",.F.)

If cPaisLoc == "MEX"
	cUUID		:= oModelFLE:GetValue("FLE_UUID")
	cRFC 		:= oModelFLE:GetValue("FLE_RFC")
Endif

//Valida Taxa de Conversão
If cMoeda == '9' .And. nTxRet <= 0
	Help(" ",1,"F677VLINTX",,STR0048 ,1,0) //"Informe a taxa de conversão para esta moeda."
	lRet := .F.
EndIf

If lRet .And. (dData < dDtIini .or. dData > dDtFim)
	Help(" ",1,"F677VLINDT",,STR0049,1,0) // "Informe a data das despesas dentro do período realizado."
	lRet := .F.
EndIf

If !lAutomato
	If MV_PAR01 == 1 //- AUTOMAÇÃO 
		F677RECALC(oView) //Recalcula valores na edição da linha	
	EndIf
EndIf

If cPaisLoc == "MEX"

	//Verifica se o codigo UUID foi preenchido atraves da consulta F3.
	//Somente a consulta F3 preenche o campo FLE_RFC
	If !Empty(cUUID) .And. Empty(cRFC)
		lRet	:= .F.
		Help(" ",1,"F677NODIGIT",,STR0153,1,0) // "O codigo UUID pode ser preenchido somente através da escolha de um arquivo a ser importado. Não é permitida a digitação manual."
	EndIf
	
	If lRet	 .And. !Empty(cUUID)
		lRet := F677CHUUID(cUUID)
	EndIf

EndIf

Return lRet


/*/{Protheus.doc} F677VLDESC
Valida desconto

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677VLDESC()

Local lRet 			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local nDesconto		:= oModelFLE:GetValue("FLE_DESCON")
Local nReemb		:= oModelFLE:GetValue("FLE_VALREE")

//Valida Taxa de Conversão
If nDesconto > nReemb
	Help(" ",1,"F677VLDESC",,STR0050 ,1,0) //"Valor do desconto não pode ser maio do que o valor reembolsável da despesa."
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} F677VALFLF
Pos Validação da field (cabeçalho da prestação)

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677VALFLF()

Local lRet 			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLF		:= oModel:GetModel("FLFMASTER")
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local dDtIini		:= oModelFLF:GetValue("FLF_DTINI")
Local dDtFim		:= oModelFLF:GetValue("FLF_DTFIM")
Local nFatCli		:= oModelFLF:GetValue("FLF_FATCLI")
Local nFatEmp		:= oModelFLF:GetValue("FLF_FATEMP")
Local dData 		:= cTod("  /  /  ")
Local dDataMax		:= cTod("  /  /  ")
Local dDataMin		:= cTod("31/12/49")
Local nX			:= 0
Local aSaveLines	:= {}

Local cCliente 	:= oModelFLF:GetValue("FLF_CLIENT")
Local cLoja    	:= oModelFLF:GetValue("FLF_LOJA")

If lRet .And. (dDtIini > dDtFim)
	Help(" ",1,"F677VLINDT",,STR0051,1,0) //"Período inválido. Informe as datas de Saída e Chegada corretamente."
	lRet := .F.
EndIf

If !lAuto
	If lRet  .And. __nOper == OPER_ALTERA .Or. __nOper == OPER_INCLUI
			aSaveLines  := FWSaveRows()
			For nX := 1 To oModelFLE:Length()
				oModelFLE:GoLine( nX )
				If !oModelFLE:IsDeleted()
		   			dData 		:= oModelFLE:GetValue("FLE_DATA")
		   			dDataMax	:= Iif(dData > dDataMax, dData, dDataMax)
		   			dDataMin	:= Iif(dData < dDataMin, dData, dDataMin)
		   		Endif
		   	Next
		   	FWRestRows(aSaveLines)

			If (dDataMin < dDtIini) .Or. (dDataMax > dDtFim)
				lRet := .F.
				Help(" ",1,"F677VLPERI",,STR0052,1,0)	//"Período inválido. Existem despesas fora do periodo da prestação de contas."
			EndIf
	EndIf

	If lRet .And. (nFatCli + nFatEmp) <> 100
		Help(" ",1,"F677VFPER",,STR0053,1,0) //"A soma dos percentuas relativos ao faturamento deve ser 100%."
		lRet := .F.
	EndIf
	// Validação cliente com o percentual do cliente
	If lRet .And. nFatcli > 0 .and. (empty(cCliente) .or. empty(cLoja))
		Help(" ",1,"F677CLILOJ",,STR0127,1,0) //"Cliente/Loja não preenchido. Favor Preencher 
		lRet := .F.
	EndIf
	
EndIf

Return lRet

/*/{Protheus.doc} PolitaDespesa
Função que determina a Politica de Despesa
com base no tipo e grupo de despesa

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PoliDesp(oModelFLE, dDataTot, lSemPernoite,nDias)

Local aArea			:= GetArea()

Local cMoeda		:= oModelFLE:GetValue("FLE_MOEDA")
Local dData			:= oModelFLE:GetValue("FLE_DATA")
Local cDespesa		:= oModelFLE:GetValue("FLE_DESPES")
Local cGrupo		:= oModelFLE:GetValue("FLE_GRUPO")
Local nTotal		:= oModelFLE:GetValue("FLE_TOTAL")
Local nTxRet		:= oModelFLE:GetValue("FLE_TXCONV")
Local cAliasTrb		:= GetNextAlias()
Local aSaveLines  	:= {}
Local nX		  	:= 0
Local cTpLimit		:= ""
Local nValLimite	:= 0
Local nValReemb		:= 0
Local nTotalReemb	:= 0
Local nSaldo		:= 0
Local lGrupo 		:= !Empty(cGrupo)
Local cMoedaPer		:= cMoeda
Local cVazio		:= ' '
Local dDataVig		:= ctod("  /  /  ")
Local lF677DSPLIM	:= ExistBlock('F677DSPLIM')
Local nDspLimite	:= 0 

Default nDias 		:= 1

If cMoeda <> '1'

	cMoedaPer := '2|3|9'

	//Conversao realizada somente para a moeda 9 (Outras
	If cMoeda == "9"
		If nTxRet > 0
			nTotal := Round(nTotal / nTxRet,2)
		Else
			nTotal := 0
		EndIf
	EndIf
EndIf


/*	
	0 - Sem Limite
	1 - Diario
	2 - Total
	3 - Despesa
*/

If lGrupo
	cTpLimit := GetAdvFVal("FLK","FLK_LIMITE",xFilial("FLK")+cGrupo,1,"")
	dDataVig := IIf(cTpLimit=="2",dDataTot,dData)
	If cTpLimit <> '0'
		DbSelectArea("FLT")
		BeginSql Alias cAliasTrb
			SELECT FLT_LIMITP LIMITP, FLT_LIMITS LIMITS, FLT_LIMM02 LIMM02, FLT_LIMM03 LIMM03
			FROM %table:FLT% FLT
		  	WHERE FLT_FILIAL = %xFilial:FLT%
		   		AND FLT_CODIGO = %exp:cGrupo%
		   		AND FLT_DTINI <= %exp:dDataVig%
		   		AND (FLT_DTFIM >= %exp:dDataVig% OR FLT_DTFIM = %exp:cVazio%)
		   		AND FLT.%notDel%
		EndSql
	EndIf
Else
	cTpLimit := GetAdvFVal("FLG","FLG_LIMITE",xFilial("FLG")+cDespesa,1,"")
	dDataVig := IIf(cTpLimit=="2",dDataTot,dData)
	If cTpLimit <> '0'
		DbSelectArea("FLS")
		BeginSql Alias cAliasTrb
			SELECT FLS_LIMITP LIMITP, FLS_LIMITS LIMITS, FLS_LIMM02 LIMM02, FLS_LIMM03 LIMM03
			FROM %table:FLS% FLS
		  	WHERE FLS_FILIAL = %xFilial:FLS%
		   		AND FLS_CODIGO = %exp:cDespesa%
		   		AND FLS_DTINI <= %exp:dDataVig%
		   		AND (FLS_DTFIM >= %exp:dDataVig% OR FLS_DTFIM = %exp:cVazio%)
		   		AND FLS.%notDel%
		EndSql
	EndIf
EndIf

If cTpLimit == '0' //Sem Limite
	nValReemb := nTotal
Else

	If (cAliasTrb)->(!Eof())
		If lSemPernoite
			nValLimite := (cAliasTrb)->LIMITS
		ElseIf cMoeda == '1'
			nValLimite	:= (cAliasTrb)->LIMITP
		ElseIf	cMoeda $ '2|9'
			nValLimite	:= (cAliasTrb)->LIMM02
		ElseIf cMoeda == '3'
			nValLimite	:= (cAliasTrb)->LIMM03
		EndIf

		If lF677DSPLIM
			nDspLimite := ExecBlock('F677DSPLIM',.F.,.F.,{cAliasTrb})
			If ValType(nDspLimite) == 'N'
				nValLimite := nDspLimite
			EndIf
		EndIf

		If cTpLimit == '3' //Limite por despesa
			nValReemb := Iif(nTotal < nValLimite, nTotal, nValLimite)

		ElseIf cTpLimit == '2' //Limite Total por prestação
			nValLimite := nValLimite * nDias 
			nTotalReemb	:= 0
			aSaveLines  	:= FWSaveRows()
			For nX := 1 To oModelFLE:Length()
				oModelFLE:GoLine( nX )
				If !oModelFLE:IsDeleted()
					If oModelFLE:GetValue("FLE_MOEDA") $ cMoedaPer
						If lGrupo .And. oModelFLE:GetValue("FLE_GRUPO") == cGrupo
							nTotalReemb += oModelFLE:GetValue("FLE_VALREE")
						ElseIf oModelFLE:GetValue("FLE_DESPES") == cDespesa
							nTotalReemb += oModelFLE:GetValue("FLE_VALREE")
						EndIf
					Endif
		   		Endif
		   	Next
		   	FWRestRows(aSaveLines)

			nSaldo := nValLimite - nTotalReemb
			nValReemb := Iif(nTotal < nSaldo, nTotal, nSaldo)

		ElseIf cTpLimit == '1' //Limite por dia
			nTotalReemb	:= 0
			aSaveLines  := FWSaveRows()
			For nX := 1 To oModelFLE:Length()
				oModelFLE:GoLine( nX )
				If !oModelFLE:IsDeleted()
					If oModelFLE:GetValue("FLE_MOEDA") $ cMoedaPer .And. oModelFLE:GetValue("FLE_DATA") == dData
						If lGrupo .And. oModelFLE:GetValue("FLE_GRUPO") == cGrupo
							nTotalReemb += oModelFLE:GetValue("FLE_VALREE")
						ElseIf oModelFLE:GetValue("FLE_DESPES") == cDespesa
							nTotalReemb += oModelFLE:GetValue("FLE_VALREE")
						EndIf
					Endif
		   		Endif
		   	Next
		   	FWRestRows(aSaveLines)

			nSaldo := nValLimite - nTotalReemb
			nValReemb := Iif(nTotal < nSaldo, nTotal, nSaldo)
		EndIf
	EndIf
EndIf

nValReemb := IIF(nValReemb > 0, nValReemb, 0)

oModelFLE:SetValue("FLE_VALREE", nValReemb)
oModelFLE:SetValue("FLE_VALNRE", nTotal - nValReemb)

If ( Select(cAliasTrb) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} F677DETOK
Validação geral das despesas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677DETOK()

Local lRet			:= .T.
Local oView 		:= FWViewActive()

lRet := F677RECALC(oView)

Return lRet


/*/{Protheus.doc}  F677AGRVMD
Função de gravação do modelo

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677AGRVMD(oModel As Object)

	Local oModelTotal	As Object
	Local aGravaTot		As Array
	Local nX			As Numeric
	Local lOK			As Logical
	Local lAprov 		As Logical
	Local lAproViagem	As Logical
	Local cPartic		As Character
	Local cChvFLF		As Character
	Local cUser 		As Character
	Local aUsers		As Array
	Local aAprv 		As Array
	Local cProcWF		As Character
	Local lAdtPag		As Logical
	Local lMobile		As Logical
	Local lLibFin		As Logical
	Local lGeraFLN		As Logical


	oModelTotal	:= oModel:GetModel("TOTAL")
	aGravaTot	:= {}
	nX			:= 0
	lOK			:= .T.
	lAprov 		:= .F.
	lAproViagem	:= GetMV("MV_RESAPRT") == '1'
	cPartic		:= FLF->FLF_PARTIC
	cChvFLF		:= ""
	cUser 		:= ""
	aUsers		:= {}
	aAprv 		:= FResAprov("2")//2 - Prestação de Contas
	cProcWF		:= 'APVPRESTCO'
	lAdtPag		:= .T.
	lMobile		:= IsInCallStack('NewXPense') .or. IsInCallStack('NewItem') .or. IsInCallStack('UpdXpense') .or. IsInCallStack('DelXpense') .or. IsInCallStack('DelItem')
	lLibFin		:= .F.
	lGeraFLN	:= .F.

	/*
		PCREQ-3829 Aprovação Automática
		
		aAprv[1] - Conferência (.T. or .F.)
		aAprv[2] - Aprovação Gestor (.T. or .F.)
		aAprv[3] - Lib. Financeiro (.T. or .F.)
	*/

	//Realiza a gravação do Modelo
	FWFormCommit( oModel )

	dbSelectArea('FLJ')
	dbSelectArea('RD0')

	If __nOper == OPER_ALTERA .OR. __nOper == OPER_INCLUI .OR. __nOper == OPER_CONFER

		aAdd(aGravaTot,{'TOTAL1','FLF_TDESP1'})
		aAdd(aGravaTot,{'VALREE1','FLF_TVLRE1'})

		aAdd(aGravaTot,{'TOTAL2','FLF_TDESP2'})
		aAdd(aGravaTot,{'VALREE2','FLF_TVLRE2'})

		aAdd(aGravaTot,{'TOTAL3','FLF_TDESP3'})
		aAdd(aGravaTot,{'VALREE3','FLF_TVLRE3'})

		aAdd(aGravaTot,{'DESCON1','FLF_TDESC1'})
		aAdd(aGravaTot,{'DESCON2','FLF_TDESC2'})
		aAdd(aGravaTot,{'DESCON3','FLF_TDESC3'})

		aAdd(aGravaTot,{'ADIANT1','FLF_TADIA1'})
		aAdd(aGravaTot,{'ADIANT2','FLF_TADIA2'})
		aAdd(aGravaTot,{'ADIANT3','FLF_TADIA3'})
	EndIf

	If __nOper == OPER_ALTERA .Or. __nOper == OPER_INCLUI
		
		Begin Transaction

		If !Empty(FLF->FLF_CONFER)
			//Apagar hierarquia de aprovação
			lOK := F677EXCAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC)
		EndIf

		If lOK
			//Estorna Prestação de contas
			If __nOper == OPER_ALTERA
				dbSelectArea("FLD")
				FLD->(DbSetOrder(1))
				FLD->(DbSeek(xFilial("FLD")+FLF->FLF_VIAGEM+FLF->FLF_PARTIC))
				While FLD->(!Eof()) .And. xFilial("FLD")+FLF->(FLF_VIAGEM+FLF_PARTIC) == FLD->(FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC)
					RecLock("FLD",.F.)
					FLD->FLD_ENCERR := "2"
					FLD->(MsUnlock())
					FLD->(DbSkip())
				EndDo
			EndIf

			RecLock("FLF",.F.)
			FLF->FLF_STATUS		:= "1"
			FLF->FLF_CONFER		:= ""
			FLF->FLF_DTCONF		:= CToD("  /  /  ")
			FLF->FLF_ITEM	 	:= ""
			For nX := 1 To Len(aGravaTot)
				FLF->(&(aGravaTot[nX][2])) := oModelTotal:GetValue(aGravaTot[nX][1])
			Next
			FLF->(MsUnlock())

		EndIf

		End Transaction

		//Verifico se existem adiantamentos que ainda não foram pagos para a prestação que está sendo manipulada
		FLD->(DbSetOrder(1))
		FLD->(DbSeek(xFilial("FLD") + FLF->FLF_VIAGEM + FLF->FLF_PARTIC))
		While FLD->(!Eof()) .And. xFilial("FLD") + FLF->(FLF_VIAGEM + FLF_PARTIC) == FLD->(FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC)
			If FLD->FLD_STATUS != '4' .And. Empty(FLD->FLD_DTPAGT)
				lAdtPag := .F.
				Exit
			EndIf
			FLD->(DbSkip())
		EndDo

		/*
		- Caso os adiantamento já tenham sido pagos, efetivo a prestação de contas conforme as regras padrão
		- Caso exista algum adiantamento que não tenha sido pago, a prestação continuará em aberto
		---------------------------------------------------------------------------------------------------------
		|Isso evitará que os valores recebidos pelo viajante sejam maiores, pois ao efetivar a prestação		|
		|de contas sem adiantamento pago, o valor a "receber" fica incorreto, pois o adiantamento que ainda		|
		|não foi pago não é considerado no cálculo do saldo da prestação.										|
		---------------------------------------------------------------------------------------------------------
		*/
		If lAdtPag
			//PCREQ-3829 Aprovação Automática
			If !lMobile .AND. lOK .AND. !(aAprv[1]) .AND. !(aAprv[2]) .AND. !(aAprv[3])
				If !lMobile
					MsgRun( STR0085,, {|| lLibFin := F677PreLib(.F.) } ) //"Processando liberação finaceiro..."
				EndIf
			//Realiza a conferência apenas se estiver habilitado na tabela 'FW0' 
			ElseIf lOK .AND. aAprv[1] 
				If (!lMobile .AND. FN677AdtM( 1 )) // "Deseja concluir a digitação das despesas e disponibiliza-la para conferência?"// "Obs.: Após confirmar este encaminhamento, não será mais possível alterar a prestação de contas."
					F677ENVCON()
				EndIf
			Elseif lOK .AND. aAprv[2] //Aprovação do Gestor
				If !lMobile .AND. FN677AdtM( 2 )//Deseja encaminhar a prestação de contas para aprovação do gestor?
					RecLock("FLF",.F.)
						FLF->FLF_STATUS	:= "4"
					FLF->(MsUnlock())
					lGeraFLN := .T.
				Endif	
			Elseif lOK .AND. aAprv[3]//Avaliação do Financeiro
				If !lMobile .AND. FN677AdtM( 3 )//Deseja encaminhar a prestação de contas para o financeiro?
					RecLock("FLF",.F.)
						FLF->FLF_STATUS	:= "6"
					FLF->(MsUnlock())
					lGeraFLN := .T.
				Endif
			EndIf
			If lGeraFLN 
				F677GERAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC, FLF->FLF_VIAGEM)	
			EndIf
		Else
			If !lMobile
				MsgAlert(STR0177)//"A prestação de contas possui adiantamentos que ainda não foram pagos e, por conta disso, continuará com status em aberto, podendo ser encaminhada para aprovação apenas após o pagamento dos adiantamentos."
			EndIf
		EndIf
	EndIf

	If __nOper == OPER_CONFER 

		//Valida se o usuário pode aprovar a própria viagem
		If lAproViagem
			//Busca aprovadores na FLJ.
			FLJ->(dbSeek( xFilial('FLJ') +  FLF->FLF_VIAGEM + FLF->FLF_ITEM))
			While FLJ->FLJ_FILIAL + FLJ->FLJ_VIAGEM + FLJ->FLJ_ITEM == xFilial('FLJ') +  FLF->FLF_VIAGEM + FLF->FLF_ITEM .AND. !lAprov
				
				If cPartic == FLJ->FLJ_PARTIC
					lAprov := .T.
				EndIf
				FLJ->(dbSkip())
				
			EndDo
			If !lAprov
				//Busca na RD0 se o participante é aprovador dele mesmo.
				RD0->(dbSeek( xFilial('RD0') + cPartic))
				lAprov := cPartic == RD0->RD0_APROPC .OR. cPartic == RD0->RD0_APSUBS 
			EndIf
		EndIf
		
		If !__lConfReprova
			lOK := F677GERAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC, FLF->FLF_VIAGEM)
		EndIf

		If lOK
			aAdd(aGravaTot,{'DESCON1','FLF_TDESC1'})
			aAdd(aGravaTot,{'DESCON2','FLF_TDESC2'})
			aAdd(aGravaTot,{'DESCON3','FLF_TDESC3'})

			RecLock("FLF",.F.)
			FLF->FLF_CONFER := aUser[1]
			FLF->FLF_DTCONF	:= dDatabase
			If lAprov
				If oModelTotal:GetValue('SALDO1') = 0
					FLF->FLF_STATUS := Iif(__lConfReprova,"5","8") //Finalizado. Aprovador dele mesmo e não existe mais saldo.
				Else
					FLF->FLF_STATUS := Iif(__lConfReprova,"5","6") //Aprovado.			
				EndIf
			Else
				If !lMobile 
					FLF->FLF_STATUS := IIF(__lConfReprova,"5","4")	
				EndIf
			EndIf	
			
			For nX := 1 To Len(aGravaTot)
				FLF->(&(aGravaTot[nX][2])) := oModelTotal:GetValue(aGravaTot[nX][1])
			Next
			//
			FLF->(MsUnlock())
			
			If !__lConfReprova 
			
				If !lMobile .AND. aAprv[2]	//Avaliação do Gestor
					If MsgYesNo(STR0140)	//Deseja encaminhar a prestação de contas para aprovação do gestor?
						RecLock("FLF",.F.)
							FLF->FLF_STATUS	:= "4"
						FLF->(MsUnlock())
						If __lMTFLUIGATV
							If MTFluigAtv("WFFINA677", cProcWF, "WFFIN677")
								DbSelectArea("RD0")
								RD0->(DbSetOrder(1))
								If RD0->(DbSeek( xFilial("RD0") + FLF->FLF_PARTIC ))
									cChvFLF := FLF->( FLF_FILIAL + FLF_TIPO + FLF_PRESTA + FLF_PARTIC )
									Iif(!Empty(RD0->RD0_APSUBS), aAdd(aUsers,RD0->RD0_APSUBS),) 						
									cUser := RD0->RD0_USER
								EndIf
								
								//Carrega todos os aprovadores do participante.
								DbSelectArea("FLN")
								FLN->(DbSetOrder(1))
								FLN->(DbSeek(xFilial("FLN") + FLF->(FLF_TIPO + FLF_PRESTA + FLF_PARTIC)))
									
								While FLN->FLN_FILIAL == xFilial("FLN") .AND. FLN->FLN_TIPO == FLF->FLF_TIPO .AND.;
									FLN->FLN_PRESTA == FLF->FLF_PRESTA  .AND. FLN->FLN_PARTIC == cPartic 
										
									aAdd(aUsers, FLN->FLN_APROV)
																						
									FLN->(DbSkip())
								EndDo

								If ExistBlock("WFFIN677",.F.,.F.)//Envia Solicitação de Aprovação para o Fluig.
									ExecBlock("WFFIN677",.F.,.F.,{cChvFLF, cUser, aUsers})
								EndIf
								
							EndIf
						EndIf
					Else
						Reclock("FLF",.F.)
						If !aAprv[1] 
							FLF->FLF_STATUS	:= "1"
						Else
							FLF->FLF_STATUS	:= "2"
						Endif
						FLF->(MsUnlock())
					EndIf
				Elseif !lMobile .AND. aAprv[3]//Avaliação do Financeiro
					If MsgYesNo(STR0141)//Deseja encaminhar a prestação de contas para o financeiro?
						RecLock("FLF",.F.)
							FLF->FLF_STATUS	:= "6"
						FLF->(MsUnlock())
					Endif
				Elseif !lMobile .AND. (!aAprv[2] .AND. !aAprv[3])
					MsgRun( STR0085,, {|| lLibFin := F677PreLib(.F.) } ) //"Processando liberação finaceiro..."

					If lLibFin .AND. !FLF->FLF_STATUS == '8'
						RecLock("FLF",.F.)
							FLF->FLF_STATUS	:= "7"
						FLF->(MsUnlock())
					EndIf
				Endif
			
			EndIf
			FLF->(MsUnlock())

			If __lConfReprova
				F677MsgMail(3,FLF->FLF_CONFER,,'1')
			else
				F677PushNotification( 103, NIL, STR0001 + " - " + STR0007, STR0208 ) //"Prestação de Contas"###'Aprovada'###'Prestação aprovada pelo conferente.' 
			EndIf
		EndIf
	EndIf

	If __nOper == OPER_ENVWF
		
		//PCREQ-3829 Aprovação Automática
		If aAprv[2]//Avaliação do Gestor
			
			If FLF->FLF_STATUS == "4"			
				If Empty(FLF->FLF_WFKID)
					DbSelectArea("RD0")
					RD0->(DbSetOrder(1))
					If RD0->(DbSeek( xFilial("RD0") + FLF->FLF_PARTIC ))
						cChvFLF := FLF->( FLF_FILIAL + FLF_TIPO + FLF_PRESTA + FLF_PARTIC )
						Iif(!Empty(RD0->RD0_APSUBS), aAdd(aUsers,RD0->RD0_APSUBS),) 						
						cUser := RD0->RD0_USER
					EndIf
					//Carrega todos os aprovadores do participante.
					DbSelectArea("FLN")
					FLN->(DbSetOrder(1))
					FLN->(DbSeek(xFilial("FLN") + FLF->(FLF_TIPO + FLF_PRESTA + FLF_PARTIC)))
						
					While FLN->FLN_FILIAL == xFilial("FLN") .AND. FLN->FLN_TIPO == FLF->FLF_TIPO .AND.;
						FLN->FLN_PRESTA == FLF->FLF_PRESTA  .AND. FLN->FLN_PARTIC == cPartic 
							
						aAdd(aUsers, FLN->FLN_APROV)
																			
						FLN->(DbSkip())
					EndDo

					If ExistBlock("WFFIN677",.F.,.F.)//Envia Solicitação de Aprovação para o Fluig.
						ExecBlock("WFFIN677",.F.,.F.,{cChvFLF, cUser, aUsers})
					EndIf
					
				Else
					Help(" ",1,"F677WFEXIST",,STR0158 + FLF->FLF_WFKID ,1,0)//"Já existe no FLuig o precesso: "
				EndIf
			Else
				Help(" ",1,"F677STATUS",,STR0159,1,0) //"Status não permite o reenvio"
			EndIf		
					
		EndIf

	EndIf

	If !lMobile
		GrvAnexo(oModel)	// Grava os Anexos no Banco de Conhecimentos (MsDocument)
	EndIf
	If lAuto
		RecLock("FLF",.F.)
		FLF->FLF_STATUS	:= "1"
		FLF->(MsUnlock())
	EndIf

Return .T.

/*/{Protheus.doc} F677ENVCON
Rotina para encaminhar prestação para conferencia

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677ENVCON(cLog As Character)

	Local lRet			As Logical
	Local lBlind	    As Logical
	Local aArea			As Array
	Local cStatus		As Character
	Local nDiasAtraso	As Numeric
	Local lComDesp		As Logical
	Local lComAdiant	As Logical
	Local nTotAdM1		As Numeric
	Local nTotAdM2		As Numeric
	Local nTotAdM3		As Numeric
	Local aAprv 		As Array

	Default cLog		:= ""

	lRet		:= .T.
	lBlind	    := IsBlind()
	aArea		:= GetArea()
	cStatus		:= "2"
	nDiasAtraso	:= SuperGetmv("MV_RESDATR",,1)
	lComDesp	:= .F.
	lComAdiant	:= .F.
	nTotAdM1	:= 0
	nTotAdM2	:= 0
	nTotAdM3	:= 0
	aAprv 		:= FResAprov("2")//2 - Prestação de Contas


	If FLF->FLF_STATUS <> "1" .AND. lRet
		lRet := .F.
		If lBlind
			cLog += STR0054
		Else
			Help(" ",1,"F677NOENV",,STR0054,1,0) //"Não é possivel enviar prestação de contas para conferência com esse status. Operação permitida apenas para prestações em aberto."
		EndIf
	EndIf

	/*
		PCREQ-3829 Aprovação Automática
		
		aAprv[1] - Conferência (.T. or .F.)
		aAprv[2] - Aprovação Gestor (.T. or .F.)
		aAprv[3] - Lib. Financeiro (.T. or .F.)
	*/
	If lRet .and. !(aAprv[1])//Conferência
		If !lBlind
			Help(" ",1,"F677APROA",,STR0144,1,0) //"Processo de Conferência não habilitado!"
		EndIf
		lRet:= F677GERAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC, FLF->FLF_VIAGEM)
		If aAprv[2]	//Se aprova gestor
			cStatus := "4"
		Else
			cStatus := "6"
		EndIf
	Endif

	If lRet .or. lAutomato

		FLF->(MsRLock())

		If lRet .And. FLF->FLF_TIPO == '1'
			dbSelectArea("FLD")
			FLD->(DbSetOrder(1))
			FLD->(DbSeek(xFilial("FLD")+FLF->FLF_VIAGEM+FLF->FLF_PARTIC))
			While FLD->(!Eof()) .And. xFilial("FLD")+FLF->(FLF_VIAGEM+FLF_PARTIC) == FLD->(FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC)
				If FLD->FLD_STATUS $ "2|3"
					lRet := .F.
					If lBlind
						cLog += STR0057
					Else
						Help(" ",1,"F677COMADI",,STR0057,1,0) //"Não é possivel enviar prestação de contas para conferência, pois existem adiantamentos pendentes de pagamento."
					EndIf
					Exit
				ElseIf FLD->FLD_STATUS $ "4"
					lComAdiant 	:= .T.
				EndIf
				FLD->(DbSkip())
			EndDo
		EndIf

		If lRet
			dbSelectArea("FLE")
			FLE->(DbSetOrder(1))
			If FLE->(DbSeek(xFilial("FLE")+FLF->(FLF_TIPO+FLF_PRESTA+FLF_PARTIC)))
				lComDesp := .T.
			EndIf

			If !lComDesp
				If !lBlind .And. MsgYesNo(STR0058) //"Prestação de contas não possui despesas. Deseja confirmar o fechamento mesmo assim?"
					/* Sem despesa e com adiantamento é gravada como Aprovada (6)
				Sem despesa e sem adiantamento já é finalizada (8)
				*/
					cStatus := Iif(lComAdiant,"6","8")
				Else
					lRet := .F.
				EndIf
			ElseIf aAprv[1]
				If lRet .And. (FLF->FLF_DTFIM + nDiasAtraso) < dDatabase
					If lBlind
						cLog += STR0059+AllTrim(Str(nDiasAtraso))+STR0060+CRLF+STR0061
					Else
						Help(" ",1,"F677ATRASO",,STR0059+AllTrim(Str(nDiasAtraso))+STR0060+CRLF+STR0061,1,0) //"A prestação de contas será disponibilizada para conferência com bloqueio, pois foi finalizada com mais de "//" dias de atraso" // "Se preferir, entre em contato com o Depto. de Viagens para maiores informações"
					EndIf
					cStatus := "3"
				EndIf
			EndIf
		EndIf

		If lRet

			Begin Transaction

			If FLF->FLF_TIPO == '1'
				dbSelectArea("FLD")
				FLD->(DbSetOrder(1))
				FLD->(DbSeek(xFilial("FLD")+FLF->FLF_VIAGEM+FLF->FLF_PARTIC))
				While FLD->(!Eof()) .And. xFilial("FLD")+FLF->FLF_VIAGEM+FLF->FLF_PARTIC == FLD->(FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC)
					If FLD->FLD_STATUS $ "2|3"
						DisarmTransaction()
						If lBlind
							cLog += STR0057
						Else
							Help(" ",1,"F677COMADI",,STR0057,1,0) // "Não é possivel enviar prestação de contas para conferência, pois existem adiantamentos pendentes de pagamento."
						EndIf
						Exit
					ElseIf FLD->FLD_STATUS == "4"
						nTotAdM1 += IIF(FLD->FLD_MOEDA == "1",FLD->FLD_VALAPR, 0 )
						nTotAdM2 += IIF(FLD->FLD_MOEDA == "2",FLD->FLD_VALAPR, 0 )
						nTotAdM3 += IIF(FLD->FLD_MOEDA == "3",FLD->FLD_VALAPR, 0 )
					EndIf
					RecLock("FLD",.F.)
					FLD->FLD_ENCERR := "1"
					FLD->(MsUnlock())
					FLD->(DbSkip())
				EndDo
			EndIf

			RecLock("FLF",.F.)
			FLF->FLF_STATUS := cStatus
			FLF->FLF_TADIA1	:= nTotAdM1
			FLF->FLF_TADIA2	:= nTotAdM2
			FLF->FLF_TADIA3	:= nTotAdM3
			FLF->(MsUnlock())

			End Transaction

			If FLF->FLF_STATUS == "8"
				F677MsgMail(5,,)
			EndIf

		EndIf

		FLF->(MsRUnlock())

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} F677TUDOOK
Validação geral do modelo

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677TUDOOK()

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLF		:= oModel:GetModel("FLFMASTER")
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local cTipoP		:= oModelFLF:GetValue("FLF_TIPO")
Local lTem			:= .F.
Local aSaveLines  	:= {}
Local nX		  	:= 0
Local aArea			:= GetArea()

dbSelectArea('RD0')

If (__nOper == OPER_ALTERA .OR. __nOper == OPER_INCLUI)
	If cTipoP == '2'
		aSaveLines  := FWSaveRows()
		For nX := 1 To oModelFLE:Length()
			oModelFLE:GoLine( nX )
			If !oModelFLE:IsDeleted() .And. !Empty(oModelFLE:GetValue("FLE_DESPES"))
				lTem := .T.
				Exit
			Endif
		Next
		FWRestRows(aSaveLines)
		If !lTem
			lRet := .F.
			Help(" ",1,"F677NODESP",,STR0062,1,0) //"Não é possivel gravar prestação de contas avulsa sem despesa."
		EndIf
	EndIf
	/*
	If lRet .And. GetMV("MV_DOCOBRI")
		If oModelFLE:Length() > 0
			lRet := .F.
			For nX := 1 To oModelFLE:Length()
				oModelFLE:SetLine(nX)
				If ! Empty(oModelFLE:GetValue('FLE_ANEXO'))
					lRet := .T.	//	Tem Anexo
				Endif
			Next
			If ! lRet	//	Não achou Anexo  
				Help(,, "MV_DOCOBRI",, X6Descric("MV_DOCOBRI"), 1, 0)	//	"Obrigatorio pelo menos um documento anexo"
			Endif
		Endif
	Endif
	*/
		
EndIf

RestArea( aArea )

Return lRet

/*/{Protheus.doc} F677CONFER
Rotina de Conferência da prestação de contas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677CONFER()

Local aArea         := GetArea()
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local lRet          := .T.
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0091},{.T.,STR0090},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk				:= {||}
Local aAprv 			:= FResAprov("2")//2 - Prestação de Contas
/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Conferência (.T. or .F.)
	aAprv[2] - Aprovação Gestor (.T. or .F.)
	aAprv[3] - Lib. Financeiro (.T. or .F.)
*/

If lRet .AND. !(aAprv[1])
	Help(" ",1,"F677CONF",,STR0144,1,0) // "Processo de conferência não habilitado!"
	lRet := .F.
Endif

If lRet .And. !(FLF->FLF_STATUS $ '2/3' )
	Help(" ",1,"F677CONF",,STR0063 ,1,0) // "Não é possivel conferir prestação com esse status."
	lRet := .F.
EndIf

//Validação de usuário para liberar a conferencia da prestação de contas
If lRet .And. ExistBlock("F677VLDCF")
	lRet := ExecBlock("F677VLDCF",.F.,.F.)
EndIf

If lRet
	FLF->(MsRLock())

	SaveInter() // Salva variaveis publicas
	pergunte("F677REC",.F.)

	__nOper      	:= OPER_CONFER
	cTitulo      	:= STR0101
	cPrograma    	:= 'FINA677'
	nOperation   	:= MODEL_OPERATION_UPDATE
	__lConfReprova 	:= .F.
	bOk          	:= {|| lRet := MsgYesNo(STR0064) }  // "Confirma a aprovação da conferência da Prestação de Contas? "
	nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	__nOper      	:= 0

	RestInter() // Restaura variaveis publicas
	Set Key VK_F12 To

	FLF->(MsRUnlock())
EndIf

RestArea(aArea)
Return

/*/{Protheus.doc} F677REPROVA
Rotina de Reprovação da conferencia da prestação de contas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677REPROVA(oView)

Local lRet	:= .F.

If MsgYesNo(STR0065) //"Confirma a reprovação da conferência da Prestação de Contas? "

	__lConfReprova := .T.
	oView:ButtonOKAction(.T.)
EndIf

Return lRet


/*/{Protheus.doc} F677CONFMX
Rotina de Confirmação da prestação de contas no financeiro das moedas estrangeiras

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677CONFMX(oView)

Local lRet			:= .F.
Local lMoedLocal	:= .F.

If __lBTNEstornar
	If MsgYesNo(STR0099) //"Confirma o acerto financeiro da prestação de contas em moeda estrangeria?"

		RecLock("FLF",.F.)
		FLF->FLF_STATMX	:= " "
		FLF->FLF_STATUS := "7"
		FLF->(MsUnlock())

		oView:ButtonCancelAction()
	EndIf

Else
	If lAutomato .or. MsgYesNo(STR0066) //"Confirma o acerto financeiro da prestação de contas em moeda estrangeria?"

		lMoedLocal	:= (FLF->FLF_TVLRE1 - (FLF->FLF_TADIA1 + FLF->FLF_TDESC1)) > 0

		RecLock("FLF",.F.)
		FLF->FLF_STATMX	:= "1"
		If !lMoedLocal .Or. (lMoedLocal .And. !Empty(FLF->FLF_DTBAIX)) //Se não tem moeda local ou se já ta pago
			FLF->FLF_STATUS := "8"
		EndIf
		FLF->(MsUnlock())

		If FLF->FLF_STATUS == "8"
			F677MsgMail(5,,)
		EndIf

		If !lAutomato
			oView:ButtonCancelAction()
		EndIf
	EndIf
EndIf


Return lRet



/*/{Protheus.doc} F677EXCAPR
Rotina de exclusão da hierarquia de aprovação

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677EXCAPR(cTpPrest, cPresta, cPartic)

Local aArea		:= GetArea()
Local lRet 		:= .T.

Default cTpPrest	:= ""
Default cPresta		:= ""
Default cPartic		:= ""

If !Empty(cTpPrest) .And.  !Empty(cPresta) .And. !Empty(cPartic)

	DbSelectArea("FLN")
	FLN->(DbSetOrder(1))
	FLN->(DbSeek(xFilial("FLN")+cTpPrest+cPresta+cPartic))
	While FLN->(!Eof()) .And. xFilial("FLN")+cTpPrest+cPresta+cPartic == FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC)
		RecLock("FLN",.F.)
		FLN->(DbDelete())
		FLN->(MsUnlock())
		FLN->(DbSkip())
	EndDo

Else
	lRet 		:= .F.
	Help(" ",1,"FINA677PAR",,STR0067,1,0) // "Parâmetros inválidos."
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} F677GERAPR
Rotina de geração da hierarquia de aprovação

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677GERAPR(cTpPrest, cPresta, cPartic, cViagem)
Local nX			:= 0
Local aArea			:= GetArea()
Local cPedido 		:= ""
Local lRet 			:= .T.
Local cSeq			:= 0
Local cAliasTrb1	:= GetNextAlias()
Local cAliasTrb2	:= GetNextAlias()
Local aAprov		:= {}
Local lFound		:= .F.
Default cTpPrest	:= ""
Default cPresta	:= ""
Default cPartic	:= ""
Default cViagem	:= ""

If ExistBlock("F677GERAPR")
	aAprov := ExecBlock("F677GERAPR",.F.,.F.)
EndIf
DbSelectArea("RD0")
RD0->(DbSetOrder(1))
			

If !Empty(cTpPrest) .And.  !Empty(cPresta) .And. !Empty(cPartic) .and. (ValType(aAprov) == 'U' .or. Len(aAprov) <= 0)

	DbSelectArea("FLN")
	FLN->(DbSetOrder(1))
	If FLN->(!DbSeek(xFilial("FLN")+cTpPrest+cPresta+cPartic))

		If cTpPrest == '1'

			If !Empty(cViagem)

				DbSelectArea("FL6")
				DbSelectArea("FLU")
				//Cria tabela com Participantes e seus Pedido
				BeginSql Alias cAliasTrb1
					SELECT FL6_VIAGEM, FL6_ITEM, FL6_EXTRA1, FLU_PARTIC
					FROM %table:FL6% FL6
					INNER JOIN %table:FLU% FLU
					ON FL6.FL6_FILIAL = FLU.FLU_FILIAL
					AND FL6.FL6_VIAGEM = FLU.FLU_VIAGEM
					AND FL6.FL6_ITEM = FLU.FLU_ITEM
					AND FLU.FLU_PARTIC = %exp:cPartic%
					AND FLU.%notDel%
				   WHERE FL6_FILIAL = %xFilial:FL6%
				   			AND FL6_VIAGEM = %exp:cViagem%
				   			AND FL6.%notDel%
					ORDER BY FL6_VIAGEM, FL6_ITEM
				EndSql

				//Pesquisa pedido que solicitou adiantamento ou o primeiro pedido
				If (cAliasTrb1)->(!Eof())
					cPedido := (cAliasTrb1)->FL6_ITEM
					While (cAliasTrb1)->(!Eof())
						If (cAliasTrb1)->FL6_EXTRA1 == '1'
							cPedido := (cAliasTrb1)->FL6_ITEM
							Exit
						EndIf
						(cAliasTrb1)->(DbSkip())
					EndDo
				EndIf

				If !Empty(cPedido)

					//Vincula prestação ao Pedido
					DbSelectArea("FLF")
					FLF->(DbSetOrder(1))
					If FLF->(DbSeek(xFilial("FLF")+cTpPrest+cPresta+cPartic))
						RecLock("FLF",.F.)
							FLF_ITEM	:= cPedido
						FLF->(MsUnLock())
					EndIf

					DbSelectArea("FLJ")
					DbSelectArea("RD0")
					BeginSql Alias cAliasTrb2
						SELECT FLJ_PARTIC PARTIC, RD0_NOME, FLJ_SUBITM
						FROM %table:FLJ% FLJ
						INNER JOIN %table:RD0% RD0
						ON FLJ.FLJ_PARTIC = RD0.RD0_CODIGO
						AND  RD0.%notDel%
					   WHERE FLJ_FILIAL = %xFilial:FLJ%
					   			AND FLJ_VIAGEM = %exp:cViagem%
					   			AND FLJ_ITEM =  %exp:cPedido%
					   			AND FLJ.%notDel%
					   	ORDER BY FLJ_SUBITM DESC
					EndSql

					If (cAliasTrb2)->(Eof())
						(cAliasTrb2)->(DbCloseArea())
						BeginSql Alias cAliasTrb2
						SELECT RD0_APROPC PARTIC, RD0_NOME
						FROM %table:RD0% RD0
					    WHERE RD0_FILIAL = %xFilial:RD0%
					   			AND RD0_CODIGO = %exp:cPartic%
					   			AND RD0.%notDel%
						EndSql
						If (cAliasTrb2)->(!Eof())
							lFound := .T.
						EndIf
					Else
						lFound := .T.
					EndIf

					If lFound
						cSeq := '1'
						While (cAliasTrb2)->(!Eof())
							RecLock("FLN",.T.)
								FLN_FILIAL	:= xFilial("FLN")
								FLN_TIPO	:= cTpPrest
								FLN_PRESTA	:= cPresta
								FLN_PARTIC	:= cPartic
								FLN_SEQ		:= cSeq
								FLN_TPAPR	:= "1"
								FLN_APROV	:= (cAliasTrb2)->PARTIC
								FLN_NOMEAP	:= (cAliasTrb2)->RD0_NOME
								FLN_STATUS	:= IIf(cSeq == "1","1","0")
							FLN->(MsUnLock())

							If cSeq == "1"
								F677MsgMail( 1, ( cAliasTrb2 )->PARTIC, )
							EndIf

							cSeq := Soma1(cSeq,1)
							(cAliasTrb2)->(DbSkip())
						EndDo
					Else
						lRet := .F.
						Help(" ",1,"FINA677APR",,STR0068,1,0) // "Pedido sem aprovadores."
					EndIf
				Else
					lRet := .F.
					Help(" ",1,"FINA677PED",,STR0069,1,0) // "Viagem sem pedido para este participante."
				EndIf
			Else
				lRet := .F.
				Help(" ",1,"FINA677VGM",,STR0070,1,0) // "Código da viagem inválido."
			EndIf

		ElseIf cTpPrest == '2'
			//Pegar o aprovador da RD0
			DbSelectArea("RD0")
			RD0->(DbSetOrder(1))
			If RD0->(DbSeek(xFilial("RD0")+cPartic)) .And. !Empty(RD0->RD0_APROPC)
				RecLock("FLN",.T.)
					FLN_FILIAL	:= xFilial("FLN")
					FLN_TIPO	:= cTpPrest
					FLN_PRESTA	:= cPresta
					FLN_PARTIC	:= cPartic
					FLN_SEQ		:= "1"
					FLN_TPAPR	:= "1"
					FLN_APROV	:= RD0->RD0_APROPC
					FLN_NOMEAP	:= RD0->RD0_NOME
					FLN_STATUS	:= "1"
				FLN->(MsUnLock())

				F677MsgMail( 1, RD0->RD0_APROPC, )

			Else
				lRet := .F. //Participante não tem aprovador cadastrado.
				Help(" ",1,"FINA677SEM",,STR0071,1,0) //Participante não tem aprovador cadastrado.
			EndIf
		EndIF
	Else
		lRet := .F.
		Help(" ",1,"FINA677JA",,STR0072,1,0) //Aprovações já geradas.
	EndIf
ElseIf ValType(aAprov) == 'A' .and. Len(aAprov) > 0 //Quando Vier do ponto de Entrada 
	cSeq := "1"
	lRet := .F. 
	For nX := 1 to Len(aAprov)
		If RD0->(DbSeek(xFilial("RD0")+aAprov[nX]))
			RecLock("FLN",.T.)
				FLN_FILIAL	:= xFilial("FLN")
				FLN_TIPO	:= cTpPrest
				FLN_PRESTA	:= cPresta
				FLN_PARTIC	:= cPartic
				FLN_SEQ		:= cSeq
				FLN_TPAPR	:= "1"
				FLN_APROV	:= aAprov[nX]
				FLN_NOMEAP	:= RD0->RD0_NOME
				FLN_STATUS	:= IIf(cSeq == "1","1","0")
			FLN->(MsUnLock())
			lRet := .T.
			If cSeq == "1"
				F677MsgMail( 1, aAprov[ nX ], )
			EndIf

			cSeq := Soma1(cSeq,1)
		Endif
	Next nX
	If !lRet
		Help(" ",1,"FINA677SEM",,STR0071,1,0) //Participante não tem aprovador cadastrado.
	Endif
Else
	lRet := .F.
	Help(" ",1,"FINA677PAR",,STR0067,1,0) //Parâmetros inválidos.
EndIf

If Select(cAliasTrb1) > 0
	(cAliasTrb1)->(DbCloseArea())
EndIf

If Select(cAliasTrb2) > 0
	(cAliasTrb2)->(DbCloseArea())
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F677GerPC
Gera Prestação de Contas.
@author William Matos Gundim Junior
@param oModel Objeto com os dados necessarios.
@since  01/11/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F677GerPC(oModelVgm)
Local aArea	  	:= GetArea()
Local oModel 	:= Nil
Local nCount 	:= 1
Local cPartic 	:= ''
Local cLog     	:= ''
Local cNome   	:= ''
Local cViagem 	:= oModelVgm:GetValue('FL5MASTER','FL5_VIAGEM')
Local dEmissao 	:= oModelVgm:GetValue('FL6DETAIL','FL6_DTEMIS')
Local dDataIni 	:= oModelVgm:GetValue('FL5MASTER','FL5_DTINI')
Local dDataFim 	:= oModelVgm:GetValue('FL5MASTER','FL5_DTFIM')
Local cNacion  	:= oModelVgm:GetValue('FL5MASTER','FL5_NACION')
Local cMotivo  	:= If (AllTrim(oModelVgm:GetValue('FL6DETAIL','FL6_MOTIVO')) <> '',oModelVgm:GetValue('FL6DETAIL','FL6_MOTIVO'),STR0073+" "+STR0001)
Local cCliente 	:= oModelVgm:GetValue('FL5MASTER','FL5_CLIENT')
Local cLoja    	:= oModelVgm:GetValue('FL5MASTER','FL5_LOJA')
Local cCC      	:= oModelVgm:GetValue('FLHDETAIL','FLH_CC')
Local cIteCTA	:= oModelVgm:GetValue('FLHDETAIL','FLH_ITECTA')
Local cCLVL		:= oModelVgm:GetValue('FLHDETAIL','FLH_CLVL')
Local cItem		:= oModelVgm:GetValue('FL6DETAIL','FL6_ITEM')
Local lCliente 	:= SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),2,1) == "1" //Verifica se utiliza cliente.
Local nPerCli	:= 0
Local nPerEmp	:= 0
Local oModelFLF := Nil

lAuto      := .T.

DbSelectArea('FLF')
oModel := FWLoadModel('FINA677')
oModel:SetOperation(3) //Inclusão
oModel:Activate()

oModelFLF := oModel:GetModel('FLFMASTER')
oModelVgm := oModelVgm:GetModel('FLUDETAIL') // Passageiros.

For nCount := 1 To oModelVgm:Length()
	oModelVgm:GoLine(nCount)
	cPartic := oModelVgm:GetValue('FLU_PARTIC')
	cNome   := oModelVgm:GetValue('FLU_NOME')

	FLF->(DbSetOrder(2)) // FLF_FILIAL + FLF_VIAGEM + FLF_PARTIC
	If !FLF->(DbSeek(xFilial('FLF') + cViagem + cPartic))

		nPerCli	:= FN693PClie(cViagem, cItem)
		nPerEmp	:= 100 - nPerCli
		//Gera os valores.
		oModelFLF:SetValue('FLF_FILIAL'	,xFilial('FLF'))
		oModelFLF:SetValue('FLF_TIPO'	,'1')               // 1 - Viagem | 2 - Avulsas
		oModelFLF:SetValue('FLF_PRESTA'	,cViagem)
		oModelFLF:SetValue('FLF_VIAGEM'	,cViagem)
		oModelFLF:SetValue('FLF_PARTIC'	,cPartic)
		oModelFLF:SetValue('FLF_NOMEPA'	,cNome)
		oModelFLF:SetValue('FLF_EMISSA'	,dEmissao)
		oModelFLF:SetValue('FLF_DTINI'	,dDataIni)
		oModelFLF:SetValue('FLF_DTFIM'	,dDataFim)
		oModelFLF:SetValue('FLF_NACION'	,cNacion)        // 1 -FINA677 Nacional | 2 - Internacional
		oModelFLF:SetValue('FLF_MOTIVO'	,cMotivo)
		oModelFLF:SetValue('FLF_FATEMP'	,nPerEmp)
		//
		If lCliente
			oModelFLF:SetValue('FLF_CLIENT'	,cCliente)
			oModelFLF:SetValue('FLF_LOJA'  	,cLoja)
			oModelFLF:SetValue('FLF_FATCLI'	,nPerCli)	
		EndIf

		oModelFLF:SetValue('FLF_CC'    	,cCC)
		oModelFLF:SetValue('FLF_ITECTA' ,cIteCTA)
		oModelFLF:SetValue('FLF_CLVL'	,cCLVL)  

		If !oModel:VldData()
			cLog := 'F667Contas' + cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
					 + ' - ' + cValToChar(oModel:GetErrorMessage()[8])
		Else
			oModel:CommitData()
			oModel:DeActivate()
			oModel:= Nil
			oModel:= FWLoadModel('FINA677')
			oModel:SetOperation(3) //Inclusão
			oModel:Activate()
			oModelFLF := oModel:GetModel('FLFMASTER')
		EndIf
	Else
		oModel:Deactivate()//Desativo para poder fazer a troca da operação
		oModel:Destroy()
		oModel := Nil
		oModel := FWLoadModel('FINA677')
		oModel:SetOperation(4)//Update		
		oModel:Activate()
		
		//Faço o update do modelo com as datas atualizadas
		oModelFLF := oModel:GetModel('FLFMASTER')
		
		oModelFLF:SetValue('FLF_DTINI'	,dDataIni)
		oModelFLF:SetValue('FLF_DTFIM'	,dDataFim)
		oModelFLF:SetValue('FLF_CC'    	,cCC)
		oModelFLF:SetValue('FLF_ITECTA' ,cIteCTA)
		oModelFLF:SetValue('FLF_CLVL'	,cCLVL)		

		If !oModel:VldData()
			cLog := 'F667Contas' + cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
					 + ' - ' + cValToChar(oModel:GetErrorMessage()[8])
		Else		
			oModel:CommitData()
			oModel:DeActivate()
			oModel:Destroy()
			oModel := Nil
			oModel := FWLoadModel('FINA677')
			oModel:SetOperation(3) //Inclusão
			oModel:Activate()
			oModelFLF := oModel:GetModel('FLFMASTER')
		EndIf
	EndIf
Next

oModelVgm := Nil
oModel:DeActivate()
oModel:Destroy()
oModel := NIL
RestArea(aArea)

lAuto      := .F.

Return	cLog


/*/{Protheus.doc} F677FINMX
Rotina para fechamento da prestação nas moedas 2 e 3

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677FINMX()

Local lRet				:= .T.
Local aArea				:= GetArea()
Local lOutraMoed		:= (FLF->FLF_TVLRE2 - (FLF->FLF_TADIA2 + FLF->FLF_TDESC2)) > 0 .Or. (FLF->FLF_TVLRE3 - (FLF->FLF_TADIA3 + FLF->FLF_TDESC3)) > 0
Local cTitulo       	:= ""
Local cPrograma     	:= ""
Local nOperation    	:= 0
Local aEnableButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0090},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"

If !(FLF->FLF_STATUS $ "7|8")
	lRet := .F.
	Help(" ",1,"F677NOFECH",,STR0074,1,0) // "Não é possivel finalizar prestação de contas com esse status."
EndIf

If lRet .And. !lOutraMoed
	lRet := .F.
	Help(" ",1,"F677NOFECH",,STR0075,1,0) //"Esta operação é permitida apenas para prestação com saldo em moeda extrangeira."
EndIf

If FLF->FLF_STATUS == "8" .And. FLF->FLF_ABONO <> "1"
	lRet := .F.
	Help(" ",1,"F677NOFECH",,STR0074,1,0) //"Esta operação é permitida apenas para prestação com saldo em moeda extrangeira."
EndIF

If lRet .And. FLF->FLF_STATMX == "1"
	__lBTNEstornar := .T.
EndIf

If lRet
	FLF->(MsRLock())
	__nOper      	:= OPER_FINMX
	cTitulo      	:= STR0077	 // "Conf. Prestação Moeda Extr."
	cPrograma    	:= 'FINA677'
	nOperation   	:= MODEL_OPERATION_VIEW
	If !lAutomato
		nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. },/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	Else
		F677CONFMX()
	EndIf
	__nOper      	:= 0
	FLF->(MsRUnlock())
EndIf

__lBTNEstornar := .F.

RestArea(aArea)

Return


 //-------------------------------------------------------------------
/*/{Protheus.doc} FINA667NEW
Obtem o próximo item para o participante de uma determinada prestação

@author jose domingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA677NEW(cTipo)

Local aArea		:= GetArea()
Local cNewItem	:= STRZERO(1,TamSx3("FLF_PRESTA")[1])
Local cAliasTrb	:= GetNextAlias()

Default cTipo	:= ""

If !Empty(cTipo)
	DbSelectArea("FLF")
	BeginSql Alias cAliasTrb
		SELECT MAX(FLF_PRESTA) PRESTA
		FROM %table:FLF% FLF
		WHERE FLF_FILIAL =  %xFilial:FLF%
 			AND FLF_TIPO = %exp:cTipo%
			AND FLF.%notDel%
	EndSql

	If (cAliasTrb)->(!Eof())
		If cTipo == "1"
			cNewItem := Soma1(Alltrim((cAliasTrb)->PRESTA))
		Else
			cNewItem := GETSXENUM("FLF","FLF_PRESTA",,1)
		EndIf
	EndIf

	(cAliasTrb)->(DbCloseArea())
EndIf

RestArea(aArea)

Return cNewItem



/*/{Protheus.doc} F677ESTFIN
Rotina para fechamento da prestação nas moedas 2 e 3

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677ESTFIN()
Local lRet				:= .T.
Local aArea				:= GetArea()
Local lOutraMoed		:= (FLF->FLF_TVLRE2 - (FLF->FLF_TADIA2 + FLF->FLF_TDESC2)) > 0 .Or. (FLF->FLF_TVLRE3 - (FLF->FLF_TADIA3 + FLF->FLF_TDESC3)) > 0
Local cTitulo       	:= ""
Local cPrograma     	:= ""
Local nOperation    	:= 0
Local aEnableButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0034},{.T.,STR0090},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk				:= {|| F677CESTPG() } 

If !(lRet := IsApprover())
	Help(" ", 1, "F677ACESSO", Nil, STR0210, 1, 0)	//Usuario nao possui acesso para liberar financeiro
EndIf

If lRet
	If !FLF->FLF_STATUS $ "7|8"
		lRet := .F.
		Help(" ",1,"F677NOESTF",,STR0078,1,0) //"Não é possivel estornar a liberação para o financeiro de prestação de contas com esse status."
	ElseIf FLF->FLF_STATUS == "8" .And. FLF->FLF_ABONO <> "1"
		lRet := .F.
		Help(" ",1,"F677NOESTF",,STR0079,1,0) //"Não é possivel estornar a liberação para o financeiro desta prestação de contas."
	ElseIf FLF->FLF_STATUS == "8" .And. FLF->FLF_ABONO == "1" .And. lOutraMoed .And. FLF->FLF_STATMX == "1"
		lRet := .F.
		Help(" ",1,"F677NOESTF",,STR0078+" "+STR0080,1,0) //"Verifique a confirmação da prestação em moeda extrangeria."
	EndIf
EndIf

If lRet
	FLF->(MsRLock())
	__nOper    := OPER_ESTFIN
	cTitulo    := STR0081 // "Estorno da liberação ao financeiro"
	cPrograma  := 'FINA677'
	nOperation := MODEL_OPERATION_UPDATE
	
	If lAutomato
		F677CESTPG()
	Else
		nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }, bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	EndIf
	
	__nOper      	:= 0
	FLF->(MsRUnlock())
EndIf

RestArea(aArea)

Return


/*/{Protheus.doc} F677CESTPG
Rotina de Confirmação da prestação de contas no financeiro das moedas extrangeiras

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677CESTPG()
Local lRet       := .F.
Local cMsg	     := ""
Local nOpcao     := 2 //Estorno
Local lAbono     := .F.
Local oView      := FWViewActivate()
Local lGerLanCon := .F.

If !Empty(FLF->FLF_TITULO)
	cMsg := STR0082 // "Atenção: Este processo fará a exclusão dos títulos gerados no financeiro. "
EndIf

If lAutomato .Or. MsgYesNo(cMsg+STR0083) // "Confirma o estorno da liberação ao financeiro da prestação de contas?"
	If FLF->FLF_ABONO == "1"
		lAbono := .T.
	EndIf
	
	lGerLanCon := (FLF->FLF_LA == "S")
	
	//Estorna titulo no Financeiro
	If (lRet := (FN677TCR(nOpcao, 0, lAbono) .Or. FN677TCP(nOpcao, 0, lAbono)))
		RecLock("FLF",.F.)
		FLF->FLF_STATUS := "6"
		FLF->FLF_DTFECH := CToD("  /  /    ")
		FLF->(MsUnlock())
	EndIf
	
	//Grupo de perguntes
	pergunte("F677REC",.F.)
	
	If lRet .And. !lAutomato
		oView:ShowUpdateMsg(.T.)
		oView:SetUpdateMessage('', STR0163 )
	EndIf  
	
	//Contabilização On-Line
	If lGerLanCon
		F6778BLCt(.T.)
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} F677RECALC
Recalcula valores das despesas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677RECALC(oView)

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLF		:= oModel:GetModel("FLFMASTER")
Local oModelFLE		:= oModel:GetModel("FLEDETAIL")
Local oModelAUX		:= oModel:GetModel("AUXDETAIL")
Local oModelTotal	:= oModel:GetModel("TOTAL")
Local dDtIini		:= oModelFLF:GetValue("FLF_DTINI")
Local dDtFim		:= oModelFLF:GetValue("FLF_DTFIM")
Local aSaveLines  	:= {}
Local aGrid			:= {}
Local nX		  	:= 0
Local nTamFLE		:= oModelFLE:Length()
Local nDias			:= 0
Local dDataAux		:= oModelFLF:GetValue("FLF_DTINI")
Local cMoedD		:= cValToChar(f677GetMoeda(1))
Local cMoedE		:= cValToChar(f677GetMoeda(2)) 
Local cSimbM1		:= Iif(SuperGetMV("MV_SIMB1"		, .F., "1") == "", "1" , SuperGetMV("MV_SIMB1"			, .F., "1"))
Local cSimbM2		:= Iif(SuperGetMV("MV_SIMB" + cMoedD, .F., "2") == "", "2" , SuperGetMV("MV_SIMB" + cMoedD	, .F., "2"))
Local cSimbM3		:= Iif(SuperGetMV("MV_SIMB" + cMoedE, .F., "3") == "", "3" , SuperGetMV("MV_SIMB" + cMoedE	, .F., "3"))
Local cSaldo1		:= ''
Local cSaldo2		:= ''
Local cSaldo3		:= ''

If __nOper == OPER_ALTERA .Or. __nOper == OPER_INCLUI .Or. __nOper == OPER_CONFER
	If __nOper == OPER_ALTERA .Or. __nOper == OPER_INCLUI //Reordena os itens
		aSaveLines  := FWSaveRows()
		For nX := 1 To nTamFLE 
			oModelFLE:GoLine( nX )
			aAdd(aGrid,{IIf(oModelFLE:IsDeleted(),"X","0")+dtos(oModelFLE:GetValue("FLE_DATA"))+oModelFLE:GetValue("FLE_ITEM"),nX})
			oModelFLE:SetValue("FLE_VALREE", 0 )
			oModelFLE:SetValue("FLE_VALNRE", 0 )
		Next nX
		
		aGrid := aSort(aGrid,,,{|x,y| x[1] < y[1] })
	EndIf

	lWhenItem := .T.
	
	For nX := 1 To Len(aGrid)
		oModelFLE:GoLine( aGrid[nX][2] )
		While dDataAux <= dDtFim
			nDias++
			dDataAux := dDataAux + 1  
		EndDo
		
		PoliDesp(oModelFLE, dDtIini,dDtIini==dDtFim,nDias)
	Next
	
	lWhenItem := .F.
	FWRestRows(aSaveLines)

	oModelAUX:SetValue("FLF_TDESP1",oModelAUX:GetValue("FLF_TDESP1") )
	oModelAUX:SetValue("FLF_TDESP2",oModelAUX:GetValue("FLF_TDESP2") )
	oModelAUX:SetValue("FLF_TDESP3",oModelAUX:GetValue("FLF_TDESP3") )

	If !IsBlind()
		oView:Refresh("FLEDETAIL")
	EndIf

	cSaldo1 := AllTrim(Transform((oModelTotal:GetValue("VALREE1") - oModelTotal:GetValue("DESCON1")) - oModelTotal:GetValue("ADIANT1"),"@E 999,999,999,999.99"))
	cSaldo2 := AllTrim(Transform((oModelTotal:GetValue("VALREE2") - oModelTotal:GetValue("DESCON2")) - oModelTotal:GetValue("ADIANT2"),"@E 999,999,999,999.99"))
	cSaldo3 := AllTrim(Transform((oModelTotal:GetValue("VALREE3") - oModelTotal:GetValue("DESCON3")) - oModelTotal:GetValue("ADIANT3"),"@E 999,999,999,999.99"))
	
	If !IsBlind() .And. FwIsInCallStack('F677DETOK')
		lRet := MsgYesNo(STR0174 + CRLF +;
				cSimbM1 + " " + cSaldo1 + CRLF +;
				cSimbM2 + " " + cSaldo2 + CRLF +;
				cSimbM3 + " " + cSaldo3 + CRLF + CRLF +;
				STR0175)

		If !lRet
			Help(" ",1,"PREST_ABERTA",,STR0176,1,0)
		EndIf
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} F677ALTER
Rotina de Alteração da prestação de contas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677ALTER()

Local aArea         := GetArea()
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local nRet			:= 2
Local cWfId			:= ""
Local cApvFluig		:= ""
Local cUserFluig	:= ""

SaveInter() // Salva variaveis publicas
pergunte("F677REC",.F.)

__nOper      	:= OPER_ALTERA
cTitulo      	:= STR0013
cPrograma    	:= 'FINA677'
nOperation   	:= MODEL_OPERATION_UPDATE
If !lAutomato
	nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
Else
	F677RECALC()
	nRet	:= 0
EndIf
__nOper      	:= 0

//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
If nRet == 0
	cWfId := FLF->FLF_WFKID
	If !Empty(cWfId)
		RD0->(DbSetOrder(1))
		If RD0->(DbSeek( xFilial("RD0")+FLF->FLF_PARTIC))
			cApvFluig  := RD0->RD0_USER
			cUserFluig := FWWFColleagueId(cApvFluig)
			CancelProcess(Val(cWfId),cUserFluig,STR0160)//"Excluido pelo sistema Protheus"
		EndIf
	Endif
Endif

RestInter() // Restaura variaveis publicas
Set Key VK_F12 To

RestArea(aArea)

Return


/*/{Protheus.doc} F677INCLUI
Rotina de Alteração da prestação de contas

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677INCLUI()

Local cTitulo       	:= ""
Local cPrograma     	:= ""
Local nOperation    	:= 0

SaveInter() // Salva variaveis publicas
pergunte("F677REC",.F.)

__nOper      	:= OPER_INCLUI
cTitulo      	:= STR0012
cPrograma    	:= 'FINA677'
nOperation   	:= MODEL_OPERATION_INSERT
nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,{|| DocView() } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
__nOper      	:= 0

RestInter() // Restaura variaveis publicas
Set Key VK_F12 To


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F677MsgMail
Estorno de liberação (Gestor) de adiantamento

@param nOpcao 	1= Gestor (Liberar solicitacao de adiantamento
				2= Paricipante (solicitacao de adiantamento negado - Gestor )
				3= Paricipante (adiantamento negado - Depto Viagens)
				4= Paricipante (pagamento de adiantamento aprovado)


@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
@Param	cOrigem 1=Protheus;2=Fluig
/*/
//-------------------------------------------------------------------

Function F677MsgMail(nOpcao,cCodAprv,cRecPag,cOrigem)

Local nLayout		:= 2		//1=Adiantamento,2=Prestação de Contas
Local nInteressado	:= 1		//1=Participante, 2=Departamento de Viagem,  3=Aprovador
Local cMensagem		:= ""  		//Mensagem a ser enviada
Local cAssunto		:= ""		//Assunto do e-mail
Local cNomeGestor	:= ""
Local lEnviaEmail	:= (SuperGetMV("MV_RESAVIS",,"") == "1")	//Para enviar email, parâmetro MV_RESAVIS == "1"
Local lF677Mail		:= ExistBlock("F677MAIL")
Local aRet			:= {}

DEFAULT nOpcao	  	:= 0
DEFAULT cCodAprv  	:= ""
DEFAULT cRecPag 	:= ""



If nOpcao == 1	//Aviso ao Gestor sobre prestação pendente de aprovação

	nLayOut			:= 4

	cAssunto	:= STR0001+" - "+STR0017 		//"Prestação de Contas - Aprovação"
	cMensagem	:= STR0001 //"Prestação de contas "
	cMensagem	+= STR0112 //" está pendente de sua aprovação."

ElseIf nOpcao == 2	//Aviso ao participante sobre prestação reprovada pelo gestor.

	cNomeGestor := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0")+ cCodAprv ,1,"")+". "

	cAssunto	:= STR0001 + " - " + STR0006 	//"Prestação de Contas - Reprovada"
	cMensagem	:= STR0001 //"Prestação de contas " //" foi reprovada pelo Aprovador: "
	cMensagem	+= STR0104 + AllTrim(cNomeGestor)+STR0105 //". Por favor, entre em contato com o mesmo para maiores esclarecimentos. "

ElseIf nOpcao == 3	//Aviso ao participante sobre prestação reprovada pelo Depto Viagens.

	cAssunto	:= STR0001+" - "+STR0006 		//"Prestação de Contas - Reprovada"
	cMensagem	:= STR0001+STR0106	//"Prestação de contas " //" foi reprovada na conferência pelo Departamento de Viagens."
	cMensagem	+= STR0105 //". Por favor, entre em contato com o mesmo para maiores esclarecimentos. "

ElseIf nOpcao == 4	//Aviso ao participante sobre pagamento liberado

	cAssunto	:= STR0001+" - "+STR0107 		//"Prestação de Contas - Liberada ao Financeiro"
	cMensagem	:= STR0001+ STR0108//"Prestação de contas " //" foi liberada para acerto financeiro."
	If cRecPag == "P"
		cMensagem	+= STR0109 //" Aguarde o pagamento do valor pendente. "
	ElseIf cRecPag == "R"
		cMensagem	+= STR0110 //" A empresa aguarda a devolução do valor pendente. "
	EndIf

ElseIf nOpcao == 5	//Aviso ao participante sobre prestação finalizada pelo Depto Viagens.

	cAssunto	:= STR0001+" - "+STR0009 		//"Prestação de Contas - Finalizada"
	cMensagem	:= STR0001+STR0111//"Prestação de contas " //" foi finalizada pelo Departamento de Viagens."

EndIf

If lEnviaEmail
	If lF677Mail
		aRet := aClone(ExecBlock('F677MAIL',.F.,.F.,{nOpcao,cAssunto,cMensagem}))
		If Len(aRet) > 0
			cAssunto := IIf(!Empty(aRet[1]),aRet[1],cAssunto)
			cMensagem := IIf(!Empty(aRet[2]),aRet[2],cMensagem)
		EndIf
	EndIf

	//Manda o email
	FNXRESMONTAEMAIL(nLayOut, nInteressado, cMensagem, cAssunto, cOrigem)
EndIf

// Executa a função de notificação via aplicativo
F677PushNotification( nOpcao, cCodAprv, cAssunto, cMensagem )

Return


/*/{Protheus.doc} F677LIBFIN
Rotina de liberação da prestação de contas para financeiro

@author Jose Domingos

@since 23/10/2013
@version 1.0
/*/
Function F677LIBFIN(cAlias,nReg,nOpc,lAutomato,lAbono)

	Local aArea			:= GetArea()
	Local cTitulo		:= ""
	Local cPrograma		:= ""
	Local nOperation	:= 0
	Local lRet			:= .T.
	Local aButtons		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0090},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	Local bOk			:= {||}
	Local aAprv 		:= FResAprov("2")	//2 - Prestação de Contas

	Default lAutomato	:= .F.
	Default lAbono		:= .F.

	/*
		Aprovação Automática
		aAprv[1] - Conferência (.T. or .F.)
		aAprv[2] - Aprovação Gestor (.T. or .F.)
		aAprv[3] - Lib. Financeiro (.T. or .F.)
	*/
	If !aAprv[3]
		Help(" ", 1, "F677APROA",, STR0145, 1, 0) //"Processo de Liberação não habilitado!"
		lRet := .F.
	Endif

	If !(lRet := IsApprover())
		Help(" ", 1, "F677ACESSO", Nil, STR0210, 1, 0)	//Usuario nao possui acesso para liberar financeiro
	EndIf

	If lRet .And. !(FLF->FLF_STATUS == '6')
		Help(" ", 1, "F677CONF",, STR0113, 1, 0) //"Não é possivel liberar financeiro de prestação com esse status."
		lRet := .F.
	EndIf

	If lRet
		FLF->(MsRLock())

		__nOper			:= OPER_LIBFIN
		cTitulo			:= STR0084
		cPrograma		:= 'FINA677'
		nOperation		:= MODEL_OPERATION_VIEW
		__lConfReprova	:= .F.
		If !lAutomato
			bOk			:= {|| F677LibOK()}  // "Confirma a aprovação da conferência da Prestação de Contas? "
			nRet		:= FwExecView(cTitulo, cPrograma, nOperation, /*oDlg*/, {|| .T. }, bOk, /*nPercReducao*/, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, /* oModel*/)
			lRet 		:= __lLibOk //disponível em caso de necessidade de efetuar alguma validação adicional
		Else
			lRet		:= F677PreLib(lAbono)
		EndIf
		__nOper			:= 0
		FLF->(MsRUnlock())
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F677LibOK
Gera financeiro da prestação de contas

@author Jose Domingos Caldana Jr

@since 05/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F677LibOK(oView,lAbono)

	Local aArea		:= GetArea()
	Local lOk		:= .F.
	Local lRet		:= .F.
	Default lAbono	:= .F.

	If lAutomato
		lOk	:= .T.
	ElseIf lAbono
		lOk	:= MsgYesNo(STR0116)
	Else
		lOk	:= MsgYesNo(STR0114)
	EndIf

	If lOk
		MsgRun( STR0085,, {|| lRet := F677PreLib(lAbono) } ) 		//"Processando liberação finaceiro..."
	EndIf

	If !lAutomato 
		oView:DeActivate()
		oView:oOwner:End()
	EndIf

	RestArea(aArea)

	__lLibOk := lRet

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} F677AltVjt
Altera Participante da prestação de contas

@author Jose Domingos Caldana Jr

@since 05/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function F677AltVjt(oView)

Local aUserCft		:= {}
Local aPerg			:= {}
Local aRet			:= {}
Local oModel		:= Nil
Local oModelFLF		:= Nil

//Valida se o usuário é susbtituto da prestação de contas de algum outro participante. Caso seja, ele poderá alterar o participante da prestação de contas

aAdd( aPerg,{1,"Participante",Space(TamSx3("RD0_CODIGO")[1]),"@!",;
												"Vazio() .Or. Existcpo('RD0')","RD0",;
												/**/,TamSx3("RD0_CODIGO")[1],.F.})

If ParamBox(aPerg,"Subst. Prest. Contas",@aRet)

	aUserCft := F677GetUPC(aUser[1])
	
	If aScan(aUserCft,{|x| x = MV_PAR01}) > 0 .Or. MV_PAR01 == aUser[1]
	
		oModel 	:= FWModelActive()
		oModelFLF 	:= oModel:GetModel('FLFMASTER')
		
		oModelFLF:SetValue('FLF_PARTIC'	,MV_PAR01)
		oModelFLF:SetValue('FLF_NOMEPA'	,Posicione("RD0",1,xFilial("RD0")+MV_PAR01,"RD0_NOME"))
		
		oView:Refresh()
		
	Else
		Help("  ",1,"F677UINVP",,STR0139,1,0) //"Este usuário não é um substituto para prestação de contas do participante selecionado"
	EndIf
				
EndIf

//Restaura o pergunte
Pergunte("F677REC",.F.)

Return

//--------------------------------------------
/*/{Protheus.doc}F677GetUPC
Retorna o(s) usuário(s) viajantes que o aprovador direto ou aprovador substituto
da prestação de contas tem acesso.

@Param cUser, char, usuário aprovador logado
@return aRet, usuário(s) viajante(s) 

@since  25/11/2020
@version 12
/*/
//--------------------------------------------
Function F677GetUPC(cUser As Char)
	Local cQry As Char
	Local aRet As Array
	Local cTbl As Char
	//Inicializa variáveis.
	aRet := {}
	
	//Valores default
	Default cUser := ""
	
	If !Empty(cUser) .And. RD0->(FieldPos("RD0_USRPRE")) > 0
		cQry := "SELECT RD0_CODIGO FROM " + RetSqlName("RD0")  + " RD0 "
		cQry += "WHERE RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry += "AND (RD0.RD0_USRPRE = '" + cUser + "' "
		cQry += "OR (RD0.RD0_APROPC = '" + cUser + "' "
		cQry += "AND RD0.RD0_USRPRE = '" + PadR("", TamSx3("RD0_USRPRE")[1]) + "')) " 
		cQry += "AND RD0.D_E_L_E_T_ = ' ' "
		cQry += "ORDER BY RD0_CODIGO"		
		cQry := ChangeQuery(cQry)		
		cTbl := MpSysOpenQuery(cQry)		
		
		While (cTbl)->(!Eof()) .And. !Empty((cTbl)->RD0_CODIGO)
			aAdd(aRet, (cTbl)->RD0_CODIGO)
			(cTbl)->(DbSkip())
		EndDo
		
		(cTbl)->(dbCloseArea())
	Endif

Return aRet

/*/{Protheus.doc} F677NomePa
Função executada pelo gatilho para retornar o nome do participante.
@author William Matos Gundim Jr.
@since 07/08/2014
/*/
Function F677NomePa()
Local cRet := ""
Local aArea := GetArea()

dbSelectArea('RD0')
If RD0->(dbSeek( xFilial("RD0") + M->FLF_PARTIC))
	cRet := RD0->RD0_NOME
EndIf

RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F687FLESX5
Consulta Especifica de Locais FLELOC - SX5³

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
Function F677FLESX5()
Local oModel := FWModelActive() //Modelo de dados ativo.
Local cNacion := oModel:Getvalue('FLFMASTER','FLF_NACION')

_bRet := FiltraSX5(cNacion)

Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltraSX5(cNacion)
Filtro de Locais na tabela SX5

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/

Static Function FiltraSX5(cNacion)
	
Local cAlias1 := CriaTrab(Nil,.F.) // Nome do arquivo temporario
Local cQry    := ""
Local cChave  := SX5->(Indexkey())
Local oLstSX5 := nil
Local nX 	  := 0
Private oDlgSX5	  := nil
Private _bRet	  := .F.
Private aDadosSX5 := {}
Private aStru     := SX5->(dbStruct())
Private cLocal    := If(cNacion="1","12","BH")

If _oFINA6771 <> Nil
	_oFINA6771:Delete()
	_oFINA6771:= Nil
EndIf

// -- Cria tabela temporaria
_oFINA6771 := FwTemporaryTable():New(cAlias1)
_oFINA6771:SetFields(aStru)
_oFINA6771:AddIndex("1",StrToKarr( cChave, "+"))
_oFINA6771:Create()
// -- 

//Query de marca x produto x referencia
cQry += " SELECT "
For nX:= 1 to Len(aStru)
	cQry += aStru[nX,1]+", "
Next
cQry += " R_E_C_N_O_ RECNO "
cQry += " FROM " + RetSqlName("SX5") + " SX5 WHERE "
If cNacion == "1"
	cQry += " SX5.X5_TABELA = '12' " 
Else
	cQry += " SX5.X5_TABELA IN('12','BH') "
EndIf

cQry += " AND SX5.D_E_L_E_T_ = ' ' " 

cQry := ChangeQuery(cQry)

MPSysOpenQuery(cQry, cAlias1)

(cAlias1)->(DbGoTop())
If (cAlias1)->(Eof())
	Help("  ",1,"NEXISTCON",,STR0130,1,0) //"Não existe dados a consultar"
	Return .F.
Endif
	
Do While (cAlias1)->(!Eof())

aAdd( aDadosSX5, { (cAlias1)->X5_CHAVE, (cAlias1)->X5_DESCRI } )

(cAlias1)->(DbSkip())

Enddo

(cAlias1)->(DbCloseArea())

nList := aScan(aDadosSX5, {|x| Alltrim(x[1]) == cLocal })

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgSX5 Title STR0134 From 0,0 To 280, 500 Of oMainWnd Pixel

@ 5,5 LISTBOX oLstSX5 ;
VAR lVarMat ;
Fields HEADER STR0135, STR0133;
SIZE 245,110 On DblClick ( ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ) ;
OF oDlgSX5 PIXEL

oLstSX5:SetArray(aDadosSX5)
oLstSX5:nAt := nList
oLstSX5:bLine := { || {aDadosSX5[oLstSX5:nAt,1], aDadosSX5[oLstSX5:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ENABLE OF oDlgSX5
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgSX5:End() ENABLE OF oDlgSX5

Activate MSDialog oDlgSX5 Centered
	
Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ConfSX5(_nPos, aDadosSX5, _bRet)
Retorno da Consulta Especifica de Locais SX5³

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/

Static Function ConfSX5(_nPos, aDadosSX5, _bRet)
	
__cRetLocal  := aDadosSX5[_nPos,1]

_bRet := .T.

oDlgSX5:End()

Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F677RLOCAL
Retorno da Consulta Especifica de Locais FWDLOC - SX5³
Retorna o codigo Estado ou do Pais
@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
FUNCTION F677RLOCAL()
	 	
RETURN __cRetLocal

//-------------------------------------------------------------------
/*/{Protheus.doc} F677FLEDES
Consulta Especifica de Locais FLEDESP - FLG

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
Function F677FLEDES()
	
Local oModel := FWModelActive() //Modelo de dados ativo.
Local cFLE_LOCAL  := oModel:Getvalue('FLEDETAIL','FLE_LOCAL')
Local cFLF_TIPOPC := oModel:Getvalue('FLFMASTER','FLF_TIPO')
Local cFLF_NACION := oModel:Getvalue('FLFMASTER','FLF_NACION')
Local aGetArea := GetArea()

_bRet := FiltraFLG(cFLE_LOCAL,cFLF_NACION,cFLF_TIPOPC)

RestArea(aGetArea)

Return _bRet

//------------------------------------------------------------------
/*/{Protheus.doc} FiltraFLG(cFLE_LOCAL,cFLF_NACION)
Filtra Despesa na consulta Especifica

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
//-------------------------------------------------------------------
Static Function FiltraFLG(cFLE_LOCAL,cFLF_NACION,cFLF_TIPOPC)
	
Local cQry:=""
Local oLstFLG := nil
Private oDlgFLG := nil
Private _bRet := .F.
Private aDadosFLG := {}
Private __cAliasTrab  := "TRAFLG"
Default cFLF_TIPOPC	  := "0"

//Query de marca x produto x referencia
cQry += " SELECT "
cQry += " FLG.FLG_CODIGO, FLG.FLG_DESCRI,FWC.FWC_DESPES, FWC.FWC_CODIGO, FWD.FWD_CODIGO, FWD.FWD_LOCAL "
cQry += " FROM " + RetSqlName("FLG") + " FLG "
cQry += " INNER JOIN " + RetSqlName("FWC") + " FWC "
cQry += " ON FWC_FILIAL = '"+xFilial('FLG')+"' AND FWC_DESPES = FLG_CODIGO "
cQry += " INNER JOIN " + RetSqlName("FWD") + " FWD "
cQry += " ON FWD_FILIAL = '"+xFilial('FWD')+"' AND FWD_CODIGO = FWC_CODIGO "
cQry += " WHERE FWD_LOCAL = '"+cFLE_LOCAL+"' "
If FLG->( FieldPos("FLG_TIPOPC") ) > 0
	cQry += "AND (FLG_TIPOPC = '"+cFLF_TIPOPC+"' OR FLG_TIPOPC = '0')" // Valida tipo da prest. de contas
EndIf
cQry += " AND FLG.D_E_L_E_T_ = ' ' " 
cQry += " AND FWC.D_E_L_E_T_ = ' ' "
cQry += " AND FWD.D_E_L_E_T_ = ' ' "

cQry := ChangeQuery(cQry)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAliasTrab,.T.,.T.)

dbSelectArea(__cAliasTrab)                                           

(__cAliasTrab)->(DBGOTOP())

If (__cAliasTrab)->(Eof())
	Help("  ",1,"NEXISTCON",,STR0130,1,0) //"Não existe dados a consultar"	
	(__cAliasTrab)->(DbCloseArea())
	Return .F.
Endif

Do While (__cAliasTrab)->(!Eof())

	aAdd( aDadosFLG, { (__cAliasTrab)->FWC_DESPES, (__cAliasTrab)->FLG_DESCRI, cFLE_LOCAL } )

	(__cAliasTrab)->(DbSkip())

Enddo

(__cAliasTrab)->(DbCloseArea())

nList := aScan(aDadosFLG, {|x| Alltrim(x[3]) == cFLE_LOCAL })

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgFLG Title STR0131 From 0,0 To 280, 500 Of oMainWnd Pixel

@ 5,5 LISTBOX oLstFLG ;
VAR lVarMat ;
Fields HEADER STR0132, STR0133;
SIZE 245,110 On DblClick ( ConfFLG(oLstFLG:nAt, @aDadosFLG, @_bRet) ) ;
OF oDlgFLG PIXEL

oLstFLG:SetArray(aDadosFLG)
oLstFLG:nAt := nList
oLstFLG:bLine := { || {aDadosFLG[oLstFLG:nAt,1], aDadosFLG[oLstFLG:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfFLG(oLstFLG:nAt, @aDadosFLG, @_bRet) ENABLE OF oDlgFLG
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgFLG:End() ENABLE OF oDlgFLG

Activate MSDialog oDlgFLG Centered

Return _bRet 

//------------------------------------------------------------------
/*/{Protheus.doc} ConfFLG()
Retorna Descrição das Despesas

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/

Static Function ConfFLG(_nPos, aDadosFLG, _bRet)
	
__cRetDespes  := aDadosFLG[_nPos,1]
__cRetDescDp  := aDadosFLG[_nPos,2]

_bRet := .T.

oDlgFLG:End()

Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F677RDESPE
Retorno da Consulta Especifica de Despesas FLEDESP - FLE ³
Retorna o codigo da Despesa filtrada pelo local

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
FUNCTION F677RDESPE()
	
RETURN __cRetDespes

//------------------------------------------------------------------
/*/{Protheus.doc} F677RDESCD
Retorno da Consulta Especifica de Despesas FLEDESP - FLE ³
Retorna a Descrição do codigo da Despesa filtrada pelo local

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
FUNCTION F677RDESCD()
	
RETURN __cRetDescDp

//------------------------------------------------------------------
/*/{Protheus.doc} F677VLD_DE()
Valida o Local de Despesas

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.5
/*/
Function F677VLD_DE()
Local oModel := FWModelActive() //Modelo de dados ativo.
Local cFLE_LOCAL  := oModel:Getvalue('FLEDETAIL','FLE_LOCAL')
Local cFLF_TIPOPC := oModel:Getvalue('FLFMASTER','FLF_TIPO')
Local cFLE_DESPES := oModel:Getvalue('FLEDETAIL','FLE_DESPES')
Local cNacion	  := oModel:GetValue("FLFMASTER","FLF_NACION")
Local cQry:=""
Local _lRet := .T.
Local __cAliasTrab  := "VLDFLE"
Local aGetArea := GetArea()

//Query de marca x produto x referencia
cQry += " SELECT "
cQry += " FLG.FLG_CODIGO, FLG.FLG_DESCRI, FWC.FWC_DESPES, FWC.FWC_CODIGO, FWD.FWD_CODIGO, FWD.FWD_LOCAL "
cQry += " FROM " + RetSqlName("FLG") + " FLG "
cQry += " INNER JOIN " + RetSqlName("FWC") + " FWC "
cQry += " ON FWC_FILIAL = '"+xFilial('FWC')+"' AND FWC_DESPES = FLG_CODIGO "
cQry += " INNER JOIN " + RetSqlName("FWD") + " FWD "
cQry += " ON FWD_FILIAL = '"+xFilial('FWD')+"' AND FWD_CODIGO = FWC_CODIGO "
cQry += " WHERE FWD_LOCAL = '"+cFLE_LOCAL+"' "	
If !Empty(cNacion)
	cQry += " AND FWD_NACION = '" + cNacion + "'"   
EndIf
cQry += " AND   FLG_CODIGO = '"+cFLE_DESPES+"' "
If FLG->( ColumnPos("FLG_TIPOPC") ) > 0
	cQry += "AND (FLG_TIPOPC = '"+cFLF_TIPOPC+"' OR FLG_TIPOPC = '0')" // Valida tipo da prest. de contas
EndIf
cQry += " AND FLG.D_E_L_E_T_ = ' ' "
cQry += " AND FWC.D_E_L_E_T_ = ' ' "
cQry += " AND FWD.D_E_L_E_T_ = ' ' "

cQry := ChangeQuery(cQry)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAliasTrab,.T.,.T.)

dbSelectArea(__cAliasTrab)                                           

(__cAliasTrab)->(DBGOTOP())

If (__cAliasTrab)->(Eof())
	Help("  ",1,"DESPINVLD",,STR0128,1,0) //"Despesa Invalida para este Local"
	_lRet:= .F.
Endif

(__cAliasTrab)->(DbCloseArea())
RestArea(aGetArea)

ReTurn _lREt


//-------------------------------------------------------------------
/*/{Protheus.doc} F6778BLCt
Gera Lançamento contabil da Prestação de Contas.

@param lEstorno - Indica se o processo é de estorno ou não
Validação chamada do botão OK

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Function F6778BLCt(lEstorno)	
	Local lPadrao 		:= .T.
	Local nHdlPrv 		:= 0
	Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local cLote   		:= LoteCont("FIN")
	Local cArquivo 		:= ""
	Local aFlagCTB 		:= {}
	Local nTotal		:= 0
	Local nPosReg		:= 0
	Local aDiario 		:= {}
	Local aGetArea  	:= GetArea()
	Local cPadrao  		:= ""
	Local cChaveFLE     := ""
	
	Default lEstorno := .F.
	
	cPadrao := If(!lEstorno, "8B3","8B4" ) 
	lPadrao := VerPadrao( cPadrao )
	
	If lPadrao .And. mv_par02 == 1		
		cChaveFLE := xFilial("FLE") + FLF->(FLF_TIPO+FLF_PRESTA+FLF_PARTIC)
		nHdlPrv   := HeadProva(cLote, "FINA677" /*cPrograma*/, Substr(cUsuario, 7, 6 ), @cArquivo)
		
		//Posiciona os itens da Prestação para contabilização
		dbSelectArea("FLE")
		FLE->(DbSetOrder(1))		
		FLE->(DbSeek(cChaveFLE))
		
		While !FLE->(Eof()) .And. FLE->(FLE_FILIAL+FLE_TIPO+FLE_PRESTA+FLE_PARTIC) == cChaveFLE			
			//Se o LP não é de Estorno e ja foi contabilizado pula para o proximo registro
			If FLE->FLE_LA == "S" .And. !lEstorno 
				FLE->(DbSkip())
				Loop							
			EndIf
			
			//Prepara Lancamento Contabil
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd(aFlagCTB, {"FLE_LA", If(!lEstorno, 'S', ''), "FLE", FLE->(Recno()), 0, 0, 0})
			Endif
			
			nTotal += DetProva(nHdlPrv, cPadrao, "FINA677", cLote,,,,,,,,@aFlagCTB, {'FLE', FLE->(Recno())})
			
			If LanceiCtb .And. !lUsaFlag //Vem do DetProva
				RecLock("FLE")
				FLE->FLE_LA := If(!lEstorno,"S"," ")
				FLE->(MsUnlock())
			ElseIf !LanceiCtb .And. lUsaFlag .And. (nPosReg  := aScan(aFlagCTB, {|x|x[4] == FLE->(Recno()) })) > 0 
				aFlagCTB := Adel(aFlagCTB, nPosReg)
				aFlagCTB := aSize(aFlagCTB, Len(aFlagCTB)-1)
			EndIf
			
			FLE->(DbSkip())
		EndDo
	EndIf
	
	cPadrao := If(!lEstorno, "8B5","8B6" ) 
	lPadrao := VerPadrao(cPadrao)
		
	If lPadrao .And. mv_par02 == 1 .And. ((lEstorno .And. FLF->FLF_LA == 'S') .Or. (!lEstorno .And. FLF->FLF_LA != "S"))	                                   
		If nHdlPrv == 0 
			nHdlPrv := HeadProva(cLote, "FINA677" /*cPrograma*/, Substr(cUsuario, 7, 6 ), @cArquivo)
		EndIf
		
		If lUsaFlag  
			aAdd( aFlagCTB, {'FLF_LA', If(!lEstorno,'S',''), 'FLF', FLF->(Recno()) ,0,0,0})
		Endif
		
		nTotal += DetProva(nHdlPrv, cPadrao, "FINA677", cLote,,,,,,,,@aFlagCTB, {'FLF', FLF->(Recno())})
		
		If LanceiCtb .And. !lUsaFlag //Vem do DetProva
			RecLock("FLF")
			FLF->FLF_LA := If(lEstorno, "", "S")
			FLF->(MsUnlock())
		ElseIf !LanceiCtb .And. lUsaFlag .And. (nPosReg  := aScan(aFlagCTB, {|x|x[4] == FLF->(Recno()) })) > 0 
			aFlagCTB := Adel(aFlagCTB, nPosReg)
			aFlagCTB := aSize(aFlagCTB, Len(aFlagCTB)-1)
		EndIf
	EndIf	    	
	
	//Efetiva Lançamento Contabil
	If nHdlPrv > 0 .and. nTotal > 0	
		RodaProva(nHdlPrv, nTotal)	
		
		//Gera o lançamento contábil
		cA100Incl(cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, mv_par03 == 1 /*lDigita*/, mv_par04 == 1 /*lAglut*/, /*cOnLine*/, /*dData*/,;
		/*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario)
		
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	Endif
	
	RestArea(aGetArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} F677BCENT(cTipo)
Busca Entidades Contabeis

@author Antonio Florêncio Domingos Filho
@since 11/05/2015
@version 12.1.6
/*/

Function F677BCENT(cTipo)
	
Local oModel := FWModelActive()
Local CFLE_DESPES := oModel:GetValue('FLEDETAIL','FLE_DESPES')
Local cRet        := " "
Local aGetArea    := GetArea()
		
dbSelectArea("FLG")
dbSetOrder(1)
dbSeek(xFilial("FLG")+CFLE_DESPES)
If Found()
	If cTipo == '1'
		cRet:=FLG->FLG_CONTA
	ElseIf cTipo == '2'
		cRet:=FLG->FLG_CUSTO
	Elseif cTipo == '3'
		cRet:=FLG->FLG_ITECTB
	ElseIf cTipo == '4'
		cRet := FLG->FLG_CLVL
	EndIf
EndIf

RestArea(aGetArea)

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} F677TxMoed()
Gatilho do FLE_TXCONV

@author Mauricio Pequim Jr
@since 08/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function F677TxMoed()

Local oModel 	:= FWModelActive()
Local oModelFLE	:= oModel:GetModel("FLEDETAIL")
Local CFLE_MOEDA := oModel:GetValue('FLEDETAIL','FLE_MOEDA')

//Caso eu informe a moeda como 9 = Outras moedas e informe a taxa de conversão
//e logo depois eu mude a moeda para Real, Dolar ou Euro 
//tenho que zerar a taxa de conversão
If !(F677When(oModel,'FLE_TXCONV')) .and. CFLE_MOEDA != '9' 
	oModelFLE:LoadValue('FLE_TXCONV',0)
Endif
	
Return CFLE_MOEDA


//-------------------------------------------------------------------
/*/{Protheus.doc} F677GetCot()
Retorna taxatipo de taxa utilizada para prestação de contas

@author Mauricio Pequim Jr
@since 08/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Function F677GetCot(oModel,nTxDolar,nTxEuro)

Local dDtTxMoed := CTOD("//")
Local oModelFLF := oModel:GetModel("FLFMASTER")
Local dDtIni	:= oModelFLF:GetValue("FLF_DTINI")
Local dDtFim	:= oModelFLF:GetValue("FLF_DTFIM")
Local nTpTxPct	:= SuperGetMv("MV_TPTXPCT",,1)	//Tipo de taxa da prestação de contas

DEFAULT nTxDolar := oModelFLF:GetValue("FLF_TXTUR2")
DEFAULT nTxEuro  := oModelFLF:GetValue("FLF_TXTUR3") 		

If nTpTxPct > 1
	//Verifico se devo obter a taxa da data inicial ou a final da viagem ou prestação avulsa		
	dDtTxMoed	:= If(nTpTxPct == 2, dDtIni,dDtFim)
	//Obtenho qual a moeda do sistema representa o Dolar
	nMoeda 		:= f677GetMoeda(1)
	//Obtenho a taxa moeda do SM2 na data parametrizada
	nTxDolar	:= RecMoeda(dDtTxMoed,nMoeda)
	//Obtenho qual a moeda do sistema representa o Euro
	nMoeda		:= f677GetMoeda(2)
	//Obtenho a taxa moeda do SM2 na data parametrizada		
	nTxEuro		:= RecMoeda(dDtTxMoed,nMoeda)		 
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F677SUMUSD
Fornula do Saldo

@author Mauricio Pequim Jr

@since 13/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F677SUMUSD(oModel,cCampo)

Local nRet		:= 0
Local oModelFLE	:= oModel:GetModel("FLEDETAIL")
Local cMoeda	:= '1'
Local nX		:= 0
Local nTxConv	:= 0
Local aSaveLines  := FWSaveRows()

For nX := 1 To oModelFLE:Length()
	oModelFLE:GoLine( nX )
	If !(oModelFLE:IsDeleted())
		cMoeda	:= oModelFLE:GetValue("FLE_MOEDA")
		If cMoeda == '2'
			nRet += oModelFLE:GetValue(cCampo)
		ElseIf cMoeda == '9'
			nTxConv	:= oModelFLE:GetValue("FLE_TXCONV")
			nRet += oModelFLE:GetValue(cCampo) / iF(nTxConv == 0, 1, nTxConv)
		EndIf
	Endif
Next nX

FWRestRows(aSaveLines)

Return nRet

/*/{Protheus.doc} F677TXMD
Função executada pelo gatilho para retornar a taxa da moeda
@author Daniel Mendes
@since 01/07/2015
/*/
Function F677TXMD()
Local nVlrMd    := 0
Local oModel    := FWModelActive()
Local oModelFLE := oModel:GetModel( "FLEDETAIL" )
Local cMoeda    := oModelFLE:GetValue( "FLE_MOEDA" )
Local dData     := oModelFLE:GetValue( "FLE_DATA"   ) 

If !Empty( cMoeda ) .And. cMoeda <> "9" .And. !Empty( dData )
	nVlrMd := RecMoeda( dDataBase, cMoeda )
EndIf

lWhenTaxa := .T.

Return nVlrMd


/*/{Protheus.doc} F677XML
Função para chamar a consulta padrão para buscar o arquivo XML. 
Requisito: PCREQ-7672 - Prestação de Contas - Mexico
Retorno: UUID/RFC 
@author Simone Mie Sato Kakinoana 
@since 28/10/2015
/*/
Function F677XML()

Local aSaveArea	:= GetArea()
Local cTipo		:=  STR0147//"Arquivos XML|*.XML"
Local cArq		:= ""	// Arquivo XML LOCAL onde estarao as informacoes do UUID e RFC

Private oXML	:= NIL	// XML que sera parseado

cArq := cGetFile(cTipo,STR0148,0,"",.F.,GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE,.T.,.T.)//Selecione arquivos do tipo XML

If Empty(cArq)
	MsgStop(STR0149)	//"Archivo no seleccionado!"
	Return(.F.)
Else
	//-------------------------------------------------------------------
	// Efetuo a copia do arquivo pois a funcao XMLPARSERFILE funciona  // 
	// apenas se o arquivo estiver em um diretorio dentro do RootPath  //
	//-------------------------------------------------------------------	
	If __CopyFile( cArq, cMoveArq )
		F677Parse()
		//----------------------------
		// Remove arquivo da pasta  //
		//----------------------------
		fErase( cMoveArq )		
	Else
		MsgStop(STR0150) //"Falha na copia do arquivo XML para o RootPath do Protheus!"
		Return(.F.)	
	EndIf		
EndIf

RestArea( aSaveArea )

Return( .T. )
 
/*/{Protheus.doc} F677Parse
Parse do XML e captura dos dados. 
Requisito: PCREQ-7672 - Prestação de Contas - Mexico
@author Simone Mie Sato Kakinoana 
@since 28/10/2015
/*/
Static Function F677Parse()

Local cErrMsg	:= ""
Local cWrnMsg	:= ""
Local cUUID		:= ""	// Dados do UUID
Local cRFC		:= ""	// Dados do RFC


//--------------------------
// Realiza o PARSE do XML //
//--------------------------
oXml := XmlParserFile( cMoveArq, "_", @cErrMsg, @cWrnMsg )

If oXml == NIL
	MsgStop(STR0151)//Falha na captura dos dados do XML!
	Return(.F.)
Else
	//------------------
	// Atualiza UUID  //
	//------------------
	If !Type("oXml:_CFDI_COMPROBANTE") == "U"
		If !Type("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO") == "U"
			If 	!Type("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL") == "U"
				If !Type("oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID") == "U"
					cUUID := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
				EndIf	
			EndIf	
		EndIf
		//------------------
		// Atualiza RFC   //
		//------------------
		If !Type("oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR") == "U"
			If !Type("oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC") == "U"			
				cRFC := oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT
			EndIf	
		EndIf
	Else
		MsgStop(STR0152)//"Este XML nao possui a estrutura necessaria para a captura dos campos UUID e RFC!"
	EndIf		
EndIf

If F677CHUUID( cUUID)
	a_UUIDRFC := { cUUID, cRFC }
	lRetXML	:= .T.
Else
	a_UUIDRFC := { "", "" }
	lRetXML	:= .F.
EndIf

Return()

/*/{Protheus.doc} F677UIDRFC
Retorno para Consulta padrão - somente para MEXICO 
Requisito: PCREQ-7672 - Prestação de Contas - Mexico
@author Simone Mie Sato Kakinoana 
@since 29/10/2015
/*/
Function F677UIDRFC() 

Return( a_UUIDRFC )

/*/{Protheus.doc} F677VlUUID
Verifica se o código UUID foi digitado ou preenchido atráves da consulta padrão. 
Requisito: PCREQ-7672 - Prestação de Contas - Mexico
@author Simone Mie Sato Kakinoana 
@since 29/10/2015
/*/
Function F677VlUUID(cUUID)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If !lRetXML
	Help(" ",1,"F677NODIGIT",,STR0153,1,0) // "O codigo UUID pode ser preenchido somente através da escolha de um arquivo a ser importado. Não é permitida a digitação manual."
	lRet	:= .F.	
EndIf

lRetXML	:= .F.

RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} F677CHUUID
Valida se já existe UUID digitado em alguma prestação de contas. 
Requisito: PCREQ-7672 - Prestação de Contas - Mexico
@author Simone Mie Sato Kakinoana 
@since 29/10/2015
/*/
Function F677CHUUID(cUUID)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local aSaveLines:= FWSaveRows()
Local oModelTmp	:= FWModelActive()
Local oModelFLE	:= oModelTmp:GetModel("FLEDETAIL")
Local nLinAtu	:= oModelFLE:GetLine()
Local cUUIDAtu	:= ""
Local cMensagem	:= ""
Local cNumPrest	:= ""
Local lRepete	:= .F.

Local nX		:= 0 

If lRet
	For nX := 1 to oModelFLE:Length()
	
		If nX == nLinAtu
			Loop
		EndIf
		
		oModelFLE:GoLine(nX)

		cUUIDAtu	:= Alltrim(oModelFLE:GetValue("FLE_UUID"))
			
		If !oModelFLE:IsDeleted()
			
			If Alltrim(cUUID) == cUUIdAtu
				cMensagem	:= STR0154 + CRLF						// "O codigo UUID pode ser utilizado somente uma vez."
				cMensagem	+= STR0155 + Alltrim(str(nX))+"."	//"Esse código já foi utilizado na linha "				
				Help(" ",1,"F677JAUSA1",,cMensagem,1,0)
				cMensagem	:= ""		
				lRet := .F.
				lRetXML		:= .F.
				Exit
			EndIf
		
		EndIf
	Next nX
	
	oModelFLE:GoLine(nLinAtu)
Endif

If lRet
	cQuery := " SELECT DISTINCT FLE_PRESTA "
	cQuery += " FROM " + RetSqlName("FLE")
	cQuery += " WHERE FLE_FILIAL ='"+xFilial("FLE")+"' "
	cQuery += " AND FLE_PRESTA <> '"+oModelFLE:GetValue("FLE_PRESTA")+"' "
	cQuery += " AND FLE_PARTIC <> '"+oModelFLE:GetValue("FLE_PARTIC")+"' "
	cQuery += " AND FLE_UUID = '"+Alltrim(cUUID) +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	If ( Select(cAliasQry) > 0 )
		DbCloseArea()
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )
	
	While (cAliasQry)->(!Eof())
		lRepete	:= .T.
		cNumPrest += (cAliasQry)->FLE_PRESTA
	
	 	dbSkip()
	 	If (cAliasQry)->(!Eof())
	 		cNumPrest += " / "
	 	EndIf
	End
	
	If lRepete

		cMensagem	:= STR0154 + CRLF				// "O codigo UUID pode ser utilizado somente uma vez."
		cMensagem	+= STR0156 + Alltrim(cNumPrest)+"."	// "Esse código já foi utilizado na prestação de contas: "
		Help(" ",1,"F677JAUSA2",,cMensagem,1,0)
		cMensagem	:= ""
		cNumPrest	:= ""		
		lRet 		:= .F.	
		lRetXML		:= .F.
	Else
		lRet	:= .T.
	EndIf
	 
	If ( Select(cAliasQry) > 0 )
		DbSelectArea(cAliasQry)
		DbCloseArea()
	EndIf
EndIf

lRetXML	:= .F.

FWRestRows(aSaveLines)

RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} F677ENVWF
Executa o modelo FINA677 como alteração para o reenvio do Workflow,
caso o serviço do Fluig esta fora do ar no fluxo padrão da prestação de conta
e não tenho conseguido subir Workflow para o Fluig.   
@author lucas.oliveira
@since 19/11/2015
/*/
Function F677ENVWF()
Local aArea         := GetArea()
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0091},{.T.,STR0090},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk				:= {||}
Local cProcWF		:= 'APVPRESTCO'
/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Conferência (.T. or .F.)
	aAprv[2] - Aprovação Gestor (.T. or .F.)
	aAprv[3] - Lib. Financeiro (.T. or .F.)
*/
If __lMTFLUIGATV
	If MTFluigAtv("WFFINA677", cProcWF, "WFFIN677" )
		FLF->(MsRLock())
	
		SaveInter() // Salva variaveis publicas
		pergunte("F677REC",.F.)
	
		__nOper      	:= OPER_ENVWF
		cTitulo      	:= STR0101
		cPrograma    	:= 'FINA677'
		nOperation   	:= MODEL_OPERATION_UPDATE
		__lConfReprova 	:= .F.
		bOk          	:= {|| .T. } 
		nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
		__nOper      	:= 0
	
		RestInter() // Restaura variaveis publicas
		Set Key VK_F12 To
	
		FLF->(MsRUnlock())
	EndIf
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} F677DesCtb
Função responsavel por preencher a descrição da classe de valor e item contabil. 
@author william.gundim
@since 12/05/16
/*/
Function F677DesCtb(oView, cIDView, cField, xValue)
Local oModel := FWModelActive()
	If !Empty(xValue) 	
		If cField == 'FLF_CLVL'
			oModel:SetValue('FLFMASTER','FLF_DSCLVL', Posicione("CTH",1,xFilial("CTH") + xValue ,"CTH_DESC01") )
		Else
			oModel:SetValue('FLFMASTER','FLF_DSITCT', Posicione("CTD",1,xFilial("CTD") + xValue ,"CTD_DESC01") )			
		EndIf
	EndIf
	oView:Refresh()
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F677VLDLOC
Função responsavel por validar local da prestação de conta
@author alvaro.camillo
@since 12/05/16
/*/
//-------------------------------------------------------------------
Function F677VLDLOC()
Local oModel	:= FWModelActive() //Modelo de dados ativo.
Local cNacion	:= oModel:Getvalue('FLFMASTER','FLF_NACION')
Local cLocal	:= oModel:Getvalue('FLEDETAIL','FLE_LOCAL')
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSX5	:= SX5->(GetArea())

dbSelectArea("SX5")
SX5->(dbSetOrder(1))
If cNacion == '1'
	If ! (SX5->(dbSeek( xFilial("SX5") + '12' + cLocal )))
		Help(" ",1,"RECNO")
		lRet := .F.
	Endif
Else
	If ! (SX5->(dbSeek( xFilial("SX5") + '12' + cLocal ))) .AND. ! (SX5->(dbSeek( xFilial("SX5") + 'BH' + cLocal )))
		Help(" ",1,"RECNO")
		lRet := .F.
	Endif
EndIf

RestArea(aAreaSX5)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F677AltSrNt
Função responsavel por permitir que o usuario altere a Serie e a Nota
da Prestação de contas.
  
@author Rodrigo Alexandrino Pirolo
@since 08/11/2016
/*/
//-------------------------------------------------------------------

Function F677AltSrNt(oView)

Local oModel	:= FWModelActive() //Modelo de dados ativo.
Local oModelFLF	:= oModel:GetModel('FLFMASTER')
Local cPartic	:= oModelFLF:GetValue('FLF_PARTIC')
Local lRet		:= .T.
Local aExt		:= {}
Local aAprv 	:= FResAprov("2")//2 - Prestação de Contas
Local aArea		:= GetArea()
Local aAreaRD0	:= RD0->(GetArea())

DbSelectArea('RD0')

Pergunte("F677REC",.F.)
If (MV_PAR05 == 1 .OR. !aAprv[3]) .AND. RD0->( DbSeek( xFilial('RD0') + cPartic ) ) .AND. RD0->RD0_TIPO == '2'
	
	If F667Externo(aExt)
		//Grava valores no campo doc e serie.
		oModelFLF:LoadValue('FLF_SERIE'	, aExt[1] )
		oModelFLF:LoadValue('FLF_DOC'	, aExt[2] )
	EndIf

Else
	Help("  ",1,"F677AltSrNt",,STR0178,1,0) //STR0178 "Função disponível apenas Prestações de Contas com Participantes cadastrados como 'Externo'."
EndIf

RestArea(aAreaRD0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DocView
Funcao executada apos confirmacao do formulario.
Exibe tela para preenchimento do documento e serie
  
@author igor.nascimento
@since 02/02/2017
/*/
//-------------------------------------------------------------------

Static Function DocView()

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFLF		:= oModel:GetModel("FLFMASTER")
Local aExt			:= {}
Local aArea			:= GetArea()
Local aAprv 		:= FResAprov("2")//2 - Prestação de Contas

Pergunte("F677REC",.F.)
If (MV_PAR05 == 1 .OR. !aAprv[3]) .AND. RD0->(dbSeek( xFilial('RD0') + oModelFLF:GetValue('FLF_PARTIC') )) .AND. RD0->RD0_TIPO == '2'
	If F667Externo(aExt)
		//Grava valores no campo doc e serie.
		oModelFLF:LoadValue('FLF_SERIE', aExt[1]	)
		oModelFLF:LoadValue('FLF_DOC'  , aExt[2]	)
	Else
		lRet := .F.	
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN677Oper
Define a operação quando executado pelo Robô de Testes 

@author Automacao 
@since  24/05/2016
/*/
//-------------------------------------------------------------------
Function FN677Oper(nOper) 

__nOper := nOper
lAutomato	 := .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FAdtMsg
Apresenta mensagem especifica de acordo com o parametro passado,
verifico se é executado via tela para que 

@author Rodrigo.Pirolo 
@since  29/01/2019
/*/
//-------------------------------------------------------------------

Static Function FN677AdtM( nMsg )

Local lRet		:= .T.

Default nMsg	:= 1

If !IsBlind()
	
	If nMsg == 1
		lRet := MsgYesNo( STR0055 + CRLF + CRLF + STR0056 )
	ElseIf nMsg == 2
		lRet := MsgYesNo( STR0140 )
	ElseIf nMsg == 3
		lRet := MsgYesNo( STR0141 )
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFieldV()
//	Inclui campo Virtual para tratamento dos Anexos
@author Mario A. Cavenaghi
@since 06/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Static Function AddFieldV(nOpcao, oStru, cCampo, nPos)

Local cPos

//	FLE_FILE
Local cTitulo := "Comprovante"
Local cDescricao := "Arquivo do Comprovante"
Local cTipo := "C"
Local cPicture := ""
Local cTamanho := 255
Local bIni := {|| " "}
Local bWhen := {|| .T.}
Local bValid := {|| .T.}

If     cCampo == "FLE_STATUS"
	cTitulo := "Status"
	cDescricao := "Status"
	cTamanho := 1
	bIni := {|| "1"}

ElseIf cCampo == "FLE_ANEXO"
	cTitulo := "Anexo"
	cDescricao := "Tem Anexo"
	cTamanho := 5
	cPicture := "@BMP"

ElseIf cCampo == "FLE_RECNO"
	cTitulo := "Recno"
	cDescricao := "Registro Gravado"
	cTipo := "N"
	cTamanho := 9
	bIni := {|| 0}
EndIf

If     nOpcao == 1  // Model
	oStru:AddField(;
		cTitulo, ;      // [01]  C   Titulo do campo
		cTitulo, ;      // [02]  C   ToolTip do campo
		cCampo, ;       // [03]  C   Id do campo
		cTipo, ;        // [04]  C   Tipo do campo
		cTamanho, ;     // [05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
		0, ;            // [06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
		bValid, ;       // [07]  B   Code-block de validação do campo
		bWhen, ;        // [08]  B   Code-block de validação When do campo
		, ;             // [09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
		.F., ;          // [10]  L   Indica se o campo tem preenchimento obrigatório
		bIni, ;         // [11]  B   Code-block de inicializacao do campo
		, ;             // [12]  L   Indica se trata-se de um campo chave
		.T., ;          // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.)            // [14]  L   Indica se o campo é Virtual

ElseIf nOpcao == 2  // View
	cPos := Alltrim(StrZero(nPos, 2))
	oStru:AddField(;
		cCampo, ;       // [01]  C   Nome do Campo
		cPos, ;         // [02]  C   Ordem
		cTitulo, ;      // [03]  C   Titulo do campo
		cDescricao, ;   // [04]  C   Descricao do campo
		, ;             // [05]  A   Array com Help
		cTipo,;         // [06]  C   Tipo do campo
		cPicture, ;     // [07]  C   Picture
		, ;             // [08]  B   Bloco de Picture Var
		, ;             // [09]  C   Consulta F3
		.F., ;          // [10]  L   Indica se o campo é alteravel
		, ;             // [11]  C   Pasta do campo
		, ;             // [12]  C   Agrupamento do campo
		, ;             // [13]  A   Lista de valores permitido do campo (Combo)
		, ;             // [14]  N   Tamanho maximo da maior opção do combo
		, ;             // [15]  C   Inicializador de Browse
		.T., ;          // [16]  L   Indica se o campo é Virtual
		, ;             // [17]  C   Picture Variavel
		.T.)            // [18]  L   Indica pulo de linha após o campo

EndIf

Return

/*/{Protheus.doc} DbClick()
Retorna o Caminho e Arquivo, do Anexo selecionado para novos registros ou executa Banco de Conhecimentos dos já Gravados ou Exibe as Legendas disponíveis.

@type		function
@since 		06/03/2018
@author 	Mario A. Cavenaghi
@version 	V12.1.21
/*/
Static Function DbClick(oMod, cCampo, nLinGrid, nLinMod)

	Local cFileDoc	:= ""
	Local cStatus 	:= ""
	Local nOpcao 	:= 0
	Local oModelFLE	:= Nil
	Local nRecno	:= 0
	Local aFile     := {}

	If cCampo == "FLE_ANEXO"
		oModelFLE := oMod:GetModel("FLEDETAIL")
		cStatus	:= oModelFLE:GetValue("FLE_STATUS")
		nRecno	:= oModelFLE:GetValue("FLE_RECNO")
		FLE->(DbGoTo(nRecno))
		If __nOper == OPER_INCLUI .or. __nOper == OPER_ALTERA
			If !Empty(oModelFLE:GetValue("FLE_ANEXO"))
				Define MsDialog oDlg Title STR0181 From 0,0 To 150, 310 Pixel
				@ 15, 55 Say    STR0187 Size 100, 10 Pixel Of oDlg	//	###"Selecione uma ação"
				@ 40, 25 Button STR0011 Size 040, 10 Pixel Of oDlg Action (nOpcao := 2, Odlg:End())	//	###"Visualizar"
				@ 40, 90 Button STR0014 Size 040, 10 Pixel Of oDlg Action (nOpcao := 1, Odlg:End())	//	###"Excluir"
				Activate MSDialog oDlg Centered
				aFile := PosMsDoc("FLE", oModelFLE)	//	Posiciona e Retorna chave de Relacionamento no Banco de Conhecimentos
				If nOpcao == 2
					If (__nOper == OPER_INCLUI .or. __nOper == OPER_ALTERA) .and. __lHTML .and. !aFile[2]
						VisuTmp(oModelFLE:GetValue("FLE_FILE")) //Somente para smartclient HTML, copia o arquivo para um apasta temporária, para conseguir ver o upload antes de confirmar a prestação de contas												
					Else
						VisuAnexo(oModelFLE:GetValue("FLE_FILE"))	//	Visualiza Anexo
					Endif

				ElseIf nOpcao == 1
					If cStatus == "4"
						ExclAnexo(Select("xAC9"))	//	Apaga Anexo
					EndIf
					cStatus := Iif(cStatus == "2", "1", "3")
					oModelFLE:LoadValue("FLE_STATUS", cStatus)
					oModelFLE:LoadValue("FLE_ANEXO" , " ")
					oModelFLE:LoadValue("FLE_FILE"  , " ")
					oMod:Refresh()
				EndIf
			Else	//	Sem Anexo
				cFileDoc := cGetFile("*.*", STR0181,,, .T., GETF_LOCALHARD, .T.)	//	###"Anexar Comprovante"				
				If !Empty(cFileDoc)
					oModelFLE:LoadValue("FLE_ANEXO", "CLIPS")
					oModelFLE:LoadValue("FLE_FILE" , cFileDoc)
					If cStatus == "1"
						oModelFLE:LoadValue("FLE_STATUS", "2")
						If Empty(oModelFLE:GetValue("FLE_FILIAL"))	//	Se for alteração os Campos dos Itens novos estão vindo em BRANCO
							oModelFLE:LoadValue("FLE_FILIAL", xFilial("FLE"))
							oModelFLE:LoadValue("FLE_TIPO"  , M->FLF_TIPO)
							oModelFLE:LoadValue("FLE_PRESTA", M->FLF_PRESTA)
							oModelFLE:LoadValue("FLE_PARTIC", M->FLF_PARTIC)
						EndIf
					EndIf
					oMod:Refresh()

					
					If (__nOper == OPER_INCLUI .or. __nOper == OPER_ALTERA) .and. __lHTML						
						VisuTmp(cFileDoc) //Somente para smartclient HTML, copia o arquivo para um apasta temporária, para conseguir ver o upload antes de confirmar a prestação de contas												
					Else
						VisuAnexo(cFileDoc)	//	Visualiza Anexo
					Endif				
					
				EndIf
			EndIf
		ElseIf !Empty(oModelFLE:GetValue("FLE_ANEXO"))
			PosMsDoc("FLE", oModelFLE)	//	Posiciona no Banco de Conhecimentos
			VisuAnexo()	//	Visualiza Anexo			
		EndIf
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} F677Doc()
//	Visualiza Todos Anexos da Prestação
@author Mario A. Cavenaghi
@since 06/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Function F677Doc(oMod)

If FLF->(Eof())
	If ValType(oMod) <> "O"
		oMod := FWModelActive()
	EndIf
	oModelFLF := oMod:GetModel("FLFMASTER")
	SIX->(dbSeek("FLF"))
	cChave := PosMsDoc("FLF", oModelFLF)[1]
	FLF->(dbSeek(cChave))
EndIf
MsDocument("FLF", FLF->(Recno()), 1)	//	Só Visual

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAnexo()
//	Gravação dos Anexos no Banco de Conhecimento (MsDocument)
@author Mario A. Cavenaghi
@since 06/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Static Function GrvAnexo(oMod)

Local aSaveLines := {}
Local oObj
Local lRet := .F.
Local cCodObj := ""
Local cCodEnt := ""
Local cFileDoc := ""
Local cFileName := ""
Local cValidName:= ""
Local cFileDest := ""
Local cFilePath := ""
Local cExt		:= ""
Local nX   := 0
Local nY   := 0
Local nI   := 1
Local nLen := 0
Local cDirDocs := Alltrim(MsDocPath())	//	Retorna Pasta do Banco de Conhecimentos
Local lValidName := .F.

oModelFLE := oMod:GetModel("FLEDETAIL")
oModelFLF := oMod:GetModel("FLFMASTER")
If Select("xAC9") > 0
	xAC9->(dbCloseArea())
EndIf
Chkfile("AC9")
Chkfile("AC9",, "xAC9")	//	AC9 Auxiliar para trabalhar com outro posicionamento de registro
xAC9->(dbSetOrder(1))	//	AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
aSaveLines  := FWSaveRows()
For nX := 1 To oModelFLE:Length()
	oModelFLE:GoLine(nX)
	cFileDoc := AllTrim(oModelFLE:GetValue("FLE_FILE"))
	cCodEnt := PosMsDoc("FLE", oModelFLE)[1]	//	Posiciona e Retorna chave de Relacionamento no Banco de Conhecimentos
	If !AC9->(Eof())	//	Achou Anexo
		nRecno := AC9->(Recno())
		If oModelFLE:IsDeleted() .Or. oModelFLF:GetOperation() == MODEL_OPERATION_DELETE	//	Se Deletou irá apagar todos os registros relacionados e o Anexo
			ExclAnexo(Select("xAC9"))
		EndIf
	ElseIf !Empty(cFileDoc)	//	Criando Vinculo do Anexo com o Novo Item
		If !FwIsInCallStack("F677ImgApp")	// Esta funcao ja fez decode
			cFileDest := Lower(cDirDocs + "\")
			nLen := Len(cFileDoc)
			For nY := nLen To 1 Step -1
				If SubStr(cFileDoc, nY, 1) == "\"
					Exit
				EndIf
			Next
			cFileName := Right(cFileDoc, nLen - nY)	//	Captura só o Nome do arquivo sem o Caminho
			cFilePath := Left(cFileDoc, nY)
			nY := At(".", cFileName)
			If nY > 0
				cExt	  := SubStr(cFileName,  nY, Len(cFileName))	// Guarda extensao
				cFileName := Left(cFileName,  nY - 1)	//	Deixa Nome do Arquivo sem Extensão
			EndIf
			cValidName := cFileName
			// Garante que o nome do arquivo n?o ir  sobrepor nenhum outro
			While !lValidName
				If File(cFileDest+cValidName+cExt)
					cValidName := cFileName+"("+cValToChar(nI)+")"
				Else
					lValidName := .T.
					If nI > 1
						cFileName := cValidName
					EndIf
				EndIf
				nI++
			EndDo
		
			Processa( { || __CopyFile( cFileDoc, cFileDest + "\" + cFileName+cExt ),lRet := File( cFileDest + "\" + cFileName+cExt ) }, STR0182, STR0183,.F.) //"Transferindo objeto"###"Aguarde..." 			
		
		Else
			nY := At(".", cFileDoc)
			If nY > 0
				cExt	  := SubStr(cFileDoc,  nY, Len(cFileDoc))	// Guarda extensao
				cFileName := Left(cFileDoc,  nY - 1)	//	Deixa Nome do Arquivo sem Extensão
			EndIf
			lRet := .T.
		EndIf
		If lRet	//	Arquivo Transferido com sucesso para Banco de Conhecimentos
			If Empty(oModelFLF:GetValue("FLF_FILIAL"))	//	Na Inclusão a Filial está vindo em BRANCO
				oModelFLF:LoadValue("FLF_FILIAL", xFilial("FLF"))
			EndIf

			//	Grava Cabeçalho do Anexo
			cCodObj := GetSXENum("ACB", "ACB_CODOBJ",, 1)
			ACB->(RecLock("ACB", .T.))
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := cCodObj
			ACB->ACB_OBJETO := cFileName+cExt
			ACB->ACB_DESCRI := cFileName
			ACB->(msUnLock())

			cEntidade := "FLE"	//	1o. Grava a Amarração para o Item da Prestação
			oObj := oModelFLE
			cCodEnt := PosMsDoc(cEntidade, oObj)[1]
			AC9->(RecLock("AC9", .T.))
			AC9->AC9_FILIAL := xFilial("AC9")
			AC9->AC9_CODOBJ := cCodObj
			AC9->AC9_ENTIDA := cEntidade
			AC9->AC9_FILENT := xFilial(cEntidade)
			AC9->AC9_CODENT := cCodEnt
			AC9->(msUnLock())
			oObj := oModelFLF
			ConfirmSx8()

		Else
			Aviso(STR0089, STR0184 + cFileDoc + STR0185, {STR0143}, 2)   //	###"Atencao !"###"Não foi possível efetuar a transferência do arquivo '"###"' para o Banco de Conhecimento !"###"Ok"
		EndIf
	EndIf
Next
FWRestRows(aSaveLines)
If Select("xAC9") > 0
	xAC9->(dbCloseArea())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PosMsDoc()
Se existir, Posiciona no Banco de Conhecimento da Entidade
@author Igor Sousa do Nascimento
@since 04/03/2019
/*/
//-------------------------------------------------------------------
Static Function PosMsDoc(cEntidade, oMod)

	Local aRet	  := Array(2)
	Local cChave  := ""
	
	cChave  := FwXFilial("FLE") + oMod:GetValue("FLE_TIPO") + oMod:GetValue("FLE_PRESTA") + oMod:GetValue("FLE_PARTIC") + oMod:GetValue("FLE_ITEM")

	aRet[1] := cChave
	aRet[2] := .F.
	AC9->(DbSetOrder(2)) // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	If AC9->(DbSeek(FwXFilial("AC9") + cEntidade + FwXFilial(cEntidade) + cChave))
		ACB->(DbSetOrder(1)) //	ACB_FILIAL+ACB_CODOBJ
		ACB->(DbSeek(FwXFilial("ACB") + AC9->AC9_CODOBJ))
		aRet[2] := .T.
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F677Exclui()
//	Tratamento para Excluir Prestação
@author Mario A. Cavenaghi
@since 20/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Function F677Exclui()

Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local oModel := FwLoadModel("FINA677")

__nOper := MODEL_OPERATION_DELETE
oModel:SetOperation(__nOper)
oModel:Activate()
FWExecView("Excluir", "FINA677", __nOper,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,, aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel) //'Excluir'
oModel:Deactivate()
oModel:Destroy()
oModel:= Nil
__nOper := 0

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ExclAnexo()
//	Exclui o Anexo selecionado
@author Mario A. Cavenaghi
@since 20/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Static Function ExclAnexo(nAC9)

Local cFileDoc := Lower(Alltrim(MsDocPath()) + "\" + ACB->ACB_OBJETO)
Local cCodEnt := AC9->AC9_CODENT
Local cCodObj := AC9->AC9_CODOBJ
Local nHdl	  := 0

nHdl := fErase(cFileDoc)	//	Apagar Arquivo no sistema

If nHdl < 0
	__ferror := FError()
Else
	If nAC9 == 0
		Chkfile("AC9",, "xAC9")	//	AC9 Auxiliar para trabalhar com outro posicionamento de registro
	EndIf
	ACB->(dbSetOrder(1))
	While !AC9->(Eof()) .And. cCodEnt == AC9->AC9_CODENT	//	Order 2
		//	Irá apagar todos os registros relacionados ao Item da Prestação
		While xAC9->(dbSeek(xFilial("AC9") + cCodObj))	//	Order 1
			xAC9->(RecLock("xAC9"))
			xAC9->(DbDelete())	//	Apaga Objeto x Entidade
			xAC9->(msUnLock())
		EndDo
		If ACB->(dbSeek(xFilial() + cCodObj))
			ACB->(RecLock("ACB"))
			ACB->(DbDelete())	//	Apaga Banco de Conhecimento
			ACB->(msUnLock())
		EndIf
		AC9->(dbSkip())	//	Próximo Objeto
	Enddo
	If nAC9 == 0
		xAC9->(dbCloseArea())
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VisuAnexo()
//	Visualiza o Anexo selecionado
@author Mario A. Cavenaghi
@since 20/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Static Function VisuAnexo(cFileDoc)	//	Visualiza Anexo

Local lFileLocal := .T.	//	.T. o Arquivo está no PC ou .F. está no Servidor
Local cDirTmp  := Lower(GetTempPath())
Local cFileTmp := ""

If __lHTML
	
	cFileDoc := Lower(Alltrim(MsDocPath() + "\" + ACB->ACB_OBJETO))
	nRet := CpyS2TW(cFileDoc, .T.)
	If nRet < 0
		Alert(STR0196)
	Endif
Else	 
	lFileLocal := ValType(cFileDoc) == "C" .And. !Empty(cFileDoc)
	If lFileLocal  //	Passa do Local de Origem para o Temporário
		cFileTmp := cFileDoc
	Else       //	Passa do Servidor para o Temporário
		cFileTmp := Lower(ACB->ACB_OBJETO)
		cFileDoc := Lower(Alltrim(MsDocPath())) + "\" + cFileTmp
		Processa({|| lFileLocal := CpyS2T(cFileDoc, cDirTmp)}, STR0182, STR0183, .F.)	//	###"Transferindo objeto"###"Aguarde..."
		cFileTmp := cDirTmp + cFileTmp
	Endif
	If lFileLocal
		ShellExecute("Open", cFileTmp, "", cDirTmp, 1)
		If cDirTmp $ cFileTmp	//	Irá apagar se estiver no Temporário
			If Ascan(__aExcluirTmp, {|x| x == cFileTmp}) == 0
				Aadd(__aExcluirTmp, cFileTmp)
			EndIf
		EndIf
	Endif
Endif	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VisuTmp()
//	Visualiza o Anexo Temporário antes da confirmação da prestação de contas, quando o Smartclient é o HTML
@author Victor Furukawa
@since 20/03/2018
@version V12.1.21
/*/
//-------------------------------------------------------------------
Static Function VisuTmp(cFileDoc as Character)	


Local aFile   as Array
Local aSO     as Array

Local cFile   as Character

Local nRet    as Numeric
Local nCria   as Numeric

Local lWin    as Logical
Local lDir    as Logical

Default cFileDoc := ""

aFile   := {}
aSO     := GetRmtInfo()

cFile   := ""

nRet    := 0

lWin    := (Upper(Substr(aSo[2],1,3)) == "WIN")
lDir    := ExistDir( "\TempViagens" )

If lWin	

	If !Empty(cFileDoc) 
	
		aFile := StrTokArr2( cFileDoc, "\", .T.)	

		If Len(aFile) > 0
			cFile := aFile[Len(aFile)]	
		Endif	

		If !lDir
			nCria := MakeDir( "\TempViagens" )
			If nCria <> 0 
				Return
			Endif
		Endif

		__CopyFile( cFileDoc , "\TempViagens\" + cFile)  //Efetua uma cópia do arquivo local para a pasta do Root do protheus  
		nRet := CpyS2TW("/TempViagens/" + cFile, .T.) //Efetua o download para o Browser, para permitir a visualização		

		If nRet == 0 //somente tenta apagar o arquivo se a cópia foi realizada
			fErase("\TempViagens\"+cFile) //Apaga o temporário para que não deixe sujeira no Root do protheus
		Endif		

	Endif

Endif  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F677ImgApp()
Integra o anexo da despesa com o app Minha Presta‡?o de Contas

@param nOper - Operacao a ser realizada
@param oModel - Model da FINA677
@return cContent - Imagem em base64 a ser atrelada a uma despesa
@author Igor Sousa do Nascimento
@since 04/03/2019
/*/
//-------------------------------------------------------------------
Function F677ImgApp(nOper,oModel,cContent)

Local aImg		  := Array(2)
Local cImg	  	  := ""
Local cAux		  := ""
Local cFilePath   := ""
Local cDirDoc	  := Lower(Alltrim(MsDocPath()))
Local cArq		  := ""
Local cExt		  := ""
Local cFileName	  := ""
Local cValidName  := ""
Local nHdl		  := 0
Local nSize		  := 0
Local nRead	      := 0
Local nI		  := 1
Local nY		  := 0
Local oModelFLE	  := Nil
Local lValidName  := .F.
Local cAnexo	  := ""

Default nOper	  := 0
Default oModel	  := Nil
Default cContent  := Nil

If oModel <> Nil .and. oModel:cId == "FINA677"
	oModelFLE := oModel:GetModel("FLEDETAIL")
EndIf

If nOper == 3		// POST
	If ValType(cContent) == "C"
		If PosMsDoc("FLE", oModelFLE)[2]	// Se encontrou anexo para essa despesa
			ExclAnexo(Select("xAC9"))
		EndIf
		cFilePath := AllTrim(cDirDoc + "\")
		nY := At(".", oModelFLE:GetValue("FLE_FILE"))
		If nY > 0
			cExt	  := SubStr(oModelFLE:GetValue("FLE_FILE"),  nY, Len(oModelFLE:GetValue("FLE_FILE")))	// Guarda extensao
			cFileName := Left(oModelFLE:GetValue("FLE_FILE"),  nY - 1)	//	Deixa Nome do Arquivo sem Extensão
		EndIf
		cValidName := cFileName
		// Garante que o nome do arquivo n?o ir  sobrepor nenhum outro
		While !lValidName
			If File(cFilePath+cValidName+cExt)
				cValidName := cFileName+"("+cValToChar(nI)+")"
			Else
				lValidName := .T.
				If nI > 1
					cFileName  := cValidName
				EndIf
			EndIf
			nI++
		EndDo
		cFilePath += cFileName+cExt
		oModelFLE:LoadValue("FLE_FILE",AllTrim(cFileName+cExt))
		nHdl := FCreate(cFilePath)		// Cria arquivo de imagem no diretorio do banco de conhecimento
		If nHdl < 0
			aImg[1] := "400"
			aImg[2] := STR0193 //"Erro ao gravar imagem anexo."
		Else
			cAnexo := Decode64(cContent)
			nSize  := FWrite(nHdl,cAnexo)
			FClose(nHdl)
			If nSize < 0
				aImg[1] := "400"
				aImg[2] := STR0193 //"Erro ao gravar imagem anexo."
			Else
				GrvAnexo(oModel)
			EndIf
			aImg[1] := "201"
			aImg[2] := oModelFLE:GetValue("FLE_FILE")
		EndIf
	EndIf
ElseIf nOper == 5	// DELETE
	If PosMsDoc("FLE", oModelFLE)[2]
		cFilePath := Lower(Alltrim(MsDocPath()) + "\" + ACB->ACB_OBJETO)
		ExclAnexo(Select("xAC9"))
		If Empty(__ferror)
			aImg[1] := "202"
			aImg[2] := STR0194 //"Anexo removido com sucesso."
		Else
			aImg[1] := "400"
			aImg[2] := STR0195 + " - " + cValToChar(__ferror) //"Nao foi possivel remover o anexo. -  + codigo da fError()"
		EndIf
	EndIf
ElseIf nOper == 2	// GET
	If PosMsDoc("FLE", oModelFLE)[2]
		cFilePath := Lower(ACB->ACB_OBJETO)
		If !Empty(cFilePath)
			cImg	  := cDirDoc + "\" + cFilePath
			nHdl	  := FOpen(cImg)
			nSize	  := FSeek(nHdl,0,2)
			FSeek(nHdl,0)
			While nSize > 0
				nRead	:= Min(1024,nSize) 
				cAux 	:= Space(nRead)
				FRead(nHdl,	@cAux, nRead) 
				cArq 	+= cAux
				nSize 	:= nSize - nRead
			EndDo
			aImg[1]	  := Lower(AllTrim(ACB->ACB_OBJETO))
			aImg[2]	  := Encode64(cArq)
			FClose(nHdl)
		EndIf
	EndIf
EndIf

Return aImg

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} F677PushNotification
Função responsável por disparar eventos do Event Viewer para visualização pelo aplicativo 
Meu Protheus\Minha Prestação de Contas

@param nOper, number, Operação a ser realizada, conforme a função F677MsgMail() ou códigos do Meu Protheus
	1 - Aviso ao Gestor sobre prestação pendente de aprovação
	2 - Aviso ao participante sobre prestação reprovada pelo gestor.
	3 - Aviso ao participante sobre prestação reprovada pelo Depto Viagens.
	4 - Aviso ao participante sobre pagamento liberado
	5 - Aviso ao participante sobre prestação finalizada pelo Depto Viagens.

	100 - Aviso ao participante sobre título gerado no financeiro.
	101 - Aviso ao participante sobre baixa do título pelo financeiro.
	102 - Aviso ao participante sobre prestação aprovada pelo gestor.
	103 - Aviso ao participante sobre prestação aprovada pelo conferente.

@param cParticipant, caracter, participante que receberá a notificação.
@param cTitle, caracter, identificador da notificação
@param cMessage, caracter, mensagem da notificação

@obs Foram criados dois ranges para o parâmetro nOper para que os mesmos não entrem em conflito:
	Abaixo de 100 - Utilizado pela rotina padrão F677MsgMail do Financeiro
	Acima de 100 - Opções criadas especificamente para uso com o aplicativo Meu Protheus

@author Marcia Junko
@since 22/07/2020
/*/
//----------------------------------------------------------------------------------------------
Function F677PushNotification( nOper, cParticipant, cTitle, cMessage )
	Local aSvAlias 		:= GetArea()
	Local cUserBKP 	 	:= __cUserID
	Local cEventCode 	:= ''
	Local cUserCode		:= ''
	Local cIDParticipant := ''
	Local lChangeUser 	:= .F.
	Local lAddMessage	:= .T.

	Default cParticipant := ''

	IF !( Alltrim( Str( nOper ) ) $ '1|2' )
		cIDParticipant := FLF->FLF_PARTIC
	EndIf
	
	Do Case 
		Case nOper == 1 .And. !Empty( cParticipant ) 	// Somente gera a notificação se for a inclusão de registro na FLN
			cEventCode := '071'
			cIDParticipant := cParticipant	// Armazena o código do aprovador (gestor)
		Case nOper == 2
			cEventCode := '063'
			cIDParticipant := FLN->FLN_PARTIC	// Armazena o código do participante
		Case nOper == 3
			cEventCode := '064'
		Case nOper == 4
			cEventCode := '065'
		Case nOper == 5
		 	cEventCode := '066'
		Case nOper == 100
			cEventCode := '068'
			lAddMessage := .F.
		Case nOper == 101
			cEventCode := '067'
			lAddMessage := .F.
		Case nOper == 102
			cEventCode := '069'
		Case nOper == 103
			cEventCode := '070'
	EndCase
	
	cUserCode := SearchContent( 'RD0', 1, cIDParticipant , 'RD0_USER' )

	If !Empty( cEventCode ) .And. ChkEventReg( cEventCode, cUserCode )
		// Checa se o usuário deve ser trocado
		lChangeUser := ChkChgUser( cUserCode )

		If lAddMessage
			cMessage += MessageCompl( nOper )
		EndIf
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventCode, FW_EV_LEVEL_INFO, "", cTitle, cMessage )

		If lChangeUser
			__cUserID := cUserBKP
		EndIF
	EndIf

	RestArea( aSvAlias )
	FWFreeArray( aSvAlias )
Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkChgUser
Função que checa se o controle de usuário deve ser alterado, para que a notificação seja 
enviada para o usuário correto.

@param cUserCode, caracter, Código do usuário que deve receber a notificação
@author Marcia Junko
@since 27/07/2020
/*/
//----------------------------------------------------------------------------------------------
Static Function ChkChgUser( cUserCode )
	Local cUserBKP 	:= __cUserID
	Local lChangeUser := .F.

	// Troca o controle do usuário para mandar a notificação para o usuário correto
	If !Empty( cUserCode )
		IF cUserCode <> cUserBKP
			__cUserID := cUserCode
			lChangeUser := .T.
		EndIf
	EndIf
Return lChangeUser

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} MessageCompl
Monta uma mensagem complementar com as informações da prestação para o push notification

@param nOper, number, Operação a ser realizada, conforme a função F677MsgMail() ou códigos do Meu Protheus
@return cTextCompl, caracter, texto auxiliar do push notification
@author Marcia Junko
@since 22/07/2020
/*/
//----------------------------------------------------------------------------------------------
Static Function MessageCompl( nOper )
	Local cTextCompl := ''
	Local cName := ''
	Local cParticipant := ''
	Local cSeekAccount := ''
	Local cAccount := ''
	Local cValueText := ''
	Local cNameText := ''

	If nOper == 1
		cAccount := FLN->FLN_PRESTA
		cParticipant := FLN->FLN_PARTIC
		cSeekAccount := FLN->FLN_TIPO + FLN->FLN_PRESTA + FLN->FLN_PARTIC 
		cName := SearchContent( 'RD0', 1, cParticipant, 'RD0_NOME' ) 
		cNameText := STR0198 + cParticipant + ' - ' + Alltrim( cName ) + CRLF 	//'Participante: '	
	Else
		cAccount := FLF->FLF_PRESTA
		cParticipant := FLF->FLF_PARTIC
		cSeekAccount := FLF->FLF_TIPO + FLF->FLF_PRESTA + FLF->FLF_PARTIC 
	EndIf

	cValueText := SearchAccount( 1, cSeekAccount )

	cTextCompl += CRLF + STR0197 + cAccount + CRLF 		//'Número da prestação: '
	cTextCompl += cNameText
	cTextCompl += cValueText
Return cTextCompl

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} SearchContent
Esta função executa a função Posicione para resgatar dados de uma tabela específica, mas garante
que a tabela retornará ao registro posicionadao anteriormente, para não interferir no fluxo.

@param cAlias, caracter,  tabela a ser pesquisada
@param nOrder, number, ordem de pesquisa na tabela
@param cSeek, caracter,  chave de busca
@param cField, caracter,  nome do campo a retornar

@return cContent, caracter, Conteúdo de acordo com o parâmetro cField
@author Marcia Junko
@since 22/07/2020
/*/
//----------------------------------------------------------------------------------------------
Static Function SearchContent( cAlias, nOrder, cSeek, cField )
	Local aSvAlias := GetArea()
	Local aBkpAlias := {}
	Local xContent

	aBkpAlias := ( cAlias )->( GetArea() )

	xContent := Posicione( cAlias, nOrder, xFilial( cAlias ) + cSeek, cField )

	RestArea( aSvAlias )
	RestArea( aBkpAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aBkpAlias )
Return xContent

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} SearchAccount
Retorna dados específicos na tabela de prestação (FLF).

@param nOption, number, determina o conteúdo que será retornado
	1 - dados dos valores de reembolso
@param cSeek, caracter,  chave de busca

@return cContent, caracter, Conteúdo de acordo com o parâmetro nOption
@author Marcia Junko
@since 22/07/2020
/*/
//----------------------------------------------------------------------------------------------
Static Function SearchAccount( nOption, cSeek )
	Local aSvAlias := GetArea()
	Local aFLFAlias := FLF->( GetArea() )
	Local cContent := ''

	Default nOption := 1
	
	FLF->( DBSetOrder(1) )		// FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC
	If FLF->( MSSeek( xFilial( "FLF" ) + cSeek ) )	
		Do Case
			Case nOption == 1
				If FLF->FLF_TVLRE1 > 0
					cContent += STR0199 + Alltrim( Transform( FLF->FLF_TVLRE1, PesqPict("FLF", "FLF_TVLRE1") ) ) + CRLF 	//'Valores em reais: '
				EndIf

				If FLF->FLF_TVLRE2 > 0 
					cContent += STR0200 + Alltrim( Transform( FLF->FLF_TVLRE2, PesqPict("FLF", "FLF_TVLRE2") ) ) + CRLF 	//'Valores em dólares: '
				EndIf

				If FLF->FLF_TVLRE3 > 0 
					cContent += STR0201 + Alltrim( Transform( FLF->FLF_TVLRE3,  PesqPict("FLF", "FLF_TVLRE3") ) ) + CRLF	//'Valores em euros: '
				EndIf
		EndCase
	EndIf

	RestArea( aSvAlias )
	RestArea( aFLFAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aFLFAlias )
Return cContent

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkEventReg
Verifica se o usuário está inscrito no evento

@param cEvent, caracter,  código do evento
@param cUser, caracter,  ID do usuário
@param cChannel, caracter,  canal do evento
@param cCategory, caracter,  categoria do evento

@return boolean, Define se o usuário está ou não inscrito em determinado evento.
@author Marcia Junko
@since 16/10/2020
/*/
//----------------------------------------------------------------------------------------------
Static Function ChkEventReg( cEvent, cUser, cChannel, cCategory )
	Local aSvAlias := GetArea()
	Local lSeek := .F.

	Default cChannel := FW_EV_CHANEL_ENVIRONMENT 
	Default cCategory := FW_EV_CATEGORY_MODULES

	SXI->(dbSetOrder(1)) // "XI_USERID+XI_CANAL+XI_CATEGOR+XI_EVENTID"
	lSeek := SXI->( MSSeek( cUser + cChannel + cCategory + cEvent ) )

	RestArea( aSvAlias )
	FWFreeArray( aSvAlias )
Return lSeek

//----------------------------------------------------------------------
/*/{Protheus.doc} IsApprover
Verifica se o usuario é aprovador da prestacao selecionada

@return boolean, se o usuario pode proceder com a ação
@author Igor Nascimento
@since 30/07/2021
/*/
//----------------------------------------------------------------------
Static Function IsApprover() as logical
	Local cResgVia As Char
	Local cFilRD0  As Char
	Local aArea    As array
	Local aAreaRD0 As array
	Local lProceed As Logical
	
	//Inicializa variáveis	
	cResgVia := SuperGetMv("MV_RESGVIA", .F., "")
	
	If !(lProceed := (__cUserID $ cResgVia))
		cFilRD0  := xFilial("RD0")
		aArea	 := GetArea()	
		aAreaRD0 := RD0->(GetArea())
		
		DbSelectArea("RD0")
		DbSelectArea("FLN")
		RD0->(DbSetOrder(1))
		FLN->(DbSetOrder(1))
		
		If FLN->(DbSeek(xFilial("FLN")+FLF->(FLF_TIPO+FLF_PRESTA+FLF_PARTIC) ))
			lProceed := RD0->(DbSeek(cFilRD0+FLN->FLN_APROV)) .And. RD0->RD0_USER == __cUserID
		EndIf
		
		//Valida se é substituto
		If !lProceed .And. RD0->(DbSeek(cFilRD0+FLF->FLF_PARTIC)) .And. !Empty(RD0->RD0_APSUBS)
			lProceed := RD0->(DbSeek(cFilRD0+RD0->RD0_APSUBS)) .And. RD0->RD0_USER == __cUserID 			
		EndIf	
		
		RestArea(aAreaRD0)
		RestArea(aArea)
		FwFreeArray(aAreaRD0)
		FwFreeArray(aArea)
	EndIf
Return lProceed
