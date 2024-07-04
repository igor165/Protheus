#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER914PER.CH"
#INCLUDE "REPORT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER914PER³ Autor ³  Luis EnrÍquez                              ³ Data ³ 09/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CERTIFICADO DE BENEFICIOS SOCIALES DEL TRABAJADOR                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPER914PER()                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Peru                                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ Issue     ³  Motivo da Alteracao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Oscar G       ³21/05/21³DMINA-12362³Se icluye impresion de Firma digital , se añade etiqueta   ³±±
±±³              ³        ³           ³TOTAL INGRESOS. (PER)                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER914PER()
	Local aArea   := GetArea()
	Local oReport := NIL

	Private nomeprog	:= "GPER914PER"
	Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
	Private nLastKey 	:= 0
	Private cPerg       := "GPR914PER"

	Pergunte(cPerg,.F.)

    oReport := ReportDef()
    oReport:PrintDialog()

	RestArea( aArea )
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³ReportDef ³ Autor ³ Luis EnrÍquez         ³ Data ³ 09/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. del reporte y defincion de secciones del reporte.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER914PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local aArea     := GetArea()	
	Local cTitulo   := OemToAnsi(STR0001) //"Certificado de Beneficios Sociales del Trabajador."
	Local cDesc     := OemToAnsi(STR0002) //"Comunicacion al trabajador cesado antes del reparto de las utilidades para que proceda a recogerlas." 
	Local oReport   := Nil
	Local oSection1 := Nil

	oReport := TReport():New("GPER914PER", cTitulo ,cPerg, {|oReport| PrintReport(oReport)}, cDesc)
	oReport:HideHeader()
	oReport:HideFooter()

	oSection1 := TRSection():New(oReport,"","")	                          

	oSection1:PrintLine()                                                                                     
	
	RestArea(aArea)
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³PrintReport ³ Autor ³ Luis EnrÍquez       ³ Data ³ 09/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para imprimir el reporte.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ReportDef                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER914PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)
	Local aArea      := GetArea()
	Local cAliasTmp  := GetNextAlias()
	Local cSitQuery  := ""
	Local cCatQuery  := ""
	Local cOrdem     := ""
	Local cFilSR6    := ""
	Local cFilCTT    := ""

	Local nCont      := 0
	Local nTotalR    := 0

	Local cFilEmp    := ""
	Local cMatEmp    := ""

	Local oSection1 := oReport:Section(1)
	Local nOrdem    := oSection1:GetOrder()
	Local nVTotIng  := 0
	Local nVTotDes  := 0
	Local nVTotApo  := 0
	Local nTotIng	:= 0

	Local nI        := 0
	Local cTpDocEmp := ""
	Local aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , {"M0_CGC", "M0_NOME"} ) 
	Local cFilSQ3   := xFilial("SQ3")
	Local cNombre   := ""
	Local cDescr    := ""
	Local cFilSX5   := xFilial("SX5")
	Local dFecIng   := Ctod(" / / ")
	Local dFecDes   := Ctod(" / / ")
	Local nX        := 0
	Local nColMax   := 0
	Local cMensagem := ""
	Local cCodMsj   := ""
	Local cTipDocRL := ""
	Local cNumDocRL := ""
	Local cDesTDoc  := ""
	Local cNomeRep  := ""
	Local nAux07    := 0
	Local nNomEsp   := 0
	Local cNomCargo := ""
	Local cFecIng   := ""   
	Local cFecBaj   := ""
	Local cFileLogo := ""
	Local cFileFirma:= ""
	Local aAMD      := {} //Años, Días, Meses
	Local cIndemniz	:= "" //No aplica imprimir

	Private oFont09    := Nil
	Private oFont10    := Nil
	Private oFont10n   := Nil
	Private oFont12n   := Nil
	Private cFiltroSQL := ""
	Private cFilSQLSRC := ""
	Private cFilSRV    := ""
	Private aCts       := {}
	Private aVac       := {}
	Private aGra       := {}
	Private aInd       := {}
	Private aOtroIng   := {}
	Private aOtroDes   := {}
	Private aAportes   := {}

	Private nTotCts    := 0
	Private nTotVac    := 0
	Private nTotGra    := 0
	Private nTotInd    := 0
	Private nTotBen    := 0

	Private nHorDCTS   := 0
	Private nValDCTS   := 0
	Private nHorMCTS   := 0
	Private nValMCTS   := 0
	Private nTotclCTS  := 0
	Private nHMVacT    := 0
	Private nVMVacT    := 0
	Private nHDVacT    := 0
	Private nVDVacT    := 0
	Private nVTotVacT  := 0
	Private nHMVacD    := 0
	Private nVMVacD    := 0
	Private nHDVacD    := 0
	Private nVDVacD    := 0
	Private nVTotVacD  := 0
	Private nHMGra     := 0
	Private nVMGra     := 0
	Private nHDGra     := 0
	Private nVDGra     := 0
	Private nVTotGra   := 0
	Private nHBonExt   := 0
	Private nVBonExt   := 0
	Private nVIndAnio  := 0
	Private nHIndAni   := 0
	Private nVIndAni   := 0
	Private nHIndMes   := 0
	Private nVIndMes   := 0
	Private nHIndDia   := 0
	Private nVIndDia   := 0
	Private nVTotInd   := 0
	Private cProceso   := ""
	Private cProcedi   := ""
	Private cPeriodo   := ""
	Private cSemana    := ""
	Private cSituacao  := ""
	Private cCategoria := ""
	Private cHora      := ""

	Pergunte(cPerg,.F.)

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	makesqlExpr(cPerg)
	cProceso   := MV_PAR01
	cProcedi   := MV_PAR02
	cPeriodo   := MV_PAR03
	cSemana    := MV_PAR04
	cSituacao  := MV_PAR10
	cCategoria := MV_PAR11
	cCodMsj    := MV_PAR13

	//Situacao do Funcionario
	cSitQuery := ""
		For nCont:=1 To Len(cSituacao)
			cSitQuery += "'" + Subs(cSituacao,nCont,1) + "'"
			If ( nCont+1 ) <= Len(cSituacao)
				cSitQuery += ","
			EndIf
		Next nCont
	cSitQuery := "%" + cSitQuery + "%"

	//Categoria do Funcionario
	cCatQuery := ""
		For nCont := 1 To Len(cCategoria)
			cCatQuery += "'" + Subs(cCategoria,nCont,1) + "'"
			If ( nCont+1 ) <= Len(cCategoria)
				cCatQuery += ","
			EndIf
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

	If !Empty(cProceso) //-- Proceso
		cFiltroSQL += " AND " + cProceso
	EndIf
	If !Empty(cProcedi) //-- Tipo de nómina
		cFiltroSQL += " AND RD_ROTEIR = '" + cProcedi + "'"
	EndIf
	If !Empty(cPeriodo) //-- Periodo
		cFiltroSQL += " AND RD_PERIODO = '" + cPeriodo + "'"
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
	If !Empty(MV_PAR08) //-- Nombres
		cFiltroSQL += " AND " + MV_PAR08
	EndIf
	If !Empty(MV_PAR09) //-- Placas
		cFiltroSQL += " AND " + MV_PAR09
	EndIf
	If !Empty(MV_PAR12) //-- Unidad
		cFiltroSQL += " AND " + MV_PAR12
	EndIf

	cFiltroSQL += " %"
	cFilSQLSRC := strTran(cFiltroSQL, "RD_", "RC_")

	BeginSql alias cAliasTmp
		SELECT DISTINCT RA_FILIAL, RA_CC, RA_TNOTRAB, RA_MAT, RA_NOME,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME, RA_NOMECMP, RA_TPCIC, RA_CIC, RA_DEPTO, RA_CARGO,
				RA_CATFUNC,RA_CODFUNC, RA_PROCES, RA_CODRPAT, RA_CODAFP, RA_OFICIO, RA_HRSMES, RA_SALARIO, RA_ADMISSA, 
				RA_DTREC, RA_TIPOCO, RA_DEMISSA, RA_TIPFIN, 
				RG_FILIAL, RG_MAT,RG_DATADEM
		FROM %table:SRA% SRA, %table:SRG% SRG, %table:SRC% SRC
		WHERE SRA.RA_FILIAL 	= SRG.RG_FILIAL					AND
				SRA.RA_MAT 	= SRG.RG_MAT						AND
				SRA.RA_FILIAL = SRC.RC_FILIAL					AND
				SRA.RA_MAT 	= SRC.RC_MAT						AND
				SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)		AND
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)		AND
				SRA.%notDel%									AND
				SRG.%notDel%									AND
				SRC.%notDel%									
				%exp:cFilSQLSRC%
		UNION
			(SELECT DISTINCT RA_FILIAL, RA_CC, RA_TNOTRAB, RA_MAT, RA_NOME,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME, RA_NOMECMP, RA_TPCIC, RA_CIC, RA_DEPTO, RA_CARGO,
					 RA_CATFUNC,RA_CODFUNC, RA_PROCES, RA_CODRPAT, RA_CODAFP, RA_OFICIO, RA_HRSMES, RA_SALARIO, 
					 RA_ADMISSA, RA_DTREC, RA_TIPOCO, RA_DEMISSA, RA_TIPFIN,
					 RG_FILIAL, RG_MAT, RG_DATADEM
			FROM %table:SRA% SRA, %table:SRG% SRG, %table:SRD% SRD
			WHERE SRA.RA_FILIAL 	= SRG.RG_FILIAL					AND
					SRA.RA_MAT 	= SRG.RG_MAT						AND
					SRA.RA_FILIAL = SRD.RD_FILIAL					AND
					SRA.RA_MAT 	= SRD.RD_MAT						AND
					SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)		AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)		AND
					SRA.%notDel%									AND
					SRG.%notDel%									AND
					SRD.%notDel%									
					%exp:cFiltroSQL%
					)
		ORDER BY %exp:cOrdem%
	EndSql
	
	dbSelectArea(cAliasTmp)
	Count To nTotalR

	(cAliasTmp )->(dbGoTop())
	oReport:SetMeter(nTotalR)
    
    nX := 10
    
	oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont10 := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont10n:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)   
	oFont12n:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.) 
	oFont14n:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.) 

	cFileLogo := GPR914LOGO()

	While ( cAliasTmp )->(!eof())
		nTotclCTS := 0
		nVTotVacT := 0
		nVTotVacD := 0
		nVTotGra  := 0
		nVBonExt  := 0
		nVTotInd  := 0
		nVTotIng  := 0
		
		cFilEmp   := ( cAliasTmp )->RA_FILIAL
		cMatEmp   := ( cAliasTmp )->RA_MAT
		dFecIng   := Stod((cAliasTmp)->RA_ADMISSA)
		dFecDes   := Stod((cAliasTmp)->RG_DATADEM)

		aAMD := DateDiffYMD( dFecIng, dFecDes ) //Años, Meses y Días (Ingreso/Despido)

		oReport:StartPage()
		oSection1:Init()

		If File(cFileLogo)
			oSection1:SayBitmap(0050,400,cFileLogo,200,180) // Impresion de logotipo
		EndIf

		oSection1:Say ( 0080, 900, STR0003, oFont14n ) //"LIQUIDACIÓN DE BENEFICIOS SOCIALES"

		nLin := 250
		nColMax := 2400
		oSection1:Say ( nLin, 080,STR0004, oFont10n ) //"NOMBRE DEL TRABAJADOR"
		cNombre := AllTrim((cAliasTmp)->RA_PRISOBR) + " " + ;
		           AllTrim((cAliasTmp)->RA_SECSOBR) + " " + ;
				   AllTrim((cAliasTmp)->RA_PRINOME) + " " + ;
				   AllTrim((cAliasTmp)->RA_SECNOME)
		oSection1:Say ( nLin, 550,cNombre, oFont10n )	

		nLin+=50 
		
		cTpDocEmp := AllTrim(FDESCRCC("ST03",(cAliasTmp)->RA_TPCIC,1,2,3,30))
		oSection1:Say ( nLin, 080,STR0005, oFont10n ) //"DOCUMENTO DE IDENTIDAD"
		oSection1:Say ( nLin, 550,AllTrim(cTpDocEmp) + " " + AllTrim((cAliasTmp)->RA_CIC), oFont10n )

		nLin+=50 

		SQ3->(dbSelectArea("SQ3"))
		SQ3->(dbSetOrder(1)) //Q3_FILIAL + Q3_CARGO + Q3_CC 

		If SQ3->(msSeek(cFilSQ3 + (cAliasTmp)->RA_CARGO))
			cNomCargo := SQ3->Q3_DESCSUM
		Else
			cNomCargo := ""
		EndIf
		
		oSection1:Say ( nLin, 080,STR0006, oFont10n ) //"CARGO"
		oSection1:Say ( nLin, 550,cNomCargo, oFont10n )
		nLin +=50 
		oSection1:Say ( nLin, 080,STR0007, oFont10n ) //"FECHA DE INGRESO"
		cFecIng := Padl(AllTrim(Str(DAY(dFecIng))),2,'0') + "/" + Padl(AllTrim(Str(MONTH(dFecIng))),2,'0') + "/" +;
			       AllTrim(Str(YEAR(dFecIng)))
		cFecRec :=  substr((cAliasTmp)->RA_DTREC,7,2)+"/"+substr((cAliasTmp)->RA_DTREC,5,2)+"/"+substr((cAliasTmp)->RA_DTREC,1,4)
		oSection1:Say ( nLin, 550,cFecIng, oFont10n )
		nLin+=50 
		oSection1:Say ( nLin, 080,STR0008, oFont10n ) //"FECHA DE CESE"
		cFecBaj := Padl(AllTrim(Str(DAY(dFecDes))),2,'0') + "/" + Padl(AllTrim(Str(MONTH(dFecDes))),2,'0') + "/" +;
			       AllTrim(Str(YEAR(dFecDes)))	
		oSection1:Say ( nLin, 550,cFecBaj, oFont10n )
		nLin+=50 

		cDescr := ""
		cDescr := AllTrim(FDESCRCC("ST17",(cAliasTmp)->RA_TIPFIN,1,2,3,110)) 
		
		oSection1:Say ( nLin, 080,STR0020, oFont10n ) //"MOTIVO DE CESE"
		oSection1:Say ( nLin, 550,cDescr, oFont10n )
		nLin+=50 	
		
		oSection1:Say ( nLin, 080,STR0009, oFont10n ) //"PERIODO DE TRABAJO"
		
		aPerAnt := GPR914INDE(( cAliasTmp )->RA_MAT)	
		
		oSection1:Say ( nLin, 550, AllTrim(Transform(aAMD[1], "@E 999,999,999")) + " " + STR0021 + " " + AllTrim(Transform(aAMD[2], "@E 999,999,999")) + " " + STR0022 + " " + AllTrim(Transform(aAMD[3]+1, "@E 999,999,999")) + " " + STR0023, oFont10n ) //" AÑOS " //" MESES " //" DIAS" 
		nLin+=50 

		cDescr := ""
		cDescr := AllTrim(FDESCRCC("ST11",(cAliasTmp)->RA_CODAFP,1,2,3,60)) 
				
		oSection1:Say ( nLin, 080,STR0010, oFont10n ) //"SISTEMA DE PENSIÓN"
		oSection1:Say ( nLin, 550,cDescr, oFont10n )
		nLin+=50 
		
		cDescr := GPR914SX5(cFilSX5, "28" + (cAliasTmp)->RA_CATFUNC)
		
		oSection1:Say ( nLin, 080,STR0011, oFont10n ) //"CATEGORIA"
		oSection1:Say ( nLin, 550,cDescr, oFont10n )
		
		nLin+=150

		oSection1:Say ( nLin+nX, 50,STR0012, oFont10n ) //"1.- REMUNERACIONES COMPUTABLES " 
		oSection1:Say ( nLin+nX, 1300,STR0013, oFont10n ) //"CTS"
		oSection1:Say ( nLin+nX, 1550,STR0014, oFont10n ) //"VAC"
		oSection1:Say ( nLin+nX, 1750,STR0015, oFont10n ) //"GRAT"

		aRemCon := GPR914DATO(( cAliasTmp )->RA_MAT)	
		
		If nTotInd <> 0
			oSection1:Say ( nLin+nX, 1950,STR0016, oFont10n ) //"INDEP"
		EndIf

		nLin+=100                                                  

		For nI := 1 to Len(aRemcon)
			If  (aRemcon[nI][2] <> 0 .or. aRemcon[nI][3] <> 0  .or. aRemcon[nI][4] <> 0  .or. aRemcon[nI][5] <> 0)
				oSection1:Say ( nLin+nX, 80,aRemcon[nI][1], oFont10 ) 
				oSection1:Say ( nLin+nX, 1250,Transform(aRemcon[nI][2], "@E 999,999,999.99"), oFont10 ) 
				oSection1:Say ( nLin+nX, 1500,Transform(aRemcon[nI][3], "@E 999,999,999.99"), oFont10 ) 
				oSection1:Say ( nLin+nX, 1700,Transform(aRemcon[nI][4], "@E 999,999,999.99"), oFont10 ) 
	
				If nTotInd <> 0
					oSection1:Say ( nLin+nX, 1900,Transform(aRemcon[nI][5], "@E 999,999,999.99"), oFont10 ) 
				EndIf		    
				nLin += 50
			EndIf
		Next nI

		osection1:Box (nLin,1250,nLin,2100)
		oSection1:Say ( nLin+nX,250,STR0017, oFont10n ) //"TOTAL REMUNERACIONES"
		oSection1:Say ( nLin+nX,1250,Transform(nTotCts, "@E 999,999,999.99"), oFont10n ) 
		oSection1:Say ( nLin+nX,1500,Transform(nTotVac, "@E 999,999,999.99"), oFont10n ) 
		oSection1:Say ( nLin+nX,1700,Transform(nTotGra, "@E 999,999,999.99"), oFont10n ) 
		
		If nTotInd <> 0
			oSection1:Say ( nLin+nX,1900,Transform(nTotInd, "@E 999,999,999.99"), oFont10n ) 
		EndIf
		
		nLin+=50
		osection1:Box (nLin,1250,nLin,2100)

		nLin+=50
		
		osection1:Box (nLin,50,nLin+nX,nColMax)
		nLin+=50
		
		oSection1:Say ( nLin+nX, 50,STR0018, oFont10n ) //"2.- CÁLCULO DE LA CTS:"

		nLin+=50

		oSection1:Say ( nLin+nX, 70,STR0019, oFont10 ) //"Periodo de Cálculo:"
		
		If MONTH(stod(( cAliasTmp )->RA_DEMISSA)) <= 4
			cPeriodo := "01/11/" + AllTrim(str(YEAR(stod((cAliasTmp)->RG_DATADEM))-1))
		Else
			cPeriodo := "01/05/" + AllTrim(str(YEAR(stod((cAliasTmp)->RG_DATADEM))))
		EndIf
			
		oSection1:Say ( nLin+nX, 550,cPeriodo, oFont10 ) 
		oSection1:Say ( nLin+nX, 750,cFecBaj, oFont10 ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotCts, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,900,Transform(nHorMCTS, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1200,STR0022, oFont10 ) //"MESES"
		oSection1:Say ( nLin+nX,2200,Transform(nValMCTS, "@E 999,999,999.99"), oFont10 ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotCts, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,1000,"30", oFont10 ) 
		oSection1:Say ( nLin+nX,1200,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,1400,Transform(nHorDCTS, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1600," " + STR0023 + " ", oFont10 ) //" DIAS "
		oSection1:Say ( nLin+nX,2200,Transform(nValDCTS, "@E 999,999,999.99"), oFont10 ) 

		nLin+=150

		oSection1:Say ( nLin+nX,1000,STR0024, oFont10 ) //"TOTAL CTS POR PAGAR"
		oSection1:Say ( nLin+nX,2200,Transform(nTotclCTS, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		oSection1:Say ( nLin+nX, 50,STR0025, oFont10n ) //"3.- VACACIONES TRUNCAS:"

		nLin+=50
		
		oSection1:Say ( nLin+nX,80,Transform(nTotVac, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,900,Transform(nHMVacT, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1200,STR0022, oFont10 ) //"MESES"
		oSection1:Say ( nLin+nX,2200,Transform(nVMVacT, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotVac, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,1000,"30", oFont10 ) 
		oSection1:Say ( nLin+nX,1200,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,1400,Transform(nHDVacT, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1600," " + STR0023 + " ", oFont10 ) //" DIAS "
		oSection1:Say ( nLin+nX,2200,Transform(nVDVacT, "@E 999,999,999.99"), oFont10n ) 

		nLin+=150

		oSection1:Say ( nLin+nX,1000,STR0026, oFont10 ) //"TOTAL VACACIONES TRUNCAS A PAGAR"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotVacT, "@E 999,999,999.99"), oFont10n ) 
		
		nLin+=50
		
		oSection1:Say ( nLin+nX, 50,STR0027, oFont10n ) //"4.- VACACIONES DEVENGADAS:"

		nLin+=50
		
		oSection1:Say ( nLin+nX,80,Transform(nTotVac, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,900,Transform(nHMVacD , "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1200,STR0022, oFont10 ) //"MESES"
		oSection1:Say ( nLin+nX,2200,Transform(nVMVacD, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotVac, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,1000,"30", oFont10 ) 
		oSection1:Say ( nLin+nX,1200,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,1400,Transform(nHDVacD, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1600," " + STR0023 + " ", oFont10 ) //" DIAS "
		oSection1:Say ( nLin+nX,2200,Transform(nVDVacD, "@E 999,999,999.99"), oFont10n ) 

		nLin+=150

		oSection1:Say ( nLin+nX,1000,STR0028, oFont10 ) //"TOTAL VACACIONES DEVENGADAS A PAGAR"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotVacD, "@E 999,999,999.99"), oFont10n ) 
		
		nLin+=50
		
		oSection1:Say ( nLin+nX, 50,STR0029, oFont10n ) //"5.- GRATIFICACIONES TRUNCAS:"

		nLin+=50

		oSection1:Say ( nLin+nX, 70,STR0019, oFont10 ) //"Periodo de Cálculo:"
		
		IF MONTH(stod(( cAliasTmp )->RA_DEMISSA)) <= 6
			cPeriodo := "01/01/"+AllTrim(str(YEAR(stod((cAliasTmp)->RG_DATADEM))))
		Else
			cPeriodo := "01/07/"+AllTrim(str(YEAR(stod((cAliasTmp)->RG_DATADEM))))
		EndIf
			
		oSection1:Say ( nLin+nX, 550,cPeriodo, oFont10 ) 
		oSection1:Say ( nLin+nX, 750,cFecBaj, oFont10 ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotGra, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"6", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,900,Transform(nHMGra , "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1200,STR0022, oFont10 ) //"MESES"
		oSection1:Say ( nLin+nX,2200,Transform(nVMGra, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		oSection1:Say ( nLin+nX,80,Transform(nTotGra, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,600,"6", oFont10 ) 
		oSection1:Say ( nLin+nX,800,"÷", oFont10 ) 
		oSection1:Say ( nLin+nX,1000,"30", oFont10 ) 
		oSection1:Say ( nLin+nX,1200,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,1400,Transform(nHDGra , "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,1600," " + STR0023 + " ", oFont10 ) //" DIAS "
		oSection1:Say ( nLin+nX,2200,Transform(nVDGra, "@E 999,999,999.99"), oFont10n ) 

		nLin+=150

		oSection1:Say ( nLin+nX,1000,STR0030, oFont10 ) //"TOTAL GRATIFICACIONES A PAGAR"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotGra, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		oSection1:Say ( nLin+nX, 50,STR0031, oFont10n ) //"6.- BONIFICACION EXTRAORDINARIA LEY 29351:"

		nLin+=50

		oSection1:Say ( nLin+nX,600,Transform(nTotGra, "@E 999,999,999.99"), oFont10 ) 
		oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
		oSection1:Say ( nLin+nX,1000,Transform(nHBonExt, "@E 999,999,999.99") + " %", oFont10 ) 
		oSection1:Say ( nLin+nX,2200,Transform(nVBonExt, "@E 999,999,999.99"), oFont10 ) 

		nLin+=150

		oSection1:Say ( nLin+nX,1000,STR0032, oFont10 ) //"BONIFICACION ESPECIAL A PAGAR"

		oSection1:Say ( nLin+nX,2200,Transform(nVBonExt, "@E 999,999,999.99"), oFont10n ) 

		nLin+=50

		//INDEMNIZACION
		cIndemniz := FDESCRCC("ST17",(cAliasTmp)->RA_TIPFIN,1,2,118,1) 

		If  cIndemniz == '1'  //Muestra indemnización solo cuando es calculada (1=Si;2=No)
			oSection1:Say ( nLin+nX, 50,STR0033, oFont10n ) //"7.- INDEMNIZACION:"

			nLin+=50

			oSection1:Say ( nLin+nX, 70,STR0019, oFont10 ) //"Periodo de Cálculo:"
			
			IF Empty(( cAliasTmp )->RA_DTREC)
				cPeriodo := cFecIng
			Else
				cPeriodo := cFecRec
			EndIf
				
			oSection1:Say ( nLin+nX, 550,cPeriodo, oFont10 ) 
			oSection1:Say ( nLin+nX, 750,cFecBaj, oFont10 ) 

			nLin+=50

			oSection1:Say ( nLin+nX,80,Transform(nVIndAnio, "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
			oSection1:Say ( nLin+nX,900,Transform(nHIndAni , "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,2200,Transform(nVIndAni, "@E 999,999,999.99"), oFont10n ) 

			nLin+=50

			oSection1:Say ( nLin+nX,80,Transform(nTotInd, "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
			oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
			oSection1:Say ( nLin+nX,800,"X", oFont10 ) 
			oSection1:Say ( nLin+nX,900,Transform(nHIndMes , "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,1200,STR0022, oFont10 ) //"MESES"
			oSection1:Say ( nLin+nX,2200,Transform(nVIndMes, "@E 999,999,999.99"), oFont10n ) 

			nLin+=50

			oSection1:Say ( nLin+nX,80,Transform(nTotInd, "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,400,"÷", oFont10 ) 
			oSection1:Say ( nLin+nX,600,"12", oFont10 ) 
			oSection1:Say ( nLin+nX,800,"÷", oFont10 ) 
			oSection1:Say ( nLin+nX,1000,"30", oFont10 ) 
			oSection1:Say ( nLin+nX,1200,"X", oFont10 ) 
			oSection1:Say ( nLin+nX,1400,Transform(nHIndDia , "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX,1600," " + STR0023 + " ", oFont10 ) //" DIAS "
			oSection1:Say ( nLin+nX,2200,Transform(nVIndDia, "@E 999,999,999.99"), oFont10n ) 

			nLin+=150

			oSection1:Say ( nLin+nX,1000,STR0034, oFont10 ) //"TOTAL INDEMNIZACION A PAGAR"
			oSection1:Say ( nLin+nX,2200,Transform(nVTotInd, "@E 999,999,999.99"), oFont10n ) 

			nLin+=50

			oReport:EndPage()
			oSection1:Init()
			oReport:StartPage()

			If File(cFileLogo)
				oSection1:SayBitmap(0050,400,cFileLogo,200,180) // Impresion de logotipo
			EndIf
			
			oSection1:Say ( 0080, 900, STR0003, oFont14n ) //"LIQUIDACIÓN DE BENEFICIOS SOCIALES"
			nLin := 250 
			nColMax := 2400 
			oSection1:Say ( nLin, 080,STR0004, oFont10n ) //"NOMBRE DEL TRABAJADOR"
			oSection1:Say ( nLin, 550,cNombre, oFont10n )	
			nLin+=50 
			
			oSection1:Say ( nLin, 080,STR0005, oFont10n ) //"DOCUMENTO DE IDENTIDAD"
			oSection1:Say ( nLin, 550,AllTrim(cTpDocEmp) + " " + AllTrim((cAliasTmp)->RA_CIC), oFont10n )
			nLin+=50 

			oSection1:Say ( nLin, 080,STR0006, oFont10n ) //"CARGO"
			oSection1:Say ( nLin, 550,cNomCargo, oFont10n )
			nLin+=50 

			oSection1:Say ( nLin, 080,STR0007, oFont10n ) //"FECHA DE INGRESO"
			oSection1:Say ( nLin, 550,cFecIng, oFont10n )

			nLin+=50 
			oSection1:Say ( nLin, 080,STR0008, oFont10n ) //"FECHA DE CESE"
			
			oSection1:Say ( nLin, 550,cFecBaj, oFont10n )
			nLin+=50 

			cDescr := ""
			cDescr := AllTrim(FDESCRCC("ST17",(cAliasTmp)->RA_TIPFIN,1,2,3,110)) 
			
			oSection1:Say ( nLin, 080,STR0020, oFont10n ) //"MOTIVO DE CESE"
			oSection1:Say ( nLin, 550,cDescr, oFont10n )
			nLin+=50 	

			oSection1:Say ( nLin, 080,STR0009, oFont10n ) //"PERIODO DE TRABAJO"
			
			oSection1:Say ( nLin, 550, AllTrim(Transform(aAMD[1], "@E 999,999,999")) + " " + STR0021 + " " + AllTrim(Transform(aAMD[2], "@E 999,999,999")) + " " + STR0022 + " " + AllTrim(Transform(aAMD[3]+1, "@E 999,999,999")) + " " + STR0023, oFont10n ) //"AÑOS" //"MESES" //"DIAS"
			nLin+=50 

			cDescr := ""
			cDescr := AllTrim(FDESCRCC("ST11",(cAliasTmp)->RA_CODAFP,1,2,3,60)) 
					
			oSection1:Say ( nLin, 080,STR0010, oFont10n ) //"SISTEMA DE PENSIÓN"
			oSection1:Say ( nLin, 550,cDescr, oFont10n )
			nLin+=50 
			
			cDescr := GPR914SX5(cFilSX5, "28" + (cAliasTmp)->RA_CATFUNC)
			
			oSection1:Say ( nLin, 080,STR0011, oFont10n ) //"CATEGORIA"
			oSection1:Say ( nLin, 550,cDescr, oFont10n )
			nLin+=100 

			nLin+=50   
		Endif  
		
		
		oSection1:Say ( nLin+nX, 50,STR0035, oFont10n ) //"8.- OTROS INGRESOS:"

		nLin+=50
		
		For nI := 1 to Len(aOtroIng)
			oSection1:Say ( nLin+nX, 80,aOtroIng[nI][1], oFont10 ) 
			oSection1:Say ( nLin+nX, 1400,Transform(aOtroIng[nI][2], "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX, 2200,Transform(aOtroIng[nI][3], "@E 999,999,999.99"), oFont10 ) 
			
			nVTotIng += aOtroIng[nI][3]
			
			nLin+=50
		Next nI
		
		nLin+=50

		oSection1:Say ( nLin+nX,1000,STR0036, oFont10 ) //"TOTAL OTROS INGRESOS"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotIng, "@E 999,999,999.99"), oFont10n ) 

		nLin += 50
			
		nTotIng := ( nTotclCTS + nVTotVacT + nVTotVacD + nVTotGra + nVBonExt + nVTotInd + nVTotIng )
		oSection1:Say ( nLin+nX,1000,STR0047, oFont10 ) //"TOTAL INGRESOS"
		oSection1:Say ( nLin+nX,2200,Transform(nTotIng, "@E 999,999,999.99"), oFont10n ) 

		nLin += 50

		IF  cIndemniz != '1'

			oReport:EndPage()
			oSection1:Init()
			oReport:StartPage()

			If File(cFileLogo)
				oSection1:SayBitmap(0050,400,cFileLogo,200,180) // Impresion de logotipo
			EndIf

			oSection1:Say ( 0080, 900, STR0003, oFont14n ) //"LIQUIDACIÓN DE BENEFICIOS SOCIALES"
			nLin := 250 
			nColMax := 2400 

		Endif
							
		oSection1:Say ( nLin+nX, 50,STR0037, oFont10n ) //"9.- DESCUENTOS DEL TRABAJADOR:"
		
		nLin+=50

		For nI := 1 To Len(aOtroDes)
			oSection1:Say ( nLin+nX, 80,aOtroDes[nI][1], oFont10 ) 
			oSection1:Say ( nLin+nX, 1400,Transform(aOtroDes[nI][2], "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX, 2200,Transform(aOtroDes[nI][3], "@E 999,999,999.99"), oFont10 ) 
			
			nVTotDes += aOtroDes[nI][3]
			
			nLin+=50
		Next nI
		
		nLin+=50

		oSection1:Say ( nLin+nX,1000,STR0038, oFont10 ) //"TOTAL DESCUENTOS"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotDes, "@E 999,999,999.99"), oFont10n )

		nLin+=50
		
		oSection1:Say ( nLin+nX, 50,STR0045, oFont10n ) //"10.- APORTES:"

		nLin += 50

		For nI := 1 To Len(aAportes)
			oSection1:Say ( nLin+nX, 80,aAportes[nI][1], oFont10 ) 
			oSection1:Say ( nLin+nX, 1400,Transform(aAportes[nI][2], "@E 999,999,999.99"), oFont10 ) 
			oSection1:Say ( nLin+nX, 2200,Transform(aAportes[nI][3], "@E 999,999,999.99"), oFont10 ) 
			
			nVTotApo += aAportes[nI][3]
			
			nLin+=50
		Next nI

		oSection1:Say ( nLin+nX,1000,STR0046, oFont10 ) //"TOTAL DE APORTES"
		oSection1:Say ( nLin+nX,2200,Transform(nVTotApo, "@E 999,999,999.99"), oFont10n )
		 

		nLin += 50
		
		osection1:Box (nLin,050,nLin+nX,nColMax)

		nLin+=50
		osection1:Box (nLin,300,nLin+50,nColMax)
		oSection1:Say ( nLin+nX, 400,STR0039, oFont10n ) //"TOTAL A RECIBIR POR CONCEPTO DE LIQUIDACIÓN"
		oSection1:Say ( nLin+nX, 2200,Transform(nTotBen, "@E 999,999,999.99"), oFont10n ) 

		nLin+=100
		
		oSection1:Say ( nLin, 80,StrTran(STR0040, '###', AllTrim(aDatosSM0[2][2])) + AllTrim(Transform(nTotBen, "@E 999,999,999.99")), oFont12n ) //"He recibido de ### por concepto de beneficios S/. "
		
		nLin+=50
		
		oSection1:Say ( nLin, 80,StrTran(STR0041, '###', extenso(nTotBen,.F.,1,,,.T.,.T.)), oFont10n ) //"SON: ###. Importe con el que estoy de acuerdo."

		nLin+=50

		oSection1:Say ( nLin, 80,STR0042, oFont10n ) //"No teniendo que reclamar ningún otro beneficio y por lo cual firmo en señal de conformidad."
		
		If !Empty(AllTrim(cCodMsj)) 
			nLin+=50
			cMensagem := AllTrim(FDESCRCC("S091",cCodMsj,1,2,3,200))
			oSection1:Say ( nLin, 80,Substr(AllTrim(cMensagem),1,120), oFont10n ) 
			nLin+=50
			oSection1:Say ( nLin, 80,Substr(AllTrim(cMensagem),121,80), oFont10n ) 
		EndIf
	
		cNumDocRL := RTrim(LTrim(fTabela("S002", 01, 6))) 
		cFileFirma:= GetSrvProfString("Startpath","") + cNumDocRL + ".BMP"
	
		If File(cFileFirma)
			oSection1:SayBitmap(nLin + 90,150,cFileFirma,820,300) // Impresion firma digital representante legal.
		EndIf
		
		nLin+=400

		cTipDocRL := RTrim(LTrim(fTabela("S002", 01, 5))) 
		nAux07    := fPosTab("ST03", cTipDocRL, "=", 4)
		cDesTDoc  := IIF(nAux07==0, "",  fTabela("ST03",nAux07, 5)) 
		
		cNomeRep  := RTrim(LTrim(fTabela("S002", 01, 7))) + " " + RTrim(LTrim(fTabela("S002", 01, 8)))+ " " + RTrim(LTrim(fTabela("S002", 01, 9))) 
		osection1:Box (nLin,100,nLin,1000)	
		osection1:Box (nLin,1300,nLin,2200)		   

		oSection1:Say (nLin+nX, 250,STR0043, oFont10n ) //"Representante Legal de la Empresa"
		oSection1:Say (nLin+nX, 1650,STR0044, oFont10n ) //"Empleado"
		
		nLin+=50

		oSection1:Say (nLin+nX, 300,cNomeRep, oFont10n ) 
		nCaracNom := Len(AllTrim(cNombre))
		nNomEsp   := Round((110-nCaracNom)/2,0)
		cNombre   := Space(nNomEsp) + AllTrim(cNombre) + Space(nNomEsp)
		oSection1:Say (nLin+nX, 1100,cNombre, oFont10n ) 

		nLin+=50
		
		oSection1:Say (nLin+nX, 200,AllTrim(cDesTDoc) + " " + AllTrim(cNumDocRL), oFont10n ) 
		oSection1:Say (nLin+nX, 1425,AllTrim(cTpDocEmp) + " " + AllTrim((cAliasTmp)->RA_CIC), oFont10n ) 

		nLin+=50

		oReport:IncMeter()

		If oReport:Cancel() //termina proceso si se cancela el reporte
			Exit
		EndIf
		(cAliasTmp)->(dbSkip())
			
		If (cAliasTmp)->(!EOF())
			oReport:EndPage()
		EndIf
	EndDo
	
	 oSection1:Finish()

	( cAliasTmp )->(dbCloseArea())

	RestArea(aArea)
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPR914INDE  ³ Autor ³ Luis Enriquez         ³ Data ³ 14.04.21³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene datos para remuneraciones computables y datos del in-³±±
±±³          ³ forme y sus totales para cada sección.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Function GPR914DATO(cEmp)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEmp - Matrícula del empleado.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRemCom = Arreglo con los valores de las Remuneraciones Com- ³±±
±±³          ³ putables.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER914PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPR914DATO(cEmp)
	Local cAliasMov := GetNextAlias()
	Local cFilEmpC  := "% SRC.RC_MAT = '" + cEmp + "' AND %"
	Local cFilEmpD  := "% SRD.RD_MAT = '" + cEmp + "' AND %" 
	Local cQuery 	:= ""
	Local aRemCom   := {}

	aCts := {}
	aVac := {}
	aGra := {}
	aInd := {}
	aAportes := {}
	aOtroIng := {}
	aOtroDes := {}

	aAdd(aRemCom, {"Sueldo Básico",0,0,0,0})
	aAdd(aRemCom, {"Asignación Familiar",0,0,0,0})
	aAdd(aRemCom, {"Anuales (12vo)",0,0,0,0})
	aAdd(aRemCom, {"Gratificación (6to)",0,0,0,0})
	aAdd(aRemCom, {"Tiempo Extra",0,0,0,0})
	aAdd(aRemCom, {"Otros Fijos",0,0,0,0})
	aAdd(aRemCom, {"Otros Variables",0,0,0,0})
	aAdd(aRemCom, {"Otros Semestrales (6tos)",0,0,0,0})
	
	BeginSql alias cAliasMov
		SELECT  RC_FILIAL, RC_MAT, RC_PD, RC_HORAS, RC_TIPO1, RC_VALOR,
				RC_TIPO2, RC_DATA, RV_COD, RV_DESC, RV_TIPOCOD
		FROM %table:SRC% SRC, %table:SRV% SRV
		WHERE 	%exp:cFilSRV%
				SRC.RC_PD		= SRV.RV_COD					AND
				%exp:cFilEmpC%
				SRC.%notDel%									AND
				SRV.%notDel%									
				%exp:cFilSQLSRC%
		UNION
			(SELECT  RD_FILIAL, RD_MAT, RD_PD, RD_HORAS, RD_TIPO1, RD_VALOR, 
			         RD_TIPO2, RD_DATARQ,RV_COD, RV_DESC, RV_TIPOCOD
			FROM %table:SRD% SRD, %table:SRV% SRV
			WHERE 	%exp:cFilSRV%
					SRD.RD_PD = SRV.RV_COD					AND
					%exp:cFilEmpD%
					SRD.%notDel%							AND
					SRV.%notDel%								
					%exp:cFiltroSQL%
					)

	EndSql
	
	cQuery := getlastquery()
	
	While (cAliasMov)->(!eof()) 
		If (cAliasMov)->RC_PD $ "350/351/352/353/354/365/366/367" // CTS movimientos
			aAdd(aCts, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_VALOR})
			If (cAliasMov)->RC_PD $ "350"
				aRemCom[1][2] := (cAliasMov)->RC_VALOR 
				aRemCom[1][3] := (cAliasMov)->RC_VALOR 
				aRemCom[1][4] := (cAliasMov)->RC_VALOR 
				aRemCom[1][5] := (cAliasMov)->RC_VALOR 
			ElseIf (cAliasMov)->RC_PD $ "351"
				aRemCom[2][2] := (cAliasMov)->RC_VALOR //CTS - Asignación Familiar para CTS
				aRemCom[2][3] := (cAliasMov)->RC_VALOR //VAC - Asignación Familiar para Vacaciones
				aRemCom[2][4] := (cAliasMov)->RC_VALOR //GRAT - Asignación Familiar para Gratificación
				aRemCom[2][5] := (cAliasMov)->RC_VALOR //IND - Asignación Familiar para Indemnización
			ElseIf (cAliasMov)->RC_PD $ "352"
				aRemCom[3][2] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "353"
				aRemCom[4][2] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "354"
				aRemCom[5][2] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "365"
				aRemCom[6][2] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "366"
				aRemCom[7][2] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "367"
				aRemCom[8][2] := (cAliasMov)->RC_VALOR
			EndIf
		ElseIf (cAliasMov)->RC_PD $ "357" //Total CTS
			nTotCts := (cAliasMov)->RC_VALOR
		ElseIf (cAliasMov)->RC_PD $ "359"
			nHorMCTS := (cAliasMov)->RC_HORAS
			nValMCTS := (cAliasMov)->RC_VALOR
		ElseIf  (cAliasMov)->RC_PD $ "358"
			nHorDCTS := (cAliasMov)->RC_HORAS
			nValDCTS := (cAliasMov)->RC_VALOR					
		ElseIf  (cAliasMov)->RC_PD $ "369"
			nTotclCTS := (cAliasMov)->RC_VALOR
		ElseIF  (cAliasMov)->RC_PD $ "164/165/166/167/168" //VAC movimientos
			aAdd(aVac, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_VALOR})
			
			If (cAliasMov)->RC_PD $ "164"
			aRemCom[3][3] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "165"
			aRemCom[4][3] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "166"
			aRemCom[5][3] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "168"
			aRemCom[7][3] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "167"
			aRemCom[8][3] := (cAliasMov)->RC_VALOR
			EndIf
		ElseIf (cAliasMov)->RC_PD $ "141" //Total VAC
			nTotVac := (cAliasMov)->RC_VALOR
		ElseIf (cAliasMov)->RC_PD $ "172"
			nHMVacT := (cAliasMov)->RC_HORAS
			nVMVacT := (cAliasMov)->RC_VALOR					
		ElseIf (cAliasMov)->RC_PD $ "171"
			nHDVacT := (cAliasMov)->RC_HORAS
			nVDVacT := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "148"
			nVTotVacT := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "170"
			nHMVacD := (cAliasMov)->RC_HORAS
			nVMVacD := (cAliasMov)->RC_VALOR					
		ElseIf (cAliasMov)->RC_PD $ "169"
			nHDVacD := (cAliasMov)->RC_HORAS
			nVDVacD := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "147"
			nVTotVacD := (cAliasMov)->RC_VALOR	
				
		ElseIF (cAliasMov)->RC_PD $ "306/307/308/309" // GRAT movimientos
			aAdd(aGra, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_VALOR})

			If (cAliasMov)->RC_PD $ "306"
			aRemCom[3][4] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "307"
			aRemCom[5][4] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "309"
			aRemCom[7][4] := (cAliasMov)->RC_VALOR
			elseIf (cAliasMov)->RC_PD $ "308"
			aRemCom[8][4] := (cAliasMov)->RC_VALOR
			EndIf
		ElseIf (cAliasMov)->RC_PD $ "310"
			nTotGra := (cAliasMov)->RC_VALOR //Total GRA
		ElseIf (cAliasMov)->RC_PD $ "326/328"
			nHMGra := (cAliasMov)->RC_HORAS
			nVMGra := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "325/327"
			nHDGra := (cAliasMov)->RC_HORAS
			nVDGra := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "237/315/319"
			nVTotGra := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "323"
			nHBonExt := (cAliasMov)->RC_HORAS
			nVBonExt := (cAliasMov)->RC_VALOR					
		ElseIf (cAliasMov)->RC_PD $ "291/292/293/294/295/296" // INDEP movimientos   
			aAdd(aInd,{(cAliasMov)->RV_DESC,(cAliasMov)->RC_VALOR})

			If (cAliasMov)->RC_PD $ "291"
				aRemCom[3][5] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "292"
				aRemCom[4][5] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "293"
				aRemCom[5][5] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "295"
				aRemCom[7][5] := (cAliasMov)->RC_VALOR
			ElseIf (cAliasMov)->RC_PD $ "294"
				aRemCom[8][5] := (cAliasMov)->RC_VALOR
			EndIf

			If (cAliasMov)->RC_PD $ "294"
				nHIndAnio := (cAliasMov)->RC_HORAS
				nVIndAnio := (cAliasMov)->RC_VALOR				
			EndIf
		ElseIf (cAliasMov)->RC_PD $ "296"
			nTotInd := (cAliasMov)->RC_VALOR //Total IND
		ElseIf (cAliasMov)->RC_PD $ "299"
			nHIndAni := (cAliasMov)->RC_HORAS
			nVIndAni := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "298"
			nHIndMes := (cAliasMov)->RC_HORAS
			nVIndMes := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "297"
			nHIndDia := (cAliasMov)->RC_HORAS
			nVIndDia := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RC_PD $ "301/302/305" //TOTAL INDEMNIZACIÓN A PAGAR
			nVTotInd := (cAliasMov)->RC_VALOR												
		ElseIf (cAliasMov)->RC_PD $ "911"
			nTotBen := (cAliasMov)->RC_VALOR	
		ElseIf (cAliasMov)->RV_TIPOCOD == "1" 
			aAdd(aOtroIng, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_HORAS,(cAliasMov)->RC_VALOR})
		ElseIf (cAliasMov)->RV_TIPOCOD == "2" //Tipo de Concepto = Descuento 
			aAdd(aOtroDes, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_HORAS,(cAliasMov)->RC_VALOR})
		ElseIf (cAliasMov)->RC_PD $ "427|431" //Aportes
			aAdd(aAportes, {(cAliasMov)->RV_DESC,(cAliasMov)->RC_HORAS,(cAliasMov)->RC_VALOR})
		EndIf
		(cAliasMov)->(dbSkip())
	EndDo
				
	(cAliasMov)->(dbCloseArea())

Return(aRemCom) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPR914INDE  ³ Autor ³ Luis Enriquez         ³ Data ³ 14.04.21³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene RC_HORAS de conceptos de indemnización del empleado. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPR914INDE(cEmp)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEmp - Matrícula del empleado.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aPerTra[1][1] = RC_HORA del concepto 299(Indemización Años). ³±±
±±³          ³ aPerTra[1][2] = RC_HORA del concepto 298(Indemización Meses).³±±
±±³          ³ aPerTra[1][3] = RC_HORA del concepto 299(Indemización Días). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER914PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function GPR914INDE(cEmp)
	Local cAliasAnt := GetNextAlias()
	Local cFilEmpC  := "% SRC.RC_MAT = '" + cemp + "' AND %"
	Local cFilEmpD  := "% SRD.RD_MAT = '" + cemp + "' AND %"
	Local cQuery    := ""
	Local aPerTra   := {}

	aAdd(aPerTra, {0,0,0})

	BeginSql alias cAliasAnt
		SELECT  RC_FILIAL, RC_MAT, RC_PD, RC_HORAS, RC_TIPO1, RC_VALOR,
				RC_TIPO2, RC_DATA, RV_COD, RV_DESC, RV_TIPOCOD
		FROM %table:SRC% SRC, %table:SRV% SRV
		WHERE 	%exp:cFilSRV%
				SRC.RC_PD		= SRV.RV_COD					AND
				SRC.RC_PD IN ('299','298','297')				AND
				%exp:cFilEmpC%
				SRC.%notDel%									AND
				SRV.%notDel%									
				%exp:cFilSQLSRC%
		UNION
			(SELECT  RD_FILIAL, RD_MAT, RD_PD, RD_HORAS, RD_TIPO1, RD_VALOR, 
			         RD_TIPO2, RD_DATARQ,RV_COD, RV_DESC, RV_TIPOCOD
			FROM %table:SRD% SRD, %table:SRV% SRV
			WHERE 	%exp:cFilSRV%
					SRD.RD_PD = SRV.RV_COD					AND
					SRD.RD_PD IN ('299','298','297')				AND
					%exp:cFilEmpD%
					SRD.%notDel%									AND
					SRV.%notDel%								
					%exp:cFiltroSQL%
					)
	EndSql
	
	cQuery := getlastquery()
	
	While ( cAliasAnt )->(!eof()) 	
		If ( cAliasAnt )->RC_PD $ "299"
			aPerTra[1][1]  := ( cAliasAnt )->RC_HORAS
		ElseIf   ( cAliasAnt )->RC_PD $ "298"
			aPerTra[1][2]    := ( cAliasAnt )->RC_HORAS
		ElseIf   ( cAliasAnt )->RC_PD $ "297"
			aPerTra[1][3]   := ( cAliasAnt )->RC_HORAS
		EndIf
		( cAliasAnt )->(dbSkip())
	EndDo
			
	( cAliasAnt )->(dbCloseArea())
Return (aPerTra)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPR914SX5  ³ Autor ³ Luis Enriquez         ³ Data ³ 09.04.21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene Descripción de item en SX5                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPR914SX5(cFilSX5,cClave)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilSX5 = Filial de la tabla SX5.                            ³±±
±±³          ³ cClave = (X5_TABELA + X5_CHAVE).                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor obtenido de campo X5_DESCSPA de tabla generica. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER914PER                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPR914SX5(cFilSX5, cClave)
	Local cRet  := ""
	Local aArea := getArea()

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1)) //X5_FILIAL + X5_TABELA + X5_CHAVE
	If SX5->(msSeek(cFilSX5 + cClave))
		cRet := X5Descri()
	EndIf
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} GPR914LOGO
Carga logo de la empresa
@type function
@author luis.enríquez
@since 27/04/2021
@version 1.0
@return cLogo .- Retorna url de ubicación de logo de empresa.
/*/
Static Function GPR914LOGO()
	Local  cStartPath:= GetSrvProfString("Startpath","")

	cLogo	:= cStartPath + "LGRL" + Alltrim(SM0->M0_CODIGO + SM0->M0_CODFIL) + ".BMP" //Empresa + Filial
	//-- Logotipo da Empresa
	If !File(cLogo)
		cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" //Empresa
	EndIf
Return cLogo
