#INCLUDE "OGR245.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGR245
Impressão de Ordens de Trânsito

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	22/08/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGR245()

Local aAreaAtu 	:= GetArea()
Local oReport		:= Nil
Private cPergunta	:= "OGR245"

// Se foi chamado do browse de Ordens de Trânsito
If FunName() $ "OGA245"
	cPergunta := ""
EndIf

If TRepInUse()
	
	If !Empty(cPergunta)
		Pergunte( cPergunta, .f. )
	EndIf
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
EndIf

RestArea( aAreaAtu )
Return( Nil )

///////////////////////////////////////////////////////////////////////////////////////

Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oBreak1

oReport := TReport():New("OGR245", STR0001, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002) //"Impressão de Ordens de Trânsito"###"Este relatorio ira imprimir a Ordem de Trânsito selecionada."

oReport:SetTotalInLine( .f. )
oReport:SetPortrait()

oSection1 := TRSection():New( oReport, STR0004, { "NK2" } ) //"Ordem de Trânsito"
TRCell():New( oSection1, "NK2_CODIGO"	, "NK2" 	, 	, 	, TamSX3("NK2_CODIGO")[1] )
TRCell():New( oSection1, "NK2_DATINC"	, "NK2" 	, 	, 	, TamSX3("NK2_DATINC")[1] )
TRCell():New( oSection1, "NK2_CODSAF"	, "NK2" 	, 	, 	, TamSX3("NK2_CODSAF")[1] )
TRCell():New( oSection1, "NK2_CODMOT"	, "NK2" 	, 	, 	, TamSX3("NK2_CODMOT")[1] )
TRCell():New( oSection1, "NK2_NOMMOT"	, "NK2" 	, 	, 	, TamSX3("NK2_NOMMOT")[1] )
TRCell():New( oSection1, "NK2_PLACA"	, "NK2" 	, 	, 	, TamSX3("NK2_PLACA")[1] )

oSection2 := TRSection():New( oReport, STR0004, { "NK2" } ) //"Ordem de Trânsito"
TRCell():New( oSection2, "NK2_CODTRA"	, "NK2" 	, 	, 	, TamSX3("NK2_CODTRA")[1] )
TRCell():New( oSection2, "NK2_NOMTRA"	, "NK2" 	, 	, 	, TamSX3("NK2_NOMTRA")[1] )
TRCell():New( oSection2, "NK2_OBS"		, "NK2" 	, 	, 	, TamSX3("NK2_OBS")[1] )

oSection3 := TRSection():New( oReport, STR0005, { "NJ0" } ) //"Dados do Produtor"
TRCell():New( oSection3, "NJ0_CODENT"	, "NJ0" 	, 	, 	, TamSX3("NJ0_CODENT")[1] )
TRCell():New( oSection3, "NJ0_LOJENT"	, "NJ0" 	, 	, 	, TamSX3("NJ0_LOJENT")[1] )
TRCell():New( oSection3, "NJ0_NOME"	, "NJ0" 	, 	, 	, TamSX3("NJ0_NOME")[1] )
TRCell():New( oSection3, "NJ0_NOMLOJ"	, "NJ0" 	, 	, 	, TamSX3("NJ0_NOMLOJ")[1] )

oSection4 := TRSection():New( oReport, STR0006, { "NK3" } ) //"Itens da Ordem de Trânsito"
//TRCell():New( oSection4, "NK3_CODIGO"	, "NK3" 	, 	, 	, TamSX3("NK3_CODIGO")[1] )
TRCell():New( oSection4, "NK3_ITEM"	, "NK3" 	, 	, 	, TamSX3("NK3_ITEM")[1] )
TRCell():New( oSection4, "NK3_CODPRO"	, "NK3" 	, 	, 	, TamSX3("NK3_CODPRO")[1] )
TRCell():New( oSection4, "NK3_DESPRO"	, "NK3" 	, 	, 	, TamSX3("NK3_DESPRO")[1] )
TRCell():New( oSection4, "NK3_UM1PRO"	, "NK3" 	, 	, 	, TamSX3("NK3_UM1PRO")[1] )
TRCell():New( oSection4, "NK3_QUANT"	, "NK3" 	, 	, 	, TamSX3("NK3_QUANT")[1] )
TRCell():New( oSection4, "NK3_PRECO"	, "NK3" 	, 	, 	, TamSX3("NK3_PRECO")[1] )
TRCell():New( oSection4, "NK3_TOTAL"	, "NK3" 	, 	, 	, TamSX3("NK3_TOTAL")[1] )

oBreak1 := TRBreak():New( oSection4, "NK3_CODIGO", STR0007, .f. )//"Total -->"
TRFunction():New(oSection4:Cell("NK3_ITEM")	, Nil, "COUNT"	, oBreak1, , , , .f., .f. )
TRFunction():New(oSection4:Cell("NK3_QUANT")	, Nil, "SUM"		, oBreak1, , , , .f., .f. )
TRFunction():New(oSection4:Cell("NK3_TOTAL")	, Nil, "SUM"		, oBreak1, , , , .f., .f. )

Return( oReport )

///////////////////////////////////////////////////////////////////////////////////////

Static Function PrintReport( oReport )

Local aAreaAtu	:= GetArea()
Local oS1			:= oReport:Section( 1 ) 
Local oS2			:= oReport:Section( 2 ) 
Local oS3			:= oReport:Section( 3 ) 
Local oS4			:= oReport:Section( 4 ) 
Local nRegNK2 	:= NK2->( Recno() )
Local cCodigo		:= Space(TamSX3("NK2_CODIGO")[1])

// Posiciona na tabela de Ordens de Trânsito
oReport:PrintText( STR0004 ) //"Ordem de Trânsito"
oReport:FatLine()
oS1:Init()
oS2:Init()
dbSelectArea( "NK2" )
NK2->(dbSetOrder( 1 ) )
If Empty(cPergunta) // Se cPergunta estiver vazio, significa que está sendo chamado do browse OGA245
	NK2->(dbGoto( nRegNK2 ) )
	cCodigo := NK2->( NK2_CODIGO )
Else
	cCodigo := MV_PAR01	
	NK2->(dbSeek( xFilial("NK2") + cCodigo ) )
EndIf
oS1:Cell("NK2_NOMMOT"):SetValue(POSICIONE('DA4',1,XFILIAL('DA4')+NK2->( NK2->NK2_CODMOT ),'DA4_NOME'))
oS1:PrintLine()
oS2:Cell("NK2_NOMTRA"):SetValue(POSICIONE('SA4',1,XFILIAL('SA4')+NK2->( NK2->NK2_CODTRA ),'A4_NOME'))
oS2:PrintLine()
oS2:Finish()
oS1:Finish()

// Posiciona na tabela de Entidades
oReport:PrintText( " " ) 
oReport:PrintText( STR0005 ) //"Dados do Produtor"
oReport:ThinLine()
oS3:Init()
DbSelectArea( "NJ0" )
NJ0->( dbSetOrder( 1 ) )
NJ0->( dbSeek( xFilial( "NJ0" ) + NK2->( NK2_CODENT + NK2_LOJENT ) ) )
oS3:PrintLine()
oS3:Finish()

// Imprime os itens da Ordem de Transito 
oReport:PrintText( " " ) 
oReport:FatLine()
oReport:PrintText( STR0006 ) //"Itens da Ordem de Trânsito"
oReport:FatLine()
oS4:Init()
dbSelectArea( "NK3" )
NK3->( dbSetOrder( 1 ) )
NK3->( dbSeek( xFilial( "NK3" ) + cCodigo ) )
While !( Eof() ) .And. NK3->( NK3_FILIAL ) + NK3->( NK3_CODIGO ) == xFilial( "NK3" ) + cCodigo
    oS4:Cell("NK3_DESPRO"):SetValue(POSICIONE('SB1',1,XFILIAL('SB1')+NK3->( NK3->NK3_CODPRO ),'B1_DESC'))
	oS4:PrintLine()
	NK3->( dbSkip() )	
EndDo
oS4:Finish()

RestArea(aAreaAtu)

Return( )
