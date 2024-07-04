#INCLUDE "OGA450A.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static __lAutomato  := isBlind()

/** {Protheus.doc} OGA450A
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA450A(pCodEnt,pLojEnt,pCodSaf,pCodPro,pTipo,lAutomato,pCtrDst,pCtrOrg )

	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer := Nil
	Local oPnCtr	 := Nil
	Local nX       := 0

	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias

	//--- Definição da estrutura da tabela temporária de Contratos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruCtr := { { "OK", "C", 2, 0 , , } , ;
	{ "C_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "C_MODELO", "C", TamSX3( "NJR_MODELO" )[ 1 ], 0 , RetTitle( "NJR_MODELO" ), PesqPict("NJR","NJR_MODELO") },;
	{ "C_STATUS", "C", TamSX3( "NJR_STATUS" )[ 1 ], 0 , RetTitle( "NJR_STATUS" ), PesqPict("NJR","NJR_STATUS") },;
	{ "C_CODCTR", "C", TamSX3( "NJR_CODCTR" )[ 1 ], 0 , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
	{ "C_DESCRI", "C", TamSX3( "NJR_DESCRI" )[ 1 ], 0 , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
	{ "C_TIPO"  ,	"C", TamSX3( "NJR_TIPO" )[ 1 ]	, 0 , RetTitle( "NJR_TIPO" )	, "@" },;
	{ "C_CODSAF", "C", TamSX3( "NJR_CODSAF" )[ 1 ], 0 , RetTitle( "NJR_CODSAF" ), PesqPict("NJR","NJR_CODSAF") },;
	{ "C_DESTIP", "C", 20 							, 0 , RetTitle( "NJR_TIPO" )	, "@" },;
	{ "C_CODENT", "C", TamSX3( "NJ0_CODENT" )[ 1 ], 0 , RetTitle( "NJ0_CODENT" ), PesqPict("NJ0","NJ0_CODENT") },;
	{ "C_LOJENT", "C", TamSX3( "NJ0_LOJENT" )[ 1 ], 0 , RetTitle( "NJ0_LOJENT" ), PesqPict("NJ0","NJ0_LOJENT") },;
	{ "C_NOMENT", "C", TamSX3( "NJ0_NOME" )[ 1 ], 0 , RetTitle( "NJ0_NOME" ), PesqPict("NJ0","NJ0_NOME") },;
	{ "C_CODPRO", "C", TamSX3( "NJR_CODPRO" )[ 1 ], 0 , RetTitle( "NJR_CODPRO" ), PesqPict("NJR","NJR_CODPRO") },;
	{ "C_DESPRO", "C", TamSX3( "NJR_DESPRO" )[ 1 ], 0 , RetTitle( "NJR_DESPRO" ), PesqPict("NJR","NJR_DESPRO") },;
	{ "C_TESEST",	"C", TamSX3( "NJR_TESEST" )[ 1 ], 0 , RetTitle( "NJR_TESEST" )	, "@" },;
	{ "C_TESRSI",	"C", TamSX3( "NJR_TESRSI" )[ 1 ], 0 , RetTitle( "NJR_TESRSI" )	, "@" },;
	{ "C_DATA"  ,	"D", 8 , 0 , RetTitle( "NJR_DATA" ) , 	"@D" },;
	{ "C_DATINI", "D", 8 , 0 , RetTitle( "NNY_DATINI" ),	"@D" },;
	{ "C_DATFIM", "D", 8 , 0 , RetTitle( "NNY_DATFIM" ),	"@D" },;
	{ "C_QTDCTR", "N", 19, 2 , RetTitle( "NJR_QTDCTR" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTDFIX", "N", 19, 2 , RetTitle( "NN8_QTDFIX" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTENFX", "N", 19, 2 , STR0017                 ,	"@E 999,999,999,999,999.99" },; //Qtd. Ent. Fix.
	{ "C_QTDAFX", "N", 19, 2 , STR0018                 ,	"@E 999,999,999,999,999.99" },; // Qtd. a Fixar
	{ "C_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "C_SLDFIS", "N", 19, 2 , RetTitle( "NJR_SLDFIS" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTEFIS", "N", 19, 2 , RetTitle( "NJR_QTEFIS" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTSFIS", "N", 19, 2 , RetTitle( "NJR_QTSFIS" ),	"@E 999,999,999,999,999.99" },;
	{ "C_DIFFIS", "N", 19, 2 , STR0019                 ,	"@E 999,999,999,999,999.99" },; // Dif. Fiscal
	{ "C_QTDRES", "N", 19, 2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999,999.99" },;
	{ "C_QTDTRF", "N", 19, 2 , STR0078                 ,	"@E 999,999,999,999,999.99" },;
	{ "C_RECNO" , "N", 10, 0 ,                  "RECNO", "@ 9999999999"} }

	Local aCpBrwCtr 	:= {}
	Local aIndCtr 	:= { "C_FILIAL+C_CODCTR" , "C_FILIAL+C_CODPRO"} // Definição dos índices

	//--- Definição da estrutura da tabela temporária de Contrato Transf ---//
	Local aEstruTrf := { { "OK", "C", 2, 0 , , } , ;
	{ "T_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "T_CODCTR" , "C", TamSX3( "NJR_CODCTR" )[ 1 ], 0 , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
	{ "T_DESCRI", "C", TamSX3( "NJR_DESCRI" )[ 1 ], 0 , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
	{ "T_CODENT" , "C", TamSX3( "NJ0_CODENT" )[ 1 ], 0 , RetTitle( "NJ0_CODENT" ), PesqPict("NJ0","NJ0_CODENT") },;
	{ "T_LOJENT" , "C", TamSX3( "NJ0_LOJENT" )[ 1 ], 0 , RetTitle( "NJ0_LOJENT" ), PesqPict("NJ0","NJ0_LOJENT") },;
	{ "T_NOMENT", "C", TamSX3( "NJ0_NOME" )[ 1 ], 0 , RetTitle( "NJ0_NOME" ), PesqPict("NJ0","NJ0_NOME") },;
	{ "T_TES"   ,	"C", TamSX3( "NJR_TESRSI" )[ 1 ], 0  , STR0023	, "@" },;
	{ "T_LOCAL" ,	"C", TamSX3( "NJJ_LOCAL" )[ 1 ], 0  , STR0024	, "@" },;
	{ "T_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "T_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "T_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999,999.99" },;
	{ "T_QTRANS", "N", 19, 2 , STR0021,	"@E 999,999,999,999,999.99" },;
	{ "T_MENNOTA","C", TamSX3( "F1_MENNOTA" )[ 1 ], 0  , STR0043	, "@" },;
	{ "T_RECNO" , "N", 10, 0, "RECNO", "@ 9999999999"} }

	Local aIndTrf  	 := { "T_FILIAL+T_CODCTR" } // Definição dos índices
	Local aSeek		 :={}

	Private cAliasCtr
	Private cTrabCtr
	Private oBrwCtr

	Private cAliasTrf
	Private cTrabTrf
	Private oBrwTrf

	Private cMarca   := GetMark()
	Private lSelAll  := .f.
	Private c1Perg   := PADR("OGA450A1",10)

	Private cNoFldCTR	 := "OK,C_FILIAL,C_MODELO,C_STATUS,C_TIPO,C_TESEST,C_TESRSI,C_RECNO"
	Private cNoFldTRF	 := "OK,T_FILIAL,T_CODENT,T_LOJENT,T_RECNO"
	Private aCpBrwTrf  := {}
	Private aContrato  := {}
	Private nQtdOrige	 := 0
	Private cOCodCtr  := ""
	Private cCodEnt   := pCodEnt
	Private cLojEnt   := pLojEnt
	Private cCtrDst   := pCtrDst
	Private cNomEnt   := ""
	Private cPSafra   := pCodSaf
	Private cPCodPro  := pCodPro
	Private cTipoCtr  := pTipo
	Private cCultra   := ""

	ValEntidade(cCodEnt,cLojEnt)

	// Tabela temporária de Contratos
	aRetTRB := AGRCRIATRB( , aEstruCtr, aIndCtr, FunName(), .T. )

	cTrabCtr 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasCtr 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwCtr	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	// Tabela temporária de Contratos a Transferir
	aRetTRB := AGRCRIATRB( , aEstruTrf, aIndTrf, FunName(), .T. )

	cTrabTrf 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasTrf 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwTrf	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	A450LoadCtr()

	//--- Montagem da tela ---//
    IF !lAutomato
		oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	
		//--- Layers ---//
		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlg, .f., .t. )
	
		// Contratos
		oFWLayer:AddLine( 'LinContrato', 100, .F. )
		oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinContrato' )
		oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinContrato' )
	
		DEFINE FWFORMBROWSE oBrwCtr DATA TABLE ALIAS cAliasCTR DESCRIPTION STR0002 OF oPnCtr //"Contratos"
		oBrwCtr:SetTemporary(.T.)
		oBrwCtr:SetdbFFilter(.T.)
		oBrwCtr:SetUseFilter(.T.)
		//oBrwCtr:SetQueryIndex(aIndCtr)
	
		aseek := {}
		//Para melhor entendimento aAdd( aSeek, { 'FILIAL+Contrato' , { {"AquiConsultaF3Setitver","C",'2',0,'filial',"@!"} ,{"","C",6,0,'codctr','@!'}  ,1  } )
		aAdd( aSeek, { Alltrim( RetTitle( "NJR_FILIAL" )) + '+' + Alltrim( RetTitle( "NJR_CODCTR" )),{{"",TAMSX3('NJR_FILIAL')[3],TAMSX3('NJR_FILIAL')[1],TAMSX3('NJR_FILIAL')[2],RetTitle( "NJR_FILIAL" ),PesqPict("NJR","NJR_FILIAL")},{""	,TAMSX3('NJR_CODCTR')[3],TAMSX3('NJR_CODCTR')[1],TAMSX3('NJR_CODCTR')[2],RetTitle( "NJR_CODCTR" ),PesqPict("NJR","NJR_CODCTR")}} ,1  } )
		aAdd( aSeek, { Alltrim( RetTitle( "NJR_FILIAL" )) + '+' + Alltrim( RetTitle( "NJR_CODPRO" )),{{"",TAMSX3('NJR_FILIAL')[3],TAMSX3('NJR_FILIAL')[1],TAMSX3('NJR_FILIAL')[2],RetTitle( "NJR_FILIAL" ),PesqPict("NJR","NJR_FILIAL")},{""	,TAMSX3('NJR_CODPRO')[3],TAMSX3('NJR_CODPRO')[1],TAMSX3('NJR_CODPRO')[2],RetTitle( "NJR_CODPRO" ),PesqPict("NJR","NJR_CODPRO")}} ,1  } )
	
		//oBrwCtr:SetSeek(,aDesIndice)
		oBrwCtr:SetSeek(,aSeek)
		oBrwCtr:SetFieldFilter(AGRITEMCBRW(aCpBrwCtr))
		ADD MARKCOLUMN oColumn DATA { || If(( cAliasCtr )->OK == cMarca,'LBOK','LBNO') } ;
		DOUBLECLICK { |oBrwCtr| A450ACLK( cAliasCtr , oBrwCtr) } ;
		HEADERCLICK { |oBrwCtr| A450ACHK( cAliasCtr , oBrwCtr) } OF oBrwCtr
	
		oBrwCtr:AddLegend( "C_MODELO=='1'"							, "WHITE"	, X3CboxDesc( "NJR_MODELO", "1" ) ) //Pré-Contrato
		oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='P'"	, "BLUE"	, X3CboxDesc( "NJR_STATUS", "P" ) ) //Previsto
		oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='A'"	, "GREEN"	, X3CboxDesc( "NJR_STATUS", "A" ) ) //Aberto
		oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='I'"	, "YELLOW"	, X3CboxDesc( "NJR_STATUS", "I" ) ) //Iniciado
		oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='E'"	, "BLACK"	, X3CboxDesc( "NJR_STATUS", "E" ) ) //Cancelado
		oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='F'"	, "RED"	, X3CboxDesc( "NJR_STATUS", "F" ) ) //Finalizado
	
		For nX := 1 To Len(aCpBrwCtr)
			If !( aCpBrwCtr[nX,1] $ cNoFldCTR )
				ADD COLUMN oColumn DATA &('{||'+aCpBrwCtr[nX,1]+'}') Title aCpBrwCtr[nX,5] SIZE aCpBrwCtr[nX,3] PICTURE aCpBrwCtr[nX,6] Of oBrwCtr
			EndIf
		Next nX
		oBrwCtr:DisableDetails()
		oBrwCtr:AddButton(STR0020,	{|| A450AVLTRF( (cAliasCTR)->C_CODENT ) },,,,,,'30')
		oBrwCtr:AddButton(STR0004,	{||   A450ADET( (cAliasCTR)->C_CODCTR ) },,,,,,'30')
		oBrwCtr:AddButton(STR0005,	{||  A450A1FIL( (cAliasCTR)->C_CODCTR ) },,,,,,'30')
		oBrwCtr:AddButton(STR0006,	{||   oDlg:End() },,,,,,'10')
		ACTIVATE FWFORMBROWSE oBrwCtr
	
		oDlg:Activate( , , , .t., { || .t. }, , { || } )
    ELSE
    	A450A1FIL()
        A450ACLK(cAliasCtr, , lAutomato)  
        A450AVLTRF(cCodEnt)  
    	A450ACHK( cAliasCtr)
    	
    ENDIF
    
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasCTR, cTrabCTR )
	AGRDELETRB( cAliasTRF, cTrabTRF )

Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/

Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } )

Return( aRotina )

/** {Protheus.doc} A450ADET
Função que detalha o contrato

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/
Function A450ADET( pcContrato )
	Local lRetorno := .t.

	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek( xFilial('NJR') + pcContrato )

		If NJR->NJR_TIPO = '1'
			A450A1View()
		ElseIf NJR->NJR_TIPO = '3'
			A450A3View()
		End
	Endif

Return ( lRetorno )

/** {Protheus.doc} A450A1FIL
Função que filtra os contratos

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
*/
Function A450A1FIL( )
	Local lRetorno := .t.
    
    If Pergunte(c1Perg,.t.)
        A450LoadCtr()
    EndIf
	

Return ( lRetorno )

/** {Protheus.doc} A450AUNSEL
Função chamada para verificar a existência de registro selecionado

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A450AUNSEL( pcAliasTRB )

	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )

		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := ' '
		msUnLock(pcAliasTRB)
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return

/** {Protheus.doc} A450ATSEL
Função chamada para verificar a existência de registro selecionado

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A450ATSEL( pcAliasTRB )

	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )

		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := cMarca
		msUnLock(pcAliasTRB)

		(pcAliasTRB)->( dbSkip() )
	EndDo
Return

/** {Protheus.doc} A450ACLK()
Marca/Desmarca registro

@param:
@author: 	Bruna Fagundes Rocio
@since: 	01/12/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450ACLK( pcAliasTRB, pOBrw, lAutomato  )

	If !(pcAliasTRB)->( Eof() )
		RecLock(pcAliasTRB, .F.)
		(pcAliasTRB)->OK := IIf((pcAliasTRB)->OK=cMarca,' ',cMarca)
		MsUnlock(pcAliasTRB)
	EndIf
	
	If !lAutomato		
	    pOBrw:Refresh()			
    EndIf
	
Return

/** {Protheus.doc} A450ACHK
Função para marcar/desmarcar todos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450ACHK( pcAliasTRB, pOBrw )

	If lSelAll
		A450ATSEL( pcAliasTRB )
	Else
		A450AUNSEL( pcAliasTRB )
	Endif

	DbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( DbGoTop() )

	If !__lAutomato		
	    pOBrw:Refresh()			
    EndIf

Return

/** {Protheus.doc} A450LoadCtr
Carrega dados da tabela temporária de Contratos.

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450LoadCtr()

	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cFiltro    	:= ""
	Local cFiltroSB5 	:= ""
	Local cCultura   	:= ""

	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	A450AclTRB( cAliasCTR )
    
    
    Pergunte(c1Perg,.f.)
    
    IF  __lAutomato		
		SetMVValue(c1Perg, "MV_PAR01",  cCodEnt) //Entidade Ini
		SetMVValue(c1Perg, "MV_PAR03",  cCodEnt) //Entidade Fim
		SetMVValue(c1Perg, "MV_PAR02",  cLojEnt)     //loja ini
		SetMVValue(c1Perg, "MV_PAR04",  cLojEnt)     //Loja fim
		SetMVValue(c1Perg, "MV_PAR05",  cCtrDst) //Contrato ini
		SetMVValue(c1Perg, "MV_PAR06",  cCtrDst) //Contrato fim		
    ENDIF
	
	cFiltro += " AND NJR_CODENT >= '" + MV_PAR01 + "'"
	cFiltro += " AND NJR_CODENT <= '" + MV_PAR03 + "'"
	cFiltro += " AND NJR_LOJENT >= '" + MV_PAR02 + "'"
	cFiltro += " AND NJR_LOJENT <= '" + MV_PAR04 + "'"
	cFiltro += " AND NJR_CODCTR >= '" + MV_PAR05 + "'"
	cFiltro += " AND NJR_CODCTR <= '" + MV_PAR06 + "'"
	cFiltro += " AND NJR_TIPO   <> '2' "
	cFiltro += " AND NJR_TIPO   <> '4' "
	cFiltro += " AND (NJR_STATUS = 'I' OR NJR_STATUS = 'A') "

	If !Empty(cPSafra)
		cFiltro += " AND NJR_CODSAF  = '" + cPSafra + "'"
	Endif

	If !Empty(cPCodPro)
		dbSelectArea('SB5')
		dbSetOrder(1)
		If dbSeek( xFilial('SB5') + cPCodPro )
			cCultura := SB5->B5_CULTRA
		Endif
	Endif

	//atribui a cultura para busca
	cCultra 	:= cCultura

	If Empty(cCultura)
		cFiltro += " AND NJR_CODPRO  = '" + cPCodPro + "'"
	Else
		cFiltroSB5 +=  " RIGHT JOIN " + RetSqlName("SB5") + " SB5 "
		cFiltroSB5 +=  "         ON SB5.D_E_L_E_T_ = '' "
		cFiltroSB5 +=  "        AND SB5.B5_FILIAL  = '" + xFilial('SB5') + "'"
		cFiltroSB5 +=  "        AND SB5.B5_CULTRA  = '" + cCultra + "'"
		cFiltroSB5 +=  "        AND SB5.B5_COD     = NJR.NJR_CODPRO "
		cFiltroSB5 +=  " RIGHT JOIN " + RetSqlName("SB1") + " SB1 "
		cFiltroSB5 +=  "         ON SB1.D_E_L_E_T_ = '' "
		cFiltroSB5 +=  "        AND SB1.B1_FILIAL  = '" + xFilial('SB1') + "'"
		cFiltroSB5 +=  "        AND SB1.B1_COD     = '" + cPCodPro + "'"
		cFiltroSB5 +=  "        AND SB1.B1_UM     = NJR.NJR_UM1PRO "
	EndIf

	cFiltro 	:= "%" + cFiltro + "%"
	cFiltroSB5	:= "%" + cFiltroSB5 + "%"

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry

		SELECT ' ' AS OK
		,NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODENT
		,NJR_LOJENT
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_DATA
		,NJR_TESRSI
		,NJR_TESEST
		,NJR.R_E_C_N_O_ AS NJR_RECNO
		,(SELECT MIN(NNY_DATINI) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATINI
		,(SELECT MAX(NNY_DATFIM) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATFIM
		,SUM(NJR_QTDCTR) as NJR_QTDCTR
		,SUM(NJR_QTEFCO) as NJR_QTEFCO
		,SUM(NJR_QTEFIS) as NJR_QTEFIS
		,SUM(NJR_QTSFCO) as NJR_QTSFCO
		,SUM(NJR_QTSFIS) as NJR_QTSFIS
		,SUM(NJR_QTDRES) as NJR_QTDRES
		,SUM(NJR_QSLFCO) as NJR_QSLFCO
		,SUM(NJR_SLDFIS) as NJR_SLDFIS
		,SUM(NN8_QTDFIX) as NN8_QTDFIX
		,SUM(NN8_QTDENT) as NN8_QTDENT
		FROM %Table:NJR% NJR
		LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1'
		%exp:cFiltroSB5%
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR%
		%exp:cFiltro%
		GROUP BY  NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODENT
		,NJR_LOJENT
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_DATA
		,NJR_TESRSI
		,NJR_TESEST
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
		( cAliasCTR )->C_CODSAF		:= ( cAliasQry )->NJR_CODSAF
		( cAliasCTR )->C_CODPRO		:= ( cAliasQry )->NJR_CODPRO
		( cAliasCTR )->C_DESPRO		:= Posicione('SB1',1,xFilial('SB1')+( cAliasQry )->NJR_CODPRO,'B1_DESC')
		( cAliasCTR )->C_CODENT 	:= ( cAliasQry )->NJR_CODENT
		( cAliasCTR )->C_LOJENT 	:= ( cAliasQry )->NJR_LOJENT
		( cAliasCTR )->C_NOMENT 	:= Posicione("NJ0",1,xFilial("NJ0")+( cAliasQry )->NJR_CODENT+( cAliasQry )->NJR_LOJENT,"NJ0_NOME")
		( cAliasCTR )->C_TIPO 		:= ( cAliasQry )->NJR_TIPO
		( cAliasCTR )->C_DESTIP 	:= X3CboxDesc( "NJR_TIPO", ( cAliasQry )->NJR_TIPO )
		( cAliasCTR )->C_DATA		:= StoD( ( cAliasQry )->NJR_DATA )
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
		( cAliasCTR )->C_TESEST 	:= ( cAliasQry )->NJR_TESEST
		( cAliasCTR )->C_TESRSI 	:= ( cAliasQry )->NJR_TESRSI
		( cAliasCTR )->C_RECNO 		:= ( cAliasQry )->NJR_RECNO

		If ( cAliasQry )->NJR_TIPO $ "1|3"
			If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
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

		( cAliasCTR )->( MsUnLock() )

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
	
    RestArea( aAreaAtu )
    
    IF  !__lAutomato
		If Type("oBrwCtr") <> "U"
			oBrwCtr:Refresh(.T.)
		EndIf
	EndIf	
	
Return

/** {Protheus.doc} A450A3View

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		OGA450A
*/
Function A450A3View( )

	Local xRet

	xRet := FWExecView( '','OGA260', MODEL_OPERATION_VIEW )

Return xRet

/** {Protheus.doc} A450A1View

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		OGA450A
*/
Function A450A1View( )

	Local xRet

	xRet := FWExecView( '','OGA280', MODEL_OPERATION_VIEW )

Return xRet

/** {Protheus.doc} A450AclTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450AclTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()

	If Select( pcAliasTRB ) > 0 // Verifica se o Arquivo Existe
		DbSelectArea( pcAliasTRB )
		Zap
	Endif

	RestArea( aAreaAtu )
Return

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

	If DbSeek( xFilial( "NJ0" ) + pcCodEnt + pcLojEnt )
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
		Help( , , STR0049, , STR0079, 1, 0 ) //"AJUDA"###"Informar Entidade para Transferencia."
		Return( .F. )
	EndIf

Return( .T. )

/** {Protheus.doc} A450ATRANS
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450ATRANS()

	Local aAreaAtu		:= GetArea()
	Local aSimNao 		:= {STR0045,STR0046}	//"Sim"###"Nao"	-->P/Formulario Proprio
	Local aTipoCtr		:= {"",STR0047,STR0048} //"Compra"###"Armaz De 3"
	Local aColunas      := {}
	Local nOpcao		:= 0
	Local nX			:= 0
	Local oDlg			:= Nil
	Local lPadrao		:= .f.
	Local aCols  		:= {}
	Local Aheader 		:= {}
	Local oStruNJR      := FWFormStruct(1, 'NJR')
	Local oStruNJM      := FWFormStruct(1, 'NJM')

	Private nPosTes			:= 0
	Private nPosLocal		:= 0
	Private nPosQtTrsf		:= 0
	Private nPosMsNf		:= 0

	Private lRet1			:= .T.
	Private lRet2			:= .F.
	Private cNFPSer		:= Space( TamSX3( "NJJ_NFPSER" )[1] )
	Private cNFPNum		:= Space( TamSX3( "NJJ_NFPNUM" )[1] )
	Private cCodTra		:= Space( TamSX3( "A4_COD"     )[1] )
	Private cCodVe1		:= Space( TamSX3( "DA3_COD"    )[1] )
	Private cFormProp		:= "1" //Space( TamSX3( "NJJ_TPFORM" )[1] )
	Private cTrnfDesp		:= "1"
	Private cTipoDest   	:= ""
	Private cMsgEnt		:= Space( TamSX3( "F1_MENNOTA" )[1] )
	Private cNFData		:= CTOD( "  /  /    " )
	Private cNFNumero		:= Space( TamSX3( "NJJ_DOCNUM" )[1] )
	Private cNFSerie		:= Space( TamSX3( "NJJ_DOCSER" )[1] )
	Private cTesDev		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cTESDest		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cNFEspecie	:= Space( TamSX3( "NJJ_DOCESP" )[1] )
	Private cChaveNFE		:= Space( TamSX3( "NJJ_CHVNFE" )[1] )
	Private cLocalD		:= Space( TamSX3( "NJJ_LOCAL"  )[1] )
	Private nNFVlrTot		:= 0
	Private nNFVlrUni		:= 0
	Private nQtd 			:= 0
	Private cPicQtd		:= "@E 999,999,999,999.99"
	Private cPicUlr		:= "@E 999,999.999999"
	Private cPicVlr		:= "@E 999,999,999,999.99"
	Private aRegNJJ      := {}

	Private nQtdEnFco	:= 0
	Private nQtdSaFco	:= 0
	Private nQtdAFixa	:= 0
	Private nDecPeso		:= SuperGetMV("MV_OGDECPS",,0)
	Private cPicPeso		:= SuperGetMV("MV_OGPICPS",,"@E 999,999,999")

	/* Vars do Tipo de Movto. */
	Private cNKMTIPOMV		:= Criavar('NKM_TIPOMV', .F.)
	Private cNKMDESTIP		:= Criavar('NKM_DESTIP', .F.)

	//*VARIAVEIS DE TELA RECEBEM INFORMACOES DA TELA PRINCIPAL
	cDCodEnt	:= cCodEnt 					//ENTIDADE
	cDLojEnt	:= cLojEnt 					//LOJA ENTIDADE
	cDNomEnt	:= cNomEnt 					//ENTIDADE

	//*VALIDACAO PARA VERIFICAR SE FOI INFORMADO ENTIDADE NA TELA PRINCIPAL
	If Empty(cCodEnt)
		Help( , , STR0049, , STR0075, 1, 0 ) //"AJUDA"###"Informar Entidade para Transferencia."
		Return( Nil )
	EndIf

	aColunas := {RetTitle( "NJR_CODCTR" ), ;
	RetTitle( "NJR_DESCRI" ),;
	RetTitle( "NJR_NOMENT" ),;
	STR0023,;
	STR0024,;
	RetTitle( "NJR_QTEFCO" ),;
	RetTitle( "NJR_QTSFCO" ),;
	RetTitle( "NJR_QTDCTR" ),;
	STR0021,;
	STR0043, "TESTE" }

	nQtdEnFco	:= ( cAliasCTR )->C_QTEFCO
	nQtdSaFco	:= ( cAliasCTR )->C_QTSFCO
	nQtdAFixa	:= ( cAliasCTR )->C_QTDFIX

	//*PARAMETROS DE TELA - TRANSFERENCIA
	IF !__lAutomato
		oDlg	:= TDialog():New( 0, 0, 550, 960, OemToAnsi( STR0026 ), , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Dados para Transferencia"
	
		oDlg:lEscClose := .f.
	
		oPanel := TPanel():New(0 , 0,,oDlg,,.F.,.F.,,,450,960,.T.,.T.)
		oPanel:Align	:= CONTROL_ALIGN_ALLCLIENT
	
		//--- Layers ---//
		oFwLayer:= FwLayer():New()
		oFwLayer:Init( oPanel, .f., .t. )
	
		// Entidade
		oFWLayer:AddLine( 'LinOrigem', 55, .T. )
		oFWLayer:AddCollumn( 'ColOrigem', 100, .T., 'LinOrigem' )
		oPnOri := oFWLayer:GetColPanel( 'ColOrigem', 'LinOrigem' )
	
		// Totais
		oFWLayer:AddLine( 'LinDestino', 34, .F. )
		oFWLayer:AddCollumn( 'ColDestino', 100, .T., 'LinDestino' )
		oPnDes := oFWLayer:GetColPanel( 'ColDestino', 'LinDestino' )
	
		//*Grupo 1 - Destino
		oLQtd	:= TGroup():New( 004,004,147,480,OemToAnsi( STR0027 ),oPnOri,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Destino"
	
		@ 012,012 SAY(OemToAnsi( STR0028 )) OF oPnOri PIXEL		//"Entidade:"
		@ 012,048 MSGET cDCodEnt PICTURE "@!" SIZE 40,10  OF oPnOri F3 "NJ0" HASBUTTON PIXEL //VALID ValEntidade(cDCodEnt)
		@ 012,090 MSGET cDLojEnt PICTURE "@!" SIZE 15,10  OF oPnOri PIXEL VALID ValEntidade(cDCodEnt,cDLojEnt) WHEN .T.
		@ 012,107 MSGET oDNomEnt Var cDNomEnt PICTURE "@!" SIZE 110,10 OF oPnOri PIXEL WHEN .F. OBFUSCATED AGRLGPD("NJ0_NOME") 

		@ 012,237 SAY(OemToAnsi( STR0029 )) OF oPnOri PIXEL 		//"Tipo Contrato"
		@ 012,277 COMBOBOX cTipoDest ITEMS aTipoCtr SIZE 60,7 OF oPnOri PIXEL
	
		@ 026,012 SAY(OemToAnsi( STR0030 )) OF oPnOri PIXEL			//"TES:"
		@ 026,048 MSGET cTESDest  PICTURE "@!" OF oPnOri F3 "SF4" HASBUTTON PIXEL
	
		@ 026,135 SAY(OemToAnsi( STR0031 )) OF oPnOri PIXEL 	//"Quantidade:"
		@ 026,171 MSGET oQtd VAR nQtd PICTURE cPicQtd OF oPnOri HASBUTTON PIXEL ON CHANGE (ValidQtdVlr('1'))
	
		@ 026,250 SAY(OemToAnsi( STR0032 )) OF oPnOri PIXEL	//"Transportadora:"
		@ 026,289 MSGET cCodTra PICTURE "@!" OF oPnOri F3 "SA4" HASBUTTON PIXEL
	
		@ 026,371 SAY(OemToAnsi( STR0033 )) OF oPnOri PIXEL	 //"Veiculo:"
		@ 026,407 MSGET cCodVe1 PICTURE "@!" OF oPnOri F3 "DA3" HASBUTTON PIXEL
	
		//*CONTROLA COMBO BOX - SIM E NAO - PARA VALIDAÇÃO DOS CAMPOS ABAIXO - SE ALTERA
		@ 041,012 SAY(OemToAnsi( STR0034 )) OF oPnOri PIXEL		//"Form. Prop."
		@ 041,048 COMBOBOX cFormProp ITEMS aSimNao SIZE 45,7 OF oPnOri PIXEL ON CHANGE (ValidForm())
	
		@ 041,135 SAY(OemToAnsi( STR0024 )) OF oPnOri PIXEL 	//"Local:"
		@ 041,171 MSGET cLocalD PICTURE "@!" OF oPnOri F3 "NNR" HASBUTTON PIXEL
	
		@ 056,012 SAY(OemToAnsi( STR0035 )) OF oPnOri PIXEL	 		//"NFP Série"
		@ 056,048 MSGET cNFPSer PICTURE "@!" OF oPnOri PIXEL WHEN lRet1
	
		@ 056,135 SAY(OemToAnsi( STR0036 )) OF oPnOri PIXEL	 	//"NFP Numero:"
		@ 056,171 MSGET cNFPNum PICTURE "@!" OF oPnOri PIXEL WHEN lRet1
	
		@ 071,012 SAY(OemToAnsi( STR0037 )) OF oPnOri PIXEL				//"Série"
		@ 071,048 MSGET cNFSerie PICTURE "@!" OF oPnOri PIXEL WHEN lRet2
	
		@ 071,135 SAY(OemToAnsi( STR0038 )) OF oPnOri PIXEL			//"Número"
		@ 071,171 MSGET cNFNumero PICTURE "@!" OF oPnOri PIXEL WHEN lRet2
	
		@ 071,253 SAY(OemToAnsi( STR0039 )) OF oPnOri PIXEL		//"Data Emissão"
		@ 071,289 MSGET cNFData  PICTURE "99/99/9999" SIZE 45,10 OF oPnOri HASBUTTON PIXEL WHEN lRet2
	
		@ 071,371 SAY(OemToAnsi( STR0040 )) OF oPnOri PIXEL			//"Espécie:"
		@ 071,407 MSGET cNFEspecie  PICTURE "@!" OF oPnOri F3 "42" HASBUTTON PIXEL WHEN lRet2
	
		@ 086,012 SAY(OemToAnsi( STR0041 )) OF oPnOri PIXEL	//"Valor Unitário"
		@ 086,048 MSGET nNFVlrUni PICTURE PesqPict("NJM","NJM_VLRUNI") OF oPnOri HASBUTTON PIXEL WHEN lRet2 ON CHANGE (ValidQtdVlr('1'))
	
		@ 086,135 SAY(OemToAnsi( STR0042 )) OF oPnOri PIXEL		//"Valor Total"
		@ 086,171 MSGET nNFVlrTot PICTURE PesqPict("NJM","NJM_VLRTOT") OF oPnOri HASBUTTON PIXEL WHEN lRet2 ON CHANGE (ValidQtdVlr('2'))
	
		@ 101,012 SAY(OemToAnsi( STR0043 )) OF oPnOri PIXEL		//"Mens.p/ Nota"
		@ 101,048 MSGET cMsgEnt PICTURE "@!" OF oPnOri PIXEL
	
		@ 116,012 SAY(OemToAnsi( STR0044 )) OF oPnOri PIXEL			//"Chave NFE:"
		@ 116,048 MSGET cChaveNFE PICTURE "@!" OF oPnOri PIXEL WHEN (lRet2 .AND. cNFEspecie='SPED')
	
		//Identifica o nr. do Tipo de Movimento a Ser Gravado na Tab. de Geração de Movimentos, Caso Utilize;
		fGetTpMv()
		//---------------------------------------------------------------------------------------------------//
		@ 131,012 SAY(OemToAnsi( 'Tp Movto' )) OF oPnOri PIXEL		//"Entidade:"
		@ 131,048 MSGET cNKMTIPOMV PICTURE PESQPICT('NKM','NKM_TIPOMV') /*SIZE 40,10   OF oGrTpMv*/ F3 "NKL" OF oPnOri HASBUTTON PIXEL WHEN .f. VALID fVldTpMv(cNKMTIPOMV)
		@ 131,090 MSGET cNKMDESTIP PICTURE PESQPICT('NKM','NKM_DESTIP') /*SIZE 220,10  OF oGrTpMv*/ OF oPnOri PIXEL WHEN .F.
	
		//----------------+
		//Cria aHeader    |
		//----------------+
		aHeader :={}
	
		// Col 01
		aAdd(aHeader,Header450(oStruNJR,"NJR_CODCTR",,"V",))
	
		// Col 02
		aAdd(aHeader,Header450(oStruNJR,"NJR_DESCRI",,"V",))
	
		// Col 03
		aAdd(aHeader,Header450(oStruNJR,"NJR_NOMENT",,"V",))
	
		// Col 04
		nPosTes	:= 04
		aAdd(aHeader,Header450(oStruNJM,"NJM_TES",,"A",))
	
		// Col 05
		nPosLocal := 05
		aAdd(aHeader,Header450(oStruNJM,"NJM_LOCAL",,"A",))
	
		// Col 06
		aAdd(aHeader,Header450(oStruNJR,"NJR_QTEFCO",,"V",))
	
		// Col 07
		aAdd(aHeader,Header450(oStruNJR,"NJR_QTSFCO",,"V",))
	
		// Col 08
		aAdd(aHeader,Header450(oStruNJR,"NJR_QSLFCO",,"V",))
	
		// Col 09
		nPosQtTrsf := 09
		aAdd(aHeader,Header450(oStruNJR,"NJR_QTDCTR","OGA450AVLD()","A",STR0021))
	
		// Col 10
		nPosMsNf		:= 10
		aAdd(aHeader,Header450(oStruNJM,"NJM_MSGNFS",,"A",))
		//----+
		//Fim |
		//----+
		// Alimenta Var do GetDados com o Dados dos Ctratos Selecionados
		acols := {}
		For nX:=1 to len( acontrato )
			aAdd(aCols,Array(Len(aHeader)+1))
			aCols[Len(aCols),01 ] := aContrato[nX,1]
			aCols[Len(aCols),02 ] := aContrato[nX,2]
			aCols[Len(aCols),03 ] := aContrato[nX,3]
			aCols[Len(aCols),04 ] := aContrato[nX,4]
			aCols[Len(aCols),05 ] := aContrato[nX,5]
			aCols[Len(aCols),06 ] := aContrato[nX,6]
			aCols[Len(aCols),07 ] := aContrato[nX,7]
			aCols[Len(aCols),08 ] := aContrato[nX,8]
			aCols[Len(aCols),09 ] := aContrato[nX,9]
			aCols[Len(aCols),10 ] := aContrato[nX,10]
			aCols[Len(aCols),Len(aHeader)+1] := .F.		// não excluido
		Next nX
	
		//Substitui o tcbrowse pelo MsNewGetDados que é o objeto mais apropriado para edicao e oferece as opcoes de validação,F3lookup,etc ( Porem essa rotina deveria ser re-escrita em mvc )
		oGDados   				:= MsNewGetDados():New(000,000,182,248,GD_UPDATE/*GD_INSERT+GD_DELETE+GD_UPDATE*/,,,,{"NJM_TES","NJM_LOCAL","NJR_QTDCTR",'NJM_MSGNFS'},,,,,,oPnDes,aHeader,aCols)
		oGDados:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||  nOpcao := 1,If(!A450AVLD(),nOpcao := 0, oDlg:End()) },{|| oDlg:End() },,,,,,,lPadrao,,,,, ) CENTERED

		cNFPSer		:= Space( TamSX3( "NJJ_NFPSER" )[1] )
		cNFPNum		:= Space( TamSX3( "NJJ_NFPNUM" )[1] )
		cCodTra		:= Space( TamSX3( "A4_COD"     )[1] )
		cCodVe1		:= Space( TamSX3( "DA3_COD"    )[1] )
		cFormProp	:= "1"
		cTrnfDesp	:= "1"
		cTipoDest	:= ""
		cMsgEnt		:= Space( TamSX3( "F1_MENNOTA" )[1] )
		cNFData		:= CTOD( "  /  /    " )
		cNFNumero	:= Space( TamSX3( "NJJ_DOCNUM" )[1] )
		cNFSerie	:= Space( TamSX3( "NJJ_DOCSER" )[1] )
		cTesDev		:= Space( TamSX3( "F4_CODIGO"  )[1] )
		cTESDest	:= Space( TamSX3( "F4_CODIGO"  )[1] )
		cNFEspecie	:= Space( TamSX3( "NJJ_DOCESP" )[1] )
		cChaveNFE	:= Space( TamSX3( "NJJ_CHVNFE" )[1] )
		cLocalD		:= Space( TamSX3( "NJJ_LOCAL"  )[1] )
		nNFVlrTot	:= 0
		nNFVlrUni	:= 0
		nQtd 		:= 0
	    
	    
	    
		RestArea( aAreaAtu )
	
		A450LoadCtr()
	
	Else			
	     cFormProp	:= "1"
		 cTrnfDesp	:= "1"
		 cTipoDest	:= ""
		 cTESDest   := '011' 
	     cLocalD    := '01'
         cNFPSer    := '1'
         cNFPNum    := '123123'
         cNFSerie   := '1'
         cNFNumero  := '121212'
         nNFVlrTot	:= 1
		 nNFVlrUni	:= 1
		 nQtd 		:= 1
		 cNFEspecie := 'NF'
		 cNFData    := cTod("20/08/2019")	     
			
		ValidForm()
	    A450AVLD()
	    ValidTES( cTESDest )
	    ValidLocal(	'01' )
	    fGetTpMv()
	    fVldTpMv(cNKMTIPOMV)
	    	    
	ENDIF

	
Return( .T. )

/*
############################################################################
# Função   : ValidForm                                                     #
# Descrição: Valida se o formulario será ou nao preenchido                 #
# Autor    : Ana Laura Olegini                                             #
# Data     : 21/11/2014                                                    #
############################################################################
*/
Static Function ValidForm()

	//Formulario Proprio?
	If cFormProp = "Sim"
		lRet1 := .T.
		lRet2 := .F.

		//Limpa tela
		cMsgEnt		:= Space( TamSX3( "F1_MENNOTA" )[1] )
		cNFData		:= CTOD( "  /  /    " )
		cNFNumero	:= Space( TamSX3( "NJJ_DOCNUM" )[1] )
		cNFSerie	:= Space( TamSX3( "NJJ_DOCSER"  )[1] )
		cNFEspecie	:= Space( TamSX3( "NJJ_DOCESP"  )[1] )
		cChaveNFE 	:= Space( TamSX3( "NJJ_CHVNFE"  )[1] )
		nNFVlrTot	:= 0
		nNFVlrUni	:= 0
	Else  //Não->trava os campos NFP Série e NFP Numero
		lRet1	:= .F.
		lRet2 	:= .T.
		//Limpa tela
		cNFPSer	:= Space( TamSX3( "NJJ_NFPSER" )[1] )
		cNFPNum	:= Space( TamSX3( "NJJ_NFPNUM" )[1] )
	EndIf

	lRefresh := .T.
Return

/** {Protheus.doc} A450AQTREG
Função para calcular o total de registros selecionados

@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A450AQTREG(pcAlias)

	Local nQtdReg := 0

	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(pcAlias)

	While !(pcAlias)->( Eof() )

		If (pcAlias)->OK = cMarca
			nQtdReg +=1
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(pcAlias)
	EndDo

Return ( nQtdReg )

/** {Protheus.doc} A450AVLTRF
Função para validação pré-transferência

@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A450AVLTRF()

	Local nQtdReg := A450AQTREG(cAliasCTR)

	If nQtdReg = 0
		Help(, , STR0049, , STR0050, 1, 0 )
		Return
	Else
		If GetContrato()
			A450ATRANS()
		Endif
	Endif

Return

/** {Protheus.doc} A450AVLD
Validações transferência

@param: 	Nil
@author: 	Bruna Rocio
@since: 	06/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
**/
Function A450AVLD()

	Local nSum := 0
	Local nX   := 0

	//------------------------------------------------------------------------------------------------------------------------
	// Retorna as colunas do GetDados que podem ter sido alterada para o array acontrato que será manipulado na Transferencia
	// mantendo a Logica Anterior q utilizava um tcbrowse
	//------------------------------------------------------------------------------------------------------------------------
	//{"NJM_TES","NJM_LOCAL",'QtTransf','NJM_MSGNFS'}
	IF !__lAutomato
		For nX:=1 to len(ogdados:acols)
			aContrato[nX,nPosTes	] := ogdados:acols[nX,nPosTes		]
			aContrato[nX,nPosLocal	] := ogdados:acols[nx,nPosLocal		]
			aContrato[nX,nPosQtTrsf	] := ogdados:acols[nX,nPosQtTrsf	]
			aContrato[nX,nPosMsNf	] := ogdados:acols[nX,nPosMsNf		]
		Next nX
	EndIF
	
	IF ! Empty( cNKMTIPOMV )// Validação ref. a Tipo de Movimentos Caso Controle a Geração de Movimentos da Transferencia Simples
		DbSelectArea( "NKL" )
		NKL->( DbSetOrder( 1 ) )
		If ! NKL->( DbSeek( fWxFilial( "NKL" ) + cNKMTIPOMV ))
			cMsg := STR0099 + CRLF  //'Transferência Multipla, Configurada para gerar controle de movimentações com tipo de movimentação inválido.' + CRLF
			cMsg += STR0100 		//'Favor verificar o parametro MV_OGCTRMV, e avegiguar o tipo de movimentação informado para os movimentos de TRFM.'
			MsgAlert( cMsg )
			Return( .f. )
		ElseIF Alltrim( NKL->NKL_ATIVO ) == '2'
			cMsg := STR0099 + CRLF 	//'Transferência Multipla, Configurada para gerar controle de movimentações com tipo de movimentação inválido.' + CRLF
			cMsg += STR0101			//'Favor verificar o parametro MV_OGCTRMV;  Tipo de Movto para os movimentos de TRFM. está Inátivo'
			MsgAlert( cMsg )
			Return( .f. )
		EndIF
	EndIF

	If Empty(cLocalD)
		Help(, , STR0049, , STR0086, 1, 0 )
		Return .f.
	Endif

	If lRet1
		If Empty(cNFPSer)
			Help(, , STR0049, , STR0088, 1, 0 )
			Return .f.
		EndIf

		If Empty(cNFPNum)
			Help(, , STR0049, , STR0089, 1, 0 )
			Return .f.
		Endif
	Endif

	If lRet2
		If Empty(cNFSerie)
			Help(, , STR0049, , STR0080, 1, 0 )
			Return .f.
		Endif

		If Empty(cNFNumero)
			Help(, , STR0049, , STR0081, 1, 0 )
			Return .f.
		Endif

		If Empty(cNFData)
			Help(, , STR0049, , STR0082, 1, 0 )
			Return .f.
		Endif

		If Empty(cNFEspecie)
			Help(, , STR0049, , STR0083, 1, 0 )
			Return .f.
		Endif

		If nNFVlrUni <= 0
			Help(, , STR0049, , STR0084, 1, 0 )
			Return .f.
		Endif

		If Empty(cChaveNFE) .And. cNFEspecie='SPED'
			Help(, , STR0049, , STR0085, 1, 0 )
			Return .f.
		Endif

	Endif
     
	IF !__lAutomato
		For nX := 1 to Len(aContrato)
			nSum += aContrato [nX, 9]
	
			If ALLTRIM(aContrato[nX,5]) == ""
				aContrato[nX,5] := cLocalD
				//			Help(, , STR0049, , STR0072, 1, 0 )
				//		Return .f.
			Endif
	
			If aContrato[nX,9] <= 0
				Help(, , STR0049, , STR0073 + aContrato[nX, 1 ], 1, 0 )
				Return .f.
			Endif
	
		Next nX
	else 
		nSum := 1	
	Endif


	If nQtd <> nSum
		Help(, , STR0049, , STR0055, 1, 0 )
		Return .f.
	EndIf

	If !A450ACTR()
		Return .f.
	EndIf

Return ( .t. )

/** {Protheus.doc} GetContrato
Função que busca os contratos selecionados para transferência

@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetContrato()

	Local cTipo    := ""
	Local cSafra   := ""
	Local cProduto := ""
	Local cMsg     := ""

	A450AclTRB( cAliasTrf )

	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasCTR)

	nQtdOrige := 0
	aContrato :={}
	While !(cAliasCTR)->( Eof() )

		If (cAliasCTR)->OK = cMarca

			If AllTrim(cTipo) = ""
				cTipo := (cAliasCTR)->C_TIPO
			ElseIf cTipo <> (cAliasCTR)->C_TIPO
				Help(, , STR0049, , STR0051, 1, 0 )
				Return .f.
			Endif

			If AllTrim(cSafra) = ""
				cSafra := (cAliasCTR)->C_CODSAF
			ElseIf cSafra <> (cAliasCTR)->C_CODSAF
				Help(, , STR0049, , STR0066, 1, 0 )
				Return .f.
			Endif

			If AllTrim(cProduto) = ""
				cProduto := (cAliasCTR)->C_CODPRO
			ElseIf cProduto <> (cAliasCTR)->C_CODPRO
				Help(, , STR0049, , STR0065, 1, 0 )
				Return .f.
			Endif

			If ( cAliasCTR )->C_STATUS <> 'I' //Iniciado
				cMsg := STR0067 + (cAliasCTR)->C_CODCTR + STR0068
				Help(, , STR0049, , cMsg, 1, 0 )
				Return .f.
			EndIf

			If (cAliasCTR)->C_QSLFCO <= 0
				cMsg := STR0069 + (cAliasCTR)->C_CODCTR + STR0070
				Help(, , STR0049, , cMsg, 1, 0 )
				Return .f.
			Endif

			nQtdOrige += ( cAliasCTR )->C_QTEFCO - ( cAliasCTR )->C_QTSFCO - ( cAliasCTR )->C_QTDFIX - ( cAliasCTR )->C_QTDRES

			If cOCodCtr = ""
				cOCodCtr  := (cAliasCTR)->C_CODCTR
			Endif

			RecLock( cAliasTrf,.t. )
			(cAliasTrf)->T_FILIAL  := (cAliasCTR)->C_FILIAL
			(cAliasTrf)->T_CODCTR  := (cAliasCTR)->C_CODCTR
			(cAliasTrf)->T_DESCRI  := (cAliasCTR)->C_DESCRI
			(cAliasTrf)->T_CODENT  := (cAliasCTR)->C_CODENT
			(cAliasTrf)->T_LOJENT  := (cAliasCTR)->C_LOJENT
			(cAliasTrf)->T_NOMENT  := (cAliasCTR)->C_NOMENT
			(cAliasTrf)->T_TES     := IIF((cAliasCTR)->C_TIPO = '1', (cAliasCTR)->C_TESEST, (cAliasCTR)->C_TESRSI)
			(cAliasTrf)->T_QTEFCO  := (cAliasCTR)->C_QTEFCO
			(cAliasTrf)->T_QTSFCO  := (cAliasCTR)->C_QTSFCO
			(cAliasTrf)->T_QSLFCO  := (cAliasCTR)->C_QSLFCO
			(cAliasTrf)->T_RECNO   := (cAliasCTR)->C_RECNO
			(cAliasTrf)->(MsUnlock())

			aAdd( aContrato, { (cAliasTrf)->T_CODCTR, (cAliasTrf)->T_DESCRI, (cAliasTrf)->T_NOMENT, (cAliasTrf)->T_TES, (cAliasTrf)->T_LOCAL, (cAliasTrf)->T_QTEFCO, (cAliasTrf)->T_QTSFCO, (cAliasTrf)->T_QSLFCO, 0,(cAliasTrf)->T_MENNOTA, (cAliasTrf)->T_FILIAL } )
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasCTR)
	EndDo

Return ( .t. )

/** {Protheus.doc} A450ACTR
Função para transferência entre contratos, possibilita a
transferência de várias origens para um só destino.

--------------------------------------------------------
Original:
# Função   : OGA450TOK
# Descrição: CONFIRMA TRANSFERÊNCIA ENTRE CONTRATOS
# Autor    : Ana Laura Olegini
# Data     : 18/07/2014
--------------------------------------------------------

@param: 	Nil
@author: 	Bruna Rocio
@since: 	09/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function A450ACTR()
	Local aAreaAtu 	:= GetArea()
	Local cDCodCtr	:= ""
	Local cVerifica 	:= GetNextAlias()
	Local lRetorno	:= .T.
	Local nX 			:= 0
	Local nVerifica	:= 0
	Local cFAnterior 	:= ""

	aRegNJJ := {}
	cTrfDst := ""

	If nQtd <= 0
		MsgAlert(STR0052+Chr(13)+STR0053) //"Não foi informada nenhuma quantidade a ser negociada."###"Nenhum movimento será gerado."
		Return( .F. )
	EndIf

	If Empty(cTipoDest)
		MsgAlert(STR0090) //"Tipo de contrato Destino (Compra/Armazenagem de 3) deverá ser informado."
		Return ( .f. )
	Endif

	//Se escolher compra - vai buscar os contratos de compra
	If cTipoDest = STR0047
		cTipoCtr := "1"
		cTipoRom := "5"	//5=Entrada Compra
		cDescTip := STR0047
		//Se escolher armaz. - vai buscar os contratos de armazenagem
	ElseIf cTipoDest = STR0048
		cTipoCtr := "3"
		cTipoRom := "3"	//3=Entrada Depos. 3
		cDescTip := STR0048
	EndIf

	If MsgYesNo(STR0054)

		//	cCodigo := OGX010BC( OGX010TC( cTipoRom ) , cDCodEnt ,cDLojEnt, cPSafra, cPCodPro )

		//	If Empty(cCodigo) //__cCodigo é uma variavel Publica declarada na Consulta Parao cusotmizada OGX010CT

		cQuery := " SELECT * "
		cQuery +=   " FROM "+ RetSqlName("NJR") + " NJR "

		If !Empty(cCultra)
			cQuery +=  " RIGHT JOIN " + RetSqlName("SB5") + " SB5 "
			cQuery +=  "         ON SB5.D_E_L_E_T_ = '' "
			cQuery +=  "        AND SB5.B5_CULTRA  = '" + cCultra + "'"
			cQuery +=  "        AND SB5.B5_COD     = NJR.NJR_CODPRO "
		EndIf

		cQuery +=  " WHERE NJR.D_E_L_E_T_ = '' "
		cQuery +=    " AND NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'"
		cQuery +=    " AND NJR.NJR_TIPO   = '" + cTipoCtr + "'"
		cQuery +=    " AND NJR.NJR_CODENT = '" + cDCodEnt + "'"
		cQuery +=    " AND NJR.NJR_LOJENT = '" + cDLojEnt + "'"
		cQuery +=    " AND NJR.NJR_CODSAF = '" + cPSafra  + "'"
		cQuery +=    " AND NJR.NJR_STATUS in ( 'P', 'A', 'I' )

		If Empty(cCultra)
			cQuery +=    " AND NJR.NJR_CODPRO = '" + cPCodPro + "'"
		EndIf

		cQuery := ChangeQuery(cQuery)
		//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
		If Select(cVerifica) <> 0
			(cVerifica)->(dbCloseArea())
		EndIf
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cVerifica,.T.,.T.)

		COUNT TO nVerifica
		
        IF __lAutomato
			cDCodCtr := pCtrOrg	
		else
			If nVerifica > 0
				If .Not. Empty( cCultra )
					OGX010TRCT( cTipoCtr , cDCodEnt ,cDLojEnt, cPSafra, cCultra )
					cDCodCtr := __cCodigo
				Else
					OGX010CT( OGX010TC( cTipoCtr ) , cDCodEnt ,cDLojEnt, cPSafra, cPCodPro )
					cDCodCtr := __cCodigo
				EndIf
			Else
				cDCodCtr := OGX010BC(OGX010TC(cTipoRom), cDCodEnt, cDLojEnt, cPSafra, cPCodPro)
				If valType(cDCodCtr) == "A" //se for array, pega apenas codigo do contrato - trata inovação liberada na P12.1.23
					cDCodCtr := cDCodCtr[1]
				EndIf
			EndIf
		EndIF
		
		If Empty(cDCodCtr)
			MsgStop( STR0095 ) //#"Não foi possível encontrar nenhum contrato que satisfaça as condições de mesma Safra, Produto e Tipo de Contrato, na entidade destino da transferência."
			lRetorno := .F.
		Endif

		if .not. ValidNFFP(cDCodCtr)
			return (.f.)
		endif

		cFAnterior := cFilAnt
		If nQtd > 0 .And. lRetorno = .t.
			cTrfDst := ""
			BEGIN SEQUENCE
				BEGIN TRANSACTION

					//"Gerando devolução contrato origem..."###"Romaneio Simbólico"
					IF ! Empty(cNKMTIPOMV)  // Identifica que Deve-se Utilizar o Controle de Movimentos do OG, Para criar vinculo entre os Romaneios do Processo
						cIdMov := fGerMvID( cNKMTIPOMV ) // Identificando o Tipo de Movto
					Else
						cIdMov := ""
					EndIF

					For nX := 1 to Len(aContrato)
						//"Gerando devolução contrato origem..."###"Romaneio Simbólico"

						MsgRun( STR0059	, STR0060 	, {|| lRetorno := GeraRomSimb( "O", aContrato[nX,1], aContrato[nX,9], "1", "", "", "",;
						"", aContrato[nX,10], "",;
						"", "", aContrato[nX,4], "","",;
						"", "" , aContrato[nX,5], "1",cIdMov) } )

						If .Not. lRetorno
							DisarmTransaction()
							BREAK
						EndIf
					Next nX

					//"Gerando entrada contrado destino..."###"Romaneio Simbólico"
					MsgRun( STR0061 , STR0062 	, {|| lRetorno := GeraRomSimb( 	"D", cDCodCtr, nQtd, If( cFormProp = "Sim","1","2"), cNFPSer, cNFPNum, cCodTra,;
					cCodVe1, cMsgEnt, cNFData,;
					cNFNumero, cNFSerie, cTESDest, cNFEspecie, cChaveNFE,;
					nNFVlrTot, nNFVlrUni, cLocalD, cTrnfDesp, cIdMov) } )
					If .Not. lRetorno
						DisarmTransaction()
						BREAK
					EndIf

				END TRANSACTION
			END SEQUENCE

			If lRetorno .And. Len( aRegNJJ ) >= 2

				For nX := 1 to Len( aRegNJJ )
					NJJ->( dbGoto( aRegNJJ[ nX ] ) )
					If RecLock( "NJJ", .f. )
						NJJ->( NJJ_FILREL ) := FWxFilial( "NJJ" )
						NJJ->( NJJ_ROMREL ) := cTrfDst
						msUnLock()
					EndIf

					lRetorno := OGA250ATUC( Alias(), Recno(), 4, .t. )

					If .Not. lRetorno
						MsgStop(STR0091 + NJJ->( NJJ_CODROM) ) //"Problema ao atualizar romaneio: "
						lRetorno := .t.
					EndIf
				Next nX
			Else
				MsgStop(STR0057+chr(13)+STR0058) //"A transação foi desfeita!"###"Nenhum movimento foi gerado."
			EndIf
		Else
			MsgStop(STR0057+chr(13)+STR0058) //"A transação foi desfeita!"###"Nenhum movimento foi gerado."
		EndIf

		If lRetorno
			MsgInfo(STR0056) ///"Movimentos gerados com sucesso!"
		EndIf
	EndIf

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} ValidTES

@param: 	Nil
@return:	Nil
@author: 	Bruna Fagundes Rocio
@since: 	19/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function ValidTES( pcTES )
	Local lRetorno := .t.

	dbSelectArea('SF4')
	dbSetOrder(1)
	If !dbSeek( xFilial('SF4') + pcTES)
		lRetorno := .f.
	Endif

Return ( lRetorno )

/** {Protheus.doc} ValidLocal

@param: 	Nil
@return:	Nil
@author: 	Bruna Fagundes Rocio
@since: 	19/02/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function ValidLocal( pcLocal )
	Local lRetorno := .t.

	dbSelectArea('NNR')
	dbSetOrder(1)
	If !dbSeek( xFilial('NNR') + pcLocal )
		lRetorno := .f.
	Endif

Return ( lRetorno )

/** {Protheus.doc} GeraRomSimb
//"Gerando romaneio de entrada e Saída

@param: 	Nil
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	02/12/2014
@Uso: 		OG - Originação de Grãos
*/
Static Function GeraRomSimb( cModelo, cCodCtrRom, nQtdRom, cTpFormRom, cNFPSerRom, cNFPNumRom,;
	cCodTraRom, cCodVeRom, cMsgRom, cNFDataRom,;
	cNFNumeroRom, cNFSerieRom, cTesRom, cNFEspRom, cChNFERom,;
	nNFVlrTot, nNFVlrUni, cLocalD, cTrnfDesp, cIdMov )

	Local aAreaAtu 	:= GetArea()
	Local lRetorno	:= .t.
	Local cPlaca 		:= ""
	Local cTipo		:= ""
	Local cNewNJJ    	:= ""
	Local cItem		:= ""
	Default cIdmov := CriaVar('NKM_IDMOV', .F. )

	//Contrato

	dbSelectArea("NJR")
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtrRom ) )

	dbSelectArea( "NJ0" )
	dbSetOrder( 1 )
	If .Not. dbSeek( FWxFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT) )
		Return( Nil )
	EndIf

	//Veiculos
	DA3->( dbSetOrder( 1 ) )
	if DA3->( dbSeek( FWxFilial( "DA3" ) + cCodVeRom ) )
		cPlaca := DA3->( DA3_PLACA )
	EndIf

	//Transportadora
	SA4->( dbSetOrder( 1 ) )
	If !SA4->( dbSeek( FWxFilial( "SA4" ) + cCodTraRom ) )
		cCodTraRom := ""
	EndIF

	If NJR->( NJR_TIPO ) = "1"
		cTipo := if (cModelo = "D", "5", "8")
		cTipMod := If (cModelo = "D", "E", "S")
	EndIf
	If NJR->( NJR_TIPO ) = "2"
		cTipo := If (cModelo = "D", "4", "9")
		cTipMod := If (cModelo = "D", "S", "E")
	EndIf
	If NJR->( NJR_TIPO ) = "3"
		cTipo := If (cModelo = "D", "3", "6")
		cTipMod := If (cModelo = "D", "E", "S")
	EndIf
	If NJR->( NJR_TIPO ) = "4"
		cTipo := If (cModelo = "D", "2", "7")
		cTipMod := If (cModelo = "D", "S", "E")
	EndIf

	//Romaneio
	//Alimenta os campos - do Romeneio
	cNewNJJ := GetSXENum('NJJ','NJJ_CODROM')
    If ( __lSx8 )
        ConfirmSX8()
    EndIf

	dbSelectArea( "NJJ" )
	If RecLock( "NJJ", .t. )
		NJJ->( NJJ_FILIAL ) 	:= FWxFilial( "NJJ" )
		NJJ->( NJJ_CODROM ) 	:= cNewNJJ
		NJJ->( NJJ_TIPO ) 	:= cTipo
		NJJ->( NJJ_CODENT ) 	:= NJ0->( NJ0_CODENT )
		NJJ->( NJJ_LOJENT ) 	:= NJ0->( NJ0_LOJENT )
		NJJ->( NJJ_ENTENT ) 	:= NJ0->( NJ0_CODENT )
		NJJ->( NJJ_ENTLOJ ) 	:= NJ0->( NJ0_LOJENT )
		NJJ->( NJJ_STATUS )	:= "1"
		NJJ->( NJJ_STSPES )  := "1"
		NJJ->( NJJ_STSCLA )  := "1"
		NJJ->( NJJ_STAFIS ) 	:= "1"
		NJJ->( NJJ_TIPENT )  := "2"
		NJJ->( NJJ_PLACA ) 	:= cPlaca
		NJJ->( NJJ_CODTRA )  := cCodTraRom
		NJJ->( NJJ_CODSAF ) 	:= NJR->( NJR_CODSAF )
		NJJ->( NJJ_CODPRO )	:= NJR->( NJR_CODPRO )
		NJJ->( NJJ_UM1PRO )	:= NJR->( NJR_UM1PRO )
		NJJ->( NJJ_TABELA )	:= NJR->( NJR_TABELA )
		NJJ->( NJJ_LOCAL )   := cLocalD
		NJJ->( NJJ_TPFORM ) 	:= cTpFormRom
		NJJ->( NJJ_NFPSER )  := cNFPSerRom
		NJJ->( NJJ_NFPNUM )  := cNFPNumRom
		NJJ->( NJJ_QTDFIS ) 	:= nQtdRom
		NJJ->( NJJ_PESO1 ) 	:= nQtdRom
		NJJ->( NJJ_PSSUBT ) 	:= nQtdRom
		NJJ->( NJJ_PSBASE ) 	:= nQtdRom
		NJJ->( NJJ_PSLIQU ) 	:= nQtdRom
		NJJ->( NJJ_MSGNFS )  := cMsgRom
		NJJ->( NJJ_DATA ) 	:= dDataBase
		NJJ->( NJJ_DATPS1 )  := dDataBase
		NJJ->( NJJ_DATPS2 )  := dDataBase
		NJJ->( NJJ_STACTR ) 	:= "2"
		NJJ->( NJJ_TRSERV )  := cTrnfDesp
		NJJ->NJJ_TPFRET			:= 'S'   //Sem Frete pois é um romaneio sem pesagem, onde a mercadoria n. transita

		If cTpFormRom = "2"
			NJJ->( NJJ_DOCSER ) 	:= cNFSerieRom
			NJJ->( NJJ_DOCNUM ) 	:= cNFNumeroRom
			NJJ->( NJJ_DOCEMI ) 	:= cNFDataRom
			NJJ->( NJJ_DOCESP ) 	:= cNFEspRom
			NJJ->( NJJ_CHVNFE ) 	:= cChNFERom
			NJJ->( NJJ_VLRUNI ) 	:= nNFVlrUni
			NJJ->( NJJ_VLRTOT ) 	:= nNFVlrTot
		EndIf

		If FieldPos("NJJ_PESO3") > 0
			NJJ->( NJJ_PESO3 ) := nQtdRom
		EndIf

		msUnLock()
	EndIf

	cItem := StrZero( 1, TamSX3( "NJM_ITEROM" )[1] )

	dbSelectArea( "NJM" )
	If RecLock( "NJM", .t. )
		NJM->( NJM_FILIAL ) := FWxFilial( "NJJ" )
		NJM->( NJM_CODROM ) := cNewNJJ
		NJM->( NJM_ITEROM ) := cItem
		NJM->( NJM_TIPO )   := cTipo
		NJM->( NJM_CODCTR ) := cCodCtrRom
		NJM->( NJM_CODENT ) := NJ0->( NJ0_CODENT )
		NJM->( NJM_LOJENT ) := NJ0->( NJ0_LOJENT )
		If ColumnPos("NJM_GENMOD") > 0 .and. ColumnPos("NJR_GENMOD") > 0
			NJM->( NJM_GENMOD ) := NJR->( NJR_GENMOD )
		EndIf
		NJM->( NJM_CODSAF ) := NJR->( NJR_CODSAF )
		NJM->( NJM_CODPRO ) := NJR->( NJR_CODPRO )
		NJM->( NJM_UM1PRO ) := NJR->( NJR_UM1PRO )
		NJM->( NJM_MSGNFS ) := cMsgRom
		NJM->( NJM_PERDIV ) := 100.00
		NJM->( NJM_STAFIS ) := "1"
		NJM->( NJM_TPFORM ) := cTpFormRom
		NJM->( NJM_NFPSER ) := cNFPSerRom
		NJM->( NJM_NFPNUM ) := cNFPNumRom
		NJM->( NJM_QTDFIS ) := nQtdRom
		NJM->( NJM_QTDFCO ) := nQtdRom
		NJM->( NJM_TES )    := cTesRom
		NJM->( NJM_LOCAL )  := cLocalD
		NJM->( NJM_TRSERV ) := cTrnfDesp
		NJM->NJM_IDMOV		:= cIdMov

		If cTpFormRom = "2"
			NJM->( NJM_DOCSER ) := cNFSerieRom
			NJM->( NJM_DOCNUM ) := cNFNumeroRom
			NJM->( NJM_DOCEMI ) := cNFDataRom
			NJM->( NJM_DOCESP ) := cNFEspRom
			NJM->( NJM_CHVNFE ) := cChNFERom
			NJM->( NJM_VLRUNI ) := nNFVlrUni
			NJM->( NJM_VLRTOT ) := nNFVlrTot
		EndIf

		msUnLock()
	EndIf

	aAdd( aRegNJJ, NJJ->( Recno() ) )
	If cModelo = "D"
		cTrfDst := NJJ->( NJJ_CODROM )
	Endif

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} ValidQtdVlr
@param: 	Nil
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OG - Originação de Grãos
*/
Static Function ValidQtdVlr(cCond)

	If nQtd <= 0
		Help( , , STR0049, , STR0063, 1, 0 ) //"AJUDA"###"Quantidade não pode ser menor ou igual a ZERO."
		nQtd := 0
		Return
		/*	ElseIf nQtd > nQtdOrige
		Help( , , STR0049, , STR0064, 1, 0 ) //"AJUDA"###"Quantidade não pode ser maior que a quantidade disponível."
		nQtd := 0
		Return*/
	Else
		If cCond = '1'
			nNFVlrTot	:= NoRound((nQtd*nNFVlrUni),TamSX3( "NJM_VLRTOT" )[2])
		ElseIf cCond = '2'
			nNFVlrUni	:= Round((nNFVlrTot/nQtd),TamSX3( "NJM_VLRUNI" )[2])
		EndIf
	EndIf

Return

/** {Protheus.doc} ValidNFFP

@param: 	Nil
@return:	Nil
@author: 	Agroindustria
@since: 	30/06/2016
@Uso: 		OG - Originação de Grãos
*/
Static Function ValidNFFP(cCodCtrRom)

	Local cAliasSF1 	:= GetNextAlias()

	If cFormProp = "Não"

		If cTipoDest = STR0019
			cTipoRom := "5"	//5=Entrada Compra
		ElseIf cTipoDest = STR0008
			cTipoRom := "3"	//3=Entrada Depos. 3
		EndIf

		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aRetClFr    := OGA250ClFr( cDCodEnt, cDLojEnt, cTESDest, cTipoRom, nQtd )
		cTipoNF     := aRetClFr[ 1 ]
		cCliFor     := aRetClFr[ 2 ]
		cLoja       := aRetClFr[ 3 ]

		BeginSql Alias cAliasSF1
			Select SF1.R_E_C_N_O_ as F1_RECNO
			,SD1.R_E_C_N_O_ as D1_RECNO
			From %table:SD1% SD1
			Inner Join %table:SF1% SF1
			on SF1.F1_FILIAL  = SD1.D1_FILIAL
			And SF1.F1_DOC     = SD1.D1_DOC
			And SF1.F1_SERIE   = SD1.D1_SERIE
			And SF1.F1_FORNECE = SD1.D1_FORNECE
			And SF1.F1_LOJA    = SD1.D1_LOJA
			And SF1.F1_TIPO    = SD1.D1_TIPO
			And SF1.%NotDel%
			Where SD1.D1_FILIAL  = %xFilial:SD1%
			And SD1.D1_DOC     = %Exp:cNFNumero%
			And SD1.D1_SERIE   = %Exp:cNFSerie%
			And SD1.D1_FORNECE = %Exp:cCLiFor%
			And SD1.D1_LOJA    = %Exp:cLoja%
			And SD1.D1_TIPO    = %Exp:cTipoNF%
			And SD1.%NotDel%
		EndSql

		(cAliasSF1)->( dbGoTop() )
		If !(cAliasSF1)->( Eof() )

			DbSelectArea( "SD1" )
			DbGoTo( (cAliasSF1)->( D1_RECNO ) )

			//busca o contrato
			dbSelectArea("NJR")
			NJR->( dbSetOrder( 1 ) )
			NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtrRom ) )

			// Verifica se a quantidade da NF fecha com a quantidade do Romaneio
			If SD1->( D1_QUANT ) <> nQtd
				MsgAlert(STR0092)	//"Não será possível associar Romaneio à Nota Fiscal já gerada, pois a Quantidade Fiscal do Romaneio difere da Quantidade da NF"
				(cAliasSF1)->( dbCloseArea( ) )
				Return( .F. )
			EndIf

			// Verifica se o Produto do Romaneio é o mesmo da NF
			If SD1->( D1_COD ) <> NJR->( NJR_CODPRO )
				MsgAlert(STR0093) //"Não será possível associar Romaneio à Nota Fiscal já gerada, pois o Produto do Romaneio difere do Produto da NF."
				(cAliasSF1)->( dbCloseArea( ) )
				Return( .F. )
			EndIf

			// Verifica NF informada não pertence a outro romaneio
			If ! Empty( SD1->( D1_CODROM ) )
				DbSelectArea( "NJJ" )
				DbSetOrder( 1 )
				If DbSeek( xFilial( "NJJ" ) + SD1->( D1_CODROM ) )
					If NJJ->( NJJ_STATUS ) $ "2|3" 	// 2=Atualizado; 3=Confirmado
						MsgAlert(STR0094 + ": " + SD1->( D1_CODROM )) //"Não será possível associar Romaneio à Nota Fiscal já gerada, pois a NF informada já está associada a outro romaneio. Romaneio"
						(cAliasSF1)->( dbCloseArea( ) )
						Return( .F. )
					EndIf
				EndIf
			EndIf

		endIf /*busca SF1*/
		(cAliasSF1)->( dbCloseArea( ) )
	endif /*Form Prop*/

Return(.t.)

/** {Protheus.doc} fVldTpMv()
Valida o Tipo de Movimento

@param: 	cTpMv - Id do Tipo de Movimento
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function fVldTpMv( cTpMv )
	Local lOk 		:= .t.
	Local aAreaAtu	:= GetArea()
	Local aAreaNKL	:= NKL->( GetArea() )

	IF !Empty( cTpMv )
		DbSelectArea( "NKL" )
		NKL->( DbSetOrder( 1 ) )
		If NKL->( DbSeek( xFilial( "NKL" ) + cTpMv ))
			cNKMDESTIP := NKL->NKL_DESCRI
		Else
			Help( , , STR0049, , STR0102, 1, 0 ) //"AJUDA"###'Tipo de movimento informado inválido.'
			lOk :=.f.
		EndIf
	Else
		cNKMDESTIP := ''
	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaNKL )

Return( lok )

/** {Protheus.doc} fGetTpMv()
Identifica se o tipo de movto para
transferencias simples esta informado no parametro
MV_OGCTRMV, Se Sim, indica que deve gerar o id de
controle de movto senão é pq não controla e então
não se gera tabela de movtos.

@param: 	nil.
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGetTpMv()
	Local cCodTPMv		:=''
	Local cMvOgCtrMv	:= SuperGetMV("MV_OGCTRMV",.F.,'')
	Local aAux			:= Separa(cMvOgCtrMv, ';')
	Local nX			:=0
	Local nPosTRFM		:=0

	For nX := 1 to Len(aAux) Step 1
		IF Upper( SUBSTR(aAux[nX],1,at('|', aAux[nX]) - 1)) == 'TRFM' //TRFM Identificação de Transferencia Multipla
			nPosTRFM := nX
			Exit
		EndIF
	nExt nX

	IF nPosTRFM == 0  // Indica Q não utiliza
		cNKMTIPOMV := ' '
		cNKMDESTIP := STR0096 //'Não Utilizado'
	ElseIF nPosTRFM > 0
		cCodTPMV := Substr(aAux[ nPosTRFM ],at('|', aAux[ nPosTRFM ]) + 1,Len(aAux[ nPosTRFM]))

		cNKMTIPOMV := cCodTPMV
		cNKMDESTIP := STR0096 //'Não Utilizado'

		IF ! Empty(cCodTpMv)
			DbSelectArea( "NKL" )
			cNKMTIPOMV := cCodTPMV
			NKL->( DbSetOrder( 1 ) )
			If NKL->( DbSeek( fWxFilial( "NKL" ) + cCodTPMV ))
				cNKMTIPOMV := cCodTPMV
				IF Alltrim( NKL->NKL_ATIVO ) == '1'
					cNKMDESTIP := NKL->NKL_DESCRI
				Else
					cNKMDESTIP := STR0097 + STR0098 //'Inválido' + '( Tp. Movto Inativo)'
				EndIF
			Else
				cNKMDESTIP := STR0097 //'Inválido'
			EndIF
		EndIF
	EndIF
Return( )

/** {Protheus.doc} fGerMvID()
Função que Gera um registro de movto
na tabela de movtos do OG.
(Utilizado qdo empresa decide que o processo de transf simples
deve gerar um controle de movtos.)

@param: 	Tipo do Movto.
@Return:    o id do movto a ser Gerado;
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGerMvID( cNKMTpMv)
	Local cIdMv := ''
	Local cMsg	:= ''

	oMdlNKM := FWLoadModel( "OGA440" )
	oMdlNKM:SetOperation( MODEL_OPERATION_INSERT )
	oMdlNKM:Activate()
	oNKM:= oMdlNKM:GetModel( "NKMUNICO" )

	lRet:= oNKM:SetValue( "NKM_FILIAL"  ,   fwXfilial("NKM")	)
	lRet:= oNKM:SetValue( "NKM_TIPOMV"  ,   cNKMTpMv 			)

	If ( lRet:=oMdlNKM:VldData() )
		oMdlNKM:CommitData()
		lContinua := .t.
		cIdMV := FWFLDGET('NKM_IDMOV')   // Identificando o Id do Movto a Ser Gerado
	Else
		cMsg := oMdlNKM:GetErrorMessage()[3] + oMdlNKM:GetErrorMessage()[6]
		Help( ,,STR0049,,cMsg, 1, 0 ) //"Ajuda"
		lContinua := .F.
	EndIf
	oMdlNKM:DeActivate()

Return ( cIdMV )

/*/{Protheus.doc} Header450
//TODO Função que retorna a estrutura de um campo para cabeçalho/colunas da tela
@author Marcos Wagner
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oStruct, object, estrutura da tabela
@param cCampo, characters, campo da tabela
@param cX3Valid, characters, valid do campo
@param cX3Contexto, characters, contexto do campo virtual(V) ou real(R)
@param cX3Title, characters, Titulo para o campo
@type function
/*/
Static Function Header450(oStruct, cCampo, cX3Valid, cX3Contexto,cX3Title)
	Local aRetorno := {}
	Local aOldArea := GetArea()
	
	aADD(aRetorno,{IIF(ValType(cX3Title) == "C", cX3Title,oStruct:GetProperty(cCampo, MODEL_FIELD_TITULO)),;
	oStruct:GetProperty(cCampo, MODEL_FIELD_IDFIELD),;
	X3Picture(cCampo),;
	TamSX3(cCampo)[1],;
	TamSX3(cCampo)[2],;
	IIF(ValType(cX3Valid) == "U",X3Valid(cCampo),cX3Valid),;
	GetSX3Cache(cCampo,"X3_USADO"),; //Verificar
	oStruct:GetProperty(cCampo, MODEL_FIELD_TIPO),;
	CpoRetF3(cCampo),;
	IIF(oStruct:GetProperty(cCampo, MODEL_FIELD_VIRTUAL),"V","R"),;
	GetSX3Cache(cCampo,"X3_CBOX"),; //MODEL_FIELD_VALUES
	GetSX3Cache(cCampo,"X3_RELACAO"),;
	GetSX3Cache(cCampo,"X3_WHEN"),;
	cX3Contexto,})

	RestArea(aOldArea)

Return aRetorno[1]

/*/{Protheus.doc} OGA450AVLD
	Função para validar a quantidade disponível para transferência.
	@type  Static Function
	@author user
	@since 28/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA450AVLD()
	Local nQtd      := &(READVAR()) 
	Local nQtdOrige := 0
	Local nQtdPend  := 0	
	Local cMsg      := ""

	NJR->(DbSetOrder(1))
	( cAliasCTR )->(DbSetOrder(1))	
	If ( cAliasCTR )->(DbSeek(xFilial("NJR") + aCols[n][1] ))	
		If NJR->(dbSeek(xFilial("NJR") + aCols[n][1]))			
			If NJR->NJR_TIPO = "1" .OR. NJR->NJR_TIPO = "3"
				nQtdPend  := OGA450BRomPd(NJR->NJR_CODCTR, "%'6','8'%")
				nQtdOrige := NJR->NJR_QTEFCO - NJR->NJR_QTSFCO - ( cAliasCTR )->C_QTDFIX - ( cAliasCTR )->C_QTDRES
				//Validar posteriormente
				If nQtdOrige < 0 
					nQtdOrige := NJR->NJR_QTEFCO - NJR->NJR_QTSFCO - ( cAliasCTR )->C_QTDRES
				Endif
				//SE TIPO FOR IGUAL A 2=VENDA OU 4=DEP. EM 3º
			ElseIf NJR->NJR_TIPO  = "2" .OR. NJR->NJR_TIPO  = "4"
				nQtdPend  := OGA450BRomPd(NJR->NJR_CODCTR, "%'7','9'%")
				nQtdOrige := NJR->NJR_QTSFCO - NJR->NJR_QTEFCO - ( cAliasCTR )->C_QTDFIX - ( cAliasCTR )->C_QTDRES

				//Validar posteriormente
				If nQtdOrige < 0
					nQtdOrige := NJR->NJR_QTSFCO - NJR->NJR_QTEFCO - ( cAliasCTR )->C_QTDRES
				Endif 
			EndIf

			If nQtd > nQtdOrige - nQtdPend
				cMsg := STR0104 + CRLF + CRLF + STR0105 + cValToChar(nQtdOrige) + CRLF  //###"Quantidade não pode ser maior que a quantidade disponível." ###"Saldo contrato de origem: " 
				If nQtdPend > 0
					cMsg += STR0106 + cValToChar(nQtdPend) + CRLF 		 //###"Volume em romaneios não confirmados: "
					cMsg += STR0107 + cValToChar(nQtdOrige - nQtdPend)   // ###"Disponível para transferência: "     		
				EndIf		

				Help( , , STR0049, , cMsg, 1, 0 ) //"AJUDA"  
				Return .f.
			EndIf

			//feita consistência, pois esse erro ocorre só lá no romaneio e não é atualizado, causando impactos nos saldos de transf.
			If NJR->NJR_VLRBAS <= 0 .AND. Empty(NJR->NJR_CODIDX)
				AgrHelp(STR0049, STR0108 + alltrim(NJR->NJR_CODCTR) + STR0109, STR0110) //#O contrato ##" não possui valor base ou índice de preço. Não será possível gerar o romaneio." ##"Por favor, verifique essas informações no cadastro do contrato."
				Return .f.
			EndIf
		EndIf
	EndIf

Return .t.
