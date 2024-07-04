#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA666.CH'
#DEFINE APROV_SOLIC 7
#DEFINE ENC_APROV 8
#DEFINE OPER_ENVWF 9

STATIC  cRetLocal :=""
STATIC  cRetDescri:=""
STATIC	 lAutomato:= .F.
STATIC	 lRetAuto := .F.
STATIC __nOper 	  := 0 // Operacao da rotina
STATIC __lConfirmar		:= .F.
STATIC	__lBTNConfirma	:= .T.
STATIC _oFINA6661
//Static para contingência do uso da função MTFLUIGATV
Static __lMTFLUIGATV := FindFunction("MTFLUIGATV")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA666

Cadastros da Solicitação de Viagens

@author Antonio Florêncio Domingos Filho
@since 14/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function FINA666()
Local oBrowse
Local aUsuario	  := {}
Local cFiltro := ""

__nOper := 0

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FW3' )
oBrowse:SetDescription( STR0003 ) //'Solicitação de Viagens'

If ExistBlock( "F666FILT" )
	cFiltro	:= ExecBlock( "F666FILT" )
	oBrowse:SetFilterDefault( cFiltro )
Endif

//Adiciona Legenda                                           
oBrowse:AddLegend("FW3_STATUS == '0' " , "GREEN",STR0053) //Em Aberto
oBrowse:AddLegend("FW3_STATUS == '1' " , "WHITE",STR0054) //Conferência
oBrowse:AddLegend("FW3_STATUS == '2' " , "BLACK",STR0055) //Cancelada
oBrowse:AddLegend("FW3_STATUS == '3' " , "YELLOW",STR0056) //Aguardando Aprovação
oBrowse:AddLegend("FW3_STATUS == '4' " , "RED"	,STR0057) //Finalizada		
oBrowse:AddLegend("FW3_STATUS == '5' " , "BLUE"	,STR0059) //Aprovada		
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição de Menu

@author Antonio FDomingos Filho
@since 14/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
Local aUserMenu	:= {}

ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FINA666' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FINA666' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FINA666' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.FINA666' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0060 ACTION 'F666Aprov'       OPERATION 7 ACCESS 0 //'Aprovação' 
ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.FINA666' OPERATION 8 ACCESS 0 //'Imprimir'
ADD OPTION aRotina Title STR0027 ACTION 'F666ENVSOL'      OPERATION 10 ACCESS 0 //'Enc. p/ Depto Viagens' 
ADD OPTION aRotina Title STR0086 ACTION 'F666EnvAp'       OPERATION 4 ACCESS 0 //'Enc. p/ Aprovação"
ADD OPTION aRotina Title STR0095 ACTION 'F666ENVWF'       OPERATION 4 ACCESS 0 //"Reenvio do WF"

// Ponto de entrada para acrescentar botoes no menu
If ExistBlock('FA666Menu')
	aUserMenu := ExecBlock('FA666Menu')
	If ValType( aUserMenu ) == 'A'
		aEval( aUserMenu, { |aAux| Aadd( aRotina, aAux ) } )
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

@author Antonio Florêncio Domingos Filho
@since 14/05/2015
@version 12.1.6
/*/

//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruFW3 := FWFormStruct( 1, 'FW3', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFW4 := FWFormStruct( 1, 'FW4', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFW5 := FWFormStruct( 1, 'FW5', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruADT := FWFormStruct( 1, 'FW5', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFW6 := FWFormStruct( 1, 'FW6', /*bAvalCampo*/, /*lViewUsado*/ )
Local bLinPre  := { |oModel, nLine, cAction,cField, xValue, xOldValue| FW5LinPre( oModel, nLine, cAction, cField,xValue, xOldValue ) }
Local oModel

oModel := MPFormModel():New(STR0020, /*bPreValidacao*/ ,{||F666TUDOOK()},{ |oModel| F666GRVMD( oModel ) },/*bCancel*/) //'FINA666'
oStruFW3:AddTrigger('FW3_CLIENT','FW3_LOJA', {|| .T. }  , {|| POSICIONE('SA1',1,xFilial("SA1")+M->FW3_CLIENT,"A1_LOJA") }  )
oStruFW3:AddTrigger('FW3_CLIENT','FW3_NOME', {|| .T. }  , {|| Padr(POSICIONE('SA1',1,xFilial("SA1")+M->FW3_CLIENT,"A1_NOME"),TamSx3('FW3_NOME')[1] ) }  )
oStruFW5:AddTrigger('FW5_PARTIC','FW5_NOME', {|| .T. }  , {|| POSICIONE('RD0',1,xFilial("RD0")+M->FW5_PARTIC,"RD0_NOME") }  )
oStruADT:AddTrigger('FW5_PARTIC','FW5_NOME', {|| .T. }  , {|| POSICIONE('RD0',1,xFilial("RD0")+M->FW5_PARTIC,"RD0_NOME") }  )
oStruADT:AddTrigger('FW5_ADIANT','FW5_VALOR',{|| .T. }  , {|| F666VALADT() } )
//
oStruFW3:AddTrigger('FW3_DTINI' ,'FW3_DTINI', {|| .T. }  , {|| F666Recalc(oModel) } )
oStruFW3:AddTrigger('FW3_DTFIM' ,'FW3_DTFIM', {|| .T. }  , {|| F666Recalc(oModel) } )

oStruFW6:AddTrigger('FW6_CC','FW6_DESC', {|| .T. }  , {|| POSICIONE('CTT',1,xFilial("CTT")+M->FW6_CC,"CTT_DESC01") }  )
oStruFW3:AddTrigger("FW3_CODORI"  	, "FW3_DESORI"	, {|| .T. }  , {|| FN666ODesc() }  )
oStruFW3:AddTrigger("FW3_CODDES"  	, "FW3_DESDES"	, {|| .T. }  , {|| FN666DDesc() }  )
//
oStruFW6:AddTrigger('FW6_CLVL'  ,'FW6_DSCLVL',{||.T.},{|oModel| If( !Empty(oModel:GetValue('FW6_CLVL')),Posicione("CTH",1,xFilial("CTH")+oModel:GetValue('FW6_CLVL'),"CTH_DESC01"), "" ) })
oStruFW6:AddTrigger('FW6_ITECTA','FW6_DSITCT',{||.T.},{|oModel| If( !Empty(oModel:GetValue('FW6_ITECTA')),Posicione("CTD",1,xFilial("CTD")+oModel:GetValue('FW6_ITECTA'),"CTD_DESC01"), "" ) })
//
oModel:AddFields( 'FW3MASTER', /*cOwner*/, oStruFW3 )
oModel:AddGrid( 'FW4DETAIL', 'FW3MASTER',oStruFW4,/*bPreValidacao*/ , /*bPosValidacao*/ , /*bPreVal*/ , /*bPosVal*/ , /*BLoad*/ )
oModel:AddGrid( 'FW5DETAIL', 'FW4DETAIL',oStruFW5, bLinPre , { |oModel| F666FW5POS(oModel) } , /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'FW6DETAIL', 'FW4DETAIL',oStruFW6,/*bPreValidacao*/ , { |oModel| F666FW6POS(oModel) } , /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'ADTDETAIL', 'FW3MASTER',oStruADT,/*bPreValidacao*/ , /*bPos*/ , /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//
oStruFW3:SetProperty("FW3_DESORI",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FN666ODesc()' ) )
oStruFW3:SetProperty("FW3_DESDES",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FN666DDesc()' ) )
//
oStruFW6:SetProperty('FW6_DSCLVL',MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "If( !INCLUI,Posicione('CTH',1,xFilial('CTH')+FW6->FW6_CLVL,'CTH_DESC01'), '' )"))
oStruFW6:SetProperty('FW6_DSITCT',MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "If( !INCLUI,Posicione('CTD',1,xFilial('CTD')+FW6->FW6_ITECTA,'CTD_DESC01'), '' )"))
oStruFW6:SetProperty('FW6_DESC'  ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "If(!INCLUI,POSICIONE('CTT',1,xFilial('CTT')+FW6->FW6_CC,'CTT_DESC01'),'')"))
//
oStruFW5:SetProperty('FW5_NOME',MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,"If( !INCLUI, POSICIONE('RD0',1,xFilial('RD0')+FW5->FW5_PARTIC,'RD0_NOME'),'')"))
//
oStruADT:SetProperty('FW5_NOME',MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,"If( !INCLUI, POSICIONE('RD0',1,xFilial('RD0')+FW5->FW5_PARTIC,'RD0_NOME'),'')"))
//
oStruFW3:SetProperty("FW3_CODORI",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'FN666VlCpo("1")' ) )
oStruFW3:SetProperty("FW3_CODDES",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'FN666VlCpo("2")' ) )


oModel:SetRelation( 'FW4DETAIL', { { 'FW4_FILIAL', 'xFilial( "FW4" )' }, { 'FW4_SOLICI', 'FW3_SOLICI' } }, FW4->( IndexKey( 1 ) ) )
oModel:SetRelation( 'FW5DETAIL', { { 'FW5_FILIAL', 'xFilial( "FW5" )' }, { 'FW5_SOLICI', 'FW3_SOLICI' } , { 'FW5_ITEM', 'FW4_ITEM' } }, FW5->( IndexKey( 1 ) ) )
oModel:SetRelation( 'ADTDETAIL', { { 'FW5_FILIAL', 'xFilial( "FW5" )' }, { 'FW5_SOLICI', 'FW3_SOLICI' } , { 'FW5_ITEM', 'FW4_ITEM' } }, FW5->( IndexKey( 1 ) ) )
oModel:SetRelation( 'FW6DETAIL', { { 'FW6_FILIAL', 'xFilial( "FW6" )' }, { 'FW6_SOLICI', 'FW3_SOLICI' } , { 'FW6_ITEM', 'FW4_ITEM' } }, FW6->( IndexKey( 1 ) ) )

oModel:GetModel( 'FW5DETAIL' ):SetUniqueLine( { 'FW5_PARTIC' } )
oModel:SetDescription( STR0003 ) //'Solicitação de Viagens'
oModel:GetModel( 'FW3MASTER' ):SetDescription( STR0010 ) //'Cabeçalho Solicitação de Viagem'
oModel:GetModel( 'FW4DETAIL' ):SetDescription( STR0011 ) //'Itens solicitação de viagem'
oModel:GetModel( 'FW5DETAIL' ):SetDescription( STR0001 ) //'Participantes'
oModel:GetModel( 'FW6DETAIL' ):SetDescription( STR0106 ) //'Custos'
//
oModel:GetModel( 'ADTDETAIL' ):SetOnlyQuery( .T. )
//
If __nOper != 0
	oModel:GetModel('FW4DETAIL'):SetNoInsertLine( .T. )
	oModel:GetModel('FW4DETAIL'):SetNoUpdateLine( .T. )
	oModel:GetModel('FW4DETAIL'):SetNoDeleteLine( .T. )
	
	oModel:GetModel('FW5DETAIL'):SetNoInsertLine( .T. )
	oModel:GetModel('FW5DETAIL'):SetNoUpdateLine( .T. )
	oModel:GetModel('FW5DETAIL'):SetNoDeleteLine( .T. )
	
	oModel:GetModel('FW6DETAIL'):SetNoInsertLine( .T. )
	oModel:GetModel('FW6DETAIL'):SetNoUpdateLine( .T. )
	oModel:GetModel('FW6DETAIL'):SetNoDeleteLine( .T. )
EndIf

	
oModel:SetVldActivate( {|oModel| F666VLMod(oModel) } )
oModel:SetActivate( {|oModel| F666Actv( oModel )})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
// Definição de View do Sistema

@author Antonio Florêncio Domingos Filho
@since 14/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oStruFW3 := FWFormStruct( 2, 'FW3' )
Local oStruFW4 := FWFormStruct( 2, 'FW4' )
Local oStruFW5 := FWFormStruct( 2, 'FW5', {|x| (AllTrim(x) $ 'FW5_PARTIC|FW5_NOME') } )
Local oStruFW6 := FWFormStruct( 2, 'FW6' )
Local oStruADT := FWFormStruct( 2, 'FW5', {|x| (AllTrim(x) $ 'FW5_PARTIC|FW5_NOME|FW5_ADIANT|FW5_VALOR')} )
Local oModel   := FWLoadModel( 'FINA666' )
Local oView
Local nX
Local nY

oStruADT:SetProperty('FW5_ADIANT',MVC_VIEW_ORDEM ,'01')
oStruADT:SetProperty('FW5_PARTIC',MVC_VIEW_ORDEM ,'02')
oStruADT:SetProperty('FW5_NOME'	 ,MVC_VIEW_ORDEM ,'03')
oStruADT:SetProperty('FW5_VALOR' ,MVC_VIEW_ORDEM ,'04')
//
oStruADT:SetProperty('FW5_PARTIC',MVC_VIEW_CANCHANGE, .F.)

oStruFW3:RemoveField('FW3_USER')
oStruFW4 := FWFormStruct( 2, 'FW4', {|cCampo| ( AllTrim(cCampo) $ "FW4_ITEM/FW4_TIPO/FW4_OBS/F4_SOLICI") } )
oStruFW6 := FWFormStruct( 2, 'FW6', {|cCampo| !( AllTrim(cCampo) $ "FW6_SOLICI/FW6_ITEM") } )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField('VIEW_FW3', oStruFW3, 'FW3MASTER' )
oView:AddGrid('VIEW_FW4',oStruFW4, 'FW4DETAIL' )
oView:AddGrid('VIEW_ADT',oStruADT, 'ADTDETAIL' )
oView:CreateHorizontalBox( 'SUPERIOR', 35 )
oView:CreateHorizontalBox( 'INFERIOR', 65 )

oView:CreateFolder('FOLDERADT', 'INFERIOR')
oView:AddSheet('FOLDERADT','SERVICOS',STR0012) // 'Serviços'
oView:CreateHorizontalBox( 'BOX_FW4', 050,,, 'FOLDERADT', 'SERVICOS')

oView:CreateHorizontalBox( 'BOX_OBS', 050,,, 'FOLDERADT', 'SERVICOS')

//
oView:AddSheet('FOLDERADT','ADIANT',STR0105) // 'Adiantamentos'
oView:CreateHorizontalBox( 'BOX_ADT', 100,,, 'FOLDERADT', 'ADIANT')
//
oView:CreateFolder( 'FOLDER', 'BOX_OBS')

oView:AddSheet('FOLDER','PARTIC',STR0001) // 'Participantes'

oView:CreateHorizontalBox( 'BOX_PARTIC', 100,,, 'FOLDER', 'PARTIC')

oView:AddGrid('VIEW_FW5' , oStruFW5,'FW5DETAIL')

oView:AddSheet('FOLDER','CUSTO',STR0106) // Custos

oView:CreateHorizontalBox( 'BOX_CUSTO', 100,,, 'FOLDER', 'CUSTO')

oView:AddGrid('VIEW_FW6' , oStruFW6,'FW6DETAIL')

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FW3', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_FW4', 'BOX_FW4' )
oView:SetOwnerView( 'VIEW_FW5', 'BOX_PARTIC' )
oView:SetOwnerView( 'VIEW_FW6', 'BOX_CUSTO' )
oView:SetOwnerView( 'VIEW_ADT', 'BOX_ADT' )

oView:AddIncrementField( 'VIEW_FW4', 'FW4_ITEM' )

oView:EnableTitleView('VIEW_FW4',STR0012) //'Serviços'

If __nOper == APROV_SOLIC
	oView:AddUserButton(STR0093 ,'OK',{|oView| FN666APSol(oView,'1') } )//'Aprovar'
	oView:AddUserButton(STR0094,'OK',{|oView| FN666APSol(oView,'2') } )//'Reprovar'
EndIf

If __nOper != 0

	aFW3TRB := FW3->( DbStruct() )
	For nX := 1 To Len( aFW3TRB )
		If	!aFW3TRB[nX][1] $ 'FW3_MOTVFL'
			For nY := 1 To Len( oStruFW3:AFIELDS)
				If oStruFW3:AFIELDS[nY][1] == aFW3TRB[nX][1]
					oStruFW3:SetProperty( aFW3TRB[nX][1] , MVC_VIEW_CANCHANGE, .F.)
				EndIf
			Next nY
		Else
			For nY := 1 To Len( oStruFW3:AFIELDS)
				If oStruFW3:AFIELDS[nY][1] == aFW3TRB[nX][1]
					oStruFW3:SetProperty( aFW3TRB[nX][1] , MVC_VIEW_CANCHANGE, .T.)
				EndIf
			Next nY
		EndIf
	Next nX
Else
	oStruFW3:SetProperty( "FW3_MOTVFL" , MVC_VIEW_CANCHANGE, .F.)
EndIf

If  __lBTNConfirma 
	oView:AddUserButton( "Cancelar", 'OK', {|oView| F666CancVs(oView) } )	//"Cancelar"
EndIf

oView:SetViewCanActivate({|| F666VldView()})
oView:SetCloseOnOK({ || .T. })

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F666VPARTI(oModel)
// Validação do Participante
// Permitido apenas participantes com superiores cadastrados.

@author Antonio Florêncio Domingos Filho
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Function F666VPARTI()
Local lRet	:= .T.
Local oModel	:= Nil
Local cPartic	:= ""
Local cSolic	:= ""	
Local aArea		:= GetArea()

//Se houver ponto de entrada, então valida conforme as regras personalizadas. Do contrário, faz a validação padrão da rotina.
If ExistBlock("F666VLDP")
	lRet := ExecBlock( "F666VLDP" )
Else
	oModel := FWModelActive() //Modelo de dados ativo.
	cPartic := Alltrim( oModel:GetValue( "FW5DETAIL", "FW5_PARTIC" ) )
	cSolic := Alltrim( oModel:GetValue( "FW3MASTER", "FW3_USER" ) )
	
	dbSelectArea("RD0")
	RD0->(dbSeek( xFilial("RD0") + cPartic ))  
	//Pode solicitar para ele e para os subordinados.	
	If  !(cSolic == cPartic  .OR. (cSolic == RD0->RD0_APROPC .OR. cSolic == RD0->RD0_APSUBS))
		
		Help(,,"VLDPARTIC",,OemToANSI(STR0091), 1, 0 )//'Apenas o próprio participante da viagem ou seu aprovador pode incluir solicitações de viagens!'
		lRet := .F.
		
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F666VBLQAD(oModel)
// Validação bloqueio do adiantamento

@author Antonio Florêncio Domingos Filho
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Function F666VBLQAD()

Local lRet := .T.
Local oModel := FWModelActive() //Modelo de dados ativo.
Local cPartic := oModel:Getvalue('FW5DETAIL','FW5_PARTIC')
Local cPERMAD:= CriaVar("RD0_PERMAD",.F.)	

cPERMAD := POSICIONE('RD0',1,xFilial("RD0")+cPartic,"RD0_PERMAD")
 	
If cPERMAD == "1"

	Help(,,"VLDBLQADTO",,OemToANSI(STR0023), 1, 0 )//'Participante está com adiantamento bloqueado!'
	lRet := .F.

EndIf


Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F666FW3SX5
Consulta Especifica de Locais FW3LOC - SX5³

@author Antonio Florêncio Domingos Filho
@since 05/06/2015
@version 12.1.6
/*/
Function F666FW3SX5()
Local oModel	:= FWModelActive() //Modelo de dados ativo.
Local cNacion	:= ''
Local bRet		:= .F.

bRet := F666FilSX5(cNacion)
If oModel:GetId() == "FINA666"
	cNacion := oModel:Getvalue('FW3MASTER','FW3_NACION')
ElseIf oModel:GetId() == "FINA665"
	cNacion := oModel:Getvalue('FL5MASTER','FL5_NACION')
EndIf

If cNacion <> nil .And. (Empty(cRetLocal) .Or. Empty(cRetDescri))
	bRet := F666FilSX5(cNacion)
Endif

Return bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F666FilSX5
Filtra a tabela SX5 pela variavel cNacion 
(1 para tabela "12-Estados" ou 2 para tabela "BH-Paises")

@author Antonio Florêncio Domingos Filho
@since 05/06/2015
@version 12.1.6
/*/
Static Function F666FilSX5(cNacion)

Local cQry:=""
Local oLstSX5 := nil
Local nX := 1
Private oDlgSX5 := nil
Private _bRet := .F.
Private aDadosSX5 := {}
Private aStru     := SX5->(dbStruct())
Private cLocal := If(cNacion="1","12","BH")

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

//------------------
//Criação da tabela temporaria 
//------------------

If _oFINA6661 <> Nil
	_oFINA6661:Delete()
	_oFINA6661 := Nil
Endif

cAlias1 := GetNextAlias()

_oFINA6661 := FWTemporaryTable():New( cAlias1 )  
_oFINA6661:SetFields(aStru) 	
_oFINA6661:AddIndex("1", {"X5_FILIAL","X5_TABELA","X5_CHAVE"})	
_oFINA6661:Create()	

Processa({||SqlToTrb(cQry, aStru, cAlias1)})	// Cria arquivo temporario

(cAlias1)->(DbGoTop())
If (cAlias1)->(Eof())
	Aviso( STR0014,STR0015, {STR0016} )//'Consulta de Ordem de Chave'#'Não existe dados a consultar'#'Ok'
	Return .F.

Endif

Do While (cAlias1)->(!Eof())

	aAdd( aDadosSX5, { (cAlias1)->X5_CHAVE, (cAlias1)->X5_DESCRI } )

	(cAlias1)->(DbSkip())

Enddo

(cAlias1)->(DbCloseArea())

//Deleta tabela temporária no banco de dados
If _oFINA6661 <> Nil
	_oFINA6661:Delete()
	_oFINA6661 := Nil
Endif
nList := aScan(aDadosSX5, {|x| Alltrim(x[1]) == cLocal })

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgSX5 Title STR0017 From 0,0 To 280, 500 Of oMainWnd Pixel //'Busca de Local'

@ 5,5 LISTBOX oLstSX5 ;
VAR lVarMat ;
Fields HEADER STR0018, STR0019; //"Local", "Descrição"
SIZE 245,110 On DblClick ( F666DESCX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ) ;
OF oDlgSX5 PIXEL

oLstSX5:SetArray(aDadosSX5)
oLstSX5:nAt := nList
oLstSX5:bLine := { || {aDadosSX5[oLstSX5:nAt,1], aDadosSX5[oLstSX5:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION F666DESCX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ENABLE OF oDlgSX5
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgSX5:End() ENABLE OF oDlgSX5

Activate MSDialog oDlgSX5 Centered

Return _bRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} F666DESCX5
Retorna a Descrição dos itens da tabela SX5

@author Antonio Florêncio Domingos Filho
@since 05/06/2015
@version 12.1.6
/*/
Static Function F666DESCX5(_nPos, aDadosSX5, _bRet)

cRetLocal  := aDadosSX5[_nPos,1]
cRetDescri := aDadosSX5[_nPos,2]

_bRet := .T.

oDlgSX5:End()

Return _bRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F666RLOCAL
Retorno da Consulta Especifica de Locais FW3LOC - SX5³
Retorna o codigo Estado ou do Pais
@author Antonio Florêncio Domingos Filho
@since 05/06/2015
@version 12.1.6
/*/
FUNCTION F666RLOCAL()
	 	
RETURN cRetLocal

//-------------------------------------------------------------------
/*/{Protheus.doc} F666RDESCR
Retorno da Consulta Especifica de Locais FW3LOC - SX5³
Retorna a Descrição do Estado ou do Pais
@author Antonio Florêncio Domingos Filho
@since 05/06/2015
@version 12.1.6
/*/
FUNCTION F666RDESCR()
	 	
RETURN cRetDescri


/*/{Protheus.doc} F666VALADT
Calcula o Valor do Adiantamento

@author Antonio Domingos

@since 12/06/2015
@version 1.0
/*/
Function F666VALADT()
Local aArea			:= GetArea()
Local oModel		:= FWModelActive()
Local oModelADT		:= oModel:GetModel("ADTDETAIL")
Local oModelFW3		:= oModel:GetModel("FW3MASTER")
Local dDataIni		:= oModelFW3:GetValue("FW3_DTINI")
Local dDataFim      := oModelFW3:GetValue("FW3_DTFIM")
Local cNacion		:= oModelFW3:GetValue("FW3_NACION")
Local lAdiant 		:= oModelADT:GetValue("FW5_ADIANT")
Local nValAdiant    := 0
Local nValorFixo 	:= GetMv("MV_RESADFX")
Local nValorDia  	:= GetMV("MV_RESADDI")
Local nResultado    := GetMV("MV_RESADSP")
Local lPernoite     := IIf( (dDataFim - dDataIni) > 0, .T. , .F. )
//
If lAdiant
	If !( Empty( oModelADT:GetValue("FW5_PARTIC") ) ) 
		If lPernoite .And. cNacion == '1'
		
			nValAdiant := nValorFixo + ( nValorDia * (dDataFim - dDataIni) )

		ElseIf(!lPernoite .And.  cNacion == '1')
			
			nValAdiant := nResultado
		
		Else

			nValAdiant := nValorFixo

		EndIf
	Else
		oModelADT:LoadValue("FW5_ADIANT", .F.)
	EndIf
Else
	nValAdiant := 0
EndIf
//
RestArea(aArea)

Return nValAdiant
/*/{Protheus.doc} F666FW5POS
Validação para haver pelo menos 1 Participante.

@author Antonio Florêncio Domingos Filho

@since 12/06/2015
@version 1.0
/*/

//-------------------------------------------------------------------
Static Function F666FW5POS( oModel )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaFW5   := FW5->( GetArea() )
Local oView      := FwViewActive()
Local nI         := 0
Local lAchou     := .F.
Local aSaveLines := FWSaveRows()

	For nI := 1 To  oModel:Length()
		
		oModel:GoLine( nI )
		
		If !oModel:IsDeleted()
			If  !Empty(oModel:GetValue( 'FW5_PARTIC' )) 
				lAchou := .T.
				Exit
			EndIf
		EndIf
		
	Next nI
	
	If !lAchou
		Help( ,, "VLDQPARTIC",,OemToANSI(STR0024), 1, 0 ) // 'Deve haver pelo menos 1 Participante!'
		lRet := .F.
	EndIf
		

FWRestRows( aSaveLines )

RestArea( aAreaFW5 )
RestArea( aArea )

Return lRet

/*/{Protheus.doc} F666FW6POS
Validação da soma dos porcentuais de rateio por Centro de Custo

@author Antonio Florêncio Domingos Filho

@since 12/06/2015
@version 1.0
/*/

//-------------------------------------------------------------------
Static Function F666FW6POS( oModel )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaFW6   := FW6->( GetArea() )
Local nI         := 0
Local lAchou     := .F.
Local aSaveLines := FWSaveRows()

FW6->( dbSetOrder( 1 ) )

	nSomaPorcen := 0
		
	For nI := 1 To  oModel:Length()
		
		oModel:GoLine( nI )

		If !oModel:IsDeleted()
			nSomaPorcen += oModel:GetValue( 'FW6_PORCEN' )
		EndIf
					
	Next nI
			
	If (nSomaPorcen / 100) > 1
		Help( ,, "VLDSUMPORC",,OemToANSI(STR0034), 1, 0 ) // 'A soma das porcentagens informadas no rateio de centro de custo não pode ser maior do que 100%!'
		lRet := .F.
	EndIf
		

FWRestRows( aSaveLines )

RestArea( aAreaFW6 )
RestArea( aArea )

Return lRet

/*/{Protheus.doc} F666TUDOOK
Validação geral do modelo

@author Antonio Florêncio Domingos Filho

@since 12/06/2015
@version 1.0
/*/
Function F666TUDOOK()

Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelFW3	:= oModel:GetModel("FW3MASTER")
Local oModelFW4	:= oModel:GetModel("FW4DETAIL")
Local oModelFW5	:= oModel:GetModel("FW5DETAIL")
Local oModelFW6	:= oModel:GetModel("FW6DETAIL")
Local oModelADT	:= oModel:GetModel("ADTDETAIL")
Local nOperation	:= oModel:GetOperation()
Local cStatus 	:= oModelFW3:GetValue("FW3_STATUS")
Local nI        	:= 0
Local lAchou    	:= .F.
Local nSumPorc  	:= 0
Local nValAdt	  	:= 0
Local aSaveLines:= FWSaveRows()
Local lInter	  := oModelFW3:GetValue('FW3_NACION') == '2'		


If cStatus == '0' //Em aberto

	nSumPorc := 0
	//
	For nI := 1 To  oModelFW6:Length()
			
		oModelFW6:GoLine( nI )
	
		If !oModelFW6:IsDeleted()
			nSumPorc += oModelFW6:GetValue( 'FW6_PORCEN' )
		EndIf
			
	Next nI
				
	If (nSumPorc / 100) <> 1
		Help( ,, "VLDSUMPORC",,OemToANSI(STR0025), 1, 0 ) // 'A soma das porcentagens informadas no rateio de centro de custo não pode ser diferente de 100%!'
		lRet := .F.
	EndIf
	
	//Verifica se participante tem aprovador cadastrado
	If !F666VPARTI()
	   lRet := .F.
	EndIf

EndIf	
//Validação de viagens internacionais.
If lInter
	lRet := FA666Inter(oModelFW3:GetValue("FW3_CODORI"),oModelFW3:GetValue("FW3_CODDES"))
	If(!lRet)
		Help( ,, "VIAGINTER",,STR0110 ,1,0)	
	EndIf
EndIf

//Recalcula os valores do adiantamento.
If nOperation != MODEL_OPERATION_DELETE 
	nValAdt := F666VALADT()
	For nI := 1 To oModelADT:Length() 
		If !oModelADT:IsDeleted(nI) .AND. oModelADT:GetValue('FW5_ADIANT',nI) 
			oModelADT:GoLine(nI)
			oModelADT:SetValue('FW5_VALOR', nValAdt) 
		EndIf
	Next nI
EndIf	
//
FWRestRows( aSaveLines )

Return lRet

/*/{Protheus.doc} FA666Inter
Validação para viagens internacionais. 
@author William Gundim
@since  21/12/15
/*/
Function FA666Inter(cOrigem, cDestino)
Local lRet 	:= .T.
Local aArea	:= GetArea()

	DbSelectArea('SX5')
	lRet := SX5->(dbSeek( xFilial('SX5') + 'BH' + AllTrim(cOrigem)  )) .OR.;
			 SX5->(dbSeek( xFilial('SX5') + 'BH' + AllTrim(cDestino) ))	
	
	
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} F666GRVMD
Função de gravação do modelo

@author Antonio Flotêncio Domingos Filho

@since 13/06/2015
@version 1.0
/*/
Function F666GRVMD(oModel)
Local oModelFW3	:= oModel:GetModel("FW3MASTER")
Local oModelFW4	:= oModel:GetModel("FW4DETAIL")
Local oModelFW5	:= oModel:GetModel("FW5DETAIL")
Local oModelADT	:= oModel:GetModel("ADTDETAIL")
Local cStatus 	:= oModelFW3:GetValue('FW3_STATUS')
Local nOperation := oModel:GetOperation()
Local cPart		:= oModelFW3:GetValue('FW3_USER')
Local lRet 		:= .T.
Local aAprv 	:= FResAprov("3")//"3" = Solicitação de Viagem
Local nX		:= 0
Local nY		:= 0
Local nTipo6	:= 0
Local nLenFW4   := oModelFW4:Length()
Local nLenADT   := 0

// PCREQ-3829 Aprovação Automática	
// aAprv[1] - Após a solicitação da viagem (.T. or .F.)
// aAprv[2] - Após a conferência da solicitação (.T. or .F.)
If nOperation <> MODEL_OPERATION_DELETE .And. cStatus == '0' //Em Aberto.
	//Atualiza entidade FW5 para os participantes com adiantamentos.
	If nLenFW4 > 0 .And. (nLenADT := oModelADT:Length()) > 0				
		For nX := 1 To nLenFW4
			oModelFW4:SetLine(nX)
			
			For nY := 1 To nLenADT
				oModelADT:GoLine(nY) // Posiciono na linha para garantir que pegará as informações da linha correta
				
				If oModelFW5:SeekLine( {{'FW5_PARTIC', oModelADT:GetValue('FW5_PARTIC', nY) }} )
					oModelFW5:SetValue('FW5_ADIANT',   oModelADT:GetValue('FW5_ADIANT', nY) )
					oModelFW5:SetValue('FW5_VALOR',    oModelADT:GetValue('FW5_VALOR', nY) )
				EndIf					
			Next nY
		Next nX
	EndIf
	
	If aAprv[1]
		If (lAutomato .and. lRetAuto) .or. MsgYesNo(STR0061)	//- AUTOMACAO	
			oModelFW3:SetValue("FW3_STATUS",'3') //Aguardando aprovação do gestor ou substituto.    
		EndIf	
	Else //Após conferência
		oModelFW3:SetValue("FW3_STATUS",'5') //Aprovada.	
	Endif
EndIf

FWFormCommit( oModel )

//Verifica tipo de servico "Outros"
For nX := 1 To nLenFW4
	oModelFW4:GoLine(nX)	
	
	If oModelFW4:GetValue("FW4_TIPO") == "6"
		nTipo6++
	EndIf	
Next nX

//Adicionado para gerar a Viagem após a aprovação da Solicitação, caso seja a vontade do usuario.
If __nOper == APROV_SOLIC .AND. nOperation <> MODEL_OPERATION_DELETE .AND. oModelFW3:GetValue("FW3_STATUS") == "5" .AND. aAprv[1]
	If nLenFW4 == nTipo6
		MsgRun( STR0088,, {|| F666ENVCON(oModel) } )
	Else
		If (lAutomato .and. lRetAuto) .or. MsgNoYes(STR0113, STR0114) // "Deseja encaminhar esta Solicitação de Viagem para Conferência do Departamento de Viagens?" "ATENÇÃO!"
			MsgRun( STR0088,, {|| F666ENVCON(oModel) } )
		EndIf
	EndIf
ElseIf ( __nOper != APROV_SOLIC .OR. __nOper != ENC_APROV .OR. __nOper != OPER_ENVWF) .AND.; 
		( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND.; 
		oModelFW3:GetValue("FW3_STATUS") == "5" .AND. aAprv[1] //APROV_SOLIC 7 ENC_APROV 8 OPER_ENVWF 9
	If nLenFW4 == nTipo6
		MsgRun( STR0088,, {|| F666ENVCON(oModel) } )
	Else
		If (lAutomato .and. lRetAuto) .or. MsgNoYes(STR0113, STR0114) // "Deseja encaminhar esta Solicitação de Viagem para Conferência do Departamento de Viagens?" "ATENÇÃO!"
			MsgRun( STR0088,, {|| F666ENVCON(oModel) } )
		EndIf
	EndIf
EndIf

If __nOper != APROV_SOLIC .And. FW3->FW3_STATUS == '3' .And. __lMTFLUIGATV
	If MTFluigAtv("WFFINA666", "SOLVIAJ1", "WFFIN666")
		FI666WF(FW3->FW3_FILIAL,FW3->FW3_SOLICI,cPart)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} F666VLMod(oModel)
Função de Validação da Alteração e Exclusão da Model

@author Antonio Flotêncio Domingos Filho

@since 18/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F666VLMod(oModel)
Local oAuxFW5	   := oModel:GetModel("FW5DETAIL") 
Local nOperation := oModel:GetOperation()
Local lRet			:= .T.

//Alteração
If nOperation == MODEL_OPERATION_UPDATE
	If  FW3->FW3_STATUS == '3' .and. !__nOper == APROV_SOLIC 
		Help(" ",1,"F666VLDALT",,STR0031 ,1,0)	//'Não é possivel alterar solicitação de viagem com esse status.'
		lRet := .F.
	EndIf
	
	If FW3->FW3_STATUS == '1'
		Help(" ",1,"F666VLDCONF",,STR0085,1,0) //"Não é possivel alterar solicitações que já foram encaminhadas para conferência."
		lRet := .F.		
	EndIf
	
	If  FW3->FW3_STATUS $ '245' 
		Help(" ",1,"F666VLDALT",,STR0031 ,1,0)	//'Não é possivel alterar solicitação de viagem com esse status.'
		lRet := .F.
	EndIf
	
EndIf

//Exclusão
If  FW3->FW3_STATUS != '0' .and. (nOperation == MODEL_OPERATION_DELETE ) 
	Help(" ",1,"F666VLDEXC",,STR0035 ,1,0)		//'Não é possivel Excluir a solicitação de viagem com esse status.'
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} F666ENVCON
Rotina para encaminhar solicitação para conferencia

@author Antonio Flotêncio Domingos Filho

@since 13/06/2015
@version 1.0
/*/
Function F666ENVCON(oModelORI)
Local oModelFW3	:= Nil
Local oModelFW4	:= Nil
Local oModelFW5	:= Nil
Local oModelFW6	:= Nil
Local oModelADT	:= Nil
Local oModelFL5	:= Nil
Local oModelFL6	:= Nil
Local oModelFLD := Nil
Local oModelFL7 := Nil
Local oModelFLH := Nil
Local oModelFL9 := Nil
Local oModelFL8 := Nil
Local oModelFLB := Nil
Local oModelFLJ := Nil
Local oModelFLA := Nil
Local oModelFLC := Nil
Local oModelFLU := Nil
Local oModelFW7 := Nil
Local cItem		:= ""
Local cLog		:= ""
Local nX		:= 0
Local nY		:= 0
Local aAprvSV	:= FResAprov("3")//"3" = Solicitação de Viagem
Local aSaveLines:= {}
Local oModel665 := Nil
Local nTipo6	:= 0
Local cFL5NOME  := ""
Local nLenFW4   := 0
Local nLenFW5   := 0
Local nLenFW6   := 0
Local nLenADT   := 0
Local cFW4_TIPO := ""
Local cFW3_STAT := ""
Local lErro     := .F.
Local lFinSolic := .F.

If oModelORI:GetValue("FW3MASTER","FW3_STATUS") != '5'
	Help(" ",1,"F666SOLALT",,STR0032 ,1,0) // 'Não é possivel encaminhar a solicitação de viagem para a conferência com esse status.'
Else
	oModelFW3 := oModelORI:GetModel("FW3MASTER")
	oModelFW4 := oModelORI:GetModel("FW4DETAIL")
	oModelFW5 := oModelORI:GetModel("FW5DETAIL")
	oModelFW6 := oModelORI:GetModel("FW6DETAIL")
	oModelADT := oModelORI:GetModel("FW5DETAIL")
	
	//Varrer a FW4 pois pode existir duas linhas com o tipo igual a 6
	If (nLenFW4 := oModelFW4:Length()) > 0
		For nX := 1 To nLenFW4
			oModelFW4:GoLine(nX)
			
			If oModelFW4:GetValue("FW4_TIPO") == "6"
				nTipo6++
			EndIf		
		Next nX
	EndIf
	
	//Carrega model de Viagens
	oModel665:= FWLoadModel("FINA665")
	oModel665:SetOperation( MODEL_OPERATION_INSERT )
	oModel665:Activate()
		
	oModelFL6 := oModel665:GetModel('FL6DETAIL')	
	oModelFL5 := oModel665:GetModel('FL5MASTER')
	
	oModelFL5:SetValue('FL5_FILIAL',xFilial("FL5"))
	oModelFL5:SetValue('FL5_CODORI',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
	oModelFL5:SetValue('FL5_DESORI',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
	oModelFL5:SetValue('FL5_CODDES',oModelFW3:GetValue("FW3_CODDES")) //Código do Estado/Páis de destino
	oModelFL5:SetValue('FL5_DESDES',oModelFW3:GetValue("FW3_DESDES")) //Descrição do local de destino
	oModelFL5:SetValue('FL5_DTINI' ,oModelFW3:GetValue("FW3_DTINI")) //Data inicial da solicitação
	oModelFL5:SetValue('FL5_DTFIM' ,oModelFW3:GetValue("FW3_DTFIM")) //Data final da solicitação
	oModelFL5:SetValue('FL5_NACION',oModelFW3:GetValue("FW3_NACION"))//Solicitação é nacional (1= Sim, 2 = Não).
	oModelFL5:SetValue('FL5_CLIENT',oModelFW3:GetValue("FW3_CLIENT"))//Código do cliente
	oModelFL5:SetValue('FL5_LOJA'  ,oModelFW3:GetValue("FW3_LOJA")) //Loja do cliente
	oModelFL5:SetValue('FL5_IDSOL' ,oModelFW3:GetValue("FW3_SOLICI"))//Código da solicitação de viagens.
	oModelFL5:SetValue('FL5_NACION',oModelFW3:GetValue("FW3_NACION"))//Nacional 1-Sim,2-Não
	
	If nLenFW4 == nTipo6
		oModelFL5:SetValue('FL5_STATUS','5')//Aguardando Aprovação.
	Else
		oModelFL5:SetValue('FL5_STATUS','6')//Solicitada.
	EndIf
	
	cFL5NOME := PadR(Posicione("SA1", 1, xFilial("SA1") + oModelFW3:GetValue("FW3_CLIENT") + oModelFW3:GetValue("FW3_LOJA"), "A1_NOME"), TamSx3('FL5_NOME')[1])
	
	oModelFL5:SetValue('FL5_OBS','')
	oModelFL5:SetValue('FL5_NOME', cFL5NOME)
	oModelFL5:SetValue('FL5_VALCOB',0)
	oModelFL5:SetValue('FL5_PEDIDO','')
	oModelFL5:SetValue('FL5_VIAGEM', FXRESNUM( oModelFW3:GetValue("FW3_NACION") ))	
	
	//FL6 – VIAGEM, Deve ser gerado um registro para cada serviço solicitado.
	DbSelectArea('FL6')
	aSaveLines  := FWSaveRows()	
	
	For nY := 1 To nLenFW4
		oModelFW4:SetLine(nY)
		
		If !oModelFL6:IsEmpty()
			oModelFL6:AddLine()
		EndIf	
		
		cItem     := oModelFW4:GetValue("FW4_ITEM")
		cFW4_TIPO := oModelFW4:GetValue("FW4_TIPO")
		oModelFL6 := oModel665:GetModel('FL6DETAIL') // Passageiros.
		
		oModelFL6:SetValue('FL6_ITEM',   cItem) //Data da Criação
		oModelFL6:SetValue('FL6_DTCRIA', dDatabase) //Data da Criação
		oModelFL6:SetValue('FL6_DTEMIS', Date() ) //Data da Criação		
		oModelFL6:SetValue('FL6_TIPO',   cFW4_TIPO) //Tipo do serviço solicitado.
		oModelFL6:SetValue('FL6_STATUS', '0') //0=Não conferido
		oModelFL6:SetValue('FL6_NOMESO', PadR(oModelFW3:GetValue("FW3_PARTIC"),tamSX3('FL6_NOMESO')[1]))		
		
		//1 = Passagem Aérea - Essa entidade só deve ser preenchida quando for solicitada uma passagem aérea.
		If cFW4_TIPO == "1" 
			//FL7 – Aéreo
			oModelFL7 := oModel665:GetModel( 'FL7DETAIL' )  // Aereo.
			oModelFL7:SetValue('FL7_DSAIDA',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFL7:SetValue('FL7_CODORI',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFL7:SetValue('FL7_ORIGEM',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
			oModelFL7:SetValue('FL7_DCHEGA',oModelFW3:GetValue("FW3_DTFIM")) 	//Data Final da solicitação
			oModelFL7:SetValue('FL7_CODES' ,oModelFW3:GetValue("FW3_CODDES")) 	//Código do Estado/Páis de destino
			oModelFL7:SetValue('FL7_DESTIN',oModelFW3:GetValue("FW3_DESDES")) 	//Descrição do local de destino
		ElseIf cFW4_TIPO == "2" //2 = Hotel - Essa entidade só deve ser preenchida quando for solicitado um hotel  
			//FL9 – Hotel
			oModelFL9 := oModel665:GetModel("FL9DETAIL")
			oModelFL9:SetValue('FL9_DSAIDA',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFL9:SetValue('FL9_CODCID',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFL9:SetValue('FL9_CIDADE',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
			oModelFL9:SetValue('FL9_DCHKIN',oModelFW3:GetValue("FW3_DTINI"))  //Data inicial da solicitação
		ElseIf cFW4_TIPO == "3" //3 = Essa entidade só deve ser preenchida quando for solicitado um veículo. 
			//FLB - Locação Veículo.
			oModelFLB := oModel665:GetModel( 'FLBDETAIL' ) // Locação.
			oModelFLB:SetValue('FLB_DRETIR',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFLB:SetValue('FLB_CODRET',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFLB:SetValue('FLB_CIDRET',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
		ElseIf cFW4_TIPO == "4" //4 = Essa entidade só deve ser preenchida quando for solicitado um seguro para a viagem.   
			//FLA – Seguro
			oModelFLA := oModel665:GetModel( 'FLADETAIL' ) // Seguros.
			oModelFLA:SetValue('FLA_INICIO',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFLA:SetValue('FLA_CODCID',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFLA:SetValue('FLA_CIDADE',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
		ElseIf cFW4_TIPO == "5" //5 = Essa entidade só deve ser preenchida quando for solicitado um transporte rodoviário. 
			//FL8 - Rodoviário.
			oModelFL8 := oModel665:GetModel( 'FL8DETAIL' ) // Rodoviario.
			oModelFL8:SetValue('FL8_DSAIDA',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFL8:SetValue('FL8_CODORI',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFL8:SetValue('FL8_ORIGEM',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
		ElseIf cFW4_TIPO == "6" //6 - Entidade só deve ser preenchida quando for solicitado outro tipo de serviço.
			DbSelectArea('FW7') //FW7 – Outros.
			oModelFW7 := oModel665:GetModel( 'FW7DETAIL' ) // Outros
		  	oModelFW7:SetValue('FW7_DTINIC',oModelFW3:GetValue("FW3_DTINI")) 	//Data inicial da solicitação
			oModelFW7:SetValue('FW7_CODORI',oModelFW3:GetValue("FW3_CODORI")) //Código do Estado/País de origem.
			oModelFW7:SetValue('FW7_DESORI',oModelFW3:GetValue("FW3_DESORI")) //Descrição do local de origem.
			oModelFW7:SetValue('FW7_CODDES',oModelFW3:GetValue("FW3_CODDES")) //Código do Estado/País de origem.
			oModelFW7:SetValue('FW7_DESDES',oModelFW3:GetValue("FW3_DESDES")) //Descrição do local de origem.
		EndIf	
		
		//Participantes de cada pedido.
		If (nLenFW5 := oModelFW5:Length()) > 0
			oModelFLU := oModel665:GetModel('FLUDETAIL') //Passag. por Pedidos.
			
			For nX := 1 To nLenFW5
				If !oModelFLU:IsEmpty()
					oModelFLU:AddLine()
				EndIf
				
				oModelFLU:SetValue("FLU_PARTIC", oModelFW5:GetValue("FW5_PARTIC", nX) )
				oModelFLU:SetValue("FLU_NOME"  , oModelFW5:GetValue("FW5_NOME"  , nX) )
			Next nX
		EndIf
		
		//Centro de Custo do Pedido
		If (nLenFW6 := oModelFW6:Length()) > 0
			oModelFLH := oModel665:GetModel('FLHDETAIL') 
			
			For nX := 1 To oModelFW6:Length()
				If !oModelFW6:IsDeleted()			
					//FLH – centro de Custo
					DbSelectArea('FLH')
					
					If nX > 1
						oModelFLH:AddLine()
					EndIf
					
					oModelFLH:SetValue('FLH_ITEM',oModelFW6:GetValue("FW6_ITEM", nX))
					oModelFLH:SetValue('FLH_CC',oModelFW6:GetValue("FW6_CC", nX)) 	//Centro de Custo
					oModelFLH:SetValue('FLH_PORCEN',oModelFW6:GetValue("FW6_PORCEN", nX)) //Porcentagem
					oModelFLH:SetValue('FLH_ITECTA',oModelFW6:GetValue("FW6_ITECTA", nX))
					oModelFLH:SetValue('FLH_CLVL',oModelFW6:GetValue("FW6_CLVL", nX))				
				EndIf			
			Next nX
		EndIf
		
		//Aprovadores.
		If (nLenFW5 := oModelFW5:Length()) > 0
			oModelFLJ := oModel665:GetModel('FLJDETAIL') //Aprovadores.
			
			For nX := 1 To nLenFW5
				RD0->(dbSeek( xFilial("RD0") + oModelFW5:GetValue("FW5_PARTIC", nX) ) )
				
				If !Empty(RD0->RD0_APROPC) .And. !oModelFLJ:SeekLine({{"FLJ_PARTIC", RD0->RD0_APROPC}})
					If !oModelFLJ:IsEmpty()
						oModelFLJ:AddLine()
					EndIf
					
					oModelFLJ:SetValue("FLJ_PARTIC", RD0->RD0_APROPC )
					oModelFLJ:SetValue("FLJ_NOME"  , GetAdvFVal('RD0','RD0_NOME', xFilial('RD0') + RD0->RD0_APROPC,1,''))
				EndIf					
			Next nX
		EndIf
		
		//Participantes com adiantamento.
		If (nLenADT := oModelADT:Length()) > 0
			oModelFLC := oModel665:GetModel( 'FLCDETAIL' )
			oModelFLD := oModel665:GetModel("FLDDETAIL")
			
			For nX := 1 To nLenADT
				If !oModelFLC:SeekLine({{"FLC_PARTIC", oModelADT:GetValue("FW5_PARTIC", nX)}} )			
					If !oModelFLC:IsEmpty()
						oModelFLC:AddLine()
					EndIf
					
					oModelFLC:SetValue("FLC_FILIAL", oModelFL5:GetValue('FL5_FILIAL') )
					oModelFLC:SetValue("FLC_VIAGEM", oModelFL5:GetValue('FL5_VIAGEM') )
					oModelFLC:SetValue("FLC_PARTIC", oModelADT:GetValue("FW5_PARTIC", nX) )
					oModelFLC:SetValue("FLC_NOME"  , oModelADT:GetValue("FW5_NOME"  , nX) )
					
					If oModelADT:GetValue("FW5_ADIANT", nX)
						If !oModelFLD:IsEmpty()
							oModelFLD:AddLine()
						EndIf
						
						cLog += F667GeraAdian(oModel665)
					EndIf
				EndIf		
			Next nX
		EndIf
	Next nY
	
	FWRestRows(aSaveLines)
	
	If oModel665:VldData() 
		oModel665:CommitData()	
	Else
		lErro := .T.
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel665:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior
		AutoGrLog( STR0062 + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( STR0063 + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( STR0064 + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( STR0065 + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( STR0066 + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( STR0067 + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( STR0068 + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( STR0069 + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( STR0070 + ' [' + AllToChar( aErro[9] ) + ']' )
		MostraErro()
	EndIf
	
	If !lErro
		oModelFW4:GoLine(1)
		nLenFW4   := oModelFW4:Length()		
		lFinSolic := (nLenFW4 != nTipo6 .And. aAprvSV[1] .And. !aAprvSV[2])
		
		If (lFinSolic .Or. nLenFW4 == nTipo6)
			If (lFinSolic .Or. !aAprvSV[1] .Or. __nOper == APROV_SOLIC .Or. __nOper == 0)
				cFW3_STAT := '4' //Finalizada.
			EndIf
		Else
			cFW3_STAT := '1' //Conferencia.
		EndIf
		
		//Atualiza o status da solicitação.
		If !Empty(cFW3_STAT) .And. cFW3_STAT != FW3->FW3_STATUS
			Reclock("FW3")								
			FW3->FW3_STATUS := cFW3_STAT 
			FW3->(MsUnlock())
		EndIf
	EndIf
	
	oModel665:DeActivate()
	oModel665:Destroy()	
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F666DUser(cCodUser)

Retorna nome e mail de usuario

@param oModel Objeto com os dados necessarios.

@author Antonio Florêncio Domingos Filho
@since  17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F666DUser(cCodUser,nRegistro,nOrdem)


Local _cRet := " "
/*
Vetor com configurações dos usuários
 
Registro   Elemento                          Tipo     Tamanho
     1     ID                                C     6
     2     Nome                              C     15
     3     Senha                             C     6
     4     Nome completo                     C     30
     5     Vetor com "n" últimas senhas      A     
     6     Data de validade                  D     8
     7     Quantas vezes para expirar        N     4
     8     Autorizado a alterar a senha      L     1
     9     Alterar senha no próximo logon    L     1
     10    Vetor com os grupos               A     
     11    ID do superior                    C     6
     12    Departamento                      C     30
     13    Cargo                             C     30
     14    E-mail                            C     30
     15    Número de acessos simultâneos     N     4
     16    Data da última alteração          D     8
     17    Usuário bloqueado                 L     1
     18    Número de digitos para o ano      N     1
     
	_NomeUser := substr(cUsuario,7,15)

*/ 

 
// Defino a ordem
PswOrder(nOrdem) //1 ID; 2 Nome
     
// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo
If PswSeek(cCodUser,.T.)
 
   // Obtenho o resultado conforme vetor
   _aRetUser := PswRet(1)
 
   _cRet     := upper(alltrim(_aRetUser[1,nRegistro]))
        
EndIf

Return(_cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F666FCBOX()
Retorna ComboBox dos Tipos de Serviços que podem ser solicitados na Viagem Avulsa
Campo FW_TIPO

@param Função F666FCBOX() como X3_CBOX

@author Antonio Florêncio Domingos Filho
@since  17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F666FCBOX()

Local cRetcBOX    := " "
Local cMV_RESSLAV := GETMV("MV_RESSLAV")
Local aGetArea    := GetArea()
Local aSx3Box     := {"1=" + STR0071 ,"2=" + STR0072 ,"3=" + STR0073 ,"4=" + STR0074,"5=" + STR0075,"6=" + STR0076}
Local nX          := 1

For nX := 1 to Len(cMV_RESSLAV)

	If Substr(cMV_RESSLAV,nX,1) == "1"
	
		If nX == 1
		
			cRetcBox += aSx3Box[nX]
	
		Else

			cRetcBox += ";"+aSx3Box[nX]
		
		EndIf
	
	EndIf

Next

RestArea(aGetArea)

Return cRetcBox


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA666NEW
Obtem o próximo item para o participante de uma determinada viagem
@author Antonio Florêncio Domingos Filho
@since 19/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------                                                                                                                            
Function FINA666NEW(cViagem, cPartic)

Local aArea		:= GetArea()
Local cNewItem	:= STRZERO(0,TamSx3("FLD_ADIANT")[1])

Default cViagem	:= ""
Default cPartic	:= ""

If !Empty(cViagem) .and. !Empty(cPartic)

	cQry := " SELECT " 
	cQry += " MAX(FLD_ADIANT) ADIANT " 
	cQry += " FROM "+RetSQlName("FLD")+ " FLD " 
	cQry += " WHERE FLD_FILIAL = '"+xFilial("FLD")+"'" 		
	cQry += " AND FLD_VIAGEM = '"+cViagem+"'"
	cQry += " AND FLD_PARTIC = '"+cPartic+"'"
	cQry += " AND FLD.D_E_L_E_T_ <> '*' "	
	
	cQry := ChangeQuery(cQry) 
	
	If Select("FLDADIANT") > 0
		FLDADIANT->(DbCloseArea())
	Endif
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "FLDADIANT", .T., .F.)	
	If Empty(FLDADIANT->ADIANT)
		cNewItem := Soma1(Alltrim(cNewItem))
	Else
		cNewItem := Soma1(Alltrim(FLDADIANT->ADIANT))
	EndIf
	FLDADIANT->(DbCloseArea())

EndIf            

RestArea(aArea)

Return cNewItem

//-------------------------------------------------------------------
/*/{Protheus.doc} F666MsgMail
Estorno de liberação (Gestor) de adiantamento

@param nOpcao 	1= Gestor (Liberar solicitacao de adiantamento
				2= Paricipante (solicitacao de adiantamento negado - Gestor )
				3= Paricipante (adiantamento negado - Depto Viagens)
				4= Paricipante (pagamento de adiantamento aprovado)


@author Antonio Florêncio Domingos Filho
@since 19/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------

Function F666MsgMail(nOpcao,cMoeda,nValor,cCodAprv,cViagem,cItViagem,cPartic)

Local nLayout		:= 1		//1=Adiantamento,2=Prestação de Contas
Local nInteressado	:= 1		//1=Participante, 2=Departamento de Viagem,  3=Aprovador
Local cMensagem		:= ""  		//Mensagem a ser enviada
Local cAssunto		:= ""		//Assunto do e-mail
Local cNomeGestor	:= ""
Local lEnviaEmail	:= (SuperGetMV("MV_RESAVIS",,"") == "1")	//Para enviar email, parâmetro MV_RESAVIS == "1"
Local cTo           := F666DUser(cCodAprv,14,1) //alltrim(RD0->RD0_EMAIL)
Local cLicenc		:= ""
Local cPedido		:= ""
Local cMensRESE		:= ""
local cNomePart		:= ""
Local cEntidade     := "FL5"
LOcal cProcesso     := STR0077
Local cRegistro     := " "
DEFAULT nOpcao	  	:= 0
DEFAULT cMoeda	  	:= "1"
DEFAULT nValor	  	:= 0
DEFAULT cCodAprv  	:= ""
DEFAULT cPedido	  	:= ""
DEFAULT cItViagem 	:= "01"
DEFAULT cPartic		:= ""



//Obtenho o codigo RESERVE
FL6->(dbSetOrder(1))
If (FL6->(MsSeek(xFilial("FL6")+cViagem+cItViagem)))
	cPedido := FL6->FL6_IDRESE
	cLicenc := FL6->FL6_LICENC
Endif

If nOpcao == 1	//Aviso ao Gestor sobre solicitacao de adiantamento

	nLayOut		:= 3		//1=Participante, 2=Departamento de Viagem,  3=Aprovador

	cAssunto	:= STR0038		//"Liberação de solicitação de adiantamento de viagem"
	cMensagem	:= STR0039 		//"Existe uma aprovação pendente referente a solicitação de adiantamento de viagem."
	cMensRESE	:= STR0040		//"Adiantamento #1[Codigo]# gerado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 2	//Aviso ao participante sobre pagamento negado (Gestor)

	cNomeGestor := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0")+ cCodAprv ,1,"")+". "

	cAssunto	:= STR0041		//"Solicitação de adiantamento de viagem"
	cMensagem	:= STR0042 		//"Foi rejeitada a solicitação de adiantamento referente a viagem "
	cMensagem 	+= STR0043 + cNomeGestor  + STR0044	//"pelo Sr./Sra. "###"Por favor, entre em contato com o mesmo/mesma para maiores esclarecimentos."
	cMensRESE	:= STR0045		//"Adiantamento #1[Codigo]# negado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 3	//Aviso ao participante sobre pagamento negado (Depto Viagens)

	cAssunto	:= STR0046 		//"Adiantamento de viagem - Pagamento"
	cMensagem	:= STR0047 		//"O pagamento de adiantamento referente a viagem foi rejeitado "
	cMensagem 	+= STR0048		//"pelo Departamento de Viagens. Por favor, entre em contato com o mesmo para maiores esclarecimentos."
	cMensRESE	:= STR0049		//"Adiantamento #1[Codigo]# negado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 4	//Aviso ao participante sobre pagamento liberado

	cAssunto	:= STR0050	//"Liberação para pagamento - Adiantamento de viagem"
	cMensagem	:= STR0051 	//"Foi aprovado o pagamento de adiantamento referente a viagem. "
	cMensRESE	:= STR0052	//"Adiantamento #1[Codigo]# liberado para pagamento para o passageiro #2[Participante]# em #3[Data]# as #4[Hora]#"
Endif

If lEnviaEmail
	//Manda o email
	FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
	//FNXRESMONTAEMAIL(nLayOut , nInteressado, cMensagem, cAssunto)
Endif

//Manda mensagem para Reserve
If !Empty(cPedido)

	//-------------------------------------------
	// Atualiza o historico do pedido no Reserve
	//-------------------------------------------
	cNomePart	:= Alltrim(GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cPartic,1,""))
	cHistorico	:= I18N(cMensRESE,{cViagem,cPartic+" - "+cNomePart,DToC(dDataBase),Time()})
	FN661Hist(cLicenc,cPedido,cHistorico)

Endif

Return

/*/{Protheus.doc} F666ENVSOL
Função de envio da solicitação posicionada no browse

@author Antonio Flotêncio Domingos Filho

@since 13/06/2015
@version 1.0
/*/
Function F666ENVSOL()
Local oModel	:= Nil

//Encaminha solicitação de viagem para conferencia do departamento de viagens.
If  FW3->FW3_STATUS == '5' 
	oModel := FWLoadModel('FINA666')
	oModel:SetOperation( MODEL_OPERATION_VIEW )
	oModel:Activate()
	MsgRun( STR0088,, {|| F666ENVCON(oModel) } ) 
Else
	Help(" ",1,"F666VLDALT",,STR0058,1,0)	
EndIf

Return 

/*/{Protheus.doc} F666ODesc
Função de Busca descrição do Local de Destino

@author Antonio Flotêncio Domingos Filho

@since 10/07/2015
@version 1.0
/*/
Function FN666ODesc()
Local oModel	:= FWModelActive()
Local cDesc  := ""

If !Empty(oModel:GetValue("FW3MASTER","FW3_CODORI"))
	If oModel:GetValue("FW3MASTER","FW3_NACION") == '1' //Nacional
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODORI")),"X5_DESCRI")
	Else
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODORI")),"X5_DESCRI")
		If Empty(cDesc)
			cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODORI")),"X5_DESCRI")
		EndIf
	EndIf
EndIf

Return ALLTRIM(cDesc)

/*/{Protheus.doc} F666DDesc
Função de Busca descrição do Local de Destino

@author Antonio Flotêncio Domingos Filho

@since 10/07/2015
@version 1.0
/*/
Function FN666DDesc()
Local oModel := FWModelActive()
Local cDesc  := ""

If !Empty(oModel:GetValue("FW3MASTER","FW3_CODDES"))
	If oModel:GetValue("FW3MASTER","FW3_NACION") == '1' //Nacional
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODDES")),"X5_DESCRI")
	Else
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODDES")),"X5_DESCRI")
		If Empty(cDesc)
			cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(oModel:GetValue("FW3MASTER","FW3_CODDES")),"X5_DESCRI")
		EndIf
	EndIf
EndIf

Return ALLTRIM(cDesc)


/*/{Protheus.doc} FN666OBrow()
Função de Busca descrição do Local de Origem  no Browse

@author Antonio Flotêncio Domingos Filho

@since 10/07/2015
@version 1.0
/*/
Function FN666OBrow()
Local cDesc  := ""

If FW3->FW3_NACION == '1' //Nacional
	cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(FW3->FW3_CODORI),"X5_DESCRI")
Else
	cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(FW3->FW3_CODORI),"X5_DESCRI")
	If Empty(cDesc)
		cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(FW3->FW3_CODORI),"X5_DESCRI")
	EndIf
EndIf

Return ALLTRIM(cDesc)

/*/{Protheus.doc} FN666DBrow()
Função de Busca descrição do Local de Destino no Browse

@author Antonio Flotêncio Domingos Filho

@since 10/07/2015
@version 1.0
/*/
Function FN666DBrow()
Local cDesc  := ""

If FW3->FW3_NACION == '1' //Nacional
	cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(FW3->FW3_CODDES),"X5_DESCRI")
Else
	cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(FW3->FW3_CODDES),"X5_DESCRI")
	If Empty(cDesc)
		cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(FW3->FW3_CODDES),"X5_DESCRI")
	EndIf
EndIf

Return ALLTRIM(cDesc)

/*/{Protheus.doc} FN666VlCpo()
Valida o código informado pelo usuário para origem/destino.
@author William Matos
@since 10/07/2015
@version 1.0
/*/
Function FN666VlCpo(cType)
Local oModel	:= FWModelActive() 
Local cValor	:= IIf(cType == '1', oModel:GetValue("FW3MASTER","FW3_CODORI"), oModel:GetValue("FW3MASTER","FW3_CODDES") ) 
Local lRet		:= .T.

If oModel:GetValue("FW3MASTER","FW3_NACION") == '1' //Nacional
	lRet := ExistCPO("SX5", "12" + cValor )
	If(cType == '1')
		If(!lRet .And. !ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODDES") ))

			lRet := .F.

		EndIf
	ElseIf(cType == '2')
		If(!lRet .And. !ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODORI") ))

			lRet := .F.

		EndIf
	EndIf
Else
	lRet :=ExistCPO("SX5", "12" + cValor ) .Or. ExistCPO("SX5", "BH" + cValor )
	If(cType == '1')
		If(ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODORI") ) .And. ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODDES") ))

			lRet := .F.

		EndIf
	ElseIf(cType == '2')
		If(ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODORI"))  .And. ExistCPO("SX5", "12" + oModel:GetValue("FW3MASTER","FW3_CODDES") ))

			lRet := .F.

		EndIf
	EndIf
EndIf	

If !lRet
	Help(/*cRotina*/,/*nLinha*/,"VLDLOCAL",/*cNome*/,OemToANSI(STR0115), 1, 0 ,/*lPop*/,/*hWnd*/,/*nHeight*/,;
		/*nWidth*/,/*lGravaLog*/,{STR0116})//'Local inválido'
EndIf

Return lRet

/*/{Protheus.doc} F666Actv()
Ativação do modelo de dados.
@author William Matos
@since 10/07/2015
@version 1.0
/*/
Function F666Actv( oModel )
Local oModelFW3	:= oModel:GetModel("FW3MASTER")
Local aUser		:= {}

If oModel:GetOperation() <> MODEL_OPERATION_VIEW

	If oModel:GetOperation() == MODEL_OPERATION_INSERT 
	
		If oModelFW3:GetValue("FW3_STATUS") == '0' //Em aberto.
			FINXUser( __cUserId, aUser, .F. )
			If !Empty(aUser)
				oModelFW3:SetValue("FW3_USER"  ,aUser[1] )
				oModelFW3:SetValue("FW3_PARTIC",aUser[2] )
			EndIf
		EndIf
	ElseIf __nOper == ENC_APROV
		oModelFW3:SetValue("FW3_STATUS","3") //Aguardando aprovação.
	EndIf
EndIf

Return 

/*/{Protheus.doc} F666Aprov()
Ativação do modelo de dados.
@author William Matos 
@since 10/07/2015
@version 1.0
/*/
Function F666Aprov()
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,""},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

If FW3->FW3_STATUS == '3' //Aguardando aprovação.
	__nOper := APROV_SOLIC
	__lBTNConfirma := .T.
	FWExecView( STR0060 , "FINA666", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,/**/ , /*nPercReducao*/, aEnableButtons)
Else
	Help(,,"APROVACAO",,OemToANSI( STR0078 + FW3->FW3_SOLICI + STR0079  ), 1, 0 )	
EndIf
__nOper 			:= 0
__lBTNConfirma	:= .F.
Return 

/*/{Protheus.doc} FN666APSol()
Aprovação/Repovação da solciitagem de viagem.
@author William Matos
@param oView: Interface
@param cType: 1 - Aprovar | 2 - Reprovar
@since 21/07/2015
@version 1.0
/*/
Function FN666APSol(oView, cType)
Local oModel := FWModelActive()
Local lRet := .F.

If cType == '1' //Aprovar
	lRet := .T.
	If ValType(oView) == "O" //-- Automação
		lRet := MsgYesNo(STR0080)
	EndIf
	If lRet
		oModel:SetValue("FW3MASTER","FW3_STATUS" , "5" )
		If ValType(oView) == "O" //-- Automação
			oView:ShowUpdateMsg(.T.)
			oView:SetUpdateMessage("",STR0081)
		EndIf
		F6CanFluig()
	EndIf	
Else
	lRet := .T.
	If ValType(oView) == "O" //-- Automação
		lRet := MsgYesNo(STR0083)
	EndIf 
	If lRet
		oModel:SetValue("FW3MASTER","FW3_STATUS" , "2" )
		If ValType(oView) == "O" //-- Automação
			oView:ShowUpdateMsg(.T.)
			oView:SetUpdateMessage("",STR0084)
		EndIf
		F6CanFluig()
	EndIf
EndIf

If lRet .And. ValType(oView) == "O" //-- Automação
	oView:Refresh()
	oView:ButtonOKAction(.T.)
EndIf

Return .F.

/*/{Protheus.doc} F666VldView
Valida se a view pode ser ativa.
@author William Matos
@since 21/07/2015
@version 1.0
/*/
Function F666VldView() 
Local lRet	 := .T.
Local cTMP	 := GetNextAlias()
Local aUser	 := {}
Local cQuery := ""

lRet := FINXUser( __cUserId, aUser )

If lRet .And. __nOper == APROV_SOLIC

	//Ponto de entrada para permitir outra regra de definicao do usuario que pode realizar a aprovacao
	If ExistBlock("F666VldAp")

		lRet := ExecBlock("F666VldAp",.F.,.F.)

	Else

		cQuery := " SELECT FW5_PARTIC"
		cQuery += " FROM " + RetSqlName( "FW5" ) 	  + " FW5" +CRLF
		cQuery += " LEFT JOIN " + RetSqlName( "RD0" ) + " RD0" +CRLF
		cQuery += " ON RD0_CODIGO = FW5_PARTIC"				   +CRLF
		cQuery += " WHERE FW5_SOLICI = '" + FW3->FW3_SOLICI+"'"+CRLF
		cQuery += " AND RD0_APROPC   = '" + aUser[1]	   +"'"+CRLF
		cQuery += " OR  RD0_APSUBS   = '" + aUser[1]	   +"'"+CRLF
		cQuery += " AND  RD0.D_E_L_E_T_  = ' ' "		       +CRLF
		cQuery += " AND  FW5.D_E_L_E_T_  = ' ' "			   +CRLF
		cQuery := ChangeQuery( cQuery )
		DBUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTMP, .F., .T. )

		If Empty((cTMP)->FW5_PARTIC)
			Help(,,"VLDPARTIC",,OemToANSI(STR0082), 1, 0 ) //"Usuário não é aprovador da solicitação."
			lRet := .F.
		EndIf

		If !Empty(cTMP) .And. Select(cTMP) > 0
			(cTMP)->(DBCloseArea())
		EndIf

	EndIf
	
EndIf

Return lRet

/*/{Protheus.doc} F666EnvAp
Encaminha solicitação para aprovação do gestor.
@author William Matos
@since 21/07/2015
@version 1.0
/*/
Function F666EnvAp()
Local aArea			:= GetArea()
Local lRet				:= .T.
Local bOk				:= {||}
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 		:= ""
Local nOperation 		:= MODEL_OPERATION_VIEW
Local aButtons		:= {}
Local bCancel			:= {|| F666ConfVs() }
Local cPart			:= FW3->FW3_USER

If FW3->FW3_STATUS == "0"
	
	cTitulo 			:= STR0086
	cPrograma 			:= 'FINA666'
	nOperation 		:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar		:= .F.
	__nOper     		:= ENC_APROV
	__lBTNConfirma	:= .T.
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Cancelar"},{.T.,"Confirmar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"
	
	If !lAutomato
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	EndIf
	
	If __lConfirmar
		MsgRun( STR0096 ,, {||	lRet := FI666EncAp(FW3->FW3_FILIAL,FW3->FW3_SOLICI,cPart)  } )//"Processando reeenvio..."
	EndIf
	
Else
	Help(,,"F666EnvAp1",,STR0087,1,0)
EndIf

__nOper      		:= 0
__lBTNConfirma	:= .F.
RestArea(aArea)
Return .T.

/*/{Protheus.doc} F6CanFluig

Realiza o cancelamento do processo no Fluig

@author Alvaro Camillo Neto
@since 09/12/2015
@version 1.0
/*/
Static Function F6CanFluig()
Local cWfId		:= FW3->FW3_WFKID
Local cPartic		:= FW3->FW3_USER
Local cCodUsrApv	:= ""
Local cUserFluig	:= ""

//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
If !Empty(cWFID) .AND. !FWIsInCallStack("WFFINA666") 
	DbSelectArea("RD0")
	RD0->(DbSetOrder(1))
	RD0->(DbSeek(xFilial("RD0")+cPartic))
	cCodUsrApv := RD0->RD0_USER
	If cCodUsrApv <> ""
		cUserFluig := FWWFColleagueId(cCodUsrApv)
		CancelProcess(Val(cWfId),cUserFluig,STR0092)//"Excluido pelo sistema Protheus"
	Endif
Endif

Return

/*/{Protheus.doc} F666ENVWF
Executa o modelo FINA666 como alteração para o reenvio do Workflow,
caso o serviço do Fluig esta fora do ar no fluxo padrão da prestação de conta
e não tenho conseguido subir Workflow para o Fluig.   
@author Alvaro Camillo
@since 19/11/2015
/*/
Function F666ENVWF()
Local aArea			:= GetArea()
Local lRet				:= .T.
Local bOk				:= {||}
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 		:= ""
Local nOperation 		:= MODEL_OPERATION_VIEW
Local aButtons		:= {}
Local bCancel			:= {|| F666ConfVs() }
Local cPart			:= FW3->FW3_USER

If __lMTFLUIGATV
	If MTFluigAtv("WFFINA666", "SOLVIAJ1", "WFFIN666")
		If FW3->FW3_STATUS == "3"
			If Empty(FW3->FW3_WFKID)
				cTitulo 			:= STR0095//"Reenvio de WF"
				cPrograma 			:= 'FINA666'
				nOperation 		:= MODEL_OPERATION_VIEW // Visualizar
				__lConfirmar		:= .F.
				__nOper     		:= OPER_ENVWF
				__lBTNConfirma	:= .T.
				
				aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0097},{.T.,STR0098},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"
				
				FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
				
				If __lConfirmar
					MsgRun( STR0096 ,, {||	lRet := FI666WF(FW3->FW3_FILIAL,FW3->FW3_SOLICI,cPart) } )//"Processando reeenvio..."
				EndIf
				
			Else
				Help(,,"F666ENVWF1",,OemToANSI(STR0099 + FW3->FW3_WFKID + STR0100 ), 1, 0 )//"O Workflow "##" já foi enviado."
			EndIf
		Else
			Help(,,"F666ENVWF1",,OemToANSI(STR0101), 1, 0 )//"Status inválido para essa opção"
		EndIf
	Else
		Help(,,"F666ENVWF2",,OemToANSI(STR0102), 1, 0 )//"Opção disponível apenas quando o WF Fluig SOLVIAJ1 estiver ativado."
	EndIf
EndIf
__nOper      		:= 0
__lBTNConfirma	:= .F.
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F666ConfVs
Botão de confirmar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function F666ConfVs()
Local cMensagem := ""
Local lRet		:= .F.

If __nOper == OPER_ENVWF
	cMensagem := STR0103//"Deseja confirmar o reenvio ?"
ElseIf __nOper == ENC_APROV
	cMensagem := STR0104//"Deseja confirmar a operação ?"
EndIf

If lAutomato .Or. MsgYesNo(cMensagem)
	__lConfirmar := .T.
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F666CancVs
Botão de cancelar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function F666CancVs(oView)

oView:ButtonCancelAction()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FI666WF
Botão de cancelar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FI666WF(cFilFW3,cFW3Cod,cPart)
Local lRet := .T.
Local aArea := GetArea()
Local cChvFW3 := "" 
Local cUser:= ""
Local aUsers := {}

RD0->(DbSetOrder(1))
If RD0->(DbSeek( xFilial("RD0") + cPart ))
	cChvFW3 := FW3->( FW3_FILIAL + FW3_SOLICI )
	cUser := RD0->RD0_USER

	Iif(!Empty(RD0->RD0_APROPC), aAdd(aUsers,RD0->RD0_APROPC), )
	Iif(!Empty(RD0->RD0_APSUBS), aAdd(aUsers,RD0->RD0_APSUBS), )

	//Ponto de entrada para adicionar aprovadores conforme criterio do cliente
	If ExistBlock("F666ApFlu",.F.,.F.)
		aUsers := ExecBlock("F666ApFlu",.F.,.F.,{aUsers})
	EndIf

	If ExistBlock("WFFIN666",.F.,.F.)
		ExecBlock("WFFIN666",.F.,.F.,{cChvFW3, cUser, aUsers})
	EndIf

EndIf
		
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} FI666EncAp
Ação de encaminhar para aprovação. 

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FI666EncAp(cFilFW3,cFW3Cod,cPart)
Local lRet:= .T.
Local aArea := GetArea()

FW3->(dbSetOrder(1))
If FW3->(dbSeek(cFilFW3+cFW3Cod))
	RecLock("FW3",.F.)
	FW3->FW3_STATUS := '3'
	MsUnLock()
	If __lMTFLUIGATV
		If MTFluigAtv("WFFINA666", "SOLVIAJ1", "WFFIN666")
			FI666WF(FW3->FW3_FILIAL,FW3->FW3_SOLICI,cPart)
		EndIf
	EndIf
EndIf


RestArea(aArea)
Return lRet

/*/{Protheus.doc} FW5LinPre
Inclui participante no grid de adiantamentos. 
@author William Gundim
@since  21/12/15
/*/
Function FW5LinPre( oFW5, nLine, cAction,cField , xValue, xOldValue )
Local oView 	:= FWViewActive()
Local oModel	:= FWModelActive()
Local oADT		:= oModel:GetModel('ADTDETAIL')

	oADT:SetNoDeleteLine( .F. )	
	oADT:SetNoInsertLine( .F. )	
	
	If cAction == 'DELETE' .AND. nLine <= oADT:Length()

		oADT:SeekLine({{'FW5_PARTIC', oFW5:GetValue('FW5_PARTIC', nLine)}})
		oADT:DeleteLine()

	ElseIf cAction == 'UNDELETE'

		oADT:SeekLine({{'FW5_PARTIC', oFW5:GetValue('FW5_PARTIC', nLine)}}, .T.)
		oADT:UnDeleteLine()
	
	ElseIf cAction = 'SETVALUE' .AND. !oADT:SeekLine({{'FW5_PARTIC', oFW5:GetValue('FW5_PARTIC', nLine)}})
	
		If !Empty(xOldValue) .AND. xOldValue != xValue
			oADT:SeekLine({{'FW5_PARTIC', oFW5:GetValue('FW5_PARTIC', nLine)}})
			oADT:DeleteLine()
		EndIf
		
		If !Empty(oFW5:GetValue('FW5_PARTIC', nLine))
			If !oADT:IsEmpty()
				oADT:AddLine()
			EndIf	
			oADT:SetValue('FW5_PARTIC', oFW5:GetValue('FW5_PARTIC', nLine) ) 					
		EndIf
	
	EndIf

	oADT:SetNoDeleteLine( .T. )	
	oADT:SetNoInsertLine( .T. )	
	oADT:SetLine(1)
	If oView != Nil
		oView:Refresh()
	EndIf

Return .T.

/*/{Protheus.doc} F666Recalc
Recalcula os valores de adiantamento. 
@author William Gundim
@since  21/12/15
/*/
Function F666Recalc(oModel)
Local nI			:= 0
Local nValAdt		:= 0
Local oModelFW3 	:= oModel:GetModel('FW3MASTER')
Local oModelADT	:= oModel:GetModel('ADTDETAIL')  
Local nOper		:= oModel:GetOperation()
Local oView		:= FWViewActive()
 
	//Recalcula os valores do adiantamento.
	If oModelFW3:GetValue('FW3_NACION') == '1' .AND. nOper != MODEL_OPERATION_DELETE 
		nValAdt := F666VALADT()
		For nI := 1 To oModelADT:Length()
			If !oModelADT:IsDeleted(nI) .AND. oModelADT:GetValue('FW5_ADIANT',nI)
				oModelADT:GoLine(nI)
				oModelADT:LoadValue('FW5_VALOR', nValAdt) 
			EndIf
		Next nI
		oModelADT:GoLine(1)
	EndIf
	
	If oView != Nil
		oView:Refresh('VIEW_ADT')
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F666DtPrev
Inicializador de valores da View

@author Rodrigo Pirolo

@since 10/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function F666DtPrev()

Local nTamSol 	:= TamSx3("FLD_NOMESO")[1]
Local nDiasPrev := SuperGetMv("MV_RESADDU",.T.,0)  

Local dDataPrev	:= dDataBase
local nUtiOco	:= SuperGetMV('MV_RESUTCO',.F.,1)//"1" = útil
local nAdUrg	:= SuperGetMV('MV_RESPURG',.F.,3)
local nBaCalc	:= SuperGetMV('MV_RESCALC',.F.,1)//"1" = pedido
Local nX 		:= 0
Local dDataIni	:= Date()
Local dDataAux	:= Date()

If nBaCalc == 1
	dDataIni := dDatabase
Else
	dDataIni := FL5->FL5_DTINI
Endif
 
If dDataIni <= dDataBase .AND. nBaCalc == 1 //Por pedido soma na data inicio
	dDataIni := dDataBase
EndIf

//Processo para permitir informar a quantidade mínima de dias para o vencimento dos adiantamentos de viagens
dDataPrev := dDataAux := dDataIni

//Cálculo
If nUtiOco == 1 //Util
	For nX = 1 To nDiasPrev
		If nBaCalc == 1  //Pedido
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)
		Else //Inicio da Viagem
			dDataAux := (dDataPrev - 1) 
			dDataPrev	:= DataValida(dDataAux,.F.)
		EndIf	
	Next nX
Else //Corrido
	If nBaCalc == 1  //Pedido
		dDataPrev := DataValida(dDataIni + nDiasPrev)
	Else //Inicio da Viagem
		dDataPrev := DataValida(dDataIni - nDiasPrev,.F.)
	EndIf
EndIf

//Verificar se o add é maior que a data base - add urgente
If dDataPrev <= dDatabase
	If nUtiOco == 1 //Util
		dDataPrev := dDatabase
		For nX = 1 To nAdUrg
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)	
		Next nX
	Else //Corrido
		dDataPrev := DataValida(dDataBase + nAdUrg)
	EndIf	
EndIf

Return dDataPrev

//-------------------------------------------------------------------
/*/{Protheus.doc} FN666Oper
Define a operação quando executado pelo Robô de Testes 

@author Automacao - Barbara Reis 
@since  03/06/2016
/*/
//-------------------------------------------------------------------
Function FN666Oper(nOper,lAuto)
Default lAuto	:= .F.
Default nOper	:= 0

__nOper 	:= nOper
lAutomato	:= .T.
lRetAuto 	:= lAuto

Return
