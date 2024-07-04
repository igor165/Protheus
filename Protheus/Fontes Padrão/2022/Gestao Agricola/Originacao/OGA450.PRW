#INCLUDE "OGA450.ch"
#include "protheus.ch"
#INCLUDE "PRCONST.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "SIGAWIN.CH"

Static __lnewNeg		:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/** {Protheus.doc} OGA450
Tela de gestor de entidade.

@param: 	pcCodEnt - Código da entidade
@param: 	pcLojEnt - Loja da entidade
@author: 	Marlon Richard Trettin
@since: 	17/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA450( pcCodEnt, pcLojEnt)

	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer   := Nil
	Local oPnEnt	 := Nil
	Local oPnSld	 := Nil
	Local oPnCtr	 := Nil
	Local nX         := 0
	Local oBtnAtual
    Local oNomEnt := NIL
	Local oNomLoj := NIL
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias

	//--- Definição da estrutura da tabela temporária de Saldos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruSld := { { "S_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" )	, PesqPict("NJR","NJR_FILIAL") },;
	{ "S_TIPO",	"C", TamSX3( "NJR_TIPO" )[ 1 ]	, 0 , RetTitle( "NJR_TIPO" )		, "@" },;
	{ "S_DESTIP", "C", 20 							, 0 , RetTitle( "NJR_TIPO" )		, "@" },;
	{ "S_LOJA",	"C", TamSX3( "NJR_LOJENT" )[ 1 ], 0 , RetTitle( "NJR_LOJENT" )	, "@" },;
	{ "S_CODSAF", "C", TamSX3( "NJR_CODSAF" )[ 1 ], 0 , RetTitle( "NJR_CODSAF" )	, PesqPict("NJR","NJR_CODSAF") },;
	{ "S_CODPRO", "C", TamSX3( "NJR_CODPRO" )[ 1 ], 0 , RetTitle( "NJR_CODPRO" )	, PesqPict("NJR","NJR_CODPRO") },;
	{ "S_DESPRO", "C", TamSX3( "NJR_DESPRO" )[ 1 ], 0 , RetTitle( "NJR_DESPRO" )	, PesqPict("NJR","NJR_DESPRO") },;
	{ "S_UM1PRO", "C", TamSX3( "NJR_UM1PRO" )[ 1 ], 0 , RetTitle( "NJR_UM1PRO" )	, PesqPict("NJR","NJR_UM1PRO") },;
	{ "S_QTDCTR", "N", 19, 2 , RetTitle( "NJR_QTDCTR" ),	"@E 999,999,999,999" },;
	{ "S_QTDFIX", "N", 19, 2 , RetTitle( "NN8_QTDFIX" ),	"@E 999,999,999,999" },;
	{ "S_QTENFX", "N", 19, 2 , STR0016					  ,	"@E 999,999,999,999" },; //Qtd. Ent. Fix.
	{ "S_QTDAFX", "N", 19, 2 , STR0007					  ,	"@E 999,999,999,999" },; // Qtd. a Fixar
	{ "S_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999" },;
	{ "S_SLDFIS", "N", 19, 2 , RetTitle( "NJR_SLDFIS" ),	"@E 999,999,999,999" },;
	{ "S_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999" },;
	{ "S_QTEFIS", "N", 19, 2 , RetTitle( "NJR_QTEFIS" ),	"@E 999,999,999,999" },;
	{ "S_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999" },;
	{ "S_QTSFIS", "N", 19, 2 , RetTitle( "NJR_QTSFIS" ),	"@E 999,999,999,999" },;
	{ "S_DIFFIS", "N", 19, 2 , STR0008                 ,	"@E 999,999,999,999" },; // Dif. Fiscal	
    { "S_QTDRES", "N", 19, 2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999" },;
	{ "S_QTDROM", "N", 19, 2 , STR0071                 ,    "@E 999,999,999,999" },; //"Qtd.Rom.Pend." 
    { "S_QTDTRF", "N", 19, 2 , STR0004                 ,	"@E 999,999,999,999" } }

	Local aCpBrwSld := {}
	Local aIndSld := { "S_FILIAL+S_TIPO+S_LOJA+S_CODSAF+S_CODPRO+S_UM1PRO", "S_FILIAL+S_LOJA+S_TIPO+S_CODSAF+S_CODPRO" } // Definição dos índices

	//--- Definição da estrutura da tabela temporária de Contratos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruCtr := { { "C_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "C_MODELO", "C", TamSX3( "NJR_MODELO" )[ 1 ], 0 , RetTitle( "NJR_MODELO" ), PesqPict("NJR","NJR_MODELO") },;
	{ "C_STATUS", "C", TamSX3( "NJR_STATUS" )[ 1 ], 0 , RetTitle( "NJR_STATUS" ), PesqPict("NJR","NJR_STATUS") },;
	{ "C_CODCTR", "C", TamSX3( "NJR_CODCTR" )[ 1 ], 0 , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
	{ "C_DESCRI", "C", TamSX3( "NJR_DESCRI" )[ 1 ], 0 , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
	{ "C_DATA",	"D", 8 , 0 , RetTitle( "NJR_DATA" ), 	"@D" },;
	{ "C_DATINI", "D", 8 , 0 , RetTitle( "NNY_DATINI" ),	"@D" },;
	{ "C_DATFIM", "D", 8 , 0 , RetTitle( "NNY_DATFIM" ),	"@D" },;
	{ "C_QTDCTR", "N", 19, 2 , RetTitle( "NJR_QTDCTR" ),	"@E 999,999,999,999" },;
	{ "C_QTDFIX", "N", 19, 2 , RetTitle( "NN8_QTDFIX" ),	"@E 999,999,999,999" },;
	{ "C_QTENFX", "N", 19, 2 , STR0016                 ,	"@E 999,999,999,999" },; //Qtd. Ent. Fix.
	{ "C_QTDAFX", "N", 19, 2 , STR0007                 ,	"@E 999,999,999,999" },; // Qtd. a Fixar
	{ "C_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999" },;
	{ "C_SLDFIS", "N", 19, 2 , RetTitle( "NJR_SLDFIS" ),	"@E 999,999,999,999" },;
	{ "C_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999" },;
	{ "C_QTEFIS", "N", 19, 2 , RetTitle( "NJR_QTEFIS" ),	"@E 999,999,999,999" },;
	{ "C_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999" },;
	{ "C_QTSFIS", "N", 19, 2 , RetTitle( "NJR_QTSFIS" ),	"@E 999,999,999,999" },;
	{ "C_DIFFIS", "N", 19, 2 , STR0008                 ,	"@E 999,999,999,999" },; // Dif. Fiscal
	{ "C_QTDRES", "N", 19, 2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999" },;
	{ "C_QTDROM", "N", 19, 2 , STR0071                 ,    "@E 999,999,999,999" },; //"Qtd.Rom.Pend." 
    { "C_QTDTRF", "N", 19, 2 , STR0004                 ,	"@E 999,999,999,999" },;
	{ "C_RECNO",  "N", 10, 0, "RECNO", "@ 9999999999"} }

	Local aCpBrwCtr 	:= {}
	Local aIndCtr 		:= { "C_FILIAL+C_CODCTR" } // Definição dos índices
	
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasSld
	Private cTrabSld
	Private cAliasCtr
	Private cTrabCtr
	Private oBrwSld, oBrwCtr
	Private aIndice1, aIndice2

	Private cNoFldSLD	:= "S_TIPO"
	Private cNoFldCTR	:= "C_FILIAL,C_MODELO,C_STATUS,C_RECNO"

	//--- Variáveis de parâmetros de entrada da tela ---//
	Private cCodEnt := Space( TamSX3("NJ0_CODENT")[1] )
	Private cLojEnt := Space( TamSX3("NJ0_LOJENT")[1] )
	Private cNomEnt := Space( TamSX3("NJ0_NOME")[1] )
	Private cNomLoj := Space( TamSX3("NJ0_NOMLOJ")[1] )

	Private aRotAux
    Private cDCodEnt := Space( TamSX3("NJ0_CODENT")[1] )
	Private cDLojEnt := Space( TamSX3("NJ0_LOJENT")[1] )
	Private cDNomEnt := Space( TamSX3("NJ0_NOME")[1] )
	
	cCodEnt := iIf( Empty( pcCodEnt ), cCodEnt, pcCodEnt )
	cLojEnt := iIf( Empty( pcLojEnt ), cLojEnt, pcLojEnt )
	ValEntidade( cCodEnt, cLojEnt ) // Retorna o valor para as variáveis cNomEnt e cLojEnt

	//--- Criação das tabelas temporárias ---//

	// Tabela temporária de Saldos
	aRetTRB := AGRCRIATRB( , aEstruSld, aIndSld, FunName(), .T. )

	cTrabSld 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasSld 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwSld	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	aIndice1	:= AGRINDICONS(aIndSld, aCpBrwSld )

	// Tabela temporária de Contratos
	aRetTRB := AGRCRIATRB( , aEstruCtr, aIndCtr, FunName(), .T. )

	cTrabCtr 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasCtr 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwCtr	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	aIndice2	:= AGRINDICONS(aIndCtr, aCpBrwCtr )
     
    //--- Montagem da tela ---//

    oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Gestão de Contratos de Compras / Vendas / Armazenagem"

    //--- Layers ---//
    oFwLayer := FwLayer():New()
    oFwLayer:Init( oDlg, .f., .t. )

    // Entidade
    oFWLayer:AddLine( 'LinEntidade', 10, .T. )
    oFWLayer:AddCollumn( 'ColEntidade', 100, .T., 'LinEntidade' )
    oPnEnt := oFWLayer:GetColPanel( 'ColEntidade', 'LinEntidade' )

    // Saldos
    oFWLayer:AddLine( 'LinSaldo', 40, .F. )
    oFWLayer:AddCollumn( 'ColSaldo', 100, .T., 'LinSaldo' )
    oPnSld := oFWLayer:GetColPanel( 'ColSaldo', 'LinSaldo' )

    // Contratos
    oFWLayer:AddLine( 'LinContrato', 50, .F. )
    oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinContrato' )
    oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinContrato' )

    // Entidade
    @ 003,005  Say STR0005 COLOR CLR_BLUE Pixel Of oPnEnt //"Entidade"
    @ 001,030  MSGET cCodEnt Picture PesqPict("NJ0","NJ0_CODENT") F3 "NJ0" VALID ValEntidade(cCodEnt,) 			WHEN .T. SIZE 060,010 PIXEL OF oPnEnt
    @ 001,090  MSGET cLojEnt Picture PesqPict("NJ0","NJ0_LOJENT") F3 "NJ0" VALID ValEntidade(cCodEnt,cLojEnt).Or.Empty(cLojEnt) WHEN .T. SIZE 020,010 PIXEL OF oPnEnt 
    @ 001,115  MSGET oNomEnt Var cNomEnt Picture PesqPict("NJ0","NJ0_NOME")   														WHEN .F. SIZE 120,010 PIXEL OF oPnEnt OBFUSCATED AGRLGPD("NJ0_NOME")
    @ 001,235  MSGET oNomLoj Var cNomLoj Picture PesqPict("NJ0","NJ0_NOMLOJ")   													WHEN .F. SIZE 120,010 PIXEL OF oPnEnt OBFUSCATED AGRLGPD("NJ0_NOME")
    // Botão Atualizar
    @ 001,360 BUTTON oBtnAtual PROMPT STR0006	 SIZE 35,012 PIXEL OF oPnEnt ACTION ( A450LoadSld(),A450LoadCtr() ) //"Atualizar"

    DEFINE FWFORMBROWSE oBrwSld DATA TABLE ALIAS cAliasSLD DESCRIPTION STR0002 OF oPnSld //"Saldos"
    oBrwSld:SetTemporary(.T.)
    oBrwSld:SetdbFFilter(.T.)
    oBrwSld:SetUseFilter(.T.)
    oBrwSld:SetFieldFilter(AGRITEMCBRW(aCpBrwSld))
    oBrwSld:SetSeek(,aIndice1)
    oBrwSld:AddLegend( "S_TIPO=='1'", "RED"   ,	X3CboxDesc( "NJR_TIPO", "1" ) ) //Compra
    oBrwSld:AddLegend( "S_TIPO=='2'", "GREEN" ,	X3CboxDesc( "NJR_TIPO", "2" ) ) //Venda
    oBrwSld:AddLegend( "S_TIPO=='3'", "ORANGE",	X3CboxDesc( "NJR_TIPO", "3" ) ) //Armazenagem de 3o.
    oBrwSld:AddLegend( "S_TIPO=='4'", "YELLOW",	X3CboxDesc( "NJR_TIPO", "4" ) ) //Armazenagem em 3o.
    For nx := 1 To Len(aCpBrwSld)
        If !( aCpBrwSld[nX,1] $ cNoFldSLD )
            nTamCpoIDX	:= 1
            If !(aCpBrwSld[nX,2] == "C")
                nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
            EndIF
            ADD COLUMN oColumn 	DATA 	&('{||'+aCpBrwSld[nX,1]+'}');
            Title	aCpBrwSld[nX,5];
            SIZE	aCpBrwSld[nX,3] * nTamCpoIDX;
            PICTURE	aCpBrwSld[nX,6];
            Align	IIf(aCpBrwSld[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
            Of oBrwSld
        EndIf
    Next nx
    oBrwSld:bChange := {|| A450LoadCtr() }
    oBrwSld:DisableDetails()
    //		oBrwSld:AddButton(STR0019,	{|| OGA440( cCodEnt, cLojEnt ) },,,,,,'40') //"Movimentações"
    oBrwSld:AddButton(STR0017,  {|| OGA450A(cCodEnt,cLojEnt,(cAliasSLD)->S_CODSAF,(cAliasSLD)->S_CODPRO, (cAliasSLD)->S_TIPO ) },,,,,,'41') 	//"Trf. Mul. Origens"
    oBrwSld:AddButton(STR0009,	{|| OGA280( cCodEnt, cLojEnt ) },,,,,,'42') //"Contr. Compra"
    oBrwSld:AddButton(STR0010,	{|| OGA290( cCodEnt, cLojEnt ) },,,,,,'43') //"Contr. Venda"
    oBrwSld:AddButton(STR0011,	{|| OGA260( cCodEnt, cLojEnt ) },,,,,,'44') //"Contr. Depósito de 3º"
    oBrwSld:AddButton(STR0012,	{|| OGA270( cCodEnt, cLojEnt ) },,,,,,'45') //"Contr. Depósito em 3º"
    oBrwSld:AddButton(STR0018,	{|| OGA261A( cCodEnt, cLojEnt ) },,,,,,'46') //"Serviços.Armaz"
    oBrwSld:AddButton(STR0022,	{|| fVGrafSLD() },,,,,,'47') //"Gráfico"
    ACTIVATE FWFORMBROWSE oBrwSld

    DEFINE FWFORMBROWSE oBrwCtr DATA TABLE ALIAS cAliasCTR DESCRIPTION STR0003 OF oPnCtr //"Contratos"
    oBrwCtr:SetTemporary(.T.)
    oBrwCtr:SetdbFFilter(.T.)
    oBrwCtr:SetUseFilter(.T.)
    oBrwCtr:SetSeek(,aIndice2)
    oBrwCtr:SetFieldFilter(AGRITEMCBRW(aCpBrwCtr))
    oBrwCtr:AddLegend( "C_MODELO=='1'"						, "WHITE"		, X3CboxDesc( "NJR_MODELO", "1" ) ) //Pré-Contrato
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='P'"	, "BLUE"		, X3CboxDesc( "NJR_STATUS", "P" ) ) //Previsto
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='A'"	, "GREEN"		, X3CboxDesc( "NJR_STATUS", "A" ) ) //Aberto
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='I'"	, "YELLOW"		, X3CboxDesc( "NJR_STATUS", "I" ) ) //Iniciado
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='E'"	, "BR_CANCEL"	, X3CboxDesc( "NJR_STATUS", "E" ) ) //Cancelado
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='F'"	, "RED"		, X3CboxDesc( "NJR_STATUS", "F" ) ) //Finalizado
    For nX := 1 To Len(aCpBrwCtr)
        If !( aCpBrwCtr[nX,1] $ cNoFldCTR )
            nTamCpoIDX	:= 1
            If !(aCpBrwCtr[nX,2] == "C")
                nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
            EndIF
            ADD COLUMN oColumn	DATA 	&('{||'+aCpBrwCtr[nX,1]+'}');
            Title 	aCpBrwCtr[nX,5];
            SIZE 	aCpBrwCtr[nX,3] * nTamCpoIDX;
            PICTURE aCpBrwCtr[nX,6];
            Align	IIf(aCpBrwCtr[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
            Of oBrwCtr
        EndIf
    Next nX
    oBrwCtr:DisableDetails()
    oBrwCtr:AddButton(STR0013,	{|| oDlg:End()                        },,,,,,'31')	//"Sair"
    oBrwCtr:AddButton(STR0020,	{|| OGC003( (cAliasCTR)->C_CODCTR )   },,,,,,'33')	//"Romaneios"
    oBrwCtr:AddButton(STR0021,	{|| OGX001VCtr( (cAliasCTR)->C_RECNO )},,,,,,'32')	//"Visualizar"
    oBrwCtr:AddButton(STR0014,	{|| At430Btn( (cAliasCTR)->C_CODCTR ) },,,,,,'30')	//"Financeiro"
    oBrwCtr:AddButton(STR0015,  {|| iIf( OGA450B(cCodEnt, cLojEnt, cNomEnt, cAliasCTR), A450LoadSld(), NIL ) }	,,,,,,'34') 	//"Transferência"
    oBrwCtr:AddButton(STR0022,  {|| fVGrafCTR()                       },,,,,,'35') //"Gráfico"

    If __lnewNeg
        oBrwCtr:AddButton(STR0056,  {|| OGA450C((cAliasCTR)->C_FILIAL,(cAliasCTR)->C_CODCTR)},,,,,,'37') //"Pendências"
    EndIf

    ACTIVATE FWFORMBROWSE oBrwCtr
    oDlg:Activate( , , , .t., { || .t. }, , { || } )

	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasSLD, cTrabSLD )
	AGRDELETRB( cAliasCTR, cTrabCTR )

Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	25/07/2013
@Uso: 		SIGAAGR
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } )

Return( aRotina )

/** {Protheus.doc} At430Btn
Ações do botão de FINANCEIRO

@param: 	Nil
@return:	nil
@author: 	SIGAAGR
@since: 	25/07/2013
@Uso: 		OGA010 - Entidades
*/
Static Function At430Btn( pcCodCtr )
	Local cCh1TrbSld	:=	( oBrwSld:Alias() )->(S_FILIAL+S_TIPO+S_LOJA+S_CODSAF+S_CODPRO+S_UM1PRO) //Indice 1 		do TRB de Saldos
	Local cCh1TrbCtr	:=	( oBrwCtr:Alias() )->(C_FILIAL+C_CODCTR) //Indice Unico 	do TRB de Contratos
    Local nRecnoSld		:= 0
	Local nRecnoCtr		:= 0    
    
	OGA430( pcCodCtr)			//Chamando a Função que Cuida da parte FinanceiraFixação

	//Reposicionando os Registros pois no Re-load Ele Volta sempre para O Inicio
	A450LoadSld()				// Fazendo um Re-load nos Dados , Ira posicionar na 1a. linha de kda Browse de Saldos
	dBSelectArea( cAliasSld )
	( cAliasSld )->(DbSetOrder(1))
	( cAliasSld )->(DbSeek( cCh1TrbSld ))
	nRecnoSld := ( cAliasSld )->( recno() )	
	
	oBrwSld:fwbrowse():Goto(nRecnoSld,.t.)	

	A450LoadCtr()			// Fazendo um Re-load nos Dados , Ira posicionar na 1a. linha de kda Browse de Ctratos
	dBSelectArea( cAliasCtr )
	( cAliasCtr )->(DbSetOrder(1))
	( cAliasCtr )->(DbSeek( cCh1TrbCtr ))
	nRecnoCtr := ( cAliasCtr )->( recno() )	
	
	oBrwCtr:fwbrowse():Goto(nRecnoCtr,.t.)	
	
	// Browses Reposicionados

Return()

/** {Protheus.doc} ValEntidade()
Valida a entidade

@param: 	pcEntidade		Recebe cCodEnt sozinho ou acompanhado de cLojEnt
@author: 	Marlon Richard Trettin
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ValEntidade( pcCodEnt, pcLojEnt )

	DbSelectArea( "NJ0" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "NJ0" ) + pcCodEnt + iIf( !Empty( AllTrim( pcLojEnt ) ), pcLojEnt, "" ) )
		cNomEnt  := NJ0->( NJ0_NOME )

		If !Empty(cDCodEnt)
			cDNomEnt := NJ0->( NJ0_NOME )
		EndIf

		If !Empty( AllTrim( pcLojEnt ) )
			cNomLoj := NJ0->( NJ0_NOMLOJ )
		Else
			cNomLoj := Space( TamSX3( "NJ0_NOMLOJ" )[1] )
		EndIf
	Else
		Return( .F. )
	EndIf

Return( .T. )

/** {Protheus.doc}
()
Carrega dados da tabela temporária de Saldos.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450LoadSld()

	Local aAreaAtu	 	:= GetArea()
	Local cAliasQry	    := GetNextAlias()
	Local cFiltro 		:= ""

	//--- Apaga conteúdo anterior da tabela temporária SLD ---//
	fZapTRB( cAliasSLD )

	cFiltro := " AND NJR_CODENT = '" + cCodEnt + "'"
	If !Empty( AllTrim( cLojEnt ) )
		cFiltro += " AND NJR_LOJENT = '" + cLojEnt + "'"
		cNoFldSLD	:= "S_TIPO,S_LOJA"
	EndIf
	cFiltro := "%" + cFiltro + "%"

	//--- Query para trazer os saldos ---//
	BeginSql Alias cAliasQry

		SELECT NJR_FILIAL
		,NJR_TIPO
		,NJR_CODENT
		,NJR_LOJENT
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_UM1PRO
		,NJR_QTDCTR
		,NJR_QTEFCO
		,NJR_QTEFIS
		,NJR_QTSFCO
		,NJR_QTSFIS
		,NJR_QTDRES
		,NJR_QSLFCO
		,NJR_SLDFIS
		,(SELECT SUM(NN8_QTDFIX) from %Table:NN8% NN8
		where NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1') as NN8_QTDFIX
		,(SELECT SUM(NN8_QTDENT) from %Table:NN8% NN8
		where NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1') as NN8_QTDENT
        ,(SELECT SUM(NJJ_PSLIQU)  
            FROM %table:NJJ% NJJ
	        INNER JOIN %table:NJM% NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.%notDel%
	        WHERE NJJ.NJJ_FILIAL = %xFilial:NJJ%
	          AND NJJ.NJJ_STATUS IN ("0", "1") //Pendente, Completo, Atualizado
	          AND NJM.NJM_CODCTR = NJR.NJR_CODCTR
	          AND NJM.NJM_TIPO   IN ( "6", "7", "8", "9")
	          AND NJJ.%notDel%) as NJJ_PSLIQU
		FROM %Table:NJR% NJR
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR%
		%exp:cFiltro%

	EndSQL

	/*Alteração conforme SQL server e soma das diferenças conforme o contrato*/
	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )
		/*Verifica se existe agrupamento e soma se for o caso*/
		DbSelectArea( cAliasSLD )
		if (cAliasSLD)->(dbSeek( ( cAliasQry )->NJR_FILIAL  + ( cAliasQry )->NJR_TIPO + ( cAliasQry )->NJR_LOJENT + ( cAliasQry )->NJR_CODSAF + ( cAliasQry )->NJR_CODPRO + ( cAliasQry )->NJR_UM1PRO))
			//update
			RecLock( cAliasSLD, .F. )
			( cAliasSLD )->S_QTDCTR 	+= ( cAliasQry )->NJR_QTDCTR
			( cAliasSLD )->S_QTDFIX 	+= ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QTENFX 	+= ( cAliasQry )->NN8_QTDENT
			( cAliasSLD )->S_QTDAFX 	+= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QSLFCO 	+= ( cAliasQry )->NJR_QSLFCO
			( cAliasSLD )->S_SLDFIS 	+= ( cAliasQry )->NJR_SLDFIS
			( cAliasSLD )->S_QTEFCO 	+= ( cAliasQry )->NJR_QTEFCO
			( cAliasSLD )->S_QTEFIS 	+= ( cAliasQry )->NJR_QTEFIS
			( cAliasSLD )->S_QTSFCO 	+= ( cAliasQry )->NJR_QTSFCO
			( cAliasSLD )->S_QTSFIS 	+= ( cAliasQry )->NJR_QTSFIS
			( cAliasSLD )->S_QTDRES 	+= ( cAliasQry )->NJR_QTDRES
			( cAliasSLD )->S_DIFFIS 	+= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS

			If ( cAliasQry )->NJR_TIPO $ "1|3"
				If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Else
				If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Endif
            
            ( cAliasSLD )->S_QTDROM += ( cAliasQry )->NJJ_PSLIQU
			
            ( cAliasSLD )->( MsUnLock() )
		else
			//new
			RecLock( cAliasSLD, .T. )
			( cAliasSLD )->S_FILIAL 	:= ( cAliasQry )->NJR_FILIAL
			( cAliasSLD )->S_LOJA 	    := ( cAliasQry )->NJR_LOJENT
			( cAliasSLD )->S_TIPO 	    := ( cAliasQry )->NJR_TIPO
			( cAliasSLD )->S_DESTIP 	:= X3CboxDesc( "NJR_TIPO", ( cAliasQry )->NJR_TIPO )
			( cAliasSLD )->S_CODSAF 	:= ( cAliasQry )->NJR_CODSAF
			( cAliasSLD )->S_CODPRO 	:= ( cAliasQry )->NJR_CODPRO
			( cAliasSLD )->S_DESPRO 	:= Posicione('SB1',1,xFilial('SB1')+( cAliasQry )->NJR_CODPRO,'B1_DESC')
			( cAliasSLD )->S_UM1PRO 	:= ( cAliasQry )->NJR_UM1PRO
			( cAliasSLD )->S_QTDCTR 	:= ( cAliasQry )->NJR_QTDCTR
			( cAliasSLD )->S_QTDFIX 	:= ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QTENFX 	:= ( cAliasQry )->NN8_QTDENT
			( cAliasSLD )->S_QTDAFX 	:= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QSLFCO 	:= ( cAliasQry )->NJR_QSLFCO
			( cAliasSLD )->S_SLDFIS 	:= ( cAliasQry )->NJR_SLDFIS
			( cAliasSLD )->S_QTEFCO 	:= ( cAliasQry )->NJR_QTEFCO
			( cAliasSLD )->S_QTEFIS 	:= ( cAliasQry )->NJR_QTEFIS
			( cAliasSLD )->S_QTSFCO 	:= ( cAliasQry )->NJR_QTSFCO
			( cAliasSLD )->S_QTSFIS 	:= ( cAliasQry )->NJR_QTSFIS
			( cAliasSLD )->S_QTDRES 	:= ( cAliasQry )->NJR_QTDRES
			( cAliasSLD )->S_DIFFIS 	:= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS

			If ( cAliasQry )->NJR_TIPO $ "1|3"
				If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Else
				If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Endif
            
            ( cAliasSLD )->S_QTDROM := ( cAliasQry )->NJJ_PSLIQU
			
            ( cAliasSLD )->( MsUnLock() )
		endIF

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
    
    If Type("oBrwSld") <> "U"
        oBrwSld:Refresh(.T.)
    EndIf	
	
	RestArea( aAreaAtu )
Return

/** {Protheus.doc} A450LoadCtr
Carrega dados da tabela temporária de Contratos.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	23/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450LoadCtr()

	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cTipo		:= ( cAliasSLD )->S_TIPO
	Local cCodSaf 	:= ( cAliasSLD )->S_CODSAF
	Local cCodPro 	:= ( cAliasSLD )->S_CODPRO
	Local cAuxLoj		:= ( cAliasSLD )->S_LOJA

	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	fZapTRB( cAliasCTR )

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry

		SELECT NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_DATA
		,NJR.R_E_C_N_O_ AS NJR_RECNO
		,(SELECT MIN(NNY_DATINI) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATINI
		,(SELECT MAX(NNY_DATFIM) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATFIM
        ,(SELECT SUM(NJJ_PSLIQU)  
            FROM %table:NJJ% NJJ
	        INNER JOIN %table:NJM% NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.%notDel%
	        WHERE NJJ.NJJ_FILIAL = %xFilial:NJJ%
	          AND NJJ.NJJ_STATUS IN ("0", "1") //Pendente, Completo, Atualizado
	          AND NJM.NJM_CODCTR = NJR.NJR_CODCTR
	          AND NJM.NJM_TIPO   IN ( "6", "7", "8", "9")
	          AND NJJ.%notDel%) as NJJ_PSLIQU
		,MAX(NJR_QTDCTR) as NJR_QTDCTR
		,MAX(NJR_QTEFCO) as NJR_QTEFCO
		,MAX(NJR_QTEFIS) as NJR_QTEFIS
		,MAX(NJR_QTSFCO) as NJR_QTSFCO
		,MAX(NJR_QTSFIS) as NJR_QTSFIS
		,MAX(NJR_QTDRES) as NJR_QTDRES
		,MAX(NJR_QSLFCO) as NJR_QSLFCO
		,MAX(NJR_SLDFIS) as NJR_SLDFIS
		,SUM(NN8_QTDFIX) as NN8_QTDFIX
		,SUM(NN8_QTDENT) as NN8_QTDENT
		FROM %Table:NJR% NJR
		LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1'
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR%
		AND NJR_CODENT = %exp:cCodEnt%
		AND NJR_LOJENT = %exp:cAuxLoj%
		AND NJR_TIPO   = %exp:cTipo%
		AND NJR_CODSAF = %exp:cCodSaf%
		AND NJR_CODPRO = %exp:cCodPro%
		GROUP BY  NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_DATA
		,NJR.R_E_C_N_O_

	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )

		RecLock( cAliasCTR, .T. )
		( cAliasCTR )->C_FILIAL 	:= ( cAliasQry )->NJR_FILIAL
		( cAliasCTR )->C_MODELO 	:= ( cAliasQry )->NJR_MODELO
		( cAliasCTR )->C_STATUS 	:= ( cAliasQry )->NJR_STATUS
		( cAliasCTR )->C_CODCTR 	:= ( cAliasQry )->NJR_CODCTR
		( cAliasCTR )->C_DESCRI 	:= ( cAliasQry )->NJR_DESCRI
		( cAliasCTR )->C_DATA	:= StoD( ( cAliasQry )->NJR_DATA )
		( cAliasCTR )->C_DATINI 	:= StoD( ( cAliasQry )->NNY_DATINI )
		( cAliasCTR )->C_DATFIM 	:= StoD( ( cAliasQry )->NNY_DATFIM )
		( cAliasCTR )->C_QTDCTR 	:= ( cAliasQry )->NJR_QTDCTR
		( cAliasCTR )->C_QTDFIX 	:= ( cAliasQry )->NN8_QTDFIX
		( cAliasCTR )->C_QTENFX 	:= ( cAliasQry )->NN8_QTDENT
		( cAliasCTR )->C_QTDAFX 	:= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
		( cAliasCTR )->C_QSLFCO 	:= ( cAliasQry )->NJR_QSLFCO
		( cAliasCTR )->C_SLDFIS 	:= ( cAliasQry )->NJR_SLDFIS
		( cAliasCTR )->C_QTEFCO 	:= ( cAliasQry )->NJR_QTEFCO
		( cAliasCTR )->C_QTEFIS 	:= ( cAliasQry )->NJR_QTEFIS
		( cAliasCTR )->C_QTSFCO 	:= ( cAliasQry )->NJR_QTSFCO
		( cAliasCTR )->C_QTSFIS 	:= ( cAliasQry )->NJR_QTSFIS
		( cAliasCTR )->C_QTDRES 	:= ( cAliasQry )->NJR_QTDRES
		( cAliasCTR )->C_DIFFIS 	:= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS
		( cAliasCTR )->C_RECNO 	:= ( cAliasQry )->NJR_RECNO

		If ( cAliasQry )->NJR_TIPO $ "1|3"
			If (( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES
			Else
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif
		Else
			If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES
			Else
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif
		Endif

        ( cAliasCTR )->C_QTDROM := ( cAliasQry )->NJJ_PSLIQU
        ( cAliasCTR )->C_QTDTRF -= ( cAliasQry )->NJJ_PSLIQU

		( cAliasCTR )->( MsUnLock() )

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )	
	
    If Type("oBrwCtr") <> "U"
        oBrwCtr:Refresh(.T.)
    EndIf

	RestArea( aAreaAtu )
Return

/** {Protheus.doc} fZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	29/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()

	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	Endif

	RestArea( aAreaAtu )
Return

Static Function fVGrafSLD()
	Local aValues := {}
	Local cTitulo := STR0002 + " " + STR0003 + " " + AllTrim( (cAliasSLD)->S_DESTIP ) + Chr(13) +; //"Saldos"##"Contratos"
	AllTrim( (cAliasSLD)->S_CODSAF ) + " " + AllTrim( (cAliasSLD)->S_DESPRO )

	aAdd( aValues, { RetTitle( "NJR_QTDCTR" ), (cAliasSLD)->S_QTDCTR } )
	If (cAliasSLD)->S_TIPO $ "1|2"
		aAdd( aValues, { RetTitle( "NN8_QTDFIX" ), (cAliasSLD)->S_QTDFIX } )
		aAdd( aValues, { STR0016, (cAliasSLD)->S_QTENFX } )	//Qtd. Ent. Fix.
		aAdd( aValues, { STR0007, (cAliasSLD)->S_QTDAFX } )	//Qtd. a Fixar
	EndIf
	aAdd( aValues, { RetTitle( "NJR_QSLFCO" ), (cAliasSLD)->S_QSLFCO } )
	aAdd( aValues, { RetTitle( "NJR_SLDFIS" ), (cAliasSLD)->S_SLDFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTEFCO" ), (cAliasSLD)->S_QTEFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTEFIS" ), (cAliasSLD)->S_QTEFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTSFCO" ), (cAliasSLD)->S_QTSFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTSFIS" ), (cAliasSLD)->S_QTSFIS } )
	aAdd( aValues, { STR0008, (cAliasSLD)->S_DIFFIS } )	// Dif. Fiscal
	aAdd( aValues, { RetTitle( "NJR_QTDRES" ), (cAliasSLD)->S_QTDRES } )
	aAdd( aValues, { STR0004, (cAliasSLD)->S_QTDTRF } )	
	
    AgrCriaChart( cTitulo, aValues, "@E 999,999,999,999" )	
	
Return NIL

Static Function fVGrafCTR()
	Local aValues := {}
	Local cTitulo := AllTrim( (cAliasCTR)->C_CODCTR ) + " - " + AllTrim( (cAliasCTR)->C_DESCRI )

	aAdd( aValues, { RetTitle( "NJR_QTDCTR" ), (cAliasCTR)->C_QTDCTR } )
	If (cAliasSLD)->S_TIPO $ "1|2"
		aAdd( aValues, { RetTitle( "NN8_QTDFIX" ), (cAliasCTR)->C_QTDFIX } )
		aAdd( aValues, { STR0016, (cAliasCTR)->C_QTENFX } )	//Qtd. Ent. Fix.
		aAdd( aValues, { STR0007, (cAliasCTR)->C_QTDAFX } )	//Qtd. a Fixar
	EndIf
	aAdd( aValues, { RetTitle( "NJR_QSLFCO" ), (cAliasCTR)->C_QSLFCO } )
	aAdd( aValues, { RetTitle( "NJR_SLDFIS" ), (cAliasCTR)->C_SLDFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTEFCO" ), (cAliasCTR)->C_QTEFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTEFIS" ), (cAliasCTR)->C_QTEFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTSFCO" ), (cAliasCTR)->C_QTSFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTSFIS" ), (cAliasCTR)->C_QTSFIS } )
	aAdd( aValues, { STR0008, (cAliasCTR)->C_DIFFIS } )	// Dif. Fiscal
	aAdd( aValues, { RetTitle( "NJR_QTDRES" ), (cAliasCTR)->C_QTDRES } )
	aAdd( aValues, { STR0004, (cAliasCTR)->C_QTDTRF } )
	
	AgrCriaChart( cTitulo, aValues, "@E 999,999,999,999" )	

Return NIL

Function AgrCriaChart( pcTitulo, paValues, pcPict )
	Local oFWChart
	Local oDlg
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local aButtons := {}
	Local nX := 0

	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( BARCHART ) }, 		"Barras", 			"Barras" } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( BARCOMPCHART ) }, 	"Barras Comp.", 	"Barras Comp." } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( LINECHART ) }, 	"Linhas", 			"Linhas" } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( PIECHART ) }, 		"Pizza", 			"Pizza" } )
	/* Valores do getInstance:
	BARCHART  		- cria objeto FWChartBar
	BARCOMPCHART 	- cria objeto FWChartBarComp
	LINECHART 		- cria objeto FWChartLine
	PIECHART 		- cria objeto FWChartPie
	*/

	DEFINE MSDIALOG oDlg FROM  aCords[ 1 ]+30, aCords[ 2 ]+30 TO aCords[ 3 ]-30, aCords[ 4 ]-30 TITLE pcTitulo PIXEL

	oFWChart := FWChartFactory():New()
	oFWChart := oFWChart:getInstance( BARCHART ) // cria objeto FWChartBar
	oFWChart:init( oDLG, .F. )
	oFWChart:setTitle( pcTitulo, CONTROL_ALIGN_CENTER )
	oFWChart:setLegend( CONTROL_ALIGN_LEFT )
	oFWChart:setMask( " *@* " )
	oFWChart:setPicture( pcPict )
	For nX := 1 to Len( paValues )
		oFWChart:addSerie( paValues[ nX, 1 ], paValues[ nX, 2 ] )
	Next nX
	oFWChart:build()

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| oDlg:End() }, {|| oDlg:End() }, , @aButtons )

Return

/*{Protheus.doc} OGA450BGNC
	//Função de tela para gerar o titulo de NCC/NDC através de alçada de aprovação
	@author filipe.olegini/Marcelo Ferrari
	@since 28/06/2018
	@version 1.0
	@type function
	@Paramns nRecno as Numeric : Id do registro selecionado do contrato
	cOpc   as Char    : C = Nota de Crédito / D= Nota de Débito
*/
Function OGA450BGNC(nRecno as numeric, cOpc as Char)
	Local aAreaNJR      as array
	Local oSize         as object
	Local oMStruNJR     as object
	Local oVStruNJR     as object
	Local oModelNxC     as object
	Local oViewNxC      as object
	Local oViewExec     as object
	Local aButtons 	    as array
	Local nWidth        as numeric
	Local nHeight       as numeric
	Local cParcela      as char

	//inicializa as variáveis
	aAreaNJR      := NJR->(GetArea())
	oSize         := FwDefSize():New(.T.) // Considera a enchoice bar
	oMStruNJR     := FwFormStruct(1, "NJR", {|x| AllTrim(x) $ "NJR_CTREXT;NJR_DESCRI;NJR_TIPO;NJR_QTSFIS;NJR_VLSFIS;NJR_SLDFIS"})
	oVStruNJR     := FwFormStruct(2, "NJR", {|x| AllTrim(x) $ "NJR_CTREXT;NJR_DESCRI;NJR_TIPO;NJR_QTSFIS;NJR_VLSFIS;NJR_SLDFIS"})
	oModelNxC     := FwFormModel():New("OGA450NxC", , , {|| .T.}, {|| .T.}) // Instancia um modelo
	oViewNxC      := FwFormView():New() // Instancia uma View
	oViewExec     := FWViewExec():New() // Instancia um Executor de View
	aButtons 	  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0037 /*Confirmar*/},{.T., STR0038 /*Fechar*/},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Confirmar" # "Fechar"
	nWidth        := 0
	nHeight       := 0
	cParcela      := ""

	nWidth  := (oSize:AWINDSIZE[4] * 0.30) // 30% da largura total
	nHeight := (oSize:AWINDSIZE[3] * 0.30) // 20% da altura total

	//joga os valores
	DbSelectArea("NJR")
	DbGoTo(nRecno)

	//adiciona campo na estrutura
	If cOpc == 'C'
		oMStruNJR:AddField(STR0061, STR0061, "DEVVAL", 'C', 1, 0,{|| fValidObs(oModelNxC)} , , , .F., , , .F., .T.) //"Tipo de Credito:"
		oVStruNJR:AddField( "DEVVAL"  ,'1' , STR0061, STR0061, {} , 'C' , '@!' , NIL, NIL, .T., NIL, NIL, {STR0062,STR0063,STR0064}, NIL, NIL, .T. ) //'0=Não Atribuido','1=Devolver ao Cliente','2=Abater Valor'
	EndIf

	oMStruNJR:AddField(RetTitle( "A1_NATUREZ" ), RetTitle( "A1_NATUREZ" ), "NATUREZA", TamSX3( "A1_NATUREZ" )[3], TamSX3( "A1_NATUREZ" )[1], TamSX3( "A1_NATUREZ" )[2], , , , .F., , , .F., .T.)
	oVStruNJR:AddField( "NATUREZA"  ,'17' , RetTitle( "A1_NATUREZ" ), RetTitle( "A1_NATUREZ" ), {} , TamSX3( "A1_NATUREZ" )[3] ,PesqPict("SA1","A1_NATUREZ") , NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )

	oVStruNJR:SetProperty("NATUREZA", MVC_VIEW_LOOKUP, "SED")

	oMStruNJR:AddField(STR0024, STR0024, "VALOR", "N", 15, 2, , , , .F., , , .F., .T.)
	oVStruNJR:AddField( "VALOR"  ,'17' , STR0024, STR0024, {} , 'N' ,'@E 999,999,999,999.99', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T. )

	//regra fiscal e cadência
	oMStruNJR:AddField(RetTitle( "N9A_ITEM" ), RetTitle( "N9A_ITEM" ), "PREVENT", TamSX3( "N9A_ITEM" )[3], TamSX3( "N9A_ITEM" )[1], TamSX3( "N9A_ITEM" )[2], , , , .F., , , .F., .T.)
	oVStruNJR:AddField( "PREVENT"  ,'18' , RetTitle( "N9A_ITEM" ), RetTitle( "N9A_ITEM" ), {} , TamSX3( "N9A_ITEM" )[3] ,PesqPict("N9A","N9A_ITEM") , NIL, "N9ANNY", .T., NIL, NIL, NIL, NIL, NIL, .T. )

	oMStruNJR:AddField(RetTitle( "N9A_SEQPRI" ), RetTitle( "N9A_SEQPRI" ), "REGRA", TamSX3( "N9A_ITEM" )[3], TamSX3( "N9A_SEQPRI" )[1], TamSX3( "N9A_SEQPRI" )[2], , , , .F., , , .F., .T.)
	oVStruNJR:AddField( "REGRA"  ,'19' , RetTitle( "N9A_SEQPRI" ), RetTitle( "N9A_SEQPRI" ), {} , TamSX3( "N9A_SEQPRI" )[3] ,PesqPict("N9A","N9A_SEQPRI") , NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )

	oMStruNJR:AddField(RetTitle("E1_HIST"), RetTitle("E1_HIST"), "OBSERVA", "C", TamSX3("E1_HIST")[1], TamSX3("E1_HIST")[2],,{|| fWhenObs(oModelNxC,cOpc)}  , , .F., , , .F., .T.)
	oVStruNJR:AddField( "OBSERVA"  ,'20' , RetTitle("E1_HIST"), RetTitle("E1_HIST"), {} , 'C' ,'@!', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T. )

	If cOpc = "D"
		oMStruNJR:AddField(STR0046, STR0046, "VENCTO", "D", 8, 0, , , , .F., , , .F., .T.)
		oVStruNJR:AddField("VENCTO"  ,'20' , STR0046, STR0046, {} , 'N' ,'', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T. )
		oMStruNJR:SetProperty("VENCTO"   , MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	//carrega os campos
	oMStruNJR:SetProperty("NJR_CTREXT", MODEL_FIELD_INIT, {|| NJR->NJR_CTREXT})
	oMStruNJR:SetProperty("NJR_DESCRI", MODEL_FIELD_INIT, {|| NJR->NJR_DESCRI})
	oMStruNJR:SetProperty("NJR_TIPO"  , MODEL_FIELD_INIT, {|| NJR->NJR_TIPO})
	oMStruNJR:SetProperty("NJR_QTSFIS", MODEL_FIELD_INIT, {|| NJR->NJR_QTSFIS})
	oMStruNJR:SetProperty("NJR_VLSFIS", MODEL_FIELD_INIT, {|| NJR->NJR_VLSFIS})
	oMStruNJR:SetProperty("NJR_SLDFIS", MODEL_FIELD_INIT, {|| NJR->NJR_SLDFIS})
	oMStruNJR:SetProperty("NJR_SLDFIS", MODEL_FIELD_INIT, {|| ""})
	//oMStruNJR:SetProperty("NATUREZA"  , MODEL_FIELD_INIT, {|| 0 })

	//muda o campo para obrigatório
	oMStruNJR:SetProperty("NATUREZA", MODEL_FIELD_OBRIGAT, .T.)
	oMStruNJR:SetProperty("VALOR"   , MODEL_FIELD_OBRIGAT, .T.)

	//trava os campos para ficar apenas visual
	oMStruNJR:SetProperty("NJR_CTREXT", MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("NJR_DESCRI", MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("NJR_TIPO"  , MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("NJR_QTSFIS", MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("NJR_VLSFIS", MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("NJR_SLDFIS", MODEL_FIELD_WHEN, {|| .F.})
	oMStruNJR:SetProperty("PREVENT"   , MODEL_FIELD_OBRIGAT, .T.)
	oMStruNJR:SetProperty("REGRA"     , MODEL_FIELD_OBRIGAT, .T.)

	If cOpc = "C"
		oModelNxC:SetDescription(STR0025) //  Gerar solicitação de Nota de Crédido Cliente
	elseif cOpc = "D"
		oModelNxC:SetDescription(STR0045) //  Gerar solicitação de Nota de Crédido Cliente
	EndIf
	oModelNxC:AddFields("FIELDNxC", , oMStruNJR) // Pre requisito para criacao de uma view
	oModelNxC:SetPrimaryKey({"NJR_CTREXT"})

	//ajusta a ordem dos campos
	oVStruNJR:SetProperty("NJR_CTREXT", MVC_VIEW_ORDEM, "01")
	oVStruNJR:SetProperty("NJR_DESCRI", MVC_VIEW_ORDEM, "02")
	oVStruNJR:SetProperty("NJR_TIPO"  , MVC_VIEW_ORDEM, "03")
	oVStruNJR:SetProperty("NJR_QTSFIS", MVC_VIEW_ORDEM, "04")
	oVStruNJR:SetProperty("NJR_VLSFIS", MVC_VIEW_ORDEM, "05")
	oVStruNJR:SetProperty("NJR_SLDFIS", MVC_VIEW_ORDEM, "06")
	oVStruNJR:SetProperty("NATUREZA"  , MVC_VIEW_ORDEM, "07")
	oVStruNJR:SetProperty("VALOR"     , MVC_VIEW_ORDEM, "08")
	oVStruNJR:SetProperty("OBSERVA"   , MVC_VIEW_ORDEM, "09")

	oVStruNJR:SetNoFolders(.T.)

	oViewNxC:SetModel(oModelNxC)
	oViewNxC:AddField("VIEWNxC", oVStruNJR, "FIELDNxC")

	oViewNxC:CreateHorizontalBox("BOXVIEWNxC", 100)
	oViewNxC:SetOwnerView("VIEWNxC", "BOXVIEWNxC")

	oViewNxC:SetViewProperty("VIEWNxC", "SETLAYOUTNxC", {FF_LAYOUT_VERT_DESCR_TOP, 1}) // Seta o layout de forma vertical com 1 coluna

	oViewExec:SetView(oViewNxC)
	oViewExec:setOperation(MODEL_OPERATION_INSERT)
	oViewExec:SetButtons(aButtons)
	If cOpc = "C"
		oViewExec:SetTitle(STR0025) // # Gerar solicitação de Nota de Crédido Cliente
	elseIf cOpc = "D"
		oViewExec:SetTitle(STR0045) //"Gerar solicitação de Nota de Débito de Cliente")
	EndIf
	oViewExec:SetOk({|oModelNxC| OGA450BOK(oModelNxC, cOpc)})
	oViewExec:setCloseOnOK({|| .T. }) //faz com que a tela seje fechada apos o ok
	oViewExec:SetSize(nHeight, nWidth) // Dimensões da tela

	oViewExec:openView(.F.)

	RestArea(aAreaNJR)

Return

/*/{Protheus.doc} OGA450BOK
	Gera registro para controle de aprovação de alçadas do compras
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@param oModelNxC, objeto, pbjeto a ser atualizado
	@see (links_or_references)
/*/
Function OGA450BOK(oModelNxC as object, cOpc as Char, aDados as array )
	Local aArea		as array
	Local aRet      as array

	Default aDados := {}

	aArea		:= GetArea()

	aAdd(aDados, NJR->NJR_FILIAL)
	aAdd(aDados, NJR->NJR_CODCTR)
	aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("PREVENT"))
	aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("REGRA"))
	aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("NATUREZA"))
	aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("VALOR"))
	aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("OBSERVA"))

	If cOpc == "D"
		aAdd(aDados, oModelNxC:GetModel("FIELDNxC"):GetValue("VENCTO"))
	EndIf

	aRet := OGA450ALCF(cOpc, aDados)

Return aRet[1]

/*/{Protheus.doc} OGA450ALCF
	Gera Alçada para Notas de Crédito ou Débito no Financeiro
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@param oModelNxC, objeto, pbjeto a ser atualizado
	@see (links_or_references)
/*/
Function OGA450ALCF(cOpc as Char, aDados as array )
	Local aArea		as array
	Local cGrpAprov	as char
	Local nValor    as numeric
	Local cNatureza as char
	Local nTxMoed   as numeric
	Local cDocumen  as char
	Local cItem     as char
	Local cTp       as Char
	Local lAlc      as logical
	Local cCodCad   as char
	Local cRegra    as Char
	Local cFilCtr   as char
	Local cCodCtr   as char

	aArea		:= NJR->(GetArea())
	cGrpAprov	:= SuperGetMv("MV_AGRO016")

	cFilCtr     := aDados[1]
	cCodCtr     := aDados[2]
	cCodCad     := aDados[3]
	cRegra      := aDados[4]
	cNatureza   := aDados[5]
	nValor      := aDados[6]
	cObserva    := aDados[7]

	If cOpc == "D"
		If ValType(aDados[8]) == 'D'
			dVencto     := aDados[8]
		Else
			dVencto     := stod(aDados[8])
		EndIf
	Endif

	NJR->(DbSetOrder(1))
	NJR->(dbSeek(cFilCtr + cCodCtr))

	nTxMoed		:= OGA450COT( NJR->NJR_MOEDA, dDataBase ) //busca a taxa da moeda
	cItem       := OGA450JAE(NJR->NJR_CODCTR, cOpc) //busca parcelas
	cDocumen    := NJR->NJR_CODCTR + AllTrim(cItem)
	lRet        := .T.

	//valida a regra fiscal
	N9A->(DbSetOrder(1))
	If !N9A->(DbSeek(NJR->NJR_FILIAL + NJR->NJR_CODCTR + cCodCad + cRegra ))
		Help( , , STR0054, , STR0055, 1, 0 )
		Return {lRet, STR0055,"", "",.F.} //"Regra Fiscal não encontrado para o contrato."
	endif

	If !Empty(cGrpAprov) //se o parametro estiver em branco ou vazio nao utiliza a alçada

		IF cOpc = "C"
			cTp := "A3"
		elseif cOpc = "D"
			cTp := "A4"
		EndIf

		If Empty(nValor) .OR. Empty(cNatureza)
			MsgInfo(STR0026,STR0027)// Campos obrigatórios não informados // Atenção
			Return {lRet, STR0057,"", "", .F.} //Valor ou natureza não preenchidos.
		Else
			MsAguarde( {|| lAlc := MaAlcDoc({cDocumen, cTp, nValor,,,cGrpAprov,,NJR->NJR_MOEDA, nTxMoed, dDataBase, ""}, dDataBase,1) },STR0058,STR0059 )
			//chamar a função de gerar NxC e gravar a N8L
			BEGIN Transaction

				dbSelectArea("NBX")
				dbSetOrder(1)
				If !dbSeek(FwXFilial("NBX")+NJR->NJR_CODCTR+cDocumen+cTp+cItem)
					If RecLock("NBX", .T.)
						NBX->NBX_FILIAL := FwXFilial("NBX")
						NBX->NBX_CODCTR := NJR->NJR_CODCTR
						NBX->NBX_DOC    := cDocumen
						NBX->NBX_TIPO   := cTp
						If cOpc = "C"
							NBX->NBX_ITEM   := "001"        //neste tipo de documento é fixo
						ElseIf cOpc = "D"
							NBX->NBX_ITEM   := AllTrim(cItem)
						EndIf
						NBX->NBX_ORIGEM := "OGA450"
						If cOpc = "C"
							NBX->NBX_DATA   := ddatabase
						Else
							NBX->NBX_DATA   := dVencto
						EndIf
						NBX->NBX_VALOR  := nValor
						NBX->NBX_USUARI := RetCodUsr()
						NBX->NBX_STATUS := "P"
						NBX->NBX_NATURE := cNatureza
						NBX->NBX_HISTOR := cObserva
						NBX->NBX_CODCAD := cCodCad
						NBX->NBX_SEQPRI := cRegra
						NBX->(MsUnlock())
					EndIf

					If lAlc
						If cOpc = "C"
							lRet := (A450GERTIT(FwXfilial("NJR"), NJR->NJR_CODCTR, cDocumen, AllTrim(cItem), nValor, cObserva, 'A' ) )
						elseif cOpc = "D"
							lRet := (A450GERNDC(FwXfilial("NJR"), NJR->NJR_CODCTR, cDocumen,AllTrim(cItem), nValor, dVencto, cObserva, 'A' ) )
						Endif
					Else
						lRet := .T.
						If cOpc = "C"
							Help('', 1, "OGA450NCCG") //Solicitação para gerar uma Nota de Crédito Cliente (A3) ecaminhada para aprovação. #A liberação deverá ser feita pelo Responsável definido no Grupo de Aprovação Cadastrado.
						elseif cOpc = "D"
							Help('', 1, "OGA450NDCG") //Solicitação para gerar uma Nota de Débito Cliente (A4) ecaminhada para aprovação. #A liberação deverá ser feita pelo Responsável definido no Grupo de Aprovação Cadastrado.
						EndIf
					EndIf

				Else
					MsgInfo(STR0048, STR0027 )   //"Não foi possivel abrir a tabela NBX para gravação"  //Atencao
					lRet := .F.
				EndIf

				If !lRet
					DisarmTransaction()
				Else
					MsgInfo(STR0065+cDocumen,STR0066) //"Numero do documento gerado:  ## Titulo Gerado! "
				EndIF
			END Transaction
		EndIf
	Else
		Help('',1, "OGA450MV16EMPT") //Parametro MV_AGRO016 não prenchido. # Para realizar a confirmação é necessário vincular no parametro MV_AGRO016 o grupo de aprovação.
		lRet    := .F.
	EndIf

	RestArea(aArea)

Return {lRet, "",cDocumen, "", lAlc}

/*{Protheus.doc} OGA450COT
	//Função que retorna a taxa da moeda
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@version 1.0
	@type function
*/
Static Function OGA450COT( nMoeda as numeric, dDtTaxa as date)
	Local nTxaComp as numeric

	nTxaComp  := 1

	//verifica se for moeda diferente de 1 busca a taxa da modea informada
	If nMoeda <> 1

		DBSelectArea("SM2")
		SM2->(DBSetOrder(1) )
		If SM2->(DbSeek(DtoS(dDtTaxa)))
			nTxaComp 	:= &('SM2->M2_TXMOED'+ STRZERO(nMoeda,1) )
		EndIf
	Else
		nTxaComp := 1
	EndIf

Return (nTxaComp)

/*{Protheus.doc} OGA450JAE
	//Função que verifica se ja existe uma NCC gerada e retorna a proxima numeração
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@version 1.0
	@type function
*/
Static Function OGA450JAE( cCodCtr as char, cOpc as Char)
	Local cRet      as char
	Local cQuery    as char
	Local cAliasQry as char

	cRet      := ""
	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT MAX(NBX_ITEM) AS ITEM"
	cQuery += " FROM " + RetSqlName('NBX')
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND NBX_FILIAL = '" + FWxFilial('NBX') + "' "
	cQuery += " AND NBX_CODCTR   = '" + cCodCtr + "' "
	If cOpc = "C"  //NCC
		cQuery += " AND NBX_TIPO = 'A3' "
	elseif cOpc = "D"   //NDC
		cQuery += " AND NBX_TIPO = 'A4' "
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof())
		cRet := (cAliasQry)->ITEM
		If Empty(cRet)
			cRet := "001"
		Else
			cRet := Soma1(cRet)
		EndIf
	Else
		cRet := "001"
	EndIf

	(cAliasQry)->(dbCloseArea())

Return cRet

/*/{Protheus.doc} A450GERTIT
	Função para gerar o titulo dos documentos do tipo A3. Chamado na função AGRXFUN1
	@type  Function
	@author filipe.olegini
	@since 23/07/2018
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function A450GERTIT(cFilCtr as char, cCodCtr as char, cDoc as char, cItem as char, nValor as Numeric, cObserva as char, cStAlc as char)
	Local aAreaNBX      as array
	Local aAreaNJR      as array
	Local aAreaNC8      as array
	Local cPrefixo      as char
	Local cParcela      as char
	Local cFilTit       as char
	Local lNBX          as logical
	Local lRet    	    as Logical

	Private lMsErroAuto as logical

	Default cItem := ""
	Default nValor := 0
	Default cObserva := ""
	Default cStAlc   := ""

	aAreaNBX    := NBX->(GetArea())
	aAreaNJR    := NJR->(GetArea())
	aAreaNC8    := NC8->(GetArea())

	lNBX := .F.
	lRet := .F.
	//AGRXCOM8(cNumDoc, cTipDoc, cRecno)
	If FWISINCALLSTACK("AGRXCOM8")
		If SELECT("NBX") = 0
			DBSelectArea("NBX")
			lNBX := .T.
		EndIf
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A3"   ) )
			cItem    := NBX->NBX_ITEM
			nValor   := NBX->NBX_VALOR
			cObserva := NBX->NBX_HISTOR
		Else
			MsgInfo(STR0047, STR0027 )   //"Documento não encontrado na tabela NBX"
			Return .F.
		EndIF
	EndIf

	cPrefixo    := SuperGetMV("MV_AGRO031", .F., "A3")
	cParcela    := StrZero(Val(cItem),2)
	cFilTit     := ""

	lMsErroAuto := .F.

	NBX->(DbSetOrder(1)) //NBX_FILIAL+NBX_CODCTR+NBX_DOC+NBX_TIPO+NBX_ITEM
	If NBX->(DbSeek(xFilial("NBX") + cCodCtr + PadR(cDoc, TamSX3("NBX_DOC")[1] )+ "A3" + cItem ))

		N9A->(DbSetOrder(1))
		If N9A->(DbSeek(cFilCtr + cCodCtr + NBX->NBX_CODCAD + NBX->NBX_SEQPRI ))
			//coloca a filial conforme a regra fiscal
			cFilTit := N9A->N9A_FILORG
		endif

		If cStAlc == "A"

			NJR->(DbSetOrder(1))
			NJR->(DbSeek(cFilCtr+cCodCtr))

			//grava as variáveis e grava N8L
			aN8lVinc := {}
			aAdd( aN8lVinc, { "N8L_FILIAL"  , FwXfilial('N8L') 	} )
			aAdd( aN8lVinc, { "N8L_FILORI"  , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')) } ) //usa a mesma filial da N8L
			aAdd( aN8lVinc, { "N8L_PREFIX"  , cPrefixo          } ) //é Utilizado tipo de documento da alçada
			aAdd( aN8lVinc, { "N8L_NUM"     , cDoc              } ) //código do contrato
			aAdd( aN8lVinc, { "N8L_PARCEL"  , cParcela          } ) //usa parcela em BRANCO
			aAdd( aN8lVinc, { "N8L_TIPO"    , "NCC"		        } ) //Fixo NCC que é o tipo que está sendo gerado
			aAdd( aN8lVinc, { "N8L_CODCTR"  , cCodCtr           } )
			aAdd( aN8lVinc, { "N8L_SAFRA"  	, NJR->NJR_CODSAF	} )
			aAdd( aN8lVinc, { "N8L_CODROM"  , ""	            } )
			aAdd( aN8lVinc, { "N8L_ITEROM" 	, ""	            } )
			aAdd( aN8lVinc, { "N8L_CODFIX" 	, ""				} )
			aAdd( aN8lVinc, { "N8L_CODOTR"  , ""				} )
			aAdd( aN8lVinc, { "N8L_ORPGRC" 	, ""				} )
			aAdd( aN8lVinc, { "N8L_ORIGEM"  , "OGA450"			} )
			aAdd( aN8lVinc, { "N8L_HISTOR"  , cObserva			} )

			lRet := fAgrVncRec ({aN8lVinc}, 3 )  	//Incluir

			If lRet
				//gera titulo na SE1
				aFina040 := {}
				aAdd( aFina040, { "E1_FILIAL"  , FwXfilial('SE1'), Nil } )
				aAdd( aFina040, { "E1_PREFIXO" , cPrefixo        , Nil } )
				aAdd( aFina040, { "E1_NUM"     , cDoc            , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , cParcela        , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , "NCC"           , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI"), Nil } )
				aAdd( aFina040, { "E1_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI"), Nil } )
				aAdd( aFina040, { "E1_NATUREZ" , NBX->NBX_NATURE , Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VALOR"   , nValor          , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , NJR->NJR_MOEDA  , Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , nValor  , Nil } )
				aAdd( aFina040, { "E1_CCUSTO"  , Posicione("SB1",1,FwXFilial("SB1") + NJR->NJR_CODPRO ,"B1_CC") , Nil } )
				If "1,3" $ SuperGetMv("MV_ITMCLVL")
					aAdd( aFina040, { "E1_CLVL"    , NJR->NJR_CODSAF , Nil } )
				EndIf
				aAdd( aFina040, { "E1_HIST"    , cObserva        , Nil } )
				aAdd( aFina040, { "E1_ORIGEM"  , "OGA450"        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')), Nil } )

				//Cria ponto de entrada
				If ExistBlock("OG450NCC")
					aRetPeSE1 := ExecBlock("OG450NCC",.F.,.F.,{aFina040, cFilCtr + cCodCtr})
					If ValType( aRetPeSE1 ) == "A"
						aFina040 := aClone(aRetPeSE1)
					EndIf
				EndIf

				MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf

				If RecLock("NBX",.F.)
					NBX->NBX_FILNUM := FwXfilial('SE1')
					NBX->NBX_NUM    := cDoc
					NBX->NBX_PREFIX := cPrefixo
					NBX->NBX_PARCEL := cParcela
					NBX->NBX_TIPNUM   := "NCC"
					NBX->NBX_STATUS := "A"
					NBX->(MsUnLock())
				EndIf

			EndIf
		EndIf
		
		IF lNBX
			NBX->(DbCloseArea())
		EndIF
	EndIf

	NBX->(DbSetOrder(1))
	NBX->(DbGoTop())
	If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A3"   ) )
		NC8->(dbSetOrder(2)) //NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC
		If NC8->(DbSeek(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NCC", TamSX3("NC8_TPDOC")[1]) ))
			While NC8->(!Eof()) .and. ;
			(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NCC", TamSX3("NC8_TPDOC")[1]) ) == NC8->(NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC)
				If RecLock("NC8", .F.)
					Iif(cStAlc == 'R', NC8->NC8_STATUS := '1', NC8->NC8_STATUS := '2')
					NC8->(MsUnLock())
				EndIf
				NC8->(DbSkip())
				lRet := .T.
			EndDo
		EndIf
	EndIf

	If !lRet 
		Help( ,, STR0027,,STR0070, 1, 0 )  //"AJUDA",,Não foi possível realizar a geração do título NCC.
	EndIf

	RestArea(aAreaNBX)
	RestArea(aAreaNJR)
	RestArea(aAreaNC8)


Return lRet

/*/{Protheus.doc} A450GERNDC
	Função para gerar o titulo dos documentos do tipo A4. Chamado na função AGRXFUN1
	@type  Function
	@author marcelo ferrari / Filipe Olegini
	@since 23/07/2018
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function A450GERNDC(cFilCtr as char, cCodCtr as char, cDoc as char, cItem as char, nValor as Numeric, dVencto as Date, cObserva as char, cStAlc as char)
	Local aAreaNBX      as array
	Local aAreaNJR      as array
	Local aAreaNC8      as array
	Local cPrefixo      as char
	Local cParcela      as char
	Local lRet          as Logical
	Local lNBX          as logical
	Local cFilTit       as char

	Private lMsErroAuto as logical

	Default cItem := ""
	Default nValor := 0
	Default dVencto := dDataBase
	Default cObserva := ""
	Default cStAlc  := ""

	cFilTit     := FwXFilial("SE1")
	lRet        := .F.

	aAreaNBX    := NBX->(GetArea())
	aAreaNJR    := NJR->(GetArea())
	aAreaNC8    := NC8->(GetArea())

	lNBX := .F.
	//AGRXCOM8(cNumDoc, cTipDoc, cRecno)
	If FWISINCALLSTACK("AGRXCOM8")
		If SELECT("NBX") = 0
			DBSelectArea("NBX")
		EndIf
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A4"   ) )
			cItem  := NBX->NBX_ITEM
			nValor := NBX->NBX_VALOR
			dVencto := NBX->NBX_DATA
			cObserva := NBX->NBX_HISTOR
		Else
			MsgInfo(STR0047, STR0027 )     //"Não foi possivel abrir a tabela NBX para gravação"
			Return .F.
		EndIF
	EndIf

	cPrefixo    := SuperGetMV("MV_AGRO032", .F., "A4")
	cParcela    := StrZero(Val(cItem),2)

	lMsErroAuto := .F.

	NBX->(DbSetOrder(1)) //NBX_FILIAL+NBX_CODCTR+NBX_DOC+NBX_TIPO+NBX_ITEM
	If NBX->(DbSeek(xFilial("NBX") + cCodCtr + PadR(cDoc, TamSX3("NBX_DOC")[1] )+ "A4" + cItem ))

		N9A->(DbSetOrder(1))
		If N9A->(DbSeek(cFilCtr + cCodCtr + NBX->NBX_CODCAD + NBX->NBX_SEQPRI ))
			//coloca a filial conforme a regra fiscal
			cFilTit := N9A->N9A_FILORG
		endif

		If cStAlc == "A"
			NJR->(DbSetOrder(1))
			NJR->(DbSeek(cFilCtr+cCodCtr))

			//grava as variáveis e grava N8L
			aN8MVinc := {}
			aAdd( aN8MVinc, { "N8M_FILIAL"  , FwXfilial('N8M') 	} )
			aAdd( aN8MVinc, { "N8M_FILORI"  , iif(!empty(cFilTit),cFilTit,FwXfilial('N8M'))} ) //usa a mesma filial da N8L
			aAdd( aN8MVinc, { "N8M_PREFIX"  , cPrefixo          } ) //é Utilizado tipo de documento da alçada
			aAdd( aN8MVinc, { "N8M_NUM"     , cDoc              } ) //código do contrato
			aAdd( aN8MVinc, { "N8M_PARCEL"  , cParcela          } ) //usa parcela em BRANCO
			aAdd( aN8MVinc, { "N8M_TIPO"    , "NDC"		        } ) //Fixo NCC que é o tipo que está sendo gerado
			aAdd( aN8MVinc, { "N8M_CODCTR"  , cCodCtr           } )
			aAdd( aN8MVinc, { "N8M_CODSAF"  	, NJR->NJR_CODSAF	} )
			aAdd( aN8MVinc, { "N8M_FORNEC"  , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI")	} )
			aAdd( aN8MVinc, { "N8M_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI") } )
			aAdd( aN8MVinc, { "N8M_ORIGEM"  , "OGA450"			} )
			aAdd( aN8MVinc, { "N8M_HISTOR"  , cObserva			} )

			lRet := fAgrVncPag ({aN8MVinc}, 3 )  	//Incluir

			If lRet
				//gera titulo na SE1
				aFina040 := {}
				aAdd( aFina040, { "E1_FILIAL"  , FwXfilial('SE1'), Nil } )
				aAdd( aFina040, { "E1_PREFIXO" , cPrefixo        , Nil } )
				aAdd( aFina040, { "E1_NUM"     , cDoc            , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , cParcela        , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , "NDC"           , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI"), Nil } )
				aAdd( aFina040, { "E1_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI"), Nil } )
				aAdd( aFina040, { "E1_NATUREZ" , NBX->NBX_NATURE , Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VALOR"   , nValor          , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , NJR->NJR_MOEDA  , Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , nValor  , Nil } )
				aAdd( aFina040, { "E1_CCUSTO"  , Posicione("SB1",1,FwXFilial("SB1") + NJR->NJR_CODPRO ,"B1_CC") , Nil } )
				If "1,3" $ SuperGetMv("MV_ITMCLVL")
					aAdd( aFina040, { "E1_CLVL"    , NJR->NJR_CODSAF , Nil } )
				EndIf
				aAdd( aFina040, { "E1_HIST"    , cObserva        , Nil } )
				aAdd( aFina040, { "E1_ORIGEM"  , "OGA450"        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')), Nil } )

				//Cria ponto de entrada
				If ExistBlock("OG450NDC")
					aRetPeSE2 := ExecBlock("OG450NDC",.F.,.F.,{aFina040, cFilCtr + cCodCtr})
					If ValType( aRetPeSE2 ) == "A"
						aFina040 := aClone(aRetPeSE2)
					EndIf
				EndIf

				//ordena os arrays de acordo com o dicionário para passar para rotina automarica
				aFina040   := FWVetByDic(aFina040	, 'SE1', .F.)

				MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf

				If RecLock("NBX",.F.)
					NBX->NBX_FILNUM := FwXfilial('SE1')
					NBX->NBX_NUM    := cDoc
					NBX->NBX_PREFIX := cPrefixo
					NBX->NBX_PARCEL := cParcela
					NBX->NBX_TIPNUM := "NDC"
					NBX->NBX_STATUS := "A"
					NBX->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	IF lNBX
		NBX->(DbCloseArea())
	EndIF

	If lRet
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A4"   ) )
			NC8->(dbSetOrder(2)) //NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC
			If NC8->(DbSeek(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NDC", TamSX3("NC8_TPDOC")[1]) ))
				While NC8->(!Eof()) .and. ;
				(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NDC", TamSX3("NC8_TPDOC")[1]) ) == NC8->(NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC)
					If RecLock("NC8", .F.)
						Iif(cStAlc == 'R', NC8->NC8_STATUS := '1', NC8->NC8_STATUS := '2')
						NC8->(MsUnLock())
					EndIf
					NC8->(DbSkip())
					lRet := .t.
				EndDo
			EndIf
		EndIf
	EndIf

	If !lRet 
		Help( ,, STR0027,,STR0069, 1, 0 )  //"AJUDA",,Não foi possível realizar a geração do título NDC.
	EndIf

	RestArea(aAreaNBX)
	RestArea(aAreaNJR)
	RestArea(aAreaNC8)

Return lRet

/*{Protheus.doc} OGA450BNFC
	//Função de tela para gerar NF de complemento através de romaneios emitidos
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@see (links_or_references)
/*/
Function OGA450BNFC(cfilCtr as char, cCodCtr as char)
	Local lRet      as logical
	Local oSize     as object
	Local oDlg      as object
	Local oPnl1     as object
	Local oFWL      as object
	Local oPnlWnd1  as object
	Local oPnlWnd2  as object
	Local oPnlWnd3  as object
	Local oBrowse1  as object
	Local oBrowse2  as object
	Local oBrowse3  as object
	Local aCpsSt1   as array  //1 - estrutura de romaneios
	Local aCpsSt2   as array  //2 - estrutura de fixacoes
	Local aCpsSt3   as array  //3 - estrutura de previsoes
	Local aCpsBr1   as array
	Local aCpsBr2   as array
	Local aCpsBr3   as array
	Local aCoors    as array
	Local aRetTMP   as array
	Local nX        as numeric

	Private _oTmpBr1    as object
	Private _oTmpBr2    as object
	Private _oTmpBr3    as object
	Private _cAliasBr1  as char
	Private _cAliasBr2  as char
	Private _cAliasBr3  as char
	Private _aInd1      as array
	Private _aInd2      as array
	Private _aInd3      as array

	Private _nTotalFat  as numeric
	Private _nTotalQtd  as numeric
	Private _nSldPrev   as numeric
	Private _nCompFat   as numeric

	_nTotalFat    := 0
	_nTotalQtd    := 0
	_nSldPrev     := 0
	_nCompFat     := 0

	lRet        := .T.
	aRetTMP     := {}
	nX          := 0
	aCoors      := FWGetDialogSize(oMainWnd)
	oSize       := FWDefSize():New(.f.) //considerar o enchoice
	oFWL        := FWLayer():New()
	oBrowse1    := FWMBrowse():New() //1 - estrutura de romaneios
	oBrowse2    := FWMBrowse():New() //2 - estrutura de fixacoes
	oBrowse3    := FWMBrowse():New() //3 - estrutura de previsoes

	If Empty(Posicione("NJR",1,cfilCtr + cCodCtr ,"NJR_CODNGC"))
		Help( ,, STR0027,,STR0042, 1, 0 )  //"AJUDA",,"Seu sistema não está configurado para utilizar o conceito de comercialização através de novos negócios. favor utilizar as rotinas de contratos para registrar um negócio."
		Return .T.
	EndIf

	//tamanho da tela principal
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins  := {0,0,0,0}
	oSize:Process()

	//Monta a dialog
	oDlg    := TDialog():New(oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0032 + " "+ STR0028 + " " + AllTrim(cCodCtr), , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Gerar nota fiscal de complemento. Contrato Numero:
	oPnl1   := tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3]  /*enchoice bar*/)

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Topo - Romaneios
	oFWL:addLine( 'TOP', 35, .F.)
	oFWL:addCollumn( 'CENTER', 100, .F., 'TOP' )

	//Meio da tela - Fixaxoes e Previsoes
	oFWL:addLine( 'MIDDLE', 50, .F.)
	oFWL:addCollumn( 'LEFT', 50, .F., 'MIDDLE' )
	oFWL:addCollumn( 'RIGHT', 50, .F., 'MIDDLE' )

	oFWL:addLine( 'BOTTOM'   , 15 , .F.)
	oFWL:addCollumn( 'CENTER' ,100,.F., 'BOTTOM' )

	//Cria column split
	oFWL:setColSplit ( 'LEFT', 1, 'MIDDLE' )
	oFWL:setColSplit ( 'RIGHT', 2, 'MIDDLE' )

	//cria as janelas
	oFWL:addWindow('CENTER', 'Wnd1', STR0030, 100 /*tamanho*/, .F., .T.,, 'TOP' )	 //Romaneios emitidos
	oFWL:addWindow('LEFT'  , 'Wnd2', STR0039, 100 /*tamanho*/, .F., .T.,, 'MIDDLE' ) //fixações pendetes
	oFWL:addWindow('RIGHT' , 'Wnd3', STR0040, 100 /*tamanho*/, .F., .T.,, 'MIDDLE' ) //previsões pendentes
	oFWL:addWindow('CENTER', 'Wnd4', STR0049,  100 /*tamanho*/, .F., .T.,, 'BOTTOM' ) //totalizadores

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1    := oFWL:getWinPanel( 'CENTER', 'Wnd1', 'TOP' )
	oPnlWnd2    := oFWL:getWinPanel( 'LEFT'  , 'Wnd2', 'MIDDLE' )
	oPnlWnd3    := oFWL:getWinPanel( 'RIGHT' , 'Wnd3', 'MIDDLE' )
	oPnlWnd4    := oFWL:getWinPanel( 'CENTER', 'Wnd4', 'BOTTOM' )

	//--TELA DO ROMANEIO

	//Monta tela e temporária de romaneios
	aCpsSt1     := {{ "MARK"  ,"C"                         , 1                          , 0                           , "X"                     , "@!"                         },; //campo mark
	{ "FILIAL", TamSX3( "NJR_FILIAL" )[ 3 ], TamSX3( "NJR_FILIAL" )[ 1 ], TamSX3( "NJR_FILIAL" )[ 2 ] , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "CODROM", TamSX3( "NJM_CODROM" )[ 3 ], TamSX3( "NJM_CODROM" )[ 1 ], TamSX3( "NJM_CODROM" )[ 2 ] , RetTitle( "NJM_CODROM" ), PesqPict("NJM","NJM_CODROM") },;
	{ "ITEROM", TamSX3( "NJM_ITEROM" )[ 3 ], TamSX3( "NJM_ITEROM" )[ 1 ], TamSX3( "NJM_ITEROM" )[ 2 ] , RetTitle( "NJM_ITEROM" ), PesqPict("NJM","NJM_ITEROM") },;
	{ "ITEM"  , TamSX3( "NJM_ITEM"   )[ 3 ], TamSX3( "NJM_ITEM"   )[ 1 ], TamSX3( "NJM_ITEM"   )[ 2 ] , RetTitle( "NJM_ITEM"   ), PesqPict("NJM","NJM_ITEM"  ) },;
	{ "SEQPRI", TamSX3( "NJM_SEQPRI" )[ 3 ], TamSX3( "NJM_SEQPRI" )[ 1 ], TamSX3( "NJM_SEQPRI" )[ 2 ] , RetTitle( "NJM_SEQPRI" ), PesqPict("NJM","NJM_SEQPRI") },;
	{ "NFCNUM", TamSX3( "NJM_DOCNUM" )[ 3 ], TamSX3( "NJM_DOCNUM" )[ 1 ], TamSX3( "NJM_DOCNUM" )[ 2 ] , STR0034                 , PesqPict("NJM","NJM_DOCNUM") },;
	{ "NFCSER", TamSX3( "NJM_DOCSER" )[ 3 ], TamSX3( "NJM_DOCSER" )[ 1 ], TamSX3( "NJM_DOCSER" )[ 2 ] , STR0033                 , PesqPict("NJM","NJM_DOCSER") },;
	{ "VALNFC", TamSX3( "NJM_VLRTOT" )[ 3 ], TamSX3( "NJM_VLRTOT" )[ 1 ], TamSX3( "NJM_VLRTOT" )[ 2 ] , STR0031                 , PesqPict("NJM","NJM_VLRTOT") },;
	{ "DOCNUM", TamSX3( "NJM_DOCNUM" )[ 3 ], TamSX3( "NJM_DOCNUM" )[ 1 ], TamSX3( "NJM_DOCNUM" )[ 2 ] , RetTitle( "NJM_DOCNUM" ), PesqPict("NJM","NJM_DOCNUM") },;
	{ "DOCSER", TamSX3( "NJM_DOCSER" )[ 3 ], TamSX3( "NJM_DOCSER" )[ 1 ], TamSX3( "NJM_DOCSER" )[ 2 ] , RetTitle( "NJM_DOCSER" ), PesqPict("NJM","NJM_DOCSER") },;
	{ "VALDOC", TamSX3( "NJM_VLRTOT" )[ 3 ], TamSX3( "NJM_VLRTOT" )[ 1 ], TamSX3( "NJM_VLRTOT" )[ 2 ] , RetTitle( "NJM_VLRTOT" ), PesqPict("NJM","NJM_VLRTOT") },;
	{ "CODPRO", TamSX3( "NJM_CODPRO" )[ 3 ], TamSX3( "NJM_CODPRO" )[ 1 ], TamSX3( "NJM_CODPRO" )[ 2 ] , RetTitle( "NJM_CODPRO" ), PesqPict("NJM","NJM_CODPRO") },;
	{ "CODTES", TamSX3( "NJM_TES"    )[ 3 ], TamSX3( "NJM_TES"    )[ 1 ], TamSX3( "NJM_TES"    )[ 2 ] , RetTitle( "NJM_TES" )   , PesqPict("NJM","NJM_TES")    },;
	{ "QTDFCO", TamSX3( "NJM_QTDFCO" )[ 3 ], TamSX3( "NJM_QTDFCO" )[ 1 ], TamSX3( "NJM_QTDFCO" )[ 2 ] , RetTitle( "NJM_QTDFCO" ), PesqPict("NJM","NJM_QTDFCO") }}

	_aInd1     := { "FILIAL+CODROM+ITEROM+ITEM+SEQPRI+NFCNUM" } // Definição dos índices

	//--- Criação das tabelas temporárias ---//

	// Tabela temporária de romaneios
	aRetTMP := AGRCRIATRB( , aCpsSt1, _aInd1, FunName(), .T. )

	_oTmpbr1 	:= aRetTMP[3] //Nome do arquivo temporário
	_cAliasBr1 	:= aRetTMP[4] //Nome do alias do arquivo temporario
	aCpsBr1	    := aRetTMP[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	_aInd1	:= AGRINDICONS(_aInd1, aCpsBr1 )

	//carrega os dados de romaneios
	A450LoRoma(cfilCtr, cCodCtr)

	oBrowse1:SetAlias(_cAliasBr1)
	oBrowse1:DisableDetails()
	oBrowse1:SetMenuDef( "" )
	oBrowse1:DisableReport(.T.)
	oBrowse1:DisableSeek(.T.)
	oBrowse1:SetProfileID("AGA450NFC1")

	oBrowse1:AddMarkColumns( { || Iif(  (_cAliasBr1)->MARK = "1" ,"LBOK","LBNO" ) }, { || A450LoChk(cfilCtr, cCodCtr, _cAliasBr1, oBrowse1, oBrowse2, oBrowse3, oBrowse1:nAt)}, { || .T.  } )

	//pula os campos de mark e filial
	For nX := 3 To Len(aCpsSt1)

		oBrowse1:AddColumn( {aCpsSt1[nX][5],; //titulo
		&("{||"+aCpsSt1[nX][1]+"}") ,; //campo
		aCpsSt1[nX][2],; //tipo
		aCpsSt1[nX][6],; //picture
		1,;
		aCpsSt1[nX][3],; //tamanho
		aCpsSt1[nX][4],; //decimal
		.f.,,,{|| .T.}} )

	Next nX

	oBrowse1:Activate(oPnlWnd1)
	oBrowse1:GoColumn(1) //posiciona sempre na primeira coluna

	//---TELA DE FIXACOES

	//monta a tela de fixações
	aCpsSt2     := {{ "MARK"  ,"C"                         , 1                          , 0                           , "X"                     , "@!"                         },; //campo mark
	{ "FILIAL", TamSX3( "N8D_FILIAL" )[ 3 ], TamSX3( "N8D_FILIAL" )[ 1 ], TamSX3( "N8D_FILIAL" )[ 2 ] , RetTitle( "N8D_FILIAL" ), PesqPict("N8D","N8D_FILIAL") },;
	{ "CODCTR", TamSX3( "N8D_CODCTR" )[ 3 ], TamSX3( "N8D_CODCTR" )[ 1 ], TamSX3( "N8D_CODCTR" )[ 2 ] , RetTitle( "N8D_CODCTR" ), PesqPict("N8D","N8D_CODCTR") },;
	{ "DTINI" , TamSX3( "N9A_DATINI" )[ 3 ], TamSX3( "N9A_DATINI" )[ 1 ], TamSX3( "N9A_DATINI" )[ 2 ] , RetTitle( "N9A_DATINI" ), PesqPict("N9A","N9A_DATINI") },;
	{ "DTFIM" , TamSX3( "N9A_DATFIM" )[ 3 ], TamSX3( "N9A_DATFIM" )[ 1 ], TamSX3( "N9A_DATFIM" )[ 2 ] , RetTitle( "N9A_DATFIM" ), PesqPict("N9A","N9A_DATFIM") },;
	{ "ITEMFX", TamSX3( "N8D_ITEMFX" )[ 3 ], TamSX3( "N8D_ITEMFX" )[ 1 ], TamSX3( "N8D_ITEMFX" )[ 2 ] , RetTitle( "N8D_ITEMFX" ), PesqPict("N8D","N8D_ITEMFX") },;
	{ "CODCAD", TamSX3( "N8D_CODCAD" )[ 3 ], TamSX3( "N8D_CODCAD" )[ 1 ], TamSX3( "N8D_CODCAD" )[ 2 ] , RetTitle( "N8D_CODCAD" ), PesqPict("N8D","N8D_CODCAD") },;
	{ "REGRA" , TamSX3( "N8D_REGRA"  )[ 3 ], TamSX3( "N8D_REGRA"  )[ 1 ], TamSX3( "N8D_REGRA"  )[ 2 ] , RetTitle( "N8D_REGRA"  ), PesqPict("N8D","N8D_REGRA" ) },;
	{ "ORDEM" , TamSX3( "N8D_ORDEM"  )[ 3 ], TamSX3( "N8D_ORDEM"  )[ 1 ], TamSX3( "N8D_ORDEM"  )[ 2 ] , RetTitle( "N8D_ORDEM"  ), PesqPict("N8D","N8D_ORDEM" ) },;
	{ "QTDVNC", TamSX3( "N8D_QTDVNC" )[ 3 ], TamSX3( "N8D_QTDVNC" )[ 1 ], TamSX3( "N8D_QTDVNC" )[ 2 ] , RetTitle( "N8D_QTDVNC" ), PesqPict("N8D","N8D_QTDVNC") },;
	{ "QTDFAT", TamSX3( "N8D_QTDFAT" )[ 3 ], TamSX3( "N8D_QTDFAT" )[ 1 ], TamSX3( "N8D_QTDFAT" )[ 2 ] , RetTitle( "N8D_QTDFAT" ), PesqPict("N8D","N8D_QTDFAT") },;
	{ "DIFERE", TamSX3( "N8D_QTDFAT" )[ 3 ], TamSX3( "N8D_QTDFAT" )[ 1 ], TamSX3( "N8D_QTDFAT" )[ 2 ] , "Qtde Ajustar"          , PesqPict("N8D","N8D_QTDFAT") },;
	{ "VALOR" , TamSX3( "N8D_VALOR"  )[ 3 ], TamSX3( "N8D_VALOR"  )[ 1 ], TamSX3( "N8D_VALOR"  )[ 2 ] , RetTitle( "N8D_VALOR"  ), PesqPict("N8D","N8D_VALOR" ) }}

	_aInd2     := { "FILIAL+ITEMFX+CODCAD+REGRA+ORDEM" } // Definição dos índices

	//--- Criação das tabelas temporárias ---//

	// Tabela temporária de romaneios
	aRetTMP := AGRCRIATRB( , aCpsSt2, _aInd2, FunName(), .T. )

	_oTmpbr2 	:= aRetTMP[3] //Nome do arquivo temporário
	_cAliasBr2 	:= aRetTMP[4] //Nome do alias do arquivo temporario
	aCpsBr2	    := aRetTMP[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	_aInd2	:= AGRINDICONS(_aInd2, aCpsBr2 )

	oBrowse2:SetAlias(_cAliasBr2)
	oBrowse2:DisableDetails()
	oBrowse2:SetMenuDef( "" )
	oBrowse2:DisableReport(.T.)
	oBrowse2:DisableSeek(.T.)
	oBrowse2:SetProfileID("AGA450NFC2")

	oBrowse2:AddMarkColumns( { || Iif(  (_cAliasBr2)->MARK = "1" ,"LBOK","LBNO" ) }, { || A450Chk(_cAliasBr2, oBrowse2) }, { || .T.  } )

	//pula os campos de mark,filial e contrato
	For nX := 4 To Len(aCpsSt2)

		oBrowse2:AddColumn( {aCpsSt2[nX][5],; //titulo
		&("{||"+aCpsSt2[nX][1]+"}") ,; //campo
		aCpsSt2[nX][2],; //tipo
		aCpsSt2[nX][6],; //picture
		1,;
		aCpsSt2[nX][3],; //tamanho
		aCpsSt2[nX][4],; //decimal
		.f.,,,{|| .T.}} )

	Next nX

	oBrowse2:Activate(oPnlWnd2)

	//--- TELA DE PREVISOES

	//monta a tela de previões
	aCpsSt3     := {{ "MARK"  ,"C"                         , 1                          , 0                           , "X"                     , "@!"                         },; //campo mark
	{ "FILIAL", TamSX3( "NN7_FILIAL" )[ 3 ], TamSX3( "NN7_FILIAL" )[ 1 ], TamSX3( "NN7_FILIAL" )[ 2 ] , RetTitle( "NN7_FILIAL" ), PesqPict("NN7","NN7_FILIAL") },;
	{ "CODCTR", TamSX3( "NN7_CODCTR" )[ 3 ], TamSX3( "NN7_CODCTR" )[ 1 ], TamSX3( "NN7_CODCTR" )[ 2 ] , RetTitle( "NN7_CODCTR" ), PesqPict("NN7","NN7_CODCTR") },;
	{ "MESEMB", TamSX3( "NNY_MESEMB" )[ 3 ], TamSX3( "NNY_MESEMB" )[ 1 ], TamSX3( "NNY_MESEMB" )[ 2 ] , RetTitle( "NNY_MESEMB" ), PesqPict("NNY","NNY_MESEMB") },;
	{ "DATAV" , TamSX3( "NN7_DTVENC" )[ 3 ], TamSX3( "NN7_DTVENC" )[ 1 ], TamSX3( "NN7_DTVENC" )[ 2 ] , RetTitle( "NN7_DTVENC" ), PesqPict("NN7","NN7_DTVENC") },;
	{ "CODCAD", TamSX3( "N9J_ITEMPE" )[ 3 ], TamSX3( "N9J_ITEMPE" )[ 1 ], TamSX3( "N9J_ITEMPE" )[ 2 ] , RetTitle( "N9J_ITEMPE" ), PesqPict("N9J","N9J_ITEMPE") },;
	{ "REGRA" , TamSX3( "N8D_REGRA"  )[ 3 ], TamSX3( "N8D_REGRA"  )[ 1 ], TamSX3( "N8D_REGRA"  )[ 2 ] , RetTitle( "N8D_REGRA"  ), PesqPict("N8D","N8D_REGRA" ) },;
	{ "ITEM"  , TamSX3( "NN7_ITEM"   )[ 3 ], TamSX3( "NN7_ITEM"   )[ 1 ], TamSX3( "NN7_ITEM"   )[ 2 ] , RetTitle( "NN7_ITEM"   ), PesqPict("NN7","NN7_ITEM"  ) },;
	{ "PARCEL", TamSX3( "NN7_PARCEL" )[ 3 ], TamSX3( "NN7_PARCEL" )[ 1 ], TamSX3( "NN7_PARCEL" )[ 2 ] , RetTitle( "NN7_PARCEL" ), PesqPict("NN7","NN7_PARCEL") },;
	{ "VALOR" , TamSX3( "NN7_VALOR"  )[ 3 ], TamSX3( "NN7_VALOR"  )[ 1 ], TamSX3( "NN7_VALOR"  )[ 2 ] , RetTitle( "NN7_VALOR"  ), PesqPict("NN7","NN7_VALOR" ) },;
	{ "VLTEMI", TamSX3( "NN7_VLTEMI" )[ 3 ], TamSX3( "NN7_VLTEMI" )[ 1 ], TamSX3( "NN7_VLTEMI" )[ 2 ] , RetTitle( "NN7_VLTEMI" ), PesqPict("NN7","NN7_VLTEMI") },;
	{ "SALDO" , TamSX3( "NN7_VLSALD" )[ 3 ], TamSX3( "NN7_VLSALD" )[ 1 ], TamSX3( "NN7_VLSALD" )[ 2 ] , RetTitle( "NN7_VLSALD" ), PesqPict("NN7","NN7_VLSALD") }}

	_aInd3     := { "FILIAL+ITEM+PARCEL" } // Definição dos índices

	//--- Criação das tabelas temporárias ---//

	// Tabela temporária de romaneios
	aRetTMP := AGRCRIATRB( , aCpsSt3, _aInd3, FunName(), .T. )

	_oTmpbr3 	:= aRetTMP[3] //Nome do arquivo temporário
	_cAliasBr3 	:= aRetTMP[4] //Nome do alias do arquivo temporario
	aCpsBr3	    := aRetTMP[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	_aInd3	:= AGRINDICONS(_aInd3, aCpsBr3 )

	oBrowse3:SetAlias(_cAliasBr3)
	oBrowse3:DisableDetails()
	oBrowse3:SetMenuDef( "" )
	oBrowse3:DisableReport(.T.)
	oBrowse3:DisableSeek(.T.)
	oBrowse3:SetProfileID("AGA450NFC3")

	oBrowse3:AddMarkColumns( { || Iif(  (_cAliasBr3)->MARK = "1" ,"LBOK","LBNO" ) }, { || A450ChkBr3(_cAliasBr3, oBrowse3)}, { || .T.  } )

	//pula os campos de mark,filial e contrato
	For nX := 4 To Len(aCpsSt3)

		oBrowse3:AddColumn( {aCpsSt3[nX][5],; //titulo
		&("{||"+aCpsSt3[nX][1]+"}") ,; //campo
		aCpsSt3[nX][2],; //tipo
		aCpsSt3[nX][6],; //picture
		1,;
		aCpsSt3[nX][3],; //tamanho
		aCpsSt3[nX][4],; //decimal
		.f.,,,{|| .T.}} )

	Next nX

	oBrowse3:Activate(oPnlWnd3)

	/*************** Totais **************************/
	//- Recupera coordenadas
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject("Total",oPnlWnd4:NWIDTH,oPnlWnd4:NHEIGHT,.t.,.t.)
	oSize2:SetWindowSize({0,0,oPnlWnd4:NHEIGHT,oPnlWnd4:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()

	//cria os tamanhos máximos
	nSizeTot  := iif((oSize2:aWorkArea[3]/5) < 100, (oSize2:aWorkArea[3]/5), 100 ) //tamanho do campo

	//cria os campos de totais
	TSay():New(0,0,{||STR0050},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Total Faturado Contrato
	TGet():New(8,0,{|| _nTotalFat },oPnlWnd4,nSizeTot-7,010,'@E 999,999,999.99',,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	TSay():New(0,((oSize2:aWorkArea[3]/6)),{||STR0051},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Total Quant. Fat. Contrato
	TGet():New(8,((oSize2:aWorkArea[3]/6)),{||  _nTotalQtd },oPnlWnd4,nSizeTot-7,010,'@E 999,999,999.99',,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	TSay():New(0,((oSize2:aWorkArea[3]/6)*2),{||STR0052},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Total Previsão Marcadas
	TGet():New(8,((oSize2:aWorkArea[3]/6)*2),{|| _nSldPrev },oPnlWnd4,nSizeTot-7,010,'@E 999,999,999.99',,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	TSay():New(0,((oSize2:aWorkArea[3]/6)*3),{||STR0053},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Total Complementos Contrato
	TGet():New(8,((oSize2:aWorkArea[3]/6)*3),{||  _nCompFat },oPnlWnd4,nSizeTot-7,010,'@E 999,999,999.99',,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	//ativa todas as telas
	oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, {|| OGA450FOK(cfilCtr, cCodCtr), oBrowse1:Refresh(), oBrowse2:Refresh() ,oBrowse3:Refresh() } /*OK*/ , {|| oDlg:End() } /*Cancel*/ ) )

Return lRet

/*{Protheus.doc} A450LoRoma
	//Função para carregar os dados dos romaneios
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@see (links_or_references)
/*/
Static Function A450LoRoma(cfilCtr as char, cCodCtr as char)
	Local cQuery    as char
	Local cAliasQry as char

	cQuery    := ""
	cAliasQry := GetNextAlias()

	//deleta os registros
	dBSelectArea((_cAliasBr1))
	ZAP

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT NJM.NJM_FILIAL, NJM.NJM_CODCTR, NJM.NJM_CODROM, NJM.NJM_ITEROM, NJM.NJM_SEQPRI, NJM.NJM_CODENT, NJM.NJM_LOJENT, NJ0.NJ0_NOME,"
	cQuery += " NJM.NJM_CODPRO, NJM.NJM_TES, NJM.NJM_QTDFCO, NJM.NJM_DOCNUM, NJM.NJM_DOCSER, NJM.NJM_VLRTOT, "
	cQuery += " NKC.NKC_DOCTO, NKC.NKC_SERIE, NKC.NKC_VRTOT, NJM.NJM_ITEM, NJM.NJM_SEQPRI "
	cQuery += " FROM " + RetSqlName('NJM') + " NJM "
	cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON (NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND "
	cQuery +=                                              " NJJ.NJJ_CODCTR = NJM.NJM_CODCTR AND "
	cQuery +=                                              " NJJ.NJJ_CODROM = NJM.NJM_CODROM AND "
	cQuery +=                                              " NJJ.D_E_L_E_T_ = NJM.D_E_L_E_T_) "
	cQuery += " INNER JOIN " + RetSqlName('NJ0') + " NJ0 ON (NJ0.NJ0_CODENT = NJM.NJM_CODENT AND "
	cQuery +=                                              " NJ0.NJ0_LOJENT = NJM.NJM_LOJENT AND "
	cQuery +=                                              " NJ0.D_E_L_E_T_ = NJM.D_E_L_E_T_) "
	cQuery += " LEFT JOIN " + RetSqlName('NKC') + " NKC ON ( NKC.NKC_CODCTR = NJM.NJM_CODCTR AND "
	cQuery +=                                              " NKC.NKC_CODROM = NJM.NJM_CODROM AND "
	cQuery +=                                              " NKC.NKC_ITEROM = NJM.NJM_ITEROM AND "
	cQuery +=                                              " NKC.D_E_L_E_T_ = NJM.D_E_L_E_T_ ) "
	cQuery += " WHERE NJM.D_E_L_E_T_ = '' "
	cQuery += " AND NJM.NJM_FILORG = '" + cfilCtr + "' " //utiliza a filial do contrato
	cQuery += " AND NJM.NJM_CODCTR = '" + cCodCtr + "' "
	cQuery += " AND NJJ.NJJ_STATUS = '3' "
	cQuery += " AND NJJ.NJJ_TIPO IN ('4') "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If RecLock((_cAliasBr1),.T.)
			(_cAliasBr1)->MARK   := " "
			(_cAliasBr1)->FILIAL := (cAliasQry)->NJM_FILIAL
			(_cAliasBr1)->CODROM := (cAliasQry)->NJM_CODROM
			(_cAliasBr1)->ITEROM := (cAliasQry)->NJM_ITEROM
			(_cAliasBr1)->SEQPRI := (cAliasQry)->NJM_SEQPRI
			(_cAliasBr1)->ITEM   := (cAliasQry)->NJM_ITEM
			(_cAliasBr1)->CODPRO := (cAliasQry)->NJM_CODPRO
			(_cAliasBr1)->CODTES := (cAliasQry)->NJM_TES
			(_cAliasBr1)->QTDFCO := (cAliasQry)->NJM_QTDFCO
			(_cAliasBr1)->DOCNUM := (cAliasQry)->NJM_DOCNUM
			(_cAliasBr1)->DOCSER := (cAliasQry)->NJM_DOCSER
			(_cAliasBr1)->VALDOC := (cAliasQry)->NJM_VLRTOT
			(_cAliasBr1)->NFCNUM := (cAliasQry)->NKC_DOCTO
			(_cAliasBr1)->NFCSER := (cAliasQry)->NKC_SERIE
			(_cAliasBr1)->VALNFC := (cAliasQry)->NKC_VRTOT
			(_cAliasBr1)->(MsUnLock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return .T.

/*{Protheus.doc} A450LoFixa
	//Função para carregar os dados da temp da tela de Fixaxoes de acordo com os romaneios marcados
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da regra fiscal
	@param cSeqPri, sequencia da regra fiscal
	@see (links_or_references)
/*/
Static Function A450LoFixa(cfilCtr as char, cCodCtr as char, cItem as char, cSeqPri as char)
	Local cQuery    as char
	Local cAliasQry as char

	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT N8D.N8D_FILIAL, N8D.N8D_CODCTR, N8D.N8D_ITEMFX, N8D.N8D_ORDEM, "
	cQuery +=       "N8D.N8D_CODCAD, N8D.N8D_REGRA, N8D_QTDVNC, N8D_QTDFAT, N8D_VALOR,"
	cQuery +=       "N9A.N9A_DATINI, N9A.N9A_DATFIM "
	cQuery += " FROM " + RetSqlName('N8D') + " N8D"
	cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A ON ( "
	cQuery +=       " N8D.N8D_FILORG = N9A.N9A_FILIAL AND "
	cQuery +=       " N8D.N8D_CODCTR = N9A.N9A_CODCTR AND "
	cQuery +=       " N8D.N8D_ITEMFX = N9A.N9A_ITEM AND "
	cQuery +=       " N9A.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE N8D.D_E_L_E_T_ = '' "
	cQuery += " AND N8D_FILIAL = '" + cfilCtr + "' "
	cQuery += " AND N8D_CODCTR = '" + cCodCtr + "' "
	cQuery += " AND N8D_CODCAD = '" + cItem + "' "
	cQuery += " AND N8D_REGRA  = '" + cSeqPri + "' "
	cQuery += " AND N8D_QTDVNC <> N8D_QTDFAT "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If RecLock((_cAliasBr2),.T.)
			(_cAliasBr2)->MARK   := "1"
			(_cAliasBr2)->FILIAL := (cAliasQry)->N8D_FILIAL
			(_cAliasBr2)->CODCTR := (cAliasQry)->N8D_CODCTR
			(_cAliasBr2)->DTINI  := STOD((cAliasQry)->N9A_DATINI)
			(_cAliasBr2)->DTFIM  := STOD((cAliasQry)->N9A_DATFIM)
			(_cAliasBr2)->ITEMFX := (cAliasQry)->N8D_ITEMFX
			(_cAliasBr2)->CODCAD := (cAliasQry)->N8D_CODCAD
			(_cAliasBr2)->REGRA  := (cAliasQry)->N8D_REGRA
			(_cAliasBr2)->ORDEM  := (cAliasQry)->N8D_ORDEM
			(_cAliasBr2)->QTDVNC := (cAliasQry)->N8D_QTDVNC
			(_cAliasBr2)->QTDFAT := (cAliasQry)->N8D_QTDFAT
			(_cAliasBr2)->DIFERE := (cAliasQry)->N8D_QTDVNC - (cAliasQry)->N8D_QTDFAT
			(_cAliasBr2)->VALOR  := (cAliasQry)->N8D_VALOR
			(_cAliasBr2)->(MsUnLock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return .T.

/*{Protheus.doc} A450LoPrev
	//Função para carregar os dados da temp da tela de PRevisoes de acordo com o browser marcado
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da regra fiscal
	@param cSeqPri, sequencia da regra fiscal
	@see (links_or_references)
/*/
Static Function A450LoPrev(cfilCtr as char, cCodCtr as char, cItem as char, cSeqPri as char)
	Local cQuery    as char
	Local cAliasQry as char

	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT NN7.NN7_FILIAL,NN7.NN7_CODCTR,NN7.NN7_ITEM,NN7.NN7_PARCEL,N9J.N9J_ITEMPE,N9J.N9J_ITEMRF,"
	cQuery +=        " NN7.NN7_DTVENC,NN7.NN7_VALOR,NN7.NN7_VLTEMI,NN7.NN7_VLSALD, NNY.NNY_MESEMB  "
	cQuery +=   " FROM " + RetSqlName('NN7') + " NN7 "
	cQuery +=  " INNER JOIN " + RetSqlName('N9J') + " N9J ON (N9J.N9J_FILIAL = NN7.NN7_FILIAL AND "
	cQuery +=                                               " N9J.N9J_CODCTR = NN7.NN7_CODCTR AND "
	cQuery +=                                               " N9J.N9J_SEQPF = NN7.NN7_ITEM AND "
	cQuery +=                                               " N9J.D_E_L_E_T_ = NN7.D_E_L_E_T_) "
	cQuery +=  "  INNER JOIN " + RetSqlName('NNY') + " NNY ON (NNY.NNY_FILIAL = NN7.NN7_FILIAL AND "
	cQuery +=                                               " NNY.NNY_CODCTR = NN7.NN7_CODCTR AND "
	cQuery +=                                               " NNY.NNY_ITEM = N9J.N9J_ITEMPE AND "
	cQuery +=                                               " NNY.D_E_L_E_T_ = ' ')"
	cQuery +=  " WHERE NN7.D_E_L_E_T_ = '' "
	cQuery +=    " AND NN7.NN7_FILIAL = '" + cfilCtr + "' "
	cQuery +=    " AND NN7.NN7_CODCTR = '" + cCodCtr + "' "
	cQuery +=    " AND N9J.N9J_ITEMPE = '" + cItem + "' "
	cQuery +=    " AND N9J.N9J_ITEMRF = '" + cSeqPri + "' "
	cQuery +=    " AND NN7.NN7_VLSALD > 0 "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If RecLock((_cAliasBr3),.T.)
			(_cAliasBr3)->MARK   := "1"
			(_cAliasBr3)->FILIAL := (cAliasQry)->NN7_FILIAL
			(_cAliasBr3)->CODCTR := (cAliasQry)->NN7_CODCTR
			(_cAliasBr3)->CODCAD := (cAliasQry)->N9J_ITEMPE
			(_cAliasBr3)->MESEMB := (cAliasQry)->NNY_MESEMB
			(_cAliasBr3)->REGRA  := (cAliasQry)->N9J_ITEMRF
			(_cAliasBr3)->ITEM   := (cAliasQry)->NN7_ITEM
			(_cAliasBr3)->PARCEL := (cAliasQry)->NN7_PARCEL
			(_cAliasBr3)->DATAV  := StoD((cAliasQry)->NN7_DTVENC)
			(_cAliasBr3)->VALOR  := (cAliasQry)->NN7_VALOR
			(_cAliasBr3)->VLTEMI := (cAliasQry)->NN7_VLTEMI
			(_cAliasBr3)->SALDO  := (cAliasQry)->NN7_VLSALD
			(_cAliasBr3)->(MsUnLock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	Return .T.

/*{Protheus.doc} A450LoChk
	//Função chamada no mark do browser 1 que faz o load das temporarias de fixacao e previsao e atualiza os browser delas
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cAliasAtu, char, alias da tabela que será atualizado
	@param oBro1Refr, objeto, objeto do browser que será atualizado
	@param oBro2Refr, objeto, objeto do browser que será atualizado
	@param oBro3Refr, objeto, objeto do browser que será atualizado
	@param nLinha, numerico, numero da linha do browser 1 para ser posicionada
	@see (links_or_references)
/*/
Static Function A450LoChk(cfilCtr as char, cCodCtr as char, cAliasAtu as char, oBro1Refr as object, oBro2Refr as object, oBro3Refr as object, nLinha as numeric)
	Local aAreaAtu  as array
	Local aRegra    as array
	Local nPos      as numeric
	Local nX        as numeric

	aAreaAtu :=  (cAliasAtu)->(GetArea())
	aRegra   := {}

	//atualiza o browser marcado
	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif

	//busca as regras para trazer os dados das previsões e fixaçoes
	(cAliasAtu)->(DbGoTop())
	While (cAliasAtu)->(!EOF())
		//somente os marcados
		If (cAliasAtu)->MARK == "1"
			nPos := aScan(aRegra, {|x| AllTrim(x[1]) == AllTrim((cAliasAtu)->ITEM) .AND.;
			AllTrim(x[2]) == AllTrim((cAliasAtu)->SEQPRI) } )
			If nPos = 0
				aAdd(aRegra, {(cAliasAtu)->ITEM, (cAliasAtu)->SEQPRI})
			EndIf

		EndIf

		(cAliasAtu)->(DbSkip())
	EndDo

	////deleta os registros
	dBSelectArea((_cAliasBr2))
	ZAP

	dBSelectArea((_cAliasBr3))
	ZAP

	_nCompFat   := 0
	_nSldPrev   := 0
	_nTotalFat  := 0
	_nTotalQtd  := 0

	For nX := 1 To Len(aRegra)

		//busca fixacoes
		A450LoFixa(cfilCtr, cCodCtr, aRegra[nX][1], aRegra[nX][2])

		//busca previsoes
		A450LoPrev(cfilCtr, cCodCtr, aRegra[nX][1], aRegra[nX][2])

	Next

	//*********************************
	//Atualiza campos totalizadores
	//*********************************

	//Total Faturado / Complemento de nota
	(_cAliasBr1)->(DbGoTop())
	While (_cAliasBr1)->(!Eof())
		If (_cAliasBr1)->MARK == '1'
			_nTotalFat  += (_cAliasBr1)->VALDOC
			_nCompFat  += (_cAliasBr1)->VALNFC
		EndIf
		(_cAliasBr1)->(DbSkip())

	EndDo

	//Total de quantidade faturada
	(_cAliasBr2)->(DbGoTop())
	While (_cAliasBr2)->(!Eof())
		_nTotalQtd  += (_cAliasBr2)->QTDFAT
		(_cAliasBr2)->(DbSkip())

	EndDo

	//Total do saldo das previsões
	(_cAliasBr3)->(DbGoTop())
	While (_cAliasBr3)->(!Eof())
		_nSldPrev  += (_cAliasBr3)->SALDO
		(_cAliasBr3)->(DbSkip())

	EndDo

	RestArea(aAreaAtu)

	//atualiza o browser de fixaxao e previsao
	oBro2Refr:UpdateBrowse()
	oBro3Refr:UpdateBrowse()

	//atualiza o browser de romaneios
	oBro1Refr:UpdateBrowse()
	oBro1Refr:SetFocus()
	oBro1Refr:GoColumn(1) //posiciona sempre na primeira coluna
	oBro1Refr:GoTo(nLinha) //volta pra linha que estava antes de fazer o while na temp

Return .T.

/*/{Protheus.doc} A450ChkBr3
	//Função para atualizar totais conforme marca/desmarca
	@type  Static Function
	@author mauricio.joao
	@since 31/07/2018
	@param cAliasAtu, char, alias da tabela que será atualizada
	@param oBroRefr, objeto, objeto do browser que será atualizado
	@see (links_or_references)
/*/
Static Function A450ChkBr3(cAliasAtu as char, oBroRefr as object)

	aAreaBr3    := (_cAliasBr3)->(GetArea())

	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif

	_nSldPrev := 0

	//Total do saldo das previsões
	(cAliasAtu)->(DbGoTop())
	While (cAliasAtu)->(!Eof())
		If (cAliasAtu)->MARK == '1'
			_nSldPrev  += (cAliasAtu)->SALDO

		EndIf
		(cAliasAtu)->(DbSkip())

	EndDo

	//testa e atualiza o browser
	If Type("oBroRefr") <> "U"
		oBroRefr:UpdateBrowse()
	EndIf

	RestArea(aAreaBr3)

Return .T.

/*/{Protheus.doc} A450Chk
	//Função marcar e desmarcar apenas
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cAliasAtu, char, alias da tabela que será atualizada
	@param oBroRefr, objeto, objeto do browser que será atualizado
	@see (links_or_references)
/*/
Static Function A450Chk(cAliasAtu as char, oBroRefr as object)

	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif		

    //testa e atualiza o browser
    If Type("oBroRefr") <> "U"
        oBroRefr:UpdateBrowse()
    EndIf
	

Return .T.

/*/{Protheus.doc} OGA450FOK
	Função que faz as validações e chama as funções para atualização e geração de NF de complemento
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@see (links_or_references)
/*/
Static Function OGA450FOK(cfilCtr as char, cCodCtr as char)
	Local lRet      as logical
	Local aAreaBr1  as array
	Local aAreaBr2  as array
	Local aAreaBr3  as array
	Local aRegraFis as array
	Local aRomaneio as array
	Local aFixacoes as array
	Local aPrevisao as array
	Local nPos      as numeric
	Local nPos2     as numeric	
	Local cTipo     as char
	Local nValor    as numeric
	Local aRet      as array
	Local cSerieOR  as char
	Local aItensNKC as array
	Local nReg      as numeric
	Local nRom      as numeric
	Local nFix      as numeric
	Local nPre      as numeric
	Local aVincNKC  as array

	lRet        := .T.
	aAreaBr1    := (_cAliasBr1)->(GetArea())
	aAreaBr2    := (_cAliasBr2)->(GetArea())
	aAreaBr3    := (_cAliasBr3)->(GetArea())
	cTipo       := "1" // fix 1  - somente valor
	cSerieOR    := GetNewPar("MV_OGASERS","1")
	aItensNKC   := {}
	aVincNKC    := {}

	//verifica se nao foi carregado o parametro - trata fora da função devido ao usa da trasação
	If Empty(cSerieOR)
		If !SX5NumNota(@cSerieOR, GetNewPar("MV_OGASERS","1") )
			Return .F.
		EndIf
	EndIf

	//Pega os romaneios marcados e isola por regra fiscal
	aRegraFis := {}

	(_cAliasBr1)->(DbGoTop())
	While (_cAliasBr1)->(!EOF())

		If (_cAliasBr1)->MARK == "1"
			//para cada regra fiscal ele pega as previsoes e fixacoes
			nPos := aScan(aRegraFis, {|x| AllTrim(x[1]) == AllTrim((_cAliasBr1)->ITEM) .AND.;
			AllTrim(x[2]) == AllTrim((_cAliasBr1)->SEQPRI) } )
			If nPos = 0

				//zera a variavel incluir nova regra fiscal
				aFixacoes := {}
				aPrevisao := {}
				aRomaneio := {}

				//para cada regra fiscal busca as tabelas dependentes
				(_cAliasBr2)->(DbGoTop())
				While (_cAliasBr2)->(!EOF())

					If (_cAliasBr2)->MARK   == "1" .AND.;
					(_cAliasBr2)->CODCAD == (_cAliasBr1)->ITEM .AND.;
					(_cAliasBr2)->REGRA  == (_cAliasBr1)->SEQPRI

						aAdd(aFixacoes,{(_cAliasBr2)->FILIAL, (_cAliasBr2)->CODCTR, (_cAliasBr2)->ITEMFX,;
						(_cAliasBr2)->CODCAD, (_cAliasBr2)->REGRA,  (_cAliasBr2)->ORDEM ,;
						(_cAliasBr2)->QTDVNC, (_cAliasBr2)->QTDFAT, (_cAliasBr2)->DIFERE,;
						(_cAliasBr2)->VALOR})
					EndIf

					(_cAliasBr2)->(DbSkip())
				EndDo

				(_cAliasBr3)->(DbGoTop())
				While (_cAliasBr3)->(!EOF())

					If (_cAliasBr3)->MARK   == "1" .AND.;
					(_cAliasBr3)->CODCAD == (_cAliasBr1)->ITEM .AND.;
					(_cAliasBr3)->REGRA  == (_cAliasBr1)->SEQPRI

						aAdd(aPrevisao,{(_cAliasBr3)->FILIAL, (_cAliasBr3)->CODCTR, (_cAliasBr3)->CODCAD,;
						(_cAliasBr3)->REGRA,  (_cAliasBr3)->ITEM,   (_cAliasBr3)->PARCEL,;
						(_cAliasBr3)->DATAV,  (_cAliasBr3)->VALOR,  (_cAliasBr3)->VLTEMI,;
						(_cAliasBr3)->SALDO })
					EndIf

					(_cAliasBr3)->(DbSkip())
				EndDo

				aAdd(aRomaneio, {(_cAliasBr1)->FILIAL, (_cAliasBr1)->CODROM, (_cAliasBr1)->ITEROM,;
				(_cAliasBr1)->ITEM  , (_cAliasBr1)->SEQPRI, (_cAliasBr1)->NFCNUM,;
				(_cAliasBr1)->NFCSER, (_cAliasBr1)->VALNFC, (_cAliasBr1)->DOCNUM,;
				(_cAliasBr1)->DOCSER, (_cAliasBr1)->VALDOC, (_cAliasBr1)->CODPRO,;
				(_cAliasBr1)->CODTES, (_cAliasBr1)->QTDFCO })

				//adiciona em um array as 3 tabelas
				aAdd(aRegraFis,{(_cAliasBr1)->ITEM, (_cAliasBr1)->SEQPRI, aRomaneio, aFixacoes, aPrevisao })

			Else
				//incrementa os romaneios
				nPos2 := aScan(aRegraFis[nPos][3], {|x| AllTrim(x[2]) == AllTrim((_cAliasBr1)->CODROM) } )
				If nPos2 = 0

					aAdd(aRegraFis[nPos][3], {(_cAliasBr1)->FILIAL, (_cAliasBr1)->CODROM, (_cAliasBr1)->ITEROM,;
					(_cAliasBr1)->ITEM  , (_cAliasBr1)->SEQPRI, (_cAliasBr1)->NFCNUM,;
					(_cAliasBr1)->NFCSER, (_cAliasBr1)->VALNFC, (_cAliasBr1)->DOCNUM,;
					(_cAliasBr1)->DOCSER, (_cAliasBr1)->VALDOC, (_cAliasBr1)->CODPRO,;
					(_cAliasBr1)->CODTES, (_cAliasBr1)->QTDFCO })
				EndIf
			EndIf

		EndIf

		(_cAliasBr1)->(DbSkip())
	EndDo

	If Len(aRegraFis[1][3]) == 0 /*.OR.;
	Len(aRegraFis[1][4]) == 0 .OR.;
	Len(aRegraFis[1][5]) == 0 */

		MsgInfo(STR0029) //Nenhum romaneio foi selecionado
		Return .F.
	EndIf

	//para cada regra fiscal gera uma NF de complemento
	For nReg := 1 To Len(aRegraFis)

		//Trata o botao com transaction devido aos ajustes realizados
		Begin Transaction

			//valor da NF de complemento
			nValor    := 0
			aItensNKC := {}

			//busca o valor para esta regra fiscal - soma do saldo da NN7
			For nPre := 1 To Len(aRegraFis[nReg][5]) //indice 5 é array de previsão financeia
				nValor += aRegraFis[nReg][5][nPre][10]

				//Realiza o ajuste na tabela NN7 zerando o saldo
				OGA450ANN7(aRegraFis[nReg][5][nPre][1], aRegraFis[nReg][5][nPre][2], aRegraFis[nReg][5][nPre][5], aRegraFis[nReg][5][nPre][10])

			Next

			If nValor <= 0

				nValor := OGA450INFC() //busca valor informado

				If nValor <= 0
					DisarmTransaction()
					Help('',1, "OGA450SEMVL")
					lRet := .F.
				EndIf

			EndIf

			//Realiza o ajuste nas tabela de fixação
			For nFix := 1 To Len(aRegraFis[nReg][4]) //indice 4 é array de fixacoes
				OGA450AN8D(aRegraFis[nReg][4][nFix][1], aRegraFis[nReg][4][nFix][2], aRegraFis[nReg][4][nFix][6], aRegraFis[nReg][4][nFix][3])
			Next

			// monta o array da tabela NKC onde fica o vinculo do romaneio com fixacao usada, utiliza apenas 1 fixação
			For nRom := 1 To Len(aRegraFis[nReg][3]) //indice 3 é array de Romaneios
				//Registra os vinculos com a NKC para cada fixacao para controlar os estornos

				If Len(aRegraFis[nReg][4]) >0
					For nFix := 1 To Len(aRegraFis[nReg][4]) //indice 4 é array de fixacoes
						aVincNKC := {}
						aAdd( aVincNKC, { "NKC_FILIAL", aRegraFis[nReg][3][nRom][1] } )
						aAdd( aVincNKC, { "NKC_CODCTR", cCodCtr                     } )
						aAdd( aVincNKC, { "NKC_ITEMFX", aRegraFis[nReg][4][nFix][3] } )
						aAdd( aVincNKC, { "NKC_CODROM", aRegraFis[nReg][3][nRom][2] } )
						aAdd( aVincNKC, { "NKC_ITEROM", aRegraFis[nReg][3][nRom][3] } )
						aAdd( aVincNKC, { "NKC_ITEM  ", 0                           } )
						aAdd( aVincNKC, { "NKC_SERIE ", ""                          } )
						aAdd( aVincNKC, { "NKC_DOCTO ", ""                          } )
						aAdd( aVincNKC, { "NKC_PREFIX", ""                          } )
						aAdd( aVincNKC, { "NKC_FORMUL", ""                          } )
						aAdd( aVincNKC, { "NKC_QTD   ", Round(aRegraFis[nReg][4][nFix][9] / Len(aRegraFis[nReg][3]),2) } )
						aAdd( aVincNKC, { "NKC_VRUN	 ", aRegraFis[nReg][4][nFix][10]} ) // valor utilizado na fixação
						aAdd( aVincNKC, { "NKC_VRTOT ", nValor / Len(aRegraFis[nReg][3]) } ) // média do valor das previsões pela quantidade de romaneios
						aAdd( aVincNKC, { "NKC_VRIMP ", 0                           } )
						aAdd( aVincNKC, { "NKC_DATA	 ", ""                          } )
						aAdd( aVincNKC, { "NKC_TPDOC ", ""                          } )
						aAdd( aVincNKC, { "NKC_PEDIDO", ""                          } )
						aAdd( aVincNKC, { "NKC_FORCLI", ""                          } )
						aAdd( aVincNKC, { "NKC_LOJA  ", ""                          } )
						aAdd(aItensNKC, aVincNKC)
					Next
				Else
					aVincNKC := {}
					aAdd( aVincNKC, { "NKC_FILIAL", aRegraFis[nReg][3][nRom][1] } )
					aAdd( aVincNKC, { "NKC_CODCTR", cCodCtr                     } )
					aAdd( aVincNKC, { "NKC_ITEMFX", ""                          } )
					aAdd( aVincNKC, { "NKC_CODROM", aRegraFis[nReg][3][nRom][2] } )
					aAdd( aVincNKC, { "NKC_ITEROM", aRegraFis[nReg][3][nRom][3] } )
					aAdd( aVincNKC, { "NKC_ITEM  ", 0                           } )
					aAdd( aVincNKC, { "NKC_SERIE ", ""                          } )
					aAdd( aVincNKC, { "NKC_DOCTO ", ""                          } )
					aAdd( aVincNKC, { "NKC_PREFIX", ""                          } )
					aAdd( aVincNKC, { "NKC_FORMUL", ""                          } )
					aAdd( aVincNKC, { "NKC_QTD   ", 0                           } )
					aAdd( aVincNKC, { "NKC_VRUN	 ", 0                           } ) // valor utilizado na fixação
					aAdd( aVincNKC, { "NKC_VRTOT ", nValor / Len(aRegraFis[nReg][3]) } ) // média do valor das previsões pela quantidade de romaneios
					aAdd( aVincNKC, { "NKC_VRIMP ", 0                           } )
					aAdd( aVincNKC, { "NKC_DATA	 ", ""                          } )
					aAdd( aVincNKC, { "NKC_TPDOC ", ""                          } )
					aAdd( aVincNKC, { "NKC_PEDIDO", ""                          } )
					aAdd( aVincNKC, { "NKC_FORCLI", ""                          } )
					aAdd( aVincNKC, { "NKC_LOJA  ", ""                          } )
					aAdd(aItensNKC, aVincNKC)
				EndIf
			Next

			//se nao houve erro anteriormente
			If lRet
				//chama a rotina para criar o pedido e NF apenas para o primeiro  romaneio
				MsgRun( STR0035, STR0036, {|| aRet := OGX008ACPL(aRegraFis[nReg][3][1][1], aRegraFis[nReg][3][1][2], aRegraFis[nReg][3][1][3], cSerieOR, cTipo, nValor, aItensNKC) } ) //"Gerando NF de Complemento." //"Gestão de Entidades"

				If !aRet[1]
					DisarmTransaction()
					MsgInfo(aRet[2])
					lRet := .F.
				EndIf
			EndIf

			//ajusta o valor faturado
			NJR->(dbSetOrder(1))
			If NJR->(dbSeek(cfilCtr + cCodCtr))
				If RecLock("NJR",.F.)
					NJR->NJR_TOTN9K += nValor
				EndIf
			EndIf

		End Transaction

	Next

	//Chama no final para ajustar o contrato de uma unica vez - Performance
	If lRet

		//ajusta a NN7 X SE1
		OGX018ATPR(cfilCtr, cCodCtr, "OGA450")

		MsgInfo(STR0041)

		//recarrega a tela
		A450LoRoma(cfilCtr, cCodCtr)

		//Limpa as tabelas
		dBSelectArea((_cAliasBr2))
		ZAP

		dBSelectArea((_cAliasBr3))
		ZAP

	EndIf

	RestArea(aAreaBr3)
	RestArea(aAreaBr2)
	RestArea(aAreaBr1)

Return lRet

/*/{Protheus.doc} OGA450ANN7
	Função para atualizar o saldo da NN7
	@type  Static Function
	@author filipe.olegini
	@since 17/07/2018
	@param cFilNN7, char, Filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da sequencia da NN7
	@param nValorBx, numeric, valor para baixar na NN7
	@see (links_or_references)
/*/
Static Function OGA450ANN7(cFilNN7 as char, cCodCtr as char, cItem, nValorBx as numeric )
	Local aAreaNN7  as array

	aAreaNN7 := NN7->(GetArea())

	NN7->(dbSetOrder(1)) //NN7_FILIAL+NN7_CODCTR+NN7_ITEM
	If NN7->(dbSeek(cFilNN7 + cCodCtr + cItem))
		If RecLock("NN7",.F.)
			NN7->NN7_VLTEMI += nValorBx
			NN7->NN7_VLTNCO += nValorBx
			NN7->NN7_VLSALD := 0
			NN7->NN7_STSTIT := "2"
			NN7->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaNN7)

Return .T.

/*/{Protheus.doc} OGA450AN8D
	Função para atualizar o saldo da N8D e NN8
	@type  Static Function
	@author filipe.olegini
	@since 17/07/2018
	@param cFilFix, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cOrdem, char, codigo da ordem da N8D
	@param cItemFix, char, código da fixacao da NN8
	@see (links_or_references)
/*/
Static Function OGA450AN8D(cFilFix as char, cCodCtr as char, cOrdem as char, cItemFix as char )
	Local aAreaN8D  as array
	Local aAreaNN8  as array

	aAreaN8D    := N8D->(GetArea())
	aAreaNN8    := NN8->(GetArea())

	//consome as quantidades totais da N8D
	N8D->(dbSetOrder(1) )//N8D_FILIAL+N8D_CODCTR+N8D_ORDEM
	If N8D->(dbSeek(cFilFix + cCodCtr + cOrdem))
		If RecLock("N8D",.F.)
			N8D->N8D_QTDFAT := N8D->N8D_QTDVNC
			N8D->(MsUnLock())
		EndIf
	EndIf

	//consome as quantidades totais da NN8
	NN8->(dbSetOrder(1)) //NN8_FILIAL+NN8_CODCTR+NN8_ITEMFX
	If NN8->(dbSeek(cFilFix + cCodCtr + cItemFix))
		If RecLock("NN8",.F.)
			NN8->NN8_QTDENT := NN8->NN8_QTDFIX
			NN8->(MsUnLock())
		Endif
	EndIf

	RestArea(aAreaNN8)
	RestArea(aAreaN8D)

Return .T.

/*{Protheus.doc} OGA450INFC
//Função que exibe a tela com os dados do romaneio e o usuário informa o valor para gerar o complemento de preço
@type  Function
@author filipe.olegini
@since 16/07/2018
@version 1.0
@type function
*/
Function OGA450INFC()
	Local aArea         := GetArea()
	Local oSize         := Nil
	Local oMStru        := FwFormModelStruct():New()
	Local oVStru        := FwFormViewStruct():New()
	Local oModel        := FwFormModel():New("OGA450CPAR", , , {|| .T.}, {|| .T.}) // Instancia um modelo
	Local oView         := FwFormView():New() // Instancia uma View
	Local oViewExec     := FWViewExec():New() // Instancia um Executor de View
	Local nWidth        := 0
	Local nHeight       := 0
	Local nValor        := 0
	Local bInit         := {|| 0 }
	Local aButtons 	    := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0037},{.T., STR0038},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Confirmar" # "Cancelar"

	oSize   := FwDefSize():New(.T.) // Considera a enchoice bar

	nWidth  := (oSize:AWINDSIZE[4] * 0.15) // 15% da largura total da tela
	nHeight := (oSize:AWINDSIZE[3] * 0.15) // 15% da altura total da tela

	oMStru:AddField(STR0031	                            ,;  	// [01] C Titulo do campo // # "Valor NF COMPL
	STR0031	                            ,;   	// [02] C ToolTip do campo // # "Valor NF COMPL
	"VALORPARC" 		                ,;    	// [03] C identificador (ID) do Field
	TamSX3("E1_VALOR" )[3] 		        ,;    	// [04] C Tipo do campo
	TamSX3("E1_VALOR" )[1] 			    ,;    	// [05] N Tamanho do campo
	TamSX3("E1_VALOR" )[2] 		        ,;    	// [06] N Decimal do campo
	Nil                                 ,;    	// [07] B Code-block de validacao do campo
	Nil					                ,;     	// [08] B Code-block de validacao When do campo
	Nil 				                ,;    	// [09] A Lista de valores permitido do campo
	.T. 				                ,;  	// [10] L Indica se o campo tem preenchimento obrigatorio
	bInit		                        ,;   	// [11] B Code-block de inicializacao do campo
	Nil 				                ,;  	// [12] L Indica se trata de um campo chave
	.T. )    	                                // [13] L Indica se o campo pode receber valor em uma operacaoo de update.

	oVStru:AddField("VALORPARC"	                        ,;  	// [01] C Id do Campo
	"01"	                            ,;   	// [02] C Ordem
	STR0031 		                    ,;    	// [03] C Titulo do campo // # "Valor NF COMPL
	STR0031                         	,;    	// [04] C Descrição do campo // # "Valor NF COMPL
	{STR0031} 	                        ,;    	// [05] A Array com Help // # "Valor NF COMPL
	TamSX3("E1_VALOR" )[3] 				,;    	// [06] C Tipo do campo
	PesqPict("SE1","E1_VALOR") 		    ,;    	// [07] C Picture
	Nil					                ,;     	// [08] B Bloco de Picture Var
	Nil 				                ,;    	// [09] C Consulta F3
	.T. 				                ,;  	// [10] L Indica se o campo é evitável
	Nil		                            ,;   	// [11] C Pasta do campo
	Nil 				                ,;  	// [12] C Agrupamento do campo
	Nil 				                ,;     	// [13] A Lista de valores permitido do campo (Combo)
	Nil                                 ,;      // [14] N Tamanho Maximo da maior opção do combo
	Nil                                 ,;      // [15] C Inicializador de Browse
	Nil                                 ,;      // [16] L Indica se o campo é virtual
	Nil )                                       // [17] C Picture Variável

	oModel:SetDescription(STR0032) // Gera Nota Fiscal de Complemento.
	oModel:AddFields("FIELDVPARC", , oMStru) // Pre requisito para criacao de uma view
	oModel:GetModel("FIELDVPARC"):SetDescription(STR0031) // # Valor NF Cpl
	oModel:SetPrimaryKey({"VALORPARC"})

	oView:SetModel(oModel)
	oView:AddField("VIEWVPARC", oVStru, "FIELDVPARC")

	oView:CreateHorizontalBox("BOXVIEWVPARC", 100)
	oView:SetOwnerView("VIEWVPARC", "BOXVIEWVPARC")

	oView:SetViewProperty("VIEWVPARC", "SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 1}) // Seta o layout de forma vertical com 1 coluna

	oViewExec:SetView(oView)
	oViewExec:setOperation(MODEL_OPERATION_INSERT)
	oViewExec:SetButtons(aButtons)
	oViewExec:SetTitle(STR0032) // # gera nota fiscal de complemento
	oViewExec:SetOk({|| OGA450INOK(oModel, oView, @nValor) })
	oViewExec:SetCloseOnOk({|| .T.})
	oViewExec:SetSize(nHeight, nWidth)

	oViewExec:openView(.F.)

	RestArea(aArea)

Return nValor

/*{Protheus.doc} OGA450INOK
	//Função de OK da tela de valor
	@type  Function
	@author filipe.olegini
	@since 16/07/2018
	@version 1.0
	@type function
*/

Static Function OGA450INOK(oModel as object, oView as object, nValor as numeric)

	nValor := oModel:GetModel("FIELDVPARC"):GetValue("VALORPARC")

	oView:SetModified(.F.)
	oView:ButtonCancelAction()

Return .F. //retornar falso sempre

/*/{Protheus.doc} fValidObs()
	Carrega a mensagem padrão caso o tipo de devolução seja  1 - ao cliente
	@type  Static Function
	@author mauricio.joao
	@since 23/11/2018
	@version 1.0
	@param oModelNxC, param_type, param_descr
/*/
Static Function fValidObs(oModelNxC)
	Local cDev as char	

	//load de variavel
	cDev :=  oModelNxC:GetModel('FIELDNxC'):GetValue('DEVVAL')

	//Se devolver o dinheiro, carrega a  mensagem  no campo de observação.
	If cDev == '1'
		oModelNxC:GetModel('FIELDNxC'):LoadValue('OBSERVA',STR0060)
	Else
		oModelNxC:GetModel('FIELDNxC'):ClearField('OBSERVA')
	EndIf

Return .T.

/*/{Protheus.doc} fWhenObs()
	Bloqueia o campo observação caso o tipo de devolução for 1 - Ao cliente
	@type  Static Function
	@author mauricio.joao
	@since 23/11/2018
	@version 1.0
	@param oModelNxC, object, modelo nxc
	@return lRet, Logical, define se bloqueia ou não o campo
/*/
Static Function fWhenObs(oModelNxC as object, cOpc as char)

	Local lRet as logical
	Local cDev as char

	//load de variaveis
	lRet := .T.

	If cOpc == 'C'
		cDev := oModelNxC:GetModel('FIELDNxC'):GetValue('DEVVAL')

		//se for devolução ele bloqueia a edição do campo observação
		If cDev == '1'
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet
