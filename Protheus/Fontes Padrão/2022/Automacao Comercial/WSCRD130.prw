#INCLUDE "WSCRD130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 
Function ___WSCRD130
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WSCRD130  ºAutor  ³Thiago Honorato	 º Data ³  FEV/2006   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WEBSERVICES que busca a numeracao de cartao do cliente      º±±
±±º          ³Verifica o STATUS do cartao e se o LIMITE DE CREDITO esta'  º±±
±±º          ³igual a zero 				                                  º±±
±±º          ³Atualiza o Status do cartao apos efetuar um recebimento de  º±±
±±º          ³titulos                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º Progr.   ³ Data     BOPS   Descricao								  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºThiago H. ³13/06/07³116926³Criado o atributo lRecebimento na qual	  º±±
±±º          ³        ³      ³indica se a rotina de Recebimento de		  º±±
±±º          ³        ³      ³Titulos esta sendo executada				  º±±
±±º          ³        ³      ³Metodos Alterados:           				  º±±
±±º          ³        ³      ³ PesqCartao                  				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWSMETHOD  ³PesqCartaoºAutor  ³Andre / Thiago      º Data ³  03/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TPLDRO                                                     º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º Progr.   ³ Data     BOPS   Descricao								  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºA.Veiga   ³14/03/06³Drog. ³Alteracao da estrutura do WebService para   º±±
±±º          ³        ³Moder-³considerar as mensagens de cartao "Ativo"   º±±
±±º          ³        ³na    ³ou nao para a venda. Se o cartao estiver    º±±
±±º          ³        ³      ³bloqueado, permite continuar a venda mas    º±±
±±º          ³        ³      ³no final o pagamento nao podera ser feito   º±±
±±º          ³        ³      ³atraves de financiamento.                   º±±
±±ºThiago H. ³04/05/06³97894 ³Alterado o parametro WSSEND de NUMCART p/   º±±
±±º          ³        ³      ³RetCart1                                    º±±
±±º          ³        ³      ³NUMCART eh do tipo string                   º±±
±±º          ³        ³      ³Retcart1 eh do tipo estrutura (array)       º±±
±±ºThiago H. ³13/03/07³121164³Alterado de Static Function para somente    º±±
±±º          ³        ³      ³Function a funcao LjBuscaCartao()           º±±
±±º          ³        ³      ³Com isso a mesma podera ser chamada         º±±
±±º          ³        ³      ³por outros programas.                       º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD PESQCARTAO WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli, lRecebimento WSSEND RetCart1 WSSERVICE CRDINFOCART

Local aRet	:= {}		//Array que contem as informacoes do cliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a validade e integridade do ID de login do usuario         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWSMETHOD  ³ATUALIZACARTAOºAutor  ºThaigo Honorato     º Data º  24/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os cartoes do cliente                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                         	                                      º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º Progr.   ³ Data     BOPS   Descricao		    	  				      º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º          ³        ³      ³              	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD ATUALIZACARTAO WSRECEIVE USRSESSIONID, CODCLI, LOJACLI WSSEND RETCART2 WSSERVICE CRDINFOCART

Local aRet := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a validade e integridade do ID de login do usuario         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncoes   ³LjPesqCar    ºAutor  ºThiago Honorato     º Data º  24/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o cartao do cliente e verifica a situacao do mesmo       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Progr.   ³ Data     BOPS   Descricao		    	  				     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        º      º              	                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Function LjBuscaCartao(cFilCli, cCodCli, cLojaCli, lRecebimento)

Local aAreaAtu   	:= GetArea()
Local aRet       	:= Array(4)			// Retoro da funcao
Local nLimite    	:= 0 				// Traz o valor do LIMITE DE CREDITO do cliente

Local lBloqVenda	:= .T. 				// Indica se e' para bloquear a venda ou nao 
Local lCartAtivo	:= .F.				// Indica se tem cartao ativo 
Local lCartBloq		:= .F.				// Indica se tem cartao bloqueado
Local lCartCanc		:= .F. 				// Indica se tem cartao cancelado
Local cMsg 			:= "" 				// Mensagem para o usuário
Local cNumeroCart	:= ""				// Numero do cartao
Local aNumeroCart	:= {}				// Array com os numeros de cartao do cliente cadastrado no MA6
Local nMotivo		 := 0				// Motivo  

DEFAULT lRecebimento := .F.				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a variavel com o limite de credito do cliente                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLimite := Posicione("SA1",1,cFilCli+cCodCli+cLojaCli,"A1_LC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aRet  - Template Drogaria                 ³
//³-------------------------------------------------------------³
//³-    aRet[1]  =  .F. = bloqueia a venda                      ³
//³-                .T. = nao bloqueia a venda                  ³
//³-    aRet[2]  =  numero do cartao                            ³
//³-    aRet[3]  =  Titulo da janela de aviso                   ³
//³-    aRet[4]  =  Mensagem da janela de aviso                 ³
//³-------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MA6")
DbSetOrder(2)
If DbSeek(cFilCli+cCodCli+cLojaCli)
	While !Eof() .AND. cFilCli+cCodCli+cLojaCli == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		If !Empty(MA6->MA6_CODDEP)
			DbSkip()
			Loop
		EndIf   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o cartao estiver 'ativo' e o numero do cartao estiver preenchido  ³
		//³ libera a venda.                                                      ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Se o cartao estiver 'bloqueado' mostra msg para o usuario que o      ³
		//³ cartao esta bloqueado mas libera a venda para ser finalizada com     ³
		//³ outra forma de pagamento.                                            ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Caso esteja executando a rotina de recebimento de titulos            ³
		//³ ira' verificar os casos em que o cartao esteja como bloqueado e      ³
		//³ motivo igual a 5 - atraso.                                           ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Se o cartao estiver 'cancelado' mostra a msg mas bloqueia a venda    ³
		//³ para este cliente. Caso o cliente queira continuar a compra ele      ³
		//³ nao sera' identificado, isto e', sera' feita a venda para o cliente  ³
		//³ padrao.                                                              ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Em qualquer um dos casos se nao houver limite no cartao, o operador  ³
		//³ do caixa sera' informado disto sem influenciar no bloqueio da venda  ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Status MA6_SITUA                                                     ³
		//³ "1" - Ativo                                                          ³
		//³ "2" - Bloqueado                                                      ³
		//³ "3" - Cancelado                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual o numero do cartao do cliente                          ³
//³ Verifica se tem algum ATIVO, se nao, verifica se tem algum bloqueado ³
//³ se nao, verifica o cancelado                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se ira' bloquear a venda ou nao                               ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Obs.: A venda sera' liberada se o cartao estiver ativo ou bloqueado. ³
//³ - No caso de cartao cancelado, a venda sera' bloqueada para o cliente³
//³ em referencia.                                                       ³
//³ - Se o cartao estiver bloqueado, libera a venda para o cliente ter   ³
//³ direito aos descontos do seu plano de fidelidade mas nao podera'     ³
//³ comprar no financiamento                                             ³
//³                                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBloqVenda := .F.
If lCartAtivo
	lBloqVenda := .F.
ElseIf lCartBloq
	lBloqVenda := .F.
ElseIf lCartCanc
	lBloqVenda := .T.
Endif

If !lBloqVenda
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o cartao estiver bloqueado, mostra msg para o usuario.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCartAtivo
		If nLimite == 0
			cMsg	:= STR0006	//"Cliente sem limite de crédito. Não será permitido o fechamento da venda através de financiamento."
		Endif
	ElseIf lCartBloq
		If nMotivo <> 5
			If nLimite == 0
				cMsg	:= STR0007	//"Cartão bloqueado e cliente sem limite de crédito. Não será permitido o fechamento da venda através de financiamento."
			Else
				cMsg  	:= STR0008	//"Cartão bloqueado. Não será permitido o fechamento da venda através de financiamento."
			Endif
		Else
			cMsg := STR0003			//"BLOQUEADO POR ATRASO"	
		Endif
	Endif
	
    aRet  := {	.T.,;
    			cNumeroCart,;
    			STR0009 ,;			//"Atenção"
    			cMsg }
Else
	aRet[1] := .F.
	aRet[2] := ""
	aRet[3] := STR0009				//"Atenção" 
	aRet[4] := STR0010				//"Cartão cancelado. Favor encaminhar o cliente ao Departamento de Crédito."
EndIf

// Restaura area original
RestArea(aAreaAtu)

Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncoes   ³UPDCartao    ºAutor  ºThiago Honorato     º Data º  24/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a situacao dos cartoes do cliente                     º±±
±±º          ³cartao de titular e cartoes de dependentes                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Progr.   ³ Data     BOPS   Descricao		    	  				     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        º      º              	                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UPDCartao( cCod, cLoj )
Local cNomeCliente := ""			// Nome do cliente	
Local lAtualiza    := .F.			// Verifica se atualiza ou nao os cartoes do cliente
Local aRet 		   := Array(3)		// Retorno da funcao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³					Estrutura do array aRet  					³
//³-------------------------------------------------------------³
//³-    aRet[1]  =  .F. = nao possui cartao cadastrado          ³
//³-                .T. = atualizou o cliente                   ³
//³-    aRet[2]  =  Titulo da janela de aviso                   ³
//³                 (caso a mensagem esteja vazia, significa que³
//³                  todos os cartoes estao com o campo SITUACAO³
//³                  igual a 'ATIVO'                            ³
//³-------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MA6")          
DbSetOrder(2)     
If DbSeek(xFilial("SA1") + cCod + cLoj)//FILIAL + COD.CLIENTE + LOJ.CLIENTE
	cNomeCliente := Posicione("SA1",1,xFilial("SA1")+ cCod + cLoj,"SA1->A1_NOME")
	While !Eof() .AND. xFilial("SA1") + cCod + cLoj == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ira' desbloquear os cartoes somente que estao com ³
		//³motivo igual a 5 - ATRASO                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		aRet[2] := STR0009		//"Atenção"
		aRet[3] := STR0011 + RTrim(cNomeCliente) + STR0012 //"O cartão do cliente " ## " foi desbloqueado!"
	Else
		aRet[1] := .T.	
		aRet[2] := STR0009		//"Atenção"	
		aRet[3] := ""			
	Endif
Else
	aRet[1] := .F.	
	aRet[2] := STR0009			//"Atenção"
	aRet[3] := STR0013			//"Cliente não possui cartão!"
Endif

Return(aRet)
