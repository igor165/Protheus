#Include "PROTHEUS.CH"
#INCLUDE "QNCA130.CH"
#INCLUDE "FiveWin.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA130  ³ Autor ³ Leandro 				³ Data ³ 13/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Etapa x Habilidade    						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui"	, 0, 1,,.F.},;	//"Pesquisar"
				 {STR0002, "QNCA130ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QNCA130ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QNCA130ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QNCA130ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QNCA130()
PRIVATE cCadastro := STR0006//"Etapa x Habilidade"
PRIVATE aRotina   := MenuDef()

If !QNCHECK()
	Return(NIL)
Endif	

DbSelectArea("QUQ")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"QUQ")

DbSelectArea("QUQ")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA130ATU³ Autor ³ Leandro				³ Data ³13/02/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do cadastro de Etapa x Habilidade				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA130ATU(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA130ATU                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCA130ATU(cAlias,nReg,nOpc)
Local oDlg
Local bCampo := { |nCPO| Field(nCPO) }
Local nI     := 0
Local aTela  := {}
Local aGets  := {}
Local lOk    := .F.

DbSelectArea("QUQ")
DbSetOrder(1)

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
	M->QUQ_FILIAL:= xFilial("QUQ") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro)	FROM 005,000 TO 300,570 OF oMainWnd PIXEL
EnChoice("QUQ",nReg,nOpc,,,,,{37,3,140,280},,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela) .And. A130Valid(nOpc),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})CENTERED

If (!lOk) .Or. nOpc == 2
	Return NIL
Endif
	
If nOpc == 5
	RecLock("QUQ", .F.)
	dbDelete()
	MsUnLock()
	dbSkip()                                                                
Else
	If nOpc == 3	
		If A130Valid()
			RecLock( "QUQ", .T. )
		Else
			Return()
		Endif	
	Else
		RecLock( "QUQ", .F. )
	EndIf
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnlock()                  
	FKCOMMIT()
End                                                   

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A130Valid ³ Autor ³ Leandro                ³ Data ³13/02/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia da habilidades cadastradas para uma   ³±±
±±³			 ³ mesma etapa          									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130Valid                                            	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A130Valid(nOpc)
Local lRetorno  := .T.
Local aArea 	:= GetArea()

dbSelectArea("QUQ")
dbSetOrder(1)
dbSeek( xFilial("QUQ")+AllTrim(M->QUQ_TPACAO)+AllTrim(M->QUQ_HABIL))

If Empty(M->QUQ_TPACAO)
	MsgAlert(STR0008)//"Campo codigo da acao nao foi preenchido"
	lRetorno := .F.
Else
	If Empty(M->QUQ_HABIL)
		MsgAlert(STR0009)//"Campo habilidade nao foi preenchido"
		lRetorno := .F.
	Else
		If Found() .And. nOpc == 3 
			MSGAlert(STR0007)//"Amarracao Etapa x Habilidade ja cadastrados."
			lRetorno := .F.
		EndIf
	Endif
Endif

RestaRea(aArea)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q130NoHablºAutor  ³Microsiga           º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a nota de habilidade do ambiente de treinamento	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QNCA130                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q130NoHabl(lDic)
Local aArea := GetArea()
Local oDlgN                       
Local oListBox
Local cVlrHb
Local lConfOK := .F.
Local aEtapa := {}
Local cVlrEts := ""
Local cSeek
Local nPQURVal
Local nAchQUR := 0
Local lRet := .T.
Local nPQURHab
Local nPQURDes 

Default lDic := .F.

If lDic
	cSeek := M->QUR_HABIL
	nPQURHab  := Ascan(aHeader,{|x| x[2] = "QUR_HABIL"})	
	nPQURVal  := Ascan(aHeader,{|x| x[2] = "QUR_NOTAHB"})	
	nPQURDes  := Ascan(aHeader,{|x| x[2] = "QUR_DESHAB"})	
	//Verifica se a habilidade ja existe no aCols

	nAchQUR := Ascan(aCols,{|x| Alltrim(x[1]) = Alltrim(M->QUR_HABIL)})		
	
	If nAchQUR > 0 
		MessageDlg("O codigo da habilidade ja esta cadastrado!")		
		M->QUR_HABIL := CriaVar("QUR_HABIL",.T.) 
		If nPQURHab > 0 
			aCols[n,nPQURHab]:= CriaVar("QUR_HABIL",.T.) 
		Endif
		If nPQURDes > 0
			aCols[n,nPQURDes]:= CriaVar("QUR_DESHAB",.T.)			
		Endif	
		lRet := .f.
	Endif		
Else
	cSeek := M->QUQ_HABIL
Endif
If lRet
	dbSelectArea("RBG")
	dbSetOrder(1)
	If dbSeek(xFilial("RBG")+cSeek)
		dbSelectArea("RBK")
		dbSetOrder(1)
		If dbSeek(xFilial("RBK")+RBG->RBG_ESCALA)            
			dbSelectArea("RBL")
			dbSetOrder(1)
			If dbSeek(xFilial("RBL")+RBK->RBK_ESCALA)
				While !RBL->(Eof())
					If RBL->RBL_FILIAL+RBL->RBL_ESCALA == RBG->RBG_FILIAL+RBG->RBG_ESCALA
						Aadd(aEtapa,{RBL->RBL_ITEM,Alltrim(Str(RBL->RBL_VALOR))})		
					Endif	
					dbSkip()
				Enddo
			Else
				MessageDlg(STR0010) //"Nao existe Escala cadastrada no ambiente de Treinamento"
			Endif	
	
		    If Len(aEtapa) > 0
				DEFINE MSDIALOG oDlgN TITLE OemToAnsi(STR0011) FROM 005,000 TO 180,320 OF oMainWnd PIXEL	 //"Escolha o Item/Valor"
				
					@ 005,003 LISTBOX oListBox VAR cVlrHb	FIELDS HEADER TitSX3("RBL_ITEM")[1],TitSX3("RBL_VALOR")[1],;
								           SIZE 154,60 OF oDlgN PIXEL
							
					oListBox:SetArray(aEtapa)                                               
					oListBox:bLine  := {||{aEtapa[oListBox:nAt,1],cVlrEts := aEtapa[oListBox:nAt,2]}}
				
					DEFINE SBUTTON FROM 70,10	S	 TYPE 1 ACTION {|| lConfOK := .T., oDlgN:End() }  ENABLE OF oDlgN PIXEL
				
				ACTIVATE MSDIALOG oDlgN CENTERED VALID lConfOk
				If lConfOK
					If lDic
						M->QUR_NOTAHB := cVlrEts	
						If nPQURVal > 0 
							aCols[n,nPQURVal] := cVlrEts
						Endif
					Else
						M->QUQ_NOTAHB := cVlrEts
					Endif
				Endif	
			Else
				MessageDlg(STR0012)//"Nao existe(m) item(ns)/valor(es) cadastrados no ambiente de Treinamento!"			
			Endif
		Else
			MessageDlg(STR0013)//"Escala nao cadastrada no ambiente de Treinamento!"
		Endif
	Else
		MessageDlg(STR0014) //"Nao existe habilidade cadastrada no ambiente de Treinamento!"
	Endif
Endif

Return lConfOK