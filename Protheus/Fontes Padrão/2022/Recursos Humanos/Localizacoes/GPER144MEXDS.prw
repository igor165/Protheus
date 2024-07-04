#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "GPER144MEX.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GP144M    ³Autor|Jonathan Gonzalez Rivera        | Data ³26/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcion encargada de la definicion del dataset usado para el informe³±±
±±³          ³Recibos de Nomina en birt                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP144M                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER144MEXDS                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³  Data  ³  Chamado/Req   ³ Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³11/12/15³     TTUJ23     ³Se elimina el tratamiento para los pre- ³±±
±±³            ³        ³                ³guntas de tipo rango, y se adecua el re-³±±
±±³            ³        ³                ³porte al nuevo grupo de preguntas.      ³±±
±±³Jonathan Glz³02/02/16³     TTUJ23     ³Se agregan la func Gpr144Val y Gpr144Rot³±±
±±³            ³        ³                ³para la validacion de las preguntas.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset GP144M
	title STR0001 //"Recibos de Nomina BIRT"
	description STR0001 //"Recibos de Nomina BIRT"
	PERGUNTE "GPR144MEX"

columns
	define column EMPRES type character size 100  Label  STR0004 //"Empresa"
	define column REGPAT type character size 20   Label  STR0005 //"Reg. Patronal"
	define column RFCEMP type character size 20   Label  STR0006 //"RFC Emp"
	define column DIRECC type character size 150  Label  STR0007 //"Dirección"
	define column MATRIC type character size 10   Label  STR0008 //"Matricula"
	define column NOME   type character size 80   Label  STR0009 //"Nombre"
	define column ORDEN  type character size 10   Label  STR0010 //"Orden"
	define column CENCOS type character size 80   Label  STR0011 //"Centro Costo"
	define column FUNCIO type character size 100  Label  STR0012 //"Función"
	define column RFC    type character size 20   Label  STR0013 //"RFC"
	define column IMSS   type character size 20   Label  STR0014 //"IMSS"
	define column CURP   type character size 20   Label  STR0015 //"CURP"
	define column SUEDIA type character size 15   Label  STR0016 //"Sueldo Diario"
	define column SDIAIN type character size 15   Label  STR0017 //"Suel. Dia. Int"
	define column LOGPAG type character size 100  Label  STR0018 //"Lugar de Pago"
	define column PROCES type character size 80   Label  STR0019 //"Proceso"
	define column ROTEIR type character size 80   Label  STR0020 //"Procedimiento"
	define column PERIOD type character size 10   Label  STR0021 //"Periodo"
	define column NUMPAG type character size 30   Label  STR0022 //"Num Pago"
	define column PERCOD type character size 10   Label  STR0023 //"Percep Código"
	define column PERDES type character size 60   Label  STR0024 //"Percep Descripción"
	define column PERREF type character size 10   Label  STR0025 //"Percep Referencia"
	define column PERVAL type character size 20   Label  STR0026 //"Percep Valor"
	define column DEDCOD type character size 10   Label  STR0027 //"Deduc Código"
	define column DEDDES type character size 60   Label  STR0028 //"Deduc Descripción"
	define column DEDREF type character size 10   Label  STR0029 //"Deduc Referencia"
	define column DEDVAL type character size 20   Label  STR0030 //"Deduc Valor"
	define column TOTPER type character size 30   Label  STR0031 //"Total  Percepciones"
	define column TOTDED type character size 30   Label  STR0032 //"Total Deduciones"
	define column CBANCO type character size 60   Label  STR0033 //"Cuenta de Banco"
	define column NETOCB type character size 30   Label  STR0034 //"Neto Por Cobrar"
	define column MENSAJ type character size 1800 Label  STR0035 //"Mensajes"
	define column RODAPE type character size 1800 Label  STR0036 //"Pie Pagina"
	define column FLAGPE type character size 1    Label  STR0037 //"FLAG"
	define column FLAGDE type character size 1    Label  STR0037 //"FLAG"
	define column LOGEMP type character size 20   Label  STR0038 //Logo Empresa

define query "SELECT EMPRES, REGPAT, RFCEMP, DIRECC, MATRIC, NOME  , ORDEN , CENCOS, "+;
                   " FUNCIO, RFC   , IMSS  , CURP  , SUEDIA, SDIAIN, LOGPAG, PROCES, "+;
                   " ROTEIR, PERIOD, NUMPAG, PERCOD, PERDES, PERREF, PERVAL, DEDCOD, "+;
                   " DEDDES, DEDREF, DEDVAL, TOTPER, TOTDED, CBANCO, NETOCB, MENSAJ, "+;
                   " RODAPE, FLAGPE, FLAGDE, LOGEMP "+;
             "FROM %WTable:1% "


process dataset
	Local aArea      := GetArea()
	Local cMes       := ""
	Local cAno       := ""
	Local lvalid     := .T.
	Local cWTabAlias

	Private dFchRef
	Private cMesAno
	Private lRet			:= .F.
	Private aLanca 		:= {}
	Private aProve 		:= {}
	Private aDesco 		:= {}
	Private aBases 		:= {}
	Private aInfo  		:= {}
	Private aCodFol		:= {}
	Private aPerAberto	:= {}
	Private aPerFechado	:= {}
	Private cProcesso		:= self:execParamValue("MV_PAR01") //Proceso
	Private cRoteiro		:= self:execParamValue("MV_PAR02") //Procedimiento
	Private cPeriodo		:= self:execParamValue("MV_PAR03") //Periodo
	Private Semana		:= self:execParamValue("MV_PAR04") //Num Pago
	Private cFilialDe    := self:execParamValue("MV_PAR05") //Filial Inicial
	Private cFilialA     := self:execParamValue("MV_PAR06") //Filial Final
	Private cCostoDe     := self:execParamValue("MV_PAR07") //centros costo inicial
	Private cCostoAte    := self:execParamValue("MV_PAR08") //centros costo final
	Private cMatDe       := self:execParamValue("MV_PAR09") //matricula inicial
	Private cMatAte      := self:execParamValue("MV_PAR10") //matricula final
	Private cNomeDe      := self:execParamValue("MV_PAR11") //Nombre inicial
	Private cNomeAte     := self:execParamValue("MV_PAR12") //Nombre final
	Private cChapaDe		:= self:execParamValue("MV_PAR13") //No. Tarjeta sin Reloj Inicial
	Private cChapaAte		:= self:execParamValue("MV_PAR14") //No. Tarjeta sin Reloj final
	Private Mensag1		:= self:execParamValue("MV_PAR15") //Mensaje 1
	Private Mensag2		:= self:execParamValue("MV_PAR16") //Mensaje 2
	Private Mensag3		:= self:execParamValue("MV_PAR17") //Mensaje 3
	Private cSituacao		:= self:execParamValue("MV_PAR18") //Situaciones
	Private cCategoria	:= self:execParamValue("MV_PAR19") //categorias
	Private cRodape		:= self:execParamValue("MV_PAR20") //Mensaje pie de pagina
	Private cMensRec		:= ALLTRIM( fPosTab( "S018", cRodape, "=", 4,,,,5) ) //Mensaje para pie de pagina

		IF !Gpr144Val(cProcesso,"","","",1)
			Help( " ", 1 , STR0042 , , STR0043 , 1 , 0 )
			lValid := .F.
		endif

		IF lvalid .AND. !Gpr144Rot(cRoteiro)
			Help( " ", 1 , STR0044 , , STR0045 , 1 , 0 )
			lValid := .F.
		endif

		IF lvalid .AND. !Gpr144Val(cProcesso,cRoteiro,cPeriodo,"",3)
			Help( " ", 1 , STR0046 , , STR0047 , 1 , 0 )
			lValid := .F.
		endif

		IF lvalid .AND. !Gpr144Val(cProcesso,cRoteiro,cPeriodo,Semana,4)
			Help( " ", 1 , STR0048 , , STR0049 , 1 , 0 )
			lValid := .F.
		endif

		IF lvalid
			// Carregar os periodos abertos (aPerAberto) e/ou os periodos fechados (aPerFechado), dependendo
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

			dFchRef := CTOD("01/" + cMes + "/" + cAno)
			cMesAno := StrZero(Month(dFchRef),2) + StrZero(Year(dFchRef),4)

			If self:isPreview()
			    //utilize este método para verificar se esta em modo de preview
			    //e assim evitar algum processamento, por exemplo atualização
			    //em atributos das tabelas utilizadas durante o processamento
			EndIf

		   cWTabAlias := ::createWorkTable()

			Processa( { | _lEnd | lRet := GP144MXIMP(cMesAno , .T. , cWTabAlias) } , ::title() )
		ELSE

			If self:isPreview()
			    //utilize este método para verificar se esta em modo de preview
			    //e assim evitar algum processamento, por exemplo atualização
			    //em atributos das tabelas utilizadas durante o processamento
			EndIf

			cWTabAlias := ::createWorkTable()

			lRet := lvalid

		ENDIF

		if !lRet
			MsgInfo(STR0002) //"No existen datos dentro de los rangos seleccionados"
		else
			MsgInfo(STR0003) //"Impresion Terminada"
		endif

	RestArea( aArea )
return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GP144MXIMP ³Autor|Jonathan Gonzalez Rivera       |Data ³26/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcion encargada de obtener procesar los empleados de acuerdo al ³±±
±±³          ³rango seleccionado en el grupo de preguntas.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP144MXIMP(lEXP1,cEXP1,lEXP2,cEXP2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GP144M                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEXP1 = MesAno del Processo/Roteiro/Periodo selecionado           ³±±
±±³          ³lEXP1 = Control de impresion                                      ³±±
±±³          ³cEXP2 = Alias de la tabla temporal del dataset                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GP144MXIMP( cMesAno , lTerminal , cWTabAlias )
	Local cAcessaSR1 := &("{ || " + ChkRH("IMPRECIB","SR1","2") + "}")
	Local cAcessaSRC := &("{ || " + ChkRH("IMPRECIB","SRC","2") + "}")
	Local cAcessaSRD := &("{ || " + ChkRH("IMPRECIB","SRD","2") + "}")
	Local cNroHoras  := &("{ || If(aVerbasFunc[nReg,05] > 0 .And. cIRefSem == 'S', aVerbasFunc[nReg,05], aVerbasFunc[nReg,6]) }")
	Local nReg       := 0
	Local aVerbasFunc:= {}
	Local cTemp      := getNextAlias()
	Local cQuery     := ""
	Local nCount     := 0
	Local nHoras     := 0
	Local nAteLim    := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
	Local cSitFunc
	Local cFilialAnt := ""
	Local nProv
	Local nDesco
	Local aSvArea
	Local dPerFin   //(Este es periodo Final)
	Local cMesComp    := ""
	Local cTipo       := ""
	Local cReferencia := ""
	Local cVerbaLiq   := ""
	Local dDataPagto  := Ctod("//")
	Local cCodFunc    := ""  //-- codigo da Funcao do funcionario
	Local cDescFunc   := ""  //-- Descricao da Funcao do Funcionario
	Local nSalDiar    := 0   //Salario Diario
	Local nSalInt     := 0   //Salario Diario Integrado
	Local cRegPatr    := ""  //Regostro Patronal
	Local cProceso    := ""  //Proceso
	Local cDesProc    := ""  //Descripción del Proceso (RCJ)
	Local cCentroC    := ""  //Centro de Costo
	Local cDescCC     := ""  //Descripción del Centro de Costo (CTT)
	Local cFuncion    := ""  //Función
	Local cDesFunc    := ""  //Descripcion de la Función

	Private dDtPesqAf
	Private nOrdemZ
	Private dRCHDtIni
	Private dRCHDtFim
	Private Desc_Fil  := Desc_End  := Desc_Bair := ""
	Private DESC_MSG1 := DESC_MSG2 := DESC_MSG3 := ""
	Private Desc_Cid  := Desc_CEP  := ""
	Private TOTVENC   := TOTDESC   := 0
	Private cPict1    := "@E 999,999,999.99"
	Private cTipoRot  := ""

		cursorwait()
			cQuery := " SELECT  SRA.*  FROM " + RetSqlName("SRA") + " SRA  "
			cQuery += " WHERE SRA.RA_PROCES = '" + cProcesso + "'  "
			cQuery += " AND SRA.RA_FILIAL BETWEEN '"+ cFilialDe +"'  AND '"+ cFilialA +"' "
			cQuery += " AND SRA.RA_MAT BETWEEN '"+ cMatDe +"'  AND '"+ cMatAte +"' "

			//Se valida que los parametros finales no esten vacios, en caso de estarlo
			//se tomaran todos los registros de acuerdo a filial y matriculas. y estos
			//ultimos filtros no seran tomados.
			if !empty(cCostoAte)
				cQuery += " AND SRA.RA_CC BETWEEN '"+ cCostoDe +"'  AND '"+ cCostoAte +"' "
			endif

			if !empty(cNomeAte)
				cQuery += " AND SRA.RA_NOME BETWEEN '"+ cNomeDe +"'  AND '"+ cNomeAte +"' "
			endif

			if !empty(cChapaAte)
				cQuery += " AND SRA.RA_CHAPA BETWEEN '"+ cChapaDe +"'  AND '"+ cChapaAte +"' "
			endif

			cQuery += " AND  SRA.D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		cursorarrow()

		dbSelectArea( cTemp )

		Count to nCount

		(cTemp)->(dbGotop())

		ProcRegua(nCount)

		While (cTemp)->(!EOF())
			//MOVIMENTA REGUA DE PROCESSAMENTO
			Incproc( OemToAnsi( STR0041) + (cTemp)->RA_MAT  )

			nOrdemZ := 0
			TOTVENC := TOTDESC:= 0
			nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00

			cTipoRot  := PosAlias("SRY", cRoteiro, (cTemp)->RA_FILIAL, "RY_TIPO")
			dDtPesqAf := CTOD("01/" + Left(cMesAno,2) + "/" + Right(cMesAno,4),"DDMMYY")
			dRCHDtIni := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), (cTemp)->RA_FILIAL , "RCH_DTINI")
			dRCHDtFim := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), (cTemp)->RA_FILIAL , "RCH_DTFIM")

			aLanca	:= {}         // Zera Lancamentos
			aProve	:= {}         // Zera Lancamentos
			aDesco	:= {}         // Zera Lancamentos
			aBases	:= {}         // Zera Lancamentos

			/*Verifica Data Demissao */
			cSitFunc  := (cTemp)->RA_SITFOLH
			If cSitFunc == "D" .And. (!Empty((cTemp)->RA_DEMISSA) .And. MesAno((cTemp)->RA_DEMISSA) > MesAno(dDtPesqAf))
				cSitFunc := " "
			Endif

			IF !( lTerminal )
				If cSitFunc $ "D" .And. Mesano((cTemp)->RA_DEMISSA) # Mesano(dFchRef)
					(cTemp)->(dbSkip())
					Loop
				Endif
			EndIF

			If (cTemp)->RA_Filial # cFilialAnt
				If ! Fp_CodFol(@aCodFol,(cTemp)->Ra_Filial) .Or. ! fInfo(@aInfo,(cTemp)->Ra_Filial)
					Exit
				Endif
				Desc_Fil := aInfo[3]
				Desc_End := aInfo[4]
				Desc_CGC := aInfo[8]
				Desc_Cid := aInfo[05]
				Desc_Bair:= aInfo[13]
				Desc_CEP := aInfo[07]

				// MENSAGENS
				If MENSAG1 # SPACE(3)
					If FPHIST82((cTemp)->RA_FILIAL,"06",MENSAG1)
						DESC_MSG1 := Left(SRX->RX_TXT,30)
					Endif
				Endif

				If MENSAG2 # SPACE(3)
					If FPHIST82((cTemp)->RA_FILIAL,"06",MENSAG2)
						DESC_MSG2 := Left(SRX->RX_TXT,30)
					Endif
				Endif

				If MENSAG3 # SPACE(3)
					If FPHIST82((cTemp)->RA_FILIAL,"06",MENSAG3)
						DESC_MSG3 := Left(SRX->RX_TXT,30)
					Endif
				Endif
				cFilialAnt := (cTemp)->RA_FILIAL
			Endif

			Totvenc := Totdesc := 0

			//Retorna as verbas do funcionario, de acordo com os periodos selecionados
			aVerbasFunc	:= RetornaVerbasFunc( (cTemp)->RA_FILIAL ,; // Filial do funcionario corrente
													 (cTemp)->RA_MAT    ,; // Matricula do funcionario corrente
													 NIL                ,; //
													 cRoteiro           ,; // Roteiro selecionado na pergunte
													 NIL                ,; // Array com as verbas a ser listadas. Se NIL retorna todas as verbas.
													 aPerAberto         ,; // Array com os Periodos e Numero de pagamento abertos
													 aPerFechado	       ) // Array com os Periodos e Numero de pagamento fechados

			If cRoteiro <> "EXT"
				For nReg := 1 to Len(aVerbasFunc)
					If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD))
						(cTemp)->(dbSkip())
						Loop
					EndIf

					If PosSrv( aVerbasFunc[nReg,3] , (cTemp)->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						nHoras := Eval(cNroHoras)

						fSomaPdRec("P",aVerbasFunc[nReg,3],nHoras,aVerbasFunc[nReg,7],(cTemp)->RA_FILIAL)
						TOTVENC += aVerbasFunc[nReg,7]

					Elseif SRV->RV_TIPOCOD == "2"
						fSomaPdRec("D",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7],(cTemp)->RA_FILIAL)
						TOTDESC += aVerbasFunc[nReg,7]

					Elseif SRV->RV_TIPOCOD $ "3/4"
						If (aVerbasFunc[nReg,3] == aCodFol[047,1])
							fSomaPdRec("B",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7],(cTemp)->RA_FILIAL)
						Endif

					Endif

					If (aVerbasFunc[nReg,3] $ aCodFol[10,1]+'*'+aCodFol[15,1]+'*'+aCodFol[27,1])
						nBaseIr += aVerbasFunc[nReg,7]

					ElseIf (aVerbasFunc[nReg,3] $ aCodFol[13,1]+'*'+aCodFol[19,1])
						nAteLim += aVerbasFunc[nReg,7]

					Elseif (aVerbasFunc[nReg,3] $ aCodFol[108,1]+'*'+aCodFol[17,1])
						nBaseFgts += aVerbasFunc[nReg,7]

					Elseif (aVerbasFunc[nReg,3] $ aCodFol[109,1]+'*'+aCodFol[18,1])
						nFgts += aVerbasFunc[nReg,7]

					Elseif (aVerbasFunc[nReg,3] == aCodFol[16,1])
						nBaseIrFe += aVerbasFunc[nReg,7]

					Endif

				Next nReg

			Elseif cRoteiro == "EXT"
				SR1->(dbSelectArea("SR1"))
				SR1->(dbSetOrder(1))

				If SR1->(dbSeek( (cTemp)->RA_FILIAL + (cTemp)->RA_MAT ))

					While SR1->(!Eof()) .And. (cTemp)->RA_FILIAL + (cTemp)->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
						If Semana # "99"
							If SR1->R1_SEMANA # Semana
								SR1->(dbSkip())
								Loop
							Endif
						Endif

						If !Eval(cAcessaSR1)
							SR1->(dbSkip())
							Loop
						EndIf

						If PosSrv( SR1->R1_PD , (cTemp)->RA_FILIAL , "RV_TIPOCOD" ) == "1"
							fSomaPdRec("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,(cTemp)->RA_FILIAL)
							TOTVENC = TOTVENC + SR1->R1_VALOR

						Elseif SRV->RV_TIPOCOD == "2"
							fSomaPdRec("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,(cTemp)->RA_FILIAL)
							TOTDESC = TOTDESC + SR1->R1_VALOR

						Elseif SRV->RV_TIPOCOD $ "3/4"
							fSomaPdRec("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,(cTemp)->RA_FILIAL)

						Endif
						SR1->(dbskip())
					Enddo
				Endif

			Endif

			If Empty( aVerbasFunc )
				(cTemp)->(dbSkip())
				Loop
			Endif

			If lTerminal

				aSvArea	:= GetArea()
				lTerminal	:= .F.
				cMesComp	:= IF( Month(dFchRef) + 1 > 12 , 01 , Month(dFchRef) )
				dPerFin	:= dRCHDtFim
				cTipo		:= PosAlias("SRY", cRoteiro, (cTemp)->RA_FILIAL, "RY_DESC")

				IF cTipoRot == "2"
					cVerbaLiq	:= PosSrv( "007ADT" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
				ElseIF cTipoRot == "1"
					cVerbaLiq	:= PosSrv( "047CAL" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
				ElseIF cTipoRot == "5"
					cVerbaLiq	:= PosSrv( "022C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
				ElseIF cTipoRot == "6"
					cVerbaLiq	:= PosSrv( "021C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
				ElseIF  cRoteiro == "EXT"
					cTipo		:= OemToAnsi(STR0040) //"Valores Extras"
					cVerbaLiq	:= ""
				EndIF

				IF  cRoteiro <> "EXT"
					dDataPagto := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro) , (cTemp)->RA_FILIAL , "RCH_DTPAGO")
				EndIf

				cReferencia := AllTrim(MesExtenso(Month(dFchRef))+"/"+STR(YEAR(dFchRef),4)) + " - ( " + cTipo + "-" + cPeriodo + "/" + Semana + " )"

				//Obtener Datos Validos
				ObtDatos(dPerFin,@nSalDiar,@nSalInt,@cProceso,@cDesProc,@cCentroC,@cDescCC,@cFuncion,@cDesFunc,@cRegPatr,(cTemp)->RA_MAT)

				if empty(cProceso)
					cProceso := (cTemp)->RA_PROCES
					cDesProc := POSICIONE( "RCJ" , 1 , XFILIAL("RCJ")+cProceso , "RCJ_DESCRI" )
				endif

				if empty(cCentroC)
					cCentroC := (cTemp)->RA_CC
					cDescCC  := POSICIONE( "CTT" , 1 , XFILIAL("CTT")+cCentroC , "CTT_DESC01" )
				endif

				if empty(cFuncion)
					cFuncion := (cTemp)->RA_CODFUNC
					cDesFunc := POSICIONE( "SRJ" , 1 , XFILIAL("SRJ")+cFuncion , "RJ_DESC" )
				endif

				/*Carrega Funcao do Funcion. de acordo com a Dt Referencia */
				fBuscaFunc(dFchRef, @cCodFunc, @cDescFunc   )

				// DADOS PERCEPICIONES
				For nProv:=1 To Len( aProve )

				lRet	:= .T.

					RecLock(cWTabAlias, .T.)
					//Datos de la empresa
						(cWTabAlias)->EMPRES := ALLTRIM(DESC_Fil)
						(cWTabAlias)->REGPAT := ALLTRIM(cRegPatr)
						(cWTabAlias)->RFCEMP := ALLTRIM(Desc_CGC)
						(cWTabAlias)->DIRECC := ALLTRIM(Desc_End)+ Alltrim( Desc_Bair ) +" - "+ If( Empty( Desc_Bair ), "", ", " ) +;
						                        AllTrim( Desc_Cid ) + If( Empty(Desc_Cid), "",  ", " ) + (cTemp)->RA_ESTADO +;
						                        If( Empty((cTemp)->RA_ESTADO), "",  ", " ) + Desc_CEP
					//Datos Empleado
						(cWTabAlias)->MATRIC := (cTemp)->RA_MAT
						(cWTabAlias)->NOME   := ALLTRIM((cTemp)->RA_NOME)
						(cWTabAlias)->ORDEN  := StrZero(nOrdemZ,4)
						(cWTabAlias)->CENCOS := ALLTRIM( cCentroC ) + " - " + ALLTRIM( cDescCC )
						(cWTabAlias)->FUNCIO := ALLTRIM( cFuncion ) + " - " + AllTrim( cDesFunc )
						(cWTabAlias)->RFC    := (cTemp)->RA_CIC
						(cWTabAlias)->IMSS   := if((cTemp)->RA_CATFUNC <> "A",(cTemp)->RA_RG, "") // Autonomos nao possui Registro no IMSS
						(cWTabAlias)->CURP   := (cTemp)->RA_CURP
						(cWTabAlias)->SUEDIA := TRANSFORM(nSalDiar,"@E 999,999.999999")
						(cWTabAlias)->SDIAIN := if((cTemp)->RA_CATFUNC <> "A",TRANSFORM(nSalInt,"@E 999,999.999999"), "")//Autonoms no possui Sal Int
						(cWTabAlias)->LOGPAG := AllTrim( (cTemp)->RA_KEYLOC ) + " - " +;
						                        Substr( AllTrim( fPosTab( "S015", (cTemp)->RA_KEYLOC, "=", 4,,,,5) ), 1, 30 )
						(cWTabAlias)->PROCES := ALLTRIM( cProceso ) + " - " + ALLTRIM(cDesProc)
						(cWTabAlias)->ROTEIR := ALLTRIM( cRoteiro ) + " - " + ALLTRIM(cTipo)
						(cWTabAlias)->PERIOD := cPeriodo
						(cWTabAlias)->NUMPAG := Semana + " - " + DtoC( GravaData( dRCHDtIni, .T. ) ) + " a " + DtoC( GravaData( dRCHDtFim, .T. ) )
						(cWTabAlias)->LOGEMP := "lgrl"+cEmpAnt+".bmp"
					//Datos Percepsiones
						(cWTabAlias)->PERCOD := substr(aProve[nProv,1],1,4)
						(cWTabAlias)->PERDES := ALLTRIM(substr(aProve[nProv,1],5))
						(cWTabAlias)->PERREF := Transform(aProve[nProv,2],'999.99')
						(cWTabAlias)->PERVAL := Transform(aProve[nProv,3],cPict1)
						(cWTabAlias)->FLAGPE := "P"
					//--DADOS TOTALES
						(cWTabAlias)->TOTPER := Transform(TOTVENC,cPict1)
						(cWTabAlias)->TOTDED := Transform(TOTDESC,cPict1)
						(cWTabAlias)->CBANCO := if( ALLTRIM( (cTemp)->RA_BCDEPSA ) <> "" , ;
                                             ALLTRIM( (cTemp)->RA_BCDEPSA ) +" - "+ ALLTRIM( DescBco((cTemp)->RA_BCDEPSA,(cTemp)->RA_FILIAL) ) ,;
						                        ALLTRIM( DescBco((cTemp)->RA_BCDEPSA,(cTemp)->RA_FILIAL) ) )
						(cWTabAlias)->NETOCB := Transform((TOTVENC-TOTDESC),cPict1)
					//Dados mensagem
						(cWTabAlias)->MENSAJ := RTRIM(DESC_MSG1) + RTRIM(DESC_MSG2) + RTRIM(DESC_MSG3) + (chr(13)+chr(10) ) +;
						                        if(cMesComp == Month(STOD((cTemp)->RA_NASC)), OemToAnsi(STR0039),"")
						(cWTabAlias)->RODAPE := cMensRec
					(cWTabAlias)->(MsUnlock())

				Next nProv

				//DADOS Deduciones
				For nDesco := 1 to Len(aDesco)

				lRet	:= .T.

					RecLock(cWTabAlias, .T.)
					//Datos de la empresa
						(cWTabAlias)->EMPRES := ALLTRIM(DESC_Fil)
						(cWTabAlias)->REGPAT := ALLTRIM(cRegPatr)
						(cWTabAlias)->RFCEMP := ALLTRIM(Desc_CGC)
						(cWTabAlias)->DIRECC := ALLTRIM(Desc_End)+ Alltrim( Desc_Bair ) +" - "+ If( Empty( Desc_Bair ), "", ", " ) +;
						                        AllTrim( Desc_Cid ) + If( Empty(Desc_Cid), "",  ", " ) + (cTemp)->RA_ESTADO +;
						                        If( Empty((cTemp)->RA_ESTADO), "",  ", " ) + Desc_CEP
					//Datos Empleado
						(cWTabAlias)->MATRIC := (cTemp)->RA_MAT
						(cWTabAlias)->NOME   := ALLTRIM((cTemp)->RA_NOME)
						(cWTabAlias)->ORDEN  := StrZero(nOrdemZ,4)
						(cWTabAlias)->CENCOS := Alltrim( cCentroC ) + " - " + ALLTRIM(cDescCC)
						(cWTabAlias)->FUNCIO := ALLTRIM( cFuncion ) + " - " + AllTrim( cDesFunc )
						(cWTabAlias)->RFC    := (cTemp)->RA_CIC
						(cWTabAlias)->IMSS   := if( (cTemp)->RA_CATFUNC <> "A" , (cTemp)->RA_RG , "" ) // Autonomos nao possui Registro no IMSS
						(cWTabAlias)->CURP   := (cTemp)->RA_CURP
						(cWTabAlias)->SUEDIA := TRANSFORM(nSalDiar,"@E 999,999.999999")
						(cWTabAlias)->SDIAIN := if((cTemp)->RA_CATFUNC <> "A",TRANSFORM(nSalInt,"@E 999,999.999999"), "")//Autonoms no possui Sal Int
						(cWTabAlias)->LOGPAG := AllTrim( (cTemp)->RA_KEYLOC ) + " - " +;
						                        Substr( AllTrim( fPosTab( "S015", (cTemp)->RA_KEYLOC, "=", 4,,,,5) ), 1, 30 )
						(cWTabAlias)->PROCES := ALLTRIM( cProceso ) + " - " + ALLTRIM(cDesProc)
						(cWTabAlias)->ROTEIR := ALLTRIM( cRoteiro ) + " - " + ALLTRIM(cTipo)
						(cWTabAlias)->PERIOD := cPeriodo
						(cWTabAlias)->NUMPAG := Semana + " - " + DtoC( GravaData( dRCHDtIni, .T. ) ) + " a " + DtoC( GravaData( dRCHDtFim, .T. ) )
						(cWTabAlias)->LOGEMP := "lgrl"+cEmpAnt+".bmp"
					//DADOS Deduciones
						(cWTabAlias)->DEDCOD := substr(aDesco[nDesco,1],1,4)
						(cWTabAlias)->DEDDES := substr(aDesco[nDesco,1],5)
						(cWTabAlias)->DEDREF := Transform(aDesco[nDesco,2],'999.99')
						(cWTabAlias)->DEDVAL := Transform(aDesco[nDesco,3],cPict1)
						(cWTabAlias)->FLAGDE := "D"
					//--DADOS TOTALES
						(cWTabAlias)->TOTPER := Transform(TOTVENC,cPict1)
						(cWTabAlias)->TOTDED := Transform(TOTDESC,cPict1)
						(cWTabAlias)->CBANCO := if( ALLTRIM( (cTemp)->RA_BCDEPSA ) <> "" , ;
                                             ALLTRIM( (cTemp)->RA_BCDEPSA ) +" - "+ ALLTRIM( DescBco((cTemp)->RA_BCDEPSA,(cTemp)->RA_FILIAL) ) ,;
						                        ALLTRIM( DescBco((cTemp)->RA_BCDEPSA,(cTemp)->RA_FILIAL) ) )
						(cWTabAlias)->NETOCB := Transform((TOTVENC-TOTDESC),cPict1)
					//Dados mensagem
						(cWTabAlias)->MENSAJ := RTRIM(DESC_MSG1) + RTRIM(DESC_MSG2) + RTRIM(DESC_MSG3) + (chr(13)+chr(10) ) +;
						                        if(cMesComp == Month(STOD((cTemp)->RA_NASC)), OemToAnsi(STR0039),"")
						(cWTabAlias)->RODAPE := cMensRec
					(cWTabAlias)->(MsUnlock())

				Next nDesco

				RestArea( aSvArea )

			Endif

			(cTemp)->(dbSkip())
			TOTDESC := TOTVENC := 0

		EndDo

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ObtDatos    ³ Autor |Jonathan Gonzalez Rivera           | Data ³26/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcion encargada de extraer los datos de Trayectoria laboral, Historico   ³±±
±±³          ³Mod Salario y Transferencias del empleado.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ObtDatos(dEXP1,nEXP1,nEXP2,cEXP1,cEXP2,cEXP3,cEXP4,cEXP5,cEXP6,cEXP7,cEXP8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ genHTMl()                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dEXP1 = Fecha periodo final                                                ³±±
±±³          ³nEXP1 = valor salario diario                                               ³±±
±±³          ³nEXP2 = valor salario integral                                             ³±±
±±³          ³cEXP1 = Codigo del proceso                                                 ³±±
±±³          ³cEXP2 = Descripcion del proceso                                            ³±±
±±³          ³cEXP3 = Codigo Centro de Costo                                             ³±±
±±³          ³cEXP4 = Descripcion Centro de Costo                                        ³±±
±±³          ³cEXP5 = Codigo de la funcion del empleado                                  ³±±
±±³          ³cEXP6 = Descripcion de la funcion del empleado                             ³±±
±±³          ³cEXP7 = Codigo Registro patronal                                           ³±±
±±³          ³cEXP8 = Matricula del empleado                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ObtDatos(dPerFinal,nSalDiar,nSalInt,cProceso,cDesProc,cCentroC,cDescCC,cFuncion,cDesFunc,cRegPatr,cMatEmp)
	Local aArea  	:= (GetArea())
	Local cQueryRCP := "" //Trayectorial laboral
	Local cAliasRCP := CriaTrab(Nil,.F.)
	Local cQuerySRE := "" //Transferencias
	Local cAliasSRE := CriaTrab(Nil,.F.)
	Local cQuerySR7 := "" //Historial Modificaciones Salario
	Local cAliasSR7 := CriaTrab(Nil,.F.)

	cQueryRCP := " SELECT RCP_MAT,RCP_DTMOV,RCP_SALDIA,RCP_SALDII,RCP_CODRPA"
	cQueryRCP += " FROM " + RetSqlName("RCP") + " RCP "
	cQueryRCP += " WHERE  RCP.RCP_MAT ='"+cMatEmp+"' AND
	cQueryRCP += " RCP.RCP_DTMOV<='"+DTOS(dPerFinal)+"' AND
	cQueryRCP += " RCP.D_E_L_E_T_<>'*'
	cQueryRCP += " ORDER BY RCP_MAT,RCP_DTMOV DESC"
	cQueryRCP := ChangeQuery(cQueryRCP)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRCP),cAliasRCP,.T.,.T.)

	(cAliasRCP)->( dbGoTop() )
		IF  !(cAliasRCP)->(Eof())
			nSalDiar := (cAliasRCP)->RCP_SALDIA
			nSalInt  := (cAliasRCP)->RCP_SALDII
			cRegPatr := POSICIONE("RCO",RetOrdem("RCO","RCO_FILIAL+RCO_CODIGO"),XFILIAL("RCO")+(cAliasRCP)->RCP_CODRPA,"RCO_NREPAT")
		Endif
	(cAliasRCP)->( DBCloseArea() )

	cQuerySR7 := " SELECT R7_MAT,R7_DATA,R7_FUNCAO,R7_DESCFUN "
	cQuerySR7 += " FROM " + RetSqlName("SR7") + " SR7 "
	cQuerySR7 += " WHERE  SR7.R7_MAT ='"+cMatEmp+"' AND
	cQuerySR7 += " SR7.R7_DATA<='"+DTOS(dPerFinal)+"' AND
	cQuerySR7 += " SR7.D_E_L_E_T_<>'*'
	cQuerySR7 += " ORDER BY R7_MAT,R7_DATA DESC"
	cQuerySR7 := ChangeQuery(cQuerySR7)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySR7),cAliasSR7,.T.,.T.)

	(cAliasSR7)->( dbGoTop() )
		IF  !(cAliasSR7)->(Eof())
			cFuncion := (cAliasSR7)->R7_FUNCAO
		 	cDesFunc := (cAliasSR7)->R7_DESCFUN
		Endif
	(cAliasSR7)->( DBCloseArea() )

	cQuerySRE := " SELECT RE_MATD,RE_DATA,RE_PROCESP,RE_CCP "
	cQuerySRE += " FROM " + RetSqlName("SRE") + " SRE "
	cQuerySRE += " WHERE  SRE.RE_MATD ='"+cMatEmp+"' AND
	cQuerySRE += " SRE.RE_DATA<='"+DTOS(dPerFinal)+"' AND
	cQuerySRE += " SRE.D_E_L_E_T_<>'*'
	cQuerySRE += " ORDER BY RE_MATD,RE_DATA DESC"
	cQuerySRE := ChangeQuery(cQuerySRE)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySRE),cAliasSRE,.T.,.T.)

	(cAliasSRE)->( dbGoTop() )
		IF  !(cAliasSRE)->(Eof())
			cProceso := (cAliasSRE)->RE_PROCESP
			cDesProc := POSICIONE("RCJ",RetOrdem("RCJ","RCJ_FILIAL+RCJ_CODIGO"),XFILIAL("RCJ")+cProceso,"RCJ_DESCRI")
		 	cCentroC := (cAliasSRE)->RE_CCP
		 	cDescCC  := POSICIONE("CTT",RetOrdem("CTT","CTT_FILIAL+CTT_CUSTO"),XFILIAL("CTT")+cCentroC,"CTT_DESC01")
		Endif
	(cAliasSRE)->( DBCloseArea() )

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fSomaPdRec ³Autor|Jonathan Gonzalez Rivera       | Data ³26/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcion encargada de asignar a arrays las percepciones, dudecciones ³±±
±±³          ³y bases de los empleados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSomaPdRec(cEXP1,cEXP2,nEXP1,nEXP2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GP144MXIMP()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEXP1 = Define si son deducciones, percepciones o bases.            ³±±
±±³          ³cEXP2 = Codigo del concepto.                                        ³±±
±±³          ³nEXP1 = Horas base para la percepcion o deduccion.                  ³±±
±±³          ³nEXP2 = Valor de la percepcion o deduccion.                         ³±±
±±³          ³cEXP3 = Sucursal del empleado que se esta procesando                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSomaPdRec(cTipo,cPd,nHoras,nValor,cFil)
	Local Desc_paga

		Desc_paga := DescPd(cPd,cFil)  // mostra como pagto

		If PosSrv(cPD, cFil, "RV_IMPRIPD") == "2"
			Return
		EndIf

		If cTipo # 'B'
			//--Array para Recibo Pre-Impresso
			nPos := Ascan(aLanca,{ |X| X[2] = cPd })
			If nPos == 0
				Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
			Else
				aLanca[nPos,4] += nHoras
				aLanca[nPos,5] += nValor
			Endif
		Endif

		//--Array para o Recibo Pre-Impresso
		If cTipo = 'P'
			cArray := "aProve"
		Elseif cTipo = 'D'
			cArray := "aDesco"
		Elseif cTipo = 'B'
			cArray := "aBases"
		Endif

		nPos := Ascan(&cArray,{ |X| X[1] = cPd })
		If nPos == 0
			Aadd(&cArray,{cPd+" "+Desc_Paga,nHoras,nValor })
		Else
			&cArray[nPos,2] += nHoras
			&cArray[nPos,3] += nValor
		Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Gpr144Valid³ Autor ³Jonathan Gonzalez      ³ Data ³28/01/16³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida os campos periodo e numero de pagamento da pergunte ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave - Chave de pesquisa (RCH)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pergunte GPR144MEX - campos Processo (MV_PAR01),           ³±±
±±³          ³                             Periodo  (MV_PAR03) e          ³±±
±±³          ³                             Numero de Pagamento (MV_PAR04).³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gpr144Val(cProces , cRoteir , cPeriod, cSemana, nFlag)
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cRot
	Local lTipoAut
	Local nPerNumPg
	Local nFilProces
	Local nTamRoteiro

		//Valida proceso
		If nFlag == 1 //proceso

			RCJ->(DbSelectArea("RCJ"))
			RCJ->(DbSetOrder(1)) // SIX -> RCJ_FILIAL + RCJ_CODIGO

			lRet := RCJ->(DbSeek( XFILIAL("RCJ") + cProces ))

			RCJ->(dbCloseArea())

		ElseIf !( nFlag == 4 .AND. cSemana == "99" )
			If cRoteir <> "EXT"

				DbSelectArea( "RCH" )
				DbSetOrder( 4 ) // RCH_FILIAL + RCH_PROCESSO + RCH_ROTEIRO + RCH_PERIODO + RCH_NUMPAG
				If LEN( cProces ) < 5
					cChave := ( cProces + Space(5-Len(cProces)) + cRoteir + cPeriod + cSemana )
				Else
					cChave := ( cProces + cRoteir + cPeriod + cSemana )
				Endif

				cChave := xFilial( "RCH" ) + cChave
				DbSeek( cChave, .F. )
				If Eof()

					/*/ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  /*/
					nFilProces 	:= GetSx3Cache( "RCH_FILIAL", "X3_TAMANHO" ) + GetSx3Cache( "RCH_PROCES", "X3_TAMANHO" )
					nTamRoteiro	:= GetSx3Cache( "RCH_ROTEIR", "X3_TAMANHO" )
					cRot 	:= Substr(cChave, nFilProces+1, nTamRoteiro)
					nPerNumPg 	:= nFilProces + Len( cRot ) + 1
					lTipoAut 	:= ( fGetTipoRot( cRot ) == "9" )
					DbSelectArea("RCH")
					If lTipoAut
						DbSeek( Substr( cChave, 1, nFilProces ) + cRot + Substr( cChave, nPerNumPg ) , .F. )
					EndIf
					If Eof()

						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Pesquisar Periodo sem roteiro de calculo.                    ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						cRoteiro := Space( nTamRoteiro )
						cChave := Substr( cChave, 1, nFilProces ) + cRot + Substr( cChave, nPerNumPg )
						DbSeek( cChave, .F. )
						If Eof()
							/*
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							If lTipoAut
								cChave := Substr( cChave, 1, nFilProces ) + cRot
								DbSeek( cChave, .F. )
								If Eof()
									lTipoAut := .F.
								EndIf
							EndIf
							If !lTipoAut
								lRet 	 := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	RestArea( aArea )
Return ( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Gpr144Rot  ³ Autor ³Jonathan Gonzalez      ³ Data ³28/01/16³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descricao do roteiro selecionado na pergunte.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave - Chave de pesquisa (RCH)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pergunte GPR144MEX - campo Roteiro (MV_PAR02)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gpr144Rot(cRot)
	Local aArea := GetArea()
	Local lRet  := .T.

		lRet 		:= ExistCpo("SRY", cRot)
		cDescRel	:= ""
		If lRet
			cDescRel := fDesc( "SRY", cRot, "RY_DESC" )
		EndIf
	RestArea( aArea )
Return ( lRet )