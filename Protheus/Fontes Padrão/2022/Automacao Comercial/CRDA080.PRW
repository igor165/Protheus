#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA080.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "CRDDEF.CH"

Static oTimerCrd                   //Objeto do timer 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA080   � Autor �Viviane M. Fernandes   � Data �05.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de clientes bloqueados por cr�dito, ordenado de    ���
���          �acordo com a  data e hora de bloqueio.                      ���
���          �Chamada da tela de desbloqueio de cr�dito, pela rotina do   ���
���          �menu "Analiza pr�x".					                  	  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �								                       		  ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���15/06/05  �Kotaki/Machima �Retirada do filtro da mBrowse para mostrar  ���
���          �               �todos os registros do cadastro de credito.  ��� 
���          �               �Apresentar a legenda para os status bloquea-��� 
���          �               �do e nao-bloqueado. Criacao do PE CRD080LIB ��� 
���03/03/06  �Andrea F.      �BOPS 94380 - Tratar o filtro na Mbrowse para���
���          �               �base de dados AS400.                        ��� 
���03/06/06  �Machima        �BOPS 100947 - Correcao para nao permitir que���
���			 �				 �2 ou mais analistas avaliem o mesmo cliente ���
���02/08/06  �Machima        �BOPS 104402-Nao permitir que dois analistas ���
���			 �				 �avaliem o mesmo cliente                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA080()

Local lAS400	 	:= TcSrvType() == "AS/400"								// Identifica se o banco de dados eh AS400
Local aCores        := {{"MA7->MA7_BLOQUE == '1'" , "BR_VERMELHO"   },;  	// Bloqueado - VERMELHO
						{"MA7->MA7_BLOQUE <> '1'" , "BR_VERDE"      }}    	// Nao-bloqueados - VERDE

Private aRotina 	:= MenuDef()
Private cCadastro	:= STR0002			   						    		// Titulo da rotina - "Classifica��o de cliente"
Private cString  	:= "MA7"
Private oCrdMBrowse                                                 		// Objeto da mBrowse

DbSelectArea("MA7")
DbSetOrder(4)
//����������������������������������������������������������������������Ŀ
//�Quando  estiver utilizando o banco de dados AS400 a opcao de filtro da�
//�mbrowse nao estara disponivel. O filtro devera ser tratado na Mbrowse �
//������������������������������������������������������������������������
If lAS400
	DbSeek(xFilial("MA7"))
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,,"CRDA080Top","CRDA080Bot",,{|| CrdAtualiza() } )
Else
	DbSeek(xFilial("MA7"),.T.)
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,aCores,,,,{|| CrdAtualiza() } )
Endif	

If ValType(oTimerCrd) == "O"
   oTimerCrd:DeActivate()	
EndIf  

Return (NIL)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina  := {	{STR0001 ,"CRA080Aval"    ,0 ,2 ,0 ,.T. } ,;				// Rotinas do menu da funcao //"Analisa Pr�x."
						{STR0025 ,"CRA080Legenda" ,0 ,2 ,0 ,.T. } } 		   		//"Legenda"
	Local aRotAdic := {}
	
	//������������������������������������������������������Ŀ
	//� Ponto de entrada - Adiciona rotinas ao aRotina       �
	//��������������������������������������������������������
	If ExistBlock("CRD080ROT")
		aRotAdic := ExecBlock("CRD080ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CrdAtualiz�Autor  �Microsiga           � Data �  06/15/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualizacao do browse para apresentar os registros de cadas-���
���          �tro do credito                                              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CrdAtualiza(oCrdMBrowse)

If oTimerCrd == NIL
	DEFINE TIMER oTimerCrd INTERVAL 10000 ACTION ( CRDTimer() ) OF GetWndDefault()	  	
	oTimerCrd:Activate()	
Endif	

Return (NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDTimer  �Autor  �Microsiga           � Data �  06/15/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execucao do timer para atualizacao do browse                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CRDTimer(nRecnoMA7)

Local lAS400		:= .F.
DEFAULT nRecnoMA7   := 0

// Alterado a atribui��o da vari�vel, pois estava dando erro de compila��o "Never used"
lAS400		:= TcSrvType() == "AS/400"

//������������������������������������������������������Ŀ
//�Comandos para executar o refresh no browse de maneira �
//�a mostrar ao avaliador o status de credito atualizado �
//��������������������������������������������������������
oCrdMBrowse := GetObjBrow()
oCrdMBrowse:ResetLen()
#IFDEF TOP
	If lAS400
		oCrdMBrowse:SetFilter(IndexKey(),CRDA080Top(),CRDA080Bot())
  	Else
		SetMbTopFilter("MA7","")      
	Endif	
#ELSE	
	oCrdMBrowse:SetFilter(IndexKey(),,)
#ENDIF	
oCrdMBrowse:GoTop()
oCrdMBrowse:Default()
oCrdMBrowse:Reset()
oCrdMBrowse:Refresh()
sysrefresh()

//��������������������������������������������Ŀ
//�Re-posiciona no registro do cliente avaliado�
//����������������������������������������������
If nRecnoMA7 > 0
   MA7->(DbGoto(nRecnoMA7))
EndIf   

Return (NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   � CRA080Aval  �Autor�Microsiga           � Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.    �Avaliacao do credito                                         ���
�������������������������������������������������������������������������͹��
���Parametro�                                                             ���
�������������������������������������������������������������������������͹��
���Uso      �SIGACRD												      ���
�������������������������������������������������������������������������Ĵ��
���               Alteracoes desde sua criacao                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA  � Programador   �BOPS  �Manutencao Efetuada                   ���
�������������������������������������������������������������������������Ĵ��
���17/04/06 �Marcos Roberto �DELLA �Incluido os parametro cliente e loja  ���
���         �               �VIA   �na chamada da funcao CRM010_006 para  ��� 
���         �               �      �forcar a busca do mesmo cli. no SA1   ��� 
���04/04/07 �Conrado Quilles�122711|Alterada a utiliza��o da chamada      ���
���         �               �      |SubStr(cUsuario,7,15) por cUserName   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRA080Aval(cAlias, nRecno, nOpc )

Local aArea		:= GetArea()           		// Salva area de trabalho
Local nTipo 	:= 3             			// Libera��o para efetiva��o  (mesma tela do ntipo 1 com a opcao de liberar cr�dito)
Local nRecnoMA7 := 0                       	// Recno no registro do MA7 para re-posicionamento na funcao CrdTimer()
Local nRecnoMAR := 0                       	// Recno do MAR gerado pelo CRDA080
Local cCliente	:= ""                      	// Codigo do cliente
Local cLoja   	:= ""                  		// Loja
Local lRet		:= .F.						// Retorno Default
Local cMV_LibNiv:= SuperGetMv("MV_LIBNIV") 	// Nivel minimo do usuario para liberacao de credito.
Local lErro		:= .F.						// Flag de controle de erro
//��������������������������������������������������������������������������������Ŀ
//�Se o nivel do usuario logado for menor que a permissao de avalicao CONFIGURADA  �
//�pelo MV_LIBNIV para o analista de Credito nao permite avaliar a proxima venda   �
//����������������������������������������������������������������������������������
If cNivel < cMV_LibNiv
	Msgstop(STR0003, STR0004) //"Usuario sem permiss�o de liberar cr�dito para cliente","Usu�rio sem Permiss�o de libera��o"
Else
	DbSelectArea("MA7")
	DbSetOrder(4)
	//�����������������������������������������������������������������������������Ŀ
	//�IMPORTANTE: NAO trocar este comando por MsSeek porque em algumas situacoes   �
	//�o cache do registro nao estava com o status Bloqueado, assim, foi "forcado" a�
	//�buscar na base para evitar esta situacao - Machima					        �	
	//�������������������������������������������������������������������������������
	If DbSeek(xFilial( "MA7" ) + "1" )	// Procura pelo primeiro cadastro de credito bloqueado
	
		While !Eof() .AND. MA7->MA7_BLOQUE == "1"
			// Se for possivel fazer um lock no registro liberar para a analise de credito
			If CRDSEMABLO( "CRDA080"  ,Recno()  ,@nRecnoMAR )
			    nRecnoMA7  := MA7->(Recno())
				lErro := .F.
				Exit
			Else
				lErro := .T.
			Endif			
			MA7->(DbSkip())
		End         
		CrdTimer(nRecnoMA7)						
	Else
		MsgStop(STR0005,STR0006) //"N�o h� registros para serem liberados.""Aten��o !"
		CrdTimer()				
		Return(lRet)
	Endif

	If lErro
		MsgStop( STR0007, STR0008 ) //"Todos os cr�ditos est�o sendo analisados ou n�o existem registros para libera��o.","Aten��o"
		CrdTimer()				
		Return(lRet)
	Endif
	
	//������������������������������������������������������������Ŀ
	//�Se o cadastro de credito nao estiver BLOQUEADO sai da funcao�
	//��������������������������������������������������������������
	If MA7->MA7_BLOQUE <> "1"
		Return(lRet)
	Endif
	
	cCliente:= MA7_CODCLI
	cLoja   := MA7_LOJA
	RegToMemory("MA7",.F.)
	
	DbSelectArea("SA1")
	Dbsetorder(1)
	If DbSeek(xFilial("SA1")+cCliente+cLoja)
		
		//������������������������������������������������������������������������������������Ŀ
		//�Esse regtomemory garante a abertura do cadastro de clientes para a tela de avaliacao�
		//��������������������������������������������������������������������������������������
		RegToMemory("SA1",.F.)
	
		//Chamada da rotina de liberacao de credito ( nTipo possui valor 3 )
		CRM010_006(	nTipo		,; 	//01 Tipo de operacao
					cCliente	,;	//02 Codigo do cliente 
					cLoja		,;	//03 LOJA 
					nRecnoMAR	,; 	//04 Numero do registro no MAR
					.T.)			//05 Utilizado para diferenciar a mensagem do botao Ok
	
		// Liberar o bloqueio do registro (semaforo)
		DbSelectArea("MAR")
		If nRecnoMAR > 0
		   DbGoto(nRecnoMAR)
		   ConOut("4. CRDA080 - Exclui registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       	   	   " Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI + ;
	       	   	   " Usuario: " + cUserName + ;
	       	   	   " Cliente: " + cCliente+"/"+cLoja)		   
		Endif
		RecLock("MAR",.F.)
		DbDelete()
		MsUnlock()
		
		WriteSx2("MAR")

		lRet := .T.
	Endif	
Endif

//��������������������������������������������������������������������Ŀ
//�Restaura a area antes de chamar a funcao CrdTimer() porque ela tem  �
//�que atualizar o browse posicionado no ALIAS MA7.                    �
//����������������������������������������������������������������������
RestArea(aArea)

CrdTimer()

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   � CRA080_002  �Autor�Viviane M. Fernandes� Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.    � Ao confirmar a liberacao de credito, ele processar� esta    ���
���         � rotina para retirar o status de pendente do cliente         ���
���         � saindo da visualizacao ou da liberacao de credito           ���
�������������������������������������������������������������������������͹��
���Parametro�EXPN1: Tipo da Consulta/Libera��o                            ���
���         �EXPC2: Cliente a ser liberado                                ���
���         �EXPC3: Loja                                                  ���
���         �EXPN4: Valor a que deve ser liberado                         ���
���         �EXPC5: Valor do combo(se escolheu SIM ou NAO)                ���
�������������������������������������������������������������������������͹��
���Uso      � AP7-Telecobran�a-Cadastro de Question�rio Socio Ecom. social���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA  � Programador   �Manutencao Efetuada                          ���
�������������������������������������������������������������������������Ĵ��
���01/09/06 �Marcos Roberto �Alteracao para gravar o codigo do usuario    ���
���         �               �que liberou/rejeitou o credito               ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRA080_002(	nTipo	, cCliente	,cLoja	, nExcedido	,;
						cCombo	, nValor )

Local cLinha 		:= ""
Local nSaldo 		:= IIf(SuperGetMv("MV_LIMMAX")>0, ( (SA1->A1_LC * SuperGetMv("MV_LIMMAX") )/100) ,0)
Local cMotTra 		:= Space(50)
Local lRetMsgGet2	:= .T.         
Local cUserCrd		:= ""								//Variavel utilizada para armazenar o codigo do usuario que sera gravado na tabela MAH
Local nMvCRDStat	:= SuperGetMV("MV_CRDSTAT",,1)		//Retorna se a busca do status vai ser via RPC ou Web Service


// Se for a consulta do cliente nao repassar os dados             
If nTipo == 2
	Return .T.
Endif          
// Armazena o codigo do usuario
cUserCrd := CRDX080USR()

DbSelectArea("MA7")
DbSetorder(1)

If DbSeek(xFilial("MA7")+cCliente+cLoja)
	
	// Verificar se o status continua como bloqueado ou transferido para o crediario
	If MA7->MA7_BLOQUE <> "1" .AND. MA7->MA7_BLOQUE <> "4"
		MsgStop(STR0009) //"Esta venda foi cancelada."
		Return .T.
	Endif
	
	If nExcedido > nSaldo .AND. cCombo == STR0013  //"SIM"
		cLinha := STR0010+Chr(13)+Chr(10) //"O valor ultrapassa o limite permitido de libera��o. "
		cLinha += STR0011 + TransForm( nSaldo,"@E 99,999,999.99" )+Chr(13)+Chr(10) //"Valor Permitido para libera��o: "
		cLinha += STR0012+TransForm(nValor,"@E 99,999,999.99")+Chr(13)+Chr(10) //"Valor a ser liberado: "
		cLinha += STR0023+TransForm(nExcedido,"@E 99,999,999.99") //"Valor excedido: "
		MsgStop(cLinha,STR0006) //"Aten��o !"
		
		Return .F.
	Else

		//������������������������������������������������������������������������Ŀ
		//�Chama a tela de observacao de usuario quando for passar para o crediario�
		//�DELLA VIA                                                               �		
		//��������������������������������������������������������������������������
		If cCombo <> STR0013 .And. cCombo <> STR0015   //"SIM"###"NAO"
			cMotTra 	:= Space(50)
			lRetMsgGet2	:= .T.
			While lRetMsgGet2 .And. Empty(cMotTra)
				lRetMsgGet2 := MsgGet2(STR0017,STR0018,@cMotTra,,{|| .t.}) //'Transfer�ncia para credi�rio'###"Qual o motivo da transfer�ncia:"
				If lRetMsgGet2 .And. Empty(cMotTra)
					MsgStop(STR0019) //"Digite a mensagem para o analista do credi�rio."
				Endif
			End
		Endif
	
		Begin Transaction
		
		If Reclock("MA7",.F.)
			
			/*
			Status do MA7_BLOQUE
			status "1" - bloqueado
			status "2" - desbloqueado
			status "3" - Rejeitado
			status "4" - Crediario
			status "0" - valor volta a ser 0 no momento da venda
			*/
			If cCombo == STR0013  //"SIM"
				
				// limpando os registros do MA7
				DbSelectArea("MA7")
				
				M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(DESBLOQ,1)
				M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0014 //"Liberado pelo Analista de Cr�dito"
				
				M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
				M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
				M->MA7_USRBL  := MA7->MA7_USRBL  :=  substr(Alltrim(cUsuario),1,15)
				
				M->MA7_VLRBL  := MA7->MA7_VLRBL  :=  0
				M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
				
				M->MA7_LC     := MA7->MA7_LC     :=  nValor
				
				//������������������������������������������������������������������������������������������������Ŀ
				//�Atualiza o status do contrato para Liberado para diferenciar do contrato que nao foi enviado ao �
				//�Crediario																					   �				
				//��������������������������������������������������������������������������������������������������
				If nTipo == 3 				
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)					
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS	With Str(ST_LIB,1)  
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				
				Endif
			Elseif cCombo == STR0015  //"NAO"
				If ExistBlock("CRD0801")
					lRet := ExecBlock("CRD0801",.F.,.F.)
				Else
					M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(REJEITADO,1)
					M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
					M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
					M->MA7_USRBL  := MA7->MA7_USRBL  :=  substr(Alltrim(cUsuario),1,15)
					M->MA7_VLRBL  := MA7->MA7_VLRBL  :=  0
					M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
					M->MA7_LC     := MA7->MA7_LC     :=  0
					If FunName() = "CRDA180"
						M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0024   //"Rejeitado pela Fila de Crediario"
					Else
						M->MA7_MOTBL  := MA7->MA7_MOTBL  :=  STR0016   //"Rejeitado pelo Analista de Cr�dito"
					Endif
				Endif
				//���������������������������������������������������������������������������Ŀ
				//�Atualiza o status do contrato para Rejeitado para controle de re-avaliacao �
				//�����������������������������������������������������������������������������
				If nTipo == 3   
					
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)					
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS	With Str(ST_REJ,1)
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				
				Endif				
			Else				
				If lRetMsgGet2
					M->MA7_BLOQUE := MA7->MA7_BLOQUE :=  Str(CREDIARIO,1)
					M->MA7_MOTBL  := MA7->MA7_MOTTRA  :=  cMotTra
					
					M->MA7_DATABL := MA7->MA7_DATABL :=  dDatabase
					M->MA7_HORABL := MA7->MA7_HORABL :=  Time()
					M->MA7_USRBL  := MA7->MA7_USRBL  :=  Substr(Alltrim(cUsuario),1,15)
					
					//Nao deve ser alterado o valor do bloqueio quando for para crediario
					M->MA7_VLRBL  := MA7->MA7_VLRBL
					
					M->MA7_DTHSDS := MA7->MA7_DTHRDS :=  Inverte(MA7->MA7_DATABL) + Inverte(StrTran(MA7_HORABL,":",""))
					M->MA7_LC     := MA7->MA7_LC     :=  0
					
					DbSelectArea("MAH")
					DbSetorder(1)
					If DbSeek(xFilial("MAH")+MA7->MA7_CONTRA)
					   RecLock("MAH",.F.)
					   Replace MAH->MAH_STATUS 	With Str(ST_CRED,1)
					   If MAH->(FieldPos("MAH_USRCRD")) > 0
					      Replace MAH->MAH_USRCRD	With cUserCrd
					   Endif	
					   MsUnlock()
					Endif				 
				Endif
			Endif
			DbSelectArea("MA7")										
			MsUnlock()
			
			If ExistBlock("CRD080GRV")
				ExecBlock("CRD080GRV",.F.,.F.,{cCombo})
			Endif

			MA7->(FkCommit())

			If nMvCRDStat == 1			
				CRD080Status( cCliente, cLoja )
			EndIf	
		Else
			MsgStop(STR0020, STR0021) //"Dados complementares do cliente sendo analisado por outro usu�rio"###"Cliente em atualiza��o"
		Endif
		
		End Transaction		
	Endif
Else
	MsgStop(STR0022) //"Cliente nao encontrado"
Endif

If ExistBlock("CRD080LIB")
	ExecBlock("CRD080LIB",.F.,.F.,{cCombo})
Endif

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDSEMABLO�Autor  �Vendas Clientes     � Data �  09/22/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existe algum usuario utilizando do mesmo regis-���
���          � tro.                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������͹��
���Parametros� ExpC1 - Rotina chamadora                                   ���
���			 � ExpN2 - Recno do MA7										  ���
���			 � ExpN3 - Recno do MAR para controle do lock de cliente      ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDSEMABLO( cRotina  ,nRegistro  ,nRecnoMAR )

Local aArea    := GetArea()         // Area atual
Local lRet     := .T.               // Indica se registro no MAR esta bloqueado por outro usuario

DbSelectArea("MAR")
DbSetOrder(1)
cRotina := cRotina + Space(Len(MAR->MAR_ROTINA)-Len(cRotina))

//���������������������������������Ŀ
//�*** Nao substituir por MsSeek ***�
//�����������������������������������
If !DbSeek(xFilial("MAR")+cRotina+StrZero(nRegistro,10,0))
	RecLock("MAR",.T.)
	Replace MAR->MAR_FILIAL With xFilial("MAR")
	Replace MAR->MAR_ROTINA With cRotina
	Replace	MAR->MAR_USUARI With cUserName
	Replace MAR->MAR_REGIST With StrZero(nRegistro,10,0)
	MsUnlock()
	nRecnoMAR       := Recno()
	ConOut("1. CRDA080 - Inclui novo registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       " Rotina: " + MAR->MAR_ROTINA + " Usuario: " + MAR->MAR_USUARI + ;
	       " Cliente: " + MA7->MA7_CODCLI+"/"+MA7->MA7_LOJA)		   
ElseIf AllTrim(cUserName) <> AllTrim(MAR->MAR_USUARI )
	ConOut("2. CRDA080 - Encontrou registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       " Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI + ;
	       " Usuario: " + cUserName + ;
	       " Cliente: " + MA7->MA7_CODCLI+"/"+MA7->MA7_LOJA)		   
	lRet  := .F.
Endif
RestArea(aArea)

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD080Legenda�Autor  �Fernando Machima � Data �  15/06/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda do browse de liberacao de credito                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������ͺ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Machima   �15/06/05�811   �- Inicio do desenvolvimento  				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRA080Legenda()

Local cLegenda  := STR0028          // "Liberacao de Credito"
Local aCores 	:= {}				// Array Default com as definicoes de cores

aCores := {	{"BR_VERDE"		,STR0026 },;					//"Nao-Bloqueado"         
            {"BR_VERMELHO" 	,STR0027 }}				      	//"Bloqueado"         
            
BrwLegenda(cLegenda,STR0025,aCores )  //"Legenda"	

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD080Stat�Autor  � Luiz Felipe Couto  � Data �  02/06/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Esta funcao tem por finalidade executar um RPC com um caixa���
���          � requisitante executando uma funcao neste caixa para a      ���
���          � atualizacao do status, e por consequencia a resposta da    ���
���          � avaliacao do crediario.                                    ���
�������������������������������������������������������������������������͹��
���Param.    � ExpC1: Codigo do Cliente para avaliacao do crediario       ���
���          � ExpC2: Loja do Cliente                                     ���
�������������������������������������������������������������������������͹��
���Uso       � SigaCRD                                                    ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRD080Status( cCliente, cLoja )

Local cIPRPC		:= ""					//IP para RPC
Local cPortaRPC		:= ""					//Porta para RPC
Local cEnvRPC		:= ""					//Environment para RPC
Local aRetStatus	:= {}					//Retorno da Funcao WSCRD110 - Status do bloqueio de crediario
Local lRetorno		:= .T.					//Retorno da Funcao
Local oServer								//Conexao com o servidor do caixa requisitante

//���������������������������������������Ŀ
//�Dados do servidor do caixa requisitante�
//�����������������������������������������
MA7->( DbSetOrder( 1 ) )

If MA7->( DbSeek( xFilial( "MA7" ) + PadR( cCliente, 6 ) + PadR( cLoja, 2 ) ) )
	If 	MA7->( FieldPos( "MA7_IPRPC" ) ) > 0 .AND. MA7->( FieldPos( "MA7_PORRPC" ) ) > 0 .AND.;
		MA7->( FieldPos( "MA7_ENVRPC" ) ) > 0

		cIPRPC 		:= AllTrim( MA7->MA7_IPRPC )
		cPortaRPC 	:= AllTrim( MA7->MA7_PORRPC )
		cEnvRPC 	:= AllTrim( MA7->MA7_ENVRPC )
	Else
		ConOut( "***** CRD080Status *****" )
		ConOut( "Favor criar os seguintes campos na base de dados de acesso do crediario:" )
		ConOut( "------------------------" )
		ConOut( "MA7_IPRPC : Caracter" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 15" )
		ConOut( "Descricao: IP para RPC" )
		ConOut( "------------------------" )
		ConOut( "MA7_PORRPC" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 5" )
		ConOut( "Descricao: Porta para RPC" )
		ConOut( "------------------------" )
		ConOut( "MA7_ENVRPC" )
		ConOut( "Tipo: Caracter" )
		ConOut( "Tamanho: 100" )
		ConOut( "Descricao: Environment para RPC" )
		ConOut( "************************" )
		
		lRetorno := .F.
	Endif
Endif

If lRetorno
	//�����������������������������������������������������Ŀ
	//�Nao faz RPC caso IP recebido do client seja 127.0.0.1�
	//�������������������������������������������������������
	If cIPRPC == "127.0.0.1"
		ConOut( "***** CRD080Status *****" )
		ConOut( "IP: " + cIPRPC )
		ConOut( "Favor atualizar a chave TCP->server do arquivo ap7rmt.ini, para o nome da maquina." )
		ConOut( "************************" )
	
		lRetorno := .F.
	Endif
Endif

If lRetorno
	//������������������������������������������������������Ŀ
	//�Verifica se o caixa esta utilizando RPC ou WebServices�
	//��������������������������������������������������������
	If !Empty( cIPRPC ) .AND. !Empty( cPortaRPC ) .AND. !Empty( cEnvRPC )
	
		ConOut( "***** CRD080Status *****" )
		ConOut( "IP: " + cIPRPC )
		ConOut( "Porta: " + cPortaRPC )
		ConOut( "Env: " + cEnvRPC )
		ConOut( "************************" )
	
		//����������������������������������������Ŀ
		//�Consulta Status de bloqueio de crediario�
		//������������������������������������������
		aRetStatus 	:= WSCRD110( cCliente, cLoja )
		
		ConOut( "Iniciando RPC... Server [" + cIPRPC + "] Porta [" + cPortaRPC + "] Ambiente " + cEnvRPC + "..." )
		 
		//�������������������������������������������Ŀ
		//�Cria a conexao RPC com o caixa requisitante�
		//���������������������������������������������
		CREATE RPCCONN oServer ON SERVER cIPRPC PORT Val( cPortaRPC ) ENVIRONMENT cEnvRPC EMPRESA "00" FILIAL "00" CLEAN
		 
		If oServer == NIL
			UserException( "Falha de conex�o - RPC" )
		Endif
		 
		ConOut( "RPC Conectado... Executando Funcao para verificacao de Status..." )
		
		//�����������������������������������������������������Ŀ
		//�Executa a funcao CRDGravaStatus no caixa requisitante�
		//�������������������������������������������������������
		oServer:CallProc( "CRDGravaStatus", cCliente, cLoja, aRetStatus[1], aRetStatus[2] )
		 
		ConOut( "Finalizando RPC... Server [" + cIPRPC + "] Porta [" + cPortaRPC + "] Ambiente " + cEnvRPC + "..." )
		
		//�������������������Ŀ
		//�Fecha a conexao RPC�
		//���������������������
		CLOSE RPCCONN oServer
		 
		ConOut( "RPC Finalizado..." )
	Endif
Endif

Return (lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA080Top� Autor �Viviane M. Fernandes   � Data �05.09.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que retorna o registro inicial que dever� ser visuali���
���			 �zado na mbrowse, sempre respeitando o �ndice que foi traba- ���
���			 �lhado anteriormente.O retorno da fun��o dever� retornar     ���
���			 �todos os campos que fazem parte da chave de �ndice.		  ���
���			 �Utilizado �ndice inverso, por isso trazemos o mais antigo   ���
���			 �pelo MAX                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CRDA080								               	      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA080Top()

Local aArea		:= GetArea()
Local cRetorno 	:= "" // variavel sera utilizada para filtrar a mbrowse

DbSelectArea("MA7")
DbSetOrder(4)// data mais recente
DbSeek(xFilial("MA7")+"1")

If !EOF()
	cRetorno := MA7->MA7_FILIAL+MA7->MA7_BLOQUE+"  "+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

RestArea(aArea)

Return(cRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA080Bot� Autor �Viviane M. Fernandes   � Data �05.09.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que retorna o �ltimo registro  que dever� ser visuali���
���			 �zado na mbrowse, sempre respeitando o �ndice que foi traba- ���
���			 �lhado anteriormente.O retorno da fun��o dever� retornar     ���
���			 �todos os campos que fazem parte da chave de �ndice.		  ���
���			 �Utilizado �ndice inverso, por isso trazemos o mais recente  ���
���			 �pelo MIN             										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CRDA080						                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA080Bot()

Local cRetorno 	:=""
Local aArea		:= GetArea() //Guarda a area atual

DBSelectArea("MA7")
DbSetOrder(5) //indice invertido
DbSeek(xFilial("MA7")+"1")

If !EOF()
	cRetorno:= MA7_FILIAL+MA7_BLOQUE+"ZZ"+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

DbSelectArea("MA7")
DbSetOrder(4)

RestArea(aArea)

Return(cRetorno)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CRDX080USR� Autor � Marcos Roberto Andrade� Data �28.08.06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o codigo do Usuario Corrente.                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void CRDX080USR()                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � RetC1  - Codigo do usuario corrente.                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico.                                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���04/04/07  |Conrado Q      �BOPS 122711: Alterada a utiliza��o da cham. ���
���          �               �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CRDX080USR()
Local aArea		:= GetArea() 		//Guarda a area atual
Local cCodUser	:= "" 				//Codigo do usuario de retorno

PswOrder(2)
If PswSeek(cUserName)	//Procura o nome do usu�rio
	cCodUser := PswRet(1)[1][1]	//Armazena o codigo do usuario
EndIf

RestArea(aArea)

Return cCodUser
