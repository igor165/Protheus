#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA099.CH"

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TAFA099
Rotina responsável por agrupar todas as tabelas dinâmicas do Sistema

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//------------------------------------------------------------------------------
Function TAFA099()
Local oMBrowse		
Local oTableAtt 
Local nX			
Local aCores  		

If TAFAlsInDic( "T2U" )

	oTableAtt	:=	TableAttDef()
	aCores		:=	{	{ "T2U->T2U_ESCOPO == '1'"	, "BR_AZUL"		, STR0001 } ,;	//'Tabelas dinâmicas do escopo Fiscal'
						{ "T2U->T2U_ESCOPO == '2'"	, "BR_VERMELHO"	, STR0002 } ,;	//'Tabelas dinâmicas do escopo eSocial'
						{ "T2U->T2U_ESCOPO == '3'"	, "BR_VERDE"	, STR0003 },;		//'Tabelas dinâmicas do escopo Contábil'
						{ "T2U->T2U_ESCOPO == '4'"	, "BR_AMARELO"	, STR0004 } }		//'Tabelas dinâmicas do escopo Reinf'

	//----------------
	// Cria o Browse 
	//----------------
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetMenuDef( 'TAFA099' )
	oMBrowse:SetAlias( "T2U" )
	oMBrowse:SetDescription( STR0004 )	//"Tabelas dinâmicas"
	For nX := 1 To Len( aCores )
		oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
	Next nX

	oMBrowse:SetAttach( .T. )

	If oTableAtt <> Nil
		oMBrowse:SetViewsDefault( oTableAtt:aViews )
		oMBrowse:SetChartsDefault( oTableAtt:aCharts )

		oMBrowse:SetIDChartDefault( "PorEsc" )
	EndIf
	//oMBrowse:SetOpenChart( .F. )
	//oMBrowse:SetChgAll(.F.)	
	//oMBrowse:SetSeeAll(.F.)

	oMBrowse:DisableDetails(.F.)
	oMBrowse:SetTotalDefault('T2U_FILIAL','COUNT',STR0005)	//'Total de Registros'
	oMBrowse:Activate()	
Else
	TAFAviso( STR0013, TafAmbInvMsg(), { STR0014 } ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()
//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef
Cria as visões e gráficos.

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()
Local oFiscal		
Local oeSocial	
Local oContabil	
Local oReinf		
Local oPorEscopo	
Local oTableAtt 	

oTableAtt			:= 	FWTableAtt():New()

oTableAtt:SetAlias("T2U")

//------------
// Visões
//------------
oFiscal := FWDSView():New()
oFiscal:SetName(STR0006)	//"Exibir Escopo Fiscal"
oFiscal:SetID("Fiscal") 
oFiscal:SetOrder(1)
oFiscal:SetCollumns({"T2U_CODIGO","T2U_DESCRI","T2U_VERSAO"})
oFiscal:SetPublic( .T. )
oFiscal:AddFilter(STR0006, "T2U_ESCOPO = '1'")
oTableAtt:AddView(oFiscal)

oeSocial := FWDSView():New()
oeSocial:SetName(STR0007)	//"Exibir Escopo eSocial"
oeSocial:SetID("eSocial") 
oeSocial:SetOrder(1)
oeSocial:SetCollumns({"T2U_CODIGO","T2U_DESCRI","T2U_VERSAO"})
oeSocial:SetPublic( .T. )
oeSocial:AddFilter(STR0007, "T2U_ESCOPO = '2'")
oTableAtt:AddView(oeSocial)

oContabil := FWDSView():New()
oContabil:SetName(STR0008)	//"Exibir Escopo Contábil"
oContabil:SetID("Contabil") 
oContabil:SetOrder(1)
oContabil:SetCollumns({"T2U_CODIGO","T2U_DESCRI","T2U_VERSAO"})
oContabil:SetPublic( .T. )
oContabil:AddFilter(STR0008, "T2U_ESCOPO = '3'")
oTableAtt:AddView(oContabil)

oReinf := FWDSView():New()
oReinf:SetName(STR0015)	//"Exibir Escopo Reinf"
oReinf:SetID("Rienf") 
oReinf:SetOrder(1)
oReinf:SetCollumns({"T2U_CODIGO","T2U_DESCRI","T2U_VERSAO"})
oReinf:SetPublic( .T. )
oReinf:AddFilter(STR0015, "T2U_ESCOPO = '4'")
oTableAtt:AddView(oReinf)

//------------
// Gráficos
//------------	
// Pizza:
oPorEscopo := FWDSChart():New()
oPorEscopo:SetName(STR0009) //"Tabelas por escopo"
oPorEscopo:SetTitle(STR0009) //"Tabelas por escopo"
oPorEscopo:SetID("PorEsc") 
oPorEscopo:SetType("PIECHART")
oPorEscopo:SetSeries({ {"T2U", "T2U_CODIGO", "COUNT"} })
oPorEscopo:SetCategory( { {"T2U", "T2U_ESCOPO"} } )
oPorEscopo:SetPublic( .T. )
oPorEscopo:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorEscopo:SetTitleAlign( CONTROL_ALIGN_CENTER ) 		

oTableAtt:AddChart(oPorEscopo)

Return (oTableAtt)
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Funcao generica MVC com as opcoes de menu

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	

aRotina	:=	{}

ADD OPTION aRotina Title STR0010 Action "T099OpTDin()" OPERATION 4 ACCESS 0 //"Abrir Browse"

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT2U 	
Local oModel 	

oStruT2U 		:= 	FWFormStruct( 1, 'T2U' )
oModel 			:= 	MPFormModel():New( 'TAFA099' )

oModel:AddFields('MODEL_T2U', /*cOwner*/, oStruT2U)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		
Local 	oStruT2U 	
Local 	oView 		

oModel 				:= 	FWLoadModel( 'TAFA099' )
oStruT2U		 	:= 	FWFormStruct( 2, 'T2U' )
oView 				:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T2U', oStruT2U, 'MODEL_T2U' )

oView:EnableTitleView( 'VIEW_T2U', STR0011 )	//'Cadastro de Tabelas Dinâmicas'
oView:CreateHorizontalBox( 'FIELDST2U', 100 )
oView:SetOwnerView( 'VIEW_T2U', 'FIELDST2U' )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} OpenTblDin
Funcao utilizada para abrir o Browse da linha marcada, utilizando a rotina owner cadastrado no SX2.

@return Chamada de um alerta ou da função owner da tabela

@author Gustavo G. Rueda
@since 05/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function T099OpTDin(cfunc)

If cfunc==Nil .Or. Empty(cfunc)
	cfunc	:=	AllTrim(T2U->T2U_ROTINA)
EndIf

If Empty(cfunc)
	Return MsgAlert(STR0012,)	//'Rotina de consulta Cadastral inválida, entrar em contato com o Administrador do sistema.'
Else	
	Return &cFunc.()
EndIf
//-------------------------------------------------------------------
/*/{Protheus.doc} T099GrvTbl

Rotina para carga e atualização da tabela autocontida referencia para todas as outras tabelas dinamicas.

@Param		cAliasTbl	-	Versão corrente na empresa
			nVerAtu		-	Versão atual ( passado como referência )

@Return	Nil

@Author	Gustavo G. Rueda
@Since		05/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function T099GrvTbl(cAliasTbl as character, cRotina as character, nVerAtu as numeric)

	Local cEscopo 		as character

	Default cAliasTbl 	:= ""
	Default cRotina 	:= ""
	Default nVerAtu 	:= 0

	cEscopo	:= ""

	Do Case
		Case cAliasTbl $ "CFM|CAH|CFU|CH0|CGN|CW4|CW9|CFL|CW6|CH6|CZT|CZS|CZV|CZU|CH8|CHA|CHI|CHJ|CHK|T26|V1P|V3K|V6T"
			cEscopo	:= "3"	//Contabil

		Case  cAliasTbl $ "CMM|C87|C88|C89|C8A|C8C|C8D|C8E|C8F|C8G|C8H|C8I|C8J|C8K|C8L|C8M|C8N|C8O|CML|C8P|C8T|C8U|C8Z|" +;
							"C8S|CMH|CMI|CUC|CUB|CMY|CUD|CUE|CUF|T12|CUN|CUR|CUV|T13|C88|CUA|CUM|CUQ|C94|C95|C96|C97|C98|" +;
							"T3E|LE7|T5G|T5H|LE5|V2K|V2L|V2M|V26|V27|V28|V29|V5O|V5Z|V5Y|V6Z|V9H|V9T"
			cEscopo	:= "2"	//eSocial

		Case cAliasTbl $ "T9A|T9B|V3O|V3Q|V4E"
			cEscopo	:= "4"	//Reinf

		Otherwise
			cEscopo	:= "1"	//Fiscal
			
	EndCase

	If TAFAlsInDic(cAliasTbl)
		T2U->(DBSetOrder(2))

		If T2U->( MsSeek( xFilial( "T2U" ) + cAliasTbl ) )
			If RecLock( "T2U", .F. )
				T2U->T2U_VERSAO := AllTrim( Str( nVerAtu ) )
				T2U->( MsUnLockAll() )
				T2U->( DBCommit() )
			EndIf
		Else
			RecLock("T2U",.T.)
			T2U->T2U_FILIAL	:=	xFilial("T2U")	
			T2U->T2U_ID		:=	TAFGeraID()
			T2U->T2U_ESCOPO	:=	cEscopo		//1=Fiscal, 2=eSocial, 3=Contábil, 4=Reinf
			T2U->T2U_CODIGO	:=	cAliasTbl
			T2U->T2U_DESCRI	:=	Upper(AllTrim(X2nome()))	
			T2U->T2U_ROTINA	:=	cRotina
			T2U->T2U_VERSAO	:=	AllTrim(Str(nVerAtu))		
			T2U->(MsUnLockAll())
			T2U->(dbCommit())
		EndIf
	EndIf

Return

Function CheckT2U(nVerAtu, cAliasAut, nVerT2U, cRotina)

Local lRet := .F.
Local aData := {}

Default nVerT2U := 1000
Default cRotina := ""

dbSelectArea('T2U')
dbSetOrder(2)
dbSelectArea("SX2")

If SX2->( MsSeek( cAliasAut ) )
	If T2U->( MsSeek( xFilial( "T2U" ) + cAliasAut ) )
        If Val(T2U->T2U_VERSAO) == nVerAtu
            lRet := .T.
		EndIf 
        
		nVerT2U := Val(T2U->T2U_VERSAO)
	Else
		T099GrvTbl( cAliasAut, cRotina, 1000 )
	EndIf
Else

	aData := GetApoInfo(cRotina + ".PRW")

	//Só gerar Erro para o Usuário se ele estiver com o TAFROTINAS + FONTE da autocontida compilado no RPO e se o Alias da tabela não existir no SX2.
	If len(aData) > 0
		TafConOut("["+STR0016+"] - " + STR0017 + " " + cAliasAut + " " +  ANSIToOEM(STR0018) + " " + cRotina + " " + ANSIToOEM(STR0019+".") + CRLF,2)  //# "AUTOCONTIDAS" # "A tabela" # "não existe no SX2 e a rotina" # "está compilada no RPO" 
		Final( "["+STR0016+"] " +STR0020+ "!", STR0021 + " " + cRotina + " " + STR0022 + " " + cAliasAut + " " + STR0023) 
		//# "AUTOCONTIDAS" # "Ambiente Desatualizado" # "O ambiente do TAF encontra-se desatualizado, a rotina" #  "está compilada no RPO porém a tabela" # "não existe no dicionário de dados, é necessário executar o compatibilizador de dicionário de dados UPDDISTR disponível no portal do cliente do TAF."  
	Else 
		TafConOut(STR0017 + " " + STR0024 + " " + cAliasAut + " " + ANSIToOEM(STR0025) + " (" + STR0026 + " " + cRotina + ") " + ANSIToOEM(STR0027) + CRLF,1) //#"A tabela autocontida " # não está compilada # Fonte # e não existe no dicionário de dados SX2, porém está relacionada no fonte TAFROTINAS.
		lRet := .T.
	EndIf 
EndIf

Return lRet 
