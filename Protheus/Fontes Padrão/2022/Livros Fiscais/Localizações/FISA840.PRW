#INCLUDE "Protheus.ch"
#INCLUDE "FISA840.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"

#DEFINE _BUFFER 16384
#define _SEPARADOR CHR(59) // ";"

/*/{Protheus.doc} FISA840
    Padrón de empresas grandes
    @type  Function
    @author raul.medina
    @since 30/09/2021
    @param 
        Fecha       - dDataAuto: Fecha de ejecución de rutina automatica.
        Caracter    - cMesAuto: Mes del periodo.
                    - cAnioAuto: Año del periodo.
                    - cDirAuto: Dirección del archivo.
    /*/

Function FISA840(dDataAuto, cMesAuto, cAnioAuto,cDirAuto)
Local aArea		    := getArea()
Local oFld		    := Nil
Local oDialog       := Nil
Local cMes          := "05"
Local cAnio         := StrZero(Year(dDataBase),4)
Local lAutomato 	:= IsBlind()

Default dDataAuto   := ""
Default cMesAuto    := ""
Default cAnioAuto   := ""
Default cDirAuto    := ""

	If !lAutomato
		DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"RG 4367 - Padrón Empresas Grandes"

		@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Importación de padrón"

		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la importación de un TXT con las "
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"informaciones del listado de empresas grandes."
		@ 025,005 SAY STR0001 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"RG 4367 - Padrón Empresas Grandes"

        @ 045,005 SAY STR0005  SIZE 150,008 PIXEL OF oFld:aDialogs[1] 
        @ 045,060 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1] 
	    @ 045,075 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	    @ 045,078 MSGET cAnio PICTURE "@E 9999" VALID !Empty(cAnio) SIZE 020,008 PIXEL OF oFld:aDialogs[1] 
        @ 045,110 SAY STR0006 SIZE  150, 8 PIXEL OF oFld:aDialogs[1]

		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION RunProc(cMes, cAnio)     //"&Importar"
		@ 075,178 BUTTON STR0008 SIZE 036,016 PIXEL ACTION oDialog:End() 	        //"&Salir"
		ACTIVATE MSDIALOG oDialog CENTER
	Else
		RunProc(cMesAuto, cAnioAuto, dDataAuto, cDirAuto)
	EndIf

	Restarea(aArea)

Return

/*/{Protheus.doc} RunProc
    Validaciones y llamada de importación del padron
    @type  Function
    @author raul.medina
    @since 30/09/2021
    @param 
        Fecha       - dDataAuto: Fecha de ejecución de rutina automatica.
        Caracter    - cMes: Mes del periodo.
                    - cAnio: Año del periodo.
                    - cDirAuto: Dirección del archivo.
    /*/
Static Function RunProc(cMes, cAnio, dDataAuto, cDirAuto)
Local cFile     := ""
Local lAutomato := isblind()
Local nMes      := Val(cMes)
Local nAnio     := Val(cAnio)
Local nMesAct   := 0
Local nAnioAct  := 0


Default cMes        := ""
Default cAnio       := ""
Default dDataAuto   := Nil
Default cDirAuto    := ""

    If lAutomato
        nMesAct     := MONTH(dDataAuto)
        nAnioAct    := YEAR(dDataAuto)
        cFile       := cDirAuto
    Else
        nMesAct     := MONTH(dDatabase)
        nAnioAct    := YEAR(dDatabase)
    EndIf

    //Validación de periodo inhabiles.
    If ((nMesAct < ( nMes + 2)) .and. (nAnioAct == nAnio)) //Periodo de los primeros 2 meses
        If !lAutomato
            xMagHelpFis(STR0017,STR0016,STR0019) //"Atención"##"Periodo inhabil para actualizaciones."##"Verifique el periodo y archivo a importar."
        EndIf
        Return Nil
    EndIf

    If (((nMes + 2) <= nMesAct)  .and. (nAnioAct == (nAnio + 1))) //Fecha posteior a 14 meses.
        If !lAutomato
            xMagHelpFis(STR0017,STR0018,STR0019) //"Atención"##"El periodo no está vigente."##"Verifique el periodo y archivo a importar."
        EndIf
        Return Nil
    EndIf

    If nAnio > nAnioAct //Año del periodo superior al año actual
        If !lAutomato
            xMagHelpFis(STR0017,STR0018,STR0019) ////"Atención"##"El periodo no está vigente."##"Verifique el periodo y archivo a importar."
        EndIf
        Return Nil
    EndIf

    If !lAutomato
        cFile := FGetFile()
    EndIf

    If Empty(cFile)
        If !lAutomato
		    MsgStop(STR0010) //"Seleccione un archivo e intente nuevamente."
        EndIf
		Return Nil
	EndIf

	If !File(cFile)
        If !lAutomato
		    MsgStop(STR0010) //"Seleccione un archivo e intente nuevamente."
        EndIf
		Return Nil
	EndIf

    If !lAutomato
        MsAguarde({|| Import(cFile, cMes, cAnio, nMesAct, nAnioAct)} ,STR0011,STR0012 ,.T.) //"Lendo Arquivo, Aguarde..."###"Actualizando registros"
        MsgAlert(STR0020)
    else
        Import(cFile, cMes, cAnio, nMesAct, nAnioAct)
    EndIf

Return

/*/{Protheus.doc} Import
    Llamada de la importación de registros y actualización.
    @type  Function
    @author raul.medina
    @since 30/09/2021
    @param 
        Numerico    - nMesAct: Mes de ejecución.
                    - nAnioAct: Año de ejecución.
        Caracter    - cMes: Mes del periodo.
                    - cAnio: Año del periodo.
                    - cFile: Dirección del archivo.
    /*/
Static Function Import(cFile, cMes, cAnio, nMesAct, nAnioAct)
Local lReturn       := .T.
Local cAliasPdr     := GetNextAlias()
Local lAutomato     := isblind()

	If!lAutomato
		Processa({|| lReturn := CreaTabla(cFile, cAliasPdr)})// cualquier base de datos
	Else
		lReturn := CreaTabla(cFile, cAliasPdr)
	EndIf

    //Proceso de registros
	If lReturn
        ActRegs(cAliasPdr, cMes, cAnio, nMesAct, nAnioAct)
	EndIf

    If Select(cAliasPdr) <> 0
        (cAliasPdr)->(dbCloseArea())
    EndIf

Return Nil

/*/{Protheus.doc} CreaTabla
    Importación de registros a tabla temporal.
    @type  Function
    @author raul.medina
    @since 30/09/2021
    @param 
        Caracter    - cArqProc: Archivo.
                    - cAliasPdr: tabla temporal.
    /*/
Static Function CreaTabla(cArqProc, cAliasPdr)
Local aInforma	    := {} 		        
Local cMsg		    := STR0011          //"Leyendo archivo. Espere..."
Local cVersion	    := FwLibVersion()
Local cBuild        := TCGetBuild()
Local nHandle	    := 0		        
Local aStruct 	    := {}
Local nTotLin 	    := 0
Local nI 		    := 0
Local lRet		    := .T.
Local oFile
Local lUseBulk      := cBuild  >= "20181212" .and. cVersion >= "20201009"
Local lCanUseBulk   := .F.

	aAdd( aStruct, { 'CUIT'     , 'C', 11   , 0 } )
	aAdd( aStruct, { 'DENOMINAC', 'C', 80   , 0 } )
	aAdd( aStruct, { 'ACTIVIDAD', 'C', 200  , 0 } )
    aAdd( aStruct, { 'FECHAINI' , 'C', 10   , 0 } )

	nHandle := FT_FUse(cArqProc)
	If nHandle == -1
		lRet := .F.
	Else
		nTotLin := FT_FLASTREC()
		FT_FUSE()
		If Select(cAliasPdr) <> 0
			(cAliasPdr)->(dbCloseArea())
		EndIf
		If TCCanOpen(cAliasPdr)
			If TcSqlExec("DROP TABLE " + cAliasPdr) <> 0
				If !TCDelFile(cAliasPdr)
					MsgAlert(STR0013)
					lRet := .F.
				EndIf
			EndIf
		EndIf
        
        If lRet
            //Se verifica si es posible usar bulk
            If lUseBulk
                oBulk := FwBulk():New(cAliasPdr,600)
                lCanUseBulk := FwBulk():CanBulk() // Este método não depende da classe FWBulk ser inicializada por NEW
            EndIf

            oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
            If !oFile:Open()
                MsgAlert(STR0014 + cArqProc + STR0015)  //"El archivo " +cArqProc+ "No puede abrirse"
                Return .F.
            EndIf

            ProcRegua(nTotLin)

            //Se crea la tabla para bulk o proceso de carga normal
            If lCanUseBulk
                FWDBCreate(cAliasPdr, aStruct , 'TOPCONN' , .T.)
                oBulk:SetFields(aStruct)

                While oFile:ReadArray(@aInforma,_SEPARADOR)
                    If Len(aInforma) == 4
                        oBulk:AddData(aInforma)
                    EndIf
                    aSize(aInforma,0)
                    nI++
                    IncProc(cMsg + str(nI))
                End		
                If !Empty(oFile:_Resto)
                    aInforma:=Separa(oFile:_Resto,_SEPARADOR)
                    If Len(aInforma) == 4
                        oBulk:AddData(aInforma)
                    EndIf
                    aSize(aInforma,0)
                EndIf
                oBulk:Close()
                oBulk:Destroy()
                oBulk := nil
                oFile:Close()	 // Fecha o Arquivo

                If Select(cAliasPdr) == 0
                    DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)
                    cIndex := cAliasPdr+"1"
                    If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
                        DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
                    EndIf
                    Set Index to (cIndex)
                EndIf
            Else
                MsCreate(cAliasPdr,aStruct,"TOPCONN")
                DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)
                cIndex := cAliasPdr+"1"
                If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
                    DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
                EndIf
                Set Index to (cIndex)

                dbSelectArea(cAliasPdr)

                While oFile:ReadArray(@aInforma,_SEPARADOR)
                    nI ++
                    IncProc(cMsg + str(nI))
                    
                    If Len(aInforma) == 4
                        RecLock(cAliasPdr,.T.)
                        (cAliasPdr)->CUIT		:= aInforma[1]
                        (cAliasPdr)->DENOMINAC	:= aInforma[2]
                        (cAliasPdr)->ACTIVIDAD	:= aInforma[3]
                        (cAliasPdr)->FECHAINI	:= aInforma[4]
                        (cAliasPdr)->(MsUnLock())
                    EndIf
                End
            EndIf
        EndIf
	EndIf
Return lRet

/*/{Protheus.doc} ActRegs
    Actualización de registros.
    @type  Function
    @author raul.medina
    @since 30/09/2021
    @param 
        Numerico    - nMesAct: Mes de ejecución.
                    - nAnioAct: Año de ejecución.
        Caracter    - cMes: Mes del periodo.
                    - cAnio: Año del periodo.
                    - cAliasPdr: Tabla temporal.
    /*/
Static Function ActRegs(cAliasPdr, cMes, cAnio, nMesAct, nAnioAct)
Local cQuery	:= ""
Local nRegs		:= 0
Local nReg      := 0
Local cSA1      := GetNextAlias()
Local nMes      := Val(cMes)
Local nAnio     := Val(cAnio)
Local lAlta     := .F.
Local lBaja     := .F.

    If (nMesAct >= ( nMes + 2)) .and. (nAnioAct == nAnio)
        lBaja := .T.
    EndIf

    If ((nMesAct >= ( nMes + 4)) .and. (nAnioAct == nAnio)) .or.; //Fecha mayor/igual a 4 meses del periodo informado
        (((nMes + 1) > nMesAct) .and. (nAnioAct == (nAnio + 1))) //Validación que sea ejecutado en un periodo menor a 13 meses del periodo informado
        lAlta := .T.
    EndIf

    cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC"
    cQuery += " FROM " + RetSqlName("SA1")
    cQuery += " WHERE " // A1_FILIAL = '" + xFilial("SA1") + "'"
    cQuery += " D_E_L_E_T_ <> '*'"
    cQuery += " ORDER BY A1_CGC ASC"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cSA1, .T., .T.)
    (cSA1)->(dbGoTop())
    count to nRegs

    ProcRegua(nRegs)

    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    SA1->(dbGoTop())
    While SA1->(!EOF())
        nReg ++
		IncProc(STR0012 + str(nReg))

        If !Empty(SA1->A1_CGC)
            If (cAliasPdr)->(MsSeek(AllTrim(SA1->A1_CGC)))
                If lAlta
                    If SA1->A1_TAMEMP $ "1|2"
                        RecLock("SA1", .F.)
                            SA1->A1_TAMEMP := "3"
                        MsUnlock()
                    EndIf
                EndIf
            Else
                If lBaja
                    If SA1->A1_TAMEMP $ "3|4"
                        RecLock("SA1", .F.)
                            SA1->A1_TAMEMP := "1"
                        MsUnlock()
                    EndIf
                EndIf
            EndIf
        EndIf
        SA1->(dbSkip())
    End

    (cSA1)->(dbCloseArea())


    //ACtualización de empresa
    If (cAliasPdr)->(MsSeek(AllTrim(SM0->M0_CGC)))
        If lAlta
            If SuperGetMv("MV_TAMEMP",.F.,"") $ "1|2"
                PutMv("MV_TAMEMP", "3")
            EndIf
        EndIf
    Else
        If lBaja
            If SuperGetMv("MV_TAMEMP",.F.,"") $ "3|4"
                PutMv("MV_TAMEMP", "1")
            EndIf
        EndIf
    EndIf

Return

/*/{Protheus.doc} FGetFile()
	funcion utilizada para llamar la pantalla de seleccion del archivo a importar
	/*/
Static Function FGetFile()
Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0009,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0009,,.T.)//"Selecionar arquivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/{Protheus.doc} FGetDir()
	funcion utilizada para crear la pantalla de seleccion del archivo a importar
	/*/
Static Function FGetDir(oTGet)
Local cDir := ""

	cDir := cGetFile(,STR0009,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil
