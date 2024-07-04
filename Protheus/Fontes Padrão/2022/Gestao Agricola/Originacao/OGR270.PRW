#INCLUDE "OGR270.ch"
#include "protheus.ch"

/** {Protheus.doc} OGR270
Relatório de Contratos de 3o e em 3o

@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	22/04/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGR270()
Local aAreaAtu 	:= GetArea()
Local oReport		:= Nil
Private cPergunta	:= "OGR270001"

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

oReport := TReport():New("OGR270", STR0001, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002) //"Relatório de Contratos"###"Este relatório tem como objetivo imprimir os dados dos contratos de depósito/remessa conforme os paramêtros informados."

oReport:SetTotalInLine( .f. )
oReport:SetLandScape()

oSection1 := TRSection():New( oReport, STR0003, { "NJR", "NJ0" } ) //"Contrato"

//TRCell():New( oSection1, "NJR_FILIAL"	, "NJR" 	, , , 15 )
TRCell():New( oSection1, "NJR_TIPO"		, "NJR" 	, , , 15 )
TRCell():New( oSection1, "NJR_CODCTR"	, "NJR" 	, , , 15 )
TRCell():New( oSection1, "NJ0_NOME"		, "NJ0" 	, , , 20 )

//// Marlon: Comentado em 19/03/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//TRCell():New( oSection1, "NJ0_MUNIC"	, "NJ0" 	, , , 20 )
//TRCell():New( oSection1, "NJ0_EST"		, "NJ0" 	, , , 10 )
TRCell():New( oSection1, "NJR_DESPRO"	, "NJR" 	)
TRCell():New( oSection1, "NJR_STATUS"	, "NJR" 	)
TRCell():New( oSection1, "NJR_QTDCTR"	, "NJR" 	)
TRCell():New( oSection1, "NJR_AUTENT"	, "NJR"		)
TRCell():New( oSection1, "NJR_AUTSAI"	, "NJR"		)
TRCell():New( oSection1, "NJR_QTEFCO"	, "NJR" 	)
TRCell():New( oSection1, "NJR_QTSFCO"	, "NJR" 	)
TRCell():New( oSection1, "COLA"			,			, STR0004 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "3", ( QryT1->( NJR_QTEFCO ) - QryT1->( NJR_QTSFCO ) ), ( QryT1->( NJR_QTSFCO ) - QryT1->( NJR_QTEFCO ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fco."
TRCell():New( oSection1, "NJR_QTEFIS"	, "NJR" 	)
TRCell():New( oSection1, "NJR_QTSFIS"	, "NJR" 	)
TRCell():New( oSection1, "COLB"			,			, STR0005 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "3", ( QryT1->( NJR_QTEFIS ) - QryT1->( NJR_QTSFIS ) ), ( QryT1->( NJR_QTSFIS ) - QryT1->( NJR_QTEFIS ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fis."
TRCell():New( oSection1, "NJR_VLEFIS"	, "NJR" 	)
TRCell():New( oSection1, "NJR_VLSFIS"	, "NJR" 	)
TRCell():New( oSection1, "COLC"			,			, STR0006 	, PesqPict('NJR', 'NJR_VLRTOT')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "3", ( QryT1->( NJR_VLEFIS ) - QryT1->( NJR_VLSFIS ) ), ( QryT1->( NJR_VLSFIS ) - QryT1->( NJR_VLEFIS ) ) ) }, "RIGHT", , "RIGHT" ) //"Val. Fis."

oBreak1 := TRBreak():New( oSection1, "", STR0007, .f. ) //"Total dos Contratos -->"

TRFunction():New(oSection1:Cell( "NJR_QTDCTR" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_AUTENT" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_AUTSAI" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_QTEFCO" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_QTSFCO" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "COLA" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_QTEFIS" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_QTSFIS" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "COLB" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_VLEFIS" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "NJR_VLSFIS" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection1:Cell( "COLC" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )

Return( oReport )


Static Function PrintReport( oReport )
Local oS1		:= oReport:Section( 1 )
Local cCtrDe	:= mv_par01
Local cCtrAte	:= mv_par02
Local nTipCtr	:= mv_par03
//Local cFilDe	:= mv_par04
//Local cFilAte	:= mv_par05
Local dDataDe	:= mv_par04
Local dDataAte	:= mv_par05
Local cEntDe	:= mv_par06
Local cEntAte	:= mv_par07

Local cFiltro	:= ""

If oReport:Cancel()
	Return( Nil )
EndIf

//cFiltro += "NJR.NJR_FILIAL >= '" + cFilDe + "' And NJR.NJR_FILIAL <= '" + cFilAte + "' "
cFiltro += " NJR.NJR_CODCTR >= '" + cCtrDe + "' And NJR.NJR_CODCTR <= '" + cCtrAte + "' "
Do Case 
	Case nTipCtr = 1
		cFiltro += "And ( NJR.NJR_TIPO = '3' ) "
	Case nTipCtr = 2
		cFiltro += "And ( NJR.NJR_TIPO = '4' ) "
	Case nTipCtr = 3
		cFiltro += "And ( NJR.NJR_TIPO = '3' Or NJR.NJR_TIPO = '4' ) "
EndCase
cFiltro += "And NJR.NJR_DATA   >= '" + DtoS( dDataDe ) + "' And NJR.NJR_DATA    <= '" + DtoS( dDataAte ) + "' "
cFiltro += "And NJR.NJR_CODENT >= '" + cEntDe          + "' And NJR.NJR_CODENT  <= '" + cEntAte          + "' "
cFiltro := "%" + cFiltro + "%"


//cFiltro += "And NJR.NJR_CODENT || NJR.NJR_LOJENT >= '" + cEntDe + "' And NJR.NJR_CODENT || NJR.NJR_LOJENT <= '" + cEntAte + "' "


oS1:BeginQuery()
	BeginSql Alias "QryT1"
		Select
			NJR.*,
			NJ0.*,
			( NJR.NJR_QTDCTR - ( NJR.NJR_QTEFIS - NJR.NJR_QTSFIS ) ) as NJR_SLEFIS,
			( NJR.NJR_QTDCTR - ( NJR.NJR_QTSFIS - NJR.NJR_QTEFIS ) ) as NJR_SLSFIS,
			( NJR.NJR_VLEFIS - NJR.NJR_VLSFIS ) as NJR_SVEFIS,
			( NJR.NJR_VLSFIS - NJR.NJR_VLEFIS ) as NJR_SVSFIS
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
			//NJR_FILIAL,
			NJR.NJR_CODCTR
	EndSql
oS1:EndQuery()

oS1:Init()

QryT1->( dbGoTop() )
While .Not. QryT1->( Eof( ) )
   
    oS1:Cell("NJR_DESPRO"):SetValue(Posicione('SB1',1,xFilial('SB1')+QryT1->(NJR_CODPRO),'B1_DESC'))
    
	oS1:PrintLine( )

	QryT1->( dbSkip() )
EndDo
oS1:Finish()

Return( )


