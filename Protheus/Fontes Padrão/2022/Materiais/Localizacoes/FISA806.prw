#Include 'Protheus.ch'
#Include 'topconn.ch'
#Include 'FISA806.ch'

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Fun��o    �FISA806   � Autor � Juan Glz Rivas     � Data �  10/02/17        ���
������������������������������������������������������������������������������͹��
���Descricao � Importacion del padron de las facturas apocrifas.               ���
������������������������������������������������������������������������������͹��
���Uso       � Version 12                                                      ���
������������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              	   ���
������������������������������������������������������������������������������͹��
���Programador � Data   � BOPS    �  Motivo da Alteracao                       ���
������������������������������������������������������������������������������͹��
���LuisEnriquez�13-02-17�MMI-4171 �Se crea fuente para importaci�n de padr�n de���
���            �        �         �facturas apocrifas (s�lo exist�a para v11). ���
������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������� 
����������������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �FGetDir806   �Autor  � Juan Glz Rivas     � Data �  10/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.  � Muestra pantalla para seleccion de archivo.                   ���
�������������������������������������������������������������������������͹��
���Retorno� Nil                                                           ���
�������������������������������������������������������������������������͹��
���Uso    �                                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FGetDir806()
	Local cDir := ""
	
	cDir := cGetFile(,STR0003,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar archivo"
	If !Empty(cDir)
		MV_PAR03 := cDir
	Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �ValC806      �Autor  � Juan Glz Rivas     � Data �  10/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.  � Valida que los parametros hayan sido indicados.               ���
�������������������������������������������������������������������������͹��
���Retorno� Valor logico .T. o .F.                                        ���
�������������������������������������������������������������������������͹��
���Uso    �                                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ValC806()
	If  EMPTY(MV_PAR01) .Or. EMPTY(MV_PAR02) .Or. EMPTY(MV_PAR03)
		MsgAlert(STR0013)
		Return .F.
	EndIf
Return .T.
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �ImpArq       �Autor  � Juan Glz Rivas     � Data �  10/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.  � Procesa archivo y modifica datos.                             ���
�������������������������������������������������������������������������͹��
���Retorno� Nil                                                           ���
�������������������������������������������������������������������������͹��
���Uso    �                                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		
	//Manda mensaje dependiendo si se realiz� la actualizaci�n de registros o no.     
	If lAct
		MsgAlert(STR0008)
	Else
		MsgAlert(STR0009)
	End If 
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �ImpFile      �Autor  � Juan Glz Rivas     � Data �  10/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.  � Procesa el archivo .csv y llena tabla temporal TRD.           ���
�������������������������������������������������������������������������͹��
���Retorno� Valor .T. o .F.                                               ���
�������������������������������������������������������������������������͹��
���Uso    �                                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		// Se posiciona en la primera l�nea
		FT_FGoTop()
		
		nFor := FT_FLastRec()
		
		ProcRegua(nFor)
		
		While !FT_FEOF()
			nX++
		
			nRecno := FT_FRecno()
			IncProc(STR0010 + str(nX))  //"Leyendo archivo. Espere..."
			cBuffer := FT_FReadLn() // lee cada l�nea del archivo
			cBuffer := Alltrim(cBuffer)
			aLinea  := {}
		
			//Se llena el arreglo con los datos por l�nea.
			aLinea := Separa(cBuffer,',',.t.)
			
			//Invierte la fecha de publicaci�n y la compara contra la fecha de vigencia.
			//Si la fecha de vigencia es menor que la fecha de publicaci�n, regresa falso.
			If nX==2 .And. Len(aLinea) == 1  .and.  SubStr(aLinea[1],1,1) == "#"
				dArqtxt:= CTOD(SubStr(aLinea[1],14,9))			
				If dFecVig < dArqtxt 
					MsgAlert(STR0007) //"Introduzca una fecha de vigencia mayor que la fecha de publicaci�n del patr�n."
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
			FT_FSKIP() // Salta a siguiente l�nea
		EndDo
		
		// Fecha o Arquivo
		FT_FUSE()
		
	EndIf
				
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �ProcRegs     �Autor  � Juan Glz Rivas     � Data �  10/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.  � Obtiene datos de tabla de clientes/provedor.                  ���
�������������������������������������������������������������������������͹��
���Retorno� No hay retorno.                                               ���
�������������������������������������������������������������������������͹��
���Uso    �                                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	
	// Seleccionar clientes/proveedores que no est�n bloqueados cuyo CUIT no est� vac�o y no hayan sido eliminados
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
