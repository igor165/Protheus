#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FISA828.CH'	

#DEFINE _COE 		1
#DEFINE _DOC 		2
#DEFINE _SERIE 		3
#DEFINE _CLIFOR 	4
#DEFINE _LOJA 		5
#DEFINE _ITEM		6
#DEFINE _COD 		7
#DEFINE _QUANT 		8
#DEFINE _VALUNIT 	9
#DEFINE _TOTAL 		10
#DEFINE _TES 		11
#DEFINE _PROVENT 	12
#DEFINE _EMISSAO 	13
#DEFINE _DIGIT 		14
#DEFINE _COMISION	15
#DEFINE _CALIDAD	16
#DEFINE _NOMPRO 	17
#DEFINE _PROESP 	18
#DEFINE _NOMESP 	19
#DEFINE _NOMBRE 	20
#DEFINE _CUIT 		21
#DEFINE _NROIB 		22
#DEFINE _NATUREZ	23
#define _COND		24


#DEFINE _IMPCOD		1
#DEFINE _IMPALIQ	2
#DEFINE _IMPBASE	3
#DEFINE _IMPVAL		4
#DEFINE _IMPCPOBAS	6
#DEFINE _IMPCPOVAL	7
#DEFINE _IMPCPOLIV	17

//Retenciones
#DEFINE _RETIVA 	1
#DEFINE _RETIIBB	2
#DEFINE _RETGAN		3
#DEFINE _RETSE		4
#DEFINE _RETDR		5

//Datos para liquidacion final
#DEFINE _PTOEMI		1
#DEFINE _CODCTR		2
#DEFINE _PROPRO		3
#DEFINE _PROVEN		4
#DEFINE _PROVOR		5
#DEFINE _DATAFP 	6
#DEFINE _PORTO		7
#DEFINE _NOMEPO		8
#DEFINE _CODPGO		9
#DEFINE _OPERAC		10
#DEFINE _TROCA		11
#DEFINE _ACTCOR		12
#DEFINE _LIQCOR		13
#DEFINE _CORRED		14
#DEFINE _LOJCOR		15
#DEFINE _CUITCR		16
#DEFINE _NOMCOR		17
#DEFINE _NOIBCR		18

STATIC aCampX3		:= {}
STATIC ACAMPX3NJC  	:= {}
STATIC aItems		:= {}
STATIC aItemsI		:= {}
STATIC oLbxR		:= Nil
STATIC oLbxI		:= Nil 

STATIC cEspecie		:= ""
STATIC cLiquid		:= ""
STATIC cTipLiq		:= ""
STATIC aDatosLiq	:= {}
STATIC lCreaReg		:= .F.
STATIC aDtosLiqF	:= {} //NJC_PTOEMI,NJC_CODCTR,NJC_PROPRO,NJC_PROVEN,NJC_PROVOR -NJC_DATAFP,NJC_PORTO, NJC_NOMEPO,NJC_CODPGO
STATIC nRecno		:= 0
STATIC aReten		:= {{},{},{},{},{}}
STATIC lRev		    := .F.

/*
{Protheus.doc} FISA828()

Função para cadastro tabela NJC

@Author     Francisco Oliveira
@Since      11/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		Nil
*/
Function FISA828()
	
	Local oBrowse	:= Nil
	
	Private lLimGrid	:= .F.
	Private aTES		:= {}
	Private lImpCalc	:= .F.
	Private lTipAju		:= .F.
	Private _aGrdM	:= {} // NL3
	Private _aGrdP	:= {} // NL4
	Private _cURL		:= ""
	Private aLogErro	:= {}

	
	
	
	Private lFisa828	:= .T.
	
	lRev := .F.
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('NJC')
	oBrowse:SetDescription(OemToAnsi(STR0006)) // Liquidação e Certificação de Grãos
	oBrowse:AddLegend("alltrim(NJC_STATUS) $ '1' .And. NJC_LIQ=='1'"		, "GREEN" 	, OemToAnsi(STR0007)) // "Em Edição"
	oBrowse:AddLegend("alltrim(NJC_STATUS) $ '1' .And. NJC_LIQ=='2' "		, "BROWN" 	, OemToAnsi(STR0063)) // "Liquidaciones pendientes" 
	oBrowse:AddLegend("alltrim(NJC_STATUS) $ '3' "							, "ORANGE" 	, OemToAnsi(STR0067)) // "Transmitida y no Integrada"
	oBrowse:AddLegend("alltrim(NJC_STATUS) $ '2' .Or. NJC_STATUS == 'AC' "	, "BLUE" 	, OemToAnsi(STR0068 )) // "Transmitida/Confirmada e integrada" - Status = "2"
	
	oBrowse:Activate()
	
Return Nil

/*
{Protheus.doc} MenuDef()Criacao do MENU

@Author     Francisco Oliveira
@Since      11/07/2016
@Project    AGRO - Argentina
@Return 	aRotina - Array contendo as rotinas do menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION 'VIEWDEF.FISA828' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION 'VIEWDEF.FISA828' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION 'VIEWDEF.FISA828' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0058) ACTION 'ARGWSLPEG'		 OPERATION 3 ACCESS 0 // 'Transmissão'
	ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION 'VIEWDEF.FISA828' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE OemToAnsi(STR0059) ACTION 'VLDLSG'			 OPERATION 3 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE OemToAnsi(STR0024) ACTION 'FISA828LEG'      OPERATION 9 ACCESS 0 // 'Legenda'
	
	
Return aRotina

/*
{Protheus.doc} FISA828LEG()

Define la Leyenda

@Author     Francisco Oliveira
@Since      11/07/2016
@Version	P12.7
@Project	AGRO - Argentina
@Return		aCores
*/
Function FISA828LEG()
	
	Local aCores    := {}
	
	aAdd(aCores, {"BR_VERDE"	, OemToAnsi(STR0007)}) // "Em Edição"
	aAdd(aCores, {"BR_MARRON"	, OemToAnsi(STR0063 )}) // "Liquidaciones pendientes" - Status = "1"
	aAdd(aCores, {"BR_LARANJA"	, OemToAnsi(STR0067 )}) // "Transmitida y no Integrada" - Status = "3"
	aAdd(aCores, {"BR_AZUL"		, OemToAnsi(STR0068 )}) // "Transmitida/Confirmada e integrada" - Status = "2"
	
	
	BrwLegenda(OemToAnsi(STR0006), OemToAnsi(STR0011), aCores ) // Status
	
Return Nil

/*
{Protheus.doc} ModelDef()

Contem a construcao e a definicao do Model, contem as regras de negocio

@Author     Francisco Oliveira
@Since      11/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 oModel
*/
Static Function ModelDef()
	
	Local cCamposRod	:= "NJC_PESTOT, NJC_SUBOPE, NJC_IMPIVA, NJC_OPEIVA, NJC_TOTDED, NJC_RETAFI, NJC_OTRRET, NJC_IMPNAP, NJC_IVARG2, NJC_PAGSCO,NJC_CREDEB,"
	Local cCamposOut	:= "NJC_RPESTO,NJC_RSUBOP,NJC_RTOTDE,NJC_RRETAF,NJC_ROTRRE,NJC_RIMPNA,NJC_RIMPIV,NJC_RIVARG,NJC_RPAGSC,NJC_LIQUID,NJC_CODEDU,NJC_CODARM,NJC_TAXIVA,NJC_CODIVA,NJC_ALRIVA,NJC_CODIMP,NJC_ALIIMP,NJC_CODDES,NJC_ALIDES,NJC_CODDOU,NJC_ALIOUT,NJC_OBS,NJC_ACTEMI,NJC_VLRLIQ,NJC_SALDO,NJC_VLRARM,NJC_VLRIVA,NJC_LOCPRO,NJC_CODCET,NJC_STAFIP,NJC_DTTRAN"
	Local oStruNJC		:= FWFormStruct(1, 'NJC', {|cCampo|Iif(alltrim(cCampo) == "NJC_LIQ", .T. ,!(alltrim(cCampo)$ cCamposOut))})
	Local oStruNL3		:= FWFormStruct(1, 'NL3')
	Local oStruNL4		:= FWFormStruct(1, 'NL4')
	
	Local bPre			:= { |oModel| FIS828PREV(oModel)}    
	Local bPos			:= { |oModel| ValidPos(oModel)} //bPosValidacao
	Local bComit		:= { |oModel| FISA828Com(oModel)}
	
	Local oModel		:= MPFormModel():New( 'FISA828MD',bPre, bPos , bComit , /*bCancel*/ )
	Local lInit828		:= TYPE("lFisa828") == "L" .and. lFisa828

	
	If lInit828
		//Inicializadores producto
		oStruNJC:SetProperty( 'NJC_COMPRO'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDatosLiq[_COE]	,"") ) })
		oStruNJC:SetProperty( 'NJC_PTOEMI'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_PTOEMI]	,"") ) })
		oStruNJC:SetProperty( 'NJC_CODCTR'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_CODCTR]	,"") ) })
		oStruNJC:SetProperty( 'NJC_PROPRO'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_PROPRO]	,"") ) })
		oStruNJC:SetProperty( 'NJC_PROVEN'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_PROVEN]	,"") ) })
		oStruNJC:SetProperty( 'NJC_PROVOR'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_PROVOR]	,"") ) })
		oStruNJC:SetProperty( 'NJC_TIPO'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, cTipLiq ) })
		oStruNJC:SetProperty( 'NJC_ESPLIQ', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, cEspecie) })
		oStruNJC:SetProperty( 'NJC_TPLIQ' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, cLiquid ) })
	
		//Inicializadores producto
		oStruNJC:SetProperty( 'NJC_OPERAC', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_OPERAC]	,"") ) })
		oStruNJC:SetProperty( 'NJC_TROCA' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel, Iif(cTipLiq == "2",aDtosLiqF[_TROCA]	,"") ) })
		oStruNJC:SetProperty( 'NJC_PROD'  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_COD]	) })
		oStruNJC:SetProperty( 'NJC_NOMPRO', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_NOMPRO]	) })
		oStruNJC:SetProperty( 'NJC_ESPECI', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_PROESP]	) })
		oStruNJC:SetProperty( 'NJC_DESESP', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_NOMESP]	) })
		
		oStruNJC:SetProperty( 'NJC_REMITO', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_DOC]	) })
		oStruNJC:SetProperty( 'NJC_ITREM' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_ITEM]	) })
		If NJC->(ColumnPos("NJC_SERREM")) > 0
			oStruNJC:SetProperty( 'NJC_SERREM', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_SERIE]	) })
		EndIf
		oStruNJC:SetProperty( 'NJC_INFCER', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,"2") })
		 
		//Inicializadores comprador
		oStruNJC:SetProperty( 'NJC_CODPRO', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "2",aDatosLiq[_CLIFOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_TIENDA', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "2",aDatosLiq[_LOJA]		,"")) })
		oStruNJC:SetProperty( 'NJC_NOMCOM', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "2",aDatosLiq[_NOMBRE]	,"")) })
		oStruNJC:SetProperty( 'NJC_CUITCO', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "2",aDatosLiq[_CUIT]		,"")) })
		oStruNJC:SetProperty( 'NJC_NROIB' ,  	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "2",aDatosLiq[_NROIB]	,"")) })
	
		//Inicializadores vendedor
		oStruNJC:SetProperty( 'NJC_VENDED', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "1",aDatosLiq[_CLIFOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_LOJAVE', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "1",aDatosLiq[_LOJA]		,"")) })
		oStruNJC:SetProperty( 'NJC_NOMVED', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "1",aDatosLiq[_NOMBRE]	,"")) })
		oStruNJC:SetProperty( 'NJC_CUITVE', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "1",aDatosLiq[_CUIT]		,"")) })
		oStruNJC:SetProperty( 'NJC_NROIBV', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cEspecie == "1",aDatosLiq[_NROIB]	,"")) })
		
		//Corredor
		oStruNJC:SetProperty( 'NJC_ACTCOR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_ACTCOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_LIQCOR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_LIQCOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_CORRED', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_CORRED]	,"")) })
		oStruNJC:SetProperty( 'NJC_LOJCOR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_LOJCOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_CUITCR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_CUITCR]	,"")) })
		oStruNJC:SetProperty( 'NJC_NOMCOR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_NOMCOR]	,"")) })
		oStruNJC:SetProperty( 'NJC_NOIBCR', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_NOIBCR]	,"")) })
		
		oStruNJC:SetProperty( 'NJC_PRECO' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_VALUNIT]) })	
		oStruNJC:SetProperty( 'NJC_DATAFP', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_DATAFP]	,STOD("//"))) })
		oStruNJC:SetProperty( 'NJC_PORTO' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_PORTO]	,"14")) })
		oStruNJC:SetProperty( 'NJC_NOMEPO', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_NOMEPO]	,"OTROS")) })
		oStruNJC:SetProperty( 'NJC_CODPGO',		MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,Iif(cTipLiq == "2",aDtosLiqF[_CODPGO]	,aDatosLiq[_COND])) })
		oStruNJC:SetProperty( 'NJC_PESSCE', 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_QUANT]) })
		oStruNJC:SetProperty( 'NJC_TES'	  , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_TES]) })
		If NJC->(ColumnPos("NJC_NATUR")) > 0
			oStruNJC:SetProperty( 'NJC_NATUR' , 	MODEL_FIELD_INIT,	{|oModelGrid|Fis828Vl(oModel,aDatosLiq[_NATUREZ]) })		
		EndIf
	
		
		oStruNJC:SetProperty( 'NJC_PROD'  , 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNJC:SetProperty( 'NJC_CODPRO', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNJC:SetProperty( 'NJC_TIENDA', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNJC:SetProperty( 'NJC_VENDED', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNJC:SetProperty( 'NJC_LOJAVE', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		//oStruNJC:SetProperty( 'NJC_PESSCE', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		
		oStruNJC:SetProperty( 'NJC_PRECO' ,		MODEL_FIELD_WHEN,	{|oModelGrid| F828ACNL4(oModelGrid) } )
		oStruNJC:SetProperty( 'NJC_PRECO' ,		MODEL_FIELD_WHEN,	{|oModelGrid| .F.} )
		oStruNJC:SetProperty( 'NJC_PESSCE', 	MODEL_FIELD_WHEN,	{|oModelGrid| F828ACNL4(oModelGrid) } )
		oStruNJC:SetProperty( 'NJC_INFCER',		MODEL_FIELD_VALID,	{|oModelGrid| F828DLNJ3(oModelGrid) } )
		oStruNJC:SetProperty( 'NJC_PESSCE', 	MODEL_FIELD_WHEN,	{|oModelGrid| F828ACNL3(oModelGrid) } )
		oStruNJC:SetProperty( 'NJC_PESSCE', 	MODEL_FIELD_VALID,	{|oModelGrid| F828VALL4(oModelGrid) } )
		oStruNJC:SetProperty( 'NJC_PESSCE',		MODEL_FIELD_WHEN,	{|oModelGrid| Iif(cTipLiq == "1",.T.,.F.)} )
		oStruNJC:SetProperty( 'NJC_TES'	  ,		MODEL_FIELD_VALID,	{|oModelGrid| F828NJCTES(oModelGrid) } )
		
		oStruNL3:SetProperty( 'NL3_CODLIQ', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNL4:SetProperty( 'NL4_CODLIQ', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNL4:SetProperty( 'NL4_TIPO'  , 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		DbSelectArea("NL4")
		If NL4->(ColumnPos("NL4_TIPAJU")) > 0
			oStruNL4:SetProperty( 'NL4_TIPAJU' , 	MODEL_FIELD_WHEN,	{|oModelGrid|Iif (cTipLiq == "2", .T., .F.)})	
		EndIf
		oStruNL4:SetProperty( 'NL4_DESTES', 	MODEL_FIELD_WHEN,	{|oModelGrid|.F.})
		oStruNL4:SetProperty( 'NL4_CODTES',		MODEL_FIELD_VALID,	{|oModelGrid| F828NL4TES(oModelGrid) } )
	EndIf
	oModel:SetDescription(STR0014) // "Liquidação e Certificação"
	
	oModel:addFields('NJC_MASTER',,oStruNJC)
	
	oModel:addGrid('NL3_DETAIL','NJC_MASTER',oStruNL3,{|oModelGrid,nLine,cAction|F828NL3PRE(oModelGrid,nLine,cAction)},)
	oModel:AddGrid('NL4_DETAIL','NJC_MASTER',oStruNL4,{|oModelGrid,nLine,cAction|F828NL4PRE(oModelGrid,nLine,cAction)},)
	
	oModel:SetRelation('NL3_DETAIL', { { 'NL3_FILIAL', 'FWxFilial("NL3")' }, { 'NL3_CODLIQ', 'NJC_CODLIQ' } }, NL3->(IndexKey(1)) )
	oModel:SetRelation('NL4_DETAIL', { { 'NL4_FILIAL', 'FWxFilial("NL4")' }, { 'NL4_CODLIQ', 'NJC_CODLIQ' } }, NL4->(IndexKey(1)) )
	
	oModel:SetPrimaryKey({'xFilial("NJC")','NJC_CODLIQ'})
	
	oModel:GetModel("NL3_DETAIL"):SetUniqueLine({"NL3_FILIAL", "NL3_CODLIQ", "NL3_CODCET" })
	oModel:GetModel("NL4_DETAIL"):SetUniqueLine({"NL4_FILIAL", "NL4_CODLIQ", "NL4_ITEM" })
	
	oModel:getModel('NJC_MASTER'):SetDescription('NJC')
	oModel:getModel('NL3_DETAIL'):SetDescription('NL3')
	oModel:getModel('NL4_DETAIL'):SetDescription('NL4')
	
	
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL3_DETAIL', 'NL3_PESNET', 'PESTOT' , 'FORMULA', /*bCondition*/,{|oModel|F828PESTTL(oModel)} /*bInitValue*/, STR0041   		/*cTitle*/ , {|oModel|F828PESTTL(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'SUBTOPE', 'FORMULA', /*bCondition*/,{|oModel|F828SUBTTL(oModel)} /*bInitValue*/, STR0042  		/*cTitle*/ , {|oModel|F828SUBTTL(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'IMPIVA' , 'FORMULA', /*bCondition*/,{|oModel|F828TTLOPR(oModel)} /*bInitValue*/, STR0043		/*cTitle*/ , {|oModel|F828TTLOPR(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'OPEIVA' , 'FORMULA', /*bCondition*/,{|oModel|F828OPEIVA(oModel)} /*bInitValue*/, STR0044		/*cTitle*/ , {|oModel|F828OPEIVA(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'TTLDED' , 'FORMULA', /*bCondition*/,{|oModel|F828TTLDED(oModel)} /*bInitValue*/, STR0045  		/*cTitle*/ , {|oModel|F828TTLDED(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'RETAFI' , 'FORMULA', /*bCondition*/,{|oModel|F828RETAFI(oModel)} /*bInitValue*/, STR0046		/*cTitle*/ , {|oModel|F828RETAFI(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'OTRRET' , 'FORMULA', /*bCondition*/,{|oModel|F828OTRRET(oModel)} /*bInitValue*/, STR0047		/*cTitle*/ , {|oModel|F828OTRRET(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'IMPNAP' , 'FORMULA', /*bCondition*/,{|oModel|F828IMPNAP(oModel)} /*bInitValue*/, STR0048		/*cTitle*/ , {|oModel|F828IMPNAP(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'IVARG2' , 'FORMULA', /*bCondition*/,{|oModel|F828IVARG2(oModel)} /*bInitValue*/, STR0049  		/*cTitle*/ , {|oModel|F828IVARG2(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'PAGSCO' , 'FORMULA', /*bCondition*/,{|oModel|F828PAGSCO(oModel)} /*bInitValue*/, STR0050  		/*cTitle*/ , {|oModel|F828PAGSCO(oModel)}/*bFormula*/)
	oModel:AddCalc( 'TOTAL', 'NJC_MASTER', 'NL4_DETAIL', 'NL4_IMPORT', 'CREDEB' , 'FORMULA', /*bCondition*/,{|oModel|F828CREDEB(oModel)} /*bInitValue*/, STR0051		/*cTitle*/ , {|oModel|F828CREDEB(oModel)}/*bFormula*/)
	
	
	oModel:GetModel("NL3_DETAIL"):SetOptional(.T.)
	oModel:GetModel("NL4_DETAIL"):SetOptional(.T.)
		
	//oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .F. )
	//oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .T. )	
	//Utiliza el comportamiento de acols anterior a version 12
	oModel:GetModel("NL3_DETAIL"):SetUseOldGrid()
	oModel:GetModel("NL4_DETAIL"):SetUseOldGrid()
	
	oModel:SetVldActivate({|oModel|FISA828PRE(oModel)})
	
Return oModel

/*
{Protheus.doc} Viewdef()

Cria a interface para uso pela rotina.

@Author     Francisco Oliveira
@Since      11/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 oView
*/
Static Function ViewDef()

	Local cCamposRod	:= "NJC_PESTOT, NJC_SUBOPE, NJC_IMPIVA, NJC_OPEIVA, NJC_TOTDED, NJC_RETAFI, NJC_OTRRET, NJC_IMPNAP, NJC_IVARG2, NJC_PAGSCO,NJC_CREDEB,"
	Local cCamposOut	:= "NJC_RPESTO,NJC_RSUBOP,NJC_RTOTDE,NJC_RRETAF,NJC_ROTRRE,NJC_RIMPNA,NJC_RIMPIV,NJC_RIVARG,NJC_RPAGSC,NJC_LIQUID,NJC_CODEDU,NJC_CODARM,NJC_TAXIVA,NJC_CODIVA,NJC_ALRIVA,NJC_CODIMP,NJC_ALIIMP,NJC_CODDES,NJC_ALIDES,NJC_CODDOU,NJC_ALIOUT,NJC_OBS,NJC_ACTEMI,NJC_VLRLIQ,NJC_SALDO,NJC_VLRARM,NJC_VLRIVA,NJC_LOCPRO,NJC_CODCET,NJC_STAFIP,NJC_DTTRAN"
	
	Local oStruNJC	:= FWFormStruct( 2, 'NJC',{|cCampo|!(Alltrim(cCampo) $ cCamposRod) .and. Iif(alltrim(cCampo) == "NJC_LIQ", .T. ,!(alltrim(cCampo)$ cCamposOut))})
	Local oStruNL3	:= FWFormStruct( 2, 'NL3')
	Local oStruNL4	:= FWFormStruct( 2, 'NL4')
	
	Local oModel	:= FWLoadModel('FISA828')
	Local oStruRod	:= FWCalcStruct( oModel:GetModel('TOTAL') )
	Local oView		:= FWFormView():New()
	Local nOrden	:= 0
	Local nI		:= 1
	Local aCposImp	:= {"1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	
	
	
		//Orden de campos
	oStruNJC:SetProperty("NJC_CODLIQ", MVC_VIEW_ORDEM, "02")
	oStruNJC:SetProperty("NJC_CUITEM", MVC_VIEW_ORDEM, "03")
	oStruNJC:SetProperty("NJC_COMPRO", MVC_VIEW_ORDEM, "04")
	oStruNJC:SetProperty("NJC_DTAAUT", MVC_VIEW_ORDEM, "05")
	oStruNJC:SetProperty("NJC_EMISSA", MVC_VIEW_ORDEM, "06")
	oStruNJC:SetProperty("NJC_PTOEMI", MVC_VIEW_ORDEM, "07")
	oStruNJC:SetProperty("NJC_PTOEMI", MVC_VIEW_LOOKUP, "CFH")
	oStruNJC:SetProperty("NJC_CODCTR", MVC_VIEW_ORDEM, "08")
	oStruNJC:SetProperty("NJC_PROPRO", MVC_VIEW_ORDEM, "09")
	oStruNJC:SetProperty("NJC_PROVEN", MVC_VIEW_ORDEM, "10")
	oStruNJC:SetProperty("NJC_TIPO"  , MVC_VIEW_ORDEM, "11")
	oStruNJC:SetProperty("NJC_ESPLIQ", MVC_VIEW_ORDEM, "12")
	oStruNJC:SetProperty("NJC_TPLIQ" , MVC_VIEW_ORDEM, "13")
	
	//Orden de campos
	oStruNJC:SetProperty("NJC_OPERAC", MVC_VIEW_ORDEM, "14")
	oStruNJC:SetProperty("NJC_TIPLIQ", MVC_VIEW_ORDEM, "15")
	oStruNJC:SetProperty("NJC_INFCER", MVC_VIEW_ORDEM, "16")
	oStruNJC:SetProperty("NJC_TROCA" , MVC_VIEW_ORDEM, "17")
	oStruNJC:SetProperty("NJC_PROD"  , MVC_VIEW_ORDEM, "18")
	oStruNJC:SetProperty("NJC_NOMPRO", MVC_VIEW_ORDEM, "19")
	oStruNJC:SetProperty("NJC_REMITO", MVC_VIEW_ORDEM, "20")
	If NJC->(ColumnPos("NJC_SERREM")) > 0
		oStruNJC:SetProperty("NJC_SERREM", MVC_VIEW_ORDEM, "21")
	EndIf
	oStruNJC:SetProperty("NJC_ITREM" , MVC_VIEW_ORDEM, "22")
	oStruNJC:SetProperty("NJC_ESPECI", MVC_VIEW_ORDEM, "23")
	oStruNJC:SetProperty("NJC_DESESP", MVC_VIEW_ORDEM, "24")
	
	//
	oStruNJC:SetProperty("NJC_CODPRO", MVC_VIEW_ORDEM, "25")
	oStruNJC:SetProperty("NJC_TIENDA", MVC_VIEW_ORDEM, "26")
	oStruNJC:SetProperty("NJC_CUITCO", MVC_VIEW_ORDEM, "27")
	oStruNJC:SetProperty("NJC_NOMCOM", MVC_VIEW_ORDEM, "28")
	oStruNJC:SetProperty("NJC_NROIB" , MVC_VIEW_ORDEM, "29")
	
	//
	oStruNJC:SetProperty("NJC_VENDED", MVC_VIEW_ORDEM, "30")
	oStruNJC:SetProperty("NJC_LOJAVE", MVC_VIEW_ORDEM, "31")
	oStruNJC:SetProperty("NJC_NOMVED", MVC_VIEW_ORDEM, "32")
	oStruNJC:SetProperty("NJC_CUITVE", MVC_VIEW_ORDEM, "33")
	oStruNJC:SetProperty("NJC_NROIBV", MVC_VIEW_ORDEM, "34")
	
	//
	oStruNJC:SetProperty("NJC_ACTCOR", MVC_VIEW_ORDEM, "35")
	oStruNJC:SetProperty("NJC_LIQCOR", MVC_VIEW_ORDEM, "36")
	oStruNJC:SetProperty("NJC_CORRED", MVC_VIEW_ORDEM, "37")
	oStruNJC:SetProperty("NJC_LOJCOR", MVC_VIEW_ORDEM, "38")
	oStruNJC:SetProperty("NJC_CUITCR", MVC_VIEW_ORDEM, "39")
	oStruNJC:SetProperty("NJC_NOMCOR", MVC_VIEW_ORDEM, "40")
	oStruNJC:SetProperty("NJC_NOIBCR", MVC_VIEW_ORDEM, "41")
	
	oStruNJC:SetProperty("NJC_PESSCE", MVC_VIEW_ORDEM, "42")
	oStruNJC:SetProperty("NJC_PRECO" , MVC_VIEW_ORDEM, "43")
	oStruNJC:SetProperty("NJC_DATAFP", MVC_VIEW_ORDEM, "44")
	oStruNJC:SetProperty("NJC_PORTO" , MVC_VIEW_ORDEM, "45")
	oStruNJC:SetProperty("NJC_NOMEPO", MVC_VIEW_ORDEM, "46")
	oStruNJC:SetProperty("NJC_GDOREF", MVC_VIEW_ORDEM, "47")
	oStruNJC:SetProperty("NJC_FRETE" , MVC_VIEW_ORDEM, "48")	
	oStruNJC:SetProperty("NJC_CODSAF", MVC_VIEW_ORDEM, "49")
	oStruNJC:SetProperty("NJC_CODSFP", MVC_VIEW_ORDEM, "50")
	oStruNJC:SetProperty("NJC_CODPGO", MVC_VIEW_ORDEM, "51")
	oStruNJC:SetProperty("NJC_TES"	 , MVC_VIEW_ORDEM, "52")
	If NJC->(ColumnPos("NJC_NATUR")) > 0
		oStruNJC:SetProperty("NJC_NATUR" , MVC_VIEW_ORDEM, "53")
	EndIf
	
	//
	nOrden := 54
	For nI := 1 To Len(aCposImp)
		If NJC->(ColumnPos("NJC_BASIM"+aCposImp[nI])) > 0
			oStruNJC:SetProperty("NJC_BASIM"+aCposImp[nI]	 , MVC_VIEW_ORDEM, AllTrim(STR(nOrden)) )
			nOrden += 1
		Endif
		
		If NJC->(ColumnPos("NJC_ALQIM"+aCposImp[nI])) > 0
			oStruNJC:SetProperty("NJC_ALQIM"+aCposImp[nI]	 , MVC_VIEW_ORDEM, AllTrim(STR(nOrden)))
			nOrden += 1
		EndIf
		
		If NJC->(ColumnPos("NJC_VALIM"+aCposImp[nI])) > 0
			oStruNJC:SetProperty("NJC_VALIM"+aCposImp[nI]	 , MVC_VIEW_ORDEM, AllTrim(STR(nOrden)))
			nOrden += 1
		EndIf
	Next nI
	
	oStruNJC:SetProperty("NJC_FACTOR", MVC_VIEW_ORDEM, AllTrim(STR(nOrden)))
	nOrden += 1
	oStruNJC:SetProperty("NJC_CONPRO", MVC_VIEW_ORDEM, AllTrim(STR(nOrden)))
	
	//oStruRod:SetNoFolder()
	//oStruNL3:RemoveField("NL3_CODLIQ")
	//oStruNL4:RemoveField("NL4_CODLIQ")
	
	oView:SetModel(oModel)
	oView:AddField('oStruNJC' , oStruNJC, 'NJC_MASTER' )
	oView:AddGrid('oStruNL3'  , oStruNL3, 'NL3_DETAIL')
	oView:AddGrid('oStruNL4'  , oStruNL4, 'NL4_DETAIL')
	
	oView:AddIncrementField('NL4_DETAIL', 'NL4_ITEM' )
	
	oView:AddField('TOTALIZADORES', oStruRod,'TOTAL')
	
	oView:CreateHorizontalBox( 'CIMA' , 35)
	oView:CreateHorizontalBox( 'MEIO' , 35)
	oView:CreateHorizontalBox( 'BAIXO', 30)
	
	oView:CreateFolder('FOLDER','MEIO')
	oView:AddSheet('FOLDER','ABANL3',STR0017) // 'Certificados De Deposito'
	oView:AddSheet('FOLDER','ABANL4',STR0018) // 'Operação/Dedução'
	
	oView:CreateHorizontalBox( 'NL3', 100,,, 'FOLDER', 'ABANL3' )
	oView:CreateHorizontalBox( 'NL4', 100,,, 'FOLDER', 'ABANL4' )
	
	oView:CreateFolder('FOLDBX','BAIXO')
	oView:AddSheet('FOLDBX','ABABTOT', STR0025)
	oView:AddSheet('FOLDBX','ABABIMP', STR0026)
	oView:AddSheet('FOLDBX','ABABRET', STR0027)
	
	
	oView:CreateHorizontalBox( 'TOTAL', 100,,, 'FOLDBX', 'ABABTOT' )
	oView:CreateHorizontalBox( 'IMPUESTO', 100,,, 'FOLDBX', 'ABABIMP' )
	oView:CreateHorizontalBox( 'RETENCION', 100,,, 'FOLDBX', 'ABABRET' )
	
	
	oView:SetOwnerView('oStruNJC', 'CIMA')
	oView:SetOwnerView('oStruNL3', 'NL3')
	oView:SetOwnerView('oStruNL4', 'NL4')
	
	oView:AddOtherObject("OTHER_PANEL", {|oPanel| fGridImp(oPanel) })
	oView:AddOtherObject("OTHER_PANEL2", {|oPanel| fGridRet(oPanel) })
	
	oView:SetOwnerView('TOTALIZADORES','TOTAL')
	oView:SetOwnerView('OTHER_PANEL','IMPUESTO')
	oView:SetOwnerView('OTHER_PANEL2','RETENCION')

	oView:AddUserButton(STR0072, "CARGA",	{ |oView| Processa( {|| Fis828Cal(oView) }, OemToAnsi(STR0022),OemToAnsi(STR0023), .T. ) },,116, {MODEL_OPERATION_UPDATE} )//"Favor de Aguardar........"//"Calculando retenciones..."
	oView:AddUserButton(STR0070, "CARGA",	{ |oView| Processa( {|| Fis828Rev(oView) }, OemToAnsi(STR0022),OemToAnsi(STR0071), .T. ) },,116, {MODEL_OPERATION_UPDATE} )//"Favor de Aguardar........"//"Revirtiendo..."

	//Acciones de Campos
	oView:SetFieldAction( 'NJC_INFCER'	, { |oView| F828ACTNJC(oView) } )
	oView:SetFieldAction( 'NJC_PRECO'	, { |oView| F828SUBTOP(oView) } )
	
	oView:SetFieldAction( 'NJC_LOJCOR'	, { |oView| Fis828Loj(oView) } )
	oView:SetFieldAction( 'NJC_PORTO'	, { |oView| Fis828Por(oView) } )
	oView:SetFieldAction( 'NJC_TES'		, { |oView| Fis828TesE(oView) } )
	
	oView:SetFieldAction( 'NL4_CODTES'	, { |oView| Fis828Tes(oView) } )
	
	oView:SetFieldAction( 'NL4_TIPDED'	, { |oView| Fis828TOP(oView) } )
	
	oView:SetFieldAction( 'NL4_QUANT'	, { |oView| Fis828TOT(oView) } )
	oView:SetFieldAction( 'NL4_PRECIO'	, { |oView| Fis828TOT(oView) } )

Return oView


/*
{Protheus.doc} FISA828PRE() Realiza las pre condiciones de inserción de la rutina

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	lRet - Indica si se tienen los datos necesarios.
*/
Static Function FISA828PRE(oModel)
Local nOpc		:= oModel:GetOperation()
Local lRet		:= .T.
Local cPerg		:= ""
Local cMsg		:= ""
Local nPosTipA	:= 0
Local cCliFor	:= ""
Local cLoja		:= ""
Local lInit828		:= TYPE("lFisa828") == "L" .and. lFisa828

	cMsg := STR0039
	If !TableInDic("NJC") 
		cMsg += " NJC"
		lRet := .F.
	EndIf
	
	If !TableInDic("NL3") 
		cMsg += " NL3"
		lRet := .F.
	EndIf
	
	If !TableInDic("NL4")
	 	cMsg += " NL4"
		lRet := .F.
	EndIf
	
	Iif(!lRet,cMsg += CRLF + STR0040,cMsg := STR0040)
	If !(SB1->(ColumnPos("B1_CODESP")) > 0)
		cMsg += " B1_CODESP"
		lRet := .F.
	EndIF
	
	If !(SD1->(ColumnPos("D1_LIQGR")) > 0)
		cMsg += " D1_LIQGR"
		lRet := .F.
	EndIf
	
	If !(SD2->(ColumnPos("D2_LIQGR")) > 0)
		cMsg += " D2_LIQGR"
		lRet := .F.
	EndIf
	
	If !lRet
		oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0038, cMsg)
		Return lRet
	EndIf
	lLimGrid := .F.
	aDatosLiq	:= {}
	aDtosLiqF	:= {"","","","","",STOD("//"),"","",""}
	aReten		:= {{},{},{},{},{}}
	//oModel	:= FWModelActive()
	oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .F. )	
	If nOpc == MODEL_OPERATION_INSERT
		oModel:GetModel( 'NL3_DETAIL' ):SetNoInsertLine( .F. )
	    oModel:GetModel( 'NL3_DETAIL' ):SetNoUpdateLine( .F. )
	    oModel:GetModel( 'NL3_DETAIL' ):SetNoDeleteLine( .F. )
		cEspecie	:= ""
		cLiquid		:= ""
	 	cTipLiq		:= ""
	 	cCliFor		:= ""
	 	cLoja		:= ""
	 	aDatosLiq	:= {} 
		
		If lInit828
			If Pergunte("FISA828",.T.)
				cEspecie 	:= AllTrim(STR(MV_PAR01))
				cLiquid		:= AllTrim(STR(MV_PAR02))
				cTipLiq		:= AllTrim(STR(MV_PAR03))
	
				If cEspecie == "2" .and. cLiquid == "1" 
					lRet := .F.
					oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0033, STR0035)
				Else
					Iif(cEspecie == "1", cPerg := "FISA828A",cPerg := "FISA828B")
					If Pergunte(cPerg,.T.)
						cCliFor 	:= MV_PAR01
						cLoja		:= MV_PAR02
						aDatosLiq := FIS828Rem(cCliFor, cLoja)
						If ValType(aDatosLiq) == "U" .Or. Len(aDatosLiq) == 0
							lRet := .F.
							oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0029, STR0030)
						EndIf
					Else
						lRet := .F.
						oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0029, STR0030)   
					EndIf
				EndIf
				If lRet //.and. (cTipLiq == "1" .Or. cTipLiq == "2") 
					lCreaReg := .T.
				EndIf
			Else
				lRet := .F.
				oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0029, STR0030)   
			EndIf
		EndIf
	ElseIf nOpc == MODEL_OPERATION_UPDATE	
		If Alltrim(NJC->NJC_STATUS) $ "AC|AN|2|3"
			lRet := .F.
			oModel:SetErrorMessage('', '' , '' , '' , STR0032,STR0065,STR0066)   
		EndIf
		cEspecie 	:= NJC->NJC_ESPLIQ
		cLiquid		:= NJC->NJC_TPLIQ
		cTipLiq		:= NJC->NJC_TIPO
		If NJC->NJC_LIQ == "2"
			oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .T. )
		    oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .T. )
		EndIf
	ElseIf nOpc == MODEL_OPERATION_DELETE
		If Alltrim(NJC_STATUS) $ "AC|AN|2|3"
			lRet := .F.
			oModel:SetErrorMessage('', '' , '' , '' , STR0032,STR0069,STR0066)   
		EndIf
	ElseIf nOpc == MODEL_OPERATION_VIEW
		cEspecie 	:= NJC->NJC_ESPLIQ
		cLiquid		:= NJC->NJC_TPLIQ
		cTipLiq		:= NJC->NJC_TIPO
	EndIf
	
	If (nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE) .and. cTipLiq == "1"
		oModel:GetModel( 'NL3_DETAIL' ):SetNoInsertLine( .T. )
	    oModel:GetModel( 'NL3_DETAIL' ):SetNoUpdateLine( .T. )
	EndIf
	
	nPosTipA := aScan(oModel:GetModel( 'NL4_DETAIL' ):oFormmodelstruct:aFields,{|x| x[3] == "NL4_TIPAJU"})
	If nPosTipA > 0
		oModel:GetModel( 'NL4_DETAIL' ):oFormmodelstruct:aFields[nPosTipA][10] := cTipLiq == "2"
	EndIf
	


Return lRet


/*
{Protheus.doc} FIS828Rem() Realiza las pre condiciones de inserción de la rutina

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	aRet - Regresa arreglo con los datos para realizar la inclusión
*/
Static Function FIS828Rem(cCliFor, cLoja)
Local cAliasSD	:= ""
Local cOrdem	:= 0
Local cSeek  	:= ""
Local cWhile    := ""
Local aCposRem	:= {}
Local cCondicao	:= ""
Local aRetRem	:= {}
Local aRet		:= {}
Local aAreaSA	:= {}
Local aAreaSB1	:= SB1->(GetArea())
Local cCondi	:= ""
Local lInit828		:= TYPE("lFisa828") == "L" .and. lFisa828

Default cCliFor := ""
Default cLoja 	:= ""

	If lInit828
		If cTipLiq == "1" .Or. cTipLiq == "3" //Parciales y totales muestran remitos con el campo D1_LIQGR = 0
			cCondi := "0"
		ElseIf cTipLiq == "2" //Finales muestran remitos con el campo D1_LIQGR = 0
			cCondi := "1"
		EndIf
		
		If cEspecie == "1"
			cOrdem		:= 10
			cAliasSD	:= "SD1"
			cSeek		:= "'" + xFilial('SD1')+cCliFor+cLoja + "'"
			cWhile		:= "!EOF() .AND. SD1->D1_FILIAL+SD1->D1_FORNECE+SD1->D1_LOJA== " + cSeek
			aCposRem 	:= {"D1_COELQ","D1_DOC", "D1_SERIE", "D1_FORNECE", "D1_LOJA", "D1_ITEM","D1_COD", "D1_QUANT", "D1_VUNIT", "D1_TOTAL",  "D1_TES", "D1_PROVENT","D1_EMISSAO", "D1_DTDIGIT", "D1_COMIS1", "D1_DESPESA" }
			cCondicao	:= "AllTrim(D1_ESPECIE) == 'RCN' .and. D1_LIQGR == '" + cCondi +"'"
			If cTipLiq == "2"
				cCondicao	:= cCondicao + " .and. !Empty(D1_COELQ)"
			EndIf
			If cLiquid == "1" .and. cCondi == "0"  //El COE tiene que estar vacio para realizar liquidaciones primarias y totales.
				cCondicao	+= " .and. Empty(D1_COELQ)"
			EndIf
			If SD1->(ColumnPos("D1_TPLIQ")) > 0
				cCondicao	+= " .and. D1_TPLIQ == '" + cLiquid  + "'" // Indica 1. Primaria, 2. Secundaria
			EndIf
		Else
			cOrdem		:= 9
			cAliasSD	:= "SD2"
			cSeek		:= "'" + xFilial('SD2')+cCliFor+cLoja + "'"
			cWhile		:= "!EOF() .AND. SD2->D2_FILIAL+SD2->D2_CLIENTE+SD2->D2_LOJA== " + cSeek
			aCposRem 	:= {"D2_COELQ","D2_DOC", "D2_SERIE", "D2_CLIENTE", "D2_LOJA", "D2_ITEM","D2_COD", "D2_QUANT", "D2_PRCVEN", "D2_TOTAL", "D2_TES", "D2_PROVENT", "D2_EMISSAO", "D2_DTDIGIT", "D2_COMIS1", "D2_DESPESA" }
			cCondicao	:= "AllTrim(D2_ESPECIE) == 'RFN' .and. D2_LIQGR == '" + cCondi +"'"
			If cCondi == "0" //El COE tiene que estar vacio para realizar liquidaciones primarias y totales.
				cCondicao	+= " .and. Empty(D2_COELQ)"
			EndIf
			If cTipLiq == "2"
				cCondicao	:= cCondicao + " .and. !Empty(D2_COELQ)"
			EndIf
		EndIf
	


		aRetRem := LocxF4(cAliasSD, cOrdem, cWhile, cSeek, aCposRem, ,STR0031 , cCondicao, .T., , , , ,.F. ,.F. ,.F.)
	
	
		If ValType(aRetRem) == "A" .and. Len(aRetRem)>0 .and. Len(aRetRem[2])>0
			aRet	:= aClone(aRetRem[2][1])
			nRecno	:= aRetRem[3][1]
		EndIf
	Else
		//Rutina Automatica
		aRet = F828RemAut()
	EndIf
	
	If Len(aRet)>0
		
		If cTipLiq == "2"
			FIS828GVal(aRet[_CLIFOR], aRet[_LOJA], aRet[_DOC], aRet[_ITEM], aRet[_QUANT])
		EndIf
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
		If SB1->(MsSeek(xFilial("SB1")+aRet[_COD]))
			AADD(aRet,SB1->B1_DESC)
			AADD(aRet,SB1->B1_CODESP )
			If !Empty(SB1->B1_CODESP)
				SX5->(DBSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
				SX5->(MsSeek(xFilial("SX5")+"SU"+SB1->B1_CODESP))
				AADD(aRet,IIf(SX5->(Found()),Trim(X5Descri()),"    "))
			Else
				AADD(aRet,"")
			EndIf
		Else
			AADD(aRet,"")
			AADD(aRet,"")
			AADD(aRet,"")
		EndIf
		
		
		If cEspecie == "1"
			aAreaSA := SA2->(GetArea())
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			If SA2->(MsSeek(xFilial("SA2")+aRet[_CLIFOR]+aRet[_LOJA]))
				AADD(aRet,SA2->A2_NOME)
				AADD(aRet,SA2->A2_CGC)
				AADD(aRet,SA2->A2_NROIB)
				AADD(aRet,SA2->A2_NATUREZ)
				AADD(aRet,SA2->A2_COND)
			Else
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
			EndIf
		Else
			aAreaSA := SA1->(GetArea())
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If SA1->(MsSeek(xFilial("SA1")+aRet[_CLIFOR]+aRet[_LOJA]))
				AADD(aRet,SA1->A1_NOME)
				AADD(aRet,SA1->A1_CGC)
				AADD(aRet,SA1->A1_NROIB)
				AADD(aRet,SA1->A1_NATUREZ)
				AADD(aRet,SA1->A1_COND)
			Else
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
				AADD(aRet,"")
			EndIf
		EndIf
		RestArea(aAreaSB1)
		RestArea(aAreaSA)
	EndIf


Return aRet

Static Function F828RemAut()
Local oModel 	:= FWModelActive()
Local oGridNJC	:= oModel:getModel("NJC_MASTER")
Local aRet		:= {}
Local cClifor	:= ""
Local cLoja		:= ""
Local cRemito	:= ""
Local cSerie	:= ""
	
	
	cTipLiq 	:= oModel:GetValue( 'NJC_MASTER', 'NJC_TIPO' )
	cEspecie 	:= oModel:GetValue( 'NJC_MASTER', 'NJC_ESPLIQ' )
	cLiquid		:= oModel:GetValue( 'NJC_MASTER', 'NJC_TPLIQ' )
	cRemito		:= oModel:GetValue( 'NJC_MASTER', 'NJC_REMITO' )
	cSerie		:= oModel:GetValue( 'NJC_MASTER', 'NJC_SERREM' )
	
	If cEspecie == "1"
		cClifor := oModel:GetValue( 'NJC_MASTER', 'NJC_VENDED' )
		cLoja	:= oModel:GetValue( 'NJC_MASTER', 'NJC_LOJAVE' )
		SD1->(dbSetOrder(1))
		If SD1->(dBSeek(xfilial('SD1')+cRemito+cSerie+cClifor+cLoja))
			aRet 	:= {SD1->D1_COELQ, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_ITEM, SD1->D1_COD, SD1->D1_QUANT, SD1->D1_VUNIT, SD1->D1_TOTAL, SD1->D1_TES, SD1->D1_PROVENT, SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SD1->D1_COMIS1, SD1->D1_DESPESA }
			nRecno	:= (SD1->(Recno()))
		EndIf
	elseIf cEspecie == "2"
		cClifor := oModel:GetValue( 'NJC_MASTER', 'NJC_CODPRO' )
		cLoja	:= oModel:GetValue( 'NJC_MASTER', 'NJC_TIENDA' )
		SD2->(dbSetOrder(3))
		If SD2->(dBSeek(xfilial('SD2')+cRemito+cSerie+cClifor+cLoja))
			aRet 	:= {SD2->D2_COELQ, SD2->D2_DOC, SD2->D2_SERIE, SD2->D2_CLIENTE, SD2->D2_LOJA, SD2->D2_ITEM, SD2->D2_COD, SD2->D2_QUANT, SD2->D2_PRCVEN, SD2->D2_TOTAL, SD2->D2_TES, SD2->D2_PROVENT, SD2->D2_EMISSAO, SD2->D2_DTDIGIT, SD2->D2_COMIS1, SD2->D2_DESPESA }
			nRecno	:= (SD2->(Recno()))
		EndIf
	EndIf

Return aRet


/*
{Protheus.doc} FIS828GVal() Si es una preliquidación final se busca el valor ya pagado.

@Author     Raul Ortiz
@Since      
@Project    AGRO - Argentina
@Return 	cValor - Regresa diferencia pendiente por pagar
*/
Static Function FIS828GVal(cCliPro, cLoja, cRemito, cItem, cValor)
Local aAreaNJC	:= NJC->(GetArea())

	DbSelectArea("NJC")
	If cEspecie == "2"
		NJC->(DbSetOrder(2)) // NJC_FILIAL+NJC_CODPRO+NJC_TIENDA+NJC_REMITO+NJC_ITREM
	Else
		NJC->(DbSetOrder(3)) //NJC_FILIAL+NJC_VENDED+NJC_LOJAVE+NJC_REMITO+NJC_ITREM
	EndIf
	If NJC->(MsSeek(xFilial("NJC")+cCliPro+cLoja+cRemito+cItem))
		//cValor 		:= cValor - NJC->NJC_PESSCE
		aDtosLiqF	:= {NJC->NJC_PTOEMI,NJC->NJC_CODCTR,NJC->NJC_PROPRO,NJC->NJC_PROVEN,NJC->NJC_PROVOR,NJC->NJC_DATAFP, NJC->NJC_PORTO, NJC->NJC_NOMEPO, NJC->NJC_CODPGO, NJC->NJC_OPERAC, NJC->NJC_TROCA, NJC->NJC_ACTCOR, NJC->NJC_LIQCOR, NJC->NJC_CORRED, NJC->NJC_LOJCOR, NJC->NJC_CUITCR, NJC->NJC_NOMCOR, NJC->NJC_NOIBCR }
	EndIf

	RestArea(aAreaNJC)
Return

/*
{Protheus.doc} FIS828PREV() Se detona en las prevalidaciones, se usa para crear las lineas iniciales en la inserción.

@Author     Raul Ortiz
@Since      
@Project    AGRO - Argentina
@Return 	lRet - Regresa un True
*/
Static Function FIS828PREV(oModel)
Local lRet		:= .T.

	If lCreaReg
		FIS828INL4(oModel) //Creación de linea iniciales
	EndIf

Return lRet

/*
{Protheus.doc} FIS828INL4() Crea las lineas iniciales en la inserción.

@Author     Raul Ortiz
@Since      
@Project    AGRO - Argentina
@Return 	lRet - Regresa un True
*/
Static Function FIS828INL4(oModel)
Local oModelNL4 := oModel:GetModel( 'NL4_DETAIL' )
Local oModel	:= FWModelActive()
Local aAreaFR8	:= FR8->(GetArea())	
Local aAreaSF4	:= SF4->(GetArea())	
Local nNum		:= 1
Local nImportCa	:= 0
Local nImportCo	:= 0
Local cTes		:= ""
Local nQtd		:= 0
Local nVlUnit	:= 0
Local nVlTot	:= 0

	DbSelectArea("FR8") 
	FR8->(DbSetOrder(1)) //FR8_FILIAL+FR8_CODIGO
	If aDatosLiq[_COMISION] > 0
		If (cTipLiq == "1" .or. cTipLiq == "3") 
			oModelNL4:loadValue('NL4_CODLIQ',M->NJC_CODLIQ)
			oModelNL4:loadValue('NL4_ITEM'  ,StrZero(nNum,TamSx3("NL4_ITEM")[1]))
			FR8->(DbGotop())
			While FR8->(!Eof())
				If FR8_TIPOOP == "1" .and.;
					(( cEspecie == "1" .and. ((cTipLiq == "1" .or. cTipLiq == "3") .and. FR8->FR8_TIPOE == "2")) .or.; //Si la especie es a pagar , si la preliquidación es parcial se busca una deducción,
				 	( cEspecie == "2" .and. (cTipLiq == "1" .and. FR8->FR8_TIPO == "2") .or. (cTipLiq == "3" .and. FR8->FR8_TIPO == "1"))) //Si la especie es a recibir, si la preliquidación es parcial se busca una deducción, si es total como operación
					oModelNL4:SetValue('NL4_TIPDED',AllTrim(FR8->FR8_CODIGO))
					oModelNL4:loadValue("NL4_DESC",FR8->FR8_DESC)
					If cEspecie == "1"
						cTes := FR8->FR8_TESE
						oModelNL4:loadValue("NL4_TIPO",FR8->FR8_TIPOE)
					ElseIf cEspecie == "2"
						cTes := FR8->FR8_TES
						oModelNL4:loadValue("NL4_TIPO",FR8->FR8_TIPO)
					EndIf
					If !Empty(cTes)
						oModelNL4:loadValue("NL4_CODTES",cTes)
						If SF4->(MsSeek(xFilial("SF4")+cTes))
							oModelNL4:loadValue("NL4_DESTES",SF4->F4_TEXTO)
						EndIf
					EndIf
					Exit
				EndIf
				FR8->(DbSkip())
			Enddo
			
			nImportCo 	:= (aDatosLiq[_QUANT] * aDatosLiq[_VALUNIT]) * (aDatosLiq[_COMISION]/100)
			nQtd		:= aDatosLiq[_QUANT]
			nVlUnit		:= ROUND(nImportCo/nQtd,MsDecimais(1))
			nVlTot		:= ROUND(nQtd * nVlUnit,MsDecimais(1))
			
			oModelNL4:loadValue("NL4_PORCEN",aDatosLiq[_COMISION])
			oModelNL4:loadValue("NL4_QUANT" ,nQtd)
			oModelNL4:loadValue("NL4_PRECIO",nVlUnit)
			oModelNL4:SetValue("NL4_IMPORT",nVlTot)
			nNum += 1
		EndIf
	EndIf
	
	If aDatosLiq[_CALIDAD] > 0
		If (cEspecie == "1" .and. cLiquid == "1" .and. (cTipLiq == "1" .or. cTipLiq == "2")) .Or. (cEspecie == "2" .and. (cTipLiq == "1" .Or. cTipLiq == "2"))
			If nNum > 1
				oModelNL4:AddLine()
			EndIf
			oModelNL4:loadValue('NL4_CODLIQ',M->NJC_CODLIQ)
			oModelNL4:loadValue('NL4_ITEM'  ,StrZero(nNum,TamSx3("NL4_ITEM")[1]))
			FR8->(DbGotop())
			While FR8->(!Eof())
				If FR8_TIPOOP == "2" .and.; 
					(( cEspecie == "1" .and. cLiquid == "1" .and. ((cTipLiq == "1" .and. FR8->FR8_TIPOE == "2" ) .or. (cTipLiq == "2" .and. FR8->FR8_TIPOE == "1"))) .or.; //Si la especie es a pagar (LPG), si la preliquidación es parcial se buscar una deducción, si es final una operación
					( cEspecie == "2" .and. (cTipLiq == "1" .and. FR8->FR8_TIPO == "2") .Or. (cTipLiq == "2" .and. FR8->FR8_TIPO == "1"))) //LSG parcial, busca el rgistro como deducción, si es final como operación
					//( cEspecie == "1" .and. cLiquid == "2"  .and. ((cTipLiq == "1" .and. FR8->FR8_TIPOE == "2" )))  //Si la especie es a pagar(LSG), si la preliquidación es parcial se buscar una deducción, si es final una operación
				 	//( cEspecie == "2" .and. ((cTipLiq == "1" .and. FR8->FR8_TIPO == "2" ) .or. (cTipLiq == "2" .and. FR8->FR8_TIPO == "1"))) //Si la especie es a recibir, si la preliquidación es parcial se buscar una deducción, si es final una operación
					cTes := ""
					oModelNL4:SetValue('NL4_TIPDED',AllTrim(FR8->FR8_CODIGO))
					oModelNL4:loadValue("NL4_DESC",FR8->FR8_DESC)
					If cEspecie == "1"
						cTes := FR8->FR8_TESE
						oModelNL4:loadValue("NL4_TIPO",FR8->FR8_TIPOE)
					ElseIf cEspecie == "2"
						cTes := FR8->FR8_TES
						oModelNL4:loadValue("NL4_TIPO",FR8->FR8_TIPO)
					EndIf
					If !Empty(cTes)
						oModelNL4:loadValue("NL4_CODTES",cTes)
						If SF4->(MsSeek(xFilial("SF4")+cTes))
							oModelNL4:loadValue("NL4_DESTES",SF4->F4_TEXTO)
						EndIf
					EndIf
					If cTipLiq == "2"
						If NL4->(ColumnPos("NL4_TIPAJU")) > 0
							oModelNL4:loadValue("NL4_TIPAJU","1")
						EndIf
					EndIf
					Exit
				EndIf
				FR8->(DbSkip())
			Enddo
				
			nImportCa 	:= (aDatosLiq[_QUANT] * aDatosLiq[_VALUNIT]) * (aDatosLiq[_CALIDAD]/100)
			nQtd		:= aDatosLiq[_QUANT]
			nVlUnit		:= ROUND(nImportCa/nQtd,MsDecimais(1))
			nVlTot		:= ROUND(nQtd * nVlUnit,MsDecimais(1))
			
			oModelNL4:loadValue("NL4_PORCEN",aDatosLiq[_CALIDAD])
			oModelNL4:loadValue("NL4_QUANT" ,nQtd)
			oModelNL4:loadValue("NL4_PRECIO",nVlUnit)
			oModelNL4:SetValue("NL4_IMPORT",nVlTot)
		EndIf
	EndIf
		
	lCreaReg := .F.
		
	RestArea(aAreaFR8)
	RestArea(aAreaSF4)

Return 

/*
{Protheus.doc} Fis828Vl() Verificar que sea operación Insert

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	xValue - Valor a asignar
*/
Static Function Fis828Vl(oModel,cVal)
Local nOperation	:= oModel:GetOperation()
Local xValue		:= ""		

	If nOperation == MODEL_OPERATION_INSERT
		xValue	:= cVal
	EndIf


Return xValue

/*
{Protheus.doc} F828ACNL4()
Validación para el campo NJC_PRECO y NJC_PESSCE para activar o desactivar el grid de Operaciones/Deducciones 
@Author     Alfredo Medrano
@Since      06/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 lRet 
*/
Static Function F828ACNL4(oModel,cCampo)

	Local cCodCert	:= ""
	Local oModel		:= FWModelActive()
	Local nPrec		:= 0
	Local nPess		:= 0
	local lRet 		:= .T.
	
	Default	cCampo	:= ""
	
	nPrec		:= oModel:GetValue("NJC_MASTER","NJC_PRECO")
	nPess		:= oModel:GetValue("NJC_MASTER","NJC_PESSCE")
	cCodCert	:= oModel:GetValue("NL3_DETAIL","NL3_CODCET")
	
	If (Empty(cCodCert) .or. nPess == 0)  .and. nPrec == 0
		// 	Deshabilitar Grid
		oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .T. )	
	Else
		// 	Habilitar Grid
		oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .F. )
		oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .F. )
		
		oModel:LoadValue("NL4_DETAIL","NL4_CODLIQ",M->NJC_CODLIQ)
	EndIf
	
	If cCampo == "NJC_PRECO" //.and. (cTipLiq == "2" .Or. cTipLiq == "3")
		lRet := .F.
	EndIf
	
Return lRet

/*
{Protheus.doc} F828ACNL3(oModel)
conversion de toneladas a Kg para mostra en los totalizadores
@Author     Alfredo Medrano
@Since      16/11/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 lRet 
*/
Static Function F828ACNL3(oModel)

	Local oModel		:= FWModelActive()
	
	If oModel:GetValue("NJC_MASTER","NJC_INFCER") == '1'
		lRet:= .F.
	EndIf

Return lRet

/*
{Protheus.doc} F828DLNJ3()
Validación para el campo NJC_INFCER elimina los registros del grid de Certificado de depósito si  no informa Certificado.
@Author     Alfredo Medrano
@Since      11/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 .T.
*/
Static Function F828DLNJ3(oModel)
	
	Local oModel 		:= FWModelActive()
	Local oModelNL3 	:= oModel:GetModel( 'NL3_DETAIL' )
	Local oView 		:= FWViewActive() // obtiene el View activo
	Local nI 			:= 0
	Local cInfCer		:= 0
	Local nBanDel		:= 0
	Local aSaveLines := FWSaveRows()
	
	For nI := 1 To oModelNL3:Length()
		oModelNL3:GoLine( nI )
		If !oModelNL3:IsDeleted()
			nBanDel++
		EndIf
	Next
	
	cInfCer := oModel:GetValue("NJC_MASTER","NJC_INFCER")
	If cInfCer == '2' .AND. oModelNL3:Length() > 0 .AND. nBanDel > 0
		IF MSGYESNO(STR0021, fDesCam('NJC_INFCER'))//Al cambiar esta opción los registros contenidos en Certificados de Depósito serán eliminados. Desea continuar?
			For nI := 1 To oModelNL3:Length()
				oModelNL3:GoLine( nI )
				If !oModelNL3:IsDeleted()
					oModelNL3:DeleteLine()
				EndIf
			Next
			oModel:GetModel( 'NL3_DETAIL' ):SetNoDeleteLine( .T. )
		Else
			oModel:getModel('NJC_MASTER'):SetValue('NJC_INFCER' ,"1")
			oModel:GetModel( 'NL3_DETAIL' ):SetNoDeleteLine( .F. )
		EndIf
	Else
		oModel:GetModel( 'NL3_DETAIL' ):SetNoDeleteLine( .F. )
		//oModel:getModel('NJC_MASTER'):LoadValue('NJC_PESSCE' ,0)
	Endif
	FWRestRows( aSaveLines )
	//oView:Refresh()
Return .T.  

/*
{Protheus.doc} F828VALL4(oModel)
conversion de toneladas a Kg para mostra en los totalizadores al 
salir dle campo NJC_PESSCE
@Author     Alfredo Medrano
@Since      16/11/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 lRet 
*/
Static Function F828VALL4(oModel)

Local oModel		:= FWModelActive()
Local oView 		:= FWViewActive() 
local lRet 		:= .T.
Local nRet		:= 0
Local nPreco		:= oModel:GetValue( 'NJC_MASTER', 'NJC_PRECO' )// Precio Referencia en Toneladas
Local nPess		:= oModel:GetValue("NJC_MASTER","NJC_PESSCE") // peso neto en Kg a liquidar
	
	//  1 Kg = 0.001 toneladas
	nPess := nPess * 0.001  // valor en toneladas
	nRet	:= nPreco * nPess  //costo $ total
	
Return lRet

/*
{Protheus.doc} F828NJCTES() valida los rangos de TES que pueden ser utilizados en la tabla NJC

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function F828NJCTES(oModel)
Local oModel 		:= FWModelActive()
Local cCodTes		:= ""
Local lRet			:= .F.

	cCodTes := oModel:GetValue("NJC_MASTER","NJC_TES")
	
	If cEspecie == "1"
		lRet := IIF(VAL(LEFT(cCodTes,1))<5 ,.T.,.F.)
	ElseIf cEspecie == "2"
		lRet := IIF(VAL(LEFT(cCodTes,1))>=5 ,.T.,.F.)
	EndIf

Return lRet

/*
{Protheus.doc} F828NL4TES() valida los rangos de TES que pueden ser utilizados en la tabla NL4

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function F828NL4TES(oModel)
Local oModel 		:= FWModelActive()
Local cCodTes		:= ""
Local cTipo			:= ""
Local lRet			:= .F.

	cCodTes := oModel:GetValue("NL4_DETAIL","NL4_CODTES")
	cTipo 	:= oModel:GetValue("NL4_DETAIL","NL4_TIPO")
	
	If (cEspecie == "1" .and. cTipo == "1") .or. (cEspecie == "2" .and. cTipo == "2")
		lRet := IIF(VAL(LEFT(cCodTes,1))<5 ,.T.,.F.)
	ElseIf (cEspecie == "1" .and. cTipo == "2") .or. (cEspecie == "2" .and. cTipo == "1")
		lRet := IIF(VAL(LEFT(cCodTes,1))>=5 ,.T.,.F.)
	EndIf

Return lRet

/*
{Protheus.doc} F828NL3PRE()
Función que identifica si se a borrado una linea del Grid de Certificados de Deposito (para control de los registros borrados)
@Author     Alfredo Medrano
@Since      03/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		lRet
*/
Static Function F828NL3PRE(oModelGrid,nLine,cAction)	
Local lRet			:= .T.
Local oModel		:= oModelGrid:GetModel()
Local nOperation	:= oModelGrid:GetOperation()
Local nPosBs		:= 0
	
	oModelGrid:GoLine( nLine )
	If cAction == 'DELETE' //.AND. !oModelGrid:IsInserted() 
		
		If aScan(_aGrdM,{|x| x == nLine}) <= 0
			aAdd(_aGrdM, nLine)
		EndIf
		
	EndIf	
	If cAction == 'UNDELETE'
		nPosBs	:= aScan(_aGrdM,{|x| x == nLine})
		If nPosBs > 0 
			ADEL(_aGrdM,nPosBs)
		EndIf
	EndIf
	
	If cAction == 'CANSETVALUE'
		nPosBs	:= aScan(_aGrdM,{|x| x == nLine})
		If nPosBs > 0 
			ADEL(_aGrdM,nPosBs)
		EndIf
	EndIf	
Return lRet

/*
{Protheus.doc} F828NL4PRE()
Función que identifica si se a borrado una linea del Grid de Operaciones/Deducciones (para control de los registros borrados)
@Author     Alfredo Medrano
@Since      03/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		lRet
*/
Static Function F828NL4PRE(oModelGrid,nLine,cAction)	
Local lRet			:= .T.
Local oModel		:= oModelGrid:GetModel()
Local nPosBs		:= 0
	
	oModelGrid:GoLine( nLine )
	If cAction == 'DELETE' //.AND. !oModelGrid:IsInserted() 
		If aScan(_aGrdP,{|x| x == nLine}) <= 0
			aAdd(_aGrdP, nLine)
		EndIf
		
	EndIf	
	If cAction == 'UNDELETE'
		nPosBs	:= aScan(_aGrdP,{|x| x == nLine})
		If nPosBs > 0 
			ADEL(_aGrdP,nPosBs)
		EndIf
	EndIf	
	
	If cAction == 'CANSETVALUE'
		nPosBs	:= aScan(_aGrdP,{|x| x == nLine})
		If nPosBs > 0 
			ADEL(_aGrdP,nPosBs)
		EndIf
	EndIf	
Return lRet

/*
{Protheus.doc} FIS828POS()

Función para revisar que en NL4 la primer línea sea tipo operación o exista al menos 

@Author     Mayra Camargo
@Since      14/08/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		lRet
*/
Static Function FIS828POS(oModelGrid,nLine)
Local lRet			:= .T.	
Local oModel		:= oModelGrid:GetModel()
Local nOperation	:= oModel:GetOperation()
Local cTipo			:= ""
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		cTipo := oModelGrid:getValue("NL4_TIPO")
		If nLine == 1 .and. cTipo <> "1"
			HELP(" ",1,"FISA828UPD",,STR0019 ,1,0) // "El primer item debe ser de tipo Operacón, verifique los datos."
			lRet := .F.
		ElseIf nLine <> 1 .and. cTipo == "1"
			HELP(" ",1,"FISA828UPD",,STR0020 ,1,0) // "El solo primer item debe ser de tipo Operacón, verifique los datos."
			lRet := .F.
		EndIf		
	EndIf
		
Return lRet

/*
{Protheus.doc} fGridImp()
fuención que visualiza el pie de pagina (sección de Impuestos) del formulario.
@Author     Alfredo Medrano
@Since      05/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 Nil
*/
static Function fGridImp(oPanel)
Local cPictBas	:= PesqPict("NL4","NL4_BASIM1")
Local cPictVal	:= PesqPict("NL4","NL4_VALIM1")
Local aCabec	:= {STR0052,STR0053, STR0054, STR0056}
Local oModel 	:= FWModelActive()
Local oGridNJC	:= oModel:getModel("NJC_MASTER")
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
	
	aItemsI := {}
	FIS828GImp() //Llamada de lectura de impuestos 
	If Len(aItemsI) == 0
		AADD(aItemsI,{"","","",""})
		lLimGrid := .F.
	Else
		AEval( aItemsI, { | x | x[3] := AllTrim(Transform(x[3],cPictBas)), x[4] := AllTrim(Transform(x[4],cPictVal)) } )
		lLimGrid := .T.
	EndIf
				
	oLbxI := TWBrowse():New(5,5,580,50,,aCabec,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
	oLbxI:SetArray( aItemsI ) 
	oLbxI:bLine := {|| aEval(aItemsI[oLbxI:nAt],{|z,w| aItemsI[oLbxI:nAt,w] } ) }
		
Return NIL

/*
{Protheus.doc} fGridRet()
fuención que visualiza el pie de pagina (sección de Impuestos) del formulario.
@Author     Alfredo Medrano
@Since      05/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 Nil
*/
static Function fGridRet(oPanel)
Local aCabec		:= {STR0052, STR0053, STR0054, STR0055, STR0057}
Local cPictBas		:= PesqPict("SFE","FE_VALBASE")
Local cPictAlq		:= PesqPict("SFE","FE_ALIQ")
Local cPictVal		:= PesqPict("SFE","FE_RETENC")

	aItems := {}
	
	If !F828GRet(@aItems)
		AADD(aItems,{" "," ",0,0,0 } )
	EndIf
	AEval( aItems, { | x | x[3] := AllTrim(Transform(x[3],cPictBas)), x[4] := AllTrim(Transform(x[4],cPictAlq)), x[5] := AllTrim(Transform(x[5],cPictVal)) } )
				
	oLbxR := TWBrowse():New(5,5,580,50,,aCabec,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
	oLbxR:SetArray( aItems ) 
	
	oLbxR:bLine := {|| aEval(aItems[oLbxR:nAt],{|z,w| aItems[oLbxR:nAt,w] } ) }
	
		
Return NIL

/*
{Protheus.doc} F828PESTTL()
Função de Calculo Rodapé Peso Total kg.
@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project	AGRO - Argentina
@Return		nRet
*/
Static Function F828PESTTL(oModel)	
Local nRet		:= 0
Local cCertSN	:= oModel:GetValue( 'NJC_MASTER', 'NJC_INFCER' )
Local oGridNL3	:= oModel:GetModel( "NL3_DETAIL")
Local nH
Local aLnGrid	:= {}
Local nPos		:= 0
Local nCls		:= 0

	aLnGrid	:= aClone(oGridNL3:ACols)
	nPos	:= aScan(oGridNL3:aHeader, { |x,y| x[2] == "NL3_PESNET"	} )
	nCls:= Len(aLnGrid)
	
	nRet := oModel:GetValue( 'NJC_MASTER', 'NJC_PESSCE' )
	
Return nRet

/*
{Protheus.doc} F828SUBTTL()
Função de Calculo Rodapé. SubTotal Operación
@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		nRet
*/
Static Function F828SUBTTL(oModel)
Local nRet		:= 0
Local nPreco	:= oModel:GetValue( 'NJC_MASTER', 'NJC_PRECO' )// Precio Referencia en Toneladas
Local nPesTtl	:= oModel:GetValue('TOTAL', 'PESTOT') // suma de peso neto en Kg todos los Certificados de deposito 
Local nPess		:= oModel:GetValue("NJC_MASTER","NJC_PESSCE") // peso neto en Kg a liquidar
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local cTipLiq	:= oModel:GetValue("NJC_MASTER","NJC_TIPO")
Local aLnGrid 	:= {}
Local nPos		:= 0
Local nPosI		:= 0
Local nH		:= 0
	

	If !(cTipLiq == "2")
		nRet	:= nPreco * nPesTtl //costo $ total
	EndIf 
	
	aLnGrid := aClone(oGridNL4:aCols)
	nPos	:= aScan(oGridNL4:aHeader, { |x| x[2] == "NL4_TIPO"	} )
	nPosI   := aScan(oGridNL4:aHeader, { |x| x[2] == "NL4_IMPORT"	} )
		
	For nH := 1 To Len(aLnGrid)
		If !aLnGrid[nH][Len(aLnGrid[nH])]
			If  aLnGrid[nH,nPos] == '1'
				nRet += aLnGrid[nH,nPosI]
			Endif
		EndIf
	Next nH
	
Return nRet

/*
{Protheus.doc} F828TTLOPR()
Função de Calculo Rodapé. Total de operaciones

@Author     Francisco Oliveira
@Since		27/07/2016
@Version	P12.7
@Project    AGRO - Argentina
@Return		nRet
*/
Static Function F828TTLOPR(oModel)	
Local nY		:= 0
Local nH		:= 0
Local nRet		:= 0
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local nPosC 	:= 0
Local aLnGrid 	:= {}
Local nPos		:= 0
Local aDatosNJC	:= {}
Local nPosNJC	:= 0
Local cTipLiq	:= oModel:GetValue("NJC_MASTER","NJC_TIPO")
	
	If !(cTipLiq == "2")
		If Len(aCampX3NJC) == 0
			aCampX3NJC := FIS828GSX3("NJC")
			
		EndIf
		
		If Len(aCampX3NJC) > 0
			aDatosNJC := oModel:GetModel("NJC_MASTER"):aDataModel[1]
			For nY := 1 To Len(aCampX3NJC)
				nPosNJC := aScan(aDatosNJC, { |x| x[1] == aCampX3NJC[nY]	} )
				If nPosNJC > 0
					nRet	+=  aDatosNJC[nPosNJC,2]
				EndIf
			Next nY
		EndIf
	EndIf
	
	If Len(aCampX3) == 0
		aCampX3 := FIS828GSX3("NL4")
	EndIf
	
	If Len(aCampX3) > 0
		aLnGrid := aClone(oGridNL4:aCols)
		nPos := aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_TIPO"	} )
			
		For nH := 1 To Len(aLnGrid)
			If !aLnGrid[nH][Len(aLnGrid[nH])]
				If  aLnGrid[nH,nPos] == '1'
					For nY := 1 To Len(aCampX3)
						nPosC 	:= aScan(oGridNL4:aHeader, { |x,y| x[2] == aCampX3[nY]	} )
						nRet	+=  aLnGrid[nH,nPosC]
					Next nY
				Endif
			EndIf
		Next nH
		
	EndIf
	
Return nRet

/*
{Protheus.doc} F828OPEIVA()
Função de Calculo Rodapé. Total Operación c/IVA

@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828OPEIVA(oModel)
	
	Local nRet		:= 0
	Local nImpIVA	:= oModel:GetValue( 'TOTAL', 'IMPIVA' )
	Local nSubOpe	:= oModel:GetValue( 'TOTAL', 'SUBTOPE' )
	
	nRet	:= nImpIVA + nSubOpe
	
Return nRet


/*
{Protheus.doc} F828TTLDED()
Função de Calculo Rodapé. Total Deducciones
@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828TTLDED(oModel)
Local nY		:= 0
Local nH		:= 0
Local nRet		:= 0
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local nPosC 	:= 0
Local aLnGrid 	:= {}
Local nPosT		:= 0
Local nPosI		:= 0
	
	If Len(aCampX3) == 0
		aCampX3 := FIS828GSX3("NL4")
	EndIf
	
	If Len(aCampX3) > 0
		nRet	:= 0
		aLnGrid := aClone(oGridNL4:ACols)
		nPosT := aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_TIPO"	} )
		nPosI := aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_IMPORT"	} )
		
		For nH := 1 To Len(aLnGrid)
			If !aLnGrid[nH][Len(aLnGrid[nH])] 
				If  aLnGrid[nH,nPosT] == '2'
					nRet += aLnGrid[nH,nPosI]
					For nY := 1 To Len(aCampX3)
						nPosC := aScan(oGridNL4:aHeader, { |x,y| x[2] == aCampX3[nY]	} )
						nRet	+=  aLnGrid[nH,nPosC]
					Next nY
				EndIf	
			EndIf
		Next nH
	EndIf
	
Return nRet

/*
{Protheus.doc} F828RETAFI()
Função de Calculo Rodapé. Total Retenciones AFIP

@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828RETAFI(oModel)
Local oGridNL4:= oModel:GetModel("NL4_DETAIL")
Local nRet	:= 0
	
		nRet := oModel:GetValue("NJC_MASTER","NJC_RETAFI")
	
Return nRet

/*
{Protheus.doc} F828OTRRET()
Função de Calculo Rodapé. Total otras retenciones

@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828OTRRET(oModel)	
Local nRet	:= 0
	
		nRet := oModel:GetValue("NJC_MASTER","NJC_OTRRET")
	
Return nRet
/*
{Protheus.doc} F828IMPNAP()
Função de Calculo Rodapé.Importe neto a pagar

@Author     Francisco Oliveira
@Since     27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828IMPNAP(oModel)
	
	Local nRet		:= 0
	Local nOpeIVA	:= oModel:GetValue( 'TOTAL', 'OPEIVA' )
	Local nTotDed	:= oModel:GetValue( 'TOTAL', 'TTLDED' )
	Local nRetAFI	:= oModel:GetValue( 'TOTAL', 'RETAFI' )
	Local nOtrRet	:= oModel:GetValue( 'TOTAL', 'OTRRET' )
	
	nRet	:= (nOpeIVA - (nTotDed + nRetAFI + nOtrRet))
	
Return nRet

/*
{Protheus.doc} F828IVARG2()
Função de Calculo Rodapé. IVA RG2300

@Author     Francisco Oliveira
@Since		27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		nRet
*/
Static Function F828IVARG2(oModel)	
Local nRet	:= 0
	
		nRet := oModel:GetValue("NJC_MASTER","NJC_IVARG2")
		
Return nRet
/*
{Protheus.doc} F828PAGSCO()

Função de Calculo Rodapé.

@Author     Francisco Oliveira
@Since		27/07/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 nRet
*/
Static Function F828PAGSCO(oModel)
	
	Local nRet		:= 0
	Local nImpNap	:= oModel:GetValue( 'TOTAL', 'IMPNAP' )
	Local nIvaRG2	:= oModel:GetValue( 'TOTAL', 'IVARG2' )
	
	nRet	:= nImpNap - nIvaRG2
	
Return nRet


/*
{Protheus.doc} F828CREDEB() Obtiene la dierencia de operaciones menos deducciones

@Author     Raul Ortiz
@Since      
@Project    AGRO - Argentina
@Return 	nRet - Diferencia entre operaciones y deducciones
*/
Static Function F828CREDEB(oModel)	
Local nY		:= 0
Local nH		:= 0
Local nRet		:= 0
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local nPosC 	:= 0
Local aLnGrid 	:= {}
Local nPosT		:= 0
Local nPosI		:= 0
Local nPosD		:= 0
Local cTipDed	:= 0
Local nPreco	:= oModel:GetValue( 'NJC_MASTER', 'NJC_PRECO' )
Local nPess		:= oModel:GetValue("NJC_MASTER","NJC_PESSCE") 
Local nRetAFI	:= oModel:GetValue( 'TOTAL', 'RETAFI' )
Local nOtrRet	:= oModel:GetValue( 'TOTAL', 'OTRRET' )
Local cTipLiq	:= oModel:GetValue("NJC_MASTER","NJC_TIPO")

	If !(cTipLiq == "2")
		nRet	:= nPreco * nPess
	EndIf
	aLnGrid := aClone(oGridNL4:aCols)
	nPosT 	:= aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_TIPO"	} )
	nPosI 	:= aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_IMPORT"	} )
	nPosD 	:= aScan(oGridNL4:aHeader, { |x,y| x[2] == "NL4_TIPDED"	} )
	DbSelectArea("FR8")
	FR8->(DbSetOrder(1)) //FR8_FILIAL+FR8_CODIGO
	
	
	For nH := 1 To Len(aLnGrid)
		If !aLnGrid[nH][Len(aLnGrid[nH])]
			cTipDed := aLnGrid[nH,nPosD]
			If FR8->(MsSeek(xFilial("FR8")+cTipDed))
				If	FR8->FR8_TIPOOP == "2"
					nRet += aLnGrid[nH,nPosI]
				Else
					If  aLnGrid[nH,nPosT] == '1'
						nRet += aLnGrid[nH,nPosI]
					ElseIf aLnGrid[nH,nPosT] == '2'
						nRet -= aLnGrid[nH,nPosI]
					EndIf
				EndIf
			EndIf
		EndIf
	Next nH
	
	nRet -= (nRetAFI+nOtrRet) 
	
Return nRet

/*
{Protheus.doc} FIS828GSX3() Llena los arreglos con los campos existentes Valimp

@Author     Raul Ortiz
@Since      
@Project    AGRO - Argentina
@Return 	aCampX3 - Arreglo con los campos existentes
*/
Static Function FIS828GSX3(cTab)
Local cCpo		:= cTab + "_VALIM"
Local aCampX3	:= {}

		SX3->(DbSetOrder(1)) 
		SX3->(DbGoTop())
		
		If SX3->(MsSeek(cTab))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cTab
				If SubStr(SX3->X3_CAMPO, 1, 9) == cCpo
					aAdd(aCampX3, SX3->X3_CAMPO )
				EndIf
				SX3->(DbSkip())
			Enddo
		Endif

Return aCampX3

/*
{Protheus.doc} F828ACTNJC()
El grid de Certificado de Depósito se activa  si es = Si  se desactiva si es = No
@Author     Alfredo Medrano
@Since      04/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 .T.
*/
Static Function F828ACTNJC(oView)
	Local cInfCer := ""
	Local oModel 	:= FWModelActive()
	Local oMdlTot:= Nil
	
	cInfCer := oModel:GetValue("NJC_MASTER","NJC_INFCER")
	If cInfCer == '2'
		// 	Deshabilitar Grid
		oModel:GetModel( 'NL3_DETAIL' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'NL3_DETAIL' ):SetNoUpdateLine( .T. )	
	Else
		// 	Habilitar Grid
		oModel:GetModel( 'NL3_DETAIL' ):SetNoInsertLine( .F. )
		oModel:GetModel( 'NL3_DETAIL' ):SetNoUpdateLine( .F. )	
	EndIf
	oMdlTot := oModel:getModel("TOTAL")
	oMdlTot:loadValue("SUBTOPE",0)
	oMdlTot:loadValue("PESTOT",0)
	
	oView:Refresh()
Return 

/*
{Protheus.doc} F828SUBTOP()
Função de Calculo Rodapé. SubTotal Operación al salir del campo NJC_PRECO
@Author     Alfredo Medrano
@Since     11/11/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return		nRet
*/
Static Function F828SUBTOP(oView)
	
	Local nRet		:= 0
	//Local oView := FwViewActive()
	Local oModel:= FWModelActive()
	Local oModTotal:= oModel:getmodel('TOTAL')
	Local nPreco	:= oModel:GetValue( 'NJC_MASTER', 'NJC_PRECO' )
	Local nPesTtl	:= oModTotal:GetValue( 'PESTOT')
	
	//  1 Kg = 0.001 toneladas
	nPesTtl := nPesTtl * 0.001 // valor en toneladas
	nRet	:= nPreco * nPesTtl //costo $ total
	oModTotal:loadValue("SUBTOPE",nRet)
	oView:Refresh()
	
Return .T.

/*
{Protheus.doc} Fis828Loj() llena los campos correspondientes al corredor

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828Loj(oView)
Local oModel 		:= FWModelActive()
Local oMdlNJC		:= Nil
Local aAreaA2		:= SA2->(GetArea())	
Local cCorr			:= ""
Local cLoja			:= ""

Default oView		:= Nil

	cCorr := oModel:GetValue("NJC_MASTER","NJC_CORRED")
	cLoja := oModel:GetValue("NJC_MASTER","NJC_LOJCOR")
	oMdlNJC := oModel:getModel("NJC_MASTER")
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	
	If SA2->(MsSeek(xFilial("SA2")+cCorr+cLoja))
		oMdlNJC:loadValue("NJC_CUITCR",AllTrim(SA2->A2_CGC))
		oMdlNJC:loadValue("NJC_NOMCOR",SA2->A2_NOME)
		oMdlNJC:loadValue("NJC_NOIBCR",SA2->A2_NROIB)
	EndIf
	
	RestArea(aAreaA2)
	If oView <> Nil
		oView:Refresh()
	EndIf
Return

/*
{Protheus.doc} Fis828Por() llena el dato del puerto

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828Por(oView)
Local oModel 		:= FWModelActive()
Local oMdlNJC		:= Nil
Local aAreaX5		:= SX5->(GetArea())	
Local cPorto		:= ""

Default oView		:= Nil

	cPorto := oModel:GetValue("NJC_MASTER","NJC_PORTO")
	oMdlNJC := oModel:getModel("NJC_MASTER")
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
	
		SX5->(MsSeek(xFilial("SX5")+"U5"+cPorto))
		oMdlNJC:loadValue("NJC_NOMEPO",IIf(SX5->(Found()),Trim(X5Descri()),""))
	
	RestArea(aAreaX5)
	If oView <> Nil
		oView:Refresh()
	EndIf
Return

/*
{Protheus.doc} Fis828Tes() llena el dato de la descipción de la TES

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828TesE(oView)
Local oModel 		:= FWModelActive()
Local oMdlNJC		:= Nil

	oMdlNJC := oModel:getModel("NJC_MASTER")

	oView:Refresh()
Return

/*
{Protheus.doc} Fis828Tes() llena el dato de la descipción de la TES

@Author     Raul Ortiz
@Since      01/04/2020
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828Tes(oView)
Local oModel 		:= FWModelActive()
Local oMdlNL4		:= Nil
Local aAreaF4		:= SF4->(GetArea())	
Local cCodTes		:= ""

	cCodTes := oModel:GetValue("NL4_DETAIL","NL4_CODTES")
	oMdlNL4 := oModel:getModel("NL4_DETAIL")
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
	
	If SF4->(MsSeek(xFilial("SF4")+cCodTes))
		oMdlNL4:loadValue("NL4_DESTES",SF4->F4_TEXTO)
	EndIf
	
	RestArea(aAreaF4)
	oView:Refresh()
Return

/*
{Protheus.doc} Fis828TOP() llena los datos correspondientes al tipo de operación

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828TOP(oView)
Local oModel 		:= FWModelActive()
Local oMdlNL4		:= Nil
Local aAreaFR8		:= FR8->(GetArea())	
Local cCodtop		:= ""
Local cTes			:= ""

	cCodTOP := oModel:GetValue("NL4_DETAIL","NL4_TIPDED")
	oMdlNL4 := oModel:getModel("NL4_DETAIL")
	DbSelectArea("FR8")
	FR8->(DbSetOrder(1)) //FR8_FILIAL+FR8_CODIGO
	
	If FR8->(MsSeek(xFilial("FR8")+cCodTOP))
		oMdlNL4:loadValue("NL4_DESC",FR8->FR8_DESC)
		If cEspecie == "1"
			cTes := FR8->FR8_TESE
			oMdlNL4:loadValue("NL4_TIPO",FR8->FR8_TIPOE)
		ElseIf cEspecie == "2"
			cTes := FR8->FR8_TES
			oMdlNL4:loadValue("NL4_TIPO",FR8->FR8_TIPO)
		EndIf
		
		If SF4->(MsSeek(xFilial("SF4")+cTes))
			oMdlNL4:loadValue("NL4_CODTES",cTes)
			oMdlNL4:loadValue("NL4_DESTES",SF4->F4_TEXTO)
		EndIf
		
		If cTipLiq == "2" .and. FR8->FR8_TIPOOP == "2"
			If NL4->(ColumnPos("NL4_TIPAJU")) > 0
				oMdlNL4:loadValue("NL4_TIPAJU","1")
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaFR8)
	oView:Refresh()
Return

/*
{Protheus.doc} Fis828TOP() llena el valor del importe
@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828TOT(oView)
Local oModel 		:= FWModelActive()
Local oMdlNL4		:= Nil
Local nCant			:= 0
Local nPrcKg		:= 0

	nCant 	:= oModel:GetValue("NL4_DETAIL","NL4_QUANT")
	nPrcKg	:= oModel:GetValue("NL4_DETAIL","NL4_PRECIO")
	oMdlNL4 := oModel:getModel("NL4_DETAIL")
	
	oMdlNL4:SetValue("NL4_IMPORT",nCant*nPrcKg)
	
	oView:Refresh()
Return

/*
{Protheus.doc} FISA828LPNL4()
Limpia el campo Tipo Deducción NL4_TIPDED cuando cambia el Tipo Certificado NL4_TIPO
@Author     Alfredo Medrano
@Since      06/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 .T. 
*/
Function FISA828LPNL4()

	Local oModel 	:= FWModelActive()
	oModel:getModel('NL4_DETAIL'):LoadValue('NL4_TIPDED' ," ")	
	
Return .T.


/*
{Protheus.doc} FISA828TTES()
obtiene el codigo de TES de Retención
@Author     Alfredo Medrano
@Since      23/11/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return	 lRet
*/
Static function FISA828TTES(cCod) //Borrar
	Local cRet := ''
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) 
	
	If SF4->(dBSeek(xfilial('SF4')+cCod))
		cRet := SF4->F4_TIPORET
	EndIf
	
return cRet

/*
{Protheus.doc} fDesCam()
Obtiene el titulo de campo en SX3    
@Author     Alfredo Medrano
@Since      11/10/2016
@Version    P12.7
@Project    AGRO - Argentina
@Return 	 Titulo de Campo
*/
Static Function fDesCam(cCamX3)
	
	Local aArea 		:= getArea()
	Local cTitulo 	:= ""
	
	If !empty(cCamX3) 
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cCamX3)   
			cTitulo := X3Titulo()
		EndIf
	EndIf
	RestArea(aArea)
	
Return cTitulo

/*
{Protheus.doc} Fis828Cal() Detona los calculos de impuestos

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/

Function Fis828Cal(oView)
Local aNJCImp 	:= {}
Local aNL4Imp	:= {}
Local oModel 	:= FWModelActive()
Local oGridNJC	:= oModel:getModel("NJC_MASTER")
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local cTesNL4	:= ""
Local nBaseNL4	:= 0
Local nCantNL4	:= 0
Local aLnGrid	:= {}
Local nI		:= 0
Local cPictBas	:= PesqPict("NL4","NL4_BASIM1")
Local cPictVal	:= PesqPict("NL4","NL4_VALIM1")
Local nDeduc	:= 0
Local nOper		:= 0
Local nSubOpe	:= oModel:GetValue( 'TOTAL', 'SUBTOPE' )
Local aAreaFR8	:= FR8->(GetArea())
Local nBaseSe	:= 0
Local nBaseDR	:= 0
Local nIVA		:= 0
Local nTotal	:= 0
Local nIVAOP	:= 0
Local nTotIVAOP	:= 0
Local nRetAFI	:= 0
Local nOtrasRET	:= 0
Local nIVAFis	:= 0
Local nIVARET	:= 0
Local cCBUESP	:= 0
Local nTotPre	:= 0
Local cLiq		:= ""
Local nTotCal	:= 0 //Calidad
Local nTotCom	:= 0 //Comisiones
Local lInit828	:= TYPE("lFisa828") == "L" .and. lFisa828

Private cTipLiq		:= oModel:GetValue("NJC_MASTER","NJC_TIPO")
Private cLiquid 	:= oModel:GetValue("NJC_MASTER","NJC_TPLIQ")
Private cEspecie 	:= oModel:GetValue("NJC_MASTER","NJC_ESPLIQ")
Private nValIVA		:= 0
Private nValIVAD	:= 0
Private nValPer		:= 0
Private nValPerD	:= 0

Default oView		:= Nil

	cLiq := oGridNJC:GetValue("NJC_LIQ")
	If cLiq == "2"
		Return
	EndIf

	aItemsI 	:= {}
	
	If !(cTipLiq == "2")
		nTotPre		:= M->NJC_PRECO * M->NJC_PESSCE
		//Detonación de calculo de impuestos para encabezado.
		aNJCImp := {0, nTotPre, nTotPre, 0, 0, {}, M->NJC_PROVEN, "" }
		Fis828Imp( @aNJCImp, M->NJC_TES, "cProducto", IIF(VAL(LEFT(M->NJC_TES,1))<5 ,.T.,.F.), "NJC")
		//Acumula impuestos
		FIS828SUM(@aItemsI, aNJCImp[6],,"NJC",oGridNJC,@nIVAFis)
	EndIf
	
	
	aNL4Imp := {}
	nValIVA		:= 0
	nValIVAD	:= 0
	nValPer		:= 0
	nValPerD	:= 0
	
	DbSelectArea("FR8")
	FR8->(DbSetOrder(1)) //FR8_FILIAL+FR8_CODIGO
	
	//Detonación de calculo de impuestos para los items Operaciones/Deducciones.
	For nI := 1 To oGridNL4:Length()
		aNL4Imp := {}
		oGridNL4:GoLine( nI )
		If oGridNL4:aCols[nI,Len(oGridNL4:aCols[nI])]
			Loop
		EndIf
		cTesNL4 	:= oGridNL4:GetValue("NL4_CODTES")
		nCantNL4	:= oGridNL4:GetValue("NL4_QUANT")
		nBaseNL4 	:= oGridNL4:GetValue("NL4_IMPORT")
		cTipo		:= oGridNL4:GetValue("NL4_TIPO")
		cTipoDed	:= oGridNL4:GetValue("NL4_TIPDED")
		
		nTotal := nBaseNL4//nCantNL4 * nBaseNL4
		
		If cTipo == "1"
			nOper += nTotal
		Else
			nDeduc += nTotal
		EndIf
		
		aNL4Imp := {0, nTotal, nTotal, 0, 0, {}, M->NJC_PROVEN, "" }
		
		//Calculo de impuestos
		Fis828Imp( @aNL4Imp, cTesNL4, "",IIF(VAL(LEFT(cTesNL4,1))<5 ,.T.,.F.),"NL4")
		nIVA := 0
		//Acumula impuestos
		FIS828SUM(@aItemsI, aNL4Imp[6],Iif(cTipo == "2", .T., .F.),"NL4",oGridNL4,@nIVA)
		
		//Acumula valores de operaciones para retención de sellos y derechos,
		If cEspecie == "1" .and. cLiquid == "1"			
			
			
			/*If M->NJC_OPERAC == "1" //Compra ventas
				nBaseSe += nTotal + nIVA
				nBaseDR += nTotal + nIVA
			Else*/
			
			If FR8->(MsSeek(xFilial("FR8")+cTipoDed))
				If FR8->FR8_TIPOOP == "2" //Calidad
					nTotCal += nTotal
				Else
					If FR8->FR8_TIPOOP == "1" //Comisión
						nTotCom += nTotal
					EndIf
					If M->NJC_OPERAC == "2" //Consignación de granos
						If FR8->FR8_TIPOOP $ "1|3" //Comisión|Gastos
							If FR8->FR8_CALCSE == "1" //Calcula Sellos
								nBaseSe += nTotal + nIVA
							EndIf
							/*If FR8->FR8_CALCDR == "1" //Calcula derechos
								nBaseDR += nTotal + nIVA
							EndIf*/
						EndIf
					Endif
				EndIf
			EndIf	
			nIVAOP 		+= nIVA
			nTotIVAOP	+= nTotal + nIVA
		EndIf
		
		aLnGrid	:= {}
	Next nI
	
	If lInit828
		If Len(aItemsI) > 0
			AEval( aItemsI, { | x | x[3] := AllTrim(Transform(x[3],cPictBas)), x[4] := AllTrim(Transform(x[4],cPictVal)) } )
			oLbxI:SetArray( aItemsI ) 
			oLbxI:bLine := {|| aEval(aItemsI[oLbxI:nAt],{|z,w| aItemsI[oLbxI:nAt,w] } ) }
			oLbxI:Refresh()
		EndIf
	EndIf
	
	If cEspecie == "1" .and. cLiquid == "1"
		If M->NJC_OPERAC == "1" 
			nBaseSe := nSubOpe + nIVAFis
		EndIf
		nBaseDR := nSubOpe + nIVAFis
		FI828CLRET(nTotPre, nSubOpe, nOper, nDeduc, nBaseSe, nBaseDR, nTotCal, nTotCom, @nRetAFI, @nOtrasRET, @nIVARET)
			//Retenciones AFI
			oModel:LoadValue("NJC_MASTER","NJC_RETAFI",nRetAFI)
			oModel:LoadValue('TOTAL', 'RETAFI',nRetAFI)
			
			//Otras retenciones
			oModel:LoadValue("NJC_MASTER","NJC_OTRRET",nOtrasRET)
			oModel:LoadValue('TOTAL', 'OTRRET',nOtrasRET)
			
			cCBUESP := Posicione("SA2",1,xFilial("SA2") + M->NJC_VENDED + M->NJC_LOJAVE,"A2_CBUESP")
			If !Empty(cCBUESP)
				//IVA RG2300
				oModel:LoadValue("NJC_MASTER","NJC_IVARG2",nIVAFis - nIVARET)
				oModel:LoadValue('TOTAL', 'IVARG2',nIVAFis - nIVARET)
			EndIf
	EndIf
	//Se detonadan con un valor 0 para actualizar los totalizadores.
	oModel:LoadValue('TOTAL', 'TTLDED',0)
	oModel:LoadValue('TOTAL', 'IMPIVA',0)
	oModel:LoadValue('TOTAL', 'OPEIVA',0)
	oModel:LoadValue('TOTAL', 'IMPNAP',0)
	oModel:LoadValue('TOTAL', 'PAGSCO',0)
	oModel:LoadValue('TOTAL', 'CREDEB',0)
	oGridNJC:LoadValue("NJC_LIQ","2")
	RestArea(aAreaFR8)
	
	 oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .T. )
	 oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .T. )
	
	If oView <> Nil
		oView:Refresh()
	EndIf
	
Return


/*
{Protheus.doc} Fis828Imp() Detona los calculos de impuestos de las TES

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function Fis828Imp( aImp, cTes, cProduto, lEntrada, cAliasImp)
Local aImposto 	:= {}
Local cFileRdMk	:= ""
Local nRecnoSFC	:= 0
Local nOrderSFC := 0
Local aAreaSA	:= {}

Private cSerie 		:= "A"
Private lCliente	:= cEspecie == "2"

/*
Parametros:

aImp:
aImp[1]
aImp[2] -> Valor de Item
aImp[3] -> Base de calculo
aImp[4] -> Valor de flete - No usado
aImp[5] -> Valor de despensa - No usado
aImp[6] -> Arreglo para los impuestos calculados
aImp[7] -> Provincia de entrega
aImp[8] -> Codigo Fiscal

cTes -> TES usada para realizar los calculos

cProtucto -> Codigo de producto.

lEntrada -> Indica según la TES que formula usar para el calculo Entrada/Salida
*/

/*
aImposto:
[01] -> Código de impuesto
[02] -> Alicuota de impuesto
[03] -> Base de calculo de impuesto
[04] -> Valor del impuesto
[05] -> 
[06] -> Campo valor item
[07] -> Campo base item 
[08] -> campo valor encabezado
[09] -> campo base encabezado
[10] -> Impuestos incluidos en el calculo
[11] -> 
[12] -> 
[13] ->
[14] ->
[15] -> Calculo Item/Total
[16] -> Código del proucto
[17] -> Campo de libro fiscal
[18] -> Descuento por item o total
[19] -> Define si el impuesto va a sumar, restar o es indiferente
[20] -> Provincia impuesto
[21] ->

*/
	If !lCliente
		aAreaSA := SA2->(GetArea())
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
		SA2->(MsSeek(xFilial("SA2")+M->NJC_VENDED+M->NJC_LOJAVE))

	Else
		aAreaSA := SA1->(GetArea())
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(MsSeek(xFilial("SA1")+M->NJC_CODPRO+M->NJC_TIENDA))
	EndIf

	SF4->( DbSetOrder( 1 ) ) //F4_FILIAL+F4_CODIGO
	SFC->( DbSetOrder( 1 ) ) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
	SFB->( DbSetOrder( 1 ) ) //B1_FILIAL+B1_COD
	
	If SF4->( MsSeek( xFilial("SF4")+cTes) )
		If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
			While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )

				If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
					cFileRdMk := Iif(lEntrada,AllTrim(SFB->FB_FORMENT),AllTrim(SFB->FB_FORMSAI))
					aImposto  := {}
					Aadd(aImposto, SFB->FB_CODIGO)  	//[01]
					Aadd(aImposto, 0.00)				//[02]
					Aadd(aImposto, 0.00)				//[03]
					Aadd(aImposto, 0.00)				//[04]
					Aadd(aImposto, "")					//[05]
					Aadd(aImposto, cAliasImp+"_BASIM"+SFB->FB_CPOLVRO)					//[06]
					Aadd(aImposto, cAliasImp+"_VALIM"+SFB->FB_CPOLVRO)					//[07]
					Aadd(aImposto, "")					//[08]
					Aadd(aImposto, "")					//[09]
					Aadd(aImposto, SFC->FC_INCIMP)		//[10]
					Aadd(aImposto, 0.00)				//[11]
					Aadd(aImposto, 0.00)				//[12]
					Aadd(aImposto, 0.00)				//[13]
					Aadd(aImposto, 0.00)				//[14]
					Aadd(aImposto, "I")					//[15]
					Aadd(aImposto, cProduto)			//[16]
					Aadd(aImposto, SFB->FB_CPOLVRO)		//[17]
					Aadd(aImposto, 0)					//[18]
					Aadd(aImposto, {1,-1,0})			//[19]
					Aadd(aImposto, SFC->FC_PROV)		//[20]
					Aadd(aImposto, SFB->FB_DESCR)
					
					nRecnoSFC := SFC->( Recno() )
					nOrderSFC := SFC->( IndexOrd() )
					
					If FindFunction(cFileRdMk) 
						aImposto := ExecBlock( cFileRdMk,.F.,.F., { aImp, aImposto,1} , .T. )//;
							//nPosCols, "D2_VALIMP"+SFB->FB_CPOLVRO,nTotBaseImp} ,.T. )
						aAdd(aImp[6],aClone(aImposto))
					EndIf
					
					SFC->( DbSetOrder(nOrderSFC) )
					SFC->( dbGoTo(nRecnoSFC) )
				EndIf
				SFC->( DbSkip() )
			Enddo
		EndIf
	EndIf
	
	If !lCliente
		SA2->(RestArea(aAreaSA))
	Else
		SA1->(RestArea(aAreaSA))
	EndIf

Return

/*
{Protheus.doc} FIS828SUM() Realiza la suma de los impuestos para su visualización en pantalla.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function FIS828SUM(aImpostos, aImp, lDeduc, cAliasIm, oGrid, nIVA)
Local nI 		:= 0
Local nPos		:= 0
Local cCpoAliq	:= ""

Default lDeduc	:= .F.
Default nIVA := 0

	For	nI := 1 To Len(aImp)
		If !(aImp[nI][_IMPBASE] > 0)
			Loop
		EndIf
		nPos := ASCAN(aImpostos,{|x|x[1] == aImp[nI][1]})
		
		If nPos > 0
			If !lDeduc
				aImpostos[nPos][_IMPBASE] 	+= aImp[nI][_IMPBASE]
				aImpostos[nPos][_IMPVAL] 	+= aImp[nI][_IMPVAL]
			Else
				aImpostos[nPos][_IMPBASE] 	-= aImp[nI][_IMPBASE]
				aImpostos[nPos][_IMPVAL] 	-= aImp[nI][_IMPVAL]
			EndIf
		Else
			If !lDeduc
				AADD(aImpostos,{aImp[nI][_IMPCOD],aImp[nI][21],aImp[nI][_IMPBASE],aImp[nI][_IMPVAL]})
			Else
				AADD(aImpostos,{aImp[nI][_IMPCOD],aImp[nI][21],aImp[nI][_IMPBASE] * -1,aImp[nI][_IMPVAL] * -1})
			EndIf
		Endif
		
		//Actualizacion de base
		If (cAliasIm)->(ColumnPos(aImp[nI][_IMPCPOBAS])) > 0
			oGrid:loadValue(aImp[nI][_IMPCPOBAS],aImp[nI][_IMPBASE])
		Endif
		
		//Actualizacion de valor
		If (cAliasIm)->(ColumnPos(aImp[nI][_IMPCPOVAL])) > 0
			oGrid:loadValue(aImp[nI][_IMPCPOVAL],aImp[nI][_IMPVAL])
		EndIf
		
		//Actualizacion de alicuota
		cCpoAliq := cAliasIm+"_ALQIM"+aImp[nI][_IMPCPOLIV]
		If (cAliasIm)->(ColumnPos(cCpoAliq)) > 0
			oGrid:loadValue(cCpoAliq,aImp[nI][_IMPALIQ])
		EndIf
	
	
		If "IV" $ aImp[nI][_IMPCOD]
			If !lDeduc
				nValIVA 	+= aImp[nI][_IMPVAL]
				nIVA		+= aImp[nI][_IMPVAL]
			Else
				nValIVAD	+= aImp[nI][_IMPVAL]
				nIVA		+= aImp[nI][_IMPVAL]
			EndIf
		ElseIf "IB" $ aImp[nI][_IMPCOD]
			If !lDeduc
				nValPer		+= aImp[nI][_IMPVAL]
			Else
				nValPerD	+= aImp[nI][_IMPVAL]
			EndIf
		EndIf
		
	Next nI
	
Return

/*
{Protheus.doc} FIS828GImp() Realiza la suma de los impuestos para su visualización en pantalla cuando se visualiza o modifica.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function FIS828GImp()
Local aAreaNL4	:= NL4->(GetArea())
Local aTES		:= {}
Local aTESAct	:= {}
Local nPosTes	:= 0


	If !Empty(M->NJC_TES)
		nPosTes := aScan(aTES, {|x| x[1] == M->NJC_TES })
		If nPosTes > 0
			aTESAct := aClone(aTes[nPosTes][2])
		Else
			aTESAct := FIS828GTES(M->NJC_TES)
			AADD(aTES, {M->NJC_TES,aClone(aTESAct)})
		EndIf
		FIS828IMPL("NJC","M",aTESAct,.F.)
	EndIf


	NL4->( DbSetOrder( 1 ) ) //NL4_FILIAL+NL4_CODLIQ+NL4_ITEM
	If NL4->( MsSeek( xFilial("NL4")+M->NJC_CODLIQ) )
		While NL4->( !Eof() .And. NL4->NL4_FILIAL+NL4->NL4_CODLIQ == xFilial("NL4")+M->NJC_CODLIQ)
			If !Empty(NL4->NL4_CODTES)
				nPosTes := aScan(aTES, {|x| x[1] == NL4->NL4_CODTES })
				If nPosTes > 0
					aTESAct := aClone(aTes[nPosTes][2])
				Else
					aTESAct := FIS828GTES(NL4->NL4_CODTES)
					AADD(aTES, {NL4->NL4_CODTES,aClone(aTESAct)})
				EndIf
				FIS828IMPL("NL4","NL4",aTESAct,Iif(NL4->NL4_TIPO == "2", .T., .F.))
			EndIf
			NL4->( DbSkip() )
		Enddo
	EndIf
	
	RestArea(aAreaNL4)
Return

/*
{Protheus.doc} FIS828IMPL() Función para acumular los impuestos

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function FIS828IMPL(cAliasImp,cPoint,aTes,lDeduc)
Local nI 		:= 1
Local nBase		:= 0
Local nVal		:= 0
Local nPos		:= 0 

	For nI := 1 To Len(aTes)
		
		If (cAliasImp)->(ColumnPos(cAliasImp+"_VALIM"+aTes[nI][3])) > 0 .And. (cAliasImp)->(ColumnPos(cAliasImp+"_BASIM"+aTes[nI][3])) > 0
			nVal 	:= &(cPoint+"->"+cAliasImp+"_VALIM"+aTes[nI][3])
			nBase 	:= &(cPoint+"->"+cAliasImp+"_BASIM"+aTes[nI][3]) 
			If nBase > 0 .Or. nVal	> 0  
				nPos := ASCAN(aItemsI,{|x|x[1] == aTes[nI][1]})
			
				If nPos > 0
					If !lDeduc
						aItemsI[nPos][_IMPBASE]	+= nBase
						aItemsI[nPos][_IMPVAL]	+= nVal
					Else
						aItemsI[nPos][_IMPBASE]	-= nBase
						aItemsI[nPos][_IMPVAL]	-= nVal
					EndIf
				Else
					If !lDeduc
						AADD(aItemsI,{aTes[nI][1],aTes[nI][2],nBase,nVal})
					Else
						AADD(aItemsI,{aTes[nI][1],aTes[nI][2],nBase * -1,nVal * -1})
					EndIf
				Endif
			EndIf
		EndIf
	Next nI

Return

/*
{Protheus.doc} FIS828GTES() Función para obtener datos de los impuestos.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function FIS828GTES(cTes)
Local aAreaSFB	:= SFB->(GetArea())
Local aAreaSFC	:= SFC->(GetArea())
Local aItems	:= {}

	SFC->( DbSetOrder( 1 ) ) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
	SFB->( DbSetOrder( 1 ) ) //FB_FILIAL+FB_CODIGO
	
	If SFC->( MsSeek( xFilial("SFC")+cTes) )
		While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+cTES)
			If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
				AADD(aItems, {SFB->FB_CODIGO,SFB->FB_DESCR,SFB->FB_CPOLVRO})
			EndIf
			SFC->( DbSkip() )
		Enddo
	EndIF
	
	RestArea(aAreaSFB)
	RestArea(aAreaSFC)
Return aItems


/*
{Protheus.doc} FI828CLRET(oView)

Realiza el calculo de retenciones

@Author     
@Since      //
@Version    P12.1.25
@Project    AGRO - Argentina
@Return 	 
*/
/*
Parametros:
nTotPre: Valor de Precio * Kilo
nSubOpe:= valor de la suboperación (NJC_SUBOPE)
nOper: Valor de operaciones
nDeduc: Valor de las deducciones
nBaseSe: Base de calculo para sellos
nBaseDR: Base de calculo para derechos
nTotCal: Valor de las cuentas de calidad de la preliquidación
nTotCom: Valor de las comisiones de la preliquidación
nRetAFI: Almacena los valores de retenciones de IVA y Ganancias
nOtrasRET: Almacena el valor de Otras retenciones (IIBB, Derechos, Sellos)
nIVARET: Almacena el valor de retención de IVA
*/
static function FI828CLRET(nTotPre, nSubOpe, nOper, nDeduc, nBaseSe, nBaseDR, nTotCal, nTotCom, nRetAFI, nOtrasRET, nIVARET)
Local aConfProv 	:= {}
Local cAgente		:= GETMV("MV_AGENTE")
Local nSigno		:= 1
Local aTmpIB		:= {}
Local aTmp1			:= {}
Local nX			:= 1
Local nY			:= 1
Local aItemsR		:= {}
Local cPictBas		:= PesqPict("SFE","FE_VALBASE")
Local cPictAlq		:= PesqPict("SFE","FE_ALIQ")
Local cPictVal		:= PesqPict("SFE","FE_RETENC")
Local cCFO			:= Posicione("SF4",1,xFilial("SF4") + M->NJC_TES,"F4_CF")
Local nBasCalIIBB	:= 0
Local nBasCalGan	:= 0
Local nPosRet		:= 0
Local lCanje		:= .F.
Local lInit828		:= TYPE("lFisa828") == "L" .and. lFisa828

Private lShowPOrd	:= .F. 
Private lRetPa		:= .T.
Private nMoedaCor	:= 1
Private aTxMoedas 	:= {}

DEFAULT nDeduc		:= 0
DEFAULT nOpera		:= 0



/*
Bases de calculos:
IVA:

IIBB:

Ganancias

Derechos de registro

Sellos:



*/

	Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
	
	cFornece	:= M->NJC_VENDED
	cLoja 		:= M->NJC_LOJAVE
	lCanje		:= M->NJC_TROCA == "2" .Or. M->NJC_TROCA == "3" 
	
	aReten := {{},{},{},{},{}}
	
	
	If cTipLiq == "2"    //Para liquidaciones finales sólo se calcula la parte de la cuenta de calidad.
		nBasCalIIBB := nTotCal
		nBasCalGan	:= nTotCal
	Else
		nBasCalIIBB := nSubOpe-nTotCal
		nBasCalGan	:= nTotPre-nTotCal
	EndIf
	
	If !(cTipLiq == "2") .and. !lCanje //Para liquidación final no se calcula retención de IVA, tampoco para canje.
		//Retención IVA
		aReten[_RETIVA] := AgroRetIVA(cAgente,nSigno,nTotPre - nTotCom,cCFO,,) 
	EndIf
	
	//Retención de Ingresos Brutos
	AADD(aConfProv,CheckConfIB(M->NJC_VENDED,M->NJC_LOJAVE,M->NJC_PROVOR))
	aConfProv[1][8] := aConfProv[1][8]/100
	AADD(aConfProv,CheckConfIB(M->NJC_VENDED,M->NJC_LOJAVE,M->NJC_PROVEN))
	aConfProv[2][8] := 1 - aConfProv[1][8]
	
	For nX := 1 To Len(aConfProv)
		aTmp1	:= AgroRetIB(cAgente,nSigno,nBasCalIIBB,cCFO,M->NJC_PROVEN,aConfProv[nX][8],aConfProv[nX])
		
		If Len(aTmp1) > 0
			For nY := 1 To Len(aTmp1)
				aAdd(aTmpIB, aClone(aTmp1[nY]))
			Next nY
			aTmp1   := {}
		Endif
	Next nX
	aReten[_RETIIBB] := aClone(aTmpIB)
	
	If !lCanje
		//Retención de ganancias
		aReten[_RETGAN] := AGRORetGN(cAgente,nSigno,nBasCalGan,M->NJC_VENDED,M->NJC_LOJAVE,M->NJC_CODLIQ)
	EndIf
	
	//Retención de sellos
	If !(cTipLiq == "2")
		If aConfProv[1][13] > 0
			aReten[_RETSE] := {nBaseSe, aConfProv[1][13], nBaseSe * (aConfProv[1][13]/100), M->NJC_PROVOR,"SLL" }
		EndIf
	EndIf
	
	//Retención de derechos
	If !(cTipLiq == "2")
		If aConfProv[1][14] > 0
			aReten[_RETDR] := {nBaseDR, aConfProv[1][14], nBaseDR * (aConfProv[1][14]/100), M->NJC_PROVOR,"REG" }
		EndIf
	EndIf
	
	//Carga a grid de IVA
	If Len(aReten[_RETIVA]) > 0
		For nX := 1 To Len(aReten[_RETIVA])
			If Abs(aReten[_RETIVA][nX][6]) > 0
				AADD(aItemsR,{"IVA","",aReten[_RETIVA][nX][3], aReten[_RETIVA][nX][10],aReten[_RETIVA][nX][6]})
				nRetAFI += aReten[_RETIVA][nX][6]
				nIVARET	+= aReten[_RETIVA][nX][6]
			EndIf
		Next nX
	EndIf
	
	//Carga a grid de IIBB
	If Len(aReten[_RETIIBB]) > 0
		For nX := 1 To Len(aReten[_RETIIBB])
			If Abs(aReten[_RETIIBB][nX][6]) > 0
				nPosRet := aScan(aItemsR,{|x| x[1] == "IBR" .and. x[2] == aReten[_RETIIBB][nX][9] .and. x[4] == aReten[_RETIIBB][nX][4]})
				If nPosRet > 0
					aItemsR[nPosRet][3] += aReten[_RETIIBB][nX][3]
					aItemsR[nPosRet][5] += aReten[_RETIIBB][nX][6]
				Else
					AADD(aItemsR,{"IBR",aReten[_RETIIBB][nX][9],aReten[_RETIIBB][nX][3], aReten[_RETIIBB][nX][4],aReten[_RETIIBB][nX][6]})
				EndIf
				nOtrasRET += aReten[_RETIIBB][nX][6]
			EndIf
		Next nX
	EndIf
	
	//Carga a grid de GAN
	If Len(aReten[_RETGAN]) > 0
		For nX := 1 To Len(aReten[_RETGAN])
			AADD(aItemsR,{"GAN",aReten[_RETGAN][nX][7],aReten[_RETGAN][nX][2], aReten[_RETGAN][nX][3],aReten[_RETGAN][nX][5]})
			nRetAFI += aReten[_RETGAN][nX][5]
		Next nX
	EndIf
	
	//Carga a grid de sellos
	If Len(aReten[_RETSE]) > 0
		If Abs(aReten[_RETSE][3]) > 0
			AADD(aItemsR,{aReten[_RETSE][5],aReten[_RETSE][4],aReten[_RETSE][1], aReten[_RETSE][2],aReten[_RETSE][3]})
			nOtrasRET += aReten[_RETSE][3]
		Endif
	EndIf
	
	//Carga a grid de derechos
	If Len(aReten[_RETDR]) > 0
		If Abs(aReten[_RETDR][3]) > 0
			AADD(aItemsR,{aReten[_RETDR][5],aReten[_RETDR][4],aReten[_RETDR][1], aReten[_RETDR][2],aReten[_RETDR][3]})
			nOtrasRET += aReten[_RETDR][3]
		Endif
	EndIf


	If Len(aItemsR) <= 0
		AADD(aItemsR,{" "," ",0,0,0 } )
	EndIf
	
	If lInit828
		AEval( aItemsR, { | x | x[3] := AllTrim(Transform(x[3],cPictBas)), x[4] := AllTrim(Transform(x[4],cPictAlq)), x[5] := AllTrim(Transform(x[5],cPictVal)) } )
		oLbxR:SetArray( aItemsR ) 
		oLbxR:bLine := {|| aEval(aItemsR[oLbxR:nAt],{|z,w| aItemsR[oLbxR:nAt,w] } ) }
		oLbxR:Refresh()
	EndIf

//oLbx:Refresh

Return

/*
{Protheus.doc} CheckConfIB() Verifica las configuraciones para el calculo de impuesto en las provincias.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function CheckConfIB(cFornecedor, cLoja, cProvincia)
Local aConfProv	:= {}
Local cTipoForn	:= ""
Local lFindSfh 	:= .F.

Default cProvincia	:= ""


CCO->(DbSetOrder(1)) //CCO_FILIAL+CCO_CODPRO
If CCO->(MsSeek(xFilial("CCO")+cProvincia))
	aConfProv := Array(14)
	aConfProv[1] := CCO->CCO_CODPRO//Provincia
	aConfProv[2] := CCO->CCO_AGRET //Agente de retenção
	aConfProv[3] := CCO->CCO_TPRET //Tipo de retenção
	SFH->(DbSetOrder(1)) //FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS
	SFH->(MsSeek(xFilial()+cFornecedor+cLoja+"IBR"+CCO->CCO_CODPROV))
	If SFH->(Found())
		aConfProv[1] := SFH->FH_ZONFIS //Provincia
		While !lFindSfh .and. (SFH->FH_FORNECE ==cFornecedor .and. SFH->FH_LOJA == cLoja .and. SFH->FH_IMPOSTO =="IBR" .and. SFH->FH_ZONFIS == CCO->CCO_CODPROV) .and. !SFH->(Eof())
			If SFH->(ColumnPos("FH_TIPO")) > 0 .And. !Empty(SFH->FH_TIPO) .And. Iif(!Empty(SFH->FH_INIVIGE),dDataBase>=SFH->FH_INIVIGE,.T.) .And. Iif(!Empty(SFH->FH_FIMVIGE),dDataBase<=SFH->FH_FIMVIGE,.T.)
				lFindSfh:=.T.
				Exit
			Endif
			SFH->(dbSkip())
		EndDo
		If lFindSfh
			cTipoForn := SFH->FH_TIPO
		Else
		//Caso o tipo não seja informado na amarração, o fornecedor deve ser tratado como No Inscripto (N)
			cTipoForn := "N"
		Endif

		aConfProv[4] := cTipoForn //Tipo
				
	Else
		aConfProv[4] := "N" //Caso não exista a amarração de exceções, o fornecedor deve ser tratado como No Inscripto (N)
	Endif
	aConfProv[5] := IIF(CCO->(ColumnPos("CCO_TPCALC"))>0,CCO->CCO_TPCALC,"1") //Tipo de Calculo 1 o "" por couta, 2 por total
	aConfProv[6] := IIF(CCO->(ColumnPos("CCO_TPCALR"))>0,IIF(Empty(CCO->CCO_TPCALR),"A",CCO->CCO_TPCALR),"A") //Tipo de Calculo 1 o "" por couta, 2 por total
	aConfProv[7] := IIF(CCO->(ColumnPos("CCO_TPLIMR")) > 0 .And. (CCO->CCO_TPLIMR == "5" .or. CCO->CCO_TPLIMR == "0"), CCO->CCO_TPLIMR, " ") //Si tipo de limite igual a 5, pasa el valor 5, de lo contrario 0.
	aConfProv[8] := IIF(CCO->(ColumnPos("CCO_REDAGR"))>0,CCO->CCO_REDAGR,100) //Porcentaje de calculo de la provincia de granos
	aConfProv[9] := IIF(CCO->(ColumnPos("CCO_TPMINR"))>0,CCO->CCO_TPMINR,"") //tipo de  minimo configurado para la provincia
	aConfProv[10] := IIF(CCO->(ColumnPos("CCO_IMMINR"))>0,CCO->CCO_IMMINR,0) //Valor del mínimo
	aConfProv[11] := IIF(CCO->(ColumnPos("CCO_RPROAG"))>0,CCO->CCO_RPROAG,"") //Ret. Prov. entre agentes 
	aConfProv[12] := IIF(CCO->(ColumnPos("CCO_CRFRET"))>0,CCO->CCO_CRFRET,0) //Coeficiente de incremento de alicuota retención por riesgo fiscal
	aConfProv[13] := IIF(CCO->(ColumnPos("CCO_ALIQSE"))>0,CCO->CCO_ALIQSE,0) //Porcentaje de calculo de la provincia de granos
	aConfProv[14] := IIF(CCO->(ColumnPos("CCO_ALIQDR"))>0,CCO->CCO_ALIQDR,0) //Porcentaje de calculo de la provincia de granos
EndIf

//Configuração padrão -> cadastro de Fornecedor - SA2
If Len(aConfProv) == 0
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	
	SA2->(MsSeek(xFilial("SA2")+cFornecedor+cLoja))
	If SA2->(Found())
		aConfProv := Array(14)
		aConfProv := {cProvincia, Iif(SA2->A2_RETIB == "S", "1", "2"), "1", SA2->A2_TIPO,"2","A","0",0,"",0,,0,0,0}
	Endif
Endif

Return aConfProv

/*
{Protheus.doc} ValidPos()

Função de validação de Exclusão.

@Author		Francisco Oliveira
@Since		11/07/2016
@Version	P12.7
@Project    AGRO - Argentina
@Return		.F. ou .T.
*/
Static Function ValidPos(oModel)
	
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaNJC	:= NJC->(GetArea())
Local cStatus	:= NJC->NJC_STATUS
Local nOp 		:= oModel:GetOperation()
Local oMdlTotal	:= oModel:Getmodel("TOTAL")
Local oMdlNL4	:= oModel:getModel("NL4_DETAIL")
	
	oModel := FWModelActive()
	
	//Exclusion
	If nOp == MODEL_OPERATION_DELETE
		If Empty(cStatus)
			If Aviso(OemToAnsi(STR0012), OemToAnsi(STR0013), {STR0015,STR0016}, 3) == 2
				lRet := .F.
			EndIf
		EndIf
	ElseIf nOp == MODEL_OPERATION_INSERT .or. (nOp == MODEL_OPERATION_UPDATE .and. Empty(cStatus))	
		//guardamos los valores de los totalizadores
		oModel:LoadValue("NJC_MASTER","NJC_PESTOT",oMdlTotal:getValue("PESTOT"))
		oModel:LoadValue("NJC_MASTER","NJC_SUBOPE",oMdlTotal:getValue("SUBTOPE"))
		oModel:LoadValue("NJC_MASTER","NJC_IMPIVA",oMdlTotal:getValue("IMPIVA"))
		oModel:LoadValue("NJC_MASTER","NJC_OPEIVA",oMdlTotal:getValue("OPEIVA"))
		oModel:LoadValue("NJC_MASTER","NJC_TOTDED",oMdlTotal:getValue("TTLDED"))
		oModel:LoadValue("NJC_MASTER","NJC_RETAFI",oMdlTotal:getValue("RETAFI"))
		oModel:LoadValue("NJC_MASTER","NJC_OTRRET",oMdlTotal:getValue("OTRRET"))
		oModel:LoadValue("NJC_MASTER","NJC_IMPNAP",oMdlTotal:getValue("IMPNAP"))
		oModel:LoadValue("NJC_MASTER","NJC_IVARG2",oMdlTotal:getValue("IVARG2"))
		oModel:LoadValue("NJC_MASTER","NJC_PAGSCO",oMdlTotal:getValue("PAGSCO"))
	EndIf
	
	RestArea(aAreaNJC)
	RestArea(aArea)
	
Return lRet

/*
{Protheus.doc} F828IncRet() graba los registros en la tabla FKR

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Function F828IncRet()
Local nX := 1
Local lFKRItem := IIf(FKR->(ColumnPos("FKR_ITEM")) > 0, .T. , .F.)
Local nTamItem  := IIf(lFKRItem, TamSX3("FKR_ITEM")[1], 4)



	If Len(aReten[_RETIVA]) > 0
		For nX := 1 To Len(aReten[_RETIVA])
			If Abs(aReten[_RETIVA][nX][6]) > 0
				RecLock("FKR",.T.)
					FKR_FILIAL		:= xFilial("FKR")
					FKR_CODIGO		:= M->NJC_CODLIQ
					FKR_FORNEC 		:= M->NJC_VENDED
					FKR_LOJA		:= M->NJC_LOJAVE
					FKR_TIPO		:= "I"
					FKR_EMISSA		:= dDataBase
					FKR_CFO			:= aReten[_RETIVA][nX][11]  
					FKR_VALBAS		:= aReten[_RETIVA][nX][3]
					FKR_ALIQ		:= aReten[_RETIVA][nX][10]
					FKR_PORCR 		:= aReten[_RETIVA][nX][5]
					FKR_RETENC		:= aReten[_RETIVA][nX][6]
					If lFKRItem
						FKR_ITEM        := Strzero(nX,nTamItem)
					EndIf
				FKR->(MsUnlock())
			EndIf
		Next nX
	EndIf
	
	If Len(aReten[_RETIIBB]) > 0
		For nX := 1 To Len(aReten[_RETIIBB])
			If Abs(aReten[_RETIIBB][nX][6]) > 0
				RecLock("FKR",.T.)
					FKR_FILIAL		:= xFilial("FKR")
					FKR_CODIGO		:= M->NJC_CODLIQ
					FKR_FORNEC 		:= M->NJC_VENDED
					FKR_LOJA		:= M->NJC_LOJAVE
					FKR_TIPO		:= "B"
					FKR_EMISSA		:= dDataBase
					FKR_CONCEP		:= aReten[_RETIIBB][nX][14]
					FKR_CFO			:= aReten[_RETIIBB][nX][11]  
					FKR_VALBAS		:= aReten[_RETIIBB][nX][3]
					FKR_ALIQ		:= aReten[_RETIIBB][nX][4]
					FKR_DEDUC 		:= aReten[_RETIIBB][nX][15]
					FKR_EST   		:= aReten[_RETIIBB][nX][9]
					FKR_RETENC		:= aReten[_RETIIBB][nX][6]
					If lFKRItem
						FKR_ITEM        := Strzero(nX,nTamItem)
					EndIf
				FKR->(MsUnlock())
			EndIf
		Next nX
	EndIf
	
	If Len(aReten[_RETGAN]) > 0
		For nX := 1 To Len(aReten[_RETGAN])
			RecLock("FKR",.T.)
				FKR_FILIAL		:= xFilial("FKR")
				FKR_CODIGO		:= M->NJC_CODLIQ
				FKR_FORNEC 		:= M->NJC_VENDED
				FKR_LOJA		:= M->NJC_LOJAVE
				FKR_TIPO		:= "G"
				FKR_EMISSA		:= dDataBase
				FKR_VALBAS		:= aReten[_RETGAN][nX][2]
				FKR_ALIQ		:= aReten[_RETGAN][nX][3]
				FKR_RETENC		:= aReten[_RETGAN][nX][5]
				FKR_DEDUC		:= aReten[_RETGAN][nX][6]
				FKR_CONCEP		:= aReten[_RETGAN][nX][7]
				FKR_PORCR 		:= aReten[_RETGAN][nX][8]
				If lFKRItem
					FKR_ITEM        := Strzero(nX,nTamItem)
				EndIf
			FKR->(MsUnlock())
		Next nX
	EndIf
	
	If Len(aReten[_RETSE]) > 0
		RecLock("FKR",.T.)
			FKR_FILIAL		:= xFilial("FKR")
			FKR_CODIGO		:= M->NJC_CODLIQ
			FKR_FORNEC 		:= M->NJC_VENDED
			FKR_LOJA		:= M->NJC_LOJAVE
			FKR_TIPO		:= "E"
			FKR_EMISSA		:= dDataBase
			FKR_VALBAS		:= aReten[_RETSE][1]
			FKR_ALIQ		:= aReten[_RETSE][2]
			FKR_RETENC		:= aReten[_RETSE][3]
			FKR_EST   		:= aReten[_RETSE][4]
			FKR_CONCEP		:= aReten[_RETSE][5]
			If lFKRItem
				FKR_ITEM        := Strzero(1,nTamItem)
			EndIf
		FKR->(MsUnlock())
	EndIf
	
	If Len(aReten[_RETDR]) > 0
		RecLock("FKR",.T.)
			FKR_FILIAL		:= xFilial("FKR")
			FKR_CODIGO		:= M->NJC_CODLIQ
			FKR_FORNEC 		:= M->NJC_VENDED
			FKR_LOJA		:= M->NJC_LOJAVE
			FKR_TIPO		:= "D"
			FKR_EMISSA		:= dDataBase
			FKR_VALBAS		:= aReten[_RETDR][1]
			FKR_ALIQ		:= aReten[_RETDR][2]
			FKR_RETENC		:= aReten[_RETDR][3]
			FKR_EST   		:= aReten[_RETDR][4]
			FKR_CONCEP		:= aReten[_RETDR][5]
			If lFKRItem
				FKR_ITEM        := Strzero(1,nTamItem)
			EndIf
		FKR->(MsUnlock())
	EndIf
Return

/*
{Protheus.doc} F828GRet() Consulta la tabla FKR para la visualización de impuestos.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function F828GRet(aItemsR)
Local lRet		:= .F.
Local nPosRet	:= 0
	
	If TableInDic("FKR")
		DbSelectArea("FKR")
		FKR->(DBSETORDER(1)) //FKR_FILIAL+FKR_CODIGO+FKR_TIPO
		If FKR->(MsSeek(xFilial("FKR")+ M->NJC_CODLIQ))
			While FKR->(!Eof()) .and. FKR->FKR_CODIGO == M->NJC_CODLIQ
				If AllTrim(FKR->FKR_TIPO) == "I"
					AADD(aItemsR,{"IVA","", FKR->FKR_VALBAS, FKR->FKR_ALIQ, FKR->FKR_RETENC})
					lRet := .T.
				ElseIf AllTrim(FKR->FKR_TIPO) == "B"
					nPosRet := aScan(aItemsR,{|x| x[1] == "IBR" .and. x[2] == FKR->FKR_EST .and. x[4] == FKR->FKR_ALIQ})
					If nPosRet > 0
						aItemsR[nPosRet][3] += FKR->FKR_VALBAS
						aItemsR[nPosRet][5] += FKR->FKR_RETENC
					Else
						AADD(aItemsR,{"IBR", FKR->FKR_EST, FKR->FKR_VALBAS, FKR->FKR_ALIQ, FKR->FKR_RETENC})
					EndIf
					lRet := .T.
				ElseIf AllTrim(FKR->FKR_TIPO) == "G"
					AADD(aItemsR,{"GAN",FKR->FKR_CONCEP, FKR->FKR_VALBAS, FKR->FKR_ALIQ, FKR->FKR_RETENC})
					lRet := .T.
				ElseIf AllTrim(FKR->FKR_TIPO) == "E"
					AADD(aItemsR,{"SLL",FKR->FKR_CONCEP, FKR->FKR_VALBAS, FKR->FKR_ALIQ, FKR->FKR_RETENC})
					lRet := .T.
				ElseIf AllTrim(FKR->FKR_TIPO) == "D"
					AADD(aItemsR,{"REG",FKR->FKR_CONCEP, FKR->FKR_VALBAS, FKR->FKR_ALIQ, FKR->FKR_RETENC})
					lRet := .T.
				EndIf
				FKR->(DbSkip())
			Enddo
		EndIf
	EndIf	

Return lRet


Static Function Fis828Rev(oView)
Local oModel 	:= FWModelActive()
Local oGridNJC	:= oModel:getModel("NJC_MASTER")
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")
Local aDatosNJC := {}
Local aDatosNL4	:= {}
Local aCposNL4	:= {}
Local nI		:= 0
Local nJ		:= 0
Local cCpo		:= ""
Local aItemsR	:= {}
Local cPictBas		:= PesqPict("SFE","FE_VALBASE")
Local cPictAlq		:= PesqPict("SFE","FE_ALIQ")
Local cPictVal		:= PesqPict("SFE","FE_RETENC")
Local cLiq			:= ""

	cLiq := oGridNJC:GetValue("NJC_LIQ")
	
	If cLiq == "1"
		Return
	EndIf

	//Se restablecen los valores del encabezado
	aDatosNJC := oModel:GetModel("NJC_MASTER"):aDataModel[1]
	For nI := 1 To Len(aDatosNJC)
		cCpo := Substr(aDatosNJC[nI][1],5,5)
		If cCpo $ "BASIM|ALQIM|VALIM" 
			oGridNJC:loadValue(aDatosNJC[nI][1],0)
		EndIf
	Next nI
		
	//Se buscan los campos de impuestos
	aDatosNL4 := oModel:GetModel("NL4_DETAIL"):aHeader
	For nI := 1 To Len(aDatosNL4)
		cCpo := Substr(aDatosNL4[nI][2],5,5)
		If cCpo $ "BASIM|ALQIM|VALIM" 
			AADD(aCposNL4,aDatosNL4[nI][2])
		EndIf
	Next nI
		
	//Se activa nuevamente la modificación de Operaciones/Deducciones
	oModel:GetModel( 'NL4_DETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'NL4_DETAIL' ):SetNoUpdateLine( .F. )
		
	//Se restablecen los valores de Operaciones/Deducciones
	For nI := 1 To oGridNL4:Length()
		oGridNL4:GoLine( nI )
		If oGridNL4:aCols[nI,Len(oGridNL4:aCols[nI])]
			Loop
		EndIf
		For nJ := 1 To Len(aCposNL4)
			oGridNL4:loadValue(aCposNL4[nJ],0)
		Next nJ
	Next nI	
	
	//Se limpia grid de percepciones	
	aItemsI	:= {}
	AADD(aItemsI,{"","","",""})
	oLbxI:SetArray( aItemsI ) 
	oLbxI:bLine := {|| aEval(aItemsI[oLbxI:nAt],{|z,w| aItemsI[oLbxI:nAt,w] } ) }
	oLbxI:Refresh()
	
	If cEspecie == "1" .and. cLiquid == "1"	
		//Se limpia grid de retenciones -	
		aItemsR := {}
		AADD(aItemsR,{" "," ",0,0,0 } )
		
		AEval( aItemsR, { | x | x[3] := AllTrim(Transform(x[3],cPictBas)), x[4] := AllTrim(Transform(x[4],cPictAlq)), x[5] := AllTrim(Transform(x[5],cPictVal)) } )
		oLbxR:SetArray( aItemsR ) 
		oLbxR:bLine := {|| aEval(aItemsR[oLbxR:nAt],{|z,w| aItemsR[oLbxR:nAt,w] } ) }
		oLbxR:Refresh()
		
		//IVA RG2300
		oGridNJC:LoadValue("NJC_IVARG2",0)
		//Otras retenciones
		oGridNJC:LoadValue("NJC_OTRRET",0)
		//Retenciones AFI
		oGridNJC:LoadValue("NJC_RETAFI",0)
		
		lRev	:= .T.
	EndIf
	
	//Se detonadan con un valor 0 para actualizar los totalizadores.
	oModel:LoadValue('TOTAL', 'TTLDED',0)
	oModel:LoadValue('TOTAL', 'IMPIVA',0)
	oModel:LoadValue('TOTAL', 'OPEIVA',0)
	oModel:LoadValue('TOTAL', 'RETAFI',0)
	oModel:LoadValue('TOTAL', 'OTRRET',0)
	oModel:LoadValue('TOTAL', 'IVARG2',0)
	oModel:LoadValue('TOTAL', 'IMPNAP',0)
	oModel:LoadValue('TOTAL', 'PAGSCO',0)
	oModel:LoadValue('TOTAL', 'CREDEB',0)
	
	//Se regresa status a liquidación
	oGridNJC:LoadValue("NJC_LIQ","1")
	
	//Se borran las retenciones
	aReten		:= {{},{},{},{},{}}
	
Return

/*
{Protheus.doc} F828DelRet() Borra los impuestos de la preliquidación.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Function F828DelRet(cPreLiq,cFornec,cLoja,lGan) 
Local nResult	:= 0
Default lGan 	:= .F.

	DbSelectArea("FKR")
	DbSetOrder(2) //FKR_FILIAL+FKR_CODIGO+FKR_FORNEC+FKR_LOJA
	If FKR->(MsSeek(xFilial("FKR") + cPreLiq + cFornec + cLoja ))
		cStrSql := "DELETE FROM "+ RETSQLNAME("FKR") 
		cStrSql += " WHERE FKR_FILIAL = '"+xFilial("FKR")+"' AND"
		cStrSql += " FKR_CODIGO = '"+cPreLiq+"' AND"
		cStrSql += " FKR_FORNEC = '"+cFornec+"' AND"
		cStrSql += " FKR_LOJA = '"+cLoja+"'"
		            
		nResult := TCSQLEXEC(cStrSql)
		If nResult < 0
		   While FKR->(!Eof()) .and. (FKR->(FKR_CODIGO+FKR_FORNEC+FKR_LOJA) == cPreLiq + cFornec + cLoja) 
		
				RecLock("FKR",.F.)
				FKR->(DbDelete())
				FKR->(MsUnlock())
				
				FKR->(DbSkip())
			EndDo
		EndIf
	EndIf

Return

/*
{Protheus.doc} F828DelRet() asigna los totalizadores a los campos correspondientes.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function GetTot(oModel)
	
	//Local lRet 		:= .T.
	Local aArea 	:= GetArea()
	Local aAreaNJC	:= NJC->(GetArea())
	Local oMdlTotal	:= oModel:Getmodel("TOTAL")
	
	oModel := FWModelActive()
	
	//guardamos los valores de los totalizadores
	oModel:LoadValue("NJC_MASTER","NJC_PESTOT",oMdlTotal:getValue("PESTOT"))
	oModel:LoadValue("NJC_MASTER","NJC_SUBOPE",oMdlTotal:getValue("SUBTOPE"))
	oModel:LoadValue("NJC_MASTER","NJC_IMPIVA",oMdlTotal:getValue("IMPIVA"))
	oModel:LoadValue("NJC_MASTER","NJC_OPEIVA",oMdlTotal:getValue("OPEIVA"))
	oModel:LoadValue("NJC_MASTER","NJC_TOTDED",oMdlTotal:getValue("TTLDED"))
	oModel:LoadValue("NJC_MASTER","NJC_RETAFI",oMdlTotal:getValue("RETAFI"))
	oModel:LoadValue("NJC_MASTER","NJC_OTRRET",oMdlTotal:getValue("OTRRET"))
	oModel:LoadValue("NJC_MASTER","NJC_IMPNAP",oMdlTotal:getValue("IMPNAP"))
	oModel:LoadValue("NJC_MASTER","NJC_IVARG2",oMdlTotal:getValue("IVARG2"))
	oModel:LoadValue("NJC_MASTER","NJC_PAGSCO",oMdlTotal:getValue("PAGSCO"))
	oModel:LoadValue("NJC_MASTER","NJC_CREDEB",oMdlTotal:getValue("CREDEB"))
	
	RestArea(aAreaNJC)
	RestArea(aArea)
	
Return

/*
{Protheus.doc} FISA828Com() Función detonada en el commit para realizar el guardado.

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function FISA828Com(oModel)
Local nOpc		:= oModel:GetOperation()
Local lRet		:= .T.
Local cTipoLiq	:= cTipLiq
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local lInit828	:= TYPE("lFisa828") == "L" .and. lFisa828
Local oGridNL4	:= oModel:GetModel("NL4_DETAIL")

Begin Transaction
	
	If nOpc == MODEL_OPERATION_INSERT
		
	
		If cEspecie == "1"
			SD1->(DbGoto(nRecno))
			If SD1->D1_LIQGR == cTipoLiq
				lRet	:= .F.
				oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0036, STR0037)
			Else
				GetTot(oModel)
				FWFormCommit( oModel )
				If RecLock("SD1",.F.)
					SD1->D1_LIQGR := cTipoLiq
					SD1->(MsUnLock())
				EndIf
			EndIf
		Else
			SD2->(DbGoto(nRecno))
			If SD2->D2_LIQGR == cTipoLiq
				lRet	:= .F.
				oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0036, STR0037)
			Else
				GetTot(oModel)
				FWFormCommit( oModel )
				If RecLock("SD2",.F.)
					SD2->D2_LIQGR := cTipoLiq
					SD2->(MsUnLock())
				EndIf
			EndIf
		EndIf
	ElseIf nOpc == MODEL_OPERATION_DELETE
		FWFormCommit( oModel )
		If TableInDic("FKR")
			F828DelRet(NJC->NJC_CODLIQ,NJC->NJC_VENDED, NJC->NJC_LOJAVE)
		EndIf
		If cEspecie == "1"
			DbSelectArea("SD1")
			SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If SD1->(MsSeek(xFilial("SD1")+NJC->NJC_REMITO))
				While xFilial("SD1") == SD1->D1_FILIAL .And. SD1->D1_DOC == NJC->NJC_REMITO .And. SD1->D1_FORNECE == NJC->NJC_VENDED .And.;
						SD1->D1_LOJA == NJC->NJC_LOJAVE .And. SD1->D1_COD == NJC->NJC_PROD .And. SD1->D1_ITEM == NJC->NJC_ITREM 
					If RecLock("SD1",.F.)
						SD1->D1_LIQGR := "0"
						SD1->(MsUnLock())
					EndIf
					SD1->(dbSkip())
				Enddo
			EndIf
		Else
			DbSelectArea("SD2")
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(MsSeek(xFilial("SD2")+NJC->NJC_REMITO))
				While xFilial("SD2") == SD2->D2_FILIAL.And. SD2->D2_DOC == NJC->NJC_REMITO .And. SD2->D2_CLIENTE == NJC->NJC_CODPRO .And.;
						SD2->D2_LOJA == NJC->NJC_TIENDA .And. SD2->D2_COD == NJC->NJC_PROD .And. SD2->D2_ITEM == NJC->NJC_ITREM
					If RecLock("SD2",.F.)
						SD2->D2_LIQGR := "0"
						SD2->(MsUnLock())
					EndIf
					SD2->(dbSkip())
				Enddo
			EndIf
		EndIf
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		GetTot(oModel)
		FWFormCommit( oModel )
		If cEspecie == "1" .and. cLiquid == "1" .and. TableInDic("FKR")
			IF  oGridNL4:IsUpdated() .And. lRev 		
				F828DelRet(M->NJC_CODLIQ,M->NJC_VENDED, M->NJC_LOJAVE)
				lRev := .F.
			Elseif oGridNL4:IsUpdated() .And. !lRev 
				lRet	:= .F.
				oModel:SetErrorMessage('', '' , '' , '' , STR0032, STR0073, STR0037)		
			EndIf
			F828IncRet()
		EndIf
	EndIf
	
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
End Transaction

Return lRet

Function VLDLSG()
Local cTipo		:= ""
Local cEspec	:= ""
Local cStatus	:= ""
Local lAutomato := IsBlind()


cTipo		:= NJC->NJC_TPLIQ
cEspec		:= NJC->NJC_ESPLIQ
cStatus 	:= AllTrim(NJC->NJC_STATUS)

IF cTipo == "2" .and. cEspec == "1" // Secundaria e Compras.
	
	If alltrim(NJC_STATUS) $ '1' .And. NJC_LIQ=='1'
		HELP(" ",1,"FISA828LSGC",,OemToAnsi(STR0062) ,1,0)
	ElseIf cStatus == "2"
		HELP(" ",1,"FISA828LSGC",,OemToAnsi(STR0061) ,1,0)
	Else
		If lAutomato
			FIS828GRVFIN()
		Else
			Processa( {||FIS828GRVFIN() }, OemToAnsi(STR0022),"", .T. )
		EndIf
	EndIf
Else
	HELP(" ",1,"FISA828LSGC",,OemToAnsi(STR0060) ,1,0)
EndIf

Return

/*
{Protheus.doc} AgroRetIVA() Función detonada para el calculo de retenciones de IVA para LPG

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/
Static Function AgroRetIVA(cAgente,nSigno,nValor,cCF,nProp,cSerieNF)
Local aSFEIVA  	:= {}
Local lCalRep	:= .F.
Local lCalcVen	:= .F.
Local lSento 	:= .F.
Local nPercRet	:= 0
Local nRetIva 	:= 0
Local nRetTotal	:= 0
Local nTotRet	:= 0
Local lCalcCbu	:= .F.
Local cCodCat	:= ""
Local cCodEst	:= ""
Local nPorIva	:= ""


DEFAULT cCF 	 := ""
DEFAULT nValor 	 := 0
DEFAULT nSigno	 := 1
DEFAULT nProp	 := 1
DEFAULT cSerieNF := Space(TAMSX3("FF_SERIENF")[1])

//+---------------------------------------------------------------------+
//?Obter Impostos somente qdo a Empresa Usuario for Agente de RetençŽŸo.?
//+---------------------------------------------------------------------+
aArea:=GetArea()

SA2->( dbSetOrder(1) )
SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
    
//If Subs(cAgente,2,1) == "S"
	
	//Si el proveedor es Agente de Ret., independientemente si la emp es o no agente, no se debe retener
	If SA2->A2_AGENRET == "S"
		Return aSFEIVA
	Endif

	If SA2->A2_AGENRET == "N"
	
		DbSelectArea("FX6")
		FX6->(DbSetOrder(1))
		FX6->(DbGotop())
		If FX6->(MsSeek(xFilial("FX6")+PadR( SA2->A2_CGC, TAMSX3( "FX6_CUIT" )[1])))
			cCodEst := AllTrim(STR(FX6->FX6_EST))    //FX6->FX6_CODCAT
			cCodCat := FX6->FX6_CODCAT //FX6->FX6_CATEG
			SFF->(DbSetOrder(22)) //FF_FILIAL+FF_IMPOSTO+ FF_SISA+FF_TIPAGRO
			SFF->(MsSeek(xFilial("SFF")+"IVR"+cCodEst+cCodCat)) 
			If SFF->(FOUND())
				nPercRet:=SFF->FF_ALIQ				
				AAdd(aSFEIVA,array(12))
				aSFEIVA[Len(aSFEIVA)][1] := ""         		//FE_NFISCAL
				aSFEIVA[Len(aSFEIVA)][2] := ""       		//FE_SERIE
				aSFEIVA[Len(aSFEIVA)][3] := Round(xMoeda((nValor * nSigno),nMoedaCor,1,,5,aTxMoedas[Max(nMoedaCor,1)][2]),MsDecimais(1))	//FE_VALBASE
				aSFEIVA[Len(aSFEIVA)][4] := 0	//FE_VALIMP
				aSFEIVA[Len(aSFEIVA)][5] := SA2->A2_PORIVA   		//FE_PORCRET
				aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][3]) *(Iif(lCalRep ,1, SA2->A2_PORIVA/100))
				aSFEIVA[Len(aSFEIVA)][9] := cCF // Gravar CFOP da operaçŽ¢o
				aSFEIVA[Len(aSFEIVA)][10]:= nPercRet
				aSFEIVA[Len(aSFEIVA)][11]:= SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
				aSFEIVA[Len(aSFEIVA)][12] := 0 
				
				//Verificar a porcetagem correteado do Iva conforme informada nas datas
				If SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. SA2->(ColumnPos("A2_IVPCCOB")) > 0
					If (dDataBase >= SA2->A2_IVPDCOB .and. dDataBase <= SA2->A2_IVPCCOB)
						nPorIva := SA2->A2_PORIVA
					ElseIf (Empty(SA2->A2_IVPDCOB) .and. dDataBase <= SA2->A2_IVPCCOB)
						nPorIva := SA2->A2_PORIVA
					ElseIf (Empty(SA2->A2_IVPCCOB) .and. dDataBase >= SA2->A2_IVPDCOB)
						nPorIva := SA2->A2_PORIVA	
					Else
						nPorIva := 100
					EndIf
				Else
					nPorIva := SA2->A2_PORIVA
				EndIf
				
				// Exenciones 
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				If SFH->(MsSeek(xFilial()+SA2->A2_COD+SA2->A2_LOJA+"IVR")) .and. SFH->(ColumnPos("FH_PERCENT"))>0
					If  (SFH->FH_ISENTO == "S" .OR. SFH->FH_PERCENT == 100)
						nPorIva := 0
					ElseIf A085aVigSFH() 
						If SFH->FH_ISENTO == "S"   .OR. SFH->FH_PERCENT == 100
							nPorIva := 0
						Else
							nPorIva := SFH->FH_PERCENT
						EndIf
					Endif 
				Endif
				
				nPercRet:=SFF->FF_ALIQ/100

				If lCalRep
					nPercRet:= 1
					nRetIva:= (aSFEIVA[Len(aSFEIVA)][3])*nPercRet
				Else
					nRetIva:= ((aSFEIVA[Len(aSFEIVA)][3]) *(nPorIva/100))*nPercRet
				EndIf

				aSFEIVA[Len(aSFEIVA)][6]:= nRetIva

				If  nRetIva < SFF->FF_IMPORTE
					aEval(aSFEIVA,{|x| x[6] := 0})
				EndIf
					
			EndIf
		EndIf
	EndIf
//EndIf


RestArea(aArea)
Return aSFEIVA


/*
{Protheus.doc} AgroRetIB() Función detonada para el calculo de retenciones de IIBB para LPG

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/

Static Function AgroRetIB(cAgente,nSigno,nSaldo,cCF,cProv,nPropImp,aConfProv)
Local aZonaIb 	:= {}
Local aSFEIB	:= {}
Local aPerIB	:= {}
Local aRes      := {}
Local lCalcIb	:= .T.
Local lRet 		:= .F.
Local lIsento	:= .F.
local lGravo 	:= .T.
Local lNoIns    := .F.
Local lCalNoIns := .F.
Local lSmRMCR   := .F.
Local cProvEnt 	:= ""
Local cQuery 	:= ""
Local cTabTemp	:= ""	
Local cEmpAct	:= ""
Local cZona		:= ""
Local cSituaca  := ""
Local nJ		:= 0
Local nPosIb	:= 0
Local nRecSM0	:= 0
Local nMoeda	:= 1
Local nAliq     := 0
Local nTotRetSFE:= 0
Local nTotBasSFE:= 0
Local nLimMInRet:= 0
Local nBaseAtual:= 0
Local nRetencao	:= 0
Local nDeduc	:= 0
Local nCofRet	:= 0
Local nNumRegs 	:= 0
Local nAliqAux	:= 0
Local nCoefmul	:= 0
Local nPercTot	:= 1   
Local nAliqRet 	:= 0 
Local nAliqAdc 	:= 0 
Local nObtMin 	:= 0
Local nLmRMCR		:= 0
Local cZonaSFH := ""
Local cTipoSFH := ""
Local lAgRetCCO := .T.
Local cTipoCalc 	:= ""
Local nValorRet 	:= 0
Local cOriMin := ""
Local nCOTipMin 	:= 0
Local nTotCCO3 	:= nSaldo
Local lCCOLimRet := Iif(aConfProv[7] <> " ", .T., .F.)
Local nLimiteSFF := 0
Local lLimPrim := .F.
Local nPrAliqIB := 1
Local lAjusta	:= .F.
Local lCalc		:= .F.
Local lCalIns	:= .F.
Local nRedBase	:= 0

DEFAULT nSigno		:= 1
DEFAULT nPropImp	:= 1
DEFAULT aConfProv	:= {}
DEFAULT lOrigen		:= .F.

//?Obter Impostos somente qdo a Empresa Usuario for Agente de Retenå™­o.?

aArea:=GetArea()
If !Empty(GetMV("MV_AGIIBB",,"CF|BA|SF|SE|TU|SA|JU|SL|MI|FO|ME|ER|SJ|LR|CO|CB|CA|NE|LP|TF|CH|RN|CR")) .And. nSigno > 0
	SA2->( dbSetOrder(1) )
	SA2->( MsSeek(xFilial("SA2")+CFORNECE+CLOJA) )
	

	If SA2->(ColumnPos("A2_DTICALB")) > 0 .And. SA2->(ColumnPos("A2_DTFCALB")) > 0 ;
	   .And. !Empty(SA2->A2_DTICALB) .And. !Empty(SA2->A2_DTFCALB)
	    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALB) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALB) )
	   		lCalcIb:=.F.
	    EndIf
	EndIf

	If lCalcIb .And. SA2->A2_RETIB == "S"
		
		nMoeda := nMoedaCor
		nPosIb := Ascan(aZonaIb,{|X| X[1]==cCF .And. X[2]==cProv})

		//Por Entrega
		If aConfProv[2] == "1" .And. aConfProv[3] == "1" .And. aConfProv[1] == cProv
			cProvEnt := cProv
			lCalc := .T.
		//Por Pago
		ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "2"
			SX5->(MsSeek(xFilial()+"74"))
			cSucur := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

			nRecSM0 := SM0->(RecNo())
			cEmpAct := SM0->(M0_CODIGO)
			
			SM0->(MsSeek(cEmpAct+cSucur))
			If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
				cProvEnt := SM0->M0_ESTENT
				lCalc := .T.
			EndIf
			SM0->(DbGoto(nRecSM0))
		//Por Inscripción
		ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "3"
			cProvEnt := aConfProv[1]
			lCalIns	:= .T.
		Endif
								
		
		If CCO->(ColumnPos("CCO_TPRET")) > 0 .and. CCO->(ColumnPos("CCO_TPRENI")) > 0  
			If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) //Identifica tratamiento Retencion sujeto No inscripto
				aRes:= NoInsCCORet( aConfProv[1],cProv)
				lCalNoIns := aRes[1][2]
				lNoIns := IIf(!Empty(aRes[1][1]),.T.,.F.)  
			EndIf 	
		EndIf
		
		AAdd(aZonaIb,{cProvEnt,cCF,nSaldo,aConfProv[4],.F.,""})

		For nJ := 1 To Len(aZonaIb)
			lRet := .F.
			nBaseAtual := 0
			//Converter a base para moeda 1
			aZonaIb[nJ][3] := Round(xMoeda(aZonaIb[nJ][3],nMoeda,1,,5,aTxMoedas[nMoeda][2]),MsDecimais(1))

			SFF->(dbSetOrder(10))
			SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][2]+aZonaIb[nJ][1]+aZonaIb[nJ][4]))
						
			If SFF->(Found())
				cZona := SFF->FF_ZONFIS
				nAliq := SFF->FF_ALIQ
				nLimMInRet:= SFF->FF_IMPORTE
				nLimiteSFF := SFF->FF_LIMITE
				If SFF->FF_PRALQIB <> 0
					nPrAliqIB := SFF->FF_PRALQIB
				EndIf
				If SFF->FF_REDBASE <> 0
					aZonaIb[nJ][3] := (aZonaIb[nJ][3] * (( 100 - SFF->FF_REDBASE ) / 100 ) )
				EndIf
			Else
				SFF->(dbSetOrder(11))
				If SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]+Replicate("*",TamSx3("FF_TIPO")[1])+Replicate("*",TamSX3("FF_CFO_C")[1]) ))
					cZona := aZonaIb[nJ][1]
					nAliq := SFF->FF_ALIQ
					nLimMInRet:= SFF->FF_IMPORTE
					nLimiteSFF := SFF->FF_LIMITE
					If SFF->FF_PRALQIB <> 0
						nPrAliqIB := SFF->FF_PRALQIB
					EndIf
					If SFF->FF_REDBASE <> 0
						aZonaIb[nJ][3] := (aZonaIb[nJ][3] * (( 100 - SFF->FF_REDBASE ) / 100 ) )
					EndIf
				EndIf
			EndIf

			nDeduc := 0
			nCofRet := 0

			If !Empty(cZona) .or. (lCalNoIns)

				//****************************************************
				// SE obtienen los registros de la SFH para el proveedor
				cTabTemp := criatrab(nil,.F.)
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SFH")+ " SFH "
				cQuery += "WHERE FH_FORNECE='" + SA2->A2_COD + "' AND "
				cQuery += "FH_LOJA='"  + SA2->A2_LOJA + "' AND "
				cQuery += "FH_IMPOSTO='IBR' AND "
				cquery += "FH_ZONFIS='" + cZona +"' AND "
				cQuery += "FH_FILIAL='" +XFILIAL("SFH") + "' AND "                                                          
				
				cquery += "((FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "                                            
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE=' ') OR "
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "      
				
				cquery += "(FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE=' '))"      
				
				cQuery += " AND "
				cQuery += "D_E_L_E_T_<>'*'"
				cQuery += "ORDER BY FH_INIVIGE,FH_FIMVIGE"

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)
				TCSetField(cTabTemp,"FH_INIVIGE","D")
 				TCSetField(cTabTemp,"FH_FIMVIGE","D")

				Count to nNumRegs

				If nNumRegs > 0 // Se verifica que existan registros para el proveedor en SFH
					(cTabTemp)->(dbGoTop())
					WHILE (cTabTemp)->(!eof())   .And. ;
						(cTabTemp)->FH_FORNECE==SA2->A2_COD .AND. (cTabTemp)->FH_LOJA == SA2->A2_LOJA .And. (cTabTemp)->FH_ZONFIS == cZona .And. !lRet

						If lNoIns .Or. !((dDatabase >=(cTabTemp)->FH_INIVIGE .Or. Empty((cTabTemp)->FH_INIVIGE) ) .And. ;
							(dDatabase <= (cTabTemp)->FH_FIMVIGE .Or. Empty((cTabTemp)->FH_FIMVIGE))) 
							(cTabTemp)->(dbskip())
							Loop
						Else
							nAliqAux := nAliq 
						EndIf
						
						If !Empty((cTabTemp)->FH_INIVIGE) .And. !Empty((cTabTemp)->FH_FIMVIGE)
							IF(dDatabase >=(cTabTemp)->FH_INIVIGE ) .AND. dDatabase <= (cTabTemp)->FH_FIMVIGE
								nCoefmul := (cTabTemp)->FH_COEFMUL
								nAliqaux := (cTabTemp)->FH_ALIQ
								lIsento  := IIF((cTabTemp)->FH_ISENTO=="S"  .OR. (cTabTemp)->FH_PERCENT == 100,.T.,.F.)
								nPercTot := (100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto								
								lRet := .T.
								cSituaca := (cTabTemp)->FH_SITUACA
								cZonaSFH := (cTabTemp)->FH_ZONFIS
								cTipoSFH := (cTabTemp)->FH_TIPO
							EndIF
						Else
							If Empty((cTabTemp)->FH_INIVIGE) .and. Empty((cTabTemp)->FH_FIMVIGE)
								nCoefmul := (cTabTemp)->FH_COEFMUL
								nAliqaux := (cTabTemp)->FH_ALIQ
								lIsento  := IIF((cTabTemp)->FH_ISENTO=="S" .OR. SFH->FH_PERCENT == 100,.T.,.F.)
								nPercTot := (100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto
								cSituaca := (cTabTemp)->FH_SITUACA
								cZonaSFH := (cTabTemp)->FH_ZONFIS
								cTipoSFH := (cTabTemp)->FH_TIPO								
							Else
								If (dDatabase >= (cTabTemp)->FH_INIVIGE .and. !Empty((cTabTemp)->FH_INIVIGE)) .or. (dDatabase <= (cTabTemp)->FH_FIMVIGE .and.  !Empty((cTabTemp)->FH_FIMVIGE))
									nAliqaux := (cTabTemp)->FH_ALIQ
									lIsento  := IIF((cTabTemp)->FH_ISENTO=="S"  .OR. (cTabTemp)->FH_PERCENT == 100,.T.,.F.)
									nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto										
									nCoefmul := (cTabTemp)->FH_COEFMUL
									lRet := .T.
									cSituaca := (cTabTemp)->FH_SITUACA
									cZonaSFH := (cTabTemp)->FH_ZONFIS
									cTipoSFH := (cTabTemp)->FH_TIPO
								EndIf
							EndIf
						Endif
						
						If CCO->(ColumnPos("CCO_RPROAG")) > 0 .And. (cTabTemp)->FH_IMPOSTO ==  "IBR"
							If aConfProv[1] == (cTabTemp)->FH_ZONFIS .And. aConfProv[2] == "1" .And. aConfProv[11] == "N" .And. (cTabTemp)->FH_AGENTE == "S"
								lAgRetCCO := .F.
							EndIf
						EndIf
						
						(cTabTemp)->(dbskip())
					EndDo

					IF nAliqAux <> 0
						lRet := .T.
					EndIF

					If lRet .and. !lIsento .AND. nAliqAux <> 0	// Si se encontr?un registro y no es excento, se toma el valor de aléŸ–uota.
						//If cSituaca == "2" .and. CCO->(ColumnPos("CCO_CRFRET")) > 0
							//nAliq := nAliqAux * (1+(POSICIONE("CCO",1,xFilial("CCO")+cZOna,"CCO_CRFRET"))/100)
						//Else
						nAliq := nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB)
						//Endif 
					ElseIf lRet .and. !lIsento .AND. nAliqAux == 0 .and. nPrAliqIB<>1
						nAliq := nAliq * (1-(nPrAliqIB/100))
					EndIf
					
					aZonaIb[nJ][3] := aZonaIb[nJ][3] *nPercTot

				EndIf
				(cTabTemp)->(dbCloseArea())

				lGravo:= Iif(lCalc .or. (lCalIns .and. (nNumRegs > 0 .or. lCalNoIns)),.T.,.F.)
				
				If lCalNoIns 
					nPropImp := 1
				EndIf
				
				//****************************************************
				If !lIsento .and. lGravo

					/*If SFF->FF_REDBASE <> 0 .and. aZonaIb[nJ][3] <> 0
						aZonaIb[nJ][3] := (aZonaIb[nJ][3] * (( 100 - SFF->FF_REDBASE ) / 100 ) )
					Endif*/
					
					nRetencao := Round((((aZonaIb[nJ][3]*nPropImp)*nSigno)*(nAliq/100)),TamSX3("FE_VALIMP")[2])  //FE_VALIMP
					
					If !Empty(aConfProv[7])
						
					ElseIF nLimMInRet > 0
						If (aZonaIb[nJ][3]*nPropImp) < nLimMInRet
							nRetencao := 0
						EndIf
					ElseIf !Empty(aConfProv[9])
						If aConfProv[9] == "1"
							If (aZonaIb[nJ][3]*nPropImp) < aConfProv[10] 
								nRetencao := 0
							EndIf
						ElseIf aConfProv[9] == "2" 
							If nRetencao < aConfProv[10] 
								nRetencao := 0
							EndIf
						EndIf
					EndIf
					
					Aadd(aSFEIb,Array(33))
					aSFEIb[Len(aSFEIb)][1] := ""        	           //FE_NFISCAL*
					aSFEIb[Len(aSFEIb)][2] := ""		             //FE_SERIE*
					aSFEIb[Len(aSFEIb)][3] := (aZonaIb[nJ][3]*nPropImp)*nSigno        //FE_VALBASE
					aSFEIb[Len(aSFEIb)][4] := nAliq
					aSFEIb[Len(aSFEIb)][5] := nRetencao
					aSFEIb[Len(aSFEIb)][6] := aSFEIb[Len(aSFEIb)][5]        //FE_RETENC
					aSFEIb[Len(aSFEIb)][7] := (aZonaIb[nJ][3]*nPropImp)*nSigno //nSaldo //SE2->E2_VALOR
					aSFEIb[Len(aSFEIb)][8] := "" //SE2->E2_EMISSAO*
					aSFEIb[Len(aSFEIb)][9] := cZona
					aSFEIb[Len(aSFEIb)][10]:= "" //SE2->E2_MOEDA*
					aSFEIb[Len(aSFEIb)][11]:= SFF->FF_CFO_C   //CFO - Compra
					aSFEIb[Len(aSFEIb)][12]:= SFF->FF_CFO_V   //CFO - Venda
					aSFEIb[Len(aSFEIb)][13]:= "" //SE2->E2_TIPO*
					aSFEIb[Len(aSFEIb)][14]:= SFF->FF_CONCEPT
					aSFEIb[Len(aSFEIb)][15]:= nDeduc
				Endif
			Endif	
		Next nJ
	EndIf
EndIf
RestArea(aArea)

If !lAgRetCCO
	aSFEIB := {}
EndIf

Return aSFEIB

/*
{Protheus.doc} AGRORetGN() Función detonada para el calculo de retenciones de ganancias para LPG

@Author     Raul Ortiz
@Since     
@Project    AGRO - Argentina
@Return 	
*/

Static Function AGRORetGN(cAgente,nSigno,nValor,cFornece,cLoja,cPreLiq)
Local cCodCat	:= ""
Local cCodEst	:= ""
Local cConcepto	:= ""
Local cConcAux	:= ""
Local nDeducMes	:= 0
Local nRetMinima:= 0
Local aSFEGN	:= {}
Local nAliq		:= 0
Local nAlqNoIns	:= 0
Local nImporte	:= 0
Local nRedBase	:= 0
Local nRetenc	:= 0
Local nDeduc	:= 0
Local aArea		:= GetArea()
Local nBasTotal	:= 0
Local nImposto	:= 0 
Local nRetencMes:= 0
Local nBasRetMes:= 0
Local nImpAtual	:= 0
Local lReduzGan	:= .T.

DEFAULT nSigno	:= 1	
	
	SA2->( dbSetOrder(1) )
	SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
	
	If SA2->(ColumnPos("A2_DTIREDG")) > 0 .And. SA2->(ColumnPos("A2_DTFREDG")) > 0 ;
	   .And. !Empty(SA2->A2_DTIREDG) .And. !Empty(SA2->A2_DTFREDG)
	    If  ( Dtos(dDataBase)< Dtos(SA2->A2_DTIREDG) ) .Or. ( Dtos(Ddatabase) > Dtos(SA2->A2_DTFREDG) )
	    	lReduzGan:= .F.
	    EndIf
	EndIf
	
	If SA2->(ColumnPos("A2_DTICALG")) > 0 .And. SA2->(ColumnPos("A2_DTFCALG")) > 0 ;
	   .And. !Empty(SA2->A2_DTICALG) .And. !Empty(SA2->A2_DTFCALG)
	    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALG) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALG) )
	    	If SA2->A2_PORGAN == 0
	   			Return(aSFEGN)   			
	   		EndIf
	   	Else
	   		lReduzGan:= .F.	   		
	    EndIf
	EndIf

	DbSelectArea("FX6")
	FX6->(DbSetOrder(1))
	FX6->(DbGotop())
	If FX6->(MsSeek(xFilial("FX6")+PadR( SA2->A2_CGC, TAMSX3( "FX6_CUIT" )[1])))
		cCodEst := AllTrim(STR(FX6->FX6_EST))    //FX6->FX6_CODCAT
		cCodCat := FX6->FX6_CODCAT //FX6->FX6_CATEG
		SFF->(DbSetOrder(22)) //FF_FILIAL+FF_IMPOSTO+ FF_SISA+FF_TIPAGRO
		SFF->(MsSeek(xFilial("SFF")+"GAN"+cCodEst+cCodCat)) 
		If SFF->(FOUND())
			cConcepto := SFF->FF_ITEM
			nAliq	  := SFF->FF_ALQINSC
			nAlqNoIns := SFF->FF_ALQNOIN
			nImporte  := SFF->FF_IMPORTE
			nRedBase  := SFF->FF_REDBASE
			nRetenc	  := SFF->FF_RETENC
			
			If SA2->A2_INSCGAN == "S"
				cConcAux := cConcepto+Space(TamSx3("FF_NUM")[1] - TamSx3("FF_ITEM")[1])
				SFF->(dbSetOrder(1))
				If SFF->(MsSeek(xFilial("SFF")+cConcAux+"12"))
					nRetMinima	:=	SFF->FF_IMPORTE
				Else 
					cConcAux := Space(TamSx3("FF_NUM")[1])
					If SFF->(MsSeek(xFilial("SFF")+cConcAux+"12"))
						nRetMinima	:=	SFF->FF_IMPORTE
					Else
						cConcAux := StrZero(1,TamSx3("FF_NUM")[1])
						If SFF->(MsSeek(xFilial("SFF")+cConcAux+"12"))
							nRetMinima	:=	SFF->FF_IMPORTE
						EndIf
					EndIf				
				EndIf
			EndIf
			
			//Acumulados
			dbSelectArea("FKR")
			dbSetOrder(3)
			FKR->(MsSeek(xFilial("FKR")+cFornece+cLoja))
			If Found()
				While !Eof() .And. FKR_FILIAL  == xFilial("FKR");
					.And. FKR_FORNEC == cFornece;
					.And. FKR_LOJA    == cLoja
	
	
					If Month(FKR_EMISSA) != Month(dDataBase) .Or. YEAR(FKR_EMISSA)!=Year(dDataBase) .Or.; //Iif(!Empty(SFE->FE_DTRETOR), Month(SFE->FE_DTRETOR) != Month(dDataBase),.F.) .Or.;
						FKR_TIPO != "G" .Or. FKR_CONCEPT != cConcepto .Or. FKR_CODIGO == cPreLiq
						dbSkip()
						Loop
					EndIf
					nBasRetMes := nBasRetMes + FKR_VALBAS - FKR_DEDUC
					nDeducMes	:= nDeducMes + FKR_DEDUC
					nRetencMes := nRetencMes + FKR_RETENC
					FKR->(dbSkip())
				Enddo
			EndIf
			
			
			nBasTotal := nBasRetMes + nValor
			
			nDeduc   := nImporte - nDeducMes
			If SA2->A2_INSCGAN == "S" 
				If ( nBasTotal + nDeducMes > nImporte ) 
					nImposto := ((nRetenc) + ((nBasTotal*((100-nRedBase)/100)) - nDeduc) * (nAliq/100)) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
					nImpAtual:= nImposto -  nRetencMes
				EndIf
			Else
				nDeduc   := 0
				nAliq    := nAlqNoIns
				nImposto := ((nRetenc) + ((nBasTotal*((100-nRedBase)/100)) - nDeduc ) * (nAlqNoIns/100))* Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
				nImpAtual:= nImposto -  nRetencMes
			EndIf
			
			Aadd(aSFEGn,Array(12))
			aSFEGn[Len(aSFEGn)][1] := ""
			aSFEGn[Len(aSFEGn)][2] := nValor - nDeduc // FE_VALBASE
			aSFEGn[Len(aSFEGn)][3] := nAliq                                         // FE_ALIQ
			aSFEGn[Len(aSFEGn)][4] := Round(Iif(nImpAtual >= nRetMinima, nImpAtual, 0 ) * nSigno, TamSX3("FE_VALIMP")[2]) // FE_VALIMP
			aSFEGn[Len(aSFEGn)][5] := Round(Iif(nImpAtual >= nRetMinima, nImpAtual, 0 ) * nSigno, TamSX3("FE_RETENC")[2]) // FE_RETENC
			aSFEGn[Len(aSFEGn)][6] := nDeduc //FE_DEDUC
			aSFEGn[Len(aSFEGn)][7] := cConcepto                                     // FE_CONCEPT
			aSFEGn[Len(aSFEGn)][8] := Iif(lReduzGan,SA2->A2_PORGAN,100)         // FE_PORCRET
			aSFEGn[Len(aSFEGn)][9] := ""                                    // FE_CONCEPT
			aSFEGn[Len(aSFEGn)][10] := ''                              // FE_PORCRET
			aSFEGn[Len(aSFEGn)][11] := ''                              // FE_PORCRET
			aSFEGn[Len(aSFEGn)][12] := .F.
			
			
		EndIf
	EndIf

RestArea(aArea)
Return aSFEGN

Function F828auto()
Local oModel 	:= FWModelActive()
Local oGridNJC	:= oModel:getModel("NJC_MASTER")

	aDatosLiq := FIS828Rem()
	
	cTipLiq 	:= oModel:GetValue( 'NJC_MASTER', 'NJC_TIPO' )
	cEspecie 	:= oModel:GetValue( 'NJC_MASTER', 'NJC_ESPLIQ' )
	cLiquid		:= oModel:GetValue( 'NJC_MASTER', 'NJC_TPLIQ' )
	
	If Len(aDatosLiq) > 0
		oModel:LoadValue("NJC_MASTER","NJC_PROD"	, Iif(cTipLiq == "2",aDatosLiq[_COE]	,""))
		oModel:LoadValue("NJC_MASTER","NJC_PROD"	, aDatosLiq[_COD])
		oModel:LoadValue("NJC_MASTER","NJC_NOMPRO"	, aDatosLiq[_NOMPRO])
		oModel:LoadValue("NJC_MASTER","NJC_ESPECI"	, Left(aDatosLiq[_PROESP], TAMSX3("NJC_ESPECI")[1]))
		oModel:LoadValue("NJC_MASTER","NJC_DESESP"	, aDatosLiq[_NOMESP])
		oModel:LoadValue("NJC_MASTER","NJC_ITREM"	, aDatosLiq[_ITEM])
		oModel:LoadValue("NJC_MASTER","NJC_CODPGO"	, aDatosLiq[_COND])
		//oModel:LoadValue("NJC_MASTER","NJC_INFCER"	, "2")
		
		//Datos comprador
		If cEspecie == "2"
			oModel:LoadValue("NJC_MASTER","NJC_CODPRO", aDatosLiq[_CLIFOR])
			oModel:LoadValue("NJC_MASTER","NJC_TIENDA", aDatosLiq[_LOJA])
			oModel:LoadValue("NJC_MASTER","NJC_NOMCOM", Left(aDatosLiq[_NOMBRE], TAMSX3("NJC_NOMCOM")[1]))
			oModel:LoadValue("NJC_MASTER","NJC_CUITCO", Left(aDatosLiq[_CUIT], TAMSX3("NJC_CUITCO")[1]))
			oModel:LoadValue("NJC_MASTER","NJC_NROIB" , Left(aDatosLiq[_NROIB], TAMSX3("NJC_NROIB")[1]))
		EndIf
		
		//Datos Vendedor
		If cEspecie == "1"
			oModel:LoadValue("NJC_MASTER","NJC_VENDED", aDatosLiq[_CLIFOR])
			oModel:LoadValue("NJC_MASTER","NJC_LOJAVE", aDatosLiq[_LOJA])
			oModel:LoadValue("NJC_MASTER","NJC_NOMVED", aDatosLiq[_NOMBRE])
			oModel:LoadValue("NJC_MASTER","NJC_CUITVE", Left(aDatosLiq[_CUIT], TAMSX3("NJC_CUITVE")[1]))
			oModel:LoadValue("NJC_MASTER","NJC_NROIBV", aDatosLiq[_NROIB])
		EndIf
		
		oModel:LoadValue("NJC_MASTER","NJC_PRECO"	, aDatosLiq[_VALUNIT])
		oModel:LoadValue("NJC_MASTER","NJC_PESSCE"	, aDatosLiq[_QUANT]) 
		oModel:LoadValue("NJC_MASTER","NJC_TES"		, aDatosLiq[_TES])
		oModel:LoadValue("NJC_MASTER","NJC_NATUR"	, aDatosLiq[_NATUREZ])	
	
	
		//Actualiza datos del corredor
		Fis828Loj()
		
		//Actualiza datos del puerto
		Fis828Por()
	
		If cTipLiq == "2" .and. Len(aDtosLiqF) == 18
			oModel:LoadValue("NJC_MASTER","NJC_COMPRO"	, aDatosLiq[_COE])
			oModel:LoadValue("NJC_MASTER","NJC_PTOEMI"	, aDtosLiqF[_PTOEMI])
			oModel:LoadValue("NJC_MASTER","NJC_CODCTR"	, aDtosLiqF[_CODCTR])
			oModel:LoadValue("NJC_MASTER","NJC_PROPRO"	, aDtosLiqF[_PROPRO])
			oModel:LoadValue("NJC_MASTER","NJC_PROVEN"	, aDtosLiqF[_PROVEN])
			oModel:LoadValue("NJC_MASTER","NJC_PROVOR"	, aDtosLiqF[_PROVOR])
	
			
			oModel:LoadValue("NJC_MASTER","NJC_OPERAC"	, aDtosLiqF[_OPERAC])
			oModel:LoadValue("NJC_MASTER","NJC_TROCA"	, aDtosLiqF[_TROCA])
			
			oModel:LoadValue("NJC_MASTER","NJC_ACTCOR"	, aDtosLiqF[_ACTCOR])
			oModel:LoadValue("NJC_MASTER","NJC_LIQCOR"	, aDtosLiqF[_LIQCOR])
			oModel:LoadValue("NJC_MASTER","NJC_CORRED"	, aDtosLiqF[_CORRED])
			oModel:LoadValue("NJC_MASTER","NJC_LOJCOR"	, aDtosLiqF[_LOJCOR])
			oModel:LoadValue("NJC_MASTER","NJC_CUITCR"	, aDtosLiqF[_CUITCR])
			oModel:LoadValue("NJC_MASTER","NJC_NOMCOR"	, aDtosLiqF[_NOMCOR])
			oModel:LoadValue("NJC_MASTER","NJC_NOIBCR"	, aDtosLiqF[_NOIBCR])
			
			oModel:LoadValue("NJC_MASTER","NJC_DATAFP"	, aDtosLiqF[_DATAFP])
			oModel:LoadValue("NJC_MASTER","NJC_PORTO"	, aDtosLiqF[_PORTO])
			oModel:LoadValue("NJC_MASTER","NJC_NOMEPO"	, aDtosLiqF[_NOMEPO] )
			oModel:LoadValue("NJC_MASTER","NJC_CODPGO"	, aDtosLiqF[_CODPGO])
		EndIf
	
		FIS828INL4(oModel)
	EndIf

Return
