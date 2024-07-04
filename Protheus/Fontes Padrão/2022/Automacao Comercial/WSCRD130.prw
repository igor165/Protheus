#INCLUDE "WSCRD130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 
Function ___WSCRD130
Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WSCRD130  �Autor  �Thiago Honorato	 � Data �  FEV/2006   ���
�������������������������������������������������������������������������͹��
���Desc.     �WEBSERVICES que busca a numeracao de cartao do cliente      ���
���          �Verifica o STATUS do cartao e se o LIMITE DE CREDITO esta'  ���
���          �igual a zero 				                                  ���
���          �Atualiza o Status do cartao apos efetuar um recebimento de  ���
���          �titulos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������Ĺ��
��� Progr.   � Data     BOPS   Descricao								  ���
�������������������������������������������������������������������������Ĺ��
���Thiago H. �13/06/07�116926�Criado o atributo lRecebimento na qual	  ���
���          �        �      �indica se a rotina de Recebimento de		  ���
���          �        �      �Titulos esta sendo executada				  ���
���          �        �      �Metodos Alterados:           				  ���
���          �        �      � PesqCartao                  				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//Esrutura
WSSTRUCT WSINFO1
	WSDATA CARTAO		AS String
	WSDATA MENSAGEM		As String
ENDWSSTRUCT                                

WSSTRUCT WSINFO2
	WSDATA ATIVO  		AS Boolean	  
	WSDATA MENSAGEM		As String
ENDWSSTRUCT

//Classes
	WSSERVICE CRDINFOCART DESCRIPTION STR0001 //"Informacoes referentes aos cartoes..."
	//Atributos
	WSDATA USRSESSIONID	AS String
	WSDATA FILIAL       As String
	WSDATA CODCLI       As String
	WSDATA LOJACLI      As String	
	WSDATA NUMCART      As String
	WSDATA LRECEBIMENTO AS Boolean OPTIONAL		
	WSDATA RETCART1		As Array of WSINFO1
	WSDATA RETCART2		As Array of WSINFO2
	//Metodos	
	WSMETHOD PESQCARTAO
	WSMETHOD ATUALIZACARTAO	

ENDWSSERVICE
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WSMETHOD  �PesqCartao�Autor  �Andre / Thiago      � Data �  03/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TPLDRO                                                     ���
�������������������������������������������������������������������������Ĺ��
��� Progr.   � Data     BOPS   Descricao								  ���
�������������������������������������������������������������������������Ĺ��
���A.Veiga   �14/03/06�Drog. �Alteracao da estrutura do WebService para   ���
���          �        �Moder-�considerar as mensagens de cartao "Ativo"   ���
���          �        �na    �ou nao para a venda. Se o cartao estiver    ���
���          �        �      �bloqueado, permite continuar a venda mas    ���
���          �        �      �no final o pagamento nao podera ser feito   ���
���          �        �      �atraves de financiamento.                   ���
���Thiago H. �04/05/06�97894 �Alterado o parametro WSSEND de NUMCART p/   ���
���          �        �      �RetCart1                                    ���
���          �        �      �NUMCART eh do tipo string                   ���
���          �        �      �Retcart1 eh do tipo estrutura (array)       ���
���Thiago H. �13/03/07�121164�Alterado de Static Function para somente    ���
���          �        �      �Function a funcao LjBuscaCartao()           ���
���          �        �      �Com isso a mesma podera ser chamada         ���
���          �        �      �por outros programas.                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD PESQCARTAO WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli, lRecebimento WSSEND RetCart1 WSSERVICE CRDINFOCART

Local aRet	:= {}		//Array que contem as informacoes do cliente

//��������������������������������������������������������������������Ŀ
//�Verifica a validade e integridade do ID de login do usuario         �
//����������������������������������������������������������������������
If !IsSessionVld( ::UsrSessionID )
	Return(.F.)
Endif

aRet := LjBuscaCartao(::Filial, ::CodCli, ::LojaCli, ::lRecebimento)

If !aRet[1]
	SetSoapFault(aRet[3], aRet[4])
	Return(.F.)
Else
	::RetCart1 := Array( 1 )
	::RetCart1[1]			:= WSClassNew( "WSINFO1" )
	::RetCart1[1]:Cartao 	:= aRet[2]
	::RetCart1[1]:Mensagem 	:= aRet[4]
EndIf

Return .T.
/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���WSMETHOD  �ATUALIZACARTAO�Autor  �Thaigo Honorato     � Data �  24/01/07   ���
�����������������������������������������������������������������������������͹��
���Desc.     �Atualiza os cartoes do cliente                                  ���
�����������������������������������������������������������������������������͹��
���Uso       �                         	                                      ���
�����������������������������������������������������������������������������Ĺ��
��� Progr.   � Data     BOPS   Descricao		    	  				      ���
�����������������������������������������������������������������������������Ĺ��
���          �        �      �              	                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
WSMETHOD ATUALIZACARTAO WSRECEIVE USRSESSIONID, CODCLI, LOJACLI WSSEND RETCART2 WSSERVICE CRDINFOCART

Local aRet := {}
//��������������������������������������������������������������������Ŀ
//�Verifica a validade e integridade do ID de login do usuario         �
//����������������������������������������������������������������������
If !IsSessionVld( ::UsrSessionID )
	Return(.F.)
Endif

aRet := UPDCartao( ::CODCLI, ::LOJACLI )

If !aRet[1]
	SetSoapFault(aRet[2], aRet[3])
	Return(.F.)
Else
	::RetCart2 				:= Array( 1 )
	::RetCart2[1]			:= WSClassNew( "WSINFO2" )
	::RetCart2[1]:ATIVO 	:= aRet[1]
	::RetCart2[1]:MENSAGEM 	:= aRet[3]
EndIf

Return .T.                                      
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Funcoes   �LjPesqCar    �Autor  �Thiago Honorato     � Data �  24/01/07   ���
����������������������������������������������������������������������������͹��
���Desc.     �Busca o cartao do cliente e verifica a situacao do mesmo       ���
����������������������������������������������������������������������������͹��
���Uso       �                                                               ���
����������������������������������������������������������������������������͹��
��� Progr.   � Data     BOPS   Descricao		    	  				     ���
����������������������������������������������������������������������������͹��
���          �        �      �              	                             ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/          
Function LjBuscaCartao(cFilCli, cCodCli, cLojaCli, lRecebimento)

Local aAreaAtu   	:= GetArea()
Local aRet       	:= Array(4)			// Retoro da funcao
Local nLimite    	:= 0 				// Traz o valor do LIMITE DE CREDITO do cliente

Local lBloqVenda	:= .T. 				// Indica se e' para bloquear a venda ou nao 
Local lCartAtivo	:= .F.				// Indica se tem cartao ativo 
Local lCartBloq		:= .F.				// Indica se tem cartao bloqueado
Local lCartCanc		:= .F. 				// Indica se tem cartao cancelado
Local cMsg 			:= "" 				// Mensagem para o usu�rio
Local cNumeroCart	:= ""				// Numero do cartao
Local aNumeroCart	:= {}				// Array com os numeros de cartao do cliente cadastrado no MA6
Local nMotivo		 := 0				// Motivo  

DEFAULT lRecebimento := .F.				

//����������������������������������������������������������������������Ŀ
//� Define a variavel com o limite de credito do cliente                 �
//������������������������������������������������������������������������
nLimite := Posicione("SA1",1,cFilCli+cCodCli+cLojaCli,"A1_LC")

//�������������������������������������������������������������Ŀ
//�Estrutura do array aRet  - Template Drogaria                 �
//�-------------------------------------------------------------�
//�-    aRet[1]  =  .F. = bloqueia a venda                      �
//�-                .T. = nao bloqueia a venda                  �
//�-    aRet[2]  =  numero do cartao                            �
//�-    aRet[3]  =  Titulo da janela de aviso                   �
//�-    aRet[4]  =  Mensagem da janela de aviso                 �
//�-------------------------------------------------------------�
//���������������������������������������������������������������
DbSelectArea("MA6")
DbSetOrder(2)
If DbSeek(cFilCli+cCodCli+cLojaCli)
	While !Eof() .AND. cFilCli+cCodCli+cLojaCli == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		If !Empty(MA6->MA6_CODDEP)
			DbSkip()
			Loop
		EndIf   
	
		//����������������������������������������������������������������������Ŀ
		//� Se o cartao estiver 'ativo' e o numero do cartao estiver preenchido  �
		//� libera a venda.                                                      �
		//����������������������������������������������������������������������ĳ
		//� Se o cartao estiver 'bloqueado' mostra msg para o usuario que o      �
		//� cartao esta bloqueado mas libera a venda para ser finalizada com     �
		//� outra forma de pagamento.                                            �
		//����������������������������������������������������������������������ĳ
		//� Caso esteja executando a rotina de recebimento de titulos            �
		//� ira' verificar os casos em que o cartao esteja como bloqueado e      �
		//� motivo igual a 5 - atraso.                                           �
		//����������������������������������������������������������������������ĳ
		//� Se o cartao estiver 'cancelado' mostra a msg mas bloqueia a venda    �
		//� para este cliente. Caso o cliente queira continuar a compra ele      �
		//� nao sera' identificado, isto e', sera' feita a venda para o cliente  �
		//� padrao.                                                              �
		//����������������������������������������������������������������������ĳ
		//� Em qualquer um dos casos se nao houver limite no cartao, o operador  �
		//� do caixa sera' informado disto sem influenciar no bloqueio da venda  �
		//����������������������������������������������������������������������ĳ
		//� Status MA6_SITUA                                                     �
		//� "1" - Ativo                                                          �
		//� "2" - Bloqueado                                                      �
		//� "3" - Cancelado                                                      �
		//������������������������������������������������������������������������
		If ( MA6_SITUA == "1" .AND. !Empty(MA6_NUM) )
			lCartAtivo	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, STR0002} ) 	//"ATIVO"
		ElseIf ( lRecebimento .AND. MA6_SITUA == "2" .AND. !Empty(MA6_NUM) .AND. MA6_MOTIVO == "5" )
			nMotivo		:= 5
			lCartBloq	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, STR0003 } )	//"BLOQUEADO POR ATRASO" 
		ElseIf ( MA6_SITUA == "2" .AND. !Empty(MA6_NUM) )
			lCartBloq	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, STR0004 } ) //"BLOQUEADO"
		ElseIf ( MA6_SITUA == "3" .AND. !Empty(MA6_NUM) )
			lCartCanc	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, STR0005 } )	//"CANCELADO"	
		EndIf
	            
	   	DbSkip()
	End
EndIf
//����������������������������������������������������������������������Ŀ
//� Verifica qual o numero do cartao do cliente                          �
//� Verifica se tem algum ATIVO, se nao, verifica se tem algum bloqueado �
//� se nao, verifica o cancelado                                         �
//������������������������������������������������������������������������
If lCartAtivo
	nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == STR0002 } )  		//"ATIVO"
	cNumeroCart := aNumeroCart[nPosTmp][1]
ElseIf lCartBloq
	If nMotivo == 5
		nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == STR0003 } )	//"BLOQUEADO POR ATRASO"
		cNumeroCart := aNumeroCart[nPosTmp][1]	
	Else
		nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == STR0004 } ) 	//"BLOQUEADO"
		cNumeroCart := aNumeroCart[nPosTmp][1]	
	Endif
ElseIf lCartCanc
	nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == STR0005 } ) 		//"CANCELADO"
	cNumeroCart := aNumeroCart[nPosTmp][1]
Else 
	cNumeroCart := Space( TamSX3( "MA6_NUM" )[1] )
Endif

//����������������������������������������������������������������������Ŀ
//� Define se ira' bloquear a venda ou nao                               �
//����������������������������������������������������������������������ĳ
//� Obs.: A venda sera' liberada se o cartao estiver ativo ou bloqueado. �
//� - No caso de cartao cancelado, a venda sera' bloqueada para o cliente�
//� em referencia.                                                       �
//� - Se o cartao estiver bloqueado, libera a venda para o cliente ter   �
//� direito aos descontos do seu plano de fidelidade mas nao podera'     �
//� comprar no financiamento                                             �
//�                                                                      �
//������������������������������������������������������������������������
lBloqVenda := .F.
If lCartAtivo
	lBloqVenda := .F.
ElseIf lCartBloq
	lBloqVenda := .F.
ElseIf lCartCanc
	lBloqVenda := .T.
Endif

If !lBloqVenda
	//����������������������������������������������������������������������Ŀ
	//� Se o cartao estiver bloqueado, mostra msg para o usuario.            �
	//������������������������������������������������������������������������
	If lCartAtivo
		If nLimite == 0
			cMsg	:= STR0006	//"Cliente sem limite de cr�dito. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
		Endif
	ElseIf lCartBloq
		If nMotivo <> 5
			If nLimite == 0
				cMsg	:= STR0007	//"Cart�o bloqueado e cliente sem limite de cr�dito. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
			Else
				cMsg  	:= STR0008	//"Cart�o bloqueado. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
			Endif
		Else
			cMsg := STR0003			//"BLOQUEADO POR ATRASO"	
		Endif
	Endif
	
    aRet  := {	.T.,;
    			cNumeroCart,;
    			STR0009 ,;			//"Aten��o"
    			cMsg }
Else
	aRet[1] := .F.
	aRet[2] := ""
	aRet[3] := STR0009				//"Aten��o" 
	aRet[4] := STR0010				//"Cart�o cancelado. Favor encaminhar o cliente ao Departamento de Cr�dito."
EndIf

// Restaura area original
RestArea(aAreaAtu)

Return(aRet)
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Funcoes   �UPDCartao    �Autor  �Thiago Honorato     � Data �  24/01/07   ���
����������������������������������������������������������������������������͹��
���Desc.     �Atualiza a situacao dos cartoes do cliente                     ���
���          �cartao de titular e cartoes de dependentes                     ���
����������������������������������������������������������������������������͹��
���Uso       �                                                               ���
����������������������������������������������������������������������������͹��
��� Progr.   � Data     BOPS   Descricao		    	  				     ���
����������������������������������������������������������������������������͹��
���          �        �      �              	                             ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function UPDCartao( cCod, cLoj )
Local cNomeCliente := ""			// Nome do cliente	
Local lAtualiza    := .F.			// Verifica se atualiza ou nao os cartoes do cliente
Local aRet 		   := Array(3)		// Retorno da funcao
//�������������������������������������������������������������Ŀ
//�					Estrutura do array aRet  					�
//�-------------------------------------------------------------�
//�-    aRet[1]  =  .F. = nao possui cartao cadastrado          �
//�-                .T. = atualizou o cliente                   �
//�-    aRet[2]  =  Titulo da janela de aviso                   �
//�                 (caso a mensagem esteja vazia, significa que�
//�                  todos os cartoes estao com o campo SITUACAO�
//�                  igual a 'ATIVO'                            �
//�-------------------------------------------------------------�
//���������������������������������������������������������������
DbSelectArea("MA6")          
DbSetOrder(2)     
If DbSeek(xFilial("SA1") + cCod + cLoj)//FILIAL + COD.CLIENTE + LOJ.CLIENTE
	cNomeCliente := Posicione("SA1",1,xFilial("SA1")+ cCod + cLoj,"SA1->A1_NOME")
	While !Eof() .AND. xFilial("SA1") + cCod + cLoj == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		//��������������������������������������������������Ŀ
		//�Ira' desbloquear os cartoes somente que estao com �
		//�motivo igual a 5 - ATRASO                         �
		//����������������������������������������������������
		If MA6_SITUA == "2" .AND. MA6_MOTIVO == "5"
			RecLock("MA6",.F.)	
			MA6_SITUA  := "1"
			MA6_MOTIVO := "1"
			MsUnLock()
			lAtualiza := .T.			
		Else
			DbSkip()
			Loop			
		EndIf
	   	DbSkip()
	End	   
	If lAtualiza
		aRet[1] := .T.
		aRet[2] := STR0009		//"Aten��o"
		aRet[3] := STR0011 + RTrim(cNomeCliente) + STR0012 //"O cart�o do cliente " ## " foi desbloqueado!"
	Else
		aRet[1] := .T.	
		aRet[2] := STR0009		//"Aten��o"	
		aRet[3] := ""			
	Endif
Else
	aRet[1] := .F.	
	aRet[2] := STR0009			//"Aten��o"
	aRet[3] := STR0013			//"Cliente n�o possui cart�o!"
Endif

Return(aRet)
