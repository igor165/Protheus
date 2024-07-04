#INCLUDE "OGX012.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/////////////////////////////////////////////////////////////////
////															     ////
////  FUNÇÕES GENÉRICAS RELACIONADAS A AUTORIZACAO           ////
////															     ////
/////////////////////////////////////////////////////////////////

#define ACOL_CTRATO	01
#define ACOL_ITEM		02
#define ACOL_TIPO		03
#define ACOL_QTDAUT	04
#define ACOL_QTDEXC	05
#define ACOL_QTDSDO	06
#define ACOL_TALHAO	07
#define ACOL_CODTER	08
#define ACOL_NOMTER	09
#define ACOL_DATINI	10
#define ACOL_DATFIM	11
#define ACOL_VAZIO	12


/** {Protheus.doc} OGX012AU
Rotina para consulta padrao da tabela de Autorizacoes

@param: 	Nil
@return:	Nil
@author: 	Gilson Venturi
@since: 	18/05/2015
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX012AU( cCtrato, iTipo )
Local aAreaAtu	:= GetArea()
Local nOpcX		:= 0
Local nOpcao		:= 0
Local aButtons	:= {}
Local nTamH 		:= ( GetScreenRes()[1] - 400 )
Local nTamV 		:= ( GetScreenRes()[2] - 400 )

Private oDlg		:= Nil
Private oBrowse	:= Nil
Private aItens	:= Array(1, 12)

Public __cCodigo	:= Space( TamSX3( "NJP_ITEM" )[1] )

Default cCtrato	:= ""
Default iTipo		:= ""


oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0001+" - "+STR0002, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Consulta Personalizada" - "Autorizacao"
oDlg:lEscClose := .f.

	oPnlT := TPanel():New( 1, 1, , oDlg, , , , , , 0, 0, .f., .t. )
	oPnlT:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlB := TPanel():New( 0, 0, , oPnlT, , , , , RGB(67,70,87), 15, 15, .f., .f. )
	oPnlB:Align := CONTROL_ALIGN_LEFT

	oBrowse := TCBrowse():New( 1, 1, 60, 156, , , , oPnlT, , , , {|| nOpcao := oBrowse:nAt }, {|| nOpcao := oBrowse:nAt, nOpcX := 1, oDlg:End() }, , , , , , , .f., ,.t., ,.f., , , )
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_CODCTR")	, { || aItens[oBrowse:nAt,ACOL_CTRATO]}, , , , "LEFT" ,35 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_ITEM")		, { || aItens[oBrowse:nAt,ACOL_ITEM]}, , , , "LEFT" ,35 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_TIPO")		, { || aItens[oBrowse:nAt,ACOL_TIPO]}, , , , "LEFT" ,05 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_QTDAUT")	, { || Transform( aItens[oBrowse:nAt, ACOL_QTDAUT], "@E 999,999,999.99" )}, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_QTDEXC")	, { || Transform( aItens[oBrowse:nAt, ACOL_QTDEXC], "@E 999,999,999.99" )}, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( STR0003					, { || Transform( aItens[oBrowse:nAt, ACOL_QTDSDO], "@E 999,999,999.99" )}, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_TALHAO")	, { || aItens[oBrowse:nAt, ACOL_TALHAO] }, , , , "LEFT" ,10 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_CODTER")	, { || aItens[oBrowse:nAt, ACOL_CODTER] }, , , , "LEFT" ,40 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJ0_NOME")		, { || aItens[oBrowse:nAt, ACOL_NOMTER] }, , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_DATINI")	, { || aItens[oBrowse:nAt, ACOL_DATINI] }, , , , "RIGHT" ,40 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJP_DATFIM")	, { || aItens[oBrowse:nAt, ACOL_DATFIM] }, , , , "RIGHT" ,40 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( ""							, { || aItens[oBrowse:nAt, ACOL_VAZIO] } , , , , "LEFT" , , .f., .t., , , ,.f., ) )

	f003AItens( cCtrato, iTipo )

oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

If nOpcX > 0 .And. Len( aItens ) > 0
	__cCodigo := aItens[ nOpcao, 2 ]
EndIf

RestArea( aAreaAtu )
Return( .t. )


/** {Protheus.doc} f003AItens
Rotina auxiliar para seleção de autorizacoes

@param: 	Nil
@return:	Nil
@author: 	Gilson Venturi
@since: 	18/05/2015
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Static Function f003AItens( cCtrato, iTipo )
Local aAreaAtu	:= GetArea()
Local aTempo		:= Array( 0 )
Local nX			:= 1
Local cFiltroQry	:= ""

Default iTipo		:= ""


If iTipo $ "1|3|5|7|9"  // Entrada
	cFiltroQry += "AND NJP.NJP_TIPO = 'E'"
ElseIf iTipo $ "2|4|6|8" // Saída
	cFiltroQry += "AND NJP.NJP_TIPO = 'S'"
Endif

cFiltroQry := "%" + cFiltroQry + "%"


BeginSql Alias 'QryNJP'
	column NJP_DATINI as Date
	column NJP_DATFIM as Date
	
	Select
		NJP_CODCTR,
		NJP_ITEM,
		NJP_TIPO,
		NJP_QTDAUT,
		NJP_QTDEXC,
		NJP_QTDAUT,
		NJP_QTDEXC,
		NJP_QTDFCO,
		NJP_TALHAO,
		NJP_CODTER,
		NJ0_NOME,
		NJP_DATINI,
		NJP_DATFIM
  FROM %table:NJP% NJP
  LEFT JOIN %Table:NJ0% NJ0
	 ON NJ0.NJ0_CODENT	= NJP.NJP_CODTER
	AND NJ0.NJ0_LOJENT	= NJP.NJP_LOJTER
	AND NJ0.NJ0_FILIAL	= %xFilial:NJ0%
	AND NJ0.%NotDel%
 WHERE NJP.NJP_FILIAL = %xFilial:NJP%
   AND NJP.NJP_CODCTR = %exp:cCtrato%
   AND NJP.%NotDel%
   %Exp:cFiltroQry%
   AND NJP.NJP_STATUS <> "E" // A=Aberta, I=Iniciada, E=Encerrada
   AND NJP.NJP_QTDAUT - NJP.NJP_QTDFCO <> 0 // Somente com Saldo
 ORDER BY NJP_ITEM
EndSql

While .Not. Eof()
	aAdd( aTempo, {} )
	aAdd( aTempo[nX], QryNJP->( NJP_CODCTR ) )								 // ACOL_CTRATO	01
	aAdd( aTempo[nX], QryNJP->( NJP_ITEM ) )									 // ACOL_ITEM		02
	aAdd( aTempo[nX], QryNJP->( NJP_TIPO ) )									 // ACOL_TIPO		03
	aAdd( aTempo[nX], QryNJP->( NJP_QTDAUT ) ) 								 // ACOL_QTDAUT	04
	aAdd( aTempo[nX], QryNJP->( NJP_QTDEXC ) ) 								 // ACOL_QTDEXC	05
	aAdd( aTempo[nX], QryNJP->( (NJP_QTDAUT + NJP_QTDEXC) - NJP_QTDFCO ) ) // ACOL_QTDSDO	06
	aAdd( aTempo[nX], QryNJP->( NJP_TALHAO ) )								 // ACOL_TALHAO	07
	aAdd( aTempo[nX], QryNJP->( NJP_CODTER ) )								 // ACOL_CODTER	08
	aAdd( aTempo[nX], QryNJP->( NJ0_NOME ) )									 // ACOL_NOME		09
	aAdd( aTempo[nX], DToC( QryNJP->( NJP_DATINI ) ) )						 // ACOL_DATINI	10
	aAdd( aTempo[nX], DToC( QryNJP->( NJP_DATFIM ) ) )						 // ACOL_DATIFM	11
	aAdd( aTempo[nX], "" ) 														 // ACOL_VAZIO	12

	nX++

	dbSkip()
EndDo

QryNJP->( dbCloseArea() )

aItens := aClone( aTempo )
oBrowse:SetArray( aItens )

RestArea( aAreaAtu )
Return( )


/** {Protheus.doc} OGX010SAut
Rotina auxiliar para seleção automatica de autorização

@param: 	cCodCtr - Codigo do Contrato
@return:	cCodAut - Codigo da Autorização
@author: 	Gilson Venturi
@since: 	11/08/2015
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX010SAut( cCodCtr, iTipo )
Local aAreaAtu := GetArea()
Local cCodAut  := ""
Local cFiltro  := ""

Default iTipo := ""

If iTipo $ "1|3|5|7|9"  // Entrada
	cFiltro += "AND NJP.NJP_TIPO = 'E'"
ElseIf iTipo $ "2|4|6|8" // Saída
	cFiltro += "AND NJP.NJP_TIPO = 'S'"
Endif 

cFiltro := "%" + cFiltro + "%"

BeginSql Alias 'QryNJP1'
	SELECT Count( * ) As Total 
	FROM	%table:NJP% NJP
	WHERE NJP.NJP_FILIAL = %xFilial:NJP%
	  AND NJP.NJP_CODCTR = %exp:cCodCtr%
	  AND NJP.%NotDel%
	  %Exp:cFiltro%
	  AND NJP.NJP_STATUS <> 'E' //A=Aberta, I=Iniciada, E=Encerrada
	  AND NJP_QTDAUT - NJP_QTDFCO <> 0 // somente com saldo
EndSql

If .Not. QryNJP1->( Eof() ) .And. QryNJP1->( Total ) > 0
	If QryNJP1->( Total ) = 1
		BeginSql Alias 'QryNJP2'
			SELECT NJP_ITEM 
			FROM	%table:NJP% NJP
			WHERE NJP.NJP_FILIAL = %xFilial:NJP%
			  AND NJP.NJP_CODCTR = %exp:cCodCtr%
			  AND NJP.%NotDel%
			  %Exp:cFiltro%
			  AND NJP.NJP_STATUS <> 'E' //A=Aberta, I=Iniciada, E=Encerrada
			  AND NJP.NJP_QTDAUT - NJP.NJP_QTDFCO <> 0 // somente com saldo
		EndSql

		cCodAut := QryNJP2->( NJP_ITEM )
		QryNJP2->( dbCloseArea( ) )
	Else
		If OGX012AU( cCodCtr, iTipo ) = .T. // Abre tela para selecionar autorizacao
			cCodAut := __cCodigo
		Endif
	EndIf

EndIf

QryNJP1->( dbCloseArea( ) )

RestArea( aAreaAtu )
Return( cCodAut )