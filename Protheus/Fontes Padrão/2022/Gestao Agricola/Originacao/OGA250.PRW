#INCLUDE "OGA250.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

/** Variaveis Statics da Rotina 
Atenção Com  statics  declaradas  fora  de função, pois ao inicializar a  Var	aParBal := AGRX003E( .f. )
a  rotina  AGRX003E  faz  referencia a uma tabela (DX6) quando  estamos executando  com SIGAADV, tudoOK, porem
se executamos via SIGAMDI, dá  erro de DX6 não existe, a razão é que em MDI, ao clicar na opção de menu o ERP,
possibilita  trocar  de Empresa / filial, o que faz com que	o TOP feche as conexões com o banco,retornando assim
mensagem de erro. Para solucionar o problema inicializei no method Activate ( oModel:SetActivate ) do modelo.
**/ 
Static oBrowseNJJ	:= Nil 
Static aParBal		:= nil	    // -- Será inicializada na funcao no Activate do Model (Devido a Error log se executado em MDI )--/	
Static aVetNK4     	:= {} 
Static lTemNFTrans 	:= .F.
Static lF10Exec    	:= .t.
Static nDecPeso		:= SuperGetMV("MV_OGDECPS",,0) 
Static _ChkQldPes 	:= SuperGetMV("MV_OGQLPES",.F.,.F.)   ///Se o parametro não existir considerar como False ( .t. Indica que irá validar o Paracer da Qualidade antes de Pesar ( bloqueando a pesagem se parecer n. Existir)  
Static lChkAgoClas 	:= SuperGetMV("MV_AGOCLAS",.F.,.F.)   ///armazena o valor do parametro, se o parametro não existir considerar como False
Static lMVOGUSANT 	:= SuperGetMV("MV_OGUSANT", , .F.) //PARAMETRO de uso da Nf de transito
Static lExecAgoClas := .f. //lExecAgoClas - variavel que informa se a função AgoClas esta em execução - DAGROGAP-413
Static _lAltIE		:= .F. //indica se houve alteração/inclusão na IE 
Static _lFretOrig	:= .F. //Contrato define se NFP compra fob utilizará peso origem

Static __aTab1221   := {"N83"} //tabelas SLC - previsão liberação 1220
Static __lLib1221   := .F. //Proteção de fonte para liberação 12.20 SLC

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __cAnaCred	:= SuperGetMv('MV_AGRB003', , .F.) // Parametro de utilização de análise de crédito
Static __lDescOk	:= .T. //O campo resultado passa por dois valids. Eh preciso saber se deve executar o segundo valid

/** {Protheus.doc} OGA250
Rotina de Romaneio de Compra utilizada para entradas de cargas onde a emissão do documento
do Romaneio é obrigatório. Esta rotina permite a atualização do saldo fisico, porem quando
uma nota fiscal acompanhar o mesmo deve atualizar tambem o saldo fiscal.
//

@param: 	Nil
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		SIGAAGR
*/
Function OGA250( cAlias, nReg, nAcao )
	private aFardRom  := {}	

	Private aGravHist := {}
	Private aIniPad	  := OGA250INIT( .f. )
	Private _cUNB     := A655GETUNB( )  
	Private _oBrwClass
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita
	Private _aItsEsq   	:= {}
	Private _lVincFard  := .F.	
    
	If !SuperGetMv("MV_AGRORI",,.F.) .OR. !SuperGetMv("MV_SIGAAGR",,.F.)  
		Agrhelp(STR0021,STR0557,STR0558) //"Não é possível acessar a rotina de romaneios com o modulo Agroindústria e Originação desativados","Para acessar a rotina de Romaneios do modulo Agroindústria é necessários ativar os parâmetros MV_AGRORI e MV_SIGAAGR"
		Return
	EndIf

	fSetKey()	

	If _cCLTTEMP == Nil .And. FWHasEAI( "AGRA530", .T., .F., .T. )
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP) //AGRA530TTO
	EndIf

	If !FINDFUNCTION("AGRDESCRINNK") 
		Agrhelp(STR0021,STR0394+"AGRDESCRINNK",STR0395) //Rotina não esta atualizada  +AGRDESCRINNK, Entre em contato com o suporte para atualizar a rotina do romaneio.
		Return
	EndIf

	__lLib1221 := AGRTABDIC(__aTab1221) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC

	oBrowseNJJ := FWMBrowse():New()
	oBrowseNJJ:SetAlias( "NJJ" )
	oBrowseNJJ:SetDescription( STR0001 ) //"Romaneios"
	oBrowseNJJ:SetMenuDef( "OGA250" )

	If NJJ->(ColumnPos('NJJ_ORIGEM')) > 0 //Campos novo romaneio 
		If !(Empty(_cUNB))
			//	oBrowseNJJ:SetFilterDefault("NJJ_ORIGEM <> 'AGRA500' .AND. (NJJ_CODUNB == '" + _cUNB + "' .OR. NJJ_CODUNB = '') .AND. NJJ_TIPENT == '0' ")
			//----- Status diferente de Agendamento == '6'  
			oBrowseNJJ:SetFilterDefault("NJJ_STATUS <> '6' .AND. (NJJ_CODUNB == '" + _cUNB + "' .OR. NJJ_CODUNB = '') .AND. NJJ_TIPENT == '0' ")
		Else
			//	oBrowseNJJ:SetFilterDefault("NJJ_ORIGEM <> 'AGRA500' .AND. NJJ_TIPENT == '0'") //0=Físico;1=Gerencial;2=Simbolico;3=Retenção	
			//----- Status diferente de Agendamento == '6'
			oBrowseNJJ:SetFilterDefault("NJJ_STATUS <> '6' .AND. NJJ_TIPENT == '0'") //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
		EndIf
	Else
		If !(Empty(_cUNB))
			oBrowseNJJ:SetFilterDefault( " (DXM_CODUNB == '" + _cUNB + "' .OR. DXM_CODUNB = '')  .AND. NJJ_TIPENT == '0'" )
		Endif
	EndIF

	oBrowseNJJ:AddLegend( "NJJ_STATUS=='0'", "RED"			, X3CboxDesc( "NJJ_STATUS", "0" ) ) //"Pendente"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='1'", "YELLOW"		, X3CboxDesc( "NJJ_STATUS", "1" ) ) //"Completo"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='2'", "ORANGE"		, X3CboxDesc( "NJJ_STATUS", "2" ) ) //"Atualizado"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='3'", "GREEN"		, X3CboxDesc( "NJJ_STATUS", "3" ) ) //"Encerrado"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='4'", "BR_CANCEL"	, X3CboxDesc( "NJJ_STATUS", "4" ) ) //"Cancelado"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='5'", "BR_PINK"		, X3CboxDesc( "NJJ_STATUS", "5" ) ) //"Pendente de aprovação"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='6'", "BR_BRANCO"	, X3CboxDesc( "NJJ_STATUS", "6" ) ) //"Previsto"

	oBrowseNJJ:aColumns[1]:cTitle := "Sts.Rom."
	If __lnewNeg
		bColor02 := { || Iif(NJJ->NJJ_LIBQLD=='0' .or. Empty(NJJ->NJJ_LIBQLD) ,'BR_CINZA', Iif(NJJ->NJJ_LIBQLD=='1','BR_VERDE', Iif(NJJ->NJJ_LIBQLD=='2','BR_VERMELHO', Iif(NJJ->NJJ_LIBQLD=='3','BR_AMARELO', ''))))}
		ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oBrowseNJJ| OGA250Leg() }  OF oBrowseNJJ

		oBrowseNJJ:aColumns[2]:cTitle := "Par.Qld."

		//0 - "Não Classificado" (vermelho) | 1 - "Classificado" (verde)
		bColor02 := { || Iif(NJJ->NJJ_STSCLA=='0' .or. Empty(NJJ->NJJ_STSCLA),'BR_VERMELHO', Iif(NJJ->NJJ_STSCLA=='1','BR_VERDE', ''))}
		ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oBrowseNJJ| A500Leg() }  OF oBrowseNJJ	

		oBrowseNJJ:aColumns[3]:cTitle := STR0376 //"St. Clas."	 
		oBrowseNJJ:aColumns[3]:nalign := 1
	EndIf
	If cPaisLoc == "ARG" 
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("NJJ_STACTP")	
			aLegeC   := {{"1",},{"2",},{"3",},{"4",},{"5",},{"6",},{"7",},{"8",}}
			bColor03 := {|| AGRLEGBWESP(NJJ->NJJ_STACTP,aLegeC)}
			ADD STATUSCOLUMN oColumn DATA bColor03 DOUBLECLICK {|oBrowseNJJ| AGRLENGESP("NJJ_STACTP",aLegeC)} OF oBrowseNJJ
			oBrowseNJJ:aColumns[3]:cTitle := X3TITULO("NJJ_STACTP")
		EndIf  		
	EndIf
	If __lnewNeg
		oBrowseNJJ:SetFilterDefault( "NJJ_TIPENT == '0'") //0=Físico;1=Gerencial;2=Simbolico;3=Retenção	
	EndIf
	oBrowseNJJ:DisableDetails()
	oBrowseNJJ:Activate()

	fSetKey()

	oBrowseNJJ:DeActivate()
Return ( )

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		SIGAAGR
*/
Static Function MenuDef()
	Local aRotina := {},aRotin2 := {}
	Local nx      := 0

	aAdd( aRotina, { STR0006	   	, "PesqBrw"							, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0007		, "OGA250Visual()"					, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0008		, "ViewDef.OGA250"					, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0009		, "OGA250ALT"					    , 0, 4, 0, .T. } ) //"Alterar"

	ADD OPTION aRotina TITLE STR0081 ACTION "OGA250ATUC" OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //"Atualizar"

	aAdd( aRotina, { STR0010	 	, "OGA250NF"						, 0, 4, 0, .F. } ) //"Confirmar"	
	aAdd( aRotina, { STR0011		, "OGA250REA"						, 0, 4, 0, .F. } ) //"Reabrir"
	aAdd( aRotina, { STR0084		, "OGA250CAN"						, 0, 4, 0, .F. } ) //"Cancelar"
	aAdd( aRotina, { STR0020		, "OGA250VKF10()"					, 0, 4, 0, .F. } ) //"Pesagem"
	aAdd( aRotina, { STR0089    	, "AGRCONHECIM('NJJ')"          	, 0, 4, 0, .F. } ) //"Conhecimento",
	aAdd( aRotina, { STR0012		, "ViewDef.OGA250"			    	, 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0013		, "OGR250"							, 0, 8, 0, .T. } ) //"Imprimir"
	aAdd( aRotina, { STR0169		, "OGASPED()"  				 		, 0, 4, 0, .F. } ) //"Sped.NFe"
	aAdd( aRotina, { STR0149		, "OGA250HIS"						, 0, 7, 0, .F. } ) //"Histórico"
	aAdd( aRotina, { STR0183		, "OGA250ANA"						, 0, 4, 0, .F. } ) //"Insp.Analise"
	aAdd( aRotina, { STR0331		, "AGOCLAS"							, 0, 4, 0, .T. } ) //"atualizar quantidade fisica e classificação
	aAdd( aRotina, { STR0381 		, "OGA250COMP()"					, 0, 4, 0, .T. } ) //"Nota Complementar"
	aAdd( aRotina, { STR0359		, "OGA250F(NJJ->NJJ_CODROM, NJJ->NJJ_CODCTR)"	   , 0, 4, 0, .F. } ) //"Informar Docto Referência"

	If __lnewNeg
		aAdd( aRotina, { STR0375 		, "OGA252(NJJ->NJJ_CODROM)"    		, 0, 4, 0, Nil } ) //"Monitoramento"	

		If __lLib1221
			aAdd( aRotina, { STR0339	, "AGRX500FAR()"  , 0, 4, 0, .F. } ) //"Vincular Fardos"
			aAdd( aRotina, { STR0362	, "OGAR250()"		                               , 0, 4, 0, .T. } ) //"Lista Fardos Romaneio"
			aAdd( aRotina, { "Registro de Entrega"	, "OGA250REG(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)"	   , 0, 4, 0, .F. } ) //"Registro de Entrega"
		EndIf	
	EndIf

	If cPaisLoc == "ARG" 
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("NJJ_CARTA")
			aRotin2 :=	{{STR0211,"OGA250CP()"		 		,0,4,0,nil},;
			{STR0212,"OGA250CD"			,0,5,0,nil},;
			{STR0213,"OGA250DD"			,0,4,0,nil},;	
			{STR0214,"OGA250DE"			,0,5,0,nil},;
			{STR0215,"OGA250EC"			,0,5,0,nil},;
			{STR0216,"OGA250RECH(.f.)"		,0,5,0,nil},;
			{STR0217,"OGA250RECH(.t.)"		,0,5,0,nil}}	
			aAdd(aRotina,{STR0218,aRotin2,0,8,0,Nil})
		EndIf		
	EndIf

	//PONTO DE ENTRADA PARA AÇÕES RELACIONADAS
	If ExistBlock('OG250MNU')
		aRetM := ExecBlock('OG250MNU',.F.,.F.)
		If Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nx])
			Next nx 
		EndIf
	EndIf 

Return( aRotina )

///////////////////////////////////////////////////
Function OGA250Visual()
	Local xRet 

	//FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
	xRet := FWExecView( STR0007, "OGA250", MODEL_OPERATION_VIEW ) //"Visualizar"
	fAftOKButton()

Return xRet

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio de Compra
*/
Static Function ModelDef()
	Local oStruNJJ := FWFormStruct( 1, "NJJ" )
	Local oStruNJK := FWFormStruct( 1, "NJK" )
	Local oStruNK4 := FWFormStruct( 1, "NK4" )
	Local oStruNJM := FWFormStruct( 1, "NJM" )
	Local oStruN9E := Nil
	Local oStruDX0 := Nil
	Local oStruN9D := Nil

	Local oModel
	Local bLinPreNJM := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreLGrdNJM( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }
	Local bFldPre  := { |oFldModel, cAction, cIDField, xValue, xCurrentValue| PreFldNJJ( oFldModel, cAction, cIDField, xValue , xCurrentValue) }
	Local bLinPreN9E := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRX500FPR( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue) }

	// Ajustado para Execauto
	Local lSimbolico	:= IsInCallStack( "OGA251" ) .or. Alltrim( FunName() ) == 'OGA251'// Se foi chamado pelo OGA251, é romaneio simbólico
	Local bTranVld	:= 'A500VDTRAN()'        

	//Ajuste da chave da NFE
	If NJJ->NJJ_STATUS  == '3' .AND. Empty(NJJ->NJJ_CHVNFE) 
		OGAjusDcFis()
	EndIf

	If NJJ->(ColumnPos('NJJ_ORIGEM')) > 0 //Campos novo romaneio
		oStruNJJ:RemoveField('NJJ_ORIGEM')	
		oStruNJJ:RemoveField('NJJ_EST')
		oStruNJJ:RemoveField('NJJ_DIFFIS')
		oStruNJJ:RemoveField('NJJ_CGC')
		oStruNJJ:RemoveField('NJJ_TOETAP')
		oStruNJJ:RemoveField('NJJ_DESTPO')
		oStruN9E := FWFormStruct( 1, "N9E" )
		oStruDX0 := FWFormStruct( 1, "DX0" )
		oStruN9D := FWFormStruct( 1, "N9D" )
	Endif

    If GetRpoRelease() <= "12.1.033" //Placa pode ser alterada, ajustado P12.1.2210		
		oStruNJJ:SetProperty( 'NJJ_PLACA' , MODEL_FIELD_WHEN  	,  {||.T.} )	
	EndIf

	//=== Trava campo para edição ===//
	oStruNJJ:SetProperty("NJJ_QPAREC",MODEL_FIELD_WHEN, {|| .f.})		//trava como .F.
	oStruNJJ:SetProperty("NJJ_LIBQLD",MODEL_FIELD_WHEN, {|| .f.})		//trava como .F.
	If __lnewNeg
		oStruNJJ:SetProperty("NJJ_TABELA",MODEL_FIELD_WHEN, {|| OGA250VLT()})
	EndIf 

	// Se o parâmetro de que a empresa usa NF de Transito estiver habilitado, insere campo e gatilho
	If lMVOGUSANT .And. !lSimbolico 
		oStruNJJ:AddField( STR0111, STR0112, 'TMP_SERNFT', 'C' , TamSX3("NK2_SERNFT")[1] , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/) 	//"Serie NF Tr."##"Série da NF de Transito"
		oStruNJJ:AddField( STR0113, STR0114, 'TMP_NUMNFT', 'C' , TamSX3("NK2_NUMNFT")[1] , 0 , {|| fVldNFTrans() }/*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"NF Transito"##"Número da NF de Transito"
	EndIf

	///=== Define gatilhos ===///
	If lSimbolico          
		oStruNJM:AddTrigger( "NJM_QTDFCO", "NJM_QTDFIS", { || .t. }, { | x | fTrgQtdFia( x ) } )   
		oStruNJJ:AddTrigger( "NJJ_QTDFIS", "NJJ_PSSUBT", { || .t. }, { | x | fTrgQtdFis( x ) } )
	EndIf
	oStruNJJ:AddTrigger( "NJJ_TIPO"  , "NJJ_DSTIPO", { || .t. }, { || SubStr( Posicione( "SX5", 1, xFilial("SX5") + "K5" + FwFldGet( "NJJ_TIPO" ), "X5_DESCRI" ), 1, TamSX3( "NJJ_DSTIPO" )[1] ) } )
	oStruNJJ:AddTrigger( "NJJ_TIPO"	 , "NJJ_PSLIQU", { || .t. }, { | x | fTrgPesoLiq( x ) } )
	oStruNJJ:AddTrigger( "NJJ_TABELA", "NJJ_PSLIQU", { || .t. }, { | x | fTrgPesoLiq( x ) } )
	oStruNJJ:AddTrigger( "NJJ_PSSUBT", "NJJ_PSLIQU", { || .t. }, { | x | fTrgPesoLiq( x ) } )
	oStruNJJ:AddTrigger( "NJJ_STSCLA", "NJJ_STATUS", { || .t. }, { | x | fTrgStatus(  ) } )
	oStruNJJ:AddTrigger( "NJJ_STSPES", "NJJ_STATUS", { || .t. }, { | x | fTrgStatus(  ) } )
	oStruNJJ:AddTrigger( "NJJ_PLACA" , "NJJ_CODMOT", { || .T. }, { | x | fTrgPlaca( x ) } )
	oStruNJJ:AddTrigger( "NJJ_CODCTR", "NJJ_CODENT", { || .T. }, { | x | fTrgIncCtr( x ) } )
	/*
	||=================||
	||  Proteção .23   ||
	||=================||
	*/	
	//Os 3 campos estão relacionados entre si
	If __lnewNeg	
		oStruNJJ:AddTrigger( "NJJ_CGC"     , "NJJ_NOMMOT"       , {|| .T. }, {|| A500GTNMMT()} )
		oStruNJJ:AddTrigger( "NJJ_CGC"     , "NJJ_CODMOT"       , {|| .T. }, {|| A500GTCODMT()} )
		oStruNJJ:AddTrigger( "NJJ_CODMOT"  , "NJJ_CGC"		   , {|| .T. }, {|| A500GTCGC()} )
	EndIf
	
	oStruNJM:AddTrigger( "NJM_PERDIV", "NJM_QTDFCO", { || .T. }, { | x | fTrgPerDiv( x ) } )
	oStruNJM:AddTrigger( "NJM_QTDFCO", "NJM_PERDIV", { || .T. }, { | x | fTrgQtdFco( x ) } )

	///=== Define obrigatoriedade ===///
	oStruNJJ:SetProperty("NJJ_TIPO"  ,MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_CODENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_LOJENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_ENTENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJJ:SetProperty("NJJ_ENTLOJ",MODEL_FIELD_OBRIGAT,.F.)

	oStruNJM:SetProperty("NJM_CODENT",MODEL_FIELD_OBRIGAT,.F.)
	oStruNJM:SetProperty("NJM_LOJENT",MODEL_FIELD_OBRIGAT,.F.)    

	If __lnewNeg 
		oStruDX0:SetProperty( "DX0_FARDAO" ,MODEL_FIELD_OBRIGAT, .F.) //Relacionamento ocorre em background
	EndIf
	///=== Define validações ===///
	oStruNJJ:SetProperty( "NJJ_TIPO" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"fTrgIncTL()") ) 
	oStruNJJ:SetProperty( "NJJ_LOJENT" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"fTrgIncTL()") ) 

	If __lnewNeg
		oStruNJJ:SetProperty( 'NJJ_CODTRA' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTranVld))
	EndIf
	oStruNJJ:SetProperty( "NJJ_CODSAF" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ1( oField, 'NJJ_CODSAF' ) } )
	oStruNJJ:SetProperty( "NJJ_CODPRO" 	, MODEL_FIELD_VALID	, {| oField, oStruNJJ | fVldCodPro(oField,oStruNJJ) } )
	oStruNJJ:SetProperty( "NJJ_LOCAL" 	, MODEL_FIELD_VALID	, {| oField, oStruNJJ | fVldLocal( oField,oStruNJJ) } )

	oStruNJJ:SetProperty( "NJJ_DOCSER" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCNUM" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )
	oStruNJJ:SetProperty( "NJJ_DOCEMI" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )
	//oStruNJJ:SetProperty( "NJJ_DOCESP" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField, 'NJJ_DOCESP' ) } )
	oStruNJJ:SetProperty( "NJJ_CHVNFE" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField, 'NJJ_CHVNFE' ) } )
	oStruNJJ:SetProperty( "NJJ_TES" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )
	oStruNJJ:SetProperty( "NJJ_NFPSER" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )
	oStruNJJ:SetProperty( "NJJ_NFPNUM" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ2( oField ) } )

	oStruNJJ:SetProperty( "NJJ_TPFORM" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_TPFORM" ) } )
	oStruNJJ:SetProperty( "NJJ_QTDFIS" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_QTDFIS" ) } )

	oStruNJJ:SetProperty( "NJJ_VLRUNI" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_VLRUNI" ) } )
	oStruNJJ:SetProperty( "NJJ_VLRTOT" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_VLRTOT" ) } )
	oStruNJJ:SetProperty( "NJJ_FRETE" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_FRETE" ) } )
	oStruNJJ:SetProperty( "NJJ_TPFRET" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_TPFRET" ) } )
	oStruNJJ:SetProperty( "NJJ_SEGURO" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_SEGURO"  ) } )
	oStruNJJ:SetProperty( "NJJ_DESPES" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_DESPES" ) } )

	//Ao atualizar o valor do novo campo NJJ_PESO3 o volor deve ser atualizado no campo NJM_QTFCO  - DAGROGAP-446
	oStruNJJ:SetProperty( "NJJ_PESO3" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_PESO3"  ) } )

	oStruNJJ:SetProperty( "NJJ_PSLIQU" 	, MODEL_FIELD_VALID	, {| oField | fVldNJJ3( oField, "NJJ_PSLIQU" ) } )

	oStruNJJ:SetProperty( "NJJ_CODAUT" 	, MODEL_FIELD_VALID	, {| oField | fInicTra( oField ) } )

	oStruNJM:SetProperty( "NJM_FRETE" 	, MODEL_FIELD_VALID	, {| oField | fVldFrete( oField ) } )

	If __lnewNeg
		oStruNJM:SetProperty( "NJM_LOTCTL"  , MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"OG250Lot()") )
	EndIf

	oStruNJJ:SetProperty( "NJJ_DOCSER"  , MODEL_FIELD_WHEN  , {|| .T.}) 
	oStruNJJ:SetProperty( "NJJ_DOCNUM"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('1')} )
	oStruNJJ:SetProperty( "NJJ_DOCEMI"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('1')} )
	oStruNJJ:SetProperty( "NJJ_DOCESP"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('1')} )
	oStruNJJ:SetProperty( "NJJ_QTDFIS"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('2')} )
	oStruNJJ:SetProperty( "NJJ_VLRUNI"  , MODEL_FIELD_WHEN  , {|| .T.} )
	oStruNJJ:SetProperty( "NJJ_VLRTOT"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('1')} )

	oStruNJJ:SetProperty( "NJJ_NFPSER"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('3')} )
	oStruNJJ:SetProperty( "NJJ_NFPNUM"  , MODEL_FIELD_WHEN  , {||wVldNJJ1('3')} )

	oStruNJJ:SetProperty( "NJJ_TES"     , MODEL_FIELD_WHEN  , {||wVldNJJ1('0')} )

	oStruNJJ:SetProperty( "NJJ_CHVNFE"  , MODEL_FIELD_WHEN  , {||wVldNJJ2('1')} )

	oStruNJJ:SetProperty( "NJJ_PESO3"  , MODEL_FIELD_WHEN  , {||wVldNJJ2('NJJ_PESO3')} )

	If __lnewNeg
		oStruNJJ:SetProperty( "NJJ_DATCHE"  , MODEL_FIELD_WHEN  , {||wVldNJJ2('NJJ_DATCHE')} )
		oStruNJJ:SetProperty( "NJJ_HORCHE"  , MODEL_FIELD_WHEN  , {||wVldNJJ2('NJJ_HORCHE')} )
	EndIf

	///=== Define inicializadores padrões ===///
	oStruNJM:SetProperty( "NJM_PERDIV" 	, MODEL_FIELD_INIT 	, {| oField | fIniPerDiv( oField ) } )
	oStruNJM:SetProperty( "NJM_QTDFCO" 	, MODEL_FIELD_INIT 	, {| oField | fIniQtdFco( oField ) } )

	If lSimbolico
		oStruNJJ:SetProperty( "NJJ_TIPENT" , MODEL_FIELD_INIT 	, { | | "2" } ) // 2=Simbolico
		oStruNJJ:SetProperty( "NJJ_STSCLA" , MODEL_FIELD_INIT 	, { | | "1" } ) // 1=Classificado
	Else
		oStruNJJ:SetProperty( "NJJ_TIPENT" , MODEL_FIELD_INIT 	, { | | "0" } ) // 0=Físico
	EndIf

	If IsInCallStack( "OGI250" )
		oStruNJJ:SetProperty( "NJJ_CODROM", MODEL_FIELD_INIT  , { | | "" } )
		oStruNJJ:SetProperty( "NJJ_PLACA" , MODEL_FIELD_VALID , {|| .T.} )
	EndIf

		If NJJ->(ColumnPos('NJJ_MOEGA')) > 0 
		oStruNJJ:AddTrigger( "NJJ_MOEGA", "NJJ_DESMOE",{ || .T. }, { | x | fTrgMoega( x ) } )
		oStruNJJ:AddTrigger( "NJJ_CULTIV", "NJJ_DESCTV",{ || .T. }, { | x | fTrgCultiv( x ) } )
		oStruNJJ:AddTrigger( "NJJ_MOEGA", "NJJ_LOCAL",{ || .T. }, { | x | fTrgLocal( x ) } )
		oStruNJJ:AddTrigger( "NJJ_CULTIV", "NJJ_LOCAL",{ || .T. }, { | x | fTrgLocal( x ) } )
		oStruNJJ:AddTrigger( "NJJ_CODPRO", "NJJ_LOCAL",{ || .T. }, { | x | fTrgLocal( x ) } )	

		oStruNJJ:SetProperty( "NJJ_MOEGA" 	, MODEL_FIELD_VALID	, {| x | fvldMoega(x)})
		oStruNJJ:SetProperty( "NJJ_CULTIV" 	, MODEL_FIELD_VALID	, {| x | fvldCulti(x)})

	EndIf

	//-- Emerson 23/02/2015 Para Tratar Frete , Seguro,Despesa --//
	oStruNJM:SetProperty( "NJM_FRETE" 	, MODEL_FIELD_INIT 	, {|| FWFLDGET("NJJ_FRETE" ) } )
	oStruNJM:SetProperty( "NJM_SEGURO"	, MODEL_FIELD_INIT 	, {|| FWFLDGET("NJJ_SEGURO") } )
	oStruNJM:SetProperty( "NJM_DESPES"	, MODEL_FIELD_INIT 	, {|| FWFLDGET("NJJ_DESPES") } )		
	If __lnewNeg
		oStruN9E:SetProperty( "N9E_CODINE" , MODEL_FIELD_VALID , {|| fGetN7SDat() } )
	EndIf
	///=== Remove campos do model ===///
	oStruNJK:RemoveField( "NJK_CODROM" )
	oStruNJM:RemoveField( "NJM_CODROM" )
	oStruNK4:RemoveField( "NK4_CODROM" )
	oStruNJJ:RemoveField( "NJJ_TPCLAS" )
	If __lnewNeg
		oStruNJJ:RemoveField( "NJJ_STSCRG" )
	EndIf

	////////////////////////
	// Inicializa o Model //
	////////////////////////
	//MPFORMMODEL():New(   <cID >,   <bPre >,      <bPost >,    <bCommit >                       , <bCancel >)
	oModel := 	  MPFormModel():New( "OGA250", /*<bPre >*/ , {| oModel | PosModelo( oModel ) } , {| oModel | GrvModelo( oModel ) }, { |x| fAftOKButton() } )

	oModel:SetVldActivate( { |oMod| fVldActivate( oMod ) } )

	oModel:AddFields( "NJJUNICO", Nil, oStruNJJ, bFldPre ) //{ |x| PosFldNJJ( x ) } somante na V11
	oModel:AddGrid( "NJKUNICO", "NJJUNICO", oStruNJK, {|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|sfPreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)},/*lPos*/,/*bPre*/,/*bPos*/, /*bLoad*/)
	oModel:AddGrid( "NK4UNICO", "NJJUNICO", oStruNK4 )
	oModel:AddGrid( "NJMUNICO", "NJJUNICO", oStruNJM, bLinPreNJM, { |x| PosLGrdNJM( x ) }, { |oModel, nLinha, cAcao, cCampo,xVrNovo,xVrAnt | PreGrdNJM( oModel, nLinha, cAcao, cCampo,xVrNovo,xVrAnt ) }, { |x| PosGrdNJM( x ) }, /*bLoad*/ )
	If __lnewNeg
		oModel:AddGrid( "N9EUNICO", "NJJUNICO", oStruN9E,bLinPreN9E)
	EndIf
	oModel:SetRelation( "NJKUNICO", { { "NJK_FILIAL", "xFilial( 'NJK' )" }, { "NJK_CODROM", "NJJ_CODROM" } }, NJK->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NK4UNICO", { { "NK4_FILIAL", "xFilial( 'NK4' )" }, { "NK4_CODROM", "NJJ_CODROM" } }, NK4->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NJMUNICO", { { "NJM_FILIAL", "xFilial( 'NJM' )" }, { "NJM_CODROM", "NJJ_CODROM" } }, NJM->( IndexKey( 1 ) ) )
	If __lnewNeg
		oModel:SetRelation( "N9EUNICO", { { "N9E_FILIAL", "xFilial( 'N9E' )" }, { "N9E_CODROM", "NJJ_CODROM" } }, N9E->( IndexKey( 1 ) ) )
	EndIf
	oModel:GetModel( "NJKUNICO" ):SetOptional( .t. )
	oModel:GetModel( "NJKUNICO" ):SetNoDelete( .t. )
	oModel:GetModel( "NJKUNICO" ):SetNoInsert( .t. )

	oModel:GetModel( "NK4UNICO" ):SetOptional( .t. )
	oModel:GetModel( "NK4UNICO" ):SetNoDelete( .t. )
	oModel:GetModel( "NK4UNICO" ):SetNoInsert( .t. )

	oModel:GetModel( "NJMUNICO" ):SetOptional( .t. )

	/*
	||=================||
	||  Proteção .23   ||
	||=================||
	*/	

	If __lnewNeg

		oModel:GetModel( "N9EUNICO" ):SetOptional( .t. )
		oModel:GetModel( "N9EUNICO" ):SetUniqueLine( { "N9E_FILIAL","N9E_CODROM","N9E_SEQUEN" } )

		//-------------------------------------
		// Rastro de Fardinhos
		//-------------------------------------	
		oModel:AddGrid( "N9DUNICO", "NJJUNICO", oStruN9D,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
		oModel:GetModel( "N9DUNICO" ):SetDescription( STR0370)	//Fardos do Romaneio
		oModel:GetModel( "N9DUNICO" ):SetOptional( .t. )

		oModel:SetRelation( "N9DUNICO", { { "N9D_FILIAL", "fwxFilial( 'N9D' )" },{ "N9D_CODROM", "NJJ_CODROM" }}, N9D->( IndexKey( 1 ) ) )//Preciso que nao filtre por item
    EndIf 
	oModel:GetModel( "NJMUNICO" ):SetUniqueLine( { "NJM_ITEROM" } )	
		//--------------------------------------------------------------
		//Campos de peso na DX0 para fazer Rateio e integrar com o PIMS
		//--------------------------------------------------------------
		oStruDX0:AddField(/*cTitulo*/STR0363,/*"Peso Bruto"*/;
		/*cTooltip*/ STR0364,/*"Peso Bruto da Pesagem"*/;
		/*cIdField*/'DX0_PSBRUT',;
		/*cTipo*/'N',;
		/*nTamanho*/14,;
		/*nDecimal*/0,;
		/*bValid*/ ,;
		/*bWhen*/{||.F.},;
		/*aValues*/,;
		/*lObrigat*/ .F.,;
		/*bInit*/,;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */ .T.)

		oStruDX0:AddField(/*cTitulo*/STR0365,/*Tara*/;
		/*cTooltip*/ STR0366,/*"Tara da Pesagem"*/;
		/*cIdField*/'DX0_TARA',;
		/*cTipo*/'N',;
		/*nTamanho*/14,;
		/*nDecimal*/0,;
		/*bValid*/ ,;
		/*bWhen*/{||.F.},;
		/*aValues*/,;
		/*lObrigat*/ .F.,;
		/*bInit*/,;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */ .T.)

		oStruDX0:AddField(/*cTitulo*/STR0367,/*"Descontos"*/;
		/*cTooltip*/ STR0368,/*"Total de Descontos"*/;
		/*cIdField*/'DX0_PSDESC',;
		/*cTipo*/'N',;
		/*nTamanho*/14,;
		/*nDecimal*/0,;
		/*bValid*/ ,;
		/*bWhen*/{||.F.},;
		/*aValues*/,;
		/*lObrigat*/ .F.,;
		/*bInit*/,;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */ .T.)	

		//-------------------------------------
		// Grid de Fardoes do Romaneio
		//-------------------------------------
		oModel:AddGrid( "AGRA500_DX0", "NJJUNICO", oStruDX0,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
		oModel:GetModel( "AGRA500_DX0" ):SetDescription(STR0339) //"Fardos vinculados"	
		oModel:GetModel( "AGRA500_DX0" ):SetOptional( .t. )

		oModel:SetRelation( "AGRA500_DX0", { { "DX0_FILIAL", "fwxFilial( 'DX0' )" }, { "DX0_NRROM", "NJJ_CODROM" }  }, DX0->( IndexKey( 1 ) ) )
	

	oModel:SetDescription( STR0014 ) //"Romaneio"
	oModel:GetModel( "NJJUNICO" ):SetDescription( STR0015 ) //"Cabecalho do Romaneio"
	oModel:GetModel( "NJKUNICO" ):SetDescription( STR0016 ) //"Itens de Classificação"
	oModel:GetModel( "NK4UNICO" ):SetDescription( STR0082 ) //"Histórico Classificação"
	oModel:GetModel( "NJMUNICO" ):SetDescription( STR0017 ) //"Itens de Comercialização"

	If __lnewNeg
		oModel:GetModel( "N9EUNICO" ):SetDescription( STR0351 ) //"Romaneio x Agendamento" 
	EndIf

	oModel:SetActivate(   { | oModel | fIniModelo( oModel, oModel:GetOperation() ) } )
	oModel:SetDeActivate( { | oModel | fFimModelo( oModel )                        } )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		SIGAAGR
*/
Static Function ViewDef()
	Local oStruNJJ 	:= FWFormStruct( 2, "NJJ" )
	Local oStruNJK 	:= FWFormStruct( 2, "NJK" )
	Local oStruNK4 	:= FWFormStruct( 2, "NK4" )
	Local oStruNJM 	:= FWFormStruct( 2, "NJM" )
	Local oStruN9E 	:= Nil
	Local oModel   	:= FWLoadModel( "OGA250" )
	Local oView    	:= FWFormView():New()
	Local cFormulario	:= IIf( NJJ->( NJJ_TPFORM )=="1", "S", "N" )
	Local lSimbolico	:= IsInCallStack( "OGA251" ) // Se foi chamado pelo OGA251, é romaneio simbólico

	If __lnewNeg
		oStruN9E 	:= FWFormStruct( 2, "N9E" )
	EndIf
	_lAltIE := .F.
	__lLib1221 := AGRTABDIC(__aTab1221) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC
	// Se o parâmetro de que a empresa usa NF de Transito estiver habilitado, insere campo e gatilho
	If lMVOGUSANT .And. !lSimbolico 

		//----------Estrutura do campo tipo View----------------------------
		// [01] C Nome do Campo
		// [02] C Ordem
		// [03] C Titulo do campo
		// [04] C Descrição do campo
		// [05] A Array com Help
		// [06] C Tipo do campo
		// [07] C Picture
		// [08] B Bloco de Picture Var
		// [09] C Consulta F3
		// [10] L Indica se o campo é evitável
		// [11] C Pasta do campo
		// [12] C Agrupamento do campo
		// [13] A Lista de valores permitido do campo (Combo)
		// [14] N Tamanho Maximo da maior opção do combo
		// [15] C Inicializador de Browse
		// [16] L Indica se o campo é virtual
		// [17] C Picture Variável

		/*A POSICAO DOS CAMPOS CODIGO E TIPO DO ROMANEIO DEVEM ESTAR NAS POSIÇÕES 02 E 03 - NAO PODENDO SER AJUSTADA PELO FATO DOS GATILHOS 
		QUE O CAMPO TIPO ALIMENTA. SENDO ASSIM A POSICAO DESSES CAMPOS DEVERA FICAR COMO 05 E 06.*/
		oStruNJJ:AddField("TMP_SERNFT", "05", STR0111, STR0112, {},"C","@!",Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)	 //"Serie NF Tr."##"Série da NF de Transito"
		oStruNJJ:AddField("TMP_NUMNFT", "06", STR0113, STR0114, {},"C","@!",Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)	 //"NF Transito"##"Número da NF de Transito"
	EndIf

	If NJJ->(ColumnPos('NJJ_ORIGEM')) > 0 //Campos do novo romaneio
		oStruNJJ:RemoveField('NJJ_ORIGEM')	
		oStruNJJ:RemoveField('NJJ_EST')
		oStruNJJ:RemoveField('NJJ_DIFFIS')
		oStruNJJ:RemoveField('NJJ_DIFCGC')
		oStruNJJ:RemoveField('NJJ_CGC')
		oStruNJJ:RemoveField('NJJ_TOETAP')
		oStruNJJ:RemoveField('NJJ_DESTPO')
		oStruNJJ:RemoveField('NJJ_ETAPA')
		oStruNJJ:RemoveField('NJJ_DTAGEN')
		oStruNJJ:RemoveField('NJJ_HRAGEN')
		oStruNJJ:RemoveField('NJJ_ITPIMS')

		If FWIsInCallStack("OGA251")
			oStruNJJ:RemoveField('NJJ_NRAGEN')
			oStruNJJ:RemoveField('NJJ_QTDAUT')
		EndIf
	Endif

	If __lnewNeg
		oStruNJJ:RemoveField('NJJ_FILORG')
	EndIf

	///=== Remove campos do view ===/// 
	oStruNJJ:RemoveField( "NJJ_ROMORI" )
	oStruNJJ:RemoveField( "NJJ_TPCLAS" )
	If __lnewNeg
		oStruNJJ:RemoveField( "NJJ_STSCRG" )
	EndIf
	oStruNJK:RemoveField( "NJK_CODROM" )
	oStruNJK:RemoveField( "NJK_RESINF" )
	oStruNK4:RemoveField( "NK4_CODROM" )
	oStruNJM:RemoveField( "NJM_CODROM" )
	oStruNJM:RemoveField( "NJM_TIPO"   )
	If !lChkAgoClas
		oStruNJK:RemoveField( "NJK_TPCLAS" )
	EndIf

    If !fHasGrupo() //se empresa não trabalha com grupo de classificação, remove campo.
        oStruNJK:RemoveField( "NJK_TIPREG" )
    EndIf

	/*
	||=================||
	||  Proteção .23   ||
	||=================||
	*/	

	If __lnewNeg

		If IsIncallstack('OGA250') .AND. !(Empty(_cUNB))
			oStruNJJ:RemoveField( "NJJ_CODUNB" )
		EndIf

		oStruN9E:RemoveField( "N9E_FILIAL" )
		oStruN9E:RemoveField( "N9E_CODROM" )
		oStruN9E:RemoveField( "N9E_SEQUEN" )
		oStruN9E:RemoveField( "N9E_FILIE"  )
		oStruN9E:RemoveField( "N9E_CODAUT"  )
		oStruN9E:RemoveField( "N9E_ITEMAC"  )

		/* Caso não utiliza o novo modelo de negócio não aparesentará os campos referente a Instrução de Embarque, 
		Entrega e Regra fiscal */
		oStruNJM:RemoveField("NJM_CODINE")
		oStruNJM:RemoveField("NJM_FILORG")
	Else
		oStruNJM:RemoveField("NJM_DESINE")
		oStruNJM:RemoveField("NJM_ITEM")
		oStruNJM:RemoveField("NJM_SEQPRI")
		oStruNJJ:RemoveField("NJJ_NUMOP")
		oStruNJJ:RemoveField("NJJ_APONOP")
		oStruNJJ:RemoveField("NJJ_DATCHE")
		oStruNJJ:RemoveField("NJJ_HORCHE")
		oStruNJJ:RemoveField("NJJ_PESEMB")
		oStruNJJ:RemoveField("NJJ_DTULAL")
		oStruNJJ:RemoveField("NJJ_HRULAL")
		oStruNJJ:RemoveField("NJJ_NRAGEN")
		oStruNJJ:RemoveField("NJJ_QTDAUT")
		oStruNJJ:RemoveField("NJJ_QTDFAR")		
		oStruNJM:RemoveField("NJM_LOCLIZ")
		oStruNJM:RemoveField("NJM_CLVL")
		oStruNJM:RemoveField("NJM_NUMCOM")
		oStruNJM:RemoveField("NJM_SERCOM")
		oStruNJM:RemoveField("NJM_CONDCO")
		oStruNJM:RemoveField("NJM_GENMOD")
		oStruNJM:RemoveField("NJM_NMLOT")		

	EndIf

	///=== Define as propriedades dos campos do view ===/// 
	If cFormulario == "N"
		oStruNJM:SetProperty( "NJM_VLRUNI" , MVC_VIEW_CANCHANGE, .T. )
		oStruNJM:SetProperty( "NJM_VLRTOT" , MVC_VIEW_CANCHANGE, .T. )
	EndIf

	If lSimbolico // Se for romaneio simbólico
		oStruNJJ:SetProperty( "NJJ_PSSUBT" , MVC_VIEW_CANCHANGE, .T. )
	Else
		oStruNJJ:SetProperty( "NJJ_PSSUBT" , MVC_VIEW_CANCHANGE, .F. )
	EndIf

	//Campo nao pode ser alteravel
	oStruNJK:SetProperty( "NJK_OBRGT" , MVC_VIEW_CANCHANGE, .F. )

	///////////////////////	
	// Inicializa o View //
	///////////////////////	
	oView:SetModel( oModel )
	oView:AddField( "V250_NJJ", oStruNJJ, "NJJUNICO" )

	oView:AddGrid( "V250_NJK", oStruNJK, "NJKUNICO",,{ || OGA250Gri(oModel,oView)} /*Get Focus*/)

	oView:AddGrid( "V250_NK4", oStruNK4, "NK4UNICO" )
	oView:AddGrid( "V250_NJM", oStruNJM, "NJMUNICO",, )

	If __lnewNeg
		oView:AddGrid( "V250_N9E", oStruN9E, "N9EUNICO" )
	EndIf	

	oView:AddIncrementField( "V250_NJK", "NJK_ITEM" )
	oView:AddIncrementField( "V250_NJM", "NJM_ITEROM" )

	oView:CreateHorizontalBox( "SUPERIOR" , 60 )
	oView:CreateHorizontalBox( "INFERIOR" , 40 )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0018) //"Classificação"
	oView:AddSheet( "GRADES", "PASTA02", STR0082) //"Hist Classificação"
	oView:AddSheet( "GRADES", "PASTA03", STR0019) //"Comercialização"

	If __lnewNeg
		oView:AddSheet( "GRADES", "PASTA04", STR0351) //"Romaneio x Agendamento"
	EndIf	

	oView:CreateHorizontalBox( "PASTA_NJK", 100, , , "GRADES", "PASTA01" )
	oView:CreateHorizontalBox( "PASTA_NK4", 100, , , "GRADES", "PASTA02" )
	oView:CreateHorizontalBox( "PASTA_NJM", 100, , , "GRADES", "PASTA03" )

	If __lnewNeg
		oView:CreateHorizontalBox( "PASTA_N9E", 100, , , "GRADES", "PASTA04" )
	EndIf	

	oView:SetOwnerView( "V250_NJJ", "SUPERIOR" )
	oView:SetOwnerView( "V250_NJK", "PASTA_NJK" )
	oView:SetOwnerView( "V250_NK4", "PASTA_NK4" )
	oView:SetOwnerView( "V250_NJM", "PASTA_NJM" )

	If __lnewNeg
		oView:SetOwnerView( "V250_N9E", "PASTA_N9E" )
	EndIf	

	oView:EnableTitleView( "V250_NJJ" )
	oView:EnableTitleView( "V250_NJK" )
	oView:EnableTitleView( "V250_NK4" )
	oView:EnableTitleView( "V250_NJM" )

	If __lnewNeg
		oView:EnableTitleView( "V250_N9E" )
	EndIf	

	//--					Adicionando Grupos na view						--//
	oStruNJJ:AddGroup( 'GRUPOA', '', '', 1 )
	oStruNJJ:AddGroup( 'GRUPOB', Chr(09), '', 2 )	
	oStruNJJ:AddGroup( 'GRUPOC', Chr(09), '', 3 )
	oStruNJJ:AddGroup( 'GRUPOD', '', '', 4 )

	//-- Atribuindo Todos os Campos ao Grupo D (campos que fica em outras abas) --//
	oStruNJJ:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPOD' )

	//-- Atribuindo os campos ao Grupo A--//
	If lMVOGUSANT .And. !lSimbolico .and. oStruNJJ:HasField("TMP_SERNFT") .and. oStruNJJ:HasField("TMP_NUMNFT")
		oStruNJJ:SetProperty( 'TMP_SERNFT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
		oStruNJJ:SetProperty( 'TMP_NUMNFT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	EndIf

	If cPaisLoc == "ARG" 
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("NJJ_CARTA")
			oStruNJJ:SetProperty( 'NJJ_CARTA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
			oStruNJJ:SetProperty( 'NJJ_CODCTG' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
		EndIf	
	Endif

	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_TIPO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_DSTIPO' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_CODCTR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )
	oStruNJJ:SetProperty( 'NJJ_CODAUT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )

	//-- Atribuindo os campos ao Grupo B --//
	oStruNJJ:SetProperty( 'NJJ_PLACA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODTRA' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMTRA' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODMOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMMOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_CODENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_LOJENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NOMENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_NLJENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTENT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTLOJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTNOM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJJ:SetProperty( 'NJJ_ENTNLJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )

	//-- Atribuindo os campos ao Grupo C --//
	oStruNJJ:SetProperty( 'NJJ_TPFORM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCSER' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCNUM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCEMI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DOCESP' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_CHVNFE' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_QTDFIS' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_VLRUNI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_VLRTOT' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_FRETE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_SEGURO' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_DESPES' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_NFPSER' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_NFPNUM' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_MSGNFS' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_OBS'    , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJJ:SetProperty( 'NJJ_TPFRET' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )


	///=== Define botões da tela ===/// 

	If !lSimbolico .And. IsInCallStack( "OGA250" ) // Se não for romaneio simbólico
		oView:AddUserButton( STR0020, "BALANCA", { | x | OGA250PESA( oModel , "VIEW" ) } ) //"Pesagem" 
		If __lnewNeg
			oView:AddUserButton( STR0348 ,'', { |oModel| AGRA500E(M->NJJ_CODVAR, M->NJJ_TALHAO, M->NJJ_FAZ, M->NJJ_CODROM, M->NJJ_CODENT, M->NJJ_CODSAF, M->NJJ_CODPRO) } ) //"Vincular Fardãos"
		EndIf	
	EndIf
	If ! IsInCallStack( "OGA440" ) .And. ! IsInCallStack( "OGX001VMov" )
		oView:AddUserButton( STR0164, "BMPCONS", { || OGX001Mov( FWFldGet("NJM_IDMOV") ) } ) //"Movimentação" 
	EndIf
	If ! IsInCallStack( "OGX001VCtr" ) 
		oView:AddUserButton( STR0166, "BMPCONS", { || OGX001Ctr( FwxFilial("NJM") ,FWFldGet("NJM_CODCTR") ) } ) //"Contrato" 
	EndIf
	oView:AddUserButton( STR0136, "BMPCONS", { || AGX500GDCF(M->NJJ_CODROM, FWFldGet("NJM_ITEROM"), M->NJJ_FILIAL) } ) //"Docto. Fiscal" 
	If __lLib1221 .And. __lnewNeg
		oView:AddUserButton( STR0339 ,''       , { |oModel| AGRX500AVF(.F., M->NJJ_CODROM) } ) //"Vincular Fardos"
	EndIf

	If __lLib1221 .AND. __lnewNeg  // Se for romaneio simbólico
		oView:AddUserButton(STR0374,'', {|oModel| OG251BDEV(oModel)}) //"Vincular NFs Origem"				
	EndIf

	/* Para não tirar a ordem dos registros do tipo grupo */
	oView:SetViewProperty("V250_NJK", "ENABLENEWGRID")
	oView:SetViewProperty("V250_NJK", "GRIDNOORDER")

	///=== Define métodos do View ===/// 
	oView:SetAfterViewActivate( { | oMod | fAftViewActiv( oMod ) } )
	oView:SetAfterOkButton( {| oMod | fAftOKButton( oMod ) } )
	oView:SetCloseOnOk( {|| .t. } )


	//--	Adicionando Action Para os Campos Abaixo , Pois qdo digitamos os 	--//
	//--  	Vrs. no Field (NJJ) já existe uma Linha adicionada no Grid*(NJM)	--//
	oView:SetFieldAction( 'NJJ_FRETE'	, { |oView| fIniFrete(oView)	} )	
	oView:SetFieldAction( 'NJJ_SEGURO'	, { |oView| fIniSeguro(oView)	} )
	oView:SetFieldAction( 'NJJ_DESPES'	, { |oView| fIniDespes(oView)	} )
	oView:SetFieldAction( 'NJJ_MSGNFS'	, { |oView| fIniMsgNF(oView)	} )
	oView:SetFieldAction( 'NJJ_CODAUT'	, { |oView| fIniCodAut(oView)	} )
	oView:SetFieldAction( 'NJJ_TIPO'    , { |oView| fVldTipo(oView)    } )
	oView:SetViewAction( "BUTTONCANCEL" , {|| OG250ROLL() } )
Return( oView )

/** {Protheus.doc} fAftViewActiv
Função para setar o ambiente na ativação da view, chamada no SetAfterViewActivate()

@param: 	oModel
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	26/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fAftViewActiv( oModel )
	Local oView			:= FwViewActive()

	lF10Exec		:= .f.
	lTemNFTrans	:= .F.


	//--Ajustando Qdo o Grid da NJM, Ganhar e Perder o Foco--//
	oView:GetViewObj("V250_NJM")[3]:obrowse:obrowse:bGotfocus:={||lFcoGrdNjm:=.t.}
	oView:GetViewObj("V250_NJM")[3]:obrowse:obrowse:bLostFocus:={||lFcoGrdNjm:=.f.}


Return NIL

/** {Protheus.doc} fAftOKButton
Função para setar a variavel private lF10Exec de volta para .T., chamada no SetAfterOkButton() da view

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	26/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fAftOKButton( oModel )

	lF10Exec := .t.

Return .T.

/** {Protheus.doc} fVldActivate
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA250 - Romaneio
*/
Static Function fVldActivate( oModel )

	Local nOpc := oModel:GetOperation()

	/* --- Alteração --- */
	If nOpc == MODEL_OPERATION_UPDATE .and.  !FWIsInCallStack("AGRA500Int")
		If NJJ->( NJJ_STATUS ) $ "2|3|4" .and. !lExecAgoClas //2=Atualizado; 3=Confirmado; 4=Cancelado
			Agrhelp(STR0021,STR0108+NJJ->( NJJ_STATUS )+" - "+X3CboxDesc( "NJJ_STATUS", NJJ->( NJJ_STATUS ) ),STR0396 ) //reverMSG//"Somente romaneios atualizados poderão ser reabertos para alteração."
			Return( .F. )
		EndIf
	EndIf

	/* --- Exclusão  --- */
	If nOpc == MODEL_OPERATION_DELETE 
		If .Not. ( NJJ->( NJJ_STATUS ) $ "0|1" ) //0=Pendente; 1=Completo
            //"HELP"##"Operação não permitida para Romaneio com status "
			Agrhelp(STR0021,STR0108+NJJ->( NJJ_STATUS )+" - "+X3CboxDesc( "NJJ_STATUS", NJJ->( NJJ_STATUS ) ),STR0397 )//#AJUDA #Operação não permitida para Romaneios com status #Somente romaneios Pendentes ou Completos poderão ser excluidos.
			Return( .F. )
		EndIf
	EndIf

Return( .T. )


/** {Protheus.doc} PreLGrdNJM
Pre-edição da linha do grid NJM.

@param: 	oGridModel - Grid do modelo de dados
@param: 	nLine - número da linha do grid
@param: 	cAction - "DELETE" / "UNDELETE" / "SETVALUE"
@param: 	cIDField - identificador do campo que está sendo atualizado
@param: 	xValue -  valor que está sendo atribuido
@param: 	xCurrentValue - valor que está atualmente no campo

@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	22/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function PreLGrdNJM(oNJM, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local oNJJ	 := oNJM:GetModel():GetModel( "NJJUNICO" )

	If __lnewNeg .and. !AGRX500FNJM(oNJM, nLine, cAction, cIDField, xValue, xCurrentValue)
		//não verifica se é algodão pois usuario pode alterar o produto
		Return( .F. )
	EndIf

	If cAction == "SETVALUE" .Or. cAction == "DELETE"

		If oNJM:GetValue( "NJM_STAFIS" ) == "2" .and. !lExecAgoClas // Se linha do NJM já possui fiscal
			Help(, , STR0021, , STR0116, 1, 0 ) //"Operação não permitida para Romaneios com itens que já possuam Documento Fiscal."
			//pendente fazer teste para simular //Agrhelp(STR0021,STR0116, "")
			Return( .F. )
		EndIf

		If .Not. Empty( oNJM:GetValue( "NJM_PEDIDO" ) ) .and. !lExecAgoClas // Se linha do NJM já possui pedido de venda
			Help(, , STR0021, , STR0117, 1, 0 ) //"Operação não permitida para Itens de Romaneio que já possuam Pedido de Venda."
			//pendente fazer teste para simular //Agrhelp(STR0021,STR0116, "")
			Return( .F. )
		EndIf

	EndIf

	If cAction == "SETVALUE"
		If oNJJ:GetValue( "NJJ_STATUS" ) $ "2|3"
			If AllTrim(cIDField) $ "NJM_PERDIV,NJM_QTDFCO,NJM_QTDFIS" .and. !lExecAgoClas
				Help(, , STR0021, , STR0122, 1, 0 ) //"Não é permitido alterar quantidades de Romaneio com Status -Atualizado- ou -Confirmado-."
				//pendente fazer teste para simular //Agrhelp(STR0021,STR0116, "")
				Return( .F. )
			EndIf
			If AllTrim(cIDField) $ "NJM_TPFORM,NJM_VLRUNI,NJM_VLRTOT" .and. !lExecAgoClas
				Help(, , STR0021, , STR0131, 1, 0 ) //"Não é permitido alterar este campo em Romaneio com Status -Atualizado- ou -Confirmado-."
				//pendente fazer teste para simular //Agrhelp(STR0021,STR0116, "")
				Return( .F. )
			EndIf
			
		EndIf
		If AllTrim(cIDField) $ "NJM_ITEM" .and. !Empty(xValue)
			DBSelectArea("N9A")
			N9A->(DbSetOrder(1))
			IF !N9A->( dbSeek( xFilial( "N9A" ) + oNJM:GetValue( "NJM_CODCTR" ) + xValue ) )
				Agrhelp(STR0021, STR0398, STR0380 +"'" + AllTrim(RetTitle("NJM_ITEM"))+"'") //#Ajuda #Código invalido. #Informe um item da regra fiscal válido para o campo 
				Return( .F. )
			ElseIf  !Empty(oNJM:GetValue( "NJM_SEQPRI" ))
				IF !N9A->( dbSeek( xFilial( "N9A" ) + oNJM:GetValue( "NJM_CODCTR" ) + xValue + oNJM:GetValue( "NJM_SEQPRI" ) ) )
					IF N9A->( dbSeek( xFilial( "N9A" ) + oNJM:GetValue( "NJM_CODCTR" ) + xValue ) )
						oNJM:SetValue( "NJM_SEQPRI",N9A->N9A_SEQPRI )
					EndIf
				EndIf
			EndIf
		EndIf
		If AllTrim(cIDField) $ "NJM_SEQPRI" .and. !Empty(xValue)
			DBSelectArea("N9A")
			N9A->(DbSetOrder(1))
			IF !N9A->( dbSeek( xFilial( "N9A" ) + oNJM:GetValue( "NJM_CODCTR" ) + oNJM:GetValue( "NJM_ITEM" ) + xValue ) )
				Agrhelp(STR0021,STR0398, STR0380 +"'" + AllTrim(RetTitle("NJM_SEQPRI"))+"'") //#Ajuda #Código invalido. #Informe um item da regra fiscal válido para o campo 
				Return( .F. )
			EndIf
		EndIf
	EndIf

Return( .T. )


/** {Protheus.doc} PreFldNJJ
Pre-edição do structure NJJ.

@param: 	oFieldModel - Field do modelo de dados
@param: 	cAction - "SETVALUE" / "CANSETVALUE"
@param: 	cIDField - identificador do campo que está sendo atualizado
@param: 	xValue -  valor que está sendo atribuido

@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	06/03/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function PreFldNJJ(oNJJ, cAction, cIDField, xValue, xCurrentValue)
	Local oModel    := FwModelActive()
	Local oNJM	    := oModel:GetModel( "NJMUNICO" )
	Local lReturn := .T.
	Local nX     := 0
	Local nLinha := 0

	If cAction == "SETVALUE"		 
		If cIdField == "NJJ_TPFORM" //tipo de formulário próprio ou não.
			If xValue == '1' //SIM
				//limpa os campos
				oNJJ:ClearField("NJJ_DOCESP") 
				oNJJ:ClearField("NJJ_DOCSER")
				oNJJ:ClearField("NJJ_DOCNUM")
				oNJJ:ClearField("NJJ_DOCEMI")
				oNJJ:ClearField("NJJ_CHVNFE")
				oNJJ:ClearField("NJJ_QTDFIS")
				oNJJ:ClearField("NJJ_VLRUNI")
				oNJJ:ClearField("NJJ_VLRTOT")
				//NJM
				For nX := 1 to oNJM:Length() 
					oNJM:GoLine( nX )
					oNJM:ClearField("NJM_DOCESP")
					oNJM:ClearField("NJM_DOCSER")
					oNJM:ClearField("NJM_DOCNUM")
					oNJM:ClearField("NJM_DOCEMI")
					oNJM:ClearField("NJM_CHVNFE")
					oNJM:ClearField("NJM_QTDFIS")
					oNJM:ClearField("NJM_VLRUNI")
					oNJM:ClearField("NJM_VLRTOT")	
				Next nX		
		
			EndIf
		ElseIf cIdField == "NJJ_TIPO" //tipo
			//se o tipo for de saida TEM ter form próprio = 'sim'.
			If xValue $ '2,4,6,8,B'
				oNJJ:SetValue( "NJJ_TPFORM", '1')				
			EndIF 
			oNJJ:SetValue( "NJJ_TES"   , fTrgTpTes( oNJJ, xValue ) )
            

		ElseIf cIdField $ "NJJ_DOCESP|NJJ_MSGNFS" //espécie de documento.			
			//define o campo editado na NJM (itens)
			DO CASE
				CASE cIdField == "NJJ_DOCESP"
					cFldEdit := "NJM_DOCESP" //
				CASE cIdField == "NJJ_MSGNFS"
					cFldEdit := "NJM_MSGNFS"
			ENDCASE
			//replica o valor para o campo editado.
			For nX := 1 to oNJM:Length() 
				oNJM:GoLine( nX )
				oNJM:SetValue( cFldEdit, xValue)
			Next nX		

		ElseIf cIdField == "NJJ_CODCTR" //codigo contrato
			//verifico se o tipo tá preenchido
			If !Empty(xValue)				
				lReturn := OGA330VLD( xValue, oNJJ:GetValue( "NJJ_TIPO" ) )	.and. OGA250VCTR()		
			EndIf

		ElseIf cIdField == "NJJ_STAFIS" .AND. xValue == '2' .AND. !lExecAgoClas // Se linha do NJJ já possui fiscal
			Agrhelp(STR0021, STR0399 , STR0400) //#AJUDA #Operação não permitida #Romaneios com itens que já possuam Documento fiscal
			lReturn := .F.  			
		ElseIf cIdField == "NJJ_CODENT" .AND. __lnewNeg 
			A500ClFld("NJJ_CODENT")
		ElseIf cIdField == "NJJ_INDPRE" 
			nLinha := oNJM:GetLine()
			For nX := 1 to oNJM:Length() 
				oNJM:SetValue( "NJM_INDPRE", xValue) //Presença Comprador (NT 2020.006)
			Next nX		
			oNJM:GoLine( nLinha )	
		ElseIf cIdField == "NJJ_CODA1U" 
			nLinha := oNJM:GetLine()
			For nX := 1 to oNJM:Length() 
				oNJM:SetValue( "NJM_CODA1U", xValue) //Codigo Intermediador (NT 2020.006)	
			Next nX	
			oNJM:GoLine( nLinha )	
		EndIf

		If oNJJ:GetValue( "NJJ_STATUS" ) $ "2|3"
			xValueAnt := oNJJ:GetValue( cIDField )

			If AllTrim(cIDField) $ "NJJ_TPFORM,NJJ_QTDFIS,NJJ_VLRUNI,NJJ_VLRTOT"
				If xValue <> xValueAnt
					Agrhelp(STR0021,STR0401 + DescriSX3(cIDField), STR0131) //#AJUDA #Não é permitido alterar o campo #Não é permitido alterar este campo em Romaneio com Status -Atualizado- ou -Confirmado-. 
					Return( .F. )
				EndIf
			EndIf
		EndIf

	EndIf	

Return( lReturn )

/** {Protheus.doc} fIniPerDiv
Inicialização do campo NJM_PERDIV no grid.

@param: 	oNJM - model ativo
@return:	xReturn - valor para o campo NJM_PERDIV
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniPerDiv( oNJM )
	Local nPerDiv	:= 0
	Local nLinha	:= 0
	Local nX 		:= 0
	Local xReturn := 0

	If oNJM:Length()
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			If .Not. oNJM:IsDeleted()

				nPerDiv += oNJM:GetValue( "NJM_PERDIV" )

			EndIf
		Next nX		
		oNJM:GoLine( nLinha )		
	EndIf

	xReturn := 100 - nPerDiv

Return( xReturn )


/** {Protheus.doc} fIniQtdFco
Inicialização do campo NJM_QTDFCO no grid.

@param: 	oNJM - model ativo
@return:	xReturn - valor para o campo NJM_QTDFCO
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniQtdFco( oNJM )
	Local nQtdFco	:= 0
	Local nLinha	:= 0
	Local nX 		:= 0
	Local xReturn := 0
	Local oNJJ		:= oNJM:GetModel():GetModel( "NJJUNICO" )

	If oNJM:Length() > 0
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			If .Not. oNJM:IsDeleted()

				nQtdFco += oNJM:GetValue( "NJM_QTDFCO" )

			EndIf
		Next nX		
		oNJM:GoLine( nLinha )		
	EndIf
	//Utiliza o valor do novo campo NJJ_PESO3 para os calculos - DAGROGAP-446
	//xReturn := oNJJ:GetValue( "NJJ_PSLIQU" ) - nQtdFco
	xReturn := oNJJ:GetValue( "NJJ_PESO3" ) - nQtdFco

Return( xReturn )

/** {Protheus.doc} fIniFrete
Inicialização do campo NJM_FRETE no grid com 
os dados do campo NJJ_FRETE

@param: 	oNJM - model ativo
@return:	NJM_FRETE Atualizado na View;
@author: 	Emerson Coelho
@since: 	23/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniFrete( oView )
	Local oNJM      := oView:GetModel():GetModel( "NJMUNICO" )

	oNJM:LoadValue('NJM_FRETE', FWFLDGET("NJJ_FRETE") )

	oView:Refresh()
Return( nil )

/** {Protheus.doc} fIniSeguro
Inicialização do campo NJM_SEGURO no grid com 
os dados do campo NJJ_SEGURO

@param: 	oNJM - model ativo
@return:	NJM_SEGURO = Atualizado na View.
@author: 	Emerson Coelho
@since: 	23/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniseguro( oView )
	Local oNJM		:= oView:GetModel():GetModel( "NJMUNICO" )

	oNJM:LoadValue('NJM_SEGURO', FWFLDGET("NJJ_SEGURO") )

	oView:Refresh()

Return( nil )
/** {Protheus.doc} fIniDespes
Inicialização do campo NJM_DESPES no grid com 
os dados do campo NJJ_DESPES

@param: 	oNJM - model ativo
@return:	NJM_DESPES Atualizado na View
@author: 	Emerson Coelho
@since: 	23/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniDespes( oView )
	Local oNJM		:= oView:GetModel():GetModel( "NJMUNICO" )

	oNJM:LoadValue('NJM_DESPES', FWFLDGET("NJJ_DESPES") )

	oView:Refresh()

Return( nil )

/** {Protheus.doc} fIniMsgNf
Inicialização do campo NJM_MSGNFS no grid com 
os dados do campo NJJ_MSGNFS

@param: 	oNJM - model ativo
@return:	NJM_MSGNFS Atualizado na view;
@author: 	Emerson Coelho
@since: 	23/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniMsgNf( oView )
//descontinuado, função tratada no pre valid do NJJ_UNICO.
Return( nil )

/** {Protheus.doc} fIniCodAut
Inicialização do campo NJM_CODAUT no grid com 
os dados do campo NJJ_CODAUT

@param: 	oNJM - model ativo
@return:	NJM_CODAUT Atualizado na view;
@author: 	Gilson Venturi
@since: 	09/05/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fIniCodAut( oView )
	Local oNJM		:= oView:GetModel():GetModel( "NJMUNICO" )

	oNJM:LoadValue('NJM_CODAUT', FWFLDGET("NJJ_CODAUT") )

	oView:Refresh()

Return( nil )
/** {Protheus.doc} fVldTipo
Obtenção dos dados do tipo  

@param:     oNJJ - model ativo
@return:    NJJ_CODENT Atualizado na view;
@author:    Agroindustria
@since:     02/10/2015
@Uso:       OGA250 - Romaneio
*/
Static Function fVldTipo( oView )
	Local oNJJ  := oView:GetModel():GetModel( "NJJUNICO" )

	if FWFLDGET("NJJ_TIPO") == "1" //romaneio por produção
		if empty(FWFLDGET("NJJ_CODENT")) .or. empty(FWFLDGET("NJJ_LOJENT")) //entidade vazia
			//busca a primeira entidade  
			DbSelectArea( "NJ0" ) // Classificaçõe do romaneio
			DbSetOrder( 5 ) //NJ0_FILIAL+NJ0_CLASSE
			If MsSeek( xFilial( "NJ0" ) + cFilAnt ) //filial logada
				oNJJ:SetValue('NJJ_CODENT', NJ0->NJ0_CODENT )
				oNJJ:SetValue('NJJ_LOJENT', NJ0->NJ0_LOJENT )
				oView:Refresh()
			endif 
		endif
	endif     

Return( nil )

/** {Protheus.doc} PosLGrdNJM
Pós validação da linha do grid NJM

@param: 	oNJM - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function PosLGrdNJM( oNJM )
	Local lRetorno	:= .T.
	Local nX      	:= 0
	Local aCposObr 	:= { "NJM_DOCNUM", "NJM_DOCESP", "NJM_DOCEMI", "NJM_QTDFIS", "NJM_VLRUNI", "NJM_VLRTOT" }
	Local oNJJ		:= oNJM:GetModel():GetModel( "NJJUNICO" )
	Local cProduto	:= oNJM:GetValue( "NJM_CODPRO" )
	Local cLote		:= oNJM:GetValue( "NJM_LOTCTL" )	

	If ! __lnewNeg
		If Rastro(cProduto) .And. Empty(cLote)
			Agrhelp(STR0021,STR0402, STR0403 + " - " + POSICIONE("SB1",1,xFilial("NJJ")+cProduto,"B1_DESC") ) //#AJUDA #Produto possui rastro por lote. #Favor informar lote para o produto
			lRetorno := .F.
		EndIf 
	EndIf

	If oNJJ:GetValue( "NJJ_STATUS" ) == "1" .And. lRetorno // 1=Completo
		If .Not. oNJM:IsDeleted() .And. oNJM:GetValue( "NJM_TPFORM" ) == "2" // 2=Não (form. próprio)
			If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //dekalpar não obriga que tenha valor unitário e valor total
				aCposObr 	 := { "NJM_DOCNUM", "NJM_DOCESP", "NJM_DOCEMI" }
			endIF
			For nX := 1 to Len( aCposObr )
				If Empty( oNJM:GetValue( aCposObr[ nX ] ) )
					Agrhelp(STR0021,STR0404, STR0405 + DescriSX3(aCposObr[nX]) ) //#AJUDA #Campo obrigatório não preenchido. #Em caso de formulario de terceiro( nao proprio ), favor prencher o campo 
					lRetorno := .F.
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

Return( lRetorno )


/** {Protheus.doc} PosGrdNJM
Pós validação do grid NJM

@param: 	oNJM - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function PosGrdNJM( oNJM )
	Local lRetorno	:= .t.
	Local oNJJ		:= oNJM:GetModel():GetModel( "NJJUNICO" )
	Local aRet		:= {}
	Local nPerDiv 	:= 0
	Local nQtdFco	:= 0
	Local cProduto	:= oNJM:GetValue( "NJM_CODPRO" )
	Local cLote		:= oNJM:GetValue( "NJM_LOTCTL" )
	Local nX		:= 0
	Local aDecPS	:= {}

	If ! __lnewNeg 
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			If .Not. oNJM:IsDeleted()
				If Rastro(cProduto) .And. Empty(cLote)
					Agrhelp(STR0021,STR0402, STR0403 + cProduto + " - " + POSICIONE("SB1",1,xFilial("NJJ")+cProduto,"B1_DESC") ) //#AJUDA #Produto possui rastro por lote. #Favor informar lote para o produto
					lRetorno := .F.
					Exit
				EndIf 
			EndIf
		Next nX
		oNJM:GoLine( nLinha )
	EndIf
	If oNJJ:GetValue( "NJJ_STATUS" ) = "1" .And. lRetorno

		// Recalcula e atualiza as qtdes dos itens do romaneio
		aRet := fAtuQtdNJM() 	
		nPerDiv := aRet[1] 
		nQtdFco := aRet[2] 

		If nPerDiv <> 100
			If nQtdFco <> oNJJ:GetValue( "NJJ_PSLIQU" )
				aDecPS := StrTokArr(cValtoChar(nQtdFco - oNJJ:GetValue( "NJJ_PSLIQU" )),'.')
				If Len(aDecPS) > 1 .and. nDecPeso < Len(aDecPS[2])
					Agrhelp(STR0021,STR0406 + cValToChar(nPerDiv) + STR0408, STR0407 + STR0543) //#Ajuda #Percentual do rateio por Entidade/Contrato esta em #%. #Ajuste o percentual dos itens do romaneio na aba 'Comercialização' para que totalize em 100%. ## Verifique o parâmetro MV_OGDECPS.
				Else
					Agrhelp(STR0021,STR0406 + cValToChar(nPerDiv) + STR0408, STR0407) //#Ajuda #Percentual do rateio por Entidade/Contrato esta em #%. #Ajuste o percentual dos itens do romaneio na aba 'Comercialização' para que totalize em 100%. 
				EndIf
				lRetorno := .F.
			EndIf
		EndIf

	EndIf

Return( lRetorno )


/** {Protheus.doc} OGA250PNJJ
Pós validação dos fields da NJJ.

@param: 	oNJJ - Enchoice do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250PNJJ()
	Local lRetorno 	:= .t.
	Local nX		:= 0
	Local aCposObr	:= {}
	Local cProduto	:= Alltrim(NJJ->NJJ_CODPRO)
	Local cCpFaltantes := "" 

	If NJJ->NJJ_TIPO == "1" .AND. Empty(SuperGetMV( "MV_ARM251A", .F., "")) 
        AgrHelp(STR0021, STR0539, STR0540) //"Tipo de movimentação de estoque para ordem de produção não encontrada." "Por favor informe o tipo de movimentação no parâmetro MV_ARM251A."
        lRetorno := .F.
    EndIf

    If lRetorno
        If AGRTPALGOD(cProduto)
            //Se produto for algodão - não precisa tratar tabela de classificação
            //aCposObr := { "NJJ_CODSAF", "NJJ_LOCAL", "NJJ_PSSUBT" }
            If NJJ->NJJ_TIPO $ "1|A" .And. __lnewNeg  //Produção/ Entrada por Transferência
                aCposObr := { "NJJ_CODSAF", "NJJ_LOCAL", "NJJ_PSSUBT", "NJJ_CODUNB" }
            Else 
                aCposObr := { "NJJ_CODSAF", "NJJ_LOCAL", "NJJ_PSSUBT" }
            EndIf	
        Else 
            aCposObr := { "NJJ_CODSAF", "NJJ_TABELA", "NJJ_LOCAL", "NJJ_PSSUBT" }
        EndIf 	

        If NJJ->( NJJ_TIPENT ) == "0" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
            If NJJ->NJJ_STATUS = "1"
                For nX := 1 to Len( aCposObr )
                    If Empty( &("NJJ->"+aCposObr[nX]) )
                        If nX > 1
                            cCpFaltantes += ", "
                        EndIf
                        If AGRTPALGOD(cProduto)
                            //Se produto for algodão - não precisa tratar tabela de classificação
                            If NJJ->NJJ_TIPO $ "1|A" //Produção/ Entrada por Transferência
                                cCpFaltantes += DescriSX3(aCposObr[nX])
                            Else
                                cCpFaltantes += DescriSX3(aCposObr[nX])
                            EndIf
                        Else
                            cCpFaltantes += DescriSX3(aCposObr[nX])
                        EndIF              
                        lRetorno := .f.
                    EndIf
                Next nX
                If !lRetorno
                    Agrhelp(STR0021,STR0409, STR0410 +cCpFaltantes ) //#Ajuda #Há campos obrigatórios não informados. #Para fechamento do romaneio informe os campos 
                EndIf
            EndIf
        EndIf
    EndIf

Return( lRetorno )

/** {Protheus.doc} wVldNJJ1

@param:     oNJJ - Enchoice do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Marlon Richard Trettin
@since:     24/01/2015
@Uso:       OGA250 - Romaneio
*/
Static Function wVldNJJ1(tpVld)
	Local lRetorno  	:= .T.
	Local oModel		:= FwModelActive()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )

	If  __lnewNeg
		If IsInCallStack("OGA710") .OR. IsInCallStack("OGA290") .or. IsInCallStack("OGA280") .OR. IsInCallStack("OGA530")
			Return .T.
		EndIf
	EndIf

	// NFP ENTRADA COMPRA FOB PERMITIR INFORMAR QTD FISCAL
    If oNJJ:GetValue("NJJ_TIPO")   == '5' .and. ; //Entrada Compra  
	   oNJJ:GetValue("NJJ_TPFRET")  = 'F' .and. ; //FOB
	   oNJJ:GetValue("NJJ_TPFORM") == '1' .and. ; //Formuluario Propio 1-sim
	   tpVld == '2'
		Return .T.
	EndIf 

	//***Se campos tipo 1
	If tpVld == '1' .or. tpVld == '2'
		If oNJJ:GetValue("NJJ_TPFORM") == '2'
			lRetorno  := .T.
		Else
			lRetorno  := .F.  
		EndIf 

		//***Se campo NJJ_NFPSER e NJJ_NFPNUM
	ElseIf tpVld == '3'  
		If oNJJ:GetValue("NJJ_TPFORM") == '2'
			lRetorno  := .F.
		Else 
			lRetorno  := .T.
		EndIf
	EndIf

Return( lRetorno )


/** {Protheus.doc} wVldNJJ2

@param:     oNJJ - Enchoice do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Marlon Richard Trettin
@since:     24/01/2015
@Uso:       OGA250 - Romaneio
*/
Static Function wVldNJJ2(tpVld)
	Local lRetorno  := .F.
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "NJJUNICO" )

	If tpVld == '1'
		If oNJJ:GetValue("NJJ_TPFORM") == '2' .AND. Alltrim(oNJJ:GetValue("NJJ_DOCESP")) == 'SPED'                               
			lRetorno  := .T. 				
		EndIf 
	ElseIf (tpVld == "NJJ_PESO3" .OR. tpVld == "NJJ_DATCHE" .OR. tpVld == "NJJ_HORCHE") 
		If oNJJ:GetValue("NJJ_TIPO") $ '2|4' .and. lChkAgoClas .and. lExecAgoClas
			lRetorno  := .T. //habilita campo NJJ_PESO3|NJJ_DATCHE|NJJ_HORCHE
		ElseIf oNJJ:GetValue("NJJ_TIPO") = '5' .and. lChkAgoClas .and. (tpVld == "NJJ_DATCHE" .OR. tpVld == "NJJ_HORCHE") 
			lRetorno  := .T. //habilita campo NJJ_DATCHE|NJJ_HORCHE
		ElseIf FwIsInCallStack("AGRA500E")
			lRetorno  := .T.  //vinculo fardao, habilita para setar desconto embalagem
		ElseIf FwIsInCallStack("OGX290NFUT")
			lRetorno  := .T.
		EndIf
	EndIf
Return( lRetorno )

/** {Protheus.doc} GrvModelo
Funcao para gravar dados adicionais e o modelo de dados

@param:     oModel - Modelo de Dados
@return:    .t.
@author:    Equipe AgroIndustria
@since:     01/01/2015
@Uso:       OGA250 – Romaneio
@Ponto de Entrada: Bruna Rocio
@Data: 25/08/2014
*/
Static Function GrvModelo( oModel )
	Local aAreaAtu		:= GetArea()
	Local aAreaNNI      := NNI->( GetArea() )
	Local lRetorno		:= .T.
	Local lRecLock		:= .F.
	Local nLinha		:= 0
	Local nCount		:= 0
	Local nRegNJJ		:= 0
	Local nX			:= 0
	Local nOperation	:= oModel:GetOperation()
	Local oModelNJJ   	:= oModel:GetModel( "NJJUNICO" )
	Local oModelNJM   	:= oModel:GetModel( "NJMUNICO" )
	Local oMldDX0		:= oModel:GetModel( "AGRA500_DX0" )
	Local lSimbolico	:= ( oModelNJJ:GetValue( "NJJ_TIPENT" ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
	
	Private _cUNB       := A655GETUNB( )

	If lRetorno .And. (ExistBlock("OGA250GRV"))
		lRetorno := ExecBlock("OGA250GRV",.F.,.F.,{oModel,"PosModelo","OGA250"})
	EndIf

	If __lnewNeg
		If lExecAgoClas
			oModelNJM:SetNoUpdateLine(.F.)
		EndIf
	EndIf
	If lRetorno
		If __lnewNeg .AND. oMldDX0:Length() > 1 	
			//Caso tenha fardões vinculados e o romaneio seja de entrada 
			A500EATDX0()
			
			A500ESTT(oMldDX0)
			
		EndIf	
		// Gravar Histórico Automaticamente
		If nOperation == MODEL_OPERATION_INSERT
			AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+oModelNJJ:Getvalue('NJJ_CODROM'),"3",STR0008})// Incluir
		elseIf nOperation == MODEL_OPERATION_DELETE
			AGRGRAVAHIS(,,,,{"NJJ",NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM,"5",STR0012}) //Excluir
		Endif

		If (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE) .And. !lSimbolico
			OGA245AtRom( NJJ->( Recno() ) , .f.) // .f. Remove vinculo da ordem de transito para mais abaixo apos commit, se insert ou update, atualizar o número do romaneio na Ordem de Trânsito vinculada (se houver)
		EndIf

		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

			nLinha := oModelNJM:GetLine()
			For nX := 1 to oModelNJM:Length()
				oModelNJM:GoLine( nX )
				If .Not. oModelNJM:IsDeleted()
					//*GRAVA O TIPO DO ROMANEIO
					oModelNJM:LoadValue("NJM_TIPO" , oModelNJJ:GetValue('NJJ_TIPO') )
					If __lnewNeg
						If !Empty(oModelNJM:GetValue('NJM_CODCTR'))					
							oModelNJM:LoadValue("NJM_FILORG", xFilial("NJR"))
						EndIf

						If empty(oModelNJM:GetValue('NJM_SUBTIP'))
							oModelNJM:SetValue("NJM_SUBTIP" , oModelNJJ:GetValue('NJJ_TIPO') + '0')
						EndIf
					EndIf		
				EndIF
			Next nX
			oModelNJM:GoLine( nLinha )

			DbSelectArea("NNI")
			NNI->(DbSetOrder(1))
			NNI->(Dbseek(xFilial("NNI")+oModelNJJ:Getvalue('NJJ_TABELA')))
			//se qualidade = 1 (nao) 
			If NNI->NNI_QLDANA =='1'		
				//o status do parecer fica como não se aplica
				oModelNJJ:LoadValue('NJJ_LIBQLD', '0')  
				lRetorno := .T.
				//se tipo do romaneio for igual a entrada e qualidade for igual a saída
			ElseIf oModelNJJ:Getvalue('NJJ_TIPO') $ '1|3|5|7|9' .and. NNI->NNI_QLDANA =='3'
				//o status do parecer fica como não se aplica
				oModelNJJ:LoadValue('NJJ_LIBQLD', '0')  
				lRetorno := .T.
				//se tipo do romaneio for igual a saída e qualidade for igual a entrada
			ElseIf oModelNJJ:Getvalue('NJJ_TIPO') $ '2|4|6|8' .and. NNI->NNI_QLDANA =='2'
				//o status do parecer fica como não se aplica
				oModelNJJ:LoadValue('NJJ_LIBQLD', '0')  
				lRetorno := .T.
				//se qualidade = 4 entrada/saida 
				//ElseIf NNI->NNI_QLDANA =='4'		
				//o status do parecer fica como requer parecer 
				//   	oModelNJJ:LoadValue('NJJ_LIBQLD', '4')  
				//   	lRetorno := .T.
			EndIf 
		EndiF

		// Se for Exclusão
		IF nOperation == MODEL_OPERATION_DELETE	    

			// Atualiza os dados do romaneio na NF relacionada, em caso de romaneio simbólico
			OGA251Del( NJJ->( Recno() ) ) 

			If __lnewNeg	
				//Ao excluir um romaneio NJJ, exclur também os movimentos de fardos N9D (com transação 07-romaneio e 08-trânsito) e integrações romaneio N9E. 
				DBSelectArea("N9D")
				N9D->(DbSetOrder(6))
				N9D->(DbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM))
				While N9D->(!Eof()) .AND. NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM == N9D->N9D_FILORG+N9D->N9D_CODROM
					If N9D->N9D_TIPMOV $ "08"
						RecLock("N9D",.F.)
						N9D->(DbDelete())
						N9D->(MsUnlock())
					EndIf
					N9D->(DbSkip())
				EndDo
			EndIf

			If NJJ->(FieldPos("NJJ_CODTRF") > 0)			
				//se for Rom de Transferencia, atualizo o status. 
				If !Empty(NJJ->NJJ_CODTRF) 
					//limpar o rom.
					If Empty(NJJ->NJJ_SEQTRF) //se for de origem
						DbSelectArea('NBU')
						NBU->(DbSetOrder(1))
						If NBU->(DbSeek(xFilial('NBU')+NJJ->( NJJ_CODTRF )))	
							While NBU->(!Eof())
								If RecLock("NBU", .F.)														
									NBU->( NBU_ROMDEV) := ""
									NBU->( NBU_DATDEV) := STOD("")
									NBU->( NBU_TESDEV) := ""					
								NBU->(MsUnlock())
								EndIf	
							NBU->(DbSkip())
							Enddo				
						EndIf
					Else
						DbSelectArea('NBU')
						NBU->(DbSetOrder(1))
						If NBU->(DbSeek(xFilial('NBU')+NJJ->( NJJ_CODTRF )+ALLTRIM(NJJ->( NJJ_SEQTRF ))))					
							If RecLock("NBU", .F.)														
								NBU->( NBU_ROMDES) := ""
								NBU->( NBU_DATTRF) := STOD("")
								NBU->( NBU_TESTRF) := ""					
							NBU->(MsUnlock())
							EndIf					
						EndIf
					EndIf

					OGA455STS(NJJ->NJJ_CODTRF)
		
				EndIf 
			EndIf

		EndIF	
		
        If IsIncallstack('OGA250')
            If !(Empty(_cUNB)) .AND. (nOperation == MODEL_OPERATION_INSERT .OR. INCLUI)
                oModel:SetValue('NJJUNICO', 'NJJ_CODUNB', _cUNB)				
            EndIf					
        EndIf        
        
        //Atualiza DXI
        If __lnewNeg
            If !Empty(oModelNJJ:GetValue('NJJ_CODCTR')) .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
                oModel:SetValue('NJJUNICO', 'NJJ_FILORG', xFilial("NJR"))
            EndIf

            If lRetorno .And. ( (Type("_lVincFard") != "U" .And. _lVincFard) .OR. nOperation == MODEL_OPERATION_DELETE )	
                //atualiza dados referente aos fardos 
                AGRX500FCM(oModel)	
            EndIf
        EndIf

        If nOperation = MODEL_OPERATION_DELETE
            aAreaNJJ := NJJ->(GetArea())

            DbSelectArea("NJJ")
            NJJ->(DbSetOrder(1)) // NJJ_FILIAL+NJJ_CODROM
            If NJJ->(DbSeek(FWxFilial("NJJ")+oModelNJJ:GetValue("NJJ_CODROM")))
                If RecLock("NJJ", .F.)
                    NJJ->NJJ_DTULAL := dDatabase
                    NJJ->NJJ_HRULAL := Time()
                    NJJ->(MsUnlock())
                EndIf
            EndIf

            RestArea(aAreaNJJ)
        EndIf
		
		lRetorno := FWFormCommit( oModel )

		RestArea( aAreaNNI )

		// Grava Historico de Classificações do Romaneio
		For nCount := 1 to LEN( aVetNK4 )

			dbSelectArea( 'NK4' )
			NK4->(dbSetOrder( 1 )) // NK4_FILIAL+NK4_CODROM+STR(NK4_SEQCLA,3,0)+NK4_ITEM
			If !NK4->(DbSeek( FwxFilial("NK4") + aVetNK4[nCount,2] + STR(aVetNK4[nCount,3],3,0) + aVetNK4[nCount,4] ))
				If RecLock('NK4', .t.)
					NK4->( NK4_FILIAL ) := FwxFilial("NK4") //aVetNK4[nCount,  1]
					NK4->( NK4_CODROM ) := aVetNK4[nCount,  2]
					NK4->( NK4_SEQCLA ) := aVetNK4[nCount,  3]
					NK4->( NK4_ITEM )   := aVetNK4[nCount,  4]
					lRecLock := .T.
				EndIf
			Else
				If RecLock('NK4', .F.)
					lRecLock := .T.
				EndIf
			EndIf
			If lRecLock
				NK4->( NK4_CODDES ) := aVetNK4[nCount,  5]
				NK4->( NK4_BASDES ) := aVetNK4[nCount,  7]
				NK4->( NK4_PERDES ) := aVetNK4[nCount,  8]
				NK4->( NK4_READES ) := aVetNK4[nCount,  9]
				NK4->( NK4_QTDDES ) := aVetNK4[nCount, 10]
				NK4->( NK4_DESRES ) := aVetNK4[nCount, 11]
				NK4->( NK4_TABALT ) := aVetNK4[nCount, 12]
				NK4->( NK4_PROALT ) := aVetNK4[nCount, 13]				
				MsUnlock()
				lRecLock := .F.
			EndIf				

		Next nCount	

		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 

			dbSelectArea( "NJJ" ) // Romaneios
			dbSetOrder( 1 ) 
			nRegNJJ := NJJ->( Recno() )

			If lMVOGUSANT .And. !lSimbolico //se parametro de uso nf de transito
				OGA245AtRom( nRegNJJ, IIF( Empty(oModelNJJ:Getvalue('NJJ_NFPSER')) .AND. Empty(oModelNJJ:Getvalue('NJJ_NFPNUM')) , .F. , .T. ) ) // Atualiza o número do romaneio na Ordem de Trânsito vinculada (se houver)
			EndIf

			If lExecAgoClas //se esta alterando o NJJ_PESO apos romaneio confirmado - UPDATE
				//Atualiza a quantidade e o saldo do contrato 
				atuQtdSldCtr()

				If __lnewNeg .and. __lLib1221 .and. NJJ->( NJJ_TIPO ) $ "2|4" .and. AGRTPALGOD(NJJ->( NJJ_CODPRO ))//romaneio de venda e produto algodao
					// Realiza o rateio dos fardos para informar o peso de chegada
					MsgRun(STR0361, STR0347 , {|| lRetorno := OG250BRPFA(NJJ->(NJJ_CODROM), 2)}) // Atualizando peso de chegada dos fardos ## Aguarde

					If lRetorno 
						// Atualiza o movimento dos fardos (08 - Em trânsito)
						OG250EATMF(.T., '08', NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, NJJ->NJJ_DATCHE)
					EndIf					
				EndIf
				If __lnewNeg																	
					// Atualiza data de chegada tabela relacionada remessa formação de lote x ie
					OG250HTRIE(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, NJJ->NJJ_DATCHE)											
				EndIf
			EndIf

		EndIf

	Endif

	lF10Exec := .t.
	_lVincFard := .F. 

	RestArea( aAreaAtu )
	
Return( lRetorno )

/** {Protheus.doc} fVldNFTrans
Validação dos campos Serie e Número de NF Transito 

@param: 	oParModel - modelo de dados
@return:	.T. / .F.
@author: 	Marlon Richard Trettin
@since: 	05/01/15
@Uso: 		OGA250
*/
Static Function fVldNFTrans( oParModel )

	Local oModel		:= FwModelActive()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local oView			:= FwViewActive()
	Local cSerNFT		:= oNJJ:GetValue( "TMP_SERNFT" )
	Local cNumNFT		:= oNJJ:GetValue( "TMP_NUMNFT" )
	Local _NJJNFPSER	:= oNJJ:GetValue( "NJJ_NFPSER" )
	Local _NJJNFPNUM	:= oNJJ:GetValue( "NJJ_NFPNUM" )

	lTemNFTrans  := .F.

	If !Empty( cSerNFT ) .Or. !Empty( cNumNFT ) 
		DbSelectArea( "NK2" ) // Ordens de Transito
		NK2->(DbSetOrder( 2 )) //NK2_FILIAL+NK2_SERNFT+NK2_NUMNFT
		If NK2->(DbSeek( xFilial( "NK2" ) + cSerNFT + cNumNFT ))

			//Seta a flag que utiliza NF de Transito para .T., para depois buscar o tipo do romaneio de acordo com o tipo de contrato
			lTemNFTrans  := .T.

			If _NJJNFPSER <> cSerNFT .Or. _NJJNFPNUM <> cNumNFT

				If NK2->( NK2_STATUS ) == '2' //2=NFT Emitida

					If oNJM:LENGTH() == 0 // Se não possuir nenhuma linha no grid

						oNJM:AddLine() // Insere uma linha

					Else // Senão, se já possui uma linha no grid, posiciona nela

						oNJM:GoLine( 1 )

					EndIf

					oNJJ:SetValue( "NJJ_CODCTR",  NK2->( NK2_CODCTR ) )
					oNJJ:SetValue( "NJJ_CODAUT", "")
					oNJJ:SetValue( "NJJ_PLACA",  NK2->( NK2_PLACA ) )
					oNJJ:SetValue( "NJJ_CODMOT", NK2->( NK2_CODMOT ) )
					oNJJ:SetValue( "NJJ_CODTRA", NK2->( NK2_CODTRA ) )
					oNJJ:SetValue( "NJJ_CODENT", NK2->( NK2_CODENT ) )
					oNJJ:SetValue( "NJJ_LOJENT", NK2->( NK2_LOJENT ) )
					oNJJ:SetValue( "NJJ_ENTENT", NK2->( NK2_CODENT ) )
					oNJJ:SetValue( "NJJ_ENTLOJ", NK2->( NK2_LOJENT ) )
					oNJJ:SetValue( "NJJ_NFPSER", NK2->( NK2_SERNFT ) )
					oNJJ:SetValue( "NJJ_NFPNUM", NK2->( NK2_NUMNFT ) )
					oNJJ:SetValue( "NJJ_CODSAF", NK2->( NK2_CODSAF ) )

					oNJM:SetValue( "NJM_CODCTR", NK2->( NK2_CODCTR ) )
					oNJM:SetValue( "NJM_CODENT", NK2->( NK2_CODENT ) )
					oNJM:SetValue( "NJM_LOJENT", NK2->( NK2_LOJENT ) )
					oNJM:SetValue( "NJM_NFPSER", NK2->( NK2_SERNFT ) )
					oNJM:SetValue( "NJM_NFPNUM", NK2->( NK2_NUMNFT ) )
					oNJM:SetValue( "NJM_PERDIV", 100 )
					oView:Refresh()

				Else
					Agrhelp(STR0021,STR0201 + X3CboxDesc( "NK2_STATUS", NK2->( NK2_STATUS ) ),STR0411 ) //#AJUDA #Nota de Trânsito e Série associado a uma Ordem de Transito com Status = A ordem de transito deve estar com status igual a 2=NFT Emitida.
					Return .F. 
				EndIf
			EndIf

		Else
			Agrhelp(STR0021, STR0202 + cNumNFT + " - " + cSerNFT , STR0412) //#Ajuda #Nota de Trânsito e Série não encontrada. #Informe uma nota de transito valida.
			Return .F. 
		EndIf

	EndIf

Return .T. 

/** {Protheus.doc} fTrgPlaca
Gatilho no campo Placa que busca o código do motorista

@param: 	oParModel - modelo de dados
@return:	cCodMot
@author: 	Marlon Richard Trettin
@since: 	25/09/14
@Uso: 		OGA250
*/
Static Function fTrgPlaca( oParModel )

	Local oModel		:= oParModel:GetModel()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local oView			:= FwViewActive()
	Local cPlaca		:= oNJJ:GetValue( "NJJ_PLACA" )
	Local cCodMot		:= oNJJ:GetValue( "NJJ_CODMOT" )

	If !Empty( cPlaca ) .And. !lTemNFTrans

		dbSelectArea( "DA3" ) // Cadastro de veículos
		DA3->(dbSetOrder( 1 ))
		If DA3->(dbSeek( xFilial( "DA3" ) + cPlaca ))

			cCodMot := DA3->( DA3_MOTORI )

		EndIf

		oNJJ:SetValue( "NJJ_CODMOT", cCodMot )
		IF valType(oView) == 'O' .AND. oView:ACURRENTSELECT[1] == "V250_NJJ"
			oView:Refresh()
		EndIF
	EndIf

Return( cCodMot )


/** {Protheus.doc} OGA250VCTR
Valida contrato para romaneios Fisicos e Simbólicos. Chamado do X3_VALID do campo NJM_CODCTR.

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VCTR()
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR 		:= NJR->( GetArea() )
	Local aAreaNNY 		:= NNY->( GetArea() )
	Local lRetorno 		:= .t.
	Local lCadenciaFis  := .t.
	Local oModel		:= FwModelActive()
	Local nLinha		:= 0
	Local nX			:= 0

	Local oNJJ			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local cTipo			:= oNJJ:GetValue( "NJJ_TIPO" )
	Local cCodSaf		:= oNJJ:GetValue( "NJJ_CODSAF" )
	Local cTabela		:= oNJJ:GetValue( "NJJ_TABELA" )

	Local oNJM			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJM" ), oModel:GetModel( "NJMUNICO" )) //Protecao para usar funcao via AGRA500 
	Local cCodCtr		:= oNJM:GetValue( "NJM_CODCTR" )	

	If .Not. Empty( cCodCtr )
		dbSelectArea( "NJR" )
		NJR->(dbSetOrder( 1 ))
		If .Not. NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ))
			Agrhelp(STR0021,STR0413 + cCodCtr + STR0414,STR0415 ) //#AJUDA #Contrato #informado não existe. #Informe um contrato valido.
			lRetorno := .f.
		Else
			// Se tipo do contrato for incompatível com tipo do romaneio
			If NJR->( NJR_TIPO ) <> OGX010TC( cTipo )  
				Agrhelp(STR0021,STR0123 + X3CboxDesc( "NJR_TIPO", NJR->( NJR_TIPO ) ), STR0416 + Alltrim(FWGetSX5("K5",cTipo)[1][4]) ) //#AJUDA #O Contrato informado não pode ser utilizado neste romaneio, pois é um contrato do tipo #Informe um contrato do tipo 
				lRetorno := .f.
			EndIf

			// FOI AJUSTADO A CONSULTA DO NJJ_CODCTR, POR ISSO, NÃO PRECISA MAIS DAS VALIDAÇÕES QUE TINHAM!
			If lRetorno
				// Verifica se o contrato possui cadência Física
				dbSelectArea( "NNY" )
				NNY->(dbSetOrder( 1 ))		
				NNY->(dbSeek( xFilial( "NNY" ) + cCodCtr))
				While .Not. NNY->( Eof() ) .And. NNY->( NNY_FILIAL ) + NNY->( NNY_CODCTR ) == xFilial( "NNY" ) + cCodCtr
					If NNY->( NNY_TIPENT ) == '1' //Gerencial
						lCadenciaFis := .f.
					Endif
					NNY->( dbSkip() )
				EndDo
				If .Not. lCadenciaFis
					Agrhelp(STR0021, STR0536,STR0417  + cCodCtr + STR0092 ) //reverMSG //#AJUDA #Somente contratos que possuem cadência do tipo -Física- podem ser utilizados neste romaneio. #Retire o contrato:
					lRetorno := .f.
				Endif
                If lRetorno
				// Se possui nota de transito
					If lTemNFTrans
						If NJR->( NJR_TIPO ) == "1" ; cTipo := "5"
						ElseIf NJR->( NJR_TIPO ) == "2" ; cTipo := "4"
						ElseIf NJR->( NJR_TIPO ) == "3" ; cTipo := "3"
						ElseIf NJR->( NJR_TIPO ) == "4" ; cTipo := "2"
						EndIf
						oNJJ:SetValue( "NJJ_TIPO"	, cTipo )
					EndIf		
					cCodSaf := NJR->( NJR_CODSAF )
					cTabela := NJR->( NJR_TABELA )					

					If NJR->( NJR_CODSAF ) <> cCodSaf .And. !Empty( cCodSaf )
						Agrhelp(STR0021, STR0418 + cCodSaf + STR0419 + NJR->( NJR_CODSAF ) + STR0420, STR0421) //#AJUDA #A safra do romaneio #e a safra do contrato #não coincidem. #Romaneio e contrato devem ter a mesma safra.
						lRetorno := .f.
					ElseIf NJR->( NJR_TABELA ) <> cTabela .And. !Empty( cTabela )
							Agrhelp(STR0021, STR0422 + cTabela + STR0423 + NJR->( NJR_TABELA ) + STR0420, STR0425) //#AJUDA #A Tabela do romaneio # e a tabela do contrato #não coincidem. #Romaneio e contrato devem ter a mesma tabela.
							lRetorno := .f.
					EndIf
			    EndIf
		    EndIf
	   EndIf
    EndIf
	If lRetorno

		/////////////////////////////////////////////
		// Atualiza status de contrato do romaneio
		/////////////////////////////////////////////
		oNJJ:SetValue( "NJJ_STACTR"	, '2' ) //2=Com CTR

		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )

			// Se algum item do romaneio NÃO tem contrato, passa o status para 1=Sem CTR
			If Empty( oNJM:GetValue( "NJM_CODCTR" ) )
				oNJJ:SetValue( "NJJ_STACTR"	, '1' ) //1=Sem CTR
			EndIf
		Next nX
		oNJM:GoLine( nLinha )

	EndIf

	RestArea( aAreaNNY )
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} OGA250VTAB
Função para validação do código da tabela de descontos e carregar o gride de classificação
Chamada do valid do campo NJJ_TABELA

@param: 	Nil
@return:	lRetorno - .T. ou .F.
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VTAB( )
	Local lRetorno 		:= .t.
	Local aAreaAtu 		:= GetArea()
	Local oModel		:= FwModelActive()
	Local oFldNJJ		:= IIF(IsInCallStack("AGRA500") , oModel:GetModel("AGRA500_NJJ" ), IIF(IsInCallStack("AGRA550") .OR. IsInCallStack("AGRA550_01") .OR. FwIsInCallStack("AGRA550_02") .OR. FwIsInCallStack("AGRA550_02") .OR. IsInCallStack("OGWSPUTATU") ,oModel:GetModel('AGRA550_NJJ'), oModel:GetModel( "NJJUNICO" ))) //Protecao para usar funcao via AGRA500
	Local oGrdNJK		:= IIF(IsInCallStack("AGRA550") .OR. IsInCallStack("AGRA550_01") .OR. FwIsInCallStack("AGRA550_02") .OR. IsInCallStack("OGWSPUTATU"),oModel:GetModel('AGRA550_NJK'),oModel:GetModel("NJKUNICO"))
	Local cProduto		:= oFldNJJ:GetValue( 'NJJ_CODPRO' )
	Local cTabela		:= oFldNJJ:GetValue( "NJJ_TABELA" )
	Local oView			:= FWViewActive()
	Local nX			:= 0
	Local cRomaneio  	:= oFldNJJ:GetValue( "NJJ_CODROM" )
	Local nSequencia 	:= 0
	Local aDescont		:= {}   // Array que Irá conter : { Cod.Classificação,Resultado Classif,Se foi informado ou não }
	Local nOperation	:= oModel:GetOperation()

	////////////////////
	// Popula o array de histórico de classificações do romaneio (aNK4)
	////////////////////
	aVetNK4 := {}

	//Validação para alteração [Parecer Qualidade]
	If nOperation == MODEL_OPERATION_UPDATE 
		If !Empty(oFldNJJ:Getvalue('NJJ_QPAREC'))
			DbSelectArea( 'NKJ' )
			NKJ->(DbSetOrder( 1 ))
			If NKJ->(dbSeek( xFilial('NKJ')+oFldNJJ:Getvalue('NJJ_QPAREC')))
				If NKJ->NKJ_LIBQLD == '1'	//1=SIM 
					Help(, , STR0021, , STR0203, 1, 0 )	//"AJUDA"###"Esse romaneio esta aprovado pelo parecer da qualidade. Não pode ser alterado tabela e/ou classificação."
					//#TESTAR - Fazer teste para descobrir como funciona //Agrhelp(STR0021,STR0058, STR0059) 
					lRetorno := .F.	
				EndIf 
			EndIf 
		EndIf
	EndIf

	dbSelectArea( 'NK4' )
	NK4->(dbSetOrder( 1 ))
	If NK4->(dbSeek( xFilial('NK4') + cRomaneio ))
		While !NK4->(Eof()) .And. NK4->NK4_FILIAL + NK4->NK4_CODROM == xFilial('NK4') + cRomaneio
			nSequencia := NK4->( NK4_SEQCLA )
			NK4->(DbSkip())
		EndDo		
	EndIf

	/**
	Se já existem descontos anteriormente cadastrados para o romaneio
	**/

	oGrdNJK:SetNoInsert( .f. )
	oGrdNJK:SetNoDelete( .f. )

	nSequencia += 1	

	dbSelectArea( 'NNI' ) // Tabelas de descontos
	NNI->(dbSetOrder( 1 ))
	If NNI->(dbSeek( xFilial( 'NNI' ) + cTabela ))
		If !Empty( NNI->( NNI_CODPRO ) )
			If cProduto <> NNI->( NNI_CODPRO )
				Agrhelp(STR0021,cProduto + " - " + POSICIONE("SB1",1,xFilial("NJJ")+cProduto,"B1_DESC") + STR0426 + cTabela,STR0427 ) //reverMSG //#AJUDA #não é compatível com produto da tabela #Favor informar um produto válido.
				lRetorno := .F.
			EndIf
			If NNI->(NNI_QLDANA) == '1'
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "0" )
			ElseIf NNI->(NNI_QLDANA) $ "2|3|4"
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "3" )
			EndIf
		Else	
			//verifica na tabela de produto pelo grupo se o grupo é existente
			//se grupo não existir apresenta mensagem para informar o grupo
			cGrupo := ''
			dbSelectArea( 'SB1' )
			SB1->(dbSetOrder( 1 ))
			SB1->(dbSeek( xFilial('SB1') + cProduto))
			cGrupo := SB1->( B1_GRUPO )
			If NNI->( NNI_PRODGR ) <> cGrupo
				Agrhelp(STR0021,cProduto + POSICIONE("SB1",1,xFilial("NJJ")+cProduto,"B1_DESC") +STR0428+ NNI->( NNI_PRODGR ) +STR0429 + cTabela, STR0427) 
				//#AJUDA # não faz parte do grupo # de produto informado na tabela #Favor informar um produto válido.
				lRetorno := .F.
			EndIf 
			If NNI->(NNI_QLDANA) == '1'
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "0" )
			ElseIf NNI->(NNI_QLDANA) $ "2|3|4"
				oFldNJJ:LoadValue( "NJJ_LIBQLD", "3" )
			EndIf
		EndIf 
		IF lRetorno
			// Apos Validar a Tabela, Limpo o Grid Caso já tenha descontos ref. a uma outra tabela //
			//oGrdNJK:ClearData()  comentado 18/01/16, pois ao trocar tabela de descontos, ocorre erro.
			For nX := 1 to oGrdNJK:Length()
				oGrdNJK:GoLine( nX )
				If !oGrdNJK:IsDeleted()
					// ADescont Utilizado na Troca de tabela para aproveitar o resultado, e se o resultado foi informado par aum item do desconto
					aAdd( aDescont, { oGrdNJK:GetValue( "NJK_CODDES" ), oGrdNJK:GetValue( "NJK_PERDES" ), oGrdNJK:GetValue( "NJK_RESINF") } )
					If Empty(oGrdNJK:GetValue( "NJK_ITEM" ))
						Exit
					Else 
						aAdd( aVetNK4, { xFilial('NJK'), cRomaneio, nSequencia, oGrdNJK:GetValue( "NJK_ITEM" ), ;
						oGrdNJK:GetValue( "NJK_CODDES" ), " " , oGrdNJK:GetValue( "NJK_BASDES" ),  ; 
						oGrdNJK:GetValue( "NJK_PERDES" ), oGrdNJK:GetValue( "NJK_READES" ), oGrdNJK:GetValue( "NJK_QTDDES" ),  ;
						oGrdNJK:GetValue( "NJK_DESRES" ), cTabela, ;
						oFldNJJ:GetValue( 'NJJ_CODPRO' )})

						oGrdNJK:LoadValue( "NJK_PERDES", 0 )		
						oGrdNJK:DeleteLine()
					EndIf
				EndIf	
			Next nX

			ItensClass(aDescont)

			//Seta o status da classificacao como não classificado
			oFldNJJ:SetValue( "NJJ_STSCLA", "0" )		
		EndIF
	Else
		Agrhelp(STR0021,STR0430+ cTabela + STR0431, STR0432) //#AJUDA #A tabela # não está cadastrada. #Favor informar uma tabela válida.
		lRetorno := .f.
	EndIf

	oGrdNJK:SetNoInsert( .t. )
	oGrdNJK:SetNoDelete( .t. )
	oGrdNJK:GoLine( 1 )


	IF !Type('oView') == 'U' .And. IsInCallStack("OGA250")	//Tratamento para Execauto, ( a View não Existe no Execauto)
		oView:Refresh("V250_NJK")
	EndIF

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} fTrgQtdFis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
Gatilho para atribuir a quantidade fiscal (NJJ_QTDFIS) ao peso subtotal (NJJ_PSSUBT) em caso de romaneio simbolico

@param: 	Nil
@return:	nPsSubt - Peso subtotal
@author: 	Marlon Richard Trettin
@since: 	05/05/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fTrgQtdFis( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )

	oNJJ:SetValue( "NJJ_PSSUBT", oNJJ:GetValue( "NJJ_QTDFIS" ) )

Return( oNJJ:GetValue( "NJJ_QTDFIS" ) )

/** {Protheus.doc} fTrgQtdFia
Gatilho para atribuir  peso subtotal (NJJ_PSSUBT) a quantidade fiscal (NJM_QTDFIS) em caso de romaneio simbolico

@param: 	Nil
@return:	nPsSubt - Peso subtotal
@author: 	Marcelo Wesan
@since: 	29/05/2017
@Uso: 		OGA250 - Romaneio

*/
Static Function fTrgQtdFia( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local nRetorno 		:= 0 

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "5"
		nRetorno := oNJJ:GetValue( "NJJ_PESO3" )
	Else
		nRetorno := oNJJ:GetValue( "NJJ_PSSUBT" )
	EndIf	
Return( nRetorno )

/** {Protheus.doc} fTrgPesoLiq
Gatilho para recalcular quantidades de desconto e retornar o Peso Liquido (NJJ_PSLIQU)

@param: 	Nil
@return:	nPsLiqu - Peso liquido para o romaneio
@author: 	Marlon Richard Trettin
@since: 	05/05/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fTrgPesoLiq( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local nRetorno		:= 0
	Local lSimbolico	:= ( oNJJ:GetValue( "NJJ_TIPENT" ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
	Local nPsSubt		:= oNJJ:GetValue( "NJJ_PSSUBT" )
   
	// Calcula os descontos
	OGA250ATUG()

	//Carrega o novo campo NJJ_PESO3 com o valor do campo NJJ_PSLIQU - DAGROGAP-446
	oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_PSLIQU" ) ) 

 	//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM
	IF _lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue("NJJ_TPFRET") = 'F' .and. oNJJ:GetValue( "NJJ_TPFORM" ) == "1"
	   oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_QTDFIS" ) ) 
	EndIf
		
	// Se for romaneio simbólico
	If lSimbolico
		//		If nPsSubt > 0
		oNJJ:SetValue( "NJJ_STSPES", "2" ) // 0=Sem Pesagem; 1=Primeira Pesagem; 2=Segunda Pesagem 
		If Empty(oNJJ:GetValue("NJJ_DATPS1"))
			oNJJ:SetValue( "NJJ_DATPS1", dDataBase )
		EndIf

		If Empty(oNJJ:GetValue( "NJJ_HORPS1"))
			oNJJ:SetValue( "NJJ_HORPS1", Substr( Time(), 1, 5 ) )
		EndIf

		oNJJ:SetValue( "NJJ_PESO1" , nPsSubt )
		oNJJ:SetValue( "NJJ_MODPS1", "M" )

		If Empty(oNJJ:GetValue( "NJJ_DATPS2"))
			oNJJ:SetValue( "NJJ_DATPS2", dDataBase )
		EndIf

		If Empty(oNJJ:GetValue( "NJJ_HORPS2"))
			oNJJ:SetValue( "NJJ_HORPS2", Substr( Time(), 1, 5 ) )
		EndIf

		oNJJ:SetValue( "NJJ_PESO2" , 0 )
		oNJJ:SetValue( "NJJ_MODPS2", "M" )
		//		EndIf
	EndIf

	nRetorno := oNJJ:GetValue( "NJJ_PSLIQU" )

Return( nRetorno )

/** {Protheus.doc} cDefClasDesc(cTipoRom)
Define quem é o mandante da classificação para desconto do romaneio
1 = fisica 
2 = fiscal

@param: 	cTipoRom - NJJ_TIPO - tipo de romaneio
@return:	Caracter
@author: 	Claudineia Heerdt Reinert
@Uso: 		OGA250 - Romaneio
*/
Function cDefClasDesc (cTipoRom, oModel, lAtuc, lNFP) 
	//Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local cRet 		:= "1" //1-fisica - padrão
	Local lFiscal 	:= .F. //se tem class fiscal na NJK
	Local oNJJ		
	Local oNJK			
	Local nOperation	
	Local nLinha
	Local nX	

	Default lAtuc := .F.
	Default lNFP  := .F.

	If oModel = Nil .AND. !lAtuc
		oModel := FwModelActive()		
	EndIf

	If !FwIsInCallStack( "OGA250ATUC" ) .and. oModel <> nil
		oNJJ := IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
		oNJK := oModel:GetModel( "NJKUNICO" )

		nOperation	:= oModel:GetOperation()
		//TODO Revisar este trecho abaixo, Informações não são passadas para o Model corretamente.
		If oNJK <> nil .And. oNJK:Length() > 0 
			If cTipoRom = "4" .and. nOperation = MODEL_OPERATION_UPDATE
				//procura se tem itens de classificação com class fiscal
				nLinha := oNJK:GetLine()
				For nX := 1 to oNJK:Length()
					oNJK:GoLine( nX )
					If .Not. oNJK:IsDeleted() .And. oNJK:GetValue("NJK_TPCLAS") = "2"
						lFiscal := .T.
					EndIf
				Next nX

				If nLinha > 0
					oNJK:GoLine( nLinha )
				EndIf

				If lFiscal //se tiver class fiscal
					cRet := "2" //2-Fiscal
				EndIf

			//se nota fiscal do produtor rural e entrada compra FOB ou romaneio de saida de venda, é inclusão e o parametro MV_AGOCLAS esta ativo
			ElseIf (cTipoRom = "5" .and. lNFP .and. _lFretOrig) .or. (cTipoRom = "4" .and. nOperation = MODEL_OPERATION_INSERT .and. lChkAgoClas)
				cRet := "2" //2-Fiscal
			EndIf
			
		EndIf

	ElseIf lAtuc .and. ( (cTipoRom = "5" .and. lNFP .and. _lFretOrig) .or. cTipoRom = "4")
		DbSelectArea( "NJK" ) // Classificaçõe do romaneio
		NJK->(DbSetOrder( 1 )) //NJK_FILIAL+NJK_CODROM+NJK_ITEM
		If NJK->(dbSeek( xFilial( "NJK" ) + NJJ->( NJJ_CODROM ) ))
			While !( NJK->( Eof() ) ) .And. NJK->( NJK_FILIAL ) + NJK->( NJK_CODROM ) == xFilial( "NJK" ) + NJJ->( NJJ_CODROM )
				If NJK->( NJK_TPCLAS ) = "2"
					cRet := "2"
				EndIf
				NJK->( DbSkip())	
			EndDo 
		EndIf
		
	EndIf

Return cRet

/** {Protheus.doc} OGA250DCBrw()
Calcula quantidades de desconto quando a pesagem é feita direto no browser, e grava

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	16/12/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250DCBrw(lAtual)
    Local nY		:= 0
	Local cTabela   := ""
	Local cStsCla   := NJJ->NJJ_STSCLA
	Local aDescont	:= {}
	Local aDesconAux:= {}
	Local aProcess	:= {}

	Local nPsEmba	:= nil
	Local nPsSubt	:= NJJ->( NJJ_PSSUBT )
	Local nPsDesc	:= 0
	Local nPsExtr	:= 0
	Local nSomaNJM  := 0
	Local nNJMRECNO := 0
	Local lSimbolico:= ( NJJ->( NJJ_TIPENT ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
	Local lClassOK	:= lSimbolico
	Local lMudaCtr	:= .F.
	Local cClassRom := cDefClasDesc(NJJ->( NJJ_TIPO),,.T.,(NJJ->(NJJ_TPFRET) = 'F'.and. NJJ->( NJJ_TPFORM ) == "1")) //Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local aAreaNJJ  := NJJ->(GetArea())
	Local aAreaNJM  := NJM->(GetArea())
	Local aAreaNJK  := NJK->(GetArea())
	Default lAtual  := .F.

	DbSelectArea( "NJK" ) // Classificaçõe do romaneio
	NJK->(DbSetOrder( 1 )) //NJK_FILIAL+NJK_CODROM+NJK_ITEM
	If NJK->(dbSeek( xFilial( "NJK" ) + NJJ->( NJJ_CODROM ) ))
		While !( NJK->( Eof() ) ) .And. NJK->( NJK_FILIAL ) + NJK->( NJK_CODROM ) == xFilial( "NJK" ) + NJJ->( NJJ_CODROM )

			aAdd( aDescont, { NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) } )

			If cClassRom = NJK->(NJK_TPCLAS)// aDesconAux - contem somente os dados do mandante
				aAdd(aDesconAux,{ NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) } )
			EndIf

			NJK->( DbSkip())	

		EndDo 

		aProcess := OGX004DESC( NJJ->( NJJ_TABELA ), nPsSubt, aDesconAux)

		If Len( aProcess ) > 0

			NJK->(dbSeek(xFilial( "NJK" ) + NJJ->( NJJ_CODROM )))
			While !( NJK->( Eof() ) ) .And. NJK->( NJK_FILIAL ) + NJK->( NJK_CODROM ) == xFilial( "NJK" ) + NJJ->( NJJ_CODROM )

				nY := aScan( aProcess, { | x | AllTrim( x[ 1 ] ) = AllTrim( NJK->( NJK_CODDES ) ) } )
				If nY > 0
					If RecLock( "NJK", .F. )
						If cClassRom = NJK->(NJK_TPCLAS)// Grava na base somente calculo do mandante - DAGROGAP-446
							NJK->( NJK_BASDES ) := aProcess[ nY, 2 ] 
							NJK->( NJK_PERDES ) := aProcess[ nY, 3 ] 
							NJK->( NJK_READES ) := aProcess[ nY, 4 ]
							NJK->( NJK_QTDDES ) := aProcess[ nY, 5 ] 
							nPsDesc += aProcess[ nY, 5 ]
						Else
							NJK->( NJK_QTDDES ) := 0 
						EndIf
						// Busca descrição do resultado do desconto
						__nDesOGA250 := AGRDESCRINNK( NJJ->( NJJ_TABELA ), NJK->( NJK_CODDES ), NJK->( NJK_PERDES ) )
						NJK->( NJK_DESRES ) := __nDesOGA250

						//Ao preencher a pesagem 
						If aProcess[ nY, 2 ] > 0
							lClassOK := .t.
						EndIf

						If .Not. Empty( aProcess[ nY, 7 ] ) .and. NJJ->( NJJ_TABELA ) <> aProcess[ nY, 7 ]
							cTabela  := aProcess[ nY, 7 ]
							lMudaCtr := .t.
						EndIf	

						NJK->( MsUnLock() )
					EndIf
				EndIf

				NJK->( DbSkip() )
			EndDo

		EndIf

	Endif	

	If RecLock( "NJJ", .F. )
		NJJ->( NJJ_PSDESC ) := nPsDesc 
		NJJ->( NJJ_PSBASE ) := nPsSubt - nPsDesc 
		NJJ->( NJJ_PSEXTR ) := nPsExtr 
		If NJJ->(ColumnPos('NJJ_PESEMB')) > 0 .and. __lnewNeg
			nPsEmba := NJJ->( NJJ_PESEMB )
			NJJ->( NJJ_PSLIQU ) := nPsSubt - ( nPsDesc + nPsExtr ) - nPsEmba
		Else
			NJJ->( NJJ_PSLIQU ) := nPsSubt - ( nPsDesc + nPsExtr ) 
		EndIf
		//Valor do novo campo NJJ_PESO3 deve ser igual ao valor do campo NJJ_PSLIQU - DAGROGAP-446
		If !lAtual .and. !lExecAgoClas .and. !_lFretOrig
			NJJ->( NJJ_PESO3 ) := NJJ->( NJJ_PSLIQU ) 
		EndIf

		if lMudaCtr
			NJJ->( NJJ_STSCTR ) := "1"  //1=Sem Ctr.
		EndIf

		//Esta tabela é buscada pelo vinculo dos desconto com o romaneio(feito acima)
		If !Empty(cTabela)
			DbSelectArea( 'NNI' )
			NNI->(DbSetOrder( 1 ))
			If NNI->(DbSeek( xFilial('NNI') + cTabela))	
				//reverMSG
				MsgAlert( STR0195 + NJJ->( NJJ_TABELA ) + STR0196 + cTabela + STR0197 ) //"A tabela de classificação foi alterada de " + NJJ->( NJJ_TABELA ) + " para " + cTabela + ", que é a tabela alternativa."
				NJJ->NJJ_TABELA	:= cTabela
				NJJ->NJJ_CODPRO := NNI->NNI_CODPRO	
				
				OGA250VTAB()
			EndIf
			//Caso a tabela não tenha descontos, o status da classificação será mantido.
		elseIf !Empty(NJJ->( NJJ_TABELA )) .AND. Empty(cTabela)
			NJJ->NJJ_STSCLA := cStsCla
		Else
			//Atualiza campo "Status" na aba "Amostra" para "Classificado" caso seja "Verdadeiro" .T.
			If lClassOK
				NJJ->( NJJ_STSCLA ) := "1" //1=Classificada
			Else
				NJJ->( NJJ_STSCLA ) := "0" //0=Não Classificada
			EndIf
		EndIf

		NJJ->( MsUnLock() )
	EndIf

	nSomaNJM := 0
	DbSelectArea( "NJM" ) // Comercializações do romaneio
	NJM->(DbSetOrder( 1 )) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
		While !( NJM->( Eof() ) ) .And. NJM->( NJM_FILIAL ) + NJM->( NJM_CODROM ) == xFilial( "NJK" ) + NJJ->( NJJ_CODROM )

			If RecLock( "NJM", .F. )
				//Utiliza o valor do novo campo NJJ_PESO3 para realizar os calculos - DAGROGAP-446
				NJM->( NJM_QTDFCO ) := Round( ( NJJ->( NJJ_PESO3 ) * ( NJM->( NJM_PERDIV ) / 100 ) ), nDecPeso )

				nSomaNJM += NJM->( NJM_QTDFCO )
				if lMudaCtr
					NJM->( NJM_CODCTR ) := " "
					If NJM->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg
						NJM->( NJM_FILORG ) := " "
					EndIf
				EndIf
				NJM->( MsUnLock() )
				nNJMRECNO := NJM->( Recno() )
			EndIf

			NJM->( DbSkip() )
		EndDo

		// Se deu alguma diferença no total por conta de arredondamento
		//Utiliza o novo campo NJJ_PESO3 para os calculos - DAGROGAP-446
		If nSomaNJM <> NJJ->( NJJ_PESO3 )
			NJM->( DbGoTo( nNJMRECNO ) )
			If RecLock( "NJM", .F. )
				NJM->( NJM_QTDFCO ) += ( NJJ->( NJJ_PESO3 ) - nSomaNJM ) // Ajusta a diferença no último item do romaneio
				NJM->( MsUnLock() )
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaNJM)
	RestArea(aAreaNJJ)
	RestArea(aAreaNJK)
Return( NIL )


/** {Protheus.doc} fTrgPerDiv
Gatilho disparado pelo campo NJM_PERDIV, para atualizar o campo de quantidade (NJM_QTDFCO)

@param: 	oParModel 
@return:	nQtdLiq - Quantidade para NJM_QTDFCO
@author: 	Marlon Richard Trettin
@since: 	02/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fTrgPerDiv( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNJJ 		:= oModel:GetModel( "NJJUNICO" )
	Local oNJM 		:= oModel:GetModel( "NJMUNICO" )
	Local nQtdLiq		:= 0

	//Utiliza o valor do novo campo NJJ_PESO3 para realizar os calculos - DAGROGAP-446
	//nQtdLiq := Round( ( oNJJ:GetValue( "NJJ_PSLIQU" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso )
	nQtdLiq := Round( ( oNJJ:GetValue( "NJJ_PESO3" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso )

	oNJM:SetValue( "NJM_QTDFCO", nQtdLiq )
	
	//NFP -> 5 = Entrada Compra , F = FOB , Formuluario Proprio 1-sim
	If (oNJM:GetValue( "NJM_TPFORM" ) == "1" .and. oNJJ:GetValue( "NJJ_TIPENT" ) <> "1") .and. ;		
		!(_lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue( "NJJ_TPFRET" )  = 'F' .and. oNJM:GetValue( "NJM_TPFORM" ) == "1")  .or.; 		
	    (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")//0=Físico;1=Gerencial;2=Simbolico;3=Retenção  Dekalpar

		oNJM:LoadValue( "NJM_QTDFIS", nQtdLiq )	
		oNJM:LoadValue( "NJM_VLRUNI", oNJJ:GetValue( "NJJ_VLRUNI" ) )	
		oNJM:LoadValue( "NJM_VLRTOT", oNJJ:GetValue( "NJJ_VLRUNI" ) * nQtdLiq )	
	EndIf

Return( nQtdLiq )


/** {Protheus.doc} fTrgQtdFco
Gatilho disparado pelo campo NJM_QTDFCO, para atualizar o campo de percentual (NJM_PERDIV) 

@param: 	oParModel
@return:	nPerLiq - Percentual para NJM_PERDIV
@author: 	Marlon Richard Trettin
@since: 	02/02/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fTrgQtdFco( oParModel )
	Local oModel   := oParModel:GetModel()
	Local oNJJ 	   := oModel:GetModel( "NJJUNICO" )
	Local oNJM 	   := oModel:GetModel( "NJMUNICO" )
	Local nPerLiq  := 0
    Local nQtdLiq  := 0

	//Fazer os calculos usando o novo campo NJJ_PESO3 - DAGROGAP-446
	//nPerLiq := Round( ( 100 * ( oNJM:GetValue( "NJM_QTDFCO" ) / oNJJ:GetValue( "NJJ_PSLIQU" ) ) ), TamSX3( "NJM_PERDIV" )[2] )
	nPerLiq := Round( ( 100 * ( oNJM:GetValue( "NJM_QTDFCO" ) / oNJJ:GetValue( "NJJ_PESO3" ) ) ), TamSX3( "NJM_PERDIV" )[2] )

	oNJM:LoadValue("NJM_PERDIV", nPerLiq ) // Usado LoadValue() pra não disparar novamente o gatilho

    nQtdLiq := Round( ( oNJJ:GetValue( "NJJ_PESO3" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso )
    
	//NFP -> 5 = Entrada Compra , F = FOB , Formuluario Proprio 1-sim
	IF (oNJM:GetValue( "NJM_TPFORM" ) == "1" .and. oNJJ:GetValue( "NJJ_TIPENT" ) <> "1") .and. !lExecAgoClas .and. ;	    
		!(_lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue( "NJJ_TPFRET" )  = 'F' .and. oNJM:GetValue( "NJM_TPFORM" ) == "1")  .or.; 		
	     (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //0=Físico;1=Gerencial;2=Simbolico;3=Retenção  Dekalpar
        oNJM:LoadValue( "NJM_QTDFIS", nQtdLiq )	
        oNJM:LoadValue( "NJM_VLRUNI", oNJJ:GetValue( "NJJ_VLRUNI" ) )	
		oNJM:LoadValue( "NJM_VLRTOT", oNJJ:GetValue( "NJJ_VLRUNI" ) * nQtdLiq )	
    EndIf

Return( nPerLiq )


/** {Protheus.doc} fVldNJJ1
Função de validação de vários campos da NJJ e preenchimento automatico da NJM

@param: 	Nil
@author: 	Marlon Richarda trettin
@since: 	16/07/2015
@Uso: 		SIGAAGR
*/
Static Function fVldNJJ1( oField, cCpo )
	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local nLinha 		:= oNJM:GetLine()

	oNJM:GoLine( 1 )

	If cCpo == 'NJJ_CODSAF'
		If !Empty( oNJJ:GetValue( "NJJ_CODSAF" )  )
			If ExistCpo('NJU', oNJJ:GetValue( "NJJ_CODSAF" ) ) .And. OGA250ACTR()
				oNJM:SetValue( "NJM_CODSAF", oNJJ:GetValue( "NJJ_CODSAF" ) )
			Else
				Return( .F. )
			EndIf
		EndIf

	ElseIf cCpo == 'NJJ_CODPRO'
		If !Empty( oNJJ:GetValue( "NJJ_CODPRO" ) )
			If ExistCpo( "SB1", oNJJ:GetValue( "NJJ_CODPRO" ) )
				oNJM:SetValue( "NJM_CODPRO", oNJJ:GetValue( "NJJ_CODPRO" ) )
				If __lnewNeg
					//Ao alterar o produto para algodao, remove NJK
					oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.T.)
					lRet := Iif(Posicione("SB5",1,fwxFilial("SB5")+oNJJ:GetValue("NJJ_CODPRO"),"B5_TPCOMMO")== '2',.F.,.T.)
					If !lRet
						oNJJ:LoadValue("NJJ_TABELA", Space(TamSX3("NJJ_TABELA")[01]))
						oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.F.)
						ResetNJK()
					EndIf
				EndIf	
			Else
				Return( .F. )
			EndIf
		EndIf

	ElseIf cCpo == 'NJJ_LOCAL'
		If !Empty(oNJJ:GetValue( "NJJ_LOCAL" ))
			If ExistCpo('NNR', oNJJ:GetValue( "NJJ_LOCAL" ) )
				oNJM:SetValue( "NJM_LOCAL", oNJJ:GetValue( "NJJ_LOCAL" ) )
			Else
				Return( .F. )
			EndIf
		EndIf
	EndIf

	oNJM:GoLine( nLinha )
Return( .T. )

/** {Protheus.doc} fVldNJJ2
Função de validação de vários campos da NJJ e preenchimento automatico da NJM

@param: 	Nil
@author: 	Marlon Richarda trettin
@since: 	16/07/2015
@Uso: 		SIGAAGR
*/
Static Function fVldNJJ2( oField, cCpo )
	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local nLinha 		:= oNJM:GetLine()
	Local lRet := .T.
	Local nX := 1

	oNJM:GoLine( 1 )

	If !Empty(oNJJ:GetValue( "NJJ_DOCSER" )) .and. FwFldGet("NJJ_TPFORM") = "2"

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_DOCSER", oNJJ:GetValue( "NJJ_DOCSER" ) )
		Next nX		
		
	EndIf
	If !Empty(oNJJ:GetValue( "NJJ_DOCNUM" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_DOCNUM", oNJJ:GetValue( "NJJ_DOCNUM" ) )
		Next nX		
		
	EndIf
	If !Empty(oNJJ:GetValue( "NJJ_DOCEMI" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_DOCEMI", oNJJ:GetValue( "NJJ_DOCEMI" ) )
		Next nX		
		
	EndIf
	If !Empty(oNJJ:GetValue( "NJJ_DOCESP" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_DOCESP", oNJJ:GetValue( "NJJ_DOCESP" ) )
		Next nX		
		
	EndIf
	If !Empty(oNJJ:GetValue( "NJJ_NFPSER" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_NFPSER", oNJJ:GetValue( "NJJ_NFPSER" ) )
		Next nX		
		
	EndIf
	If !Empty(oNJJ:GetValue( "NJJ_NFPNUM" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_NFPNUM", oNJJ:GetValue( "NJJ_NFPNUM" ) )
		Next nX		
			
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_TES" ))

		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )	
			oNJM:SetValue( "NJM_TES", oNJJ:GetValue( "NJJ_TES" ) )
		Next nX		
		
	EndIf

	If cCpo == 'NJJ_DOCESP' .And. !Empty(oNJJ:GetValue( "NJJ_DOCESP" )) .And.;
	!ExistCpo('SX5','42'+oNJJ:GetValue("NJJ_DOCESP"))
		lRet := .F.
	EndIf

	If cCpo == 'NJJ_CHVNFE'
		lRet := OGA250CHNF()
		If lRet
			oNJM:SetValue( "NJM_CHVNFE", oNJJ:GetValue( "NJJ_CHVNFE" ) )
		EndIf
	EndIf

	oNJM:GoLine( nLinha )
Return lRet

/** {Protheus.doc} fVldNJJ3
Função de validação de vários campos da NJJ e preenchimento automatico da NJM

@param: 	Nil
@author: 	Marlon Richarda trettin
@since: 	16/07/2015
@Uso: 		SIGAAGR
*/
Static Function fVldNJJ3( oField, cField )

	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )
	Local nLinha 		:= oNJM:GetLine()
	Local oView			:= FWViewActive()
	Local nX := 1

	If lExecAgoClas	
		If !vlQtdPeso3(oModel) //valida a quantidade fisica NJJ_PESO3 - DAGROGAP-446
			Return ( .f. )
		EndIf  

		Return ( .T. )
	EndIf

	oNJM:GoLine( 1 )

	If oNJJ:GetValue( "NJJ_STATUS" ) $ "2|3" .and. !lExecAgoClas
		Agrhelp(STR0021,STR0433 + DescriSX3(cField), STR0131) 
		//#HELP #Não é permitido alterar o campo #Não é permitido alterar este campo em Romaneio com Status -Atualizado- ou -Confirmado-.
		Return( .F. )
	EndIf

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|4|6|8"; // Se tipo do romaneio for de SAÍDA
	.And. oNJJ:GetValue( "NJJ_TPFORM" ) <> "1"  // e Formulário Próprio for diferente de SIM
		Agrhelp(STR0021,STR0434, STR0138)
		//#HELP #Tipo de formulário inválido. #Para romaneios de SAÍDA, é obrigatório informar o Formulário Próprio igual a SIM.
		Return( .F. )
	Else
		For nX := 1 to oNJM:Length() 
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_TPFORM", oNJJ:GetValue( "NJJ_TPFORM" ) )
		Next nX		
	EndIf

	IF _lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and.  oNJJ:GetValue( "NJJ_TPFORM" ) == "1"
	   	If oNJJ:GetValue("NJJ_TPFRET") == 'F' 
		   oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_QTDFIS" ) )
		ElseIf Alltrim(cField) == "NJJ_TPFRET" .and. oNJJ:GetValue("NJJ_TPFRET") != 'F'
			oNJJ:LoadValue( "NJJ_QTDFIS", 0 )
			OGA250ATUG()
		EndIf
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_QTDFIS" )) .or. (_lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and.  oNJJ:GetValue("NJJ_TPFRET") == 'F' .and. oNJJ:GetValue( "NJJ_TPFORM" ) == "1")
		oNJM:LoadValue( "NJM_QTDFIS", oNJJ:GetValue( "NJJ_QTDFIS" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_VLRUNI" ))
		oNJM:LoadValue( "NJM_VLRUNI", oNJJ:GetValue( "NJJ_VLRUNI" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_VLRTOT" ))
		oNJM:LoadValue( "NJM_VLRTOT", oNJJ:GetValue( "NJJ_VLRTOT" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_FRETE" ))
		oNJM:LoadValue( "NJM_FRETE", oNJJ:GetValue( "NJJ_FRETE" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_SEGURO" ))
		oNJM:LoadValue( "NJM_SEGURO", oNJJ:GetValue( "NJJ_SEGURO" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_DESPES" ))
		oNJM:LoadValue( "NJM_DESPES", oNJJ:GetValue( "NJJ_DESPES" ) )
	EndIf

	IF _lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue("NJJ_TPFRET") = 'F' .and. oNJJ:GetValue( "NJJ_TPFORM" ) == "1"
	   	oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_QTDFIS" ) )
	EndIf

	//Atualizar o campo NJM_QTDFCO com o informado no campo NJJ_PESO3 - DAGROGAP-446
	oNJM:SetValue( "NJM_QTDFCO", oNJJ:GetValue( "NJJ_PESO3" ))  
 
	If ValType(oView) == 'O' .AND. oView:GetModel():GetId() == "OGA250"
		oView:Refresh()
	EndIf

	oNJM:GoLine( nLinha )
Return( .T. )


/** {Protheus.doc} OGA250PESA
Função auxililar para executar a rotina de pesagem

@param: 	oModel - Modelo de Dados
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	08/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250PESA( oModel, cOrigem )
	Local oView			:= FWViewActive()
    Local nNJJRECNO 	:= NJJ->( Recno() )
	Local nOperation	:= oModel:GetOperation()
	Local oFldNJJ		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500

	Local nPeso1 		:= 0
	Local nPeso2 		:= 0
	Local lPeso1 		:= .F.
	Local lPeso2		:= .F.
	Local lPeso3		:= .F.

	Local oDlg 			:= Nil
	Local oCombo		:= Nil
	Local cCombo		:= ""
	Local nItem			:= 1
	Local nPeso			:= 0
	Local lPesagManu	:= .f.
	Local aParam        := { NJJ->( NJJ_CODROM )}
	Local lExec         := .T.

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

	If ExistBlock('OG250PES')
		lExec := ExecBlock('OG250PES',.F.,.F.,aParam)
	EndIf

	If lExec
		If aParBal == nIl     // Para Ser Inicializado Somente Qdo ainda não foi 
			aParBal := AGRX003E( .f., 'OGA050001' )
		EndIF	

		If Empty(aParBal[1]) 
		    Agrhelp(STR0021,STR0435,STR0436) //#HELP #Nenhuma balança selecionada. #Informe a balança a ser utilizada por meio da tecla de atalho F12.
			Return(.F.)
		EndIf   

		IF _CHKQLDPES		// PARAMETRO QUE INDICA, A NECESSIDADE DE VERIFICAR, O LCAMENTO DO PARECER DE QUALIDADE ANTES DA PESAGEM.
			/*FUçãO PARA VALIDAR PARECER DA QUALIDADE*/
			IF !OGA250PQL() 
				RETURN( .F. )
			ENDIF
		ENDIF

	  nPeso1 := oFldNJJ:GetValue( "NJJ_PESO1" )
		nPeso2 := oFldNJJ:GetValue( "NJJ_PESO2" )
	
		lPeso1 := ( nPeso1 == 0 )
		lPeso2	:= ( nPeso2 == 0 )
		lPeso3	:= ( nPeso1 > 0 .And. nPeso2 > 0 )
	
		If .Not. oFldNJJ:GetValue( "NJJ_STATUS" ) $ "0,1"		
			Agrhelp(STR0021,STR0087 + Chr(13)+Chr(10) + "Rom. [ "+xFilial('NJJ')+" - "+oFldNJJ:GetValue( "NJJ_CODROM" )+" ]; Status [ "+oFldNJJ:GetValue( "NJJ_STATUS" )+"-"+X3CboxDesc( "NJJ_STATUS", oFldNJJ:GetValue( "NJJ_STATUS" ) )+" ]",STR0437)
			//reverMSG //#Status do Romaneio não permite alteração na Pesagem. #Somente romaneios Abertos podem ser pesados.
			Return( Nil )
		EndIf		

		If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == 4)
			/*FUçãO PARA VALIDAR PARECER DA QUALIDADE*/
			/** Ja possui as duas pesagens */
			If lPeso3 .And. .Not. aParBal[ 4 ]
				oDlg 	:= TDialog():New(0,0,24,300,STR0109,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Refazer:"
				oCombo 	:= TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0038, STR0039}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , 'cCombo' ) //"Primeira Pesagem"###"Segunda Pesagem"
				oTButt 	:= TButton():New( 001, 104, STR0040, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma"
				oDlg:Activate( , , , .t., { | | nAcao := 1, .t. }, , { || } )

				If nAcao < 1; Return( ); EndIf

				If nItem = 1
					lPeso1 := .t.
					lPeso2 := .f.
				ElseIf nItem = 2
					lPeso1 := .f.
					lPeso2 := .t.
				EndIf
			EndIf
			// Abre a tela para pesagem
			AGRX003A( @nPeso,.t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2 )
			// Se o peso lido for maior que zero
			If nPeso > 0	

				/** Executa primeira pesagem ou repesagem do primeiro peso **/
				If lPeso1

					If nPeso <> nPeso2 // Consistência para não permitir 2 pesos iguais

						oFldNJJ:SetValue( "NJJ_DATPS1", dDataBase )
						oFldNJJ:SetValue( "NJJ_HORPS1", Substr( Time(), 1, 5 ) )
						oFldNJJ:SetValue( "NJJ_PESO1" , nPeso )
						oFldNJJ:SetValue( "NJJ_MODPS1", IIf( lPesagManu, "M", "A" ) )
						oFldNJJ:SetValue( "NJJ_STSPES", IIf( lPeso3, "2", "1" ) )	
						oFldNJJ:SetValue( "NJJ_STATUS", IIf( lPeso3, "1", "0" ) )	
												

						If lPeso3	

							oFldNJJ:SetValue( "NJJ_PSSUBT", Abs( nPeso - nPeso2 ) )

							If cOrigem == "GRID"		

								OGA250DCBrw() // Atualiza descontos
							Endif	
						EndIf
						If nOperation == MODEL_OPERATION_UPDATE .AND. (cOrigem == "GRID" .OR. oFldNJJ:GetValue( "NJJ_PESO1" ) > 0)
							AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+FwFldGet('NJJ_CODROM'),"4",STR0176})
						EndIF	
					Else
						Agrhelp(STR0021,STR0127 + Chr(13)+Chr(10) + STR0014 + " [ "+xFilial('NJJ')+" - "+NJJ->( NJJ_CODROM )+" ]",STR0438)
						//#AJUDA #O romaneio não pode receber 2 pesagens iguais. #Romaneio #Verifique as pesagens realizadas.
						Return( Nil )
					Endif			
				Else
					/** Executa segunda pesagem ou repesagem do segundo peso **/
					If lPeso2

						If nPeso <> nPeso1 // Consistência para não permitir 2 pesos iguais

							
								oFldNJJ:SetValue( "NJJ_DATPS2", dDataBase )
								oFldNJJ:SetValue( "NJJ_HORPS2", Substr( Time(), 1, 5 ) )
								oFldNJJ:SetValue( "NJJ_PESO2" , nPeso )
								oFldNJJ:SetValue( "NJJ_MODPS2", IIf( lPesagManu, "M", "A" ) )
								oFldNJJ:SetValue( "NJJ_STSPES", "2" )	
								oFldNJJ:SetValue( "NJJ_STATUS", "1" ) //1=Completo	
								oFldNJJ:SetValue( "NJJ_PSSUBT", Abs( nPeso - nPeso1 ) )	

							If cOrigem == "GRID"						
								OGA250DCBrw() // Atualiza descontos							
							EndIf

							If nOperation == MODEL_OPERATION_UPDATE .AND. (cOrigem == "GRID" .OR. oFldNJJ:GetValue( "NJJ_PESO2" ) > 0)
								AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+FwFldGet('NJJ_CODROM'),"4",STR0177})
							EndIF
						Else
							Agrhelp(STR0021,STR0127 + Chr(13)+Chr(10) + STR0014 + " [ "+xFilial('NJJ')+" - "+NJJ->( NJJ_CODROM )+" ]", STR0438)
							//#AJUDA #O romaneio não pode receber 2 pesagens iguais. #Romaneio #Verifique as pesagens realizadas.
							Return( Nil )
						Endif
					EndIf		
				EndIf
			EndIf
		EndIf
		
		If cOrigem == "GRID"
			//faz o commit do oga250
			fcommit(oModel)
		Endif

		If .Not. lF10Exec
			oView:Refresh()
		Else
			//	oFiltro:ExecuteFilter()
			NJJ->( DbGoTo( nNJJRECNO ) )
			oBrowseNJJ:Refresh()
		Endif
	EndIf	
Return(.t.)

/*/{Protheus.doc} fcommit()
	realiza o commit do oga250 para processos automáticos
	@type  Static Function
	@author mauricio.joao
	@since 05/02/2020
	@version 1.0
	/*/
Static Function fcommit(oModel)

	If oModel:VldData()
		oModel:CommitData()	
		oModel:DeActivate() // Desativa o modelo
		oModel:Destroy() // Destroy o objeto modelo	
	Else
		AutoGrLog(oModel:GetErrorMessage()[6])
		AutoGrLog(oModel:GetErrorMessage()[7])
		If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
			AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
		EndIf
		MostraErro()
	EndIf
	
Return .T.

/** {Protheus.doc} OGA250INIT
Rotina para atualizar dados de inicializadores padrão em romaneios

@return:	Array com os parametros de [1]-Safra e [2]-Tabela e [3]-Local de Carga/Descarga
@param: 	Nil
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250INIT( lPergunta )
	Local aAreaAtu	:= GetArea()
	Local __cSafra	:= ""
	Local __cProduto	:= ""
	Local __cTabela	:= ""
	Local __cLocal	:= ""

	Default lPergunta	:= .t.

	Pergunte( "OGA2500001", lPergunta )

	__cSafra 	:= mv_par01
	__cProduto	:= mv_par02
	__cTabela	:= mv_par03
	__cLocal	:= mv_par04

	RestArea( aAreaAtu )

Return( { __cSafra, __cProduto, __cTabela, __cLocal } )


/** {Protheus.doc} fTrgStatus
Gatilho para atualizar o campo NJJ_STATUS

@return:	cStatus - Status geral do romaneio
@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	05/05/2015
@Uso: 		OGA250 - Romaneio
*/
Static Function fTrgStatus( )
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "NJJUNICO" )
	Local cStsCla	:= oNJJ:GetValue( "NJJ_STSCLA" )
	Local cStsPes	:= oNJJ:GetValue( "NJJ_STSPES" )
	Local nPsSubt	:= oNJJ:GetValue( "NJJ_PSSUBT" )
	Local cStatus 	:= oNJJ:GetValue( "NJJ_STATUS" )
	Local lSimbolico:= ( oNJJ:GetValue( "NJJ_TIPENT" ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção

	If nPsSubt > 0 .Or. lSimbolico
		oNJJ:LoadValue( "NJJ_STSPES", "2" ) // 0=Sem Pesagem; 1=Primeira Pesagem; 2=Segunda Pesagem 
		cStsPes := "2"
	EndIf

	If cStsCla == "1" .And. cStsPes == "2" .And. !lExecAgoClas
		cStatus := "1"
	EndIf

Return( cStatus )


/** {Protheus.doc} OGA250ATUG
Calcula os descontos

@return:	cStatus - Status geral do romaneio
@param: 	Nil
@author: 	Equipe AgroIndustria
@since: 	01/01/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250ATUG( lCalc)
	Local oView		:= FWViewActive()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJK		:= oModel:GetModel( "NJKUNICO" )
	Local oNJM		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJM" ), oModel:GetModel( "NJMUNICO" )) //Protecao para usar funcao via AGRA500 
	Local nY		:= 0
	Local nX		:= 0
	Local nLinha	:= 0
	Local cTabela 	:= ""
	Local aAreaNJR  := NJR->( GetArea() )
	Local aProcess	:= {}
	Local nPsEmba	:= nil
	Local nPsSubt	:= oNJJ:GetValue( "NJJ_PSSUBT" )
	Local nAnPsDesc	:= oNJJ:GetValue( "NJJ_PSDESC" )
	Local nPsDesc 	:= 0
	Local nPsExtr	:= oNJJ:GetValue( "NJJ_PSEXTR" )
	Local lSimbolico:= ( oNJJ:GetValue( "NJJ_TIPENT" ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
	Local lClassOK	:= lSimbolico 
	Local lMudaCtr	:= .f.
	Local lClassUpd := .T.
	Local cClassRom := cDefClasDesc(oNJJ:GetValue("NJJ_TIPO"), oModel,,(oNJJ:GetValue("NJJ_TPFRET") = 'F'.And. oNJJ:GetValue("NJJ_TPFORM") == "1")) //Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local aDesconAux := {}
	Local aSaveLines  := FWSaveRows()
	Local cCtrlQuald  := "2"
	Local cNNKDESC := Nil
	Local cTabTemp := ""
	Local cCodTemp := ""
	Local nPerTemp := 0
	Default lCalc := .t.

	If __lnewNeg
		If !__lDescOk //Reprovou o primeiro valid
			Return .F.
		EndIf

		If NJJ->(ColumnPos('NJJ_PESEMB')) > 0 
			nPsEmba := oNJJ:GetValue( "NJJ_PESEMB" )
		EndIf
	EndIf

	nPsSubt	:= oNJJ:GetValue( "NJJ_PSSUBT" )

	If lCalc
		nLinha := oNJK:GetLine()
		For nX := 1 to oNJK:Length()
			oNJK:GoLine( nX )
			If .Not. oNJK:IsDeleted() .And. oNJK:GetValue("NJK_TPCLAS") = cClassRom
				aAdd( aDesconAux, { oNJK:GetValue( "NJK_CODDES" ), oNJK:GetValue( "NJK_PERDES" ) } )
			EndIf
		Next nX
		oNJK:GoLine( nLinha )
			
		aProcess := OGX004DESC( oNJJ:GetValue( "NJJ_TABELA" ), nPsSubt, aDesconAux)

		If Len( aProcess ) > 0 //.And. lClassUpd 

			nPsDesc := 0
			For nY := 1 to Len( aProcess )
				nPsDesc += aProcess[ nY, 5 ]
			Next nY

			If nAnPsDesc <> nPsDesc	// Se alterou a quantidade de descontos romaneio
				If fNJMStaFis("VIEW") == "2" .and. !lExecAgoClas // E possui Doc Fiscal em alguma linha no NJM, não permite alterar
					Agrhelp(STR0021, STR0439, STR0440 ) //#AJUDA #Operação não permitida. #Para realizar a alteração não pode haver vínculo de documento fiscal nos itens do romaneio.
					Return( .F. )
				EndIf
			EndIf

			nPsDesc := 0
			nLinha := oNJK:GetLine()
			For nX := 1 to oNJK:Length()
				oNJK:GoLine( nX )
				If .Not. oNJK:IsDeleted()
					nY := aScan( aProcess, { | x | AllTrim( x[ 1 ] ) = AllTrim( oNJK:GetValue( "NJK_CODDES" ) ) } )
					//Mostra somente os descontos do mandante - DAGROGAP-446
					If oNJK:GetValue("NJK_TPCLAS") = cClassRom 
						oNJK:LoadValue( "NJK_BASDES", aProcess[ nY, 2 ] )
						oNJK:LoadValue( "NJK_PERDES", aProcess[ nY, 3 ] )
						oNJK:LoadValue( "NJK_READES", aProcess[ nY, 4 ] )
						oNJK:LoadValue( "NJK_QTDDES", aProcess[ nY, 5 ] )
						nPsDesc += aProcess[ nY, 5 ]
					Else
						oNJK:LoadValue( "NJK_READES", 0 )
						oNJK:LoadValue( "NJK_QTDDES", 0 )
					EndIf


					cTabTemp := oNJJ:GetValue("NJJ_TABELA")
					cCodTemp := oNJK:GetValue("NJK_CODDES")
					nPerTemp := oNJK:GetValue("NJK_PERDES")

					cNNKDESC := GetNextAlias() 

					BeginSQL Alias cNNKDESC 
						SELECT NNK_DESRES
						FROM %Table:NNK%
						WHERE %notDel%
						AND NNK_FILIAL =  %xFilial:NNK%
						AND NNK_CODTAB =  %Exp:cTabTemp%
						AND NNK_CODDES =  %Exp:cCodTemp%
						AND (NNK_PERINI <= %Exp:nPerTemp%
						AND NNK_PERFIM >= %Exp:nPerTemp%)
					EndSQL

					If (cNNKDESC)->(!Eof())
						__nDesOGA250 := (cNNKDESC)->NNK_DESRES
					Else
						__nDesOGA250 := ""
					EndIf

					(cNNKDESC)->(dbCloseArea())

					oNJK:LoadValue( "NJK_DESRES", __nDesOGA250 )

					If .Not. Empty( aProcess[ nY, 7 ] ) .and. oNJJ:GetValue( "NJJ_TABELA" ) <> aProcess[ nY, 7 ]
						cTabela := aProcess[ nY, 7 ]
						lMudaCtr := .t.
					EndIf	
				EndIf
			Next nX
			oNJK:GoLine( nLinha )
		EndIf	
	Else
		nLinha := oNJK:GetLine()
		For nX := 1 to oNJK:Length()
			oNJK:GoLine( nX )
			If .Not. oNJK:IsDeleted()
				nPsDesc += oNJK:GetValue( "NJK_QTDDES")	
				nPct    := (oNJK:GetValue( "NJK_QTDDES")	/ oNJK:GetValue( "NJK_BASDES")) * 100
				oNJK:LoadValue("NJK_READES", nPct)
				oNJK:LoadValue("NJK_PERDES", fGetResul(oNJJ:GetValue("NJJ_TABELA"), oNJK:GetValue("NJK_CODDES"), nPct))				
			EndIf
		Next nX 		
		oNJK:GoLine( nLinha )
	EndIf

	oNJJ:LoadValue( "NJJ_PSDESC", nPsDesc )
	oNJJ:LoadValue( "NJJ_PSBASE", nPsSubt - nPsDesc )
	oNJJ:LoadValue( "NJJ_PSEXTR", nPsExtr )
	If NJJ->(ColumnPos('NJJ_PESEMB')) > 0 .and.__lnewNeg
		oNJJ:LoadValue( "NJJ_PSLIQU", nPsSubt - ( nPsDesc + nPsExtr ) - nPsEmba)
	Else
		oNJJ:LoadValue( "NJJ_PSLIQU", nPsSubt - ( nPsDesc + nPsExtr ) )
	EndIf

	//Sugerir o valor do novo campo NJJ_PESO3 com base no NJJ_PSLIQU - DAGROGAP-446
	If !lExecAgoClas .and. !(_lFretOrig .And. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue("NJJ_TPFRET") = 'F' .and. oNJJ:GetValue( "NJJ_TPFORM" ) == "1")
		oNJJ:LoadValue( "NJJ_PESO3", oNJJ:GetValue( "NJJ_PSLIQU" ))
	EndIf

	// Recalcula e atualiza as qtdes dos itens do romaneio
	fAtuQtdNJM() 

	If lMudaCtr
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:LoadValue( "NJM_CODCTR", " " )
			If NJJ->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg
				oNJM:LoadValue( "NJM_FILORG", " " )
			EndIf

		Next nX
		oNJM:GoLine( nLinha )
	EndIf

	DbSelectArea('NJR')
	NJR->( DbSetOrder(1) )
	If NJR->( dbSeek( FwxFilial( "NJR" ) + oNJM:GetValue('NJM_CODCTR',1) ))
		cCtrlQuald := NJR->NJR_CLASSQ  //QUAL CLASSIFICAÇÃO ORIGEM OU DESTINO DETERMINA QUE O ROMANEIO ESTA CLASSIFICADO.
		
		If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
			//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM
			IF NJR->NJR_CLASSF == "2" .AND. oNJJ:GetValue( "NJJ_TIPO" ) == '5' .and. oNJJ:GetValue("NJJ_TPFRET") = 'F' .and. oNJM:GetValue( "NJM_TPFORM" ) == "1"
				cCtrlQuald := "2" // Origem
			EndIf		
		EndIf
	EndIf

	nLinha := oNJK:GetLine()
	For nX := 1 to oNJK:Length()
		oNJK:GoLine( nX )
		If .Not. oNJK:IsDeleted()
			// Garantindo que resultados copiados de uma tab. informada previamente
			// Sejam considerados como resultados informados (( Pois ao trocar uma tabela que ja tenha class informada
			// o sistema aproveita os resultados )
			IF oNJK:GetValue( "NJK_RESINF" ) == '2' .AND. oNJK:GetValue( "NJK_PERDES" ) > 0
				oNJK:SetValue( "NJK_RESINF" , '1' )
			EndIF

			//Esse IF é somente para manter o legado onde o campo NJK_OBRGT pode estar vazio
			If oNJK:GetValue( "NJK_OBRGT" ) == " " .AND. oNJK:GetValue( "NJK_RESINF" ) == '1'
				lClassUpd := .T.
			EndIf 

			//Se o campo obrigatorio for 1=sim e resultado informado for 2=não informado - não classifica e sai
			If oNJK:GetValue( "NJK_OBRGT" ) == '1' .AND. oNJK:GetValue( "NJK_RESINF" ) == '2'
				If NJR->(ColumnPos('NJR_CLASSQ')) > 0 .and. __lnewNeg
					If cCtrlQuald = oNJK:GetValue( "NJK_TPCLAS" )  
						lClassUpd := .F.  //ROMANEIO NÃO CLASSIFICADO
						exit
					EndIf
				Else
					lClassUpd := .F.  
					exit
				EndIf
			EndIf    
		EndIf
	Next nX
	oNJK:GoLine( nLinha )

	If lClassUpd  .and. ! lSimbolico  // Indica que todos os itens de classificação obrigatorios foram preenchidos
		lClassOk := lClassUpd 
	EndIf

	If !Empty(cTabela)
		DbSelectArea( 'NNI' )
		NNI->(DbSetOrder( 1 ))
		If NNI->(DbSeek( xFilial('NNI') + cTabela))
		//	Agrhelp(STR0021,STR0195 + oNJJ:GetValue( "NJJ_TABELA" ) + STR0196 + cTabela + STR0197 ,NIL)//A Tabela de Classificação foi alterada de . para que é a tabela alternativa.
			//reverMSG
			MsgAlert( STR0195 + oNJJ:GetValue( "NJJ_TABELA" ) + STR0196 + cTabela + STR0197 ) 
			oNJJ:SetValue( "NJJ_CODPRO", NNI->NNI_CODPRO )
			oNJJ:LoadValue( "NJJ_TABELA", cTabela )	
			
			OGA250VTAB()
		EndIf 
	ElseIf .Not. Empty(oNJJ:GetValue( "NJJ_TABELA"))
		//Atualiza campo "Status" na aba "Amostra" para "Classificado" caso seja "Verdadeiro" .T.
		If lClassOK
			oNJJ:SetValue( "NJJ_STSCLA", "1" )
		Else
			oNJJ:SetValue( "NJJ_STSCLA", "0" )
		EndIf
	EndIf

	IF  ValType(oView) == 'O' .and. oView:IsActive() .and. ( IsInCallStack("sfPreValLin") .OR. IsInCallStack("SETVALUE") )	//Tratamento para Execauto a View não Existe
		oView:Refresh()
	EndIF
	FWRestRows(aSaveLines)
	
	RestArea( aAreaNJR )
Return( .t. )

/** {Protheus.doc} fNJMStaFis
Retorna se alguma linha de NJM possui fiscal

@param: 	NIL
@return:	xRet - "1"=Sem Fiscal; "2"=Com Fiscal
@author: 	Marlon Richard Trettin
@since: 	04/02/2015
@Uso: 		OGA250 - Romaneio
*/
Function fNJMStaFis( pcOrigem )
	Local xRet 		:= "1" // Sem Fiscal
	Local nX 			:= 0
	Local nLinha 		:= 0

	If pcOrigem == "GRID"

		// Verifica se tem algum romaneio com NJM_STAFIS = "2" 	
		If OG250TFisc( NJJ->( NJJ_CODROM ) )
			xRet := "2" // Com Fiscal
		EndIf

	Else // pcOrigem == "VIEW"

		Private oModel	:= FwModelActive()
		Private oNJM		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJM" ), oModel:GetModel( "NJMUNICO" ))

		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			If .Not. oNJM:IsDeleted()
				If oNJM:GetValue("NJM_STAFIS") == "2" //Se possui fiscal
					xRet := "2" // Com Fiscal
				EndIf
			EndIf
		Next nX
		oNJM:GoLine( nLinha )

	EndIf

Return( xRet )

/** {Protheus.doc} fAtuQtdNJM
Recalcula e atualiza as qtdes dos itens do romaneio

@param: 	NIL
@return:	aRet - { nPerDiv, nQtdFco } 
@author: 	Marlon Richard Trettin
@since: 	04/02/2015
@Uso: 		OGA250 - Romaneio
*/
Function fAtuQtdNJM()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500") , oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJM		:= IIF(IsInCallStack("AGRA500") , oModel:GetModel( "AGRA500_NJM" ), oModel:GetModel( "NJMUNICO" )) //Protecao para usar funcao via AGRA500 
	Local nPerDiv := 0
	Local nQtdFco := 0
	Local nQtdAux := 0
	Local nX 		:= 0
	Local nLinha	:= 0
		
	////Validaç?o para considerar casas decimais caso seja romaneio sem pesagem 
	If  IsInCallStack("OGA251") .and. (oNJJ:GetValue( "NJJ_PESO3" ) != int(oNJJ:GetValue( "NJJ_PESO3" )) )
		//se o valor informado não for um numero inteiro usará as casas decimais.
		nDecPeso	:= TamSX3( "NJJ_PSLIQU" )[02]
	EndIf

	// Ajusta as quantidades nos itens do romaneio (NJM)
	nLinha := oNJM:GetLine()
	For nX := 1 to oNJM:Length()
		oNJM:GoLine( nX )
		If .Not. oNJM:IsDeleted()

			//Fazer os calculos usando o novo campo NJJ_PESO3 - DAGROGAP-446
			//nQtdAux := Round( ( oNJJ:GetValue( "NJJ_PSLIQU" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso )
			nQtdAux := Round( ( oNJJ:GetValue( "NJJ_PESO3" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) ), nDecPeso )

			If lExecAgoClas //Debloqueia a NJM caso for Atu Qtd Destino
				oNJM:SetNoUpdateLine(.F.)
			EndIf

			oNJM:SetValue( "NJM_QTDFCO", nQtdAux )

			If lExecAgoClas
				oNJM:SetNoUpdateLine(.T.)
			EndIf

			nQtdFco += nQtdAux
			nPerDiv += oNJM:GetValue( "NJM_PERDIV" )
		EndIf
	Next nX

	// Ajusta a ultima linha de NJM em caso de diferença de arredondamento
	If oNJJ:GetValue( "NJJ_PSLIQU" ) <> nQtdFco 
		If lExecAgoClas
			oNJM:SetNoUpdateLine(.F.)
		EndIf

		oNJM:SetValue( "NJM_QTDFCO", oNJM:GetValue( "NJM_QTDFCO" ) + ( oNJJ:GetValue( "NJJ_PESO3" ) - nQtdFco ) )
		
		If lExecAgoClas
			oNJM:SetNoUpdateLine(.F.)
		EndIf
	EndIf

Return { nPerDiv, nQtdFco } 

/** {Protheus.doc} OGA250ENTOK
Rotina para verificar dados do cliente e fornecedor associado a entidade informada

@param: 	NIL
@return:	.T. ou .F. 
@author: 	Marlon Richard Trettin
@since: 	07/12/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250ENTOK()
	Local aAreaAtu  := GetArea()
	Local lContinua	:= .T.
	Local cTipoNF	:= ''
	Local cCliFor	:= ''
	Local cLoja 	:= ''
	Local cAliasE	:= ''

	dbSelectArea( "NJM" ) // Comercializações do romaneio
	NJM->(dbSetOrder( 1 ))
	NJM->(dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
	While .Not. NJM->( Eof() ) .And. NJM->( NJM_FILIAL ) + NJM->( NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) 

		// Verifica se a entidade está ok
		//If .Not. AgrEntidOk( NJM->( NJM_CODENT ), NJM->( NJM_LOJENT ), NJJ->( NJJ_TIPO ) )
		//	Return( .F. )
		//EndIf

		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aCliFor := OGA250ClFr( NJM->( NJM_CODENT ), NJM->( NJM_LOJENT ), NJM->( NJM_TES ), NJM->( NJM_TIPO ), NJM->( NJM_QTDFIS ) )
		cTipoNF	:= aCliFor[ 1 ]
		cCliFor	:= aCliFor[ 2 ]
		cLoja 	:= aCliFor[ 3 ]
		cAliasE	:= aCliFor[ 4 ]

		lContinua := AgrEntidOk( cAliasE, cCliFor, cLoja )

		NJM->( dbSkip() )
	EndDo

	RestArea( aAreaAtu )
Return( lContinua )

/** {Protheus.doc} OGA250VQTD
Rotina para validar as quantidades e valores do romaneio

@param: 	NIL
@return:	lRetorno - .T. ou .F. 
@author: 	Marlon Richard Trettin
@since: 	02/02/2015
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VQTD()
	Local aAreaAtu  	:= GetArea()
	Local lRetorno	:= .T.
	Local nPerDiv 	:= 0
	Local nQtdFco	 	:= 0
	Local lSimbolico	:= IsInCallStack( "OGA251" ) .OR. IsInCallStack( "OGA455" )  // Se foi chamado pelo OGA251, é romaneio simbólico

	If NJJ->( NJJ_TIPENT ) $ "0|2" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção

		dbSelectArea( "NJM" ) // Comercializações do romaneio
		NJM->(dbSetOrder( 1 ))
		NJM->(dbSeek( NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM  ))
		While .Not. NJM->( Eof() ) .And. NJM->NJM_FILIAL + NJM->NJM_CODROM == NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM 

			If NJJ->( NJJ_TIPENT ) <> "2" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
				If NJM->( NJM_QTDFCO ) == 0 
					Agrhelp(STR0021, STR0441 + DescriSX3("NJM_QTDFCO") + STR0442 + NJM->NJM_ITEROM, STR0125 + STR0530 )
					//#AJUDA #O campo # não foi informado no item #Informe a Qtde Física do item do romaneio  # na aba 'Comercialização'.
					lRetorno := .F.
				EndIf
				If NJM->( NJM_PERDIV ) == 0 
					Agrhelp(STR0021, STR0441 + DescriSX3("NJM_PERDIV") + STR0442 + NJM->NJM_ITEROM, STR0126 + STR0530 )
					//#AJUDA #O campo # não foi informado no item #Informe o Percentual de Divisão do item do romaneio # na aba 'Comercialização'.
					lRetorno := .F.
				EndIf
			EndIf

			nPerDiv += NJM->( NJM_PERDIV )
			nQtdFco += NJM->( NJM_QTDFCO )

			NJM->( dbSkip() )
		EndDo

		If ( nPerDiv < 99 .Or. nPerDiv > 101 ) .And. nQtdFco > 0
			Agrhelp(STR0021,STR0443 + cValToChar(nPerDiv) + STR0408, STR0407) //#AJUDA #Percentual do rateio por Entidade/Contrato esta em #% #Ajuste o percentual dos itens do romaneio na aba 'Comercialização' para que totalize em 100%.
			lRetorno := .F.
		EndIf

		//Considera o novo campo NJJ_PESO3 para realizar a validação - DAGROGAP-446
		If nQtdFco <> NJJ->( NJJ_PESO3 ) .and. !_lFretOrig
			Agrhelp(STR0021,STR0444, STR0445+ cValToChar(nQtdFco) +STR0446 + cValToChar(NJJ->( NJJ_PESO3 )) )
			//#AJUDA #Soma da quantidade física dos itens do romaneio não confere com o peso líquido do romaneio. #Quantidade física: #. Peso líquido: 
			lRetorno := .F.
		EndIf

		If ABS( NJJ->( NJJ_PESO1 - NJJ_PESO2 ) ) <> NJJ->( NJJ_PSSUBT )
			Agrhelp(STR0021,   "["+RetTitle("NJJ_PESO1")+"] - ["+RetTitle("NJJ_PESO2")+"] "+STR0121+" ["+RetTitle("NJJ_PSSUBT")+"].", STR0447 )
			//#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem
			lRetorno := .F.
		EndIf

		If NJJ->( NJJ_PSBASE ) <> NJJ->( NJJ_PSSUBT - NJJ_PSDESC )
			Agrhelp(STR0021,   "["+RetTitle("NJJ_PSBASE")+"] "+STR0121+" ["+RetTitle("NJJ_PSSUBT")+"] - ["+RetTitle("NJJ_PSDESC")+"].", STR0447 )
			//#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem.
			lRetorno := .F.
		EndIf

		If NJJ->(ColumnPos('NJJ_PESEMB')) > 0 .and. __lnewNeg
			If NJJ->( NJJ_PSLIQU ) <> NJJ->( NJJ_PSBASE - NJJ_PSEXTR - NJJ_PESEMB)
				Agrhelp(STR0021,   "["+RetTitle("NJJ_PSLIQU")+"] "+STR0121+" ["+RetTitle("NJJ_PSBASE")+"] - ["+RetTitle("NJJ_PSEXTR")+"] - ["+RetTitle("NJJ_PESEMB")+"].", STR0447)
				//#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem.
				lRetorno := .F.
			EndIf
		Else
			If NJJ->( NJJ_PSLIQU ) <> NJJ->( NJJ_PSBASE - NJJ_PSEXTR )
				Agrhelp(STR0021,   "["+RetTitle("NJJ_PSLIQU")+"] "+STR0121+" ["+RetTitle("NJJ_PSBASE")+"] - ["+RetTitle("NJJ_PSEXTR")+"].", STR0447)
				 //#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem.
				lRetorno := .F.
			EndIf
		EndIf

	EndIf

	If NJJ->( NJJ_TIPENT ) == "2" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
		If .NOT. lSimbolico  //valida se o romaneio é simbolico  e altera a validação das quantidades
			If NJJ->( NJJ_PSLIQU ) <> 0 
				If NJJ->( NJJ_PSLIQU ) <> NJJ->( NJJ_QTDFIS ) .And. NJJ->( NJJ_TPFORM ) == "1"  .And. NJJ->( NJJ_TIPO ) <> "1"// Teste Camila. Se quantidade Física <> de Fiscal e Form. Próprio = SIM
					Agrhelp(STR0021,   "["+RetTitle("NJJ_PSLIQU")+"] "+STR0121+" ["+RetTitle("NJJ_QTDFIS")+"] ", STR0447 )
					//#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem.
					lRetorno := .F.
				EndIf
			EndIf
		Else
			If NJJ->( NJJ_PSLIQU ) <> 0 
				If NJJ->( NJJ_PSLIQU ) <> (NJJ->( NJJ_PSSUBT ) - NJJ->( NJJ_PSDESC)) .And. NJJ->( NJJ_TPFORM ) == "1"  .And. NJJ->( NJJ_TIPO ) <> "1" 
					Agrhelp(STR0021,   "["+RetTitle("NJJ_PSLIQU")+"] "+STR0121+" ["+RetTitle("NJJ_PSSUBT")+"] - ["+RetTitle("NJJ_PSDESC")+"].", STR0447 )
					//#AJUDA #está diferente de #Verifique os valores informados nos campos de pesagem.
					lRetorno := .F.
				EndIf
			EndIf

		EndIf
	EndIf
	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} OGA250ATUC
Rotina para Atualizar o romaneio Valida e atualiza dados do contrato

@param: 	cAlias - Tabela do Romaneio
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	15/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250ATUC( cAlias, nReg, nAcao, lAuto )

	local lRetorno:= OGA250C(cAlias, nReg, nAcao, lAuto)

Return( lRetorno )

/** {Protheus.doc} OGA250GTES
Abre a tela de diálogo para o usuário confirmar a TES

@param: 	pcTES			TES atual
@param: 	pcTipo			Tipo do romaneio
@return:	aRetTES[3]		3o. elemento do array de retorno (nova TES)
@author: 	Marlon Richard Trettin
@since: 	11/05/15
@Uso: 		OGA250 - Romaneio
*/
Function OGA250GTES( pcTES, pcTipo )
	Local aPergs 		:= {}
	Local aRetTES		:= {}
	Private cCadastro	:= STR0001		//"Romaneios"

	aAdd( aPergs ,{ 9, STR0145+" "+NJJ->( NJJ_CODROM ), 110, 40, .T. } ) //"Confirme / Altere a TES que será utilizada na geração da NF do Romaneio"
	aAdd( aPergs ,{ 9, " ", 70, 10, .T. } ) 
	aAdd( aPergs ,{ 1, RetTitle( "NJM_TES" ), pcTES , PesqPict( "NJM", "NJM_TES" ), "ExistCpo('SF4')", "SF4", ".T.", TamSX3( "NJM_TES" )[1], .T. } ) 

	While .T.
		If ParamBox( aPergs , STR0146, @aRetTES, , , .T./*lCentered*/, /*nPosx*/, /*nPosy*/, ; //"Confirmação de TES"
		/*oDlgWizard*/, /*cLoad*/, .F./*lCanSave*/, .F./*lUserSave*/ )
			// Verifica se a TES informada está de acordo com o tipo do romaneio
			If OGA250VTES( aRetTES[3], pcTipo )
				Return ( aRetTES[3] )
			EndIf
		Else
			Return ""
		EndIf
	EndDo

Return .T.

/** {Protheus.doc} OGA250VTES
Verifica se a TES informada está de acordo com o tipo do romaneio

@param: 	pcTES			TES atual
@param: 	pcTipo			Tipo do romaneio
@return:	.T. / .F. 
@author: 	Marlon Richard Trettin
@since: 	11/05/15
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VTES( pcTES, pcTipo )
	If pcTipo $ "2|4|6|8" .And. pcTES < "500"  // Se for romaneio de Saida e TES < "500"		
		Agrhelp(STR0021,STR0448+pcTES+STR0449, STR0450) //#AJUDA #A TES código # não é permitida para operação de Saida #Você deve selecionar uma TES de Saída ( maior ou igual a 500 ) para um Romaneio de Saída.
		Return( .F. )
	ElseIf pcTipo $ "3|5|7|9" .And. pcTES >= "500" // Se for romaneio de Entrada e TES >= "500"
		Agrhelp(STR0021,STR0448+pcTES+STR0451,STR0452) //#AJUDA #A TES código # não é permitida para operação de Entrada #Você deve selecionar uma TES de Entrada ( menor que 500 ) para um Romaneio de Entrada.
		Return( .F. )
	EndIf								
Return( .T. ) 

/** {Protheus.doc} OGA250VAUT
Valida quantidade do romaneio com as quantidades do contrato e autorizações

@param: 	cCodCTR (Codigo do Contrato escolhido no momento da Atualização )
@return:	lRetorno - .T. / .F.
@author: 	Marlon Richard Trettin
@since: 	11/02/15
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VAUT( cCodCTR, nQtAtuAut, nTotAdtv )
	Local nQtdDev		:= 0
	Local nQtdSld		:= 0
	Local nQtalocada	:= 0
	LOCAL nQtFixada		:= 0
	Local cItCadenci	:= ''

	Local nQtdEContr 	:= 0
	Local nQtdSContr 	:= 0
	Local nQtdRoman 	:= 0 
	Local nQtdAutor		:= 0
	Local ctipo			:= ''

	Default cCodCTR := '' 

	Private cPicPeso	:= SuperGetMV("MV_OGPICPS",,"@E 999,999,999")

	IF NJR->NJR_CLASSP == "2"
		nQtdEContr := NJR->NJR_QTEFIS
		nQtdSContr := NJR->NJR_QTSFIS

		If NJM->( NJM_TPFORM ) = "1" .and. NJJ->NJJ_TIPENT <> "1" .and. NJJ->NJJ_TIPENT <> "2"
			nQtdRoman := NJM->( NJM_QTDFCO )
		Else
			nQtdRoman := NJM->( NJM_QTDFIS )
		EndIf	
	ELSE
		nQtdEContr := NJR->NJR_QTEFCO
		nQtdSContr := NJR->NJR_QTSFCO
		nQtdRoman  := NJM->NJM_QTDFCO
	EndIf	
    
	If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
		//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM	
		IF NJR->NJR_CLASSF == "2" .AND. NJJ->(NJJ_TIPO) == '5' .and.  NJJ->(NJJ_TPFRET)  = 'F' .and. NJM->( NJM_TPFORM ) = "1"  
			nQtdEContr := NJR->NJR_QTEFIS
			nQtdSContr := NJR->NJR_QTSFIS
			nQtdRoman := NJM->( NJM_QTDFIS )
		EndIf	
	ENDIF

	If   NJJ->( NJJ_TIPO ) == "3" ;		// 3= (E) Entrada para Deposito
	.OR. NJJ->( NJJ_TIPO ) == "5"		// 5= (E) Entrada por Compra                   

		nQtdDev  := 0
		If NJR->( NJR_TIPO ) == "1"		// 1=Compra
			nQtdDev := nQtdSContr
		EndIf

		If AGRColPos('NJR_TPEXC') .and. NJR->NJR_TPEXC == '3' .and. NJR->(NJR_TOLENT) > 0   //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
			nQtdSld := ((NJR->( NJR_AUTENT ) - nTotAdtv - nQtAtuAut) - ( nQtdEContr - nTotAdtv - nQtdDev )) + ((NJR->( NJR_AUTENT ) - nTotAdtv - nQtAtuAut) * (NJR->(NJR_TOLENT)/100))
		Else
			nQtdSld := (NJR->( NJR_AUTENT ) - ( nQtdEContr - nQtdDev ))
		EndIf 

		If nQtdRoman > nQtdSld  
			Agrhelp(STR0021,STR0453,STR0454+Transform( nQtdSld, cPicPeso )) //#AJUDA #Quantidade autorizada de entrada no contrato insuficiente! #Quantidade autorizada disponível: 
			Return .f.
		EndIf

	ElseIf NJJ->( NJJ_TIPO ) == "6" ;	// 6= (S) Devolucao de Deposito
	.OR. NJJ->( NJJ_TIPO ) == "8"		// 8= (S) Devolucao de Compra

		nQtdSld := nQtdEContr - nQtdSContr

		If nQtdRoman > nQtdSld 
			Agrhelp(STR0021,STR0455,STR0454+Transform( nQtdSld, cPicPeso )) //#AJUDA #Quantidade autorizada de saida no contrato insuficiente! #Quantidade autorizada disponível: 
			Return .f.
		EndIf

		//0=Físico;1=Gerencial;2=Simbolico;3=Retenção
		IF NJJ->NJJ_TIPENT  <> "3" .And. nQtdRoman > NJR->( NJR_AUTSAI ) 
			Agrhelp(STR0021,STR0455,STR0454 +Transform( nQtdSld, cPicPeso )) //#AJUDA #Quantidade autorizada de saida no contrato insuficiente! #Quantidade autorizada disponível: 
			Return .f.
		EndIf

		IF NJJ->( NJJ_TIPO ) == "8" .and. NJR->NJR_MODELO == '3' // Romaneio de dev. Compra e Contrato automatico
			cItCadenci := Replicate("0",TamSx3('NNY_ITEM')[1])
			cItCadenci := Soma1(cItCadenci)	//Sempre será a 1a (001) pois contratos automaticos somente possuem 1 cadencia
			// Tipo de Contrato 2 , para identificar os contratos de venda vinculados ao contrato de compra q esta sendo passado
			nQtalocada := OG285CTRV(NJR->NJR_CODCTR,cItCadenci, NJR->NJR_QTDINI, '2' )
			IF nQtalocada > 0 //Indica que tem Qtidade Vinculada ( Verificando vinculo das Cadencias ...)
				IF nQtAlocada > (nQtdSld - nQtdRoman ) 
					Agrhelp(STR0021,STR0456+NJR->NJR_CODCTR+STR0457,STR0458+Transform( nQtalocada, cPicPeso )) //#AJUDA #O contrato  #possui Quantidade vinculada, em um ou mais contratos de vendas.#Favor excluir o vinculo. Quantidade Vinculada: 
					Return .f.
				EndIF
			ElseIF (nQtFixada := fQtFixCtr( NJR->NJR_codctr ) ) > 0		// Indica que Tem Qt Fixada no contrato Automatico ( Verificando se possui Fixação ... )
				IF nQtFixada > (nQtdSld - nQtdRoman )
					Agrhelp(STR0021,STR0456+NJR->NJR_CODCTR+STR0459,STR0460+Transform( nQtFixada, cPicPeso )) //#AJUDA #O contrato # possui Quantidade Fixada.#Favor Alterar/Exluir Fixação; Quantidade Fixada: 
					Return .f.
				EndIF 			   
			EndIF
		EndIF
	ElseIf NJJ->( NJJ_TIPO ) == "2" ;	// 2= (S) Remessa para Deposito
	.OR. NJJ->( NJJ_TIPO ) == "4"		// 4= (S) Saida por Venda             

		nQtdDev := 0
		If NJR->( NJR_TIPO ) $ "1|2"	// 1=Compra; 2=Venda
			nQtdDev := nQtdEContr
		EndIf

		If AGRColPos('NJR_TPEXC') .and. NJR->NJR_TPEXC == '3' .and. NJR->(NJR_TOLENT) > 0   //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
			nQtdSld := ((NJR->( NJR_AUTSAI ) - nTotAdtv - nQtAtuAut) - ( nQtdSContr - nTotAdtv - nQtdDev )) + ((NJR->( NJR_AUTSAI ) - nTotAdtv - nQtAtuAut) * (NJR->(NJR_TOLENT)/100))
		Else 
			nQtdSld := (NJR->( NJR_AUTSAI ) - ( nQtdSContr - nQtdDev ))
		EndIf

		If nQtdRoman > nQtdSld
			Agrhelp(STR0021,STR0461,STR0454+Transform( nQtdSld, cPicPeso )) //#AJUDA #Quantidade autorizada de saida no contrato insuficiente! #Quantidade autorizada disponível: 
			Return .f.
		EndIf

	ElseIf NJJ->( NJJ_TIPO ) == "7" ;	// 7= (E) Devolucao de Remessa
	.OR. NJJ->( NJJ_TIPO ) == "9"		// 9= (E) Devolucao de Venda

		nQtdSld := nQtdSContr - nQtdEContr

		If nQtdRoman > nQtdSld 
			Agrhelp(STR0021,STR0453,STR0454+Transform( nQtdSld, cPicPeso )) //#AJUDA ##Quantidade autorizada de entrada no contrato insuficiente!#Quantidade autorizada disponível: 
			Return .f.
		EndIf
		If nQtdRoman > NJR->( NJR_AUTENT ) 
			Agrhelp(STR0021,STR0453,STR0454+Transform( nQtdSld, cPicPeso )) //#AJUDA ##Quantidade autorizada de entrada no contrato insuficiente!#Quantidade autorizada disponível: 
			Return .f.
		EndIf

		IF NJJ->NJJ_TIPO == "9" .and. NJR->NJR_MODELO == '3' 		// Romaneio de dev. de Venda de Contrato automatico
			cItCadenci := Replicate("0",TamSx3('NNY_ITEM')[1])
			cItCadenci := Soma1(cItCadenci)	//Sempre será a 1a (001) pois contratos automaticos somente possuem 1 cadencia
			// Tipo de Contrato 1 , para identificar os contratos de compra vinculados ao contrato de compra q esta sendo passado
			nQtalocada := OG285CTRV(NJR->NJR_CODCTR,cItCadenci, NJR->NJR_QTDINI, '1' )
			IF nQtalocada > 0							//Indica que tem Qtidade Vinculada ( Verificando vinculo das Cadencias ...)
				IF nQtAlocada > (nQtdSld - nQtdRoman )
					Agrhelp(STR0021,STR0462,STR0463+Transform( nQtalocada, cPicPeso )) //#AJUDA ##Este contrato possui quantidade vinculada, em um ou mais contratos de compras.#Favor excluir o vinculo. Quantidade Vinculada: 
					Return .f.
				EndIF
			ElseIF (nQtFixada := fQtFixCtr( NJR->NJR_codctr ) ) > 0		// Indica que Tem Qt Fixada no contrato Automatico ( Verificando se possui Fixação ... )
				IF nQtFixada > (nQtdSld - nQtdRoman )
					Agrhelp(STR0021,STR0456+NJR->NJR_CODCTR+STR0459,STR0465+Transform( nQtFixada, cPicPeso )) //#AJUDA #O contrato # Possui Quantidade Fixada. #Favor Alterar/Exluir Fixação; Quantidade Fixada: 
					Return .f.
				EndIF 			   
			EndIF
		EndIF

	EndIf
	
	// *** Validação para Controle de AUTORIZAÇÃO
	// Quando for retenção não exigir que seja informada autorização
	If NJJ->NJJ_TIPENT  <> "3" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção

		IF NJR->( NJR_CTRLLG ) = "1" /* Ctrl.Logist -> 1=Sim */
			If Empty(NJM->NJM_CODAUT) .And. ;
			(( NJJ->( NJJ_TIPO) $ "1|3|5|7|9" .And. NJR->( NJR_CTRLCD ) $ "2|3" ) .Or.  ;
			( NJJ->( NJJ_TIPO) $ "2|4|6|8"   .And. NJR->( NJR_CTRLCD ) $ "1|3" )) 
				Agrhelp(STR0021,STR0466+"'"+DescriSX3("NJM_CODAUT")+"'"+STR0467,STR0468+"'"+DescriSX3("NJM_CODAUT")+"'")
			    //#AJUDA #Para contratos com controle logistico igual a 1=Sim, o campo # deve ser informado #Favor preencher o campo
				Return .F.
			Endif
		ElseIF !Empty(NJM->NJM_CODAUT)
			Agrhelp(STR0021,STR0469+"'"+DescriSX3("NJM_CODAUT")+"'"+STR0470,STR0471+"'"+DescriSX3("NJM_CODAUT")+"'")
			//#AJUDA #Para contratos com controle logistico igual a 2=Não, o campo # não pode ser informado #Favor verificar o preenchimento do campo 
			Return .F.
		Endif
	Endif

	// Validar para que contrato/autorizacao do romaneio (se informado) seja igual ao contrato/autorizacao na comercializacao
	IF !Empty( NJJ->NJJ_CODCTR ) .And. ( (NJJ->NJJ_CODCTR <> NJM->NJM_CODCTR .and. Empty(cCodCtr) ) .Or. NJJ->NJJ_CODAUT <> NJM->NJM_CODAUT)	
		Agrhelp(STR0021,STR0472+NJM->NJM_CODAUT+STR0473+NJM->NJM_ITEROM+STR0474+NJJ->NJJ_CODAUT+STR0475,STR0476)
		//#AJUDA #O codigo de autorização # informado no item # está divergente do codigo de autorização # informado no cabeçalho do romaneio O codigo de autorização deve ser igual para todo o romaneio.
		Return .F.
	EndIf
	
	// Validar se a Autorizacao informada possui saldo suficiente para o romaneio
	IF !Empty( NJM->NJM_CODAUT )
		dbSelectArea( "NJP" ) // Autorizacao
		NJP->(dbSetOrder( 1 ))
		IF NJP->(dbSeek( xFilial( "NJP" ) + NJM->( NJM_CODCTR ) + NJM->( NJM_CODAUT ) ))
			//Validar para que o tipo do Romaneio seja igual ao tipo da Autorizacao
			If ( NJJ->( NJJ_TIPO ) $ "1|3|5|7|9" .And. NJP->(NJP_TIPO) <> "E" );   // Entrada
		     .Or. ( NJJ->( NJJ_TIPO ) $ "2|4|6|8"   .And. NJP->(NJP_TIPO) <> "S" )    // Saída
				ctipo = iif(NJJ->( NJJ_TIPO ) $ "2|4|6|8", "Saida", "Entrada")
				Agrhelp(STR0021,STR0477,STR0478+Alltrim(FWGetSX5("K5",NJJ->( NJJ_TIPO ))[1][4])+STR0479+cTipo )
				//#AJUDA #Tipo da Autorização selecionada é diferente do tipo do Romaneio #Para Romaneio do tipo # deve ser utilizado Autorização do tipo 
				Return .F.
			Else
				IF NJP->( NJP_STATUS ) == "E" // E=Encerrada
					Agrhelp(STR0021,STR0480,STR0481) //#AJUDA #Autorização informada encontra-se encerrada. #Informe uma Autorização com status Aberta ou Iniciada.
					Return .F.
				Endif

				IF !Empty(NJP->( NJP_TALHAO )) .And. ( !Empty(NJM->NJM_TALHAO) .AND. NJP->( NJP_TALHAO ) <> NJM->NJM_TALHAO )
					Agrhelp(STR0021, STR0482+NJM->NJM_TALHAO+STR0473+NJM->NJM_ITEROM+STR0483,STR0484)
					//#AJUDA #Talhão # informado no item # do romaneio é diferente do talhão da Autorização.#Informe o talhão compativel com a Autorização.
					Return .F.
				EndIf

				IF ( dDataBase < NJP->(NJP_DATINI) .Or. dDataBase > NJP->(NJP_DATFIM) )
					Agrhelp(STR0021,STR0485,STR0486 ) //#AJUDA #Autorização informada encontra-se fora do periodo de validade.#Informe uma Autorização dentro do periodo vigente.
					Return .F.
				Endif

				//Controle Contrato 1 = Origem ou 2-Destino					
				IF NJR->NJR_CLASSP == "2"
					nQtdAutor := NJP->NJP_QTDFIS
				Else
					nQtdAutor := NJP->NJP_QTDFCO
				EndIf

				If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
					//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM
					IF NJR->NJR_CLASSF == "2" .AND.  NJJ->(NJJ_TIPO) == '5' .and. NJJ->(NJJ_TPFRET) = 'F' .and. NJM->( NJM_TPFORM ) == "1" 
						nQtdAutor := NJP->NJP_QTDFIS
					EndIf	
				EndIf

				IF ( NJP->(NJP_QTDAUT) + NJP->(NJP_QTDEXC) ) < ( nQtdAutor + nQtdRoman )
					Agrhelp(STR0021,STR0487,STR0488+Transform( nQtdSld, cPicPeso ) )				
					//#AJUDA #Quantidade informada no romaneio é superior a quantidade autorizada! #Quantidade Disponível: 
					Return .F.
				EndIf
			EndIf

		Else
			Agrhelp(STR0021,STR0489+NJM->( NJM_CODAUT )+STR0490,STR0491)								
			//#AJUDA Autorização # informada não foi encontrada. #Informe uma Autorização válida.
			Return .F.
		EndIf
	EndIf 

Return .T.

Function OGA250GSubPr( nItens )
	Local lRetorno := .t.

	dbSelectArea( "NJM" )
	If RecLock( "NJM", .t. )
		cItemSeq	:= StrZero( nItens, TamSX3( "NJM_ITEROM" )[1] )
		NJM->( NJM_FILIAL ) := QryNJM->NJM_FILIAL
		NJM->( NJM_CODROM ) := QryNJM->NJM_CODROM
		NJM->( NJM_TIPO )   := QryNJM->NJM_TIPO
		NJM->( NJM_ITEROM ) := cItemSeq
		NJM->( NJM_CODENT ) := QryNJM->( NJM_CODENT )
		NJM->( NJM_LOJENT ) := QryNJM->( NJM_LOJENT )
		NJM->( NJM_TRANS )  := QryNJM->( NJM_TRANS )
		NJM->( NJM_CODSAF ) := QryNJM->( NJM_CODSAF )
		NJM->( NJM_CODPRO ) := NNH->( NNH_CODPRO )
		NJM->( NJM_PERDIV ) := 0
		NJM->( NJM_QTDFCO ) := (NJK->( NJK_QTDDES ) * QryNJM->( NJM_PERDIV )) / 100 
		NJM->( NJM_QTDFIS ) := (NJK->( NJK_QTDDES ) * QryNJM->( NJM_PERDIV )) / 100 
		NJM->( NJM_TPFORM ) := QryNJM->( NJM_TPFORM )  
		NJM->( NJM_DOCSER ) := QryNJM->( NJM_DOCSER  )
		NJM->( NJM_DOCNUM ) := QryNJM->( NJM_DOCNUM )
		NJM->( NJM_DOCEMI ) := QryNJM->( NJM_DOCEMI )
		NJM->( NJM_DOCESP ) := QryNJM->( NJM_DOCESP )
		NJM->( NJM_CHVNFE ) := QryNJM->( NJM_CHVNFE )
		NJM->( NJM_CODCTR ) := QryNJM->( NJM_CODCTR )

		msUnLock()
	EndIf

Return( lRetorno )

/** {Protheus.doc} OGA250NF
Rotina para fechamento do romaneio

@param cAlias, Character, Tabela do Romaneio
@param nReg, numeric, Registro para atualizaca
@param nAcao, numeric, Tipo de atualizacao
@param lAuto, logical, Se automatica para nao exibir mensagens
@author	Vitor Alexandre de Barba
@since: 	13/10/2014
@Uso: 		OGA250 - Romaneio
@type function
*/
Function OGA250NF(cAlias, nReg, nAcao, lAuto)
	Local cNumOP :=    Nil
	Local lRetorno := .T.

	//PE para validação de usuário. A continuação da rotina depende do retorno do PE.
	If EXISTBLOCK ("OG250NFVD")
		lRetorno := ExecBlock("OG250NFVD",.F.,.F.,{NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM})
	EndIf

	If lRetorno .AND. NJJ->(ColumnPos('NJJ_NUMOP')) > 0 .and. __lnewNeg
		cNumOP :=  Iif(ExistBlock("AGRX50OP"),ExecBlock('AGRX50OP',.F.,.F.,),'')
		If Empty(cNumOP)
			cNumOP := NJJ->NJJ_NUMOP
		Endif
	EndIf

	if lRetorno

		lRetorno := OGA250G(cAlias, nReg, nAcao, lAuto, cNumOP)
		If NJJ->(FieldPos("NJJ_CODTRF") > 0)
				//se for Rom de Transferencia, atualizo o status. 
			If lRetorno .and. !Empty(NJJ->NJJ_CODTRF) 	
			
				OGA455STS(NJJ->NJJ_CODTRF)

			EndIf
		EndIf
        
        /*INTEGRAÇÃO PIMS - EAI*/
       /** 
	   CHAMDA DE INTEGRAÇÃO COMENTADA, ISSUE DAGROOGD-13709 e DAGROOGD-13798 - ver comentarios das issues
	   Ajustado para que a Integração seja a principio apenas para romaneio tipo entrada produção e realizada dentro da transação do confirmação do romaneio(OGA250G)
	   If lRetorno .AND. !Empty(NJJ->NJJ_ORDCLT) .And. NJJ->NJJ_PSLIQU > 0
            lIntegracao := AGRA500Int()
        EndIf
		**/
	endIf

	//Atualizar os valores financeiros no contrato - DAGROCOM-3521	
	If __lnewNeg
		if lRetorno
			OGX310(1,NJJ->NJJ_CODROM) 
		endIf
	EndIf 

	/* necessário setar novamente, pois ao gerar nota fiscal o VK_F10 é substituído no MATA*/
	fSetKey()

Return(lRetorno)

/** {Protheus.doc} OG250TFisc
Verifica se o romaneio realmente possui os documentos fiscais relacionados. Caso não, ajusta os status do romaneio (auto-healing).

@param: 	pcCodRom - Código do romaneio
@return:	lTemFiscal = .T. romaneio tem fiscal / .F. romaneio não tem fiscal
@author: 	Marlon Richard Trettin
@since: 	24/03/2015
@Uso: 		SIGAAGR
*/
Function OG250TFisc( pcCodRom )
	Local lTemFiscal 	:= .F.
	Local lSemFiscal    := .F.
	Local aAreaAtu  	:= GetArea()
	Local cQryNJM		:= GetNextAlias() 
	Local aCliFor		:= {}
	Local cTipoNF		:= ""
	Local cCliFor		:= ""
	Local cLoja 		:= ""


	If  __lnewNeg
		// Para Venda a ordem, só muda status para confirmado se todas as NJM tiverem nota gerada
		BeginSql Alias cQryNJM
			Select NJM_CODROM, NJM_TIPO, NJM_DOCNUM, NJM_DOCSER, NJM_CODENT, NJM_LOJENT, NJM_TES, NJM_QTDFIS, NJM_PEDIDO, R_E_C_N_O_ AS NJM_RECNO
			From %table:NJM% NJM
			Where NJM.NJM_FILIAL = %xFilial:NJM% 
			And NJM.NJM_CODROM = %Exp:pcCodRom%
			And NJM.NJM_STAFIS = %Exp:"1"%
			And (NJM.NJM_SUBTIP = %Exp:"45"% Or NJM.NJM_SUBTIP = %Exp:"46"%) 	  
			And NJM.%NotDel%
		EndSql
		dbGoTop()
		// Se achou algum NJM_STAFIS == "1"
		If !(cQryNJM)->( Eof() )
			lSemFiscal    := .T.
		EndIf
		(cQryNJM)->( dbCloseArea( ))

	EndIf


	// Verifica se para todos os registros de NJM_STAFIS = 2 há realmente um documento fiscal relacionado
	BeginSql Alias cQryNJM
		Select NJM_CODROM, NJM_TIPO, NJM_DOCNUM, NJM_DOCSER, NJM_CODENT, NJM_LOJENT, NJM_TES, NJM_QTDFIS, NJM_PEDIDO, R_E_C_N_O_ AS NJM_RECNO
		From %table:NJM% NJM
		Where NJM.NJM_FILIAL = %xFilial:NJM% 
		And NJM.NJM_CODROM = %Exp:pcCodRom%
		And NJM.NJM_STAFIS = %Exp:"2"%		  
		And NJM.%NotDel%
	EndSql
	dbGoTop()
	// Se achou algum NJM_STAFIS == "2"
	If !(cQryNJM)->( Eof() )

		While !(cQryNJM)->( Eof() )

			//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
			aCliFor := OGA250ClFr( (cQryNJM)->( NJM_CODENT ), (cQryNJM)->( NJM_LOJENT ), (cQryNJM)->( NJM_TES ), (cQryNJM)->( NJM_TIPO ), (cQryNJM)->( NJM_QTDFIS ) )
			cTipoNF	:= aCliFor[ 1 ]
			cCliFor	:= aCliFor[ 2 ]
			cLoja 	:= aCliFor[ 3 ]

			If (cQryNJM)->( NJM_TIPO ) $ "3|5|7|9" // Se for romaneio de ENTRADA

				DbSelectArea( "SF1" )
				SF1->(DbSetOrder( 1 )) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If !SF1->(DbSeek(FWxFilial( "SF1" ) + (cQryNJM)->( NJM_DOCNUM ) + (cQryNJM)->( NJM_DOCSER ) + cCliFor + cLoja ))

					// Reabre o romaneio de entrada que não possui documento fiscal relacionado
					OGX145Reabre( xFilial( "NJM" ), pcCodRom, (cQryNJM)->( NJM_DOCSER ), (cQryNJM)->( NJM_DOCNUM ) )

				Else
					lTemFiscal := .T.
				EndIf

			Else	// Se for romaneio de SAIDA

				If cPaisLoc <> "PAR"
					DbSelectArea( "SC5" )
					SC5->(DbSetOrder( 1 )) //C5_FILIAL+C5_NUM
					If SC5->(DbSeek( FWxFilial( "SC5" ) + (cQryNJM)->( NJM_PEDIDO ) ))

						DbSelectArea( "SF2" )
						SF2->(DbSetOrder( 1 ))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						If !SF2->(DbSeek( FWxFilial( "SF2" ) + SC5->( C5_NOTA ) + SC5->( C5_SERIE ) + SC5->( C5_CLIENTE ) + SC5->( C5_LOJACLI ) ))

							// Reabre o romaneio de saída que não possui documento fiscal relacionado
							OGX165Reabre( FWxFilial( "NJM" ), pcCodRom, (cQryNJM)->( NJM_RECNO ), (cQryNJM)->( NJM_PEDIDO ) )

						Else
							lTemFiscal := .T.
						EndIf

					Else // Se não achou pedido de venda
						DbSelectArea( "SF2" )
						SF2->(DbSetOrder( 1 )) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						If !SF2->(DbSeek( FWxFilial( "SF2" ) + SC5->( C5_NOTA ) + SC5->( C5_SERIE ) + SC5->( C5_CLIENTE ) + SC5->( C5_LOJACLI ) ))

							// Reabre o romaneio de saída que não possui documento fiscal relacionado
							OGX165Reabre( FWxFilial( "NJM" ), pcCodRom, (cQryNJM)->( NJM_RECNO ), (cQryNJM)->( NJM_PEDIDO ) )
						Else
							lTemFiscal := .T.
						EndIf
						// Reabre o romaneio de saída que não possui documento fiscal relacionado
						OGX165Reabre( FWxFilial( "NJM" ), pcCodRom, (cQryNJM)->( NJM_RECNO ), "" )

					EndIf
				Else //Para localização Paraguai, não é gerado pedido de venda
					DbSelectArea( "SF2" )
					SF2->(DbSetOrder( 1 )) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
					If !SF2->(DbSeek( FWxFilial( "SF2" ) + (cQryNJM)->( NJM_DOCNUM ) + (cQryNJM)->( NJM_DOCSER ) + cCliFor + cLoja ))

						// Reabre o romaneio de saída que não possui documento fiscal relacionado
						OGX165Reabre( xFilial( "NJM" ), pcCodRom, (cQryNJM)->( NJM_RECNO ), (cQryNJM)->( NJM_PEDIDO ) )

					Else
						lTemFiscal := .T.
					EndIf

				EndIf

			EndIf	

			(cQryNJM)->( DbSkip() )
		EndDo				

		NJJ->( DbSetOrder( 1 ) )
		If NJJ->( DbSeek( xFilial( "NJJ" ) + pcCodRom ) )
			If lTemFiscal .And. !lSemFiscal

				// Atualiza o registro de NJJ com o primeiro de NJM
				OGX140AtNJJ( xFilial( "NJJ" ), pcCodRom )

			Else				// Senão, NÃO tem fiscal
				If RecLock( "NJJ", .f. )
					NJJ->( NJJ_STATUS ) := iIf( NJJ->( NJJ_STATUS )=="3", "2", NJJ->( NJJ_STATUS ) ) //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
					NJJ->( NJJ_STAFIS ) := "1" //1=Sem Fiscal;2=Com Fiscal;3=Gerencial
					NJJ->( msUnLock() )
				EndIf
			EndIf
		EndIf

	Else // Se não achou nenhum NJM_STAFIS = "2" (ou seja, NÃO tem fiscal )

		NJJ->( DbSetOrder( 1 ) )
		If NJJ->( DbSeek( xFilial( "NJJ" ) + pcCodRom ) )
			If NJJ->( NJJ_STAFIS ) == "2" // Se NJJ_STAFIS="2" (Com Fiscal)
				If RecLock( "NJJ", .f. )				
					NJJ->( NJJ_STATUS ) := iIf( NJJ->( NJJ_STATUS )=="3", "2", NJJ->( NJJ_STATUS ) ) //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
					NJJ->( NJJ_STAFIS ) := "1" //1=Sem Fiscal;2=Com Fiscal;3=Gerencial
					NJJ->( msUnLock() )
				EndIf 
			ElseIf	NJJ->( NJJ_STAFIS ) == "1" .And. NJJ->( NJJ_STATUS )=="3" // Se NJJ_STAFIS="1" (Sem Fiscal) e NJJ_STATUS="3" (Confirmado)
				If RecLock( "NJJ", .f. )				
					NJJ->( NJJ_STATUS ) := "2" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
					NJJ->( msUnLock() )
				EndIf
			EndIf
		EndIf

	EndIf
	(cQryNJM)->( dbCloseArea( ) )

	RestArea( aAreaAtu )
Return( lTemFiscal )

/** {Protheus.doc} OGA250ATUF
Rotina para atualização dos valores financeiros provisorios do contrato

@param: 	Nil
@author: 	Vitor Alexandre de Barba
@since: 	08/11/2014
@Uso: 		OG - Originação de Grãos
*/
Function OGA250ATUF(cCodCtr, nQuant, cTipo)


	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtr ) )

	If NJR->(ColumnPos('NJR_CODNGC')) > 0 .and. __lnewNeg
		If Empty(NJR->NJR_CODNGC)//trata se é oriundo de novo negócio, se nao não chama
			OGA250ATUQ( nQuant,cTipo )
		EndIf
	Else
		OGA250ATUQ(nQuant, cTipo)
	EndIf


Return( Nil )


/** {Protheus.doc} OGA250ATUG
Rotina para atualização dos valores financeiros provisorios do contrato

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	09/04/2019
@Uso: 		OG - Originação de Grãos
*/

Function OGA250ATUQ(nQuant, cTipo)
	Local nSldAD	:= 0
	Local nVlrUni := 0

	nVlrUni := IIf( NJR->( NJR_MOEDA ) != 1, xMoeda( NJR->( NJR_VLRUNI ), NJR->NJR_MOEDA, 1, dDataBase ), NJR->( NJR_VLRUNI ) )

	nSldAD := xMoeda(((nQuant * nVlrUni) / AGRX001( NJR->NJR_UMPRC , NJR->NJR_UM1PRO ,1, NJR->NJR_CODPRO)), 1, NJR->( NJR_MOEDA ), dDataBase ) 

	NJ0->( dbSetORder( 1 ) )
	NJ0->( dbSeek( FWxFilial( "NJ0" ) + NJR->( NJR_CODENT ) + NJR->( NJR_LOJENT ) ) )

	If NJR->( NJR_TIPO ) = "1"

		BeginSql Alias "QrySE2"
			Select
			SE2.*
			From
			%table:SE2% SE2
			Where
			SE2.E2_FILIAL = %xFilial:SE2% And
			SE2.E2_PREFIXO = 'CTR' And
			SE2.E2_NUM = %Exp:NJR->( NJR_CODCTR )% And
			SE2.E2_TIPO = 'PR' And
			SE2.E2_FORNECE = %Exp:NJ0->( NJ0_CODFOR )% And
			SE2.E2_LOJA = %Exp:NJ0->( NJ0_LOJFOR )% And
			SE2.%NotDel%
			Order By
			SE2.E2_PARCELA
		EndSql

		//Lógica de Baixa de Saldo e Eliminação de Título - Contas a Pagar
		While .Not. QrySE2->( Eof() ) .And. nSldAD > 0

			SE2->( dbSetOrder( 1 ) )
			SE2->( dbGoto( QrySE2->( R_E_C_N_O_ ) ) )

			IF cTipo == "1"	//aditamento		    
				SE2->( RecLock( "SE2", .f. ) )
				SE2->( E2_VALOR ) += nSldAD 
				SE2->( E2_SALDO ) += nSldAD 
				SE2->( msUnlock() )

				nSldAD := 0 
			Else 
				If SE2->( E2_VALOR ) > nSldAD

					SE2->( RecLock( "SE2", .f. ) )
					SE2->( E2_VALOR ) -= nSldAD 
					SE2->( E2_SALDO ) -= nSldAD 
					SE2->( msUnlock() )

					nSldAD := 0
				Else
					nSldAD -= SE2->( E2_VALOR )

					SE2->( RecLock( "SE2", .f. ) )
					SE2->( dbDelete() )
					SE2->( msUnlock() )

				EndIf
			Endif	
			QrySE2->( dbSkip() )
		EndDo
		QrySE2->( dbCloseArea( ) )
	EndIf

	If NJR->( NJR_TIPO ) = "2"
		BeginSql Alias "QrySE1"
			Select
			SE1.*
			From
			%table:SE1% SE1
			Where
			SE1.E1_FILIAL = %xFilial:SE1% And
			SE1.E1_PREFIXO = 'CTR' And
			SE1.E1_NUM = %Exp:NJR->( NJR_CODCTR )% And
			SE1.E1_TIPO = 'PR' And
			SE1.E1_CLIENTE = %Exp:NJ0->( NJ0_CODCLI )% And
			SE1.E1_LOJA = %Exp:NJ0->( NJ0_LOJCLI )% And
			SE1.%NotDel%
			Order By
			SE1.E1_PARCELA
		EndSql

		//Lógica de Baixa de Saldo e Eliminação de Título - Contas a Receber
		While .Not. QrySE1->( Eof() ) .And. nSldAD > 0

			SE1->( dbSetOrder( 1 ) )
			SE1->( dbGoto( QrySE1->( R_E_C_N_O_ ) ) )

			If SE1->( E1_VALOR ) > nSldAD
				SE1->( RecLock( "SE1", .f. ) )
				SE1->( E1_VALOR ) -= nSldAD * IIf( cTipo == "2", 1, -1 )
				
				If SE1->(E1_TXMOEDA) > 0
					SE1->( E1_VLCRUZ) = SE1->( E1_VALOR ) * SE1->(E1_TXMOEDA)
				Else
					SE1->( E1_VLCRUZ) = xMoeda( SE1->( E1_VALOR ), SE1->( E1_MOEDA ), 1, dDataBase)
				Endif
								
				SE1->( E1_SALDO ) -= nSldAD * IIf( cTipo == "2", 1, -1 )
				SE1->( msUnlock() )

				nSldAD := 0
			Else
				nSldAD -= SE1->( E1_VALOR )

				SE1->( RecLock( "SE1", .f. ) )
				SE1->( dbDelete() )
				SE1->( msUnlock() )
			EndIf

			QrySE1->( dbSkip() )
		EndDo
		QrySE1->( dbCloseArea( ) )
	EndIf

Return (nil)

/** {Protheus.doc} OGA250ACTR
//**   X3_VALID->NJJ_TIPO  **\\

@param: 	Nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Ana Laura Olegini
@since: 	15/07/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250ACTR()
	Local lRetorno		:= .T.
	Local nLinha		:= 0
	Local nX      		:= 0
	Local cCtrBnc     	:= Space(TAMSX3("NJM_CODCTR")[1])
	Local cDtrBnc     	:= Space(TAMSX3("NJR_DESCRI")[1])
	Local oModel		:= FwModelActive()
	Local oNJJ			:= IIF(FWIsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), iif(FWIsInCallStack("AGRA550")  .OR. IsInCallStack("OGWSPUTATU"),oModel:GetModel( "AGRA550_NJJ" ) ,oModel:GetModel( "NJJUNICO" ) )  ) //Protecao para usar funcao via AGRA500
	Local oNJM			:= IIF(FWIsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJM" ), iif(FWIsInCallStack("AGRA550")  .OR. IsInCallStack("OGWSPUTATU"),oModel:GetModel( "AGRA550_NJM" ) ,oModel:GetModel( "NJMUNICO" ) )) //Protecao para usar funcao via AGRA500 
	Local nOperation	:= oModel:GetOperation()

	If nOperation = 4 	//*4=Alteracao
		//Se o tipo que ja existe for ENTRADA - entra
		If NJJ->( NJJ_TIPO ) $ "1|3|5|7|9"
			//Se o tipo informado em tela for SAIDA - não valida
			If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|4|6|8" 
			 	Agrhelp(STR0021,STR0492,STR0493) //#AJUDA #Alteração não permitida. #Alteração permitida apenas para os tipos de SAIDA 2,4,6 ou 8
				lRetorno := .F.
			Else
				//*Se contrato nao for vazio faz a condicao abaixo
				If !Empty(oNJM:GetValue( "NJM_CODCTR" ))
					//*Zera os campos Cod. e Desc. de Contrato quando o TIPO/SAFRA for alterado.
					nLinha := oNJM:GetLine()
					For nX := 1 to oNJM:Length()
						oNJM:GoLine( nX )
						oNJM:LoadValue( "NJM_CODCTR", cCtrBnc )	//Codigo do Contrato
						If NJM->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg
							oNJM:LoadValue( "NJM_FILORG", FWxFilial("NJR"))  //Filial Origem do Contrato
						EndIf

						oNJM:LoadValue( "NJM_DESCTR", cDtrBnc )	//Descrição do Contrato
					Next nX
					oNJM:GoLine( nLinha )
					lRetorno		:= .T.					
					
				EndIf
			EndIf
					
		ElseIf NJJ->( NJJ_TIPO ) $ "2|4|6|8"  //Se o tipo que ja existe for SAIDA - entra
			//Se o tipo informado em tela for ENTRADA - não valida
			If oNJJ:GetValue( "NJJ_TIPO" ) $ "1|3|5|7|9"  
				Agrhelp(STR0021,STR0492 ,STR0494) //#AJUDA #Alteração não permitida. #Alteração permitida apenas para os tipos de ENTRADA 1,3,5,7 ou 9
				lRetorno := .F. 
			Else
				//*Se contrato nao for vazio faz a condicao abaixo
				If !Empty(oNJM:GetValue( "NJM_CODCTR" ))
					//*Zera os campos Cod. e Desc. de Contrato quando o TIPO/SAFRA for alterado.
					nLinha := oNJM:GetLine()
					For nX := 1 to oNJM:Length()
						oNJM:GoLine( nX )
						oNJM:LoadValue( "NJM_CODCTR", cCtrBnc )	//Codigo do Contrato
						If NJM->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg
							oNJM:LoadValue( "NJM_FILORG", FWxFilial("NJR"))  //Filial Origem do Contrato
						EndIf
						oNJM:LoadValue( "NJM_DESCTR", cDtrBnc )	//Descrição do Contrato
					Next nX
					oNJM:GoLine( nLinha )
					lRetorno		:= .T.									
				EndIf
			EndIf			
		EndIf
	EndIf
Return ( lRetorno )

/** {Protheus.doc} OGA250NNKF3
Consulta customizada para os itens de classificação

@param:	Nil
@author: 	Bruna Rocio
@since: 	25/06/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250NNKF3( cTabela, cCodDes)
	Local aAreaAtu	:= GetArea()
	Local nOpcX		:= 0
	Local nOpcao		:= 0
	Local aButtons	:= {}
	Local nTamH 		:= ( GetScreenRes()[1] - 400 )
	Local nTamV 		:= ( GetScreenRes()[2] - 400 )
	Local aItens	    := {}

	Private oDlg		:= Nil
	Private oBrowse	:= Nil
	Private aColunas	:= { STR0071, STR0072, STR0073, STR0074, STR0075, STR0076, STR0077, STR0078 } 


	Public __nResOGA250	:= &( ReadVar() )
	Public __nDesOGA250  := &( ReadVar() )
	Public __nReaOGA250  := &( ReadVar() )

	Default cTabela := ""
	Default cCodDes := ""

	BeginSql Alias "NNKPes"

		Select *
		From %Table:NNK% NNK 
		Where
		NNK.NNK_FILIAL  = %xFilial:NNK%  And
		NNK.NNK_CODTAB  = %Exp:cTabela%  And
		NNK.NNK_CODDES  = %Exp:cCodDes%  And
		NNK.%notDel%
	EndSql 

	While .Not. NNKPes->( Eof() )
		aAdd(aItens , { NNKPes->( NNK_SEQ ), NNKPes->( NNK_PERINI), NNKPes->( NNK_PERFIM ), NNKPes->( NNK_DESRES ), NNKPes->( NNK_PERDES ), NNKPes->( NNK_TABALT ), NNKPes->( NNK_PROALT )})
		NNKPes->( dbSkip() )
	EndDo 
	NNKPes->(dbCloseArea())

	If Len( aItens ) > 0
		oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0006, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Consulta Personalizada"
		oDlg:lEscClose := .f.

		oPnlT := TPanel():New( 1, 1, , oDlg, , , , , , 0, 0, .f., .t. )
		oPnlT:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlB := TPanel():New( 0, 0, , oPnlT, , , , , RGB(67,70,87), 15, 15, .f., .f. )
		oPnlB:Align := CONTROL_ALIGN_LEFT

		oBrowse := TCBrowse():New( 1, 1, 260, 156, , , , oPnlT, , , , {|| nOpcao := oBrowse:nAt }, {|| nOpcao := oBrowse:nAt, nOpcX := 1, oDlg:End() }, , , , , , , .f., ,.t., ,.f., , , )
		oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		oBrowse:AddColumn( TCColumn():New( aColunas[1], { || aItens[oBrowse:nAt,1] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[2], { || aItens[oBrowse:nAt,2] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[3], { || aItens[oBrowse:nAt,3] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[4], { || aItens[oBrowse:nAt,4] }, , , , "LEFT", , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[5], { || aItens[oBrowse:nAt,5] }, , , , "RIGHT" , , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[6], { || aItens[oBrowse:nAt,6] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )
		oBrowse:AddColumn( TCColumn():New( aColunas[7], { || aItens[oBrowse:nAt,7] }, , , , "LEFT" , , .f., .t., , , ,.f., ) )

		oBrowse:SetArray( aItens )

		oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

		If nOpcX > 0 .And. Len( aItens ) > 0
			__nResOGA250 := aItens[ nOpcao, 3 ]
			__nDesOGA250 := aItens[ nOpcao, 4 ]
			If FUNNAME() $ "OGA250|OGA251"			
				FwFldPut('NJK_DESRES', __nDesOGA250)
			Else
				FwFldPut('NJG_DESRES', __nDesOGA250)
			EndIf   				
		EndIf
	End

	RestArea( aAreaAtu )
Return( .t. )


/** {Protheus.doc} OGA250VKF10
Função auxililar para chamar a rotina de pesagem

@param: 	oModel - Modelo de Dados
@return:	Nil
@author: 	Bruna Rocio
@since: 	11/11/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250VKF10()


	IF LF10EXEC = .T.
		If NJJ->NJJ_STATUS $ '0|1'
			oModel := FwLoadModel( "OGA250" )

			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()

			OGA250PESA( oModel, "GRID" )
			oModel:DeActivate()	
		EndIf
	ELSE
		oModel := FwModelActive()
		OGA250PESA( oModel, "VIEW" )
	ENDIF

Return .t.

/*
+=================================================================================================+
| Função    : OGA250PER                                                                           |
| Descrição : Carrega a descrição do desconto                                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/11/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250PER()
	Local oModel		:= FwModelActive()
	Local oGrdNJJ		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oGrdNJK		:= oModel:GetModel( "NJKUNICO" )
	__nDesOGA250 := AGRDESCRINNK(oGrdNJJ:GetValue("NJJ_TABELA"),oGrdNJK:GetValue("NJK_CODDES"),oGrdNJK:GetValue("NJK_PERDES"))
	oGrdNJK:LoadValue( "NJK_DESRES",  __nDesOGA250) 
Return .T.


/** {Protheus.doc} OGA250ClFr
Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio

@param:	pcCodEnt	Codigo da enditidade
@param:	pcLojEnt	Loja da enditidade
@param:	pcTes		TES 
@param:	pcTipoNJJ	Tipo do romaneio (NJJ_TIPO)
@param:	pnQtdFis	Quantidade fiscal

@return:	aRet		{ cTipoNF, cCliFor, cLoja, cAliasRet }
@return:	cTipoNF	Tipo de nota fiscal a ser gerada
@return:	cCliFor	Código do cliente ou fornecedor
@return:	cLoja		Loja do cliente ou fornecedor
@return:	cAliasRet	Alias de retorno (SA1 ou SA2)

@author: 	Marlon Richard Trettin
@since: 	07/01/2015
@Uso: 		OG
*/
Function OGA250ClFr( pcCodEnt, pcLojEnt, pcTes, pcTipoNJJ, pnQtdFis, cFilRom )
	Local cTipoNF		:= ""
	Local cCliFor		:= ""
	Local cLoja			:= ""
	Local cAliasRet 	:= ""
	Local aRet			:= {}

	Default cFilRom := ''

	NJ0->( dbSetOrder( 1 ) )
	NJ0->( dbSeek( xFilial( "NJ0" ) + pcCodEnt + pcLojEnt ) )

	SF4->( dbSetOrder( 1 ) )
	SF4->( dbSeek( xFilial( "SF4" ) + pcTes ) )

	Do Case
		//// Tipos de entrada
		Case pcTipoNJJ = "3" //Deposito de 3
		If SF4->( F4_PODER3 ) $ "R"
			cTipoNF		:= "B"
			cCliFor		:= NJ0->( NJ0_CODCLI )
			cLoja 		:= NJ0->( NJ0_LOJCLI )
			cAliasRet 	:= "SA1"
		Else
			cTipoNF		:= "N"
			cCliFor		:= NJ0->( NJ0_CODFOR )
			cLoja 		:= NJ0->( NJ0_LOJFOR )
			cAliasRet 	:= "SA2"
		EndIf

		Case pcTipoNJJ = "5" //Compra
		If pnQtdFis = 0
			cTipoNF	:= "C"
		Else
			cTipoNF	:= "N"
		EndIf
		cCliFor		:= NJ0->( NJ0_CODFOR )
		cLoja 		:= NJ0->( NJ0_LOJFOR )
		cAliasRet 	:= "SA2"

		Case pcTipoNJJ = "7" //Devolução de Remessa de 3
		If SF4->( F4_PODER3 ) $ "D"
			cTipoNF		:= "N"
			cCliFor		:= NJ0->( NJ0_CODFOR )
			cLoja 		:= NJ0->( NJ0_LOJFOR )
			cAliasRet 	:= "SA2"
			If  __lnewNeg
				//Se for depósito alfandegado, nota deve ser gerada par
				cCGCDAC := ''
				If NJ0->NJ0_DEPALF = '1' .And. !Empty(cFilRom) 
					dbSelectArea("SM0")
					SM0->( dbSetOrder(1) )
					SM0->( dbGoTop() )
					While !SM0->( Eof() )
						If AllTrim(SM0->M0_CODFIL) == AllTrim(cFilRom)
							cCGCDAC   := SM0->M0_CGC
							Exit								
						EndIf
						SM0->( dbSkip() )
					EndDo
				EndIf
				If !Empty(cCGCDAC)
					dbSelectArea("SA2")
					SA2->(dbSetOrder(3))
					If SA2->(dbSeek(xFilial("SA2",SM0->M0_CODFIL)+cCGCDAC))
						cCliFor 	:= SA2->A2_COD
						cLoja 		:= SA2->A2_LOJA
					EndIf
				EndIf

			EndIf


		Else
			cTipoNF	:= "D"
			cCliFor	:= NJ0->( NJ0_CODCLI )
			cLoja 		:= NJ0->( NJ0_LOJCLI )
			cAliasRet 	:= "SA1"
		EndIf

		Case pcTipoNJJ = "9" //Devolução de Venda
		cTipoNF 	:= "D"
		cCliFor		:= NJ0->( NJ0_CODCLI )
		cLoja 		:= NJ0->( NJ0_LOJCLI )
		cAliasRet 	:= "SA1"

		//// Tipos de Saída
		Case pcTipoNJJ = "2" //Remessa
		If SF4->( F4_PODER3 ) $ "R"
			cTipoNF		:= "B"
			cCliFor 	:= NJ0->( NJ0_CODFOR )
			cLoja 		:= NJ0->( NJ0_LOJFOR )
			cAliasRet 	:= "SA2"
			If  __lnewNeg	
				//Se for depósito alfandegado, nota deve ser gerada par
				cCGCDAC := ''
				If NJ0->NJ0_DEPALF = '1' .And. !Empty(cFilRom) 
					dbSelectArea("SM0")
					SM0->( dbSetOrder(1) )
					SM0->( dbGoTop() )
					While !SM0->( Eof() )
						If AllTrim(SM0->M0_CODFIL) == AllTrim(cFilRom)
							cCGCDAC   := SM0->M0_CGC
							Exit								
						EndIf
						SM0->( dbSkip() )
					EndDo
				EndIf
				If !Empty(cCGCDAC)
					dbSelectArea("SA2")
					SA2->(dbSetOrder(3))
					If SA2->(dbSeek(xFilial("SA2",SM0->M0_CODFIL)+cCGCDAC))
						cCliFor 	:= SA2->A2_COD
						cLoja 		:= SA2->A2_LOJA
					EndIf
				EndIf
			EndIf	
		Else
			cTipoNF		:= "N"
			cCliFor 	:= NJ0->( NJ0_CODCLI )
			cLoja 		:= NJ0->( NJ0_LOJCLI )
			cAliasRet 	:= "SA1"
		EndIf

		Case pcTipoNJJ = "4" //Venda
		If pnQtdFis = 0
			cTipoNF 	:= "C"
		Else
			cTipoNF	:= "N"
		EndIf
		cCliFor 	:= NJ0->( NJ0_CODCLI )
		cLoja 		:= NJ0->( NJ0_LOJCLI )
		cAliasRet 	:= "SA1"

		Case pcTipoNJJ = "6" //Devolução de Deposito
		If SF4->( F4_PODER3 ) $ "D"
			cTipoNF		:= "N"
			cCliFor 	:= NJ0->( NJ0_CODCLI )
			cLoja 		:= NJ0->( NJ0_LOJCLI )	
			cAliasRet 	:= "SA1"
		Else
			cTipoNF		:= "D"
			cCliFor 	:= NJ0->( NJ0_CODFOR )
			cLoja 		:= NJ0->( NJ0_LOJFOR )				
			cAliasRet 	:= "SA2"
		EndIf

		Case pcTipoNJJ = "8" //Devolução de Compra
		cTipoNF		:= "D"
		cCliFor 	:= NJ0->( NJ0_CODFOR )
		cLoja 		:= NJ0->( NJ0_LOJFOR )
		cAliasRet 	:= "SA2"
		//		If  __lnewNeg	
		Case pcTipoNJJ = "B" //Saida por transferência entre filiais.
		cTipoNF		:= "D"
		cCliFor 	:= NJ0->( NJ0_CODCLI )
		cLoja 		:= NJ0->( NJ0_LOJCLI )
		cAliasRet 	:= "SA1"

		Case pcTipoNJJ = "A" //Entrada por transferência entre filiais.
		cTipoNF		:= "D"
		cCliFor 	:= NJ0->( NJ0_CODFOR )
		cLoja 		:= NJ0->( NJ0_LOJFOR )
		cAliasRet 	:= "SA1"	
		//		EndIf		
	EndCase

	aRet := { cTipoNF, cCliFor, cLoja, cAliasRet }

Return( aRet )

/** {Protheus.doc} fVldFrete
Função de validação do tipo de frete

@param: 	Nil
@author: 	Ana Laura Olegini
@since: 	12/08/2014
@Uso: 		SIGAAGR
*/
Static Function fVldFrete ( oField )

	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "NJMUNICO" )
	Local nLinha 		:= oNJM:GetLine()
	Local nVrFrete	:= FWFLDGET("NJM_FRETE", nLinha )
	Local cTpFrete	:= FWFLDGET("NJJ_TPFRET" )
	Local lRet			:= .t. 

	If ( nVrFrete > 0 ) .and. !(cTpFrete  $ "C|F|T" )
		Agrhelp(STR0021,STR0495,STR0496)
		//reverMSG //#AJUDA #Não é permitido informar o Valor do frete, quando o Tipo de Frete for S=Sem Frete #Favor informar Tipo de Frete válido.
		lRet := .f.
	EndIF	

Return( lRet )

/** {Protheus.doc} OGA250HIS
Descrição: Mostra em tela de Historico do contrato

@param: 	Nil
@author: 	Vinícius Becher Pagung
@since: 	12/05/2015
@Uso: 		OGA250 
*/
Function OGA250HIS()
	Local cChaveI := "NJJ->("+Alltrim(AGRSEEKDIC("SIX","NJJ1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NJJ",cChaveA)
Return

/** {Protheus.doc} fTrgIncCtr
Função para atualizar de forma automática alguns campos do romaneio com dados do contrato.

@param: 	Nil
@author: 	Gilson Venturi
@since: 	15/05/2015
@Uso: 		OGA250
*/
Static Function fTrgIncCtr ( oParModel )
	Local aAreaNJR  := NJR->( GetArea() )
	Local oModel    := oParModel:GetModel()
	Local oNJJ      := oModel:GetModel( "NJJUNICO" )
	Local oNJM      := oModel:GetModel( "NJMUNICO" )
	Local nLinha    := oNJM:GetLine()
	Local cCodEnt   := space( TAMSX3("NJR_CODENT")[1] )
	Local nOperation:= oModel:GetOperation() 

	If .Not. Empty( oNJJ:GetValue( "NJJ_CODCTR" ) )
		dbSelectArea( "NJR" )
		NJR->(dbSetOrder( 1 ))
		If NJR->(dbSeek( xFilial( "NJR" ) + oNJJ:GetValue( "NJJ_CODCTR" ) ))							
			If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato
			  _lFretOrig := (NJR->NJR_CLASSF == "2") //2 = Controle de frete Fob com Qtd e Qld Origem
			ENDIF			

			cCodEnt     := NJR->NJR_CODENT			
			oNJJ:SetValue( "NJJ_CODENT", NJR->NJR_CODENT )
			oNJJ:SetValue( "NJJ_LOJENT", NJR->NJR_LOJENT )
			oNJJ:SetValue( "NJJ_CODSAF", NJR->NJR_CODSAF )          
			oNJJ:SetValue( "NJJ_CODPRO", NJR->NJR_CODPRO )
			oNJJ:SetValue( "NJJ_TPFRET", NJR->NJR_TPFRET )

			// Se Tipo não for, saida venda ou saida devolucao 3, atualiza com entidade
			if  !(oNJJ:GetValue( "NJJ_TIPO" ) $ "4|6") 
				 oNJJ:SetValue( "NJJ_ENTENT", NJR->NJR_CODENT )
				 oNJJ:SetValue( "NJJ_ENTLOJ", NJR->NJR_LOJENT )					    
			//caso tenha apenas uma linha na comerc. ou ja tinha valor na entid entrega, alterar = entidade (DAGROOGD-12103) 				
			ELSEIF (nOperation == MODEL_OPERATION_INSERT .and. oNJM:Length() = 1 ) .OR. ;
					(oNJM:Length() = 1 .and. !Empty( oNJJ:GetValue( "NJJ_ENTENT" ) ))
					oNJJ:SetValue( "NJJ_ENTENT", NJR->NJR_CODENT )
				    oNJJ:SetValue( "NJJ_ENTLOJ", NJR->NJR_LOJENT )						
			ENDIF// caso tenha apenas uma linha na comerc. e ja tinha valor 
			
			//Se for romaneio de devolucao, pegar a TES de devolução associada a tes do contrato.
			if oNJJ:GetValue( "NJJ_TIPO" ) $ "6|7|8|9"
				SF4->( dbSetOrder( 1 ) )
				SF4->( dbSeek( xFilial( "SF4" ) + NJR->NJR_TESEST ) )
				oNJJ:SetValue( "NJJ_TES", SF4->F4_TESDV )
			ElseIf !__lnewNeg .AND. NJR->NJR_OPETRI == "1" .AND. NJR->NJR_TIPO == "2" //OP. TRIANGILAR VENDA MODELO CLASSICO
				oNJJ:SetValue( "NJJ_TES", NJR->NJR_TESFIN )
			Else
				oNJJ:SetValue( "NJJ_TES", NJR->NJR_TESEST )
			endIf

			If NJR->(FieldPos("NJR_INDPRE")) > 0 .AND. !Empty(NJR->NJR_INDPRE)
				oNJJ:SetValue( "NJJ_INDPRE", NJR->NJR_INDPRE ) //Presença Comprador (NT 2020.006)
				oNJJ:SetValue( "NJJ_CODA1U", NJR->NJR_CODA1U ) //Codigo Intermediador (NT 2020.006)	
			EndIf

			oNJM:GoLine(1)
			oNJM:SetValue( "NJM_CODCTR", oNJJ:GetValue( "NJJ_CODCTR" ) )
			oNJM:SetValue( "NJM_TES", oNJJ:GetValue( "NJJ_TES" ) ) //para NJM refletir a ultima alteração da TES
									
			If NJM->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg
				oNJM:SetValue( "NJM_FILORG", FWxFilial("NJR")) 
				oNJM:SetValue( "NJM_CLVL"  , NJR->NJR_CLVL)
				If (!IsInCallStack("OGA710") .and. !IsInCallStack("OGA290") .and. !IsInCallStack("OGX290NFUT"))				
					oNJJ:SetValue( "NJJ_TABELA", NJR->NJR_TABELA )
				EndIf
			Else				
				oNJJ:SetValue( "NJJ_TABELA", NJR->NJR_TABELA )			 
			EndIf			

			oNJM:GoLine(nLinha)
		Endif
	else
		oNJJ:SetValue( "NJJ_TES", "" )
	Endif

	RestArea( aAreaNJR )
Return( cCodEnt )

/** {Protheus.doc} fInicTra
Função para atualizar transportadora de acordo com autorizacao informada.

@param: 	Nil
@author: 	Gilson Venturi
@since: 	15/05/2015
@Uso: 		OGA250
*/
Static Function fInicTra ( oField )
	Local aAreaNJP	:= NJP->( GetArea() )
	Local oModel	:= FwModelActive()
	Local oNJJ 		:= oModel:GetModel( "NJJUNICO" )
	Local cCodCtr 	:= oNJJ:GetValue( "NJJ_CODCTR" )
	Local cCodAUT 	:= oNJJ:GetValue( "NJJ_CODAUT" )

	If .Not. Empty( cCodCtr ) .And. .Not. Empty( cCodAut ) 

		dbSelectArea( "NJP" )
		NJP->(dbSetOrder( 1 ))
		If NJP->(dbSeek( xFilial( "NJP" ) + cCodCtr + cCodAut ))
			oNJJ:SetValue( "NJJ_CODTRA", NJP->( NJP_CODTRA ) )
		Endif
	Endif

	RestArea( aAreaNJP )
Return( .T. )

/**{Protheus.doc}
Rotina que Mostra o Saldo do Produto, pode ser utilizada tanto
no cabeçalho do romaneio qto nos itens do romaneio;

@param oVIEW
@return Consulta de Saldos
@author Emerson Coelho
@since 09/092015
@version 1.0
/*/

Static Function fShowSaldo( )

	Local oView			:= FwViewActive()
	Local oModel        := FWModelActive()
	Local oModeLNJJ		:= oModel:GetModel("NJJUNICO")
	Local oModeLNJM		:= oModel:GetModel("NJMUNICO")
	Local cProduto		:= Criavar('B1_COD', .F. )
	Local nHdlCodPro	:= oView:GetViewObj("V250_NJJ")[3]:GetFWEditCTRL("NJJ_CODPRO"):OCtrl:OGet:HWND 	//Get o Handle do NJJ_CODPRO
	//Local nHdlGrdNJM    := oView:GetViewObj("V250_NJM")[3]:Obrowse:Obrowse:HWND							//Get o Handle do Grid do NJM

	Local lConsultar	:=.t.
	Local nObjHasFoc	:= Getfocus()
	//Local nPJMCodPro 	:= gdFieldPos('NJM_CODPRO', oView:GetViewObj("V250_NJM")[3]:obrowse:Aheader ) 	//Encontra a coluna onde esta o NJM_CODPRO. no Grid
	Local aViewNJMCp    := aclone(oview:GetViewStruct('V250_NJM'):Getfields())
	Local nPJMCodPro 	:= aScan( aViewNJMCp, { |x| AllTrim( x[ MVC_VIEW_IDFIELD ] ) ==  AllTrim( 'NJM_CODPRO' ) } )
	Local nLinNJM 		:= oModeLNJM:GetLine()															//Linha no Momento do click   do F4 Qdo no Grid
	Local nColNJM		:= oView:GetViewObj("V250_NJM")[3]:obrowse:obrowse:ColPos()						//Coluna no Momento do click  do F4, Qdo no Grid

	IF nObjHasFoc == nHdlCodPro
		cProduto	:= oModelNJJ:GetValue("NJJ_CODPRO")
	ElseIF ( Type("lFcoGrdNjm") <> "U"  .and. lFcoGrdNjm )		//Indica que o Grid esta Com o Foco.
		IF nColNJM == nPJMCodPro		// Se a Coluna em q o Foco se encontra for igual a Coluna do NJM_CODPRO no Grid
			cProduto	:= cProduto	:= oModelNJM:GetValue("NJM_CODPRO",nLinNJM)
		Else
			lConsultar := .f.
		EndIF
	Else
		lConsultar := .f.
	EndIF

	IF lConsultar
		DbSelectArea('SB1')
		SB1->( DbSetOrder(1) )
		IF SB1->(DbSeek(Fwxfilial('SB1') + cProduto ))
			MaViewSB2( cProduto )
		Else
			Agrhelp(STR0021,STR0497+ cProduto +STR0498,STR0499) //#AJUDA #Produto # informado não foi encontrado #Favor informar um produto válido
		EndIF
	Else
		Agrhelp(STR0021,STR0500,STR0501) //#AJUDA #Não foi possivel abrir a consulta de Produto #Favor clique no campo Produto antes de abrir a consulta.
	EndIF

Return ( nil )


/** {Protheus.doc} 
Função que Inicializa / Activate o modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	10/09/2015
@Uso: 		AgroIndustria
*/
Static Function fIniModelo( oModel , nOperation )
	Local oView			:= FwViewActive()
	Local oNJJ 			:= oModel:GetModel( "NJJUNICO" )
	Local nOpc 			:= oModel:GetOperation()	
	Local aAreaNJR      := NJR->(GetArea())

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

	SetKey( VK_F4, { || fShowSaldo() } ) 		// Setanto F4 para Mosrar,Consulta de Saldos

	If nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_VIEW 
		// Se o parâmetro de que a empresa usa NF de Transito estiver habilitado, inicializa os campos com os valores da tabela
		If lMVOGUSANT .And. oNJJ:HasField("TMP_SERNFT") .and. oNJJ:HasField("TMP_NUMNFT")
			oNJJ:LoadValue( "TMP_SERNFT" , oNJJ:GetValue( "NJJ_NFPSER" ) )
			oNJJ:LoadValue( "TMP_NUMNFT" , oNJJ:GetValue( "NJJ_NFPNUM" ) )
		EndIf
	ElseIf nOpc == MODEL_OPERATION_INSERT

		Pergunte("OGA2500001",.F.)
		If !Empty(MV_PAR01)
			FwFldPut( "NJJ_CODSAF" , MV_PAR01 ) //Safra
		Endif
		If !Empty(MV_PAR02)
			FwFldPut( "NJJ_CODPRO" , MV_PAR02 ) //Produto
		Endif
		If !Empty(MV_PAR03)
			FwFldPut( "NJJ_TABELA" , MV_PAR03 ) //Tabela
		Endif
		If !Empty(MV_PAR04)
			FwFldPut( "NJJ_LOCAL"  , AllTrim(MV_PAR04) ) //Local
		Endif

	EndIf

	If NJJ->(ColumnPos('NJJ_DTULAL')) > 0 .and. __lnewNeg
		If oModel:Activate() .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
			oNJJ:SetValue("NJJ_DTULAL", DDATABASE)
			oNJJ:SetValue("NJJ_HRULAL", TIME())
		EndIf

	Else
		If nOpc == MODEL_OPERATION_UPDATE
			oNJJ:SetValue("NJJ_CODCTR", NJJ->NJJ_CODCTR)
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_UPDATE
		dbSelectArea( "NJR" )
		If .Not. Empty(oNJJ:GetValue("NJJ_CODCTR"))
			NJR->(dbSetOrder( 1 ))
		    If NJR->(dbSeek( xFilial("NJR") + allTrim(oNJJ:GetValue("NJJ_CODCTR")) ))
			   IF NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
			   		_lFretOrig := (NJR->NJR_CLASSF == "2") //2 = Controle de frete Fob com Qtd e Qld Origem
				EndIf
			EndIf
		EndIf
		If lExecAgoClas
			fCarNJKClas(oModel,.F.)			
		EndIf
	EndIf

	/*Fução para validar parecer da qualidade*/
	OGA250GotF(oModel,oView)

	RestArea(aAreaNJR)

Return( .t. )

/** {Protheus.doc} 7 ffimModelo
Função executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	10/09/2015
@Uso: 		AgroIndustria
*/
Static Function fFimModelo( oModel )

	SetKey (VK_F4, nil)
	lFcoGrdNjm := Nil

Return( .t. )

/** {Protheus.doc} OGA250CT1
Validação aplicada no Campo NJJ_CODCTR
chamada no valid do NJJ_CODCTR;

@param:  Nil
@return: Nil
@author:  Emerson Coelho
@since:  01/01/2015
@Uso:   OGA250 - Romaneio
*/
Function OGA250CT1()
	Local aAreaAtu   := GetArea()
	Local aAreaNJR   := NJR->( GetArea() )
	Local aAreaNNY   := NNY->( GetArea() ) 
	Local oModel  := FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local cCodCtr  := oNJJ:GetValue( "NJJ_CODCTR" )
	Local cTipo   := oNJJ:GetValue( "NJJ_TIPO" )
	Local lContinua  := .t.
	Local lCadenFis     := .t.


	IF Empty( cTipo )
		// -- É preciso ter o tipo do romaneio para validar se o Ctrato,
		// -- pode ser usado neste tipo de romaneio
		Agrhelp(STR0021,STR0502,STR0503) //#AJUDA ##O Tipo do romaneio não foi informado. #Favor informar o Tipo do Romaneio, antes de preencher o contrato.
		lContinua := .f.
	ElseIf .Not. Empty( cCodCtr )
		dbSelectArea( "NJR" )
		NJR->(dbSetOrder( 1 ))
		If .Not. NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ))
			Agrhelp(STR0021,STR0456+cCodCtr+STR0504,STR0505)
			//#AJUDA #O contrato # informado não foi encontrado.#Favor informar um Contrato válido.
			lContinua := .f.
		Else
			// Se tipo do contrato for incompatível com tipo do romaneio
			If NJR->( NJR_TIPO ) <> OGX010TC( cTipo )  	
			    Agrhelp(STR0021,STR0123 + "[ " + X3CboxDesc( "NJR_TIPO", NJR->( NJR_TIPO ) ) + " ]",STR0506)		
				//#AJUDA #O Contrato informado não pode ser utilizado neste romaneio, pois é um contrato do tipo #Informe um contrato compativel com o tipo do romaneio.
				lContinua := .f.
			ElseIF NJR->NJR_STATUS $ "P=Previsto;E=Cancelado;F=Finalizado"
				Agrhelp(STR0021,STR0463,STR0464)  
				//#AJUDA ##Contrato não pode ser utilizado. O contrato informado deve estar Previsto,Cancelado ou Finalizado.#Somente contratos com status de Aberto e Iniciado podem ser utilizados.
				lContinua := .f.
			EndIf
		EndIF

		IF lContinua
			// Verifica se o contrato possui cadência Física
			dbSelectArea( "NNY" )
			NNY->(dbSetOrder( 1 ) )
			NNY->(dbSeek( xFilial( "NNY" ) + cCodCtr))
			While .Not. NNY->( Eof() ) .And. NNY->( NNY_FILIAL ) + NNY->( NNY_CODCTR ) == xFilial( "NNY" ) + cCodCtr
				If NNY->( NNY_TIPENT ) == '1' //Gerencial
					lCadenFis := .f.
				Endif
				NNY->( dbSkip() )
			EndDo
			If .Not. lCadenFis
				Agrhelp(STR0021,STR0507,STR0181)
				lContinua := .f.
			Endif
		EndIF  
	EndIF
	RestArea( aAreaNNY ) 	
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( lContinua )

/** {Protheus.doc} OGA250Leg
Legenda para status do campo NJJ_LIBQLD

@param.:  Nil
@return:  Nil
@author:  Ana Laura Olegini
@since.:  16/12/2015
@Uso...:  OGA250 - Romaneio
*/
Function OGA250Leg()
	Local oLegenda  :=  FWLegend():New()     // Objeto FwLegend.

	oLegenda:Add("","BR_CINZA" 		, X3CboxDesc("NJJ_LIBQLD",'0')) // "Não se aplica"
	oLegenda:Add("","BR_VERDE" 		, X3CboxDesc("NJJ_LIBQLD",'1')) // "Aprovado"
	oLegenda:Add("","BR_VERMELHO" 	, X3CboxDesc("NJJ_LIBQLD",'2')) // "Reprovado"
	oLegenda:Add("","BR_AMARELO" 	, X3CboxDesc("NJJ_LIBQLD",'3')) // "Requer Parecer"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return(.T.)

/** {Protheus.doc} OGA250PQL
Validação do Parecer da Qualidade

@param.:  Nil
@return:  Nil
@author:  Ana Laura Olegini
@since.:  16/12/2015
@Uso...:  OGA250 - Romaneio
*/
Function OGA250PQL()
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.
	Local cTipRom	:= ''	
	Local cTipQld	:= ''

	If IsInCallStack("OGA455")
		Return .T.
	EndIf
	
	cTipRom := IIF(NJJ->NJJ_TIPO $ "1|3|5|7|9","2"/*entrada*/,"3"/*saida*/)


	If !Empty(M->NJJ_TABELA)  		
		DbSelectArea("NNI")
		NNI->(DbSetOrder(1))
		If NNI->(Dbseek(xFilial("NNI")+M->NJJ_TABELA))
			cTipQld := NNI->NNI_QLDANA
			If cTipQld == "2" .AND. cTipQld == cTipRom	//Entrada
				If Empty(NJJ->NJJ_QPAREC)
					Help(, , STR0021, , STR0184, 1, 0 ) //"Ajuda""Romaneio requer parecer de inspenção de entrada."
					lRetorno := .F.
				ElseIf !Empty(NJJ->NJJ_QPAREC)
					DbSelectArea("NKJ")
					NKJ->(DbSetOrder(1))
					If NKJ->(Dbseek(xFilial("NKJ")+NJJ->NJJ_QPAREC))
						If NKJ->NKJ_LIBQLD = '2'	//Não
							Help(, , STR0021, , STR0185, 1, 0 ) //"Ajuda""Entrada reprovada pela inspenção de entrada."
							lRetorno := .F.
						EndIf
					EndIf
				EndIf			
			ElseIf cTipQld == "3" .AND. cTipQld == cTipRom	//Saída
				If Empty(NJJ->NJJ_QPAREC)
					Help(, , STR0021, , STR0186, 1, 0 ) //"Ajuda""Romaneio requer parecer de inspenção de saída."
					lRetorno := .F.
				ElseIf !Empty(NJJ->NJJ_QPAREC)
					DbSelectArea("NKJ")
					NKJ->(DbSetOrder(1))
					If NKJ->(Dbseek(xFilial("NKJ")+NJJ->NJJ_QPAREC))
						If NKJ->NKJ_LIBQLD = '2'	//Não
							Help(, , STR0021, , STR0187, 1, 0 ) //"Ajuda""Saída reprovada pela inspenção de saída."
							lRetorno := .F.
						EndIf
					EndIf					
				EndIf	
			ElseIf cTipQld == "4"	//Entrada/Saída
				If Empty(NJJ->NJJ_QPAREC)
					Help(, , STR0021, , STR0188, 1, 0 ) //"Ajuda""Romaneio requer parecer de inspenção de entrada ou saída."
					lRetorno := .F.
				ElseIf !Empty(NJJ->NJJ_QPAREC)
					DbSelectArea("NKJ")
					NKJ->(DbSetOrder(1))
					If NKJ->(Dbseek(xFilial("NKJ")+NJJ->NJJ_QPAREC))
						If NKJ->NKJ_LIBQLD = '2'	//Não
							Help(, , STR0021, , STR0189, 1, 0 ) //"Ajuda""Entrada/Saída reprovada pela inspenção de entrada/saída."
							lRetorno := .F.
						EndIf
					EndIf					
				EndIf	
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return lRetorno

/** {Protheus.doc} OGA250ANA
Inlusão do parecer da qualidade

@param.:  Nil
@return:  Nil
@author:  Ana Laura Olegini
@since.:  16/12/2015
@Uso...:  OGA250 - Romaneio
*/
Function OGA250ANA()
	Local lRetorno	 := .F.
	Local lContinua  := .F.
	Local lInclui 	 := .F.
	Local oDlg		 := Nil
	Local cUsrRetNam := (RetCodUsr())

	Private cParQld	:= Space( TamSX3( "NKJ_PAREC" )[1] )

	If !NJJ->NJJ_STATUS $ '0|1'
		Help(, , STR0021, , STR0198, 1, 0 ) //"AJUDA""Não é Possível Alterar o Parecer de Qualdiade, Romaneio Fechado!!!"
		lRetorno := .F.
	ElseIf NJJ->NJJ_LIBQLD == '0' .OR. Empty(NJJ->NJJ_LIBQLD)
		Help(, , STR0021, , STR0199, 1, 0 )	//"AJUDA""A tabela de classifcação do romaneio não requer parecer da qualidade!"
		lRetorno := .F.
	Else 
		If Empty(NJJ->NJJ_QPAREC)
			lInclui := .T.
			cParQld := NJJ->NJJ_QPAREC
			cDesc	:= Posicione( "NKJ", 1, xFilial("NKJ")+cParQld, "NKJ_DESCRI" )
		Else 
			cParQld := NJJ->NJJ_QPAREC
			cDesc	:= Posicione( "NKJ", 1, xFilial("NKJ")+cParQld, "NKJ_DESCRI" )
		EndIf 

		While .t.
			oDlg := MSDialog():New(100,100,210, 540,STR0190,,,,/*nOr(WS_VISIBLE,WS_POPUP)*/,,,,,.T.) //"Parecer da Qualidade"

			oDlg:lEscClose := .F.
			//--<< Cria Layer >>--
			oFwLayer := FwLayer():New()
			oFwLayer:Init( oDlg, .f., .t. )
			//--<<Cria  1  colunas no Layer>>--
			oFwLayer:addCollumn('Col01',100,.F.)
			//--<< Cria 1 Janela na Coluna do Layerr >>--
			oFwLayer:addWindow('Col01','C1_Win01',STR0191,100,.f.,.F.,,,)	//'Informe o Parecer da Qualidade'
			//--<< pega o Painel da Janela do Layer >>>--	
			oPanelJan := oFwLayer:getWinPanel('Col01','C1_Win01')  // Get panel da Janela esquerda de cima

			@ 005, 002 SAY oSay1 PROMPT STR0192 SIZE 30, 10 OF oPanelJan COLORS 0, 16777215 PIXEL	//"Parecer:"
			@ 005, 030 MSGET cParQld Picture PesqPict('NKJ',"NKJ_PAREC") SIZE 30,8 FONT oDlg:OFont PIXEL F3 "NKJ" Of oPanelJan
			//cDesc:= Posicione( "NKJ", 1, xFilial("NKJ")+cParQld, "NKJ_DESCRI" ) 
			@ 005, 065 MSGET Posicione("NKJ",1,xFilial("NKJ")+cParQld,"NKJ_DESCRI") Picture PesqPict('NKJ',"NKJ_DESCRI") SIZE 143,8 FONT oDlg:OFont PIXEL WHEN .F. Of oPanelJan
			oBtn1 := TButton():New( 018,170,"OK",oPanelJan,{|| lContinua := .T., oDlg:End()},037,010,,,,.T.,,"",,,,.F. )

			ACTIVATE MSDIALOG oDlg CENTERED 

			If lContinua 
				DbSelectArea("NKJ")
				NKJ->(DbSetOrder(1))
				If NKJ->(Dbseek(xFilial("NKJ")+cParQld))
					BEGIN TRANSACTION
						If RecLock( "NJJ", .F. )
							NJJ->NJJ_QPAREC := cParQld
							NJJ->NJJ_QUSUAR	:= cUsrRetNam											//NJJ = 0=Nao se aplica;1=Aprovado;2=Reprovado;3=Requer Parecer
							NJJ->NJJ_LIBQLD	:= IIF(NKJ->NKJ_LIBQLD=='1','1',IIF(NKJ->NKJ_LIBQLD=='2','2','0'))  //NKJ = 1=Sim;2=Não
							NJJ->(MsUnLock()) 
							lRetorno := .T.
						EndIf
						If lInclui
							AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+NJJ->NJJ_CODROM,"3",STR0192+Alltrim(NJJ->NJJ_QPAREC)+" - "+Alltrim(NKJ->NKJ_DESCRI)})
						Else
							AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+NJJ->NJJ_CODROM,"4",STR0192+Alltrim(NJJ->NJJ_QPAREC)+" - "+Alltrim(NKJ->NKJ_DESCRI)})
						EndIf 
					END TRANSACTION
					If lRetorno  
						Exit
					EndIf
				Else
					lRetorno := .F.
					Exit
				EndIf
			Else
				lRetorno := .F.
				Exit
			EndIf 
		Enddo
	EndIf 

	If (ExistBlock("OG250ANA"))
		ExecBlock("OG250ANA",.F.,.F.) 
	EndIf

Return lRetorno

/*{Protheus.doc} OGA250GotF
Validação Para o Grid Ganhar o Focus a GridNJK só deverá Ganhar 
o Foco se estiver pelo menso uma linha no Grid NJK

@author  Emerson coelho
@version P11 
@Since   26/06/15
*/
Function OGA250GotF(oModel,oView)
	Local aAreaAtu		:= GetArea()
	Local oNJJ			:= IIF(IsInCallStack("AGRA500") , oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local nOperation	:= oModel:GetOperation()
	Local lOKFoco		:= .T.

	//Validação para alteração [Parecer Qualidade]
	If nOperation == MODEL_OPERATION_UPDATE 
		IF (!Empty(FwFldGet("NJK_PERDES") ) )
			If !Empty(oNJJ:Getvalue('NJJ_QPAREC'))
				DbSelectArea("NKJ")
				NKJ->(DbSetOrder(1))
				If NKJ->(Dbseek(xFilial("NKJ")+oNJJ:Getvalue('NJJ_QPAREC')))
					If NKJ->NKJ_LIBQLD == '1'	//1=SIM 
						lOkFoco := .F.
					EndIf 
				EndIf
			EndIf			
		EndIF
	EndIf

	oModel:GetModel("NJKUNICO"):GetStruct():SetProperty( '*' , MODEL_FIELD_WHEN, {||lOkFoco} )
	If lOkFoco
		oModel:GetModel("NJKUNICO"):GetStruct():SetProperty( 'NJK_PERDES' , MODEL_FIELD_WHEN, {|| OG250TWhen(oModel, "NJK_PERDES")} )	
	EndIf

	RestArea( aAreaAtu )
Return ( lOKFoco )

/** {Protheus.doc} OGA250Gri
Validação para mensagem da grid
@param.:  oModel, oView
@return:  lOKFoco
@author:  Ana Laura Olegini
@since.:  17/12/2015
@Uso...:  OGA250 - Romaneio
*/
Function OGA250Gri(oModel,oView)
	Local aAreaAtu		:= GetArea()
	Local oNJJ			:= IIF(IsInCallStack("AGRA500") , oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local nOperation	:= oModel:GetOperation()
	Local lOKFoco		:= .T.

	//Validação para alteração [Parecer Qualidade]
	If nOperation == MODEL_OPERATION_UPDATE 
		//IF (!Empty(FwFldGet("NJK_PERDES") ) )
		If !Empty(oNJJ:Getvalue('NJJ_QPAREC'))
			DbSelectArea("NKJ")
			NKJ->(DbSetOrder(1))
			If NKJ->(Dbseek(xFilial("NKJ")+oNJJ:Getvalue('NJJ_QPAREC')))
				If NKJ->NKJ_LIBQLD == '1'	//1=SIM 
					Help(, , STR0021, , STR0193, 1, 0 )	//"AJUDA""Esse romaneio esta aprovado pelo parecer da qualidade. Não pode ser alterado tabela e/ou classificação."	
					lOkFoco := .F.
				EndIf 
			EndIf
		EndIf			
		//EndIF
	EndIf			
	RestArea( aAreaAtu )			
Return ( lOKFoco )

/** {Protheus.doc} OG250Lot
Verifica se produto possui rastro por lote e campo NJM_LOTCTL esta vazio

Retorno:    .t. ou .f. 
@author: 	Ana Laura Olegini
@since: 	15/02/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG250Lot()
	Local aAreaAtu	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oNJM		:= oModel:GetModel( "NJMUNICO" )
	Local cProduto	:= oNJM:Getvalue('NJM_CODPRO')
	Local cLote		:= oNJM:GetValue( "NJM_LOTCTL" )
	Local lRetorno	:= .T.

	If Rastro(cProduto) .And. Empty(cLote) 
		Agrhelp(STR0021,STR0402, STR0403 + cProduto + " - " + POSICIONE("SB1",1,xFilial("NJJ")+cProduto,"B1_DESC") )
		//#AJUDA #Produto possui rastro por lote. #Favor informar lote para o produto 
		lRetorno := .F.
	EndIf 

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} sfPreValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)			   
Rotina de Pre validação do modelo NJK(Classificação)

@Param..:	oModelGrid Modelo
@Param..:	nLinha Linha corrente
@Param..:	cAcao  Ação ("DELETE", "SETVALUE", e etc)
@Param..:	cCampo Campo atualizado
@Param..:	Vr. inserido no Campo
@Param..:	Vr. que do Cpos antes da Inserção do novo vr.
@Retorno:   lRet 
@Author.: 	Ana Laura Olegini
@Since..: 	23/03/2016
@Uso....: 	SIGAAGR - Originação de Grãos
*/
Function sfPreValLin(oNJK, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local oModel    	:= FWModelActive()
	Local oNJJ			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500

	Local aSaveLines  	:= FWSaveRows()
	Local lContinua		:= .T.
	Local cClasRom 		:= cDefClasDesc(oNJJ:GetValue("NJJ_TIPO"), oModel,,(oNJJ:GetValue("NJJ_TPFRET")  = 'F'.And. oNJJ:GetValue("NJJ_TPFORM")  == "1")) //busca qual classificação rege os descontos 1=destino; 2=origem (oNJJ:GetValue("NJJ_TPFRET") = 'F'.And. oNJJ:GetValue("NJJ_TPFORM") == "1")

	//se lContinua = .T. e ação for modificação e campo for de resultado
	IF lContinua .AND. cAcao == 'SETVALUE' .AND. cCampo == "NJK_PERDES"	
		If xVrNovo == 0 .AND.  oNJK:GetValue( "NJK_OBRGT ") == '1' 
			Agrhelp(STR0021,STR0531, STR0532)
			lContinua := .F.
		else
			oNJK:SetValue( "NJK_RESINF" , '1' ) //1='INFORMADO'		
		EndIf	

	EndIF

	If lExecAgoClas //se a função AGOCLASS esta em execução
		If cCampo == "NJK_PERDES" .and. (oNJK:GetValue( "NJK_TPCLAS") == cClasRom .or. empty(oNJK:GetValue( "NJK_TPCLAS")))
			lContinua := .f.  
		ElseIf cCampo == "NJK_BASDES" .and. (oNJK:GetValue( "NJK_TPCLAS") == cClasRom .or. empty(oNJK:GetValue( "NJK_TPCLAS")))
			lContinua := .f.
		ElseIf cCampo == "NJK_CODDES" 
			lContinua := .f.
		ElseIf cCampo == "NJK_QTDDES" .and. (oNJK:GetValue( "NJK_TPCLAS") == cClasRom )
			lContinua := .F.  
		ElseIf cCampo == "NJK_READES" .and. (oNJK:GetValue( "NJK_TPCLAS") == cClasRom )
			lContinua := .F.  
		endIf
	ElseIf cCampo == "NJK_PERDES" .AND. !lExecAgoClas .and. lChkAgoClas .and. oNJK:GetValue( "NJK_TPCLAS") != cClasRom .and. cClasRom = '2' //cClasRom = '2' = SAIDA
		//qdo romaneio SAIDA(FISCAL/ORIGEM), não habilita informar classificação destino, será informado qdo lExecAgoClas
		lContinua := .f. 
	EndIf

	FWRestRows(aSaveLines)

Return(lContinua)

//-------------------------------------------------------------------
/*{Protheus.doc}OG250ROLL()
Evento Cancela no Processo de Ajuste a Valor Positivo / Negativo Societario
@author Vinicius Beche Pagung
@since  29/04/2016
*/
//-------------------------------------------------------------------

Static Function OG250ROLL()

	If __lSX8 
		RollBackSX8()
	EndIf

	If Type("_aItsEsq") != "U" .AND. !(EMPTY(_aItsEsq))
		_aItsEsq := {}
	EndIf
Return
/*
+=================================================================================================+
| Função    : OGA250CP                                                                            |
| Descrição : Confirma carta de porte                                                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250CP()
	Local nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTG,nPesoB,nOpc,cCodtr := Space(6)
	Private cNomtr := Space(40)
	Store 0 To nPesoB,nOpc

	DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0211) Of oMainWnd PIXEL
	@5,4  Say OemToAnsi(STR0219)	 SIZE 45 ,9 Of oDlg PIXEL  							  										 	
	@5,50 MSGET nCarta 				 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta) Picture "@!" When .f.	 

	@5,120 Say OemToAnsi("CTG") 	 SIZE 10 ,9 Of oDlg PIXEL  
	@5,135 MSGET nCTG 					 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG) 		 Picture "@!"	When .f.

	@20,4  Say OemToAnsi(STR0220) SIZE 40 ,9 Of oDlg PIXEL 
	@20,50 MSGET cCodtr  			 SIZE 12 ,9 Of oDlg PIXEL Valid OGA250VTR(cCodtr) F3 "SA4"					 Picture "@!"							 	
	@20,90 MSGET cNomtr  			 SIZE 120,9 Of oDlg PIXEL	      															 Picture "@!" When .f.

	@35,4 Say OemToAnsi(STR0221)	 SIZE 30 ,9 Of oDlg PIXEL 
	@35,50 MSGET nPesoB  			 SIZE 50 ,9 Of oDlg PIXEL Valid Naovazio(nPesoB) .and. Positivo(nPesoB) Picture "@E 99,999,999.99"

	DEFINE SBUTTON FROM 90,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1, If(!AGROBRICAMP({nCarta,nCTG,nPesoB,cCodtr}),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 90,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc = 1

		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := "2"
		MsUnlock()

		Alert(STR0508)//"CONFIMAÇÃO SOLICITADA" colocar uma STR
		// Chamar a função para buscar os dados da carta e testar de houve erro
		// deve retornar : data,hora e código da operação
	Endif	
Return

/*
+=================================================================================================+
| Função    : OGA250VTR                                                                           |
| Descrição : Validação da transportadora                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/02/2016                                                                          |
+=================================================================================================+   
*/
Static Function OGA250VTR(cCod)
	cNomtr := Space(40)
	If !ExistCpo("SA4",cCod)
		Return .f.
	EndIf
	cNomtr := Posicione("SA4",1,xFilial("SA4")+cCod,"A4_NOME")
Return .T.

/*
+=================================================================================================+
| Função    : OGA250DD                                                                            |
| Descrição : Desvido da Destino                                                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250DD()
	Local nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTG,nPesoB,nOpc,cCodtr := Space(6),cCodDes := Space(6)
	Private cNomtr := Space(40),cNomDeN := Space(40)
	Store 0 To nPesoB,nOpc

	DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0213) Of oMainWnd PIXEL
	@5,4  Say OemToAnsi(STR0219)	 SIZE 45 ,9 Of oDlg PIXEL  							  										 	
	@5,50 MSGET nCarta 				 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta) Picture "@!"	When .f. 

	@5,120 Say OemToAnsi("CTG") 	 SIZE 10 ,9 Of oDlg PIXEL  
	@5,135 MSGET nCTG 					 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG)		 Picture "@!" When .f.	

	@20,4  Say OemToAnsi(STR0220) SIZE 40 ,9 Of oDlg PIXEL 
	@20,50 MSGET cCodtr  			 SIZE 12 ,9 Of oDlg PIXEL Valid OGA250VTR(cCodtr) F3 "SA4"					 Picture "@!"							 	
	@20,90 MSGET cNomtr  			 SIZE 120,9 Of oDlg PIXEL																	  	 Picture "@!" When .f.

	@35,4  Say OemToAnsi(STR0221) SIZE 30 ,9 Of oDlg PIXEL 
	@35,50 MSGET nPesoB  			 SIZE 50 ,9 Of oDlg PIXEL Valid Naovazio(nPesoB) .and. Positivo(nPesoB) Picture "@E 99,999,999.99"

	@50,4  Say OemToAnsi(STR0222) SIZE 40 ,9 Of oDlg PIXEL 
	@50,50 MSGET cCodDes  			 SIZE 12 ,9 Of oDlg PIXEL Valid Naovazio(cCodDes)									 Picture "@!"
	@50,90 MSGET cNomDeN  			 SIZE 120,9 Of oDlg PIXEL																	  	 Picture "@!" When .f.

	DEFINE SBUTTON FROM 90,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1, If(!AGROBRICAMP({nCarta,nCTG,nPesoB,cCodtr,cCodDes}),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 90,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc = 1
		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := "4"
		MsUnlock()

		Alert(STR0509)//colocar uma STR
		// Chamar a função para buscar os dados do novo destino e testar de houve erro
		// deve retornar : data,hora e código da operação 
	EndIf	
Return

/*
+=================================================================================================+
| Função    : OGA250CD                                                                            |
| Descrição : Validação e envio de informações para buscar os dados confirmação definitivaHTML...)|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250CD()
	Local nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTGnPesoB,nOpc,cCodes := Space(6),cEstabe := Space(6),cCodSa := Space(15)
	Private cNomEst := Space(40),cNomEsp := cNomEst
	Store 0 To nPesoB,nOpc

	DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0212) Of oMainWnd PIXEL
	@5,4  Say OemToAnsi(STR0219)	  SIZE 45 ,9 Of oDlg PIXEL  							  										 	
	@5,50 MSGET nCarta 				  SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta) Picture "@!" When .f.

	@5,120 Say OemToAnsi("CTG") 	  SIZE 10 ,9 Of oDlg PIXEL  
	@5,135 MSGET nCTG 					  SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG) 			Picture "@!" When .f.

	@20,4  Say OemToAnsi(STR0223)  SIZE 40 ,9 Of oDlg PIXEL 
	@20,50 MSGET cEstabe  			  SIZE 12 ,9 Of oDlg PIXEL Valid Naovazio(cEstabe)									Picture "@!"		
	@20,90 MSGET cNomEst  			  SIZE 120,9 Of oDlg PIXEL																	   	Picture "@!" When .f.	

	@35,4  Say OemToAnsi(STR0224)  SIZE 40 ,9 Of oDlg PIXEL 
	@35,50 MSGET cCodes  			  SIZE 12 ,9 Of oDlg PIXEL Valid Naovazio(cCodes)										Picture "@!"	
	@35,90 MSGET cNomEsp  			  SIZE 120,9 Of oDlg PIXEL																	   	Picture "@!" When .f.	

	@50,4  Say OemToAnsi(STR0225)  SIZE 40 ,9 Of oDlg PIXEL 
	@50,50 MSGET cCodSa  			  SIZE 60 ,9 Of oDlg PIXEL Valid ExistCpo("NJU",cCodSa) F3 "NJU"			   Picture "@!"

	@50,115 Say OemToAnsi(STR0221) SIZE 30 ,9 Of oDlg PIXEL 
	@50,145 MSGET nPesoB  			  SIZE 50 ,9 Of oDlg PIXEL Valid Naovazio(nPesoB) .and. Positivo(nPesoB)	 Picture "@E 99,999,999.99"

	DEFINE SBUTTON FROM 90,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1, If(!AGROBRICAMP({nCarta,nCTG,nPesoB,cCodes,cEstabe,cCodSa}),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 90,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc = 1

		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := "3"
		MsUnlock()

		Alert(STR0510)	//colocar uma STR
		// Chamar a função para buscar os dados do novo destino e testar de houve erro
		// deve retornar : data,hora,carta e CTG 
	EndIf	
Return

/*
+=================================================================================================+
| Função    : OGA250DE                                                                            |
| Descrição : Validação e envio de informações para buscar os dados confirmação definitivaHTML...)|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250DE()
	Local nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTGnPesoB,nOpc,cCodes := Space(6),cLocal := Space(12),cCodesN := Space(6),cEstabe := Space(6)
	Private cNomDes,cNomLoc,cNomeEst,cNomDeN
	Store Space(40) To cNomDes,cNomLoc,cNomEst,cNomDeN 
	Store 0 To nPesoB,nOpc

	DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0214) Of oMainWnd PIXEL
	@5,4  Say OemToAnsi(STR0219)	 SIZE 45 ,9 Of oDlg PIXEL  							  										 	
	@5,50 MSGET nCarta 				 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta) Picture "@!" When .f.	 

	@5,120 Say OemToAnsi("CTG")	 SIZE 10 ,9 Of oDlg PIXEL  
	@5,135 MSGET nCTG  				 SIZE 55 ,9 Of oDlg PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG)      Picture "@!" When .f.

	@20,4  Say OemToAnsi(STR0222) SIZE 40 ,9 Of oDlg PIXEL 
	@20,50 MSGET cCodes  			 SIZE 12 ,9 Of oDlg PIXEL Valid Naovazio(cCodes)									   Picture "@!"		
	@20,90 MSGET cNomDes  			 SIZE 120,9 Of oDlg PIXEL 		                									   Picture "@!" When .f.				

	@35,4  Say OemToAnsi(STR0226) SIZE 40 ,9 Of oDlg PIXEL 
	@35,50 MSGET cLocal  			 SIZE 20 ,9 Of oDlg PIXEL Valid Naovazio(cLocal)									 	Picture "@!"
	@35,90 MSGET cNomLoc  			 SIZE 120,9 Of oDlg PIXEL 																		Picture "@!" When .f.

	@50,4 Say OemToAnsi(STR0221)	 SIZE 30 ,9 Of oDlg PIXEL 
	@50,50 MSGET nPesoB  			 SIZE 50 ,9 Of oDlg PIXEL Valid Naovazio(nPesoB) .and. Positivo(nPesoB) Picture "@E 99,999,999.99"

	@65,4  Say OemToAnsi(STR0223) SIZE 40 ,9 Of oDlg PIXEL 
	@65,50 MSGET cEstabe  			 SIZE 20 ,9 Of oDlg PIXEL Valid Naovazio(cEstabe)									Picture "@!"
	@65,90 MSGET cNomEst  			 SIZE 120,9 Of oDlg PIXEL																		Picture "@!" When .f.	

	@80,4  Say OemToAnsi(STR0227) SIZE 40 ,9 Of oDlg PIXEL 
	@80,50 MSGET cCodesN  			 SIZE 20 ,9 Of oDlg PIXEL Valid Naovazio(cCodesN)									Picture "@!"
	@80,90 MSGET cNomDeN  			 SIZE 120,9 Of oDlg PIXEL																		Picture "@!" When .f.	

	DEFINE SBUTTON FROM 100,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1, If(!AGROBRICAMP({nCarta,nCTG,nPesoB,cCodes,cLocal,cCodesN,cEstabe}),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 100,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc = 1

		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := "5"
		MsUnlock()

		Alert(STR0511) //colocar uma STR
		// Chamar a função para buscar os dados do novo destino e testar de houve erro
		// deve retornar : data,hora,carta,CTG e número da solicitação 
	EndIf
Return

/*
+=================================================================================================+
| Função    : OGA250EC                                                                            |
| Descrição : Validação e rechazar CTG                                                   (HTML...)|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250EC()
	Local oMsg,nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTG,nOpc := 0,cMotivo := CriaVar("NK9_MSGMEM")

	DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0215) Of oMainWnd PIXEL
	@5,4  Say OemToAnsi(STR0219)	 SIZE 45 ,9  Of oDlg           PIXEL  							  										 	
	@5,50 MSGET nCarta					 SIZE 55 ,9  Of oDlg           PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta) Picture "@!" When .f.	 

	@5,120 Say OemToAnsi("CTG")	 SIZE 10 ,9  Of oDlg           PIXEL  
	@5,135 MSGET nCTG					 SIZE 55 ,9  Of oDlg           PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG)      Picture "@!" When .f.	

	@20,4  Say OemToAnsi(STR0228) SIZE 40 ,9  Of oDlg           PIXEL
	@20,50 GET oMsg Var cMotivo	 SIZE 180,80 Of oDlg Multiline PIXEL Valid Naovazio(cMotivo)

	DEFINE SBUTTON FROM 105,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1, If(!AGROBRICAMP({nCarta,nCTG,cMotivo}),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 105,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED				

	If nOpc = 1

		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := "8"
		MsUnlock()

		Alert(STR0512) //colocar uma STR
		// Chamar a função para buscar os dados do novo destino e testar de houve erro
		// deve retornar : data,hora,carta,Código transação e número da solicitação 
	Endif	
Return

/*
+=================================================================================================+
| Função    : OGA250RECH                                                                          |
| Descrição : Validação e rechazar CTG (Origem ou Destino)                               (HTML...)|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/02/2016                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGA250RECH(lOrigem)
	Local nCarta := NJJ->NJJ_CARTA,nCTG := NJJ->NJJ_CODCTG,nOpc := 0,nKMSR := 0
	Local cTitulo := If(lOrigem,STR0217,STR0216)	
	Local cLocal  := Space(6),cOrigem := Space(6),cLocalD := Space(6),cDestino := Space(6),cDesnata := Space(6),cDestinoN := Space(6)
	Local nTipoD  := If(lOrigem,1,2)

	DEFINE MSDIALOG oDlg FROM 50,40  TO 405,541 TITLE OemToAnsi(cTitulo) Of oMainWnd  PIXEL
	@2,5 TO 33,250 LABEL STR0229							Of oDlg PIXEL
	@15,10  Say OemToAnsi(STR0219)	SIZE 45,9		Of oDlg PIXEL  							  										 	
	@15,60 MSGET nCarta 					SIZE 55,9		Of oDlg PIXEL Valid Naovazio(nCarta) .and. Positivo(nCarta)	Picture "@!" When .f.	 

	@15,140 Say OemToAnsi("CTG")		SIZE 10,9		Of oDlg PIXEL  
	@15,155 MSGET nCTG  					SIZE 55,9		Of oDlg PIXEL Valid Naovazio(nCTG).and. Positivo(nCTG)			Picture "@!" When .f.	

	@40,5 TO 180,250 LABEL STR0230 Of oDlg PIXEL
	@50,009 RADIO oRad VAR nTipoD ITEMS STR0231,STR0232 3D SIZE 120,10 of oDlg Pixel	when .f.
	@75,7 TO 100,245 LABEL " "+STR0231+" "			Of oDlg PIXEL
	@85,15 Say OemToAnsi(STR0233)	SIZE 65,9		Of oDlg PIXEL  							  										 	
	@85,70 MSGET cOrigem 				SIZE 55,9		Of oDlg PIXEL 																		Picture "@!" When lOrigem	 

	@85,130 Say OemToAnsi(STR0234)	SIZE 65,9		Of oDlg PIXEL  							  										 	
	@85,185 MSGET cLocal 				SIZE 55,9		Of oDlg PIXEL	          															Picture "@!" When lOrigem	 

	@105,7 TO 145,245 LABEL " "+STR0232+" "   	Of oDlg Pixel
	@115,15 Say OemToAnsi(STR0235)	SIZE 65,9		Of oDlg PIXEL  							  										 	
	@115,70 MSGET cDestino 				SIZE 55,9 		Of oDlg PIXEL																			Picture "@!" When !lOrigem	 

	@115,130 Say OemToAnsi(STR0236)	SIZE 65,9 		Of oDlg PIXEL  							  										 	
	@115,185 MSGET cLocalD 				SIZE 55,9 		Of oDlg PIXEL																			Picture "@!" When !lOrigem	 

	@130,15 Say OemToAnsi(STR0237)	SIZE 65,9 		Of oDlg PIXEL  							  										 	
	@130,70 MSGET cDestinoN				SIZE 55,9		Of oDlg PIXEL																			Picture "@!" When !lOrigem	 

	@130,130 Say OemToAnsi(STR0238)	SIZE 65,9		Of oDlg PIXEL  							  										 	
	@130,185 MSGET cDesnata				SIZE 55,9		Of oDlg PIXEL																			Picture "@!" When !lOrigem

	@150,10 Say OemToAnsi(STR0239)	SIZE 65,9		Of oDlg PIXEL  							  										 	
	@150,70 MSGET nKMSR     			SIZE 55,9		Of oDlg PIXEL Valid Naovazio(nKMSR) .and. Positivo(nKMSR)		Picture "@E 99,999,999.99"

	DEFINE SBUTTON FROM 160,155 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1,;
	If(!AGROBRICAMP(If(lOrigem,{nCarta,nCTG,cOrigem,cLocal,nKMSR},{nCarta,nCTG,cDestino,cLocalD,cDestinoN,cDesnata,nKMSR})),nOpc := 0,oDlg:End()))
	DEFINE SBUTTON FROM 160,190 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED		 

	If nOpc = 1

		DbSelectArea("NJJ")
		RecLock("NJJ",.f.)
		NJJ->NJJ_STACTP := If(lOrigem,"7","6")
		MsUnlock()

		Alert(cTitulo)
		// Chamar a função para buscar os dados do novo destino e testar de houve erro
		// deve retornar : data,hora,carta,Código transação e número da solicitação

	Endif
Return .t. 

/** {Protheus.doc} OGA250ENT
Descrição:  Validação para verificar se entidade está valida
@param:     Nil
@author:    Ana Laura Olegini
@since:     03/05/2016
@Uso:       OGA260 
*/
Function OGA250ENT()
	Local aAreaAtu  := GetArea()
	Local oModel    := FwModelActive()
	Local oNJJ 		:= oModel:GetModel("NJJUNICO")
	Local oNJM 		:= oModel:GetModel("NJMUNICO")
	Local cCodEnt   := oNJJ:GetValue("NJJ_CODENT")
	Local cLojEnt   := oNJJ:GetValue("NJJ_LOJENT")   

	If !Empty(cCodEnt)
		//Acessa a tabela de entidades para a verificação
		DbSelectArea("NJ0") // Entidades
		NJ0->(dbSetOrder(1))
		If NJ0->(dbSeek(xFilial("NJ0")+cCodEnt+cLojEnt))
			//Verifica se esta ativo
			If NJ0->(NJ0_ATIVO) == '2' // 1=Ativo; 2=Inativo			
				Agrhelp(STR0021,STR0513,STR0514+NJ0->(NJ0_CODENT)+" "+NJ0->(NJ0_LOJENT))
				//#AJUDA #Cadastro de Entidade está INATIVO e não pode ser usado para esta função.#Verifique o cadastro da entidade:
				Return( .F. )
			EndIf	

			If !lExecAgoClas
				oNJM:GoLine( 1 ) //posiciona na primeira linha da NJM
				oNJM:SetValue( "NJM_CODENT", oNJJ:GetValue( "NJJ_CODENT" ) )
				oNJM:SetValue( "NJM_LOJENT", oNJJ:GetValue( "NJJ_LOJENT" ) )
				If !(oNJJ:GetValue( "NJJ_TIPO" ) $ "4|6")
					oNJJ:SetValue( "NJJ_ENTENT", oNJJ:GetValue( "NJJ_CODENT" ) )
					oNJJ:SetValue( "NJJ_ENTLOJ", oNJJ:GetValue( "NJJ_LOJENT" ) )
				EndIf
			EndIf	

		EndIf
	EndIf
	RestArea(aAreaAtu)
Return(.T.)

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     12/05/2016
@Uso:       OGA250
*/
Static Function PosModelo( oModel )
	Local lContinua     := .T.
	Local nOperation    := oModel:GetOperation()
	Local oNJJ 			:= oModel:GetModel("NJJUNICO")
	Local oNJM          := oModel:GetModel("NJMUNICO")
	Local oN9E          := nil
	Local lTemIE        := .F.
	Local nY            := 0

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

	Iif(lExecAgoClas,;
	oNJM:SetNoUpdateLine(.F.),)	

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		//Função para validar entidade 
		lContinua := OGA250ENT() 

		If __lnewNeg .and. lExecAgoClas .and. oNJJ:GetValue('NJJ_TIPO') $ "2|4" .and. (Empty(oNJJ:GetValue('NJJ_DATCHE')) .OR. Empty(StrTran(oNJJ:GetValue('NJJ_HORCHE' ),":")) )
			Help(" ", 1, "OGA250DTHRCHEG") //##Problema: O campo Data Chegada ou o campo Hora Chegada não foi informado. ##Solução: Informe o campo Data Chegada e o campo Hora Chegada. 
			lContinua := .F.
		EndIf	
		If __lnewNeg

			oN9E := oModel:GetModel("N9EUNICO")
			//Tem contrato e IE informada
			If lContinua .And. __lnewNeg .And. !Empty(oNJJ:GetValue('NJJ_CODCTR')) .And. oN9E:Length( .T. ) //Tem linha ativa na grid 

				For nY := 1 To oN9E:Length() //percorre toda a grid pois pode haver registros deletados
					oN9E:GoLine(nY) //posiciona na linha
					If !oN9E:IsDeleted() .AND. !Empty(oN9E:GetValue("N9E_CODINE"))   //se linha não estiver deletada
						lTemIE := .T.												
					EndIf
				Next nY
				oN9E:GoLine(1) //posiciona na linha

				If lTemIE .AND. !lExecAgoClas				
					agrhelp(STR0021,STR0515,STR0516)
					//#AJUDA ## Contrato não deve ser informado quando houver IE relacionada ao Romaneio. #Não informe o contrato no romaneio.
					lContinua := .F.
				EndIf				
			EndIf


			If M->NJJ_TIPO $ '2|4|6|8' .AND. _lAltIE //se for saída e houve alteração na IE faz análise crédito
				lContinua := AGRX500VlC(oModel, M->NJJ_CODROM)

				if lContinua
					_lAltIE := .F.
				Else
					//Tratamento para mostrar mensagem corretamente para NF Venda Futura
					If FwIsInCallStack("OGX290NFUT") //Global Venda Futura
						aErro := oModel:GetErrorMessage()
						If Len(aErro) > 0
							Help(, , AllToChar( aErro[6] ), , AllToChar( aErro[7] ), 1, 0 )
						EndIF
					EndIF
				EndIf
			EndIF
            
		EndIf	

        If M->NJJ_TIPO == "1" .And. Empty(M->NJJ_ORDCLT) .AND. FWHasEAI( "AGRA530", .T., .F., .T. )
            AgrHelp(STR0021,STR0541,STR0542) //A ordem de colheita não foi informada. Quando está configurado a integração via EAI a ordem de colheita é obrigatória. //"Por favor, informe a ordem de colheita."
            lContinua := .F.
        EndIf
		If NJJ->(ColumnPos('NJJ_MOEGA')) > 0
			lContinua:= vldMoega(oNJJ,'TUDOK')
		endif
	EndIf
Return(lContinua)

/*{Protheus.doc} OGA250DES
Função para tratar quando o tipo for Faixa ou Percentual 
da tabela de classificação/descontos
Função validação do campo NJK_PERDES

@author 	ana.olegini
@since 		23/06/2016
@version 	1.0
@return 	lContinua, Lógico [.T. = True - .F. = Falso]
*/
Function OGA250DES()
	Local lContinua := .T.
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJK		:= oModel:GetModel( "NJKUNICO" )

	Local cTabela	:= oNJJ:GetValue("NJJ_TABELA")
	Local cDescon	:= oNJK:GetValue("NJK_CODDES")
	Local nPerDes	:= oNJK:GetValue("NJK_PERDES")

	Local cTipoRes	:= Posicione( "NNJ", 1, xFilial("NNJ") + cTabela + cDescon, "NNJ_TIPRES" )

	//-- Se o Tipo do Resultado for Percentual [P]
	If cTipoRes == "P"
		//-- Se o Percentual Inicial OU Final for maior que 99.99 - retorna Falso
		If nPerDes > 99.99 
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNJJ:GetId(), , oNJJ:GetId(), "", "", STR0287, STR0288, "", "")	//"O tipo de resultado é percentual."#"Por Favor, informe um valor até 99,99"	
		EndIf 		
	ElseIf cTipoRes == "F" 
		//-- Se a Faixa Inicial OU Final for maior que 99999.99 - retorna Falso
		If nPerDes > 99999.99 
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNJJ:GetId(), , oNJJ:GetId(), "", "", STR0289, STR0290, "", "")	//"O tipo de resultado é faixa."#"Por Favor, informe um valor até 99999,99"
		EndIf 		
	EndIf
	__lDescOk := lContinua

Return(lContinua)

/*{Protheus.doc} fQtfixCtr
Função que Retorna a Qtidade Fixada Total do Contrato 
@author 	Emerson Coelho
@since 		04/08/2016
@return 	nQtFix -> Qtidadade Fixada
*/
Static Function fQtFixCtr( cCodctr )
	Local  cQryNN8 	:= GetNextAlias()
	Local  nQtFixada	:= 0

	BeginSql Alias cQryNN8
		SELECT 
		SUM(NN8_QTDFIX) as NN8_QTDFIX
		FROM 	%Table:NN8% NN8
		WHERE 	NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = %exp:cCodctr%
		AND NN8_TIPOFX = '1'
	EndSQL

	nQtFixada := (cQryNN8)->NN8_QTDFIX

Return( nQtFixada )

/*/{Protheus.doc} ItensClass
//TODO Descrição auto-gerada.
@author rafael.kleestadt
@since 05/04/2017
@version undefined
@param aDescont, array, descricao
@type function
/*/
Static Function ItensClass(aDescont)
	Local oModel    := FwModelActive()
	Local oFldNJJ   := IIF(IsInCallStack("AGRA500") , oModel:GetModel("AGRA500_NJJ" ), IIF(IsInCallStack("AGRA550") .OR. IsInCallStack("AGRA550_01") .OR. FwIsInCallStack("AGRA550_02") .OR. IsInCallStack("OGWSPUTATU"),oModel:GetModel('AGRA550_NJJ'), oModel:GetModel( "NJJUNICO" ))) //Protecao para usar funcao via AGRA500
	Local oGrdNJK   := IIF(IsInCallStack("AGRA550") .OR. IsInCallStack("AGRA550_01") .OR. FwIsInCallStack("AGRA550_02") .OR. IsInCallStack("OGWSPUTATU"),oModel:GetModel('AGRA550_NJK'),oModel:GetModel("NJKUNICO"))
	Local nCount    := 0
	Local nCount2   := 1
	Local nX		:= 0
	Local cClassRom := cDefClasDesc(oFldNJJ:GetValue("NJJ_TIPO"), oModel,,(oFldNJJ:GetValue("NJJ_TPFRET") = 'F'.and. oFldNJJ:GetValue("NJJ_TPFORM" ) == "1")) //Obtem o mandante da classificação para calculo dos descontos

	If SuperGetMV( "MV_AGOCLAS",, .F. )
		nCount2 := 2
	EndIf		
	
	If fHasGrupo(NNI->( NNI_CODIGO ))
		NNJ->(dbSetOrder( 5 )) //ordena pelo nível	
	Else
		NNJ->(dbSetOrder( 2 )) //ordena pela sequencia
	EndIf 

	For nX := 1 To nCount2  

		NNJ->(dbGoTop())
		If NNJ->(dbSeek( xFilial( 'NNJ' ) + NNI->( NNI_CODIGO ) ))

			While .Not. NNJ->(Eof()) .And. NNJ->( NNJ_FILIAL ) = xFilial('NNJ') .And. NNJ->( NNJ_CODTAB ) = NNI->( NNI_CODIGO ) 

				nCount++
				cItem := StrZero( nCount, TamSX3( "NJK_ITEM" )[1] )
				if nCount <= oGrdNJK:Length() 
					oGrdNJK:GoLine( nCount )
					oGrdNJK:UnDeleteLine()
				Else
					oGrdNJK:AddLine()
				EndIf

				oGrdNJK:SetValue( "NJK_ITEM" 	, cItem 	)
				oGrdNJK:SetValue( "NJK_CODDES"	, NNJ->NNJ_CODDES)
				oGrdNJK:SetValue( "NJK_OBRGT"	, NNJ->NNJ_OBRGT )
				oGrdNJK:SetValue( "NJK_RESINF"	, '2' )	//gravar como "2=Não Informado" - campo é tratado na função sfPreValLin

				If nX != 1
					oGrdNJK:LoadValue( "NJK_TPCLAS", "2" )
				Else
					oGrdNJK:LoadValue( "NJK_TPCLAS", "1" )	
				EndIf	

				If !__lnewNeg .and. lChkAgoClas .and. cClassRom != oGrdNJK:GetValue( "NJK_TPCLAS")	
					oGrdNJK:SetValue( "NJK_OBRGT"	, "2" ) //para os itens que não são do mandante não será obrigatório informar item classificação
				EndIf

				If NJK->(ColumnPos('NJK_TIPREG')) > 0
					oGrdNJK:LoadValue( "NJK_TIPREG", NNJ->( NNJ_NIVEL ))
				EndIf

				NNJ->(dbSkip())
			EndDo
			//Seta o status da classificacao como não classificado
			oFldNJJ:SetValue( "NJJ_STSCLA", "0" )

		EndIf
	Next nX 

Return()

/*/{Protheus.doc} OGA250PNJK
//TODO Descrição auto-gerada.
@author rafael.kleestadt - DAGROGAP-446
@since 05/04/2017
@version undefined
@param cCodCtr, characters, descricao
@type function
/*/
Function OGA250PNJK(cCodCtr, lSimbolico)	
	Local lRetorno  := .t.
	Local nX        := 0
	Local aAreaNJJ 	:= NJJ->( GetArea() )
	Local aAreaNJK 	:= NJK->( GetArea() )
	Local aAreaNJM 	:= NJM->( GetArea() )
	
	Local cClassRom := cDefClasDesc(NJJ->(NJJ_TIPO),,.T.,(NJJ->(NJJ_TPFRET) = 'F'.and. NJJ->( NJJ_TPFORM ) == "1")) //Obtem o mandante da classificação para calculo dos descontos - DAGROGAP-514
	Local cCtrlQuald := ""
	Local cDsClass := ""

	DbSelectArea( "NJK" ) // Classificaçõe do romaneio
	NJK->(DbSetOrder( 1 )) //NJK_FILIAL+NJK_CODROM+NJK_ITEM
	NJK->(dbGoTop())
	If NJK->(dbSeek( xFilial( "NJK" ) + NJJ->( NJJ_CODROM ) ))	
		While .Not. Eof() .And. xFilial( "NJK" ) + NJJ->(NJJ_CODROM) == NJK->(NJK_FILIAL) + NJK->(NJK_CODROM) 
			nX++
			If cClassRom = NJK->(NJK_TPCLAS)
				If Empty(NJK->(NJK_PERDES)) .And. NJK->(NJK_OBRGT) = "1" .And. !lSimbolico
					If __lnewNeg
						If lChkAgoClas .And. lExecAgoClas //Se eh destino. Valida preenchimento
							DbSelectArea('NJR')
							NJR->( DbSetOrder(1) )
							If NJR->( dbSeek( FwxFilial( "NJR" ) + NJM->NJM_CODCTR ))
								cCtrlQuald := NJR->NJR_CLASSQ
								If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato				
									//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM
									IF NJR->NJR_CLASSF == "2" .AND. NJJ->(NJJ_TIPO) == '5' .and.  NJJ->(NJJ_TPFRET)  = 'F' .and. NJM->( NJM_TPFORM ) = "1"  
										cCtrlQuald := "2"
									EndIf	
								ENDIF
							EndIf
							If cCtrlQuald = "2" //Origem
								lRetorno := .F.
								If !Empty(cDsClass)
									cDsClass += " / "
								endIF
								cDsClass += AllTrim(POSICIONE('NNH',1,XFILIAL('NNH')+NJK->NJK_CODDES,'NNH_DESCRI'))
							EndIf
							NJR->(dbCloseArea())
						Else
							lRetorno := .f.
							If !Empty(cDsClass)
								cDsClass += " / "
							endIF 
							cDsClass += AllTrim(POSICIONE('NNH',1,XFILIAL('NNH')+NJK->NJK_CODDES,'NNH_DESCRI'))
						EndIf
					EndIf
				EndIf
			EndIf
			dbSkip()
		EndDo
	EndIf

	If !lRetorno
	    Agrhelp(STR0021,STR0517+cDsClass,STR0518) //#AJUDA ##O resultado da classificação não foi informado : #Informe todos os resultados da classificação.
	EndIf

	RestArea( aAreaNJJ )
	RestArea( aAreaNJK )
	RestArea( aAreaNJM )

Return(lRetorno)


/*/{Protheus.doc} AGOCLAS
Função que permite após romaneio confirmado a atualização
do peso fisico e a classificação fisica ou fiscal

@author claudineia.reinert	
@since 17/05/2017
@version 1.0
@type function
/*/
Function AGOCLAS()
	Local aCoors    := FWGetDialogSize(oMainWnd) //array com tamanho da window
	Local oView		:= NIL
	Local lAuto 	:= IiF(IsBlind(),.T.,.F.) //automação
	Private nPeso3Ant := NJJ->NJJ_PESO3	

	If !lChkAgoClas //se parametro não estiver ativo
		Agrhelp(STR0021,STR0519,STR0520)
		//#AJUDA #Funcionalidade não habilitada. # Para utilizar é necessario ativar a funcionalidade de controle Fisica/Fiscal pelo parametro MV_AGOCLAS.
		Return .f.	 
	ElseIf !(NJJ->( NJJ_TIPO ) $ "2|4|5") //se romaneio não for 2-remessa para deposito, 4-venda e 5-compra
	    Agrhelp(STR0021,STR0521,STR0522)//2-remessa para deposito, 4-venda e 5-compra
		//#AJUDA #Operação não permitida para este tipo de romaneio. #Operação disponivel apenas para romaneios dos tipos 2-remessa para deposito, 4-venda e 5-compra. 
		Return .f.	
	ElseIf  NJJ->( NJJ_STATUS ) != "3" //se romaenio não for 3-confirmado
	    Agrhelp(STR0021,STR0108+NJJ->( NJJ_STATUS ) + " - " + X3CboxDesc( "NJJ_STATUS", NJJ->( NJJ_STATUS )),STR0523)
		//#AJUDA #Operação não permitida para Romaneios com status Ação permitida somente para romaneios com status Confirmado
		Return .f.	
	Else 
		lF10Exec := .f.
		lExecAgoClas := .T. //seta variavel para informar que a função AgoClas esta em execução

		If lAuto
			return .T. //necessario para execução da automação ter a variavel lExecAgoClas := .T.
		EndIf

		If FwIsInCallStack("OGA250") .Or. FwIsInCallStack("GFEA523")
			oView :=  FWLoadView( "OGA250" ) //carrega a view do OGA250
			oView:SetOperation(MODEL_OPERATION_UPDATE) //se que é alteração para a view
			oStrucNJK := oView:GetViewStruct("NJKUNICO") //carrega a estrutura da NJK da view
			oStrucNJK:SetProperty( "NJK_BASDES" , MVC_VIEW_CANCHANGE, .T. )
			oStrucNJK:SetProperty( "NJK_READES" , MVC_VIEW_CANCHANGE, .T. )
			oStrucNJK:SetProperty( "NJK_QTDDES" , MVC_VIEW_CANCHANGE, .T. )
			If __lnewNeg 
				oStrucNJJ := oView:GetViewStruct("NJJUNICO") //carrega a estrutura da NJJ da view
				oStrucNJJ:SetProperty( "NJJ_DATCHE" , MVC_VIEW_CANCHANGE, .T. )
				oStrucNJJ:SetProperty( "NJJ_HORCHE" , MVC_VIEW_CANCHANGE, .T. )	
			EndIf
			oView:GetModel():GetModel("NJMUNICO"):SetNoInsertLine(.T.)
			oView:GetModel():GetModel("NJMUNICO"):SetNoUpdateLine(.T.)
			oView:GetModel():GetModel("NJMUNICO"):SetNoDeleteLine(.T.)
			//DESABILITA FOLDERS QUE NÃO DEVEM APARECER, DEVE APARECER APENAS PESAGEM E CLASSIFICAÇÃO
			oView:SetAfterViewActivate({|oModel|oView:HideFolder("V250_NJJ",1,1),oView:HideFolder("V250_NJJ",2,1),oView:HideFolder("V250_NJJ",4,1),oView:HideFolder("V250_NJJ",5,1),oView:HideFolder("GRADES",2,2),oView:HideFolder("GRADES",4,2)})
			
		ElseIf FwIsInCallStack("AGRA500") 
			oView :=  FWLoadView( "AGRA500" ) //carrega a view do OGA250
			oView:SetOperation(MODEL_OPERATION_UPDATE) //se que é alteração para a view
			oStrucNJK := oView:GetViewStruct("NJKUNICO") //carrega a estrutura da NJK da view
			oStrucNJK:SetProperty( "NJK_BASDES" , MVC_VIEW_CANCHANGE, .T. )
			If __lnewNeg 
				oStrucNJJ := oView:GetViewStruct("AGRA500_NJJ") //carrega a estrutura da NJJ da view
				oStrucNJJ:SetProperty( "NJJ_DATCHE" , MVC_VIEW_CANCHANGE, .T. )
				oStrucNJJ:SetProperty( "NJJ_HORCHE" , MVC_VIEW_CANCHANGE, .T. )
				oStrucNJJ:SetProperty( "NJJ_PESO3" ,  MODEL_FIELD_WHEN, .T. )
	
			EndIf
			oView:GetModel():GetModel("AGRA500_NJM"):SetNoInsertLine(.T.)
			oView:GetModel():GetModel("AGRA500_NJM"):SetNoUpdateLine(.T.)
			oView:GetModel():GetModel("AGRA500_NJM"):SetNoDeleteLine(.T.)

			//Para remover a linha abaixo, deve-se controlar os folders pela variavel lAgoClas no AGRA500
			oView:SetAfterViewActivate({|oModel|oView:HideFolder("GRADES",1,2),oView:HideFolder("GRADES",3,2)})
		EndIf

		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])

		aButtons  := {{.F.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}, {.T.,nil},{.T.,nil},{.f.,nil},{.f.,nil},{.f.,nil},;
		{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}}
		oFWMVCWindow:Activate(,,abuttons) 

		oView:DeActivate()
		FreeObj(oView)
		oFWMVCWindow:DeActivate()
		FreeObj(oFWMVCWindow)

		//seta variavel para informar que a função AgoClas não esta mais em execução
		//necessario pois a variavel é private e mantem valor .t. se não setar .f. o que interfere na chamada de outras funções
		lExecAgoClas := .f. 

	EndIf 	

Return

/** {Protheus.doc} vlQtdPeso3
Função que valida a quantidade fisica - NJJ_PESO3

@author: 	claudineia.reinert	
@since: 	02/06/2017
@Uso: 		OGA250
*/
Function vlQtdPeso3(oModel)
	Local oNJM			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJMUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJJ			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJK			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJKUNICO" )) //Protecao para usar funcao via AGRA500
	Local cQryNNC		:= GetNextAlias() 
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR 		:= NJR->( GetArea() )
	Local nPeso3Ant 	:= NJJ->NJJ_PESO3
	Local nLinha		:= 0
	Local nX			:= 0
	Local cClassRom 	:= cDefClasDesc(oNJJ:GetValue("NJJ_TIPO"), oModel,,(oNJJ:GetValue("NJJ_TPFRET") = 'F'.And. oNJJ:GetValue("NJJ_TPFORM") == "1")) 
	Local oView			:= FwViewActive()
		
	BeginSql Alias cQryNNC
		Select NNC.NNC_CODROM, NNC.NNC_QTDENT ,SUM(NNC.NNC_QTDFIX) AS NNC_QTDTOTFIX
		From %table:NNC% NNC
		Where 
		NNC.%NotDel%  
		and NNC.NNC_FILIAL = %xFilial:NNC% 
		and NNC.NNC_CODROM = %Exp:oNJJ:GetValue( "NJJ_CODROM" )%
		GROUP BY NNC.NNC_CODROM, NNC.NNC_QTDENT
	EndSql

	(cQryNNC)->( dbGoTop() )
	If !(cQryNNC)->( Eof() )
		While !(cQryNNC)->( Eof() )
			If oNJJ:GetValue( "NJJ_PESO3" ) < (cQryNNC)->( NNC_QTDTOTFIX ) 
                Agrhelp(STR0021,STR0524,STR0525)
				//#AJUDA #Existe fixação para este Romaneio, quantidade não pode ser menor que a quantidade ja fixada. #Verifique o volume fixado.
				Return ( .f. )

			endif
			(cQryNNC)->( DbSkip() )
		EndDo   
	EndIf
	(cQryNNC)->( dbCloseArea() )

	dbSelectArea( "NJR" )
	NJR->(dbSetOrder( 1 ))
	If NJR->(dbSeek( xFilial( "NJR" ) + oNJJ:GetValue( "NJJ_CODCTR" ) ))
		IF  (NJJ->NJJ_TIPO $ "2|4" ; 
		.and. ((NJR->NJR_QTDCTR + NJR->NJR_QTEFCO )  - ( NJR->NJR_QTSFCO + (oNJJ:GetValue( "NJJ_PESO3" ) - nPeso3Ant) ) < 0) ) ;
		.or. (NJJ->NJJ_TIPO == "5" ;     // 5= (E) Entrada por Compra
		.and. ((NJR->NJR_QTDCTR + NJR->NJR_QTSFCO )  - ( NJR->NJR_QTEFCO + (oNJJ:GetValue( "NJJ_PESO3" ) - nPeso3Ant) ) < 0) )
			Agrhelp(STR0021,STR0526,STR0527)
			//#AJUDA ##A quantidade do romaneio é maior que o saldo do contrato. #Verifique o saldo do contrato.	
			Return ( .f. )

		ENDIF

	EndIf

	If oNJJ:GetValue( "NJJ_PESO3" ) <= 0
		Agrhelp(STR0021,STR0528,STR0529)
		//#AJUDA #O Romaneio não pode ter quantidade fisica igual a zero. #Informe a Quantidade Física do romaneio.
		Return ( .f. )
	EndIf

	oNJM:SetNoUpdateLine(.F.)			

	//atualiza o Quantidade fisica da NJM 
	nLinha := oNJM:GetLine()
	For nX := 1 to oNJM:Length()
		oNJM:GoLine( nX )

		oNJM:SetValue( "NJM_QTDFCO", ( oNJJ:GetValue( "NJJ_PESO3" ) * ( oNJM:GetValue( "NJM_PERDIV" ) / 100 ) )  )

	Next nX
	oNJM:GoLine( nLinha )

	If lExecAgoClas
		fCarNJKClas(oModel)
	EndIf

	RestArea( aAreaNJR )
	RestArea( aAreaAtu )

Return ( .t. )

/** {Protheus.doc} atuQtdFCOCtr
Função que atualiza o saldo do contrato
na confirmação do modelo na execução da função AgoClas()

@author: 	claudineia.reinert	
@since: 	02/06/2017
@Uso: 		OGA250
*/
function atuQtdSldCtr() 
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR 		:= NJR->( GetArea() )
	Local aAreaNJM 		:= NJM->( GetArea() )
	Local nDifPeso3 	:= NJJ->NJJ_PESO3 - nPeso3Ant

	If lExecAgoClas .and. nDifPeso3 <> 0

		BEGIN TRANSACTION
			dbSelectArea( "NJM" )
			NJM->(dbSetOrder( 1 ))
			NJM->(dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
			While .Not. Eof() .And. NJM->(NJM_FILIAL) = xFilial( "NJM" ) .And. NJM->(NJM_CODROM) = NJJ->( NJJ_CODROM ) 
				If NJM->( NJM_TIPMOV ) = "1" // 1=Fisico

					NJR->( dbSetOrder( 1 ) )
					NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )
					If RecLock( "NJR", .f. )
						If NJJ->( NJJ_TIPO ) = "5" //compra
							NJR->( NJR_QTEFCO ) += ( nDifPeso3 * (NJM->(NJM_PERDIV) / 100) )  //atualiza apena com a diferença do valor anterior para o novo
						ElseIf NJJ->( NJJ_TIPO ) $ "2|4" //venda
							NJR->( NJR_QTSFCO ) += ( nDifPeso3 * (NJM->(NJM_PERDIV) / 100) ) //atualiza apena com a diferença do valor anterior para o novo
						EndIf
						NJR->( msUnLock() )
					EndIf

					// Atualiza qtdes do contrato				
					OGX010QTDS()

				EndIf	

				// Atualizando Autorizacoes
				If !Empty( NJM->NJM_CODAUT )
					dbSelectArea( "NJP" ) // Autorizacao
					NJP->(dbSetOrder( 1 ))
					If NJP->(dbSeek( xFilial( "NJP" ) + NJM->( NJM_CODCTR ) + NJM->( NJM_CODAUT ) ))
						If RecLock( "NJP", .f. )
							NJP->( NJP_QTDFCO ) += nDifPeso3 //atualiza apena com a diferença do valor anterior para o novo
							NJP->( msUnLock() )
						EndIf
					EndIf
				EndIf

				// Passa para o próximo registro de NJM
				NJM->( dbSkip() )
			EndDo
		END TRANSACTION
	EndIf

	RestArea( aAreaNJM )
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )

Return 

/*{Protheus.doc} OGA250ExcC
Função que Gera uma Adição por Excedente de Carga no Contrato
@author 	Tamyris Ganzenmueller
@since 		28/06/2017
@return 
*/
Function OGA250ExcC(nValExc)
	Local cCodMtv := ''
	Local cSeq    := ''
	Local oModelNNW :=FwLoadModel('OGA335')
	Local lRet   := .T.
	Local lExced := .F.

	cAliasQry := GetNextAlias()
	cQry :=    " SELECT NNQ.NNQ_CODMTV"
	cQry +=    " FROM " + RetSQLName("NNQ") + " NNQ "
	cQry +=    " WHERE NNQ.NNQ_FILIAL = '" + XFilial("NNQ") + "' "
	cQry +=    "   AND NNQ.NNQ_ADEXCE = '1' " //Sim
	cQry +=    "   AND NNQ.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	(cAliasQry)->( dbGoTop() )      
	If (cAliasQry)->( !Eof() )        
		cCodMtv := (cAliasQry)->NNQ_CODMTV
	EndIf
	(cAliasQry)->(dbCloseArea())

	If Empty(cCodMtv) 
		Return .F.
	EndIF

	cAliasQry := GetNextAlias()
	cQry :=    " SELECT NNW_ADEXCE"
	cQry +=    " FROM " + RetSQLName("NNW") + " NNW "
	cQry +=    " WHERE NNW.NNW_FILIAL = '" + XFilial("NNW") + "' "
	cQry +=    "   AND NNW.NNW_CODCTR = '" + NJR->NJR_CODCTR + "' "
	cQry +=    "   AND NNW.NNW_SEQ = (SELECT MAX(NNW_SEQ) FROM " + RetSQLName("NNW") + " 
	cQry +=    "                       WHERE NNW_CODCTR = '" + NJR->NJR_CODCTR + "' ) "
	cQry +=    "   AND NNW.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	(cAliasQry)->( dbGoTop() )      
	If (cAliasQry)->( !Eof() )        
		lExced := IIf( (cAliasQry)->NNW_ADEXCE == '1', .T., .F.)
	EndIf
	(cAliasQry)->(dbCloseArea())

	If lExced .And. !NJR->(NJR_TPEXC) == "3"
		Return .F.
	EndIf

	oModelNNW:SetOperation(MODEL_OPERATION_INSERT)
	If oModelNNW:Activate()
		oModelNNW:SetValue('NNWUNICO','NNW_CODCTR', NJR->NJR_CODCTR)
		oModelNNW:SetValue('NNWUNICO','NNW_CODROM', NJJ->NJJ_CODROM)		
		oModelNNW:SetValue('NNWUNICO','NNW_DATA'  , dDataBase )
		oModelNNW:SetValue('NNWUNICO','NNW_QTDALT', nValExc )
		oModelNNW:SetValue('NNWUNICO','NNW_ADEXCE', '1') //Sim
		oModelNNW:SetValue('NNWUNICO','NNW_TIPO'  , '1') //Adição
		oModelNNW:SetValue('NNWUNICO','NNW_CODMTV', cCodMtv )		

		If oModelNNW:VldData()
			If !oModelNNW:CommitData()
				lRet:=.F.
			Else
				cSeq := oModelNNW:GetValue('NNWUNICO','NNW_SEQ')

				dbSelectArea("NNW")
				NNW->(dbSetOrder(1))             
				If NNW->(dbSeek(xFilial("NNW")+NJR->NJR_CODCTR+cSeq) )
					lRet := OGA335C()
					If !LRet
						oModelNNW:Deactivate()
						oModelNNW:SetOperation(MODEL_OPERATION_DELETE)
						If oModelNNW:Activate()
							If oModelNNW:VldData()
								oModelNNW:CommitData()
							EndIf
						EndIf

						Return .F.
					EndIF
				EndIf
				NNW->(dbCloseArea())
			Endif
		Else
			lRet:=.F.
		Endif
	Else
		lRet:=.F.
	Endif

	oModelNNW:Deactivate()
	oModelNNW:Destroy()
	oModelNNW:=nil

Return lRet

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}

	aRet := OGI250(cXml, nTypeTrans, cTypeMessage)

Return aRet


/** {Protheus.doc} ChecarNNW
Na reabertura do romaneio, checa se romaneio tem aditação por excedente no contrato, 
caso tiver excluir a aditação e atualiza as quantidades do contrato

@return:	Nil
@author: 	Claudineia Heerdt Reinert
@since: 	06/07/2017
@Uso: 		OGA250 - Romaneio
*/
Function ChecarNNW(cCodCtr,cCodRom)
	Local cTipo		  := ""
	Local nQuant      := 0  
	Local cCodAutorz  := "" 

	dbSelectArea( "NJR" ) // Contratos
	NJR->(dbSetOrder( 1 ))
	If NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ))
		dbSelectArea( "NNW" ) 
		NNW->(dbSetOrder( 2 ))
		If NNW->(dbSeek( xFilial( "NNW" ) + cCodCtr + cCodRom ))
			cTipo  := Alltrim(NNW->( NNW_TIPO ))
			nQuant -= NNW->( NNW_QTDALT ) //NEGATIVO POIS SERÁ DELETADO O REGISTRO é deve atualizar o saldo do contrato

			If cTipo == "1"
				If RecLock( "NNW", .f. )
					NNW->( dbDelete() )
					NNW->( MsUnlock('NNW') )
				EndIf

				// Buscar a Autorização referente ao contrato selecionado 
				cCodAutorz := OGX010SAut( cCodCtr, NJJ->( NJJ_TIPO ) )

				dbSelectArea( "NJP" ) // Autorização
				NJP->(dbSetOrder( 1 ))
				If NJP->(dbSeek( xFilial( "NJP" ) + cCodCtr + cCodAutorz ))
					If RecLock( "NJP", .f. )
						NJP->( NJP_QTDAUT ) += nQuant //atualiza com a qdt da aditação
						NJP->( msUnLock() )
					EndIf
				EndIf
				NJP->(dbCloseArea())

				// Atualiza quantidades do contrato de acordo com as aditações / supressões
				OGA335AtuQtd()

				//atualiza as fixações
				StaticCall(OGA335, OGA335UpFx, cTipo, NJR->( NJR_QTDCTR ))

				// Atualiza qtdes do contrato e saldos
				OGX010QTDS()

				// Atualiza autorizações
				OGX010QAut()

				// Atualiza Previsão financeira
				If NJJ->(ColumnPos('NJR_CODNGC')) > 0 .and. __lnewNeg
					If Empty(NJR->NJR_CODNGC) //trata se é oriundo de novo negócio, se nao não chama
						OGA250ATUF( cCodCtr, nQuant, cTipo )
					EndIf
				EndIf

			EndIf

		EndIf  

	EndIf

return .T.		


/** {Protheus.doc} OGA250CHNF
Validação do campo "Chave NFE"

@return:	Nil
@author: 	Marcos Wagner Junior
@since: 	12/02/2018
@Uso: 		OGA250 - Romaneio
*/
Function OGA250CHNF()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "NJJUNICO" )
	Local nTamanho 	:= Len(AllTrim(oNJJ:GetValue("NJJ_CHVNFE")))
	Local lRet		:= .t.

	If nTamanho > 0 .AND. nTamanho <> 44
		oModel:GetModel():SetErrorMessage( oNJJ:GetId(), , oNJJ:GetId(), "", "", STR0350, STR0349, "", "") //"Valor digitado inválido!"###"Deverá ser informado 44 caracteres para o campo 'Chave NFe' !"
		lRet := .f.
	EndIf

Return lRet					


/*/{Protheus.doc} AGRA500VLT
//When do campo NJJ_TABELA
@author carlos.augusto
@since 12/02/2018
@version undefined

@type function
/*/
Function OGA250VLT()
	Local lRet := .T.
	Local oModel	:= FwModelActive()
	Local oModelNJJ	:= oModel:GetModel( "NJJUNICO" )

	If oModel:GetModel("NJJUNICO"):IsActive() 
		oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.T.)
		lRet := Iif(Posicione("SB5",1,fwxFilial("SB5")+oModelNJJ:GetValue("NJJ_CODPRO"),"B5_TPCOMMO")== '2',.F.,.T.)
		If !lRet
			oModelNJJ:LoadValue("NJJ_TABELA", Space(TamSX3("NJJ_TABELA")[01]))
			oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.F.)
			ResetNJK()
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} ResetNJK
//Deleta as linhas do grid NJK (ela esta somente no modelo)
@author carlos.augusto
@since 12/02/2018
@version undefined
@type function
/*/
Static Function ResetNJK()
	Local oModel	 := FwModelActive()
	Local oGrdNJK := oModel:GetModel( "NJKUNICO" )
	Local nX

	For nX := 1 to oGrdNJK:Length()
		oGrdNJK:GoLine( nX )
		oGrdNJK:DeleteLine()
	Next nX

	Return .T.

	/*/{Protheus.doc} OGA250QIE()
	Função que valida se a instrução de embarque selecionada possui quantidade instruida para a filial do romaneio.
	@type  Function
	@author rafael.kleestadt
	@since 22/02/2018
	@version 1.0
	@param param, param_type, param_descr
	@return lRet, Logical, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
	/*/
Function OGA250QIE()
	Local lRet    := .F.
	Local oModel  := FwModelActive()
	Local oNJJ	  := oModel:GetModel( "NJJUNICO" )
	Local oN9E	  := nil
	Local cCodine := nil
	Local cTpFrete := ""
	Local cContr := ""

	If __lnewNeg
		oN9E	  := oModel:GetModel( "N9EUNICO" )
		cCodine := oN9E:GetValue("N9E_CODINE")
		If oNJJ:GetValue("NJJ_TIPO") == "9"
			lRet := .T.
		Else
			DbSelectArea("N7S")
			DbSetOrder(1)
			If N7S->(DbSeek(FwxFilial("N7S") + cCodine))
				While N7S->( !Eof() ) .And. N7S->N7S_CODINE == cCodine	
					If N7S->N7S_QTDVIN > 0 .And. N7S->N7S_FILORG == FwxFilial("NJJ")		
						cContr := N7S->N7S_CODCTR
						lRet := .T.
						Exit
					EndIf
					N7S->(DbSkip())
				EndDo
			EndIf
			N7S->(DbCloseArea())
		EndIf

		//verifica se o produto do romaneio é o mesmo da IE
		DbSelectArea("N7Q")
		DbSetOrder(1)
		If N7Q->(DbSeek(FwxFilial("N7Q") + cCodine))
			If oNJJ:GetValue("NJJ_CODPRO") != N7Q->N7Q_CODPRO
				lRet    := .F.
			EndIf
		EndIf

		If .Not. lRet
			Help(" ",1,".OGA250000001.")//Problema: "Instrução de Embarque não instruída para este romaneio."
			Return .F.                  //Solução:  "Verifique se a instrução de embarque informada possui quantidade instruida e se a filial e produto são os mesmos do romaneio."
		EndIf

		If lRet 
			cTpFrete := GetDataSql("select NJR_TPFRET FROM " + RetSqlName("NJR") + " NJR " + ;
			"WHERE NJR_CODCTR = '" + cContr + "' " + ;
			"AND D_E_L_E_T_  = ' ' " )
			oNJJ:LoadValue("NJJ_TPFRET", cTpFrete )
		EndIf
	EndIf
Return lRet


/** {Protheus.doc} OGA250ALT
Rotina para validar a chamada de alteração

@return:	Nil
@author: 	Thiago Henrique Rover
@since: 	27/02/2018
@Uso: 		OGA250 - Romaneio
*/
Function OGA250ALT()
	Local aAreaAtu  := GetArea()
	Local cRetorno


	If __lnewNeg
		_lAltIE := .F.
		//Verificar se registros foram eliminados
		cAliasQry := GetNextAlias()
		cQuery := " SELECT N9E_FILIAL, N9E_ORIGEM"
		cQuery += " FROM " + RetSqlName("N9E") + " N9E "
		cQuery += " WHERE N9E_FILIAL = '" + xFilial('N9E') + "'"
		cQuery += "   AND N9E_CODROM = '" + NJJ->NJJ_CODROM + "'"
		cQuery += "   AND D_E_L_E_T_ = '' "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
		If !(cAliasQry)->(Eof()) .Or. (cAliasQry)->(Eof())
			cRetorno := (cAliasQry)->N9E_ORIGEM
		EndIf
		(cAliasQry)->(dbCloseArea())

		If  !(cRetorno $ "1,2")

			xRet := FWExecView('', 'VIEWDEF.OGA250', MODEL_OPERATION_UPDATE, , {|| .T. }) //"Incluir"
		Else 	
			Help(" ",1,".OGA250000002.")
			return .F.

		EndIf
	Else
		xRet := FWExecView('', 'VIEWDEF.OGA250', MODEL_OPERATION_UPDATE, , {|| .T. }) //"Incluir"		
	EndIf
	RestArea( aAreaAtu )
Return xRet

/** {Protheus.doc} OGA250EXP
Retorna se o romaneio é exportação

@return:	Nil
@author: 	francisco.nunes / tamyris.ganzenmueller
@since: 	07/03/2018
@Uso: 		OGA250 - Romaneio
@param cFilialR - Filial do Romaneio
@param cRomaneio
*/
Function OGA250EXP(cFilialR, cRomaneio)

	Local lExport := .F.

	if __lnewNeg
		DbSelectArea("N9E") // Romaneios X Angendamentos
		N9E->(DbSetOrder(1)) // N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
		If N9E->(dbSeek(cFilialR+cRomaneio))
			If !(N9E->(Eof()))			
				If N9E->(N9E_ORIGEM) == "1" .OR. N9E->(N9E_ORIGEM) == "2"				
					lExport	  := .T.
				EndIf									
			EndIf
		EndIf
		N9E->(dbCloseArea())
	endIf	

Return lExport

/** {Protheus.doc} OGA250IEOK
Validação no confirmar do romaneio, validando a quantidade remetida versus quantidade maxima permitida na instrução de embarque quando informada.
Validação para grãos e algodão.
Obs: Na atualização do romaneio é atualizado a quantidade remetida na IE.

@return:	Nil
@author: 	claudineia.reinert
@since: 	17/04/2018
@Uso: 		OGA250 - Romaneio

*/
Function OGA250IEOK()
	Local lRet 	:= .T.
	Local cMsg	:= ""

	DbSelectArea("N9E")
	N9E->(DbSetorder(1))
	IF N9E->(dbSeek(xFilial("N9E") + NJJ->NJJ_CODROM))
		While !N9E->(Eof()) .AND. ( xFilial("N9E") + N9E->N9E_CODROM == NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM )
			If !Empty(N9E->N9E_CODINE)
				DbSelectArea("N7Q")
				N7Q->(DbSetOrder(1))
				IF N7Q->(dbSeek(xFilial("N7Q") + N9E->N9E_CODINE))
					nQtdMaxima := (N7Q->N7Q_LIMMAX * ((100 - N7Q->N7Q_PERMAX) / 100)) // Qtd máxima da instrução
					If nQtdMaxima > 0 .and. nQtdMaxima < N7Q->N7Q_QTDREM
						cMsg += STR0354 + N7Q->N7Q_DESINE + Chr(13)+Chr(10)   //Instrução de Embarque:
						cMsg += STR0355 + cValToChar(nQtdMaxima) + Chr(13)+Chr(10)  //"Qtd. Máx. permitida na Instrução de Embarque: "
						cMsg += STR0356 + cValToChar(N7Q->N7Q_QTDREM) + Chr(13)+Chr(10)  //"Qtd. Remetida:" 
						lRet := .F.						
					EndIf
				EndIf
			EndIf			
			N9E->(DbSkip())
		EndDo
	EndIf

	If .NOT. lRet

		cMsg := STR0357 + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cMsg + Chr(13)+Chr(10) + STR0358  

		Help(, , STR0021, , cMsg, 1, 0 )//'HELP'### A quantidade/peso do romaneio ultrapassou a quantidade maxima da instrução de embarque vinculada no romaneio.

	EndIf

Return lRet

/*{Protheus.doc} OGA250DR
Informar Documento Referência - abre tela para informar os dados da NF do Cliente 
nas Vendas a Ordem
@author janaina.duarte
@since 18/04/2018
@version 1.0
@type function
*/
Function OGA250DR()
	Local lRet := .T.

	MsgAlert("Irá abrir tela para informar dados da NF do Cliente para Vendas a Ordem. Será implementado na DAGROGAP-4299")

Return lRet

/*---------------------------------------------------
{Protheus.doc} OGA250VGRID
//TODO Descrição auto-gerada.
@author thiago.rover
@since 27/04/2018
@version undefined
@type function
----------------------------------------------------*/
Function OGA250VGRID()

	Local oModel    := FwModelActive()
	Local oGridN9E  := oModel:GetModel("N9EUNICO")
	Local oModelNJJ := oModel:GetModel("NJJUNICO")
	Local nX        := 0
	Local lRet      := .T.

	Local nLineAtual    := oGridN9E:GetLine()
	Local cTipoIEAtual  := ""
	Local cTipoMerAtual := ""
	Local nLineAnt		:= 0
	Local cTipoIEAnt    := ""
	Local cTipoMerAnt   := ""

	// Não realiza a validação para devolução de remessa
	If oModelNJJ:GetValue("NJJ_TIPO") == "7" // Devolução de Remessa
		Return .T.
	EndIf	

	/**
	* Select que irá buscar o tipo de mercado localizado na NJR
	* por intermédio do Codigo da Instrução proveniente da escolha 
	* do usuário
	*/

	cTipoIeAtual  := Posicione("N7Q",1,xFilial("N7Q")+AllTrim(M->N9E_CODINE),"N7Q_TPCTR")
	cTipoMerAtual := Posicione("N7Q",1,xFilial("N7Q")+AllTrim(M->N9E_CODINE),"N7Q_TPMERC")

	For nX := 1 to oGridN9E:Length()
		oGridN9E:GoLine(nX)
		If !oGridN9E:IsDeleted() .AND. !Empty(oGridN9E:GetValue("N9E_CODINE",nX))
			cTipoIEAnt  := Posicione("N7Q",1,xFilial("N7Q")+AllTrim(oGridN9E:GetValue("N9E_CODINE",nX)),"N7Q_TPCTR")
			cTipoMerAnt	:= Posicione("N7Q",1,xFilial("N7Q")+AllTrim(oGridN9E:GetValue("N9E_CODINE",nX)),"N7Q_TPMERC")
			nLineAnt	:= nX
			EXIT 
		EndIf
	Next nX

	oGridN9E:GoLine(nLineAtual) 

	If	!oGridN9E:IsDeleted() .AND. nLineAtual <> nLineAnt
		If (cTipoMerAnt != cTipoMerAtual) .Or. (cTipoIEAnt != cTipoIeAtual)
			lRet := .F.
		EndIF
	EndIf	

	IF oGridN9E:IsInserted() .OR. oGridN9E:IsUpdated()
		If __cAnaCred $ "1|2|3" //Parâmetro de análise de crédito: 1 - Interno, 2 - Externo, 3 - Ambos, 4 - Nenhum
			If __cAnaCred = "3" //Ambos
				_lAltIE := .T.
			ElseIf __cAnaCred = cTipoMerAtual
				_lAltIE := .T.
			EndIf
		Else
			_lAltIE := .F.
		EndIf
	EndIf

	If .NOT. lRet
		Help(" ",1,".OGA250000003.")//Instruções de Embarque com tipo de mercado ou tipo de produtos diferentes.Informe outra Instrução que atenda os requisitos ou altere a Instrução escolhida.
		return .F.
	Endif

Return lRet

/*--------------------------------------------
{Protheus.doc} OG250DORIG
Função que retorna o inicializador padrão do campo N9E_DESORG

@author francisco.nunes
@since 10/05/2018
@version 1.0
@type function
--------------------------------------------*/
Function OG250DORIG()

	Local cDesOrig := ""

	If !INCLUI
		cDesOrig := Posicione("SX5",1,xFilial("SX5")+"KB"+N9E->N9E_ORIGEM,"X5DESCRI()")
	Else
		// Caso seja inclusão do romaneio, o incializador do origem é 5 (Manual)
		cDesOrig := Posicione("SX5",1,xFilial("SX5")+"KB"+"5","X5DESCRI()")
	EndIf

Return cDesOrig

//-------------------------------------------------------------------
/*/{Protheus.doc} OG250TWhen
When do campo resultado da tela de classificação
@author  rafael.voltz
@since   20/07/2018
@version version
/*/
//-------------------------------------------------------------------
Function OG250TWhen(oModel, cField)
	Local oModelNJJ := oModel:GetModel():GetModel("NJJUNICO")
	Local oModelNJK := oModel:GetModel():GetModel("NJKUNICO")

	If fIsGrupo(oModelNJJ:GetValue("NJJ_TABELA"), oModelNJK:GetValue("NJK_CODDES"))
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGA250REG
Chama o navegador para abrir o link do documento.
@author  felipe.rafael
@since   20/01/2019
@version version
/*/
//-------------------------------------------------------------------

Function OGA250REG(cCodFil, cCodRom)//Verificar para retirar  do menu oga251 e oga255 

	If Empty(POSICIONE("NJJ",1,cCodFil+cCodRom,"NJJ_DATCHE"))
		DbselectArea("NCY")
		DbSetOrder(1)
		If DbSeek(FWxFilial("NCY")+"NJJ"+cCodFil+cCodRom)
			ShellExecute( "open", NCY->NCY_MSG, "", "", 5 )
		Else
			MsgAlert("Romaneio sem documento de entrega") //cadastrar STR
		EndIf
	Else
		MsgAlert("Romaneio não entregue")
	EndIF

return .t.

/*/{Protheus.doc} fGetN7SDat
// Gatilha os dados da IE para os outros campos necessários.
@author gustavo.pereira	/ brunosilva
@since 04/04/2019
@version 1.0
@type static function
/*/
Static Function fGetN7SDat()

	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oN9E		:= oModel:GetModel( "N9EUNICO" )	
	Local oNJM		:= oModel:GetModel( "NJMUNICO" )
	Local oNJJ		:= oModel:GetModel( "NJJUNICO" )

	if !Empty(oN9E:GetValue('N9E_CODINE'))
		DbSelectArea('N7S')
		DbSetOrder(3)
		If DBSeek(FWxFilial("N7S")+ oN9E:GetValue('N9E_CODINE'))

			If Empty(Alltrim(oNJM:GetValue('NJM_OPEFIS')))
				oNJM:SetValue('NJM_OPEFIS', N7S->N7S_OPEFIS)
			Endif

			oN9E:SetValue('N9E_CODCTR',N7S->N7S_CODCTR)

			dbSelectArea( "NJR" )
			NJR->(dbSetOrder( 1 ))
			If NJR->(dbSeek( xFilial( "NJR" ) + N7S->N7S_CODCTR ))
				oNJJ:SetValue( "NJJ_CODENT", NJR->NJR_CODENT )
				oNJJ:SetValue( "NJJ_LOJENT", NJR->NJR_LOJENT )
				oNJJ:SetValue( "NJJ_CODSAF", NJR->NJR_CODSAF )          
				oNJJ:SetValue( "NJJ_CODPRO", NJR->NJR_CODPRO )		

				oNJJ:SetValue( "NJJ_TPFRET", NJR->NJR_TPFRET )
				oNJJ:SetValue( "NJJ_TES",    N7S->N7S_TES )

				oNJM:GoLine(1)

				oNJM:SetValue( "NJM_FILORG", FWxFilial("NJR")) 
				oNJM:SetValue( "NJM_CLVL"  , NJR->NJR_CLVL)
				oNJM:SetValue( "NJM_CODENT", NJR->NJR_CODENT)
				oNJM:SetValue( "NJM_LOJENT", NJR->NJR_LOJENT)
				oNJM:SetValue( "NJM_CODCTR", N7S->N7S_CODCTR)

				If Empty(oNJJ:GetValue( "NJJ_TABELA" ))  .and. (!IsInCallStack("OGA710") .and. !IsInCallStack("OGA290"))
					oNJJ:SetValue( "NJJ_TABELA", NJR->NJR_TABELA )
				EndIf			

			EndIf
		Endif

		N7S->(DbCloseArea())	
		RestArea(aArea)
	else	
		oNJJ:SetValue("NJJ_TPFRET", Space(TamSX3("NJJ_TPFRET")[01]))
		oNJJ:SetValue("NJJ_TES", Space(TamSX3("NJJ_TES")[01]))

		oNJM:SetValue("NJM_CODCTR", Space(TamSX3("NJM_CODCTR")[01]))

		oN9E:SetValue("N9E_CODCTR", Space(TamSX3("N9E_CODCTR")[01]))
	endIf

Return .T.

/*/{Protheus.doc} OGA250VLCT
//WHEN do NJJ_CODCTR para que quando for novo negócio, não habilite caso seja saída por venda.
@author brunosilva
@since 16/05/2019
@version 1.0

@type function
/*/
Function OGA250VLCT()
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oModelNJJ	:= oModel:GetModel( "NJJUNICO" )
	Local cTipo		:= oModelNJJ:GetValue("NJJ_TIPO")

	If !FWISINCALLSTACK("OGX290NFUT")
		iif(cTipo = "4",lRet := .F., )
	EndIf

Return lRet


/*/{Protheus.doc} fTrgTpTes
//Responsável por gatilhar a TES quando alterado o Tp romaneio e o Cod Ctr estiver preenchido.
@author brunosilva
@since 18/07/2019
@version 1.0

@type function
/*/
Static Function fTrgTpTes(oParModel, xValue)

	Local oModel	:= oParModel:GetModel()
	Local oNJJ		:= oModel:GetModel( "NJJUNICO" )	
	Local cCodCtr   := oNJJ:GetValue( "NJJ_CODCTR" )
	Local cTipo 	:= xValue
	Local cTES 		:= ""

	If .Not. Empty( cCodCtr )
		dbSelectArea( "NJR" )
		NJR->(dbSetOrder( 1 ))
		If NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ))
			//Se for romaneio de devolucao, pegar a TES de devolução associada a tes do contrato.
			if cTipo $ "6|7|8|9"
				SF4->( dbSetOrder( 1 ) )
				SF4->( dbSeek( FWxFilial( "SF4" ) + NJR->NJR_TESEST ) )
				cTES := SF4->F4_TESDV
				//				oNJJ:SetValue( "NJJ_TES", SF4->F4_TESDV )
			else
				cTES := NJR->NJR_TESEST
				//				oNJJ:SetValue( "NJJ_TES", NJR->NJR_TESEST )
			endIf
		endIf
	else
		cTES := ""
		//		oNJJ:SetValue( "NJJ_TES", "" )
	endIf

return cTES


/*{Protheus.doc} OGASPED
//chama o SPEDNEF e após o envio atualiza os dados da nota
@author felipe.mendes
@since 05/10/2019
@version 1
@type function
*/
Function OGASPED()

SPEDNFE() //Chama o Sped
OGAjusDcFis() //Atualiza a CHAVENFE

Return .t.

/** {Protheus.doc} OGAjusDcFis
Verifica se o Romaneio possui chave da nota fiscal, Caso o Romaneio estiver completo e sem chave, 
essa rotina irá associar a chave ao romaneio.

@param:     Nil
@return:    Nil
@author:    Vinícius Becher Pagung
@since:     30/03/2016
@Uso:       SIGAAGR
*/

Function OGAjusDcFis()
	Local aAreaAtu      := GetArea()
	Local aCliFor       := {}
	Local cTipoNF       := ""
	Local cCliFor       := ""
	Local cLoja         := ""

	Private cAliasNJM   := ''  

	cAliasNJM := GetNextAlias()
	QryBaka := " SELECT NJM_CHVNFE,NJM.NJM_TIPO, NJM.NJM_DOCNUM, NJM.NJM_DOCSER, NJM.NJM_PEDIDO, NJM.NJM_QTDFIS, NJM.NJM_CODENT, NJM.NJM_LOJENT, NJM.NJM_TES, NJM.R_E_C_N_O_"
	QryBaka += " FROM " + RetSqlName('NJM')+ " NJM "
	QryBaka += " WHERE NJM.D_E_L_E_T_ ='' "
	QryBaka += " AND NJM.NJM_CHVNFE  = '' "
	QryBaka += " AND NJM.NJM_STAFIS  = '2'"
	QryBaka += " AND NJM.NJM_DOCSER != '' "
	QryBaka += " AND NJM.NJM_DOCNUM != '' "
	QryBaka := ChangeQuery(QryBaka)

	If select("cAliasNJM") <> 0
		cAliasNJM->( dbCloseArea() )
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,QryBaka),cAliasNJM,.T.,.T.)
	DbSelectArea( cAliasNJM )  
	(cAliasNJM)->( dbGoTop() )

	DbSelectArea("NJM")
	DbSetOrder(1)
	DbSeek(xFilial("NJM")+NJJ->NJJ_CODROM)
	While NJM->( !Eof() ) .AND. xFilial("NJM")+NJJ->NJJ_CODROM == NJM->NJM_FILIAL + NJM->NJM_CODROM

		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aCliFor := OGA250ClFr( NJM->NJM_CODENT, NJM->NJM_LOJENT, NJM->NJM_TES, NJM->NJM_TIPO, NJM->NJM_QTDFIS )
		cTipoNF := aCliFor[ 1 ]
		cCliFor := aCliFor[ 2 ]
		cLoja   := aCliFor[ 3 ]

		If NJM->NJM_TIPO $ "3|5|7|9" // Se for romaneio de ENTRADA
			DbSelectArea( "SF1" )
			DbSetOrder( 1 ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If DbSeek( xFilial( "SF1" ) + NJM->NJM_DOCNUM + NJM->NJM_DOCSER + cCliFor + cLoja )  
				
				If Empty(NJM->NJM_CHVNFE) .AND. RecLock("NJM", .F.)
					NJM->NJM_CHVNFE := SF1->F1_CHVNFE
					NJM->(MsUnlock())
				EndIf 
				If Empty(NJJ->NJJ_CHVNFE) .AND. RecLock("NJJ", .F.) 
					NJJ->NJJ_CHVNFE := SF1->F1_CHVNFE
					NJJ->(MsUnlock())
				EndIf
			EndIf

		Else    // Se for romaneio de SAIDA
			DbSelectArea( "SC5" )
			DbSetOrder( 1 ) //C5_FILIAL+C5_NUM
			If DbSeek( xFilial( "SC5" ) + NJM->NJM_PEDIDO )

				DbSelectArea( "SF2" )
				DbSetOrder( 1 ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If DbSeek( xFilial( "SF2" ) + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
					If Empty(NJM->NJM_CHVNFE) .AND. RecLock("NJM", .F.)
						NJM->NJM_CHVNFE := SF2->F2_CHVNFE
						NJM->(MsUnlock())
					EndIf 
					If Empty(NJJ->NJJ_CHVNFE) .AND. RecLock("NJJ", .F.) 
						NJJ->NJJ_CHVNFE := SF2->F2_CHVNFE
						NJJ->(MsUnlock())
					EndIf
				EndIf
			Endif
		EndIf 
		NJM->(DbSkip())
	EndDo
	RestArea( aAreaAtu )
Return( NIL )

/*/{Protheus.doc} fSetKey
	(long_description)
	@type  Function
	@author rafael.voltz
	@since 29/01/2020
	@version 1.0	
	@example
	(examples)
	@see (links_or_references)
	/*/
Function fSetKey()
	SetKey( VK_F11, { || aIniPad := OGA250INIT( .t. ) } )
	SetKey( VK_F12, { || aParBal:= AGRX003E( .t., 'OGA050001' ) } )
	SetKey( VK_F10, { || OGA250VKF10() } )
Return 

/*/{Protheus.doc} fGetResul
	Busca a faixa do resultado com base no percentual
	@type  Static Function
	@author user
	@since 07/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGetResul(cTabela, cCodDes, nPct)
	Local cQry  := GetNextAlias()
	Local nValor := 0
	
	BeginSQL Alias cQry
		SELECT NNK_PERFIM 
		  FROM %table:NNK% NNK
		WHERE NNK_FILIAL = %xFilial:NNK%
		  AND NNK_CODTAB = %Exp: cTabela%
		  AND NNK_CODDES = %Exp: cCodDes%
		  AND NNK_PERDES >= %Exp: nPct%
		  AND %notDel%
		  ORDER BY NNK_PERFIM
	EndSql

	nValor := (cQry)->NNK_PERFIM

	(cQry)->(dbCloseArea())

	If Empty(nValor)
		nValor := 0
	EndIf

Return nValor

/*/{Protheus.doc} OGA250DESC
	Validação do campo NJK_QTDDES
	@type  Function
	@author user
	@since 07/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA250DESC()

	If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
		OGA250ATUG(.f.)
	EndIf
	
Return .T.
/** {Protheus.doc} PreGrdNJM
Pre validação do grid NJM

@return:	lRetorno - verdadeiro ou falso
@author: 	felipe.mendes
@Uso: 		OGA250 - Romaneio
*/
Static Function PreGrdNJM( oModel, nLinha, cAcao, cCampo,xVrNovo,xVrAnt )
Local lRetorno := .T.
Local cOpeTri := "2"

If cAcao == 'SETVALUE'
	If cCampo == 'NJM_CODCTR' .AND. !Empty(xVrNovo)
		cOpeTri := Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_OPETRI" )
		//Preenchimento de valores necessarios para confirmação
		oModel:SetValue("NJM_CODENT", Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_CODENT" ) )		
		oModel:SetValue("NJM_LOJENT", Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_LOJENT" ) )
		oModel:SetValue("NJM_CODPRO", Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_CODPRO" ) )
		oModel:SetValue("NJM_CODSAF", Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_CODSAF" ) ) 
		If cOpeTri == "1"
			oModel:SetValue("NJM_TES"   , Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_TESFIN" ) )
		Else
			oModel:SetValue("NJM_TES"   , Posicione( "NJR", 1, xFilial("NJR") + xVrNovo , "NJR_TESEST" ) )
		EndIf
	Endif
Endif

Return( lRetorno )

/*/{Protheus.doc} OGA250COMP
	Gera nota fiscal complementar a partir do romaneio posicionado.
	@type  Function
	@author mauricio.joao
	@since 30/03/2020
	@version 1.0
	/*/
Function OGA250COMP()
Local aInformacoes := {}
Local cNfGerada :=  ""
Local lRet      := .T.
Local cDescErro := ""
Local cContrato := ""
Local nValorCompl := ""
Local aAreaNJJ  := NJJ->(GetArea())
Local cNJJRom   := ""

Private _lComplRom := .F. //pra poder incluir romaneio sem quantidade.

    If !fRomVinc(NJJ->NJJ_CODROM)
        //busca informações do romaneio posicionado
        oModelOrig := FwLoadModel("OGA250")
        oModelOrig:SetOperation(MODEL_OPERATION_VIEW)
        oModelOrig:Activate()

        //Validações
        If !fValCompl(oModelOrig)
            oModelOrig:DeActivate() // Desativa o model
            oModelOrig:Destroy() // Destroi o objeto do model
            RestArea(aAreaNJJ)        
            Return 
        EndIf

        //Dialog para pegar TES e Valor do complemento
        aInformacoes := fDlgCompl(oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODROM"))

        If Empty(aInformacoes) .or. aInformacoes[1] == .F.
            RestArea(aAreaNJJ)        
            Return 
        EndIf

        cNJJRom         := oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODROM")    	
        cContrato 		:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODCTR")    	
        cTipRom         := oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_TIPO")    	
        cCodEnt         := oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODENT")    	
        cLojEnt         := oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_LOJENT")    	
        nValorCompl		:= aInformacoes[2]    

        //-- Se a serie não estiver preenchida no parametro, abre a tela para seleção da série --//
        cSeriSF2 := SuperGetMV("MV_OGASERS"	,.f.," "	)

        If Empty( cSeriSF2 )	
            If .Not. SX5NumNota(@cSeriSF2, GetNewPar("MV_TPNRNFS","1") )
                RestArea(aAreaNJJ)            
                Return ( )
            EndIf
        EndIf	

        Begin Transaction 
            _lComplRom := .T.
            Processa({|| lRet := OGA430BNfCplV(, nValorCompl, @cDescErro, cSeriSF2, @cNfGerada, 0,,, oModelOrig)},OemToAnsi( "Gerando Documento Fiscal de Complemento" ) ) //#"Gerando Documento Fiscal de Complemento"        
            
            // Gera o romaneio simbólico a partir da NF
            // NJJ_TIPO, NJJ_CODENT, NJJ_LOJENT, NJJ_DOCSER, NJJ_DOCNUM, NJJ_CODCTR
            If lRet 
                If lRet := OGA251GSimb( cTipRom, cCodEnt, cLojEnt , cSeriSF2, cNfGerada, cContrato, NIL, NIL, cNJJRom )	
                    If lRet := OGA250RELC(cNJJRom, NJJ->NJJ_CODROM, "C" /*COMPLEMENTO*/) 
                        //atualiza romaneio
                        If lRet := OGA250ATUC() 
                            //confirma o romaneio
                            lRet := OGA250NF( Alias(), Recno(), 4, .t. ) 
                        EndIf				
                    EndIf
                EndIf
            EndIf
            
            _lComplRom := .F.		
            oModelOrig:DeActivate() // Desativa o model
            oModelOrig:Destroy()    // Destroi o objeto do model

            If lRet   						
                MsgInfo(STR0533 + _CRLF + STR0136 +": " + cNfGerada + _CRLF + STR0534 + cSeriSF2 + _CRLF + STR0135 +": " + NJJ->NJJ_CODROM) //#"Documento fiscal de complemento de preço gerado com sucesso." #Doc. Fiscal #Série  #"Romaneio simbólico: "
            Else
                MsgAlert(STR0535 + _CRLF + alltrim(cDescErro))  
                DisarmTransaction()
            EndIf		
            
        End Transaction     
    Else
        AgrHelp(STR0021, STR0537, STR0538) //#Não é possível emitir nota de complemento, pois romaneio já possui vínculo com a fixação. //"Quando há vínculo com a fixação, somente é possível gerar complemento por meio do Ajuste de Pendências do Gestor de Entidades."
    EndIf

    RestArea(aAreaNJJ)    

Return 

/*/{Protheus.doc} fValCompl
	(long_description)
	@type  Static Function
	@author mauricio.joao
	@since 01/04/2020
	@version 1.0
	@param omodelorig, object, romaneio original
/*/
Static Function fValCompl(oModelOrig)
Local lValida := .T.

Do Case
	Case GetRpoRelease() < "12.1.023"
		Agrhelp(STR0021,STR0382+GetRpoRelease(),STR0383) 
		 //"Atenção","A Rotina de Complemento de Romaneio não está habilitada para release: ","Favor entre em contato com a Equipe TOTVS."
		lValida := .F.
	Case oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_TIPO") <> "4"
		Agrhelp(STR0021,STR0384,STR0385) 	
	 	//'Atenção',"Tipo de romaneio selecionado esta incorreto.","Para complemento de preço, favor selecionar tipo de romaneio '4 - Saida por venda'"
		lValida := .F.	
	Case oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_STATUS") <> "3"
		 Agrhelp(STR0021,STR0386,STR0387) 
	 	//"Atenção","Status do Romaneio não permite Complemento de Preço.","Para geração do Complemento de Preço é necessário que o status do romaneio seja 3-Confirmado."
		lValida := .F.	
EndCase
	
Return lValida

/*/{Protheus.doc} fDialog()
	(long_description)
	@type  Static Function
	@author mauricio.joao
	@since 30/03/2020
	@version 1.0
	/*/
Static Function fDlgCompl(cRomaneio)
Local aInformacoes := {}

Local nValorCompl := 0 // Variável do tipo numérica

oModal := FWDialogModal():New()       
oModal:SetEscClose(.T.)
oModal:setTitle(STR0388+cRomaneio)
	
//Seta a largura e altura da janela em pixel
oModal:setSize(80, 300)
oModal:createDialog()

oModal:addButton(STR0040,{||fFecha(nValorCompl,aInformacoes)}) //Confirmar
oModal:addButton(STR0084,{||oModal:OOWNER:END() }) //"Cancelar"
oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

nLinGet := 5
nColGet := 70

nLinSay := 5
nColSay := 5

//confirmar

//Valor complementar	
TSay():New(nLinSay,nColSay,{|| STR0389},oContainer,,,,,,.T.,,,60,20,,,,,,.T.) //Valor Complementar
oGet2 := TGet():New( nLinGet, nColGet, { | u | If( PCount() == 0, nValorCompl, nValorCompl := u ) },oContainer, ;
     060, 010, "@E 999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nValorCompl",,,,.t.  )
nLinGet += 15
nLinSay += 15

oModal:Activate()

Return aInformacoes

/*/{Protheus.doc} fFecha
	(long_description)
	@type  Static Function
	@author mauricio.joao
	@since 01/04/2020
	@version 1.0
	/*/
Static Function fFecha(nValorCompl,aInformacoes)

	Do Case		
        Case Empty(nValorCompl) .OR. nValorCompl <= 0
            MsgAlert(STR0392) //"Valor do complemento não preenchido.")
            AADD( aInformacoes, .F. )	
	EndCase
	
	AADD( aInformacoes, .T. )
	AADD( aInformacoes, nValorCompl )	

	oModal:OOWNER:END()

Return .T.

/*/{Protheus.doc} OGA250RELC
    Função para gravar os relacionamentos entre romaneios.
    @type  Function
    @author user
    @since 14/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OGA250RELC(cRomOrig, cRomRel, cTipoRel)
 Local lRet      := .T.
 Local cAliasQry := ""
 Local cSequenc  := "001"

    If TableInDic('ND4') 
        cAliasQry := GetNextAlias()
        
        BeginSQL Alias cAliasQry
            SELECT Max(ND4_SEQUEN) ND4_SEQUEN
            FROM %table:ND4%
            WHERE ND4_FILIAL = %xFilial:ND4%
            AND ND4_CODROM  = %Exp:cRomOrig%
            AND %notDel%
        EndSql

        If !Empty((cAliasQry)->ND4_SEQUEN)
            cSequenc := Soma1((cAliasQry)->ND4_SEQUEN) 
        EndIf

        (cAliasQry)->(dbCloseArea())

        If !Empty(cRomOrig) .and. !Empty(cRomRel) .and. !Empty(cTipoRel)
            RecLock("ND4", .T.)
            ND4->ND4_FILIAL := xFilial("ND4")
            ND4->ND4_CODROM := cRomOrig
            ND4->ND4_SEQUEN := cSequenc
            ND4->ND4_ROMREL := cRomRel
            ND4->ND4_TIPREL := cTipoRel
            ND4->(MsUnLock())
        Else        
			lRet := .F.
        EndIf 
    EndIf
    
Return lRet

/*/{Protheus.doc} fHasGrupo
	Verifica se na tabela de classificação possui grupos ou subgrupos.
	@type  Static Function
	@author user
	@since 07/04/2020	
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fHasGrupo(cTabela as char)
	Local cAliasQry  as char
	Local lRet       as logical	

    Default cTabela := ""

	If NNJ->(ColumnPos('NNJ_GRUPO')) > 0
		cAliasQry := GetNextAlias()
		lRet      := .F.

		If Empty(cTabela)
			BeginSql Alias cAliasQry
				SELECT Count(*) Qtd 
				FROM %table:NNJ% 
				WHERE NNJ_FILIAL = %xFilial:NNJ%				
				AND (NNJ_GRUPO  = '1'  OR NNJ_GRUPO  = '2')				
				AND %notDel% 
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT Count(*) Qtd 
				FROM %table:NNJ% 
				WHERE NNJ_FILIAL = %xFilial:NNJ%
				AND NNJ_CODTAB   = %exp:cTabela%
				AND (NNJ_GRUPO   = '1'  OR NNJ_GRUPO  = '2')				
				AND %notDel% 
			EndSql
		EndIf

		If (cAliasQry)->Qtd > 0
			lRet := .T.
		EndIf

		(cAliasQry)->(dbCloseArea())	
	EndIf
	
Return lRet

 /*/{Protheus.doc} fIsGrupo
	Verifica se o desconto é grupo ou subgrupo
	@type  Static Function
	@author user
	@since 07/04/2020	
	@example
	(examples)
	@see (links_or_references)
	/*****/
Static Function fIsGrupo(cTabela, cCodigoDes)
 Local aAreaNNJ := NNJ->(GetArea())
 Local lRet := .F.

  If NNJ->(ColumnPos('NNJ_GRUPO')) > 0
	 NNJ->(dbSetOrder(1))
	 If NNJ->(DBSeek(xFilial("NNJ") + cTabela + cCodigoDes))
	 	If NNJ->NNJ_GRUPO == "1" .or. NNJ->NNJ_GRUPO == "2"
	 		lRet := .T.
	 	EndIf
	 EndIf
     
	 RestArea(aAreaNNJ)
  EndIf

Return lRet 

/*/{Protheus.doc} fRomVinc
    Função para verificar se existe relacionamento na NNC
    @type  Static Function
    @author rafael.voltz
    @since 02/06/2020
    @version 1.0
    @param cRomaneio, char, Código do Romaneio
    @return lRet, logical, REtorna se possui ou não relacionamento na NNC
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fRomVinc(cRomaneio as char)
    Local cAliasQry as char
    Local lRet      as logical

    cAliasQry := GetNextAlias()
    lRet      := .F.

    BeginSql Alias cAliasQry
        SELECT COUNT(*) COUNT
          FROM %table:NNC%
         WHERE NNC_FILIAL = %xFilial:NNC%
           AND NNC_CODROM = %Exp:cRomaneio%           
           AND %notDel%
    EndSQL

    If (cAliasQry)->COUNT > 0
        lRet := .T.
    EndIf
    
    (cAliasQry)->(dbCloseArea())

Return lRet

/** {Protheus.doc} fTrgMoega
Gatilho para atribuir  a descrição da moega

@param: 	Nil
@return:	NL5_DESCRI
@author: 	FSW
@since: 	11/2020
@Uso: 		OGA250 - Romaneio

*/
Static Function fTrgMoega(oStruNJJ)
	Local cMoega 	:= oStruNJJ:GetValue("NJJ_MOEGA")
	Local cDesMoega as char

	if !Empty(cMoega)

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT NL5_DESCRI
			FROM %table:NL5%
			WHERE NL5_FILIAL = %xFilial:NL5%
			AND NL5_MOEGA = %Exp:cMoega%
			AND %notDel%
		EndSQL

		If (cAliasQry)->(!Eof())
			cDesMoega := (cAliasQry)->NL5_DESCRI
		EndIf
		
		(cAliasQry)->(dbCloseArea())
	endIF

Return cDesMoega

/** {Protheus.doc} fTrgCultiv
Gatilho para atribuir  a descrição da cultivar
@param: 	Nil
@return:	NP4_CULTIV
@author: 	FSW
@since: 	11/2020
@Uso: 		OGA250 - Romaneio

*/
Static Function fTrgCultiv(oStruNJJ)
 	Local cCultiv 	:= oStruNJJ:GetValue("NJJ_CULTIV")
	Local cDesCultiv as char

	if !Empty(cCultiv)

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT NP4_DESCRI
			FROM %table:NP4%
			WHERE NP4_FILIAL = %xFilial:NP4%
			AND NP4_CODIGO = %Exp:cCultiv%
			AND %notDel%
		EndSQL

		If (cAliasQry)->(!Eof())
			cDesCultiv := (cAliasQry)->NP4_DESCRI
		EndIf
		
		(cAliasQry)->(dbCloseArea())
	endIF

Return cDesCultiv

/** {Protheus.doc} fTrgLocal
Gatilho para atribuir  o Local 
@param: 	Nil
@return:	NNR_CODIGO
@author: 	FSW
@since: 	11/2020
@Uso: 		OGA250 - Romaneio

*/
Static Function fTrgLocal(oStruNJJ)
	Local cCultiv 	:= oStruNJJ:GetValue("NJJ_CULTIV")
	Local cMoega 	:= oStruNJJ:GetValue("NJJ_MOEGA")
	Local cProduto 	:= oStruNJJ:GetValue("NJJ_CODPRO")
	Local cLocal 	:= ''

	cLocal := getLocal(cCultiv,cMoega,cProduto)
Return cLocal

/** {Protheus.doc} vldMoega
Função para retornar o local conforme parâmetros
@param: 	Nil
@return:	NNR_CODIGO
@author: 	FSW
@since: 	11/2020
@Uso: 		OGA250 - Romaneio

*/
Function vldMoega(oStruNJJ,cCampo)
	Local lRet := .T.
	Local cMoega:= '' 
	Local cLocal:= ''
	Local cCodPro:= ''
	Local cCultiv:= ''
	Local oModel := FwModelActive()
	Local oNJJ	 := oModel:GetModel( "NJJUNICO" )

	if cCampo == 'NJJ_LOCAL'
		cLocal:= oStruNJJ:GetValue("NJJ_LOCAL")
	
		// se as variáveis da struct estão diferentes das variáveis de memória, significa que já está validando o local gatilhado, sendo assim, deve-se utilizar o campo da struct
		if M->NJJ_MOEGA != oStruNJJ:GetValue("NJJ_MOEGA")
			cMoega:= oStruNJJ:GetValue("NJJ_MOEGA")
		else
			cMoega:= M->NJJ_MOEGA
		endif
	
		if M->NJJ_CODPRO != oStruNJJ:GetValue("NJJ_CODPRO")
			cCodPro:= oStruNJJ:GetValue("NJJ_CODPRO")
		else
			cCodPro:= M->NJJ_CODPRO
		endif


		if M->NJJ_CULTIV != oStruNJJ:GetValue("NJJ_CULTIV")
			cCultiv:= oStruNJJ:GetValue("NJJ_CULTIV")
		else
			cCultiv:= M->NJJ_CULTIV
		endif
	elseif cCampo == 'NJJ_MOEGA'
		cMoega:= oStruNJJ:GetValue("NJJ_MOEGA")
		cLocal:= M->NJJ_LOCAL
		cCodPro:= M->NJJ_CODPRO
		cCultiv:= M->NJJ_CULTIV
	elseif cCampo == 'NJJ_CODPRO'
		cMoega:= M->NJJ_MOEGA
		cLocal:= M->NJJ_LOCAL
		cCodPro:= oStruNJJ:GetValue("NJJ_CODPRO")
		cCultiv:= M->NJJ_CULTIV
	elseif cCampo == 'NJJ_CULTIV'
		cMoega:= M->NJJ_MOEGA
		cLocal:= M->NJJ_LOCAL
		cCodPro:= M->NJJ_CODPRO
		cCultiv:= oStruNJJ:GetValue("NJJ_CULTIV")
	else
		cMoega:= oStruNJJ:GetValue("NJJ_MOEGA")
		cLocal:= oStruNJJ:GetValue("NJJ_LOCAL")
		cCodPro:= oStruNJJ:GetValue("NJJ_CODPRO")
		cCultiv:= oStruNJJ:GetValue("NJJ_CULTIV")	
	endif
	if !Empty(cMoega) .AND. !Empty(cCodPro)
		if cCampo == 'NJJ_LOCAL' .OR. cCampo == 'TUDOK'
			if Empty(getLocal(cCultiv,cMoega,cCodPro,cLocal))
				lRet:= .F.
			endif
		else
			if Empty(getLocal(cCultiv,cMoega,cCodPro))
				lRet:= .F.
			endif
		endif
		if !lRet
			oModel:GetModel():SetErrorMessage( cMoega, , cMoega, "", "", STR0546+cMoega+"/ "+STR0548+cLocal+"/ "+STR0547+cCultiv+"/ "+STR0497+cCodPro+" "+STR0544, STR0545, "", "")
		endif
	endif
	if lRet // faz esta tratativa, pois todos os campos gatilham o LOCAL e se as variáveis de memória não são atualizadas na força, vai validar o local com informações inválidas
		if cCampo == 'NJJ_LOCAL'
			M->NJJ_LOCAL:= oStruNJJ:GetValue("NJJ_LOCAL")
		elseif cCampo == 'NJJ_MOEGA'
			M->NJJ_MOEGA:= oStruNJJ:GetValue("NJJ_MOEGA")
		elseif cCampo == 'NJJ_CODPRO'
			M->NJJ_CODPRO:= oStruNJJ:GetValue("NJJ_CODPRO")
		elseif cCampo == 'NJJ_CULTIV'
			M->NJJ_CULTIV:= oStruNJJ:GetValue("NJJ_CULTIV")		
		endif
	endif
Return lRet

/** {Protheus.doc} getLocal
Função para retornar o local conforme parâmetros
@param: 	Nil
@return:	NNR_CODIGO
@author: 	FSW
@since: 	11/2020
@Uso: 		OGA250 - Romaneio
*/
 Static Function getLocal(cCultiv,cMoega,cProduto, cLocalOri)
	Local cAliasQry := GetNextAlias()
	Local cLocal := M->NJJ_LOCAL
	Local bAchou := .F.
	Local cTime  := ''
	
	If !Empty(cMoega) .AND. !Empty(cProduto)	
		if !Empty(cLocalOri)
			BeginSql Alias cAliasQry
				SELECT NL6_LOCAL, NL6_DTINI, NL6_HRINI, NL6_DTFIM,NL6_HRFIM
				FROM %table:NL6%
				WHERE NL6_FILIAL = %xFilial:NL6%
				AND NL6_MOEGA  = %Exp:cMoega%
				AND NL6_CULTIV = %Exp:cCultiv%
				AND NL6_PRODUT = %Exp:cProduto%
				and NL6_LOCAL  = %Exp:cLocalOri%
				AND %notDel%
			EndSQL
		else
			BeginSql Alias cAliasQry
				SELECT NL6_LOCAL, NL6_DTINI, NL6_HRINI, NL6_DTFIM,NL6_HRFIM
				FROM %table:NL6%
			WHERE NL6_FILIAL = %xFilial:NL6%
				AND NL6_MOEGA  = %Exp:cMoega%
				AND NL6_CULTIV = %Exp:cCultiv%
				AND NL6_PRODUT = %Exp:cProduto%
				AND %notDel%
			EndSQL
		endif
		If (cAliasQry)->(!Eof())
			cTime := Time()
			cTime := SubStr(cTime,1,2)+SubStr(cTime,4,2)
			While ( (cAliasQry)->(!EOF()) .AND. !bAchou )
				if ( dToS(dDataBase) = (cAliasQry)->NL6_DTINI ) //se a data atual for igual a data de inicio , entao deve verificar a hora
					if ( cTime >= (cAliasQry)->NL6_HRINI )
						if vldDtFim((cAliasQry)->NL6_DTFIM, (cAliasQry)->NL6_HRFIM)
							cLocal := (cAliasQry)->NL6_LOCAL
							bAchou := .T.
						endif
					endif
				elseif ( dToS(dDataBase) > (cAliasQry)->NL6_DTINI )// se a data de atual for maior que a data de inicio, entao deve verificar o
					if vldDtFim((cAliasQry)->NL6_DTFIM, (cAliasQry)->NL6_HRFIM)
						cLocal := (cAliasQry)->NL6_LOCAL
						bAchou := .T.
					endif
				endIF
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		(cAliasQry)->(dbCloseArea())
		if !(bAchou) 
			cLocal := ''
		endif
	endif
Return cLocal

/** {Protheus.doc} vldDtFim
Verifica se a data está dentro da data final
@param: 	Nil
@return:	True / False
@author: 	FSW
@since: 	12/2020
@Uso: 		OGA250 - Romaneio
*/
static Function vldDtFim(dDtFim,horaFim)
	Local lRet:= .F.
	Local cTime := Time()
	cTime := SubStr(cTime,1,2)+SubStr(cTime,4,2)
	if !Empty(dDtFim)//Se a data e hora iniciais estiverem ok, verifica data final ( se existir )
		if ( dToS(dDataBase) < dDtFim )
			lRet:= .T.
		elseif ( dToS(dDataBase) = dDtFim )
			if !Empty(horaFim)
				if ( cTime <= horaFim )
					lRet:= .T.
				endif
			endif
		endif
	else
		lRet:= .T.
	endIf
return lRet

/** {Protheus.doc} fVldCodPro
Função centralizadora de valids para o campo NJJ_CODPRO
@param: 	Nil
@return:	True / False
@author: 	FSW
@since: 	12/2020
@Uso: 		OGA250 - Romaneio
*/
static function fVldCodPro(oField,oStruNJJ)
	Local lRet := .T.
	Local oModel := FwModelActive()
	Local oNJJ := oModel:GetModel( "NJJUNICO" )

	lRet:= fVldNJJ1( oField, 'NJJ_CODPRO' )
	if lRet
		If NJJ->(ColumnPos('NJJ_MOEGA')) > 0 
			lRet:= vldMoega(oNJJ,'NJJ_CODPRO')
		endIf
	endif
return lRet

/** {Protheus.doc} fVldLocal
Função centralizadora de valids para o campo NJJ_LOCAL
@param: 	Nil
@return:	True / False
@author: 	FSW
@since: 	12/2020
@Uso: 		OGA250 - Romaneio
*/
static function fVldLocal(oField,oStruNJJ)
	Local lRet := .T.
	Local oModel		:= FwModelActive()
	Local oNJJ			:= oModel:GetModel( "NJJUNICO" )

	lRet:= fVldNJJ1( oField, 'NJJ_LOCAL' )
	if lRet
		If NJJ->(ColumnPos('NJJ_MOEGA')) > 0 
			lRet:= vldMoega(oNJJ,'NJJ_LOCAL')
		endIf
	endif

return lRet

/** {Protheus.doc} fVldMoega
Função centralizadora de valids para o campo NJJ_MOEGA
@param: 	Nil
@return:	True / False
@author: 	FSW
@since: 	12/2020
@Uso: 		OGA250 - Romaneio
*/
static function fVldMoega(oStruNJJ)
	Local lRet:= .T.

	if !Empty(oStruNJJ:GetValue("NJJ_MOEGA"))
		lRet:= iif(Len(Alltrim(Posicione("NL5",1,fwxFilial("NL5")+oStruNJJ:GetValue("NJJ_MOEGA"),"NL5_MOEGA")))>0,.T.,.F.)
		// so pode validar moega cadastrada, se cultivar estiver preenchido, pois pode ocorrer de não achar um em branco, mas achar um preenchido
		if lRet .AND. !Empty(oStruNJJ:GetValue("NJJ_CULTIV"))
			lRet:= vldMoega(oStruNJJ,'NJJ_MOEGA' )	
		endif
	endif
return lRet

/** {Protheus.doc} fvldCulti
Função centralizadora de valids para o campo NJJ_CULTIV
@param: 	Nil
@return:	True / False
@author: 	FSW
@since: 	12/2020
@Uso: 		OGA250 - Romaneio
*/
static function fvldCulti(oStruNJJ)
	Local lRet:= .T.

	if !Empty(oStruNJJ:GetValue("NJJ_CULTIV"))
		lRet:= iif(Len(Alltrim(Posicione("NP4",1,fwxFilial("NP4")+oStruNJJ:GetValue("NJJ_CULTIV"),"NP4_CODIGO")))>0,.T.,.F.)
		if lRet
			lRet:= vldMoega(oStruNJJ,'NJJ_CULTIV' )
		endif
	endif

return lRet

/** {Protheus.doc} fTrgIncTL
Descrição:  Validação entidade E ENTIDADE DE ENTREGA
@param:     Nil
@author:    Agroindustria
@since:     2022
@Uso:       OGA250 
*/
Function fTrgIncTL()
	Local aAreaAtu  := GetArea()
	Local oModel    := FwModelActive()
	Local oNJJ 		:= oModel:GetModel("NJJUNICO")
	Local oNJM 		:= oModel:GetModel("NJMUNICO")
	Local cCodEnt   := oNJJ:GetValue("NJJ_CODENT")
	Local cLojEnt   := oNJJ:GetValue("NJJ_LOJENT")  
	Local nOperation:= oModel:GetOperation() 

	If !Empty(cCodEnt)
		//Acessa a tabela de entidades para a verificação
		DbSelectArea("NJ0") // Entidades
		NJ0->(dbSetOrder(1))
		If NJ0->(dbSeek(xFilial("NJ0")+cCodEnt+cLojEnt))
			//Verifica se esta ativo
			If NJ0->(NJ0_ATIVO) == '2' // 1=Ativo; 2=Inativo			
				Agrhelp(STR0021,STR0513,STR0514+NJ0->(NJ0_CODENT)+" "+NJ0->(NJ0_LOJENT))
				//#AJUDA #Cadastro de Entidade está INATIVO e não pode ser usado para esta função.#Verifique o cadastro da entidade:
				Return( .F. )
			EndIf	

			If !lExecAgoClas //NÃO É OPERACAO DE ALTERAR PESO/QUALIDADE APOS CONFIRMADO 				
			    // Se não for , saida venda ou saida devolucao 3, atualiza com entidade
				if  !(oNJJ:GetValue( "NJJ_TIPO" ) $ "4|6") 
					oNJJ:SetValue( "NJJ_ENTENT", oNJJ:GetValue( "NJJ_CODENT" ) )
					oNJJ:SetValue( "NJJ_ENTLOJ", oNJJ:GetValue( "NJJ_LOJENT" ) )					    
				//caso tenha apenas uma linha na comerc. ou ja tinha valor na entid entrega, alterar = entidade (DAGROOGD-12103) 				
				ELSEIF (nOperation == MODEL_OPERATION_INSERT .and. oNJM:Length() = 1 ) .OR. ;
				       (oNJM:Length() = 1 .and. !Empty( oNJJ:GetValue( "NJJ_ENTENT" ) ))
						oNJJ:SetValue( "NJJ_ENTENT", oNJJ:GetValue( "NJJ_CODENT" ) )
						oNJJ:SetValue( "NJJ_ENTLOJ", oNJJ:GetValue( "NJJ_LOJENT" ) )					
				ENDIF
			EndIf	
		EndIf
	EndIf
	RestArea(aAreaAtu)
Return(.T.)

/*/{Protheus.doc} fCarNJKClas
Carrega valores na grid de classificação MV_AGOCLAS=.T. via opção de menu
@type function
@version  
@author claudineia.reinert
@since 30/09/2022
@param oModel, object, modelo de dados
@param lAtuQtd, Logical, define se sempre atualiza quantidade NJK_BASDES
@return variant, return_description
/*/
Static function fCarNJKClas(oModel,lAtuQtd)
	Local oNJJ			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	Local oNJK			:= IIF(IsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJKUNICO" )) //Protecao para usar funcao via AGRA500
	Local nLinha		:= 0
	Local nX			:= 0
	Local cClassRom 	:= cDefClasDesc(oNJJ:GetValue("NJJ_TIPO"), oModel,,(oNJJ:GetValue("NJJ_TPFRET") = 'F'.And. oNJJ:GetValue("NJJ_TPFORM") == "1")) 
	Local oView			:= FwViewActive()
	Default lAtuQtd		:= .T.
	
	If lExecAgoClas
		nLinha := oNJK:GetLine()
		For nX := 1 to oNJK:Length()
			oNJK:GoLine( nX )
			If oNJK:GetValue("NJK_TPCLAS") != cClassRom 
				If lAtuQtd .or. (!lAtuQtd .and. oNJK:GetValue( "NJK_BASDES") <= 0)
					If oNJJ:GetValue("NJJ_TIPO") == "5" //compra
						oNJK:SetValue( "NJK_BASDES", ( oNJJ:GetValue( "NJJ_QTDFIS" ))  )
					Else
						oNJK:SetValue( "NJK_BASDES", ( oNJJ:GetValue( "NJJ_PESO3" ))  )
					EndIF
				EndIf
			EndIf
		Next nX 
		oNJK:GoLine( nLinha )
		IF ValType(oView) == 'O' .and. oView:IsActive()
			oView:Refresh("V250_NJK")
		EndIF
	
	EndIf

Return .T.
