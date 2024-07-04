#INCLUDE "Totvs.CH"
#INCLUDE "FISA839.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA839
Generación de TXT RG 016-12 - Posadas RETENCIONES

@type 		Function

@author 	raul.medina
@version	12.1.27 / Superior
@since		28/07/2021 
/*/
//-------------------------------------------------------------------
Function FISA839()
Local aArea		    := getArea()
Local oFld		    := Nil
Local oDialog       := Nil
Local lAutomato 	:= IsBlind()

	If !lAutomato
		DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"RG 016-12 - Posadas Retenciones"

		@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Exportacion de TXT"

		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la exportacion de un TXT con las "
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"retenciones de impuestos municipales de Posadas."
		@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"RG 016-12 – Municipalidad de Posadas"
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	    //"&Exportar"
		@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDialog:End() 	//"&Salir"
		ACTIVATE MSDIALOG oDialog CENTER
	Else
		RunProc()
	EndIf

	Restarea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc
Generación de TXT RG 016-12 - Posadas RETENCIONES

@type 		Function

@author 	raul.medina
@version	12.1.27 / Superior
@since		28/07/2021 
/*/
//-------------------------------------------------------------------
Static Function RunProc()
Local aDatos        := {}
Local aDatosA       := {}
Local cFileNameTxt 	:= ""
Local aSucsCalc     := {}
Local cSucursal     := ""
Local nSuc	        := 0
Local cCGC          := ""
Local cNomenc       := ""
Local nI            := 0
Local nPoSCuit      := 0
Local aArea         := getArea()
Local nOpEx         := 0
Local cRuta         := ""
Local lAutomato 	:= IsBlind()
Local lProc			:= .F.

	If lAutomato
		lProc := .T.
	Else
		lProc := Pergunte("FISA839",.T.)
	EndIf

	If lProc
		If ValidParam()
            cRuta           := RTRIM(MV_PAR04)
            cFileNameTxt 	:= RTRIM(MV_PAR05)
			If MV_PAR06 == 1
				aSucsCalc := MatFilLCal(MV_PAR06 == 1,,,,)
				If Empty(aSucsCalc)
					Return
				EndIf
				If MV_PAR07 == 1 //Agrupa todos los registros por el mismo cuit
					aDatosA := {}
					nOpEx := 0
					For nSuc := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSuc,1])
							aDatos := {}
							cCGC := RIGHT(AllTrim(aSucsCalc[nSuc,4]),11)
							cSucursal := aSucsCalc[nSuc,2]
							nPoSCuit := aScan(aDatosA,{|x| Substr(x[1][2],1,11) $ cCGC })  //Busca cuit para agrupar
							If nPoSCuit == 0								
								cNomenc := aSucsCalc[nSuc,3]
								cNomenc := STRTRAN(Alltrim(cNomenc),";")
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
								Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
									Alltrim(cCGC)+";",;
									Alltrim(cNomenc)+";",;
									SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
									STR0022+";",";" })
								nOpEx := 0
							Else
								nOpEx := Val(aDatosA[nPoSCuit][1][6])
							EndIf
							Processa( {|| GetRet(@aDatos,cSucursal,@nOpEx)}, STR0020,STR0018, .T. )
							If nPoSCuit == 0
								Aadd(aDatosA, aDatos)
								aDatosA[Len(aDatosA)][1][6] := Alltrim(Str(nOpEx))
							Else
								AEval( aDatos,  { | x | AAdd( aDatosA[nPoSCuit], x ) } )
								aDatosA[nPoSCuit][1][6] := Alltrim(Str(nOpEx))
							EndIf
						EndIf
					Next

					For nI := 1 To Len(aDatosA)
						Processa( {|| genFile(.F.,aDatosA[nI], cRuta + Substr(aDatosA[nI][1][2],1,11) + "_" +cFileNameTxt)}	, STR0020,STR0021, .T. )
					Next
				ElseIf MV_PAR07 == 2
					For nSuc := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSuc,1])
							cSucursal := aSucsCalc[nSuc,2]
							cCGC := AllTrim(aSucsCalc[nSuc,4])
							cNomenc := aSucsCalc[nSuc,3]
							cNomenc := STRTRAN(Alltrim(cNomenc),";")
							cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
							cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
							aDatos := {}
							Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
								RIGHT(cCGC,11)+";",;
								Alltrim(RIGHT(cNomenc,255))+";",;
								SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
								STR0022+";",";" })
							nOpEx := 0
							Processa( {|| GetRet(@aDatos,cSucursal,@nOpEx)}, STR0020,STR0018, .T. )
							aDatos[1][6] := Alltrim(Str(nOpEx))
							Processa( {|| genFile(.F.,aDatos,cRuta + cSucursal + "_" + cFileNameTxt)}	, STR0020,STR0021, .T. )
						EndIf
					Next
				EndIf
			ElseIf MV_PAR06 == 2 //Toma la sucursal en curso
				cCGC := AllTrim(SM0->M0_CGC)
				cNomenc := SM0->M0_NOMECOM
				cNomenc := STRTRAN(Alltrim(cNomenc),";")
				cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
				cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
				aDatos := {}
				Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
					RIGHT(cCGC,11)+";",;
					Alltrim(RIGHT(cNomenc,255))+";",;
					SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
					STR0022+";",";" })
				nOpEx := 0
				Processa( {|| GetRet(@aDatos,cFilAnt,@nOpEx)}, STR0020,STR0018, .T. )
				aDatos[1][6] := Alltrim(Str(nOpEx))
				Processa( {|| genFile(.F.,aDatos,cRuta + cFileNameTxt)}	, STR0020,STR0021, .T. )
			EndIf
			MSGINFO(STR0011)
		EndIf
	EndIf

    Restarea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidParam
Validación de parámetros

@type 		Function

@author 	raul.medina
@version	12.1.27 / Superior
@since		28/07/2021 
/*/
//-------------------------------------------------------------------
Static Function ValidParam()
	Local lRet:=  .T.
	Local cErr := ""

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05);
			.Or. Empty(MV_PAR06) .Or. Empty(MV_PAR07)
		cErr += STR0008 + " " //"Por favor, complete todos los parametros solicitados"
		lRet := .F.
	End
	If Alltrim(Str(YEAR(MV_PAR01)))+Alltrim(Str(MONTH(MV_PAR01))) != Alltrim(Str(YEAR(MV_PAR02)))+Alltrim(Str(MONTH(MV_PAR02)))
		cErr += STR0009 + " " //"El rango de fechas debe pertenecer al mismo periodo."
		lRet := .F.
	EndIf
	If Len(Alltrim(MV_PAR03)) > 6 .AND. AT("/",MV_PAR03) != 7 .OR. Len(Alltrim(MV_PAR03)) != 9
		cErr += STR0010 // "Verifique el formato del numero de habilitacion 000000/00"
		lRet := .F.
	End
	If lRet == .F.
		MSgAlert(cErr)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRet
Validación de parámetros

@type 		Function

@author 	raul.medina
@version	12.1.27 / Superior
@since		28/07/2021 
/*/
//-------------------------------------------------------------------
Static function GetRet(aData, cSucursal, nNoRet)
Local cQuery    := ""
Local cTmp		:= GetNextAlias()
Local nRegs		:= 0
Local aArea		:= getArea()
Local nPosReg	:= 0
Local cCuit		:= ""

    cQuery  := "Select "
    cQuery  += "A2_NOME, A2_CGC, "
    cQuery  += "FE_ORDPAGO, FE_NROCERT, FE_NRETORI, FE_EMISSAO, SUM(FE_VALBASE) AS BASE, FE_ALIQ, SUM(FE_RETENC) AS RETEN "
    cQuery  += "from "
    cQuery  += RetSqlName("SFE") + " SFE, "
    cQuery  += RetSqlName("SA2") + " SA2 "
    cQuery  +=      "Where "
    cQuery  +=          "FE_EST = 'MI' "
    cQuery  +=          "And FE_TIPO = 'M' "
    cQuery  +=          "And FE_FORNECE <> '' "
    cQuery  +=          "And FE_EMISSAO >='" + DTOS(MV_PAR01) + "' "
    cQuery  +=          "And FE_EMISSAO <='" + DTOS(MV_PAR02) + "' "
    cQuery  +=          "And FE_FORNECE = A2_COD "
	If VldModAcc() //Valida la comparticion de la tabla SFE.
    	cQuery  +=     	"And FE_MSFIL = '" + cSucursal + "' "
	Else
		cQuery  +=		"And FE_FILIAL = '" + xFilial("SFE",cSucursal) + "' "
	EndIf
   	cQuery  +=          "And A2_FILIAL = '" + xFilial("SA2",cSucursal) + "' "
	cQuery  += 			"And A2_LOJA = FE_LOJA "
    cQuery  +=          "And SFE.D_E_L_E_T_= ' ' "
    cQuery  +=          "And SA2.D_E_L_E_T_= ' ' "
	cQuery	+= 			"And ( FE_DTESTOR <'" + DTOS(MV_PAR01) + "' Or "
	cQuery	+=			"FE_DTESTOR >'" + DTOS(MV_PAR02) + "' Or "
	cQuery	+=			"FE_DTESTOR = ' ' Or "
	cQuery	+=			"FE_NRETORI <> ' ' "
	cQuery	+=			") And ( "
	cQuery	+=			"FE_DTRETOR <'" + DTOS(MV_PAR01) + "' Or "
	cQuery	+=			"FE_DTRETOR >'" + DTOS(MV_PAR02) + "' Or "
	cQuery	+=			"FE_DTRETOR = ' ' Or "
	cQuery	+=			"FE_NRETORI = ' ' ) "
    cQuery  +=      "GROUP BY "
    cQuery  +=          "A2_NOME, A2_CGC, FE_ORDPAGO, FE_NROCERT, FE_EMISSAO, FE_ALIQ, FE_NRETORI"


    cQuery  := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TcSetField( cTmp, 'FE_EMISSAO', 'D', TamSX3('FE_EMISSAO')[1], 0 )
	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
        nRegs++
		IncProc(STR0018 + str(nRegs))
		
		If AllTrim((cTmp)->FE_NROCERT) == 'NORET' 
			nNoRet ++
			(cTmp)-> (dbSkip())
			Loop
		EndIf

		cCuit 	:= STRZERO(Val((cTmp)->A2_CGC),11,0)
		cNoCert := RIGHT((cTmp)->FE_NROCERT,12)

		nPosReg := aScan(aData,{|x| x[1] == cCuit .and. x[3] == cNoCert })

		If nPosReg == 0
			AADD(aData,;
				{ cCuit + ";",;
				Alltrim((cTmp)->A2_NOME)+";",;
				cNoCert+";",;
				STR0019+";",;
				DTOC((cTmp)->FE_EMISSAO)+";",;
				Alltrim(TRANSFORM((cTmp)->BASE,     "@! 9999999.99"))+";",;
				Alltrim(TRANSFORM((cTmp)->FE_ALIQ,  "@! 9999999.99"))+";",;
				Alltrim(TRANSFORM((cTmp)->RETEN ,   "@! 9999999.99"))})
		EndIf

        (cTmp)-> (dbSkip())
    EndDo
	(cTmp)-> (dbCloseArea())
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} genFile
Realiza la escritura del archivo

@type 		Function

@author 	raul.medina
@version	12.1.27 / Superior
@since		28/07/2021 
/*/
//-------------------------------------------------------------------
Static Function genFile(lAgrup, aArq,cFileName)
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local nK		:= 0
	Local nArqLog	:= 0

	if Len(aArq) > 0
		If File(cFileName)
			FErase(cFileName)
		EndIf
		nArqLog	:= MSfCreate(cFileName, 0)
		ProcRegua(Len(aArq))
		For nI:=1 To Len(aArq)
			If nI == 1
				FWrite(nArqLog,"'"+STR0024+"';'"+STR0037+"';'"+STR0026+"';'"+STR0027+"';'"+STR0028+"';'"+STR0029+"'"+Chr(13)+Chr(10))
			elseif nI == 2
				FWrite(nArqLog,Chr(13)+Chr(10))
				FWrite(nArqLog,"'"+STR0037+"';'"+STR0030+"';'"+STR0031+"';'"+STR0032+"';'"+STR0033+"';'"+STR0034+"';'"+STR0035+"';'"+STR0036+"'"+Chr(13)+Chr(10))
			EndIf
			IncProc(STR0012 + str(nI))
			If lAgrup
				For nJ:= 1 to Len(aArq[nI])
					For nK:= 1 to Len(aArq[nI,nJ])
						cLinea	+= aArq[nI,nJ,nK]
					Next nK
					FWrite(nArqLog,cLinea+Chr(13)+Chr(10))
					cLinea:= ""
				Next nJ
			Else
				For nJ:= 1 to Len(aArq[nI])
					cLinea	+= aArq[nI,nJ]
				Next nJ
				FWrite(nArqLog,cLinea+Chr(13)+Chr(10))
				cLinea:= ""
			EndIf
		Next nI
		FClose(nArqLog)
	EndIf

Return .T.

Static Function MatFilLCal(lMostratela,aListaFil,lChkUser,nOpca,nValida,lContEmp)
Local aFilsCalc	:= {}
// Variaveis utilizadas na selecao de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk       := LoadBitmap(GetResources(),"LBOK")
Local oNo       := LoadBitmap(GetResources(),"LBNO")
// Variaveis utilizadas para lista de filiais
Local lIsBlind  := IsBlind()

Local aAreaSM0	:= SM0->(GetArea())
Local aSM0      := FWLoadSM0(.T.,,.T.)

Local oDlg	        := Nil

Default nValida	:= 0 //0=Legado Seleção Livre
Default lMostraTela	:= .F.
Default aListaFil	:= {{.T., cFilAnt}}
Default lchkUser	:= .T.
Default lContEmp 	:= .F.
Default nOpca		:= 1

//-- Carrega filiais da empresa corrente
	lChkUser := !GetAPOInfo("FWFILIAL.PRW")[4] < CTOD("10/01/2013")

	aEval(aSM0,{|x| If(x[SM0_GRPEMP] == cEmpAnt .And.;
		Iif (!lContEmp ,x[SM0_EMPRESA] == FWCompany(),.T.) .And.;
		(!lChkUser .Or. x[SM0_USEROK].Or. lIsBlind) .And.;
		(x[SM0_EMPOK] .Or. lIsBlind),;
		aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
		Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM")}),;
		NIL)})

//-- Monta tela para selecao de filiais
	If lMostraTela
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi(STR0013) OF oDlg  PIXEL
		@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0014) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))
		@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017) SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL
		bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@R 99-99999999-9")}}
		oQual:SetArray(aFilsCalc)
		oQual:bLine := bLine
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(MtFCalOk(@aFilsCalc,.T.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(MtFCalOk(@aFilsCalc,.F.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	RestArea(aAreaSM0)
Return aFilsCalc


Static Function MtFClTroca(nIt,aArray,nValida,cSelCNPJIE)
	Default nValida := 0
	If nValida == 0
		aArray[nIt,1] := !aArray[nIt,1]
	Endif
Return aArray


/*/{Protheus.doc} VldModAcc
	@description Valida si existe comparticion de tablas.
	@type  Static Function
	@author alejandro.parrales
	@since 26/06/2022
	@return lRet
/*/
Static Function VldModAcc()
	Local lRet := .F.
	If FwModeAccess("SFE",1) + FwModeAccess("SFE",2) + FwModeAccess("SFE",3) == "CCC" .AND.;
		FwModeAccess("SA2",1) + FwModeAccess("SA2",2) + FwModeAccess("SA2",3) == "CCC"
		If SFE->(ColumnPos("FE_MSFIL")) > 0
			lRet := .T.
		EndIf
	EndIf
Return lRet
