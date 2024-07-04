#include 'fisa838.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"
#include "TOTVS.CH"

#DEFINE _SEPARADOR 		CHR(59)//09
#DEFINE	_CUIT	   		1
#DEFINE _ACTECONO	    3
#DEFINE _BUFFER 16384
#DEFINE _IMPUESTORET "IBR"
#DEFINE _ZONAFIS     "BA"


Function FISA838()

	Local cCombo	:= ""
	Local aCombo	:= {}
	Local oDlg		:= Nil
	Local oFld		:= Nil
    Local nYAux:=0

	Private cMes	:= StrZero(Month(dDataBase),2)
    Private cDiaIni	:="01" 
	Private cMesIni	:= StrZero(Month(dDataBase),2)
	Private cAnoIni	:= StrZero(Year(dDataBase),4)

    private dFechaFin :=LastDay(CTOD("01/"+cMesIni+"/"+cAnoIni))
    Private cDiaFin := StrZero(Day(dFechaFin),2)
	Private cMesFin	:= StrZero(Month(dDataBase),2)
	Private cAnoFin	:= StrZero(Year(dDataBase),4)
	Private cTabEqu	:= space(TamSX3("CCP_DESCR")[1])
	Private lRet	:= .T.
	Private lPer	:= .T.

	aAdd( aCombo, STR0002 ) //"1- Fornecedor"

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 350,450 OF oDlg PIXEL

	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"

	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)

//+----------------------
//| Campos Check-Up
//+----------------------

	@ 10,115 SAY STR0008 SIZE 065,008 PIXEL OF oFld //"Imposto: "

	//@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0009 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)  //"Percepcao"
	@ 020,115 CHECKBOX oChk2 VAR lRet PROMPT STR0010 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Retencao"
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,120 //"&Importação de Arquivo TXT"

//+----------------
//| Campos Folder 2
//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] 
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] 
                        "

    nYAux:=43
	@ nYAux,005 SAY STR0014  SIZE 150,008 PIXEL OF oFld:aDialogs[1] 
    @ nYAux,060 MSGET cTabEqu PICTURE "@!" VALID !Empty(cTabEqu) SIZE  90,008 PIXEL OF oFld:aDialogs[1] 

	nYAux:=60
	@ nYAux,005 SAY STR0032  SIZE 150,008 PIXEL OF oFld:aDialogs[1] 
    @ nYAux,060 MSGET cDiaIni PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1] 
    @ nYAux,075 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ nYAux,078 MSGET cMesIni PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1] 
	@ nYAux,093 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ nYAux,096 MSGET cAnoIni PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1] 
    @ nYAux,125 SAY STR0015 SIZE  150, 8 PIXEL OF oFld:aDialogs[1]

	
    nYAux:=75
	@ nYAux,005 SAY STR0033  SIZE 150,008 PIXEL OF oFld:aDialogs[1]
    @ nYAux,060 MSGET cDiaFin PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]
    @ nYAux,075 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ nYAux,078 MSGET cMesFin PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]
	@ nYAux,093 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ nYAux,096 MSGET cAnoFin PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1] 
    @ nYAux,125 SAY STR0015 SIZE  150, 8 PIXEL OF oFld:aDialogs[1]

//+-------------------
//| Boton de MSDialog
//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cCombo) //"&Importar"
	@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

	ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/{Protheus.doc} ValidChk
	funcion utilizada para validar el cambio de los valores del combo
	@type  bolean
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param oCombo,Objeto,combo que maneja el tipo de valor(retencion percepcion).
	@return bolean, , retorna true o false
	/*/
Static function ValidChk(cCombo)
	Local lAux := .T.
	If lRet == .T. .and. Subs(cCombo,1,1) $ "2|3"    // Cliente nao tem retenção!
		lRet :=.F.
		lAux := .F.
	EndIf
	If  lRet == .T. .and. lPer == .T. .and. (Subs(cCombo,1,1) $ "1" )
		lRet :=.F.
		lPer :=.F.
		lAux := .F.
	EndIf

	//oChk1:Refresh()
	oChk2:Refresh()

Return lAux

/*/{Protheus.doc} ImpArq
	funcion Inicializa a importacao do arquivo
	@type  VOID
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param aCombo,cCombo.
	@return nil
	/*/
Static Function ImpArq(aCombo,cCombo)

	Local   nPos     := 0
	Local aAreaCCP	:= CCP->(GetArea())

	Private cFile    := ""
	Private dDataIni := ""
	Private dDataFim := ""
	Private lFor     := .F.
	Private lCli     := .F.
	Private lImp     := .F.
	If Empty(Alltrim(cTabEqu)) 
		MsgStop(STR0034)
		Return Nil
	EndIf
	
	CCP->(dbSelectArea("CCP"))
	CCP->(DbSetOrder(1))
	If !(CCP->(MsSeek(xFilial("CCP") +ALLTRIM(cTabEqu)) ) )  //CCP_FILIAL+CCP_COD+CCP_VORIGE 
		MsgStop(STR0035)
		CCP->(RestArea(aAreaCCP))
		Return Nil
	EndIf
	CCP->(RestArea(aAreaCCP))
	
	nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
	If nPos == 1 // Fornecedor
		lFor := .T.
	ElseIf nPos == 2 // Cliente
		lCli := .T.
	ElseIf nPos == 3 // Ambos
		lFor := .T.
		lCli := .T.
	EndIf

	cFile := FGetFile()
	If Empty(cFile)
		MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf

	If !File(cFile)
		MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf
	If VldArch()
		MsAguarde({|| Import(cFile)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
	EndIf

	If (lImp )
		MsgAlert(STR0025,"") //"Arquivo importado!"
	EndIf
Return Nil

/*/{Protheus.doc} VldArch
	funcion utilizada para validar el archivo
	@type  bolean
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param .
	@return bolean, , retorna true si todo esta ok o nulo si no se tiene un archivo vacio o sin el separador.
	/*/

Static Function VldArch()

	Local cErro		:= STR0029
	Local cSolucao 	:= STR0031
	Local cTitulo	:= STR0001

	FT_FUSE(cFile)
	If !(_SEPARADOR $ (FT_FREADLN()))
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return Nil
	EndIf
	dDataIni := CTOD(cDiaIni+"/"+cMesIni+"/"+cAnoIni)
	dDataFim := CTOD(cDiaFin+"/"+cMesFin+"/"+cAnoFin)
	FT_FUSE()

Return .T.
/*/{Protheus.doc} FGetFile()
	funcion utilizada para llamar la pantalla de seleccion del archivo a importar
	@type  string
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param 
	@return cRet path del archivo
	/*/
Static Function FGetFile()

	Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0027,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0027,,.T.)//"Selecionar arquivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/{Protheus.doc} FGetDir()
	funcion utilizada para crear la pantalla de seleccion del archivo a importar
	@type  bolean
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param oTget  input para obtener path de archivo
	@return nil 
	/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	cDir := cGetFile(,STR0027,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*/{Protheus.doc} Import()
	funcion utilizada para visualizar el loading de carga , y la llamada de la GeraTemp para crear archivos temporales
	@type  bolean
	@author TOTVS
	@since 19/03/2021
	@version version 1
	@param cFile ruta del archivo a importar
	@return nil 
	/*/

Static Function Import(cFile)

	Local lReturn   	:= .T.
	Private lCoinAli    := .F.
	Private lGenera     := .F.
	Private cTable  	:= ""
	Private cAliasPdr := GetNextAlias()
	Private lAutomato := isblind()
	If!lAutomato
		Processa({|| lReturn := GeraTemp(cFile)})// cualquier base de datos
	Else
		GeraTemp(cFile)
	EndIf

	If !lReturn
		Return Nil
	EndIf

Return Nil

/*/{Protheus.doc} ProvCal()
	funcion utilizada para verificar los casos a validar para agregar o actualizar la tabla CGF
	@type  bolean
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param lPadron = True existe en padron  False no existe en padron , cMarca = valor a verificar en la Tabla de equivalencia
	@return nil 
	/*/

Static Function ProvCal(lPadron,cMarca)
	Local lCGF	:= .F. // Existe en CGF
	Local nAliq 		:= 0
	If lFor .and. lRet
		If lRet
			nAliq:=Iif((cMarca<>"0"),alicuota(cMarca,cTabEqu),0)
			If lPadron
				dbSelectArea("CGF")
				CGF->(dbSetOrder(5))
				CGF->(dbGoTop())

				cChave := xFilial("CGF")+Alltrim(cSA2->A2_COD) //CGF_FILIAL+CGF_FORNEC 
				If CGF->(MsSeek(cChave))
					nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,_IMPUESTORET,_ZONAFIS)
					If nRecFim >0
						lCGF := .T.
						CGF->(DbGoTo(nRecFim))
						
						If lCGF
							If CGF->CGF_ALIQ ==nAliq  //coincide alicuota 
								lCoinAli := .T.
							Else
								lGenera  := .T.   
							EndIf
						Else
							lGenera := .T.
						EndIf
					EndIf
				EndIf// fin cgf busq

				If lCGF
						If lCoinAli
							RecLock("CGF", .F.)
							CGF->CGF_FIMVIGE := dDataFim
							CGF->(MsUnlock())
						ElseIf lGenera
							ActCGF(CGF->CGF_FORNEC,CGF->CGF_LOJA,CGF->CGF_ZONFIS,CGF->CGF_IMPOST,nAliq,dDataIni,dDataFim,"A2")
						EndIf
				Else // no CGF
						ActCGF(cSA2->A2_COD,cSA2->A2_LOJA,_ZONAFIS,_IMPUESTORET,nAliq,dDataIni,dDataFim,"A2")
				EndIf
				CGF->(dbCloseArea())

			Else//  no padron
				dbSelectArea("CGF")
				CGF->(dbSetOrder(5))
				CGF->(dbGoTop())

				cChave := xFilial("CGF")+cSA2->A2_COD
				If CGF->(MsSeek(cChave))
					nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,_IMPUESTORET,_ZONAFIS)
					If nRecFim >0
						lCGF := .T.
						CGF->(DbGoTo(nRecFim))
						If lCGF
							If (Empty(CGF->CGF_FIMVIGE) .or. (CGF->CGF_FIMVIGE > dDataIni))  //esta vigente
								RecLock("CGF", .F.)
								CGF->CGF_FIMVIGE := dDataIni - 1
								CGF->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
				
			EndIf// fin padron
		EndIf// fin ret prove

		lCoinAli    := .F.
		lGenera     := .F.
		lCGF 		:= .F.
		lImp := .T.
	EndIf // fin prove

Return Nil
/*/{Protheus.doc} ActCGF
	funcion utilizada para actualizar la tabla CGF
	@type  bolean
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cCOD = Codigo Proveedor  cLoja = tienda,
		   cZonaFis = Zona  fiscal , cImpost = impuesto(IBR)
		   nAliq = alicuota, dDataIni= fecha inicio
		   dDataFim= fecha fin , cTable = origen de datos SA1 O SA2
	@return nil 
	/*/
Static Function ActCGF(cCOD,cLoja,cZonaFis,cImpost,nAliq,dDataIni,dDataFim,cTable)
	Default cLoja	:= ""
	Private lLojaCGF:= .T.
	Private lCodCGF := .T.
	Private cPrefixo := "->"+cTable+"_"
	cTable :="S"+cTable

	If Empty(cLoja)
		lLojaCGF := .F.
	EndIf
	If Empty(cCOD)//codigo proveedor o cliente
		lCodCGF := .F.
	EndIf

	If RecLock("CGF", .T.)
		CGF->CGF_FILIAL	:=  xFilial("CGF")
		CGF->CGF_ZONFIS	:= cZonaFis
		If cTable == "SA2"
			CGF->CGF_FORNEC := IIf(lCodCGF, cCOD , &(cTable+cPrefixo+"COD"))
		EndIf
		CGF->CGF_LOJA	:= IIf(lLojaCGF, cLoja, &(cTable+cPrefixo+"LOJA"))
		CGF->CGF_IMPOST	:= cImpost
		CGF->CGF_ALIQ	:= nAliq
		CGF->CGF_INIVIGE := dDataIni
		CGF->CGF_FIMVIGE := dDataFim
		CGF->(MsUnlock())
	EndIf
Return Nil
/*/{Protheus.doc} alicuota
	funcion utilizada para actualizar la tabla CGF
	@type  number
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cMarca = codigo a buscar en la tabla de equivalencia para obtener alicuota,
		   cTablaEq  = Nombre de la tabla de equivalencia
	@return nAliq retorno el valor de la alicuota para asignar  
	/*/
Static Function alicuota(cMarca,cTablaEq)
	Local aAreaCCP	:= CCP->(GetArea())
	Local nAliq := 0
	Local cAliq :=""
	CCP->(dbSelectArea("CCP"))
	CCP->(DbSetOrder(1))
	cMarca= AllTrim(cMarca)
	
	If (CCP->(MsSeek(xFilial("CCP") +ALLTRIM(cTablaEq)+cMarca) ) )  //CCP_FILIAL+CCP_COD+CCP_VORIGE 
			cAliq := ALLTRIM(CCP->CCP_VDESTI)
			cAliq := StrTran( cAliq, ",", "." )
			nAliq:=VAL(cAliq)
	EndIf
	
	CCP->(RestArea(aAreaCCP))
Return nAliq

/*/{Protheus.doc}MayorFech
	funcion utilizada para obtener el registro con fecha mayor en la tabla CGF
	@type  number
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cCod = codigo prooveedor cLoja = tienda,
		   cImpuesto = impuesto(IBR), cZonaFis = Zona  fiscal 
	@return nAliq retorno el valor de la alicuota para asignar  
	/*/

Static Function MayorFech(cCod,cLoja,cImpuesto,cZonaFis)

	Private dFecAnt := ""
	Private nAux :=0
	Private cTipoClie :=""
	Private nAuxIni :=0
	cTipoClie="CGF_FORNEC"
	
	cQuery	:= ""
	cQuery := "SELECT  CGF_FIMVIG AS FECHA,R_E_C_N_O_ AS NUM,CGF_INIVIG AS INI"
	cQuery += " FROM " + RetSqlName("CGF")
	cQuery += " WHERE CGF_FILIAL = '" + xFilial("CGF") + "'"
	cQuery += " AND "+cTipoClie+" = '"+cCod+"'"
	cQuery += " AND CGF_LOJA ='"+cLoja+"'"
	cQuery += " AND CGF_IMPOST ='"+cImpuesto+"'"
	cQuery += " AND CGF_ZONFIS  ='"+cZonaFis+"'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTMayor", .T., .T.)

	cTMayor->(dbGoTop())
	Do While cTMayor->(!EOF())
		If cTMayor->FECHA > dFecAnt
			nAux := cTMayor->NUM
			dFecAnt := cTMayor->FECHA
		EndIf

		If(DTOS(dDataIni) == cTMayor->INI)
			nAuxIni :=cTMayor->NUM
		EndIf
		cTMayor->(dbSkip())
	EndDo
	If(nAuxIni<>0)
		nAux :=nAuxIni
	EndIf
	cTMayor->(dbCloseArea())
Return nAux

/*/{Protheus.doc}GeraTemp
	funcion utilizada para crear las tabla temporal de la SA2 y prosigue a verificar si los casos en ProvCal
	@type  bolean
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cFile = ruta del archivo 
	@return lReturn true no existe problemas false existe problemas 
	/*/

Static Function GeraTemp(cFile)
	Local cArqProc   := cFile	// Arquivo a ser importado selecionado na tela de Wizard
	Local cErro	     := ""		// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
	Local cSolucao   := ""		// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
	Local lArqValido := .T.		// Determina se o arquivo  esta ok para importacao
	Local cTitulo	 := STR0001  //"Problemas en la importación del archivo"
	Local cQuery	:= ""
	Local nRegs			:= 0
	Local nTotal		:= 0
	Local lReturn    := .T.
	Local nLineasA2  :=0

	If lFor .and. (lRet)
		cQuery	:= ""
		cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC"
		cQuery += " FROM " + RetSqlName("SA2")
		cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "'"
		cQuery += " AND A2_CGC <> ''"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY A2_CGC ASC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cSA2", .T., .T.)
		cSA2->(dbGoTop())
		count to nRegs
		nLineasA2 := nRegs
		cSA2->(dbGoTop())
		nTotal += nRegs
	EndIf
	If File(cArqProc)
		lArqValido := CreaTabla(cArqProc)
		If lArqValido
			If lFor .and. lRet
				
				While cSA2->(!EOF())
					If (cAliasPdr)->(MsSeek(AllTrim(cSA2->A2_CGC)))
						ProvCal(.T.,(cAliasPdr)->MARCAMAYOR)
					Else
						ProvCal(.F.,"0")
					EndIf
					cSA2->(dbSkip())
				Enddo
			EndIf
			(cAliasPdr)->(dbCloseArea())
		Else
			cErro	   := STR0023 + cArqProc + STR0024	//"El archivo " +cArqProc+ "No puede abrirse"
			cSolucao   := STR0029 						//"Verifique se foi informado o arquivo correto para importação"
		EndIf
		If lFor .and. (lRet)
			cSA2->(dbCloseArea())
		EndIf
		If !Empty(cErro)
			xMagHelpFis(cTitulo,cErro,cSolucao)
			lReturn := .F.
		Endif
	EndIf
Return(lReturn)

/*/{Protheus.doc}CreaTabla
	funcion utilizada para la carga de datos que proviene del archivo
	@type  bolean
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cFile = ruta del archivo 
	@return lRetu true no existe problemas false existe problemas 
	/*/
Static Function CreaTabla(cArqProc)
	Local aInforma	:= {} 		// Array auxiliar com as informacoes da linha lida no arquivo XLS
	Local cMsg		:= STR0019 //"Leyendo archivo. Espere..."
	Local cVersion	:= FwLibVersion()
	Local cBuild	:= TCGetBuild()
	Local nHandle	:= 0		// Numero de referencia atribuido na abertura do arquivo XLS
	Local aStruct 	:= {}
	Local nTotLin 	:= 0
	Local nI 		:= 0
	Local lRetu		:= .T.
	Local oFile

	aAdd( aStruct, { 'CUIT',  'C', 14,0 } )
	aAdd( aStruct, { 'MARCAMAYOR','C', 1,0 } )
	aAdd( aStruct, { 'NOMBRE', 'C', 250,0 } )

	nHandle := FT_FUse(cArqProc)
	If nHandle == -1
		lRetu := .F.
	Else
		nTotLin := FT_FLASTREC()
		FT_FUSE()
		If Select(cAliasPdr) <> 0
			(cAliasPdr)->(dbCloseArea())
		EndIf
		If TCCanOpen(cAliasPdr)
			If TcSqlExec("DROP TABLE " + cAliasPdr) <> 0
				If !TCDelFile(cAliasPdr)
					MsgAlert(STR0021)
					lRetu := .F.
				EndIf
			EndIf
		EndIf
		If cBuild  >= "20181212" .and. cVersion >= "20201009"
			FWDBCreate(cAliasPdr, aStruct , 'TOPCONN' , .T.)
			oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
			If !oFile:Open()
				MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
				Return .F.
			EndIf
			oBulk := FwBulk():New(cAliasPdr,600)
			lCanUseBulk := FwBulk():CanBulk() // Este método não depende da classe FWBulk ser inicializada por NEW
			If lCanUseBulk
				oBulk:SetFields(aStruct)
				ProcRegua(nTotLin)
				While oFile:ReadArray(@aInforma,_SEPARADOR)
					If Len(aInforma) == 3
						oBulk:AddData(aInforma)
					EndIf
					aSize(aInforma,0)
					nI++
					IncProc(cMsg + str(nI))
				EndDo		
				If !Empty(oFile:_Resto)
					aInforma:=Separa(oFile:_Resto,_SEPARADOR)
					If Len(aInforma) == 3
						oBulk:AddData(aInforma)
					EndIf
					aSize(aInforma,0)
				EndIf
				oBulk:Close()
				oBulk:Destroy()
				oBulk := nil
			EndIf
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
			oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
			If !oFile:Open()
				MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
				Return .F.
			EndIf
			ProcRegua(nTotLin)
			dbSelectArea(cAliasPdr)
			While oFile:ReadArray(@aInforma,_SEPARADOR)
				nI ++
				IncProc(cMsg + str(nI))
				
				If Len(aInforma) == 3
					RecLock(cAliasPdr,.T.)
					(cAliasPdr)->CUIT		:= aInforma[1]
					(cAliasPdr)->MARCAMAYOR	:= aInforma[2]
					(cAliasPdr)->NOMBRE	:= aInforma[3]
					(cAliasPdr)->(MsUnLock())
				EndIf
			End
		EndIf
	EndIf
Return lRetu

/*/{Protheus.doc} FIS838AUT
	funcion utilizada en la automatizacion de la fisa838
	@type  void
	@author Adrian Perez Hernandez
	@since 19/03/2021
	@version version 1
	@param cArchivo,caracter,ruta del padron a cargar.
	@return nil, nil, no retorna nada
	/*/
Function FIS838AUT(cArchivo)
	IF FILE(cArchivo)
		Import(cArchivo)
	EndIf
Return nil
