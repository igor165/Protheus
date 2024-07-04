#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSUNISLE.CH'

static cCmpEspMed 	:= 'B5L_CODRDA,B5L_CODSW2,B5L_DESCRI,B5L_SERDIS,B5L_INT410,B5L_AMB410,B5L_HOR410,B5L_SOB410,B5L_HOSESP,B5L_TPNOXM'
static cCmpSerHos 	:= 'B5L_CODRDA,B5L_CODSW2,B5L_DESCRI,B5L_SERDIS,B5L_TPNOXM'
static cCmpSADT 	:= 'B5L_CODRDA,B5L_CODSW2,B5L_DESCRI,B5L_SERDIS,B5L_TPSADT,B5L_NMTER1,B5L_NMTER2,B5L_RGTER1,B5L_RGTER2,B5L_TPNOXM'

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSUNISLE
Tela de Informa��es do PTU A410
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSUNISLE(lAutoma)
local cFiltro   := "@(BAU_FILIAL = '" + xFilial("BAU") + "') "
local oBrowse	:= nil
local lPrtUnim	:= alltrim(getnewpar("MV_PLSUNI","0")) == "1" 
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

if lPrtUnim
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('BAU')
	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetOnlyFields( { 'BAU_FILIAL', 'BAU_CODIGO', 'BAU_NOME', 'BAU_NREDUZ', 'BAU_CPFCGC', 'BAU_NFANTA'} )
	oBrowse:AddLegend("BAU->BAU_CODBLO==Space(03) .Or. BAU->BAU_DATBLO > DDATABASE", "GREEN", STR0018 ) //Autorizado
	oBrowse:AddLegend("BAU->BAU_CODBLO<>Space(03) .AND. BAU->BAU_DATBLO <= DDATABASE", "RED", STR0019 ) //Negado
	oBrowse:SetDescription(STR0001) //Prestador - Informa��o PTU A410
	iif(!lAutoma, oBrowse:Activate(), '')
else
	Help(nil, nil , STR0013, nil, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} ) //"Funcionalidade de uso exclusivo para Operadoras da Rede Unimed"	
endif
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0004	Action 'staticCall(PLSUNISLE, PlsTelNew)' 	Operation 9 Access 0  //Alterar

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB5X	:= FWFormStruct(1,'B5X')
Local oStrB5W	:= FWFormStruct(1,'B5W')
Local oStrB5Y	:= FWFormStruct(1,'B5Y')
Local oStrB5Z   := FWFormStruct(1,'B5Z')
Local oStrB5L   := FWFormStruct(1,'B5L')
Local oStrB5LH  := FWFormStruct(1,'B5L')
Local oStrB5LS  := FWFormStruct(1,'B5L')
local aGatl		:= {}

oModel := MPFormModel():New( 'PLSUNISLE', ,  { || PLSCADOK(oModel) }  ) 
oModel:AddFields( 'B5XMASTER', /*cOwner*/, oStrB5X )
oModel:AddGrid('B5WDetail', 'B5XMASTER', oStrB5W)
oModel:AddGrid('B5YDetail', 'B5XMASTER', oStrB5Y)
oModel:AddGrid('B5ZDetail', 'B5XMASTER', oStrB5Z)
oModel:AddGrid('B5LDetail',  'B5XMASTER', oStrB5L,  ,{||PlTipSrvPTU(oModel, "1", "B5LDetail")})
oModel:AddGrid('B5LHDetail', 'B5XMASTER', oStrB5LH, ,{||PlTipSrvPTU(oModel, "2", "B5LHDetail")})
oModel:AddGrid('B5LSDetail', 'B5XMASTER', oStrB5LS, ,{||PlTipSrvPTU(oModel, "3", "B5LSDetail")})

aGatl := FwStruTrigger('B5L_CODSW2', 'B5L_DESCRI', 'B5V->B5V_DESCRI', .T., 'B5V', 1,'xFilial("B5V") + cValtoChar(M->B5L_CODSW2)','!empty(M->B5L_CODSW2)')                                           
oStrB5L:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )
oStrB5LH:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )
oStrB5LS:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

aGatl := FwStruTrigger('B5L_CODSW2', 'B5L_TPATEN', 'PlRtTpAtIsle()', .T., 'B5V', 1,'xFilial("B5V") + cValtoChar(M->B5L_CODSW2)','!empty(M->B5L_CODSW2)')                                           
oStrB5L:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

aGatl := FwStruTrigger('B5W_CODSW2', 'B5W_DESCRI', 'B5V->B5V_DESCRI', .T., 'B5V', 1,'xFilial("B5V") + cValtoChar(M->B5W_CODSW2)','!empty(M->B5W_CODSW2)')                                           
oStrB5W:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

aGatl := FwStruTrigger('B5Y_CODHME', 'B5Y_DESCRI', 'B5O->B5O_DESCRI', .T., 'B5O', 1,'xFilial("B5O") + M->B5Y_CODHME + "1"','!empty(M->B5Y_CODHME)')                                           
oStrB5Y:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

aGatl := FwStruTrigger('B5Z_CODHMA', 'B5Z_DESCRI', 'B5O->B5O_DESCRI', .T., 'B5O', 1,'xFilial("B5O") + M->B5Z_CODHMA + "2"','!empty(M->B5Z_CODHMA)')                                           
oStrB5Z:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

//Campos Obrigat�rios
oStrB5X:setProperty( "B5X_NIVDIS" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_IDUTI"  , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGDITX" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGMTCS" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGHONM" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGEQUO" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGOPME" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_TPMTES" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGDIET" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGSADT" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_NGMEDI" , MODEL_FIELD_OBRIGAT, .t. )
oStrB5X:setProperty( "B5X_TPACRE" , MODEL_FIELD_OBRIGAT, .t. )

//Valida��es de campos e valores
oStrB5W:setProperty( "B5W_CODSW2" , MODEL_FIELD_VALID, {|| ExistCpo("B5V", alltrim(STR(oModel:getModel("B5WDetail"):getValue("B5W_CODSW2"))), 1)} )
oStrB5L:setProperty( "B5L_CODSW2"  , MODEL_FIELD_VALID, {|| Pl410Flt(alltrim(STR(oModel:getModel("B5LDetail"):getValue("B5L_CODSW2"))),"1")} )
oStrB5LH:setProperty( "B5L_CODSW2" , MODEL_FIELD_VALID, {|| Pl410Flt(alltrim(STR(oModel:getModel("B5LHDetail"):getValue("B5L_CODSW2"))),"2")} )
oStrB5LS:setProperty( "B5L_CODSW2" , MODEL_FIELD_VALID, {|| Pl410Flt(alltrim(STR(oModel:getModel("B5LSDetail"):getValue("B5L_CODSW2"))),"3")} )
oStrB5Y:setProperty( "B5Y_CODHME" , MODEL_FIELD_VALID, {|| ExistCpo("B5O", oModel:getModel("B5YDetail"):getValue("B5Y_CODHME") + "1", 1)} )
oStrB5Z:setProperty( "B5Z_CODHMA" , MODEL_FIELD_VALID, {|| ExistCpo("B5O", oModel:getModel("B5ZDetail"):getValue("B5Z_CODHMA") + "2", 1)} )

//Inicializador de campos obrigat�rios e virtuais
oStrB5X:setProperty( "B5X_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5W:setProperty( "B5W_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5Y:setProperty( "B5Y_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5Z:setProperty( "B5Z_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5L:setProperty( "B5L_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5LH:setProperty( "B5L_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5LS:setProperty( "B5L_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5L:setProperty(  "B5L_TPNOXM" , MODEL_FIELD_INIT, { || "1"} )
oStrB5LH:setProperty( "B5L_TPNOXM" , MODEL_FIELD_INIT, { || "2"} )
oStrB5LS:setProperty( "B5L_TPNOXM" , MODEL_FIELD_INIT, { || "3"} )

oModel:SetRelation( 'B5WDetail', { ;
	{ 'B5W_FILIAL'	, 'xFilial( "B5W" )' },;
	{ 'B5W_CODRDA'	, 'B5X_CODRDA'		 }},;
    B5W->( IndexKey(1) ) )
    
oModel:SetRelation( 'B5YDetail', { ;
	{ 'B5Y_FILIAL'	, 'xFilial( "B5Y" )' },;
	{ 'B5Y_CODRDA'	, 'B5X_CODRDA'		 }},;
    B5Y->( IndexKey(1) ) )    

oModel:SetRelation( 'B5ZDetail', { ;
	{ 'B5Z_FILIAL'	, 'xFilial( "B5Z" )' },;
	{ 'B5Z_CODRDA'	, 'B5X_CODRDA'		 }},;
	B5Z->( IndexKey(1) ) )   

oModel:SetRelation( 'B5LDetail', { ;
	{ 'B5L_FILIAL'	, 'xFilial( "B5L" )' },;
	{ 'B5L_CODRDA'	, 'B5X_CODRDA'		 }},;
	B5L->( IndexKey(1) ) )  	

oModel:SetRelation( 'B5LHDetail', { ;
	{ 'B5L_FILIAL'	, 'xFilial( "B5L" )' },;
	{ 'B5L_CODRDA'	, 'B5X_CODRDA'		 }},;
	B5L->( IndexKey(1) ) )

oModel:SetRelation( 'B5LSDetail', { ;
	{ 'B5L_FILIAL'	, 'xFilial( "B5L" )' },;
	{ 'B5L_CODRDA'	, 'B5X_CODRDA'		 }},;
	B5L->( IndexKey(1) ) )	
	
oModel:GetModel( 'B5WDetail' ):SetUniqueLine( { 'B5W_CODRDA', 'B5W_CODSW2' } )
oModel:GetModel( 'B5YDetail' ):SetUniqueLine( { 'B5Y_CODRDA', 'B5Y_CODHME' } )
oModel:GetModel( 'B5ZDetail' ):SetUniqueLine( { 'B5Z_CODRDA', 'B5Z_CODHMA'} )
oModel:GetModel( 'B5LDetail' ):SetUniqueLine( { 'B5L_CODRDA', 'B5L_CODSW2'} )
oModel:GetModel( 'B5LHDetail' ):SetUniqueLine( { 'B5L_CODRDA', 'B5L_CODSW2'} )
oModel:GetModel( 'B5LSDetail' ):SetUniqueLine( { 'B5L_CODRDA', 'B5L_CODSW2'} )

oModel:GetModel( 'B5WDetail' ):setOptional(.t.)
oModel:GetModel( 'B5YDetail' ):setOptional(.t.)
oModel:GetModel( 'B5ZDetail' ):setOptional(.t.)
oModel:GetModel( 'B5LDetail' ):setOptional(.f.)
oModel:GetModel( 'B5LHDetail' ):setOptional(.t.)
oModel:GetModel( 'B5LSDetail' ):setOptional(.t.)

//Filtro dos Grids
oModel:GetModel( 'B5LDetail'  ):SetLoadFilter( { { 'B5L_TPNOXM', "'1'" } } )
oModel:GetModel( 'B5LHDetail' ):SetLoadFilter( { { 'B5L_TPNOXM', "'2'" } } )
oModel:GetModel( 'B5LSDetail' ):SetLoadFilter( { { 'B5L_TPNOXM', "'3'" } } )

oModel:GetModel( 'B5XMASTER' ):SetDescription( STR0001 ) //Prestador - Informa��o PTU A410
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da interface.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSUNISLE' )
Local oStrB5X	:= FWFormStruct(2,'B5X')
Local oStrB5W	:= FWFormStruct(2,'B5W')
Local oStrB5Y	:= FWFormStruct(2,'B5Y')
Local oStrB5Z   := FWFormStruct(2,'B5Z')
Local oStrB5L   := FWFormStruct(2,'B5L', { |cCampo| FilEspCmp(cCampo) })
Local oStrB5LH  := FWFormStruct(2,'B5L', { |cCampo| FilHosCmp(cCampo) } )
Local oStrB5LS  := FWFormStruct(2,'B5L', { |cCampo| FilSDTCmp(cCampo) } )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_B5X', oStrB5X, 'B5XMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 60)
oView:CreateHorizontalBox( 'BAIXO'	 , 40)

//dados gerais
oStrB5X:SetProperty('B5X_TPACRE', MVC_VIEW_TITULO, "Tipo de Acredita��o")

//Leitos Existentes - caption para facilitar a leitura do usu�rio
oStrB5X:SetProperty('B5X_ERLPIS', MVC_VIEW_TITULO, "Psiqui�tricos")
oStrB5X:SetProperty('B5X_ERLINT', MVC_VIEW_TITULO, "Intermedi�rio NeoNatal")
oStrB5X:SetProperty('B5X_ERLDIA', MVC_VIEW_TITULO, "Hospital Dia")
oStrB5X:SetProperty('B5X_ERLBER', MVC_VIEW_TITULO, "Ber��rio")
oStrB5X:SetProperty('B5X_ERLIND', MVC_VIEW_TITULO, "Individual")
oStrB5X:SetProperty('B5X_ERLCOL', MVC_VIEW_TITULO, "Coletivo")
oStrB5X:SetProperty('B5X_ERLISO', MVC_VIEW_TITULO, "Isolamento")
oStrB5X:SetProperty('B5X_ERLUCC', MVC_VIEW_TITULO, "Unid. Cuidados Cl�nicos UCC")
oStrB5X:SetProperty('B5X_ERLSEM', MVC_VIEW_TITULO, "Terapia Semi Intensiva")
oStrB5X:SetProperty('B5X_ELNEOC', MVC_VIEW_TITULO, "UCI NeoNatal Convencional")
oStrB5X:SetProperty('B5X_ELNNCG', MVC_VIEW_TITULO, "UCI NeoNatal Canguru")
oStrB5X:SetProperty('B5X_ERLPED', MVC_VIEW_TITULO, "UCI Pedi�trico")
oStrB5X:SetProperty('B5X_ERLADU', MVC_VIEW_TITULO, "UCI Adulto")
oStrB5X:SetProperty('B5X_ELCORO', MVC_VIEW_TITULO, "Unid. Coronariana")
oStrB5X:SetProperty('B5X_ERUTIA', MVC_VIEW_TITULO, "UTI Adultos")
oStrB5X:SetProperty('B5X_ERUTIN', MVC_VIEW_TITULO, "UTI NeoNatal")
oStrB5X:SetProperty('B5X_ERUTIP', MVC_VIEW_TITULO, "UTI Pedi�trica")
oStrB5X:SetProperty('B5X_ETITP1', MVC_VIEW_TITULO, "UTI Adulto Tipo 1")
oStrB5X:SetProperty('B5X_ETITP2', MVC_VIEW_TITULO, "UTI Adulto Tipo 2")
oStrB5X:SetProperty('B5X_ETITP3', MVC_VIEW_TITULO, "UTI Adulto Tipo 3")
oStrB5X:SetProperty('B5X_ETIPT1', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 1")
oStrB5X:SetProperty('B5X_ETIPT2', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 2")
oStrB5X:SetProperty('B5X_ETIPT3', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 3")
oStrB5X:SetProperty('B5X_ETINT1', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 1")
oStrB5X:SetProperty('B5X_ETINT2', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 2")
oStrB5X:SetProperty('B5X_ETINT3', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 3")
oStrB5X:SetProperty('B5X_ETIQUE', MVC_VIEW_TITULO, "UTI Queimados")
oStrB5X:SetProperty('B5X_ETICR2', MVC_VIEW_TITULO, "UTI Coronariana Tipo 2")
oStrB5X:SetProperty('B5X_EOBSPA', MVC_VIEW_TITULO, "Observa��o P.A.")
oStrB5X:SetProperty('B5X_EEMRPA', MVC_VIEW_TITULO, "Sala Emerg�ncia P.A.")

//Leitos Contratados - caption para facilitar a leitura do usu�rio
oStrB5X:SetProperty('B5X_NRLPIS', MVC_VIEW_TITULO, "Psiqui�tricos")
oStrB5X:SetProperty('B5X_NRLINT', MVC_VIEW_TITULO, "Intermedi�rio NeoNatal")
oStrB5X:SetProperty('B5X_NRLDIA', MVC_VIEW_TITULO, "Hospital Dia")
oStrB5X:SetProperty('B5X_NRLBER', MVC_VIEW_TITULO, "Ber��rio")
oStrB5X:SetProperty('B5X_NRLIND', MVC_VIEW_TITULO, "Individual")
oStrB5X:SetProperty('B5X_NRLCOL', MVC_VIEW_TITULO, "Coletivo")
oStrB5X:SetProperty('B5X_NRLISO', MVC_VIEW_TITULO, "Isolamento")
oStrB5X:SetProperty('B5X_NRLUCC', MVC_VIEW_TITULO, "Unid. Cuidados Cl�nicos UCC")
oStrB5X:SetProperty('B5X_NRLSEM', MVC_VIEW_TITULO, "Terapia Semi Intensiva")
oStrB5X:SetProperty('B5X_NLNEOC', MVC_VIEW_TITULO, "UCI NeoNatal Convencional")
oStrB5X:SetProperty('B5X_NLNNCG', MVC_VIEW_TITULO, "UCI NeoNatal Canguru")
oStrB5X:SetProperty('B5X_NRLPED', MVC_VIEW_TITULO, "UCI Pedi�trico")
oStrB5X:SetProperty('B5X_NRLADU', MVC_VIEW_TITULO, "UCI Adulto")
oStrB5X:SetProperty('B5X_NLCORO', MVC_VIEW_TITULO, "Unid. Coronariana")
oStrB5X:SetProperty('B5X_NRUTIA', MVC_VIEW_TITULO, "UTI Adultos")
oStrB5X:SetProperty('B5X_NRUTIN', MVC_VIEW_TITULO, "UTI NeoNatal")
oStrB5X:SetProperty('B5X_NRUTIP', MVC_VIEW_TITULO, "UTI Pedi�trica")
oStrB5X:SetProperty('B5X_UTITP1', MVC_VIEW_TITULO, "UTI Adulto Tipo 1")
oStrB5X:SetProperty('B5X_UTITP2', MVC_VIEW_TITULO, "UTI Adulto Tipo 2")
oStrB5X:SetProperty('B5X_UTITP3', MVC_VIEW_TITULO, "UTI Adulto Tipo 3")
oStrB5X:SetProperty('B5X_UTIPT1', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 1")
oStrB5X:SetProperty('B5X_UTIPT2', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 2")
oStrB5X:SetProperty('B5X_UTIPT3', MVC_VIEW_TITULO, "UTI Pedi�trica Tipo 3")
oStrB5X:SetProperty('B5X_UTINT1', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 1")
oStrB5X:SetProperty('B5X_UTINT2', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 2")
oStrB5X:SetProperty('B5X_UTINT3', MVC_VIEW_TITULO, "UTI NeoNatal Tipo 3")
oStrB5X:SetProperty('B5X_UTIQUE', MVC_VIEW_TITULO, "UTI Queimados")
oStrB5X:SetProperty('B5X_UTICR2', MVC_VIEW_TITULO, "UTI Coronariana Tipo 2")
oStrB5X:SetProperty('B5X_NOBSPA', MVC_VIEW_TITULO, "Observa��o P.A.")
oStrB5X:SetProperty('B5X_NEMRPA', MVC_VIEW_TITULO, "Sala Emerg�ncia P.A.")

//Dados Gerais
oStrB5X:SetProperty('B5X_NRLTOT', MVC_VIEW_TITULO, "N� Total Leitos")
oStrB5X:SetProperty('B5X_NRLCON', MVC_VIEW_TITULO, "N� Total Leitos Contratados")
oStrB5X:SetProperty('B5X_PRDATN', MVC_VIEW_TITULO, "Prioridade de Atendimento")
oStrB5X:SetProperty('B5X_NLTCIR', MVC_VIEW_TITULO, "N� Total Leitos Cir�rgicos")
oStrB5X:SetProperty('B5X_NLTOBS', MVC_VIEW_TITULO, "N� Total Leitos Obst�tricos")
oStrB5X:SetProperty('B5X_NLTPED', MVC_VIEW_TITULO, "N� Total Leitos Pedi�tricos")
oStrB5X:SetProperty('B5X_IDUTI' , MVC_VIEW_TITULO, "Possui UTI?")

//Dados Negocia��o
oStrB5X:SetProperty('B5X_NGDITX', MVC_VIEW_TITULO, "Tipo Negocia��o Di�rias/Taxas")
oStrB5X:SetProperty('B5X_EXCDIA', MVC_VIEW_TITULO, "Informa��o de exce��es das di�rias")
oStrB5X:SetProperty('B5X_NGMTCS', MVC_VIEW_TITULO, "Tipo Negocia��o Materiais de Consumo")
oStrB5X:SetProperty('B5X_NGEQUO', MVC_VIEW_TITULO, "Tipo Negocia��o Equipos")
oStrB5X:SetProperty('B5X_NGOPME', MVC_VIEW_TITULO, "Tipo Negocia��o OPME")
oStrB5X:SetProperty('B5X_PCTXOP', MVC_VIEW_TITULO, "Taxa Comercial. OPME")
oStrB5X:SetProperty('B5X_TPMTES', MVC_VIEW_TITULO, "Tipo Negocia��o Material Especial")
oStrB5X:SetProperty('B5X_PCTXME', MVC_VIEW_TITULO, "Taxa Comercial. Material Espe")
oStrB5X:SetProperty('B5X_NGMEDI', MVC_VIEW_TITULO, "Tipo Negocia��o Medicamentos")
oStrB5X:SetProperty('B5X_NGDIET', MVC_VIEW_TITULO, "Tipo Negocia��o Dietas")
oStrB5X:SetProperty('B5X_NGSADT', MVC_VIEW_TITULO, "Tipo Negocia��o SADT")
oStrB5X:SetProperty('B5X_NGHONM', MVC_VIEW_TITULO, "Tipo Negocia��o Honor�rios M�dicos")

//Ordena��o dos Crit�rios Econ�micos
oStrB5X:SetProperty( 'B5X_NGDITX' , MVC_VIEW_ORDEM    , "00" )
oStrB5X:SetProperty( 'B5X_EXCDIA' , MVC_VIEW_ORDEM    , "01" )
oStrB5X:SetProperty( 'B5X_NGMTCS' , MVC_VIEW_ORDEM    , "02" )
oStrB5X:SetProperty( 'B5X_NGEQUO' , MVC_VIEW_ORDEM    , "03" )
oStrB5X:SetProperty( 'B5X_NGOPME' , MVC_VIEW_ORDEM    , "04" )
oStrB5X:SetProperty( 'B5X_PCTXOP' , MVC_VIEW_ORDEM    , "05" )
oStrB5X:SetProperty( 'B5X_TPMTES' , MVC_VIEW_ORDEM    , "06" )
oStrB5X:SetProperty( 'B5X_PCTXME' , MVC_VIEW_ORDEM    , "07" )
oStrB5X:SetProperty( 'B5X_NGMEDI' , MVC_VIEW_ORDEM    , "08" )
oStrB5X:SetProperty( 'B5X_NGDIET' , MVC_VIEW_ORDEM    , "09" )
oStrB5X:SetProperty( 'B5X_NGSADT' , MVC_VIEW_ORDEM    , "10" )
oStrB5X:SetProperty( 'B5X_NGHONM' , MVC_VIEW_ORDEM    , "11" )

//Grids
oView:AddGrid( 'ViewB5L', oStrB5L, 'B5LDetail' )
oView:AddGrid( 'ViewB5LH', oStrB5LH, 'B5LHDetail' )
oView:AddGrid( 'ViewB5LS', oStrB5LS, 'B5LSDetail' )
oView:AddGrid( 'ViewB5W', oStrB5W, 'B5WDetail' )
oView:AddGrid( 'ViewB5Y', oStrB5Y, 'B5YDetail' )
oView:AddGrid( 'ViewB5Z', oStrB5Z, 'B5ZDetail' )

//T�tulo
oView:EnableTitleView('ViewB5L',STR0015) //"Especialidade M�dica / Hospital Especializado"
oView:EnableTitleView('ViewB5LH',STR0016) //"Servi�os Hospitalares"
oView:EnableTitleView('ViewB5LS',STR0017) //"Dados do SADT"
oView:EnableTitleView('ViewB5W',STR0006) //"Exce��o Prestador SADT"
oView:EnableTitleView('ViewB5Y',STR0007) //"Exce��o Prestador Honor�rio M�dico - Especialidade"
oView:EnableTitleView('ViewB5Z',STR0008) //"Exce��o Prestador Honor�rio M�dico - �rea Atua��o"

//Folders
oView:CreateFolder( 'ABA', 'BAIXO' )
oView:CreateHorizontalBox( 'A1' , 100,,, 'ABA', 'V1')
oView:CreateHorizontalBox( 'A2' , 100,,, 'ABA', 'V2')
oView:CreateHorizontalBox( 'A3' , 100,,, 'ABA', 'V3')
oView:CreateHorizontalBox( 'A4' , 100,,, 'ABA', 'V4')
oView:CreateHorizontalBox( 'A5' , 100,,, 'ABA', 'V5')
oView:CreateHorizontalBox( 'A6' , 100,,, 'ABA', 'V6')

//Abas com grids
oView:AddSheet( 'ABA', 'V1', STR0015) //Especialidade M�dica / Hospital Especializado
oView:AddSheet( 'ABA', 'V2', STR0016) //Servi�os Hospitalares
oView:AddSheet( 'ABA', 'V3', STR0017) //Dados do SADT
oView:AddSheet( 'ABA', 'V4', STR0006) //Exce��o Prestador SADT
oView:AddSheet( 'ABA', 'V5', STR0007) //Exce��o Prestador Honor�rio M�dico - Especialidade
oView:AddSheet( 'ABA', 'V6', STR0008) //Exce��o Prestador Honor�rio M�dico - �rea Atua��o

oView:SetOwnerView('VIEW_B5X', 'SUPERIOR' )
oView:SetOwnerView('ViewB5L' , 'A1' )
oView:SetOwnerView('ViewB5LH', 'A2' )
oView:SetOwnerView('ViewB5LS', 'A3' )
oView:SetOwnerView('ViewB5W' , 'A4' )
oView:SetOwnerView('ViewB5Y' , 'A5' )
oView:SetOwnerView('ViewB5Z' , 'A6' )

oView:AddUserButton( STR0010, 'CLIPS', {|oView| PSinBAUB5X(oModel)} )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclus�o do Registro.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADOK(oModel)
Local lRet		:= .T.

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PSinBAUB5X
Valida a inclus�o do Registro.
@since 09/2019.
@version P12
/*/
//-------------------------------------------------------------------
static Function PSinBAUB5X(oModel, lAutoma)
local nI 		:= 0
local aCampos	:= {'ENFER','APTO','URGEME','NRLTOT','NRLCON','NRLPIS','NRUTIA','NRUTIN','NRUTIP','PRDATN','NRLINT','NLTCIR','NLTOBS','NLTPED'}
local lRet		:= .f.
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

if ( lAutoma .or. MsgYesNo(STR0011 + CRLF + STR0012,STR0013) ) //Deseja sincronizar os dados de leitos presentes na RDA (aba Atendimento) para este novo cadastro? - "Ao clicar em Sim, os dados ser�o sobrescritos pelos que constam na RDA."
	for nI := 1 to Len(aCampos)
		oModel:getmodel('B5XMASTER'):loadValue("B5X_" + aCampos[nI] , &("BAU->BAU_" + aCampos[nI]))
	next
	oModel:getmodel('B5XMASTER'):loadValue("B5X_NRLDIA", val(BAU->BAU_NRLDIA))	//Na BAU est� como caracter
	iif( !lAutoma, msgalert( STR0014, STR0013 ), "" ) //"Aten��o" / "Dados sincronizados."
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRtTpAtIsle
Gatilho para exibir o tipo de servi�o para o usu�rio, de acordo com a tabela B5V
@since 12/2019
@version P12
/*/
//-------------------------------------------------------------------
function PlRtTpAtIsle(cCodigo)
local cTexto 	:= ''
local aTpAtend	:= {{'_ESPMED', 'Especialidade'}, {'_SERHOS','Hospitalar'}, {'_SRSADT', 'SADT'}}
local nI 		:= 0
local cAlias	:= "B5V"
local lRet		:= .t.
default cCodigo	:= "-"

if cValtoChar(cCodigo) != "-"
	B5V->(DbsetOrder(1))
	if !B5V->(MsSeek(xfilial("B5V") + cValtoChar(cCodigo)))
		lRet := .f.
	endif
endif

if lRet
	for nI := 1 to len(aTpAtend)
		if ( (cAlias)->&(cAlias + aTpAtend[nI,1]) == "1" )
			cTexto += aTpAtend[nI,2] + ' / '
		endif 
	next
	cTexto := substr(cTexto,1, len(cTexto) -3 )
endif
return cTexto


//-------------------------------------------------------------------
/*/{Protheus.doc} PlTipSrvPTU
Preencher o campo B5L_TPNOXM com o valor correto, representando o tipo de servi�o preenchido pelo usu�rio
1 - Especialidade / 2 - Hospitalar / 3 - SADT
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlTipSrvPTU(oModel,cTipo, cObjGrid)
local lRet 		:= .t.
local oB5LGen 	:= oModel:getmodel(cObjGrid)
local aCmpVld	:= Separa( iif(cTipo == "1", cCmpEspMed, iif(cTipo == "2", cCmpSerHos, cCmpSADT)), ",")
local nFor 		:= 0
local cCmpNotV	:= 'B5L_CODRDA,B5L_DESCRI,B5L_NMTER2,B5L_RGTER2,B5L_NMTER1,B5L_RGTER1' 
local cNomExten	:= 	iif(cTipo == "1", STR0015, iif(cTipo == "2", STR0016, STR0017))

if (oB5LGen:getValue("B5L_TPNOXM") != cTipo)
	oB5LGen:loadValue("B5L_TPNOXM", cTipo)
endif

if cTipo == "3" .and. oB5LGen:getValue('B5L_TPSADT') == "02" .and. ( empty(oB5LGen:getValue('B5L_NMTER1')) .or. empty(oB5LGen:getValue('B5L_RGTER1')) )
	Help(nil, nil , STR0013, nil, STR0027 , 1, 0, NIL, NIL, NIL, NIL, NIL, {''} ) //Quando servi�o SADT � terceirizado, obrigat�rio informar Nome e CNPJ/CPF do terceirizado principal
	lRet := .f.
else		
	for nFor := 1 to Len(aCmpVld)
		if empty( oB5LGen:getValue(aCmpVld[nFor]) ) .and. !aCmpVld[nFor] $ cCmpNotV
			Help(nil, nil , STR0013, nil, STR0026 + ' ' + cNomExten, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} ) //"Informe os demais campos do grid"
			lRet := .f.
			exit
		endif
	next
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FilHosCmp
Campos que devem ser exibidos no grid de SERVI�OS HOSPITALARES
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function FilHosCmp(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ cCmpSerHos
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FilEspCmp
Campos que devem ser exibidos no grid de ESPECIALIDADE M�DICA/HOSPITAL ESPECIALIZADO
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function FilEspCmp(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ cCmpEspMed //'B5L_TPSADT,B5L_NMTER1,B5L_NMTER2,B5L_RGTER1,B5L_RGTER2,B5L_TPATEN'
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FilSDTCmp
Campos que devem ser exibidos no grid de DADOS DO SADT
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function FilSDTCmp(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ cCmpSADT
	lRet := .t.
endif	

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Pl410Flt
Valida se o c�digo informado na B5L existe e se pertence ao tipo isnerido de especialidade/hospital/sadt                                       
@since  02/2020
/*/
//-------------------------------------------------------------------
static function Pl410Flt(cValor, cGrid)
local lRet 		:= .f.
local cRet		:= ""

B5V->(DbsetOrder(1))
if B5V->(DbSeek(xfilial("B5V") + cValor))
	if cGrid == "1" .and. B5V->B5V_ESPMED != "1"
		cRet := STR0022 //"Servi�o informado n�o � Especialidade M�dica."
	elseif cGrid == "2" .and. B5V->B5V_SERHOS != "1" 
		cRet := STR0023//"Servi�o informado n�o � Servi�o Hospitalar."
	elseif cGrid == "3" .and. B5V->B5V_SRSADT != "1" 
		cRet := STR0024	//"Servi�o informado n�o � SADT."
	endif
else
	cRet := STR0025 //"C�digo inv�lido. Informe um c�digo existente na tabela W2."
endif

if !empty(cRet)
	Help(nil, nil , STR0013, nil, cRet, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} ) 
else
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTELNEW
Tela de Informa��es do PTU A410                                        
@since  02/2020
/*/
//-------------------------------------------------------------------
static function PLSTELNEW()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	

BAG->(dbsetorder(1))
if ( BAG->(dbSeek(xFilial("BAG") + BAU->BAU_TIPPRE)) .and. (alltrim(BAG->BAG_CODPT) $ ('02,10')) )
	B5X->(dbsetorder(1))
	if ( B5X->(dbSeek(xFilial("B5X") + BAU->BAU_CODIGO)) )
		FWExecView(STR0001,'PLSUNISLE', 4,,,,,aButtons ) //Informa��es do PTU A410
	else
		FWExecView(STR0001,'PLSUNISLE', 3,,,,,aButtons ) //Informa��es do PTU A410
	endif 	
else
	Help(nil, nil , STR0013, nil, STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} ) //"V�lido somente para Prestador do tipo Hospital e Hospital Dia"
endif	

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlCbPT410
Cbox dos campos, devido aos novos valores isneridos                                     
@since  02/2020
/*/
//-------------------------------------------------------------------
Function PlCbPT410(cNomBox)
local cRet	:= ""

if cNomBox == "1"
	cRet := "01=Aus�ncia Regula��o ou Taxa comercializa��o acima do permitido;02=Aceita Regula��o com Taxa comercializa��o;03=Aceita Regula��o sem Taxa comercializa��o"
	cRet += ";04=Aceita Pagamento Direto ao Fornecedor;05=N�o possui negocia��o / N�o se aplica"
elseif cNomBox == "2"
	cRet := "01=TNUMM (Bras�ndice/Simpro/PF) com acr�scimo;02=TNUMM (Bras�ndice/Simpro/PF); 03=TNUMM (Bras�ndice/Simpro/PF) com desconto"
	cRet += ";04=Valor Acordado Base/Custo com Acr�scimo"                                
elseif cNomBox == "3"
	cRet := "01=Pratica pre�o acima TNUMM (maior 100%);02=Pratica pre�o acima TNUMM (at� 100%);03=Pratica TNUMM;04=Pratica pre�os inferiores TNUMM"
	cRet += ";05=N�o possui negocia��o / N�o se aplica" 
elseif cNomBox == "4"
	cRet := "01=TNUMM (CMED PF + 20%) com Acr�scimo;02=TNUMM (CMED PF + 20%);03=TNUMM (CMED PF + 20%) com Desconto ou Tabela baseada em Gen�ricos;"
	cRet += "04=Valor Acordado Base Custo com Acr�scimo;05=N�o possui negocia��o / N�o se aplica"
elseif cNomBox == "5"	
	cRet := "01=N�o Aceita ROL Unimed;02=Aceita ROL Unimed com exce��o de mais de um servi�o;03=Aceita ROL Unimed com exce��o de um servi�o"
	cRet += ";04=Aceita 100% ROL Unimed;05=N�o possui negocia��o / N�o se aplica
elseif cNomBox == "6"	
	cRet := "01=N�o Aceita ROL Unimed;02=Aceita ROL Unimed com exce��o de mais de uma Especialidade M�dica;03=Aceita ROL Unimed com Exce��o de uma Especialidade"
	cRet += " M�dica;04=Aceita 100% ROL Unimed;05=N�o possui negocia��o / N�o se aplica"
endif 

return cRet