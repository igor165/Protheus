#INCLUDE "INKEY.CH"
#INCLUDE "protheus.ch"
#INCLUDE "report.ch"
#INCLUDE "GPER903.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER903  ³ Autor ³ Tiago Malta           ³ Data ³ 22/03/10     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Medias                             			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER903(void)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - Argentina                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³21/05/10³07500/2010³Ajustes de parametros da funçao  	      ³±±
±±³            ³        ³          ³ fBuscaPerAt.                        	  ³±±
±±³Glaucia M.  ³31/08/11³09782/2011³Adequacao do Relatorio Medias, para qdo   ³±±
±±³			   ³		³		   ³nao existir verbas e/ou periodos p/ apre- ³±±
±±³			   ³		³		   ³sentar.									  ³±±
±±³            ³        ³          ³                                          ³±±
±±³Jonathan Glz³07/05/15³PCREQ-4256³Se elimina funcion AjustaSx1 que realiza  ³±±
±±³            ³        ³          ³modificacion al diccionario de datos(SX1) ³±±
±±³            ³        ³          ³por motivo de ajuste nueva estructura de  ³±±
±±³            ³        ³          ³SXs para V12                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER903(lCalcF)

local aKeys:= GetKeys()
Local oReport

Private lFerias := lCalcF

IF lFerias == nil
	lFerias := .F.
ENDIF

oReport := ReportDef(lFerias)
oReport:PrintDialog()

RestKeys(aKeys,.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Tiago Malta           ³ Data ³ 22.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function ReportDef(lFerias)

Local oReport
Local cDesc		:=	STR0001
Local aOrd	  	:=	{ STR0011 }
Local oSection
Local oSection2
Local oSection3

IF !lFerias
	Pergunte("GPER903",.F.)
Endif

	IF lFerias
		DEFINE REPORT oReport NAME "GPER903" TITLE OemToAnsi(STR0001) ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cDesc TOTAL IN COLUMN PAGE TOTAL IN COLUMN
	ELSE
		DEFINE REPORT oReport NAME "GPER903" TITLE OemToAnsi(STR0001) PARAMETER "GPER903" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cDesc TOTAL IN COLUMN PAGE TOTAL IN COLUMN
	ENDIF

		DEFINE SECTION oSection OF oReport TABLES "SRA" ORDERS aOrd

		   	DEFINE CELL NAME "RA_FILIAL"	OF oSection ALIAS "SRA" SIZE 10
		   	DEFINE CELL NAME "RA_MAT" 		OF oSection ALIAS "SRA"	SIZE 20
			DEFINE CELL NAME "RA_NOME" 		OF oSection ALIAS "SRA" SIZE 50

		DEFINE SECTION oSection2 OF oSection TABLES "SRD"

		   	DEFINE CELL NAME "RD_PERIODO"	OF oSection2 ALIAS "SRD" TITLE STR0002                      SIZE 6
		 	DEFINE CELL NAME "RD_DATARQ" 	OF oSection2 ALIAS "SRD" TITLE STR0003 PICTURE "@R 9999/99" SIZE 7
			DEFINE CELL NAME "RD_PD" 		OF oSection2 ALIAS "SRD" TITLE STR0004                        SIZE 3
			DEFINE CELL NAME "PDDESC" 		OF oSection2             TITLE STR0005                    SIZE 30  BLOCK {|| FDESC("SRV",SRD->RD_PD,"RV_DESC") }
			DEFINE CELL NAME "RD_HORAS" 	OF oSection2 ALIAS "SRD" TITLE STR0006  PICTURE "@E 999,999.99"                      SIZE 10
			DEFINE CELL NAME "RD_VALOR" 	OF oSection2 ALIAS "SRD" TITLE STR0007  PICTURE "@E 999,999.99"                      SIZE 10

	  	DEFINE SECTION oSection3 OF oSection TABLES "SRD1"

		   	DEFINE CELL NAME "RD_PERIODO"	OF oSection3 ALIAS "SRD1" TITLE STR0002                      SIZE 6
		 	DEFINE CELL NAME "RD_DATARQ" 	OF oSection3 ALIAS "SRD1" TITLE STR0003 PICTURE "@R 9999/99" SIZE 7
			DEFINE CELL NAME "RD_PD" 		OF oSection3 ALIAS "SRD1" TITLE STR0004                        SIZE 3
			DEFINE CELL NAME "PDDESC" 		OF oSection3              TITLE STR0005                    SIZE 30  BLOCK {|| FDESC("SRV",SRD1->RD_PD,"RV_DESC") }
			DEFINE CELL NAME "RD_HORAS" 	OF oSection3 ALIAS "SRD1" TITLE STR0006                        SIZE 10

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintReport³ Autor ³ R.H. - Tiago Malta      ³ Data ³ 22.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Medias                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PrintReport( oReport )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis Locais                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oSection  	:= oReport:Section(1) 		// Funcionario
Local oSection2 	:= oSection:Section(1)		// Acumulado
Local oSection3 	:= oSection:Section(2)		// Acumulado
Local cTitulo		:= STR0001
Local cAliasSRA		:= "SRA"
Local cAliasSRD		:= "SRD"
Local cSRD1	        := "SRD1"
Local cSitQuery	    := ""
Local cCatQuery	    := ""
Local cOrdem		:= ""
Local cOrdemSRD     := "%RD_FILIAL, RD_MAT, RD_DATARQ ,RD_PD%"
Local cFiltro		:= ""
Local cInner        := ""
Local cInnerC       := ""
Local nOrdem		:= oSection:GetOrder()
Local nReg			:= 0
Local cProcesso     := MV_PAR03
Local cPeriodo      := MV_PAR04
Local cNumPg        := MV_PAR05
Local cSituacao     := MV_PAR06
Local cCategoria    := MV_PAR07
Local nImpress      := MV_PAR08
Local nTipo         := MV_PAR09
Local nPerAtu       := MV_PAR10
Local cVerbasHG     := "%" + "'" + fGetCodFol('0031') + "'" + "," + "'" + fGetCodFol('0032') + "'" + "%"
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER903" , "SRA" , "2" ) + " } " )
Local cTitMed       := ""
Local nMeses        := 0
Local cPeriod       := ""

	IF lFerias
		nTipo     := 1
		nImpress  := 1
		nPerAtu   := 1
		cPeriodo  := M->RH_PERIODO
		cNumPg    := M->RH_NPAGTO
	ENDIF

	IF nTipo == 1
		cInner          := "% SRV.RV_COD = SRD.RD_PD AND SRV.RV_MEDFER = 'S' %"
		cInnerC         := "% SRV.RV_COD = SRC.RC_PD AND SRV.RV_MEDFER = 'S' %"
	ELSE
		cInner          := "% SRV.RV_COD = SRD.RD_PD AND SRV.RV_MEDAUS = 'S' %"
		cInnerC         := "% SRV.RV_COD = SRC.RC_PD AND SRV.RV_MEDAUS = 'S' %"
	ENDIF

    IF nImpress == 1
		DEFINE BREAK oBreakSRD OF oSection2  WHEN oSection:Cell("RA_MAT") TITLE STR0008
	 	DEFINE FUNCTION NAME "TOTAL"    FROM oSection2:Cell("RD_VALOR") FUNCTION SUM     BREAK oBreakSRD NO END SECTION NO END REPORT PICTURE "@E 999,999.99"
	 	DEFINE FUNCTION NAME "HORAS"    FROM oSection2:Cell("RD_HORAS") FUNCTION SUM     BREAK oBreakSRD NO END SECTION NO END REPORT PICTURE "@E 999,999.99"

	   	DEFINE BREAK oBrkSRD1 OF oSection3  WHEN oSection:Cell("RA_MAT") TITLE STR0008
	   	DEFINE FUNCTION NAME "HORAS"    FROM  oSection3:Cell("RD_HORAS" ) FUNCTION SUM    BREAK oBrkSRD1 NO END SECTION NO END REPORT PICTURE "@E 999,999.99"
	ELSE
		DEFINE BREAK oBreakSRD OF oSection2  WHEN oSection:Cell("RA_MAT") TITLE STR0008
	 	DEFINE FUNCTION NAME "TOTAL"    FROM oSection2:Cell("RD_VALOR") FUNCTION SUM     BREAK oBreakSRD NO END SECTION NO END REPORT PICTURE "@E 999,999.99" DISABLE
	 	DEFINE FUNCTION NAME "HORAS"    FROM oSection2:Cell("RD_HORAS") FUNCTION SUM     BREAK oBreakSRD NO END SECTION NO END REPORT PICTURE "@E 999,999.99" DISABLE

	   	DEFINE BREAK oBrkSRD1 OF oSection3  WHEN oSection:Cell("RA_MAT") TITLE STR0008
	   	DEFINE FUNCTION NAME "HORAS"    FROM  oSection3:Cell("RD_HORAS" ) FUNCTION SUM    BREAK oBrkSRD1 NO END SECTION NO END REPORT PICTURE "@E 999,999.99" DISABLE
	ENDIF

   	DEFINE BREAK oBrkSRD1 OF oSection  WHEN oSection:Cell("RA_MAT") TITLE STR0009
	DEFINE CELL NAME STR0010 	OF oSection3
 	DEFINE FUNCTION NAME "MEDIA" FROM  oSection3:Cell(STR0010) FUNCTION ONPRINT BREAK oBrkSRD1 FORMULA {|| oSection2:GetFunction("TOTAL"):PageValue() / IIF( (cAliasSRA)->RA_CATFUNC $ "HG" , oSection3:GetFunction("HORAS"):PageValue() , nMeses ) } PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT
   	oBrkSRD1:SetTotalText({|| STR0009 + space(2) + Transform( oSection2:GetFunction("TOTAL"):PageValue() , "@E 999,999.99"  ) + " / " + Alltrim( IIF( (cAliasSRA)->RA_CATFUNC $ "HG" , Transform( oSection3:GetFunction("HORAS"):PageValue() , "@E 999,999.99" ) , STR(nMeses) ) ) })
   	oBrkSRD1:SetTotalInLine(.T.)

   	IF !lFerias
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz filtro no arquivo...                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltro	:= "%"

		//-- Adiciona no filtro o parametro tipo Range
		//-- Filial
		If !Empty(mv_par01)
			cFiltro +=" SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		EndIf

		//-- Matricula
		If !Empty(mv_par02)
			cFiltro +=" SRA."+RANGESX1("RA_MAT"  ,MV_PAR02)+" AND "
		EndIf

	    cFiltro+="%"

		For nReg:=1 to Len(cSituacao)
			cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cSituacao)
				cSitQuery += ","
			Endif
		Next nReg

		cSitQuery := "%" + cSitQuery + "%"

		cCatQuery := ""
		For nReg:=1 to Len(cCategoria)
			cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cCategoria)
				cCatQuery += ","
			Endif
		Next nReg

		cCatQuery := "%" + cCatQuery + "%"

		If nOrdem == 1
			cOrdem += "%RA_FILIAL, RA_MAT%"
		Endif

	  	IF SELECT(cAliasSRA) > 0
	  		(cAliasSRA)->( dbclosearea() )
		ENDIF

		BeginSql alias cAliasSRA
			SELECT *
			FROM %table:SRA% SRA
			WHERE SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				  SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				  SRA.RA_PROCES  =   %exp:cProcesso%         AND
				  %exp:cFiltro%
				  SRA.%notDel%
			ORDER BY %exp:cOrdem%
		EndSql

	Endif
	//-- Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter( (cAliasSRA)->( RecCount() ) )

	While (cAliasSRA)->( !EOF() )

		IF !((cAliasSRA)->RA_CATFUNC $ "HG")
		    // Busca a quantidade de meses para media
		    nMeses := Posicione("RCE",1,xFilial("RCE")+(cAliasSRA)->RA_SINDICA,"RCE_MED01")

		    IF nMeses <= 0
			    nMeses := VAL(Alltrim(Posicione("RCA",1,xFilial("RCA")+"P_MESESPRO      ","RCA_CONTEU")))
		    ENDIF
		ENDIF

		//Busca os periodos para busca dos registros para media
		cPeriod := fBusPerMed( cAliasSRA , nMeses , cPeriodo , cNumPg , nPerAtu )

		IF Empty(cPeriod) .OR. cPeriod == '%() AND %'

			IF !lFerias

				IF SELECT("SRA") > 0
					SRA->(dbCloseArea())
				Endif

				ChkFile("SRA")

			ENDIF

			IF SELECT("SRD") > 0
				SRD->(dbCloseArea())
			Endif
			IF SELECT("SRD1") > 0
				SRD1->(dbCloseArea())
			Endif

			Return nil

		Endif

  		oReport:IncMeter()

  		IF nImpress == 1
	  		oSection2:GetFunction("TOTAL"):ResetPage()
 			oSection3:GetFunction("HORAS"):ResetPage()
 		ENDIF

  		IF SELECT(cAliasSRD) > 0
  			(cAliasSRD)->( dbclosearea() )
  		ENDIF

  		BeginSql alias cAliasSRD
			SELECT *
			FROM       %table:SRD% SRD
			INNER JOIN %table:SRV% SRV
			ON  %exp:cInner%
			WHERE SRD.RD_MAT     = %exp: (cAliasSRA)->RA_MAT % AND
				  %exp:cPeriod%
				  SRD.%notDel%                                 AND
				  SRV.%notDel%
				  ORDER BY %exp:cOrdemSRD%
		EndSql

		// Validação para a impressão dos horistas
		IF (cAliasSRA)->RA_CATFUNC $ "HG"

		  	IF SELECT(cSRD1) > 0
  				(cSRD1)->( dbclosearea() )
  			ENDIF

			BeginSql alias cSRD1
				SELECT *
				FROM       %table:SRD% SRD
				WHERE SRD.RD_MAT     = %exp: (cAliasSRA)->RA_MAT % AND
				      %exp:cPeriod%                                AND
				      SRD.RD_PD      IN (%exp: cVerbasHG %)        AND
					  SRD.%notDel%
					  ORDER BY %exp:cOrdemSRD%
			EndSql
		ENDIF

        IF !EMPTY((cAliasSRD)->RD_MAT)

			oSection:Init()
		   	oSection2:Init()

	  		IF (cAliasSRA)->RA_CATFUNC $ "HG"
	  			oSection3:Init()
	  		Endif

	  	ENDIF

		//-- Verifica se o usuário cancelou a impressão do relatorio
		If oReport:Cancel()
			Exit
		EndIf

		If !((cAliasSRA)->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			(cAliasSRA)->( dbSkip() )
			Loop
		EndIf

		IF !EMPTY((cAliasSRD)->RD_MAT)

			oSection:PrintLine()

			IF nImpress == 2
				oSection2:Hide()
			ENDIF

			(cAliasSRD)->(DBGOTOP())
			While (cAliasSRD)->(!EOF())
				oSection2:PrintLine()
				(cAliasSRD)->(DBSKIP())
			ENDDO

		    // Tratamento para periodo atual
			IF nPerAtu == 1
				fBuscaPerAt( cAliasSRA , cAliasSRD , cOrdemSRD ,cInner , cInnerC , oSection2 , cPeriodo , cNumPg )
			ENDIF

			oSection2:Finish()

			// Validação para a impressão dos horistas
			IF (cAliasSRA)->RA_CATFUNC $ "HG"

				IF nImpress == 2
					oSection3:Hide()
				ENDIF

				(cSRD1)->(DBGOTOP())
				While (cSRD1)->(!EOF())
					oSection3:Cell("Resultado"):SetTitle("")
					oSection3:PrintLine()
					(cSRD1)->(DBSKIP())
				ENDDO

				IF nPerAtu == 1
					fBuscaPerAt( cAliasSRA , cAliasSRD , cInner , cInnerC , oSection3 , cPeriodo , cNumPg )
				ENDIF

				oSection3:Finish()

			ENDIF

			oSection:Finish()

		ENDIF

		IF !lFerias
			(cAliasSRA)->( dbSkip() )
		ELSE
			EXIT
		ENDIF

	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF !lFerias

		IF SELECT("SRA") > 0
			SRA->(dbCloseArea())
		Endif

		ChkFile("SRA")

	ENDIF

	IF SELECT("SRD") > 0
		SRD->(dbCloseArea())
	Endif
	IF SELECT("SRD1") > 0
		SRD1->(dbCloseArea())
	Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBusPerMed ºAutor  ³Tiago Malta        º Data ³  29/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca os periodos anteriores para media                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fBusPerMed( cAliasSRA , nMeses , cPeriodo , cNumPg , nPerAtu )

Local aPerAberto  := {}
Local aPerFechado := {}
Local cMes        := ""
Local cAno        := ""
Local i           := 0
Local cPeriod     := ""
Local cMesAux     := ""
Local cAnoAux     := ""
Local cRoteiro    := ""
Local SumMes      := 0

IF nPerAtu == 1
	SumMes := 1
ELSE
	SumMes := 0
ENDIF

	dbselectarea("RCF")
	RCF->( Dbsetorder(3) )
	IF RCF->( Dbseek( xFilial("RCF") + (cAliasSRA)->RA_PROCES + cPeriodo + cNumPg ) )

		cMes := cMesAux := RCF->RCF_MES
		cAno := cAnoAux := RCF->RCF_ANO

		cMesAux := STRzero( VAL(cMesAux) - nMeses + SumMes ,2 )

		IF VAL(cMesAux) <= 0
			cMesAux := STRzero( VAL(cMesAux) + 12  , 2)
		ENDIF

		IF VAL(cMesAux) > VAL(cMes)
			cAnoAux := Alltrim(STR(VAL(cAnoAux) - 1))
		ENDIF

		while (cAnoAux+cMesAux) < (cAno+cMes)

			fRetPerComp(cMesAux, cAnoAux , NIL, (cAliasSRA)->RA_PROCES , cRoteiro, @aPerAberto, @aPerFechado)

			For i=1 to len(aPerFechado)
				cPeriod += "SRD.RD_PERIODO = '" + aPerFechado[i][1] + "' AND SRD.RD_SEMANA = '" + aPerFechado[i][2] + "' OR "
			Next i

			IF (cAnoAux+ STRzero( VAL(cMesAux) + 1 , 2) ) == (cAno+cMes)
			     cPeriod := SUBSTR(cPeriod, 1 , LEN(cPeriod) -3 )
			ENDIF

			IF cMesAux == "12"
				cMesAux := "01"
				cAnoAux := Alltrim(STR(VAL(cAnoAux) + 1))
			ELSE
				cMesAux := SOMA1(cMesAux)
			ENDIF

			IF (cAnoAux+cMesAux) == (cAno+cMes)
				IF "OR" $ SUBSTR(cPeriod, LEN(cPeriod)-2 , 4 )
				     cPeriod := SUBSTR(cPeriod, 1 , LEN(cPeriod) -3 )
				ENDIF
			ENDIF

		Enddo


		IF !empty(cPeriod)
			cPeriod := "%(" + cPeriod + ") AND %"
		Endif


    ENDIF

Return( cPeriod )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaPerAt  ºAutor  ³Tiago Malta      º Data ³  30/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca as informações do periodo atual para media           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fBuscaPerAt( cAliasSRA , cAliasSRD , cOrdemSRD ,cInner , cInnerC , oSectionP , cPeriodo , cNumPg )

Local cMes          := ""
Local cAno          := ""
Local cRoteiro      := ""
Local aPerAberto    := {}
Local aPerFechado   := {}
Local i             := {}
Local cOrdemSRC     := "%RC_FILIAL, RC_MAT, RC_PD%"
Local cValue        := ""

    dbselectarea("RCF")
	RCF->( Dbsetorder(3) )
	IF RCF->( Dbseek( xFilial("RCF") + (cAliasSRA)->RA_PROCES + cPeriodo + cNumPg ) )

		cMes := RCF->RCF_MES
		cAno := RCF->RCF_ANO

		fRetPerComp(cMes, cAno , NIL, (cAliasSRA)->RA_PROCES , cRoteiro, @aPerAberto, @aPerFechado)

		IF LEN(aPerAberto) > 0

		    For i=1 to len(aPerAberto)

			  	IF SELECT(cAliasSRD) > 0
	  				(cAliasSRD)->( dbclosearea() )
	  			ENDIF

		 		BeginSql alias cAliasSRD
					SELECT RC_PERIODO AS RD_PERIODO , RC_PD AS RD_PD , RC_HORAS AS RD_HORAS , RC_VALOR AS RD_VALOR
					FROM       %table:SRC% SRC
					INNER JOIN %table:SRV% SRV
					ON  %exp:cInnerC%
					WHERE SRC.RC_MAT     = %exp: (cAliasSRA)->RA_MAT % AND
						  SRC.RC_PERIODO = %exp: aPerAberto[i][1]    % AND
						  SRC.RC_SEMANA  = %exp: aPerAberto[i][2]    % AND
						  SRC.%notDel%                                 AND
						  SRV.%notDel%
						  ORDER BY %exp:cOrdemSRC%
				EndSql

				cValue := oSectionP:Cell("RD_DATARQ"):GetValue(.T.)

				(cAliasSRD)->(DBGOTOP())
				While (cAliasSRD)->(!EOF())
					oSectionP:Cell("RD_DATARQ"):SetValue(cAno + "/" + cMes)
					oSectionP:PrintLine()
					(cAliasSRD)->(DBSKIP())
				ENDDO

		    Next i
		    oSectionP:Cell("RD_DATARQ"):SetValue(cValue)
		ENDIF

		IF LEN(aPerFechado) > 0

		  	FOR i=1 to len(aPerFechado)

			  	IF SELECT(cAliasSRD) > 0
	  				(cAliasSRD)->( dbclosearea() )
	  			ENDIF

				BeginSql alias cAliasSRD
					SELECT *
					FROM       %table:SRD% SRD
					INNER JOIN %table:SRV% SRV
					ON  %exp:cInner%
					WHERE SRD.RD_MAT     = %exp: (cAliasSRA)->RA_MAT % AND
						  SRD.RD_PERIODO = %exp: aPerFechado[i][1]   % AND
						  SRD.RD_SEMANA  = %exp: aPerFechado[i][2]   % AND
						  SRD.%notDel%                                 AND
						  SRV.%notDel%
						  ORDER BY %exp:cOrdemSRD%
				EndSql

				(cAliasSRD)->(DBGOTOP())
				While (cAliasSRD)->(!EOF())
					oSectionP:PrintLine()
					(cAliasSRD)->(DBSKIP())
				ENDDO

			Next i

		ENDIF

	ENDIF

Return()
