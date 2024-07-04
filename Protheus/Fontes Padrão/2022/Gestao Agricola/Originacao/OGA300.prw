
/*
observaccoes:

MV_MOEDA5
MV_SIM5
MV_MOEDAP5


1o) o C6_prcven, e tbem vrs. unit. no contrato de parceria n nota fiscal etc. devem ter pelo menos 4 casas
decimais senao n. irá funcionar; 0,1111
1a) Verifica o parametro MV_MOEDTIT STAH = S


2o)Criar Campo ADA_TRCNUM (VISUAL, USADO OPCIONAL, NO MODULO 67) que ira Identificar o acordo de troca NO AJUSTASX3 	( Feito )
-- JA SUBI O FONTE NO TFS AGORA EH SO COMITA-LO não rodar na SG criar na mãO;
30) Para ter os tits. de troca gerando com o prefixo TRC
Alterar o Parametro Para MV_1DUPREF, para algo do tipo:
MV_1DUPREF := A1:="IIF(!TYPE('lOGNFTRC') = 'U','TRC',SF2->F2_SERIE)"
Desta forma o pedido de troca será gerado com prefixo TRC
4o)eXCLUI NJR_CTRPAR , NJR_USADO do AJUSTANJR e tbem do  dicionario de dados.
50) Pegar fata400 com o vini e inserir codigo de validacao para nao alterar,excluir
6O) aTENCAO MUDAR FATA400
FindFunction("OGA280")  PARA FindFunction("OGA280TROK") -> fEITO PELO VINI
FindFunction("OGA280")  PARA FindFunction("OGA280NK6")	-> FEITO PELO VINI
7O) aDICAO E SUBTRACAO DE contrato n. pode ser executada qdo for um ctrato envolvido em troca oga335, ajustado e passado para o  marlon subir.
80) rODAR O AJUSTANKT Q CRIEI;
90) RODAR O AJUSTANKO Q CRIEI;
10) RODAR O AJUSTASX3 PARA CRIAR O CPO ADA_TRCNUM
11)) ALINHAR COM O VITOR PARA TIRAR O FTROCA() DO OGX155;


///** ubs Ajustar
*Nas rotinas de autorizacao e tbem de ordem de carregamento o Vr. do produto uniario não poderá ser
auterado qdo for um ctrato de troca;;;
e tbem devve star com 4 casas
****/

//MV_CALCCM - Indica se faz o cálculo da correção monetária.


// Regras


*/
#INCLUDE "OGA300.CH"
#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'FWEDITPANEL.CH'
#Include 'COLORS.CH'

Static nAdaRecno           := 0
Static cAdaNumCtr          := ''
Static nSC5Recno	:= 0
Static cSC5NumPed	:= ''
Static __nTipo		:= ''

/** {Protheus.doc} OGA300
Rotina de Manutenção de Acordo de Troca

@param: 	Nil
@author: 	Emerson Coelho
@since: 	28/04/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA300()

	Local oMBrowse := Nil

	SetKey (VK_F12, nil)
	
	__nTipo := 2
	
	Pergunte('OGA30001', .F.)
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKT" )
	oMBrowse:SetDescription( STR0057 ) //#Controle de Acordo de Troca

	oMBrowse:AddLegend("NKT_STATUS == '00'", "WHITE" , STR0058) //#Legado
	oMBrowse:AddLegend("NKT_STATUS == '01'", "RED"   , STR0059) //#Pendente
	oMBrowse:AddLegend("NKT_STATUS == '02'", "GREEN" , STR0060) //#Liberado
	oMBrowse:AddLegend("NKT_STATUS == '03'", "YELLOW", STR0061) //#Iniciado
	oMBrowse:AddLegend("NKT_STATUS == '04'", "PINK"  , STR0062) //#Recebido
	oMBrowse:AddLegend("NKT_STATUS == '05'", "BLACK" , STR0063) //#Finalizado

	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef( "OGA300" )
	oMBrowse:Activate()

Return( nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA300 - Acordo de Troca
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0041 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0042, "ViewDef.OGA300", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0043, "ViewDef.OGA300", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0044, "ViewDef.OGA300", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0045, "ViewDef.OGA300", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0046, "ViewDef.OGA300", 0, 8, 0, Nil } ) //"Imprimir"
	//aAdd( aRotina, { STR0047, "STATICCALL(OGA300,FSHOWCTPAR,4)", 0, 7, 0, Nil } ) //'Manut Ctr. Parceria'
	//aAdd( aRotina, { STR0008, "ViewDef.OGA300", 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0048, "OGA300HIS", 0, 11, 0, Nil } ) //"Histórico"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA300 - Acordo de Troca
*/
Static Function ModelDef()
	Local oStruNKT 	:= FWFormStruct( 1, "NKT" )
	Local oStruNKO 	:= FWFormStruct( 1, "NKO" )
	Local oModel 	:= MPFormModel():New( "OGA300",/*PRE*/,/*POS*/{| oModel | TudoOK( oModel )} ,/*GRV*/ {| oModel | GrvModelo( oModel ) }  )

	oModel:SetDescription( STR0064 ) // #Acordo de Troca

	oStruNKO:RemoveField( "NKO_TRCNUM" ) //Remove o Trnum do view.

	//--Valids da Nkt --
	oStruNKT:SetProperty( "NKT_CODCTR" 	   , MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg300Vld1()") )
	oStruNKT:SetProperty( "NKT_MOEDA" 	   , MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg300Vld2()") )
	oStruNKT:SetProperty( "NKT_TPPARD" , MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"fOg300Vld3()") )
		
	If "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,""))
		oStruNKT:SetProperty( "NKT_NATURE", MODEL_FIELD_OBRIGAT	, .T. )
	EndIf	

	//--Adding Gatilhos na NKT ( Field ) --//
	oStruNKT:AddTrigger( "NKT_CODCTR"      ,"NKT_CODCLI"      , {|| .T. 			   }, {|| fOG300CPRA()	}  )	// Preenche Cpos. que necessitam inf. do ctrato de Compra
	oStruNKT:AddTrigger( "NKT_VRVNDP"      ,"NKT_VRVNDP"      , {|| M->NKT_TPPARD== '2'}, {|| fCalcVrUni('*')})	//Calcula Vr. Unitario qdo o tipo de paridade é 2
	oStruNKT:AddTrigger( "NKT_VRVNDP"      ,"NKT_VRVNDP"      , {|| M->NKT_TPPARD== '1'}, {|| fIdxParid( '*')})	//Calc. indice de Paridade por Preço
	oStruNKT:AddTrigger( "NKT_TPPARD"      ,"NKT_UMPAR"       , {|| .T. 			   }, {|| fMudaTpPar()	}  )	//Muda a Forma de Paridade da Troca
	oStruNKT:AddTrigger( "NKT_UMPAR"       ,"NKT_UMPAR"       , {|| .T. 			   }, {|| fDisNktUmp()	}  )	//Desabilita o cpo para n. ter seu vr. mudado.

	//--Adding Gatilhos na NKO ( Grid itens a Vender)--//
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_DESPRO"      , {|| .T. }  , {|| fIniDesPro()} )	//Descricao
	////oStruNKO:AddTrigger( "NKO_CODPRO"      , "NKO_UMPARI"          , {|| .T. }  , {|| fIniUMPar() 	}  )	//Unidade de medida
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_UM"          , {|| .T. }  , {|| fIniUM() 	 } )	//Unidade de medida
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_TES"         , {|| .T. }  , {|| fIniTES()   } )	//Busca Tes
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_LOCAL"       , {|| .T. }  , {|| fIniLocal() } )	//Busca Local
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_PRCVEN"      , {|| .T. }  , {|| fIniPrcVnd()} )	//Busca Vr. de Venda
	//--Gatilhos ref. Itens de semente q contem b5_semente = sim
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_CULTRA"      , {|| .T. }  , {|| fDadosSem('NKO_CULTRA')} )	//Gatilho Cultura
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_CTVAR"       , {|| .T. }  , {|| fDadosSem('NKO_CTVAR') } )	//Gatilho Cultivar
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_CATEG"       , {|| .T. }  , {|| fDadosSem('NKO_CATEG') } )	//Gatilho Categoria
	oStruNKO:AddTrigger( "NKO_CODPRO"      ,"NKO_PENE"        , {|| .T. }  , {|| fDadosSem('NKO_PENE')	} )	//Gatilho Peneira
	oStruNKO:AddTrigger( 'NKO_QUANT'	   ,"NKO_QTTRC"		  , {|| .t. }  , {|| fTotTRC()   }	) 	//Atualiza prc. Total em OM (Troca)
	oStruNKO:AddTrigger( 'NKO_QUANT'	   ,"NKO_TOTAL"		  , {|| .t. }  , {|| fTotal()    }	)	//Atualiza prc. Total
	If ! IsBlind()
	   oStruNKO:AddTrigger( 'NKO_PARIUM'	   ,"NKO_PRCVEN"	  , {|| .t. }  , {|| fCalcVrUni()}	)	//Calcula Vr. Unitario qdo o tipo de paridade é 2
	EndIf
	oStruNKO:AddTrigger( "NKO_PRCVEN"      ,"NKO_IDXPAR"      , {|| .T. }  , {|| fIdxParid() }	)	//Calc. Paridade
	oStruNKO:AddTrigger( 'NKO_PRCVEN'	   ,"NKO_TOTAL"	      , {|| .t. }  , {|| fTotal()    }	)	//Atualiza prc. Total
	oStruNKO:AddTrigger( "NKO_IDXPAR"      ,"NKO_VRPAUT"      , {|| .T. }  , {|| fCalcVrPau()}	)	//Calc. Vr. de Pauta do Produto
	oStruNKO:AddTrigger( 'NKO_IDXPAR'	   ,"NKO_QTTRC"	      , {|| .t. }  , {|| fTotTRC()	 }	)  	//Atualiza prc. Total em OM (Troca)
	
	oModel:AddFields( "NKTUNICO", Nil, oStruNKT )
	oModel:SetDescription( STR0009 ) //"Tipo de Reserva"
	//oModel:GetModel( "NKTUNICO" ):SetDescription( STR0010 ) //"Dados do Tipo de Reserva"

	///oModel:AddGrid( "NKOGRID", "NKTUNICO", /*oStruNKO,{|oModelGrid, nLine,cAction,cField|PreValLin(oModelGrid, nLine, cAction, cField)}*//*bLinePre*/ ,/*{|oModelGrid, nLine,cAction,cField|PreValCOO(oModelGrid, nLine, cAction, cField)} bLinePos*/ ,/*bPreVal*/, { | oGrid | ValPosNKO( oGrid ) },  )
	oModel:AddGrid( "NKOGRID", "NKTUNICO",oStruNKO,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)})
	//oModel:GetModel( "NKOGRID" ):SetDescription( STR0024 ) //"Dados das Previsões Financeiras"
	oModel:GetModel( "NKOGRID" ):SetUniqueLine( { "NKO_ITEM" } )
	oModel:GetModel( "NKOGRID" ):SetOptional( .t. )
	oModel:SetRelation( "NKOGRID", { { "NKO_FILIAL", "fWxFilial( 'NKO' )" }, { "NKO_TRCNUM", "NKT_TRCNUM" } }, NKO->( IndexKey( 1 ) ) )


	oModel:AddCalc( 'OGA300TOTAL', 'NKTUNICO', 'NKOGRID', 'NKO_QTTRC'  , 'TOTMOEDA2'  	,'SUM',{||.t.}/*{||fVndTotal() }*/,,'Vr.Total.OM.',/*{||fVndTotal() }*/ ) //'Total Fardos'
	oModel:AddCalc( 'OGA300TOTAL', 'NKTUNICO', 'NKOGRID', 'NKO_TOTAL'  , 'TOTMOEDA1'  	,'SUM',{||.T.},,'Vr.Total',/*{||fVndTotal() }*/) 	//'Total Fardos'
	
	//oMdlCalc := oModel:GetModel("OGA300TOTAL")
	//  oMdlCalc:AddEvents("OGA300TOTAL","TOTMOEDA1","TOTMOEDA2",{||.t.})

	oModel:SetActivate( { | oModel | fIniModelo( oModel, oModel:GetOperation() ) } )
	oModel:SetDeActivate( { | oModel | fFimModelo( oModel ) } )

	oModel:SetVldActivate( { | oModel | fVldModelo( oModel, oModel:GetOperation() ) } )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA300 - Acordo de Troca
*/
Static Function ViewDef()
	Local oStruNKT 	:= FWFormStruct( 2, "NKT" )
	Local oStruNKO	:= FWFormStruct( 2, "NKO" )
	Local oModel   	:= FWLoadModel( "OGA300" )
	Local oView    	:= FWFormView():New()

	oStruNKO:RemoveField( "NKO_TRCNUM" ) //Remove o Trnum do view.

	oView:SetDescription( 'Acordo de Trocas ' )
	oView:SetModel( oModel )

	oCalc := FWCalcStruct( oModel:GetModel( 'OGA300TOTAL') )
	///oCalc2 := FWCalcStruct( oModel:GetModel( 'OGA300TOT2') )

	oView:AddField( "VIEW_NKT", oStruNKT, "NKTUNICO" )
	oView:AddGrid(  "VIEW_NKO", oStruNKO, "NKOGRID",, )

	oView:AddField( 'VIEW_CALC', oCalc , 'OGA300TOTAL' )

	oView:AddIncrementField( "VIEW_NKO", "NKO_ITEM" )


	oView:CreateHorizontalBox( "SUPERIOR" , 	50 	)
	oView:CreateHorizontalBox( "INFERIOR" , 	40 	)
	oView:CreateHorizontalBox( 'RODAPE', 		10	) //,,.T.)

	//--Ancorando os Objetos Fields e Grids --//
	oView:SetOwnerView( "VIEW_NKT", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NKO", "INFERIOR" )

	oView:SetOwnerView( 'VIEW_CALC','RODAPE' )

	oView:EnableTitleView( "VIEW_NKT" )
	oView:EnableTitleView( "VIEW_NKO" )

	//--Adding Actions para os Campos da NKT ( Field de Troca)--//
	oView:SetFieldAction( "NKT_CODPRO"      ,  {|oView| fActProdTr(oView)	} )

	//Adicionando Action Para os Campos da NKT(Cab da troca)
	oView:SetFieldAction( "NKT_VRVNDP",  { |oView| fActQtREC(oView) }  ) //Atualiza a qtidade a receber
	oView:SetFieldAction( "NKT_VRPAUT",  { |oView| fActVrPau(oView) }  ) //Atualiza a qtidade a receber

	oView:AddUserButton('Ratear dif. nos Itens' ,'',{||Processa({|oView| fRateio( oView )}, "")}) //'Composição de Preços

	SetKey( VK_F4, { || OGA300LF4() } )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )


	/*/{Protheus.doc} fActProdTr(oview)
	Encontra a Descrição do Produto de Troca...

	@author Emerson Coelho

	@since 29/04/2013
	@version 1.0
	/*/
Static Function fActProdTr( oView )
	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local cProduto		:= oModeLNKT:GetValue("NKT_CODPRO")
	Local cDesPro		:=''
	Local cUMPRCProd    :=''

	cDesPro 	:= POSICIONE("SB1", 1, fwxFilial("SB1") + cProduto, "B1_DESC" )
	cUMPRCProd 	:= POSICIONE("SB5", 1, fwxFilial("SB5") + SB1->B1_COD, "B5_UMPRC" )

	oModeLNKT:LoadValue("NKT_DESPRO",	cDesPro		)
	oModeLNKT:LoadValue("NKT_UMPRC"	,	cUMPRCProd	)

	oView:Refresh()

Return

/*/{Protheus.doc} fIniDesPro
Encontra a Descrição do Produto ...

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
Static Function fIniDesPro()

	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO     := oModel:GetModel("NKOGRID")
	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")

	Local cCodCli		:= oModelNKT:GetValue("NKT_CODCLI")
	Local Clojcli		:= oModelNKT:GetValue("NKT_LOJCLI")
	Local cDesPro		:=''

	dbSelectArea("SA7")
	dbSetOrder(1)
	If ( MsSeek(fwxFilial("SA7")+cCodCli+Clojcli+cProduto,.F.) ) .And. !Empty( SA7->A7_DESCCLI )
		cDesPro := SA7->A7_DESCCLI
	Else
		cDesPro := POSICIONE("SB1", 1, fwxFilial("SB1") + cProduto, "B1_DESC" )
	EndIf

Return cDesPro

/*/{Protheus.doc} fIniUM
Encontra a Unidade de Medida do Produto ...

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
Static Function fIniUM()
	Local oModel      := FWModelActive()
	Local oModelNKO   := oModel:GetModel("NKOGRID")
	Local cProduto	  := oModelNKO:GetValue("NKO_CODPRO")
	Local cUM			:=	''

	//-- Unidade de Medida do Produto
	cUM := POSICIONE("SB1", 1, fwxFilial("SB1") + cProduto, "B1_UM" )

Return cUM


/*/{Protheus.doc} fIniUMPar
Encontra a Unidade de Medida que será
utilizada na Paridade;

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
/*/Static Function fIniUMPar()

Local oModel        	:= FWModelActive()
Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
Local oModelNKO      := oModel:GetModel("NKOGRID")
Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")

Local cUM				:=	''

//-- Unidade de Medida do Produto


//-- Unidade de Medida que será usada na paridade
//-- Se n. tiver a B1_UMPRC, então usaremos a B1_UM
cUM := POSICIONE("SB1", 1, fwxFilial("SB1") + cProduto, "B1_UMPRC" )
IF Empty(cUm)
cUM := POSICIONE("SB1", 1, fwxFilial("SB1") + cProduto, "B1_UM" )
EndIF

Return cUM
/*/

/*/{Protheus.doc} fIniTES
Encontra a TES

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
Static Function fIniTES()

	Local oModel        := FWModelActive()
	Local oModelNKO     := oModel:GetModel("NKOGRID")
	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")

	Local cTes			:=	''

	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	MsSeek(xFilial("SB1")+cProduto)

	cTes := RetFldProd(cProduto,"B1_TS")

Return cTes



/*/{Protheus.doc} fIniLocal
Encontra o Local Padrao

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
Static Function fIniLocal()

	Local oModel       	:= FWModelActive()
	Local oModelNKO     := oModel:GetModel("NKOGRID")
	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")

	Local cLocPad		:=	''

	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	MsSeek( fWxFilial("SB1") + cProduto )

	cLocPad := RetFldProd(cProduto,"B1_LOCPAD")

Return cLocPad

/*/{Protheus.doc} fIniPrcVnd
Encontra o Local Padrao

@author Emerson Coelho

@since 29/04/2013
@version 1.0
/*/
Static  Function fIniPrcVnd()

	Local oModel       	:= FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO     := oModel:GetModel("NKOGRID")

	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")
	Local cCodCli		:= oModelNKT:GetValue("NKT_CODCLI")
	Local Clojcli		:= oModelNKT:GetValue("NKT_LOJCLI")
	Local dDtNeg    	:= oModelNKT:GetValue("NKT_DTNEG")
	Local cTabela		:= oModelNKT:GetValue("NKT_TBPRAT")

	Local nMoeda		:= 1   //-- Sempre Gera na Moed Corrente --//
	Local nVrVnd		:= 0


	nVrVnd	:=	MaTabPrVen(cTabela,cProduto,0,cCodCli,Clojcli,nMoeda,dDtNeg)
	If ! IsBlind()
	   oModelNKO:SetValue("NKO_PARIUM", 0 )
    EndIf
	///oModelNKO:SetValue("NKO_VVNDTB", nVrVnd ) 	//Quardo o Vr. de Venda da Tabela caso usuario mude o Vr. por questões de negociação
Return nVrVnd

	/*/{Protheus.doc} fTotTRC ( )
	Rotina de Gatilho para Atualizar o Vr. total do Item em Outra Moeda (Troca)
	@param oVIEW
	@return Vr. de Venda Total
	@author Emerson Coelho
	@since 29/04/2013
	@version 1.0
	/*/
Static Function fTotTRC( )
	Local oModel       	:= FWModelActive()
	Local oModelNKO     := oModel:GetModel("NKOGRID")

	//--Vars. Calc. Vr. Total do item
	Local nQuant		:= oModelNKO:GetValue("NKO_QUANT" )
	Local nParidade		:= oModelNKO:GetValue("NKO_IDXPAR")

	Local nQtTrc		:= 0

	// -- Calculando o Vr. total do Item
	//nTotal := a410Arred(nQuant * nPrcVnd, "D2_TOTAL" )
	//oModelNKO:SetValue("NKO_TOTAL", nTotal )
		
	nQtTrc := ROUND(nQuant * nParidade, 4 )
	//oModelNKO:SetValue("NKO_QTTRC", nQtTrc )
		
	//oView:Refresh()

Return( nQtTrc )

	/*/{Protheus.doc} fTotal ( )
	Rotina de Gatilho para Atualizar o Vr. total do Item em 1aMoeda
	@param oVIEW
	@return Vr. de Venda Total
	@author Emerson Coelho
	@since 29/04/2013
	@version 1.0
	/*/
Static  Function fTotal( )
	Local oModel     := FWModelActive()
	Local oModelNKO	 := oModel:GetModel("NKOGRID")

	//--Vars. Calc. Vr. Total do item
	Local nQuant	 := oModelNKO:GetValue("NKO_QUANT" )
	Local nPrcVnd	 := oModelNKO:GetValue("NKO_PRCVEN")
	Local nTotal	 := 0

	// -- Calculando o Vr. total do Item
	nTotal := ROUND(nQuant * nPrcVnd, 4 )	
	
Return( nTotal )

	/*/{Protheus.doc} fCalcVrPau ( oView )
	Rotina de Action Field, utilizada para Calcular o Vr. Unitario de Pauta do item
	@param oVIEW
	@return Vr. Un. de Pauta do item
	@author Emerson Coelho
	@since 29/04/2013
	@version 1.0
	/*/
Static  Function fCalcVrPau( oView )
	Local oModel     := FWModelActive()
	Local oModeLNKT	 := oModel:GetModel("NKTUNICO")
	Local oModelNKO  := oModel:GetModel("NKOGRID")

	Local nVrPauta	 := oModelNKT:GetValue("NKT_VRPAUT" )
	Local nParidade	 := oModelNKO:GetValue("NKO_IDXPAR")
	Local nVrItPauta := 0

	nVrItPauta := ROUND(nParidade* nVrPauta , 4 )
Return( nVrItpauta )

	/*/{Protheus.doc} fIdxParid (  cFlag )

	Rotina de Gatilho  para Calcular a Paridade
	que é feito a tabela de vendas e um vr. de soja previsto;
	Rotina chamada em Gatilho no NKO_PRCVEN, e tbem no NKT_VRVNDP

	@param cFlag '*' Indica que é para varrer todo o grid
	@return Indice de Paridade
	@author Emerson Coelho
	@since 29/04/2013
	@version 1.0
	/*/
Static  Function fIdxParid( cFlag )
	Local oModel		:= FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO		:= oModel:GetModel("NKOGRID")
	Local aSaveLines	:= FWSaveRows()

	//--Vars Calc. Ind. Paridade --
	Local nValor	:= 0
	Local nPrcVnd	:= ''
	Local nVrVndPrv	:= oModelNKT:GetValue("NKT_VRVNDP")
	Local nX		:= 0
	Default cFlag	:= ''

	For nX := 1 to oModelNKO:Length()
		IIF (cFlag == '*', oModelNKO:GoLine( nX ),nIl ) //(cFlag *) == Todas Linha do Grid; (cFlag Vazio()) Somente Linha Posicionada ;
		///		oModelNKO:GoLine( nX )
		//	If .Not. oGrdNKO:IsDeleted() // Calc. Idx. paridade, até para os deletados. pq se forem undeletados já vão posuir o indice ;
		nPrcVnd	:= fWfldGet("NKO_PRCVEN")
		nValor 	:= NoRound(nPrcVnd / nVrVndPrv, 4)
		oModelNKO:SetValue("NKO_IDXPAR", nValor )
		IF ! cFlag == '*' // Não é para fazer todos devo Sair Fora
			Exit
		EndIF

	next Nx

	FWRestRows(aSaveLines)
Return ( nValor )


	/*/{Protheus.doc} PreValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
	Rotina de Pre validação do modelo COO(Solicitações)

	@author alexandre.gimenez
	@param oModelGrid Modelo
	@param nLinha Linha corrente
	@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
	@param cCampo Campo atualizado
	@param Vr. inserido no Campo
	@param Vr. que do Cpos antes da Inserção do novo vr.
	@return lRet
	@since 12/09/2013
	@version 1.1
	/*/
//------------------------------------------------------------------
Function PreValLin(oModelNKO, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local oModel        	:= FWModelActive()
	Local nOperation 		:= oModel:GetOperation()
	Local aSaveLines     := FWSaveRows()
	Local oView			:= FwViewActive()
	Local lContinua		:=.t.
	Local cItem			:= 	FWFLDGET('NKO_ITEM',nLinha)

	IF lContinua .and. cAcao == 'DELETE'
		//-- Verifico se  o item do Ctrato de parceria pode ser deletado;
		IF fGetQtdEmp( cItem ) > 0
			Help(,, STR0001,,STR0002 , 1, 0 ) //#Ajuda #"Item não pode ser excluido pois já possui Quantidade empenhada."
			lContinua := .f.
		EndIF
	EndIF

	//-- Qdo for Paridade Por UM, eu não posso deixar que dados sejam inseridos no Cpo. NKO_PRCVEN
	IF lContinua .and. cAcao == 'CANSETVALUE' .and. FWFLDGET('NKT_TPPARD' ) == '2'.and. cCampo == 'NKO_PRCVEN'
		lContinua := .f.
	EndIF

	IF lContinua .and. nOperation == MODEL_OPERATION_UPDATE .and. cAcao == 'CANSETVALUE'
		//IF cAcao == 'CANSETVALUE'
		/*--------------------------------------------------------------------------------------------------*
		!Verifico se Já existe Qtidade Empenhada Se Sim, Somente o Cpo Qtidade(NKO_QUANT)pode ser alterado !
		*--------------------------------------------------------------------------------------------------*/
		IF fGetQtdEmp( cItem ) > 0 .and. ! cCampo == "NKO_QUANT"
			Help(,, STR0001,,STR0003 , 1, 0 ) 					//#Ajuda #"Campo não pode ser alterado, pois já possui quantidade empenhada."
			lContinua := .f.
		EndIF
		//EndIF
	EndIF

	IF lContinua .and. nOperation == MODEL_OPERATION_UPDATE .and. cAcao == 'SETVALUE'
		//	IF cAcao == 'SETVALUE'
		/*---------------------------------------------------------------------------*
		!Na Alteração se o ctrato tem qtd emprenhada tenho q garantir que				!
		!a qtidade q está sendo digitada não seja menor que a Qtidade ja empenhada  !
		*---------------------------------------------------------------------------*/
		nQtAux := fGetQtdEmp( cItem )

		IF nQtAux > 0 .and. cCampo == "NKO_QUANT" .and. xVrNovo < nQtAux
			Help(,, STR0001,,STR0004 +  cvaltochar(nQtAux) + STR0005 , 1, 0 )	//# Ajuda # "Quantidade não pode ser menor que: "  # ", pois essa quantidade já se encontra empenhada"
			lContinua := .f.
		EndIF
		//	EndIF
	EndIF

	FWRestRows(aSaveLines)
   If ! IsBlind()
	  oview:refresh()
   EndIf
Return (lContinua)

/*/
{Protheus.doc} fActQtREC ()
Rotina de Action Field, utilizada para atualizar a Qtidade
de produto a receber na troca e tbem o indice de paridade
refaz todas as linhas do array
@param oVIEW
@return Qt. a receber de todos os itens do grid;
@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/
Static  Function fActQtREC(oView )
	Local oModel        := FWModelActive()
	Local oModelNKO     := oModel:GetModel("NKOGRID")
	Local nQtTroca		:= 0
	Local nVrVndIt		:= 0
	Local nParidade		:= 0
	Local nQuant		:=	0
	Local aSaveLines    := FWSaveRows()
	Local nX
	Local nPropor

	//--Calc a Qtidade de produto a receber em troca do vr total do item--
	//--Calculo eh igual a vr total do item / vr de venda do produto na troca

	For nX := 1 to oModelNKO:Length()
		oModelNKO:GoLine( nX )
		If .Not. oModelNKO:IsDeleted()
			nVrVndIt	:= FWFLDGET( "NKO_PRCVEN" ,	nX )
			nQuant		:= FWFLDGET( "NKO_QUANT"  ,	nX )
			nParidade 	:= FWFLDGET( "NKO_IDXPAR" ,	nX )
			nPropor     := Iif(FWFLDGET( "NKO_PROPOR" , nX ) = Nil, 0, FWFLDGET( "NKO_PROPOR" , nX ))
			
			nQtTroca 	:= (FWFLDGET( "NKT_QTTRC")* (nPropor / 100))
			oModelNKO:SetValue("NKO_QTTRC", nQtTroca)

		EndIF
	Next nX

	FWRestRows(aSaveLines)

 Return

	/*/{Protheus.doc} fActVrPau ()
	Rotina de Action Field, utilizada para atualizar os Vrs. de Pauta
	Caso o Vr. de Pauta do Prod. em troca for alterado
	refaz todas as linhas do array
	@param oVIEW
	@return Qt. a receber de todos os itens do grid;
	@author Emerson Coelho
	@since 29/04/2013
	@version 1.0
	/*/
Static  Function fActVrPau(oView )
	Local oModel        	:= FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO      := oModel:GetModel("NKOGRID")

	Local nVrTrcPaut		:= oModelNKT:GetValue("NKT_VRPAUT")
	Local nVrpauta       := 0
	Local aSaveLines     := FWSaveRows()
	Local nX

	//--Calc a Qtidade de produto a receber em troca do vr total do item--
	//--Calculo eh igual a vr total do item / vr de venda do produto na troca

	For nX := 1 to oModelNKO:Length()
		oModelNKO:GoLine( nX )
		If .Not. oModelNKO:IsDeleted()

			nParidade 	:=  FWFLDGET( "NKO_IDXPAR",	nX )
			nVrPauta	:= ROUND(nVrTrcPaut * nParidade, 4 )

			oModelNKO:SetValue("NKO_VRPAUT", 	nVrPauta	)

		EndIF
	Next nX

	FWRestRows(aSaveLines)

	oView:Refresh()
Return



/** {Protheus.doc} 7
Função que Inicializa o modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function finimodelo( oModel , nOperation )
	Local nQtEmp	:= 0
	Local lRet		:= .T.

	SetKey( VK_F2, { || fShowCCpra() } ) 		// Setanto F2 para Mostrar o Contrato
	SetKey( VK_F7, { || fShowPedVen( 2 ) } )	// Setando f7 para mostrar o Pedido de venda.

	If nOperation == MODEL_OPERATION_UPDATE .AND. Empty(M->NKT_NUMPED)

		fOG300CPRA()

		//--Verifico se algum item do Ctrato de parceria ja possui qtd empenhada
		ADB->( dbSetOrder( 1 ) )
		ADB->(dbSeek( fWxFilial( "ADB" ) + cAdaNumctr ))
		If( dbSeek( fWxFilial( "ADB" ) + cAdaNumctr  ))
			While ADB->(! Eof() )  .and. ADB->( ADB_FILIAL+ADB_NUMCTR ) == fWxFilial( "ADB" ) + cAdaNumctr

				nQtemp += ADB->( ADB_QTDEMP + ADB_QTDENT )
				ADB->( DbSkip() )
			EndDo
			IF nQtEmp > 0 // jÁ Existe item empenhado , portanto não posso alterar Varios Campos irei desabilitar os campos
				oModel:GetModel("NKTUNICO"):GetStruct():SetProperty( '*' , MODEL_FIELD_NOUPD, .f.)

				Help(,, STR0001,,STR0006 , 1, 0 )	//#Ajuda #"Já existem itens desse contrato de troca com quantidade empenhada,portanto somente os itens que ainda não possuem quantidade empenhada poderam ser alterados."
			EndIF
		EndIf
	EndIF

Return lRet

/** {Protheus.doc} 7 ffimModelo
Função executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fFimModelo( oModel )

	SetKey (VK_F2, nil)
	SetKey (VK_F4, nil)
	SetKey (VK_F5, nil)
	SetKey (VK_F7, nil)

Return( .t. )



/** {Protheus.doc} 7
Função que Valida o Modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fVldModelo( oModel , nOperation )

	Local aAreaADA		:= ADA->(GetArea())
	Local lRet			:= .t.

	//-- Verifica se o Acordo de Troca já possui um Ctrato de parceria (só devera existir qdo não for incluir)
	IF !(nOperation == MODEL_OPERATION_INSERT)
		RegToMemory("NKT", .F., .F.)
		If Empty(M->NKT_NUMPED)
			fGetCtrPar() //-- >> busca o Ctrato de Parceria do acordo de troca(Ataliza as Variaveis STATICAS nAdaRecno , cAdaNumctr) -- >>
			__nTipo := 1
		Else
			fGetPedVen()//-- >> busca o Pedido de Venda do acordo de troca(Ataliza as Variaveis STATICAS nSC5Recno , cSC5NumPed) -- >>
			__nTipo := 2
		EndIf
	Else
		__nTipo := MV_PAR01
	EndIF

	If nOperation == MODEL_OPERATION_UPDATE
		IF Empty(M->NKT_NUMPED)
			ADA->(dbGoTo( nAdaRecno ) )
			DO Case
				Case ADA->ADA_STATUS == 'D'
				Help(,, STR0001,,STR0007 , 1, 0 )				//#'Ajuda' #"Contrato de Troca não pode Ser Alterado Pois o mesmo já está totalmente empenhado"
				lRet := .f.
				Case ADA->ADA_STATUS == 'E'
				Help(,, STR0001,,STR0008 , 1, 0 )				//#Ajuda" #"Contrato de Troca não pode ser alterado pois o contrato de parceria foi encerrado"
				lRet := .f.
			EndCase

		Else
			dbSelectArea( "NJR" )
			NJR->( dbSetOrder( 1 ) )
			If NJR->( dbSeek( xFilial( "NJR" )+M->NKT_CODCTR ) ) .AND. NJR_STATUS=='P'
				Help(,, STR0001,,STR0022 , 1, 0 )		//# Ajuda #"Não é possivel utilizar Contrato previsto, favor Confirmar o contrato de compra."
				lRet := .f.
			EndIF

		EndIf

	ElseIF nOperation == MODEL_OPERATION_DELETE
		IF Empty(M->NKT_NUMPED)
			ADA->(dbGoTo( nAdaRecno ) )
			Do Case
				Case ADA->ADA_STATUS == 'D'
				Help(,, STR0001,,STR0009 , 1, 0 )				//#'Ajuda' #"Contrato de Troca não pode ser excluido Pois o mesmo já está totalmente empenhado"
				lRet := .f.
				Case ADA->ADA_STATUS == 'C'
				Help(,, STR0001,,STR0010 , 1, 0 )				//#STR0001, #"Contrato de Troca não pode ser excluido Pois o mesmo já está parcialmente empenhado"
				lRet := .f.
				Case ADA->ADA_STATUS == 'E'
				Help(,, STR0001,,STR0011 , 1, 0 )				//#Ajuda #"Contrato de Troca não pode ser excluido pois o contrato de parceria foi encerrado"
				lRet := .f.
			EndCase

		EndIf
	EndIf

 // valida se já existe programação de entrega e liberação de pedido, se tiver deve excluir/estornar para conseguir alterar
	If nOperation == MODEL_OPERATION_UPDATE
 		dbSelectArea( "NJ5" )
 		NJ5->( dbSetOrder( 1 ) )
 	    dbSelectArea( "SC9" )
 		SC9->( dbSetOrder( 1 ) )
 		If !Empty(NJ5->( dbSeek( xFilial( "NJ5" )+M->NKT_NUMPED))) .Or. !Empty(SC9->( dbSeek( xFilial( "SC9" )+M->NKT_NUMPED)))
 			Help(,, STR0001,,STR0078, 1, 0 ) //# Ajuda #"Somente possível alterar registros sem programação de entrega (AGRA860) e sem liberação do pedido (MATA440)"
 			lRet := .f.
 		EndIF
	EndIf

	RestArea( aAreaADA )

Return( lRet )


/**{Protheus.doc}
Rotina que Mostra os dados do Ctrato de Cpra
que será utilizado na Troca ..
@param oVIEW
@return Qt. a receber de todos os itens do grid;
@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Static Function fShowCCPRA()

	Local lContinua		:= .t.
	Local aAreaAtu		:= GetArea()

	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")

	Local cCodCtr			:= oModelNKT:GetValue("NKT_CODCTR")

	//Vars do ExecView
	Local cTitulo		:= STR0012 // #" Contrato de Compra em Troca "
	Local cPrograma		:= "OGA280"
	Local nOperation 	:= MODEL_OPERATION_VIEW
	Local bOk			:= {||.f.}
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.t.,STR0040},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //###"Fechar"

	Private aGrvNKA	:= {}

	//--Lendo o Ctrato de Compra //
	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	If .Not. dbSeek( xFilial( "NJR" ) + cCodCtr )
		lContinua := .f.
	EndIF

	IF lContinua == .t.
		//--Antes de chamar desabilito as fkeys (n. qro q se precionar f5 com o ccpra apareca o ctr par)
		SetKey (VK_F2, nil)
		SetKey (VK_F5, nil)


		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, bOk , 12/*nPercReducao*/, aEnableButtons, /*bCancel*/ )

		//-- Retorno as fKeys
		SetKey( VK_F2, { || fShowCCpra() } ) 		// Setanto F2 para Mosrar o Compra
	EndIF

	RestArea( aAreaAtu )

Return

/**{Protheus.doc}
Rotina que Mostra os dados do Pedido de venda
que será utilizado na Troca .
@param nOpc = 2 ->> Visualizar), 4 ->>Alterar
@return nil
@author Bruno Coelho
@since 11/2016
@version 1.0
/*/
Static Function fShowPedVen(nOpc)

	Private cCadastro := STR0051	//#"Pedido de venda"
	Private aRotina   := StaticCall(MATA410, MenuDef)

	IF Empty(M->NKT_NUMPED)
		IF nOpc == 4 		//Necesessário identificar o Pedido de venda da linha selecionada no browse
			fGetPedVen() 	//-- >> busca o Pedido de venda do Acordo de troca(Ataliza as Variaveis STATICAS nSC5Recno , cSC5NumPed) -- >>
		ElseIF nOpc == 2 	// Veio das Fkeys , declaradas no modelo;
			Help(,, STR0001,,STR0056 , 1, 0 )			//#Ajuda #"Não há Pedido de venda vinculado a este acordo de troca."
			Return ( nil )
		EndIF
	EndIF

	//--Antes de chamar desabilito as fkeys(o Ctrpar tem f2 portanto desabilito a F2 e reabilito na volta )
	SetKey (VK_F2, nil)
	SetKey (VK_F7, nil)

	SC5->(dbGoTo( nSC5Recno ) )
	A410Visual('SC5',nSC5Recno, nOpc )   		//Visualiza o Pedido de venda
	//-- Retorno as fKeys
	SetKey( VK_F2, { || fShowCCpra() } ) 		// Setanto F2 para Mostrar o Contrato
	SetKey( VK_F7, { || fShowPedVen( 2 ) } ) 	// Setanto F7 para Mosrar o Pedido de venda ( 2 = Visualizar)

Return

/**{Protheus.doc}
Busca Dados do  Ctrato de Compra,
Cliente, Produto, Um de preço
@param oVIEW
@return Atualiza os campos de Cliente,Produto,Um Preço;
@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

//function fOG300CPRA( cCampo )
function fOG300CPRA()
	Local aAreaAtu		:= GetArea() //ADB
	Local aAreaNJR		:= NJR->( GetArea() )

	Local oView			:= FwViewActive()
	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")

	Local cCliente		:= ''
	Local cCliNome		:= ''

	Local cProduto		:= ''
	Local cUmPRC		:= ''
	Local cProdDesc		:= ''
	Local cCodSaf		:= ''
	Local nNjrVlrBas	:= 0
	Local nQtTrc		:= 0

	Local cCodCtr			:= oModelNKT:GetValue("NKT_CODCTR")

	IF Empty(cCodCtr)
		oModeLNKT:ClearField('NKT_CODCLI')
		oModeLNKT:ClearField('NKT_LOJCLI')
		oModeLNKT:ClearField('NKT_CLINOM')
		oModeLNKT:ClearField('NKT_CODPRO')
		oModeLNKT:ClearField('NKT_DESPRO')
		oModeLNKT:ClearField('NKT_UMPRC')
		oModeLNKT:ClearField('NKT_QTTRC')
		oModeLNKT:ClearField('NKT_CLIENT')
		oModeLNKT:ClearField('NKT_LOJAEN')
		oModeLNKT:ClearField('NKT_CODSAF')
		
		If !(oModel:getOperation() == MODEL_OPERATION_UPDATE)
			oModeLNKT:ClearField('NKT_VRPAUT')
		endIF
		
		oView:Refresh('VIEW_NKT')

		Return( )
	EndIF

	//--Lendo o Ctrato de Compra //
	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

	cCliente		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod Forn. Origem
	cLjaCli			:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Forn. Origem
	cCliNome		:= Posicione("SA1",1,FwxFilial("SA1")+cCliente+cLjaCli,"SA1->A1_NOME")						// Nome do Cliente

	cProduto		:= NJR->NJR_CODPRO
	cUmPRC			:= NJR->NJR_UMPRC
	cProdDesc		:= Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC')
	cCodSaf			:= NJR->NJR_CODSAF
	nNjrVlrBas		:= NJR->NJR_VLRBAS

	nQtTrc := noRound( AGRX001(NJR->NJR_UM1PRO , NJR->NJR_UMPRC, NJR->NJR_QTDCTR, NJR->NJR_CODPRO ), 2 )

	//	oModelNKT:SetValue("NKT_CODCLI", cCliente)
	oModelNKT:SetValue("NKT_LOJCLI", 	cLjaCli)
	oModelNKT:SetValue("NKT_CLINOM", 	Substr(cCliNome,1,TamSx3('NKT_CLINOM')[1]) )
	oModelNKT:SetValue("NKT_CODPRO", 	cProduto)
	oModelNKT:SetValue("NKT_DESPRO", 	cProdDesc)
	oModelNKT:SetValue("NKT_UMPRC", 	cUmPRC)
	omodelNKT:SetValue("NKT_QTTRC",		nQtTrc)
	omodelNKT:SetValue("NKT_CODSAF",	cCodSaf)

	If !(oModel:getOperation() == MODEL_OPERATION_UPDATE)
		oModelNKT:SetValue("NKT_VRPAUT", nNjrVlrBas)
	EndIf

	RestArea( aAreaNJR )
	RestArea( aAreaAtu )

Return ( cCliente )


/*/{Protheus.doc} fRateio ()
Rotina que Rateia qtd. em OM, nos itens em caso de necessidade;
Garantindo que os itens da Venda utilizados na troca tenham o Vr. em outra Moeda se somados igual
a Qtidade de Sacos do Ctrato de compra vinculado;
<<<<	Lembrando que tenho q levar em consideração que Qtd X ao indice de conversão, precisao bater com o
Vr. total em OM do item pois eles irão gerar uma NF. 	>>>

@param oVIEW
@return Grid atualizado com os Itens rateados;
@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/
Static  Function fRateio( oView )
	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO     := oModel:GetModel("NKOGRID")
	Local oModelCalc	:= omodel:GetModel("OGA300TOTAL")
	Local nOperation	:= oModel:GetOperation()

	Local nQuant		:= 0
	Local nQtTrc		:= FWFLDGET( "NKT_QTTRC")  
	
	Local nTotMoeTRC	:= ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 )
	Local nTotMoeda   	:= ROUND(oModelCalc:GetValue("TOTMOEDA1"), 4 ) //oModelCalc:GetValue("TOTMOEDA1")
	
	Local nRatearTR		:= 0 //Vr. a Ratear em Outra moeda
	Local nRatearMo		:= 0 //Vr. Rateaar Moeda 1
	Local nRateadoIt	:= 0
	Local nAux			:= 0
	Local nAux1			:= 0
	Local nItMaiorVr	
	Local nMaiorVr		

	Local nVrVndPrv		:= oModelNKT:GetValue("NKT_VRVNDP")
	Local aSaveLines    := FWSaveRows()

	Local nX
	Local cont   := 0
	
	//-- Encontra o Vr. a ratear na Moeda do Contrato
	nRatearTR := ROUND((nQtTrc - nTotMoeTRC), 4 )
		
	IF nRatearTr = 0   		//-- N. tenho q ratear
		Return
	ElseIF nRatearTR < 0   //-- se a qtd. a ratear for < 0, vou Sair fora pois nesse momento creio q isso n. irá acontecer
		Help( , , STR0001, , STR0015 , 1, 0 )	//#Ajuda #'Não há Valor a Ratear. Verifique, pois o Vr. total em OM, é maior que o vr total no contrato de Compra.'
		Return
	EndIF
		
	//--Se apos ratear ainda a Qtd. de troca n. bater com a Qtd do Ctrato
	//--Ajusto a dif no Item q tem a Maior percentagem
	nRatearMO :=   ROUND((Posicione("NJR",1, FWxFilial("NJR")+M->NKT_CODCTR,"NJR_VLRTOT")) - nTotMoeda, 4)  
		
	//-- Varrendo os itens e rateando  o Vr. a ratear nos itens
	//-- de forma proporcional a Valor total na 1aMoeda.
	nItMaiorVr := 0
	nMaiorVr   := 0
		
	For nX := 1 to oModelNKO:Length()
		
		oModelNKO:GoLine( nX )
		If .Not. oModelNKO:IsDeleted()
			//--Na alteração se o item já tiver sido empenhando(Ja tenho um Pv para ele)  n. posso utilizalo para rateio
			//-- pois seu vr. n. pode mais mudar senão os vr.s totais faturados n. fecharam com os Vrs. do ctrato de troca
			IF nOperation == MODEL_OPERATION_UPDATE
				nQtEmp := 0
		
				ADB->( dbSetOrder( 1 ) )
				IF ADB->( dbSeek( xFilial( "ADB" ) + cAdaNumctr + FWFLDGET('NKO_ITEM',nX ) ) )
					nQtEmp :=  ADB->(ADB_QTDEMP + ADB_QTDENT)
				EndIF
				IF nQtemp > 0
					Loop
				EndIF
			EndIF
		
			nPercItem 	:= ROUND((FWFLDGET( "NKO_TOTAL",	nX )/ nTotMoeda * 100), 4 ) //Qtos % Este item corresponde do total
			nRateadoIt	:= ROUND((nRatearMo * nPercItem / 100), 4 ) 
			nQuant		:= ROUND(FWFLDGET( "NKO_QUANT",	nX 	), 4)
			nAux		:= ROUND((Posicione("NJR",1, FWxFilial("NJR")+M->NKT_CODCTR,"NJR_VLRTOT")*(nPercItem / 100)), 4)
			nAux1		:= (nAux / nQuant)
		
			oModelNKO:SetValue("NKO_PRCVEN", nAux1	)	//Move o novo Vr. unitario composto com o Rateio	
			oModelNKO:SetValue("NKO_PROPOR", nPercItem)
			
			IF FWFLDGET( "NKO_TOTAL",	nX ) > nMaiorVr
				nItMaiorVr := nX
				nMaiorVr   := FWFLDGET( "NKO_TOTAL",	nX )
			EndIF
		
		EndIF
	Next nX
	
	fActQtREC(oView) // Atualiza os Vrs. a Receber em OM, ns itens do Grid
		
	//-- Se apos o Rateio ainda ouver dif. tento Ratear a dif , em cada um dos itens até o final do grid
	For nX := 1 to oModelNKO:Length()
	
		//--Neste momento as Qtidades em OM, do Ctrato de compra , Com a Qtd.Troca dos Itens Deve ser Igual
		nTotMoeTRC		:= ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 )  
		nRatearTR		:=	ROUND((nQtTrc - nTotMoeTRC), 4 ) 
		
		//-- Se apos o Rateio ainda ouver dif. tento rastrear a dif , em cada um dos itens até o final do grid
		IF nRatearTR = 0   
			Exit
		EndIF
		
		oModelNKO:GoLine( nX )
		
		If .Not. oModelNKO:IsDeleted()
		
			//--Na alteração se o item já tiver sido empenhando(Ja tenho um Pv para ele)  n. posso utilizalo para rateio
			//-- pois seu vr. n. pode mais mudar senão os vr.s totais faturados n. fecharam com os Vrs. do ctrato de troca
			IF nOperation == MODEL_OPERATION_UPDATE
				nQtEmp := 0
				ADB->( dbSetOrder( 1 ) )
				IF ADB->( dbSeek( xFilial( "ADB" ) + cAdaNumctr + FWFLDGET('NKO_ITEM',nX ) ) )
					nQtEmp :=  ADB->(ADB_QTDEMP + ADB_QTDENT)
				EndIF
				IF nQtemp > 0
					Loop
				EndIF
			EndIF
		
			// A dif. deve ser 0.0Alguma coisa vr. irrisorio por unidade.
			nQuant			:= FWFLDGET( "NKO_QUANT")
			nPrcVenAtual	:= FWFLDGET( "NKO_PRCVEN")
			IF nRatearTr > 0
				nAux		:= ROUND((FWFLDGET( "NKO_TOTAL"	) + (nRatearTR * nVrVndPrv )), 4) 
			ElseIF nRatearTr < 0
				nAux		:= ROUND((FWFLDGET( "NKO_TOTAL"	) - (nRatearTR * nVrVndPrv )), 4) 
			EndIF
			nAux1		:= ROUND((nAux / nQuant), 4 )  
			oModelNKO:SetValue("NKO_PRCVEN", 	nAux1 )	//Move o novo Vr. unitario composto com o Rateio
		EndIF
	Next nX

	// Atualiza os Vrs. a Receber em OM, ns itens do Grid
	fActQtREC(oView) 
	
	//--Neste momento as Qtidades em OM, do Ctrato de compra , Com a Qtd.Troca dos Itens Deve ser Igual
	nTotMoeTRC := ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 ) 

	nRatearTR  :=	ROUND((nQtTrc - nTotMoeTRC), 4 )


	IF ! nRatearTR = 0  // Se Ainda o Vr. em OM  não Bater com o Total do Ctr. Compra ajusto no Item Com Maior Vr. a Dif.
		//-Adiciono a Dif. ainda Existente no Item de Maior Vr.	Para ver se Equaliza o Vr. total em Scs, com o Total do Grid em OM

		oModelNKO:GoLine( nItMaiorVr )
		nQuant			:= FWFLDGET( "NKO_QUANT",	nItMaiorVr 	)
		IF nRatearTr > 0
			nAux := ROUND((FWFLDGET( "NKO_TOTAL", nItMaiorVr) + (nRatearTR * nVrVndPrv )), 4) 
		ElseIF nRatearTr < 0
			nAux := ROUND((FWFLDGET( "NKO_TOTAL", nItMaiorVr) - (nRatearTR * nVrVndPrv )), 4)
		EndIF

		nAux1 := ROUND((nAux / nQuant), 4 ) 
		oModelNKO:SetValue("NKO_PRCVEN", nAux1 ) 
	EndIF

	fActQtREC(oView) // Atualiza os Vr. a Receber em OM no Grid

	nTotMoeTRC		:= ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 ) //Get, total em OM
	nRatearTR		:=	ROUND((nQtTrc - nTotMoeTRC), 4)

	//Se Ainda a Qtd. dos itens em OM, Ainda não bater c a Qtd. do Ctrato
	//Tento ajustar agora mas pelo indice de paridade Rodando en todos os itens do Grid para tentar Zerar
	//a Dif. q aqui eh de 0,0 alguma Coisa
	IF ! nRatearTr = 0   	
		lDifAdd:= IIF(nRatearTR > 0,.t.,.f.)
		
		For nX := 1 to oModelNKO:Length()  //Varrendo itens do Grid
		
			oModelNKO:GoLine( nX )
		
			If .Not. oModelNKO:IsDeleted()
		
				//--Na alteração se o item já tiver sido empenhando(Ja tenho um Pv para ele)  n. posso utilizalo para rateio
				//-- pois seu vr. n. pode mais mudar senão os vr.s totais faturados n. fecharam com os Vrs. do ctrato de troca
				IF nOperation == MODEL_OPERATION_UPDATE
					nQtEmp := 0
					ADB->( dbSetOrder( 1 ) )
					IF ADB->( dbSeek( xFilial( "ADB" ) + cAdaNumctr + FWFLDGET('NKO_ITEM',nX ) ) )
						nQtEmp :=  ADB->(ADB_QTDEMP + ADB_QTDENT)
					EndIF
					IF nQtemp > 0
						Loop
					EndIF
				EndIF
		
				nAuxIDXPAR := FWFLDGET( "NKO_IDXPAR") //-- Qdo o Vr. antes de começar a Tentar o Ajuste--
		
				While cont <= 100
		
					nTotMoeTRC		:= ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 ) //Get, total em OM
					nRatearTR		:=	ROUND((nQtTrc - nTotMoeTRC), 4 )
		
					nAux := FWFLDGET( "NKO_IDXPAR")   // (((( Estou posicionado em cima da Linha do Grid ))
					IF nRatearTr > 0
						IF  lDifAdd == .t.      // Indica que a dif. Originada eh de adição (itens do Grid a menor)
							nAux	+= 0.0001 	//Vou Incrementando de 0.0001 Sacas para tentar zerar Qdo os Itens do Grid estão a menor;
						Else 	                // Indica q vim adicionando adicionando e o no geral não Bateu
						// Retorno o Vr. antes de Entrar no While
							oModelNKO:SetValue("NKO_IDXPAR", 	nAuxIdxPar 	)
							Exit
						EndIF
					ElseIF nRatearTr < 0
						IF  lDifAdd == .f.      //Indica que a Dif. Originada eh de Subtracao(Itens do Grid a Maior)
							nAux    -= 0.0001 	//Vou Incrementando de 0.0001 Sacas para tentar fazer Zerar Qdo os Itens do Grid Estão a Maior
							// Então n. consegui Ajustar a dif neste item vamos tentar em outo no for;
						ELSE
							oModelNKO:SetValue("NKO_IDXPAR", 	nAuxIdxPar 	) // Retorno o Vr. antes de Entrar no While
							Exit // Indica q vim subtrainto subtraindo e q chegou ao pouto do grid ficar a Menor e não equalizou com a Qtd. do Ctrato;
							// Então n. consegui Ajustar a dif neste item vamo tentar em outo no for;
						EndIF
					ElseIF nRatearTR == 0 //Diferença ajustada
						Exit
					EndIF
					oModelNKO:SetValue("NKO_IDXPAR", nAux )
					cont++
				EndDO
		
				fActQtREC(oView) // Atualiza as Qtds. em OM , a Receber de todos os Itens do Grid;
		
				nTotMoeTRC	 := ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 )//Get, total em OM
				nRatearTR	 :=	ROUND((nQtTrc - nTotMoeTRC), 4 ) 
				IF nRatearTr == 0 // Qtidade do Contrato em SCs. bate com a qTD do Grid
					Exit
				EndIF
			EndIF
		nExt Nx
	EndIF

	fActQtREC(oView)        // Atualiza as Qtds. em OM , a Receber de todos os Itens do Grid;

	nTotMoeTRC		:= ROUND(oModelCalc:GetValue("TOTMOEDA2"), 4 )
	nRatearTR		:=	nQtTrc - nTotMoeTRC
	
	FWRestRows(aSaveLines)

	oview:Refresh()

Return

/** {Protheus.doc} TudoOk
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA290 - Contratos de Venda
*/

Static Function TudoOk( oModel )
	Local lRetorno		:= .t.
	Local nOperation	:= oModel:GetOperation()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelCalc    := omodel:GetModel("OGA300TOTAL")


	IF nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		// -- Valida as Qt. dos itens em OM, com  a Qtd. em SCs. do Ctrato de Compra -- //
		IF  ROUND(oModelCalc:GetValue("TOTMOEDA2"), 2 ) != FWFLDGET( "NKT_QTTRC")
			Help( , , STR0001, , STR0016 , 1, 0 )	//#Ajuda #'O Vr. total em Outra Moeda não bate com a qtidade negociada do contrato.'
			lRetorno :=.f.
		EndIF

		//--Valida a Moeda --
		IF lRetorno
			IF fOg300Vld2() //  Verifica se a Moeda existe no sistema
				IF oModeLNKT:GetValue("NKT_MOEDA") == 1 // Verifica se a moeda de Troca não é a moeda 1
					Help( , , STR0001, , STR0017 , 1, 0 )	//Ajuda #'Moeda de troca não pode ser a moeda ( << 1 >> ).'
					lRetorno :=.f.
				EndIF
			ELSE
				lRetorno := .f.
			EndIF
		EndIF
	EndIF


Return( lRetorno )

/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA280 - Contratos
*/
Static Function GrvModelo( oModel )
	Local nOperation 	:= oModel:GetOperation()
	Local oModelNKO  	:= oModel:GetModel("NKOGRID")
	Local aSaveLines    := FWSaveRows()
	Local nX			:= 0
	//Monta o Aitens
	Local aCab			:= 0
	Local aItens 		:= {}
	Local aitauto 		:= {}
	Local lRet          := .t.
	
	If IsBlind()
	  __nTipo := 2
	EndIf

	If __nTipo == 1

			//Monta o Acab ADA --
			aCab := {}

			IF nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE
				aAdd( aCab, { "ADA_NUMCTR"		, cAdaNumCtr	,nil } )
			EndIF

			aAdd( aCab, { "ADA_TRCNUM"		, FWFLDGET( "NKT_TRCNUM")	,nil } )
			aAdd( aCab, { "ADA_CODSAF"		, FWFLDGET( "NKT_CODSAF")	,nil } )

			IF nOperation == MODEL_OPERATION_INSERT
				aAdd( aCab, { "ADA_EMISSA"		, dDataBase				,nil } )
			EndIF
			aAdd( aCab, { "ADA_CODCLI"		, FWFLDGET( "NKT_CODCLI")	,nil } )
			aAdd( aCab, { "ADA_LOJCLI"  	, FWFLDGET( "NKT_LOJCLI")	,nil } )
			aAdd( aCab, { "ADA_CONDPG"		, FWFLDGET( "NKT_CONDPG")	,nil } )
			aAdd( aCab, { "ADA_MOEDA"		, FWFLDGET( "NKT_MOEDA")	,nil } )
			aAdd( aCab, { "ADA_FILENT"		, cFilAnt					,nil } )


			//--Calc a Qtidade de produto a receber em troca do vr total do item--
			//--Calculo eh igual a vr total do item / vr de venda do produto na troca
			lPassITDel := IiF( nOperation == MODEL_OPERATION_UPDATE,.t.,.f.) // manda os Itens deletados somente qdo for Alteração

			For nX := 1 to oModelNKO:Length()
				oModelNKO:GoLine( nX )
				aItens := {}

				aadd(aItens, {"ADB_ITEM",	FWFLDGET( "NKO_ITEM",		nX ),nil})
				aadd(aItens, {"ADB_CODPRO", FWFLDGET( "NKO_CODPRO",		nX ),nil})
				aadd(aItens, {"ADB_TES", 	FWFLDGET( "NKO_TES",		nX ),nil})
				aadd(aItens, {"ADB_LOCAL", 	FWFLDGET( "NKO_LOCAL",		nX ),nil})
				aadd(aItens, {"ADB_QUANT", 	FWFLDGET( "NKO_QUANT ",		nX ),nil})
				//aadd(aItens, {"ADB_PRCVEN", FWFLDGET( "NKO_PRCVEN",	nX ),nil })
				aadd(aItens, {"ADB_PRCVEN", NoRound(FWFLDGET( "NKO_IDXPAR",	nX ),TamSx3('C6_PRCVEN')[2] ),nil })
				aadd(aItens, {"ADB_CULTRA",	FWFLDGET( "NKO_CULTRA ",	nX ),nil})
				aadd(aItens, {"ADB_CTVAR", 	FWFLDGET( "NKO_CTVAR ",		nX ),nil})
				aadd(aItens, {"ADB_CATEG", 	FWFLDGET( "NKO_CATEG ",		nX ),nil})
				aadd(aItens, {"ADB_PENE", 	FWFLDGET( "NKO_PENE ",		nX ),nil})

				aAdd(AitAuto,aItens)

			Next nX

			FWRestRows(aSaveLines)

			// Ponto de entrada inserido para adição de campos especificos do usuário, antes da Inclusão do Contrato de parceria
			If ExistBlock("OG300CTR")
				aRetPe := ExecBlock("OG300CTR",.F.,.F.,{Omodel,aCab,AitAuto})
				If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
					aCab		:= aClone(aRetPe[1])
					AitAuto		:= aClone(aRetPe[2])
				EndIf
			EndIF
			/* Exemplo do PE
			User Function OG300CTR()
			Local oModel := aClone(PARAMIXB[1])
			Local aCab := aClone(PARAMIXB[2])
			Local aItens := aClone(PARAMIXB[3])
			Local aRet := {} //Customizações do usuário

			aAdd( aCab, {"ADA_MEUCAMPO" 	, 'Valor'		, Nil } )

			aRet := {aCab,aItens}

			Return aRet
			*/

			aCab	:= FWVetByDic(aCab 	,'ADA',.f.)
			aItauto	:= FWVetByDic(aItauto, 'ADB',.T.)

			//-- Passando informação que a Linha Esta Deletada depois do Fwvetbydic, pq senao ela elimina a Informação do array
			lPassITDel := IiF( nOperation == MODEL_OPERATION_UPDATE,.t.,.f.) // manda os Itens deletados somente qdo for Alteração
			For nX := 1 to oModelNKO:Length()
				oModelNKO:GoLine( nX )
				aItens := aItauto[nx]
					If  oModelNKO:IsDeleted()
						Do Case
							Case lPassItDel
							aadd(aItens,{"AUTDELETA","S",Nil})
							AitAuto[NX] := aItens
							OtherWise
							 Loop
						EndCase
					EndIF
			Next nX
			// -- Fim Informando Itens Deletados --
	EndIf

	Begin Transaction
		If __nTipo == 1
			lRet:=fgrvctrpar(aCab, aItauto, nOperation)

			//GRAVANDO HISTÓRICO DE CONFIRMAÇÃO DO CONTRATO DE PARCERIA
			AGRGRAVAHIS(,,,,{"NKT", FWxFilial("NKT") + FWFLDGET("NKT_TRCNUM"), IIF( nOperation == 5, "E", "I" ), STR0013 + " - " + ADA->ADA_NUMCTR}) //STR0013 - Contrato de Parceria - Venda
		else
		If ! IsBlind()
 			lRet:= OGA300PED(oModel)
 		Else
 		   lRet:=  .t.
 		EndIf	
		endif
		If lRet
			lRet:=FWFormCommit( oModel )

			//Atualiza o status do troca para liberado
			NKT->NKT_STATUS := "02" //Liberado

			IF nOperation == 3
				If __nTipo == 1
					NKT->NKT_NUMPAR:= ADA->ADA_NUMCTR
				Else
					NKT->NKT_NUMPED := SC5->C5_NUM
					//TODO *Melhorar - Redundancia de persistencia para resolver relacionamento erroneo
					RECLOCK("SC5")
					SC5->C5_TRCNUM := NKT->NKT_TRCNUM
					MSUNLOCK()
				EndIf
			/*Else
				__nTipo := MV_PAR01*/
			EndIf

			Pergunte('OGA30001', .F.)
			__nTipo := MV_PAR01

		EndIF

		If ! lRet
			RollbackSX8()
			DisarmTransaction()
			lRet := .f.
		EndIf
		
		//Passo o bloco de codigo que será executado dentro da transacao
		//lRet := FwFormCommit(oModel,,,,{||fgrvctrpar(aCab, aItauto,nOperation)})
	End Transaction

Return lRet

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  OGA300HIS()
Mostra em tela o Historico.
@author: Bruno Coelho da Silva
@since.: 01/11/2016
@Uso...: OGA300HIS
/*/
//--------------------------------------------------------------------------------------------
Function OGA300HIS()
	Local cChaveI := "NKT->("+Alltrim(AGRSEEKDIC("SIX","NKT",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
	AGRHISTTABE("NKT",cChaveA)
Return


/*
** {Protheus.doc} fGrvCtrpar
Função que Simula execauto do FATA400 para Incluir,Alterar,Excluir

@param: 	aCab(ADA),Aitauto(ADB)
@return:	.t. ou .f. (Conseguiu incluir ou nao)
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		fGrvCtrPar
*/

Static Function fGrvCtrPar(aCab, aItAuto,nOpc )
	Local nX		:= 0
	Local nUsado    := 0
	Local lContinua	:= .T.
	Local nSaveSx8  := GetSx8Len()
	Local aRegADB	:={}
	Local aStruct	:={}

	Private aRotina := StaticCall(FATA400, MenuDef)

	PRIVATE aTELA[0][0]
	PRIVATE aGETS[0]
	PRIVATE aHeader := {}
	PRIVATE aCols   := {}
	PRIVATE N       := 1

	Private Inclui 	:= .t.
	Private Altera 	:= .F.

	//--Setando o Modulo 67 pq senão não funciona, Alguns Campos só estão visiveis no modulo 67--//
	nModuloAnt := nModulo
	nModulo := 67 //--SigaAGR


	Do Case
		Case nOpc == 3
		Inclui := .t.
		Altera := .f.
		Case nOpc == 4
		Inclui := .f.
		AlTera :=.t.
		Otherwise
		Inclui := .f.
		AlTera :=.f.
	EndCase
	//--Inicializando as Variaveis do Enchoice --//

	IF INCLUI
		RegToMemory( "ADA", .T., .t. ) //inclui
	Else
		nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] == "ADA_NUMCTR" })
		IF nPosCpo > 0
			cNumctr:= aCab[ nPosCpo,2 ]
			dbSelectArea("ADA")
			ADA->( dbSetOrder(1) )
			ADA->( dbSeek( xFilial( "ADA" ) + cNumctr ) )
		EndIF
		RegToMemory( "ADA", .f., .t. )

		//Abastece o array aRegAdb
		ADB->(DbSetOrder(1) )
		aItem 	:= {}
		aRegADB	:= {}
		For nX := 1 to Len(aItAuto)
			aItem := aItAuto[nX]
			nPosCpo	:= ASCAN(aItem, {|aItem| aItem[1] == "ADB_ITEM" })
			cItem	:= aItem[nPosCpo,2]

			IF ADB->( dBseek(FWxFilial("ADB") + ADA->ADA_NUMCTR + cItem ))
			   aAdd(aRegADB, ADB->( Recno() ) )
			EndIF

		nExt nX
	EndIF

	// -- Montando o Aheader ----
	aStruct := ADB->(DbStruct())

	For nX := 1 To Len(aStruct)
		If X3USADO(aStruct[nX,1]) .And. cNivel >= AGRRETNIV(aStruct[nX,1])
			Aadd(aHeadTrb,{ TRIM(RetTitle(aStruct[nX,1])),;
							aStruct[nX,1],;
							X3PICTURE(aStruct[nX,1]),;
							aStruct[nX,3],;
							aStruct[nX,4],;
							X3VALID(aStruct[nX,1]),;
							X3USADO(aStruct[nX,1]),;
							aStruct[nX,2],;
							"ADB",;
							AGRRETCTXT("ADB", aStruct[nX,1])})
		EndIf
	Next nX
	// -- Fim Aheader        ----

	nUsado := nX

	// -- Montando o Acols   ----
	aadd(aCOLS,Array(nUsado+1))
	For nX := 1 To nUsado
		aCols[1][nX] := CriaVar(aHeader[nX][2])
		If ( AllTrim(aHeader[nX][2]) == "ADB_ITEM" )
			aCols[1][nX] := "01"
		EndIf
	Next nX
	aCOLS[1][nUsado+1] := .F.
	// -- FIM Acols          ----


	/*/
	!-------------------------------------------------------------------------------------------------!
	!	O Codigo de Validação foi criado devido ao Fata400 n. possuir execauto, Desta forma garanto   !
	!	as validações do dicionario de dados Antes de chamar a função que grava os Dados		    	!
	!-------------------------------------------------------------------------------------------------!
	/*/
	// -- Monta array aValid com os Vrs. ADA inicializados pelo regtomemory -- //
	aValidGet := {}
	For nX := 1 TO ADA->( FCount() )
		IF  nOpc == 3 .and. ADA->( FIELD( nX )) = "ADA_NUMCTR" // retiro o ADA_NUMCTR pq fica pulando o codigo do ctrato de 2 em 2 ( o q n. queremos )
			Loop
		EndIf
		aAdd(aValidGet,{ADA->( FIELD( nX ) )    ,&(M->( ADA->(FIELD( nX )) )),"CheckSX3('" + M->( ADA->(FIELD( nX )) )+"') .And. VldUser('" + M->( ADA->(FIELD( nX )) )+"')" ,.T.})
		// Sintaxe de Exemplo Amigavel aAdd(aValidGet,{"ADA_CODCLI"    ,M->ADA_CODCLI,"CheckSX3('ADA_CODCLI')    .And. VldUser('ADA_CODCLI')",.t.})
	Next nX

	//---ATualizo o AvalidGet, c/ os Dados q desejo Gravar do array ACAB, para Valida-los---//
	For nX :=1 to Len(aCab)
		nPosCpo := ASCAN(aValidGet, {|aValidGet| aValidGet[1] == acab[nX,1]})
		IF nPosCpo > 0
			aValidGet[ nPosCpo, 2 ] := aCab[ nX,2 ]
		EndIF
	nExt nX
	//----------------------------------------------------------------------------------------------------

	// --Validando a ADA --
	aValidGet := fWVetByDic(aValidGet,'ADA')	// Organizando os Campos para validar na ordem do Dic, Senao pode validar loja do cli antes do codigo ai dah erro
	IF ! ADA->( MsVldGAuto(aValidGet) ) 		// -- Validando as Variaveis do ADA ( Cabecalho ) //
		lContinua 	:= .f.
	EndIF

	// --Validando a ADB, se a ADA esta OK --
	IF lContinua == .t.
		IF !MsGetDAuto(aItauto,{|| Ft400LinOk()},{|| Ft400TudOk()},aCab,nOpc) 		// -- Validando os Itens ADB 						//
			lContinua	:= .f.
		EndIF
	ENDIF

	IF ! lContinua	// --Erro de Validação --//
		MostraErro()
		Return(.f.)
	Else				//--Tudo Ok --//
		Begin Transaction
			If Ft400Grava(IIF (nOpc == 3,1,IIF (nOpc == 4,2,3)),aRegADB ) //1 Inclui,2=altera,3Exclui
				EvalTrigger()
				While (GetSx8Len() > nSaveSx8)
					ConfirmSx8()
				EndDo
			Else
				While (GetSx8Len() > nSaveSx8)
					RollBackSx8()
				EndDo
			EndIf
			//-- Atualiza o Status do contrato de Parceria --//
			FT400STATCT()
		End Transaction
		FWLogMsg("INFO", , "OGA300", funName(), , "01", STR0079 + M->ADA_NUMCTR, 0, 0, {}) //http://tdn.totvs.com/x/fgueCQ ###'Ctr.Parceria Inserido: '

	EndIF

	//--Retornando o Modulo original--//
	nmodulo := nModuloAnt

Return .t.

/*/{Protheus.doc} fDadosSem
Encontra os Dados Ref. a Semente de Acordo como Campo Recebido

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Static Function fDadosSem( cCampo )

	Local oModel        	:= FWModelActive()
	Local oModelNKO      := oModel:GetModel("NKOGRID")
	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")
	Local cValor			:=''

	dbSelectArea("SB5")
	SB5->( dbSetOrder(1) )
	IF ( SB5->( dBSeek( fwxFilial("SB5") + cProduto ) ) ) .And. SB5->B5_SEMENTE == '1'
		Do Case
			Case cCampo $ "NKO_CULTRA"
			cValor  := SB5->B5_CULTRA
			Case cCampo $ "NKO_CTVAR"
			cValor  := SB5->B5_CTVAR
			Case cCampo $ "NKO_CATEG"
			cValor  := SB5->B5_CATEG
			Case cCampo $ "NKO_PENE"
			cValor  := SB5->B5_PENE
		EndCase
	EndIf

Return cValor

/*/{Protheus.doc} fOg300SeOK
Valida os dados Ref. a Sem.

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Function fOg300SeOK( cCampo )
	Local aAreaAtu 		:= GetArea()
	Local aAreaSB5 		:= SB5->( GetArea() )
	Local oModel        	:= FWModelActive()
	Local oModelNKO      := oModel:GetModel("NKOGRID")
	Local cProduto		:= oModelNKO:GetValue("NKO_CODPRO")
	Local cValor			:= FWFLDGET( Alltrim(cCampo) )
	Local cVrSB5			:=''
	Local lOk				:= .t.

	dbSelectArea("SB5")
	SB5->( dbSetOrder(1) )
	IF ( SB5->( dBSeek( fwxFilial("SB5") + cProduto ) ) ) .And. SB5->B5_SEMENTE == '1'
		Do Case
			Case cCampo $ "NKO_CULTRA"
			cVrSB5  := SB5->B5_CULTRA
			Case cCampo $ "NKO_CTVAR"
			cVrSB5  := SB5->B5_CTVAR
			Case cCampo $ "NKO_CATEG"
			cVrSB5  := SB5->B5_CATEG
			Case cCampo $ "NKO_PENE"
			cVrSB5  := SB5->B5_PENE
		EndCase

		IF !Empty(cVrSB5)
			IF ! Alltrim(cValor) = Alltrim(cVrSB5)
				Help(,, STR0001,,STR0018 + CRLF + STR0019, 1, 0 )	//#Ajuda #"Valor invalido." #"O valor informado deve ser igual ao valor informado na tabela (SB5) complemento de produtos aba Agro."
				lOk := .F.
			EndIF
		EndIF

	EndIf

	RestArea( aAreaSB5 )
	RestArea (AAreaAtu )

Return lOk

/*/{Protheus.doc} fOg300Vld1
Valida o contra de compra n. pemitindo Ctrato de compra já utilizado em outro contrato.

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Function fOg300Vld1()
	Local aAreaAtu 		:= GetArea()
	Local aAreaNKT 		:= NKT->( GetArea() )

	Local oModel        := FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local cNktCodCtr	:= oModelNKT:GetValue("NKT_CODCTR")
	Local cNktTrcNum	:= oModelNKT:GetValue("NKT_TRCNUM")
	Local cNktUmPar		:= oModelNKT:GetValue("NKT_UMPAR")
	Local cNktTpPard	:= oModelNKT:GetValue("NKT_TPPARD")
	Local lRet			:= .t.

	IF !Empty( cNktCodCtr )

		dbSelectArea( "NJR" )
		NJR->( dbSetOrder( 1 ) )
		If ! NJR->( dbSeek( xFilial( "NJR" ) + cNktCodCtr ) )
			Help(,, STR0001,,STR0020 , 1, 0 )			//#Ajuda # "Contrato de compra não existe. Verifique e informe outro contrato de compra."
			lRet := .f.
		Else
			IF !NJR->NJR_TIPO = '1'
				Help(,, STR0001,,STR0021 , 1, 0 )		//Ajuda, #"Contrato não é contrato de compra"
				lRet := .f.
			ElseIF NJR_STATUS=='P'
				Help(,, STR0001,,STR0022 , 1, 0 )		//# Ajuda #"Não é possivel utilizar Contrato previsto, favor Confirmar o contrato de compra."
				lRet := .f.
			ElseIF NJR_MODELO=='3'
				Help(,, STR0001,,STR0023 , 1, 0 )		//#Ajuda #"Não é possivel utilizar Contrato automatico."
				lRet := .f.
			ElseIF NJR_STATUS=='E'
				Help(,, STR0001,,STR0074 , 1, 0 )		//#Ajuda #"Não é possivel utilizar Contrato Cancelado."
				lRet := .f.
			EndIF
		EndIF

		IF lRet  //Verifica se o Ctrato de Compra já n. faz. parte de um outro acordo de Troca

			dbSelectArea("NKT")
			NKT->( dbSetOrder(2) )
			IF ( NKT->( dBSeek( fwxFilial("NKT") + cNktCodCtr ) ) )
				IF NKT->NKT_TRCNUM != cnktTrcNum
					Help(,, STR0001,,STR0024 + NKT->NKT_TRCNUM + STR0025 , 1, 0 )		//#'Ajuda' #"Contrato de compra já utilizado no processo de Troca:" #", Verifique e informe outro contrato de compra"
					lRet := .F.
				EndIF
			EndIF
		Endif

		IF lRet
			IF cNktTpPard == '2' 	// Indica que a Troca irá ter a paridade Calculada Por UM
				// Este tipo de troca requer q todas UMs dos produtos en-
				//volvidos tenham que ser possivel converter a UMs deles
				//Para UM, escolhida na Troca
				// Verifica se é possivel converter a UM. do Produto do Ctrato para a Um, da Troca
				IF ! fValConvUM(NJR->NJR_UMPRC, cNktUmPar, 1) .and. !Empty( cNktUmPar )
					Help(,, STR0001,,STR0026 , 1, 0 )		//#Ajuda #"Não é possivel Converter a UM. de preço do Ctrato de Compra para a UM. informada no acordo de troca"
					lRet := .F.
				EndIF
			EndIf
		EndIF

	EndIF


	RestArea( aAreaNKT )
	RestArea (AAreaAtu )

Return lRet

/*/{Protheus.doc} OG300VLTRC
Validação Utilizada no fata400, para impedir o Fata400,excluir
um ctrato que foi gerado pelo acordo de troca

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/
Function OG300VLTRC(nOpcX)
	Local lContinua:= .t.

	IF !Empty(ADA->ADA_TRCNUM)
		IF nOpcX == 5
			lContinua := .f.
		EndIF
		Do Case
			Case nOpcX == 4
			//Help(,, 'Ajuda',,"Contrato não pode ser Alterado pois faz parte de um acordo de Troca." , 1, 0 )
			IF !(IsInCallStack( 'FSHOWCTPAR' )) 	// Só mostra o help qdo a chamada não vor feita via OGA300
				Help(,, STR0001,,STR0027 , 1, 0 )	//#Ajuda #"Contrato faz parte de um acordo de troca portanto alguns campos não podem ser alterados."
			EndIF
			Case nOpcX == 5
			Help(,, STR0001,,STR0028 , 1, 0 )		//Ajuda #"Contrato não pode ser Excluido pois faz parte de um acordo de Troca."
		EndCase

	EndIF

Return (lContinua)

/*/{Protheus.doc} fOg300Vld1
Valida a Moeda d Troca;

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Function fOg300Vld2()
	Local cAlias    := Alias()
	Local nOrder    := IndexOrd()
	Local oModel    := FWModelActive()
	Local oModeLNKT	:= oModel:GetModel("NKTUNICO")
	Local nMoeda	:= oModelNKT:GetValue("NKT_MOEDA")
	Local lRet		:= .t.

	//Verifica se a moeda existe no SX3
	cMoeda        := Alltrim(Str(nMoeda))

	dbSelectArea("SX3")

	nRec := SX3->( Recno() )
	dbSetOrder(2)
	If !dbSeek("M2_MOEDA"+cMoeda)
		Help( , , STR0001, , STR0029, 1, 0 )		//#Ajuda #'Moeda não encontrada no sistema.'
		lRet := .F.
	EndIf

	SX3->( dbGoto(nRec) )
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
Return lRet

/*/{Protheus.doc} fOg300Vld3
Valida a Mudança do tipo
de Paridade a utilizar no acordo de troca

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Function fOg300Vld3()
	Local nOpcao 			:= 1
	Local lRet				:= .t.
	Local oView			:= FwViewActive()
	Local oModel        	:= FWModelActive()
	Local oModelNKO    	:= oModel:GetModel("NKOGRID")
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local cNktTpPard		:= omodelnkt:getvalue('NKT_TPPARD')
	Local cProduto		:= oModeLNKO:GetValue("NKO_CODPRO", 1 )

	IF ( oModelNKO:Length() == 1 .and. ! Empty(cProduto) ) .or. oModelNKO:Length() > 1
		nOpcao := AVISO(STR0030, STR0031, { STR0032 , STR0033 }, 2)		//#Atenção #"Ao mudar o Tipo de paridade, os Itens digitados de troca serão eliminados. Confirma a mudança do tipo de paridade?" #"OK"#"Cancelar"
	EndIF

	lRet := IIF(nOpcao == 1, .t., .f.)

	IF lRet
		// Habilito o cpo de UM. de Paridade que stah com a Edição desabilitada
		oModEl:GetModel("NKTUNICO"):GetStruct():SetProperty( 'NKT_UMPAR' , MODEL_FIELD_WHEN, {|| MODEL_OPERATION_INSERT	 .and. cNktTpPard == '2' } )
		// Desabilitoo cpo de Tabela de Preço que stá Habilitado
		oModEl:GetModel("NKTUNICO"):GetStruct():SetProperty( 'NKT_TBPRAT' , MODEL_FIELD_WHEN, {|| MODEL_OPERATION_INSERT .and. cNktTpPard == '1' } )
	EndIF

   If !IsBlind()
	oView:Refresh('VIEW_NKT')
   EndIf
Return lRet

/*/{Protheus.doc} fOg300Vld4
Rotina de Validação , Para garantir que
Qdo o Tipo de troca for 2;
1o) Garante que a Unidade de medida de Troca stá preenchida;
2o) Garante que a Um. de preço possui fator de conversão
entre a UM de preço do produto e a Un.medida do acordo;
(Iremos Urilizar a UM Pq a SG alega q na B1_um nâo pode ter
Um tipo S6 (Correspondendo a uma saca de 60),S4 (Correspondendo a uma saca de 40)

@author Emerson Coelho
@since 29/04/2013
@version 1.0
/*/

Function fOg300Vld4()
	Local lRet			:= .t.
	Local oModel        	:= FWModelActive()
	Local oModelNKO    	:= oModel:GetModel("NKOGRID")
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local cNktTpPard		:= omodelnkt:getvalue('NKT_TPPARD')
	Local cNktUmPar		:= oModelNKT:GetValue("NKT_UMPAR")
	Local cProduto		:= oModelNKO:GetValue('NKO_CODPRO')
	Local cProdUmPrc     := POSICIONE("SB5",1,fWxFilial("SB5")+cProduto,"B5_UMPRC")
	Local cNktCodCtr		:= oModelNKT:GetValue("NKT_CODCTR")
	Local nNktVrVnDp		:= oModelNKT:GetValue("NKT_VRVNDP")
	Local cNJR_UMPRC		:= IIF(!Empty( cNktCodCtr),POSICIONE("NJR",1,fWxFilial("NJR")+ cNktCodCtr ,"NJR_UMPRC") , '' )

	IF ! cNktTpPard == '2' // Se não for Troca por Unidade de Medida
		Return ( lRet )
	EndIF

	// Validação para Garantir que UM da Troca Seja Preenchida

	IF Empty( cNktUmPar )
		Help(,, STR0001,,STR0034 , 1, 0 )		//#Ajuda #"Acordo de troca por Unidade de medida; Favor informar UM. do acordo de troca"
		lRet := .F.
	ElseIF Empty( POSICIONE("SB5",1,fWxFilial("SB5")+SB1->B1_COD, "B5_UMPRC"))
		Help(,, 'Ajuda',,STR0035 , 1, 0 )		//#Ajuda # "Acordo de troca por Unidade de medida, e o produto não possui Um. de Preço, favor informar"
		lRet := .F.
	ElseIF !Empty( POSICIONE("SB5",1,fWxFilial("SB5")+SB1->B1_COD, "B5_UMPRC") ).and.  ! fValConvUM(cProdUmPrc, cNktUmPar, 1) //!Empty( SB1->B1_UM ).and.  ! fValConvUM(cProdUm, cNktUmPar, 1)
		Help(,, STR0001,,STR0036 , 1, 0 )		//#Ajuda #"Não é possivel encontrar o fator de Conversão entre, a UM. de preço do Produto de venda e a UM. informada no acordo de troca"
		lRet := .F.
	ElseIF Empty( cNktCodCtr )
		Help(,, STR0001,,STR0037 , 1, 0 )		//#Ajuda #"Acordo de troca por Unidade de medida; Favor informar o Contrato de compra para prosseguir."
		lRet := .F.
	ElseIF ! Empty( cNktCodCtr ) .and. ! fValConvUM(cNJR_UMPRC, cNktUmPar, 1) /// .and. !Empty( cNktUmPar )
		Help(,, STR0001,,STR0038 , 1, 0 )		//#Ajuda #"Não é possivel encontrar o fator de conversão entre a UM. de preço do Produto do Contrato de Compra e a UM. do acordo de troca"
		lRet := .F.
	ElseIF  ! nNktVrVnDp > 0
		Help(,, STR0001,,STR0039 , 1, 0 )		//#Ajuda #"Antes de prosseguir favor informar o Vr. de Venda previsto do produto de troca"
		lRet := .F.
	EndIF


Return lRet


/** {Protheus.doc} 7
Função que busca o o Recno e ADA_CTRPAR,
do Ctrato de parceria ref. ao acordo de trocas.

@param: 	Nil
@return:	Ataliza as Variaveis STATICAS nAdaRecno , cAdaNumctr
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fGetCtrPar()

	Local cQryADA	 	:= GetNextAlias()

	BeginSql Alias cQryADA
	Select
	R_E_C_N_O_ as ADA_RECNO
	From
	%table:ADA% ADA
	Where	ADA.ADA_FILIAL = %exp:fWXfilial('ADA')%
	And  	ADA.ADA_TRCNUM = %exp:NKT->NKT_TRCNUM %
	And     ADA.%NotDel%
	EndSql

	nAdaRecno 	:= 0
	cAdaNumctr	:= ''

	//-- Selecionando a Area do Contrato de Parceria e dos Itens --//
	DbSelectArea('ADA')
	DbSelectArea('ADB')
	//------------------------------------------------------------//

	nAdaRecno	:= (cQryADA)->ADA_RECNO
	ADA->(dbGoTo( nAdaRecno ) )
	cAdaNumCtr 	:= ADA->ADA_NUMCTR

Return
	

/** {Protheus.doc}
Função que busca o o Recno e SC5_NUM,
do Pedido de venda ref. ao acordo de trocas.

@param: 	Nil
@return:	Ataliza as Variaveis STATICAS nSc5Recno , cSc5NumPed
@author: 	Bruno Coelho
@since: 	11/2016
@Uso: 		AgroIndustria
*/
Static Function fGetPedVen()

	Local cQrySC5	:= GetNextAlias()

	BeginSql Alias cQrySC5
	Select
	R_E_C_N_O_ as SC5_RECNO
	From
	%table:SC5% SC5
	Where	SC5.C5_FILIAL = %exp:fWXfilial('SC5')%
	And  	SC5.C5_TRCNUM = %exp:NKT->NKT_TRCNUM %
	And     SC5.%NotDel%
	EndSql

	nSC5Recno 	:= 0
	cSC5NumPed	:= ''

	//-- Selecionando a Area do Pedido de venda e dos Itens --//
	DbSelectArea('SC5')
	DbSelectArea('SC6')
	//------------------------------------------------------- //

	nSC5Recno	:= (cQrySC5)->SC5_RECNO
	SC5->(dbGoTo( nSC5Recno ) )
	cSC5NumPed 	:= SC5->C5_NUM

Return
******

/** {Protheus.doc} 7
Função de gatilho executada na mudança do tipo de paridade
força a limpesa do Grid,  pois os calcs. são completamente
entre o Calc. Paridade por Valor e Por UM.

@param: 	Nil
@return:	Grid Inicializado, NKT_UMPAR Inicializada
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fMudaTpPar()
	Local oView			:= FwViewActive()
	Local oModel    		:= FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO    	:= oModel:GetModel("NKOGRID")

	//Inicializo os campos de Um, de Paridade e Tbem de tabela praticada
	oModeLNKT:LoadValue("NKT_UMPAR", 	' '	)
	oModelNkt:LoadValue("NKT_TBPRAT", ' '	) // Qto for por paridade por UM, não pode ser informado tabela de preços;

	//Inicializo o Grid
	oModelNKO:ClearData()
    If !IsBlind()
    	Oview:Refresh()
    EndIf
Return ( )


/** {Protheus.doc} 7
Função de gatilho executado, no cpo NKT_UMPAR,
apos inserir um dado desabilito o cpo. e não deixo
o mesmo mais ser alterado.

@param: 	Nil
@return:	Cpo NKT_UMPAR, desabilitado na tela
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fDisNktUmp()
	Local oView			:= FwViewActive()
	Local oModel    	:= FWModelActive()

	// força o when para qdo for alterar para n. permitir o cpo ter seu vr. mudado apos preencher
	oModEl:GetModel("NKTUNICO"):GetStruct():SetProperty( 'NKT_UMPAR' , MODEL_FIELD_WHEN, {||ALTERA} )
	If !IsBlind()
		oView:Refresh('VIEW_NKT')
    EndIf
Return( nil )

/** {Protheus.doc} 7
Função de gatilho executado, no cpo NKO_PARIUM , NKT_VRVNDP
Qdo o tipo de paridade for 2 (Por Unidade de Medida ),
a mesma encontra o vr dos itens de forma automatica

@param: 	(*) Varre Todas as linhas do Grid
@return:	O cpo NKO_PRCVEN é Atualizado;
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fCalcVrUni( cFlag )

	//Var. do Modelo
	Local oModel    	:= FWModelActive()
	Local oModeLNKT		:= oModel:GetModel("NKTUNICO")
	Local oModelNKO    	:= oModel:GetModel("NKOGRID")
	/*
	1o)	Nesse momento tenho todas as Un.Medidas envolvidas no calculo
	UM de preço do Produto de Venda, UM. de preço do Produto que Irei receber, e Um. em que o Acordo de troca será realizado
	2o)	Tbem tenho garantido que todas possuem um fator de conversão entre si.
	*/
	Local cNktUmPar		:= oModelNKT:GetValue("NKT_UMPAR")	// Unidade de medida de Paridade do acordo de Troca
	Local cCpraUmPrc	:= NJR->NJR_UMPRC					// Unidade de Medida do Item do Contrato de Compra (Utilizamos a UM. de preco)
	Local cB1UmPrc		:= ''								// Unidade de Medida do Produto de venda

	Local nPrdpar		:= 0								// Qt. Paridade informada
	Local nNktVrVndP	:= oModelNKT:GetValue("NKT_VRVNDP")	// Qt. Paridade informada

	//Variaveis Auxiliares
	Local nParUmTrc		:= 0 //Contem o Vr. de paridade na Um do Prod. Ctrato.
	Local nX			:= 0
	Local aSaveLines    := FWSaveRows()

	//Valores Default
	Default cFlag = ''

	/*
	<<< Forma do calculo >>>
	Apos informa a Qtidade de paridade:
	1) Tenho q encontrar o fator de conversão da Unidade de medida de preço do produto de TRoca
	que esta no Ctrato de Compra (OGA280), para a Unidade de troca ( NKO_UMPAR )
	2) Tenho q encontrar o fator de conversão da Unidade de medida de preço do produto que está
	sendo vendido, para a Unidade de troca ( NKO_UMPAR )
	(Atençao foi utilizado UMPrc, Para os Itens de venda pq a SG não quis separa as uns, SC para S6(SC 60 KGS),S4(sc 40kgs ) )
	3) De acordo com a paridade infornada (NKO_PARIUM) encontro qto devo receber do produto que
	está no contrato de compra, para kda item vendido;
	Ex: Vamos considerar
	A)	(S6) =  Sacas de 60 kgs
	B)	(S4) =  Sacas de 40 Kgs
	C)	Produto  001 Soja Comercial, Ctrato de compra nr 433 (UmPrc) = S6   	-> ( Produto a receber em troca)
	D)	Produto  788 Sem Soja categ 786 (UmPrc) = S4								-> ( Produto Sendo Vendidor		)
	E)	NKT_VRVNDP = 70,00															->	Vr. de Venda Futura do Prod. 001
	F)	Paridade (NKO_PARIUM) = 3 (Para kda KG do Prod 788 eu tenho q receber 3 do Produto 001
	G)	Tenho ( 3  x 40 / 60 ) = 2
	3 = Paridade em qtd 																			(G1)
	40 = Fator conversao de Ums do prod. venda 	para a Um do acordo de trocas 			(G2)
	60 = Fator conversao de Ums do prod. em Troca	para a Um do acordo de trocas 			(G3)
	2 = Vr. do unitario do produto de venda na Unidade de medida do acordo de Trocas 	(G4)
	(nesse momento Tenho agora o Vr Unitario em Paridade por UM para o item de venda 788 )
	H)	Preciso encontrar o Vr Unitario em (Moeda 1)R$ do item q está sendo vendido
	Então temos 2 x 70 = 140,00 Vr em R$ ( Moeda 1) do Produto
	Apos preencher o Vr unitario, o Sistema dispara gatilhos Calculando o Indice de Paridade baseado em Vrs
	Pegando 140 / 70 ( Desta Forma Mantive a Logica que já Havia sido desenvolvida Basenado em paridade encontrada por Vr)
	Esse Calc Garante q baixarei a qtd Vendida e terei Gerado o Tit. em OM ( Outra Moeda como a Sem.Goias ) Deseja )
	*/

	// Encontra o Fator de Conversão da UM. do Produto de Troca para UM. do acordo de Troca
	nFatProdTrc 	:= AGRX001( cCpraUmPrc ,cNktUmPar, 1, NJR->NJR_CODPRO )			//	(G3)

	For nX := 1 to oModelNKO:Length()
		IIF (cFlag == '*', oModelNKO:GoLine( nX ),nIl ) //(cFlag *) == Todas Linha do Grid; (cFlag Vazio()) Somente Linha Posicionada ;
		//Encontra o Fator de Conversão da UM. de Preco do Produto de Venda para UM. do acordo de Troca
		cB1UmPrc		:= POSICIONE("SB5",1,fWxFilial("SB5")+ oModelNKO:GetValue("NKO_CODPRO") ,"B5_UMPRC")
		nPrdpar			:= oModelNKO:GetValue("NKO_PARIUM")									// (G1)
		nFatProdVnd 	:= AGRX001( cB1UmPrc 	,cNktUmPar, 1 , oModelNKO:GetValue("NKO_CODPRO"))								// (G2)
		nParUmTrc		:= 	ROUND(nPrdPar * nFatProdVnd  / nFatProdTrc,oModelNKO:GetValue("NKO_IDXPAR")) 	// (G4)
		nVrUnit 		:= nParUmTrc * nNktVrVNDP												// (H )
		oModelNKO:SetValue("NKO_PRCVEN", nVrUnit )
		IF ! cFlag == '*' // Não é para fazer todos devo Sair Fora
			Exit
		EndIF
	nExt Nx

	FWRestRows(aSaveLines)

Return( nVrUnit )



/** {Protheus.doc} 7
Função verifica qual é a Qtidade empenhada de
um produto que se encontra no Grid

@param: 	Item a ser Checado
@return:	Qtidade Já empenhada
@author: 	E Coelho
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/
Static Function fGetQtdEmp( cChkItem )
	Local aAreaAtu	:= GetArea()
	Local aAreaADB	:= ADB->( GetArea() )
	Local nQtEmpen	:= 0

	ADB->( dbSetOrder( 1 ) )
	IF ADB->( dbSeek( xFilial( "ADB" ) + cAdaNumctr + cChkItem ) )
		nQtEmpen := ADB->(ADB_QTDEMP + ADB_QTDENT)
	EndIF

	RestArea( aAreaAtu )
	RestArea( aAreaADB )

Return( nQtEmpen )


/*
+=================================================================+
| Programa  : OGA300PED                                           |
| Descrição : Geração do pedido de venda                          |
| Autor     : Bruno Coelho da Silva                               |
| Data      : 11/2016                                             |
+=================================================================+
*/
Function OGA300PED(oModel)
	Local aArea	  		:= GetArea()
	Local lRet 			:= .T.
	Local nOpPed 		:= oModel:GetOperation()
	Local oModelNKO  	:= oModel:GetModel("NKOGRID")
	Local oModelNKT  	:= oModel:GetModel("NKTUNICO")	
	Local aSaveLines    := FWSaveRows()
	Local aPedido		:= {{},{}}
	Local nX
	Local nY
	Local nTot          := 0 
    Local lValid        := .T.
	
	Private lMsErroAuto	:= .F.
	Private lMSHelpAuto := .T.
	Private aCab		:= {}
	Private aItens 		:= {}
	
	nModulo := 5
	
	Begin Transaction

		IF nOpPed == MODEL_OPERATION_UPDATE .or. nOpPed == MODEL_OPERATION_DELETE
			aAdd( aPedido[1], { "C5_NUM", FWFLDGET("NKT_NUMPED"), nil } )
		Else
			aAdd(aPedido[1],{"C5_CLIENT" ,FWFLDGET("NKT_CLIENT")	,Nil})
			aAdd(aPedido[1],{"C5_LOJAENT",FWFLDGET("NKT_LOJAEN")	,Nil})	
			aAdd(aPedido[1],{"C5_TIPO"   ,"N"				        ,Nil})
			aAdd(aPedido[1],{"C5_CLIENTE",FWFLDGET("NKT_CODCLI")    ,Nil})
			aAdd(aPedido[1],{"C5_LOJACLI",FWFLDGET("NKT_LOJCLI")    ,Nil})					
		EndIF

		aAdd(aPedido[1],{"C5_CONDPAG",FWFLDGET("NKT_CONDPG")	,Nil})
		aAdd(aPedido[1],{"C5_CODSAF" ,FWFLDGET("NKT_CODSAF")    ,Nil})
		aAdd(aPedido[1],{"C5_MOEDA"   ,FWFLDGET("NKT_MOEDA")     ,Nil})
		aAdd(aPedido[1],{"C5_TABELA"  ,FWFLDGET("NKT_TBPRAT")    ,Nil})
		aAdd(aPedido[1],{"C5_DESC1"   ,FWFLDGET("NKT_DESC1")     ,Nil})
		aAdd(aPedido[1],{"C5_DESC2"   ,FWFLDGET("NKT_DESC2")     ,Nil})
		aAdd(aPedido[1],{"C5_DESC3"   ,FWFLDGET("NKT_DESC3")     ,Nil})
		aAdd(aPedido[1],{"C5_DESC4"   ,FWFLDGET("NKT_DESC4")     ,Nil})
		aAdd(aPedido[1],{"C5_TRANSP"  ,FWFLDGET("NKT_TRANSP")    ,Nil})
		aAdd(aPedido[1],{"C5_TPFRETE" ,FWFLDGET("NKT_TPFRET")    ,Nil})
		aAdd(aPedido[1],{"C5_FRETE"   ,FWFLDGET("NKT_FRETE")     ,Nil})
		aAdd(aPedido[1],{"C5_SEGURO"  ,FWFLDGET("NKT_SEGURO")    ,Nil})
		aAdd(aPedido[1],{"C5_DESPESA" ,FWFLDGET("NKT_DESPES")    ,Nil})
		aAdd(aPedido[1],{"C5_FRETAUT" ,FWFLDGET("NKT_FRETAU")    ,Nil})
		aAdd(aPedido[1],{"C5_TPCARGA" ,FWFLDGET("NKT_TPCARG")    ,Nil})
		aAdd(aPedido[1],{"C5_DESCONT" ,FWFLDGET("NKT_DESCON")    ,Nil})
		aAdd(aPedido[1],{"C5_TIPLIB"  ,FWFLDGET("NKT_TPLIB")     ,Nil})
		aAdd(aPedido[1],{"C5_PDESCAB" ,FWFLDGET("NKT_PDESCA")    ,Nil})
		aAdd(aPedido[1],{"C5_MENNOTA" ,FWFLDGET("NKT_MENNOT")    ,Nil})
		aAdd(aPedido[1],{"C5_MENPAD"  ,FWFLDGET("NKT_MENPAD")    ,Nil})
		aAdd(aPedido[1],{"C5_VEICULO" ,FWFLDGET("NKT_VEICUL")    ,Nil})
		
		If (POSICIONE("SE4",1,FWxFilial("SE4")+FWFLDGET("NKT_CONDPG"),"E4_TIPO") = "9")	
			For nY := 1 to oModelNKO:Length()
				oModelNKO:SetLine(nY)
				nTot += A410Arred(FWFLDGET("NKO_IDXPAR") * FWFLDGET("NKO_QUANT"), "C6_VALOR")
			Next nY
			aAdd(aPedido[1],{"C5_PARC1" ,nTot    ,Nil})
		Else
			aAdd(aPedido[1],{"C5_PARC1" ,FWFLDGET("NKT_PARC1")     ,Nil})
		EndIF
				
		If ! Empty(FWFLDGET("NKT_PARC2"))
			aAdd(aPedido[1],{"C5_PARC2"   ,FWFLDGET("NKT_PARC2")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_PARC3"))
			aAdd(aPedido[1],{"C5_PARC3"   ,FWFLDGET("NKT_PARC3")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_PARC4"))
			aAdd(aPedido[1],{"C5_PARC4"   ,FWFLDGET("NKT_PARC4")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_DATA1"))
			aAdd(aPedido[1],{"C5_DATA1"   ,FWFLDGET("NKT_DATA1")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_DATA2"))
			aAdd(aPedido[1],{"C5_DATA2"   ,FWFLDGET("NKT_DATA2")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_DATA3"))
			aAdd(aPedido[1],{"C5_DATA3"   ,FWFLDGET("NKT_DATA3")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_DATA4"))
			aAdd(aPedido[1],{"C5_DATA4"   ,FWFLDGET("NKT_DATA4")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_VEND1"))
			aAdd(aPedido[1],{"C5_VEND1"   ,FWFLDGET("NKT_VEND1")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_VEND2"))
			aAdd(aPedido[1],{"C5_VEND2"   ,FWFLDGET("NKT_VEND2")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_VEND3"))
			aAdd(aPedido[1],{"C5_VEND3"   ,FWFLDGET("NKT_VEND3")     ,Nil})
		EndIf
		If ! Empty(FWFLDGET("NKT_VEND4"))
			aAdd(aPedido[1],{"C5_VEND4"   ,FWFLDGET("NKT_VEND4")     ,Nil})
		EndIf
						
		If ExistSX3("C5_NATUREZ") 
			If X3Uso(posicione("SX3",2,"C5_NATUREZ","X3_USADO"))
				aAdd(aPedido[1],{"C5_NATUREZ" ,FWFLDGET("NKT_NATURE")    ,Nil})
			EndIf
		EndIf
		
		For nX := 1 to oModelNKO:Length()
			aPedido[2]	:= {}
			oModelNKO:GoLine( nX )
			aAdd(aPedido[2], {"C6_ITEM"	   ,FWFLDGET("NKO_ITEM")    ,Nil})
			aAdd(aPedido[2], {"C6_PRODUTO" ,FWFLDGET("NKO_CODPRO")	,Nil})
			aAdd(aPedido[2], {"C6_QTDVEN"  ,FWFLDGET("NKO_QUANT")	,Nil})
			aAdd(aPedido[2], {"C6_OPER"    ,FWFLDGET("NKO_OPER")    ,Nil})
			aAdd(aPedido[2], {"C6_PRCVEN"  ,FWFLDGET("NKO_IDXPAR")  ,Nil})
			aAdd(aPedido[2], {"C6_CODSAF"  ,FWFLDGET("NKT_CODSAF")	,Nil})
			aAdd(aPedido[2], {"C6_TES"     ,FWFLDGET("NKO_TES")		,Nil})
			
			//Valida se os campos de cultura, cultivar, categoria e peneira são utilizados				
			If ExistSX3("C6_CULTRA") 
				If X3Uso(posicione("SX3",2,"C6_CULTRA","X3_USADO"),67)
					aAdd(aPedido[2], {"C6_CULTRA",FWFLDGET("NKO_CULTRA")  ,Nil})
				Else 
					lValid := .F.
				Endif
			Endif
			
			If ExistSX3("C6_CTVAR") 
				If X3Uso(posicione("SX3",2,"C6_CTVAR","X3_USADO"),67)
					aAdd(aPedido[2], {"C6_CTVAR",FWFLDGET("NKO_CTVAR")   ,Nil})
				Else 
					lValid := .F.
				Endif
			Endif
			
			If ExistSX3("C6_CATEG") 
				If X3Uso(posicione("SX3",2,"C6_CATEG","X3_USADO"),67)
					aAdd(aPedido[2], {"C6_CATEG",FWFLDGET("NKO_CATEG")   ,Nil})
				Else 
					lValid := .F.
				Endif
			Endif
			
			If ExistSX3("C6_PENE") 
				If X3Uso(posicione("SX3",2,"C6_PENE","X3_USADO"),67)
					aAdd(aPedido[2], {"C6_PENE",FWFLDGET("NKO_PENE")    ,Nil})
				Else 
					lValid := .F.
				Endif
			Endif			
						
			aAdd(aPedido[2], {"C6_LOCAL"   ,FWFLDGET("NKO_LOCAL")   ,Nil})
			aAdd(aPedido[2], {"C6_CF"      ,FWFLDGET("NKO_CF")      ,Nil})
			aAdd(aPedido[2], {"C6_PRUNIT"  ,FWFLDGET("NKO_PRUNIT")  ,Nil})
			if(! Empty(FWFLDGET("NKO_LOTECT")))
			aAdd(aPedido[2], {"C6_LOTECTL" ,FWFLDGET("NKO_LOTECT")  ,Nil})
			EndIf
			aAdd(aPedido[2], {"C6_SUGENTR" ,FWFLDGET("NKO_SUGENT")  ,Nil})
			aAdd(aPedido[2], {"C6_ENTREG"  ,FWFLDGET("NKO_ENTREG")  ,Nil})
			if(! Empty(FWFLDGET("NKO_TNATRE")))
				aAdd(aPedido[2], {"C6_TNATREC"  ,FWFLDGET("NKO_TNATRE")  ,Nil})
			EndIf
			if(! Empty(FWFLDGET("NKO_CNATRE")))
				aAdd(aPedido[2], {"C6_CNATREC"  ,FWFLDGET("NKO_CNATRE")  ,Nil})
			EndIf
			if(! Empty(FWFLDGET("NKO_GRPNAT")))
				aAdd(aPedido[2], {"C6_GRPNATR"  ,FWFLDGET("NKO_GRPNAT")  ,Nil})
			EndIf
			
			//TODO Acerto para que o pedido seja alterado sem a alteração da C6.
			aAdd(aPedido[2], {"C6_MOPC"   ,TIME()                   ,Nil})
			aAdd(aItens, aPedido[2])

		Next nX

		FWRestRows(aSaveLines)
		
		If !lValid
			lRet := .F.
			oModel:GetModel():SetErrorMessage( oModelNKO:GetId(), , oModelNKO:GetId(), "", "", STR0075, STR0076, "", "")			
		Endif

		If lRet
			//PONTO DE ENTRADA DO MÓDULO SIGAAGR PARA GERAÇÃO DE PEDIDO DE VENDA A PARTIR DO ACORDO DE TROCA.
			If EXISTBLOCK ("AG300PVAC") 
				aRetPe := ExecBlock("AG300PVAC",.F.,.F.,{oModel, aPedido[1], aItens})
				
				If Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
					aPedido[1] := aRetPe[1]
					aItens := aRetPe[2]
				EndIf
			EndIf
		
			If ! Empty(aItens)			
				If !O300TpPg()
					Help(,,STR0030,,STR0065,1,0)//Atenção //Inconsistencia nos dados financeiros.
					lRet := .F.					
				Else
					RestArea(aArea)
						
					IF nOpPed == MODEL_OPERATION_DELETE

						MsAguarde({||MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aPedido[1], aItens, nOpPed)},STR0052,STR0081) //STR0052 "Aguarde...", STR0081 "Excluindo pedido de vendas..." )
					
					ElseIf Empty(oModelNKT:GetValue("NKT_NUMPED"))
						//verifica se a nota existe para indicar a operação correta
						//caso haja um problema na geração do pedido, o registro NKT fica inutilizado no metodo anterior
						nOpPed := MODEL_OPERATION_INSERT	
						MsAguarde({||MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aPedido[1], aItens, nOpPed)},STR0052,STR0053) //STR0052 "Aguarde...", STR0053 "Gerando pedido de vendas..." )
					
					Else
						nOpPed := MODEL_OPERATION_UPDATE
						MsAguarde({||MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aPedido[1], aItens, nOpPed)},STR0052,STR0080) //STR0052 "Aguarde...", STR0080 "Alterando pedido de vendas..." )
					
					Endif
				EndIf
			EndIf
	
			If lMsErroAuto .OR. Empty(aItens) .OR. !lRet
				RollBackSx8()
				DisarmTransaction()
				MostraErro()
				lRet := .F.
			Else
				ConfirmSx8()
				AGRGRAVAHIS(,,,,{"NKT", FWxFilial("NKT") + oModelNKT:GetValue("NKT_TRCNUM"), IIF(nOpPed == 4, "A", IIF( nOpPed == 5, "E", "I" )), STR0051 + " - " + SC5->C5_NUM}) //STR0051 "Pedido de Venda"
			EndIf
		EndIf	
	End Transaction
	
	nModulo := 67
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} StatusNKT
Função responsável pela atualização do status da troca.
@author brunosilva
@since 06/01/2017
@version undefined
@param cOpcao, characters, descricao
@type function
/*/
Function StatusNKT(cOpcao)

	NKT->( DbSetOrder(2) ) 
	IF (NKT->(DbSeek(fWXfilial('NKT') + NJR->NJR_CODCTR))) .AND. ! (EMPTY(NKT->NKT_NUMPED))
		RecLock("NKT", .F.)

		NKT->NKT_STATUS := cOpcao //01=Pendente, 02=Liberado, 03=Iniciado, 04=Recebido, 05 = Finalizado.

		MsUnlock()
	EndIF
Return

/*/{Protheus.doc} O300TpPg
//Responsável por gerenciar as validações de acordo com o tipo de pagamento escolhido..
@author brunosilva
@since 06/03/2017
@version undefined

@type function
/*/
Function O300TpPg()
	Local aArea := GetArea()
	Local lRet := .T.

	DbSelectArea("SE4")
	POSICIONE("SE4",1,FWxFilial("SE4")+FWFLDGET("NKT_CONDPG"),"E4_TIPO")
	If (SE4->E4_TIPO = "9")	
		lRet := O300Tipo9()
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} O300Tipo9
Função responsável pela validação da condição de pagamento do tipo 9
@author brunosilva
@since 24/02/2017
@version undefined

@type function
/*/
Function O300Tipo9()
	Local oModel       := FWModelActive()
	Local oModelCalc   := omodel:GetModel("OGA300TOTAL")
	Local nXt   := 0
	Local lRet  := .T.
	Local aArea := GetArea()
	
	If(NKT_TPPARD = "1")
		nXt := oModelCalc:GetValue("TOTMOEDA1")
	ElseIf (NKT_TPPARD = "2")
		nXt := oModelCalc:GetValue("TOTMOEDA2")
	EndIf
	 
	 /*If noRound((FWFLDGET("NKT_PARC1") + FWFLDGET("NKT_PARC2") + FWFLDGET("NKT_PARC3") + FWFLDGET("NKT_PARC4")), 2) != noRound(nXt, 2)
	 	lRet := .F.
	 Else*/
	 If(( ! Empty(FWFLDGET("NKT_PARC1"))  .AND. Empty(FWFLDGET("NKT_DATA1"))) .OR. ( ! Empty(FWFLDGET("NKT_PARC2")) .AND. Empty(FWFLDGET("NKT_DATA2")))  .OR. ( ! Empty(FWFLDGET("NKT_PARC3")) .AND. Empty(FWFLDGET("NKT_DATA3"))) .OR. ( ! Empty(FWFLDGET("NKT_PARC4")) .AND. Empty(FWFLDGET("NKT_DATA4"))))
	 	lRet := .F.
	 EndIf 
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} O300Venc
//Obriga a digitação da data de vencimento apenas quando a condição de pagamento for tipo 9
@author brunosilva
@since 01/03/2017
@version undefined

@type function
/*/
Function O300Venc()
Local cVar := &(ReadVar())
Local cAlias := Alias()
Local lRet   := .T.

dbSelectArea("SE4")
dbSetOrder(1)
If dbSeek(FWxFilial()+M->NKT_CONDPG)
    If SE4->E4_TIPO == "9"
        If DtoS(cVar) < DtoS(M->NKT_DTNEG) .And. !Empty(cVar)
            Help(,,STR0030,,STR0066,1,0)//Atenção //"Necessário informar data de vencimento."
            lRet := .F.
        Endif        
    Endif
Endif
dbSelectArea(cAlias)
Return lRet

/*/{Protheus.doc} O300Cli
//Responsável por validar se cliente possui o mesmo codigo em lojas diferentes
@author brunosilva
@since 02/03/2017
@version undefined

@type function
/*/
Function O300Cli()

Local lRetorno  := .F.
Local cLoja     :=""
Local lConPadOk := .F.
Local aArea  	:= {}
Local aArea2  := {}
Local cProxCli  := ""
Local lBloq := .F. //Variável de controle para verificar se o cliente/fornecedor + loja estiver bloqueado

Local cO300CliV	    := "M->NKT_CODCLI"
Local cO300Cli		:=&(cO300CliV)
	
dbSelectArea("SA1")
aArea	:= GetArea()
If Empty(cLoja)
	MsSeek( xFilial()+cO300Cli,.F.)
Else
	MsSeek( xFilial()+cO300Cli+cLoja,.F.)
EndIf	 
aArea2	:= GetArea()
	
dbSkip()	
cProxCli := &("SA1->A1_COD")
cProxCli := IIF(cProxCli <> cO300Cli,"",cProxcli)
	
MsSeek( xFilial()+cO300Cli+cLoja,.F.)
If (Recno() == aArea2[3]) .and. !Empty(M->NKT_LOJCLI)
	cProxCli := ""
EndIf	
	
RestArea(aArea2)
If Empty(cProxCli)
	cLoja := SA1->A1_LOJA
Else
	cLoja := Space( Len(SA2->A2_LOJA) )	
	M->NKT_LOJCLI := cLoja
EndIf	
	
RestArea(aArea)
	
If ( !Empty(cO300Cli) )
	dbSelectArea("SA1")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura por Codigo + Loja                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !MsSeek( xFilial()+cO300Cli+cLoja,.F.) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por Codigo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MsSeek( xFilial()+cO300Cli,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura pelo nome do cliente                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSetOrder(2)
			If ( !MsSeek( xFilial()+Trim(cO300Cli),.F.) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Procura pelo CGC                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSetOrder(3)
				If ( MsSeek( xFilial()+Trim(cO300Cli),.F.) )
					lRetorno := .T.
				Else
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .T.
			EndIf
			If lRetorno
				&(cO300CliV) := SA1->A1_COD
			EndIf
		Else
			lRetorno := .T.
		EndIf
	Else
		lRetorno := .T.
	EndIf
EndIf
	
If ( lRetorno )	
	If SA1->A1_MSBLQL == '1' .AND. Empty(cLoja)
		lBloq = .T.
	Else
		cLoja    := IIf(Empty(cProxcli),SA1->A1_LOJA,Space(Len(SA1->A1_LOJA)))		
	EndIf
	
	cO300Cli := SA1->A1_COD
	lConPadOk := .T.
Else
	Help(,,"Atenção",,"Loja inválida",1,0)
EndIf

	FWFldPut("NKT_CLIENT", FWFldGet("NKT_CODCLI"))
	FWFldPut("NKT_LOJAEN", FWFldGet("NKT_LOJCLI"))		 

Return ( lRetorno )



/*/{Protheus.doc}O300Loja
//Responsável por validar os dados da loja
@author brunosilva
@since 02/03/2017
@version undefined

@type function
/*/
Function O300Loja()

Local aArea		:= GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aSvArea  := {}
Local lRetorno := .T.
Local cTabela	:= ""
Local cCondPag	:= ""
Local lCondOk		:= .F. //Variavel para verificar se existe condição de Pagamento amarrada ao cliente, para filial ativa.

Local cLojaV     := ReadVar()
Local cLoja      := &(ReadVar())

	dbSelectArea("SA1")
	dbSetOrder(1)
	If ( "NKT_LOJCLI" $ cLojaV )
		If ( !MsSeek(xFilial()+M->NKT_CODCLI+cLoja,.F.) )
			Help(,,STR0030,,STR0067,1,0)//Atenção //Loja não encontrada.
			lRetorno := .F.
		Else
			lRetorno := RegistroOk("SA1")		
		EndIf
	Else
		If  ( "NKT_LOJAEN" $ cLojaV )
			If ( !MsSeek(xFilial()+IIf(!Empty(M->NKT_CLIENT),M->NKT_CLIENT,M->NKT_CODCLI)+cLoja,.F.) )
				Help(,,STR0030,,STR0068,1,0)//Atenção //Loja de entrega não encontrada.
				lRetorno := .F.
			Else
				lRetorno := RegistroOk("SA1")
			EndIf			
		EndIf
	EndIf
	
If lRetorno .And. !Empty(cLoja)
	
	If !("NKT_LOJAEN" $ cLojaV)
		If M->NKT_CODCLI == M->NKT_CLIENT 
			M->NKT_LOJAEN := SA1->A1_LOJA
		EndIf
	
		If !("NKT_LOJAEN" $ cLojaV ) .And.	!("NKT_CLIENT" $ cLojaV )
			M->NKT_LOJCLI := A1_LOJA
		Endif	
	
		If ( lRetorno )
			M->NKT_TRANSP := SA1->A1_TRANSP
			
				M->NKT_VEND1 := SA1->A1_VEND
				
			aSvArea := GetArea()
			dbSelectArea("SA3")
			SA3->(dbSetOrder(1))
			If ( !MsSeek(xFilial("SA3")+M->NKT_VEND1) ) 
				M->NKT_VEND1 := Space(TamSX3("A1_VEND")[1])
			Else
				If !RegistroOk("SA3",.F.)
					M->NKT_VEND1 := Space(TamSX3("A1_VEND")[1])
				EndIf
			EndIf
			RestArea(aSvArea)
			lCondOk := Posicione("SE4",1,XFILIAL("SE4")+SA1->A1_COND, "E4_CODIGO") == SA1->A1_COND 

			If lCondOk	
				M->NKT_CONDPG := SA1->A1_COND
			Else
				M->NKT_CONDPG :=  Space(TamSx3("C5_CONDPAG")[1])
			EndIf
	
			M->NKT_TBPRAT:= IIF(Empty(SA1->A1_TABELA),"   ",SA1->A1_TABELA)

			If Empty(M->NKT_TBPRAT) .Or. Empty(M->NKT_CONDPG)
				cTabela	:= M->NKT_TBPRAT
				cCondPag	:= M->NKT_CONDPG

				M->NKT_CONDPG	:= Iif(Empty(M->C5_CONDPAG),cCondPag,M->C5_CONDPAG)
				M->NKT_TBPRAT	:= IiF(Empty(M->NKT_TBPRAT),cTabela,M->NKT_TBPRAT)
			EndIf

			M->NKT_TPFRET := SA1->A1_TPFRET
			If !Empty(SA1->A1_DESC)
				M->NKT_DESC1  := SA1->A1_DESC
			Else
				M->NKT_DESC1  := 0
			EndIf
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !lRetorno )
	RestArea(aAreaSA1)
EndIf

RestArea(aArea)

Return(lRetorno)


/*/{Protheus.doc} O300SitTrib
//Responsável por posicionar as tabelas SB1 e SF4 no X3_VALID dos campos NKO_OPER e NKO_TES.
@author brunosilva
@since 02/03/2017
@version undefined

@type function
/*/

Function O300SitTrib()
	Local lGrade := MatGrdPrrf(FWFLDGET("NKO_CODPRO")) 

If lGrade .AND. !(FWFLDGET("NKO_CODPRO") $ SB1->B1_COD) 
	SB1->(dbgotop())
	SB1->(MsSeek(xFilial("SB1")+FWFLDGET("NKO_CODPRO"),.F.))
EndIf 

If !Empty(FWFLDGET("NKO_CODPRO")) .And. (RTrim(FWFLDGET("NKO_CODPRO")) <> RTrim(SB1->B1_COD))
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+(FWFLDGET("NKO_CODPRO"))))
EndIf
	
If !Empty(FWFLDGET("NKO_TES")) .And. (RTrim(FWFLDGET("NKO_TES")) <> RTrim(SF4->F4_CODIGO))
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+(FWFLDGET("NKO_TES"))))
EndIf

Return .T.

/*/{Protheus.doc} O300SitTrib
//Responsável por preencher a NKO_CF de acordo com a NKO_TES informada.
//Fonte baseado no MATA410A (A410MultT)
@author brunosilva
@since 27/03/2017
@version undefined

@type function
/*/
Function O300MultT(cReadVar,xConteudo,lHelp)
	Local aArea     := GetArea()
	Local oVw       := FwViewActive() 
	Local aDadosCfo := {}               
	Local nPCFO     := ascan(OVW:AVIEWS[2][3]:OBROWSE:AHEADER,{|x| x[2]='NKO_CF'}) 
	Local lCfo      := .F.    
	Local cTesVend  := SuperGetMV("MV_TESVEND",,"")
	Local cEstado   := SuperGetMv("MV_ESTADO")
	Local nX        := 0
	Local lRetorno  := .T.
	
	DEFAULT cReadVar := ReadVar()
	DEFAULT xConteudo:= &(cReadVar)
	DEFAULT lHelp    := .T.
	
	Do Case
		Case "NKO_TES" $ cReadVar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A Consultoria Tributária, por meio da Resposta à Consulta nº 268/2004, determinou a aplicação das seguintes alíquotas nas Notas Fiscais de venda emitidas pelo vendedor remetente:                                                                         ³
		//³1) no caso previsto na letra "a" (venda para SP e entrega no PR) - aplicação da alíquota interna do Estado de São Paulo, visto que a operação entre o vendedor remetente e o adquirente originário é interna;                                              ³
		//³2) no caso previsto na letra "b" (venda para o DF e entrega no PR) - aplicação da alíquota interestadual prevista para as operações com o Paraná, ou seja, 12%, visto que a circulação da mercadoria se dá entre os Estado de São Paulo e do Paraná.       ³
		//³3) no caso previsto na letra "c" (venda para o RS e entrega no SP) - aplicação da alíquota interna do Estado de São Paulo, uma vez que se considera interna a operação, quando não se comprovar a saída da mercadoria do território do Estado de São Paulo,³
		//³ conforme previsto no art. 36, § 4º do RICMS/SP                                                                                                                                                                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If cEstado == 'SP'
			If !Empty(M->NKT_CLIENT) .And. M->NKT_CLIENT <> M->NKT_CODCLI		
				For nX := 1 To Len(aCols)
		   			If Alltrim(FWFLDGET("NKO_TES")) $ Alltrim(cTesVend) .Or. SF4->F4_CODIGO $ Alltrim(cTesVend)
		 				lCfo:= .T.
		 			EndIf
		   		Next 
		   		If lCfo
					dbSelectArea("SA1")
					dbSetOrder(1)           
					MsSeek(FWxFilial()+M->NKT_CODCLI+M->NKT_LOJAEN)
					If SA1->A1_EST <> 'SP'
						MsSeek(FWxFilial()+IIf(!Empty(M->NKT_CLIENT),M->NKT_CLIENT,M->NKT_CODCLI)+M->NKT_LOJAEN) 
					Else
						For nX := 1 To Len(aCols)
		   					If Len(aCols)>1
		 				   		If cPaisLoc=="BRA"
		 							Aadd(aDadosCfo,{"OPERNF","S"})
		 							Aadd(aDadosCfo,{"TPCLIFOR",SA1->A1_TIPO})					
		 							Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
		 							Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
									If SA1->(FieldPos("A1_CONTRIB")) > 0 		 			 	
									 	Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
									EndIf	
									//aCols[nX,nPCFO] := MaFisCfo(,Iif(!Empty(aCols[nX,nPCFO]),aCols[nX,nPCFO],SF4->F4_CF),aDadosCfo)
									FwFldPut("NKO_CF",MaFisCfo(,Iif(!Empty(FWFLDGET("NKO_CF")),FWFLDGET("NKO_TES"),SF4->F4_CF),aDadosCfo))
								EndIf
		 		   			EndIf
		   				Next
					EndIf
				EndIf 
			EndIf
		 EndIF

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(FWxFilial("SF4") + fwfldget("NKO_TES"))
			 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche o CFO                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc!="BRA"
			aCols[n,nPCFO]:=AllTrim(SF4->F4_CF)
		Else             
		 	Aadd(aDadosCfo,{"OPERNF","S"})
		 	Aadd(aDadosCfo,{"TPCLIFOR",SA1->A1_TIPO})					
		 	Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
		 	Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
			If SA1->(FieldPos("A1_CONTRIB")) > 0 		 			 	
			 	Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
			EndIf
		 	Aadd(aDadosCfo,{"FRETE" ,M->NKT_TPFRETE})	
			//aCols[n,nPCFO] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			FwFldPut("NKO_CF",MaFisCfo(,SF4->F4_CF,aDadosCfo))
		EndIf
	EndCase
	
	RestArea(aArea)
Return lRetorno

/*/{Protheus.doc} O300LotCTL
//TODO Descrição auto-gerada.
@author brunosilva
@since 03/03/2017
@version undefined

@type function
/*/	
Function O300LotCTL()

Local aArea		:= GetArea()
Local aAreaF4	:= SF4->(GetArea())
Local aAreaSB8	:= {}
Local lRetorna  := .T.
Local nSaldo	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Movimenta Estoque                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
If ( MsSeek(FWxFilial("SF4")+FWFLDGET("NKO_TES")) .And. SF4->F4_ESTOQUE=="N" )
	If UPPER(ALLTRIM(Readvar())) == "M->NKO_LOTECT" .And. ! Empty(FWFLDGET("NKO_LOTECT"))
		Help(,,STR0030,,STR0069,1,0)//Atenção //O produto não movimenta estoque.
		lRetorna := .F.	
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Produto possui rastreabilidade                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorna .And. !Rastro(FWFLDGET("NKO_CODPRO")) )
	If (!Empty(&(ReadVar())))
		Help(,,STR0030,,STR0070,1,0)//Atenção //O produto não possui rastreabilidade.
		FWFLDGET("NKO_LOTECT")	:= CriaVar( "NKO_LOTECT" )
		lRetorna := .F.
	Else
		FWFLDGET("NKO_LOTECT")	:= CriaVar( "NKO_LOTECT" )
	EndIf
Else
	If ( lRetorna ) .And. (!Empty(ReadVar()))
		nSaldo := SldAtuEst(FWFLDGET("NKO_CODPRO"),FWFLDGET("NKO_LOCAL"),FWFLDGET("NKO_QUANT"),FWFLDGET("NKO_LOTECT"))
		
		If ( FWFLDGET("NKO_QUANT") > nSaldo )
			Help(,,STR0030,,STR0071,1,0)//Atenção //Quantidade liberada maior que o saldo
			lRetorna  := .F.
		EndIf
		
		If lRetorna
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso lote exista, obtem a data de validade                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaSB8 := GetArea()
			SB8->(dbSetOrder(3))
			If SB8->(dbSeek(FWxFilial("SB8") + FWFLDGET("NKO_CODPRO") + FWFLDGET("NKO_LOCAL") + FWFLDGET("NKO_LOTECT") + IIF(Rastro(FWFLDGET("NKO_CODPRO"),"S"), Replicate(" ",TamSX3("C6_NUMLOTE")[1]), "")))  
				If !(EMPTY(FWFLDGET("NKO_ENTREG"))) .AND. SB8->B8_DTVALID < FWFLDGET("NKO_ENTREG")
					If Type('lMSErroAuto') <> 'L'
						Help(,,STR0030,,STR0072,1,0)//Atenção //Data de entrega acima da data de validade do lote.
						lRetorna := .F.
					EndIf				
				EndIf			
			Endif		
			RestArea(aAreaSB8)
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada da Rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaF4)
RestArea(aArea)
Return(lRetorna)

/*/{Protheus.doc} OGA300LF4
//Consulta saldo por lote
@author brunosilva
@since 03/03/2017
@version undefined
@param cCod, characters, descricao
@param cLocal, characters, descricao
@param cCultra, characters, descricao
@param cCtvar, characters, descricao
@param cCateg, characters, descricao
@param cPene, characters, descricao
@type function
/*/
Function OGA300LF4()
	Local cLocal  := FWFLDGET("NKO_LOCAL")
	Local cCultra := FWFLDGET("NKO_CULTRA")
	Local cCtvar  := FWFLDGET("NKO_CTVAR")
	Local cCateg  := FWFLDGET("NKO_CATEG")
	Local cPene   := FWFLDGET("NKO_PENE")
	Local cCodPr  := FWFLDGET("NKO_CODPRO")
	Local nIndice,cChaveA
	Local cQuery ,cIndice := "",aIndex := {"NP9_LOTE"}
	Local nx,ny,nSaldoL,nSaldoBF
  	Local CodSaf		:= M->NKT_CODSAF
	Local aSeek := {},aColumns	:= {}
	Local lEmpPrev		:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
	Local cVar			:= ReadVar()
	Local lRastroS
	
	If Empty(cCodPr)
		Help(,,STR0030,,STR0077, 1, 0 )//  //Campo produto não preenchido.
		Return .F.
	EndIf
	
	If (cVar $ "M->NKO_LOTECT") .AND. FWFLDGET("NKO_LOCAL") != "99"
	
		lRastroS := If(Rastro(cCodPr,"S"),.t.,.f.)
	
		cQuery := " AND NP9_PROD ='"+cCodPr+"' AND NP9_CODSAF ='"+CodSaf+"' "
		cQuery += if(!empty(cCultra), "	AND NP9_CULTRA='"+cCultra+"' ","")
		cQuery += if(!empty(cCtvar), "	AND NP9_CTVAR='"+cCtvar+"' ","")
		cQuery += if(!empty(cPene), "	AND NP9_PENE 	='"+cPene+"' ","")
		cQuery += if(!empty(cCateg),"	AND NP9_CATEG='"+cCateg+"' ","")
		cQuery += if(!empty(cLocal),"	AND B8_LOCAL='"+cLocal+"' ","")
		cQuery += " AND NP9_STATUS  = '2'"
		cQuery := "% " + cQuery + " %"
	
		BeginSQL Alias "NP9TEMP"
		COLUMN B8_DTVALID AS DATE
		SELECT NP9.NP9_PROD,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_2UM,	NP9.NP9_CULTRA,
		NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SBF.BF_LOCALIZ,SB8.B8_LOCAL,SBF.BF_NUMLOTE
		FROM %Table:SB8% SB8
		INNER JOIN %table:NP9% NP9 ON NP9.%notDel%
		AND NP9.NP9_FILIAL = %xFilial:NP9%  AND  NP9.NP9_LOTE = SB8.B8_LOTECTL AND NP9.NP9_PROD = SB8.B8_PRODUTO
		LEFT JOIN %table:SBF% SBF ON
		SBF.%notDel%	AND
		SBF.BF_FILIAL = %xFilial:SBF%	AND SBF.BF_LOCAL = SB8.B8_LOCAL	AND SBF.BF_PRODUTO	= %exp:cCodPr%	AND
		SBF.BF_LOTECTL = NP9.NP9_LOTE
		WHERE
		SB8.B8_FILIAL=%xFilial:SB8% %exp:cQuery% AND SB8.%NotDel%
		EndSQL
	
		//Cria estrutura de arquivo temporario
		aCamTRB :=	{{"NP9_LOTE"},{"B8_LOCAL"},{"BF_LOCALIZ"},{"NP9_CULTRA"},{"NP9_CTVAR"},{"NP9_CATEG"},{"NP9_PENE"},{"NP9_2UM"},;
		{"B8_DTVALID"},{"B8_SALDO",TamSX3("B8_SALDO")[3],TamSX3("B8_SALDO")[1],TamSX3("B8_SALDO")[2],AGRTITULO("B8_SALDO"),PesqPict("SB8","B8_SALDO")},;
		{"BF_QUANT",TamSX3("BF_QUANT")[3],TamSX3("BF_QUANT")[1],TamSX3("BF_QUANT")[2],"Saldo Endereco",PesqPict("SBF","BF_QUANT")},;
		{"NP9_TIPLOT",TamSX3("NP9_TIPLOT")[3], TamSX3("NP9_TIPLOT")[1], TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
		{"NP9_TRATO",TamSX3("NP9_TRATO")[3], TamSX3("NP9_TRATO")[1], TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
		{"NP9_EMB",TamSX3("NP9_EMB")[3], TamSX3("NP9_EMB")[1], TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")}}
	
		aRet := AGRCRIATRB(,aCamTRB,aIndex,FunName(),.t.)
		cNomeTRB := aRet[3] //Nome do arquivo temporário
		cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
		aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
		ARGSETIFARQUI("NP9TEMP") //Carrega os dados para o arquivo temporario
		While !Eof()
			nIndice := If(lRastroS,2,3)
			cChaveA := If(lRastroS,("NP9TEMP")->BF_NUMLOTE+("NP9TEMP")->NP9_LOTE+cCodPr+("NP9TEMP")->B8_LOCAL,cCodPr+("NP9TEMP")->B8_LOCAL+("NP9TEMP")->NP9_LOTE)
			If AGRIFDBSEEK("SB8",cChaveA,nIndice,.f.)
				nSaldoL  := SB8Saldo(.F.,!Empty(("NP9TEMP")->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
				nSaldoBF := SaldoSBF(("NP9TEMP")->B8_LOCAL,("NP9TEMP")->BF_LOCALIZ,("NP9TEMP")->NP9_PROD,NIL,("NP9TEMP")->NP9_LOTE,NIL,.F.,NIL,.T.)
				If !Empty(nSaldoL)
					AGRGRAVA2T(cAliTRBL,"NP9TEMP")
					(cAliTRBL)->NP9_TRATO 	:=	AGRRETSX3BOX("NP9_TRATO"	,("NP9TEMP")->NP9_TRATO)
					(cAliTRBL)->NP9_TIPLOT 	:=	AGRRETSX3BOX("NP9_TIPLOT"	,("NP9TEMP")->NP9_TIPLOT)
					(cAliTRBL)->NP9_EMB 	:=	AGRRETSX3BOX("NP9_EMB"		,("NP9TEMP")->NP9_EMB)
					(cAliTRBL)->B8_SALDO 	:=	nSaldoL
					(cAliTRBL)->BF_QUANT	:=	nSaldoBF
				EndIf
			EndIf
			AGRDBSELSKIP("NP9TEMP")
		End
	
		For nx := 1 To Len(aIndex) // monta a estruta para index
			cIndice := aIndex[nx]
			cIndice := StrTran(cIndice," ","")
			cIndice := StrTran(cIndice,"Dtos(","")
			cIndice := StrTran(cIndice,"Descend(","")
			cIndice := StrTran(cIndice,")","")
			cDescIn := Space(1)
			vVetInT := {}
			While !Empty(cIndice)
				nPos := At("+",cIndice)
				cCam := If(nPos > 0,Alltrim(SubStr(cIndice,1,nPos-1)),Alltrim(SubStr(cIndice,1,Len(cIndice))))
				Aadd(vVetInT,cCam)
				cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
			End
			cTamInd := 0
			For ny := 1 To Len(vVetInT)
				nPos1 := Ascan(aArqTemp,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
				If nPos1 > 0
					cDescIn += Alltrim(aArqTemp[nPos1,5])+If(ny < len(vVetInT)," + ","")
					cTamInd += aArqTemp[nPos1,3]
				EndIf
			Next ny
			Aadd(aSeek,{cDescIn,{{"","C",cTamInd,0,' ',,}}})
		Next nx
	
		DEFINE MSDIALOG oDlgX TITLE "Consulta de Lote de semente" FROM 00,00 TO 500,1000 PIXEL OF oMainWnd
		DEFINE FONT oBold NAME "Arial" SIZE 0,-12 BOLD
		// Instancia o layer
		oFWL1 := FWLayer():New()
		// Inicia o Layer
		oFWL1:init( oDlgX,.F.)
		// Cria uma linha unica para o Layer
		oFWL1:addLine( 'SUP', 10 , .F.)
		oFWL1:addLine( 'INF', 90 , .F.)
		// Cria colunas
		oFWL1:addCollumn('ESQ',100,.T.,'SUP' )
		oPnlLine1 := oFWL1:getLinePanel('INF')
		oPnDir    := oFWL1:getColPanel('ESQ','SUP')
	
		@ 004,010 SAY SM0->M0_CODIGO+"/"+Alltrim(FWCodFil())+" - "+Alltrim(SM0->M0_FILIAL)+"/"+SM0->M0_NOME Of oPnDir PIXEL SIZE 245,009
		@ 014,010 SAY Alltrim(cCodPr)+ " - "+POSICIONE("SB1",1,xFilial("SB1")+cCodPr,"B1_DESC")                 Of oPnDir PIXEL SIZE 245,009 FONT oBold
	
		For nx := 1 To Len(aArqTemp)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nx]:SetData(&("{||"+aArqTemp[nx,1]+"}"))
			aColumns[nx]:SetTitle(Alltrim(aArqTemp[nx,5]))
			aColumns[nx]:SetPicture(Alltrim(aArqTemp[nx,6]))
			aColumns[nx]:SetType(Alltrim(aArqTemp[nx,2]))
			aColumns[nx]:SetSize(aArqTemp[nx,3])
			aColumns[nx]:SetReadVar(aArqTemp[nx,1])
		Next nx
	
		DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliTRBL OF oPnlLine1
		oBrowsX:SetTemporary(.T.)
		oBrowsX:SetFieldFilter(AGRITEMCBRW(aArqTemp))
		oBrowsX:SetColumns(aColumns)
		oBrowsX:SetDBFFilter(.T.)
		oBrowsX:SetUseFilter(.T.)
		oBrowsX:DisableDetails(.F.)
		oBrowsX:SetSeek(,aSeek)
		oBrowsX:SetDoubleClick(&('{||OGA300UPD()}'))
		oBrowsX:AddButton("Sair",{|| oDlgX:end()},,9,0)
		ACTIVATE FWFORMBROWSE oBrowsX
		ACTIVATE MSDIALOG oDlgX CENTER
		AGRDELETRB(cAliTRBL,cNomeTRB)
		ARGCLOSEAREA("NP9TEMP")
		
	EndIf
Return .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada da Rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaF4)
RestArea(aArea)
Return(lRetorna)

/*/{Protheus.doc} OGA300UPD
//Reponsável por atualizar a linha com o lote selecionado.
@author brunosilva
@since 03/03/2017
@version undefined

@type function
/*/
Function OGA300UPD()
	Local oModel   := FWModelActive()
	Local oGridNKO := oModel:GetModel("NKOGRID")
	Local oView	   := FWViewActive()
	oGridNKO:SetNoUpdateLine( .F. )
	If !empty((cAliTRBL)->NP9_LOTE )
		AGRLOADVALUE(oGridNKO,{{"NKO_LOTECT",(cAliTRBL)->NP9_LOTE},{"NKO_CULTRA",(cAliTRBL)->NP9_CULTRA},{"NKO_CTVAR",(cAliTRBL)->NP9_CTVAR},;
		{"NKO_CATEG",(cAliTRBL)->NP9_CATEG},{"NKO_PENE",(cAliTRBL)->NP9_PENE},{"NKO_LOCAL" ,(cAliTRBL)->B8_LOCAL}})
		oView:Refresh()
	Endif
	oDlgX:end()
Return

//Calcula o valor de venda já com o desconto.
/*/{Protheus.doc} fVndTotal
//TODO Descrição auto-gerada.
@author brunosilva
@since 16/04/2017
@version undefined

@type function
/*/
Function fVndTotal() 
	Local oModel      := FWModelActive()
	Local oModelCalc  := omodel:GetModel("OGA300TOTAL")
	Local oModelNKO   := oModel:GetModel("NKOGRID")
	Local nX        := 0
	Local TOTMOEDA1 := 0
	
	/*****************************************/
	//TODO ESTUDAR COMO MELHORAR A PERFORMACE.
	/*****************************************/
	For nX := 1 to oModelNKO:Length()
		oModelNKO:GoLine( nX )
		If .Not. oModelNKO:IsDeleted()
			TOTMOEDA1 += FWFLDGET( "NKO_TOTAL",	nX )
		EndIf
	End
	
	oModelCalc:LoadValue("TOTMOEDA1", TOTMOEDA1 )
	
Return .F.

/*/{Protheus.doc} fIdxTotal
//TODO Descrição auto-gerada.
@author brunosilva
@since 16/04/2017
@version undefined

@type function
/*/
Function fIdxTotal()
	Local oModel      := FWModelActive()
	Local oModelCalc  := omodel:GetModel("OGA300TOTAL")	
	Local oModelNKO   := oModel:GetModel("NKOGRID")
	Local nX          := 0
	Local TOTMOEDA2   := 0
	
	/*****************************************/
	//TODO ESTUDAR COMO MELHORAR A PERFORMACE.
	/*****************************************/
	For nX := 1 to oModelNKO:Length()
		oModelNKO:GoLine( nX )
		If .Not. oModelNKO:IsDeleted()
			TOTMOEDA2 += FWFLDGET( "NKO_TOTAL",	nX )
		EndIf
	End
	
	oModelCalc:LoadValue("TOTMOEDA2", TOTMOEDA2 )
Return .T.

/*/{Protheus.doc} OG300NUM
// Responsável por buscar a próxima numeração no banco. Usado no valid do campo NKT_TRCNUM
@author brunosilva
@since 30/05/2017
@version undefined

@type function
/*/
Function OG300NUM()
Local 	cNumTrc := ' '

	cNumTrc := GetSXENum('NKT','NKT_TRCNUM')
	NKT->(dbSetOrder(1))
	While NKT->(dbSeek(FWxFilial("NKT")+cNumTrc))
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cNumTrc := GetSXENum('NKT','NKT_TRCNUM')
	EndDo
	If ( __lSx8 )
		ConfirmSX8()
	EndIf

Return cNumTrc

/*/{Protheus.doc} OG300VRPR
// Validação para obrigar o preenchimento do Valor de venda prevista.
@author brunosilva
@since 03/05/2017
@version undefined

@type function
/*/
Function OG300VRPR()
	Local lRetorna := .T.
	
	If FWFLDGET("NKT_VRVNDP") = 0
		Help(,,STR0030,,STR0073, 1, 0 )//  //Favor preencher o valor de venda prevista.
		lRetorna := .F.
	EndIf

Return lRetorna
