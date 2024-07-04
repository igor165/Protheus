#include "PROTHEUS.CH"
#include "QADA140.CH"
 
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140   �Autor  �Marcelo Iuspa          � Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Encerramento da Auditoria                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�02/02/01�------�Alterado programa para que seja efetuada a���
���            �	    �      �rolagem de Tela na Conclusao da Auditoria,���
���            �	    �      �quando estiver sendo acessada a Opcao de  ���
���            �	    �      �Visualizacao.							  ���
���Paulo Emidio�09/04/01�      �Criacao do MV_QADQNC.					  ���
���Robson Ramir�14/05/02� Meta �Alteracao do alias da familia QU para QA  ���
���Robson Ramir�14/06/02� Meta �Alteracao da estrutura da tela para padrao���
���            �        �      �enchoice e melhorias                      ���
���            �        �      �Troca de campo caracter para memo         ���
���Eduardo S.  �14/10/02�------�Alterado para apresentar 4 fases de status���
���Eduardo S.  �21/10/02�------�Alterado para verificar o campo QAA_LOGIN ���
���            �        �      �no lugar do campo QAA_APELID.             ���
���Eduardo S.  �28/11/02�------�Alterado para permitir somente o acesso de���
���            �        �      �Auditores envolvidos na Auditoria.        ���
���Eduardo S.  �10/01/03�------�Alterado para permitir pesquisar usuarios ���
���            �        �      � entre filiais na consulta padrao.        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

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

//Avisa o cliente sobre as atualiza��es que ser�o realizadas no SIGAQAD.
//QAvisoQad()

aCores:=	{{'QUB->QUB_STATUS == "1"','ENABLE'    },;
			{ 'QUB->QUB_STATUS == "2"','BR_AMARELO'},;
			{ 'QUB->QUB_STATUS == "3"','BR_PRETO'  },;
			{ 'QUB->QUB_STATUS == "4"','DISABLE'   }}

mBrowse( 6, 1,22,75,"QUB",,,,,,aCores)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140Atu� Autor � Marcelo Iuspa			� Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Manutencao do encerramento da Auditoria					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADA140Atu(cAlias,nReg,nOpc)				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Verifica se o Usuario Logado eh auditor nesta Auditoria.     �
//����������������������������������������������������������������
If nOpc > 2 .Or. (nOpc = 2 .And. Empty(QUB->QUB_ENCREA))
	If !QADCkAudit(QUB->QUB_NUMAUD)
		Return(NIL)
	EndIf
Endif

//��������������������������������������������������������������Ŀ
//� Prepara variaveis para enchoice  							 �
//����������������������������������������������������������������
RegToMemory("QUB",.F.)

//��������������������������������������������������������������Ŀ
//� Verifica os campos que serao editados na Enchoice			 �
//����������������������������������������������������������������
aCpos := {}
oStruQUB := FWFormStruct(3, "QUB")

For nX := 1 to Len(oStruQUB[3])
	If !AllTrim(oStruQUB[3][nX][1]) $ "QUB_DESCHV/QUB_OK/QUB_CHAVE/QUB_SUGCHV/QUB_STATUS"
		aAdd(aCpos, oStruQUB[3][nX][1])
	EndIf
Next nX

//������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para permitir que o usu�rio manipule os campos que    �
//� ser�o apresentados na tela de encerramento da auditoria.               �
//��������������������������������������������������������������������������                       

If ExistBlock("QD140Cpo")
 	aRet := ExecBlock("QD140Cpo",.F.,.F.,{aCpos})
 	If ValType(aRet) == "A"
 	   aCpos := AClone(aRet)
 	EndIf   
EndIf


//������������������������������������������������������������������������Ŀ
//� Habilita campos do usuario que podem ser alterados na tela             �
//��������������������������������������������������������������������������
If lQ140ATC
	aCpoAlt := aClone(ExecBlock("QAD140AC",.F.,.F.))
Endif  

//Preenche os campos que serao alterados
Aadd(aCpoAlt,"QUB_ENCREA")
Aadd(aCpoAlt,"QUB_CONCLU")

//Campo para Observacoes/Sugestoes sobre a Auditoria realizada

Aadd(aCpoAlt,"QUB_SUGOBS")

//��������������������������������������������������������������Ŀ
//�Realiza as validacoes somente na opcao de encerramento		 �
//����������������������������������������������������������������
If nOpc == 3

	//��������������������������������������������������������������Ŀ
	//� Verifico se a auditoria est� encerrada. Se encerrada, retorno�
	//����������������������������������������������������������������
	If ! Empty(QUB->QUB_ENCREA)
		Help(" ",1,"AUDITENC")	
		Return(.F.)
	Endif	
    
	//��������������������������������������������������������������Ŀ
	//� Vou travar o arquivo para evitar dois usu�rios alterando     �
	//� simultaneamente a mesma auditoria...						 �
	//����������������������������������������������������������������
	If !SoftLock("QUB")
		Help(" ",1,"QUBLOCK")	
		Return(.F.)  	
	Endif	                      

	//����������������������������������������������Ŀ
	//� Verifica os Parametros de Integracao QNC     �
	//������������������������������������������������
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

		//��������������������������������������������������������������Ŀ
		//�Verifica se a questao foi considerada 1=SIM 2=NAO             �
		//����������������������������������������������������������������

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
	
		//��������������������������������������������������������������Ŀ
		//� QUD_TIPO = 1) Padrao 										 �
		//�			   2) Adicional 									 �
		//�            3) Unica										     �
		//����������������������������������������������������������������
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
           
		//��������������������������������������������������������������Ŀ
		//� Verifica se a nota informada na questao Alternativa e igual  �
		//� a Faixa Inicial, se o MV_QADQZER for igual a .T., a nota da  �
		//� questao sera sugerida como Zero para efeito de calculo.      � 
		//����������������������������������������������������������������
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
			
			//������������������������������������������������������������������Ŀ
			//� Realiza a Integracao com o Modulo de Nao-Conformidades			 �
			//��������������������������������������������������������������������
			If lIntQNC 
					//���������������������������������������������������������������������������������Ŀ
					//� Ponto de Entrada Gerar ou Nao a FNC                                             �
					//�����������������������������������������������������������������������������������
				If ExistBlock("QDAGRFNC")
					lRet:=ExecBlock("QDAGRFNC", .F., .F.)
				EndIf
				If lRet 
			  		QADA140GNC(M->QUB_NUMAUD)
			  	EndIf                         
			EndIf
			
		End Transaction		  			

		//������������������������������������������������������������������Ŀ
		//�Verifica as Nao-Conformidades e direciona para as areas envolvidas�
		//��������������������������������������������������������������������
		IF lEnNEmail
			Qada140Mail(M->QUB_NUMAUD)
		Endif	

		//���������������������������������������������������������������������������������Ŀ
		//� Ponto de Entrada criado para atualizar outras tabelas                           �
		//�����������������������������������������������������������������������������������
		IF ExistBlock( "QADENCAU" )
			ExecBlock( "QADENCAU", .f., .f. )
		Endif

		//������������������������������������������������������������������Ŀ
		//� Chama ponto de antrada apos todas as atualizacoes        		 �
		//� Unimed                                                   		 �
		//��������������������������������������������������������������������
    	If  lQ140Fim                           
		    ExecBlock("QAD140FI",.F.,.F.)     
		EndIf                                  
		
	EndIf			
Endif	
                  
DbSelectArea("QUB")
MsUnLock()
                  
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140Vld� Autor � Marcelo Iuspa			� Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do encerramento								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADA140Vld(EXPD1,EXPN1) 					                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExPN1 = Opcao selecionada no aRotina						  ��� 
���          �  														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140Legenda� Autor � Marcelo Iuspa		� Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Legenda das Auditorias					 				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADA140Legenda()	    					                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADA140Legenda()

BrwLegenda(cCadastro,STR0010, {	{"ENABLE"    ,STR0021 },; // "Auditorias" ### "Sem Resultado"
   						       	{"BR_AMARELO",STR0019 },; // "Resultados Parcialmente Respondido"
   						       	{"BR_PRETO"  ,STR0020 },; // "Liberada para Encerramento"
   						       	{"DISABLE"   ,STR0012 }}) // "Encerrada"

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140Mail   � Autor � Marcelo Iuspa		� Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Envio de e-mail comunicando as areas envolvidas			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADA140Mail(cNumAud)    					                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//������������������������������������������������������������������Ŀ
//� Envia copia para os envolvidos na Auditoria						 �
//��������������������������������������������������������������������
QUI->(dbSetOrder(1))
QUI->(dbSeek(xFilial("QUI")+cNumAud))
While QUI->(!Eof()) .And. QUI->QUI_FILIAL == xFilial("QUI") .And.;
	QUI->QUI_NUMAUD == cNumAud   

	//������������������������������������������������������������������Ŀ
	//� Caso haja o mesmo endereco, este nao sera considerado            �
	//��������������������������������������������������������������������
	If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr)	== 0
		cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUI->QUI_EMAIL)+";"
	EndIf		
	QUI->(dbSkip())	
	
EndDo	

//������������������������������������������������������������������Ŀ
//� Envia copia para os auditores envolvidos na Auditoria			 �
//��������������������������������������������������������������������
QUC->(dbSetOrder(1))
QUC->(dbSeek(xFilial("QUC")+cNumAud))
While QUC->(!Eof()) .And. QUC->QUC_FILIAL == xFilial("QUC") .And.;
	QUC->QUC_NUMAUD == cNumAud   
	
	//������������������������������������������������������������������Ŀ
	//� Caso haja o mesmo endereco, este nao sera considerado            �
	//��������������������������������������������������������������������
	If At(Upper(AllTrim(QUI->QUI_EMAIL)),cCpyUsr)	== 0
		cCpyUsr := AllTrim(cCpyUsr)+AllTrim(QUC->QUC_EMAIL)+";"
	EndIf		
	QUC->(dbSkip())	
	
EndDo	
If SubStr(cCpyUsr,Len(cCpyUsr),1)==";"
	cCpyUsr := SubStr(cCpyUsr,1,Len(cCpyUsr)-1)
EndIf

//������������������������������������������������������������������Ŀ
//� Envia os emails referentes as areas auditadas e para os auditores�
//��������������������������������������������������������������������
QUH->(dbSetOrder(1))
QUH->(dbSeek(xFilial("QUH")+cNumAud))
While QUH->(!Eof()) .And. QUH->QUH_FILIAL == xFilial("QUH") .And. QUH->QUH_NUMAUD == cNumAud
	
	cSeekNC  := QUH->(QUH_NUMAUD+QUH_SEQ)
	
	FOR nCont:=1 TO 2
		IF nCont == 1
			//�����������������������Ŀ
			//�e-mail da Area Auditada�
			//�������������������������
			cEmail:= QUH->QUH_EMAIL
		ElseIF nCont == 2
			//�����������������Ŀ
			//�e-mail do Auditor�
			//�������������������
			cEmail:=""
			QAA->(dbSetOrder(1))
			If QAA->(MsSeek(QUH->QUH_FILMAT+QUH->QUH_CODAUD))
				If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
					cEmail:=QAA->QAA_EMAIL
				Endif
			Endif
		ENDIF
		//���������������������������������������������������Ŀ
		//�Monta e-mail do Encerramento da Auditoria em Html. �
		//�����������������������������������������������������
		cMsg:= Q100AudMail(2,cSubject, Nil, 2)
		
		//������������������������������������������������������������������Ŀ
		//� Executa o Ponto de Entrada Q140MAIL, dever ser retornado o texto �
		//��������������������������������������������������������������������
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

//������������������������������������������������������������������Ŀ
//� Realiza a conexao e o envio dos emails							 �
//��������������������������������������������������������������������
bSendMail := {||QaudEnvMail(aUserMail,,,,.T.)}
cTitle    := STR0016 //"Envio de e-mail"
cMessage  := STR0017 //"Enviando e-mail comunicando o encerramento da Auditoria."
MsgRun(cMessage,cTitle,bSendMail)

Return(NIL)                                     

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADA140GNC � Autor � Paulo Emidio de Barros � Data �19/10/00���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza a integracao das NC,s com o QNC					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADA140GNC(EXPC1)    					                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = numero da Auditoria								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	//��������������������������������������������������������������Ŀ
	//� Realiza integracao com o QNC         						 �
	//����������������������������������������������������������������
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
	    
		//��������������������������������������������������������������Ŀ
		//� Grava o Codigo+Revisao da NC								 �
		//����������������������������������������������������������������
		RecLock("QUG",.F.)
		QUG->QUG_CODNC := aRetQNC[2] //Codigo da Nao-conformidade
		QUG->QUG_REVNC := aRetQNC[3] //Revisao da Nao-conformidade				
		MsUnLock()    
		FKCOMMIT()
	    QUG->(dbSkip())
	    
    
EndDo
	
Return(NIL)
