#INCLUDE "PROTHEUS.CH"
#INCLUDE "QADA030.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QADA030  ³ Autor ³ Marcelo Iuspa			³ Data ³ 19/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Perguntas									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQAD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³18/12/00³------³Foram ajustados e complementados os STR's ³±±
±±³            ³	    ³      ³e os arquivos CH's, para que os mesmos pos³±±
±±³            ³	    ³      ³sam ser traduzidos.						  ³±±
±±³Robson Ramir³10/06/02³ Meta ³Alteracao da estrutura da tela para padrao³±±
±±³            ³        ³      ³enchoice e melhorias, alteracao de alguns ³±±
±±³            ³        ³      ³campos caracter para memo                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()



Local aRotina := {{STR0001, "AxPesqui"	, 0, 1,,.F.},;	//"Pesquisar"
				 {STR0002, "QADA030ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QADA030ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QADA030ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QADA030ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QADA030()

Local aUsrMat	:= QA_USUARIO()
Local lSoLider	:= GetMv("MV_AUDSLID", .T., .F.)
Private cMatFil	:= aUsrMat[2]
Private cMatCod	:= aUsrMat[3]
PRIVATE cCadastro := OemToAnsi(STR0006) //"Questionario"

PRIVATE aRotina := 	MenuDef()

//Avisa o cliente sobre as atualizações que serão realizadas no SIGAQAD.
//QAvisoQad()

If lSoLider
	DbSelectArea("QUH")
	DbSetOrder(1)

	DbSelectArea("QUJ")
	DbSetOrder(2)	
Endif
DbSelectArea("QU4")
DbSetOrder(1)
If lSoLider
	Set Filter To &("Qad030Qau()")
Endif

mBrowse( 6, 1,22,75,"QU4")

DbSelectArea("QU4")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA030Atu³ Autor ³ Marcelo Iuspa			³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Questionario								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA030Atu(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA030Atu(cAlias,nReg,nOpc)
Local oDlg
Local bCampo := { |nCPO| Field(nCPO) }
Local nCont   
Local aSize    	:= MsAdvSize()
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
local aPosObj   := MsObjSize(aInfo,{},.T.)
Local aAcho     := {"QU4_CHKLST", "QU4_REVIS", "QU4_CHKITE", "QU4_QSTITE", "QU4_TXTQS1", "QU4_OBSER1",;
                    "QU4_REQQS1", "QU4_FAIXIN", "QU4_FAIXFI", "QU4_ULTREV", "QU4_PESO", "QU4_USAALT"}

Private aTela := {}
Private aGets := {}
Private lOk   := .F.

If (nOpc == 4 .Or. nOpc == 5)
	If !QADChkEfet(QU4->QU4_CHKLST+QU4->QU4_REVIS,.F.)
		Return(.F.)
	Endif
EndIf

DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL
RegToMemory("QU4",(nOpc==3))

EnChoice("QU4",nReg,nOpc,,,, aAcho,{027,003,aSize[4],aSize[3]},,)
If (nOpc # 2)              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela) .And. QADA030All(),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
EndIf	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a gravacao dos Dados			             			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (!lOk) .Or. nOpc == 2
	Return NIL
Endif
	
If nOpc == 5
	Begin Transaction
		//Realiza a exclusao do Texto da Questao
		MsMM(QU4->QU4_TXTCHV,,,,2,,,,)
		
		//Realiza a exclusao do Requisito da Questao
		MsMM(QU4->QU4_REQCHV,,,,2,,,,)
		
		//Realiza a exclusao da Observacao da Questao
		MsMM(QU4->QU4_OBSCHV,,,,2,,,,)
		
		RecLock("QU4", .F., .T.)
		dbDelete()
		MsUnLock()
	End Transaction
	
	Return NIL
EndIf

If Inclui
	If QU4->(dbSeek(xFilial("QU4")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE+M->QU4_QSTITE))
		If !(QADA030Next())
			Help(" ",1,"QU4ALTNQST")
		Endif
	Endif
Endif
DbSelectArea("QU4")
QU4->(DbGoto(nReg))

Begin Transaction
	RecLock("QU4",(nOpc == 3),.T.)
	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QU4"))
		Elseif ALLTRIM(UPPER(Field(nCont)))=="QU4_PESO"
			FieldPut(nCont,If(M->&(EVAL(bCampo,nCont))==0,1,M->&(EVAL(bCampo,nCont))))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont
	MsUnlock()                  
	FKCOMMIT()
	
	//Realiza a gravacao do Texto da Questao
	MsMM(,TamSX3('QU4_TXTQS1')[1],,M->QU4_TXTQS1,1,,,'QU4','QU4_TXTCHV')
	
	//Realiza a gravacao do Requisito da Questao
	MsMM(,TamSX3('QU4_REQQS1')[1],,M->QU4_REQQS1,1,,,'QU4','QU4_REQCHV')
	
	//Realiza a gravacao da Observacao da Questao
	MsMM(,TamSX3('QU4_OBSER1')[1],,M->QU4_OBSER1,1,,,'QU4','QU4_OBSCHV')  
	If Existblock ("QD030TOK")
		Execblock("QD030TOK",.F.,.F.,{QU4->QU4_FILIAL,QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE})
	Endif


End Transaction

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA030Vld³ Autor ³ Marcelo Iuspa			³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes no Questionario						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA030Vld()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA030Vld()
Local lRetorno := .T.
Local lHelp    := .F.

If !Empty(M->QU4_CHKLST) 

	QU3->(dbSetOrder(1))
	If QU3->(!dbSeek(xFilial("QU3")+M->QU4_CHKLST))
		lRetorno := .F.
		lHelp    := .T.
    EndIf  
    
	If !Empty(M->QU4_REVIS) .And. lRetorno
		If QU3->(!dbSeek(xFilial("QU3")+M->QU4_CHKLST+M->QU4_REVIS))
			lRetorno := .F.
			lHelp    := .T.
		Else
			If !QADChkEfet(M->QU4_CHKLST+M->QU4_REVIS,.F.)
				lRetorno := .F.
			EndIf	
	    EndIf
	    
		If !Empty(M->QU4_CHKITE) .And. lRetorno
			If QU3->(!dbSeek(xFilial("QU3")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE))
				lRetorno := .F.
				lHelp    := .T.
            EndIf
		EndIf
	EndIf		
EndIf

If lHelp
	Help(" ",1,"QU4CHKNEXI")	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA030All³ Autor ³ Paulo Emidio de Barros³ Data ³02/07/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a Validacao na Confirmacao do Questionario		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA030All()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA030All()
Local cTitFxFin := AllTrim(GetSX3Cache("QU4_FAIXFI","X3_TITULO"))
Local cTitFxIni := AllTrim(GetSX3Cache("QU4_FAIXIN","X3_TITULO"))
Local lRetorno  := .T.

If lRetorno .AND. Empty(AllTrim(M->QU4_TXTQS1))
	Help(" ",1,"QU4SEMTEXT")
	lRetorno := .F.
Endif

IF lRetorno .AND. EMPTY(M->QU4_USAALT)
	Help(" ",1,"OBRIGAT")
	lRetorno := .F.
Endif

If lRetorno
	If M->QU4_USAALT == '1' //Usa Alternativa 1-Sim

		If !IIf(M->QU4_FAIXFI > 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXIN > 0,.T.,.F.), IIf(M->QU4_FAIXIN > 0,.T.,.F.)) 
			Help(NIL, NIL, cTitFxIni, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) //"Faixa Inicial inválida."###"Não é permitido informar a faixa inicial menor ou igual a zero, a faixa inicial maior que a faixa final, ou as duas faixas iguais quando o campo Alternativa esta 1-Sim."
			Return .F.
		EndIf

		If !IIf(M->QU4_FAIXIN > 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXFI > 0,.T.,.F.), IIf(M->QU4_FAIXFI > 0,.T.,.F.))
			Help(NIL, NIL, cTitFxFin, NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010}) //"Faixa Final inválida."###"Não é permitido informar a faixa final menor ou igual a zero, a faixa inicial maior que a faixa final, ou as duas faixas iguais quando o campo Alternativa esta 1-Sim."
			Return .F.
		EndIf

	Else //Usa Alternativa 2-Não

 		If M->QU4_FAIXIN == M->QU4_FAIXFI .Or. ; //- A faixa inicial e faixa final não podem ser iguais.
		   M->QU4_FAIXIN < 0              .Or. ; //- A faixa inicial não pode ser menor que zero. 
		   M->QU4_FAIXIN >= M->QU4_FAIXFI .Or. ; //- A faixa inicial não pode ser maior que a faixa final. 
		   M->QU4_FAIXFI == 0                    //- A faixa final não pode ser igual a zero.
			Help(NIL, NIL, cTitFxIni + ', ' + cTitFxFin, NIL, STR0013, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014}) //"Faixa Final ou Inicial inválida."###"Não é permitido informar a faixa final menor ou igual zero, a faixa inicial maior que a faixa final ou as duas faixas iguais quando o campo Alternativa esta 2-Não."
			Return .F.
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA030Next³ Autor ³ Marcelo Iuspa	    ³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ retorna o proximo numero da questao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA030Next()									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA030Next()
Local aSavQU4  := QU4->(GetArea())
Local lRetorno := .T. 
Local nChkLst  := 0            

If !Empty(M->QU4_CHKLST) .And. !Empty(M->QU4_REVIS)  .And.!Empty(M->QU4_CHKITE) 
	QU4->(dbSetOrder(1))
	If !QU4->(dbSeek(xFilial("QU4")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE))
		nChkLst ++
		M->QU4_QSTITE := StrZero(nChkLst,Len(QU4->QU4_QSTITE))
	Else
		While !QU4->(Eof()) .And. (QU4->QU4_FILIAL+QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE)==;
			(xFilial("QU4")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE)
			nChkLst ++
			IF Val(QU4->QU4_QSTITE) <> nChkLst			
				nChkLst--
				Exit
			Endif	
			QU4->(dbSkip())
		EndDo      
		M->QU4_QSTITE := StrZero((nChkLst+1),Len(QU4->QU4_QSTITE))
	Endif
EndIf   

RestArea(aSavQU4)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qad030Qau  ³ Autor ³ Wagner Mobile Costa  ³ Data ³26/06/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o questionario tem auditorias associadas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qad030Qau()		 							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qad030Qau()

Local lRet  := .T.

QUJ->(DbSetOrder(2))

// Caso tenha o CHECK-LIST informado em alguma auditoria faco verificacoes

If QUJ->(DbSeek(xFilial("QUJ") + QU4->QU4_CHKLST + QU4->QU4_REVIS + QU4->QU4_CHKITE))
	QUJ->(DbSetOrder(1))
	DbSelectArea("QUJ")

// Verifico se o usuario eh Auditor em uma das areas ou Auditor lider em uma auditoria
// Desse CHECK-LIST que esteja em aberto
	
	cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " +;
				RetSqlName("QUJ") + " QUJ, " +;
				RetSqlName("QUH") + " QUH, " +;
				RetSqlName("QUB") + " QUB WHERE " +;
				"QUJ_FILIAL = '" + xFilial("QUJ") + "' AND QUJ_CHKLST = '"+;
				QU4->QU4_CHKLST + "' AND QUJ_REVIS = '" + QU4->QU4_REVIS +;
				"' AND QUJ_CHKITE = '" + QU4->QU4_CHKITE + "' AND " +;
				"QUJ.D_E_L_E_T_ = ' ' AND QUH_FILIAL = '" + xFilial("QUH") +;
				"' AND QUH.QUH_NUMAUD = QUJ_NUMAUD AND QUH.QUH_SEQ = QUJ_SEQ AND "+;
				"QUH.D_E_L_E_T_ = ' ' AND "+;
				"QUB_FILIAL = '" + xFilial("QUB") + "' AND " +;
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
					QU4->QU4_CHKLST + "' AND QUJ_REVIS = '" + QU4->QU4_REVIS +;
					"' AND QUJ_CHKITE = '" + QU4->QU4_CHKITE + "' AND " +;
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
						QU4->QU4_CHKLST + "' AND QUJ_REVIS = '" + QU4->QU4_REVIS +;
						"' AND QUJ_CHKITE = '" + QU4->QU4_CHKITE + "' AND " +;
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

DbSelectArea("QU4")

Return lRet

/*/{Protheus.doc} fValidFaix
Função executada no X3_VALID dos campos Faixa Inic.(QU4_FAIXIN) e Faixa Final(QU4_FAIXFI) para realizar as validações abaixo:
Quando a questão for alternativa, as notas da faixa não podem ser menores ou iguais a zero, não podem ser iguais, e a faixa inicial não pode ser maior que a faixa final.
Quando a questão não for alternativa, as notas das faixas não podem ser menores que zero, não podem ser iguais, e a faixa inicial não pode ser maior que a faixa final. 
@type  Function
@author rafael.kleestadt
@since 29/06/2022
@version 1.0
@param param_name, param_type, param_descr
@return true or false, logic, verdadeiro ou falso
@example
(examples)
@see https://tdn.totvs.com/x/tCtKEg
/*/
Function fValidFaix()
Local cTitFxFin := AllTrim(GetSX3Cache("QU4_FAIXFI","X3_TITULO"))
Local cTitFxIni := AllTrim(GetSX3Cache("QU4_FAIXIN","X3_TITULO"))

If M->QU4_USAALT == '1' //Usa Alternativa 1-Sim

	If READVAR() == 'M->QU4_FAIXIN' .And. !IIf(M->QU4_FAIXFI > 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXIN > 0,.T.,.F.), IIf(M->QU4_FAIXIN > 0,.T.,.F.)) 
		Help(NIL, NIL, cTitFxIni, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) //"Faixa Inicial inválida."###"Não é permitido informar a faixa inicial menor ou igual a zero, a faixa inicial maior que a faixa final, ou as duas faixas iguais quando o campo Alternativa esta 1-Sim."
		Return .F.
	EndIf

	If READVAR() == 'M->QU4_FAIXFI' .And. !IIf(M->QU4_FAIXIN > 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXFI > 0,.T.,.F.), IIf(M->QU4_FAIXFI > 0,.T.,.F.))
		Help(NIL, NIL, cTitFxFin, NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010}) //"Faixa Final inválida."###"Não é permitido informar a faixa final menor ou igual a zero, a faixa inicial maior que a faixa final, ou as duas faixas iguais quando o campo Alternativa esta 1-Sim."
		Return .F.
	EndIf

Else //Usa Alternativa 2-Não

	If READVAR() == 'M->QU4_FAIXIN' .And. !IIf(M->QU4_FAIXFI >= 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXIN >= 0,.T.,.F.), IIf(M->QU4_FAIXIN >= 0,.T.,.F.))
		Help(NIL, NIL, cTitFxIni, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011}) //"Faixa Inicial inválida."###"Não é permitido informar a faixa inicial menor que zero, a faixa inicial maior que a faixa final, ou as duas faixas iguais quando o campo Alternativa esta 2-Não."
		Return .F.
	EndIf

	If READVAR() == 'M->QU4_FAIXFI' .And. !IIf(M->QU4_FAIXIN >= 0, IIf(M->QU4_FAIXIN < M->QU4_FAIXFI .AND. M->QU4_FAIXFI >= 0,.T.,.F.), IIf(M->QU4_FAIXFI >= 0,.T.,.F.)) 
		Help(NIL, NIL, cTitFxFin, NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012}) //"Faixa Final inválida."###"Não é permitido informar a faixa final menor que zero, a faixa inicial maior que a faixa final ou as duas faixas iguais quando o campo Alternativa esta 2-Não."
		Return .F.
	EndIf

EndIf

Return .T.
