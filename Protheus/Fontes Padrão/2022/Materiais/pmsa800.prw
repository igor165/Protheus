#INCLUDE "PROTHEUS.CH" 
#INCLUDE "PMSA800.CH"

Static _oPMSA8001
Static _oPMSA8002

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMAS800   ³ Autor ³ Reynaldo Miyashita    ³ Data ³16/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Planilha de cotação do projeto                             ³±±
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
Function PMSA800(nCallOpcx,cRevisa)
Local aUsRotina := {}

PRIVATE cCadastro := "Planilha de Cotação do projeto"
PRIVATE aRotina 	:= {	{ "Pesquisar", "AxPesqui"  , 0 , 1},;
							{ "Visualizar", "PMS800Dlg", 0 , 2},;
							{ "Incluir", "PMS800Dlg", 0 , 3},;
							{ "Alterar", "PMS800Dlg", 0 , 4},;
							{ "Cópia", "PMS800Cpy", 0 , 2},;
							{ "Excluir", "PMS800Dlg", 0 , 5}}

PRIVATE aCores  := PmsAF8Color()

	// adiciona botoes do usuario na EnchoiceBar
	If ExistBlock( "PMA800ROT" )
		If ValType( aUsRotina := ExecBlock( "PMA800ROT", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

	If AMIIn(44)
		If nCallOpcx <> Nil
			PMS800Dlg( "AEB",AEB->(RecNo()),nCallOpcx,,,cRevisa,lSimula)
		Else
			mBrowse(6,1,22,75,"AEB",,,,,,aCores)
		EndIf
	EndIf		

Return .T.

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
Function PMS800Dlg(cAlias,nReg,nOpcX,cR1,cR2,cVers,lSimula)
Local l800Inclui	:= .F.
Local l800Visual	:= .F.
Local l800Altera	:= .F.
Local l800Exclui	:= .F.
Local oEnch
Local oFntVerdana

Local nY         := 0
Local nX         := 0
Local lContinua  := .T.
Local aSize      := {}
Local aObjects   := {} 
Local aInfo      := {}
Local aPosObj    := {}
Local aButtons   := {}
Local aHeadAEEPrd   := {}
Local aHeadAEERec := {}
Local aHeadAECPrd   := {}
Local aHeadAECRec   := {}
Local aColsAEEPrd   := {}
Local aColsAEERec := {}
Local aColsAECPrd   := {}
Local aColsAECREc   := {}
Local aRecAECPrd    := {}
Local aRecAECREc    := {}
Local nOpc       := 0
Local nOpcGDAEC  := 0
Local nOpcGDAEE  := 0
Local aStrAECPrd := {}
Local aStrAECRec := {}
Local aStrAEEPrd := {}
Local aStrAEERec := {}
Local nOpcGet := 0

PRIVATE oGDAEEPrd
PRIVATE oGDAECPrd
PRIVATE oGDAEERec
PRIVATE oGDAECRec
PRIVATE oSayProd
PRIVATE oSayRec
PRIVATE INCLUI  := .F.   
PRIVATE ALTERA  := .F.
PRIVATE EXCLUI  := .F.

PRIVATE cAliasRec  := GetNextAlias() 
PRIVATE cAliasPRD  := GetNextAlias() 

	// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
	Do Case
		Case (aRotina[nOpcX][4] == 2) // Visualizar
			INCLUI  := .F.
			ALTERA  := .F.
			EXCLUI  := .F.
			l800Visual := .T.
			nOpcGet := 2
			nOpcGDAEC := 0
			nOpcGDAEE := 0
		Case (aRotina[nOpcX][4] == 3) .Or. (aRotina[nOpcX,4] == 6) //  Incluir
			INCLUI  := .T.
			ALTERA  := .F.
			EXCLUI  := .F.
			l800Inclui	:= .T.
			nOpcGDAEC := GD_UPDATE
			nOpcGDAEE := GD_INSERT + GD_DELETE + GD_UPDATE
			nOpcGet := 3
		Case (aRotina[nOpcX][4] == 4) // Alterar
			INCLUI  := .F.
			ALTERA  := .T.
			EXCLUI  := .F.
			l800Altera	:= .T.
			nOpcGDAEC := GD_UPDATE
			nOpcGDAEE := GD_INSERT + GD_DELETE + GD_UPDATE
			nOpcGet := 4
		Case (aRotina[nOpcX][4] == 5) // Excluir
			INCLUI  := .F.
			ALTERA  := .F.
			EXCLUI  := .T.
			l800Exclui	:= .T.
			l800Visual	:= .T.
			nOpcGDAEC := 0
			nOpcGDAEE := 0
			nOpcGet := 5
	EndCase
	
	If lContinua
	
		dbSelectArea("AEB")
		RegToMemory("AEB" ,l800Inclui)
		
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

		If _oPMSA8001 <> Nil
			_oPMSA8001:Delete()
			_oPMSA8001 := Nil
		Endif
		
		_oPMSA8001 := FWTemporaryTable():New( cAliasPRD )  
		_oPMSA8001:SetFields(aStrAECPrd) 
		_oPMSA8001:AddIndex("1", {"AEC_FILIAL","AEC_PROJET","AEC_REVISA","AEC_PRODUT","AEC_DATREF"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMSA8001:Create()	

		If _oPMSA8002 <> Nil
			_oPMSA8002:Delete()
			_oPMSA8002 := Nil
		Endif
		
		_oPMSA8002 := FWTemporaryTable():New( cAliasRec )  
		_oPMSA8002:SetFields(aStrAECRec) 
		_oPMSA8002:AddIndex("1", {"AEC_FILIAL","AEC_PROJET","AEC_REVISA","AEC_RECURS","AEC_DATREF"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMSA8002:Create()	
		
		If !l800Inclui
			// faz a montagem do aColsAEEPrd
			dbSelectArea("AEE")
			dbSetOrder(1)
			dbSeek(xFilial("AEE")+AEB->(AEB_PROJET+AEB_REVISA))
			While !Eof() .And. AEE->(AEE_FILIAL+AEE_PROJET+AEE_REVISA)==xFilial("AEE")+AEB->(AEB_PROJET+AEB_REVISA)
			
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
			
		EndIf
		
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
        
		If !l800Inclui
			// Carrega as datas do intervalo de periodo
			aDatas := PmsPeriod(M->AEB_TIPPER ,M->AEB_INIPER ,M->AEB_FIMPER)
	 		    
			// Carrega a aColsAEC referente ao produto da linha atual
			dbSelectArea("AEC")
			dbSetOrder(1)
			dbSeek(xFilial("AEC")+AEB->(AEB_PROJET+AEB_REVISA))
			While !Eof() .And. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA)==xFilial("AEE")+AEB->(AEB_PROJET+AEB_REVISA)
			
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
			
			AECLoadPrd(aHeadAECPRD ,aColsAECPRD ,cAliasPRD ,M->AEB_PROJET ,M->AEB_REVISA ,"" ,aColsAEEPrd[1 ,1] ,aRecAECPRD )
			AECLoadrec(aHeadAECrec ,aColsAECrec ,cAliasrec ,M->AEB_PROJET ,M->AEB_REVISA ,"" ,aColsAEErec[1 ,1] ,aRecAECrec )
			
		EndIf
		
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
		If ExistBlock("PMA800BTN")
			aButtons := ExecBlock("PMA800BTN",.F.,.F.,{aButtons})
			If !(ValType(aButtons) == "A")
				MsgAlert(STR0001)	// #"Ponto de entrada PMA800BTN gerou um retorno inválido"
				aButtons := {}
			EndIf
		EndIf

		// faz o calculo automatico de dimensoes de objetos
		aSize := MsAdvSize(,.F.,400)
		aObjects := {} 
				
		aAdd( aObjects, { 050, 050 , .T., .T. } )
		aAdd( aObjects, { 150, 150 , .T., .T. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
		oEnch := MsMGet():New("AEB",AEB->(RecNo()),nOpcGet,,,,,aPosObj[1],,3,,,,oDlg,,,,,,.T.)

		oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],{STR0014, STR0015},{},oDlg ,,,,.T. ,.T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])	// #"Produto" #"Recurso"
		
		oPnlAEEPrd := TPanel():New(2,2,'',oFolder:aDialogs[1],oDlg:oFont,.T.,.T.,,,(aPosObj[2,4]-aPosObj[2,2])*(3/5),aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
		/*
		MsNewGetDados:= {nTop, nLeft, nBottom, nRight, [ nStyle ], [ uLinhaOk ], [ uTudoOk ], [ cIniCpos ], ;
								[ aAlter ], [ nFreeze ], [ nMax ], [ cFieldOk ], [ uSuperDel ], [ uDelOk ], [ oWnd ],;
								[ aParHeader ], [ aParCols ])
		*/
		oGDAEEPrd  := MsNewGetDados():New(2,2,50,75,nOpcGDAEE,"AlwaysTrue","AlwaysTrue",,,,999,"AEEFieldOK",,,oPnlAEEPrd,aHeadAEEPrd,aColsAEEPrd)
		oGDAEEPrd:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT
		oGDAEEPrd:oBrowse:bChange   := {|| GDAEEChange(oGDAEEPrd ,oGDAECPrd ,cAliasPRD ,M->AEB_PROJET ,M->AEB_REVISA)}
		oGDAEEPrd:bLinhaOk          := {|| GDAEELinOK(oGDAEEPrd)}
		oGDAEEPrd:oBrowse:bGotFocus := {|| GDAEEChange(oGDAEEPrd ,oGDAECPrd ,cAliasPRD ,M->AEB_PROJET ,M->AEB_REVISA)}
		oGDAEEPrd:Cargo := oGDAEEPrd:nAt

		oPnlAECPrd := TPanel():New(2,aPosObj[2,2]+50+((aPosObj[2,4]-aPosObj[2,2])*(3/5)),'',oFolder:aDialogs[1],oDlg:oFont,.T.,.T.,,,((aPosObj[2,4]-aPosObj[2,2])*(2/5))-50,aPosObj[2,3]-aPosObj[2,1],.T.,.T. )

		DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -12 BOLD

		@ 3,14 SAY oSayProd PROMPT STR0014 + ": " SIZE 150,12 Of oPnlAECPrd FONT oFntVerdana COLOR RGB(80,80,80) PIXEL	// #"Produto"
		oSayProd:Align := CONTROL_ALIGN_TOP
		oGDAECPrd  := MsNewGetDados():New(12,2,50,75,nOpcGDAEC,"AllwaysTrue","AllwaysTrue",,,,999,"AECFieldOK",,,oPnlAECPrd,aHeadAECPrd,aColsAECPrd)
		oGDAECPrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGDAECPrd:bTudoOk       := {|| GDAECTudoOK(oGDAECPrd)}
		oGDAECPrd:Cargo         := aRecAECPrd
		
		//
		/*********************************************/
		//
	
		oPnlAEERec := TPanel():New(2,2,'',oFolder:aDialogs[2],oDlg:oFont,.T.,.T.,,,(aPosObj[2,4]-aPosObj[2,2])*(3/5),aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
		oPnlAEERec:Refresh()
		/*
		MsNewGetDados:= {nTop, nLeft, nBottom, nRight, [ nStyle ], [ uLinhaOk ], [ uTudoOk ], [ cIniCpos ], ;
								[ aAlter ], [ nFreeze ], [ nMax ], [ cFieldOk ], [ uSuperDel ], [ uDelOk ], [ oWnd ],;
								[ aParHeader ], [ aParCols ])
		*/
		oGDAEEREC  := MsNewGetDados():New(2,2,(aPosObj[2,4]-aPosObj[2,2])*(3/5) ,oPnlAEERec:nClientWidth -350 ,nOpcGDAEE,"AlwaysTrue","AlwaysTrue",,,,999,"AEERFieldOK()",,,oPnlAEEREC,aHeadAEEREC,aColsAEEREC)
		oGDAEEREC:oBrowse:bChange   := {|| GDAEERChange(oGDAEEREC ,oGDAECRec ,cAliasREC ,M->AEB_PROJET ,M->AEB_REVISA)}
		oGDAEEREC:bLinhaOk          := {|| GDAEERLinOK(oGDAEEREC)}
		oGDAEEREC:oBrowse:bGotFocus := {|| GDAEERChange(oGDAEEREC ,oGDAECRec ,cAliasREC ,M->AEB_PROJET ,M->AEB_REVISA)}
		oGDAEEREC:Cargo := oGDAEEREC:nAt
		oGDAEEREC:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT

		oPnlAECRec := TPanel():New(2,aPosObj[2,2]+50+((aPosObj[2,4]-aPosObj[2,2])*(3/5)),'',oFolder:aDialogs[2],oDlg:oFont,.T.,.T.,,,((aPosObj[2,4]-aPosObj[2,2])*(2/5))-50,aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
		oPnlAECRec:Refresh()
		
		@ 3,2 SAY oSayRec PROMPT STR0015 + ": " SIZE 150,12 Of oPnlAECRec FONT oFntVerdana COLOR RGB(80,80,80) PIXEL	// #"Recurso"
		oSayRec:Align := CONTROL_ALIGN_TOP
		oGDAECRec  := MsNewGetDados():New(12 ,2 ,oPnlAECRec:nClientHeight ,oPnlAECRec:nClientWidth -175  ,nOpcGDAEC,"AllwaysTrue","AllwaysTrue",,,,999,"AECRFieldOK()",,,oPnlAECRec,aHeadAECRec,aColsAECRec)
		oGDAECRec:bLinhaOk          := {|| GDAECRLinOK(oGDAECRec)}
		oGDAECRec:bTudoOk           := {|| GDAECRTudoOK(oGDAECRec)}
		oGDAECRec:Cargo := aRecAECRec
		oGDAECRec:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE MSDIALOG oDlg ON INIT ( oFolder:aDialogs[1]:Refresh() ,oPnlAEEPrd:Refresh() ,oPnlAECPrd:Refresh() ,oGDAECPRD:oBrowse:Refresh() ,oGDAEEPRD:oBrowse:Refresh() ;
		                                ,EnchoiceBar(oDlg ,{||(eVal(oGDAEEPrd:oBrowse:bChange) ,eVal(oGDAEEREC:oBrowse:bChange),iIf( DlgValid(oEnch ,oGDAEEPrd ,oGDAECPrd ,l800Visual ,l800Exclui) ,(nOpc:=1 ,oDlg:End()) ,nOpc:= 0 ))} ,{||oDlg:End()},,aButtons) ;
		                                ,oFolder:aDialogs[2]:Refresh() ,oPnlAEERec:Refresh() ,oPnlAECRec:Refresh() ,oGDAECRec:oBrowse:Refresh() ,oGDAEERec:oBrowse:Refresh();
		                                )

		If (nOpc == 1) .And. (l800Inclui .Or. l800Altera .Or. l800Exclui)
		
			Begin Transaction
				PMS800Grava(l800Inclui ,l800Altera ,l800Exclui ,cAliasPRD ,oGDAECPrd:aHeader ,oGDAECPrd:aCols ,oGDAEEPrd:aHeader ,oGDAEEPrd:aCols ,cAliasREC ,oGDAEErec:aHeader ,oGDAEErec:aCols)
			End Transaction
		
		EndIf
		
		(cAliasPRD)->(dbCloseArea())

		If _oPMSA8001 <> Nil
			_oPMSA8001:Delete()
			_oPMSA8001 := Nil
		Endif
		
		If _oPMSA8002 <> Nil
			_oPMSA8002:Delete()
			_oPMSA8002 := Nil
		Endif

	EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

Return .T.  

Static Function DlgValid(oEnch ,oGDAEEPrd ,oGDAECPrd ,lVisualizar ,lExcluir)
Local lOk := .T.
    
	If !(lExcluir .OR. lVisualizar)
		lOk := Obrigatorio( oEnch:aGets ,oEnch:aTela )
	EndIf

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

	oSayProd:cTitle := STR0014 + ": " + oGDAEEPrd:aCols[oGDAEEPrd:nAt ,1]	// #"Produto"
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

	oSayrec:cTitle := STR0015 + ": " + oGDAEERec:aCols[oGDAEERec:nAt ,1]	// #"Recurso: "
	oSayrec:refresh()
	
Return .T.

Static Function AECLoadPrd(aHeadAEC ,aColsAEC ,cAliasPRD ,cProjeto ,cRevisa ,cProdOld ,cProdNew ,aRecAEC)
Local nY       := 0
Local nX       := 0
Local nZ       := 0
Local nPos	   := 0
Local lSeek    := .T.
Local aDatas   := {}
Local aRecUso  := {}
Local aArea    := GetArea()
Local aAreaAEC := AEC->(GetArea())

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
			nPos := aScan(aHeadAEC,{|x| AllTrim( x[2] ) == "AEC_DATREF"})
			For nY := 1 To len(aColsAEC)
				If (lSeek := dbSeek(xFilial("AEC")+cProjeto+cRevisa+cProdOld+dtos(aColsAEC[nY ,nPos])))
					aAdd(aRecUso ,(cAliasPRD)->(Recno()))
				EndIf
				RecLock( cAliasPRD ,!lSeek)
				For nX := 1 To Len(aHeadAEC)
					If (aHeadAEC[nX,10] != "V")
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
		aDatas := PmsPeriod(M->AEB_TIPPER ,M->AEB_INIPER ,M->AEB_FIMPER)
 		    
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
Local aRecUso  := {}
Local aArea    := GetArea()
Local aAreaAEC := AEC->(GetArea())
Local nPos     := 0

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
			nPos := aScan(aHeadAEC,{|x| AllTrim( x[2] ) == "AEC_DATREF"})
			For nY := 1 To len(aColsAEC)
				If !Empty(nPos) .And. (lSeek := dbSeek(xFilial("AEC")+cProjeto+cRevisa+cRECOld+dtos(aColsAEC[nY ,nPos])))
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
		aDatas := PmsPeriod(M->AEB_TIPPER ,M->AEB_INIPER ,M->AEB_FIMPER)
 		    
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

Function AEEFieldOK()
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local nPosAtual := 0
Local nX        := 0
Local nAECPosDat  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_DATREF"})
Local nAECPosCust := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nAECPosPerc := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nAEEPProd   := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_PRODUT"})
Local nAEEPDatSTD := aScan(oGDAEEPrd:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local cReadVar    := ReadVar()
Local dReferencia := stod("")
Local nPerc := 0
Local nCusto := 0

Local lOk := .T.

	If INCLUI .OR. ALTERA
		If !oGDAEEPrd:aCols[oGDAEEPrd:nAt ,Len(oGDAEEPrd:aHeader)+1] 
		
			If "AEE_PRODUT" $ cReadVar .AND. !Empty(M->AEE_PRODUT)
				nPosAtual := oGDAEEPrd:nAt
				For nX := 1 To len(oGDAEEPrd:aCols)
					If !oGDAEEPrd:aCols[nX ,Len(oGDAEEPrd:aHeader)+1] .AND. nPosAtual != nX .AND. oGDAEEPrd:aCols[nX ,1] == M->AEE_PRODUT
						MsgAlert(STR0002)	// #"O produto já informado!"
						lOk := .F.
					EndIf
				Next nX

				If lOk
					dbSelectArea("SB1")
					dbSetOrder(1)
					If dbSeek(xFilial("SB1")+M->AEE_PRODUT)
					    
						If Empty(RetFldProd(SB1->B1_COD,"B1_UCALSTD")) 
							dReferencia := dDatabase
						Else
							dReferencia := RetFldProd(SB1->B1_COD,"B1_UCALSTD")
						EndIf
					
						oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nAEEPDatSTD] := dReferencia
						
						oGDAEEPrd:aCols[oGDAEEPrd:nAt,3] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						oSayProd:cTitle := STR0014 + ": " + M->AEE_PRODUT	// #"Produto"
						oSayProd:refresh()
						For nX := 1 To len(oGDAECPrd:aCols)
							If DTOS(oGDAECPrd:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(M->AEB_TIPPER ,dReferencia))
								oGDAECPrd:aCols[nX ,nAECPosCust] := RetFldProd(SB1->B1_COD,"B1_CUSTD")
								oGDAECPrd:nAt := nX
								nPerc := oGDAECPrd:aCols[nX ,nAECPosPerc] 
								nCusto := oGDAECPrd:aCols[nX ,nAECPosCust] 
								Exit
							EndIf
						Next nX
						ReCalPer(oGDAECPrd ,nPerc ,nCusto)
						oGDAECPrd:oBrowse:refresh()
					EndIf
				EndIf
			EndIf
			
			If "AEE_CUSTD" $ cReadVar
				If !Empty(oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nAEEPProd])
					For nX := 1 To len(oGDAECPrd:aCols)
						If DTOS(oGDAECPrd:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(M->AEB_TIPPER ,oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nAEEPDatSTD]))
							oGDAECPrd:aCols[nX ,nAECPosCust] := &(cReadVar)
							oGDAECPrd:nAt := nX
							nPerc := oGDAECPrd:aCols[nX ,nAECPosPerc] 
							nCusto := oGDAECPrd:aCols[nX ,nAECPosCust] 
							Exit
						EndIf
					Next nX
					ReCalPer(oGDAECPrd ,nPerc ,nCusto)
					oGDAECPrd:oBrowse:refresh()
				EndIf
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

	If Empty(oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nPosCodPrd])
		MsgAlert(STR0003)	// # "Produto em branco"
		lOk := .F.
	EndIf
	
	If lOk .AND. Empty(oGDAEEPrd:aCols[oGDAEEPrd:nAt ,nPosDatCot])
		MsgAlert(STR0004)	// #"Data do Custo Standard não foi informado"
		lOk := .F.
	EndIf

Return lOk

Static Function GDAEERLinOK( oGDAEErec )
Local lOk := .T.
Local nPosCodrec := aScan(oGDAEErec:aHeader,{|x|AllTrim(x[2])=="AEE_RECURS"})
Local nPosDatCot := aScan(oGDAEErec:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})

	If Empty(oGDAEEREC:aCols[oGDAEEREC:nAt ,nPosCODREC])
		MsgAlert(STR0005)	// #"Recurso em branco"
		lOk := .F.
	EndIf
	
	If lOk .AND. Empty(oGDAEErec:aCols[oGDAEErec:nAt ,nPosDatCot])
		MsgAlert(STR0004)	// #"Data do Custo Standard não foi informado"
		lOk := .F.
	EndIf

Return lOk

Static Function GDAEETudoOK( oGDAEEPrd )
Local nX         := 0
Local lOk        := .T.

	For nX := 1 to Len(oGDAEEPrd:aCols)
		If !(oGDAEEPrd:aCols[nX ,Len(oGDAEEPrd:aHeader)+1])
			If !GDAEELinOK( oGDAEEPrd )
				lOk := .F.
				Exit
			EndIf
		EndIf
	Next nX

Return lOk

STATIC Function GDAEErTudoOK( oGDAEErec )
Local nX         := 0
Local lOk        := .T.

	For nX := 1 to Len(oGDAEErec:aCols)
		If !(oGDAEErec:aCols[nX ,Len(oGDAEErec:aHeader)+1])
			If !GDAEErLinOK( oGDAEErec )
				lOk := .F.
				Exit
			EndIf
		EndIf
	Next nX

Return lOk

Function AECFieldOK()
Local nPosPerc  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nPosCust  := aScan(oGDAECPrd:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nCusto    := 0
Local lRet      := .T.
Local cReadVar  := ""

	cReadVar := ReadVar()

	If INCLUI .OR. ALTERA
	
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

Static Function PMS800Grava(lIncluir ,lAlterar ,lExcluir ,cAliasPRD ,aHeadAEC ,aColsAEC ,aHeadAEEPrd ,aColsAEEPrd ,cAliasRec ,aHeadAEERec ,aColsAEERec)
Local nX       := 0
Local nY       := 0
Local aDatas   := {}
Local aAreaAEE := AEE->(GetArea())
Local aAreaAEC := AEC->(GetArea())
Local aAreaAEB := AEB->(GetArea())
Local aArea    := GetArea()
Local lNew     := .T.
Local nAEEProdut := 0
Local nAEERecurs := 0
Local nCnt       := 0

	If !lExcluir
		
		dbSelectArea("AEB")
		dbSetOrder(1)
		MsSeek(xFilial("AEB")+M->(AEB_PROJET+AEB_REVISA))
		RecLock("AEB",lIncluir)
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(FieldName(nX)))
		Next nx
		AEB->AEB_FILIAL := xFilial("AEB")
		MsUnLock()
		
		// Carrega as datas do intervalo de periodo
		aDatas := PmsPeriod(M->AEB_TIPPER ,M->AEB_INIPER ,M->AEB_FIMPER)
		
		nAEEProdut := aScan( aHeadAEEPrd ,{|x| x[2] == "AEE_PRODUT"})
		nAEERecurs := aScan( aHeadAEERec ,{|x| x[2] == "AEE_RECURS"})
		For nY := 1 to len(aColsAEEPrd)
			// se não foi excluido 
			If !aColsAEEPrd[nY ,Len(aHeadAEEPrd)+1] .AND. !Empty(aColsAEEPrd[nY ,nAEEProdut]) 
				dbSelectArea("AEE")
				dbSetOrder(1)
				lNew := !MsSeek(xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
				RecLock("AEE" ,lNew)
				For nX := 1 TO Len(aHeadAEEPrd)
					If ( aHeadAEEPrd[nX ,10] != "V" )
						AEE->(FieldPut(FieldPos(aHeadAEEPrd[nX ,2]),aColsAEEPrd[nY ,nX]))
					EndIf
				Next nX
				AEE->AEE_REVISA := M->AEB_REVISA
				AEE->AEE_PROJET := M->AEB_PROJET
				AEE->AEE_FILIAL := xFilial("AEE")
				MsUnLock()
				
				aAECRecNo := {}
					
				For nCnt := 1 To len(aDatas)
					// Busca na tabela temporaria
					dbSelectArea(cAliasPRD)
					dbSetOrder(1)
					If dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]+dtos(aDatas[nCnt]))
						dbSelectArea("AEC")
						dbSetOrder(1)
						lNew := !MsSeek(xFilial("AEC")+(cAliasPRD)->(AEC_PROJET+AEC_REVISA+AEC_PRODUT+AEC_RECURS+dtos(AEC_DATREF)))
						RecLock("AEC" ,lNew)
						For nX := 1 TO (cAliasPRD)->(fCount())
							AEC->(FieldPut(FieldPos((cAliasPRD)->(FieldName(nX))) ,(cAliasPRD)->(FieldGet(FieldPos(FieldName(nX))))))
						Next nX
						AEC->AEC_REVISA := M->AEB_REVISA
						AEC->AEC_PROJET := M->AEB_PROJET
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
				dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
				While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL_+AEC_PROJET+AEC_REVISA+AEC_PRODUT)==xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]
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
					dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
					While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+AEC_PRODUT)== xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut]
						RecLock("AEC" ,.F.)
							dbDelete()
						msUnlock()
						dbSkip()
					EndDo
					dbSelectArea("AEE")
					dbSetOrder(1)
					if MsSeek(xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEPrd[nY ,nAEEProdut])
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
				lNew := !MsSeek(xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA)+aColsAEErec[nY ,nAEERecurs])
				RecLock("AEE" ,lNew)
				For nX := 1 TO Len(aHeadAEErec)
					If ( aHeadAEErec[nX ,10] != "V" )
						AEE->(FieldPut(FieldPos(aHeadAEErec[nX ,2]),aColsAEErec[nY ,nX]))
					EndIf
				Next nX
				AEE->AEE_REVISA := M->AEB_REVISA
				AEE->AEE_PROJET := M->AEB_PROJET
				AEE->AEE_FILIAL := xFilial("AEE")
				MsUnLock()
				
				aAECRecNo := {}
					
				For nCnt := 1 To len(aDatas)
					// Busca na tabela temporaria
					dbSelectArea(cAliasRec)
					dbSetOrder(1)
					If dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEErec[nY ,nAEERecurs]+dtos(aDatas[nCnt]))
						dbSelectArea("AEC")
						dbSetOrder(2)
						lNew := !MsSeek(xFilial("AEC")+(cAliasrec)->(AEC_PROJET+AEC_REVISA+AEC_RECURS+space(tamsx3("AEC_PRODUT")[1])+dtos(AEC_DATREF)))
						RecLock("AEC" ,lNew)
						For nX := 1 TO (cAliasrec)->(fCount())
							AEC->(FieldPut(FieldPos((cAliasrec)->(FieldName(nX))) ,(cAliasrec)->(FieldGet(FieldPos(FieldName(nX))))))
						Next nX
						AEC->AEC_REVISA := M->AEB_REVISA
						AEC->AEC_PROJET := M->AEB_PROJET
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
				dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEErec[nY ,nAEERecurs])
				While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL_+AEC_PROJET+AEC_REVISA+AEC_RECURS)==xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEERec[nY ,nAEERecurs]
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
					dbSeek(xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEREC[nY ,nAEERecurs])
					While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+AEC_RECURS)== xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEREC[nY ,nAEERecurs]
						RecLock("AEC" ,.F.)
							dbDelete()
						msUnlock()
						dbSkip()
					EndDo
					dbSelectArea("AEE")
					dbSetOrder(2)
					if MsSeek(xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA)+aColsAEEREC[nY ,nAEERecurs])
						RecLock("AEE" ,.F.)
							dbDelete()
						MsUnlock()
					EndIf
				EndIf
			EndIf
				
		Next nY
		

	Else
		dbSelectArea("AEE")
		dbSetOrder(1)
		dbSeek(xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA))
		While AEE->(!Eof()) .AND. AEE->(AEE_FILIAL+AEE_PROJET+AEE_REVISA) == xFilial("AEE")+M->(AEB_PROJET+AEB_REVISA)
			RecLock("AEE",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
		
		dbSelectArea("AEC")
		dbSetOrder(1)
		dbSeek(xFilial("AEC")+AEB->(AEB_PROJET+AEB_REVISA))
		While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA) == xFilial("AEC")+M->(AEB_PROJET+AEB_REVISA)
			RecLock("AEC",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
		
		dbSelectArea("AEB")
		dbSetOrder(1)
		MsSeek(xFilial("AEB")+M->(AEB_PROJET+AEB_REVISA))
		RecLock("AEB",.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
	
	RestArea(aAreaAEE)
	RestArea(aAreaAEC)
	RestArea(aAreaAEB)
	RestArea(aArea)
	
Return .T. 


Static Function DataSeek( cTipPer ,dData )
Local dRet := stod("")

	Do Case
		Case cTipPer == "2"
			dRet := dData
			If DOW(dData)<>1
				dIni := DOW(dData)-1
			EndIf
		Case cTipPer == "3"
			dRet	:= CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
		Case cTipPer == "4"
			dRet	:= CTOD("01/"+StrZero(MONTH(dData),2,0)+"/"+StrZero(YEAR(dData),4,0))
		OtherWise 
			dRet	:= dData
	EndCase

Return dRet

Function PMSPeriod( cTipPer ,dIniPer ,dFimPer )
Local dIni   := stod("")
Local dX     := stod("")
Local aDatas := {}

	Do Case
		Case cTipPer == "2"
			dIni := dIniPer
			If DOW(dIniPer)<>1
				dIni -= DOW(dIniPer)-1
			EndIf
		Case cTipPer == "3"
			dIni	:= CTOD("01/"+StrZero(MONTH(dIniPer),2,0)+"/"+StrZero(YEAR(dIniPer),4,0))
		Case cTipPer == "4"
			dIni	:= CTOD("01/"+StrZero(MONTH(dIniPer),2,0)+"/"+StrZero(YEAR(dIniPer),4,0))
		OtherWise 
			dIni	:= dIniPer
	EndCase
	
	dX := dIni
	While dX <= dFimPer
		// carrega as datas que fazem parte do periodo
		aadd(aDatas ,dX )
		Do Case 
			Case cTipPer == "2"
				dx += 7
			Case cTipPer == "3"
				If DAY(dx) == 01
					dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				Else
					dx += 35
					dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
				EndIf
			Case cTipPer == "4"
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			OtherWise
				dx += 1
		EndCase
	EndDo
Return aDatas 


Function PMS800Cpy()
Local aParam := {TamSX3("AF8_PROJET")[1] ,TamSX3("AF8_PROJET")[1]}
Local cVerDest := ""
Local cVerOrig := ""

	dbSelectArea("AEB")
	aParam[1] := AEB->AEB_PROJET
	aParam[2] := CriaVar("AF8_PROJET",.F.)

	If ParamBox( { {1, STR0006 + ":" ,aParam[1] ,"@!","ExistCpo('AF8',MV_PAR01)","AF8","",40,.T.} ;	// #"Projeto De"
	              ,{1, STR0007 + ":" ,aParam[2] ,"@!","VldPrjPara(MV_PAR02 ,MV_PAR01)","AF8","",40,.T.} ;	// #"Projeto Para"
	             }, STR0008, @aParam)	// #"Cópia de Planilha"
	             
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(xFilial()+aParam[2])
			cVerDest := AF8->AF8_REVISA
		EndIf
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(xFilial()+aParam[1])
			cVerOrig := AF8->AF8_REVISA
		EndIf
		
		dbSelectArea("AEB")
		dbSetOrder(1)
		If dbSeek(xFilial()+aParam[2]+cVerDest)
			dbSelectArea("AEC")
			dbSetOrder(1)
			dbSeek(xFilial()+aParam[1]+cVerOrig)
			While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA)==xFilial("AEC")+aParam[1]+cVerOrig
			
				RecLock("AEC",.F.)
				dbDelete()
				MsUnLock()

				dbSelectArea("AEC")
				dbSkip()
			EndDo
			
			dbSelectArea("AEE")
			dbSetOrder(1)
			dbSeek(xFilial()+aParam[1]+cVerOrig)
			While AEE->(!Eof()) .AND. AEE->(AEE_FILIAL+AEE_PROJET+AEE_REVISA)==xFilial("AEE")+aParam[1]+cVerOrig
			
				RecLock("AEE",.F.)
				dbDelete()
				MsUnLock()
				
				dbSelectArea("AEE")
				dbSkip()
			EndDo
			RecLock("AEB",.F.)
			dbDelete()
			MsUnLock()
			
		EndIf
		
		dbSelectArea("AEB")
		dbSetOrder(1)
		If dbSeek(xFilial()+aParam[1]+cVerOrig)
			PmsCopyReg("AEB" ,AEB->(Recno()) ,{{"AEB_PROJET",aParam[2]} ,{"AEB_REVISA",cVerDest}})
			dbSelectArea("AEE")
			dbSetOrder(1)
			dbSeek(xFilial()+aParam[1]+cVerOrig)
			While AEE->(!Eof()) .AND. AEE->(AEE_FILIAL+AEE_PROJET+AEE_REVISA)==xFilial("AEE")+aParam[1]+cVerOrig
			
				PmsCopyReg("AEE" ,AEE->(Recno()) ,{{"AEE_PROJET" ,aParam[2]} ,{"AEE_REVISA" ,cVerDest}})
				
				dbSelectArea("AEE")
				dbSkip()
			EndDo
			
			dbSelectArea("AEC")
			dbSetOrder(1)
			dbSeek(xFilial()+aParam[1]+cVerOrig)
			While AEC->(!Eof()) .AND. AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA)==xFilial("AEC")+aParam[1]+cVerOrig
					
				PmsCopyReg("AEC" ,AEC->(Recno()) ,{{"AEC_PROJET",aParam[2]} ,{"AEC_REVISA" ,cVerDest}})
				
				dbSelectArea("AEC")
				dbSkip()
			EndDo

		EndIf
	EndIf
	
Return

Function VldPrjPara(cProjDest ,cProjOrig)  
Local lContinua := .T. 

	If (lContinua := ExistCpo('AF8',cProjDest)) .AND. (cProjOrig==cProjDest)
		lContinua := .F.
	EndIf
	
	If lContinua 
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(xFilial()+cProjDest)
			dbSelectArea("AEB")
			dbSetOrder(1)
			If dbSeek(xFilial()+AF8->(AF8_PROJET+AF8_REVISA))
				If Aviso(STR0008, STR0009 + AllTrim(AEB->AEB_PROJET)+". " + STR0010 ,{STR0011 , STR0012} ,3)== 2	// #"Cópia de planilha" #"Já existe planilha de cotação para o projeto " #"Deseja sobrepor?" #"Continuar" #"Cancelar"
					lContinua := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lContinua

Function AEERFieldOK()
Local aArea    := GetArea()
Local aAreaAE8 := AE8->(GetArea())
Local nPosAtual := 0
Local nX        := 0
Local nAECPosDat  := aScan(oGDAECRec:aHeader,{|x|AllTrim(x[2])=="AEC_DATREF"})
Local nAECPosCust := aScan(oGDAECRec:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nAECPosPerc := aScan(oGDAECRec:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nAEEPRec    := aScan(oGDAEERec:aHeader,{|x|AllTrim(x[2])=="AEE_RECURS"})
Local nAEEPDatSTD := aScan(oGDAEERec:aHeader,{|x|AllTrim(x[2])=="AEE_DATSTD"})
Local cReadVar  := ReadVar()
Local nPerc := 0
Local nCusto := 0

Local lOk := .T.

	If INCLUI .OR. ALTERA
		If "AEE_RECURS" $ cReadVar .AND. !Empty(M->AEE_RECURS)
			nPosAtual := oGDAEERec:nAt
			For nX := 1 To len(oGDAEERec:aCols)
				If !oGDAEERec:aCols[nX ,Len(oGDAEERec:aHeader)+1] .AND. nPosAtual != nX .AND. oGDAEERec:aCols[nX ,1] == M->AEE_RECURS
					MsgAlert(STR0013)	// #"O Recurso já foi informado!"
					lOk := .F.
				EndIf
			Next nX
			If lOk
				dbSelectArea("AE8")
				dbSetOrder(1)
				If dbSeek(xFilial("AE8")+M->AEE_RECURS)
					oGDAEERec:aCols[oGDAEERec:nAt,2] := dDatabase
					oGDAEERec:aCols[oGDAEERec:nAt,3] := AE8->AE8_VALOR
					oSayREC:cTitle := STR0015 + ": " + M->AEE_RECURS	// #"Recurso"
					oSayREC:refresh()
					For nX := 1 To len(oGDAECRec:aCols)
						If DTOS(oGDAECRec:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(M->AEB_TIPPER ,dDatabase))
							oGDAECRec:aCols[nX ,nAECPosCust] := AE8->AE8_VALOR
							oGDAECRec:nAt := nX
							nPerc := oGDAECRec:aCols[nX ,nAECPosPerc] 
							nCusto := oGDAECRec:aCols[nX ,nAECPosCust] 
							Exit
						EndIf
					Next nX
					ReCalPer(oGDAECRec ,nPerc ,nCusto)
					oGDAECRec:oBrowse:refresh()
				EndIf
			EndIf
		EndIf
		
		If "AEE_CUSTD" $ cReadVar
			If !Empty(oGDAEERec:aCols[oGDAEERec:nAt ,nAEEPRec])
				For nX := 1 To len(oGDAECRec:aCols)
					If DTOS(oGDAECRec:aCols[nX ,nAECPosDat]) >= DTOS(DataSeek(M->AEB_TIPPER ,oGDAEERec:aCols[oGDAEERec:nAt ,nAEEPDatSTD]))
						oGDAECRec:aCols[nX ,nAECPosCust] := &(cReadVar)
						oGDAECRec:nAt := nX
						nPerc := oGDAECRec:aCols[nX ,nAECPosPerc] 
						nCusto := oGDAECRec:aCols[nX ,nAECPosCust] 
						Exit
					EndIf
				Next nX
				ReCalPer(oGDAECRec ,nPerc ,nCusto)
				oGDAECRec:oBrowse:refresh()
			EndIf
		EndIf
	EndIf

RestArea(aAreaAE8)
RestArea(aArea)

Return lOk

Function AECRFieldOK()     
Local nPosPerc  := aScan(oGDAECrEC:aHeader,{|x|AllTrim(x[2])=="AEC_PERC"})
Local nPosCust  := aScan(oGDAECREC:aHeader,{|x|AllTrim(x[2])=="AEC_CUSTD"})
Local nCusto    := 0
Local lRet      := .T.
Local cReadVar  := ""

	cReadVar := ReadVar()

	If ALTERA
	
		If "AEC_PERC" $ cReadVar
				
			If !(oGDAECREC:aCols[oGDAECREC:nAt ,nPosPerc] == M->AEC_PERC)
				If M->AEC_PERC <>0
					If oGDAECREC:nAt > 1
						nCusto   := oGDAECREC:aCols[oGDAECREC:nAt-1 ,nPosCust]*(1+(M->AEC_PERC/100))
					EndIf
				Else
					If oGDAECREC:nAt > 1
						nCusto   := oGDAECREC:aCols[oGDAECREC:nAt-1 ,nPosCust]
					Else
						nCusto   := oGDAECREC:aCols[oGDAECREC:nAt ,nPosCust]
					EndIf
				EndIf
				oGDAECREC:aCols[oGDAECREC:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGDAECREC ,M->AEC_PERC ,nCusto)
				
			EndIf
		EndIf
		
		If "AEC_CUSTD" $ cReadVar
		
			If !(oGDAECREC:aCols[oGDAECREC:nAt ,nPosCust] == M->AEC_CUSTD)
				oGDAECREC:aCols[oGDAECREC:nAt ,nPosPerc] := 0
				nCusto   := M->AEC_CUSTD
				oGDAECREC:aCols[oGDAECREC:nAt ,nPosCust] := nCusto
				
				ReCalPer(oGDAECREC ,0 ,nCusto)
				
			EndIf
		EndIf
	EndIf

Return lRet 
