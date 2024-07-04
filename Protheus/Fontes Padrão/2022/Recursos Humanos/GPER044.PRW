#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER044.CH"
#INCLUDE "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³GPER044   ºAutor  ³Claudinei Soares    º Data ³ 07/06/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ Relatorio dos valores pagos em folha de pagamento referentesº±±
±±º           ³ ao PPE - Programa de Protecao ao Emprego.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ Folha de pagamento                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data     ³    FNC    | Motivo da Alteracao                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºClaudinei S.³07/06/2016³     TUQEKD|Criacao do Relatorio                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPER044()

Local	 oReport
Local	 aArea 		:= GetArea()
Private cPerg			:= "GPER044"
Private cExists 		:= ""
Private cPDDesc		:= ""	//Codigo da verba de desconto do PPE
Private cPDAbon		:= ""	//Codigo da verba de abono do PPE
Private aInfo			:= {}
Private cAliasQry		:= ""
Private cTitulo		:= OemToAnsi(STR0001)	//"PPE - Programa de Proteção ao Emprego"
Private nOrdem		:= 1
Private aOrd			:={	OemToAnsi(STR0004)}			//1 - "Matrícula"

dbSelectArea("SX1")
dbSetOrder(1)

If SX1->(dbSeek("GPER044"))
	Pergunte(cPerg,.F.)
Else
	Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0006), 1, 0 ) //"Atenção" ## "Esta rotina só está disponível a partir do Release 12.1.07 de Agosto de 2016"
	Return
Endif

oReport := ReportDef()
oReport:SetLandScape()
oReport:PrintDialog()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Claudinei Soares        Data ³16/09/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio PPE - Valores                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER044                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oSecFun
Local oSecNom
Local cDesc1	:= OemToAnsi(STR0001)+ SPACE(1) + OemToAnsi(STR0002) + SPACE(1) + OemToAnsi(STR0003)
//"RELATORIO POR CODIGO" ### "SERA IMPRESSO DE ACORDO COM OS PARAMETROS SOLICITADOS PELO" ### "USUARIO."

//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME "GPER044" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R044Imp(oReport)} DESCRIPTION cDesc1

	oReport:SetTotalInLine(.F.)     // PARA TOTALIZAR EM LINHAS
	oReport:SetDynamic()

	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0004) TABLES "SRA"  ORDERS aOrd	//Matrícula

		DEFINE CELL NAME "RA_FILIAL"  	OF oSecFun ALIAS "SRA" BLOCK {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0004)	//"Filial"
		DEFINE CELL NAME "RA_MAT"     	OF oSecFun ALIAS "SRA" TITLE OemToAnsi(STR0004)	//"Matric."
		DEFINE CELL NAME "SINAL"      	OF oSecFun TITLE "."
		DEFINE CELL NAME "STATUS"     	OF oSecFun TITLE "."
		DEFINE CELL NAME "RA_CC"      	OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "RA_CIC"    	OF oSecFun TITLE "CPF"
		DEFINE CELL NAME "RA_PIS"    	OF oSecFun TITLE "PIS"
		DEFINE CELL NAME "RA_NOME"    	OF oSecFun TITLE "NOME"
		DEFINE CELL NAME "RA_DEPTO"  	OF oSecFun TITLE "SETORTRABALHOEMPRESA" BLOCK {||fDesc("SQB",(cAliasQry)->RA_DEPTO,'QB_DESCRIC')} PICTURE "@!"
		DEFINE CELL NAME "RA_SALARIO"  	OF oSecFun TITLE "VALORSALARIOSEMREDUCAO" BLOCK {|| If((cAliasQry)->(RA_CATFUNC)=="H" ,((cAliasQry)->(RA_HRSMES)*;
																							(cAliasQry)->(RA_SALARIO)),(cAliasQry)->(RA_SALARIO))}
		DEFINE CELL NAME "RA_ADMISSA"  	OF oSecFun TITLE "DATAADMISSAO"
		DEFINE CELL NAME "RA_NASC"   	OF oSecFun TITLE "DATANASCIMENTO"

		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("SINAL"     ):Disable()
		oSecFun:Cell("STATUS"    ):Disable()
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"Matrícula"

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³ R044Imp    ³ Autor ³ Claudinei Soares    ³ Data 16/09/2015³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de valores PPE											±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER044                                                       ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R044Imp(oReport)
Local aAreaRep		:= GetArea()
Local oSectDet
Local cFiltro		:= ""
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cVerQry		:= ""
Local cVerQry0		:= ""
Local cUnion		:= ""
Local cSum			:= ""
Local cCellVerba	:= ""
Local cCellCompl	:= ""
Local cCellPDRed	:= ""
Local cCellPDAbo	:= ""
Local cCodigos		:= ""
Local cOrdem		:= ""
Local cAls			:= ""
Local cPref			:= ""
Local cCountQ		:= ""
Local cCpoQuebra	:= ""
Local cOrdFunc		:= ""
Local cCpoDelim		:= ""
Local cOrgJoin		:= ""
Local nReg			:= 0
Local nCont			:= 0
Local nCodigos		:= 0
Local aQryVerba		:= {}
Local aVerQry		:= {}
Local aLogCodFol    := {}
Local aIdCodFol 	:= {1397}
Local nX			:= 0

Private nSinAna		:= 2
Private aVerbas		:= {}
Private cVerQuery	:= ""

cSituacao 	:= MV_PAR08
cCategoria	:= MV_PAR07

nTipo := 1
nCodigos := 5

If !Empty(MV_PAR09) .And. MV_PAR09 == 2
	cAls	:= "SRD"
	cPref	:= "RD_"
Else
	cAls	:= "SRC"
	cPref	:= "RC_"
Endif

If Type("aCodFol") # "A" .Or. Len(aCodFol) == 0
	aCodFol	:=	{}
	FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
Endif

If Len(aCodFol) > 1396
	If !Empty(aCodFol[1397,1]) 
		cCodigos	:= 	AllTrim(aCodFol[1397,1])
		cPDDesc		:=  aCodFol[1397,1]	//Codigo da verba de desconto do PPE
		If !Empty(aCodFol[1398,1])		
			cCodigos	+= 	AllTrim(aCodFol[1398,1])
			cPDAbon		:=  aCodFol[1398,1]	//Codigo da verba de abono do PPE
		else
			cPDAbon		:= "2"	
		EndIf
	ElseIf !Empty(aCodFol[1398,1])		
			cPDDesc		:= "1"
			cCodigos	:= 	AllTrim(aCodFol[1398,1])
			cPDAbon		:=  aCodFol[1398,1]	//Codigo da verba de abono do PPE				
	Else
		cCodigos 	:= ""
		cPDDesc		:= "1"
		cPDAbon		:= "2"		
	EndIf
Else
	cCodigos	:= ""
	cPDDesc		:= "1"
	cPDAbon		:= "2"
EndIf

for nX := 1 to Len(aIdCodFol)
	If Len(aCodFol) > 0 .And. Empty(aCodFol[aIdCodFol[nX],1])
		aAdd(aLogCodFol, cValToChar(aIdCodFol[nX]))
	EndIf
next

nOrdem		:= oReport:GetOrder()

For nReg:=1 to Len(cCodigos) step 3
	cVerQuery += "'"+Subs(cCodigos,nReg,3)+"'"
	If ( nReg+1 ) <= Len(cCodigos)
		cVerQuery += ","
	Endif
Next nReg

cVerQuery	:= Subs(cVerQuery,1,Len(cVerQuery)-1)
oSectDet 	:= oReport:Section(1)

If !(AllTrim(oReport:Title()) == cTitulo)
	cTitulo	:= oReport:Title()
Endif

oSectDet:Cell( "RA_FILIAL" ):Disable()
cCellPDRed		:= cPDDesc
cCellCompl := ("V"+cCellPDRed)
DEFINE CELL NAME (cCellPDRed) OF oSectDet TITLE Substr(cCellPDRed,2,3) PICTURE "@E 99,999,999,999.99" SIZE 20 ;
			BLOCK {|| If((cAliasQry)->(RA_CATFUNC)=="H" ,((cAliasQry)->(RA_HRSMES)*(cAliasQry)->(RA_SALARIO))-(cAliasQry)->((&cCellCompl)),;
							((cAliasQry)->(RA_SALARIO)-(cAliasQry)->((&cCellCompl))))}

oSectDet:Cell(cCellPDRed):SetHeaderAlign("RIGHT")
oSectDet:Cell(cCellPDRed):SetAutoSize()
oSectDet:Cell(cCellPDRed):SetTitle("VALORSALARIOCUSTEADOEMPRESA")
aAdd(aQryVerba,AllTrim(cCellPDRed))

If !EMPTY(cPDAbon)
	cCellPDAbo		:= cPDAbon
	cCellVerba := ("V"+cCellPDAbo)
	DEFINE CELL NAME (cCellPDAbo) OF oSectDet TITLE Substr(cCellPDAbo,2,3) PICTURE "@E 99,999,999,999.99" SIZE 20 ;
				BLOCK {||(cAliasQry)->(&(cCellVerba))}
	oSectDet:Cell(cCellPDAbo):SetHeaderAlign("RIGHT")
	oSectDet:Cell(cCellPDAbo):SetAutoSize()
	oSectDet:Cell(cCellPDAbo):SetTitle("VALORCOMPENSACAOPAGOPPE")
	aAdd(aQryVerba,AllTrim(cCellPDAbo))
ENDIF

DEFINE CELL NAME "VALTOTPGEMP" OF oSectDet TITLE "VALORTOTALPAGAMENTOEMPREGADO" PICTURE "@E 99,999,999,999.99" SIZE 20;
			BLOCK {|| If((cAliasQry)->(RA_CATFUNC)=="H" ,((cAliasQry)->(RA_HRSMES)*(cAliasQry)->(RA_SALARIO))-(cAliasQry)->((&cCellCompl));
							+(cAliasQry)->((&cCellVerba)),	((cAliasQry)->(RA_SALARIO)-(cAliasQry)->((&cCellCompl)))+(cAliasQry)->((&cCellVerba)))}

oSectDet:Cell("VALTOTPGEMP"):SetHeaderAlign("RIGHT")
oSectDet:Cell("VALTOTPGEMP"):SetAutoSize()

DEFINE CELL NAME "MESCOMP" OF oSectDet TITLE "MESCOMPETENCIAFOPAG" PICTURE "@!" SIZE 20 BLOCK {||SubSTR(MV_PAR01,5,2)}
oSectDet:Cell("MESCOMP"):SetHeaderAlign("RIGHT")
oSectDet:Cell("MESCOMP"):SetAutoSize()

DEFINE CELL NAME "ANOCOMP" OF oSectDet TITLE "ANOCOMPETENCIAFOPAG" PICTURE "@!" SIZE 20 BLOCK {||SubSTR(MV_PAR01,1,4)}
oSectDet:Cell("ANOCOMP"):SetHeaderAlign("RIGHT")
oSectDet:Cell("ANOCOMP"):SetAutoSize()

DEFINE CELL NAME "RACACOR" OF oSectDet TITLE "RACACOR" PICTURE "@!" SIZE 20 BLOCK {||(cAliasQry)->(RA_RACACOR)}
oSectDet:Cell("RACACOR"):SetHeaderAlign("RIGHT")
oSectDet:Cell("RACACOR"):SetAutoSize()

DEFINE CELL NAME "CBO" OF oSectDet TITLE "CBO" PICTURE "@!" SIZE 20;
	BLOCK {||fDesc("SRJ",(cAliasQry)->RA_CODFUNC,'RJ_CODCBO')}
oSectDet:Cell("CBO"):SetHeaderAlign("RIGHT")
oSectDet:Cell("CBO"):SetAutoSize()

oSectDet:Cell("RA_CIC"		):Enable()
oSectDet:Cell("RA_PIS"		):Enable()
oSectDet:Cell("RA_NOME"		):Enable()
oSectDet:Cell("RA_DEPTO" 	):Enable()
oSectDet:Cell("RA_SALARIO" 	):Enable()
oSectDet:Cell("RA_ADMISSA"	):Enable()
oSectDet:Cell("RA_NASC"		):Enable()
oSectDet:Cell("RA_MAT"    	):Disable()
oSectDet:Cell("RA_CC"     	):Disable()

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += ","
	Endif
Next nReg

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += ","
	Endif
Next nReg

dbSelectArea("SRA")
dbSetOrder(1)

SRA->( DbGoTop() )

MakeSqlExpr(cPerg)

cOrdem 	:= "%TRB.RA_FILIAL,TRB.RA_MAT"
cOrdFunc	:= "%SRA.RA_FILIAL"
cOrdem		:= cOrdem + "%"
cOrdFunc	:= cOrdFunc + "%"

cAliasQry	:= GetNextAlias()

//=== Filial
If !Empty(mv_par02)
	cFiltro += mv_par02
EndIf

//=== Centro de Custo
If !Empty(mv_par03)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par03
EndIf

//=== Sindicato
If !Empty(mv_par04)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par04
EndIf

//=== Matricula
If !Empty(mv_par05)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par05
EndIf

//=== Departamento
If !Empty(mv_par06)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par06
EndIf

cExists := " EXISTS ( SELECT " + cPref +"FILIAL FROM "
cExists += RetSqlName(cAls) + " " + cAls
cExists += " WHERE SRA.RA_FILIAL = "+ cPref +"FILIAL AND SRA.RA_MAT ="+ cPref +"MAT AND " + cAls +".D_E_L_E_T_= ' ' AND "
If nSinAna == 1 .And. nOrdem == 2
	cExists += " SRA.RA_CC = " + cPref + "CC AND "
Endif
cExists += cPref +"PD IN (" + cVerQuery + ") )"

cVerQry	+= "FROM "
cVerQry	+= RetSqlName("SRA")  + " SRA "
cVerQry	+= "INNER JOIN  "
cVerQry	+= RetSqlName(cAls)   + " " + cAls + " ON "
cVerQry	+= "SRA.RA_FILIAL = " + cAls + "." + cPref + "FILIAL AND "
cVerQry	+= "SRA.RA_MAT = " + cAls + "." + cPref + "MAT "
cVerQry	+= "WHERE "
cVerQry	+= Iif(Empty(cFiltro),"",cFiltro + " AND ")
cVerQry	+= "SRA.RA_SITFOLH IN ("+ cSitQuery + ") AND "
cVerQry	+= "SRA.RA_CATFUNC IN ("+ cCatQuery + ") AND "
cVerQry	+= Iif(cAls == "SRD", "SRD.RD_DATARQ = '" +MV_PAR01 + "' AND " ,"")
cVerQry	+= "SRA.D_E_L_E_T_= ' ' AND " + cAls + ".D_E_L_E_T_= ' ' "

cVerQry0	:= "SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CC, SRA.RA_NOME, SRA.RA_SITFOLH, SRA.RA_CATFUNC, "
cVerQry0	+= "SRA.RA_CIC,	SRA.RA_PIS,	SRA.RA_DEPTO,	SRA.RA_ADMISSA, SRA.RA_NASC, SRA.RA_RACACOR, SRA.RA_CBO, SRA.RA_CODFUNC,	"
cVerQry0	+= cAls + "." + cPref + "FILIAL FILIAL, " + cAls + "." + cPref
cVerQry0	+= "MAT MAT, " + cAls + "." + cPref + "CC CCUSTO, "
If nSinAna == 2 // Analítico
	cVerQry0 += "SRA.RA_SALARIO, SRA.RA_HRSMES, "
Else
	cVerQry0 += "0 RA_SALARIO, 0 RA_HRSMES, "
Endif

aVerQry	:= Array(Len(aQryVerba))
For nReg	:= 1 to Len(aVerQry)
	aVerQry[nReg] := cVerQry0
Next

For nReg	:= 1 to Len(aQryVerba)
	cSum	+= Iif(Empty(cSum),"",", ")
	cSum	+= " SUM(V" + aQryVerba[nReg] + ") V" + aQryVerba[nReg] //+ "' "

	For nCont	:= 1 to Len(aVerQry)
		If nReg == nCont
			If nReg == Len(aVerQry)
				If nTipo == 1
				    aVerQry[nReg]	+= cAls + "." + cPref + "VALOR V" + aQryVerba[nReg] + " "
				Else
				    aVerQry[nReg]	+= cAls + "." + cPref + "HORAS V" + aQryVerba[nReg] + " "
				Endif
			Else
			    If nTipo == 1
					aVerQry[nReg]	+= cAls + "." + cPref + "VALOR V" + aQryVerba[nReg] + ", "
				Else
					aVerQry[nReg]	+= cAls + "." + cPref + "HORAS V" + aQryVerba[nReg] + ", "
				Endif
			Endif
		Else
			If nReg == Len(aVerQry)
				aVerQry[nCont]	+= "0 V" + aQryVerba[nReg] + " "
			Else
				aVerQry[nCont]	+= "0 V" + aQryVerba[nReg] + ", "
			Endif
		EndIf
	Next
Next

cUnion	:= Iif(!Empty(aVerQry[1]), " (" + aVerQry[1] + cVerQry + " AND " + cAls + "." + cPref + ;
			"PD = '" + aQryVerba[1]  + "' ", "")

For nCont	:= 2 to Len(aVerQry)
	cUnion	+= Iif(!Empty(aVerQry[nCont]), " UNION ALL " + aVerQry[nCont] + cVerQry + " AND " + cAls + ;
			"." + cPref + "PD = '" + aQryVerba[nCont] + "' ", "")
Next

cUnion		+= ") TRB "
cUnion		:= "%" + cUnion
cUnion		+= Iif(Empty(cOrgJoin),"%",cOrgJoin+"%")
cSitQuery	:= "%" + cSitQuery	+ "%"
cCatQuery	:= "%" + cCatQuery	+ "%"
cVerQuery	:= "%" + cVerQuery	+ "%"
cSum		:= "%" + cSum 		+ "%"
cExists		:= "%" + cExists	+ "%"
cFiltro		:= "%" + cFiltro    + "%"

cCpoDelim	:= "%RA_FILIAL "
cCpoDelim	+= Iif(!Empty(cCpoQuebra),","+AllTrim(cCpoQuebra),"")
cCpoDelim	+= "%"

SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query
SRC->( dbCloseArea() ) //Fecha o SRC para uso da Query

BEGIN REPORT QUERY oSectDet

BeginSql alias cAliasQry
	SELECT	TRB.RA_FILIAL,  	TRB.RA_MAT,  		TRB.RA_CC,   		TRB.RA_NOME,
			TRB.RA_CIC,		TRB.RA_PIS,		TRB.RA_DEPTO,		TRB.RA_ADMISSA,
			TRB.RA_NASC,		TRB.RA_RACACOR, 	TRB.RA_CBO,		TRB.RA_CODFUNC,
			TRB.RA_SITFOLH, 	TRB.RA_CATFUNC,	TRB.FILIAL,		TRB.MAT,
			TRB.CCUSTO,		TRB.RA_SALARIO, 	TRB.RA_HRSMES,	%exp:cSum%
	FROM  	%exp:cUnion%
	GROUP BY 	TRB.RA_FILIAL, 	TRB.RA_MAT,     	TRB.RA_CC,  		TRB.RA_NOME,
				TRB.RA_SITFOLH, 	TRB.CCUSTO,		TRB.RA_SALARIO, 	TRB.RA_HRSMES,
				TRB.RA_CIC,		TRB.RA_PIS,		TRB.RA_DEPTO,		TRB.RA_ADMISSA,
				TRB.RA_RACACOR, 	TRB.RA_CBO,		TRB.RA_CODFUNC,	TRB.RA_NASC,
				TRB.RA_CATFUNC, 	TRB.FILIAL,		TRB.MAT,  			TRB.CCUSTO
	ORDER BY %exp:cOrdem%
EndSql

END REPORT QUERY oSectDet

fInfo(@aInfo,(cAliasQry)->RA_FILIAL)

// VERIFICA SE O USUARIO CANCELOU A IMPRESSAO DO RELATORIO
If oReport:Cancel()
	Return
EndIf

IF Len(aLogCodFol) > 0
	bMakeLog := { || fMakeLog( { aLogCodFol } ,  { STR0007 + ": " + STR0008 } , NIL , .T. , FunName() , NIL , "G" , "L" , NIL , NIL ) }
	MsAguarde( bMakeLog , OemToAnsi( STR0008 ) ) 	//-- Log de Ocorrencias
EndIf

dbSelectArea(cAliasQry)

oSectDet:Cell(cCellPDRed):SetTitle("VALORSALARIOCUSTEADOEMPRESA")
If !EMPTY(cPDAbon)
	oSectDet:Cell(cCellPDAbo):SetTitle("VALORCOMPENSACAOPAGOPPE")
ENDIF

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
cCountQ := " SELECT COUNT(*) NRECS FROM ( "+ SUBSTR(GetLastQuery()[2],1,At("ORDER BY",GetLastQuery()[2])-1) + ") Y"
dbUseArea(.T., 'TOPCONN', TcGenQry(,,cCountQ), 'QTREGIS', .F., .F. )
oReport:SetMeter(QTREGIS->NRECS)
QTREGIS->( dbCloseArea() )

oSectDet:Print()

RestArea(aAreaRep)

Return
