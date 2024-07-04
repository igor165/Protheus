#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM872CHI.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPEM872CHI³ Autor ³ alfredo.medrano      ³ Data ³ 16/02/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera Acumulados (Chile)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM872CHI()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Preparar la información tanto del trabajador como de sus    ³±±
±±³          ³ acumulados anuales para la generación de la Declaración     ³±±
±±³          ³ Jurada Anual de Rentas.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS/FNC     ³  Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex Hdez   ³25/11/15³PCREQ-7944    ³Se paso a la v12 a partir del fuen-³±±
±±³            ³        ³              ³te de v11 con la fecha 13/11/15    ³±±
±±³ Alex Hdez  ³04/01/16³PCREQ-7944    ³Se agrego función GPE872RCWB para  ³±±
±±³            ³        ³              ³borrar los datos en la tabla RCW.  ³±±
±±³            ³        ³              ³Se modifico la funcion GPEM872RCV  ³±±
±±³            ³        ³              ³al generar "cLlave" xFilial("RCV") ³±±
±±³            ³        ³              ³por cFil. Se cambio la funcion GPEM³±±
±±³            ³        ³              ³872RCW al generar "cLlave" xFilial ³±±
±±³            ³        ³              ³("RCW") por cFil.                  ³±±
±±³ Alex Hdez  ³14/12/15³PCREQ-7944    ³Cambio funcion GPE872RCWB al genera³±±
±±³            ³        ³              ³r "cLlave" xFilial("RCW") por cFil.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPEM872CHI()
Local nOpca 	:= 0
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia
Private cCadastro := OemToAnsi(STR0001) //"Generación del Archivo de Declaracion Anual"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variables utilizadas  parametros                             ³
//³ mv_par01 - ¿Sucursales?                                      ³
//³ mv_par02 - ¿Empleados?                                       ³
//³ mv_par03 - ¿Centralizar en la Sucursal ?                     ³
//³ mv_par04 - ¿Año Base?                                        ³
//³ mv_par05 - ¿Respeta Ajustes Usuario?                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Pergunte("GPEM872CHI",.T.)
	Processa( {|lEnd| GPEM872PRO(@lEnd)}, OemToAnsi(STR0007),OemToAnsi(STR0004), .T. ) //"Favor de Aguardar....." //"Incio de la generación de acumulados para la Declaración Anual"
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPEM872PRO³ Autor ³ Alfredo Medrano       ³ Data ³17/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa informacion                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM872PRO(@ExpL1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd = Boolean                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM872CHI                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function GPEM872PRO(lEnd)
Local	  aArea 	 := getArea()
Local 	  lRet 	 := .T.
Local	  cAliasGR	 := criatrab( nil, .f. )
Local	  cQuery 	 := ""
Local 	  cFil		 := ""
Local 	  cMat		 := ""
Local 	  aMesAcum	 := {}
Local 	  cAno		 := ""
Local 	  nTotal	 := 0
Private  cFils	 := ""
Private  cMats	 := ""
Private  cCentra	 := mv_par03
Private  nAno		 := mv_par04
Private  nRespAjustes := mv_par05
Private  nFolio := 0
Private cMatTmp := ""

lEnd := .T.
cAno := Alltrim(STR(nAno))
ProcRegua(1)
//convierte parametros tipo Range a expresion sql
//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
MakeSqlExpr("GPEM872CHI")
	cFils		:= mv_par01
 	cMats		:= mv_par02

	//Se filtran los datos de las tablas RG7, SRA, SRV
	//Los renglones de conceptos diferentes RG7_PD pero del mismo RV_DIRF se suman
	cQuery := " SELECT RG7_FILIAL,RA_FILIAL,RG7_MAT,RA_MAT,RV_DIRF, "
	cQuery += " RA_CIC,RA_PRINOME,RA_PRISOBR,RA_SECSOBR,RA_ADMISSA,RA_DEMISSA, "
	cQuery += " SUM(RG7_ACUM01) MES1,SUM(RG7_ACUM02) MES2,SUM(RG7_ACUM03) MES3, "
	cQuery += " SUM(RG7_ACUM04) MES4,SUM(RG7_ACUM05) MES5, SUM(RG7_ACUM06) MES6, "
	cQuery += " SUM(RG7_ACUM07) MES7, SUM(RG7_ACUM08) MES8,SUM(RG7_ACUM09) MES9, "
	cQuery += " SUM(RG7_ACUM10) MES10,SUM(RG7_ACUM11) MES11, SUM(RG7_ACUM12) MES12 "
	cQuery += " FROM " + RetSqlName("RG7") + " RG7 INNER JOIN "
    cQuery +=   RetSqlName("SRA") + " SRA ON RG7.RG7_MAT = SRA.RA_MAT AND
    cQuery += " RG7.RG7_FILIAL=SRA.RA_FILIAL LEFT OUTER JOIN "
    cQuery +=	RetSqlName("SRV") + " SRV ON RG7.RG7_PD = SRV.RV_COD
    cQuery += " WHERE SRV.RV_DIRF NOT IN (' ', 'N') AND RG7.RG7_CODCRI='01' "
   If	!Empty( cAno )
		cQuery += " AND RG7_ANOINI = '" + cAno +" '"
	EndIf
   If	!Empty( cFils )
		cQuery += " AND " + cFils
	EndIf
	If	!Empty( cMats )
		cQuery += " AND " + cMats
	EndIf
	cQuery += " AND SRV.RV_FILIAL	=  '" + XFILIAL('SRV') + "' "
	cQuery += " AND RG7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY  RG7.RG7_FILIAL, SRA.RA_FILIAL, RG7.RG7_MAT, SRA.RA_MAT, SRV.RV_DIRF, "
	cQuery += " SRA.RA_CIC,SRA.RA_PRINOME,SRA.RA_PRISOBR, SRA.RA_SECSOBR, SRA.RA_ADMISSA, SRA.RA_DEMISSA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGR,.T.,.T.)

	TCSetField(cAliasGR,"RA_ADMISSA","D",8,0) // Formato de fecha
	TCSetField(cAliasGR,"RA_DEMISSA","D",8,0) // Formato de fecha

	Count to nTotal
	If nTotal <= 0
		Msginfo(OemToAnsi(STR0018) )//"No existe información con esos parámetros"
		Return Nil
	EndIf

	ProcRegua(nTotal)
	(cAliasGR)->(dbgotop())//primer registro de tabla
	While  (cAliasGR)->(!EOF())

	IncProc(OemToAnsi(STR0017) + ( cAliasGR )->RA_MAT  ) //"Procesando Empleado : "
		If cFil != ( cAliasGR )->RA_FILIAL .or. cMat != ( cAliasGR )->RA_MAT
			cCentra := If(Empty(cCentra), (cAliasGR)->RA_FILIAL, cCentra)

			IF cFil != ( cAliasGR )->RA_FILIAL
				nFolio := 0
			EndIf

			GPEM872RCV(	( cAliasGR )->RA_FILIAL, ( cAliasGR )->RA_MAT, ( cAliasGR )->RA_CIC, nAno,;
							( cAliasGR )->RA_ADMISSA, ( cAliasGR )->RA_DEMISSA, ( cAliasGR )->RA_PRINOME, '',;
							( cAliasGR )->RA_PRISOBR, ( cAliasGR )->RA_SECSOBR, cCentra )
		EndIf

		AADD(aMesAcum,{	( cAliasGR )->MES1,( cAliasGR )->MES2,( cAliasGR )->MES3,( cAliasGR )->MES4,( cAliasGR )->MES5,;
							( cAliasGR )->MES6,( cAliasGR )->MES7,( cAliasGR )->MES8,( cAliasGR )->MES9,( cAliasGR )->MES10,;
							( cAliasGR )->MES11,( cAliasGR )->MES12})
		

		GPEM872RCW(	( cAliasGR )->RA_FILIAL, ( cAliasGR )->RA_MAT, ( cAliasGR )->RA_CIC, nAno,;
						( cAliasGR )->RA_ADMISSA, ( cAliasGR )->RA_DEMISSA, ( cAliasGR )->RV_DIRF, aMesAcum )

		cFil := ( cAliasGR )->RA_FILIAL
		cMat := ( cAliasGR )->RA_MAT

		aMesAcum :={}
	( cAliasGR )-> (dbskip())

	EndDo

	Msginfo( OemToAnsi(STR0006))//"Proceso Generado con éxito."
	( cAliasGR )->(dbCloseArea())
	restArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPEM872RCV³ Autor ³ Alfredo Medrano       ³ Data ³18/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agrega Registros en la Tabla RCV Decla. Jurada Encabezado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM872RCV(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6,ExpC7,ExpC8 ³±±
±±³          ³ ExpC9,ExpC10)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ³±±
±±³          ³ ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems,    ³±±
±±³          ³ ExpC7 = Prim.Nom ExpC8 = Sec.Nom     ExpC9 = Prim.Sobr.,   ³±±
±±³          ³ ExpC10= Sec.Sobr                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM872PRO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPEM872RCV (cFil, cMat, cCIC, nAnio, dAdmss, dDemss, cPriNom, cSecnom, cPrisob, cSecsob, cCentra )
Local nAux01    := 0
Local cRutDecla := ""
Local cNomDecla := ""
Local cRutReLeg := ""
Local cNomReLeg := ""
Local cMailDecl := ""
Local cAnio	  := Alltrim(STR(nAno))
Local cEmpresa  := ""
Local cLlave    := ""
Local cMesIni   := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin   := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )
Local lSalir    := .F.

    DbSelectArea("SRA")
    DbSetOrder(1) // RA_FILIAL + RA_MAT
    If dbSeek(xFilial("SRA") + cMat)
        cEmpresa := SRA->RA_EMPRESA
    EndIf
    SRA->( dbCloseArea() )

    nAux01 := fPosTab("S013", cEmpresa, "=", 4)

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))

    If Empty(cCentra)
        cCentra := cFil
    EndIf

    If ( SM0->(dbSeek( SM0->M0_CODIGO + cCentra )))
        cRutDecla := SM0->M0_CGC	 // Rut Declarante
        cNomDecla := SM0->M0_NOMECOMP  //Nom. Declarante
    EndIf

    cRutReLeg := If(nAux01 > 0, fTabela("S013", nAux01, 6), " ") //Rut Representante Legal
    cNomReLeg := If(nAux01 > 0, fTabela("S013", nAux01, 5), " ") //Nom. Representante Legal
    cMailDecl := If(nAux01 > 0, fTabela("S013", nAux01, 7), " ") //Email Declarante
    nFolio++

/*Agrega registro a la tabla RCV encabezado Decla. Jurada */
// Si existe un registro en esta BD
	dbSelectArea("RCV")
	dbSetOrder(1) // 8RCV_FILIAL+6RCV_MAT+9RCV_RFC+4RCV_ANO+2RCV_MESINI+2RCV_MESFIN=31
	cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin

    If dbSeek(cLlave) // si lo encuentra lo borra
        If (nRespAjustes == 2 .And. RCV->RCV_STATUS == "U") // respetar ajustes por el usuario
            lSalir := .T.
        Else // borrado
            While RCV->(!eof()) .and. RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN == cLlave
            //Elimina los registros de la tabla "Declaracion Jurada Detalle"
                RecLock("RCV",.F.,.T.)
                RCV->(dbDelete())
                MsUnlock()
                RCV->(dbSkip())
                IncProc(OemToAnsi(STR0014))//"Limpiando Tabla RCV..."
            EndDo
        EndIf
    EndIf

    If (!lSalir)
        RecLock("RCV", .T.) // inserta un registro nuevo
	        RCV->RCV_FILIAL 	:= cFil
	        RCV->RCV_MAT 	:= cMat
	        RCV->RCV_RFC 	:= cCIC
	        RCV->RCV_ANO 	:= cAnio
	        RCV->RCV_MESINI 	:= cMesIni
	        RCV->RCV_MESFIN 	:= cMesFin
	        RCV->RCV_PRINOM	:= cPriNom
	        RCV->RCV_SEGNOM	:= cSecnom
	        RCV->RCV_PRISOB	:= cPrisob
	        RCV->RCV_SEGSOB	:= cSecsob
	        RCV->RCV_FILFON	:= cCentra
	        RCV->RCV_RFCFON	:= cRutDecla
	        RCV->RCV_NOMFON 	:= cNomDecla
	        RCV->RCV_RFCREP	:= cRutReLeg
	        RCV->RCV_EMAIL	:= cMailDecl
	        RCV->RCV_NOMREP	:= cNomReLeg
	        RCV->RCV_STATUS	:= "S"
	        RCV->RCV_FOLIO	:= nFolio
        RCV->(MsUnlock())

        IncProc(OemToAnsi(STR0012))//"Agregando Registros a Tabla RCV..."
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPEM872RCW³ Autor ³ Alfredo Medrano       ³ Data ³18/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agrega Registros en la Tabla RCW Decla. Jurada Detalle.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM872RCW(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6,ExpC7,ExpA8 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ³±±
±±³          ³ ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems,    ³±±
±±³          ³ ExpC7 = Dirf.    ExpA8 = Valor de los Meses                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM872PRO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPEM872RCW(cFil, cMat, cCIC, nAnio, dAdmss, dDemss, cDirf, aMesAcum )
Local nNum		:= 12
Local nX		:= 0
Local cAnio	:=  Alltrim(STR(nAno))
Local cMesIni := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )

IF cMatTmp <> cMat //Borra los datos de la RCW 
	GPE872RCWB(cFil, cMat, cCIC, nAnio, dAdmss, dDemss )
	cMatTmp := cMat
EndIf

For nX := 1  To nNum
/*Agrega registro a la tabla RCW detalle Decla. Jurada */
    dbSelectArea("RCW")
    dbSetOrder(1) // RCW_FILIAL+RCW_MAT+RCW_RFC+RCW_ANO+RCW_MESINI+RCW_MESFIN+RCW_MES+RCW_TIPORE 
    cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin+strzero(nX,2)+cDirf
    If !dbSeek(cLlave)
       	RecLock("RCW", .T.) // inserta un registro nuevo
			RCW->RCW_FILIAL 	:= cFil
			RCW->RCW_MAT 	:= cMat
			RCW->RCW_RFC 	:= cCIC
			RCW->RCW_ANO 	:= cAnio
			RCW->RCW_MESINI 	:= cMesIni
			RCW->RCW_MESFIN	:= cMesFin
			RCW->RCW_TIPORE	:= cDirf
			RCW->RCW_MES		:= strzero(nX,2)
			RCW->RCW_VALOR	:= aMesAcum[1][nX]
			RCW->RCW_STATUS	:= "S"
			RCW->(MsUnlock())
			IncProc(OemToAnsi(STR0016))		//"Agregando Registros a Tabla RCW..."   
		  	
	ENDIF
Next

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPE872RCWB³ Autor ³ Alex Hdez             ³ Data ³04/12/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Borra los datos del empleado de la Tabla RCW.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPE872RCWB(ExpC1,ExpC2,ExpC3,ExpN4,ExpD5,ExpD6)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial,  ExpC1 = Matricula,  ExpC3 = RUT,          ³±±
±±³          ³ ExpN4 = Anio,    ExpD5 = Fch. Admis, ExpD6 = Fch. Dems     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM872CHI                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPE872RCWB(cFil, cMat, cCIC, nAnio, dAdmss, dDemss)
Local nNum		:= 12
Local nX		:= 0
Local cAnio	:=  Alltrim(STR(nAno))
Local cMesIni := If( Year(dAdmss) >= nAnio, StrZero(Month(dAdmss),2), "01" )
Local cMesFin := If( Year(dDemss) == nAnio, StrZero(Month(dDemss),2), "12" )

For nX := 1  To nNum
/*Agrega registro a la tabla RCW detalle Decla. Jurada */
    dbSelectArea("RCW")
    dbSetOrder(1) // RCW_FILIAL+RCW_MAT+RCW_RFC+RCW_ANO+RCW_MESINI+RCW_MESFIN+RCW_MES+RCW_TIPORE 
    cLlave := cFil+cMat+cCIC+cAnio+cMesIni+cMesFin+strzero(nX,2)

    If dbSeek(cLlave) // si lo encuentra lo borra
            While RCW->(!eof()) .and. RCW->RCW_FILIAL+RCW->RCW_MAT+RCW->RCW_RFC+RCW->RCW_ANO+RCW->RCW_MESINI+RCW->RCW_MESFIN+RCW->RCW_MES == cLlave 
                //Elimina los registros de la tabla "Declaracion Jurada Detalle"
                If !(nRespAjustes == 2 .And. RCW->RCW_STATUS == "U") .OR. nRespAjustes == 1 // respetar ajustes por el usuario
	                RecLock("RCW",.F.,.T.)
	                RCW->(dbDelete())
	                MsUnlock()
	                IncProc(OemToAnsi(STR0015))     //"Limpiando Tabla RCW..."
	             Endif        
                RCW->(dbSkip())                
            EndDo
    EndIf

Next

Return
