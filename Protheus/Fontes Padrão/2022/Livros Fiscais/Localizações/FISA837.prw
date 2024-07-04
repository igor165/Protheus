#INCLUDE "Totvs.CH"
#INCLUDE "FISA837.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
±±Program   | FISA837   | Autor |Alejandro Parrales ±± Data09.03.2021    ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Descripcion  ±± RG 001-12 - Posadas - Percepciones                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Retorno   ±±  Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Parametrosï±± Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±DATA   ±± Programador   ±±Manutencao Efetuada                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±        ±±               ±±                                            ±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
/*/
Function FISA837()
	Local aArea		:= getArea()
	Local oFld		:= Nil
	Private _lRegs	:= .F.
	Private oDlg	:= Nil
	Private oDialog := Nil

	DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"RG1510 Percepciones y Retenciones Jujuy"

	@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Exportacion de TXT"

	@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la exportacion de un TXT con las "
	@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepciones y retenciones de impuestos "
	@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"para la provincia de Jujuy."
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
	@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDialog:End() 		//"&Sair"
	ACTIVATE MSDIALOG oDialog CENTER
	Restarea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
±±Program   | FISA836   | Autor |Alejandro Parrales ±± Data13.01.2021    ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Descripcion  ±± RG 001-12 - Posadas - Percepciones                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Retorno   ±±  Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Parametrosï±± Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±DATA   ±± Programador   ±±Manutencao Efetuada                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±        ±±               ±±                                            ±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
*/
Static Function RunProc()
	Local aDatos		:= {}
	Local aDatosA := {}
	Local aSucsCalc := {}
	Local cSucursal := ""
	Local nSucus:= 0
	Local nI := 0
	Local lAuto := IsBlind()
	If Pergunte("FISA837",.T.)
		If ValidParam()
			If MV_PAR04 == 1 // Selecciona Sucursales
				aSucsCalc := MatFilLCal(.T.,,,,)
				If Empty(aSucsCalc)
					Return
				EndIf
				If MV_PAR05 == 1 //Agrupa sucursales
					aDatosA := {}
					For nI := 1 To Len(aSucsCalc)
						If (aSucsCalc[nI,1])
							aDatos := {}
							Processa( {|| GenArqPer(@aDatos,aSucsCalc[nI][2])}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Aadd(aDatosA, aDatos)
						EndIf
					Next
					Processa( {|| genFile(.T.,aDatosA, AllTrim(MV_PAR03)+" "+cSucursal+".txt")} , STR0011,STR0010, .T. ) //"Atención" Seleccionando registros...
				ElseIf MV_PAR05 == 2 //No agrupa sucursales
					For nSucus := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSucus,1])
							cSucursal := aSucsCalc[nSucus,2]
							aDatos := {}
							Processa( {|| GenArqPer(@aDatos,cSucursal)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Processa( {|| genFile(.F.,aDatos, AllTrim(MV_PAR03)+" "+cSucursal+".txt")}	, STR0011,STR0010, .T. ) //"Atención" Seleccionando registros...
						EndIf
					Next
				EndIf
			Else //Toma la sucursal en curso
				aDatos := {}
				If lAuto
					GenArqPer(@aDatos,cFilAnt)
				Else
					Processa( {|| GenArqPer(@aDatos,cFilAnt)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
					Processa( {|| genFile(.F.,aDatos,AllTrim(MV_PAR03)+" "+cFilAnt+".txt")}	, STR0011,STR0010, .T. ) //"Atención" Seleccionando registros...
				EndIf

			EndIf
			MSGINFO(STR0014) // "Procedimiento finalizado."
		EndIf
	EndIf
Return .T.

//+----------------------------------------------------------------------+
//|Valida parametros de entrada											 |
//+----------------------------------------------------------------------+
Static Function ValidParam()
	Local lRet:=  .T.
	Local cErr := ""
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. Empty(MV_PAR03) .or. Empty(MV_PAR04);
			.or. Empty(MV_PAR05) .or.Empty(MV_PAR06)
		cErr += STR0008 + " " //"Por favor, complete todos los parametros solicitados"
		lRet := .F.
	End
	If Alltrim(Str(YEAR(MV_PAR01)))+Alltrim(Str(MONTH(MV_PAR01))) != Alltrim(Str(YEAR(MV_PAR02)))+Alltrim(Str(MONTH(MV_PAR02)))
		cErr += STR0016 + " " //"El rango de fechas debe pertenecer al mismo periodo."
		lRet := .F.
	EndIf
	If lRet == .F.
		MSgAlert(cErr)
	EndIf
Return lRet

//+----------------------------------------------------------------------+
//|Realiza el proceso para obtener los registrso de percepciones    	 |
//+----------------------------------------------------------------------+
//|Parï¿½metros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|aDatos													 |
//|				|	Array en dï¿½nde serï¿½n almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//+-------------+--------------------------------------------------------+

Static Function GenArqPer(aDatos, cSucursal)
	Local cCpo := ""
	Default aDatos := ""
	Default cSucursal := ""

	If MV_PAR06 == 1
		cCpo	:=  GetCpoImp(cSucursal) //Obtiene el cpo del impuesto IBC
		If cCpo != ""
			PerSF3(1,@aDatos,cCpo,cSucursal) //1.-Percepciones Clientes
			//PerSF3(2,@aDatos,cCpo,cSucursal) //2.-Percepciones Proveedores
		EndIf
	ElseIf MV_PAR06 == 2
		RetSFE(1,@aDatos,cSucursal) //Retenciones Proveedor Efectuadas
	ElseIf MV_PAR06 == 3
		RetSFE(2,@aDatos,cSucursal) //Retenciones Proveedor Revertidas
	EndIf

Return

//+----------------------------------------------------------------------+
//|Obtiene el campo del cuï¿½l se obtendrï¿½ el importe de las percepciones	 |
//+----------------------------------------------------------------------+
Static Function GetCpoImp(cSucursal)
	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "tempIBC"
	Local cCpo		:= ""
	Default cSucursal := ""

	cQuery	:= 	"SELECT "
	cQuery	+=	"FB_CPOLVRO "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SFB") + " SFB "
	cQuery	+=	"WHERE "
	cQuery 	+=  "FB_ESTADO ='"+ Alltrim(MV_PAR07) +"' AND "
	cQuery	+=	"FB_FILIAL = '"+ xFilial("SFB",cSucursal)+"' AND "
	cQuery	+=	"FB_CLASSIF = '1' AND "
	cQuery	+=	"FB_CLASSE = 'P' AND "
	cQuery	+=	"D_E_L_E_T_= ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		cCpo := (cTmp)->FB_CPOLVRO
		(cTmp)->(dbskip())
	EndDo
	(cTmp)->(dbCloseArea())
	RestArea(aArea)
Return cCpo

//+----------------------------------------------------------------------+
//|Genera el archivo de texto 											 |
//+----------------------------------------------------------------------+
//|Parï¿½metros	|aArq:	Array con los datos a registrar en el archivo	 |
//|				|	de Texto.											 |
//|				|cNameFile												 |
//|				|	Nombre del archivo que s erï¿½ generado.     		|
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+

Static Function genFile(lAgrup, aArq,cFileName)
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local nK		:= 0
	Local nArqLog	:= 0
	
	Default lAgrup := .T.
	Default aArq := {}
	Default cFileName := ""

	if Len(aArq) > 0
		If File(cFileName)
			FErase(cFileName)
		EndIf
		nArqLog	:= MSfCreate(cFileName, 0)
		ProcRegua(Len(aArq))
		For nI:=1 To Len(aArq)
			IncProc(STR0012 + str(nI)) //"Procesando registros"
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

//+---------------------------------------------------------------------+
//|Muestra la pantalla de seleccion de sucursales						|
//+---------------------------------------------------------------------+

Static Function MatFilLCal(lMostratela,aListaFil,lChkUser,nOpca,nValida,lContEmp)
	Local aFilsCalc	:= {}
	Local oChkQual,lQual,oQual,cVarQ
	Local oOk       := LoadBitmap(GetResources(),"LBOK")
	Local oNo       := LoadBitmap(GetResources(),"LBNO")
	Local lIsBlind  := IsBlind()

	Local aAreaSM0	:= SM0->(GetArea())
	Local aSM0      := FWLoadSM0(.T.,,.T.)

	Default nValida	:= 0 //0=Legado Seleção Livre
	Default lMostraTela	:= .F.
	Default aListaFil	:= {{.T., cFilAnt}}
	Default lchkUser	:= .T.
	Default lContEmp 	:= .F.
	Default nOpca		:= 1

	lChkUser := !GetAPOInfo("FWFILIAL.PRW")[4] < CTOD("10/01/2013")

	aEval(aSM0,{|x| If(x[SM0_GRPEMP] == cEmpAnt .And.;
		Iif (!lContEmp ,x[SM0_EMPRESA] == FWCompany(),.T.) .And.;
		(!lChkUser .Or. x[SM0_USEROK].Or. lIsBlind) .And.;
		(x[SM0_EMPOK] .Or. lIsBlind),;
		aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
		Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM")}),;
		NIL)})

	If lMostraTela
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0017) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL //"Seleccion de Sucursales"
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi(STR0018) OF oDlg  PIXEL //"Marque las Sucursales que se consideran en el procesamiento"
		@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0019) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.)) //STR019 "Invertir seleccion"
		@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0020),OemToAnsi(STR0021),OemToAnsi(STR0022) SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL //STR020-22"Sucursal""Descripcion""CUIT"
		bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@R 99.999.999/9999-99")}}
		oQual:SetArray(aFilsCalc)
		oQual:bLine := bLine
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(MtFCalOk(@aFilsCalc,.T.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(MtFCalOk(@aFilsCalc,.F.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	RestArea(aAreaSM0)
Return aFilsCalc

//+---------------------------------------------------------------------+
//|Funcion auxiliar para la seleccion de sucursales						|
//+---------------------------------------------------------------------+

Static Function MtFClTroca(nIt,aArray,nValida,cSelCNPJIE)
	Default nIt := 0
	Default aArray := {}
	Default nValida := 0
	Default cSelCNPJIE := ""

	If nValida == 0
		aArray[nIt,1] := !aArray[nIt,1]
	Endif
Return aArray

//+---------------------------------------------------------------------+
//|Obtiene informaciï¿½n de SF3 para archivo de percepciones			|
//+---------------------------------------------------------------------+
//|Parï¿½metros	|nTipo:	Tipo de archivo a generar   					|
//|				|	1.-Percepciones Clientes							|
//|				|	2.-Percepciones Proveedores							|
//|				|aDatos													|
//|				|	Array en dï¿½nde serï¿½n almacenados los datos antes|
//|				|	de generar el txt.									| 
//|				|cCpo												   	|
//|				|	Campo configurado para obtener el valor del importe	|
//|				|	en SF3.												| 
//				|cSucursal: Codigo de la sucursal a procesar			|
//+-------------+--------------------------------------------------------+
Static function PerSF3(nTipo,aData,cCpo,cSucursal)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTempPer	:= GetNextAlias()
	Local nRegs		:= ""
	Local cCuit 	:= ""
	Local cNome 	:= ""
	Local cEspecieV	:= ""
	Local cEspecieC	:= ""
	Default nTipo := 1
	Default aData := {}
	Default cCpo := ""
	Default cSucursal := ""

	If nTipo == 1
		cEspecieV	:= "'NF','NDC','NCC','NDI','NCI' "
	ElseIf nTipo == 2
		cEspecieC  := "'NDI','NCI' "
	EndIf
	// Query para seccion datos
	cQuery 	:= 	"SELECT "
	cQuery	+=		"F3_SERIE, "
	cQuery	+=		"F3_EMISSAO, "
	cQuery	+=		"F3_NFISCAL, "
	cQuery	+=		"F3_ESPECIE, "
	cQuery	+=		"F3_LIQPROD, "
	cQuery	+=		"F3_BASIMP" + cCpo + ", "
	cQuery	+=		"F3_ALQIMP" + cCpo + ", "
	cQuery	+=		"F3_VALIMP" + cCpo + ", "
	If nTipo == 1
		cQuery	+=	"A1_CGC, A1_NOME, A1_TIPO, A1_MUN, A1_END, A1_CEP 	"
	ElseIf nTipo == 2
		cQuery 	+=	"A2_CGC, A2_NOME "
	EndIf
	cQuery 	+=	"FROM "
	cQuery	+=		RetSqlName("SF3")+ " SF3,"

	If nTipo == 1
		cQuery	+=		RetSqlName("SA1")+ " SA1 "
	ElseIf nTipo == 2
		cQuery	+=		RetSqlName("SA2")+ " SA2 "
	End IF

	cQuery	+=	"WHERE "
	cQuery	+=	"F3_FILIAL='" + xFilial("SF3",cSucursal)+ "' AND "
	cQuery  +=  "F3_VALIMP"+ cCpo +" <> 0 AND "
	If nTipo == 1
		cQuery	+=	"A1_FILIAL='" + xFilial("SA1",cSucursal)+ "' AND "
	Else
		cQuery	+=	"A2_FILIAL='" + xFilial("SA2",cSucursal)+ "' AND "
	End If

	cQuery	+=		"F3_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"F3_EMISSAO <='" + DTOS(MV_PAR02)+ "' AND "
	If nTipo == 1	// Percepciones Clientes
		cQuery	+=	"F3_TIPOMOV='V' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieV+") AND "
		cQuery	+=	"A1_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A1_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA1.D_E_L_E_T_=' ' AND "
	ElseIf nTipo == 2
		cQuery 	+= 	"F3_TIPOMOV='C' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieC+") AND "
		cQuery	+=	"A2_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A2_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA2.D_E_L_E_T_=' ' AND "

	EndIf
	cQuery	+=		"SF3.D_E_L_E_T_=' ' "
	cQuery	+=		"ORDER BY F3_EMISSAO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempPer,.T.,.T.)
	TcSetField( cTempPer, 'F3_EMISSAO', 'D', TamSX3('F3_EMISSAO')[1], 0 )

	//Obtiene el Nro. Agente de la tabla CCO
	CCO->(dbSetOrder(1))
	CCO->(MsSeek(xFilial("CCO",cSucursal)+"JU", .F.))
	cNumAgen := Chr(34)+Alltrim(CCO->CCO_NROAGE)+Chr(34)+","

	//Obtiene el codigo de la provincia de la tabla de equivalencias
	CCP->(dbSetOrder(1))
	CCP->(MsSeek(xFilial("CCP",cSucursal)+"ARPI"+"JU"))
	cProvin := Alltrim(CCP->CCP_VDESTI) + ","

	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTempPer)-> (dbgotop())
	While (cTempPer)-> (!Eof())
		nRegs++
		IncProc(STR0009 + str(nRegs)) //"Seleccionando registros..."
		// Modifica los datos del cliente (nTipo:1) / proveedor segun el Layout
		If nTipo == 1
			cCuit := Alltrim(Substr((cTempPer)->A1_CGC,0,11))+","
			cNome := Chr(34)+Alltrim(Substr((cTempPer)->A1_NOME,0,60))+Chr(34)+","
			Iif(AllTrim((cTempPer)->A1_TIPO) $ "N|S", cTipo:=Chr(34)+"N"+Chr(34)+",",cTipo:=Chr(34)+"S"+Chr(34)+",")
			cMun := Chr(34)+Alltrim(Substr((cTempPer)->A1_MUN,0,20))+Chr(34)+","
			cDomi := Chr(34)+Alltrim(Substr((cTempPer)->A1_END,0,60))+Chr(34)+","
			cCep := Chr(34)+Alltrim(Substr((cTempPer)->A1_CEP,0,10))+Chr(34)+","
		ElseIf nTipo == 2
			cCuit := Alltrim(Substr((cTempPer)->A2_CGC,0,11))+","
			cNome := Alltrim(Substr((cTempPer)->A2_NOME,0,60))+","
			Iif(AllTrim((cTempPer)->A2_TIPO) $ "N|S", cTipo:="N,",cTipo:="S,")
			cMun := Alltrim(Substr((cTempPer)->A2_MUN,0,20))+","
			cDomi := Alltrim(Substr((cTempPer)->A2_END,0,60))+","
			cCep := Alltrim(Substr((cTempPer)->A2_CEP,0,10))+","
		EndIf

		cFechaPago := DTOS((cTempPer)->F3_EMISSAO)+","
		cNumCons := "0"+","
		cAnCons := "0"+","
		cTipComp := ""
		If Alltrim((cTempPer)->F3_ESPECIE) $ "NF|NDC|NCI"
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="N".AND.At("A",(cTempPer)->F3_SERIE)==1,cTipComp:="01",.F.)
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="N".AND.At("B",(cTempPer)->F3_SERIE)==1,cTipComp:="02",.F.)
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="N".AND.At("M",(cTempPer)->F3_SERIE)==1,cTipComp:="04",.F.)
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="S".AND.At("A",(cTempPer)->F3_SERIE)==1,cTipComp:="14",.F.)
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="S".AND.At("B",(cTempPer)->F3_SERIE)==1,cTipComp:="15",.F.)
			Iif(Alltrim((cTempPer)->F3_LIQPROD)=="S".AND.At("M",(cTempPer)->F3_SERIE)==1,cTipComp:="16",.F.)
		Endif
		If Alltrim((cTempPer)->F3_ESPECIE) $ "NCC|NDI"
			Iif(At("A",(cTempPer)->F3_SERIE)==1,cTipComp:="20",.F.)
			Iif(At("B",(cTempPer)->F3_SERIE)==1,cTipComp:="21",.F.)
			Iif(At("M",(cTempPer)->F3_SERIE)==1,cTipComp:="23",.F.)
		EndIf
		cTipComp := cTipComp +  ","
		cSucComp := Substr((cTempPer)->F3_NFISCAL,0,4) + ","
		cNumComp := Substr((cTempPer)->F3_NFISCAL,5,12)+","
		cMontBas := Strtran(Alltrim(TRANSFORM((cTempPer)->&("F3_BASIMP"+cCpo),"@! 9999999999.99")),".")+","
		cAlicApl := Strtran(Alltrim(TRANSFORM((cTempPer)->&("F3_ALQIMP"+cCpo),"@! 99.99")),".")+","
		cMontPer := Strtran(Alltrim(TRANSFORM((cTempPer)->&("F3_VALIMP"+cCpo) ,"@! 99999999.99")),".")+","
		
		cCateUsu := Chr(34)+Chr(34)+","
		cNumServi := "0,"
		cEstado := ""

		AADD(aData,{cNumAgen,cCuit,cNome,cTipo,cProvin,cMun,cDomi,;
			cCep,cFechaPago,cNumCons,cAnCons,cTipComp,cSucComp,cNumComp,;
			cMontBas,cAlicApl,cMontPer,cCateUsu,cNumServi,cEstado })
		(cTempPer)-> (dbSkip())
	EndDo
	(cTempPer)-> (dbCloseArea())
	RestArea(aArea)
Return

//+---------------------------------------------------------------------+
//|Obtiene informaciï¿½n de SFE para archivo de retenciones 			|
//+---------------------------------------------------------------------+
//|Parï¿½metros	|nTipo:	Tipo de archivo a generar   					|
//|				|	1.-Retenciones Efectuadas							|
//|				|	2.-Retenciones Revertidas							|
//|				|aDatos													|
//|				|	Array en dï¿½nde serï¿½n almacenados los datos antes|
//|				|	de generar el txt.									| 
//				|cSucursal: Codigo de la sucursal a procesar			|
//+-------------+--------------------------------------------------------+


Static Function RetSFE(nTipo,aData,cSucursal)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= GetNextAlias()
	Local nRegs		:= ""
	Local cCuit := ""
	Local cNome := ""

	Default nTipo := 1
	Default aData := {}
	Default cSucursal := ""

	// Query para seleccion datos
	cQuery 	:= 		"SELECT "
	cQuery	+=		"FE_NROCERT, "
	cQuery	+=		"FE_FORNECE, "
	cQuery	+=		"FE_LOJA, "
	cQuery	+=		"FE_EMISSAO, "
	cQuery	+=		"FE_VALBASE, "
	cQuery	+=		"FE_ALIQ, "
	cQuery	+=		"FE_RETENC,"
	cQuery	+=		"FE_FILIAL,"
	cQuery	+=		"FE_ORDPAGO,"
	cQuery	+=		"FE_NFISCAL,"
	cQuery	+=		"FE_SERIE,"
	cQuery	+=		"FE_PARCELA,"
	cQuery	+=		"A2_CGC,"
	cQuery	+=		"A2_NOME,"
	cQuery	+=		"A2_TIPO,"
	cQuery	+=		"A2_NROIB "
	cQuery 	+=		"FROM "
	cQuery	+=		RetSqlName("SFE")+ " SFE,"
	cQuery	+=		RetSqlName("SA2")+ " SA2 "

	cQuery	+=		"WHERE "
	cQuery	+=		"FE_FILIAL='" 		+ xFilial("SFE",cSucursal)+ "' AND "
	cQuery	+=		"A2_FILIAL='" 		+ xFilial("SA2",cSucursal)+ "' AND "
	cQuery	+=		"FE_EMISSAO >='" 	+ DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"FE_EMISSAO <='" 	+ DTOS(MV_PAR02)+ "' AND "
	cQuery	+=		"FE_EST = '"		+ AllTrim(MV_PAR07)+"' AND "
	cQuery	+=		"FE_TIPO = 'B' AND "

	If nTipo == 1
		cQuery	+=	"FE_NROCERT <> 'NORET' AND FE_DTRETOR = '' AND FE_NRETORI = '' AND "
	EndIf
	If nTipo == 2
		cQuery	+= "FE_DTRETOR <> '' AND FE_NRETORI <> '' AND "
	EndIf

	cQuery	+=		"A2_COD =FE_FORNECE  AND "
	cQuery	+=		"A2_LOJA=FE_LOJA  AND "
	cQuery	+=		"SA2.D_E_L_E_T_=' ' AND "
	cQuery	+=		"SFE.D_E_L_E_T_=' ' "
	cQuery  +=		"ORDER BY FE_EMISSAO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TcSetField( cTmp, 'FE_EMISSAO', 'D', TamSX3('FE_EMISSAO')[1], 0 )
	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0

	//Obtiene el Nro. Agente de la tabla CCO
	CCO->(dbSetOrder(1))
	CCO->(MsSeek(xFilial("CCO",cSucursal)+"JU", .F.))
	cNumAgen := Chr(34)+Alltrim(Substr(CCO->CCO_NROAGE,0,10))+Chr(34) +","


	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0009 + str(nRegs))//"Seleccionando registros..."

		//Valida Si la retención y su reversión están dentro del mismo período seleccionado
		If (F837ValRev((cTmp)->FE_EMISSAO,(cTmp)->FE_FORNECE,;
				(cTmp)->FE_LOJA,(cTmp)->FE_NFISCAL,(cTmp)->FE_SERIE,;
				(cTmp)->FE_ORDPAGO,cSucursal) .AND. nTipo == 1) .OR. nTipo == 2

			// Modifica los datos segun el Layout
			cCuit := Alltrim(Substr((cTmp)->A2_CGC,0,11))+","
			cNome := Chr(34)+Alltrim(Substr((cTmp)->A2_NOME,0,60))+Chr(34)+","
			Iif(AllTrim((cTmp)->A2_TIPO) $ "N|S", cTipo:="N",cTipo:="S")
			cTipo  := Chr(34)+cTipo+Chr(34)+","
			cCep := Substr(Alltrim((cTmp)->FE_NROCERT),-6)+","
			cAnConst := Alltrim(Str(Year((cTmp)->FE_EMISSAO)))+","
			cFechaPago := DTOS((cTmp)->FE_EMISSAO)+","
			cValBase := Strtran(Alltrim(TRANSFORM((cTmp)->FE_VALBASE,"@! 9999999999.99")),".")+","
			cAlicApl := Strtran(Alltrim(TRANSFORM((cTmp)->FE_ALIQ,"@! 99.99")),".")+","
			cMontPer := Strtran(Alltrim(TRANSFORM((cTmp)->FE_RETENC,"@! 99999999.99")),".")+","
			cCodig := ""
			If nTipo == 1
				cCodig := "0,"
			ElseIf nTipo == 2
				cCodig := "5,"
			EndIf
			cCantiFac := "1,"
			cNumSucur := Substr(Alltrim((cTmp)->FE_FILIAL),-2)+","
			cNumIIBB := Chr(34)+Alltrim(Substr((cTmp)->A2_NROIB,0,11))+Chr(34)+","
			//EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
			cLlave :=  xFilial("SEK",cSucursal)+(cTmp)->FE_ORDPAGO+"TB"+(cTmp)->FE_SERIE+(cTmp)->FE_NFISCAL+PADR((cTmp)->FE_PARCELA, TamSX3("EK_PARCELA")[1])

			lFormPago := F837SEK(cLlave,cSucursal,(cTmp)->FE_VALBASE)
			If lFormPago
				cFormPag := "1,"
			Else
				cFormPag := "0,"
			Endif
			cPerid := Substr(DTOS((cTmp)->FE_EMISSAO),0,6)+","
			If nTipo == 1
				cPresent := "0"
			Else
				cPresent := Alltrim(Str(MV_PAR08))
			EndIf

			AADD(aData,{cNumAgen,cCuit,cNome,cTipo,cCep,cAnConst,cFechaPago,;
				cValBase,cAlicApl,cMontPer,cCodig,cCantiFac,cNumSucur,cNumIIBB,;
				cFormPag,cPerid,cPresent })
		EndIf
		(cTmp)-> (dbSkip())
	EndDo
	(cTmp)-> (dbCloseArea())
	RestArea(aArea)
Return

//+---------------------------------------------------------------------+
//|Obtiene si la retencion fue originada por una parcialidad en la OP	|
//+---------------------------------------------------------------------+
Static Function F837SEK(cLlave,cSucursal, nValBase)
	Local aArea	:= getArea()
	Local lFormPa := .F. // True = Credito; False = Contado

	Default cLlave := ""
	Default cSucursal := ""
	Default nValBase := 0

	SEK->(dbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ

	SEK->(MsSeek(cLlave))

	While SEK->(!Eof()) .AND. cLlave == SEK->(EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA)
		If SEK->EK_VALORIG == SEK->EK_VALOR
			lFormPa := .F.
		Else
			lFormPa := .T.

			If Alltrim(SEK->EK_TIPO) $ "NF|NDP" //N
				//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  NF|NDC
				nVal := Posicione("SF1",1,xFilial("SF1",cSucursal)+SEK->EK_NUM+SEK->EK_PREFIXO+SEK->EK_FORNECE+SEK->EK_LOJA, "F1_VALMERC")
			Else
				//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
				nVal := Posicione("SF2",1,xFilial("SF2",cSucursal)+SEK->EK_FORNECE+SEK->EK_LOJA+SEK->EK_NUM+SEK->EK_PREFIXO,"F2_VALMERC")
			EndIf
			If nVal == nValBase
				lFormPa := .F.
			Endif
		EndIf
		SEK->(dbSkip())
	EndDo
	RestArea(aArea)
Return lFormPa

//+---------------------------------------------------------------------+
//|Valida si la reversion de la retencion se realizo en el mismo perido |
//+---------------------------------------------------------------------+
Static Function F837ValRev(cEmis,cForn,cLoj,cNfis,cSer,cOrdP, cSucursal)
	Local aArea	:= getArea()
	Local cTabTemp := GetNextAlias()
	Local lRetorno := .T.

	Default cEmis := ""
	Default cForn := ""
	Default cLoj := ""
	Default cNfis := ""
	Default cSer := ""
	Default cOrdP := ""
	Default cSucursal := ""

	cQuery 	:= 		"SELECT "
	cQuery	+=		"FE_DTESTOR, "
	cQuery	+=		"FE_DTRETOR "
	cQuery 	+=		"FROM "
	cQuery	+=		RetSqlName("SFE")+ " SFE "
	cQuery	+=		"WHERE "
	cQuery	+=		"FE_FILIAL ='" + xFilial("SFE",cSucursal)+ "' AND "
	cQuery	+=		"FE_FORNECE ='" + Alltrim(cForn) + "' AND "
	cQuery	+=		"FE_LOJA ='" + Alltrim(cLoj) + "' AND "
	cQuery	+=		"FE_NFISCAL ='" + Alltrim(cNfis) + "' AND "
	cQuery	+=		"FE_SERIE ='" + Alltrim(cSer) + "' AND "
	cQuery	+=		"FE_ORDPAGO ='" + Alltrim(cOrdP) + "' AND "
	cQuery	+=		"FE_DTESTOR <> '' AND "
	cQuery	+=		"FE_VALBASE < 0 AND "

	cQuery	+=		"SFE.D_E_L_E_T_=' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)

	While (cTabTemp)->(!Eof())
		If SUBSTR((cTabTemp)->FE_DTESTOR,0,6) == SUBSTR((cTabTemp)->FE_DTRETOR,0,6)
			lRetorno := .F.
		EndIF
		(cTabTemp)->(dbSkip())
	EndDo
	(cTabTemp)-> (dbCloseArea())
	RestArea(aArea)
Return lRetorno
