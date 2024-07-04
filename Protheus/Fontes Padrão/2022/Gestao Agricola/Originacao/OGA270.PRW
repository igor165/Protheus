#INCLUDE "OGA270.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

Static __lnewNeg  := SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __lAutomato   := IiF(IsBlind(),.T.,.F.) //automação

/** {Protheus.doc} OGA270
Rotina para cadastro de contratos de compra, venda e ou armazenagem

@param: 	Nil
@author: 	Emerson Coelho
@since: 	01/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
@type function
*/
Function OGA270( pcCodEnt, pcLojEnt )
	Local oMBrowse := Nil
	Local cFiltroDef := "NJR_TIPO='4'" + iIf(!Empty(pcCodEnt),".AND.NJR_CODENT='"+pcCodEnt+"'","") + iIf(!Empty(pcLojEnt),".AND.NJR_LOJENT='"+pcLojEnt+"'","")
	Private _lCopyN9A := .F.
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJR" )
	oMBrowse:SetDescription( STR0001 ) //"Contratos de Deposito Em 3"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA270" ) 

	oMBrowse:AddLegend( "(NJR_MODELO=='1')"											, "WHITE"		, X3CboxDesc( "NJR_MODELO", "1" )	) //"Pré-Contrato"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='P'"	, "BLUE"		, X3CboxDesc( "NJR_STATUS", "P" )	) //"Previsto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='A'"	, "GREEN"		, X3CboxDesc( "NJR_STATUS", "A" )	) //"Aberto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='I'"	, "YELLOW"		, X3CboxDesc( "NJR_STATUS", "I" )	) //"Iniciado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='E'"	, "BR_CANCEL"	, X3CboxDesc( "NJR_STATUS", "E" )	) //"Cancelado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='F'"	, "RED"			, X3CboxDesc( "NJR_STATUS", "F" )	) //"Finalizado"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Emerson Coelho
@since: 	01/01/2015
@Uso: 		OGA270 - Contratos
*/
Static Function MenuDef()
	Local aRotina := {}
	Local aRotina1 := {}

	aAdd( aRotina1, { STR0061	, "OGA340(NJR->NJR_CODCTR)"			, 0, 4, 0, Nil } ) //"Autorizações"
	aAdd( aRotina1, { STR0062	, "OGA335(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"			, 0, 4, 0, Nil } ) //"Adic./Supres."
	aAdd( aRotina1, { STR0063	, "OGA320(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"			, 0, 4, 0, Nil } ) //"Status"
	aAdd( aRotina1, { STR0064	, "OGC003(NJR->NJR_CODCTR)"			, 0, 4, 0, Nil } ) //"Romaneios"
	aAdd( aRotina1, { STR0068 	, "OGR342(NJR->NJR_CODCTR, NJR->NJR_TIPO)" 	, 0, 4, 0, Nil } ) //"Imprimir Word"

	aAdd( aRotina, { STR0008	, "PesqBrw"        			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0009	, "ViewDef.OGA270"			, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0010   	, "ViewDef.OGA270"			, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0011   	, "ViewDef.OGA270"			, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0055	, "AGRCONHECIM('NJR')"			, 0, 4,  , .T. } ) //"Conhecimento"
	aAdd( aRotina, { STR0012	, "OGA270C"				, 0, 4, 0, Nil } ) //"Confirmar"
	aAdd( aRotina, { STR0013	, "OGA270E"				, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0014	, "OGA270F"				, 0, 4, 0, Nil } ) //"Finalizar"
	aAdd( aRotina, { STR0015	, "AGRXREABRE"				, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0016   	, "ViewDef.OGA270"			, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0017  	, "ViewDef.OGA270"			, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0071  	, "OGR340"				, 0, 8, 0, Nil } ) //"Imprimir Sintético"
	aAdd( aRotina, { STR0019    	, "ViewDef.OGA270"			, 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0059    	, "AGRXHIST"      			, 0, 7, 0, Nil } ) //"Histórico"
	aAdd( aRotina, { STR0065	, aRotina1				, 0, 4, 0, Nil } ) //"Mais ações..."
Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270 - Contratos
*/
Static Function ModelDef()
	Local oStruNJR 	:= FWFormStruct( 1, "NJR" )
	Local oStruNNY 	:= FWFormStruct( 1, "NNY" )
	Local oStruN9A  := {} 

	Local oModel 		:= MPFormModel():New( "OGA270" , {| oModel | PreModelo( oModel ) }, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) }  )
    Local bPreVal   :=  {|oFieldModel, cAction, cIDField, xValue|PreValNJR(oFieldModel, cAction, cIDField, xValue)}

	oStruNJR:RemoveField( "NJR_CLASSP" )	
	oStruNNY:RemoveField( "NNY_CODCTR" )
	
	oStruNJR:AddTrigger( "NJR_VLRBAS", "NJR_VLRTOT", { || .t. }, { |  | fGatVlrUni(  ) } )//mantido por conta do gatilho em dicionario
    oStruNJR:AddTrigger( "NJR_QTDINI", "NJR_VLRTOT", { || .t. }, { |  | fGatVlrUni(  ) } )//mantido por conta do gatilho em dicionario

	//Tratamento TES inteligente.
	oStruNJR:AddTrigger( "NJR_OPEFIS", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_CODENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 

	If __lnewNeg	
		oStruN9A := FWFormStruct( 1, "N9A" )
		oStruNJR:AddTrigger( "NJR_CODENT", "NJR_CODENT", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODENT" ) } )
		oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_LOJENT", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_LOJENT" ) } )
		oStruNJR:AddTrigger( "NJR_CODTER", "NJR_CODTER", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODTER" ) } )
		oStruNJR:AddTrigger( "NJR_LOJTER", "NJR_LOJTER", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_LOJTER" ) } )					
		oStruNJR:AddTrigger( "NJR_CODFIN", "NJR_CODFIN", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODFIN" ) } )
		oStruNJR:AddTrigger( "NJR_DESFIN", "NJR_DESFIN", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_DESFIN" ) } )        
		oStruNNY:AddTrigger( "NNY_DATINI", "NNY_DATINI", { || .T. }, { | x | fTrgNNYDAT( "NNY_DATINI" ) } )//mantido por conta do gatilho em dicionario
		oStruNNY:AddTrigger( "NNY_DATFIM", "NNY_DATFIM", { || .T. }, { | x | fTrgNNYDAT( "NNY_DATFIM" ) } )//mantido por conta do gatilho em dicionario		

		oStruN9A:AddTrigger( "N9A_OPEFIS", "N9A_TES",    { || .T. }, { | x | AGRXTESINT(.T.)}) 
		If GetRpoRelease() <= "12.1.027"
			oStruN9A:SetProperty("N9A_CODENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODENT' ) } )	
			oStruN9A:SetProperty("N9A_LOJENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_LOJENT' ) } )	
			oStruN9A:SetProperty("N9A_CODFIN", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODFIN' ) } )	
			oStruN9A:SetProperty("N9A_TIPCLI", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_TIPCLI' ) } )	
		EndIf

		oStruNJR:SetProperty("NJR_TESEST", MODEL_FIELD_OBRIGAT, .F.)//não obrigatorio
		
	EndIf 

	oModel:SetDescription( STR0021 ) //"Contrato de Deposito Em 3"

	oModel:AddFields( "NJRUNICO", /*cOwner*/, oStruNJR,bPreVal , {| oField | AGRXPOSNJR( oField ) } /*bPost*/, /*bLoad */   )

	oModel:GetModel( "NJRUNICO" ):SetDescription( STR0022 ) //"Dados do Contrato"
	//--<< Campos que nao devem copiar no processo de copia >>--
	cFldsNCopy :=''
	cFldsNCopy += "NJR_CODCTR,NJR_ULTALT,NJR_DATA,NJR_CODRPC,NJR_AUTENT,NJR_AUTSAI,NJR_QTEFCO,NJR_QTEFIS,NJR_VLEFIS,"
	cFldsNCopy += "NJR_QTSEMB,NJR_QTSFCO,NJR_QTSFIS,NJR_VLSFIS,NJR_QSLEMB,NJR_QSLFCO,NJR_SLDFIS,NJR_SLDTO,NJR_QTDRES,"
	cFldsNCopy += "NJR_QTDQUE,NJR_VLRUNI,NJR_VLRTOT,NJR_TRANSF,NJR_MODELO,NJR_MODBAS,NJR_STSASS,NJR_STSFIS,NJR_STSFIN,"
	cFldsNCopy += "NJR_STSEST,NJR_STATUS,NJR_VLRBAS,NJR_QTDINI,NJR_QTDCTR,NJR_MODAL,NJR_INSCPO"
	aFldNCopy  := Separa(cFldsNCopy,',' )
	oModel:GetModel( "NJRUNICO" ):SetFldNoCopy( aFldNcopy ) // Na função Copiar nao copia os campos de retornados em array

	oModel:AddGrid( "NNYUNICO", "NJRUNICO", oStruNNY, { | oGrid, nLine, cAction,cField,xVrNovo,xVrAnt| PREVALNNY( oGrid, nLine, cAction,cField,xVrNovo,xVrAnt ) } , , , { | oGrid | AGRXPOSNNY( oGrid ) } , {|oGrid, lCopy| AGRXLICOPY(oGrid, lCopy)} )
	oModel:GetModel( "NNYUNICO" ):SetDescription( STR0023 ) //"Dados do Intervalo de Cadência"
	oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )
	oModel:GetModel( "NNYUNICO" ):SetOptional( .t. )

	If __lnewNeg //Se utiliza as regras de negócio, copia as previsões de entrega e regras fiscais na função de cópia.
		cFldsNCopy :=''
		cFldsNCopy += "NNY_QTDINT"
		aFldNCopy  := Separa(cFldsNCopy,',' )
		oModel:GetModel( "NNYUNICO" ):SetFldNoCopy( aFldNcopy ) // Na função Copiar nao copia os campos de retornados em array
	else
		oModel:GetModel( "NNYUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNYUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array
	endIf

	oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NJR_CODCTR" } }, NNY->( IndexKey( 1 ) ) )

	If __lnewNeg	 
		//Regras Fiscais
		oStruN9A:SetProperty('N9A_CODCTR', MODEL_FIELD_OBRIGAT, .F.)

		oModel:AddGrid( "N9AUNICO", "NNYUNICO", oStruN9A, , , , { | oMDGrid | AGRXVALN9A( oMDGrid )} )
		oModel:GetModel( "N9AUNICO" ):SetUniqueLine( {"N9A_ITEM","N9A_SEQPRI" } )
		oModel:GetModel( "N9AUNICO" ):SetOptional( .T. )
		
		//Se utiliza as regras de negócio, copia as previsões de entrega e regras fiscais na função de cópia.
		cFldsNCopy :=''
		cFldsNCopy += "N9A_QUANT, N9A_QTDINS, N9A_SDOINS, N9A_QTDNF, N9A_SDONF"
		aFldNCopy  := Separa(cFldsNCopy,',' )
		oModel:GetModel( "N9AUNICO" ):SetFldNoCopy( aFldNcopy ) // Na função Copiar nao copia os campos de retornados em array

		oModel:SetRelation( "N9AUNICO", { { "N9A_FILIAL", "xFilial( 'N9A' )" }, { "N9A_CODCTR", "NJR_CODCTR" }, { "N9A_ITEM", "NNY_ITEM" } }, N9A->( IndexKey( 1 ) ) )

	EndIF

	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
Funcao AGRColPos no fonte AGRUTIL01 

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270 - Contratos
*/
Static Function ViewDef()
	Local oStruNJR	:= FWFormStruct( 2, "NJR" )
	Local oStruNNY	:= FWFormStruct( 2, "NNY" )
	Local oStruN9A  := nil 

	Local oModel	:= FWLoadModel( "OGA270" )
	Local oView	    := FWFormView():New()

	oStruNJR:RemoveField("NJR_MOEDAF")
	oStruNJR:RemoveField("NJR_TIPO"  )
	oStruNJR:RemoveField("NJR_CLASSP")
	oStruNJR:RemoveField("NJR_CLASSQ")	
	oStruNJR:RemoveField("NJR_QTDQUE")
	oStruNJR:RemoveField("NJR_CODTSE")
	oStruNJR:RemoveField("NJR_DESTSE")
	oStruNJR:RemoveField("NJR_TESQTE")
	oStruNJR:RemoveField("NJR_TESRSI")
	oStruNJR:RemoveField("NJR_DIASF" )	
	oStruNJR:RemoveField("NJR_MOEDAR")
	oStruNJR:RemoveField("NJR_DIASR" )
	oStruNJR:RemoveField("NJR_OPERAC")
	oStruNJR:RemoveField("NJR_UM2PRO")
	oStruNJR:RemoveField("NJR_QTDUM2")	
	oStruNJR:RemoveField("NJR_CONDPG")
	oStruNJR:RemoveField("NJR_DIASPG")
	oStruNJR:RemoveField("NJR_DESPG" )
	oStruNJR:RemoveField("NJR_HVIUM" )
	oStruNJR:RemoveField("NJR_TIPUM" )
	oStruNJR:RemoveField("NJR_HVICAL")
	oStruNJR:RemoveField("NJR_OUTUM" )
	oStruNJR:RemoveField("NJR_HVIFAT")
	oStruNJR:RemoveField("NJR_OUTCAL")
	oStruNJR:RemoveField("NJR_TIPCAL")
	oStruNJR:RemoveField("NJR_OUTFAT")
	oStruNJR:RemoveField("NJR_HVITOL")
	oStruNJR:RemoveField("NJR_QAPADR")
	oStruNJR:RemoveField("NJR_TIPACE")
	oStruNJR:RemoveField("NJR_TISEVO")
	oStruNJR:RemoveField("NJR_HVIREG")
	oStruNJR:RemoveField("NJR_TIPFAT")
	oStruNJR:RemoveField("NJR_TPSEVO")
	oStruNJR:RemoveField("NJR_CODNGC")
	oStruNJR:RemoveField("NJR_VERSAO")
	oStruNJR:RemoveField("NJR_BOLSA" )
	oStruNJR:RemoveField("NJR_DBOLSA")
	oStruNJR:RemoveField("NJR_CODEMB")
	oStruNJR:RemoveField("NJR_DESEMB")		
	oStruNJR:RemoveField("NJR_OPETRI")
	oStruNJR:RemoveField("NJR_OPEFUT")
	oStruNJR:RemoveField("NJR_TESFIN")
	oStruNJR:RemoveField("NJR_TIPFIX")
	oStruNJR:RemoveField("NJR_RESFIX")
	oStruNJR:RemoveField("NJR_CHKFIX")
	oStruNJR:RemoveField("NJR_DATREF")
	oStruNJR:RemoveField("NJR_TIPALG")
	oStruNJR:RemoveField("NJR_TKPFIS")	
	oStruNJR:RemoveField("NJR_TIPMER")	
	oStruNJR:RemoveField("NJR_CONDPA")
	oStruNJR:RemoveField("NJR_DESCPA")	
	oStruNJR:RemoveField("NJR_VIA"   )
	oStruNJR:RemoveField("NJR_DESVIA")	
	oStruNJR:RemoveField("NJR_INCOTE")
	oStruNJR:RemoveField("NJR_DESINC")
	oStruNJR:RemoveField("NJR_CODREM")
	oStruNJR:RemoveField("NJR_DESREM")
	oStruNJR:RemoveField("NJR_CLASSF")

	oStruNJR:RemoveField("NJR_DESMOR")
	oStruNJR:RemoveField("NJR_DESMOF")
	oStruNJR:RemoveField("NJR_TOTNN7")
	oStruNJR:RemoveField("NJR_TOTN9G")
	oStruNJR:RemoveField("NJR_BCOPRV")
	oStruNJR:RemoveField("NJR_AGGPRV")
	oStruNJR:RemoveField("NJR_CTAPRV")
	oStruNJR:RemoveField("NJR_TOTN9K")
	oStruNJR:RemoveField("NJR_TOTARB")
	oStruNJR:RemoveField("NJR_STSMIN")
	oStruNJR:RemoveField("NJR_PROMIN")
	oStruNJR:RemoveField("NJR_CONPES")

	oStruNNY:RemoveField("NNY_CODCTR")
	oStruNNY:RemoveField("NNY_VMESAN")
	oStruNNY:RemoveField("NNY_MESANO")
	oStruNNY:RemoveField("NNY_IDXCTF")
	oStruNNY:RemoveField("NNY_MEMBAR")
	oStruNNY:RemoveField("NNY_IDXNEG")
	oStruNNY:RemoveField("NNY_MESBOL")	
	oStruNNY:RemoveField("NNY_DTLFIX")
	oStruNNY:RemoveField("NNY_DTLTKP")
	oStruNNY:RemoveField("NNY_TKPQTD")
	oStruNNY:RemoveField("NNY_QTDCTR")

	If __lnewNeg
		oStruN9A  := FWFormStruct( 2, "N9A" , { |x| !ALLTRIM(x) $ 'N9A_CODCTR,N9A_ITEM'})

		oStruN9A:RemoveField("N9A_CODROM")
		oStruN9A:RemoveField("N9A_OPEFUT")
		oStruN9A:RemoveField("N9A_OPETRI")
		oStruN9A:RemoveField("N9A_TESAUX")
		oStruN9A:RemoveField("N9A_QTDTKP")
		oStruN9A:RemoveField("N9A_DTLTKP")
		oStruN9A:RemoveField("N9A_TAKEUP")
		oStruN9A:RemoveField("N9A_STAPRE")
		oStruN9A:RemoveField("N9A_DESCTR")
		oStruN9A:RemoveField("N9A_TIPMER")
		oStruN9A:RemoveField("N9A_TIPCTR")
		oStruN9A:RemoveField("N9A_DESOPF")
		oStruN9A:RemoveField("N9A_CODPRO")
		oStruN9A:RemoveField("N9A_DESPRO")
		oStruN9A:RemoveField("N9A_UNIPRO")		
		oStruN9A:RemoveField("N9A_INCOTE")
		oStruN9A:RemoveField("N9A_CONDPA")
		oStruN9A:RemoveField("N9A_DESCPA")
		oStruN9A:RemoveField("N9A_CONDPG")
		oStruN9A:RemoveField("N9A_DESPG" )	
		oStruN9A:RemoveField("N9A_CTREXT")
		oStruN9A:RemoveField("N9A_QTNFPV")
		oStruNJR:RemoveField("NJR_OPEFIS")
		oStruNJR:RemoveField("NJR_TESEST")		

	Else
		oStruNJR:RemoveField("NJR_CTREXT")
		oStruNJR:RemoveField("NJR_TIPOCL")
		oStruNJR:RemoveField("NJR_CODFIN")
		oStruNJR:RemoveField("NJR_DESFIN")
		oStruNJR:RemoveField("NJR_CLVL")
		oStruNJR:RemoveField("NJR_GENMOD")
		
		oStruNNY:RemoveField("NNY_FILORG")		
		oStruNNY:RemoveField("NNY_FILDES")	
		oStruNNY:RemoveField("NNY_MESEMB")	
		
	EndIf

	AGRXSTPROP(oStruNJR, "NJR_VLRUNI" , MVC_VIEW_CANCHANGE , .F.) // Verifica se o campo existe na estrutura antes de adicionar a view
	oStruNJR:SetProperty( "NJR_QTDINI" 	, MVC_VIEW_CANCHANGE, .F.)
	//view master
	oView:SetModel( oModel )

	If __lnewNeg //se esta configurado parametro para usar registro de negocio
		//cria a pasta principal
		oView:CreateFolder( "CTRFOLDER")

		//abas folder contrato
		oView:AddSheet('CTRFOLDER', 'PRINCIPAL' , "Principal") // Principal
		oView:AddSheet('CTRFOLDER', 'ENTREGAS'  , "Entregas") // Cadência

		//view master
		oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO")
		oView:CreateHorizontalBox( "BOX-PRIN" , 100, , , "CTRFOLDER", "PRINCIPAL" )
		oView:SetOwnerView( "VIEW_NJR", "BOX-PRIN" )
		oView:EnableTitleView( "VIEW_NJR" )	

		//--  Adicionando Grupos na view  - adicionar em RUP?    --//
		oStruNJR:AddGroup( 'GRUPOA', ''     , '', 1 )
		oStruNJR:AddGroup( 'GRUPOB', Chr(09), '', 2 )   
		oStruNJR:AddGroup( 'GRUPOC', Chr(09), '', 3 )
		oStruNJR:AddGroup( 'GRUPOD', Chr(09), '', 4 )
		oStruNJR:AddGroup( 'GRUPOE', ''     , '', 5 )

		//view cadência
		oView:AddGrid( "VIEW_NNY", oStruNNY,  "NNYUNICO")
		oView:AddGrid( "VIEW_N9A", oStruN9A, "N9AUNICO")

		oView:CreateHorizontalBox( "BOX-TOP-ENT" , 50, , , "CTRFOLDER", "ENTREGAS" )
		oView:CreateHorizontalBox( "BOX-BOT-ENT" , 50, , , "CTRFOLDER", "ENTREGAS" )
		oView:SetOwnerView( "VIEW_NNY", "BOX-TOP-ENT" )
		oView:SetOwnerView( "VIEW_N9A", "BOX-BOT-ENT" )
		oView:EnableTitleView( "VIEW_NNY") 
		oView:EnableTitleView( "VIEW_N9A") 
		oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM"   )
		oView:AddIncrementField( "VIEW_N9A", "N9A_SEQPRI" )

	Else
		
		oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO" )
		oView:AddGrid( "VIEW_NNY", oStruNNY,  "NNYUNICO")
		oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )

		oView:CreateHorizontalBox( "SUPERIOR" , 60 )
		oView:CreateHorizontalBox( "INFERIOR" , 40 )

		oView:CreateFolder( "GRADES", "INFERIOR")
		oView:AddSheet( "GRADES", "PASTA01", STR0025) //"Cadência"

		oView:CreateHorizontalBox( "PASTA_NNY", 100, , , "GRADES", "PASTA01" )

		oView:SetOwnerView( "VIEW_NJR", "SUPERIOR" )
		oView:SetOwnerView( "VIEW_NNY", "PASTA_NNY" )

		oView:EnableTitleView( "VIEW_NJR" )
		oView:EnableTitleView( "VIEW_NNY" )

	EndIf

	oView:AddUserButton( STR0064 ,'', {|| OGC003( oView:GetModel("NJRUNICO"):GetValue("NJR_CODCTR") ) } )  //"Romaneios"

	oView:SetCloseOnOk( {||.t.} )

Return( oView )


/** {Protheus.doc} OG270VDTB
Função que valida o campo da tabela de descontos utilizada no contrato

@param: 	oFields - Field da tabela NJ0
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270 - Contratos
*/
Function OG270VDTB(oModelNJR,cTabela,cCodPro)
	Local aAreaAtu 	:= GetArea()
	Local lRetorno 	:= .T.
	Local oModel    := FWModelActive()
	Local cGrupo	:= ""

	dbSelectArea( "NNI" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NNI" ) + cTabela )	.AND. .NOT. AGRTPALGOD(cCodPro)
		//para o campo de cod. do produto preenchido
		If !Empty(NNI->( NNI_CODPRO ))
			If NNI->( NNI_CODPRO ) <> cCodPro
				If !Empty(cCodPro)
					Help( , , STR0026, , STR0027, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada para este produto."
					lRetorno := .f.
				ElseIf Empty(cCodPro)
					Help( , , STR0026, , STR0067, 1, 0 ) //"AJUDA"###"Informar produto compatível com a tabela selecionada."
					lRetorno := .f.
					Return( lRetorno )
				EndIf
			Else
				If ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
					Help( , , STR0026, , STR0028, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
					lRetorno := .f.
				EndIf
			EndIf
			//para o campo de cod. do produto vazio
		ElseIf Empty(NNI->( NNI_CODPRO ))
			//verifica na tabela de produto pelo grupo se o grupo é existente
			//se grupo não existir apresenta mensagem para informar o grupo
			If AGRIFDBSEEK("SB1",cCodPro,1,.F.)
				cGrupo := SB1->( B1_GRUPO )
				If NNI->( NNI_PRODGR ) <> cGrupo
					Help( , , STR0026, , STR0066, 1, 0 ) //"Produto não faz parte do grupo da tabela selecionada. Informar produto compatível com a tabela selecionada."##"AJUDA"
					lRetorno := .F.
				ElseIf ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
					Help( , , STR0026, , STR0028, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
					lRetorno := .f.
				EndIf
			Else
				//se produto for vazio, não permitir tabela
				If Empty(cCodPro)
					Help( , , STR0026, , STR0067, 1, 0 ) //"AJUDA"###"Informar produto compatível com a tabela selecionada."
					lRetorno := .f.
					Return( lRetorno )
				EndIf
			EndIf
		EndIf
	ElseIf .NOT. AGRTPALGOD(cCodPro)
		Help( , , STR0026, , STR0029, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada."
		lRetorno := .f.
	EndIf

	RestArea (AAreaAtu )
Return( lRetorno )

/** {Protheus.doc} PosGride
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo
Funcao AGRColPos no fonte AGRUTIL01 

@param: 	oGride - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	08/06/2010   - Refeito 07/07/2016  Inácio Luiz Kolling
@Uso: 		OGA270 - Contratos
*/
Static Function PosGride( oGride )
	Local oModel	  := FwModelActive()
	Local nQtdTot  := oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" )
	Local nSomaTot := AGRSOMACOLSM(oGride,{"NNY_QTDINT"})
	Local nLinha   := 0
	Local nX       := 0

	If oModel:GetValue("NJRUNICO","NJR_MODELO")  == "3" .And. Empty(nSomaTot)
		Return .t.
	EndIf
	If nQtdTot <> nSomaTot
		Help(,,STR0026,,STR0030,1,0) //"AJUDA"###"A soma da quantidade nos itens de Cadência do Contrato esta divergente do Contrato!"
		Return .f.
	EndIf

	If AGRColPos('NNY_DTLTKP') .AND. AGRColPos('NNY_DTLFIX')   
		/*Validação de datas*/
		nLinha := oGride:GetLine()
		For nX := 1 to oGride:Length()
			oGride:GoLine( nX )

			if .not. OGA290VTKP( oGride:GetValue('NNY_DTLTKP'),  oGride:GetValue('NNY_DATINI'), "NNY_DTLTKP")
				Return .f.
			endif

			if .not. OGA290VTKP( oGride:GetValue('NNY_DTLFIX'),  oGride:GetValue('NNY_DATINI'), "NNY_DTLFIX")
				Return .f.
			endif
		Next nX
		oGride:GoLine( nLinha )
	EndIf
Return .t.

/** {Protheus.doc} IniModelo
Função que valida a inicialização do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270 - Contratos
*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno 	:= .t.
	Local nQtdPre 	:= NJR->( NJR_AUTENT ) + NJR->( NJR_AUTSAI )

	// Validação de assinatura do ctrato
	IF nOperation == MODEL_OPERATION_UPDATE
		If NJR->NJR_STSASS == 'F'
			Help( ,, STR0034,, STR0056, 1, 0 )  //"AJUDA"###"Não é possivel excluir este contrato, pois ja foi confirmado ou esta em execução. Este contrato somente pode ser -Finalizado- ou - Encerrado-."
			lRetorno := .f.
		EndIF
	EndIF

	If nOperation == MODEL_OPERATION_DELETE
		If NJR->( NJR_STATUS ) <> "P" .Or. nQtdPre > 0
			Help( ,, STR0026,, STR0031, 1, 0 ) //"AJUDA"###"Não é possivel excluir este contrato, pois ja foi confirmado ou esta em execução. Este contrato somente pode ser -Finalizado- ou - Cancelado-."
			lRetorno := .f.
		EndIf
	EndIf

	_lCopyN9A := .F.

Return( lRetorno )


/** {Protheus.doc} PreModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270
*/
Static Function PreModelo( oModel )
	Local lRetorno		:= .t.
	Local nOperation	:= oModel:GetOperation()
	Local cStatus		:= oModel:GetValue( "NJRUNICO", "NJR_STATUS" )

	If nOperation == MODEL_OPERATION_UPDATE

		If cStatus $ "F|E"
			Help( , , STR0026, , STR0032, 1, 0 ) //"AJUDA"###"Contrato ja foi Finalizado ou Cancelado! não pode ser alterado."
			lRetorno := .f.
		EndIf

	EndIf
	
	If __lnewNeg	
		fN9ACopy()
	EndIf

Return( lRetorno )


/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270
*/
Static Function PosModelo( oModel )
	Local lContinua		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cCodEnt		:= oModel:GetValue( "NJRUNICO", "NJR_CODENT" )
	Local cLojEnt		:= oModel:GetValue( "NJRUNICO", "NJR_LOJENT" )
	Local cTipo			:= oModel:GetValue( "NJRUNICO", "NJR_TIPO" )
	Local cSafra		:= oModel:GetValue( "NJRUNICO", "NJR_CODSAF" )
	Local cProd			:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )

	If !AGRXPOSNNY(oModel:GetModel( "NNYUNICO" ))
		Return .F.
	EndIf
	
	If __lnewNeg .and. !AGRXNNYNN9(oModel) //valida nos registros das previsões de entrega com as regras fiscais as quantidades
		Return .F.
	EndIf

	If nOperation == MODEL_OPERATION_INSERT 
		//Função para não permitir dois contratos com a mesma entidade e safra [OGA390]
		lContinua := OGA390B(xFilial("NJR"), cCodEnt, cLojEnt, cSafra, cProd, cTipo)		
	EndIf

	If lContinua .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
		//Função para validar entidade 
		lContinua := AGRXVALENT("C",cCodEnt, cLojEnt)

		If lContinua .And. !OGA260CADEN(oModel)
			Return .F.
		EndIf
	EndIf	

Return( lContinua )


/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA270 - Contratos
*/
Static Function GrvModelo( oModel )
	Local nOperation  := oModel:GetOperation()
	Local cModelo     := oModel:GetValue( "NJRUNICO", "NJR_MODELO" )
	Local oModelNJR   := oModel:GetModel( "NJRUNICO" )	

	// Gravar Histórico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"3",STR0010}) //Incluir				
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"4",STR0011}) //Alterar 
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"5",STR0016}) //Excluir
	Endif

	IF nOperation == MODEL_OPERATION_INSERT .Or. ( nOperation == MODEL_OPERATION_UPDATE .And. oModelNJR:Getvalue('NJR_STATUS')=='P' )

		oModelNJR:LOADVALUE('NJR_QSLFCO', ( oModelNJR:Getvalue('NJR_QTSFCO') - oModelNJR:Getvalue('NJR_QTEFCO') ))
		oModelNJR:LOADVALUE('NJR_SLDFIS', ( oModelNJR:Getvalue('NJR_QTSFIS') - oModelNJR:Getvalue('NJR_QTEFIS') ))
			
	EndIF

	If nOperation == MODEL_OPERATION_UPDATE
		If cModelo == "1"
			oModel:SetValue( "NJRUNICO", "NJR_MODELO", "2" )
		EndIf
		If cModelo == "2"
			oModel:SetValue( "NJRUNICO", "NJR_STATUS", "P" )
		EndIf

	EndIf

	If __lnewNeg .AND. nOperation != MODEL_OPERATION_DELETE
		// Alteração dos campos Produto, Tipo de Contrato, Tipo de Mercado e Contrato Externo nas regras fiscais
		// Este campos foram criados como tipo "Real", pois serão mostrados no Painel de Cadências (OGA530)
		AGRXCADGRV(oModel)  	
	EndIf

	lRet := FWFormCommit( oModel )

Return( .t. )


/** {Protheus.doc} OGA270C
Rotina para que confirmação do contrato para que o mesmo possa ser utilizado

@param: 	Nil
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA270C( cAlias, nReg, nAcao )
	Local aAreaAtu		:= GetArea()
	Local cStatus		:= "A"
	Local cNewCtr		:= Space( TamSX3( "NJR_CODRPC" )[1] )
	Local nRegNJR		:= NJR->( Recno() )
	Local nX			:= 0
	Local lRetorno      := .T.
	Local lErro	        := .F.
	
	If Empty(NJR->NJR_CODIDX) .And. NJR->NJR_VLRBAS == 0
		Help( ,,STR0026,, STR0079, 1, 0 ) //"AJUDA"###"Valor base ou Índice devem ser preenchidos."	
		return .F.
	Endif 
		
	lRet := .F.
	
	//Não permite confirmar o contrato caso os campos TES,Finalidade,Entidade de faturamento ou se operação futura ou triagular, validar se TES auxiliar foi preenchida.
	DbSelectArea("N9A")
	DbSetorder(1)
	dbSeek(xFilial("N9A") + NJR->NJR_CODCTR)
	While !N9A->(Eof()) .AND. ( xFilial("N9A") + NJR->NJR_CODCTR == N9A->N9A_FILIAL+N9A->N9A_CODCTR ) 
		
		cMsg := ''
		
		If  Empty(N9A->N9A_CODENT)
			cMsg += STR0083
			lErro := .T.
		EndIf
		If  Empty(N9A->N9A_TES) 
			If !Empty(cMsg)
				cMsg += ", "
			EndIf
		
			cMsg += STR0082
			lErro := .T.
		EndIf
		If Empty(N9A->N9A_NATURE)
			
			If !Empty(cMsg)
				cMsg += ", "
			EndIf
			
			cMsg += STR0085
			lErro := .T.
		EndIf
		
		If lErro
			Help(NIL, NIL, STR0080, NIL, STR0081, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0084+cMsg})
			//Help('',1,".OGA270000001.") //"AJUDA"###Não é possivel Confirmar o contrato se houver Regras Fiscais sem os campos TES, Finalidade e Cod. Entidade informados.
			Return .F.
		EndIf

		If (N9A->N9A_OPETRI == '1' .OR. N9A->N9A_OPEFUT  == '1')
			Help('',1,".OGA270000002.") //"AJUDA"###É necessario informar a TES Auxiliar caso o contrato possua Operação Futura ou Operação Triangular.
			Return .F.	
		EndIf

		cFilialCtr := NJR->NJR_FILIAL
		cCodCtr    := NJR->NJR_CODCTR
		nQtd       := NJR->NJR_QTDINI
		cTes       := N9A->N9A_TES
		cNaturFin  := ""
		cFilOrg    := ""
		cCodCad    := N9A->N9A_ITEM
		cCodRegra  := N9A->N9A_SEQPRI
		cTipClient := ""
		cCodClient := ""
		cCodLoja   := ""
		nPrecoBase := 0
		cFormaCalc := ""

		If !Empty(NJR->NJR_CODIDX)
			//Busco o valor unitário do produto 		
			aValores := OGX060(cFilialCtr, cCodCtr, nQtd , cTes, cNaturFin, cFilOrg, cCodCad, cCodRegra, /*cCodRoman*/, /*cItemRom*/,  /*lUpdtRegra*/, cTipClient, cCodClient, cCodLoja, nPrecoBase, cFormaCalc )
			
			BEGIN TRANSACTION

				If aValores[1][1] != nil 
					If RecLock( "NJR", .F. )
						NJR->NJR_VLRBAS := aValores[1][1]									
						msUnLock()
					Endif

					If RecLock( "N9A", .F. )							
						N9A->N9A_VLUFPR := aValores[1][1]
						N9A->N9A_VLTFPR := aValores[1][1] * NJR->NJR_QTDINI
						N9A->N9A_VLR2MO := aValores[1][1]
						N9A->N9A_VLT2MO := aValores[1][1] * NJR->NJR_QTDINI
					Endif
				Endif
				
			END TRANSACTION
				
		Else //Valor base preenchido			

			BEGIN TRANSACTION			

				nPrecoBase := OGX700UMVL(NJR->NJR_VLRBAS, NJR->NJR_UMPRC, NJR->NJR_UM1PRO, NJR->NJR_CODPRO)
				
				If RecLock( "N9A", .F. )							
						N9A->N9A_VLUFPR := nPrecoBase
						N9A->N9A_VLTFPR := nPrecoBase * NJR->NJR_QTDINI
						N9A->N9A_VLR2MO := nPrecoBase
						N9A->N9A_VLT2MO := nPrecoBase * NJR->NJR_QTDINI
				Endif
			END TRANSACTION	
		Endif
		
		N9A->(DbSkip())
	EndDo
	
	If NJR->( NJR_MODELO ) = "1"
		Help( ,,STR0026,, STR0033, 1, 0 ) //"AJUDA"###"Pre-Contratos nao podem ser confirmados, altere para Contrato para depois confirmar."
	ElseIf .Not. AgrEntidOk( NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) ) //Verifica se a Entidade Esta ok, Tipo For/cli n. Bloqueados
		lRetorno:= .f.		
	Else

		If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) = "P"

			// Não permite confirmar se houver outro contrato Confirmado ou Iniciado com a mesma Entidade, Safra e Produto
			lRetorno := OGA390B(xFilial("NJR"), NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) , NJR->( NJR_CODSAF ), NJR->( NJR_CODPRO ) , NJR->( NJR_TIPO ) )
			if lRetorno = .F.
				Return .F.
			endif
        	
			If !__lAutomato 
			    //"Deseja realmente confirmar o contrato?"		
				lhistorico := (AGRGRAVAHIS(STR0034,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"N") = 1)
			Else
				lhistorico := .T.
			EndIf
			
			If lhistorico

				BEGIN TRANSACTION

					If RecLock( "NJR", .f. )
						NJR->( NJR_CODRPC ) := cNewCtr
						msUnLock()
					EndIf

					// Atualiza as quantidades autorizadas do contrato
					OGX010QAut("A")

					/** Gerar contrato de Deposito de 3o. na empresa de destino se for o caso */
					NJ0->( dbSetOrder( 1 ) )
					NJ0->( dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT ) ) )
					If .Not. Empty( NJ0->( NJ0_CODCRP ) ) .And. SuperGetMV( "MV_ARM334C", .f., .f. )

						BeginSql Alias 'QryNJ0'
						Select *
						From %table:NJ0% NJ0
						Where NJ0.NJ0_FILIAL = %xFilial:NJ0% And NJ0.NJ0_CODENT = %exp:NJR->( NJR_CODENT )% And NJ0.NJ0_LOJENT = %exp:NJR->( NJR_LOJENT )% And NJ0.%NotDel%
						EndSql
						dbGotop()

						BeginSql Alias 'QryNJR'
						column NJR_DATA As Date

						Select *
						From %table:NJR% NJR
						Where NJR.NJR_FILIAL = %xFilial:NJR% And NJR.NJR_CODCTR = %exp:NJR->( NJR_CODCTR )% And NJR.%NotDel%
						EndSql
						dbGotop()

						BeginSql Alias 'QryNNY'
						column NNY_DATINI As Date
						column NNY_DATFIM As Date

						Select *
						From %table:NNY% NNY
						Where NNY.NNY_FILIAL = %xFilial:NNY% And NNY.NNY_CODCTR = %exp:NJR->( NJR_CODCTR )% And NNY.%NotDel%
						EndSql
						dbGotop()

						cEmpAntSav := cEmpAnt
						cFilAntSav := cFilAnt

						cNewEmp := Substr( AllTrim( NJ0->( NJ0_CODCRP ) ), 1, 2 )
						cNewFil := Substr( AllTrim( NJ0->( NJ0_CODCRP ) ), 3, 2 )

						SX2->( dbCloseArea( ) )
						NJ0->( dbCloseArea( ) )
						NJR->( dbCloseArea( ) )
						NNY->( dbCloseArea( ) )

						cEmpAnt := cNewEmp
						cFilAnt := cNewFil

						dbSelectArea( "SX2" )

						EmpChangeTable( "NJ0" , cNewEmp , cEmpAntSav , 1 )
						If ( Select( "NJ0" ) == 0 )
							ChkFile( "NJ0" )
						EndIf
						EmpChangeTable( "NJR" , cNewEmp , cEmpAntSav , 1 )
						If ( Select( "NJR" ) == 0 )
							ChkFile( "NJR" )
						EndIf
						EmpChangeTable( "NNY" , cNewEmp , cEmpAntSav , 1 )
						If ( Select( "NNY" ) == 0 )
							ChkFile( "NNY" )
						EndIf

						NJ0->( dbSetOrder( 5 ) )
						NJ0->( dbSeek( xFilial( "NJ0" ) + cEmpAntSav + cFilAntSav ) )

						cNewCtr	:= GetSXENum( "NJR", "NJR_CODCTR" )
						ConfirmSX8()

						dbSelectArea( "NJR" )
						If RecLock( "NJR", .t. )
							For nX := 1 to FCount()
								cCampo := FieldName( nX )
								If .Not. Empty( cCampo )
									If Valtype( cCampo ) <> 'M'
										&( "NJR->( " + AllTrim( cCampo ) + " ) := QryNJR->( " + AllTrim( cCampo ) + " )" )
									Endif
								EndIf
							Next nX
							NJR->( NJR_FILIAL ) := xFilial( "NJR" )
							NJR->( NJR_TIPO   ) := "3"
							NJR->( NJR_CODCTR ) := cNewCtr
							NJR->( NJR_CODENT ) := NJ0->( NJ0_CODENT )
							NJR->( NJR_LOJENT ) := NJ0->( NJ0_LOJENT   )
							NJR->( NJR_CODRPC ) := QryNJR->( NJR_CODCTR )
							NJR->( NJR_AUTENT ) := QryNJR->( NJR_AUTENT )
							NJR->( NJR_AUTSAI ) := QryNJR->( NJR_AUTSAI )
							NJR->( NJR_STATUS ) := cStatus
							msUnLock()
						EndIf

						While .Not. QryNNY->( Eof() )

							dbSelectArea( "NNY" )
							If RecLock( "NNY", .t. )
								For nX := 1 to FCount()
									cCampo := FieldName( nX )
									If .Not. Empty( cCampo )
										If Valtype( cCampo ) <> 'M'
											&( "NNY->( " + AllTrim( cCampo ) + " ) := QryNNY->( " + AllTrim( cCampo ) + " )" )
										Endif
									EndIf
								Next nX
								NNY->( NNY_FILIAL ) := xFilial( "NNY" )
								NNY->( NNY_CODCTR ) := cNewCtr
								msUnLock()
							EndIf

							QryNNY->( dbSkip() )
						EndDo

						cEmpAnt := cEmpAntSav
						cFilAnt := cFilAntSav

						SX2->( dbCloseArea( ) )
						NJ0->( dbCloseArea( ) )
						NJR->( dbCloseArea( ) )
						NNY->( dbCloseArea( ) )

						EmpChangeTable( "NNY" , cEmpAntSav, cNewEmp , 1 )
						If ( Select( "NNY" ) == 0 )
							ChkFile( "NNY" )
						EndIf

						EmpChangeTable( "NJR" , cEmpAntSav , cNewEmp , 1 )
						If ( Select( "NJR" ) == 0 )
							ChkFile( "NJR" )
						EndIf
						EmpChangeTable( "NJ0" , cEmpAntSav , cNewEmp , 1 )
						If ( Select( "NJ0" ) == 0 )
							ChkFile( "NJ0" )
						EndIf

						QryNJ0->( dbCloseArea( ) )
						QryNJR->( dbCloseArea( ) )
						QryNNY->( dbCloseArea( ) )

						dbSelectArea( "SX2" )

					EndIf

					NJR->( dbGoto( nRegNJR ) )

					If RecLock( "NJR", .f. )
						NJR->( NJR_CODRPC ) := cNewCtr
						msUnLock()
					EndIf

					If !__lAutomato		
						MsgInfo( STR0036, STR0037 ) //"Contrato Confirmado com Sucesso!!!"###"Confirmação do Contrato"
					Endif

				END TRANSACTION

			EndIf

		Else
		    If !__lAutomato
				Help( ,,STR0026,, STR0038, 1, 0 ) //"AJUDA"###"Este contrato ja foi confirmado..."
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGA270E
Rotina para utilizada para encerrar o contrato para que o mesmo nao seja mais movimentado

@param: 	Nil
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA270E( cAlias, nReg, nAcao )
	Local aAreaAtu	:= GetArea()

	//Se NJR_STATUS for A=aberto , I=iniciado ou P=previsto
	If NJR->( NJR_STATUS ) $ "A|I|P"
		If NJR->( NJR_STATUS) == "P"
			Help( ,,STR0026,, STR0072, 1, 0 ) //"Ajuda"###"Contrato com status 'Previsto' não pode ser cancelado. Somente é permitido a operação de 'Excluir'.
			Return ( Nil )
		EndIf
		If NJR->( NJR_QTEFIS ) = 0 .AND.  NJR->( NJR_QTSFIS )= 0

			//"Deseja realmente encerrar este contrato?"
			If AGRGRAVAHIS(STR0039,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"E") = 1

				If RecLock( "NJR", .f. )
					NJR->( NJR_QTDCTR ) := NJR->( NJR_QTSFCO )
					NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
					NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
					NJR->( NJR_STATUS ) := "E"
					msUnLock()
				EndIf

				MsgInfo( STR0040, STR0041 ) //"Contrato Cancelado com Sucesso!!!"###"Encerramento do Contrato"

			EndIf				
		Else
			Help( ,,STR0026,,STR0086, 1, 0 ) //"Ajuda"#### "Contrato não pode ser Cancelado. Existe saldo de quantidades."
			Return( Nil )
		EndIf

	Else

		Help( ,,STR0026,, STR0042, 1, 0 ) //"Ajuda"###"Este contrato não pode ser -Cancelado-, pois ja foi -Finalizado-..."
		Return( Nil )

	EndIf

	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGA270F
Rotina para utilizada para finalizar o contrato para que o mesmo nao seja mais movimentado

@param: 	Nil
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA270F( cAlias, nReg, nAcao ) 
	Local aAreaAtu	:= GetArea()
	Local aTpContrato := SuperGetMV("MV_AGRO001",.F., "") //tipo do contrato //1COMPRA 2 VENDA 3 ARM DE TERC 4 ARMA EM TERC
	Local nIt		  := 0
	Local lRet        := .T.

	If !Empty(aTpContrato) // Verifica o parametro de tipo do contrato
		aTpContrato := Separa(aTpContrato, ";")
		For nIt := 1 To Len(aTpContrato)
			If NJR->( NJR_TIPO )== AllTrim(aTpContrato[nIt]) // se o tipo não fizer parte do parametro valida normalmente
				lRet := .F.
				//"Deseja realmente finalizar este contrato?"
				If NJR->( NJR_STATUS ) $ "I" 
					If AGRGRAVAHIS(STR0060,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
						If RecLock( "NJR", .f. )
							NJR->( NJR_STATUS ) := "F"
							msUnLock()
						EndIf
						MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finalização do Contrato"
					EndIf
				Else
					Help( ,,STR0026,, STR0045, 1, 0 ) //"Ajuda"###"Este contrato não pode ser -Finalizado-, pois ainda não foi -Iniciado- ."
					Return( Nil )
				EndIf
			EndIf
		Next nIt
		If lRet
			If NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
				//"Deseja realmente finalizar este contrato?"
				If AGRGRAVAHIS(STR0060,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
					If RecLock( "NJR", .f. )
						NJR->( NJR_STATUS ) := "F"
						msUnLock()
					EndIf
					MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finalização do Contrato"
				EndIf
			Else
				Help( ,,STR0026,, STR0073, 1, 0 ) //"Ajuda"###"Este contrato não pode ser -Finalizado-, verifique o status interno do contrato ."
				Return( Nil )
			EndIf

		EndIf
	Else
		If NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
			//"Deseja realmente finalizar este contrato?"
			If AGRGRAVAHIS(STR0060,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
				If RecLock( "NJR", .f. )
					NJR->( NJR_STATUS ) := "F"
					msUnLock()
				EndIf
				MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finalização do Contrato"
			EndIf
		Else
			Help( ,,STR0026,, STR0073, 1, 0 ) //"Ajuda"###"Este contrato não pode ser -Finalizado-, verifique o status interno do contrato ."   "
			Return( Nil )
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )



/** {Protheus.doc} fGatVlrUni
Gatilho no Campo NJR_VLRUNI q dispara para o NJR_VLRTOT


@param: 	Nil
@return:	nPsLiqu - Peso liquido para o romaneio
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		OGA260 -
*/
Static Function fGatVlrUni( )
	Local nRetorno	:= 0
	Local oModel	:= FwModelActive()

	//--<< Aplicar no calculo a conversão da unidade de medida
	//--<< Utilizar NJR_QTDCTR para considerar os aditivo caso houver
	nRetorno := Round( oModel:GetValue("NJRUNICO","NJR_QTDCTR") * OGX700UMVL(oModel:GetValue("NJRUNICO","NJR_VLRBAS"),oModel:GetValue("NJRUNICO","NJR_UMPRC"),oModel:GetValue("NJRUNICO","NJR_UM1PRO"), oModel:GetValue("NJRUNICO","NJR_CODPRO")),TamSX3('NJR_VLRTOT')[2])		
	
Return( nRetorno )

/** {Protheus.doc} OG270CODPRO
Função que Valida o produto, Verifica se é um Produto Valido e se o mesmo possui
UM. de Preço Cadastrada.
@param:   Produto
Retorno:  .t. ou .f. Indicando que o produto está ok.
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG270CODPRO(oModelNJR,cProduto,cTabela)
	Local oModel	:= FWModelActive()
	Local oModelNJR	:= oModel:GetModel( "NJRUNICO" )
	Local cUmPreco	:= AgrUmPrc ( cProduto )
	Local lRet		 	:= .t.


	If AGRTPALGOD(cProduto)
		oModelNJR:LoadValue("NJR_TABELA" , "")
	EndIf

	IF ! ExistCpo('SB1', cProduto )
		Help( , , STR0026, , STR0057, 1, 0 ) //"AJUDA"###"Produto nao cadastrado."
		lRet :=.f.
	ElseIF Empty(cUmPreco) 
		//Help - OGA270UMPRC  - cadastrado no Atusx - Manutenção Agro 12.1.17/Janeiro18
		Help('',1,"OGA270UMPRC") //"AJUDA"###"Produto nao possui UM.Preço."
		lRet := .f.
	ElseIF !Empty(cProduto) .and. !Empty(cTabela) // Validando o produto contra Tabela de Classif.
		lRet := OG270VDTB(oModelNJR,cProduto,cTabela)
	EndIF

	If lRet
		oModelNJR:LoadValue( "NJR_UMPRC" , cUmPreco )
	EndIf
Return( lRet )	

/** {Protheus.doc} fTrgNNYFIL
Função criada para realizar gatilho do campo NNY_FILORG
@author:    Thiago Henrique Rover
@since:     30/01/2018
@Uso:       OGA290 - Contrato de Venda
*/
Static Function fTrgNNYFIL(xVrNovo) //Projeto SLC
	Local oModel	:= FwModelActive()
	Local oN9A      := oModel:GetModel( "N9AUNICO" )	
	Local nCont     := 0
	Local oView     := FwViewActive()

	If __lnewNeg //se esta configurado parametro para usar registro de negocio 
		If !Empty(xVrNovo)	.and. oN9A:Length( .T. ) == 1 //se foi informado a filial e se tiver apenas uma regra fiscal ativa
			For nCont := 1 To oN9A:Length() //percorre toda a grid pois pode haver regras fiscais deletadas
				oN9A:GoLine(nCont)
				If .not. oN9A:IsDeleted() //se linha não estiver deletada
					oN9A:SetValue("N9A_FILORG", xVrNovo )
				EndIf
			Next nCont
			oN9A:GoLine(1)
			If valType(oView) == 'O' .AND. oView:ACURRENTSELECT[1] == "VIEW_NJR"
				oView:refresh("VIEW_N9A")
			EndIf
		EndIf
	EndIf

Return

/** {Protheus.doc} fTrgNNYDAT
Função criada para realizar gatilho do campo NNY_QTDINI
@author:    Thiago Henrique Rover
@since:     30/01/2018
@Uso:       OGA290 - Contrato de Venda
*/
Static Function fTrgNNYDAT(cCampo) //Projeto SLC 
	Local oModel	:= FwModelActive() 
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	Local oNNY      := oModel:GetModel( "NNYUNICO" )
	Local nCont     := 0
	Local oView     := FwViewActive()
	Local dDataNNY := IIF(cCampo == "NNY_DATINI", oNNY:GetValue('NNY_DATINI'), oNNY:GetValue('NNY_DATFIM') ) 
	
	If __lnewNeg
		
		If oN9A:Length( .T. ) == 1 //só tem uma linha ativa
			For nCont := 1 To oN9A:Length() //percorre a grid pois pode ter linha deletadas e como só tem uma linha ativa o valor deve ser inserido na linha ativa
				oN9A:GoLine(nCont)	
				If .not. oN9A:IsDeleted() //se linha não estiver deletada insere valor
					If cCampo == "NNY_DATINI"
						oN9A:LoadValue("N9A_DATINI", dDataNNY )
					Else 
						oN9A:LoadValue("N9A_DATFIM", dDataNNY )
					EndIf
				EndIf
			Next nCont		
			oN9A:GoLine(1)
			If valType(oView) == 'O' .AND. oView:ACURRENTSELECT[1] == "VIEW_NJR"
				oView:refresh("VIEW_N9A")
			EndIf
		EndIf
	
	EndIf

Return



/** {Protheus.doc} fN9ACopy
Função criada para limpar os valores de quantidades da grid de Regras Fiscais quando é feita Cópia
@author:    Janaina F B Duarte
@since:     21/02/2018
@Uso:       OGA270 - Contrato de Deposito em 3.
*/
Static Function fN9ACopy()  
	Local oModel	:= FwModelActive() 
	Local oN9A      := oModel:GetModel( "N9AUNICO" )	
	Local nCont     := 0
    
	If __lnewNeg .and. oModel:IsCopy() .and. !_lCopyN9A
		_lCopyN9A := .T.
		For nCont := 1 To oN9A:Length() 
			oN9A:GoLine(nCont)	
			If .not. oN9A:IsDeleted() //se linha não estiver deletada insere valor
				oN9A:LoadValue("N9A_QUANT", 0 )
				oN9A:LoadValue("N9A_SDOINS", 0 )
				oN9A:LoadValue("N9A_SDONF" , 0)
			EndIf
		Next nCont		
		oN9A:GoLine(1)		
	EndIf

Return

/*/{Protheus.doc} OGA270PRE
//Trata o evento de delete do grid de entregas
@author carlos.augusto
@since 13/02/2019
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@type function
/*/
Static Function PREVALNNY ( oGrid, nLine, cAction,cField,xVrNovo,xVrAnt )
	Local lRetorno	:= .T.
	Local oModel		:= oGrid:GetModel()
	Local oModelNJR  	:= oModel:GetModel("NJRUNICO")

	If cAction == "CANSETVALUE" .AND. cField == "NNY_QTDINT" .AND. oModelNJR:GetValue("NJR_STATUS") $ "A|I"
		Return (.F.) //não deve alterar a quantidade depois de confirmado
	EndIf 	
	If cAction == "SETVALUE" .And. cField == "NNY_DATINI"
	     AGRXDTNNY( oGrid )
	EndIf 
	If __lnewNeg 
	   If cAction == "SETVALUE" .AND. cField $ "NNY_FILORG"
		fTrgNNYFIL(xVrNovo)  
       EndIf	
	EndIf
	lRetorno := AGRXATUQTD(oGrid, cAction, xVrNovo, xVrAnt, nLine, cField )
	

Return ( lRetorno )

/*/{Protheus.doc} PreValNJR()
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
 Static Function PreValNJR(oFieldModel, cAction, cIDField, xValue)
	Local oModel  := FwModelActive()
	Local lRet	   := .T.
	
	If ValType(oModel) == "U" //proteção quando o set é chamado de outra função (agrxctr)
		Return lRet
	EndIf 

	If cAction == "SETVALUE" .AND. cIDField $ "NJR_CODPRO"
		oFieldModel:ClearField("NJR_TABELA")
		lRet := OG270CODPRO(oFieldModel,xValue,oFieldModel:GetValue("NJR_TABELA"))
		Return lRet
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TABELA"
		oFieldModel:ClearField("NJR_TABELA")
		lRet := OG270VDTB(oFieldModel,xValue,oFieldModel:GetValue("NJR_CODPRO"))
		Return lRet
	ElseIf cAction == "ISENABLE" .AND. cIDField $ "NJRUNICO" .AND. oFieldModel:GetOperation() == 3
		oFieldModel:SetValue("NJR_TIPO",'4')
		oFieldModel:SetValue("NJR_MODELO",'2')	
	ElseIf  cAction == "SETVALUE" .AND. cIDField $ "NJR_VLRBAS"
		oFieldModel:SetValue( "NJR_VLRUNI",  xValue )
	ElseIf  cAction == "SETVALUE" .AND. cIDField $ "NJR_LOJENT"	
		AGRXVALENT()
	EndIf
Return lRet
