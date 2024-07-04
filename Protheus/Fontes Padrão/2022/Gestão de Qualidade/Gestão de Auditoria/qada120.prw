#include "PROTHEUS.CH"
#include "QADA120.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QADA120  ³ Autor ³ Paulo Emidio de Barros³ Data ³ 17/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Questoes adicionais por Auditoria			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQAD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Robson Ramir³13/06/02³ Meta ³Alteracao da estrutura da tela para padrao³±±
±±³            ³        ³      ³enchoice e melhorias                      ³±±
±±³            ³        ³      ³Alteracao de campo carac. para memo       ³±±
±±³            ³        ³      ³Adaptacao das melhorias feitas para J&J   ³±±
±±³Eduardo S.  ³14/10/02³------³Alterado para gravar o status da Auditoria³±±
±±³Eduardo S.  ³28/11/02³------³Alterado gravar o questionario somente pa-³±±
±±³            ³        ³      ³ra a Area que ira Auditar o CheckList/Top.³±±
±±³Eduardo S.  ³28/11/02³------³Alterado para permitir somente o acesso de³±±
±±³            ³        ³      ³Auditores envolvidos na Auditoria.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina := {	{ STR0001, "AxPesqui"    , 0 , 1,,.F.},;   //"Pesquisar"
				 	{ STR0002, "QADA120ATU"  , 0 , 2},;   //"Visualizar"  
				 	{ STR0003, "QADA120ATU"  , 0 , 3},;   //"Incluir"     
				 	{ STR0004, "QADA120ATU"  , 0 , 4, 2},;//"Alterar"     
				 	{ STR0005, "QADA120ATU"  , 0 , 5, 1}} //"Excluir"  

Return aRotina

Function QADA120()

Local aUsrMat	:= QA_USUARIO()
Local lSoLider	:= GetMv("MV_AUDSLID", .T., .F.)
Private cMatFil	:= aUsrMat[2]
Private cMatCod	:= aUsrMat[3]

PRIVATE cCadastro := OemToAnsi(STR0006)//"Questoes Adicionais por Auditoria"

PRIVATE aRotina := MenuDef()

If lSoLider
	DbSelectArea("QUH")
	DbSetOrder(1)

	DbSelectArea("QUJ")
	DbSetOrder(2)
Endif
DbSelectArea("QUE")
DbSetOrder(1)
If lSoLider
	Set Filter To &("Qad120Qau()")
Endif

mBrowse( 6, 1,22,75,"QUE") 

DbSelectArea("QUE")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA120ATU ³ Autor ³Paulo Emidio de Barros³ Data ³17/11/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao das Questoes adicionais						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADA120Atu(cAlias,nReg,nOpc)

Local oDlg   
Local lOk	:= .F.  
Local aSize    	:= MsAdvSize()
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
local aPosObj   := MsObjSize(aInfo,{},.T.)
Local aAcho     := {"QUE_NUMAUD", "QUE_CHKLST", "QUE_REVIS", "QUE_CHKITE", "QUE_QSTITE", "QUE_TXTQS1", "QUE_OBSER1",;
                    "QUE_REQQS1", "QUE_FAIXIN", "QUE_FAIXFI", "QUE_ULTREV", "QUE_PESO", "QUE_USAALT" }

Private aGets   := {}
Private aTela   := {}
Private cChkLst := "ß"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc <> 3 .and. nOpc <> 2) .Or. (nOpc = 2 .And. Empty( POSICIONE("QUB",1,QUE->QUE_FILIAL + QUE->QUE_NUMAUD ,"QUB_ENCREA") ))
	If !QADCkAudit(QUE->QUE_NUMAUD)
		Return(NIL)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variaveis para edicao dos dados na enchoice		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QUE",(nOpc==3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a questao ja possui resultado cadastrado         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc ==5 
	If !(Q120QstRes(nOpc))
		Return(NIL)
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Tela de Edicao dos Dados							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL
EnChoice("QUE",nReg,nOpc,,,, aAcho,{033,003,aSize[4],aSize[3]},,)

If (nOpc # 2)              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := (Q120VldGet(nOpc) .AND. QADA120All() .And. Obrigatorio(aGets,aTela)),If(lOk,oDlg:End(),)},{||oDlg:End()},,)
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
EndIf	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Gravacao											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	If lOk
		Begin Transaction
			Q120GrvQst(nOpc)
		End Transaction
	EndIf
EndIf

	
Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q120GrvQst³ Autor ³ Paulo Emidio de Barros³ Data ³17/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a gravacao e Manutencao da Questao Adicional       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q120GrvQst(nOpc)			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada no aRotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q120GrvQst(nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCont   := 0
Local lVerEvid:= GetMv("MV_QADEVI",.T.,.F.) 
	
If nOpc == 5

	QUJ->(dbSetOrder(1))
	QUJ->(dbSeek(xFilial("QUJ")+QUE->QUE_NUMAUD))
	While QUJ->(!Eof()) .And. QUJ->QUJ_FILIAL+QUJ->QUJ_NUMAUD == xFilial("QUJ")+QUE->QUE_NUMAUD		

		If QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE == QUE->QUE_CHKLST+QUE->QUE_REVIS+QUE->QUE_CHKITE				

			QUD->(dbSetOrder(1))
			If QUD->(dbSeek(xFilial("QUD")+QUE->QUE_NUMAUD+QUJ->QUJ_SEQ+QUE->QUE_CHKLST+;
				QUE->QUE_REVIS+QUE->QUE_CHKITE+QUE->QUE_QSTITE))
	
				RecLock("QUD",.F.)
				dbDelete()
				MsUnlock()
				FKCOMMIT()
			EndIf			
		EndIf		
		QUJ->(dbSkip())		

	EndDo       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a exclusao dos campos no formato Memo (SYP)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsMM(QUE->QUE_TXTCHV,,,,2,,,,) //Text Questao

	MsMM(QUE->QUE_OBSCHV,,,,2,,,,) //Observacoes

	MsMM(QUE->QUE_REQCHV,,,,2,,,,) //Requisitos
	
	RecLock("QUE",.F.)
	dbDelete()         
	MsUnLock()
	
Else	
	RecLock("QUE",If(nOpc == 3,.T.,.F.))
	For nCont := 1 To FCount()
		If "_FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QUE"))
		Elseif ALLTRIM(UPPER(Field(nCont)))=="QUE_PESO"
			FieldPut(nCont,If(M->&(EVAL(bCampo,nCont))==0,1,M->&(EVAL(bCampo,nCont))))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont
	MsUnlock()                       
	FKCOMMIT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a gravacao dos campos no formato Memo (SYP)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsMM(,TamSX3("QUE_TXTQS1")[1],,M->QUE_TXTQS1,1,,,"QUE","QUE_TXTCHV") // Text Questao

	MsMM(,TamSX3("QUE_OBSER1")[1],,M->QUE_OBSER1,1,,,"QUE","QUE_OBSCHV") // Observacoes

	MsMM(,TamSX3("QUE_REQQS1")[1],,M->QUE_REQQS1,1,,,"QUE","QUE_REQCHV") // Requisitos
	
	QUJ->(dbSetOrder(1))
	QUJ->(dbSeek(xFilial("QUJ")+QUE->QUE_NUMAUD))
	While QUJ->(!Eof()) .And. QUJ->QUJ_FILIAL+QUJ->QUJ_NUMAUD == xFilial("QUJ")+QUE->QUE_NUMAUD
		
		If QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE == QUE->QUE_CHKLST+QUE->QUE_REVIS+QUE->QUE_CHKITE		
	
			QUD->(dbSetOrder(1))
			If !QUD->(dbSeek(xFilial("QUD")+QUE->QUE_NUMAUD+QUJ->QUJ_SEQ+QUE->QUE_CHKLST+;
				QUE->QUE_REVIS+QUE->QUE_CHKITE+QUE->QUE_QSTITE))

				RecLock("QUD",.T.)
				QUD->QUD_FILIAL := xFilial("QUD") 
				QUD->QUD_NUMAUD := QUE->QUE_NUMAUD
				QUD->QUD_SEQ    := QUJ->QUJ_SEQ
				QUD->QUD_CHKLST := QUE->QUE_CHKLST
				QUD->QUD_REVIS  := QUE->QUE_REVIS
				QUD->QUD_CHKITE := QUE->QUE_CHKITE
				QUD->QUD_QSTITE := QUE->QUE_QSTITE
				QUD->QUD_TIPO   := "2"
				MsUnLock()			
			EndIf

		EndIf			
		QUJ->(dbSkip())
		
	EndDo
	
	If nOpc == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se existir o campo Grava o Status da Auditoria.	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QUB->(DbSeek(QUE->QUE_FILIAL+QUE->QUE_NUMAUD))
			If QUB->QUB_STATUS == "3" .And. lVerEvid
				RecLock("QUB",.F.)
				QUB->QUB_STATUS:= "2"
				MsUnlock()
				FKCOMMIT()
			EndIf
		EndIf
	EndIf

EndIf	

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q120NexQst³ Autor ³ Paulo Emidio de Barros³ Data ³17/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve a proxima sequencia da questao				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q120NexQst(EXPN1)	                           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120NexQst(nOpc)
Local cRetQst                           
Local aSavArea := GetArea()

If nOpc == 3
	QUE->(dbSetOrder(1))
	If QUE->(dbSeek(xFilial("QUE")+M->QUE_NUMAUD+M->QUE_CHKLST+M->QUE_REVIS+M->QUE_CHKITE))
	
		While QUE->(!Eof()) .And. QUE->QUE_FILIAL == xFilial("QUE") .And.;
			(QUE->QUE_NUMAUD+QUE->QUE_CHKLST+QUE->QUE_REVIS+QUE->QUE_CHKITE)==;
			(M->QUE_NUMAUD+M->QUE_CHKLST+M->QUE_REVIS+M->QUE_CHKITE)
			QUE->(dbSkip())
		EndDo
		QUE->(dbSkip(-1))
		cRetQst := StrZero(Val(QUE->QUE_QSTITE)+1,Len(QUE->QUE_QSTITE))
		
	Else
		QU4->(dbSetOrder(1))
		If QU4->(dbSeek(xFilial("QU4")+M->QUE_CHKLST+M->QUE_REVIS+M->QUE_CHKITE))
			While QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
				(QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE)==;
				(M->QUE_CHKLST+M->QUE_REVIS+M->QUE_CHKITE)
				QU4->(dbSkip())
			EndDo
			QU4->(dbSkip(-1))
			cRetQst := StrZero(Val(QU4->QU4_QSTITE)+1,Len(QU4->QU4_QSTITE))
		Else
			cRetQst := StrZero(1,Len(QU4->QU4_QSTITE))
		Endif
		
	EndIf     
	
	If Empty(M->QUE_NUMAUD) .Or. Empty(M->QUE_CHKLST) .Or.;
		Empty(M->QUE_REVIS) .Or. Empty(M->QUE_CHKITE)
		cRetQst := Space(Len(QUE->QUE_QSTITE))	
	EndIf
Else
	cRetQst := QUE->QUE_QSTITE	
EndIf

RestArea(aSavArea)

Return(cRetQst)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q120VldGet³ Autor ³ Paulo Emidio de Barros³ Data ³17/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ efetua a validacao dos gets correntes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q120VldGet()			                           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120VldGet(nOpc)
Local lRetorno := .T.

If nOpc == 3 .or. nOpc == 4
	If Empty(M->QUE_NUMAUD)  .Or. Empty(M->QUE_CHKLST) .Or.;
		Empty(M->QUE_REVIS)  .Or. Empty(M->QUE_CHKITE) .Or.;
		Empty(M->QUE_QSTITE) .Or. Empty(M->QUE_TXTQS1) .Or.;
		Empty(M->QUE_USAALT)
     
		Help("",1,"120CABNINF")
		lRetorno := .F.
	Endif
Endif    

Return(lRetorno)
                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q120QstRes³ Autor ³ Paulo Emidio de Barros  ³ Data ³17/10/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³verifica se a questao selecionada ja possui resultados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q120QstRes()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM												  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120QstRes(nOpc)
Local lRetorno := .T.
Local aSavArea := GetArea()

QUJ->(dbSetOrder(1))
QUJ->(dbSeek(xFilial("QUJ")+QUE->QUE_NUMAUD))
While QUJ->(!Eof()) .And. QUJ->QUJ_FILIAL+QUJ->QUJ_NUMAUD == xFilial("QUJ")+QUE->QUE_NUMAUD		

	If QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE == QUE->QUE_CHKLST+QUE->QUE_REVIS+QUE->QUE_CHKITE			

		QUD->(dbSetOrder(1))
		QUD->(dbSeek(xFilial("QUD")+QUE->QUE_NUMAUD+QUJ->QUJ_SEQ+QUE->QUE_CHKLST+;
			QUE->QUE_REVIS+QUE->QUE_CHKITE+QUE->QUE_QSTITE))

		If QUD->(!Eof())
			If !Empty(QUD->QUD_DTAVAL)
				If nOpc == 4
					Help("",1,"120ALTQRSP") // "Esta questao nao podera ser alterada," ### "pois a mesma ja esta respondida."
				ElseIf nOpc == 5
					Help("",1,"120QSTRESP")
				EndIf
				lRetorno := .F.
				Exit
			EndIf	
		EndIf

	EndIf	
	QUJ->(dbSkip())			
EndDo

RestArea(aSavArea)

Return(lRetorno)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q120FilChk³ Autor ³ Paulo Emidio de Barros  ³ Data ³12/04/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os CheckLists utlizados na Auditoria		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q120FilChk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120FilChk(cNumAud)

QUJ->(dbSetorder(1))
If QUJ->(dbSeek(xFilial("QUJ")+cNumAud))
	While QUJ->(!Eof()) .And. QUJ->QUJ_FILIAL == xFilial("QUJ") .And.;
		QUJ->QUJ_NUMAUD == cNumAud
		If At(QUJ->(QUJ_CHKLST+QUJ_REVIS),cChkLst) == 0
			cChkLst += QUJ->(QUJ_CHKLST+QUJ_REVIS)+'ß'
		EndIf
		QUJ->(dbSkip())
	EndDo		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QADCkAudit(cNumAud)
	Return(.F.)
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QAD120VlFaixa ³ Autor ³Robson Ramiro A. Olive³Data ³29/05/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se a nota esta dentro da faixa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD120VlFaixa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QAD120VlFaixa(nOpc)
Local lReturn := .F.
Local cValid1, cValid2
Local lVal1, lVal2

If ValType(M->QUE_FAIXFI) <> "U"
	cValid1 := "Positivo(M->QUE_FAIXIN) .and. If(M->QUE_FAIXFI>0,M->QUE_FAIXIN<M->QUE_FAIXFI,.T.)"
Else
	cValid1 := "Positivo(M->QUE_FAIXIN)"
EndIf

If ValType(M->QUE_FAIXIN) <> "U"
	cValid2 := "Positivo(M->QUE_FAIXFI) .and. If(M->QUE_FAIXIN>0,M->QUE_FAIXIN<M->QUE_FAIXFI,.T.)"
Else
	cValid2 := "Positivo(M->QUE_FAIXFI)"
EndIf

If nOpc == 1
	lVal1 := &(cValid1)
	lVal2 := .T.
Elseif nOpc == 2
	lVal2 := &(cValid2)
	lVal1 := .T.
Elseif nOpc == 3
	lVal1 := &(cValid1)
	lVal2 := &(cValid2)
Endif

If INCLUI .or. ALTERA
	If lVal1 .and. lVal2
		lReturn := .T.
	Else
		If lVal1
			Help(" ",1,"QUE_FAIXIN")
		Else
			Help(" ",1,"QUE_FAIXFI")
		Endif
	Endif
Else
	lReturn := .T.
Endif

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QAD120ChkLst  ³ Autor ³Paulo Emidio de Barros³Data ³09/09/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o CheckList realacionado a Auditoria				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD120ChkLst()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QAD120ChkLst()
Local lRetorno := .T.
Local lHelp    := .F.
                  
If !Empty(M->QUE_CHKLST) .And. lRetorno
                                        
	//Verifica a existencia do CheckList
	QU2->(dbSetOrder(1))
	If QU2->(!dbSeek(xFilial('QU2')+M->QUE_CHKLST))
	    lRetorno := .F.
	    lHelp    := .T.
	EndIf

	If !Empty(M->QUE_REVIS) .And. lRetorno                
	    
	    //Verifica a existencia do CheckList + Revisao
		QU2->(dbSetOrder(1))
		If QU2->(!dbSeek(xFilial('QU2')+M->QUE_CHKLST+M->QUE_REVIS))
	        lRetorno := .F.
	   		lHelp    := .T.
	    EndIf
	
	    //Verifica se o CheckList encontra-se efetivado
		lRetorno := QADChkEfet(M->QUE_CHKLST+M->QUE_REVIS,.T.,.F.)
	
		//Verifica se o Check List esta associado a Auditoria
		If !Empty(M->QUE_NUMAUD) .And. lRetorno
			QUJ->(dbSetOrder(2))
		  	IF !QUJ->(dbSeek(xFilial("QUJ")+M->QUE_CHKLST+M->QUE_REVIS+M->QUE_CHKITE+M->QUE_NUMAUD))
				Help("",1,"Q120CHKNAS") 
		 		lRetorno := .F.
		   	EndIf                                            
		EndIf
		
	EndIf
	
EndIf

If lHelp
	Help("",1,"NEXISTCHK")
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qad120Qau  ³ Autor ³ Wagner Mobile Costa  ³ Data ³29/06/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o questionario tem auditorias associadas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qad120Qau()		 							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qad120Qau()

Local lRet  := .T., nAberto := nEncerrado := nUsuario := 0

QUJ->(DbSetOrder(2))

// Caso tenha o CHECK-LIST informado em alguma auditoria faco verificacoes

If QUJ->(DbSeek(xFilial("QUJ") + QUE->QUE_CHKLST + QUE->QUE_REVIS + QUE->QUE_CHKITE + QUE->QUE_NUMAUD))
	QUJ->(DbSetOrder(1))
	DbSelectArea("QUJ")

// Verifico se o usuario eh Auditor em uma das areas ou Auditor lider em uma auditoria
// Desse CHECK-LIST que esteja em aberto
	
	cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " +;
				RetSqlName("QUJ") + " QUJ, " +;
				RetSqlName("QUH") + " QUH, " +;
				RetSqlName("QUB") + " QUB WHERE " +;
				"QUJ_FILIAL = '" + xFilial("QUJ") + "' AND QUJ_CHKLST = '"+;
				QUE->QUE_CHKLST + "' AND QUJ_REVIS = '" + QUE->QUE_REVIS +;
				"' AND QUJ_CHKITE = '" + QUE->QUE_CHKITE + "' AND " +;
				"QUJ.D_E_L_E_T_ = ' ' AND QUH_FILIAL = '" + xFilial("QUH") +;
				"' AND QUH.QUH_NUMAUD = QUJ_NUMAUD AND QUH.QUH_SEQ = QUJ_SEQ AND "+;
				"QUH.D_E_L_E_T_ = ' ' AND "+;
				"QUB_FILIAL = '" + xFilial("QUB") + "' AND " +;
				"QUB_NUMAUD = '" + QUE->QUE_NUMAUD + "' AND "+;
				"QUB_NUMAUD = QUJ.QUJ_NUMAUD AND "+;
				"((QUH_FILMAT = '" + cMatFil + "' AND QUH_CODAUD = '" + cMatCod +;
				"') OR (QUB_FILMAT = '" + cMatFil + "' AND QUB_AUDLID = '" + cMatCod +;
				"')) AND QUB_ENCREA = ' ' AND QUB.D_E_L_E_T_ = ' '"
	cFiltro := ChangeQuery(cFiltro)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "QRYQUJ", .F., .T.)
	lRet := CONTADOR > 0
	DbCloseArea()

	If ! lRet

// Caso nao seja verifico se existem auditorias encerradas para esse CHECK-LIST

		cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " +;
					RetSqlName("QUJ") + " QUJ, " +;
					RetSqlName("QUB") + " QUB WHERE " +;
					"QUJ_FILIAL = '" + xFilial("QUJ") + "' AND QUJ_CHKLST = '"+;
					QUE->QUE_CHKLST + "' AND QUJ_REVIS = '" + QUE->QUE_REVIS +;
					"' AND QUJ_CHKITE = '" + QUE->QUE_CHKITE + "' AND " +;
					"QUJ_NUMAUD = '" + QUE->QUE_NUMAUD + "' AND "+;
					"QUJ.D_E_L_E_T_ = ' ' AND " +;
					"QUB_FILIAL = '" + xFilial("QUB") + "' AND " +;
					"QUB_NUMAUD = QUJ.QUJ_NUMAUD AND "+;
					"QUB_ENCREA <> ' ' AND QUB.D_E_L_E_T_ = ' '"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "QRYQUJ", .F., .T.)
		lRet :=	CONTADOR > 0
		DbCloseArea()

            If lRet

// Caso tenha auditorias encerradas verifico se nao existem auditorias em aberto para esse CHECK-LIST

			cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " +;
						RetSqlName("QUJ") + " QUJ, " +;
						RetSqlName("QUB") + " QUB WHERE " +;
						"QUJ_FILIAL = '" + xFilial("QUJ") + "' AND QUJ_CHKLST = '"+;
						QUE->QUE_CHKLST + "' AND QUJ_REVIS = '" + QUE->QUE_REVIS +;
						"' AND QUJ_CHKITE = '" + QUE->QUE_CHKITE + "' AND " +;
						"QUJ_NUMAUD = '" + QUE->QUE_NUMAUD + "' AND "+;
						"QUJ.D_E_L_E_T_ = ' ' AND " +;
						"QUB_FILIAL = '" + xFilial("QUB") + "' AND " +;
						"QUB_NUMAUD = QUJ.QUJ_NUMAUD AND "+;
						"QUB_ENCREA = ' ' AND QUB.D_E_L_E_T_ = ' '"

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "QRYQUJ", .F., .T.)
			lRet := CONTADOR = 0
			DbCloseArea()
		Endif
	Endif
Endif
QUJ->(DbSetOrder(1))


DbSelectArea("QUE")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA120All³ Autor ³ Telso Carneiro        ³ Data ³21/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a Validacao na Confirmacao do Questionario		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA120All()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QADA120All()
Local lRetorno := .T.

If 	(M->QUE_FAIXFI - M->QUE_FAIXIN) <= 0
	Help(" ",1,"QU4NOTA")		
	lRetorno := .F.
Endif		

Return(lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q120CHLIST³ Autor ³ Renata Cavalcante     ³ Data ³06/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³De acordo com a rotina selecionada,exibe a consulta(F3)-QUE ³±±          ³				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Consulta especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QIEA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120CHLIST()
Local lRet:= .F.
Private cChkLst := "ß"
Q120FilChk(M->QUE_NUMAUD)
If Alltrim(FunName())<>"LERDA" .and. Alltrim(Funname()) <> "MPVIEW" .And. Alltrim(Funname()) <> "EDAPP"
	lRet := ConPad1(,,,"QUE",,,.F.)	
Endif

Return lRet                                                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QADA120   ºAutor  ³Microsiga           º Data ³  02/25/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD120GAT(nCpo)         
Local aArea:= GetArea()        
Local cRet := ""

DbSelectArea("QUJ") 
	cArquivo := CriaTrab(,.F.)

	cChave := "QUJ_FILIAL+QUJ_NUMAUD+QUJ_CHKLST+QUJ_REVIS"

	IndRegua("QUJ",cArquivo,cChave,,)

	DbSelectArea("QUJ")

	nIndex := RetIndex("QUJ")

	DbSetOrder(nIndex+1)
	If nCpo == 1	
		If DbSeek(xFilial("QUJ")+M->QUE_NUMAUD+M->QUE_CHKLST)
			cRet:=QUJ->QUJ_REVIS
		Endif 
	Else
		If DbSeek(xFilial("QUJ")+M->QUE_NUMAUD+M->QUE_CHKLST+M->QUE_REVIS)
			cRet:=QUJ->QUJ_CHKITE
		Endif 
	Endif 
	
RestArea(aArea)
Return(cRet)
