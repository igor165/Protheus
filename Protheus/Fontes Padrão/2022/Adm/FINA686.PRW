#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINA686.CH'

#DEFINE OPER_CONFERIR		10
#DEFINE OPER_ESTORNAR       20
#DEFINE OPER_VISUALIZAR     30
#DEFINE BMP_ON  "LBOK"
#DEFINE BMP_OFF "LBNO"

STATIC __nOper		:= 0
STATIC nOrdemFL6		:= 1
STATIC nTipoDoc		:= 0 //Identifica o tipo de documento gerado pela conferência
STATIC dDataDe		:= ctod("//")	//Data inicial do range de datas das viagens
STATIC dDataAte		:= ctod("//")	//Data final do range de datas das viagens
STATIC cViagemDe	:= Space(10)	//Viagem inicial do range de viagens
STATIC cViagemAte	:= Space(10)	//Viagem final do range de viagens
STATIC cPrdHotel	:= ""			//Código do produto - Hotel 
STATIC cPrdAereo	:= ""			//Código do produto - Aereo
STATIC cPrdRodov	:= ""			//Código do produto - Rodoviario
STATIC cPrdSegur	:= ""			//Código do produto - Seguros
STATIC cPrdCarro	:= ""			//Código do produto - Locacoes
STATIC cTESHotel	:= ""			//Código do TES - Hotel
STATIC cTESAereo	:= ""			//Código do TES - Aereo
STATIC cTESRodov	:= ""			//Código do TES - Rodoviario
STATIC cTESSegur	:= ""			//Código do TES - Seguros
STATIC cTESCarro	:= ""			//Código do TES - Locacoes
STATIC aHeader		:= {}			//aHeader para a tela de selecao de servicos
STATIC aCols		:= {}			//aCols para a tela de selecao de servicos
STATIC oBrwMov		:= NIL			//Objeto da Tela de selecao de servicos
STATIC aFiltro		:= {}			//Array de filtros
STATIC cAliasQry	:= ""
STATIC cFornec		:= ""			//Fornecedor para a geração do documento apos conferencia
STATIC cLoja		:= ""			//Loja para a geração do documento apos conferencia
STATIC cNaturez		:= ""			//Natureza para a geração do documento apos conferencia
STATIC nVlrInforOld := 0
STATIC __lConfirmar	:= .T.
STATIC __lBTNConfirma := .F.
STATIC __lBTNConsulta := .F.
STATIC __lMarcaTodos	 := .F.
STATIC __lConfTodos	 := NIL
STATIC __lEncTodos    := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc}FINA686
Conferência de Serviços II - Integração Reserve.

@author Mauricio Pequim Jr
@since  17/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FINA686()
Local oBrowse  := FWmBrowse():New()
Local cFiltro  := "AllTrim(FLQ->FLQ_ORIGEM) $ 'FINA686|FINA694'"	

SetKey (VK_F12,{|a,b| F686LoadPerg()})

oBrowse:SetAlias('FLQ')
oBrowse:SetDescription(STR0001)		//"Conferência de Serviços II"
oBrowse:SetFilterDefault( cFiltro )	
//Adiciona Legenda
oBrowse:AddLegend("FLQ_STATUS == '1' " , "GREEN" ,STR0002)		//"Confirmada"
oBrowse:AddLegend("FLQ_STATUS == '2' " , "RED"   ,STR0003)		//"Confirmação Estornada"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional.
@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0004	Action 'FINA686Vis'			OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina Title STR0005	Action 'FINA686Conf'		OPERATION 3 ACCESS 0	//"Conferência"
ADD OPTION aRotina Title STR0006	Action 'FINA686Est'			OPERATION 2 ACCESS 0	//"Estornar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mauricio Pequim Junior

@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel 
Local oStr1:= F686Struct('FLQ')
Local oStr2:= F686Struct('FL6')
Local oStr3:= F686Struct('FL7')
Local oStr4:= F686Struct('FL9')
Local oStr5:= F686Struct('FL8')
Local oStr6:= F686Struct('FLA')
Local oStr7:= F686Struct('FLB')
Local oStr8:= F686Struct('FLV')

oModel := MPFormModel():New('FINA686')
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FINA686', /*bPreValidacao*/, { |oModel| F686POSVL(oModel) }, { |oModel| F686GRVMD( oModel ) } , /*bCancel*/ )

oModel:addFields('FLQMASTER',,oStr1)

If __nOper == OPER_CONFERIR
	oModel:addGrid('FL6DETAIL','FLQMASTER',oStr2,{ || FL6LINPRE()} )
Else
	oModel:addgrid('FL6DETAIL','FLQMASTER',oStr2,,,,,{|oSubModel| F686CargaFL6(oSubModel)} )
	oModel:SetRelation('FL6DETAIL', { { 'FL6_FILIAL', 'xFilial("FL6")' } /*{ 'FL6_VIAGEM', 'FLV_VIAGEM' } */}, FL6->(IndexKey(1)) )
	
	If AlLTrim(TcGetDb()) $ "MSSQL#MSSQL7"
		oModel:GetModel('FL6DETAIL'):SetLoadFilter( , "FL6_VIAGEM + FL6_ITEM IN (SELECT FLV_VIAGEM + FLV_ITEM  FROM "+ RetSqlName("FLV") + " FLV WHERE FLV_CONFER = '"+FLQ->FLQ_CONFER+"')" )
	Else
		oModel:GetModel('FL6DETAIL'):SetLoadFilter( , "FL6_VIAGEM || FL6_ITEM IN (SELECT FLV_VIAGEM || FLV_ITEM  FROM "+ RetSqlName("FLV") + " FLV WHERE FLV_CONFER = '"+FLQ->FLQ_CONFER+"')" )
	Endif
Endif

oModel:addGrid('FL7DETAIL','FL6DETAIL',oStr3)
oModel:SetRelation('FL7DETAIL', { { 'FL7_FILIAL', 'xFilial("FL7")' }, { 'FL7_VIAGEM', 'FL6_VIAGEM' }, { 'FL7_ITEM', 'FL6_ITEM' } }, FL7->(IndexKey(1)) )

oModel:addGrid('FL9DETAIL','FL6DETAIL',oStr4)
oModel:SetRelation('FL9DETAIL', { { 'FL9_FILIAL', 'xFilial("FL9")' }, { 'FL9_VIAGEM', 'FL6_VIAGEM' }, { 'FL9_ITEM', 'FL6_ITEM' } }, FL9->(IndexKey(1)) )

oModel:addGrid('FL8DETAIL','FL6DETAIL',oStr5)
oModel:SetRelation('FL8DETAIL', { { 'FL8_FILIAL', 'xFilial("FL8")' }, { 'FL8_VIAGEM', 'FL6_VIAGEM' }, { 'FL8_ITEM', 'FL6_ITEM' } }, FL8->(IndexKey(1)) )

oModel:addGrid('FLADETAIL','FL6DETAIL',oStr6)
oModel:SetRelation('FLADETAIL', { { 'FLA_FILIAL', 'xFilial("FLA")' }, { 'FLA_VIAGEM', 'FL6_VIAGEM' }, { 'FLA_ITEM', 'FL6_ITEM' } }, FLA->(IndexKey(1)) )

oModel:addGrid('FLBDETAIL','FL6DETAIL',oStr7)
oModel:SetRelation('FLBDETAIL', { { 'FLB_FILIAL', 'xFilial("FLB")' }, { 'FLB_VIAGEM', 'FL6_VIAGEM' }, { 'FLB_ITEM', 'FL6_ITEM' } }, FLB->(IndexKey(1)) )

oModel:getModel('FL6DETAIL'):SetDescription(STR0007)	//'Pedidos'
oModel:getModel('FL7DETAIL'):SetDescription(STR0008)	//'Aéreo'
oModel:getModel('FL9DETAIL'):SetDescription(STR0009)	//'Hotel'
oModel:getModel('FL8DETAIL'):SetDescription(STR0010)	//'Rodoviário'
oModel:getModel('FLADETAIL'):SetDescription(STR0011)	//'Seguros'
oModel:getModel('FLBDETAIL'):SetDescription(STR0012)	//'Locação'
oModel:SetDescription(STR0013)							//'Conferência de Serviços'

//Deixa o preenchimento como opcional
oModel:getModel('FL7DETAIL'):SetOptional(.T.)
oModel:getModel('FL8DETAIL'):SetOptional(.T.)
oModel:getModel('FL9DETAIL'):SetOptional(.T.)
oModel:getModel('FLADETAIL'):SetOptional(.T.)
oModel:getModel('FLBDETAIL'):SetOptional(.T.)

//Não permite a delecao ou inclusao de novas linhas nas Grids
oModel:GetModel( 'FL6DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FL7DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FL8DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FL9DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FLADETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FLBDETAIL' ):SetNoDeleteLine( .T. )

If __nOper == OPER_ESTORNAR
	oModel:GetModel( 'FL6DETAIL' ):SetNoInsertLine( .T. )	
	oModel:GetModel( 'FL7DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FL7DETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'FL8DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FL8DETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'FL9DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FL9DETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'FLADETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FLADETAIL' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'FLBDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FLBDETAIL' ):SetNoUpdateLine( .T. )
ENDIF
	
oModel:SetVldActivate( {|oModel| F686VLMod(oModel) } )
oModel:SetActivate( {|oModel| F686LoadConf(oModel) } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mauricio Pequim Junior

@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
 
Local oStr1:= FWFormStruct(2, 'FLQ')
Local oStr2:= FWFormStruct(2, 'FL6')
Local oStr3:= FWFormStruct(2, 'FL7')
Local oStr4:= FWFormStruct(2, 'FL9')
Local oStr5:= FWFormStruct(2, 'FL8')
Local oStr6:= FWFormStruct(2, 'FLA')
Local oStr7:= FWFormStruct(2, 'FLB')

If __nOper == OPER_CONFERIR
	//Adiciona campo virtual para a view do tipo lógico.
	oStr2:AddField( 'FL6_OK' ,'02',' ','FL6_OK',, 'Check',,,,.T. )
EndIf
//Adiciona campo legenda.
oStr2:AddField( 'FL6_LEG','01','','',/*aHelp*/,"BT",/*cPicture*/,/*PictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,/*lVirtual*/,/*cPictVar*/,/*lInsertLine*/ )
//Construcao da tela
oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM2' , oStr1 ,'FLQMASTER' )
oView:AddGrid('FORM7'  , oStr2 ,'FL6DETAIL')
oView:AddGrid('FORM9'  , oStr3 ,'FL7DETAIL')
oView:AddGrid('FORM11' , oStr4 ,'FL9DETAIL')
oView:AddGrid('FORM13' , oStr5 ,'FL8DETAIL')
oView:AddGrid('FORM15' , oStr6 ,'FLADETAIL')
oView:AddGrid('FORM17' , oStr7 ,'FLBDETAIL')

oView:SetViewProperty("FORM2","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,1})      
oView:SetViewProperty("FORM7", "GRIDFILTER"	, {.T.})
oView:SetViewProperty("FORM7", "GRIDSEEK"		, {.T.})

//Box Geral
oView:CreateHorizontalBox( 'BOX1', 100)

//Divide a tela verticalmente na proporcao 70/30
oView:CreateVerticalBox( 'BOX4', 70, 'BOX1')
oView:CreateVerticalBox( 'BOXFORM2', 30, 'BOX1')

//Lado direito da tela (Fields - FLQ)
oView:SetOwnerView('FORM2','BOXFORM2')
oView:EnableTitleView('FORM2' , 'Dados da Fatura' ) 

//Lado esquerdo da tela (Grids)


oView:CreateHorizontalBox( 'BOXFORM7', 50, 'BOX4')
oView:SetOwnerView('FORM7','BOXFORM7')

//Botão marcar todos
If __nOper == OPER_CONFERIR
	oView:AddOtherObject("VIEW_BT", {|oPanel,oView| F686SelAll(oPanel,oView) })
	oView:CreateHorizontalBox( 'BOXBT', 10, 'BOX4')
	oView:SetOwnerView("VIEW_BT",'BOXBT')
EndIf

oView:CreateHorizontalBox( 'BOX5', 40, 'BOX4')
oView:CreateFolder( 'FOLDER6', 'BOX5')
oView:AddSheet('FOLDER6','SHEET13',STR0078)//'Aéreo'
oView:AddSheet('FOLDER6','SHEET12',STR0079)//'Hotel'
oView:AddSheet('FOLDER6','SHEET9' ,STR0080)//'Locação'
oView:AddSheet('FOLDER6','SHEET10',STR0081)//'Seguros'
oView:AddSheet('FOLDER6','SHEET11',STR0082)//'Rodoviário'

oView:CreateHorizontalBox( 'BOXFORM17', 100, /*owner*/, /*lUsePixel*/, 'FOLDER6', 'SHEET9')
oView:SetOwnerView('FORM17','BOXFORM17')

oView:CreateHorizontalBox( 'BOXFORM15', 100, /*owner*/, /*lUsePixel*/, 'FOLDER6', 'SHEET10')
oView:SetOwnerView('FORM15','BOXFORM15')

oView:CreateHorizontalBox( 'BOXFORM13', 100, /*owner*/, /*lUsePixel*/, 'FOLDER6', 'SHEET11')
oView:SetOwnerView('FORM13','BOXFORM13')

oView:CreateHorizontalBox( 'BOXFORM11', 100, /*owner*/, /*lUsePixel*/, 'FOLDER6', 'SHEET12')
oView:SetOwnerView('FORM11','BOXFORM11')

oView:CreateHorizontalBox( 'BOXFORM9', 100, /*owner*/, /*lUsePixel*/, 'FOLDER6', 'SHEET13')
oView:SetOwnerView('FORM9','BOXFORM9')

//Remove campos da View
//FL6 - Conferencia
//Gera titulo CP
If nTipoDoc == 1
	oStr1:RemoveField( 'FLQ_PEDIDO' )
	oStr1:RemoveField( 'FLQ_COND' 	)
	oStr1:RemoveField( 'FLQ_DCPAG'	)
	oStr1:RemoveField( 'FLQ_ORIGEM' )	
	oStr1:RemoveField( 'FLQ_PREFIX' )
	oStr1:RemoveField( 'FLQ_NUMTIT' )
	oStr1:RemoveField( 'FLQ_PARC' 	)
//Gera pedido de compra
ElseIf nTipoDoc == 2	
	oStr1:RemoveField( 'FLQ_PREFIX' )
	oStr1:RemoveField( 'FLQ_NUMTIT' )
	oStr1:RemoveField( 'FLQ_PARC' 	)
	oStr1:RemoveField( 'FLQ_VENCTO' )
	oStr1:RemoveField( 'FLQ_NATUR'  )
	oStr1:RemoveField( 'FLQ_DNATUR'	)
	oStr1:RemoveField( 'FLQ_ORIGEM' )		
//Gera Nota fiscal de Entrada
ElseIf nTipoDoc == 3
	oStr1:RemoveField( 'FLQ_PEDIDO' )
	oStr1:RemoveField( 'FLQ_VENCTO' )
	oStr1:RemoveField( 'FLQ_ORIGEM' )			
	oStr1:RemoveField( 'FLQ_PARC' 	)
Endif

//FL6 - Reservas
oStr2:RemoveField( 'FL6_LICENC' )
oStr2:RemoveField( 'FL6_TOTFEE' )
oStr2:RemoveField( 'FL6_CREDIT' )
oStr2:RemoveField( 'FL6_MULTA'  )
oStr2:RemoveField( 'FL6_MOETAX' )
oStr2:RemoveField( 'FL6_MOEDA'  )
oStr2:RemoveField( 'FL6_MENTAR' )
oStr2:RemoveField( 'FL6_TARREF' )
oStr2:RemoveField( 'FL6_TARPRO' )
oStr2:RemoveField( 'FL6_TARACO' )
oStr2:RemoveField( 'FL6_TAXSER' )
oStr2:RemoveField( 'FL6_TAXPAX' )
oStr2:RemoveField( 'FL6_TARPAX' )
oStr2:RemoveField( 'FL6_DTRESE' )
oStr2:RemoveField( 'FL6_ORIRES' )
oStr2:RemoveField( 'FL6_LOCPAS' )
oStr2:RemoveField( 'FL6_LOCALI' )
oStr2:RemoveField( 'FL6_NOMERE' )
oStr2:RemoveField( 'FL6_IDRESP' )
oStr2:RemoveField( 'FL6_PARTSO' )
oStr2:RemoveField( 'FL6_NOMESO' )
oStr2:RemoveField( 'FL6_IDSOL'  )
oStr2:RemoveField( 'FL6_EXTRA3' )
oStr2:RemoveField( 'FL6_EXTRA2' )
oStr2:RemoveField( 'FL6_EXTRA1' )
oStr2:RemoveField( 'FL6_ATIVI'  )
oStr2:RemoveField( 'FL6_MOTIVO' )
oStr2:RemoveField( 'FL6_BKOFAT' )
oStr2:RemoveField( 'FL6_FPAGTO' )
oStr2:RemoveField( 'FL6_IDREMA' )
oStr2:RemoveField( 'FL6_PARTRE' )
oStr2:RemoveField( 'FL6_STATUS' )

//ATENCAO - campos serao retirados da estrutura (duplicados)
oStr2:RemoveField( 'FL6_INFORM' )
oStr2:RemoveField( 'FL6_CONFER' )

//FL7 - Passagens Aereas
oStr3:RemoveField( 'FL7_ITEM'   )
oStr3:RemoveField( 'FL7_VIAGEM' )

//FL8 - Rodoviario 
oStr5:RemoveField( 'FL8_ITEM' )
oStr5:RemoveField( 'FL8_VIAGEM' )

//FL9 - Hospedagem 
oStr4:RemoveField( 'FL9_ITEM' )
oStr4:RemoveField( 'FL9_VIAGEM' )

//FLA - Seguro Viagem 
oStr6:RemoveField( 'FLA_ITEM' )
oStr6:RemoveField( 'FLA_VIAGEM' )

//FLB - Locacao 
oStr7:RemoveField( 'FLB_ITEM' )
oStr7:RemoveField( 'FLB_VIAGEM' )

//Ordem dos campos na grid de itens dos pedidos (FL6)
oStr2:SetProperty('FL6_VIAGEM',MVC_VIEW_ORDEM,'02')
oStr2:SetProperty('FL6_ITEM'  ,MVC_VIEW_ORDEM,'03')
oStr2:SetProperty('FL6_IDRESE',MVC_VIEW_ORDEM,'04')
oStr2:SetProperty('FL6_TIPO'  ,MVC_VIEW_ORDEM,'05')
oStr2:SetProperty('FL6_DTEMIS',MVC_VIEW_ORDEM,'06')
oStr2:SetProperty('FL6_VINFOR',MVC_VIEW_ORDEM,'07')
oStr2:SetProperty('FL6_VCONFE',MVC_VIEW_ORDEM,'08')
oStr2:SetProperty('FL6_TOTAL' ,MVC_VIEW_ORDEM,'09')
oStr2:SetProperty('FL6_DTCRIA',MVC_VIEW_ORDEM,'10')
oStr2:SetProperty('FL6_ITEM',MVC_VIEW_TITULO,STR0071) //Item

//Seta o folder de acordo com o tipo do servico
oView:SetViewProperty("FORM7","CHANGELINE",{{||F686SetFold(oModel)}})
//Seta o folder de acordo com o tipo do servico na primeira exibicao
oView:SetAfterViewActivate({|| F686SetFold(oModel)})

//Quando o tipo de documento gerado for NFE, troco a nomenclatura do campo abaixo 
If nTipoDoc == 3
	oStr1:SetProperty('FLQ_PREFIX',MVC_VIEW_TITULO,STR0014)		//'Serie'
	oStr1:SetProperty('FLQ_NUMTIT',MVC_VIEW_TITULO,STR0015)		//'Numero'
Endif

//Botoes de usuario
If  __lBTNConfirma 
	oView:AddUserButton( STR0059 , 'OK', {|oView| F686ConfEst(oView) } )	//"Confirma"
Endif

If  __lBTNConsulta 
	oView:AddUserButton( STR0063 , STR0063, {|oView| F686ConfCons(oView) } )	//"Consulta Confer."
Endif

oView:AddUserButton('Legenda','',{|oView|F686legenda()})




Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F686Struct
Monta estrutura do Model

@author pequim
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function F686Struct(cAlias)

Local oStruct 	:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX		:= 0
Local cPrefix	:= PrefixoCpo(cAlias)
Local cCampoProd:= cPrefix+'_PROD'
Local cCampoTES := cPrefix+'_TE'

If cAlias == "FLQ"
	If nTipoDoc == 1		//Contas a Pagar
		oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PREFIX" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_NUMTIT" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PARC"   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PEDIDO" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )			
		oStruct:AddTrigger( "FLQ_NATUR", "FLQ_DNATUR", {|| .T. }  , {|| Posicione("SED",1,xFilial("SED")+M->FLQ_NATUR,"ED_DESCRIC")})
		If __nOper == OPER_ESTORNAR
			oStruct:SetProperty("FLQ_FORNEC" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_LOJA"   , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_HISTOR" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_VENCTO" , MODEL_FIELD_WHEN , {|| .F. } )	
			oStruct:SetProperty("FLQ_NATUR"   , MODEL_FIELD_WHEN , {|| .F. } )
		EndIf 
	ElseIf nTipoDoc == 2	//Pedido de Compra
		oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PREFIX" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_NUMTIT" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PARC"   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_VENCTO" , MODEL_FIELD_WHEN , {|| .F. } )	
		//Gatilhos.
		oStruct:AddTrigger( "FLQ_COND" , "FLQ_DCPAG"	, {|| .T. }  , {|| Posicione("SE4",1,xFilial("SE4")+M->FLQ_COND,"E4_DESCRI")}  )
		//
		If __nOper == OPER_ESTORNAR
			oStruct:SetProperty("FLQ_FORNEC" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_LOJA"   , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_HISTOR" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_PEDIDO" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_COND"   , MODEL_FIELD_WHEN , {|| .F. } )
		EndIf 					
	ElseIf nTipoDoc == 3	//Nota Fiscal de Entrada (NFE)
		oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PARC"   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_PEDIDO" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FLQ_VENCTO" , MODEL_FIELD_WHEN , {|| .F. } )
		If __nOper == OPER_ESTORNAR
			oStruct:SetProperty("FLQ_FORNEC" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_LOJA"   , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_HISTOR" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_PREFIX" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_NUMTIT" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )			
			oStruct:SetProperty("FLQ_NATUR"  , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_COND"   , MODEL_FIELD_WHEN , {|| .F. } )
		EndIf 
		//Gatilhos.
		oStruct:AddTrigger( "FLQ_COND" , "FLQ_DCPAG"	, {|| .T. }  , {|| Posicione("SE4",1,xFilial("SE4")+M->FLQ_COND ,"E4_DESCRI")}) 
		oStruct:AddTrigger( "FLQ_NATUR", "FLQ_DNATUR", {|| .T. }  , {|| Posicione("SED",1,xFilial("SED")+M->FLQ_NATUR,"ED_DESCRIC")})
		//			
	Endif
Endif

If __nOper == OPER_CONFERIR
	If cAlias == "FL6"
		// Bloqueia todos os campos menos do VALOR INFORMADO
		oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_VINFOR" , MODEL_FIELD_WHEN , {|| .T. } )
		bVldVInfor := FwBuildFeature( STRUCT_FEATURE_VALID,"Positivo() .and. F686VLDFL6()")
		oStruct:SetProperty("FL6_VINFOR" , MODEL_FIELD_VALID , bVldVInfor )
		oStruct:AddField(' ' ,'RECNO'   ,'FL6_RECNO', 'N', 10, 0, , , , ,{||.F.} )
		oStruct:AddField(' ' ,'RECNO'   ,'FL6_ENCERRADO', 'C', 1, 0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/,{||"N"} )
		oStruct:AddField(' ' ,'OK'			  ,'FL6_OK'		,'L' ,1,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/,{||.F.},.F.,.F.,.T. ) 
		oStruct:AddTrigger('FL6_OK','FL6_VINFOR',/*bPre*/,{|oFL6| F686ValGat(oFL6)})
	EndIf

	If cAlias $ "FL7|FL8|FL9|FLA|FLB"
		oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
		If nTipodoc > 1
			oStruct:SetProperty(cCampoProd , MODEL_FIELD_WHEN , {|| .T. } )
			oStruct:SetProperty(cCampoTES  , MODEL_FIELD_WHEN , {|| .T. } )
		Endif
	Endif	
	
	If cAlias $ "FLQ"
		oStruct:AddTrigger( "FLQ_LOJA"  	, "FLQ_LOJA"  		, {|| .T. }  , {|| F686NomFor() }  )
	Endif
Endif

If cAlias == 'FL6'
	oStruct:AddField(' ' ,'FL6_LEG' ,'FL6_LEG'	,'BT',1,0,/*bValid*/, /*bWhen*/, , .F.,/*bInit*/, /*lKey*/, /*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)		
	If __nOper == OPER_ESTORNAR
		oStruct:SetProperty('FL6_ITEM'   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty('FL6_VIAGEM' , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_IDRESE" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_TIPO"   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_DTEMIS" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_VINFOR" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_VCONFE" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_TOTAL"  , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_DTCRIA" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_ITEM"   , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FL6_NRCART" , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf 
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA686Conf
Conferência de serviços
@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FINA686Conf(cAlias,nReg,nOpc,lAutomato)

Local cTitulo		:= STR0013		//"Conferência de Serviços"
Local cPrograma		:= 'FINA686'
Local nOperation	:= MODEL_OPERATION_INSERT
Local nSelTipo		:= 0
Local lRet			:= .T.
Local aPergAux		:= {}

Default lAutomato	:= .F.

aFiltro := {}

//Carrega pergunta FINA686 que contém o tipo de documento gerado
If !lAutomato
	F686LoadPerg(.F.)
EndIf

//Parâmetros para filtragem dos dados
If Pergunte("FINA686A",.T.)
	dDataDe		:= mv_par01
	dDataAte	:= mv_par02
	cViagemDe	:= mv_par03
	cViagemAte	:= mv_par04
	nSelTipo	:= mv_par05
	nOrdemFL6	:= If (mv_par06 == 1,1,3) 
	
	/*
	Caso não selecione tipo, verifico se os códigos de TES e Produto
	estão preenchidos para todos os serviços
	Caso não estejam, será apresentado Help e a tela de seleção de serviços
	será aberta para preenchimento
	*/ 
	Pergunte("FINA686B",.F.)
	cPrdAereo := mv_par01
	cTESAereo := mv_par02
	cPrdHotel := mv_par03
	cTESHotel := mv_par04
	cPrdCarro := mv_par05
	cTESCarro := mv_par06
	cPrdSegur := mv_par07
	cTESSegur := mv_par08
	cPrdRodov := mv_par09
	cTESRodov := mv_par10
	
	If nSelTipo == 2 .and. nTipoDoc > 1
		If Empty(cPrdHotel) .or. Empty(cTESHotel) .or. Empty(cPrdAereo) .or. Empty(cTESAereo) .or. Empty(cPrdRodov) .or. ;
		   Empty(cTESRodov) .or. Empty(cPrdSegur) .or. Empty(cTESSegur) .or. Empty(cPrdCarro) .or. Empty(cTESCarro)
			Help(" ",1,"FIN686TESPROD",,STR0016+CRLF+;	//"Você optou por considerar todos os tipos de serviços na sua conferência."
		   								STR0017+CRLF+;	//"No entanto alguns serviços não possuem TES ou Produto padrões definidos."
		   								STR0018,1,0)	//"Portanto, será aberta a tela de seleção de serviços para preenchimento das informações."
			nSelTipo := 1
		Endif
	Endif
	
	//Mostra a tela de seleção de tipos de serviço
	If nSelTipo == 1
		lRet := F686SelTipos(lAutomato,@aPergAux)
	Endif	
	
	//Monta a query filtrando o FL6
	If lRet
		cAliasQry := F686Query()
	Endif
	
	If lRet
	
		__nOper := OPER_CONFERIR
		__lBTNConsulta := .T.

		If !lAutomato
			nOpc := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
		EndIf
		
		If nOpc == 1 // Cancelou a operação faz os rollback da operação
			DisarmTransaction()
		EndIf

		__lBTNConsulta := .F.

	Endif
	
	If !Empty(cAliasQry) .And. !lAutomato
		(cAliasQry)->(dbCloseArea())
		cAliasQry := ""
	Endif
	
Endif
 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F686VLMod
Inicializador do Model

@author pequim

@since 13/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F686VLMod(oModel)

Local lRet		:= .T.

//Adiantamento encerrado
If __nOper == OPER_ESTORNAR .and. FLQ->FLQ_STATUS == "2" 
	Help(" ",1,"F686ESTORNADO",,STR0019 ,1,0)	//"Esta conferência já se encontra estornada."
	lRet := .F.
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686LoadConf
Carrega dados para a Grid dos itens de pedido a serem conferidos

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686LoadConf(oModel)

Local oModelFLQ	:= oModel:GetModel('FLQMASTER')
Local oModelFL6	:= oModel:GetModel('FL6DETAIL')	
Local aArea		:= GetArea() 
Local aAlias	:= {"FL7","FL9","FLB","FLA","FL8"}
Local aModels	:= {"FL7DETAIL","FL9DETAIL","FLBDETAIL","FLADETAIL","FL8DETAIL"}
Local nAliasGrd := 0
Local cAliasGrd	:= ""
Local cPrefix	:= ""
Local cCpoFilial:= ""
Local cCpoViag  := ""
Local cCpoItem  := ""
Local cModel	:= ""
Local oModelGrd := ""
Local nZ		:= 0
Local nTipo		:= 0
Local aStruc	:= {}
Local nCount	:= .T.
Local lFirst	:= .T.
Local lFA686Vld	:= ExistBlock( "FA686VLD" )

IF __nOper == OPER_CONFERIR 
	//Carregamento da Fields (FLQ)
	oModelFLQ:LoadValue("FLQ_FORNEC" ,  SuperGetMv("MV_RESCAGE",,"") )
	oModelFLQ:LoadValue("FLQ_LOJA"   ,  SuperGetMv("MV_RESLAGE",,"") )
	oModelFLQ:LoadValue("FLQ_NOMEFO" ,  F686NomFor()			 )
	oModelFLQ:LoadValue("FLQ_NATUR"  ,  SuperGetMv("MV_RESNTCF",,"") )
	oModelFLQ:LoadValue("FLQ_TPPGTO" ,  Alltrim(Str(nTipoDoc))		 )
	oModelFLQ:LoadValue("FLQ_ORIGEM" ,  "FINA686"  )
	If nTipoDoc > 1
		oModelFLQ:LoadValue("FLQ_VENCTO"  , dDatabase + 1		 )
	Endif
	
	//carregamento das grids
	dbSelectArea(cAliasQry)
	dbGoTop()
	While !(cAliasQry)->(Eof())

		//Valida se inclui ou não a linha na tela .T. = Inclui/ .F. = Não Inclui
		If lFA686Vld
			If !ExecBlock("FA686VLD", .F., .F.,{cAliasQry})
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf
	
		//Inclui a quantidade de linhas necessárias
		oModelFL6:AddLine()		
			
		//Vai para linha criada
		oModelFL6:GoLine( oModelFL6:Length() )	
	
		//Atribui os novos valores	
		oModelFL6:LoadValue("FL6_LEG"			,		F686Leg((cAliasQry)->FL6_STATUS))
		oModelFL6:LoadValue("FL6_FILIAL" ,  xFilial("FL6")          )
		oModelFL6:LoadValue("FL6_VIAGEM" ,  (cAliasQry)->FL6_VIAGEM )
		oModelFL6:LoadValue("FL6_ITEM"   ,  (cAliasQry)->FL6_ITEM   )	
		oModelFL6:LoadValue("FL6_IDRESE" ,  (cAliasQry)->FL6_IDRESE )
		oModelFL6:LoadValue("FL6_DTCRIA" ,  (cAliasQry)->FL6_DTCRIA )
		oModelFL6:LoadValue("FL6_TIPO"   ,  (cAliasQry)->FL6_TIPO   )
		oModelFL6:LoadValue("FL6_DTEMIS" ,  (cAliasQry)->FL6_DTEMIS )
		oModelFL6:LoadValue("FL6_VCONFE" ,  (cAliasQry)->FL6_VCONFE )
		oModelFL6:LoadValue("FL6_TOTAL"  ,  (cAliasQry)->FL6_TOTAL  )
		oModelFL6:LoadValue("FL6_STATUS" ,  (cAliasQry)->FL6_STATUS )
	
		If __nOper == OPER_CONFERIR 
			oModelFL6:LoadValue("FL6_VINFOR" ,  (cAliasQry)->FL6_VINFOR )
		Else
			oModelFL6:LoadValue("FL6_VINFOR" ,  (cAliasQry)->FLV_VALOR )
		Endif	
	
		If __nOper != OPER_VISUALIZAR
			oModelFL6:LoadValue("FL6_RECNO"  ,  (cAliasQry)->FL6RECNO   )
		Endif
			
		nTipo 		:= Val((cAliasQry)->FL6_TIPO)
		cAliasGrd	:= aAlias[nTipo]
		cModel		:= aModels[nTipo]
		cPrefix	 	:= PrefixoCpo(cAliasGrd)
		cCpoFilial 	:= cPrefix+'_FILIAL'
		cCpoViag 	:= cPrefix+'_VIAGEM'
		cCpoItem 	:= cPrefix+'_ITEM'
		lFirst		:= .T.
		
		//Carrega a model Filha
		dbSelectArea(cAliasGrd)
		dbSetOrder(1)
		aStruc := (cAliasGrd)->(dbStruct())
		If MsSeek(xFilial(cAliasGrd)+(cAliasQry)->FL6_VIAGEM+(cAliasQry)->FL6_ITEM)
			While !(cAliasGrd)->(Eof()) .and. xFilial(cAliasGrd)+(cAliasQry)->FL6_VIAGEM+(cAliasQry)->FL6_ITEM == (cAliasGrd)->&(cCpoFilial)+&(cCpoViag)+&(cCpoItem)
				oModelGrd := oModel:GetModel(cModel)
				//Inclui a quantidade de linhas necessárias
				If !lFirst
					oModelGrd:AddLine()
				Endif		
				lFirst := .F.
										
				//Vai para linha criada
				oModelGrd:GoLine( oModelGrd:Length() )	
			
				For nZ := 1 to Len(aStruc)
					//Atribui os novos valores	
					oModelGrd:LoadValue( aStruc[nZ,1],  (cAliasGrd)->&(aStruc[nZ,1]) )
				Next
	
				If nTipoDoc > 1
					If nTipo == 1		//Aereo
						oModelGrd:LoadValue( "FL7_PROD", cPrdAereo	)	
						oModelGrd:LoadValue( "FL7_TE"  , cTESAereo	)
					ElseIf nTipo == 2	//Hotel  
						oModelGrd:LoadValue( "FL9_PROD", cPrdHotel	)	
						oModelGrd:LoadValue( "FL9_TE"  , cTESHotel 	)
					ElseIf nTipo == 3	//Locacao  
						oModelGrd:LoadValue( "FLB_PROD", cPrdCarro	)	
						oModelGrd:LoadValue( "FLB_TE"  , cTESCarro	)
					ElseIf nTipo == 4	//Seguro  
						oModelGrd:LoadValue( "FLA_PROD", cPrdSegur	)	
						oModelGrd:LoadValue( "FLA_TE"  , cTESSegur	)
					ElseIf nTipo == 5	//Rodoviario  
						oModelGrd:LoadValue( "FL8_PROD", cPrdRodov	)	
						oModelGrd:LoadValue( "FL8_TE"  , cTESRodov	)
					Endif
				Endif
	
				(cAliasGrd)->(dbSkip())
			EndDo
		Endif
		
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbSkip())
		
	Enddo

	//Posiciona a grid FL6VALOR na primeira linha
	oModel:getModel('FL6DETAIL'):GoLine( 1 )
	oModel:getModel('FL7DETAIL'):GoLine( 1 )
	oModel:getModel('FL8DETAIL'):GoLine( 1 )
	oModel:getModel('FL9DETAIL'):GoLine( 1 )
	oModel:getModel('FLADETAIL'):GoLine( 1 )
	oModel:getModel('FLBDETAIL'):GoLine( 1 )
	
	//Seto a propriedade OnlyQuery apenas depois do carregamento das grids 
	oModel:getModel('FL6DETAIL'):SetOnlyQuery(.T.)
	oModel:getModel('FL7DETAIL'):SetOnlyQuery(.T.)
	oModel:getModel('FL9DETAIL'):SetOnlyQuery(.T.)
	oModel:getModel('FL8DETAIL'):SetOnlyQuery(.T.)
	oModel:getModel('FLADETAIL'):SetOnlyQuery(.T.)
	oModel:getModel('FLBDETAIL'):SetOnlyQuery(.T.)
	
	//Desabilito a insercao de novas linhas nas grids das mesmas
	oModel:GetModel( 'FL6DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FL7DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FL8DETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'FL9DETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'FLADETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'FLBDETAIL' ):SetNoInsertLine( .F. )
Else
	oModelFL6:LoadValue("FL6_LEG",F686Leg(oModelFL6:GetValue('FL6_STATUS')))	
Endif

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} F686SetFold
Seta o folder na View de acordo com o conteúdo de FL6_TIPO

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function F686SetFold(oModel)

Local oModelFL6 := oModel:GetModel('FL6DETAIL')
Local oView   	:= FWViewActive()
Local cTipo    	:= oModelFL6:GetValue('FL6_TIPO')   
Local nCount  	:= 1 
Local nFolder	:= 1

nFolder := Val(cTipo)

If oView != NIL
	If !Empty(cTipo) .AND. Val(cTipo) > 0 
		For nCount := 1 To 5
			oView:HideFolder('FOLDER6',nCount,2) 
	    Next
	    oView:SelectFolder('FOLDER6',nFolder,2)
	EndIf
Endif


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F686LoadPerg
Carrega pergunta FINA686 que contém o tipo de documento gerado
após a confirmação da conferencia (Titulo CP, NFE ou Pedido de Compra)

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686LoadPerg(lMostra,nOpcAut)

Default lMostra := .T.
Default nOpcAut := 0

SaveInter()

Pergunte("FINA686",lMostra)
If nOpcAut == 0
	nTipoDoc := mv_par01
Else
	nTipoDoc := nOpcAut
EndIf

RestInter()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F686SelTipos
Tela de seleção dos tipos de serviços  a serem considerados para a 
após a confirmação da conferencia (Titulo CP, NFE ou Pedido de Compra)

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686SelTipos(lAutomato,aPergAux)

Local aArea		:= GetArea()
Local aSize		:= {}
Local nX		:= 0
Local nY		:= 0
Local cArqTipos := ""
Local cTmpTipos := ""
Local lOk		:= .F.
Local oDlgConc
Local aAltera	:= {}
Local cPerg		:= Padr("FINA686B",Len(SX1->X1_GRUPO))
Local aRetAut	:= {}

Default lAutomato	:= .F.

//Montagem do AHeader e Acols
F686CriaDados(aAltera)

If !lAutomato
	aSize := FwGetDialogSize(oMainWnd)          
	oDlgConc := TDialog():New(aSize[1],aSize[2],200,975,STR0020,,,,,,,,,.T.,,,,975,200)	//"Seleção de serviços"

	oBrwMov:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,,,, aAltera,,5,,,"F686Del()",oDlgConc,aHeader,aCols)   
	oBrwMov:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwMov:oBrowse:blDblClick:={|| If( oBrwMov:oBrowse:nColPos == 1 , F686Mark(@oBrwMov), oBrwMov:EditCell() ) }

	oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| IF(F686TudoOk(),(lOk:= .T.,oDlgConc:End()), )},{|| lOk:= .F.,oDlgConc:End() },.F.)}
	oDlgConc:Activate(,,,.T.,,,)
Else
	lOk := F686TudoOk(lAutomato)
EndIf

Pergunte(cPerg,.F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

//Monta o array com as informações de cada serviço selecionado
If lOk
	
	//Array dos Filtros
	For nX := 1 to Len(aCols)
		If aCols[nX,1] == BMP_ON
			//Caso  algum serviço selecionado não possua codigo de produto ou TES, aviso e volto para tela de seleção
			//aFiltro[1] = Tipo de serviço (1 = Hotel,2 = Aéreo, 3 = Locações, 4 = Seguros, 5= Rodoviário)
			//aFiltro[2] = Código do Produto
			//aFiltro[3] = Código do TES
			//aFiltro[4] = Filtro a ser aplicado aos fornecedores  		
			AADD(aFiltro,{nX,aCols[nX,3],aCols[nX,5],Alltrim(aCols[nX,7])})
		Else
			AADD(aFiltro,{0,"","",""})		
		Endif

		//Grava os valores informados na tela do tipo do servi‡o
		If nTipoDoc > 1
			//Grava codigo do Produto e codigo do TES
			If Upper(AllTrim(aCols[nX,2])) == "AEREO"
				mv_par01 := cPrdAereo := aCols[nX,3]
				mv_par02 := cTESAereo := aCols[nX,5]
			EndIf
			If Upper(AllTrim(aCols[nX,2])) == "HOTEL"
				mv_par03 := cPrdHotel := aCols[nX,3]
				mv_par04 := cTESHotel := aCols[nX,5]
			EndIf
			If Upper(AllTrim(aCols[nX,2])) == "LOCACOES"
				mv_par05 := cPrdCarro := aCols[nX,3]
				mv_par06 := cTESCarro := aCols[nX,5]
			EndIf
			If Upper(AllTrim(aCols[nX,2])) == "SEGUROS"
				mv_par07 := cPrdSegur := aCols[nX,3]
				mv_par08 := cTESSegur := aCols[nX,5]
			EndIf
			If Upper(AllTrim(aCols[nX,2])) == "RODOVIARIO"
				mv_par09 := cPrdRodov := aCols[nX,3]
				mv_par10 := cTESRodov := aCols[nX,5]
			EndIf
		Endif
	Next	

	//Salva os parâmetros selecionados no Profile do usuário
	__SaveParam(cPerg, aPergAux)

Endif

RestArea(aArea)

Return lOk


//-------------------------------------------------------------------
/*/{Protheus.doc} F686CriaDados
Cria TRB para tela de seleção de serviços

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686CriaDados(aAltera)

Local aServicos := {}
Local cUsado	:= ""

//Lê perguntas referentes a Tes e Produtos
aServicos := F686Servicos()

//Montando aHeader
//Obtenho o campo usado de um campo usado nao obriatorio
SX3->( DbSetOrder(2) )
SX3->( DbSeek("CT5_HIST") )
cUsado := SX3->X3_USADO

aHeader := {}
AAdd(aHeader,{" "    ,"MARCA"  ,"@BMP",4                     ,0,""                       ,cUsado,"C",""   ,"R","",""})
AAdd(aHeader,{STR0021,"SERVICO","@!"  ,20                    ,0,""                       ,cUsado,"C",""   ,"R","",""})	//"Serviço"
AAdd(aHeader,{STR0022,"PRODUTO","@!"  ,TamSX3("B1_COD")[1]   ,0,"F686VldProd(M->PRODUTO)",cUsado,"C","SB1","R","",""})	//"Produto"
AAdd(aHeader,{STR0023,"DESCPRO","@!"  ,TamSX3("B1_DESC")[1]  ,0,""                       ,cUsado,"C",""   ,"R","",""})	//"Descrição"
AAdd(aHeader,{STR0024,"TES"    ,"@!"  ,TamSX3("F4_CODIGO")[1],0,"F686VldTES(M->TES)"     ,cUsado,"C","SF4","R","",""})	//"TES"
AAdd(aHeader,{STR0025,"DESCTES","@!"  ,TamSX3("F4_TEXTO")[1] ,0,""                       ,cUsado,"C",""   ,"R","",""})	//"Texto Padrão"
AAdd(aHeader,{STR0026,"FILTRO" ,"@!"  ,20                    ,0,""                       ,cUsado,"C",""   ,"R","",""})	//"Filtro"

//Carregando aCols
aCols := F686aCols(aServicos) 

//Campos Alteraveis
aadd(aAltera, "FILTRO")
//Se o tipo de documento gerado for NFE ou Pedido de Compras, habilito preenchimento de TES e Produto
If nTipoDoc > 1
	aadd(aAltera, "PRODUTO")
	aadd(aAltera, "TES")		
Endif

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} F686MarExt
Marcação do tipo de serviço

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686Mark(oBrwMov)

If oBrwMov:aCols[oBrwMov:nAt][1] == BMP_ON
	oBrwMov:aCols[oBrwMov:nAt][1]:= BMP_OFF
Else
	oBrwMov:aCols[oBrwMov:nAt][1]:= BMP_ON
EndIf

oBrwMov:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F686TudoOk
Validação geral da tela de selecao de servicos

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686TudoOk(lAutomato)

Local lRet := .T.
Local nCount := 0
Local nX := 0	

If !lAutomato
	aCols := aClone(oBrwMov:aCols)
Else
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("FINA686TestCase") // PASSAR O ARRAY COM OS PARAMETROS PREENCHIDOS DO MARK/DESMARK
	EndIf
	
	For nX	:= 1 To Len(aRetAuto)
		aCols[nX,1] :=  aRetAuto [nX,1]
	Next nX
EndIf
//Valida se TES e Produto estão preenchidos quando o tipo de documento a ser gerado for NFE ou pedido de compras	
For nX := 1 to Len(aCols)
	If aCols[nX,1] == BMP_ON 
		nCount++
		//Caso  algum serviço selecionado não possua codigo de produto ou TES, aviso e volto para tela de seleção
		If nTipoDoc > 1 
			If ( Empty(aCols[nX,3]) .OR. Empty(aCols[nX,5]) )
				Help(" ",1,"F686TESPROD",,STR0027+CRLF+;	//"Existem serviços selecionados que não possuem TES ou Produto padrões definidos."
	   								  STR0028,1,0)		//"Por favor, informe os dados necessários."
				lRet := .F.
				Exit
			Endif
			If lRet .and. !(MaAvalTes("E",aCols[nX,5]))
				lRet := .F.
				Exit
			Endif			
		Endif  
	Endif
Next

//Caso nenhum serviço tenha sido selecionado, emite mensagem e não continua o processo, voltando para a tela de seleção.
If lRet .and. nCount == 0
	Help(" ",1,"F686NOSELEC",,STR0029+CRLF+;	//"Não foi selecionado nenhum serviço para filto da conferência de serviços.."
							  STR0030,1,0)		//"Por favor, selecione ao menos um serviço."
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F686Servicos
Gera array contendo
[1] Descrição do serviço
[2] Código do Produto
[3] Código do TES
[4] Descrição do Produto
[5] Texto Padrão da TES
[6] Filtro do usuário

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686Servicos()

Local aDesc := {}
Local aArea := GetArea()
Local aServico := {STR0008,STR0009,STR0012,STR0011,STR0010}	//"Aéreo"###"Hotel"###"Locações"###"Seguros"###"Rodoviário"

SaveInter()

Pergunte("FINA686B",.F.)

//AEREO
AADD(aDesc,{BMP_ON,aServico[1],mv_par01,Posicione("SB1",1,xFilial("SB1")+mv_par01,"B1_DESC"),mv_par02,Posicione("SF4",1,xFilial("SF4")+mv_par02,"F4_TEXTO"),Space(20),.F.})
//HOTEL
AADD(aDesc,{BMP_ON,aServico[2],mv_par03,Posicione("SB1",1,xFilial("SB1")+mv_par03,"B1_DESC"),mv_par04,Posicione("SF4",1,xFilial("SF4")+mv_par04,"F4_TEXTO"),Space(20),.F.})
//LOCACOES
AADD(aDesc,{BMP_ON,aServico[3],mv_par05,Posicione("SB1",1,xFilial("SB1")+mv_par05,"B1_DESC"),mv_par06,Posicione("SF4",1,xFilial("SF4")+mv_par06,"F4_TEXTO"),Space(20),.F.})
//SEGUROS
AADD(aDesc,{BMP_ON,aServico[4],mv_par07,Posicione("SB1",1,xFilial("SB1")+mv_par07,"B1_DESC"),mv_par08,Posicione("SF4",1,xFilial("SF4")+mv_par08,"F4_TEXTO"),Space(20),.F.})
//RODOVIARIO
AADD(aDesc,{BMP_ON,aServico[5],mv_par09,Posicione("SB1",1,xFilial("SB1")+mv_par09,"B1_DESC"),mv_par10,Posicione("SF4",1,xFilial("SF4")+mv_par10,"F4_TEXTO"),Space(20),.F.})

RestInter()

RestArea(aArea)

Return(aDesc)


//-------------------------------------------------------------------
/*/{Protheus.doc} AF460aCol
Gera acols

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686aCols(aServicos)

Local nX	:= 0
Local nZ	:= 0
Local nCols	:= 0
Local aCols	:= {}
Local nTamHead := Len(aHeader)

DEFAULT aServicos := {}

For nZ := 1 to Len(aServicos)
	aAdd(aCols,Array(nTamHead+1))
	nCols ++
	//Preencho o acols da segunda a penultima linha
	For nX := 1 To nTamHead
		aCols[nCols][nX] := aServicos[nZ,nX]
	Next nX
	aCols[nCols][nTamHead+1] := .F.
Next

Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc} F686Del
Não permite deletar linha na MSNewGetdados

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686Del()

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} F686VldProd
Validação do produto na tela de seleção de serviços

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686VldProd(cProduto)

Local cDescri := ""
Local lRet	  := .F.

If !Empty(cProduto)
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cDescri := SB1->B1_DESC
		oBrwMov:aCols[oBrwMov:nAt,4] := cDescri 
		lRet := .T.
	Else
		Help(" ",1,"F686PROD",,STR0031+CRLF+;	//"O código do produto informado para o serviço não está cadastrado."
							   STR0032,1,0)		//"Por favor, verifique o código digitado. (Consulta F3 disponível)"

	Endif
Endif
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F686VldTes
Validação do TES na tela de seleção de serviços

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686VldTes(cTes)

Local cDescri := ""
Local lRet	  := .F.

If !Empty(cTes)
	SF4->(dbSetOrder(1))
	If SF4->(MsSeek(xFilial("SF4")+cTes)) 
		If MaAvalTes("E",cTes)
			cDescri := SF4->F4_TEXTO
			oBrwMov:aCols[oBrwMov:nAt,6] := cDescri 
			lRet := .T.
		Endif
	Else
		Help(" ",1,"F686TES",,STR0033+CRLF+;	//"O código de TES informado para o serviço não está cadastrado."
							  STR0032,1,0)		//"Por favor, verifique o código digitado. (Consulta F3 disponível)."

	Endif


Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F686Query
Montagem do filtro dos dados a serem apresentados

@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F686Query()

Local cQuery 	:= ""
Local lFiltro   := .F.
Local nLenAFlt	:= Len(aFiltro)
Local nX 		:= 0
Local nY 		:= 0  
Local cTipo 	:= ""
Local aServ		:= {}
Local aFilUsr	:= {}
Local nCount	:= 0
Local nLenFilUsr:= 0

/*/
nTipoDoc	= Identifica o tipo de documento gerado pela conferência
dDataDe		= Data inicial do range de datas das viagens
dDataAte	= Data final do range de datas das viagens
cViagemDe	= Viagem inicial do range de viagens
cViagemAte	= Viagem final do range de viagens
aFiltro		= Array de filtros
/*/

If nLenAFlt > 0 
	//Obtenho os tipos de serviços selecionados
	For nX := 1 to nLenAFlt
		//aFiltro[1] = Tipo de serviço (1 = Hotel,2 = Aéreo, 3 = Locações, 4 = Seguros, 5=Rodoviário )
		//aFiltro[2] = Código do Produto
		//aFiltro[3] = Código do TES
		//aFiltro[4] = Filtro a ser aplicado aos fornecedores  		
		If aFiltro[nX,1] > 0
			cTipo += Alltrim(STR(nX))+"|"
			//Verifico se existe algum filtro de usuário
			If !Empty(aFiltro[nX,4])
				lFiltro := .T.
			Endif
		Endif 
	Next		
	aServ := StrtoKarr(cTipo,"|")
Endif

FL6->(dbSetOrder(1))

cAliasQry := GetNextAlias()

cQuery := "SELECT FL6_FILIAL, FL6_VIAGEM, FL6_ITEM, FL6_IDRESE, FL6_DTCRIA, FL6_TIPO, FL6_DTEMIS, FL6_VINFOR, FL6_VCONFE, FL6_STATUS, FL6_TOTAL, "
cQuery += "FL6.R_E_C_N_O_ FL6RECNO, FL5_STATUS FROM " + RetSQLTab('FL6')
cQuery += "INNER JOIN " + RetSQLTab('FL5') 
cQuery += " ON FL5_VIAGEM = FL6_VIAGEM "
cQuery += "WHERE "
cQuery += "FL6_FILIAL = '"+ xFilial("FL6") + "' AND "
cQuery += "FL6_DTEMIS BETWEEN '"+ Dtos(dDataDe) +"' AND '"+ Dtos(dDataAte) +"' AND "
cQuery += "FL6_VIAGEM BETWEEN '"+ cViagemDe     +"' AND '"+ cViagemAte     +"' AND "
cQuery += "FL6_STATUS <> '2' AND "
cQuery += "FL6_TIPO <> '6' AND " //Outros.
If !Empty(cTipo)
	cQuery += "FL6_TIPO IN "+ FormatIN(cTipo,"|") +" AND "
Endif
cQuery += "FL6.D_E_L_E_T_ = ' ' AND "
cQuery += "FL5_STATUS = '1' AND " //Valida se a viagem esta aprovada
cQuery += "FL5.D_E_L_E_T_ = ' ' "

//Filtro dos tipos de servicos
If lFiltro

	//Filtro do Usuário
	For nX := 1 to Len(aServ)
		
		DO CASE
			//Aereo
			CASE aServ [nX] == "1"
		
				nCount++

				cQuery += If(nCount == 1, "AND ( (", "OR (" ) 								
				cQuery += " EXISTS ( "
				cQuery += "SELECT FL7_VIAGEM "
				cQuery += "FROM "+RetSqlName("FL7")+" FL7 "
				cQuery += "WHERE FL7_FILIAL='"+xFilial("FL7")+"' AND "
				cQuery +=		"FL7_VIAGEM = FL6_VIAGEM AND "
				cQuery +=		"FL7_ITEM = FL6_ITEM  "
				
				//Se usuario digitou filtro para esse servico
				If !Empty(aFiltro[1,4])
					aFilUsr := StrtoKarr(aFiltro[1,4],";")
					nLenFilUsr := Len(aFilUsr)
					cQuery +=	" AND ( "					
					For nY := 1 to nLenFilUsr
						cQuery +=	"UPPER(FL7_NOME) LIKE '%"+aFilUsr[nY]+"%'"
						If nY != nLenFilUsr
							cQuery += " OR "
						Endif
					Next
					cQuery +=                               " ) "
				Endif
				cQuery += "AND FL7.D_E_L_E_T_ = ' ') ) "

			//Hotel
			CASE aServ [nX] == "2"
		
				nCount++

				cQuery += If(nCount == 1, "AND ( (", "OR (" ) 								
				cQuery += " EXISTS ( "
				cQuery += "SELECT FL9_VIAGEM "
				cQuery += "FROM "+RetSqlName("FL9")+" FL9 "
				cQuery += "WHERE FL9_FILIAL='"+xFilial("FL9")+"' AND "
				cQuery +=		"FL9_VIAGEM = FL6_VIAGEM AND "
				cQuery +=		"FL9_ITEM = FL6_ITEM "

				//Se usuario digitou filtro para esse servico					
				If !Empty(aFiltro[2,4])
					aFilUsr := StrtoKarr(aFiltro[2,4],";")
					nLenFilUsr := Len(aFilUsr)
					cQuery +=	" AND ( "
					For nY := 1 to nLenFilUsr
						cQuery +=	"UPPER(FL9_NOME) LIKE '%"+aFilUsr[nY]+"%'"
						If nY != nLenFilUsr
							cQuery += " OR "
						Endif
					Next
					cQuery +=                               " ) "
				Endif
				cQuery += "AND FL9.D_E_L_E_T_ = ' ') ) "

			//Locacoes
			CASE aServ [nX] == "3"
		
				nCount++

				cQuery += If(nCount == 1, "AND ( (", "OR (" ) 								
				cQuery += " EXISTS ( "
				cQuery += "SELECT FLB_VIAGEM "
				cQuery += "FROM "+RetSqlName("FLB")+" FLB "
				cQuery += "WHERE FLB_FILIAL='"+xFilial("FLB")+"' AND "
				cQuery +=		"FLB_VIAGEM = FL6_VIAGEM AND "
				cQuery +=		"FLB_ITEM = FL6_ITEM "

				//Se usuario digitou filtro para esse servico
				If !Empty(aFiltro[3,4])
					aFilUsr := StrtoKarr(aFiltro[3,4],";")
					nLenFilUsr := Len(aFilUsr)
					cQuery +=	" AND ( "
					For nY := 1 to nLenFilUsr
						cQuery +=	"UPPER(FLB_NOME) LIKE '%"+aFilUsr[nY]+"%'"
						If nY != nLenFilUsr
							cQuery += " OR "
						Endif
					Next
					cQuery +=                               " ) "
				Endif
				cQuery += "AND FLB.D_E_L_E_T_ = ' ') ) "

			//Seguro
			CASE aServ [nX] == "4"
		
				nCount++

				cQuery += If(nCount == 1, "AND ( (", "OR (" ) 								
				cQuery += " EXISTS ( "
				cQuery += "SELECT FLA_VIAGEM "
				cQuery += "FROM "+RetSqlName("FLA")+" FLA "
				cQuery += "WHERE FLA_FILIAL='"+xFilial("FLA")+"' AND "
				cQuery +=		"FLA_VIAGEM = FL6_VIAGEM AND "
				cQuery +=		"FLA_ITEM = FL6_ITEM "

				//Se usuario digitou filtro para esse servico
				If !Empty(aFiltro[4,4])
					aFilUsr := StrtoKarr(aFiltro[4,4],";")
					nLenFilUsr := Len(aFilUsr)
					cQuery +=	" AND ( "
					For nY := 1 to Len(aFilUsr)
						cQuery +=	"UPPER(FLA_NOME) LIKE '%"+aFilUsr[nY]+"%'"
						If nY != nLenFilUsr
							cQuery += " OR "
						Endif
					Next
					cQuery +=                               " ) "
				Endif
				cQuery += "AND FLA.D_E_L_E_T_ = ' ') ) "

			//Rodoviario
			CASE aServ [nX] == "5"
		
				nCount++

				cQuery += If(nCount == 1, "AND ( (", "OR (" ) 								
				cQuery += " EXISTS ( "
				cQuery += "SELECT FL8_VIAGEM "
				cQuery += "FROM "+RetSqlName("FL8")+" FL8 "
				cQuery += "WHERE FL8_FILIAL='"+xFilial("FL8")+"' AND "
				cQuery +=		"FL8_VIAGEM = FL6_VIAGEM AND "
				cQuery +=		"FL8_ITEM = FL6_ITEM "

				//Se usuario digitou filtro para esse servico
				If !Empty(aFiltro[5,4])
					aFilUsr := StrtoKarr(aFiltro[5,4],";")
					nLenFilUsr := Len(aFilUsr)
					cQuery +=	" AND ( "					
					For nY := 1 to Len(aFilUsr)
						cQuery +=	"UPPER(FL8_NOME) LIKE '%"+aFilUsr[nY]+"%'"
						If nY != nLenFilUsr
							cQuery += " OR "
						Endif
					Next
					cQuery +=                               " ) "
				Endif
				cQuery += "AND FL8.D_E_L_E_T_ = ' ') ) "
					
		END CASE	
	Next
	If nCount > 0
		cQuery += 	" ) "
	Endif

Endif

cQuery += "ORDER BY "+ SqlOrder(FL6->(IndexKey(nOrdemFL6)))
cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry, "FL6_DTEMIS", "D")
TcSetField(cAliasQry, "FL6_DTCRIA", "D")


Return (cAliasQry)


//-------------------------------------------------------------------
/*/{Protheus.doc} F686NomFor
Gatilho que retorna o nome do fornecedor

@author Mauricio Pequim Junior
@since  05/03/2014
@version 12
/*/

//-------------------------------------------------------------------
Function F686NomFor()

Local oModel	:= FWModelActive()
Local oModelFLQ	:= oModel:GetModel('FLQMASTER')
Local cNomeFor 	:= ""
Local cForn		:= oModelFLQ:GetValue('FLQ_FORNEC')
Local cLoja		:= oModelFLQ:GetValue('FLQ_LOJA')

If !Empty(cForn) .and. !Empty(cLoja)
	SA2->(dbSelectArea("SA2"))
	SA2->(dbSetOrder(1))
	If SA2->(MsSeeK(xFilial("SA2")+cForn+cLoja))
		cNomeFor := SA2->A2_NREDUZ 
	Endif
Endif

Return cNomeFor	


//-------------------------------------------------------------------
/*/{Protheus.doc} F686POSVL
Validacao do Model após a confirmacao de inclusao

@author Mauricio Pequim Jr
@since 06/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686POSVL(oModel)

Local lRet		:= .T.
Local oModelFL6	:= oModel:GetModel('FL6DETAIL')
Local nTipo		:= Val(oModelFL6:GetValue("FL6_TIPO"))
Local nX		:= 0
Local nY		:= 0
Local cModelGrd	:= ""
Local cAlias	:= ""
Local oModelGrd := NIL
Local cViagem	:= ""
Local cItem		:= ""
Local aSaveLines:= FWSaveRows()
Local aModels	:= {"FL7DETAIL","FL9DETAIL","FLBDETAIL","FLADETAIL","FL8DETAIL"}
Local cNaturez	:= oModel:GetValue("FLQMASTER","FLQ_NATUR")
Local cSerie	:= ""
Local cNumTit	:= ""
Local cFornec	:= ""
Local cLoja		:= ""

If __nOper == OPER_CONFERIR
	//Valida se houve alguma conferencia
	If !F686PedCanc(oModel:GetModel('FL6DETAIL')) .AND. oModel:GetValue("FLQMASTER","FLQ_TOTAL") == 0 
		Help(" ",1, 'F686VLRZERO',,STR0034, 1, 0 )	// 'Nenhum valor foi informado para a conferência.'
		lRet := .F.
	Endif

	If lRet
		//Geracao de Contas a Pagar
		If nTipoDoc == 1
			//Valida Natureza
			If Empty(cNaturez)	
				Help(" ",1, 'F686NATUREZ',,STR0035+CRLF+;		//'Nenhum código de natureza foi informado.'
										STR0036, 1, 0 )		//'Esta informação é obrigatória para a geração do título de contas a pagar.'
				lRet := .F.
			Endif
			SED->(dbSetOrder(1))
			If !SED->(MsSeek(xfilial("SED")+cNaturez))
				Help(" ",1, 'F686NONAT',, STR0038, 1, 0 )		//'Código de natureza não cadastrado.'
				lRet := .F.
			Endif
			//Valida Data de vencimento
			If lRet .and. Empty(oModel:GetValue("FLQMASTER","FLQ_VENCTO"))	
				Help(" ",1, 'F686VENCTO',, STR0037 +CRLF+;		//'Nenhuma data de vencimento foi informada.'
										STR0036, 1, 0 )		//'Esta informação é obrigatória para a geração do título de contas a pagar.'
				lRet := .F.
			Endif
		
		//Geração de Pedido de Compras
		ElseIf nTipoDoc == 2
			//Valida condicao de pagto
			If Empty(oModel:GetValue("FLQMASTER","FLQ_COND"))	
				Help(" ",1, 'F686CONDPG',,STR0039 +CRLF+ ;	//'O Código da condição de pagamento não foi informado.'
										STR0040, 1, 0 )	//'Esta informação é obrigatória para a geração do pedido de compras.'
				lRet := .F.
			Endif
			//Valida codigo do pedido
			cPedido := oModel:GetValue("FLQMASTER","FLQ_PEDIDO")
			If lRet .and. Empty(cPedido)	
				Help(" ",1, 'F686PEDIDO',,STR0041+CRLF+ ;	//'O Código do pedido de compras não foi informado.'
										STR0040, 1, 0 )	//'Esta informação é obrigatória para a geração do pedido de compras.'
				lRet := .F.
			Endif
			SC7->(dbSetOrder(1))
			If SC7->(MsSeek(xfilial("SC7")+cPedido))
				Help(" ",1, 'F686EXISTPED',,STR0042, 1, 0 )	//'Já existe pedido de compras com o código informado.'
				lRet := .F.
			Endif

		//Geração de Nota Fiscal de Entrada
		ElseIf nTipoDoc == 3
			//Valida Data de vencimento
			If Empty(oModel:GetValue("FLQMASTER","FLQ_VENCTO"))	
				Help(" ",1, 'F686VENCTO',,STR0037 +CRLF+ ;	//'Nenhuma data de vencimento foi informada.'
										STR0043, 1, 0 )	//'Esta informação é obrigatória para a geração da nota fiscal de entrada.'
				lRet := .F.
			Endif
			//Valida condicao de pagto
			If lRet .and. Empty(oModel:GetValue("FLQMASTER","FLQ_COND"))	
				Help(" ",1, 'F686CONDPG',,STR0039+CRLF+; 	//'O Código da condição de pagamento não foi informado.'
										STR0043, 1, 0 )	//'Esta informação é obrigatória para a geração da nota fiscal de entrada.'
				lRet := .F.
			Endif

			//Valida Natureza
			If Empty(oModel:GetValue("FLQMASTER","FLQ_NATUR"))	
				Help(" ",1, 'F686NATUREZ',,STR0035+CRLF+;	//'Nenhum código de natureza foi informado.'
										STR0043, 1, 0 )	//'Esta informação é obrigatória para a geração da nota fiscal de entrada.'
				lRet := .F.
			Endif
			SED->(dbSetOrder(1))
			If !SED->(MsSeek(xfilial("SED")+cNaturez))
				Help(" ",1, 'F686NONAT',,STR0038, 1, 0 )	//'Código de natureza não cadastrado.'
				lRet := .F.
			Endif
			//Valida numero da nota fiscal
			If lRet .and. Empty(oModel:GetValue("FLQMASTER","FLQ_NUMTIT"))	
				Help(" ",1, 'F686NUMERO',,STR0044+CRLF+; 	//'Não foi informado o número do documento de entrada.'
										STR0043, 1, 0 )	//'Esta informação é obrigatória para a geração da nota fiscal de entrada.'
				lRet := .F.
			Endif
			
			If lRet 
				cSerie	:= oModel:GetValue("FLQMASTER","FLQ_PREFIX")
				cNumTit	:= oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
				cFornec	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
				cLoja	:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
				SF1->(dbSetOrder(1))	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO	
				If SF1->(MsSeek(xfilial("SF1")+cNumTit+cSerie+cFornec+cLoja+"NFE"))
					Help(" ",1, 'F686NUMDOC',,STR0045 +CRLF+ STR0046, 1, 0 )	//'Já existe nota fiscal de entrada com mesma série, número, fornecedor e loja.'###'Verifique, por favor.'
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

	//Geração de Pedido de Compras ou Nota Fiscal de Entrada
	If lRet .and. nTipoDoc > 1
		//Valida o preenchimento da TES e Produto 
		For nX := 1 to oModelFL6:Length()
			oModelFL6:GoLine( nX )
			//Confiro apenas as linhas com valor de conferência
			If oModel:GetValue("FL6DETAIL","FL6_VINFOR") > 0
				nTipo		:= Val(oModelFL6:GetValue("FL6_TIPO"))
				cModelGrd	:= aModels[nTipo]
				cAlias		:= SubsTr(cModelGrd,1,3)
				oModelGrd 	:= oModel:GetModel(cModelGrd)
		
				For nY := 1 To oModelGrd:Length()
					oModelGrd:GoLine( nY )
					If Empty(oModel:GetValue(cModelGrd,cAlias+"_PROD")) .OR. Empty(oModel:GetValue(cModelGrd,cAlias+"_TE"))
						cViagem := oModel:GetValue(cModelGrd,cAlias+"_VIAGEM")
						cItem	:= oModel:GetValue(cModelGrd,cAlias+"_ITEM")
						Help(" ",1, 'F686PROD_TES',,STR0047 +CRLF+;				//'Não foram informados códigos de produtos ou TES para: '
													STR0048 + cViagem + CRLF+;  //'Viagem: '
													STR0049 + cItem + CRLF+;	//'Item: '
													STR0050, 1, 0 )				//'Essas informações são obrigatórias para o tipo de documento escolhido para geração após a conferência.'
						lRet := .F.
						Exit
					Endif
				Next nY
				If !lRet
					Exit
				Endif
			Endif
		Next nX
	Endif 
ENDIF

FWRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FL6LINPRE
Obtém o valor informado antes da alteração pelo usuario

@author Mauricio Pequim Jr
@since 06/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static Function FL6LINPRE()

Local lRet    := .T.
Local oModel  := FWModelActive()

nVlrInforOld := oModel:GetValue("FL6DETAIL","FL6_VINFOR")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F686VLDFL6
Valida o valor informado na conferencia
Atualiza os totalizadores de linha (FL6_TOTAL) e de conferência (FLQ_TOTAL)

@author Mauricio Pequim Jr
@since 06/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686VLDFL6()

Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oModelFLQ     := oModel:GetModel("FLQMASTER")
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local nX			:= 0
Local oView			:= FWViewActive()
Local nTotal        := 0
Local oModelFLU     := oModel:GetModel("FLUDETAIL")
Local nTotalFLU     := 0
Local nVlrInfor		:= oModelFL6:GetValue("FL6_VINFOR")
Local nVlrConfe		:= oModelFL6:GetValue("FL6_VCONFE")
Local nVlrTotFL6	:= oModelFL6:GetValue("FL6_TOTAL")
Local nVlrTotFLQ	:= oModelFLQ:GetValue("FLQ_TOTAL")
Local nValCalc		:= nVlrInfor + nVlrConfe - nVlrInforOld
Local lValOk		:= If( nValCalc == nVlrTotFL6, .T., .F. )
Local lParcial	:= .F.
Local lEncerra	:= .F.

//Verifico se o valor de conferencia é maior que o valor do pedido
If !lValOk .AND. !FWIsInCallStack('F686ValGat')
	
	If !IsBlind() 
		
		If nValCalc > nVlrTotFL6
			If __lMarcaTodos
				If __lConfTodos == Nil
					__lConfTodos := MsgYesNo( STR0073 +CRLF+ STR0074,STR0055)	//"Existem pedidos onde o valor é maior que o previsto."###"Confirma os valores ?"### 
					lRet := __lConfTodos
				Else
					lRet := __lConfTodos
				Endif
			Else
				lRet := MsgYesNo( STR0051 +CRLF+ STR0052,STR0055)	//"O Valor informado para o Pedido é maior que o valor previsto."###"Confirma este Valor ?"###
			Endif
		Else

			If __lMarcaTodos
				If __lEncTodos == Nil
					__lEncTodos := MsgYesNo( STR0076 +CRLF+ STR0077,STR0055)	//"Existem pedidos onde o valor é menor que o previsto."###"Deseja encerrar estes itens?"### 
					lEncerra := __lEncTodos
				Else
					lEncerra := __lEncTodos
				Endif
			Else
				lEncerra := MsgYesNo( STR0064 +CRLF+ STR0075,STR0055)	//"O Valor informado para o Pedido é menor que o valor previsto."###"" ?"###"Deseja encerrar este item?"
			Endif
		
			If lEncerra 
				//Coloca o item como encerrado.
				oModelFL6:LoadValue('FL6_ENCERRADO',"S")
			Else
				oModelFL6:LoadValue('FL6_ENCERRADO',"N")	
				lParcial := .T.
			EndIf
			lRet := .T.
		EndIf	
			
	Else
		
		If nValCalc > nVlrTotFL6
			Help(" " ,1, 'F686VLRINFO',,STR0054, 1, 0 )	//'O Valor informado para o Pedido é maior que o valor previsto.'
		Else
			Help(" " ,1, 'F686VLRINFO',,STR0054, 1, 0 )	//'O Valor informado para o Pedido é menor que o valor previsto.'
		EndIf
		
	Endif
	
EndIf

If lRet
	//Atualizo o valor total da conferência
	nTotal := nVlrTotFLQ - nVlrInforOld + nVlrInfor
	oModelFLQ:LoadValue( "FLQ_TOTAL" , nTotal )  
	
	//Atualizo o valor total conferido da linha
	nTotal := nVlrConfe - nVlrInforOld + nVlrInfor
	oModelFL6:LoadValue( "FL6_VCONFE" , nTotal )  
	nVlrInforOld := nVlrInfor
Else
	If !lParcial 
		Help(" ",1, 'F686VLINFO',,STR0065, 1, 0 )	//"Favor informar o valor correto."
	EndIf
Endif

If oView != Nil .And. !__lMarcaTodos
	oView:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F686GRVMD
Gravacao do Model

@author Mauricio Pequim Jr
@since 07/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686GRVMD( oModel,lAutomato )

Local lRet		:= .T.
Local oModelFL6	:= oModel:GetModel('FL6DETAIL')
Local oModelGrd := NIL
Local cModelGrd	:= ""
Local cAlias	:= ""
Local cViagem	:= ""
Local cItem		:= ""
Local cCpoProd	:= ""
Local cCpoTes	:= ""
Local cProduto	:= "" 
Local cTes	 	:= ""
Local cSubItem	:= ""
Local cStatusFL6:= ""
Local cConfer	:= ""
Local nX		:= 0
Local nY		:= 0
Local nRecnoFL6	:= 0		
Local nVlrInfor	:= 0
Local nVlrConfe	:= 0
Local nVlrTotFL6:= 0
Local nValProp	:= 0
Local nValCtrl	:= 0
Local nProp		:= 0
Local nFLQRecno := 0
Local nTipo		:= Val(oModelFL6:GetValue("FL6_TIPO"))
Local aSaveLines:= FWSaveRows()
Local aModels	:= {"FL7DETAIL","FL9DETAIL","FLBDETAIL","FLADETAIL","FL8DETAIL"}
Local aViagens	:= {}
Local aItens	:= {}
Local aArea		:= GetArea()

Default lAutomato := .F.

If __nOper != OPER_ESTORNAR

	BEGIN TRANSACTION
	//Realiza a gravação do Modelo
	FWFormCommit( oModel )
	
	nFLQRecno := FLQ->(Recno())
	cConfer	  := oModel:GetValue("FLQMASTER","FLQ_CONFER")
	
	//Realiza a gravação complementar
	//Atualiza FL6 
	For nX := 1 to oModelFL6:Length()
		oModelFL6:GoLine( nX )
		nTipo		:= Val(oModelFL6:GetValue("FL6_TIPO"))
		nRecnoFL6	:= oModelFL6:GetValue("FL6_RECNO")		
		nVlrInfor	:= oModelFL6:GetValue("FL6_VINFOR")
		nVlrConfe	:= oModelFL6:GetValue("FL6_VCONFE")
		nVlrTotFL6	:= oModelFL6:GetValue("FL6_TOTAL")
		cViagem		:= oModelFL6:GetValue("FL6_VIAGEM")
		cItem		:= oModelFL6:GetValue("FL6_ITEM")
		cModelGrd	:= aModels[nTipo]
		cAlias		:= SubsTr(cModelGrd,1,3)
		oModelGrd 	:= oModel:GetModel(cModelGrd)
		
		If nVlrInfor > 0 .OR. F686PedCanc(oModelFL6, nX)
	
			aadd(aViagens, {cViagem, cItem, nVlrInfor})
	
			//Status de conferência do item de viagem
			If nVlrConfe >= nVlrTotFL6 .OR. oModelFL6:GetValue('FL6_ENCERRADO') == "S"
				cStatusFL6 := "2"	//Conferido totalmente
			Else
				cStatusFL6 := "1" 	//Conferido parcialmente
			Endif
	
			dbSelectAreA("FL6")
			FL6->(dbGoto(nRecnoFL6))		
			RecLock("FL6",.f.)
			FL6->FL6_VCONFE := nVlrConfe
			FL6->FL6_STATUS := cStatusFL6
			MsUnlock()	
	
			nValCtrl := 0
			nProp	 := oModelGrd:Length()
			For nY := 1 To nProp
				oModelGrd:GoLine( nY )
				cCpoProd := cAlias+'_PROD'
				cCpoTes  := cAlias+'_TE'
				cSubItem := oModelGrd:GetValue( cAlias + '_SUBITM' )
				cProduto := oModelGrd:GetValue( cCpoProd ) 
				cTes	 := oModelGrd:GetValue( cCpoTes )
				//							
				If nY == nProp
					nValProp := Round(NoRound(nVlrInfor - nValCtrl,3),2)
				Else
					nValProp := Round(NoRound(nVlrInfor/nProp,3),2)
					nValCtrl += nValProp
				Endif							
				dbSelectArea(cAlias)
				dbSetOrder(1)
				//Para geracao de NFE ou Pedido de compra, guardo a informacao item a item
				If nTipoDoc > 1
					If MsSeek(xFilial(cAlias)+cViagem+cItem+cSubItem)
						RecLock(cAlias,.F.)
						&(cCpoProd) := cProduto  
			 			&(cCpoTes)  := cTes
						MsunLock()
					EndIf
				EndIf
				//				
				aAdd(aItens,{cViagem,cItem,cSubItem,cProduto,cTes,nValProp})	
			Next nY
		Endif
	Next nX
	
	
	//Geracao de Contas a Pagar
	If nTipoDoc == 1
		lRet := F686GeraTit(oModel, nFLQRecno, aItens )		
	
	//Geração de Pedido de Compras
	ElseIf nTipoDoc == 2
		lRet := F686GeraPed(oModel, nFLQRecno, aItens )
	
	//Geração de Nota Fiscal de Entrada
	ElseIf nTipoDoc == 3
		lRet := F686GeraNFE(oModel, nFLQRecno, aItens )
	
	Endif
	
	//Seto o status da viagem
	If lRet
		cViagem := ""
		cItem	:= ""
		dbSelectArea("FL5")
		dbSetOrder(1)
		For nX := 1 to Len(aViagens)
			If cViagem != aViagens[nX,1]
				cViagem := aViagens[nX,1]
				If FL5->( MsSeek( xFilial( 'FL5' ) + cViagem ) )
					Reclock("FL5",.F.)
					FL5->FL5_STATUS := FN685STAT(cViagem)
					MsUnlock()
				Endif
			Endif
			cItem   := aViagens[nX,2]
	
			//Grava tabela FLV - Pedido vs Conferencia
			RecLock("FLV",.T.)
			FLV->FLV_FILIAL := xFilial("FLV")
			FLV->FLV_CONFER	:= cConfer 
			FLV->FLV_VIAGEM := cViagem
			FLV->FLV_ITEM   := cItem
			FLV->FLV_VALOR  := aViagens[nX,3]
			FLV->FLV_STATUS := '1'
			MsUnlock()
		Next
	ElseIf nTipoDoc == 1	// Se nao gravou titulo financeiro, exibe "Título não incluso no Contas à Pagar"
		DisarmTransaction()
		Help(" ",1,"F686GRV",,STR0085,1,0)
	Else
		DisarmTransaction()
		Help(" ",1,"F686GRV",,STR0072,1,0)
	Endif
	
	END TRANSACTION
	
	FWRestRows(aSaveLines)
	
	RestArea(aArea)
EndIf


Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686GeraTit
Gera titulo contas a pagar no Financeiro (Conferencia)
Exclui titulo contas a pagar no Financeiro (Estorno de Conferencia)

@author Mauricio Pequim Jr
@since 06/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686GeraTit(oModel, nRecno, aItens )

Local aArea		:= GetArea()
Local _aTit 	:= {}
Local lRet		:= .F.
Local cPrefixo  := SuperGetMV("MV_RESPRCF",.T.,"CNF")
Local cFornece	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
Local cLoja		:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
Local cNaturez	:= oModel:GetValue("FLQMASTER","FLQ_NATUR")
Local dDtVenc	:= oModel:GetValue("FLQMASTER","FLQ_VENCTO")
Local nVlrTit	:= oModel:GetValue("FLQMASTER","FLQ_TOTAL")
Local cTipo		:= SuperGetMV("MV_RESTPCF",.T.,"DP ")
Local nTamPrf	:= TamSx3("E2_PREFIXO")[1]
Local nTamNum	:= TamSx3("E2_NUM")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamTipo	:= TamSx3("E2_TIPO")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local cNumTit	:= ""
Local aCC			:= {}
Local aAuxSEV	:= {} //Auxiliar para Natureza.
Local aAuxSEZ	:= {} //Auxiliar para Centro de Custo.
Local aRatSEZ	:= {}
Local aRatSEVEZ := {}
Local nX				:= 0
Local aAreaAnt	:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

DEFAULT nRecno 		:= 0
Default aItens			:= {}		

If nRecno > 0

	FLQ->(dbGoTo(nRecno))

	BEGIN TRANSACTION

		//Gero numero do titulo
		cNumTit	:= ProxTitulo("SE2",cPrefixo)
		
		_aTit := {}
		AADD(_aTit , {"E2_NUM"    ,PadR(cNumTit,nTamNum)           ,NIL})
		AADD(_aTit , {"E2_PREFIXO",PadR(cPrefixo,nTamPrf)          ,NIL})
		AADD(_aTit , {"E2_PARCELA",Space(nTamParc)                 ,NIL})
		AADD(_aTit , {"E2_TIPO"   ,PadR(cTipo,nTamTipo)            ,NIL})
		AADD(_aTit , {"E2_NATUREZ",PadR(cNaturez,nTamNat)          ,NIL})
		AADD(_aTit , {"E2_FORNECE",cFornece                        ,NIL})
		AADD(_aTit , {"E2_LOJA"   ,cLoja                           ,NIL})
		AADD(_aTit , {"E2_EMISSAO",dDatabase                       ,NIL})
		AADD(_aTit , {"E2_VENCTO" ,dDtVenc			               			  ,NIL})
		AADD(_aTit , {"E2_VENCREA",DataValida(dDtVenc,.T.) 		   	 ,NIL})
		AADD(_aTit , {"E2_EMIS1"  ,dDatabase                       ,NIL})
		AADD(_aTit , {"E2_MOEDA"  ,1 					           								 ,NIL})               
		AADD(_aTit , {"E2_VALOR"  ,nVlrTit		                  			 ,NIL})
		AADD(_aTit , {"E2_ORIGEM" ,"FINA686"                       ,NIL})	
		AADD(_aTit , {"E2_HIST"   ,STR0066 + oModel:GetValue('FLQMASTER','FLQ_CONFER') ,Nil})
		//Calcula a proporção do centro de custo para o título.
		aCC := F686CalcCC(oModel,aItens, 0)	
		//
		If !Empty(aCC)
		
			If Len(aCC) == 1
				AADD(_aTit , {"E2_CCUSTO" , aCC[1][1] , Nil }) 
				AADD(_aTit , {"E2_ITEMCTA", aCC[1][4] , Nil })
				AADD(_aTit , {"E2_CLVL"   , aCC[1][5] , Nil })   
			Else
				aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat),NIL})
			   aAdd( aAuxSEV ,{"EV_VALOR"   , nVlrTit , Nil })//valor do rateio na natureza
			   aAdd( aAuxSEV ,{"EV_PERC"    , 100	 , Nil })//percentual do rateio na natureza
			   aAdd( aAuxSEV ,{"EV_RATEICC" , "1"			 , Nil })//indicando que há rateio por centro de custo
			   
			   For nX := 1 To Len(aCC)
			   
				   aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1] , Nil })//centro de custo da natureza
				   aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2] , Nil })//valor do rateio neste centro de custo
				   aAdd( aAuxSEZ ,{"EZ_PERC"   ,aCC[nX][3] , NIl })
				   aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4] , Nil })
				   aAdd( aAuxSEZ ,{"EZ_CLVL"   ,aCC[nX][5] , Nil })				   
				   aAdd( aRatSEZ,aClone(aAuxSEZ))
				   aSize(aAuxSEZ,0)
				   aAuxSEZ := {}
		 		Next nX
					
				aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
				aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
				
				//
				AADD(_aTit ,{"E2_MULTNAT","1"		 	  ,NIL}) 	
				AADD(_aTit ,{"AUTRATEEV" ,aRatSEVEZ,Nil})//adicionando ao vetor aCab o vetor do rateio
			EndIf
			
		EndIf	
		
		aAreaAnt := GetArea()
		//Chamada da rotina automatica 3 = inclusao
		MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)
		
		If lMsErroAuto
			MOSTRAERRO()
			lMsErroAuto := .F.
			DisarmTransaction()
			lRet := .F.
		EndIf
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		// Se nao gravou o titulo, cancela transacao
		If !(dbSeek(xFilial("SE2")+PadR(cPrefixo,nTamPrf)+PadR(cNumTit,nTamNum)+Space(nTamParc)+PadR(cTipo,nTamTipo)))
			lRet := .F.
		Else
			lRet := .T.
		EndIf
		RestArea(aAreaAnt)	
		
		If lRet
			//Atualizo o status da conferência
			FLQ->(dbGoTo(nRecno))
			RecLock("FLQ")
			FLQ->FLQ_PREFIX	:= cPrefixo
			FLQ->FLQ_NUMTIT	:= cNumTit
			FLQ->FLQ_PARC	:= Space(nTamParc)
			FLQ->FLQ_TIPO	:= cTipo
			FLQ->FLQ_FORNEC := cFornece
			FLQ->FLQ_LOJA	:= cLoja
			MsUnLock()
		Else
			DisarmTransaction()		
		EndIf

	END TRANSACTION

Endif

RestArea(aArea)
aSize(aCC, 0)
aSize(aAuxSEV,0)		
aSize(aAuxSEZ,0)		
aSize(aRatSEZ,0)		
aSize(aRatSEVEZ,0)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686GeraNFE
Gera nota fiscal de entrada (Conferencia)
Exclui nota fiscal de entrada (Estorno de Conferencia)

@author Mauricio Pequim Jr
@since 11/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static Function F686GeraNFE(oModel , nRecno, aItensVg )
Local aArea		:= GetArea()
Local lRet		:= .F.
Local dDtVenc	:= oModel:GetValue("FLQMASTER","FLQ_VENCTO")
Local cSerie	:= oModel:GetValue("FLQMASTER","FLQ_PREFIX")
Local cDoc		:= oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
Local cFornece	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
Local cLoja		:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
Local cNaturez	:= oModel:GetValue("FLQMASTER","FLQ_NATUR")
Local cCondPag	:= oModel:GetValue("FLQMASTER","FLQ_COND")
Local cTipo		:= SuperGetMV("MV_RESTPCF",.T.,"DP ")
Local nTamSer	:= TamSx3("F1_SERIE")[1]
Local nTamDoc	:= TamSx3("F1_DOC")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local nX     	:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local aCC			:= {}
Local aRateio	:= {}
Local aAux			:= {}
Local nY				:= 0
Local cD1Item	:= ''
Local aSDE			:= {}

DEFAULT nRecno 		:= 0
DEFAULT aItensVg	:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

dbSelectArea("FLH")

If nRecno > 0

	//Seto a ordem do arquivo de cabeçalho da nota 
	DbSelectArea("SF1")	
	DbSetOrder(2)	

	aCabec := {}
	aItens := {}		

	//Inclusão da NFE
	BEGIN TRANSACTION

		aadd(aCabec, {"F1_TIPO"   	, "N"					})		
		aadd(aCabec, {"F1_FORMUL" 	, "N"					})		
		aadd(aCabec, {"F1_DOC"    	, PadR(cDoc,nTamDoc)	})		
		aadd(aCabec, {"F1_SERIE"  	, PadR(cSerie,nTamSer)	})		
		aadd(aCabec, {"F1_EMISSAO"	, dDataBase				})		
		aadd(aCabec, {"F1_FORNECE"	, cFornece				})		
		aadd(aCabec, {"F1_LOJA"   	, cLoja					})		
		aadd(aCabec, {"F1_ESPECIE"	, "NFE"					})		
		aadd(aCabec, {"F1_COND"   	, cCondPag				})
		AADD(aCabec, {'F1_ORIGLAN'   ,"CS"		            })
		AADD(aCabec, {"E2_NATUREZ"	, PadR(cNaturez,nTamNat)})
	
		For nX := 1 To Len(aItensVg)			
			aLinha := {}			
			cD1Item := StrZero(nX,TamSX3("D1_ITEM")[1])
			aAdd(aLinha,{"D1_ITEM"		, cD1Item					,Nil})
			aadd(aLinha,{"D1_COD"  	, aItensVg[nX,4]	,Nil})			
			aadd(aLinha,{"D1_QUANT"	, 1									,Nil})			
			aadd(aLinha,{"D1_VUNIT"	, aItensVg[nX,6]	,Nil})			
			aadd(aLinha,{"D1_TOTAL"	, aItensVg[nX,6]	,Nil})			
			aadd(aLinha,{"D1_TES"		, aItensVg[nX,5]	,Nil})			
			//Centro de Custo no Pedido de Compra.
			If FLH->(DbSeek(xFilial('FLH') + aItensVg[nX, 1] + aItensVg[nX, 2]))
				While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM + FLH->FLH_ITEM == (xFilial('FLH') + aItensVg[nX, 1] + aItensVg[nX, 2])
					aAdd(aCC, { FLH->FLH_CC, FLH->FLH_PORCEN, FLH->FLH_ITECTA, FLH->FLH_CLVL} )	
					FLH->(dbSkip())
				EndDo
			EndIf	
			If !Empty(aCC)
				If Len(aCC) > 1 //Preenche SCH - Rateio por Pedido de Compra.
					For nY := 1 To Len(aCC)
						aAux := {}
						aAdd(aAux, {'DE_CC'			, aCC[nY,1], Nil })
						aAdd(aAux, {'DE_PERC'		, aCC[nY,2], Nil })   			
						aAdd(aAux, {'DE_ITEM'		, StrZero(nY,TamSX3("DE_ITEM")[1])})
						aAdd(aAux, {'DE_ITEMCTA'    , aCC[nY,3], Nil})
						aAdd(aAux, {'DE_CLVL'   	, aCC[nY,4], Nil})						
						//	'
						aAdd(aRateio, aClone(aAux))
					Next nY	
					
					aAdd(aLinha,{"D1_RATEIO ", '1', Nil})
					aAdd(aSDE, {cD1Item, aClone(aRateio)} ) 
					
				Else
					aAdd(aLinha,{"D1_CC"		, aCC[1,1], Nil } )
					aAdd(aLinha,{"D1_ITEMCTA"	, aCC[1,3], Nil } )
					aAdd(aLinha,{"D1_CLVL   "	, aCC[1,4], Nil } )					
				EndIf
			EndIf	
			
			aadd(aItens,aClone(aLinha))
			aRateio	:= {}
			aAux			:= {}
			aCC			:= {}
							
		Next nX	
						
		//Inclusao de NFE                                            		
		MSExecAuto({|x,y,z,a,b,c,d,e| mata103(x,y,z,a,b,c,d,e)},aCabec,aItens,/**/,/**/,/**/,/**/,/**/,aSDE)		
	
		If lMsErroAuto
			MOSTRAERRO()
			lMsErroAuto := .F.
			DisarmTransaction()
			lRet := .F.
		Else
			lRet := .T.
			//Atualizo o status da conferência
			FLQ->(dbGoTo(nRecno))
			RecLock("FLQ")
			FLQ->FLQ_PREFIX	:= cSerie
			FLQ->FLQ_NUMTIT	:= cDoc
			FLQ->FLQ_PARC	:= Space(nTamParc)
			FLQ->FLQ_TIPO	:= "NFE"
			FLQ->FLQ_FORNEC := cFornece
			FLQ->FLQ_LOJA	:= cLoja
			MsUnLock()		
		EndIf
	
	END TRANSACTION
	
EndIf

aSize(aSDE,0)
aSDE := {}
RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686GeraPed
Gera pedido de compras  (Conferencia)
Exclui pedido de compras (Estorno de Conferencia)

@author Mauricio Pequim Jr
@since 12/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static Function F686GeraPed(oModel , nRecno, aItensVg )
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cDoc		:= oModel:GetValue("FLQMASTER","FLQ_PEDIDO")
Local cFornece	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
Local cLoja		:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
Local cCondPag	:= oModel:GetValue("FLQMASTER","FLQ_COND")
Local nTamDoc	:= TamSx3("C7_NUM")[1]
Local cC7Item := ""
Local nX     	:= 0
Local nZ				:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local aCC 			:= {}
Local aSCH			:= {}
Local aAux			:= {}
Local aRateio:= {}

DEFAULT nRecno 		:= 0
DEFAULT aItensVg	:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//Seto a ordem do arquivo de cabeçalho da nota 
DbSelectArea("SC7")	
DbSetOrder(1)
//Centro de Custo da Viagem.
DbSelectArea("FLH")
DbSetOrder(1)	

aCabec := {}
aItens := {}		

//Inclusão do pedido de compras
BEGIN TRANSACTION

	aadd(aCabec,{"C7_NUM" 		, PadR(cDoc,nTamDoc)	})
	aadd(aCabec,{"C7_EMISSAO"	, dDataBase				})
	aadd(aCabec,{"C7_FORNECE"	, cFornece				})
	aadd(aCabec,{"C7_LOJA" 		, cLoja					})
	aadd(aCabec,{"C7_COND" 		, cCondPag				})
	aadd(aCabec,{"C7_CONTATO" 	, " "					})
	aadd(aCabec,{"C7_FILENT" 	, cFilAnt				})


	For nX := 1 To Len(aItensVg)	
		aLinha := {}
		cC7Item := StrZero(nX,TamSX3("C7_ITEM")[1])
		aAdd(aLinha,{"C7_ITEM", cC7Item, Nil})
		aadd(aLinha,{"C7_PRODUTO" , aItensVg[nX,4]	,Nil})
		aadd(aLinha,{"C7_QUANT"   , 1				,Nil})
		aadd(aLinha,{"C7_PRECO"   , aItensVg[nX,6]	,Nil})
		aadd(aLinha,{"C7_TOTAL"   , aItensVg[nX,6]	,Nil})
		aadd(aLinha,{"C7_TES" 	  , aItensVg[nX,5]	,Nil})
		AADD(aLinha,{"C7_ORIGEM"  , "FINA686"       ,Nil})
		aAdd(aLinha,{"C7_OBS"		, STR0066 + oModel:GetValue('FLQMASTER','FLQ_CONFER') ,Nil}) //Conf. de Serviços
	
		//Centro de Custo no Pedido de Compra.
		If FLH->(DbSeek(xFilial('FLH') + aItensVg[nX, 1] + aItensVg[nX, 2]))
			While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM + FLH->FLH_ITEM == (xFilial('FLH') + aItensVg[nX, 1] + aItensVg[nX, 2])
				aAdd(aCC, { FLH->FLH_CC, FLH->FLH_PORCEN, FLH->FLH_ITECTA, FLH->FLH_CLVL} )	
				FLH->(dbSkip())
			EndDo
		EndIf	
			
		If !Empty(aCC)
			If Len(aCC) > 1 //Preenche SCH - Rateio por Pedido de Compra.
				For nZ := 1 To Len(aCC)
					aAux := {}
					aAdd(aAux, {'CH_FORNECE'	, cFornece , Nil})
					aAdd(aAux, {'CH_LOJA'		, cLoja	   , Nil})
					aAdd(aAux, {'CH_CC'			, aCC[nZ,1], Nil})
					aAdd(aAux, {'CH_PERC'		, aCC[nZ,2], Nil})
					aAdd(aAux, {'CH_ITEMCTA'	, aCC[nZ,3], Nil})
					aAdd(aAux, {'CH_CLVL'		, aCC[nZ,4], Nil})					   			
					aAdd(aAux, {'CH_ITEM'		, StrZero(nZ,TamSX3("CH_ITEM")[1])})
					//	
					aAdd(aRateio, aClone(aAux))
					aAdd(aLinha,{"C7_RATEIO", '1', Nil})
				Next nZ	
				
				aAdd(aSCH, {cC7Item, aClone(aRateio)} ) 
				
			Else
				aAdd(aLinha,{"C7_CC"		, aCC[1,1], Nil } )	
				aAdd(aLinha,{"C7_ITEMCTA"	, aCC[1,3], Nil } )
				aAdd(aLinha,{"C7_CLVL"		, aCC[1,4], Nil } )  
			EndIf
		EndIf	
	
		aAdd(aItens,aLinha)
		aSize(aCC, 0)
		aSize(aRateio, 0)
		aSize(aAux, 0)
		aAux := {}
		aRateio := {}
		aCC 			:= {}
	
	Next nX
	
	MATA120(1,aCabec,aItens,3, .F.,aSCH)
	
	aSize(aSCH, 0)
	aSize(aRateio,0)
	aSCH 		:= {}
	aRateio := {}
	
	If lMsErroAuto
		MOSTRAERRO()
		lMsErroAuto := .F.
		DisarmTransaction()
		lRet := .F.
	Else
		

	EndIf
	
END TRANSACTION

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA686Est
Exclusão da conferência de serviços
@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FINA686Est(cAlias,nReg,nOpc,lAutomato)

Local cTitulo		:= STR0056	//"Estorno de Conferência de Serviços"
Local cPrograma		:= 'FINA686'
Local nOperation	:=  MODEL_OPERATION_UPDATE
Local nSelTipo		:= 0
Local lRet			:= .T.
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
Local bOk			:= {|| MsgYesNo (STR0057,STR0055) }		//"Confirma o estorno desta conferêcia?"###"Atenção"

Default lAutomato	:= .F.

__nOper      := OPER_ESTORNAR

dbSelectArea("FLQ")

nTipoDoc := Val(FLQ->FLQ_TPPGTO) 

If lRet
	BeginTran()
		__lConfirmar	:= .F.
		__lBTNConfirma  := .T.
	
		If !lAutomato
			FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
		Else
			__lConfirmar := .T.
		EndIf
		
		If __lConfirmar //Confirmou o estorno da conferencia de servicos
			MsgRun( STR0057,, {||	lRet := F686GrvEst(FLQ->(Recno())) } )  //"Processando estorno de conferência..."
		Else		// Cancelou a operação faz os rollback da operação
			DisarmTransaction()
		EndIf
		
	EndTran()
Endif

If !Empty(cAliasQry) .And. !lAutomato
	(cAliasQry)->(dbCloseArea())
	cAliasQry := ""
Endif
 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA686Est
Exclusão da conferência de serviços
@author Mauricio Pequim Junior
@since  20/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FINA686Vis(cAlias,nReg,nOpc)

Local cTitulo		:= STR0058	//"Visualização de Conferência de Serviços"
Local cPrograma		:= 'FINA686'
Local nOperation	:=  MODEL_OPERATION_VIEW
Local nSelTipo		:= 0
Local lRet			:= .T.
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0060},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Fechar"

__nOper      := OPER_VISUALIZAR

dbSelectArea("FLQ")

nTipoDoc := Val(FLQ->FLQ_TPPGTO) 

If lRet
	__lBTNConfirma  := .F.
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )

Endif

If !Empty(cAliasQry)
	(cAliasQry)->(dbCloseArea())
	cAliasQry := ""
Endif
 
Return




//-------------------------------------------------------------------
/*/{Protheus.doc} F686CargaFL6
Estorno da conferencia
Carrega o valor de informado na conferencia 

@author Mauricio Pequim Jr
@since 14/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static function F686CargaFL6(oSubModel)
Local aRet		:= {}
Local aFields 	:= {}
Local aArea		:= GetArea()
Local nPosField := 0
Local nx 		:= 0
Local nPosValor	:= 0
Local nPosItem	:= 0 
Local nPosViagem := 0
Local oStruct	:= NIL
Local cViagem	:= ""
Local cItem		:= ""

@assume oSubModel as fwformgridmodel
oStruct    := oSubModel:getstruct()
aFields    := oStruct:GetFields()
nPosValor  := aScan(aFields,{|X|x[MVC_MODEL_IDFIELD] == "FL6_VINFOR"})
nPosViagem := aScan(aFields,{|X|x[MVC_MODEL_IDFIELD] == "FL6_VIAGEM"})
nPosItem   := aScan(aFields,{|X|x[MVC_MODEL_IDFIELD] == "FL6_ITEM"})
aRet       := formloadgrid(oSubModel)

dbSelectArea("FLV")
dbSetOrder(1)
If MsSeek(xFilial("FLV")+ FLQ->FLQ_CONFER)
	IF nPosValor > 0 
		For nx := 1 to Len(aRet)
			cViagem := aRet[nx][2][nPosViagem] 
			cItem	:= aRet[nx][2][nPosItem]
			If MsSeek(xFilial("FLV")+ FLQ->FLQ_CONFER+cViagem+cItem)
				aRet[nx][2][nPosValor] := FLV->FLV_VALOR
			Endif
		Next nx 
	Endif
Endif

RestArea(aArea)

Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686ConfEst
Estorno de conferência - Botao OK 

@author Mauricio Pequim Jr
@since 14/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static Function F686ConfEst(oView)

If __nOper == OPER_ESTORNAR
	If oView == Nil .Or. MsgNoYes(STR0084)	//"Confirma o estorno desta conferência ?"
		__lConfirmar := .T.
		If oView != Nil
			oView:ShowUpdateMsg(.F.)
			oView:ButtonOkAction(.T.)
		EndIf
	EndIf	
Endif

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} F686GrvEst
Estorno de conferência 

@author Mauricio Pequim Jr
@since 14/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Static function F686GrvEst(nFLQRecno)
	
Local cConfer 	:= ""
Local cViagem	:= ""
Local cOrigem	:= ""
Local nX		:= 0
Local nTipoDoc	:= 0
Local aViagens	:= {}
Local aRecFLV	:= {}
Local lRet		:= .F.

FLQ->(dbGoTo(nFLQRecno))
cConfer := FLQ->FLQ_CONFER
cOrigem	:= FLQ->FLQ_ORIGEM
nTipoDoc := Val(FLQ->FLQ_TPPGTO)
	
//Posiciono FLV
dbSelectArea("FLV")
dbSetOrder(1)
If MsSeek(xFilial("FLV")+cConfer) 	
	While !(FLV->(Eof())) .and. xfilial("FLV")+cConfer == FLV->(FLV_FILIAL+FLV_CONFER)
		//Guardo registros da FLV para posterior exclusão
		aadd(aRecFLV, FLV->(Recno()))

		dbSelectArea("FL6")
		dbSetOrder(1)				 
		If MsSeek(xFilial("FL6")+FLV->(FLV_VIAGEM+FLV_ITEM))
			RecLock("FL6",.F.)
			FL6->FL6_VCONFE -= FLV->FLV_VALOR
			//Status de conferência do item de viagem
			If FL6->FL6_VCONFE > 0
				FL6->FL6_STATUS := "1"	//Conferido parcialmente
			Else
				FL6->FL6_STATUS := "0" 	//sem conferências
			Endif
			MSUnlock()
			
			aadd(aViagens, FL6->FL6_VIAGEM )
		Endif

		DbSelectArea("FLV")
		dbSkip()
		
	Enddo	
	
	//Estorna os documentos gerados pela conferencia
	lRet := F686EstDoc(nTipoDoc, nFLQRecno )

	//Seto o status da viagem
	If lRet
		cViagem := ""
		dbSelectArea("FL5")
		dbSetOrder(1)
		For nX := 1 to Len(aViagens)
			If cViagem != aViagens[nX]
				cViagem := aViagens[nX]
				If FL5->( MsSeek( xFilial( 'FL5' ) + cViagem ) )
					Reclock("FL5",.F.)
					FL5->FL5_STATUS := FN685STAT(cViagem)
					MsUnlock()
				Endif
			Endif
		Next

		//Exclui registro da tabela FLV - Pedido vs Conferencia
		For nX := 1 to Len(aRecFLV)
			dbSelectArea("FLV")
			dbSetOrder(1)	//FLV_FILIAL+FLV_CONFER+FLV_VIAGEM+FLV_ITEM
			FLV->(dbGoTo(aRecFLV[nX]))
			RecLock("FLV",.F.)
			FLV->FLV_STATUS := '2'	//Estornado
			MsUnlock()
		Next nX		

		//Atualiza FWN - EBTA/HotelCard.
		If AllTrim(cOrigem) == 'FINA694'
			dbSelectArea('FWN')
			dbSetOrder(2) //FWN_FILIAL + FWN_CONFER
			FWN->(dbSeek( xFilial('FWN') + cConfer ))
			While FWN->(!Eof()) .AND. xFilial('FWN') + cConfer == FWN->(FWN_FILIAL + FWN_CONFER)
			
				RecLock("FWN",.F.)
				FWN->FWN_CONFER := ''	//Não conferido.
				FWN->FWN_VIAGEM := ''	//Remove associacao de viagem
				MsUnlock()
				//
				FWN->(dbSkip())	
			EndDo
		EndIf
		//Seto o status da conferencia
		dbSelectArea("FLQ")
		FLQ->(dbGoTo(nFLQRecno))
		RecLock("FLQ",.F.)
		FLQ->FLQ_STATUS := "2"
		MsUnlock()		
	Endif
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F686GeraTit
Gera titulo contas a pagar no Financeiro (Conferencia)
Exclui titulo contas a pagar no Financeiro (Estorno de Conferencia)

@author Mauricio Pequim Jr
@since 06/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686EstDoc(nOpcao, nRecno )

Local aArea		:= GetArea()
Local _aTit 	:= {}
Local aCabec 	:= {}
Local aItens 	:= {}
Local lRet		:= .F.

Local nTamPrf	:= TamSx3("E2_PREFIXO")[1]
Local nTamNum	:= TamSx3("E2_NUM")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamTipo	:= TamSx3("E2_TIPO")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local cNumTit	:= ""
Local nY		:= 0

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

DEFAULT nOpcao 		:= 1
DEFAULT nRecno 		:= 0

If nRecno > 0

	FLQ->(dbGoTo(nRecno))

	BEGIN TRANSACTION

	If nOpcao == 1	//Contas a Pagar
	
		lRet := .T.
		
		//Posiciono no titulo no Financeiro
		SE2->(dbSetOrder(1))
		
		If SE2->(MsSeek(xFilial("SE2")+FLQ->(FLQ_PREFIX+FLQ_NUMTIT+FLQ_PARC+FLQ_TIPO+FLQ_FORNEC+FLQ_LOJA)))

			_aTit := {}

			AADD(_aTit , {"E2_NUM"    ,FLQ->FLQ_NUMTIT		           ,NIL})
			AADD(_aTit , {"E2_PREFIXO",FLQ->FLQ_PREFIX		           ,NIL})
			AADD(_aTit , {"E2_PARCELA",FLQ->FLQ_PARC	               ,NIL})
			AADD(_aTit , {"E2_TIPO"   ,FLQ->FLQ_TIPO                   ,NIL})
			AADD(_aTit , {"E2_FORNECE",FLQ->FLQ_FORNEC	               ,NIL})
			AADD(_aTit , {"E2_LOJA"   ,FLQ->FLQ_LOJA                   ,NIL})
		
			//Chamada da rotina automatica
			//5 = Exclusao
			MSExecAuto({|x,y,z| FINA050(x,y,z)}, _aTit, 5, 5)
				
			If lMsErroAuto
				MOSTRAERRO()
				lMsErroAuto := .F.
				DisarmTransaction()
				lRet := .F.
			Endif
    	Endif

	ElseIf nOpcao == 2	//Pedido de Compras

		lRet := .T.
		
		dbSelectArea("SC7")
		dbSetOrder(1)	//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		If MsSeek(xFilial("SC7")+FLQ->FLQ_PEDIDO)
			aadd(aCabec,{"C7_NUM" 		, FLQ->FLQ_PEDIDO	})
		Endif
	
		MsExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCabec,aItens,5)

		If lMsErroAuto
			MOSTRAERRO()
			lMsErroAuto := .F.
			DisarmTransaction()
			lRet := .F.
		EndIf
	
	ElseIf nOpcao == 3	//Nota fiscal de entrada
	
		dbSelectArea("SF1")
		dbSetOrder(1)	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If MsSeek(xFilial("SF1")+FLQ->(FLQ_NUMTIT+FLQ_PREFIX+FLQ_FORNEC+FLQ_LOJA+"N"))
                                                  
			lRet := .T.		
			aadd(aCabec, {"F1_DOC"    	, FLQ->FLQ_NUMTIT	})		
			aadd(aCabec, {"F1_SERIE"  	, FLQ->FLQ_PREFIX	})		
			aadd(aCabec, {"F1_FORNECE"	, FLQ->FLQ_FORNEC	})		
			aadd(aCabec, {"F1_LOJA"   	, FLQ->FLQ_LOJA		})		
			aadd(aCabec, {"F1_TIPO"   	, "N"               })
				
			MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,5)		
	
			If lMsErroAuto
				MOSTRAERRO()
				lMsErroAuto := .F.
				DisarmTransaction()
				lRet := .F.
			EndIf
		Endif
	Endif    
	
	END TRANSACTION
	
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F686GetSC7
Gera numeracao do pedido de compras apenas quando o tipo de documento
escolhido para a conferência for pedido de compra                  

@author Mauricio Pequim Jr
@since 18/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686GetSC7()
     
Local cPedido := ""

If nTipoDoc == 2
	cPedido := GetNumSC7()
Endif

Return cPedido


//-------------------------------------------------------------------
/*/{Protheus.doc} F686ConfCons
Visualização do detalhe de conferencias anteriores do item da viagem

@author Mauricio Pequim Jr
@since 18/03/2014	
@version 12
/*/
//-------------------------------------------------------------------
Function F686ConfCons(oView)

Local cTitulo		:= STR0061	//"Conferência de Serviços - Detalhe"
Local cPrograma		:= 'FINA686A'
Local nOperation	:=  MODEL_OPERATION_VIEW
Local oModel        := FWModelActive()
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local cViagem		:= oModelFL6:GetValue("FL6_VIAGEM")
Local cItem			:= oModelFL6:GetValue("FL6_ITEM")
Local aArea			:= GetArea()
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0060},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Fechar"

FL6->(dbSetOrder(1))
If FL6->(MsSeek(xFilial("FL6")+cViagem+cItem))

	__nOper  := OPER_VISUALIZAR
	
	__lBTNConfirma  := .F.
		
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
	
Endif 

Return


/*/{Protheus.doc} F686CalcCC
Realiza calculo de proporção do centro de custo para o título.
@author William Matos Gundim Jr.
@param oModel = Modelo ativo da rotina
@param aItens = Array com os dados da viagem e do pedido conferidos.
@param nTotal = Valor total.
@since 13/08/2014	
@version 12
/*/
Function F686CalcCC(oModel,aItens, nTotal)
Local aRet 		:= {}
Local nX				:= 0
Local oFL6 		:= Nil
Local aArea		:= GetArea()
Local nValor 	:= 0
Local nValCC	:= 0
Local nPorCC 	:= 0
Local nPos			:= 0
Local l686			:= FwIsInCallStack('FINA686') 

//Centro de Custo por Pedido.
dbSelectArea('FLH')

For nX := 1 To Len(aItens) 

	If l686
		oFL6 		:= oModel:GetModel('FL6DETAIL')
		oFL6:SeekLine( { {"FL6_VIAGEM", aItens[nX,1] } , {"FL6_ITEM", aItens[nX,2] } } ) 
		nValor	:= aItens[nX,6]
		nTotal	:= oModel:GetValue("FLQMASTER","FLQ_TOTAL")
	EndIf
								
	If FLH->(DbSeek(xFilial('FLH') + aItens[nX, 1] + aItens[nX, 2]))
					
		While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM + FLH_ITEM == (xFilial('FLH') + aItens[nX, 1] + aItens[nX, 2])
				
			//Armazena o código do centro de custo, porcentagem e o valor conforme a porcentagem.
			nValCC := If(l686, nValor * FLH->FLH_PORCEN/100 , nTotal * FLH->FLH_PORCEN/100)  //Encontra valor referente a porcentagem dentro do pedido.
			nPorCC := Round(nValCC * 100 / nTotal,2)
				
			If (nPos := Ascan(aRet,{|x| AllTrim(x[1] + x[4] + x[5]) == AllTrim(FLH->FLH_CC + FLH->FLH_ITECTA + FLH->FLH_CLVL)})) > 0
				aRet[nPos][2] := aRet[nPos][2] + nValCC //Acumula valor do CC.
				aRet[nPos][3] := aRet[nPos][3] + nPorCC //Acumula porcentagem do CC.
			Else
				aAdd(aRet, { FLH->FLH_CC, nValCC, nPorCC, FLH->FLH_ITECTA, FLH->FLH_CLVL} )	
			EndIf
			FLH->(dbSkip())
		EndDo
			
	EndIf	

Next nX

RestArea(aArea)
Return aRet

/*/{Protheus.doc} F686Leg
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 22/08/2014
@version 12
/*/
Function F686Leg(cValue)
Local cRet:=''

Do Case
	Case cValue == "1"	//Parcialmente	
		cRet := 'br_amarelo'
	Case cValue == "2" //Conferido
		cRet := 'br_azul'
	Case cValue == '3'
		cRet := 'br_vermelho'
	OtherWise //Não conferido.
		cRet := 'br_verde'			   
EndCase

Return cRet

/*/{Protheus.doc} LMLegenda
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function F686Legenda()
Local oLegenda:=FwLegend():New()

oLegenda:add('FL6->FL6_STATUS==0','GREEN' ,STR0067) //Em aberto.		
oLegenda:add('FL6->FL6_STATUS==1','YELLOW',STR0068) //Conf. Parcialmente.
oLegenda:add('FL6->FL6_STATUS==2','BLUE'  ,STR0069)	//Conferido.
oLegenda:add('FL6->FL6_STATUS==3','RED'   ,STR0070) //Cancelado.
oLegenda:View()
oLegenda:=nil
        
Return .T.

/*/{Protheus.doc} F686ValGat
Gatilho para o campo valor informado.
@author William Matos Gundim Junior.
@since 27/08/2014
@version 12
/*/
Function F686ValGat(oFL6)
Local nValor := 0

If oFL6:GetValue('FL6_OK') 
	If oFL6:GetValue('FL6_STATUS') == '3' //Cancelado.
		oFL6:LoadValue('FL6_ENCERRADO','S')
	ElseIf oFL6:GetValue('FL6_STATUS') == '1' // Adicionado para evitar carregamento de valor maior do que o Total do registro. Pirolo
		nValor := oFL6:GetValue("FL6_TOTAL") - oFL6:GetValue("FL6_VCONFE")
	Else
		nValor := oFL6:GetValue('FL6_TOTAL')
	EndIf 
Else
	oFL6:LoadValue('FL6_VINFOR',0)
	F686VLDFL6() 
	If oFL6:GetValue('FL6_STATUS') == '3' //Cancelado.
		oFL6:LoadValue('FL6_ENCERRADO','N')
	EndIf 
EndIf

Return nValor

/*/{Protheus.doc} F686PedCanc
Monta a legenda dos registros apresentados no Grid.
@param oFL6 - Objeto com dados do Pedido.
@param nLine- Linha do detail.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function F686PedCanc(oFL6, nLine)
Local lRet := .F.
Local nX   := 1
Default nLine := 0

If nLine > 0
	lRet := oFL6:GetValue('FL6_STATUS', nLine) == '3' .AND. oFL6:GetValue('FL6_ENCERRADO',nLine) = 'S'	
Else	
	While !lRet .AND. nX <= oFL6:Length() 
		lRet := oFL6:GetValue('FL6_STATUS', nX) == '3' .AND. oFL6:GetValue('FL6_ENCERRADO',nX) = 'S'
		nX ++
	EndDo
EndIf	
Return lRet

/*/{Protheus.doc} F686SelAll()
Botão para marcar/desmarcar todos.
@author Alvaro Camillo Neto
@since 16/05/2016
@version 12
/*/
Function F686SelAll(oPanel,oView)
Local oTBtn1 := Nil

oTBtn1 := TButton():Create( oPanel,005,005,STR0083,{||F686AllBt()},70,15,,,,.T.,,,,,,)//"Marcar todos"	

Return 


/*/{Protheus.doc} F686AllBt()
Botão para marcar/desmarcar todos.
@author Alvaro Camillo Neto
@since 16/05/2016
@version 12
/*/
Function F686AllBt()
Local oModel	:= FWModelActive()
Local oView	:= FWViewActive()
Local oFL6		:= oModel:GetModel('FL6DETAIL')
Local nX		:= 0

__lMarcaTodos := .T.
__lConfTodos := Nil
__lEncTodos    := NIL

For nX := 1 To oFL6:Length()
	
	oFL6:GoLine(nX)
	oFL6:SetValue('FL6_OK', !oFL6:GetValue("FL6_OK", nX))
	
Next nX

oFL6:GoLine(1)
oView:Refresh()

__lMarcaTodos := .F.
__lConfTodos := Nil
__lEncTodos    := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FN686Oper
Define a operação quando executado pelo Robô de Testes 

@author Automacao 
@since  14/06/2016
/*/
//-------------------------------------------------------------------
Function FN686Oper(nOper) //-- Automação
Default nOper	:= 0

__nOper 	:= nOper

Return
