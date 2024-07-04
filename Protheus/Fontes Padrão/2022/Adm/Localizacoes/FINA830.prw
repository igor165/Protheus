#Include 'Protheus.ch'
#Include 'Fina830.ch'
#Include 'topconn.ch'


/*{Protheus.doc} FINA830
Actualización de porcentajes de exención de percepción 
y retención del IVA de acuerdo al padrón emitido por la AFIP.

@author Mayra L. Camargo 
@since 01/08/2013
@version P11
/*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS     ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez ³01/07/15³PCREQ-4256³Se elimina la funcion  UpdData() y se   ³±±
±±³              ³        ³          ³usa PUTMV() para actualizar el parametro³±±
±±³              ³        ³          ³MV_RG2226 por motivo de adecuacion de   ³±±
±±³              ³        ³          ³fuentes para nuevas estructura de  SX   ³±±
±±³              ³        ³          ³para Version 12.                        ³±±
±±³Jonathan Glez ³09/10/15³PCREQ-4261³Merge v12.1.8                           ³±±
±±³   Marco A.   ³06/12/16³SERINN001 ³Se aplican los cambios de Ctree en los  ³±±
±±³              ³        ³-119      ³CriaTrab que crean tablas temporales    ³±±
±±³              ³        ³          ³fisicas. (ARG)                          ³±±
±±³Luis Enriquez ³24/02/17³MMI-282   ³Merge 12.1.14 MI En funcion UpdSFH se   ³±±
±±³              ³        ³          ³modifica llenado para campo de zona fis-³±±
±±³              ³        ³          ³cal (FH_ZONFIS), y se agrego llenado de ³±±
±±³              ³        ³          ³campos Exento(FH_ISENTO) y Paga IB      ³±±
±±³              ³        ³          ³(FH_APERIB)y modifica funcion getStruc  ³±±
±±³              ³        ³          ³para que se haga busqueda de acuerdo al ³±±
±±³              ³        ³          ³alias con el orden 1 de SX3 y obtener   ³±±
±±³              ³        ³          ³estructura (Argentina).                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA830()
	
	Local cCombo01	:= ""
	Local aCombo	:= {}
	Local aArea		:= getArea()
	Local oFld		:= Nil
	Local dPer		:= SUPERGETMV("MV_RG2226",.F.,CTOD(""),)
	Local cPer		:= DTOS(dPer)
	
	Private cMes	:= SubStr(cPer,5,2)
	Private cAno	:= SubStr(cPer,1,4)
	Private oDlg	:= Nil
	Private lAct	:= .F.

	aAdd(aCombo, STR0002) //"1- Fornecedor"
	aAdd(aCombo, STR0003) //"2- Cliente"
	aAdd(aCombo, STR0004) //"3- Ambos"
	
	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Porcentaje de Exención de Percepción y Retención del IVA"
		 
		@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"		
		@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
		@ 020,010 COMBOBOX oCombo VAR cCombo01 ITEMS aCombo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo01)		
		@ 041,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,075 //"&Importação de Arquivo TXT"
		
		//+----------------
		//| Campos Folder 2
		//+----------------
		@ 005,005 SAY STR0009 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina actualiza los porcentajes de exención de    "
		@ 015,005 SAY STR0010 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepción y retención del IVA deacuerdo al padrón  "
		@ 025,005 SAY STR0011 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"emitido por la AFIP.   "                        "		
		@ 045,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
		@ 045,055 SAY cMes  	 SIZE 015,008 PIXEL OF oFld:aDialogs[1]	                                          
		@ 045,070 SAY "/"     SIZE 150, 8  PIXEL OF oFld:aDialogs[1]
		@ 045,075 SAY cAno    SIZE 020,008 PIXEL OF oFld:aDialogs[1]	
		
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0013 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cCombo01) //"&Importar"
		@ 075,178 BUTTON STR0014 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

	ACTIVATE MSDIALOG oDlg CENTER
		
	RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq ³ Autor ³ Mayra Camargo         ³ Data ³ 09.06.2011 ³±±
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
Static Function ImpArq(aCombo,cCombo01)
	
	Local nPos		:= 0
	Local cLine		:= ""
	Local cFile		:= ""
	Local cTmp		:= "TRD"
	Local cArq		:= ""
	Local aStru		:= {}
	Local nOpc		:= 0
	Local lImp		:= .F.
	Local aArea		:= getArea()
	Local aOrdem	:= {}

	Private dDataIni	:= ""
	Private dDataFim	:= ""
	Private oTmpTable	:= Nil
	
	nOpc := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo01)})

	// Seleciona o arquivo
	cFile := FGetFile()
		
	If File(cFile) .And. !Empty(cFile)     
		
		//creamos la tabla temporal
		AADD(aStru,{ "CUIT"    , "C",  14, 0})
		AADD(aStru,{ "DESDE"   , "D",   8, 0})
		AADD(aStru,{ "HASTA"   , "D",   8, 0})
		AADD(aStru,{ "EXEN"    , "N",   6, 2})
		
		aOrdem := {"CUIT"}
		
		oTmpTable := FWTemporaryTable():New("TRD")
		oTmpTable:SetFields(aStru) // mc
		oTmpTable:AddIndex("IN1", aOrdem)
		oTmpTable:Create()
		
		// Se procesa archivo de texto				
		Processa({|| lImp := ImpFile(cFile,"TRD")}, STR0015, STR0015, .T.)
		
		If lImp // Si el archivo fue procesado		
			Processa({|| RunProc(nOpc, "TRD")}, STR0015, STR0019, .T.)		
		EndIF
		
	Else
		Return Nil
	EndIF
		                                 
	// Faz a importacao normal

	If lAct
		MsgAlert(STR0023)
	Else
		MsgAlert(STR0024)
	End If         	
	RestArea(aArea)         	
	oDlg:End()	
	If oTmpTable <> Nil
        oTmpTable:Delete()
    EndIF
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleção do arquivo txt a ser importado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretori e arquivo selecionado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0018,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0018,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
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
/*/
Static Function FGetDir(oTGet)
	Local cDir := ""
	
	cDir := cGetFile(,STR0018,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*/-----------------------------------------------------------------------------------
//|	ImpFile: Procesa el archivo de texto y coloca su contenido en tabla temporal TRD
//------------------------------------------------------------------------------------*/
Static Function ImpFile(cFile,cAlias)
	Local cBuffer	 	:= ""
	Local nFor			:= 0
	Local cDataI		:= ""		
	Local cDataF		:= ""
	Local nHandle		
	Local nX			:= 0
	Local lRet := .F.
	
	dbSelectArea(cAlias)	
	
	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	if nHandle = -1  
		MsgAlert(STR0016 + cFile + STR0017)
		return .F.
	endif
	// Se posiciona en la primera línea
	FT_FGoTop()
	
	nFor := FT_FLastRec()
	
	ProcRegua(nFor)
	
	While !FT_FEOF()   
		nX++
		nRecno 	:= FT_FRecno()  
		IncProc(STR0019 + str(nX))
		cBuffer  	:= FT_FReadLn() // lee cada línea del archivo
		
		// Retorna a linha corrente  
		IF cBuffer <> space(len(cBuffer)) .and. substr(cbuffer,1,1)== " "
			cDataI 	:= substr(cBuffer,75,10)	//Desde
			cDataF		:= substr(cBuffer,86,10) // Hasta
			
			Reclock("TRD",.T.)
					TRD->CUIT := SUBSTR(cBuffer,2,12) // CUIT
					TRD->DESDE:= CTOD(cDataI)
					TRD->HASTA:= CTOD(cDataF)
					TRD->EXEN := val(substr(cBuffer,106,108)) //% De Exención
			TRD->(MsUnlock())
	 
			FT_FSKIP() // Salta a siguiente línea
		Else
			lRet := .T.
			FT_FUSE()
			return .T.
		End if	
	End
	// Fecha o Arquivo
	FT_FUSE()
		
Return lRet

/*/-----------------------------------------------------------------------------------
//|	RunProc: Procesa clientes, proveedores o ambos dependiendo de nOpc
//------------------------------------------------------------------------------------*/
Static Function RunProc(nOpc,cAlias)
	Do Case
		case nOpc ==1//Proveedores 
			ProcProv()	
		case nOpc == 2//Clientes
			ProcCli() 
		case nopc ==3 //Ambos			
			ProcCli()
			ProcProv()
	End Case
	
	PUTMV("MV_RG2226", DTOS(dDatabase))
	TRD->(dbCloseArea()) // Cierra tabla temporal
Return

/*/-----------------------------------------------------------------------------------
//|	Proceso de clientes
//------------------------------------------------------------------------------------*/
Static Function ProcCli()
	Local cQuery	:= ""	
	Local cSA1		:= ""
	Local cTmp		:= ""                              
  	Local aTmp		:= {}
  	Local nReg		:= 0
  	Local nI		:= 0
  	Local cClave	:= ""
	Local aArea	:= {}
	
	// Seleccionar clientes  que no estén bloqueados cuyo CUIT no esté vacío y no hayan sido eliminados
	// para todas las filiales
	
	cSA1 	:= InitSqlName("SA1")
	cTmp 	:= criatrab(nil,.F.)    
	cQuery := "SELECT *  "
	cQuery += "FROM "
	cQuery +=		cSA1 + " SA1 " 
	cQuery += 	"WHERE "
	cQuery +=  	"A1_MSBLQL <> '1'  AND "
	cQuery += 		"A1_CGC <> ' ' AND "
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY A1_CGC "
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
 
   	Count to nCont
    (cTmp)->(dbGoTop())
        
   ProcRegua(nCont) 
	While (cTmp)->(!eof())
		nI++
    	IncProc(STR0020 + str(nI))
    	cClave := (cTmp)->A1_CGC
    	
    	dbSelectArea("TRD")
    	trd->(dbSetOrder(1))
    	
    	// Se realiza la búsqueda por CUIT del cliente en la tabla Temporal 
    	If TRD->(dbSeek(cClave))
    		aArea:= getArea()
    		//Si el registro es encontrado, se sigue con el proceso en SFH
    		UpdSFH(cTmp,TRD->DESDE,TRD->HASTA,TRD->EXEN,.T.,cClave)
		  	RestArea(aArea)				
    	End If    	
  
    	(cTmp)->(dbSkip())	
    
    End Do
    (cTmp)->(dbCloseArea()) 
    
Return

/*/-----------------------------------------------------------------------------------
//|	Actualiza SFH según las condiciones dadas
//------------------------------------------------------------------------------------*/
Static Function UpdSFH(cAlias,dDesde,dHasta,nExen,lCli,cClave)

	Local cQuery	:= ""	
	Local cSFH		:= ""
	Local cTmp		:= ""                              
  	Local aTmp		:= {}
  	Local nReg		:= 0
  	Local cPref		:= IIF(lCli,"A1","A2")
  	Local aStrut	:= getStruct("SFH")
  	Local j			:= 0
	Local lIntSynt 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
	Local lPosFlag 	:= SA1->(FieldPos("A1_POSFLAG")) > 0
	Local lPosDtEx 	:= SA1->(FieldPos("A1_POSDTEX")) > 0	 
	
	Default cClave  := ""
	
	cSFH 	:= InitSqlName("SFH")
	cTmp 	:= criatrab(nil,.F.)  
	
	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT *  "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE "
	
	If lCli
		cQuery += 		"FH_FILIAL ='" + (cAlias)->A1_FILIAL + "' AND "
		cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  + "' AND "
		cQuery += 		"FH_LOJA   ='" + (cAlias)->A1_LOJA   + "' AND "
	Else
		cQuery += 		"FH_FILIAL ='" + (cAlias)->A2_FILIAL + "' AND "
		cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD	  + "' AND "
		cQuery += 		"FH_LOJA   ='" + (cAlias)->A2_LOJA   + "' AND "
	End IF
	
	cQuery +=		"FH_IMPOSTO='IVP' AND "
	cQuery +=		"D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY  FH_FIMVIGE DESC  "
	
	cQuery := ChangeQuery(cQuery)                    

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
 	TCSetField(cTmp,"FH_INIVIGE","D")
 	TCSetField(cTmp,"FH_FIMVIGE","D") 
 	 
   	Count to nCont
   (cTmp)->(dbGoTop())
	while (cTmp)->(!EOF()) 
		
		If (cTmp)->	FH_FIMVIGE == CTOD('//') .OR. (cTmp)->	FH_FIMVIGE == Nil  // Busca registro con FH_FIMVIGE Vació o null
			nReg := (cTmp)->r_e_c_n_o_	
			For j:=1 to len(aStrut)	
				aADD(aTmp,{aStrut[j],(cTmp)->&(aStrut[j])})
			Next j	
			Exit				
		End If
		
		(cTmp)->(dbSkip())	
	End Do
	
	(cTmp)->(dbGoTop())
	IF nCont > 0	//Si existe el registro			
		If ((cTmp)->FH_INIVIGE == dDesde .and. (cTmp)->FH_FIMVIGE == dHasta .and. (cTmp)->FH_PERCENT== nExen)
			(cTmp)->(dbCloseArea())
			Return
		ElseIF ((cTmp)->FH_INIVIGE <> dDesde .or. (cTmp)->FH_FIMVIGE <> dHasta .or. (cTmp)->FH_PERCENT<> nExen)
				//Si la fecha DESDE es mayor a DTFIM
			If nReg == 0
				If dDesde > (cTmp)->FH_FIMVIGE
					//Inserta nuevo registro
					Reclock("SFH",.T.)
						
					For j:=1 To Len(aStrut)
						If FieldPos(aStrut[j]) > 0
							FieldPut(FieldPos(aStrut[j]),(cTmp)->&(aStrut[j]))
						EndIf
					Next j
		
					SFH->FH_PERCENT		:= nExen
					SFH->FH_INIVIGE		:= dDesde
					SFH->FH_FIMVIGE		:= dHasta
							
					MsUnlock()
					lAct := .T. 
				End If
			Else
				//Inserta nuevo registro en base al registro en FIMVIGE Vacío
					Reclock("SFH",.T.)
						
					For j:=1 To Len(aTmp)
						If FieldPos(aTmp[j,1]) > 0
							FieldPut(FieldPos(aTmp[j,1]),(aTmp[j,2]))
						EndIf
					Next j
					
					SFH->FH_PERCENT		:= nExen
					SFH->FH_INIVIGE		:= dDesde
					SFH->FH_FIMVIGE		:= dHasta
							
					MsUnlock()
					lAct := .T. 
			End If
		End If				
		
	Else
	
		IF lCli
			// Si no existe registro
			// Se genera nuevo registro
			// aplica solo para la opción clientes.
			Reclock("SFH",.T.)
				
				SFH->FH_FILIAL		:= (cAlias)->&(cPref+"_FILIAL")
				SFH->FH_ZONFIS		:= (cAlias)->&(cPref+"_EST")
				SFH->FH_ISENTO		:= 'N'
				SFH->FH_APERIB		:= 'N'
				SFH->FH_AGENTE      := 'N'
				SFH->FH_CLIENTE 	:= (cAlias)->&(cPref+"_COD")
				SFH->FH_LOJA 		:= (cAlias)->&(cPref+"_LOJA")
				SFH->FH_NOME		:= (cAlias)->&(cPref+"_NOME")
				SFH->FH_IMPOSTO		:= 'IVP'
				SFH->FH_PERCIBI		:= 'N'
				SFH->FH_PERCENT		:= nExen
				SFH->FH_INIVIGE		:= dDesde
				SFH->FH_FIMVIGE		:= dHasta
				SFH->FH_TIPO		:= 'I'
				   
			SFH->(MsUnlock())
			lAct := .T.
		End IF
	End IF
	
   	//Caso integracao Synthesis esteja ativa e tenha atualizado algum registro na SFH atualiza o cliente para envio ao Bridge		              
	If lAct	.AND. !Empty(cClave)
		If lIntSynt .AND. lPosFlag .AND. lPosDtEx 
    		AtuSynt(cClave)
   	  	EndIf
	EndIf 
	
	(cTmp)->(dbCloseArea())
Return
/*/+-----------------------------------------------------------------------------------+
// |Procesa Proveedores																   |
// +-----------------------------------------------------------------------------------+*/
Static function ProcProv()

	Local cQuery	:= ""	
	Local cSA2		:= ""
	Local cTmp		:= ""                              
  	Local aTmp		:= {}
  	Local nReg		:= 0
  	Local nI		:= 0
  	Local cClave	:= ""  
  	Local nExen	:= 0
  	Local dDesde	
  	Local dHasta	
  	Local aArea	:= {}

	//Se procesa tabla SM0 para buscar el CUIT de la empresa en el padrón (tabla temp. TRD)
	lEmp := ProcEmp(@nExen,@dDesde,@dHasta)
		
	//If lEmp	//Si encontró registros en la SM0
	
		//Ejecuta query en (SA2) en donde se seleccionen proveedores activos, cuit no vacío, no eliminados		
		//para todas las filiales y ordernados por CUIT
		
		cSA2 	:= InitSqlName("SA2")
		cTmp 	:= criatrab(nil,.F.)    
		cQuery := "SELECT * "
		cQuery += "FROM "
		cQuery +=		cSA2 + " SA2 " 
		cQuery += 	"WHERE "
		cQuery +=  	"A2_MSBLQL <> '1'  AND "
		cQuery += 		"A2_CGC <> ' ' AND "
		cQuery +=	"D_E_L_E_T_ = ' ' "
		cQuery	+=	"ORDER BY A2_CGC "
		
		cQuery := ChangeQuery(cQuery)                    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	 
	   	Count to nCont
	    (cTmp)->(dbGoTop())
	        
	   ProcRegua(nCont) 
		While (cTmp)->(!eof())
			nI++
	    	IncProc(STR0021 + str(nI))
	    	dbSelectArea("TRD")
	    	TRD->(dbgotop())
	    	TRD->(dbSetOrder(1))
  
	    	// Se realiza la búsqueda por CUIT del cliente en la tabla Temporal 
	    	If TRD->(dbSeek((cTmp)->A2_CGC))
	    		aArea := getArea()
				// Proveedores retención
				// Actualiza el registro en SA2 del proveedor en proceso
				cClave := (cTmp)->A2_FILIAL+(cTmp)->A2_COD+(cTmp)->A2_LOJA
			
				UpdProv(cClave,TRD->DESDE,TRD->HASTA,TRD->EXEN,.F.)	
				
				// Proveedores Percepción
	    		//Si el CUIT de la empresa es encontrado en el padrón, se sigue con el proceso en SFH para el proveedor en proceso
	    		IF lEmp
	    			UpdSFH(cTmp,dDesde,dHasta,nExen,.F.)
	    		End IF
			  	RestArea(aArea)				
	    	End If    	
	    	
	    	(cTmp)->(dbSkip())	
	    
	    End Do
	    (cTmp)->(dbCloseArea()) 
	    
    //End If

Return

/*/-----------------------------------------------------------------------------------
//|	Procesa empresas
//------------------------------------------------------------------------------------*/
Static Function ProcEmp(nExen, dDesde, dHasta)
		
	Local lRet := .F.
	Local aArea:= getArea()
	dbSelectArea("SM0")
	sm0->(dbSetOrder(1))
	SM0->(dbgotop())
	
	While SM0->(!EOF()) .and. !lRet //Se recorre SM0 y no se ha encontrado cuit en padrón
		dbSelectArea("TRD")
		TRD->(dbSetOrder(1))
		TRD->(dbSeek(SM0->M0_CGC)) //Se busca registro en tab temporal(TRD) por CIUT
		
		If Found() .and. !lRet //Si es encontrado
		
		// Se toma el valor de % de exención y fechas desde y hasta
			nExen 	:= 	TRD->EXEN
			dDesde := 	TRD->DESDE
			dHasta :=	TRD->HASTA 
			lRet 	:= 	.T.
		End IF
		
		SM0->(DbSkip())
	EndDo

	RestArea(aArea)
Return lRet
/*/-----------------------------------------------------------------------------------
//|	Obtiene la estructura de la SFH para generar un registro nuevo
//------------------------------------------------------------------------------------*/
Static function getStruct(cAlias)
	Local aArea := getArea()
	Local aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
		aadd(aStru,SX3->X3_campo)
		SX3->(DBsKIP())
	End do
	RestArea(aArea)
Return aStru
/*/-----------------------------------------------------------------------------------
//|	Actualiza tabla de proveedores 
//------------------------------------------------------------------------------------*/
Static function UpdProv(cClave,dDesde, dHasta,nExen)
	Local aArea:= getArea()
	dbSelectArea("SA2")
	SA2->(dbgotop())
	SA2->(dbsetorder(RETORDEM("A2_FILIAL+A2_COD+A2_LOJA")))
	
	IF SA2->(DBSEEK(cClave))
		RecLock("SA2",.F.)
			SA2->A2_PORIVA	:= ( 100 - nExen )
			SA2->A2_IVPDCOB	:= dDESDE
			SA2->A2_IVPCCOB	:= dHASTA			
		SA2->(MsUnlock())
	End IF
	lAct	:= .T.
	RestArea(aArea)
Return


/*/-----------------------------------------------------------------------------------
//|	Actualiza tabla de cliente para integracao Synthesis
//------------------------------------------------------------------------------------*/
Static function AtuSynt(cClave)

Local aArea:= getArea()

Default cClave := ""

dbSelectArea("SA1")
SA1->(dbgotop())
SA1->(dbsetorder(3))
	
If SA1->(DbSeek(FwXFilial("SA1")+cClave))
	If SA1->A1_POSFLAG == "1"
		RecLock("SA1",.F.)
		SA1->A1_POSDTEX			
		SA1->(MsUnlock())
    EndIf
EndIf

RestArea(aArea)

Return
