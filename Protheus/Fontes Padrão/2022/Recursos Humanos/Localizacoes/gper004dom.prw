#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER004DOM.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER004DOM³ Autor ³  FMonroy                  ³ Data ³ 18/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte IR 4                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER004DOM()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Camp³08/02/12³18894/2011³ - Ajuste no tamanho e nos titulos        ³±±
±±³            ³        ³    TDKQVR³das celulas, para adequar o relatorio     ³±±
±±³Jonathan Glz³23/11/16³  MMI-30  ³ Se realiza localizacion para Rep. Dom....³±±
±±³            ³        ³          ³Se agregan columnas faltantes del reporte ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER004DOM() 
	Local aArea   := GetArea()
    Local cPerg      :="GPR004DOM"   
    Local oReport 
	
	Private cNomeProg :="GPER004DOM"
	Private cAliasRG7:=criatrab(nil,.f.)
	Private cSucI	:=	""
	Private cSucF	:=	""
	Private cProI	:=	""
	Private cProF	:=	""
	Private cMatI	:=	""
	Private cMatF	:=	""
	Private cMes	:=	""
	Private cAnio	:=	""
	Private nMesA	:=	0
	Private cMesAte   := ""
	Private cAnioAte  := ""
	Private nMesAAte  := 0
	Private nLin      := 55

	    If Pergunte(cPerg,.T.)
	       If TodoOk(cPerg)	
				oReport:=ReportDef(cPerg)  
				oReport:PrintDialog() 
			EndIf
	    EndIf   
	
	RestArea(aArea)
Return ( Nil )   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef   Autor ³ FMonroy               ³ Data ³18/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte IR 4.                                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(cExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-Nombre de la pregunta                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER864                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(cPerg) 
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	
	Private cTitulo	:=OEMTOANSI(STR0002)//"Reporte IR 4" 
	 
	cTitulo := Trim(cTitulo)

		//Criacao do componente de impressao
		oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), cPerg  ,{|oReport| PrintReport(oReport)})	
			oReport:Setlandscape(.T.)     //Pag Horizontal
			oReport:lHeaderVisible := .F.
			oReport:nFontBody	:= 5 // Define o tamanho da fonte.
			oReport:CFONTBODY:="COURIER NEW"

		//Criacao da celulas da secao do relatorio
		//Creación de la Primera Sección:  Encabezado
		oSection1:= TRSection():New(oReport,"Encabezado",,,/*Campos do SX3*/,/*Campos do SIX*/)
			oSection1:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
			oSection1:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
			oSection1:SetLeftMargin(3)

			TRCell():New( oSection1 , "TITLE" , , , , 60 , .F. , ,"LEFT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

		//Creación de la Segunda Sección: Enacabezado
		oSection2:=TRSection():New(oReport,"Encabezado  Det",,,/*Campos do SX3*/,/*Campos do SIX*/)
			oSection2:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
			oSection2:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
			oSection2:SetLineStyle(.F.)     //Pone titulo del campo y aun lado el y valor
			oSection2:SetLeftMargin(3)
		
			TRCell():New( oSection2 , "No"         , , , , 5                    , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "A_Nombre"   , , , , 20                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "B_Cedula"   , , , , TamSx3("RA_CIC")[1]  , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "C_Sueldos"  , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "D_oRemu"    , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "E_pRemo"    , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "F_Tmes"     , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "G_RSegu"    , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "H_Sueldo13" , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "I_PRECVIAL" , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "J_RePenAli" , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "K_ToReInEx" , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "L_SOtros"   , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "M_Liq"      , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "N_SalFa"    , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "O_SalCom"   , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "P_NSalFa"   , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection2 , "Q_DifP"     , , , , 19                   , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

		//Creación de la Tercera Sección: Detalle
		oSection3:=TRSection():New(oReport,"Detalle",,,/*Campos do SX3*/,/*Campos do SIX*/)
			oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
			oSection3:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
			oSection3:SetLineStyle(.F.)     //Pone titulo del campo y aun lado el y valor
			oSection3:SetLeftMargin(3)
	
			TRCell():New( oSection3 , "No"         , , ,                         , 5                    , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "A_Nombre"   , , ,                         , 20                   , .F. , /*bBlock*/ ,"LEFT"   ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "B_Cedula"   , , ,                         , TamSx3("RA_CIC")[1]  , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "C_Sueldos"  , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "D_oRemu"    , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "E_pRemo"    , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "F_Tmes"     , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "G_RSegu"    , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "H_Sueldo13" , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "I_PRECVIAL" , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "J_RePenAli" , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "K_ToReInEx" , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "L_SOtros"   , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "M_Liq"      , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "N_SalFa"    , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "O_SalCom"   , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "P_NSalFa"   , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
			TRCell():New( oSection3 , "Q_DifP"     , , , "@E 999,999,999,999.99" , 19                   , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

		//Creación de la Tercera Sección: Detalle
		oSection4 := TRSection():New(oReport,"Datos Agente",,,/*Campos do SX3*/,/*Campos do SIX*/)
			oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
			oSection4:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
			oSection4:SetLineStyle(.f.)     //Pone titulo del campo y aun lado el y valor
			oSection4:SetLeftMargin(3)

			TRCell():New( oSection4 , "DATAAGENTE" , "" , "" , , 60 , .F. , ,"LEFT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

		oSection1:nLinesBefore:=0
		oSection2:nLinesBefore:=0	
		oSection3:nLinesBefore:=0	
		oSection4:nLinesBefore := 0
			
Return ( oReport )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport³ Autor ³ FMonroy              ³ Data ³18/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³   Impresión del Informe                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    PrintReport(oExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1.-Objeto del reporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER864                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport) 
		Local aArea     := GetArea()
	Local oSection3 := oReport:Section(3)
	Local oSection1 := oReport:Section(1)
	Local cTitle    := ""
	Local cFilPro   := ""
	Local cSelect   := ""
	Local cOrder    := ""
	Local cFilSRV   := xFilial( "SRV", RG7->RG7_FILIAL)
	Local cMat      := ""
	Local cCic      := ""
	Local cPas      := ""
	Local nTotal    := 0
	Local nI        := 0
	Local nIRET     := 0
	Local Atot      := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local nSueldos  := 0, noRemu := 0, npRemo := 0, nTmes := 0, nRSegu := 0, nSueldo13 := 0, nPRECVIAL := 0, nRePenAli := 0
	Local nToReInEx := 0, nSOtros := 0, nLiq := 0, nSalFa := 0, nSalCom := 0, nNSalFa := 0, nDifP := 0
	Local nX        := 0
	Local cConcept  := GetCocepto()
	Local aCampos   := {}
	Local cFchIni   := cAnio + cMes + "01"
	Local cFchFin   := cAnioAte + cMesAte + ALLTRIM( STR( last_day( STOD( cAnioAte + cMesAte + "01" ) ) ) )

		Pergunte(oReport:GetParam(),.F.)   

		#IFDEF TOP
			cSelect :="%"
			cSelect += " SRA.RA_FILIAL  , RG7.RG7_PROCES , RG7.RG7_MAT  , SRA.RA_NOME    , SRA.RA_CIC     , "
			cSelect += " SRA.RA_PASSPOR , SRV.RV_COD     ,SRV.RV_CODFOL , RG7.RG7_ANOINI , RG7.RG7_ANOFIM , "
				for nX := val(cMes) to val(cMesAte)
					cSelect +="  RG7.RG7_ACUM" + strZERO(nX,2) + " ACUM" + strZERO(nX,2) + ", "
				next
			cSelect := SUBSTR(cSelect, 1, (Len(cSelect)- 2)) + "%"

			cFILPRO :=  "%"    
			CFILPRO += " RG7.RG7_CODCRI='01' "
			if !empty(cConcept)
				CFILPRO += " AND SRV.RV_COD IN ( "+ cConcept +" ) "
			endif
			CFILPRO += " AND RG7.RG7_FILIAL BETWEEN '"+ cSucI + "' AND '"+ cSucF+"'"
			CFILPRO += " AND RG7.RG7_PROCES BETWEEN '"+ cProI + "' AND '"+ cProF+"'"
			CFILPRO += " AND RG7.RG7_MAT BETWEEN '"	+ cMatI + "' AND '"+ cMatF+"'"
			CFILPRO += " AND RG7.RG7_ANOINI BETWEEN '"	+ cAnio + "' AND '"+ cAnioAte+"'"
			CFILPRO += " AND ( SRA.RA_DEMISSA = '' or (SRA.RA_DEMISSA BETWEEN '" + cFchIni + "' AND '" + cFchFin + "') )"
			CFILPRO += " %"
	
			cOrder := "% SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC, SRA.RA_PASSPOR, RG7.RG7_ANOINI, RG7.RG7_ANOFIM %"

			BeginSql alias cAliasRG7
				SELECT	%exp:cSelect% 			
				FROM %table:RG7% RG7    
				INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = RG7.RG7_FILIAL AND SRA.RA_MAT = RG7.RG7_MAT
				INNER JOIN %table:SRV% SRV ON SRV.RV_FILIAL = %exp:cFilSRV%  AND SRV.RV_COD = RG7.RG7_PD
				WHERE %exp:cFilPro%
					AND  SRA.%notDel% 
					AND  RG7.%notDel%  
					AND  SRV.%notDel%  
				ORDER BY  %exp:cOrder%
			EndSql 
    
		#ELSE
			MSGERROR(STR0001)//"No esta disponible para DBF"
		#ENDIF

		for nX := val(cMes) to val(cMesAte)
			AADD( aCampos , "ACUM" + strZERO(nX,2) )
		next
	
		Begin Sequence  
			 dbSelectArea( cAliasRG7 )
			 count to nTotal
			 oReport:SetMeter(nTotal) 
			 (cAliasRG7)->(DbGoTop()) 
				
			 If (cAliasRG7)->(!Eof())
				 oReport:Skipline(2)
				
				 While (cAliasRG7)->(!Eof())
				 	cSucActu:=(cAliasRG7)->RA_FILIAL
					nI:=0		
					nIRET:=0
				
					While (cAliasRG7)->(!Eof()) .and. cSucActu==(cAliasRG7)->RA_FILIAL  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Imprime Encabezado   1                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
						 GPER864En(oReport,(cAliasRG7)->RA_FILIAL)		
						 oReport:skipline(2)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Imprime Encabezado   2                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
						 GPER864En2(oReport)
						 oreport:fatline()		 
						 oSection3:Init()				 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Imprime Detalle                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
						nlc:=0
						While (cAliasRG7)->(!Eof()) .and. cSucActu==(cAliasRG7)->RA_FILIAL  .and. nlc<nLin        
							nI++
							nlc++
							oSection3:cell("No"):SETVALUE(ALLTRIM(STR(nI)))
							oSection3:cell( "A_Nombre" ):SETVALUE( (cAliasRG7)->RA_NOME )
							oSection3:cell( "B_Cedula" ):SETVALUE( (cAliasRG7)->RA_CIC )
							cCic:=(cAliasRG7)->RA_CIC  
		
							cPas:=(cAliasRG7)->RA_PASSPOR  
		
                   			//Inicializar celdas
							oSection3:cell( "C_Sueldos"  ):SETVALUE( 0 )
							oSection3:cell( "D_oRemu"    ):SETVALUE( 0 )
							oSection3:cell( "E_pRemo"    ):SETVALUE( 0 )
							oSection3:cell( "F_Tmes"     ):SETVALUE( 0 )
							oSection3:cell( "G_RSegu"    ):SETVALUE( 0 )
							oSection3:cell( "H_Sueldo13" ):SETVALUE( 0 )
							oSection3:cell( "I_PRECVIAL" ):SETVALUE( 0 )
							oSection3:cell( "J_RePenAli" ):SETVALUE( 0 )
							oSection3:cell( "K_ToReInEx" ):SETVALUE( 0 )
							oSection3:cell( "L_SOtros"   ):SETVALUE( 0 )
							oSection3:cell( "M_Liq"      ):SETVALUE( 0 )
							oSection3:cell( "N_SalFa"    ):SETVALUE( 0 )
							oSection3:cell( "O_SalCom"   ):SETVALUE( 0 )
							oSection3:cell( "P_NSalFa"   ):SETVALUE( 0 )
							oSection3:cell( "Q_DifP"     ):SETVALUE( 0 )
							nSueldos  := noRemu := npRemo := nTmes := nRSegu := nSueldo13 := nPRECVIAL := 0
							nRePenAli := nToReInEx := nSOtros := nLiq := nSalFa := nSalCom := nNSalFa := nDifP := 0
							while (cAliasRG7)->(!Eof()) .and. cSucActu==(cAliasRG7)->RA_FILIAL .and. cCic==(cAliasRG7)->RA_CIC .AND.  cPas==(cAliasRG7)->RA_PASSPOR

								Do Case
									case (cAliasRG7)->RV_CODFOL $ "|0031|"      //C - sueldo
										for nX := 1 to len(aCampos)
											nSueldos += &("(cAliasRG7)->"+aCampos[nX])
											aTot[1] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("C_Sueldos"):SETVALUE(nSueldos)
									case (cAliasRG7)->RV_CODFOL $ "|0085|"      //D - Otras remuneraciones agente
										for nX := 1 to len(aCampos)
											noRemu += &("(cAliasRG7)->"+aCampos[nX])
											aTot[2] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("D_oRemu"):SETVALUE(noRemu)
									case (cAliasRG7)->RV_CODFOL $ "|1118|"      //E - Remuneraciones pagadas
										for nX := 1 to len(aCampos)
											npRemo += &("(cAliasRG7)->"+aCampos[nX])
											aTot[3] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("E_pRemo"):SETVALUE(npRemo)
									case (cAliasRG7)->RV_CODFOL $ "|0607|0859|" // G - Retencion Seg. Social
										for nX := 1 to len(aCampos)
											nRSegu += &("(cAliasRG7)->"+aCampos[nX])
											aTot[4] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("G_RSegu"):SETVALUE(nRSegu)
									case (cAliasRG7)->RV_CODFOL $ "|0024|0025|" // H - Reg. Pascual
										for nX := 1 to len(aCampos)
											nSueldo13 += &("(cAliasRG7)->"+aCampos[nX])
											aTot[5] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("H_Sueldo13"):SETVALUE(nSueldo13)
									case (cAliasRG7)->RV_CODFOL $ "|0544|"      // I - Preav., Cesant., Viáticos e Indemn. Accidentes Lab.
										for nX := 1 to len(aCampos)
											nPRECVIAL += &("(cAliasRG7)->"+aCampos[nX])
											aTot[6] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("I_PRECVIAL"):SETVALUE(nPRECVIAL)
									case IsLeeBen(.T.,(cAliasRG7)->RV_COD,.f.)  // J Retención Pensión Alimenticia
										for nX := 1 to len(aCampos)
											nRePenAli += &("(cAliasRG7)->"+aCampos[nX])
											aTot[7] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("J_RePenAli"):SETVALUE(nRePenAli)
									case (cAliasRG7)->RV_CODFOL $ "|0066|"      //M - Liq. Periodo
										for nX := 1 to len(aCampos)
											nLiq += &("(cAliasRG7)->"+aCampos[nX])
											aTot[8] += &("(cAliasRG7)->"+aCampos[nX])
										next
										IF nLiq <> 0
										nIRET++
										ENDIF
										oSection3:cell("M_Liq"):SETVALUE(nLiq)
									case (cAliasRG7)->RV_CODFOL $ "|0477|"      //N - Saldo fav. Asalariado
										for nX := 1 to len(aCampos)
											nSalFa += &("(cAliasRG7)->"+aCampos[nX])
											aTot[9] += &("(cAliasRG7)->"+aCampos[nX])
										next
										oSection3:cell("N_SalFa"):SETVALUE(nSalFa)
								EndCase
		
								(cAliasRG7)->(dbSkip())
								oReport:IncMeter() 
							EndDO	
							//F - Total pagado en el mes
							nTmes := nSueldos  + noRemu + npRemo
							oSection3:cell( "F_Tmes"     ):SETVALUE( nTmes )
							aTot[10] += nTmes
		
							//K - Total retenciones e ingresos exentos
							nToReInEx := nRSegu + nSueldo13  + nPRECVIAL + nRePenAli
							oSection3:cell( "K_ToReInEx" ):SETVALUE( nToReInEx )
							aTot[11] += nToReInEx
		
							//L - sueldo y otros pagos sujetos a retencion
							nSOtros := IIF(  ( nTmes - nToReInEx ) > 0 , nTmes - nToReInEx , 0 )
							oSection3:cell( "L_SOtros"   ):SETVALUE( nSOtros  )
							aTot[12] += nSOtros
		
							//O - saldo compensado
							nSalCom := IIF( nSalFa < nLiq  , nSalFa , nLiq )
							oSection3:cell( "O_SalCom"   ):SETVALUE( nSalCom )
							aTot[13] += nSalCom
		
							//P - nuevo saldo a favor
							nNSalFa := IIF( nSalFa < nLiq  , 0 , nSalFa - nSalCom )
							oSection3:cell( "P_NSalFa"   ):SETVALUE( nNSalFa )
							aTot[14] += nNSalFa
		
							//Q - Diferencia a pagar
							nDifP := IIF( nSalFa < nLiq  , nLiq - nSalFa , 0 )
							oSection3:cell( "Q_DifP"     ):SETVALUE( nDifP )
							aTot[15] += nDifP
		
							oSection3:PrintLine() 
						EndDo //Fin  de archivo
		
						iif((cAliasRG7)->(Eof()) .or. cSucActu!=(cAliasRG7)->RA_FILIAL ,"",oReport:EndPage())
					EndDo //Misma Sucursal
		
					oReport:Skipline(1)
					oSection3:Finish() 
					oreport:fatline()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Imprime Totales                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					oSection3:Init()
						oSection3:cell("No"):SETVALUE(SPACE(1))
						oSection3:cell( "A_Nombre"   ):SETVALUE( SPACE(1)	)
						oSection3:cell( "B_Cedula"   ):SETVALUE( STR0003	) //"Totales"
						oSection3:cell( "C_Sueldos"  ):SETVALUE( aTot[1]	)
						oSection3:cell( "D_oRemu"    ):SETVALUE( aTot[2]	)
						oSection3:cell( "E_pRemo"    ):SETVALUE( aTot[3]	)
						oSection3:cell( "F_Tmes"     ):SETVALUE( aTot[10]	)
						oSection3:cell( "G_RSegu"    ):SETVALUE( aTot[4]	)
						oSection3:cell( "H_Sueldo13" ):SETVALUE( aTot[5]	)
						oSection3:cell( "I_PRECVIAL" ):SETVALUE( aTot[6]	)
						oSection3:cell( "J_RePenAli" ):SETVALUE( aTot[7]	)
						oSection3:cell( "K_ToReInEx" ):SETVALUE( aTot[11]	)
						oSection3:cell( "L_SOtros"   ):SETVALUE( aTot[12]	)
						oSection3:cell( "M_Liq"      ):SETVALUE( aTot[8]	)
						oSection3:cell( "N_SalFa"    ):SETVALUE( aTot[9]	)
						oSection3:cell( "O_SalCom"   ):SETVALUE( aTot[13]	)
						oSection3:cell( "P_NSalFa"   ):SETVALUE( aTot[14]	)
						oSection3:cell( "Q_DifP"     ):SETVALUE( aTot[15]	)
					oSection3:PrintLine()
					oSection3:Finish()
		
					oReport:skipline(1)
					oSection1:Init()
						oSection1:cell("TITLE"):SetValue(PADR(STR0004,40," ")+":"+SPACE(1)+transform(nI,"@E 999,999.99"))//"Número de Asalariados"
						oSection1:Printline()
						oSection1:cell("TITLE"):SetValue(PADR(STR0005,40," ")+":"+SPACE(1)+transform(nIRET,"@E 999,999.99"))//"Asalariados Sujetos a Retención"
					oSection1:Printline()
					oSection1:Finish()
					Atot:={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		
					oReport:EndPage()

		 		EndDo // FIN DE ARCHIVO
		
			EndIf //If fin de archivo 
		
			(cAliasRG7)->(dbCloseArea())
		End Sequence
	
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER864En ³ Autor ³ FMonroy               ³ Data ³17/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER864En(oExp1,cExp2) 		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±³          ³cExp2: Filial         		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER864                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPER864En(oReport,CFILIALRA)
	Local oSection1:=oReport:Section(1)
	Local oSection4 := oReport:Section(4)
	Local nPosS012:=0
	
		nPosS012:=FPOSTAB("S012",CFILIALRA,"=",1)
		If nPosS012 == 0
			nPosS012 := FPOSTAB("S012",Space(Len(xfilial("RCB"))),"=",1)
		Endif

		oSection1:Init()	
			oReport:Skipline()
			oReport:Skipline()
			oSection1:cell("TITLE"):SETVALUE(space(1))
			oSection1:Printline()
			oSection1:cell("TITLE"):SETVALUE( PADR(STR0006,70," ") ) //"DIRECCION GENERAL DE IMPUESTOS INTERNOS
			oSection1:Printline()
			oSection1:cell("TITLE"):SETVALUE( PADR(STR0009,70," ") ) //"CALCULO DE LAS RETENCIONES MENSUALES DEL ASALARIADO
			oSection1:Printline()
			oSection1:cell("TITLE"):SETVALUE(STR0043 + ALLTRIM(STR(YEAR(dDataBase))))//"Version " + Año
			oSection1:Printline()
		oSection1:Finish()

		oSection4:Init()
			oReport:Skipline()
			oReport:Skipline()
			oSection4:cell("DATAAGENTE"):SETVALUE( PADR( UPPER( STR0012 ) , 24 , " " ) + AllTrim(STR(FTABELA("S012",NPOSS012,5))) )
			oSection4:Printline()
			oSection4:cell("DATAAGENTE"):SETVALUE( PADR( UPPER( STR0037 ) , 24 , " " ) + FTABELA("S012",NPOSS012,9) )
			oSection4:Printline()
			oSection4:cell("DATAAGENTE"):SETVALUE( PADR( UPPER( STR0031 ) , 24 , " " ) + STR0059 )
			oSection4:Printline()
			oSection4:cell("DATAAGENTE"):SETVALUE( PADR( " " , 24 , " " ) + space(7) + cMes + "  " + cAnio + space(12) + cMesAte + "  " + cAnioAte )
			oSection4:Printline()
		oSection4:Finish()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER864En2³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER864En2(oExp1)    			     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER864                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPER864En2(oReport)
	Local oSection2:=oReport:Section(2)
	
	oSection2:Init()	
		oSection2:cell( "No"         ):SETVALUE( STR0013 ) //"No."
		oSection2:cell( "A_Nombre"   ):SETVALUE( STR0014 ) //"Apellidos y nombres"
		oSection2:cell( "B_Cedula"   ):SETVALUE( STR0015 ) //"Cédula/RNC"
		oSection2:cell( "C_Sueldos"  ):SETVALUE( STR0016 ) //"Sueldos Pagados"
		oSection2:cell( "D_oRemu"    ):SETVALUE( STR0017 ) //"Otras"
		oSection2:cell( "E_pRemo"    ):SETVALUE( STR0018 ) //"Remuneraciones pagadas"
		oSection2:cell( "F_Tmes"     ):SETVALUE( STR0019 ) //"Total Pagado mes"
		oSection2:cell( "G_RSegu"    ):SETVALUE( STR0020 ) //"Retención seg socia"
		oSection2:cell( "H_Sueldo13" ):SETVALUE( STR0045 ) //"Regalia Pascual"
		oSection2:cell( "I_PRECVIAL" ):SETVALUE( STR0046 ) //"Preaviso, Cesantía, "
		oSection2:cell( "J_RePenAli" ):SETVALUE( STR0047 ) //"Retención Pensión "
		oSection2:cell( "K_ToReInEx" ):SETVALUE( STR0048 ) //"TOTAL RETENSIONES e "
		oSection2:cell( "L_SOtros"   ):SETVALUE( STR0021 ) //"Sueldos y Otros"
		oSection2:cell( "M_Liq"      ):SETVALUE( STR0022 ) //"Liquidación"
		oSection2:cell( "N_SalFa"    ):SETVALUE( STR0023 ) //"Saldo a favor"
		oSection2:cell( "O_SalCom"   ):SETVALUE( STR0049 ) //"Saldo "
		oSection2:cell( "P_NSalFa"   ):SETVALUE( STR0024 ) //"Nuevo Saldo a"
		oSection2:cell( "Q_DifP"     ):SETVALUE( STR0050 ) //"Diferencia a "
		oSection2:Printline()

		oSection2:cell( "No"         ):SETVALUE( SPACE(1)	)
		oSection2:cell( "A_Nombre"   ):SETVALUE( STR0041	) //"completos"
		oSection2:cell( "B_Cedula"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "C_Sueldos"  ):SETVALUE( STR0026	) //"por el agente de"
		oSection2:cell( "D_oRemu"    ):SETVALUE( STR0018	) //"Remuneraciones"
		oSection2:cell( "E_pRemo"    ):SETVALUE( STR0027	) //"pagadas"
		oSection2:cell( "F_Tmes"     ):SETVALUE( STR0028	) //"en el mes"
		oSection2:cell( "G_RSegu"    ):SETVALUE( STR0029	) //"Segurid"
		oSection2:cell( "H_Sueldo13" ):SETVALUE( STR0051	) //"(Sueldo 13)"
		oSection2:cell( "I_PRECVIAL" ):SETVALUE( STR0052	) //"Viáticos e "
		oSection2:cell( "J_RePenAli" ):SETVALUE( STR0053	) //"Alimenticia"
		oSection2:cell( "K_ToReInEx" ):SETVALUE( STR0058	) //" e "
		oSection2:cell( "L_SOtros"   ):SETVALUE( STR0030	) //"pagos sujeitos a"
		oSection2:cell( "M_Liq"      ):SETVALUE( STR0031	) //"Periodo"
		oSection2:cell( "N_SalFa"    ):SETVALUE( STR0039	) //"del asalariado"
		oSection2:cell( "O_SalCom"   ):SETVALUE( STR0055	) //"Compensado"
		oSection2:cell( "P_NSalFa"   ):SETVALUE( STR0032	) //"favor  Asalariado"
		oSection2:cell( "Q_DifP"     ):SETVALUE( STR0033	) //"a Pagar"
		oSection2:Printline()

		oSection2:cell("No"):SETVALUE(SPACE(1))
		oSection2:cell( "A_Nombre"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "B_Cedula"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "C_Sueldos"  ):SETVALUE( STR0035	) //"de Retención"
		oSection2:cell( "D_oRemu"    ):SETVALUE( STR0036	) //"pagadas por el"
		oSection2:cell( "E_pRemo"    ):SETVALUE( STR0038	) //"empleadores"
		oSection2:cell( "F_Tmes"     ):SETVALUE( SPACE(1)	)
		oSection2:cell( "G_RSegu"    ):SETVALUE( SPACE(1)	)
		oSection2:cell( "H_Sueldo13" ):SETVALUE( SPACE(1)	)
		oSection2:cell( "I_PRECVIAL" ):SETVALUE( STR0056	) //"Indemnizaciones "
		oSection2:cell( "J_RePenAli" ):SETVALUE( SPACE(1)	)
		oSection2:cell( "K_ToReInEx" ):SETVALUE( STR0054	) //"Ingreso exento"
		oSection2:cell( "L_SOtros"   ):SETVALUE( STR0020	) //"Retención"
		oSection2:cell( "M_Liq"      ):SETVALUE( SPACE(1)	)
		oSection2:cell( "N_SalFa"    ):SETVALUE( SPACE(1)	)
		oSection2:cell( "O_SalCom"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "P_NSalFa"   ):SETVALUE( STR0040	) //"a Compensar"
		oSection2:cell( "Q_DifP"     ):SETVALUE( SPACE(1)	)
		oSection2:Printline()

		oSection2:cell("No"):SETVALUE(SPACE(1))
		oSection2:cell( "A_Nombre"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "B_Cedula"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "C_Sueldos"  ):SETVALUE( SPACE(1)	)
		oSection2:cell( "D_oRemu"    ):SETVALUE( STR0037	) //"Agente de Retencion"
		oSection2:cell( "E_pRemo"    ):SETVALUE( SPACE(1)	)
		oSection2:cell( "F_Tmes"     ):SETVALUE( SPACE(1)	)
		oSection2:cell( "G_RSegu"    ):SETVALUE( SPACE(1)	)
		oSection2:cell( "H_Sueldo13" ):SETVALUE( SPACE(1)	)
		oSection2:cell( "I_PRECVIAL" ):SETVALUE( STR0057	) //"Accidentes Laborales"
		oSection2:cell( "J_RePenAli" ):SETVALUE( SPACE(1)	)
		oSection2:cell( "K_ToReInEx" ):SETVALUE( SPACE(1)	)
		oSection2:cell( "L_SOtros"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "M_Liq"      ):SETVALUE( SPACE(1)	)
		oSection2:cell( "N_SalFa"    ):SETVALUE( SPACE(1)	)
		oSection2:cell( "O_SalCom"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "P_NSalFa"   ):SETVALUE( SPACE(1)	)
		oSection2:cell( "Q_DifP"     ):SETVALUE( SPACE(1)	)
		oSection2:Printline()

	oSection2:Finish()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR04DOM01³ Autor ³ FMonroy               ³ Data ³18/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion de las preguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPR04DOM01()      									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X1_VALID - GPER864En X1_ORDEM = 7                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPR04DOM01()                                       
	Local aArea  := GetArea()
	Local cMvPAR := READVAR()
	Local cMes   := SUBSTR(strZERO(&(cMvPAR),6),1,2)
	
		IF val(cMes)<1 .or.val(cMes)>12
					MSGALERT(STR0034)//"El mes debe ser de 1 a 12!"
			Return .F.
		ENDIF                  

		If cMvPAR == "MV_PAR08"
			if &(cMvPAR) < M->MV_PAR07
				MSGALERT(STR0042)//"¡El periodo final debe ser mayor o igual al periodo inicial!"
				Return .F.
			Endif
		EndIf

	RestArea(aArea)
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  05/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TodoOK(cPerg)
	Local aArea  := GetArea()

		Pergunte(cPerg,.F.)
			cSucI	:=	MV_PAR01
			cSucF	:=	MV_PAR02
			cProI	:=	MV_PAR03
			cProF	:=	MV_PAR04
			cMatI	:=	MV_PAR05
			cMatF	:=	MV_PAR06
			cMes	:=	SUBSTR(strZERO(MV_PAR07,6),1,2)
			cAnio	:=	SUBSTR(strZERO(MV_PAR07,6),3,4)
			nMesA	:=	MV_PAR07
			cMesAte  := SUBSTR(strZERO(MV_PAR08,6),1,2)
			cAnioAte := SUBSTR(strZERO(MV_PAR08,6),3,4)
			nMesAAte := MV_PAR08
		RestArea(aArea)
Return (.T.)

/*/
ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»
ºFuncao    ³GetCoceptoºAutor  ³Jonathan Gonzalez   º Data ³ 08/08/2016  º
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
ºDesc.     ³ obtiene lista de conceptos que se van a imp. en el reporte º
ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
/*/
static function GetCocepto()
	Local aArea := GetArea()
	Local cConcepto := ""

		DbSelectArea("SRV")
		SRV->(DbSetOrder(1))
		SRV->(DbGoTop())
		while !SRV->(Eof())
			if IsLeeBen(.T.,SRV->RV_COD,.f.)
				cConcepto += "'" + SRV->RV_COD +"',"
			endif
			if SRV->RV_CODFOL $ "|0031|0085|1118|0607|0859|0024|0025|0544|0066|0477|"
				cConcepto +=  "'" + SRV->RV_COD +"',"
			endif
			SRV->(dbSkip())
		enddo
		cConcepto := SUBSTR(cConcepto, 1, (Len(cConcepto)- 1))

	RestArea(aArea)
return cConcepto