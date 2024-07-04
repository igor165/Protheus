#INCLUDE "SFCA313.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE 313NE_a "CYV_QTTERP/CYV_QTTEEX/CYV_QTTEOE/CYV_LGRPEO/" // Campos que não serão exibidos
#DEFINE 313NE_b "CYW_QTTEUT/CYW_QTTEEX/CYW_QTTEOE/" // Campos que não serão exibidos
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA313
Tela de Estorno de Apontamento de Produção

@author Samantha Preima
@since 04/10/2010
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA313()
Return NIL

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oStruCZP := FWFormStruct( 1, 'CZP', /*bAvalCampo*/,/*lViewUsado*/ ) // Componente
Local oStruCYW := FWFormStruct( 1, 'CYW', /*bAvalCampo*/,/*lViewUsado*/ ) // Recurso
Local oStruCY0 := FWFormStruct( 1, 'CY0', /*bAvalCampo*/,/*lViewUsado*/ ) // Refugo
Local oStruCZ0 := FWFormStruct( 1, 'CZ0', /*bAvalCampo*/,/*lViewUsado*/ ) // Ferramenta
Local oStruCZW := FWFormStruct( 1, 'CZW', /*bAvalCampo*/,/*lViewUsado*/ ) // GGF
Local oModel


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA313', /*Pre*/, { | oMdl | SFCA313POS ( oMdl ) }, /*{ | oMdl | SFCA310F12() }*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYVMASTER', /*cOwner*/, oStruCYV )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY0DETAIL', 'CYVMASTER', oStruCY0, /*bLinePre*/, /* Pos */, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYWDETAIL', 'CYVMASTER', oStruCYW, /*bLinePre*/, /* Pos */, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZPDETAIL', 'CYVMASTER', oStruCZP, /*bLinePre*/, /* Pos */, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZ0DETAIL', 'CYVMASTER', oStruCZ0, /*bLinePre*/, /* Pos */, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZWDETAIL', 'CYVMASTER', oStruCZW, /*bLinePre*/, /* Pos */, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY0DETAIL', { { 'CY0_FILIAL', 'xFilial( "CY0" )' } , { 'CY0_NRSQRP', 'CYV_NRSQRP' } } , CY0->( IndexKey(1)) )
oModel:SetRelation( 'CYWDETAIL', { { 'CYW_FILIAL', 'xFilial( "CYW" )' } , { 'CYW_NRSQRP', 'CYV_NRSQRP' } } , CYW->( IndexKey(1)) )
oModel:SetRelation( 'CZPDETAIL', { { 'CZP_FILIAL', 'xFilial( "CZP" )' } , { 'CZP_NRSQRP', 'CYV_NRSQRP' } } , CZP->( IndexKey(1)) )
oModel:SetRelation( 'CZ0DETAIL', { { 'CZ0_FILIAL', 'xFilial( "CZ0" )' } , { 'CZ0_NRSQRP', 'CYV_NRSQRP' } } , CZ0->( IndexKey(1)) )
oModel:SetRelation( 'CZWDETAIL', { { 'CZW_FILIAL', 'xFilial( "CZW" )' } , { 'CZW_NRSQRP', 'CYV_NRSQRP' } } , CZW->( IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY0DETAIL' ):SetUniqueLine( { 'CY0_CDRF' } )
oModel:GetModel( 'CYWDETAIL' ):SetUniqueLine( { 'CYW_IDOE' } )
oModel:GetModel( 'CZ0DETAIL' ):SetUniqueLine( { 'CZ0_IDFE' } )
oModel:GetModel( 'CZWDETAIL' ):SetUniqueLine( { 'CZW_CDCETR' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY0DETAIL' ):SetDescription( STR0001 ) //'Apontamento de Refugo'
oModel:GetModel( 'CYWDETAIL' ):SetDescription( STR0002 ) //'Apontamento de Recurso'
oModel:GetModel( 'CZPDETAIL' ):SetDescription( STR0003 ) //'Componentes'
oModel:GetModel( 'CZ0DETAIL' ):SetDescription( STR0004 ) //'Ferramentas'
oModel:GetModel( 'CZWDETAIL' ):SetDescription( 'GGF' )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY0DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CYWDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZPDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZ0DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZWDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0005 ) //'Apontamento de Produção'

//Define bloco a ser executado apos a ativacao do Model
oModel:SetActivate( { | oModel | SFCA313LD( oModel ) } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYV := FWFormStruct( 2, 'CYV', { |cCampo| !AllTrim( cCampo ) + '/' $ 313NE_a } )
Local oStruCY0 := FWFormStruct( 2, 'CY0' )
Local oStruCYW := FWFormStruct( 2, 'CYW', { |cCampo| !AllTrim( cCampo ) + '/' $ 313NE_b } )
Local oStruCZP := FWFormStruct( 2, 'CZP' )
Local oStruCZ0 := FWFormStruct( 2, 'CZ0' )
Local oStruCZW := FWFormStruct( 2, 'CZW' )
Local oModel   := FWLoadModel( 'SFCA313' )
Local oView

// Criação de divisores
oStruCYV:AddGroup( 'Grupo01', STR0005, '', 2 ) //'Apontamento de Produção'
oStruCYV:AddGroup( 'Grupo02', STR0006, '', 2 ) //'Estorno de Produção'
oStruCYV:AddGroup( 'Grupo03', 'Preparação', '', 2 )
oStruCYV:AddGroup( 'Grupo04', 'Detalhes', '', 2 )
oStruCYV:AddGroup( 'Grupo05', 'Consumo', '', 2 )
oStruCYV:AddGroup( 'Grupo06', 'Acabado', '', 2 )

oStruCYV:SetProperty( 'CYV_CDMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_DSMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_NRORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_IDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_IDATQO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_CDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_CDACRP', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_DSAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

oStruCYV:SetProperty( 'CYV_DTEO'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )

oStruCYV:SetProperty( 'CYV_DTBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HRBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DTEDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HREDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_CDSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DSSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )

oStruCYV:SetProperty( 'CYV_QTATRP', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_QTATRF', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_QTATRT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_QTATAP', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_DTRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_HRRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_DTRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_HRRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_HRTERP', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_LGRPPO', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_LGLBCQ', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_LGRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_CDTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_DSTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_NRTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_NRTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_DTRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_HRRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_NRDO'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_NRSR'  , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_LGLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_NRSQRP', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_CDFEPO', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
//oStruCYV:SetProperty( 'CYV_DSFEPO', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_LGEDRP', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )

oStruCYV:SetProperty( 'CYV_CDDPOT', MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYV:SetProperty( 'CYV_CDLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo05' )

oStruCYV:SetProperty( 'CYV_CDDP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYV:SetProperty( 'CYV_CDLC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYV:SetProperty( 'CYV_CDRE'  , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYV:SetProperty( 'CYV_CDLOSR', MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYV:SetProperty( 'CYV_DTVDLO', MVC_VIEW_GROUP_NUMBER, 'Grupo06' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYV', oStruCYV, 'CYVMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_CY0' , oStruCY0, 'CY0DETAIL' )
oView:AddGrid( 'VIEW_CYW' , oStruCYW, 'CYWDETAIL' )
oView:AddGrid( 'VIEW_CZP' , oStruCZP, 'CZPDETAIL' )
oView:AddGrid( 'VIEW_CZ0' , oStruCZ0, 'CZ0DETAIL' )
oView:AddGrid( 'VIEW_CZW' , oStruCZW, 'CZWDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'APONT'   , 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0003) //'Componentes'
oView:AddSheet( 'PASTAS', 'ABA02', STR0007) //'Recursos'
oView:AddSheet( 'PASTAS', 'ABA03', STR0004) //'Ferramentas'
oView:AddSheet( 'PASTAS', 'ABA04', STR0008) //'Refugos'
oView:AddSheet( 'PASTAS', 'ABA05', 'GGF')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'COMPO'  , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'RECUR'  , 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'FERRA'  , 100,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'REFUG'  , 100,,, 'PASTAS', 'ABA04' )
oView:CreateHorizontalBox( 'GGF'    , 100,,, 'PASTAS', 'ABA05' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYV' , 'APONT' )
oView:SetOwnerView( 'VIEW_CZP' , 'COMPO' )
oView:SetOwnerView( 'VIEW_CYW' , 'RECUR' )
oView:SetOwnerView( 'VIEW_CY0' , 'REFUG' )
oView:SetOwnerView( 'VIEW_CZ0' , 'FERRA' )
oView:SetOwnerView( 'VIEW_CZW' , 'GGF'   )

//Remove o campo repetido em tela
oStruCY0:RemoveField("CY0_NRSQRP")
oStruCYW:RemoveField("CYW_NRSQRP")
oStruCYW:RemoveField("CYZ_NRSQRP")
oStruCZ0:RemoveField("CZ0_NRSQRP")
oStruCZP:RemoveField("CZP_NRORPO")
oStruCZP:RemoveField("CZP_IDMTOR")
oStruCZP:RemoveField("CZP_NRSQRP")
oStruCZW:RemoveField("CZW_NRSQRP")
oStruCZW:RemoveField("CZW_QTTEGF")

Return oView

//-----------------------------------------------------------------
// Botão estornar apontamento de produção
//
//-----------------------------------------------------------------
Function SFCA313E (xRotAuto)
Local oDlg, oCombo
Local lRet         := .T.
Local dDataEstorno := DATE()
Local cNRORPO  := ''
Local cIDAT    := ''
Local cIDATQO  := ''
Local aArea    := GetArea()
Local aAreaCYV := CYV->(GetArea())
Local aAreaCYQ := CYQ->(GetArea())
Local lAutoExe := xRotAuto != nil

if lAutoExe
	if Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'}) == 0

		AutoGRLog(STR0033) // 'É preciso informar a sequencia do apontamento para realizar o estorno. Campos CYV_NRSQRP'
		lMsErroAuto := .T.

		lRet := .F.
	Else
		cNRSQRP := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'})][2],TamSX3('CYV_NRSQRP')[1])

		if Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_DTEO'}) > 0
				dDataEstorno := xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_DTEO'})][2]
			Else
				dDataEstorno := Date()
		Endif

		dbSelectArea('CYV')
		CYV->(dbSetOrder(1))
		CYV->(dbSeek(xFilial('CYV')+cNRSQRP))
	Endif
Endif

CYQ->(dbSeek(xFilial("CYQ")+CYV->CYV_NRORPO))

If CYQ->CYQ_TPRPOR == '1' .And. !Empty(CYV->CYV_NRRPOG)
	SFCMsgErro('SFCA313_NAORP', "SFCA313", 3) //'Somente apontamentos reportados ser estornados pelo usuário.' - 'Selecione o registro que o originou e os não reportados serão estornados automaticamente.'
	lRet := .F.
EndIf

if CYV->CYV_TPSTRP == '1'
	SFCMsgErro('SFCA313_ESTINI', "SFCA313", 3) //'Somente apontamentos finalizados podem ser estornados'
	lRet := .F.
Endif

if CYV->CYV_LGRPEO
	SFCMsgErro(STR0009 + DTOC(CYV->CYV_DTEO), "SFCA313") //'Apontamento de Produção já foi estornado no dia '
	lRet := .F.
Endif

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
CYY->(dbSeek(CYV->CYV_FILIAL+CYV->CYV_NRORPO+CYV->CYV_IDAT+CYV->CYV_IDATQO))

if lRet

	cNRORPO := CYV->CYV_NRORPO
	cIDAT   := CYV->CYV_IDAT
	cIDATQO := CYV->CYV_IDATQO
	cNRSQRP := CYV->CYV_NRSQRP
	nQTATRP := CYV->CYV_QTATRP
	nQTATRF := CYV->CYV_QTATRF

	if lAutoExe
		lRet := SFCA313OK(CYV->CYV_NRSQRP,dDataEstorno,,.T.)
	Else

		if MSGYESNO(STR0010) //'Confirma Estorno de Apontamento?'

			Define Font oFont Name STR0011 Size 0, -12 //'Courier New'

			Define MsDialog oDlg From 0,0 to 280,370 PIXEL TITLE STR0012 //'Estornar Apontamento'

				tSay():New(10.5,13,{||STR0013},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Ordem Produção:'
				@ 08, 62 MSGET cNRORPO SIZE 40,7 PIXEL OF oDlg WHEN .F.

				tSay():New(25.5,13,{||STR0014},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Operação:'
				@ 23, 62 MSGET CIDAT SIZE 40,7 PIXEL OF oDlg WHEN .F.

				tSay():New(40.5,13,{||STR0015},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Split:'
				@ 38, 62 MSGET cIDATQO SIZE 40,7 PIXEL OF oDlg WHEN .F.

				tSay():New(55.5,13,{||STR0016},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Sequencia Reporte:'
				@ 53, 62 MSGET cNRSQRP SIZE 70,7 PIXEL OF oDlg WHEN .F.

				tSay():New(70.5,13,{||STR0017},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Qtde Reporte:'
				@ 68, 62 MSGET nQTATRP SIZE 70,7 PIXEL PICTURE "@R 999,999,999.9999" OF oDlg WHEN .F.

				tSay():New(85.5,13,{||STR0018},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Qtde Refugada:'
				@ 83, 62 MSGET nQTATRF SIZE 70,7 PIXEL PICTURE "@R 999,999,999.9999" OF oDlg WHEN .F.

				tSay():New(100.5,13,{||STR0019},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Data Estorno:'
				@ 98, 62 MSGET dDataEstorno SIZE 70,7 PIXEL OF oDlg WHEN .T.

				TButton():New(125,090,STR0020,oDlg,{|| if(SFCA313OK(cNRSQRP,dDataEstorno),oDlg:End(),SFCA310F12())},40,10,,,,.T.) //'Ok'
				TButton():New(125,135,STR0021,oDlg,{|| oDlg:End(), SFCA310F12() },40,10,,,,.T.) //'Cancelar'

			Activate MsDialog oDlg Centered
		Endif
	Endif
Endif

RestArea(aArea)
RestArea(aAreaCYV)
RestArea(aAreaCYQ)

SFCA310F12()

Return lRet

//-----------------------------------------------------------------
// Efetiva estorno de apontamento
//
// Input: data de estorno
//-----------------------------------------------------------------
Function SFCA313OK(cNRSQRP, dEstorno, lAlteraEst, lRotAut)
Local lRet := .T.
Local oModelCYV
Local cNRORPO   := ''
Local cIDAT     := ''
Local oView     := FwViewActive()
Local cSeqOrigem
Local aAreaCYV
Local aAreaCYQ := CYQ->(GetArea())
Private lOk     := .T. // Sinaliza se respondeu sim para reabrir operação e splits
Private lAltEstOp
Default lAlteraEst := .F.

lAltEstOp := lAlteraEst

Begin Transaction

	oModelCYV := FWLoadModel( 'SFCA313' )
	oModelCYV:SetOperation( 4 )

	dbSelectArea('CYV')
	CYV->(dbSetOrder(1))
	CYV->(dbGoTop())
	CYV->(dbSeek(xFilial('CYV')+cNRSQRP))

	cNRORPO := CYV->CYV_NRORPO
	cIDAT   := CYV->CYV_IDAT
	cSeqOrigem	:= If(Empty(CYV->CYV_NRRPOG),cNRSQRP,CYV->CYV_NRRPOG)

	oModelCYV:Activate()

	oModelCYV:SetValue('CYVMASTER','CYV_DTEO'  , dEstorno)
	oModelCYV:SetValue('CYVMASTER','CYV_LGRPEO', .T.)
	oModelCYV:SetValue('CYVMASTER','CYV_CDUSOE', RetCodUsr())

	if oModelCYV:VldData()
		oModelCYV:CommitData()
	Else
		aErro := oModelCYV:GetErrorMessage()
		SFCMsgErro(aErro[6], "SFCA313")
		lRet := .F.
	Endif
	oModelCYV:DeActivate()

	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

	//Estorna apontamento não reportados linkados com o reporte(caso houverem)
	If CYQ->CYQ_TPRPOR == "1"

		dbSelectArea("CYD")
		CYD->(dbSetOrder(2))

		If CYD->(dbSeek(xFilial("CYD")+cNRORPO+cIDAT))

			aAreaCYV = CYV->(GetArea())

			CYV->(dbSetOrder(2))
			CYV->(dbGoTop())
			If CYV->(dbSeek(xFilial("CYV")+cNRORPO+CYD->CYD_IDATPV))

				While !CYV->(Eof()) .And. CYV->CYV_FILIAL+AllTrim(CYV->CYV_NRORPO)+AllTrim(CYV->CYV_IDAT) == xFilial("CYV")+AllTrim(cNRORPO)+AllTrim(CYD->CYD_IDATPV)

					If AllTrim(CYV->CYV_NRRPOG) == AllTrim(cSeqOrigem)
						SFCA313OK(CYV->CYV_NRSQRP,dEstorno,.T.)
						Exit
					EndIf
					CYV->(dbSkip())
				End

				CYV->(RestArea(aAreaCYV))

			EndIf
		EndIf
	EndIf

	if !lRet
		DisarmTransaction()

		IF oView != NIL
			oView:Refresh()
		Endif
	Endif

End Transaction

CYQ->(RestArea(aAreaCYQ))

Return lRet

//-------------------------------------------------------------------
// Função executada após ativação do model
//-------------------------------------------------------------------
Static Function SFCA313LD( oModel )

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oModel:LoadValue( 'CYVMASTER', 'CYV_LGRPEO', .T. )
EndIf

Return NIL

//-------------------------------------------------------------------
// Validações
//-------------------------------------------------------------------
Static Function SFCA313POS ( oModel )
Local aArea		:= GetArea()
Local aAreaCY9	:= CY9->(GetArea())
Local aAreaCYY	:= CYY->(GetArea())
Local aAreaCYQ	:= CYQ->(GetArea())
Local aAreaCYX	:= CYX->(GetArea())
Local aAreaCYB	:= CYB->(GetArea())
Local lRet		:= .T.
Local lParada	:= .F.
Local nI		:= 0
Local nI2		:= 0
Local nOpc		:= oModel:GetOperation()
Local oModelCYV	:= oModel:GetModel( 'CYVMASTER' )
Local oModelCZP	:= oModel:GetModel( 'CZPDETAIL' )
Local dIni		:= CTOD('01/01/2999')
Local dFim		:= CTOD('01/01/2000')
Local cIni		:= ''
Local cFim		:= ''
Local cNRORPO	:= oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT		:= oModelCYV:GetValue('CYV_IDAT')
Local aModelCYV	:= {}
Local nHrPrep	:= 0
Local oModelCYQ,oModelCYY,oModelCYX
Local lAlteraEst := Type("lAltEstOp") != "U" .And. lAltEstOp

Begin Transaction

	if nOpc == 4 // Estorno é considerado alteração!

		if Empty(oModelCYV:GetValue('CYV_DTEO'))
			SFCMsgErro(STR0022, "SFCA314") //"É preciso informar uma data para estorno"
			lRet := .F.
		Elseif oModelCYV:GetValue('CYV_TPSTRP') != '1' // Somente validar e processar estorno, quando apontamento finalizado

			lRet := SFCA313PVE(oModelCYV:GetValue('CYV_CDMQ'),cNRORPO,cIDAT,oModelCYV:GetValue('CYV_IDATQO'),oModelCYV:GetValue('CYV_QTATRF'),oModelCYV:GetValue('CYV_QTATAP'))

			// Somente apontamentos finalizados estornar as informações de CYQ, CY9, CYY e tabelas PCP
			if lRet

				dbSelectArea('CYQ')
				CYQ->(dbSetOrder(1))
				CYQ->(dbGoTop())
				IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

					oModelCYQ := FWLoadModel( 'SFCA100' )
					oModelCYQ:SetOperation( 4 )
					If oModelCYQ:Activate()

						For nI := 1 To oModelCYQ:GetModel( 'CY9DETAIL' ):Length()
							oModelCYQ:GetModel('CY9DETAIL'):GoLine( nI )

							if oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_NRORPO') == oModelCYV:GetValue('CYV_NRORPO') .AND.;
						   		oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_IDAT')   == oModelCYV:GetValue('CYV_IDAT')

								if oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_TPST') == '3'
									IF lAlteraEst .Or. IsInCallStack("MATI681") .Or. MSGYESNO(STR0023) //'Deseja alterar o estado da operação? Se sim, a operação passará a ter o estado de Iniciada, senão continuará como finalizada.'
										oModelCYQ:SetValue('CY9DETAIL', 'CY9_TPST', '2')
										lOk := .T.
									Endif
								Endif

								oModelCYQ:SetValue('CY9DETAIL', 'CY9_QTPO', oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_QTPO') - oModelCYV:GetValue('CYV_QTATRP'))
								oModelCYQ:SetValue('CY9DETAIL', 'CY9_QTRF', oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_QTRF') - oModelCYV:GetValue('CYV_QTATRF'))
								oModelCYQ:SetValue('CY9DETAIL', 'CY9_QTRP', oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_QTRP') - oModelCYV:GetValue('CYV_QTATRP'))
								oModelCYQ:SetValue('CY9DETAIL', 'CY9_QTRT', oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_QTRT') - oModelCYV:GetValue('CYV_QTATRT'))
								oModelCYQ:SetValue('CY9DETAIL', 'CY9_QTAP', oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_QTAP') - oModelCYV:GetValue('CYV_QTATAP'))

								Exit
							Endif
						Next

						For nI := 1 to oModelCZP:Length()
							oModelCZP:GoLine(nI)

							For nI2 := 1 To oModelCYQ:GetModel( 'CYPDETAIL' ):Length()
								oModelCYQ:GetModel('CYPDETAIL'):GoLine( nI2 )

								if oModelCYQ:GetModel('CYPDETAIL'):GetValue('CYP_CDMT') == oModelCZP:GetValue('CZP_CDMT')

									oModelCYQ:SetValue('CYPDETAIL', 'CYP_QTRP', oModelCYQ:GetModel('CYPDETAIL'):GetValue('CYP_QTRP') - oModelCZP:GetValue('CZP_QTRPPO'))

									Exit
								Endif
							Next nI2
						Next nI

						oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPST', '3')
						oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPSTOR', '6')

						if oModelCYQ:GetModel('CY9DETAIL'):GetValue('CY9_LGATED')
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_QTORRP', oModelCYQ:GetValue('CYQMASTER', 'CYQ_QTORRP') - oModelCYV:GetValue('CYV_QTATRP'))
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_QTORAP', oModelCYQ:GetValue('CYQMASTER', 'CYQ_QTORAP') - oModelCYV:GetValue('CYV_QTATAP'))
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_QTORRT', oModelCYQ:GetValue('CYQMASTER', 'CYQ_QTORRT') - oModelCYV:GetValue('CYV_QTATRT'))
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_QTORRF', oModelCYQ:GetValue('CYQMASTER', 'CYQ_QTORRF') - oModelCYV:GetValue('CYV_QTATRF'))
						Endif
					Else
						lRet := .F.
						SFCMsgErro(STR0032+" SFCA100", "SFCA313")//"Não foi possível ativar o model"
					Endif
				Endif

				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				CYY->(dbClearFilter())
				CYY->(dbGoTop())
				IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+oModelCYV:GetValue('CYV_IDATQO')))
					oModelCYY := FWLoadModel( 'SFCA315' )
					oModelCYY:SetOperation( 4 )
					If oModelCYY:Activate()

						oModelCYY:SetValue('CYYMASTER', 'CYY_QTATAP', oModelCYY:GetValue('CYYMASTER','CYY_QTATAP') - oModelCYV:GetValue('CYV_QTATAP'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTATRT', oModelCYY:GetValue('CYYMASTER','CYY_QTATRT') - oModelCYV:GetValue('CYV_QTATRT'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTATRF', oModelCYY:GetValue('CYYMASTER','CYY_QTATRF') - oModelCYV:GetValue('CYV_QTATRF'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTATRP', oModelCYY:GetValue('CYYMASTER','CYY_QTATRP') - oModelCYV:GetValue('CYV_QTATRP'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTTEAT', oModelCYY:GetValue('CYYMASTER','CYY_QTTEAT') - oModelCYV:GetValue('CYV_QTTERP'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTTEOE', oModelCYY:GetValue('CYYMASTER','CYY_QTTEOE') - oModelCYV:GetValue('CYV_QTTERP'))
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTTEMQ', oModelCYY:GetValue('CYYMASTER','CYY_QTTEMQ') - oModelCYV:GetValue('CYV_QTTERP'))

						if oModelCYY:GetValue('CYYMASTER', 'CYY_QTATRP') == 0
							oModelCYY:ClearField('CYYMASTER', 'CYY_DTBGSU')
							oModelCYY:ClearField('CYYMASTER', 'CYY_DTEDSU')
							oModelCYY:ClearField('CYYMASTER', 'CYY_HRBGSU')
							oModelCYY:ClearField('CYYMASTER', 'CYY_HREDSU')
							oModelCYY:ClearField('CYYMASTER', 'CYY_DTBGAT')
							oModelCYY:ClearField('CYYMASTER', 'CYY_DTEDAT')
							oModelCYY:ClearField('CYYMASTER', 'CYY_HRBGAT')
							oModelCYY:ClearField('CYYMASTER', 'CYY_HREDAT')
							oModelCYY:SetValue('CYYMASTER', 'CYY_TPSTAT', '3')
						Else
							// Se ainda existe um reporte, tenho que buscar para atualizar as datas do split
							dbSelectArea('CYV')
							CYV->(dbSetOrder(2))
							CYV->(dbGoTop())
							CYV->(dbSeek(xFilial('CYV')+cNRORPO+cIDAT+oModelCYV:GetValue('CYV_IDATQO')))

							While CYV->(!EOF()) .AND. CYV->CYV_NRORPO == cNRORPO .AND.;
													  CYV->CYV_IDAT   == cIDAT .AND.;
													  CYV->CYV_IDATQO == oModelCYV:GetValue('CYV_IDATQO')

								IF Empty(cIni)
									dIni := CYV->CYV_DTRPBG
									dFim := CYV->CYV_DTRPED
									cIni := CYV->CYV_HRRPBG
									cFim := CYV->CYV_HRRPED
								Else
									if CYV->CYV_DTRPBG <= dIni
										if CYV->CYV_DTRPBG == dIni
											if CYV->CYV_HRRPBG < cIni
												cIni := CYV->CYV_HRRPBG
											Endif
										Endif

										dIni := CYV->CYV_DTRPBG
									Endif

									if CYV->CYV_DTRPED >= dFim
										if CYV->CYV_DTRPED == dFim
											if CYV->CYV_HRRPED < cFim
												cFim := CYV->CYV_HRRPED
											Endif
										Endif

										dFim := CYV->CYV_DTRPED
									Endif
								Endif

								CYV->(dbSkip())
							End

							oModelCYY:SetValue('CYYMASTER', 'CYY_DTBGAT', dIni)
							oModelCYY:SetValue('CYYMASTER', 'CYY_DTEDAT', dFim)
							oModelCYY:SetValue('CYYMASTER', 'CYY_HRBGAT', cIni)
							oModelCYY:SetValue('CYYMASTER', 'CYY_HREDAT', cFim)

							if lOk
								oModelCYY:SetValue('CYYMASTER', 'CYY_TPSTAT', '4')
							Endif
						Endif
					Else
						lRet := .F.
						SFCMsgErro(STR0032+" SFCA315", "SFCA313")//Não foi possível ativar o model
					EndIf
				Endif

				// Busca parada de produção relacionada para eliminar
				dbSelectArea('CYX')
				CYX->(dbSetOrder(4))
				CYX->(dbGoTop())
				if CYX->(dbSeek(xFilial('CYX')+oModelCYV:GetValue('CYV_NRSQRP')))

					lParada := .T.

					oModelCYX := FWLoadModel('SFCA311')
					oModelCYX:SetOperation(5)
					oModelCYX:Activate()

					nHrPrep := oModelCYX:GetValue("CYXMASTER","CYX_HRTEUT") + oModelCYX:GetValue("CYXMASTER","CYX_HRTEEX")
				Endif

				if lRet .AND. SFCIntegra() == 1
					lRet := AUTO681(oModel,lParada,nHrPrep)
				Endif

				If lRet
					dbSelectArea("CZ5")
					CZ5->(dbSetOrder(8))
					CZ5->(dbSeek(xFilial("CZ5")+oModelCYV:GetValue('CYV_NRORPO')))

					While CZ5->(!EOF()) .And. CZ5->CZ5_NRORPO == oModelCYV:GetValue('CYV_NRORPO')
						If CZ5->CZ5_NRSQRP == oModelCYV:GetValue('CYV_NRSQRP')
							RecLock('CZ5',.F.)
							CZ5->(dbDelete())
							MsUnLock()
						EndIf

						CZ5->(dbSkip())
					End
				EndIf

				if lRet
					if lParada
						if oModelCYX:VldData()
							oModelCYX:CommitData()
						Else
							aErro := oModelCYX:GetErrorMessage()
							SFCMsgErro(aErro[6], "SFCA311")
							lRet := .F.
						Endif
						oModelCYX:DeActivate()
					Endif

					if oModelCYY:VldData()
						oModelCYY:CommitData()
					Else
						aErro := oModelCYY:GetErrorMessage()
						SFCMsgErro(aErro[6], "SFCA313")
						lRet := .F.
					Endif
					oModelCYY:DeActivate()

					if oModelCYQ:VldData()
						oModelCYQ:CommitData()
					Else
						aErro := oModelCYQ:GetErrorMessage()
						SFCMsgErro(aErro[6], "SFCA313")
						lRet := .F.
					Endif
					oModelCYQ:DeActivate()
				Endif
			Endif
		Endif

		RestArea(aAreaCYY)
		RestArea(aAreaCYX)
		RestArea(aAreaCYB)
		RestArea(aAreaCYQ)
		RestArea(aAreaCY9)
	Endif

	if !lRet
		DisarmTransaction()
	Endif

End Transaction

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Pre validações do estorno - preValidaEstorno - boin536.i9
//-------------------------------------------------------------------
Static Function SFCA313PVE(cCDMQ,cNRORPO,cIDAT,cIDATQO,nRefugada,nAprovada)
Local lRet   := .T.
Local nQTAT  := 0
Local nQTPO  := 0

/* integração com datasul não tem previsão de sair
dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
CYQ->(dbGoTop())
IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))
	if SFCIntegra() == 2 .AND.;
		(CYQ->CYQ_TPSTOR == '7' .OR. CYQ->CYQ_TPSTOR == '8')
		SFCMsgErro(STR0024, "SFCA313") //"Ordem de Produção já está finalizada ou terminada e não pode ser estornada"
		lRet := .F.
	Endif
Endif*/

if lRet

	Pergunte('MTA680',.F.)

	IF MV_PAR07 != 3 // Valida rede-pert

		dbSelectArea('CYD')
		CYD->(dbSetOrder(1))
		CYD->(dbGoTop())
		IF CYD->(dbSeek(xFilial('CYD')+cNRORPO))

			dbSelectArea('CY9')
			CY9->(dbSetOrder(1))
			CY9->(dbGoTop())
			CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

			nQTAT := CY9->CY9_QTAT
			nQTPO := CY9->CY9_QTPO

			dbSelectArea('CYD')
			CYD->(dbSetOrder(3))
			CYD->(dbGoTop())
			CYD->(dbSeek(xFilial('CYD')+cNRORPO+CY9->CY9_CDAC+CY9->CY9_CDRT+CY9->CY9_CDAT))

			dbSelectArea('CY9')
			CY9->(dbSetOrder(3))
			CY9->(dbGoTop())
			IF CY9->(dbSeek(xFilial('CY9')+CYD->CYD_NRORPO+CYD->CYD_CDAC+CYD->CYD_CDRT+CYD->CYD_CDAT))

				IF ROUND(nRefugada + nAprovada,4) * ROUND(CYQ->CYQ_QTOR / nQTAT,4) > ROUND(nQTPO - CY9->CY9_QTPO,4)
					SFCMsgErro(STR0025, "SFCA313") //"Quantidade deve ser menor que a utilizada na operação posterior"
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
Endif

Return lRet
//-------------------------------------------------------------------
/*EstornPrep - Estorna o custo da preparação*/
//-------------------------------------------------------------------
Static Function EstornPrep(cMaquina,cOP,dEmissao,nHrPrep)
	Local cCod		:= PadR(APrModRec(PadR(cMaquina,TamSX3("H1_CODIGO")[1])),TamSX3("B1_COD")[1])
	Local lAchou	:= .F.
	Local lRet    := .T.
	Local cSFRQMB := SuperGetMV("MV_SFRQMB",.F.,"")

	SD3->(dbSetOrder(1))
	cChaveSD3 := xFilial("SD3") + PadR(cOP,TamSX3("D3_OP")[1]) + PadR(cCod,TamSX3("D3_COD")[1]) + PadR(RetFldProd(cCod,"B1_LOCPAD"),TamSX3("D3_LOCAL")[1])
	SD3->(dbSeek(cChaveSD3))

	While !SD3->(EOF()) .And. SD3->(D3_FILIAL+D3_OP+D3_COD+D3_LOCAL) == cChaveSD3
		lEstornado	:= (SD3->D3_ESTORNO != 'S')
		lQuantidad	:= (QtdComp(SD3->D3_QUANT) == nHrPrep)
		lDtEmissao	:= (SD3->D3_EMISSAO == dEmissao)
		lTpMovimen	:= (SD3->D3_TM == cSFRQMB)
		If lEstornado .And. lQuantidad .And. lDtEmissao .And. lTpMovimen
			lAchou := .T.
			Exit
		EndIf
		SD3->(dbSkip())
	End

	If lAchou
		MsExecAuto({|x,y,z| MATA241(x,y,z)},{},Nil,6)
		If lMSErroAuto
			If !IsTelNet()
				MostraErro()
			Else
				ErroTelnet()
			EndIf
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO681
Rotina para Integração com o Protheus - MATA681

@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AUTO681(oModelCYV,lPrep,nHrPrep)
Local aMata681      := {}
Local aProd         := {}
Local cChaveSD3     := ""
Local cDtEmissao    := SToD(' ')
Local cHoraIni      := ''
Local cHoraFim      := ''
Local cIdentSH6     := oModelCYV:GetValue('CYVMASTER','CYV_NRRPET')
Local cLocCZP       := ""
Local cMvPar        := ""
Local cParData      := SuperGetMV("MV_DTAPT",.F.,2) //Indica a data que será gravada na movimentação de estoque. (1=Dt.Atual; 2=Dt.Base; 3=Dt.Inicial; 4=Dt.Final)
Local cSFRQMB       := SuperGetMV("MV_SFRQMB",.F.,"")
Local cTipoHr       := 0
Local lAchou        := .F.
Local lAltPar       := .F.
Local lHelp         := HelpLog(.T.)
Local lHelpDark     := HelpInDark(.F.)
Local lRet          := .T.
Local nI            := 0
Local oModelCZP     := oModelCYV:GetModel('CZPDETAIL')
Local oModelCZW     := oModelCYV:GetModel('CZWDETAIL')

Private lMSErroAuto := .F.
Private nRegSH6     := 0
Private lEstornRec  := .T.

Pergunte("MTA680",.F.)
cTipoHr := GetMv('MV_SFCTPRE') //-- 1-Normal ; 2-Centesimal

//-- Conversao da hora:
//-- Normal para centesimal: (normal * 100) / 60
//-- Centesimal para normal: (centesimal * 60) / 100

//-- Numero da ordem de producao:
aAdd(aMata681,{"H6_OP"     ,PadR(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),TamSX3("H6_OP")[1]),NIL})

//-- Codigo do produto produzido:
aAdd(aMata681,{"H6_PRODUTO",PadR(oModelCYV:GetValue('CYVMASTER','CYV_CDACRP'),TamSX3("H6_PRODUTO")[1]),NIL})

//-- Codigo da operacao apontada:
aAdd(aMata681,{"H6_OPERAC" ,PadR(oModelCYV:GetValue('CYVMASTER','CYV_CDAT'),TamSX3("H6_OPERAC")[1]),NIL})

aAdd(aMata681,{"H6_SEQ",Space(TamSX3("H6_SEQ")[1]),NIL})

//-- Data de inicio do apontamento:
aAdd(aMata681,{"H6_DATAINI",oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG'),NIL})

//-- Hora inicio do apontamento:
//-- Respeitar o tipo de hora parametrizado na rotina (nTipoHr)

if cTipoHr=='1'
	cHoraIni := Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG'),1,5)
Else
	cHoraIni := Substr(ALLTRIM(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG')),1,2) + ':' + Substr(ALLTRIM(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG')),4,2)
Endif
aAdd(aMata681,{"H6_HORAINI",cHoraIni,NIL})

//-- Data de termino do apontamento
aAdd(aMata681,{"H6_DATAFIN",oModelCYV:GetValue('CYVMASTER','CYV_DTRPED'),NIL})

//-- Hora de termino do apontamento
//-- Respeitar o tipo de hora parametrizado na rotina (nTipoHr)
if cTipoHr=='1'
	cHoraFim := Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED'),1,5)
Else
	cHoraFim := Substr(ALLTRIM(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED')),1,2) + ':' + Substr(ALLTRIM(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED')),4,2)
Endif
aAdd(aMata681,{"H6_HORAFIN",cHoraFim,NIL})

aAdd(aMata681,{"INDEX",1,NIL})

aAdd(aMata681,{"H6_FILIAL",xFilial('SH6'),NIL})

If !RecnoSH6(oModelCYV     ,;
			 aMata681[1][2],; //OP
			 aMata681[2][2],; //Produto
			 aMata681[3][2],; //Operação
			 aMata681[4][2],; //Sequência
			 aMata681[5][2],; //Data Inicial
			 aMata681[6][2],; //Hora Inicial
			 aMata681[7][2],; //Data Final
			 aMata681[8][2],; //Hora Final
			 cIdentSH6)

	Help( , , 'HELP', 'SFCA313', STR0034, 1, 0) //"Não foi possível identificar precisamente o registro a ser estornado no PCP. O apontamento será estornado, porém, é necessária a validação dos apontamentos SFC com PCP."
EndIf

msExecAuto({|x,y| MATA681(x,y)},aMata681,5)

If lMSErroAuto //-- Tratativa de erro
	If !IsTelNet()
		MostraErro()
	Else
		ErroTelnet()
	EndIf
	lRet = .F.
EndIf

If lRet
	If ExistBlock("SF313Ex681")
		lRet := ExecBlock("SF313Ex681",.F.,.F.,{oModelCYV})
	EndIf
EndIf

If lRet

	If lPrep
		lRet := EstornPrep(oModelCYV:GetValue('CYVMASTER','CYV_CDMQ'), oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'), oModelCYV:GetValue('CYVMASTER','CYV_DTBGSU'),nHrPrep)
	EndIf

	//-- Estorno das requisicoes
	If lRet .AND. GetMV("MV_REQAUT") == 'D'

		lAltPar := .F.
		cMvPar  := ""
		lRet    := PerMATA241(oModelCYV, @lAltPar, @cMvPar)

		If lRet
    		//COM O H6_IDENT BUSCAR O CAMPO D3_EMISSAO DA SD3
    		//USAR ESSE VALOR DA D3_EMISSAO PARA FILTRAR A DATA DO EXEXAUTO DO MATA240
			dbSelectArea("SD3")
			dbSetOrder(1)
			dbSeek(xFilial("SD3")+SH6->H6_OP+SH6->H6_PRODUTO)
			While SD3->(!EOF()) .And. SH6->H6_OP+SH6->H6_PRODUTO == SD3->D3_OP+SD3->D3_COD
        		If SH6->H6_PRODUTO+SH6->H6_IDENT == SD3->D3_COD+SD3->D3_IDENT .And. SD3->D3_CF == "PR0"
            		cDtEmissao := SD3->D3_EMISSAO
             		Exit
            	EndIf
            	SD3->(dbSkip())
    		EndDo

			If Empty(cDtEmissao)
				Do Case
					Case cParData == 1 //Dt. Atual
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//Date()
					Case cParData == 2 //Dt. Base
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//dDataBase
					Case cParData == 3 //Dt. Inicial
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG')
					Case cParData == 4 //Dt. Final
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRPED')
					OtherWise
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//dDataBase
				End Case
			EndIf

			For nI := 1 To oModelCZP:Length()
				oModelCZP:GoLine(nI)
				cLocCZP := ""
			
				If !Empty(oModelCZP:GetValue('CZP_CDMT'))
					SD3->(dbSetOrder(1)) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
					cChaveSD3 := 	xFilial("SD3")+;
					PadR(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),TamSX3("D3_OP")[1])+;
					PadR(oModelCZP:GetValue('CZP_CDMT'),TamSX3("D3_COD")[1])
				
					IF !EMPTY(oModelCZP:GetValue('CZP_CDDP'))
						cLocCZP := PadR(oModelCZP:GetValue('CZP_CDDP'),TamSX3("D3_LOCAL")[1])
						cChaveSD3 += cLocCZP
					ENDIF
			
					SD3->(dbSeek(cChaveSD3))

					While !SD3->(EOF()) .And. SD3->(D3_FILIAL+D3_OP+D3_COD+IIF(!EMPTY(cLocCZP),D3_LOCAL,"")) == cChaveSD3
						If SD3->D3_ESTORNO <> 'S' .And.;
							QtdComp(SD3->D3_QUANT) == Round(oModelCZP:GetValue('CZP_QTRPPO'),TamSX3("D3_QUANT")[2]) .And.;
							SD3->D3_EMISSAO == cDtEmissao .And.;
							SD3->D3_TM == cSFRQMB	

							aProd := {}
							aAdd(aProd, {"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
							aAdd(aProd, {"INDEX"    ,4             ,Nil})

							MSExecAuto({|x,y| MATA240(x,y)}, aProd, 5) //5-Estorno
							If lMSErroAuto
								If !IsTelNet()
									MostraErro()
								Else
									ErroTelnet()
								EndIf
								lRet := .F.
							EndIf
							Exit
						EndIf					
						SD3->(dbSkip())														
					End
				Endif

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf 

		If lAltPar
			SetMVValue("MTA240",cMvPar,1)
		EndIF 		
		Pergunte("MTA680",.F.)
	Endif

	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+oModelCYV:GetValue('CYVMASTER','CYV_CDMQ')))

	//-- Estorno da MOD
	IF lRet
		lAltPar := .F.
		cMvPar  := ""
		lRet    := PerMATA241(oModelCYV, @lAltPar, @cMvPar)		

		CYQ->(dbSetOrder(1))
		If CYQ->(dbSeek(xFilial('CYQ')+oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'))) .And. CYQ->CYQ_TPGGF == '1'
			//COM O H6_IDENT BUSCAR O CAMPO D3_EMISSAO DA SD3
       		//USAR ESSE VALOR DA D3_EMISSAO PARA FILTRAR A DATA DO EXEXAUTO DO MATA240
			If Empty(cDtEmissao)
	   			dbSelectArea("SD3")
	   			dbSetOrder(1)
	   			dbSeek(xFilial("SD3")+SH6->H6_OP+SH6->H6_PRODUTO)
	   			While SD3->(!EOF()) .And. SH6->H6_OP+SH6->H6_PRODUTO == SD3->D3_OP+SD3->D3_COD
            		 If SH6->H6_PRODUTO+SH6->H6_IDENT == SD3->D3_COD+SD3->D3_IDENT .And. SD3->D3_CF == "PR0"
             			cDtEmissao := SD3->D3_EMISSAO
             			Exit
             		EndIf
             		SD3->(dbSkip())
       			EndDo
			EndIf

			If Empty(cDtEmissao)
				Do Case
					Case cParData == 1 //Dt. Atual
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//Date()
					Case cParData == 2 //Dt. Base
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//dDataBase
					Case cParData == 3 //Dt. Inicial
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG')
					Case cParData == 4 //Dt. Final
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRPED')
					OtherWise
						cDtEmissao := oModelCYV:GetValue('CYVMASTER','CYV_DTRP')//dDataBase
				End Case
			EndIf

			For nI := 1 To oModelCZW:Length()
				oModelCZW:GoLine(nI)
				If oModelCZW:GetValue('CZW_CDCETR') == CYB->CYB_CDCETR
					cCod := PadR(APrModRec(PadR(CYB->CYB_CDMQ,TamSX3("H1_CODIGO")[1])),TamSX3("B1_COD")[1])

					SD3->(dbSetOrder(1))
					cChaveSD3 := 	xFilial("SD3")+;
									PadR(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),TamSX3("D3_OP")[1])+;
									PadR(cCod,TamSX3("D3_COD")[1])+;
									PadR(RetFldProd(cCod,"B1_LOCPAD"),TamSX3("D3_LOCAL")[1])
					SD3->(dbSeek(cChaveSD3))
					lAchou := .F.
					While !SD3->(EOF()) .And. SD3->(D3_FILIAL+D3_OP+D3_COD+D3_LOCAL) == cChaveSD3
						If SD3->D3_ESTORNO <> 'S' .And.;
							QtdComp(SD3->D3_QUANT) == Round(oModelCZW:GetValue('CZW_HRTEGF'),TamSX3('D3_QUANT')[2]) .And.;
							SD3->D3_EMISSAO == cDtEmissao .And.;
							SD3->D3_TM == cSFRQMB
							
							aProd := {}
							aAdd(aProd, {"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
							aAdd(aProd, {"INDEX"    ,4             ,Nil})

							MSExecAuto({|x,y| MATA240(x,y)}, aProd, 5) //5-Estorno
							If lMSErroAuto
								If !IsTelNet()
									MostraErro()
								Else
									ErroTelnet()
								EndIf
								lRet := .F.
							EndIf

							Exit
						EndIf
						SD3->(dbSkip())
					End
				EndIf

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf

		If lAltPar
			SetMVValue("MTA240",cMvPar,1)
		EndIF 		
		Pergunte("MTA680",.F.)
	Endif
Endif

HelpInDark(lHelpDark)
HelpLog(lHelp)

Return lRet

/*/{Protheus.doc} RecnoSH6
Busca o R_E_C_N_O_ do registro correspondente na SH6
@author Marcelo Neumann
@since 14/01/2020
@version 1.0
@param 01 oModelCYV, object   , Modelo de Dados
@param 02 cOp      , character, Número da OP
@param 03 cProduto , character, Código do Produto
@param 04 cOperac  , character, Código da Operação
@param 05 cSeq     , character, Sequência
@param 06 cDataIni , character, Data inicial
@param 07 cHoraIni , character, Hora inicial
@param 08 cDataFim , character, Data Final
@param 09 cHoraFim , character, Hora final
@param 10 cIdentSH6, character, Identificador do registro na SH6 (PCP)
/*/
Static Function RecnoSH6(oModelCYV, cOp, cProduto, cOperac, cSeq, cDataIni, cHoraIni, cDataFim, cHoraFim, cIdentSH6)

    Local cAlias := GetNextAlias()
	Local lRet   := .T.
	Local cWhere := "%D_E_L_E_T_ = ' '"

	//Se já possui o identificador, busca o registro usando-o
	If !Empty(cIdentSH6)
		cWhere += " AND H6_IDENT = '" + PadR(AllTrim(cIdentSH6), TamSX3("H6_IDENT")[1]) + "'"
	EndIf
	cWhere += "%"

    BeginSql Alias cAlias
		SELECT R_E_C_N_O_
		  FROM %Table:SH6%
		 WHERE H6_FILIAL  = %xfilial:SH6%
		   AND H6_OP      = %Exp:cOp%
		   AND H6_PRODUTO = %Exp:cProduto%
		   AND H6_OPERAC  = %Exp:cOperac%
		   AND H6_SEQ     = %Exp:cSeq%
		   AND H6_DATAINI = %Exp:cDataIni%
		   AND H6_HORAINI = %Exp:cHoraIni%
		   AND H6_DATAFIN = %Exp:cDataFim%
		   AND H6_HORAFIN = %Exp:cHoraFim%
		   AND %Exp:cWhere%
    EndSql

    While (cAlias)->(!Eof())
		//Se encontrou mais de um registro na SH6, retorna erro solicitando a correção na base
		If nRegSH6 > 0
			lRet    := .F.
			nRegSH6 := 0
			Exit
		EndIf

		nRegSH6 := (cAlias)->R_E_C_N_O_

        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} PerMATA241
Valida se existe o Pergunte 'Quanto ao estorno' no MATA241
@author Michele Girardi
@since 14/01/2020
@version 1.0
@param 01 oModelCYV, object    , Modelo de Dados
@param 02 lAltPar  , lógico    , Indicador se alteração o valor do parâmetro
@param 03 cMvPar   , character , Parâmetro do Pergunte Quanto ao Estorno
/*/
Static Function PerMATA241(oModelCYV, lAltPar, cMvPar)
	
	Local lRet    := .T.
	
	cMvPar  := "mv_par04"

	// Pergunta cadastrada no MATA240 a partir do release 12.1.37 
	// (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
	If cPaisLoc == "ANG" .Or. cPaisLoc == "EQU" .Or. cPaisLoc == "HAI" .Or. cPaisLoc == "PTG"
		cMvPar := "mv_par05"
	EndIf
		
	&cMvPar := ""
	Pergunte("MTA240",.F.)
	If Empty(&cMvPar)
		//Obrigar a criação do Pergunte no MT240
		oModelCYV:SetErrorMessage('CYVMASTER', 'CYY_CDCETR',,,, STR0035 ) // 'Para realizar o estorno das requisições é necessário incluir o parâmetro "Quanto ao estorno" no Pergunte "MTA240".'
		lRet = .F.
	Else
		//Validar se o Pergunte está com o valor 2 
		//Se não estiver alterar para 2 e depois retornar para o valor original	
		If !(&cMvPar == 2)
			SetMVValue("MTA240",cMvPar,2)
			lAltPar := .T.
		EndIf 
	EndIf

Return lRet

