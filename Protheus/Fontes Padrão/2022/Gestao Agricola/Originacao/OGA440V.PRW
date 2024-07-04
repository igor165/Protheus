#INCLUDE "OGA440V.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA440V
Tela de gestor de entidade.

@param: 	pcCodEnt - Código da entidade
@param: 	pcLojEnt - Loja da entidade
@author: 	Marlon Richard Trettin
@since: 	17/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA440V( pcIDMOV ) 
	Local aAreaAtu := GetArea()
	Local lRetorno := .F.
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer := Nil
	Local nX       := 0
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//--- Definição da estrutura da tabela temporária de Saldos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruNJM := { { "COL_MARK"  , "C", 2, 0 , , } , ;
							{ "COL_STATUS", "C", TamSX3( "NJJ_STATUS" )[ 1 ], 0 , RetTitle( "NJJ_STATUS" )	, "@" },;
	 						{ "COL_FILIAL", "C", TamSX3( "NJM_FILIAL" )[ 1 ], 0 , RetTitle( "NJM_FILIAL" )	, PesqPict("NJM","NJM_FILIAL") },;
	 						{ "COL_TIPO"  , "C", TamSX3( "NJJ_TIPO" )[ 1 ]  , 0 , RetTitle( "NJJ_TIPO" )		, "@!" },;
	 						{ "COL_DSTIPO", "C", 25                         , 0 , RetTitle( "NJJ_DSTIPO" )	, "@!" },;
							{ "COL_TIPENT", "C", TamSX3( "NJJ_TIPENT" )[ 1 ], 0 , RetTitle( "NJJ_TIPENT" )	, PesqPict("NJM","NJJ_TIPENT") },;
	 						{ "COL_DSTPEN", "C", 10                         , 0 , RetTitle( "NJJ_TIPENT" )	, "@!" },;
							{ "COL_CODROM", "C", TamSX3( "NJM_CODROM" )[ 1 ], 0 , RetTitle( "NJM_CODROM" )	, PesqPict("NJM","NJM_CODROM") },;						
							{ "COL_ITEROM", "C", TamSX3( "NJM_ITEROM" )[ 1 ], 0 , RetTitle( "NJM_ITEROM" )	, PesqPict("NJM","NJM_ITEROM") },;						
							{ "COL_IDMOV" , "C", TamSX3( "NJM_IDMOV" )[ 1 ] , 0 , RetTitle( "NJM_IDMOV" )	, PesqPict("NJM","NJM_IDMOV")  },;
							{ "COL_CODENT", "C", TamSX3( "NJM_CODENT" )[ 1 ], 0 , RetTitle( "NJM_CODENT" )	, PesqPict("NJM","NJM_CODENT") },;
							{ "COL_LOJENT", "C", TamSX3( "NJM_LOJENT" )[ 1 ], 0 , RetTitle( "NJM_LOJENT" )	, PesqPict("NJM","NJM_LOJENT") },;
							{ "COL_NOMENT", "C", TamSX3( "NJM_NOMENT" )[ 1 ], 0 , RetTitle( "NJM_NOMENT" )	, PesqPict("NJM","NJM_NOMENT") },;
							{ "COL_NLJENT", "C", TamSX3( "NJM_NLJENT" )[ 1 ], 0 , RetTitle( "NJM_NLJENT" )	, PesqPict("NJM","NJM_NLJENT") },;
							{ "COL_CODSAF", "C", TamSX3( "NJM_CODSAF" )[ 1 ], 0 , RetTitle( "NJM_CODSAF" )	, PesqPict("NJM","NJM_CODSAF") },;
							{ "COL_CODPRO", "C", TamSX3( "NJM_CODPRO" )[ 1 ], 0 , RetTitle( "NJM_CODPRO" )	, PesqPict("NJM","NJM_CODPRO") },;
							{ "COL_DESPRO", "C", TamSX3( "NJM_DESPRO" )[ 1 ], 0 , RetTitle( "NJM_DESPRO" )	, PesqPict("NJM","NJM_DESPRO") },;
							{ "COL_UM1PRO", "C", TamSX3( "NJM_UM1PRO" )[ 1 ], 0 , RetTitle( "NJM_UM1PRO" )	, PesqPict("NJM","NJM_UM1PRO") },;
							{ "COL_CODCTR", "C", TamSX3( "NJM_CODCTR" )[ 1 ], 0 , RetTitle( "NJM_CODCTR" )	, PesqPict("NJM","NJM_CODCTR") },;
							{ "COL_DESCTR", "C", TamSX3( "NJM_DESCTR" )[ 1 ], 0 , RetTitle( "NJM_DESCTR" )	, PesqPict("NJM","NJM_DESCTR") },;
							{ "COL_PERDIV", "N", TamSX3( "NJM_PERDIV" )[ 1 ], TamSX3( "NJM_PERDIV" )[ 2 ], RetTitle( "NJM_PERDIV" ), PesqPict("NJM","NJM_PERDIV") },;
							{ "COL_QTDFCO", "N", TamSX3( "NJM_QTDFCO" )[ 1 ], TamSX3( "NJM_QTDFCO" )[ 2 ], RetTitle( "NJM_QTDFCO" ), PesqPict("NJM","NJM_QTDFCO") },;
							{ "COL_QTDFIS", "N", TamSX3( "NJM_QTDFIS" )[ 1 ], TamSX3( "NJM_QTDFIS" )[ 2 ], RetTitle( "NJM_QTDFIS" ), PesqPict("NJM","NJM_QTDFIS") },;
							{ "COL_VLRUNI", "N", TamSX3( "NJM_VLRUNI" )[ 1 ], TamSX3( "NJM_VLRUNI" )[ 2 ], RetTitle( "NJM_VLRUNI" ), PesqPict("NJM","NJM_VLRUNI") },;
							{ "COL_VLRTOT", "N", TamSX3( "NJM_VLRTOT" )[ 1 ], TamSX3( "NJM_VLRTOT" )[ 2 ], RetTitle( "NJM_VLRTOT" ), PesqPict("NJM","NJM_VLRTOT") },;
							{ "COL_DOCNUM", "C", TamSX3( "NJM_DOCNUM" )[ 1 ], 0 , RetTitle( "NJM_DOCNUM" )	, PesqPict("NJM","NJM_DOCNUM") },;
							{ "COL_DOCSER", "C", TamSX3( "NJM_DOCSER" )[ 1 ], 0 , RetTitle( "NJM_DOCSER" )	, PesqPict("NJM","NJM_DOCSER") },;
							{ "COL_PEDIDO", "C", TamSX3( "NJM_PEDIDO" )[ 1 ], 0 , RetTitle( "NJM_PEDIDO" )	, PesqPict("NJM","NJM_PEDIDO") },;
							{ "COL_NJMREC", "N", 10                       , 0 , "RECNO_NJM"             	, "" },;
							{ "COL_NJJREC", "N", 10                       , 0 , "RECNO_NJJ"             	, "" },;						
							{ "COL_AIDMOV", "C", TamSX3( "NJM_IDMOV" )[ 1 ], 0 , RetTitle( "NJM_IDMOV" )	, PesqPict("NJM","NJM_IDMOV") },;
							{ "COL_ALTERA", "L", 1                        , 0 , "ALTERADO"					, "" } }
	
	Local aCpBrw  := {}
	// Definição dos índices
	Local aIndNJM := { 	"COL_FILIAL+COL_CODROM+COL_ITEROM",;
							"COL_IDMOV+COL_FILIAL+COL_CODROM+COL_ITEROM",;
							"COL_CODENT+COL_LOJENT+COL_IDMOV+COL_CODROM" } 
	
	Private oPnCab, oPnDet, oPnRod
	
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasNJM 
	Private cTrabNJM 	 
	Private oBrwNJM
	Private aIndice1
	
	Private cNoFldNJM	:= "COL_MARK,COL_STATUS,COL_TIPO,COL_TIPENT,COL_NJMREC,COL_NJJREC,COL_AIDMOV,COL_ALTERA"
	
	Private xMarca	:= GetMark()
	
	//--- Variáveis de parâmetros de entrada da tela ---// 
	Private cIDMOV := pcIDMOV
	
	
	//--- Validações de Entrada ---//
	DbSelectArea( "NKM" ) // Movimentações
	DbSetOrder( 1 )
	If DbSeek( xFilial( "NKM" ) + cIDMOV )
		cTipoMv := NKM->( NKM_TIPOMV )
		cDsTpMv := Posicione( "NKL", 1, xFilial( "NKL" ) + NKM->( NKM_TIPOMV ), "NKL_DESCRI" ) 
	Else
		MsgStop( STR0001 + Chr(13) + RetTitle( "NKM_FILIAL" ) + ": [" + xFilial( "NKM" ) + "] ; " + RetTitle( "NKM_IDMOV" )+ ": [" + cIDMOV + "]" ) //"Movimentação não localizada na tabela de movimentações (NKM)."
		Return( .F. )
	EndIf
	
	//--- Criação das tabelas temporárias ---//
	
	// Tabela temporária de Romaneios
	aRetTRB := AGRCRIATRB( , aEstruNJM, aIndNJM, FunName(), .T. )
		cTrabNJM 	:= aRetTRB[3] //Nome do arquivo temporário 
		cAliasNJM 	:= aRetTRB[4] //Nome do alias do arquivo temporario
		aCpBrw		:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndice1	:= AGRINDICONS(aIndNJM, aCpBrw )	
	
	//--- Carrega os dados para a tabela temporária ---//
	fLoadData()
	
	//--- Montagem da tela ---//
	
	oDlg := TDialog():New( aCords[ 1 ]+10, aCords[ 2 ]+20, aCords[ 3 ]-10, aCords[ 4 ]-20, STR0002, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Vinculação / Desvinculação de Romaneios à Movimentações"
	
	//--- Layers ---//
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )
	
		// Cabecalho (ID da Movimentação)
		oFWLayer:AddLine( 'LinCabec', 10, .T. )				
		oFWLayer:AddCollumn( 'ColCabec', 100, .T., 'LinCabec' )
		oPnCab := oFWLayer:GetColPanel( 'ColCabec', 'LinCabec' )
		
		// Detalhes (Romaneios)
		oFWLayer:AddLine( 'LinDetalhe', 70, .F. )
		oFWLayer:AddCollumn( 'ColDetalhe', 100, .T., 'LinDetalhe' )
		oPnDet := oFWLayer:GetColPanel( 'ColDetalhe', 'LinDetalhe' )
		
		// Rodape (Totais)
		oFWLayer:AddLine( 'LinRodape', 20, .F. )
		oFWLayer:AddCollumn( 'ColRodape', 100, .T., 'LinRodape' )
		oPnRod := oFWLayer:GetColPanel( 'ColRodape', 'LinRodape' )
		
	//--- Conteúdo dos panels ---// 
		
		// Cabeçalho
		@ 003,005  Say RetTitle( "NKM_IDMOV" )  COLOR CLR_BLACK Pixel Of oPnCab 
		@ 013,005  MSGET cIDMOV Picture PesqPict("NKM","NKM_IDMOV") WHEN .F. SIZE 060,010 PIXEL OF oPnCab  
		@ 003,100  Say RetTitle( "NKM_TIPOMV" ) COLOR CLR_BLACK Pixel Of oPnCab
		@ 013,100  MSGET cTIpoMv Picture "@!"                        WHEN .F. SIZE 040,010 PIXEL OF oPnCab  
		@ 013,140  MSGET cDsTpMv Picture "@!"                        WHEN .F. SIZE 100,010 PIXEL OF oPnCab  
		
		// Detalhes (Romaneios)
		DEFINE FWFORMBROWSE oBrwNJM DATA TABLE ALIAS cAliasNJM DESCRIPTION STR0003 OF oPnDet //"Selecione os Romaneios para vincular a Movimentação"
			oBrwNJM:SetTemporary( .T. )
			oBrwNJM:SetdbFFilter( .T. )
			oBrwNJM:SetUseFilter( .T. )	
			oBrwNJM:SetFieldFilter( AGRITEMCBRW( aCpBrw ) )	
			oBrwNJM:SetSeek(,aIndice1)	
			oBrwNJM:bVldExecFilter := {|| fTotalMark() }
			
			ADD MARKCOLUMN oColumn 	DATA { || If( (cAliasNJM)->( COL_MARK ) == xMarca, 'checked_15', 'unchecked_15' ) } ;
								DOUBLECLICK { || fMarkOne() } ;
								HEADERCLICK { || fMarkAll() } OF oBrwNJM
			
			oBrwNJM:AddLegend( "COL_STATUS=='0'", "RED"   	, X3CboxDesc( "NJJ_STATUS", "0" ) ) //Pendente
			oBrwNJM:AddLegend( "COL_STATUS=='1'", "YELLOW"   , X3CboxDesc( "NJJ_STATUS", "1" ) ) //Completo
			oBrwNJM:AddLegend( "COL_STATUS=='2'", "ORANGE"   , X3CboxDesc( "NJJ_STATUS", "2" ) ) //Atualizado
			oBrwNJM:AddLegend( "COL_STATUS=='3'", "GREEN"    , X3CboxDesc( "NJJ_STATUS", "3" ) ) //Encerrado
			oBrwNJM:AddLegend( "COL_STATUS=='4'", "BR_CANCEL", X3CboxDesc( "NJJ_STATUS", "4" ) ) //Cancelado
			For nx := 1 To Len( aCpBrw )
				If !( aCpBrw[nX,1] $ cNoFldNJM )
					ADD COLUMN oColumn DATA &('{||'+aCpBrw[nX,1]+'}') Title aCpBrw[nX,5] SIZE aCpBrw[nX,3] PICTURE aCpBrw[nX,6] Of oBrwNJM
				EndIf
			Next nx 
			
			oBrwNJM:DisableDetails()
			oBrwNJM:AddButton(STR0006,	{|| lRetorno := .F., oDlg:End() },,,,,,'40') //"Cancelar"
			oBrwNJM:AddButton(STR0004,	{|| OGX001VRom( (cAliasNJM)->( COL_NJJREC ) ) },,,,,,'40') //"Visualizar"
			oBrwNJM:AddButton(STR0005,	{|| lRetorno := .T., oDlg:End() },,,,,,'40') //"Confirmar"
			
		ACTIVATE FWFORMBROWSE oBrwNJM
		
		// Rodape (Totais)
		fTotalMark()
		
	oDlg:Activate( , , , .t., { || .t. }, , { || } )
	
	If lRetorno
		
		dbSelectArea(cAliasNJM)
		(cAliasNJM)->( dbGoTop() )
		While !(cAliasNJM)->( Eof() )
			
			// Se registro tiver sido alterado
			If (cAliasNJM)->( COL_ALTERA ) == .T.
				
				DbSelectArea( "NJM" )
				DbGoTo( (cAliasNJM)->( COL_NJMREC ) )
				If NJM->( NJM_IDMOV ) <> (cAliasNJM)->( COL_IDMOV )
					If ! Empty( NJM->( NJM_IDMOV ) ) .And. ! Empty( (cAliasNJM)->( COL_IDMOV ) )
						If MsgNoYes( 	STR0007 + (cAliasNJM)->( COL_CODROM ) + "-" + (cAliasNJM)->( COL_ITEROM ) + ; //"Confirma a troca do vínculo do romaneio "####-###
										STR0008 + (cAliasNJM)->( COL_AIDMOV ) + STR0009 + (cAliasNJM)->( COL_IDMOV ) + "?" )    //", que está vinculado a movimentação "#####" e ficará vinculado a movimentação "#####" ?"
							If RecLock( "NJM", .F. )
								NJM->( NJM_IDMOV ) := (cAliasNJM)->( COL_IDMOV )
								NJM->( MsUnLock() )
							EndIf
						EndIf
					Else
						If RecLock( "NJM", .F. )
							NJM->( NJM_IDMOV ) := (cAliasNJM)->( COL_IDMOV )
							NJM->( MsUnLock() )
						EndIf
					EndIf
				EndIf
				
			EndIf
			
			(cAliasNJM)->( dbSkip() )
		EndDo
		
	EndIf
	
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasNJM, cTrabNJM )  
	
	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	25/07/2013
@Uso: 		SIGAAGR
*/
Static Function MenuDef()    
	Local aRotina := {}
	aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } )	// Passado DUMMY porque não será usado este menu 
Return( aRotina )

/** {Protheus.doc} fLoadData()
Carrega dados da tabela temporária de Romaneios.

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	02/07/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fLoadData()
	Local aAreaAtu := GetArea()
	Local cQryNJM	 := GetNextAlias()
	
	//--- Apaga conteúdo anterior da tabela temporária ---//
	fZapTRB( cAliasNJM )
	
	//--- Query para trazer os romaneios ---//
	BeginSql Alias cQryNJM
		Select NJM.*, NJJ.*, NJM.R_E_C_N_O_ as NJM_RECNO, NJJ.R_E_C_N_O_ as NJJ_RECNO
		  From %Table:NJM% NJM
		 Inner Join %Table:NJJ% NJJ 
		    On NJJ.NJJ_FILIAL = NJM.NJM_FILIAL
		   And NJJ.NJJ_CODROM = NJM.NJM_CODROM
		   And NJJ.%NotDel%
		 Where NJM.%NotDel%
	EndSql
	
	DbselectArea( cQryNJM )
	DbGoTop()
	While (cQryNJM)->( !Eof() )
		
		RecLock( cAliasNJM, .T. )
			(cAliasNJM)->COL_MARK 	:= iIf( (cQryNJM)->( NJM_IDMOV ) == cIDMOV, xMarca, " " )
			(cAliasNJM)->COL_STATUS 	:= ( cQryNJM )->NJJ_STATUS
			(cAliasNJM)->COL_FILIAL 	:= ( cQryNJM )->NJM_FILIAL
			(cAliasNJM)->COL_TIPO 	:= ( cQryNJM )->NJM_FILIAL
			(cAliasNJM)->COL_DSTIPO 	:= Posicione('SX5',1,xFilial('SX5')+'K5'+(cQryNJM)->( NJJ_TIPO ),'X5_DESCRI') 		
			(cAliasNJM)->COL_TIPENT	:= (cQryNJM)->( NJJ_TIPENT )
			(cAliasNJM)->COL_DSTPEN	:= X3CboxDesc( "NJJ_TIPENT", (cQryNJM)->( NJJ_TIPENT ) )
			(cAliasNJM)->COL_CODROM	:= (cQryNJM)->( NJM_CODROM )
			(cAliasNJM)->COL_ITEROM	:= (cQryNJM)->( NJM_ITEROM )
			(cAliasNJM)->COL_IDMOV	:= (cQryNJM)->( NJM_IDMOV )
			(cAliasNJM)->COL_CODENT	:= (cQryNJM)->( NJM_CODENT )
			(cAliasNJM)->COL_LOJENT	:= (cQryNJM)->( NJM_LOJENT )
			(cAliasNJM)->COL_NOMENT	:=  POSICIONE('NJ0',1,XFILIAL('NJ0')+(cQryNJM)->( NJM_CODENT )+(cQryNJM)->( NJM_LOJENT ),'NJ0_NOME')
			(cAliasNJM)->COL_NLJENT	:=  POSICIONE('NJ0',1,XFILIAL('NJ0')+(cQryNJM)->( NJM_CODENT )+(cQryNJM)->( NJM_LOJENT ),'NJ0_NOMLOJ')
			(cAliasNJM)->COL_CODSAF	:= (cQryNJM)->( NJM_CODSAF )
			(cAliasNJM)->COL_CODPRO	:= (cQryNJM)->( NJM_CODPRO )
			(cAliasNJM)->COL_DESPRO	:=  Posicione('SB1',1,xFilial('SB1')+(cQryNJM)->( NJM_CODPRO ),'B1_DESC')
			(cAliasNJM)->COL_CODCTR	:= (cQryNJM)->( NJM_CODCTR )
			(cAliasNJM)->COL_DESCTR	:= Posicione('NJR',1,xFilial('NJR')+(cQryNJM)->( NJM_CODCTR ),'NJR_DESCRI')
			(cAliasNJM)->COL_PERDIV	:= (cQryNJM)->( NJM_PERDIV )
			(cAliasNJM)->COL_QTDFCO	:= (cQryNJM)->( NJM_QTDFCO )
			(cAliasNJM)->COL_QTDFIS	:= (cQryNJM)->( NJM_QTDFIS )
			(cAliasNJM)->COL_VLRUNI	:= (cQryNJM)->( NJM_VLRUNI )
			(cAliasNJM)->COL_VLRTOT	:= (cQryNJM)->( NJM_VLRTOT )
			(cAliasNJM)->COL_DOCNUM	:= (cQryNJM)->( NJM_DOCNUM )
			(cAliasNJM)->COL_DOCSER	:= (cQryNJM)->( NJM_DOCSER )
			(cAliasNJM)->COL_PEDIDO	:= (cQryNJM)->( NJM_PEDIDO )
			(cAliasNJM)->COL_NJMREC 	:= (cQryNJM)->( NJM_RECNO )
			(cAliasNJM)->COL_NJJREC 	:= (cQryNJM)->( NJJ_RECNO )
			(cAliasNJM)->COL_AIDMOV 	:= (cQryNJM)->( NJM_IDMOV )
			(cAliasNJM)->COL_ALTERA 	:= .F.
		(cAliasNJM)->( MsUnLock() )
		
		(cQryNJM)->( DbSkip() )
	EndDo
	(cQryNJM)->( DbCloseArea() )
	
	If Type("oBrwNJM") <> "U"
		oBrwNJM:Refresh(.T.)
	EndIf
	
	RestArea( aAreaAtu )
Return( NIL ) 

/** {Protheus.doc} fZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	pcAliasTRB - Alias da tabela temporária que será feito ZAP
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	02/07/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()
	
	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	Endif
	
	RestArea( aAreaAtu )
Return( NIL )

/** {Protheus.doc} fMarkOne()
Função para Marcar / Desmarcar UM registro

@param:	NIL 	
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	02/07/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fMarkOne()
	
	If !(cAliasNJM)->( Eof() )		
		RecLock( cAliasNJM, .F. )
			If (cAliasNJM)->( COL_MARK ) <> xMarca
				(cAliasNJM)->( COL_MARK )  := xMarca
				(cAliasNJM)->( COL_IDMOV ) := cIDMOV
			Else
				(cAliasNJM)->( COL_MARK )  := " "
				(cAliasNJM)->( COL_IDMOV ) := iIf( ! Empty( (cAliasNJM)->( COL_AIDMOV ) ) .And. (cAliasNJM)->( COL_AIDMOV ) <> cIDMOV, (cAliasNJM)->( COL_AIDMOV ), Space( TamSX3( "NJM_IDMOV" )[1] ) )
			EndIf
			(cAliasNJM)->( COL_ALTERA ) := ( (cAliasNJM)->( COL_IDMOV ) <> (cAliasNJM)->( COL_AIDMOV ) ) 
		MsUnlock(cAliasNJM)
	EndIf
	
	fTotalMark()
	If Type("oBrwNJM") <> "U"
//		oBrwNJM:Refresh(.T.)
		oBrwNJM:LineRefresh()
	EndIf
Return( NIL )

/** {Protheus.doc} fMarkAll()
Função para Marcar / Desmarcar TODOS registros 

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	02/07/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fMarkAll()
	Local lMarca := .F.
	
	dbSelectArea(cAliasNJM)
	(cAliasNJM)->( dbGoTop() )
	lMarca := ( (cAliasNJM)->( COL_MARK ) <> xMarca )
	While !(cAliasNJM)->( Eof() )
		
		RecLock(cAliasNJM,.f.)
			If lMarca 	// Se é para marcar todos
				(cAliasNJM)->( COL_MARK )  := xMarca
				(cAliasNJM)->( COL_IDMOV ) := cIDMOV
			Else		// Se á para desmarcar todos
				(cAliasNJM)->( COL_MARK )  := " "
				(cAliasNJM)->( COL_IDMOV ) := iIf( ! Empty( (cAliasNJM)->( COL_AIDMOV ) ) .And. (cAliasNJM)->( COL_AIDMOV ) <> cIDMOV, (cAliasNJM)->( COL_AIDMOV ), Space( TamSX3( "NJM_IDMOV" )[1] ) )
			EndIf
			(cAliasNJM)->( COL_ALTERA ) := ( (cAliasNJM)->( COL_IDMOV ) <> (cAliasNJM)->( COL_AIDMOV ) ) 
		msUnLock(cAliasNJM)
		
		(cAliasNJM)->( dbSkip() )
	EndDo
	
	fTotalMark()
	If Type("oBrwNJM") <> "U"
		oBrwNJM:Refresh(.T.)
	EndIf
Return( NIL )

/** {Protheus.doc} fTotalMark()
Função para totalizar os registros marcados

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	02/07/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fTotalMark()
	Local aAreaAtu := GetArea()
	Local aCabTot  :=	 { 	{ "TOTAIS", "C", 60, 0, "TOTAIS", "@!" },;
							{ "NJM_QTDFCO"},; 
							{ "NJM_QTDFIS"},;
							{ "NJM_VLRTOT"},;
							{ "BRANCO", "C", 60, 0, " ", "@!" } }
	Local aIteTot  := {}
	Local nPos 	 := 0
	Local cTipoRom := " "
	
	// Totaliza itens marcados 
	dbSelectArea(cAliasNJM)
	(cAliasNJM)->( dbGoTop() )
	While !(cAliasNJM)->( Eof() )
		
		If (cAliasNJM)->( COL_MARK ) == xMarca
			cTipoRom 	:= (cAliasNJM)->( COL_DSTIPO )  
			nPos 		:= aScan( aIteTot, { |x| AllTrim( x[1] ) == AllTrim( cTipoRom ) } )
			If nPos == 0
				aAdd( aIteTot, { cTipoRom, (cAliasNJM)->( COL_QTDFCO ), (cAliasNJM)->( COL_QTDFIS ), (cAliasNJM)->( COL_VLRTOT ), "" } )
			Else
				aIteTot[nPos,2] += (cAliasNJM)->( COL_QTDFCO )
				aIteTot[nPos,3] += (cAliasNJM)->( COL_QTDFIS )
				aIteTot[nPos,4] += (cAliasNJM)->( COL_VLRTOT )
			EndIf
		EndIf
		
		(cAliasNJM)->( dbSkip() )
	EndDo
	If Len( aIteTot ) == 0
		aAdd( aIteTot, { " ", 0, 0, 0, "" } )
	EndIf
	
	/// Chama a função AgrMosTotais que monta um GetDados com o array de totais, no panel indicado
	//          ( aMatCam, vVetDad, oBjeto, oBFWFor, lTamObj )
	AgrMosTotais( aCabTot, aIteTot, oPnRod,        , .T.     )
	
	RestArea( aAreaAtu )
Return( NIL )