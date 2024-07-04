#INCLUDE "OGR280.ch"
#include "protheus.ch"

/** {Protheus.doc} OGR280
Relatório de Contratos Compra/Vendas

@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	22/04/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGR280()
Local aAreaAtu 	:= GetArea()
Local oReport		:= Nil
Private cPergunta	:= "OGR280001"

If TRepInUse()
	
	Pergunte( cPergunta, .f. )
	oReport := ReportDef()
	oReport:PrintDialog()
	
EndIf

RestArea( aAreaAtu )
Return( Nil )


Static Function ReportDef()
Local oReport		:= Nil
Local oSection1		:= Nil

oReport := TReport():New("OGR280", STR0001, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002) //"Relatório de Contratos"###"Este relatório tem como objetivo imprimir os dados dos contratos de compra conforme os paramêtros informados."

oReport:SetTotalInLine( .f. )
oReport:SetLandScape()

oSection1 := TRSection():New( oReport, STR0003, { "NJR", "NJ0" } ) //"Contrato"

//TRCell():New( oSection1, "NJR_FILIAL"	, "NJR" 	, , , 15 )
TRCell():New( oSection1, "NJR_CODCTR"	, "NJR" 	, , , 15 )
TRCell():New( oSection1, "NJ0_NOME"	, "NJ0" 	, , , 20 )

//// Marlon: Comentado em 19/03/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//TRCell():New( oSection1, "NJ0_MUNIC"	, "NJ0" 	, , , 20 )
//TRCell():New( oSection1, "NJ0_EST"		, "NJ0" 	, , , 10 )
TRCell():New( oSection1, "NJR_DESPRO"	, "NJR" 	)
TRCell():New( oSection1, "NJR_STATUS"	, "NJR" 	)
TRCell():New( oSection1, "COLX"			,			, STR0004 , PesqPict('NJ0', 'NJ0_NOMLOJ') , 45, , , "LEFT", , "LEFT" ) //"Origem"

//Estoque
TRCell():New( oSection1, "NJR_QTDCTR"	, "NJR" 	, , , 20)
TRCell():New( oSection1, "NJR_AUTENT"	, "NJR" 	, , , 20)
TRCell():New( oSection1, "NJR_QTEFIS"	, "NJR" 	, , , 20)
TRCell():New( oSection1, "NJR_QTEFCO"	, "NJR" 	, , , 20)
TRCell():New( oSection1, "NJR_QTSFIS"	, "NJR" 	, , , 20)
TRCell():New( oSection1, "NJR_QTSFCO"	, "NJR"	, , , 20)
TRCell():New( oSection1, "COLA"			,			, STR0005 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "1", ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTEFIS ) - QryT1->( NJR_QTSFIS ) ) ), ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTSFIS ) - QryT1->( NJR_QTEFIS ) ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fis."
TRCell():New( oSection1, "COLB"			,			, STR0006 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "1", ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTEFCO ) - QryT1->( NJR_QTSFCO ) ) ), ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTSFCO ) - QryT1->( NJR_QTEFCO ) ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fco."

//Fiscal
TRCell():New( oSection1, "NJR_VLRUNI"	, "NJR" 	, , , 25)
TRCell():New( oSection1, "NJR_VLRTOT"	, "NJR" 	, , , 25)
TRCell():New( oSection1, "NJR_VLEFIS"	, "NJR"	, , , 25)
TRCell():New( oSection1, "NJR_VLSFIS"	, "NJR"	, , , 25)

TRCell():New( oSection1, "COLC"			,			, STR0007 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , { | x | x := BuscaVLP()  }, "RIGHT", , "RIGHT" ) //"Val. Liq."
TRCell():New( oSection1, "COLD"			,			, STR0008 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , { | x | x := BuscaVLPD() }, "RIGHT", , "RIGHT" ) //"Val. Liq. Dev."

//Financeiro
TRCell():New( oSection1, "COLE"			,			, STR0009 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF Pago"
TRCell():New( oSection1, "COLF"			,			, STR0010 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF A Pagar"
TRCell():New( oSection1, "COLG"			,			, STR0011 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF p/ Fatura"

TRCell():New( oSection1, "COLH"			,			, STR0012 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"FT Pago"
TRCell():New( oSection1, "COLI"			,			, STR0013 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"FT A Pagar"

TRCell():New( oSection1, "COLJ"			,			, STR0014 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Devolvido"
TRCell():New( oSection1, "COLK"			,			, STR0015 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Adiantado"

TRCell():New( oSection1, "COLL"			,			, STR0016 		, PesqPict('NJR', 'NJR_VLRTOT') , 25, , , "RIGHT", , "RIGHT" ) //"A Pagar s/ Fat."
TRCell():New( oSection1, "COLM"			,			, STR0017 		, PesqPict('NJR', 'NJR_VLRTOT') , 25, , , "RIGHT", , "RIGHT" ) //"A Pagar s/ Ctr."


oBreak1 := TRBreak():New( oSection1, "", STR0018, .f. ) //"Total dos Contratos -->"

TRFunction():New(oSection1:Cell( "NJR_QTDCTR" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )


Return( oReport )


Static Function PrintReport( oReport )
Local oS1		:= oReport:Section( 1 )
Local cFilDe	:= ""
Local cFilAte	:= "ZZ"
Local cCtrDe	:= mv_par01
Local cCtrAte	:= mv_par02
Local dDataDe	:= mv_par03
Local dDataAte	:= mv_par04
Local cEntDe	:= mv_par05
Local cEntAte	:= mv_par06

Local cFilNJ0	:= Space( FwSizeFilial() )

Local cFiltro	:= ""

If oReport:Cancel()
	Return( Nil )
EndIf

cFiltro += "NJR.NJR_FILIAL >= '" + cFilDe + "' And NJR.NJR_FILIAL <= '" + cFilAte + "' "
cFiltro += "AND NJR.NJR_CODCTR >= '" + cCtrDe + "' And NJR.NJR_CODCTR <= '" + cCtrAte + "' "
cFiltro += "And NJR.NJR_TIPO = '1' "
cFiltro += "And NJR.NJR_DATA >= '" + DtoS( dDataDe ) + "' And NJR.NJR_DATA <= '" + DtoS( dDataAte ) + "' "
cFiltro += "And NJR.NJR_CODENT || NJR.NJR_LOJENT >= '" + cEntDe + "' And NJR.NJR_CODENT || NJR.NJR_LOJENT <= '" + cEntAte + "' "
cFiltro := "%" + cFiltro + "%"

oS1:BeginQuery()
	BeginSql Alias "QryT1"
		Select
			NJR.*,
			NJ0.*
		From
			%table:NJR% NJR,
			%table:NJ0% NJ0
		Where
			NJR.NJR_CODENT = NJ0.NJ0_CODENT And
			NJR.NJR_LOJENT = NJ0.NJ0_LOJENT And
			%Exp:cFiltro% And
			NJR.%notDel% And
			NJ0.%notDel%
		Order By
			NJR_FILIAL,
			NJR.NJR_CODCTR
	EndSql
oS1:EndQuery()

oS1:Init()

QryT1->( dbGoTop() )
While .Not. QryT1->( Eof( ) )
    
    oS1:Cell("NJR_DESPRO"):SetValue(Posicione('SB1',1,xFilial('SB1')+QryT1->(NJR_CODPRO),'B1_DESC'))
    
	aValores := BuscaCP()

	oS1:Cell( "COLE" ):SetValue( aValores[2] )
	oS1:Cell( "COLF" ):SetValue( aValores[3] )
	oS1:Cell( "COLG" ):SetValue( aValores[4] )
	oS1:Cell( "COLH" ):SetValue( aValores[5] )
	oS1:Cell( "COLI" ):SetValue( aValores[6] )
	oS1:Cell( "COLJ" ):SetValue( aValores[8] )
	oS1:Cell( "COLK" ):SetValue( aValores[9] )

	oS1:Cell( "COLL" ):SetValue( ( ( aValores[1] + aValores[4] ) - ( aValores[2] + aValores[5] + aValores[8] + aValores[9] ) ) )
	oS1:Cell( "COLM" ):SetValue( ( ( QryT1->( NJR_VLRTOT ) ) - ( aValores[2] + aValores[5] + aValores[8] + aValores[9] ) ) )

	NNY->( dbSelectArea( 1 ) )
	NNY->( dbSeek( QryT1->( NJR_FILIAL ) + QryT1->( NJR_CODCTR ) ) )
	cFilNJ0 := IIf( Empty( xFilial( "NJ0" ) ), Space( FwSizeFilial() ), QryT1->( NJR_FILIAL ) )

	NJ0->( dbSetOrder( 1 ) )
	NJ0->( dbSeek( cFilNJ0 + NNY->( NNY_ENTORI ) + NNY->( NNY_LOJORI )) )
	OS1:Cell( "COLX" ):SetValue( NJ0->( NJ0_NOMLOJ ) )


	oS1:PrintLine( )

	QryT1->( dbSkip() )
EndDo
oS1:Finish()

Return( )


/** {Protheus.doc} BuscaCP
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	10/05/2004
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function BuscaCP( )
Local aRetorno	:= { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
Local nNFTotal	:= 0
Local nNFPaga	:= 0
Local nNFAPagar	:= 0
Local nFTTotal	:= 0
Local nFTPaga	:= 0
Local nFTAPagar	:= 0
Local nDevTot	:= 0
Local nDevSld	:= 0
Local nAdtoSld	:= 0

/**
 * Obtem valor dos faturamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_VALOR ) as E2VALOR,
		Sum( SE2.E2_SALDO ) as E2SALDO
	From
		%table:SE2% SE2
	    INNER JOIN %Table:N8M% N8M
	    	ON  N8M.N8M_FILIAL 	= SE2.E2_FILIAL
	    	AND N8M.N8M_PREFIX 	= SE2.E2_PREFIXO
	    	AND N8M.N8M_NUM	   	= SE2.E2_NUM
	    	AND N8M.N8M_PARCEL 	= SE2.E2_PARCELA
	    	AND N8M.N8M_TIPO	= SE2.E2_TIPO
	    	AND N8M.D_E_L_E_T_  	!= '*'		
	Where
		SE2.E2_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		N8M.N8M_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		SE2.E2_TIPO = 'NF' And
		SE2.E2_FATURA = ' ' And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nNFTotal	:= QryT2->( E2VALOR )
	nNFPaga 	:= QryT2->( E2VALOR ) - QryT2->( E2SALDO )
	nNFAPagar 	:= QryT2->( E2SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos faturamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_VALOR ) as E2VALOR,
		Sum( SE2.E2_SALDO ) as E2SALDO
	From
		%table:SE2% SE2
	Where
		SE2.E2_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		SE2.E2_NUM = %Exp:QryT1->( NJR_CODCTR )% And
		SE2.E2_PREFIXO = 'OP' And
		SE2.E2_TIPO Like 'FT%' And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nFTTotal	:= QryT2->( E2VALOR )
	nFTPaga 	:= QryT2->( E2VALOR ) - QryT2->( E2SALDO )
	nFTAPagar 	:= QryT2->( E2SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos adiantamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_VALOR ) as E2VALOR,
		Sum( SE2.E2_SALDO ) as E2SALDO
	From
		%table:SE2% SE2
		INNER JOIN %Table:N8M% N8M
			ON  N8M.N8M_FILIAL 	= SE2.E2_FILIAL
	    	AND N8M.N8M_PREFIX 	= SE2.E2_PREFIXO 
	    	AND N8M.N8M_NUM	   	= SE2.E2_NUM 
	    	AND N8M.N8M_PARCEL 	= SE2.E2_PARCELA
	    	AND N8M.N8M_TIPO	= SE2.E2_TIPO
	    	AND N8M.D_E_L_E_T_  	!= '*'		
	Where
		SE2.E2_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		N8M.N8M_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		SE2.E2_TIPO   = 'NDF' And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nDevTot := QryT2->( E2VALOR )
	nDevSld := QryT2->( E2SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos adiantamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_SALDO ) as E2SALDO
	From
		%table:SE2% SE2
	Where
		SE2.E2_FILIAL  = %Exp:QryT1->( NJR_FILIAL )% And
		SE2.E2_NUM     = %Exp:QryT1->( NJR_CODCTR )% And
		SE2.E2_PREFIXO = 'OPA' And
		SE2.E2_TIPO    = 'PA' And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nAdtoSld := QryT2->( E2SALDO )
EndIf
QryT2->( dbCloseArea() )

aRetorno[ 1 ] := nNFTotal
aRetorno[ 2 ] := nNFPaga
aRetorno[ 3 ] := nNFAPagar
aRetorno[ 4 ] := nFTTotal
aRetorno[ 5 ] := nFTPaga
aRetorno[ 6 ] := nFTAPagar
aRetorno[ 7 ] := nDevTot
aRetorno[ 8 ] := nDevSld
aRetorno[ 9 ] := nAdtoSld

Return( aRetorno )


/** {Protheus.doc} BuscaLQP
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	10/05/2004
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function BuscaVLP( )
Local nRetorno	:= 0

BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_VALOR ) as E2VALLIQ
	From
		%table:NJM% NJM,
		%table:NJJ% NJJ,
		%table:NJ0% NJ0,
		%table:SF1% SF1,		
		%table:SE2% SE2		
	Where
		NJJ.NJJ_TIPO   = '5' And
		NJM.NJM_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		NJM.NJM_FILIAL = NJJ.NJJ_FILIAL And
		NJM.NJM_CODROM = NJJ.NJJ_CODROM And
		NJM.NJM_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		NJ0.NJ0_CODENT = NJM.NJM_CODENT And
		NJ0.NJ0_LOJENT = NJM.NJM_LOJENT And
		SF1.F1_FILIAL  = NJJ.NJJ_FILIAL And
		SF1.F1_DOC     = NJM.NJM_DOCNUM And
		SF1.F1_SERIE   = NJJ.NJJ_DOCSER And
		SF1.F1_FORNECE = NJ0.NJ0_CODFOR And
		SF1.F1_LOJA    = NJ0.NJ0_LOJFOR And
		SE2.E2_PREFIXO = SF1.F1_SERIE   And
		SE2.E2_NUM     = SF1.F1_DOC     And
		SE2.E2_FORNECE = SF1.F1_FORNECE And
		SE2.E2_LOJA    = SF1.F1_LOJA    And
		NJM.%NotDel% And
		NJJ.%NotDel% And
		NJ0.%NotDel% And
		SF1.%NotDel% And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nRetorno += QryT2->( E2VALLIQ )
EndIf
QryT2->( dbCloseArea() )

Return( nRetorno )


/** {Protheus.doc} BuscaLQP
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	10/05/2004
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function BuscaVLPD( )
Local nRetorno	:= 0

BeginSql Alias "QryT2"
	Select
		Sum( SE2.E2_VALOR ) as E2VALLIQ
	From
		%table:NJM% NJM,
		%table:NJJ% NJJ,
		%table:NJ0% NJ0,
		%table:SF2% SF2,	
		%table:SE2% SE2
	Where
		NJJ.NJJ_TIPO   = '8' And
		NJM.NJM_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		NJM.NJM_FILIAL = NJJ.NJJ_FILIAL And
		NJM.NJM_CODROM = NJJ.NJJ_CODROM And
		NJM.NJM_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		NJ0.NJ0_CODENT = NJM.NJM_CODENT And
		NJ0.NJ0_LOJENT = NJM.NJM_LOJENT And
		SF2.F2_FILIAL  = NJJ.NJJ_FILIAL And
		SF2.F2_DOC     = NJM.NJM_DOCNUM And
		SF2.F2_SERIE   = NJM.NJM_DOCSER And
		SF2.F2_CLIENTE = NJ0.NJ0_CODFOR And
		SF2.F2_LOJA    = NJ0.NJ0_LOJFOR And
		SE2.E2_PREFIXO = SF2.F2_SERIE   And
		SE2.E2_NUM     = SF2.F2_DOC     And
		SE2.E2_FORNECE = SF2.F2_CLIENTE And
		SE2.E2_LOJA    = SF2.F2_LOJA    And
		NJM.%NotDel% And 
		NJJ.%NotDel% And
		NJ0.%NotDel% And
		SF2.%NotDel% And
		SE2.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nRetorno += QryT2->( E2VALLIQ )
EndIf
QryT2->( dbCloseArea() )

Return( nRetorno )

