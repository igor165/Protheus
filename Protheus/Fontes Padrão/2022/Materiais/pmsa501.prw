#INCLUDE "PROTHEUS.CH"

//Objeto para a classe FwTemporaryTable (Cria tabela temporária no banco de dados)
Static _oPMS5011
Static _oPMS5012

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMS800Dlg ³ Autor ³ Reynaldo Miyashita    ³ Data ³16/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Dialog da Planilha de cotação do projeto                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PMS501Pln()
Local oPanel
Local oPanel1
Local oEnch
Local oFntVerdana

Local aArea       := GetArea()
Local dIni
Local dX
Local nY          := 0
Local nX          := 0
Local lContinua   := .T.
Local aSize       := {}
Local aObjects    := {} 
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aHeadAEEPrd := {}
Local aHeadAEERec := {}
Local aHeadAECPrd := {}
Local aHeadAECRec := {}
Local aColsAEEPrd := {}
Local aColsAEERec := {}
Local aColsAECPrd := {}
Local aColsAECREc := {}
Local aRecAECPrd  := {}
Local aRecAECREc  := {}
Local nOpc        := 0
Local nZ          := 0
Local nOpcGDAEC   := 0
Local nOpcGDAEE   := 0
Local aStrAECPrd  := {}
Local aStrAECRec  := {}
Local aStrAEEPrd  := {}
Local aStrAEERec  := {}
Local nI          := 0
Local nOpcGet     := 0
Local dFecha      := stod("")

PRIVATE oGDAEEPrd
PRIVATE oGDAECPrd
PRIVATE oGDAEERec
PRIVATE oGDAECRec
PRIVATE oSayProd
PRIVATE oSayRec
PRIVATE INCLUI  := .F.
PRIVATE ALTERA  := .F.
PRIVATE EXCLUI  := .F.

PRIVATE cAliasRec  := ""
PRIVATE cAliasPRD  := ""

	INCLUI  := .F.
	ALTERA  := .T.
	EXCLUI  := .F.
	nOpcGDAEC := GD_UPDATE
	nOpcGDAEE := GD_INSERT + GD_DELETE + GD_UPDATE
	nOpcGet := 4

	If lContinua
	
		// montagem do aHeadAEEPrd
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEE")
		While !EOF() .And. (x3_arquivo == "AEE")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO)$"AEE_RECURS")
				aAdd( aHeadAEEPrd ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			                     ,SX3->X3_PICTURE     ,SX3->X3_TAMANHO ;
			                     ,SX3->X3_DECIMAL     ,SX3->X3_VALID ;
			                     ,SX3->X3_USADO	      ,SX3->X3_TIPO ;
			                     ,SX3->X3_F3          ,SX3->X3_CONTEXT ;
			                     ,SX3->X3_CBOX        ,SX3->X3_RELACAO})
			Endif
			
			If x3_context != "V"
				aAdd(aStrAEEPrd ,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			EndIf
			
			dbSkip()
		EndDo
		
		// montagem do aHeadAEEPrd
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEE")
		While !EOF() .And. (x3_arquivo == "AEE")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO)$"AEE_PRODUT")
				aAdd( aHeadAEERec ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			                     ,SX3->X3_PICTURE     ,SX3->X3_TAMANHO ;
			                     ,SX3->X3_DECIMAL     ,SX3->X3_VALID ;
			                     ,SX3->X3_USADO	      ,SX3->X3_TIPO ;
			                     ,SX3->X3_F3          ,SX3->X3_CONTEXT ;
			                     ,SX3->X3_CBOX        ,SX3->X3_RELACAO})
			Endif
			
			If x3_context != "V"
				aAdd(aStrAEERec ,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			EndIf
			
			dbSkip()
		EndDo
		
		// montagem do aHeadAEC
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEC")
		While !EOF() .And. (x3_arquivo == "AEC")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. !(AllTrim(X3_CAMPO)$"AEC_RECURS")
				
				aAdd( aHeadAECPrd ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			                     ,SX3->X3_PICTURE     ,SX3->X3_TAMANHO ;
			                     ,SX3->X3_DECIMAL     ,SX3->X3_VALID ;
			                     ,SX3->X3_USADO	      ,SX3->X3_TIPO ;
			                     ,SX3->X3_F3          ,SX3->X3_CONTEXT ;
			                     ,SX3->X3_CBOX        ,SX3->X3_RELACAO})
			Endif
			If x3_context != "V"
				aAdd(aStrAECPrd ,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			EndIf
			
			dbSkip()
		EndDo
		
		// montagem do aHeadAEC
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AEC")
		While !EOF() .And. (x3_arquivo == "AEC")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. !(AllTrim(X3_CAMPO)$"AEC_PRODUT")
				
				aAdd( aHeadAECRec ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			                     ,SX3->X3_PICTURE     ,SX3->X3_TAMANHO ;
			                     ,SX3->X3_DECIMAL     ,SX3->X3_VALID ;
			                     ,SX3->X3_USADO	      ,SX3->X3_TIPO ;
			                     ,SX3->X3_F3          ,SX3->X3_CONTEXT ;
			                     ,SX3->X3_CBOX        ,SX3->X3_RELACAO})
			Endif
			If x3_context != "V"
				aAdd(aStrAECRec ,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			EndIf
			
			dbSkip()
		EndDo

		//
		// Cria um espelho da tabela AEC para manipulacao para o projeto
		//

		If _oPMS5011 <> Nil
			_oPMS5011:Delete()
			_oPMS5011 := Nil
		Endif
		
		cAliasPRD := GetNextAlias()
		
		_oPMS5011 := FWTemporaryTable():New( cAliasPRD )  
		_oPMS5011:SetFields(aStrAECPrd) 
		_oPMS5011:AddIndex("1", {"AEC_FILIAL","AEC_PROJET","AEC_REVISA","AEC_PRODUT","AEC_DATREF"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMS5011:Create()		
	
		If _oPMS5012 <> Nil
			_oPMS5012:Delete()
			_oPMS5012 := Nil
		Endif
		
		cAliasRec := GetNextAlias()
			
		_oPMS5012 := FWTemporaryTable():New( cAliasRec )  
		_oPMS5012:SetFields(aStrAECRec) 
		_oPMS5012:AddIndex("1", {"AEC_FILIAL","AEC_PROJET","AEC_REVISA","AEC_RECURS","AEC_DATREF"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMS5012:Create()	
		
		// faz a montagem do aColsAEEPrd
		dbSelectArea("AEE")
		dbSetOrder(1)
		dbSeek(xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA))
		While !Eof() .And. AEE->(AEE_FILIAL+AEE_PROJET+AEE_REVISA)==xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA)

			If ! Empty(AEE->AEE_RECURS)
				aAdd(aColsAEERec ,Array(Len(aHeadAEERec)+1))
				For nY := 1 to Len(aHeadAEERec)
					If (aHeadAEERec[nY ,10] != "V")
						aColsAEERec[Len(aColsAEERec) ,nY] := FieldGet(FieldPos(aHeadAEERec[nY ,2]))
					Else
						aColsAEERec[Len(aColsAEERec) ,nY] := CriaVar(aHeadAEERec[nY ,2])
					EndIf
				Next nY
				aColsAEERec[Len(aColsAEERec) ,Len(aHeadAEERec)+1] := .F.
			Else 
				aAdd(aColsAEEPrd ,Array(Len(aHeadAEEPrd)+1))
				For nY := 1 to Len(aHeadAEEPrd)
					If (aHeadAEEPrd[nY ,10] != "V")
						aColsAEEPrd[Len(aColsAEEPrd) ,nY] := FieldGet(FieldPos(aHeadAEEPrd[nY ,2]))
					Else
						aColsAEEPrd[Len(aColsAEEPrd) ,nY] := CriaVar(aHeadAEEPrd[nY ,2])
					EndIf
				Next nY
				aColsAEEPrd[Len(aColsAEEPrd) ,Len(aHeadAEEPrd)+1] := .F.

			EndIf
			
			dbSkip()
		EndDo
		
		If Empty(aColsAEEPrd)
			// faz a montagem de uma linha em branco no aColsAFA
			aadd(aColsAEEPrd ,Array(Len(aHeadAEEPrd)+1))
			For ny := 1 to Len(aHeadAEEPrd)
				aColsAEEPrd[Len(aColsAEEPrd) ,nY] := CriaVar(aHeadAEEPrd[nY ,2])
			Next ny
			aColsAEEPrd[Len(aColsAEEPrd) ,Len(aHeadAEEPrd)+1] := .F.
		EndIf
		If Empty(aColsAEERec)
			// faz a montagem de uma linha em branco no aColsAFA
			aadd(aColsAEERec ,Array(Len(aHeadAEERec)+1))
			For ny := 1 to Len(aHeadAEERec)
				aColsAEERec[Len(aColsAEERec) ,nY] := CriaVar(aHeadAEERec[nY ,2])
			Next ny
			aColsAEERec[Len(aColsAEERec) ,Len(aHeadAEERec)+1] := .F.
		EndIf
        
		// Carrega a aColsAEC referente ao produto da linha atual
		dbSelectArea("AEC")
		dbSetOrder(1)
		dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA))
		While !Eof() .And. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA)==xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)
		
			If ! Empty(AEC->AEC_RECURS)
				RecLock( cAliasREC ,.T.)
				For nX := 1 To AEC->(fCount())
					If !(AEC->(FieldName(nX)) == "AEC_PRODUT")
						(cAliasREC)->(FieldPut(FieldPos(AEC->(FieldName(nX))) ,AEC->(FieldGet(FieldPos(FieldName(nX))))))
					EndIF
				Next nX 
				(cAliasREC)->AEC_FILIAL	:= xFilial("AEC")
				msUnlock()
			Else
				RecLock( cAliasPRD ,.T.)
				For nX := 1 To AEC->(fCount())
					If !(AEC->(FieldName(nX)) == "AEC_RECURS")
						(cAliasPRD)->(FieldPut(FieldPos(AEC->(FieldName(nX))) ,AEC->(FieldGet(FieldPos(FieldName(nX))))))
					EndIf
				Next nX 
				(cAliasPRD)->AEC_FILIAL	:= xFilial("AEC")
				msUnlock()
			EndIf
			dbSelectArea("AEC")
			dbSkip()
		EndDo
		
		AECLoadPrd(aHeadAECPRD ,aColsAECPRD ,cAliasPRD ,AJB->AJB_PROJET ,AJB->AJB_REVISA ,"" ,aColsAEEPrd[1 ,1] ,aRecAECPRD )
		AECLoadrec(aHeadAECrec ,aColsAECrec ,cAliasrec ,AJB->AJB_PROJET ,AJB->AJB_REVISA ,"" ,aColsAEErec[1 ,1] ,aRecAECrec )
		
		If Empty(aColsAECPrd)
			// faz a montagem de uma linha em branco no aColsAFA
			aadd(aColsAECPrd ,Array(Len(aHeadAECPrd)+1))
			For ny := 1 to Len(aHeadAECprd)
				aColsAECPRD[Len(aColsAECPRD) ,nY] := CriaVar(aHeadAECPRD[nY ,2])
			Next ny
			aColsAECPRD[Len(aColsAECPRD) ,Len(aHeadAECPRD)+1] := .F.
		EndIf

		If Empty(aColsAECRec)
			// faz a montagem de uma linha em branco no aColsAFA
			aadd(aColsAECreC ,Array(Len(aHeadAECREC)+1))
			For ny := 1 to Len(aHeadAECREC)
				aColsAECREC[Len(aColsAECREC) ,nY] := CriaVar(aHeadAECREC[nY ,2])
			Next ny
			aColsAECREC[Len(aColsAECREC) ,Len(aHeadAECREC)+1] := .F.
		EndIf

		// verifica os botoes de usuarios
		If ExistBlock("PMA501BTN")
			aButtons := ExecBlock("PMA501BTN",.F.,.F.,{aButtons})
			If !(ValType(aButtons) == "A")
				MsgAlert("Ponto de entrada PMA501BTN gerou um retorno inválido")
				aButtons := {}
			EndIf
		EndIf

		// faz o calculo automatico de dimensoes de objetos
		oMainWnd:CoorsUpdate()
		aSize := MsAdvSize(,.F.,400)
		aObjects := {} 
				
		aAdd( aObjects, { 150, 150 , .T., .T. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		oDlg:CoorsUpdate()
		oDlg:refresh()

		oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],{"Produto","Recurso"},{},oDlg ,,,,.T. ,.T.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1])
		oFolder:refresh()

		// 737,4 / 737,756
		oPnlAEEPrd := TPanel():New(2,2,'',oFolder:aDialogs[1],oDlg:oFont,.T.,.T.,,,(aPosObj[1,4]-aPosObj[1,2])*(3/5),aPosObj[1,3]-aPosObj[1,1]-15,.T.,.T. )

		/*
		MsNewGetDados:= {nTop, nLeft, nBottom, nRight, [ nStyle ], [ uLinhaOk ], [ uTudoOk ], [ cIniCpos ], ;
								[ aAlter ], [ nFreeze ], [ nMax ], [ cFieldOk ], [ uSuperDel ], [ uDelOk ], [ oWnd ],;
								[ aParHeader ], [ aParCols ])
		*/
		// 0,0 / 737,756
		oGDAEEPrd  := MsNewGetDados():New(0,0,50,75,nOpcGDAEE,"AlwaysTrue","AlwaysTrue",,,,999,"SAEEFieldOK(oGDAECPrd ,oGDAEEPrd ,oSayProd)",,,oPnlAEEPrd,aHeadAEEPrd,aColsAEEPrd)
		oGDAEEPrd:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT
		oGDAEEPrd:oBrowse:bChange   := {|| GDAEEChange(oGDAEEPrd ,oGDAECPrd ,cAliasPRD ,AJB->AJB_PROJET ,AJB->AJB_REVISA)}
		oGDAEEPrd:bLinhaOk          := {|| GDAEELinOK(oGDAEEPrd)}
//		oGDAEEPrd:bTudoOk           := {|| GDAEETudoOK(oGDAEEPrd)}
		oGDAEEPrd:oBrowse:bGotFocus := {|| GDAEEChange(oGDAEEPrd ,oGDAECPrd ,cAliasPRD ,AJB->AJB_PROJET ,AJB->AJB_REVISA)}
		oGDAEEPrd:Cargo := oGDAEEPrd:nAt
		oGDAEEPrd:oBrowse:refresh()
		
    	//4,860 /737,394
		oPnlAECPrd := TPanel():New(2,aPosObj[1,2]+50+((aPosObj[1,4]-aPosObj[1,2])*(3/5)),'',oFolder:aDialogs[1],oDlg:oFont,.T.,.T.,,,((aPosObj[1,4]-aPosObj[1,2])*(2/5))-55,aPosObj[1,3]-aPosObj[1,1]-15,.T.,.T. )

		DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -12 BOLD

		@ 3,14 SAY oSayProd PROMPT "Produto: " SIZE 150,12 Of oPnlAECPrd FONT oFntVerdana COLOR RGB(80,80,80) PIXEL 
		oSayProd:Align := CONTROL_ALIGN_TOP
		
    	//24,04 /713,394
		oGDAECPrd  := MsNewGetDados():New(12,2,50,75,nOpcGDAEC,"AllwaysTrue","AllwaysTrue",,,,999,"SAECFieldOK(oGdAECPrd)",,,oPnlAECPrd,aHeadAECPrd,aColsAECPrd)
		oGDAECPrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGDAECPrd:bLinhaOk      := {|| GDAECLinOK(oGDAECPrd)}
		oGDAECPrd:bTudoOk       := {|| GDAECTudoOK(oGDAECPrd)}
		oGDAECPrd:Cargo         := aRecAECPrd
		
		oPnlAEERec := TPanel():New(2,2,'',oFolder:aDialogs[2],oDlg:oFont,.T.,.T.,,,(aPosObj[1,4]-aPosObj[1,2])*(3/5) ,aPosObj[1,3]-aPosObj[1,1]-15,.T.,.T. )

		/*
		MsNewGetDados:= {nTop, nLeft, nBottom, nRight, [ nStyle ], [ uLinhaOk ], [ uTudoOk ], [ cIniCpos ], ;
								[ aAlter ], [ nFreeze ], [ nMax ], [ cFieldOk ], [ uSuperDel ], [ uDelOk ], [ oWnd ],;
								[ aParHeader ], [ aParCols ])
		*/
		oGDAEEREC  := MsNewGetDados():New(2,2,368 ,375 ,nOpcGDAEE,"AlwaysTrue","AlwaysTrue",,,,999,"SAEEFieldOK(oGDAECRec ,oGDAEERec ,oSayRec)",,,oPnlAEERec,aHeadAEERec,aColsAEERec)
		oGDAEEREC:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT
		oGDAEEREC:oBrowse:bChange   := {|| GDAEERChange(oGDAEEREC ,oGDAECRec ,cAliasREC ,AJB->AJB_PROJET ,AJB->AJB_REVISA)}
		oGDAEEREC:bLinhaOk          := {|| GDAEERLinOK(oGDAEEREC)}
//		oGDAEEREC:bTudoOk           := {|| GDAEERTudoOK(oGDAEEREC)}
		oGDAEEREC:oBrowse:bGotFocus := {|| GDAEERChange(oGDAEEREC ,oGDAECRec ,cAliasREC ,AJB->AJB_PROJET ,AJB->AJB_REVISA)}
		oGDAEEREC:Cargo := oGDAEEREC:nAt
		oGDAEEREC:oBrowse:refresh()

		oPnlAECRec := TPanel():New(2,aPosObj[1,2]+50+((aPosObj[1,4]-aPosObj[1,2])*(3/5)),'',oFolder:aDialogs[2],oDlg:oFont,.T.,.T.,,,((aPosObj[1,4]-aPosObj[1,2])*(2/5))-55,aPosObj[1,3]-aPosObj[1,1]-15,.T.,.T. )

		@ 3,2 SAY oSayRec PROMPT "Recurso: " SIZE 150,12 Of oPnlAECRec FONT oFntVerdana COLOR RGB(80,80,80) PIXEL 
		oSayRec:Align := CONTROL_ALIGN_TOP       
		
		oGDAECRec  := MsNewGetDados():New(12 ,2 ,oGDAECPrd:oBrowse:nClientWidth-100 ,oGDAECPrd:oBrowse:nClientHeight-100 ,nOpcGDAEC,"AllwaysTrue","AllwaysTrue",,,,999,"SAECFieldOK(oGdAECRec)",,,oPnlAECRec,aHeadAECRec,aColsAECRec)
		oGDAECRec:bLinhaOk          := {|| GDAECRLinOK(oGDAECRec)}
		oGDAECRec:bTudoOk           := {|| GDAECRTudoOK(oGDAECRec)}
		oGDAECRec:Cargo := aRecAECRec
		oGDAECRec:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGDAECRec:obrowse:refresh()
		
		ACTIVATE MSDIALOG oDlg ON INIT ( oFolder:aDialogs[2]:Refresh() ,oPnlAEERec:Refresh() ,oPnlAECRec:Refresh() ,oGDAECRec:oBrowse:Refresh() ,oGDAEERec:oBrowse:Refresh();
		                                ,EnchoiceBar(oDlg ,{||(eVal(oGDAEEPrd:oBrowse:bChange) ,eVal(oGDAEEREC:oBrowse:bChange),iIf( DlgValid(oEnch ,oGDAEEPrd ,oGDAECPrd) ,(nOpc:=1 ,oDlg:End()) ,nOpc:= 0 ))} ,{||oDlg:End()},,aButtons) ;
		                                ,oFolder:aDialogs[1]:Refresh() ,oPnlAEEPrd:Refresh() ,oPnlAECPrd:Refresh() ,oGDAECPRD:oBrowse:Refresh() ,oGDAEEPRD:oBrowse:Refresh() ;
		                                )

		If (nOpc == 1) 
		
			Begin Transaction
				PMS800Grava(cAliasPRD ,oGDAECPrd:aHeader ,oGDAECPrd:aCols ,oGDAEEPrd:aHeader ,oGDAEEPrd:aCols ,cAliasREC ,oGDAEErec:aHeader ,oGDAEErec:aCols)
			End Transaction
		
		EndIf
		
		(cAliasPRD)->(dbCloseArea())
		
		//Deleta tabelas temporarias criadas no banco de dados
		If _oPMS5011 <> Nil
			_oPMS5011:Delete()
			_oPMS5011 := Nil
		Endif
		
		If _oPMS5012 <> Nil
			_oPMS5012:Delete()
			_oPMS5012 := Nil
		Endif
		
	EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

Return .T.  

Static Function DlgValid(oEnch ,oGDAEEPrd ,oGDAECPrd)
Local lOk := .T.
    
	//lOk := Obrigatorio( oEnch:aGets ,oEnch:aTela )

Return lOk

Static Function GDAEEChange( oGDAEEPrd ,oGDAECPrd ,cAliasPRD ,cProjeto ,cRevisa)
Local cProdOld := ""
Local aHeadAEC := {}
Local aColsAEC := {}
Local nPosAnt  := 0
Local aRecAEC  := {}

	aHeadAEC := oGDAECPrd:aHeader
	aColsAEC := oGDAECPrd:aCols
	aRecAEC	 := oGDAECPrd:Cargo

	nPosAnt := oGDAEEPrd:Cargo

	If nPosAnt<1 
		cProdOld := oGDAEEPrd:aCols[1 ,1]
	Else  
		If nPosAnt > Len(oGDAEEPrd:aCols)
			cProdOld := ""
		Else
			cProdOld := oGDAEEPrd:aCols[nPosAnt ,1]
		EndIf
	EndIf
		
	AECLoadPrd(aHeadAEC ,aColsAEC ,cAliasPRD ,cProjeto ,cRevisa ,cProdOld ,oGDAEEPrd:aCols[oGDAEEPrd:nAt ,1] ,aRecAEC )
	oGDAEEPrd:Cargo := oGDAEEPrd:nAt 
	oGDAECPrd:aCols := aColsAEC 
	oGDAECPrd:Cargo := aRecAEC 
	oGDAECPrd:oBrowse:Refresh()

	oSayProd:cTitle := "Produto: " + oGDAEEPrd:aCols[oGDAEEPrd:nAt ,1]
	oSayProd:refresh()
	
Return .T.

Static Function GDAEERChange( oGDAEEREC ,oGDAECREC ,cAlias ,cProjeto ,cRevisa)
Local crecOld := ""
Local aHeadAEC := {}
Local aColsAEC := {}
Local nPosAnt  := 0
Local aRecAEC  := {}

	aHeadAEC := oGDAECRec:aHeader
	aColsAEC := oGDAECRec:aCols
	aRecAEC	 := oGDAECRec:Cargo

	nPosAnt := oGDAEERec:Cargo

	If nPosAnt<1 
		cRecOld := oGDAEEREC:aCols[1 ,1]
	Else  
		If nPosAnt > Len(oGDAEERec:aCols)
			cRecOld := ""
		Else
			cRecOld := oGDAEERec:aCols[nPosAnt ,1]
		EndIf
	EndIf
		
	AECLoadREC(aHeadAEC ,aColsAEC ,cAlias ,cProjeto ,cRevisa ,cRecOld ,oGDAEErec:aCols[oGDAEERec:nAt ,1] ,aRecAEC )
	oGDAEErec:Cargo := oGDAEErec:nAt 
	oGDAECrec:aCols := aColsAEC 
	oGDAECrec:Cargo := aRecAEC 
	oGDAECrec:oBrowse:Refresh()

	oSayrec:cTitle := "Recurso: " + oGDAEERec:aCols[oGDAEERec:nAt ,1]
	oSayrec:refresh()
	
Return .T.

Static Function AECLoadPrd(aHeadAEC ,aColsAEC ,cAliasPRD ,cProjeto ,cRevisa ,cProdOld ,cProdNew ,aRecAEC)
Local nY       := 0
Local nX       := 0
Local nZ       := 0
Local lSeek    := .T.
Local aDatas   := {}
Local aNewDatas := {}
Local aRecUso  := {}
Local aArea    := GetArea()
Local aAreaAEC := AEC->(GetArea())
Local nPosDatRef := aScan(aHeadAEC, {|x| alltrim(x[2]) == "AEC_DATREF"})

DEFAULT cProjeto := ""
DEFAULT cRevisa  := ""
DEFAULT cProdOld := ""
DEFAULT cProdNew := ""
DEFAULT aRecAEC  := {}

	dbSelectArea("AEC")
	dbSetOrder(1)
	
	If !Empty(cProjeto) .OR. !Empty(cRevisa)
		// grava a aColsAEC referente ao produto da linha anterior
 		If !Empty(cProdOld)
			dbSelectArea(cAliasPRD)
			dbSetOrder(1)
			For nY := 1 To len(aColsAEC)
				If (lSeek := dbSeek(xFilial("AEC")+cProjeto+cRevisa+cProdOld+dtos(aColsAEC[nY ,nPosDatRef])))
					aAdd(aRecUso ,(cAliasPRD)->(Recno()))
				EndIf
				RecLock( cAliasPRD ,!lSeek)
				For nX := 1 To Len(aHeadAEC)
					If ( aHeadAEC[nX,10] != "V" )
						(cAliasPRD)->(FieldPut(FieldPos(aHeadAEC[nX ,2]),aColsAEC[nY ,nX]))
					EndIf
				Next nX
				(cAliasPRD)->AEC_PRODUT	:= cProdOld
				(cAliasPRD)->AEC_REVISA	:= cRevisa
				(cAliasPRD)->AEC_PROJET	:= cProjeto
				(cAliasPRD)->AEC_FILIAL	:= xFilial("AEC")
				MsUnlock()
	        Next nY
	        
	        For nY := 1 To len(aRecAEC)
				If aScan(aRecUso, aRecAEC[nY]) == 0  // se existia o registro e nao foi usado
					(cAliasPRD)->(dbGoto(aRecAEC[nY]))
					RecLock(cAliasPRD ,.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
	        Next nY
        EndIf
        
		aColsAEC := {}
		aRecAEC  := {}
		
		// Carrega as datas do intervalo de periodo
		aDatas := PmsPeriod(AF8->AF8_TPPERI ,AF8->AF8_INIPER ,AF8->AF8_FIMPER)
 		
 		For nY := 1 To Len(aDatas)
 			If aDatas[nY] >= AF8->AF8_ULMES 
	 			aAdd(aNewDatas ,aDatas[nY])
	 		EndIf
 		Next nY
 		aDatas := aNewDatas
 		    
		// Carrega a aColsAEC referente ao produto da linha atual
		dbSelectArea(cAliasPRD)
		dbSetOrder(1)
 		For nZ := 1 to len(aDatas)
			// faz a montagem de uma linha em branco no aColsAEC
			aAdd(aColsAEC ,Array(Len(aHeadAEC)+1))
			
			If !Empty(cProdNew) .AND. dbSeek(xFilial("AEC")+cProjeto+cRevisa+cProdNew+dtos(aDatas[nZ]))
				For nY := 1 to Len(aHeadAEC)
					If (aHeadAEC[nY ,10] != "V")
						aColsAEC[Len(aColsAEC) ,nY] := FieldGet(FieldPos(aHeadAEC[nY ,2]))
					Else
						aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
					EndIf
				Next nY
				aAdd( aRecAEC ,(cAliasPRD)->(Recno()))
			Else
				For nY := 1 to Len(aHeadAEC)
					aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
					If AllTrim(aHeadAEC[nY,2]) == "AEC_DATREF"
						aColsAEC[Len(aColsAEC) ,nY] := aDatas[nZ]
					EndIf
				Next nY
			EndIf
			aColsAEC[Len(aColsAEC) ,Len(aHeadAEC)+1] := .F.
		Next nZ	

		If Empty(aColsAEC)
			// faz a montagem de uma linha em branco no aColsAEC
			aAdd(aColsAEC ,Array(Len(aHeadAEC)+1))
			For ny := 1 to Len(aHeadAEC)
				aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
			Next ny
			aColsAEC[Len(aColsAEC) ,Len(aHeadAEC)+1] := .F.
		EndIf
		
    EndIf
    
	RestArea(aAreaAEC)
	RestArea(aArea)
	
Return .T.

Static Function AECLoadRec(aHeadAEC ,aColsAEC ,cAlias ,cProjeto ,cRevisa ,cRECOld ,cRECNew ,aRecAEC)
Local nY       := 0
Local nX       := 0
Local nZ       := 0
Local lSeek    := .T.
Local aDatas   := {}
Local aNewDatas := {}
Local aRecUso  := {}
Local aArea    := GetArea()
Local aAreaAEC := AEC->(GetArea())
Local nPosDatRef := aScan(aHeadAEC, {|x| alltrim(x[2]) == "AEC_DATREF"})

DEFAULT cProjeto := ""
DEFAULT cRevisa  := ""
DEFAULT cRECOld  := ""
DEFAULT cRECNew  := ""
DEFAULT aRecAEC  := {}

	dbSelectArea("AEC")
	dbSetOrder(2)
	
	If !Empty(cProjeto) .OR. !Empty(cRevisa)
		// grava a aColsAEC referente ao produto da linha anterior
 		If !Empty(cRECOLD)
			dbSelectArea(cAlias)
			dbSetOrder(1)
			For nY := 1 To len(aColsAEC)
				If (lSeek := dbSeek(xFilial("AEC")+cProjeto+cRevisa+cRECOld+dtos(aColsAEC[nY ,nPosDatRef])))
					aAdd(aRecUso ,(cAlias)->(Recno()))
				EndIf
				RecLock( cAlias ,!lSeek)
				For nX := 1 To Len(aHeadAEC)
					If ( aHeadAEC[nX,10] != "V" )
						(cAlias)->(FieldPut(FieldPos(aHeadAEC[nX ,2]),aColsAEC[nY ,nX]))
					EndIf
				Next nX
				(cAlias)->AEC_RECURS	:= cRECOld
				(cAlias)->AEC_REVISA	:= cRevisa
				(cAlias)->AEC_PROJET	:= cProjeto
				(cAlias)->AEC_FILIAL	:= xFilial("AEC")
				MsUnlock()
	        Next nY
	        
	        For nY := 1 To len(aRecAEC)
				If aScan(aRecUso, aRecAEC[nY]) == 0  // se existia o registro e nao foi usado
					(cAlias)->(dbGoto(aRecAEC[nY]))
					RecLock(cAlias ,.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
	        Next nY
        EndIf
        
		aColsAEC := {}
		aRecAEC  := {}
		
		// Carrega as datas do intervalo de periodo
		aDatas := PmsPeriod(AF8->AF8_TPPERI ,AF8->AF8_INIPER ,AF8->AF8_FIMPER)
 		    
 		For nY := 1 To Len(aDatas)
 			If aDatas[nY] >= AF8->AF8_ULMES 
	 			aAdd(aNewDatas ,aDatas[nY])
	 		EndIf
 		Next nY
 		aDatas := aNewDatas

		// Carrega a aColsAEC referente ao produto da linha atual
		dbSelectArea(cAlias)
		dbSetOrder(1)
 		For nZ := 1 to len(aDatas)
			// faz a montagem de uma linha em branco no aColsAEC
			aAdd(aColsAEC ,Array(Len(aHeadAEC)+1))
			
			If !Empty(crecNew) .AND. dbSeek(xFilial("AEC")+cProjeto+cRevisa+crecNew+dtos(aDatas[nZ]))
				For nY := 1 to Len(aHeadAEC)
					If (aHeadAEC[nY ,10] != "V")
						aColsAEC[Len(aColsAEC) ,nY] := FieldGet(FieldPos(aHeadAEC[nY ,2]))
					Else
						aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
					EndIf
				Next nY
				aAdd( aRecAEC ,(cAlias)->(Recno()))
			Else
				For nY := 1 to Len(aHeadAEC)
					aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
					If AllTrim(aHeadAEC[nY,2]) == "AEC_DATREF"
						aColsAEC[Len(aColsAEC) ,nY] := aDatas[nZ]
					EndIf
				Next nY
			EndIf
			aColsAEC[Len(aColsAEC) ,Len(aHeadAEC)+1] := .F.
		Next nZ	

		If Empty(aColsAEC)
			// faz a montagem de uma linha em branco no aColsAEC
			aAdd(aColsAEC ,Array(Len(aHeadAEC)+1))
			For ny := 1 to Len(aHeadAEC)
				aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeadAEC[nY ,2])
			Next ny
			aColsAEC[Len(aColsAEC) ,Len(aHeadAEC)+1] := .F.
		EndIf
		
    EndIf
    
	RestArea(aAreaAEC)
	RestArea(aArea)
	
Return .T.
            
Function AEESCampOK(lProdut)
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local nPosAtual := 0
Local nX        := 0
Local nAECPosDat  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_DATREF"})
Local nAECPosCust := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nAECPosPerc := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nAEEPProd   := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_PRODUT"})
Local nAEEPDatSTD := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local nAEEPCustD  := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_CUSTD"})
Local cReadVar    := ReadVar()
Local dReferencia := stod("")
Local lOk := .T.     
Local nPerc := 0    
Local nCusto := 0

Local oGD
Local oSay

	If ALTERA
		If lProdut
		 	oGD	:= oGDAEEPrd
		 	oGDAEC := oGDAECPrd
		 	oSay := oSayProd
		 	cCampo := "AEE_PRODUT"
		 	uValueVar := &("M->"+cReadVar)
		Else
		 	oGD	:= oGDAECRec
		 	oGDAEC := oGDAECRec
		 	oSay := oSayRec
		 	cCampo := "AEE_RECURS"
		 	uValueVar := &("M->"+cReadVar)
		EndIf
		
		nAECPosDat  := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_DATREF"})
		nAECPosCust := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
		nAECPosPerc := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
		nAEEPProd   := aScan(oGD:aHeader,{|x|AllTrim(x[2])==cCampo})
		nAEEPDatSTD := aScan(oGD:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
		nAEEPCustD  := aScan(oGD:aHeader,{|x|AllTrim(x[2])=="AEE_CUSTD"})
		 	
		If !oGD:aCols[oGD:nAt ,Len(oGD:aHeader)+1] 
			If cCampo $ cReadVar .AND. !Empty(uValueVar)
				nPosAtual := oGD:nAt
				For nX := 1 To len(oGD:aCols)
					If !oGD:aCols[nX ,Len(oGD:aHeader)+1] .AND. nPosAtual != nX .AND. oGD:aCols[nX ,1] == uValueVar
						MsgAlert(iIf(lProdut,"O produto já informado!","O recurso já informado!"))
						lOk := .F.
					EndIf
				Next nX

				If lOk
					If lProdut
						dbSelectArea("SB1")
						dbSetOrder(1)
						If dbSeek(xFilial("SB1")+uValueVar)
						    
							dReferencia := iIf(Empty(RetFldProd(SB1->B1_COD,"B1_UCALSTD")) ,dDatabase ,RetFldProd(SB1->B1_COD,"B1_UCALSTD"))
							
							oGD:aCols[oGD:nAt ,nAEEPDatSTD] := dReferencia
							oGD:aCols[oGD:nAt ,03] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
							
							oSay:cTitle := "Produto: " + uValueVar
							oSay:refresh()
							For nX := 1 To len(oGDAEC:aCols)
								If DTOS(oGDAEC:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(AF8->AF8_TPPERI ,dReferencia))
									oGDAEC:aCols[nX ,nAECPosCust] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
									oGDAEC:nAt := nX
									nPerc := oGDAEC:aCols[nX ,nAECPosPerc] 
									nCusto := oGDAEC:aCols[nX ,nAECPosCust] 
									Exit
								EndIf
							Next nX
							ReCalPer(oGDAEC ,nPerc ,nCusto)
							oGD:oBrowse:refresh()
						EndIf
					Else
						dbSelectArea("AE8")
						dbSetOrder(1)
						If dbSeek(xFilial("AE8")+uValueVar)
							oGD:aCols[oGD:nAt,2] := dDatabase
							oGD:aCols[oGD:nAt,3] := AE8->AE8_VALOR
							oSay:cTitle := "Recurso: " + uValueVar
							oSay:Refresh()
							For nX := 1 To len(oGDAEC:aCols)
								If DTOS(oGDAEC:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(AF8->AF8_TPPERI ,dDatabase))
									oGDAEC:aCols[nX ,nAECPosCust] := AE8->AE8_VALOR
									oGDAEC:nAt := nX
									nPerc := oGDAEC:aCols[nX ,nAECPosPerc] 
									nCusto := oGDAEC:aCols[nX ,nAECPosCust] 
									Exit
								EndIf
							Next nX
							ReCalPer(oGDAEC ,nPerc ,nCusto)
							oGDAEC:oBrowse:refresh()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
			
		If "AEE_CUSTD" $ cReadVar
			If !Empty(oGD:aCols[oGD:nAt ,nAEEPProd])
				For nX := 1 To len(oGD:aCols)
					If DTOS(oGDAEC:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(AF8->AF8_TPPERI ,oGD:aCols[oGD:nAt ,nAEEPDatSTD]))
						oGDAEC:aCols[nX ,nAECPosCust] := &(cReadVar)
						oGDAEC:nAt := nX
						nPerc := oGDAEC:aCols[nX ,nAECPosPerc] 
						nCusto := oGDAEC:aCols[nX ,nAECPosCust] 
						Exit
					EndIf
				Next nX
				ReCalPer(oGDAEC ,nPerc ,nCusto)
				oGDAEC:oBrowse:refresh()
			EndIf
		EndIf
		
	EndIf

RestArea(aAreaSB1)
RestArea(aArea)

Return lOk

Static Function GDAEELinOK( oGDAEEPrd )
Local lOk := .T.
Local nPosCodPrd := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_PRODUT"})
Local nPosDatCot := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local nPosCustCo := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_CUSTCO"})

	If Empty(oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nPosCodPrd])
		MsgAlert("Produto em branco")
		lOk := .F.
	EndIf
	
	If lOk .AND. Empty(oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nPosDatCot])
		MsgAlert("Data do Custo Standard não foi informado")
		lOk := .F.
	EndIf

Return lOk

Static Function GDAEERLinOK( oGDAEErec )
Local lOk := .T.
Local nPosCodrec := aScan(oGDAEErec:aHeader,{|x|AllTrim(x[2])=="AEE_RECURS"})
Local nPosDatCot := aScan(oGDAEErec:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local nPosCustCo := aScan(oGDAEErec:aHeader,{|x|AllTrim(x[2])=="AEE_CUSTCO"})

	If Empty(oGDAEEREC:aCols[oGDAEEREC:nAt ,nPosCODREC])
		MsgAlert("Recurso em branco")
		lOk := .F.
	EndIf
	
	If lOk .AND. Empty(oGDAEErec:aCols[oGDAEErec:nAt ,nPosDatCot])
		MsgAlert("Data do Custo Standard não foi informado")
		lOk := .F.
	EndIf

Return lOk


Function AECSCampOK()
Local nPosAtual := 0
Local nX        := 0
Local nPosPerc  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nPosCust  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nCusto    := 0
Local lRet      := .T.
Local cReadVar  := ""
Local nGDPos    := oGDAECPrd:nAt

	cReadVar := ReadVar()

	If ALTERA
	
		If "AEC_PERC" $ cReadVar
				
			If !(oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosPerc] == M->AEC_PERC)
				If M->AEC_PERC <>0
					If oGDAECPrd:nAt > 1
						nCusto   := oGDAECPrd:aCols[oGDAECPrd:nAt-1 ,nPosCust]*(1+(M->AEC_PERC/100))
					EndIf
				Else
					If oGDAECPrd:nAt > 1
						nCusto   := oGDAECPrd:aCols[oGDAECPrd:nAt-1 ,nPosCust]
					Else
						nCusto   := oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosCust]
					EndIf
				EndIf
				oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGDAECPrd ,M->AEC_PERC ,nCusto)
				
			EndIf
		EndIf
		
		If "AEC_CUSTD" $ cReadVar
		
			If !(oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosCust] == M->AEC_CUSTD)
				oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosPerc] := 0
				nCusto   := M->AEC_CUSTD
				oGDAECPrd:aCols[oGDAECPrd:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGDAECPrd ,0 ,nCusto)
				
			EndIf
		EndIf
	EndIf

Return lRet 

Static Function ReCalPer(oGDAEC ,nPerc ,nCusto)
Local nX := 0
Local nPosPerc  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nPosCust  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})

	For nX := oGDAEC:nAt+1 To len(oGDAEC:aCols)
		nCusto := nCusto * (1+(oGDAEC:aCols[nX ,nPosPerc]/100))
		oGDAEC:aCols[nX ,nPosCust] := nCusto
	Next nX
	
Return .T. 

Static Function GDAECLinOK( oGDAECPrd )
Local lOk := .T.

Return lOk

Static Function GDAECRLinOK( oGDAECPrd )
Local lOk := .T.
Return lOk

Static Function GDAECTudoOK( oGDAECPrd )
Local nX       := 0
Local lOk      := .T.

	For nX := 1 to Len(oGDAECPrd:aCols)
		If !(oGDAECPrd:aCols[nX ,Len(oGDAECPrd:aHeader)+1])
			If !GDAECLinOK( oGDAECPrd )
				lOk := .F.
				Exit
			EndIf
		EndIf
	Next nX

Return lOk

Static Function GDAECRTudoOK( oGDAECrec )
Local nX       := 0
Local lOk      := .T.

	For nX := 1 to Len(oGDAECrec:aCols)
		If !(oGDAECrec:aCols[nX ,Len(oGDAECrec:aHeader)+1])
			If !GDAECrLinOK( oGDAECrec )
				lOk := .F.
				Exit
			EndIf
		EndIf
	Next nX

Return lOk

Static Function PMS800Grava(cAliasPRD ,aHeadAEC ,aColsAEC ,aHeadAEEPrd ,aColsAEEPrd ,cAliasRec ,aHeadAEERec ,aColsAEERec)
Local nX       := 0
Local nY       := 0
Local aDatas   := {}
Local aNewDatas   := {}
Local aAreaAEE := AEE->(GetArea())
Local aAreaAEC := AEC->(GetArea())
Local aArea    := GetArea()
Local lNew     := .T.
Local nAEEProdut := 0
Local nAEERecurs := 0
Local nCnt       := 0

	// Carrega as datas do intervalo de periodo
	aDatas := PmsPeriod(AF8->AF8_TPPERI ,AF8->AF8_INIPER ,AF8->AF8_FIMPER)
	For nY := 1 To Len(aDatas)
		If aDatas[nY] >= AF8->AF8_ULMES 
 			aAdd(aNewDatas ,aDatas[nY])
 		EndIf
 	Next nY
 	aDatas := aNewDatas
	
	nAEEProdut := aScan( aHeadAEEPrd ,{|x| x[2] == "AEE_PRODUT"})
	nAEERecurs := aScan( aHeadAEERec ,{|x| x[2] == "AEE_RECURS"})
	For nY := 1 to len(aColsAEEPrd)
		// se não foi excluido 
		If !aColsAEEPrd[nY ,Len(aHeadAEEPrd)+1] .AND. !Empty(aColsAEEPrd[nY ,nAEEProdut]) 
			dbSelectArea("AEE")
			dbSetOrder(1)
			lNew := !MsSeek(xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
			RecLock("AEE" ,lNew)
			For nX := 1 TO Len(aHeadAEEPrd)
				If ( aHeadAEEPrd[nX ,10] != "V" )
					AEE->(FieldPut(FieldPos(aHeadAEEPrd[nX ,2]),aColsAEEPrd[nY ,nX]))
				EndIf
			Next nX
			AEE->AEE_REVISA := AJB->AJB_REVISA
			AEE->AEE_PROJET := AJB->AJB_PROJET
			AEE->AEE_FILIAL := xFilial("AEE")
			MsUnLock()
			
			aAECRecNo := {}
				
			For nCnt := 1 To len(aDatas)
				// Busca na tabela temporaria
				dbSelectArea(cAliasPRD)
				dbSetOrder(1)
				If dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]+dtos(aDatas[nCnt]))
					dbSelectArea("AEC")
					dbSetOrder(1)
					lNew := !MsSeek(xFilial("AEC")+(cAliasPRD)->(AEC_PROJET+AEC_REVISA+AEC_PRODUT+AEC_RECURS+dtos(AEC_DATREF)))
					RecLock("AEC" ,lNew)
					For nX := 1 TO (cAliasPRD)->(fCount())
						AEC->(FieldPut(FieldPos((cAliasPRD)->(FieldName(nX))) ,(cAliasPRD)->(FieldGet(FieldPos(FieldName(nX))))))
					Next nX
					AEC->AEC_REVISA := AJB->AJB_REVISA
					AEC->AEC_PROJET := AJB->AJB_PROJET
					AEC->AEC_FILIAL := xFilial("AEC")
					MsUnlock()
					aAdd(aAECRecNo ,AEC->(Recno()))
		 		EndIf
		 	Next nCnt
			 	
		 	//
		 	// apaga os registros da tabela AEC que não são mais utilizados
		 	//
			dbSelectArea("AEC")
			dbSetOrder(1)
			dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
			While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL_+AEC_PROJET+AEC_REVISA+AEC_PRODUT)==xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]
			 	If !Empty(AEC->AEC_PRODUT) .and. (aScan( aAECRecNo ,{|x| x == AEC->(Recno())}) == 0)
			 		RecLock("AEC",.F.)
			 		dbDelete()
			 		MsUnLock()
			 	EndIf
			 	dbSkip()
			EndDo
			
		Else 	
			If !Empty(aColsAEEPrd[nY ,nAEEProdut])
				dbSelectArea("AEC")
				dbSetOrder(1)
				dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
				While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+AEC_PRODUT)== xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]
					RecLock("AEC" ,.F.)
						dbDelete()
					msUnlock()
					dbSkip()
				EndDo
				dbSelectArea("AEE")
				dbSetOrder(1)
				if MsSeek(xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
					RecLock("AEE" ,.F.)
						dbDelete()
					MsUnlock()
				EndIf
			EndIf
		EndIf
			
	Next nY
	
	For nY := 1 to len(aColsAEERec)
		// se não foi excluido 
		If !aColsAEERec[nY ,Len(aHeadAEErec)+1] .AND. !Empty(aColsAEErec[nY ,nAEERecurs])
			dbSelectArea("AEE")
			dbSetOrder(2)
			lNew := !MsSeek(xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEErec[nY ,nAEERecurs])
			RecLock("AEE" ,lNew)
			For nX := 1 TO Len(aHeadAEErec)
				If ( aHeadAEErec[nX ,10] != "V" )
					AEE->(FieldPut(FieldPos(aHeadAEErec[nX ,2]),aColsAEErec[nY ,nX]))
				EndIf
			Next nX
			AEE->AEE_REVISA := AJB->AJB_REVISA
			AEE->AEE_PROJET := AJB->AJB_PROJET
			AEE->AEE_FILIAL := xFilial("AEE")
			MsUnLock()
			
			aAECRecNo := {}
				
			For nCnt := 1 To len(aDatas)
				// Busca na tabela temporaria
				dbSelectArea(cAliasRec)
				dbSetOrder(1)
				If dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEErec[nY ,nAEERecurs]+dtos(aDatas[nCnt]))
					dbSelectArea("AEC")
					dbSetOrder(2)
					lNew := !MsSeek(xFilial("AEC")+(cAliasrec)->(AEC_PROJET+AEC_REVISA+AEC_RECURS+space(tamsx3("AEC_PRODUT")[1])+dtos(AEC_DATREF)))
					RecLock("AEC" ,lNew)
					For nX := 1 TO (cAliasrec)->(fCount())
						AEC->(FieldPut(FieldPos((cAliasrec)->(FieldName(nX))) ,(cAliasrec)->(FieldGet(FieldPos(FieldName(nX))))))
					Next nX
					AEC->AEC_REVISA := AJB->AJB_REVISA
					AEC->AEC_PROJET := AJB->AJB_PROJET
					AEC->AEC_FILIAL := xFilial("AEC")
					MsUnlock()
					aAdd(aAECRecNo ,AEC->(Recno()))
		 		EndIf
		 	Next nCnt
			 	
		 	//
		 	// apaga os registros da tabela AEC que não são mais utilizados
		 	//
			dbSelectArea("AEC")
			dbSetOrder(2)
			dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEErec[nY ,nAEERecurs])
			While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL_+AEC_PROJET+AEC_REVISA+AEC_RECURS)==xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEERec[nY ,nAEERecurs]
			 	If !Empty(AEC->AEC_RECURS) .and. (aScan( aAECRecNo ,{|x| x == AEC->(Recno())}) == 0)
			 		RecLock("AEC",.F.)
			 		dbDelete()
			 		MsUnLock()
			 	EndIf
			 	dbSkip()
			EndDo
			
		Else 	
			If !Empty(aColsAEEREC[nY ,nAEERecurs])
				dbSelectArea("AEC")
				dbSetOrder(2)
				dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEREC[nY ,nAEERecurs])
				While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+AEC_RECURS)== xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEREC[nY ,nAEERecurs]
					RecLock("AEC" ,.F.)
						dbDelete()
					msUnlock()
					dbSkip()
				EndDo
				dbSelectArea("AEE")
				dbSetOrder(2)
				if MsSeek(xFilial("AEE")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEEREC[nY ,nAEERecurs])
					RecLock("AEE" ,.F.)
						dbDelete()
					MsUnlock()
				EndIf
			EndIf
		EndIf
			
	Next nY
	
	RestArea(aAreaAEE)
	RestArea(aAreaAEC)
	RestArea(aArea)
	
Return .T. 


Static Function DataSeek( cTipPer ,dData )
Local dRet := stod("")

	Do Case
		Case cTipPer == "2"
			dRet := dData
			If DOW(dData)<>1
				dIni -= DOW(dData)-1
			EndIf
		Case cTipPer == "3"
			dRet	:= CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
		Case cTipPer == "4"
			dRet	:= CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
		OtherWise 
			dRet	:= dData
	EndCase

Return dRet

Function SAEEFieldOK(oGDAEC ,oGDAEE ,oSay)
Local aArea    := GetArea()
Local aAreaAE8 := AE8->(GetArea())
Local aAreaSB1 := AE8->(GetArea())
Local nPosAtual := 0
Local nX        := 0
Local nAECPosDat  := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_DATREF"})
Local nAECPosCust := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nAECPosPerc := aScan(oGDAEC:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nAEEPDatSTD := aScan(oGDAEE:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local nAEEPCustD  := aScan(oGDAEE:aHeader,{|x|AllTrim(x[2])=="AEE_CUSTD"})
Local nAEEPos    := 0
Local cReadVar  := ReadVar()
Local lOk := .T.
Local lProdut := .T.
Local cCampo := "AEE_PRODUT"    
Local nPerc := 0  
Local nCusto := 0

	If (nAEEPos := aScan(oGDAEE:aHeader,{|x|AllTrim(x[2])=="AEE_PRODUT"}))==0
		nAEEPos := aScan(oGDAEE:aHeader,{|x|AllTrim(x[2])=="AEE_RECURS"})
		lProdut := .F.
		cCampo := "AEE_RECURS"
	EndIF

	If ALTERA
		// SE FOR RECURSO
		If !Empty(&(cReadVar))
			If cCampo $ cReadVar
				nPosAtual := oGDAEE:nAt
				For nX := 1 To len(oGDAEE:aCols)
					If !oGDAEE:aCols[nX ,Len(oGDAEE:aHeader)+1] .AND. nPosAtual != nX .AND. oGDAEE:aCols[nX ,1] == M->&(cCampo)
						If lProdut
							MsgAlert("O Produto já foi informado!")
						Else						
							MsgAlert("O Recurso já foi informado!")
						EndIF
						lOk := .F.
					EndIf
				Next nX
				If lOk
					If lProdut
						dbSelectArea("SB1")
						dbSetOrder(1)
						If dbSeek(xFilial("SB1")+M->&(cCampo))
							oGDAEE:aCols[oGDAEE:nAt,2] := iIf(Empty(RetFldProd(SB1->B1_COD,"B1_UCALSTD")) ,dDatabase ,RetFldProd(SB1->B1_COD,"B1_UCALSTD"))
							oGDAEE:aCols[oGDAEE:nAt,3] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
							oSay:cTitle := "Produto: " + M->&(cCampo)
						EndIf
					Else
						dbSelectArea("AE8")
						dbSetOrder(1)
						If dbSeek(xFilial("AE8")+M->&(cCampo))
							oGDAEE:aCols[oGDAEE:nAt,2] := dDatabase
							oGDAEE:aCols[oGDAEE:nAt,3] := AE8->AE8_VALOR
							oSay:cTitle := "Recurso: " +M->&(cCampo)
						EndIf
					EndIf
					
					oSay:Refresh()
					
					For nX := 1 To len(oGDAEC:aCols)
						If DTOS(oGDAEC:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(AF8->AF8_TPPERI ,dDatabase))
							oGDAEC:aCols[nX ,nAECPosCust] := AE8->AE8_VALOR
							oGDAEC:nAt := nX
							nPerc := oGDAEC:aCols[nX ,nAECPosPerc] 
							nCusto := oGDAEC:aCols[nX ,nAECPosCust] 
							Exit
						EndIf
					Next nX
					ReCalPer(oGDAEC ,nPerc ,nCusto)
					oGDAEC:oBrowse:refresh()
				EndIf
			EndIf
			
		EndIf
		
		If "AEE_CUSTD" $ cReadVar
			For nX := 1 To len(oGDAEC:aCols)
				If DTOS(oGDAEC:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(AF8->AF8_TPPERI ,oGDAEE:aCols[oGDAEE:nAt ,nAEEPDatSTD]))
					oGDAEC:aCols[nX ,nAECPosCust] := &(cReadVar)
					oGDAEC:nAt := nX
					nPerc := oGDAEC:aCols[nX ,nAECPosPerc] 
					nCusto := oGDAEC:aCols[nX ,nAECPosCust] 
					Exit
				EndIf
			Next nX
			ReCalPer(oGDAEC ,nPerc ,nCusto)
			oGDAEC:oBrowse:refresh()
		EndIf
		
	EndIf

RestArea(aAreaAE8)
RestArea(aArea)

Return lOk

Function SAECFieldOK(oGD)
Local nPosAtual := 0
Local nX        := 0
Local nPosPerc  := 0
Local nPosCust  := 0
Local nCusto    := 0
Local lRet      := .T.
Local cReadVar  := ""
Local nGDPos    := 0

	nPosPerc  := aScan(oGD:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
	nPosCust  := aScan(oGD:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
	nGDPos    := oGD:nAt

	cReadVar := ReadVar()

	If INCLUI .OR. ALTERA
	
		If "AEC_PERC" $ cReadVar
				
			If !(oGD:aCols[oGD:nAt ,nPosPerc] == M->AEC_PERC)
				If M->AEC_PERC <>0
					If oGD:nAt > 1
						nCusto   := oGD:aCols[oGD:nAt-1 ,nPosCust]*(1+(M->AEC_PERC/100))
					EndIf
				Else
					If oGD:nAt > 1
						nCusto   := oGD:aCols[oGD:nAt-1 ,nPosCust]
					Else
						nCusto   := oGD:aCols[oGD:nAt ,nPosCust]
					EndIf
				EndIf
				oGD:aCols[oGD:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGD ,M->AEC_PERC ,nCusto)
				
			EndIf
		EndIf
		
		If "AEC_CUSTD" $ cReadVar
		
			If !(oGD:aCols[oGD:nAt ,nPosCust] == M->AEC_CUSTD)
				oGD:aCols[oGD:nAt ,nPosPerc] := 0
				nCusto   := M->AEC_CUSTD
				oGD:aCols[oGD:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGD ,0 ,nCusto)
				
			EndIf
		EndIf
	EndIf

Return lRet 

/*******************************************************
*******************************************************/
User Function qga004()

	dbSelectArea("AF8")
	dbSetorder(1)
	If dbSeek(xfilial()+AJB->AJB_PROJET)

		If Aviso("Atualiza do Cadastro" ,"Esta rotina tem a finalidade de atualizar o custo dos produtos/recursos do projeto na planilha de cotação."+CRLF ;
		         +"Será efetuado na simulação:"+AJB->AJB_PROJET+" revisão:"+AJB->AJB_REVISA+" a partir da data: " +dtoc(AF8->AF8_ULMES)+ "."+CRLF ;
		         +"Deseja continuar o processo?";
		         ,{"SIM" ,"NÃO"}, 3) == 1
	
			UpdPlnCot( .T. ,cAliasPRD ,oGDAEEPrd ,oGDAECPrd)
			UpdPlnCot( .F. ,cAliasREC ,oGDAEERec ,oGDAECRec)
		EndIf
	EndIf
		
Return .T.		

/*******************************************************
*******************************************************/
Static Function UpdPlnCot( lProdut ,cAlias ,oGDAEE ,oGDAEC )
Local nCnt       := 0
Local nAEEChave  := 0
Local nCntField  := 0
Local nCntAEE    := 0
Local nCntAEC    := 0
Local nX         := 0
Local nCusto     := 0
Local aDatas     := {}
Local aNewDatas  := {}
Local nY         := 0
Local nPosLin    := oGDAEE:nAt
Local aHeaderAEE := oGDAEE:aHeader
Local aColsAEE   := oGDAEE:aCols
Local aHeaderAEC := oGDAEC:aHeader
Local aColsAEC   := oGDAEC:aCols
Local nCntPer := 0

	// Carrega as datas do intervalo de periodo
	aDatas := PmsPeriod(AF8->AF8_TPPERI ,AF8->AF8_INIPER ,AF8->AF8_FIMPER)
	For nY := 1 To Len(aDatas)
		If aDatas[nY] >= AF8->AF8_ULMES 
 			aAdd(aNewDatas ,aDatas[nY])
		EndIf
 	Next nY
 	aDatas := aNewDatas

	nAEEPDatSTD := aScan(aHeaderAEE ,{|x|AllTrim(x[2])=="AEE_DATSTD"})
	nAEEPCustD  := aScan(aHeaderAEE ,{|x|AllTrim(x[2])=="AEE_CUSTD"})
	
	If lProdut
		cAECField := "AEC_PRODUT"
		nAEEChave := aScan(aHeaderAEE ,{|x| x[2] == "AEE_PRODUT"})
		nAECChave := aScan(aHeaderAEC ,{|x| x[2] == "AEC_PRODUT"})
	Else
		cAECField := "AEC_RECURS"
		nAEEChave := aScan(aHeaderAEE ,{|x| x[2] == "AEE_RECURS"})
		nAECChave := aScan(aHeaderAEC ,{|x| x[2] == "AEC_RECURS"})
	EndIF

	For nCntAEE := 1 to len(aColsAEE)
		// se não estiver em branco
		If !Empty(aColsAEE[nCntAEE ,nAEEChave]) 
			If lProdut
				cRecurso := space(TamSX3("AEC_PRODUT")[1])
				cProduto := aColsAEE[nCntAEE ,nAEEChave]
				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(xFilial("SB1")+aColsAEE[nCntAEE ,nAEEChave])
					nCusto := RetFldProd(SB1->B1_COD,"B1_CUSTD")
				EndIf
		
			Else
				cRecurso := aColsAEE[nCntAEE ,nAEEChave]
				cProduto := space(TamSX3("B1_COD")[1])
				dbSelectArea("AE8")
				dbSetOrder(1)
				If dbSeek(xFilial("AE8")+aColsAEE[nCntAEE ,nAEEChave])
					nCusto := AE8->AE8_VALOR
				EndIf
			EndIf
			
			aColsAEE[nCntAEE ,nAEEPDatSTD] := AF8->AF8_ULMES
			aColsAEE[nCntAEE ,nAEEPCustD] := nCusto
                
			dbSelectArea(cAlias)
			dbSetOrder(1)
			dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEE[nCntAEE ,nAEEChave])
			While !EOF() .AND. (cAlias)->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+&(cAECField))==xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEE[nCntAEE ,nAEEChave]
				If aScan(aDatas ,{|x|x==(cAlias)->AEC_DATREF}) >0
					Reclock(cAlias ,.F.)
					(cAlias)->AEC_CUSTD := nCusto
					(cAlias)->AEC_PERC  := 0
					MsUnLock()
				EndIf
				dbSkip()
			EndDo
			
			If nCntAEe == nPosLin
				aColsAEC := {}
				// Carrega a aColsAEC referente ao produto da linha atual
				dbSelectArea(cAlias)
				dbSetOrder(1)
		 		For nCntPer := 1 to len(aDatas)
					// faz a montagem de uma linha em branco no aColsAEC
					aAdd(aColsAEC ,Array(Len(aHeaderAEC)+1))
					
					If dbSeek(xFilial("AEC")+AJB->(AJB_PROJET+AJB_REVISA)+aColsAEE[nCntAEE ,nAEEChave]+dtos(aDatas[nCntPer]))
						For nY := 1 to Len(aHeaderAEC)
							If (aHeaderAEC[nY ,10] != "V")
								aColsAEC[Len(aColsAEC) ,nY] := FieldGet(FieldPos(aHeaderAEC[nY ,2]))
							Else
								aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeaderAEC[nY ,2])
							EndIf
						Next nY
					Else
						For nY := 1 to Len(aHeaderAEC)
							aColsAEC[Len(aColsAEC) ,nY] := CriaVar(aHeaderAEC[nY ,2])
							If AllTrim(aHeaderAEC[nY,2]) == "AEC_DATREF"
								aColsAEC[Len(aColsAEC) ,nY] := aDatas[nCntPer]
							EndIf
						Next nY
					EndIf
					aColsAEC[Len(aColsAEC) ,Len(aHeaderAEC)+1] := .F.
				Next nCntPer
							
			EndIf
			
		EndIf
		
	Next nCnt
	
	oGDAEE:aCols := aColsAEE
	oGDAEC:aCols := aColsAEC
	oGDAEE:oBrowse:refresh()
	oGDAEC:oBrowse:refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³QGA005   ³ Autor ³ Reynaldo Miyashita    ³ Data ³04/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importa os produtos e recursos do projeto para a planilha  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function QGA005()
Local aArea     := GetArea()
Local cMensagem := ""
                     
	dbSelectArea("AF8")
	dbSetorder(1)
	If dbSeek(xfilial()+AJB->AJB_PROJET)
		cMensagem := "Esta rotina tem a finalizade de efetuar a importação de produtos/recursos " + CRLF
		cMensagem += "utilizados na simulacao corrente para a planilha de cotação" + CRLF
	
		If Aviso("Importação de produtos/recursos" ,cMensagem ,{"Continuar", "Cancelar"}, 3) == 1
		
			ImpPlnCot(AJB->AJB_PROJET ,AJB->AJB_REVISA ,.T. ,cAliasPRD ,oGDAEEPrd ,oGDAECPrd)
			ImpPlnCot(AJB->AJB_PROJET ,AJB->AJB_REVISA ,.F. ,cAliasREC ,oGDAEERec ,oGDAECRec)
		
		EndIf
	EndIF	
RestArea(aArea)

Return .T.

/******************************************************************************
*******************************************************************************/
Static Function ImpPlnCot( cProjeto ,cRevisa ,lProdut ,cAlias ,oGDAEE ,oGDAEC )
Local nCnt       := 0
Local nAEEChave  := 0
Local nCntField  := 0
Local nCntAEE    := 0
Local nCntAEC    := 0
Local nX         := 0
Local nCusto     := 0
Local aDatas     := {}
Local aNewDatas  := {}
Local nY         := 0
Local nPosLin    := oGDAEE:nAt
Local aHeaderAEE := oGDAEE:aHeader
Local aColsAEE   := oGDAEE:aCols
Local aHeaderAEC := oGDAEC:aHeader
Local aColsAEC   := oGDAEC:aCols
Local nCntPer := 0

	// Carrega as datas do intervalo de periodo
	aDatas := PmsPeriod(AF8->AF8_TPPERI ,AF8->AF8_INIPER ,AF8->AF8_FIMPER)
	For nY := 1 To Len(aDatas)
		If aDatas[nY] >= AF8->AF8_ULMES 
 			aAdd(aNewDatas ,aDatas[nY])
		EndIf
 	Next nY
 	aDatas := aNewDatas

	If lProdut
		cAECField := "AEC_PRODUT"
		nAEEChave := aScan(aHeaderAEE ,{|x| x[2] == "AEE_PRODUT"})
		nAECChave := aScan(aHeaderAEC ,{|x| x[2] == "AEC_PRODUT"})
	Else
		cAECField := "AEC_RECURS"
		nAEEChave := aScan(aHeaderAEE ,{|x| x[2] == "AEE_RECURS"})
		nAECChave := aScan(aHeaderAEC ,{|x| x[2] == "AEC_RECURS"})
	EndIF

	dbSelectArea("AFA")
	dbSetOrder(2)
	dbSeek(xFilial("AFA")+cProjeto+cRevisa)
	While AFA->(!Eof()) .AND. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA) == xFilial("AFA")+cProjeto+cRevisa

		If lProdut 
			If Empty(AFA->AFA_RECURS)
				//
				// inclui o produto na planilha de cotacao, caso nao existir
				//
				If aScan(aColsAEE ,{|x|x[nAEEChave]== AFA->AFA_PRODUT})==0
					// cadastro de produtos
					dbSelectArea("SB1")
					dbSetOrder(1)
					If dbSeek(xFilial("SB1")+AFA->AFA_PRODUT)
						// faz a montagem de uma linha em branco no aColsAEE
						aAdd(aColsAEE ,Array(Len(aHeaderAEE)+1))
						For nCntAEE := 1 to Len(aHeaderAEE)
							Do Case
								Case "AEE_CUSTD"  $ aHeaderAEE[nCntAEE ,2]
									aColsAEE[Len(aColsAEE) ,nCntAEE] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
								Case "AEE_DATSTD" $ aHeaderAEE[nCntAEE ,2]
									aColsAEE[Len(aColsAEE) ,nCntAEE] := iIf(Empty(RetFldProd(SB1->B1_COD,"B1_UCALSTD")) ,dDatabase ,RetFldProd(SB1->B1_COD,"B1_UCALSTD"))
								Case "AEE_PRODUT" $ aHeaderAEE[nCntAEE ,2]
									aColsAEE[Len(aColsAEE) ,nCntAEE] := SB1->B1_COD
								Otherwise
									If (aHeaderAEE[nCntAEE ,10] == "V")
										aColsAEE[Len(aColsAEE) ,nCntAEE] := CriaVar(aHeaderAEE[nCntAEE ,2])
									EndIf
							EndCase
						Next nCntAEE
						aColsAEE[Len(aColsAEE) ,Len(aHeaderAEE)+1] := .F.
						
						ImpAECSim(cProjeto ,cRevisa ,AFA->AFA_PRODUT ,"" ,iIf(Empty(RetFldProd(SB1->B1_COD,"B1_UCALSTD")) ,dDatabase ,RetFldProd(SB1->B1_COD,"B1_UCALSTD")) ,RetFldProd(SB1->B1_COD,"B1_CUSTD") ,cAlias ,aDatas )
						
					EndIf
				EndIf
			EndIf
		Else
			If !Empty(AFA->AFA_RECURS)
				//
				// inclui o recursos na planilha de cotacao, caso nao existir
				//
				If aScan(aColsAEE ,{|x|x[nAEEChave]== AFA->AFA_RECURS}) ==0
					// cadastro de recursos
					dbSelectArea("AE8")
					dbSetOrder(1)
					If dbSeek(xFilial("AE8")+AFA->AFA_RECURS)
						// faz a montagem de uma linha em branco no aColsAEE
						aAdd(aColsAEE ,Array(Len(aHeaderAEE)+1))
						For nCntAEE := 1 to Len(aHeaderAEE)
							If (aHeaderAEE[nCntAEE ,10] != "V")
								aColsAEE[Len(aColsAEE) ,nCntAEE] := FieldGet(FieldPos(aHeaderAEE[nCntAEE ,2]))
							Else
								Do Case
									Case aHeaderAEE[nCntAEE ,2] == "AEE_CUSTD"
										aColsAEE[Len(aColsAEE) ,nCntAEE] := AE8->AE8_VALOR
									Case aHeaderAEE[nCntAEE ,2] == "AEE_DATSTD"
										aColsAEE[Len(aColsAEE) ,nCntAEE] := dDatabase
									Case aHeaderAEE[nCntAEE ,2] == "AEE_RECURS"
										aColsAEE[Len(aColsAEE) ,nCntAEE] := AE8->AE8_RECURS
									Otherwise
										aColsAEE[Len(aColsAEE) ,nCntAEE] := CriaVar(aHeaderAEE[nCntAEE ,2])
								EndCase
							EndIf   
						Next nCntAEE
						aColsAEE[Len(aColsAEE) ,Len(aHeaderAEE)+1] := .F.
						
						ImpAECSim(cProjeto ,cRevisa ,"" ,AFA->AFA_RECURS ,dDatabase ,ae8->AE8_VALOR ,cAlias ,aDatas)
					EndIf
				EndIf
			EndIF
		EndIf
		
		dbSelectArea("AFA")
		dbSkip()
	EndDo
		
	oGDAEE:aCols := aColsAEE
	oGDAEC:aCols := aColsAEC
	oGDAEE:oBrowse:refresh()
	oGDAEC:oBrowse:refresh()
	
Return .T.

/******************************************************************************
*******************************************************************************/
Static Function ImpAECSim(cProjeto ,cRevisa ,cProduto ,cRecurso ,dStandard ,nCustD ,cAlias ,aDatas)
Local aArea  := GetArea()
Local nPer   := 0
Local nField := 0

DEFAULT cRecurso := ""
DEFAULT cProduto := ""

	dbSelectArea(cAlias)
	For nPer := 1 to Len(aDatas)
		RegToMemory("AEC" ,.T.)
		RecLock(cAlias ,.T.)
		For nField := 1 TO (cAlias)->(fCount())
			FieldPut(nField ,M->&(FieldName(nField)))
		Next nField
		
		(cAlias)->AEC_CUSTD  := nCustD
		(cAlias)->AEC_PERC   := 0
		
		(cAlias)->AEC_DATREF := aDatas[nPer]
		If Empty(cRecurso)
			(cAlias)->AEC_PRODUT := cProduto
		Else
			(cAlias)->AEC_RECURS := cRecurso
		EndIf
		(cAlias)->AEC_REVISA := cRevisa
		(cAlias)->AEC_PROJET := cProjeto
		(cAlias)->AEC_FILIAL := xFilial("AEC")
		MsUnLock()
	Next nPer

RestArea(aArea)
Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

