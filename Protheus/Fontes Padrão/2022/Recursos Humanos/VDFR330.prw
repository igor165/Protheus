#INCLUDE "VDFR330.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFR330
Relatório de Estagiários Ativos
@sample 	VDFR330()
@author	    Wagner Mobile Costa
@since		27/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFR330()

Local aRegs := {}

Private oReport
Private cString		:= "SRA"
Private cPerg		:= "VDFR330"
Private cTitulo		:= STR0001 //'Relatório de Estagiários Ativos'
Private nSeq		:= 0
Private cAliasQRY	:= ""

	Pergunte(cPerg, .F.)

	M->QB_COMARC := ""	// Variavel para controle da numeração

	oReport := ReportDef()
	oReport:PrintDialog()

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Montagem das definições do relatório
@sample 	ReportDef()
@author	    Wagner Mobile Costa
@since		27/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportDef()

Local cDescri := STR0002 //"Relatório de Estagiários Ativos em ordem alfabética por Lotação"

oReport := TReport():New(	cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
oReport:nFontBody := 7

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
														 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
														 oReport:Section(1):Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""
oFilial:nLinesBefore   := 1
oFilial:bOnPrintLine := { || (oReport:SkipLine()) }  

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oComarcas := TRSection():New(oFilial, STR0004, { "REC" }) //'Comarcas'
oComarcas:SetLineStyle()
oComarcas:cCharSeparator := ""
oComarcas:nLinesBefore   := 0
oComarcas:bOnPrintLine := { || (oReport:SkipLine(), oReport:PrintText(STR0013 + ": " + (cAliasQry)->(QB_COMARC + ' - ' + REC_NOME)), .F.) }  //'Comarca'

TRCell():New(oComarcas,"QB_COMARC","SQB")
TRCell():New(oComarcas, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (	If(M->QB_COMARC <> (cAliasQry)->(RA_FILIAL + QB_COMARC), nSeq := 0, Nil),;
																	(cAliasQry)->(REC_NOME)) } )

oFunc := TRSection():New(oComarcas, STR0005, ( "SRA","SQB" )) //'Servidores'
oFunc:nLinesBefore   := 0

nSeq := 0
TRCell():New(oFunc,	"","",'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || (M->QB_COMARC := (cAliasQry)->(RA_FILIAL + QB_COMARC), AllTrim(Str(++ nSeq))) } ) //Para incluir o número(sequencial) na linha de impressão
TRCell():New(oFunc,"RA_MAT","SRA",STR0006,,10) //'Matrícula'
TRCell():New(oFunc,"RA_NOME","SRA",STR0007,, 45) //'Nome'
TRCell():New(oFunc,"QB_DESCRIC","SQB",STR0008,,45) //Lotação atual do servidor //'Lotação'
TRCell():New(oFunc,"RA_ADMISSA","SRA",STR0009 + Chr(13) + Chr(10) + STR0010) //Data de Admissão //'Data do'###'Credenciamento'
TRCell():New(oFunc,"RA_ADMISSA","SRA",STR0011 + Chr(13) + Chr(10) + STR0012, ,, /*lPixel*/,/*bBlock*/ { || (cAliasQRY)->(RA_ADMISSA) + 730 } ) //Para incluir o número(sequencial) na linha de impressão //'Data Final'###'do Estágio'

Return(oReport)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do conteúdo do relatório
@sample 	ReportPrint(oReport)
@author	    Wagner Mobile Costa
@since		27/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oFilial  := oReport:Section(1), oComarca := oReport:Section(1):Section(1), oFunc := oReport:Section(1):Section(1):Section(1)
Local oBreakComarc
Local cSQBJoin := fTbJoinSQL("SQB", "SRA","%")
Local cRECJoin := fTbJoinSQL("REC", "SQB","%")

cAliasQRY := GetNextAlias()
cWhere    := "%SRA.RA_CATFUNC IN ('E','G') AND SRA.RA_DEMISSA = ' '"		// E=Estagiário Mensalista e G=Estagiário Horista

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cMV_PAR := ""
if !empty(MV_PAR01)		//-- Filial
	cMV_PAR += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cMV_PAR += " AND " + MV_PAR02
EndIf
if !empty(MV_PAR03)		//-- Departamento/Lotação
	cMV_PAR += " AND " + MV_PAR03
EndIf
cMV_PAR += "%"

cWhere += cMV_PAR

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	COLUMN RA_ADMISSA as DATE

	SELECT SQB.QB_COMARC, REC.REC_NOME, SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQB.QB_DESCRIC, SRA.RA_ADMISSA
	  FROM %table:SRA% SRA
	  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cSQBJoin% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	  JOIN %table:REC% REC ON REC.%notDel% AND %Exp:cRECJoin% AND REC.REC_CODIGO = SQB.QB_COMARC
     WHERE SRA.%notDel% AND %Exp:cWhere% 
  ORDER BY SRA.RA_FILIAL, SQB.QB_COMARC, SRA.RA_NOME
EndSql
oFilial:EndQuery()

oComarca:SetParentQuery()
oComarca:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQRY)->(RA_FILIAL + QB_COMARC) == cParam}, {|| (cAliasQRY)->(RA_FILIAL + QB_COMARC)  })

oFilial:Print()

Return