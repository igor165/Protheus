#Include 'Protheus.ch'
#Include 'topconn.ch'
#Include 'FISA806.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FISA806   º Autor ³ Juan Glz Rivas     º Data ³  10/02/17        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importacion del padron de las facturas apocrifas.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Version 12                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data   ³ BOPS    ³  Motivo da Alteracao                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLuisEnriquez³13-02-17³MMI-4171 ³Se crea fuente para importación de padrón deº±±
±±º            ³        ³         ³facturas apocrifas (sólo existía para v11). º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA806()
	Local cCadastro := STR0001 
	Local cPerg := "FISA806"
	Local aArea := GetArea()
	Local aSays :={} 
	Local aButtons :={}
	Local nOpca := 0
	Private cTipo	:= ""
	Private dFecVig := ""
	Private cDir := ""
	Private aLinea := {}
	Private lAct := .F.
   Private cTmp := GetNextAlias()   
		
	//Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0002) ) 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| Iif(ValC806(), (nOpcA := 1, o:oWnd:End()),)}} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpca := 2, o:oWnd:End()}} )
	FormBatch( oemtoansi(cCadastro), aSays , aButtons )	
	
	If nOpca == 1
		cTipo := MV_PAR01
		dFecVig := MV_PAR02
		cDir := MV_PAR03
		
		ImpArq(cDir)
	EndIf
	
	Restarea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³FGetDir806   ºAutor  ³ Juan Glz Rivas     º Data ³  10/02/17   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Muestra pantalla para seleccion de archivo.                   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ Nil                                                           º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGetDir806()
	Local cDir := ""
	
	cDir := cGetFile(,STR0003,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar archivo"
	If !Empty(cDir)
		MV_PAR03 := cDir
	Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³ValC806      ºAutor  ³ Juan Glz Rivas     º Data ³  10/02/17   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Valida que los parametros hayan sido indicados.               º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ Valor logico .T. o .F.                                        º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValC806()
	If  EMPTY(MV_PAR01) .Or. EMPTY(MV_PAR02) .Or. EMPTY(MV_PAR03)
		MsgAlert(STR0013)
		Return .F.
	EndIf
Return .T.
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³ImpArq       ºAutor  ³ Juan Glz Rivas     º Data ³  10/02/17   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Procesa archivo y modifica datos.                             º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ Nil                                                           º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/			
Static Function ImpArq(cDir)

	Local cFile := ""
	Local cArq := ""
	Local aStru := {}
	Local lImp	:= .F.
	Local nOpc
	Private lAct := .F.
	
	IF File(cDir) .And. !Empty(cDir)     
		
		//creamos la tabla temporal
	
		AADD(aStru,{ "CUIT", "C", 14, 0})
		AADD(aStru,{ "FCHDTC", "C", 8, 0})
		AADD(aStru,{ "FCHPUB", "C", 8, 0})
		
    oTmpTable := FWTemporaryTable():New(cTmp,aStru)
    oTmpTable:AddIndex("IN1", {"CUIT"})
    oTmpTable:Create()
		
		// Se procesa archivo de texto				
		Processa( {|| lImp:=ImpFile(cDir,cTmp)}, STR0004, STR0004, .T.)
		
		If lImp // Si el archivo fue procesado
			//Si el tipo es diferente de 2, o sea que es para proveedores o para ambos
			If cTipo != 2
				Processa( {|| ProcRegs(1,cTmp)}, STR0010, STR0011, .T. )	//Proveedores
			EndIf
			
			//Si el tipo es diferente de 1, o sea que es para clientes o para ambos
			If cTipo != 1
				Processa( {|| ProcRegs(2,cTmp)}, STR0010, STR0012, .T. )	//Clientes	
			EndIf			
		End IF
      oTmpTable:Delete()
	Else
		Return Nil
	EndIF
		
	//Manda mensaje dependiendo si se realizó la actualización de registros o no.     
	If lAct
		MsgAlert(STR0008)
	Else
		MsgAlert(STR0009)
	End If 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³ImpFile      ºAutor  ³ Juan Glz Rivas     º Data ³  10/02/17   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Procesa el archivo .csv y llena tabla temporal TRD.           º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ Valor .T. o .F.                                               º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpFile(cFile,cAlias)

	Local nHandle
	Local cBuffer := ""
	Local nFor	:= 0
	Local nX := 0
	Local lRet := .F.
	Local dArqtxt := ""  
	
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())	
	
	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	If nHandle = -1  
		MsgAlert(STR0005 + cFile + STR0006)	// El archivo	XXXXX no puede abrirse.
		return .F.	
	Else
		// Se posiciona en la primera línea
		FT_FGoTop()
		
		nFor := FT_FLastRec()
		
		ProcRegua(nFor)
		
		While !FT_FEOF()
			nX++
		
			nRecno := FT_FRecno()
			IncProc(STR0010 + str(nX))  //"Leyendo archivo. Espere..."
			cBuffer := FT_FReadLn() // lee cada línea del archivo
			cBuffer := Alltrim(cBuffer)
			aLinea  := {}
		
			//Se llena el arreglo con los datos por línea.
			aLinea := Separa(cBuffer,',',.t.)
			
			//Invierte la fecha de publicación y la compara contra la fecha de vigencia.
			//Si la fecha de vigencia es menor que la fecha de publicación, regresa falso.
			If nX==2 .And. Len(aLinea) == 1  .and.  SubStr(aLinea[1],1,1) == "#"
				dArqtxt:= CTOD(SubStr(aLinea[1],14,9))			
				If dFecVig < dArqtxt 
					MsgAlert(STR0007) //"Introduzca una fecha de vigencia mayor que la fecha de publicación del patrón."
					Return .F.
				EndIf			
			ElseIf Len(aLinea) >= 3 .And. SubStr(aLinea[1],1,1) <> "#"		
				Reclock(cAlias,.T.)
				(cAlias)->CUIT		:= aLinea[1]
				(cAlias)->FCHDTC    := aLinea[2]
				(cAlias)->FCHPUB	:= aLinea[3] 
				(cAlias)->(MsUnlock())
				lRet := .T.
		    Endif  		 
			FT_FSKIP() // Salta a siguiente línea
		EndDo
		
		// Fecha o Arquivo
		FT_FUSE()
		
	EndIf
				
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³ProcRegs     ºAutor  ³ Juan Glz Rivas     º Data ³  10/02/17   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Obtiene datos de tabla de clientes/provedor.                  º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ No hay retorno.                                               º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcRegs(nTipo,cAlias)

	Local cQuery := ""	
	Local cSA := IIF(nTipo == 2,InitSqlName("SA1"),InitSqlName("SA2"))
	Local cTmp := ""                              
  	Local nReg := 0
  	Local nI := 0
  	Local cClave := ""
  	Local cPref := IIF(nTipo == 2,"A1","A2")
  	Local nValor := 0
	
	// Seleccionar clientes/proveedores que no estén bloqueados cuyo CUIT no esté vacío y no hayan sido eliminados
	// para todas las filiales
	cTmp 	:= criatrab(nil,.F.)    
	cQuery := "SELECT R_E_C_N_O_, " + cPref + "_CGC, " + cPref + "_SITUACA "
	cQuery += "FROM " + cSA + " WHERE " + cPref + "_CGC != ' ' AND D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY " + cPref + "_CGC"
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
 
	Count to nCont
	(cTmp)->(dbGoTop())
        
   ProcRegua(nCont)
   
   //Mientras existan datos en la tabla
	While (cTmp)->(!eof())
		nI++
    	IncProc(STR0010 + str(nI))
    	//Obtiene el valor del CUIT a comparar.
    	cClave := (cTmp)->&(cPref+"_CGC")
		cClave := Replace(cClave, "-", "")    	
    	dbSelectArea(cAlias)
    	dbSetOrder(1)
    	
    	nValor := 1
    	// Se realiza la busqueda por CUIT en la tabla Temporal 
    	If (cAlias)->(dbSeek(cClave))
    		nValor := 4
    	End If    	
    	    	
    	nReg  := (cTmp)->R_E_C_N_O_
    	//Si el tipo es = 2, se busca en la tabla Clientes (SA1)
		If nTipo == 2
			//Si el campo es difente al valor que se quiere asignar.
			If ALLTRIM((cTmp)->A1_SITUACA) != ALLTRIM(STR(nValor))  
				//Bloquea, actualiza, libera.
				SA1->(DBGOTO(nReg))
				Reclock("SA1",.F.)
				SA1->A1_SITUACA := ALLTRIM(STR(nValor))
				lAct := .T.
				SA1->(MsUnlock())
			EndIf
		//Si el tipo es != 2, se busca en la tabla de Proveedores(SA2)
		Else
			//Si el campo es difente al valor que se quiere asignar.
			If ALLTRIM((cTmp)->A2_SITUACA) != ALLTRIM(STR(nValor))
				//Bloquea, actualiza, libera.
				SA2->(DBGOTO(nReg))
				Reclock("SA2",.F.)
				SA2->A2_SITUACA := ALLTRIM(STR(nValor))
				lAct := .T.
				SA2->(MsUnlock())
			EndIf
		EndIf
		//Siguiente registro
    	(cTmp)->(dbSkip())	    
    EndDo
    //Cierra la tabla.
    (cTmp)->(dbCloseArea()) 
Return
