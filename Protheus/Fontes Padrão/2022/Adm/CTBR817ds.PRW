#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "CTBR817.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBR817ds ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 15.12.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza la definicion del datase que sera utiliza para       ³±±
±±³          ³ contener los datos obtenidos apartir de los parametros       ³±±
±±³          ³ proporcionados en por el usario.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (void)                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³jonathan glz³08/09/2015³TTHAMD³Se cambia la forma de imprimir el archivo ³±±
±±³            ³          ³      ³Termino Auxiliares para que no permita    ³±±
±±³            ³          ³      ³imprimir archivo mayoresa 2 mil caracteres³±±
±±³jonathan glz³23/10/2015³TTKUXV³Se cambia la manera de usar la instruccion³±±
±±³            ³          ³      ³dbselectarea() para archivos temporales y ³±±
±±³            ³          ³      ³se pase la variable cArqTmp entre comillas³±±
±±³            ³          ³      ³al momento de hacer el dbselectarea().    ³±±
±±³Jonathan Glz³30/06/2017³MMI-  ³Se cambia el grupo de preguntas se crean  ³±±
±±³            ³          ³  6119³los grupos CTBR817A y CTBR817B, se cambia ³±±
±±³            ³          ³      ³las validaciones y el titulo del reporte. ³±±
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset C085ds
	title STR0002 //DEMOSTRACION DEL FLUJO DE CAJA
	description STR0004 // Imprimiera la Demostracion del flujo de caja de acuerdo con los parametros que el usuario selecciono.
	Pergunte "CTR817B"

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define las columnas del dataset dsVen.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
columns
	define column COLUM1   TYPE CHARACTER  SIZE 40   LABEL STR0024 //NOMBRE EMP
	define column COLUM2   TYPE CHARACTER  SIZE 40   LABEL STR0025 //REG PATRONAL
	define column COLUM3   TYPE CHARACTER  SIZE 60   LABEL STR0026 //TITULO
	define column COLUM4   TYPE CHARACTER  SIZE 30   LABEL STR0027 //ANO FISCAL ANT
	define column COLUM5   TYPE CHARACTER  SIZE 30   LABEL STR0028 //ANO FISCAL ACT
	define column COLUM6   TYPE CHARACTER  SIZE 30   LABEL STR0029 //ANO FISCAL VAR
	define column COLUM7   TYPE CHARACTER  SIZE 30   LABEL STR0030 //ACT. OPERATIVA
	define column COLUM8   TYPE CHARACTER  SIZE 30   LABEL STR0031 //LUCRO NETE ANO
	define column COLUM9   TYPE CHARACTER  SIZE 30   LABEL STR0032 //IDENTIFICADOR
	define column COLUM10  TYPE CHARACTER  SIZE 30   LABEL STR0033 //CONCEPTO
	define column COLUM11  TYPE CHARACTER  SIZE 30   LABEL STR0034 //ANO ACTUAL
	define column COLUM12  TYPE CHARACTER  SIZE 30   LABEL STR0035 //ANO ANTERI
	define column COLUM13  TYPE CHARACTER  SIZE 30   LABEL STR0036 //VARIACION
	define column COLUM14  TYPE CHARACTER  SIZE 80   LABEL STR0037 //DESCRIPCION
	define column COLUM15  TYPE CHARACTER  SIZE 30   LABEL STR0038 //VAL ANO ACT
	define column COLUM16  TYPE CHARACTER  SIZE 30   LABEL STR0039 //VAL ANO ANT
	define column COLUM17  TYPE CHARACTER  SIZE 30   LABEL STR0040 //VAL VARIACION
	define column COLUM18  TYPE CHARACTER  SIZE 30   LABEL STR0041 //VAL ANO FIS ANT
	define column COLUM19  TYPE CHARACTER  SIZE 30   LABEL STR0042 //VAL ANO FIS ACT
	define column COLUM20  TYPE CHARACTER  SIZE 30   LABEL STR0043 //VAL ANO FIS VAR
	define column COLUM21  TYPE CHARACTER  SIZE 2000 LABEL STR0044 //ARCHIVO
	define column COLUM22  TYPE CHARACTER  SIZE 30   LABEL STR0045 //IMAGEN
	define column COLUM23  TYPE NUMERIC    SIZE 6    LABEL STR0046 //NUM PAG

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query, para la obtencion de informacion del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
define query "SELECT  COLUM1 , COLUM2 , COLUM3 , COLUM4 , COLUM5 , COLUM6 , COLUM7 , COLUM8 , COLUM9 , COLUM10, COLUM11, COLUM12,  "+;
                     "COLUM13, COLUM14, COLUM15, COLUM16, COLUM17, COLUM18, COLUM19, COLUM20, COLUM21, COLUM22, COLUM23 "+;
             "FROM   %WTable:1%  "

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se inicia la rutina de llenado del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
process dataset
	Local cWTabAlias
	Local lRet        := .F.

	Private dFinal     := StoD("")
	Private dFinalA    := StoD("")
	Private cTitulo    := ""
	Private aSetOfBook := {}
	Private aCtbMoeda  := {}
	Private aSelFil    := {}

	Private cEjrConta  := self:execParamValue("MV_PAR01") //ejercicio contable
	Private cCodConfL  := self:execParamValue("MV_PAR02") //Cod. Conf. libros
	Private cMoneda    := self:execParamValue("MV_PAR03") //moneda
	Private nPosAntLP  := self:execParamValue("MV_PAR04") //Pos. ant. L/P
	Private dFcGanPer  := self:execParamValue("MV_PAR05") //fch. ganancias/perdidas
	Private nDemosVar  := nMvPAR01 //dem. Varacion
	Private nNomInici  := self:execParamValue( "MV_PAR06" ) //nomina inicial
	Private dFcRefere  := self:execParamValue( "MV_PAR07" ) //fch ref.
	Private nPeriodo   := self:execParamValue( "MV_PAR08" ) //periodo
	Private nImprAuxi  := self:execParamValue( "MV_PAR09" ) //imp aux
	Private cPathAuxi  := self:execParamValue( "MV_PAR10" ) //path aux.
	Private nSalCerrs  := self:execParamValue( "MV_PAR11" ) //saldos cerrados
	Private nConsider  := self:execParamValue( "MV_PAR12" ) //considerar
	Private cDescMone  := self:execParamValue( "MV_PAR13" ) //desc. moneda
	Private nConSaldo  := self:execParamValue( "MV_PAR14" ) //consolidar saldos
	Private cSalConso  := self:execParamValue( "MV_PAR15" ) //saldos a consolidar
	Private cTipSaldo  := self:execParamValue( "MV_PAR16" ) //tipo saldo
	Private nMetodo    := nMvPAR02 //metodo
	Private nReslEjer  := self:execParamValue( "MV_PAR17" ) //resultados ejercicio
	Private nSalEjer   := self:execParamValue( "MV_PAR18" ) //saldos ejercicio
	Private nSalEjerA  := self:execParamValue( "MV_PAR19" ) //saldos ejercicio ant
	Private nTituloVi  := self:execParamValue( "MV_PAR20" ) //titulo vision
	Private nFiliales  := self:execParamValue( "MV_PAR21" ) //Selecciona Filiales

		if ::isPreview()
		endif

		// Faz a validacao das filiais
		If nFiliales == 1 .And. Len( aSelFil ) <= 0
			aSelFil := AdmGetFil()
		EndIf

		cWTabAlias := ::createWorkTable()
		chkFile("CTG")

		//Funcion para validar el diccionario contable.
		CTBR817R3()

		//Regla de avance de la impresion.
		Processa({|_lEnd| lRet := Ctr817Det(cWTabAlias, cTitulo)}, ::title())

		if !lRet
			MsgInfo(STR0020) //No hay datos que cumplan la condicion
		else
			MsgInfo(STR0001) // Impresion concluida satisfactoriamente
		endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR817R3 ³ Autor ³ Jonathan.gonzalez     ³ Data ³05/12/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para la validacion del calendario contable.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR817R3()
	Local lMovPeriodo := nConsider == 1
	local aArea       := GetArea()

		//faz a validacao do livro
		If !VdSetOfBook(cCodConfL,.T.)
			Return .F.
		Else
			aSetOfBook := CTBSetOf(cCodConfL)
			aCtbMoeda  := CtbMoeda(cMoneda, aSetOfBook[9])
		EndIf

		//valida moneda
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			Return .F.
		Endif

		//VAlida la impresion del  archivo Termino Auxiliar.
		if nImprAuxi == 1 .and. empty(cPathAuxi)
			msgAlert(STR0048,STR0047) //Seleccione un Archivo de Termino Auxiliar.## //¡Campo Vacio!
			Return .F.
		endif

		cTitulo := If(!Empty(aSetOfBook[10]),aSetOfBook[10],cTitulo)//"Titulo definido SetOfBook" /*Balance General*/

		//Valida si se desea utilizar el nombre de la vision en el titulo del informe.
		If (nTituloVi == 1)
			cTitulo := CTBNomeVis( aSetOfBook[5] ) //*Balance General*//
		EndIf

		//Valida si se considera el calendario todo o el periodo informado
		//en la fecha de referencia en la  impresion del informe.
		If nPeriodo == 1
			// SE DEVE CONSIDERAR TODO O CALENDARIO
			CTG->(dbSelectArea("CTG"))
			CTG->(dbSetOrder(1))
			CTG->(DbSeek(xFilial("CTG")+cEjrConta))
				//Valida Fecha de refencia para la impresion.
				If Empty(dFcRefere)
					While CTG->(! Eof()) .and. CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = cEjrConta
						dFinal	:= CTG->CTG_DTFIM
						CTG->(DbSkip())
					EndDo
				Else
					dFinal	:= dFcRefere
				EndIf

				dFinalA   := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
				cEjrConta := dFinal
			CTG->(dbCloseArea())
		Else
			// SE DEVE CONSIDERAR O PERIODO CONTABIL
			If Empty(dFcRefere)
				MsgInfo( STR0005, STR0006 )//"necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
				Return .F.
			Endif
			dFinal := dFcRefere

			CTG->(dbSetOrder(1))
			CTG->(DbSeek(xFilial("CTG")+cEjrConta))

			While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == cEjrConta
				If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
					dFinalA		:= CTG->CTG_DTINI
					If lMovPeriodo
						dFinalA		:= dFinalA - 1
					EndIf
					Exit
				Endif
				CTG->(DbSkip())
			EndDo

			CTG->(dbCloseArea())

			If Empty(dFinalA)
				MsgInfo( STR0007, STR0008 )//"Data fora do calendário !"#"Data de referência."
				Return .F.
			Endif
		EndIf
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctr817Det ³ Autor ³ Jonathan.gonzalez     ³ Data ³05/12/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion de llenado de dataset C085ds, para su uso en el     ³±±
±±³          ³ reporte "Flujo de Caja Birt"                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet: Returna .T. o .F., Si no se encontraron datos para el  ³±±
±±³          ³llenado del dataset.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabla Temporal                                      ³±±
±±³          ³ ExpC2 = Titulo Informe                                      ³±±
±±³          ³ ExpC3 = Regla de avance                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctr817Det(cWTabAlias, cTitulo, cProcesso)
	Local cArqTmp
	Local cCodVis		:= Posicione("CTN",1, xFilial("CTN")+cCodConfL,"CTN_PLAGER")
	Local cDescCont	:= ""
	Local cPerg		:= 'CTR560'
	Local nPosCol		:= 0
	Local lMovPeriodo	:= nConsider == 1
	Local cTpValor	:= GetMV("MV_TPVALOR")
	Local cDescMoeda	:= AllTrim(aCtbMoeda[3])
	Local lImpTrmAux	:= Iif(nImprAuxi == 1,.T.,.F.)
	Local nDecimais 	:= DecimalCTB(aSetOfBook,cMoneda)
	Local cMoedaDesc	:= IIf( Empty(cDescMone),cMoneda,cDescMone)
	Local cPicture 	:= IIf(!Empty(aSetOfBook[4]) .And. Len(Trans(0, aSetOfBook[4])) > 17,"",aSetOfBook[4])
	Local aPosCol		:= IIf(nDemosVar == 1,{ 1435, 1740, 2045 },{ 1740, 2045 })
	Local lVlrZerado	:= IIf(nSalCerrs==1,.T.,.F.)
	Local cSaldos    	:= fTrataSlds()
	Local nSaldoAnt	:= 0
	Local nSaldoAtu	:= 0
	Local nSaldoVar	:= 0
	Local nX			:= 0
	Local cFiliais	:= ""
	Local aEncColum	:= {}
	Local aEmpresa 	:= { "", "" }
	Local cCGCTxt 	:= ""
	Local cnt := 0

	Private aDatos := {.f., ""}

		//Monta Arquivo Temporario para Impressao
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(	/*01*/oMeter,;
									/*02*/oText,;
									/*03*/oDlg,;
									/*04*/@lEnd,;
									/*05*/@cArqTmp,;
									/*06*/dFinalA+1,;
									/*07*/dFinal,;
									/*08*/"",;
									/*09*/"",;
									/*10*/"",;
									/*11*/Repl("Z", TamSx3("CT1_CONTA")[1]),;
									/*12*/"",;
									/*13*/Repl("Z", TamSx3("CTT_CUSTO")[1]),;
									/*14*/"",;
									/*15*/Repl("Z", TamSx3("CTD_ITEM")[1]),;
									/*16*/"",;
									/*17*/Repl("Z", TamSx3("CTH_CLVL")[1]),;
									/*18*/cMoneda,;
									/*19*/cSaldos,;
									/*20*/aSetOfBook,;
									/*21*/,;
									/*22*/"",;
									/*23*/Repl("Z", 20),;
									/*24*/,;
									/*25*/,;
									/*26*/,;
									/*27*/,;
									/*28*/,;
									/*29*/nPosAntLP=1,;
									/*30*/dFcGanPer,;
									/*31*/,;
									/*32*/lVlrZerado,;
									/*33*/,;
									/*34*/,;
									/*35*/,;
									/*36*/,;
									/*37*/,;
									/*38*/,;
									/*39*/,;
									/*40*/,;
									/*41*/,;
									/*42*/,;
									/*43*/,;
									/*44*/,;
									/*45*/,;
									/*46*/,;
									/*47*/,;
									/*48*/,;
									/*49*/,;
									/*50*/,;
									/*51*/,;
									/*52*/,;
									/*53*/,;
									/*54*/,;
									/*55*/,;
									/*56*/,;
									/*57*/cMoedaDesc,;
									/*58*/lMovPeriodo,;
									/*59*/aSelFil,;
									/*60*/,;
									/*61*/.T.,;
									/*62*/nConSaldo=1);
					},STR0010,cProcesso) //"Criando Arquivo Temporario..."

		DbSelectArea( "cArqTmp ")
		dbGoTop()

		//Conteo del archivo temporal para la regla de avance
		count to nCount
		dbGotop()
		ProcRegua(nCount)

		//Limitado a exibição do titulo em 85 caracteres para que não estoure na exibição das filiais
		If Len(aSelFil) > 0
			For nX := 1 to Len(aSelFil)
				If Len(cTitulo + STR0019 + cFiliais) <= 85 //Sucursales:
					cFiliais += aSelFil[nX] + ","
				endIf
			Next nX
			cFiliais := Left(cFiliais,Len(cFiliais)-1)
			cTitulo += STR0019 + cFiliais	+ "..." //Sucursales:
		EndIf

		//Encabezado padrao
		SX3->(DbSetOrder(2))
		SX3->(MsSeek("A1_CGC",.t.))
		cCGCTxt := X3Titulo()

		If cModulo <> "RSP" .And. cModulo <> "CSA"
			aEmpresa[1] := AllTrim(SM0->M0_NOMECOM)
			aEmpresa[2] := Trim(cCGCTxt)+" "  + Transform(Alltrim(SM0->M0_CGC),alltrim(SX3->X3_PICTURE))
		Else
			aEmpresa[1] := ""
			aEmpresa[2] := ""
		EndIf

		//Agrega el encabezado de las columnas
		AADD(aEncColum,"(Em " + cDescMoeda + ")")

		For nPosCol := 1 To Len(aPosCol)
			Do Case
				//Segunda coluna
				Case nPosCol = 1
					AADD(aEncColum,DtoC(dFinal))
				//Terceira coluna
				Case nPosCol = 2
					AADD(aEncColum,DtoC(dFinalA))
				//Quarta coluna
				Case nPosCol = 3
					AADD(aEncColum,STR0012)
			EndCase
		Next

		While cArqTmp->(!Eof())
		cnt++
		Incproc()

		RecLock(cWTabAlias, .T.)

				(cWTabAlias)->COLUM1  := aEmpresa[1]
				(cWTabAlias)->COLUM2  := aEmpresa[2]
				(cWTabAlias)->COLUM3  := cTitulo

			//Encabezado Metodo de impresion Indirecto
			//Valida si es indirecto para agregar el titulo a la tabla del encabezado
			If nMetodo == 2
				If nDemosVar == 1
					(cWTabAlias)->COLUM4  := STR0014 //Ano Fiscal Anterior
					(cWTabAlias)->COLUM5  := STR0015 //Ano Fiscal Actual
					(cWTabAlias)->COLUM6  := STR0016 //Ano Fiscal Variacion
				Else
					(cWTabAlias)->COLUM4  := STR0014 //Ano Fiscal Anterior
					(cWTabAlias)->COLUM5  := STR0015 //Ano Fiscal Actual
				EndIf

				// ORIZIO criar arquivo .CH com os textos usados no relatorio
				// Linha 1
				(cWTabAlias)->COLUM7  := STR0017 //Actividades Operativas
				// Linha 2
				(cWTabAlias)->COLUM8  := STR0018 //Lucro Neto del Ano Fiscal
			EndIf
			//termina//

			(cWTabAlias)->COLUM10 := aEncColum[1]
			(cWTabAlias)->COLUM11 := aEncColum[2]
			(cWTabAlias)->COLUM12 := aEncColum[3]
			(cWTabAlias)->COLUM13 := iif ( nDemosVar == 1, aEncColum[4] , STR0012 )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³indica se a entidade gerencial sera impressa/visualizada em ³
			//³um relatorio ou consulta apos o processamento da visao      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cArqTmp->VISENT == "2"
				cArqTmp->( DbSkip() )
				Loop
			EndIf

			//Obtiene la descripcion de la cuenta contable.
			cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+cArqTmp->CONTA,"CTS_DETHCG")
			cDescCont := AllTrim(cArqTmp->DESCCTA)+Rtrim(cDescCont)

			(cWTabAlias)->COLUM14 := cDescCont
			(cWTabAlias)->COLUM9  := cArqTmp->IDENTIFI
			(cWTabAlias)->COLUM22 := "lgrl"+cEmpAnt+".bmp"
			(cWTabAlias)->COLUM23 := nNomInici

			/*
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			Explicacion de parametros de la funcion ValorCTB
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

			ValotCTB(ExpN1, ExpN2, ExpN3, ExpN4, ExpN5, ExpL1, ExpC1, ExpC2, ExpC3, ExpL2, ExpO1, ExpC4, ExpC5, ExpL3, ExpL4)

			Parametros	 ExpN1 = Valor
						 ExpN2 = Numero da Linha
						 ExpN3 = Numero da Coluna
						 ExpN4 = Tamanho
						 ExpN5 = Numero de Decimais
						 ExpL1 = Se devera ser impresso com sinal ou nao.
						 ExpC1 = Picture
						 ExpC2 = Tipo
						 ExpC3 = Conta
						 ExpL2 = Se eh grafico ou nao
						 ExpO1 = Objeto oPrint
						 ExpC4 = Tipo do sinal utilizado
						 ExpC5 = Identificar [USADO em modo gerencial]
						 ExpL3 = Imprime zero
						 ExpL4 = Se .F., inves de imprimir retornara o valor como
						         caracter.
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			*/
			For nPosCol := 1 To Len(aPosCol)
				Do Case
					Case nPosCol = 1
						nSaldo		:= cArqTmp->SALDOATU
				   		If cArqTmp->IDENTIFI < "5"
					                              //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
				   			(cWTabAlias)->COLUM15 := ValorCTB(nSaldo,,,15,nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,, cTpValor, ;
				   			                                  IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,.F. )
						EndIf
						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoAtu 	+= nSaldo
						EndIf
					Case nPosCol = 2
						nSaldo := cArqTmp->SALDOANT
				   		If cArqTmp->IDENTIFI < "5"
					                              //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
							(cWTabAlias)->COLUM16 := ValorCTB(nSaldo,,,15,nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,, cTpValor, ;
							                                  IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,.F.)
						EndIf
						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoAnt 	+= nSaldo
						EndIf
					Case nPosCol = 3
						nSaldo		:= GetVarEnt(cArqTmp->CONTA,cCodVis,cArqTmp->ORDEM)
				   		If cArqTmp->IDENTIFI < "5"
					                              //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
							(cWTabAlias)->COLUM17 := ValorCTB(nSaldo,,,15,nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,, cTpValor, ;
							                                  IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,.F.)
						EndIf
						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoVar 	+= nSaldo
						EndIf
				EndCase
			Next

			If nMetodo == 2
				If nReslEjer == 2
					nSaldoAtu := nSalEjer
					nSaldoAnt := nSalEjerA
					nSaldoVar := nSaldoAtu - nSaldoAnt

				EndIf

				If nDemosVar == 1
					                       //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
					(cWTabAlias)->COLUM18 := ValorCTB( nSaldoAnt , , , 15 , nDecimais , .T. , cPicture , , , , , cTpValor , "1" , , .F. )
					(cWTabAlias)->COLUM19 := ValorCTB( nSaldoAtu , , , 15 , nDecimais , .T. , cPicture , , , , , cTpValor , "1" , , .F. )
					(cWTabAlias)->COLUM20 := ValorCTB( nSaldoVar , , , 15 , nDecimais , .T. , cPicture , , , , , cTpValor , "1" , , .F. )
				Else
					                       //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
					(cWTabAlias)->COLUM18 := ValorCTB( nSaldoAnt , , , 15 , nDecimais , .T. , cPicture , , , , , cTpValor , "1" , , .F. )
					(cWTabAlias)->COLUM19 := ValorCTB( nSaldoAtu , , , 15 , nDecimais , .T. , cPicture , , , , , cTpValor , "1" , , .F. )
				EndIf
			EndIf

		(cWTabAlias)->(MsUnlock())

			cArqTmp->(DbSkip())
		EndDo

		//Valida si se imprimira el archivo de Termo Aux.
		If lImpTrmAux
			while !aDatos[1]
				aDatos := {.f.,""}
				ValTermCTB(cPerg)
			enddo
			RecLock(cWTabAlias, .T.)
				(cWTabAlias)->COLUM21 := aDatos[2]
			(cWTabAlias)->(MsUnlock())
		Endif

		DbSelectArea( "cArqTmp ")
		Set Filter To
		dbCloseArea()

		If Select( cArqTmp ) == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIF

		lRet := cnt > 0

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fTrataSlds³ Autor³ Felipe Aurelio de Melo³ Data ³ 14.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento do retorno do parametro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fTrataSlds()
	Local cRet := ""
		If nConSaldo = 1
			cRet := cSalConso
		Else
			cRet := cTipSaldo
		EndIf
Return(cRet)
