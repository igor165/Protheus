#INCLUDE "QIEA220.CH"
#INCLUDE "PROTHEUS.CH"

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA220  � Autor � Paulo Emidio de Barros� Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao das Nao-conformidades (Ver710)				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Ultimo STR� STR0021													  ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.	          ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 				      ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                        
Static Function MenuDef()

Local aRotina := {}

Aadd(aRotina,{STR0004,"AxPesqui",  0,1,,.F.})  //"Pesquisar"     
Aadd(aRotina,{STR0005,"Q220NNC",   0,2})  //"Visualizar"  
Aadd(aRotina,{STR0001,"Q220NNC",   0,4})  //"Alterar"  
Aadd(aRotina,{STR0008,"Q220NNC",   0,5})  //"Excluir"  
Aadd(aRotina,{STR0002,"Q220Legend",0,5,,.F.})  //"Legenda"

Return aRotina

Function QIEA220()

Private cTitulo   := STR0009 //"Controle de Notifica��es de N�o Conformidades"
Private cCadastro := OemToAnsi(cTitulo) 
Private cPerg     := 'QEA220'     
Private oBrowse
Private cFiltro   := ""

Private cMatFil := QA_Usuario()[2]
Private cMatCod := QA_Usuario()[3]

//����������������������������������������������������������������Ŀ
//� Indica o numero de dias utilizados como prazo para respostas   � 
//� das Notificacoes das Nao-conformidades                         � 
//������������������������������������������������������������������
Private nDiasResNNC := GetMV("MV_QERENNC")

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina   := MenuDef()

//��������������������������������������������������������������Ŀ
//� Posiciona o registro do Usuario logado no Sistema			 �
//����������������������������������������������������������������
If Empty(cMatCod)
	MessageDlg(STR0010,cTitulo,3)  //"Usu�rio n�o cadastrado"
	Return(NIL)
EndIf
        
//��������������������������������������������������������������Ŀ
//� mv_par01 =  Considera NNCs       1)-com Grupo				 �
//�							         2)-sem Grupo 				 �
//�                   			     3)-ambas					 �
//� mv_par02 = NNCs pendentes		 1)-Sim 2)-Nao	 			 �
//� mv_par03 = NNCs atrasadas	     1)-Sim 2)-Nao				 �
//� mv_par04 = NNCs encerradas       1)-Sim 2)-Nao 				 �
//� mv_par05 = Todas as situacoes    1)-Sim 2)-Nao 				 �
//����������������������������������������������������������������
Pergunte(cPerg,.T.)

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QEM' )
oBrowse:SetDescription(cCadastro)  

oBrowse:AddLegend( "Q220Enc()", "BR_VERDE"	  , STR0013 ) // "Encerradas"
oBrowse:AddLegend( "Q220Pen()", "BR_CINZA"	  , STR0014 ) // "Pendentes"
oBrowse:AddLegend( "Q220Atr()", "BR_VERMELHO" , STR0007 ) // "Atrasadas"

//����������������������������������������������������������������Ŀ
//� Filtra as NNCs baseado nos parametros informados pelo usuario  � 
//������������������������������������������������������������������
If Q220Filtro()
	oBrowse:Activate()
EndIf
	             
dbSelectArea('QEM')
Set Filter to      

Return(NIL)
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q220NNC	� Autor �Paulo Emidio de Barros � Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao de NNCs										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q220NNC(EXPC1,EXPN1,EXPN2)							  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Alias do arquivo									  ���
���			 � EXPN1 = Numero do registro 								  ���
���			 � EXPN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA215													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220NNC(cAlias,nReg,nOpc)
Local oDlg 
Local nOpcA    := 0
Local oTexto   := ''
Local cTexto   := ''
Local cChave   := ''
Local cEspecie := "QIEA220 "
Local nTamLin  := TamSX3("QA2_TEXTO")[1]
Local aTexto   := {}

Private aGets    := {}
Private aTela    := {}   
Private aButtons := {}  

//��������������������������������������������������������������Ŀ
//� Adiciona os botoes para as rotinas especificas 				 �
//���������������������������������������������������������������� 
Aadd(aButtons,{"SDUPROP",{||Q220BotDA(nOpc)},OemToAnsi(STR0022),OemToAnsi(STR0023)}) //"Anexar Documento."  ###"Anex.Doc"


//���������������������������������������������������������������������������Ŀ
//� Recupera o Texto da Notificacao da Nao-conformidade						  �
//�����������������������������������������������������������������������������
cChave := QEM->QEM_CHAVE
If !Empty(cChave)
	cTexto := QA_RecTxt(cChave,cEspecie,00,nTamLin,"QA2",@aTexto)
EndIf
//���������������������������������������������������������������������������Ŀ
//� Cria as variaveis para edicao na enchoice								  �
//�����������������������������������������������������������������������������
RegToMemory("QEM",.F.,.F.)            
              
DEFINE MSDIALOG oDlg TITLE cCadastro From 120,000 To 490,615 OF oMainWnd Pixel	  	

nOpcA := EnChoice(cAlias,nReg,nOpc,,,,,{33,03,115,306},,3,,,)

@ 118,002.5 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE 302.5,055 OF oDlg Pixel
oTexto:lReadOnly := If(nOpc==3,.F.,.T.)

If (nOpc == 3)              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(!Obrigatorio(aGets,aTela),nOpcA:=0,oDlg:End())},;
		{||oDlg:End()},,aButtons) VALID Q220Texto(cTexto,oTexto,nOpc)
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=2,oDlg:End()},,aButtons)
EndIf	  

//���������������������������������������������������������������������������Ŀ
//� Realiza a atualizacao das Notificacoes das nao-conformidades			  �
//�����������������������������������������������������������������������������
If nOpcA == 1       
	If (nOpc # 2)
		Q220GrvAll(nOpc,cTexto)         
    EndIf
EndIf

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Q220Enc	� Autor � Paulo Emidio de Barros� Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica as NNCs Encerradas							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Enc()
Local lRetorno := .F.

//����������������������������������������������������������������Ŀ
//� Se ja tem data de fechamento considera verde - nao importa se  �
//�  ocorreu atraso ou nao                                         �
//������������������������������������������������������������������	
If QEM->QEM_DTFECH # cTod("")
	lRetorno := .T.
EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Q220Atr	� Autor � Paulo Emidio de Barros� Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica as NNCs em atraso								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Atr()
Local lRetorno := .F.

//����������������������������������������������������������������Ŀ
	//� Se ja foi informado a data de resposta usa esta data, caso     �
	//�  contrario utiliza a dDatabase                                 �
	//������������������������������������������������������������������	
	If QEM->QEM_DTRESP == cTod("")
		If (dDataBase - QEM->QEM_DTNNC) > 	nDiasResNNC 
			lRetorno := .T.
		EndIf
	else
	   If (QEM->QEM_DTRESP - QEM->QEM_DTNNC) > 	nDiasResNNC 
			lRetorno := .T.
		EndIf
	EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Q220Pen	� Autor � Paulo Emidio de Barros� Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica as NNCs pendentes								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Pen()
Local lRetorno := .F.

//����������������������������������������������������������������Ŀ
//� Se ja tem data de fechamento considera verde - nao importa se  �
//�  ocorreu atraso ou nao                                         �
//������������������������������������������������������������������	
If QEM->QEM_DTFECH == cTod("")	 

	//����������������������������������������������������������������Ŀ
	//� Se ja foi informado a data de resposta usa esta data, caso     �
	//�  contrario utiliza a dDatabase                                 �
	//������������������������������������������������������������������	
	If QEM->QEM_DTRESP == cTod("")
		If (dDataBase - QEM->QEM_DTNNC) <= nDiasResNNC 
			lRetorno := .T.
		EndIf
	else
		If (QEM->QEM_DTRESP - QEM->QEM_DTNNC) <= nDiasResNNC 
			lRetorno := .T.
		EndIf	
	EndIf
EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q220Legend� Autor �Paulo Emidio de Barros � Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Define as Legendas utilizadas nas NNCs					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q211Legend()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA220													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Legend() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0013)})//"Encerradas" 
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0007)})//"Atrasadas"
Aadd(aLegenda,{"BR_CINZA",	  OemToAnsi(STR0014)})//"Pendentes"  

BrwLegenda(cCadastro,STR0015,aLegenda) //"NNC's"
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220GrvAll� Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava as informacoes das Entradas                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220GrvAll(nOpc,cTexto)         
Local bCampo    := {|nCPO|Field(nCPO)}
Local nCpo      := 0
Local lQEA220G  := ExistBlock("QEA220G")
Local cEspecie  := "QIEA220 "           
Local aAreaQEM                                    
Local aTexto    := {}
Local cChave

Begin Transaction
If nOpc == 3 //Atualizacao

	//Atualiza os campos do QEM
	RecLock("QEM",.F.) 
	For nCpo := 1 To fCount()    
		 If !(FieldName(nCpo) $ "QEM_FILIAL�QEM_NNC")
			FieldPut(nCpo,M->&(EVAL(bCampo,nCpo)))
		 EndIf
	Next nCpo                    
	MsUnlock()

	//���������������������������������������������������������������������������Ŀ
	//� Gera a chave de ligacao do texto da Notificacao das nao-conformidades	  �
	//�����������������������������������������������������������������������������
	cChave := QEM->QEM_CHAVE
	If Empty(cChave)

	    aAreaQEM := GetArea()
   	    cChave := QA_NewChave("QEM",2)
		RestArea(aAreaQEM)   
	   	
	   	dbSelectArea("QEM")
		RecLock("QEM",.F.) 
		QEM->QEM_CHAVE := cChave
		MsUnLock()                      
		
	EndIf

	//����������������������������������������������������������Ŀ
	//� Atualiza o texto das Notificacoes das NCs	  			 �
	//������������������������������������������������������������
	Aadd(aTexto,{1,cTexto})
	QA_GrvTxt(QEM->QEM_CHAVE,cEspecie,1,@aTexto)    
	//
	
    //Executa o ponto de entrada apos a gravacao 
	If lQEA220G 
		ExecBlock( "QEA220G",.F.,.F.,{M->QEM_NNC})
	Endif                                            
	
ElseIf nOpc == 4 //Exclusao
	//����������������������������������������������������������Ŀ
	//� Exclui o texto da Notificacao da Nao-conformidade		 �
	//������������������������������������������������������������
	cChave := QEM->QEM_CHAVE  
	If !Empty(cChave)
		QA_DELTXT(cChave,cEspecie)      
	EndIf	
	RecLock("QEM",.F.) 
	QEM->QEM_DTFECH := cTod('')
	QEM->QEM_DTRESP := cTod('')
	QEM->QEM_CHAVE  := '' 
	MsUnLock()

EndIf      
End Transaction

Return(NIL)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220Encer � Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a data de encerramento da NNC						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Encer()
Local lRetorno := .T.

If M->QEM_DTFECH # cTod("")
	If M->QEM_DTFECH < M->QEM_DTRESP  
		MessageDlg(STR0017,cTitulo,3) //"A data de fechamento deve ser posterior ou igual � data da resposta."
		lRetorno := .F.
	EndIf
EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220Resp  � Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a data das resposta da NNC						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220Resp() 
Local lRetorno    := .T.                   

If (M->QEM_DTRESP < M->QEM_DTNNC)  .Or. (M->QEM_DTRESP  == cTod("")) 
	MessageDlg(STR0018,cTitulo,3) //"A data da resposta deve ser posterior ou igual � data da NNC."
	lRetorno := .F.
EndIf

Return(lRetorno)
                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220FilGrp� Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza o filtro considerando o Grupo de Produtos		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q220FilGrp(cFiltro,lGrupo,lAmbos)
Local lRetorno  := .T.
Local cGrupo    := Space(TamSX3("QEM_GRUPO")[1])
Local cCondicao := " "    
Local cGrupoMax := " "
Local cGrupoMin := " "

dbSelectArea("QE5")
dbSetOrder(3) 
If !dbSeek(xFilial("QE5")+cMatFil+cMatCod)
	MessageDlg(STR0011,cTitulo,3) //"Usu�rio n�o associado a nenhuma equipe de Follow-up"
	lRetorno := .F.
EndIf
	            
If lRetorno
	If lGrupo .Or. lAmbos
	
		dbSeek(xFilial("QE5")+cMatFil+cMatCod,.T.)
		While !Eof() .And. (QE5->QE5_FILIAL == xFilial("QE5")) .And.;
			(QE5->QE5_FILRES+QE5->QE5_RESPON == cMatFil+cMatCod)
			
			dbSelectArea("QE3")
			dbSetOrder(2)
			dbSeek(xFilial("QE3")+QE5->QE5_EQUIPE,.T.)
			While !Eof() .And. (QE3->QE3_FILIAL==xFilial("QE3")) .And. (QE3->QE3_EQUIPE==QE5->QE5_EQUIPE)                   
			
				IIF(QE3->QE3_GRUPO < cGrupoMin .or. Empty(cGrupoMin),cGrupoMin:=QE3->QE3_GRUPO,.f.)
				IIF(QE3->QE3_GRUPO > cGrupoMax,cGrupoMax:=QE3->QE3_GRUPO,.f.)
						
				dbSelectArea("QE3")
				dbSkip()
			EndDo
			dbSelectArea("QE5")
			dbSkip()
		EndDo
		
	EndIf	

	If !Empty(cGrupoMin) 
		If lAmbos                              
		 	cCondicao += '.And. (QEM_GRUPO >='+ '"'+cGrupoMin+'".And. QEM_GRUPO <='+ '"'+cGrupoMax+'")'			     
        Else
		 	cCondicao += '.And. (QEM_GRUPO >='+ '"'+cGrupoMin+'".And. QEM_GRUPO <='+ '"'+cGrupoMax+'")'			     
        EndIf
	EndIf    

	If !lGrupo .Or. lAmbos                              
		If lAmbos
			cCondicao += ' .And. QEM_GRUPO <> "*"'   //' .Or. QEM_GRUPO == "'+cGrupo+'"' 
		Else
			cCondicao += ' .And. QEM_GRUPO == "'+cGrupo+'"' 
		EndIf
	EndIf
	
EndIf   

If Empty(cCondicao) .Or.(Empty(cGrupoMin) .and. lGrupo).And.!lAmbos
	MessageDlg(STR0012,cTitulo,3) // "N�o h� grupos de produtos associados a esta equipe"
	lRetorno := .F.
Else                  
	cFiltro += cCondicao	
EndIf    

Return(lRetorno)
                                     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220Texto � Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o Texto da Notificacao esta preenchido		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q220Texto(cTexto,oTexto,nOpc)
Local lRetorno := .T.

oTexto:Refresh()

If nOpc == 3
	cTexto := AllTrim(cTexto)
	
	If Empty(cTexto)
		Help(" ",1,"Q220TEXTO")
		lRetorno := .F.  
	EndIf
	
EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220Filtro� Autor � Paulo Emidio de Barros� Data �16/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza o filtro nas NNCs								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q220Filtro()
Local lRetorno   := .T.
Local cFilSitNNC := ''                       
Local cDatFech   := Space(TamSx3("QEM_DTFECH")[1])

cFiltro += 'QEM_FILIAL== "'+xFilial("QEM")+'"'
	
If mv_par01 == 1 //com grupo
	lRetorno := Q220FilGrp(@cFiltro,.T.,.F.)            
	
ElseIf mv_par01 == 2 //sem grupo
	lRetorno := Q220FilGrp(@cFiltro,.F.,.F.)
	
ElseIf mv_par01 == 3 //ambas situacoes
	lRetorno := Q220FilGrp(@cFiltro,.T.,.T.)
	
EndIf

If lRetorno
	If mv_par05 == 2  //nao considera todas as situacoes
		If mv_par02 == 1 //Pendentes                       
			cFilSitNNC += 'dTos(QEM_DTFECH) == "'+cDatFech+'" .AND.(Ddatabase-QEM_DTNNC) <= nDiasResNNC'
			If (mv_par03==1) .Or. (mv_par04==1)          
				cFilSitNNC += ' .Or.'
			EndIf
		EndIf
			
		If mv_par03 == 1 //atrasadas
			cFilSitNNC += 'dTos(QEM_DTFECH) == "'+cDatFech+'".AND.(Ddatabase-QEM_DTNNC) > nDiasResNNC'
			If (mv_par04==1)
				cFilSitNNC += ' .Or.'				
			EndIf
		EndIf
		
		If mv_par04 == 1  //encerradas                       
			cFilSitNNC += 'dTos(QEM_DTFECH) <> "'+cDatFech+'"'
		EndIf                 
	Else                           
		cFiltro += '.And. (dTos(QEM_DTFECH) == "'+cDatFech+'"'  
		cFiltro += '.Or. (Ddatabase-QEM_DTNNC) > nDiasResNNC' 
		cFiltro += '.Or. dTos(QEM_DTFECH) <> "'+cDatFech+'")'   
	EndIf
	
	If !Empty(cFilSitNNC)
		cFiltro += 	'.And. ('+cFilSitNNC+')'
	EndIf
                                        
	dbSelectArea("QEM")
	dbSetOrder(1) 
	dbGoTop() 
	oBrowse:SetFilterDefault(cFiltro)
	dbGoTop()
	If Eof()
		MessageDlg(STR0021,cTitulo,3) // "N�o h� NNC sob responsabilidade do usu�rio"
		lRetorno := .F.
	EndIf
EndIf

Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q220BotDA � Autor � Cleber Souza          � Data �19/10/05  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Documento Anexo.								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA220												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q220BotDA(nOpc)                

If nOpc==3 
	If !Empty(M->QEM_DOCANE)
		If MsgYesNo(STR0024,STR0025) //"Deseja alterar o documento existente ?"###"Atencao"
    		M->QEM_DOCANE := QVRFANEXO(nOpc,"","QIE")
    	Else 
			M->QEM_DOCANE := QVRFANEXO(nOpc,M->QEM_DOCANE,"QIE")
    	EndIF
    Else
		M->QEM_DOCANE := QVRFANEXO(nOpc,M->QEM_DOCANE,"QIE")
    EndIf	
Else
	M->QEM_DOCANE := QVRFANEXO(nOpc,M->QEM_DOCANE,"QIE")
endIf  

Return(.T.)
