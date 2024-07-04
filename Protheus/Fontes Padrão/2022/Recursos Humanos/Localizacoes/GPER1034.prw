#Include "PROTHEUS.CH" 
#Include "GPER1034.CH"
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออออออออออออออหอออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บ GPER1034 บ Autor บ Laura Medina                  บ Fecha บ  08/12/2021  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออออออออออออสอออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บLRE: libro de Remuneraci๓n Electr๓nica - Chile                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGAGPE                                                                 บฑฑ
ฑฑฬออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  บฑฑ
ฑฑฬออออออออออออออออหออออออออออออหออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Programador   บ    Data    บ   Issue    บ  Motivo da Alteracao                    บฑฑ
ฑฑฬออออออออออออออออลออออออออออออลออออออออออออลอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                บ            บ            บ                                         บฑฑ
ฑฑศออออออออออออออออสออออออออออออสออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER1034()
	
Local oFld		 := Nil

Private cProceso := ""
Private cProced  := ""
Private cPeriodo := ""
Private cNroPago := "01"
Private cRangSuc := ""
Private cRutaArc := ""
Private cPictVl8 := "@E 99999999"
Private nArchTXT := 0
Private lGenCSV  := .F.
Private aCatego	 := {}
Private cPerg	 := "GPER1034"
Private nCCAF	 := 0
Private nMUTUAL	 := 0
Private cIMPTOR	 := ""
Private cDelimi	 := ";"
Private cLinea	 := ""
Private cAliasAux:= ""
Private cPrefixo := ""
Private lerMsg	 := .T.

Pergunte( cPerg, .F. )

	DEFINE MSDIALOG oDlg TITLE STR0015 FROM 0,0 TO 250,450 OF oDlg PIXEL //"LRE"
	
	@ 020,010 FOLDER oFld OF oDlg PROMPT STR0001 PIXEL SIZE 155,075 	//"Libro de Remuneraci๓n Electr๓nico" 
	//+----------------
	//| Campos Folder 
	//+----------------
	@ 005,005 SAY STR0002 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la generaci๓n del Libro de remuneraci๓n "
	@ 015,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"electr๓nico en formato .CSV, informe los parแmetros. "" 

	@ 022,180 BUTTON STR0010 SIZE 036,016 PIXEL ACTION GetParam() //"Parametros"
	@ 050,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION (IIf(ArchLRE(),oDlg:End(),) ) //"Aceptar"
	@ 078,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End() //"Salir"

	ACTIVATE MSDIALOG oDlg CENTER
	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณForm1357    บAutor  ณLaura Media       บFecha ณ  19/03/2020  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el formulario 1357.                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetParam()

If  !Pergunte(cPerg,.T. )
	Return .T. 
Endif


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArchLRE   บAutor  ณLaura Medina         บFecha ณ  09/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el Archivo LRE.                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ArchLRE()
Local lRet		:= .T.
	
	MakeSqlExpr(cPerg)
	cProceso:= MV_PAR01
	cProced := MV_PAR02
	cPeriodo:= MV_PAR03
	cRangSuc:= MV_PAR04
	cRutaArc:= Alltrim(MV_PAR05)	

	aCatego := cargaTabla("S019")
	
	If  !Empty(aCatego)
		If  lExisCpos()
			Processa({ || ProcLRE() })
		Else
			Aviso(OemToAnsi(STR0007), OemToAnsi(STR0004), {STR0009} ) //"No se tienen todos los campos necesarios, verifique la documentaci๓n."
			Return .T. 
		Endif
	Else
		Aviso(OemToAnsi(STR0007), OemToAnsi(STR0013), {STR0009} ) //"No se encontr๓ informaci๓n en la tabla alfanum้rica S019."
		Return .T. 
	Endif
	
	If  lGenCSV 
		Aviso( OemToAnsi(STR0007), OemToAnsi(STR0016), {STR0009} ) //"Archivo generado con ้xito!."
	ElseIf lerMsg
		Aviso(OemToAnsi(STR0007), OemToAnsi(STR0017), {STR0009} ) //"No se encontr๓ informaci๓n para generar el Libro de Remuneraci๓n Electr๓nico."
	Endif
	FCLOSE(nArchTXT)

	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcLRE    บAutor  ณLaura Medina        บFecha ณ  09/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n para obtener los datos de SRD, solo aplica para     บฑฑ
ฑฑบ          ณ periodos cerrados.                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLRE()
Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local lProcesa  := .T.
Local a2Haberes := Array(49)
Local a3Desctos := Array(37)
Local a4Aportes := Array(6)
Local a5Totales := Array(15)
Local nLoop     := 0
Local nRegs     := 0
Local nPos2		:= 0
Local nCounReg1 := 0
Local nContCat2	:= 0
Local n5201		:= 0
Local n21XX		:= 0
Local n22XX		:= 0
Local n23XX		:= 0
Local n24XX		:= 0
Local n31XX		:= 0
Local n41XX		:= 0
Local c07_5361	:= ""  //5361
Local c09_5341	:= ""  //5341
Local c13_5502	:= ""  //5502
Local c14_5564	:= ""  //5564
Local c15_5565	:= ""  //5565

Private dIniPer	:= CTOD("//")
Private dFinPer	:= CTOD("//")

cAliasAux   := "SRD"
cPrefixo    := "RD_"	
 
dIniPer :=  FirstDay(CTOD("01/"+ substr(cPeriodo,5,2) + "/" + substr(cPeriodo,1,4)))
dFinPer :=  LastDay(CTOD("01/"+ substr(cPeriodo,5,2) + "/" + substr(cPeriodo,1,4)))		

cQuery 	:= 	"SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_DEMISSA, RA_ADMISSA, RA_TIPOAFA, RA_TPOTRAB, RA_AFP, RA_OBRASOC, RA_SEGCESA, RA_LOCAL, RA_CENTRAB, " 
cQuery	+=	"RA_DESTRAB, RA_TPSBCOM, RA_TJRNDA, RA_TPPREVI, RA_TIPINF, RA_TPJORNA, RA_VALINF, RA_TPDEFFI, RA_TRAMFAM, RA_SINDICA, RA_REGIME, SUM("+cPrefixo+"VALOR) RD_VALOR "
cQuery	+=	"FROM "
cQuery	+=	RetSqlName("SRA") + " SRA,  "	
cQuery  +=	RetSqlName(cAliasAux) +" "+ cAliasAux + " " 
cQuery  += 	"WHERE SRA.D_E_L_E_T_= ' ' AND "
cQuery  +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
If  !Empty(cRangSuc)
	cQuery  += cRangSuc +  "  AND "
Else
	cQuery  += 		"SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND "
Endif
cQuery  += 		cAliasAux+"."+cPrefixo+"FILIAL = RA_FILIAL   AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"MAT    = RA_MAT  AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
//cQuery += 		cAliasAux+"."+cPrefixo+"SEMANA	= '" +  cNroPago+ "'  AND "
cQuery  +=		"((RA_SITFOLH <> 'D') OR (RA_SITFOLH = 'D' AND RA_DEMISSA BETWEEN '" + DTOS(dIniPer) +"'AND '" + DTOS(dFinPer)  +"' ) OR (RA_SITFOLH = 'D' AND RA_DEMISSA > '" + DTOS(dFinPer)  +"') )" 
cQuery  +=	"GROUP BY RA_FILIAL, RA_MAT, RA_CIC, RA_DEMISSA, RA_ADMISSA, RA_TIPOAFA, RA_TPOTRAB, RA_AFP, RA_OBRASOC, RA_SEGCESA , RA_LOCAL, RA_CENTRAB, "
cQuery  +=	"RA_DESTRAB, RA_TPSBCOM, RA_TJRNDA, RA_TPPREVI, RA_TIPINF, RA_TPJORNA, RA_VALINF, RA_TPDEFFI, RA_TRAMFAM, RA_SINDICA, RA_REGIME "
cQuery  +=	"ORDER BY RA_FILIAL, RA_MAT"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
TcSetField(cTmp, "RA_ADMISSA", "D", 08, 0)
TcSetField(cTmp, "RA_DEMISSA", "D", 08, 0)

Count to nRegs

ProcRegua(nRegs)
(cTmp)->(dbGoTop())

If  nRegs > 0 //Archivo LRE
	If  !GenArch()  //Crea el archivo.
		lProcesa := .F. 
	Endif
Else
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0011), {STR0009} ) //"Periodo invalido, informe un periodo cerrado o no existen registros en la tabla Hist๓rico de movimientos de n๓mina (SRD) para ese periodo."
	(cTmp)->(dbCloseArea())	
	lerMsg := .F.  //No envie 2 mensajes exponiendo casi lo mismo.
	Return 
Endif

If  lProcesa
	CCAFyMutal(@nCCAF,@nMutual)  //Obtener RA_CCAF y RA_MUTUAL
Endif

While (cTmp)-> (!Eof()) .And. lProcesa
	IncProc(STR0012 + STR0014) //"Generando " "LRE... " "Libro Remuneraci๓n Electr๓nico... "
	
	If  abs((cTmp)->RD_VALOR) > 0  //Solo son procesados los empleado tiene alg๚n registro con valor mayor a 0

		nCounReg1 ++
		
		//2.HABERES: 49
		For nloop := 1 to Len(a2Haberes)
			If (nPos2:= aScan(aCatego, {|x| x[2] == 2 .And. x[3] == nloop}) )> 0
				a2Haberes[nloop]:= ObtMov("V",aCatego[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1)
				If  Substr(aCatego[nPos2,5],1,2) == "21"   //Suma todos los conceptos que su Cod LRE inicie con 21xx
					n21XX += val(Transform(Round(a2Haberes[nloop],TamSX3("RD_VALOR")[2]), cPictVl8))  
				ElseIf  Substr(aCatego[nPos2,5],1,2) == "22"   //Suma todos los conceptos donde Cod LRE inicie con 22xx
					n22XX += val(Transform(Round(a2Haberes[nloop],TamSX3("RD_VALOR")[2]), cPictVl8))   
				ElseIf  Substr(aCatego[nPos2,5],1,2) == "23"   //Suma todos los conceptos donde Cod LRE inicie con 23xx
					n23XX += val(Transform(Round(a2Haberes[nloop],TamSX3("RD_VALOR")[2]), cPictVl8))  
				ElseIf  Substr(aCatego[nPos2,5],1,2) == "24"   //Suma todos los conceptos donde Cod LRE inicie con 24xx
					n24XX += val(Transform(Round(a2Haberes[nloop],TamSX3("RD_VALOR")[2]), cPictVl8))   
				Endif
			Else
				a2Haberes[nloop]:= 0
			Endif
		Next
		
		//3.DESCUENTOS: 37
		For nloop := 1 to Len(a3Desctos)
			If (nPos2:= aScan(aCatego, {|x| x[2] == 3 .And. x[3] == nloop}) )> 0
				a3Desctos[nloop]:= ObtMov("V",aCatego[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1)
				If  Substr(aCatego[nPos2,5],1,2) == "31"   //Suma todos los conceptos que su Cod LRE inicie con 31xx
					n31XX += val(Transform(Round(a3Desctos[nloop],TamSX3("RD_VALOR")[2]), cPictVl8))  
				Endif
			Else
				a3Desctos[nloop]:= 0
			Endif
		Next
		
		//4.APORTES: 6
		For nloop := 1 to Len(a4Aportes)
			If (nPos2:= aScan(aCatego, {|x| x[2] == 4 .And. x[3] == nloop}) )> 0
				a4Aportes[nloop]:= ObtMov("V",aCatego[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1)
				If  Substr(aCatego[nPos2,5],1,2) == "41"   //Suma todos los conceptos que su Cod LRE inicie con 41xx
					n41XX += val(Transform(Round(a4Aportes[nloop],TamSX3("RD_VALOR")[2]), cPictVl8)) 
				Endif
			Else
				a4Aportes[nloop]:= 0
			Endif
		Next
		
		If  nCounReg1 == 1 //Solo 1vez obtener el concepto que corresponde.
			c07_5361	:= "'3161','3165'"  //5361
			c09_5341	:= "'3141','3143','3144','3145','3146','3151','3154','3155','3156','3157','3158'"  //5341
			c13_5502	:= "'2313','2314','2315','2316','2331','2417','2418'"  //5502
			c14_5564	:= "'2417','2418'"  //5564
			c15_5565	:= "'2313','2314','2315','2316','2331'"  //5565	 
		Endif
		
		//5.TOTALES: 15
		For nloop := 2 to Len(a5Totales) 
			If (nPos2:= aScan(aCatego, {|x| x[2] == 5 .And. x[3] == nloop}) )> 0
				If  nloop == 2 .OR. nloop == 3 .OR. nloop == 4 .OR. nloop == 5
					If  nloop == 2
						a5Totales[nloop]:= n21XX
					ElseIf nloop == 3 
						a5Totales[nloop]:= n22XX
					ElseIf	nloop == 4 
						a5Totales[nloop]:= n23XX
					ElseIf  nloop == 5
						a5Totales[nloop]:= n24XX							
					Endif
					n5201 += a5Totales[nloop]	
				Elseif nloop == 6 
					a5Totales[nloop]:= n31XX
				ElseIf nloop == 11 
					a5Totales[nloop]:= n41XX
				Elseif nloop == 7 .Or. nloop == 14
					a5Totales[nloop]:= ObtMov("V","", cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 2, IIf(nloop == 7, c07_5361, c14_5564 )) 				
				Elseif nloop == 8
					a5Totales[nloop]:= ObtMov("V",'3162', cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 1, "")
				Elseif nloop == 9
					a5Totales[nloop]:= ObtMov("V","", cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 2, c09_5341)
				Elseif nloop == 10
					a5Totales[nloop]:= a5Totales[6] - (a5Totales[7] + a5Totales[8] + a5Totales[9])
				Elseif nloop == 13 .Or. nloop == 15
					a5Totales[nloop]:= ObtMov("V", "", cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 2, IIf(nloop == 13, c13_5502, c15_5565 )) 
				Endif						
			Else
				a5Totales[nloop]:= 0
			Endif
		Next
		If  Len(a5Totales) > 0
			a5Totales[1] := n5201
			a5Totales[12]:= a5Totales[1] - a5Totales[6] 
		Endif	
		
		//Archivo LRE 
		If  nCounReg1 == 1 //Solo se imprime una vez el encabezado
			GrabaHead()    //144 Headers
		Endif
		GrabaCat01( (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, (cTmp)->RA_CIC, (cTmp)->RA_ADMISSA, (cTmp)->RA_DEMISSA, (cTmp)->RA_TIPOAFA, (cTmp)->RA_LOCAL, ;
 			(cTmp)->RA_CENTRAB, (cTmp)->RA_TIPINF, (cTmp)->RA_TPJORNA, (cTmp)->RA_TPDEFFI, (cTmp)->RA_TPOTRAB, (cTmp)->RA_AFP, (cTmp)->RA_OBRASOC, ;
 			(cTmp)->RA_SEGCESA, (cTmp)->RA_TRAMFAM, (cTmp)->RA_SINDICA,(cTmp)->RA_TPSBCOM, (cTmp)->RA_TJRNDA, (cTmp)->RA_DESTRAB, (cTmp)->RA_TPPREVI, ; 
 			(cTmp)->RA_VALINF, (cTmp)->RA_REGIME  )   //45 campos
		GrabaCatXX(a2Haberes,2) //48 campos
		GrabaCatXX(a3Desctos,3) //35 campos
		GrabaCatXX(a4Aportes,4) //6  campos
		GrabaCatXX(a5Totales,5) //15 campos
		lGenCSV := .T. 		

		a2Haberes := Array(49)
		a3Desctos := Array(37)
		a4Aportes := Array(6)
		a5Totales := Array(15)		
		nContCat2 := 0
		n5201 	  := 0
		cLinea	  := ""
		n21XX	  := 0
		n22XX	  := 0
		n23XX	  := 0
		n24XX	  := 0
		n31XX	  := 0
		n41XX	  := 0
	Endif	
	(cTmp)->(DbSkip())	
EndDo
(cTmp)->(dbCloseArea())	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGenArch   บAutor  ณLaura Medina         บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Generar archivo y registro 01                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GenArch()
Local lRet   	:= .T.
Local cNomArch	:= "LRE_"+StrZero(Day(dDataBase),2)+ StrZero(Month(dDataBase),2)+ Str(Year(dDataBase),4)+"_"+SubStr(Time(),1,2) + SubStr(Time(),4,2) + ".CSV"  
Local cDrive	:= ""
Local cDir      := ""
Local cExt      := ""
Local cNewFile	:= ""

IIf (!(Substr(cNomArch,Len(cNomArch) - 2, 3) $ "csv|CSV"), cNomArch += ".CSV", "")

cNewFile := cRutaArc + cNomArch

SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
cDir 	 := cDrive + cDir

Makedir(cDir,,.F.) //Crea el directorio en caso de no existir

cNewFile := cDir + cNomArch + cExt   
nArchTXT := FCreate (cNewFile,0)

If  nArchTXT == -1
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0008 + cNomArch), {STR0009} ) //"Atencion" - "No se pudo crear el archivo " - "OK"
	lRet   := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaHead  บAutor  ณLaura Medina        บFecha ณ  12/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunci๓n que graba todo el encabezado del archivo (144 campos)บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: GrabaHead                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaHead() 
Local cHeader	:= ""
Local nLoop		:= 0

For nLoop := 1 To Len(aCatego)
	cHeader += Alltrim(aCatego[nLoop,4])
	
	If  nLoop < Len(aCatego)
		cHeader += cDelimi
	Endif
Next nLoop

FWrite(nArchTXT, cHeader)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaCat01 บAutor  ณLaura Medina        บFecha ณ  14/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLibro LRE | Categorํa 01 - Conceptos|                        บฑฑ
ฑฑบ          ณLa primer categorํa a ser impresa es la de Conceptos con una บฑฑ
ฑฑบ          ณlongitud de 40 (cuarenta) caracteres.                        บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaCat01(cFilMov, cMatMov, cCIC, dAdmissa, dDemissa, cTipoAfa, cLocal, cCentrab, cTipInf, cTpJorn, cTpDeffi, cTpoTrab, ;
						   cAFP, cObraSoc, cSegCesa, cTramFam, cSindica, cTpsbcom, cTjrnda, cDestrab, cTpPrevi, nValInf, cRegime ) 
//Longitud de 40 caracteres
Local cAhIndiv := "0"
Local cAhColec := "0"
Local cRCOAfp  := ""
Local cRCOIPS  := ""
Local cPension := "1"
Local cSalud   := "2"
Local cRCOSal  := ""

If  ObtMov("V",'3155', cAliasAux, cPrefixo,cFilMov,cMatMov,1) > 0 .Or. ;
	ObtMov("V",'3156', cAliasAux, cPrefixo,cFilMov,cMatMov,1) > 0 
	cAhIndiv := "1"	
Endif

If  ObtMov("V",'3157', cAliasAux, cPrefixo,cFilMov,cMatMov,1) > 0 .Or. ;
	ObtMov("V",'3158', cAliasAux, cPrefixo,cFilMov,cMatMov,1) > 0 
	cAhColec := "1"	
Endif

If  cRegime=='1'
	cRCOAfp := POSICIONE("RCO",4,xFilial("RCO")+cPension+cAFP,"RCO_LRE") //RCO_FILIAL+RCO_ATIVID+RCO_CODIGO 
	cRCOAfp := val(Iif(!Empty(cRCOAfp),cRCOAfp, "100")) 
	cRCOIPS := "0" 
Elseif cRegime=='2'
	cRCOIPS := POSICIONE("RCO",4,xFilial("RCO")+cPension+cAFP,"RCO_LRE") //RCO_FILIAL+RCO_ATIVID+RCO_CODIGO 
	cRCOIPS := val(Iif(!Empty(cRCOIPS),cRCOIPS, "0")) 
	cRCOAfp := "100"
Else
	cRCOIPS := "0"
	cRCOAfp := "100"
Endif

cCIC   		:= PADL(cCIC, 9, "0")
cRCOSal		:= POSICIONE("RCO",4,xFilial("RCO")+cSalud+cObraSoc,"RCO_LRE")
cRCOSal		:= IIf(!Empty(cRCOSal),Alltrim(Str(Val(cRCOSal))),"")

cLinea := CRLF
cLinea += Substr(cCIC,1,8) + "-" + Substr(cCIC,9,1) + cDelimi  //
cLinea += DTOC(dAdmissa) + cDelimi
cLinea += Iif(!Empty(dDemissa) .And. (dDemissa >= dIniPer .And. dDemissa <= dFinPer ), DTOC(dDemissa), space(10)) + cDelimi 
cLinea += PADL(Alltrim(cTipoAfa), 2, " ") + cDelimicLinea += PADL(Iif(Alltrim(cLocal)$ "EX|RM","",cLocal) , 2, " ") + cDelimi              
cLinea += PADL(Alltrim(Str(Val(cCentrab))), 5 , " ") + cDelimi
cLinea += PADL(cIMPTOR, 1, " ") + cDelimi
cLinea += PADL(cTipInf, 1, " ") + cDelimi
cLinea += PADL(cTpJorn, 3, " ") + cDelimi
cLinea += PADL(cTpDeffi, 1, " ") + cDelimi
cLinea += PADL(Iif(cTpoTrab <> "0","1",cTpoTrab), 1, " ") + cDelimi
cLinea += PADL(cRCOAfp, 3, " " ) + cDelimi
cLinea += PADL(cRCOIPS, 3, " " ) + cDelimi
cLinea += PADL(cRCOSal, 3, " " ) + cDelimi
cLinea += PADL(Iif(cSegCesa =="2","0","1"), 1, " ") + cDelimi
cLinea += PADL(Alltrim(Str(nCCAF)), 1 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(nMutual)), 2 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(ObtCargas("1",cFilMov, cMatMov))), 2 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(ObtCargas("2",cFilMov, cMatMov))), 2 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(ObtCargas("3",cFilMov, cMatMov))), 2 , " ") + cDelimi
cLinea += PADL(cTramFam, 1, " ") + cDelimi
cLinea += PADL(POSICIONE("RCE",1,xFilial("RCE")+cSindica,"RCE_CGC"), 10, " ") + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += SPACE(10) + cDelimi
cLinea += PADL(Alltrim(Str(ObtMov("H","", cAliasAux, cPrefixo, cFilMov, cMatMov, 3, "'044'" ))), 2 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(ObtMov("H","", cAliasAux, cPrefixo, cFilMov, cMatMov, 3, "'001','005'"))), 2 , " ") + cDelimi
cLinea += PADL(Alltrim(Str(ObtMov("H","", cAliasAux, cPrefixo, cFilMov, cMatMov, 3, "'017'" ))), 2 , " ") + cDelimi
cLinea += PADL(cTpsbcom, 1, " ") + cDelimi
cLinea += PADL(Iif(cTjrnda == "1",cDestrab,""), 1, " ") + cDelimi
cLinea += cAhIndiv + cDelimi
cLinea += cAhColec + cDelimi
cLinea += PADL(cTpPrevi, 1, " ") + cDelimi
cLinea += PADL(Iif(nValInf> 0 ,Replace(Alltrim(str(nValInf)), ',', '.'),""), 4, " ") + cDelimi

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaCatXX บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Archivo 1357 | Registro 03, 04 Y 05 |                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑบParametrosณ aRegistroX:= Arreglo con los movimientos (RC/RD_VALOR).     บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaCatXX(aRegistroX,nReg)
Local nLoop	   := 0 
Local cValorXX := ""

For nLoop := 1 To Len(aRegistroX)
	If  (nReg==2 .And. nLoop == 1) .Or. (nReg==3 .And. (nLoop == 1 .Or. nLoop == 2 .Or. nLoop == 11))  .Or. ;
		(nReg==4 .And. (nLoop == 2 .Or. nLoop == 5))  .Or. (nReg==5 .And. (nLoop <> 8  .And. nLoop <> 13 ) ) //Campos obligatorios - ceros
		cValorXX := Transform(Round(aRegistroX[nLoop],TamSX3("RD_VALOR")[2]), cPictVl8)	
	Else    //Campos Opcionales - vacios 
		cValorXX := Iif(aRegistroX[nLoop] == 0, "", Transform(Round(aRegistroX[nLoop],TamSX3("RD_VALOR")[2]), cPictVl8)	)
	Endif
	cLinea += PADL(cValorXX, 8, " ") 
	//Susbtr(Substr(cValorXX, 1, AT(".",cValorXX)-1 ), 1, AT(",",cValorXX)-1)
	If  !(nLoop == Len(aRegistroX) .And. nReg == 5)
		cLinea += cDelimi 
	Endif
Next

If  nReg == 5  //Solo imprime cuando sean los totales
	FWrite(nArchTXT, cLinea)
	cLinea := ""
Endif

		
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtMov     บAutor  ณLaura Medina        บFecha ณ  11/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener movimientos para el concepto.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtMov(cHrsVlr,cCodLRE, cAliasAux, cPrefixo, cFilMov, cMatMov, nOpc, cInConc)
Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local nRenumera := 0

Default cCodLRE	:= ""
Default cAliasAux:="SRD"
Default cPrefixo:= "RD_" 
Default cFilMov := ""
Default cMatMov	:= ""
Default nOpc	:= 1
Default cInConc := ""

If 	cHrsVlr == "V"
	cQuery := 	"SELECT SUM("+cPrefixo+"VALOR) "+cPrefixo+"VALOR "
Else
	cQuery := 	"SELECT SUM("+cPrefixo+"HORAS) "+cPrefixo+"HORAS "
Endif
cQuery +=	"FROM "
cQuery +=	RetSqlName(cAliasAux) +" "+ cAliasAux + ", "  +RetSqlName("SRV")+ " SRV " 
cQuery += 	"WHERE "+ cAliasAux+"."+cPrefixo+"MAT = '" +cMatMov + "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"FILIAL	= '" +  cFilMov+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PD = SRV.RV_COD AND "
//RV_CODLRE 1101, 1102,...5565
If  nOpc ==1
	cQuery += 		"SRV.RV_CODLRE = '" + cCodLRE  + "'  AND "
Elseif nOpc == 2   //Sumariza varios conceptos - IN
	cQuery += 		"SRV.RV_CODLRE IN (" + cInConc  + ")  AND "
Elseif nOpc== 3
	cQuery += 		"SRV.RV_COD IN (" + cInConc  + ")  AND "
Endif
cQuery +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.RV_FILIAL = '" + xFilial("SRV")+ "' ""
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

If (cTmp)-> (!Eof())
	If 	cHrsVlr == "V"
		nRenumera := (cTmp)->&((cPrefixo)+"VALOR")	
	Else
		nRenumera := (cTmp)->&((cPrefixo)+"HORAS")	
	Endif
Endif
(cTmp)->(dbCloseArea())	

Return nRenumera



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcargaTabla บAutor  ณLaura Medina        บFecha ณ  10/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener los IDs de las 5 categorias.                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cargaTabla(cTabla)
Local aTablaS019:= {}
Local aArea	 	:= GetArea()
Local nSecuen	:= 0
Local cTemp		:= "1"
Local cCodS019	:= ""

Default cTabla 	 := ""


DbSelectArea("RCC")    
RCC->(dbSetOrder(1)) //"RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"

If  RCC->(MsSeek(xFilial("RCC") + cTabla ))
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC") + cTabla
			If  cTemp == Substr(RCC->RCC_CONTEU,1,1)
				nSecuen ++
			Else
				nSecuen := 1
			Endif
			cCodS019 := Substr(RCC->RCC_CONTEU,1,4) //2101
			aAdd(aTablaS019, {cCodS019,;   //2101
							Val(Substr(RCC->RCC_CONTEU,1,1)),; // 2
							nSecuen,; // secuencia
							Alltrim(Substr(RCC->RCC_CONTEU,6))+Iif(cCodS019 $ "2161|3166|3167|", " (","(") +Alltrim(cCodS019)+")",;  //RUT (1101)
							cCodS019 } ) //2101
			cTemp := Substr(RCC->RCC_CONTEU,1,1)
	RCC->(dbSkip())	
	EndDo
Endif

RestArea(aArea)
Return aTablaS019


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCCAFyMutal บAutor  ณLaura Medina        บFecha ณ  12/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener el RCJ_CCAF y RCJ_MUTUAL.                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CCAFyMutal(nCCAF, nMutual)
Local aArea		:= GetArea()

DbSelectArea("RCJ")    
RCJ->(dbSetOrder(1)) //"RCJ_FILIAL+RCJ_CODIGO"

If  RCJ->(MsSeek(xFilial("RCJ") + cProceso ))
	nCCAF	:= Val(RCJ_CCAF)
	nMutual	:= Val(RCJ_MUTUAL)
	cIMPTOR	:= RCJ_IMPTOR
Endif

RestArea(aArea)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlExisCpos บAutor  ณLaura Medina        บFecha ณ  14/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Se verifica que existan todos los campos nuevo que son usa- บฑฑ
ฑฑบ          ณ dos en el LRE.                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lExisCpos()
Local aArea		:= GetArea()
Local lRet := .F.

If  SRA->(ColumnPos("RA_LOCAL")) > 0  .And. SRA->(ColumnPos("RA_CENTRAB")) > 0  .And. SRA->(ColumnPos("RA_DESTRAB")) > 0 .And. ;
 	SRA->(ColumnPos("RA_TPSBCOM")) > 0  .And. SRA->(ColumnPos("RA_TJRNDA")) > 0  .And. SRA->(ColumnPos("RA_TPPREVI")) > 0 .And. ;
	SRA->(ColumnPos("RA_TIPINF")) > 0  .And. SRA->(ColumnPos("RA_TPJORNA")) > 0  .And. SRA->(ColumnPos("RA_VALINF")) > 0 .And. ;
	RCJ->(ColumnPos("RCJ_IMPTOR")) > 0  .And. SRV->(ColumnPos("RV_CODLRE")) > 0 .And.  RCO->(ColumnPos("RCO_LRE")) > 0
	lRet := .T.	
Endif


RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtCargas  บAutor  ณLaura Medina        บFecha ณ  14/12/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener cargas familiares.                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo LRE                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtCargas(cTipoCar,cFilMov, cMatMov)
Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local nCargas	:= 0
Local nRegs		:= 0

Default cTipoCar	:= ""

cQuery := 	"SELECT RB_NOME "
cQuery +=	"FROM "
cQuery +=	RetSqlName("SRB")+ " SRB " 
cQuery += 	"WHERE  SRB.RB_MAT  = '" +cMatMov + "'  AND "
cQuery += 		"SRB.RB_FILIAL	= '" + cFilMov+ "'  AND "
// "1" - Simple, "2" - Maternal y "3" - Invalidez
cQuery += 		"SRB.RB_TPOCAR = '" + cTipoCar  + "'  AND "
cQuery +=		"SRB.D_E_L_E_T_= ' '  "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

Count to nRegs

If  nRegs > 0 //Archivo LRE
	nCargas := nRegs
Endif

(cTmp)->(dbCloseArea())

Return nCargas
