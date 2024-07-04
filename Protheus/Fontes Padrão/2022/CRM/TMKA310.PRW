#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA310.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ApWizard.ch"
#INCLUDE "CRMDEF.CH"

/*
Descricao dos itens da Campanha

1 - Evento
2 - Descricao do Evento 
3 - Script
4 - Titulo do Script
5 - Produto
6 - Nome do Produto
7 - Veiculacao
8 - Descricao
*/

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA310

Cadastro de Campanha

@sample 	TMKA310()

@param		Nenhum
	
@return	.T. 

@author	Vendas CRM
@since		21/02/2002       
@version	P12   
/*/
//------------------------------------------------------------------------------

Function TMKA310( cFilDef, aAddFil, cVDefault )

Local oMBrowse  := Nil 
Local oTableAtt	:= TableAttDef()
Local cFiltro		:= IIF( !Empty( cFilDef ), cFilDef, "" )
Local nX			:= 0

Private aRotina := MenuDef()

Default cFilDef   := ""
Default aAddFil   := {}
Default cVDefault := ""

If nModulo == 73 
	cFiltro += " UO_ATENDIM == '5' " 
Else 
	cFiltro += " UO_ATENDIM <> '5' " 
EndIf

//----------------
// Cria o Browse 
//----------------

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SUO") // Campanhas 
oMBrowse:SetDescription(STR0026) // "Cadastro de Campanhas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro Default do Browse                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cFiltro )
	oMBrowse:SetFilterDefault( cFiltro )
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtros adicionais do Browse                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
oMBrowse:SetAttach( .T. ) 				  //Habilita as visões do Browse

If oTableAtt <> Nil
	oMBrowse:SetViewsDefault( oTableAtt:aViews )   //Passa as visões para o  Browse
	oMBrowse:SetChartsDefault( oTableAtt:aCharts ) //Passa o gráfico para o Browse

	// selecionando a visão inicial 
	If !Empty( cVDefault ) 
		nScan := aScan( oTableAtt:aViews, { |x| x:cID == cVDefault } )
		If nScan > 0 
			oMBrowse:SetIDViewDefault( oTableAtt:aViews[nScan]:cID )
		EndIf
	EndIf 
	
	oMBrowse:SetIDChartDefault( "CampTp" )
EndIf

oMBrowse:SetChgAll(.F.)	
oMBrowse:SetSeeAll(.F.)
oMBrowse:SetTotalDefault("UO_CODCAM","COUNT",STR0048) // "Total de Registros"

// se for diferente do modulo CRM, então abre o browse com o grafico fechado
If nModulo <> 73
	oMBrowse:SetOpenChart( .F. )
EndIf

oMBrowse:Activate()

Return(.T.)

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

Local oTableAtt	:= FWTableAtt():New()
Local cCodUsr 	:= RetCodUsr() 
Local oDSView	:= Nil
Local oMyCamp	:= Nil
Local oAtCamp	:= NIl
Local oQualif	:= Nil
Local oCampTp	:= Nil
Local oCampSt	:= Nil   
Local oCusOrc	:= Nil

oTableAtt:SetAlias("SUO")

//---------------------------------
// *** Cria as visões (Views) ***
//---------------------------------

//-----------------------------
// Campanhas Lançadas
//-----------------------------
oDSView := FWDSView():New()
oDSView:SetName( STR0041 ) //"Campanhas Lançadas"
oDSView:SetID( "DSView" ) 
oDSView:SetPublic( .T. )
oDSView:SetCollumns( { "UO_CODCAMP", "UO_DESC", "UO_DTINI", "UO_DTFIM", "UO_DTINIR",;
						"UO_DTTERMR", "UO_STATUS", "UO_DTINS", "UO_HRINS" } )
oDSView:SetOrder( 1 )//UO_FILIAL+UO_CODCAMP                                                                                                                                            
oDSView:AddFilter( STR0041, 'UO_STATUS == "2"' ) //"Campanhas Lançadas"
oTableAtt:AddView(oDSView)

If IsInCallStack("CRMA360") .OR. IsInCallStack("CRMA290") .OR. IsInCallStack("CRMA290A") .Or. IsInCallStack( "CA290CWDGT" )

	//-----------------------------
	// Minhas Campanhas
	//-----------------------------    
	oMyCamp := FWDSView():New()
	oMyCamp:SetName( STR0042 ) //"Minhas Campanhas"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	oMyCamp:SetID( "MyCamp" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
	oMyCamp:SetPublic( .T. )
	oMyCamp:SetCollumns( { "UO_CODCAMP", "UO_DESC", "UO_DTINI", "UO_DTFIM", "UO_DTINIR",;
							"UO_DTTERMR", "UO_STATUS", "UO_DTINS", "UO_HRINS" } )
	oMyCamp:SetOrder( 1 )//UO_FILIAL+UO_CODCAMP                                                                                                                                            
	oMyCamp:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'UO_FILIAL+UO_CODCAMP' )   
	oMyCamp:AddFilter( STR0042, "AO4_CODUSR = '" +cCodUsr+ "' AND AO4_ENTIDA = 'SUO' AND AO4_CTRLTT = 'T'" , "AO4" ) //"Minhas Campanhas"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	oTableAtt:AddView(oMyCamp)
	
EndIf

//-----------------------------
// Todas Campanhas Ativas
//-----------------------------
oAtCamp := FWDSView():New()
oAtCamp:SetName( STR0043 ) //"Todas Campanhas Ativas
oAtCamp:SetID( "AtCamp" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
oAtCamp:SetPublic( .T. )
oAtCamp:SetCollumns( { "UO_CODCAMP", "UO_DESC", "UO_DTINI", "UO_DTFIM", "UO_DTINIR",;
						"UO_DTTERMR", "UO_STATUS", "UO_DTINS", "UO_HRINS" } )
oAtCamp:SetOrder( 1 )//UO_FILIAL+UO_CODCAMP                                                                                                                                            
oAtCamp:AddFilter( STR0043, 'UO_MSBLQL == "2"' ) //"Todas Campanhas Ativas  
oTableAtt:AddView(oAtCamp)

//-----------------------------
// *** Criacao de Gráficos ***
//-----------------------------

//-------------------------------               
// Total de Campanhas por Tipo
//-------------------------------                     
oCampTp := FWDSChart():New()
oCampTp:SetName( STR0044 )  //Tipo de Campanha
oCampTp:SetTitle( STR0044 ) //Tipo de Campanha
oCampTp:SetID( "CampTp" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
oCampTp:SetPublic( .T. )
oCampTp:SetSeries( { { "SUO", "UO_CODCAMP", "COUNT" } } )    
oCampTp:SetCategory( { { "SUO", "UO_DTPCAMP" } } ) //Descrição do tipo de campanha 
oCampTp:SetType( "PIECHART" ) //Grafico de Pizza
oCampTp:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oCampTp:SetTitleAlign( CONTROL_ALIGN_TOP )              
oTableAtt:AddChart(oCampTp)

//-----------------------------------------               
// Orçamento vs. Custos Reais de Campanha
//-----------------------------------------
oCusOrc := FWDSChart():New()
oCusOrc:SetName( STR0045 ) //"Orçamentos vs. Custos"
oCusOrc:SetTitle( STR0045 )//"Orçamentos vs. Custos"
oCusOrc:SetID( "CusOrc" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
oCusOrc:SetPublic( .T. )
oCusOrc:SetSeries( { { "SUO", "UO_CUSTO", "SUM" }, { "SUO", "UO_ORCALOC", "SUM" } } )
oCusOrc:SetCategory( { { "SUO", "UO_DTTERMR" } } ) //Data Término Real UO_DTTERMR
oCusOrc:SetType( "BARCOMPCHART" ) //Gráfico de Barras
oCusOrc:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oCusOrc:SetTitleAlign( CONTROL_ALIGN_CENTER )   
oTableAtt:AddChart(oCusOrc)

//-------------------------------------------------
// Qualificação de Suspect e Prospect por Campanha
//-------------------------------------------------   
oQualif := FWDSChart():New()
oQualif:SetName( STR0046 ) //"Qualificação de Suspects e Prospects"
oQualif:SetTitle( STR0046 )//"Qualificação de Suspects e Prospects"
oQualif:SetID( "Qualif" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
oQualif:SetPublic( .T. )                  
oQualif:SetSeries( { { "SUO", "UO_PROSPE", "SUM" }, { "SUO", "UO_SUSPEC", "SUM" } } )
oQualif:SetCategory( { { "SUO", "UO_DESC" } } )
oQualif:SetType( "BARCOMPCHART" ) //Gráfico e Barras
oQualif:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oQualif:SetTitleAlign( CONTROL_ALIGN_CENTER )       
oTableAtt:AddChart(oQualif)

//-------------------------------               
// Campanhas por Status
//-------------------------------
oCampSt := FWDSChart():New()
oCampSt:SetName( STR0047 )  //"Status de Campanha" 
oCampSt:SetTitle( STR0047 ) //"Status de Campanha" 
oCampSt:SetID( "CampSt" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
oCampSt:SetPublic( .T. )
oCampSt:SetSeries( { { "SUO", "UO_CODCAMP", "COUNT" } } ) 
oCampSt:SetCategory( { { "SUO", "UO_STATUS" } } )
oCampSt:SetType( "BARCOMPCHART" )//Grafico de Barras     
oCampSt:SetLegend( CONTROL_ALIGN_BOTTOM )//Inferior
oCampSt:SetTitleAlign( CONTROL_ALIGN_CENTER )
oTableAtt:AddChart(oCampSt)

Return(oTableAtt)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados do Cadastro de Campanhas.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Vendas CRM
@since			20/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruSUO		:= FWFormStruct( 1, "SUO", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSUW		:= FWFormStruct( 1, "SUW", /*bAvalCampo*/, /*lViewUsado*/ )
Local bPosValidacao 	:= {|oModel| Tk310TudOk(oModel)}
Local bLinePost		:= {|oModelGrid| Tk310LinOk(oModelGrid)}
Local bCommit			:= {|oModel| Tk310Cmt(oModel)}

oModel	:= MPFormModel():New("TMKA310",/*bPreValidacao*/, bPosValidacao, Iif(nModulo == 73, bCommit,),/*bCancel*/ )

oModel:AddFields("SUOMASTER",/*cOwner*/,oStruSUO,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/ )
oModel:AddGrid("SUWDETAIL","SUOMASTER",oStruSUW,/*bLinePre*/,bLinePost,/*bPre*/,/*bPost*/,/*bLoad*/ )

//oModel:GetModel( 'SUWDETAIL' ):SetUniqueLine( { 'UW_CODCAMP', 'UW_', 'UW_'} )

If nModulo == 73
	//Tira a obrigatoriedade do campo 
	oStruSUO:SetProperty( "UO_TIPO", MODEL_FIELD_OBRIGAT,.F.) 
	//Seta o tipo de atendimento "Marketing"
	oStruSUO:SetProperty("UO_ATENDIM",MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,'5' ) )
	oStruSUO:SetProperty("UO_ATENDIM",MODEL_FIELD_WHEN,{||.F.} )
	//Preenchimento da Grid opcional
	oModel:GetModel( 'SUWDETAIL' ):SetOptional( .T. )
EndIf

oModel:SetRelation( 'SUWDETAIL', { { 'UW_FILIAL', 'xFilial( "SUW" )' }, { 'UW_CODCAMP', 'UO_CODCAMP' } }, SUW->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0026) // "Cadastro de Campanhas"
oModel:GetModel("SUOMASTER"):SetDescription("SUO")

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("SUOMASTER", oModel, "SUO" )

Return (oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface do Cadastro de Especificações.	

@sample		ViewDef()

@param			Nenhum

@return		ExpO - Objeto FWFormView

@author		Vendas CRM
@since			20/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel		:= FWLoadModel("TMKA310")
Local oStruSUO	:= FWFormStruct( 2, "SUO", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSUW	:= FWFormStruct( 2, "SUW", /*bAvalCampo*/, /*lViewUsado*/ )

Local cTitle		:= ""


oStruSUO:RemoveField( "UO_TOTFRA" )

If nModulo == 73	// SIGACRM
	oStruSUO:RemoveField( "UO_TIPO" )
	oStruSUO:RemoveField( "UO_META" )
	oStruSUO:RemoveField( "UO_METAOP" )
	oStruSUO:RemoveField( "UO_PREVEND" )
	oStruSUO:RemoveField( "UO_RETORNO" )
	oStruSUO:RemoveField( "UO_TOTFRA" )
	oStruSUO:RemoveField( "UO_VENCIDO" )
	oStruSUO:RemoveField( "UO_RECUPER" )
	cTitle := STR0028 // "Adicionar Lista de Marketing"
Else
	cTitle := STR0029 // "Adicionar Lista de Contatos"
EndIf

oView	:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SUO", oStruSUO, "SUOMASTER", )
oView:AddGrid("VIEW_SUW", oStruSUW, "SUWDETAIL")

// Campanhas
oView:CreateHorizontalBox("SUPERIOR", 50)
//oView:EnableTitleView("VIEW_SUO","Campanhas")

// Scripts Dinâmico X Campanha
oView:CreateHorizontalBox("INFERIOR", 50)
oView:EnableTitleView("VIEW_SUW",STR0030) // "Scripts Dinâmicos x Campanha"

oView:SetOwnerView("VIEW_SUO","SUPERIOR")
oView:SetOwnerView("VIEW_SUW","INFERIOR")

oView := CRMXAddAct("SUO",oView) //Adcionar Rotinas no 'Ações relacionadas' do Formulário

Asort(oView:aUserButtons,,,{ | x,y | y[1] > x[1] } )  

Return (oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação.

@sample		MenuDef()

@param			Nenhum

@return   		aRotina - Array das operações

@author		Vendas CRM
@since			20/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()

Local nPos        := 0
Local aRotina     := {}
Local aEntRelac   := {}
Local aAtiv       := {}
Local aAnotac     := {}
Local cTitle	  := ""

If nModulo == 73
	cTitle := STR0028 // "Adicionar Lista de Marketing"
Else
	cTitle := STR0029 // "Adicionar Lista de Contatos"
EndIf

ADD OPTION aRotina TITLE STR0002 	ACTION 'PesqBrw'			OPERATION 1	ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.TMKA310'	OPERATION 2	ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004	ACTION 'Tk310Inc'			OPERATION 3	ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION 'Tk310Alt'			OPERATION 4	ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.TMKA310'	OPERATION 5	ACCESS 0 // "Excluir"

ADD OPTION aEntRelac TITLE STR0031  ACTION 'CRMA260()'		    OPERATION 6	ACCESS 0 // "Respostas de Campanha"
ADD OPTION aRotina   TITLE cTitle	ACTION 'Tk310LstMk()'	    OPERATION 6	ACCESS 0 
ADD OPTION aEntRelac TITLE STR0033	ACTION 'Tk310Memb()'		OPERATION 8	ACCESS 0 // "Membros da Campanha"

If nModulo == 73
	ADD OPTION aRotina   TITLE STR0032	ACTION 'Tk310Ativ()'	OPERATION 7	ACCESS 0 // "Distribuir Atividades"
	ADD OPTION aEntRelac TITLE STR0025	ACTION 'CRMA200()'		OPERATION 3  	ACCESS 0 // "Privilégios"

	aEntRelac := CRMXINCROT( "SUO", aEntRelac )
	
	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
	If nPos > 0 
		ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
		Adel(aEntRelac,nPos)
		Asize(aEntRelac,Len(aEntRelac)-1)
	EndIf
	
	nPos := ASCAN(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
	If nPos > 0
		ADD OPTION aAtiv   TITLE STR0049 ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
		ADD OPTION aAtiv   TITLE STR0050 ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
		aEntRelac[nPos][2] := aAtiv
	EndIf

	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
	If nPos > 0
		ADD OPTION aAnotac   TITLE STR0051 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
		ADD OPTION aAnotac   TITLE STR0052 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anotações" 
		aEntRelac[nPos][2] := aAnotac
	EndIf

EndIf 

Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
ADD OPTION aRotina TITLE  STR0053 ACTION aEntRelac 	    OPERATION 8  ACCESS 0//"Relacionadas"

Return(aRotina)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310LinOk

Faz a pós validação da linha (LinhaOk).

@sample		Tk310LinOk(oSUWDetail)

@param			oSUWDetail	- Objeto da grid

@return		ExpL - 	.T. Troca de linha é realizada
						.F. Troca de linha não é realizada

@author		Vendas CRM
@since			20/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function Tk310LinOk(oSUWDetail)

Local lRet 	   	:= .T.
Local cScript		:= oSUWDetail:GetValue('UW_CODSCRI')

If nModulo <> 73  // SIGACRM
		If 	Empty(oSUWDetail:GetValue('UW_CODSCRI')) .AND.;
			Empty(oSUWDetail:GetValue('UW_CODEVE')) 	.AND.;
			Empty(oSUWDetail:GetValue('UW_CODCAMP'))
			Help(" ",1,"A010VAZ")
			lRet := .F.
		Endif
	
		//Se o tipo do atendimento RECEPTIVO / ATIVO, dos scripts forem diferentes
		//do tipo do atendimento da campanha, entao nao aceita.   	
		DbSelectArea("SUZ")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SUZ") + cScript)
			If SUZ->UZ_TIPO <> "3" .AND. SUZ->UZ_TIPO <> FwFldGet('UO_TIPO')
				Help(" ", 1, "NAOPERACAO")
				lRet := .F.
			Endif
		Endif	
EndIf


Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310TudOk

Faz a Pos Validação (TudoOk).

@sample		Tk310TudOk(oModel)

@param			ExpO - 	Objeto do modelo

@return		ExpL - 	.T. Validado
						.F. Não validado

@author		Vendas CRM
@since			20/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function Tk310TudOk(oModel)

Local oSUWDetail 	:= oModel:GetModel('SUWDETAIL')
Local nX			:= 0
Local lRet			:= .T.
Local cScript		:= ""
Local nLinValid	:= 0
Local nOpc			:= oModel:GetOperation()

If nModulo <> 73  // SIGACRM
	For nX := 1 To oSUWDetail:Length()
	
		If !oSUWDetail:IsDeleted()		
			oSUWDetail:GoLine(nX)
			cScript := oSUWDetail:GetValue('UW_CODSCRI')
			If Empty(cScript)
				lRet := .F.
				Exit
			EndIf	
			
			//Se o tipo do atendimento RECEPTIVO / ATIVO, dos scripts forem diferentes
			//do tipo do atendimento da campanha, entao nao aceita.   	
			DbSelectArea("SUZ")
			DbSetOrder(1)
			If DbSeek(xFilial("SUZ") + cScript)
				If SUZ->UZ_TIPO <> "3" .AND. SUZ->UZ_TIPO <> FwFldGet('UO_TIPO')
					lRet := .F.
				Endif
			Endif
			nLinValid++		
		EndIf
		
	Next nX	
	
	If !lRet
		Help(" ",1,"A010VAZ")
	Endif
	
	//Verifica se a campanha esta em uso na lista de contato
	If lRet
		If (nOpc == 5) .OR. (nLinValid == 0)//Exclusao
			lRet := Tk310Integ(nOpc) //Valida operacao
		EndIf
	EndIf
EndIf

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Integ

Verifica se a campanha pode ser excluida ou entao alterada sem o preenchimento de seus itens.  

@sample		Tk310Integ(nOpc)

@param			ExpN - 	Opção selecionada no vetor aRotina 

@return		ExpL - 	.T. Pode
						.F. Não pode

@author		Vendas CRM
@since			08/05/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function Tk310Integ(nOpc)

Local aArea		:= GetArea()			// Salva area atual
Local aAreaSU4	:= SU4->(GetArea())	// Salva area da tabela SU4
Local cQuery	:= ""					// Query para consulta em base Top
Local lRet		:= .T.					// Retorno da funcao

//Pesquisa por algum registro associado a campanha atual
//nas listas de contato           
	
cQuery 	:= "SELECT U4_CODCAMP FROM " + RetSqlName("SU4") + " SU4"
cQuery 	+= " WHERE SU4.D_E_L_E_T_ = '' "

If xFilial("SU4") == xFilial("SUO")
	cQuery	+= " AND SU4.U4_FILIAL = '" + M->UO_FILIAL + "'"
EndIf

cQuery	+= " AND SU4.U4_CODCAMP = '" + M->UO_CODCAMP + "'"

If Select("SU4TMP") > 0
	SU4TMP->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SU4TMP",.T.,.T.)

SU4TMP->(DbGoTop())

lRet := SU4TMP->(Eof()) //Se o arquivo estiver vazio, nao ha dependencia
	
SU4TMP->(DbCloseArea())

If !lRet
	If nOpc == 5
		MsgStop(STR0018,STR0017) //"Uma ou mais listas de contato dependem dos registros desta campanha."###"Atenção"
	Else
		MsgStop(STR0018 + CRLF + STR0019 ,STR0017) //"Uma ou mais listas de contato dependem dos registros desta campanha."### "Deve existir pelo menos um item cadastrado."###"Atenção"
	EndIf	
EndIf

RestArea(aAreaSU4)
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310VldScript

Valida o conteudo do campo TIPO DE CAMPANHA para validar se 
os SCRIPTS informados estao de acordo com a selecao         
Tipo == ATIVO ou RECEPTIVO. 

@sample		Tk310VldScript()

@param			Nenhum 

@return		ExpL - 	.T. Validado
						.F. Não validado

@author		Vendas CRM
@since			08/05/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Function Tk310VldScript()

Local aArea    	:= GetArea()
Local oModel   	:= FWModelActive() 
Local oSUWDetail	:= oModel:GetModel( 'SUWDETAIL' ) 
Local lRet     	:= .T.											
Local nI       	:= 0
Local cScript		:= ""
	
DbSelectArea("SUZ")
DbSetOrder(1)
	
If nModulo <> 73  // SIGACRM
	For nI := 1 To oSUWDetail:Length()
		cScript := oSUWDetail:GetValue('UW_CODSCRI')
		If !Empty(cScript)
			If DbSeek(xFilial("SUZ") + cScript)
				
	
				//Alem do tipo "AMBOS" o Script tem que ser igual ao escolhido na campanha (ATIVO/RECEPTIVO) 
				If (SUZ->UZ_TIPO <> "3") .AND. (SUZ->UZ_TIPO <> FwFldGet('UO_TIPO'))			// Ambos
					Help(" ", 1, "NAOPERACAO")
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	
	Next nI 
EndIf
RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Ativ

Chama a rotina de atividades. 

@sample 	Tk310Ativ( )

@param		Nenhum 

@return   	lRet - Finalização Wizard

@author	Cristiane Nishizaka
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------

Function Tk310Ativ()

Local lRet	:= .T.

lRet :=  CRMA180( Nil, Nil, Nil, 3, "SUO")    

If lRet
	Processa( { ||  Tk310AOFCommit() },STR0054,STR0055)  // "Aguarde"//"Distribuido Atividades para lista da campanha ..."
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310AOFCommit

Executa o ExecView na tabela AOF (Atividades) para todos os membros da campanha.

@sample 	Tk310AOFCommit()

@param		Nenhum 

@return   	Nenhum

@author	Cristiane Nishizaka
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------

Static Function Tk310AOFCommit()

Local aExecAuto := {}
Local aArea     := GetArea()

Local lProcessa	:= .T.
Local lFirst		:= .T.
Local cChvCamp	:= ""
Local aGetSx2		:= ""
Local cAliasAOG	:= GetNextAlias()
Local aEntAtiv	:= {}
Local nX			:= 0
Local cCamp		:= ""
Local cEmail		:= ""
Local cRemete   	:= ""
Local cBodyPadrao	:= ""
Local cCodRastr	:= ""
Local cCodUSR		:= ""
Local aDadUsr   	:= {}
Local aAnexos   	:= {}

Private lMsErroAuto := .F.
Private aCRM180ANX  := {}

aGetSx2 	:= Tk310AChv("SUO", SUO->UO_CODCAMP)
cChvCamp 	:= aGetSx2[1]
cCamp		:= SUO->UO_CODCAMP

If FWAlertNoYes(STR0056,STR0057) //"Deseja enviar essas atividades a um usuário especifico ?"//"Usuário x Atividade"
	If Conpad1(,,,"AO3")
		cCodUSR := AO3->AO3_CODUSR
	EndIf
EndIf

BeginSql Alias cAliasAOG

	SELECT  AOG.AOG_ENTIDA
			,AOG.AOG_CHAVE
			,AOG.AOG_CHVLST
	FROM	%table:AOG% AOG
	WHERE	AOG.AOG_FILIAL = %xFilial:AOG%
	AND		AOG.AOG_CHVCAM = %Exp:cChvCamp%
	AND		AOG.AOG_TIPCAM = '1'
	AND		AOG.%NotDel% 
	
EndSql

// Retira duplicidade de entidades para evitar que uma entidade receba duas atividades iguais 
DbSelectArea(cAliasAOG)       
(cAliasAOG)->(DbGoTop())

While (cAliasAOG)->(!EOF())
	If aScan(aEntAtiv,{|x| 	x[1] == (cAliasAOG)->AOG_ENTIDA .And.;
							 	x[2] == (cAliasAOG)->AOG_CHAVE } ) == 0
		aAdd(aEntAtiv,{	(cAliasAOG)->AOG_ENTIDA,;
							(cAliasAOG)->AOG_CHAVE,;
							(cAliasAOG)->AOG_CHVLST	})		
	EndIf
	(cAliasAOG)->(DbSkip())
EndDo

If AOF->AOF_TIPO == TPEMAIL // Verificando o tipode de Atividade criada.
	aDadUsr   := CRM170GetS(.T.)// pegando os dados do usuario
	If aDadUsr[3]// verifica se é usuario do CRM
		cRemete := aDadUsr[_PREFIXO][_EndEmail]
	Else
		cRemete := UsrRetMail(RetCodUsr()) 
	EndIf
	If AOF->AOF_ANEXO == "1"
		aAnexos := CRMA180ANX("AOF",XFilial("AOF")+AOF->AOF_CODIGO)
	EndIf
EndIf

For nX := 1 To Len(aEntAtiv)

	If (aEntAtiv[nX][1])->(DbSeek(xFilial(aEntAtiv[nX][1])+Alltrim(aEntAtiv[nX][2])))// posicionando no registro
		 
		 Do Case //Não procesar registros que estão bloqueados por MSBLQL 
			Case aEntAtiv[nX][1] == "SA1"
					lProcessa  := IIF(SA1->A1_MSBLQL == "2", .T., .F.)
			Case aEntAtiv[nX][1] == "SUS"
					lProcessa := IIF(SUS->US_MSBLQL == "2", .T., .F.)
			Case aEntAtiv[nX][1] == "ACH"
					lProcessa := IIF(ACH->ACH_MSBLQL == "2", .T., .F.)
			Case aEntAtiv[nX][1] == "SU5"
					lProcessa := IIF(SU5->U5_MSBLQL == "2", .T., .F.)
		 EndCase

		If lProcessa 
			AAdd(aExecAuto,{"AOF_FILIAL",xFilial("AOF"),Nil})
			If lFirst
				AAdd(aExecAuto,{"AOF_CODIGO", AOF->AOF_CODIGO ,Nil})
				nOper  := 4
				cBodyPadrao := AOF->AOF_DESCRI
				cCodRastr   := AllTrim(SHA1(AOF->AOF_CODIGO)) //codigo rastreavel para imagens no html padrao
			Else 
				nOper  := 3	
			EndIf
			
			Do Case 
				Case AOF->AOF_TIPO == TPTAREFA // Tarefa
						AAdd(aExecAuto,{"AOF_DESCRI",AOF->AOF_DESCRI  ,Nil})
						AAdd(aExecAuto,{"AOF_DTINIC",AOF->AOF_DTINIC  ,Nil})
						AAdd(aExecAuto,{"AOF_HRINIC",AOF->AOF_HRINIC  ,Nil})
						AAdd(aExecAuto,{"AOF_DTFIM" ,AOF->AOF_DTFIM   ,Nil})
						AAdd(aExecAuto,{"AOF_HRFIM" ,AOF->AOF_HRFIM   ,Nil})
						AAdd(aExecAuto,{"AOF_PERCEN",AOF->AOF_PERCEN  ,Nil})
						AAdd(aExecAuto,{"AOF_PRIORI",AOF->AOF_PRIORI  ,Nil})
						AAdd(aExecAuto,{"AOF_HRLEMB",AOF->AOF_HRLEMB  ,Nil})
						AAdd(aExecAuto,{"AOF_HRLEMB",AOF->AOF_HRLEMB  ,Nil})
						AAdd(aExecAuto,{"AOF_STATUS",AOF->AOF_STATUS  ,Nil})
				
				Case AOF->AOF_TIPO == TPCOMPROMISSO // Compromisso
						AAdd(aExecAuto,{"AOF_DESCRI",AOF->AOF_DESCRI  ,Nil})
						AAdd(aExecAuto,{"AOF_PARTIC",AOF->AOF_PARTIC  ,Nil})
						AAdd(aExecAuto,{"AOF_LOCAL" ,AOF->AOF_LOCAL   ,Nil})
						AAdd(aExecAuto,{"AOF_DTINIC",AOF->AOF_DTINIC  ,Nil})
						AAdd(aExecAuto,{"AOF_HRINIC",AOF->AOF_HRINIC  ,Nil})
						AAdd(aExecAuto,{"AOF_DTFIM" ,AOF->AOF_DTFIM   ,Nil})
						AAdd(aExecAuto,{"AOF_HRFIM" ,AOF->AOF_HRFIM   ,Nil})
						AAdd(aExecAuto,{"AOF_PERCEN",AOF->AOF_PERCEN  ,Nil})
						AAdd(aExecAuto,{"AOF_PRIORI",AOF->AOF_PRIORI  ,Nil})
						AAdd(aExecAuto,{"AOF_STATUS",AOF->AOF_STATUS  ,Nil})
			
				Case AOF->AOF_TIPO == TPEMAIL // E-mail
		
						cEmail		:= Tk310Email(aEntAtiv[nX][1],aEntAtiv[nX][2])
						AAdd(aExecAuto,{"AOF_DESCRI",CRM170MEEM(cBodyPadrao,"SUO"),Nil})		
						AAdd(aExecAuto,{"AOF_DESTIN",cEmail           ,Nil})
						AAdd(aExecAuto,{"AOF_REMETE",cRemete          ,Nil})
						AAdd(aExecAuto,{"AOF_PARTIC",AOF->AOF_PARTIC  ,Nil})
						AAdd(aExecAuto,{"AOF_STATUS",STPENDENTE       ,Nil})
						
			EndCase
			If !Empty(cCodUSR)
				AAdd(aExecAuto,{"AOF_CODUSR",cCodUSR			,Nil})
			EndIf
			AAdd(aExecAuto,{"AOF_CHVCAM",cChvCamp				,Nil})
			AAdd(aExecAuto,{"AOF_CODCAM",cCamp					,Nil})
			AAdd(aExecAuto,{"AOF_TIPCAM","SUO"	 				,Nil})	
			AAdd(aExecAuto,{"AOF_TIPO"  , AOF->AOF_TIPO      ,Nil})
			AAdd(aExecAuto,{"AOF_ASSUNT", AOF->AOF_ASSUNT    ,Nil})
			AAdd(aExecAuto,{"AOF_ENTIDA", aEntAtiv[nX][1]		,Nil})
			AAdd(aExecAuto,{"AOF_CHAVE" , aEntAtiv[nX][2]		,Nil})
			
			CRMA180( aExecAuto, nOper, .T., Nil, Nil , aAnexos,,,, cCodRastr)// Importar agenda por rotina automatica
		
			lFirst := .F.
			Asize( aExecAuto, 0)
		EndIF	 	
	EndIf	
Next nX

aCRM180ANX := Nil

(cAliasAOG)->(DBCloseArea()) 
RestArea(aArea)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Email

Obtem o e-mail da entidade.

@sample		Tk310Email(cEntida, cChave)

@param			cEntida 	- Alias da entidade
				cChave		- Chave da entidade
				
@return		cRet		- Email

@author	Cristiane Nishizaka
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------

Static Function Tk310Email(cEntida, cChave)

Local cRet		:= ""
Local cPrefix	:= ""

cPrefix := Iif( Subs( cEntida, 1, 1 ) == "S", Subs( cEntida, 2,3 ), cEntida )

DbSelectArea(cEntida)
(cEntida)->(DbSetOrder(1))

If (cEntida)->(DbSeek(xFilial(cEntida)+AllTrim(cChave)))	
	cRet	:= (cEntida)->&(cPrefix+"_EMAIL")	
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310F3SUO

Monta uma consulta do tipo F3 ESPECIFICA  para a consulta de
campanhas (SUO) para todo acesso no Protheus . 

@sample		Tk310F3SUO()

@param			Nenhum

@return		ExpL - 	.T. Retorna consulta
						.F. Não retorna consulta

@author		Vendas CRM
@since			08/05/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Function Tk310F3SUO()

Local oDlgCons										// Tela
Local oListBox                                      // Listbox com as opcoes
Local nPosLbx     := 0								// Posicao do Listbox
Local aItens      := {}								// Array dos itens
Local nPos        := 0								// Contador
Local lRet        := .F.							// Retorno da funcao
Local cFuncao	  := ALLTRIM(UPPER(FunName()))		// Nome da funcao


//Cadastro de Campanha
//1 - Receptivo       
//2 - Ativo           

CursorWait()

DbSelectArea("SUO")
DbSetOrder(1)
DbSeek(xFilial("SUO"))
While (!Eof()) .AND. (SUO->UO_FILIAL == xFilial("SUO"))
	If SUO->UO_ATENDIM <> '5' // Tipo de Atendimento 5=Marketing
		Do Case
			Case cFuncao == "TMKA120"
				
				//NAO CARREGA - Se o tipo de campanha for diferente da operacao na configuracao de TMK 
				IF SUO->UO_TIPO <> M->UE_OPERACA
				
					SUO->(DbSkip())
					Loop
				Endif
				
			Case cFuncao == "VEIVA500"
				
				//NAO CARREGA - Se no modulo de veiculos nao for uma operacao de ATIVO 
				If VAL(SUO->UO_TIPO) <> ATIVO
					SUO->(DbSkip())
					Loop
				Endif
				
			Case cFuncao == "TMKA271"
				
				//Verifica a validade da campanha, caso as dastas estejam preenchidas.
				If (!Empty(SUO->UO_DTINI) .AND. dDatabase < SUO->UO_DTINI) .OR. (!Empty(SUO->UO_DTFIM) .AND. dDatabase > SUO->UO_DTFIM)
					SUO->(DbSkip())
					Loop
				EndIf
				
				If TkGetTipoAte() $ "45"	// Se for TODOS ou TMK x TLV
					
					If nFolder == 1			// Se for TELEMARKETING
						
						//1) Avalia se o atendimento da campanha e para Televendas ou Todos  
						If !SUO->UO_ATENDIMEN $ "14"
							SUO->(DbSkip())
							Loop
						Endif
						
						//NAO CARREGA - Se o tipo de campanha for diferente da operacao no Telemarketing       
						If SUO->UO_TIPO <> M->UC_OPERACA
							SUO->(DbSkip())
							Loop
						Endif
						
					ElseIf nFolder == 2		// Se o folder for TELEVENDAS
						
						//Operacado do Televendas - UA_TMK 
						//1=Receptivo                      
						//2=Ativo                          
						//3=Fax                            
						//4=Representante                  
						
						//1) Avalia se o atendimento da campanha e para Televendas ou Todos  
						If !(SUO->UO_ATENDIMEN $ "24")
							SUO->(DbSkip())
							Loop
						Endif
						
						If M->UA_TMK <> "3" .AND. M->UA_TMK <> "4"
							If SUO->UO_TIPO <> M->UA_TMK
								SUO->(DbSkip())
								Loop
							Endif
						Endif
						
						If M->UA_TMK == "3" .OR. M->UA_TMK == "4"   // Fax e Representante sao operacoes de RECEPTIVO
							If VAL(SUO->UO_TIPO) <> RECEPTIVO
								SUO->(DbSkip())
								Loop
							Endif
						Endif
						
					ElseIf nFolder == 3			// Se o folder for TELECOBRANCA
						
						//1) Avalia se o atendimento da campanha e para Telecobranca ou Todos  
						If !(SUO->UO_ATENDIMEN $ "34")
							SUO->(DbSkip())
							Loop
						Endif
						
						//NAO CARREGA - Se o tipo de campanha for diferente da operacao no Telecobranca 
						If SUO->UO_TIPO <> M->ACF_OPERA
							SUO->(DbSkip())
							Loop
						Endif
						
					Endif
					
				ElseIf TkGetTipoAte() == "1"	// Se for somente o telemarketing
					//1) Avalia se o atendimento da campanha e para Televendas ou Todos  
					If !SUO->UO_ATENDIMEN $ "14"
						SUO->(DbSkip())
						Loop
					Endif
					
					//NAO CARREGA - Se o tipo de campanha for diferente da operacao no Telemarketing   
					If SUO->UO_TIPO <> M->UC_OPERACA
						SUO->(DbSkip())
						Loop
					Endif
					
				ElseIf TkGetTipoAte() == "2"  // Se for somente o televendas
					
					//Operacado do Televendas - UA_TMK 
					//1=Receptivo                      
					//2=Ativo                          
					//3=Fax                            
					//4=Representante                  
					
					//1) Avalia se o atendimento da campanha e para Televendas ou Todos  
					If !(SUO->UO_ATENDIMEN $ "24")
						SUO->(DbSkip())
						Loop
					Endif
					
					//Se o atendimento de televendas NAO for de FAX ou Representante valida pela operacao 
					If M->UA_TMK <> "3" .AND. M->UA_TMK <> "4"
						If SUO->UO_TIPO <> M->UA_TMK
							SUO->(DbSkip())
							Loop
						Endif
					Endif
					
					//Se o atendimento de televendas for de FAX ou Representante valida pela operacao RECEPTIVO 
					If M->UA_TMK == "3" .OR. M->UA_TMK == "4"   // Fax e Representante sao operacoes de RECEPTIVO
						If VAL(SUO->UO_TIPO) <> RECEPTIVO
							SUO->(DbSkip())
							Loop
						Endif
					Endif
					
				ElseIf TkGetTipoAte() == "3"		// Se for somente o Telecobranca
					//1) Avalia se o atendimento da campanha e para Telecobranca ou Todos  
					If !(SUO->UO_ATENDIMEN $ "34")
						SUO->(DbSkip())
						Loop
					Endif
					
					//NAO CARREGA - Se o tipo de campanha for diferente da operacao no Telecobranca 
					If SUO->UO_TIPO <> M->ACF_OPERA
						SUO->(DbSkip())
						Loop
					Endif
				Endif
				
			Case cFuncao == "TMKA280"		// Pre-atendimento ATIVO de Telecobranca
	
				//Verifica a validade da campanha
				If (dDatabase < SUO->UO_DTINI) .OR. (dDatabase > SUO->UO_DTFIM)
					SUO->(DbSkip())
					Loop
				EndIf
				
				If SUO->UO_TIPO <> M->ACF_OPERA
					SUO->(DbSkip())
					Loop
				Endif
				
			Case cFuncao == "TMKA061"
				
				//NAO CARREGA - Se a campanha nao for ATIVA - Lista de contatos 
				If VAL(SUO->UO_TIPO) <> ATIVO
					SUO->(DbSkip())
					Loop
				Endif
				
			Case cFuncao == "TMKA062" // Lista de Cobranca
				
				//1) NAO CARREGA - se a campanha nao for para Telecobranca ou Todos - Atendimentos
				If !(SUO->UO_ATENDIM $ "34"	)
					SUO->(DbSkip())
					Loop
				Endif
				
				//2) NAO CARREGA - Se nao for uma campanha para atendimento ATIVO - Lista de Inadimplentes 
				If VAL(SUO->UO_TIPO) <> ATIVO
					SUO->(DbSkip())
					Loop
				Endif
				
			Case cFuncao == "TMKA510A" // Help Desk
	
				//1) Avalia se o atendimento da campanha e para Todos  
				If !SUO->UO_ATENDIMEN $ "14"
					SUO->(DbSkip())
					Loop
				Endif
				
				//NAO CARREGA - Se o tipo de campanha for diferente da operacao no Atendimento         
				If SUO->UO_TIPO <> M->ADE_OPERAC
					SUO->(DbSkip())
					Loop
				Endif		
	
		Endcase
	
		//Carregas as campanhas validas - consideranto a rotina e o tipo de atendimento (Ativo/Receptivo)
		AAdd(aItens, {SUO->UO_CODCAMP, SUO->UO_DESC} )
	Else
		If cFuncao <> "CRMA370"
			SUO->(DbSkip())
			Loop
		EndIf
		
		AAdd(aItens, {SUO->UO_CODCAMP, SUO->UO_DESC} )
		
	EndIf	
	
	SUO->(DbSkip())
End
              
CursorArrow()

If Len(aItens) <= 0 
	//Help(" ", 1, "TMK_TPOPER")
	MsgStop(STR0016,STR0017) //"Não existem campanhas criadas para o tipo de atendimento definido nessa rotina"###"Atenção"
	Return(lRet)
Endif

DEFINE MSDIALOG oDlgCons FROM 0,0 TO 230,440 TITLE STR0013 PIXEL	// "Consulta de campanhas"

	@ 05,05 LISTBOX oListBox VAR nPosLbx FIELDS HEADER STR0014, STR0015 SIZE 180,100 OF oDlgCons PIXEL NOSCROLL	// "Codigo", "Descricao"
	oListBox:SetArray(aItens)
    oListBox:bLine:={|| {	aItens[oListBox:nAt,1],;
						   	aItens[oListBox:nAt,2]  }}

    oListBox:BlDblClick := {||(lRet:= .T.,nPos:= oListBox:nAt, oDlgCons:End())}
	oListBox:Refresh()
                                       
    DEFINE SBUTTON FROM 05,190 TYPE 1  ENABLE OF oDlgCons ACTION (lRet:= .T.,nPos:= oListBox:nAt,oDlgCons:End())

    DEFINE SBUTTON FROM 20,190 TYPE 2  ENABLE OF oDlgCons ACTION (lRet:= .F.,oDlgCons:End())
    
  	DEFINE SBUTTON FROM 35,190 TYPE 15 ENABLE OF oDlgCons ACTION (TK061VISCAD(aITens[oListBox:nAt,1],1))

ACTIVATE MSDIALOG oDlgCons CENTERED

If lRet
   DbSelectArea("SUO")
   DbSetOrder(1)
   DbSeek(xFilial("SUO") + aItens[nPos][1])
Endif

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Cmt

Bloco de Commit. 

@sample		Tk310Cmt(oModel)

@param			oModel 		Objeto do modelo 

@return		lRet		.T.

@author	Cristiane Nishizaka
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------

Static Function Tk310Cmt( oModel )

Local aArea       := GetArea()                             
Local aAreaAO4    := AO4->(GetArea())
Local lRet        := .T.                   
Local nOpc        := oModel:GetOperation()   
Local aExecAuto   := {}
Local aNvlEstrut  := {}
Local cChave      := "" 
Local cAliasAOG   := GetNextAlias()
Local cChvCamp    := ""
Local aGetSx2     := ""
Local lContinua   := .T.

If nOpc == MODEL_OPERATION_DELETE

	aGetSx2 	:= Tk310AChv("SUO", SUO->UO_CODCAMP)
	cChvCamp 	:= aGetSx2[1]

	BeginSql Alias cAliasAOG
	
		SELECT  AOG.AOG_ENTIDA
				,AOG.AOG_CHAVE
				,AOG.AOG_CHVLST
		FROM	%table:AOG% AOG
		WHERE	AOG.AOG_FILIAL = %xFilial:AOG%
		AND		AOG.AOG_CHVCAM = %Exp:cChvCamp%
		AND		AOG.AOG_TIPCAM = '1'
		AND		AOG.%NotDel% 
		
	EndSql
	
	DbSelectArea("AOG")
	AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
	
	While (cAliasAOG)->(!EOF())
		If AOG->(DbSeek(xFilial("AOG")+(cAliasAOG)->AOG_CHVLST+(cAliasAOG)->AOG_CHAVE+cChvCamp+"1"))
			RecLock("AOG",.F.)
				DbDelete()
			AOG->(MsUnlock())
		EndIf
		(cAliasAOG)->(DbSkip())
	End		
	
	(cAliasAOG)->(DBCloseArea()) 
	
EndIf

If nOpc == MODEL_OPERATION_DELETE
	// Exclusão de Anotações    	                                                                        
	If nModulo == 73
		CRMA090Del( "SUO", SUO->( Recno() ) )
	EndIf	
	
EndIf

RestArea( aAreaAO4 )
RestArea( aArea )

FWFormCommit(oModel,Nil,{ |oModel,cId, cAlias| Tk310CmtAft(oModel,cId,cAlias) })

Return( lRet )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk310CmtAft

Bloco de transacao durante o commit do model. 

@sample	Tk310CmtAft(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function Tk310CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local lRetorno 	:= .T.
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cId == "SUOMASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	cChave 	:= PadR(xFilial("SUO")+oModel:GetValue("UO_CODCAMP"),TAMSX3("AO4_CHVREG")[1]) 
	aAutoAO4	:= CRMA200PAut(nOperation,"SUO",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf 

Return(lRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Inc

Inclusão do cadastro. 

@sample		Tk310Inc()

@param			Nenhum

@return		Nenhum

@author		Vendas CRM
@since			27/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Function Tk310Inc()

Local oModel     	:= Nil 
Local oView      	:= Nil
Local aSize     	:= FWGetDialogSize( oMainWnd ) 
Local dDataAtu	:= dDataBase
Local dHoraAtu	:= Time()

oModel := FWLoadModel("TMKA310")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
//Passa a data e hora de cadastro da campanha
oModel:GetModel("SUOMASTER"):SetValue("UO_DTINS", dDataAtu)
oModel:GetModel("SUOMASTER"):SetValue("UO_HRINS", SubStr(dHoraAtu,1,5))
oView := FWLoadView("TMKA310")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT) 
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
            
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0004) // "Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Alt

Alteração do cadastro. 

@sample		Tk310Alt()

@param			Nenhum

@return		Nenhum

@author		Vendas CRM
@since			27/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Function Tk310Alt()

Local oModel     	:= Nil 
Local oView      	:= Nil
Local aSize     	:= FWGetDialogSize( oMainWnd ) 

oModel := FWLoadModel("TMKA310")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

If (cPaisLoc != "RUS" .or.  X3Usado('UO_MSBLQL')) .and. SUO->UO_MSBLQL == "1"

	Help("",1,"HELP",,STR0037,1) // "Esta Campanha não pode ser alterada pois está inativa."	
	oModel:DeActivate()
	
Else

oView := FWLoadView("TMKA310")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_UPDATE) 
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
            
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0005) // "Alterar"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310FltScript

Trata o filtro da consulta padrão SUZ de acordo com o módulo. 

@sample		Tk310FltScript()

@param		Nenhum 

@return		ExpC - 	Filtro

@author	Cristiane Nishizaka
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------

Function Tk310FltScript()

Local lRet := .T.											

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310RetCBox

Trata as opções do campo de acordo com o módulo. 

@sample		Tk310RetCBox()

@param			Nenhum 

@return		ExpC - 	Filtro

@author		Cristiane Nishizaka
@since			14/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310RetCBox()

Local cRet     := ""											

If nModulo <> 73
	cRet := STR0038 // "1=Telemarketing;2=Televendas;3=Telecobranca;4=Todos"
Else
	cRet := STR0039 // "5=Marketing"                                                                                                                                                              
EndIf

Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310VldCamp

Valida o código de campanha de acordo com o módulo. 

@sample		Tk310VldCamp(cCodCamp)

@param			cCodCamp		Código da campanha 

@return		ExpC - 	Filtro

@author		Cristiane Nishizaka
@since			14/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310VldCamp(cCodCamp)

Local lRet     	:= .T.											
Local cFuncao	  := ALLTRIM(UPPER(FunName()))		// Nome da funcao

DbSelectArea('SUO')
DbSetOrder(1)

If SUO->(DbSeek(xFilial('SUO')+AllTrim(cCodCamp)))
	If SUO->UO_ATENDIM == '5' .And. cFuncao <> "CRMA370"
		Help("",1,"HELP",,STR0040,1) // "Campanha inválida para o tipo de atendimento definido nessa rotina."
		lRet	:= .F.
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310LstMk

Chama a rotina de Adicionar Lista de Marketing. 

@sample		Tk310LstMk()

@param			Nenhum 

@return		Nenhum

@author		Cristiane Nishizaka
@since			14/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310LstMk()
	TMKA310A('SUO', SUO->( Recno() ))
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310Memb

Chama a rotina de Visualizar membros da campanha. 

@sample		Tk310Memb()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			14/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310Memb()	
	If IsInCallStack("TMKA310") 
		TMKA130B('SUO', SUO->( Recno() ))
	ElseIf IsInCallStack("CRMA250") 
		TMKA130B('AOC', AOC->( Recno() ))
	EndIf	
Return

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
