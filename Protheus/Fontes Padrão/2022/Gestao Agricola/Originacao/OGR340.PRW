#include "protheus.ch"

/** {Protheus.doc} OGR340
Impressão de Contratos
Compra, Venda, Deposito de 3 e Deposito em 3.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	02/03/2014
@Uso: 		SIGAAGR - Originação de Grãos
@Manutenção: Vinicius Becher Pagung 12/11/14
*/

Function OGR340()
Local aAreaAtu 	:= GetArea()
Local oReport		:= Nil

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

RestArea( aAreaAtu )
Return( Nil )


Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4

oReport := TReport():New("OGR340", "Impressão de Contratos","", {| oReport | PrintReport( oReport ) }, "Este relatorio ira imprimir o Contrato selecionado na lista.")

oReport:SetTotalInLine( .f. )
oReport:SetLandScape()

oSection1 := TRSection():New( oReport, "Contratos", { "NJR" } )
TRCell():New( oSection1, "NJR_CODCTR"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_DATA"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_DESCRI"	, "NJR" 	, 	, 	, 45 )
TRCell():New( oSection1, "NJR_CODENT"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_LOJENT"	, "NJR" 	, 	, 	, 4 )
TRCell():New( oSection1, "NJR_NOMENT"	, "NJR" 	, 	, 	, 25 )

//// Marlon: Comentado em 19/03/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//TRCell():New( oSection1, "NJ0UF"		,			, "Uf.Ent" 		, PesqPict('NJ0', 'NJ0_EST')	, 15, , , "LEFT", , "LEFT" )
//TRCell():New( oSection1, "NJ0MUNIC"	,			, "Munic.Ent" 	, PesqPict('NJ0', 'NJ0_MUNIC')	, 25, , , "LEFT", , "LEFT" )
TRCell():New( oSection1, "NJR_CODPRO"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_DESPRO"	, "NJR" 	, 	, 	, 25 )
TRCell():New( oSection1, "NJR_CODSAF"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_QTDINI"	, "NJR" 	, 	, 	, 25 )
TRCell():New( oSection1, "NJR_QTDCTR"	, "NJR" 	, 	, 	, 25 )
TRCell():New( oSection1, "NJR_VLRBAS"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_VLRUNI"	, "NJR" 	, 	, 	, 15 )
TRCell():New( oSection1, "NJR_VLRTOT"	, "NJR" 	, 	, 	, 25 )

oSection2 := TRSection():New( oReport, "Previsoes Financeiras", { "NN7" } )
TRCell():New( oSection2, "NN7_DTVENC"	, "NN7" 	, 	, 	, TamSX3("NN7_DTVENC")[1] )
TRCell():New( oSection2, "NN7_VALOR"	, "NN7" 	, 	, 	, TamSX3("NN7_VALOR")[1] )
TRCell():New( oSection2, "NN7_CODBCO"	, "NN7" 	, 	, 	, TamSX3("NN7_CODBCO")[1] )
TRCell():New( oSection2, "NN7_CODAGE"	, "NN7" 	, 	, 	, TamSX3("NN7_CODAGE")[1] )
TRCell():New( oSection2, "NN7_DVAGE"	, "NN7" 	, 	, 	, TamSX3("NN7_DVAGE")[1] )
TRCell():New( oSection2, "NN7_CODCTA"	, "NN7" 	, 	, 	, TamSX3("NN7_CODCTA")[1] )
TRCell():New( oSection2, "NN7_DVCTA"	, "NN7" 	, 	, 	, TamSX3("NN7_DVCTA")[1] )
TRCell():New( oSection2, "NN7_NOMFAV"	, "NN7" 	, 	, 	, TamSX3("NN7_NOMFAV")[1] )

oSection3 := TRSection():New( oReport, "Cadência", { "NNY, NJ0" } )
TRCell():New( oSection3, "NNY_DATINI"	, "NNY" 	, 	, 	, TamSX3("NNY_DATINI")[1] )
TRCell():New( oSection3, "NNY_DATFIM"	, "NNY" 	, 	, 	, TamSX3("NNY_DATFIM")[1] )
TRCell():New( oSection3, "NNY_QTDINT"	, "NNY" 	, 	, 	, TamSX3("NNY_QTDINT")[1] )
TRCell():New( oSection3, "COLA"			,			, "Origem" 	, PesqPict('NJ0', 'NJ0_NOMLOJ')	, TamSX3("NJ0_NOMLOJ")[1], , , "LEFT", , "LEFT" )
//// Marlon: Comentado em 26/02/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//TRCell():New( oSection3, "COLB"			,			, "Uf.Orig" 	, PesqPict('NJ0', 'NJ0_EST')	, TamSX3("NJ0_EST")[1], , , "LEFT", , "LEFT" )
TRCell():New( oSection3, "COLC"			,			, "Destino" 	, PesqPict('NJ0', 'NJ0_NOMLOJ')	, TamSX3("NJ0_NOMLOJ")[1], , , "LEFT", , "LEFT" )
//TRCell():New( oSection3, "COLD"			,			, "Uf.Dest" 	, PesqPict('NJ0', 'NJ0_EST')	, TamSX3("NJ0_EST")[1], , , "LEFT", , "LEFT" )

//TRCell():New( oSection3, "NNY_LOCORI"	, "NNY" 	, 	, 	, TamSX3("NJ0_NOME")[1] )
//TRCell():New( oSection3, "NNY_LOCDES"	, "NNY" 	, 	, 	, TamSX3("NJ0_NOME")[1] )

oSection4 := TRSection():New( oReport, "Corretoras", { "NNF, NJM" } )
TRCell():New( oSection4, "NNF_CODENT"	, "NNF" 	, 	, 	, TamSX3("NNF_CODENT")[1] )
TRCell():New( oSection4, "NJM_LOJENT"	, "NJM" 	, 	, 	, TamSX3("NJM_LOJENT")[1] )
TRCell():New( oSection4, "NNF_NOMENT"	, "NNF" 	, 	, 	, TamSX3("NNF_NOMENT")[1] )
TRCell():New( oSection4, "NNF_CODENT"	, "NNF" 	, 	, 	, TamSX3("NNF_CODENT")[1] )
TRCell():New( oSection4, "NNF_VLBCOM"	, "NNF" 	, 	, 	, TamSX3("NNF_VLBCOM")[1] )
TRCell():New( oSection4, "NNF_PCBCOM"	, "NNF" 	, 	, 	, TamSX3("NNF_PCBCOM")[1] )

//oBreak1 := TRBreak():New( oSection1, "", "Total de Cargas-->", .f. )
//
//TRFunction():New(oSection1:Cell("NJI_QTDFIS")	, Nil, "SUM"		, oBreak1, , , , .f., .f. )
//TRFunction():New(oSection1:Cell("NJI_VLRTOT")	, Nil, "SUM"		, oBreak1, , , , .f., .f. )
//TRFunction():New(oSection1:Cell("NJI_QTDFCO")	, Nil, "SUM"		, oBreak1, , , , .f., .f. )

Return( oReport )

Static Function PrintReport( oReport )
Local aAreaAtu		:= GetArea()
Local oS1			:= oReport:Section( 1 ) 
Local oS2			:= oReport:Section( 2 ) 
Local oS3			:= oReport:Section( 3 ) 
Local oS4			:= oReport:Section( 4 ) 
Local nRegAnt 		:= NJR->( Recno() )
Local cLocOrig		:= ""
Local cLocDest		:= ""

oS1:Init()
oS2:Init()
oS3:Init()
oS4:Init()

dbSelectArea( "NJR" )
NJR->(dbSetOrder( 1 ) )
NJR->(dbGoto( nRegAnt ) )

//// Marlon: Comentado em 26/02/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//cUfEnt	:= Posicione( "NJ0", 1, xFilial( "NJ0" ) + NJR->( NJR_CODENT ) + NJR->( NJR_LOJENT ), "NJ0_EST" )
//cMunic 	:= Posicione( "NJ0", 1, xFilial( "NJ0" ) + NJR->( NJR_CODENT ) + NJR->( NJR_LOJENT ), "NJ0_MUNIC" )

//oS1:Cell( "NJ0UF" ):SetValue( cUfEnt )
//oS1:Cell( "NJ0MUNIC" ):SetValue( cMunic  )


oS1:PrintLine()
	
dbSelectArea( "NN7" )
NN7->(dbSetOrder( 1 ) )
dbGoTop()
While .Not. Eof() .And. ( NJR->(NJR_FILIAL ) == FWxFilial( "NJR" ) )
	If ( NJR->( NJR_CODCTR  )  == NN7->( NN7_CODCTR ) )
		oS2:PrintLine()
	EndIf
	NN7->( dbSkip() )	
EndDo

dbSelectArea( "NNY" )
NNY->(dbSetorder( 1 ) )
dbGoTop()
While .Not. Eof() .And. ( NJR->(NJR_FILIAL ) == FWxFilial( "NJR" ) )
	If ( NJR->( NJR_CODCTR  )  == NNY->( NNY_CODCTR ) )
		cLocOrig := Posicione( "NJ0", 1, xFilial( "NJ0" ) + NNY->( NNY_LOJORI ), "NJ0_NOMLOJ" )
//// Marlon: Comentado em 26/02/15 para ser revisto e buscar os campos da SA1 ou SA2 se houver necessidade ////
//		cUFOrig  := Posicione( "NJ0", 1, xFilial( "NJ0" ) + NNY->( NNY_LOJORI ), "NJ0_EST" )
		cLocDest := Posicione( "NJ0", 1, xFilial( "NJ0" ) + NNY->( NNY_ENTDES ), "NJ0_NOMLOJ" )
//		cUFDest  := Posicione( "NJ0", 1, xFilial( "NJ0" ) + NNY->( NNY_ENTDES ), "NJ0_EST" )
		
		oS3:Cell( "COLA" ):SetValue( cLocOrig )
//		oS3:Cell( "COLB" ):SetValue( cUFOrig  )
		oS3:Cell( "COLC" ):SetValue( cLocDest )
//		oS3:Cell( "COLD" ):SetValue( cUFDest  )
		oS3:PrintLine()
	Endif
	NNY->( dbSkip() )
EndDo

dbSelectArea( "NNF" )
NNF->(dbSetorder( 1 ) )
dbGoTop()
While .Not. Eof() .And. ( NJR->(NJR_FILIAL ) == FWxFilial( "NJR" ) )
	If ( NJR->( NJR_CODCTR  )  == NNF->( NNF_CODCTR ) )
		oS4:PrintLine()
	EndIf
	NNF->( dbSkip() )
EndDo

oS4:Finish()
oS3:Finish()
oS2:Finish()
oS1:Finish()


RestArea(aAreaAtu)

Return( )
