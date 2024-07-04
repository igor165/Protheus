#INCLUDE "GPER884.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#Include "RPTDEF.CH"
#INCLUDE "FONT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±| Programa    ³ GPER884  | Autor ³ Luis Enriquez      | Data ³ 01/06/17      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Desc.       ³ Recibos de Nomina CFDi v 1.2                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ Generico                                                     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|             ³      ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.       |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Programador ³ Data     ³ Motivo da Alteracao                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Luis Enriquez³22/06/2017³MMI-5054 Se sube fuente a main ya que es nuevo para|±±
±±|				³		   ³version 12.1.14. (MEXICO)		                   |±±
±±|Marco A. Glez³14/03/2018³Se replica para V12.1.17, las soluciones realizadas|±±
±±|				³		   ³en los issues DMINA-92 y DMINA-938. (MEX)          |±±
±±|Alf. Medrano ³22/02/2019³DMINA-5626 En fun GPER884 se valida que el parám   |±±
±±|				³		   ³MV_CFDICON. Se crea fun G884LinC y en En fun fLanca|±±
±±|				³		   ³se asigna para dar fortmato a la descripcion       |±±
±±|				³		   ³del concepto para OtrosPagos.Se crea func fOtrosPag|±±
±±|				³		   ³para generar info en nodo OtroPago SubsidioAlEmpleo|±±
±±|				³		   ³ y CompensacionSaldosAFavor. En fun R030Imp en var |±±
±±|				³		   ³ cTipOtrPag se asigna el tipo SAT “005O” para ser  |±±
±±|				³		   ³ incluido en otros pagos, se asigna el importe 0.01|±±
±±|				³		   ³ al total del nodo TotalOtrosPagos.En fun VldCad884|±±
±±|				³		   ³ se asignan los valores clave, concepto y importe  |±±
±±|				³		   ³ al nodo OtroPago. En fun ObtDeclAnu para subsidio |±±
±±|				³		   ³ al empleo se asigna identificador de cálculo 0514 |±±
±±|				³25/02/2019³ se compatibiliza fuente para v12.1.14 y v12.1.17  |±±
±±³Marco A Glez ³13/05/2019³DMINA-6526 - Se agrega punto de entrada G884GENTAB,³±±
±±³             ³          ³para el llenado de una tabla de usuario, con infor-³±±
±±³             ³          ³macion correspondiente a recibos timbrados.        ³±±
±±³Eduardo Perez³09/10/2019³DMINA-7563-En la función EnvRecMail(), se agrega   ³±±
±±³Andres S     ³          ³una nueva variable para obtener el valor del       ³±±
±±³             ³          ³parámetro MV_RELTLS; la cual, será utilizada en el ³±±
±±³             ³          ³valor de TLS (SetUseTLS)                           ³±±
±±³Alf. Medrano ³17/12/2019³En fun R030Imp se obtiene el Subsidio causado con  ³±±
±±³             ³          ³la función ObtDeclAnu() sin depender del subsidio  ³±±
±±³             ³          ³del empleo. En fun VldCad884(), fOtrosPag() y      ³±±
±±³             ³          ³NodOpcion() se asigna validación para el subsidio  ³±±
±±³             ³          ³causado y de empleo, si = 0 se sustituye por 0.01  ³±±
±±³Marco A Glez ³14/02/2020³DMINA-8373 - La funcionalidad realizada en el issue³±±
±±³             ³          ³DMINA-7920, queda sin efecto, por lo que se quita  ³±±
±±³             ³          ³dicha funcionalidad.                               ³±±
±±³Marco A Glez ³28/02/2020³DMINA-8494 - Se realizan ajustes para la impresion ³±±
±±³             ³          ³nodo subsidio causado y efectivamente pagado.      ³±±
±±³Marco A Glez ³15/04/2020³DMINA-8374 - Se realizan ajustes para la impresion ³±±
±±³             ³          ³y timbrado del Recibo de Nomina con Regimen Asimi- ³±±
±±³             ³          ³lados.                                             ³±±
±±³ARodriguez   ³19/08/2020³DMINA-9618 Refactorización por performance.        ³±±
±±³             ³          ³Proceso de SRA solo con registros en SRC/SRD.      ³±±
±±³             ³          ³Eliminar uso de dbEval(), macrosubstitución (&) y  ³±±
±±³             ³          ³otras prácticas.                                   ³±±
±±³             ³          ³Cambiar funciones std obsoletas por optimizadas.   ³±±
±±³Alf. Medrano ³17/11/2020³DMINA-10501 - en la función fRodape se incrementa  ³±±
±±³             ³          ³el porcentaje de tamaño del código QR.             ³±±
±±³             ³20/11/2020³DMINA-10501 - en fun GPER884() se valida el paramet³±±
±±³             ³          ³MV_VERICFD y en fun LoadBlock() se modifica conten-³±±
±±³             ³          ³-nido de codigo QR.                                ³±±
±±³Alf. Medrano ³25/11/2020³DMINA-10676 - en fun fLanca se valida si el nodo   ³±±
±±³             ³          ³PERCEPCION es un objeto o un array para poder ser  ³±±
±±³             ³          ³procesado.                                         ³±±
±±³ José Glez o ³11/12/2020³DMINA-10768 - En la funcion GravPerDed se ajusta   ³±±
±±³             ³          ³el llamado a la funcion STRZERO(nConsec,2)         ³±±
±±³Verónica F.  ³18/12/2020³DMINA-10662 - En la funcion NodoRelacc se modifica ³±±
±±³             ³          ³para que solo muestre el ultimo UUID               ³±±
±±³Eduardo Prz  ³28/12/2020³DMINA-10779 - En la funcion ImpXML se modifica     ³±±
±±³             ³          ³para que se use el array aArchivos para generar PDF³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER884(lTerminal,cFilTerminal,cMatTerminal,cMesAnoRef,nRecTipo,cSemanaTerminal)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cString		:= "SRA"        // alias do arquivo principal (Base)
	Local aOrd			:= {STR0001, STR0003, STR0004, STR0002 + " + " + STR0001, STR0002 + " + " + STR0003, STR0128 + " + " + STR0001, STR0128 + " + " + STR0003} //"Matricula"###"Nome"###"Chapa"###"C.Custo + Mat."###"C.Custo + Nome"###Departamento + Mat."###"Departamento + Nome"
	Local aDriver		:= ReadDriver()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cBaseAux		:= "S"
	Local cHtml			:= ""
	Local cMes			:= ""
	Local cAno			:= ""
	Local lImpCFDi		:= ExistBlock("G884IMPREC")
	Local cArchivos		:= ""
	Local lTimbrado		:= .F.
	Local oFwSX1Util    As Object
	Local aPergunte		:= {}

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o numero da linha de impressão como 0                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	SetPrc(0,0)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aReturn		:= {STR0009, 1, STR0010, 2, 2, 1, "", 1}	//"Zebrado"###"Administra‡„o"
	Private nomeprog	:= "GPER884"
	Private aLinha		:= { }
	Private nLastKey	:= 0
	Private cPerg		:= "GPER884"
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe
	Private cCompac		:= aDriver[1]
	Private cNormal		:= aDriver[2]
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aLanca		:= {}
	Private aProve		:= {}
	Private aDesco		:= {}
	Private aBases		:= {}
	Private aInfo		:= {}
	Private aCodFol		:= {}
	Private li			:= _PROW()
	Private Titulo		:= STR0011		//"EMISSŽO DE RECIBOS DE PAGAMENTOS"
	Private lEnvioOk	:= .F.
	Private lRetCanc	:= .T.
	Private cIRefSem	:= SuperGetMV("MV_IREFSEM", .F., "S")
	Private aPerAberto	:= {}
	Private aPerFechado	:= {}
	Private aPerSelec	:= {} // Periodo Seleccionado (Abierto/Cerrado)
	Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (MV_PAR01).
	Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (MV_PAR02).
	Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (MV_PAR03).
	Private cCcto		:= ""
	Private cCond		:= ""
	Private cRot		:= ""
	Private cDescProc	:= ""
	Private cConcpDPg	:= "" //CFDi
	Private nImpReten	:= 0
	Private nOtroDedu	:= 0
	Private aTmpArea	:= {}
	Private lGenXML		:= .F.
	private lEnvTimb	:= .F. //GetMv("MV_ENVTIMB",,.F.)   //.T. Indica si se envia a Timbrar - .F. Solo imprime (XML) sin timbrar
	Private lEsPerAb	:= .T.
	Private lExistReg	:= .F.
	Private aVlrPerDed	:= {0,0,0,0,0}
	Private aArchivos	:= {}
	/*Total Percepciones*/
	Private nTotSueld	:= 0 //Sueldos y salarios
	Private nTotIndem	:= 0 //Separacion indemnizacion
	Private nTotJubil	:= 0 //Jubilacion Pension Retiro
	/*AccionesOTitulos*/
	Private nValorMer	:= 0 //Valor Mercado
	Private nPrecOtor	:= 0 //Precio al Otorgarse
	Private aPDAccTit	:= {}
	Private cPDAccTit	:= ""
	/*JubilacionPensionRetiro*/
	Private nTotUnaEx	:= 0 //Total Una Exhibicion
	Private nTotParci	:= 0 //Total Parcialidad
	Private nTotDiari	:= 0 //Monto Diario
	Private nTotIAcum	:= 0 //Ingreso Acumulable
	Private NTotNAcum	:= 0 //Ingreso No Acumulable
	Private aPDRetiro	:= {}
	Private cPDRetiro	:= ""
	/*SeparacionIndemnizacion*/
	Private nTotPagad	:= 0 //Total Pagado
	Private nNumAnios	:= 0 //Num Años Servicio
	Private nUltSuelM	:= 0 //UltimoSueldoMensOrd
	Private nIngrAcum	:= 0 //IngresoAcumulable
	Private nIngrNAcu	:= 0 //Ingreso No Acumulable
	Private aPDIndemn	:= {}
	Private cPDIndemn	:= ""
	/*CompensacionSaldosAFavor*/
	Private nSaldoFav	:= 0 //SaldoAFavor
	Private nAnio		:= 0 //Año
	Private nRemSaldF	:= 0 //RemanenteSalFav
	/*Nodo Acciones Titulos*/
	Private cNodoAccT	:= "" //Acciones o Titulos
	Private cNodoHExt	:= "" //Horas Extras
	Private cNodoSubE	:= "" //Subsidio al Empleo
	Private cNodoComp	:= "" //Compensacion Saldos A Favor
	Private cNodoSubC	:= "" //Subcontratacion
	Private cNodoSNCF	:= "" //Entidad SNCF
	Private cOrigRecur	:= ""
	Private cCRLF		:= CRLF
	Private cDescRot	:=	""
	Private cLocPago	:= ""
	Private cTipoReg	:= ""
	/*Subsidio al Empleado*/
	Private aPDSubsidio	:= {}
	Private cPDSubsidio	:= ""
	Private nSubsidio	:= 0
	Private lAbrePDF	:= SuperGetMV("MV_CFDIPDF", .F., .T.)
	Private oTmpTable	:= Nil
	Private lGenNodSub	:= SuperGetMV("MV_NODOSUB", .F., .F.) //Utilizado para definir si genera nodo subsidio con 0.1
	Private cCFDICON	:= SuperGetMV("MV_CFDICON", .F., "") //Utilizado para informar el Concepto de Nomina para el subsidio
	Private lUsaSubPer	:= .F.
	Private lPEGenTab	:= ExistBlock("G884GENTAB")
	Private cURLValCFD	:= AllTrim(SuperGetMV("MV_VERICFD", .F., "")) //Url de Verificación de Comprobantes Fiscales Digitales por Internet.
	Private lImprDir	:= SuperGetMV("MV_EMPDIR", .F., .F.) //Utilizado para no realizar la impresión de la dirección del empleado; .T.- No imprime / .F. - Imprime.

	//Variables privadas para Nuevo proceso de Cancelación
	Private lSusRecAnt	:= .F.
	Private cMotivCanc	:= ""
	Private lEnvCanAnt	:= .F.
	Private cUUIDSust	:= ""
	
	// Nova ordem de impressao para o Mexico - Local de Pago
	If cPaisLoc == "MEX"
		If Empty(cURLValCFD)
			MsgInfo(STR0221) //El parámetro MV_VERICFD se encuentra vacío, es necesario informar la url de Verificación de Comprobantes Fiscales Digitales por Internet, la cual es necesario para generar correctamente el Código QR. Informe el parámetro e intente nuevamente."
			Return
		EndIf
		If lGenNodSub
			If Empty(cCFDICON) //Valida que exista informacion en el parametro MV_CFDICON
				Help( , , STR0217, , STR0220 + ; //"Aviso" - "Tiene activado el parámetro MV_NODOSUB, por lo tanto, "
					STR0215 + ; //"configure el parámetro MV_CFDICON "
					STR0216 + cCRLF + ; //"con el código de concepto de nómina para Subsidio al empleado, usado cuando el empleado no tiene el concepto en su nómina."
					STR0218, 1, 0) //"Puede conformarse desde 3 hasta 15 caracteres."
				Return
			Else
				lUsaSubPer := .T. //Indica que PAC valida el envio de Nodo Sub con 0.01 sin calcularlo
			EndIf
		EndIf
		aAdd(aOrd, STR0126)
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Envia controle para a funcao SETPRINT                        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	wnRel := "GPER884"            //Nome Default do relatorio em Disco

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se o programa foi chamado do terminal - TCF         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lTerminal := IIf( lTerminal == Nil, .F., lTerminal )

	//Valida que el ambiente tenga las preguntas de Sustitución de recibos
	oFwSX1Util := FwSX1Util():New()
	oFwSX1Util:AddGroup(cPerg)
	oFwSX1Util:SearchGroup()

	aPergunte := oFwSX1Util:GetGroup(cPerg)

	If Len(aPergunte) >= 2 .And. Len(aPergunte[2]) < 30
		APMSGINFO(STR0223) //"El grupo de preguntas GPER884 no se encuentra actualizado. Para evitar errores, contacte al área de soporte para mayor información."
		Return( If( lTerminal , cHtml , NIL ) )
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica as perguntas selecionadas                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Pergunte(cPerg , .T. )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define a Ordem do Relatorio                                  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nOrdem := IIF( !( lTerminal ), aReturn[8] , 1 )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿

		³ Carregando variaveis MV_PAR?? para Variaveis do Sistema.     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		cSemanaTerminal := IIF( Empty( cSemanaTerminal ) , Space( Len( SRC->RC_SEMANA ) ) , cSemanaTerminal )
		cProcesso  := IIF( !( lTerminal ), MV_PAR01 , cProcTerminal		)   //Processo
		cRoteiro   := IIF( !( lTerminal ), MV_PAR02 , nRecTipo			)	//Emitir Recibos(Roteiro)
		cPeriodo   := IIF( !( lTerminal ), MV_PAR03 , cPerTerminal		)   //Periodo
		Semana     := IIF( !( lTerminal ), MV_PAR04 , cSemanaTerminal	)	//Numero da Semana

		//Carregar os periodos abertos (aPerAberto) e/ou
		// os periodos fechados (aPerFechado), dependendo
		// do periodo (ou intervalo de periodos) selecionado
		RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
		cRoteiro	,; // Roteiro selecionado na Pergunte.
		cPeriodo	,; // Periodo selecionado na Pergunte.
		Semana		,; // Numero de Pagamento selecionado na Pergunte.
		NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
		NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
		@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
		@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados

		// Retorna o mes e o ano do periodo selecionado na pergunte.
		AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
		cRoteiro	,; // Roteiro selecionado na Pergunte.
		cPeriodo	,; // Periodo selecionado na Pergunte.
		@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
		@cAno		 ) // Retorna o Ano do Processo + Roteiro + Periodo selecionado
		dDataRef := CTOD("01/" + cMes + "/" + cAno)

		nTipRel    := IIF( !( lTerminal ), MV_PAR05, 3              )	//Tipo de Recibo (Pre/Zebrado/EMail)
		cFilDe     := IIF( !( lTerminal ), MV_PAR06, cFilTerminal   )	//Filial De
		cFilAte    := IIF( !( lTerminal ), MV_PAR07, cFilTerminal   )	//Filial Ate
		cMatDe     := IIF( !( lTerminal ), MV_PAR08, cMatTerminal   )	//Matricula Des
		cMatAte    := IIF( !( lTerminal ), MV_PAR09, cMatTerminal   )	//Matricula Ate
		cNomDe     := IIF( !( lTerminal ), MV_PAR10, SRA->RA_NOME   )	//Nome De
		cNomAte    := IIF( !( lTerminal ), MV_PAR11, SRA->RA_NOME   )	//Nome Ate
		ChapaDe    := IIF( !( lTerminal ), MV_PAR12, SRA->RA_CHAPA  )	//Chapa De
		ChapaAte   := IIF( !( lTerminal ), MV_PAR13, SRA->RA_CHAPA  )	//Chapa Ate
		cCcDe      := IIF( !( lTerminal ), MV_PAR14, SRA->RA_CC     )	//Centro de Custo De
		cCcAte     := IIF( !( lTerminal ), MV_PAR15, SRA->RA_CC     )	//Centro de Custo Ate
		cDeptoDe   := IIF( !( lTerminal ), MV_PAR16, SRA->RA_DEPTO  )	//Centro de Custo De
		cDeptoAte  := IIF( !( lTerminal ), MV_PAR17, SRA->RA_DEPTO  )	//Centro de Custo Ate
		cSituacao  := IIF( !( lTerminal ), MV_PAR18, fSituacao(NIL, .F.))	//Situacoes a Imprimir
		cCategoria := IIF( !( lTerminal ), MV_PAR19, fCategoria(NIL, .F.))	//Categorias a Imprimir

		cDescRot   :=	PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_DESC")

		If cPaisLoc == "MEX"
			cLocalDe    := MV_PAR24 //De Local Pago
			cLocalAte   := MV_PAR25 //A Local Pago
			nSumaVerba	:= If( !(lTerminal), MV_PAR26, 1 ) //1 - Sumariza verbas 2 - Não sumariza
		EndIf

		lEnvTimb   := MV_PAR27 == 1
		cBaseAux   := "N" //Imprimir Bases

		If RCJ->RCJ_CODIGO <> cProcesso
			DbSelectArea( "RCJ" )
			DbSetOrder( 1 )  // RCJ_FILIAL + RCJ_CODIGO
			DbSeek( xFilial( "RCJ" ) + cProcesso, .F. )
		EndIf

		cDescProc := IIf(RCJ->(EOF()), Space(15), SubStr( RCJ->RCJ_DESCRI, 1, 30))
		cOrigRecur := IIf(RCJ->(EOF()), "", Alltrim( RCJ->RCJ_ORIREC ))
		cTipoReg   := IIf(RCJ->(EOF()), "", IIf(RCJ->(FieldPos("RCJ_REGIME") > 0), Alltrim( RCJ->RCJ_REGIME ), ""))

		If aReturn[5] == 1 .and. nTipRel == 1
			li	:=  0
		EndIf

		IF !( lTerminal )
			cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
		EndIf

		lSusRecAnt := MV_PAR28 == 1 //Si se selecciona sustituir recibos anteriores.
		lEnvCanAnt := MV_PAR29 == 1 //Si se selecciona cancelar el recibo anterior
		cMotivCanc := StrZero(MV_PAR30, 2) //Obtiene el motivo de cancelación.

		If lSusRecAnt
			If !MsgYesNo(STR0224 + cMotivCanc + STR0225, STR0226) //"Se ha seleccionado la opción Sustituir recibos anteriores, con el motivo " - ". ¿Desea continuar?." - "Sustitución de Recibos"
				Return( If( lTerminal , cHtml , NIL ) )
			EndIf
		EndIf

		If Posicione("RCH",1,xFilial("RCH")+cProcesso+cPeriodo+Semana+cRoteiro,"RCH_STATUS") == "6" .And. lEnvTimb   //Timbrados
			APMSGINFO(STR0132) //"No es posible timbrar este proceso, ya fueron timbrado."
			Return( If( lTerminal , cHtml , NIL ) )
		EndIf

		DbSelectArea( "SRA" )

		IF nTipRel == 3
			IF lTerminal
				cHtml := R030Imp(.F.,wnRel,cString,cMesAnoRef,lTerminal)
			Else
				ProcGPE({|lEnd| R030IMP(@lEnd,wnRel,cString,cMesAnoRef,.f.)},,,.T.)  // Chamada do Processamento
			EndIf

		Else
			RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString,cMesAnoRef,.f.)},Titulo)  // Chamada do Relatorio

		EndIf

		If lGenXML
			If lEnvTimb   //Depende del parametro
				Processa({|| lTimbrado := TimbreRecNom()}) //Sinigica que pudo generar los timbres y debe actualizarse el estatus
				If lTimbrado
					//Impresion de los recibos ya Timbrados
					If lImpCFDi  //Existe PE
						Execblock("G884IMPREC",.f.,.f.,)
					Else
						IMPRXML884()
					EndIf

					dbselectarea("RCH")

					If RCH->(dbseek(XFILIAL("RCH")+cProcesso+cPeriodo+Semana+cRoteiro))
						Reclock("RCH",.F.)
						RCH->RCH_STATUS := "6"  //Recibos Timbrados
						Msunlock()
					EndIf
				EndIf

			Else
				If lImpCFDi
					Execblock("G884IMPREC",.f.,.f.,)
				Else
					IMPRXML884()
				EndIf

			EndIf

		Else
			If lImpCFDi
				Execblock("G884IMPREC",.f.,.f.,)
			Else
				IMPRXML884()
			EndIf

		EndIf
	EndIf	//Pergunte

	cArchivos := Alltrim(MV_PAR01) + Alltrim(MV_PAR02) + Alltrim(MV_PAR03) + Alltrim(MV_PAR04)

	//Elimana archivo timbradocfdi_xxxxxx.ini
	Iif( File( GetClientDir() + "timbradocfdi_" + cArchivos + ".ini" ), FErase( GetClientDir() + "timbradocfdi_" + cArchivos + ".ini" ), "" )
	//Elimina archivo timbrado_xxxxxx.bat
	Iif( File( GetClientDir() + "timbrado_" + cArchivos + ".bat" ), FErase( GetClientDir() + "timbrado_" + cArchivos + ".bat" ), "" )
	//Elimina archivo codbarqr_xxxxxx.txt
	Iif( File( GetClientDir() + "codbarqr_" + cArchivos + ".txt" ), FErase( GetClientDir() + "codbarqr_" + cArchivos + ".txt" ), "" )

Return( IF( lTerminal , cHtml , NIL ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R030IMP  ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento Para emissao do Recibo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cAcessaSRA	:= &("{ || " + ChkRH("GPER884","SRA","2") + "}")
	Local cAcessaSRC	:= &("{ || " + ChkRH("GPER884","SRC","2") + "}")
	Local cAcessaSRD	:= &("{ || " + ChkRH("GPER884","SRD","2") + "}")
	Local cHtml			:= ""
	Local nX
	Local nReg			:= 0
	Local aVerbasFunc	:= {}
	Local aVerbasFilter	:= {}
	Local cFilSRV		:= xFilial("SRV")
	Local dDataLibRh
	Local cMesCorrente	:= SuperGetmv("MV_FOLMES",.F.,"")
	Local nTcfDadt		:= If(lTerminal,SuperGetmv("MV_TCFDADT",.F.,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfDfol		:= If(lTerminal,SuperGetmv("MV_TCFDFOL",.F.,0),0)		// indica a quantidade de dias a somar ou diminuir no ultimo dia do mes corrente para liberar a consulta do TCF
	Local nTcfD131		:= If(lTerminal,SuperGetmv("MV_TCFD131",.F.,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfD132		:= If(lTerminal,SuperGetmv("MV_TCFD132",.F.,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfDext		:= If(lTerminal,SuperGetmv("MV_TCFDEXT",.F.,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local lGenero		:= .F.
	Local cArchNom		:= ""
	Local cDirArch		:= &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))
	Local lTExtra		:= .F.
	Local lSubEmpT		:= .T.
	Local cTabla 		:= ""
	Local cPref			:= ""
	Local cJoin			:= ""
	Local cWhere		:= ""
	Local cOrder		:= ""
	Local nRecCount		:= 0
	Local cCatQuery		:= ""
	Local cDirCan  		:= cDirArch + "cancelados\"
	Local lPerded       := .T.
	Local nPosXML       := 0
	Local aRecXML		:= {}
	Local cNombreOri	:= ""
	
	//Variables utilizadas en el nuevo proceso de Cancelación
	Local cDirACance	:= cDirArch + "cancelar\" //Directorio que almacena los recibos pendientes a cancelar antes el SAT
	Local cNomRecSus	:= ""
	Local cRutaSmr		:= &(SuperGetmv("MV_CFDSMAR", .F., "GetClientDir()")) //Ruta donde se encuentra el ejecutable para el timbrado
	Local cRutCFDSmr	:= cRutaSmr + "Recibos\"

	Private lCalSub		:= .F.
	Private tamanho		:= "M"
	Private limite		:= 132
	Private cDtPago		:= ""
	Private cPict1		:= "@E 999,999,999.99"
	Private cPict2		:= "@E 99,999,999.99"
	Private cPict3		:= "@E 999,999.99"
	Private cTipoRot	:= PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_TIPO")
	Private cDescRot	:= PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_DESC")
	Private nConsPer	:= 0
	Private nConsDed	:= 0
	Private cTipOtrPag	:= "001O|002O|003O|004O|999O|005O|006O|007O|008O"
	Private cPDIncap	:= ""
	Private cAliasQry	:= GetNextAlias()
	Private lIndemn		:= .F.
	Private lImprIndem  := .F.
	Private aVerbIndem  := {}
	Private aVerbOrd    := {}

	//Variables privadas para Nuevo proceso de Cancelación
	Private cUUIDSust	:= ""

	//Crea la carpeta donde se ubican los recibos a cancelar
	If !ExistDir(cDirCan)
		MakeDir(cDirCan)
	EndIf

	//Crea la carpeta donde se ubican los recibos cancelados
	If !ExistDir(cDirACance)
		MakeDir(cDirACance)
	EndIf

	//Crea la carpeta donde se ubican los recibos temporales a la ruta del SmartClient
	If !ExistDir(cRutCFDSmr)
		MakeDir(cRutCFDSmr)
	EndIf

	If MsDecimais(1) == 0
		cPict1	:=	"@E 99,999,999,999"
		cPict2  :=	"@E 9,999,999,999"
		cPict3  :=	"@E 99,999,999"
	EndIf

	// Ajuste do tipo da variavel
	nTcfDadt	:= If(valtype(nTcfDadt)=="C",val(nTcfDadt),nTcfDadt)
	nTcfD131	:= If(valtype(nTcfD131)=="C",val(nTcfD131),nTcfD131)
	nTcfD132	:= If(valtype(nTcfD132)=="C",val(nTcfD132),nTcfD132)
	nTcfDfol	:= If(valtype(ntcfdfol)=="C",val(ntcfdfol),ntcfdfol)
	nTcfDext	:= If(valtype(ntcfdext)=="C",val(ntcfdext),ntcfdext)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	| Verifica se o Mes solicitado esta liberado para consulta no  |
	| terminal de consulta do funcionario.                         |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lTerminal

		If !empty(cMesCorrente)
			cMesCorrente := substr(cMesCorrente,-2)+substr(cMesCorrente,1,4)
		EndIf

		If	cMesCorrente == cMesArqRef  .or. right(cMesCorrente,4)+left(cMesCorrente,2) == mesano(ddataref) .Or. ;
				mesano(ddataref) > substr(cMesCorrente,3,4)+substr(cMesCorrente,1,2) .Or.;
					left(cMesArqRef,2) == "13"

			If cTipoRot == "2" //Adiantamento
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTcfDadt,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf

			ElseIf cTipoRot == "1" .and. !empty(nTCFDFOL) //Folha
				dDataLibRh := fMontaDtTcf(cMesCorrente,nTCFDFOL)
				If date() < dDataLibRh
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf

			ElseIf cTipoRot == "5" //1a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTcfD131,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf

			ElseIf cTipoRot == "6" //2a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTcfD132,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf

			ElseIf cRoteiro == "EXT"  // Valores Extras
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
				( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTcfDext,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf
			EndIf

		EndIf

	EndIf

	If  !Empty(aPerAberto)  //Es periodo abierto
		aPerSelec := aPerAberto
		lEsPerAb  := .T.
	ElseIf !Empty(aPerFechado)  //Es periodo cerrado
		aPerSelec := aPerFechado
		lEsPerAb  := .F.
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Selecionando a Ordem de impressao escolhida no parametro.    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea( "SRA")
	IF !( lTerminal )
		cTabla := "%" + RetSqlName( IIf(lEsPerAb, "SRC", "SRD") ) + "%"
		cPref := IIf(lEsPerAb, "RC", "RD")
		cJoin := "%" + IIf(lEsPerAb, "RC_FILIAL=RA_FILIAL AND RC_MAT=RA_MAT", "RD_FILIAL=RA_FILIAL AND RD_MAT=RA_MAT") + "%"
		cWhere := "%RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' AND "
		cWhere += "RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' AND "
		cWhere += "RA_NOME BETWEEN '" + cNomDe + "' AND '" + cNomAte + "' AND "
		cWhere += "RA_CHAPA BETWEEN '" + ChapaDe + "' AND '" + ChapaAte + "' AND "
		cWhere += "RA_CC BETWEEN '" + cCcDe + "' AND '" + cCcAte + "' AND "
		cWhere += "RA_DEPTO BETWEEN '" + cDeptoDe + "' AND '" + cDeptoAte + "' AND "

		If cPaisLoc == "MEX"
			cWhere += "RA_KEYLOC BETWEEN '" + cLocalDe + "' AND '" + cLocalAte + "' AND "
		EndIf

		For nX := 1 to Len(cCategoria)
			cCatQuery += "'"+Subs(cCategoria,nX,1)+"'"
			If ( nX ) < Len(cCategoria)
				cCatQuery += ","
			Endif
		Next nX

		cWhere += "RA_CATFUNC IN (" + cCatQuery + ") AND "
		cWhere += cPref + "_PROCES = '" + cProcesso + "' AND "
		cWhere += cPref + "_ROTEIR = '" + cRoteiro + "' AND "
		cWhere += cPref + "_PERIODO = '" + cPeriodo + "' AND "
		cWhere += cPref + "_SEMANA = '" + Semana + "'%"

		If nOrdem == 1
			dbSetOrder(1)	//RA_FILIAL+RA_MAT
			cOrder := "%RA_FILIAL,RA_MAT%"

		ElseIf nOrdem == 2
			dbSetOrder(3)	//RA_FILIAL+RA_NOME
			cOrder := "%RA_FILIAL,RA_NOME%"

		ElseIf nOrdem == 3
			cOrder := "%RA_FILIAL,RA_CHAPA,RA_MAT%"

		ElseIf nOrdem == 4
			dbSetOrder(2)	//RA_FILIAL+RA_CC+RA_MAT
			cOrder := "%RA_FILIAL,RA_CC,RA_MAT%"

		ElseIf nOrdem == 5
			dbSetOrder(8)	//RA_FILIAL+RA_CC+RA_NOME
			cOrder := "%RA_FILIAL,RA_CC,RA_NOME%"

		ElseIf nOrdem == 6
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_DEPTO+RA_MAT"))
			cOrder := "%RA_FILIAL,RA_DEPTO,RA_MAT%"

		ElseIf nOrdem == 7
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_DEPTO+RA_NOME"))
			cOrder := "%RA_FILIAL,RA_DEPTO,RA_NOME%"

		ElseIf nOrdem == 8
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_KEYLOC+RA_NOME"))
			cOrder := "%RA_FILIAL,RA_KEYLOC,RA_NOME%"

		EndIf

		// Query para extraer empleados con conceptos
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.R_E_C_N_O_ nRECNO, %Exp:cOrder%
			FROM %Table:SRA% SRA
			INNER JOIN %Exp:cTabla% SRC
			ON %Exp:cJoin%
			WHERE SRA.%notDel% AND
				SRC.%notDel% AND
				%Exp:cWhere%
			ORDER By %Exp:cOrder%
		EndSql

		dbSelectArea(cAliasQry)
		nRecCount := Lastrec()

		If nTipRel == 2
			@ LI,00 PSAY AvalImp(limite)
		EndIf

	Else
		cAliasQry := "SRA"
		nRecCount := 1

	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Regua Processamento                                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nTipRel # 3
		SetRegua(nRecCount)	// Total de elementos da regua
	Else
		If !( lTerminal )
			GPProcRegua(nRecCount)// Total de elementos da regua
		EndIf
	EndIf

	TOTVENC := TOTDESC := FLAG := CHAVE := 0

	dRCHDtIni := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTINI")
	dRCHDtFim := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTFIM")
	cFilialAnt := Space(FWGETTAMFILIAL)
	Vez        := 0
	OrdemZ     := 0

	If cPaisLoc == "MEX"
		aVerbasFilter := {}
		aPDAccTit := {}
		aPDRetiro := {}
		aPDIndemn := {}
		aPDSubsidio := {}

		SRV->(dbSetOrder(1))
		SRV->(dbSeek(cFilSRV))

		While SRV->( !Eof() ) .And. SRV->RV_FILIAL ==  cFilSRV
			If SRV->RV_IMPRIPD == "1" .AND. !EMPTY(SRV->RV_TIPSAT)
				AAdd(aVerbasFilter, {SRV->RV_COD})
			EndIf

			If Alltrim(SRV->RV_DECLANU) $ "41K|41L"
				//Conceptos Acciones Titulo
				AAdd(aPDAccTit, {SRV->RV_COD, SRV->RV_DECLANU})
			ElseIf Alltrim(SRV->RV_DECLANU) $ "3Q|3R|3S|3X|3Y"
				//Conceptos Jubilacion Retiro
				AAdd(aPDRetiro, {SRV->RV_COD, SRV->RV_DECLANU})
			ElseIf Alltrim(SRV->RV_DECLANU) $ "3A|3B|3E|3G"
				//Conceptos Indemnizacion
				AAdd(aPDIndemn, {SRV->RV_COD, SRV->RV_DECLANU})
			EndIf

			If Alltrim(SRV->RV_CODFOL) $ "0471|0514"
				//Subsidio al Empleado
				AAdd(aPDSubsidio, {SRV->RV_COD, SRV->RV_DECLANU})
			EndIf

			SRV->( dbSkip() )
		EndDo

		cPDAccTit := fNodOpcPer(aPDAccTit)
		cPDRetiro := fNodOpcPer(aPDRetiro)
		cPDIndemn := fNodOpcPer(aPDIndemn)
		cPDSubsidio := fNodOpcPer(aPDSubsidio)
	EndIf

	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() ) .Or. lIndemn
			If !lTerminal
				If lIndemn
					lImprIndem := lIndemn
					lIndemn := .F.
				Else
					lImprIndem := .F.
				EndIf
				SRA->(dbGoto((cAliasQry)->nRECNO))
			EndIf

			//Retorna as verbas do funcionario, de acordo com os periodos selecionados
			If !lImprIndem
				VerbasIndem(aVerbasFilter)
			EndIf

			If lImprIndem
				aVerbasFunc := aVerbIndem
				aVerbIndem := {}
			Else
				aVerbasFunc := aVerbOrd
				aVerbOrd := {}
				nPosIndem := (cAliasQry)->nRECNO
			EndIf

			If Empty(aVerbasFunc)
				If !lIndemn
					(cAliasQry)->( dbSkip() )
				Endif
				Loop
			EndIf

			lCalSub    := .F.
			lSubEmpT   := .T.
			aTmpArea   := {}
			lGenero    := .F.
			nImpReten  := 0
			nOtroDedu  := 0
			aVlrPerDed := {0,0,0,0,0}

			/*Total Percepciones*/
			nTotSueld := 0 //Sueldos y salarios
			nTotIndem := 0 //Separacion indemnizacion
			nTotJubil := 0 //Jubilacion Pension Retiro
			/*AccionesOTitulos*/
			nValorMer := 0 //Valor Mercado
			nPrecOtor := 0 //Precio al Otorgarse
			/*JubilacionPensionRetiro*/
			nTotUnaEx := 0 //Total Una Exhibicion
			nTotParci := 0 //Total Parcialidad
			nTotDiari := 0 //Monto Diario
			nTotIAcum := 0 //Ingreso Acumulable
			NTotNAcum := 0 //Ingreso No Acumulable
			/*SeparacionIndemnizacion*/
			nTotPagad := 0 //Total Pagado
			nNumAnios := 0 //Num Años Servicio
			nUltSuelM := 0 //UltimoSueldoMensOrd
			nIngrAcum := 0 //IngresoAcumulable
			nIngrNAcu := 0 //Ingreso No Acumulable
			/*CompensacionSaldosAFavor*/
			nSaldoFav := 0 //SaldoAFavor
			nAnio     := 0 //Año
			nRemSaldF := 0 //RemanenteSalFav
			nSubsidio := 0 //SubsidioCausado

			cPDIncap  := ""
			lTExtra   := .F. //Flag tiempo extra

			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
			// Movimenta Regua Processamento                                //
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
			If !( lTerminal )
				If nTipRel # 3
					IncRegua()  // Anda a regua
				ElseIf !( lTerminal )
					GPIncProc(SRA->RA_FILIAL + " - " + SRA->RA_MAT + " - " + SRA->RA_NOME)
				EndIf

				If lEnd
					@Prow()+1,0 PSAY cCancel
					Exit
				EndIf
			EndIf

			aLanca	:= {}         // Zera Lancamentos
			aProve	:= {}         // Zera Lancamentos
			aDesco	:= {}         // Zera Lancamentos
			aBases	:= {}         // Zera Lancamentos
			nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
			Ordem_Rel := 1     // Ordem dos Recibos

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica Data Demissao         ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cSitFunc := SRA->RA_SITFOLH
			dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")

			// Esta condición genera una regla especial, razón por la que RA_SITFOLH no se incluye en WHERE del Query
			If ( cPaisLoc # "MEX" ) // alterado Reginaldo
				If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
					cSitFunc := " "
				EndIf
			EndIf

			IF !( lTerminal )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Consiste situacao e categoria dos funcionarios			   |
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If !( cSitFunc $ cSituacao )
					If !lIndemn
						(cAliasQry)->(dbSkip())
					Endif
					Loop
				EndIf

				If ( cPaisLoc # "MEX" )  //alterado Reginaldo
					If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
						If !lIndemn
							(cAliasQry)->(dbSkip())
						EndIf
						Loop
					EndIf
				EndIf
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Consiste controle de acessos e filiais validas			   |
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
					If !lIndemn
						(cAliasQry)->(dbSkip())
					Endif
					Loop
				EndIf
			EndIf

			If SRA->RA_FILIAL # cFilialAnt
				If !Fp_CodFol(@aCodFol, SRA->RA_FILIAL) .Or. !fInfo(@aInfo, SRA->RA_FILIAL)
					Exit
				EndIf

				dbSelectArea(cAliasQry)
				cFilialAnt := SRA->RA_FILIAL
			EndIf

			cNombreOri := Alltrim(MV_PAR01) + Alltrim(MV_PAR02) + Alltrim(MV_PAR03) + Alltrim(MV_PAR04) + "_" + SRA->RA_FILIAL + SRA->RA_MAT +IIF(lImprIndem,"_indem","")
			cArchNom := cNombreOri + ".xml"
			
			If lSusRecAnt //Si se selecionó sustituir recibos anteriores
				cUUIDSust := FGetMovRIW(SRA->RA_FILIAL, SRA->RA_CIC) //Variable utilizada en función NodoRelacc() para pasar el UUID a sustituir
			EndIf

			aAdd ( aArchivos, { cNombreOri } )
			nPosXML := Len(aArchivos)

			cNewNom := Substr(cArchNom,1,len(cArchNom)-4) + "_" + dtos(ddatabase) + "-" +  StrTran( Time(), ":", "_" ) + ".xml"

			If File( cDirArch + cArchNom + ".canc")
				CpyT2S( GetSrvProfString('RootPath','') + cDirArch + cArchNom + ".canc" , cDirCan)
				If File(cDirArch + cArchNom )
					Frename( cDirArch + cArchNom,  cDirArch + cNewNom)
					CpyT2S( GetSrvProfString('RootPath','') + cDirArch + cNewNom , cDirCan)
					Frename( cDirArch + cArchNom + ".out", cDirArch + cNewNom + ".out")
					CpyT2S( GetSrvProfString('RootPath','') + cDirArch + cNewNom + ".out"  , cDirCan)
					Ferase( cDirArch + cNewNom )
					Ferase( cDirArch + cNewNom + ".out" )
					Ferase( cDirArch + cArchNom + ".canc" )
				EndIF
			EndIF

			//Funcion para validar si ya existe el archivo XML y si existe se valida si esta TIMBRADO
			IF File(cDirArch + cArchNom)
				IF ValidaRecibo( cDirArch + cArchNom, aRecXML ) //Valida si el recibo ya está timbrado

					If lSusRecAnt //Si se selecciona sustituir recibo anterior
						
						cUUIDSust := aRecXML[2] //Variable utilizada en función NodoRelacc() para pasar el UUID a sustituir

						cNomRecSus := cNombreOri + "_" + AllTrim(Str(FGetRIWRco(cUUIDSust))) + ".xml"

						//Renombra, copia y remueve archivo XML/OUT a cancelar
						fUbicaArch(cDirArch, cRutCFDSmr, cArchNom, cNomRecSus, cDirACance)
						fUbicaArch(cDirArch, cRutCFDSmr, cArchNom + ".out", cNomRecSus + ".out", cDirACance)

					EndIf

					If !lIndemn .And. !lSusRecAnt
						(cAliasQry)->(dbSkip())
					Endif

					If !lSusRecAnt
						Loop
					EndIf

				Else
					FERASE(cDirArch + cArchNom)
				EndIf
			EndIf

			ObtRegSRC(9)
			If  !lExistReg
				If !lIndemn
					(cAliasQry)->(dbSkip())
				Endif
				Loop
			EndIf

			Totvenc := Totdesc := 0
			nConsPer := nConsDed := 0

			If cRoteiro <> "EXT"
				If !Empty(aVerbasFunc)
					LocTrab884("SRCEX")  //Horas Extra
					ObtRegSRC(6)
					LocTrab884("SRVPD")  //Detalle percepciones y deducciones
				EndIf

				For nReg := 1 to Len(aVerbasFunc)
					If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD))
						dbSkip()
						Loop
					EndIf

					If  PosSrv(aVerbasFunc[nReg,3], SRA->RA_FILIAL, "RV_IMPRIPD") == "1"    //1- Imprimir el concepto
						//Percepciones
						If  PosSrv( aVerbasFunc[nReg,3] , SRA->RA_FILIAL , "RV_TIPOCOD" ) $ "1|3"  .And.  (SRV->RV_IR $ "1|2|3|4|5")
							GravPerDed("1",SRV->RV_TIPSAT,aVerbasFunc[nReg,3],aVerbasFunc[nReg,7],SRV->RV_IR,nSumaVerba,Alltrim(SRV->RV_DESCDET),SRV->RV_CODFOL,Alltrim(SRV->RV_DECLANU),aVerbasFunc[nReg,6],@lTExtra)   //1-Deduccion,RV_TIPSAT,RV_PD,RC_VALOR,RV_IR
							TOTVENC += aVerbasFunc[nReg,7]

							If  SRV->RV_IR $ '1|4|5' .And. !(SRV->RV_TIPSAT $ (cTipOtrPag)) //Percepcion Gravada

								If SRV->RV_CODFOL == "0446"
									If !lTExtra
										aVlrPerDed[1] += SRVPD->RC_VALORGV
										aVlrPerDed[2] += SRVPD->RC_VALOREX
									EndIf

								Else
									aVlrPerDed[1] += aVerbasFunc[nReg,7]

								EndIf

							ElseIf (SRV->RV_IR == '2' .Or. SRV->RV_IR == '3') .And. !(SRV->RV_TIPSAT $ (cTipOtrPag)) //Percepcion Exenta

								If SRV->RV_CODFOL == "0446"
									If !lTExtra
										aVlrPerDed[1] += SRVPD->RC_VALORGV
										aVlrPerDed[2] += SRVPD->RC_VALOREX
									EndIf

								Else
									aVlrPerDed[2] += aVerbasFunc[nReg,7]

								EndIf

							EndIf

							If SRV->RV_TIPSAT $ (cTipOtrPag) //Otras Percepciones
								aVlrPerDed[5] += aVerbasFunc[nReg][7]

								If SRV->RV_CODFOL == "0477"
									nSaldoFav := aVerbasFunc[nReg][7]
									If  Month(aVerbasFunc[nReg][13]) == 12
										nAnio := Year(aVerbasFunc[nReg][13])
									Else
										nAnio := Year(aVerbasFunc[nReg][13]) - 1
									Endif

								ElseIf SRV->RV_CODFOL == "1212"
									nRemSaldF := aVerbasFunc[nReg][7]

								ElseIf SRV->RV_CODFOL == "0514"
									lSubEmpT := .F.

								EndIf

							EndIf

							If !Empty(cPDSubsidio) .and. !lCalSub .and. !lImprIndem
								ObtDeclAnu(IIf(Empty(aPerAberto), .F., .T.), cPDSubsidio)
								lCalSub := .T.
							EndIf

							/*Percepciones*/
							If !(Alltrim(SRV->RV_DECLANU) $ ("3A|3Q|3R")) .And. !(SRV->RV_TIPSAT $ (cTipOtrPag)) //Sueldos y salarios
								nTotSueld += aVerbasFunc[nReg][7]
							EndIf

							If Alltrim(SRV->RV_DECLANU) $ ("3A") //Separacion indemnizacion
								nTotIndem += aVerbasFunc[nReg][7]
								nTotPagad:= 0 //gpe
								If !Empty(cPDIndemn)
									ObtDeclAnu(IIf(Empty(aPerAberto), .F., .T.), cPDIndemn)
								EndIf
							EndIf

							If Alltrim(SRV->RV_DECLANU) $ ("3Q|3R") //Jubilacion Pension Retiro
								nTotJubil += aVerbasFunc[nReg][7]
								If !Empty(cPDRetiro)
									ObtDeclAnu(IIf(Empty(aPerAberto), .F., .T.), cPDRetiro)
								EndIf
							EndIf

							If Alltrim(SRV->RV_DECLANU) $ ("41K|41L") //Valor Mercado
								If !Empty(cPDAccTit)
									ObtDeclAnu(IIf(Empty(aPerAberto), .F., .T.), cPDAccTit)
								EndIf
							EndIf

							//Deducciones
						ElseIf (SRV->RV_TIPOCOD == "2" .OR. SRV->RV_TIPOCOD == "4") .And.  (SRV->RV_IR $ "1|2|3|4|5")
							GravPerDed("2",SRV->RV_TIPSAT,aVerbasFunc[nReg,3],aVerbasFunc[nReg,7],SRV->RV_IR,nSumaVerba,Alltrim(SRV->RV_DESCDET),SRV->RV_CODFOL,Alltrim(SRV->RV_DECLANU),aVerbasFunc[nReg,6],@lTExtra)   //2-Deduccion,RV_TIPSAT,RV_PD,RC_VALOR,RV_IR
							TOTDESC += aVerbasFunc[nReg,7]

							If  SRV->RV_IR $ '1|4|5' .And. !(SRV->RV_TIPSAT $ (cTipOtrPag))//Deduccion Gravada
								aVlrPerDed[3] += aVerbasFunc[nReg][7]

							ElseIf (SRV->RV_IR == '2' .Or. SRV->RV_IR == '3') .And. !(SRV->RV_TIPSAT $ (cTipOtrPag)) //Deduccion Exenta"
								aVlrPerDed[4] += aVerbasFunc[nReg][7]

							EndIf

							If SRV->RV_TIPSAT $ (cTipOtrPag)//Otras Deducciones
								aVlrPerDed[5] -= aVerbasFunc[nReg][7]

								If SRV->RV_CODFOL == "0477"
									nSaldoFav := aVerbasFunc[nReg][7]

									If  Month(aVerbasFunc[nReg][13]) == 12
										nAnio := Year(aVerbasFunc[nReg][13])
									Else
										nAnio := Year(aVerbasFunc[nReg][13]) - 1
									Endif

								ElseIf SRV->RV_CODFOL == "1212"
									nRemSaldF := aVerbasFunc[nReg][7]

								EndIf

							EndIf

						EndIf
					EndIf
				Next nReg
			EndIf

			If lSubEmpT .And. lUsaSubPer .and. !lImprIndem
				aVlrPerDed[5] += 0.01
				lSubEmpT := .F.
			EndIf

			//Temporalmente que imprima aunque no tenga percepciones y deducciones
			If Empty(aVerbasFunc)
				LocTrab884("SRVPD")  //Detalle percepciones y deducciones
			EndIf

			If lGenNodSub
				lPerded := ValPerDed()
			EndIf

			If lPerded
				//Generaci¾n del archivo XML (CFDI): Imprimir solo si se genera el XML
				lGenero := GpeaXML884()
			Else
				if Len(aArchivos) == 1
					aArchivos := {}
				Else
					ADEL(aArchivos,nPosXML)
				Endif
				If !lIndemn
					(cAliasQry)->( dbSkip() )
				Endif
				Loop
			EndIf
			If !lGenXML .And. lGenero //Existe al menos un registro timbrado
				lGenXML := lGenero
			EndIf

			dbSelectArea(cAliasQry)
			If !lIndemn
				(cAliasQry)->( dbSkip() )
			EndIf
			TOTDESC := TOTVENC := 0
		EndDo

	Else
		APMSGINFO(STR0214) //No se encontro información para generar los Recibos
	EndIf

	If !( lTerminal )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino do relatorio                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasQry)->(dbCloseArea())
		dbSelectArea("SRC")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRD")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRA")
		dbSetOrder(1)          // Retorno a ordem 1

		Set Device To Screen

		If lEnvioOK
			APMSGINFO(STR0042)
		ElseIf nTipRel == 3
			APMSGINFO(STR0043)
		EndIf

		SeTPgEject(.F.)

		If aReturn[5] == 1 .and. nTipRel # 3
			Set Printer To
			Commit
		EndIf

		MS_FLUSH()
	EndIf

Return cHtml

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fMontaDtTcf   ³Autor³Ricardo Duarte       ³ Data ³ 13/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data valida para a consulta do Terminal Consulta   ³±±
±±³          ³do Funcionario                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³fMontaDtTcf(cMesAno,nDia)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMesAno.- Valor de mes año                                   ³±±
±±³          ³nDia.- Valor de numero de día                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³dDataValida.- Valor de fecha valido                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fMontaDtTcf(cMesAno,nDia)
	Local dDataValida
	Default nDia := 0

	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+"01")
	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+strzero(f_UltDia(dDataValida),2))+nDia

Return dDataValida

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ObtNomin ³ Autor ³ Laura Medina Prado    ³ Data ³ 10/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para obtener las deducciones y Percepciones del    ³±±
±±³          ³ empleado en proceso.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtConcep()                                                ³±±
±±³          ³ Retorno:  cConceptos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravPerDed(cTipoCon,cTipSAT,cPDSRV,nValorSRC,cIR,nSumaCon,cDESCDET,cCodFol,cDeclAnu,cValorHrs,lTExtra)
	Local aArea		:= GetArea()
	Local nConsec	:= 0

	Static lAglutPd
	DEFAULT nSumaCon:= 0

	If  nValorSRC <>0

		If  cTipoCon == "1"    //Percepcion
			nConsPer++
			nConsec :=  nConsPer

		ElseIf cTipoCon == "2" //Deduccion
			nConsDed++
			nConsec :=  nConsDed

		EndIf

		If  lAglutPd == Nil
			lAglutPd := ( SuperGetmv("MV_AGLUTPD", .F., "1") == "1" ) // 1-Agrupa conceptos 2-No Agrupa conceptos
			If ( nSumaCon == 1 .OR. cPDSRV = "137" )     //Suma los conceptos
				lAglutPd := .T.
			ElseIf ( nSumaCon == 2 ) //Muestra los conceptos por separado
				lAglutPd := .F.
			EndIf

		Else
			If ( nSumaCon == 1  .OR. cPDSRV = "137")     //Suma los conceptos
				lAglutPd := .T.
			ElseIf ( nSumaCon == 2 ) //Muestra los conceptos por separado
				lAglutPd := .F.
			EndIf

		EndIf

		dbSelectArea("SRVPD")
		SRVPD->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM

		If  lAglutPd  .And.  (SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon+cPDSRV)) ) .Or. ((SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon+cPDIncap))) .And. cTipSAT == "006D")//Sumarizar los conceptos
			RecLock("SRVPD",.F.)

			If  cIR $ "1|4|5"  //Gravado
				If cCodFol == "0446"
					If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
						SRVPD->RC_VALORGV := SRCEX->RC_VALOR
					EndIf

					If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
						SRVPD->RC_VALOREX := SRCEX->RC_VALOR
					EndIf

				Else
					SRVPD->RC_VALORGV += nValorSRC	//Importe Gravado

				EndIf

			ElseIf cIR == "2" .OR. cIR == "3"  //Exento
				If cCodFol == "0446"
					If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
						SRVPD->RC_VALORGV := SRCEX->RC_VALOR
					EndIf

					If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
						SRVPD->RC_VALOREX := SRCEX->RC_VALOR
					EndIf

				Else
					SRVPD->RC_VALOREX += nValorSRC	//Importe Exento

				EndIf

			EndIf

			SRVPD->RC_HORAS += cValorHrs
			SRVPD->(MsUnlock())

			If cCodFol $ "0446"
				lTExtra := .T.
			EndIf

		Else
			If !SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon+cPDSRV+STRZERO(nConsec,2)))
				RecLock("SRVPD",.T.)
				SRVPD->RA_FILIAL := SRA->RA_FILIAL        		//Filial
				SRVPD->RA_MAT    := SRA->RA_MAT        			//Matricula

				If (cTipSAT $ (cTipOtrPag))
					SRVPD->RV_TIPO   := "3"        			//Tipo (3-Otros)
				Else
					SRVPD->RV_TIPO   := cTipoCon        			//Tipo (1-Percepcion/2-Deduccion)
				EndIf

				SRVPD->RV_ITEM   := STRZERO(nConsec,2)     		//Consecutivo
				SRVPD->RV_TIPSAT := cTipSAT 					//Tipo Percepcion
				SRVPD->RV_COD	 := cPDSRV	                	//Clave

				If cTipSAT == "006D"
					SRVPD->RV_DESCDET := STR0213
					cPDIncap := cPDSRV

				Else
					SRVPD->RV_DESCDET := cDESCDET					//Concepto

				EndIf

				If  cIR $ "1|4|5"  //Gravado
					If cCodFol == "0446"
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
							SRVPD->RC_VALORGV := SRCEX->RC_VALOR
						EndIf
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
							SRVPD->RC_VALOREX := SRCEX->RC_VALOR
						EndIf

					Else
						SRVPD->RC_VALORGV := nValorSRC	//Importe Gravado

					EndIf

				ElseIf cIR == "2" .OR. cIR == "3"  //Exento
					If cCodFol == "0446"
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
							SRVPD->RC_VALORGV := SRCEX->RC_VALOR
						EndIf
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
							SRVPD->RC_VALOREX := SRCEX->RC_VALOR
						EndIf

					Else
						SRVPD->RC_VALOREX := nValorSRC	//Importe Exento

					EndIf

				EndIf

				SRVPD->RV_CODFOL := cCodFol
				SRVPD->RV_DECLANU := cDeclAnu
				SRVPD->RC_HORAS := cValorHrs
				SRVPD->(MsUnlock())

			Else
				RecLock("SRVPD",.F.)
				SRVPD->RC_HORAS += cValorHrs

				If cCodFol == "0447"
					If cIR $ "1|4|5"  //Gravado
						SRVPD->RC_VALORGV += nValorSRC	//Importe Gravado
					ElseIf cIR $ "2|3"  //Exento
						SRVPD->RC_VALOREX += nValorSRC	//Importe Exento
					EndIf
				EndIf

				If cCodFol $ "0446"
					lTExtra := .T.
				EndIf
				SRVPD->(MsUnlock())

			EndIf

		EndIf

		//Impuestos Retenidos (ISR)
		If  cTipSAT =='002D'     //Tipo SAT: ISR
			If cTipoCon == "1" //Percepcion: resta
				nImpReten -= nValorSRC
			ElseIf cTipoCon == "2" //Deduccion: suma
				nImpReten += nValorSRC
			EndIf

		ElseIf cTipSAT !='002D' .And. cTipoCon == "2"
			nOtroDedu += nValorSRC

		EndIf

	EndIf

	RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GpeaXML884³ Autor ³ Laura Medina Prado    ³ Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generación del XML para enviar al PAC y que regrese el Tim-³±±
±±³          ³ bre digital.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GpeaXML884()                                               ³±±
±±³          ³ Retorno:  aGenXML[]                                        ³±±
±±³          ³ 1 - (.T.) Si genero correctamente el XML                   ³±±
±±³          ³ 2 - Timbre Fiscal                                          ³±±
±±³          ³ 3 - Descripción del error en caso de que no se genere XML. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GpeaXML884()
	Local aArea			:= GetArea()
	Local aAreaSRA		:= SRA->(GetArea())
	Local lGeneXML		:= .F.
	Local cFilTmp		:= cFilAnt

	Private cRegPatr	:= "" //RegistroPatronal
	Private dFchPag		:= CTOD("//")   //FechaPago
	Private dFchInPag	:= CTOD("//")   //FechaInicialPago
	Private dFchFiPag	:= CTOD("//")   //FechaFinalPago
	Private nDiasPag	:= 0            //NumDiasPagagos
	Private cDeptoIm	:= ""           //Departamento
	Private cBcoCfdi	:= ""           //Banco
	Private dFchInLab	:= CTOD("//")   //FechaInicioRelLaboral
	Private nAntigue	:= CTOD("//")   //Antiguedad
	Private cPuesCfdi	:= ""           //Puesto
	Private cTipJorn	:= ""           //TipoJornada
	Private cPerCFDi	:= ""           //Periodicidad del Pago
	Private nSalBasAp	:= 0            //Salario Base Ap
	Private cRiegCFDi	:= ""           //Riesgo del Puesto
	Private nTotPGrav	:= 0            //Total Gravado Percepciones
	Private nTotPExen	:= 0            //Total Exento Percepciones
	Private nTotDGrav	:= 0            //Total Gravado Deducciones
	Private nTotDExen	:= 0            //Total Exento Deducciones
	Private nTotOtroP	:= 0
	Private aErrores	:= {}
	Private cRUTASRV	:= SuperGetmv( "MV_CFDRECN" , .F. , "\cfd\recibos\" )	// Ruta donde se generan los recibos.xml (servidor)
	Private cConcepSRV	:= ""
	Private lEsExMar	:= .F.
	Private cMV_DIAST	:= SuperGetmv( "MV_CFDI_DT" , .F. , "" )	// Concepto Num
	Private cMV_PGRAV	:= SuperGetmv( "MV_CFDI_PG" , .F. , "" )	// Concepto de días pagados
	Private aPercDed	:= {}
	Private cEntFed 	:= ""

	/*aPerSelec[]:
	1 - Periodo
	2 - No. de Pago
	3 - Mes
	4 - Ano
	5 - DTINI
	6 - DITFIM
	7 - DTPAGO
	*/

	If !lEsPerAb //Solo validar cuando es periodo cerrado
		If  aPerSelec[1,6]<=ctod('31/03/2014')  //Excepcion
			lEsExMar := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ELEMENTO NOMINA:  ENCABEZADO                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt  := SRA->RA_FILIAL

	//Lugar Expedicion
	dbSelectArea("RGC")
	RGC->(dbSetOrder(1)) //RGC_FILIAL+RGC_KEYLOC

	IF  RGC->(dbSeek(xFilial("RGC")+SRA->RA_KEYLOC))
		cEntFed := fDescRCC("S036",RGC->RGC_ESTADO,4,4,1,3)
		cLocPago := Alltrim(RGC->RGC_CIDADE) + ", " + Alltrim(RGC->RGC_ESTADO)
	EndIf

	//Registro Patronal
	dbSelectArea("RCO")
	RCO->(dbSetOrder(1)) //RCO_FILIAL+RCO_CODIGO+RCO_NREPAT+RCO_ATIVID

	IF  RCO->(dbSeek(xFilial("RCO")+SRA->RA_CODRPAT))
		cRegPatr := RCO->RCO_NREPAT
	EndIf

	//Fecha Pago
	IF  !Empty(aPerSelec[1,7])
		dFchPag := aPerSelec[1,7]
	EndIf

	//Fecha Inicial Pago
	IF  !Empty(aPerSelec[1,5])
		dFchInPag := aPerSelec[1,5]
	EndIf

	//Fecha Final Pago
	If  !Empty(aPerSelec[1,6])
		dFchFiPag := aPerSelec[1,6]
	EndIf

	//Obtener concepto de días pagados
	cConcpDPg  := Iif(lEsExMar,cMV_DIAST,ObtConcep(2))
	//Dias Pagados
	nDiasPag := ObtRegSRC(1)

	//Departamentos
	dbSelectArea("SQB")
	SQB->(dbSetOrder(1)) //QB_FILIAL+QB_DEPTO

	If SQB->(dbSeek(xFilial("SQB")+SRA->RA_DEPTO))
		cDeptoIm := SQB->QB_DESCRIC
	EndIf

	//Bancos
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	If SA6->(dbSeek(xFilial("SA6")+Subs(SRA->RA_BCDEPSA,1,3)+Subs(SRA->RA_BCDEPSA,4,5)))
		cBcoCfdi := SA6->A6_TIPSAT
	EndIf

	//Fecha inicio de Rel Laboral
	dFchInLab := IIf(!Empty(SRA->RA_FECREI),SRA->RA_FECREI,SRA->RA_ADMISSA)

	//Antiguedad
	nAntigue := int((dFchFiPag-dFchInLab+1)/7)  //Semanas cotizadas

	//Puesto (Funciones)
	dbSelectArea("SRJ")
	SRJ->(dbSetOrder(1)) //RJ_FILIAL+RJ_FUNCAO

	IF  SRJ->(dbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
		cPuesCfdi := SRJ->RJ_DESC
		cRiegCFDi := SRJ->RJ_RIESGO
	EndIf

	//Tipo Jornada
	dbSelectArea("SR6")
	SR6->(dbSetOrder(1)) //R6_FILIAL+R6_TURNO

	IF  SR6->(dbSeek(xFilial("SR6")+SRA->RA_TNOTRAB))
		If SR6->(FieldPos("R6_TIPJOR")>0)
			cTipJorn := SR6->R6_TIPJOR
		EndIf
	EndIf

	//Periodicidad Pago (Procesos)
	dbSelectArea("RCJ")
	RCJ->(dbSetOrder(1)) //RCJ_FILIAL+RCJ_CODIGO

	IF  RCJ->(dbSeek(xFilial("RCJ")+SRA->RA_PROCES))
		cPerCFDi := RCJ->RCJ_PERIOD
	EndIf

	//Salario Base
	If (cConcepSRV := ObtConcep(1)) <> ""
		nSalBasAp := ObtRegSRC(2, cConcepSRV)
	EndIf

	nTotPGrav := aVlrPerDed[1]
	nTotPExen := aVlrPerDed[2]
	nTotDGrav := aVlrPerDed[3]
	nTotDExen := aVlrPerDed[4]
	nTotOtroP := aVlrPerDed[5]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ELEMENTO NOMINA: INCAPACIDAD                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LocTrab884("SRCIN")  //Incapacidades
	ObtRegSRC(5)

	if nTotPGrav + nTotPExen + nTotOtroP > 0
		SM0->(DBSEEK(SM0->M0_CODIGO+cFilAnt))
		If GenRNom884()
			lGeneXML := .T.
		EndIf

	Else
		DelATbr884()
		lGeneXML := .F.

	EndIf

	cFilAnt := cFilTmp
	SM0->(DBSEEK(SM0->M0_CODIGO+cFilAnt))
	SRA->(RestArea( aAreaSRA ))
	RestArea( aArea )

Return lGeneXML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ObtRegSRC³ Autor ³ Laura Medina Prado    ³ Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para obtener el numero de dias pagados.            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtRegSRC(nOpc)                                            ³±±
±±³          ³ 1 - Dias pagados                                           ³±±
±±³          ³ 2 - Salario Base                                           ³±±
±±³          ³ 3 - Total Gravado Percepciones                             ³±±
±±³          ³ 4 - Total Exento Percepciones                              ³±±
±±³          ³ 5 - Incapacidades                                          ³±±
±±³          ³ 6 - Horas Extra                                            ³±±
±±³          ³ 7 - Total Gravado Deducciones                              ³±±
±±³          ³ 8 - Total Exento Deducciones                               ³±±
±±³          ³ 9 - Dias pagados / Existen registros                       ³±±
±±³          ³ 10 - Otros Pagos                                           ³±±
±±³          ³ Retorno:  nDiasPg                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtRegSRC(nOpc, cSRVCon)
	Local aAreaSRA	:= GetArea()
	Local nDiasPg	:= 0
	Local cQuerySRC	:= "" //Trayectorial laboral
	Local cAliasSRC	:= GetNextAlias()
	Local nConsec	:= 0  //Consecutivo para las incapacidades
	Local cID0447	:= '0447'
	Local cID0492	:= '0492'
	Local cID0493	:= '0493'
	Local cQrAlias	:= "" //Alias de la tabla en uso (SRC/SRD)

	Default cSRVCon	:= ""

	lExistReg := .F.

	If lEsPerAb
		cQrAlias := "SRC"
		cQrIdent := "RC"

	Else
		cQrAlias := "SRD"
		cQrIdent := "RD"

	EndIf

	If nOpc == 1 .Or. nOpc == 9     //Dias Pagados
		cQuerySRC := " SELECT " + cQrIdent + "_HORAS RC_HORAS"

	ElseIf nOpc == 2 //Salario Base
		cQuerySRC := " SELECT sum(" + cQrIdent + "_VALOR) RC_HORAS"

	ElseIf nOpc == 5 //Incapacidades
		cQuerySRC := " SELECT " + cQrIdent + "_HORAS RC_HORAS," + cQrIdent + "_VALOR RC_VALOR, RCM_TIPSAT"

	ElseIf nOpc == 6 //Horas Extra
		cQuerySRC := " SELECT RV_CODFOL, SUM(" + cQrIdent + "_VALOR) RC_VALOR, SUM (" + cQrIdent + "_HORAS) RC_HORAS, RV_COD"

	EndIf

	cQuerySRC += " FROM " + RetSqlName(cQrAlias) + " SRC "

	If nOpc == 5 //Incapacidades
		cQuerySRC += ", " + RetSqlName("RCM") + " RCM "
	EndIf

	If nOpc == 6 //Percepciones/Deducciones/Horas Extra
		cQuerySRC += ", " + RetSqlName("SRV") + " SRV "
	EndIf

	cQuerySRC += " WHERE " + cQrIdent + "_FILIAL ='" + SRA->RA_FILIAL + "' AND "
	cQuerySRC += cQrIdent + "_MAT ='" + SRA->RA_MAT + "' AND "
	cQuerySRC += cQrIdent + "_PERIODO ='" + cPeriodo + "' AND "
	cQuerySRC += cQrIdent + "_SEMANA ='" + Semana + "' AND "
	cQuerySRC += cQrIdent + "_PROCES ='" + cProcesso + "' AND "
	cQuerySRC += cQrIdent + "_ROTEIR ='" + cRoteiro + "' AND "

	If  nOpc == 1
		cQuerySRC += cQrIdent + "_PD ='" + cConcpDPg + "' AND "

	ElseIf nOpc == 2
		cQuerySRC += cQrIdent + "_PD IN (" + cSRVCon + ") AND "

	ElseIf nOpc == 5    //Incapacidades
		cQuerySRC += " ( (" + cQrIdent + "_PD = RCM_PD  AND RCM_TPIMSS='2') AND "
		cQuerySRC += "    RCM_FILIAL ='" + XFILIAL("RCM") + "' AND RCM.D_E_L_E_T_<>'*' ) AND "

	ElseIf nOpc == 6    //Horas Extra
		cQuerySRC += " ( " + cQrIdent + "_PD = RV_COD  AND (RV_CODFOL = '" + cID0447 + "' OR RV_CODFOL = '" + cID0492 + "' OR RV_CODFOL = '" + cID0493 + "')) AND "

	EndIf

	If  nOpc == 6
		cQuerySRC += "    RV_FILIAL ='" + XFILIAL("SRV") + "' AND SRV.D_E_L_E_T_<>'*' AND "
	EndIf

	cQuerySRC += "SRC.D_E_L_E_T_<>'*' "

	If  nOpc == 6
		cQuerySRC += " GROUP BY RV_COD, RV_CODFOL "
	EndIf

	cQuerySRC := ChangeQuery(cQuerySRC)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySRC),cAliasSRC,.T.,.T.)
	(cAliasSRC)->( dbGoTop() )

	If  nOpc < 3 .Or. nOpc == 9 //.Or.  nOpc == 7  .Or.  nOpc == 8
		IF  !(cAliasSRC)->(Eof())
			nDiasPg := (cAliasSRC)->RC_HORAS

			If  nOpc == 9
				lExistReg := .T.
			EndIf
		EndIf

	ElseIf nOpc == 5   //Incapacidades
		IF  !(cAliasSRC)->(Eof())
			While (cAliasSRC)->(!Eof() )
				nConsec ++
				dbSelectArea("SRCIN")
				SRCIN->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RCM_TIPSAT

				If !SRCIN->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+STRZERO(nConsec) ))
					RecLock("SRCIN",.T.)
					SRCIN->RA_FILIAL := SRA->RA_FILIAL        		//Filial
					SRCIN->RA_MAT    := SRA->RA_MAT        			//Matricula
					SRCIN->RC_ITEM   := STRZERO(nConsec,2)    		//Consecutivo
					SRCIN->RC_HORAS  := (cAliasSRC)->RC_HORAS 		//Dias Incapacidad
					SRCIN->RCM_TIPSAT:= (cAliasSRC)->RCM_TIPSAT	//Tipo Incapacidad
					SRCIN->RC_VALOR  := (cAliasSRC)->RC_VALOR		//Descuento
					SRCIN->(MsUnlock())
				EndIf

				(cAliasSRC)->(dbSkip())
			Enddo
		EndIf

	ElseIf nOpc == 6  //Horas Extra
		IF  !(cAliasSRC)->(Eof())
			While (cAliasSRC)->( !Eof())
				nConsec ++
				dbSelectArea("SRCEX")
				SRCEX->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_CODFOL

				If !SRCEX->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+(cAliasSRC)->RV_CODFOL))
					RecLock("SRCEX",.T.)
					SRCEX->RA_FILIAL := SRA->RA_FILIAL        		//Filial
					SRCEX->RA_MAT    := SRA->RA_MAT        			//Matricula
					SRCEX->RGB_DUM   := ObtDias((cAliasSRC)->RV_CODFOL)   //Dias
					SRCEX->RV_CODFOL := Alltrim((cAliasSRC)->RV_CODFOL)//Iif(Alltrim((cAliasSRC)->RV_CODFOL)==cID0446 .Or. Alltrim((cAliasSRC)->RV_CODFOL)==cID0493,"01","02") 	//Tipo Horas (valor fijo: Dobles/Triples)
					SRCEX->RC_HORAS  := (cAliasSRC)->RC_HORAS		//Horas Extras
					SRCEX->RC_VALOR  := (cAliasSRC)->RC_VALOR 		//Importe pagado
					SRCEX->RV_COD    := (cAliasSRC)->RV_COD
					SRCEX->(MsUnlock())
				EndIf

				(cAliasSRC)->(dbSkip())
			Enddo
		EndIf

	EndIf

	(cAliasSRC)->( DBCloseArea() )
	RestArea( aAreaSRA )

Return nDiasPg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ObtConcep³ Autor ³ Laura Medina Prado    ³ Data ³ 06/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para obtener los conceptos con Id de calculo 0543  ³±±
±±³          ³ (gravado 113), XXXX(gravado del 142) y 0476(liquidacion).  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtConcep()                                                ³±±
±±³          ³ Retorno:  cConceptos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtConcep(nOpc)
	Local aAreaSRA	:= GetArea()
	Local cQuerySRV	:= "" //Trayectorial laboral
	Local cAliasSRV	:= GetNextAlias()
	Local cIDCalc	:= "('0543','0476','1278')"     //ID'S
	Local cConceptos:= ""

	/*nOpc
	1- Id's para Salario Base Cotizacion
	2- Id'  para Dias Pagados */

	If nOpc== 1

		If  lEsExMar  //Es exepcion
			cIDCalc   := "('0543','0476')"

		Else
			cIDCalc   := "('0543','0476','1376')"
			//0543 - Gravado 113
			//0476 - Liquidacion
			//1376 - Total Percepcion Gravada 142

		EndIf

	Else
		cIDCalc   := "('0989')"
		//0989 - Dias Trabajados

	EndIf

	cQuerySRV := " SELECT RV_COD"
	cQuerySRV += " FROM " + RetSqlName("SRV") + " SRV "
	cQuerySRV += " WHERE RV_FILIAL ='" + XFILIAL("SRV") + "' AND "
	cQuerySRV += " RV_CODFOL IN "+cIDCalc+" AND "
	cQuerySRV += " SRV.D_E_L_E_T_<>'*'

	cQuerySRV := ChangeQuery(cQuerySRV)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySRV),cAliasSRV,.T.,.T.)
	(cAliasSRV)->( dbGoTop() )

	IF  !(cAliasSRV)->(Eof())
		While !(cAliasSRV)->(Eof())
			cConceptos += "'"+(cAliasSRV)->RV_COD+"',"
			(cAliasSRV)->(dbSkip())
		Enddo
	EndIf

	(cAliasSRV)->( DBCloseArea() )

	If !Empty(cConceptos)
		If  nOpc ==2
			cConceptos := Substr(Alltrim(cConceptos),2,len(cConceptos)-3)

		Else
			If  lEsExMar  //Es exepcion
				If !Empty(cMV_PGRAV)
					cConceptos += "'"+Alltrim(cMV_PGRAV)+"',"
				EndIf
			EndIf

			cConceptos := Substr(Alltrim(cConceptos),1,len(cConceptos)-1)

		EndIf
	EndIf

	RestArea( aAreaSRA )

Return cConceptos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ObtDias  ³ Autor ³ Laura Medina Prado    ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para obtener el numero total de dias de Horas Extra³±±
±±³          ³ generados en el periodo.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtDias()                                                  ³±±
±±³          ³ Retorno:  nDias                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtDias(cIDCalc)
	Local aAreaSRA		:= GetArea()
	Local cQueryDIAS	:= ""
	Local cAliasDIAS	:= GetNextAlias()
	Local nDias			:= 0
	Local cIDDias		:= ""

	If lEsPerAb
		cQrAlias := "SRC"
		cQrIdent := "RC"
	Else
		cQrAlias := "SRD"
		cQrIdent := "RD"
	EndIf

	If  cIDCalc $ '0492|0493'	//Dobles (cIDCalc == '0446')
		cIDDias := '1377'		//ID's
	ElseIf cIDCalc == '0447'	//Tripes (cIDCalc == '0447')
		cIDDias := '1378'		//ID's
	EndIf

	cQueryDIAS := " SELECT " + cQrIdent+"_HORAS RC_HORAS "
	cQueryDIAS += " FROM " + RetSqlName(cQrAlias) + " SRC," + RetSqlName("SRV")+ " SRV "
	cQueryDIAS += " WHERE "+cQrIdent+"_FILIAL ='"+SRA->RA_FILIAL+"' AND "
	cQueryDIAS += " RV_FILIAL  ='"+XFILIAL("SRV")+"'  AND "
	cQueryDIAS += cQrIdent + "_MAT ='" + SRA->RA_MAT + "' AND "
	cQueryDIAS += cQrIdent + "_PERIODO ='" + cPeriodo + "' AND "
	cQueryDIAS += cQrIdent + "_SEMANA ='" + Semana + "' AND "
	cQueryDIAS += cQrIdent + "_PROCES ='" + cProcesso + "' AND "
	cQueryDIAS += cQrIdent + "_ROTEIR ='" + cRoteiro + "' AND  "
	cQueryDIAS += cQrIdent + "_PD = RV_COD  AND RV_CODFOL = '" + cIDDias + "' AND "
	cQueryDIAS += " SRC.D_E_L_E_T_<>'*' AND "
	cQueryDIAS += " SRV.D_E_L_E_T_<>'*' "

	cQueryDIAS := ChangeQuery(cQueryDIAS)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDIAS),cAliasDIAS,.T.,.T.)
	(cAliasDIAS)->( dbGoTop() )

	IF  !(cAliasDIAS)->(Eof())
		While (cAliasDIAS)->( !Eof())
			nDias += (cAliasDIAS)->RC_HORAS
			(cAliasDIAS)->(dbSkip())
		Enddo
	EndIf
	(cAliasDIAS)->( DBCloseArea() )

	RestArea( aAreaSRA )

Return nDias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GenRNom884³ Autor ³ Laura Medina Prado    ³ Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generación del XML para enviar al PAC y que regrese el Tim-³±±
±±³          ³ bre digital (se basa en el GPER884.ini).                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GpeaXXX()                                                  ³±±
±±³          ³ Retorno:  aGenXML[]                                        ³±±
±±³          ³ 1 - (.T.) Si genero correctamente el XML                   ³±±
±±³          ³ 2 - Timbre Fiscal                                          ³±±
±±³          ³ 3 - Descripción del error en caso de que no se genere XML. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GenRNom884()
	Local aAreaSRA	:= GetArea()
	Local lGeneXML	:= .T.
	Local lMv_CFDi40:= SuperGetmv("MV_CFDI40", .F., .F.)
	Local cNorma	:= IIF(lMv_CFDi40 .And. SRA->(ColumnPos("RA_FISCALI")) > 0 , "GPER88440.INI", "GPER884.INI")
	Local cDir		:= &(cRUTASRV)       // "\cfd\recibos\"        "D:\TEMP\"
	Local cDest		:= Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+Alltrim(MV_PAR03)+Alltrim(MV_PAR04)+"_"+SRA->RA_FILIAL+SRA->RA_MAT +Iif(lImprIndem,"_indem","") //Proceso+Roteiro+Periodo+No.Pago+"_"Filial+Matricula
	Local cDrive	:= ""
	Local cExt		:= ".xml"
	Local aProcFil	:= {.F.,cFilAnt}
	Local aTrab		:= {}
	Local nX		:= 0

	cNewFile := cDir + cDest
	SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)
	cDir := cDrive + cDir
	cDest += ".xml"
	cDirRec := cDir

	Makedir(cDirRec)
	Makedir("\HTTP\")

	dbSelectArea("SX3")
	dbSetOrder(1)
	Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ferase no array aTrab                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aTrab)
		Ferase(AllTrim(aTrab[nX][1]))
	Next

	RestArea( aAreaSRA )

Return lGeneXML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LocTrab884³ Autor ³ Laura Medina Prado    ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta los archivos de trabajo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cTpArq - > Area de trabajo a crear.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LocTrab884(cTpArq)
	Local aAreaSRA	:= GetArea()
	Local cArqSRV	:= "" //Percepciones-Deducciones
	local aStrutSRV	:= {}
	Local cArqINCAP	:= "" //Incapacidad
	local aStrutINC	:= {}
	Local cArqHREXT	:= "" //Horas Extra
	Local aStrutHEX	:= {}
	Local aOrdem	:= {}

	If Select(cTpArq) > 0
		DbSelectArea(cTpArq)
		DBCloseArea()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Creacion del archivo de Trabajo - Percepciones/Deducciones              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpArq == "SRVPD"     //Detalle percepciones y deducciones
		AADD(aStrutSRV,{"RA_FILIAL"	,"C",GetSx3Cache("RA_FILIAL","X3_TAMANHO")   ,0}) 	//Filial
		AADD(aStrutSRV,{"RA_MAT"    ,"C",GetSx3Cache("RA_MAT","X3_TAMANHO")      ,0}) 	//Matricula
		AADD(aStrutSRV,{"RV_TIPO"	,"C",1,0}) 											//Tipo (1-Percepcion/2-Deduccion)
		AADD(aStrutSRV,{"RV_ITEM"	,"C",2,0}) 											//Consecutivo
		AADD(aStrutSRV,{"RV_TIPSAT"	,"C",GetSx3Cache("RV_TIPSAT","X3_TAMANHO")   ,0}) 	//Tipo Percepcion
		AADD(aStrutSRV,{"RV_COD"    ,"C",GetSx3Cache("RV_COD","X3_TAMANHO")      ,0}) 	//Clave
		AADD(aStrutSRV,{"RV_DESCDET","C",GetSx3Cache("RV_DESCDET","X3_TAMANHO")  ,0}) 	//Concepto
		AADD(aStrutSRV,{"RC_VALORGV","N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6})	//Importe Gravado
		AADD(aStrutSRV,{"RC_VALOREX","N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6})	//Importe Exento
		AADD(aStrutSRV,{"RC_VALOR"  ,"N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6})	//Importe Impuesto
		AADD(aStrutSRV,{"RC_HORAS"  ,"N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6})	//Importe Impuesto
		AADD(aStrutSRV,{"RV_CODFOL" ,"C",GetSx3Cache("RV_CODFOL","X3_TAMANHO")   ,0})	//ID Calculo
		AADD(aStrutSRV,{"RV_DECLANU","C",GetSx3Cache("RV_DECLANU","X3_TAMANHO")  ,0})	//ID Declaracion Anual

		oTmpTable := FWTemporaryTable():New("SRVPD")
		oTmpTable:SetFields( aStrutSRV )

		aOrdem	:=	{"RA_FILIAL","RA_MAT","RV_TIPO","RV_COD","RV_ITEM"}

		oTmpTable:AddIndex("I1", aOrdem)
		oTmpTable:Create()

		DbSelectArea("SRVPD")
		DbSetOrder(1)
		Aadd(aTmpArea,{"SRVPD",cArqSRV})

	ElseIf cTpArq == "SRCIN"  //Incapacidades
		AADD(aStrutINC,{"RA_FILIAL"	,"C",GetSx3Cache("RA_FILIAL","X3_TAMANHO")   ,0}) 	//Filial
		AADD(aStrutINC,{"RA_MAT"    ,"C",GetSx3Cache("RA_MAT","X3_TAMANHO")      ,0}) 	//Matricula
		AADD(aStrutINC,{"RC_ITEM"	,"C",2,0}) 											//Consecutivo
		AADD(aStrutINC,{"RC_HORAS"	,"N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6}) 	//Dias Incapacidad
		AADD(aStrutINC,{"RCM_TIPSAT","C",GetSx3Cache("RCM_TIPSAT","X3_TAMANHO")  ,0}) 	//Tipo Incapacidad
		AADD(aStrutINC,{"RC_VALOR"  ,"N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6}) 	//Descuento

		oTmpTable := FWTemporaryTable():New("SRCIN")
		oTmpTable:SetFields( aStrutINC )

		aOrdem	:=	{"RA_FILIAL","RA_MAT","RC_ITEM"}

		oTmpTable:AddIndex("I1", aOrdem)
		oTmpTable:Create()

		DbSelectArea("SRCIN")
		DbSetOrder(1)
		Aadd(aTmpArea,{"SRCIN",cArqINCAP})

	ElseIf cTpArq == "SRCEX"   //Horas Extra
		AADD(aStrutHEX,{"RA_FILIAL"	,"C",GetSx3Cache("RA_FILIAL","X3_TAMANHO")   ,0}) 	//Filial
		AADD(aStrutHEX,{"RA_MAT"    ,"C",GetSx3Cache("RA_MAT","X3_TAMANHO")      ,0})	//Matricula
		AADD(aStrutHEX,{"RGB_DUM"	,"N",4,2})     										//Dias
		AADD(aStrutHEX,{"RV_CODFOL" ,"C",7,0}) 											//Tipo Horas (valor fijo: Dobles/Triples)
		AADD(aStrutHEX,{"RC_HORAS"  ,"N",GetSx3Cache("RC_HORAS","X3_TAMANHO")    ,0}) 	//Horas Extras
		AADD(aStrutHEX,{"RC_VALOR"  ,"N",GetSx3Cache("RC_VALOR","X3_TAMANHO") + 4,6}) 	//Importe pagado
		AADD(aStrutHEX,{"RV_COD"    ,"C",GetSx3Cache("RV_COD","X3_TAMANHO")      ,0}) 	//Clave

		oTmpTable := FWTemporaryTable():New("SRCEX")
		oTmpTable:SetFields( aStrutHEX )

		aOrdem	:=	{"RA_FILIAL","RA_MAT","RV_CODFOL","RV_COD"}

		oTmpTable:AddIndex("I1", aOrdem)
		oTmpTable:Create()

		DbSelectArea("SRCEX")
		DbSetOrder(1)
		Aadd(aTmpArea,{"SRCEX",cArqHREXT})

	EndIf

	RestArea( aAreaSRA )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelATbr884 ³ Autor ³ Laura Medina Prado   ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Borra los archivos de trabajo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DelATbr884()
	Local nI := 0

	For nI := 1 To Len(aTmpArea)
		If Select(aTmpArea[nI,1]) > 0
			dbSelectArea(aTmpArea[nI])
			&(aTmpArea[nI,1])->(dbCloseArea())
		EndIf
	Next nI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldCad884  ³ Autor ³ Laura Medina Prado   ³ Data ³ 20/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para armar la cadena origal: 1-Percepciones (SRVPD)³±±
±±³          ³ 2-Deducciones (SRVPD), 3-Incapacidades (SRVIN) y 4-Horas   ³±±
±±³          ³ Extr (SRCEX).                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldCad884(cTipoCon)
	Local aArea		:= GetArea()
	Local cTmpCadOrg:= ""//	cCadOrig
	Local cTmpCadAoT:= ""//Acciones o titulos
	Local cPipe     := "|"
	Local lHrExtD   := .F.
	Local lSubEmpT  := .T.

	If  cTipoCon=="1" .Or.  cTipoCon=="2" .Or.  cTipoCon=="3"   //Percepciones o Deducciones
		dbSelectArea("SRVPD")
		SRVPD->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM

		If  SRVPD->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon))
			While SRVPD->( !Eof() .And.  SRVPD->RA_FILIAL+SRVPD->RA_MAT+SRVPD->RV_TIPO==SRA->RA_FILIAL+SRA->RA_MAT+cTipoCon)
				cTmpCadOrg += Alltrim(SUBSTR(SRVPD->RV_TIPSAT,1,3)) +cPipe
				cTmpCadOrg += Alltrim(SRVPD->RV_COD) + cPipe
				cTmpCadOrg += Alltrim(SRVPD->RV_DESCDET) + cPipe

				If cTipoCon=="1"
					cTmpCadOrg += Alltrim(Transform(Round(SRVPD->RC_VALORGV,2), "99999999.99")) + cPipe
					cTmpCadOrg += Alltrim(Transform(Round(SRVPD->RC_VALOREX,2), "99999999.99"))+ cPipe

				ElseIf cTipoCon=="2" .Or. cTipoCon=="3"
					cTmpCadOrg += Alltrim(Transform(Round(SRVPD->RC_VALORGV + SRVPD->RC_VALOREX,2), "99999999.99")) + cPipe

				EndIf

				If Alltrim(SRVPD->RV_DECLANU) $ ("41K|41l") .And. (nValorMer <> 0 .Or. nPrecOtor <> 0) .And. (Empty(cTmpCadAoT) .And. cTipoCon=="1")/*Acciones O Titulos*/
					cTmpCadAoT += Alltrim(Transform(Round(nValorMer,2), "99999999.99")) + cPipe
					cTmpCadAoT += Alltrim(Transform(Round(nPrecOtor,2), "99999999.99")) + cPipe
					cTmpCadOrg += cTmpCadAoT

				ElseIf Alltrim(SRVPD->RV_CODFOL) == "0514" .And. cTipoCon == "3"/*Subsidio Al Empleo*/
					cTmpCadOrg += Alltrim(Transform(Round(IIf(nSubsidio > 0, nSubsidio, 0.01), 2), "99999999.99")) + cPipe
					lSubEmpT := .F.

				ElseIf Alltrim(SRVPD->RV_CODFOL) =="0477" .And. cTipoCon=="3"/*Compensacion Saldos A Favor*/
					cTmpCadOrg += Alltrim(Transform(Round(nSaldoFav,2), "99999999.99")) + cPipe
					cTmpCadOrg += Alltrim(Str(nAnio)) + cPipe
					cTmpCadOrg += Alltrim(Transform(Round(nRemSaldF,2), "99999999.99")) + cPipe

				ElseIf cTipoCon=="1"/*Horas Extras*/
					SRCEX->(DbGotop())

					If SRVPD->RV_CODFOL == "0447"
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+RV_CODFOL)))//Triples Gravadas
							cTmpCadOrg += Alltrim(Str(IIf(SRCEX->RGB_DUM == 0 , 1, SRCEX->RGB_DUM))) +cPipe
							cTmpCadOrg += "02" + cPipe
							cTmpCadOrg += Alltrim(Str(SRVPD->RC_HORAS)) + cPipe
							cTmpCadOrg += Alltrim(Transform(Round(SRCEX->RC_VALOR, 2),"999999999.99")) + cPipe
						EndIf

					ElseIf SRVPD->RV_CODFOL == "0446"
						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
							lHrExtD := .T.
						EndIf

						If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
							lHrExtD := .T.
						EndIf

						If lHrExtD
							cTmpCadOrg += Alltrim(Str(IIf(SRCEX->RGB_DUM == 0 , 1, SRCEX->RGB_DUM))) +cPipe
							cTmpCadOrg += "01" + cPipe
							cTmpCadOrg += Alltrim(Str(SRVPD->RC_HORAS)) + cPipe
							cTmpCadOrg += Alltrim(Transform(Round(SRVPD->RC_VALORGV + SRVPD->RC_VALOREX,2), "99999999.99")) + cPipe
						EndIf

					EndIf

				EndIf

				SRVPD->(dbSkip())
			Enddo
		EndIf

		If lSubEmpT .And. cTipoCon == "3" .And. lUsaSubPer .And. !lImprIndem
			cTmpCadOrg += '002' +cPipe
			cTmpCadOrg += cCFDICON + cPipe
			cTmpCadOrg += STR0219 + cPipe
			cTmpCadOrg += Alltrim(Transform(Round(0.01,2), "99999999.99")) + cPipe
			cTmpCadOrg += Alltrim(Transform(Round(IIF(nSubsidio>0,nSubsidio ,0.01), 2), "99999999.99")) + cPipe
		EndIf

	ElseIf cTipoCon=="4"  //Incapacidades
		dbSelectArea("SRCIN")
		SRCIN->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RCM_TIPSAT

		If SRCIN->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRCIN->( !Eof() .And.  SRCIN->RA_FILIAL+SRCIN->RA_MAT==SRA->RA_FILIAL+SRA->RA_MAT)
				cTmpCadOrg += Alltrim(Str(SRCIN->RC_HORAS)) +cPipe
				cTmpCadOrg += Alltrim(SRCIN->RCM_TIPSAT) + cPipe
				cTmpCadOrg += Alltrim(Transform(Round(SRCIN->RC_VALOR,2), "99999999.99")) + cPipe
				SRCIN->(dbSkip())
			Enddo
		EndIf

	ElseIf cTipoCon=="5"  //Horas Extra
		dbSelectArea("SRCEX")
		SRCEX->(dbSetOrder(1))   //RA_FILIAL+RA_MAT+RV_CODFOL

		If SRCEX->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRCEX->( !Eof() .And.  SRCEX->RA_FILIAL+SRCEX->RA_MAT==SRA->RA_FILIAL+SRA->RA_MAT)
				cTmpCadOrg += Alltrim(Str(SRCEX->RGB_DUM)) +cPipe
				cTmpCadOrg += Alltrim(SRCEX->RV_CODFOL) + cPipe
				cTmpCadOrg += Alltrim(Str(SRCEX->RC_HORAS)) + cPipe
				cTmpCadOrg += Alltrim(Str(SRCEX->RC_VALOR)) + cPipe
				SRCEX->(dbSkip())
			Enddo
		EndIf
	EndIf

	If !Empty(cTmpCadOrg)
		cCadOrig += cTmpCadOrg
	EndIf

	RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IMPRXML884³ Autor ³ Mayra Camargo         ³ Data ³ 16.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao de Recibos de Pagamento Mexico a partir de xml     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMPRXML884(void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IMPRXML884()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local aDriver:= ReadDriver()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cTitRel		:= ""

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aReturn		:= {STR0009, 1,STR0010, 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Private nomeprog	:= "GPER884"
	Private aLinha		:= { }
	Private nLastKey	:= 0
	Private cPerg		:= "IMPREC"
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe
	Private oFont		:= Nil
	Private cCompac		:= aDriver[1]
	Private cNormal		:= aDriver[2]

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private li			:= 0050
	Private Titulo		:= STR0011		//"EMISSŽO DE RECIBOS DE PAGAMENTOS"
	Private lEnvioOk	:= .T. //modificacion Elena HD 04/10/13
	Private cProcesso	:= MV_PAR01 // Armazena o processo selecionado na Pergunte GPR040 (mv_par01).
	Private cRoteiro	:= MV_PAR02 // Armazena o Roteiro selecionado na Pergunte GPR040 (mv_par02).
	Private cPeriodo	:= MV_PAR03 // Armazena o Periodo selecionado na Pergunte GPR040 (mv_par03).
	Private Semana		:= MV_PAR04 // No. de Pago
	Private nTipRel		:= MV_PAR05	//Tipo de Recibo (Pre/Zebrado/EMail)
	Private cFilDe		:= MV_PAR06	//Filial De
	Private cFilAte		:= MV_PAR07	//Filial Ate
	Private cMatDe		:= MV_PAR08 //Matricula Des
	Private cMatAte		:= MV_PAR09 //Matricula Ate
	Private cNomDe		:= MV_PAR10	//Nome De
	Private cNomAte		:= MV_PAR11	//Nome Ate
	Private ChapaDe		:= MV_PAR12 //Chapa De
	Private ChapaAte	:= MV_PAR13	//Chapa Ate
	Private cCcDe		:= MV_PAR14 //Centro de Custo De
	Private cCcAte		:= MV_PAR15 //Centro de Custo Ate
	Private cDeptoDe	:= MV_PAR16 //Departamento De
	Private cDeptoAte	:= MV_PAR17 //Departamento Ate
	Private cSituacao	:= MV_PAR18	//Situacoes a Imprimir
	Private cCategoria	:= MV_PAR19	//Categorias a Imprimir
	Private DESC_MSG1	:= ""
	Private DESC_MSG2	:= ""
	Private DESC_MSG3	:= ""
	Private cLocalDe	:= Space(Len(SRA->RA_KEYLOC))
	Private cLocalAte	:= Replicate("z", Len(SRA->RA_KEYLOC))
	Private cCcto		:= ""
	Private cCond		:= ""
	Private cRot		:= ""
	Private cMensRec	:= ""
	Private cMensGral	:= "" // Mensaje para cuerpo del Correo (LEMP 13/10/08)
	Private cDescProc	:= ""
	Private cClaveEmp	:= ""
	Private Ordem_Rel	:= 0

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Envia controle para a funcao SETPRINT                        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cTitRel := "GPER884"	//Nome Default do relatorio em Disco

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If cPaisLoc == "MEX"
		cLocalDe	:= MV_PAR24	//De Local Pago
		cLocalAte	:= MV_PAR25	//A Local Pago
	EndIf

	DbSelectArea( "RCJ" )
	DbSetOrder( 1 )  // RCJ_FILIAL + RCJ_CODIGO
	DbSeek( xFilial( "RCJ" ) + cProcesso, .F. )

	cDescProc := SubStr( RCJ->RCJ_DESCRI, 1, 15 )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Inicializa Impressao                                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Processa({|| ImpXml()})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpXML   ³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Procesa XMl para generar PDF                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpXML()
	Local aArea			:= GetArea()
	Local cCaminhoXML	:= &(SuperGetMv("MV_CFDRECN", .F.,""))
	Local oXML			:= Nil
	Local cAviso		:= ""
	Local cErro			:= ""
	Local nI			:= 0
	Local cFile			:= ""
	Local nPosIni		:= 0
	Local nPosFin		:= 0
	Local cFim			:= ""
	Local cRutaPdf		:= ""

	Private tamanho		:= "M"
	Private limite		:= 132
	Private cDtPago		:= ""
	Private cPict1		:= "@E 999,999,999.99"
	Private cPict2		:= "@E 99,999,999.99"
	Private cPict3		:= "@E 999,999.99"
	Private cTipoRot	:= PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_TIPO")
	Private cNomIma		:= ""

	cFim   := cFilAte + cMatAte

	dbSelectArea("SRA")
	dbSetOrder(1)

	For nI:= 1 to len(aArchivos)
		If aArchivos[nI] <> NIL
			cFile		:= aArchivos[nI,1]+".XML"
			nPosIni		:= Rat("_",cFile)+1
			nPosFin		:= Rat(".",cFile)
			if Substr(cFile,nPosIni,nPosfin-nPosIni) == "indem"
				nPosFin := nPosIni-1
				nPosIni := AT("_",cFile)+1
			EndIf
			cClaveEmp	:= Substr(cFile,nPosIni,nPosfin-nPosIni)
			cNomIma		:= aArchivos[nI,1]

			IF SRA->(dbSeek(cClaveEmp)) .and. SRA->RA_FILIAL + SRA->RA_MAT <= cFim  .and. !(;
			(SRA->RA_FILIAL < cFilDe)	.Or. (SRA->RA_FILIAL > cFilAte) .Or. ;
			(SRA->RA_MAT < cMatDe)		.Or. (SRA->RA_MAT > cMatAte)	.Or. ;
			(SRA->RA_NOME < cNomDe)		.Or. (SRA->RA_NOME > cNomAte)	.Or. ;
			(SRA->RA_CHAPA < ChapaDe)	.Or. (SRA->RA_CHAPA > ChapaAte)	.Or. ;
			(SRA->RA_CC < cCcDe)		.Or. (SRA->RA_CC > cCcAte)		.Or. ;
			(SRA->RA_DEPTO < cDeptoDe)	.Or. (SRA->RA_DEPTO > cDeptoAte) .or. ;
			(SRA->RA_KEYLOC < cLocalDe)  .Or. (SRA->RA_KEYLOC > cLocalAte) .or. ;
			(!( SRA->RA_SITFOLH $ cSituacao ) .OR.  !( SRA->RA_CATFUNC $ cCategoria )) )

				IncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
				oXML := XmlParserFile( cCaminhoXML + cFile, "_", @cAviso,@cErro )

				IF Empty(cAviso) .and. Empty(cErro) .and. oXML <> NIL
					li := 100
					If nTipRel == 1
						//Imprime en pantalla
						cRutaPdf := ImpRcNPdf(cNomIma,,,SRA->RA_FILIAL,SRA->RA_MAT)
					Else
						fSendDPgto(oXML,cNomIma)
					EndIF
				EndIf

				FreeObj(oXML)
			EndIf
		EndIf
	Next nI

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSendDPgtoºAutor  ³mayra.camargo       º Data ³ 24/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envía por mail el  htm generado a partir del xml.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSendDPgto(oXml,cNomIma) //original
	Local aSvArea		:= GetArea()
	Local cEmail		:= SRA->RA_EMAIL
	Local cHtml			:= ""
	Local cSubject		:= STR0017 //gsa STR0044	//" DEMONSTRATIVO DE PAGAMENTO "
	Local aRutaPdf		:= ""
	Local lEmail		:= .T.
	Local nLoop			:= 0

	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL
	Private lAutentica	:= .F.
	Private cPwAut		:= ""
	Private cAcAut		:= ""

	cHtml := "RY_DESC"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca parametros                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMailConta	:= IIf(cMailConta == NIL,SuperGetmv("MV_RELACNT", .F., ""),cMailConta)           //Conta utilizada p/envio do email
	cMailServer	:= IIf(cMailServer == NIL,SuperGetmv("MV_RELSERV", .F., ""),cMailServer)           //Server
	cMailSenha	:= IIf(cMailSenha == NIL,SuperGetmv("MV_RELAPSW", .F., ""),cMailSenha)

	///Autentificación  para envio de Email externo // elena HD 04/10/13
	lAutentica := SuperGetmv("MV_RELAUTH", .F., .F.)
	cPwAut 	:= SuperGetmv("MV_RELAPSW", .F., "")	//Contrasena para autenticacion en servidor de e-mai
	cAcAut	:= SuperGetmv("MV_RELAUSR", .F., "")	//Usuario para Autenticacion en el Servidor de Email

	If Empty(cEmail)
		Help("",1,"")
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o SMTP Server                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Empty(cMailServer)
		Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe a CONTA                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Empty(cMailConta)
		Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe a Senha                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Empty(cMailServer)
		Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
		Return(.F.)
	EndIf

	aRutaPdf = ImpRcNPdf(cNomIma,,,SRA->RA_FILIAL,SRA->RA_MAT,lEmail)
	lEnvioOK := EnvRecMail(cSubject,cHtml,cEmail,aRutaPdf)

	RestArea( aSvArea )

	For nLoop := 1 To Len(aRutaPdf)
		If SubStr(Alltrim(aRutaPdf[nLoop]),Len(Alltrim(aRutaPdf[nLoop]))-2,3) $ "PDF|pdf"
			FErase(aRutaPdf[nLoop])
		EndIf
	Next nLoop
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EnvRecMail³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia correo electronico con XML y PDF                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EnvRecMail(cAssunto,cMensaje,cEmail,_aAnexo)
	Local oMailServer	:= Nil
	Local oMessage		:= Nil
	Local cEmailTo		:= ""
	Local cEmailBcc		:= ""
	Local cError		:= ""
	Local cEMailAst		:= cAssunto

	// Verifica se serao utilizados os valores padrao.
	Local cAccount		:= SuperGetmv("MV_RELACNT", .F., "")
	Local cPassword		:= SuperGetmv("MV_RELPSW", .F., "")
	Local cServer		:= SuperGetmv("MV_RELSERV", .F., "") //smtp.microsiga.com.br
	Local cAttach		:= ""
	Local cFrom			:= cAccount
	Local lUseTLS		:= SuperGetmv("MV_RELTLS", .F., .F.)    //Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL/TLS);
	Local lUseSSL		:= SuperGetmv("MV_RELSSL", .F., .F.)	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lAuth			:= SuperGetmv("MV_RELAUTH", .F., .F.)	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local nPort			:= SuperGetmv("MV_SRVPORT", .F., 25)
	Local lResult		:= .F.
	Local nX			:= 0
	Local NI			:= 0

	Default _aAnexo		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense³
	//³que somente ela recebeu aquele email, tornando o email mais personalizado.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmailTo := cEmail

	If Empty(nPort)
		nPort := 25
	EndIf

	If !lAuth

		For nI:= 1 to Len(_aAnexo)
			cAttach += _aAnexo[nI] + "; "
		Next nI

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		If lResult
			SEND MAIL FROM cFrom ;
			TO      	cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cEMailAst;
			BODY    	cEMailAst;
			ATTACHMENT  cAttach  ;
			RESULT lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				Help(" ",1,STR0171,,cError,4,5)
			EndIf

			DISCONNECT SMTP SERVER

		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError

			Help(" ",1,STR0171,,cError,4,5)

		EndIf

		DISCONNECT SMTP SERVER

	Else
		//Instancia o objeto do MailServer
		oMailServer:= TMailManager():New()
		oMailServer:SetUseSSL(lUseSSL)				//Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
		oMailServer:SetUseTLS(lUseTLS) 				//Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento
		oMailServer:Init("",cServer,cAccount,cPassword,0,nPort)

		//Definição do timeout do servidor
		If oMailServer:SetSmtpTimeOut(120) != 0
			Help(" ",1,STR0171,,STR0172 ,4,5)
			Return .F.
		EndIf

		//Conexão com servidor
		nErr := oMailServer:smtpConnect()

		If nErr <> 0
			Help(" ",1,STR0171,,oMailServer:getErrorString(nErr),4,5)
			oMailServer:smtpDisconnect()
			Return .F.
		EndIf

		//Autenticação com servidor smtp
		nErr := oMailServer:smtpAuth(cAccount, cPassword)

		If nErr <> 0
			Help(" ",1,STR0171,,STR0173 + oMailServer:getErrorString(nErr),4,5)
			oMailServer:smtpDisconnect()
			return .F.
		EndIf

		//Cria objeto da mensagem+
		oMessage := tMailMessage():new()
		oMessage:clear()
		oMessage:cFrom := cFrom
		oMessage:cTo := cEmailTo
		oMessage:cCc := cEmailBcc
		oMessage:cSubject :=  cEMailAst
		oMessage:cBody := cEMailAst

		For nX := 1 to Len(_aAnexo)
			oMessage:AddAttHTag("Content-ID: <" + _aAnexo[nX] + ">")	//Essa tag, ?a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
			xRet := oMessage:AttachFile( _aAnexo[nX] )

			If xRet < 0
				cMsg := "Could not attach file " + _aAnexo[nX]
				conout( cMsg )
				return
			EndIf
		Next nX

		//Dispara o email
		nErr := oMessage:send(oMailServer)
		If nErr <> 0
			Help(" ",1,STR0171,,STR0174 + oMailServer:getErrorString(nErr),4,5)
			oMailServer:smtpDisconnect()
			Return .F.

		Else
			lResult := .T.

		EndIf

		//Desconecta do servidor
		oMailServer:smtpDisconnect()
		FreeObj(oMailServer)
		FreeObj(oMessage)
	EndIf

Return(lResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NodOpcion ³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea nodos opcionales                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function NodOpcion(nTipoNodo)
	Local lHrExtD := .F.

	If nTipoNodo == 1 //Acciones o Titulos
		If Alltrim(SRVPD->RV_DECLANU) $ ("41K|41l") .And. (nValorMer <> 0 .Or. nPrecOtor <> 0)
			cNodoAccT := '                <nomina12:AccionesOTitulos'
			cNodoAccT += ' ValorMercado="' + Alltrim(Transform(Round(nValorMer, 2),"999999999.99")) + '"'
			cNodoAccT += ' PrecioAlOtorgarse="' + Alltrim(Transform(Round(nPrecOtor, 2),"999999999.99")) + '"/>'
			nValorMer := 0
			nPrecOtor := 0

		Else
			cNodoAccT := ""

		EndIf

	ElseIf nTipoNodo == 2 //Horas Extras
		SRCEX->(DbGotop())

		If SRVPD->RV_CODFOL == "0447"
			If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+RV_CODFOL)))
				cNodoHExt := '                <nomina12:HorasExtra'
				cNodoHExt += ' Dias="' + Alltrim(Str(IIf(SRCEX->RGB_DUM == 0 , 1, SRCEX->RGB_DUM))) + '"'
				cNodoHExt += ' TipoHoras="' + "02" + '"'
				cNodoHExt += ' HorasExtra="' + Alltrim(Str(SRVPD->RC_HORAS)) + '"'
				cNodoHExt += ' ImportePagado="' + Alltrim(Transform(Round(SRCEX->RC_VALOR, 2),"999999999.99")) + '"'
				cNodoHExt += '/>'
			EndIf

		ElseIf SRVPD->RV_CODFOL == "0446"
			If SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0492")))//Dobles Gravadas
				lHrExtD := .T.
			ElseIf SRCEX->(dbSeek(SRVPD->(RA_FILIAL+RA_MAT+"0493")))//Dobles Exentas
				lHrExtD := .T.
			EndIf

			If lHrExtD
				cNodoHExt := '                <nomina12:HorasExtra'
				cNodoHExt += ' Dias="' + Alltrim(Str(IIf(SRCEX->RGB_DUM == 0 , 1, SRCEX->RGB_DUM))) + '"'
				cNodoHExt += ' TipoHoras="' + "01" + '"'
				cNodoHExt += ' HorasExtra="' + Alltrim(Str(SRVPD->RC_HORAS)) + '"'
				cNodoHExt += ' ImportePagado="' + Alltrim(Transform(Round(SRVPD->RC_VALORGV + SRVPD->RC_VALOREX,2), "99999999.99")) + '"'
				cNodoHExt += '/>'
			EndIf

		Else
			cNodoHExt := ""

		EndIf

	ElseIf nTipoNodo == 3 //Subsidio al empleo
		If Alltrim(SRVPD->RV_CODFOL) == "0514"
			cNodoSubE := '                <nomina12:SubsidioAlEmpleo'
			cNodoSubE += ' SubsidioCausado="' + Alltrim(Transform(Round(IIF(nSubsidio>0,nSubsidio ,0.01), 2),"999999999.99")) + '"/>'

		Else
			cNodoSubE := ""

		EndIf

	ElseIf nTipoNodo == 4 //Compensacion Saldos A Favor
		If Alltrim(SRVPD->RV_CODFOL) =="0477"
			cNodoComp := '                <nomina12:CompensacionSaldosAFavor'
			cNodoComp += ' SaldoAFavor="' + Alltrim(Transform(Round(nSaldoFav, 2),"999999999.99")) + '"'
			cNodoComp += ' Año="' + Alltrim(Str(nAnio)) + '"'
			cNodoComp += ' RemanenteSalFav="' + Alltrim(Transform(Round(nRemSaldF, 2),"999999999.99")) + '"'
			cNodoComp += '/>'
			nSaldoFav := 0
			nRemSaldF := 0

		Else
			cNodoComp := ""

		EndIf

	ElseIf nTipoNodo == 5
		If SRA->RA_PORSUB <> 0
			cNodoSubC := '            <nomina12:SubContratacion'
			cNodoSubC += ' RfcLabora="' + Alltrim(SRA->RA_RFCLAB) + '" '
			cNodoSubC += ' PorcentajeTiempo="' + Alltrim(Str(SRA->RA_PORSUB)) + '" '
			cNodoSubC += '/>'

		Else
			cNodoSubC := ""

		EndIf

	ElseIf nTipoNodo == 6
		If !Empty(cOrigRecur)
			cNodoSNCF := '            <nomina12:EntidadSNCF'
			cNodoSNCF += ' OrigenRecurso="' + cOrigRecur + '"'
			cNodoSNCF += ' MontoRecursoPropio="' + Alltrim(Transform(Round(nTotPGrav+nTotPExen, 2),"999999999.99")) + '"'
			cNodoSNCF += '/>'

		Else
			cNodoSNCF := ""

		EndIf

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldNodJub ³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea nodos opcionales                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldNodJub()
	nTotUnaEx := 0; nTotParci := 0; nTotDiari := 0; nTotIAcum := 0; NTotNAcum := 0
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldNodInde³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea nodos opcionales                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldNodInde()
	nTotPagad := 0; nNumAnios := 0; nUltSuelM := 0; nIngrAcum := 0; nIngrNAcu := 0
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpRcNPdf ³ Autor ³ Luis Samaniego        ³ Data ³ 09/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea archivo PDF                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ImpRcNPdf(cProc,cPer,cNumP,cFil,cMat,lEmail)
	Local cCaminhoXML	:= &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))//GetSrvProfString('startpath','\')+'cfd\recibos\'
	Local cPath			:= GetSrvProfString('RootPath','\') //+ 'System\spool\'
	Local oXML			:= Nil
	Local cAviso		:= ""
	Local cErro			:= ""
	Local oPrinter
	LOCAL aArqDir		:= {}
	Local nX			:= 0
	Local cFile			:= ""
	Local cRot			:= ""
	local aItens		:= {}
	Local cArq			:= ""
	Local aFileAux		:= {}
	Local cFileAux		:= ""
	Local cPathHTTP		:= ""
	Local lJob			:= ( Alltrim(FunName()) == "RPC" ) .OR. Empty(FunName())
	Local lZip			:= .F.

	Private cFil2		:= cFil
	Private cMat2		:= cMat
	PRIVATE oFont		:= NIL
	PRIVATE oFont1		:= NIL
	PRIVATE oFont2		:= NIL
	PRIVATE oFont3		:= NIL
	PRIVATE oFont4		:= NIL
	PRIVATE oFont5		:= NIL
	PRIVATE oFont6		:= NIL
	PRIVATE oFont7		:= NIL
	Default lEmail		:= .F.

	If lJob
		cRot := AllTrim(getRoteir())
		cFil := PadR(cFil, GetSx3Cache("RA_FILIAL","X3_TAMANHO"))
		cFile := AllTrim(cProc) + alltrim(cRot) + cPer + cNumP + "_" + cFil + cMat
	Else
		cRot := cRoteiro
		cFile := cProc
	EndIf

	cCaminhoXML := Replace( cCaminhoXML, "\\", "\" )
	cPathHTTP :=  cPath + "\HTTP\"

	IF ISSRVUNIX()
		cCaminhoXML := Replace( cCaminhoXML, "\", "/" )
	EndIf

	If ISSRVUNIX() .Or. Substr(Alltrim(cPath), 1,2) == "\\"
		lZip := .T.
	EndIf

	ClearFolder(cPathHTTP)

	IF lJob
		oPrinter      := FWMSPrinter():New(cFile,6,.F.,cPath,.T.,,,,,.F.,,.F.,)
	Else
		oPrinter      := FWMSPrinter():New(cFile,6,.F.,GetClientDir(),.T.,,,,,.F.)
	EndIf

	oFont1 := TFont():New('Courier new',,40,.T., .T.)
	oFont :=  TFont():New( "ARIAL", , 07, .T., .F.)
	oFont2 := TFont():New( "ARIAL", , 05, .T., .F.)
	oFont3 := TFont():New( "ARIAL", , 10, .T., .T.)
	oFont4 := TFont():New( "ARIAL", , 07, .T., .T.)
	oFont5 := TFont():New( "ARIAL", , 05, .T., .T.)
	oFont6 := TFont():New( "ARIAL", , 07, .T., .F.)
	oFont7 := TFont():New( "ARIAL", , 05, .T., .F.)

	IF lJob
		aArqDir := Directory(cCaminhoXML + "*.*", "D")
	EndIf

	If FILE(cCaminhoXML + cFile + ".XML")
		oXML := XmlParserFile( cCaminhoXML + cFile + '.xml', "_", @cAviso,@cErro )

	Else
		For nX := 1 to Len(aArqDir)
			If aArqDir[nX][5] == "D"
				If FILE(cCaminhoXML + aArqDir[nX][1] + "\" + cFile + ".XML")
					cCaminhoXML := cCaminhoXML + aArqDir[nX][1] + "\"
					oXML := XmlParserFile( cCaminhoXML + cFile + '.xml', "_", @cAviso,@cErro )
					nX := Len(aArqDir)
				EndIf
			EndIf
		Next

	EndIf

	If oXML == NIL
		Return ""
	EndIf

	oPrinter:setDevice(IMP_PDF)

	If !Ljob
		oPrinter:cPathPDF := GetClientDir()
	Else
		oPrinter:cPathPDF := cCaminhoXML //definir ruta dondese guardará, misma ruta variable con extencion .xml
	EndIf

	oPrinter:StartPage()
	ImprRecNom(@oPrinter,oXml)
	oPrinter:EndPage()

	If lJob
		FERASE(cCaminhoXML + cFile + ".pdf")
	ElseIf File( GetClientDir()  + cFile +".pdf")
		FErase(GetClientDir()  + cFile +".pdf")
	EndIf

	If !Ljob
		If lEmail .Or. !lAbrePDF
			oPrinter:SetViewPDF(.F.)
		EndIf
		oPrinter:Print()
	Else
		oPrinter:Print()
		oPrinter:Cancel()
	EndIf

	If !Ljob
		cFileAux := GetClientDir()  + cFile +".pdf"

		If lEmail
			CpyT2S(cFileAux, cCaminhoXML)
			aAdd( aItens, cCaminhoXML + cFile + ".pdf" )
			aAdd( aItens, cCaminhoXML + cFile + ".xml" )

			If lZip
				cArq := tarCompress( aItens, cPathHTTP + cFile + ".Zip" )
				FERASE(cCaminhoXML + cFile + ".pdf" )
				aAdd(aFileAux, StrTran( upper(cArq), upper(GetSrvProfString('rootpath',''))))
			EndIf
		EndIf

	Else
		aAdd( aItens, cCaminhoXML + cFile + ".pdf" )
		aAdd( aItens, cCaminhoXML + cFile + ".xml" )
		cFileAux := Replace( cFile, " ", "_" )

		If lZip
			cArq := tarCompress( aItens, cPathHTTP + cFileAux + ".Zip" )
			FERASE(cCaminhoXML + cFile + ".pdf")
			cFile := SuperGetmv( "MV_HTTPPTL" , .F. , "Undefined" )
		EndIf

		If	cFile == "Undefined"
			aAdd(aFileAux,cFile)
		Else
			aAdd(aFileAux, cFile + cFileAux)
		EndIf

	EndIf

	If !lZip
		aFileAux := AClone(aItens)
	EndIf

	FreeObj(oPrinter)
	oPrinter := Nil

Return aFileAux

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImprRecNom    ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impresion de recibo de nómina.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ImprRecNom(oPrinter,oXml)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oPrinter.- Objeto para impresión de reporte                  ³±±
±±³          ³oXml.- Estructura xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImprRecNom(oPrinter,oXml)
	Private msg			:= ""
	Private li			:= 0
	Private cPict1		:=	"@E 999,999,999.99"
	Private cPict2		:=	"@E 99,999,999.99"
	Private cPict3		:=	"@E 999,999.99"
	Private nEsp1		:= 10
	Private nEsp2		:= 10
	Private nEsp3		:= 15
	Private nEsp4		:= 25
	Private nEspLi1		:= 5
	Private nEspLi2		:= 10
	Private cCertSAT	:= ""

	msg := AllTrim( fDescRCC("S018",MV_PAR23,1,2,5,200) )

	ImpEnc(@oPrinter,oXml)
	fLanca(@oPrinter,oXML)
	fRodape(@oPrinter,oXML)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Imprime   ºAutor  ³mayra.camargo       º Data ³ 24/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera el reporte a base del xml con los datos fiscales    º±±
±±º          ³ y ya timbrado.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEnc(oPrinter,oXml)
	Local cDet			:= ""
	Local cDir			:= ""
	Local cFileLogo		:= ""
	Local cFchRelLab	:= ""
	Local cFchPerIni	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_FechaInicialPago:TEXT
	Local cFchPerFin	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_FechaFinalPago:TEXT
	Local cFchPago		:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_FECHAPAGO:TEXT
	Local cPaisR		:= ""
	Local cCPR			:= ""
	Local cFilSX5		:= xFilial("SX5")

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "FechaInicioRelLaboral")
		cFchRelLab := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_FECHAINICIORELLABORAL:TEXT
		If !Empty(cFchRelLab)
			cFchRelLab := SubStr(cFchRelLab,9,2) + "/" + SubStr(cFchRelLab,6,2) + "/" + SubStr(cFchRelLab,1,4)
		Else
			cFchRelLab := "//"
		EndIf
	EndIf

	//Fecha Pago
	If !Empty(cFchPago)
		cFchPago := substr(cFchPago,9,2)+"/"+substr(cFchPago,6,2)+"/"+substr(cFchPago,1,4)
	Else
		cFchPago := "//"
	EndIf

	//Fecha Inicio Periodo-Pago
	If !Empty(cFchPerIni)
		cFchPerIni := substr(cFchPerIni,9,2)+"/"+substr(cFchPerIni,6,2)+"/"+substr(cFchPerIni,1,4)
	Else
		cFchPerIni := "//"
	EndIf

	//Fecha Final Periodo-Pago
	If !Empty(cFchPerFin)
		cFchPerFin := substr(cFchPerFin,9,2)+"/"+substr(cFchPerFin,6,2)+"/"+substr(cFchPerFin,1,4)
	Else
		cFchPerFin := "//"
	EndIf

	fCarLogo(@cFileLogo)
	oPrinter:Line(5,5,820,5,,"-4") //Linea lateral izquierda
	oPrinter:Line(5,585,820,585,,"-4") //Linea lateral derecha
	oPrinter:Line(5,5,5,585,,"-4")//Linea horizontal de marco

	cDir += rtrim(SM0->M0_ENDCOB) + " "
	cDir += rtrim(SM0->M0_BAIRCOB) + " "
	cDir += rtrim(SM0->M0_ESTCOB) 	+ " "
	cDir += rtrim(SM0->M0_COMPCOB) + ","
	cDir += rTrim(SM0->M0_CEPCOB)

	LI := 10
	If File(cFileLogo)
		oPrinter:SayBitmap(LI,10, cFileLogo,40,30) // Tem que estar abaixo do RootPath
	EndIf

	LI += 15
	oPrinter:Say(LI,250,STR0017,oFont3)
	LI += 15
	oPrinter:Say(LI,250,Alltrim(cDescRot),oFont)
	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	oPrinter:Say(LI,10,STR0097,oFont4)
	oPrinter:Say(LI,55,SM0->M0_NOMECOM,oFont)

	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_EMISOR, "REGISTROPATRONAL")
		oPrinter:SAY(LI,200 ,STR0121,OFONT4)
		oPrinter:SAY(LI,255 ,OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_EMISOR:_REGISTROPATRONAL:TEXT,oFont)
	EndIf

	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_EMISOR, "RFC")
		oPrinter:SAY(LI,355 ,STR0099,OFONT4)
		oPrinter:SAY(LI,375 ,OXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT,oFont)
	EndIf

	LI += nEsp2
	oPrinter:SAY(LI,10 ,STR0098, oFont4)
	oPrinter:SAY(LI,55 , cDir ,oFont)
	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")

	DbSelectArea ("SRA")
	SRA->(DbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT")))
	SRA->(Dbseek(PadR(cFil2,Len(SRA->RA_FILIAL))+cMat2))
	cCPR := SRA->RA_CEP
	cPaisR := SRA->RA_PAIS

	LI += nEspLi2
	oPrinter:SAY(LI,10 , STR0001 + ": " , oFONT4)
	oPrinter:SAY(LI,75 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_NUMEMPLEADO:TEXT,oFont)
	oPrinter:SAY(LI,145 , STR0024,Ofont4)
	oPrinter:SAY(LI,200 , alltrim(SRA->RA_PRISOBR)+" "+alltrim(SRA->RA_SECSOBR)+" "+alltrim(SRA->RA_PRINOME)+" "+alltrim(SRA->RA_SECNOME),oFont)
	Li += nEsp2
	oPrinter:SAY(LI,10 , STR0099, Ofont4)
	oPrinter:SAY(LI,75 , SRA->RA_CIC,oFont)

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "NumSeguridadSocial")
		oPrinter:SAY(LI,145 , STR0122, oFONT4)
		oPrinter:SAY(LI,200 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_NUMSEGURIDADSOCIAL:TEXT,oFont)
	EndIf

	oPrinter:SAY(LI,280 , STR0123 + ": " , oFONT4)
	oPrinter:SAY(LI,335 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_CURP:TEXT,oFont)
	oPrinter:SAY(LI,420 , STR0175, oFONT4)
													//PERIODICIDAD DE PAGO
	oPrinter:SAY(LI,480 , ALLTRIM(fDescRCC("S029",oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_PERIODICIDADPAGO:TEXT,1,2,3,65)) ,oFont)

	/*Correcto*/
	Li += nEsp2

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "Departamento")
		oPrinter:SAY(LI,10 , STR0128, oFONT4)
		oPrinter:SAY(LI,75 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_DEPARTAMENTO:TEXT,oFont)
	EndIf

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "Puesto")
		oPrinter:SAY(LI,280 , STR0133, Ofont4)
		If Len(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_PUESTO:TEXT) >= 22
			oPrinter:SAY(LI+nEsp2,280 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_PUESTO:TEXT,oFont)
		Else
			oPrinter:SAY(LI,335 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_PUESTO:TEXT,oFont)
		Endif
	EndIf

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "TipoContrato")
		oPrinter:SAY(LI,420 , STR0176, oFONT4)															//TIPO DE CONTRATO
		Li += nEsp2
		oPrinter:SAY(LI,420 ,ALLTRIM(fDescRCC("S028",oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_TIPOCONTRATO:TEXT,1,2,3,65)) ,oFont)
		Li += nEsp2
	EndIf

	Li += nEsp2
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "SalarioBaseCotApor")
		oPrinter:SAY(LI,10 ,STR0134, oFONT4)
		oPrinter:SAY(LI,75 , Alltrim(Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_SalarioBaseCotApor:TEXT),cPict2)),oFont)
	EndIf

	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "SalarioDiarioIntegrado")
		oPrinter:SAY(LI,145 ,STR0135, oFONT4)
		oPrinter:SAY(LI,200 , Alltrim(Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_SalarioDiarioIntegrado:TEXT),cPict2)),oFont)
	EndIf

	//Salario int Liq
	If ObtUidXML(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "SalarioIntegralLiquido")
		oPrinter:SAY(LI,280 ,STR0181, oFONT4)
		oPrinter:SAY(LI,335 , oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_SalarioIntegralLiquido:TEXT,oFont)
	EndIf

	//Fecha de Inicio de Relacion Laboral
	If !Empty(cFchRelLab)
		oPrinter:SAY(LI, 420, STR0111, oFONT4)
		oPrinter:SAY(LI, 480, cFchRelLab,oFont)
	EndIf

	Li += nEsp2
	cDet := rtrim(SRA->RA_ENDEREC) + " "
	cDet += rtrim(SRA->RA_COMPLEM) + " "
	cDet += SRA->RA_BAIRRO + " ,"

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) //"X5_FILIAL+X5_TABELA+X5_CHAVE"

	If SX5->(MSSeek(cFilSX5+"12"+SRA->RA_ESTADO))
		cDet += RTrim(X5Descri()) + " "
	EndIf

	cDet += +" CP "+ alltrim(cCPR) + " "

	If SX5->(MSSeek(cFilSX5+"BH"+ALLTRIM(cPaisR)))
		cDet += RTrim(X5Descri())
	EndIf

	If Empty(cLocPago)
		DBSELECTAREA("RGC")
		RGC->(DBSETORDER(RetOrdem("RGC","RGC_FILIAL+RGC_KEYLOC")))
		IF  RGC->(DBSEEK(XFILIAL("RGC")+SRA->RA_KEYLOC))
			cLocPago := Alltrim(RGC->RGC_CIDADE) + ", " + Alltrim(RGC->RGC_ESTADO)
		Endif
	Endif

	DbSelectArea ("SRA")
	SRA->(DbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT")))
	SRA->(Dbseek(PadR(cFil2,Len(SRA->RA_FILIAL))+cMat2))

	If !lImprDir
		oPrinter:SAY(Li,10 ,STR0098 , oFONT4)
		oPrinter:SAY(Li,75 , cDet,oFont)
		Li += nEsp2 //2
	ENDIF
	oPrinter:SAY(Li,10 ,STR0178, OFONT4) //STR0120 - "No Pago: "     Periodo Pago
	oPrinter:SAY(Li,75 ,cFchPerIni+"  a  " + cFchPerFin,oFont)
	oPrinter:SAY(LI,280 ,STR0126,oFONT4)
	oPrinter:SAY(LI,335 , cLocPago,oFont)
	oPrinter:SAY(LI,420 ,STR0136, ofont4)
	oPrinter:SAY(LI,480 ,cFchPago,oFont)
	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLanca    ºAutor  ³Raul Ortiz          º Data ³ 29/10/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera cuerpo del reporte en base al xml                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLanca(oPrinter,oXML)
	Local cString		:= ""
	Local nI			:= 0
	Local nY			:= 0
	Local cImpGrv		:= ""
	Local cImpExc		:= ""
	Local cXML			:= ""
	Local LExistPer		:= .F.
	Local nTotPer		:= 0
	Local nTotOtr		:= 0
	Local nTotDed		:= 0
	Local cDesIncap		:= ""
	Local cDesHrExt		:= ""
	Local cTtlOtrasDed	:= 0
	Local cTotalImpRet	:= 0
	Local nHEDias		:= 0
	Local cHETipo		:= ""
	Local nNumHExt		:= 0
	Local nHEValor		:= 0
	Local aHoraExt		:= {}
	Local nPosTipo		:= 0
	Local nLoop			:= 0
	Local nLiSal		:= 0
	Local lpercep		:= .f.

	oPrinter:SAY(Li,10 ,STR0137	,oFont4)
	oPrinter:SAY(Li,75 ,STR0138	,oFont4)
	oPrinter:SAY(Li,145 ,STR0069 ,oFont4)
	oPrinter:SAY(Li,280 ,STR0177 ,oFont4)
	oPrinter:SAY(Li,390 ,STR0182 ,oFont4)
	oPrinter:SAY(Li,490 ,STR0140 ,oFont4)
	LI += 5
	oPrinter:Line(LI,10,LI,575,,"-4")
	LI += nEspLi2
	newPage(oPrinter)
	oPrinter:SAY(Li,10 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CANTIDAD:TEXT,oFont)
	oPrinter:SAY(Li,75 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_CLAVEUNIDAD:TEXT	,oFont)
	oPrinter:SAY(Li,145 ,oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_DESCRIPCION:TEXT,oFont)
	oPrinter:SAY(Li,280 ,oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NUMDIASPAGADOS:TEXT,oFont) // DIAS PAGADOS SAT
	oPrinter:SAY(Li,390 ,Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_VALORUNITARIO:TEXT),cPict2),oFont6)
	oPrinter:SAY(Li,490 ,Transform(val(oXml:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO:_IMPORTE:TEXT),cPict2),oFont6)
	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	oPrinter:SAY(Li,10 ,STR0141	,oFont4)
	oPrinter:SAY(Li,75 ,STR0142	,oFont4)
	oPrinter:SAY(Li,145 ,STR0069	,oFont4)
	oPrinter:SAY(Li,280 ,STR0144	,oFont4)
	oPrinter:SAY(Li,390 ,STR0202	,oFont4)
	oPrinter:SAY(Li,500 ,STR0145	,oFont4)
	LI += 5
	oPrinter:Line(LI,10,LI,575,,"-4")
	LI += nEspLi2
	newPage(oPrinter)

	If ObtUidXML(oXML,"nomina12:Percepciones")
		IF ValType(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION) <> "O"
			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION)
				cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_IMPORTEGRAVADO:TEXT)
				cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_IMPORTEEXENTO:TEXT)

				IF !Empty( Alltrim(Str(cImpGrv + cImpExc)))
					cString := Transform((cImpGrv + cImpExc),cPict2)
					oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_TIPOPERCEPCION:TEXT,oFont)
					oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_CLAVE:TEXT,oFont)
					oPrinter:SAY(LI,145,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_CONCEPTO:TEXT,oFont)
					oPrinter:SAY(LI,280,cString,oFont6)
					Li += nEsp1
					newPage(oPrinter)
				EndIf
			Next nI

		Else
			SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION XMLSTRING cXML
			If ("ACCIONESOTITULOS" $ UPPER(cxml)) .or. ("HORASEXTRA" $ UPPER(cxml))
				LExistPer := .T.
			EndIf

			If !(LExistPer)
				cImpGrv := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_IMPORTEGRAVADO:TEXT)
				cImpExc := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_IMPORTEEXENTO:TEXT)

				IF !Empty( Alltrim(Str(cImpGrv + cImpExc)))
					cString := Transform((cImpGrv + cImpExc),cPict2)
					oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_TIPOPERCEPCION:TEXT,oFont)
					oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_CLAVE:TEXT,oFont)
					oPrinter:SAY(LI,145,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_CONCEPTO:TEXT,oFont)
					oPrinter:SAY(LI,280,cString,oFont6)
					Li += nEsp1
					newPage(oPrinter)
				EndIf
			EndIf

		EndIf
			lpercep:= .t.
	else
	    lpercep:= .f.
	EndIf

	// Otros pagos
	If ObtUidXML(oXML,"nomina12:OtrosPagos")
		If valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO) <> "O"
			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO)
				cString := Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_Importe:TEXT),cPict2)
				oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_TIPOOTROPAGO:TEXT,oFont)
				oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_CLAVE:TEXT,oFont)
				G884LinC(oPrinter,LI,145, oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_CONCEPTO:TEXT, 40, nEsp1, 2, oFont, @nLiSal)

				If nLiSal > 0
					Li += nEsp1
				EndIf

				oPrinter:SAY(LI,390 , cString,oFont6)
				Li += nEsp1
				newPage(oPrinter)
			Next nI

		Else
			cString := Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_Importe:TEXT),cPict2)
			oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_TIPOOTROPAGO:TEXT,oFont)
			oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_CLAVE:TEXT,oFont)
			G884LinC(oPrinter,LI,145, oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_CONCEPTO:TEXT, 40, nEsp1, 2,oFont, @nLiSal)

			If nLiSal > 0
				Li += nEsp1
			EndIf

			oPrinter:SAY(LI,390 , cString,oFont6)
			Li += nEsp1
			newPage(oPrinter)

		EndIf
	EndIf

	newPage(oPrinter)

	If ObtUidXML(oXML,"nomina12:Deducciones")
		If valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION) <> "O"
			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALOTRASDEDUCCIONES")
				cTtlOtrasDed := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALOTRASDEDUCCIONES:TEXT)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALIMPUESTOSRETENIDOS")
				cTotalImpRet := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALIMPUESTOSRETENIDOS:TEXT)
			EndIf

			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION)
				If Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION[nI]:_TIPODEDUCCION:TEXT) == "006"
					cDescPD := STR0213
				Else
					cDescPD := oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION[nI]:_CONCEPTO:TEXT
				EndIf
				cString := Transform(VAL(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION[nI]:_IMPORTE:TEXT),cPict2)
				oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION[nI]:_TIPODEDUCCION:TEXT,oFont)
				oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION[nI]:_CLAVE:TEXT,oFont)
				oPrinter:SAY(LI,145,cDescPD,oFont)
				oPrinter:SAY(LI,500 , cString,oFont6)
				Li += nEsp1
				newPage(oPrinter)
			Next nI

		Else
			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALOTRASDEDUCCIONES")
				cTtlOtrasDed := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALOTRASDEDUCCIONES:TEXT)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALIMPUESTOSRETENIDOS")
				cTotalImpRet := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALIMPUESTOSRETENIDOS:TEXT)
			EndIf

			If Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION:_TIPODEDUCCION:TEXT) == "006"
				cDescPD := STR0213
			Else
				cDescPD := oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION:_CONCEPTO:TEXT
			EndIf

			cString := Transform(VAL(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION:_IMPORTE:TEXT),cPict2)
			oPrinter:SAY(LI,10,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION:_TIPODEDUCCION:TEXT,oFont)
			oPrinter:SAY(LI,75,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_NOMINA12_DEDUCCION:_CLAVE:TEXT,oFont)
			oPrinter:SAY(LI,145,cDescPD,oFont)
			oPrinter:SAY(LI,500, cString,oFont6)
			Li += nEsp1
			newPage(oPrinter)

		EndIf
	EndIf

	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	oPrinter:SAY(Li,10 ,STR0195,oFont4)

	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA,"TotalPercepciones")
		nTotPer := VAL(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_TOTALPERCEPCIONES:TEXT)
		oPrinter:SAY(Li,280 ,Transform(nTotPer,cPict2),oFont4)
	EndIf

	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA,"TotalOtrosPagos")
		nTotOtr	:= VAL(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_TotalOtrosPagos:TEXT)
		oPrinter:SAY(Li,390 ,Transform(nTotOtr,cPict2),oFont4)
	EndIf

	If ObtUidXML(OXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA,"TotalDeducciones")
		nTotDed	:= VAL(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_TotalDeducciones:TEXT)
		oPrinter:SAY(Li,500 ,Transform(nTotDed,cPict2),oFont4)
	EndIf

	Li += nEsp1
	oPrinter:SAY(Li,10 ,STR0055,oFont4)
	oPrinter:SAY(Li,500 ,Transform((nTotPer+nTotOtr)-nTotDed,cPict2) ,oFont4)
	Li += nEsp1
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter)

	If ObtUidXML(oXML,"nomina12:Incapacidades")
		oPrinter:SAY(Li,10 ,STR0147,oFont4)
		Li += nEsp3
		newPage(oPrinter)
		oPrinter:SAY(Li,10 ,STR0148			,oFont4)
		oPrinter:SAY(Li,75 ,STR0141			,oFont4)
		oPrinter:SAY(Li,500 ,STR0149		,oFont4)
		Li += 5
		oPrinter:Line(LI,10,LI,575,,"-4")
		LI += nEspLi2
		newPage(oPrinter)

		IF valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD)<> "O"
			For nI := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD)
				oPrinter:SAY(Li,10 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD[NI]:_DIASINCAPACIDAD:TEXT,oFont)
				cDesIncap := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD[NI]:_TIPOINCAPACIDAD:TEXT)
				cDesIncap := AllTrim( fDescRCC("S032",cDesIncap,1,2,3,50) )
				oPrinter:SAY(Li,75 , cDesIncap ,oFont)

				If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD[NI],"IMPORTEMONETARIO")
					oPrinter:SAY(Li,520 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD[NI]:_IMPORTEMONETARIO:TEXT),cPict2),oFont6)
				EndIf

				Li += nEsp1
				newPage(oPrinter)
			Next nI

		Else
			oPrinter:SAY(Li,10 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD:_DIASINCAPACIDAD:TEXT,oFont)
			cDesIncap := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD:_TIPOINCAPACIDAD:TEXT)
			cDesIncap := AllTrim( fDescRCC("S032",cDesIncap,1,2,3,50) )
			oPrinter:SAY(Li,75 , cDesIncap ,oFont)

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD,"IMPORTEMONETARIO")
				oPrinter:SAY(Li,520 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_INCAPACIDADES:_NOMINA12_INCAPACIDAD:_IMPORTEMONETARIO:TEXT),cPict2),oFont6)
			EndIf

			Li += nEsp1
			newPage(oPrinter)

		EndIf
	EndIf
if lpercep
	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"NOMINA12:HORASEXTRA")
		oPrinter:Line(LI,5,LI,585,,"-4")
		newPage(oPrinter)
		LExistPer := .F.
		Li += nEsp1
		oPrinter:SAY(Li,10 ,STR0151,oFont4)
		Li += nEsp1
		newPage(oPrinter)
		oPrinter:SAY(Li,10 ,STR0148	,oFont4)
		oPrinter:SAY(Li,75 ,STR0141	,oFont4)
		oPrinter:SAY(Li,145 ,STR0152	,oFont4)
		oPrinter:SAY(Li,520 ,STR0140	,oFont4)
		Li += nEsp1

		IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION)<> "O"

			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION)
				For nY := 1 to XmlChildCount( oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI])
					SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI] XMLSTRING cXML

					If ("HORASEXTRA" $ UPPER(cxml))
						LExistPer := .T.
					EndIf
				Next nY

				If (LExistPer)
					IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA) <> "O"
						For nY := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA)
							nHEDias  := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA[nY]:_DIAS:TEXT)
							cHETipo  := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA[nY]:_TIPOHORAS:TEXT)
							nNumHExt := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA[nY]:_HORASEXTRA:TEXT)
							nHEValor := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA[nY]:_IMPORTEPAGADO:TEXT)
							nPosTipo := aScan( aHoraExt , {|x| cHETipo == x[2] } )

							If nPosTipo == 0
								aAdd(aHoraExt, {nHEDias, cHETipo, nNumHExt, nHEValor})
							Else
								aHoraExt[nPosTipo][3] += nNumHExt
								aHoraExt[nPosTipo][4] += nHEValor
							EndIf

							LExistPer := .F.
						Next nY

					Else
						nHEDias  := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA:_DIAS:TEXT)
						cHETipo  := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA:_TIPOHORAS:TEXT)
						nNumHExt := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA:_HORASEXTRA:TEXT)
						nHEValor := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_HORASEXTRA:_IMPORTEPAGADO:TEXT)
						nPosTipo := aScan( aHoraExt , {|x| cHETipo == x[2] } )

						If nPosTipo == 0
							aAdd(aHoraExt, {nHEDias, cHETipo, nNumHExt, nHEValor})
						Else
							aHoraExt[nPosTipo][3] += nNumHExt
							aHoraExt[nPosTipo][4] += nHEValor
						EndIf

						LExistPer := .F.

					EndIf
				EndIf
			Next nI
		Else


			For nY := 1 to XmlChildCount( oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION)
				SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION XMLSTRING cXML

				If ("HORASEXTRA" $ UPPER(cxml))
					LExistPer := .T.
				EndIf
			Next nY

			If (LExistPer)
				IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA) <> "O"
					For nY := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA)
						nHEDias  := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA[nY]:_DIAS:TEXT)
						cHETipo  := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA[nY]:_TIPOHORAS:TEXT)
						nNumHExt := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA[nY]:_HORASEXTRA:TEXT)
						nHEValor := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA[nY]:_IMPORTEPAGADO:TEXT)
						nPosTipo := aScan( aHoraExt , {|x| cHETipo == x[2] } )

						If nPosTipo == 0
							aAdd(aHoraExt, {nHEDias, cHETipo, nNumHExt, nHEValor})
						Else
							aHoraExt[nPosTipo][3] += nNumHExt
							aHoraExt[nPosTipo][4] += nHEValor
						EndIf

						LExistPer := .F.
					Next nY

				Else
					nHEDias  := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA:_DIAS:TEXT)
					cHETipo  := Alltrim(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA:_TIPOHORAS:TEXT)
					nNumHExt := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA:_HORASEXTRA:TEXT)
					nHEValor := val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_HORASEXTRA:_IMPORTEPAGADO:TEXT)
					nPosTipo := aScan( aHoraExt , {|x| cHETipo == x[2] } )

					If nPosTipo == 0
						aAdd(aHoraExt, {nHEDias, cHETipo, nNumHExt, nHEValor})
					Else
						aHoraExt[nPosTipo][3] += nNumHExt
						aHoraExt[nPosTipo][4] += nHEValor
					EndIf

					LExistPer := .F.

				EndIf
			EndIf

		EndIf

		For nLoop := 1 To Len(aHoraExt)
			oPrinter:SAY(Li,10 ,Transform(aHoraExt[nLoop][1],cPict2),oFont6)
			cDesHrExt := IIf(aHoraExt[nLoop][2] == "01", STR0205, IIf(aHoraExt[nLoop][2] == "02", STR0206, STR0207))
			oPrinter:SAY(Li,75 ,cDesHrExt,oFont6)
			oPrinter:SAY(Li,145 ,Transform(aHoraExt[nLoop][3],cPict2),oFont6)
			oPrinter:SAY(Li,520 ,Transform(aHoraExt[nLoop][4],cPict2),oFont6)
			Li += nEsp1
			newPage(oPrinter)
		Next nLoop
	EndIf

	// Acciones o titulos
	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"NOMINA12:ACCIONESOTITULOS")
		LExistPer := .F.
		oPrinter:Line(LI,5,LI,585,,"-4")
		newPage(oPrinter)
		Li += nEsp1
		oPrinter:SAY(Li,10 ,STR0184	,oFont4)
		Li += nEsp1
		oPrinter:SAY(Li,15 ,STR0185	,oFont4)
		oPrinter:SAY(Li,480 ,STR0186	,oFont4)
		Li += nEsp1
		oPrinter:Line(LI,10,LI,575,,"-4")
		LI += nEspLi2
		newPage(oPrinter)

		If VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION) <> "O"
			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION)
				For nY := 1 to XmlChildCount( oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI])
					SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI] XMLSTRING cXML
					If ("ACCIONESOTITULOS" $ UPPER(cxml))
						LExistPer := .T.
					EndIf
				Next nY

				If (LExistPer)
					IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS) <> "O"
						For nY := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS)
							oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS[nY]:_VALORMERCADO:TEXT),cPict2),oFont6)
							oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS[nY]:_PRECIOALOTORGARSE:TEXT),cPict2),oFont6)
							Li += nEsp1
							newPage(oPrinter)
							LExistPer := .F.
						Next NY

					Else
						oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS:_VALORMERCADO:TEXT),cPict2),oFont6)
						oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION[nI]:_NOMINA12_ACCIONESOTITULOS:_PRECIOALOTORGARSE:TEXT),cPict2),oFont6)
						Li += nEsp1
						newPage(oPrinter)
						LExistPer := .F.

					EndIf
				EndIF
			Next nI

		Else
			oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_ACCIONESOTITULOS:_VALORMERCADO:TEXT),cPict2),oFont6)
			oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_PERCEPCION:_NOMINA12_ACCIONESOTITULOS:_PRECIOALOTORGARSE:TEXT),cPict2),oFont6)
			Li += nEsp1
			newPage(oPrinter)
			LExistPer := .F.

		EndIF
	EndIf

	//Jubilaciones
	If ObtUidXML(oXML,"NOMINA12:JUBILACIONPENSIONRETIRO")
		IF ValType(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO) <> "O"
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,"JUBILACION PENSION RETIRO",oFont4)
			Li += nEsp1
			oPrinter:Line(LI,10,LI,575,,"-4")
			Li += nEsp1
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,STR0187	,oFont4)
			oPrinter:SAY(Li,100 ,STR0188	,oFont4)
			oPrinter:SAY(Li,200 ,STR0189	,oFont4)
			oPrinter:SAY(Li,300 ,STR0190	,oFont4)
			oPrinter:SAY(Li,400 ,STR0191	,oFont4)
			Li += nEsp1

			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO)
				IF ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"TOTALUNAEXHIBICION")
					oPrinter:SAY(Li,10 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO[nI]:_TOTALUNAEXHIBICION:TEXT),cPict2),oFont6)
				EndIf

				If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"TOTALPARCIALIDAD")
					oPrinter:SAY(Li,100 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO[nI]:_TOTALPARCIALIDAD:TEXT),cPict2),oFont6)
				EndIf

				If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"MONTODIARIO")
					oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO[nI]:_MONTODIARIO:TEXT),cPict2),oFont6)
				EndIf

				oPrinter:SAY(Li,300 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO[nI]:_INGRESOACUMULABLE:TEXT),cPict2),oFont6)
				oPrinter:SAY(Li,420 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO[nI]:_INGRESONOACUMULABLE:TEXT),cPict2),oFont6)
				Li += nEsp1
				newPage(oPrinter)
			Next nI

		Else
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,"JUBILACION PENSION RETIRO",oFont4)
			Li += nEsp1
			oPrinter:Line(LI,10,LI,575,,"-4")
			Li += nEsp1
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,STR0187	,oFont4)
			oPrinter:SAY(Li,100 ,STR0188	,oFont4)
			oPrinter:SAY(Li,200 ,STR0189	,oFont4)
			oPrinter:SAY(Li,300 ,STR0190	,oFont4)
			oPrinter:SAY(Li,400 ,STR0191	,oFont4)
			Li += nEsp1

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"TOTALUNAEXHIBICION")
				oPrinter:SAY(Li,10 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO:_TOTALUNAEXHIBICION:TEXT),cPict2),oFont6)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"TOTALPARCIALIDAD")
				oPrinter:SAY(Li,100 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO:_TOTALPARCIALIDAD:TEXT),cPict2),oFont6)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"MONTODIARIO")
				oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO:_MONTODIARIO:TEXT),cPict2),oFont6)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"INGRESOACUMULABLE")
				oPrinter:SAY(Li,300 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO:_INGRESOACUMULABLE:TEXT),cPict2),oFont6)
			EndIf

			If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO,"INGRESONOACUMULABLE")
				oPrinter:SAY(Li,400 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_JUBILACIONPENSIONRETIRO:_INGRESONOACUMULABLE:TEXT),cPict2),oFont6)
			EndIf

			Li += nEsp1
			newPage(oPrinter)

		EndIf
	EndIf

	// Separacion
	If ObtUidXML(oXML,"NOMINA12:SEPARACIONINDEMNIZACION")
		IF ValType(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION) <> "O"
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)
			Li += nEsp4
			oPrinter:SAY(Li,10 ,"SEPARACION INDEMNIZACION",oFont4)
			Li += nEsp1
			oPrinter:Line(LI,10,LI,575,,"-4")
			Li += nEsp1
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,STR0208	,oFont4)
			oPrinter:SAY(Li,100 ,STR0209	,oFont4)
			oPrinter:SAY(Li,200 ,STR0210	,oFont4)
			oPrinter:SAY(Li,350 ,STR0211	,oFont4)
			oPrinter:SAY(Li,450 ,STR0212	,oFont4)
			Li += nEsp1

			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION)
				oPrinter:SAY(Li,10 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION[nI]:_TOTALPAGADO:TEXT),cPict2),oFont6)
				oPrinter:SAY(Li,100 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_NUMA_OSSERVICIO),cPict2),oFont6)
				oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION[nI]:_ULTIMOSUELDOMENSORD:TEXT),cPict2),oFont6)
				oPrinter:SAY(Li,350 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION[nI]:_INGRESOACUMULABLE:TEXT),cPict2),oFont6)
				oPrinter:SAY(Li,450 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION[nI]:_INGRESONOACUMULABLE:TEXT),cPict2),oFont6)
				Li += nEsp1
				newPage(oPrinter)
			Next nI

		Else
			Li += nEsp1
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,"SEPARACION INDEMNIZACION",oFont4)
			Li += nEsp1
			oPrinter:Line(LI,10,LI,575,,"-4")
			Li += nEsp1
			newPage(oPrinter)
			oPrinter:SAY(Li,10 ,STR0208	,oFont4)
			oPrinter:SAY(Li,100 ,STR0209	,oFont4)
			oPrinter:SAY(Li,200 ,STR0210	,oFont4)
			oPrinter:SAY(Li,350 ,STR0211	,oFont4)
			oPrinter:SAY(Li,450 ,STR0212	,oFont4)
			Li += nEsp1
			oPrinter:SAY(Li,10 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_TOTALPAGADO:TEXT),cPict2),oFont6)
			oPrinter:SAY(Li,100 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_NUMA_OSSERVICIO:TEXT),cPict2),oFont6)
			oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_ULTIMOSUELDOMENSORD:TEXT),cPict2),oFont6)
			oPrinter:SAY(Li,350 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_INGRESOACUMULABLE:TEXT),cPict2),oFont6)
			oPrinter:SAY(Li,450 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_NOMINA12_SEPARACIONINDEMNIZACION:_INGRESONOACUMULABLE:TEXT),cPict2),oFont6)
			Li += nEsp1
			newPage(oPrinter)

		EndIf
	EndIf
endif //de percepciones
	// ISR a FAVOR
	If ObtUidXML(oXML,"NOMINA12:OTROPAGO")
		LExistPer := .F.

		IF ValType(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO) <> "O"
			Li += nEsp1
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)

			For nI := 1 to Len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO)
				For nY := 1 to XmlChildCount( oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI])
					SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI] XMLSTRING cXML
					If ("COMPENSACIONSALDOAFAVOR" $ UPPER(cxml))
						LExistPer := .T.
					EndIf
				Next nY

				If (LExistPer)
					IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR) <> "O"
						For nY := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR)
							oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_SALDOAFAVOR:TEXT),cPict2),oFont6)
							oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_ANO:TEXT),cPict2),oFont6)
							oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_REMANENTESALDOAFAVOR:TEXT),cPict2),oFont6)
							Li += nEsp1
							newPage(oPrinter)
							LExistPer := .F.
						Next NY

					Else
						oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR:_SALDOAFAVOR:TEXT),cPict2),oFont6)
						oPrinter:SAY(Li,200 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR:_ANO:TEXT,oFont6)
						oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR:_REMANENTESALDOAFAVOR:TEXT),cPict2),oFont6)
						Li += nEsp1
						newPage(oPrinter)
						LExistPer := .F.

					EndIf
				EndIf
			Next nI

		Else
			Li += nEsp1
			oPrinter:Line(LI,5,LI,585,,"-4")
			LI += nEspLi2
			newPage(oPrinter)
			SAVE oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO XMLSTRING cXML

			If ("COMPENSACIONSALDOAFAVOR" $ UPPER(cxml))
				LExistPer := .T.
			EndIf

			If (LExistPer)
				IF VALTYPE(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR) <> "O"
					For nY := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_COMPENSACIONSALDOAFAVOR)
						oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_SALDOAFAVOR:TEXT),cPict2),oFont6)
						oPrinter:SAY(Li,200 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_ANO:TEXT),cPict2),oFont6)
						oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR[nY]:_REMANENTESALDOAFAVOR:TEXT),cPict2),oFont6)
						Li += nEsp1
						newPage(oPrinter)
						LExistPer := .F.
					Next NY

				Else
					oPrinter:SAY(Li,15 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR:_SALDOAFAVOR:TEXT),cPict2),oFont6)
					oPrinter:SAY(Li,200 ,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR:_ANO:TEXT,oFont6)
					oPrinter:SAY(Li,480 ,Transform(val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_COMPENSACIONSALDOAFAVOR:_REMANENTESALDOAFAVOR:TEXT),cPict2),oFont6)
					Li += nEsp1
					newPage(oPrinter)
					LExistPer := .F.

				EndIf
			EndIf

		EndIf
	EndIf

	LI -= 5
	oPrinter:Line(LI,5,LI,585,,"-4")
	Li += nEspLi2
	newPage(oPrinter)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRodape   ºAutor  ³Raul Ortiz          º Data ³ 29/10/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera pie de reporte incluyendo mensajes, totales ,        º±±
±±º          ³ cadenas de sello e imagen de codigo de barras.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRodape(oPrinter,oXML)    // Rodape do Recibo
	Local cTotalPerGrv	:= 0
	Local cTotalPerExc	:= 0
	Local cTtlOtrasDed	:= 0
	Local cTotalImpRet	:= 0
	Local cTotal		:= 0
	Local cSubTotal		:= 0
	Local nI			:= 0
	Local nX			:= 0
	Local cCadAux		:= ""
	Local nLiaux		:= ""
	Local cTotalSueldo	:= 0
	Local cTotalSepI	:= 0
	Local cTotalJuPe	:= 0
	Local cSubGrav		:= 0

	// Mensaje 1
	If  !EMPTY(MV_PAR20)
			DESC_MSG1 := AllTrim( fDescRCC("S018",MV_PAR20,1,2,5,200) )
	EndIf

	// Mensaje 2
	If  !EMPTY(MV_PAR21)
			DESC_MSG2 := AllTrim( fDescRCC("S018",MV_PAR21,1,2,5,200) )
	EndIf

	// Mensaje 3
	If  !EMPTY(MV_PAR22)
			DESC_MSG3 := AllTrim( fDescRCC("S018",MV_PAR22,1,2,5,200) )
	EndIf

	If ObtUidXML(oXML,"nomina12:Percepciones")
		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"TOTALSUELDOS")
			cTotalSueldo 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_TOTALSUELDOS:TEXT)
		EndIf

		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"TOTALSEPARACIONINDEMNIZACION")
			cTotalSepI 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_TOTALSEPARACIONINDEMNIZACION:TEXT)
		EndIf

		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"TOTALJUBILACIONPENSIONRETIRO")
			cTotalJuPe	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_TOTALJUBILACIONPENSIONRETIRO:TEXT)
		EndIf

		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"TOTALGRAVADO")
			cTotalPerGrv 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_TOTALGRAVADO:TEXT)
		EndIf

		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES,"TOTALEXENTO")
			cTotalPerExc 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_PERCEPCIONES:_TOTALEXENTO:TEXT)
		EndIf
	EndIf

	If ObtUidXML(oXML,"nomina12:Deducciones")
		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALOTRASDEDUCCIONES")
			cTtlOtrasDed 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALOTRASDEDUCCIONES:TEXT)
		EndIf

		If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES,"TOTALIMPUESTOSRETENIDOS")
			cTotalImpRet 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_DEDUCCIONES:_TOTALIMPUESTOSRETENIDOS:TEXT)
		EndIf
	EndIf

	If ObtUidXML(oXML,"nomina12:SubsidioAlEmpleo")
		IF valtype(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO)<> "O"
			For nI := 1 to len(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO)
				If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI],"nomina12:SubsidioAlEmpleo")
					cSubGrav 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO[nI]:_NOMINA12_SUBSIDIOALEMPLEO:_SUBSIDIOCAUSADO:TEXT)
				EndIf
			Next nI

		Else
			cSubGrav 	:= val(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_OTROSPAGOS:_NOMINA12_OTROPAGO:_NOMINA12_SUBSIDIOALEMPLEO:_SUBSIDIOCAUSADO:TEXT)

		EndIf
	EndIf

	cSubTotal	:= val(oXML:_CFDI_COMPROBANTE:_SUBTOTAL:TEXT)
	cTotal		:= val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT)

	oPrinter:SAY(LI,10,STR0196 ,oFont4)
	Li += nEsp1

	If !Empty(cTotalSueldo)
		oPrinter:SAY(LI,10, STR0198,oFont4)
		oPrinter:SAY(LI,450, Transform(cTotalSueldo,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cTotalSepI)
		oPrinter:SAY(LI,10, STR0199,oFont4)
		oPrinter:SAY(LI,450, Transform(cTotalSepI,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cTotalJuPe)
		oPrinter:SAY(LI,10, STR0200,oFont4)
		oPrinter:SAY(LI,450, Transform(cTotalJuPe,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cTotalPerGrv)
		oPrinter:SAY(LI,10, STR0156,oFont4)
		oPrinter:SAY(LI,450, Transform(cTotalPerGrv,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cTotalPerExc)
		oPrinter:SAY(LI,10, STR0197,oFont4)
		oPrinter:SAY(LI,450, Transform(cTotalPerExc,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	newPage(oPrinter)

	If !Empty(cTtlOtrasDed)
		oPrinter:SAY(LI,10, STR0203,oFont4)
		oPrinter:SAY(LI,520, Transform(cTtlOtrasDed,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cTotalImpRet)
		oPrinter:SAY(LI,10, STR0204,oFont4)
		oPrinter:SAY(LI,520, Transform(cTotalImpRet,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	If !Empty(cSubGrav)
		oPrinter:SAY(LI,10, STR0201,oFont4)
		oPrinter:SAY(LI,450, Transform(cSubGrav,cPict2),oFont6)
		Li += nEsp1
		newPage(oPrinter)
	EndIF

	LI += nEspLi1
	newPage(oPrinter)
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter)

	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "Banco")
		oPrinter:SAY(LI,10 , STR0164, oFont4	)//"CRED:"
		oPrinter:SAY(LI,85 , oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_BANCO:TEXT,oFont)
	EndIf

	If ObtUidXML(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR, "CUENTABANCARIA")
		oPrinter:SAY(LI,165 , STR0165, ofont4)
		oPrinter:SAY(LI,220 , oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_NOMINA12_NOMINA:_NOMINA12_RECEPTOR:_CUENTABANCARIA:TEXT,oFont)//"CONTA:"
	EndIf

	LI += nEspLi1
	newPage(oPrinter)
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter)
	oPrinter:SAY(LI,10 , STR0166, oFont4	)

	If !Empty(DESC_MSG1)
		If Len(DESC_MSG1) > 138
			oPrinter:SAY(LI,50,Substr(DESC_MSG1,1,138),ofont4)
			LI += nEsp1
			oPrinter:SAY(LI,50,Substr(DESC_MSG1,139,200),ofont4)
		Else
			oPrinter:SAY(LI,50,DESC_MSG1,ofont4)
		EndIf
	LI += nEsp1
	EndIf

	If !Empty(DESC_MSG2)
		If Len(DESC_MSG2) > 138
			oPrinter:SAY(LI,50,Substr(DESC_MSG2,1,138),ofont4)
			LI += nEsp1
			oPrinter:SAY(LI,50,Substr(DESC_MSG2,139,200),ofont4)
		Else
			oPrinter:SAY(LI,50,DESC_MSG2,ofont4)
		EndIf
	LI += nEsp1
	Endif

	If !Empty(DESC_MSG3)
		If Len(DESC_MSG3) > 138
			oPrinter:SAY(LI,50,Substr(DESC_MSG3,1,138),ofont4)
			LI += nEsp1
			oPrinter:SAY(LI,50,Substr(DESC_MSG3,139,200),ofont4)
		Else
			oPrinter:SAY(LI,50,DESC_MSG3,ofont4)
		EndIf
	LI += nEsp1
	Endif

	If Empty(DESC_MSG1) .And. Empty(DESC_MSG2) .And. Empty(DESC_MSG3)
		LI += nEsp1
	Endif

	newPage(oPrinter)
	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter)
	aBlock := LoadBlock(oXML)

	If aBlock[4][2] > 815 - LI
		newPage(oPrinter, .T.)
	EndIf

	oPrinter:SAY(LI,10 , STR0179, oFont5)
	LI += nEsp2

	If ObtUidXML(oXML,"tfd:TimbreFiscalDigital")
		nX := 1

		For nI := 1 to aBlock[1][2]
			cCadAux := Substr(aBlock[1][1],nX,225)
			nX += 225
			oPrinter:SAY(LI,10 ,cCadAux,oFont7)
			Li += nEsp2
		Next nI

	Else
		Li += nEsp2

	EndIF

	oPrinter:SAY(LI,130 ,STR0168,oFont5)
	nLiaux := LI
	LI += nEsp2

	If ObtUidXML(oXML,"SELLOCFD")
		nX := 1

		For nI := 1 to aBlock[2][2]
			cCadAux := Substr(aBlock[2][1],nX,170)
			nX += 170
			oPrinter:SAY(LI,130 ,cCadAux,oFont7)
			Li += nEsp1
		Next

	Else
		Li += nEsp2

	EndIf

	oPrinter:SAY(LI,130 , STR0169, oFont5)
	LI += nEsp2

	If	ObtUidXML(oXML,"SELLOSAT")
		nX := 1

		For nI := 1 to aBlock[3][2]
			cCadAux := Substr(aBlock[3][1],nX,170)
			nX += 170
			oPrinter:SAY(LI,130 ,cCadAux,oFont7)
			Li += nEsp1
		Next

		  oPrinter:QRCode(nLiaux + 110,10,aBlock[4][1], 120)

	Else
		Li += nEsp1

	EndIf

	lI += nEsp3
	oPrinter:SAY(LI,130 , UPPER(STR0170),oFont7)
	oPrinter:Line(820,5,820,585,,"-4")
	oPrinter:SAY(825,10,msg,oFont7)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LoadBlock     ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula el tamaño del bloque y regresa las cadenas de los no-³±±
±±³          ³dos contenidos en el bloque, junto con el numero de lineas   ³±±
±±³          ³lineas que va a ocupar                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LoadBlock(oXML)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oXml.- Estructura xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LoadBlock(oXML)
	Local aBlock	:= {{{},{}},{{},{}},{{},{}},{{},{}}}
	Local nLineas	:= 0
	Local cCadena	:= ""
	Local nX		:= 0
	Local nI		:= 0
	Local nTmp		:= 0
	Local nLiAux	:= 0

	nLineas += oFont5:NHEIGHT
	nLineas += nEsp2

	If ObtUidXML(oXML,"tfd:TimbreFiscalDigital")
		cCadena := "||" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_VERSION:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT
		cCadena += "|" + oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
		cCadena += "||"

		nX := 1
		nTmp := (len(cCadena)/225)	+ 1

		For nI := 1 to nTmp
			cCadAux := Substr(cCadena,nX,225)
			nX += 225
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		Next nI

		aBlock[1][1] := cCadena
		aBlock[1][2] := nTmp

	Else
		nLineas += nEsp2

	EndIF

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2

	If ObtUidXML(oXML,"SELLOCFD")
		cCadena := oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT
		nX := 1
		nTmp := (Len(cCadena)/170)	+ 1

		For nI := 1 to nTmp
			cCadAux:= Substr(cCadena,nX,170)
			nX+=170
			nLiAux	+= oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI

		aBlock[2][1] := cCadena
		aBlock[2][2] := nTmp

	Else
		nLiAux += nEsp2

	EndIf

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2

	If	ObtUidXML(oXML,"SELLOSAT")
		If Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT) < 0
			nTtlAux := Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT) * (- 1)
			nTtlAux := "-" + Replace(Transform(nTtlAux,"999999999.999999") , " ", "0")
		Else
			nTtlAux := Val(oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT)
			nTtlAux := Replace(Transform(nTtlAux,"9999999999.999999") , " ", "0")
		EndIf

		cCadena :=  oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
		cCertSAT := cURLValCFD
		cCertSAT += "?id=" + oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
		cCertSAT += "&re=" + oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT
		cCertSAT += "&rr=" + oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT
		cCertSAT += "&tt=" + nTtlAux
		cCertSAT += "&fe=" + Right(cCadena, 8)

		aBlock[4][1] := cCertSAT

		nX := 1
		nTmp := (Len(cCadena)/170)	+ 1

		For nI := 1 to  nTmp
			cCadAux := Substr(cCadena,nX,170)
			nX += 170
			nLiAux += 	oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI

		aBlock[3][1] := cCadena
		aBlock[3][2] := nTmp

	Else
		nLiAux += nEsp1

	EndIf

	nLiAux += nEsp3
	nLiAux += oFont7:NHEIGHT

	If nLiAux <= 115
		nLineas += 120
	Else
		nLineas += nLiAux
	EndIf

	aBlock[4][2] := nLineas

Return aBlock

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ObtUidXML     ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca nodo o elemento en el XML                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ObtUidXML(oXML,cNodo)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oXml.- Estructura xml                                        ³±±
±±³          ³cNodo.- Valor del nodo a buscar                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet.- Valor logigo .T. o .V.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtUidXML(oXML,cNodo)
	Local cXML     := ""
	Local cError   := ""
	Local cDetalle := ""
	Local lRet     := .F.

	If valType(oXml) == "O"				//Es un objeto
		SAVE oXML XMLSTRING cXML

		If AT( "ERROR" , Upper(cXML) ) > 0	// El archivo tiene errores
			If 	ValType(oXml:_ERROR) == "O"
				cError   := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			EndIf
		Else		//Obtener identificador del certificado
			If At( UPPER(cNodo) , Upper(cXML) ) > 0
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fCarLogo      ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carga Logo de la empresa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³fCarLogo(cLogo)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cLogo.- Valor para mostra logo de empresa en reporte         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cLogo.- Valor para mostra logo de empresa en reporte         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCarLogo(cLogo)
	Local  cStartPath:= GetSrvProfString("Startpath","")

	cLogo	:= cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf
Return cLogo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³newPage       ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Comprueba el espacio restante en la pagina y crea el fin de  ³±±
±±³          ³página y el inicio de la siguiente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³newPage(oPrinter,lCheck)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oPrinter.- Objeto para impresión de reporte                  ³±±
±±³          ³lCheck.- Valor logico para salto de página                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function newPage(oPrinter,lCheck)
	Local lNewPage := .F.
	Default lCheck := .F.

	If lCheck
		lNewPage := .T.
	Else
		If li >= 815
			lNewPage := .T.
		EndIf
	EndIf

	If lNewPage
		oPrinter:Line(820,5,820,585,,"-4")
		oPrinter:SAY(825,10 , msg,oFont7)
		oPrinter:EndPage()
		LI := 50
		oPrinter:StartPage()
		oPrinter:Line(5,5,820,5,,"-4") //Linea lateral izquierda
		oPrinter:Line(5,585,820,585,,"-4") //Linea lateral derecha
		oPrinter:Line(5,5,5,585,,"-4")//Linea horizontal de marco
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³getRoteir     ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtiene el reotiero correspondiente                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³getRoteir()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRoteir.- Valor de procedimiento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function getRoteir()
	Local aArea := GetArea()
	Local cRoteir := ''

	dbselectarea("SRY")
	dbsetorder(1)
	cTmpSRY			:= GetNextAlias()		// Tabla temporal
	cSRYRetSqlName  := InitSqlName("SRY") 	//Se obtiene el nombre  fisico de la tabla
	cFilSRY 		:= xfilial("SRY")  		// se obtiene la filial de la tabla  SRY

	cQuery := "SELECT RY_CALCULO "
	cQuery += "FROM " + cSRYRetSqlName +	" "
	cQuery += "WHERE RY_ORDINAR='1' AND RY_TIPO='1' AND RY_FILIAL='"+cFilSRY+"' AND D_E_L_E_T_<>'*' "

	cQuery := ChangeQuery(cQuery)
	// coloca el resultado en cTmpSRY(Tabla temporal)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSRY,.T.,.T.)
	(cTmpSRY)->(dbGoTop())

	While (cTmpSRY)->(!eof())
		cRoteir:=(cTmpSRY)->RY_CALCULO
		(cTmpSRY)->(dbskip())
	End Do

	(cTmpSRY)->(dbCloseArea())
	RestArea(aArea)
Return cRoteir

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ClearFolder   ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Limpia la carpeta HTTP de los archivos .Zip creados al menos ³±±
±±³          ³un día antes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ClearFolder(cPath)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPath.- Valor de ruta de carpeta HTTP                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ClearFolder(cPath)
	Local aArqDir := Directory(cPath + "*.Zip")
	Local nX := 0

	For nX := 1 to Len(aArqDir)
		If DtoS(aArqDir[nX][3]) < DtoS(Date())
			FERASE(cPath + aArqDir[nX][1])
		EndIf
	Next
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ObtDeclAnu    ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtiene valores para nodos opcionales de percepcion          ³±±
±±³          ³1 - Jubilacion                                               ³±±
±±³          ³2 - Indemnizacion                                            ³±±
±±³          ³3 - Acciones o Titulos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ObtDeclAnu(lTablaSR, cAuxPD)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTablaSR.- .T. Periodo abierto .F. Periodo cerrado           ³±±
±±³          ³cAuxPD.- Valor de clave de concepto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtDeclAnu(lTablaSR, cAuxPD)
	Local aArea    := GetArea()
	Local cQrAlias := ""
	Local cQrIdent := ""
	Local cQrySR   := ""
	Local cAliasSRC := GetNextAlias()

	If lTablaSR
		cQrAlias := "SRC"
		cQrIdent := "RC"
	Else
		cQrAlias := "SRD"
		cQrIdent := "RD"
	EndIf

	cQrySR := " SELECT SUM(" + cQrIdent + "_VALOR) RC_VALOR, " + cQrIdent + "_PD, RV_DECLANU, RV_CODFOL"
	cQrySR += " FROM " + RetSqlName(cQrAlias) + " " + cQrAlias + ", " + RetSqlName("SRV") + " SRV "
	cQrySR += " WHERE " + cQrIdent + "_FILIAL = '" + SRA->RA_FILIAL + "'"
	cQrySR += " AND " + cQrIdent + "_MAT = '" + SRA->RA_MAT + "'"
	cQrySR += " AND " + cQrIdent + "_PROCES = '" + cProcesso + "'"
	cQrySR += " AND " + cQrIdent + "_ROTEIR = '" + cRoteiro + "'"
	cQrySR += " AND " + cQrIdent + "_PERIODO = '" + cPeriodo + "'"
	cQrySR += " AND " + cQrIdent + "_SEMANA = '" + Semana + "'"
	cQrySR += " AND " + cQrIdent + "_PD IN (" + cAuxPD + ")"
	cQrySR += " AND " + cQrIdent + "_PD = RV_COD"
	cQrySR += " AND RV_FILIAL ='" + xFilial("SRV")+ "'
	cQrySR += " AND SRV.D_E_L_E_T_<>'*'"
	cQrySR += " AND " + cQrAlias +".D_E_L_E_T_<>'*'
	cQrySR += " GROUP BY " + cQrIdent + "_PD, RV_DECLANU, RV_CODFOL"

	cQrySR := ChangeQuery(cQrySR)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySR),cAliasSRC,.T.,.T.)
	(cAliasSRC)->( dbGoTop() )

	While (cAliasSRC)->(!Eof() )
		/*JubilacionPensionRetiro*/
		If Alltrim((cAliasSRC)->RV_DECLANU) $ ("3Q") //Total Una Exhibicion
			nTotUnaEx += (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3R") //Total Parcialidad
			nTotParci += (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3S") //Monto Diario
			nTotDiari := (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3X") //Ingreso Acumulable
			nTotIAcum := (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3Y") //Ingreso No Acumulable
			NTotNAcum := (cAliasSRC)->RC_VALOR
		EndIf

		/*SeparacionIndemnizacion*/
		If Alltrim((cAliasSRC)->RV_DECLANU) $ ("3A") //Total Pagado
			nTotPagad += (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3B") //Num Años Servicio
			nNumAnios := (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3E")
			nUltSuelM := (cAliasSRC)->RC_VALOR //Ultimo Sueldo Mens Ord
			nIngrAcum := (cAliasSRC)->RC_VALOR //Ingreso Acumulable
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("3G") //Ingreso No Acumulable
			nIngrNAcu := (cAliasSRC)->RC_VALOR
		EndIf

		/*AccionesTitulos*/
		If Alltrim((cAliasSRC)->RV_DECLANU) $ ("41K") //Ingreso Acumulable
			nValorMer := (cAliasSRC)->RC_VALOR
		ElseIf Alltrim((cAliasSRC)->RV_DECLANU) $ ("41L") //Ingreso No Acumulable
			nPrecOtor := (cAliasSRC)->RC_VALOR
		EndIf

		/*Subsidio al empleado*/
		If Alltrim((cAliasSRC)->RV_CODFOL) == "0471" .and. !lCalSub
			nSubsidio += (cAliasSRC)->RC_VALOR
		EndIf

		(cAliasSRC)->(dbSkip())
	Enddo

	(cAliasSRC)->( DBCloseArea() )
	RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fNodOpcPer    ³Autor³Luis Eduardo Enriquez³ Data ³ 04/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Forma cadena con codigos de conceptos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³fNodOpcPer(aAuxPD)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aAuxPD.- Arreglo de códigos de conceptos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cAuxPD.- Cadena de codigos de conceptos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fNodOpcPer(aAuxPD)
	Local nLoop := 1
	Local cAuxPD := ""

	For nLoop := 1 To Len(aAuxPD)
		cAuxPD += "'" + aAuxPD[nLoop][1] + "'" + IIf(nLoop < Len(aAuxPD), ",", "")
	Next nLoop
Return cAuxPD

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NodoRelacc³ Autor ³Luis Eduardo Enriquez³ Data ³ 26/09/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion utilizada para obtener los UUID cancelados que seran³±±
±±³          ³ relacionados al recibo de nomina 1.2                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := Tipo de string de retorno.                         ³±±
±±³          ³          1 = String para cadena original                    ³±±
±±³          ³          2 = String de nodo CFDI:CfdiRelacionados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 := string para cadena original o Nodo CfdiRelacionados³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NodoRelacc(nTipo)
	
	Local aArea		:= GetArea()
	Local cRelacion	:= ""
	Local cCRLF		:= (chr(13)+chr(10))

	Default nTipo := 0

	If lSusRecAnt .And. !Empty(cUUIDSust) .And. cMotivCanc == "01"
		If nTipo == 1
			cRelacion := ''
			cRelacion += cUUIDSust + '|'
		ElseIf nTipo == 2
			cRelacion := '	<cfdi:CfdiRelacionados TipoRelacion="04">'
			cRelacion += cCRLF + '		<cfdi:CfdiRelacionado'
			cRelacion += ' UUID="' + cUUIDSust + '"'
			cRelacion += ' />'
			cRelacion += cCRLF + '	</cfdi:CfdiRelacionados>'
		Else
			cRelacion := '04|'
		EndIf
	EndIf

	RestArea(aArea)

Return cRelacion

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fOtrosPag     ³Autor³Alfredo Medrano      ³ Data ³ 19/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime el tag OtroPago                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³fOtrosPag()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³N/A                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cNodoOtPag.- Cadena con la estructura del tag  OtroPago      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER884.ini                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fOtrosPag()
	Local aArea			:= GetArea()
	Local cEtiApert		:= '        <nomina12:OtrosPagos>' + cCRLF //Etiqueta apertura de otros pagos
	Local cEtiCierr		:= '        </nomina12:OtrosPagos>' + cCRLF //Etiqueta cierre de otros pagos
	Local cNodoOtPag	:= "" //Nodo de pagos
	Local cNodoCompl	:= "" //Nodo completo que sera retornado OtrosPagos>OtroPago
	Local lSubEmpT		:= .T.

	DBSelectArea("SRVPD")
	SRVPD->(DBGoTop())

	If DBSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3") // RA_FILIAL+RA_MAT+RV_TIPO+RV_COD+RV_ITEM
		While !SRVPD->(Eof())
			cNodoOtPag += '            <nomina12:OtroPago'
			cNodoOtPag += ' TipoOtroPago="' + Alltrim(Substr(SRVPD->RV_TIPSAT,1,3)) + '"'
			cNodoOtPag += ' Clave="' + Alltrim(SRVPD->RV_COD) + '"'
			cNodoOtPag += ' Concepto="' + Alltrim(SRVPD->RV_DESCDET) + '"'
			cNodoOtPag += ' Importe="' + Alltrim(Transform(Round(SRVPD->RC_VALORGV + SRVPD->RC_VALOREX,2), "99999999.99")) + '"'
			cNodoOtPag += ' > '
			NodOpcion(3) //Subsidio al empleo

			If !Empty(cNodoSubE)
				cNodoOtPag += cCRLF + cNodoSubE
				lSubEmpT := .F.
			EndIF

			NodOpcion(4) //Compensacion Saldos A Favor

			If !Empty(cNodoComp)
				cNodoOtPag += cCRLF + cNodoComp
			EndIf

			cNodoOtPag += cCRLF + '            </nomina12:OtroPago>' + cCRLF
			SRVPD->(DBSkip())
		EndDo
	EndIf

	If lSubEmpT .And. lUsaSubPer .And. !lImprIndem
		cNodoOtPag += '            <nomina12:OtroPago'
		cNodoOtPag += ' TipoOtroPago="002"'
		cNodoOtPag += ' Clave="' + cCFDICON +'"'
		cNodoOtPag += ' Concepto="' + STR0219 + '"' //"Subsidio para el empleo (Efectivamente entregado al trabajador)."
		cNodoOtPag += ' Importe="0.01" >'
	    cNodoOtPag += cCRLF
		cNodoOtPag += '                <nomina12:SubsidioAlEmpleo'
		cNodoOtPag += ' SubsidioCausado="' + Alltrim(Transform(Round(IIf(nSubsidio > 0, nSubsidio, 0.01), 2),"999999999.99"))+ '"/>'
		cNodoOtPag += cCRLF
		cNodoOtPag += '            </nomina12:OtroPago>' + cCRLF
	EndIf

	If !Empty(cNodoOtPag)
		cNodoCompl := cEtiApert + cNodoOtPag + cEtiCierr
	EndIf

	RestArea(aArea)

Return cNodoCompl

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³G884LinC    ºAutor  ³Alfredo Medrano  º Data ³  19/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recorta y divide en líneas impresión de texto FWMSPrinter  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³G884LinC()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oPrinter .-  Objeto Printer                                º±±
±±ºParametros³nLiFP    .-  Posición inicial de la línea                  º±±
±±ºParametros³nColFP   .-  Columna en donde se imprimirá la línea        º±±
±±ºParametros³cDesFP   .-  Cadena Texto a dividir en lineas              º±±
±±ºParametros³nStr     .-  Numero de caracteres por línea                º±±
±±ºParametros³nSalto   .-  Numero de pixeles a imprimir entre líneas     º±±
±±ºParametros³nTotlin  .-  Total de lineas a imprimir                    º±±
±±ºParametros³oFont    .-  Fuente de texto                               º±±
±±ºParametros³nLiSal   .-  Lineas extras que fueron impresas             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G884LinC(oPrinter,nLiFP,nColFP,cDesFP,nStr, nSalto, nTotlin, oFont,nLiSal)

	Local x 		:= 0
	Local y 		:= 1
	Local lBan 		:= .F.
	Local nLineas	:= 0
	Local nTamDes	:= 0

	default nLiSal	:= 0
	default nLiFP 	:= 0
	default nColFP	:= 0
	default nStr	:= 0
	default nSalto	:= 0
	default nTotlin	:= 0

	nTamDes := LEN(cDesFP)

	If nTamDes > nStr
		For  x := nTamDes  to y step -1
			If  nLineas < nTotlin
				If  (x <= nStr .and. substr(cDesFP, x, 1) == " ")  .OR. (lBan == .T. .and. x <= y + nStr .and. substr(cDesFP, x, 1) == " ")
					If lBan == .T.
						nLineas++
						nLiFP += nSalto
						oPrinter:Say(nLiFP, nColFP, substr(cDesFP, y, x - y), oFont)

					Else
						oPrinter:Say(nLiFP, nColFP, substr(cDesFP, y, x), oFont)
						nLineas++

					EndIf

					y := x +1
					x := nTamDes

					If Len(substr(cDesFP, y,x )) <= 34
						nLiFP += nSalto
						oPrinter:Say(nLiFP , nColFP, substr(cDesFP, y, x), oFont)
						Exit

					Else
						lBan := .T.

					EndIf

				EndIf
			EndIf
		Next
	Else
		oPrinter:Say(nLiFP, nColFP, cDesFP, oFont)
	EndIf

	nLiSal := nLineas

Return

/*/{Protheus.doc} ValPerDed
Función que valida si el empleado cuenta con percepciones y deducciones calculadas.
@type
@author eduardo.manriquez
@since 01/03/2021
@version 1.0
@param
@return lValid , boolean,retorna .F. cuando el empleado no cuenta con percepciones y deducciones.
@example
ValPerDed()
@see (links_or_references)
/*/
Function ValPerDed()
	Local aArea       := GetArea()
	Local lPercp      := .F.
	Local lDeduc      := .F.
	Local lValid      := .T.

	DbSelectArea("SRVPD") //Detalle percepciones y deducciones
	SRVPD->(DbGotop())

	While SRVPD->(!Eof())
		If SRVPD->RV_TIPO == "1" // Percepciones
			lPercp := .T.
			SRVPD->(dbskip())
			Loop
		EndIf

		If SRVPD->RV_TIPO == "2" // Deducciones
			lDeduc := .T.
			SRVPD->(dbskip())
			Loop
		EndIf

		If SRVPD->RV_TIPO == "3" // Otros Pagos: Deben ser considerados como percepciones
			lPercp := .T.
			SRVPD->(dbskip())
			Loop
		EndIf

		 SRVPD->(dbskip())
	EndDo

	If !lDeduc .and. !lPercp
		lValid := .F.
	EndIf
	RestArea(aArea)

Return lValid


/*/{Protheus.doc} VerbasIndem
Función que realiza la separación de conceptos de indemnización o separación de los demás conceptos
@type
@author eduardo.manriquez
@since 12/07/2021
@version 1.0
@param aVerbasFilter , array , arreglo que contiene los conceptos que podrian ser considerados para ser impresos en el recibo.
@return
@example
VerbasIndem(aVerbasFilter)
@see (links_or_references)
/*/
Static Function VerbasIndem(aVerbasFilter)

	Local aVerbasFunc := {}
	Local nReg        := 1
	Local cIsrFin     := "0476"

	aVerbasFunc	:= RetornaVerbasFunc(	SRA->RA_FILIAL					,; // Filial do funcionario corrente
	SRA->RA_MAT	  					,; // Matricula do funcionario corrente
	NIL								,; //
	cRoteiro	  					,; // Roteiro selecionado na pergunte
	IIf(cPaisLoc == "MEX", aVerbasFilter, NIL)	,; //			  aVerbasFilter				 // Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
	aPerAberto	  					,; // Array com os Periodos e Numero de pagamento abertos
	aPerFechado	 	 				 ) // Array com os Periodos e Numero de pagamento fechados

	lIndemn:= Iif(Ascan(aVerbasFunc,{|imp| imp[3] $ cPDIndemn}) > 0,.T.,lIndemn)

	For nReg := 1 To Len(aVerbasFunc)
		If (aVerbasFunc[nReg][3] $ cPDIndemn) .or. PosSrv( aVerbasFunc[nReg][3], SRA->RA_FILIAL, "RV_CODFOL") $ cIsrFin
			AADD(aVerbIndem,aVerbasFunc[nReg])
		Else
			AADD(aVerbOrd,aVerbasFunc[nReg])
		EndIf
	Next nReg

Return

/*/{Protheus.doc} FGetRIWRco
	Función utilizada para obtener el Recno de los registros en RIW.
	@type  Static Function
	@author marco.rivera
	@since 16/03/2022
	@version 1.0
	@param cUUID, Character, UUID de recibo a cancelar.
	@return nRecnoRIW, Numeric, Recno del registro en RIW.
	@example
	FGetRIWRco(cUUID)
/*/
Function FGetRIWRco(cUUID)
	
	Local aAreaRIW	:= GetArea()
	Local cTmpRIW	:= GetNextAlias()
	Local nRecnoRIW	:= 0
	Local cFilRIW	:= xFilial("RIW")

	Default cUUID	:= ""

	BeginSql Alias cTmpRIW
		SELECT R_E_C_N_O_ RECNORIW
		FROM %table:RIW%
		WHERE RIW_FILIAL = %exp:cFilRIW% AND
			RIW_UUID = %exp:cUUID% AND
			%NotDel%
	EndSql

	While (cTmpRIW)->(!Eof())
		nRecnoRIW := (cTmpRIW)->RECNORIW
		(cTmpRIW)->(DBSkip())
	EndDo

	(cTmpRIW)->(DbCloseArea())
	RestArea(aAreaRIW)

Return nRecnoRIW

/*/{Protheus.doc} FGetMovRIW
	Función utilizada para validar si hay movimientos de recibos anteriores
	y que estén timbrados.
	@type  Static Function
	@author marco.rivera
	@since 18/03/2022
	@version 1.0
	@param cFilSRA, Character, Sucursal del empleado.
	@param cRFC, Character, RFC del empleado.
	@return cRetIDSust, Character, UUID del recibo anterior.
	@example
	FGetMovRIW(cFilSRA, cRFC)
/*/
Static Function FGetMovRIW(cFilSRA, cRFC)
	
	Local aAreaRIW		:= GetArea()
	Local cTmpRIW		:= GetNextAlias()
	Local cRetIDSust	:= ""

	Default cFilSRA	:= xFilial("SRA")
	Default cRFC	:= ""

	BeginSql alias cTmpRIW
		SELECT RIW.RIW_UUID
		FROM %table:RIW% RIW
		WHERE RIW.RIW_FILIAL = %exp:cFilSRA% AND
			RIW.RIW_PROCES = %exp:MV_PAR01% AND
			RIW.RIW_ROTEIR = %exp:MV_PAR02% AND
			RIW.RIW_PER = %exp:MV_PAR03% AND
			RIW.RIW_NUMPAG = %exp:MV_PAR04% AND
			RIW.RIW_RFC = %exp:cRFC% AND
			RIW.RIW_FECANT = '' AND
			RIW.%notDel%
		ORDER BY RIW.R_E_C_N_O_ DESC
	EndSql

	DBSelectArea(cTmpRIW)
	(cTmpRIW)->(DBGoTop())

	cRetIDSust := (cTmpRIW)->RIW_UUID

	(cTmpRIW)->(DbCloseArea())
	RestArea(aAreaRIW)

Return cRetIDSust

/*/{Protheus.doc} fUbicaArch
	Función utilizada para mover a la carpeta "cancelar" los recibos
	timbrados anteriormente y que serán sustituidos por uno nuevo.

	@type  Static Function
	@author marco.rivera
	@since 25/04/2022
	@version 1.0
	@param cRutCFDSrv, Character, Ruta del servidor
	@param cRutCFDSmr, Character, Ruta del SmartClient
	@param cNomRecOri, Character, Nombre del archivo original
	@param cNomRecSus, Character, Nombre del archivo a sustituir
	@param cDirACance, Character, Ruta del directorio cancelar
	@example
	fUbicaArch(cRutCFDSrv, cRutCFDSmr, cNomRecOri, cNomRecSus, cDirACance)
/*/
Static Function fUbicaArch(cRutCFDSrv, cRutCFDSmr, cNomRecOri, cNomRecSus, cDirACance)

	Local aArea			:= GetArea()

	Default cRutCFDSrv 	:= ""
	Default cRutCFDSmr	:= ""
	Default cNomRecOri	:= ""
	Default cNomRecSus	:= ""
	Default cDirACance	:= ""

	If !Empty(cNomRecSus)
		FRename( cRutCFDSrv + cNomRecOri,  cRutCFDSrv + cNomRecSus) //Renombra archivo
		CpyS2T(cRutCFDSrv + cNomRecSus, cRutCFDSmr) //Copia archivo a la carpeta recibos de la ruta en MV_CFDSMAR
		If File(cRutCFDSmr + cNomRecSus) //Valida si está el archivo en la carpeta recibos de la ruta en MV_CFDSMAR
			CpyT2S(cRutCFDSmr + cNomRecSus, cDirACance) //Copia el archivo a la ruta "Cancelar"
			If File(cDirACance + cNomRecSus) //Valida si está el archivo en la carpeta "Cancelar"
				Ferase(cRutCFDSrv + cNomRecSus) //Borra el archivo de la carpeta recibos de la ruta en MV_CFDRECN
				Ferase(cRutCFDSmr + cNomRecSus) //Borra el archivo de la carpeta recibos de la ruta en MV_CFDSMAR
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	
Return
