#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR710.CH"

/*--------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TECR710
Relatorio - Livro de Registro de Armas
@author   Mário Augusto Cavenaghi - EthosX
@since    16/12/2020
@version  P12.1.27
@return   Nil
@perguntas:
	MV_PAR01 - Arma De
	MV_PAR02 - Arma Até
	MV_PAR03 - Local De
	MV_PAR04 - Local Até
	MV_PAR05 - Cofre De
	MV_PAR06 - Cofre Até
	MV_PAR07 - Situação: Todas / Ativa / Implantada / Em Manutenção / Furtada / Roubada / Extraviada / Apreendida / Recuperada / Desativada / Descartada
	MV_PAR08 - Exibe Arma S/ Localização?
	MV_PAR09 - Filiais

----------------------------------------------------------------------------------------------------------------------*/
Function TECR710()
	Local oReport
	Local cPerg := "TECR710"

	If TRepInUse() .And. Pergunte(cPerg, .T.)
		oReport := ReportDef() 
		oReport:SetLandScape(.T.)
		oReport:PrintDialog() 
	EndIf

Return

/*--------------------------------------------------------------------------------------------------------------------
{Protheus.doc} ReportDef 
Definição dos campos
@author   Mário Augusto Cavenaghi - EthosX
@since    16/12/2020
@version  P12.1.27
@return   oReport - Objeto report
----------------------------------------------------------------------------------------------------------------------*/
Static Function ReportDef()
	Local aCBox     := {}
	Local cCbox		:= Posicione("SX3", 2, "TE0_ESPEC", "X3_CBOX")
	Local cAlias    := GetNextAlias()
	Local cPerg     := "TECR710"
	Local cTitCNPJ  := Alltrim(GetSx3Cache("A1_CGC", "X3_TITULO"))
	Local oReport   := Nil	//	Objeto para armazenar a seção pai
	Local oSection1 := Nil	//	Objeto para armazenar a seção 1 do objeto pai
	Local oSection2 := Nil	//	Objeto para armazenar a seção 2 do objeto pai
	Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()

	If(!EMPTY(cCbox))
		aCBox := StrToKArr(Posicione("SX3", 2, "TE0_ESPEC", "X3_CBOX"), ";")
	EndIf
	//Relatório
	DEFINE REPORT oReport NAME STR0001 TITLE STR0002 ACTION {|oReport| PrintReport(oReport, cPerg, cAlias )}

	//Seção 1
	DEFINE SECTION oSection1 OF oReport TITLE STR0003 TABLES "SM0" BREAK HEADER

	//Células Seção 1
	DEFINE CELL NAME "Fili_Emp" OF oSection1 TITLE STR0004 SIZE Len(SM0->(M0_CODFIL + M0_NOMECOM)) BLOCK {|| AllTrim(SM0->(Alltrim(M0_CODFIL) + ": " + M0_NOMECOM))}
	DEFINE CELL NAME "CNPJ_Emp" OF oSection1 TITLE cTitCNPJ SIZE Len(Alltrim(X3Picture("A1_CGC")))  BLOCK {|| AllTrim(Transform(SM0->M0_CGC, X3Picture("A1_CGC")))}

 	//Seção 2
	DEFINE SECTION oSection2 OF oSection1 TITLE STR0005 TABLE "TE0" BREAK HEADER LEFT MARGIN 10
 
	//Células Seção 2
	DEFINE CELL NAME "TE0_COD"    OF oSection2 TITLE STR0006        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_COD}
	DEFINE CELL NAME "TE0_ESPEC"  OF oSection2 TITLE STR0007        ALIAS "TE0" SIZE 20 BLOCK {|| Iif(!EMPTY(cCBox),SubStr(aCBox[Val((cAlias)->TE0_ESPEC)], 3),TecSx5Desc("GS",(cAlias)->TE0_ESPEC))}
	DEFINE CELL NAME "TE0_MARCA"  OF oSection2 TITLE STR0008        ALIAS "TE0" BLOCK {|| Posicione("SX5", 1, xFilial("SX5") + "79" + (cAlias)->TE0_MARCA, "X5_DESCRI")}
	DEFINE CELL NAME "TE0_CALIBR" OF oSection2 TITLE STR0009        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_CALIBR}
	DEFINE CELL NAME "TE0_NUMREG" OF oSection2 TITLE STR0010        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_NUMREG}
	DEFINE CELL NAME "TE0_DTREG"  OF oSection2 TITLE STR0011        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_DTREG}
	DEFINE CELL NAME "TE0_MODELO" OF oSection2 TITLE STR0012	    ALIAS "TE0" BLOCK {|| (cAlias)->TE0_MODELO} // "Modelo da Arma"
	DEFINE CELL NAME "TE0_SINARM" OF oSection2 TITLE STR0013        ALIAS "TE0" SIZE 20 BLOCK {|| (cAlias)->TE0_SINARM}
	DEFINE CELL NAME "TE0_DOU"    OF oSection2 TITLE STR0014        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_DOU}
	DEFINE CELL NAME "TE0_DTDOU"  OF oSection2 TITLE STR0015        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_DTDOU}
	DEFINE CELL NAME "TE0_SITUA"  OF oSection2 TITLE STR0016        ALIAS "TE0" BLOCK {|| Posicione("SX5", 1, xFilial("SX5") + "82" + (cAlias)->TE0_SITUA, "X5_DESCRI")}

	DEFINE CELL NAME "TE0_ENTIDA" OF oSection2 TITLE STR0019        ALIAS "TE0" BLOCK {|| (cAlias)->TE0_ENTIDA } // "Loc.Destino"

	If lMultFil
		DEFINE CELL NAME "TE0_FILLOC" OF oSection2 TITLE STR0022 ALIAS "TE0" BLOCK {|| (cAlias)->TE0_FILLOC } // "Fil.Loc" 
	Endif

	DEFINE CELL NAME "TE0_LOCAL" OF oSection2 TITLE STR0023 ALIAS "TE0" SIZE 15 BLOCK {|| (cAlias)->TE0_LOCAL} //"Cod.loc"
	DEFINE CELL NAME "TE0_CLIDES" OF oSection2 TITLE STR0017 ALIAS "TE0" BLOCK {|| (cAlias)->TE0_CLIDES}

	DEFINE FUNCTION FROM oSection2:Cell("TE0_COD") OF oSection1 FUNCTION COUNT TITLE STR0018 NO END SECTION

Return oReport

/*--------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PrintReport
Função responsável pela impressão do relatório
@author   Mário Augusto Cavenaghi - EthosX
@since    16/12/2020
@version  P12.1.27
@return   Nil
----------------------------------------------------------------------------------------------------------------------*/
Static Function PrintReport(oReport, cPerg, cAlias)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oSection1:Section(1)
	Local cCLiente	:= STR0020 // 'Local Atendimento'
	Local cEmpresa	:= STR0021	// 'Local Interno'
	Local cWhereUN	:= ""
	Local cWhere    := ""	//	String contendo a expressão utilizada na query
	Local cSituac	:= ""
	Local cFiliais 	:= ""
	Local cBetween  := Replicate("Z", Len(TE0->TE0_LOCAL))
	Local lMultFil 	:= TE0->(ColumnPos("TE0_FILLOC")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
	Local cSlc		:= "%%"

	MakeSqlExpr(cPerg)

	If lMultFil
		cSlc := "%, TE0.TE0_FILLOC %"
	Endif
	
	//	Arma
	If !Empty("MV_PAR01")
		cWhere += " TE0_COD >= '" + MV_PAR01 + "' "
	Endif
	If Empty("MV_PAR02")
		MV_PAR02 := cBetween
	Endif

	cWhere += Iif(!Empty(cWhere), " AND ", "") + "TE0_COD <= '" + MV_PAR02 + "' "

	//	Local Atendimento
	If !Empty("MV_PAR03")
		cWhereUN += " (( TE0_LOCAL >= '" + MV_PAR03 + "' "
	Endif
	If Empty("MV_PAR04")
		MV_PAR04 := cBetween
	Endif
	cWhereUN += " AND TE0_LOCAL <= '" + MV_PAR04 + "' )"

	//	Cofre
	If !Empty("MV_PAR05")
		cWhereUN += " OR ( TE0_LOCAL >= '" + MV_PAR05 + "' "
	Endif
	If Empty("MV_PAR06")
		MV_PAR06 := cBetween
	Endif
	cWhereUN += " AND TE0_LOCAL <= '" + MV_PAR06 + "' ))"

	//	Situação
	If !Empty(MV_PAR07)
		If "IN" $ MV_PAR07 .OR. "BETWEEN" $ MV_PAR07
			cSituac := RIGHT(MV_PAR07, LEN(MV_PAR07) - 1)
			cSituac := LEFT(cSituac, LEN(cSituac) - 1)
			
			If AT('TE0_SITUA',MV_PAR07) > 0
				cWhere += " AND " + cSituac + " "
			Else
				cWhere += " AND TE0_SITUA " + cSituac + " "
			EndIf
		Else
			cWhere += " AND TE0_SITUA ='" + MV_PAR07 + "' "
		EndIf
	EndIf
	
	If TecHasPerg("MV_PAR08", cPerg) .AND.  MV_PAR08 == 2
		cWhere += " AND TE0_LOCAL <> '' "
	EndIf
	
	If lMultFil .AND. TecHasPerg("MV_PAR09", cPerg) .AND. !Empty(MV_PAR09)
		cFiliais := RIGHT(MV_PAR09, LEN(MV_PAR09) - 1)
		cFiliais := LEFT(cFiliais, LEN(cFiliais) - 1)
		If AT('TE0_FILLOC',MV_PAR09) > 0
			cWhere += " AND " + cFiliais + " "
		Else
			cWhere += " AND TE0_FILLOC " + cFiliais + " "
		EndIf
	EndIf
	
	cWhere := "%" + cWhere + "%"
		cWhereUN := "%" + cWhereUN + "%"

	BEGIN REPORT QUERY oSection2
		BeginSql Alias cAlias
			SELECT TE0.TE0_COD, TE0.TE0_ESPEC, TE0.TE0_MARCA, TE0.TE0_CALIBR, TE0.TE0_NUMREG, TE0.TE0_DTREG, TE0.TE0_MODELO, 
			TE0.TE0_SINARM, TE0.TE0_DOU, TE0.TE0_DTDOU, TE0.TE0_SITUA, TE0.TE0_LOCAL,TE0.TE0_CLIDES,
			CASE WHEN TE0.TE0_ENTIDA = 'ABS' THEN %Exp:cCLiente% WHEN TE0.TE0_ENTIDA = 'TER' THEN %Exp:cEmpresa% ELSE '' END TE0_ENTIDA %Exp:cSlc%
			FROM   %Table:TE0% TE0
			WHERE  %Exp:cWhereUN%
			AND	%Exp:cWhere%
			AND    TE0.TE0_FILIAL= %xfilial:TE0%  
			AND    TE0.%NotDel%
			ORDER  BY TE0_COD

		EndSql
	END REPORT QUERY oSection2

	oSection1:EndQuery()
	oSection1:SetParentQuery(.F.)
	oSection1:Init()
	oSection1:PrintLine()
	oSection2:SetParentQuery(.F.)
	While !(cAlias)->(EOF())
		oSection2:Init()
		oSection2:PrintLine()
		(cAlias)->(dbSkip())
	Enddo
	oSection2:Finish()
	oSection1:Finish()

Return Nil
