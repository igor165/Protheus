#Include 'PROTHEUS.ch'
#Include 'FISA805.ch'
#Include 'TOPCONN.ch'

#DEFINE _SEPARADOR "	"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISA805  ³ Autor ³ Luis Samaniego          ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Padron Riesgo Fiscal de Salta                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ FECHA  ³   BOPS  ³  MOTIVO DE LA ALTERACION                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marco A. Glez³23/01/17³MMI-4744 ³Se agregan las validaciones:             ³±±
±±³              ³        ³         ³FH_ISENTO != "S" y FH_PERCENT != 100 para³±±
±±³              ³        ³         ³condicionar la actualizacion de la tabla ³±±
±±³              ³        ³         ³SFH - Empresa vs Zona Fiscal, de acuerdo ³±±
±±³              ³        ³         ³al Padron de Riesgo Fiscal Salta (ARG)   ³±±
±±³ Marco A. Glez³03/02/17³MMI-4794 ³Replica para V12.1.14 - Padron de Riesgo ³±±
±±³              ³        ³         ³Fiscal de Salta. (ARG)                   ³±±
±±³ Alf. Medrano ³28/04/17³MMI-179  ³creación de tabla temporal con   	     ³±±
±±³              ³        ³         ³FFWTemporaryTable en func ImpArq         ³±±
±±³              ³        ³         ³Merge Main vs 12.1.14                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA805()

	Local oFld		:= Nil
	Local aCombo	:= {}

	Private oGet		:= Nil
	Private oDlg		:= Nil
	Private lRet		:= .F.
	Private lPer		:= .F.
	Private lExistEmp	:= .F.
	Private cCombo		:= ""
	Private dFchPro		:= Date()
	Private cTipoEmp	:= ""
	Private cRiesgoEmp	:= ""
	Private aEstSFH		:= {}
	Private lAct		:= .F.

	aAdd(aCombo, STR0001) //"1- Cliente"  
	aAdd(aCombo, STR0002) //"2- Proveedor"
	aAdd(aCombo, STR0003) //"2- Ambos"

	DEFINE MSDIALOG oDlg TITLE STR0004 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Padron de Riesgo Fiscal de Salta"

	@ 006,006 TO 040,170 LABEL STR0007 OF oDlg PIXEL //"Inf. Preliminar."
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)

	@ 10,115 SAY STR0008 SIZE 065,008 PIXEL OF oFld //"Impuesto: "
	@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0011 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Percepción" 
	@ 030,115 CHECKBOX oChk2 VAR lRet PROMPT STR0012 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Retención"
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,075

	@ 010,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Identificacion de la situación de Riesgo Fiscal del" 
	@ 025,005 SAY STR0006 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Cliente/Proveedor (Empresa) y sus fechas de vigencia."

	@ 055,178 BUTTON STR0009 SIZE 036,016 PIXEL ACTION ImpArq(Val(Subs(cCombo,1,1)))//"&Importar"
	@ 075,178 BUTTON STR0010 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Salir" 

	ACTIVATE MSDIALOG oDlg CENTER

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Proceso archivo padron                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpArq(nOpc)

	Local cFile		:= ""
	Local aStru		:= {}
	Local aPadron	:= {}
	Local lImp		:= .F. 

	Private cTmpCUIT	:= ""
	Private cPadron		:= ""
	Private oTmpCUIT
	Private oTmpPadr

	cFile	:= FGetFile()
	aEstSFH	:= SFH->(DBSTRUCT())

	If File(cFile) .AND. !Empty(cFile)

		//Crea tabla temporal de padron
		aAdd(aStru, {"TMP_CUIT"		, "C", TamSX3("A1_CGC")[1], 0})
		aAdd(aStru, {"TMP_TIPO"		, "C", 1, 0})
		aAdd(aStru, {"TMP_RIESGO"	, "C", 1, 0})


		//Creacion de la tabla
		cTmpCUIT := Criatrab(Nil,.F.)
		oTmpCUIT:= FWTemporaryTable():New(cTmpCUIT)
		oTmpCUIT:SetFields( aStru )
		oTmpCUIT:AddIndex("T1", {"TMP_CUIT"}) 
		oTmpCUIT:Create() 
		Processa({|| lImp := ImpArch(cFile)}, STR0013, , .T.)

		//Crea tabla temporal de padron reducido
		aAdd(aPadron, {"TMP_CUIT"	, "C", TamSX3("A1_CGC")[1], 0})
		aAdd(aPadron, {"TMP_ORIGEN"	, "C", 1, 0})
		aAdd(aPadron, {"TMP_CODIGO"	, "C", TamSX3("A1_COD")[1], 0})
		aAdd(aPadron, {"TMP_LOJA"	, "C", TamSX3("A1_LOJA")[1], 0})
		aAdd(aPadron, {"TMP_NOMBRE"	, "C", TamSX3("A1_NOME")[1], 0})
		aAdd(aPadron, {"TMP_TIPO"	, "C", 1, 0})
		aAdd(aPadron, {"TMP_RIESGO"	, "C", 1, 0})
		aAdd(aPadron, {"TMP_EXISTE"	, "C", 1, 0})

		//Creacion de la tabla
		cPadron := Criatrab(Nil,.F.)
		oTmpPadr:= FWTemporaryTable():New(cPadron)
		oTmpPadr:SetFields( aPadron )
		oTmpPadr:AddIndex("T2", {"TMP_ORIGEN", "TMP_CUIT"}) 
		oTmpPadr:Create() 

		If lImp
			If nOpc == 1 .OR. nOpc == 3
				If lPer //Clientes
					Processa( {|| ProcRegs("SA1")}, , , .T. )
				EndIf
			EndIf
			If nOpc == 2 .OR. nOpc == 3
				If lPer .OR. lRet //Proveedores
					//Existe CUIT de empresa en padron
					lExistEmp := ProcEmp()
					Processa( {|| ProcRegs("SA2")}, , , .T. )
				EndIf
			EndIf
		EndIf

		(cPadron)->(dbGoTop())
		While (cPadron)->(!Eof())
			If (cPadron)->TMP_ORIGEN == "C"
				BuscaSFH("C", (cPadron)->TMP_EXISTE)
			ElseIf (cPadron)->TMP_ORIGEN == "P"
				If lRet
					BuscaSFH("P", (cPadron)->TMP_EXISTE) //Retenciones
				EndIf
				If lPer
					BuscaSFH("E", (cPadron)->TMP_EXISTE) //Percepciones
				EndIf
			EndIf
			(cPadron)->(dbSkip())
		EndDo
		(cPadron)->(dbCloseArea())	
		(cTmpCUIT)->(dbCloseArea())	
	Else
		Return Nil
	EndIf

	If lAct
		MsgInfo(STR0019, STR0022) //"Registros actualizados."  - "TOTVS"
	Else
		MsgInfo(STR0020, STR0022) //"No hubo modificaciones a los registros." - "TOTVS"
	End If         	
	oDlg:End()
	
	If oTmpCUIT <> Nil   
		oTmpCUIT:Delete()  
		oTmpCUIT := Nil 
	Endif 
	
	If oTmpPadr <> Nil   
		oTmpPadr:Delete()  
		oTmpPadr := Nil 
	Endif 
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcRegs ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea Padron reducido                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcRegs(cTabla)

	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSA		:= ""
	Local cTmp		:= ""                              
	Local nReg		:= 0
	Local nI		:= 0
	Local cClave	:= ""
	Local cPref		:= IIf(cTabla == "SA1","A1","A2")
	Local cMsg		:= IIf(cTabla == "SA1", STR0016, STR0017)

	cTmp 	:= Criatrab(Nil,.F.)
	cSA 	:= InitSqlName(cTabla)

	cQuery := "SELECT " + cPref + "_COD ," 
	cQuery +=			  cPref + "_LOJA,"
	cQuery +=			  cPref + "_CGC , "
	cQuery +=			  cPref + "_NOME "
	cQuery += "FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	cQuery += 		cPref + "_CGC <> ' ' AND "
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY " + cPref + "_CGC "

	cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

	Count to nCont
	(cTmp)->(dbGoTop())
	dbSelectArea(cTmpCUIT)
	dbSetOrder(1)
	ProcRegua(nCont) 
	While (cTmp)->(!eof())
		nI++
		IncProc(cMsg + str(nI))
		cClave := Alltrim((cTmp)->&(cPref+"_CGC"))

		If (cTmpCUIT)->(dbSeek(cClave))
			Reclock(cPadron,.T.)
			(cPadron)->TMP_CUIT     := Alltrim((cTmpCUIT)->TMP_CUIT)
			(cPadron)->TMP_ORIGEN   := IIf(cTabla == "SA1","C","P")
			(cPadron)->TMP_CODIGO   := Alltrim((cTmp)->&(cPref+"_COD"))
			(cPadron)->TMP_LOJA     := Alltrim((cTmp)->&(cPref+"_LOJA"))
			(cPadron)->TMP_NOMBRE   := Alltrim((cTmp)->&(cPref+"_NOME"))
			(cPadron)->TMP_TIPO     := (cTmpCUIT)->TMP_TIPO
			(cPadron)->TMP_RIESGO   := (cTmpCUIT)->TMP_RIESGO
			(cPadron)->TMP_EXISTE   := "S"
			(cPadron)->(MsUnlock()) 
		Else
			Reclock(cPadron,.T.)
			(cPadron)->TMP_CUIT     := Alltrim((cTmpCUIT)->TMP_CUIT)
			(cPadron)->TMP_ORIGEN   := IIf(cTabla == "SA1","C","P")
			(cPadron)->TMP_CODIGO   := Alltrim((cTmp)->&(cPref+"_COD"))
			(cPadron)->TMP_LOJA     := Alltrim((cTmp)->&(cPref+"_LOJA"))
			(cPadron)->TMP_NOMBRE   := Alltrim((cTmp)->&(cPref+"_NOME"))
			(cPadron)->TMP_TIPO     := ""
			(cPadron)->TMP_RIESGO   := ""
			(cPadron)->TMP_EXISTE   := "N"
			(cPadron)->(MsUnlock()) 	  					
		EndIf    	

		(cTmp)->(dbSkip())	    
	EndDo
	(cTmp)->(dbCloseArea())

	RestArea(aArea)
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BuscaSFH ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea registro en tabla SFH                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaSFH(cOrigen, cExisteP)
	
	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSFH		:= ""
	Local cTmp		:= ""                              
	Local nReg		:= 0

	cSFH 	:= InitSqlName("SFH")
	cTmp 	:= criatrab(Nil,.F.)  
	
	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH "
	cQuery += 	"WHERE "
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If cOrigen == "C"
		cQuery += "FH_CLIENTE='" + (cPadron)->TMP_CODIGO + "' AND "
		cQuery += "FH_LOJA   ='" + (cPadron)->TMP_LOJA + "' AND "
	ElseIf cOrigen == "P" .OR. cOrigen == "E"
		cQuery += "FH_FORNECE='" + (cPadron)->TMP_CODIGO + "' AND "
		cQuery += "FH_LOJA   ='" + (cPadron)->TMP_LOJA + "' AND "
	EndIf
	If cOrigen == "C"	.OR. cOrigen == "E"	
		cQuery += "FH_IMPOSTO = 'IBI' AND "
	ElseIf cOrigen == "P"		
		cQuery += "FH_IMPOSTO = 'IBR' AND "
		cQuery += "FH_ZONFIS = 'SA' AND " 
	End If 
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTmp, .T., .T.) 
	TCSetField(cTmp, "FH_INIVIGE", "D")
	TCSetField(cTmp, "FH_FIMVIGE", "D")

	Count to nCont
	(cTmp)->(dbGoTop())

	If nCont > 1
		(cTmp)->(dbSkip(nCont - 1))
		If (cTmp)->FH_FIMVIGE <> CTOD("//")
			(cTmp)->(dbGoTop())
		EndIf
	EndIf
	nReg := (cTmp)->R_E_C_N_O_
	If ((cOrigen $ "C|P" .AND. (cPadron)->TMP_EXISTE == "S") .OR. (cOrigen == "E" .AND. lExistEmp)) .AND. nCont > 0
		SFH->(DBGOTO(nReg))
		If  SFH->(!Eof())
			If FH_ISENTO != "S"
				If FH_PERCENT != 100
					If VldVigSFH()
						Reclock("SFH",.F.)
						SFH->FH_ISENTO  := "N"
						If cOrigen == "E"
							SFH->FH_TIPO    := cTipoEmp
							SFH->FH_SITUACA := cRiesgoEmp
							If cTipoEmp == "X"
								SFH->FH_PERCENT := 100
							Else
								SFH->FH_PERCENT := 0
							EndIf
						Else
							SFH->FH_TIPO    := (cPadron)->TMP_TIPO
							SFH->FH_SITUACA := (cPadron)->TMP_RIESGO
							If (cPadron)->TMP_TIPO == "X"
								SFH->FH_PERCENT := 100
							Else
								SFH->FH_PERCENT := 0
							EndIf
						EndIf
						MSUnlock()
						lAct := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf ((cOrigen $ "C|P" .AND. (cPadron)->TMP_EXISTE == "S" .AND. (cPadron)->TMP_TIPO <> "N") .OR. (cOrigen == "E" .AND. lExistEmp .AND. cTipoEmp <> "N"))  .AND. nCont == 0
		Reclock("SFH",.T.)
		SFH->FH_FILIAL := xFilial("SFH")
		SFH->FH_AGENTE := "N"
		If cOrigen == "C"
			SFH->FH_CLIENTE := (cPadron)->TMP_CODIGO
		Else
			SFH->FH_FORNECE := (cPadron)->TMP_CODIGO
		EndIf
		SFH->FH_NOME := (cPadron)->TMP_NOMBRE
		SFH->FH_LOJA := (cPadron)->TMP_LOJA
		If cOrigen $ "C|E"
			SFH->FH_IMPOSTO := "IBI"
		Else
			SFH->FH_IMPOSTO := "IBR"
		EndIf
		If cOrigen $ "C|E"
			SFH->FH_PERCIBI := "S"
		Else
			SFH->FH_PERCIBI := "N"
		EndIf
		SFH->FH_ISENTO := "N"
		SFH->FH_APERIB := "N"
		SFH->FH_ZONFIS := "SA"
		If cOrigen == "E"
			SFH->FH_TIPO    := cTipoEmp
		Else
			SFH->FH_TIPO := (cPadron)->TMP_TIPO
		EndIf
		If (cPadron)->TMP_TIPO == "X"
			SFH->FH_PERCENT := 100
		Else
			SFH->FH_PERCENT := 0
		EndIf
		If cOrigen == "E"
			SFH->FH_SITUACA := cRiesgoEmp
		Else
			SFH->FH_SITUACA := (cPadron)->TMP_RIESGO
		EndIf
		SFH->FH_INIVIGE := Date()
		SFH->FH_FIMVIGE := CTOD("//")

		lAct := .T.
		MSUnlock()
	ElseIf ((cOrigen $ "C|P" .AND. (cPadron)->TMP_EXISTE == "N") .OR. (cOrigen == "E" .AND. !lExistEmp)) .AND. nCont > 0
		SFH->(DBGOTO(nReg))
		If  SFH->(!Eof())
			If FH_ISENTO != "S" .AND. FH_PERCENT != 100
				If VldVigSFH()
					Reclock("SFH", .F.)
					If cOrigen == "E"
						SFH->FH_TIPO    := "N"
						SFH->FH_SITUACA := "1"
						SFH->FH_PERCENT := 0
					Else
						SFH->FH_TIPO    := "N"
						SFH->FH_SITUACA := "1"
						SFH->FH_PERCENT := 0
					EndIf
					MSUnlock()
					lAct := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldVigSFH³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida fechas de vigencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldVigSFH()
	
	Local lRet := .F.

	If (SFH->FH_INIVIGE == CTOD('//') .AND. SFH->FH_FIMVIGE == CTOD('//'))
		actRegSFH("1")
		lRet := .T.
	ElseIf (SFH->FH_INIVIGE == CTOD('//') .AND. SFH->FH_FIMVIGE <> CTOD('//') .AND. SFH->FH_FIMVIGE > dFchPro)
		actRegSFH("2")
		lRet := .T.
	ElseIf (SFH->FH_INIVIGE <> CTOD('//') .AND. SFH->FH_FIMVIGE == CTOD('//'))
		actRegSFH("3")
		lRet := .T.
	ElseIf (SFH->FH_INIVIGE <> CTOD('//') .AND. SFH->FH_FIMVIGE <> CTOD('//') .AND. SFH->FH_FIMVIGE > dFchPro) 
		actRegSFH("4")
		lRet := .T.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ actRegSFH³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Actualiza registro en tabla SFH                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function actRegSFH(cSituac)
	
	Local i := 0
	Local j := 0

	aSFHTemp := {}

	For i := 1 to len(aEstSFH)
		aADD(aSFHTemp,{aEstSFH[i],SFH->&(aEstSFH[i][1])}) 
	Next i

	Reclock("SFH",.F.)
	SFH->FH_FIMVIGE :=  dFchPro-1
	MSUnlock()

	Reclock("SFH",.T.)
	For j := 1 to Len(aSFHTemp)
		SFH->&(aSFHTemp[j][1][1]) := aSFHTemp[j][2]
	Next j
	SFH->FH_INIVIGE := dFchPro
	If cSituac $ "1|3"
		SFH->FH_FIMVIGE	:= CTOD("//")
	EndIf
	
	MSUnlock()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArch  ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lee archivo de texto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpArch(cFile)
	
	Local nFor		:= 0
	Local nHandle	:= 0
	Local nX		:= 0
	Local lOK		:= .F.

	dbSelectArea(cTmpCUIT)
	(cTmpCUIT)->(dbGoTop())

	nHandle := FT_FUse(cFile)

	If nHandle != -1

		FT_FGoTop()

		nFor := FT_FLastRec()

		ProcRegua(nFor)

		While !FT_FEOF()//Si el puntero esta posicionado al final del archivo
			nX++
			nRecno := FT_FRecno()
			aLinea := {}

			IncProc(STR0015 + Str(nX))

			aLinea := Separa(FT_FREADLN(),_SEPARADOR)

			If  Empty(aLinea)
				FT_FSKIP() 
				Loop
			Endif  

			aLinea[1] := Alltrim(aLinea[1])
			aLinea[3] := Alltrim(aLinea[3])
			aLinea[4] := Alltrim(aLinea[4])

			Reclock(cTmpCUIT,.T.)
			(cTmpCUIT)->TMP_CUIT   := aLinea[1]
			(cTmpCUIT)->TMP_TIPO   := IIf(aLinea[3] == "JU", "I", IIf(aLinea[3] == "CM", "V", IIf(aLinea[3] == "EX", "X", "N")))
			(cTmpCUIT)->TMP_RIESGO := IIf(aLinea[4] == "SR" .OR. aLinea[4] == "", "1", "2")
			(cTmpCUIT)->(MsUnlock()) 
			lOK := .T.

			FT_FSKIP()
		EndDo
		FT_FUSE()
	Else
		MsgInfo(STR0010 + cFile + STR0011, STR0022)//"&Salir" - "Percepción" - "TOTVS"	
	EndIf

Return lOK

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcEmp  ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida CUITs de Empresas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcEmp(nExen, dDesde, dHasta)

	Local lOK	:= .F.
	Local aArea	:= getArea()
	
	dbSelectArea("SM0")
	dbSetOrder(1)

	SM0->(dbgotop())

	While SM0->(!Eof()) .AND. !lOK
		If !Empty(SM0->M0_CGC) 
			If (cTmpCUIT)->(dbSeek(Alltrim(SM0->M0_CGC)))	
				cTipoEmp   := (cTmpCUIT)->TMP_TIPO
				cRiesgoEmp := (cTmpCUIT)->TMP_RIESGO
				lOK 	    := .T.
			EndIf
		EndIf	
		SM0->(DbSkip())
	EndDo

	RestArea(aArea)

Return lOK

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidChk ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacion de checks de percepcion y retencion             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function ValidChk(cCombo)

	If lRet == .T. .AND. Subs(cCombo, 1, 1) $ "1"
		lRet := .F.
	EndIf	
	oChk2:Refresh()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta ventana para obtener archivo de texto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGetFile()

	Local cRet := Space(50)

	oDlg01 := MSDialog():New(000, 000, 100, 500, STR0021, , , , , , , , , .T.)

	oGet01 := TGet():New(010,010,{|u| If(PCount() > 0, cRet := u, cRet)}, oDlg01, 215, 10, , {||ValExtFile(cRet)}, , , , , , .T., , , , , , , , , , "cRet")
	oBtn01 := TBtnBmp2():New(017, 458, 025, 028, "folder6", "folder6", , , {|| FGetDir(oGet01)}, oDlg01, STR0021, , .T.)

	oBtn02 := SButton():New(035, 185, 1, {|| oDlg01:End()}, oDlg01, .T., , )
	oBtn03 := SButton():New(035, 215, 2, {|| cRet := "",oDlg01:End()}, oDlg01, .T., , )

	oDlg01:Activate( , , , .T., , , )

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtiene archivo de texto                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGetDir(oTGet)

	Local cDir := ""

	cDir := cGetFile( , STR0021, , , .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) //"Seleccionar archivo" 
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValExtFile³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida extension de archivo de texto                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValExtFile(cNomeFile)

	Local lOK	:= .T.
	Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)

	If Empty(UPPER(cNomeFile)) .OR. !(cExt $ "csv|CSV|txt|TXT")
		MsgInfo(STR0014, STR0022) //"Formato de archivo no válido." - "TOTVS"
		lOK := .F.
	End If

Return lOK
