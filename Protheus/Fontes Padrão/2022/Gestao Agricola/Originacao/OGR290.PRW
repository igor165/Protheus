#INCLUDE "OGR290.ch"
#include "protheus.ch"

/** {Protheus.doc} OGR290
Relatório de Contratos Compra/Vendas

@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	22/04/2013
@Uso: 		SIGAAGR - Originação de Grãos     
*/
 
Function OGR290()
Local aAreaAtu 	:= GetArea()
Local oReport		:= Nil
Private cPergunta	:= "OGR290001"

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

oReport := TReport():New("OGR290", STR0001, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002) //"Relatório de Contratos"###"Este relatório tem como objetivo imprimir os dados dos contratos de venda conforme os paramêtros informados."

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
TRCell():New( oSection1, "NJR_QTSFCO"	, "NJR"		, , , 20)
TRCell():New( oSection1, "COLA"			,			, STR0005 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "1", ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTEFIS ) - QryT1->( NJR_QTSFIS ) ) ), ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTSFIS ) - QryT1->( NJR_QTEFIS ) ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fis."
TRCell():New( oSection1, "COLB"			,			, STR0006 	, PesqPict('NJR', 'NJR_QTDCTR')	, 20, , { | x | x := IIf( QryT1->( NJR_TIPO ) = "1", ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTEFCO ) - QryT1->( NJR_QTSFCO ) ) ), ( QryT1->( NJR_QTDCTR ) - ( QryT1->( NJR_QTSFCO ) - QryT1->( NJR_QTEFCO ) ) ) ) }, "RIGHT", , "RIGHT" ) //"Sld. Fco."

//Fiscal
TRCell():New( oSection1, "NJR_VLRUNI"	, "NJR" 	, , , 25)
TRCell():New( oSection1, "NJR_VLRTOT"	, "NJR" 	, , , 25)
TRCell():New( oSection1, "NJR_VLEFIS"	, "NJR"		, , , 25)
TRCell():New( oSection1, "NJR_VLSFIS"	, "NJR"		, , , 25)

TRCell():New( oSection1, "COLC"			,			, STR0007 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , { | x | x := BuscaVLR()  }, "RIGHT", , "RIGHT" ) //"Val. Liq."
TRCell():New( oSection1, "COLD"			,			, STR0008 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , { | x | x := BuscaVLRD() }, "RIGHT", , "RIGHT" ) //"Val. Liq. Dev."

//Financeiro
TRCell():New( oSection1, "COLE"			,			, STR0009 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF Recebido"
TRCell():New( oSection1, "COLF"			,			, STR0010 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF A Receber"
TRCell():New( oSection1, "COLG"			,			, STR0011 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"NF p/ Fatura"

TRCell():New( oSection1, "COLH"			,			, STR0012 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"FT Recebido"
TRCell():New( oSection1, "COLI"			,			, STR0013 	, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"FT A Receber"

TRCell():New( oSection1, "COLJ"			,			, STR0014 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Devolvido"
TRCell():New( oSection1, "COLK"			,			, STR0015 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Adiantado"

TRCell():New( oSection1, "COLL"			,			, STR0016 , PesqPict('NJR', 'NJR_VLRTOT') , 25, , , "RIGHT", , "RIGHT" ) //"A Rec. s/ Fat."
TRCell():New( oSection1, "COLM"			,			, STR0017 , PesqPict('NJR', 'NJR_VLRTOT') , 25, , , "RIGHT", , "RIGHT" ) //"A Rec. s/ Ctr."

//Posicao de Carteiras
TRCell():New( oSection1, "COLN"			,			, STR0018 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Carteira"
TRCell():New( oSection1, "COLO"			,			, STR0019 		, PesqPict('NJR', 'NJR_VLRTOT')	, 25, , , "RIGHT", , "RIGHT" ) //"Bordero"



oBreak1 := TRBreak():New( oSection1, "", STR0020, .f. ) //"Total dos Contratos -->"

TRFunction():New(oSection1:Cell( "NJR_QTDCTR" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )


Return( oReport )


Static Function PrintReport( oReport )
Local oS1		:= oReport:Section( 1 )
//Local cFilDe	:= mv_par01
//Local cFilAte	:= mv_par02
Local cCtrDe	:= mv_par01
Local cCtrAte	:= mv_par02
Local dDataDe	:= mv_par03
Local dDataAte	:= mv_par04
Local cEntDe	:= mv_par05
Local cLojDe	:= mv_par06
Local cEntAte	:= mv_par07
Local cLojAte	:= mv_par08

Local cFilNJ0	:= Space( FwSizeFilial() )

Local cFiltro	:= ""

If oReport:Cancel()
	Return( Nil )
EndIf

//cFiltro += "NJR.NJR_FILIAL >= '" + cFilDe + "' And NJR.NJR_FILIAL <= '" + cFilAte + "' "
cFiltro += "NJR.NJR_CODCTR >= '" + cCtrDe + "' And NJR.NJR_CODCTR <= '" + cCtrAte + "' "
cFiltro += "And NJR.NJR_TIPO = '2' "
cFiltro += "And NJR.NJR_DATA >= '" + DtoS( dDataDe ) + "' And NJR.NJR_DATA <= '" + DtoS( dDataAte ) + "' "
cFiltro += "And NJR.NJR_CODENT >= '" + cEntDe + "' And NJR.NJR_CODENT <= '" + cEntAte + "' "
cFiltro += "And NJR.NJR_LOJENT >= '" + cLojDe + "' And NJR.NJR_LOJENT <= '" + cLojAte + "' "

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
			NJR.%notDel%  And
			NJ0.%notDel%
		Order By
			NJR_FILIAL,
			NJR.NJR_CODCTR
	EndSql
oS1:EndQuery()

oS1:Init()

QryT1->( dbGoTop() )
While .Not. QryT1->( Eof( ) )

	aValores := BuscaCR()

    oS1:Cell( "NJR_DESPRO" ):SetValue(  POSICIONE("SB1", 1, xFilial("SB1") + QryT1->NJR_CODPRO,"B1_DESC") )           
	oS1:Cell( "COLE" ):SetValue( aValores[2] )
	oS1:Cell( "COLF" ):SetValue( aValores[3] )
	oS1:Cell( "COLG" ):SetValue( aValores[4] )
	oS1:Cell( "COLH" ):SetValue( aValores[5] )
	oS1:Cell( "COLI" ):SetValue( aValores[6] )
	oS1:Cell( "COLJ" ):SetValue( aValores[8] )
	oS1:Cell( "COLK" ):SetValue( aValores[9] )

	oS1:Cell( "COLN" ):SetValue( aValores[10] )
	oS1:Cell( "COLO" ):SetValue( aValores[11] )

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


/** {Protheus.doc} BuscaCR
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	10/05/2004
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function BuscaCR( )
Local aRetorno	:= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

Local nNFTotal	:= 0
Local nNFPaga	:= 0
Local nNFAPagar	:= 0

Local nFTTotal	:= 0
Local nFTPaga	:= 0
Local nFTAPagar	:= 0

Local nDevTot	:= 0
Local nDevSld	:= 0

Local nAdtoSld	:= 0

Local nValCar	:= 0
Local nValBor	:= 0
Local cFiltroCtr := " "
Local cInnerN8L := " "

//proteção de versão.
If GetRpoRelease() < "12.1.023" //Versão menor que a 23
	//filtra usando o contrato da SE1
	cFiltroCtr := " SE1.E1_CTROG  = '"+QryT1->( NJR_CODCTR )+"' "
Else
	//inclui o inner join da tabela N8L as querys
	cInnerN8L  := "INNER JOIN "  + RetSqlName("N8L") + " N8L "+;
	"	ON  N8L.N8L_FILIAL 	= SE1.E1_FILIAL "+;
	"	AND N8L.N8L_PREFIX 	= SE1.E1_PREFIXO "+;
	"	AND N8L.N8L_NUM	   	= SE1.E1_NUM "+;
	"	AND N8L.N8L_PARCEL 	= SE1.E1_PARCELA "+;
	"	AND N8L.N8L_TIPO	= SE1.E1_TIPO "+;
	"	AND N8L.D_E_L_E_T_ = ' '	 "

	//filta usando o contrato da N8L.
	cFiltroCtr := " N8L.N8L_CODCTR = '"+QryT1->( NJR_CODCTR )+"' "
EndIf

//tratamento para incluir no embedded sql.
cFiltroCtr := "%"+cFiltroCtr+"%"
cInnerN8L  := "%"+cInnerN8L+"%" 

/**
 * Obtem valor dos faturamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_VALOR ) as E1VALOR,
		Sum( SE1.E1_SALDO ) as E1SALDO
	From
		%table:SE1% SE1	
		%Exp:cInnerN8L%
	Where	
		SE1.E1_FILIAL 	= %Exp:QryT1->( NJR_FILIAL )% And 
		%Exp:cFiltroCtr% And
		SE1.E1_TIPO   	= 'NF' And
		SE1.E1_FATURA 	= ' '  And
		SE1.E1_NUMLIQ 	= ' '  And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nNFTotal	:= QryT2->( E1VALOR )
	nNFPaga 	:= QryT2->( E1VALOR ) - QryT2->( E1SALDO )
	nNFAPagar 	:= QryT2->( E1SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos faturamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_VALOR ) as E1VALOR,
		Sum( SE1.E1_SALDO ) as E1SALDO
	From
		%table:SE1% SE1
	Where
		SE1.E1_FILIAL  = %Exp:QryT1->( NJR_FILIAL )% And
		SE1.E1_NUM     = %Exp:QryT1->( NJR_CODCTR )% And
		SE1.E1_PREFIXO = 'OR' And
		SE1.E1_TIPO    Like 'FT%' And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nFTTotal	:= QryT2->( E1VALOR )
	nFTPaga 	:= QryT2->( E1VALOR ) - QryT2->( E1SALDO )
	nFTAPagar 	:= QryT2->( E1SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos adiantamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_VALOR ) as E1VALOR,
		Sum( SE1.E1_SALDO ) as E1SALDO
	From
		%table:SE1% SE1
		%Exp:cInnerN8L%	
	Where
		SE1.E1_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		%Exp:cFiltroCtr% And
		SE1.E1_TIPO   = 'NCC' And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nDevTot := QryT2->( E1VALOR )
	nDevSld := QryT2->( E1SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos adiantamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_SALDO ) as E1SALDO
	From
		%table:SE1% SE1
	Where
		SE1.E1_FILIAL  = %Exp:QryT1->( NJR_FILIAL )% And
		SE1.E1_NUM     = %Exp:QryT1->( NJR_CODCTR )% And
		SE1.E1_PREFIXO = 'ORA' And
		SE1.E1_TIPO    = 'RA'  And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nAdtoSld := QryT2->( E1SALDO )
EndIf
QryT2->( dbCloseArea() )


/**
 * Obtem valor dos faturamentos e saldos dos mesmos
 */
BeginSql Alias "QryT2"
	Select
		SE1.E1_SITUACA,
		Sum( SE1.E1_SALDO ) as E1SALDO
	From
		%table:SE1% SE1		
		%Exp:cInnerN8L%		
	Where
		SE1.E1_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		%Exp:cFiltroCtr% And
		SE1.E1_TIPO   = 'NF' And
		SE1.E1_FATURA = ' '  And
		SE1.E1_NUMLIQ = ' '  And
		SE1.%NotDel%
	Group By
		SE1.E1_SITUACA
	Order By
		SE1.E1_SITUACA
EndSql
If .Not. QryT2->( Eof() )
	While .Not. QryT2->( Eof() )

		If QryT2->( E1_SITUACA ) = "0"
			nValCar += QryT2->( E1SALDO )
		Else
			nValBor += QryT2->( E1SALDO )
		EndIf

		QryT2->( dbSkip() )
	EndDo
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

aRetorno[ 10 ] := nValCar
aRetorno[ 11 ] := nValBor

Return( aRetorno )


/** {Protheus.doc} BuscaLQP
Ajusta dicionário de perguntas.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	10/05/2004
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function BuscaVLR( )
Local nRetorno	:= 0

BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_VALOR ) as E1VALLIQ
	From
		%table:NJM% NJM,
		%table:NJJ% NJJ,
		%table:NJ0% NJ0,
		%table:SF2% SF2,
		%table:SE1% SE1
	Where

		NJJ.NJJ_TIPO   = '4'            And    // (S) Saida por Venda
		NJM.NJM_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		NJM.NJM_FILIAL = NJJ.NJJ_FILIAL And
		NJM.NJM_CODROM = NJJ.NJJ_CODROM And
		NJM.NJM_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		NJ0.NJ0_CODENT = NJM.NJM_CODENT And
		SF2.F2_FILIAL  = NJJ.NJJ_FILIAL And
		SF2.F2_DOC     = NJM.NJM_DOCNUM And
		SF2.F2_SERIE   = NJJ.NJJ_DOCSER And
		SF2.F2_CLIENTE = NJ0.NJ0_CODCLI And
		SF2.F2_LOJA    = NJ0.NJ0_LOJCLI And
		SE1.E1_PREFIXO = SF2.F2_SERIE   And
		SE1.E1_NUM     = SF2.F2_DOC     And
		SE1.E1_CLIENTE = SF2.F2_CLIENTE And
		SE1.E1_LOJA    = SF2.F2_LOJA    And
		NJM.%NotDel% And
		NJJ.%NotDel% And
		NJ0.%NotDel% And
		SF2.%NotDel% And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nRetorno += QryT2->( E1VALLIQ )
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
Static Function BuscaVLRD( )
Local nRetorno	:= 0

BeginSql Alias "QryT2"
	Select
		Sum( SE1.E1_VALOR ) as E1VALLIQ
	From
		%table:NJM% NJM,
		%table:NJJ% NJJ,
		%table:NJ0% NJ0,
		%table:SF1% SF1,
		%table:SE1% SE1
	Where

                NJJ.NJJ_TIPO   = '9'            And // (E) Devolucao por Venda
		NJM.NJM_FILIAL = %Exp:QryT1->( NJR_FILIAL )% And
		NJM.NJM_FILIAL = NJJ.NJJ_FILIAL And
		NJM.NJM_CODROM = NJJ.NJJ_CODROM And
		NJM.NJM_CODCTR = %Exp:QryT1->( NJR_CODCTR )% And
		NJ0.NJ0_CODENT = NJM.NJM_CODENT And
		NJ0.NJ0_LOJENT = NJM.NJM_LOJENT And
		SF1.F1_FILIAL  = NJJ.NJJ_FILIAL And
		SF1.F1_DOC     = NJM.NJM_DOCNUM And
		SF1.F1_SERIE   = NJM.NJM_DOCSER And
		SF1.F1_FORNECE = NJ0.NJ0_CODFOR And
		SF1.F1_LOJA    = NJ0.NJ0_LOJFOR And
		SE1.E1_PREFIXO = SF1.F1_SERIE   And
		SE1.E1_NUM     = SF1.F1_DOC     And
		SE1.E1_CLIENTE = SF1.F1_FORNECE And
		SE1.E1_LOJA    = SF1.F1_LOJA    And
		NJM.%NotDel% And 
		NJJ.%NotDel% And
		NJ0.%NotDel% And
		SF1.%NotDel% And
		SE1.%NotDel%
EndSql
If .Not. QryT2->( Eof() )
	nRetorno += QryT2->( E1VALLIQ )
EndIf
QryT2->( dbCloseArea() )

Return( nRetorno )

