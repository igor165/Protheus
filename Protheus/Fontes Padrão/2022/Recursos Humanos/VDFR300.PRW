#Include "VDFR300.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR300  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  03.12.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de Cargos em Comissão e Ocupando Cargos Efetivos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR300(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function VDFR300()

Local aRegs := {}

Private oReport
Private cString   := "SRA"
Private cPerg	  	:= "VDFR300"
Private cTitulo   := STR0001 // 'Relação de Cargos em Comissão ou Ocupando Cargos Efetivos'
Private nSeq      	:= 0
Private cQCargo   := cCCargo := ""
Private cAliasQRY	:= ""
Private oCelCargo	:= Nil

Pergunte(cPerg, .F.)

M->Q3_CARGO := ""	// Variavel para controle da numeração

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 03.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR300                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR300                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR300 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local cDescri	:= STR0002  //- 'Selecione a ordem desejada para mudar as visões do relatório.'
Local aOrd 	:= { STR0003, STR0004 } //'Cargo Comissão'###'Cargo Efetivo'
      
      //-'Cargo Comissão'   'Cargo Efetivo'
oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
oReport:nFontBody := 7							

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
								//- 'Filiais'
oFilial := TRSection():New(oReport, STR0005, { "SM0" }, aOrd) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""
oFilial:nLinesBefore   := 0

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )
									
oCargos := TRSection():New(oFilial, STR0006,( "SQ3" )) //- 'Cargos'
oFunc   := TRSection():New(oCargos, STR0007, ( "SRA","SQ3","SQB","SPF" )) //- 'Servidores'

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
														 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
														 oReport:Section(1):Section(1):Finish()), .F.) })

TRCell():New(oCargos, "", "", STR0006,/*Picture*/,Len(SQ3->Q3_DESCSUM)/*Tamanho*/,/*lPixel*/,;
				{|| (If(M->Q3_CARGO <> (cAliasQRY)->(RA_FILIAL) + (cAliasQRY)->(&cCCargo), nSeq := 0, Nil),;
					 M->Q3_CARGO := (cAliasQRY)->(RA_FILIAL) + (cAliasQRY)->(&cCCargo),;
					 AllTrim((cAliasQRY)->(&cQCargo))) })
				
oCargos:SetLineStyle()
oCargos:nLinesBefore   := 0

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
nSeq := 0
TRCell():New(oFunc,	"","", 'No', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } )
TRCell():New(oFunc,	"RA_MAT","SRA", STR0008,, 12)   //- 'Matrícula'
TRCell():New(oFunc,	"RA_NOME","SRA")
oCelCargo := TRCell():New(oFunc, "Q3_ECARGO","SQ3", STR0009, "@!", Len(SQ3->Q3_DESCSUM)) // - 'Cargo'
TRCell():New(oFunc,	"QB_DESCRIC","SQB", STR0010)   //- 'Lotação'
TRCell():New(oFunc,	"","", STR0011 + Chr(13) + Chr(10) + STR0012,/*cPicture*/, 16,/*lPixel*/, { || (cAliasQRY)->RA_DTNOMEA },;  //- 'Data de Nomeação'
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")                           //- 'Efetivo'
TRCell():New(oFunc,	"R7_DATA","SR7", STR0011 + Chr(13) + Chr(10) + STR0013,/*cPicture*/, 16/*nSize*/,/*lPixel*/,/*bBlock*/,;  //- 'Data de Nomeação'
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")                                     //- 'Comissionado'

Return (oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 08.12.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR300                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR300                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR300 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrnDatE

Local dData := Ctod(""), aArea := GetArea()

BeginSql Alias "QRYSR7"
	COLUMN R7_DATA as DATE
	
	SELECT MIN(R7_DATA) AS R7_DATA
	  FROM %table:SR7%
     WHERE %notDel% AND R7_FILIAL = %Exp:xFilial("SR7")% AND R7_MAT = %Exp:(cAliasQRY)->RA_MAT% AND R7_DATA < %Exp:Dtos((cAliasQRY)->R7_DATA)%
       AND R7_CARGO = %Exp:(cAliasQRY)->R7_ECARGO%
EndSql

dData := QRYSR7->R7_DATA
QRYSR7->(DbCloseArea())
RestArea(aArea)

Return dData

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 05.12.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR300                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR300                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR300 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

Local oFilial   := oReport:Section(1)
Local oCargos   := oReport:Section(1):Section(1)
Local oFunc     := oReport:Section(1):Section(1):Section(1)
Local nOrdem    := 0, cOrdem := cWhere := "", cWCargo := "%1=1%", cWhereSR7 := "%1=1%"
Local cJoinSQB	:= ""
Local cJoinSQ3	:= ""
Local cJoinSQ3E	:= ""

cAliasQRY	:= GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
cJoinSQ3:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinSQ3E:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinSQ3E:= Replace(cJoinSQ3E,"SQ3","SQ3E")
cJoinSQB:= "%"+ FWJoinFilial("SRA","SQB")+"%"
//-- Cargo Comissionado + Nome
If oFilial:GetOrder() < 2
	oReport:SetTitle(STR0014)  	//'Relação de Servidores Ocupando Cargo em Comissão'
	cTitCargo := STR0004		//'Cargo Efetivo'

	cQCargo := "Q3_CARGO"
	cCCargo := "Q3_CARGOC"
	oCelCargo:cName := "Q3_ECARGO"

	oCelCargo:cTitle := STR0004  //'Cargo Efetivo'
	cOrdem  := "%SRA.RA_FILIAL, SRA.RA_CARGO, SRA.RA_NOME%"
	If ! Empty(mv_par03)
		cWCargo := "%" + StrTran(mv_par03, "RA_CARGOF", "SRA.RA_CARGO") + "%"
	Endif
//-- Cargo Efetivo + Nome
Else
	oReport:SetTitle(STR0015)  //'Relações de Cargos Efetivos X Servidores Em Comissão'
	cTitCargo := STR0013       //'Comissionado'

	cQCargo := "Q3_ECARGO"
	cCCargo := "Q3_ECARGOC"
	oCelCargo:cName := "Q3_CARGO"

	oCelCargo:cTitle := STR0013 ////'Comissionado'
	cOrdem  := "%SRA.RA_FILIAL, SR7.R7_ECARGO, SRA.RA_NOME%"
	If ! Empty(mv_par03)
		cWCargo := "%" + StrTran(mv_par03, "RA_CARGOF", "SR7.R7_ECARGO") + "%"
	Endif
EndIf
oCelCargo:= cTitleProduct := oCelCargo:cTitle

cWhere := "%SRA.RA_CATFUNC = '3'"
If ! Empty(mv_par01)		//-- Filial
	cWhere += " AND " + mv_par01
	cWhereSR7 := "%" + StrTran(mv_par01, "RA_FILIAL", "SR7.R7_FILIAL") + "%"
EndIf

If ! Empty(mv_par02)		//-- Matricula
	cWhere += " AND " + mv_par02
EndIf

If ! Empty(mv_par04)		//-- Lotação/Departamento
	cWhere += " AND " + mv_par04
EndIf
cWhere += "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	COLUMN R7_DATA as DATE
	
	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, SQ3.Q3_CARGO AS Q3_CARGOC, SQ3.Q3_DESCSUM AS Q3_CARGO, SR7.R7_ECARGO, 
	       SQ3E.Q3_CARGO AS Q3_ECARGOC, SQ3E.Q3_DESCSUM AS Q3_ECARGO, SQB.QB_DESCRIC, SR7.R7_DATA, SRA.RA_DTNOMEA 
	  FROM %table:SRA% SRA
	  JOIN (SELECT SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO, MAX(SR7.R7_DATA) AS R7_DATA
	          FROM %table:SR7% SR7
	          JOIN %table:SRA% SRA ON SRA.%notDel% AND %Exp:cWhere% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT
             WHERE SR7.%notDel% AND %Exp:cWhereSR7% AND %Exp:cWCargo%
               AND SR7.R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7% SR7X
                                    JOIN %table:SRA% SRAX ON SRAX.%notDel% AND %Exp:StrTran(cWhere, "SRA", "SRAX")% AND SRAX.RA_FILIAL = SR7X.R7_FILIAL 
                                     AND SRAX.RA_MAT = SR7X.R7_MAT
                                   WHERE SR7X.%notDel% AND SR7X.R7_FILIAL = SR7.R7_FILIAL 
                                     AND SR7X.R7_MAT = SR7.R7_MAT
                                     AND SR7X.R7_SEQ = SR7.R7_SEQ
                                     AND SR7X.R7_TIPO = 'NOM')
             GROUP BY SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO) SR7 ON SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
	  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND  %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	  JOIN %table:SQ3% SQ3E ON SQ3E.%notDel% AND %Exp:cJoinSQ3E% AND SQ3E.Q3_CARGO = SR7.R7_ECARGO
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
     WHERE SRA.%notDel% AND %Exp:cWhere%
	 ORDER BY %exp:cOrdem%
EndSql
oFilial:EndQuery()

oCargos:SetParentQuery()    
oCargos:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFunc:SetParentQuery()    
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(&cCCargo) == cParam}, {|| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(&cCCargo) })

oFilial:Print()

Return