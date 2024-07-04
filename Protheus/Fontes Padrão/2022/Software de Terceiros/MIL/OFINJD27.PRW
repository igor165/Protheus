#include "protheus.ch"
#include "OFINJD27.CH"
#include "fileio.ch"
#include "topconn.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "003997_4"

/*/{Protheus.doc} OFINJD27 "Grupos DPM"
	Rotina para controlar mais de 1 DPM no mesmo servidor protheus

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  12/08/2015
/*/
Function OFINJD27()

	Local nBaseEsq := 25
	Local nBaseDir := 70 

	Private oDlg,lstFiliais,oSay2,oGrp3,oGrp4,oGrp5,oGrp6,btnAdd1,brtAdd2,btnAdd3,btnAdd4,btnRem1,btnRem4,btnRem3,;
		btnRem2,oSay17,oSay18,oSay19,oSay20,lstGrp1,lstGrp2,lstGrp3,lstGrp4,otxtConta1,otxtConta2,otxtConta3,otxtConta4

	Private ctxtConta1 := ctxtConta2 := ctxtConta3 := ctxtConta4 := SPACE(6) // numero conta principal jd

	Private oArHelp := DMS_ArrayHelper():New()
	Private oLogger := DMS_Logger():New()
	Private oDpm    := DMS_DPM():New()
	Private cTxtPath1
	Private cTxtPath2
	Private cTxtPath3
	Private cTxtPath4
	// oPath1,oPath2,oPath3,oPath4

	oDlg := MSDIALOG():Create()
	oDlg:cName := "oDlg"
	oDlg:cCaption := STR0006 //Configuração DPM
	oDlg:nLeft := 0
	oDlg:nTop := 0
	oDlg:nWidth := 1084
	oDlg:nHeight := 580
	oDlg:lShowHint := .F.
	oDlg:lCentered := .F.

	lstFiliais := TWBrowse():New(nBaseEsq+18, 5, 140, 220,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    lstFiliais:AddColumn( TCColumn():New( STR0004  , { || lstFiliais:aArray[lstFiliais:nat][1] },,,,"LEFT", 30,.F.,.F.,,,,.F.,) ) // "Filial"
    lstFiliais:AddColumn( TCColumn():New( STR0005 , { || lstFiliais:aArray[lstFiliais:nat][2] },,,,"LEFT", 40,.F.,.F.,,,,.F.,) ) // "Código JD"
    lstFiliais:nAt := 1
    //lstFiliais:bChange := { || /* FS_chgRotinas() */ }

	lstGrp1 := TWBrowse():New(nBaseDir, 200, 140, 50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lstGrp1:AddColumn( TCColumn():New( STR0004  , { || lstGrp1:aArray[lstGrp1:nat][1] },,,,"LEFT", 30,.F.,.F.,,,,.F.,) ) // "Filial"
    lstGrp1:AddColumn( TCColumn():New( STR0005 , { || lstGrp1:aArray[lstGrp1:nat][2] },,,,"LEFT", 40,.F.,.F.,,,,.F.,) ) // "Código JD"
	lstGrp1:nAt := 1
	//lstGrp1:bChange := { || /* FS_chgRotinas() */ }

	lstGrp2 := TWBrowse():New((nBaseDir*2)+14, 200, 140, 50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lstGrp2:AddColumn( TCColumn():New( STR0004 , { || lstGrp2:aArray[lstGrp2:nat][1] },,,,"LEFT", 30,.F.,.F.,,,,.F.,) ) // "Filial"
    lstGrp2:AddColumn( TCColumn():New( STR0005, { || lstGrp2:aArray[lstGrp2:nat][2] },,,,"LEFT", 40,.F.,.F.,,,,.F.,) ) // "Código JD"
	lstGrp2:nAt := 1
	//lstGrp2:bChange := { || /* FS_chgRotinas() */ }

	lstGrp3 := TWBrowse():New(nBaseDir, 378, 140, 50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lstGrp3:AddColumn( TCColumn():New( STR0004  , { || lstGrp3:aArray[lstGrp3:nat][1] },,,,"LEFT", 30,.F.,.F.,,,,.F.,) ) // "Filial"
    lstGrp3:AddColumn( TCColumn():New( STR0005 , { || lstGrp3:aArray[lstGrp3:nat][2] },,,,"LEFT", 40,.F.,.F.,,,,.F.,) ) // "Código JD"
	lstGrp3:nAt := 1
	//lstGrp3:bChange := { || /* FS_chgRotinas() */ }

	lstGrp4 := TWBrowse():New((nBaseDir*2)+14, 378, 140, 50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lstGrp4:AddColumn( TCColumn():New( STR0004  , { || lstGrp4:aArray[lstGrp4:nat][1] },,,,"LEFT", 30,.F.,.F.,,,,.F.,) ) // "Filial"
    lstGrp4:AddColumn( TCColumn():New( STR0005 , { || lstGrp4:aArray[lstGrp4:nat][2] },,,,"LEFT", 40,.F.,.F.,,,,.F.,) ) // "Código JD"
	lstGrp4:nAt := 1
	//lstGrp4:bChange := { || /* FS_chgRotinas() */ }

	oSay2 := TSAY():Create(oDlg)
	oSay2:cName := "oSay2"
	oSay2:cCaption := STR0002 //Filiais DPM
	oSay2:nLeft := 9
	oSay2:nTop := nBaseDir-2
	oSay2:nWidth := 65
	oSay2:nHeight := 17
	oSay2:lShowHint := .F.
	oSay2:lReadOnly := .F.
	oSay2:Align := 0
	oSay2:lVisibleControl := .T.
	oSay2:lWordWrap := .F.
	oSay2:lTransparent := .F.

	oGrp3 := TGROUP():Create(oDlg)
	oGrp3:cName := "oGrp3"
	oGrp3:cCaption := STR0003 + "1" //Grupo
	oGrp3:nLeft := 390
	oGrp3:nTop := nBaseDir+3
	oGrp3:nWidth := 300
	oGrp3:nHeight := 170
	oGrp3:lShowHint := .F.
	oGrp3:lReadOnly := .F.
	oGrp3:Align := 0
	oGrp3:lVisibleControl := .T.

	oGrp4 := TGROUP():Create(oDlg)
	oGrp4:cName := "oGrp4"
	oGrp4:cCaption := STR0003 + "2" //Grupo
	oGrp4:nLeft := 390
	oGrp4:nTop := nBaseDir+173
	oGrp4:nWidth := 300
	oGrp4:nHeight := 170
	oGrp4:lShowHint := .F.
	oGrp4:lReadOnly := .F.
	oGrp4:Align := 0
	oGrp4:lVisibleControl := .T.

	oGrp5 := TGROUP():Create(oDlg)
	oGrp5:cName := "oGrp5"
	oGrp5:cCaption := STR0003 + "3"
	oGrp5:nLeft := 750
	oGrp5:nTop := nBaseDir+3 //Grupo
	oGrp5:nWidth := 300
	oGrp5:nHeight := 170
	oGrp5:lShowHint := .F.
	oGrp5:lReadOnly := .F.
	oGrp5:Align := 0
	oGrp5:lVisibleControl := .T.

	oGrp6 := TGROUP():Create(oDlg)
	oGrp6:cName := "oGrp6"
	oGrp6:cCaption := STR0003 + "4" //Grupo
	oGrp6:nLeft := 750
	oGrp6:nTop := nBaseDir+173
	oGrp6:nWidth := 300
	oGrp6:nHeight := 170
	oGrp6:lShowHint := .F.
	oGrp6:lReadOnly := .F.
	oGrp6:Align := 0
	oGrp6:lVisibleControl := .T.

	btnAdd1 := SBUTTON():Create(oDlg)
	btnAdd1:cName := "btnAdd1"
	btnAdd1:cCaption := ">>"
	btnAdd1:bAction := {|| add1() }
	btnAdd1:nLeft := 330
	btnAdd1:nTop := nBaseDir+14
	btnAdd1:nWidth := 52
	btnAdd1:nHeight := 22
	btnAdd1:lShowHint := .F.
	btnAdd1:lReadOnly := .F.
	btnAdd1:Align := 0
	btnAdd1:lVisibleControl := .T.
	btnAdd1:nType := 1

	btnAdd2 := SBUTTON():Create(oDlg)
	btnAdd2:cName := "btnAdd2"
	btnAdd2:cCaption := ">>"
	btnAdd2:bAction := {|| add2() }
	btnAdd2:nLeft := 330
	btnAdd2:nTop := nBaseDir+185
	btnAdd2:nWidth := 52
	btnAdd2:nHeight := 22
	btnAdd2:lShowHint := .F.
	btnAdd2:lReadOnly := .F.
	btnAdd2:Align := 0
	btnAdd2:lVisibleControl := .T.
	btnAdd2:nType := 1

	btnAdd3 := SBUTTON():Create(oDlg)
	btnAdd3:cName := "btnAdd3"
	btnAdd3:cCaption := ">>"
	btnAdd3:bAction := {|| add3() }
	btnAdd3:nLeft := 692
	btnAdd3:nTop := nBaseDir+14
	btnAdd3:nWidth := 52
	btnAdd3:nHeight := 22
	btnAdd3:lShowHint := .F.
	btnAdd3:lReadOnly := .F.
	btnAdd3:Align := 0
	btnAdd3:lVisibleControl := .T.
	btnAdd3:nType := 1

	btnAdd4 := SBUTTON():Create(oDlg)
	btnAdd4:cName := "btnAdd4"
	btnAdd4:cCaption := ">>"
	btnAdd4:bAction := {|| add4() }
	btnAdd4:nLeft := 692
	btnAdd4:nTop := nBaseDir+185
	btnAdd4:nWidth := 52
	btnAdd4:nHeight := 22
	btnAdd4:lShowHint := .F.
	btnAdd4:lReadOnly := .F.
	btnAdd4:Align := 0
	btnAdd4:lVisibleControl := .T.
	btnAdd4:nType := 1

	btnRem1 := SBUTTON():Create(oDlg)
	btnRem1:cName := "btnRem1"
	btnRem1:cCaption := "<<"
	btnRem1:bAction := {|| Rem1() }
	btnRem1:nLeft := 330
	btnRem1:nTop := nBaseDir+41
	btnRem1:nWidth := 52
	btnRem1:nHeight := 22
	btnRem1:lShowHint := .F.
	btnRem1:lReadOnly := .F.
	btnRem1:Align := 0
	btnRem1:lVisibleControl := .T.
	btnRem1:nType := 1

	btnRem2 := SBUTTON():Create(oDlg)
	btnRem2:cName := "btnRem2"
	btnRem2:cCaption := "<<"
	btnRem2:bAction := {|| Rem2() }
	btnRem2:nLeft := 330
	btnRem2:nTop := nBaseDir+211
	btnRem2:nWidth := 52
	btnRem2:nHeight := 22
	btnRem2:lShowHint := .F.
	btnRem2:lReadOnly := .F.
	btnRem2:Align := 0
	btnRem2:lVisibleControl := .T.
	btnRem2:nType := 1

	btnRem3 := SBUTTON():Create(oDlg)
	btnRem3:cName := "btnRem3"
	btnRem3:cCaption := "<<"
	btnRem3:bAction := {|| Rem3() }
	btnRem3:nLeft := 692
	btnRem3:nTop := nBaseDir+41
	btnRem3:nWidth := 52
	btnRem3:nHeight := 22
	btnRem3:lShowHint := .F.
	btnRem3:lReadOnly := .F.
	btnRem3:Align := 0
	btnRem3:lVisibleControl := .T.
	btnRem3:nType := 1

	btnRem4 := SBUTTON():Create(oDlg)
	btnRem4:cName := "btnRem4"
	btnRem4:cCaption := "<<"
	btnRem4:bAction := {|| Rem4() }
	btnRem4:nLeft := 692
	btnRem4:nTop := nBaseDir+211
	btnRem4:nWidth := 52
	btnRem4:nHeight := 22
	btnRem4:lShowHint := .F.
	btnRem4:lReadOnly := .F.
	btnRem4:Align := 0
	btnRem4:lVisibleControl := .T.
	btnRem4:nType := 1

	oSay17 := TSAY():Create(oDlg)
	oSay17:cName := "oSay17"
	oSay17:cCaption := STR0001 //Caminho
	oSay17:nLeft := 400
	oSay17:nTop := nBaseDir+28
	oSay17:nWidth := 65
	oSay17:nHeight := 17
	oSay17:lShowHint := .F.
	oSay17:lReadOnly := .F.
	oSay17:Align := 0
	oSay17:lVisibleControl := .T.
	oSay17:lWordWrap := .F.
	oSay17:lTransparent := .F.

	oSay18 := TSAY():Create(oDlg)
	oSay18:cName := "oSay18"
	oSay18:cCaption := STR0001 //Caminho
	oSay18:nLeft := 400
	oSay18:nTop := nBaseDir+193
	oSay18:nWidth := 65
	oSay18:nHeight := 17
	oSay18:lShowHint := .F.
	oSay18:lReadOnly := .F.
	oSay18:Align := 0
	oSay18:lVisibleControl := .T.
	oSay18:lWordWrap := .F.
	oSay18:lTransparent := .F.

	oSay19 := TSAY():Create(oDlg)
	oSay19:cName := "oSay19"
	oSay19:cCaption := STR0001 //Caminho
	oSay19:nLeft := 760
	oSay19:nTop := nBaseDir+28
	oSay19:nWidth := 65
	oSay19:nHeight := 17
	oSay19:lShowHint := .F.
	oSay19:lReadOnly := .F.
	oSay19:Align := 0
	oSay19:lVisibleControl := .T.
	oSay19:lWordWrap := .F.
	oSay19:lTransparent := .F.

	oSay20 := TSAY():Create(oDlg)
	oSay20:cName := "oSay20"
	oSay20:cCaption := STR0001 //Caminho
	oSay20:nLeft := 760
	oSay20:nTop := nBaseDir+193
	oSay20:nWidth := 65
	oSay20:nHeight := 17
	oSay20:lShowHint := .F.
	oSay20:lReadOnly := .F.
	oSay20:Align := 0
	oSay20:lVisibleControl := .T.
	oSay20:lWordWrap := .F.
	oSay20:lTransparent := .F.

	cTxtPath1 := SPACE(244)
	cTxtPath2 := SPACE(244)
	cTxtPath3 := SPACE(244)
	cTxtPath4 := SPACE(244)
	@  nBaseDir-24, 230 BUTTON oPath1 PROMPT cTxtPath1 OF oDlg SIZE 100, 12 PIXEL ACTION ( oPath1:cCaption := cTxtPath1 := OJD27GtFile() )
	@  nBaseDir+58, 230 BUTTON oPath2 PROMPT cTxtPath2 OF oDlg SIZE 100, 12 PIXEL ACTION ( oPath2:cCaption := cTxtPath2 := OJD27GtFile() )
	@  nBaseDir-24, 410 BUTTON oPath3 PROMPT cTxtPath3 OF oDlg SIZE 100, 12 PIXEL ACTION ( oPath3:cCaption := cTxtPath3 := OJD27GtFile() )
	@  nBaseDir+58, 410 BUTTON oPath4 PROMPT cTxtPath4 OF oDlg SIZE 100, 12 PIXEL ACTION ( oPath4:cCaption := cTxtPath4 := OJD27GtFile() )
	
	@  nBaseDir-12, 200 SAY STR0008 SIZE 50,20 OF oDlg PIXEL //Conta
	@  nBaseDir-12, 230 MSGET oTxtConta1 VAR cTxtConta1 OF oDlg SIZE 100, 8 PIXEL
	
	@ nBaseDir+72, 200 SAY STR0008 SIZE 50,20 OF oDlg PIXEL //Conta
	@ nBaseDir+72, 230 MSGET oTxtConta2 VAR cTxtConta2 OF oDlg SIZE 100, 8 PIXEL
	
	@ nBaseDir-12, 380 SAY STR0008 SIZE 50,20 OF oDlg PIXEL //Conta
	@ nBaseDir-12, 410 MSGET oTxtConta3 VAR cTxtConta3 OF oDlg SIZE 100, 8 PIXEL
	
	@ nBaseDir+72, 380 SAY STR0008 SIZE 50,20 OF oDlg PIXEL //Conta
	@ nBaseDir+72, 410 MSGET oTxtConta4 VAR cTxtConta4 OF oDlg SIZE 100, 8 PIXEL
	
	lstFiliais:SetArray( oDpm:GetFiliais() )
    lstFiliais:Refresh()
    lstGrp1:SetArray({})
    lstGrp2:SetArray({})
    lstGrp3:SetArray({})
    lstGrp4:SetArray({})

	ACTIVATE MSDIALOG oDlg;
		ON INIT ( EnChoiceBar(oDlg,{|| IIF(FS_CONFIRMA(), oDlg:End(), nil) } ,{|| FS_CANCELA(), oDlg:End() }) )

Return .T.

/*/{Protheus.doc} Add

	@author       Vinicius Gati
	@since        29/07/2015
	@description  Adiciona no seu respectivo grupo a filial selecionada

/*/
Static Function Add1()
	if Len(lstFiliais:aArray) > 0
		aElAdd := lstFiliais:aArray[lstFiliais:nAt]
		aCompleto := AADD(lstGrp1:aArray, aElAdd)
		ADEL( lstFiliais:aArray, lstFiliais:nAt )
		ASIZE(lstFiliais:aArray, LEN(lstFiliais:aArray) -1)
	EndIf
Return .T.

Static Function Add2()
	if Len(lstFiliais:aArray) > 0
		aElAdd := lstFiliais:aArray[lstFiliais:nAt]
		aCompleto := AADD(lstGrp2:aArray, aElAdd)
		ADEL( lstFiliais:aArray, lstFiliais:nAt )
		ASIZE(lstFiliais:aArray, LEN(lstFiliais:aArray) -1)
	EndIf
Return .T.

Static Function Add3()
	if Len(lstFiliais:aArray) > 0
		aElAdd := lstFiliais:aArray[lstFiliais:nAt]
		aCompleto := AADD(lstGrp3:aArray, aElAdd)
		ADEL( lstFiliais:aArray, lstFiliais:nAt )
		ASIZE(lstFiliais:aArray, LEN(lstFiliais:aArray) -1)
	EndIf
Return .T.

Static Function Add4()
	if Len(lstFiliais:aArray) > 0
		aElAdd := lstFiliais:aArray[lstFiliais:nAt]
		aCompleto := AADD(lstGrp4:aArray, aElAdd)
		ADEL( lstFiliais:aArray, lstFiliais:nAt )
		ASIZE(lstFiliais:aArray, LEN(lstFiliais:aArray) -1)
	EndIf
Return .T.

/*/{Protheus.doc} Rem

	@author       Vinicius Gati
	@since        29/07/2015
	@description  Remove do grupo a filial selecionada 

/*/
Static Function Rem1()
	If LEN(lstGrp1:aArray) > 0
		aElRev := lstGrp1:aArray[lstGrp1:nAt]
		ADEL( lstGrp1:aArray, lstGrp1:nAt )
		ASIZE( lstGrp1:aArray, LEN(lstGrp1:aArray) -1)
		AADD( lstFiliais:aArray, aElRev )
	EndIf
Return .T.

Static Function Rem2()
	If LEN(lstGrp2:aArray) > 0
		aElRev := lstGrp2:aArray[lstGrp2:nAt]
		ADEL( lstGrp2:aArray, lstGrp2:nAt )
		ASIZE(lstGrp2:aArray, LEN(lstGrp2:aArray) -1)
		AADD( lstFiliais:aArray, aElRev )
	EndIf
Return .T.

Static Function Rem3()
	If LEN(lstGrp3:aArray) > 0
		aElRev := lstGrp3:aArray[lstGrp3:nAt]
		ADEL( lstGrp3:aArray, lstGrp3:nAt )
		ASIZE(lstGrp3:aArray, LEN(lstGrp3:aArray) -1)
		AADD( lstFiliais:aArray, aElRev )
	EndIf
Return .T.

Static Function Rem4()
	If LEN(lstGrp3:aArray) > 0
		aElRev := lstGrp4:aArray[lstGrp4:nAt]
		ADEL( lstGrp4:aArray, lstGrp4:nAt )
		ASIZE(lstGrp4:aArray, LEN(lstGrp4:aArray) -1)
		AADD( lstFiliais:aArray, aElRev )
	EndIf
Return .T.

/*/{Protheus.doc} FS_CONFIRMA

	@author       Vinicius Gati
	@since        21/08/2015
	@description  Acao do botao confirma, salva os dados de configuração

/*/
Static Function FS_CONFIRMA()
	Local aFilsGrp1 := lstGrp1:aArray
	Local aFilsGrp2 := lstGrp2:aArray
	Local aFilsGrp3 := lstGrp3:aArray
	Local aFilsGrp4 := lstGrp4:aArray
	Local nIdx      := 1
	Local cSchedFile := FM_SQL("SELECT MAX(VQL_DADOS) FROM "+ RetSqlName('VQL') + " WHERE VQL_TIPO = 'DPMSCHED_FILE' ")
	Local cSchedImp := FM_SQL("SELECT MAX(VQL_DADOS) FROM "+ RetSqlName('VQL') + " WHERE VQL_TIPO = 'DPMSCHED_IMP' ")
	

	BEGIN TRANSACTION

		// 'DPMSCHED_IMP''DPMSCHED_FILE' estes 2 são do prism, devem ser deletados pois a configuração pode mudar, mas somente estes!
		TcSqlExec(" UPDATE " + RetSqlName('VQL') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP IN ('DPMC1','DPMC2','DPMC3','DPMC4') AND VQL_TIPO IN ('FILS', 'PATH', 'CONTA', 'DPMSCHED_IMP','DPMSCHED_FILE') ")


		If ! Empty(aFilsGrp1)
			For nIdx := 1 to Len(aFilsGrp1)
				aFil := aFilsGrp1[nIdx]
				oLogger:LogToTable({ ;
					{'VQL_AGROUP' , 'DPMC1'      },;
					{'VQL_TIPO'   , 'FILS'       },;
					{'VQL_DADOS'  , ALLTRIM(aFil[1])      } ;
				})
			Next
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC1'           },;
				{'VQL_TIPO'   , 'PATH'            },;
				{'VQL_DADOS'  , ALLTRIM(cTxtPath1)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC1'           },;
				{'VQL_TIPO'   , 'CONTA'            },;
				{'VQL_DADOS'  , ALLTRIM(ctxtConta1)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC1'           },;
				{'VQL_TIPO'   , 'DPMSCHED_FILE'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedFile)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC1'           },;
				{'VQL_TIPO'   , 'DPMSCHED_IMP'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedImp)} ;
			})
		EndIf

		If ! Empty(aFilsGrp2)
			For nIdx := 1 to Len(aFilsGrp2)
				aFil := aFilsGrp2[nIdx]
				oLogger:LogToTable({ ;
					{'VQL_AGROUP' , 'DPMC2'     },;
					{'VQL_TIPO'   , 'FILS'      },;
					{'VQL_DADOS'  , ALLTRIM(aFil[1])     } ;
				})
			Next
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC2'},;
				{'VQL_TIPO'   , 'PATH'   },;
				{'VQL_DADOS'  , ALLTRIM(cTxtPath2)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC2'           },;
				{'VQL_TIPO'   , 'CONTA'            },;
				{'VQL_DADOS'  , ALLTRIM(ctxtConta2)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC2'           },;
				{'VQL_TIPO'   , 'DPMSCHED_FILE'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedFile)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC2'           },;
				{'VQL_TIPO'   , 'DPMSCHED_IMP'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedImp)} ;
			})
		EndIf

		If ! Empty(aFilsGrp3)
			For nIdx := 1 to Len(aFilsGrp3)
				aFil := aFilsGrp3[nIdx]
				oLogger:LogToTable({ ;
					{'VQL_AGROUP' , 'DPMC3'     },;
					{'VQL_TIPO'   , 'FILS'      },;
					{'VQL_DADOS'  , ALLTRIM(aFil[1])     } ;
				})
			Next
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC3'},;
				{'VQL_TIPO'   , 'PATH'   },;
				{'VQL_DADOS'  , ALLTRIM(cTxtPath3)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC3'           },;
				{'VQL_TIPO'   , 'CONTA'            },;
				{'VQL_DADOS'  , ALLTRIM(ctxtConta3)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC3'           },;
				{'VQL_TIPO'   , 'DPMSCHED_FILE'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedFile)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC3'           },;
				{'VQL_TIPO'   , 'DPMSCHED_IMP'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedImp)} ;
			})
		EndIf

		If ! Empty(aFilsGrp4)
			For nIdx := 1 to Len(aFilsGrp4)
				aFil := aFilsGrp4[nIdx]
				oLogger:LogToTable({ ;
					{'VQL_AGROUP' , 'DPMC4'    },;
					{'VQL_TIPO'   , 'FILS'     },;
					{'VQL_DADOS'  , ALLTRIM(aFil[1])    } ;
				})
			Next
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC4'},;
				{'VQL_TIPO'   , 'PATH'   },;
				{'VQL_DADOS'  , ALLTRIM(cTxtPath4)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC4'           },;
				{'VQL_TIPO'   , 'CONTA'            },;
				{'VQL_DADOS'  , ALLTRIM(ctxtConta4)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC4'           },;
				{'VQL_TIPO'   , 'DPMSCHED_FILE'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedFile)} ;
			})
			oLogger:LogToTable({ ;
				{'VQL_AGROUP' , 'DPMC4'           },;
				{'VQL_TIPO'   , 'DPMSCHED_IMP'            },;
				{'VQL_DADOS'  , ALLTRIM(cSchedImp)} ;
			})
		EndIf

	END TRANSACTION
Return .T.

/*/{Protheus.doc} FS_CANCELA

	@author       Vinicius Gati
	@since        21/08/2015
	@description  Cancela tudo e volta para mbrowse

/*/
Static Function FS_CANCELA()
Return .T.

/*/{Protheus.doc} FS_FS_GETFILE

	@author       Vinicius Gati
	@since        21/08/2015
	@description  Selecao de caminho dos arquivos DPM

/*/
Function OJD27GtFile()
Return cGetFile( '', STR0001, 1, '', .F., nOR( GETF_NETWORKDRIVE, GETF_RETDIRECTORY ),.T., .T. ) //Caminho
