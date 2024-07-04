#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCDESP.CH'
#include 'COLORS.CH'
#INCLUDE "Fwlibversion.ch"
#include 'totvs.ch'
#DEFINE MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCDESP

Manutencao de Eventos X Despesas no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCDESP(cFiltro, lAuto)
	Local oBrowse := Nil
	Default lAuto := .F.
	Default cFiltro :=  " B3L_FILIAL = '" + B3D->B3D_FILIAL + "' .And. " +;
		" B3L_CODOPE = '" + B3D->B3D_CODOPE + "' .And. " +;
		" B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' .And. " +;
		" B3L_ANOCMP = '" + B3D->B3D_ANO    + "' .And. " +;
		" B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B3L')
	oBrowse:SetMenuDef( 'PLSMVCDESP' )
	oBrowse:SetDescription(STR0001) //Eventos X Despesas
	oBrowse:AddLegend( "B3L_STATUS=='1'", "YELLOW"	, "Validacao Pendente" )
	oBrowse:AddLegend( "B3L_STATUS=='2'", "GREEN"	, "Valido" )
	oBrowse:AddLegend( "B3L_STATUS=='3'", "RED"		, "Invalido" )
	oBrowse:SetFilterDefault( cFiltro )

	If !lAuto
		oBrowse:Activate()
	EndIf

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Eventos X Despesas", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aAjustes		:= {}
	Local aRotina	:= {}

	ADD OPTION aAjustes Title 'Criticado p/ Demais Desp.'	Action "PLSCORSIP('1')"			OPERATION 0 ACCESS 0
	ADD OPTION aAjustes Title 'Ajusta Grp. e Reg.'			Action "PLSCORSIP('2')"			OPERATION 0 ACCESS 0
	ADD OPTION aRotina Title STR0002						Action 'PesqBrw'				OPERATION 1 ACCESS 0//Pesquisar
	ADD OPTION aRotina Title STR0003						Action 'VIEWDEF.PLSMVCDESP'		OPERATION 2 ACCESS 0//Visualizar
	ADD OPTION aRotina Title STR0006						Action 'VIEWDEF.PLSMVCDESP'		OPERATION 5 ACCESS 0//Excluir
	ADD OPTION aRotina Title STR0007						Action 'VIEWDEF.PLSMVCDESP'		OPERATION 8 ACCESS 0//Imprimir
	ADD OPTION aRotina Title 'Detalhes Class. H'            Action "DesClasH()"             OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Ajustes'						Action aAjustes					OPERATION 0 ACCESS 0//Submenu Ajustes

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3M

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3L 		:= FWFormStruct( 1, 'B3L' )
	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
	Local oModel

	oModel := MPFormModel():New( STR0001 )
	oModel:AddFields( 'B3LMASTER', /*cOwner*/ , oStruB3L )
	oModel:AddGrid( 'B3FDETAIL', 'B3LMASTER', oStruB3F )
	If B3F->(FieldPos("B3F_TABKEY")) > 0
		oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
			{ 'B3F_ORICRI' , '"B3L"'      },;
			{ 'B3F_CODOPE' , 'B3L_CODOPE' },;
			{ 'B3F_CDOBRI' , 'B3L_CODOBR' },;
			{ 'B3F_ANO'    , 'B3L_ANOCMP' },;
			{ 'B3F_CDCOMP' , 'B3L_CDCOMP' },;
			{ 'B3F_TABKEY' , 'B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)+B3L_EVDEIN' };
			}, B3F->( IndexKey( 1 ) ) )
	Else
		oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
			{ 'B3F_ORICRI' , '"B3L"' },;
			{ 'B3F_CHVORI' , 'B3L->(Recno())' };
			}, B3F->( IndexKey( 1 ) ) )
	EndIF
	oModel:SetDescription( 'Críticas' )
	oModel:GetModel( 'B3LMASTER' ):SetDescription( "Compromissos" )
	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )
	oModel:GetModel( 'B3FDETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3FDETAIL' ):SetOptional(.T.)
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3M

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCDESP' )
	Local oStruB3L 			:= FWFormStruct( 2, 'B3L' )
	Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3L', oStruB3L, 'B3LMASTER' )
	oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )
	oStruB3F:RemoveField('B3F_CODOPE')
	oStruB3F:RemoveField('B3F_CDOBRI')
	oStruB3F:RemoveField('B3F_ANO')
	oStruB3F:RemoveField('B3F_CDCOMP')
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:SetOwnerView( 'VIEW_B3L', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )
	oView:EnableTitleView( 'VIEW_B3L', STR0011 )//"Eventos x Despesas"
	oView:EnableTitleView( 'VIEW_B3F', STR0012 )//"Críticas no Processamento"
	oView:AddUserButton( 'Muda Classificação', '', {|oView| PLSMUCLAS()} )
	oView:AddUserButton( 'Detalhes Class. H', '', {|oView| DesClasH()} )
Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPROT

Funcao criada para retornar a lista de rotinas / jobs a serem processados

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - SADT / Internacao
	2 - Alto custo
	3 - Reembolso
	4 - Exposto
	5 - Finalizacao

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIPROT(cDado)
	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local nFor		:= 0
	Local nOpc		:= 0
	Local bOK		:= { || nOpc := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Default cDado	:= ''

	aAdd(aConjunto,{'1','Despesas'			,.F.})
	aAdd(aConjunto,{'2','Alto custo'		,.F.})
	aAdd(aConjunto,{'3','Reembolso'			,.F.})
	aAdd(aConjunto,{'4','Benef. exposto'	,.F.})
	aAdd(aConjunto,{'5','Finalizacao'		,.F.})

	DEFINE MSDIALOG oDlg TITLE 'Conjuntos a processar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT 'Selecione o(s) conjunto(s) a serem procesados' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

	If nOpc == 1
		cDado := ""
		For nFor := 1 To Len(aConjunto)
			If aConjunto[nFor,3]
				cDado += aConjunto[nFor,1]+","
			Endif
		Next
	Endif

	If nOpc == 0                      //não foi selecionado nada e estou saindo da tela.
		cDado:=""
	Endif

	//Tira a virgula do final
	If Subs(cDado,Len(cDado),1) == ","
		cDado := Subs(cDado,1,Len(cDado)-1)
	EndIf
Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMUCLAS

Funcao criada para retornar a lista de rotinas / jobs a serem processados

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - SADT / Internacao
	2 - Alto custo
	3 - Reembolso
	4 - Exposto
	5 - Finalizacao

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMUCLAS()
	Local aCriMud		:= {"E033"} //Lista de criticas que podem se tornar outras despesas
	Local cSql			:= ""
	Local cAlias		:= "TRBMC"
	Local lMudCla		:= .F.
	Local cRecB3L		:= AllTrim(Str(B3L->(Recno())))
	Local nFor			:= 0
	Local lMV_PLCENDB	:= MV_PLCENDB

	For nFor := 1 TO Len(aCriMud)

		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3F") + " WHERE B3F_FILIAL ='" + xFilial("B3F") + "' AND B3F_CODOPE = '" + B3L->B3L_CODOPE + "' AND B3F_ORICRI = 'B3L' AND B3F_CHVORI = " + cRecB3L + " AND B3F_CODCRI = '" + aCriMud[nFor] + "' "
		cSql += "AND B3F_TIPO = '1' AND B3F_STATUS = '1' AND D_E_L_E_T_ = ' ' " //B3F_TIPO - Origem Job Validacao, B3L_STATUS - Pendente
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

		If (cAlias)->(Eof())
			MsgInfo("Não existe critica que permita converter a despesa em H-Demais Despesas!")
		Else
			While (cAlias)->(!Eof())
				dbGoTo(Val(cRecB3L))//Posiciona na despesa
				MsgRun("Convertendo itens ",,{|| lMudCla := ConverteItens(cRecB3L,'H','H','1') } )
				If lMudCla
					cDataRef := DataRef(B3L->B3L_TRIREC)
					MsgRun("Limpando totalizador ",,{|| CENDELTOT(B3L->B3L_CODOPE,B3L->B3L_CODOBR,B3L->B3L_ANOCMP,B3L->B3L_CDCOMP,B3L->B3L_CLAINT,B3L->B3L_TRIOCO,B3L->B3L_UF) } )
					MsgRun("Totalizando item H ",,{|| CENTITESIP(12,B3L->B3L_CODOPE,B3L->B3L_CODOBR,B3L->B3L_ANOCMP,B3L->B3L_CDCOMP,cDataRef,"ItemH",lMV_PLCENDB) } )
					MsgInfo("Despesa convertida para H-Demais despesas com sucesso!")
				EndIf
				(cAlias)->(dbSkip())
			EndDo
		EndIf
		(cAlias)->(dbCloseArea())
	Next For

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ConverteItens

Funcao criada para mudar a classificacao de uma determinada despesa do SIP

@param nRecno		Recno do registro a ser atualizado
@param cNewAmb		Novo valor para a claasificacao ambulatorial - B3L_CLAAMB
@param cNewInt		Novo valor para a classificacao de internacao - B3L_CLAINT
@param cNewSta		Novo valor de status para o registro - B3L_STATUS

@author timoteo.bega
@since 23/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ConverteItens(cRecno,cNewAmb,cNewInt,cNewSta)
	Local lRetorno		:= .F.
	Local cSql			:= ""
	Local aAreaB3L		:= GetArea()
	Default cRecno	:= ''
	Default cNewAmb	:= ''
	Default cNewInt	:= ''
	Default cNewSta	:= ''

	cSql := "SELECT R_E_C_N_O_ RECITE FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL='" + xFilial("B3L") + "'  AND B3L_CODOPE='" + B3L->B3L_CODOPE + "' AND B3L_CODOBR = '" + B3L->B3L_CODOBR + "' AND B3L_ANOCMP = '" + B3L->B3L_ANOCMP + "' "
	cSql += "AND B3L_CDCOMP = '" + B3L->B3L_CDCOMP + "' AND B3L_MATRIC<>B3L_EVEDES AND B3L_CLAINT = '" + B3L->B3L_CLAINT + "' AND R_E_C_N_O_ = " + cRecno + " AND D_E_L_E_T_=' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBI",.F.,.T.)

	While !TRBI->(Eof())
		B3L->(dbGoTo( TRBI->RECITE ))
		oModel	:= FWLoadModel( 'PLSMVCDESP' )
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		If !Empty(cNewAmb)
			oModel:SetValue( 'B3LMASTER', 'B3L_CLAAMB'	, cNewAmb )
		EndIf
		If !Empty(cNewInt)
			oModel:SetValue( 'B3LMASTER', 'B3L_CLAINT'	, cNewInt )
		EndIf
		If !Empty(cNewSta)
			oModel:SetValue( 'B3LMASTER', 'B3L_STATUS'	, cNewSta )
		EndIf
		if B3L->(fieldpos("B3L_CLASSH")) > 0 //Verifica se existe o campo B3L_CLASSH
			oModel:SetValue( 'B3LMASTER', 'B3L_CLASSH', "Classificação H forçada pelo usuário [" + rtrim(usrfullname(retcodusr())) + "] em [" + dtoc(ddatabase) + "]. (Caminho: 'Painel de Obrigaçoes/Obrigações/SIP/Eventos x Despesas/Visualizar/Outras Ações/Muda Classificação')" )
		endif
		If oModel:VldData()
			oModel:CommitData()
			lRetorno := .T.
		Else
			aErro := oModel:GetErrorMessage()
		EndIf
		oModel:DeActivate()
		oModel:Destroy()
		FreeObj(oModel)
		oModel := Nil
		TRBI->(dbSkip())
	EndDo

	TRBI->(dbCloseArea())
	RestArea(aAreaB3L)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataRef

Funcao retorna a data de referencia do trimestre de acordo com o trimestre de reconhecimento passado

@param cTriRec		Trimestre de reconhecimento yyyyaa

@return cDataRef	Data de referencia no formado yyyymmaa

@author timoteo.bega
@since 23/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function DataRef(cTriRec)
	Local cDataRef		:= ""
	Local cMes			:= ""
	Default cTriRec	:= ""

	If !Empty(cTriRec)

		cMes := Right(cTriRec,2)
		cDataRef := Left(cTriRec,4)

		If cMes == '01'
			cDataRef += '03'
		ElseIf cMes == '02'
			cDataRef += '06'
		ElseIf cMes == '03'
			cDataRef += '09'
		ElseIf cMes == '04'
			cDataRef += '12'
		Else
			cDataRef += '00'
		EndIf

		cDataRef += '31'

	EndIf

Return cDataRef

/*/{Protheus.doc} DesClasH
Tela modal mostrando o conteúdo do campo MEMO que mostra a origem da classficação H.

@author Gabriel H. Klok

@type function
@since 25/06/2020
@versin 1.0
/*/
function DesClasH()
	local cClasH := iif(empty(B3L->B3L_EVDEIN), B3L_CLAAMB, B3L->B3L_CLAINT)

	if upper(rtrim(cClasH)) == 'H'
		if rtrim(B3L->B3L_MATRIC) == rtrim(B3L->B3L_EVEDES)
			msginfo("Registro posicionado é um totalizador, sendo assim não existe descrição.", "Aviso")
		else
			msginfo( iif(empty(B3L->B3L_CLASSH), "Sem descrição, o registro já existia na base de dados.", B3L->B3L_CLASSH), "Descrição")
		endif
	else
		msginfo("O registro posicionado não possui classificação H.", "Aviso")
	endif
return
