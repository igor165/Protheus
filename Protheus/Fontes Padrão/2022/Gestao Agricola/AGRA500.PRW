#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "AGRA500.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static __oBrowseA500 	:= Nil
Static __lF10Exec    	:= .T.
Static __cTipoOp     	:= ""
Static __cCodPro     	:= ""
Static __aPerBal
Static __bTipoIni		:= ""
Static __nDecPeso		:= SuperGetMV("MV_OGDECPS",,0)	//--Definir Quantidade de Decimais p/ Campos de Peso no Romaneio
Static __cEtapa         := ""
Static __cOrdEtp        := "" 
Static __cCodRom        := ""
Static __cNumPsag		:= 3 //1=Primeira Pesagem, 2=Segunda Pesagem, 3=Verificar pesagem ou exibir tela para escolha
Static __lChkAgoC 		:= SuperGetMV("MV_AGOCLAS",.F.,.F.)   ///armazena o valor do parametro, se o parametro não existir considerar como False
Static __lnewNeg 		:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/*/{Protheus.doc} AGRA500
//Função principal do novo romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined

@type function
/*/
Function AGRA500()
	//Local oBrowse := Nil
	Local bKeyF12 	:= { || __aPerBal := AGRX003E( .T., "AGRA500001" ) }
	Local bTeclaF10 := SetKey( VK_F10, {||A500VLDPes(NJJ->NJJ_CODROM)} )
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita
	//Private aFardRom  := {}	
	Private _aItsEsq   	:= {}
	Private _oBrwClass
	Private aFardRom   	:= {}
	Private _lVincFard  := .F.
	Private _lAltIE		:= .F. //indica se houve alteração/inclusão na IE
	
	//Rotina somente deve ser acessada com o novo negocio ativo
	If !__lnewNeg
		Help( , , STR0048, , STR0153, 1, 0 )//"Para acessar a rotina Romaneio Unificado é necessario ativar o novo modelo de negócio"  
		Return
	EndIf

	If _cCLTTEMP == Nil
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP) //AGRA530TTO
	EndIf
	
	//Balança
	If __aPerBal == Nil
		__aPerBal := AGRX003E( .F., "AGRA500001" )
	EndIf	
	
	//-- Habilita o pergunte para escolher o tipo de operação
	Pergunte( "AGRA500001", .F. )
	
	If Empty(MV_PAR04) .OR. Empty(MV_PAR01) 
		IF Pergunte( "AGRA500001", .T. )
			If Empty(MV_PAR01)
				MsgAlert(STR0135) //"Nenhuma balança selecionada para pesagem."
				Return .F.
			Else
				__aPerBal := AGRX003E( .F., "AGRA500001" , MV_PAR01)
			EndIF
			
			If Empty(MV_PAR04)
				Help('' ,1,".AGRA50000004.", , ,1,0) //"Favor informar o Tipo de Operação."
				Return .F.
			EndIF
		EndIf
	EndIf
		
	//-- Variavel do tipo de operação
	__cTipoOp := MV_PAR04
	
	//-- Variavel do produto
	__cCodPro := MV_PAR02
			
	//-- Se estiver vazio não será aberta a tela de romaneios
	If Empty(__cTipoOp)
		Help('' ,1,".AGRA50000004.", , ,1,0) //"Favor informar o Tipo de Operação."
		Return .F.
	EndIF
	
	__bTipoIni  := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_TIPO")
		
	//---------------
	//Seta tecla F12
	//---------------
	SetKey( VK_F12, bKeyF12 )

	__oBrowseA500 := FWMBrowse():New()
	__oBrowseA500:SetAlias('NJJ')
	__oBrowseA500:SetDescription( STR0001 ) //"Romaneio"  
	
	//__oBrowseA500:SetFilterDefault( " NJJ_ORIGEM = 'AGRA500' " )
	//----- Status diferente de Agendamento == '6'
	__oBrowseA500:SetFilterDefault( " NJJ_STATUS <> '6' " )
	__oBrowseA500:SetOnlyFields({'NJJ_CODROM','NJJ_TIPO','NJJ_CODSAF','NJJ_CODPRO','NJJ_DESPRO','NJJ_UM1PRO','NJJ_LOCAL','NJJ_CODENT','NJJ_LOJENT','NJJ_FAZ','NJJ_TALHAO','NJJ_CODVAR'})	
		
	//__oBrowseA500:AddLegend( "NJJ_STATUS=='0'", "RED"		, X3CboxDesc( "NJJ_STATUS", "0" ) ) //"Pendente"
	//__oBrowseA500:AddLegend( "NJJ_STATUS=='3'", "GREEN" 	, X3CboxDesc( "NJJ_STATUS", "3" ) ) //"Encerrado"
	//__oBrowseA500:AddLegend( "NJJ_STATUS=='5'", "YELLOW" 	, X3CboxDesc( "NJJ_STATUS", "5" ) ) //"Pendente de aprovação"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='0'", "RED"			, X3CboxDesc( "NJJ_STATUS", "0" ) ) //"Pendente"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='1'", "YELLOW"		, X3CboxDesc( "NJJ_STATUS", "1" ) ) //"Completo"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='2'", "ORANGE"		, X3CboxDesc( "NJJ_STATUS", "2" ) ) //"Atualizado"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='3'", "GREEN"			, X3CboxDesc( "NJJ_STATUS", "3" ) ) //"Encerrado"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='4'", "BR_CANCEL"		, X3CboxDesc( "NJJ_STATUS", "4" ) ) //"Cancelado"	
	__oBrowseA500:AddLegend( "NJJ_STATUS=='5'", "BR_PINK"		, X3CboxDesc( "NJJ_STATUS", "5" ) ) //"Pendente de aprovação"
	__oBrowseA500:AddLegend( "NJJ_STATUS=='6'", "BR_BRANCO"		, X3CboxDesc( "NJJ_STATUS", "6" ) ) //"Previsto"
	
	//0 - "Não Classificado" (vermelho) | 1 - "Classificado" (verde)
	bColor02 := { || Iif(NJJ->NJJ_STSCLA=='0' .or. Empty(NJJ->NJJ_STSCLA),'BR_VERMELHO', Iif(NJJ->NJJ_STSCLA=='1','BR_VERDE', ''))}
	ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oMBrowse| A500Leg() }  OF __oBrowseA500	
	
	__oBrowseA500:aColumns[2]:cTitle := "St. Clas." //STR0136 //"St. Clas."	 
	__oBrowseA500:aColumns[2]:nalign := 1
		
	__oBrowseA500:SetMenuDef('AGRA500')
		
	__oBrowseA500:Activate()

	SetKey(VK_F12,Nil)	
	SetKey( VK_F10, bTeclaF10 )
	
	__oBrowseA500:DeActivate()
Return 

/*/{Protheus.doc} MenuDef
//Chamadas padrões de menu da rotina de novo romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002    Action 'A500Vis' 	 OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0003    Action 'A500Inc' 	 OPERATION 3  ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0004    Action 'A500Alt' 	 OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0132 	Action "OGA250ATUC"  OPERATION MODEL_OPERATION_UPDATE   ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0009    Action 'A500ConfRom(NJJ->NJJ_CODROM, .T.)'  OPERATION 10 ACCESS 0 //Confirmação
	ADD OPTION aRotina Title STR0097    Action 'AGRCONHECIM("NJJ")'          	    OPERATION 4  ACCESS 0 //"Conhecimento",
	ADD OPTION aRotina Title STR0043    Action 'SPEDNFE'     OPERATION 4  ACCESS 0 //"Sped.NFe"
	ADD OPTION aRotina Title STR0044    Action 'OGA250HIS'   OPERATION 7  ACCESS 0 //"Histórico"
	ADD OPTION aRotina Title STR0045    Action 'AGOCLAS'     OPERATION 4  ACCESS 0 //"atualizar quantidade fisica e classificação
	ADD OPTION aRotina Title STR0046    Action 'OGA250ANA'   OPERATION 4  ACCESS 0 //"Insp.Analise"
	ADD OPTION aRotina Title STR0082    Action 'A500Aprov(NJJ->NJJ_CODROM, .T.)'    OPERATION 11  ACCESS 0 //"Aprovar Romaneio"
	ADD OPTION aRotina Title STR0125    Action 'VIEWDEF.AGRA500' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina Title STR0152    Action 'OGR250' OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina Title STR0134    Action 'OGA250REA'   OPERATION 4  ACCESS 0 //"Reabrir"
	ADD OPTION aRotina Title STR0141    Action "OGA250F(NJJ->NJJ_CODROM, NJJ->NJJ_CODCTR)"   OPERATION 4  ACCESS 0 //"Informar Docto Referência"

Return aRotina

/*/{Protheus.doc} ModelDef
//Declaração da função de modelo do novo romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel  	:= Nil
	Local oStrNJJ 	:= FwFormStruct( 1, "NJJ" )		
	Local oStrNJM 	:= FWFormStruct( 1, "NJM" )	
	Local oStruNJK  := FWFormStruct( 1, "NJK" )
	Local oStruDX0  := FWFormStruct( 1, "DX0" )
	Local oStruN9E  := FWFormStruct( 1, "N9E" )
	Local oStruN9D  := FWFormStruct( 1, "N9D" )
	
    Local bTipoOp   := 'MV_PAR04'
    Local bCodPro   := 'MV_PAR02'	  
    Local bDesPro	:= 'AGRA500INP("NJJ_DESPRO")'
    Local bUM1Pro	:= 'AGRA500INP("NJJ_UM1PRO")'
    Local bCodPro2	:= 'AGRA500INP("NJM_CODPRO")'
    Local bDesPro2	:= 'AGRA500INP("NJM_DESPRO")'
    Local bUM1Pro2	:= 'AGRA500INP("NJM_UM1PRO")'    
	Local bPlacaVld	:= 'A500VldPlaca()'			
	Local bCgcVld	:= 'A500VldCgc()'
	Local bSafraVld	:= 'A500VldSafra()'	
	Local bPrtorVld	:= 'A500VldPrtor()'	
	Local bPrdtVld	:= 'A500VldPrdt()'	
	Local bLojaVld	:= 'A500VldLoja()'					
	Local bDescVld	:= 'A500VldDesc()'
	Local bNFVld	:= 'A500VldNf()'	
    Local bFazVld	:= 'A500VldFaz()'				
    Local bTalVld	:= 'A500VldTal()'
	Local bTipoVld	:= 'A500VldTipo()'	
	Local bVarVld   := 'A500VldVar()'
	Local bLocVld   := 'A500VldLoc()'	
	Local bNFPSVld	:= 'A500VldSNfp()'	
	Local bNFPNVld	:= 'A500VldNNfp()'	
	Local bTipoIniJ := 'AGRA500INP("NJJ_TIPO")'
	Local bTipoIniM := 'AGRA500INP("NJM_TIPO")'
	Local bItRomIni	:= 'A500ItRom()'
	Local bTesVld	:= 'A500VldTes()'
	Local bCodineVld := 'A500GTN9A()'
	Local bGatTbl	:= 'A500GTTB()'
	Local bTranVld	:= 'A500VDTRAN()'
	
	Local bLinePre := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRX500FPR( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }

	oStrNJJ:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
	
	oStrNJJ:SetProperty( "NJJ_TIPENT" , MODEL_FIELD_INIT 	, { | | "0" } ) // 0=Físico
	oStrNJJ:SetProperty( "NJJ_STSCLA" , MODEL_FIELD_INIT 	, { | | "0" })  // 1=Classificado
	
	//---------------------------------------------------
	// Inicializa valor NJJ_TIPO, 
	//---------------------------------------------------			
    oStrNJJ:SetProperty( 'NJJ_TIPO',   MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, bTipoIniJ))
    
    oStrNJJ:SetProperty( 'NJJ_CODPRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bCodPro))
    oStrNJJ:SetProperty( 'NJJ_DESPRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bDesPro))
    oStrNJJ:SetProperty( 'NJJ_UM1PRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bUM1Pro))
    oStrNJJ:SetProperty( 'NJJ_TOETAP', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bTipoOp))  	

    oStrNJM:SetProperty( 'NJM_CODPRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bCodPro2))
    oStrNJM:SetProperty( 'NJM_DESPRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bDesPro2))
    oStrNJM:SetProperty( 'NJM_UM1PRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bUM1Pro2))

	oStrNJM:SetProperty( 'NJM_TIPO',   MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, bTipoIniM))
	oStrNJM:SetProperty( 'NJM_ITEROM', MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, bItRomIni))
	
	oStrNJJ:SetProperty( 'NJJ_TABELA', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, IIF( EMPTY(MV_PAR02),,bGatTbl) ))
					
	//-------------------------------------------------
	// Manipula a estrutura para a etapa de transporte
	//-------------------------------------------------			
	oStrNJJ:SetProperty( 'NJJ_PLACA' , MODEL_FIELD_WHEN  	, {||.T.})	
	oStrNJJ:SetProperty( 'NJJ_PLACA' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bPlacaVld))				
	oStrNJJ:SetProperty( 'NJJ_CGC'   , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bCgcVld))
	oStrNJJ:SetProperty( 'NJJ_CODTRA', MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTranVld))
	
	oStrNJJ:SetProperty( 'NJJ_DSTIPO', MODEL_FIELD_TAMANHO 	, TamSX3('X5_DESCRI')[1])
	
	//-------------------------------------
	// Valid para NJJ_TIPO, NJJ_CODSAF
	//-------------------------------------
	oStrNJJ:SetProperty( 'NJJ_TIPO'   , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTipoVld))
	
	//Substituir valid de dicionário
	oStrNJJ:SetProperty( 'NJJ_CODSAF' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bSafraVld))
	oStrNJJ:SetProperty( 'NJJ_CODVAR' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bVarVld))
	oStrNJJ:SetProperty( 'NJJ_CODENT' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bPrtorVld))
	oStrNJJ:SetProperty( 'NJJ_LOJENT' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bLojaVld))
	oStrNJJ:SetProperty( 'NJJ_CODPRO' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bPrdtVld))
	oStrNJJ:SetProperty( 'NJJ_PSDESC' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bDescVld))
	oStrNJJ:SetProperty( 'NJJ_FAZ'    , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bFazVld))
	oStrNJJ:SetProperty( 'NJJ_TALHAO' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTalVld))
	oStrNJJ:SetProperty( 'NJJ_LOCAL'  , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bLocVld))
	oStrNJJ:SetProperty( 'NJJ_NFPSER' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bNFPSVld))
	oStrNJJ:SetProperty( 'NJJ_NFPNUM' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bNFPNVld))
	oStrNJJ:SetProperty( 'NJJ_TES'    , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTesVld))
	
	oStrNJJ:SetProperty( 'NJJ_CODENT' , MODEL_FIELD_TITULO	, STR0033 ) //Produtor
																  
	//---------------------------------------------------
	// Manipula a estrutura para a etapa de dados fiscais
	//---------------------------------------------------				
	
	oStrNJJ:SetProperty( "NJJ_DOCNUM" , MODEL_FIELD_WHEN	, 	{|| .T.})
	oStrNJJ:SetProperty( "NJJ_DOCSER" , MODEL_FIELD_WHEN, 	{|| .T.})
	oStrNJJ:SetProperty( "NJJ_DOCESP" , MODEL_FIELD_WHEN, 	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( "NJJ_DOCEMI" , MODEL_FIELD_WHEN, 	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( "NJJ_VLRUNI" , MODEL_FIELD_WHEN, 	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( "NJJ_VLRTOT" , MODEL_FIELD_WHEN, 	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( "NJJ_QTDFIS" , MODEL_FIELD_WHEN, 	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( 'NJJ_EST'	  , MODEL_FIELD_WHEN,  	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( 'NJJ_DIFFIS' , MODEL_FIELD_WHEN,  	{|| AGRA500WNF()})
	oStrNJJ:SetProperty( 'NJJ_PESO3'  , MODEL_FIELD_WHEN, 	{|| AGRA500WP3("NJJ_PESO3")})

	oStrNJJ:SetProperty( 'NJJ_DATCHE' 	, MODEL_FIELD_WHEN, 	{|| AGRA500WP3("NJJ_DATCHE")})
	oStrNJJ:SetProperty( 'NJJ_HORCHE' 	, MODEL_FIELD_WHEN, 	{|| AGRA500WP3("NJJ_HORCHE")})
	
	oStrNJJ:SetProperty( 'NJJ_LIBQLD' 	, MODEL_FIELD_WHEN, 	{|| .F.})
	oStrNJJ:SetProperty( 'NJJ_QPAREC' 	, MODEL_FIELD_WHEN, 	{|| .F.})
	oStrNJJ:SetProperty( 'NJJ_QUSUAR' 	, MODEL_FIELD_WHEN, 	{|| .F.})

	oStrNJJ:SetProperty( 'NJJ_TABELA' , MODEL_FIELD_WHEN, 	{|| AGRA500VLT()})
	oStrNJJ:SetProperty( 'NJJ_CODPRO' , MODEL_FIELD_WHEN, 	{|| AGRA500WPr()})
	
	oStrNJM:SetProperty( "NJM_CODENT" , MODEL_FIELD_OBRIGAT, .F.)
	oStrNJM:SetProperty( "NJM_CODROM" , MODEL_FIELD_OBRIGAT, .F.)
	oStrNJM:SetProperty( "NJM_LOJENT" , MODEL_FIELD_OBRIGAT, .F.)


	oStruDX0:SetProperty( "DX0_FARDAO" ,MODEL_FIELD_OBRIGAT, .F.) //Relacionamento ocorre em background
	
	oStrNJJ:SetProperty( 'NJJ_DOCNUM' , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID, bNFVld))
	oStrNJJ:SetProperty( 'NJJ_DOCSER' , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID, bNFVld))	                                                         

    oStrNJJ:SetProperty( "NJJ_TPFORM" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
    oStrNJJ:SetProperty( "NJJ_QTDFIS" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
	
	oStrNJJ:SetProperty( "NJJ_VLRUNI" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
	oStrNJJ:SetProperty( "NJJ_VLRTOT" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
	oStrNJJ:SetProperty( "NJJ_FRETE"  , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
	oStrNJJ:SetProperty( "NJJ_SEGURO" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )
	
	//Ao atualizar o valor do novo campo NJJ_PESO3 o volor deve ser atualizado no campo NJM_QTFCO  - DAGROGAP-446
	oStrNJJ:SetProperty( "NJJ_PESO3"  , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )

	oStrNJJ:SetProperty( "NJJ_PSLIQU" , MODEL_FIELD_VALID , {| oField | A500VLDVR( oField ) } )

	
	oStrNJM:SetProperty( "NJM_FRETE"  , MODEL_FIELD_VALID , {| oField | fVldFrete( oField ) } )
	oStrNJM:SetProperty( "NJM_LOTCTL" , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"A500Lot()") )
	oStrNJM:SetProperty( "NJM_CODSAF" , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"ExistCpo('NJU', M->NJM_CODSAF) .And. A500ACTR()") )
	oStrNJM:SetProperty( "NJM_CODCTR" , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"OGA330VLD(FwFldGet('NJM_CODCTR'),FwFldGet('NJJ_TIPO')) .And. A500VCTR()") )
	oStrNJM:SetProperty( "NJM_TES"    , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"VldTESNJM()") )	                                                         
	
	///=== Define inicializadores padrões ===///
	oStrNJM:SetProperty( "NJM_PERDIV" , MODEL_FIELD_INIT  , {| oField | fIniPerDiv( oField ) } )

	//-- Para Tratar Frete , Seguro,Despesa --//
	oStrNJM:SetProperty( "NJM_FRETE"  , MODEL_FIELD_INIT  , {|| FWFLDGET("NJJ_FRETE" ) } )
	oStrNJM:SetProperty( "NJM_SEGURO" , MODEL_FIELD_INIT  , {|| FWFLDGET("NJJ_SEGURO") } )
	oStrNJM:SetProperty( "NJM_DESPES" , MODEL_FIELD_INIT  , {|| FWFLDGET("NJJ_DESPES") } )		
	oStrNJM:SetProperty( "NJM_MSGNFS" , MODEL_FIELD_INIT  , {|| FWFLDGET("NJJ_MSGNFS") } )
	
	//Adicionando gatilhos
	oStrNJJ:AddTrigger( "NJJ_TIPO"    ,"NJJ_DSTIPO"       , {|| .T. }, {|| Posicione("SX5",1,FWxFilial("SX5")+'K5'+M->NJJ_TIPO,"X5_DESCRI") } )
	oStrNJJ:AddTrigger( "NJJ_TOETAP"  ,"NJJ_DESTPO"       , {|| .T. }, {|| Posicione("N92",1,FWxFilial("N92")+__cTipoOp,"N92_DESCTO")  		} )
	oStrNJJ:AddTrigger( "NJJ_FAZ"     ,"NJJ_NMFAZ"        , {|| .T. }, {|| Posicione("NN2",3,FWxFilial("NN2")+M->(NJJ_CODENT+NJJ_LOJENT+NJJ_FAZ),"NN2_NOME")   	} )
	oStrNJJ:AddTrigger( "NJJ_TALHAO"  ,"NJJ_DESTAL"       , {|| .T. }, {|| Posicione("NN3",1,FWxFilial("NN3")+M->(NJJ_CODSAF+NJJ_FAZ+NJJ_TALHAO),"NN3_DESCRI") 	} )
	oStrNJJ:AddTrigger( "NJJ_CODVAR"  ,"NJJ_DESVAR"       , {|| .T. }, {|| Posicione("NNV",1,FWxFilial("NNV")+M->(NJJ_CODPRO+NJJ_CODVAR),"NNV_DESCRI")         	} )
	
	oStrNJJ:AddTrigger( "NJJ_CODENT"  , "NJJ_ENTENT"	  , {|| .T. }, {|x| A500GTCEN(x) } )
	oStrNJJ:AddTrigger( "NJJ_LOJENT"  , "NJJ_ENTLOJ"	  , {|| .T. }, {|x| A500GTLEN(x) } )

	oStrNJJ:AddTrigger( "NJJ_TIPO"	  , "NJJ_PSLIQU"	  , {|| .T. }, {|x| A500GATPL(x) } )
	oStrNJJ:AddTrigger( "NJJ_TABELA"  , "NJJ_PSLIQU"	  , {|| .T. }, {|x| A500GATPL(x) } )
	oStrNJJ:AddTrigger( "NJJ_PSSUBT"  , "NJJ_PSLIQU"	  , {|| .T. }, {|x| A500GATPL(x) } )
	
	oStrNJJ:AddTrigger( "NJJ_STSCLA"  , "NJJ_STATUS"	  , {|| .T. }, {|x| A500GATST(x) } )
	oStrNJJ:AddTrigger( "NJJ_STSPES"  , "NJJ_STATUS"	  , {|| .T. }, {|x| A500GATST(x) } )
	oStrNJJ:AddTrigger( "NJJ_CODPRO"  , "NJJ_TABELA"      , {|| .T. }, {|x| A500GTTB(x) })

	//Os 3 campos estão relacionados entre si
	oStrNJJ:AddTrigger( "NJJ_CGC"     , "NJJ_NOMMOT"       , {|| .T. }, {|| A500GTNMMT()} )
	oStrNJJ:AddTrigger( "NJJ_CGC"     , "NJJ_CODMOT"       , {|| .T. }, {|| A500GTCODMT()} )
	oStrNJJ:AddTrigger( "NJJ_CODMOT"  , "NJJ_CGC"		   , {|| .T. }, {|| A500GTCGC()} )
	
	//-------------------------------------------------------
	// Trigger para Autorizacao que limpa campos dependentes-
	//-------------------------------------------------------
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_CODINE" ,{|| .T. }, {|| Space(TamSX3("N9E_CODINE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_ITEMAC" ,{|| .T. }, {|| Space(TamSX3("N9E_ITEMAC")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_DESINE" ,{|| .T. }, {|| Space(TamSX3("N9E_DESINE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_FILIE"  ,{|| .T. }, {|| Space(TamSX3("N9E_FILIE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_CODCTR" ,{|| .T. }, {|| Space(TamSX3("N9E_CODCTR")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_ITEM"   ,{|| .T. }, {|| Space(TamSX3("N9E_ITEM")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_SEQPRI" ,{|| .T. }, {|| Space(TamSX3("N9E_SEQPRI")[1])})
	
	oStrNJJ:AddTrigger(  "N9E_CODAUT","NJJ_LOTCTL" ,{|| .T. }, {|| Space(TamSX3("NJJ_LOTCTL")[1])})


	/** Valid provisorio, pois este campo tem o seguinte valid no dicionario OGA250QIE
	*	Para isolar o fonte copiei a logica. Logo o fonte OGA250B sera unificado com AGRX500F
	**/
	oStruN9E:SetProperty( "N9E_CODINE" , MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID, bCodineVld) )
	
	//---------------------------------------------------------------
	// Trigger que preenche os campos da N8O para a IE selecionada---
	//---------------------------------------------------------------
	//oStruN9E:AddTrigger( "N9E_CODINE","N9E_FILIE" , {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_FILORI"),Space(TamSX3("N9E_FILIE")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_FILIE" , {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),FwXFilial("N7Q"),Space(TamSX3("N9E_FILIE")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_ITEMAC", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),N8O->N8O_ITEM,Space(TamSX3("N9E_ITEMAC")[1]) )  } )
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_CODCTR", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_CODCTR"),Space(TamSX3("N9E_CODCTR")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_ITEM"  , {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDENTR"),Space(TamSX3("N9E_ITEM")  [1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_SEQPRI", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDREGR"),Space(TamSX3("N9E_SEQPRI")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_QTDAGD", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8N",1,FwXfilial("N8N") + FwFldGet("N9E_CODAUT"), "N8N_QTDAGD"),0)})	

	//---------------------------------------------------------------
	
	oStruN9E:SetProperty( "N9E_ORIGEM" , MODEL_FIELD_INIT 	, { | | "5" } ) // Manual
	
		
	oModel := MpFormModel():New( "AGRA500", /*bPre*/, {| oModel | PosModelo( oModel ) }, {|oModel| GrvModelo(oModel)} , /*{ |x| fAftOKButton() }*/)
	oModel:SetDescription( STR0010 ) //"Modelo de Dados do Romaneio"
		
	//--------------------------------
	// Adiciona a estrutura de dados
	//--------------------------------
	oModel:AddFields( 'AGRA500_NJJ', , oStrNJJ )
	
	oModel:GetModel( 'AGRA500_NJJ' ):SetDescription( STR0011 )  //"Dados do Romaneio"
	
	//--------------------------------
	// Adiciona a estrutura classificacao
	//--------------------------------
	oModel:AddGrid( "NJKUNICO", "AGRA500_NJJ", oStruNJK, {|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|sfPreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)},/*lPos*/,/*bPre*/,/*bPos*/, /*bLoad*/)

	// Remove campos NJK
	oStruNJK:RemoveField( "NJK_CODROM" )
	oStruNJK:RemoveField( "NJK_CLASSP" )

	oModel:GetModel( "NJKUNICO" ):SetNoDelete( .t. )
	oModel:GetModel( "NJKUNICO" ):SetNoInsert( .t. )

	//--------------------------------------
	// Adiciona a estrutura comercializacao
	//--------------------------------------	
	oModel:AddGrid( "AGRA500_NJM", "AGRA500_NJJ", oStrNJM, /*lPre*/, /*lPos*/, /*bPre*/, /*bPos*/, /*bLoad*/)
	
	//-- Gatilho das quantidades de peso para a linha NJM
	oStrNJM:AddTrigger( "NJM_PERDIV", "NJM_QTDFCO", { || .T. }, { | x | A500PerDiv( x ) } )
	oStrNJM:AddTrigger( "NJM_QTDFCO", "NJM_PERDIV", { || .T. }, { | x | A500QtdFco( x ) } )
	
	//------------------------------------
	// Relacionamentos e obrigatoriedades
	//------------------------------------		
	oModel:GetModel( "NJKUNICO"):SetOptional( .T. )
	oModel:SetRelation( "NJKUNICO", { { "NJK_FILIAL", "fwxFilial( 'NJK' )" }, { "NJK_CODROM", "NJJ_CODROM" } }, NJK->( IndexKey( 1 ) ) )
	
	oModel:GetModel( "AGRA500_NJM" ):SetOptional( .t. )			
	
	oModel:SetDescription( STR0010 ) //"Modelo de Dados do Romaneio"
	oModel:SetRelation( "AGRA500_NJM", { { "NJM_FILIAL", "fwxFilial( 'NJM' )" }, { "NJM_CODROM", "NJJ_CODROM" } }, NJM->( IndexKey( 1 ) ) )
	
	oModel:GetModel( "AGRA500_NJM" ):SetDescription( STR0017 ) //"Itens de Comercialização"
	
	//--------------------------------------------------------------
	//Campos de peso na DX0 para fazer Rateio e integrar com o PIMS
	//--------------------------------------------------------------
	oStruDX0:AddField(/*cTitulo*/STR0119,/*"Peso Bruto"*/;
	/*cTooltip*/ STR0120,/*"Peso Bruto da Pesagem"*/;
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
	
	oStruDX0:AddField(/*cTitulo*/STR0121,/*Tara*/;
	/*cTooltip*/ STR0122,/*"Tara da Pesagem"*/;
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
	
	oStruDX0:AddField(/*cTitulo*/STR0123,/*"Descontos"*/;
	/*cTooltip*/ STR0124,/*"Total de Descontos"*/;
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
	oModel:AddGrid( "AGRA500_DX0", "AGRA500_NJJ", oStruDX0,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA500_DX0" ):SetDescription(STR0070) //"Fardos vinculados"	
	oModel:GetModel( "AGRA500_DX0" ):SetOptional( .t. )

	oModel:SetRelation( "AGRA500_DX0", { { "DX0_FILIAL", "fwxFilial( 'DX0' )" }, { "DX0_NRROM", "NJJ_CODROM" }  }, DX0->( IndexKey( 1 ) ) )

	//-------------------------------------
	// Grid de Integracao Romaneio
	//-------------------------------------
	oModel:AddGrid( "AGRA500_N9E", "AGRA500_NJJ", oStruN9E, bLinePre )	
	oModel:GetModel( "AGRA500_N9E" ):SetDescription(STR0099) //"Integracao Romaneio"	
	oModel:GetModel( "AGRA500_N9E" ):SetOptional( .t. )
	oModel:GetModel( "AGRA500_N9E" ):SetUniqueLine( { "N9E_FILIAL","N9E_CODAUT","N9E_CODINE","N9E_ITEMAC" } )
	oModel:SetRelation( "AGRA500_N9E", { { "N9E_FILIAL", "xFilial( 'N9E' )" }, { "N9E_CODROM", "NJJ_CODROM" } }, N9E->( IndexKey( 1 ) ) )

	//-------------------------------------
	// Rastro de Fardinhos
	//-------------------------------------	
	oModel:AddGrid( "AGRA500_N9D", "AGRA500_NJJ", oStruN9D,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA500_N9D" ):SetDescription( "Fardos do Romaneio")	//Fardos do Romaneio
	oModel:GetModel( "AGRA500_N9D" ):SetOptional( .t. )

	oModel:SetRelation( "AGRA500_N9D", { { "N9D_FILIAL", "fwxFilial( 'N9D' )" }, { "N9D_CODROM", "NJJ_CODROM" } /*,  { "N9D_ITEMAC", "N8O_ITEM" }*/ }, N9D->( IndexKey( 1 ) ) )//Preciso que nao filtre por item

	oModel:SetActivate(   { | oModel | fIniModelo(oModel, oModel:GetOperation()) } )

Return oModel


/*/{Protheus.doc} fIniModelo
//Para incluir algumas funcionalidades no modelo
@author carlos.augusto
@since 24/08/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function fIniModelo(oModel, nOperation)
	Local oView			:= FwViewActive()
	Local oNJJ 			:= oModel:GetModel( "AGRA500_NJJ" )
	Local lVTab			:= M->NJJ_TIPO $ '1|A|B'
	Local lGraos		:= Posicione("SB5",1,fwxFilial("SB5")+M->NJJ_CODPRO,"B5_TPCOMMO") != '2'

	/*Fução para validar parecer da qualidade. Especificamente, se o usuario pode digitar o resultado*/
	OGA250GotF(oModel,oView)
	
	/*Função para preenchimento da GRID de classificação caso */
	if lVTab .AND. FWISINCALLSTACK('A500INC') .AND. (!Empty(M->NJJ_CODPRO) .AND. lGraos)
		OGA250VTAB()
	endIF

	If oModel:Activate() .AND. (nOperation == 3 .OR. nOperation == 4)
		oNJJ:SetValue("NJJ_DTULAL", DDATABASE)
		oNJJ:SetValue("NJJ_HRULAL", Time())
	EndIf

Return .T.

/*/{Protheus.doc} A500Inc
//Função de Inclusão - View conforme o tipo de operação selecionado
-- Para função de inclusão o Tipo de Operação é o que esta no pergunte.
@author 	ana.olegini
@since 		27/12/2017
@version 	P12
@return 	FWExecView, Executa a view conforme o tipo de operação selecionado
/*/
Function A500Inc()
	Local oView 	:= FwLoadView('AGRA500')
	Local cAlias   	:= GetNextAlias()
	Local cQuery	:= ""
	
	_lAltIE := .F.
	
	//--Desativa a View
	oView:Deactivate()
	
	//-- Se estiver vazio não será aberta a tela de romaneios
	If Empty(MV_PAR04)
		Help('' ,1,".AGRA50000004.", , ,1,0) //"Favor informar o Tipo de Operação."
		Return .F.
	EndIF
	
	If Empty(MV_PAR02)

		cQuery := " SELECT 1 "
		cQuery +=   " FROM "+RetSqlName("N95")+" N95 					"
		cQuery +=  " WHERE N95.N95_FILIAL 	= '"+ FWxFilial("N95") +"'	"
		cQuery +=    " AND N95.N95_CODTO    = '"+ MV_PAR04 + "'			"
		cQuery +=    " AND N95.N95_CAMPO	= 'NJJ_CODPRO' 				"
		cQuery +=    " AND N95.D_E_L_E_T_   = ''  						"
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAlias),.F.,.T.)		
		dbSelectArea(cAlias)
		
		(cAlias)->( dbGoTop() )		
		
		If (cAlias)->(Eof())
			Help('' ,1,".AGRA50000014.", , ,1,0) //"Favor informar o Produto."
			Return .F.
		endIf
	endIf
		
Return FWExecView( STR0003,"AGRA500",MODEL_OPERATION_INSERT,,{|| .T.})		//"Incluir"


/*/{Protheus.doc} A500Alt
//Função de Alteração - View conforme o tipo de operação selecionado
-- Para função de alteração o Tipo de Operação é o que esta gravado no campo NJJ_TOETAP
@author 	ana.olegini
@since 		27/12/2017
@version 	P12
@return 	FWExecView, Executa a view conforme o tipo de operação selecionado
/*/
Function A500Alt()
	Local oView := FwLoadView('AGRA500')
	Local lRet  := .T.
	
	_lAltIE := .F.
	
	//--Desativa a View
	oView:Deactivate()
	
	If NJJ->NJJ_STATUS $ '0|1'	//"0=Pendente" ou "1=Completo"
		lRet := FWExecView( STR0004,"AGRA500",MODEL_OPERATION_UPDATE,,{|| .T.})		//"Alterar"
	else
		Help('' ,1,".AGRA50000001.", , ,1,0) /* Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'. */
		//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
		//Somente Romaneios com status - Pendende - Completo - podem ser alterados.
		lRet := .F.	
	endIf
	
Return lRet

/*/{Protheus.doc} A500Vis
//Função de Visualização - View conforme o tipo de operação selecionado
-- Para função de visualização o Tipo de Operação é o que esta gravado no campo NJJ_TOETAP
@author 	ana.olegini
@since 		27/12/2017
@version 	P12
@return 	FWExecView, Executa a view conforme o tipo de operação selecionado
/*/
Function A500Vis()
	Local oView := FwLoadView('AGRA500')
	Local lRet  := .T.
	//--Desativa a View
	oView:Deactivate()
	
	lRet := FWExecView( STR0002,"AGRA500",MODEL_OPERATION_VIEW,,{|| .T.})		//"Visualizar"
	
	fAftOKButton()
Return lRet

/*/{Protheus.doc} ViewDef
//Função de criação da view padrão da rotina de novo romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined
@type function
/*/
Static Function ViewDef()
	Local oView   	:= FwFormView():New()
	Local oModel  	:= FWLoadModel('AGRA500')
	Local oStrNJJ 	:= Nil		
	Local oStrNJM 	:= Nil
	Local oStrN9E 	:= Nil
	Local oStruNJK 	:= Nil 	 							  
	Local aEtapas 	:= {}
	Local nX 	  	:= 0
	Local nY 	  	:= 0
	Local nLin 	 	:= 0
	Local cCampos 	:= ""
	Local nCount  	:= 1
	Local oVal
	Local lObrigat 	:= .F.
	Local cMdExec 	:= ""
	Local cCdGFE	:= ""
	Local lVincDXL 	:= .F. //Acao Relacionada de Vinc Fardoes
	Local lAtQtdDes := .F.
	Local lAgoClas	:= FwIsInCallStack("AGOCLAS")
	
	If IsInCallStack('AGRA500')
		If .NOT. Inclui
			//-- Busca etapa gravada
		    IF .NOT.EMPTY(NJJ->NJJ_TOETAP)
		    	__cTipoOp := NJJ->NJJ_TOETAP
		    	__bTipoIni  := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_TIPO")
		    EndIf
	    Else //-- Utiliza etapa do parametro 
	    	Pergunte( "AGRA500001", .F. )
	    	__cTipoOp := MV_PAR04
	    	__bTipoIni  := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_TIPO")
	    EndIf
	    cMdExec := "2"   //Modo Exec. (2=Unico)
	Else
	    //-- Realiza busca Modo Exec. (1=Etapas; 2=Unico)
	    if Select ('N92') = 0
	    	N92->(dbSelectArea("N92"))
	    endIf
		N92->(dbSetOrder(1))
		If N92->(DBSeek(FWxFilial("N92")+__cTipoOp)) //FILIAL + CODIGO OPERACAO
		   cMdExec     := N92->N92_MDEXEC
		   __bTipoIni  := N92->N92_TIPO
		EndIf 
	    N92->(dbCloseArea())
	    
	    //if IsInCallStack('GFEA523')
	    if IsInCallStack('AX500PRFUN')
	    	cCdGFE := GX4->GX4_CDPTCT
	    endIf
	EndIf    

	If IsInCallStack('AGRA500')
		//-- Realiza busca na tabela de Etapas 
		dbSelectArea("N93")
		dbSetOrder(1)
		If dbSeek(FWxFilial("N93") + __cTipoOp)
			nLin := 0	//-- controla sequencia 
			While N93->(!Eof()) .AND. N93->N93_CODTO == __cTipoOp
				If N93->N93_OK == .T.
				
					lAtQtdDes := .F.
					If lAgoClas //Se for acao de menu Atu Qtd Destino, mostrar apenas classificacao e pesagem.
						dbSelectArea('N94')
						N94->(dbSetOrder(1))
						N94->(msSeek(FWxFilial("N94")+__cTipoOp + N93->N93_CODIGO))
						While !N94->(EOF())  .AND. N94->N94_FILIAL == FWxFilial("N94") .And. N94->N94_CODTO == __cTipoOp .And. N94->N94_CODETP == N93->N93_CODIGO
							If N94->N94_ANAQUA .Or. N94->N94_QTCPES
								lAtQtdDes := .T.
								exit
							EndIf   
							N94->(dbSkip())
						End   
						N94->(dbCloseArea())
					Else
						lAtQtdDes := .T.
					EndIf
				
					If lAtQtdDes
						nLin ++
						AaDd(aEtapas, {N93->N93_CODIGO , N93->N93_DESETP, N93->N93_ORDEM, })
						//-- Realiza busca na tabela de Campos da Etapa	
						dbSelectArea("N95")
						dbSetOrder(2)
						If msSeek(FWxFilial("N95")+__cTipoOp+N93->N93_CODIGO)
							aEtapas[nLin][4] := {}
							While N95->(!Eof()) .AND. N95->N95_CODTO == __cTipoOp	.AND. N95->N95_CODETP == N93->N93_CODIGO 
								
								aadd(aEtapas[nLin][4], {N95->N95_CAMPO, N95->N95_OBRIGA}) 
								
								N95->(dbSkip())
							EndDo
						EndIF
						N95->(dbCloseArea())
					EndIf
				EndIf 
				N93->(dbSkip())
			EndDo
		EndIF
		N93->(dbCloseArea())
	else
		//-- Realiza busca na tabela de Etapas 
		dbSelectArea("N93")
		dbSetOrder(2)
		If dbSeek(FWxFilial("N93") + __cTipoOp + cCdGFE)
			nLin := 0	//-- controla sequencia 
			While N93->(!Eof()) .AND. N93->N93_CODTO == __cTipoOp  .AND. N93->N93_CDPTCT = cCdGFE
				If N93->N93_OK == .T.
				
					lAtQtdDes := .F.
					If lAgoClas //Se for acao de menu Atu Qtd Destino, mostrar apenas classificacao e pesagem.
						dbSelectArea('N94')
						N94->(dbSetOrder(1))
						N94->(msSeek(FWxFilial("N94")+__cTipoOp + N93->N93_CODIGO))
						While !N94->(EOF())  .AND. N94->N94_FILIAL == FWxFilial("N94") .And. N94->N94_CODTO == __cTipoOp .And. N94->N94_CODETP == N93->N93_CODIGO
							If N94->N94_ANAQUA .Or. N94->N94_QTCPES
								lAtQtdDes := .T.
								exit
							EndIf   
							N94->(dbSkip())
						End   
						N94->(dbCloseArea())
					Else
						lAtQtdDes := .T.
					EndIf
				
					If lAtQtdDes				
						nLin ++
						AaDd(aEtapas, {N93->N93_CODIGO , N93->N93_DESETP, N93->N93_ORDEM, })
						//-- Realiza busca na tabela de Campos da Etapa	
						dbSelectArea("N95")
						dbSetOrder(2)
						If msSeek(FWxFilial("N95")+__cTipoOp+N93->N93_CODIGO)
							aEtapas[nLin][4] := {}
							While N95->(!Eof()) .AND. N95->N95_CODTO == __cTipoOp	.AND. N95->N95_CODETP == N93->N93_CODIGO 
								
								aadd(aEtapas[nLin][4], {N95->N95_CAMPO, N95->N95_OBRIGA}) 
								
								N95->(dbSkip())
							EndDo
						EndIF
						N95->(dbCloseArea())
					EndIf
				EndIf 
				N93->(dbSkip())
			EndDo
		EndIF
		N93->(dbCloseArea())
	endif	
	
	//--Ordena pelo campo N93_ORDEM
	ASORT(aEtapas, , , { | x,y | x[3] < y[3] } )
	
	//-- Verifica Modo Exec. 1=Etapas
	If cMdExec == "1" 
	    // se etapa estiver vazia procura no romaneio
	    If Empty(__cEtapa) .AND. !Empty(__cCodRom)
		    //-- Realiza busca da etapa que romaneio se encontra
		    dbSelectArea("NJJ")
			dbSetOrder(1)
			If msSeek(FWxFilial("NJJ")+__cCodRom) //FILIAL + ROMANEIO 
			   __cEtapa := NJJ->NJJ_ETAPA
			EndIf 

		    //se etapa do romaneio estiver vazia seta default primeira etapa
		    If Empty(__cEtapa) .AND. !Empty(aEtapas)
		       __cEtapa := aEtapas[1][1]
		    EndIf
		EndIf    
	    
	    //remove as etapas deixando apenas etapa que romaneio se encontra 
	    For nX := 1 TO Len(aEtapas)
	        If nX > Len(aEtapas)
				Exit
			EndIf
			
	        If aEtapas[nX][1] != __cEtapa
	           aDel(aEtapas,nX)
			   aSize(aEtapas,Len(aEtapas)-1)  
			   nX--
	        Else
	           __cOrdEtp := aEtapas[1][3]    //atribui ordem da etapa
	        EndIf
	    Next nX 
	EndIf	
	
	//-- Separa os campos para criar a estrutura da view
	If .NOT. Empty(aEtapas)
		For nX := 1 TO Len(aEtapas)
			If aEtapas[nX][4] != Nil .OR. !(EMPTY(aEtapas[nX][4])) //Caso a N95 não tenha sido preenchida
				For nY := 1 TO Len(aEtapas[nX][4]) 
					If nX = 1 .AND. nY = 1
						cCampos += aEtapas[nX][4][nY][1]
					Else 
						cCampos += "|" + aEtapas[nX][4][nY][1]
					EndIf 
				
				Next nY
			EndIf
		Next nX 
	Else
		cCampos := "NJJ_CODROM"
	EndIF 
	If EMPTY(cCampos)
		cCampos := "|NJJ_CODROM"
	EndIf 
	oStrNJJ := FwFormStruct( 2, "NJJ", {|cCampo| (Alltrim(cCampo) $  cCampos  )} )
																  
	oHMCpos := AToHM(oStrNJJ:aFields)
	
	oView:SetModel( oModel )															  
	oView:AddField( 'VIEW_NJJ', oStrNJJ , 'AGRA500_NJJ' )

	//--------------------------------
	// Pode alterar valores
	//--------------------------------
	If HMGet(oHMCpos,"NJJ_PSSUBT", oVal)
		oStrNJJ:SetProperty( 'NJJ_PSSUBT' , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If HMGet(oHMCpos,"NJJ_PSDESC", oVal)
		oStrNJJ:SetProperty( 'NJJ_PSDESC' , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_QTDFIS", oVal)
		oStrNJJ:SetProperty( 'NJJ_QTDFIS' , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_DOCESP", oVal)
		oStrNJJ:SetProperty( "NJJ_DOCESP" , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_DOCEMI", oVal)
		oStrNJJ:SetProperty( "NJJ_DOCEMI" , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_VLRUNI", oVal)
		oStrNJJ:SetProperty( "NJJ_VLRUNI" , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_VLRTOT", oVal)
		oStrNJJ:SetProperty( "NJJ_VLRTOT" , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	If HMGet(oHMCpos,"NJJ_EST", oVal)
		oStrNJJ:SetProperty( 'NJJ_EST'	  , MVC_VIEW_CANCHANGE, .T.)
	EndIf
	
	//--------------------------------
	// Consultas padroes
	//--------------------------------
	If HMGet(oHMCpos,"NJJ_CGC", oVal)
		oStrNJJ:SetProperty( 'NJJ_CGC'   , MVC_VIEW_LOOKUP , 'DA4NJJ')
	EndIf
	If HMGet(oHMCpos,"NJJ_PLACA", oVal)
		oStrNJJ:SetProperty( 'NJJ_PLACA' , MVC_VIEW_LOOKUP , 'DA302')
	EndIf
	If HMGet(oHMCpos,"NJJ_CODENT", oVal)
		oStrNJJ:SetProperty( 'NJJ_CODENT' , MVC_VIEW_LOOKUP, 'NJ0')
	EndIf
	
	//--------------------------------------
	//Altera a picture em tempo de execucao
	//--------------------------------------
	If HMGet(oHMCpos,"NJJ_CGC", oVal)
		oStrNJJ:SetProperty('NJJ_CGC'   , MVC_VIEW_PICT  , '@R 999.999.999-99999')
	EndIf

	oStrNJJ:AddFolder('FOLDER1', STR0037 ,'',2) // Informacoes
	oStrNJJ:SetProperty( '*' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')

	//Divisão de grupos
	For nX := 1 TO Len(aEtapas)
		//--------------------------------
		// Grupo criado
		//--------------------------------
		oStrNJJ:AddGroup(  'GRUPO0' + cValtoChar(nX), aEtapas[nX][2], '', 2 )
	Next nX 
		
	//Divisão de grupos
	For nX := 1 TO Len(aEtapas)
		If aEtapas[nX][4] != Nil .OR. !(EMPTY(aEtapas[nX][4])) //Caso a N95 não tenha sido preenchida
			For nY := 1 TO Len(aEtapas[nX][4])
				//--------------------------------
				// Grupo que o campo sera adicionado
				//-------------------------------- 
				oStrNJJ:SetProperty(AllTrim( aEtapas[nX][4][nY][1] ), MVC_VIEW_GROUP_NUMBER, 'GRUPO0' + cValtoChar(nX))
				//--------------------------------
				// Ordem de campos
				//--------------------------------
				oStrNJJ:SetProperty( AllTrim( aEtapas[nX][4][nY][1] ), MVC_VIEW_ORDEM, STRZERO(nCount, 2))
				//--------------------------------
				// Campos obrigatorios ou nao
				//--------------------------------			
				lObrigat := IIF(AllTrim( aEtapas[nX][4][nY][2]) == "1",.T.,.F.) 
				oModel:GetModel("AGRA500_NJJ"):GetStruct():SetProperty(AllTrim( aEtapas[nX][4][nY][1]), MODEL_FIELD_OBRIGAT, lObrigat)	
				nCount++
			Next nY
		EndIf
	Next nX 
    
	//-----------------------
	// Remove campos da view
	//-----------------------
	oStrNJJ:RemoveField("NJJ_TIPO")
	oStrNJJ:RemoveField("NJJ_DSTIPO")
	
	//--------------------------------
	//Inicio Grid NJM na View 
	oStrNJM := FWFormStruct( 2, "NJM" )

	oHMCpos := AToHM(oStrNJM:aFields)

	oStrNJM:RemoveField( "NJM_CODROM" )
	oStrNJM:RemoveField( "NJM_TIPO"   )

	///=== Define as propriedades dos campos do view ===/// 
	/*If cFormulario == "N"
	oStrNJM:SetProperty( "NJM_VLRUNI" , MVC_VIEW_CANCHANGE, .T. )
	oStrNJM:SetProperty( "NJM_VLRTOT" , MVC_VIEW_CANCHANGE, .T. )
	EndIf*/

	//--------------------------------
	// Consultas padroes
	//--------------------------------
	If HMGet(oHMCpos,"NJM_TALHAO", oVal)
		oStrNJM:SetProperty( 'NJM_TALHAO' , MVC_VIEW_LOOKUP, 'NN3NJM')
	EndIf

	oView:AddGrid( "V500_NJM", oStrNJM, "AGRA500_NJM",, )

	oView:AddIncrementField( "V500_NJM", "NJM_ITEROM" )

	oView:CreateHorizontalBox( "SUPERIOR" , 60 )
	oView:CreateHorizontalBox( "INFERIOR" , 40 )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0062) //"Comercialização"

	oView:CreateHorizontalBox( "PASTA_NJM", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( 'VIEW_NJJ' ,'SUPERIOR' ) 
	oView:SetOwnerView( "V500_NJM", "PASTA_NJM" )
	//Final Grid NJM na View 
	//--------------------------------
	
	//--------------------------------
	If IsInCallStack('AGRA500')
		//Inicio Grid NJK na View 
		If MostraClas(__cTipoOp, __cEtapa)
			oStruNJK := FWFormStruct( 2, "NJK" )
			
			//Campo nao pode ser alteravel
			oStruNJK:SetProperty( "NJK_OBRGT" , MVC_VIEW_CANCHANGE, .F. )
			
			oView:AddGrid( "V500_NJK", oStruNJK, "NJKUNICO",,{ || OGA250Gri(oModel,oView)} /*Get Focus*/)
			oView:AddSheet( "GRADES", "PASTA03", STR0068) //"Classificacao"
			
			oView:CreateHorizontalBox( "PASTA_NJK", 100, , , "GRADES", "PASTA03" )
			oView:SetOwnerView( "V500_NJK", "PASTA_NJK" )
			oStruNJK:RemoveField( "NJK_CODROM" )
			
			/* Para não tirar a ordem dos registros do tipo grupo */
			oView:SetViewProperty("V500_NJK", "ENABLENEWGRID")
			oView:SetViewProperty("V500_NJK", "GRIDNOORDER")
		EndIf
	EndIf	
	//Final Grid NJK na View 
	//--------------------------------

		
	dbSelectArea("N92")	
	dbSetOrder(1)
	N92->(msSeek(FWxFilial("N92")+__cTipoOp))
	if N92->N92_GSTFD1
		oView:AddUserButton( STR0069  , '', { |oModel| AGRA500E(M->NJJ_CODVAR, M->NJJ_TALHAO, M->NJJ_FAZ, M->NJJ_CODROM, M->NJJ_CODENT, M->NJJ_CODSAF, M->NJJ_CODPRO) } ) //"Vincular fardões"
		lVincDXL := .T. 
	elseIf N92->N92_GSTFD2
		oView:AddUserButton( STR0070  , '', { |oModel| IIF(AGRA500TemIE(oModel),AGRX500AVF(.F., M->NJJ_CODROM),)  } ) //"Vincular fardos"  
	endIf

	oStrN9E := FWFormStruct( 2, "N9E" )
	oStrN9E:RemoveField( "N9E_FILIAL" )
	oStrN9E:RemoveField( "N9E_CODROM" )
	oStrN9E:RemoveField( "N9E_SEQUEN" )
	oStrN9E:RemoveField( "N9E_FILIE"  )
	oView:AddGrid( "V500_N9E", oStrN9E, "AGRA500_N9E",, )
	oView:AddSheet( "GRADES", "PASTA02", STR0099) //"Integração Romaneio"
	oView:CreateHorizontalBox( "PASTA_N9E", 100, , , "GRADES", "PASTA02" )
	oView:SetOwnerView( "V500_N9E", "PASTA_N9E" )
	
	oStrN9E:SetProperty( 'N9E_ITEMAC'   , MVC_VIEW_LOOKUP , 'N8ON9E')
	
	//-- Habilita a visualização do contrato
	If .NOT. IsInCallStack( "OGX001VCtr" ) 
		oView:AddUserButton( STR0109, "BMPCONS", { || OGX001Ctr( , FWFldGet("NJM_CODCTR")  ) } ) 	//"Contrato" 
	EndIf
	
	//-- Habilita a visualização do documento fiscal 
	oView:AddUserButton( STR0106, 'BMPCONS', { || AGX500GDCF( FWFldGet("NJJ_CODROM"), FWFldGet("NJM_ITEROM"), FWFldGet("NJJ_FILIAL")) } ) 	//"Docto. Fiscal" 
	
	//-- Habilita a visualização movimentações
	If .NOT. IsInCallStack( "OGA440" ) .And. ! IsInCallStack( "OGX001VMov" )
		oView:AddUserButton( STR0110, "BMPCONS", { || OGX001Mov( FWFldGet("NJM_IDMOV") ) } ) 	//"Movimentação" 
	EndIf

    //--------------------------------------
	//Inclui botão de pesagem nas ações relacionadas
	//--------------------------------------
    oView:AddUserButton( STR0007 , '', {|oModel| AGRA500P(oModel, "VIEW")} ) 	//"Pesagem"
    
    //-- Verifica Modo Exec. 1=Etapas
	If cMdExec == "1"
       oView:AddUserButton(STR0086, '', {|oView| AGR500GETP(oView)} ) //"Finalizar Etapa"
    EndIf
    
    oView:SetViewAction( "BUTTONCANCEL", {|| A500CLOSE() } )
    
    oView:SetAfterViewActivate( { | | fAftViewActiv( ) } )
	oView:SetAfterOkButton( {| | fAftOKButton( ) } )
    
Return oView

Static Function PosModelo(oModel)
	Local lRet		:= .T.
	Local nOperac	:= oModel:GetOperation()
	Local cFilCli	:= ""	
	
	If nOperac == MODEL_OPERATION_INSERT .OR. nOperac == MODEL_OPERATION_UPDATE 
	  	If M->NJJ_TIPO $ "A|B"	//--tratamento para filiais somente devem ser feitas para os tipos A e B (transferencias)
	  		cFilCli := AGRX500POF(M->NJJ_CODENT, M->NJJ_LOJENT)
	  		
	  		if cFilCli = cFilAnt
	  			Help('' ,1,".AGRA50000027.", , ,1,0) //Entidade inválida para o tipo de operação do romaneio. //Informe uma entidade diferente da filial logada.
	  			lRet	:= .F.
	  		EndIf	  			 
	  	ElseIf M->NJJ_TIPO $ '2|4|6|8' .AND. _lAltIE //se for saída e houve alteração na IE faz análise crédito
  			lRet := AGRX500VlC(oModel, M->NJJ_CODROM)
		
  			if lRet
  				_lAltIE := .F.
  			EndIf
		EndIF
	EndIf
	
Return lRet

/*/{Protheus.doc} GrvModelo
//Função responsável pela persistência dos dados do romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)
	Local lRet    		:= .T.
	Local lRetAtu  		:= .T.
	Local oMldNJJ 		:= oModel:GetModel('AGRA500_NJJ')
	Local oMldNJM 		:= oModel:GetModel('AGRA500_NJM')
	Local oMldDX0 		:= oModel:GetModel('AGRA500_DX0')
	Local nOperation	:= oModel:GetOperation()
	Local cTpEntSai     := ''
	Local nLinha		:= 0
	Local nX			:= 0
	Local lAtuAuto 		:= .F.
	Local lConfAuto 	:= .F.
	Local cModoExec		:= "2"
	Local lAgoClas		:= FwIsInCallStack("AGOCLAS")
	
	If lAgoClas
		oMldNJM:SetNoUpdateLine(.F.)
	EndIf
	
	N92->(dbSelectArea('N92'))
	N92->(dbSetOrder(1))
	
	If .NOT. Empty(oMldNJJ:GetValue('NJJ_TOETAP'))
		 __cTipoOp := oMldNJJ:GetValue('NJJ_TOETAP')
	EndIf

	If N92->(dbSeek(FWxFilial("N92") + __cTipoOp))
		cModoExec := N92->N92_MDEXEC
		lAtuAuto  := N92->N92_AUTATU
		lConfAuto := N92->N92_AUTCNF 
	EndIf

	If Empty(__cTipoOp) .AND. IsInCallStack('AGRA500')
		//-- Pergunte para escolher o tipo de operação
		Pergunte( "AGRA500001", .F. )
		//-- Variavel do tipo de operação
		__cTipoOp := MV_PAR04
	EndIf	
	
	If nOperation != MODEL_OPERATION_DELETE
		//-- Seta a função origem como o novo romaneio
		oMldNJJ:SetValue('NJJ_ORIGEM','AGRA500')
	EndIf
	
	//-- Seta o Tipo de Operação somente quando for uma operação de inclusão
	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) .AND. .NOT. IsInCallStack('A500IncRom') 
		oMldNJJ:SetValue('NJJ_TOETAP', __cTipoOp)

		nLinha := oMldNJM:GetLine()
		For nX := 1 to oMldNJM:Length()
			oMldNJM:GoLine( nX )
			If .Not. oMldNJM:IsDeleted()
				//*GRAVA O TIPO DO ROMANEIO
				if EMPTY(oMldNJM:GetValue("NJM_TIPO"))
					oMldNJM:LoadValue("NJM_TIPO" , oMldNJJ:GetValue('NJJ_TIPO') )
				endIf
				
				If !Empty(oMldNJM:GetValue('NJM_CODCTR'))					
					oMldNJM:LoadValue("NJM_FILORG", FwxFilial("NJR"))
				EndIf
				
				If Empty(oMldNJM:GetValue('NJM_SUBTIP'))
					oMldNJM:LoadValue("NJM_SUBTIP" , oMldNJJ:GetValue('NJJ_TIPO') + '0')
				EndIf
			EndIF
		Next nX
		oMldNJM:GoLine( nLinha )

	EndIf
	
	//Busca o tipo do romaneio na tabela N92
	cTpEntSai := POSICIONE('N92',1,FWxFilial('N92')+__cTipoOp,'N92_TIPO') 	
	
	//Valida a parte de IE com Cabecalho NJJ
	If lRet
		lRet := AGRX500FVL(oModel)
	EndIf
	
	//Atualiza status dos fardoes
	If lRet //.And. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
		A500ESTT(oMldDX0)
	EndIf
	
	If nOperation != MODEL_OPERATION_DELETE .And. lRet .And. cModoExec == "1"
		oMldNJJ:SetValue('NJJ_ETAPA', __cEtapa)
	EndIf
	
	//Atualiza DXI
	If lRet .And. Type("_lVincFard") != "U" .And. _lVincFard
		AGRX500FCM(oModel)	
	EndIf
	
	If lRet
		lRet := FWFormCommit( oModel )
	EndIF
	
	//Atualização Automatica do Romaneio N92_AUTATU
	If lRet .And. lAtuAuto
		lRetAtu := OGA250ATUC()
	EndIf

	//Confirmacao Automatica do Romaneio N92_AUTCNF
	If lRet .AND. lRetAtu .AND. lConfAuto
		A500ConfRom(oMldNJJ:GetValue("NJJ_CODROM"), .F.)
	EndIf

Return lRet


/*/{Protheus.doc} A500ConfRom
//Função responsável pela preparação dos dados para confirmação do romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Function A500ConfRom(cCodRomaneio, lVisual)
	Local lRet		:= .T.
	Local aArea   	:= GetArea()
	Local aLines  	:= FwSaveRows()
	Local aCampos	:= {}
	Local cCampos	:= ""
	Local cNumOP	:= ""
	Local cEtapa	:= ""
	Local oModel  	:= FwLoadModel('AGRA500')
	Local oVal 		:= Nil
	Local nX		:= 0
	Local lAlgodao	:= .F.
	Local lOPEspec  := .F. 
	Local cFilCli 	:= ""
	Local cRomDest 	 := ''
	Local cRomOri 	 := ''
	Local cFilOri	 := cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DA ENTIDADE
	Local lEfet      := .F.
	
	Local cAlias, nReg, nAcao, lAuto
	Private __cNNTFil := "" //variavel carregada na transferencia entre filiais
	Private __cNNTCod := "" //variavel carregada na transferencia entre filiais
	
	lOPEspec := ExistBlock("AGRA50OP")
	
	//-- Variavel do tipo de operação
	__cTipoOp := MV_PAR04
	
	If IsInCallStack('AGRA500')
		//-- Se não é uma inclusão
		If .NOT. Inclui
			//-- Busca etapa gravada
		    IF .NOT.EMPTY(NJJ->NJJ_TOETAP) 
		    	__cTipoOp := NJJ->NJJ_TOETAP
		    EndIf
	    Else //-- Utiliza etapa do parametro 
	    	Pergunte( "AGRA500001", .F. )
	    	__cTipoOp := MV_PAR04
	    EndIf
    EndIf

	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))
	If NJJ->( msSeek(fwxFilial('NJJ')+cCodRomaneio) )
		
		//Se status do romaneio for 3, dá mensagem
		If !(NJJ->NJJ_STATUS $ '3|5')
		
			oModel:SetOperation(4) //Alteração
			If oModel:Activate()
	
				//--Função para busca dos campos do tpo de operação que são obrigatorios.
				aCampos := A500Etap()
				oHMCpos := AToHM( aCampos )
				
				For nX := 1 To Len(aCampos)
					If HMGet(oHMCpos, aCampos[nx][1], oVal)
						If Empty(oModel:GetValue( 'AGRA500_NJJ', aCampos[nx][1]) )
							cCampos := aCampos[nx][1]
							cEtapa	:= Posicione("N93",1,FWxFilial("N93")+__cTipoOp+aCampos[nx][2],"N93_DESETP") 
						EndIf
					EndIf
				Next nX
				
				Processa({||lRet := VldConfRom(@oModel, cCampos, cEtapa)}, STR0017 ) //"Validando dados de romaneio para confirmação"
				
				lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
									
				If lRet 
				
					//OP (ordem produção) específica enviada pelo cliente por ponto entrada
					If lOPEspec
					  	cNumOP := ExecBlock('AGRX50OP',.F.,.F.,)
					ElseIf NJJ->NJJ_NUMOP != ''
						cNumOP := NJJ->NJJ_NUMOP
					Else
					    cNumOP := ""
					EndIf
					
					//-- INICIO TRANSACAO CONFIRMAR ROMANEIO --//
					BEGIN TRANSACTION						
						//--Entrada por Transferencia = A
						If NJJ->NJJ_TIPO == 'A' //entrada por transferência
							cRomDest := NJJ->NJJ_CODROM

							lRet := A500EntTra(@cFilCli, cFilOri, @cRomOri, lAlgodao, cNumOP, oModel, @lEfet) //Função no fonte AGRX500E.PRW

						//--Saída por Transferencia = B
						ElseIf NJJ->NJJ_TIPO == 'B' // saída por transferência
							cRomOri	:= NJJ->NJJ_CODROM

							lRet := AX500SaiTr(@cFilCli, cFilOri, @cRomDest, lAlgodao, cNumOP, oModel, @lEfet) //Função no fonte AGRX500K.PRW
						ElseIf NJJ->NJJ_TIPO == '4' // saída por venda
							If .NOT. lAlgodao
								lRet := AX500PSVen(cNumOP) //Função no fonte AGRX500P.PRW
							EndIf
						EndIf	
						
						If NJJ->NJJ_TIPO $ 'A|B'
							//se efetivação da transferência funcionou chama função atualizar pedido/ NF
						    If lEfet
					        	lRet := A500ATROM(cRomOri, cRomDest)
						    EndIf
						EndIf

						If lRet
							If lRet := oModel:VldData()
								lRet := FWFormCommit(oModel)								
							EndIf
						EndIf 
					
						If !(lRet)
						   DisarmTransaction()
						EndIf
						
					END TRANSACTION
					//-- FINAL TRANSACAO CONFIRMAR ROMANEIO --//
					
					
					//CONFIRMAR RETIRADO DA TRANSAÇÃO
					If lRet .AND. .NOT. NJJ->NJJ_TIPO $ 'A|B' 
						lRet := OGA250G(cAlias, nReg, nAcao, lAuto, cNumOP)
                        
                        /**  CHAMDA DE INTEGRAÇÃO COMENTADA, ISSUE DAGROOGD-13709 e DAGROOGD-13798 - ver comentarios das issues
						//Integracao PIMS
                        If lRet .And. !Empty(NJJ->NJJ_ORDCLT) .And. NJJ->NJJ_PSLIQU > 0
                            lRet := AGRA500Int()
                        EndIf
						**/
					EndIf
					
					If lRet					

                        If NJJ->NJJ_TIPO $ '3|5|7|9' 
							lRet := AX500LCfEn(lAlgodao) //Função no fonte AGRX500L.PRW
						ElseIf NJJ->NJJ_TIPO $ '2|4|6|8'						
							lRet := AX500MCfSa(lAlgodao) //Função no fonte AGRX500M.PRW
						endIf
//						ElseIf NJJ->NJJ_TIPO $ 'A|B'
//							//se efetivação da transferência funcionou chama função atualizar pedido/ NF
//						    If lEfet
//					        	lRet := A500ATROM(cRomOri, cRomDest)
//						    EndIf
//						EndIf
						
						if lRet
							oModel:GetModel('AGRA500_NJJ'):SetValue('NJJ_STATUS','3') //Se validação prévia = ok, então, atualiza status como confirmado
						endIf
					endIf
					
					If lRet .And. lVisual
						MsgInfo( STR0013 + cCodRomaneio + STR0018 ) //"O romaneio " ## " foi confirmado com sucesso."
					Endif
					//CONFIRMAR RETIRADO DA TRANSAÇÃO
					
				Else 
					AutoGrLog(oModel:GetErrorMessage()[6])
					AutoGrLog(oModel:GetErrorMessage()[7])
					If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
						AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
					EndIf
					
					If lVisual
						MostraErro()
					Endif
				Endif
				
				oModel:DeActivate()
			Else
				//Problemas com modelo do romaneio
				AutoGrLog(STR0012 + cCodRomaneio + ".")
				lRet := .F.
				If lVisual
					MostraErro()
				Endif
				//Help(,,'HELP',, STR0012 + cCodRomaneio + "." ,1,0) //"Não foi possível efetuar a confirmação do romaneio. Por gentileza, verifique a validade do romaneio "	
			Endif
		Else
			//Help(,,'HELP',, STR0013 + cCodRomaneio + STR0019,1,0) //" já foi confirmado."
			If NJJ->NJJ_STATUS = '3'
				AutoGrLog(STR0013 + cCodRomaneio + STR0019)
			Else
				AutoGrLog(STR0105) //"Favor aprovar o romaneio antes de confirmá-lo"
			EndIf
			lRet := .F.
			If lVisual
				MostraErro()
			Endif
		Endif
	Else
		//Mensagem indicando que código de romaneio não existe para a filial logada
		AutoGrLog(STR0013 + cCodRomaneio + STR0014)
		lRet := .F.
		If lVisual
			MostraErro()
		Endif 
	Endif
	
	//NJJ->(DbCloseArea())
	
	FwRestRows(aLines)
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} A500Aprov
Aprovação do romaneio 
@author silvana.torres
@since 12/03/2018
@version undefined
@param cCodRomaneio, characters, descricao
@param lVisual, logical, descricao
@param aMsgHist, array, descricao
@type function
/*/
Function A500Aprov(cCodRomaneio, lVisual, aMsgHist, lConfirma)

	Local lRet		:= .T.
	Local aArea   	:= GetArea()
	Local aLines  	:= FwSaveRows()
	Local oModel  	:= FwLoadModel('AGRA500')
	
	Default aMsgHist	:= {} 	
	Default lConfirma	:= .F.
	 
	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))
	If NJJ->( msSeek(fwxFilial('NJJ')+cCodRomaneio) )

		//Se status do romaneio for 5 - pendente de aprovação
		If NJJ->NJJ_STATUS = '5'
		
			if len(aMsgHist) > 0
				AGRGRAVAHIS(,,,,{"NJJ",fwxFilial("NJJ")+cCodRomaneio,aMsgHist[2],aMsgHist[1]})
			else			
				If .NOT. AGRGRAVAHIS(STR0085,"NJJ",NJJ_FILIAL+NJJ_CODROM,"A") = 1
					lRet := .F.
				endIf
			endIf
			
			if lRet
				oModel:SetOperation(4) //Alteração
				If oModel:Activate()
		
					If .NOT. lConfirma
						oModel:GetModel('AGRA500_NJJ'):SetValue('NJJ_STATUS','0') //Se validação prévia = ok, então, atualiza status como pendente
					Else
						oModel:GetModel('AGRA500_NJJ'):SetValue('NJJ_STATUS','3') //Se validação prévia = ok, então, atualiza status como confirmado
					EndIf
					
					If lRet := oModel:VldData()
						lRet := oModel:CommitData()
					EndIf 
				Else 
					AutoGrLog(oModel:GetErrorMessage()[6])
					AutoGrLog(oModel:GetErrorMessage()[7])
					If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
						AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
					EndIf
					
					If lVisual
						MostraErro()
					Endif					
				Endif
				
				If lRet .And. lVisual
					MsgInfo( STR0013 + cCodRomaneio + STR0084 ) //"O romaneio " ## " foi aprovado com sucesso."
				Endif
				
				oModel:DeActivate()
			EndIf
		Else
			AutoGrLog(STR0013 + cCodRomaneio + STR0083) //"O romaneio " ## " já foi aprovado."
			lRet := .F.
			If lVisual
				MostraErro()
			Endif
		Endif
	EndIf
		
	FwRestRows(aLines)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldConfRom
//Função responsável pela validação dos dados pertinentes a confirmação do romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function VldConfRom(oModel, cValidar, cEtapa)
	Local lRet        := .T.
	Local oMldNJJ     := oModel:GetModel('AGRA500_NJJ')	
	Local nX          := 0	
	Local cErro       := ""

	For nX := 1 to oMldNJJ:OFORMMODELSTRUCT:NFIELDSLENTH //Laço vai navegar por toda a estrutura	
		If (oMldNJJ:OFORMMODELSTRUCT:aFields[nX,3] $ cValidar) .And. lRet //Considera campos que precisam de validação de preenchimento
			//Função responsável por verificar especificamente o preenchimento dos campos passados
			If !VldHasData(oMldNJJ, oMldNJJ:OFORMMODELSTRUCT:aFields[nX,4], oMldNJJ:OFORMMODELSTRUCT:aFields[nX,3])
				cErro := STR0015 + oMldNJJ:OFORMMODELSTRUCT:aFields[nX,2] + STR0042 + Alltrim(cEtapa) + STR0016  //"O campo " ## " da Etapa " ## " não informado. Seu preenchimento é necessário para o processo de confirmação do romaneio."

				oModel:SetErrorMessage( , , oModel:GetId() , "", "", cErro, "", "", "")
				lRet := .F.				
			Endif
		Endif
	Next nX			
Return lRet

/*/{Protheus.doc} VldHasData
//Função responsável pela verificação de existência de dados informados nos campos da estrutura do modelo
@author bruna.rocio
@since 22/11/2017
@version undefined
@param oModel, object, descricao
@param cType, characters, descricao
@param cCode, characters, descricao
@type function
/*/
Static Function VldHasData(oModel, cType, cCode)
	Local lRet := .T.
	
	Do Case
		Case cType = 'C' //Tipo caracter
			lRet := !Empty(oModel:GetValue(cCode))
		Case cType = 'N' //Tipo Numérico
			lRet := oModel:GetValue(cCode) > 0	
	EndCase
Return lRet


/*/{Protheus.doc} A500Basico
//Funcao Dados Basicos
@author carlos.augusto
@since 23/11/2017
@version undefined
@param cCodRom, char, Codigo do romaneio informado pelo AGRA500
@param lVisual, logical, informa se executara na tela
@param aCpo, object, Lista de campos para gravacao. Array com array de campos conforme:
{"OPERATION", 3=Inclusao ou 4=Alteracao ou 5=Exclusao},{"NJJ_CODROM",'0000000001'},{"NJJ_TIPO",'1'}
@type function
/*/
Function A500Basico(cCodRom, lVisual, aCpo)
	Local lRet		:= .T.
	Local oModel	:= FWLoadModel('AGRA500')
	Local oView		:= FWLoadView('AGRA500A')
	Local oFWMVCWindow, aCoors
	Local oVal		:= Nil
	Local cStatus   := ''
	
	Default lVisual	:= .F.
	Default aCpo	:= {}
	
/*	//Informar numero do romaneio
	If IsInCallStack('GFEA523')
		cCodRom := U_INPUTVAL('Nº Romaneio',)
	EndIf*/

	oModel:GetModel("AGRA500_NJJ"):GetStruct():SetProperty('NJJ_CODENT', MODEL_FIELD_OBRIGAT,.T.)
	oModel:GetModel("AGRA500_NJJ"):GetStruct():SetProperty('NJJ_TIPO',   MODEL_FIELD_OBRIGAT,.T.)		

	If !lVisual
	
		If Empty(aCpo)
			AutoGrLog(STR0034) //"Função de persistência de dados basicos do romaneio está sendo executada em modo API. 
								//Dessa forma, é necessário informar todos os dados via array."				
			Return .F.
		Endif	
	
		oHash := AToHM(aCpo)
	
		If HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 3
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		ElseIf HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 4
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			If HMGet(oHash,"NJJ_CODROM", oVal)
				dbSelectArea( "NJJ" )
				dbSetOrder( 1 )
				msSeek( FWxFilial( "NJJ" ) + oVal[1][2])
				cStatus := NJJ->NJJ_STATUS
			EndIf
		EndIf
	
		If oModel:Activate()
		
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cStatus = ''
				//Mensagem indicando que código de romaneio não existe para a filial logada
				AutoGrLog(STR0013 + cCodRom + STR0014 )
				Return .F.
			ElseIf cStatus = '3' //Confirmado
				
				AutoGrLog(STR0013 + cCodRom + STR0019 )
				//Help(,,'HELP',, STR0013 + cCodRom + STR0019,1,0) //" já foi confirmado."
				Return .f.
			Endif
			
			If lRet .And. HMGet(oHash,"NJJ_TIPO", oVal)
				M->NJJ_TIPO := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_TIPO', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_TOETAP", oVal)
				M->NJJ_TOETAP := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_TOETAP', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_CODSAF", oVal)
				M->NJJ_CODSAF := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CODSAF', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_CODPRO", oVal)
				M->NJJ_CODPRO := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CODPRO', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_UM1PRO", oVal)
				M->NJJ_UM1PRO := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_UM1PRO', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_LOCAL", oVal)
				M->NJJ_LOCAL := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_LOCAL', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_CODENT", oVal)
				M->NJJ_CODENT := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CODENT', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_LOJENT", oVal)
				M->NJJ_LOJENT := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_LOJENT', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_FAZ", oVal)
				M->NJJ_FAZ := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_FAZ', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_TALHAO", oVal)
				M->NJJ_TALHAO := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_TALHAO', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_CODVAR", oVal)
				M->NJJ_CODVAR := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CODVAR', oVal[1][2])
			EndIf		
		
			If lRet := oModel:VldData()
			    lRet := oModel:CommitData()
			EndIf
			If !lRet
				AutoGrLog(oModel:GetErrorMessage()[6])
				AutoGrLog(oModel:GetErrorMessage()[7])
				If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
					AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
				EndIf
			EndIf
			HMClean(oHash)
			FreeObj(oHash)
			oModel:DeActivate()
		Else
			//Problemas com modelo do romaneio
			AutoGrLog(STR0012 + cCodRom + ".")
			lRet := .F.
		EndIf
		
	Else
	
		If !Empty(cCodRom)
			dbSelectArea( "NJJ" )
			dbSetOrder( 1 )
			msSeek( FWxFilial( "NJJ" ) + cCodRom)
		EndIf
		
		If !Empty(cCodRom) .And. MsgYesNo( STR0025 + cCodRom + STR0026 ,OemToAnsi(STR0027)) // "Deseja continuar o processo para o romaneio "##"? Caso selecione a opção não, será iniciado um novo romaneio."##"Atenção"
			//If NJJ->NJJ_STATUS == '3'
			If NJJ->NJJ_STATUS $ '2|3|4'	//"3=Encerrado" ou "4-Cancelado"
				Help('' ,1,".AGRA50000001.", , ,1,0) /* Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'. */
				//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
				//Somente Romaneios com status - Pendende - Completo - podem ser alterados.				
				Return .F.
			EndIf
			oView:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oView:SetOperation(MODEL_OPERATION_INSERT)
		EndIf
	
		aCoors := FWGetDialogSize(oMainWnd)  
				
	   	oView:SetModel(oModel)
		oView:EnableControlBar(.T.)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
	
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
		oFWMVCWindow:SetTitle(STR0022 ) //"Dados Básicos do Romaneio" 
		oFWMVCWindow:SetEscClose(.T.)
		oFWMVCWindow:SetStyle(2)
		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
	
	EndIf
	
Return lRet

/*/{Protheus.doc} A500FISC
//TODO Descrição auto-gerada.
@author silvana.torres
@since 29/11/2017
@version undefined
@param cCodRom, characters, descricao
@param lVisual, logical, descricao
@param aCpo, array, descricao
@type function
/*/
Function A500FISC(cCodRom, lVisual, aCpo)
	Local lRet		:= .T.
	Local oModel	:= FWLoadModel('AGRA500')
	Local oView		:= FWLoadView('AGRA500D')
	Local oFWMVCWindow, aCoors
	Local oVal		:= Nil
	Local cStatus   := ''
	
	Default lVisual 	:= .F.

	If !lVisual
	
		If Empty(aCpo)
			AutoGrLog(STR0036) //"Função de persistência de dados fiscais do romaneio está sendo executada em modo API. 
								//Dessa forma, é necessário informar todos os dados via array."				
			Return .F.
		Endif	
	
		oHash := AToHM(aCpo)
	
		If HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 3
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		ElseIf HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 4
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			If HMGet(oHash,"NJJ_CODROM", oVal)
				dbSelectArea( "NJJ" )
				dbSetOrder( 1 )
				msSeek( FWxFilial( "NJJ" ) + oVal[1][2])
				cStatus := NJJ->NJJ_STATUS
			EndIf
		EndIf
	
		If oModel:Activate()
		
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cStatus = ''
				//Mensagem indicando que código de romaneio não existe para a filial logada
				AutoGrLog(STR0013 + cCodRom + STR0014 )
				Return .F.
			ElseIf cStatus = '3' //Confirmado
				
				AutoGrLog(STR0013 + cCodRom + STR0019 )
				//Help(,,'HELP',, STR0013 + cCodRom + STR0019,1,0) //" já foi confirmado."
				Return .f.
			Endif
		
			If lRet .And. HMGet(oHash,"NJJ_DOCNUM", oVal)
				M->NJJ_DOCNUM := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DOCNUM', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_DOCSER", oVal)
				M->NJJ_DOCSER := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DOCSER', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_DOCESP", oVal)
				M->NJJ_DOCESP := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DOCESP', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_EST", oVal)
				M->NJJ_EST := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_EST', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_DOCEMI", oVal)
				M->NJJ_DOCEMI := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DOCEMI', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_VLRUNI", oVal)
				M->NJJ_VLRUNI := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_VLRUNI', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_VLRTOT", oVal)
				M->NJJ_VLRTOT := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_VLRTOT', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_QTDFIS", oVal)
				M->NJJ_QTDFIS := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_QTDFIS', oVal[1][2])
			EndIf
			
			If lRet := oModel:VldData()
			    lRet := oModel:CommitData()
			EndIf
			If !lRet
				AutoGrLog(oModel:GetErrorMessage()[6])
				AutoGrLog(oModel:GetErrorMessage()[7])
				If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
					AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
				EndIf
			EndIf
				
			HMClean(oHash)
			FreeObj(oHash)
			oModel:DeActivate()
		Else
			//Problemas com modelo do romaneio
			AutoGrLog(STR0012 + cCodRom + ".")
			lRet := .F.
		EndIf	
	

	Else
	
		If !Empty(cCodRom)
			dbSelectArea( "NJJ" )
			dbSetOrder( 1 )
			msSeek( FWxFilial( "NJJ" ) + cCodRom)
		EndIf
		
		If !Empty(cCodRom) .And. MsgYesNo( STR0025 + cCodRom + STR0026 ,OemToAnsi(STR0027)) // "Deseja continuar o processo para o romaneio "##"? Caso selecione a opção não, será iniciado um novo romaneio."##"Atenção"
			//If NJJ->NJJ_STATUS == "3"
			If NJJ->NJJ_STATUS $ '2|3|4'	//"3=Encerrado" ou "4-Cancelado"
				Help('' ,1,".AGRA50000001.", , ,1,0) /* Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'. */
				//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
				//Somente Romaneios com status - Pendende - Completo - podem ser alterados.					
				Return .F.
			EndIf
			oView:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oView:SetOperation(MODEL_OPERATION_INSERT)
		EndIf
	
		aCoors := FWGetDialogSize(oMainWnd)  
				
	   	oView:SetModel(oModel)
		oView:EnableControlBar(.T.)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
	
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
		oFWMVCWindow:SetTitle(STR0032 ) //"Dados Fiscais do Romaneio" 
		oFWMVCWindow:SetEscClose(.T.)
		oFWMVCWindow:SetStyle(2)
		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
	
	EndIf
	
Return lRet


/*/{Protheus.doc} A500Transp
//Funcao Dados Basicos
@author carlos.augusto
@since 23/11/2017
@version undefined
@param cCodRom, char, Codigo do romaneio informado pelo AGRA500
@param lVisual, logical, informa se executara na tela
@param aCpo, object, Lista de campos para gravacao. Array com array de campos conforme:
{"OPERATION", 3=Inclusao ou 4=Alteracao ou 5=Exclusao},{"NJJ_CODROM",'0000000001'},{"NJJ_TIPO",'1'}
@type function
/*/
Function A500Transp(cCodRom, lVisual, aCpo)
	Local aArea     := GetArea()
	Local aLines    := FwSaveRows()
	Local lRet		:= .T.
	Local oModel	:= FWLoadModel('AGRA500')
	Local oView		:= FWLoadView('AGRA500B')
	Local oFWMVCWindow, aCoors
	Local oVal		:= Nil
	Local cStatus   := ''
	Default lVisual := .F.
	Default aCpo	:= {}
	
	If !lVisual
	
		If Empty(aCpo)
			AutoGrLog(STR0023) //"Função de persistência de dados de transporte de romaneio está sendo executada em modo API. 
								//Dessa forma, é necessário informar todos os dados via array."				
			Return .F.
		Endif
	
		oHash := AToHM(aCpo)
	
		If HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 3
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		ElseIf HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 4
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			If HMGet(oHash,"NJJ_CODROM", oVal)
				dbSelectArea( "NJJ" )
				dbSetOrder( 1 )
				msSeek( FWxFilial( "NJJ" ) + oVal[1][2])
				cStatus := NJJ->NJJ_STATUS
			EndIf
		EndIf
	
		If oModel:Activate()
		
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cStatus = ''
				//Mensagem indicando que código de romaneio não existe para a filial logada
				AutoGrLog(STR0013 + cCodRom + STR0014 )
				Return .F.
			ElseIf cStatus = '3' //Confirmado
				
				AutoGrLog(STR0013 + cCodRom + STR0019 )
				//Help(,,'HELP',, STR0013 + cCodRom + STR0019,1,0) //" já foi confirmado."
				Return .f.
			Endif
			
			//Procura na matriz de dados as informações correspondentes a cada campo
			If HMGet(oHash,"NJJ_CODTRA", oVal) .And. lRet
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CODTRA', oVal[1][2])
			EndIf		
			If HMGet(oHash,"NJJ_CGC", oVal) .And. lRet
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_CGC', oVal[1][2])
			EndIf
			If HMGet(oHash,"NJJ_PLACA", oVal) .And. lRet
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PLACA', oVal[1][2])
			EndIf
			If HMGet(oHash,"NJJ_TPFRET", oVal) .And. lRet
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_TPFRET', oVal[1][2])		
			EndIf
			
			If lRet := oModel:VldData()
			    lRet := oModel:CommitData()
			EndIf
			If !lRet
				AutoGrLog(oModel:GetErrorMessage()[6])
				AutoGrLog(oModel:GetErrorMessage()[7])
				If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
					AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
				EndIf
			EndIf
			HMClean(oHash)
			FreeObj(oHash)
			oModel:DeActivate()
		Else
			//Problemas com modelo do romaneio
			AutoGrLog(STR0012 + cCodRom + ".")
			lRet := .F.
		EndIf
	Else
	
		If !Empty(cCodRom)
			dbSelectArea( "NJJ" )
			dbSetOrder( 1 )
			msSeek( FWxFilial( "NJJ" ) + cCodRom)
		EndIf
		
		If !Empty(cCodRom) .And. MsgYesNo( STR0025 + cCodRom + STR0026 ,OemToAnsi(STR0027)) // "Deseja continuar o processo para o romaneio "##"? Caso selecione a opção não, será iniciado um novo romaneio."##"Atenção"
			//If NJJ->NJJ_STATUS == "3"
			If NJJ->NJJ_STATUS $ '2|3|4'	//"3=Encerrado" ou "4-Cancelado"
				Help('' ,1,".AGRA50000001.", , ,1,0) /* Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'. */
				//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
				//Somente Romaneios com status - Pendende - Completo - podem ser alterados.					
				Return .F.
			EndIf
			oView:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oView:SetOperation(MODEL_OPERATION_INSERT)
		EndIf
	
		aCoors := FWGetDialogSize(oMainWnd)  
			
	   	oView:SetModel(oModel)
		oView:EnableControlBar(.T.)
		
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
		oFWMVCWindow:SetTitle(STR0024) //"Dados de Transporte do Romaneio" 
		oFWMVCWindow:SetEscClose(.T.)
		oFWMVCWindow:SetStyle(2)
		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})	
	
	EndIf
	FwRestRows(aLines)
	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} A500PES
//Funcao Dados Pesagem
@author carlos.augusto
@since 23/11/2017
@version undefined
@param cCodRom, char, Codigo do romaneio informado pelo AGRA500
@param lVisual, logical, informa se executara na tela
@param aCpo, object, Lista de campos para gravacao. Array com array de campos conforme:
{"OPERATION", 3=Inclusao ou 4=Alteracao ou 5=Exclusao},{"NJJ_CODROM",'0000000001'},{"NJJ_TIPO",'1'}
@type function
/*/
Function A500PES(cCodRom, lVisual, aCpo)
	Local lRet		:= .T.
	Local oModel	:= FWLoadModel('AGRA500')
	Local oView		:= FWLoadView('AGRA500C')
	Local oFWMVCWindow, aCoors
	Local oVal		:= Nil
	Local cStatus   := ''
	
	Default lVisual := .F.
	Default aCpo	:= {}

	If !lVisual
	
		If Empty(aCpo)
			AutoGrLog(STR0035) //"Função de persistência de dados de pesagem do romaneio está sendo executada em modo API. 
								//Dessa forma, é necessário informar todos os dados via array."				
			Return .F.
		Endif
	
		oHash := AToHM(aCpo)
	
		If HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 3
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		ElseIf HMGet(oHash,"OPERATION", oVal) .And. oVal[1][2] == 4
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			If HMGet(oHash,"NJJ_CODROM", oVal)
				dbSelectArea( "NJJ" )
				dbSetOrder( 1 )
				msSeek( FWxFilial( "NJJ" ) + oVal[1][2])
				cStatus := NJJ->NJJ_STATUS
			EndIf
		EndIf
	
		If oModel:Activate()
		
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cStatus = ''
				//Mensagem indicando que código de romaneio não existe para a filial logada
				AutoGrLog(STR0013 + cCodRom + STR0014 )
				Return .F.
			ElseIf cStatus = '3' //Confirmado
				
				AutoGrLog(STR0013 + cCodRom + STR0019 )
				//Help(,,'HELP',, STR0013 + cCodRom + STR0019,1,0) //" já foi confirmado."
				Return .f.
			Endif
		
			If lRet .And. HMGet(oHash,"NJJ_PESO1", oVal)
				M->NJJ_PESO1 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PESO1', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_MODPS1", oVal)
				M->NJJ_MODPS1 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_MODPS1', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_DATPS1", oVal)
				M->NJJ_DATPS1 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DATPS1', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_HORPS1", oVal)
				M->NJJ_HORPS1 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_HORPS1', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_PESO2", oVal)
				M->NJJ_PESO2 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PESO2', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_MODPS2", oVal)
				M->NJJ_MODPS2 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_MODPS2', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_DATPS2", oVal)
				M->NJJ_DATPS2 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DATPS2', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_HORPS2", oVal)
				M->NJJ_HORPS2 := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_HORPS2', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_PSSUBT", oVal)
				M->NJJ_PSSUBT := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PSSUBT', oVal[1][2])
			EndIf
			If lRet .And. HMGet(oHash,"NJJ_PSDESC", oVal)
				M->NJJ_PSDESC := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PSDESC', oVal[1][2])
			EndIf		
			If lRet .And. HMGet(oHash,"NJJ_PSLIQU", oVal)
				M->NJJ_PSLIQU := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_PSLIQU', oVal[1][2])
			EndIf	
			If lRet .And. HMGet(oHash,"NJJ_DIFFIS", oVal)
				M->NJJ_DIFFIS := oVal[1][2]
				lRet := oModel:SetValue('AGRA500_NJJ','NJJ_DIFFIS', oVal[1][2])
			EndIf	
		
			If lRet := oModel:VldData()
			    lRet := oModel:CommitData()
			EndIf
			If !lRet
				AutoGrLog(oModel:GetErrorMessage()[6])
				AutoGrLog(oModel:GetErrorMessage()[7])
				If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
					AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
				EndIf
			EndIf
			HMClean(oHash)
			FreeObj(oHash)
			oModel:DeActivate()
		Else
			//Problemas com modelo do romaneio
			AutoGrLog(STR0012 + cCodRom + ".")
			lRet := .F.
		EndIf
	Else
	
		If !Empty(cCodRom)
			dbSelectArea( "NJJ" )
			dbSetOrder( 1 )
			msSeek( FWxFilial( "NJJ" ) + cCodRom)
		EndIf
		
		If !Empty(cCodRom) .And. MsgYesNo( STR0025 + cCodRom + STR0026 , OemToAnsi(STR0027)) // "Deseja continuar o processo para o romaneio "##"? Caso selecione a opção não, será iniciado um novo romaneio."##"Atenção"
			//If NJJ->NJJ_STATUS == "3"
			If NJJ->NJJ_STATUS $ '2|3|4'	//"3=Encerrado" ou "4-Cancelado"
				Help('' ,1,".AGRA50000001.", , ,1,0) /* Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'. */
				//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
				//Somente Romaneios com status - Pendende - Completo - podem ser alterados.					
				Return .F.
			EndIf
			oView:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oView:SetOperation(MODEL_OPERATION_INSERT)
		EndIf
	
		aCoors := FWGetDialogSize(oMainWnd)  
		
	   	oView:SetModel(oModel)
		oView:EnableControlBar(.T.)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
		oView:oModel:lModify := .T.
		
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
		oFWMVCWindow:SetTitle(STR0028) //"Dados de Pesagem do Romaneio" 
		oFWMVCWindow:SetEscClose(.T.)
		oFWMVCWindow:SetStyle(2)
		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
	
	EndIf
	
Return lRet

/*/{Protheus.doc} AGRA500P
//Rotina do botao de pesagem
@author carlos.augusto
@since 28/11/2017
@version undefined
@param oView, object, descricao
@type function
/*/
Function AGRA500P(oModel, cOrigem, cParametro)
	Local lRet 			:= .T.
	Local oView     	:= FWViewActive()
	Local oFldNJJ       := oModel:GetModel( "AGRA500_NJJ" )
	Local nNJJRECNO 	:= 0
	Local nPeso         := 0
	Local nPeso1        := 0
	Local nPeso2        := 0
	Local lPeso1        := .F.
	Local lPeso2        := .F.
	Local lPeso3		:= .F.
	
	Local nDifFisFis	:= 0
	Local oDlg 		    := Nil
	Local oCombo	    := Nil
	Local oTButt	    := Nil
	Local cCombo	    := ""
	Local nItem		    := 1
	Local lPesagManu    := .F.
	Local nOperation	:= oModel:GetOperation()
	Local cAlert		:= ""
	Local cCodPerg		:= ""	
	Local cBalanca      := ""
	Local aBalancas		:= {}
	
	Default cParametro	:= ""
	
	//Pesquisa por alguma permissao em balanca
	If IsInCallStack('GFEA523')
		__aPerBal = Nil
		aBalancas	:= AGRBalsUsr()
		If Len(aBalancas) = 1
			cBalanca := aBalancas[1]
		ElseIf Len(aBalancas) > 1
			lRet := Pergunte( "AGRA500002", .T. )
			If lRet
				cBalanca := MV_PAR01
			Else
				cBalanca := Space(TamSX3("DX6_CODBAL")[1])
			EndIF
			If Empty (cBalanca)
				MsgAlert(STR0135) //"Nenhuma balança selecionada para pesagem."
				lRet := .F.
				Return .F.
			EndIf
		Else		
			MsgAlert(STR0127)//"Não existe balança configurada para este usuário. Realize o cadastro através da rotina Usuário x Balança."
			Return .F.
		EndIf
	EndIf
	Pergunte( "AGRA500001", .F. )
	
	//--Inicializar a variavel - caso esteja null
	If __aPerBal == Nil
		__aPerBal := AGRX003E( .F., "AGRA500001" , cBalanca)
	EndIf	
	
	If Empty(__aPerBal[1]) .And. Empty(cBalanca)
//		Help('' ,1,".AGRA50000003.", , ,1,0)
		MsgAlert(STR0135)//"Nenhuma balança selecionada para pesagem."
		//"Não existe balança configurada para este usuário. Realize o cadastro através da rotina Usuário x Balança."
		lRet := .F.
		Return( .F. )
	EndIf
	
	If lRet 
		If cOrigem == "GRID"	
			nNJJRECNO := NJJ->( Recno() )
			
			nPeso1 := NJJ->( NJJ_PESO1 )
			nPeso2 := NJJ->( NJJ_PESO2 )
		Else
			nPeso1 := oModel:GetValue(  'AGRA500_NJJ', "NJJ_PESO1" )
			nPeso2 := oModel:GetValue(  'AGRA500_NJJ', "NJJ_PESO2" )
		EndIf
		
		if UPPER(cParametro) != "PESAGEM"
			lPeso1 := ( nPeso1 == 0 )
			lPeso2 := ( nPeso2 == 0 )
			lPeso3 := ( nPeso1 > 0 .And. nPeso2 > 0 )
		EndIf
		
		//Define quais das pesagens está executando
		If IsInCallStack('GFEA523')
			If __cNumPsag = 1
				lPeso1 := .T. 
				lPeso2 := .F.
			EndIf
			If __cNumPsag = 2
				lPeso1 := .F. 
				lPeso2 := .T.
			EndIf
		EndIf
				
		If oFldNJJ:GetValue("NJJ_STATUS" ) $ '2|3|4'	
//			Help('' ,1,".AGRA50000015.", , ,1,0)
			cAlert := STR0126	//Operação não permitida para Romaneios com status - Atualizado - Confirmado - Cancelado - .
			cAlert += STR0131	//Somente Romaneios com status - Pendende - Completo - podem ser alterados.
			MsgAlert(cAlert) 	//"Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'."
			Return( .F. )
		EndIf
			

		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == 4  
			
			If __cNumPsag = 3
			
				If lPeso3 .And. .Not. __aPerBal[ 4 ] //--Já possui as duas pesagens 
					oDlg 	:= TDialog():New(0,0,50,300,'',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
					oCombo 	:= TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0030, STR0031}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , 'cCombo' ) //"Primeira Pesagem"###"Segunda Pesagem"
					oTButt 	:= TButton():New( 001, 104, STR0009, oDlg, { || oDlg:End() }, 040, 016, , , .f., .t., .f., , .f., , , .f. ) //"Confirmar"
			 		oDlg:Activate( , , , .t., { | | nAcao := 1, .T. }, , { || } )
			 		
			 		If nAcao < 1; Return( ); EndIf
			 		
					If nItem = 1
						lPeso1  := .T.
						lPeso2  := .F.
					ElseIf nItem = 2
						lPeso1  := .F.
						lPeso2  := .T.
					EndIf
				EndIf  
			EndIf
			
			// Abre a tela para pesagem
			AGRX003A( @nPeso,.t., __aPerBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2 )
			
			// Se o peso lido for maior que zero
			If nPeso > 0	
				if UPPER(cParametro) == "PESAGEM"
				
					cQry := "SELECT N93_CDPERG FROM "+RetSQLName("N93")+" N93 INNER JOIN "+RetSQLName("N94")+" N94 ON N93_FILIAL = N94_FILIAL " +;
						    "   AND N93_CODTO  = N94_CODTO " +;
						    "   AND N93_CODIGO = N94_CODETP " +;
						    "   AND N93.D_E_L_E_T_ = ' ' " +;
							"   AND N94.D_E_L_E_T_ = ' ' " +;
						    " INNER JOIN "+RetSQLName("N95")+" N95 ON N94_FILIAL = N95_FILIAL " +;
						    "   AND N94_CODTO  = N95_CODTO" +;
						    "   AND N94_CODETP = N95_CODETP" +;
						    "   AND N94_QTCPES = 'T' " +;
						    "   AND N95.D_E_L_E_T_ = ' '" +;
						    " WHERE N93_FILIAL = '" + FWXFILIAL("N93") + "' " +;
						    "   AND N93_CODTO  = '" + __cTipoOp + "' "  +;
						    "   AND N93_CDPTCT = '" + GX4->GX4_CDPTCT + "' " 
				     
				    //Encontra qual pergunta deve mudar o GX5_RESPOS para respondido.
				    cCodPerg := GetDataSql(cQry)
					
					RecLock("GX4", .F.)
						GX4->GX4_QTPESO := nPeso
					MsUnlock("GX4")
					
					GX5->(dbSetOrder(1))
					if GX5->(dbSeek(FWxFilial("GX5")+GX5->GX5_NRMOV+GX5->GX5_CDPTCT+GX5->GX5_SEQ+cCodPerg))
						RecLock("GX5", .F.)
							GX5->GX5_RESPOS := "1"
						MsUnlock("GX5")
					endIf
				endIf
			
				/** Executa primeira pesagem ou repesagem do primeiro peso **/
				If lPeso1
					If nPeso <> nPeso2 // Consistência para não permitir 2 pesos iguais		
						If cOrigem == "VIEW"	
							IF Empty(oFldNJJ:GetValue("NJJ_DATPS1"))
								oFldNJJ:SetValue( "NJJ_DATPS1", dDataBase )
							EndIf	
							
							If Empty(oFldNJJ:GetValue("NJJ_HORPS1"))
								oFldNJJ:SetValue( "NJJ_HORPS1", Substr( Time(), 1, 5 ) )
							EndIf
							
							oFldNJJ:SetValue( "NJJ_PESO1" , nPeso )
							oFldNJJ:SetValue( "NJJ_MODPS1", IIf( lPesagManu, "M", "A" ) )
						
							oFldNJJ:SetValue( "NJJ_STSPES", IIf( lPeso3, "2", "1" ) )	//Status Pesagem  =	"0=Sem Pesagem", "1=Primeira Pesagem" e "2=Segunda Pesagem"
							oFldNJJ:SetValue( "NJJ_STATUS", IIf( lPeso3, "1", "0" ) )	//Status Romaneio = "0=Pendente" e "1=Completo"							
						Else
							BEGIN TRANSACTION
							dbSelectArea( "NJJ" )
							NJJ->(DbGoTo(nNJJRECNO))
							If RecLock( "NJJ", .F. )
								If Empty(NJJ->NJJ_DATPS1)
									NJJ->NJJ_DATPS1 := dDataBase
								EndIf
							
								If Empty(NJJ->NJJ_HORPS1)
									NJJ->NJJ_HORPS1 := Substr( Time(), 1, 5 )
								EndIf	 
							
								NJJ->NJJ_PESO1  := nPeso
								NJJ->NJJ_MODPS1 := IIf( lPesagManu, "M", "A" )
							
								NJJ->NJJ_STSPES := IIf( lPeso3, "2", "1" )	//Status Pesagem  =	"0=Sem Pesagem", "1=Primeira Pesagem" e "2=Segunda Pesagem"
								NJJ->NJJ_STATUS := IIf( lPeso3, "1", "0" )	//Status Romaneio = "0=Pendente" e "1=Completo" 								
								NJJ->(msUnLock())
							EndIf
							END TRANSACTION
						Endif
								
						If lPeso3
							If cOrigem == "VIEW"
								oFldNJJ:SetValue( 'NJJ_PSSUBT', Abs(nPeso - nPeso2))

								oFldNJJ:LoadValue( 'NJJ_PSLIQU', Abs(nPeso - nPeso2) - (oFldNJJ:GetValue('NJJ_PSDESC') + oFldNJJ:GetValue('NJJ_PESEMB') ) )
								oFldNJJ:LoadValue( 'NJJ_PESO3',  Abs(nPeso - nPeso2) - (oFldNJJ:GetValue('NJJ_PSDESC') + oFldNJJ:GetValue('NJJ_PESEMB') ) )
								
								If !Empty(oModel:GetValue( 'AGRA500_NJJ', 'NJJ_DOCNUM' ))
									nDifFisFis := oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' ) - oModel:GetValue( 'AGRA500_NJJ', 'NJJ_QTDFIS' )
									oModel:SetValue('AGRA500_NJJ', 'NJJ_DIFFIS', nDifFisFis)
								EndIf					
							Else
								BEGIN TRANSACTION
								dbSelectArea( "NJJ" )
								NJJ->(DbGoTo(nNJJRECNO))
								If RecLock( "NJJ", .f. )
									NJJ->NJJ_PSSUBT := Abs( nPeso - nPeso2 )
									
									NJJ->NJJ_PSLIQU := Abs( nPeso - nPeso2) - (NJJ->NJJ_PSDESC + NJJ->NJJ_PESEMB)    
									NJJ->NJJ_PESO3  := Abs( nPeso - nPeso2) - (NJJ->NJJ_PSDESC + NJJ->NJJ_PESEMB)  
									If !(Empty(NJJ->NJJ_DOCNUM))
										nDifFisFis := (NJJ->NJJ_PSLIQU) - (NJJ->NJJ_QTDFIS)
										NJJ->NJJ_DIFFIS := 	nDifFisFis	
									EndIf	
									NJJ->(msUnLock())
									
									//--Recalcula as quantidades e descontos quando a pesagem é realizada no Browser
									//--Função no fonte AGRX500D
									//AGRX500CBW()
									OGA250DCBrw() // Atualiza descontos
								Endif				
								END TRANSACTION					
							EndIf
							
							
						EndIf
					
						If nOperation == MODEL_OPERATION_UPDATE .AND. (cOrigem == "GRID" .OR.  oFldNJJ:GetValue( 'NJJ_PESO1' ) > 0)
							AGRGRAVAHIS(,,,,{"NJJ",FWxFilial("NJJ")+FwFldGet('NJJ_CODROM'),"4",STR0030})
						EndIF	
					Else
						Help(, , STR0064, ,STR0065, 1, 0 ) //"O romaneio não pode receber 2 pesagens iguais."
						Return( Nil )
					Endif	
					
				Else	
					If lPeso2
						If nPeso <> nPeso1 // Consistência para não permitir 2 pesos iguais
							If cOrigem == "VIEW"	
								If Empty(oFldNJJ:GetValue("NJJ_DATPS2"))
									oFldNJJ:SetValue( "NJJ_DATPS2", dDataBase )
								EndIf
								
								If Empty(oFldNJJ:GetValue("NJJ_HORPS2"))
									oFldNJJ:SetValue( "NJJ_HORPS2", Substr( Time(), 1, 5 ) )
								EndIf
								
								oFldNJJ:SetValue( "NJJ_PESO2" , nPeso )
								oFldNJJ:SetValue( "NJJ_MODPS2", IIf( lPesagManu, "M", "A" ) )
								
								oFldNJJ:SetValue( "NJJ_STSPES", "2" )	
								oFldNJJ:SetValue( "NJJ_STATUS", "1" ) //1=Completo
																						
								oFldNJJ:SetValue( "NJJ_PSSUBT", Abs( nPeso - nPeso1 ) )	
								oFldNJJ:SetValue( 'NJJ_PSLIQU', Abs(nPeso - nPeso1) - (oFldNJJ:GetValue('NJJ_PSDESC') + oFldNJJ:GetValue('NJJ_PESEMB') ) )
								oFldNJJ:LoadValue( 'NJJ_PESO3', Abs(nPeso - nPeso1) - (oFldNJJ:GetValue('NJJ_PSDESC') + oFldNJJ:GetValue('NJJ_PESEMB') ) )
								
								If !Empty(oModel:GetValue( 'AGRA500_NJJ', 'NJJ_DOCNUM' ))
									nDifFisFis := oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' ) - oModel:GetValue( 'AGRA500_NJJ', 'NJJ_QTDFIS' )
									oFldNJJ:SetValue( 'NJJ_DIFFIS', nDifFisFis)
								EndIf
							Else
								BEGIN TRANSACTION
								dbSelectArea( "NJJ" )
								NJJ->(DbGoTo(nNJJRECNO))
								If RecLock( "NJJ", .f. )
									If Empty(NJJ->( NJJ_DATPS2 ))
										NJJ->( NJJ_DATPS2 ) := dDataBase
									EndIf
									
									If Empty(NJJ->( NJJ_HORPS2 ))
										NJJ->( NJJ_HORPS2 ) := Substr( Time(), 1, 5 )
									EndIf
									 
									NJJ->( NJJ_PESO2  ) := nPeso
									NJJ->( NJJ_MODPS2 ) := IIf( lPesagManu, "M", "A" )

									NJJ->( NJJ_STSPES ) := "2" 
									NJJ->( NJJ_STATUS ) := "1" //1=Completo
																		
									NJJ->( NJJ_PSSUBT ) := Abs( nPeso - nPeso1 ) 
									NJJ->( NJJ_PSLIQU ) := Abs( nPeso - nPeso1) - (NJJ->NJJ_PSDESC + NJJ->NJJ_PESEMB)
									NJJ->( NJJ_PESO3 )  := Abs( nPeso - nPeso1) - (NJJ->NJJ_PSDESC + NJJ->NJJ_PESEMB)
									
									If !(Empty(NJJ->NJJ_DOCNUM))
										nDifFisFis := (NJJ->NJJ_PSLIQU) - (NJJ->NJJ_QTDFIS)
										NJJ->NJJ_DIFFIS := 	nDifFisFis	
									EndIf
									NJJ->(msUnLock())
								EndIf
									
									//--Recalcula as quantidades e descontos quando a pesagem é realizada no Browser
									//--Função no fonte AGRX500D
									//AGRX500CBW()
									OGA250DCBrw() // Atualiza descontos
								END TRANSACTION
							EndIf
		
							If nOperation == MODEL_OPERATION_UPDATE .AND. (cOrigem == "GRID" .OR. oFldNJJ:GetValue( 'NJJ_PESO1' ) > 0)
								AGRGRAVAHIS(,,,,{"NJJ",FWxFilial("NJJ")+FwFldGet('NJJ_CODROM'),"4",STR0031})
							EndIF
						Else
							Help(, , STR0021, , STR0065, 1, 0 ) //"O romaneio não pode receber 2 pesagens iguais."
							Return( Nil )
						Endif	
					EndIf			
				EndIf
			EndIf
		EndIF
	EndIf

	If .NOT. __lF10Exec
		oView:lModify := .T.
		oView:Refresh()
	ElseIF !IsInCallStack('GFEA523')
		NJJ->( DbGoTo( nNJJRECNO ) )
		If IsInCallStack('AGRA500') .AND. cOrigem == "GRID"
		   __oBrowseA500:Refresh()

		ElseIf IsInCallStack('AGRA500') .AND. cOrigem == "VIEW"
		   oView:Refresh()
		   
		EndIf   
	Endif

Return lRet


/*/{Protheus.doc} VldDesc
//Atualiza o peso liquido
@author carlos.augusto
@since 28/11/2017
@version undefined

@type function
/*/
Function A500VldDesc()
	Local oModel 		:= FWModelActive()
	Local nPeso1		:= oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PESO1' )
	Local nPeso2		:= oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PESO2' )
	Local nPsTara       := oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PESEMB' )
	Local nPsDesc		:= oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSDESC' )
	Local nPsSub		:= oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSSUBT' )
	Local nPsLiq		:= oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' )
	
	If !Empty(nPeso1) .And. !Empty(nPeso2)
		If nPsLiq <> (nPsSub - nPsDesc)
			If nPeso1 > nPeso2
				oModel:LoadValue( 'AGRA500_NJJ', 'NJJ_PSLIQU',(nPeso1 - nPeso2 - nPsDesc - nPsTara ))
				oModel:LoadValue( 'AGRA500_NJJ', 'NJJ_PESO3', oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' ) ) 
			Else
				oModel:LoadValue( 'AGRA500_NJJ', 'NJJ_PSLIQU',(nPeso2 - nPeso1 - nPsDesc - nPsTara ))
				oModel:LoadValue( 'AGRA500_NJJ', 'NJJ_PESO3', oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' ) ) 
			Endif
		EndIf
	EndIf
	

Return .T.

/*/{Protheus.doc} AGRA500Tip
//Função de picture variavel de CPF de Motorista
@author bruna.rocio
@since 24/11/2017
@version undefined

@type function
/*/
Function AGRA500Tip()
	Local cMasc := ""
	
	If !Empty(M->NJJ_CGC) .And. Len(AllTrim(M->NJJ_CGC))<14
		cMasc := "@R 999.999.999-99999%C" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
	Else
		cMasc := "@R 99.999.999/9999-99%C"
	EndIf

Return cMasc

/*/{Protheus.doc} A500VldPlaca
//Validação de placa por motorista
@author bruna.rocio
@since 28/11/2017
@version undefined
@type function
/*/
Function A500VldPlaca()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local cPlaca	:= oNJJ:GetValue( "NJJ_PLACA" )
	
	If .Not. Empty(cPlaca)
		lRet := ExistCpo('DA3', cPlaca, 3)
	EndIf
	
	RestArea(aArea) 
Return lRet

/*/{Protheus.doc} AGRA500PRO
//Auxilia o filtro da consulta padrao NN4NJJ
@author carlos.augusto
@since 29/11/2017
@version undefined
@type function
/*/
Function AGRA500PRO()
	dbSelectArea('NNV')
	dbSetOrder(1)
	lRet := msSeek(fwxFilial('NNV')+M->NJJ_CODPRO+NN4->NN4_CODVAR)

Return lRet

/*/{Protheus.doc} A500VldSafra
//Validação da safra 
@author bruna.rocio
@since 28/11/2017
@version undefined
@type function
/*/
Function A500VldSafra()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ		:= oModel:GetModel("AGRA500_NJJ")
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	Local cCtrlLote := Posicione('SB1',1,fwxFilial('SB1')+FWFldGet("NJJ_CODPRO"),'B1_RASTRO')
	
	A500ClFld("NJJ_CODSAF")
	lRet := Vazio() .Or. ExistCpo('NJU')
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_CODSAF", oNJJ:GetValue( "NJJ_CODSAF" ) )
			If cCtrlLote = "L"
				oNJM:SetValue( "NJM_LOTCTL", oNJJ:GetValue( "NJJ_CODSAF" ) )
			Endif
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500VldPrtor
//Valida entidade para AGRA500
@author carlos.augusto
@since 01/12/2017
@version undefined
@type function
/*/
Function A500VldPrtor()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	A500ClFld("NJJ_CODENT")
	lRet := ExistCpo("NJ0",FWFldGet("NJJ_CODENT")+IIF(!Empty(FWFldGet("NJJ_LOJENT")),FWFldGet("NJJ_LOJENT"),""))

	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_CODENT", oNJJ:GetValue( "NJJ_CODENT" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			//oView:Refresh()
		EndIf

		//se for entrada ou saída por transferência
		If oNJJ:GetValue("NJJ_TIPO") $ "A|B"
			//verifica se gatilha TES inteligente
			A500TESINT(oNJJ, oNJM)
		EndIf	
	EndIF
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500StClas()
//TODO Descrição auto-gerada.
@author ana.olegini
@since 22/05/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A500StClas()
	Local cStsClas := ''
	Local lAlgodao := If(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	
	If lAlgodao
		cStsClas := "1"	//Classificado - algodão não possui tabela de classificação.
	Else
		cStsClas := "0" //
	EndIf

Return cStsClas

/*/{Protheus.doc} A500VldTes
//TODO Descrição auto-gerada.
@author silvana.torres
@since 14/02/2018
@version undefined

@type function
/*/
Function A500VldTes()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	lRet := Vazio() .Or. ExistCpo('SF4')
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_TES", oNJJ:GetValue( "NJJ_TES" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500VldFaz
//Valida fazenda para AGRA500
@author marina.muller
@since 11/01/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500VldFaz()
	Local lRet   := .T.
	Local aArea  := GetArea()
	A500ClFld("NJJ_FAZ")
	A500ClFld("NJJ_NMFAZ")
	lRet := Vazio() .Or. ExistCpo("NN2",FWFldGet("NJJ_CODENT")+FWFldGet("NJJ_LOJENT")+FWFldGet("NJJ_FAZ"),3)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500VldTal
//Valida talhão para AGRA500
@author marina.muller
@since 11/01/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500VldTal()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	
	A500ClFld("NJJ_DESTAL")	
	A500ClFld("NJJ_TALHAO")
	
	lRet := Vazio() .Or. ExistCpo("NN3",FWFldGet("NJJ_CODSAF")+FWFldGet("NJJ_FAZ")+FWFldGet("NJJ_CODPRO")+FWFldGet("NJJ_TALHAO"),3)
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_TALHAO", oNJJ:GetValue( "NJJ_TALHAO" ) )
	
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF	
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500VldLoja
//Validação loja da entidade
@author bruna.rocio
@since 28/11/2017
@version undefined
@type function
/*/
Function A500VldLoja()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	lRet := ExistCpo('NJ0',FWFldGet("NJJ_CODENT") +FWFldGet("NJJ_LOJENT"))
		
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_LOJENT", oNJJ:GetValue( "NJJ_LOJENT" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			//oView:Refresh()
		EndIf

		//se for entrada ou saída por transferência
		If oNJJ:GetValue("NJJ_TIPO") $ "A|B"
			//verifica se gatilha TES inteligente
			A500TESINT(oNJJ, oNJM)
		EndIf	
	EndIF	
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} A500VldLoc
//Valid local
@author ana.olegini
@since 13/02/2018
@version undefined

@type function
/*/
Function A500VldLoc()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	A500ClFld("NJJ_LOCAL")
	lRet := Vazio().Or.ExistCpo('NNR', FWFldGet("NJJ_LOCAL") )
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_LOCAL", oNJJ:GetValue( "NJJ_LOCAL" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} A500VldPrdt
//Valid produto
@author carlos.augusto
@since 01/12/2017
@version undefined

@type function
/*/
Function A500VldPrdt()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	A500ClFld("NJJ_CODPRO")
	lRet := Vazio() .Or. ExistCpo('SB1', M->NJJ_CODPRO)
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_CODPRO", oNJJ:GetValue("NJJ_CODPRO") )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf

		//se for entrada ou saída por transferência
		If oNJJ:GetValue("NJJ_TIPO") $ "A|B"
			//verifica se gatilha TES inteligente
			A500TESINT(oNJJ, oNJM)
		EndIf	
	EndIF
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500ClFld
//Limpa campos
@author carlos.augusto
@since 01/12/2017
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Function A500ClFld(cCampo)
	Local oModel 	:= FwModelActive()
	Local oModelNJJ	:=  IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP") .Or. IsInCallStack("AX500NATU") .Or. IsInCallStack("AX500FCONF"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	
	Do Case
		Case "NJJ_CODSAF" $ cCampo .Or. "NJJ_CODENT" $ cCampo
			oModelNJJ:SetValue("NJJ_CODVAR", Space(TamSX3("NJJ_CODVAR")[01]))
			oModelNJJ:SetValue("NJJ_TALHAO", Space(TamSX3("NJJ_TALHAO")[01]))
			oModelNJJ:SetValue("NJJ_FAZ",    Space(TamSX3("NJJ_FAZ")[01]))
		Case "NJJ_CODPRO" $ cCampo
			oModelNJJ:SetValue("NJJ_CODVAR", Space(TamSX3("NJJ_CODVAR")[01]))
			oModelNJJ:SetValue("NJJ_TALHAO", Space(TamSX3("NJJ_TALHAO")[01]))
			oModelNJJ:SetValue("NJJ_FAZ",    Space(TamSX3("NJJ_FAZ")[01]))
		Case "NJJ_FAZ" $ cCampo
			oModelNJJ:SetValue("NJJ_CODVAR", Space(TamSX3("NJJ_CODVAR")[01]))
			oModelNJJ:SetValue("NJJ_TALHAO", Space(TamSX3("NJJ_TALHAO")[01]))
		Case "NJJ_TALHAO" $ cCampo
			oModelNJJ:SetValue("NJJ_CODVAR", Space(TamSX3("NJJ_CODVAR")[01]))
		
		Case "NJJ_NMFAZ" $ cCampo
			oModelNJJ:LoadValue("NJJ_NMFAZ",  Space(TamSX3("NJJ_NMFAZ")[01]))
		Case "NJJ_DESTAL" $ cCampo
			oModelNJJ:LoadValue("NJJ_DESTAL", Space(TamSX3("NJJ_DESTAL")[01]))
		Case "NJJ_DESVAR" $ cCampo
			oModelNJJ:LoadValue("NJJ_DESVAR", Space(TamSX3("NJJ_DESVAR")[01]))
				
		Otherwise
			Return .T.

	EndCase

Return .T.

/*/{Protheus.doc} A500VldCgc
//Valid para CGC
@author carlos.augusto
@since 04/12/2017
@version undefined
@type function
/*/
Function A500VldCgc()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local cCGC		:= oNJJ:GetValue( "NJJ_CGC" )
	
	If .Not. Empty(cCGC)
		cCGC := StrTran(cCGC, ".", "")
		cCGC := StrTran(cCGC, "/", "")
		cCGC := StrTran(cCGC, "-", "")
		
		lRet := ExistCpo('DA4', cCGC, 3)
	EndIf
	
	RestArea(aArea) 
Return lRet


/*/{Protheus.doc} A500VldNf
//Validação da NF/serie digitada
@author silvana.torres
@since 01/12/2017
@version undefined

@type function
/*/
Function A500VldNf()

	Local lRet  		:= .F.
	Local aArea 		:= GetArea()
	Local cQry  		:= GetNextAlias()
	Local oView			:= FwViewActive()
	Local oModel 		:= FwModelActive()
	Local oNJJ			:= oModel:GetModel("AGRA500_NJJ")
	Local oNJM	 		:= oModel:GetModel( "AGRA500_NJM" )
	Local nDifFisFis 	:= 0	
	Local nLinha		:= oNJM:GetLine()
	Local nX	 		:= 0
	
	if oModel:GetValue( 'AGRA500_NJJ', 'NJJ_TPFORM' ) == "1" 
		if !empty(FwFldGet('NJJ_DOCNUM')) .And. !empty(FwFldGet('NJJ_DOCSER'))
			 BeginSQL Alias cQry
				Select D1_EMISSAO, D1_VUNIT, D1_TOTAL, D1_QUANT, F1_ESPECIE, F1_EST
				  from %Table:SD1% SD1, %Table:SF1% SF1  
				 WHERE SD1.%notDel%
				   AND SD1.D1_DOC 	= %exp:PadR(FwFldGet('NJJ_DOCNUM'), TamSX3("NJJ_DOCNUM")[1] ) %
				   AND SD1.D1_SERIE	= %exp:PadR(FwFldGet('NJJ_DOCSER'), TamSX3("NJJ_DOCSER")[1] ) %
				   AND SF1.%notDel%
				   AND SF1.F1_FILIAL	= SD1.D1_FILIAL
				   AND SF1.F1_DOC 		= SD1.D1_DOC
				   AND SF1.F1_SERIE 	= SD1.D1_SERIE 
				   AND SF1.F1_FORNECE   = SD1.D1_FORNECE
				   AND SF1.F1_LOJA 		= SD1.D1_LOJA
				   AND SF1.F1_FORMUL	= SD1.D1_FORMUL
				   AND NOT EXISTS (SELECT 1 
				                     FROM %Table:NJJ% NJJ 
				                    WHERE NJJ.NJJ_DOCNUM  = SF1.F1_DOC 
				                      AND NJJ.NJJ_CODROM <>  %exp:PadR(FwFldGet('NJJ_CODROM'), TamSX3("NJJ_CODROM")[1] ) % 
				                      AND NJJ.NJJ_DOCSER  = SF1.F1_SERIE )
			EndSql
			
			dbSelectArea(cQry)
			(cQry)->(dbGoTop())
			
			If (cQry)->(!Eof())
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_DOCEMI',StoD((cQry)->D1_EMISSAO))
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_VLRUNI',(cQry)->D1_VUNIT)
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_VLRTOT',(cQry)->D1_TOTAL)
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_QTDFIS',(cQry)->D1_QUANT)
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_DOCESP',(cQry)->F1_ESPECIE)
				oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_EST'   ,(cQry)->F1_EST)
				lRet := .T.
				
				nDifFisFis := oModel:GetValue( 'AGRA500_NJJ', 'NJJ_PSLIQU' ) - oModel:GetValue( 'AGRA500_NJJ', 'NJJ_QTDFIS' )
				oModel:SetValue('AGRA500_NJJ', 'NJJ_DIFFIS', nDifFisFis)
			Endif
		endIf
		
		if Empty(FwFldGet('NJJ_DOCNUM')) .Or. Empty(FwFldGet('NJJ_DOCSER'))
			lRet := .T.
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_DOCEMI', CtoD( "  /  /  " ))
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_VLRUNI', 0)
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_VLRTOT', 0)
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_QTDFIS', 0)
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_DOCESP', Space( TamSX3( "NJJ_DOCESP" )[1] ))
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_EST'   , Space( TamSX3( "NJJ_EST" )[1] ))
			oModel:GetModel('AGRA500_NJJ'):LoadValue('NJJ_DIFFIS', 0)
		EndIf
	else
		lRet := .T.
	endIf
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:LoadValue( "NJM_DOCNUM", oNJJ:GetValue( "NJJ_DOCNUM" ) )
			oNJM:LoadValue( "NJM_DOCSER", oNJJ:GetValue( "NJJ_DOCSER" ) )
			oNJM:LoadValue( "NJM_DOCEMI", oNJJ:GetValue( "NJJ_DOCEMI" ) )
			oNJM:LoadValue( "NJM_VLRUNI", oNJJ:GetValue( "NJJ_VLRUNI" ) )
			oNJM:LoadValue( "NJM_VLRTOT", oNJJ:GetValue( "NJJ_VLRTOT" ) )
			oNJM:LoadValue( "NJM_QTDFIS", oNJJ:GetValue( "NJJ_QTDFIS" ) )
			oNJM:LoadValue( "NJM_DOCESP", oNJJ:GetValue( "NJJ_DOCESP" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea) 
	
Return lRet

/*/{Protheus.doc} A500VldTipo
//Valid Tipo
@author brunosilva
@since 04/12/2017
@version undefined

@type function
/*/
Function A500VldTipo()
	Local lRet   	:= .F.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()	
	Local oNJJ		:= oModel:GetModel("AGRA500_NJJ")
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX		:= 0
		
	lRet := ExistCpo('SX5', 'K5'+M->NJJ_TIPO) .And. A500ACTR() 
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_TIPO", oNJJ:GetValue( "NJJ_TIPO" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O' .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF	
	
	RestArea(aArea) 
Return lRet 

/*/{Protheus.doc} A500VldVar
//Validação da variedade.
@author brunosilva
@since 11/12/2017
@version undefined

@type function
/*/
Function A500VldVar()
	Local lRet   := .F.
	Local aArea  := GetArea()
	A500ClFld("NJJ_DESVAR")
	lRet := ExistCPO("NNV",M->(NJJ_CODPRO+NJJ_CODVAR),1) .AND. ExistCPO("NN4",M->(NJJ_CODSAF+NJJ_FAZ+NJJ_TALHAO+NJJ_CODVAR),2)  .Or. Vazio()
	RestArea(aArea) 
Return lRet

/*/{Protheus.doc} A500Etap
//-- Verifica campos da etapa para validação do confirmar

@author 	ana.olegini
@since 		22/01/2018
@version 	P12
/*/
Function A500Etap()
	Local aEtapas 	:= {}

	__cTipoOp := IIF(ValType(__cTipoOp) == "N", cValtoChar(__cTipoOp), __cTipoOp) 
	
	//-- Realiza busca na tabela de Etapas 
	dbSelectArea("N93")
	dbSetOrder(1)
	If MsSeek(FWxFilial("N93") + __cTipoOp )
		While N93->(!Eof()) .AND. N93->N93_CODTO == __cTipoOp  
			If N93->N93_OK == .T.

				//-- Realiza busca na tabela de Campos da Etapa	
				dbSelectArea("N95")
				dbSetOrder(1)
				If MsSeek(FWxFilial("N95")+__cTipoOp+N93->N93_CODIGO)
				
					While N95->(!Eof()) .AND. N95->N95_CODTO == __cTipoOp	.AND. N95->N95_CODETP == N93->N93_CODIGO 
						//--Se o campo é obrigatório 
						IF N95->N95_OBRIGA == '1'	//1=Sim#2=Não
							aadd(aEtapas, {N95->N95_CAMPO, N95->N95_CODETP}) 
						EndIf
						N95->(dbSkip())
					EndDo
				EndIF
			EndIf 
			N93->(dbSkip())
		EndDo
	EndIF
	N95->(dbCloseArea())
	N93->(dbCloseArea())
	
Return aEtapas

Function VldF10(cTpOp)
	Local lRet      := .F.
	Local cfilN94 := FWxFilial("N94")
	
	dbSelectArea('N94')
	N94->(dbSetOrder(1))
	N94->(msSeek(FWxFilial("N94")+cTpOp))
	While !N94->(EOF())  .AND. N94->N94_FILIAL == cfilN94 .And. N94->N94_CODTO == cTpOp
		If N94->N94_QTCPES
			lRet := .T.
			exit
		EndIf   
		N94->(dbSkip())
	End      
Return lRet

/*/{Protheus.doc} AGRA500ORD
//Valida Ordem de Colheita para AGRA500 e OGA250. Campo NJJ_ORDCLT
@author carlos.augusto
@since 31/01/2018
@version undefined
@type function
/*/
Function AGRA500ORD(cOrdCol, _cCLTTEMP)
	Local lRet		:= .T.
	Local oModel 	:= FWModelActive()
	Local aArea		:= GetArea()
	Local aLines	:= FWSaveRows()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	Local cCodProNJJ := ""
	Local cTalhao   := ""
	Local nSubs     := 0
	Local cSafra    := ""    
	
	If !Empty(cOrdCol)
	
		If !FWHasEAI( "AGRA530", .T., .F., .T. )
			lRet := .F.
			//#"Integração entre Protheus x PIMS não foi efetuada." - #"Verifique as configurações de integração da mensagem GetHarvestOrder."
			Help(, , STR0048, , STR0092 + STR0093, 1, 0 )
		EndIf
		
		If lRet
			If !(_cCLTTEMP)->(RecCount()) > 0
				AGRA530ODC(.F., @_cCLTTEMP)
			EndIf
		
			dbSelectArea(_cCLTTEMP)
			(_cCLTTEMP)->(dbSetOrder(1))
		
			//Valida Ordem de Colheita			
            lRet := (_cCLTTEMP)->(msSeek(cOrdCol))
			If !lRet
				Help('' ,1,".AGRA50000009.", , ,1,0) //"Ordem de Colheita não encontrada.."Verifique o cadastro de Ordens de Colheita.
				lRet := .F.
			EndIf            
		               
			//Busca Safra Vinculada a Ordem de Produção amarrada a Ordem de Colheita
			If lRet
				//Valida OP
                If !Empty(alltrim((_cCLTTEMP)->CODOPS))
                    dbSelectArea("SC2")
                    SC2->(dbSetOrder(9)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_PRODUTO 
                    lRet := DbSeek(fwxFilial("SC2")+ (_cCLTTEMP)->CODOPS + StrZero( 1 , TamSX3('C2_ITEM')[1]) + (_cCLTTEMP)->CODPRO)
                    
                    If lRet
                        oNJJ:LoadValue( "NJJ_NUMOP", (_cCLTTEMP)->CODOPS + SC2->C2_ITEM + SC2->C2_SEQUEN)
                        cSafra := SC2->C2_CODSAF
                        If .Not. Empty(cSafra)
                            oNJJ:LoadValue( "NJJ_CODSAF", cSafra )                        
                        EndIf
                    Else
                        Help('' ,1,".AGRA50000013.", , ,1,0) //"Não foi encontrada Ordem de Produção com o Produto informado. Verifique o cadastro de Ordens de Produção.
                        lRet := .F.
                    EndIf
                    SC2->(dbCloseArea())
                EndIf				

                If Empty(oNJJ:GetValue( "NJJ_CODSAF" ))
					lRet := .F.
					Help('' ,1,".AGRA50000010.", , ,1,0) //"O campo Safra não foi preenchido. Favor preencher o campo de Safra para realizarmos as valições de Ordem de Colheta.
				EndIf
			EndIf
		
			//Valida Fazenda
			If lRet
				dbSelectArea("NN2")
				NN2->(dbSetOrder(2))//Fazenda
				lRet := NN2->(DbSeek(fwxFilial("NN2")+ (_cCLTTEMP)->CODFAZ))
				If lRet 
					If .Not. Empty(oNJJ:GetValue( "NJJ_CODENT" ))
						NN2->(dbSetOrder(3))//NN2_FILIAL+NN2_PRDTOR+NN2_LJPRO+NN2_CODIGO
						lRet := DbSeek(fwxFilial("NN2") + oNJJ:GetValue( "NJJ_CODENT" ) + oNJJ:GetValue( "NJJ_LOJENT" ) + (_cCLTTEMP)->CODFAZ)
						If .Not. lRet
							Help('' ,1,".AGRA60100002.", , ,1,0) //"Não foi encontrada a Entidade vinculada com a fazenda informada na Ordem de Colheita. Verifique o cadastro de Fazendas."
							lRet := .F.
						EndIf
					EndIf
					If lRet
						oNJJ:LoadValue( "NJJ_FAZ", (_cCLTTEMP)->CODFAZ )
						oNJJ:LoadValue( "NJJ_NMFAZ", NN2->NN2_NOME )
					EndIf
				Else
					AgrHelp(STR0021, STR0154 + alltrim((_cCLTTEMP)->CODFAZ), STR0155) //"Não foi encontrada a Fazenda informada na Ordem de Colheita. Código da Fazenda: " "Verifique o cadastro de Fazendas."
					lRet := .F.
				EndIf
				NN2->(dbCloseArea())
			EndIf
				
			//Função para gatilhar talhão em variedade com base em safra, ativo e variedade
			//Num futuro o ideal é solicitar ao PIMS que envie junto a OC também o código do periodo
			//a qual se refere
			If lRet
				//Calcula o tamanho necessário do substring
				nSubs   := Len(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL))
				//Prepara a informação do talhão com setor + talhão PIMS
				cTalhao := AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL)
				
				//A query busca o último talhão que atende as informações parciais de setor e talhão pims
				//validadas junto a safra, produto, fazenda e variedade especifica atrelada a OC, além de 
				//garantir que o talhão não esteja fechado, tendo em vista que processualmente, se já estivermos 
				//trabalhando com a OC de outro talhão com o mesmo código aberto
				BeginSql Alias "QryTLVar"
					Select * From %Table:NN3% NN3
					Inner Join %Table:NN4% NN4
						On NN4.%notDel%
					   And NN4.NN4_FILIAL = %xFilial:NN4%	
					   And NN4.NN4_SAFRA  = NN3.NN3_SAFRA
					   And NN4.NN4_FAZ    = NN3.NN3_FAZ
					   And NN4.NN4_TALHAO = NN3.NN3_TALHAO
						Where NN3.%notDel%
						  and NN3.NN3_FILIAL = %xFilial:NN3%
						  and NN3.NN3_SAFRA  = %exp:oNJJ:GetValue('NJJ_CODSAF')% //Safra da OP relacionada a OC
						  and NN3.NN3_FAZ    = %exp:(_cCLTTEMP)->CODFAZ%
						  and SUBSTRING(NN3.NN3_TALHAO,1,%exp:nSubs%) = %exp:cTalhao%
						  and NN3.NN3_CODPRO = %exp:(_cCLTTEMP)->CODPRO%
						  and NN3.NN3_FECHAD = 'N'					  
				EndSql		  
				
				If QryTLVar->(!Eof())
					oNJJ:LoadValue( "NJJ_TALHAO", QryTLVar->NN3_TALHAO)
					//oNJJ:LoadValue( "NJJ_DESTAL", QryTLVar->NN3_DESCRI )	
					oNJJ:LoadValue( "NJJ_CODVAR", (_cCLTTEMP)->CODVAR)
					//oNJJ:LoadValue( "NJJ_DESVAR", Posicione('NNV',1,fwxFilial('NNV')+(_cCLTTEMP)->CODPRO+(_cCLTTEMP)->CODVAR, NNV->NNV_DESCRI ))
				Else
					Help('' ,1,".AGRA50000011.", , ,1,0) //"Não foi encontrado o Talhão informado na Ordem de Colheita. Verifique o cadastro de Talhões
					lRet := .F.
				EndIf
				
				QryTLVar->(dbCloseArea())
			EndIf	
			//Fim tratamento talhão + variedade
					
			
			If IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP")
				cCodProNJJ := Posicione("NCB",1,FWxFilial("NCB")+__cTipoOp+(_cCLTTEMP)->CODPRO,"NCB_CODPRO")
				If .Not. Empty(cCodProNJJ) .And. cCodProNJJ != (_cCLTTEMP)->CODPRO
					//#Produto do Tipo de Operação de Romaneio diferente da Ordem de Colheita 
					//#Verifique o cadastro de Tipo de Operação de Romaneio ou a Ordem de Colheita informada.
					Help('' ,1,".AGRA50000019.", , ,1,0) 
					lRet := .F.
				EndIf
			ENdIf
			
			//Valida Produto
			If lRet
				dbSelectArea("SB1")
				dbSetOrder(1) //B1_FILIAL+B1_COD
				lRet := DbSeek(fwxFilial("SB1")+ (_cCLTTEMP)->CODPRO)
				
				If lRet
					oNJJ:LoadValue( "NJJ_CODPRO", (_cCLTTEMP)->CODPRO)
				Else
					Help('' ,1,".AGRA50000017.", , ,1,0) //"Não foi encontrado o Produto informado na Ordem de Colheita. Verifique o cadastro de Produtos"
					lRet := .F.
				EndIf
				SB1->(dbCloseArea())
			EndIf
			
			If !lRet
				If Empty(cCodProNJJ)
					oNJJ:LoadValue( "NJJ_CODPRO", Space(TamSx3("NJJ_CODPRO")[1]) )
				EndIf
				oNJJ:LoadValue( "NJJ_FAZ",    Space(TamSx3("NJJ_FAZ")[1]) )
				oNJJ:LoadValue( "NJJ_TALHAO", Space(TamSx3("NJJ_TALHAO")[1]) )
				oNJJ:LoadValue( "NJJ_DESTAL", Space(TamSx3("NJJ_DESTAL")[1]) )
				oNJJ:LoadValue( "NJJ_CODVAR", Space(TamSx3("NJJ_CODVAR")[1]) )
				oNJJ:LoadValue( "NJJ_DESVAR", Space(TamSx3("NJJ_DESVAR")[1]) )
				oNJJ:LoadValue( "NJJ_NUMOP",  Space(TamSx3("NJJ_NUMOP")[1]) )
			EndIf
		EndIf
	ElseIf .Not. IsInCallStack("AGRA500") .And. .Not. IsInCallStack("AGRA500POP")
		oNJJ:LoadValue( "NJJ_NUMOP",     Space(TamSx3("NJJ_NUMOP")[1]) )
	EndIf
	RestArea(aArea)
	FwRestRows(aLines)
Return lRet



/*/{Protheus.doc} A500Class
//Funcao para apresentar os dados de classificacao
@author carlos.augusto
@since 07/02/2018
@version undefined
@param cCodRom, char, Codigo do romaneio
@param cCodTab, char, tabela de classificacao
@param lComp, logical, informa se esta executando componentizada
@type function
/*/
Function A500Class(cCodRom, cCodTab, lComp)
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oModel500	:= FWLoadModel('AGRA500')
	
	Local oViewAct	:= FwViewActive()
	Local oView		:= FWLoadView('AGRA500F')
	Local oFWMVCWindow, aCoors
	Default lComp	:= .T.
	Private _cNJKTEMP	
		
/*	//Informar numero do romaneio
	If IsInCallStack('GFEA523')
		cCodRom := U_INPUTVAL('Nº Romaneio',)
	EndIf*/

	If IsInCallStack('AGRA500')
		cCodTab := M->NJJ_TABELA
		
		If Empty(cCodTab)		
			Help('' ,1,".AGRA50000007.", , ,1,0) //"Campo tabela não preenchido.."Informe uma tabela relacionada ao produto, por favor.
			lRet := .F.
		EndIf
	ElseIf !Empty(cCodRom) // .And. Empty(NJJ->NJJ_CODROM)
		cCodTab := M->NJJ_TABELA
		If Empty(cCodTab)
			dbSelectArea( "NJJ" )
			dbSetOrder( 1 )
			dbSeek( FWxFilial( "NJJ" ) + cCodRom)
			cCodTab := NJJ->NJJ_TABELA
		EndIf
		If Empty(cCodTab)
			MsgAlert(STR0133) //"Campo tabela não preenchido. Informe uma tabela relacionada ao produto, por favor."		
			lRet := .F.
		EndIf
	EndIf

	SetKey( VK_F10, Nil)
	If lRet
		oView:SetOperation(MODEL_OPERATION_UPDATE)

		aCoors := FWGetDialogSize(oMainWnd)  

		IF lComp
			oModel500:SetOperation( MODEL_OPERATION_UPDATE )
			
			oView:SetModel(oModel500)
			oView:EnableControlBar(.T.)
			oView:SetUseCursor(.F.)
			oView:SetCloseOnOk({|| .T.})

			oFWMVCWindow := FWMVCWindow():New()
			oFWMVCWindow:SetUseControlBar(.T.)
			oFWMVCWindow:SetView(oView)
			oFWMVCWindow:SetCentered(.T.)
			oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
			oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
			oFWMVCWindow:SetTitle(STR0068) //"Classificação"   
			oFWMVCWindow:SetEscClose(.T.)
			oFWMVCWindow:SetStyle(2)

			oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})

//			oModel:Activate() //Reativa
		Else
			//Se TT nula
			If _cNJKTEMP == Nil
				//Cria TT
				_cNJKTEMP := AGRX500TTD(@_cNJKTEMP)
				//Realiza a carga da TT
				AGRX500TTC(@_cNJKTEMP)
				//Apresenta a Dialog
				AGRX500CLA(_cNJKTEMP)
			EndIf
			
			oViewAct:oModel:lModify := .T.
			oViewAct:lModify := .T.
			SetKey( VK_F10, {||AGRA500P(oModel, "VIEW")})
		EndIf
	EndIf


	
Return lRet


/** {Protheus.doc} fIniPerDiv
Inicialização do campo NJM_PERDIV no grid.

@param: 	oNJM - model ativo
@return:	xReturn - valor para o campo NJM_PERDIV
@author: 	Marlon Richard Trettin
@since: 	24/01/2015
@Uso: 		AGRA500 - Romaneio
*/
Static Function fIniPerDiv( oNJM )
	Local nPerDiv	:= 0
	Local nLinha	:= 0
	Local nX 		:= 0
	Local xReturn 	:= 0

	nLinha := oNJM:GetLine()
	For nX := 1 to oNJM:Length()
		oNJM:GoLine( nX )
		If .Not. oNJM:IsDeleted()

			nPerDiv += oNJM:GetValue( "NJM_PERDIV" )

		EndIf
	Next nX
	oNJM:GoLine( nLinha )

	xReturn := 100 - nPerDiv

Return( xReturn )



/** {Protheus.doc} A500Lot
Verifica se produto possui rastro por lote e campo NJM_LOTCTL esta vazio

Retorno:    .t. ou .f. 
@author: 	Ana Laura Olegini
@since: 	15/02/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A500Lot()
	Local aAreaAtu	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oNJM		:= oModel:GetModel( "AGRA500_NJM" )
	Local cProduto	:= oNJM:Getvalue("NJM_CODPRO")
	Local cLote		:= oNJM:GetValue("NJM_LOTCTL")
	Local lRetorno	:= .T.

	If Rastro(cProduto,"N") 
		If Empty(cLote)
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0107 , STR0108, "", "") //"Produto possui rastro por lote."#"Favor informar lote pra este produto!"	
			lRetorno := .F.
		Else	
			/*Verifica lote*/
			IF !fVerifLote(oNJM, oModel)		
				lRetorno := .F.
			ENDIF
		EndIf
	EndIf		 

	RestArea( aAreaAtu )
Return( lRetorno )


/*/{Protheus.doc} VldTESNJM
Valida TES da NJM e replica para a NJJ
@author silvana.torres
@since 10/07/2018
@version undefined

@type function
/*/
Function VldTESNJM()
	Local aAreaAtu	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oNJM		:= oModel:GetModel( "AGRA500_NJM" )
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local lRetorno	:= .F.

	If Vazio() .Or. ExistCpo('SF4') 
		lRetorno := .T.
		
		oNJJ:SetValue( "NJJ_TES", oNJM:GetValue( "NJM_TES" ) )
	EndIf		 

	RestArea( aAreaAtu )
Return( lRetorno )

/*/{Protheus.doc} fVerifLote
Função para verificação de informações do lote
@author silvana.torres
@since 16/04/2018
@version undefined
@param oNJM, object, descricao
@param oModel, object, descricao
@type function
/*/
Static Function fVerifLote(oNJM, oModel)
	
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.

	/*============================================================*\
	Se o produto controla lote, a Tes tem q movimentar Estoque 
	\*============================================================*/
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	If SF4->(MsSeek(FwxFilial("SF4")+oNJM:Getvalue("NJM_TES"))) .And. SF4->F4_ESTOQUE=="N" .And. lRetorno
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0111 , STR0112, "", "")	//"Valor Base do contrato não preenchido." //"Favor informar uma TES com movimento de estoque."
		lRetorno := .F.
	EndIf
	SF4->(dbCloseArea())

	/*=======================================*\
	Verifica se é um Romaneio de Saída com 
	Data de Validade do Lote ok
	\*=======================================*/
	DbSelectArea("SB8")
	SB8->(DbSetOrder(3))
	If SB8->(MsSeek(FwxFilial("SB8")+oNJM:Getvalue("NJM_CODPRO")+oNJM:Getvalue("NJM_LOCAL")+oNJM:GetValue("NJM_LOTCTL"))) .And. oNJM:Getvalue("NJM_TIPO") $ "2|4|6|8" .And. lRetorno
		If SB8->B8_DTVALID < dDataBase 
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0113 , STR0114, "", "")	//"Lote esta vencido." //"Favor informar um lote válido."
			lRetorno := .F.
		EndIf
	EndIf
	SB8->(dbCloseArea())

	RestArea( aAreaAtu )
	
Return lRetorno
/** {Protheus.doc} A500VCTR
Valida contrato para romaneios Fisicos e Simbólicos. Chamado do X3_VALID do campo NJM_CODCTR.

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	01/01/2015
@Uso: 		AGRA500 - Romaneio
*/
Function A500VCTR()
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR 		:= NJR->( GetArea() )
	//Local aAreaNNY 		:= NNY->( GetArea() )
	Local lRetorno 		:= .t.
	Local oModel		:= FwModelActive()
	Local nLinha		:= 0
	Local nX			:= 0

	Local oNJJ			:= oModel:GetModel( "AGRA500_NJJ" )
	Local cTipo			:= oNJJ:GetValue( "NJJ_TIPO" )

	Local oNJM			:= oModel:GetModel( "AGRA500_NJM" )
	Local cCodCtr		:= oNJM:GetValue( "NJM_CODCTR" )
	Local cCodEnt		:= oNJM:GetValue( "NJM_CODENT" )
	Local cLojEnt		:= oNJM:GetValue( "NJM_LOJENT" )

	If .Not. Empty( cCodCtr )
		dbSelectArea( "NJR" )
		dbSetOrder( 1 )
		If .Not. dbSeek( FWxFilial( "NJR" ) + cCodCtr )
			Help(, , STR0048, , STR0030, 1, 0 ) //"Ajuda"###"Não existe o -Contrato- informado."
			lRetorno := .f.
		Else
			// Se tipo do contrato for incompatível com tipo do romaneio
			If NJR->( NJR_TIPO ) <> OGX010TC( cTipo )  
				Help(, , STR0048, , STR0053 + "[ " + X3CboxDesc( "NJR_TIPO", NJR->( NJR_TIPO ) ) + " ]", 1, 0 ) //"Ajuda"###"O -Contrato- informado não pode ser utilizado neste romaneio, pois é um contrato do tipo "
				lRetorno := .f.
			EndIf

			// Se produto do contrato for diferente do produto do item do romaneio
			If  NJR->( NJR_CODPRO ) <> oNJM:GetValue( "NJM_CODPRO" )
				Help(, , STR0048, , STR0054 + Chr(10) + Chr(13) + "[ " + NJR->( NJR_CODPRO )+ " ]", 1, 0 ) //"Ajuda"###"O -Produto- do contrato informado é diferente do produto informado na linha do item do romaneio."
				lRetorno := .f.
			EndIf

			// Se o contrato pertence a outra entidade
			If NJR->( NJR_CODENT + NJR_LOJENT ) <> cCodEnt + cLojEnt
				Help(, , STR0048, , STR0055 + Chr(10) + Chr(13) + "[ " + NJR->( NJR_CODENT ) +" / " + NJR->( NJR_LOJENT ) + " ]", 1, 0 ) //"Ajuda"###"O -Contrato- informado pertence a outra Entidade / Loja."
				lRetorno := .f.
			EndIf

			/*// Verifica se o contrato possui cadência Física
			dbSelectArea( "NNY" )
			dbSetOrder( 1 )		
			dbSeek( xFilial( "NNY" ) + cCodCtr)
			While .Not. NNY->( Eof() ) .And. NNY->( NNY_FILIAL ) + NNY->( NNY_CODCTR ) == xFilial( "NNY" ) + cCodCtr
				If NNY->( NNY_TIPENT ) == '1' //Gerencial
					lCadenciaFis := .f.
				Endif
				NNY->( dbSkip() )
			EndDo
			If .Not. lCadenciaFis
				Help(, , STR0048, , STR0092 + cCodCtr, 1, 0 ) //"Ajuda"###"Somente contratos que possuem cadência do tipo -Física- podem ser utilizados neste romaneio. Retire o contrato: "+cCodCtr
				lRetorno := .f.
			Endif

			If lRetorno

				// Se possui nota de transito
				If lTemNFTrans
					If 	   NJR->( NJR_TIPO ) == "1" ; cTipo := "5"
					ElseIf NJR->( NJR_TIPO ) == "2" ; cTipo := "4"
					ElseIf NJR->( NJR_TIPO ) == "3" ; cTipo := "3"
					ElseIf NJR->( NJR_TIPO ) == "4" ; cTipo := "2"
					EndIf
					oNJJ:SetValue( "NJJ_TIPO"	, cTipo )
				EndIf		
				cCodSaf := NJR->( NJR_CODSAF )
				cTabela := NJR->( NJR_TABELA )
				cOpeFis := NJR->( NJR_OPEFIS )

				If NJR->( NJR_CODSAF ) <> cCodSaf .And. !Empty( cCodSaf )
					Help(, , STR0048, , STR0033, 1, 0 ) //"Ajuda"###"O contrato esta com -Safra- diferente do romaneio."
					lRetorno := .f.
				Else
					If NJR->( NJR_TABELA ) <> cTabela .And. !Empty( cTabela )
						Help(, , STR0048, , STR0034, 1, 0 ) //"Ajuda"###"O contrato esta com -Tabela de Descontos- diferente do romaneio."
						lRetorno := .f.
					EndIf
				EndIf
			EndIf*/
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

//	RestArea( aAreaNNY )
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} A500ACTR

//**   X3_VALID->NJJ_TIPO  **\\

@param: 	Nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Ana Laura Olegini
@since: 	15/07/2014
@Uso: 		AGRA500 - Romaneio
*/
Function A500ACTR()
	Local lRetorno		:= .T.
	Local nLinha		:= 0
	Local nX      		:= 0
	Local cCtrBnc     	:= Space(TAMSX3("NJM_CODCTR")[1])
	Local cDtrBnc     	:= Space(TAMSX3("NJR_DESCRI")[1])
	Local oModel		:= FwModelActive()
	Local oNJJ			:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM			:= oModel:GetModel( "AGRA500_NJM" )
	Local nOperation	:= oModel:GetOperation()

	//*4=Alteracao
	If nOperation = 4
		//Se o tipo que ja existe for ENTRADA - entra
		If NJJ->( NJJ_TIPO ) $ "1|3|5|7|9|A"

			//Se o tipo informado em tela for SAIDA - não valida
			If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|4|6|8|B" 
				Help(, ,STR0021, ,STR0056 , 1, 0 ) //"AJUDA"###"Alteração permitida somente para outro tipo ENTRADA"		
				lRetorno := .F.
			Else
				//*Se contrato nao for vazio faz a condicao abaixo
				If !Empty(oNJM:GetValue( "NJM_CODCTR" ))
					//*Zera os campos Cod. e Desc. de Contrato quando o TIPO/SAFRA for alterado.
					nLinha := oNJM:GetLine()
					For nX := 1 to oNJM:Length()
						oNJM:GoLine( nX )
						oNJM:LoadValue( "NJM_CODCTR", cCtrBnc )	//Codigo do Contrato
						oNJM:LoadValue( "NJM_DESCTR", cDtrBnc )	//Descrição do Contrato
					Next nX
					oNJM:GoLine( nLinha )
					lRetorno		:= .T.					
					//*** 28/01/2016 ****************************************************** 
					// Foi comentada essa funcionalidade, pois ao alterar o campo NJJ_SAFRA e em seguida clicar em fechar,
					// estava salvando o que alterava no modelo de dados, ocorrendo alterações inconsistentes 
					//FWFormCommit( oModel )
				EndIf
			EndIf

			//Se o tipo que ja existe for SAIDA - entra		
		ElseIf NJJ->( NJJ_TIPO ) $ "2|4|6|8|B" 

			//Se o tipo informado em tela for ENTRADA - não valida
			If oNJJ:GetValue( "NJJ_TIPO" ) $ "1|3|5|7|9|A"  
				Help(, ,STR0021, ,STR0057 , 1, 0 ) //"AJUDA"###"Alteração permitida somente para outro tipo SAIDA"
				lRetorno := .F. 
			Else
				//*Se contrato nao for vazio faz a condicao abaixo
				If !Empty(oNJM:GetValue( "NJM_CODCTR" ))
					//*Zera os campos Cod. e Desc. de Contrato quando o TIPO/SAFRA for alterado.
					nLinha := oNJM:GetLine()
					For nX := 1 to oNJM:Length()
						oNJM:GoLine( nX )
						oNJM:LoadValue( "NJM_CODCTR", cCtrBnc )	//Codigo do Contrato
						oNJM:LoadValue( "NJM_DESCTR", cDtrBnc )	//Descrição do Contrato
					Next nX
					oNJM:GoLine( nLinha )
					lRetorno		:= .T.									
					//*** 28/01/2016 ****************************************************** 
					// Foi comentada essa funcionalidade, pois ao alterar o campo NJJ_SAFRA e em seguida clicar em fechar,
					// estava salvando o que alterava no modelo de dados, ocorrendo alterações inconsistentes 
					//FWFormCommit( oModel )
				EndIf
			EndIf			
		EndIf
	EndIf
Return ( lRetorno )


/** {Protheus.doc} fVldFrete
Função de validação do tipo de frete

@param: 	Nil
@author: 	Ana Laura Olegini
@since: 	12/08/2014
@Uso: 		SIGAAGR
*/
Static Function fVldFrete ( oField )

	Local oModel	:= FwModelActive()
	Local oNJM		:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha 	:= oNJM:GetLine()
	Local nVrFrete	:= FWFLDGET("NJM_FRETE", nLinha )
	Local cTpFrete	:= FWFLDGET("NJJ_TPFRET" )
	Local lRet		:= .T. 

	If ( nVrFrete > 0 ) .and. !(cTpFrete  $ "C|F|T" )
		Help(, , STR0048, , STR0058, 1, 0 ) //"#Ajuda,#Foi informado valor de frete com tipo de frete Vazio ou Sem Frete"	   
		lRet := .f.
	EndIF	

Return( lRet )




/*/{Protheus.doc} fAftOKButton
//Função usada pra alteração do valor da variavel que indica pro F10 se o clique veio da grid(browse) ou da view. 
// Variável usada na função A500VLDPes
@author brunosilva
@since 05/02/2018
@type function
/*/
Static Function fAftOKButton( )
	__lF10Exec := .T.
Return .T.

/*/{Protheus.doc} fAftViewActiv
//Função usada pra alteração do valor da variavel que indica pro F10 se o clique veio da grid(browse) ou da view.
// Variável usada na função A500VLDPes
@author brunosilva
@since 05/02/2018
@type function
/*/
Static Function fAftViewActiv( )
	__lF10Exec := .F.
Return .T.

/*/{Protheus.doc} A500VLDPes
//Responsável por validar o F10(tecla de atalho da pesagem). 
@author brunosilva
@since 05/02/2018
@version undefined
@param cRomaneio, characters, descricao
@type function
/*/
Static Function A500VLDPes(cRomaneio)
	Local aArea   := GetArea()
	Local oModel  := FWModelActive()
	Local oView   := FWViewActive()
	Local cfilN94 := FWxFilial("N94")
	Local lRet    := .F.

	
	//If oModel:GetOperation() != 3 .AND. NJJ->NJJ_STATUS <> '0'
	//--verifica se o modelo esta ativo - quando volta para o browse nao estamos mais com o modelo ativo
	//--sendo necessario validar se ele esta ativo.
	If If(oModel == Nil, .F. , oModel:GetOperation() != MODEL_OPERATION_INSERT .AND. NJJ->NJJ_STATUS <> '0' .AND. NJJ->NJJ_STATUS <> '1')
		Help('' ,1,".AGRA50000015.", , ,1,0) //--Romaneio não pode ser alterado. Selecione um romaneio que não esteja com o status 'Confirmado'.
		lRet := .F.
	Else
		IF __lF10Exec = .T. .AND. oView == Nil
			dbSelectArea("NJJ")
			dbSetOrder(1)
			IF msSeek( FWxFilial('NJJ') + cRomaneio)
				oModel := FWLoadModel( "AGRA500" )
		
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				oModel:Activate()
				
				dbSelectArea('N94')
				N94->(dbSetOrder(1))
				N94->(msSeek(FWxFilial("N94")+NJJ->NJJ_TOETAP))
				While !N94->(EOF())  .AND. N94->N94_FILIAL == cfilN94 .And. N94->N94_CODTO == NJJ->NJJ_TOETAP
					If N94->N94_QTCPES
						lRet := .T.
						exit
					EndIf   
					N94->(dbSkip())
				End
				
				dbSelectArea("NJJ")
				If lRet 
					AGRA500P(oModel, "GRID")
				Else
					HELP(, , STR0021, , STR0063, 1, 0 ) //"O tipo de operação deste romaneio não tem pesagem."
				EndIF
				oModel:DEACTIVATE()
			ENDIF
		Else
			If oModel:GetOperation() != 1
				dbSelectArea('N94')
				N94->(dbSetOrder(1))
				N94->(msSeek(FWxFilial("N94")+__cTipoOp))
				While !N94->(EOF())  .AND. N94->N94_FILIAL == cfilN94 .And. N94->N94_CODTO == __cTipoOp
					If N94->N94_QTCPES
						lRet := .T.
						exit
					EndIf   
					N94->(dbSkip())
				End
				
				If lRet 
					AGRA500P(oModel, "VIEW")
				Else
					HELP(, , STR0021, , STR0063, 1, 0 ) //"O tipo de operação deste romaneio não tem pesagem."
				EndIF
			EndIf
		EndIF
	endIf
	
	dbSelectArea('NJJ')
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500CTPOP
//Valid para o campo de produto do pergunte. Este campo filtra os tipo de operações a serem exibidos
@author brunosilva
@since 06/02/2018
@type function
/*/
Function A500CTPOP()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If !(EMPTY(MV_PAR02))
	
		IF ExistCpo('SB1', MV_PAR02)		
			NCB->(dbSelectArea("NCB"))
			
			If !(EMPTY(MV_PAR04)) //Tp. Op.
				NCB->(dbSetOrder(1))
				
				If !NCB->(msSeek(FWxFilial("NCB")+MV_PAR04+MV_PAR02))
					lRet := .T.
					MV_PAR04 := Space(TamSX3("N92_CODIGO")[1])
					MV_PAR05 := Space(TamSX3("N92_DESCTO")[1])
				EndIf
			EndIf
			
			NCB->(dbGoTop())
			NCB->(dbSetOrder(2))
			If !(NCB->(msSeek(FWxFilial("NCB")+MV_PAR02)))
				HELP(, , STR0021, , STR0067, 1, 0 ) //"Não existe nenhum Tipo de operação cadastrado para este produto."
				lRet := .F.
			Else
			 	MV_PAR03 := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR02,"B1_DESC")
			EndIf
			NCB->(dbCloseArea())
		Else
			lRet := .F.
		EndIF
	Else
		MV_PAR03 := Space(TamSX3("B1_DESC")[1])
	EndIf
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} A500CTPOR
//Valid para o campo de tipo de operação do pergunte. 
@author ana.olegini
@since  24/04/2018
@type function
/*/
Function A500CTPOR()
	Local aArea 	:= GetArea()
	Local lRetorno  := .T.
	
	//--Se o Tipo de Operação NAO estiver vazio E o Produto NAO estiver vazio
	If .NOT. (EMPTY(MV_PAR04)) .AND. .NOT. (EMPTY(MV_PAR02))
		//--Verifica na NCB se o tipo de operação possui produto vinculado
		NCB->(dbSelectArea("NCB"))	
		NCB->(dbSetOrder(1)) //Filial+TipOper+CodPro
		If .NOT. (NCB->(MSSeek(FWxFilial("NCB")+MV_PAR04+MV_PAR02)))
			Help(, , STR0021, , STR0117, 1, 0 ) 	//"Tipo de Operação não está cadastrado para o Produto selecionado."
			lRetorno := .F.
		Else
			MV_PAR05 := Posicione("N92",1,FWxFilial("N92")+MV_PAR04,"N92->N92_DESCTO")
		EndIf
		NCB->(dbCloseArea())
	Else
		If Empty(MV_PAR04)
			MV_PAR05 := Space(TamSX3("N92_DESCTO")[1])
		Else
			N92->(dbSelectArea("N92"))	
			N92->(dbSetOrder(1))
			If .NOT. (N92->(MSSeek(FWxFilial( "N92")+MV_PAR04)))
				lRetorno := .F.
			Else
				MV_PAR05 := N92->N92_DESCTO
			EndIf
			N92->(dbCloseArea())
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRetorno

/*/{Protheus.doc} A500WhTpOp
Filtro da consulta N92DES
@author silvana.torres
@since 27/08/2018
@version undefined

@type function
/*/
Function A500WhTpOp()

	Local cWhere	:= ""
	
	cWhere := "@D_E_L_E_T_ = ' ' AND N92_MSBLOQ <> 'T' " 
	
	If .NOT. Empty(MV_PAR02)
		cWhere += " AND N92_CODIGO     IN (SELECT NCB_CODTO FROM " + RetSqlName("NCB") + " NCB WHERE NCB_FILIAL = N92_FILIAL AND NCB_CODPRO = '" + MV_PAR02 + "' ) "
	Else
		cWhere += " AND N92_CODIGO NOT IN (SELECT NCB_CODTO FROM " + RetSqlName("NCB") + " NCB WHERE NCB_FILIAL = N92_FILIAL) "
	EndIf
	
Return cWhere


/*/{Protheus.doc} AGRA500WNF
//Verifica o formulário para habilitar ou não os campos da NF
@author silvana.torres
@since 14/02/2018
@version undefined

@type function
/*/
Function AGRA500WNF()

	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oModelNJJ	:= oModel:GetModel( "AGRA500_NJJ" )

	If oModel:GetModel("AGRA500_NJJ"):IsActive() 
		If oModelNJJ:GetValue("NJJ_TPFORM") == "1"
			return .F.
		else 	
			return .T.			
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AGRA500VLT
//When do campo NJJ_TABELA
@author carlos.augusto
@since 12/02/2018
@version undefined

@type function
/*/
Function AGRA500VLT()
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oModelNJJ	:= oModel:GetModel( "AGRA500_NJJ" )
	Local lBloqTab  := .F.
	
	If oModel:GetOperation() != 3 //se não for inclusão, 
	//ele pega o tipo da operação, do registro
		__cTipoOp := oModelNJJ:GetValue('NJJ_TOETAP')
	Else
	//se for inclusão ele pega do parametro
		__cTipoOp := MV_PAR04
    EndIf

	lBloqTab := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_BLQTAB")	

	If oModel:GetModel("AGRA500_NJJ"):IsActive() 
		oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.T.)
		lRet := Iif(Posicione("SB5",1,fwxFilial("SB5")+oModelNJJ:GetValue("NJJ_CODPRO"),"B5_TPCOMMO")== '2',.F.,.T.)
		If .NOT. lRet .And. .NOT. Empty(oModelNJJ:GetValue("NJJ_TABELA"))
			oModelNJJ:LoadValue("NJJ_TABELA", '')
			oModel:GetModel('NJKUNICO'):SetNoDeleteLine(.F.) 
			ResetNJK() 
		EndIf
		If lRet == .T. .And. lBloqTab == .T.
			return .F.
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


/*/{Protheus.doc} A500PerDiv
Gatilho disparado pelo campo NJM_PERDIV, para atualizar o campo de quantidade (NJM_QTDFCO)

-- FUNÇÃO DO OGA250 ADAPTADA PARA O AGRA500

@author ana.olegini
@since 10/02/2018

@param 	oField, 	Model 
@return nQtdLiq, 	Retorna quantidade liquida
/*/
Static Function A500PerDiv( oField )
	Local oModel	:= oField:GetModel()
	Local oNJJ 		:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM 		:= oModel:GetModel( "AGRA500_NJM" )
	Local nQtdLiq	:= 0

	//Utiliza o valor do novo campo NJJ_PESO3 para realizar os calculos - DAGROGAP-446
	nQtdLiq := ( ( oNJJ:GetValue( "NJJ_PESO3" ) * oNJM:GetValue( "NJM_PERDIV" ) ) / 100 )

	oNJM:SetValue( "NJM_QTDFCO", Round(nQtdLiq , __nDecPeso ) )
	

Return( nQtdLiq )


/*/{Protheus.doc} A500PerDiv
Inicialização do campo NJM_QTDFCO no grid.

-- FUNÇÃO DO OGA250 ADAPTADA PARA O AGRA500

@author ana.olegini
@since 10/02/2018

@param 	oField, 	Model 
@return nPerLiq, 	Retorna percentual de divisão
/*/
Static Function A500QtdFco( oField )
	Local oModel	:= oField:GetModel()
	Local oNJJ 		:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM 		:= oModel:GetModel( "AGRA500_NJM" )
	Local nPerLiq	:= 0

	//Fazer os calculos usando o novo campo NJJ_PESO3 - DAGROGAP-446
	nPerLiq := ( 100 * ( oNJM:GetValue( "NJM_QTDFCO" ) / oNJJ:GetValue( "NJJ_PESO3" ) ) )

	oNJM:LoadValue("NJM_PERDIV",  Round(nPerLiq, TamSX3( "NJM_PERDIV" )[2] ) ) // Usado LoadValue() pra não disparar novamente o gatilho

Return( nPerLiq )


/*/{Protheus.doc} A500VldSNfp
Realiza o gatilho para a NJM Série da NFP do produtor 

-- FUNÇÃO DO OGA250 ADAPTADA PARA O AGRA500

@author ana.olegini
@since 10/02/2018
@return lRet, .T. verdadeiro ou .F. falso
/*/
Function A500VldSNfp()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_NFPSER", oNJJ:GetValue( "NJJ_NFPSER" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} A500VldNNfp
Realiza o gatilho para a NJM NUmero da NFP do produtor 

-- FUNÇÃO DO OGA250 ADAPTADA PARA O AGRA500

@author ana.olegini
@since 10/02/2018
@return lRet, .T. verdadeiro ou .F. falso
/*/
Function A500VldNNfp()
	Local lRet   	:= .T.
	Local aArea  	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJJ	 	:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM	 	:= oModel:GetModel( "AGRA500_NJM" )
	Local nLinha	:= oNJM:GetLine()
	Local nX	 	:= 0
	
	//--Gatilha para a tabela NJM - a função de trigger nao funciona
	If lRet
		nLinha := oNJM:GetLine()
		For nX := 1 to oNJM:Length()
			oNJM:GoLine( nX )
			oNJM:SetValue( "NJM_NFPNUM", oNJJ:GetValue( "NJJ_NFPNUM" ) )
		Next nX
		oNJM:GoLine( nLinha )
		
		If valType(oView) == 'O'  .AND. !(IsInCallStack("AX500NAtu") .OR. IsInCallStack("AX500FCONF"))
			oView:Refresh()
		EndIf
	EndIF
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500ItRom
Realiza a incialização do campo Item do romaneio

@author ana.olegini
@since 10/02/2018
@return cIteROm, Sequencia do item do romaneio
/*/
Function A500ItRom()
	Local cIteROm := ''
	
	//tipo de operação igual de Produção, Entrada por Transferência e Saída por Transferência
	If __bTipoIni $ "1|A|B"
		cIteROm := "01"	//até o momento cria-se uma linha para esses tipos de movimentações 
	EndIf
Return cIteROm


/*/{Protheus.doc} A500NFENT
Função auxiliar para busca da nota de entrada gerada para o romaneio

@author ana.olegini
@since 14/02/2018
@return aRetorno, 	Retorna as informações da NF gerada para o Romaneio
/*/
Function A500NFENT(cRomaneio, cSafra, cContrato)
	Local aRetorno 		:= {}
	Local cAliasSF1 	:= GetNextAlias()
	Local cQuerySF1		:= ""

	//--Agrupa para geração do Documento de compra
	cQuerySF1 := " SELECT F1_SERIE, F1_DOC, F1_EMISSAO, F1_TIPO, F1_FORNECE, F1_LOJA, F1_ESPECIE, F1_CHVNFE "
	cQuerySF1 +=   " FROM "+RetSqlName("SF1")+" SF1 "
	cQuerySF1 +=  " WHERE SF1.F1_FILIAL = '"+ FWxFilial("SF1") +"'"
	cQuerySF1 +=    " AND SF1.F1_CODROM  = '"+ cRomaneio + "'"
	cQuerySF1 := ChangeQuery(cQuerySF1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySF1),(cAliasSF1),.F.,.T.)
	
	dbSelectArea((cAliasSF1))
	(cAliasSF1)->( dbGoTop() )
	While (cAliasSF1)->( .NOT. Eof() )
	
		aAdd( aRetorno, { (cAliasSF1)->F1_SERIE, (cAliasSF1)->F1_DOC, (cAliasSF1)->F1_EMISSAO, (cAliasSF1)->F1_TIPO, (cAliasSF1)->F1_ESPECIE, (cAliasSF1)->F1_CHVNFE } )
	
		(cAliasSF1)->( dbSkip() )
	EndDo 
	(cAliasSF1)->( dbCloseArea() )
	
Return aRetorno


/*/{Protheus.doc} A500NFSAI
Função auxiliar para busca da nota de saída gerada para o romaneio

@author ana.olegini
@since 23/02/2018
@return aRetorno, 	Retorna as informações da NF gerada para o Romaneio
/*/
Function A500NFSAI(cRomaneio, cDocumento, cSerie)
	Local aRetorno 		:= {}
	Local cAliasSF2 	:= GetNextAlias()
	Local cQuerySF2		:= ""

	//--Agrupa para geração do Documento de compra
	cQuerySF2 := " SELECT F2_SERIE, F2_DOC, F2_EMISSAO, F2_TIPO, F2_CLIENTE, F2_LOJA, F2_ESPECIE, F2_CHVNFE "
	cQuerySF2 +=   " FROM "+RetSqlName("SF2")+" SF2 "
	cQuerySF2 +=  " WHERE SF2.F2_FILIAL = '"+ FWxFilial("SF2") 	+"'"
	cQuerySF2 +=    " AND SF2.F2_DOC    = '"+ cDocumento 	   	+ "'"
	cQuerySF2 +=    " AND SF2.F2_SERIE  = '"+ cSerie 	   		+ "'"
	cQuerySF2 := ChangeQuery(cQuerySF2)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySF2),(cAliasSF2),.F.,.T.)
	
	dbSelectArea((cAliasSF2))
	(cAliasSF2)->( dbGoTop() )
	While (cAliasSF2)->( .NOT. Eof() )
	
		aAdd( aRetorno, { (cAliasSF2)->F2_SERIE, (cAliasSF2)->F2_DOC, (cAliasSF2)->F2_EMISSAO, (cAliasSF2)->F2_TIPO, (cAliasSF2)->F2_ESPECIE, (cAliasSF2)->F2_CHVNFE } )
	
		(cAliasSF2)->( dbSkip() )
	EndDo 
	(cAliasSF2)->( dbCloseArea() )
	
Return aRetorno


/*/{Protheus.doc} AGRA500WPr
When do código do produto
@author silvana.torres
@since 28/02/2018
@version undefined

@type function
/*/
Static Function AGRA500WPr()
	
	Local oModel	:= FwModelActive()
	Local lRet		:= .T.
		
	if !(FWIsInCallStack('OGA250EXRO'))
		
		If Empty(MV_PAR02) .And. Empty(oModel:GetValue('AGRA500_NJJ', 'NJJ_ORDCLT' ))
			lRet := .T.
		Else
			lRet := .F.	
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} AGRA500INP
//Inicializador padrao dos campos NJJ_TIPO ou NJM_TIPO
@author carlos.augusto
@since 19/02/2018
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Function AGRA500INP(cCampo)
	Local aArea     := GetArea()
	Local cValor    := ""
    
	//-- Se não é uma inclusão
	If .NOT. Inclui
		//-- Busca etapa gravada
	    IF .NOT.EMPTY(NJJ->NJJ_TOETAP) 
	    	__cTipoOp := NJJ->NJJ_TOETAP
	    	If cCampo $ "NJJ_TIPO|NJM_TIPO"
	    		cValor  := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_TIPO")
	    	EndIf  
	    EndIf
	    If cCampo $ "NJM_CODPRO"
	    	cValor := NJJ->NJJ_CODPRO
	    EndIf	 
	    
	    If cCampo $ "NJJ_DESPRO"
	    	cValor := Posicione("SB1",1,FWxFilial("SB1")+NJJ->NJJ_CODPRO,"B1_DESC")
	    endIf
	    
	    If cCampo $ "NJM_DESPRO"
	    	cValor := Posicione("SB1",1,FWxFilial("SB1")+NJJ->NJJ_CODPRO,"B1_DESC")
	    EndIf
	    
	    If cCampo $ "NJJ_UM1PRO" 
	    	cValor := Posicione( "SB1", 1, FWxFilial("SB1") + NJJ->NJJ_CODPRO, "B1_UM" )
	    endIf
	    
	    If cCampo $ "NJM_UM1PRO"
	    	cValor := Posicione( "SB1", 1, FWxFilial("SB1") + NJJ->NJJ_CODPRO, "B1_UM" )
	    endIf	  
 
    Else //-- Utiliza etapa do parametro 
    	If FWIsInCallStack('AGRA500') .or. FWIsInCallStack('GFEA523')
	    	Pergunte( "AGRA500001", .F. )
	    	__cTipoOp := MV_PAR04
	    EndIf
	    
	    If cCampo $ "NJJ_TIPO|NJM_TIPO"
	       cValor  := Posicione("N92",1,fwxFilial("N92")+__cTipoOp,"N92_TIPO")
	    EndIf	 
    	
    	if .NOT. EMPTY(MV_PAR02)
		    If cCampo $ "NJM_CODPRO"
		    	cValor := MV_PAR02
		    EndIf	
    	 
	    	If cCampo $ "NJJ_DESPRO"
	   			cValor := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR02,"B1_DESC")
		    endIf 
	    
		    If cCampo $ "NJM_DESPRO"
		    	cValor := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR02,"B1_DESC")
		    EndIf
		    	    
		    If cCampo $ "NJJ_UM1PRO"
		    	cValor := Posicione( "SB1", 1, FWxFilial("SB1") + MV_PAR02, "B1_UM" )
		    endIf	    

		    If cCampo $ "NJM_UM1PRO"
		    	cValor := Posicione( "SB1", 1, FWxFilial("SB1") + MV_PAR02, "B1_UM" )
		    endIf
	    ENDiF
    EndIf	

	RestArea(aArea)

Return cValor


/*/{Protheus.doc} AGR500GETP
//Função chamada no botão finalizar etapa
@author marina.muller
@since 14/03/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGR500GETP(oModel)
	Local aAreaAtu	:= GetArea()
	Local lRet		:= .T.
	Local cAliasN93 := GetNextAlias()
    Local cQuery	:= ""
    Local cProxEtp  := ""
	Local oModel    := FwModelActive()
    
	cQuery := " SELECT N93_CODIGO "
	cQuery +=   " FROM "+RetSqlName("N93")+" N93 		      "
	cQuery +=  " WHERE N93.N93_CODTO 	= '"+ __cTipoOp  + "' "
	cQuery +=    " AND N93.N93_CODIGO  <> '"+ __cEtapa   + "' "
	cQuery +=    " AND N93.N93_ORDEM    > '"+ __cOrdEtp  + "' "
	cQuery +=    " AND N93.N93_OK       = 'T'                 "
	cQuery +=    " AND N93.D_E_L_E_T_   = ''  				  "
	cQuery +=    " ORDER BY N93_ORDEM                         "
	cQuery := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasN93),.F.,.T.)		
	dbSelectArea(cAliasN93)
	
	(cAliasN93)->( dbGoTop() )		
	If (cAliasN93)->(.NOT. Eof())
	   cProxEtp := (cAliasN93)->N93_CODIGO
	endIf
	(cAliasN93)->( dbCloseArea())
         
    //Se não encontrar próxima etapa mantem código da atual
    If Empty(cProxEtp) 
       cProxEtp := __cEtapa
    EndIf
	    
	oModel:SetValue("AGRA500_NJJ","NJJ_ETAPA", cProxEtp)
	lRet := GrvModelo(oModel)

    If lRet 
       MsgInfo(STR0087) //"Etapa foi atualizada com sucesso."
    Else    
       MsgInfo(STR0088) //"Não foi possível atualizar a etapa para romaneio."
    EndIf	
	
	RestArea(aAreaAtu)
		
Return lRet

/*/{Protheus.doc} A500CLOSE
// Responsável por limpar o array do vinculo da fardão  x romaneio.
@author brunosilva
@since 23/03/2018
@version undefined

@type function
/*/
Static Function A500CLOSE()
	If !(EMPTY(_aItsEsq   := {}))
		_aItsEsq   := {}
	EndIf
Return


/*/{Protheus.doc} AGRA500IntFardao
//Realiza a integracao da pesagem do romaneio
@author carlos.augusto
@since 27/03/2018
@version undefined
@type function
/*/
Function AGRA500Int()
	Local lRet		 := .T.
	Local aRet 		 := {}
	Local oModel	 := NIL
	Local oMldDX0 	 := nil
	Local oMldNJJ	 := nil
	Local lAlgodao   := .F.
    Local nOperation := nil
	Local nX
	Local aLines	 := FWSaveRows()		//Salva contexto do model ativo
	Local aArea      := GetArea()	
	
    If FwIsInCallStack("OGA250NF") .OR. IsInCallStack('OGA250REA') .OR. IsInCallStack('OGA250CAN') //CONFIRMAR, REABRIR ou CANCELAR
        oModel := FwLoadModel("OGA250")
    Else
        oModel := FwLoadModel("AGRA500")
    EndIf
    
	oModel:SetOperation(MODEL_OPERATION_UPDATE)

    oModel:Activate()
    
    nOperation := oModel:GetOperation()
    oMldDX0    := oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio	
    oMldNJJ    := IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))

	//Se a TT de ordem de colheita esta vazia e tem ordem de colheita, integra para poder validar
	If !(_cCLTTEMP)->(RecCount()) > 0
		If FWHasEAI( "AGRA530", .T., .F., .T. )
		//#"Realizando Integração com o PIMS. Validando Ordem de Colheita."
			Processa({|| FWIntegDef( "AGRA530", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "AGRA530")}, STR0091 )
		Else
			lRet := .F.
			//#"Integração entre Protheus x PIMS não foi efetuada." - #"Verifique as configurações de integração da mensagem GetHarvestOrder."
			AgrHelp(STR0048,STR0092,STR0093)
			//oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0092, STR0093, "", "")
		EndIf
	EndIf
	
	//Se tem registros na TT
	If (_cCLTTEMP)->(RecCount()) > 0 
		dbSelectArea(_cCLTTEMP)
		(_cCLTTEMP)->(dbSetOrder(1))
		(_cCLTTEMP)->(msSeek(oMldNJJ:GetValue( "NJJ_ORDCLT" )))
	Else
		//#"Ordem de Colheita não retornada pelo PIMS." - #"Por favor, verifique a inconsistência na Ordem de Colheita informada anteriormente."
		AgrHelp(STR0048,STR0094,STR0095)
		//oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0094, STR0095, "", "")
		
		lRet := .F.
	EndIf
	
	lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+oMldNJJ:GetValue( "NJJ_CODPRO" ),"B5_TPCOMMO")== '2',.T.,.F.)

	If lRet .and. FWHasEAI( "AGRW500", .T., .F., .T. )  .AND. lAlgodao
	
		If nOperation != MODEL_OPERATION_DELETE	
			AGRX500IRT() //Ratear peso na DX0
		EndIf

		For nX := 1 to oMldDX0:Length()
			oMldDX0:GoLine(nX)
			If (.Not. oMldDX0:IsDeleted() .And. .Not. Empty(oMldDX0:GetValue("DX0_FARDAO"))) .Or. ;
				(oMldDX0:IsDeleted() .And. Val(oMldDX0:GetValue("DX0_BOLETI")) != 0)
			
				//#"Realizando integracao com o PIMS: Código do Fardão: "
				Processa({|| aRet := FWIntegDef( "AGRW500", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "AGRW500")}, STR0096 + oMldDX0:GetValue("DX0_FARDAO") )
				If .Not. Empty(aRet) //Quando sincrono
					If .Not. aRet[1]
						AgrHelp(STR0048,STR0092 + aRet[2],STR0118+STR0156) //##Integração entre Protheus x PIMS não foi efetuada.###Verifique o Romaneio.#Verifique as configurações da integração.
						lRet := .F.
					EndIf
				EndIf
			EndIf			
		Next nX
	
	ElseIf lRet .and. FWHasEAI( "AGRI500", .T., .F., .T. )  .AND. !lAlgodao

		//#"Realizando integração com o PIMS: Código do Romaneio: "
		Processa({|| aRet := FWIntegDef( "AGRI500", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "AGRI500")}, STR0130 + oMldNJJ:GetValue("NJJ_CODROM") )
		If .Not. Empty(aRet) //Quando sincrono
			If .Not. aRet[1]
				AgrHelp(STR0048,STR0092 + aRet[2],STR0118+STR0156) //##Integração entre Protheus x PIMS não foi efetuada.###Verifique o Romaneio.#Verifique as configurações da integração.
				lRet := .F.
			EndIf
		EndIf
	
	EndIf
	
	RestArea(aArea)
	FwRestRows(aLines)	

Return lRet


/*/{Protheus.doc} AGRA500TemIE
//Verifica se tem IE para abrir a tela
@author carlos.augusto
@since 13/04/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRA500TemIE(oModel)
	Local lRet 		:= .F.
	Local oMldN9E 	:= oModel:GetModel('AGRA500_N9E') //Integracao Romaneio
	Local oMldNJJ 	:= oModel:GetModel('AGRA500_NJJ') //Integracao Romaneio
	Local nX

	For nX := 1 to oMldN9E:Length()
		oMldN9E:GoLine(nX)
		If .Not. oMldN9E:IsDeleted() .And. .Not. Empty(oMldN9E:GetValue( "N9E_CODINE" ))
			lRet := .T.
			exit
		EndIf
	Next nX
	
	If .Not. lRet
		MsgAlert(STR0101)//"Nenhuma Instrução de Embarque selecionada para filtrar os fardos"
	EndIf
	
	If lRet .And. Empty(oMldNJJ:GetValue( "NJJ_CODSAF" ))
		MsgAlert(STR0102)//"Favor preencher o campo Safra."
		lRet := .F.
	EndIf 

Return lRet


/*/{Protheus.doc} A500VLDFAR
//Função valida se tipo operação foi marcado fardinho/fardão o mesmo foi informado no romaneio
@author marina.muller
@since 01/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500VLDFAR()
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local nQtdVinc
	Local nQtdN9D
	Local oModel
	Local oMldNJJ 		
	Local oMldDX0
	Local oMldN9D
	Local nX
	Local cToEtap	:= NJJ->NJJ_TOETAP
	
	if EMPTY(oModel)
		oModel := IIF(IsInCallStack("AGRA500"),FWLoadModel('AGRA500'),IIF(IsInCallStack("GFEA523"),FWLoadModel('AGRA550'),FWLoadModel('OGA250')))
		oModel:Activate()
	Else
		oModel := FWModelActive()
	EndIf

	oMldNJJ 	:= IIF(IsInCallStack("AGRA500"),oModel:GetModel('AGRA500_NJJ'),IIF(IsInCallStack("GFEA523"),oModel:GetModel('AGRA550_NJJ'),oModel:GetModel('NJJUNICO')))
	oMldDX0 	:= IIF(IsInCallStack("AGRA500"),oModel:GetModel('AGRA500_DX0'),IIF(IsInCallStack("GFEA523"),oModel:GetModel('AGRA550_DX0'),oModel:GetModel('AGRA500_DX0'))) //Vinculo FardaoxRomaneio
	oMldN9D		:= IIF(IsInCallStack("AGRA500"),oModel:GetModel('AGRA500_N9D'),IIF(IsInCallStack("GFEA523"),oModel:GetModel('AGRA500_N9D'),oModel:GetModel('N9DUNICO')))    //Vinculo FardinhoxRomaneio
	
	nQtdVinc  := oMldDX0:Length()
	nQtdN9D	  := oMldN9D:Length()
		
	
	//Caso encontre a etapa vinculada, valida qual etapa deve ser feita.
	if !EMPTY(cToEtap)
		
		N92->(dbSelectArea("N92"))	
		N92->(dbSetOrder(1))
		If (N92->(msSeek(FWxFilial("N92")+NJJ->NJJ_TOETAP)))
		   If N92->N92_GSTFD1  //G. Fard MP  
			  For nX := 1 to nQtdVinc			
				
				  oMldDX0:GoLine( nX )
				  
				  if !EMPTY(oMldDX0:GetValue('DX0_FARDAO'))
					  dbSelectArea("DX0")
					  DX0->(dbSetOrder(1))
					  //se encontrar fardões/fardinhos vinculados segue confirmação romaneio
					  If DX0->(MsSeek(FWxFilial("DX0")+oMldDX0:GetValue('DX0_CODROM')+oMldDX0:GetValue('DX0_ITEM')+oMldDX0:GetValue('DX0_NRROM')))
					     lRet := .T.
						 Exit
					  //se não encontrar fardões/ fardinhos vinculados apresenta mensagem em tela
					  Else
						lRet := .F.
						Exit  
					  EndIf
					  DX0->(dbCloseArea())
				  else
				  	  lRet := .F.
				  	  Loop
				  endIf
			  Next nX	
		   ElseIf N92->N92_GSTFD2  //G. Fard PA 
		   		//Validar quando for romaneio de fardinho
		   		For nX := 1 to nQtdN9D
			
					oMldN9D:GoLine( nX )
					
					if !EMPTY(oMldN9D:GetValue('N9D_CODROM'))
						dbSelectArea("N9D")
						N9D->(dbSetOrder(6))
						//se encontrar fardões/fardinhos vinculados segue confirmação romaneio
						If N9D->(dbSeek(FWxFilial("N9D")+oMldN9D:GetValue('N9D_CODROM')+oMldN9D:GetValue('N9D_TIPMOV')))
							lRet := .T.
							Exit
							//se não encontrar fardões/ fardinhos vinculados apresenta mensagem em tela
						Else
							lRet := .F.
							Exit  
						EndIf
						N9D->(dbCloseArea())
					else
						lRet := .F.
						Loop
					endIf
				next nX
		   else
		   		lRet := .F.
		   EndIf	
		EndIf
		N92->(dbCloseArea())
	else		
		//Se maior que 0, então tem fardão vinculado
		if nQtdVinc > 0
			For nX := 1 to nQtdVinc			
				
			  oMldDX0:GoLine( nX )
			  
			  if !EMPTY(oMldDX0:GetValue('DX0_NRROM'))
				  dbSelectArea("DX0")
				  DX0->(dbSetOrder(1))
				  //se encontrar fardões/fardinhos vinculados segue confirmação romaneio
				  If DX0->(MsSeek(FWxFilial("DX0")+oMldDX0:GetValue('DX0_CODROM')+oMldDX0:GetValue('DX0_ITEM')+oMldDX0:GetValue('DX0_NRROM')))
				  	 lRet := .T.
					 Exit
				  //se não encontrar fardões/ fardinhos vinculados apresenta mensagem em tela
				  Else
					lRet := .F.
					Exit  
				  EndIf
			  else
			  	  Loop
			  endIf
			  DX0->(dbCloseArea())		
			Next nX
		endIf
		
		if nQtdN9D > 0 .AND. lRet 
			For nX := 1 to nQtdN9D
			
				oMldN9D:GoLine( nX )
				
				if !EMPTY(oMldN9D:GetValue('N9D_CODROM'))
					dbSelectArea("N9D")
					N9D->(dbSetOrder(6))
					//se encontrar fardões/fardinhos vinculados segue confirmação romaneio
					If N9D->(dbSeek(FWxFilial("N9D")+oMldN9D:GetValue('N9D_CODROM')+oMldN9D:GetValue('N9D_TIPMOV')))
						lRet := .T.
						Exit
						//se não encontrar fardões/ fardinhos vinculados apresenta mensagem em tela
					Else
						lRet := .F.
						Exit  
					EndIf
					N9D->(dbCloseArea())
				else
					Loop
				endIf
			next nX
		else
			//Não tem nada viculado.
			lRet := .F.
		endif
	endIf
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} MostraClas
//Indica se apresenta a acao relacionada Classificacao
@author carlos.augusto
@since 08/05/2018
@version undefined
@param cTpOper, characters, descricao
@param cEtapaRom, characters, descricao
@type function
/*/
Static Function MostraClas(cTpOper, cEtapaRom)
	Local aArea		:= GetArea()
	Local cEtapaN94 := ""
	Local lRet		:= .F.
	Local cModoExec := ""
	
	N92->(dbSelectArea('N92'))
	N92->(dbSetOrder(1))
	N92->(MsSeek(FWxFilial("N92") + cTpOper))
	If !N92->(EOF())
		cModoExec := N92->N92_MDEXEC
	EndIf

	N94->(dbSelectArea('N94'))
	N94->(dbSetOrder(1))
	N94->(msSeek(FWxFilial("N94") + cTpOper))
	While !N94->(EOF())  .AND. N94->N94_FILIAL = FWxFilial("N94") .And. N94->N94_CODTO = cTpOper
		cEtapaN94 := N94->N94_CODETP
		lRet  := N94->N94_ANAQUA
		
		If cModoExec == "1" .And. lRet //cEtapaN94 == cEtapaRom
			exit
		ElseIf cModoExec == "2" .And. lRet
			exit
		EndIf
		N94->(dbSkip())
	End

	N92->(dbCloseArea())
	N94->(dbCloseArea())

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA500POP
//Função para criação da tela popup em etapas
@author marina.muller
@since 15/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodRom, characters, descricao
@param cOper, characters, descricao
@param cEtapa, characters, descricao
@param cProd, characters, descricao
@type function
/*/
Function AGRA500POP(cCodRom, cOper, cEtapa, cParametro,cCdPtCt)
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oView		:= Nil
	Local oFWMVCWindow, aCoors
	Local cDescEtp
	Local lBalanca	:= .F.
	Local lPeso1	:= .F.
	Local lPeso2	:= .F.
	Local cQry 		:= ""
	Local cRetQry	:= ""
	Local aArea		
	
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita
	Private _lVincFard  := .F.
	
	Default cParametro	:= ""
	Default cCdPtCt		:= ""
	
	If _cCLTTEMP == Nil
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP) //AGRA530TTO
	EndIf	

	__cTipoOp := cOper
	__cEtapa  := cEtapa
	
	//Deve executar depois de inicializar as variaveis da classe
	oView := FWLoadView('AGRA500')
	
	//Caso o parmetro venha vazio, quer dizer que veio das perguntas e o fluxo deve seguir normal
	if Empty(cParametro)
		//Trecho destinado ao processo de pesagem.
		//Define se exibira a tela de balanca e qual das pesagens deve executar, primeira ou segunda.
		dbSelectArea("N93")
		N93->(dbSetOrder(1))
		If N93->(DbSeek(FWxFilial("N93") + __cTipoOp + __cEtapa ))
			cDescEtp := N93->N93_DESETP
			
			dbSelectArea("N94")
			N94->(dbSetOrder(1))
			If N94->(DbSeek(FWxFilial("N94") + __cTipoOp + __cEtapa ))
				
				
				lBalanca := N94->N94_QTCPES
				
				//A partir deste momento usa pesagem. Com isso, definir qual das pesagens esta configurada.
				//Se __cNumPsag = 1, primeira. Se 2 = Segunda. Se 3, mal configurado e o usuario deve selecionar a pesagem.
				If lBalanca
					__cNumPsag := 3
					dbSelectArea("N95")
					N95->(dbSetOrder(1))
					If DbSeek(FWxFilial("N95")+__cTipoOp + __cEtapa)
						
							lPeso1 := EMPTY(NJJ->NJJ_PESO1)
							lPeso2 := EMPTY(NJJ->NJJ_PESO2)
							
							Do Case
								Case lPeso1 .And. lPeso2
									__cNumPsag := 3
								Case lPeso1
									__cNumPsag := 1
								Case lPeso2
									__cNumPsag := 2
							EndCase						
							N95->(dbSkip())					
						//endIF
					EndIF
					N95->(dbCloseArea())
				EndIf
			EndIf
			N94->(dbCloseArea())
		EndIf
		N93->(dbCloseArea())
	else
		//Caso o parmetro venha preenchido, significa que deve abrir uma função especificada no parametro.
		aArea := GetArea()
		
		if UPPER(cParametro) == "PESAGEM"	
			lBalanca := .T.
				
			cQry := "SELECT N95_CAMPO FROM "+RetSQLName("N93")+" N93 INNER JOIN "+RetSQLName("N94")+" N94 ON N93_FILIAL = N94_FILIAL " +;
				    "   AND N93_CODTO  = N94_CODTO " +;
				    "   AND N93_CODIGO = N94_CODETP " +;
				    "   AND N93.D_E_L_E_T_ = ' ' " +;
					"   AND N94.D_E_L_E_T_ = ' ' " +;
				    " INNER JOIN "+RetSQLName("N95")+" N95 ON N94_FILIAL = N95_FILIAL " +;
				    "   AND N94_CODTO  = N95_CODTO" +;
				    "   AND N94_CODETP = N95_CODETP" +;
				    "   AND N94_QTCPES = 'T' " +;
				    "   AND N95.D_E_L_E_T_ = ' '" +;
				    " WHERE N93_FILIAL = '" + FWXFILIAL("N93") + "' " +;
				    "   AND N93_CODTO  = '" + __cTipoOp + "' "  +;
				    "   AND N93_CDPTCT = '" + cCdPtCt + "' " 
				     
			cRetQry := GetSqlAll(cQry)
			
			While !(cRetQry)->(EOF())
				if ((cRetQry)->N95_CAMPO = "NJJ_PESO1" .OR. (cRetQry)->N95_CAMPO = "NJJ_PESO2")  
					if (cRetQry)->N95_CAMPO = "NJJ_PESO1"
						lPeso1 := .T.
						__cNumPsag := 1
						exit
					elseIf (cRetQry)->N95_CAMPO = "NJJ_PESO2"
						lPeso2 := .T.
						__cNumPsag := 2
						exit
					endIf
				endIf
				(cRetQry)->(dbSkip())
			EndDo
			
			RestArea(aArea)
			
		endIf
	endIf
	
	If .Not. Empty(cCodRom)
		dbSelectArea("NJJ")
		NJJ->(dbSetOrder(1))
		NJJ->(dbSeek( FWxFilial( "NJJ" ) + cCodRom))
		oView:SetOperation(MODEL_OPERATION_UPDATE)
	Else
		oView:SetOperation(MODEL_OPERATION_INSERT)
	EndIf

	If lBalanca
		oModel := FWLoadModel('AGRA500')
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		AGRA500P(oModel, "GRID", cParametro)
	Else
		aCoors := FWGetDialogSize(oMainWnd)

		oView:EnableControlBar(.T.)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
		//
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize((aCoors[3]* 0.8 ),(aCoors[4]* 0.8 ))
		oFWMVCWindow:SetTitle(cDescEtp)    
		oFWMVCWindow:SetEscClose(.T.)
		oFWMVCWindow:SetStyle(2)

		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
	EndIf
Return lRet


/*/{Protheus.doc} A500GATST
//Gatilho para atualizar o campo NJJ_STATUS

@author ana.olegini
@since 21/05/2018
@return cStatus, Status do Romaneio NJJ_STATUS
/*/
Static Function A500GATST( )
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local cStsCla	:= oNJJ:GetValue( "NJJ_STSCLA" )
	Local cStsPes	:= oNJJ:GetValue( "NJJ_STSPES" )
	Local nPsSubt	:= oNJJ:GetValue( "NJJ_PSSUBT" )
	Local cStatus 	:= oNJJ:GetValue( "NJJ_STATUS" )
	Local lSimbolico:= ( oNJJ:GetValue( "NJJ_TIPENT" ) == "2" ) //0=Físico;1=Gerencial;2=Simbolico;3=Retenção
	
	//Se Peso Subtotal maior que Zero .OU. Romaneio Simbolico
	If nPsSubt > 0 .OR. lSimbolico
		oNJJ:LoadValue( "NJJ_STSPES", "2" ) //0=Sem Pesagem; 1=Primeira Pesagem; 2=Segunda Pesagem 
		cStsPes := "2"		 //2=Segunda Pesagem
	EndIf
	
	//Se 2=Segunda Pesagem .AND. 1=Classificado
	If cStsPes == "2" .AND. cStsCla == '1'
		cStatus := "1"		//Status do Romaneio = 1-Completo.
	EndIf

Return( cStatus )

/*/{Protheus.doc} A500GATPL
//Gatilho para recalcular quantidades de desconto e retornar o Peso Liquido (NJJ_PSLIQU)
//FUNÇÃO fTrgPesoLiq() da rotina OGA250.
@author ana.olegini
@since 	23/05/2018
@param 	oModel, object, Modelo de dados
@return nRetorno, Retorna o valor do pelo liquido
/*/
Static Function A500GATPL( oModelNJJ )
	Local oModel		:= oModelNJJ:GetModel( "AGRA500" )
	Local lSimbolico	:= Iif(oModel:HasField("AGRA500_NJJ","NJJ_TIPENT"),( oModelNJJ:GetValue( "NJJ_TIPENT" ) == "2" ),.F.)
	Local nRetorno		:= 0
	Local nPsSubt		:= Iif(oModel:HasField("AGRA500_NJJ","NJJ_PSSUBT"),oModelNJJ:GetValue( "NJJ_PSSUBT"),0)
	Local nPsDesc		:= Iif(oModel:HasField("AGRA500_NJJ","NJJ_PSDESC"),oModelNJJ:GetValue( "NJJ_PSDESC"),0)
	Local lAlgodao 		:= If(Posicione("SB5",1,fwxFilial("SB5")+M->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	Local nPsExtr       := Iif(oModel:HasField("AGRA500_NJJ","NJJ_PSEXTR"),oModelNJJ:GetValue( "NJJ_PSEXTR"),0)
	Local nPsEmba       := Iif(oModel:HasField("AGRA500_NJJ","NJJ_PESEMB"),oModelNJJ:GetValue( "NJJ_PESEMB"),0)
	 	
	//--Realiza o recalculo dos descontos e trabalha com a tabela NJM
	OGA250ATUG()
	If lAlgodao
		oModelNJJ:LoadValue( "NJJ_PSBASE", nPsSubt - nPsDesc )
		oModelNJJ:LoadValue( "NJJ_PSLIQU", nPsSubt - ( nPsDesc + nPsExtr ) - nPsEmba)
	EndIf
	
	//Carrega o novo campo NJJ_PESO3 com o valor do campo NJJ_PSLIQU - DAGROGAP-446
	If oModel:HasField("AGRA500_NJJ","NJJ_PSLIQU")
		oModelNJJ:LoadValue( "NJJ_PESO3", oModelNJJ:GetValue( "NJJ_PSLIQU" ) ) 
	EndIf
	// Se for romaneio simbólico
	If lSimbolico
		oModelNJJ:SetValue( "NJJ_STSPES", "2" ) // 0=Sem Pesagem; 1=Primeira Pesagem; 2=Segunda Pesagem 
		If Empty(oModelNJJ:GetValue( "NJJ_DATPS1"))
			oModelNJJ:SetValue( "NJJ_DATPS1", dDataBase )
		EndIf
		
		If Empty(oModelNJJ:GetValue( "NJJ_HORPS1"))
			oModelNJJ:SetValue( "NJJ_HORPS1", Substr( Time(), 1, 5 ) )
		EndIf
		
		oModelNJJ:SetValue( "NJJ_PESO1" , nPsSubt )
		oModelNJJ:SetValue( "NJJ_MODPS1", "M" )
		
		If Empty(oModelNJJ:GetValue( "NJJ_DATPS2"))
			oModelNJJ:SetValue( "NJJ_DATPS2", dDataBase )
		EndIf
		
		If Empty(oModelNJJ:GetValue( "NJJ_HORPS2"))
			oModelNJJ:SetValue( "NJJ_HORPS2", Substr( Time(), 1, 5 ) )
		EndIf
		
		oModelNJJ:SetValue( "NJJ_PESO2" , 0 )
		oModelNJJ:SetValue( "NJJ_MODPS2", "M" )
	EndIf
	
	If oModel:HasField("AGRA500_NJJ","NJJ_PSLIQU")
		nRetorno := oModelNJJ:GetValue( "NJJ_PSLIQU" )
	Else
		nRetorno := 0
	EndIf
Return( nRetorno )


/** {Protheus.doc} fVldNJJ3
Função de validação de vários campos da NJJ e preenchimento automatico da NJM

@param: 	Nil
@author: 	Marlon Richarda trettin
@since: 	16/07/2015
@Uso: 		SIGAAGR
*/
Static Function A500VLDVR( oField )
	Local oModel		:= FwModelActive()
	Local oNJM			:= oModel:GetModel( "AGRA500_NJM" )
	Local oNJJ			:= oModel:GetModel( "AGRA500_NJJ" )
	Local nLinha 		:= oNJM:GetLine()
	Local oView			:= FWViewActive()

	oNJM:GoLine( 1 )

	If oNJJ:GetValue( "NJJ_STATUS" ) $ "2|3" .and. !lExecAgoClas
		Help('' ,1,".AGRA50000025.", , ,1,0) //Não é permitido alterar este Romaneio com Status -Atualizado- ou -Confirmado-.#Somente Romaneio com status -Pendente- e -Completo-.
		Return( .F. )
	EndIf

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|4|6|8|B"; // Se tipo do romaneio for de SAÍDA
	.And. oNJJ:GetValue( "NJJ_TPFORM" ) <> "1"  // e Formulário Próprio for diferente de SIM
		Help('' ,1,".AGRA50000026.", , ,1,0) //Para romaneios de SAÍDA, é obrigatório informar o Formulário Próprio igual a SIM.#Informe o Formulário Próprio igual a SIM.
		Return( .F. )
	Else
		oNJM:SetValue( "NJM_TPFORM", oNJJ:GetValue( "NJJ_TPFORM" ) )
	EndIf

	If !Empty(oNJJ:GetValue( "NJJ_QTDFIS" ))
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

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "1|2|3|4|5|A|B"
		oNJM:LoadValue( "NJM_TRANS", "1" )	// 1=Entrega
	Else
		oNJM:LoadValue( "NJM_TRANS", "2" )	// 2=Devolução
	EndIf

	//Atualizar o campo NJM_QTDFCO com o informado no campo NJJ_PSLIQU
	oNJM:LoadValue( "NJM_QTDFCO", oNJJ:GetValue("NJJ_PSLIQU"))  
	
	IF !Type('oView') == 'U'
		oView:Refresh()
	EndIf

	oNJM:GoLine( nLinha )
Return( .T. )


/*/{Protheus.doc} A500GTCEN
//Gatilho para atualizar o campo NJJ_ENTENT

@author ana.olegini
@since 21/05/2018
@return cCodEnt, Codigo da entidade entrega NJJ_ENTENT
/*/
Static Function A500GTCEN()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local cCodEnt	:= ''

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|3|4|5|6|7|8|9"
		cCodEnt := oNJJ:GetValue( "NJJ_CODENT" )
	EndIf		

Return(cCodEnt)


/*/{Protheus.doc} A500GTLEN
//Gatilho para atualizar o campo NJJ_ENTLOJ

@author ana.olegini
@since 21/05/2018
@return cCodEnt, Codigo da loja da entidade entrega NJJ_ENTLOJ
/*/
Static Function A500GTLEN()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local cLojEnt	:= ''

	If oNJJ:GetValue( "NJJ_TIPO" ) $ "2|3|4|5|6|7|8|9"
		cLojEnt := oNJJ:GetValue( "NJJ_LOJENT" )
	EndIf		
Return(cLojEnt)


/*/{Protheus.doc} A500ATROM
//Atualiza as notas de entrada/saida no romaneio
@author brunosilva/ marina.muller
@since 12/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCli, characters, descricao
@param cFilOri, characters, descricao
@param cRomOri, characters, descricao
@param cRomDest, characters, descricao
@type function
/*/
Static Function A500ATROM(cRomOri, cRomDest)
    Local lRet		:= .T.
    Local aArea		:= GetArea()

    //busca nota e serie gerada na efetivação da transferência
    DbSelectArea("NNT")
    NNT->(dbSetOrder(1))
    If NNT->(MsSeek(__cNNTFil+__cNNTCod)) //filial+código transferência
    EndIf	  
    
	//Quando o Documento de Entrada é feito pela função acima (A311Efetiv)
	// ele não tem a TES gravada pois ele fica como um doc a classificar.
	// Precisamos da TES para emitir a NF entrada por devolução caso gere um devolução fiscal.
	dbSelectArea('SD1')
	SD1->(dbSetOrder(1))
	If SD1->(MsSeek(NNT->NNT_FILDEST+NNT->NNT_DOC+NNT->NNT_SERIE))
		If RecLock( "SD1", .F. )
			SD1->D1_TES := NNT->NNT_TE
			SD1->(msUnLock())
		EndIf
	EndIF
				
	//Vincula o romaneio criado na origem com a nota do doc. de entrada
	// gerada pela transferencia de estoque.
	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))
	If NJJ->(msSeek(NNT->NNT_FILDEST+cRomDest))   /*#########  ENTRADA  ########*/
		If RecLock( "NJJ", .F. ) .AND. (!(EMPTY(NNT->NNT_DOC)) .OR. (NNT->NNT_DOC != NIL))
			NJJ->NJJ_DOCNUM	:= NNT->NNT_DOC  		
			NJJ->NJJ_DOCSER	:= NNT->NNT_SERIE	
			NJJ->NJJ_DOCEMI := SD1->D1_EMISSAO
			NJJ->NJJ_QTDFIS := SD1->D1_QUANT	
			NJJ->NJJ_VLRUNI := SD1->D1_VUNIT
			NJJ->NJJ_VLRTOT := SD1->D1_TOTAL
			NJJ->NJJ_DIFFIS := M->NJJ_PSLIQU
			NJJ->NJJ_UM1PRO	:= M->NJJ_UM1PRO									
			NJJ->(msUnLock())
		Else
			lRet := .F.
		EndIf
	EndIf
	NJJ->(DbCloseArea())
		
	//Atualiza os campos da NJM.
	//Vincula o pedido e a nota de entrada ao romaneio de entrada por transferencia.
	dbSelectArea('NJM') 
	NJM->(dbSetOrder(1))							/*#########  ENTRADA  ########*/
	If NJM->(msSeek(NNT->NNT_FILDEST+cRomDest)) .AND. (!(EMPTY(NNT->NNT_DOC)) .OR. (NNT->NNT_DOC != NIL))							
		If RecLock( "NJM", .F. )
			NJM->NJM_PEDIDO := SC5->C5_NUM 
			NJM->NJM_DOCNUM	:= NNT->NNT_DOC  		
			NJM->NJM_DOCSER	:= NNT->NNT_SERIE	
			NJM->NJM_DOCITE := '01'	//Só fazemos um item por vez.
			NJM->NJM_UM1PRO := M->NJJ_UM1PRO							
			NJM->NJM_DOCEMI := SD1->D1_EMISSAO
			NJM->NJM_CHVNFE := SF1->F1_CHVNFE
			NJM->NJM_QTDFIS := SD1->D1_QUANT	
			NJM->NJM_VLRUNI := SD1->D1_VUNIT
			NJM->NJM_VLRTOT := SD1->D1_TOTAL
			NJM->(msUnLock())
		Else
			lRet := .F.
		EndIf
	EndIf
	NJM->(DbCloseArea())

	//Atualiza os campos da NJJ de saída.
	//Vincula o pedido e a nota de saida ao romaneio de saída por transferencia.
	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))							/*#########  SAIDA  ########*/
	If NJJ->(msSeek(NNT->NNT_FILORI+cRomOri)) .AND. (!(EMPTY(NNT->NNT_DOC)) .OR. (NNT->NNT_DOC != NIL))							
		If RecLock( "NJJ", .F. )
			NJJ->NJJ_DOCNUM	:= NNT->NNT_DOC  		
			NJJ->NJJ_DOCSER	:= NNT->NNT_SERIE	
			NJJ->NJJ_DOCEMI := SD1->D1_EMISSAO
			NJJ->NJJ_QTDFIS := SD1->D1_QUANT	
			NJJ->NJJ_VLRUNI := SD1->D1_VUNIT
			NJJ->NJJ_VLRTOT := SD1->D1_TOTAL
			NJJ->NJJ_DIFFIS := M->NJJ_PSLIQU
			NJJ->NJJ_UM1PRO	:= M->NJJ_UM1PRO	
			NJJ->(msUnLock())
		Else
			lRet := .F.
		EndIf
	EndIf
	NJJ->(DbCloseArea())
		
	//Atualiza os campos da NJM.
	//Vincula o pedido e a nota de saida ao romaneio de saída por transferencia.
	dbSelectArea('NJM')
	NJM->(dbSetOrder(1))							/*#########  SAIDA  ########*/
	If NJM->(msSeek(NNT->NNT_FILORI+cRomOri)) .AND. (!(EMPTY(NNT->NNT_DOC)) .OR. (NNT->NNT_DOC != NIL))							
		If RecLock( "NJM", .F. )
			NJM->NJM_PEDIDO := SC5->C5_NUM 
			NJM->NJM_DOCNUM	:= NNT->NNT_DOC  		
			NJM->NJM_DOCSER	:= NNT->NNT_SERIE	
			NJM->NJM_DOCITE := '01'	
			NJM->NJM_UM1PRO := M->NJJ_UM1PRO
			NJM->NJM_DOCEMI := SD1->D1_EMISSAO
			NJM->NJM_CHVNFE := SF1->F1_CHVNFE
			NJM->NJM_QTDFIS := SD1->D1_QUANT	
			NJM->NJM_VLRUNI := SD1->D1_VUNIT
			NJM->NJM_VLRTOT := SD1->D1_TOTAL
			NJM->(msUnLock())
		Else
			lRet := .F.
		EndIf
	EndIf
	NJM->(DbCloseArea())
		
	SD1->(DbCloseArea())
	NNT->( DbCloseArea())
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A500Leg
Legenda para status de classificação 
@author silvana.torres
@since 02/07/2018
@version undefined

@type function
/*/
Function A500Leg()
	Local oLegenda  :=  FWLegend():New()     // Objeto FwLegend.
		
	oLegenda:Add( "NJJ_STSCLA=='0'"  , "RED"         , X3CboxDesc( "NJJ_STSCLA", "0" )   ) //"Não Classificado"
	oLegenda:Add( "NJJ_STSCLA=='1'"  , "GREEN"  	 , X3CboxDesc( "NJJ_STSCLA", "1" )   ) //"Classificado"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return(.T.)

/*/{Protheus.doc} A500TESINT
//Verifica se gatilha TES inteligente
@author marina.muller
@since 30/08/2018
@version 1.0
@return ${return}, ${return_description}
@param oNJJ, object, descricao
@param oNJM, object, descricao
@type function
/*/
Static Function A500TESINT(oNJJ, oNJM)
	Local lRet   	:= .T.
	Local cTes      := ""
	Local nLinha    := oNJM:GetLine()
	Local nX	    := 0
	
	If !Empty(oNJJ:GetValue("NJJ_TOETAP")) .And.; 
	   !Empty(oNJJ:GetValue("NJJ_TIPO"))   .And.;
	   !Empty(oNJJ:GetValue("NJJ_CODENT")) .And.;
	   !Empty(oNJJ:GetValue("NJJ_LOJENT")) .And.;
	   !Empty(oNJJ:GetValue("NJJ_CODPRO"))
	   
	   //busca TES inteligente (AGRX500.prw)
	   cTes := AGRX500TIN(oNJJ:GetValue("NJJ_TOETAP"),;  //tipo de operação
	                      oNJJ:GetValue("NJJ_TIPO"),;    //tipo do romaneio
	                      oNJJ:GetValue("NJJ_CODENT"),;  //entidade
	                      oNJJ:GetValue("NJJ_LOJENT"),;  //loja
	                      oNJJ:GetValue("NJJ_CODPRO"))   //produto
	                      
	   If !Empty(cTes)
			oNJJ:SetValue("NJJ_TES", cTes)
			
			nLinha := oNJM:GetLine()
			For nX := 1 to oNJM:Length()
				oNJM:GoLine( nX )
				oNJM:SetValue("NJM_TES", cTes)
			Next nX
			oNJM:GoLine( nLinha )
	   EndIf 
	EndIf

Return lRet


/*/{Protheus.doc} A500GTTB
// Gatilha a tabela de desconto caso o produto tenha uma.
@author brunosilva
@since 24/10/2018
@version 1.0
@return cTabela, character
@param oModel, object
@type function
/*/
Function A500GTTB(oModel)
	Local cCodPro 	:= M->NJJ_CODPRO
	Local oMdlNJJ	:= Nil
	Local lGraos	:= (Posicione("SB5",1,FWxFilial("SB5")+cCodPro,"B5_TPCOMMO") != '2')
	Local cTabela	:= ''
	Local cQry		:= ""
	Local cDB 		:= TcGetDB()
	Local cStrDt	:= ''
	
	Default oModel := iif(Empty(oModel), FwLoadModel('AGRA500'), )
	
	oMdlNJJ	:= oModel:GetModel('AGRA500_NJJ')  
	
	if M->NJJ_TIPO $ '1|A|B' .AND. lGraos 
		If cDb = 'MSSQL'
			cStrDt := " GETDATE() "
		ElseIf cDb = "ORACLE"
			cStrDt := " SYSDATE "
		EndIf
		
		cQry := "SELECT NNI.NNI_CODIGO FROM "+RetSqlName("NNI")+" NNI "
		cQry += "WHERE NNI_TABPDR = '1' "
		cQry += "AND NNI_CODPRO = '"+ cCodPro +"' "
		cQry += "AND " + cStrDt + " BETWEEN " + cCpoDataDB("NNI_DATINI") + " AND " + cCpoDataDB("NNI_DATFIM") + " "
		
		cTabela := getDataSql(cQry)		
		
	endIf
	
Return cTabela


/*/{Protheus.doc} cCpoDataDB
// Reponsável por tratar os campos de data.
@author brunosilva
@since 24/10/2018
@version 1.0
@return cData, Date
@param cCpoData, characters
@type function
/*/
Static Function cCpoDataDB(cCpoData)
	Local cDB := TcGetDB()
	
	If cDb = 'MSSQL'
		cData := cCpoData
	ElseIf cDb =  "ORACLE"
		cData := "TO_DATE(" + cCpoData + ", 'YYYYMMDD')"
	EndIf
Return cData


/*/{Protheus.doc} AGRA500WP3
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 30/10/2018
@version 1.0
@return ${return}, ${return_description}
@param tpVld, , descricao
@type function
/*/
Function AGRA500WP3(tpVld)
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local lRetorno	:= .T.

	If (tpVld == "NJJ_PESO3" .OR. tpVld == "NJJ_DATCHE" .OR. tpVld == "NJJ_HORCHE") .AND. !IsInCallStack("AGRA500E")
		If .Not. oNJJ:GetValue("NJJ_TIPO") $ '2|4' .Or. (oNJJ:GetValue("NJJ_TIPO") $ '2|4' .And. !__lChkAgoC) .Or. oNJJ:GetValue("NJJ_PESO3") <= 0 .Or. (oNJJ:GetValue("NJJ_TIPO") $ '2|4' .and. .Not. FwIsInCallStack("AGOCLAS") /*!lExecAgoClas*/)
			//se for venda e o parametro MV_AGOCLASS não estiver ativo
			// se NJJ_PESO3 não tiver valor - para tratar os registros antes de implementar controle fisico/fiscal, neste caso NJJ_PESO3 não existia e quando criado seu valor é em branco
			lRetorno  := .F. //desabilita campo NJJ_PESO3
		EndIf
	EndIf
	
Return lRetorno

/*/{Protheus.doc} A500GTN9A
// Preenche os campos que são referentes à IE.
@author brunosilva
@since 24/10/2018
@version 1.0
@return cTabela, character
@param oModel, object
@type function
/*/
Function A500GTN9A()

	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= oModel:GetModel( "AGRA500_NJJ" )
	Local oNJM		:= oModel:GetModel( "AGRA500_NJM" )
	Local oN9E		:= oModel:GetModel( "AGRA500_N9E" )	
	Local lRet      := .T.
	Local cTabela	:= ""
	Local cCodSaf	:= ""
	Local cCodEnt	:= ""
	Local cLojEnt	:= ""

	lRet := AGRX500IE()

	If lRet 

		DbSelectArea('N7S')
		DbSetOrder(3)

		If DBSeek(FWxFilial("N7S")+ oN9E:GetValue('N9E_CODINE'))
			If Empty(Alltrim(oNJM:GetValue('NJM_TES'))) 
				oNJM:SetValue('NJM_TES', N7S->N7S_TES)
			Endif

			If Empty(Alltrim(oNJM:GetValue('NJM_OPEFIS')))
				oNJM:SetValue('NJM_OPEFIS', N7S->N7S_OPEFIS)
			Endif
			
			if !Empty(cTabela := Posicione("NJR",1,FWxFilial("NJR")+N7S->N7S_CODCTR,"NJR_TABELA"))
				oNJJ:SetValue('NJJ_TABELA', cTabela)
			endIf
			
			if !Empty(cCodSaf := Posicione("NJR",1,FWxFilial("NJR")+N7S->N7S_CODCTR,"NJR_CODSAF"))
				oNJJ:SetValue('NJJ_CODSAF', cCodSaf)
			endIf
			
			if !Empty(cCodEnt := Posicione("NJR",1,FWxFilial("NJR")+N7S->N7S_CODCTR,"NJR_CODENT"))
				oNJJ:SetValue('NJJ_CODENT', cCodEnt)
			endIf
			
			if !Empty(cLojEnt := Posicione("NJR",1,FWxFilial("NJR")+N7S->N7S_CODCTR,"NJR_LOJENT"))
				oNJJ:SetValue('NJJ_LOJENT', cLojEnt)
			endIf
			
		Endif
		N7S->(DbCloseArea())	
		RestArea(aArea)
	
	Endif

Return lRet


/*/{Protheus.doc} A500GTNMMT
//Trigger para obter nome do motorista
@author carlos.augusto
@since 21/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500GTNMMT()
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	Local cCGC		:= oNJJ:GetValue( "NJJ_CGC" )
	Local cNomeMot	:= Space(TamSX3("NJJ_NOMMOT")[1])
	
	cCGC := StrTran(cCGC, ".", "")
	cCGC := StrTran(cCGC, "/", "")
	cCGC := StrTran(cCGC, "-", "")
	cNomeMot := Posicione("DA4",3,fwxFilial("DA4") + cCGC,"DA4_NOME")
	RestArea(aArea)
Return cNomeMot


/*/{Protheus.doc} A500GTCODMT
//Gatilho Cod Motorista
@author carlos.augusto
@since 23/02/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function A500GTCODMT()
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	Local cCGC		:= oNJJ:GetValue( "NJJ_CGC" )
	Local cCodMot	:= Space(TamSX3("NJJ_CODMOT")[1])
	
	cCGC := StrTran(cCGC, ".", "")
	cCGC := StrTran(cCGC, "/", "")
	cCGC := StrTran(cCGC, "-", "")
	cCodMot := Posicione("DA4",3,fwxFilial("DA4") + cCGC,"DA4_COD")
	RestArea(aArea)
Return cCodMot


/*/{Protheus.doc} A500GTCGC
//Gatilho CGC
@author carlos.augusto
@since 23/02/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function A500GTCGC()
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oNJJ		:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	Local cCodMot	:= oNJJ:GetValue( "NJJ_CODMOT" )
	Local cCGC		:= Space(TamSX3("NJJ_CGC")[1])
	
	cCGC := Posicione("DA4",1,fwxFilial("DA4") + cCodMot,"DA4_CGC")
	RestArea(aArea)
Return cCGC


/*/{Protheus.doc} A500VDTRAN
//Valid transportadora AGRA500
@author carlos.augusto
@since 23/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500VDTRAN()
	Local lRet   	 := .T.
	Local aArea  	 := GetArea()
	Local oModel	 := FwModelActive()
	Local oNJJ		 := IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))
	Local cCodTra	 := oNJJ:GetValue( "NJJ_CODTRA" )
	Local cEmitTmp   := SuperGetMv("MV_EMITMP",.F.,"0") //Modo de codificação do emitente de transporte
	Local cCGCIDFED  := "" 
	Local cTranspSN  := ""
	Local cEmit      := ""
	Local cAuton     := ""
	Local cNmGU3     := AllTrim(FWX2Nome("GU3")) //Emitentes de Transporte
	Local cDescTran  := ""
	Local cTitTransp := ""
    Local cOpcTransp := ""
    Local cTitAutono := ""
    Local cOpcAutono := ""
	
	If .Not. Empty(cCodTra)
	    //trabalha por 0=CNPJ/CPF
	    If Empty(cEmitTmp) .Or. cEmitTmp == "0" 
		    //busca transportadora pelo código emitente
			SA4->(dbSetOrder(1))    	
			If .Not. SA4->(DbSeek(FwxFilial("SA4") + cCodTra)) //A4_FILIAL+A4_COD
				HELP(' ',1,RetTitle("NJJ_CODTRA") ,,STR0142,2,0,,,,,, {STR0143 + STR0144 + STR0145})
				Return .F. //Cod. Transp. ### "Não existe registro relacionado a este código." ### "1) Informe um código que exista no cadastro." ### "2) Efetue o cadastro no programa de manutenção do respectivo cadastro." ### "3) Escolha um registro válido."
			EndIf  
		
		//trabalha por 1=Numeração própria
		Else
		    //busca transportadora pela numeração própria
			//Pegar CNPJ
			dbSelectArea("SA4")
			SA4->(dbSetOrder(1))
			If SA4->(DbSeek(FWxFilial("SA4")+cCodTra))
				cCGCIDFED := SA4->A4_CGC
				cDescTran := SA4->A4_NREDUZ
			EndIf
			SA4->(DbCloseArea())
			
			If Empty(cCGCIDFED)
				HELP(' ',1,RetTitle("NJJ_CODTRA") ,,STR0142,2,0,,,,,, {STR0143 + STR0144 + STR0145})
				Return .F. //Cod. Transp. ### "Não existe registro relacionado a este código." ### "1) Informe um código que exista no cadastro." ### "2) Efetue o cadastro no programa de manutenção do respectivo cadastro." ### "3) Escolha um registro válido."
			EndIf
			
			If lRet		
				dbSelectArea("GU3")
				GU3->(dbSetOrder(11))
				If GU3->(DbSeek(FWxFilial("GU3")+cCGCIDFED))
					//WHILE !(EOF()) .AND. GU3->GU3_IDFED = cCGCIDFED .AND. (GU3->GU3_TRANSP = '1' .OR. GU3->GU3_AUTON = '1') 
					While GU3->(!Eof()) .AND. GU3->GU3_IDFED = cCGCIDFED
						
						cTranspSN := GU3->GU3_TRANSP
						cEmit 	  := GU3->GU3_CDEMIT
						cAuton	  := GU3->GU3_AUTON
						If cTranspSN == "1" .OR. cAuton = '1'
							exit
						EndIf
						GU3->(dbSkip())
					EndDo
				Else
 					HELP(' ',1,cNmGU3,,STR0146+AllTrim(cDescTran)+", CGC: "+AllTrim(cCGCIDFED)+STR0147+cNmGU3+".",2,0,,,,,, {STR0148+cNmGU3+STR0149})
					Return .F.//"Emitentes de Transporte" ### "Problema de integração com o SIGAGFE, a transportadora: " ### ", CGC: " ### ", não foi encontrado no cadastro de " ### "Verifique se a transportadora selecionada consta no cadastro de " ### " do SIGAGFE."
				EndIf
				GU3->(DbCloseArea())
				
				If .Not. Empty(cTranspSN) .And. (cTranspSN == "2" .AND. cAuton == "2")
					cTitTransp := AllTrim(RetTitle("GU3_TRANSP"))         //"Transp?"
					cOpcTransp := AllTrim(X3CboxDesc( "GU3_TRANSP", "1" ))//"Sim"
					cTitAutono := AllTrim(RetTitle("GU3_AUTON"))          //"Autonomo?"
					cOpcAutono := AllTrim(X3CboxDesc( "GU3_AUTON", "1" )) //"Sim"

					HELP(' ',1,cNmGU3,,STR0150,2,0,,,,,, {STR0151 + cTitTransp + " = " + cOpcTransp + " ou " + cTitAutono + " = " + cOpcAutono + "."})  
					Return .F.//"Emitentes de Transporte" ### "Emitente inválido!" ### "O emitente deve ser configurado: " ### " ou "
				EndIf
				
				If Empty(cEmit)
					HELP(' ',1,cNmGU3,,STR0146+AllTrim(cDescTran)+", CGC: "+AllTrim(cCGCIDFED)+STR0147+cNmGU3+".",2,0,,,,,, {STR0148+cNmGU3+STR0149})
					Return .F.//"Emitentes de Transporte" ### "Problema de integração com o SIGAGFE, a transportadora: " ### ", com CGC: " ### ", não foi encontrado no cadastro de " ### "Verifique se a transportadora selecionada consta no cadastro de " ### " do SIGAGFE."
				EndIf
			Endif
		
		EndIf
	EndIf
	RestArea(aArea) 
Return lRet
