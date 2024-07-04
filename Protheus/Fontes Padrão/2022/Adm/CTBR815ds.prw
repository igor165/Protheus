#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "ctbr815.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  C815ds  ³ Autor ³Jesus Peñaloza         ³ Data ³ 10/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informe Balance Patrimonial (Birt)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³jonathan glz³08/09/15³TTHAMD³Se cambia la forma de imprimir el archivo ³±±
±±³            ³        ³      ³Termino Auxiliares para que no permita    ³±±
±±³            ³        ³      ³imprimir archivo mayoresa 2 mil caracteres³±±
±±³jonathan glz³23/10/15³TTKUXV³Se cambia la manera de usar la instruccion³±±
±±³            ³        ³      ³dbselectarea() para archivos temporales y ³±±
±±³            ³        ³      ³se pase la variable cArqTmp entre comillas³±±
±±³            ³        ³      ³al momento de hacer el dbselectarea().    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset C815ds
	title STR0001 //Balance Patrimonial
	description STR0001 //Balance Patrimonial
	PERGUNTE "CTR500"

columns
	//Columnas de Activo
	define column ATIVO      type character size 30   label STR0002 //Activo
	define column ASEMESTRE  type character size 25   label STR0003 //Semestre
	define column AEXERCICIO type character size 25   label STR0004 //Ejercicio
	define column AEXERANT   type character size 25   label STR0005 //Anterior
	//Columnas de Pasivo
	define column PASSIVO    type character size 30   label STR0006 //Pasivo
	define column PSEMESTRE  type character size 25   label STR0003 //Semestre
	define column PEXERCICIO type character size 25   label STR0004 //Ejercicio
	define column PEXERANT   type character size 25   label STR0005 //Anterior
	define column TIPORES    type character size 1    label ""
	define column TAMAUX     type character size 2000 label STR0015 //"Arq. Aux."
	define column IMAGE      type character size 30   label STR0016 //"Imagen"
	define column NPAGI      type numeric   size 6    label STR0017 //"Num Pag."
	define column TITULO     type character size 30   label STR0018 //"Tituto"

define query "SELECT TITULO, ATIVO, ASEMESTRE, AEXERCICIO, AEXERANT, PASSIVO, PSEMESTRE, "+;
                     "PEXERCICIO, PEXERANT, TIPORES, TAMAUX, IMAGE, NPAGI "+;
             "FROM %WTable:1% "

process dataset
	Local cWTabAlias
	Local lRet       := .F.
	Local dFinal 	   := CTOD(SPACE(8))

	Private cEjerCont  := self:execParamValue("MV_PAR01")
	Private cCodigo    := self:execParamValue("MV_PAR02")
	Private cMoneda    := self:execParamValue("MV_PAR03")
	Private nSemestre  := self:execParamValue("MV_PAR04")
	Private nInicio    := self:execParamValue("MV_PAR05")
	Private nAuxiliar  := self:execParamValue("MV_PAR06")
	Private cPathAuxi  := self:execParamValue("MV_PAR07")
	Private nSaldoCer  := self:execParamValue("MV_PAR08")
	Private dFecha     := self:execParamValue("MV_PAR09")
	Private nPerAnt    := self:execParamValue("MV_PAR10")
	Private cDescMon   := self:execParamValue("MV_PAR11")
	Private cTipoSal   := self:execParamValue("MV_PAR12")
	Private nTitulo    := self:execParamValue("MV_PAR13")
	Private nSucursal  := self:execParamValue("MV_PAR14")
	Private aSelFil    := {}

	if ::isPreview()
	endif

	cWTabAlias := ::createWorkTable()

	Processa({|_lEnd| lRet := ReportPrint(cWTabAlias, cEjerCont, cCodigo, cMoneda, nSemestre, nInicio, nAuxiliar, cPathAuxi, nSaldoCer, dFecha, nPerAnt, cDescMon, cTipoSal, nTitulo, nSucursal, dFinal)}, ::title())
	if !lRet
		MsgInfo(STR0007) //"No existen datos dentro de los rangos seleccionados"
	else
		MsgInfo(STR0019) //"Impresion Terminada"
	endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportPrint³Autor ³ Jesus Peñaloza        ³ Data ³10/12/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el Reporte de Balance Patrimonial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportPrint(cExp1, cExp2, cExp3, cExp4, cExp5)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExp1.- Nombre de tabla temporal que guardara el resultado ³±±
±±³Parametros³ cExp2.- Ejercicio contable                                 ³±±
±±³          ³ cExp3.- Codigo                                             ³±±
±±³          ³ cExp4.- Copdigo Moneda                                     ³±±
±±³          ³ nExp5.- Semestre                                           ³±±
±±³          ³ nExp6.- Pag. Inicio                                        ³±±
±±³          ³ cExp7.- Termino Auxiliar                                   ³±±
±±³          ³ nExp8.- Saldo cerado                                       ³±±
±±³          ³ dExp9.- Fecha                                              ³±±
±±³          ³ nExp10- Periodo anterior                                   ³±±
±±³          ³ cExp11- Descripcion moneda                                 ³±±
±±³          ³ cExp12- Tipo Saldo                                         ³±±
±±³          ³ nExp13- Titulo                                             ³±±
±±³          ³ nExp14- Numero sucursal                                    ³±±
±±³          ³ nExp15- Fecha final                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR472                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(cWTabAlias, cEjerCont, cCodigo, cMoneda, nSemestre, nInicio, nAuxiliar, cPathAuxi, nSaldoCer, dFecha, nPerAnt, cDescMon, cTipoSal, nTitulo, nSucursal, dFinal)
	local aArea	   	:= GetArea()
	Local aSetOfBook	:= CTBSetOf(cCodigo)
	Local aCtbMoeda	:= {}
	Local lin 			:= 2301
	Local aMaxCol		:= {	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
								{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
	Local aColunas	:= { {}, {} }
	Local nMaxCol 	:= 0
	Local nPosCol		:= 0
	Local nColuna		:= 0
	Local nCelula		:= 0
	Local lPeriodoAnt	:= (nPerAnt == 1)
	Local lColuna		:= .F.
	Local cTpValor	:= GetMV("MV_TPVALOR")
	Local lImpTrmAux	:= (nAuxiliar == 1)
	Local cArqTrm		:= ""
	Local aTamVal		:= TAMSX3("CT2_VALOR")
	Local cMoedaDesc	:= cDescMon // RFC - 22/01/07 - BOPS 103653
	Local lRet 		:= .F.
	Local nCount 		:= 0
	Local cREPORT		:= "CTBR500"
	Local cTITULO		:= Capital(STR0001) // BALANCOS PATRIMONIAIS
	Local aTamDesc	:= TAMSX3("CTS_DESCCG")
	Local nTamAux		:= 10
	Local dFinal 		:= CTOD(SPACE(8))
	Local cTamAux		:= ""
	Local cArqTmp
	Local cPicture
	Local lSemestre
	Local aPosCol

	Private aDatos := {.f., ""}

		If Valtype(nTitulo)=="N" .And. (nTitulo == 1)
			cTitulo := CTBNomeVis( aSetOfBook[5] )
		EndIf

		//Filtra Filiais
		If nSucursal == 1 .And. Len( aSelFil ) <= 0
			aSelFil := AdmGetFil()
		EndIf
		If Empty(dFecha)
			While CTG->(! Eof()) .and. CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = cEjerCont
				dFinal	:= CTG->CTG_DTFIM
				CTG->(DbSkip())
			EndDo
		Else
			dFinal:= dFecha
		EndIf

		nAno := year(dFinal)

		If nSemestre = 1
			cTitCol := ""
		Else
			cTitCol	:= Dtoc(dFinal)
		Endif

		If Empty(CTBSetOf(cCodigo)[5])
			ApMsgAlert(STR0011) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao
			                    //livro. Verifique a configuracao de livros escolhida !"
			Return .F.
		Endif

		If nSemestre = 1 .And. Month(dFinal) > 6
			dSemestre := Ctod("30/06/" + Str(Year(dFinal), 4))
		Endif

		If !lPeriodoAnt
			dFinalA := dFinal-1
		ElseIf  Substr(dtoc(dFinal),1,5) == "29/02" // Validacao para anos bissextos
			dFinalA := Ctod("28/02/" + Str(Year(dFinal) - 1, 4))
		Else
			dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
		Endif

		lSemestre	:= nSemestre = 1 .And. Month(dFinal) > 6

		aPosCol		:= {	{  175, If(lSemestre, 740 ,), 1050, If(lPeriodoAnt,1370,), 1630 },;
							{ 1695, If(lSemestre, 2220,), 2540, If(lPeriodoAnt,2860,), 3120 }	}

		aCtbMoeda := CtbMoeda(cMoneda, aSetOfBook[9])
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			Return .F.
		Endif

		nDecimais 	:= DecimalCTB(aSetOfBook,cMoneda)
		cPicture 	:= aSetOfBook[4]

		lComNivel	:= .T.

		//Monta Arquivo Temporario para Impressao
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
								dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
				   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
				   				"",Repl("Z", Len(CTH->CTH_CLVL)),cMoneda,;
				   				cTipoSal,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
				   				,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
					STR0012, cTitulo) //"Criando Arquivo Temporario..."

		dbSelectArea("cArqTmp")
		dbGoTop()
		lColuna	:= FieldPos("COLUNA") > 0

		#DEFINE C_CONTA			1
		#DEFINE C_DESC			2
		#DEFINE C_SITNORMAL		3
		#DEFINE C_NIVEL    		4
		#DEFINE C_IDENTIFI		5
		#DEFINE C_SALDOS  		5
		#DEFINE C_SALDOSEM		6
		#DEFINE C_SALDOATU		7
		#DEFINE C_SALDOANT		8
		#DEFINE C_TOTAL   		9

		While !Eof()
			If lColuna
				If COLUNA < 2
					nColuna := 1
				Else
					nColuna := 2
				Endif
			Else
				nColuna := 1
			Endif
			If IDENTIFI = "4"
				aMaxCol[nColuna][C_CONTA] 		:= CONTA
				aMaxCol[nColuna][C_DESC] 		:= DESCCTA
				aMaxCol[nColuna][C_SITNORMAL]	:= NORMAL
				aMaxCol[nColuna][C_NIVEL]		:= NIVEL
				aMaxCol[nColuna][C_IDENTIFI]	:= "4"
				aMaxCol[nColuna][C_SALDOANT] 	+= SALDOANT
				aMaxCol[nColuna][C_SALDOATU] 	+= SALDOATU
				If lSemestre
					aMaxCol[nColuna][C_SALDOSEM] += SALDOSEM
				Endif
			Else
				Aadd(aColunas[nColuna], { 	CONTA, DESCCTA, NORMAL, NIVEL, IDENTIFI,;
											If(lSemestre, SALDOSEM, 0), SALDOATU, SALDOANT })
				aMaxCol[nColuna][C_TOTAL] ++
			Endif
			DbSkip()
		EndDo

		If aMaxCol[1][C_TOTAL] > aMaxCol[2][C_TOTAL]
			nMaxCol := aMaxCol[1][C_TOTAL]
		Else
			nMaxCol := aMaxCol[2][C_TOTAL]
		Endif

		dbSelectArea("cArqTmp")
		Set Filter To
		dbCloseArea()
		If Select(cArqTmp) == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIF
		dbselectArea("CT2")

		nCol1Pos	:= 0
		nCol2Pos	:= 0
		RecLock(cWTabAlias, .T.)
			(cWTabAlias)->TITULO  := UPPER(cTitulo)
			(cWTabAlias)->ATIVO   := STR0008 //"Activo (En $)"
			(cWTabAlias)->PASSIVO := STR0009 //"Pasivo +"
			(cWTabAlias)->TIPORES := "0"
			(cWTabAlias)->IMAGE   := "lgrl"+cEmpAnt+".bmp"
			(cWTabAlias)->NPAGI   := nInicio
			If !lSemestre .and. !lPeriodoAnt
				(cWTabAlias)->AEXERCICIO := DTOC(dFinal)
				(cWTabAlias)->PEXERCICIO := DTOC(dFinal)
			EndIf
			If lSemestre .and. !lPeriodoAnt
				(cWTabAlias)->AEXERCICIO := STR0004 //Ejercicio
				(cWTabAlias)->ASEMESTRE  := Alltrim(str(Year(dFinal)))
				(cWTabAlias)->PEXERCICIO := STR0004 //Ejercicio
				(cWTabAlias)->PSEMESTRE  := Alltrim(str(Year(dFinal)))
			EndIf
			If !lSemestre .and. lPeriodoAnt
				(cWTabAlias)->AEXERCICIO := DTOC(dFinal)
				(cWTabAlias)->AEXERANT   := DTOC(dFinalA)
				(cWTabAlias)->PEXERCICIO := DTOC(dFinal)
				(cWTabAlias)->PEXERANT   := DTOC(dFinalA)
			EndIf
			If lSemestre .and. lPeriodoAnt
				(cWTabAlias)->ASEMESTRE  := Alltrim(str(Year(dFinal)))
				(cWTabAlias)->AEXERCICIO := STR0004 //Ejercicio
				(cWTabAlias)->AEXERANT   := Alltrim(str(YEAR(dFinalA)))
				(cWTabAlias)->PSEMESTRE  := Alltrim(str(Year(dFinal)))
				(cWTabAlias)->PEXERCICIO := STR0004 //Ejercicio
				(cWTabAlias)->PEXERANT   := Alltrim(str(YEAR(dFinalA)))
			EndIf
		(cWTabAlias)->(MsUnlock())

		RecLock(cWTabAlias, .T.)
			(cWTabAlias)->TIPORES    := "0"
			(cWTabAlias)->PASSIVO    := STR0010 //"Patrimonio Neto (En $)"
			(cWTabAlias)->AEXERCICIO := ""
			(cWTabAlias)->PEXERCICIO := ""
			(cWTabAlias)->AEXERANT   := ""
			(cWTabAlias)->PEXERANT   := ""
			If lSemestre .and. !lPeriodoAnt
				(cWTabAlias)->ASEMESTRE := STR0003 //Semestre
				(cWTabAlias)->PSEMESTRE := STR0003 //Semestre
			EndIf
			If lSemestre .and. lPeriodoAnt
				(cWTabAlias)->ASEMESTRE := STR0003 //Semestre
				(cWTabAlias)->PSEMESTRE := STR0003 //Semestre
				(cWTabAlias)->AEXERANT  := STR0004 //Ejercicio
				(cWTabAlias)->PEXERANT  := STR0004 //Ejercicio
			EndIf
		(cWTabAlias)->(MsUnlock())
		aTamVal[1] += 8

		For nColuna := 1 To nMaxCol
			nCol1Pos++
			nCol2Pos++
			nCount++
			RecLock(cWTabAlias, .T.)
			If nCol1Pos > Len(aColunas[1]) .and. nCol2Pos > Len(aColunas[2])
				Exit
			Endif

			If 	(nColuna <= Len(aColunas[1]) .And. aColunas[1][nColuna][C_DESC] = "-") .Or.;
				(nColuna <= Len(aColunas[2]) .And. aColunas[2][nColuna][C_DESC] = "-")
			Else
				If nSaldoCer <> 1				/// Se Imprime Valor Zerado = Não
					/// LOCALIZA A PROXIMA LINHA COM VALOR NA COLUNA 1
				 	While nCol1Pos <= Len(aColunas[1]) .and. (aColunas[1][nCol1Pos][C_SALDOS + 2] == 0 .And. aColunas[1][nCol1Pos][C_SALDOS + 3] == 0)
						If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"
							If aColunas[1][nCol1Pos][C_SALDOS + 2] <> 0 .OR. aColunas[1][nCol1Pos][C_NIVEL]==1				/// SE O SALDO ATUAL NAO ESTIVER ZERADO OU FOR SINTETICA
								Exit
							EndIf
						EndIf
						nCol1Pos++
					EndDo

					/// LOCALIZA A PROXIMA LINHA COM VALOR NA COLUNA 2
					While nCol2Pos <= Len(aColunas[2]) .and. (aColunas[2][nCol2Pos][C_SALDOS + 2] == 0 .And. aColunas[2][nCol2Pos][C_SALDOS + 3] == 0)
						If aColunas[2][nCol2Pos][C_IDENTIFI] < "5"
							If aColunas[2][nCol2Pos][C_SALDOS + 2] <> 0  .OR. aColunas[2][nCol2Pos][C_NIVEL]==1 				/// SE O SALDO ATUAL NAO ESTIVER ZERADO
								Exit
							Endif
						Endif
					  	nCol2Pos++
					EndDo
				Endif

		// 1. Coluna
				If nCol1Pos <= Len(aColunas[1])
					(cWTabAlias)->ATIVO := aColunas[1][nCol1Pos][C_DESC]
					If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"
						For nPosCol := 2 To Len(aPosCol[1]) - 1
							If aPosCol[1][nPosCol] # Nil
								nCelula := ( C_SALDOS + nPosCol - 1 )
								If nCelula == 6 .And. lSemestre
									(cWTabAlias)->ASEMESTRE := ValorCTB( aColunas[1][nCol1Pos][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F. )
								ElseIf nCelula == 7
									(cWTabAlias)->AEXERCICIO := ValorCTB( aColunas[1][nCol1Pos][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F. )
								ElseIf nCelula == 8 .And. lPeriodoAnt
									(cWTabAlias)->AEXERANT := ValorCTB( aColunas[1][nCol1Pos][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F. )
								EndIf
							Endif
						Next
					//Somente para Linha Sem Valor
					ElseIf aColunas[1][nCol1Pos][C_IDENTIFI] == "5"
						For nPosCol := 2 To Len(aPosCol[1]) - 1

							If aPosCol[1][nPosCol] # Nil

								nCelula := ( C_SALDOS + nPosCol - 1 )

								If nCelula == 6 .And. lSemestre
									(cWTabAlias)->ASEMESTRE := ""
								ElseIf nCelula == 7
									(cWTabAlias)->AEXERCICIO := " "
								ElseIf nCelula == 8 .And. lPeriodoAnt
									(cWTabAlias)->AEXERANT := " "
								EndIf
							Endif
						Next
					Endif
				Endif

		// 2. Coluna
				If nCol2Pos <= Len(aColunas[2])
					(cWTabAlias)->PASSIVO := aColunas[2][nCol2Pos][C_DESC]
					If aColunas[2][nCol2Pos][C_IDENTIFI] < "5"
						For nPosCol := 2 To Len(aPosCol[1]) - 1
							If aPosCol[2][nPosCol] # Nil
								nCelula := ( C_SALDOS + nPosCol - 1 )
								If nCelula == 6 .And. lSemestre
									(cWTabAlias)->PSEMESTRE := ValorCTB( aColunas[2][nCol2Pos][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F. )
								ElseIf nCelula == 7
									(cWTabAlias)->PEXERCICIO := ValorCTB( aColunas[2][nCol2Pos][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F. )
								ElseIf nCelula == 8 .And. lPeriodoAnt
									(cWTabAlias)->PEXERANT := ValorCTB( aColunas[2][nCol2Pos][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
											aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F. )
								EndIf
							Endif
						Next

					ElseIf aColunas[2][nCol2Pos][C_IDENTIFI] == "5"
						For nPosCol := 2 To Len(aPosCol[1]) - 1
							If aPosCol[2][nPosCol] # Nil
								nCelula := ( C_SALDOS + nPosCol - 1 )
								If nCelula == 6 .And. lSemestre
									(cWTabAlias)->PSEMESTRE := " "
								ElseIf nCelula == 7
									(cWTabAlias)->PEXERCICIO := " "
								ElseIf nCelula == 8 .And. lPeriodoAnt
									(cWTabAlias)->PEXERANT := " "
								EndIf
							Endif
						Next
					Endif
				Endif

				If nCol1Pos > Len( aColunas[1] )
					(cWTabAlias)->ATIVO := ""
					(cWTabAlias)->AEXERCICIO := ""
					If lSemestre
						(cWTabAlias)->ASEMESTRE := ""
					EndIf
					If lPeriodoAnt
						(cWTabAlias)->AEXERANT := ""
					EndIf
				EndIf
				If nCol2Pos > Len( aColunas[2] )
					(cWTabAlias)->PASSIVO := ""
					(cWTabAlias)->PEXERCICIO := ""
					If lSemestre
						(cWTabAlias)->PSEMESTRE := ""
					EndIf
					If lPeriodoAnt
						(cWTabAlias)->PEXERANT := ""
					EndIf
				EndIf
			Endif
			(cWTabAlias)->TIPORES := "1"
			(cWTabAlias)->(MsUnlock())
		Next

		// 1 Coluna
		RecLock(cWTabAlias, .T.)
		(cWTabAlias)->ATIVO := aMaxCol[1][C_DESC]

		nColuna2 := 2

		For nPosCol := 2 To Len(aPosCol[1])

			nCelula := (C_SALDOS + nPosCol - 1)

			If ( aPosCol[1][nPosCol] <> Nil ) .And. ( nCelula < Len(aMaxCol[1]) )
				If nCelula == 6 .And. lSemestre
					(cWTabAlias)->ASEMESTRE := ValorCTB( aMaxCol[1][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F. )
				ElseIf nCelula == 7
					(cWTabAlias)->AEXERCICIO := ValorCTB( aMaxCol[1][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F. )
				ElseIf nCelula == 8 .And. lPeriodoAnt
					(cWTabAlias)->AEXERANT := ValorCTB( aMaxCol[1][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F. )
				EndIf
			Endif
		Next

		// 2 Coluna
		(cWTabAlias)->PASSIVO := aMaxCol[2][C_DESC]

		For nPosCol := 2 To Len(aPosCol[2])
			nCelula := (C_SALDOS + nPosCol - 1)
			If ( aPosCol[2][nPosCol] <> Nil ) .And. ( nCelula < Len(aMaxCol[2]) )
				If nCelula == 6 .And. lSemestre
					(cWTabAlias)->PSEMESTRE := ValorCTB( aMaxCol[2][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F. )
				ElseIf nCelula == 7
					(cWTabAlias)->PEXERCICIO := ValorCTB( aMaxCol[2][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F. )
				ElseIf nCelula == 8 .And. lPeriodoAnt
					(cWTabAlias)->PEXERANT := ValorCTB( aMaxCol[2][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
							aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F. )
				EndIf
			Endif
		Next

		If Len( aPosCol[1] ) > Len( aPosCol[2] )
			(cWTabAlias)->PASSIVO := ""
			(cWTabAlias)->PEXERCICIO := ""
			If lSemestre
				(cWTabAlias)->PSEMESTRE := ""
			EndIf
			If lPeriodoAnt
				(cWTabAlias)->PEXERANT := ""
			EndIf
		ElseIf Len( aPosCol[2] ) > Len( aPosCol[1] )
			(cWTabAlias)->ATIVO := ""
			(cWTabAlias)->AEXERCICIO := ""
			If lSemestre
				(cWTabAlias)->ASEMESTRE := ""
			EndIf
			If lPeriodoAnt
				(cWTabAlias)->AEXERANT := ""
			EndIf
		EndIf
		(cWTabAlias)->TIPORES := "2"
		(cWTabAlias)->(MsUnlock())

		//Valida si se imprimira el archivo de Termo Aux.
		If lImpTrmAux

			while !aDatos[1]
				aDatos := {.f.,""}
				ValTermCTB("CTR500")
			enddo

			RecLock(cWTabAlias, .T.)
				(cWTabAlias)->TAMAUX  := aDatos[2]
				(cWTabAlias)->TIPORES := "2"
			(cWTabAlias)->(MsUnlock())

		Endif
	RestArea( aArea )
Return .T.
