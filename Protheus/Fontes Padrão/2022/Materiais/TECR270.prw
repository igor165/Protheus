#Include "Protheus.ch"
#Include "Report.ch"
#Include "TECR270.ch"
Static cAutoPerg := "TECR270"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TECR270   ºAutor  ³Microsiga           º Data ³  12/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de Oportunidade Comercial - Visitas               º±±
±±º          ³			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TECR270()

Local oReport
Local aArea := GetArea()

Private cTitulo := STR0001
Private aOrdem	:= {STR0011} //"Oportunidade"
Private cPerg	:= "TECR270"
Private cQry	:= GetNextAlias()

Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Microsiga           º Data ³  12/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local oReport
Local oSection
Local oBreakEnt

If TYPE("cTitulo") == "U"
	cTitulo := STR0001
EndIf

If TYPE("aOrdem") == "U"
	aOrdem	:= {STR0011} //"Oportunidade"
EndIf

If TYPE("cPerg") == "U"
	cPerg	:= "TECR270"
EndIf

If TYPE("cQry") == "U"
	cQry	:= GetNextAlias()
EndIf
Define Report oReport Name STR0002 Title cTitulo Parameter cPerg Action {|oReport| ReportPrint(oReport)} Description STR0003 //"Este programa emite a Impressão de Relatório de oportunidades com as respectivas visitas."

Define Section oSection Of oReport Title cTitulo Tables "ATT" Total In Column Orders aOrdem

Define Cell Name "AAT_OPORTU" Of oSection Size(10) Alias "AAT" Title STR0013 //"Oport"
Define Cell Name "AAT_CODENT" Of oSection Size(6) Alias "AAT"
Define Cell Name "AAT_LOJENT" Of oSection Size(2) Alias "AAT"
Define Cell Name "AAT_NOMENT" Of oSection Size(40) Alias "AAT" Block {|| FsVerifEnt((cQry)->AAT_ENTIDA)} 
Define Cell Name "AAT_CODABT" Of oSection Size(3) Alias "AAT" Title STR0014 //"Visita"
Define Cell Name STR0012 Of oSection Size(30) Alias "AAT" Block {|| Posicione("ABT",1,xFilial("ABT")+(cQry)->AAT_CODABT,"ABT_DESCRI")} //"Descrição Visita"
Define Cell Name "AAT_VISTOR" Of oSection Size(6) Alias "AAT" Title STR0015 //"Cod.Vist."
Define Cell Name "AAT_NOMVIS" Of oSection Size(30) Alias "AAT" Block {|| Posicione("AA1",1,xFilial("AA1")+(cQry)->AAT_VISTOR,"AA1_NOMTEC") } Title STR0016 //"Nome Vistoriador"
Define Cell Name "AAT_DTINI" Of oSection Alias "AAT" Title STR0017 //"Dt Inicial"  
Define Cell Name "AAT_DTFIM" Of oSection Alias "AAT" Title STR0018 //"Dt Final"
Define Cell Name "AAT_REGIAO" Of oSection Size(13) Alias "AAT" Block {|| Posicione("SX5",1,xFilial("SX5")+"A2"+(cQry)->AAT_REGIAO,"X5_DESCRI")}        

TRPosition():New(oSection,"AAT",2,{|| xFilial("AAT") + AAT->AAT_OPORTU },.T.)  

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Microsiga           º Data ³  12/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local nOrdem    := oReport:Section(1):GetOrder() 
Local cTit		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01        // Oportunidade de		                     ³
//³ mv_par02        // Oportunidade ate		                     ³
//³ mv_par03        // Data de	            		             ³
//³ mv_par04        // Data ate  								 ³
//³ mv_par05		// 1-Clientes, 2-Prospect, 3-Ambos 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cOportDe	 := mv_par01
Local cOportAte	 := mv_par02
Local dDataDe    := mv_par03
Local dDataAte   := mv_par04
Local nEntidade	 := mv_par05 
Local cEnt		 := ''   

If nEntidade == 1
	cEnt := '%1%'
ElseIf nEntidade == 2
	cEnt := '%2%'
Else
	cEnt := '%1 OR AAT.AAT_ENTIDA = 2%'
EndIf 

BEGIN REPORT QUERY oSection1
	
	BeginSQL Alias cQry

		SELECT 	AAT.AAT_OPORTU, AAT.AAT_CODENT, AAT.AAT_LOJENT, AAT.AAT_CODABT,
				AAT.AAT_VISTOR, AAT.AAT_DTINI, AAT.AAT_DTFIM,AAT.AAT_REGIAO, 
				AAT.AAT_ENTIDA, AAT.AAT_FILIAL, AAT.AAT_EMISSA
        FROM 	%Table:AAT% AAT		
		WHERE   AAT.AAT_OPORTU BETWEEN  %Exp:cOportDe%  AND %Exp:cOportAte% 
		   		AND AAT.AAT_EMISSA BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
				AND AAT.AAT_ENTIDA = %Exp:cEnt%
				AND AAT.%notdel%
		Order By AAT.AAT_FILIAL, AAT.AAT_ENTIDA, AAT.AAT_OPORTU, AAT.AAT_CODENT		
	EndSQL    

END REPORT QUERY oSection1  

DBSelectArea(cQry)

                                                                             
Define Break oBreakOpt Of oSection1 When {|| oSection1:Cell("AAT_OPORTU"):GetText()+oSection1:Cell("AAT_CODENT"):GetText()} TITLE STR0010 

Define Function From oSection1:Cell("AAT_CODENT") Function Count Break oBreakOpt  

If !isBlind()
	oSection1:Print()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FSADLIM303ºAutor  ³Microsiga           º Data ³  12/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Nome da Entidade (Cliente ou Prospect)            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FsVerifEnt(cEntid)

Local cNomEnt := ""

DbSelectArea(cQry)


If cEntid == "1"
	cNomEnt := Alltrim( Posicione("SA1",1,xFilial("SA1")+(cQry)->(AAT_CODENT+AAT_LOJENT),"A1_NOME") )
Else
	cNomEnt := Alltrim( Posicione("SUS",1,xFilial("SUS")+(cQry)->(AAT_CODENT+AAT_LOJENT),"US_NOME") )
EndIf

Return (cNomEnt)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Chama a função ReportPrint
Chamada utilizada na automação de código.

@author Mateus Boiani
@since 31/10/2018
@return objeto Report
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport ( oReport )

Private cTitulo := STR0001
Private aOrdem	:= {STR0011} //"Oportunidade"
Private cPerg	:= "TECR270"
Private cQry	:= GetNextAlias()

Return ReportPrint( oReport )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg