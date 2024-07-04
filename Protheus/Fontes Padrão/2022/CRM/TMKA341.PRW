#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "COLORS.CH"  
#INCLUDE "TMKA341.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "CRMDEF.CH"

Static aAOVMark := {}
Static lCRMTerr	:= Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA341

Cadastro de Suspects

@sample 	TMKA341( xRotAuto, nOpc, cFilDef, aAddFil )

@param		xRotAuto - Vetor com campos da enchoice utilizado em ExecAuto 
@param		nOpc	 - Opcao da execauto selecionada:3-Inclui,4-Altera,etc
			cFilDef  - Filtro padrão do Browse
			aAddFil  - Adiciona um filtro na lista de opcoes do Browse 

@return   	Nil

@author		Vendas CRM
@since		12/07/2001
@version	12
/*/
//------------------------------------------------------------------------------
Function TMKA341(xRotAuto, nOpc, cFilDef, aAddFil)

Local lTK341MEMO 	:= ExistBlock( "TK341MEMO" )	  // P.E  Para capturar os campos memo do usuario para serem atualizados no cadastro de suspects
Local nX			:= 0  
Local lRet			:= .T.

Default xRotAuto	:= Nil 
Default nOpc		:= 1 //Visualizar
Default cFilDef		:= ""
Default aAddFil		:= {}
						 
Private cCadastro   := STR0080   	//"Suspect"
Private aMemos	  	:= {}			// Campos MEMO do usuario
Private aRotina     := {}

If nModulo == 73
	aRotina := FwLoadMenuDef("CRMA320")
Else	
	aRotina := MenuDef()
EndIf

//------------------------------------------------------------
// Definicao de variaveis para rotina de inclusao automatica 
//------------------------------------------------------------
Private lTk341Auto := ( xRotAuto <> NIL )

// Criado o model como estatico para evitar de carregar o model quando a rotina automatica é chamada mais de uma vez. Evitando assim estouro de memoria.
Static oModel		 := Nil	                        

If lTK341MEMO
	aMemos := ExecBlock( "TK341MEMO", .F., .F. )
	If ( ValType( aMemos ) <> "A" )
		aMemos := {}
	Endif 
Endif

If ( nOpc == NIL )
	nOpc := 3
Else
	nOpc := nOpc
Endif                                             

If lTk341Auto

	ACH->(DbCloseArea())

	aRotina := MenuDef()
	If oModel == Nil
		oModel := 	ModelDef()	
	EndIf
	FWMVCRotAuto( oModel, "ACH", nOpc, { { "ACHMASTER", xRotAuto } } )
Else
	//-------------------------------------------
	//Browse de Prospect. 
	//-------------------------------------------
	BrowseDef( /*oMBrowse*/, cFilDef, aAddFil )
EndIf	 

//Limpa o array de marcacao do Segmentos para nova carga.
aAOVMark := {}

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse de Cadastro de Suspect

@sample	BrowseDef( oMBrowse, cFilDef, aAddFil, cVDefault )

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
			cFilDef	, Caracter	, Filtro padrao.
			aAddFil	, Array		, Filtros relacionados.
			
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		05/12/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse, cFilDef, aAddFil )

Local oTableAtt 	:= Nil
Local lWidget		:= .F.
Local nX			:= 0
Local lTK341Fil	:= ExistBlock( "TK341FIL" ) //Ponto de entrada para filtrar o Browse ACH
Local cMainProc := IIF(nModulo==73,"CRMA320","TMKA341")
Local cFiltraACH	:= ""
Local aCores		:= {	{ "ACH->ACH_STATUS == '0'", "BR_BRANCO"  , STR0052  } ,; // Mailing
							{ "ACH->ACH_STATUS == '1'", "BR_MARROM"  , STR0053	 } ,; // Classificado
		   				{ "ACH->ACH_STATUS == '2'", "BR_VERMELHO", STR0054	 } ,; // Desenvolvimento
		   				{ "ACH->ACH_STATUS == '3'", "BR_AZUL"    , STR0055	 } ,; // Gerente
							{ "ACH->ACH_STATUS == '4'", "BR_AMARELO" , STR0056	 } ,; // Standy by
							{ "ACH->ACH_STATUS == '5'", "BR_PRETO"   , STR0057	 } ,; // Cancelado
							{ "ACH->ACH_STATUS == '6'", "BR_VERDE"   , STR0058	 } ,; // Prospect
							{ "Empty(ACH->ACH_STATUS)", "BR_CINZA"   , STR0083	 } }  // (sem status)	

Default oMBrowse		:= {}
Default cFilDef		:= ""
Default aAddFil		:= {}

If Empty( oMBrowse )
	//----------------
	// Cria o Browse 
	//----------------
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("ACH")
Else
	lWidget	:= .T.
EndIf

oMBrowse:SetCanSaveArea(.T.) 

For nX := 1 To Len( aCores )
	oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
Next nX

//---------------------------------
//³ Filtro Default do Browse.
//---------------------------------
If !Empty( cFilDef )
	oMBrowse:SetFilterDefault( cFilDef )
EndIf

//---------------------------------
//³ Filtros adicionais do Browse.   
//---------------------------------
For nX := 1 To Len( aAddFil )
	oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
					      aAddFil[nX][ADDFIL_EXPR], ;
					      aAddFil[nX][ADDFIL_NOCHECK], ;
					      aAddFil[nX][ADDFIL_SELECTED], ;
					      aAddFil[nX][ADDFIL_ALIAS], ;
					      aAddFil[nX][ADDFIL_FILASK], ;
					      aAddFil[nX][ADDFIL_FILPARSER], ;
					      aAddFil[nX][ADDFIL_ID] )
	oMBrowse:ExecuteFilter()	
Next nX	

//-------------------------------------
// Ponto de entrada para filtrar o ACH
//-------------------------------------	
If lTK341Fil
	cFiltraACH := AllTrim( ExecBlock( "TK341FIL", .F., .F. ) )
	If Valtype( cFiltraACH ) == "C" .AND. !Empty( cFiltraACH )
		oMBrowse:AddFilter( STR0139, cFiltraACH, .T., .T. ) // "Filtro de Usuário"
		oMBrowse:ExecuteFilter()
	EndIf
EndIf	

oMBrowse:SetDescription( STR0008 ) // Atualizacao de Suspect

If !lWidget
	oTableAtt 	:= TableAttDef()	
	oMBrowse:SetAttach( .T. ) 				  //Habilita as visões do Browse
	oMBrowse:SetViewsDefault( oTableAtt:aViews )  
	oMBrowse:SetChartsDefault( oTableAtt:aCharts ) //Passa o gráfico para o Browse
	oMBrowse:SetIDChartDefault( "PorVend" )
			
		//Se não for SIGACRM inibe a exibição do gráfico
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf
	oMBrowse:SetMainProc(cMainProc)	
	oMBrowse:SetTotalDefault('ACH_CODIGO','COUNT',STR0102) //'Total de Registros'
	oMBrowse:Activate()			
EndIf
	
Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

//Visões
Local oMyAbertos	:= Nil // Meus Suspects Abertos
Local oAbertos		:= Nil // Suspects Abertos
Local oQualif		:= Nil // Suspects Qualificados
Local oDesqual		:= Nil // Suspects Desqualificados
//Gráficos
Local oPorOrig		:= Nil // Pizza: Suspects por Origem
Local oPorCamp		:= Nil // Colunas: Suspects por Campanha de Origem
Local oTaxa			:= Nil // Linha: Taxa de Geração de Suspects por Mês
Local oPorStatus	:= Nil // Colunas: Suspects por Status
Local oPorVend		:= Nil // Colunas: Suspects por Vendedor
Local oTableAtt 	:= Nil
Local lTMKV341View	:= ExistBlock("CRMBRWVIEW")	//Ponto entrada para manipulação das views padrão
Local cRotina		:= "TMKA341"
Local cAliasView	:= "ACH"
Local aUserPaper	:= {}
Local cCodUser	 	:= " " 
Local cSeqPaper		:= " "		

If lTMKV341View 
	oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
EndIf

If Empty ( oTableAtt ) 

	oTableAtt 	:= FWTableAtt():New()
	oTableAtt:SetAlias("ACH")

	//----------
	// Visões
	//---------- 
	If ( IsInCallStack("CRMA320") .Or. IsInCallStack("CRMA290") .Or. IsInCallStack("CRMA290A") .Or. IsInCallStack( "CRM290CWGT" ) )
		aUserPaper := CRMXGetPaper()
		
		If ! Empty( aUserPaper )
			cCodUser  := aUserPaper[USER_PAPER_CODUSR]
			cSeqPaper := aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER]
		Else
			cCodUser  := If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 
		EndIf
		
		// Meus Suspects Abertos		
		oMyAbertos := FWDSView():New()
		oMyAbertos:SetName(STR0093) //"Meus Suspects Abertos"
		oMyAbertos:SetID("MyAbertos") 
		oMyAbertos:SetOrder(1) // ACH_FILIAL+ACH_CODIGO+ACH_LOJA
		oMyAbertos:SetCollumns({	"ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_NFANT","ACH_DDD","ACH_TEL",;
									"ACH_EMAIL","ACH_END","ACH_BAIRRO","ACH_CIDADE","ACH_EST","ACH_ORIGEM","ACH_STATUS"})
		oMyAbertos:SetPublic( .T. )
		oMyAbertos:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'ACH_FILIAL+ACH_CODIGO+ACH_LOJA' )   	
		oMyAbertos:AddFilter(STR0093, "!ACH_STATUS $ '5,6'") //"Meus Suspects Abertos"
		If !Empty( aUserPaper )
			oMyAbertos:AddFilter(STR0093, "AO4_ENTIDA == 'ACH' .And. AO4_CODUSR == '" + cCodUser + "' .And. ( AO4_USRPAP == '" + cSeqPaper + "' .Or. AO4_USRPAP == ' ' ) .And. AO4_CTRLTT == .T.","AO4") //"Meus Suspects Abertos"
		Else
			oMyAbertos:AddFilter(STR0093, "AO4_ENTIDA == 'ACH' .AND. AO4_CODUSR == '"+cCodUser+"' .AND. AO4_CTRLTT == .T.","AO4") //"Meus Suspects Abertos"
		EndIf	
		
		oTableAtt:AddView(oMyAbertos)
	
	EndIf
	
	// Suspects Abertos		
	oAbertos := FWDSView():New()
	oAbertos:SetName(STR0094) //"Suspects Abertos"
	oAbertos:SetID("Abertos") 
	oAbertos:SetOrder(1) // ACH_FILIAL+ACH_CODIGO+ACH_LOJA
	oAbertos:SetCollumns({"ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_NFANT","ACH_DDD","ACH_TEL",;
								"ACH_EMAIL","ACH_END","ACH_BAIRRO","ACH_CIDADE","ACH_EST","ACH_ORIGEM","ACH_STATUS"})
	oAbertos:SetPublic( .T. )
	oAbertos:AddFilter(STR0094, "!ACH_STATUS $ '5,6'") //"Suspects Abertos"
	
	oTableAtt:AddView(oAbertos)
	
	// Suspects Qualificados		
	oQualif := FWDSView():New()
	oQualif:SetName(STR0095) //"Suspects Qualificados"
	oQualif:SetID("Qualif") 
	oQualif:SetOrder(1) // ACH_FILIAL+ACH_CODIGO+ACH_LOJA
	oQualif:SetCollumns({"ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_NFANT","ACH_DDD","ACH_TEL",;
								"ACH_EMAIL","ACH_END","ACH_BAIRRO","ACH_CIDADE","ACH_EST","ACH_ORIGEM","ACH_STATUS"})
	oQualif:SetPublic( .T. )
	oQualif:AddFilter(STR0095, "ACH_STATUS == '6'") //"Suspects Qualificados"
	
	oTableAtt:AddView(oQualif)
	
	// Suspects Desqualificados		
	oDesqual := FWDSView():New()
	oDesqual:SetName(STR0096) //"Suspects Desqualificados"
	oDesqual:SetID("Desqual") 
	oDesqual:SetOrder(1) // ACH_FILIAL+ACH_CODIGO+ACH_LOJA
	oDesqual:SetCollumns({"ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_NFANT","ACH_DDD","ACH_TEL",;
								"ACH_EMAIL","ACH_END","ACH_BAIRRO","ACH_CIDADE","ACH_EST","ACH_ORIGEM","ACH_STATUS"})
	oDesqual:SetPublic( .T. )
	oDesqual:AddFilter(STR0096, "ACH_STATUS == '5'")	//"Suspects Desqualificados" 
	
	oTableAtt:AddView(oDesqual)

EndIf

//------------
// Gráficos
//------------	

// Pizza: Suspects por Origem
oPorOrig := FWDSChart():New()
oPorOrig:SetName(STR0097) //"Suspects por Origem"
oPorOrig:SetTitle(STR0097) //"Suspects por Origem"
oPorOrig:SetID("PorOrig") 
oPorOrig:SetType("PIECHART")
oPorOrig:SetSeries({ {"ACH", "ACH_CODIGO", "COUNT"} })
oPorOrig:SetCategory( { {"ACH", "ACH_ORIGEM"} } )
oPorOrig:SetPublic( .T. )
oPorOrig:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorOrig:SetTitleAlign( CONTROL_ALIGN_CENTER ) 		

oTableAtt:AddChart(oPorOrig)	

// Colunas: Suspects por Campanha de Origem
oPorCamp := FWDSChart():New()
oPorCamp:SetName(STR0098) //"Suspects por Campanha de Origem"
oPorCamp:SetTitle(STR0098) //"Suspects por Campanha de Origem"
oPorCamp:SetID("oPorCamp") 
oPorCamp:SetType("BARCOMPCHART")
oPorCamp:SetSeries({ {"ACH", "ACH_CODIGO", "COUNT"} })
oPorCamp:SetCategory( { {"SUO", "UO_DESC"} } )
oPorCamp:SetPublic( .T. )
oPorCamp:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorCamp:SetTitleAlign( CONTROL_ALIGN_CENTER ) 

oTableAtt:AddChart(oPorCamp)	

// Linha: Taxa de Geração de Suspects por Data
oTaxa := FWDSChart():New()
oTaxa:SetName(STR0099) //"Taxa de Geração de Suspects por Data"
oTaxa:SetTitle(STR0099) //"Taxa de Geração de Suspects por Data"
oTaxa:SetID("Taxa") 
oTaxa:SetType("LINECHART")
oTaxa:SetSeries({ {"ACH", "ACH_CODIGO", "COUNT"} })
oTaxa:SetCategory( { {"ACH", "ACH_DTCAD"} } )
oTaxa:SetPublic( .T. )
oTaxa:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oTaxa:SetTitleAlign( CONTROL_ALIGN_CENTER ) 

oTableAtt:AddChart(oTaxa)	

// Colunas: Suspects por Status
oPorStatus := FWDSChart():New() 
oPorStatus:SetName(STR0100) //"Suspects por Status"
oPorStatus:SetTitle(STR0100) //"Suspects por Status"
oPorStatus:SetID("PorStatus") 
oPorStatus:SetType("BARCOMPCHART")
oPorStatus:SetSeries({ {"ACH", "ACH_CODIGO", "COUNT"} })
oPorStatus:SetCategory( { {"ACH", "ACH_STATUS"} } )
oPorStatus:SetPublic( .T. )
oPorStatus:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorStatus:SetTitleAlign( CONTROL_ALIGN_CENTER ) 	

oTableAtt:AddChart(oPorStatus)	

// Colunas: Suspects por Vendedor
oPorVend := FWDSChart():New()
oPorVend:SetName(STR0101) //"Suspects por Vendedor"
oPorVend:SetTitle(STR0101) //"Suspects por Vendedor"
oPorVend:SetID("PorVend") 
oPorVend:SetType("BARCOMPCHART")
oPorVend:SetSeries({ {"ACH", "ACH_CODIGO", "COUNT"} })
oPorVend:SetCategory( { {"SA3", "A3_NOME"} } )
oPorVend:SetPublic( .T. )
oPorVend:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorVend:SetTitleAlign( CONTROL_ALIGN_CENTER ) 

oTableAtt:AddChart(oPorVend)	

Return (oTableAtt)	


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author		Vendas CRM
@since		02/02/12
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	   := {}
Local aRotAdic   := {}	
Local aEntRelac  := {}

Local lTk341Rot  := ExistBlock( "TK341ROT" ) // Retorno do P.E. TK341ROT para entrada automatica

ADD OPTION aRotina   TITLE STR0001 ACTION 'PesqBrw'         OPERATION 1  ACCESS 0 //'Pesquisar'
ADD OPTION aRotina   TITLE STR0002 ACTION "VIEWDEF.TMKA341" OPERATION 2  ACCESS 0//"Visualizar"

If !IsInCallStack( "CRMA710" ) 
	ADD OPTION aRotina   TITLE STR0003 ACTION "VIEWDEF.TMKA341" OPERATION 3  ACCESS 0//"Incluir"
EndIf

ADD OPTION aRotina   TITLE STR0004 ACTION "VIEWDEF.TMKA341" OPERATION 4  ACCESS 0//"Alterar" 	
ADD OPTION aRotina   TITLE STR0005 ACTION "VIEWDEF.TMKA341" OPERATION 5  ACCESS 0//"Excluir"
ADD OPTION aRotina   TITLE STR0051 ACTION "Tk341Legenda"    OPERATION 8  ACCESS 0//"Legenda"

ADD OPTION aEntRelac TITLE STR0041 ACTION "FtContato('ACH',ACH->(Recno()),3)"  OPERATION 4  ACCESS 0//"Contatos" 
ADD OPTION aEntRelac TITLE STR0007 ACTION "Tk341Prospect()"                    OPERATION 4  ACCESS 0//"Qualificação em Lote" 	
ADD OPTION aEntRelac TITLE STR0050 ACTION "MsDocument('ACH',ACH->(Recno()),3)" OPERATION 4  ACCESS 0//"Conhecimento"

ADD OPTION aRotina TITLE STR0110   ACTION "Tk341Desq()"	            OPERATION  6	 ACCESS 0 //"Desqualificação"
ADD OPTION aRotina TITLE STR0111   ACTION "TK341SaveDesq( 'R' )"	  OPERATION  6	 ACCESS 0 //"Reativação"
ADD OPTION aRotina TITLE STR0112   ACTION 'CRMA341Conv()'           OPERATION  7  ACCESS 0 //"Qualificação por Registro"

Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
ADD OPTION aRotina TITLE STR0088 ACTION aEntRelac 	    OPERATION 8  ACCESS 0//"Relacionadas"

//-------------------------------------------------
// Ponto de entrada - Adiciona rotinas ao aRotina 
//-------------------------------------------------
If lTk341Rot
	aRotAdic := ExecBlock( "TK341ROT", .F., .F.)
	If ValType( aRotAdic ) == "A"
		AEval( aRotAdic, { |x| AAdd( aRotina, x ) } )
	Endif
Endif

Return( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de Dados - Regra de Negócio	

@return   	oModel - Objeto do Modelo

@author		Vendas CRM
@since		02/02/12
@version	12
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruACH		:= FWFormStruct( 1, 'ACH', /*bAvalCampo*/, /*lViewUsado*/ )
Local bPosValidacao	:= { |oMdl| Tk341Pos( oMdl ) }
Local bCommit 		:= { |oMdl| Tk341Cmm( oMdl ) }		
Local bCancel 		:= { |oMdl| Tk341Can( oMdl ) }		    // Efetua o cancelamento

//SIGACRM - Atribuir o vendedor ao registro durante a inclusão
If nModulo == 73
	oStruACH:SetProperty( "ACH_VEND", MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "CRMXRetVend()" ) ) 
EndIf

If cPaisLoc == 'RUS' .AND. oStruACH:HasField('ACH_CGC')
	oStruACH:SetProperty('ACH_CGC', MODEL_FIELD_OBRIGAT, .F.)
EndIf
oModel := MPFormModel():New('TMKA341',/*bPreValidacao*/, bPosValidacao, bCommit,bCancel)
oModel :AddFields( 'ACHMASTER',/*cOwner*/,oStruACH,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/ )

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("ACHMASTER", oModel, "ACH" )

oModel :SetVldActivate( { |oMdl| Tk341Pre( oMdl ) } )
oModel :SetDescription( STR0008 )

Return( oModel )
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface

@return   	oView - Objeto da interface

@author		Vendas CRM
@since		02/02/12
@version	12
/*/
//------------------------------------------------------------------------------ 
Static Function ViewDef()

Local oView
Local oModel	:= FWLoadModel( 'TMKA341' )
Local oStruACH	:= FWFormStruct( 2, 'ACH' )
Local lTK341BUT	:= ExistBlock( "TK341BUT" ) // Ponto de entrada para criacao de botoes
Local aRetPE	:= {}							 // Array contendo os botoes criados no P.E.
Local nX		:= 0
Local oDlg		:= Nil
Local nOpcA		:= 0

If lCRMTerr == Nil
	lCRMTerr := SuperGetMV("MV_CRMTERR",.F.,.F.)
EndIf

oStruACH:RemoveField( "ACH_IDESTN" )
oStruACH:RemoveField( "ACH_NVESTN" )

If cPaisLoc == 'RUS' .AND. oStruACH:HasField('ACH_CGC')
	oStruACH:RemoveField('ACH_CGC')
EndIf
oView := FWFormView():New()
oView :SetModel( oModel )
oView :AddField( 'VIEW_ACH', oStruACH, 'ACHMASTER' )     

//-----------------------------------------
//          Criacao dos botoes
//-----------------------------------------
If IsInCallStack( "FATA320" ) 
	//-------------------------------------------------------------
	// Se o script foi acionado atraves da workarea, verifica se o
	// grupo do representante atual possui permissao para executar
	//                         scripts.                                                    
	//-------------------------------------------------------------
	ACA->( DbSetOrder( 1 ) )//ACA_FILIAL+ACA_GRPREP
	If 	ACA->( DbSeek( xFilial( "ACA" ) + SA3->A3_GRPREP ) ) .AND.;
		ACA->ACA_QUASUS == "1"
		//Qualificacao de Suspect 
		oView:AddUserButton( STR0068,"",{ |oView| TMKA342( M->ACH_CODIGO, M->ACH_LOJA, @oDlg, @nOpcA, M->ACH_VEND ) },,,{ MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) //"Qualificar suspect" 	                                                  
	EndIf
EndIf
//Link com a Receita Federal                                                  
If cPaisLoc == "BRA"
	oView:AddUserButton( STR0064,"",{ |oView| Tk341CNPJ( M->ACH_CGC ) },,,{ MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) //"CNPJ"
	
EndIf
//Scripts de Atendimento                        
oView:AddUserButton( STR0066, "",{|oView| SaveInter(), TkLstScr( MODEL_OPERATION_UPDATE,"ACH", M->ACH_CODIGO, M->ACH_LOJA ) ,RestInter() },,,{ MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE} )	

//Scripts de Segmentos
oView:AddUserButton( STR0133,"",{ |oView| SaveInter(), CRMA620(@aAOVMark,"ACH", FwFldGet("ACH_CODIGO"), FwFldGet("ACH_LOJA"), FwFldGet("ACH_CODSEG"), oModel:GetOperation()),RestInter() },,,{ MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) 

//Territorios
If lCRMTerr
	oView:AddUserButton(STR0134,"",{|| IIF( Empty( FwFldGet("ACH_CODTER") ),CRMA690EvalTerritory("TMKA341","ACH",.T.,.T.),;
									   MsgInfo(STR0138) ) },STR0134,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Esta entidade já possui um território!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
EndIf

//Desqualificação da Conta
oView:AddUserButton( STR0110 , "", { |oView| Tk341Desq(oModel,.F.) },,,{ MODEL_OPERATION_UPDATE } ) //"Desqualificação"
//Reativação da Conta
oView:AddUserButton( STR0111 , "", { |oView| TK341SaveDesq('R', , , oModel, .F.)},,,{ MODEL_OPERATION_UPDATE } ) //"Reativação"

//-----------------------------------------
// Ponto de entrada para criacao de botoes
//-----------------------------------------
If lTK341BUT 
	aRetPE	:= U_Tk341But( oModel )
	If ValType( aRetPE ) == "A"
		For nX := 1 To Len( aRetPE )
			oView:AddUserButton( aRetPE[nX][4], aRetPE[nX][1], aRetPE[nX][2] )
		Next nX
	EndIf
EndIf

oView := CRMXAddAct("ACH",oView) //Adcionar Rotinas no 'Ações relacionadas' do Formulário   
             
oView :CreateHorizontalBox( 'TELA', 100 )
oView :SetOwnerView( 'VIEW_ACH', 'TELA' )



Return( oView )        

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Pre 

Validacao realizada na ativação do Modelo, permitindo ou não sua ativação    

@sample 	Tk341Pre( oModel )

@param		oModel -  Modelo de dados do sistema

@return   	lRet   -  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		03/02/12
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341Pre( oMdl )

Local nOpc			:= oMdl:GetOperation()
Local lRet			:= .T.				

If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE
	If ACH->ACH_STATUS == "6" // Prospect
		Help( " ", 1, "TMKALTS" ) //Esse Suspect já foi convertido em um novo Prospect. Não é possível alterar as informações do cadastro antigo.
		lRet := .F.
	Endif
EndIf

If lRet .AND. !(IsInCallStack("TK341SaveDesq"))		
	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE
		If  ACH->ACH_STATUS == "5" // DESQUALIFICADO
			Help( ,, STR0071,, STR0129 , 1, 0 )//"Atenção", "O registro selecionado foi desqualificado. Reative o registro através da opção: Outras Ações / Reativar."
			lRet := .F.
		Endif
	EndIf
EndIf

Return( lRet )
                    
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Pos  

Faz a Pos Validação validacao (TudoOk).

@sample 	Tk341Pos ( oMdl )

@param		oMdl -  Modelo de dados do sistema

@return   	lRet   -  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		09/05/13  
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341Pos( oMdl ) 

Local aArea		 	:= GetArea()
Local lRet 		 	:= .T.
Local lTMKINCACH 	:= ExistBlock( "TMKINCACH" ) 	 // P.E  Depois da inclusao do contato.
Local lTKDELACH	 	:= ExistBlock( "TKDELACH" )		 // Ponto de entrada antes da exclusão do suspect
Local lTKALTACH  	:= ExistBlock( "TKALTACH" ) 	 // Ponto de entrada antes da alteração do suspect
Local nOperation 	:= oMdl:GetOperation()
Local aParams		:= {{||},{||.T.}, {||}, {||} }	// Códigos de bloco que serão executados, sendo [1] antes da abertura da tela e [2] antes da gravação. Obs. O retorno do [2] irá permitir .T. ou não .F. a gravação da exclusão do suspect.
Local nBusca	:= 0 						// Contador
Local nRecnoSM0 := SM0->(RecNo())			// Posição do registro na área SM0
Local aSM0CodFil:= {}						// Lista de filiais
Local lPodeApagar   := .F.
Local xTerritory	:= Nil

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	If ( oMdl:GetValue( "ACHMASTER", "ACH_STATUS" ) == "5" ) .And. Empty(oMdl:GetValue("ACHMASTER","ACH_CODESQ"))
		Help( ,,'HELP',,STR0136, 1, 0 ) //"O campo Ent. Origem tem que ser preenchido"
		lRet := .F.
	EndIf
	
	If lRet .AND. oMdl:GetValue("ACHMASTER", "ACH_STATUS") == "6"
		Help( ,, "TK341POS", , STR0141, 1, 0,,,,,,{STR0142}) //"Não é permitida a classificação de um Suspect como 'Prospect' neste momento." ## "Para classificá-lo como Prospect utilize a opção de 'qualificação' da rotina."
 		lRet := .F.
	EndIf
EndIf

If lRet .AND. ( oMdl:GetValue( "ACHMASTER", "ACH_ORIGEM" ) $ "1|5|7" ) .And. Empty( oMdl:GetValue( "ACHMASTER","ACH_ENTORI" ) ) 
	Help( ,, STR0071,, STR0073, 1, 0 ) //"Atenção"##"O campo Ent. Origem tem que ser preenchido"
 	lRet := .F. 
EndIf           
        
If lRet .AND. nOperation == MODEL_OPERATION_INSERT
	If ( Type("lTk341Auto") == "U" )
		lTk341Auto := .F.
	EndIf
	If !( lTk341Auto )
		//-------------------------------------
		// Se houve confirmacao executa o P.E.
		//-------------------------------------
		If lTMKINCACH
			U_TMKINCACH( oMdl )
		Endif
	EndIf
EndIf	

If lRet .AND. nOperation == MODEL_OPERATION_DELETE
	//-----------------------------------------------
	// Ponto de entrada antes da exclusão do suspect
	//-----------------------------------------------
	//Passa para o AxDeleta a execução do ponto de entrada, antes da gravacao.
	If lTKDELACH
		aParams[2] := { ||ExecBlock( "TKDELACH", .F., .F., { oMdl } ) }
	EndIf
	If lTKALTACH
		lRet := ExecBlock( "TKALTACH", .F., .F., { oMdl } )
	EndIf

	If lRet
		//----------------------------------
		// Preenche um array com as filiais.
		//----------------------------------
		DbSelectArea("SM0")
		DbGoTop()
		While ! Eof()
			If SM0->M0_CODIGO == cEmpAnt
				Aadd( aSM0CodFil, FWGETCODFILIAL )
			Endif
			DbSkip()
		End
		DBGoTo( nRecnoSM0 )
	
		//---------------------------------------------------------------------
		// Verifica se existe algum movimento desta entidade no telemarketing 
		//---------------------------------------------------------------------
		DBSelectArea("SUC")//Cabecalho do Telemarketing
		DBSetOrder( 2 ) //UC_FILIAL+UC_ENTIDAD+UC_CHAVE
		aFiliais := If( FWModeAccess( "SUC", 3 ) == "E" .And. FWModeAccess( "ACH", 3 ) == "C", aClone( aSM0CodFil ), { xFilial() } )
		For nBusca := 1 to Len(aFiliais)
			If DBSeek( aFiliais[nBusca] + 'ACH'+ oMdl:GetValue( "ACHMASTER", "ACH_CODIGO" ) + oMdl:GetValue( "ACHMASTER", "ACH_LOJA" ) )
				Help( ,, STR0071,, STR0086, 1, 0 ) //"Atenção" ### "O Suspect não poderá ser excluído, pois, está diretamente relacionada com as tabelas de atendimento."
				lRet := .F.
				Exit
			EndIf
		Next( nBusca )
	EndIf
	
	// Verifica se existe Atendimento no Teleatendimento ADE
	If lRet .And. FindFunction("Tk510TAxEn")
		lPodeApagar := Tk510TAxEn("ACH", ACH->ACH_FILIAL, ACH->ACH_CODIGO + ACH->ACH_LOJA)
		If !lPodeApagar
			lRet := .F.
		Endif
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o usuario trocou o segmento primario de uma amarracao com os subsegmentos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := CRMA620TOkSeg(oMdl:GetValue( "ACHMASTER", "ACH_CODSEG" ),aAOVMark)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a avaliação do(s) melhor(es) territorio(s) para atender esta conta . ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCRMTerr == Nil
	lCRMTerr := SuperGetMV("MV_CRMTERR",.F.,.F.)
EndIf
If ( lCRMterr .And. lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
	If Empty( oMdl:GetValue( "ACHMASTER", "ACH_CODTER" ) )
		xTerritory	:= CRMA690EvalTerritory("TMKA341","ACH",.T.,.F.)
		//--------------------------------------------------------------------
		//Considerar o retorno .T. ou .F. caso a função CRMA690EvalTerritory
		//encontrar algum territorio para esta conta.
		//-------------------------------------------------------------------
		If ValType(xTerritory) == "A"
			If !Empty( xTerritory[2] )
				lRet := xTerritory[1] 
			EndIf
		Else
			lRet := xTerritory
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Cmm

Faz a gravação dos dados (Commit).     

@sample 	Tk341Cmm( oModel )

@param		oModel -  Modelo de dados do sistema

@return   	lRet   -  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		18/02/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341Cmm( oModel )
 
Local aAreaAO4   := AO4->(GetArea())
Local nOperation := oModel:GetOperation()
Local cVendAnt   := ""
Local cNomeAnt   := ""
Local cCGCAnt    := ""
Local cCodigo	 := ""	
Local cLoja		 := ""
Local lRet       := .T.
Local cCodSeg	 := oModel:GetValue('ACHMASTER', 'ACH_CODSEG' )
Local lAOWDeleted	:= .F.

If nOperation == MODEL_OPERATION_UPDATE
	cVendAnt	:= ACH->ACH_VEND
	cNomeAnt	:= ACH->ACH_RAZAO
	cCGCAnt	:= ACH->ACH_CGC
	cCodigo	:= ACH->ACH_CODIGO
	cLoja		:= ACH->ACH_LOJA
EndIf

FWFormCommit( oModel, Nil, { |oModel,cId, cAlias| Tk341After( oModel, cId, cAlias, cVendAnt, cNomeAnt, cCGCAnt, cCodigo, cLoja  ) } )

// Prepara para apagar as amarracoes caso seja exclusao de suspect ou o segmento principal esteja vazio
If ( nOperation == MODEL_OPERATION_DELETE .Or. Empty(oModel:GetValue("ACHMASTER", "ACH_CODSEG")) )
	lAOWDeleted := .T.
EndIf
	
// Efetiva as amarracoes de subsegmentos
If !Empty(cCodSeg)
	CRMA620GrvAOW(aAOVMark, "ACH", oModel:GetValue("ACHMASTER", "ACH_CODIGO"), oModel:GetValue("ACHMASTER", "ACH_LOJA"), oModel:GetValue("ACHMASTER", "ACH_CODSEG") ,lAOWDeleted )
EndIf

If nOperation <> MODEL_OPERATION_INSERT
	RestArea( aAreaAO4 )
Endif

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341After

Faz a gravação dos dados posteriores depois do Commit.     

@sample 	Tk341After( oModel, cId, cAlias, cVendAnt, cNomeAnt, cCGCAnt, cCodigo, cLoja )  

@param		oModel 		-  Modelo de dados do sistema 
			cId 	- Id do Modelo
			cAlias - Alias
			cVendAnt	-  Vendedor atual  
			cNomeAnt	-  Nome do Suspect
			cCGCAnt		-  CGC da entidade
			cCodigo     -  Código do Suspect
			cLoja		-  Loja do Suspect	

@return   	lRet   		-  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		06/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function Tk341After( oModel, cId, cAlias, cVendAnt, cNomeAnt, cCGCAnt, cCodigo, cLoja )

Local aArea		 := GetArea()
Local aAreaAO3	 := AO3->(GetArea())			// Armazena posicionamento atual do AO3
Local aAreaAO4	 := AO4->(GetArea())			// Armazena posicionamento atual do AO4
Local nOperation := oModel:GetOperation()
Local lRet		 := .T.
Local lAtuADL	 := .F.
Local lProcADL	 := GetMv( "MV_CRMADL",,.T. )   // Indica se a ADL deverá ter manutenção
Local lTK341GRV	 := ExistBlock( "TK341GRV" ) // Ponto de entrada ao final da gravacao
Local cChave	 := ""
Local cChaveUSR  := ""
Local aAutoAO4	 := {}
Local cUserAnt	 := ""
Local aAutoAO4Aux:= {}
Local aTerritory := Nil
Local cRoleAnt	 := ""
Local lCRMAZS	 := SuperGetMv("MV_CRMUAZS",, .F.)	
Local cLoggedUser:= If(lCRMAZS, CRMXCodUser(), RetCodUsr()) 
Local aAutoAO4Aux:= {}
Local aTerritory := {}
Local aRole		 := CRMXGetPaper()
Local lPropri    := .T.

If lProcADL
	SX2->(DbSetOrder(1))
	lAtuADL := SX2->(DbSeek("ADL"))
EndIf

If nOperation == MODEL_OPERATION_INSERT
	If lAtuADL .AND. !Empty( ACH->ACH_VEND )
		Ft520Inc( ACH->ACH_VEND, "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA )
	EndIf
EndIf

If nOperation == MODEL_OPERATION_UPDATE
	If lAtuADL
		If Empty( cVendAnt ) .AND. !Empty( ACH->ACH_VEND )
			Ft520Inc( ACH->ACH_VEND, "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA )
		ElseIf !Empty( cVendAnt ) .AND. ACH->ACH_VEND <> cVendAnt
			Ft520Alt( cVendAnt, ACH->ACH_VEND, "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA )
		EndIf
  		//-------------------------------------
		// Atualiza a tabela de referencia ADL
		//-------------------------------------
		#IFDEF TOP
			If ( ( cCGCAnt <> ACH->ACH_CGC ) .OR. ( cNomeAnt <> ACH->ACH_RAZAO ) )
				Ft520AtuEn( "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA, ACH->ACH_RAZAO, ACH->ACH_CGC )
			EndIf
		#ENDIF		
	EndIf
EndIf

If nOperation == MODEL_OPERATION_DELETE
	
	If lRet
		//-------------------------------------
		// Exclui a amarracao com os contatos
		//-------------------------------------
		FtContato("ACH",ACH->(RecNo()),2,,3)
		
		//------------------------------------------
		// Exclui a amarracao com os conhecimentos
		//------------------------------------------
		MsDocument("ACH",ACH->(RecNo()),2,,3)
		
		//----------------------------------
		// Desfaz a amarração com o ADL
		//----------------------------------
		If lAtuADL .And. !Empty( ACH->ACH_VEND )
			Ft520Del( ACH->ACH_VEND, "ACH", ACH->ACH_CODIGO, ACH->ACH_LOJA )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclusao de Anotações    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModulo == 73 .And. FindFunction("CRMA090")
			CRMA090Del("ACH",ACH->(Recno()))
		EndIf
		
	EndIf
	
EndIf 

If cId == "ACHMASTER"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona ou Remove o privilegios deste registro.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := PadR(xFilial("ACH")+oModel:GetValue("ACH_CODIGO")+oModel:GetValue("ACH_LOJA"),TAMSX3("AO4_CHVREG")[1])
	
	If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE )
		aAutoAO4	:= CRMA200PAut(nOperation,"ACH",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/,,,lPropri)

		If nOperation == MODEL_OPERATION_INSERT
			If lCRMAZS
				If ! Empty( aRole )
					AZS->( DBSetOrder( 1 ) ) 
		       
					If AZS->( DbSeek(xFilial("AZS") + aRole[1] + aRole[2] + aRole[3] ) )
						 If ( ! ( Empty( oModel:GetValue("ACH_VEND")  ) ) ) .And. ( AZS->AZS_VEND <> oModel:GetValue("ACH_VEND")  )
						 	AZS->( DBSetOrder( 4 ) ) 
		       
							If AZS->( DbSeek(xFilial("AZS") + oModel:GetValue("ACH_VEND")  ) )					  	
								If ! ( AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL == aRole[1] + aRole[2] + aRole[3] )
									aAutoAO4Aux := CRMA200PAut(nOperation,"AD1",cChave,AZS->AZS_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,aRole[1],/*dDataVld*/,,,lPropri, AZS->AZS_SEQUEN + AZS->AZS_PAPEL)
									aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])				  
								EndIf	
						  	EndIf		  
						 EndIf
					EndIf 	
				EndIf 		 			
			Else
				DbSelectArea("AO3")
				AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
				If AO3->(DbSeek(xFilial("AO3")+RetCodUsr()))
					// Se o codigo do vendendor logado for diferente do cadastrado, insere na AO4 como compartilhado
					If !Empty(oModel:GetValue("ACH_VEND")) .AND. AO3->AO3_VEND <> oModel:GetValue("ACH_VEND")
						AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
						If AO3->(DbSeek(xFilial("AO3")+oModel:GetValue("ACH_VEND")))
							aAutoAO4Aux := CRMA200PAut(nOperation,"ACH",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,RetCodUsr(),/*dDataVld*/)
							aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		
		If !Empty(oModel:GetValue("ACH_VEND"))
			
			If Empty(cVendAnt)
				cVendAnt := oModel:GetValue("ACH_VEND")	
			EndIf
			
			If lCRMAZS
				If AZS->( DbSeek(xFilial("AZS") + cVendAnt) )
					DbSelectArea("AO4")
					AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
					
					If !AO4->( DbSeek(xFilial("AO4") + "ACH" + cChave + AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL ))
						aAutoAO4 := CRMA200PAut(nOperation,"ACH",cChave,AZS->AZS_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,cLoggedUser,/*dDataVld*/,,,, AZS->AZS_SEQUEN + AZS->AZS_PAPEL)
					Else	
						cUserAnt := AZS->AZS_CODUSR
						cRoleAnt := AZS->AZS_SEQUEN + AZS->AZS_PAPEL
							
						If AZS->AZS_VEND <> oModel:GetValue("ACH_VEND")
							AZS->( DBSetOrder(4) )    // AZS_FILIAL+AZS_VEND
							                        
							If AZS->( DbSeek(xFilial("AZS") + oModel:GetValue("ACH_VEND") ) )							
								DbSelectArea("AO4")
								AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
									
								//Verifica se o vendedor atual possui privilegios para este registro.
								If AO4->(DbSeek( xFilial("AO4") + "ACH" + cChave + AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL ))
									//Se possui deleta o acesso do vendedor anterior
									If AO4->( DbSeek(xFilial("AO4") + "ACH" + cChave + cUserAnt + cRoleAnt))
										RecLock("AO4",.F.)
										AO4->(DbDelete())
										AO4->(MsUnlock())
									EndIf	
								Else
									//Senão troca o privilegios.
									If AO4->( DbSeek(xFilial("AO4") + "ACH" + cChave + cUserAnt + cRoleAnt ) )
										RecLock("AO4",.F.)
										AO4->AO4_CODUSR := AZS->AZS_CODUSR
										AO4->AO4_IDESTN := AZS->AZS_IDESTN
										AO4->AO4_NVESTN := AZS->AZS_NVESTN
										AO4->AO4_USRPAP := AZS->AZS_SEQUEN + AZS->AZS_PAPEL
										AO4->(MsUnlock())
									EndIf								
								EndIf							
							EndIf							
						EndIf				
					EndIf	
				EndIf			
			Else
				DbSelectArea("AO3")
				AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
				
				If AO3->(DbSeek(xFilial("AO3")+cVendAnt))
					
					DbSelectArea("AO4")
					AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
					
					If !AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave+AO3->AO3_CODUSR))
						aAutoAO4 := CRMA200PAut(nOperation,"ACH",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,RetCodUsr(),/*dDataVld*/)
					Else
							
						cUserAnt := AO3->AO3_CODUSR
							
						If AO3->AO3_VEND <> oModel:GetValue("ACH_VEND")
								
							If AO3->(DbSeek(xFilial("AO3")+oModel:GetValue("ACH_VEND")))
									
								DbSelectArea("AO4")
								AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
									
								//Verifica se o vendedor atual possui privilegios para este registro.
								If AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave+AO3->AO3_CODUSR))
									//Se possui deleta o acesso do vendedor anterior
									If AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave+cUserAnt))
										RecLock("AO4",.F.)
										AO4->(DbDelete())
										AO4->(MsUnlock())
									EndIf	
								Else
									//Senão troca o privilegios.
									If AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave+cUserAnt))
										RecLock("AO4",.F.)
										AO4->AO4_CODUSR := AO3->AO3_CODUSR
										AO4->AO4_IDESTN := AO3->AO3_IDESTN
										AO4->AO4_NVESTN := AO3->AO3_NVESTN
										AO4->(MsUnlock())
									EndIf
									
								EndIf
									
							EndIf
								
						EndIf
					
					EndIf
					
				EndIf
			EndIf
		ElseIf !Empty(cVendAnt)
			cChaveUSR := AO3->AO3_CODUSR
			If lCRMAZS
				DbSelectArea("AZS")
				DBSetOrder(4)		    // AZS_FILIAL+AZS_VEND
			Else
				DbSelectArea("AO3")
				DbSetOrder(2)			// AO3_FILIAL+AO3_VEND
			EndIf
			
			If DbSeek(xFilial()+cVendAnt)
				If lCRMAZS
					cChaveUSR  := AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL
				EndIf
				 
				DbSelectArea("AO4")
				DbSetOrder(1)		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				
				If AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave+cChaveUSR))
					RecLock("AO4",.F.)
					AO4->(DbDelete())
					AO4->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	If Len(aAutoAO4) > 0
		DbSelectArea("AO4")	
		AO4->(DbSetOrder(1)) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
		If !AO4->(DbSeek(xFilial("AO4")+"ACH"+cChave))
			nOperation := MODEL_OPERATION_INSERT 	
		EndIf
		lRet := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a distribuicao da conta + rodizio para o territorio vencedor. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCRMTerr == Nil
		lCRMTerr := SuperGetMV("MV_CRMTERR",.F.,.F.)
	EndIf
	If lCRMTerr .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
		If ( Empty( ACH->ACH_TPMEM ) .Or. Empty( ACH->ACH_CODMEM ) )
			aTerritory := CRMA690CasterTerritory("TMKA341","ACH", ACH->ACH_CODTER, /*cScript*/, /*lSimulation*/)
			If aTerritory[1]
				RecLock("ACH",.F.)
				ACH->ACH_CODTER := aTerritory[2]  // Código do Territorio.
				ACH->ACH_TPMEM  := aTerritory[3]  // Tipo do Membro
				ACH->ACH_CODMEM := aTerritory[4]  // Codigo do Membro
				ACH->ACH_VEND	:= aTerritory[5]  // Vendedor DONO/RESPONSAVEL da conta
				ACH->(MsUnLock())
			EndIf
		EndIf
	EndIf
EndIf

//---------------------------------------------
// Ponto de entrada apos a gravacao do suspect
//---------------------------------------------
If lTK341GRV
	U_TK341GRV(nOperation,ACH->(Recno()),oModel)
EndIf

RestArea(aAreaAO3)
RestArea(aAreaAO4)
RestArea(aArea)

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk260Can

Bloco de cancelamento do formulario.     

@sample 	Tk260Can( oModel )

@author		Vendas CRM
@since		16/06/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341Can()
	aAOVMark := {}
Return(.T.) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341CGC

Validacao do CPF/CNPJ do Suspect (Utilizado no Valid do campo ACH_CGC)           

@sample 	Tk341CGC( cCgc )

@param		cCgc 	-  CNPJ do registro posicionado

@return   	lRet    - Verdadeiro ou Falso

@author		Vendas CRM
@since		12/02/08 
@version	12
/*/
//------------------------------------------------------------------------------
Function Tk341CGC( cCgc )

Local aArea		:= GetArea()
Local lRet		:= .T.   
Local cTipoVld	:= GetMv( "MV_TMKCGC",,"1" ) //1=Valida CNPJ,2=Apenas Raiz do CNPJ
Local cMay		:= ""
Local cSValCnpj	:= SuperGetMv("MV_VALCNPJ",,"1")
Local lExistCgc	:= .F.
Default cCgc	:= M->ACH_CGC

If !Empty( cCgc )
	If cTipoVld == "1" //Valida CNPJ
		cMay := "ACH" + xFilial("ACH") + cCgc
		lExistCgc := !ExistChav( "ACH", cCgc, 2, "ACH_CGC" ) 
		lRet := ( CGC( cCgc ) .AND. !lExistCgc .AND. MayIUseCode( cMay ) .AND. TmkVeEnt( cCgc, "ACH" ))
	ElseIf cTipoVld == "2" //Raiz do CNPJ
		cCgc := SubStr( cCgc, 1, 8 )
		cMay := "ACH" + xFilial("ACH") + cCgc
		lExistCgc := !ExistChav( "ACH", SubStr( cCgc, 1, 8 ), 2, "ACH_CGC" )
		lRet := CGC( cCgc ) .AND. !lExistCgc .And. MayIUseCode( cMay ) .And. TmkVeEnt( SubStr( cCgc, 1, 8 ), "ACH")
	EndIf
	If cSValCnpj == "1" .AND. lExistCgc //Verifica se o cnpj já está cadastrado 
		If (Type("lTk341Auto") == "U" .OR. !lTk341Auto)
			Aviso(STR0071,STR0151,{STR0021},2)//"Atenção"##"O Cnpj Informado já está sendo utilizado"##"OK"	
		EndIf
		lRet := .T.
	Endif
EndIf

If !lRet
	Leave1Code( cMay )
EndIf

RestArea( aArea )

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341Legenda

Legendas do browse de cadastro de Suspect  

@sample 	TK341Legenda()

@return   	.T.   -  Retorna verdadeiro

@author		Vendas CRM
@since		28/10/03
@version	12
/*/
//------------------------------------------------------------------------------
Function Tk341Legenda( oModel )

Local lTk341Leg := ExistBlock( "TK341LEG" )			// Ponto de entrada para alterar a legenda
Local aCores	:= { { "BR_BRANCO"   , STR0052 } ,; // Mailing 
  					 { "BR_MARROM"   , STR0053 } ,; // Classificado
				     { "BR_VERMELHO" , STR0054 } ,; // Desenvolvimento
					 { "BR_AZUL"     , STR0055 } ,; // Gerente
					 { "BR_AMARELO"  , STR0056 } ,; // Standy by
					 { "BR_PRETO"    , STR0057 } ,; // Cancelado
					 { "BR_VERDE"    , STR0058 } ,; // Prospect
					 { "BR_CINZA"	 , STR0083 } }  //"Sem Status"

//------------------------------------------------- 
// Ponto de Entrada para alterar cores da legenda 
//-------------------------------------------------
If lTk341Leg
	aCores := ExecBlock( "TK341LEG", .F., .F., aCores, oModel )
	If ValType( aCores ) <> "A"
		aCores := {}	
	Endif
Endif	

BrwLegenda( cCadastro, STR0051, aCores )   // Legenda

Return( .T. ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Prospect 

Seleciona os Suspects e executa a conversao para Prospect 

@sample 	Tk341Prospect ()

@return   	.T.   -  Retorna verdadeiro

@author		Vendas CRM
@since		12/07/01
@version	12
/*/
//------------------------------------------------------------------------------
Function Tk341Prospect()

Local lRet := .T.
Local cStatus	:= ACH->ACH_STATUS
Local cCodMot	:= ACH->ACH_CODESQ

If cStatus == '5' .And. !Empty(cCodMot)	
	Help( ,, 'HELP',, STR0137, 1, 0 ) //'Não é possível gerar Prospest para Suspect Desqualificado'
	lRet := .F.
EndIf

If lRet
	If Pergunte("TMK341",.T.)
		Processa({|| Tk341GrvPros()}, STR0039,, .T.)  // Gravando o Prospect...
	Else
		lRet := .F.
	Endif
EndIf
Return( lRet )      

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341CNPJ  

Efetua link com o site da Receita Federal para consulta da situacao do 
CNPJ da empresa.  

@sample 	Tk341CNPJ( cCNPJ )

@param		cCNPJ	- CNPJ da entidade

@return   	.T.   -  Retorna verdadeiro

@author		Vendas CRM
@since		30/11/07
@version	12
/*/
//------------------------------------------------------------------------------                                   
Static Function Tk341CNPJ( cCNPJ )

Local cURL := GetNewPar( "MV_TMKURLR", "http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Solicitacao2.asp" )

ShellExecute("open", cURL+"?cnpj="+Alltrim(cCNPJ), "", "", 1)

Return .T.
                  
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341GrvPros 

Gravacao dos Prospects a partir da tabela ACH(Suspects) 

@sample 	³Tk341GrvPros ()

@return   	.T.   -  Retorna verdadeiro

@author		Vendas CRM
@since		12/07/01
@version	12
/*/
//------------------------------------------------------------------------------ 
Static Function Tk341GrvPros(cCdProsp, lAutomato)

Local aObrigaACH:= {}
Local lInc 		:= .T.
Local lRet 		:= .T.
Local cAviso 	:= ""
Local nI		:= 0
Local cSValCnpj	:= SuperGetMv("MV_VALCNPJ",,"1") 

Default cCdProsp	:= ""
Default lAutomato	:= .F.

If !lAutomato
	ProcRegua( RecCount() )
EndIf

//----------------------------------------------------------
// Grava informacoes do ACH990 para o cadastro de Prospect
//----------------------------------------------------------
DbSelectarea("ACH")
DbSetorder( 1 )
DbSeek( xFilial("ACH")+ ALLTRIM( MV_PAR03 ), .T. ) // Codigo inicial
While ( ( !ACH->( Eof() ) ) .AND. ( xFilial("ACH") == ACH->ACH_FILIAL ) .AND. ( ACH->ACH_CODIGO <= MV_PAR04 ) ) //Codigo Final
	If CRMXLibReg( "ACH", ACH->ACH_CODIGO + ACH->ACH_LOJA )
		//--------------------------------------
		// Executa as validacoes para gravacao	
		//--------------------------------------
		If !(TK341Expor()) .And. ( MV_PAR01 == 1 ) //Validacao de Prospect pelo CGC = SIM
			//-------------------------------------------------
			// Se o CGC do SUSPECT estiver VAZIO nao converte  
			//-------------------------------------------------
			If Empty( AllTrim( ACH->ACH_CGC ) )
				DbSelectArea("ACH")
				ACH->( DbSkip() )
				If !lAutomato
					IncProc()
				EndIf
				Help( " ", 1, "TK341CONVCGC" ) //"Não foi possível verificar o Prospect pois o CGC do Suspect está vazio." ## "Preencha o campo CGC"
				lRet := .F.
				Loop
			Endif
			//--------------------------------------------------------------------------------------
			// Se existir um PROSPECT ja cadastradado com o mesmo CGC avanca para o proximo SUSPECT
			//--------------------------------------------------------------------------------------
			DbSelectArea("SUS")
			DbSetOrder( 4 )
			If DbSeek( xFilial("SUS") + ACH->ACH_CGC ) .AND. cSValCnpj <> "1"
				DbSelectArea("ACH")
				ACH->( DbSkip() )
				If !lAutomato
					IncProc()
				EndIf
				Loop
			Endif
		Endif
		If !(TK341Expor()) .And. ( MV_PAR02 == 1 ) //Validacao de Cliente pelo CGC
			If Empty( AllTrim( ACH->ACH_CGC ) )
				DbSelectArea("ACH")
				ACH->( DbSkip() )
				If !lAutomato
					IncProc()
				EndIf
				Help( " ", 1, "TK341CLICGC" )//"Não foi possível verificar o Cliente pois o CGC do Suspect está vazio." ## "Preencha o campo CGC."
				lRet := .F.
				Loop
			Endif
			//-----------------------------------------------------------
			// Se existir um cliente com esse CGC nao grava no PROSPECT  
			//-----------------------------------------------------------
			DbSelectArea("SA1")
			DbSetOrder( 3 )
			If DbSeek( xFilial("SA1") + ACH->ACH_CGC )
				DbSelectArea("ACH")
				ACH->( DbSkip() )
				If !lAutomato
					IncProc()
				EndIf
				Loop
			Endif
		Endif
				
		//Verifica se todos os Campos Obrigatórios do Suspect X Prospect estão Preenchidos
		aAdd(aObrigaACH, {{"ACH_CODIGO",STR0106},;
		                  {"ACH_LOJA",STR0046},;
		                  {"ACH_RAZAO",STR0107},;
		                  {"ACH_TIPO",STR0108},;
		                  {"ACH_END",STR0028},;
		                  {"ACH_EST",STR0031}}) //STR0106 - Código, STR0046 - Loja, STR0107 - Razão Social, STR0108 - Tipo, STR0028 - Endereço, STR0031 - Estado,
	   
		cAviso := STR0109 + CRLF //"Para realizar a conversão preencha o(s) seguinte(s) campo(s): "
		For nI := 1 To Len( aObrigaACH[1] )
			cCampo := "ACH->"+aObrigaACH[1][nI][1]
			If Empty(&cCampo)
				cAviso += aObrigaACH[1][nI][2] + CRLF
				lInc := .F.
			EndIf
		Next nI
		
		//----------------------------------------------------------------------
       // Grava um novo registro no SUS com as informacoes desse Suspect atual
       //----------------------------------------------------------------------
		If lInc
			TK341GrvSTP( ACH->ACH_CODIGO, ACH->ACH_LOJA, NIL, Nil, Nil, cCdProsp )
		Else
			Aviso( STR0071, cAviso, { STR0021 } ) //"Atencao"###"????????'###"Ok""
		EndIf

	EndIf
	
	DbSelectArea("ACH")
	ACH->( DbSkip() )
	If !lAutomato
		IncProc()
	EndIf
		
End

Return( lRet )



//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341GrvSTP 

Funcao para gravar um novo prospect a partir de um suspect, sem apagar o suspect 
e atualizando a classificacao do mesmo. 

***Premissas***                                                  
Todas as validacoes ja foram feitas antes de executar essa funcao no programa 
de origem.           

***Observacoes Importantes***
Essa funcao e executada pelo Cadastro de Suspect (no momento de passar para 
"Prospect" e no atendimento de Telemarketing para fazer o mesmo processo 
(Converter de Suspect para Prospect)                                                    

Function Tk341GrvSTP( cCodigo, cLoja, lProspect, cCodVend, aNewSUS )

@param		cCodigo 	- Codigo do Suspect 
@param		cLoja       - Loja do Suspect
@param		lProspect   - Se é prospect

@return   	.T.   -  Retorna verdadeiro

@author		Vendas CRM
@since		31/10/03 
@version	12
/*/
//------------------------------------------------------------------------------ 
Function Tk341GrvSTP( cCodigo, cLoja, lProspect, cCodVend, aNewSUS, cCdProsp, lRezDisTRod )

Local cCodPro 		:= ""		 // Futuro codigo do novo prospect que sera INCLUIDO no SUS
Local lRet 	  		:= .T.							 // Retorno da gravacao
Local nCont     	:= 0 							 // Contador de campos
Local nSaveSx8 		:= GetSX8Len()					 // Funcao de numeracao
Local aContato		:= {}							 // Dados dos contatos copiados
Local cChave 		:= ""		
Local aAutoAO4		:= {}
Local aAutoAO4Aux	:= {}

Local aAmarra		:= {}
//--------------------------------------------------------
// Pontos de entrada da gravacao de Suspect para Prospect
//--------------------------------------------------------
Local lTMKSUSP  	:= ExistBlock( "TMKSUSP" )	  	 // P.E. ANTES da gravacap de Suspect para Prospect
Local lTMKGRSP		:= ExistBlock( "TMKGRSP" )	  	 // P.E. DEPOIS da gravacao de Suspect para Prospect
Local lProcADL      := GetMv( "MV_CRMADL",,.T. )     // Indica se a ADL deverá ter manutenção
Local lAtuADL		:= .F.

Local aRegs			:= {}							 // Retorno esperado do P.E. TK341GPROS 
Local lTK341GPROS	:= ExistBlock( "TK341GPROS" ) 	 // P.E. DEPOIS da gravacao de Suspect para Prospect 
Local lCRMAZS		:= SuperGetMv("MV_CRMUAZS",, .F.)
Local cCodUsr		:= If(lCRMAZS, CRMXCodUser(), RetCodUsr()) 
Local lPropri		:= .T.
Local aRole			:= CRMXGetPaper() 

Default cCodVend 	:= "" 	//Na qualificacao do suspect o atendente informará qual vendedor recebera a conta. 
Default aNewSUS		:= {}
Default cCdProsp	:= ""
Default lRezDisTRod := .F.	

If lProcADL 
	SX2->( DbSetOrder( 1 ) )
	lAtuADL := SX2->( DbSeek( "ADL" ) )
EndIf

//--------------------------------------
// Ponto de Entrada antes da conversao 
//--------------------------------------
If lTMKSUSP              		
   lRet :=	U_TMKSUSP( cCodigo + cLoja )
   If ValType( lRet ) <> "L"
      lRet := .F.
   Endif   
Endif
//Somente para campos do usuario no cadastro de Prospect
If !lRet 
   Return( lRet )
Endif

//-----------------------------------------------------------------------
// Ponto de Entrada para pegar o conteudo dos campos especificos do SUS 
//-----------------------------------------------------------------------
If lTK341GPROS
	aRegs := ExecBlock( "TK341GPROS", .F., .F. )  
    If ValType( aRegs ) <> "A"
      aRegs := {}
   Endif   
Endif

//-------------------------------------------------------
// Grava informacoes do ACH para o cadastro de Prospect	            
//-------------------------------------------------------
DbSelectarea("ACH")
DbSetorder( 1 )
If DbSeek( xFilial("ACH") + cCodigo + cLoja )	               
	//------------------------------------------------------------------------------
	// Valida se realmente nao tem um PROSPECT com o mesmo codigo no cadastro atual
	//------------------------------------------------------------------------------
	Begin Transaction

	If Empty(cCdProsp)
		cCodPro := TkNumero( "SUS", "US_COD" )
	Else  
		cCodPro := cCdProsp 
	EndIf 
	
	//----------------------------
	// Inicia a Gravacao no SUS  
	//----------------------------                
	DbSelectarea("SUS")
	Reclock( "SUS", .T. )
	Replace US_FILIAL	With xFilial("SUS")
	Replace US_COD	    With cCodPro
	Replace US_LOJA	    With ACH->ACH_LOJA
	Replace US_TIPO	    With Tk341Tipo(ACH->ACH_TIPO)
	Replace US_NOME	    With ACH->ACH_RAZAO
	Replace US_NREDUZ   With IIf(Empty(ACH->ACH_NFANT),ACH->ACH_RAZAO,ACH->ACH_NFANT)
	Replace US_END      With ACH->ACH_END
	Replace US_BAIRRO   With ACH->ACH_BAIRRO		
	Replace US_CEP      With ACH->ACH_CEP
	Replace US_EST 	    With ACH->ACH_EST
	If cPaisLoc == "BRA"
		Replace US_COD_MUN 	With ACH->ACH_CODMUN	
	EndIf
	Replace US_MUN      With ACH->ACH_CIDADE
	If cPaisLoc == "BRA"
		Replace US_REGIAO 	With ACH->ACH_REGIAO	
		Replace US_DSCREG 	With ACH->ACH_DSCREG
	EndIf
	Replace US_DDD	    With ACH->ACH_DDD
	Replace US_DDI	    With ACH->ACH_DDI
	Replace US_TEL	    With SgLimpaTel(ACH->ACH_TEL)
	Replace US_FAX      With ACH->ACH_FAX
	Replace US_EMAIL    With ACH->ACH_EMAIL
	Replace US_URL	    With ACH->ACH_URL 
	If cPaisLoc == "BRA"             
		Replace US_PESSOA With ACH->ACH_PESSOA
	EndIf
	Replace US_CGC      With Tk341AjCGC( ACH->ACH_CGC )
	Replace US_STATUS   With "1"			// "Classificado" - Status inicial quando o suspect passa para Prospect
	Replace US_DTCAD    With Date()		// Data de cadastro com a data atual
	Replace US_HRCAD    With Time()		// Hora do cadastro com a hora atual
	If IsinCallStack("CRMA260")
		Replace US_TPCAMP		With FWFldGet("AOD_TPCAMP")
		Replace US_CHVCAM		With FWFldGet("AOD_CHVCAM")
	Else
		Replace US_TPCAMP		With ACH->ACH_TPCAMP
		Replace US_CHVCAM		With ACH->ACH_CHVCAM
	EndIf
	
	Replace US_CODSEG		 	With ACH->ACH_CODSEG
	
	//-------------------------------------------------------------------
	// Gravacao dos campos CNAE, Faturamento, Funcionarios, PaÍs e midia
	//-------------------------------------------------------------------
	Replace US_CNAE		With ACH->ACH_CNAE
	Replace US_FATANU	With ACH->ACH_FATANU
	Replace US_QTFUNC	With ACH->ACH_QTFUNC
	Replace US_PAIS		With ACH->ACH_PAIS
	Replace US_MIDIA	With ACH->ACH_MIDIA
	If	!lRezDisTRod
	
		Replace US_VEND	    With IIF(Empty(cCodVend),ACH->ACH_VEND,cCodVend)
		//--------------------------------------------------------------------------------------------------
		// Grava campos de territorio na qualificacao, caso rotina de distribuicao/rodizio esteja habilitado 
		//--------------------------------------------------------------------------------------------------
		If lCRMTerr == Nil
			lCRMTerr := SuperGetMV("MV_CRMTERR",.F.,.F.)
		EndIf
		If	lCRMTerr
			Replace US_CODTER	With ACH->ACH_CODTER
			Replace US_TPMEMB	With ACH->ACH_TPMEM
			Replace US_CODMEMB	With ACH->ACH_CODMEM
		Endif
	Endif 		
		  
		  
	//-------------------------------------------------------------------
	// Gravacao dos campos para replicar o nivel da estrutura de negocio
	//-------------------------------------------------------------------
	Replace US_IDESTN	 With ACH->ACH_IDESTN	
	Replace US_NVESTN	 With ACH->ACH_NVESTN	 
	
	//------------------------------------------------------
	// Gravacao dos campos para mapear a origem do prospect
	//------------------------------------------------------
	Replace US_ORIGEM   With ACH->ACH_ORIGEM		
	Replace US_ENTORI   With ACH->ACH_ENTORI	
	
	/*
	  ------------------------------------------------------------------
	  Grava os campos de usuario atraves do retorno do P.E.  			
	  Porque os campos podem nao tem o mesmo nome no SUS iguais ao ACH 
	                                                                   
	  Estrutura do Array de Retorno                                    
	  aRegs[1][1]  =  Codigo do Suspect   Ex: ACH->ACH_CODIGO          
	  aRegs[1][2]  =  Campo               Ex: "US_xxxxxx"				
	  aRegs[1][3]  =  Conteudo 		   Ex: "Microsiga Software SA"                                                                     
	  ------------------------------------------------------------------
	*/  
	If Len( aRegs ) > 0
		For nCont := 1 To Len( aRegs )
			If aRegs[nCont][1] == ACH->ACH_CODIGO   // Se este item pertencer ao registro posicionado grava.
				Replace &(aRegs[nCont][2]) With aRegs[nCont][3]
			Endif
		Next nCont
	Endif

	MsUnlock()
	FkCommit()
	While ( GetSx8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo

	// inserindo registro na tabela de privilegios automaticamente
	If !IsInCallStack( "CRMA040" )
		cChave := PadR( xFilial("SUS")+SUS->US_COD+SUS->US_LOJA,TAMSX3("AO4_CHVREG")[1])  		
			
		//Adiciona o privilegios para usuario logado ou seja quem incluiu o suspect.
		aAutoAO4 := CRMA200PAut(3,"SUS",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/,,,lPropri)    

		//Adiciona vendedor responsavel pela conta.
		If !Empty(SUS->US_VEND)
			If lCRMAZS
				AZS->( DBSetOrder(4) )    // AZS_FILIAL+AZS_VEND
				                        
				If AZS->( DbSeek(xFilial("AZS") + SUS->US_VEND ) ) .And. ! Empty(aRole) 
					If ! ( AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL == aRole[1] + aRole[2] + aRole[3] )
						aAutoAO4Aux := CRMA200PAut(3,"SUS",cChave,AZS->AZS_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,aRole[1],/*dDataVld*/,,,lPropri, AZS->AZS_SEQUEN + AZS->AZS_PAPEL )
						aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
					EndIf			
				EndIf 
			Else
				DbSelectArea("AO3")
				AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
				//Verifica se o usuario logado é o mesmo que está qualificando!
				//Caso seja diferente a conta será atribuida para vendedor informado no cadastro.
				If AO3->(DbSeek(xFilial("AO3")+SUS->US_VEND)) .And. AO3->AO3_CODUSR <> cCodUsr
					aAutoAO4Aux := CRMA200PAut(3,"SUS",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,cCodUsr,/*dDataVld*/)
					aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
				EndIf
			EndIf
		EndIf

		If !Empty(aAutoAO4)
			CRMA200Auto(aAutoAO4[1],aAutoAO4[2],3)
		EndIf
		 
	EndIf
		 
	//---------------------
	// Atualiza o Prospect 
	//--------------------- 
	If lProspect <> NIL
		lProspect := .T.
	Endif
	
	lRet := .T.
	
	//------------------------
	// Alteracao da entidade 
	//------------------------
	DbSelectArea("AC8")
	DbSetOrder( 2 ) //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	If DbSeek( xFilial("AC8") + "ACH" + xFilial("ACH") + ALLTRIM( cCodigo + cLoja ) )
		While ( !Eof() ) 								.AND. ;
			( AC8->AC8_FILIAL == xFilial("AC8") ) 	.AND. ;
			( AC8->AC8_ENTIDA == "ACH" ) 				.AND. ;
			( AC8->AC8_FILENT == xFilial("ACH") ) 	.AND. ;
			( ALLTRIM( AC8->AC8_CODENT ) == ALLTRIM( cCodigo + cLoja ) )

			//----------------------------------------------------------
			// Armazena os contatos ja existentes no suspect para copia
			//----------------------------------------------------------
			AAdd( aContato,{	xFilial("AC8")	,;
							"SUS"					,;
							xFilial("SUS")		,;
							cCodPro + ACH->ACH_LOJA	,;
							AC8->AC8_CODCON			} )
			AC8->( DbSkip() )
		End
		
		//-----------------------------------
		// Copia os contatos para o prospect
		//-----------------------------------
		For nCont := 1 To Len( aContato )
			Reclock("AC8",.T.)
			Replace AC8_FILIAL  With aContato[nCont][1]
			Replace AC8_ENTIDA  With aContato[nCont][2]
			Replace AC8_FILENT  With aContato[nCont][3]
			Replace AC8_CODENT	With aContato[nCont][4]
			Replace AC8_CODCON	With aContato[nCont][5]
			MsUnlock()
			FkCommit()
		Next nCont

	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui os relacionamentos de segmento para a nova entidade - CLIENTES ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AOW")
	dbSetOrder(1) //AOW_FILIAL+AOW_ENTIDA+AOW_FILENT+AOW_CODCNT+AOW_LOJCNT+AOW_CODSEG

	IF	dbSeek(xFilial("AOW")+"ACH"+xFilial("ACH")+ACH->ACH_CODIGO+ACH->ACH_LOJA+ACH->ACH_CODSEG)
		While ((!AOW->( Eof())) .And. (xFilial("AOW") == AOW->AOW_FILIAL) .And.;
		       (AOW->AOW_ENTIDA == 'ACH') .And. (xFilial("ACH")==AOW->AOW_FILENT) .And.;
		       (AOW->AOW_CODCNT == ACH->ACH_CODIGO) .And. (AOW->AOW_LOJCNT== ACH->ACH_LOJA) .And.;
		       (AOW->AOW_CODSEG == ACH->ACH_CODSEG))
 
 			AAdd( aAmarra,{xFilial("AOW"),;
							 xFilial("ACH"),;
							 cCodPro,;
							 "SUS",;
							 cLoja,;
							 AOW->AOW_CODSEG,;
							 AOW->AOW_SUBSEG} )
  
			AOW->( DbSkip() )            
		EndDo
		
		For nCont := 1 To Len( aAmarra )
			Reclock("AOW",.T.)
			AOW_FILIAL := aAmarra[nCont][1]
			AOW_FILENT := aAmarra[nCont][2]			
			AOW_CODCNT := aAmarra[nCont][3]			
			AOW_ENTIDA := aAmarra[nCont][4]
			AOW_LOJCNT := aAmarra[nCont][5]
			AOW_CODSEG := aAmarra[nCont][6]
			AOW_SUBSEG := aAmarra[nCont][7]
			MsUnlock()
			DbCommit()   
		Next
	Endif	
	
	DbSelectArea("ACH")
	Reclock( "ACH", .F., .T. )
	Replace ACH->ACH_CODPRO With cCodPro
	Replace ACH->ACH_LOJPRO With ACH->ACH_LOJA
	Replace ACH->ACH_STATUS With "6"
	Replace ACH->ACH_DTCONV With Date()
	Replace ACH->ACH_HRCONV With Time()
	MsUnlock()
	FkCommit()
	
	//---------------------------------------------------------
	//Atualiza o relacionamento com o ADL (conta do vendedor)
	//---------------------------------------------------------
	If lAtuADL
		Ft520UpdEn( "ACH", "SUS", ACH->ACH_CODIGO, SUS->US_COD	,;
			ACH->ACH_LOJA, SUS->US_LOJA	)
	EndIf
	
	 End Transaction
	
	//---------------------------------------
	// Ponto de Entrada depois da conversao
	//---------------------------------------
	If lTMKGRSP
		U_TMKGRSP( cCodPro, ACH->ACH_LOJA )
	Endif
	If lRet 
		aNewSUS := {  SUS->US_COD, SUS->US_LOJA } 
	EndIf
Endif 

Return( lRet )   

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Tipo 

Conversao do tipo de consumidor 	

@sample 	Tk341Tipo( cTipo )

@param		cTipo 	- Tipo do Consumidor

@return   	cTipo   -  Retorna o Tipo do Consumidor

@author		Vendas CRM
@since		22/05/02 
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341Tipo( cTipo )

If cTipo == "1"
	cTipo := "F"
ElseIf cTipo == "2"
	cTipo := "L"
ElseIf cTipo == "3"
	cTipo := "R"
ElseIf cTipo == "4"
	cTipo := "S"
ElseIf cTipo == "5"
	cTipo := "X"
ElseIf cTipo == "6"	// Esse tipo e usado para localizacoes
	cTipo := "M"
Endif

Return( cTipo )
               

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341AjuCGC

Funcao para gravar no cadatro de prospect o CGC sem picture 

@sample 	Tk341AjuCGC( cCGC )

@param		cCGC	- numero do CNPJ/CPF	

@return   	cCGC    -  Retorna numero do CNPJ/CPF sem picture

@author		Vendas CRM
@since		10/09/07
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Tk341AjCGC( cCGC )

Default	cCGC := ""		// Variavel com o CGC

If !Empty( cCGC )
	cCGC := StrTran( cCGC,".","" )
	cCGC := StrTran( cCGC,"-","" )
	cCGC := StrTran( cCGC,"/","" )   
	          
	cCGC := PadR( cCGC, TamSX3( "A1_CGC" )[1] )
Endif

Return( cCGC )       

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldPict

Ajusta a Picture de CGC quando pesssoa Fisica ou Juridica
**Utilizado no campo ACH_CGC

@sample 	VldPict()

@return   	Retorna a picture a ser utilizada 

@author		Thamara Villa Jacomo
@since		21/02/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function VldPict()                                                   

Return( PicPes( M->ACH_PESSOA ) )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341RESV  

Funcao para controlar a quantidade maxima de contas  de cliente do vendedor. 

@sample 	TK341RESV( cCodRepres, cReserva )

@param      cCodRepres  - Codigo do Vendedor corrente 
@paramc 	Reserva     - Reserva Sim/Nao  

@return   	lRet   		-  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		18/01/08
@version	12
/*/
//------------------------------------------------------------------------------
Function TK341RESV( cCodRepres, cReserva )

Local AreaAnt		:=	GetArea()
Local aRet      	:= {}       // retono da função Ft520Total()
Local nMaxCota 		:= 0        // nr. maximo de conta do cleinte
Local nSomaConta	:= 0
Local nContador 	:= 0
Local lRet			:= .T.

RestArea( AreaAnt )
Return( lRet )
  
If Empty( cCodRepres ) .And. cReserva <> "2"
	Aviso( STR0071, STR0070, { STR0021 } ) //"Atencao"###"Preencher o codigo do vendedor antes de definir a reserva'###"Ok""
	M->ACH_RESERV  := Space( TamSX3( "ACH_RESERV" )[1] )
	RestArea( AreaAnt )
	lRet :=	.F.
	Return( lRet )
Endif

nMaxCota:= SuperGetMv( "MV_FATCON",,0 )

Posicione( "SA3", 1, xFilial("SA3") + cCodRepres, "A3_COD" )

If cReserva = "1"
	
	If SA3->A3_QTCONTA > 0 // caso esteja informado no SA3
		aRet := Ft520Total( cCodRepres )
		
		For nContador:=1 To Len( aRet )
			nSomaConta+=aRet[nContador]
		Next nContador
		
		If Inclui
			nSomaConta++ // Atribui mais um referente ao atual
		Endif
		
		If nSomaConta > SA3->A3_QTCONTA
			Aviso( STR0071, STR0069 , { STR0021 } ) //"Atencao"###"Numero maximo de contas de clinte para esse vendedor foi atingida"###"Ok"
			M->ACH_VEND    := Space( TamSX3( "ACH_VEND" )[1] )
			M->ACH_RESERV  := Space( TamSX3( "ACH_RESERV" )[1] )
		Endif
	Else  // se não Pegar do Parametro	
		aRet := Ft520Total( cCodRepres )
		
		For nContador:=1 To Len( aRet )
			nSomaConta+=aRet[nContador]
		Next nContador
		
		If Inclui
			nSomaConta++ // Atribui mais um referente ao atual
		Endif
		
		If nSomaConta > nMaxCota
			Aviso( STR0071, STR0069 , { STR0021 } ) //"Atencao"###"Numero maximo de contas de cliente para esse vendedor foi atingida"###"Ok"
			M->ACH_VEND    := Space( TamSX3( "ACH_VEND" )[1] )
			M->ACH_RESERV  := Space( TamSX3( "ACH_RESERV" )[1] )
			lRet :=	.F.
		Endif
	Endif
Endif
RestArea( AreaAnt )

Return( lRet )
                
//------------------------------------------------------------------------------
/*/{Protheus.doc} TmkA341Rot

Retorna o array aRotina do Tmka341    

@sample 	TmkA341Rot()

@return   	MenuDef   -  Retorna o menu a ser exibido na aplicação

@author		Vendas CRM
@since		15/09/08
@version	12
/*/
//------------------------------------------------------------------------------
Function TmkA341Rot()

Return MenuDef()
                     
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341VldEnt

Efetua a validacao da origem para saber se o campo ACH_ENTORI pode ser editavel.

@sample 	Tk341VldEnt()

@return   	lRet   -  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		22/05/13
@version	12
/*/
//------------------------------------------------------------------------------
Function Tk341VldEnt()

Local lRet := .F.

If M->ACH_ORIGEM $ "1|5|7" 
	 lRet := .T. 
EndIf

Return ( lRet )
     

//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341VldCd

Efetua a validacao para saber se o codigo que o usuario digitou existe na tabela

@sample 	TK341VldCd()

@return   	lRet   -  Retorna verdadeiro ou falso

@author		Vendas CRM
@since		22/05/13
@version	12
/*/
//------------------------------------------------------------------------------
Function TK341VldCd()   

Local lRet	:=	.F. 

Do Case
	Case M->ACH_ORIGEM == "1" .AND. !Empty(M->ACH_ENTORI)	//1=Mailing
		lRet := ExistCpo("SA2", M->ACH_ENTORI)
	Case M->ACH_ORIGEM == "5" .AND. !Empty(M->ACH_ENTORI)	//5=Evento
		lRet := ExistCpo("ACD", M->ACH_ENTORI)
	Case M->ACH_ORIGEM == "7" .AND. !Empty(M->ACH_ENTORI)	//7=Parceiro 
		lRet := ExistCpo("AC4", M->ACH_ENTORI)
	Case Empty(M->ACH_ENTORI)
		lRet := .T.
EndCase 

Return( lRet )          

//-------------------------------------------
/*/  Estrutura do Arquivo de mailing padrao	
              									
   01 - Nome										
   02 - Nome Fantasia								
   03 - Endereco									
   04 - Municipio									
   05 - Cep											
   06 - Estado										
   07 - DDD         								
   08 - Telefone									
   09 - Fax											
   10 - EMAIL										
   11 - Url											
   12 - CGC											
   13 - Contato										
   14 - Cargo do Contato 				  			
/*/
//-------------------------------------------
                
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Mile

Importa layout do acelerador MILE referente ao adapter TMKA341 (Suspect)

@sample 	Tk341Mile() 

@param		cCodLayout				Layout a ser importado@param		
	
@return	Verdadeiro ou Falso

@author	Aline Kokumai
@since		20/06/2013       
@version	P11.80   
/*/
//------------------------------------------------------------------------------
Function Tk341Mile(cCodLayout)

Local lRetorno 	:= .T.									//Retorno da função
Local cCode 		:= ""		 							//Codigo do layout
Local cDesc 		:= ""									//Descrição do layout
Local cAdapter		:= 'TMKA341' 							//Nome do adapter
Local cType		:= '1'									//Código tipo
Local cAtivo		:= '1'									//Código ativo
Local cLayout 		:= ""

If cCodLayout == "ACHLAY01"
	FATPDLogUser('TK341MILE')	// Log de Acesso LGPD
	Tk341ACHLAY(@cCode, @cDesc, @cLayout)

EndIf

DbSelectArea("XXJ")
RecLock("XXJ",.T.)
XXJ->XXJ_CODE 	:= cCode
XXJ->XXJ_DESC 	:= cDesc
XXJ->XXJ_ADAPT	:= cAdapter
XXJ->XXJ_LAYOUT	:= cLayout
XXJ->XXJ_TYPE	:= cType
XXJ->XXJ_ACTIVE	:= cAtivo
XXJ->(MsUnLock())

Return(lRetorno)  

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341ACHLAY

Carrega o conteúdo XML do layout ACHLAY01.

@sample 	Tk341ACHLAY(cCode, cDesc, cLayout) 

@param		cCode				Codigo do layout	
@param		cDesc				Descrição do layout
@param		cLayout			Conteúdo XML do layout
	
@return	

@author	Cristiane Nishizaka
@since		29/10/2013       
@version	P11.90   
/*/
//------------------------------------------------------------------------------

Function Tk341ACHLAY(cCode, cDesc, cLayout)

cCode 				:= 'ACHLAY01' 							//Codigo do layout
cDesc 				:= STR0074								//Descrição do layout: 'LAYOUT IMPORTACAO DE SUSPECT'

	cLayout := 		'<?xml version="1.0" encoding="UTF-8"?><CFGA600 Operation="4" version="1.01">'+;
						'<XZ1MASTER modeltype="FIELDS" >'+;
							'<XZ1_LAYOUT order="1"><value>ACHLAY01</value></XZ1_LAYOUT>'+;
							'<XZ1_TYPE order="2"><value>2</value></XZ1_TYPE>'+;
							'<XZ1_DESC order="3"><value>'+STR0074+'</value> </XZ1_DESC>'+;
							'<XZ1_ADAPT order="4"><value>TMKA341</value></XZ1_ADAPT>'+;
							'<XZ1_STRUC order="5"><value>2</value></XZ1_STRUC>'+;
							'<XZ1_SEPARA order="6"><value>;</value></XZ1_SEPARA>'+;
							'<XZ1_TYPEXA order="7"><value>1</value></XZ1_TYPEXA>'+;
							'<XZ1_SEPINI order="8"><value>2</value></XZ1_SEPINI>'+;
							'<XZ1_SEPFIN order="9"><value>2</value></XZ1_SEPFIN>'+;
							'<XZ1_TABLE order="10"><value>ACH</value></XZ1_TABLE>'+;
							'<XZ1_DESTAB order="11"><value>'+STR0075+'</value></XZ1_DESTAB>'+; //SUSPECTS
							'<XZ1_ORDER order="12"><value>1</value></XZ1_ORDER>'+;
							'<XZ1_SOURCE order="13"><value>0000</value></XZ1_SOURCE>'+;
							'<XZ1_TIPDAT order="18"><value>1</value></XZ1_TIPDAT>'+;
							'<XZ1_DECSEP order="19"><value>2</value></XZ1_DECSEP>'+;
							'<XZ1_EMULTC order="20"><value>2</value></XZ1_EMULTC>'+;
							'<XZ1_DETOPC order="21"><value>2</value></XZ1_DETOPC>'+;
							'<XZ1_IMPEXP order="23"><value>1</value></XZ1_IMPEXP>'+;
							'<XZ1_VERSIO order="24"><value>1.0</value></XZ1_VERSIO>'+;
							'<XZ1_MVCOPT order="25"><value>2</value></XZ1_MVCOPT>'+;
							'<XZ1_MVCMET order="26"><value>1</value></XZ1_MVCMET>'+;
						'<XZ2DETAIL modeltype="GRID">'+;
							'<struct>'+;
								'<XZ2_LAYOUT order="1"></XZ2_LAYOUT><XZ2_SEQ order="2"></XZ2_SEQ>'+;
								'<XZ2_CHANEL order="3"></XZ2_CHANEL>'+;
								'<XZ2_SUPER order="4"></XZ2_SUPER>'+;
							'</struct>'+;
							'<items>'+;
								'<item id="1" deleted="0" >'+;
									'<XZ2_SEQ>01</XZ2_SEQ>'+;
									'<XZ2_CHANEL>01</XZ2_CHANEL>'+;
										'<XZ3DETAIL modeltype="FIELDS" >'+;
											'<XZ3_CHANEL order="2"><value>01</value></XZ3_CHANEL>'+;
											'<XZ3_DESC order="3"><value>'+STR0076+'</value></XZ3_DESC>'+; //CANAL 01
											'<XZ3_IDOUT order="4"><value>ACHMASTER</value></XZ3_IDOUT>'+;
											'<XZ3_OCCURS order="5"><value>1</value></XZ3_OCCURS></XZ3DETAIL>'+;
												'<XZ4DETAIL modeltype="GRID" optional="1">'+;
													'<struct>'+;
														'<XZ4_LAYOUT order="1"></XZ4_LAYOUT>'+;
														'<XZ4_CHANEL order="2"></XZ4_CHANEL>'+;
														'<XZ4_SEQ order="3"></XZ4_SEQ>'+;
														'<XZ4_FIELD order="4"></XZ4_FIELD>'+;
														'<XZ4_TYPFLD order="5"></XZ4_TYPFLD>'+;
														'<XZ4_EXEC order="6"></XZ4_EXEC>'+;
														'<XZ4_COND order="7"></XZ4_COND>'+;
														'<XZ4_NOVAL order="8"></XZ4_NOVAL>'+;
														'<XZ4_DESC order="9"></XZ4_DESC>'+;
														'<XZ4_OBS order="10"></XZ4_OBS>'+;
														'<XZ4_SOURCE order="11"></XZ4_SOURCE>'+;
													'</struct>'+;
													'<items>'+;
														'<item id="1" deleted="0" >'+;
															'<XZ4_SEQ>001</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CODIGO</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_COND>.F.</XZ4_COND>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CODIGO"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0001</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="2" deleted="0" >'+;
															'<XZ4_SEQ>002</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_LOJA</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_LOJA"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0002</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="3" deleted="0" >'+;
															'<XZ4_SEQ>003</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_RAZAO</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_RAZAO"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0003</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="4" deleted="0" >'+;
															'<XZ4_SEQ>004</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CGC</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_EXEC>IIF(!Empty(xA),Strtran(Strtran(Strtran( xA, &quot;-&quot;, &quot;&quot; ),&quot;/&quot;,&quot;&quot;),&quot;.&quot;,&quot;&quot;),&quot;&quot;)</XZ4_EXEC>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CGC"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0004</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="5" deleted="0" >'+;
															'<XZ4_SEQ>005</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_TIPO</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_TIPO"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0005</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="6" deleted="0" >'+;
															'<XZ4_SEQ>006</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_STATUS</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_STATUS"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0006</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="7" deleted="0" >'+;
															'<XZ4_SEQ>007</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_NFANT</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_NFANT"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0007</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="8" deleted="0" >'+;
															'<XZ4_SEQ>008</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_END</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_END"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0008</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="9" deleted="0" >'+;
															'<XZ4_SEQ>009</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_BAIRRO</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_BAIRRO"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0009</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="10" deleted="0" >'+;
															'<XZ4_SEQ>010</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CIDADE</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CIDADE"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0010</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="11" deleted="0" >'+;
															'<XZ4_SEQ>011</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_EST</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_EST"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0011</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="12" deleted="0" >'+;
															'<XZ4_SEQ>012</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CEP</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_EXEC>IIF(!Empty(xA),Strtran(Strtran(Strtran( xA, &quot;-&quot;, &quot;&quot; ),&quot;/&quot;,&quot;&quot;),&quot;.&quot;,&quot;&quot;),&quot;&quot;)</XZ4_EXEC>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CEP"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0012</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="13" deleted="0" >'+;
															'<XZ4_SEQ>013</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_PAIS</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_PAIS"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0013</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="14" deleted="0" >'+;
															'<XZ4_SEQ>014</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_DDI</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_DDI"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0014</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="15" deleted="0" >'+;
															'<XZ4_SEQ>015</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_DDD</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_DDD"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0015</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="16" deleted="0" >'+;
															'<XZ4_SEQ>016</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_TEL</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_EXEC>IIF(!Empty(xA),Strtran(Strtran(Strtran( xA, &quot;-&quot;, &quot;&quot; ),&quot;/&quot;,&quot;&quot;),&quot;.&quot;,&quot;&quot;),&quot;&quot;)</XZ4_EXEC>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_TEL"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0016</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="17" deleted="0" >'+;
															'<XZ4_SEQ>017</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_FAX</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_EXEC>IIF(!Empty(xA),Strtran(Strtran(Strtran( xA, &quot;-&quot;, &quot;&quot; ),&quot;/&quot;,&quot;&quot;),&quot;.&quot;,&quot;&quot;),&quot;&quot;)</XZ4_EXEC>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_FAX"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0017</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="18" deleted="0" >'+;
															'<XZ4_SEQ>018</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_EMAIL</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_EMAIL"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0018</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="19" deleted="0" >'+;
															'<XZ4_SEQ>019</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_URL</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_URL"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0019</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="20" deleted="0" >'+;
															'<XZ4_SEQ>020</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_MIDIA</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_MIDIA"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0020</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="21" deleted="0" >'+;
															'<XZ4_SEQ>021</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CNAE</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CNAE"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0021</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="22" deleted="0" >'+;
															'<XZ4_SEQ>022</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_FATANU</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_FATANU"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0022</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="23" deleted="0" >'+;
															'<XZ4_SEQ>023</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_ORIGEM</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_ORIGEM"), "@!")+'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0023</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="24" deleted="0" >'+;
															'<XZ4_SEQ>024</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_ENTORI</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_ENTORI"), "@!") +'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0024</XZ4_SOURCE>'+;
														'</item>'+;
														'<item id="25" deleted="0" >'+;
															'<XZ4_SEQ>025</XZ4_SEQ>'+;
															'<XZ4_FIELD>ACH_CODSEG</XZ4_FIELD>'+;
															'<XZ4_TYPFLD>C</XZ4_TYPFLD>'+;
															'<XZ4_NOVAL>2</XZ4_NOVAL>'+;
															'<XZ4_DESC>'+ Transform(RetTitle("ACH_CODSEG"), "@!") +'</XZ4_DESC>'+;
															'<XZ4_SOURCE>0025</XZ4_SOURCE>'+;
														'</item>'+;
													'</items>'+;
												'</XZ4DETAIL>'+;
										'<XZ5DETAIL modeltype="GRID" optional="1">'+;
											'<struct>'+;
												'<XZ5_LAYOUT order="1"></XZ5_LAYOUT>'+;
												'<XZ5_CHANEL order="2"></XZ5_CHANEL>'+;
												'<XZ5_SEQ order="3"></XZ5_SEQ>'+;
												'<XZ5_FIELD order="4"></XZ5_FIELD>'+;
												'<XZ5_TYPFLD order="5"></XZ5_TYPFLD>'+;
												'<XZ5_EXEC order="6"></XZ5_EXEC>'+;
												'<XZ5_COND order="7"></XZ5_COND>'+;
												'<XZ5_OBS order="8"></XZ5_OBS>'+;
												'<XZ5_SOURCE order="9"></XZ5_SOURCE>'+;
											'</struct></XZ5DETAIL>'+;
										'</item>'+;
									'</items>'+;
								'</XZ2DETAIL>'+;
							'</XZ1MASTER>'+;
						'</CFGA600>'

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk341Desq

Motivo da desqualificação do Suspect

@sample 	Tk341Desq() 

@return	

@author	    Totvs
@since		25/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Function Tk341Desq(oModel, lMbrowse)

Local oDlg      := Nil
Local oPanel    := Nil
Local oSay      := Nil
Local oMemo	    := Nil
Local oMotivo   := Nil
Local oDescMot  := Nil
Local lRet      := .F.
Local cCodMot   := Space(6)
Local cDescMot  := ""
Local cObsMot   := ''
Local cStatus   := ''
Local cCodPro   := ''
Local cLojPro   := ''

Default oModel	:= Nil
Default lMbrowse 	:= .T.

If oModel <> Nil
	cStatus 	:= oModel:GetValue( "ACHMASTER", "ACH_STATUS"  )
	cCodMot	:= oModel:GetValue( "ACHMASTER", "ACH_CODESQ" )
	cObsMot	:= oModel:GetValue( "ACHMASTER", "ACH_OBSDES" ) 
	cCodPro 	:= oModel:GetValue( "ACHMASTER", "ACH_CODPRO"  )
	cLojPro	:= oModel:GetValue( "ACHMASTER", "ACH_LOJPRO" )
Else
	cStatus 	:= ACH->ACH_STATUS
	cCodMot	:= ACH->ACH_CODESQ
	cObsMot	:= ACH->ACH_OBSDES
	cCodPro 	:= ACH->ACH_CODPRO
	cLojPro	:= ACH->ACH_LOJPRO
EndIf

IF	(cStatus <> '6' .And. Empty(cCodPro) .And. Empty(cLojPro)) 

	oDlg := FWDialogModal():New()
		oDlg:SetBackGround( .T. )
		oDlg:SetTitle( STR0113 ) //"Desqualificação de Suspect"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
		oDlg:SetEscClose( .T. )
		oDlg:SetSize( 150, 300 )
		oDlg:EnableFormbar( .T. )
	
		//----------------------------------------
		// Cria a Janela
		//----------------------------------------
		oDlg:CreateDialog()
	
		//----------------------------------------
		// Cria o Painel
		//----------------------------------------
		oPanel := oDlg:GetPanelMain()
	
		oDlg:CreateFormBar()

		//Código do Motivo
		oMotivo := TGet():New( 010, 010, { |u| If( PCount() > 0, cCodMot := u, cCodMot ) }, oPanel, 030, 009,;
				PesqPict( "SUN", "UN_ENCERR" ),{||ExistCpo( "SUN", cCodMot ) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SUN", cCodMot,,,,.T.,,, STR0114, 2)
		oMotivo:bF3 := &('{|| IIf(ConPad1(,,,"SUN",,,.F.),Eval({|| cCodMot := SUN->UN_ENCERR,oMotivo:Refresh()}),.T.)}')

		//Descrição do Motivo
		oDescMot := TGet():New( 010, 100, { |u| Alltrim( POSICIONE( "SUN", 1, FwxFilial("SUN")+cCodMot, "UN_DESC" ) ) }, oPanel, 130, 009,;
				PesqPict( "SUN", "UN_DESC" ), {|| oDlg:Refresh()}, 0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F., , cDescMot,,,,.T.,,, STR0115, 2)		
	
		oSay := TSay():New( 30, 10, { ||STR0116 }, oPanel,,,,,,.T.) //"Informe uma descrição mais detalhada:"	
		@ 40, 10 Get oMemo Var cObsMot Of oPanel VALID NAOVAZIO(cObsMot) MULTILINE SIZE 275,050 PIXEL		
				
		oDlg:AddButton( STR0117,{|| Iif(!ExistCpo("SUN", cCodMot,1) , '',; //"Atenção",  
		               (TK341SaveDesq( 'D', cCodMot, cObsMot, oModel, lMbrowse ),oDlg:Deactivate()))}, STR0117, , .T., .F., .T., )//"Confirmar"	
		oDlg:AddButton( "Sair",{|| oDlg:Deactivate() }, "Sair", , .T., .F., .T., )//"Sair"
		

	oDlg:Activate()
Else
	Help("",1,"HELP",,STR0131 ,1) //"Esta conta foi convertida, não sera possível desqualilica-la pelo cadastro vigente."
	lRet := .F.	
EndIf
	
	
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341SaveDesq

Faz a gravaçao da desqualificacao ou reativacao de um Prospect.

@sample 	TK341SaveDesq() 

@param      cTipo   - desqualificacao ou reativacao
            cCodMot - codigo do motivo da desqualificação
            cObsMot - obs da desqualificação

@return	Verdadeiro

@author		Totvs - CRM 
@since		28/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function TK341SaveDesq( cTipo, cCodMot, cObsMot, oModel, lMbrowse )
Local aArea		:= {}
Local cUserL		:= ""
Local cMsg			:= ""
Local lProcessa	:= .T.
Local oMdlACH		:= Nil

Default cTipo		:= ''
Default cCodMot	:= ''
Default cObsMot	:= ''
Default oModel	:= Nil
Default lMbrowse	:= .T.

If cTipo == "R"
	If	ACH->ACH_STATUS == "6"
		cMsg		:= STR0140	//"Não é possível a reativação de um suspect que já é um prospect."
		lProcessa	:= .F.
	EndIf
	If	lProcessa .AND. ACH->ACH_STATUS <> "5"
		cMsg		:= STR0144	//"Não é possível a reativação de um Suspect que não esteja desativado."
		lProcessa	:= .F.
	EndIf
EndIf

If	lProcessa

	aArea		:= GetArea()
	cUserL		:= RetCodUsr()
	If lMbrowse
		oModel    := FwLoadModel('TMKA341')
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
	EndIf
    
	oMdlACH := oModel:GetModel("ACHMASTER")

	If	cTipo == 'D' //desqualificação
		oMdlACH:SetValue("ACH_CODESQ",cCodMot)
		oMdlACH:SetValue("ACH_OBSDES",cObsMot)
		oMdlACH:SetValue("ACH_STATUS",'5')
		oMdlACH:SetValue("ACH_MSBLQL",'1')

		oMdlACH:SetValue("ACH_CODUSR",cUserL)
		oMdlACH:SetValue("ACH_DTREAT",Ctod(''))
		oMdlACH:SetValue("ACH_DTDESQ",dDataBase)
	Else
		If	oMdlACH:GetValue("ACH_STATUS") == '5'
			If	AVISO(STR0118, STR0119, { STR0120, STR0121 }) == 1 //"Reativação de Suspect", "Deseja mesmo reativar este registro?", "Reativar", "Cancelar"
				oMdlACH:SetValue("ACH_CODESQ",'')
				oMdlACH:SetValue("ACH_OBSDES",'')
				oMdlACH:SetValue("ACH_STATUS",'1')
				oMdlACH:SetValue("ACH_MSBLQL",'2')
				oMdlACH:SetValue("ACH_CODUSR",cUserL)
				oMdlACH:SetValue("ACH_DTREAT",dDataBase)
				oMdlACH:SetValue("ACH_DTDESQ",Ctod(''))
			Endif
		EndIf
	Endif

	If lMbrowse
		If oModel:VldData()
			oModel:CommitData()
			oModel:DeActivate()
		Else
			aError := oModel:GetErrorMessage()
			Help("",1,"HELP",,aError[6],1)
		EndIf
	EndIf
	RestArea( aArea )
Else
	Help("",1,"TK341SaveDesq",, cMsg ,1)
EndIf
Return( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA341Conv

Tela de Conversão de Resposta de Campanha. 

@sample		CRMA341Conv()

@param		Nenhum 

@return		lRet		.T.

@author		Vendas CRM
@since		26/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------

Function CRMA341Conv()

Local oModel		:= FWLoadModel("TMKA341")
Local oDlg			:= Nil
Local oPanel		:= Nil
Local oGrpProsp		:= Nil
Local oGrpOpp		:= Nil
Local oF3Prosp		:= Nil
Local oConvProsp	:= Nil
Local oOpp			:= Nil
Local lConvProsp	:= .T.
Local lOpp			:= .F.
Local lRet          := .T.
Local oBut1		:= Nil
Local oBut2		:= Nil
Local cF3Prosp 		:= ACH->ACH_CODIGO
Local cLojaACH      := ACH->ACH_LOJA
Local lOpRap 	    := .T.

IF	SuperGetMv( "MV_CNVOPOR" , .F. , .F. ) == .T.
	lOpRap := .F.
	lOpp   := .T.	 
Endif	 

If ACH->ACH_MSBLQL == '1'
	Help("",1,"HELP",,STR0122,1) //"Este Suspect não pode ser convertida pois está inativa."
	lRet := .F.	
EndIf

If 	ACH->ACH_STATUS == '6'
	Help("",1,"HELP",,STR0123,1) //"Este Suspect ja foi convertido para prospect."
	lRet := .F.	
EndIf

DbSelectArea("AO3")
AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
AO3->(DbSeek(xFilial("AO3")+RetCodUsr()))

If lRet

	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	DEFINE MSDIALOG oDlg TITLE STR0124 FROM 5,0 TO 18.5,35.4 OF oMainWnd //"Converter"   
		@ 000, 000 MSPANEL oPanel   PROMPT '' SIZE 51,165 OF oDlg
		oPanel:Align := CONTROL_ALIGN_TOP 
		
		//Converter em Prospect
		@ 002,002 GROUP oGrpProsp 		TO 20, 140 		PROMPT "" 		   OF oPanel PIXEL
		@ 006,005 CHECKBOX oConvProsp 	VAR lConvProsp 	PROMPT STR0125     OF oPanel SIZE 070, 010 PIXEL WHEN .F. //"Converter em Prospect"

		@ 006,088 MSGET oF3Prosp 		VAR cF3Prosp        			   OF oPanel SIZE 048, 010 PIXEL WHEN .F.
				
		//Criar uma Oportunidade
		@ 025,002 GROUP oGrpOpp 		TO 50, 140 		PROMPT "" 		   OF oPanel PIXEL
		@ 035,005 CHECKBOX oOpp 		VAR lOpp 		PROMPT STR0126     OF oPanel SIZE 070, 010 PIXEL When lOpRap // "Criar uma Oportunidade"


		DEFINE SBUTTON oBut1 FROM 80, 80  TYPE 1 ENABLE OF oPanel PIXEL ACTION {((),lRet := TK341Oportu(cF3Prosp, cLojaACH, lOpp) , oDlg:END(),)} 
		DEFINE SBUTTON oBut2 FROM 80, 110 TYPE 2 ENABLE OF oPanel PIXEL ACTION {lRet:=.F.,oDlg:End()}
	
	ACTIVATE MSDIALOG oDlg CENTERED
Endif


Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341Oportu

Oportunidade simplificada

@sample 	TK341Oportu() 

@param      cF3Prosp - codigo do prospect
            cLojaACH - loja do prospect
            lOpp     - Verdadeira vai gerar a oportunidade simplificada

@return	Verdadeiro

@author		Totvs - CRM 
@since		28/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function TK341Oportu(cF3Prosp, cLojaACH, lOpp)
 	
Local cCodigo	:= ""
Local cLoja  	:= ""
Local cCdProsp	:= ""
Local lRet	   	:= .F.
Local nSaveSx8	:= GetSX8Len()

If cPaisLoc != 'RUS'
	MV_PAR01 := 1 // Prospect Validation by CGC = YES
	MV_PAR02 := 1 // Customer Validation by CGC
Else
	MV_PAR01 := 0 // Field CGC not used
	MV_PAR02 := 0 // Field CGC not used
EndIf
MV_PAR03 := cF3Prosp
MV_PAR04 := cF3Prosp

BEGIN TRANSACTION
	cCdProsp	:= TK341Num()
	lRet := Tk341GrvPros(cCdProsp)
	
	If	lOpp
		DbSelectArea("ACH")
		ACH->(DbSetOrder(1))	// ACH_FILIAL+ACH_CODIGO+ACH_LOJA
		ACH->(DbSeek(xFilial("ACH")+ cF3Prosp + cLojaACH))
		IF	!Empty(ACH->ACH_CODPRO) .And. !Empty(ACH->ACH_LOJPRO)
			If nModulo == 73
				If !Empty(ACH->ACH_VEND)
					cCodVend := ACH->ACH_VEND
				Else
					cCodVend := AO3->AO3_VEND
				EndIf
			Else	
				cCodVend := Posicione("SA3",7,xFilial("SA3")+RetCodUsr(), "SA3->A3_COD")
			EndIf
			lRet := TK341ExecOpt( ACH->ACH_CODPRO, ACH->ACH_LOJPRO,cCodVend,,"SUS" )
		
		Endif	
	EndIf
	If !lRet
		DisarmTransaction()
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		Enddo
	Else
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		Enddo
	EndIf
END TRANSACTION

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341ExecOpt
Rotina responsável por exibir a tela da oportunidade de maneira simplificada em
formato modal.  
@sample	TK341ExecOpt( cProspe, cLoja, cCodVend, cCodAtend )
@param		cProspe = Código do novo prospect gerado
@param		cLoja	 = Loja do novo prospect gerado
@return	Verdadeiro
@author	Thamara Villa 
@since		01/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function TK341ExecOpt(cProspe, cLoja, cCodVend, cCodAtend, cEntidad)

Local oModel 	  	:= FWLoadModel("FATA300")
Local oView			:= FWLoadView("FATA300")
Local oStructAD1	:= oView:GetViewStruct("AD1MASTER")
Local oExecView  	:= Nil
Local nGrvCompr		:= SuperGetMv("MV_CRMGAGE",,2)	//Confirma se deseja criar tarefa / compromisso ou e-mail para a Oportunidade Rápida
Local cCodUsrPr		:= ""	//Código do usuário proprietário da Atividade/Compromisso/E-mail que pode ser criado para a Oportunidade Rápida 
Local lRetorno 		:= .F.
Local lExecView		:= SuperGetMV("MV_TMKOPRA",.F.,.T.)	//Habilita
Local lRet			:= .T. 	

Default cProspe		:= ""
Default cLoja		:= ""
Default cCodVend	:= ""
Default cEntidad	:= ""
Default cCodAtend	:= ""

//Ponto de entrada para indicar se a oportunidade deve ser gerada. 
If ExistBlock("TK341OPG")
	lRet := ExecBlock("TK341OPG",.f.,.f.)
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf

If lRet
	If !lExecView
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()

		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_PROSPE", cProspe )
		oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_LOJPRO", cLoja )

		//Ponto de entrada para usuario preencher outras informacoes no model.
		If ExistBlock("TK341OPT")
			ExecBlock("TK341OPT",.F.,.F.,oModel)
		EndIf
		
		If oModel:VldData()
		
			oModel:CommitData()
			lRetorno := .T.
			
		Else
			aError := oModel:GetErrorMessage()
			Help("",1,"TK341ExecOpt",,aError[6],1)
			lRetorno := .F.
		EndIf	
	Else
		oStructAD1:SetProperty( "AD1_PROSPE" , MVC_VIEW_CANCHANGE,.F. )
		oStructAD1:SetProperty( "AD1_LOJPRO" , MVC_VIEW_CANCHANGE,.F. )
		oStructAD1:SetProperty( "AD1_VEND"   , MVC_VIEW_CANCHANGE,.T. )
		oStructAD1:SetProperty( "AD1_CODCLI" , MVC_VIEW_CANCHANGE,.F. )
		oStructAD1:SetProperty( "AD1_LOJCLI" , MVC_VIEW_CANCHANGE,.F. )
		
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		FATPDLogUser('TK341EXECO')	// Log de Acesso LGPD
		oModel:Activate()
		
		If cEntidad == "SUS"
			oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_PROSPE", cProspe )
			oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_LOJPRO", cLoja )
		ElseIf cEntidad == "SA1"
			oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_CODCLI", cProspe )
			oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_LOJCLI", cLoja )
		EndIf
		oModel:GetModel( "AD1MASTER" ):SetValue( "AD1_VEND", cCodVend )
			
		If IsInCallStack("Tk272GrvTmk")
			oModel:GetModel( "AD1MASTER" ):LoadValue( "AD1_CODTMK", cCodAtend )
		Endif
		
		oModel:GetModel( "AD2DETAIL" ):SetValue( "AD2_VEND",   cCodVend )    
		oModel:GetModel( "AD2DETAIL" ):SetValue( "AD2_PERC",   100 )
		
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0143)	//"Oportunidade Rápida"
		oExecView:SetSource( "FATA300" )
		oExecView:SetOK({|oViewExec| lRetorno := Tk341VdExecOpt(oViewExec) })
		oExecView:SetModal( .T. )
		oExecView:SetOperation( MODEL_OPERATION_INSERT )
		oExecView:SetModel( oModel )
		oExecView:SetView(oView)
		oExecView:OpenView( .F. )
		oExecView:DeActivate()
	EndIf


	If	nGrvCompr == 1 .OR. ( nGrvCompr == 3 .AND. MsgYesNo(STR0145) )	//"Deseja criar um agendamento para a Oportunidade?"
		cCodUsrPr	:= Posicione("AO3", 2, xFilial("AO3") + AD1->AD1_VEND, "AO3_CODUSR") // Utiliza o vendedor que efetivamente foi gravado na Oportunidade Rápida para buscar o seu Código de Usuário
		CRMA180(/*uRotAuto*/, /*nOpcAuto*/, /*lExecAuto*/, 3/*nOper*/, "AD1"/*cAlias*/, /*aAnexos*/, /*oMdlAux*/, /*nTpAtiv*/, /*cVDefault*/, /*cCodRastr*/, cCodUsrPr /*cCodUsrPr*/)
	EndIf
EndIf
Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TK341ExecOpt

Rotina responsável pelo retorno Falso caso o usuário cancele a operação de Oportunidade Rápida.

@sample	Tk341VdExecOpt(oViewExec)

@param		oViewExec

@return	Verdadeiro ou Falso

@author	Philip Pellegrini
@since		20/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Tk341VdExecOpt(oViewExec)

Local lRetorno := .T.
Local oModel	 := oViewExec:GetModel()
Local aError	 := {}

If !( oModel:VldData() )
	lRetorno := .F.
	aError := oModel:GetErrorMessage()
	Help("",1,"TK341VLDOP",,aError[6],1)
EndIf

If !lRetorno .AND. Empty(Posicione("AO3", 2, xFilial("AO3") + oModel:GetModel("AD1MASTER"):GetValue("AD1_VEND"), "AO3_CODUSR"))
	Help("",1,"Tk341VdExecOpt",,STR0146,1, 0,,,,,,{STR0147})	//"Vendedor selecionado não está vinculado a um usuário."##"Realize o vínculo do Vendedor selecionado a um usuário (A3_CODUSR)."
	lRetorno := .F.
EndIf
Return( lRetorno )

//------------------------------------------------------------------
/*/{Protheus.doc} TK341Num()
Rotina responsável por retornar o Codigo do Prospect

@author 	Squad CRM
@since 		04/07/2018
@version 	12.1.17
@return 	cCodigo , Char,  Codigo do Prospect
/*/
//-------------------------------------------------------------------

Static Function TK341Num()

Local cFil		:= xFilial("SUS")
Local cCodigo	:= GetSXENum("SUS","US_COD")
Local nSaveSx8	:= GetSX8Len()
		
DbSelectArea("SUS")
SUS->(DbSetOrder(1))
While .T.
	If !SUS->(DbSeek(cFil + cCodigo))
		Exit
	Else
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		Enddo
		cCodigo := GetSXENum("SUS","US_COD")
	Endif
Enddo
Return cCodigo

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} TK341Expor
    @description
    Função que verifica se o suspect é do tipo exportacao ou nao.

    @type  Function
    @sample TK341Expor()
    @author Squad CRM & Faturamento
    @since 09/07/2020
    @version P12    
    @return lExporta, Logico, Indica se o suspect eh para uso em exportacao ou nao
/*/
//-----------------------------------------------------------------------------------
Static Function TK341Expor()
	Local lExporta := (ACH->ACH_EST = "EX" .And. ACH->ACH_TIPO = "5")
Return lExporta

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AO4GdModel

Cria um GridModel associado ao modelo informado no parãmetro, para evitar
a validação do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		AO4GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function AO4GdModel(cIDMasterM, oModel, cAliasMast )
Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasMast := ""

oModel:AddGrid("AO4CHILD",cIDMasterM,oStructAO4,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGdAO4(oGridModel, lCopy)})
oModel:SetRelation( "AO4CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, AO4->( IndexKey( 1 ) ) )
oModel:GetModel("AO4CHILD"):SetOnlyView()
oModel:GetModel("AO4CHILD"):SetOnlyQuery()
oModel:GetModel("AO4CHILD"):SetOptional(.T.)
oModel:GetModel("AO4CHILD"):SetNoInsertLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGdAO4 

Bloco de carga dos dados do submodelo.
Este bloco sera invocado durante a execução do metodo activate desta classe.
O bloco recebe por parametro o objeto de model do FormGrid(FWFormGridModel) e um 
valor lógico indicando se eh uma operação de copia.

@param, oGridModel, objeto de model do FormGrid, FWFormGridModel
@param, lCopy     , indica se eh uma operação de copia, Boolean

@sample	LoadGdAO4(oGridModel, lCopy)

@return, aLoad, array com os dados que serão carregados no objeto, 
                o array deve ter a estrutura abaixo:
					[n]
					[n][1] ExpN: Id do registro (RecNo)
					[n][2] Array com os dados, os dados devem seguir exatamente 
					       a mesma ordem da estrutura de dados submodelo

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function LoadGdAO4(oGridModel, lCopy)
	
	Local aLoad      := {}
	Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStructAO4:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == "AO4_FILIAL"
			xValue := XFilial("AO4")
			cType  := ""
		Else
			cType  := aFields[nField][4]
			nLen   := aFields[nField][5]	
		EndIf

		Do Case
			Case cType == "C"
				xValue := Space(nLen)
			Case cType == "N"
				xValue := 0
			Case cType == "L"
				xValue := .T.
			Case cType == "D"
				xValue := CToD("  /  /    ")
		End Case

		AAdd(aLoad[1][2], xValue)
	Next nField

	FwFreeObj(oStructAO4)
	FwFreeObj(aFields)

Return aLoad

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

