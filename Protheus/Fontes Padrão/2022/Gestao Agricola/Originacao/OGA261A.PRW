#INCLUDE "OGA261A.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#include "totvs.ch"
#include "SIGAWIN.CH"

/** {Protheus.doc} OGA261A
Rotina Acerto de serviços de armazenagem
*****
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA261A( pcCodEnt, pcLojEnt, nPosArot, lAutomato )

	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer 	 := Nil
	Local oPnEnt	 := Nil
	Local oPnTot	 := Nil
	Local oPnCtr	 := Nil
	Local nX       	 := 0
	Local oBtnAtual
	
	Local aIndice1  := Nil
	Local aIndice2  := Nil
	
	Local bTeclaF12 := SetKey( VK_F12, { || OGA261AFil(  ) } )
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//		Status Contrato Cod. Desp	Descrição 	Valor Serviço 	Qtd. Ret.										
	
	//--- Definição da estrutura da tabela temporária de Saldos    ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruTot := { { "OK", "C", 2, 0 , , } , ;
							{ "T_STATUS",	"C", TamSX3( "NKG_STATUS" )[ 1 ], 0 , RetTitle( "NKG_STATUS" ) , "@" },;
							{ "T_FILIAL", "C", TamSX3( "NKG_FILIAL" )[ 1 ], 0 , RetTitle( "NKG_FILIAL" )	, PesqPict("NKG","NKG_FILIAL") }, ;
	 						{ "T_CODCTR", "C", TamSX3( "NKG_CODCTR" )[ 1 ], 0 , RetTitle( "NKG_CODCTR" )	, PesqPict("NKG","NKG_CODCTR") }, ;
	 						{ "T_DESCTR", "C", TamSX3( "NKG_DESCTR" )[ 1 ], 0 , RetTitle( "NKG_DESCTR" )	, PesqPict("NKG","NKG_DESCTR") } , ;
	 						{ "T_CODDES",	"C", TamSX3( "NKG_CODDES" )[ 1 ], 0 , RetTitle( "NKG_CODDES" )	, PesqPict("NKG","NKG_CODDES") } , ; 
							{ "T_DESDES", "C", TamSX3( "NKG_DESDES" )[ 1 ], 0 , RetTitle( "NKG_DESDES" )	, PesqPict("NKG","NKG_DESDES") } , ;
							{ "T_CODPRO",	"C", TamSX3( "NKG_CODPRO" )[ 1 ], 0 , RetTitle( "NKG_CODPRO" )	, PesqPict("NKG","NKG_CODPRO") } , ; 
							{ "T_DESPRO", "C", TamSX3( "NKG_DESPRO" )[ 1 ], 0 , RetTitle( "NKG_DESPRO" )	, PesqPict("NKG","NKG_DESPRO") } , ;
							{ "T_VALSER", "N", TamSX3( "NKG_VALSER" )[ 1 ], TamSX3( "NKG_VALSER" )[ 2 ] , RetTitle( "NKG_VALSER" )	, PesqPict("NKG","NKG_VALSER") } , ;						
							{ "T_QTDRET", "N", TamSX3( "NKG_QTDRET" )[ 1 ], TamSX3( "NKG_QTDRET" )[ 2 ] , RetTitle( "NKG_QTDRET" )	, PesqPict("NKG","NKG_QTDRET") } , ;
							{ "T_QTDAJU", "N", TamSX3( "NKG_QTDAJU" )[ 1 ], TamSX3( "NKG_QTDAJU" )[ 2 ] , "Ajuste"	, PesqPict("NKG","NKG_QTDAJU") } , ; 
							{ "T_VLTARC", "N", TamSX3( "NKG_VLTARC" )[ 1 ], TamSX3( "NKG_VLTARC" )[ 2 ] , RetTitle( "NKG_VLTARC" )	, PesqPict("NKG","NKG_VLTARC") } , ;
	 						{ "T_QTRETC", "N", TamSX3( "NKG_QTRETC" )[ 1 ], TamSX3( "NKG_QTRETC" )[ 2 ] , RetTitle( "NKG_QTRETC" )	, PesqPict("NKG","NKG_QTRETC") } } 
							
	
							
	Local aCpBrwTot := {}
	Local aIndTot   := { "T_FILIAL+T_CODCTR+T_CODDES+T_STATUS" } // Definição dos índices
	
	//	Status	Contrato	Cod. Desp	Descrição 	Fat.Gerador	Per.Cobrança	Dt. Início		Dt. Final	Qt.Períodos	Dt. Movto	Dt.Calc.	
	//Serie	Documento	Romaneio Base Cálculo	Ajuste Base	Vl Tarifa 		Perc. Ret.		UM	Valor Serviço 	Qtd. Ret.		
	//Rom Ret	Série Serv.	Docto Serv.	Dt.Emissão		Item Serviço Descrição Item Serviço  	Observação Ajuste Base																							
	
	
	
	//--- Definição da estrutura da tabela temporária de Contratos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruDet := { { "D_STATUS", "C", TamSX3( "NKG_STATUS" )[ 1 ], 0 , RetTitle( "NKG_STATUS" ), "@" },;
	 						{ "D_FILIAL", "C", TamSX3( "NKG_FILIAL" )[ 1 ], 0 , RetTitle( "NKG_FILIAL" ), PesqPict("NKG","NKG_FILIAL") },;
	 						{ "D_CODCTR", "C", TamSX3( "NKG_CODCTR" )[ 1 ], 0 , RetTitle( "NKG_CODCTR" ), PesqPict("NKG","NKG_CODCTR") },;
	 						{ "D_ITEMOV", "C", TamSX3( "NKG_ITEMOV" )[ 1 ], 0 , RetTitle( "NKG_ITEMOV" ), PesqPict("NKG","NKG_ITEMOV") },;
	 						{ "D_CODDES", "C", TamSX3( "NKG_CODDES" )[ 1 ], 0 , RetTitle( "NKG_CODDES" ), PesqPict("NKG","NKG_CODDES") },;
	 						{ "D_DESDES", "C", TamSX3( "NKG_DESDES" )[ 1 ], 0 , RetTitle( "NKG_DESDES" ), PesqPict("NKG","NKG_DESDES") },;
	 						{ "D_CODROM", "C", TamSX3( "NKG_CODROM" )[ 1 ], 0 , RetTitle( "NKG_CODROM" ),	PesqPict("NKG","NKG_CODROM") },;
	 						{ "D_DOCSER", "C", TamSX3( "NKG_DOCSER" )[ 1 ], 0 , RetTitle( "NKG_DOCSER" ),	PesqPict("NKG","NKG_DOCSER") },;						
							{ "D_DOCNUM", "C", TamSX3( "NKG_DOCNUM" )[ 1 ], 0 , RetTitle( "NKG_DOCNUM" ),	PesqPict("NKG","NKG_DOCNUM") },;
							{ "D_DATCAL", "D", 8, 0 , RetTitle( "NKG_DATCAL" ),	"@D" },;
							{ "D_DOCEMI", "D", 8, 0 , RetTitle( "NKG_DOCEMI" ),	"@D" },;
	 						{ "D_FATGER", "C", 20, 0 , RetTitle( "NKG_FATGER" ), PesqPict("NKG","NKG_FATGER") },;
	 						{ "D_PERCOB", "C", 20, 0 , RetTitle( "NKG_PERCOB" ), PesqPict("NKG","NKG_PERCOB") },;
	 						{ "D_DATINI", "D", 8 , 0 , RetTitle( "NKG_DATINI" ),	"@D" },;
	 						{ "D_DATFIM", "D", 8 , 0 , RetTitle( "NKG_DATFIM" ),	"@D" },;
							{ "D_QTDPER", "N", TamSX3( "NKG_QTDPER" )[ 1 ], TamSX3( "NKG_QTDPER" )[ 2 ] , RetTitle( "NKG_QTDPER" ),	PesqPict("NKG","NKG_QTDPER") },;
							{ "D_PERRET", "N", TamSX3( "NKG_PERRET" )[ 1 ], TamSX3( "NKG_PERRET" )[ 2 ] , RetTitle( "NKG_PERRET" ),	PesqPict("NKG","NKG_PERRET") },;
							{ "D_VALTAR", "N", TamSX3( "NKG_VALTAR" )[ 1 ], TamSX3( "NKG_VALTAR" )[ 2 ] , RetTitle( "NKG_VALTAR" ),	PesqPict("NKG","NKG_VALTAR") },;
							{ "D_UMTAR" , "C", TamSX3( "NKG_UMTAR"  )[ 1 ], 0                           , RetTitle( "NKG_UMTAR"  ),	PesqPict("NKG","NKG_UMTAR")  },;
							{ "D_QTDBAS", "N", TamSX3( "NKG_QTDBAS" )[ 1 ], TamSX3( "NKG_QTDBAS" )[ 2 ] , RetTitle( "NKG_QTDBAS" ),	PesqPict("NKG","NKG_QTDBAS") },;
							{ "D_VALSER", "N", TamSX3( "NKG_VALSER" )[ 1 ], TamSX3( "NKG_VALSER" )[ 2 ] , RetTitle( "NKG_VALSER" ),	PesqPict("NKG","NKG_VALSER") },;
							{ "D_QTDRET", "N", TamSX3( "NKG_QTDRET" )[ 1 ], TamSX3( "NKG_QTDRET" )[ 2 ] , RetTitle( "NKG_QTDRET" ),	PesqPict("NKG","NKG_QTDRET") },;
							{ "D_QTDAJU", "N", TamSX3( "NKG_QTDAJU" )[ 1 ], TamSX3( "NKG_QTDAJU" )[ 2 ] , RetTitle( "NKG_QTDAJU" ),	PesqPict("NKG","NKG_QTDAJU") },;
							{ "D_OBSAJU", "C", TamSX3( "NKG_OBSAJU" )[ 1 ], TamSX3( "NKG_OBSAJU" )[ 2 ] , RetTitle( "NKG_OBSAJU" ),	PesqPict("NKG","NKG_OBSAJU") } } 
	
	Local aCpBrwDet 	:= {}
	Local aIndDet 	:= { "D_FILIAL+D_CODCTR+D_CODDES+D_STATUS" } // Definição dos índices
    Local bBlock    := {||}
	Local oNomEnt := NIL
	Local oNomLoj := NIL 
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasTOT 
	Private cTrabTOT 	 
	Private cAliasDET
	Private cAliasDETAux 
	Private cTrabDET	 
	Private oBrwTot, oBrwDet
	Private cAliasNKG := GetNextAlias()
	Private cAliasQry := GetNextAlias()
	
	Private cNoFldTOT	:= "T_STATUS,OK,T_CODPRO,T_DESCTR"
	Private cNoFldDET	:= "OK,D_STATUS"
	
	//--- Variáveis de parâmetros de entrada da tela ---// 
	Private cCodEnt		:= Space( TamSX3("NJ0_CODENT")[1] )
	Private cLojEnt		:= Space( TamSX3("NJ0_LOJENT")[1] )
	Private cNomEnt		:= Space( TamSX3("NJ0_NOME")  [1] )
	Private cNomLoj		:= Space( TamSX3("NJ0_NOMLOJ")[1] )
	
	Private aRotAux
	Private cMarca		:= GetMark()
	Private lSelAll		:= .f.
	Private cPergunta	:= "OGA261A" + (SPACE(1))
	
	Private cPicQtd		:= "@E 999,999,999.99"
	Private cPicVlr		:= "@E 999,999,999.99"
	Private nQtdRet		:= 0
	Private nVlr			:= 0
	Private cTesVal		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cSerVal		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cDocVal		:= Space( TamSX3( "F2_DOC"     )[1] )
	Private cObsNF		:= Space( TamSX3( "F1_MENNOTA" )[1] )
	Private cTesQtd		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cSerQtd		:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cObsNF2		:= Space( TamSX3( "F1_MENNOTA" )[1] )
	Private cComboVal	:= ""
	Private cComboRet	:= ""
	Private cComboEnt	:= ""
	Private cCondPGVal	:= Space( TamSX3( "E4_CODIGO" )[1] )
	Private cCondPGRet	:= Space( TamSX3( "E4_CODIGO" )[1] )
	Private aServicos	:= {}
	Private cCtrAjuste	:= Space( TamSX3( "NKG_CODCTR"  )[1] )
	Private cDesCtr		:= Space( TamSX3( "NKG_DESCTR"  )[1] )
	Private cDespesa	:= Space( TamSX3( "NKG_CODDES"  )[1] )
	Private cDesDesp	:= Space( TamSX3( "NKG_DESDES"  )[1] )
	Private valOrig		:= Space( TamSX3( "NKG_VALSER"  )[1] )
	Private valAjuste	:= Space( TamSX3( "NKG_VALSER"  )[1] )
	Private valServ		:= Space( TamSX3( "NKG_VALSER"  )[1] )
	Private qtdOrig		:= Space( TamSX3( "NKG_QTDRET"  )[1] )
	Private qtdAjuste	:= Space( TamSX3( "NKG_QTDRET"  )[1] )
	Private qtdRet		:= Space( TamSX3( "NKG_QTDRET"  )[1] )
	Private cObsAjuste	:= Space( TamSX3( "F1_MENNOTA"  )[1] )
	Private cContSimul	:= Space( TamSX3( "NJR_CODCTR"  )[1] )
	Private nQtdContr	:= 0
	Private dDtSimul	:= dDatabase
	Private cLocalRet	:= Space( TamSX3( "NNR_CODIGO"  )[1] )
	Private lFiltro		:= .t.
	Private cFiltroTot	:= ""
	Private cTipEnt		:= "0"
	Private cContrato	:= ""
	Private lFirst		:= .t.
	Private nItemSer	:= 1
	Private _lTipo		:= .f.
	Private _aParce		:= {}
	
	Private aServico  := {}
	Private _cTabela  := Space(4)
	Private _cCombo1  := ""
	Private lExibe    := .F.
	Private lVazio    := .T.
    Private aRotinaAut    := {"A261CALC",;
                              "A261SIMUL",;
                              "A261APROV",;
                              "A261BONIF",;
                              "A261GERNF",;
                              "A261PRINT",;
                              "A261DELET",;
                              "OGX001Ctr"}
	
	cCodEnt := IIf( Empty( pcCodEnt ), cCodEnt, pcCodEnt )
	cLojEnt := IIf( Empty( pcLojEnt ), cLojEnt, pcLojEnt )
	ValEntidade( cCodEnt, cLojEnt ) // Retorna o valor para as variáveis cNomEnt e cLojEnt
	
	/**** Criação das tabelas temporárias *****/
	
	// Tabela temporária de Totais
	aRetTRB := AGRCRIATRB( , aEstruTot, aIndTot, FunName(), .T. )
	 
	cTrabTOT 	:= aRetTRB[3] //Nome do arquivo temporário 
	cAliasTOT 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwTot	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndice1 := AGRINDICONS(aIndTot, aCpBrwTot )	//Nome nos filtros.
	
	// Tabela temporária de Detalhes
	aRetTRB := AGRCRIATRB( , aEstruDet, aIndDet, FunName(), .T. )
	 
	cTrabDET 	   := aRetTRB[3] //Nome do arquivo temporário 
	cAliasDET 	   := aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwDet	   := aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture
	
	aIndice2 := AGRINDICONS(aIndDet, aCpBrwDet )	//Nome nos filtros.
	
	Atualizar(.T.) 
	
	/******************************************/
	
	/************ Montagem da tela ************/
	If !lAutomato
        oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0007, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Tarifas Depósito de 3"
        
        //--- Layers ---//
        oFwLayer:= FwLayer():New()
        oFwLayer:Init( oDlg, .f., .t. )
        if !(FWIsInCallStack("OGA455TRVL")) //Transferência de saldo entre contratos.
            // Entidade
            oFWLayer:AddLine( 'LinEntidade', 10, .T. )				
            oFWLayer:AddCollumn( 'ColEntidade', 100, .T., 'LinEntidade' )
            oPnEnt := oFWLayer:GetColPanel( 'ColEntidade', 'LinEntidade' )
            
            // Totais
            oFWLayer:AddLine( 'LinTot', 40, .F. )
            oFWLayer:AddCollumn( 'ColSaldo', 100, .T., 'LinTot' )
            oPnTot := oFWLayer:GetColPanel( 'ColSaldo', 'LinTot' )
            
            // Detalhes
            oFWLayer:AddLine( 'LinDetalhe', 50, .F. )
            oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinDetalhe' )
            oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinDetalhe' )
            
            //--- Conteúdo dos panels ---//
                
            // Entidade
            @ 003,005  Say STR0008 COLOR CLR_BLUE Pixel Of oPnEnt //"Entidade"
            @ 001,030  MSGET cCodEnt Picture PesqPict("NJ0","NJ0_CODENT") F3 "NJ0" VALID ValEntidade(cCodEnt,) 			       WHEN .T. SIZE 040,010 PIXEL OF oPnEnt  
            @ 001,075  MSGET cLojEnt Picture PesqPict("NJ0","NJ0_LOJENT") VALID ValEntidade(cCodEnt,cLojEnt).Or.Empty(cLojEnt) WHEN .T. SIZE 020,010 PIXEL OF oPnEnt  
            @ 001,095  MSGET oNomEnt Var cNomEnt Picture PesqPict("NJ0","NJ0_NOME")   													   WHEN .F. SIZE 120,010 PIXEL OF oPnEnt  OBFUSCATED AGRLGPD("NJ0_NOME")
            @ 001,215  MSGET oNomLoj Var cNomLoj Picture PesqPict("NJ0","NJ0_NOMLOJ")   												   WHEN .F. SIZE 125,010 PIXEL OF oPnEnt  OBFUSCATED AGRLGPD("NJ0_NOME")
            // Botão Atualizar
            @ 001,340 BUTTON oBtnAtual PROMPT STR0009	 SIZE 35,012 PIXEL OF oPnEnt ACTION ( Atualizar() ) //"Atualizar"
        else
            // Totais
            oFWLayer:AddLine( 'LinTot', 40, .F. )
            oFWLayer:AddCollumn( 'ColSaldo', 100, .T., 'LinTot' )
            oPnTot := oFWLayer:GetColPanel( 'ColSaldo', 'LinTot' )
            
            // Detalhes
            oFWLayer:AddLine( 'LinDetalhe', 60, .F. )
            oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinDetalhe' )
            oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinDetalhe' )
        endIf
        
        DEFINE FWFormBrowse oBrwTot DATA TABLE ALIAS cAliasTOT DESCRIPTION STR0005 OF oPnTot //"Totais"
            oBrwTot:SetTemporary(.T.)
            oBrwTot:SetdbFFilter(.T.)
            oBrwTot:SetUseFilter(.T.)	
            oBrwTot:SetFieldFilter(AGRITEMCBRW(aCpBrwTot))	
            oBrwTot:AddLegend( "T_STATUS=='0'", "RED"    , STR0001 ) //Pendente
            oBrwTot:AddLegend( "T_STATUS=='1'", "YELLOW" , STR0002 ) //Atualização
            oBrwTot:AddLegend( "T_STATUS=='2'", "GREEN"  , STR0003 ) //Confirmado
            oBrwTot:AddLegend( "T_STATUS=='3'", "BLUE"   , STR0004 ) //Bonificado
            oBrwTot:AddLegend( "T_STATUS=='4'", "PINK"   , STR0117 ) 
            oBrwTot:AddLegend( "T_STATUS=='9'", "GRAY"   , STR0066 )
            oBrwTot:SetSeek(,aIndice1)
                
            ADD MARKCOLUMN oColumn DATA { || If(( cAliasTOT )->OK == cMarca,'LBOK','LBNO') } ;
            DOUBLECLICK { |oBrwTot| OGA261ACLK( cAliasTOT , oBrwTot) } ;
            HEADERCLICK { |oBrwTot| OGA261ACHK( cAliasTOT , oBrwTot) } OF oBrwTot	
                            
            For nx := 1 To Len(aCpBrwTot)
                If !( aCpBrwTot[nX,1] $ cNoFldTOT )
                    ADD COLUMN oColumn DATA &('{||'+aCpBrwTot[nX,1]+'}') Type aCpBrwTot[nX,2] Title aCpBrwTot[nX,5] SIZE aCpBrwTot[nX,3] PICTURE aCpBrwTot[nX,6] Of oBrwTot
                EndIf
            Next nx 
            
            oBrwTot:bChange := {|| A261ALDetAux() } 
            oBrwTot:DisableDetails()
            if !(FWIsInCallStack("OGA455TRVL")) //Transferência de saldo entre contratos.
                oBrwTot:AddButton(STR0030,		{|| A261CALC( ) },,,,,,'10')  //Calcular
                oBrwTot:AddButton(STR0028,		{|| A261SIMUL( ) },,,,,,'10') //Simular
                oBrwTot:AddButton(STR0026,		{|| A261APROV( ) },,,,,,'10') //Aprovar
                oBrwTot:AddButton(STR0027,		{|| A261BONIF( ) },,,,,,'10') //Bonificar
                oBrwTot:AddButton(STR0029,	    {|| A261GERNF( ) },,,,,,'10') //Gerar NF
                oBrwTot:AddButton(STR0064,		{|| A261PRINT( ) },,,,,,'10')  //Imprimir
                oBrwTot:AddButton(STR0065,		{|| A261DELET( ) },,,,,,'10')  //Excluir
                oBrwTot:AddButton(STR0081,		{|| OGX001Ctr( (cAliasTOT)->T_FILIAL, ( cAliasTOT )->T_CODCTR ) },,,,,,'10')  //"Contrato"
            else
                //Somente o bonificar
                oBrwTot:AddButton(STR0027,		{|| A261BONIF( ) },,,,,,'10') //Bonificar
            endIf
            
        ACTIVATE FWFormBrowse oBrwTot

	DEFINE FWFormBrowse oBrwDet DATA TABLE ALIAS cAliasDET DESCRIPTION STR0006 OF oPnCtr //"Detalhes"
	    oBrwDet:SetTemporary(.T.)
		oBrwDet:SetdbFFilter(.T.)
		oBrwDet:SetUseFilter(.T.)	
		oBrwDet:SetFieldFilter(AGRITEMCBRW(aCpBrwDet))	
		oBrwDet:AddLegend( "D_STATUS=='0'" , "RED"	  , STR0001 ) //Pendente
		oBrwDet:AddLegend( "D_STATUS=='1'" , "YELLOW" , STR0002 ) //Atualização
		oBrwDet:AddLegend( "D_STATUS=='2'" , "GREEN"  , STR0003 ) //Confirmado
		oBrwDet:AddLegend( "D_STATUS=='3'" , "BLUE"	  , STR0004 ) //Bonificado
		oBrwDet:AddLegend( "D_STATUS=='4'" , "PINK"   , STR0117 )
		oBrwDet:AddLegend( "D_STATUS=='9'" , "GRAY"   , STR0066 ) //Simulado
		oBrwDet:SetSeek(,aIndice2)
					
		For nX := 1 To Len(aCpBrwDet)
			If !( aCpBrwDet[nX,1] $ cNoFldDET )
				ADD COLUMN oColumn DATA &('{||'+aCpBrwDet[nX,1]+'}') Type aCpBrwDet[nX,2] Title aCpBrwDet[nX,5] SIZE aCpBrwDet[nX,3] PICTURE aCpBrwDet[nX,6] Of oBrwDet
			EndIf
		Next nX
		
		oBrwDet:DisableDetails()		
		oBrwDet:AddButton(STR0025,		{|| oDlg:End() },,,,,,'10')	
		oBrwDet:AddButton(STR0118,		{|| OGX001Rom( (cAliasDET)->D_FILIAL, (cAliasDET)->D_CODROM ) },,,,,,'10')  //"Romaneio"
	ACTIVATE FWFormBrowse oBrwDet

    oDlg:Activate( , , , .t., { || .t. }, , { || } )
Else    
    OGA261ACLK( cAliasTOT, , .T.  ) //Marca Registro no Browse
    bBlock := &( "{ |a| " + aRotinaAut[ nPosArot] + "(a) }" )
    Eval( bBlock, lAutomato )
EndIf

//--- Apaga as tabelas temporárias ---//
AGRDELETRB( cAliasTOT,    cTrabTOT )  
AGRDELETRB( cAliasDET,    cTrabDET ) 

SetKey( VK_F12, bTeclaF12 )	

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	01/12/14
@Uso: 		OGA261A - Tarifas Depósito de 3
*/
Static Function MenuDef()    
Local aRotina := {}

aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } ) 

Return( aRotina )


/** {Protheus.doc} A261ALoadTot()
Carrega dados da tabela temporária de Saldos.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261ALoadTot()

Local aAreaAtu	:= GetArea()
Local cAliasCab	:= GetNextAlias()
Local aContrato   := {}

//--- Apaga conteúdo anterior da tabela temporária TOT ---//
A261AZapTRB( cAliasTOT )

	if !(FWIsInCallStack("OGA455DTAL")) .AND. !(FWIsInCallStack("OGA455TRVL"))
		If lFiltro
			
			cFiltroTot := ""
			cFiltroTot += " AND NKG_FILIAL >= '" + MV_PAR01 + "'"
			cFiltroTot += " AND NKG_FILIAL <= '" + MV_PAR02 + "'"
			
			cFiltroTot += " AND NKG_CODDEV = '" + cCodEnt + "'"
			If !Empty( AllTrim( cLojEnt ) )
				cFiltroTot += " AND NKG_LOJDEV = '" + cLojEnt + "'"
				cNoFldTOT	:= "T_STATUS,OK,T_CODPRO,T_DESCTR"
			EndIf
			
			If !(Empty(MV_PAR13))
				cFiltroTot += " AND NKG_DOCEMI >= '" + DTOS(MV_PAR13) + "'"
			Endif
			
			If !(Empty(MV_PAR14))
				cFiltroTot += " AND NKG_DOCEMI <= '" + DTOS(MV_PAR14) + "'"
			Endif
				
			If !(Empty(MV_PAR03))
				cFiltroTot += " AND NKG_CODCTR >= '" + MV_PAR03 + "'"
			Endif
			
			If !Empty(MV_PAR04)
				cFiltroTot += " AND NKG_CODCTR <= '" + MV_PAR04 + "'"
			Endif
			
			If !Empty(MV_PAR07)
				cFiltroTot += " AND NKG_CODDES >= '" + MV_PAR07 + "'"	
			Endif
			
			If !Empty(MV_PAR08)
				cFiltroTot += " AND NKG_CODDES <= '" + MV_PAR08 + "'"
			Endif
			
			If !Empty(MV_PAR05)
				cFiltroTot += " AND NKG_CODTSE >= '" + MV_PAR05 + "'" 	
			Endif
			
			If !Empty(MV_PAR06)
				cFiltroTot += " AND NKG_CODTSE <= '" + MV_PAR06 + "'"
			Endif
			
			If !Empty(MV_PAR09)
				cFiltroTot += " AND NKG_CODPRO >= '" + MV_PAR09 + "'"
			Endif
			
			If !Empty(MV_PAR10)
				cFiltroTot += " AND NKG_CODPRO <= '" + MV_PAR10 + "'"
			Endif
			
			If !Empty(MV_PAR11)
				cFiltroTot += " AND NKG_CODSAF >= '" + MV_PAR11 + "'"
			Endif
			
			If !Empty(MV_PAR12)
				cFiltroTot += " AND NKG_CODSAF <= '" + MV_PAR12 + "'"
			Endif
			cFiltroTot += GetStatus()
			cFiltroTot := "%" + cFiltroTot + "%"
		Endif
	else
		cFiltroTot := _cFltTot
		
//		cFiltroTot += GetStatus()
		cFiltroTot := "%" + cFiltroTot + "%"
	endIf

//--- Query para trazer os totais ---//
BeginSql Alias cAliasCab

	SELECT ' ' as OK
	      ,NKG_FILIAL 
	      ,NKG_STATUS 
	      ,NKG_CODCTR
	      ,NKG_CODDES	      
	      ,NKG_CODPRO
	      ,SUM(NKG_VALSER) as NKG_VALSER
	      ,SUM(NKG_QTDRET) as NKG_QTDRET	      
	      ,SUM(NKG_QTDAJU) as NKG_QTDAJU
	      ,SUM(NKG_VLTARC) as NKG_VLTARC
	      ,SUM(NKG_QTRETC) as NKG_QTRETC
	  FROM %Table:NKG% NKG
	 WHERE NKG.%notDel%
	    %exp:cFiltroTot%
	GROUP BY NKG_FILIAL 
	      ,NKG_CODCTR
	      ,NKG_CODDES  
	      ,NKG_STATUS		     
	      ,NKG_CODPRO 	      
EndSQL

DbselectArea( cAliasCab )
DbGoTop()
While ( cAliasCab )->( !Eof() )

	aContrato :=  GetContrato( ( cAliasCab )->NKG_CODCTR )

	RecLock( cAliasTOT, .T. )
		( cAliasTOT )->OK 	   		:= ( cAliasCab )->OK
		( cAliasTOT )->T_FILIAL 	:= ( cAliasCab )->NKG_FILIAL
		( cAliasTOT )->T_STATUS 	:= ( cAliasCab )->NKG_STATUS
		( cAliasTOT )->T_CODCTR 	:= ( cAliasCab )->NKG_CODCTR
		( cAliasTOT )->T_DESCTR 	:= aContrato[1]
		( cAliasTOT )->T_DESPRO 	:= aContrato[2]
		( cAliasTOT )->T_CODDES 	:= ( cAliasCab )->NKG_CODDES
		( cAliasTOT )->T_DESDES 	:= POSICIONE('NJT',1,XFILIAL('NJT')+( cAliasCab )->NKG_CODDES,'NJT_DESCRI')
		( cAliasTOT )->T_VALSER 	:= ( cAliasCab )->NKG_VALSER
		( cAliasTOT )->T_QTDRET 	:= ( cAliasCab )->NKG_QTDRET	
		( cAliasTOT )->T_QTDAJU 	:= ( cAliasCab )->NKG_QTDAJU
		( cAliasTOT )->T_VLTARC 	:= ( cAliasCab )->NKG_VLTARC
		( cAliasTOT )->T_QTRETC 	:= ( cAliasCab )->NKG_QTRETC
	( cAliasTOT )->( MsUnLock() )

	( cAliasCab )->( DbSkip() )
EndDo
( cAliasCab )->( DbCloseArea() )
( cAliasTOT )->(dbGoTop())

A261ALoadDet()
If Type("oBrwTot") <> "U"
	oBrwTot:Refresh(.T.)
EndIf

RestArea( aAreaAtu )
Return 

/** {Protheus.doc} A261ALDetAux
Carrega dados da tabela temporária de Detalhes dos Movimentos de Serviços de Armazenagem.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	04/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261ALDetAux()

Local cStatus		:= ( cAliasTOT )->T_STATUS 
Local cCodCtr 	:= ( cAliasTOT )->T_CODCTR
Local cCodDes 	:= ( cAliasTOT )->T_CODDES


CursorWait()  // Mudando o Cursor para Esperar

//--- Apaga conteúdo anterior da tabela temporária CTR ---//
A261AZapTRB( cAliasDET )

//Posiciona no inicio do arquivo temporário
ARGSETIFARQUI(cAliasQry)

While !Eof()                        
	
	If  ( cAliasQry )->NKG_STATUS = cStatus .And. ;
		( cAliasQry )->NKG_CODCTR = cCodCtr .And. ;
		( cAliasQry )->NKG_CODDES = cCodDes

		RecLock( cAliasDET, .T. )
			( cAliasDET )->D_STATUS 	:= ( cAliasQry )->NKG_STATUS
			( cAliasDET )->D_FILIAL 	:= ( cAliasQry )->NKG_FILIAL
			( cAliasDET )->D_CODCTR 	:= ( cAliasQry )->NKG_CODCTR
			( cAliasDET )->D_ITEMOV := ( cAliasQry )->NKG_ITEMOV
			( cAliasDET )->D_CODDES 	:= ( cAliasQry )->NKG_CODDES
			( cAliasDET )->D_DESDES 	:= POSICIONE('NJT',1,XFILIAL('NJT')+( cAliasQry )->NKG_CODDES,'NJT_DESCRI')
			( cAliasDET )->D_FATGER 	:= X3CboxDesc( "NKG_FATGER", ( cAliasQry )->NKG_FATGER )
			( cAliasDET )->D_PERCOB	:= X3CboxDesc( "NKG_PERCOB", ( cAliasQry )->NKG_PERCOB )
			( cAliasDET )->D_DATINI 	:= StoD( ( cAliasQry )->NKG_DATINI )
			( cAliasDET )->D_DATFIM 	:= StoD( ( cAliasQry )->NKG_DATFIM )
			( cAliasDET )->D_QTDPER 	:= ( cAliasQry )->NKG_QTDPER
			( cAliasDET )->D_DATCAL 	:= StoD( ( cAliasQry )->NKG_DATCAL )
			( cAliasDET )->D_DOCEMI 	:= StoD( ( cAliasQry )->NKG_DOCEMI )
			( cAliasDET )->D_DOCSER 	:= ( cAliasQry )->NKG_DOCSER
			( cAliasDET )->D_DOCNUM 	:= ( cAliasQry )->NKG_DOCNUM
			( cAliasDET )->D_CODROM 	:= ( cAliasQry )->NKG_CODROM
			( cAliasDET )->D_QTDBAS 	:= ( cAliasQry )->NKG_QTDBAS
			( cAliasDET )->D_VALTAR 	:= ( cAliasQry )->NKG_VALTAR
			( cAliasDET )->D_PERRET 	:= ( cAliasQry )->NKG_PERRET
			( cAliasDET )->D_UMTAR 	:= ( cAliasQry )->NKG_UMTAR
			( cAliasDET )->D_VALSER 	:= ( cAliasQry )->NKG_VALSER
			( cAliasDET )->D_QTDRET  := ( cAliasQry )->NKG_QTDRET
			( cAliasDET )->D_QTDAJU 	:= ( cAliasQry )->NKG_QTDAJU
			( cAliasDET )->D_OBSAJU 	:= ( cAliasQry )->NKG_OBSAJU
		( cAliasDET )->( MsUnLock() )
	EndIf

	AGRDBSELSKIP(cAliasQry)
EndDo


If Type("oBrwDet") <> "U"
	oBrwDet:Refresh(.T.)
EndIf	

CursorArrow() // Retornando o Cursor
Return

/** {Protheus.doc} A261ALoadDet
Carrega dados da tabela temporária de Detalhes dos Movimentos de Serviços de Armazenagem.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	23/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261ALoadDet()	
	Local aAreaAtu	:= GetArea()
	Local cFiltroDet := ""
	
	If (Select(cAliasQry) > 0 )
		ARGCLOSEAREA(cAliasQry)
	Endif
	
	if !(FWIsInCallStack("OGA455DTAL")) .AND. !(FWIsInCallStack("OGA455TRVL"))
		Pergunte(cPergunta,.f.)

		cFiltroDet := "     NKG_FILIAL >= '" + MV_PAR01 + "'"
		cFiltroDet += " AND NKG_FILIAL <= '" + MV_PAR02 + "'"
		cFiltroDet += " AND NKG_CODDEV  = '" + cCodEnt  + "'"
		
		If !Empty( AllTrim( cLojEnt ) )
			cFiltroDet   += " AND NKG_LOJDEV = '" + cLojEnt + "'"
		Endif
		
		If lFiltro 
			If !(Empty(MV_PAR13))
				cFiltroDet += " AND NKG_DOCEMI >= '" + DTOS(MV_PAR13) + "'"
			Endif
			
			If !(Empty(MV_PAR14))
				cFiltroDet += " AND NKG_DOCEMI <= '" + DTOS(MV_PAR14) + "'"
			Endif
			
			If !(Empty(MV_PAR03))
				cFiltroDet += " AND NKG_CODCTR >= '" + MV_PAR03 + "'"
			Endif
			
			If !Empty(MV_PAR04)
				cFiltroDet += " AND NKG_CODCTR <= '" + MV_PAR04 + "'"
			Endif
			
			If !Empty(MV_PAR07)
				cFiltroDet += " AND NKG_CODDES >= '" + MV_PAR07 + "'"	
			Endif
			
			If !Empty(MV_PAR08)
				cFiltroDet += " AND NKG_CODDES <= '" + MV_PAR08 + "'"
			Endif
			
			If !Empty(MV_PAR05)
				cFiltroDet += " AND NKG_CODTSE >= '" + MV_PAR05 + "'" 	
			Endif
			
			If !Empty(MV_PAR06)
				cFiltroDet += " AND NKG_CODTSE <= '" + MV_PAR06 + "'"
			Endif
					
			If !Empty(AllTrim(MV_PAR09))
				cFiltroDet += " AND NKG_CODPRO >= '" + MV_PAR09 + "'"
			Endif
			
			If !Empty(AllTrim(MV_PAR10))
				cFiltroDet += " AND NKG_CODPRO <= '" + MV_PAR10 + "'"
			Endif
			
			If !Empty(MV_PAR11)
				cFiltroDet += " AND NKG_CODSAF >= '" + MV_PAR11 + "'"
			Endif
			
			If !Empty(MV_PAR12)
				cFiltroDet += " AND NKG_CODSAF <= '" + MV_PAR12 + "'"
			Endif
			
			cFiltroDet += GetStatus()
		Endif
	else
		cFiltroDet := _cFltDet		
	endIF
	
	lFiltro := .F.	

	cFiltroDet += " GROUP BY NKG_FILIAL ,NKG_CODCTR ,NKG_ITEMOV ,NKG_CODDES ,NKG_STATUS ,NKG_FATGER ,NKG_PERCOB ,NKG_DATINI ,NKG_DATFIM ,NKG_QTDPER "
	cFiltroDet += " ,NKG_DATCAL ,NKG_DOCEMI ,NKG_DOCSER ,NKG_DOCNUM ,NKG_CODROM ,NKG_QTDBAS ,NKG_QTDAJU ,NKG_VALTAR ,NKG_PERRET ,NKG_UMTAR ,NKG_VALSER, NKG_QTDRET, NKG_QTDPER ,NKG_OBSAJU "
	//cFiltroDet += " ORDER BY NKG_FILIAL ,NKG_CODCTR ,NKG_ITEMOV  "
	cFiltroDet := "%" + cFiltroDet + "%" 
	
	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	A261AZapTRB( cAliasDET )
	
	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry
		SELECT NKG_STATUS
		      ,NKG_FILIAL
		      ,NKG_CODCTR
		      ,NKG_ITEMOV
		      ,NKG_CODDES
		      ,NKG_FATGER  
		      ,NKG_PERCOB
		      ,NKG_DATINI
		      ,NKG_DATFIM
		      ,NKG_QTDPER
		      ,NKG_DATCAL
		      ,NKG_DOCEMI
		      ,NKG_DOCSER
		      ,NKG_DOCNUM
		      ,NKG_CODROM
		      ,NKG_QTDBAS
		      ,NKG_QTDAJU
		      ,NKG_VALTAR
		      ,NKG_PERRET
		      ,NKG_UMTAR
		      ,NKG_VALSER
		      ,NKG_QTDRET
		      ,NKG_QTDPER
		      ,NKG_OBSAJU
		  FROM %Table:NKG% NKG
		 WHERE NKG.%notDel%
		   AND %exp:cFiltroDet%
	EndSQL
	
	A261ALDetAux()
	
	RestArea( aAreaAtu )
Return 


/** {Protheus.doc} A261AZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	Bruna Rocio
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261AZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()
	
	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	EndIF
	
	RestArea( aAreaAtu )
Return

/** {Protheus.doc} getCliente
Retorna um array com o código e loja de cliente da entidade.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	06/01/15
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function getCliente( pcEntidade, pcLoja )
	
	Local aRet := { , }
	
	dbSelectArea('NJ0')
	dbSetOrder(1)
	If (dbSeek( xFilial('NJ0') + pcEntidade + pcLoja ))
	
		aRet[1] := NJ0->NJ0_CODCLI
		aRet[2] := NJ0->NJ0_LOJCLI
				
	EndIf
	
Return ( aRet )

/** {Protheus.doc} Atualizar()

@param:	Nil 	
@author: 	Bruna Rocio
@since: 	06/01/15
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function Atualizar( lFirstTime )
	Default lFirstTime := .F.
	
	// Se acabou de abrir a tela
	If lFirstTime
		OGA261AFil() //Abre a tela de parâmetros
		lFirstTime := .F.
	Else
		lFiltro := .t.
		A261ALoadTot()
	EndIf
	
Return ( .T. )

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
		cNomEnt := NJ0->( NJ0_NOME ) 
		If !Empty( AllTrim( pcLojEnt ) )
			cNomLoj := NJ0->( NJ0_NOMLOJ ) 
		Else
			cNomLoj := Space( TamSX3( "NJ0_NOMLOJ" )[1] )
		EndIf
	Else
		Return( .F. )
	EndIf

Return( .T. )

/** {Protheus.doc} OGA261AFil()
Filtra os registros por faixa de data

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	01/12/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA261AFil( )
	
	if !(FWIsInCallStack("OGA455DTAL")) .AND. !(FWIsInCallStack("OGA455TRVL"))
		Pergunte(cPergunta,.t.)
	endIF
			
	lFiltro := .t.		
	A261ALoadTot()	

Return

/** {Protheus.doc} OGA261ACLK()
Marca/Desmarca registro

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	01/12/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA261ACLK( pcAliasTRB, pOBrw, lAutomato  )
	Default lAutomato := .F.

	If !(pcAliasTRB)->( Eof() )		
		RecLock(pcAliasTRB, .F.)
		(pcAliasTRB)->OK := IIf((pcAliasTRB)->OK=cMarca,' ',cMarca)
		MsUnlock(pcAliasTRB)
	EndIf
	If !lAutomato		
	    pOBrw:Refresh()			
    EndIf
Return


/** {Protheus.doc} A261AQTREG
Função para calcular o total selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A261AQTREG()
	
	Local nQtdReg := 0

	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)

	While !(cAliasTOT)->( Eof() )
	
		If (cAliasTOT)->OK = cMarca	
			nQtdReg +=1		
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTOT)	
	EndDo

Return ( nQtdReg )

Static Function ValidFilial()
	
	Local cFil := ""
	
	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)

	While !(cAliasTOT)->( Eof() )
	
		If (cAliasTOT)->OK = cMarca	
			
			If Empty(cFil)
				cFil := (cAliasTOT)->T_FILIAL
			Else
				If cFil <> (cAliasTOT)->T_FILIAL
					Help(, , STR0033, , STR0115, 1, 0 )
					Return .f.
				EndIf	 		
			Endif	
					
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTOT)	
	EndDo

Return ( .t. )

/** {Protheus.doc} OGA261APRINT
Função chamada para imprimir o extrato 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	18/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261PRINT(lAutomato)
    Default lAutomato := .f.
	OGR262()

Return

/** {Protheus.doc} OGA261AUNSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA261AUNSEL( pcAliasTRB )
	
	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
				
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := ' '
		msUnLock(pcAliasTRB)		
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 

/** {Protheus.doc} OGA261ATSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA261ATSEL( pcAliasTRB )
	
	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
			
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := cMarca
		msUnLock(pcAliasTRB)
								
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 

/** {Protheus.doc} OGA261ACHK
Função para marcar/desmarcar todos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA261ACHK( pcAliasTRB, pOBrw )
	
	If lSelAll
		OGA261ATSEL( pcAliasTRB )
	Else
		OGA261AUNSEL( pcAliasTRB )		
	Endif
	
	DbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( DbGoTop() )

	pOBrw:Refresh()

Return 

/** {Protheus.doc} A261DELET
Função para exclusão dos cálculos

@param: 	pnOp       - Opção 1/Calcular por Total 2/Calcular por registro
			poBrwTot   - Grid Totais
			poBrwDet   - Grid Detalhes
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261DELET( lAutomato )
	
	Local nQtdReg := A261AQTREG()

    Default lAutomato := .f.
	
	If nQtdReg <= 0
		Help(, , STR0033, , STR0067, 1, 0 )	 	
	Else
		If .Not. MsgYesNo( STR0068, STR0069) //"Tem certeza que deseja realizar o cálculo de serviços?"###"Cálculo de Serviços"
			Return
		Else
			MsgRun( STR0070, STR0071, {|| A261DELREG( ) } )
			A261ALoadTot()
			oBrwTot:Refresh(.t.)
		Endif
	Endif	
					
Return

/** {Protheus.doc} A261DELREG
Função para eliminação dos calculos pendentes

@param: 	Nil
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function A261DELREG( )
			
	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)
					
	While !(cAliasTOT)->( Eof() )
	
		If (cAliasTOT)->OK = cMarca	
									
			//Posiciona no inicio do arquivo temporario
			dbSelectArea(cAliasQry)	
			dbGoTop()	
			While !Eof()
				
				If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
					( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
					( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES 
			
					dbSelectArea('NKG')
					dbSetOrder(1)
					If dbSeek( xFilial('NKG')+(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV )
						If 	NKG->NKG_STATUS <> '2'
							RecLock('NKG',.F.)
						   DbDelete()
						   MsUnLock()
						Else
							Help(, , STR0033, , STR0072, 1, 0 )
							Return
						Endif
					Else
						Help(, , STR0033, , STR0072, 1, 0 )
						Return 
					Endif
				Endif		
				
				dbSelectArea(cAliasQry)
				dbSkip()
			EndDo
		Endif		
		dbSelectArea(cAliasTOT)
		dbSkip()	
	EndDo
	dbSelectArea(cAliasTOT)	
	dbGoTop()	
	dbSelectArea(cAliasDET)	
	dbGoTop()		
Return

/** {Protheus.doc} ValidAprov
Função para validação dos dados antes da aprovação

@param: 	
@author: 	Bruna Rocio
@since: 	13/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ValidAprov()

	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)
					
	While !Eof()
	
		If    (cAliasTOT)->OK = cMarca ;
		.And. (cAliasTOT)->T_STATUS <> '0' 	
		
			Help(, , STR0033, , STR0076, 1, 0 )
			Return .f.
		Endif	
		AGRDBSELSKIP(cAliasTOT)		
	EndDo
	
Return ( .t. )

/** {Protheus.doc} A261APROV
Função para aprovação dos calculos pendentes

@param: 	pnOp       - Opção 1/Calcular por Total 2/Calcular por registro
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261APROV( lAutomato )
	
	Local nQtdReg := 0

    Default lAutomato := .f.
	
	If ValidFilial()
		
		ARGSETIFARQUI(cAliasTOT)
			
		nQtdReg := A261AQTREG()
		If nQtdReg > 0
			If ValidAprov()
				MsgRun( STR0073, STR0074	, {|| ATULTOTAL() } )
			EndIf	
		Else
			Help(, , STR0033, , STR0075, 1, 0 )
		Endif
	Endif					
Return

/** {Protheus.doc} ATULTOTAL
Função para aprovação dos calculos pendentes

@param: 	Nil 
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ATULTOTAL()

	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)
					
	While !Eof()
	
		If (cAliasTOT)->OK = cMarca	
		
			//Posiciona no inicio do arquivo temporario
			ARGSETIFARQUI(cAliasQry)		
			
			While !Eof()
			
				If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
					( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
					( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES 
									
					//Busca o registro com a chave primária
					IF AGRIFDBSEEK('NKG',(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV,1,.f.)
						
						If NKG->NKG_STATUS <> '0'
							Help(, , STR0033, , STR0076, 1, 0 )
							Return
						Else
							RecLock('NKG',.f. )							
							If NKG->NKG_TIPRET = '1' // Cobrança Retenção
	                         NKG->NKG_STATUS := '4' //Negoc Pendente
	                     Else  
	                         NKG->NKG_STATUS := '1' //Atualizado
	                     Endif  
							
							MsUnlock()	
						Endif	
					Endif		
				EndIf			
				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasQry)			
			EndDo				
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTOT)		
	EndDo
	A261ALoadTot()
	oBrwTot:Refresh(.t.)
		
Return 


/** {Protheus.doc} A261BONIF
Função para aprovação dos calculos pendentes

@param: 	pnOp       - Opção 1/Calcular por Total 2/Calcular por registro
			poBrwTot   - Grid Totais
			poBrwDet   - Grid Detalhes
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function A261BONIF( lAutomato )
	
	Local nQtdReg 	:= A261AQTREG()
	Local lValor  	:= .T.
	Local lRet		:= .T.
	Local lOGA455	:= (FWIsInCallStack("OGA455TRVL"))	
	Local oModel 	

    Default lAutomato := .f.
	
	If ValidFilial()
		
		If nQtdReg <= 0
			Help(, , STR0033, , STR0077, 1, 0 )		
		ElseIf nQtdReg > 1
			Help(, , STR0033, , STR0078, 1, 0 )
		Else
		
			//Posiciona no inicio do arquivo temporário
			ARGSETIFARQUI(cAliasTOT)

			While !Eof()

				If (cAliasTOT)->OK = cMarca	

					If (cAliasTOT)->T_STATUS = '0' .Or. (cAliasTOT)->T_STATUS = '2' //0-Pendente#2-Confirmado  
						Help(, , STR0033, , STR0079, 1, 0 )
						Return .f. 
					Endif

					cCtrAjuste := (cAliasTOT)->T_CODCTR 
					cDesCtr    := (cAliasTOT)->T_DESCTR
					cDespesa   := (cAliasTOT)->T_CODDES
					cDesDesp   := (cAliasTOT)->T_DESDES
					valOrig    := (cAliasTOT)->T_VLTARC
					valAjuste  := IIF( (cAliasTOT)->T_VALSER > 0,(cAliasTOT)->T_QTDAJU,0)
					valServ    := (cAliasTOT)->T_VALSER
					qtdOrig    := (cAliasTOT)->T_QTRETC
					qtdAjuste  := IIF( (cAliasTOT)->T_QTDRET > 0,(cAliasTOT)->T_QTDAJU,0)
					qtdRet     := (cAliasTOT)->T_QTDRET
					lValor     := IIF( (cAliasTOT)->T_QTRETC > 0,.f.,.t.)
				Endif	
				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasTOT)
			EndDo		
				
			A261AJUST( lValor,lAutomato )
		Endif
		If !lAutomato
			A261ALoadTot()
			oBrwTot:Refresh(.t.)
		Endif
		
		if lOGA455
			aArea := GetArea()
			
			oModel := FWLoadModel('OGA455')
			
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
			
			dbSelectArea("NBV")
			NBV->(dbSetOrder(2))
			if NBV->(dbSeek(FWxFilial('NBV')+cCodTrf+cCtrAjuste+cDespesa+"1"))
				if RecLock('NBV',.F.)
		       		NBV->NBV_VALOR := valServ
		       		MsUnlock()
		       	else
		       		lRet := .F.
	       		endIf
			endIf
			restArea(aArea)
			
			if lRet
				if RecLock('NBT',.F.)
		       		NBT->NBT_SERVIC := "3"
		       		MsUnlock()
		       	else
		       		lRet := .F.
	       		endIf
	       	endIf
		endIf
	Endif
Return lRet


/** {Protheus.doc} A261AJUST
Função para aprovação dos calculos pendentes

@param: 	plValor - Indica se a bonificação é por valor
@author: 	Bruna Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function A261AJUST( plValor,lAutomato )

	Local lRetorno	:= .t.
	Local nDecPeso	:= SuperGetMV("MV_OGDECPS",,0)
	Local nDecDic	:= AGRSEEKDIC("SX3","NKG_VALSER",2,"X3_DECIMAL")
	Local cPict		:= "@E 999,999,999."+Replicate("9",If(nDecPeso = 0,nDecDic,If(nDecPeso < nDecDic,nDecPeso,nDecDic)))

	If !lAutomato 			

		DEFINE MSDIALOG oDlgAjuste TITLE STR0080 FROM 0,0 TO 220,580 PIXEL

		@ 015,020 Say OemToAnsi(STR0081)       Of oDlgAjuste Pixel 
		@ 013,050 MSGET oContrato  Var cCtrAjuste Picture "@!" When .f. Of oDlgAjuste Pixel SIZE 050, 008
		@ 013,100 MSGET oDesCtr    Var cDesCtr    Picture "@!" When .f. Of oDlgAjuste Pixel SIZE 180 , 008
		
		@ 030,020 Say OemToAnsi(STR0082)       Of oDlgAjuste Pixel 
		@ 028,050 MSGET oDespesa Var cDespesa    Picture "@!" When .f. Of oDlgAjuste Pixel SIZE 050, 008
		@ 028,100 MSGET oDesDesp Var cDesDesp    Picture "@!" When .f. Of oDlgAjuste Pixel SIZE 180, 008
		
		@ 045,020 Say OemToAnsi(STR0083) Of oDlgAjuste Pixel
		@ 045,050 MSGET oValOrig Var valOrig     Picture "@E 999,999,999.99" When .f.      Of oDlgAjuste Pixel SIZE 050, 008
		@ 045,105 Say OemToAnsi(STR0084)    Of oDlgAjuste Pixel
		@ 045,135 MSGET oValAjuste Var valAjuste Picture cPict When plValor VALID vldAjSer()  Of oDlgAjuste Pixel SIZE 050, 008
		@ 045,190 Say OemToAnsi(STR0085)   Of oDlgAjuste Pixel
		@ 045,220 MSGET oValSer Var valServ      Picture "@E 999,999,999.99" When .f.      Of oDlgAjuste Pixel SIZE 050, 008
		
		@ 060,020 Say OemToAnsi(STR0086) Of oDlgAjuste Pixel 
		@ 058,050 MSGET oQtdOrig Var qtdOrig     Picture "@E 999,999,999.99" When .f.      Of oDlgAjuste Pixel SIZE 050, 008
		@ 060,105 Say OemToAnsi(STR0087)    Of oDlgAjuste Pixel 
		@ 058,135 MSGET oQtdAjust Var qtdAjuste  Picture cPict When !plValor VALID vldQtRet() Of oDlgAjuste Pixel SIZE 050, 008
		@ 060,190 Say OemToAnsi(STR0088)       Of oDlgAjuste Pixel 
		@ 058,220 MSGET oQtdRet Var qtdRet       Picture "@E 999,999,999.99" When .f. 	   Of oDlgAjuste Pixel SIZE 050, 008
		
		@ 075,020 Say OemToAnsi(STR0089) Of oDlgAjuste Pixel 
		@ 073,050 MSGET oObsAjuste Var cObsAjuste Picture "@!"  VALID ValObservacao() Of oDlgAjuste Pixel SIZE 220, 008
				
		DEFINE SBUTTON FROM 90,220 TYPE 1 ACTION (A261ATUREG( plValor ), oDlgAjuste:End())  ENABLE OF oDlgAjuste
		DEFINE SBUTTON FROM 90,250 TYPE 2 ACTION (lRetorno := .f.      , oDlgAjuste:End())  ENABLE OF oDlgAjuste

		ACTIVATE MSDIALOG oDlgAjuste CENTER

	Else
		qtdAjuste := 1
		vldAjSer()
		vldQtRet()
		A261ATUREG( plValor )
	EndIf
	
Return

/** {Protheus.doc} vldAjSer

@param: 	
@author: 	Bruna Rocio
@since: 	06/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function vldAjSer()
	
	valServ = valOrig - valAjuste
			
Return ( .t. )

/** {Protheus.doc} vldQtRet

@param: 	
@author: 	Bruna Rocio
@since: 	06/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function vldQtRet()

	qtdRet = qtdOrig - qtdAjuste
	
Return ( .t. )


/** {Protheus.doc} ValObservacao
Função para validação da observação da bonificação

@param: 	
@author: 	Bruna Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function ValObservacao()
	
	Local lRetorno := .t.
	
	If Empty(AllTrim(cObsAjuste))
		Help(, , STR0033, , STR0090, 1, 0 )
		lRetorno := .f.
	Endif
	
Return lRetorno

/** {Protheus.doc} A261ATUREG
Função para bonificação dos registros

@param: 	
@author: 	Bruna Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function A261ATUREG( plValor )

	Local deSaldo     := IIf(plValor = .t., valAjuste, qtdAjuste)
				 
	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTOT)
				
	While !Eof()
	
		If (cAliasTOT)->OK = cMarca	
								
			//Posiciona no inicio do arquivo temporario
			ARGSETIFARQUI(cAliasQry)		
			
			While !Eof()
				//Busca o registro com a chave primária
				
				If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
					( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
					( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES
				
					IF AGRIFDBSEEK('NKG',(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV,1,.f.)
						
				       If plValor 
				       	If deSaldo >= NKG->NKG_VLTARC
				       		RecLock('NKG',.f.)
					       		NKG->NKG_QTDAJU := NKG->NKG_VLTARC
					       		NKG->NKG_OBSAJU := cObsAjuste
					       		NKG->NKG_VALSER := 0    // bonificado 100%
					       		NKG->NKG_STATUS := '3'    // 3=Bonificado
				       		deSaldo         := deSaldo - NKG->NKG_VLTARC
				       		MsUnlock()
				       	ElseIf deSaldo = 0
				       		RecLock('NKG',.f.)
					       		NKG->NKG_QTDAJU := deSaldo
							       NKG->NKG_OBSAJU := ""
							       NKG->NKG_VALSER := NKG->NKG_VLTARC   // bonificado parcial
					       		If NKG->NKG_TIPRET = '1'
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','4')  //9=Simulado#4=Negoc.Pend
				              	Else
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','1')  //9=Simulado#1=Atualizado
				              	Endif
				       		MsUnlock() 
				       	Else
				       		RecLock('NKG',.f. )
					       		NKG->NKG_QTDAJU := deSaldo
							       NKG->NKG_OBSAJU := cObsAjuste 
							       NKG->NKG_VALSER := NKG->NKG_VLTARC - deSaldo   // bonificado parcial
							       deSaldo         := 0
							       If NKG->NKG_TIPRET = '1'
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','4')  //9=Simulado#4=Negoc.Pend
				              	Else
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','1')  //9=Simulado#1=Atualizado
				              	Endif
						       MsUnlock()    
						   Endif
						Else
							If deSaldo >= NKG->NKG_QTRETC
								RecLock('NKG',.f. )
									NKG->NKG_QTDAJU := NKG->NKG_QTRETC
									NKG->NKG_OBSAJU := cObsAjuste
									NKG->NKG_QTDRET := 0    // bonificado 100%
									NKG->NKG_STATUS := '3'    // 3=Bonificado
									deSaldo         := deSaldo - NKG->NKG_QTRETC
								MsUnlock()
			              ElseIf deSaldo = 0
			              	RecLock('NKG',.f. )
				              	NKG->NKG_QTDAJU := 0
				              	NKG->NKG_OBSAJU := ""
				              	NKG->NKG_QTDRET := NKG->NKG_QTRETC   // bonificado parcial 
				              	If NKG->NKG_TIPRET = '1'
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','4')  //9=Simulado#4=Negoc.Pend
				              	Else
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','1')  //9=Simulado#1=Atualizado
				              	Endif
			              	MsUnlock() 
							Else
								RecLock('NKG',.f. )
								NKG->NKG_QTDAJU := deSaldo
				              	NKG->NKG_OBSAJU := cObsAjuste
				              	NKG->NKG_QTDRET := NKG->NKG_QTRETC - NKG->NKG_QTDAJU   // bonificado parcial
				              	deSaldo         := 0
				              	If NKG->NKG_TIPRET = '1'
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','4')  //9=Simulado#4=Negoc.Pend
				              	Else
				              		NKG->NKG_STATUS := IIf(Empty(NKG->NKG_DOCNUM),'9','1')  //9=Simulado#1=Atualizado
				              	Endif	
			              	MsUnlock() 
							Endif
						Endif
						AGRDBSELSKIP('NKG')	
					Endif
				EndIf	
				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasQry)			
			EndDo	
		Endif
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTOT)		
	EndDo
		
Return

/** {Protheus.doc} A261SIMUL
Função para aprovação dos calculos pendentes

@param: 	
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261SIMUL( lAutomato )
	
	Local cAliasCtrS := GetNextAlias()

    Default lAutomato := .f.
	
	If ValidFilial()
		
		ARGSETIFARQUI(cAliasTOT)
		
		BeginSql Alias cAliasCtrS
			SELECT * 
				FROM %Table:NKG% NKG
			   WHERE NKG.%NotDel%
			     AND NKG.NKG_FILIAL = %exp:xFilial('NKG')%
			     AND NKG.NKG_CODCTR = %exp:(cAliasTOT)->T_CODCTR%
			     AND NKG.NKG_STATUS = '9'
		EndSQL	     
		
		dbSelectArea(cAliasCtrS)
		dbGoTop()
		
		While !Eof()
			//Tratamento
			Help(, , STR0033, , STR0091, 1, 0 )
			Return
		EndDo
	
		SimularScr( lAutomato )
	Endif
Return

/** {Protheus.doc} A261GERNF
Função para geração de documento fiscal

@param: 	Nil
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261GERNF( lAutomato )

	Local nQtdReg := A261AQTREG()
    Default lAutomato := .F.
	
	If ValidFilial()
		If nQtdReg <= 0
			Help(, , STR0033, , STR0111, 1, 0 )	
			Return .f.		
		Endif
		
		cContrato   := ""
		nQtdRet     := 0
		nValSer     := 0
		cDespesa    := ""
				
		//Posiciona no inicio do arquivo temporário
		ARGSETIFARQUI(cAliasTot)
		
		While !Eof() 
		
			If (cAliasTot)->OK = cMarca
						
				If (cAliasTot)->T_STATUS <> '1' 
					Help(, , STR0033, , STR0092, 1, 0 ) 				
					Return .f.
				Endif									
															
				If Empty(cContrato)
					cContrato := (cAliasTot)->T_CODCTR	
				Endif
				
				If cContrato != (cAliasTot)->T_CODCTR
					Help(, , STR0033, , STR0093, 1, 0 )
					Return .f. 				
				Endif
								
				nValSer += (cAliasTot)->T_VALSER
				nQtdRet += (cAliasTot)->T_QTDRET
				If nQtdRet > 0
					cDespesa := (cAliasTot)->T_CODDES
				Endif	
			Endif
			//Retoma a área e vai para o próximo registro
			AGRDBSELSKIP(cAliasTot)			
		EndDo
			
		dbSelectArea('NJR')
		dbSetOrder(1)
		If(dbSeek( xFilial('NJR') + cContrato ))
			cTESQtd := NJR->NJR_TESQTE
		Endif
		
		NegociEnt( lAutomato )
	Endif

Return( .t. )

/** {Protheus.doc} A261OKNF
Função para geração de documento fiscal

@param: 	Nil
@author: 	Bruna Rocio
@since: 	13/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function A261OKNF( lAutomato )

	Local lRetorno  := .t.	
	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
    Local cCodRom       := ""

    Default lAutomato := .f.
		
	aServicos := {}
	
// Atenção nesse ponto o Codigo do Contrato encontra-se posicionado anteriormente em ( A261GERNF )	

	DbSelectArea("NJ0")
	DbSetOrder(1)
	If ! DbSeek( xFilial("NJ0")+ NJR->NJR_CODENT + NJR->NJR_LOJENT )     				// Entidade devedora ref. ao contrato selecionado
		Help( , , STR0033, , STR0102 + NJR->NJR_CODENT + "/" + NJR->NJR_LOJENT, 1, 0 )  	//"AJUDA"###"Não foi encontrado cadastro da Entidade " + ":" + NJR->NJR_CODENT + "/" NJR->NJR_LOJENT
		Return( .F. )
	EndIf	
	
	If !VldLocalRet()
		Return .f.
	Endif	
	
	If _lTipo .And. Empty(_aParce)
		Help(,,"HELP",,STR0119,1,0)
		Return .f.
	EndIf
			
	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTot)
	
	While !Eof() 
		If (cAliasTot)->OK = cMarca
		
			If (cAliasTot)->T_VALSER > 0
													
				aAdd( aServicos, {(cAliasTot)->T_CODCTR, (cAliasTot)->T_CODDES, ;
					(cAliasTot)->T_DESDES, (cAliasTot)->T_VALSER, (cAliasTot)->T_QTDRET, (cAliasTot)->T_QTDAJU} )	
			Endif	
		Endif
		
		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTot)	
	EndDo	

	//Abre tela para seleção da serie da NF, necessario ser antes do Begin TRANSACTION para evitar erros
	If nValSer > 0	.and. Empty(cSerVal) .and. Empty(cDocVal) 
		If .Not. SX5NumNota(@cSerVal, GetNewPar("MV_TPNRNFS","1"))
			Return .F.
		EndIf
	EndIf	
	
	BEGIN TRANSACTION
		If nValSer > 0	
			If Empty(cDocVal) 		
				If !lAutomato                
                    MsgRun( STR0094,  STR0095, {|| lRetorno := GeraPVSrv() } )                    
                Else
                    lRetorno := GeraPVSrv(lAutomato) 
                EndIf

                If .Not. lRetorno
                    DisarmTransaction()
                    Break
                EndIf	
			Else
				dbSelectArea('SF2')
				dbSetOrder(2) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE   
				If( dbSeek( xFilial('SF2') + NJ0->NJ0_CODCLI + NJ0->NJ0_LOJCLI + cDocVal + cSerVal) )
					While !Eof() ; 
					.And. SF2->F2_FILIAL  = xFilial('SF2') ;
					.And. SF2->F2_CLIENTE = NJ0->NJ0_CODCLI;
					.And. SF2->F2_LOJA    = NJ0->NJ0_LOJCLI;
					.And. SF2->F2_DOC     = cDocVal;
					.And. SF2->F2_SERIE   = cSerVal
					
						dbSelectArea('SD2')     
						dbSetOrder(3)	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						If (dbSeek( xFilial('SD2') + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
						  	
						  	aSavSC5 := SC5->( GetArea() )
							aSavSc6 := SC6->( GetArea() )
							
							dbSelectArea( "SC5" ) // Cabecalho do PV
							SC5->( dbSetOrder( 1 ) )
							If dbSeek( xFilial( "SC5" ) + SD2->D2_PEDIDO )
							
								dbSelectArea( "SC6" ) 		// Item do PV
								SC6-> ( dbSetOrder( 1 ))  	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
								
								If dbSeek( xFilial( "SC6" ) + SD2->D2_PEDIDO)
									While .Not. SC6->( Eof() ) .And. SC6->( C6_FILIAL+C6_NUM) == FwxFilial("SC6") + SD2->D2_PEDIDO
										// Criando array de vinculo do fechamento de serviço com o PV
										//Criando Vinculo com SC5 / SC6
										
										aLinhaVinc := {}
										aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
										aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SC6->C6_ITEM 				} )
										aadd( aLinhaVinc, { "N8I_PRODUT"    	, SC6->C6_PRODUTO			} )
										aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 			} )
										//No vincular não tem como amarrar Contrato e Safra, pois não tem nenhuma
										//garantia que o PV.  tem itens gerados por contrato e serviço. 
										//tambem n.possui vinculo com os serviços, podendo estar confirmando 10 serviços de 10 contratos diferentes
										// e na nf ter somente um item ( Hj. está desta forma)
										aadd( aLinhaVinc, { "N8I_CODCTR"    	, ''						} ) 
										aadd( aLinhaVinc, { "N8I_SAFRA"    		, ''						} )
										aadd( aLinhaVinc, { "N8I_CODROM"    	, ''						} )
										aadd( aLinhaVinc, { "N8I_ITEROM"    	, ''						} )
										aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''						} )
										aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''						} )
										aadd( aLinhaVinc, { "N8I_CODFIX"    	, ''						} )
										aadd( aLinhaVinc, { "N8I_ORPGRC"   		, ''						} )
										aadd( aLinhaVinc, { "N8I_FECSER"   		, ''						} ) // Ainda n. tenho o codigo do fechto de serviço, irei ajustar ao jerar o fechamento de serviço;
										aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA261A'		 			} ) 
										aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA261A","STR0121",121)	} ) // 'Fechamento de Servico, ao vincular NF)'
					
										aAdd( aVincITE, aLinhaVinc )
										SC6->( dBskip() )
									EndDO
								EndIF
								
								//Cabeçalho do vinc. do pv
								aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 		} )
								aadd( aVincCab, { "N8H_NUMPV"    	, SC5->C5_NUM			} )
								aadd( aVincCab, { "N8H_CODCTR"    	, ''			 		} ) //o Fechamento de serviço pode conter serviços de varios contratos, como iremos criar pv. para o fechamento não iremos ter o contrato aqui
								aadd( aVincCab, { "N8H_CODROM"    	, ''					} )  
								aadd( aVincCab, { "N8H_CODFIX"   	, ""					} )
								aadd( aVincCab, { "N8H_CODOTR"   	, ""					} )
								aadd( aVincCab, { "N8H_FECSER" 		, ''					} ) // Ainda n. tenho o codigo do fechto de serviço, irei ajustar ao jerar o fechamento de serviço;   	
								aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA261A"				} )
								aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA261A","STR0121",121) } ) //'Fechamento de Servico, ao vincular NF)' 
								
							EndIF
							
							Restarea( aSavSC5 )
							Restarea( aSavSC6 )
																				
							If !lAutomato
								MsgRun( STR0096, STR0095, {|| lRetorno := GeraNKS( SD2->D2_PEDIDO, '3', STR0120, aClone(aVincCab), aClone(aVincITE) ) } )
							Else
								lRetorno := GeraNKS( SD2->D2_PEDIDO, '3', STR0120, aClone(aVincCab), aClone(aVincITE) )
							EndIf
							  	
							If .Not. lRetorno
								DisarmTransaction()
								Break
							EndIf
						Else
							Help( ,,STR0033 ,, STR0097, 1, 0) //'HELP'###"Nota Fiscal não encontrada"
							DisarmTransaction()
							Break							 	
						Endif
						AGRDBSELSKIP('SF2')		
					EndDo
				Else
					Help( ,, STR0033,, STR0097, 1, 0) //'HELP'###"Nota Fiscal não encontrada"
				    DisarmTransaction()
					Break					
				Endif
			Endif	
		Endif
			
		If nQtdRet > 0
			
			If !lAutomato                
                MsgRun( STR0098, STR0095, {|| lRetorno := GeraRomRet(nQtdRet, cObsNF2, cSerQtd, cTESQtd, cLocalRet, @cCodRom ) } )
            Else
                lRetorno := GeraRomRet(nQtdRet, cObsNF2, cSerQtd, cTESQtd, cLocalRet, @cCodRom ) 
            EndIf

			//Ponto de Entrada após geração do romaneio de retenção
            If ExistBlock('OGA261RRET')
                lRetorno := ExecBlock('OGA261RRET', .F.,.F.,{ cCodRom  } )
            Endif

            If .Not. lRetorno
				DisarmTransaction()
				Break
			EndIf
		Endif
	END TRANSACTION		

    If !lAutomato
        ClearVar()
        A261ALoadTot()
        ObrwTot:Refresh(.t.)
    EndIf
Return


/** {Protheus.doc} GeraRomRet
//"Gerando romaneio de retorno simbólico (Saída)

@param: 	Nil
@return:	Nil
@author: 	Bruna
@since: 	16/12/2014
@Uso: 		OG - Originação de Grãos
*/
Static Function GeraRomRet(nQtdRom, cMsgRom, cNFSerieRom, cTesRom, cLocalD, cCodRom )
	Local aAreaAtu 	:= GetArea()
	Local lRetorno	:= .t.
	Local cNewNJJ   := ""
	Local cItem		:= ""
	Local cFecSer   := ""
	local nNJMRECNO := nil

    Default cCodRom := ""
		
	//Contrato
	dbSelectArea("NJR")
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial( "NJR" ) + cContrato ) )

	dbSelectArea( "NJ0" )
	dbSetOrder( 1 )
	If .Not. dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT) )
		Help( ,, STR0033 ,, STR0099, 1, 0) //'HELP'###"Nota Fiscal não encontrada"
		Return( .f. )
	EndIf
	//Alimenta os campos - do Romaneio
	
	BEGIN TRANSACTION
		cNewNJJ := GETSXENUM("NJJ",xFilial( "NJJ" ),xFilial( "NJJ" )+x2path("NJJ")); ConfirmSX8()
        cCodRom := cNewNJJ
		dbSelectArea( "NJJ" )
		If RecLock( "NJJ", .t. )
			NJJ->NJJ_FILIAL 	:= xFilial( "NJJ" )
			NJJ->NJJ_CODROM 	:= cNewNJJ
			NJJ->NJJ_TIPO 	    := "6"
			NJJ->NJJ_TIPENT     := "3" //Retenção
			NJJ->NJJ_CODENT 	:= NJ0->NJ0_CODENT
			NJJ->NJJ_LOJENT 	:= NJ0->NJ0_LOJENT						
			NJJ->NJJ_ENTENT 	:= NJ0->NJ0_CODENT
			NJJ->NJJ_ENTLOJ 	:= NJ0->NJ0_LOJENT					
			NJJ->NJJ_STATUS	    := "1"
			NJJ->NJJ_STSPES     := "1"
			NJJ->NJJ_STSCLA     := "1"
			NJJ->NJJ_STAFIS 	:= "1"
			NJJ->NJJ_PLACA 	    := ""
			NJJ->NJJ_CODTRA     := ""
			NJJ->NJJ_CODSAF 	:= NJR->NJR_CODSAF
			NJJ->NJJ_CODPRO	    := NJR->NJR_CODPRO			
			NJJ->NJJ_UM1PRO	    := NJR->NJR_UM1PRO
			NJJ->NJJ_TABELA	    := NJR->NJR_TABELA
			NJJ->NJJ_LOCAL      := cLocalD 
			NJJ->NJJ_TPFORM 	:= "1"
			NJJ->NJJ_NFPSER     := ""
			NJJ->NJJ_NFPNUM     := ""
			NJJ->NJJ_QTDFIS 	:= nQtdRom
			NJJ->NJJ_PESO1      := nQtdRom
			NJJ->NJJ_PSSUBT     := nQtdRom
			NJJ->NJJ_PSBASE     := nQtdRom 
			NJJ->NJJ_PSLIQU     := nQtdRom                
			NJJ->NJJ_DATA       := dDataBase
			NJJ->NJJ_DATPS1     := dDataBase
			NJJ->NJJ_DATPS2     := dDataBase
			NJJ->NJJ_MSGNFS     := cMsgRom
			NJJ->NJJ_STACTR 	:= "2"
		 	NJJ->NJJ_TRSERV     := "0"     // não 
			NJJ->NJJ_DOCSER 	:= cNFSerieRom
			NJJ->NJJ_TPFRET     := "S"
			msUnLock()
		EndIf
		
		cItem := StrZero( 1, TamSX3( "NJM_ITEROM" )[1] )
		
		dbSelectArea( "NJM" )
		If RecLock( "NJM", .t. )
			NJM->NJM_FILIAL := xFilial( "NJJ" )
			NJM->NJM_CODROM := cNewNJJ
			NJM->NJM_ITEROM := cItem 
			NJM->NJM_TIPO   := "6"
			NJM->NJM_CODCTR := cContrato
			NJM->NJM_CODENT := NJ0->NJ0_CODENT
			NJM->NJM_LOJENT := NJ0->NJ0_LOJENT			
			NJM->NJM_CODSAF := NJR->NJR_CODSAF
			NJM->NJM_CODPRO := NJR->NJR_CODPRO			
			NJM->NJM_UM1PRO := NJR->NJR_UM1PRO
			
			NJM->NJM_GENMOD := NJR->NJR_GENMOD
			
			NJM->NJM_PERDIV := 100.00
			NJM->NJM_STAFIS := "1"
			NJM->NJM_TPFORM := "1"
			NJM->NJM_NFPSER := ""
			NJM->NJM_NFPNUM := ""
			NJM->NJM_QTDFIS := nQtdRom
			NJM->NJM_QTDFCO := nQtdRom
			NJM->NJM_TES    := cTesRom
			NJM->NJM_LOCAL  := cLocalD 
			NJM->NJM_MSGNFS := cMsgRom
		 	NJM->NJM_TRSERV := "0"     // não 
			NJM->NJM_DOCSER := cNFSerieRom
				
			msUnLock()
			
			nNJMRECNO = NJM->( Recno() ) //guarda o recno para utilizar na tabela NKS
			 
		EndIf
		
		dbSelectArea('NJJ')	
		lRetorno := OGA250ATUC( Alias(), Recno(), 4, .t. )
						
		If lRetorno
			
			NJM->( DbGoTo( nNJMRECNO ) )
			
			aEntidade := getCliente( NJM->NJM_CODENT , NJM->NJM_LOJENT )
																	    
		    cFecSer := GetSXENum("NKS","NKS_FECSER")
		    ConfirmSX8()
		    
		    dbSelectArea('NKS')
		    If RecLock('NKS', .t.)
			    NKS->NKS_FILIAL  := xFilial('NKS')
			    NKS->NKS_FECSER  := cFecSer
			    NKS->NKS_CODDEV  := NJM->NJM_CODENT
			    NKS->NKS_LOJDEV  := NJM->NJM_LOJENT
			    NKS->NKS_CODROM  := NJM->NJM_CODROM
			    NKS->NKS_ITEROM  := NJM->NJM_ITEROM
			    NKS->NKS_DOCSER  := NJM->NJM_DOCSER
			    NKS->NKS_DOCNUM  := NJM->NJM_DOCNUM
			    NKS->NKS_CLIENT  := aEntidade[1]
			    NKS->NKS_LOJA    := aEntidade[2]
			    NKS->NKS_DOCEMI  := dDatabase
			    NKS->NKS_TPFORM  := NJM->NJM_TPFORM
			    NKS->NKS_TES     := NJM->NJM_TES
			    NKS->NKS_STATUS  := '1' //Gerado
			    NKS->NKS_OBSNF   := cMsgRom
			    NKS->NKS_PEDIDO  := NJM->NJM_PEDIDO
			    NKS->NKS_QTDRET  := nQtdRom
					    
				MsUnlock()
			Endif	
				
			//Posiciona no inicio do arquivo temporário
			ARGSETIFARQUI(cAliasTot)
			
			While !Eof() 
				If (cAliasTot)->OK = cMarca .And. (cAliasTot)->T_QTDRET > 0
																				
					//Posiciona no inicio do arquivo temporario
					ARGSETIFARQUI(cAliasQry)		
					
					While !Eof()
					
						If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
							( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
							( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES 
					
							//Busca o registro com a chave primária
							If AGRIFDBSEEK('NKG',(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV,1,.f.)
							
								RecLock('NKG', .f.)
								NKG->NKG_FECSER := cFecSer
								NKG->NKG_STATUS := '2' //Confirmado
								MsUnlock()
								//Retoma a área e vai para o próximo registro
								AGRDBSELSKIP('NKG')
							Endif
						EndIf	
							
						//Retoma a área e vai para o próximo registro
						AGRDBSELSKIP(cAliasQry)	
					EndDo
				Endif	
				
				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasTot)	
			EndDo
		Else
			DisarmTransaction()
			Break		
		EndIf
	END TRANSACTION		
	RestArea( aAreaAtu )
	
Return( lRetorno )

/** {Protheus.doc} GetSafra
Busca safra do contrato
@param: 	Contrato
@return:	Safra
@author: 	Bruna
@since: 	11/12/2014
@Uso: 		OG - Originação de Grãos
*/

Static Function GetSafra( pcContrato )

	Local cSafra := ""
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If( dbSeek( xFilial('NJR') + pcContrato ) )
		
		cSafra := NJR->NJR_CODSAF
	Endif

Return ( cSafra )

/** {Protheus.doc} GetContrato
Busca descrição do contrato
@param: 	Contrato
@return:	Safra
@author: 	Bruna
@since: 	19/12/2014
@Uso: 		OG - Originação de Grãos
*/

Static Function GetContrato( pcContrato )

	Local aRetorno := { , }
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If( dbSeek( xFilial('NJR') + pcContrato ) )
		
		aRetorno[1] := NJR->NJR_DESCRI
		aRetorno[2] := Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC') 
	Endif

Return ( aRetorno )

/** {Protheus.doc} GeraPVSrv
Gera Pedido de Venda de serviço 

@param: 	Nil
@return:	Nil
@author: 	Bruna
@since: 	11/12/2014
@Uso: 		OG - Originação de Grãos
*/
STATIC FUNCTION GeraPVSrv( lAutomato )

	// somente deve estar nesta função se tiver valor total de serviços em tela, se for somente retenção, não entrar nesta função 

	Local aAreaAtu	:= GetArea()         // se não usar essas variáveis todas, depois limpar
	Local aCabec  	:= {}
	Local aItens  	:= {}
	Local aLinha  	:= {}
	Local cProduto	:= ""
	Local cCodCli 	:= ""
	Local cLojCli 	:= ""
	Local cItemSeq	:= ""
	Local cLocal  	:= ""
	Local nX 			:= 0
	Local nY      	:= 0
	Local cPVServ 	:= ""
	Local cCodSaf 	:= ""
	Local aItensPed  := {}
	Local lRetorno   := .t.
	Local nPerQtdNul := 0

		//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo

	Default lAutomato := .F.

	PRIVATE lMsErroAuto := .F.

	DbSelectArea("NJ0")
	DbSetOrder(1)
	If DbSeek( xFilial("NJ0")+ cCodEnt + cLojEnt)     // entidade devedora que está em tela nos regsitros selecionados
		SX3->( DbSetOrder(2) ) //X3_CAMPO

		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+NJ0->( NJ0_CODCLI )+NJ0->( NJ0_LOJCLI ))
			cCodCli := SA1->A1_COD
			cLojCli := SA1->A1_LOJA
		Else
			MsgAlert(STR0100+cCodDev+"-"+cLojDev+STR0110+Chr(13)+STR0101)
			RestArea( aAreaAtu )
			Return( .F. )
		EndIf
	Else
		MsgAlert(STR0102+cCodDev+"-"+cLojDev+".")
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf

	if empty(cTesVal)    // TES de serviço informado em tela  
		MsgAlert(STR0103+Chr(13)+STR0104+Chr(13)+STR0105)
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf 

	cPVServ := GetSxeNum("SC5","C5_NUM")
	ConfirmSX8()

	// Cabeçalho do pedido
	aadd(aCabec,{"C5_NUM"    ,cPVServ	  ,Nil})
	aadd(aCabec,{"C5_TIPO"   ,"N"		  ,Nil})
	aadd(aCabec,{"C5_CLIENTE",cCodCli	  ,Nil})
	aadd(aCabec,{"C5_LOJACLI",cLojCli	  ,Nil})
	aadd(aCabec,{"C5_CLIENT" ,cCodCli	  ,Nil})
	aadd(aCabec,{"C5_LOJAENT",cLojCli	  ,Nil})
	aadd(aCabec,{"C5_CONDPAG",cCondPgVal ,Nil})  // solicitado em tela 
	aadd(aCabec,{"C5_EMISSAO",dDataBase  ,Nil})	
	aadd(aCabec,{"C5_TPFRETE","S"		  ,Nil})
	aAdd(aCabec,{"C5_TIPLIB" ,"2"		  ,Nil})  //1=Libera por item; 2=Libera por pedido
	aAdd(aCabec,{"C5_LIBEROK","S"        ,Nil}) //Pedido liberado total

	If .Not. Empty( aCabec )    // solicitado em tela 
		aAdd( aCabec, {"C5_MENNOTA" , cObsNF 		, Nil } )	//Campo mensagem da nota
	EndIf

	// atribui as parcelas se foi informado tipo de pagamento igual a 9
	If _lTipo .And. !Empty(_aParce)
		For nx := 1 To Len(_aParce)
			If !Empty(_aParce[nx,2]) 
				Aadd(aCabec,{_aParce[nx,1],_aParce[nx,2],Nil})
			EndIf	
		Next nx
	EndIf
		
	// Itens do pedido
	For nX := 1 to Len(aServicos)   // serviços selecionados no resumo que tenham valor de tarifa
		
		cProduto := Posicione( "NJT", 1, xFilial("NJT") + aServicos[ nX, 2 ], "NJT_CODPRO" )   // está buscando o produto do tipo de despesa
		If Empty( cProduto )
			MsgAlert( STR0106 + aServicos[ nX, 2 ] + Chr(13) + STR0107)
			RestArea( aAreaAtu )
			Return( .F. )
		EndIf
			
		lExiste := .f.
		For nY := 1 to Len(aItensPed)
		
			If aItensPed [ nY, 3 ] = cProduto
				lExiste := .t.
				aItensPed [nY, 4] += aServicos[ nX, 4]
			Endif
		Next nY
			
		If .Not. lExiste
			cCodSaf := GetSafra( aServicos[ nX, 1] )	
		
			aAdd( aItensPed, { aServicos[ nX, 1], cCodSaf, cProduto, aServicos[ nX, 4] } )
		Endif   	
	Next nX

	//verifica se é a TES permite entrega de quantidade 0 SF4 -> cTesVal
	if Posicione( "SF4", 1, xFilial("SF4") + cTesVal, "F4_QTDZERO" ) = "1" //TES Permite Quantidade Zero  
	nPerQtdNul := 0
	else
	nPerQtdNul := 1  
	endIF 

	// criar os itens do pedido 
	For nX := 1 to Len(aItensPed)

		cLocal	  := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_LOCPAD" )
		cItemSeq := StrZero( nX, TamSX3( "D2_ITEM" )[1] )

		aLinha := {}
		aAdd( aLinha, { "C6_ITEM"		, cItemSeq			           , Nil } )
		aAdd( aLinha, { "C6_PRODUTO"	, aItensPed[ nX, 3 ]			, Nil } ) 
		aAdd( aLinha, { "C6_TES"		, cTesVal		              , Nil } ) 
		aAdd( aLinha, { "C6_QTDVEN"		, nPerQtdNul                , Nil } ) /*TES permitir que gere pedido com 0 -  MATA410A*/
		aAdd( aLinha, { "C6_QTDLIB"		, nPerQtdNul                , Nil } ) /*TES permitir que gere pedido com 0 -  MATA410A*/
		aAdd( aLinha, { "C6_QTDEMP"		, nPerQtdNul                , Nil } ) /* Faz Liberacao do Pedido se C5_LiberOk = "S" e C6_QtdLib = C6_QtdEmp*/
		aAdd( aLinha, { "C6_PRCVEN"		, aItensPed[ nX, 4 ]			, "alwaystrue()" } )
		aAdd( aLinha, { "C6_VALOR"		, aItensPed[ nX, 4 ]			, Nil } )
		aAdd( aLinha, { "C6_LOCAL"		, cLocal						, Nil } )
		
		If GetRPOrelease() <= "12.1.017"
			aAdd( aLinha, { "C6_CTROG"		, aItensPed[ nX, 1 ]			, Nil } )
			aAdd( aLinha, { "C6_CODSAF"		, aItensPed[ nX, 2 ]		 	, Nil } )
		EndIf
		aAdd( aItens, aLinha )
		
		//Criando Vinculo com SC5 / SC6
		aLinhaVinc := {}
		aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 		} )
		aadd( aLinhaVinc, { "N8I_ITEMPV"    	, cItemSeq				} )
		aadd( aLinhaVinc, { "N8I_PRODUT"    	, aItensPed[ nX, 3 ]	} )
		aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 		} )
		aadd( aLinhaVinc, { "N8I_CODCTR"    	, aItensPed[ nX, 1 ]	} )
		aadd( aLinhaVinc, { "N8I_SAFRA"    		, aItensPed[ nX, 2 ]	} )
		aadd( aLinhaVinc, { "N8I_CODROM"    	, ''					} )
		aadd( aLinhaVinc, { "N8I_ITEROM"    	, ''					} )
		aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''					} )
		aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''					} )
		aadd( aLinhaVinc, { "N8I_CODFIX"    	, ''					} )
		aadd( aLinhaVinc, { "N8I_ORPGRC"   		, ''					} )
		aadd( aLinhaVinc, { "N8I_FECSER"   		, ''					} ) // Ainda n. tenho o codigo do fechto de serviço, irei ajustar ao jerar o fechamento de serviço;
		aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA261A'		 		} ) 
		aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA261A","STR0122",122)	} )  //'Fechamento de Servico'
						
		aAdd( aVincITE, aLinhaVinc )
		
	Next nX
		
	// Criando array de vinculo do fechamento de serviço com o PV
	aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H')		} )
	aadd( aVincCab, { "N8H_NUMPV"    	, cPVServ	 			} )
	aadd( aVincCab, { "N8H_CODCTR"    	, ''					} ) //o Fechamento de serviço pode conter serviços de varios contratos, como iremos criar pv. para o fechamento não iremos ter o contrato aqui
	aadd( aVincCab, { "N8H_CODROM"    	, ''					} )  
	aadd( aVincCab, { "N8H_CODFIX"   	, ""					} )
	aadd( aVincCab, { "N8H_CODOTR"   	, ""					} )
	aadd( aVincCab, { "N8H_FECSER" 		, ''					} ) // Ainda n. tenho o codigo do fechto de serviço, irei ajustar ao jerar o fechamento de serviço;   	
	aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA261A"				} )
	aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA261A","STR0122",122)				} )  //'Fechamento de Servico'
			
	// Ponto de entrada inserido para controlar dados especificos do cliente 15/05/2016
	// Cliente precisava Setar o campo c5_naturez pq par ao mesmo cliente era preciso tirar docto de devoluão de mercadoria e cobrança de serviços
	// fazendo assim com que nao se pode sempre utilizar a natureza que stá no cadasto de clientes;
		If ExistBlock("OG261APV")
			aRetPePV := ExecBlock("OG261APV",.F.,.F.,{aCabec,aItens})
			If ValType( aRetPePV ) == "A" .And. Len( aRetPePV ) == 2 .And. ValType( aRetPePV[1] ) == "A" .And. ValType( aRetPePV[2] ) == "A"
				aCabec	:= aClone(aRetPePV[1])
				aItens	:= aClone(aRetPePV[2])
			EndIf
			/* Exemplo do PE
				User Function OG261APV()
					Local aCab := aClone(PARAMIXB[1])
					Local aItens := aClone(PARAMIXB[2])
					Local aRet := {} //Customizações do usuário
					
					aAdd( aCab, {"C5_MEUCAMPO"  , 'Valor'       , Nil } )
					
					aRet := {aCab,aItens}
					
					Return aRet
			*/
		EndIf

	/* Necessitamos solicitar o modulo pois alguns campos como LOTE, DTLOTE, NATUREZ
	não estao setados para trabalhar com o SIGAAGR */
	cModulo := "FAT" 
	nModulo := 5
	If !lAutomato
		MsgRun( STR0108, STR0109	, {|| MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCabec, aItens, 3 )  } )
	Else
		MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCabec, aItens, 3 )
	EndIf
	//Retornando o modulo do SIGAAGR
	cModulo := cModAtu
	nModulo := nModAtu
	// Cria o pedido de venda pela rotina automatica

	If lMsErroAuto 
		If !lAutomato
			MostraErro()
		EndIf
		If __lSX8; RollBackSX8(); EndIf
		RestArea( aAreaAtu )
		Return( .f. )
	Else
		If __lSX8; ConfirmSX8(); EndIf
					
		cAliasPVSV := Alias()
		nRecnoPVSV := Recno()
		
	EndIf

	lRetorno := ConfNFPed( cPVServ, cSerVal, cObsNF, aClone( aVincCab ), aClone( aVincITE ), lAutomato )

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} ConfNFPed
Confirma Nota fiscal de serviço pelo pedido gerado e atualizar a tabela NKS 
@param: 	Nr. do Pedido
			Serie docto
			Obs. do docto
			aArray para gerar tab. de vinculo do PV 		( Padrao autoexec de cabecalho)
			aArray para gerar tab. de vinculo Itens do PV	( Padrao autoexec de itens)
@return:	Nil
@author: 	Bruna
@since: 	11/12/2014
@Uso: 		OG - Originação de Grãos
*/

STATIC FUNCTION ConfNFPed( pcPedido, pcSerie, pcObs, aVincPV,aVincItePV, lAutomato )			
   Local cSerie    := pcSerie    // Serie informada em tela
   Local aRet      := {}
	
   Default lAutomato := .F.

   Private cOGUBS_NF	:= fAgrtpnf(Nil)   
					
	SC5->( dbSetOrder( 1 ) )
	If SC5->( dbSeek( xFilial( "SC5" ) + pcPedido  ) )
      
	    If !lAutomato
            MsgRun( STR0061	, STR0060 	, {|| aRet := AgrGeraNFS( pcPedido , cSerie ) } )
        Else
            aRet := AgrGeraNFS( pcPedido , cSerie ) 
        EndIf

		If empty(aRet) .or. Len( aRet ) <= 0 //dependendo do retorno pode ser nil
			  Help( ,, STR0033 ,, STR0059, 1, 0) //'HELP'###"Não foi possível gerar Nota Fiscal de Serviço "
		      Return( .f. )
		ElseIf AGRIFDBSEEK("SD2",pcPedido,8,.f.) 
		   			   		   		    
		   	//Nota Gerada		   			   		   		    
		   	GeraNKS( SD2->D2_PEDIDO, '1', pcObs, aClone(aVincPV),aClone(aVincItePV) )
									
			//Retoma a área e vai para o próximo registro
			AGRDBSELSKIP('SD2') 
		ENDIF       
	EndIf		
		
Return( .t. )

/** {Protheus.doc} GeraNKS
Função para calculos dos serviços

@param: 	Nr. do Pedido
			Status
			aArray para gerar tab. de vinculo do PV 		( Padrao autoexec de cabecalho)
			aArray para gerar tab. de vinculo Itens do PV	( Padrao autoexec de itens)
			
@author: 	Bruna Rocio
@since: 	22/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GeraNKS( pcPedido, pcStatus, pcObs, aVincPV,aVincItePV )
	Local aAreaAtu 		:= GetArea()
	Local nPosCpo		:= 0
	Local nI			:= 0
	Local lVinculou		:= .f.
	aEntidade := getCliente( cCodEnt , cLojEnt )

	cFecSer := GetSXENum('NKS','NKS_FECSER')
	ConfirmSX8()

	dbSelectArea('NKS')

	RecLock('NKS', .t.)
	NKS->NKS_FILIAL  := xFilial('NKS')
	NKS->NKS_FECSER  := cFecSer
	NKS->NKS_CODDEV  := cCodEnt
	NKS->NKS_LOJDEV  := cLojEnt
	NKS->NKS_DOCSER  := SD2->D2_SERIE
	NKS->NKS_DOCNUM  := SD2->D2_DOC
	NKS->NKS_CLIENT  := aEntidade[1]
	NKS->NKS_LOJA    := aEntidade[2]
	NKS->NKS_DOCEMI  := dDatabase
	NKS->NKS_TES     := SD2->D2_TES
	NKS->NKS_STATUS  := pcStatus // 1-Gerado, 2-Cancelado, 3-Vinculado
	NKS->NKS_OBSNF   := pcObs
	NKS->NKS_PEDIDO  := SD2->D2_PEDIDO
	NKS->NKS_VALSER  := nVlr

	NKS->( MsUnlock() )
	
	IF Len( aVincPV ) > 0   
		// Adicionando o nr. do fechto no array do cabecalho da tab. vinc. pv
		nPosCpo:= ASCAN(aVincPV, {|aVincPV| aVincPV[1] ==  'N8H_FECSER' })
		IF nPosCpo > 0
			aVincPV [ nPosCpo ,2] := cFecSer
		Else
			aadd( aVincPV, { "N8H_FECSER"   	, cFecSer		} )
		EndIF

		IF Len( aVincItePV ) > 0
			For nI := 1 to len( aVincItePV )
				aLinhaVinc := aClone( aVincItePV[ nI ] )
				nPosCpo:= ASCAN(aLinhaVinc, {|aLinhaVinc| aLinhaVinc[1] ==  'N8I_FECSER' })
				IF nPosCpo > 0
					aLinhaVinc[nPosCpo, 2] := cFecSer 
				Else
					aAdd( aLinhaVinc, { "N8I_FECSER"   	, cFecSer		} )
				EndIF
				aVincItePV[nI] :=   aClone( aLinhaVinc )
			nExt nI
		EndIF

		lVinculou := fAgrVncPV (aVincPV,aVincItePV  , 3)  	//Incluir

	EndIF
	
	fvincNFS ( SD2->D2_PEDIDO ) // Função de vinculo da NF (SF2/SD2) do fechamento fiscal com (N8J/N8K)
	
	//Posiciona no inicio do arquivo temporário
	ARGSETIFARQUI(cAliasTot)

	While !Eof() 
		If (cAliasTot)->OK = cMarca .And. (cAliasTot)->T_VALSER > 0

			//Posiciona no inicio do arquivo temporario
			ARGSETIFARQUI(cAliasQry)		

			While !Eof()

				If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
				( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
				( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES 			
					//Busca o registro com a chave primária
					If AGRIFDBSEEK('NKG',(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV,1,.f.)

						RecLock('NKG', .f.)
						NKG->NKG_FECSER := cFecSer
						NKG->NKG_STATUS := '2' //Confirmado
						MsUnlock()
						//Retoma a área e vai para o próximo registro
						AGRDBSELSKIP('NKG')						
					Endif
				EndIf	

				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasQry)	
			EndDo
		Endif	

		//Retoma a área e vai para o próximo registro
		AGRDBSELSKIP(cAliasTot)	
	EndDo	

	RestArea( aAreaAtu )
Return .t.


/** {Protheus.doc} A261CALC
Função para calculos dos serviços

@param: 	Nil
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261CALC(lAutomato)
	Local aParams    := {}

    Default lAutomato := .F.
	
	If ValidFilial()	
			
		If   Empty(MV_PAR04) .Or. Empty(MV_PAR06) .Or. Empty(MV_PAR10); 
		.Or. Empty(MV_PAR12) .Or. Empty(MV_PAR08) .Or. Empty(MV_PAR13);
		.Or. Empty(MV_PAR14)
			Help(, , STR0033, , STR0034, 1, 0 ) //"Apenas registros com Status diferente de Confirmado podem ser excluídos" 
		Else
			
			aAdd( aParams, { "MV_PAR01", MV_PAR03 } )	//"Contrato De"
			aAdd( aParams, { "MV_PAR02", MV_PAR04 } )	//"Contrato Até"	
			aAdd( aParams, { "MV_PAR03", cCodEnt } )		//"Entidade De"
			aAdd( aParams, { "MV_PAR04", cLojEnt } )		//"Loja De"
			aAdd( aParams, { "MV_PAR05", cCodEnt } )		//"Entidade Até"
			aAdd( aParams, { "MV_PAR06", cLojEnt } )		//"Loja Até"
			aAdd( aParams, { "MV_PAR07", MV_PAR05 } )	//"Tabela Tarifas de"
			aAdd( aParams, { "MV_PAR08", MV_PAR06 } )	//"Tabela Tarifas até"
			aAdd( aParams, { "MV_PAR09", MV_PAR07 } )	//"Tipo Despesa de"
			aAdd( aParams, { "MV_PAR10", MV_PAR08 } )	//"Tipo Despesa até"
			aAdd( aParams, { "MV_PAR11", MV_PAR09 } )	//"Produto De"
			aAdd( aParams, { "MV_PAR12", MV_PAR10 } )	//"Produto Ate"
			aAdd( aParams, { "MV_PAR13", MV_PAR11 } )	//"Safra De"
			aAdd( aParams, { "MV_PAR14", MV_PAR12 } )	//"Safra Ate"
			aAdd( aParams, { "MV_PAR15", MV_PAR13 } )	//"Data Movimento de"
			aAdd( aParams, { "MV_PAR16", MV_PAR14 } )	//"Data Movimento Ate"
			
			OGA262CALC( aParams, , , , .F. ) 
			
			If !lAutomato
				A261ALoadTot()
				oBrWTot:Refresh(.t.)
			EndIf
		Endif	
	Endif	
	
Return

/** {Protheus.doc} A261ASIM
Função para simulação de calculo

@param: 	pTipEnt - Tipo Entrada #Física#Simbólica
@author: 	Bruna Rocio
@since: 	16/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function A261ASIM( pTipEnt,lAutomato )
	
	/*Após confirmar, deve validar: 
	- Somente aceitar contrato que seja da entidade selecionada e que seja de depósito 3º NJR_TIPO = 3=Armazenagem De 3
	-  O contrato deve ter quantidade para retornar, ou seja Se quantidade informada < (NJR_QTEFCO - NJR_QTSFCO) 
	dar mensagem: “Contrato não possui quantidade física para retorno”.
	- Deve aceitar data igual a do dia e data futura, não deve aceitar data retroativa. 
	*/
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If (dbSeek( xFilial('NJR') + cContSimul ))
		
		If NJR->NJR_TIPO <> '3' //Armazenagem de 3º
			Help(, , STR0033, , STR0036, 1, 0 )
			Return .f.
		Endif
		
		If nQtdContr > (NJR->NJR_QSLFCO - NJR->NJR_QTDRES)
			Help(, , STR0033, , STR0037, 1, 0 )
			Return .f.
		Endif 
	Else
		Help(, , STR0033, , STR0038, 1, 0 )
		Return .f.	
	Endif
	
	If dDtSimul < dDatabase
		Help(, , STR0033, , STR0039, 1, 0 )
		Return .f.
	Endif
	
	A261ACLL262(pTipEnt,lAutomato)
	
Return( .t. )

/** {Protheus.doc} A261ACLL262
Função para simulação de calculo

@param: 	Nil
@author: 	Bruna Rocio
@since: 	23/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A261ACLL262(pTipEnt,lAutomato)
	Local aParams := {}

	If   Empty(MV_PAR14) ; 
	.Or. Empty(MV_PAR08) .Or. Empty(MV_PAR13) 
			Help(, , STR0033, , STR0034, 1, 0 ) //"Verificar informações do filtro" 
	Else
		If dDtSimul <> MV_PAR14
			Help(, , STR0033, , STR0112, 1, 0 )
		Endif	 
		
		aAdd( aParams, { "MV_PAR01", cContSimul } )	//"Contrato De"
		aAdd( aParams, { "MV_PAR02", cContSimul } )	//"Contrato Até"	
		aAdd( aParams, { "MV_PAR03", cCodEnt } )		//"Entidade De"
		aAdd( aParams, { "MV_PAR04", cLojEnt } )		//"Loja De"
		aAdd( aParams, { "MV_PAR05", cCodEnt } )		//"Entidade Até"
		aAdd( aParams, { "MV_PAR06", cLojEnt } )		//"Loja Até"
		aAdd( aParams, { "MV_PAR07", MV_PAR05 } )	//"Tabela Tarifas de"
		aAdd( aParams, { "MV_PAR08", MV_PAR06 } )	//"Tabela Tarifas até"
		aAdd( aParams, { "MV_PAR09", MV_PAR07 } )	//"Tipo Despesa de"
		aAdd( aParams, { "MV_PAR10", MV_PAR08 } )	//"Tipo Despesa até"
		aAdd( aParams, { "MV_PAR11", MV_PAR09 } )	//"Produto De"
		aAdd( aParams, { "MV_PAR12", MV_PAR10 } )	//"Produto Ate"
		aAdd( aParams, { "MV_PAR13", MV_PAR11 } )	//"Safra De"
		aAdd( aParams, { "MV_PAR14", MV_PAR12 } )	//"Safra Ate"
		aAdd( aParams, { "MV_PAR15", MV_PAR13 } )	//"Data Movimento de"
		aAdd( aParams, { "MV_PAR16", dDtSimul } )	//"Data Movimento Ate"
		
		OGA262CALC( aParams, nQtdContr, dDtSimul, pTipEnt, .F. ) 
		
		IF !lAutomato
            A261ALoadTot()
            oBrWTot:Refresh(.t.)
        EndIf
	Endif		
	
Return .t.

/** {Protheus.doc} GetSldCtr
Função para retornar saldo do contrato menos quantidade reservada

@param: 	Filial, Contrato
@author: 	Bruna Rocio
@since: 	14/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetSldCtr( pcContrato )
	Local nSld := 0
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek( xFilial('NJR') + pcContrato )
		
		nSld := NJR->NJR_QSLFCO - NJR->NJR_QTDRES
	Endif
	
Return ( nSld )

/** {Protheus.doc} SimularScr
Função para simulação de calculo

@param: 	Nil
@author: 	Bruna Rocio
@since: 	16/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function SimularScr( lAutomato )
Local aAreaAtu	:= GetArea()
Local aButtons	:= {}
Local oDlg			:= Nil
Local nTamH 		:= 560 // ( GetScreenRes()[1] - 500 )
Local nTamV 		:= 250 // ( GetScreenRes()[2] - 500 )

cContSimul := (cAliasTOT)->T_CODCTR
nQtdContr  := GetSldCtr( (cAliasTOT)->T_CODCTR )

If !lAutomato

	oDlg := TDialog():New( 0, 0, nTamV, nTamH, OemToAnsi( STR0042 ), , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	oDlg:lEscClose := .f.

	oLContrato := TSay():New( 042, 005, {|| OemToAnsi( STR0043 ) }		, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
	oGContrato := TGet():New( 040, 060, { |u| If( PCount() > 0, cContSimul := u, cContSimul ) } , oDlg, 060, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., "NJR", "cContSimul", , , , )

	oLQtdSimul	:= TSay():New( 057, 005, {|| OemToAnsi( STR0044 ) }		, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
	oGQtdSimul := TGet():New( 055, 060, { |u| If( PCount() > 0, nQtdContr := u, nQtdContr ) } , oDlg, 060, 010, cPicQtd, { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., , "nQtdContr", , , , )

	oLDtSimul  := TSay():New( 072, 005, {|| OemToAnsi( STR0045 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
	oGDtSimul  := TGet():New( 070, 060, { |u| If( PCount() > 0, dDtSimul := u, dDtSimul ) } , oDlg, 060, 010, , { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., ,"dDtSimul", , , , )

	oLCmbVlr	 := TSay():New( 087, 005, {|| OemToAnsi( STR0046 ) }				, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
	oComboEnt	 := TComboBox():New( 085, 060, { |u| If( PCount() > 0, cComboEnt := u, cComboEnt ) }, {STR0047, STR0048}, 100, 020, oDlg, , { || cTipEnt := IIF(oComboEnt:nAt = 0, '0', '2') }, , , , .t., , , , , , , , , "cComboEnt" ) //"Físico#Simbolico"

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| A261ASIM(cTipEnt,lAutomato), oDlg:End()},{|| oDlg:End() },, @aButtons ) } )

Else
	cContSimul := "000041"
	nQtdContr  := 10000
	dDtSimul   := cTod("23/08/2019")
	cTipEnt    := "0"
	A261ASIM(cTipEnt,lAutomato)

EndIf

RestArea( aAreaAtu )
Return( .t. )

/** {Protheus.doc} ClearVar()
Função para calculos dos serviços

@param: 	Nil
@author: 	Bruna Rocio
@since: 	12/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ClearVar()

	cTESVal    := Space( TamSX3( "F4_CODIGO"  )[1] )
	cSerVal    := Space( TamSX3( "F4_CODIGO"  )[1] )
	cDocVal    := Space( TamSX3( "F2_DOC"     )[1] )
	cCondPgVal := Space( TamSX3( "E4_CODIGO"  )[1] )
	cObsNF     := Space( TamSX3( "F1_MENNOTA" )[1] )
	
	cTESQtd    := Space( TamSX3( "F4_CODIGO"  )[1] )
	cSerQtd    := Space( TamSX3( "F4_CODIGO"  )[1] )
	cLocalRet  := Space( TamSX3( "NNR_CODIGO" )[1] )
	cObsNF2    := Space( TamSX3( "F1_MENNOTA" )[1] )

Return ( .t. )


/** {Protheus.doc} VldLocalRet
Função para calculos dos serviços

@param: 	Nil
@author: 	Bruna Rocio
@since: 	15/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function VldLocalRet()
	Local lRetorno := .t.
	
	If Empty(cLocalRet) .And. nQtdRet > 0
		Help(, , STR0033, , STR0116, 1, 0 )
		lRetorno := .f.
	Endif

Return ( lRetorno )

  
/** {Protheus.doc} NegociEnt
Função para calculos dos serviços

@param: 	Nil
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function NegociEnt( lAutomato )
Local aAreaAtu	:= GetArea()
Local aButtons	:= {}
Local nTamH 		:= 700 // ( GetScreenRes()[1] - 500 )
Local nTamV 		:= 600// ( GetScreenRes()[2] - 500 )
Local oDlg			:= Nil

Default lAutomato := .f.

Private oGQtSv, oGVlSv, oGCnSv, oGSrSv, oGNfSv

nVlr := nValSer

If !Empty(SuperGetMV("MV_OGASERS",,''))
	cSerQtd := SuperGetMV("MV_OGASERS",,'')
EndIf

If !lAutomato
    oDlg := TDialog():New( 0, 0, nTamV, nTamH, OemToAnsi( STR0049 ), , , , , CLR_BLACK, CLR_WHITE, , , .t. )
    oDlg:lEscClose := .f.

    oLCmbVlr	  := TSay():New( 32, 010, {|| OemToAnsi( STR0050 ) }				, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
    oComboVal 	  := TComboBox():New( 30, 070, { |u| If( PCount() > 0, cComboVal := u, cComboVal ) }, {STR0023, STR0024}, 100, 020, oDlg, , { || nItemSer := oComboVal:nAt }, , , , .t., , , , { || IIF( nVlr > 0, .t., .f. ) }, , , , , "cComboVal" ) //"Primeira Pesagem"###"Segunda Pesagem"

    oLVlr		  := TSay():New( 052, 010, {|| OemToAnsi( STR0051 ) }				, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 060, 010 )
    oGVlr		  := TGet():New( 050, 070, { |u| If( PCount() > 0, nVlr := u, nVlr ) } , oDlg, 060, 010, cPicVlr, {|| .t.}, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .f. }, .f., .f., , .f., .f., ,"nVlr", , , , )

    oLTesVal 	  := TSay():New( 072, 010, {|| OemToAnsi( STR0052 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGTesVal	  := TGet():New( 070, 070, { |u| If( PCount() > 0, cTESVal := u, cTESVal ) } , oDlg, 060, 010, "@!",;
                { || AGRVLDESP("SF4",cTESVal,1,"SF4->F4_TIPO = 'S'",.T.)},;
                CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF( nVlr > 0,ValGeraNota(nItemSer), .f.) }, .f., .f., , .f., .f., "SF4","cTESVal", , , , )

    oLSerVal 	  := TSay():New( 092, 010, {|| OemToAnsi( STR0053 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGSerVal	  := TGet():New( 090, 070, { |u| If( PCount() > 0, cSerVal := u, cSerVal ) } , oDlg, 060, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF( nVlr > 0, .t., .f.) }, .f., .f., , .f., .f., ,"cSerVal", , , , )

    oLDocVal 	  := TSay():New( 112, 010, {|| OemToAnsi( STR0054 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGDocVal	  := TGet():New( 110, 070, { |u| If( PCount() > 0, cDocVal := u, cDocVal ) } , oDlg, 060, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF( nVlr > 0,!ValGeraNota(nItemSer), .f.) }, .f., .f., , .f., .f., "SF2", "cDocVal", , , , )

    oLCondPgVal := TSay():New( 132, 010, {|| OemToAnsi( STR0055 ) }		, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGCondPgVal := TGet():New( 130, 070, { |u| If( PCount() > 0, cCondPgVal := u, cCondPgVal ) } , oDlg, 060, 010, "@!",;
                    { || ExistCpo("SE4",cCondPgVal) .And. OGA261ACP()}, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF( nVlr > 0,ValGeraNota(nItemSer), .f.) }, .f., .f., , .f., .f., "SE4", "cCondPgVal", , , , )

    oLObsNF	  := TSay():New( 152, 010, {|| OemToAnsi( STR0056 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGObsNF	  := TGet():New( 150, 070, { |u| If( PCount() > 0, cObsNF := u, cObsNF ) } , oDlg, 200, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF( nVlr > 0,ValGeraNota(nItemSer), .f.) }, .f., .f., , .f., .f., ,"cObsNF", , , , )

    @ 165,010 TO 167,280 LABEL ""  OF oDlg PIXEL

    oLQtd	     := TSay():New( 180, 010, {|| OemToAnsi( STR0057 ) }		, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGQtd  	     := TGet():New( 182, 070, { |u| If( PCount() > 0, nQtdRet := u, nQtdRet ) } , oDlg, 060, 010, cPicQtd, { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || .f. }, .f., .f., , .f., .f., , "nQtdRet", , , , )

    oLTesQtd 	 := TSay():New( 202, 010, {|| OemToAnsi( STR0052 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGTesQtd	 := TGet():New( 200, 070, { |u| If( PCount() > 0, cTESQtd := u, cTESQtd ) } , oDlg, 060, 010, "@!",;
                            { || AGRVLDESP("SF4",cTESQtd,1,"SF4->F4_TIPO = 'S'",.T.)},;
                            CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF(nQtdRet > 0, .t., .f.) }, .f., .f., , .f., .f., "SF4","cTESQtd", , , , )

    oLSerQtd 	 := TSay():New( 220, 010, {|| OemToAnsi( STR0053 ) }	, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGSerQtd	 := TGet():New( 222, 070, { |u| If( PCount() > 0, cSerQtd := u, cSerQtd ) } , oDlg, 060, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF(nQtdRet > 0, .t., .f.) }, .f., .f., , .f., .f., ,"cSerQtd", , , , )

    oLLocal := TSay():New( 240, 010, {|| OemToAnsi( STR0058 ) }		, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGLocal := TGet():New( 242, 070, { |u| If( PCount() > 0, cLocalRet := u, cLocalRet ) } , oDlg, 060, 010, "@!", , CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF(nQtdRet > 0, .t., .f.) }, .f., .f., , .f., .f., "NNR", "cLocalRet", , , , )

    oLObsNF2	 := TSay():New( 260, 010, {|| OemToAnsi( STR0056 ) }, oDlg, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 010 )
    oGObsNF2	 := TGet():New( 262, 070, { |u| If( PCount() > 0, cObsNF2 := u, cObsNF2 ) } , oDlg, 200, 010, "@!", { || .t. }, CLR_BLACK, CLR_WHITE, , .f., , .t., , .f., { || IIF(nQtdRet > 0, .t., .f.) }, .f., .f., , .f., .f., ,"cObsNF2", , , , )

    oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| A261OKNF(), oDlg:End()},{|| oDlg:End() },, @aButtons ) } )
Else
    /* Carregar aqui variáveis para automação */
	nItemSer    := 2
	cTESVal     := '501'
	cSerVal     := '003'
	cCondPgVal  := '000'
	cObsNF      := ''
	A261OKNF( lAutomato )
       
EndIf

RestArea( aAreaAtu )
Return( .t. )

  
/** {Protheus.doc} ValGeraNota
Função para calculos dos serviços

@param: 	Nil
@author: 	Bruna Rocio
@since: 	10/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function ValGeraNota( pnOpc )

	Local lRetorno := .f.

	If pnOpc = 2
		lRetorno := .t.
	Endif

Return ( lRetorno )


/** {Protheus.doc} GetStatus
Função para retornar os status selecionados no filtro

@param: 	Nil
@author: 	Bruna Rocio
@since: 	17/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetStatus()
		
	Local mvpar15	:= AllTrim( mv_par15 )
	Local aTipos	:= {}
	Local nX		:= 0
	Local cFiltro := ""
	Local cHifen  := "-"
	Local cPV     := ";"
	Local nPos    := 0
	Local nPosH   := 0
	Local nPosV   := 0
	Local cIni    := ""
	Local cFim    := ""
	Local nTam    := 0
	Local nY      := 0
	
	If AT(cHifen, mvpar15) > 0 .And. AT(cPV, mvpar15) > 0 
		nTam  := Len(mvpar15)
		nPosH := AT(cHifen, mvpar15)
		hPosV := AT(cPV, mvpar15)
		
		cIni := SUBSTR(mvpar15, 1, (nPosH + 1))
		cFim := SUBSTR(mvpar15, (nPosH + 1), (nPosH + 1))
		
		For nY := Val(cIni) To Val(cFim)
			
			cAux := cValToChar(nY)
			aAdd( aTipos, cAux )
		Next nY
		
		cIni := SUBSTR(mvpar15, nPosV + 1, nTam)
		
		If Len(cIni) > 0
			For nX := 1 to Len( cIni )
			
				cAux := substr( cIni, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NKG_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NKG_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
			
	ElseIf AT(cHifen, mvpar15) > 0
		nTam := Len(mvpar15)
		nPos := AT(cHifen, mvpar15)
		cIni := SUBSTR(mvpar15, 1, (nTam - nPos))
		cFim := SUBSTR(mvpar15, (nPos + 1), nTam)
		
		cFiltro += " AND NKG_STATUS >= '" + cIni + "'"
		cFiltro += " AND NKG_STATUS <= '" + cFim + "'"
		
 	ElseIf AT(cPV, mvpar15) > 0
		If Len(mvpar15) > 0
			For nX := 1 to Len( mvpar15 )
			
				cAux := substr( mvpar15, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NKG_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NKG_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
	ElseIf Len(mvpar15) = 1
	
		cFiltro += " AND ( NKG_STATUS = '" + mvpar15 + "' )" 
	
	Endif
	
Return ( cFiltro )

/*
+=================================================================================================+
| Programa  : OGA261ACP                                                                           |
| Descrição : Verifica se a condição de pagamento é do tipo 9 e atualiza as parcelas              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/06/2016                                                                          |
+=================================================================================================+     
*/
Function OGA261ACP()
	_aParce := {}
	_lTipo := .f.
	DbSelectArea('SE4')
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(fWXfilial('SE4')+cCondPgVal)) .And. SE4->E4_TIPO == "9"
		_aParce := OGA470(cCondPgVal,nVlr)
		_lTipo := .t.
	EndIf
Return  .t.




/** {Protheus.doc} fvincNFS
Deve ser chamada apos gerar o vinculo do PV.
Rotina para criar tab. vinculo N8J,N8K ( SF2,SD2)
Quando o doc fiscal for gerado pela rotina de fechamento
de serviços

@param: 	cPedido ( Nr. do pedido de vendas gerado pelo fechamento serviço )
@author: 	Agro
@since: 	09/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function fvincNFS ( cPedido )

	Local aLinha		:= {}
	Local aVincCabNF	:= {}
	Local aVincIteNF	:= {}
	Local aVncRec		:= {}
	Local aLinVncAux	:= {}


	dbSelectArea('SD2')     
	SD2->( dbSetOrder( 8 ) )  	// D2_FILIAL+D2_PEDIDO+D2_ITEMPV                                           
	dbSelectArea( "N8I" ) 		// Tab. de vinculo de itens do pv
	N8I->( dbSetOrder( 1 ) )  	//N8I_FILIAL+N8I_NUMPV+N8I_ITEMPV                                                                                        
	If (dbSeek( FwxFilial('SD2') + cPedido))                                                                                                                                   
		While .Not. SD2->( Eof() ) .And. SD2->( D2_FILIAL + D2_PEDIDO ) == ( FWxFilial("SD2") + cPedido )			

			IF N8I->( dbSeek( fwxFilial( 'N8I' ) + SD2->D2_PEDIDO + SD2->D2_ITEMPV ))  

				//--------------------------------
				// Inicio Vinculo Doc fiscal saida!
				//--------------------------------

				//Array de vinculo do Agro com o doc. Sada

				IF Len (aVincCabNF) == 0
					aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8J')	} )
					aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC		} )
					aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
					aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} ) 
					aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
					aadd( aVincCabNF, { "N8J_TPDOC"    	, SF2->F2_TIPO   	} )
					aadd( aVincCabNF, { "N8J_CODCTR"    , N8I->N8I_CODCTR	} )
					aadd( aVincCabNF, { "N8J_CODROM"    , N8I->N8I_CODROM	} )
					aadd( aVincCabNF, { "N8J_CODFIX"    , N8I->N8I_CODFIX	} )
					aadd( aVincCabNF, { "N8J_CODROM"   	, N8I->N8I_CODROM   } )
					aadd( aVincCabNF, { "N8J_CODOTR"   	, N8I->N8I_CODOTR	} )
					aadd( aVincCabNF, { "N8J_CODFIX"	, N8I->N8I_CODFIX 	} )
					aadd( aVincCabNF, { "N8J_CODOTR"	, N8I->N8I_CODOTR	} )		
					aadd( aVincCabNF, { "N8J_ORPGRC"	, N8I->N8I_ORPGRC 	} )
					aadd( aVincCabNF, { "N8J_FECSER"	, N8I->N8I_FECSER	} )
					aadd( aVincCabNF, { "N8J_ORIGEM"	, N8I->N8I_ORIGEM	} )
					aadd( aVincCabNF, { "N8J_HISTOR"	, N8I->N8I_HISTOR	} )
				EndIf


				aLinha := {}
				aadd( aLinha, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
				aadd( aLinha, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
				aadd( aLinha, { "N8K_SERIE"    	, SD2->D2_SERIE		} )
				aadd( aLinha, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} ) 
				aadd( aLinha, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
				aadd( aLinha, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
				aadd( aLinha, { "N8K_PRODUT"    , SD2->D2_COD 		} )
				aadd( aLinha, { "N8K_TPPROD"    , N8I->N8I_TPPROD	} )
				aadd( aLinha, { "N8K_CODCTR"    , N8I->N8I_CODCTR	} )
				aadd( aLinha, { "N8K_SAFRA"    	, N8I->N8I_SAFRA 	} )
				aadd( aLinha, { "N8K_CODROM"   	, N8I->N8I_CODROM   } )
				aadd( aLinha, { "N8K_ITEROM"   	, N8I->N8I_ITEROM	} )
				aadd( aLinha, { "N8K_CODFIX"    , N8I->N8I_CODFIX 	} )
				aadd( aLinha, { "N8K_CODOTR"    , N8I->N8I_CODOTR	} )		
				aadd( aLinha, { "N8K_ITEOTR"    , N8I->N8I_ITEOTR 	} )
				aadd( aLinha, { "N8K_ORPGRC"    , N8I->N8I_ORPGRC 	} )
				aadd( aLinha, { "N8K_FECSER"    , N8I->N8I_FECSER	} )
				aadd( aLinha, { "N8K_ORIGEM"    , N8I->N8I_ORIGEM	} )
				aadd( aLinha, { "N8K_HISTOR"    , N8I->N8I_HISTOR	} )

				aAdd( aVincIteNF, aLinha )
			EndIF
			
			IF Len (aVncRec) == 0
				cHist :=  FWI18NLang("OGA261A","STR0122",122) 
				aVncCRec :={}
				SF2->(DBSETORDER(1))  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				IF SF2->( DBSEEK(Fwxfilial('SF2') + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_FORMUL + D2_TIPO)))

					dbSelectArea( "SE1" ) // Titulo a Receber
					dbSetOrder( 2 )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					dbSeek( xFilial( "SE1" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) )
					While	.Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == xFilial( "SE1" );
					.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL )

						DbselectArea( 'N8L' )
						N8L->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
						IF .NOT. N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

							//vinculando o contas a receber.
							aLinVncAux := {}
							aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
							aadd( aLinVncAux, { "N8L_FILORI"    	, SE1->E1_FILORIG 				} )
							aadd( aLinVncAux, { "N8L_PREFIX"    	, SE1->E1_PREFIXO				} )
							aadd( aLinVncAux, { "N8L_NUM"    		, SE1->E1_NUM					} )
							aadd( aLinVncAux, { "N8L_PARCEL"    	, SE1->E1_PARCELA				} )
							aadd( aLinVncAux, { "N8L_TIPO"    		, SE1->E1_TIPO					} )
							aadd( aLinVncAux, { "N8L_CODCTR"    	, N8I->N8I_CODCTR				} )
							aadd( aLinVncAux, { "N8L_SAFRA"    		, N8I->N8I_SAFRA				} )													
							aadd( aLinVncAux, { "N8L_CODROM"    	, ''							} )
							aadd( aLinVncAux, { "N8L_ITEROM"   		, ''							} )
							aadd( aLinVncAux, { "N8L_CODFIX"   		, ''							} )
							aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''							} )
							aadd( aLinVncAux, { "N8L_ITPGRC"   		, ''							} )
							aadd( aLinVncAux, { "N8L_FECSER"   		, N8I->N8I_FECSER				} )	
							aadd( aLinVncAux, { "N8L_ORIGEM"    	, 'OGA261A'						} )
							aAdd( aLinVncAux, { "N8L_HISTOR"    	, cHist							} )  //Fechamento de Serviços												

							aAdd(aVncCRec, aLinvncAux)
						EndIF

						SE1->( DbSkip() )
					EndDo
				EndIF
			EndIF									
			SD2->( DbSkip() )
		EndDo
	EndIF

	IF Len (aVincCabNF) > 0
		lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  	//Incluir
	EndIF
	
	IF  Len( aVncCRec ) > 0
		fAgrVncRec (aVncCRec, 3 )  	//Incluir
	EndIF

Return( lVinculou )
