#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1958.CH"

Function LOJA1958 ; Return  // "dummy" function - Internal Use  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCFrmCheque     บAutorณVENDAS CRM     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar ou confirmar os dados do cheque    บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCFrmCheque

	Data nBanco														//Numero do banco
   	Data nAgencia													//Numero da agencia
   	Data nConta														//Numero da conta
   	Data nCheque													//Numero do cheque
   	Data nC1														//C1
   	Data nC2														//C2
   	Data nC3														//C3
   	Data nCompensa													//Compensacao	
	Data oCompensa													//Objeto Get
	Data oBanco														//Objeto Get
	Data oAgencia													//Objeto Get
	Data oC1                                                        //Objeto Get
	Data oConta                                                     //Objeto Get
	Data oC2														//Objeto Get
	Data oCheque                                                    //Objeto Get
	Data oC3                                                        //Objeto Get
	Data oFont                                                      //Objeto Font
	Data oBtn        												//Objeto Botao
	Data oDlg                                                       //Objeto Dialog

	Method New()
	Method Show()
	Method ShowCMC7()    
	Method Validar()    

EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Self:ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCFrmCheque.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCFrmCheque  

	Self:nBanco			:= 0
   	Self:nAgencia		:= 0
   	Self:nConta			:= 0
   	Self:nCheque		:= 0
   	Self:nC1			:= 0
   	Self:nC2			:= 0
   	Self:nC3			:= 0
   	Self:nCompensa		:= 0
	Self:oCompensa		:= Nil
	Self:oBanco			:= Nil
	Self:oAgencia		:= Nil
	Self:oC1			:= Nil
	Self:oConta			:= Nil
	Self:oC2			:= Nil
	Self:oCheque		:= Nil
	Self:oC3			:= Nil
	Self:oFont			:= Nil
	Self:oBtn			:= Nil
	Self:oDlg      		:= Nil

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShow      บAutor  ณVendas Clientes     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a tela.							    				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Show() Class LJCFrmCheque

	DEFINE FONT Self:oFont NAME "Arial" SIZE 07,17 BOLD
	
	DEFINE MSDIALOG Self:oDlg TITLE STR0001 FROM 000,000 TO 130,553 PIXEL OF GetWndDefault() COLOR CLR_BLUE,CLR_WHITE ;
	STYLE DS_MODALFRAME STATUS //"Dados do Cheque"
	
		//Desabilita o esc da tela
		Self:oDlg:lEscClose := .F.	
		
		//Box - Mensagens recebidas do sitef
		@ 005,005 TO 40,273 PIXEL
			
		@10,010	SAY STR0002 FONT Self:oFont COLOR CLR_BLUE 					SIZE 030,10 OF Self:oDlg PIXEL 		//"Comp."
		@20,010	MSGET Self:oCompensa VAR Self:nCompensa PICTURE "@E 999"	SIZE 002,10 OF Self:oDlg PIXEL
	
		@10,045	SAY STR0005 FONT Self:oFont COLOR CLR_BLUE 					SIZE 030,10 OF Self:oDlg PIXEL		//"Banco"
		@20,045	MSGET Self:oBanco VAR Self:nBanco PICTURE "@E 999"	 		SIZE 004,10 OF Self:oDlg PIXEL
	
		@10,080	SAY STR0003 FONT Self:oFont COLOR CLR_BLUE 					SIZE 035,10 OF Self:oDlg PIXEL		//"Ag๊ncia"
		@20,080	MSGET Self:oAgencia VAR Self:nAgencia PICTURE "@E 9999"		SIZE 004,10 OF Self:oDlg PIXEL
	
		@10,115 SAY STR0004	FONT Self:oFont COLOR CLR_BLUE	 				SIZE 010,10 OF Self:oDlg PIXEL		//"C1"
		@20,115	MSGET Self:oC1  VAR Self:nC1	 PICTURE "@E 9"				SIZE 002,10 OF Self:oDlg PIXEL
		
		@10,140	SAY STR0006 FONT Self:oFont COLOR CLR_BLUE					SIZE 055,10 OF Self:oDlg PIXEL		//"Conta Corrente"
		@20,140	MSGET Self:oConta VAR Self:nConta PICTURE "@E 9999999999"	SIZE 050,10 OF Self:oDlg PIXEL
		
		@10,195	SAY STR0007 FONT Self:oFont COLOR CLR_BLUE					SIZE 010,10 OF Self:oDlg PIXEL		//"C2"
		@20,195	MSGET Self:oC2  VAR Self:nC2	 PICTURE "@E 9"				SIZE 002,10 OF Self:oDlg PIXEL
		
		@10,220	SAY STR0008 FONT Self:oFont COLOR CLR_BLUE					SIZE 025,10 OF Self:oDlg PIXEL		//"Numero do cheque"
		@20,220	MSGET Self:oCheque VAR Self:nCheque PICTURE "@E 999999"		SIZE 020,10 OF Self:oDlg PIXEL
				
		@10,260	SAY STR0009 FONT Self:oFont COLOR CLR_BLUE					SIZE 010,10 OF Self:oDlg PIXEL		//"C3"
		@20,260	MSGET Self:oC3  VAR Self:nC3	 PICTURE "@E 9"				SIZE 002,10 OF Self:oDlg PIXEL
		
		Self:oCompensa:SetFocus()    	
		
		@45,233 BUTTON Self:oBtn PROMPT STR0010 SIZE 40,15 OF Self:oDlg PIXEL ACTION (IIF(Self:Validar(),Self:oDlg:End(),.F.)) //"&Confirma"	
	
	ACTIVATE MSDIALOG Self:oDlg CENTERED
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShow      บAutor  ณVendas Clientes     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida os dados do cheque.			    				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Method Validar() Class LJCFrmCheque
	
	Local lRetorno 	:= .T.						//Retorno do metodo
	Local cMensagem	:= STR0011					//Mensagem de dado invแlido
	
	If Self:nBanco == 0
		STFMessage("SiTEF", "ALERT", cMensagem + " - " + STR0005)
		STFShowMessage( "SiTEF")
   		lRetorno := .F.
   		Self:oBanco:SetFocus()
   		Return lRetorno
   	EndIf
   	
   	If Self:nAgencia == 0
		STFMessage("SiTEF", "ALERT", cMensagem + " - " + STR0003)
		STFShowMessage( "SiTEF")
   		lRetorno := .F.
   		Self:oAgencia:SetFocus()
   		Return lRetorno
   	EndIf
   	
   	If 	Self:nConta == 0
		STFMessage("SiTEF", "ALERT", cMensagem + " - " + STR0006)
		STFShowMessage( "SiTEF")
   		lRetorno := .F.
   		Self:oConta:SetFocus()
   		Return lRetorno
   	EndIf
   	
   	If Self:nCheque == 0 
  		STFMessage("SiTEF", "ALERT", cMensagem + " - " + STR0008)
		STFShowMessage( "SiTEF" )
   		lRetorno := .F.
   		Self:oCheque:SetFocus()
   		Return lRetorno
   	EndIf
   	   	
   	If Self:nCompensa == 0
		STFMessage("SiTEF", "ALERT", cMensagem + " - " + STR0002)
		STFShowMessage( "SiTEF" )
   		lRetorno := .F.
   		Self:oCompensa:SetFocus()
   		Return lRetorno
   	EndIf
   	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShowCMC7  บAutor  ณVendas Clientes     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida os dados lido atraves do CMC7 e exibe a tela para    บฑฑ
ฑฑบ			 ณconfirmacao												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcDadosChq - Dados do cheque lido atraves do CMC7			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Method ShowCMC7(cDadosChq) Class LJCFrmCheque
	
	Local cCmc7 	:= ""							//Codigo cmc7 so com caracteres numericos
	Local nCount 	:= 0							//Variavel auxiliar contador
	
	//Exemplos:
	//Itau
	//=34162252= 0180002055^ 591270040651/
	//341 62252 0180002055 591270040651
	//1   4     9  12           24
	//
	//Caixa
	//=10415648= 0219000235^ 400100867951/
	//104 15648 0219000235 400100867951
	//1   4     9  12        21
	//
	//Unibanco
	//=40908171= 0213001635^ 059711473518/
	//409 08171 0213001635 059711473518
	//1   4     9  12          23
	
	
	//Considerando so os caracteres numericos
	For nCount := 1 To Len(cDadosChq)
		If IsDigit(Substr(cDadosChq, nCount, 1))
			cCmc7 += Substr(cDadosChq, nCount, 1)
		EndIf
	Next
		
	//Banco	
	Self:nBanco := Val(Substr(cCmc7, 1, 3))
    //Agencia
	Self:nAgencia := Val(Substr(cCmc7, 4, 4))
    //Compensacao
	Self:nCompensa := Val(Substr(cCmc7, 9, 3))
    //Cheque
	Self:nCheque := Val(Substr(cCmc7, 12, 6))
		
	Do Case
		//Banco do Brasil
		Case Self:nBanco == 1
			Self:nConta := Val(Substr(cCmc7, 23, 7))

        //Unibanco
		Case Self:nBanco == 409
			Self:nConta := Val(Substr(cCmc7, 23, 7))

        //Itau
		Case Self:nBanco == 341
			Self:nConta := Val(Substr(cCmc7, 24, 6))
        
		//Caixa Economica federal
		Case Self:nBanco == 104
			Self:nConta := Val(Substr(cCmc7, 21, 9))
        
		//Banco Frances e Brasileiro
		Case Self:nBanco == 348
			Self:nConta := Val(Substr(cCmc7, 24, 6))

   		//Benge
		Case Self:nBanco == 48
			Self:nConta := Val(Substr(cCmc7, 23, 7))
            
   		//Excel
		Case Self:nBanco == 641
			Self:nConta := Val(Substr(cCmc7, 21, 9))
            
        //Bradesco
		Case Self:nBanco == 237
			Self:nConta := Val(Substr(cCmc7, 23, 6))

		//Banestado
		Case Self:nBanco == 38
			Self:nConta := Val(Substr(cCmc7, 24, 6)) 

		//Sudameris
		Case Self:nBanco == 347
			Self:nConta := Val(Substr(cCmc7, 20, 6))

		//Noroeste
		Case Self:nBanco == 424
			Self:nConta := Val(Substr(cCmc7, 22, 8))

        //Panamericano
		Case Self:nBanco == 623
			Self:nConta := Val(Substr(cCmc7, 23, 7))
		
		//Santander
		Case Self:nBanco == 424
			Self:nConta := Val(Substr(cCmc7, 22, 8))

		//Nossa caixa
		Case Self:nBanco == 151
			Self:nConta := Val(Substr(cCmc7, 21, 9))

		//BankBoston
		Case Self:nBanco == 479
			Self:nConta := Val(Substr(cCmc7, 22, 8))

		//CityBank
		Case Self:nBanco == 745
			Self:nConta := Val(Substr(cCmc7, 22, 8))

		//America do Sul
		Case Self:nBanco == 215
			Self:nConta := Val(Substr(cCmc7, 23, 7))

		//Finasa
		Case Self:nBanco == 392
			Self:nConta := Val(Substr(cCmc7, 22, 8))
         
   		//Banespa
		Case Self:nBanco == 33
			Self:nConta := Val(Substr(cCmc7, 22, 8))

		//Banco Real
		Case Self:nBanco == 275
			Self:nConta := Val(Substr(cCmc7, 23, 7))

		//Bandeirantes
		Case Self:nBanco == 230
			Self:nConta := Val(Substr(cCmc7, 23, 7))

		//BMD
		Case Self:nBanco == 388
			Self:nConta := Val(Substr(cCmc7, 24, 6))

		//HSBC Bamerindus
		Case Self:nBanco == 399
			Self:nConta := Val(Substr(cCmc7, 24, 6))
        
		//Safra
		Case Self:nBanco == 422
			Self:nConta := Val(Substr(cCmc7, 23, 7))

		//BCN
		Case Self:nBanco == 291
			Self:nConta := Val(Substr(cCmc7, 23, 7))

		//Banco Holandes Unido
		Case Self:nBanco == 356
			Self:nConta := Val(Substr(cCmc7, 23, 8))
        
        //Outros
        OtherWise
        	Self:nConta := Val(Substr(cCmc7, 23, 7))
				
	EndCase	 
	
	cDadosChq := cCMC7	
	
	Self:Show()
	
Return