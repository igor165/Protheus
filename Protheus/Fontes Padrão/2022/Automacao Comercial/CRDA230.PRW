#INCLUDE "CRDA230.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWizard.ch"

//Pula Linha
#Define CTRL Chr(13)+Chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA230   � Autor �Marcos R. Andrade      � Data �30.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de pontos manual dos clientes                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���      
�������������������������������������������������������������������������Ĵ��
���16/01/06  �Machima B.91206�Incluida a opcao para zerar o saldo dos pon-���
���			 �				 �tos dos clientes							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Function CRDA230()                   

Private aRotina := MenuDef()

Private cCadastro := STR0006                           //"Cadastro de Pontos do Cliente"

DbSelectArea("MAX")                                                    

dbSetOrder(1) 
DbSeek(xFilial("MAX"),.T.)

mBrowse( 06, 01, 15, 75, "MAX" )

Return 

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
��� Uso      � CRDA230                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,; 	//"Pesquisar"
						{STR0002	,"AxVisual"		,0	,2	,0	,.T.	}	,; 	//"Visualizar"
						{STR0004	,"AxAltera"		,0	,4	,0	,.T.	}	,; 	//"Alterar"
						{STR0007	,"Crd230Zera"	,0	,4	,0	,.T.	}	} 	//"Inic. Ptos."
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd230Zera  � Autor �Fernando Machima     � Data �13/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem da interface do wizard para inicializar o saldo    ���
���			 �de pontos 												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd230Zera()		                                          ��� 
�������������������������������������������������������������������������Ĵ��
���Uso       �Cadastro de pontos             					          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Function Crd230Zera()

Local nTamCliente  := TamSX3("A1_COD")[1]        // Tamanho do campo A1_COD
Local nTamLoja     := TamSX3("A1_LOJA")[1]       // Tamanho do campo A1_LOJA
Local lRet         := .T.                        // Retorno da funcao
Local lMA7_PONTOS  := MA7->(FieldPos("MA7_PONTOS") > 0)  // Controla se o campo MA7_PONTOS foi criado no dicionario
Local oWizard                                     // Objeto do wizard
Local oPanel                                      // Objeto do panel
Local oGetCliIni                                  // Objeto do codigo do cliente
Local oGetLojIni                                  // Objeto da loja 
Local oGetCliFim                                  // Objeto do codigo do cliente
Local oGetLojFim                                  // Objeto da loja 
Local cCodCliIni   := Space(nTamCliente)         // Codigo do cliente inicial
Local cCodCliFim   := Space(nTamCliente)         // Codigo do cliente final
Local cLojCliIni   := Space(nTamLoja)            // Loja do cliente inicial
Local cLojCliFim   := Space(nTamLoja)            // Loja do cliente final
Local cText        := STR0008 + ;               //"Este programa inicializar� o saldo de pontos dos clientes de acordo com os "
					  STR0009 + ;               //"par�metros selecionados. O saldo atual ser� armazenado no campo Pontos(MA7_PONTOS) "
					  STR0010 + CTRL + CTRL + ; //"para consulta futura. "
					  STR0011 + CTRL + CTRL + ; //"ATEN��O! Se j� houver um saldo gravado, este ser� sobreposto pelo novo saldo calculado."
	  			      STR0012                   //"Para continuar clique em Avan�ar."	  			      
	  			      
Local bValid                                      // Bloco de codigo com validacao


If !lMA7_PONTOS        
   //"Favor criar o campo MA7_PONTOS para armazenar o valor atual de pontos do cliente."
   //"Entre em contato com o Administrador do Sistema."
   MsgStop(STR0013 + STR0014) 
   lRet  := .F.        
EndIf
//�������������������������������������������Ŀ
//�Permissao apenas com senha de Administrador�
//���������������������������������������������
If lRet .AND. !CrdSenhaAdm()
   lRet  := .F.
EndIf

//�����������������������Ŀ
//�Inicializacao do Wizard�
//�������������������������
If lRet
	DEFINE WIZARD oWizard TITLE STR0015 ;    //"Inicializa��o do Saldo de Pontos"
	HEADER STR0016 ;                         //"Wizard de inicializa��o do saldo de pontos dos clientes"
	MESSAGE STR0017 TEXT cText ;             //"Processamento autom�tico."
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//�������������������������������������������Ŀ
	//�Segundo Panel - Perguntas da inicializacao �
	//���������������������������������������������
	CREATE PANEL oWizard HEADER STR0018 ; //"Par�metros para inicializa��o autom�tica"
	MESSAGE STR0019 ;                     //"Informe os par�metros abaixo para a inicializa��o autom�tica do saldo de pontos dos clientes."
	BACK {|| .T. } FINISH {|| Crd230Inic( cCodCliIni   ,cLojCliIni  ,cCodCliFim  ,cLojCliFim ) } PANEL         
	oPanel := oWizard:GetPanel(2)
	
	bValid   := {|| Crd230VldCli( cCodCliIni  ,cLojCliIni ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(15,05,{|| STR0020},oPanel,,,,,,.T.)  //"Cliente inicial:"
	oGetCliIni := TGet():New(14,70,bSETGET(cCodCliIni),oPanel,35,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
	
	bValid   := {|| Crd230VldCli( cCodCliIni  ,cLojCliIni ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(35,05,{|| STR0021},oPanel,,,,,,.T.)  //"Loja inicial:"
	oGetLojIni := TGet():New(34,70,bSETGET(cLojCliIni),oPanel,15,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| Crd230VldCli( cCodCliFim  ,cLojCliFim ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }	
	TSay():New(55,05,{|| STR0022},oPanel,,,,,,.T.)  //"Cliente final:"
	oGetCliFim := TGet():New(54,70,bSETGET(cCodCliFim),oPanel,35,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
	
	bValid   := {|| Crd230VldCli( cCodCliFim  ,cLojCliFim ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(75,05,{|| STR0023},oPanel,,,,,,.T.)  //"Loja final:"
	oGetLojFim := TGet():New(74,70,bSETGET(cLojCliFim),oPanel,15,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	ACTIVATE WIZARD oWizard CENTER
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd230VldCli� Autor �Fernando Machima     � Data �13/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se o cliente esta cadastrado na base de dados		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd230VldCli(ExpC1, ExpC2)		                          ���
���			 �ExpC1 - codigo do cliente								      ���
���			 �ExpC2 - loja do cliente								      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cadastro de pontos             					          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd230VldCli( cCodCli  ,cLojCli )

Local lRet    := .T.                                                //Retorno da funcao, controla se cliente esta cadastrado
Local cChave  := IIf(Empty(cLojCli),cCodCli,cCodCli+cLojCli)       // Chave de pesquisa

lRet  := ExistCpo("SA1",cChave)

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd230VlSeqC� Autor �Fernando Machima     � Data �16/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Va�ida os codigos de Cliente inicial e final		          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd230VlSeqC(ExpC1, ExpC2, ExpC3, ExpC4 )		              ���
���          �ExpC1 - cliente inicial								      ���
���          �ExpC2 - loja do cliente inicial							  ���
���          �ExpC3 - cliente final								          ���
���          �ExpC4 - loja do cliente final							      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cadastro de Pontos             					          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd230VlSeqCli( cCodIni  ,cLojIni, cCodFim, cLojFim )

Local lRet  := .T.                         // Retorno da validacao

If !Empty(cCodIni+cLojIni) .AND. !Empty(cCodFim+cLojFim)
	lRet  := (cCodFim+cLojFim >= cCodIni+cLojIni)
	
	If !lRet
	   MsgStop(STR0024) //"O c�digo final deve ser maior ou igual ao c�digo inicial."
	EndIf
EndIf

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd230Inic  � Autor �Fernando Machima     � Data �16/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa a inicializacao do saldo de pontos                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd230Inic(ExpC1, ExpC2, ExpC3, ExpC4)        		      ���
���			 �ExpC1 - cliente inicial 								      ���
���			 �ExpC2 - loja do cliente inicial 							  ���
���			 �ExpC3 - cliente final 								      ���
���			 �ExpC4 - loja do cliente final  							  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cadastro de Pontos             					          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd230Inic( cCodCliIni   ,cLojCliIni  ,cCodCliFim  ,cLojCliFim )

Local lRet      := .T.           // Retorno da funcao, controla se foram excluidos os pontos de algum cliente
Local nQtde     := 0             // Quantidade de clientes atualizados

If lRet := MsgYesNo(STR0025)    //"Confirma a inicializa��o do saldo de pontos dos clientes informados?"
   DbSelectArea("MA7")
   DbSetOrder(1)
   DbSeek(xFilial("MA7")+cCodCliIni+cLojCliIni,.T.)

   Processa({|lEnd| Crd230Processa(cCodCliIni  ,cLojCliIni  ,cCodCliFim ,cLojCliFim ,;
                                    @nQtde )},,STR0026)	     //"Inicializando saldo de pontos..."

   If nQtde > 0
      MsgStop(STR0027+ALLTRIM(STR(nQtde))+STR0028)   //"Foi realizada a inicializa��o do saldo de pontos de "###" clientes."
   Else 
      lRet  := .F.
	  MsgStop(STR0029) //"N�o foi inicializado o saldo de pontos de nenhum cliente. Verifique se o intervalo de c�digos foi corretamente informado."
   EndIf      
EndIf

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd230Proces� Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa a inicializacao do saldo de pontos				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd230Processa(ExpC1, ExpC2, ExpC3, ExpC4, ExpN5)		      ���
���			 �ExpC1 - cliente inicial               					  ���
���			 �ExpC2 - loja do cliente inicial               		      ���
���			 �ExpC3 - cliente final                					      ���
���			 �ExpC4 - loja do cliente final            					  ���
���			 �ExpN5 - quantidade de registros inicializados      		  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Cadastro de pontos             					          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd230Processa(cCodCliIni  ,cLojCliIni  ,cCodCliFim ,cLojCliFim ,;
							   nQtde )

Local nTotPontos:= 0            // Somatoria de pontos acumulados do cliente
Local nX                        // Controle de loop
Local aRecnoMAX := {}          // Array com os recnos dos clientes(MAX) a serem excluidos 

BEGIN TRANSACTION
	While !Eof() .AND. xFilial("MA7")+cCodCliFim+cLojCliFim >= MA7->MA7_FILIAL+MA7->MA7_CODCLI+MA7->MA7_LOJA
	   //�����������������������������������������������Ŀ
	   //�Soma o total de pontos acumulados ate o momento�
	   //�������������������������������������������������
	   DbSelectArea("MAX")
	   DbSetOrder(1)
	   nTotPontos  := 0
	   aRecnoMAX   := {}
	   If DbSeek(xFilial("MAX")+MA7->MA7_CODCLI+MA7->MA7_LOJA)
	      While !Eof() .AND. xFilial("MAX")+MA7->MA7_CODCLI+MA7->MA7_LOJA == MAX->MAX_FILIAL+MAX->MAX_CODCLI+MAX->MAX_LOJA            
	         nTotPontos  += MAX->MAX_PONTOS
	            
	         AADD(aRecnoMAX,Recno())
	            
	         DbSkip()      
	      End         
	      
	      If nTotPontos > 0
	         nQtde++   
			 //����������������������������������������������������������������������������������������������Ŀ
			 //�Armazena no campo MA7_PONTOS do cliente o total acumulado caso queira recuperar posteriomente �
			 //������������������������������������������������������������������������������������������������
			 RecLock("MA7",.F.)     
			 MA7->MA7_PONTOS  := nTotPontos
			 MsUnlock()      
			 //��������������������������������������������Ŀ
			 //�Exclui os registros de pontos do arquivo MAX�
			 //����������������������������������������������
			 For nX := 1 to LEN(aRecnoMAX)
			    MAX->(DbGoto(aRecnoMAX[nX]))   
			    
				RecLock("MAX",.F.)     
				DbDelete()
				MsUnlock()      	        
			 Next nX
		  EndIf	 
	   EndIf   
		  
	   DbSelectArea("MA7")
	   DbSkip()
	End
	FkCommit()
END TRANSACTION

Return (.T.)
