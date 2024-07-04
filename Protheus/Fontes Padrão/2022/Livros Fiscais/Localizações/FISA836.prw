#INCLUDE "Totvs.CH"
#INCLUDE "FISA836.CH"

/*/
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
/*/
Function FISA836()
	Local aArea		:= getArea()
	Local oFld		:= Nil
    Local lAutomato 	:= IsBlind()
	Private _lRegs	:= .F.
	Private oDlg	:= Nil
	Private oDialog := Nil

	If !lAutomato
		DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"RG 001-12 - Posadas - Percepciones"

		@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Exportacion de TXT"

		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la exportacion de un TXT con las "
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepciones de impuestos municipales de Posadas."
		@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"RG 001-12 – Municipalidad de Posadas"
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
		@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDialog:End() 		//"&Sair"
		ACTIVATE MSDIALOG oDialog CENTER
	Else
		RunProc()
	EndIf
	
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
	Local cFileNameTxt 	:= ""
	Local aSucsCalc := {}
	Local cSucursal := ""
	Local nSucus:= 0
	Local cCGC := ""
	Local cNomenc := ""
	Local nI := 0
	Local nPosi := 0
	Local aRepetidos := {}
	Local aArea := getArea() 
	Local nOpEx         := 0
	Local lAutomato 	:= IsBlind()
	Local lProc			:= .F.

	If lAutomato
		lProc := .T.
	Else
		lProc := Pergunte("FISA836",.T.)
	EndIf

	If lProc
		If ValidParam()
			cFileNameTxt 	:=RTRIM(MV_PAR04)
			If MV_PAR05 == 1
				aSucsCalc := MatFilLCal(MV_PAR05 == 1,,,,)
				Restarea(aArea)
				If Empty(aSucsCalc)
					Return
				EndIf
				If MV_PAR06 == 1 //Agrupa todos los registros
					aDatosA := {}
					nOmit := 0
					For nSucus := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSucus,1])
							aDatos := {}
							nOpEx := 0
							cCGC := RIGHT(AllTrim(aSucsCalc[nSucus,4]),11)
							cSucursal := aSucsCalc[nSucus,2]
							nPoSCuit := aScan(aDatosA,{|x| Substr(x[1][2],1,11) $ cCGC })  //Busca cuit para agrupar
							If nPoSCuit == 0								
								cNomenc := aSucsCalc[nSucus,3]
								cNomenc := STRTRAN(Alltrim(cNomenc),";")
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
								Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
									Alltrim(cCGC)+";",;
									Alltrim(cNomenc)+";",;
									SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
									"PERCEPCION;",";" })									
								nOpEx := 0								
							Else
								nOpEx := Val(aDatosA[nPoSCuit][1][6])
							EndIf
							Processa( {|| GenArqPer(@aDatos,cSucursal,@nOpEx)}, STR0011,STR0009, .T. )
							If nPoSCuit == 0
								Aadd(aDatosA, aDatos)
								aDatosA[Len(aDatosA)][1][6] := Alltrim(Str(nOpEx))
								nOmit+=nOmit
							Else
								AEval( aDatos,  { | x | AAdd( aDatosA[nPoSCuit], x ) } )
								aDatosA[nPoSCuit][1][6] := Alltrim(Str(nOpEx))
							EndIf
						EndIf
					Next

					For nI := 1 To Len(aDatosA)
						Processa( {|| genFile(.F.,aDatosA[nI],cFileNameTxt+".txt")}	, STR0011,STR0010, .T. )
					Next
				ElseIf MV_PAR06 == 2
					For nSucus := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSucus,1])
							//De termina las sucursales con el mismo cuit
								cSucursal := aSucsCalc[nSucus,2]
								cCGC := AllTrim(aSucsCalc[nSucus,4])
								cNomenc := aSucsCalc[nSucus,3]
								cNomenc := STRTRAN(Alltrim(cNomenc),";")
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
								cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
								aDatos := {}
								Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
									RIGHT(cCGC,11)+";",;
									Alltrim(RIGHT(cNomenc,255))+";",;
									SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
									"PERCEPCION;",";" })
								nOmit := 0
								Processa( {|| GenArqPer(@aDatos,cSucursal,@nOmit)}, STR0011,STR0009, .T. )
								aDatos[1][6] := Alltrim(Str(nOmit))
								Processa( {|| genFile(.F.,aDatos, cFileNameTxt+" "+cSucursal+".txt")}	, STR0011,STR0010, .T. )
						EndIf
					Next
				EndIf
			ElseIf MV_PAR05 == 2 //Toma la sucursal en curso
				cCGC := AllTrim(SM0->M0_CGC)
				cNomenc := SM0->M0_NOMECOM
				cNomenc := STRTRAN(Alltrim(cNomenc),";")
				cNomenc := STRTRAN(Alltrim(cNomenc),Chr(34))
				cNomenc := STRTRAN(Alltrim(cNomenc),Chr(39))
				aDatos := {}
				Aadd(aDatos,{ AllTrim(MV_PAR03)+";",;
					Alltrim(cCGC)+";",;
					Alltrim(cNomenc)+";",;
					SUBSTR(Alltrim(Dtoc(MV_PAR01)),4)+";",;
					"PERCEPCION;",";" })
				nOmit := 0
				Processa( {|| GenArqPer(@aDatos,cFilAnt,@nOmit)}, STR0011,STR0009, .T. )
				aDatos[1][6] := Alltrim(Str(nOmit))
				Processa( {|| genFile(.F.,aDatos,cFileNameTxt +" " + cFilAnt  + ".txt")}	, STR0011,STR0010, .T. )
			EndIf
			MSGINFO(STR0014)
		EndIf
	EndIf

	Restarea(aArea)

Return .T.

//+----------------------------------------------------------------------+
//|Valida parametros de entrada											 |
//+----------------------------------------------------------------------+
Static Function ValidParam()
	Local lRet:=  .T.
	Local cErr := ""
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. Empty(MV_PAR03) .or. Empty(MV_PAR04) .or. Empty(MV_PAR05);
			.OR.Empty(MV_PAR06)
		cErr += STR0008 + " " //"Por favor, complete todos los parametros solicitados"
		lRet := .F.
	End
	If Alltrim(Str(YEAR(MV_PAR01)))+Alltrim(Str(MONTH(MV_PAR01))) != Alltrim(Str(YEAR(MV_PAR02)))+Alltrim(Str(MONTH(MV_PAR02)))
		cErr += STR0016 + " " //"El rango de fechas debe pertenecer al mismo periodo."
		lRet := .F.
	EndIf
	If Len(Alltrim(MV_PAR03)) > 6 .AND. AT("/",MV_PAR03) != 7 .OR. Len(Alltrim(MV_PAR03)) != 9
		cErr += STR0013 // Verifique el formato del numero de habilitacion 000000/00
		lRet := .F.
	End
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

Static Function GenArqPer(aDatos, cSucursal,nOmit)
	Local cCpo := ""
	cCpo	:=  GetCpoImp(cSucursal) //Obtiene el cpo del impuesto PMP
	If cCpo != ""
		PerSF3(1,@aDatos,cCpo,cSucursal,@nOmit)//1.-Percepciones Clientes
		PerSF3(2,@aDatos,cCpo,cSucursal,@nOmit)//2.-Percepciones Proveedores
	EndIf
Return

//+----------------------------------------------------------------------+
//|Obtiene informaciï¿½n de SF3 para archivo de percepciones				 |
//+----------------------------------------------------------------------+
//|Parï¿½metros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|aDatos													 |
//|				|	Array en dï¿½nde serï¿½n almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//|				|cCpo												     |
//|				|	Campo configurado para obtener el valor del importe  |
//|				|	en SF3.												 | 
//+-------------+--------------------------------------------------------+
Static function PerSF3(nTipo,aData,cCpo,cSucursal, nOmi)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local nRegs		:= ""
	Local cCuit := ""
	Local cNome := ""
	Local cEspecie := ""
	Local cEspecieV	:= ""
	Local cEspecieC	:= ""
	Local nSinal := 1

	// Query para seccion datos
	If nTipo == 1
		cEspecieV	:= "'NF','NDC','NCC'"
	ElseIf nTipo == 2
		cEspecieC  := "'NDI','NCI'"
	EndIf
	cQuery 	:= 	"SELECT "
	cQuery	+=		"F3_SERIE, "
	cQuery	+=		"F3_EMISSAO, "
	cQuery	+=		"F3_NFISCAL, "
	cQuery	+=		"F3_ESPECIE, "
	cQuery	+=		"F3_BASIMP" + cCpo + ", "
	cQuery	+=		"F3_ALQIMP" + cCpo + ", "
	cQuery	+=		"F3_VALIMP" + cCpo + ", "
	If nTipo == 1
		cQuery	+=	"A1_CGC, A1_NOME	"
	ElseIf nTipo == 2
		cQuery 	+=	"A2_CGC, A2_NOME "
	End IF
	cQuery 	+=	"FROM "
	cQuery	+=		RetSqlName("SF3")+ " SF3,"

	If nTipo == 1
		cQuery	+=		RetSqlName("SA1")+ " SA1 "
	ElseIf nTipo == 2
		cQuery	+=		RetSqlName("SA2")+ " SA2 "
	End IF

	cQuery	+=	"WHERE "
	cQuery	+=	"F3_FILIAL='" + xFilial("SF3",cSucursal)+ "' AND "

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

	End If
	cQuery	+=		"SF3.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TcSetField( cTmp, 'F3_EMISSAO', 'D', TamSX3('F3_EMISSAO')[1], 0 )
	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0009 + str(nRegs))
		If (cTmp)->&("F3_VALIMP"+cCpo) != 0
			nSinal:=1
			If Alltrim((cTmp)->F3_ESPECIE) $ "NCC|NCI"
				nSinal:=-1
			EndIf
			If Alltrim((cTmp)->F3_ESPECIE) == "NF"
				cEspecie := "Fc("+ Alltrim(Substr((cTmp)->F3_SERIE,0,1)) + ")"
			ElseIf Alltrim((cTmp)->F3_ESPECIE) $ "NDC|NDI"
				cEspecie := "Nd("+ Alltrim(Substr((cTmp)->F3_SERIE,0,1)) + ")"
			ElseIf Alltrim((cTmp)->F3_ESPECIE) $ "NCC|NCI"
				cEspecie := "Nc("+ Alltrim(Substr((cTmp)->F3_SERIE,0,1)) + ")"
			EndIf
			If nTipo == 1
				cNome := Substr((cTmp)->A1_NOME,0,255)
				cCuit := Substr((cTmp)->A1_CGC,0,11)
			ElseIf nTipo == 2
				cNome := Substr((cTmp)->A2_NOME,0,255)
				cCuit := Substr((cTmp)->A2_CGC,0,11)
			EndIf
			AADD(aData,{ cCuit+ ";",;
				Alltrim(cNome)+";",;
				Substr((cTmp)->F3_NFISCAL,0,12)+";",;
				cEspecie+";",;
				DTOC((cTmp)->F3_EMISSAO)+";",;
				Alltrim(PADL(TRANSFORM((cTmp)->&("F3_BASIMP"+cCpo),"@! 9999999999.99"),13))+";",;
				Alltrim(TRANSFORM((cTmp)->&("F3_ALQIMP"+cCpo),"@! 99.99"))+";",;
				Alltrim(PADL(TRANSFORM((cTmp)->&("F3_VALIMP"+cCpo)*nSinal ,"@! 99999999999.99"),15))})
		Else
			nOmi++
		EndIf
		(cTmp)-> (dbSkip())
	EndDo
	(cTmp)-> (dbCloseArea())
	RestArea(aArea)
Return
//+----------------------------------------------------------------------+
//|Obtiene el campo del cuï¿½l se obtendrï¿½ el importe de las percepciones	 |
//+----------------------------------------------------------------------+
Static Function GetCpoImp(cSucursal)
	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "PMP"
	Local cCpo		:= ""

	cQuery	:= 	"SELECT "
	cQuery	+=	"FB_CPOLVRO "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SFB") + " SFB "
	cQuery	+=	"WHERE "
	cQuery 	+=  "FB_CODIGO ='PMP' AND "
	cQuery	+=	"FB_FILIAL = '"+ xFilial("SFB",cSucursal)+"' AND "
	cQuery	+=	"FB_CLASSIF = '5' AND "
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
//|				|	Nombre del archivo que s erï¿½ generado.     			 |
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+
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
				FWrite(nArqLog,"'"+STR0023+"';'"+STR0024+"';'"+STR0025+"';'"+STR0026+"';'"+STR0027+"';'"+STR0028+"'"+Chr(13)+Chr(10))
			ElseIf nI == 2 .And. !lAgrup
				FWrite(nArqLog,Chr(13)+Chr(10))
				FWrite(nArqLog,"'"+STR0024+"';'"+STR0029+"';'"+STR0030+"';'"+STR0031+"';'"+STR0032+"';'"+STR0033+"';'"+STR0034+"';'"+STR0035+"'"+Chr(13)+Chr(10))
			End IF
			IncProc(STR0012 + str(nI))
			If lAgrup
				For nJ:= 1 to Len(aArq[nI])
					For nK:= 1 to Len(aArq[nI,nJ])
						cLinea	+= aArq[nI,nJ,nK]
					Next nK
			
					IF nJ == 2
						FWrite(nArqLog,Chr(13)+Chr(10))
						FWrite(nArqLog,"'"+STR0024+"';'"+STR0029+"';'"+STR0030+"';'"+STR0031+"';'"+STR0032+"';'"+STR0033+"';'"+STR0034+"';'"+STR0035+"'"+Chr(13)+Chr(10))
					EndIf
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
		aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMECOM],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
		Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM"),x[SM0_NOMRED]}),;
		NIL)})

//-- Monta tela para selecao de filiais
	If lMostraTela
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0017) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi(STR0018) OF oDlg  PIXEL
		@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0019) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))
		@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0020),OemToAnsi(STR0021),OemToAnsi(STR0022) SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL
		bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,7],Transform(aFilsCalc[oQual:nAt,4],"@R 99.999.999/9999-99")}}
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
