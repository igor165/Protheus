#INCLUDE "PROTHEUS.ch"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "GPER916PER.CH"
#INCLUDE "report.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER916PER³ Autor ³                       ³ Data ³ 22/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ COMUNICADO A TRABAJADOR CESADO REPARTO DE UTILIDADES         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPER916PER()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Peru                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³           ³                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER916PER()
Local aArea   := GetArea()
Local oReport := NIL
Private cPerg   := "GPER916PER"

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³ReportDef ³ Autor ³                       ³ Data ³ 22/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. del reporte y defincion de secciones del reporte.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER915PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local cDesc     := OemToAnsi(STR0005) //"Comunicacion al trabajador cesado antes del reparto de las utilidades para que proceda a recogerlas."
Local cTitulo   := OemToAnsi(STR0001) //"Comunicado al trabajador cesado antes del reparto de utilidades."
Local aOrd      := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004)}	//"Sucursal + Matricula" //"Sucursal + Ceco + Matrícula" //"Sucursal + Nombre"
Local oReport
Local oSection1
/*GPER916PER:
MV_PAR01 - Procesos
MV_PAR02 - Procedimiento
MV_PAR03 - Periodo
MV_PAR04 - Num Pgo
MV_PAR05 - Sucursales
MV_PAR06 - Centros de costo
MV_PAR07 - Matriculas

MV_PAR08 - Placas
MV_PAR09 - Situacion
MV_PAR10 - Categoria
MV_PAR11 - Unidad Organ
MV_PAR12 - Horarios de atencion

*/

	oReport := TReport():New("GPER916PER", cTitulo ,cPerg, {|oReport| PrintReport(oReport)}, cDesc)
	
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine( .F. )

	//Definicion de seccion.
	oSection1 := TRSection():New(oReport,"Cuerpo",NIL,aOrd)
	oSection1:SetHeaderSection(.F.)
	oSection1:SetHeaderPage(.T.)
	
	oSection1:SetReadOnly()

	//Definicion de columnas.
	

	TRCell():New(oSection1,"Detalle"    ,"",STR0007,"@!",300,NIL,NIL,"LEFT"  ,.T.,"LEFT"  ,NIL,NIL,.T.,NIL,NIL,NIL) //"Detalle"
	

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³PrintReport ³ Autor ³                     ³ Data ³ 22/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para imprimir el reporte.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER915PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)
Local aArea      := GetArea()
Local oSection1  := oReport:Section(1)
Local nOrdem     := oSection1:GetOrder()
Local cAliasTmp  := GetNextAlias()
Local cTitulo    := OemToAnsi(STR0001) //"Comunicado al trabajador cesado antes del reparto de utilidades."
Local cSitQuery  := ""
Local cCatQuery  := ""
Local cOrdem     := ""
Local cFilSRV    := ""
Local cFilSR6    := ""
Local cFilCTT    := ""
Local cFiltroSQL := ""
Local nCont      := 0
Local nTotalR    := 0

Local cFilEmp    := ""
Local cMatEmp    := ""
LOCAL cConAux    := SUPERGETMV("MV_CONUTIL", .T., "")
Local cConcept   := ""
local aConAux    := STRTOKARR( ALLTRIM(cConAux) , "/")

Local cNomEmp    := ""
Local nValor     := 0

Private aInfo	 := {}

	pergunte(cPerg,.F.)

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSQLExpr(cPerg)

	cProcedi   := MV_PAR02
	cPeriodo   := MV_PAR03
	cSemana    := MV_PAR04
	cSituacao  := alltrim(MV_PAR09)
	cCategoria := alltrim(MV_PAR10)
	cHora      := MV_PAR12

	//Conceptos
	cConcept := ""
		For nCont:= 1 to Len(aConAux)
			cConcept += "'"+ aConAux[nCont] +"',"
		Next
	cConcept := "% " + substr(cConcept,1,Len(cConcept)-1) + " %"

	//Situacao do Funcionario
	cSitQuery := ""
		For nCont:=1 to Len(cSituacao)
			cSitQuery += "'"+Subs(cSituacao,nCont,1)+"'"
			If ( nCont+1 ) <= Len(cSituacao)
				cSitQuery += ","
			Endif
		Next nCont
	cSitQuery := "%" + cSitQuery + "%"

	//Categoria do Funcionario
	cCatQuery := ""
		For nCont:=1 to Len(cCategoria)
			cCatQuery += "'"+Subs(cCategoria,nCont,1)+"'"
			If ( nCont+1 ) <= Len(cCategoria)
				cCatQuery += ","
			Endif
		Next nCont
	cCatQuery := "%" + cCatQuery + "%"

	If nOrdem == 1 // Matricula
		cOrdem := "%RA_FILIAL, RA_MAT%"
	ElseIf nOrdem == 2 // Centro de Custo
		cOrdem := "%RA_FILIAL, RA_CC, RA_MAT%"
	ElseIf nOrdem == 3 // Nome
		cOrdem := "%RA_FILIAL, RA_NOME, RA_MAT%"
	EndIf

	cFilSRV := "% SRV.RV_FILIAL = '"  + xFilial("SRV") + "' AND %"
	cFilSR6 := "% SR6.R6_FILIAL = '"  + xFilial("SR6") + "' AND %"
	cFilCTT := "% CTT.CTT_FILIAL = '" + xFilial("CTT") + "' AND %"

	//-- Tratamiento parametros Rango
	cFiltroSQL := "% "
		If !Empty(MV_PAR01) //-- Proceso
			cFiltroSQL += " AND " + MV_PAR01
		EndIf
		If !Empty(MV_PAR05) //-- Filial
			cFiltroSQL += " AND " + MV_PAR05
		EndIf
		If !Empty(MV_PAR06) //--Centro de Costo
			cFiltroSQL += " AND " + MV_PAR06
		EndIf
		If !Empty(MV_PAR07) //-- Matricula
			cFiltroSQL += " AND " + MV_PAR07
		EndIf
	
		If !Empty(MV_PAR08) //-- Placas
			cFiltroSQL += " AND " + MV_PAR09
		EndIf
		If !Empty(MV_PAR11) //-- Unidad
			cFiltroSQL += " AND " + MV_PAR12
		EndIf
	cFiltroSQL += " %"

	BeginSql alias cAliasTmp
		SELECT RA_FILIAL, RA_CC, RA_MAT, RA_NOME, RA_NOMECMP, RA_TPCIC, RA_CIC, RA_DEPTO, RA_CODFUNC, RA_PROCES, RA_HRSMES,
				RA_SALARIO, RA_ADMISSA, RA_TIPOCO, RG_FILIAL, RG_MAT, RG_DFERVEN, RG_DFERPRO, RG_SALMES, RG_SALDIA, RG_SALHORA,
				RC_FILIAL, RC_MAT, RC_PD, RC_ROTEIR, RC_PERIODO, RC_SEMANA, RC_HORAS, RC_VALOR, RC_DATA, RV_COD, RV_DESC, R6_DESC, CTT_DESC01
		FROM %table:SRA% SRA, %table:SRG% SRG, %table:SRC% SRC, %table:SRV% SRV,
		     %table:SR6% SR6, %table:CTT% CTT
		WHERE SRA.RA_FILIAL 	= SRG.RG_FILIAL					AND
				SRA.RA_MAT 	= SRG.RG_MAT						AND
				SRA.RA_FILIAL = SRC.RC_FILIAL					AND
				SRA.RA_MAT 	= SRC.RC_MAT						AND
				%exp:cFilSRV%
				SRC.RC_PD		= SRV.RV_COD					AND
			   	%exp:cFilSR6%
				SR6.R6_TURNO	= SRA.RA_TNOTRAB				AND
				%exp:cFilCTT%
				CTT.CTT_CUSTO	= SRA.RA_CC						AND
				SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)		AND
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)		AND
				SRA.%notDel%									AND
				SRG.%notDel%									AND
				SRC.%notDel%									AND
				SRV.%notDel%									AND
				SR6.%notDel%									AND
				CTT.%notDel%
				AND (RV_COD IN(%exp:cConcept%))
				AND (RC_PERIODO = %exp:cPeriodo%)
				AND (RC_SEMANA = %exp:cSemana%)
				AND (RC_ROTEIR = %exp:cProcedi% )
				%exp:cFiltroSQL%
		UNION
			(SELECT RA_FILIAL, RA_CC, RA_MAT, RA_NOME, RA_NOMECMP, RA_TPCIC, RA_CIC, RA_DEPTO, RA_CODFUNC, RA_PROCES, RA_HRSMES,
					 RA_SALARIO, RA_ADMISSA, RA_TIPOCO, RG_FILIAL, RG_MAT, RG_DFERVEN, RG_DFERPRO, RG_SALMES, RG_SALDIA, RG_SALHORA,
					 RD_FILIAL, RD_MAT, RD_PD, RD_PERIODO, RD_SEMANA, RD_ROTEIR, RD_HORAS, RD_VALOR, RD_DATARQ, RV_COD, RV_DESC, R6_DESC, CTT_DESC01
			 FROM %table:SRA% SRA, %table:SRG% SRG, %table:SRC% SRC, %table:SRD% SRD, %table:SRV% SRV,
			      %table:SR6% SR6, %table:CTT% CTT
			 WHERE SRA.RA_FILIAL 	= SRG.RG_FILIAL					AND
					SRA.RA_MAT 	= SRG.RG_MAT						AND
					SRA.RA_FILIAL = SRD.RD_FILIAL					AND
					SRA.RA_MAT 	= SRD.RD_MAT						AND
					%exp:cFilSRV%
					SRD.RD_PD		= SRV.RV_COD					AND
				   	%exp:cFilSR6%
					SR6.R6_TURNO	= SRA.RA_TNOTRAB				AND
					%exp:cFilCTT%
					CTT.CTT_CUSTO	= SRA.RA_CC						AND
					SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)		AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)		AND
					SRA.%notDel%									AND
					SRG.%notDel%									AND
					SRD.%notDel%									AND
					SRV.%notDel%									AND
					SR6.%notDel%									AND
					CTT.%notDel%
					AND (RV_COD IN(%exp:cConcept%))
					AND (RD_PERIODO = %exp:cPeriodo%)
					AND (RD_SEMANA = %exp:cSemana%)
					AND (RD_ROTEIR = %exp:cProcedi% )
					%exp:cFiltroSQL%
					)
		ORDER BY %exp:cOrdem%
	EndSql

	dbSelectArea(cAliasTmp)
	Count to nTotalR

	(cAliasTmp )->(DBGOTOP())
	oReport:SetMeter(nTotalR)

	While ( cAliasTmp )->(!eof())
	 	cMatEmp    := ( cAliasTmp )->RA_MAT
	 	cFilEmp    := ( cAliasTmp )->RA_FILIAL
		While ( cAliasTmp )->(!eof()) .AND. ( cAliasTmp )->RA_MAT == cMatEmp
			oReport:IncMeter()
			If oReport:Cancel() //termina proceso si se cancela el reporte
				Exit
			EndIf

			cNomEmp := ALLTRIM( ( cAliasTmp )->RA_NOMECMP )
			nValor  += ( cAliasTmp )->RC_VALOR

			( cAliasTmp )->(dbSkip())
			If  ( cAliasTmp )->RA_MAT <> cMatEmp
				//Busca dados da empresa
				fInfo(@aInfo,cFilEmp)
				oSection1:Init()
					oSection1:cell("Detalle"):SetValue("")
					oSection1:PrintLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetAlign("CENTER")
					oSection1:cell("Detalle"):SetValue(UPPER(STR0005))
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue("")
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:ThinLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetAlign("LEFT")
					oSection1:cell("Detalle"):SetValue(STR0009 + ALLTRIM(STR(DAY(DDATABASE))) + STR0010 +;
					                                   MESEXTENSO(MONTH(DDATABASE)) + STR0010 + ALLTRIM(STR(YEAR(DDATABASE))))
					oSection1:PrintLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetValue(STR0011)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(cNomEmp)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0012)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetValue(STR0013 + ALLTRIM(aInfo[3]) + STR0014 + ALLTRIM(aInfo[8]) + STR0015 + ALLTRIM(SM0->M0_ENDENT))
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0016 + fTabela("S002",1,4,dDataBase) +" "+ fTabela("S002",1,5,dDataBase) +" "+;
					                                   fTabela("S002",1,6,dDataBase) + STR0017 + fTabela("S002",1,3,dDataBase) + STR0018)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetValue(STR0019 + cPeriodo + STR0020 )
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0021)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0022)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0023)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetAlign("CENTER")
					oSection1:cell("Detalle"):SetValue(STR0024 + ALLTRIM(TRANSFORM ( nValor , "@E 99,999,999,999" )) + " - " + Extenso(nValor, .t.) + STR0025 )
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetAlign("LEFT")
					oSection1:cell("Detalle"):SetValue(STR0026)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0027 + ALLTRIM(SM0->M0_ENDENT) + STR0028 + cHora)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetValue(STR0029)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0030)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oSection1:cell("Detalle"):SetAlign("CENTER")
					oSection1:cell("Detalle"):SetValue(STR0031)
					oSection1:PrintLine()
					oSection1:cell("Detalle"):SetValue(STR0032)
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oReport:ThinLine()
					oReport:SkipLine()

				oSection1:Finish()
				oReport:EndPage()
			EndIf
		EndDo
	EndDo
	( cAliasTmp )->(dbCloseArea())

RestArea(aArea)
Return (.T.)
