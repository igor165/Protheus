#Include 'Protheus.ch'
#Include 'FISA067.ch'
#Include 'topconn.ch'

#DEFINE _SEPARADOR ";"
#DEFINE _POSCGC     4
#DEFINE _POSFCHPUB  1
#define	_POSINIVIG  2
#DEFINE _POSFINVIG  3
#DEFINE _POSTIPO    5
#DEFINE _POSALTA    6
#DEFINE _POSMARCAL  7
#DEFINE _POSALICP   8
#DEFINE _POSALICR   9
#DEFINE _POSGRPPER 10
#DEFINE _POSGRPRET 11
#DEFINE _POSRAZON  12

#DEFINE _BUFFER 16384

//-------------------------------------------------------------------
/* {Protheus.doc} 

@author Mayra L. Camargo 
@since 22/03/2013
@version P11
@cambios Alf. Medrano 27/12/16  SERINN001-543
creación de tablas temporales se asigna FWTemporaryTable en func. ImpArq
Alf. Medrano 12/01/17  SERINN001-543 merge Main vs 12.1.15
@cambios Jose Glez 28/08/17 DMIMIX-89
creacion de tablas temporales se asigna FWTemporaryTable
/*/
//-------------------------------------------------------------------

Function FISA067(aAuto)

	Local	oFld   		:= Nil
	Local   aCombo := {}
	Local cFileAuto	:= ""
	Private cPerVig		:= Space(6)
	Private oGet		:= Nil
	Private oDlg   		:= Nil
	Private lAct		:= .F.
	Private cMes   := StrZero(Month(dDataBase),2)
	Private cAno   := StrZero(Year(dDataBase),4)
	Private lRet   := .T.
	Private lPer   := .T.
	Private cCombo := ""
	Private aLinea := {}
	Private cTipoRG := ""
	Private cTitulo1 := ""
	Private cInfo1   := 1
	Private cInfo2   := 1
	Private lVBanco	:= "MSSQL"$Upper(TCGetDB())
	Private lDBPostgre	:= "POSTGRES"$Upper(TCGetDB())
	Private aSucEmp  := {}
	
	Public aQry := {}

	Default aAuto 	:= {} 
	/*{"RES816-14" o "RES364-16",
	"1" - Fornecedor o  "2" - Cliente o "3"- Ambos,
	 cAno,
	 cMes,
	 cFile Ejemplo: /SYSTEM/baselien/dmicns14203.txt,
	 lPer,
	 lRet}*/

	If Len(aAuto) > 0
		cTipoRG 	:= aAuto[1]
		cCombo  	:= aAuto[2]
		cAno		:= aAuto[3]
		cMes		:= aAuto[4]
		cFileAuto	:= aAuto[5]
		lPer		:= aAuto[6]
		lRet		:= aAuto[7]

		If !Empty(cTipoRG) .and. !Empty(cCombo) .and. !Empty(cAno) .and. !Empty(cMes) .and. !Empty(cFileAuto)
			ImpArq(Val(Subs(cCombo,1,1)),cFileAuto)
		EndIf
	Else
		aAdd( aCombo, "1.- RES 816-14 | Padrón Alicuotas Diferenciales y Otros" )
		aAdd( aCombo, "2.- RES 364-16 | Padrón Regímenes Generales" )

		DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 125,450 OF oDlg PIXEL

		@ 006,006 TO 040,170 LABEL STR0034 OF oDlg PIXEL
		@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 155,8 PIXEL OF oFld
		@ 005,175 BUTTON STR0035 SIZE 036,016 PIXEL ACTION {|| VldTipoRG(Val(Subs(cCombo,1,1))), oDlg:End(), aCombo := {}} //"&Importar"
		@ 025,175 BUTTON STR0014 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"
		
		ACTIVATE MSDIALOG oDlg CENTER
		
		If !Empty(cTipoRG)
			
			aAdd( aCombo, STR0002 ) //"1- Fornecedor"
			aAdd( aCombo, STR0003 ) //"2- Cliente"
			aAdd( aCombo, STR0004 ) //"3- Ambos"


			DEFINE MSDIALOG oDlg TITLE cTitulo1 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Porcentaje de Exención de Percepción y Retención del IVA"
		
			@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
			@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)
		
			//+----------------------
			//|  Campos Check-Up
			//+----------------------
			@ 10,115 SAY STR0027 SIZE 065,008 PIXEL OF oFld //"Imposto: "
			@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0028 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)  //"Percepcao"
			@ 030,115 CHECKBOX oChk2 VAR lRet PROMPT STR0029 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Retencao"
			@ 041,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,075 //"&Importação de Arquivo TXT"
			
			//+----------------
			//| Campos Folder 2
			//+----------------
			@ 005,005 SAY cInfo1 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
			@ 015,005 SAY cInfo2 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo TXT  "                    "
			@ 045,005 SAY STR0030 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
			@ 045,055 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]	                                          
			@ 045,080 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
			@ 045,085 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]
		
		
			//+-------------------
			//| Boton de MSDialog
			//+-------------------
			@ 055,178 BUTTON STR0013 SIZE 036,016 PIXEL ACTION ImpArq(Val(Subs(cCombo,1,1))) //"&Importar"
			@ 075,178 BUTTON STR0014 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"
		
			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	EndIf
		

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq ³ Autor ³ Mayra Camargo         ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa archivo y modifica datos				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(nOpc, cFileAuto)

	Local nPos     	:= 0
	Local cLine    	:= ""
	Local cFile    	:= ""
	Local cTmpSA1   := ""
	Local cTmpSA2   := ""
	Local cArq 		:= ""
	Local aStru		:= {}
	Local lImp		:= .F. 
	Local nI      	:= 0
	Local nJ      	:= 0
	Local oTmpTab   := Nil	// Arquivo temporario para importacao
	Local lAuto		:= IsBlind()
	Private lTempDB := .F.
	Private lBulk 	:= .T.
	Private _cCont		:= 0
	Private dDataIni	:= ""
	Private dDataFim 	:= ""
	Private lAct		:= .F.
	Private lExistEmp := .F.
	Private nPerEmp  := 0
	Private aEstSFH := SFH->(DBSTRUCT())
	Private dIniVige  := CTOD("//")
	Private dFinVige  := CTOD("//")
	Private cTmpTRD := GetNextAlias()
	Private oTmpTable := Nil	// Arquivo temporario para importacao

	Default cFileAuto := ""
	
	// Seleciona o arquivo
	cFile := Iif(!Empty(cFileAuto),cFileAuto,FGetFile())
	If VldFech(cFile)	
		IF File(cFile) .And. !Empty(cFile)
			
			If lVBanco
				Processa( {|| lImp:=ImpASql(cFile)}, STR0015,STR0015, .T. )
			EndIf
			If lDBPostgre
				Processa( {|| lImp:=ImpPostGre(cFile)}, STR0015,STR0015, .T. )
			EndIf
			If !lImp
				lBulk := .F.
				If FwBulk():CanBulk()
					Processa( {|| lImp:=ImpBulk(cFile)}, STR0015,STR0015, .T. )
				Else
					If CreaTabla(cTmpTRD)[1][1]
						Processa( {|| lImp:=ImpFile(cFile,nOpc)}, STR0015,STR0015, .T. )
					EndIf
				EndIf	
			End IF
			
			If lImp
				
				Processa( {|| lExistEmp := ProcEmp()} , STR0015,STR0019, .T. )
				For nI := 1 To Len(aSucEmp)
					For nJ := 1 To Len(aSucEmp[nI][1])
						lExistEmp :=  aSucEmp[nI][3]
						nPerEmp   := aSucEmp[nI][4]
						
						If (nOpc == 2 .Or. nOpc == 3) .And. lPer  //Percepcion Clientes
							Processa( {|| PadReduc(@cTmpSA1, "A1", aSucEmp[nI][1][nJ],@oTmpTab)}, STR0015,STR0015, .T. )
							Processa( {|| ProcRegs(.T.,.T.,cTmpSA1, aSucEmp[nI][1][nJ])}, STR0015,STR0020, .T. ) //Clientes    Percepciones	
							If Select(cTmpSA1) <> 0
								(cTmpSA1)->(dbCloseArea())
								DelTab(cTmpSA1)
								oTmpTab:Delete()
								oTmpTab := Nil
							EndIf
						EndIf
						If  nOpc == 1 .Or. nOpc == 3   
							Processa( {|| PadReduc(@cTmpSA2, "A2", aSucEmp[nI][1][nJ],@oTmpTab)}, STR0015,STR0015, .T. )
							If  lPer
								Processa( {|| ProcRegs(.F.,.T.,cTmpSA2, aSucEmp[nI][1][nJ])}, STR0015,STR0021, .T. )    //Proveedores Percepciones
							EndIf
							If  lRet
								Processa( {|| ProcRegs(.F.,.F.,cTmpSA2, aSucEmp[nI][1][nJ])}, STR0019,STR0021, .T. ) //Proveedores Retenciones
							EndIf
							
							If Select(cTmpSA2) <> 0
								(cTmpSA2)->(dbCloseArea())
								DelTab(cTmpSA2)
								oTmpTab:Delete()
								oTmpTab := Nil
							EndIf
						EndIf
					Next
				Next
				If Select(cTmpTRD) <> 0
					(cTmpTRD)->(dbCloseArea())
				EndIf
			    DelTab(cTmpTRD)
			EndIf
	
		Else
			Return Nil
		EndIf
		
		If !lAuto
			If lAct
				MsgAlert(STR0023)
			Else
				MsgAlert(STR0024)
			End If        	
			oDlg:End()
		EndIf 
	EndIf
	
	If lTempDb
		oTmpTable:Delete()
	Endif
	
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
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
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
	
	cDir := cGetFile(,STR0019,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*/-----------------------------------------------------------------------------------
//|	ImpFile: Procesa el archivo csv y coloca su contenido en tabla temporal TRD
//------------------------------------------------------------------------------------*/
Static Function ImpFile(cFile,nOpc)

	Local cBuffer	 	:= ""
	Local nFor			:= 0
	Local nHandle		
	Local nX			:= 0
	Local lReturn		:= .T.
	Local cCuit			:= Space(TamSX3("A2_CGC")[1])
	Local nPosI			:= 0
	Local nPosF			:= 0
	Local cAux			:= ""
	Local oFile
	Local aInforma		:= {}
	Local cCGCEmp		:= ""
	Local nCGCEmp		:= ""
	Local nPosCGC		:= 0
	Local lCGC			:= .T.
	Local cQueryA1		:= ""
	Local cQueryA2		:= ""
	Local xFilialSA1	:= xFilial("SA1")
	Local xFilialSA2	:= xFilial("SA2")
	Local nPosCli		:= 0
	Local nPosFor		:= 0
	Local nCuitCli		:= 0
	Local nCuitFor		:= 0
	Local nPrimer		:= 0
	Local nUltimo		:= 0
	Local nTamCgc		:= TAMSX3("A2_CGC")[1]
	Local nRegs			:= 0 
	Local nTotal		:= 0
	Local cIniVige		:= ""
	Local cFinVige		:= ""
	Local lCli			:= Iif(nOpc == 2 .Or. nOpc == 3, .T., .F.)
	Local lFor			:= Iif(nOpc == 1 .Or. nOpc == 3, .T., .F.)
	Local nI 			:= 0
	Local aAreaSM0		:= SM0->(GetArea())
	Local aCgcEmp		:= {}
	Local nPosEmp		:= 0

	
	If lCli .and. lPer  
		cQueryA1 := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME"
		cQueryA1 += " FROM " + RetSqlName("SA1") + " SA1"
		cQueryA1 += " WHERE A1_FILIAL = '" + xFilialSA1 + "' AND"
		cQueryA1 += " A1_CGC <> '' AND"
		cQueryA1 += " D_E_L_E_T_ <> '*'"
		cQueryA1 += " ORDER BY A1_CGC ASC"
		cQueryA1 := ChangeQuery(cQueryA1)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryA1), "cSA1", .T., .T.)
		cSA1->(dbGoTop())
		count to nRegs
		cSA1->(dbGoTop())
		nTotal += nRegs
		
	EndIf
	
	If lFor	.and. lRet
		cQueryA2 := "SELECT A2_COD, A2_LOJA, A2_CGC, A2_NOME"
		cQueryA2 += " FROM " +  RetSqlName("SA2")  + " SA2"
		cQueryA2 += " WHERE A2_FILIAL = '" + xFilialSA2 + "' AND"
		cQueryA2 += " A2_CGC <> '' AND"
		cQueryA2 += " D_E_L_E_T_ <> '*' "
		cQueryA2 += " ORDER BY A2_CGC ASC"
		cQueryA2 := ChangeQuery(cQueryA2)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryA2), "cSA2", .T., .T.)
		cSA2->(dbGoTop())
		count to nRegs
		cSA2->(dbGoTop())
		nTotal += nRegs
		
	EndIf
	
	dbSelectArea(cTmpTRD)
	(cTmpTRD)->(dbGoTop())	
	
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbgotop())
	
	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	If nHandle = -1  
		MsgAlert(STR0016 + cFile + STR0017)	// El archivo	no puede abrirse.
		return .F.	
	Else
		// Se posiciona en la primera línea
		FT_FGoTop()
		nFor := FT_FLastRec()
		
		// Fecha o Arquivo
		FT_FUSE()
		oFile := ZFWReadTXT():New(cFile,,_BUFFER)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0007 + cFile + STR0008)  //"El archivo" CGF "no puede abrirse."
			Return .F.
		EndIf
		
		ProcRegua(nTotal)
		While oFile:ReadBlock(@aInforma,_SEPARADOR)  
			//nX++
		
			IncProc(STR0006 + str(nX))  //"Procesando archivo..."
			nPrimer := Val(aInforma[1][_POSCGC])
		 	nUltimo := Val(aInforma[Len(aInforma)][_POSCGC])
			
			If (cAno+cMes) != (SubStr(aInforma[1,2], 5, 4) + SubStr(aInforma[1,2], 3, 2))
				MsgAlert(STR0025)
				Return .F.
			EndIf
			
			If lFor .and. lPer
				While SM0->(!EOF())
					cCGCEmp		:= AllTrim(SM0->M0_CGC)
					nCGCEmp		:= Val(cCGCEmp)
					If (nPrimer <= nCGCEmp .and. nUltimo >= nCGCEmp)
				 		nPosCGC :=  ascan(aInforma,{|x| x[_POSCGC] == cCGCEmp })		 		
				 		If nPosCGC > 0
				 			nPosEmp := ascan(aCgcEmp, cCGCEmp )
				 			If nPosEmp == 0
								cIniVige := SubStr(aInforma[nPosCGC][_POSINIVIG] , 5, 4) + SubStr(aInforma[nPosCGC][_POSINIVIG] , 3, 2) + SubStr(aInforma[nPosCGC][_POSINIVIG] , 1, 2)
								cFinVige := SubStr(aInforma[nPosCGC][_POSFINVIG] , 5, 4) + SubStr(aInforma[nPosCGC][_POSFINVIG] , 3, 2) + SubStr(aInforma[nPosCGC][_POSFINVIG] , 1, 2)
								AddReg(aInforma[nPosCGC][_POSCGC], aInforma[nPosCGC][_POSFCHPUB], cIniVige, cFinVige, aInforma[nPosCGC][_POSTIPO], aInforma[nPosCGC][_POSALTA], aInforma[nPosCGC][_POSMARCAL],;
								 Replace(aInforma[nPosCGC][_POSALICP], ',', '.'), Replace(aInforma[nPosCGC][_POSALICR], ',', '.'), aInforma[nPosCGC][_POSGRPPER], aInforma[nPosCGC][_POSGRPRET], Iif(Len(aInforma[nPosCGC]) >= 12,REPLACE(aInforma[nPosCGC][_POSRAZON],'"',""),""))
								 AADD(aCgcEmp,cCGCEmp)	
							EndIf
				 		EndIf
				 		SM0->(dbSkip())
					ElseIf nCGCEmp >= nUltimo
						Exit
					ElseIf nPrimer >= nCGCEmp
						SM0->(dbSkip())
				 	EndIf
			 	EndDo
		 	EndIf
				
			If lCli .and. lPer
				While cSA1->(!EOF())
					nCuitCli := Val(AllTrim(cSA1->A1_CGC))
					If (nPrimer <= nCuitCli .and. nUltimo >= nCuitCli)
						nPosCli :=  ascan(aInforma,{|x| x[_POSCGC] == AllTrim(cSA1->A1_CGC) })
						If nPosCli > 0	
							cIniVige := SubStr(aInforma[nPosCli][_POSINIVIG] , 5, 4) + SubStr(aInforma[nPosCli][_POSINIVIG] , 3, 2) + SubStr(aInforma[nPosCli][_POSINIVIG] , 1, 2)
							cFinVige := SubStr(aInforma[nPosCli][_POSFINVIG] , 5, 4) + SubStr(aInforma[nPosCli][_POSFINVIG] , 3, 2) + SubStr(aInforma[nPosCli][_POSFINVIG] , 1, 2)
							AddReg(aInforma[nPosCli][_POSCGC], aInforma[nPosCli][_POSFCHPUB], cIniVige, cFinVige, aInforma[nPosCli][_POSTIPO], aInforma[nPosCli][_POSALTA], aInforma[nPosCli][_POSMARCAL],;
							 Replace(aInforma[nPosCli][_POSALICP], ',', '.'), Replace(aInforma[nPosCli][_POSALICR], ',', '.'), aInforma[nPosCli][_POSGRPPER], aInforma[nPosCli][_POSGRPRET], Iif(Len(aInforma[nPosCli]) >= 12,REPLACE(aInforma[nPosCli][_POSRAZON],'"',""),""))
						EndIf
						cSA1->(dbSkip())
						nX ++
					ElseIf nCuitCli >= nUltimo
						Exit
					ElseIf nPrimer >= nCuitCli
						cSA1->(dbSkip())
						nX ++
					EndIf
				Enddo
			EndIf
			
			If lFor .and. lRet
				While cSA2->(!EOF())
					nCuitFor := Val(AllTrim(cSA2->A2_CGC))
					If (nPrimer <= nCuitFor .and. nUltimo >= nCuitFor)
	 					nPosFor :=  ascan(aInforma,{|x| x[_POSCGC] == AllTrim(cSA2->A2_CGC) })
						If nPosFor > 0
							cIniVige := SubStr(aInforma[nPosFor][_POSINIVIG] , 5, 4) + SubStr(aInforma[nPosFor][_POSINIVIG] , 3, 2) + SubStr(aInforma[nPosFor][_POSINIVIG] , 1, 2)
							cFinVige := SubStr(aInforma[nPosFor][_POSFINVIG] , 5, 4) + SubStr(aInforma[nPosFor][_POSFINVIG] , 3, 2) + SubStr(aInforma[nPosFor][_POSFINVIG] , 1, 2)
							AddReg(aInforma[nPosFor][_POSCGC], aInforma[nPosFor][_POSFCHPUB], cIniVige, cFinVige, aInforma[nPosFor][_POSTIPO], aInforma[nPosFor][_POSALTA], aInforma[nPosFor][_POSMARCAL],;
							 Replace(aInforma[nPosFor][_POSALICP], ',', '.'), Replace(aInforma[nPosFor][_POSALICR], ',', '.'), aInforma[nPosFor][_POSGRPPER], aInforma[nPosFor][_POSGRPRET], Iif(Len(aInforma[nPosFor]) >= 12,REPLACE(aInforma[nPosFor][_POSRAZON],'"',""),""))
						EndIf
						cSA2->(dbSkip())
						nX ++
					ElseIf nCuitFor >= nUltimo
						Exit
					ElseIf nPrimer >= nCuitFor
						cSA2->(dbSkip())
						nX ++
					EndIf
				Enddo
			EndIf		 
			
			aSize(aInforma,0)
		EndDo
		
		(cTmpTRD)->(dbGoTop())
		// Fecha o Arquivo
		oFile:Close()
		
		RestArea(aAreaSM0)
		
		If Select(cTmpTRD) == 0
			lReturn := .F.
		EndIf  
		If  (lFor .and. lPer) .And. !lReturn  //Solo se está ejecutando Cliente-Percepción y NO existe el CUIT
			lReturn := .T.
		Endif
	EndIf
			
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcRegs ³ Autor ³ M.Camargo		      ³ Data ³ 31.07.2013 ³±±
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
Static Function ProcRegs(lCli,lPer,cTabla, cSucProc)

	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSA		:= ""
	Local cTmp		:= ""                              
  	Local aTmp		:= {}
  	Local nReg		:= 0
  	Local nI		:= 0
  	Local cClave	:= ""
  	Local cPref		:= IIF(lCli,"A1","A2")
  	Local lExiste	:= .F.
	Local cMsg		:= IIF(lCli,STR0020,STR0022)
	
	// Seleccionar clientes  que no estén bloqueados cuyo CUIT no esté vacío y no hayan sido eliminados
	// para todas las filiales
	
	cSA 	:= IIF(lCli,InitSqlName("SA1"),InitSqlName("SA2"))
	cTmp 	:= GetNextAlias() 
	cQuery := "SELECT " + cPref + "_COD ," 
	cQuery +=			  cPref + "_LOJA,"
	cQuery +=			  cPref + "_CGC,  "
	If !lCli
		cQuery +=			  cPref + "_TIPROV,  "
	EndIf
	cQuery +=			  cPref + "_NOME "
	cQuery += "FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	//cQuery +=  	"A1_MSBLQL <> '1'  AND "
	cQuery += 		cPref + "_CGC <> ' ' AND "
	cQuery += cPref + "_FILIAL = '" + xFilial("S"+cPref, cSucProc) + "' AND "
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY " + cPref + "_CGC "
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
 
	Count to nCont
	(cTmp)->(dbGoTop())
    ProcRegua(nCont) 
	While (cTmp)->(!eof())      //Clientes/Proveedores
		nI++
    	IncProc(cMsg + str(nI))
    	cClave := (cTmp)->&(cPref+"_CGC")
		cClave := Replace(cClave, "-", "")
    	dbSelectArea(cTabla)
    	dbSetOrder(1)
    	
    	If (cTabla)->(MsSeek(cClave))
    		lExiste := .T.	  		
    		If  (lCli .And. lPer) .OR. (!lCli .And. lRet) 
    			dIniVige := Iif ( lBulk,STOD(SubStr((cTabla)->INIVIGE , 5, 4) + SubStr((cTabla)->INIVIGE , 3, 2) + SubStr((cTabla)->INIVIGE , 1, 2)),STOD((cTabla)->INIVIGE)) 
				dFinVige := Iif ( lBulk,STOD(SubStr((cTabla)->FINVIGE , 5, 4) + SubStr((cTabla)->FINVIGE , 3, 2) + SubStr((cTabla)->FINVIGE , 1, 2)),STOD((cTabla)->FINVIGE))
    		Endif			
    	EndIf    	
    	
    	BuscaSFH(cTmp,lCli,lPer,lExiste,cTabla,cSucProc)
    	  		
  		lExiste := .F.
    	(cTmp)->(dbSkip())	    
    End Do
    (cTmp)->(dbCloseArea())  
    RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BuscaSFH ³ Autor ³ M.Camargo		      ³ Data ³ 3.07.2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca y actualiza registros en SFH 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Tabla temp con los registros obtenidos de SA1/SA2 ³±±
±±³          ³ lCli   - Si .T. está procesando Clientes					  ³±±
±±³          ³ 			Si .F. está procesandoProveedores				  ³±±
±±³          ³ lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	  ³±±
±±³          ³ 			archivo excel 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina 			                  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuscaSFH(cAlias,lCli,lPer,lExiste,cTabla,cSucProc)

	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSFH		:= ""
	Local cTmp		:= ""                              
  	Local aTmp		:= {}
  	Local nReg		:= 0
  	Local cPref		:= IIF(lCli,"A1","A2")
  	Local j		:= 0
  	Local cPerAux	:= ""
  	Local lAliqP    := IIF(Val(Replace((cTabla)->ALICPERC, ',', '.')) == 0, .T., .F.)
  	Local lAliqR    := IIF(Val(Replace((cTabla)->ALICRETE, ',', '.')) == 0, .T., .F.)
  	Local aSFH      := {} 
  	Local nAliq     := 0  	 	
  	nYear := YEAR(STOD(cPerVig+"01"))
	
	cSFH 	:= InitSqlName("SFH")
	cTmp 	:= GetNextAlias()
	
	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT FH_FIMVIGE,FH_ALIQ,FH_PERCENT,FH_SITUACA,FH_ISENTO,R_E_C_N_O_ "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE "
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH", cSucProc)			+ "' AND "
	If lCli		
		cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
	Else
		cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
	End IF
	
	If lPer
		cQuery +=	"FH_IMPOSTO='IBP' AND "
	Else	//	Retenciones a Proveedores
		cQuery +=	"FH_IMPOSTO='IBR' AND "
	End If 
	cQuery +=   "FH_ZONFIS ='CF'  AND "
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"  
	
	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TCSetField(cTmp,"FH_INIVIGE","D",8,0)
	TCSetField(cTmp,"FH_FIMVIGE","D",8,0) 
 	 
   	Count to nCont
   (cTmp)->(dbGoTop())
       
	If nCont > 1
		(cTmp)->(dbSkip(nCont - 1))
		If !Empty((cTmp)->FH_FIMVIGE)
			(cTmp)->(dbGoTop())
		EndIf
	EndIf
    
    If (lCli .And. lPer)
    	nAliq := Val(Replace((cTabla)->ALICPERC, ',', '.'))
    ElseIf (!lCli .And. !lPer)
    	nAliq := Val(Replace((cTabla)->ALICRETE, ',', '.'))
    ElseIf !lCli .And. lPer 
    	nAliq := nPerEmp
    	lAliqP    := IIF(nPerEmp == 0, .T., .F.)
    EndIf
    nReg  := (cTmp)->R_E_C_N_O_ 
	If cTipoRG == "RES816-14"

	    If (((lPer .And. lAliqP) .And. (lCli .Or. (!lCli .And. lExistEmp))) .Or. ((!lPer .And. lAliqR) .And. !lCli))
			If (nCont > 0 .and. lExiste) .Or. (nCont > 0 .And. !lCli .And. lPer .And. lExistEmp)
				If ((cTmp)->FH_ALIQ == 0 .And. (cTmp)->FH_PERCENT == 100)				
					SFH->(DBGOTO(nReg))
					If  SFH->(!EOF())
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := dFinVige
							If  SFH->FH_SITUACA $ "1|2" .OR. empty(SFH->FH_SITUACA)
								SFH->FH_SITUACA := "5"
							EndIf
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				ElseIf (((cTmp)->FH_ALIQ <> 0 .Or. (cTmp)->FH_PERCENT <> 100 ).And. ((cTmp)->FH_FIMVIGE < dFinVige) .Or. Empty((cTmp)->FH_FIMVIGE))
					SFH->(DBGOTO(nReg))
					actRegSFH(dIniVige)
					Reclock("SFH",.F.)
						If lPer
							SFH->FH_IMPOSTO   := "IBP"
							SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
						Else
							SFH->FH_IMPOSTO   := "IBR"
							SFH->FH_ALIQ      := nAliq	
						EndIf
						SFH->FH_PERCENT  := 100
						SFH->FH_PERCIBI  := "N"
						SFH->FH_APERIB   := "N"
						SFH->FH_ISENTO   := "N"
						SFH->FH_SITUACA  := "5"
						SFH->FH_INIVIGE  := dIniVige
						SFH->FH_FIMVIGE  := dFinVige
					SFH->(MsUnlock())
				ElseIf (((cTmp)->FH_ALIQ <> 0 .Or. (cTmp)->FH_PERCENT <> 100 ) .And. (cTmp)->FH_FIMVIGE == dFinVige)
					SFH->(DBGOTO(nReg))
					If  SFH->(!EOF())
						Reclock("SFH",.F.)
							If lPer
								SFH->FH_IMPOSTO 	    := "IBP"
								SFH->FH_ALIQ		    := IIf(lCli, nAliq, nPerEmp)
							Else
								SFH->FH_IMPOSTO 	    := "IBR"
								SFH->FH_ALIQ		    := nAliq	
							EndIf
							If SFH->FH_SITUACA $ "1|2" .OR. empty(SFH->FH_SITUACA)
								SFH->FH_SITUACA := "5"
							EndIf
							SFH->FH_PERCENT		:= 100
							SFH->FH_PERCIBI		:= "N"
							SFH->FH_ISENTO		:= "N"
							SFH->FH_APERIB		:= "N"
							SFH->FH_TIPO			:= Iif(Alltrim((cTabla)->TIPO)=="D","I","V")
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				EndIf 
			ElseIf nCont == 0 .And. lExiste  .And. !(!lCli .And. lPer)  //Percepcion Clientes/Retencion a Proveedores: Alicuota cero en el padron (No existe el registro en SFH)
					Reclock("SFH",.T.)
					SFH->FH_FILIAL		:= xFilial("SFH", cSucProc)
					SFH->FH_AGENTE      := "N"
					If lCli
						SFH->FH_CLIENTE	:= (cAlias)->A1_COD
					Else  
						SFH->FH_FORNECE	:=	(cAlias)->A2_COD
					EndIf
					SFH->FH_LOJA	 	:= (cAlias)->&(cPref+"_LOJA")
					SFH->FH_NOME        := (cAlias)->&(cPref+"_NOME")
					If lPer
						SFH->FH_IMPOSTO	:= "IBP"
						SFH->FH_ALIQ	:= nAliq
					Else
						SFH->FH_IMPOSTO	:= "IBR"
						SFH->FH_ALIQ	:= nAliq	
					EndIf
					SFH->FH_PERCIBI		:= "N"
					SFH->FH_ISENTO		:= "N"
					SFH->FH_APERIB		:= "N"
					SFH->FH_ZONFIS		:= "CF"   
					SFH->FH_SITUACA		:= "5"
					SFH->FH_TIPO			:= Iif(Alltrim((cTabla)->TIPO)=="D","I","V")
					SFH->FH_PERCENT		:= 100
					SFH->FH_INIVIGE		:= dIniVige
					SFH->FH_FIMVIGE		:= dFinVige
					lAct := .T.
				SFH->(MsUnlock())	
			ElseIf nCont > 0 .And. ((!lExiste .And. (lCli .Or. (!lCli .And. !lPer))) .Or. (!lCli .And. lPer .And. !lExistEmp))
				SFH->(DBGOTO(nReg))
				If  SFH->(!EOF())
					If SFH->FH_FIMVIGE > dFinVige .Or. Empty(SFH->FH_FIMVIGE)
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := dFinVige
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				EndIf	
			EndIf
		ElseIf (lCli .And. !lAliqP .And. lPer) .Or. (!lCli .And. !lAliqR .And. !lPer) .Or. (!lCli .And. !lAliqP .And. lPer .And. lExistEmp)
			If (nCont > 0 .and. lExiste) .Or. (nCont > 0 .And. !lCli .And. lPer .And. lExistEmp)
				If ((lPer .And. (cTmp)->FH_ALIQ == nAliq) .Or. (!lPer .And. (cTmp)->FH_ALIQ == nAliq))         
					SFH->(DBGOTO(nReg))
					If  SFH->(!EOF())
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := dFinVige
							If SFH->FH_SITUACA $ "1|2" .OR. empty(SFH->FH_SITUACA)
								SFH->FH_SITUACA := "5"
							EndIf
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				ElseIf ((lPer .And. (cTmp)->FH_ALIQ != nAliq) .Or. (!lPer .And. (cTmp)->FH_ALIQ != nAliq))
					If  (cTmp)->FH_FIMVIGE == dFinVige  
						SFH->(DBGOTO(nReg))
						If  SFH->(!EOF())
							Reclock("SFH",.F.)
							If lPer
								SFH->FH_ALIQ		:= IIf(lCli, nAliq, nPerEmp)
							Else
								SFH->FH_ALIQ		:= nAliq
							EndIf  
							If SFH->FH_SITUACA $ "1|2" .OR. empty(SFH->FH_SITUACA)
								SFH->FH_SITUACA := "5"
							EndIf 
							SFH->FH_PERCENT		:= 0
							SFH->FH_PERCIBI		:= IIf(lPer, "S", "N")
							SFH->FH_APERIB		:= IIf(lPer, "S", "N")					
							SFH->FH_ISENTO		:= "N"
							SFH->FH_TIPO			:= Iif(Alltrim((cTabla)->TIPO)=="D","I","V")
							lAct := .T.
							SFH->(MsUnlock())
						EndIf
					Elseif   ((cTmp)->FH_FIMVIGE < dFinVige .OR. Empty((cTmp)->FH_FIMVIGE)) 
						SFH->(DBGOTO(nReg))
						actRegSFH(dIniVige)
						Reclock("SFH",.F.)
							If lPer
								SFH->FH_IMPOSTO   := "IBP"
								SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
							Else
								SFH->FH_IMPOSTO   := "IBR"
								SFH->FH_ALIQ      := nAliq	
							EndIf
							SFH->FH_AGENTE		:= "S"
							SFH->FH_PERCENT      := 0
							SFH->FH_SITUACA      := "5"
							SFH->FH_PERCIBI		:= IIf(lPer, "S", "N")
							SFH->FH_APERIB		:= IIf(lPer, "S", "N")
							SFH->FH_ISENTO		:= "N"
							SFH->FH_INIVIGE      := dIniVige
							SFH->FH_FIMVIGE      := dFinVige
						SFH->(MsUnlock())
						lAct := .T.
					EndIf
				EndIf
			ElseIf nCont > 0 .And. !lExiste
					SFH->(DBGOTO(nReg))
					If  SFH->(!EOF())
						If SFH->FH_FIMVIGE > dFinVige .Or. Empty(SFH->FH_FIMVIGE)
							Reclock("SFH",.F.)
								SFH->FH_FIMVIGE := dFinVige
								lAct := .T.
							SFH->(MsUnlock())
						EndIf
					EndIf	
			ElseIf (nCont == 0 .And. lExiste) .And. ((lCli .And. !lAliqP) .Or. (!lCli .And. !lAliqR .And. !lPer))
				Reclock("SFH",.T.)
					SFH->FH_AGENTE        := "S"
					If lCli
						SFH->FH_FILIAL		:= xFilial("SFH", cSucProc)
						SFH->FH_CLIENTE		:= (cAlias)->A1_COD
					Else
						SFH->FH_FILIAL		:= xFilial("SFH", cSucProc)  
						SFH->FH_FORNECE	:=	(cAlias)->A2_COD
					EndIf
					SFH->FH_LOJA		    := (cAlias)->&(cPref+"_LOJA")
					SFH->FH_NOME         := (cAlias)->&(cPref+"_NOME")
					If lPer
						SFH->FH_IMPOSTO 	    := "IBP"
						SFH->FH_ALIQ		    := nAliq
					Else
						SFH->FH_IMPOSTO 	    := "IBR"
						SFH->FH_ALIQ		    := nAliq	
					EndIf
					SFH->FH_PERCIBI		:= IIf(lPer, "S", "N")
					SFH->FH_ISENTO		:= "N"
					SFH->FH_APERIB		:= IIf(lPer, "S", "N")
					SFH->FH_ZONFIS		:= "CF"
					SFH->FH_TIPO		    := Iif(Alltrim((cTabla)->TIPO)=="D","I","V")
					SFH->FH_INIVIGE		:= dIniVige
					SFH->FH_FIMVIGE		:= dFinVige
					SFH->FH_SITUACA      := "5"
					lAct := .T.
				SFH->(MsUnlock())	
			EndIf
		ElseIf nCont > 0 .And. ((!lExiste .And. (lCli .Or. (!lCli .And. !lPer))) .Or. (!lCli .And. lPer .And. !lExistEmp))
			SFH->(DBGOTO(nReg))
			If  SFH->(!EOF())
				If SFH->FH_FIMVIGE > dFinVige .Or. Empty(SFH->FH_FIMVIGE)
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFinVige
						lAct := .T.
					SFH->(MsUnlock())
				EndIf
			EndIf
		EndIf
		
	ElseIf cTipoRG == "RES364-16"

		//(Cliente, Percepcion y Aliq Cero) o (Proveedor, Percepcion, Aliq Cero y Existe CUIT de Emp) o (Proveedor, Retencion y Aliq Cero)
		If ((lCli .And. lPer .And. lAliqP) .Or. (!lCli .And. lPer .And. lAliqP .And. lExistEmp) .Or. (!lCli .And. !lPer .And. lAliqR))
			If (nCont > 0 .and. lExiste) .Or. (!lCli .And. lPer .And. lAliqP .And. lExistEmp .And. nCont > 0)
				If ((!((cTmp)->FH_SITUACA $ "2|3|5") .And. (cTmp)->FH_ISENTO <> "S") .Or. ((cTmp)->FH_FIMVIGE <=  dIniVige) .And. !Empty((cTmp)->FH_FIMVIGE))
					If ((cTmp)->FH_ALIQ == 0 .And. (cTmp)->FH_PERCENT == 100)
						SFH->(DBGOTO(nReg))
						If  SFH->(!EOF())
							Reclock("SFH",.F.)
								SFH->FH_FIMVIGE := dFinVige
								SFH->FH_SITUACA := "1"
								lAct := .T.
							SFH->(MsUnlock())
						EndIf
					ElseIf (((cTmp)->FH_ALIQ <> 0 .Or. (cTmp)->FH_PERCENT <> 100 ) .And. ((cTmp)->FH_FIMVIGE < dFinVige) .Or. Empty((cTmp)->FH_FIMVIGE))
							SFH->(DBGOTO(nReg))
							actRegSFH(dIniVige,(cAlias)->&(cPref+"_NOME"))
							Reclock("SFH",.F.)
								If lPer
									SFH->FH_IMPOSTO   := "IBP"
									SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
								Else
									SFH->FH_IMPOSTO   := "IBR"
									SFH->FH_ALIQ      := nAliq	
								EndIf
								SFH->FH_PERCENT  := 100
								SFH->FH_PERCIBI  := "N"
								SFH->FH_APERIB   := "N"
								SFH->FH_ISENTO   := "N"
								SFH->FH_SITUACA  := "1"
								SFH->FH_INIVIGE  := dIniVige
								SFH->FH_FIMVIGE  := dFinVige
							SFH->(MsUnlock())
							lAct := .T.
					ElseIf (((cTmp)->FH_ALIQ <> 0 .Or. (cTmp)->FH_PERCENT <> 100 ) .And. (cTmp)->FH_FIMVIGE == dFinVige)
						SFH->(DBGOTO(nReg))
						If  SFH->(!EOF())
							Reclock("SFH",.F.)
								If lPer
									SFH->FH_IMPOSTO   := "IBP"
									SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
								Else
									SFH->FH_IMPOSTO   := "IBR"
									SFH->FH_ALIQ      := nAliq	
								EndIf
								SFH->FH_PERCENT		:= 100
								SFH->FH_PERCIBI		:= "N"
								SFH->FH_APERIB		:= "N"
								SFH->FH_ISENTO		:= "N"
								SFH->FH_SITUACA      := "1"
								SFH->FH_INIVIGE  := dIniVige
								SFH->FH_FIMVIGE  := dFinVige
								lAct := .T.
							SFH->(MsUnlock())
						EndIf
					EndIf
				EndIf		
			ElseIf nCont == 0 .And. lExiste .And. (lCli .And. lPer .And. lAliqP)  //Percepcion Clientes/Retencion a Proveedores: Alicuota cero en el padron (No existe el registro en SFH)
				AddRegSFH(lCli,lPer,xFilial("SFH",cSucProc),"N",(cAlias)->A1_COD,"",(cAlias)->&(cPref+"_LOJA"),(cAlias)->&(cPref+"_NOME"),"IBP",nAliq,"1",Iif(Alltrim((cTabla)->TIPO)=="D","I","V"),100,"N","N","N")	
				lAct := .T.
			ElseIf nCont > 0 .And. !lExiste
				SFH->(DBGOTO(nReg))
				If SFH->(!EOF())
					If SFH->FH_PERCENT == 100 .and. SFH->FH_IMPOSTO == "IBP"
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := dFinVige
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				EndIf
			EndIf
		//(Cliente, Percepcion y Aliq <> Cero) o (Proveedor, Percepcion, Aliq Cero y Existe CUIT de Emp) o (Proveedor, Retencion y Aliq Cero)
		ElseIf ((lCli .And. lPer .And. !lAliqP) .Or. (!lCli .And. lPer .And. !lAliqP .And. lExistEmp) .Or. (!lCli .And. !lPer .And. !lAliqR))
			If (nCont > 0 .and. lExiste) .Or. (!lCli .And. lPer .And. !lAliqP .And. lExistEmp .And. nCont > 0)
				If ((!((cTmp)->FH_SITUACA $ "2|3|5") .And. (cTmp)->FH_ISENTO <> "S") .Or. ((cTmp)->FH_FIMVIGE <=  dIniVige) .And. !Empty((cTmp)->FH_FIMVIGE))
					If ((cTmp)->FH_ALIQ == nAliq)
						SFH->(DBGOTO(nReg))
						If  SFH->(!EOF())
							Reclock("SFH",.F.)
								SFH->FH_FIMVIGE := dFinVige
								SFH->FH_SITUACA := "1"
								lAct := .T.
							SFH->(MsUnlock())
						EndIf
					ElseIf (((cTmp)->FH_ALIQ <> nAliq).And. ((cTmp)->FH_FIMVIGE < dFinVige) .Or. Empty((cTmp)->FH_FIMVIGE))
							SFH->(DBGOTO(nReg))
							actRegSFH(dIniVige,(cAlias)->&(cPref+"_NOME"))
							Reclock("SFH",.F.)
								If lPer
									SFH->FH_IMPOSTO   := "IBP"
									SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
								Else
									SFH->FH_IMPOSTO   := "IBR"
									SFH->FH_ALIQ      := nAliq	
								EndIf
								
								SFH->FH_PERCENT      := 0
								SFH->FH_SITUACA      := "1"
								SFH->FH_PERCIBI		:= IIf(lPer, "S", "N")
								SFH->FH_APERIB		:= IIf(lPer, "S", "N")
								SFH->FH_ISENTO		:= "N"
								SFH->FH_INIVIGE      := dIniVige
								SFH->FH_FIMVIGE      := dFinVige
							SFH->(MsUnlock())
							lAct := .T.
					ElseIf (((cTmp)->FH_ALIQ <> nAliq) .And. (cTmp)->FH_FIMVIGE == dFinVige)
						SFH->(DBGOTO(nReg))
						If  SFH->(!EOF())
							Reclock("SFH",.F.)
								If lPer
									SFH->FH_IMPOSTO   := "IBP" 
									SFH->FH_ALIQ      := IIf(lCli, nAliq, nPerEmp)
								Else
									SFH->FH_IMPOSTO   := "IBR"
									SFH->FH_ALIQ      := nAliq	
								EndIf
								SFH->FH_AGENTE		:= "S"
								SFH->FH_PERCENT		:= 0
								SFH->FH_SITUACA      := "1"
								SFH->FH_PERCIBI		:= IIf(lPer, "S", "N")
								SFH->FH_APERIB		:= IIf(lPer, "S", "N")
								SFH->FH_ISENTO		:= "N"
								SFH->FH_INIVIGE      := dIniVige
								SFH->FH_FIMVIGE      := dFinVige
								lAct := .T.
							SFH->(MsUnlock())
						EndIf
					EndIf
				EndIf
			ElseIf  nCont == 0 .And. lExiste .And. ((!(!lCli .And. (cAlias)->A2_TIPROV == "A") .And. !lPer ) .OR. (lCli .And. lPer .And. !lAliqP) ) //.And. !((cTmp)->FH_FIMVIGE = '')
				If (lCli .And. lPer .And. !lAliqP)
					AddRegSFH(lCli,lPer,xFilial("SFH",cSucProc),"N",(cAlias)->A1_COD,"",(cAlias)->&(cPref+"_LOJA"),(cAlias)->&(cPref+"_NOME"),"IBP",nAliq,"1",Iif(Alltrim((cTabla)->TIPO)=="D","I","V"),0,"S","N","S")
				Else
					AddRegSFH(lCli,lPer,xFilial("SFH",cSucProc),"S",IIf(lCli,(cAlias)->A1_COD,(cAlias)->A2_COD),IIf(lCli,(cAlias)->A1_COD,(cAlias)->A2_COD),(cAlias)->&(cPref+"_LOJA"),(cAlias)->&(cPref+"_NOME"),;
					Iif(lPer,"IBP","IBR"),Iif(lPer,IIf(lCli, nAliq, nPerEmp),nAliq),"1",Iif(Alltrim((cTabla)->TIPO)=="D","I","V"),0,IIf(lPer, "S", "N"),"N",IIf(lPer, "S", "N"))
				Endif
				lAct := .T.
			ElseIf nCont > 0 .And. !lExiste
				SFH->(DBGOTO(nReg))
				If  SFH->(!EOF())
					If SFH->FH_FIMVIGE > dFinVige .Or. Empty(SFH->FH_FIMVIGE)
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := dFinVige
							lAct := .T.
						SFH->(MsUnlock())
					EndIf
				EndIf
			EndIf
		ElseIf nCont > 0 .And. (!lCli .And. lPer .And. !lExistEmp)
			SFH->(DBGOTO(nReg))
			If  SFH->(!EOF())
				If SFH->FH_FIMVIGE > dFinVige .Or. Empty(SFH->FH_FIMVIGE)
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFinVige
						lAct := .T.
					SFH->(MsUnlock())
				EndIf
		
		
			EndIf			
		EndIf
		
	EndIf

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
Return


/*/-----------------------------------------------------------------------------------
//|	Procesa empresas
//------------------------------------------------------------------------------------*/
Static Function ProcEmp()//lPadRed
	Local aFils    := {}
	Local nPosEmp  := 0
	Local nPosFil  := 0
	Local lRet     := .F.
	Local aArea	 := getArea()
	Local cGrpComp := Alltrim(FwGrpCompany())
	
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbgotop())
	
	While SM0->(!EOF()) //Se recorre SM0
		If !Empty(SM0->M0_CGC) .And. Alltrim(SM0->M0_CODIGO) ==cGrpComp
			nPosEmp := aScan( aSucEmp,{|x| x[2] == Alltrim(SM0->M0_CGC)} )
			If nPosEmp == 0
				lRet := VldCuitEmp(Alltrim(SM0->M0_CGC))
				aAdd(aSucEmp, {{}, Alltrim(SM0->M0_CGC), lRet, nPerEmp})
				
				nPosFil := aScan( aFils,{|x| x == xFilial("SFH", SM0->M0_CODFIL)} )
				If nPosFil == 0
					aAdd(aSucEmp[Len(aSucEmp)][1], SM0->M0_CODFIL)
					aAdd(aFils, xFilial("SFH", SM0->M0_CODFIL))
				ElseIf Len(aSucEmp[Len(aSucEmp)][1]) == 0
					aAdd(aSucEmp[Len(aSucEmp)][1], SM0->M0_CODFIL)
				EndIf
			Else
				nPosFil := aScan( aFils,{|x| x == xFilial("SFH", SM0->M0_CODFIL)} )
				If nPosFil == 0
					aAdd(aSucEmp[nPosEmp][1], SM0->M0_CODFIL)
					aAdd(aFils, xFilial("SFH", SM0->M0_CODFIL))
				EndIf
			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo

	If cTipoRG == "RES816-14"
		dbSelectArea("CCO")
		CCO->(dbSetOrder(1))

		If CCO->(MsSeek(XFILIAL("CCO")+"CF")) .and. lRet
			RecLock("CCO",.F.)
				CCO->CCO_TIPO:= "X"
			CCO->(MsUnlock())
			lAct := .T.
		ElseIf 	CCO->(MsSeek(XFILIAL("CCO")+"CF")) .and. !lRet 
			
			If CCO->CCO_TIPO == "X" 
				RecLock("CCO",.F.)
					CCO->CCO_TIPO:= "I"
				CCO->(MsUnlock())
				lAct := .T.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


/*/+------------------------------------------------------------------------------------+
///|Valida Formato de Fecha de vigencia AAAAMMM al ser introducido						|
///+------------------------------------------------------------------------------------+*/

Static Function ValidaVige()

	Local lRet	:= .T.
	Local dPer	:= STOD(cPerVig + "01")
	
	If !(YEAR(dPer)<>0)
		MsgAlert(STR0025)
		lRet:= .F.
	End If

Return lRet

Static Function ValExtFile(cNomeFile)
	Local lRet := .T.
	Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)//Substr(cNomeFile,at(".",cNomeFile)+1)
	
	If Empty(UPPER(cNomeFile)) .or. !(cExt $"csv|CSV|txt|TXT")
		MsgAlert(STR0026)
		lRet := .F.
	End If

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidChk ³ Autor ³ Paulo Augusto       ³ Data ³ 30.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa que impede o uso do check de retencao para        ³±±
±±³          ³ clientes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Variavel com o valor escolhido no combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - .T. se validado ou .F. se incorreto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ValidChk(cCombo)
		
	If lRet == .T. .and. Subs(cCombo,1,1) $ "2"    // Cliente nao tem retenção
		lRet :=.F.
	EndIf	
	oChk2:Refresh()

Return lRet

Static Function FormatDate(cDate)
Local cFecha := 0
	cFecha := SubStr(cDate, 5, 4) + SubStr(cDate, 3, 2) + SubStr(cDate, 1, 2)
Return cFecha

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetFecha  ³ Autor ³ Raul Ortiz	      ³ Data ³ 18/08/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion para actualizar la tabla de Ingresos Brutos - SFH  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFecha - Fecha del proceso                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ultimo día del mes correspondiente                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldTipoRG(nTipoProc)
	If nTipoProc == 1
		cTipoRG := "RES816-14" //Padron Alicuotas Diferenciales y Otros (TRKDBT)
		cTitulo1 := STR0005
		cInfo1   := STR0009
		cInfo2   := STR0010
	ElseIf nTipoProc == 2
		cTipoRG := "RES364-16" //Padron Regimenes Generales (TVYLAK)
		cTitulo1 := STR0031
		cInfo1   := STR0032
		cInfo2   := STR0033
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetFecha  ³ Autor ³ Raul Ortiz	      ³ Data ³ 18/08/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcion para actualizar la tabla de Ingresos Brutos - SFH  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFecha - Fecha del proceso                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ultimo día del mes correspondiente                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function actRegSFH(dFchPro, cNombre)
Local i := 0
Local j := 0
Local aSFHTemp := {}

Default	cNombre := ""

	aSFHTemp := {}
	
	For i:=1 to len(aEstSFH)
		aADD(aSFHTemp,{aEstSFH[i],SFH->&(aEstSFH[i][1])}) 
	Next i
	
	Reclock("SFH",.F.)
		SFH->FH_FIMVIGE    :=  dFchPro-1
	SFH->(MsUnlock())
	
	Reclock("SFH",.T.)
		For j := 1 to Len(aSFHTemp)
			SFH->&(aSFHTemp[j][1][1]) := aSFHTemp[j][2]
		Next j
		If !Empty(cNombre)
			SFH->FH_NOME := cNombre
		EndIf
	SFH->(MsUnlock())
							
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CreaTabla ³ Autor ³ Luis Samaniego      ³ Data ³ 11/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea tabla en base de datos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CreaTabla(cTmpTRD)
Local cIndex	:= ""
Local aStru		:= {}
Local lCrea 	:= .T.
Local aAux 		:={}
Local aOrdem := {"CUIT"}

	If Select(cTmpTRD) <> 0
		(cTmpTRD)->(dbCloseArea())
		lCrea := DelTab(cTmpTRD)
	EndIf
	If  lCrea 
		AADD(aStru,{ "FCHPUB"  ,  "C",  8,  0})
		AADD(aStru,{ "INIVIGE" ,  "C",  8,  0})
		AADD(aStru,{ "FINVIGE" ,  "C",  8,  0})
		AADD(aStru,{ "CUIT"    ,  "C",  14, 0})
		AADD(aStru,{ "TIPO"    ,  "C",  1,  0})
		AADD(aStru,{ "ALTA"    ,  "C",  1,  0})
		AADD(aStru,{ "MARCALIC",  "C",  1,  0})
		AADD(aStru,{ "ALICPERC",  "C",  6,  0})
		AADD(aStru,{ "ALICRETE",  "C",  6,  0})
		AADD(aStru,{ "GRPPERC" ,  "C",  6,  0})
		AADD(aStru,{ "GRPRETE" ,  "C",  6,  0})
		AADD(aStru,{ "RAZONSOC",  "C",  60, 0})
		
		oTmpTable := FWTemporaryTable():New(cTmpTRD,aStru )
        oTmpTable:AddIndex( "1", aOrdem )
        oTmpTable:Create()
        cTmpTRD := oTmpTable:GetAlias()
        lTempDB := .T.
	EndIf
	
	aadd(aAux,{lCrea,aStru})
Return aAux

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DelTab    ³ Autor ³ Luis Samaniego      ³ Data ³ 11/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Elimina tabla temporal de la base de datos                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DelTab(cTmpTRD)
Local cQuery 	:= ""
Local lRet 	:= .T.
	
	If TCCanOpen(cTmpTRD)
	   	cQuery := "DROP TABLE " + cTmpTRD           
		If TcSqlExec(cQuery) <> 0
			if !TCDelFile(cTmpTRD)
				MsgAlert(STR0036)
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpASql   ³ Autor ³ Luis Samaniego      ³ Data ³ 11/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inserta padron en tabla de base de datos MSSQL             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpASql(cFile)
Local lImpSql := .F.
Local cQry  := ""
Local lCrea := .T.

	If TCCanOpen(cTmpTRD)
		lCrea:= DelTab(cTmpTRD)
	EndIf

	If lCrea 
		cQry := "CREATE TABLE dbo." + cTmpTRD 
		cQry += " (" 
		cQry += " FCHPUB		varchar(8) , "	//Fecha Vigencia Desde
		cQry += " INIVIGE		varchar(8) , "	//Fecha Vigencia Hasta
		cQry += " FINVIGE		varchar(8) , " 	//Numero de Cuit
		cQry += " CUIT 		varchar(14) , "	//Fecha de Publicacion
		cQry += " TIPO		varchar(1) , "	//Tipo-Contr_Insc
		cQry += " ALTA		varchar(1) , "	//Marca-alta-sujeto
		cQry += " MARCALIC	varchar(1) , "	//Marca-alicuota
		cQry += " ALICPERC	varchar(6) , "	//Alicuota- Percepcion
		cQry += " ALICRETE	varchar(6) , "	//Alicuota- Retencion
		cQry += " GRPPERC		varchar(6) , "	//Nro-Grupo-Percepcion
		cQry += " GRPRETE		varchar(6) , "	//Nro-Grupo-Retencion
		cQry += " RAZONSOC	varchar(60) "	//Razon Social
		cQry += ")"
		
		If TCSqlExec( cQry ) <> 0
			UserException( "Error en la creacion de tabla FISA067" + CRLF + TCSqlError() )
		Else 
			lImpSql := .T.
		EndIf
		
		cQry := "BULK INSERT dbo." + cTmpTRD + " FROM '" + cFile + "' WITH ( BATCHSIZE = 30000 , DATAFILETYPE = 'char', FIELDTERMINATOR = '"+_SEPARADOR+"',ROWTERMINATOR = '\n' )"
	
	
		If  TCSqlExec( cQry ) <> 0
			lImpSql := .F.
			lBulk   := .F.
			DelTab(cTmpTRD) 
		Endif 
	Endif
Return lImpSql

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PadReduc  ³ Autor ³ Luis Samaniego      ³ Data ³ 11/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea Padron Reducido                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PadReduc(cTmpSA, cTabla, cSucProc, oTmpTab)
Local lImpSql := .F.
Local cQry    := ""
Local aStru   := {}
Local cTRDTmp := Iif(Type("oTmpTable") <> "U", oTmpTable:GetRealName(), cTmpTRD)
Local aOrdem := {"CUIT"}

	cTmpSA :=GetNextAlias()
	
	aStru := RetStru()

	oTmpTab := FWTemporaryTable():New(cTmpSA,aStru )
	oTmpTab:AddIndex( "1", aOrdem )
	oTmpTab:Create()
	cTmpSA := oTmpTab:GetAlias()
	
	cQry := " SELECT * FROM " + cTRDTmp + ", " + InitSqlName("S"+cTabla) + " " + "S"+cTabla
	cQry += " WHERE " + cTRDTmp + ".CUIT = " + "S"+cTabla + "." + cTabla + "_CGC AND "
	cQry += "S" +cTabla + "." + cTabla + "_FILIAL = '" + xFilial("S" + cTabla, cSucProc) + "'"
	cQry += " AND " + "S"+cTabla + ".D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY " + cTRDTmp + ".CUIT "
	
	cQry := ChangeQuery(cQry)      
	
	SqlToTrb(cQry,aStru,cTmpSA)
	dbSelectArea(cTmpSA)
	(cTmpSA)->(dbSetOrder(1))
	(cTmpSA)->(dbGoTop())
	  
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldCuitEmp³ Autor ³ Luis Samaniego      ³ Data ³ 11/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida si existe CUIT de empresa en padron                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCuitEmp(cCuitEmp)
Local lImpSql := .F.
Local cQry    := ""
Local cTmpSM0 := GetNextAlias() 
Local cTRDTmp := Iif(Type("oTmpTable") <> "U", oTmpTable:GetRealName(), cTmpTRD)
	
	cQry := " SELECT * FROM " + cTRDTmp + " WHERE CUIT = '" + cCuitEmp + "'"
	
	cQry := ChangeQuery(cQry)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTmpSM0,.T.,.T.)
	
	If (cTmpSM0)->(!EOF())
		lImpSql := .T.
		nPerEmp := Val(Replace((cTmpSM0)->ALICPERC, ',', '.'))
		dIniVige := STOD((cTmpSM0)->INIVIGE)
		dFinVige := STOD((cTmpSM0)->FINVIGE)
	Else
		nPerEmp := 0
	EndIf
	
	If Select(cTmpSM0) <> 0
		(cTmpSM0)->(dbCloseArea()) 
		DelTab(cTmpSM0)
	EndIf
Return lImpSql

Static Function AddReg(cCuit, cFchPub, cIniVige, cFinVige, cTipo, cAlta, cMarcalic, cAlicPerc, cAlicRet, cGrpPerc, cGrpRet, cRazon)

	(cTmpTRD)->( DBAppend() )
	(cTmpTRD)->CUIT		:= cCuit
	(cTmpTRD)->FCHPUB   := cFchPub
	(cTmpTRD)->INIVIGE	:= cIniVige
	(cTmpTRD)->FINVIGE 	:= cFinVige
	(cTmpTRD)->TIPO		:= cTipo
	(cTmpTRD)->ALTA 	:= cAlta
	(cTmpTRD)->MARCALIC := cMarcalic
	(cTmpTRD)->ALICPERC := cAlicPerc
	(cTmpTRD)->ALICRETE := cAlicRet
	(cTmpTRD)->GRPPERC 	:= cGrpPerc
	(cTmpTRD)->GRPRETE 	:= cGrpRet
	(cTmpTRD)->RAZONSOC := cRazon
	(cTmpTRD)->( DBCommit() )
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AddRegSFH ³ Autor ³ Laura Medina        ³ Data ³ 26/08/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Agregar registro en la SFH.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddRegSFH(lCli,lPer,cFilSFH,cAgenSFH,cCodCte,cCodPro,cLojaSFH,cNomeSFH,cImpSFH,nAliqSFH,cSitSFH,cTipoSFH,nPercSFH,cPercibi,cIsento,cAperib)	
				
	Reclock("SFH",.T.)
	SFH->FH_FILIAL		:= cFilSFH
	SFH->FH_AGENTE      := cAgenSFH
	If lCli
		SFH->FH_CLIENTE	:= cCodCte
	Else  
		SFH->FH_FORNECE	:= cCodPro
	EndIf
	SFH->FH_LOJA	 	:= cLojaSFH
	SFH->FH_NOME        := cNomeSFH
	SFH->FH_IMPOSTO		:= cImpSFH
	SFH->FH_ALIQ		:= nAliqSFH
	SFH->FH_PERCIBI		:= cPercibi
	SFH->FH_ISENTO		:= cIsento
	SFH->FH_APERIB		:= cAperib
	SFH->FH_ZONFIS		:= "CF"   
	SFH->FH_SITUACA		:= cSitSFH
	SFH->FH_TIPO		:= cTipoSFH
	SFH->FH_PERCENT		:= nPercSFH
	SFH->FH_INIVIGE		:= dIniVige
	SFH->FH_FIMVIGE		:= dFinVige
	SFH->(MsUnlock())

Return 

Static Function VldFech(cFile)
Local cFin  := ""
Local cLine := ""
	
	FT_FUSE(cFile)
	If !(_SEPARADOR $ (FT_FREADLN()))
		MsgStop(STR0026)
		Return Nil
	EndIf
	cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSINIVIG ]
	cFin  := Separa(FT_FREADLN(),_SEPARADOR)[_POSFINVIG ]
		
	If (cMes+cAno) <> (SubStr(cLine,3,7))  
		xMagHelpFis(STR0022,STR0026,STR0025)
		Return Nil
	EndIf
	
	dIniVige  := STOD(SubStr(cLine , 5, 4) + SubStr(cLine , 3, 2) + SubStr(cLine , 1, 2))
	dFinVige  := STOD(SubStr(cFin  , 5, 4) + SubStr(cFin  , 3, 2) + SubStr(cFin  , 1, 2))

	FT_FUSE() 
		
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpPostGre ³ Autor ³ Danilo Santos      ³ Data ³ 10/11/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inserta padron en tabla de base de datos POSTGREE SQL      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpPostGre(cFile)
Local lImpPost := .F.
Local cQry  := ""
Local lCrea := .T.

	If Select(cTmpTRD) <> 0
		(cTmpTRD)->(dbCloseArea())
		lCrea:= DelTab(cTmpTRD)
	EndIf

	If lCrea 
	
		cQry += "CREATE TABLE " + cTmpTRD
		cQry += " (" 
		cQry += " FCHPUB	varchar(8) , "	//Fecha Vigencia Desde
		cQry += " INIVIGE	varchar(8) , "	//Fecha Vigencia Hasta
		cQry += " FINVIGE	varchar(8) , " 	//Numero de Cuit
		cQry += " CUIT 		varchar(14) , "	//Fecha de Publicacion
		cQry += " TIPO		varchar(1) , "	//Tipo-Contr_Insc
		cQry += " ALTA		varchar(1) , "	//Marca-alta-sujeto
		cQry += " MARCALIC	varchar(1) , "	//Marca-alicuota
		cQry += " ALICPERC	varchar(6) , "	//Alicuota- Percepcion
		cQry += " ALICRETE	varchar(6) , "	//Alicuota- Retencion
		cQry += " GRPPERC	varchar(6) , "	//Nro-Grupo-Percepcion
		cQry += " GRPRETE	varchar(6) , "	//Nro-Grupo-Retencion
		cQry += " RAZONSOC	varchar(100) "	//Razon Social
		cQry += ")"	

		If TCSqlExec( cQry ) <> 0
			UserException( "Error en la creacion de tabla FISA067" + CRLF + TCSqlError() )
		Else 
			lImpPost := .T.
		EndIf

		cQry := "COPY " + cTmpTRD + " FROM '" + cFile + "'  using DELIMITERs ';' encoding 'windows-1251'"
		
		If  TCSqlExec( cQry ) <> 0
			lImpPost := .F.
			lBulk   := .F.
			DelTab(cTmpTRD) 
		Endif 
	Endif
Return lImpPost

/*/{Protheus.doc} RetStru
Regresa la estructura de la tabla
@type function
@author raul.medina
@since 05/2022
@version 1.0
*/
Static Function RetStru()
Local aStru	:= {}

	AADD(aStru,{ "FCHPUB"  ,  "C",  8,  0})
	AADD(aStru,{ "INIVIGE" ,  "C",  8,  0})
	AADD(aStru,{ "FINVIGE" ,  "C",  8,  0})
	AADD(aStru,{ "CUIT"    ,  "C",  14, 0})
	AADD(aStru,{ "TIPO"    ,  "C",  1,  0})
	AADD(aStru,{ "ALTA"    ,  "C",  1,  0})
	AADD(aStru,{ "MARCALIC",  "C",  1,  0})
	AADD(aStru,{ "ALICPERC",  "C",  6,  0})
	AADD(aStru,{ "ALICRETE",  "C",  6,  0})
	AADD(aStru,{ "GRPPERC" ,  "C",  6,  0})
	AADD(aStru,{ "GRPRETE" ,  "C",  6,  0})
	AADD(aStru,{ "RAZONSOC",  "C",  60, 0})

Return aStru

/*/{Protheus.doc} ImpBulk
Realiza la carga por medio del FWBulk
@type function
@author raul.medina
@since 05/2022
@version 1.0
@param cFile,		Caracter, 	Archivo a ser usado en la carga.

*/
Static Function ImpBulk(cFile)
Local cCodeError	:= ""
Local nX 			:= 0
Local aStruct 		:= {}
Local aInforma		:= {}
Local nUlt 			:= 0
Local lRet			:= .F.
Local cIniVige		:= ""
Local cFinVige		:= ""
Local oBulk 	as object
Local cPathServ		:= GetSrvProfString("StartPath","")
Local cFileAux		:= ""
Local lDelFile		:= .F.
Local lAutomato		:= IsBlind()

Default cFile := ""	

	IIF(TCCanOpen(cTmpTRD),;
		IIF(!TCDelFile(cTmpTRD),UserException( "DROP table error " + cTmpTRD + CRLF + TCSqlError() ),.T.);
	,.T.)

	If !lAutomato
		cPathServ := StrTran(cPathServ,"/","\")
		cPathServ += If(Right(cPathServ,1)=="\","","\")
		If CpyT2S(cFile,cPathServ,.T.)
			cFileAux := SUBSTR(cFile, RAT("\",cFile)+1)
			cFile := cPathServ + cFileAux
			lDelFile := .T.
		EndIf
	EndIf

	FT_FUSE(cFile)	

	// Se posiciona en la primera línea
	FT_FGoTop()
	nUlt := FT_FLastRec()

	aStruct := RetStru()

    FWDBCreate( cTmpTRD, aStruct , 'TOPCONN' , .T.) 

	oBulk := FwBulk():New(cTmpTRD)
    oBulk:SetFields(aStruct)

	oFile := ZFWReadTXT():New(cFile,,_BUFFER)
	// Se hay error al abrir el archivo
	If oFile:Open()
	
		ProcRegua(nUlt)
		While oFile:ReadArray(@aInforma,_SEPARADOR)
			IncProc(STR0006 + str(nX))
			cIniVige := SubStr(aInforma[_POSINIVIG] , 5, 4) + SubStr(aInforma[_POSINIVIG] , 3, 2) + SubStr(aInforma[_POSINIVIG] , 1, 2)
			cFinVige := SubStr(aInforma[_POSFINVIG] , 5, 4) + SubStr(aInforma[_POSFINVIG] , 3, 2) + SubStr(aInforma[_POSFINVIG] , 1, 2)        
			oBulk:AddData({;
				aInforma[_POSFCHPUB],; 
				cIniVige,;
				cFinVige,;
				aInforma[_POSCGC],;
				aInforma[_POSTIPO],; 
				aInforma[_POSALTA],; 
				aInforma[_POSMARCAL],;
				Replace(aInforma[_POSALICP], ',', '.'),;
				Replace(aInforma[_POSALICR], ',', '.'),;
				aInforma[_POSGRPPER],;
				aInforma[_POSGRPRET],;
				Iif(Len(aInforma) >= 12,REPLACE(aInforma[_POSRAZON],'"',""),"")})        

			nX += 1
			aSize(aInforma,0)
		EndDo

		oFile:Close()
	EndIf

	FT_FUSE()

	cCodeError:= oBulk:GetError()
	oBulk:Close()
	oBulk:Destroy()
	oBulk := nil

	lRet := Empty(cCodeError)

	If lDelFile
		FERASE(cFile)
	EndIf

Return .T.
