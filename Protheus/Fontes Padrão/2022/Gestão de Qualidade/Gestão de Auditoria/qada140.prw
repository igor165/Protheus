#include "PROTHEUS.CH"
#include "QADA140.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140   ³Autor  ³Marcelo Iuspa          ³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Encerramento da Auditoria                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQAD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³02/02/01³------³Alterado programa para que seja efetuada a³±±
±±³            ³	    ³      ³rolagem de Tela na Conclusao da Auditoria,³±±
±±³            ³	    ³      ³quando estiver sendo acessada a Opcao de  ³±±
±±³            ³	    ³      ³Visualizacao.							  ³±±
±±³Paulo Emidio³09/04/01³      ³Criacao do MV_QADQNC.					  ³±±
±±³Robson Ramir³14/05/02³ Meta ³Alteracao do alias da familia QU para QA  ³±±
±±³Robson Ramir³14/06/02³ Meta ³Alteracao da estrutura da tela para padrao³±±
±±³            ³        ³      ³enchoice e melhorias                      ³±±
±±³            ³        ³      ³Troca de campo caracter para memo         ³±±
±±³Eduardo S.  ³14/10/02³------³Alterado para apresentar 4 fases de status³±±
±±³Eduardo S.  ³21/10/02³------³Alterado para verificar o campo QAA_LOGIN ³±±
±±³            ³        ³      ³no lugar do campo QAA_APELID.             ³±±
±±³Eduardo S.  ³28/11/02³------³Alterado para permitir somente o acesso de³±±
±±³            ³        ³      ³Auditores envolvidos na Auditoria.        ³±±
±±³Eduardo S.  ³10/01/03³------³Alterado para permitir pesquisar usuarios ³±±
±±³            ³        ³      ³ entre filiais na consulta padrao.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina := {{STR0001,"AxPesqui"      ,0,1,,.F.},;    //"Pesquisar" 
					 {STR0002,"QADA140ATU"    ,0,2},;      //"Visualizar"
					 {STR0003,"QADA140ATU"    ,0,4},;      //"Encerrar " 
					 {STR0004,"QADA140Legenda",0,5,,.F.}}  //"Legenda"   

Return aRotina

Function QADA140()

Local aCores := {}
					 
PRIVATE cCadastro := OemToAnsi(STR0005) //"Encerramento de Auditorias"
Private cFilMat   := cFilAnt

PRIVATE aRotina := MenuDef()

//Avisa o cliente sobre as atualizações que serão realizadas no SIGAQAD.
//QAvisoQad()

aCores:=	{{'QUB->QUB_STATUS == "1"','ENABLE'    },;
			{ 'QUB->QUB_STATUS == "2"','BR_AMARELO'},;
			{ 'QUB->QUB_STATUS == "3"','BR_PRETO'  },;
			{ 'QUB->QUB_STATUS == "4"','DISABLE'   }}

mBrowse( 6, 1,22,75,"QUB",,,,,,aCores)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140Atu³ Autor ³ Marcelo Iuspa			³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao do encerramento da Auditoria					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA140Atu(cAlias,nReg,nOpc)				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA140Atu(cAlias,nReg,nOpc)
Local oDlg
Local nMin
Local nMax 
Local nPeso
Local nPontos 	 := 0
Local nPesoTotal := 0
Local lOk     	 := .F.
Local nSemAval	 := 0
Local lQ140ATU	 := ExistBlock("QAD140AT") 
Local lQ140FIM   := ExistBlock("QAD140FI")   // Unimed
Local lQ140ATC   := ExistBlock("QAD140AC")
Local lRetQ140    
Local lIntQNC	 := GetMv("MV_QADQNC") //Integracao com o QNC
Local lVerEvid	 := GetMv("MV_QADEVI") //Indica se as Evidencias devem ser obrigatorias
Local lContinua	 := .T.
Local aCpos	     := {}
Local aRet	     := {}
Local aCpoAlt	 := {}
Local cTxtEvi    := ''             
Local lQstZer    := GetMv("MV_QADQZER",.T.,.T.)
Local lAltern    := .F.
Local nNota      := 0  
Local lEnNEmail  := GetMV("MV_QADENAE",.F.,"1")=="1" //Envia e-mail no Encerramento da Auditoria (1=SIM 2=NAO)
Local lRet       :=.T. 
Local aSize    	:= MsAdvSize()
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
local aPosObj   := MsObjSize(aInfo,{},.T.)
Local oStruQUB
Local nX

Private nQAConpad:= 2
Private aGets    := {}
Private aTela    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc > 2 .Or. (nOpc = 2 .And. Empty(QUB->QUB_ENCREA))
	If !QADCkAudit(QUB->QUB_NUMAUD)
		Return(NIL)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara variaveis para enchoice  							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QUB",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos que serao editados na Enchoice			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {}
oStruQUB := FWFormStruct(3, "QUB")

For nX := 1 to Len(oStruQUB[3])
	If !AllTrim(oStruQUB[3][nX][1]) $ "QUB_DESCHV/QUB_OK/QUB_CHAVE/QUB_SUGCHV/QUB_STATUS"
		aAdd(aCpos, oStruQUB[3][nX][1])
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para permitir que o usuário manipule os campos que    ³
//³ serão apresentados na tela de encerramento da auditoria.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                       

If ExistBlock("QD140Cpo")
 	aRet := ExecBlock("QD140Cpo",.F.,.F.,{aCpos})
 	If ValType(aRet) == "A"
 	   aCpos := AClone(aRet)
 	EndIf   
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita campos do usuario que podem ser alterados na tela             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQ140ATC
	aCpoAlt := aClone(ExecBlock("QAD140AC",.F.,.F.))
Endif  

//Preenche os campos que serao alterados
Aadd(aCpoAlt,"QUB_ENCREA")
Aadd(aCpoAlt,"QUB_CONCLU")

//Campo para Observacoes/Sugestoes sobre a Auditoria realizada

Aadd(aCpoAlt,"QUB_SUGOBS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza as validacoes somente na opcao de encerramento		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se a auditoria está encerrada. Se encerrada, retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(QUB->QUB_ENCREA)
		Help(" ",1,"AUDITENC")	
		Return(.F.)
	Endif	
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vou travar o arquivo para evitar dois usuários alterando     ³
	//³ simultaneamente a mesma auditoria...						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SoftLock("QUB")
		Help(" ",1,"QUBLOCK")	
		Return(.F.)  	
	Endif	                      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os Parametros de Integracao QNC     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lIntQNC .AND. !QNCMSGERA(STR0023)  //"no Parametro MV_QADQNC"
		Return(NIL)
	ENDIF            

	QAA->(dbSetOrder(1))
	QAA->(dbSeek(QUB->QUB_FILMAT+QUB->QUB_AUDLID))
	If QAA->(!Eof())
		If Upper(QAA->QAA_LOGIN) # Upper(cUserName)
			Help("",1,"Q140AUDLID")
			Return(.F.)
		EndIf
	EndIf

	dbSelectArea("QUD")
	dbSeek(cSeek := xFilial("QUD") + QUB->QUB_NUMAUD)
	While !Eof() .and. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == cSeek

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a questao foi considerada 1=SIM 2=NAO             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If QUD->QUD_APLICA == "2"
			dbSkip()
			Loop
		Endif
		
		If nOpc == 3
			If lVerEvid
				cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
				If Empty(cTxtEvi)
					Help("",1,"QEVIDENCIA")	 
					lContinua := .F.
					Exit
			    EndIf
			EndIf
		EndIf
	        
		cChave := QUD->QUD_CHKLST + QUD->QUD_REVIS + QUD->QUD_CHKITE + QUD->QUD_QSTITE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ QUD_TIPO = 1) Padrao 										 ³
		//³			   2) Adicional 									 ³
		//³            3) Unica										     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QUD->QUD_TIPO = "2"    
			QUE->(dbSeek(xFilial("QUE") + QUD->QUD_NUMAUD + cChave))
			nMin    := QUE->QUE_FAIXIN
			nMax    := QUE->QUE_FAIXFI
			nPeso   := If(QUE->QUE_PESO==0,1,QUE->QUE_PESO)
			lAltern := If(QUE->QUE_USAALT=="1",.T.,.F.)
		Else
			QU4->(dbSeek(xFilial("QU4") + cChave))
			nMin    := QU4->QU4_FAIXIN
			nMax    := QU4->QU4_FAIXFI
			nPeso   := If(QU4->QU4_PESO==0,1,QU4->QU4_PESO)
			lAltern := If(QU4->QU4_USAALT=="1",.T.,.F.)
		Endif	                                       
           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota informada na questao Alternativa e igual  ³
		//³ a Faixa Inicial, se o MV_QADQZER for igual a .T., a nota da  ³
		//³ questao sera sugerida como Zero para efeito de calculo.      ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    nNota := QUD->QUD_NOTA 
		If lQstZer .And. lAltern
			If nNota == nMin
				nNota := 0
			EndIf	
		EndIf
		
		nSemAval   += If(Empty(QUD->QUD_DTAVAL), 1, 0)
		nPontos	   += (((nNota * nPeso)*100)/nMax)
		nPesoTotal += (nPeso)
		dbselectarea("QUD")
		dbSkip()
	Enddo	     
	
	If lContinua 
		M->QUB_PONOBT := nPontos / nPesoTotal
		
		If nSemAval > 0
			Help(" ",1,"QUDDTAVAL")	
			Return(.F.)
		Endif	
	EndIf
	
EndIf

If !lContinua 
	Return(NIL)
EndIf

If nOpc == 3
	If lQ140Atu
		If !(lRetq140 := ExecBlock("QAD140AT",.F.,.F.))
			Return(NIL)
		EndIf
	EndIf	
EndIf


DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL

EnChoice("QUB",nReg,nOpc,,,,aCpos,{033,003,aSize[4],aSize[3]},aCpoAlt,,,,)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := Obrigatorio(aGets,aTela), If(lOk,oDlg:End(),)},{||oDlg:End()}, ,)

If lOk
	If nOpc == 3
		Begin Transaction
		
			RecLock("QUB", .F.)
			QUB->QUB_PONOBT := M->QUB_PONOBT 
			QUB->QUB_ENCREA := M->QUB_ENCREA
			QUB->QUB_STATUS:= "4"             // Auditoria Encerrada
			MsUnlock()
			FKCOMMIT()
		
			MsMM(QUB_CHAVE,,,M->QUB_CONCLU,1,,,"QUB","QUB_CHAVE")

			//Observacoes/Sugestoes sobre a Auditoria realizada
			MsMM(QUB_SUGCHV,,,M->QUB_SUGOBS,1,,,"QUB","QUB_SUGCHV")			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a Integracao com o Modulo de Nao-Conformidades			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntQNC 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de Entrada Gerar ou Nao a FNC                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("QDAGRFNC")
					lRet:=ExecBlock("QDAGRFNC", .F., .F.)
				EndIf
				If lRet 
			  		QADA140GNC(M->QUB_NUMAUD)
			  	EndIf                         
			EndIf
			
		End Transaction		  			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica as Nao-Conformidades e direciona para as areas envolvidas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lEnNEmail
			Qada140Mail(M->QUB_NUMAUD)
		Endif	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada criado para atualizar outras tabelas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock( "QADENCAU" )
			ExecBlock( "QADENCAU", .f., .f. )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama ponto de antrada apos todas as atualizacoes        		 ³
		//³ Unimed                                                   		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If  lQ140Fim                           
		    ExecBlock("QAD140FI",.F.,.F.)     
		EndIf                                  
		
	EndIf			
Endif	
                  
DbSelectArea("QUB")
MsUnLock()
                  
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140Vld³ Autor ³ Marcelo Iuspa			³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do encerramento								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA140Vld(EXPD1,EXPN1) 					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExPN1 = Opcao selecionada no aRotina						  ³±± 
±±³          ³  														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADA140Vld(nOpc)

If nOpc == 3
	If Empty(M->QUB_ENCREA)
		Help("",1,"QUBENCREA")
		Return(.F.)
	Endif                       
	If Empty(M->QUB_CONCLU)
		Help("",1,"QUBCONCLU") 
		Return(.F.)
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140Legenda³ Autor ³ Marcelo Iuspa		³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda das Auditorias					 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA140Legenda()	    					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADA140Legenda()

BrwLegenda(cCadastro,STR0010, {	{"ENABLE"    ,STR0021 },; // "Auditorias" ### "Sem Resultado"
   						       	{"BR_AMARELO",STR0019 },; // "Resultados Parcialmente Respondido"
   						       	{"BR_PRETO"  ,STR0020 },; // "Liberada para Encerramento"
   						       	{"DISABLE"   ,STR0012 }}) // "Encerrada"

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140Mail   ³ Autor ³ Marcelo Iuspa		³ Data ³19/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Envio de e-mail comunicando as areas envolvidas			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA140Mail(cNumAud)    					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QADA140Mail(cNumAud)
Local cSeekNC
Local cEmail
Local cSubject  := OemToAnsi(STR0022) // "Encerramento da Auditoria"
Local aUserMail := {}
Local cCpyUsr   := ""
Local lQ140MAIL := ExistBlock("Q140MAIL")
Local aText     := {}
Local cMail     := AllTrim(Posicione("QAA", 1, M->QUB_FILMAT+M->QUB_AUDLID,"QAA_EMAIL"))	// E-Mail Auditor Lider
Local nCont		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia copia para os envolvidos na Auditoria						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QUI->(dbSetOrder(1))
QUI->(dbSeek(xFilial("QUI")+cNumAud))
While QUI->(!Eof()) .And. QUI->QUI_FILIAL == xFilial("QUI") .And.;
	QUI->QUI_NUMAUD == cNumAud   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso haja o mesmo endereco, este nao sera considerado            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr)	== 0
		cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUI->QUI_EMAIL)+";"
	EndIf		
	QUI->(dbSkip())	
	
EndDo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia copia para os auditores envolvidos na Auditoria			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QUC->(dbSetOrder(1))
QUC->(dbSeek(xFilial("QUC")+cNumAud))
While QUC->(!Eof()) .And. QUC->QUC_FILIAL == xFilial("QUC") .And.;
	QUC->QUC_NUMAUD == cNumAud   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso haja o mesmo endereco, este nao sera considerado            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr)	== 0
		cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUC->QUC_EMAIL)+";"
	EndIf		
	QUC->(dbSkip())	
	
EndDo	
If SubStr(cCpyUsr,Len(cCpyUsr),1)==";"
	cCpyUsr := SubStr(cCpyUsr,1,Len(cCpyUsr)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia os emails referentes as areas auditadas e para os auditores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QUH->(dbSetOrder(1))
QUH->(dbSeek(xFilial("QUH")+cNumAud))
While QUH->(!Eof()) .And. QUH->QUH_FILIAL == xFilial("QUH") .And. QUH->QUH_NUMAUD == cNumAud
	
	cSeekNC  := QUH->(QUH_NUMAUD+QUH_SEQ)
	
	FOR nCont:=1 TO 2
		IF nCont == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³e-mail da Area Auditada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEmail:= QUH->QUH_EMAIL
		ElseIF nCont == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³e-mail do Auditor³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEmail:=""
			QAA->(dbSetOrder(1))
			If QAA->(MsSeek(QUH->QUH_FILMAT+QUH->QUH_CODAUD))
				If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
					cEmail:=QAA->QAA_EMAIL
				Endif
			Endif
		ENDIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta e-mail do Encerramento da Auditoria em Html. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg:= Q100AudMail(2,cSubject, Nil, 2)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o Ponto de Entrada Q140MAIL, dever ser retornado o texto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQ140MAIL
			aText := ExecBlock("Q140MAIL",.F.,.F.,{cSeekNC,cSubject})
			
			If aText[1] # NIL
				cMsg:= aText[1]
			EndIf
			
			If aText[3] # NIL
				cSubject += aText[3]
			EndIf
		EndIf
		
		If !Empty(cEmail)
			Aadd(aUserMail,{cEmail,cSubject,cMsg,""})
		EndIf
	Next
	
	QUH->(dbSkip())
EndDo

If 	At(cMail,cCpyUsr) == 0 .And.;	// Verifica se o auditor lider
	Ascan(aUserMail, { |x| Upper(Trim(x[1])) == Upper(cMail) }) = 0	// ja teve o e-mail incluido
	cCpyUsr := AllTrim(cCpyUsr)+";"+cMail
EndIf		

If !Empty(cCpyUsr)
	Aadd(aUserMail,{cCpyUsr,cSubject,cMsg,""})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a conexao e o envio dos emails							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSendMail := {||QaudEnvMail(aUserMail,,,,.T.)}
cTitle    := STR0016 //"Envio de e-mail"
cMessage  := STR0017 //"Enviando e-mail comunicando o encerramento da Auditoria."
MsgRun(cMessage,cTitle,bSendMail)

Return(NIL)                                     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADA140GNC ³ Autor ³ Paulo Emidio de Barros ³ Data ³19/10/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a integracao das NC,s com o QNC					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADA140GNC(EXPC1)    					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = numero da Auditoria								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QADA140GNC(cNumAud)
Local aCpoQNC 
Local aRetQNC
Local cSeek  
Local aMatCod   := QA_Usuario()
Local cResFil   := AllTrim(GetNewPar("MV_QNCFRES",""))	//Filial do Responsavel
Local cResMat   := AllTrim(GetNewPar("MV_QNCMRES",""))	//Matricula do Responsavel 
Local lQADGRFNC := ExistBlock("QADGRFNC")
Local aRetrQNC   := {}


 

dbSelectArea("QUG")
dbSetOrder(2)
cSeek:=xFilial("QUG")+cNumAud                                                                      
dbSeek(cSeek)
While QUG->(!Eof()) .And. (QUG->QUG_FILIAL+QUG->QUG_NUMAUD) == cSeek .And. QUG->QUG_ACACOR == '1'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza integracao com o QNC         						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpoQNC := {}
	Aadd(aCpoQNC,{"QI2_MEMO1",MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])})
	Aadd(aCpoQNC,{"QI2_OCORRE",QUG->QUG_OCORNC})
	Aadd(aCpoQNC,{"QI2_CONPRE",QUG->QUG_OCORNC+QUG->QUG_PRAZO})
	Aadd(aCpoQNC,{"QI2_DESCR" ,STR0018+AllTrim(QUG->QUG_NUMAUD)+" - "+QUG->QUG_SEQ}) //"NAO-CONFORMIDADE REFERENTE AUDITORIA "
	Aadd(aCpoQNC,{"QI2_TPFIC" ,"2"})
	Aadd(aCpoQNC,{"QI2_PRIORI",QUG->QUG_CATEG})
	Aadd(aCpoQNC,{"QI2_MEMO2" ,"CHECK LIST "+QUG->QUG_CHKLST+" - "+QUG->QUG_REVIS+" - "+QUG->QUG_CHKITE+" - "+QUG->QUG_QSTITE})
	Aadd(aCpoQNC,{"QI2_ORIGEM","QAD"})
	Aadd(aCpoQNC,{"QI2_CODFOR",QUB->QUB_CODFOR})
	Aadd(aCpoQNC,{"QI2_LOJFOR",QUB->QUB_LOJA})
	Aadd(aCpoQNC,{"QI2_FILMAT",aMatCod[2]})
	Aadd(aCpoQNC,{"QI2_MAT"   ,aMatCod[3]})      
	Aadd(aCpoQNC,{"QI2_MATDEP",aMatCod[4]})
	Aadd(aCpoQNC,{"QI2_FILRES",IIf(Empty(cResFil),aMatCod[2],cResFil)})	//Filial do Responsavel
	Aadd(aCpoQNC,{"QI2_MATRES",IIf(Empty(cResMat),aMatCod[3],cResMat)})	//Matricula do Responsavel
	Aadd(aCpoQNC,{"QI2_ORIDEP",aMatCod[4]})
	Aadd(aCpoQNC,{"QI2_NUMAUD",QUG->QUG_NUMAUD})

	If lQADGRFNC
		aRetrQNC:=ExecBlock("QADGRFNC", .F., .F.,{aCpoQNC}) 
		If ValType(aRetrQNC)=="A" .And. !Empty(aRetrQNC) 
		    aCpoQNC := aRetrQNC
		EndIf
	EndIf
	
		aRetQNC := QNCGERA(1,aCpoQNC)
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Codigo+Revisao da NC								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("QUG",.F.)
		QUG->QUG_CODNC := aRetQNC[2] //Codigo da Nao-conformidade
		QUG->QUG_REVNC := aRetQNC[3] //Revisao da Nao-conformidade				
		MsUnLock()    
		FKCOMMIT()
	    QUG->(dbSkip())
	    
    
EndDo
	
Return(NIL)
