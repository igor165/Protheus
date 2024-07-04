#Include "Protheus.ch"
#Include "FISA101.ch"
#Include 'topconn.ch'

#DEFINE _SEPARADOR "  "
#DEFINE _SEPAR8314 ";"

 /*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噭o    ?FISA101  ?Autor ?Laura Medina               ?Data ?27/04/15 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噭o ?Rutina para Padron de Tucum醤 (IIBB y de Contribuyentes)        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?FISA101                                                         潮?
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?                         ATUAIZACOES SOFRIDAS                              潮?
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅rogramador ?Data   ?  BOPS   ?          Motivo da Alteracao             潮?
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Marco A.  ?2/01/17砈ERINN001 砈e aplica CTREE para evitar la creacion    潮?
北?           ?       ?535      砫e tablas temporales de manera fisica      潮?
北?           ?       ?         砮n system.                                 潮?
北矼arco A. Glz?9/03/17? MMI-318 砈e replica llamado (TVOAD3 - V11.8), Se    潮?
北?           ?       ?         砤grega funcionalidad, para carga de Padron 潮?
北?           ?       ?         矰GR 82-14 y que el padron tambien sea dife-潮?
北?           ?       ?         硆ente de semestral. (ARG)                  潮?
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function FISA101()
	
	Local oFld		:= Nil
	Local oPadron	:= Nil
	Local oTipo		:= Nil                                                       			
	Local aPadron	:= {}
	Local aTipo		:= {}
	
	Private cPerVig		:= Space(6) 	
	Private oGet		:= Nil
	Private oDlg		:= Nil
	Private lAct		:= .F.
	Private cMes		:= StrZero(Month(dDataBase), 2)
	Private cAno		:= StrZero(Year(dDataBase), 4)
	Private lRet		:= .T.
	Private cPadron		:= ""
	Private cTipo		:= STR0004
	Private aLinea		:= {}    
	Private dFchIni		:= CTOD("//")
	Private dFchFin		:= CTOD("//")   
	Private cCoefSM0	:= ""
	Private cExenSM0	:= ""
	Private cConvSM0	:= ""
	Private cMesFin		:= ""
	Private cMesIni		:= ""
	Private nAliqEmp    := 0
	

	Public aQry := {}

	aAdd( aPadron, STR0028 ) //"1 - Padr髇 IIBB"
	aAdd( aPadron, STR0029 ) //"2 - Padr髇 de Contribuyentes"

	aAdd( aTipo, STR0002 ) //"1- Fornecedor"
	aAdd( aTipo, STR0003 ) //"2- Cliente"
	aAdd( aTipo, STR0004 ) //"3- Ambos"	   

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Padr髇 Tucum醤"

	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Par醡etros"
	@ 015,010 SAY STR0027 SIZE 065,008 PIXEL OF oFld //"縋adr髇 a Importar?"
	@ 025,010 COMBOBOX oPadron VAR cPadron ITEMS aPadron SIZE 65,8 PIXEL OF oFld 

	//+-----------------
	//| Campos Check-Up
	//+-----------------
	@ 025,100 COMBOBOX oTipo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //"1- Proveedor", "2- Cliente", "3- Cliente" 
	@ 050,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,070 

	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 003,005 SAY STR0009 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina tiene como objetivo importar el Padr髇 DGR 83-14: Padr髇 Coeficientes "
	@ 013,005 SAY STR0010 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"o el Padr髇 DGR 83-14: Padr髇 de Contribuyentes. "
	@ 023,005 SAY STR0011 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Contribuyentes."
	@ 037,005 SAY STR0030 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"縋eriodo de Vigencia?"
	@ 035,070 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 035,095 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 035,100 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]

	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0013 SIZE 036,016 PIXEL ACTION ImpArq() //"&Importar"
	@ 075,178 BUTTON STR0014 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

	ACTIVATE MSDIALOG oDlg CENTER

Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?ImpArq   ?Autor ?Laura Medina        ?Data ?27/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Procesa archivo.                                           潮?
北?         ?                                                           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?														  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Provincia de Tucuman			                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function ImpArq(cRG,cCliFor)

	Local nPos		:= 0
	Local cLine		:= ""
	Local cFile		:= ""
	Local cTmp		:= "TMP"
	Local cArq		:= ""
	Local aStru		:= {}
	Local lImp		:= .F.
	Local aOrdem	:= {} 

	Private _cCont		:= 0
	Private dDataIni	:= ""
	Private dDataFim	:= ""
	Private lExistEmp	:= .F.
	Private nPerEmp		:= 0
	Private oTmpTable	:= Nil
	Private lAutomato := isblind()
	
	Default cRG	:=""
	Default cCliFor :=""

	If !lAutomato
		cPadron := Subs(cPadron,1,1)  	//1 - IIBB 2 - Contribuyentes
		cTipo   := Subs(cTipo,1,1)  	//1 - Proveedor, 2 - Cliente y  3 - Ambos
	Else
		cPadron := Subs(cRg,1,1)
		cTipo   := Subs(cCliFor,1,1)
	EndIf	
	// Seleciona o arquivo
	If !lAutomato
		cFile := FGetFile()
	Else
		cFile := cFileAut		
	EndIf
	If File(cFile) .And. !Empty(cFile)     

		If cPadron == "1" //Tabla temporal para IIBB
			//creamos la tabla temporal	
			AADD(aStru,{ "TMP_CUIT"    , "C",  14, 0})
			AADD(aStru,{ "TMP_EXENTO"  , "C",  1,  0})
			AADD(aStru,{ "TMP_COEF"    , "N",  8,  4})
			AADD(aStru,{ "TMP_ALIQ"    , "N",  8,  4})

			aOrdem := {"TMP_CUIT"}

			oTmpTable := FWTemporaryTable():New("TMP")
			oTmpTable:SetFields(aStru)
			oTmpTable:AddIndex("IN1", aOrdem)
			oTmpTable:Create()

			// Se procesa archivo de texto				
			Processa( {|| lImp:= ObtFile(cFile,"TMP")},STR0015,Alltrim(cFile), .T. )
		ElseIf cPadron == "2" //Tabla temporal para Contribuyentes
			//creamos la tabla temporal	
			aAdd(aStru,{ "TMP_CUIT"    , "C",  14, 0})
			aAdd(aStru,{ "TMP_EXENTO"  , "C",  1,  0})
			aAdd(aStru,{ "TMP_CONV"    , "C",  1,  0})
			AADD(aStru,{ "TMP_ALIQ"    , "N",  8,  4})

			aOrdem := {"TMP_CUIT"}

			oTmpTable := FWTemporaryTable():New("TMP")
			oTmpTable:SetFields(aStru)
			oTmpTable:AddIndex("IN1", aOrdem)
			oTmpTable:Create()

			// Se procesa archivo de texto				
			Processa( {|| lImp:= ObtFile(cFile,"TMP")},STR0015,Alltrim(cFile), .T. )
		Endif

		If cPadron == "1" //Tabla temporal para IIBB
			If  lImp // Si el archivo fue procesado    
				Processa( {|| lExistEmp := ProcEmp()} , STR0015,STR0019, .T. )	//Proveedores Percepciones
				If  cTipo == "1" .Or. cTipo == "3"      //Procesa Proveedores
					Processa( {|| ProcRegs(.F.)}, STR0015,STR0021, .T. )
				EndIf
				If  cTipo == "2" .Or. cTipo == "3"      //Procesa Clientes
					Processa( {|| ProcRegs(.T.)} , STR0015,STR0019, .T. )	//Proveedores Percepciones						
				EndIf		
			End IF
			TMP->(dbCloseArea())  
		Elseif cPadron == "2"
			If  lImp // Si el archivo fue procesado
				If  cTipo == "1" .Or. cTipo == "3"      //Procesa Proveedores
					Processa( {|| ProcRegs(.F.)}, STR0015,STR0021, .T. )	//Proveedores Percepciones (solo si el CUIT de SM0 existe en el padron)
				EndIf
				If  cTipo == "2" .Or. cTipo == "3"      //Procesa Clientes
					Processa( {|| ProcRegs(.T.)} , STR0015,STR0019, .T. )	//Proveedores Percepciones						
				EndIf
			End IF
			TMP->(dbCloseArea())
		Endif

		If cPadron == "1" //Tabla temporal para IIBB
			If lAct
				MsgAlert(STR0023)
			Else
				MsgAlert(STR0024)
			End If      
		Else  
			If lAct
				MsgAlert(STR0023)
			Else
				MsgAlert(STR0024)
			End If 
		Endif   	
		If !lAutomato
			oDlg:End()
		EndIf		  

	Endif
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?FGetFile ?Autor ?Ivan Haponczuk      ?Data ?09.06.2011 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Tela de sele玢o do arquivo txt a ser importado.            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?cRet - Diretori e arquivo selecionado.                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Buenos Aires Argentina - MSSQL                    潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function FGetFile()

	Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0018,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0018,,.T.)//"Selecionar arquivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?FGetDir  ?Autor ?Ivan Haponczuk      ?Data ?09.06.2011 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Tela para procurar e selecionar o arquivo nos diretorios   潮?
北?         ?locais/servidor/unidades mapeadas.                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?oPar1 - Objeto TGet que ira receber o local e o arquivo    潮?
北?         ?        selecionado.                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Nulo                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Buenos Aires Argentina - MSSQL                    潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function FGetDir(oTGet)

	Local cDir := ""

	cDir := cGetFile(,STR0019,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?ObtFile  ?Autor ?Laura Medina        ?Data ?27/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Lee archivo (.txt) y coloca su contenido en tabla temporal 潮?
北?         ?TMP.                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?														  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Provincia de Tucuman			                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function ObtFile(cFile,cAlias)
	
	Local nFor		:= 0
	Local nHandle	:= 0
	Local nX		:= 0
	Local lRet		:= .F.
	Local lBandera	:= .T.
	Local dFechaAux	:= CTOD("//") 
	Local cLinPadron := ""


	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())	

	nHandle := FT_FUse(cFile)

	// Se hay error al abrir el archivo
	If  nHandle != -1  
		// Se posiciona en la primera l韓ea
		FT_FGoTop()

		nFor := FT_FLastRec()

		ProcRegua(nFor)

		While !FT_FEOF()   
			nX++		
			nRecno 	:= FT_FRecno()   
			aLinea  := {}

			IncProc(STR0019 + str(nX))  //"Procesando registros..."   
			
			cLinPadron := FT_FREADLN()
			If Len(cLinPadron) < 180
				FT_FSKIP() 
				Loop
			EndIf
			
			If cPadron == "1"
				aLinea := {,,,,,}
				aLinea[1] := Substr(cLinPadron, 1, 13)
				aLinea[2] := Substr(cLinPadron, 13, 3)
				aLinea[3] := Substr(cLinPadron, 17, 8)
				aLinea[4] := Substr(cLinPadron, 25, 8)
				aLinea[5] := Substr(cLinPadron, 33, 152)
				aLinea[6] := Substr(cLinPadron, 185)
			ElseIf cPadron == "2"
				aLinea := {,,,,,,}
				aLinea[1] := Substr(cLinPadron, 1, 13)
				aLinea[2] := Substr(cLinPadron, 13, 3)
				aLinea[3] := Substr(cLinPadron, 17, 4)
				aLinea[4] := Substr(cLinPadron, 21, 10)
				aLinea[5] := Substr(cLinPadron, 31, 10)
				aLinea[6] := Substr(cLinPadron, 41, 152)
				aLinea[7] := Substr(cLinPadron, 193)
			EndIf
			
			If  Empty(aLinea) //Es una linea vacia
				FT_FSKIP() 
				Loop
			Endif 

			If !(Substr(aLinea[1],1,1) $ '0123456789') //NO es un registro valido
				FT_FSKIP() 
				Loop
			Endif 

			If  lBandera //Solo valida una vez
				If (cAno+cMes) != (SubStr(aLinea[4],1,4) + SubStr(aLinea[4],5,2))
					MsgAlert(STR0025)
					Exit
				EndIf 
				dFchIni := CTOD("01/"+SubStr(aLinea[4],5,2)+"/"+SubStr(aLinea[4],1,4) )
				If cPadron == "1"
					dFchFin := CTOD(Str(F_UltDia(CTOD("01/"+SubStr(aLinea[4],5,2)+"/"+SubStr(aLinea[4],1,4) )))+"/"+SubStr(aLinea[4],5,2)+"/"+SubStr(aLinea[4],1,4))
				Elseif cPadron == "2"
					cMesIni = SubStr(aLinea[4],5,2)
					cMesFin := SubStr(aLinea[5],5,2)
					cMesFin := IIf(Len(cMesFin)=1,"0" + cMesFin, cMesFin)
					dFechaAux := CTOD(Str(F_UltDia(CTOD("01/"+cMesFin+"/"+SubStr(aLinea[4],1,4) )))+"/"+cMesFin+"/"+SubStr(aLinea[4],1,4))
					dFchFin := CTOD(Str(F_UltDia(CTOD("01/"+SubStr(aLinea[5],5,2)+"/"+SubStr(aLinea[5],1,4) )))+"/"+SubStr(aLinea[5],5,2)+"/"+SubStr(aLinea[5],1,4))
				EndIf
				lBandera := .F.
			Endif			
	 
			If !Empty(aLinea) 
				Reclock(cAlias,.T.)
				(cAlias)->TMP_CUIT		:= aLinea[1]
				(cAlias)->TMP_EXENTO	:= IIf(Alltrim(aLinea[2]) == "E","S","N")
				If cPadron == "1"
					(cAlias)->TMP_COEF		:= IIf(Alltrim(aLinea[2])=="E", 0.0, IIf(Val(aLinea[3]) > 99.9999, Val(aLinea[3])/1000, Val(aLinea[3])))
					(cAlias)->TMP_ALIQ      := IIf(Alltrim(aLinea[2])=="E", 0.0, Val(aLinea[6]))
				Elseif cPadron == "2"
					(cAlias)->TMP_CONV	    := Iif(Alltrim(aLinea[3]) == "CM","V","I")
					(cAlias)->TMP_ALIQ      := IIf(Alltrim(aLinea[2])=="E", 0.0, Val(aLinea[7]))
				EndIf 	
				(cAlias)->(MsUnlock())			
				lRet := .T.							
			Endif
			
			FT_FSKIP() // Salta a siguiente l韓ea
			
		EndDo

		//Cerrar archivo
		FT_FUSE()
	Else
		MsgAlert(STR0016 + cFile + STR0017)	// El archivo XXX no puede abrirse.		
	EndIf

Return lRet

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?ProcRegs ?Autor ?Laura Medina        ?Data ?28/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Tela para procurar e selecionar o arquivo nos diretorios   潮?
北?         ?locais/servidor/unidades mapeadas.                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?lCli = .T. si selecciono cliente                           潮?
北?         ?       .F. si es Proveedor                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Nulo                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Provincia de tucuman                              潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function ProcRegs(lCli)

	Local aArea		:= GetArea()
	Local cQuery	:= ""	
	Local cSA		:= Iif(lCli,InitSqlName("SA1"),InitSqlName("SA2"))	 
	Local cMsg		:= Iif(lCli,STR0020,STR0022)       
	Local cPref		:= Iif(lCli,"A1","A2")
	Local cTmp 	    := Criatrab(nil,.F.)                               
	Local aTmp		:= {}
	Local nReg		:= 0
	Local nI		:= 0
	Local cClave	:= ""
	Local nCont		:= 0 

	// Seleccionar clientes que no esten bloqueados y cuyo CUIT no este vacio y sean registros que no 
	// esten eliminados y para todas las filiales
	cQuery := " SELECT " + cPref + "_COD ," 
	cQuery +=		cPref + "_LOJA,"
	cQuery +=		cPref + "_CGC,  "
	cQuery +=		cPref + "_NOME, "
	IF !lCli
	cQuery +=		cPref + "_TIPROV, "
EndIf
	cQuery +=		cPref + "_FILIAL "
	cQuery += " FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	cQuery += 		cPref + "_CGC <> ' ' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + cPref + "_CGC "

	cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

	ProcRegua(nCont) 

	If cPadron == "1"
		While (cTmp)->(!eof()) //Clientes/Proveedores
			nI++
			IncProc(cMsg + Str(nI))

			cClave := (cTmp)->&(cPref+"_CGC")

			dbSelectArea("TMP")
			dbSetOrder(1)

			//  Se realiza la busqueda por CUIT en la tabla Temporal
			If (TMP->(dbSeek(cClave)))
				BuscaSFH(cTmp,lCli,IiF(lCli,"C","P"))  
			EndIf

			If lExistEmp .and. !lCli  
				BuscaSFH(cTmp,lCli,"E")
			EndIf

			(cTmp)->(dbSkip())	    
		EndDo
	ElseIf cPadron == "2"
		lExistEmp := ProcEmp()
		While (cTmp)->(!eof())      //Clientes/Proveedores
			nI++
			IncProc(cMsg + Str(nI))

			cClave := (cTmp)->&(cPref+"_CGC")

			dbSelectArea("TMP")
			dbSetOrder(1)

			//  Se realiza la busqueda por CUIT en la tabla Temporal 
			If (TMP->(dbSeek(cClave)))
				UPDSFH(cTmp,IiF(lCli,"C","P"),.T.)
			Else
				UPDSFH(cTmp,IiF(lCli,"C","P"),.F.)
			Endif

			IF !lCli
				UPDSFH(cTmp,"E",lExistEmp)
			EndIF

			(cTmp)->(dbSkip())	    
		EndDo
	EndIf

	(cTmp)->(dbCloseArea()) 

	RestArea(aArea)
	
Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?BuscaSFH ?Autor ?Laura Medina        ?Data ?28/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Busca y actualiza registros en SFH 						  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cAlias - Tabla temp con los registros obtenidos de SA1/SA2 潮?
北?         ?lCli   - Si .T. est?procesando Clientes					  潮?
北?         ?			Si .F. est?procesandoProveedores				  潮?
北?         ?lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	  潮?
北?         ?			archivo ASCII 									  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Nulo                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Argentina 			                  			  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function BuscaSFH(cAlias,lCli,cOrigen)

	Local aArea		:= GetArea()
	Local cQuery	:= ""	
	Local cSFH		:= InitSqlName("SFH")
	Local cTmp		:= criatrab(nil,.F.)                                
	Local cPref		:= IIf(lCli,"A1","A2")
	Local aTmp		:= {}
	Local nReg		:= 0
	Local j	   		:= 0
	Local cPerAux	:= ""
	Local aSFH		:= {} 
	Local lRegSFH   := .F.
	Local nTamCoef	:= TAMSX3('FH_COEFMUL')[2]

	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If  lCli	
		cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
	Else      
		cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
	EndIF
	If cOrigen == "E" .or. cOrigen == "C"
		cQuery += "FH_IMPOSTO = 'IB4' AND "
	Else 
		cQuery += "FH_IMPOSTO = 'IBR' AND "
	EndIf
	cQuery += 	"FH_ZONFIS  = 'TU'  AND "

	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"  

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

//Valida si existe registro en SFH
If nCont == 0 .And. cOrigen == "E" 
	lRegSFH := VldSFH8314((cAlias)->A2_COD, (cAlias)->&(cPref+"_LOJA"))
EndIf
   If nCont > 0 //Actualizar registro
		While (cTmp)->(!EOF())  
			nReg := (cTmp)->R_E_C_N_O_ 
			SFH->(DBGOTO(nReg))
			If  SFH->(!EOF())
				Reclock("SFH",.F.)
				If (STOD((cTmp)->FH_FIMVIGE)) == dFchFin 
					If (cOrigen == "C" .And. (cTmp)->FH_IMPOSTO =="IB4") .Or. (cOrigen == "P" .And. (cTmp)->FH_IMPOSTO =="IBR")
						SFH->FH_TIPO	:= "V"
					EndIf	
					SFH->FH_PERCENT	:= Iif(Iif(cOrigen == "E",cExenSM0,TMP->TMP_EXENTO)=="S",100.00,0.00)
					SFH->FH_ALIQ 	:= Iif(cOrigen == "E",nAliqEmp,TMP->TMP_ALIQ)
					If (cTmp)->FH_IMPOSTO =="IB4"
						SFH->FH_COEFMUL 	:= Iif(cOrigen == "E",cCoefSM0,Round(TMP->TMP_COEF,nTamCoef))
					EndIf	
				ELseIf SFH->FH_FIMVIGE == (dFchIni-1)  .And. (cTmp)->FH_TIPO == "V" .And. Round ((cTmp)->FH_COEFMUL,nTamCoef)== Round(TMP->TMP_COEF,nTamCoef);
				.And. (cTmp)->FH_ALIQ == TMP->TMP_ALIQ .And. (cTmp)->FH_PERCENT == (IIf(TMP->TMP_EXENTO=="S",100.00,0.00))
					SFH->FH_FIMVIGE	:= dFchFin
				EndIf	
				
				SFH->(MsUnlock())
				lAct := .T.
			EndIf 
			(cTmp)->(dbSkip())	  
		Enddo
	ElseIf ((nCont == 0 .And. cOrigen $ "C|P") .Or. (lRegSFH .And. cOrigen == "E" .And. (cAlias)->A2_TIPROV <> "A")) //Insertar registro (No existe)
			Reclock("SFH",.T.)
			SFH->FH_FILIAL	:= xFilial("SFH")
			SFH->FH_AGENTE	:= "N"
			If lCli
				SFH->FH_CLIENTE	:= (cAlias)->A1_COD
			Else  //Es proveedor y el CUIT de la empresa (SM0_CGC) esta incluido en el padr髇 
				SFH->FH_FORNECE	:= (cAlias)->A2_COD
			EndIf
			SFH->FH_LOJA	:= (cAlias)->&(cPref+"_LOJA")
			SFH->FH_NOME	:= (cAlias)->&(cPref+"_NOME")
			SFH->FH_TIPO	:= "V"
			SFH->FH_ZONFIS	:= "TU"
			If cOrigen == "P"
				SFH->FH_IMPOSTO	:= "IBR"
			Else 
				SFH->FH_IMPOSTO	:= "IB4"
			EndIf
			SFH->FH_PERCIBI	:= "S"
			SFH->FH_APERIB	:= "S"
			SFH->FH_ALIQ		:= Iif(cOrigen == "E",nAliqEmp,TMP->TMP_ALIQ)
			SFH->FH_COEFMUL 	:= Iif(cOrigen == "E",cCoefSM0,Round(TMP->TMP_COEF,nTamCoef))
			SFH->FH_PERCENT		:= Iif(Iif(cOrigen == "E",cExenSM0,TMP->TMP_EXENTO)=="S",100.00,0.00)
			SFH->FH_INIVIGE	:= dFchIni
			SFH->FH_FIMVIGE	:= dFchFin
			SFH->FH_ISENTO	:= "N"
			SFH->(MsUnlock())		  

			lAct := .T. 
	Endif 

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?ProcEmp  ?Autor ?Laura Medina        ?Data ?28/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Procesa para empresa.                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?														  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Provincia de Tucuman			                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function ProcEmp()

	Local lRet	:= .F.
	Local aArea	:= GetArea()     
	Local nTamCoef := TAMSX3('FH_COEFMUL')[2]

	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbgotop())

	While SM0->(!EOF()) .and. !lRet //Se recorre SM0
		dbSelectArea("TMP")
		dbSetOrder(1)
		TMP->(dbSeek(AllTrim(SM0->M0_CGC))) //Se busca registro en tab temporal(TMP) por CIUT)

		If Found() .and. !Empty(SM0->M0_CGC)//Si es encontrado el CUIT 			
			lRet     := .T.
			cExenSM0 := TMP->TMP_EXENTO //(S = Si, si el campo EXENTO = "E", si no N = No) 
			If cPadron == "1"
			cCoefSM0 := IIf(TMP->TMP_EXENTO == "E", 0.0, Round(TMP->TMP_COEF,nTamCoef))
			nAliqEmp := TMP->TMP_ALIQ
			Elseif cPadron == "2"
				cConvSM0 := TMP->TMP_CONV
				nAliqEmp := TMP->TMP_ALIQ
			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo

	If lRet
		dbSelectArea("CCO")
		CCO->(dbSetOrder(1))	
		If  CCO->(dbseek(XFILIAL("CCO")+"TU")) 
			If  cExenSM0 == "S"
				RecLock("CCO",.F.)
				CCO->CCO_TIPO:= "X"
				CCO->(MsUnlock())
			Else		
				RecLock("CCO",.F.)
				If cPadron == "1"
					CCO->CCO_TIPO:= "V"
				ElseIf cPadron == "2"
					CCO->CCO_TIPO := cConvSM0
				EndIf
				CCO->(MsUnlock())		
			EndIf
			lAct := .T.
		EndIf
	Else
		If cPadron == "2"
			dbSelectArea("CCO")
			CCO->(dbSetOrder(1))	
			If CCO->(dbseek(XFILIAL("CCO")+"TU"))
				RecLock("CCO",.F.)
				CCO->CCO_TIPO:= "N"
				CCO->(MsUnlock())
			EndIf
		EndIf
	Endif 

	RestArea(aArea)

Return lRet

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    砎alExtFile?Autor ?Laura Medina        ?Data ?28/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Valida extension del archivo seleccionado.                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Logico: Si extension es correcta o no.                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Provincia de Tucuman			                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/*/
Static Function ValExtFile(cNomeFile)
	
	Local lRet := .T.
	Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)//Substr(cNomeFile,at(".",cNomeFile)+1)

	If Empty(UPPER(cNomeFile)) .or. !(cExt $ "txt|TXT")
		MsgAlert(STR0026)
		lRet := .F.
	EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘?
北矲uncao    ?UPDSFH   ?Autor ?Raul Ortiz          ?Data ?28/04/2015 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢?
北矰escricao ?Busca y actualiza registros en SFH 					      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cAlias - Tabla temp con los registros obtenidos de SA1/SA2 潮?
北?         ?cOrigen   - Si es C est?procesando Clientes				  潮?
北?         ?			Si es P est?procesandoProveedores			      潮?
北?         ?			Si es E est?procesandoProveedores/Empresa        潮?
北?         ?lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	  潮?
北?         ?			archivo ASCII 							          潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Nulo                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Fiscal - Argentina 			                  		      潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDSFH(cAlias, cOrigen, lExist)

	Local aArea		:= GetArea()
	Local cQuery	:= ""	
	Local cSA		:= IIf(cOrigen == "C", InitSqlName("SA1"), InitSqlName("SA2"))	 
	Local cMsg		:= IIf(cOrigen == "C", STR0020, STR0022)       
	Local cPref		:= IIf(cOrigen == "C", "A1", "A2")
	Local cSFH		:= InitSqlName("SFH")
	Local cTmp 	    := Criatrab(nil,.F.)                               
	Local nI		:= 0
	Local cClave	:= ""
	Local nCont		:= 0
	Local nFin		:= 0
	Local dFecAux	:= CTOD("//")
	Local lActReg   := .F.
	Local lExistSFH := .F. 

	nFin := IIf(!lExist, Val(cMesIni), Val(cMesFin))
	
	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "	
	If cOrigen == "C"	
		cQuery += "FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
		cQuery += "FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
	Else      
		cQuery += "FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
		cQuery += "FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
	EndIF
	If cOrigen == "E" .or. cOrigen == "C"
		cQuery += "FH_IMPOSTO = 'IB4' AND "
	Else 
		cQuery += "FH_IMPOSTO = 'IBR' AND "
	EndIf
	cQuery += "FH_ZONFIS  = 'TU'  AND "
	If cPadron == "2"
	cQuery += "FH_TIPO = '" + TMP->TMP_CONV + "' AND "
	Endif 
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"  

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

	If  nCont > 0 //Actualizar registro
		If lExist
			If (STOD((cTmp)->FH_FIMVIGE) + 1) == dFchIni .And. (IIf(cOrigen $ "C|P",(cTmp)->FH_ALIQ == TMP->TMP_ALIQ, nAliqEmp == (cTmp)->FH_ALIQ));
			 .And. (cTmp)->FH_PERCENT == (IIf(IIf(cOrigen == "E",cExenSM0,TMP->TMP_EXENTO)=="S",100.00,0.00))
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFchFin
					lActReg := .T.
				SFH->(MsUnlock())
				lAct := .T. 
			EndIf
		EndIf
		If dFchIni > STOD((cTmp)->FH_FIMVIGE) .And. !lActReg
			lExistSFH := (IIf(Empty(STOD((cTmp)->FH_INIVIGE)) .And. cOrigen $ "P|E" .And. !lExist, vldRegSFH(cOrigen, (cAlias)->A2_COD, (cAlias)->&(cPref+"_LOJA")), .F.))
			If (!Empty(STOD((cTmp)->FH_FIMVIGE)) .Or. (Empty(STOD((cTmp)->FH_FIMVIGE)) .And. STOD((cTmp)->FH_INIVIGE) <> dFchIni)) .And. !lExistSFH
				For nI := Val(cMesIni) To nFin
					dFecAux := CTOD("01"+"/"+IIF(Len(Alltrim(str(nI)))=1,"0" + Alltrim(str(nI)), Alltrim(str(nI)))+"/"+STR(YEAR(dFchIni)))
					Reclock("SFH",.T.)
						SFH->FH_FILIAL		:= xFilial("SFH")
						SFH->FH_AGENTE 		:= (cTmp)->FH_AGENTE
						If  cOrigen == "C"
							SFH->FH_CLIENTE	:= (cAlias)->A1_COD
						Else  
							SFH->FH_FORNECE	:= (cAlias)->A2_COD
						EndIf
						SFH->FH_LOJA	    := (cAlias)->&(cPref+"_LOJA")
						SFH->FH_NOME	    := (cAlias)->&(cPref+"_NOME")
						SFH->FH_TIPO		:= IIF(lExist,IIF(cOrigen == "E", cConvSM0, TMP->TMP_CONV),IIf(cOrigen $ "E|P","N",(cTmp)->FH_TIPO))
						SFH->FH_PERCIBI		:= IIf(lExist,(cTmp)->FH_PERCIBI, "N")
						SFH->FH_ZONFIS		:= "TU"
						SFH->FH_IMPOSTO		:= IIF(cOrigen == "P","IBR","IB4")
						SFH->FH_ALIQ		:= IIf(cOrigen == "E", nAliqEmp, TMP->TMP_ALIQ)
						SFH->FH_PERCENT		:= IIf(lExist,IIf(IIf(cOrigen == "E",cExenSM0,TMP->TMP_EXENTO)=="S",100.00,0.00),0.00)
						SFH->FH_INIVIGE		:= IIF(!lExist,dFchIni,dFecAux)//dFchIni
						If cOrigen == "C"
							If lExist
								SFH->FH_FIMVIGE := CTOD(STR(F_UltDia(dFecAux))+"/"+IIF(Len(Alltrim(str(nI)))=1,"0" + Alltrim(str(nI)), Alltrim(str(nI)))+"/"+STR(YEAR(dFchFin)))
							Else
								SFH->FH_FIMVIGE := CTOD(STR(F_UltDia(dFchFin))+"/"+IIF(Len(Alltrim(str(Month(dFchFin))))=1,"0" + Alltrim(str(Month(dFchFin))), Alltrim(str(Month(dFchFin))))+"/"+STR(YEAR(dFchFin)))
							EndIf
						Else
							SFH->FH_FIMVIGE		:= IIF(!lExist,CTOD("//"),CTOD(STR(F_UltDia(dFecAux))+"/"+IIF(Len(Alltrim(str(nI)))=1,"0" + Alltrim(str(nI)), Alltrim(str(nI)))+"/"+STR(YEAR(dFchFin))))
						EndIf
						SFH->FH_ISENTO		:= "N"
						SFH->FH_APERIB		:= "S"
					SFH->(MsUnlock())
				Next
			EndIf			  
			lAct := .T. 

		EndIf
	ElseIf nCont == 0 .And. (cOrigen $ "C|P")    //Insertar registro (No existe)
		If lExist
			For nI := Val(cMesIni) To nFin
				dFecAux := CTOD("01"+"/"+IIf(Len(Alltrim(Str(nI)))==1,"0" + Alltrim(Str(nI)), Alltrim(Str(nI)))+"/"+Str(YEAR(dFchIni)))
				Reclock("SFH",.T.)
				SFH->FH_FILIAL	:= xFilial("SFH")
				SFH->FH_AGENTE	:= "N"
				If  cOrigen == "C"
					SFH->FH_CLIENTE	:= (cAlias)->A1_COD
				Else  //Es proveedor y el CUIT de la empresa (SM0_CGC) esta incluido en el padr髇 
					SFH->FH_FORNECE	:= (cAlias)->A2_COD
				EndIf
				SFH->FH_LOJA	:= (cAlias)->&(cPref+"_LOJA")
				SFH->FH_NOME	:= (cAlias)->&(cPref+"_NOME")
				SFH->FH_TIPO	:= IIf(cOrigen == "E", cConvSM0, TMP->TMP_CONV)
				SFH->FH_PERCIBI	:= "S"
				SFH->FH_ZONFIS	:= "TU"
				SFH->FH_IMPOSTO	:= IIf(cOrigen == "P","IBR","IB4")
				SFH->FH_ALIQ		:= SFH->FH_ALIQ		:= IIf(cOrigen == "E", nAliqEmp, TMP->TMP_ALIQ)
				SFH->FH_PERCENT	:= IIf(IIf(cOrigen == "E",cExenSM0,TMP->TMP_EXENTO)=="S",100.00,0.00)
				SFH->FH_INIVIGE	:= dFecAux
				SFH->FH_FIMVIGE	:= CTOD(Str(F_UltDia(dFecAux))+"/"+IIf(Len(Alltrim(Str(nI)))=1,"0" + Alltrim(Str(nI)), Alltrim(Str(nI)))+"/"+Str(YEAR(dFchFin)))
				SFH->FH_ISENTO	:= "N"
				SFH->FH_APERIB	:= "S"
				SFH->(MsUnlock())	
			Next		  
			lAct := .T. 
		EndIf
	Endif 

	(cTmp)->(dbCloseArea())
	RestArea(aArea)

Return

/*/{Protheus.doc} vldRegSFH
Verifica si existe registro en SFH.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   14/06/2018
@Version P11
@Param   
@Return  lExistSFH: .T. - Si existe registro en SFH.
/*/
Static Function vldRegSFH(cOrigen, cCodCliPro, cLojCliPro)
Local aArea		:= getArea()
Local cQuery	    := ""	
Local cSFH		:= InitSqlName("SFH")
Local cTmp 	    := Criatrab(Nil,.F.)                               
Local nCont     := 0
Local lExistSFH := .F.

	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If  cOrigen == "C"	
		cQuery +=  	"FH_CLIENTE='" + cCodCliPro + "' AND "
		cQuery += 	"FH_LOJA   ='" + cLojCliPro + "' AND "
	Else      
		cQuery +=  	"FH_FORNECE='" + cCodCliPro + "' AND "
		cQuery += 	"FH_LOJA   ='" + cLojCliPro	+ "' AND "
	EndIF
	If cOrigen == "E" .or. cOrigen == "C"
		cQuery +=	"FH_IMPOSTO = 'IB4' AND "
	Else 
		cQuery +=	"FH_IMPOSTO = 'IBR' AND "
	EndIf
	cQuery += 	"FH_ZONFIS  = 'TU'  AND " 
	cQuery += "FH_INIVIGE = " + DTOS(dFchIni) + " AND "
			
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"  
		
	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
		 
	Count to nCont
	
	If nCont > 0
		lExistSFH := .T.
	EndIf
	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
Return lExistSFH

/*/{Protheus.doc} VldSFH8314
Verifica si existe registro en SFH.
@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   18/06/2018
@Version P11
@Param   
@Return  lExistSFH: .T. - Si existe registro en SFH.
/*/
Static Function VldSFH8314(cCliPro, cTienda)
Local aArea		:= getArea()
Local lExistSFH := .F.
	
	dbSelectArea("SFH")
	dbSetOrder(1)
	If SFH->(MsSeek(xFilial("SFH") + cCliPro + cTienda + "IB4" + "TU"))
		lExistSFH := .T.
	EndIf
RestArea(aArea)
Return lExistSFH

/*/{Protheus.doc} FISA101AUT
	funcion utilizada en la automatizacion de la fisa101
	@author Cristian Franco
	@since 04/05/2021
	@version version 1
	@param cArchivo,caracter,ruta del padron a cargar.
	@param cRG,caracter,indica el padr髇 )
	@param cCliFor,caracter,indica si es cliente, proveedor o ambos("1- Proveedor","2- Cliente","3- Ambos" )
	@return nil
	/*/
Function FIS101AUT(cArchivo,cRG,cCliFor)
	Private cFileAut:=cArchivo
	Private aQry := {}

	IF FILE(cArchivo)
		ImpArq(cRG,cCliFor)
	EndIf
Return nil
