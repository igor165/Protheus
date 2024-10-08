#INCLUDE "PCOA003.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA003N  �Autor  �Microsiga           � Data �  08/24/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Manuten��o de Fases Or�amentarias                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA003()

//���������������������������������������������������Ŀ
//�  Verifica se o controle de fases esta habilitado  �
//�����������������������������������������������������
If GetMv("MV_PCOEXFS",,"2") == "2"
	Help("   ",1,"NOPCOA003",,STR0014+CRLF+STR0015,3,0) // "O Controle de Fases est� desabilitado." ## "Para acessar essa funcionalidade, verifique o conte�do do par�metro MV_PCOEXFS."
    	Return
EndIf

Private aRotina := MenuDef()
	           				
DbSelectArea("AMO")
DbSetOrder(1)
mBrowse(6,1,22,75,"AMO")
		
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FPCOA003  �Autor  �Microsiga           � Data �  24/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de manuten��o de fases Or�amentaorias	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FPCOA003(cAlias, nReg, nOpc)
	Local alDms  		:= FWGetDialogSize(oMainWnd)
	Local oBtn			:= FWButtonBar():New()
	Local nlI			:= 0
	Local nlC			:= 0
   
	Local alAlter1		:= {"AMO_DESCRI","AMO_CORBRW","AMO_MSG"}
	Local alCampos		:= IiF(nOpc==5,{},{"AMR_EVENT","AMR_PERMIT","AMR_MSG"})
	
	//Variaveis usadas pela FILLGETDADOS
	Local cSeek 		:= xFilial("AMR")+IiF(nOpc!=3, AMO_FASE,"") 
	Local bWhile 		:= {|| AMR_FILIAL+AMR_FASE }
	Local aNoFields		:= {"AMR_FASE"}
	Local llInclui		:= IiF(nOpc!=3, .F., .T.)
	Local alEvento		:= {}
	Local alFase		:= {}
	Local alItFaEv		:= {}
	Local bAfterCols	:= {|| FMemoACols()}
	Local lSave	  		:= .F.
	Local cFilSeek		:= ""

	Private oFWLayer 	:= FWLayer():new()
	Private aTela[0][0]
	Private aGets[0]
	
	If nOpc	 == 3 	
		RegToMemory("AMO", .T.)
		RegToMemory("AMQ", .T.) 	
	Else
		RegToMemory("AMO", .F.,,, FunName())
		RegToMemory("AMQ", .F.,,, FunName())
	EndIF

	FILLGETDADOS(nOpc,"AMR",1,cSeek,bWhile,,aNoFields,,,,,llInclui,,,bAfterCols,,,"AMR")

 	If nOpc == 3
 		
		cFilSeek := xFilial("AMQ")

		nlI:= 1
	 	DbSelectArea("AMQ")

		AMQ->(DbSetOrder(1))
		AMQ->(DbSeek(cFilSeek))
	
		While AMQ->(!EOF()) .AND. AMQ->AMQ_FILIAL == cFilSeek
			aCols[nlI,GDFIELDPOS("AMR_EVENT")]	:= AMQ->AMQ_EVENT
			aCols[nlI,GDFIELDPOS("AMR_DESCRI")]	:= AMQ->AMQ_DESCRI
			aCols[nlI,GDFIELDPOS("AMR_PERMIT")]	:= "2"
			aCols[nlI,GDFIELDPOS("AMR_MSG")]	:= ""
			aCols[nlI,Len(aHeader)+1]			:= .F. 
			AMQ->(DbSkip())
			nlI++
			
			If AMQ->(!EOF()) .and. AMQ->AMQ_FILIAL == cFilSeek
				AADD(aCols, Array(Len(aHeader)+1))
				For nlC:=1 to Len(aHeader)
					If aHeader[nlc,2] == 'AMR_ALI_WT'
						aCols[nlI, nlC] := "AMR"
					ElseIf aHeader[nlc,2] == 'AMR_REC_WT'
						aCols[nlI, nlC] := AMR->(RECCOUNT())
					Else
						aCols[nlI, nlC] := CriaVar(aHeader[nlC,2])
					EndIf
				Next nlC
			EndIf
		EndDo
	EndIf
	oDlg :=MSDialog():New(alDms[1],alDms[2],alDms[3],alDms[4],STR0006,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.)		 //"Fases do Or�amento"
		oFWLayer:INIT(oDlg,.T.)
		oFWLayer:addCollumn('Col1',100,.F.)
	   
		oFWLayer:addWindow('Col1'	,'Win1'	,STR0007 ,27,.T.,.T.,/*{||}*/,,/*{||}*/) //"Fase Or�ament�ria X Eventos"
		oFWLayer:addWindow('Col1'	,'Win2'	,STR0008 ,73,.T.,.T.,/*{||}*/,,/*{||}*/) //"Fase Or�ament�ria"
		oPanel1:= oFWLayer:GetWinPanel('Col1','Win1')
		oPanel1:FreeChildren()
		oPanel2:= oFWLayer:GetWinPanel('Col1','Win2') 
		oPanel2:FreeChildren()
		
		oEnch :=	Msmget():New("AMO",nReg,nOpc,,,,,{0,0,50,50},,3,,,,oPanel1,,.T.)		
   		If nOpc != 3
	   		M->AMO_MSG := AMO->AMO_MSG // MSMM(AMO->AMO_CODMSG,TamSx3("AMO_MSG")[1])  
		EndIf
	   	oEnch:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT   	
	   	
	   	oMsGet	:=MsNewGetDados():New(0,0,150,200,GD_UPDATE+GD_DELETE+GD_INSERT,/*"AllwaysTrue"*/,/*"AllwaysTrue"*/,,alCampos,,Len(aCols),/*"u_FVldAltEx()"*/,/*"AllwaysTrue"*/,"AllwaysFalse",oPanel2,aHeader,aCols)
		oMsGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
		
		oBtn:Init(oPanel2, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )			

	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,{|| Eval({|| Iif(Obrigatorio(aGets,aTela) .And. ValEvFO() .And. PCOA003V() ,(lSave:= FGrvFase(nOpc),oDlg:End()),Nil)})},{||oDlg:End()}))
	If !lSave
		RollBackSX8()	
	Else
		ConFirmSX8()
	EndIf	

	aCols := {}

Return Nil
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FMemoACols�Autor  �Microsiga           � Data �  08/24/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � executado na inclus�o de cada linha do acols               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FMemoACols()
	aCols[Len(aCols)][GDFIELDPOS("AMR_MSG")]:= AMR->AMR_MSG // MSMM(AMR->AMR_CODMSG,TamSx3("AMR_MSG")[1])
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FGrvFase  �Autor  �Microsiga           � Data �  08/24/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua altera��es no banco		                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FGrvFase(nOpc)
	Local nlI 		:= 0
	Local clSql 	:= ""
	Local alEvent   := {}
	Local alFase	:= {}
	Local alItFaEv	:= {}
	Local lRet		:= .F.
	
    aCols := {}
    aCols := ACLONE(oMsGet:aCols)
    
	Do Case
		Case nOpc == 3
	 		DbSelectArea("AMO")
			If RecLock("AMO",.T.)
				AMO->AMO_FILIAL 	:= xFilial("AMO")
				AMO->AMO_FASE		:= M->AMO_FASE
				AMO->AMO_DESCRI		:= M->AMO_DESCRI
				AMO->AMO_CORBRW		:= M->AMO_CORBRW
				AMO->AMO_MSG 		:= M->AMO_MSG //(MSMM(,TamSx3("AMO_MSG")[1],,M->AMO_MSG,1,,,"AMO","AMO_CODMSG"))
				AMO->(MsUnLock())
			EndIf
			For nlI := 1 to Len(aCols)
				If RecLock ("AMR",.T.) .and. !Empty(aCols[nli,1])
			    	AMR->AMR_FILIAL	:= xFilial("AMR")
					AMR->AMR_FASE	:= M->AMO_FASE
					AMR->AMR_EVENT	:= aCols[nli,1]
					AMR->AMR_PERMIT	:= aCols[nli,3]			
				   	AMR->AMR_MSG	:= aCols[nli,4] //(MSMM(,TamSx3("AMR_MSG")[1],,aCols[nli,4],1,,,"AMR","AMR_CODMSG"))
					AMR->(MsUnLock())
	    		EndIf
			Next nlI				
			lRet	:= .T.	
		Case nOpc == 4
			DbSelectArea("AMO")
			If RecLock("AMO",.F.) 
				AMO->AMO_FILIAL 	:= xFilial("AMO")
				AMO->AMO_FASE		:= M->AMO_FASE
				AMO->AMO_DESCRI		:= M->AMO_DESCRI
				AMO->AMO_CORBRW		:= M->AMO_CORBRW
				AMO->AMO_MSG		:= M->AMO_MSG //(MSMM(AMO->AMO_CODMSG,TamSx3("AMO_MSG")[1],,M->AMO_MSG,1,,,"AMO","AMO_CODMSG"))
				AMO->(MsUnLock())
			EndIf

			clSql:="DELETE FROM "+RetSqlName("AMR")
			clSql+=" WHERE AMR_FASE = '"+M->AMO_FASE+"'"
			clSql+=" AND AMR_FILIAL = '"+xFilial("AMR")+"'"
			clSql+=" AND D_E_L_E_T_ <> '*'"
			
			TcSqlEXEC(clSql)			

			For nlI := 1 to Len(aCols)
				If RecLock("AMR",.T.) .and. !Empty(aCols[nli,1])
				   	AMR->AMR_FILIAL	:= xFilial("AMR")
					AMR->AMR_FASE	:= M->AMO_FASE
					AMR->AMR_EVENT	:= aCols[nli,1]
					AMR->AMR_PERMIT	:= aCols[nli,3]			
					AMR->AMR_MSG 	:= aCols[nli,4] //(MSMM(,TamSx3("AMR_MSG")[1],,aCols[nli,4],1,,,"AMR","AMR_CODMSG"))
					AMR->(MsUnLock())
	    	   	EndIf
	    	Next nlI 
	    	lRet := .T.
		
		Case nOpc == 5
			
			Pco007Ar(@alEvent,@alFase,@alItFaEv)
		
			DbSelectArea("AMO") 
			DbSetOrder(1)
			If DbSeek(xFilial("AMO") + M->AMO_FASE)
				dbSelectArea("AK1") 
				dbSetOrder(3)
				If dbSeek(xFilial("AK1") + M->AMO_FASE)
					Aviso(STR0009,STR0010,{STR0011}) //"Aten��o"###"A fase n�o pode ser excluida, pois possui amarra��o com uma planilha."###"Ok"
					Return(.F.)
				ElseIf AsCan(alFase,{|aX| aX[1]== M->AMO_FASE})!=0
					Aviso(STR0009,STR0012,{STR0011}) //"Aten��o"###"O Evento selecionado n�o pode ser excluido, pois � padr�o."###"Ok"
					Return(.F.)
				ElseIf RecLock("AMO",.F.)
					DbDelete() 
					MsUnLock()
					
					DbSelectArea("AMR")
					AMR->(DbSetOrder(1))
					
					While dbSeek(xFilial("AMR")+M->AMO_FASE)
						RecLock("AMR",.F.,.T.)
						DbDelete()
						MsUnlock()
					EndDo
				EndIf
			EndIf
			
			lRet := .T.
	End Case
	
	If lRet .AND. ExistBlock('PCOA03GRV') 
		ExecBlock('PCOA03GRV',.F.,.F.,{nOpc})	
	EndIf	
	
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FPesEv    �Autor  �Microsiga           � Data �  18/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida os eventos nas fases or�amentarias                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValEvFO()
Local lRet := .F.
Local nCnt := 0

If Empty(M->AMO_MSG)
	For nCnt := 1 To Len(oMsGet:aCols)
		If !Empty(oMsGet:aCols[nCnt,4])
			lRet := .T.
		EndIf
	Next nCnt
Else
	lRet := .T.
EndIf

If !lRet
	MsgAlert(STR0018) // "Imposs�vel gravar Fase Or�ament�ria sem Mensagem de Aviso!"
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Pedro Pereira Lima � Data �  28/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {{STR0001	,"AxPesqui"	,0,1} ,; //"Pesquisar"
		            {STR0002	,"FPCOA003"	,0,2} ,; //"Visualizar"
		            {STR0003	,"FPCOA003"	,0,3} ,; //"Incluir"
		           	{STR0004	,"FPCOA003"	,0,4} ,; //"Alterar"
		            {STR0005	,"FPCOA003"	,0,5}}  //"Excluir"

Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOA003V  �Autor  � Protheus			 � Data �  28/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o do Acols                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������l�������������
*/
Function PCOA003V(cCampo) 

Local lRet := .T. 
Local nX := 0   
Local nZ := 0
Local aHeader 
Local aCols 
Local nPosEvent := 0  
Local cCont := ""
Default cCampo := Nil 

If IsInCallStack("PCOA003") 
	aHeader := oMsGet:aHeader 
	aCols := oMsGet:aCols
	
	nPosEvent := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMR_EVENT")})

	If cCampo <> Nil
		cCont := M->AMR_EVENT	 
	EndIf
		
	For nX := 1 to Len(aCols)
		If !lRet  
			Exit
		EndIf
		If !Empty(cCont)
			If AllTrim(aCols[nX][nPosEvent]) == Alltrim(cCont) 
				lRet:= .F.  
				Help("   ",1,"NOPDUP1",,STR0020+aCols[nX][nPosEvent],3,0) //J� existe o evento selecionado : 
	   			Exit
	   		EndIf
	  	Else
			For nZ := 1 to Len(aCols)  
				If nX == nZ
					Loop
				EndIf
				If AllTrim(aCols[nX][nPosEvent]) == AllTrim(aCols[nZ][nPosEvent]) 
					lRet:= .F.  
					Help("   ",1,"NOPDUP2",,STR0021+aCols[nX][nPosEvent],3,0) //Evento duplicado: 
					Exit    
	  			EndIf
			Next nZ       
		 EndIf             
	Next nX
EndIf

Return lRet
