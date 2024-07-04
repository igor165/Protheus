#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "CRDA250.CH"

//Extras
#XTRANSLATE bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#XCOMMAND DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    	 <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
	  [  <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

//Pula Linha
#DEFINE CTRL Chr(13)+Chr(10)

//DEFINE's do array aDadosConv
#DEFINE CODCLI   2
#DEFINE LOJACLI  3
#DEFINE NOMECLI  4
#DEFINE NUMCART  5
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDA250	 �Autor  �Thiago Honorato     � Data �  08/08/06  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de porocessamento automatico para mudar os campos   ���
���          � Situacao e Motivo dos cartoes dos clientes.                ���
���          � Rotina acessada mediante autorizacao caso o usuario logado ���
���          � seja diferente de adminstrador                             ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD - chamada do menu do SIGACRD					      ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���          �        �      �                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA250()

Local oWizard		    													// objeto WIZARD
Local oPanel																// objeto PANEL 

Local oGrp1																	// objeto - Grupo informativo
Local oGrp2																	// objeto - Grupo informativo

Local oGetCodCli        													// objeto para o get do Codigo Cliente
Local oGetLojCli     	  													// objeto para o get do Loja Cliente
Local cCodCli     := Space(TamSX3("A1_COD")[1])							// codigo do cliente 
Local cLojCli     := Space(TamSX3("A1_LOJA")[1])							// loja do cliente


Local oGetCodClFim	     													// objeto para o get do Codigo Cliente Final
Local oGetLojClFim  	  													// objeto para o get do Loja Cliente Final
Local cCodClFim  := Space(TamSX3("A1_COD")[1])								// codigo do cliente final
Local cLojClFim  := Space(TamSX3("A1_LOJA")[1])							// loja do cliente final

Local oSituacao                                                 // objeto das situacoes dos cartoes
Local aSituacao  := {STR0001, STR0002, STR0003}	    // Array com as acoes a serem realizadas pelo usuario //"Desbloquear"###"Bloquear"###"Cancelar"
Local nSituacao  := 1

Local oMot1							 								    	// objeto Motivos
Local oMot2							 								    	// objeto Motivos
Local oMot3					 								    			// objeto Motivos

Local aMot1    := {STR0004, STR0005, STR0006}		// Array com os tipos dos Motivos //"Cart�o Novo"###"Perda/Furto"###"Bloqueio Autom�tico"
Local aMot2    := {STR0004}											// Array com os tipos dos Motivos //"Cart�o Novo"
Local aMot3    := {STR0007}													// Array com os tipos dos Motivos                     //"�bito"

Local nMot1	   := 1			 								    			// escolha Motivos
Local nMot2	   := 1			 								    			// escolha Motivos
Local nMot3	   := 1			 								    			// escolha Motivos

Local nMotivo	 := 0														// motivo escolhido

Local cText :=	STR0061 + ;  //"Este programa ir� fazer atualiza��es no cadastro de cliente "
                STR0062 			   + ;  //"nas informa��es referentes aos cart�es cadastrados"
	  			 CTRL + CTRL + CTRL + ;
	  			STR0063 //"Para continuar clique em Avan�ar."

Local bValid        			// parametro de validacao

Local lMarcAll := .F.			// opcao para marcar todos os Conveniados
Local oMarcAll          		// objeto da opcao Marcar Tudo


Local lInadimplente := .F.    	// opcao para marcar somente os clientes Inadimplentes
Local oInadimplentes          	// objeto da opcao Somente Inadimplentes

Local nQtdeCli := 0				// conta quanto registros foram atualizados
//������������������������������Ŀ
//�Estrutura do array aDadosConv �
//�------------------------------�
//�1-Marca de selecao            �
//�2-Codigo do cliente           �
//�3-Loja                        �
//�4-Nome                        �
//�5-Numero do cartao            �
//��������������������������������
Local aDadosConv  := {}	  //array com informacoes do cliente
Local aCpos 	  := {}  // array auxiliar
Local lTPLDRO 	  := .F. // indica se o filtro sera' feito atraves da empresa de convenio (Somente o TPL - Drogaria)

Local cMesg1	  := Iif(HasTemplate("DRO"),STR0064,STR0065) //"Informe a empresa de conv�nio na qual ser�o processados as altera��es referentes aos cart�es!"###"Selecionando os clientes!"

Private oOk		    := LoadBitMap(GetResources(), "LBOK")
Private oNo		    := LoadBitMap(GetResources(), "LBNO")
Private oNever	    := LoadBitMap(GetResources(), "DISABLE")
Private oArrayConv

//�������������������������������������Ŀ
//�Verifica o nivel de acesso do usu�rio�
//�So' tera' acesso a esta rotina o     �
//�usuario cujo nivel de acesso seja    �
//�igual a 9 ou o usuario logado no     �
//�sistema seja ADMINISTRADOR           �
//���������������������������������������
If CRDXVLDUSU(3)
	//�����������������������Ŀ
	//�Inicializacao do Wizard�
	//�������������������������
	DEFINE WIZARD oWizard TITLE STR0066 ; //"SIGACRD - Processamento dos cart�es"
	HEADER STR0067 ;  //"Wizard do processamento dos cart�es:"
	MESSAGE STR0068 TEXT cText ; //"Processamento autom�tico."
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�Segundo Panel - Escolha dos clientes 											          �
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0069 ; //"Dados para processamento dos cart�es"
	MESSAGE cMesg1 ;
	BACK {|| .T. } NEXT {|| CRD250VldCli( cCodCli, cLojCli, cCodClFim, cLojClFim, lTPLDRO ) } FINISH {|| .T. } PANEL         
	oPanel := oWizard:GetPanel(2)
	
	If HasTemplate("DRO")
		ChkTemplate("DRO")
		//��������������������������������������������������
		//�Tela que sera' utilizada para Template DROGARIA �
		//��������������������������������������������������		
		bValid   := {|| ExistCpo("SA1",cCodCli)}
		TSay():New(15,05,{|| STR0017},oPanel,,,,,,.T.) //"Empresa de conv�nio"
		oGetCodCli := TGet():New(14,70,bSETGET(cCodCli),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L54",)
		
		bValid   := {|| ExistCpo("SA1",cCodCli+cLojCli)}
		TSay():New(35,05,{|| STR0018},oPanel,,,,,,.T.) //"Loja da empresa"
		oGetLojCli := TGet():New(34,70,bSETGET(cLojCli),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

		lTPLDRO := .T.
    Else
		//��������������������������������������������������
		//�Tela que sera' utilizada para o Padrao MICROSIGA�
		//��������������������������������������������������
		oGrp2 := TGroup():New(5,2,135,280,STR0019,oPanel,,,.T.) //" Filtro: "
		
		bValid   := {|| ExistCpo("SA1",cCodCli)}
		TSay():New(30,25,{|| STR0020},oPanel,,,,,,.T.) //"Cliente de:"
		oGetCodCli := TGet():New(24,60,bSETGET(cCodCli),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
		
		bValid   := {|| ExistCpo("SA1",cCodCli+cLojCli)}
		TSay():New(45,25,{|| STR0021},oPanel,,,,,,.T.) //"Loja de:"
		oGetLojCli := TGet():New(39,60,bSETGET(cLojCli),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
		
		bValid   := {|| ExistCpo("SA1",cCodClFim) .AND. cCodClFim >= cCodCli}
		TSay():New(75,25,{|| STR0022},oPanel,,,,,,.T.) //"Cliente at�:"
		oGetCodClFim := TGet():New(69,60,bSETGET(cCodClFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
		
		bValid   := {|| ExistCpo("SA1",cCodClFim+cLojClFim)}
		TSay():New(90,25,{|| STR0023},oPanel,,,,,,.T.) //"Loja at�:"
		oGetLojClFim := TGet():New(84,60,bSETGET(cLojClFim),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
    Endif
	//�������������������������������������������������������������������������������������������Ŀ	
	//�TERCEIRO - Acoes a serem realizadas (Desbloquear - Bloquear - Cancelar)					  �
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0070 ; //"Defini��o das altera��es a serem efetuadas para os cart�es dos clientes."
	MESSAGE STR0071; //"Informe a a��o a ser realizada"
	BACK {||.T.};
	NEXT {|| IIF( nSituacao <> 2, Iif(nSituacao == 1,oWizard:nPanel += 1 , oWizard:nPanel += 2), ), .T. };
	FINISH {||.F.} PANEL	
	oPanel := oWizard:GetPanel(3)
																		
	oGrp1 := TGroup():New(5,2,135,280,STR0072,oPanel,,,.T.) //"Informa��es: "
	@ 25,08 TO 100,120 PROMPT STR0027  PIXEL OF oPanel  //"A��o:"
																										
	oSituacao  := TRadMenu():New(45,16,aSituacao,bSETGET(nSituacao),oPanel,,,,,,,,60,10,,,,.T.)


	TSay():New(107,08,{|| STR0028},oPanel,,,,,,.T.)	 //"ATEN��O:"
	TSay():New(114,08,{|| STR0073},oPanel,,,,,,.T.)	 //"Cart�es com cujo campo Situa��o esteja igual a CANCELADO, n�o ser�o selecionados para processamento!"

	//�������������������������������������������������������������������������������������������Ŀ	
	//�QUARTO - MOTIVOS *quando a situacao escolhida = Bloqueio     							  �
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0070 ; //"Defini��o das altera��es a serem efetuadas para os cart�es dos clientes."
	MESSAGE STR0031; //"Informe MOTIVO para qual deseja atualizar as informa��es dos cart�es!"
	BACK {|| .T. };
	NEXT {|| Iif( nMot1 == 3, nMotivo := 4, nMotivo := nMot1 ),;  
			 oWizard:nPanel += 2,;
			 CRD250Prox( nMot1    , cCodCli , cLojCli  , cCodClFim,;
					     cLojClFim, lTPLDRO , nSituacao, @aDadosConv,;
					     @lInadimplente ) };
	FINISH {|| .T. } PANEL         
	oPanel := oWizard:GetPanel(4)
																		
	oGrp1 := TGroup():New(5,2,135,280,STR0072,oPanel,,,.T.) //"Informa��es: "
	@ 25,08 TO 100,120 PROMPT STR0032 PIXEL OF oPanel  //"Motivo do Bloqueio"

	oMot1  := TRadMenu():New(42,16,aMot1,bSETGET(nMot1),oPanel,,,,,,,,60,10,,,,.T.)
	
	//�����������������������������������������������������������������������������������Ŀ
	//�Alerta referente a escolha do motivo bloqueado.                                    �
	//�Escolhendo este motivo, o sistema ira' selecionar somente os cliente Inadimplentes.�
	//�������������������������������������������������������������������������������������
	TSay():New(107,08,{|| STR0028},oPanel,,,,,,.T.)	 //"ATEN��O:"
	TSay():New(114,08,{|| STR0074},oPanel,,,,,,.T.)	 //"Escolhendo o motivo Bloqueio Autom�tio, ser� selecionado somente os cliente Inadimplentes!"

	//�������������������������������������������������������������������������������������������Ŀ
	//�QUINTO - MOTIVOS *quando a situacao escolhida = Desbloqueio  							  �
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0070 ; //"Defini��o das altera��es a serem efetuadas para os cart�es dos clientes."
	MESSAGE STR0031; //"Informe MOTIVO para qual deseja atualizar as informa��es dos cart�es!"
	BACK {|| oWizard:nPanel -= 1, .T. };
	NEXT {|| nMotivo := nMot2,; 
			 oWizard:nPanel += 1,;
			 CRD250SeekCart( cCodCli, cLojCli, cCodClFim, cLojClFim,;
			 			     lTPLDRO, nSituacao, @aDadosConv )};
	FINISH {|| .T. } PANEL         
	oPanel := oWizard:GetPanel(5)
																		
	oGrp1 := TGroup():New(5,2,135,280,STR0072,oPanel,,,.T.) //"Informa��es: "
	@ 25,08 TO 100,120 PROMPT STR0035  PIXEL OF oPanel  //"Motivo do Desbloqueio"

	oMot2  := TRadMenu():New(42,16,aMot2,bSETGET(nMot2),oPanel,,,,,,,,60,10,,,,.T.)
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�SEXTO - MOTIVOS *quando a situacao escolhida = Cancelar      							  �
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0070 ; //"Defini��o das altera��es a serem efetuadas para os cart�es dos clientes."
	MESSAGE STR0031; //"Informe MOTIVO para qual deseja atualizar as informa��es dos cart�es!"
	BACK {|| oWizard:nPanel -= 2, .T. };
	NEXT {|| Iif( nMot3 == 1, nMotivo := 3, nMotivo := nMot3),;
	         CRD250SeekCart( cCodCli, cLojCli  , cCodClFim, cLojClFim,;
	         				 lTPLDRO, nSituacao, @aDadosConv ) };
	FINISH {|| .T. } PANEL         
	oPanel := oWizard:GetPanel(6)
																		
	oGrp1 := TGroup():New(5,2,135,280,STR0072,oPanel,,,.T.) //"Informa��es: "
	@ 25,08 TO 100,120 PROMPT STR0036  PIXEL OF oPanel  //"Motivo do Canecelamento"

	oMot3  := TRadMenu():New(42,16,aMot3,bSETGET(nMot3),oPanel,,,,,,,,60,10,,,,.T.)
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�SETIMO - CLIENTES *todos os clientes selecionados de acordo com os parametros anteriores   � 
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0037 ; //"Confirma��o os cart�es processados:"
	MESSAGE STR0038 ; //"Selecione os cart�es que ser�o alterados."
	BACK {|| IIF( nSituacao <> 3, Iif(nSituacao == 1,oWizard:nPanel -= 1 , oWizard:nPanel -= 2), ), .T. };
	NEXT {|| CRD250AtuMA6( nSituacao, nMotivo, @nQtdeCli, aDadosConv,;
						   lInadimplente ) };
	FINISH {|| .T. } PANEL        
	oPanel := oWizard:GetPanel(7)
	      
	aCabec  := {"",STR0039,STR0040,STR0041,STR0042} //"C�digo Cliente"###"Loja"###"Nome"###"N� do cart�o"
	aTam    := {5 ,25              ,30    ,25    ,50}
	Aadd(aCpos  ,"nSel")
	Aadd(aCpos  ,"A1_COD")
	Aadd(aCpos  ,"A1_LOJA")
	Aadd(aCpos  ,"A1_NOME")
	Aadd(aCpos  ,"MA6_NUM")
	
	//Inicializa array com os dados dos conveniados
	aDadosConv  := CRD250MontaArray(aCpos) 
					
	oArrayConv	:= TwBrowse():New(000,000,000,000,,aCabec,aTam,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oArrayConv:nHeight	:=230
	oArrayConv:nWidth	:=565
	oArrayConv:lColDrag	:= .T.
	oArrayConv:nFreeze	:= 1
	oArrayConv:bLDblClick :={ || CRD250Marc(@lMarcAll, @oMarcAll, @aDadosConv )}
	
	@ 125,00 CHECKBOX oMarcAll VAR lMarcAll PROMPT STR0043 SIZE 100,10 OF oPanel PIXEL ON CHANGE(CRD250All( lMarcAll, @aDadosConv )) //"Marcar Todos"
	
	oArrayConv:SetArray(aDadosConv)
	oArrayConv:bLine := { ||{  If(aDadosConv[oArrayConv:nAt,1]>0,oOk,If(aDadosConv[oArrayConv:nAt,1]<0,oNo,oNever)),;
							    aDadosConv[oArrayConv:nAT][CODCLI] ,;
							    aDadosConv[oArrayConv:nAT][LOJACLI],;
	                            aDadosConv[oArrayConv:nAT][NOMECLI],;
	                            aDadosConv[oArrayConv:nAT][NUMCART]}}                        
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�OITAVO - Resultado do PROCESSAMENTO 														  |
	//���������������������������������������������������������������������������������������������
	CREATE PANEL oWizard HEADER STR0044 ; //"Resultado do processamento:"
	MESSAGE STR0045 ; //"Veja abaixo o resultado do Processamento"
	BACK {|| .F. } NEXT {|| .T. } FINISH {|| .T. } PANEL         
	oPanel := oWizard:GetPanel(8)
	
	TSay():New(35,05,{|| STR0046 },oPanel,,,,,,.T.) //"Quantidade de cart�es atualizados:"
	oGetRegProc := TGet():New(30,95, bSETGET(nQtdeCli),oPanel,60,10,,,,,,,,.T.,,,,,,,.T.,,,)
	
	ACTIVATE WIZARD oWizard CENTER 
Endif

Return     

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CRD250Prox    �Autor  �Thiago Honorato     � Data �  08/08/06  ���
����������������������������������������������������������������������������͹��
���Desc.     � Verifica qual funcao sera chamada de acordo com a Situacao 	 ���
���          � escolhida                                                  	 ���
����������������������������������������������������������������������������͹��
���Uso       � Quarto Panel - funcao CRDA250()         	 			      	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Motivo escolhido                                    	 ���
���          �ExpC1 - Codido do cliente inicial                           	 ���
���          �ExpC2 - Codido da loja inicial                             	 ���
���          �ExpC3 - Codido do cliente final                            	 ���
���          �ExpC4 - Codido da loja final                               	 ���
���          �ExpL1 - Controle se esta usando o Template Drogaria         	 ���
���          �ExpN2 - Situacao escolhida                                  	 ���
���          �ExpA1 - Array com informacoes dos clientes                  	 ��� 
���          �ExpL1 - Controla se o cliente esta' inadimplente ou nao	     ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida o processamento dos clientes                 	 ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 ���
����������������������������������������������������������������������������͹��
���          �        �      �                            	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/    
Static Function CRD250Prox( nMot1    , cCodCli, cLojCli  , cCodClFim ,;
							cLojClFim, lTPLDRO, nSituacao, aDadosConv,;
							lInadimplente )

Local lRet := .F.	// Retorno da funcao


//��������������������������������������������������������������������Ŀ
//�nMot1 = 3  - significa 'Bloqueio Automatico', com isso,             �
//�             sera' selecionado apenas clientes inadimplentes.	   �
//����������������������������������������������������������������������
If nMot1 <> 3 
	lRet := CRD250SeekCart( cCodCli, cLojCli  , cCodClFim  , cLojClFim,;
 						    lTPLDRO, nSituacao, @aDadosConv, @lInadimplente )
Else
	lRet := CRD250Inadimplentes( cCodCli, cLojCli    , cCodClFim, cLojClFim,;
 			 					 lTPLDRO, @aDadosConv, @lInadimplente )
Endif       

Return ( lRet )

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CRD250SeekCart�Autor  �Thiago Honorato     � Data �  08/08/06  ���
����������������������������������������������������������������������������͹��
���Desc.     � Posiciona nos clientes e seus respectivos cartoes         	 ���
����������������������������������������������������������������������������͹��
���Uso       � Quarto e Quinto PANEL - funcao CRDA250()				      	 ���
���          � CRD250Prox()											      	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codido do cliente inicial                           	 ���
���          �ExpC2 - Codido da loja inicial                             	 ���
���          �ExpC3 - Codido do cliente final                            	 ���
���          �ExpC4 - Codido da loja final                               	 ���
���          �ExpL1 - Controle se esta usando o Template Drogaria         	 ���
���          �ExpA1 - Array com informacoes dos clientes                  	 ��� 
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida o processamento dos clientes                  	 ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 ���
����������������������������������������������������������������������������͹��
���          �        �      �                            	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/    
Static Function CRD250SeekCart( cCodCli, cLojCli  , cCodClFim, cLojClFim,;
							    lTPLDRO, nSituacao, aDadosConv )

Local lRet := .T.	// retorno da funcao
//�������������Ŀ
//�Processamento�
//���������������
Processa( { |lEnd| lRet  := CRD250ProcCart( cCodCli, cLojCli   , cCodClFim, cLojClFim,;
											lTPLDRO,  nSituacao,  @aDadosConv ) },;
											STR0047,, .F.)   //"Processando os clientes..."

Return (lRet)
/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �CRInadimplentes�Autor  �Thiago Honorato     � Data �  08/08/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     � Funcao que seleciona todos os clientes inadimplentes dentro    ���
���          � do intervalo pre-estabelecido                                  ���
�����������������������������������������������������������������������������͹��
���Uso       � Chamada a partir da funcao CRD250Prox()						  ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codido do cliente inicial                           	  ���
���          �ExpC2 - Codido da loja inicial                             	  ���
���          �ExpC3 - Codido do cliente final                            	  ���
���          �ExpC4 - Codido da loja final                               	  ���
���          �ExpL1 - Controle se esta usando o Template Drogaria         	  ���
���          �ExpA1 - Array com informacoes dos clientes                  	  ��� 
���          �ExpL1 - Controla se o cliente esta' inadimplente ou nao	      ���
�����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida o processamento dos clientes inadimplentes  	  ���
�����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	  ���
�����������������������������������������������������������������������������͹��
���          �        �      �                            	                  ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/    
Static Function CRD250Inadimplentes( cCodCli, cLojCli  ,  cCodClFim, cLojClFim,;
							 	     lTPLDRO, aDadosConv, lInadimplente )

Local lRet := .T.	// Retorno da funcao
//�������������Ŀ
//�Processamento�
//���������������
Processa( { |lEnd| lRet  := CR250ProcInad( cCodCli, cLojCli     , cCodClFim, cLojClFim,;
											lTPLDRO,  @aDadosConv, @lInadimplente ) },;
											STR0047,, .F.)   //"Processando os clientes..."

Return (lRet)
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CR250ProcInad �Autor  �Thiago Honorato     � Data �  08/08/06  ���
����������������������������������������������������������������������������͹��
���Desc.     � Posiciona nos  clientes e seus rspectivos cartoes.          	 ���
����������������������������������������������������������������������������͹��
���Uso       � Chamada a partir da funcao CRD250Inadimplentes()		      	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codido do cliente inicial                           	 ���
���          �ExpC2 - Codido da loja inicial                             	 ���
���          �ExpC3 - Codido do cliente final                            	 ���
���          �ExpC4 - Codido da loja final                               	 ���
���          �ExpL1 - Controle se esta' usando o Template Drogaria         	 ���
���          �ExpA1 - Array com informacoes dos clientes                  	 ���
���          �ExpL1 - Controla se o cliente esta' inadimplente ou nao	     ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida o processamento dos clientes inadimplentes   	 ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 ���
����������������������������������������������������������������������������͹��
���          �        �      �                            	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function CR250ProcInad( cCodCli, cLojCli   , cCodClFim, cLojClFim,;
							   lTPLDRO, aDadosConv, lInadimplente )

Local cCodAux  := ""	 	// Codigo do Cliente
Local cLojAux  := ""   		// Loja
Local cNomeCli := ""	 	// Nome do cliente
Local nQtdeCli := 0	 		// Controla o numero de cliente selecionados
Local lInad    := .F.		// Controla se o cliente esta inadimplente ou nao
Local lRet 	   := .T.		// Retorno da funcao	

aDadosConv := {}	// Array com todos os clientes selecionados

//���������������������������������������Ŀ
//�Posicionamento nos clientes atraves da �
//�empresa de convenio.                   �
//�Somente o TPL-Drogaria usa este filtro �
//�����������������������������������������
If lTPLDRO
	//���������������������������������������Ŀ
	//�Posicionamento da empresa de convenio  �
	//�����������������������������������������
	DbSelectArea("SA1")
	DbOrderNickname("SA1DRO2")  
	If !MsSeek(xFilial("SA1") + cCodCli + cLojCli) // A1_FILIAL + A1_COD + A1_LOJA
		lRet := .F.
	Endif
	
	If lRet  
		While !Eof() .AND. xFilial("SA1") + cCodCli + cLojCli == A1_FILIAL + A1_EMPCONV + A1_LOJCONV	
			cCodAux	 := A1_COD
			cLojAux  := A1_LOJA
			cNomeCli := Posicione( "SA1",1,xFilial("SA1") + cCodAux + cLojAux, "A1_NOME" )	
			//�����������������������������������������������Ŀ
			//�Funcao que verifica se o cliente esta'         �
			//�inadimplente ou nao.                           �
			//�������������������������������������������������						
			If CR250VerifInad( cCodAux, cLojAux )
				lInadimplente := .T.
			Else
				lInadimplente := .F.
			Endif
			If lInadimplente
				DbSelectArea("MA6")
				DbSetOrder(2)
				If MsSeek(xFilial("MA6") + cCodAux + cLojAux ) //MA6_FILIAL + MA6_CODCLI + MA6_LOJA
					//�����������������������������������������������Ŀ
					//�Verifica todos os cartoes amarrados ao cliente.�
					//�������������������������������������������������
					While !Eof() .AND. xFilial("MA6") + cCodAux + cLojAux == MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA
						//�����������������������������������������������Ŀ
						//�Cartoes CANCELADOS nao poderao ser alterados   �
						//�������������������������������������������������
						If MA6_SITUA <> "3" //CANCELADO
							If MA6_SITUA == "1"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif							
						Else	
							DbSkip()
					        Loop			    	    			
						Endif
			
				        DbSkip()			
					End	
				Else
			    	MsgAlert(STR0048)		 //"Os cliente conveniados a esta empresa n�o possuem cart�es!"
			    	lRet := .F.
				Endif
			Endif	
			
			SA1->(DbSkip())
				
		End
	EndIf						
Else
	DbSelectArea("SA1")
	DbSetOrder(1)
	If MsSeek(xFilial("SA1")+cCodCli+cLojCli,.T.)
 		While !SA1->(Eof()) .AND.	xFilial("SA1") + cCodCli   + cLojCli <= SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA .AND.;
									xFilial("SA1") + cCodClFim + cLojClFim >= SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA    
			cCodAux	 := A1_COD
			cLojAux  := A1_LOJA
			cNomeCli := Posicione( "SA1",1,xFilial("SA1") + cCodAux + cLojAux, "A1_NOME" )	
			//�����������������������������������������������Ŀ
			//�Funcao que verifica se o cliente esta'         �
			//�inadimplente ou nao.                           �
			//�������������������������������������������������						
			If CR250VerifInad( cCodAux, cLojAux )
				lInadimplente := .T.
			Else                    
				lInadimplente := .F.
			Endif
			//�����������������������������������������������Ŀ
			//�Caso o cliente esteja inadimplente, o mesmo    �
			//�sera' selecionado para efetuar o bloqueio de   �
			//�seu cartao                                     �
			//�������������������������������������������������			
			If lInadimplente
				DbSelectArea("MA6")
				DbSetOrder(2)
				If MsSeek(xFilial("MA6") + cCodAux + cLojAux ) //MA6_FILIAL + MA6_CODCLI + MA6_LOJA
					//�����������������������������������������������Ŀ
					//�Verifica todos os cartoes amarrados ao cliente.�
					//�������������������������������������������������
					While !Eof() .AND. xFilial("MA6") + cCodAux + cLojAux == MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA
						//�����������������������������������������������Ŀ
						//�Cartoes CANCELADOS nao poderao ser alterados   �
						//�������������������������������������������������
						If MA6_SITUA <> "3" //CANCELADO
							If MA6_SITUA == "1"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif							
						Else	
							DbSkip()
					        Loop			    	    			
						Endif
			
				        DbSkip()			
					End	
				Endif
            Endif
			SA1->(DbSkip())
		End	
	EndIf            
Endif
If Len(aDadosConv) == 0
	MsgAlert(STR0049) //"N�o foi encontrado nenhum cliente Inadimplente!"
	lRet := .F.
Endif

If lRet
    oArrayConv:SetArray(aDadosConv)
   	oArrayConv:bLine := { ||{ If(aDadosConv[oArrayConv:nAt,1] > 0,oOk,If(aDadosConv[oArrayConv:nAt,1] < 0,oNo,oNever)),;
                             	  aDadosConv[oArrayConv:nAT][CODCLI],;
	 		  					  aDadosConv[oArrayConv:nAT][LOJACLI],;
      	                     	  aDadosConv[oArrayConv:nAT][NOMECLI],;
      	                     	  aDadosConv[oArrayConv:nAT][NUMCART]}} 		
Endif  

Return lRet
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CR250VerifInad    �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Verifica se o cliente esta' inadimplente ou nao                   ���
��������������������������������������������������������������������������������͹��
���Uso       � Chamada a partir da funcao CR250ProcInad()	 		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do cliente a ser analisado                          ���
���          �ExpC2 - Loja do cliente a ser analisado                            ���
��������������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Indica se o cliente analisado esta' inadimplente ou nao	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CR250VerifInad( cCodCli, cLoja )

Local aLjFilWS  := StrToKArr(SuperGetmv("MV_LJFILWS"), ",")	// Intervalo de filiais para limite de credito

Local aArea		:= {}	    							// Salva a area atual
Local aFils 	:= {}        							// Array com todas as filiais do intervado informado no parametro MV_LJFILWS
Local lSE1Exc 	:= .F.									// Identifica se o SE1 - Contas a Receber esta em modo exclusivo
Local nTemp		:= 0									// Contador
Local dTitAnt   := CtoD("")								// Identifica a data do titulo mais antigo
Local nToler	:= 0									// Dias de titulo em atraso para realizar o bloqueio de cartao automaticamente
Local nk		:= 0									// Contador
Local lRet		:= .F.									// Retorno da funcao

aArea := GetArea()

lSE1Exc  :=  FWModeAccess("SE1",3) == "E"

If lSE1Exc
	DbSelectArea("SM0")
	dbGoTop()
	While SM0->(!EOF()) 
		If M0_CODIGO == cEmpAnt
			If FWGETCODFILIAL >= aLJFilWS[1] .AND. FWGETCODFILIAL <= aLJFilWS[2]
				Aadd(aFils, FWGETCODFILIAL)
			EndIf
		EndIf
		SM0->(DbSkip())
	End               
EndIf

DbSelectArea("SE1")
DbSetOrder(2)//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

If lSE1Exc 
	nTemp := Len(aFils)
	For nK := 1 To nTemp
		If MSSeek(aFils[nK]+cCodCli+cLoja)
			//����������������������������������������������Ŀ
			//�Verifica as datas dos vencimento dos titulos  �
			//������������������������������������������������		
			CR250DataTit(aFils[nK], cCodCli, cLoja, @dTitAnt)
		EndIf
	Next nK
Else
	If MSSeek(xFilial("SE1")+cCodCli+cLoja)
		//����������������������������������������������Ŀ
		//�Verifica as datas dos vencimento dos titulos  �
		//������������������������������������������������	
		CR250DataTit(xFilial("SE1"), cCodCli, cLoja, @dTitAnt)
	EndIf
EndIf

If !Empty(dTitAnt)
	nToler := SuperGetmv("MV_CRDBLCT")
	//����������������������������������������������Ŀ
	//�Verifica se os dias atrasado esta' maior que o�
	//�permitido                                     �
	//������������������������������������������������	
	If nToler > 0 .AND. ( dDataBase - dTitAnt ) >= nToler	
		//����������������������������������������������Ŀ
		//�Indica que o cliente analisado esta' 		 �
		//�inadimplente.	                             �
		//������������������������������������������������			
		lRet := .T.
	Endif	
Endif

Return ( lRet )
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CR250DataTit      �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Encontra a data dos titulos vencidos                              ���
��������������������������������������������������������������������������������͹��
���Uso       � Chamada a partir da funcao CR250VerifInad()	 		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Filial                                                     ���
���          �ExpC2 - Codigo do cliente                                          ���
���          �ExpC3 - Loja do cliente                                            ���
���          �ExpD1 - Data base do sistema                                       ���
��������������������������������������������������������������������������������͹��
���Retorno   �                                                            	 	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CR250DataTit( cFilPar, cCodCli, cLoja, dDt )

Local cMVCRDTPLC := SuperGetmv("MV_CRDTPLC")		//Tipos dos titulos que entrarao na soma dos titulos em aberto para abater do limite do cliente

If dDt == CtoD("")
	dDt := dDataBase
EndIf

While SE1->(!EOF()) .AND. SE1->E1_FILIAL == cFilPar .AND. SE1->E1_CLIENTE == cCodCli .AND. SE1->E1_LOJA == cLoja
	If SE1->E1_VENCREA < dDt .AND. SE1->E1_SALDO > 0
		If ALLTRIM(SE1->E1_TIPO) $ cMVCRDTPLC .AND. SE1->E1_VENCREA < dDt
			dDt := SE1->E1_VENCREA
		EndIf
	EndIf
	SE1->(DbSkip())
End

Return NIL
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CRD250ProcCart�Autor  �Thiago Honorato     � Data �  08/08/06  ���
����������������������������������������������������������������������������͹��
���Desc.     � Processa os clientes e seus rspectivos cartoes.           	 ���
����������������������������������������������������������������������������͹��
���Uso       � Chamada a partir da funcao CRD250SeekCart()			      	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codido do cliente inicial                           	 ���
���          �ExpC2 - Codido da loja inicial                             	 ���
���          �ExpC3 - Codido do cliente final                            	 ���
���          �ExpC4 - Codido da loja final                               	 ���
���          �ExpL1 - Verifica se esta' usando o template Drogaria        	 ���
���          �ExpN1 - Codigo da situacao escolhida inicialmente           	 ���
���          �ExpA1 - Array com informacoes dos clientes                  	 ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Encontrou ou nao os clientes de acordo com o filtro.	 ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 ���
����������������������������������������������������������������������������͹��
���          �        �      �                            	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function CRD250ProcCart( cCodCli, cLojCli  , cCodClFim , cLojClFim,;
							    lTPLDRO, nSituacao, aDadosConv )


Local cCodAux	 := ""	 	// Codigo do Cliente
Local cLojAux    := ""   	// Loja
Local cNomeCli	 := ""	 	// Nome do cliente
Local nQtdeCli   := 0	 	// Controla o numero de cliente selecionados
Local lRet 		 := .T.		// Retorno da funcao	

aDadosConv := {}	// Array com todos os clientes selecionados pela rotina

//���������������������������������������Ŀ
//�Posicionamento nos clientes atraves da �
//�empresa de convenio.                   �
//�Somente o TPL-Drogaria usa este filtro �
//�����������������������������������������
If lTPLDRO
	//���������������������������������������Ŀ
	//�Posicionamento da empresa de convenio  �
	//�����������������������������������������
	SA1->(DbGoTop())
	DbSelectArea("SA1")
    DbOrderNickname("SA1DRO2")	
	If !MsSeek(xFilial("SA1") + cCodCli + cLojCli) // A1_FILIAL + A1_EMPCONV + A1_LOJCONV
		MsgAlert(STR0050) //"N�o existe nenhum cliente conveniado para esta empresa!"
		lRet := .F.
	Endif	
	If lRet
		While !Eof() .AND. xFilial("SA1") + cCodCli + cLojCli == A1_FILIAL + A1_EMPCONV + A1_LOJCONV	
			cCodAux	 := A1_COD
			cLojAux  := A1_LOJA
			cNomeCli := Posicione( "SA1",1,xFilial("SA1") + cCodAux + cLojAux, "A1_NOME" )	
			DbSelectArea("MA6")
			DbSetOrder(2)
			If MsSeek(xFilial("MA6") + cCodAux + cLojAux ) //MA6_FILIAL + MA6_CODCLI + MA6_LOJA
				//�����������������������������������������������Ŀ
				//�Verifica todos os cartoes amarrados ao cliente.�
				//�������������������������������������������������
				While !Eof() .AND. xFilial("MA6") + cCodAux + cLojAux == MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA
					//�����������������������������������������������Ŀ
					//�Cartoes CANCELADOS nao poderao ser alterados   �
					//�������������������������������������������������
					If MA6_SITUA <> "3" //CANCELADO
						//�����������������������������������������������������������Ŀ
						//�nSituacao                                                  �
						//�1 = Desbloquear                                            �
						//�Selecionar: Cart�o Novo - Perda/Furot - Bloqueio Autom�tico�
						//�                                                           �
						//�2 = Bloquear                                               �
						//�Selecionar: Cart�o Novo                                    �
						//�                                                           �
						//�3 = Cancelar                                               �
						//�Selecionar: Cart�o Novo                                    �
						//�������������������������������������������������������������
						If 	nSituacao == 1 //Desbloquear
							//If (MA6_SITUA == "1" .AND. MA6_MOTIVO <> "1") .OR.  (MA6_SITUA == "2" .AND. MA6_MOTIVO <> "1" )
							If MA6_SITUA == "2"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif
						ElseIf nSituacao == 2 .OR. nSituacao == 3 //Bloquear ou Cancelar
							If MA6_SITUA == "1"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif							
						Endif
					Else	
						DbSkip()
				        Loop			    	    			
					Endif
		
			        DbSkip()
				End	
			Else
		    	MsgAlert(STR0048)		 //"Os cliente conveniados a esta empresa n�o possuem cart�es!"
		    	lRet := .F.
			Endif
			
			SA1->(DbSkip())
		End
	EndIf
Else
	DbSelectArea("SA1")
	DbSetOrder(1)
	If MsSeek(xFilial("SA1")+cCodCli+cLojCli,.T.)
 		While !SA1->(Eof()) .AND.	xFilial("SA1") + cCodCli   + cLojCli   <= SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA .AND.;
									xFilial("SA1") + cCodClFim + cLojClFim >= SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA    
			cCodAux	 := A1_COD
			cLojAux  := A1_LOJA
			cNomeCli := Posicione( "SA1",1,xFilial("SA1") + cCodAux + cLojAux, "A1_NOME" )	
			DbSelectArea("MA6")
			DbSetOrder(2)
			If MsSeek(xFilial("MA6") + cCodAux + cLojAux ) //MA6_FILIAL + MA6_CODCLI + MA6_LOJA
				//�����������������������������������������������Ŀ
				//�Verifica todos os cartoes amarrados ao cliente.�
				//�������������������������������������������������
				While !Eof() .AND. xFilial("MA6") + cCodAux + cLojAux == MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA
					//�����������������������������������������������Ŀ
					//�Cartoes CANCELADOS nao poderao ser alterados   �
					//�������������������������������������������������
					If MA6_SITUA <> "3" //CANCELADO
						//�����������������������������������������������������������Ŀ
						//�nSituacao                                                  �
						//�1 = Desbloquear                                            �
						//�Selecionar: Cartao Novo - Perda/Furto - Bloqueio Automatico�
						//�                                                           �
						//�2 = Bloquear                                               �
						//�Selecionar: Cartao Novo                                    �
						//�                                                           �
						//�3 = Cancelar                                               �
						//�Selecionar: Cartao Novo                                    �
						//�������������������������������������������������������������
						If 	nSituacao == 1 //Desbloquear
							//If (MA6_SITUA == "1" .AND. MA6_MOTIVO <> "1") .OR.  (MA6_SITUA == "2" .AND. MA6_MOTIVO <> "1" )
							If MA6_SITUA == "2"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif
						ElseIf nSituacao == 2 .OR. nSituacao == 3 //Bloquear ou Cancelar
							If MA6_SITUA == "1"
						    	Aadd( aDadosConv, { -1, cCodAux, cLojAux, cNomeCli, MA6_NUM, .F. } )				
						    Else
								DbSkip()
						        Loop			    	    
							Endif							
						Endif
					Else	
						DbSkip()
				        Loop			    	    			
					Endif
		
			        DbSkip()			
				End	
			Endif

			SA1->(DbSkip())
		End	
	EndIf            
Endif

If Len(aDadosConv) == 0
	MsgAlert(STR0051) //"N�o foi encontrado nenhum cart�o para os clientes escolhidos!"
	lRet := .F.
Endif

If lRet
    oArrayConv:SetArray(aDadosConv)
   	oArrayConv:bLine := { ||{ If(aDadosConv[oArrayConv:nAt,1] > 0,oOk,If(aDadosConv[oArrayConv:nAt,1] < 0,oNo,oNever)),;
                             	  aDadosConv[oArrayConv:nAT][CODCLI],;
	 		  					  aDadosConv[oArrayConv:nAT][LOJACLI],;
      	                     	  aDadosConv[oArrayConv:nAT][NOMECLI],;
      	                     	  aDadosConv[oArrayConv:nAT][NUMCART]}} 		
Endif  

Return lRet
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CRD250VldCli  �Autor  �Thiago Honorato     � Data �  08/08/06  ���
����������������������������������������������������������������������������͹��
���Desc.     � Validacao dos campos do Panel 2                           	 ���
����������������������������������������������������������������������������͹��
���Uso       �Segundo PANEL - funcao CRDA250()         				      	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codido do cliente inicial                           	 ���
���          �ExpC2 - Codido da loja inicial                             	 ���
���          �ExpC3 - Codido do cliente final                            	 ���
���          �ExpC4 - Codido da loja final                               	 ���
���          �ExpL1 - verifica se o filtra esta' sendo realizado pela empresa���
���          �        de convenio.(neste caso, Template Drogaria)            ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida os dados de entrada                   	         ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 ���
����������������������������������������������������������������������������͹��
���          �        �      �                            	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function CRD250VldCli( cCodCli, cLojCli, cCodClFim, cLojClFim,;
							  lTPLDRO )

Local lRet  := .T.	//retorno da funcao

//�������������������������������������������������������������������������Ŀ
//�Validacao para o filtra referente a empresa de convenio... TPL - Drogaria�
//���������������������������������������������������������������������������
If lTPLDRO
	If Empty(cCodCli)
	   MsgAlert(STR0052) //"Preencher o codigo da empresa de conv�nio."
	   lRet  := .F.
	EndIf
	
	If lRet .AND. Empty(cLojCli)
	   MsgAlert(STR0053) //"Preencher a loja da empresa de conv�nio."
	   lRet  := .F.
	EndIf
	
	SA1->(DbSetOrder(1))
	If lRet .AND. SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli)) //A1_FILIAL + A1_COD + A1_LOJA
	   If !(lRet  := SA1->A1_TPCONVE == "4")
	      MsgAlert(STR0054) //"O cliente selecionado n�o � uma empresa de conv�nio. Verificar o campo Tipo de Conv�nio."
	   EndIf   
	EndIf  
Else 
	//�������������������������������������������������������Ŀ
	//�Validacao para o filtra referente aos clientes - PADRAO�
	//���������������������������������������������������������
	If Empty(cCodCli)
	   MsgAlert(STR0055) //"Preencher o codigo do cliente inicial."
	   lRet  := .F.
	EndIf
	
	If lRet .AND. Empty(cLojCli)
	   MsgAlert(STR0056) //"Preencher a loja do cliente inicial."
	   lRet  := .F.
	EndIf
	
	If lRet .AND. Empty(cCodClFim)
	   MsgAlert(STR0057) //"Preencher o codigo do cliente final."
	   lRet  := .F.
	EndIf
	
	If lRet .AND. Empty(cLojClFim)
	   MsgAlert(STR0058) //"Preencher a loja do cliente final."
	   lRet  := .F.
	EndIf
Endif

Return ( lRet )
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CRD250MontaArray  �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Montagem de um array auxiliar                            	 	 ���
��������������������������������������������������������������������������������͹��
���Uso       � Setimo PANEL - funcao CRDA250()               		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpA1 - Array com informacoes para a montagem do array principal   ���
��������������������������������������������������������������������������������͹��
���Retorno   �ExpA1 - Estrutura do array principal.                       	 	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CRD250MontaArray( aCpos )

Local aC := {}	// array auxiliar
Local nX := 0	// controle de loop	

aC := Array(1,Len(aCpos)+1)
aC[1][1] := -1

SX3->(DBSetOrder(2))
For nX := 2 to Len(aCpos)
   If SX3->(MsSeek(aCpos[nX]))
      aC[Len(aC)][nX]   := CriaVar(aCpos[nX])
   Else
      aC[Len(aC)][nX]   := &(aCpos[nX])
   Endif
Next nX

aC[Len(aC)][Len(aC[1])]:= .F.

Return( aC )
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CRD250Marc        �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Marca o registro no aCols quando e' clicado duas vezes.           ���
��������������������������������������������������������������������������������͹��
���Uso       � Setimo PANEL - funcao CRDA250()               		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Variavel de controle para a opcao 'Marcar Todos'           ���
���          �ExpO1 - Objeto para a opcao 'Marcar Todos'                         ���
���          �ExpA1 - Array com informacoes dos clientes                         ���
��������������������������������������������������������������������������������͹��
���Retorno   �                                                            	 	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CRD250Marc(lMarcAll, oMarcAll, aDadosConv )

aDadosConv[oArrayConv:nAt,1] := aDadosConv[oArrayConv:nAT,1] * -1
oArrayConv:Refresh()

lMarcAll := .F.

oMarcAll:Refresh()

Return .T.
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CRD250All         �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Marca todos os registros do aCols aArrayConv                      ���
��������������������������������������������������������������������������������͹��
���Uso       � Setimo PANEL - funcao CRDA250()               		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Variavel de controle para a opcao 'Marcar Todos'           ���
���          �ExpA1 - Array com informacoes dos clientes                         ���
��������������������������������������������������������������������������������͹��
���Retorno   �                                                            	 	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CRD250All( lMarcAll, aDadosConv )
Local nx 	:= 0	// controle de loop
Local nMarc := -1	// opcao para Marcar (1) ou Desmarcar (-1) 

If lMarcAll 
	nMarc := 1 	
Endif

For nX := 1 TO Len(aDadosConv)
	aDadosConv[nX][1] := nMarc
Next nX

oArrayConv:Refresh()

Return .T.
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �CRD250AtuMA6      �Autor  �Thiago Honorato     � Data �  08/08/06  ���
��������������������������������������������������������������������������������͹��
���Desc.     � Atualiza os registro da tabela MA6.                               ���
��������������������������������������������������������������������������������͹��
���Uso       � Setimo PANEL - funcao CRDA250()               		      	 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Situacao escolhida inicialmente                            ���
���          �ExpN2 - Motivo escolhido inicialmente                              ���
���          �ExpN3 - Quantidade de registros processados                        ���
���          �ExpA1 - Array com as informacoes dos clientes                      ���
���          �ExpL1 - Controla se o cliente esta' inadimplente ou nao	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - confirmacao do processamento                         	 	 ���
��������������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada            	         	 	 ���
��������������������������������������������������������������������������������͹��
���          �        �      �                            	             	     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CRD250AtuMA6( nSituacao, nMotivo, nQtdeCli, aDadosConv,;
							  lInadimplente )

Local nX   	  := 0		// controle de loop
Local lRet 	  := .T.	// retorno da funcao
Local lAtuMA6 := .F.	// verifica o retorno da funcao CRDVencCli
Local lSel	  := .F.	// verifica se existe pelo menos um registro selecionado pra o processamento.

If !MsgYesNo(STR0059) //"Confirma as altera��es para os cliente selecionados?"
	lRet := .F.
Endif

If lRet
	DbSelectArea("MA6")
	DbSetOrder(1)
	For nX := 1 TO Len(aDadosConv)
		If aDadosConv[nX][1] = 1
			lSel := .T.
			If lInadimplente// verifica se as alteracoes serao somente para os cliente inadimplentes
				//�������������������������������������������������������������Ŀ
				//�CRDVencCli() - funcao que atualiza os registros da tabela MA6�
				//�caso o cliente esteja inadimplente.                          �
				//���������������������������������������������������������������
				lAtuMA6 := CRDVencCli(aDadosConv[nX][2],aDadosConv[nX][3], @lAtuMA6)
				If lAtuMA6
					nQtdeCli++	    
				Endif
			Else
				If MsSeek(xFilial("MA6") + aDadosConv[nX][5])
			    	BEGIN TRANSACTION
				    Reclock("MA6",.F.)   
					REPLACE MA6_SITUA  WITH AllTrim(Str( nSituacao ))
					REPLACE MA6_MOTIVO WITH AllTrim(Str( nMotivo ))
				    MsUnlock()            
					nQtdeCli++	          
					END TRANSACTION
				Endif
			Endif
		Endif	
	Next nX
Endif                       

If !lSel .AND. lRet
	MsgAlert(STR0060) //"Favor selecionar pelo menos um registro para efetuar o processamento!"
	lRet := .F.
Endif

Return lRet