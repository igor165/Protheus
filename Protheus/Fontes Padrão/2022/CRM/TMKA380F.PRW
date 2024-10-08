#INCLUDE "TMKA380F.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TMKA380F  �Autor  �Vendas Clientes     � Data �  01/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Agenda do operador. Marketing Ativo.                        ���
���          �Fonte com as funcoes de processo do Script Dinamico         ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
     

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Funcao    �Tk380LeScript   �  Autor�Vendas Clientes         �Data  �  20/01/04   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Carrega os itens do script (perguntas/respostas)                      ���
�����������������������������������������������������������������������������������͹��
���Parametros�ExpA1: Array com os dados do Script                        		    ���
���          �ExpC1: Formato do Script Dinamico                           		    ���
���          �ExpC2: Codigo do script dinamico                            			���
���          �ExpC3: Codigo da lista de contatos                          			���
�����������������������������������������������������������������������������������͹��
���Uso       �AP8 - Agenda do Operador                                              ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Function Tk380LeScript(aItems,cFormato,cScript,cLista)


Local aPergunta	:= {}		//Array com as perguntas
Local aResposta := {}		//Array com as respostas
Local aTodasResp:= {}		//Array com todas as Respostas
Local nPergunta := 0		//Contador
Local nResposta := 0		//Contador
Local lRet		:= .F.		//Retorno da funcao
Local aArea    	:= GetArea()
 
//�����������������������������������������Ŀ
//�Limpa o array com as perguntas/respostas.�
//�������������������������������������������
aItems:= {}

//�����������������������������������������������������������������Ŀ
//�Carrega o formato do script para orientar a exibicao dos folders.�
//�������������������������������������������������������������������
cFormato:= Posicione("SUZ",1,xFilial("SUZ") + cScript,"UZ_FORMATO")

//����������������������������������
//�Carrega as perguntas e repostas.�
//����������������������������������
DbSelectArea("SUP")
DbSetOrder(1)
If DbSeek(xFilial("SUP") + cScript)
	
	While !Eof() .AND. (xFilial("SUP") == SUP->UP_FILIAL) .AND. (cScript == SUP->UP_CODCAMP)
		
		//�����������������������������������������������������������������������Ŀ
		//�Se o tipo de resposta esta VAZIO e porque se trata de uma PERGUNTA     �
		//�������������������������������������������������������������������������
		If !Empty(SUP->UP_TIPOOBJ)
			Aadd(aPergunta,{UP_CODCAMP	,UP_CARGO	,UP_IDTREE	,UP_DESC,;
			UP_CODOBS	,UP_SCORE	,UP_TIPOOBJ})  //Carrega todas as perguntas
		Else
			Aadd(aTodasResp,{UP_CODCAMP	,UP_CARGO	,UP_IDTREE	,UP_DESC,;
			UP_CODOBS	,UP_SCORE	,UP_TIPOOBJ	,UP_COMPRES}) //Carrega todas as respostas
		Endif
		
		DbSkip()
	End
	
	//�����������������������������������������������������������������Ŀ
	//�Armazena somente as respostas das perguntas do SCRIPT selecionado�
	//�������������������������������������������������������������������
	For nPergunta:= 1 To Len(aPergunta)
		
		For nResposta:= 1 To Len(aTodasResp)
			If (aTodasResp[nResposta][1] == cScript) .AND. (aTodasResp[nResposta][3] == aPergunta[nPergunta][2])
				Aadd(aResposta,{aTodasResp[nResposta][1],;	//Codigo da Campanha
				aTodasResp[nResposta][2],;	//Codigo do Cargo (TREE)
				aTodasResp[nResposta][3],;	//Codigo do ID (TREE)
				aTodasResp[nResposta][4],;	//Descricao
				aTodasResp[nResposta][5],;  //Codigo da Mensagem
				aTodasResp[nResposta][6],;	//Score
				aTodasResp[nResposta][7],;	//Tipo da Resposta
				aTodasResp[nResposta][8]})  //Complemento de resposta S/N
			Endif
		Next nResposta
		
		Aadd(aItems,{aPergunta[nPergunta],aResposta})
		aResposta:= {}
		
	Next nPergunta
Endif

//�����������������������������������������������������������
//�Se o script selecionado tem perguntas e respostas esta OK�
//�����������������������������������������������������������
If (Len(aItems) > 0 )
	lRet := .T.
Endif

RestArea(aArea)

Return(lRet)


/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Funcao    �Tk380Grava       �Rafael M. Quadrotti 	   	   � Data �  22/01/04   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Grava as respostas do script com integridade.		    			    ���
�����������������������������������������������������������������������������������͹��
���Parametros�ExpA1: Array com os controles das respostas informadas     		    ���
���          �ExpA2: Array com as perguntas e respostas do script         		    ���
���          �ExpC1: Codigo do operador.                                  			���
���          �ExpC2:                                                      			���
���Parametros�ExpC3: Formato do Script.                                  		    ���
���          �ExpC4: Campanha pai do script.                              		    ���
���          �ExpC5: Codigo do script dinamico                            			���
���          �ExpC6: Alias da  entidade.                                  			���
���Parametros�Expc7: Chave primaria da entidade.                         		    ���
���          �ExpC8: Codigo do Contato                                    		    ���
���          �ExpC9: Codigo da ligacao (para alteracao de atendimentos)   			���
���          �ExpC3: Codigo da lista de contatos                          			���
���Parametros�ExpA1: Codigo do atendimento                               		    ���
���          �ExpC3: Codigo do ACI para alteracao de scripts              			���
�����������������������������������������������������������������������������������͹��
���Uso       �TMKA380 - Agenda do Operador                                       	���
�����������������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Function Tk380Grava(	aControl	,aItems		,cOperador	,cCodigo	,;
cFormato	,cCampanha	,cScript	,cEntidade	,;
cChave		,cCodCont	,cCodLig	,cLista	  	,;
cCodAte		,cCampCod	,lPergunta	)

Local nPos    		:= 0
Local nControl		:= 0
Local nItem   		:= 0
Local aSelecao		:= {}
Local lRet    		:= .F.
Local nSaveSx8 		:= GetSX8Len()                      // Funcao de numeracao
Local lGrvVisVen	:= SuperGetMV("MV_TMKAVIS")			// Gravacao da visita do vendedor. Atualiza visita.
Local aResMemo		:= TamSx3("UK_RESMEMO")				// Recebe o tamanho do campo cadastrado no SX3.
Local nTotScore		:= 0								// Soma os valores do Score do Script
Local aScriptVal    := {}                              // Array que contem os campos para ser utilizado no Event Viewer
Local cEventID      := ""                              // Id do Evento a ser disparado pelo Event Viewer
Local cMensagem     := ""                              // Mensagem que sera enviada por e-mail ou RSS pelo Event Viewer
Local lTk380Grv		:= ExistBlock("TK380GRV")			// Ponto de entrada executado ap�s as grava��es

DEFAULT cCampCod := ""
DEFAULT lPergunta:= .T.

CursorWait()

//���������������������������������������������������������Ŀ
//�Apago o script deste atendimento para inclui-lo novamente�
//�����������������������������������������������������������

For nControl:= 1 To Len(aControl)
	
	nPos := Ascan(aItems,{|aVal| aVal[1][2]== aControl[nControl][1]})
	
	Do Case
		Case aControl[nControl][7] == "C"
			If aControl[nControl][3]
				If  (nPos > 0)
					For nItem:= 1 To Len(aItems[nPos][2])
						If (aItems[nPos][2][nItem][2] == aControl[nControl][2])
							Aadd(aSelecao,{	aItems[nPos][2][nItem][2],;
							aItems[nPos][2][nItem][3],;
							aItems[nPos][2][nItem][6],;
							aControl[nControl][6],""})
						Endif
					Next nItem
				Endif
			Endif
			
		Case aControl[nControl][7] == "R"
			nItem:= aControl[nControl][4]
			If(nItem > 0)
				Aadd(aSelecao,{	aItems[nPos][2][nItem][2],;
				aItems[nPos][2][nItem][3],;
				aItems[nPos][2][nItem][6],;
				aControl[nControl][6],;
				Iif(ALLTRIM(UPPER(aItems[nPos][2][nItem][4]))==UPPER(STR0001),AllTrim(aControl[nControl][5]),"")  })//RESPOSTA ABERTA //"RESPOSTA ABERTA"
				
				
				
			Endif
			
		Case aControl[nControl][7] == "M"
			If !Empty(aControl[nControl][5])
				Aadd(aSelecao,{	aItems[nPos][1][3],;
				aItems[nPos][1][2],;
				aItems[nPos][1][6],;
				aControl[nControl][6],;
				AllTrim(aControl[nControl][5])})
				
			Endif
	EndCase
Next nControl

If (Len(aSelecao) > 0) .AND. Iif(lPergunta,TmkOk(STR0002),.T.) //"Confirma a gravacao da campanha ?"
	
	BEGIN TRANSACTION
	
	If ! Empty(cCodigo)
		
		//��������������������������������������������������Ŀ
		//�Apaga os itens da execucao para incluir novamente.�
		//����������������������������������������������������
		DbSelectArea("SUK")
		DbSetOrder(1)
		If DbSeek(xFilial("SUK") + cCodigo)
			While !Eof() .AND. (xFilial("SUK") == SUK->UK_FILIAL) .AND. (cCodigo == SUK->UK_CODIGO)
				RecLock("SUK",.F.,.T.)
				DbDelete()
				MsUnlock()
				DbSkip()
			End
		Endif
	Endif
	
	//������������������������������������������Ŀ
	//�Grava o cabecalho da execucao da campanha �
	//��������������������������������������������
	If Empty(cCodigo)
		cCodigo:= GetSxeNum("ACI","ACI_CODIGO")
		DbSelectArea("ACI")
		DbSetOrder(1)
		RecLock("ACI",.T.)
		REPLACE ACI_FILIAL With xFilial("ACI")
		REPLACE ACI_CODIGO With cCodigo
	Else
		//���������������������������������
		//�Grava a alteracao              �
		//���������������������������������
		DbSelectArea("ACI")
		DbSetOrder(1)
		If DbSeek(xFilial("ACI") + cCodigo)
			RecLock("ACI",.F.)
		Endif
	Endif
	
	REPLACE ACI_CODCON With cCodCont
	REPLACE ACI_ENTIDA With cEntidade
	REPLACE ACI_CHAVE  With cChave
	REPLACE ACI_OPERAD With cOperador
	REPLACE ACI_CODCAM With cCampanha
	REPLACE ACI_CODSCR With cScript
	REPLACE ACI_DATA   With dDatabase
	MsUnlock()
	FKCommit()
	
	While (GetSx8Len() > nSaveSx8)
		ConfirmSX8()
	End
	
	//��������������������������������Ŀ
	//�Grava as respostas dos CONTATOS �
	//����������������������������������
	For nControl:= 1 To Len(aSelecao)
		
		DbSelectArea("SUK")
		RecLock("SUK",.T.)
		REPLACE UK_FILIAL  With xFilial("SUK")
		REPLACE UK_CODIGO  With cCodigo
		REPLACE UK_CODRESP With aSelecao[nControl][1]
		REPLACE UK_CODPERG With aSelecao[nControl][2]
		REPLACE UK_SCORE   With aSelecao[nControl][3]
		REPLACE UK_COMPRES With aSelecao[nControl][4]
		//����������������������������������������������������Ŀ
		//�Se a variavel nao estiver com NIL significa que o   �
		//�script esta sendo executado pela tela de atendimento�
		//������������������������������������������������������
		If cCodAte <> NIL
			REPLACE UK_CODATEN With cCodAte
		Endif
		MSMM(,aResMemo[1],,aSelecao[nControl][5],1,,,"SUK","UK_CODMEMO")
		MsUnLock()
		DbCommit()
		
		//Totaliza o score
		nTotScore += aSelecao[nControl][3]
		
	Next nControl
	
	//����������������������������������������������������������Ŀ
	//�Retorna para a tela de atendimento o numero da execucao da�
	//�campanha                                                  �
	//������������������������������������������������������������
	cCampCod:= ACI->ACI_CODIGO
	
	
	//���������������������������������������������������������������Ŀ
	//�Atualiza a data do ultimo contato.  SU5.                       �
	//�Para que possam ser geradas listas por ultimo contato todas as �
	//�interacoes devem atualizar a data do ultimo contato no cadastro�
	//�de Contatos.                                                   �
	//�����������������������������������������������������������������
	If !Empty(cCodCont)
		DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek(xFilial("SU5") + cCodCont)
			Reclock("SU5",.F.)
			REPLACE SU5->U5_ULTCONT With dDatabase
			MsUnlock()
		EndIf
	EndIf
	
	//�������������������������������������������������������������Ŀ
	//�Ultima Visita.                                               �
	//�                                                             �
	//�Caso o parametro esteja ativo, grava no SA1 a referencia.    �
	//�O campo A1_ULTVIS defini a data da ultima visita ao cliente. �
	//�                                                             �
	//���������������������������������������������������������������
	If lGrvVisVen .AND. Alltrim(cEntidade) == "SA1"
		DbSelectArea(cEntidade)
		DbSetOrder(1)
		If DbSeek(cChave)
			Reclock("SA1",.F.)
			REPLACE SA1->A1_ULTVIS With dDatabase
			MsUnLock()
		EndIf
	EndIf
	
	//��������������������������������������������������������������������������Ŀ
	//� Event Viewer - Acao para a pontuacao minima e maxima do script dinamico  �
	//����������������������������������������������������������������������������
	
	//�����������������������������������������������������������������Ŀ
	//�O cliente XXXXXX participou da campanha YYYYYY                   �
	//� que tem a pontuacao minima de ZZ pontos e a pontuacao maxima de �
	//�WW pontos, e obteve KK pontos                                    �
	//�Atendimento : 123456                                             �
	//�������������������������������������������������������������������
	dbSelectArea("SUZ")
	dbSetOrder(1)
	If dbSeek(xFilial("SUZ")+cScript)
		
		If cCodAte == NIL
			cCodAte := ""
		EndIf
		
		aScriptValue := {SubStr(cChave,1,TamSx3("A1_COD")[1])+"/"+SubStr(cChave,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1]),;
		cCampanha,Str(SUZ->UZ_SCORMIN),Str(SUZ->UZ_SCORMAX),Str(nTotScore),cCodAte}
		
		cMensagem := STR0003+aScriptVal[1]+STR0004+aScriptVal[2]+STR0005+aScriptVal[3]+STR0006+aScriptVal[4]+STR0007+aScriptVal[5];
		+STR0008+CRLF+STR0009+aScriptVal[6]
		
		If nTotScore == SUZ->UZ_SCORMIN
			//���������������������������������������������������������������Ŀ
			//� Event Viewer - Envia e-mail ou RSS para Score Minimo - Script �
			//�����������������������������������������������������������������
			
			cEventID := "011" //Score Minimo - Script
			EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0011,cMensagem)
		
		ElseIf nTotScore == SUZ->UZ_SCORMAX
			//���������������������������������������������������������������Ŀ
			//� Event Viewer - Envia e-mail ou RSS para Score Maximo - Script �
			//�����������������������������������������������������������������
			cEventID  := "012" //Score Maximo - Script
			EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0010,cMensagem)
			
		EndIf
	EndIf
	
	END TRANSACTION
	lRet := .T.
Else
	
	//�����������������������������������������������Ŀ
	//�Avisa que n�o foi selecionado nenhuma resposta.�
	//�������������������������������������������������
	Help(" ",1,"SEMRESPOST")
	lRet := .F.
Endif

If lTk380Grv
	ExecBlock("TK380GRV",.F.,.F.,{cFormato,aControl,aItems,lRet})
Endif

CursorArrow()

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Tk380lRes �Autor  �Vendas Clientes     � Data �  10/15/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Define o Array de controles(aControl)para a altera��o     ���
���          �de dados do Script.                                         ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1: Array com os controles das respostas informadas      ���
���          �ExpN1: Opcao de atendimento.                                ���
���          �ExpC1: Codigo da Campanha                                   ���
���          �ExpC2: Codigo do script                                     ���
���Parametros�ExpC3: Codigo do contato                                    ���
���          �ExpC4: Alias da entidade                                    ���
���          �ExpC5: Chave primaria da entidade                           ���
���          �ExpC6: Alias                                                ���
���Parametros�ExpN2: Registro posicionado                                 ���
���          �ExpC7: Codigo do operador                                   ���
���          �ExpC8: Codigo da lista de contatos                          ���
���          �ExpC9: Codigo do SU6                                        ���
���Parametros�ExpC10:Codigo do atendimento                                ���
���          �ExpA2: Array para informacoes para alteracao                ���
���          �ExpC11: Codigo ACI                                          ���
���          �ExpA3: Perguntas e respostas do script dinamico             ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk380LRes(	aControl 	,nOpc  		,cCampanha	,cScript	,;
cCodCont	,cEntidade	,cChave		,cAlias		,;
nReg		,cOperador	,cLista   	,cSU6Cod	,;
cCodAte		,aParScript ,cCodigo	,aItems)

Local aArea     := GetArea()
Local cCodACI   := ""
Local nResp     := 0
Local nPosPerg  := 0
Local cAte      := "" 						// Folder do Atendimento
Local nPos      := 0
Local cRespAb   := "" 						// Texto da RESPOSTA ABERTA
Local aResMemo	:= TamSx3("UK_RESMEMO")		// Recebe o tamanho do campo cadastrado no SX3.
Local nPosResp	:= 0
Local cMemoResp := ""

//��������������������������������������������������������������Ŀ
//�Verifica se o script ja foi respondido no atendimento corrente�
//����������������������������������������������������������������
nPosResp := aScan(aParScript,{|x| x[6]==cCampanha .AND. x[7]==cScript .AND. x[13]==cCodAte })

If (nOpc <> 3) .AND. (nPosResp ==0 ) // Diferente de inclusao e nao foi respondido atualmente
	
	
	//���������������������������������������������������������������Ŀ
	//�Busca  po codigo do ACI onde esta gravada a execu��o do Script.�
	//�����������������������������������������������������������������
	DbSelectArea("ACI")
	DbSetOrder(2)
	If DbSeek(XFILIAL("ACI")+cCodCont+cEntidade+cChave)
		While((!EOF()) .AND. (xFilial("ACI") == ACI_FILIAL)  .AND.(Alltrim(ACI_CODCON) == Alltrim(cCodCont)) .AND.;
			(ACI_ENTIDA == cEntidade) .AND. (Alltrim(ACI_CHAVE) == Alltrim(cChave)) )
			
			If Alltrim(ACI_ATEND)<> ""
				cAte := Alltrim(Str(nFolder)) // Foi executado de um atendimento Receptivo entao verifica o folder
			EndIf
			
			If  (Alltrim(ACI_CODCAM) == cCampanha) .AND.  (Alltrim(ACI_CODSCR) == cScript)
				
				IF (Alltrim(ACI_ATEND)<>"") .AND. (ACI_ROTINA == cAte) .AND. (Alltrim(ACI_ATEND) == cCodAte)
					cCodACI := ACI_CODIGO
					cCodigo := cCodACI
					Exit
				EndIF
				
			EndIf
			
			DbSkip()
		End
	EndIf
	
	//������������������������������Ŀ
	//�Se encontrou o registro no ACI�
	//��������������������������������
	If !Empty(cCodACI)
		DbSelectArea("SUK")
		DbSetOrder(1)
		If DbSeek(xFilial("SUK")+ cCodACI)
			While (!EOF() .AND. (xFilial("SUK") == UK_FILIAL) .AND. (UK_CODIGO == cCodACI))
				
				DbSelectArea("SUP")
				DbSetorder(2)
				If DbSeek(xFilial("SUP") + cScript + SUK->UK_CODPERG)
					
					//��������������������������������������������������������������������������������������Ŀ
					//�Efetua contagem para verificar a ordem da resposta para preenchimento correto do RADIO�
					//����������������������������������������������������������������������������������������
					While  (!EOF() .AND. (SUP->UP_CODCAMP == cScript) )
						
						//���������������������Ŀ
						//�Se for pergunta pula.�
						//�����������������������
						
						If !Empty(SUP->UP_TIPOOBJ)
							SUP->(DbSkip())
							Loop
						EndIf
						
						//���������������������Ŀ
						//�Ordem da Resposta .  �
						//�����������������������
						
						nResp+=1
						
						IF SUP->UP_CARGO == SUK->UK_CODRESP  // memos vem zerados 0000000
							
							//���������������������������������������Ŀ
							//�Se RESPOSTA ABERTA armazena o texto.   �
							//�����������������������������������������
							
							If  ALLTRIM(UPPER(SUP->UP_DESC))== ALLTRIM(UPPER(STR0001)) //"RESPOSTA ABERTA"
								cRespAb := MSMM(SUK->UK_CODMEMO,aResMemo[1])
							ElseIf !Empty(SUP->UP_CODOBS)
								cMemoResp := MSMM(SUP->UP_CODOBS,aResMemo[1])
							EndIf

							Exit //Sai do laco e retorna a posicao da resposta (nResp)
						EndIf
						
						SUP->(DbSkip())
					End
				EndIf
				
				nPosPerg := Ascan(aControl,{|aVal| aVal[1] == SUK->UK_CODPERG})
				
				//����������������������������������������������������Ŀ
				//�Verifica qual o tipo de objeto e carrega o aControl.�
				//������������������������������������������������������
				
				If nPosPerg > 0
					If aControl[nPosPerg][7] == "R"
						aControl[nPosPerg][2]  := SUK->UK_CODRESP
						aControl[nPosPerg][4]  := nResp // controle do radio
						
						If cRespAb <> ""
							aControl[nPosPerg][5] :=  cRespAb //resposta aberta
						ElseIf !Empty(cMemoResp)
							aControl[nPosPerg][5] :=  cMemoResp
						EndIf
						
					ElseIf aControl[nPosPerg][7] == "M"
						aControl[nPosPerg][5]  := MSMM(SUK->UK_CODMEMO,aResMemo[1])
						
					ElseIf	 aControl[nPosPerg][7] == "C"
						For nPos:= nPosPerg TO Len(aControl)
							If aControl[nPos][2]  == SUK->UK_CODRESP
								aControl[nPos][3]  := .T.
								aControl[nPos][6]  := SUK->UK_COMPRES
							EndIf
						Next
					EndIf
				EndIf
				nResp := 0
				
				DbSelectArea("SUK")
				SUK->(DbSkip())
			End
			
		EndIf
	EndIf
Else
	
	//����������������������������������������������������������������������������Ŀ
	//�Caso seja uma inclus�o ou alteracao sera avaliado o parametro aParScript    �
	//�que possui os dados dos Scripts executados e n�o gravados.                  �
	//�A primeira posicao deste array � o array aControl.                          �
	//�Se os dados forem referentes ao mesmo Script, campanha e Atendimento        �
	//�os dados serao carregados novamente possibilitando a alteracao              �
	//�de um Script que ainda n�o foi gravado.                                     �
	//������������������������������������������������������������������������������
	If Len(aParScript)>0 .AND. nPosResp > 0
		aControl := aParScript[nPosResp][1]
	EndIf
	
EndIf

RestArea(aArea)

Return .T.
