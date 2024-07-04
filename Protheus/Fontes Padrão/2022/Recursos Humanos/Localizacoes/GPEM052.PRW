#INCLUDE "TOTVS.CH"
#INCLUDE "GPEM052.CH"
#INCLUDE "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEM052   ºAutor  ³Raul Ortiz          ºFecha ³ 11/11/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera información correspondientes a IPS de acuerdo a la   º±±
±±º          ³legislación, usos y costumbres de Paraguay.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP12                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Programador ³  Fecha   ³Llamado  ³  Motivo da Alteracao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCristian Fran³10/05/2021³         ³ Archivo IPS Paraguay               º±±
±±ºCristian Fran³28/05/2021³         ³ Tabla Alfanúmerica para registrar  º±±
±±º 					   ³		 ³ Conceptos y mostrar archivo IPS.   º±±	
±±ºCristian Fran³16/07/2021³ 		 ³Suma de conceptos donde RV_SALARIA=1º±±	
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM052()
Local aArea		:= getArea()   
Local oFld		:= Nil
	
Private oDlg1	:= Nil
Private oDialg  := Nil
	
	
DEFINE MSDIALOG oDlg1 TITLE STR0001 FROM 0,0 TO 250,450 OF oDlg1 PIXEL //"Porcentaje de Exención de Percepción y Retención del IVA"

@ 020,006 FOLDER oFld OF oDlg1 PROMPT STR0002 PIXEL SIZE 165,075 	//"&Importação de Arquivo TXT"
		
	//+----------------
	//| Campos Folder
	//+----------------
@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina genera información correspondientes a "
@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"IPS de acuerdo a la legislación, usos y costumbres "
@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"de Paraguay."

	//+-------------------
	//| Boton de MSDialog
	//+-------------------
@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDlg1:End() 	//"&Sair"	"
	
ACTIVATE MSDIALOG oDlg1 CENTER
		
Restarea(aArea)


Return

//+----------------------------------------------------------------------+
//|Detona los parámetros y la selección de registros.                    |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function RunProc()
Private cDate  := ""
Private cMes   := ""
Private cAno   := ""
Private cFil   := ""
Private cPerg  := "GPEM052"
Private aDatos := {}
Private cRuta  := ""
Private cCodPat:= ""
	
	If Pergunte(cPerg,.T.)
		cDate := MV_PAR01
		cRuta := Carpeta()
		If ValidParam()
			MakeSqlExpr(cPerg)
			cFil  := MV_PAR02
			cCodPat := MV_PAR03
			Processa( {|| GenArqIPS()}, STR0012,STR0012, .T. )
		EndIf
	EndIf

Return

//+----------------------------------------------------------------------+
//|Valida los parámetros de entrada de la rutina					     |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function ValidParam()
	Local lRet := .T.
	Local nMes := 0
	
	If (SRA->(ColumnPos("RA_PRISOBR")) * SRA->(ColumnPos("RA_SECSOBR")) * SRA->(ColumnPos("RA_PRINOME")) * SRA->(ColumnPos("RA_SECNOME")) * SRA->(ColumnPos("RA_JUBILAC")) * RCM->(ColumnPos("RCM_TPIMSS"))) > 0
		If !Empty(cDate) .And. !Empty(cRuta)
		
			cMes := SubStr(cDate,6,2)
			cAno := SubStr(cDate,1,4)
			nMes := Val(cMes)
			If nMes < 0 .Or. nMes > 12
				MsgAlert(STR0008) 		
				lRet := .F.
			EndIf
		Else
			MsgAlert(STR0009) 		
			lRet := .F.
		EndIf
	Else
		MsgAlert(STR0015 + STR0016)
		lRet := .F.
	EndIf	
Return lRet

//+----------------------------------------------------------------------+
//|Realiza la selección de registros y la escritura en el archivo        |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function GenArqIPS()
	Local cQuery	:= ""
	Local cTmp		:= GetNextAlias()
	Local cDataIni	:= cAno + cMes + "01"
	Local cDataFin	:= cAno + cMes + AllTrim(STR(F_UltDia(CTOD("01" + "/" + cMes + "/" + cAno) )))
	Local nRegs		:= 0
	Local nReg		:= 0
	Local cLinea	:= ""
	Local cSepar	:= ";"
	Local nArqLog	:= ""
	Local nH0360	:= ""
	Local nV0869	:= ""
	Local cFilMat	:= ""
	
	
	Private aCdgos	:= {}

	
	aDatos := {}
	
			
	cQuery 	:= 	"SELECT "
	cQuery	+=		"RA_FILIAL, "
	cQuery	+=		"RA_MAT, "
	cQuery	+=		"RA_CODRPAT, "
	cQuery	+=		"RA_RG, "
	cQuery	+=		"RA_CIC, "
	cQuery	+=		"RA_PRINOME, "
	cQuery	+=		"RA_SECNOME, "
	cQuery	+=		"RA_PRISOBR, "
	cQuery	+=		"RA_SECSOBR, "
	cQuery	+=		"RA_ADMISSA, "
	cQuery	+=		"RA_SITFOLH, "
	cQuery	+=		"RA_INSSSC, "
	cQuery	+=		"RA_JUBILAC, "
	cQuery	+=		"RA_DEMISSA, "
	//SubQuery de número de ausencias registradas en el mes
	cQuery  += 		"("
	cQuery  += 			"SELECT COUNT (DISTINCT (R8_TIPOAFA)) "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SR8")+ " SR8 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"SRA.RA_MAT = SR8.R8_MAT AND "
	cQuery  += 				"SRA.RA_FILIAL = SR8.R8_FILIAL AND "
	cQuery  += 				"R8_DATAINI >= '" + cDataIni + "' AND "
	cQuery  += 				"R8_DATAINI <= '" + cDataFin + "' AND "
	cQuery  += 				"SR8.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS NROAU, "
	//Fin SubQuery de numero de ausencias
	//SubQuery de codigo de ausencia, regresa un unico registro.
	cQuery  += 		"("
	cQuery  += 			"SELECT MAX (RCM_TPIMSS) "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("RCM")+ " RCM "	
	cQuery  += 			"WHERE "
	cQuery	+=			"RCM.RCM_TIPO = " 
	cQuery  += 			"("
	cQuery  += 				"SELECT MAX (R8_TIPOAFA) "
	cQuery	+=				"FROM "
	cQuery	+=				RetSqlName("SR8")+ " SR8 "	
	cQuery  += 				"WHERE "
	cQuery  += 					"SRA.RA_MAT = SR8.R8_MAT AND "
	cQuery  += 					"SRA.RA_FILIAL = SR8.R8_FILIAL AND "
	cQuery  += 					"R8_DATAINI >= '" + cDataIni + "' AND "
	cQuery  += 					"R8_DATAINI <= '" + cDataFin + "' AND "
	cQuery  += 					"SR8.D_E_L_E_T_ = ' ' "
	cQuery	+=			") AND "
	cQuery  +=			"RCM.D_E_L_E_T_ = ' ' "
	cQuery	+=		") AS TIPO"
	//Fin SubQuery de codigo de ausencia
	//Campos SRD
	
	cQuery	+=	", "
	cQuery	+=	"RD_HORAS AS RDHORAS, "
	cQuery	+=	"RD_VALOR AS RDVALOR, "
	cQuery	+=	"RD_PD "
	cQuery	+= " "
	
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SRA")+ " SRA "
	// Join con tablas SRD para obtener datos
	
	//SRD
	cQuery	+= 	"INNER JOIN "
	cQuery	+=  RetSqlName("SRD")  +" SRD ON "
	cQuery	+=	"RA_FILIAL = RD_FILIAL AND "
	cQuery	+=	"RA_MAT = RD_MAT AND "
	cQuery  +=	"RD_PERIODO = '"+ cAno + cMes +"' AND " 			
	cQuery	+=	"SRD.D_E_L_E_T_= ' ' "
	
	// Join con tablas SRV		
	cQuery	+= 	"INNER JOIN "
	cQuery	+=  RetSqlName("SRV")  +" SRV ON "
	cQuery	+=	"RV_COD=SRD.RD_PD  "
	cQuery	+=	"AND RV_SALARIA='1' "
	cQuery	+=	"WHERE "
	If !Empty(cCodPat)
		cQuery  += "RA_CODRPAT = '"+ cCodPat +"' AND "
	EndIf		
	If !Empty(cFil)
		cQuery	+=	cFil + " AND "
	EndIf
	cQuery	+=		"( "
	cQuery	+=			"RA_SITFOLH <> 'D' OR "
	cQuery	+=			"("
	cQuery	+=				"RA_SITFOLH = 'D' AND "
	cQuery	+=				"RA_DEMISSA >= '" + cDataIni + "' AND "
	cQuery	+=				"RA_DEMISSA <= '" + cDataFin + "' "
	cQuery  += 			")"
	cQuery	+=		") AND "
	cQuery	+=		"SRA.D_E_L_E_T_= ' ' "
	cQuery  +=	"GROUP BY RA_FILIAL,RA_MAT,RA_CODRPAT,RA_RG,RA_CIC,RA_PRINOME,RA_SECNOME,RA_PRISOBR,RA_SECSOBR,RA_ADMISSA,RA_SITFOLH,RA_INSSSC,RA_JUBILAC,RA_DEMISSA,RD_HORAS,RD_VALOR,RD_PD "
	cQuery  += 	"ORDER BY RA_FILIAL, RA_MAT"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	
	Count to nRegs

	ProcRegua(nRegs)
	(cTmp)->(dbGoTop())
	
	nReg := 0
	nH0360	:= 0
	nV0869	:= 0
	If genFile(@nArqLog)
		While (cTmp)-> (!Eof())
			nReg++
			IncProc(STR0012)
			
			If cFilMat <> (cTmp)->RA_FILIAL + (cTmp)->RA_MAT   
				cFilMat := (cTmp)->RA_FILIAL + (cTmp)->RA_MAT
				cLinea := (cTmp)->RA_CODRPAT  + cSepar 											//Número patronal
				cLinea += RTrim((cTmp)->RA_RG) + cSepar 										//Número de asegurado
				cLinea += RTrim((cTmp)->RA_CIC) + cSepar 										//Número de cédula
				cLinea += RTrim((cTmp)->RA_PRISOBR) + " " + RTrim((cTmp)->RA_SECSOBR) + cSepar	//Apellidos
				cLinea += RTrim((cTmp)->RA_PRINOME) + " " + RTrim((cTmp)->RA_SECNOME) + cSepar 	//Nombres
				cLinea += "E" + cSepar 															//Categoría
				cLinea += "#H0360#" + cSepar 													//Cantidad de días trabajados
				cLinea += "#V0869#" + cSepar 													//Salario
				cLinea += cMes + cAno + cSepar 													//Mes y año
				cLinea += CdgoMov(cTmp,cDataIni,cDataFin) + cSepar 								//Código de movimiento
				cLinea += "#V0869#"																//Salario Real
				
				If(cTmp)->RD_PD == '196'
					nH0360	:= (cTmp)->RDHORAS
				EndIf
				nV0869	+= (cTmp)->RDVALOR		
			ElseIf cFilMat == (cTmp)->RA_FILIAL + (cTmp)->RA_MAT 
				If(cTmp)->RD_PD == '196'
					nH0360	:= (cTmp)->RDHORAS
				EndIf
				nV0869	+= (cTmp)->RDVALOR
			EndIf														
			
			(cTmp)->(dbSkip())
			If cFilMat <> (cTmp)->RA_FILIAL + (cTmp)->RA_MAT .and. !Empty(cLinea)
				cLinea := Replace(cLinea,"#H0360#",AllTrim(STR(nH0360)))
				cLinea := Replace(cLinea,"#V0869#",AllTrim(STR(nV0869)))
				FWrite(nArqLog,cLinea+Chr(13)+Chr(10))
				nH0360	:= 0
				nV0869	:= 0
			EndIf
		EndDo
		
		FClose(nArqLog)
		MsgAlert(STR0013)
	EndIf
	(cTmp)->(dbCloseArea())		
Return


//+----------------------------------------------------------------------+
//|Genera el archivo de texto 											 |
//+----------------------------------------------------------------------+
//|Parámetros	|nArqLog												 |
//|				|	Nombre del archivo que será generado.     			 |
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+
Static Function genFile(nArqLog)
	Local cFileName	:= ""
	Local nArqLog	:= ""
	Local cNameFile := IIf(!Empty (cCodPat),cCodPat+"_"+STR0014,STR0014) //"Declaracion_salarios_IPS.txt"
	
	If !ExistDir(cRuta)
		MsgAlert(STR0010) 
		Return	.F.
	EndIf 
	
	cFileName := AllTrim(cRuta) + cNameFile
	If File(cNameFile)	
		FErase(cNameFile) 
	EndIf
	
	nArqLog	:= MSfCreate(cFileName, 0)
	
Return .T.

//+----------------------------------------------------------------------+
//|Permite la selección de la ruta para guardar el archivo.              |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function Carpeta()
	Local cTipo		:= ""
	Local cCpoVld	:= ""
	
	cCpoVld := cGetFile( cTipo , OemToAnsi(STR0011),,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)

Return cCpoVld

//+----------------------------------------------------------------------+
//|Validaciones para determinar el codigo de movimiento		             |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function CdgoMov(cTmp,cDataIni,cDataFin)
Local cCgoMov	:= ""
Local nCausas	:= 0
	
	If (cTmp)->NROAU > 1 //Más de 2 ausencias con diferente codigo -> Varias causas
		cCgoMov := "10"
	Else
		If (cTmp)->RA_DEMISSA >= cDataIni .and. cDataFin >= (cTmp)->RA_DEMISSA //Salida
			cCgoMov	:= "2"
		    nCausas += 1
		EndIf
		If (cTmp)->RA_ADMISSA >= cDataIni .and. cDataFin >= (cTmp)->RA_ADMISSA //Entrada
			cCgoMov	:= "1"
			nCausas += 1
		EndIf 
		
		If nCausas > 1 .Or. (nCausas == 1 .and. (cTmp)->NROAU == 1)//Varias causas
			cCgoMov := "10"
		Else
			If (cTmp)->NROAU == 1 // 1 Ausencia				
				If AllTrim((cTmp)->TIPO) $ ("3|4|11|12|13|16|17")
					cCgoMov := AllTrim((cTmp)->TIPO)
					//3 -> Vacaciones
					//4 -> Reposo
					//11 -> Permiso
					//12 -> Judicial
					//13 -> Sanción
					//16 -> Salida Programada
					//17 -> Junta Medica
				Else
					cCgoMov := "6" //Otras causas
				EndIf
			Else
				If(cTmp)->RA_ADMISSA <= cDataIni .And. (cTmp)->RA_SITFOLH <> 'D'
					If (cTmp)->RA_INSSSC == "N"
						If (cTmp)->RA_JUBILAC == "0" //Normal
							If(cTmp)->NROAU == 0
								cCgoMov	:= "0"
							EndIf	
						Else
							cCgoMov	:= "18" //Jubilación/ Invalidez
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


Return cCgoMov



//+----------------------------------------------------------------------+
//|Verifica si el empleado tuvo una liquidación en el periodo            |
//+----------------------------------------------------------------------+
//|Parámetros	|       												 | 
//+-------------+--------------------------------------------------------+
Static Function VerifLiq(cSuc, cMat, cDataIni, cDataFin)
Local cQuery	:= ""
Local cTmpLiq	:= GetNextAlias()
Local lRet		:= .F.
Local cTipoLiq	:= fGetCalcRot("A")
	
	cQuery 	:= 	"SELECT "
	cQuery	+=		"RA_MAT, "
	cQuery	+=		"COUNT(SRC.RC_MAT) AS RCLIQ, "
	cQuery	+=		"COUNT(SRD.RD_MAT) AS RDLIQ "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SRA")+ " SRA "
	cQuery	+= 	"LEFT JOIN "
	cQuery	+=  RetSqlName("SRC")  +" SRC ON "
	cQuery	+=		"RA_FILIAL = RC_FILIAL AND "
	cQuery	+=		"RA_MAT = RC_MAT AND "
	cQuery	+=  	"RC_ROTEIR = '" + cTipoLiq + "' AND "		
	cQuery  += 		"RC_DATA >= '" + cDataIni + "' AND "
	cQuery  += 		"RC_DATA <= '" + cDataFin + "' AND "
	cQuery	+=		"SRC.D_E_L_E_T_= ' ' "
	cQuery	+= 	"LEFT JOIN "
	cQuery	+=  RetSqlName("SRD")  +" SRD ON "
	cQuery	+=		"RA_FILIAL = RD_FILIAL AND "
	cQuery	+=		"RA_MAT = RD_MAT AND "
	cQuery	+=  	"RD_ROTEIR = '" + cTipoLiq + "' AND "		
	cQuery  += 		"RD_DATPGT >= '" + cDataIni + "' AND "
	cQuery  += 		"RD_DATPGT <= '" + cDataFin + "' AND "
	cQuery	+=		"SRD.D_E_L_E_T_= ' ' "
	cQuery	+=	"WHERE "
	cQuery	+=		"RA_FILIAL = '" + cSuc + "' AND "
	cQuery	+=		"RA_MAT = '" + cMat + "' AND "
	cQuery	+=		"SRA.D_E_L_E_T_= ' ' "
	cQuery	+=	"GROUP BY RA_MAT"
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpLiq,.T.,.T.)
	
	If (cTmpLiq)-> (!Eof()) 
		While (cTmpLiq)-> (!Eof()) .And. !lRet
			
			If (cTmpLiq)->RCLIQ > 0 .Or. (cTmpLiq)->RDLIQ > 0
				lRet := .T.
			EndIf
			(cTmpLiq)->(dbSkip())
		Enddo
	Else
		lRet := .F.
	EndIf
	
Return lRet

