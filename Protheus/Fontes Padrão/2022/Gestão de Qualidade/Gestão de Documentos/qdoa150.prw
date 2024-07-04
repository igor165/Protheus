#INCLUDE "QDOA150.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOA150  ³ Autor ³ Edilson Mendes Nascim ³ Data ³ 26/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do plano de centros de custo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA150()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³15/03/02³ META ³ Eduardo S.³ Refeita a rotina utilizando Enchoice.     ³±±
±±³19/03/02³ META ³ Eduardo S.³ Amarracao Pastas x Departamento.          ³±±
±±³27/08/02³ ---- ³ Eduardo S.³ Incluido validacao no codigo do depto qdo ³±±
±±³        ³      ³           ³ integrado com SIGAGPE.                    ³±±
±±³09/01/03³ ---- ³Eduardo S. ³ Alterado para permitir pesquisar usuarios ³±±
±±³        ³      ³           ³ de outras filiais no cad. de responsaveis.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {{ OemToAnsi(STR0001),"AxPesqui" ,0 ,1,,.F.},; //"Pesquisar"
				 { OemToAnsi(STR0002),"QD150Telas",0 ,2},; //"Visualizar"
				 { OemToAnsi(STR0003),"QD150Telas",0 ,3},; //"Incluir"
				 { OemToAnsi(STR0004),"QD150Telas",0 ,4},; //"Alterar"
				 { OemToAnsi(STR0005),"QD150Telas",0 ,5},;  // "Excluir
				 { STR0014           ,"QD150Leg" , 0, 5,,.F. }}    //"Legenda"
Return aRotina

Function QDOA150() 

Local aCores:={}

Private nQaConpad:= 2
Private cCadastro:= OemToAnsi(STR0006)  //"Cadastro de Departamento"
Private aRotina  := MenuDef() 

aCores:=	{{'QAD->QAD_STATUS == "1"','ENABLE' },;
			 {'QAD->QAD_STATUS == "2"','DISABLE'}}

mBrowse(006,001,022,075,"QAD",,,,,,aCores)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD150Telas³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Departamento                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD150Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD150Telas(cAlias,nReg,nOpc)

Local oDlg
Local oFont
Local nI    := 0
Local nOpcao:= 0
Local nCnt  := 0
Local aAlias:= {}
Local aAlter:= {}
Local nSaveSx8:= GetSX8Len()
Local aMsSize	:= MsAdvSize()
Local aObjects 	:= {{ 800, 600, .T., .T., .T. }}
Local aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Local aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )
Local oSayPas
Local oGetQAD

Private oGet
Private lIntGPE:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]
Private aHeader:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private cFilMat:= xFilial("QAA") // Utilizada no SXB

DbSelectArea("QAD")
DbSetOrder(1)

DbSelectArea("QDT")
DbSetOrder(1)

Aadd(aAlias,"QAD")
Aadd(aAlias,"QDT")

For nCnt:= 1 To Len(aAlias)
	DbSelectArea(aAlias[nCnt])
	If nOpc == 3 
	   For nI := 1 To FCount()
	       cCampo := Eval( bCampo, nI )
	       lInit  := .F.
	       If ExistIni( cCampo )
	          lInit := .T.
	          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
	          If ValType( M->&( cCampo ) ) = "C"
	      	     M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
	          EndIf
	          If M->&( cCampo ) == Nil
	             lInit := .F.
	          EndIf
	       EndIf
	       If !lInit
	          M->&( cCampo ) := FieldGet( nI )
	          If ValType( M->&( cCampo ) ) = "C"
	             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
	          ElseIf ValType( M->&( cCampo ) ) = "N"
	             M->&( cCampo ) := 0
	          ElseIf ValType( M->&( cCampo ) ) = "D"
	             M->&( cCampo ) := CtoD( "  /  /  " )
	          ElseIf ValType( M->&( cCampo ) ) = "L"
	             M->&( cCampo ) := .f.
	          EndIf
	       EndIf
	   Next nI
	Else
	   For nI := 1 To FCount()
	       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	   Next nI
	EndIf
Next nCnt

If Inclui
	M->QAD_FILIAL:= xFilial("QAD")
	M->QDT_FILIAL:= xFilial("QDT")
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7] ,000 To aMsSize[6], aMsSize[5]  OF oMainWnd PIXEL //"Cadastro de Departamento"

oPnlMain       := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,200,200,.T.,.T. )
oPnlMain:Align := CONTROL_ALIGN_ALLCLIENT

oPnlEnc        := TPanel():New(0,0,'',oPnlMain,, .T., .T.,, ,160,160,.T.,.T. )
oPnlEnc:Align  := CONTROL_ALIGN_TOP

oPnlGetD       := TPanel():New(0,0,'',oPnlMain,, .T., .T.,, ,200,200,.T.,.T. )
oPnlGetD:Align := CONTROL_ALIGN_ALLCLIENT

oGetQAD:=MsMGet():New("QAD",nReg,nOpc,,,,,{014,002,070,312},,,,,,oPnlEnc)  
oGetQAD:oBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 005,002 SAY oSayPas PROMPT Space(2)+OemToAnsi(STR0009) SIZE 100,010 OF oPnlGetD COLOR CLR_HRED,CLR_WHITE PIXEL // "Pastas x Departamentos"
oSayPas:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD150Ahead()
QD150Acols(nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que podem ser Alterados		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlter,"QDT_CODMAN")

if !SetMDIchild()
	oGet := MSGetDados():New(075,002,190,312,nOpc,"QD150LinOk","QD150TudOk"," ",.T.,aAlter,,,,,,,,oPnlGetD)	
Else    
	oGet := MSGetDados():New(065,002,aMsSize[4],aMsSize[3],nOpc,"QD150LinOk","QD150TudOk"," ",.T.,aAlter,,,,,,,,oPnlGetD)	
EndIf
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .AND. QD150VLD() ,;
										(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED

If nOpc <> 2
	If nOpcao == 1
		If nOpc == 3 .Or. nOpc == 4
			QDA150GrCC(nOpc)
			While (GetSX8Len() > nSaveSx8)
			   	ConfirmSX8()		
			Enddo
		ElseIf nOpc == 5
			QDA150Dele()
		EndIf
	Else
		While (GetSX8Len() > nSaveSx8)
			RollBackSX8()
		Enddo
	Endif
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA150GrCC³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Departamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA150GrCC(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA150GrCC(nOpc)

Local lRecLock:= .F.
Local nCnt    := 0
Local nCpo    := 0
Local nPosDel := Len(aHeader) + 1
Local nPos01  := aScan(aHeader, { |x| AllTrim(x[2]) == "QDT_CODMAN" })

If nOpc == 3
	lRecLock:= .T.
EndIf

Begin Transaction
	DbSelectArea("QAD")
	DbSetOrder(1)
	RecLock("QAD",lRecLock)
	For nCnt := 1 TO FCount()
		FieldPut(nCnt,M->&(Eval(bCampo,nCnt)))
	Next nCnt	
	MsUnLock()      
	FKCOMMIT()
	
	DbSelectArea("QDT")
	DbSetOrder(1)
	For nCnt:= 1 To Len(aCols)
		If !aCols[nCnt, nPosDel] .And. !Empty(aCols[nCnt,nPos01])  // Verifica se o item foi deletado
			If Altera
				If QDT->(DbSeek(M->QAD_FILIAL+M->QAD_CUSTO+xFilial("QDC")+Acols[nCnt,nPos01]))
					RecLock("QDT",.F.)
				Else
					RecLock("QDT",.T.)
				Endif
			Else
				RecLock("QDT",.T.)
			Endif
			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					QDT->(FieldPut(FieldPos(Trim(aHeader[nCpo,2])),aCols[nCnt,nCpo]))
				EndIf
			Next nCpo
			QDT->QDT_FILIAL:= xFilial("QDT")
			QDT->QDT_FILDEP:= M->QAD_FILIAL
			QDT->QDT_DEPTO := M->QAD_CUSTO
			If FWModeAccess("QDC") == "E" //Retorna o modo de compartilhamento
				QDT->QDT_FILCOD := M->QAD_FILIAL
			EndIf 
			MsUnlock()
			FKCOMMIT()
		Else
			If QDT->(DbSeek(M->QAD_FILIAL+M->QAD_CUSTO+xFilial("QDC")+Acols[nCnt,nPos01]))
				RecLock("QDT",.F.)
				QDT->(DbDelete())
				MsUnlock()
				FKCOMMIT()
				QDT->(DbSkip())
			Endif
		Endif
	Next nCnt
End Transaction
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA150Dele³ Autor ³ Edilson Mendes Nascim ³ Data ³ 26/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Departamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA150Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA150Dele()

Local lQD0  := .F.

CursorWait()
MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0007),{|| QDA150VRCC(@lQD0)})	// "Validacao da Exclusao de Departamento..." ### "Aguarde"
CursorArrow()
	
If !lQD0
	Begin Transaction
		If QDT->(DbSeek(M->QAD_FILIAL+M->QAD_CUSTO))
			While QDT->(!Eof()) .And. QDT->QDT_FILDEP+QDT->QDT_DEPTO == M->QAD_FILIAL+M->QAD_CUSTO
				RecLock("QDT",.F.)
				DbDelete()
				MsUnlock()     
				FKCOMMIT()
				QDT->(DbSkip())
			EndDo
		EndIf

		RecLock("QAD",.F.)
		DbDelete()
		MsUnlock()
		FKCOMMIT()
		DbSkip()
	End Transaction
Else
	Help( " ", 1, "EXISTELARE") // Existe Relacao
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA150VRCC³ Autor ³ Eduardo de Souza      ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Relacionamento Departamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA150VRCC(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Verifica se registro pode ser apagado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA150VRCC(lQD0)

Local cAliasQry := ""
Local lQadExc	:= FWModeAccess("QAD")=="E"//Empty(xFilial("QAD"))
Local aArea		:= GetArea()
Local aDeptos	:= { 	"QD0_DEPTO", "QD1_DEPTO", "QD2_DEPTO", "QD8_DEPTO",;
						"QDD_DEPTOA", "QDG_DEPTO", "QDH_DEPTOD", "QAA_CC" }, nDeptos
Local cAlias	:= ""

For nDeptos := 1 To Len(aDeptos)
	cAlias	  := Left(aDeptos[nDeptos], 3)
	If cAlias = "QDH"
		cAliasQry := SelDados(	"QDH", "(QDH_DEPTOD = '" + QAD->QAD_CUSTO + "' .Or. " +;
								"QDH_DEPTOE = '" + QAD->QAD_CUSTO + "')" +;
								If(lQadExc, " .And. " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'", ""),,, { "QDH_DEPTOD", "QDH_DEPTOE" } )
		If 	(cAliasQry)->QDH_DEPTOD = QAD->QAD_CUSTO .Or.;
			(cAliasQry)->QDH_DEPTOE = QAD->QAD_CUSTO
			lQd0 := .T.
		Endif
	Else
		cAliasQry := SelDados(	cAlias, aDeptos[nDeptos] + " = '" + QAD->QAD_CUSTO + "'" +;
								If(lQadExc, " .And. " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'", ""),,, { aDeptos[nDeptos] })
		If &(cAliasQry + "->" + aDeptos[nDeptos]) = QAD->QAD_CUSTO
			lQd0 := .T.
		Endif
	Endif
	RemoveSel(cAlias)
	If lQd0
		Exit
	Endif
Next

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QD150Ahead³ Autor ³Eduardo de Souza      ³ Data ³ 19/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD150Ahead()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD150Ahead()

Local aStruQDT := FWFormStruct(3,"QDT")[3]
Local aStruQDC := FWFormStruct(3,"QDC")[3]
Local nX       := 0

aHeader:= {}
nUsado := 0

For nX := 1 To Len(aStruQDT)
	If cNivel >= GetSx3Cache(aStruQDT[nX,1], "X3_NIVEL")
		If 	AllTrim(aStruQDT[nX,1]) == "QDT_CODMAN" .Or. AllTrim(aStruQDT[nX,1]) == "QDT_DESMAN" .Or.;
			AllTrim(aStruQDT[nX,1]) == "QDT_FILCOD"
			nUsado++
			aAdd(aHeader,{ Trim(QAGetX3Tit(aStruQDT[nX,1])), ;
						   aStruQDT[nX,1], ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_PICTURE"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_TAMANHO"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_DECIMAL"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_VALID"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_USADO"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_TIPO"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_ARQUIVO"), ;
						   GetSx3Cache(aStruQDT[nX,1], "X3_CONTEXT")})
		EndIf
	EndIf
Next nX

For nX := 1 To Len(aStruQDC)
	If cNivel >= GetSx3Cache(aStruQDC[nX,1],"X3_NIVEL")
		If 	AllTrim(aStruQDC[nX,1]) == "QDC_STATUS" 
			nUsado++
			aAdd(aHeader,{ Trim(QAGetX3Tit(aStruQDC[nX,1])), ;
						   aStruQDC[nX,1], ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_PICTURE"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_TAMANHO"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_DECIMAL"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_VALID"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_USADO"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_TIPO"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_ARQUIVO"), ;
						   GetSx3Cache(aStruQDC[nX,1], "X3_CONTEXT")})
		EndIf
	EndIf
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD150Acols³ Autor ³Eduardo de Souza      ³ Data ³ 19/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD150Acols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD150Acols(nOpc)

Local nI    := 0
Local cCpo	:=""
Local cFilPst:=xFilial("QDC")

nUsado:= Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	aCols := Array(1,nUsado+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			cCpo := AllTrim(Upper(aHeader[nI,2]))
			IF cCpo=="QDC_STATUS"	
				aCols[Len(aCols),nI] := "1"
			Else
				aCols[1,nI] := Space(aHeader[nI,4])
			Endif
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD("  /  /  ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI
	aCols[1,nUsado+1] := .F.
Else
	DbSelectArea("QDT")
	DbSetOrder(1)
	If QDT->(DbSeek(QAD->QAD_FILIAL+QAD->QAD_CUSTO))
		While QDT->(!Eof()) .And. QDT->QDT_FILDEP+PADR( QDT->QDT_DEPTO, TAMSX3('QDT_DEPTO')[1] ) == QAD->QAD_FILIAL+QAD->QAD_CUSTO
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					IF cCpo=="QDC_STATUS"	
						If FWModeAccess("QDC") == "E" //!Empty(xFilial("QDC"))
							cFilPst:= QDT->QDT_FILCOD
						EndIf
						aCols[Len(aCols),nI] := Posicione("QDC",1,cFilPst+QDT->QDT_CODMAN,"QDC_STATUS")
					Else					
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Endif
				Else										// Campo Virtual
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			QDT->(DbSkip())
		Enddo            		
	Else
		aCols := Array(1,nUsado+1)
			
		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				IF cCpo=="QDC_STATUS"	
					aCols[Len(aCols),nI] := "1"
				Else
					If cCpo == "QDT_FILCOD"
						aCols[1,nI] := CriaVar("QDT_FILCOD")
					Else
						aCols[1,nI] := Space(aHeader[nI,4])
					Endif
				Endif
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD("  /  /  ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI
		aCols[1,nUsado+1] := .F.
	EndIf
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QD150LinOk³ Autor ³ Eduardo de Souza     ³ Data ³ 19/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD150LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD150LinOk

Local lRet   := .t.
Local nCont  := 0
Local nPos01 := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QDT_CODMAN"})
Local nPosDel:= Len(aHeader) + 1

If aCols[n,nUsado+1] == .F.
	If Empty(aCols[n,nPos01])
		Help(" ",1,"QDT_CODMAN")
		lRet := .F.
	Endif
	If nPos01 <> 0
		Aeval( aCols, { |X| If(X[nPosDel] == .F. .And. X[nPos01] == aCols[N,nPos01],nCont++,nCont)})
		If nCont > 1
			Help(" ",1,"QALCTOJAEX")
			lRet:= .F.
		EndIf
	EndIf
EndIf

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QD150TudOk³ Autor ³ Wagner Mobile Costa  ³ Data ³ 23/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para confirmacao da gravacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD150TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD150TudOk

Local lRet := .F.
Local N

For N := 2 To Len(aCols)
	If ! QD150LinOk()
		lRet := .F.
		Exit
	Endif
Next

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD150VLD  ºAutor  ³Telso Carneiro      º Data ³  31/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a Gravacao do Depto                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD150VLD()
Local lRet	 :=.T.
Local cFilQAD

IF FWModeAccess("QAD")=="E"  //!EMPTY(xFilial("QAD"))
	cFilQAD:= xFilial("QAD")
	IF cFilQAD!=M->QAD_FILMAT
		Help("",1,"QADFILDIF",,OemtoAnsi(STR0010)+CHR(13)+;  //"Devido a Configuração de (Filial Exclusiva)"
				               OemtoAnsi(STR0011)+CHR(13)+;   //" do Depto,Não é permitido o Cadastro"
				               OemtoAnsi(STR0012),1,0)  //" de Responsavel de Filial diferente da Depto"
		lRet:= .F.
	ENDIF
Endif    

If lRet
	IF !Empty(M->QAD_MAT)
		lRet:=QA_CHKMAT(M->QAD_FILMAT,M->QAD_MAT)
	Endif	
Endif

REturn(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOA150   ºAutor  ³Renata Cavalcante   º Data ³  11/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda do Browse da rotina de Departamento                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Visualização da Legenda do Browse                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QD150Leg()

BrwLegenda(STR0013,STR0014, {	{"ENABLE"    ,STR0015 },; // ""Departamento"" ### "Legenda" ###
						       	{"DISABLE"   ,STR0016 }}) // "Departamento Inativo"

Return(NIL)
