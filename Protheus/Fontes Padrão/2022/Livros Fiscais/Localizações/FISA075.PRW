#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA075.CH"
#INCLUDE "REPORT.CH"

//Es necsario agregar la rutina FISA818.prw con esta rutina.

#DEFINE _SEPARADOR ";"
#DEFINE _BUFFER 16384


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FISA075  ³ Autor ³ Emanuel Villicaña     ³ Data ³24/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Replica llamado THDEZB DE P10 (FISA071)                    ³±±
±±³Descri‡…o ³ IIBB - Padron de Retencion de la Provincia de Mendoza.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 y se cambia la³±±
±±³            ³        ³          ³actualizacion al parametro MV_RETMZCF ³±±
±±³            ³        ³          ³por PUTMV en las funciones  UPDDATA() ³±±
±±³            ³        ³          ³y ActParam() por motivo deadecuacion a³±±
±±³            ³        ³          ³fuentes a nuevas estructuras SX para  ³±±
±±³            ³        ³          ³Version 12.                           ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		          ³±±
±±³Alf. Medrano³29/12/16³SERINN001-544³creación de tabla temporal con     ³±±
±±³            ³        ³          ³FWTemporaryTable en func ProcArc()    ³±±
±±³            ³        ³          ³se incializa y se limpia obj oTmpTable³±±
±±³            ³        ³          ³en func FISA075.                      ³±±
±±³Alf. Medrano³12/01/17³SERINN001-544³MERGE MAIN vs 12.1.15              ³±±
±±³LuisEnriquez³18/05/17³MMI-4536  ³Merge Main vs v12.1.14 Est. MI (ARG)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FISA075()
	Local aArea		:= GetArea()
	Local cTitulo		:= STR0001 //"IIBB - Padron de Retencion de la Provincia de Mendoza"
	Local cMsg1		:= STR0002 //"Este programa lee el archivo del Padron de Retencion - Provincia de Mendoza y en base "
	Local cMsg2		:= STR0003 //"a este archivo actualiza la información en el sistema. Se deben indicar los parámetros "
	Local cMsg3		:= STR0004 //"parámetros necesarios. "
	Local cMsg4     	:= STR0009 //"Ultimo proceso: "
	
	Local cPerg		:= "FISA075"
	Private dFchPro := Ctod("//")	
	Private aProvAct:= {}
	Private cFecPr	 := GetMv("MV_RETMZFC",,"//")
	Private cFilCCP := xFilial("CCP") 
	Private 	oTmpTable

	If !Isblind()
		Private nOpca := 0		
		Private cFile   := ""
		Private cTabAct := ""
		Private cOpcMod := ""		
	EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface com o usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	MV_PAR01 = Ruta de padron
	MV_PAR02 = Tabla de equivalencia de actividades
	MV_PAR03 = Opcion  de tipo a procesar (Cliente/Proveedor/Ambos)
	*/
	If !Isblind()

		Pergunte(cPerg,.F.)

		FormBatch(cTitulo,{OemToAnsi(cMsg1),OemToAnsi(cMsg2),OemToAnsi(cMsg3),OemToAnsi(cMsg4)+ " " + cFecPr},;
			{ { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
			{ 1,.T.,{|o| nOpcA := 1,o:oWnd:End()}},;
			{ 2,.T.,{|o| nOpca := 2,o:oWnd:End()}}})
		cFile   := MV_PAR01
		cTabAct := MV_PAR02
		cOpcMod := MV_PAR03
	EndIf		

	If ( nOpcA==1 )
		dFchPro := dDatabase
		ProcArc()
		ActParam("MV_RETMZFC",dtoc(dDatabase))
	Endif
   
   If oTmpTable <> Nil  
		oTmpTable:Delete() 
		oTmpTable := Nil 
	Endif
	RestArea(aArea)
Return


	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ProcArc  ³ Autor ³ Laura Medina        ³ Data ³ 14/11/13   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Procesa archivo y modifica datos				              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³												    		  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Fiscal - Buenos Aires Argentina 			                  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function ProcArc()
	Local nPos 	:= 0
	Local cLine 	:= ""
	Local cTmp		:= "TRD"
	Local cArq		:= ""
	Local aStru	:= {}
	Local nOpc
	Local lImp		:= .F.
	Local lAct     := .F.
	Local cTitulo 	:= ""
	Private lArcInv := .T.
	
	dbselectarea("CGF")
	
	IF  File(cFile) .And. !Empty(cFile)
	//creamos la tabla temporal
		AADD(aStru,{ "CUIT"    , "C",  14, 0})
		AADD(aStru,{ "NO_INSCR", "C",  10, 0})
		AADD(aStru,{ "TIPO"    , "C"	,   3, 0})
		AADD(aStru,{ "COD_ACT" , "C",   6, 0})
		AADD(aStru,{ "FCH_INIA", "D",   8, 0})
		AADD(aStru,{ "ALIQ_ACT", "N",   5, 0})
		AADD(aStru,{ "TASACERO", "C",   1, 0})
		AADD(aStru,{ "RIESGO"  , "C",   1, 0})
		AADD(aStru,{ "FCH_INIR", "D",   8, 0})
		AADD(aStru,{ "FCH_FINR", "D",   8, 0})
		
		oTmpTable := FWTemporaryTable():New('TRD')
		oTmpTable:SetFields( aStru ) 
		//crea indice
		oTmpTable:AddIndex('T1ORD', {'CUIT'})
		//Creacion de la tabla
		oTmpTable:Create()
		
		// "Procesando archivo padrón..."				
		Processa( {|| lImp:=LeeArch(cFile,"TRD")}, STR0005,STR0006, .T. )
		
		If lImp // Si el archivo fue procesado
			Processa( {|| lAct:=RunProc("TRD")}, STR0014,STR0014, .T. )
		EndIf		                             
	EndIf

	If !lArcInv
		MsgAlert(STR0023) //"Archivo invalido."
	Else
		If  lAct
			MsgInfo(STR0010)  //"Proceso finalizado con éxito!"
			ImpReport(STR0012,aProvAct)         //Reporte con los Proveedores Actualizados
		Else
			MsgAlert(STR0011)  //"El proceso no finalizo correctamente, verifique el archivo."
		EndIf
	EndIf
Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LeeArch  ³ Autor ³ Laura Medina        ³ Data ³ 14/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa el archivo de texto -Padron- y coloca su contenido ³±±
±±³          ³ en la tabla temporal TRD.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeeArch(cFile,cAlias)

	Local cBuffer	:= ""
	Local nFor		:= 0
	Local nHandle
	Local nX		:= 0
	Local lRet      := .F.
	Local aLinea    := {}
	Local nloop     := 0
	Local ctemp	:= ""
	Local cTipo	:= ""
	Local oFile
	Local aRegistro:=""
	Local nAux:=0
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())

	nHandle := FT_FUse(cFile)
	If  nHandle = -1
		MsgAlert(STR0007 + cFile + STR0008)  //"El archivo" CGF "no puede abrirse."
		Return .F.
	EndIf
	//Se posiciona en la primera línea
	FT_FGoTop()
	nFor := FT_FLastRec()
	// Fecha o Arquivo
	FT_FUSE()
	
	
	oFile := FWFileReader():New(cFile)
	// Se hay error al abrir el archivo
	If !oFile:Open()
		MsgAlert(STR0007 + cFile + STR0008)  //"El archivo" CGF "no puede abrirse."
		Return .F.
	EndIf
		
	ProcRegua(nFor)
	oFile:setBufferSize(_BUFFER)
	While (!oFile:Eof())
		nX++
	
		IncProc(STR0006 + str(nX))  //"Procesando archivo..."
		cBuffer := oFile:GetLine()
		cBuffer := Alltrim(cBuffer)
		aLinea  := {}
		
		aLinea := separa(cBuffer,_SEPARADOR)

		If Len(aLinea) >= 3
				cTipo = Alltrim(aLinea[3]) 
				cTipo = IIF(cTipo = "CM","V",IIF(cTipo = "M","M",IIF(cTipo $ "R|P","","I")))
		Else
			lArcInv := .F.
			lRet := .F.
			Exit
		EndIf
		If  !Empty(aLinea) .And. (Substr(aLinea[1],3,1)=="-" .And. Substr(aLinea[1],12,1)=="-") //Solo procesa CUITS validos
			TRD->( DBAppend( .F. ) )
				TRD->CUIT    := REPLACE(aLinea[1],"-","")
				TRD->NO_INSCR:= aLinea[2]
				TRD->TIPO    := cTipo
				TRD->COD_ACT := aLinea[4]
				TRD->FCH_INIA:= CTOD(aLinea[5])
				TRD->ALIQ_ACT:= VAL(Iif(!Empty(aLinea[6]),aLinea[6],"0"))
				TRD->TASACERO:= aLinea[7]
				TRD->RIESGO  := aLinea[8]
				TRD->FCH_INIR:= CTOD(Iif(Empty(aLinea[9]),"//",aLinea[9]))
				TRD->FCH_FINR:= CTOD(Iif(Empty(aLinea[10]),"//",aLinea[10]))
			TRD->( DBCommit() )
			
			lRet := .T.
		EndIf		
	
	End
		If !Empty(oFile:XLINEBUFFER)
			//registros sobrantes
			aSize(aLinea,0)
			aRegistro:=Separa(oFile:XLINEBUFFER,(CHR(10)))
			For nAux:=1 to len(aRegistro)
				//linea colunas
				aLinea:=Separa(aRegistro[nAux],_SEPARADOR)
				If  !Empty(aLinea) .And. (Substr(aLinea[1],3,1)=="-" .And. Substr(aLinea[1],12,1)=="-") //Solo procesa CUITS validos
					TRD->( DBAppend( .F. ) )
					TRD->CUIT    := REPLACE(aLinea[1],"-","")
					TRD->NO_INSCR:= aLinea[2]
					TRD->TIPO    := cTipo
					TRD->COD_ACT := aLinea[4]
					TRD->FCH_INIA:= CTOD(aLinea[5])
					TRD->ALIQ_ACT:= VAL(Iif(!Empty(aLinea[6]),aLinea[6],"0"))
					TRD->TASACERO:= aLinea[7]
					TRD->RIESGO  := aLinea[8]
					TRD->FCH_INIR:= CTOD(Iif(Empty(aLinea[9]),"//",aLinea[9]))
					TRD->FCH_FINR:= CTOD(Iif(Empty(aLinea[10]),"//",aLinea[10]))
					TRD->( DBCommit() )
			
					lRet := .T.
				EndIf
				aSize(aLinea,0)
			Next			
			aSize(aRegistro,0)
		EndIf
	
	
	TRD->(dbGoTop())
		
	// Fecha o Arquivo
	oFile:Close()		
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunProc  ³ Autor ³ Laura Medina        ³ Data ³ 15/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion que realiza el proceso para reducir el padrón MZ vs³±±
±±³          ³ los registros existentes.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Alias te la tabla temporal                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RunProc(cAlias)
	Local aArea	:= GetArea()
	Local lRet      := .T.
	Private cTmp		:= criatrab(nil,.F.)
	Private cTmpCli		:= criatrab(nil,.F.)
	Private aEstSFH := {}
	Private aSFHTemp := {}
	Private lRgoFin := .F.
	Private lActSFH := .F.
    
	aEstSFH := SFH->(DBSTRUCT())		
    
	If cOpcMod == 1 
		UpdCli(cAlias)
	EndIf
	
	TRD->(dbCloseArea()) // Cierra tabla temporal
	
	UpdData() // Actualiza parámetro MV_RETMZFC
	
	RestArea( aArea )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ UpdProv  ³ Autor ³ Raul Ortiz          ³ Data ³ 18/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion que realiza el proceso para reducir el padrón MZ vs³±±
±±³          ³ los proveedores existentes (SA2).                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Alias te la tabla temporal                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UpdProv(cAlias)
	Local cQuery	:= ""
	Local cSA2		:= InitSqlName("SA2")
	Local nI		:= 0
	Local cClave	:= ""
	Local cLlave  := ""
	Local cCodFis	:= ""
	Local cCodAct := ""
	Local lPrimera := .F.
	Local lExistEmp := .F.
	Local cCodFisEmp	:= ""
	Local cCodActEmp := ""
	Local lRiesgoEmp := .F.
	Local lTasaEmp := .F.
	Local nContProv := 0
	Local aEmpDatos := {}
	Local nEmp := 0
	
	Private dDesde := CTOD("//")
	Private dHasta := CTOD("//")
	Private cTipoEmp := ""
	
	Dbselectarea("SFH")
	DbSelectArea("TRD")
	DbSetOrder(1)
	Dbselectarea("CCP")
	DbSetOrder(1)

	//Ejecuta query en (SA2) en donde se seleccionen proveedores activos, cuit no vacío, no eliminados		
	//para todas las filiales y ordernados por CUIT
		
	cQuery := "SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME, A2_CGC, A2_MSBLQL "
	cQuery += "FROM "
	cQuery += cSA2 + " SA2 "
	cQuery += "WHERE "
	cQuery += "A2_MSBLQL <> '1'  AND "
	cQuery += "A2_CGC <> ' ' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery	+= "ORDER BY A2_CGC "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	
	lExistEmp := ProcEmp(cAlias,@cCodActEmp,@cCodFisEmp,@lRiesgoEmp,@lTasaEmp,@aEmpDatos)
	
	Count to nContProv
	(cTmp)->(dbGoTop())
	        
	ProcRegua(nContProv)
	While (cTmp)->(!eof())
		lRgoFin := .F.
		lActSFH := .F.
		cCodFis := ""
		cCodAct := ""
		nI++
		IncProc(STR0013	 + str(nI))
		
		// Se localiza ultimo reg de este cuit en tabla temporal y 
		// retorna el ultimo codigo actividad
		cLlave  := (cTmp)->A2_CGC
		dbSelectArea("TRD")
		lPrimera := .F.
		
		If lExistEmp
			For nEmp := 1 to Len (aEmpDatos)
				UpdSFHPer("E","A2",cTmp,aEmpDatos[nEmp][3],aEmpDatos[nEmp][2],.T.,aEmpDatos[nEmp][4],aEmpDatos[nEmp][1],aEmpDatos[nEmp][5],aEmpDatos[nEmp][6],aEmpDatos[nEmp][7])
			Next
		Else
			UpdSFHPer("E","A2",cTmp,.F.,.F.,.F.,"","")
		EndIf
		
		lActSFH := .F.		
		If TRD->(MsSeek(cLlave))
			dbSelectArea("CCP")
			dbSetOrder(1)
			While  TRD->(!eof()) .and. cLlave == TRD->CUIT
				cCodAct := TRD->COD_ACT
				cClave := (cTmp)->A2_FILIAL+(cTmp)->A2_COD+(cTmp)->A2_LOJA								
				If CCP->(MsSeek(cFilCCP + cTabAct + TRD->COD_ACT))
					cCodFis := CCP->CCP_VDESTI
				Else
					cCodFis := ""
				EndIf
				UpdSFH(cTmp,Iif(TRD->TASACERO=="A",.T.,.F.),Iif(TRD->RIESGO=="S",.T.,.F.),.T.,cCodFis,cCodAct)
				TRD->(dbSkip())
			Enddo
		Else  //El CUIT (Proveedor) no existe en el Padron
			UpdSFH(cTmp,.F.,.F.,.F.,cCodFis,cCodAct)
		Endif
    	
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

	If !Empty(aProvAct) //Generar el log de Proveedores actualizados para mostrar al usuario.

	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ UpdCli   ³ Autor ³ Raul Ortiz          ³ Data ³ 18/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion que realiza el proceso para reducir el padrón MZ vs³±±
±±³          ³ los clientes existentes (SA1).                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Alias te la tabla temporal                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function UpdCli(cAlias)
	Local cQuery	:= ""
	Local cSA1		:= InitSqlName("SA1")
	Local nI		:= 0
	Local cClave	:= ""
	Local cLlave  := ""
	Local cCodFis	:= ""
	Local cCodAct := ""
	Local lPrimera := .F.
	Local lExsInd:= .F.
	
	Dbselectarea("SFH")
	DbSelectArea("TRD")
	DbSetOrder(1)
	Dbselectarea("CCP")
	DbSetOrder(1)

	//Ejecuta query en (SA2) en donde se seleccionen proveedores activos, cuit no vacío, no eliminados		
	//para todas las filiales y ordernados por CUIT
		
	cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_MSBLQL "
	cQuery += "FROM "
	cQuery += cSA1 + " SA1 "
	cQuery += "WHERE "
	cQuery += "A1_MSBLQL <> '1'  AND "
	cQuery += "A1_CGC <> ' ' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery	+= "ORDER BY A1_CGC "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpCli,.T.,.T.)
	 
	Count to nCont
	(cTmpCli)->(dbGoTop())
	        
	ProcRegua(nCont)
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	
	While (cTmpCli)->(!eof())
		lRgoFin := .F.
		lActSFH := .F.
		nI++
		IncProc(STR0013	 + str(nI))
		
		If (cAlias)->(MsSeek((cTmpCli)->A1_CGC))
			dbSelectArea("CCP")
			lExsInd:= FWSIXUtil():ExistIndex( "CCP" , "2" )
			If lExsInd
				dbSetOrder(2)
			Else
				dbSetOrder(1)
			EndIf
			While  (cAlias)->(!eof()) .and. (cTmpCli)->A1_CGC == (cAlias)->CUIT
				cCodAct := TRD->COD_ACT
				If CCP->(MsSeek(cFilCCP + cTabAct + TRD->COD_ACT))				
					cCodFis := CCP->CCP_VORIGE
				Else
					cCodFis := ""
				EndIf
				If !Empty(cCodFis)
					UpdSFHPer("C","A1",cTmpCli,Iif(TRD->TASACERO=="A",.T.,.F.),Iif(TRD->RIESGO=="S",.T.,.F.),.T.,cCodFis,cCodAct)
				EndIf	
				TRD->(dbSkip())
			Enddo
		Else
			UpdSFHPer("C","A1",cTmpCli,Iif(TRD->TASACERO=="A",.T.,.F.),Iif(TRD->RIESGO=="S",.T.,.F.),.F.,cCodFis,cCodAct)
		EndIf
		(cTmpCli)->(dbSkip())
	EndDo

	(cTmpCli)->(dbCloseArea())   
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ UpdSFH   ³ Autor ³ Laura Medina        ³ Data ³ 15/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion para actualizar la tabla de Ingresos Brutos - SFH  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UpdSFH(cAlias,lEsTasa,lEsRiesgo,lExPadron,cCodFis,cCodAct)
	Local aArea	:= GetArea()
	Local cQuery	:= ""
	Local cSFH		:= InitSqlName("SFH")
	Local cTmp		:= criatrab(nil,.F.)
	Local aTmp		:= {}
	Local nReg		:= 0
	Local aStrut	:= getStruct("SFH")
	Local j			:= 0
	Local lExisSFH  := .F.
	Local lNoRgo    := .F.
	Local lEsRgo    := .F.
	Local nRecCGF   := 0
	Local nPos      := 0
	Local nsCon     := 0
	
	If !lActSFH     
	    //Seleccionar cliente o proveedor de SFH  
		cQuery := "SELECT *  "
		cQuery += "FROM "+ cSFH + " SFH "
		cQuery += "WHERE FH_FILIAL  = '" + (cAlias)->A2_FILIAL +"' AND "
		cQuery += "      FH_FORNECE = '" + (cAlias)->A2_COD + "' AND " //Codigo del Proveedor
		cQuery += "      FH_LOJA    = '" + (cAlias)->A2_LOJA + "' AND "
		cQuery += "      FH_ZONFIS  = 'ME' AND "
		cQuery += "      FH_IMPOSTO = 'IBR' AND "
		cQuery +=		"D_E_L_E_T_ = ' ' "
		cQuery	+=	"ORDER BY  FH_FIMVIGE DESC  "
		
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
		TCSetField(cTmp,"FH_INIVIGE","D")
		TCSetField(cTmp,"FH_FIMVIGE","D")
		(cTmp)->(dbGoTop())

		Count to nsCon
		(cTmp)->(dbGoTop())
		
		If nsCon > 0
			If nsCon > 1
				(cTmp)->(dbskip(nsCon - 1))
				IF (cTmp)->FH_FIMVIGE <> CTOD("//")
					(cTmp)->(dbGoTop())		
				EndIf	
			EndIf
			
			If lExPadron .and. lEsTasa .and. (cTmp)->FH_FIMVIGE > dFchPro .and. (cTmp)->FH_SITUACA = "2"
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmp)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_SITUACA := "1"
					SFH->FH_INIVIGE := SFH->FH_FIMVIGE + 1
					SFH->FH_FIMVIGE	:= CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.			
			ElseIf lEsRiesgo .and. lExPadron .and. ((cTmp)->FH_FIMVIGE == CTOD('//') .OR. (cTmp)->FH_FIMVIGE >= dFchPro) .and. (cTmp)->FH_SITUACA<>"2" .and. !lRgoFin// Busca registro con FH_FIMVIGE Vació o Mayor a la fecha de Proceso
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))		
				Reclock("SFH",.F.)
					SFH->FH_SITUACA := "2"
					SFH->FH_INIVIGE :=  IIF(TRD->FCH_INIR <> CTOD('//'),TRD->FCH_INIR,CTOD('//')) 
					SFH->FH_FIMVIGE :=  IIF(TRD->FCH_FINR <> CTOD('//'),TRD->FCH_FINR,CTOD('//')) 
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.
			ElseIf lEsRiesgo .and. lExPadron .and. (cTmp)->FH_FIMVIGE == CTOD('//') .And. (cTmp)->FH_SITUACA == "2" .and. TRD->FCH_FINR <> CTOD("//")
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := TRD->FCH_FINR 
					SFH->FH_TIPO := TRD->TIPO
				Msunlock()
				
				Reclock("SFH",.T.)
				For j:=1 To Len(aStrut)
					If ColumnPos(aStrut[j]) > 0
						FieldPut(ColumnPos(aStrut[j]),(cTmp)->&(aStrut[j]))
					EndIf
				Next j
				SFH->FH_SITUACA := ""
				SFH->FH_INIVIGE	:= CTOD("//")
				SFH->FH_FIMVIGE	:= CTOD("//")
				MsUnlock()
				lRgoFin := .T.
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.
			ElseIf !lExPadron .and. (cTmp)->FH_FIMVIGE == CTOD('//') .and. (cTmp)->FH_SITUACA == "2" // Busca registro con FH_FIMVIGE Vacio
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))		
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE :=  dFchPro-1
				MsUnlock()
	
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmp)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_SITUACA := ""
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE	:= CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.
			ElseIf lExPadron .and. AllTrim(TRD->TIPO) <> ""
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				If !VldVigSFH(TRD->TIPO, lEsTasa)
					Reclock("SFH",.F.)
						SFH->FH_TIPO := TRD->TIPO
					MsUnlock()
				EndIf	
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.	
			EndIf
		Else
			If lEsRiesgo .and. lExPadron 
				InsertSFH(2)
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.
			ElseIF lExPadron
				InsertSFH(1)
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->A2_NOME+(cAlias)->A2_CGC})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->A2_NOME,(cAlias)->A2_CGC })
				Endif
				lActSFH := .T.
			EndIf
		EndIf
		(cTmp)->(dbCloseArea())
	EndIf
	If (lExPadron .and. AllTrim(cCodFis) <> "" .and. AllTrim(cCodAct) <> "") .or. !lExPadron
		ChkCGFPer(2,(cAlias)->A2_COD,(cAlias)->A2_LOJA,cCodAct,lExPadron,lEsTasa,cCodFis,.T.,(cAlias)->A2_CGC,(cAlias)->A2_NOME)
	EndIf
	RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ UpdSFHPer ³ Autor ³ Raul Ortiz          ³ Data ³ 19/11/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea registro en la 	tabla SFH o lo modifica               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 Static Function UpdSFHPer(cOrig,cSA,cAlias,lEsTasa,lEsRiesgo,lExPadron,cCodFis,cCodAct,dDesde,dHasta,cTipoEmp)
	Local aArea	:= GetArea()
	Local cQuery	:= ""
	Local cSFH		:= InitSqlName("SFH")
	Local cTmpSFH		:= criatrab(nil,.F.)
	Local aTmp		:= {}
	Local nReg		:= 0
	Local aStrut	:= getStruct("SFH")
	Local j			:= 0
	Local lExisSFH  := .F.
	Local lNoRgo    := .F.
	Local lEsRgo    := .F.
	Local nRecCGF   := 0
	Local nPos      := 0
	Local nsCon     := 0
	
	Default dDesde := CTOD("//")
   	Default dHasta := CTOD("//")
   	Default cTipoEmp := ""
   
   If !lActSFH 
	    //Seleccionar cliente o proveedor de SFH  
		cQuery := "SELECT *  "
		cQuery += "FROM "+ cSFH + " SFH "
		cQuery += "WHERE FH_FILIAL  = '" + xFilial("SFH") +"' AND "
		If cOrig == "C"
			cQuery += "      FH_CLIENTE = '" + (cAlias)->&(cSA +"_COD") + "' AND " //Codigo del Proveedor
		ElseIf (cOrig == "P" .or. cOrig == "E" )
			cQuery += "      FH_FORNECE = '" + (cAlias)->&(cSA +"_COD") + "' AND " //Codigo del Proveedor
		EndIf
		cQuery += "      FH_LOJA    = '" + (cAlias)->&(cSA +"_LOJA") + "' AND "
		cQuery += "      FH_ZONFIS  = 'ME' AND "
		cQuery += "      FH_IMPOSTO = 'IBF' AND "
		cQuery +=		"D_E_L_E_T_ = ' ' "
		cQuery	+=	"ORDER BY  FH_FIMVIGE DESC  "
		
		cQuery := ChangeQuery(cQuery)
	
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSFH,.T.,.T.)
		TCSetField(cTmpSFH,"FH_INIVIGE","D")
		TCSetField(cTmpSFH,"FH_FIMVIGE","D")
		(cTmpSFH)->(dbGoTop())
		
		Count to nsCon
		(cTmpSFH)->(dbGoTop())
		If nsCon > 0
			If nsCon > 1
				(cTmpSFH)->(dbskip(nsCon - 1))
				IF (cTmpSFH)->FH_FIMVIGE <> CTOD("//")
					(cTmpSFH)->(dbGoTop())		
				EndIf	
			EndIf
			
			If (cOrig == "C" .or. cOrig == "E")  .and. lExPadron .and. lEsTasa .and. (cTmpSFH)->FH_FIMVIGE > dFchPro .and. (cTmpSFH)->FH_SITUACA = "2"
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmpSFH)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_TIPO := IIF(cOrig == "E",cTipoEmp,TRD->TIPO)
					SFH->FH_SITUACA := "1"
					SFH->FH_INIVIGE := SFH->FH_FIMVIGE + 1
					SFH->FH_FIMVIGE	:= CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "C" .and. lExPadron .and. lEsRiesgo .and. (cTmpSFH)->FH_SITUACA <> "2" .and. ((cTmpSFH)->FH_FIMVIGE == CTOD("//") .or. (cTmpSFH)->FH_FIMVIGE > dFchPro) .and. !lRgoFin //RiesgoFiscal CLIENTES
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_SITUACA := "2"
					SFH->FH_INIVIGE := TRD->FCH_INIR
					SFH->FH_FIMVIGE := TRD->FCH_FINR
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "C" .and. lExPadron .and. lEsRiesgo .and. TRD->FCH_FINR <> CTOD("//") .and. (cTmpSFH)->FH_SITUACA = "2" .and. (cTmpSFH)->FH_FIMVIGE == CTOD("//") //Clientes Riesgo Fiscal con fin de Riesgo
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))		
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := TRD->FCH_FINR
				MsUnlock()
	
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmpSFH)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_SITUACA := ""
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE	:= CTOD("//")
				MsUnlock()
				lRgoFin := .T.
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "C" .and. !lExPadron .and. (cTmpSFH)->FH_SITUACA = "2" .and. (cTmpSFH)->FH_FIMVIGE == CTOD("//") //Riesgo Fiscal Clientes que no están en el padrón
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFchPro-1
				MsUnlock()
				
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmpSFH)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_SITUACA := ""
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "E" .and. lExPadron .and. lEsRiesgo .and. (cTmpSFH)->FH_SITUACA <> "2"  .and. ((cTmpSFH)->FH_FIMVIGE == CTOD("//") .or. (cTmpSFH)->FH_FIMVIGE > dFchPro) .and. !lRgoFin //Riesgo Fiscal Proveedores
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				Reclock("SFH",.F.)				
					SFH->FH_TIPO := cTipoEmp
					SFH->FH_SITUACA := "2"
					SFH->FH_INIVIGE := dDesde
					SFH->FH_FIMVIGE := dHasta
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "E" .and. lExPadron .and. lEsRiesgo .and. dHasta <> CTOD("//") .and. (cTmpSFH)->FH_SITUACA = "2" .and. (cTmpSFH)->FH_FIMVIGE == CTOD("//")
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dHasta
				MsUnlock()
					
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmpSFH)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_TIPO := cTipoEmp
					SFH->FH_SITUACA := ""
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				lRgoFin := .T.
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "E" .and. !lExPadron .and.  (cTmpSFH)->FH_SITUACA = "2" .and. (cTmpSFH)->FH_FIMVIGE == CTOD("//")
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFchPro-1
				MsUnlock()
				
				RecLock("SFH",.T.)
					For j:=1 To Len(aStrut)
						If ColumnPos(aStrut[j]) > 0
							FieldPut(ColumnPos(aStrut[j]),(cTmpSFH)->&(aStrut[j]))
						EndIf
					Next j
					SFH->FH_SITUACA := ""
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf (cOrig == "E" .or. cOrig == "C") .and. lExPadron .and. IIF(cOrig == "E",AllTrim(cTipoEmp) <> "",AllTrim(TRD->TIPO) <> "")
				SFH->(DBGOTO((cTmpSFH)->R_E_C_N_O_))
				If !VldVigSFH(IIF(cOrig == "E",cTipoEmp,TRD->TIPO),.F.)
					Reclock("SFH",.F.)
						SFH->FH_TIPO := IIF(cOrig == "E",cTipoEmp,TRD->TIPO)
					MsUnlock()
				EndIf
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			EndIf
			
		Else
			If cOrig == "C" .and. lExPadron .and. lEsTasa .and. AllTrim(cCodFis) <> "" .and. AllTrim(cCodAct) <> ""//Tasa cero y no existe registro de cliente
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_CLIENTE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					SFH->FH_PERCIBI := "N"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			Elseif cOrig == "E" .and. lExPadron .and. lEsTasa .and. AllTrim(cCodFis) <> "" .and. AllTrim(cCodAct) <> ""
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_FORNECE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					CGF->CGF_ZONFIS := "ME"
					SFH->FH_PERCIBI := "N"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_TIPO := cTipoEmp
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "C" .and. lExPadron .and. lEsRiesgo .and. lEsTasa 
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_CLIENTE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					SFH->FH_PERCIBI := "N"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_SITUACA := "2"
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_ALIQ := 0
					SFH->FH_PERCENT := 0
					SFH->FH_INIVIGE := TRD->FCH_INIR
					SFH->FH_FIMVIGE := TRD->FCH_FINR
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			Elseif cOrig == "E" .and. lExPadron .and. lEsRiesgo
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_FORNECE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					SFH->FH_PERCIBI := "N"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_SITUACA := "2"
					SFH->FH_TIPO := cTipoEmp
					SFH->FH_ALIQ := 0
					SFH->FH_PERCENT := 0
					SFH->FH_INIVIGE := dDesde
					SFH->FH_FIMVIGE := dHasta
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "C" .and. lExPadron .and. AllTrim(TRD->TIPO) <> "" .and. lEsTasa 
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_CLIENTE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					SFH->FH_PERCIBI := "S"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_SITUACA := "1"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_TIPO := TRD->TIPO
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			ElseIf cOrig == "E" .and. lExPadron .and. AllTrim(cTipoEmp) <> ""
				Reclock("SFH",.T.)
					SFH->FH_FILIAL := xFilial("SFH")
					SFH->FH_AGENTE := "N"
					SFH->FH_FORNECE := (cAlias)->&(cSA +"_COD")
					SFH->FH_LOJA := (cAlias)->&(cSA +"_LOJA")
					SFH->FH_NOME := (cAlias)->&(cSA +"_NOME")
					SFH->FH_IMPOSTO := "IBF"
					SFH->FH_PERCIBI := "S"
					SFH->FH_ISENTO := "N"
					SFH->FH_APERIB := "N"
					SFH->FH_SITUACA := "1"
					SFH->FH_ZONFIS	:=  "ME"
					SFH->FH_TIPO := cTipoEmp
					SFH->FH_INIVIGE := CTOD("//")
					SFH->FH_FIMVIGE := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == (cAlias)->&(cSA +"_NOME")+(cAlias)->&(cSA +"_CGC")})
				If nPos == 0
					aAdd(aProvAct,{(cAlias)->&(cSA +"_LOJA"),(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_NOME"),(cAlias)->&(cSA +"_CGC") })
				EndIf
				lActSFH := .T.
			EndIf
		EndIf
		(cTmpSFH)->(dbCloseArea())
	EndIf
	
	If (lExPadron .and. AllTrim(cCodFis) <> "" .and. AllTrim(cCodAct) <> "") .or. !lExPadron
		If cOrig == "C" //Tasa Cero(Clientes)
			ChkCGFPer(1,(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_LOJA"),cCodAct,lExPadron,lEsTasa,cCodFis,,(cAlias)->&(cSA +"_CGC"),(cAlias)->&(cSA +"_NOME"))
		Elseif cOrig == "E" ////Tasa Cero (Proveedores)
			ChkCGFPer(2,(cAlias)->&(cSA +"_COD"),(cAlias)->&(cSA +"_LOJA"),cCodAct,lExPadron,lEsTasa,cCodFis,,(cAlias)->&(cSA +"_CGC"),(cAlias)->&(cSA +"_NOME"))
		EndIf
	EndIf
	
	RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ InsertSFH³ Autor ³ Laura Medina        ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Para insertar un registro nuevo en la tabla de Ingresos    ³±±
±±³          ³ Brutos - SFH.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InsertSFH(nOpc)
                                    
	Reclock("SFH",.T.)
	SFH->FH_CLAPROD :=  "CGF"
	SFH->FH_FILIAL	:= xFilial("SFH")
	SFH->FH_FORNECE := (cTmp)->A2_COD
	SFH->FH_LOJA 	:= (cTmp)->A2_LOJA
	SFH->FH_NOME	:= (cTmp)->A2_NOME
	SFH->FH_AGENTE	:= 'N'
	SFH->FH_ZONFIS	:= 'ME'
	SFH->FH_IMPOSTO	:= 'IBR'
	SFH->FH_PERCIBI	:= 'N'
	SFH->FH_ISENTO	:= 'N'
	SFH->FH_APERIB	:= 'N'
	SFH->FH_TIPO	:= TRD->TIPO

	If  nOpc == 1   //TASACERO (No existe registro en SFH)
		SFH->FH_INIVIGE	:= CTOD("//")
		SFH->FH_FIMVIGE	:= CTOD("//")
	Elseif nOpc == 2 //RIESGO (No existe registro en SFH)
		SFH->FH_SITUACA := "2"
		SFH->FH_ALIQ    := 0
		SFH->FH_PERCENT := 0
		SFH->FH_INIVIGE	:= TRD->FCH_INIR
		SFH->FH_FIMVIGE := TRD->FCH_FINR
	Endif
	MsUnlock()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChkCGFPer³ Autor ³ Raul Ortiz          ³ Data ³ 19/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se inserta registro en la nueva tabla CGF o lo modifica    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkCGFPer(nOpc,cCod,cLoja,cCodAct,lExiste,lTasaCero,cCodFis,lIbr,cCGC,cNome)         
	Local aArea	:= GetArea()
	Local cTmpCGF	:= criatrab(nil,.F.)
	Local nRegCGF		:= 0
	Local nPos      := 0
		
	Default lIbr := .F.
		
	//Seleccionar cliente o proveedor de CGF 
	
	If (CGF->(ColumnPos("CGF_CODCLI")) > 0 .and. nOpc == 1) .or. nOpc == 2
		FISCGFQry(cTmpCGF,nOpc,cCod,cLoja,cCodAct,@nRegCGF,lExiste,lIbr)
		
		(cTmpCGF)->(dbGoTop())
		If nRegCGF > 0
			If (cTmpCGF)-> CGF_FIMVIG <> CTOD("//") .and. lExiste
				If (cTmpCGF)->CGF_FIMVIG <= dFchPro .and. lTasaCero
					Reclock("CGF",.T.)
						CGF->CGF_FILIAL := xFilial("CGF")
						If nOpc == 1
							CGF->CGF_CODCLI := cCod
						ElseIf  nOpc == 2
							CGF->CGF_COD := cCod
						EndIf
						CGF->CGF_LOJA := cLoja
						If !lIbr
							CGF->CGF_IMPOST := "IBF"
						Else
							CGF->CGF_IMPOST := "IBR"
						EndIf
						CGF->CGF_ZONFIS := "ME"
						CGF->CGF_CFO := cCodFis
						CGF->CGF_CODACT := cCodAct
						CGF->CGF_PEREXE := 100
						CGF->CGF_INIVIG := DDATABASE
						CGF->CGF_FIMVIG  := CTOD("//")
					MsUnlock()
					nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == cNome+cCGC})
					If nPos == 0 
						aAdd(aProvAct,{cLoja,cCod,cNome,cCGC })
					EndIf
				EndIf
			ElseIf lExiste .and. !lTasaCero
				CGF->(DBGOTO((cTmpCGF)->R_E_C_N_O_))
				Reclock("CGF",.F.)
					CGF->CGF_FIMVIG  := dFchPro-1
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == cNome+cCGC})
				If nPos == 0 
					aAdd(aProvAct,{cLoja,cCod,cNome,cCGC })
				EndIf
			ElseIf !lExiste
				While (cTmpCGF)->(!EOF())
					If (cTmpCGF)-> CGF_FIMVIG == CTOD("//")
						CGF->(DBGOTO((cTmpCGF)->R_E_C_N_O_))
						Reclock("CGF",.F.)
							CGF->CGF_FIMVIG  := dFchPro-1
						MsUnlock()
					EndIf
					(cTmpCGF)->(DbSkip())
				Enddo
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == cNome+cCGC})
				If nPos == 0 
					aAdd(aProvAct,{cLoja,cCod,cNome,cCGC })
				EndIf
			EndIf
		Else
			If lExiste .and. lTasaCero
				Reclock("CGF",.T.)
					CGF->CGF_FILIAL := xFilial("CGF")
					If nOpc == 1
						CGF->CGF_CODCLI := cCod
					ElseIf  nOpc == 2
						CGF->CGF_COD := cCod
					EndIf
					CGF->CGF_LOJA := cLoja
					If !lIbr
						CGF->CGF_IMPOST := "IBF"
					Else
						CGF->CGF_IMPOST := "IBR"
					EndIf
					CGF->CGF_ZONFIS := "ME"
					CGF->CGF_CFO := cCodFis
					CGF->CGF_CODACT := cCodAct
					CGF->CGF_PEREXE := 100
					CGF->CGF_INIVIG := DDATABASE
					CGF->CGF_FIMVIG  := CTOD("//")
				MsUnlock()
				nPos := Ascan(aProvAct,{|aProvTmp| aProvTmp[3]+aProvTmp[4] == cNome+cCGC})
				If nPos == 0 
					aAdd(aProvAct,{cLoja,cCod,cNome,cCGC })
				EndIf
			EndIf
		EndIf
		
		(cTmpCGF)->(dbCloseArea())
	EndIf
	RestArea( aArea )
Return   
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISCGFQry   ³ Autor ³ Raul Ortiz        ³ Data ³ 19/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica registro en la 	tabla CGF                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISCGFQry(cTmpCGF,nOpc,cCod,cLoja,cCodAct, nRegCGF,lExiste,lIbr)
	Local cQuery := ""
	Local cCGF		:= InitSqlName("CGF")
	
	Default lIbr := .F.
		
	If (CGF->(ColumnPos("CGF_CODCLI")) > 0 .and. nOpc == 1) .or. nOpc == 2
		cQuery := "SELECT *  "
		cQuery += "FROM "+ cCGF + " CGF "
		cQuery += "WHERE CGF_FILIAL = '" + xFilial("CGF") +"' AND "
		If nOpc == 1
			cQuery += "      CGF_CODCLI = '" + cCod + "' AND "
		ElseiF  nOpc == 2
			cQuery += "      CGF_COD = '" + cCod + "' AND "
		EndIf
		cQuery += "      CGF_LOJA   = '" + cLoja + "' AND "
		If lExiste
			cQuery += "      CGF_CODACT   = '" + cCodAct + "' AND "
		EndIf
		cQuery += "      CGF_ZONFIS = 'ME' AND "
		If !lIbr
			cQuery += "      CGF_IMPOST = 'IBF' AND "
		Else
			cQuery += "      CGF_IMPOST = 'IBR' AND "
		EndIf
		cQuery +=		"D_E_L_E_T_ = '' "
		cQuery	+=	"ORDER BY  CGF_INIVIG DESC , CGF_FIMVIG DESC  "
		
		cQuery := ChangeQuery(cQuery)
	
		nRegCGF := 0
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpCGF,.T.,.T.)
		TCSetField(cTmpCGF,"CGF_INIVIG","D")
		TCSetField(cTmpCGF,"CGF_FIMVIG","D")
		
		(cTmpCGF)->(dbGoTop())
		Count to nRegCGF
	EndIf
Return   
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ getStruct ³ Autor ³ Laura Medina        ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Obtiene la estructura de la SFH para generar un registro  ³±± 
±±³           ³ nuevo.                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ getStruct()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static function getStruct(cAlias)
	Local aStru := {}
	Local aArea	:= getArea()
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias)
	While !Eof() .and. SX3->X3_ARQUIVO == cAlias
		aadd(aStru,SX3->X3_campo)
		dbSkip()
	EndDo
	dbCloseArea()
	RestArea(aArea)
Return aStru


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SelArch  ³ Autor ³ Laura Medina          ³ Data ³ 13/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecciona el directorio para el archivo Padron - MZ       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SelArch()     		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SelArch()
	Local mvRet		:= Alltrim(ReadVar())
	Local cType 	:= ""
	Local cArq		:= ""
	Local aDir		:= {}
	Local nDir		:= 0

	cType := "(*.TXT) |*.txt|"

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±³Comando para selecionar um arquivo.                                    ³±±
	±±³ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.            ³±±
	±±³            GETF_LOCALHARD - Inclui o Harddisk local.                  ³±±
	±±³                                                                       ³±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/


	cArq 	:= cGetFile(cType,OemToAnsi(STR0005),0,'', .T.,GETF_LOCALHARD+GETF_LOCALFLOPPY)  // "Selecione arquivo "
	aDir	:= { { cArq } }

	For nDir := 1 To Len(aDir)
		cArq := aDir[nDir][1]

		If !Empty(cArq)
			If !File(cArq)
				MsgAlert(STR0018 + cArq)  //"Archivo no encontrado: "
			Return .F.
			EndIf
		EndIf
	Next nDir

	&mvRet := cArq
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ UpdData  ³ Autor ³ Laura Medina        ³ Data ³ 15/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Para actualizar los parámetros necesarios para el proceso  ³±±
±±³          ³ de la importacion del padrón.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UpdData()
	dbselectarea("SX6")
	dbSetOrder(1)
	//Fecha de proceso (ejecucion)
	If SX6->(MsSeek(xFilial("SX6")+"MV_RETMZCF"))
		PUTMV("MV_RETMZCF", cFile)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpReport³ Autor ³ Laura Medina        ³ Data ³ 25/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Función para imprimir el reporte de los proveedores actua- ³±±
±±³          ³ lizados.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpReport(cTitulo,aProvAct)
	Local oReport
	Local aArea		 := GetArea()
	Private cPergu 	 := ""
	Private aOrd	 := {}
 
	oReport :=LOCARGLOG(cTitulo,aProvAct)
	oReport:PrintDialog()
	RestArea( aArea )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocArgLog ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrtura do Relatorio em TREPORT                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOCARGLOG(cTitulo,aLogArq)
	Local oReport
	Local oSection
	Local cDesc	   := cTitulo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos componentes de impressao                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE REPORT oReport NAME cTitulo TITLE "" PARAMETER cPergu ACTION {|oReport| LocArgImp(oReport,aLogArq)} DESCRIPTION cDesc TOTAL IN COLUMN
	oReport:SetPortrait(.T.)//Impressao Retrato
 
   	//oReport:DisableOrientation()//Desabilita a mudanca de impressao
   	//-------------------------------------------------------------------------------------------------------
	// oSection = usado para montar o cabeçalho do relatorio
	//-------------------------------------------------------------------------------------------------------
	DEFINE SECTION oSection OF oReport TITLE OemToAnsi(cTitulo) ORDERS aOrd TABLE "" TOTAL IN COLUMN
		//oSection1:SetLineStyle()	// Impressao da descricao e conteudo do campo na mesma linha      
	//DEFINE CELL NAME STR0015 OF oSection TITLE STR0016  SIZE 200
	DEFINE CELL NAME "D1" OF oSection TITLE STR0019  SIZE 8 Picture "99" //"Sucursal"
	DEFINE CELL NAME "D2" OF oSection TITLE STR0020  SIZE 7              //"Codigo"
	DEFINE CELL NAME "D3" OF oSection TITLE STR0021  SIZE 42             //"Nombre"
	DEFINE CELL NAME "D4" OF oSection TITLE STR0022  SIZE 15	         //"CUIT"       
		                
Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocArgImp ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Detalhe do Relatorio em TREPORT                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocArgImp(oReport,aLogArq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Declaracao de variaveis                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oSection := oReport:Section(1)
	Local nCont    := 0
	oSection:Init()
	For nCont:=1 To Len(aLogArq)
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		//oSection:Cell("LISTA"):SetBlock({||aLogArq[nCont]})
		
		oSection:Cell("D1"):SetValue(aLogArq[nCont,1]) // Sucursal
		oSection:Cell("D2"):SetValue(aLogArq[nCont,2]) // Codigo
		oSection:Cell("D3"):SetValue(aLogArq[nCont,3]) // Nombre 
		oSection:Cell("D4"):SetValue(aLogArq[nCont,4]) // CUIT
		
		oSection:PrintLine()
	End
	oSection:Finish()
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ActParam ³ Autor ³ Emanuel Villicaña   ³ Data ³ 28/04/14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Actualiza Parametro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ActParam(cParam,cValor)
	Local aArea	:= GetArea()

	dbSelectArea("SX6")
	dbSetOrder(1)
	If SX6->(MsSeek(Space( Len( SX6->X6_FIL ) )+cParam))
		PUTMV("MV_RETMZFC", cValor)
	Endif 
	
	RestArea( aArea )
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcEmp  ³ Autor ³ Raul Ortiz          ³ Data ³ 25/08/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca el cuit de las empresas dentro del padron			  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasP - Nombre de la tabla temporal del padron            ³±±
±±³          ³          									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Mendoza Argentina - MSSQL                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcEmp(cAliasP,cCodActEmp,cCodFisEmp,lRiesgoEmp,lTasaEmp,aEmpDatos)
	Local lRet := .F.

	SM0->(dbGoTop())
	While SM0->(!eof()) .and. !lRet
		DbSelectArea(cAliasP)
		(cAliasP)->(dbSetOrder(1))
		(cAliasP)->(dbGoTop())
		If (cAliasP)->(MsSeek(SM0->M0_CGC))
        	lRet := .T.
        	dbSelectArea("CCP")
			dbSetOrder(1)
        	While (cAliasP)->(!eof()) .and. SM0->M0_CGC == (cAliasP)->CUIT				
				If CCP->(MsSeek(cFilCCP + cTabAct + (cAliasP)->COD_ACT))
					cCodFisEmp := CCP->CCP_VDESTI
				Else
					cCodFisEmp := ""
				EndIf
				AADD(aEmpDatos,{(cAliasP)->COD_ACT,Iif(TRD->RIESGO=="S",.T.,.F.),Iif(TRD->TASACERO=="A",.T.,.F.),cCodFisEmp,(cAliasP)->FCH_INIR,(cAliasP)->FCH_FINR,(cAliasP)->TIPO})
				(cAliasP)->(DbSkip())
			Enddo
		EndIf
		SM0->(DbSkip())
	Enddo 	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldVigSFH³ Autor ³ Raul Ortiz          ³ Data ³ 02/02/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida la vigencia de los registros                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Mendoza Argentina - MSSQL                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldVigSFH(cTipo, lEsTasa)
	Local lRet := .F.
	
	If (SFH->FH_FIMVIGE == CTOD('//') .Or. SFH->FH_FIMVIGE > dFchPro) .And. lEsTasa
		lRet := .F.
	Else
		If (SFH->FH_INIVIGE == CTOD('//') .and. SFH->FH_FIMVIGE == CTOD('//')) .and. AllTrim(SFH->FH_TIPO) <> AllTrim(cTipo)
			actRegSFH("1",cTipo)
			lRet := .T.
		ElseIf (SFH->FH_INIVIGE == CTOD('//') .and. SFH->FH_FIMVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE > dFchPro) .and. AllTrim(SFH->FH_TIPO) <> AllTrim(cTipo)
			actRegSFH("2",cTipo)
			lRet := .T.
		ElseIf (SFH->FH_INIVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE == CTOD('//')) .and. AllTrim(SFH->FH_TIPO) <> AllTrim(cTipo)
			actRegSFH("3",cTipo)
			lRet := .T.
		ElseIf (SFH->FH_INIVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE > dFchPro) .and. AllTrim(SFH->FH_TIPO) <> AllTrim(cTipo)
			actRegSFH("4",cTipo)
			lRet := .T.
		ElseIf (SFH->FH_INIVIGE == CTOD('//') .and. SFH->FH_FIMVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE < dFchPro)
			actRegSFH("5",cTipo)
			lRet := .T.
		ElseIf (SFH->FH_INIVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE <> CTOD('//') .and. SFH->FH_FIMVIGE < dFchPro)
			actRegSFH("6",cTipo)
			lRet := .T.
		EndIf
	EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ actRegSFH³ Autor ³ Raul Ortiz          ³ Data ³ 02/02/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea un nuevo registro en SFH                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Mendoza Argentina - MSSQL                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function actRegSFH(cSituac,cTipo)
	Local i := 0
	Local j := 0

	aSFHTemp := {}
	
	For i:=1 to len(aEstSFH)
		aADD(aSFHTemp,{aEstSFH[i],SFH->&(aEstSFH[i][1])}) 
	Next i
	
	If cSituac $ "1|2|3|4"
		Reclock("SFH",.F.)
			SFH->FH_FIMVIGE    :=  dFchPro-1
		Msunlock()
	EndIf
	
	Reclock("SFH",.T.)
		For j := 1 to Len(aSFHTemp)
			SFH->&(aSFHTemp[j][1][1]) := aSFHTemp[j][2]
		Next j
		SFH->FH_TIPO    := cTipo
		SFH->FH_INIVIGE := dFchPro
		If cSituac $ "1|3|5|6"
			SFH->FH_FIMVIGE	:= CTOD("//")
		EndIf
	Msunlock()						
Return

