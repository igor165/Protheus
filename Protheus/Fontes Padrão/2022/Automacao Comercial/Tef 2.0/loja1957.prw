#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1957.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1957 ; Return  // "dummy" function - Internal Use


//Tipo de tela
#DEFINE _VISOR 			1			//Mensagem visor
#DEFINE _CAPTURA 		2			//Tela de captura
#DEFINE _SELECAO 		3           //Tela de selecao
#DEFINE _CONFIRMACAO	4			//Tela de confirmacao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCFrmTef        บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe e captura as informacoes do tef 							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCFrmTef
   	
   	Data oDlgTef														//Objeto Dialog do tef
   	Data cTitulo														//Titulo da transacao que esta sendo efetuada
   	Data cMsgSitef														//Mensagem enviada pelo sitef
	Data oMsgTef														//Objeto Say das mensagens retornadas pelo sitef    
   	Data oListSel														//Objeto ListBox para lista de opcoes
   	Data oListConf														//Objeto ListBox para exibir mensagem ao operador e esperar uma confirmacao
   	Data cListBox                                                       //Guardar a lista de opcoes
	Data oComSitef														//Objeto do tipo LJCComClisitef
   	Data oGetDados														//Objeto Get para capturar os dados
   	Data cGetDados														//Guardar o dados capturado			
   	Data lSelecao														//Indica se esta utilizando lista de selecao
	Data lCaptura														//Indica se esta utilizando captura de dados
	Data cVersao														//Versao da clisitef32.dll e clisitef32i.dll
	Data oBtnCont														//Objeto Button continuar
	Data oBtnVoltar														//Objeto Button voltar
	Data oBtnCanc														//Objeto Button encerrar
	Data oFontMens														//Objeto Font das mensagens retornadas do sitef    
    Data oFontSolic														//Objeto Font do objeto Say - Solicitacao TEF
    Data oFontList														//Objeto Font do objeto ListBox utilizado para lista de opcoes
	Data lGetEnable                                                         //Habilita o campo Get
	
		   	   			
	Method New(oComSitef, cTitulo, cVersao)								
	Method Show()														
	Method Questionar(cMensagem)										
	Method MsgVisor(cMensagem)											
	Method LimpaVisor()													
	Method Capturar(cTipo, nMin, nMax, cValor)                       	
	Method Confirmar(cMensagem)											
	Method Fechar()														
	Method MenuOpcoes(cOpcoes)											
	Method ContinFunc(nContinua)										
	Method PrepObjeto(cTipo)   
										

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCComClisitef.  			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oComSitef) - Objeto do tipo LJCComClisitef				 บฑฑ
ฑฑบ			 ณEXPC1 (2 - cTitulo) - Titulo da transacao							 บฑฑ
ฑฑบ			 ณEXPC2 (3 - cVersao) - Versao da clisitef32.dll e clisitef32i.dll	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(oComSitef, cTitulo, cVersao) Class LJCFrmTef
   
	Self:oDlgTef		:= Nil
   	Self:cTitulo		:= cTitulo
   	Self:cMsgSitef		:= "Aguarde Conectando Sitef..."
	Self:oMsgTef		:= Nil
	Self:oListSel		:= Nil
   	Self:cListBox      	:= ""
   	Self:lSelecao		:= .F.   
	Self:oFontMens		:= Nil
    Self:oFontSolic		:= Nil
    Self:oFontList		:= Nil
	Self:oComSitef		:= oComSitef
   	Self:oGetDados		:= Nil
   	Self:cGetDados		:= ""
   	Self:oListConf		:= .F.
   	Self:lCaptura		:= .F.
   	Self:cVersao		:= cVersao
	Self:oBtnCont		:= Nil
	Self:oBtnVoltar		:= Nil
	Self:oBtnCanc		:= Nil
	Self:lGetEnable		:= .T.

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShow  	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em exibir a tela.							    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Show() Class LJCFrmTef
	
	Local oObj	 := Self						//Objeto criado para ser executado no ON INIT do Dialog. 			
	Local aList  := {{"",""}}					//Inicializar o listbox
	Local cVar   := ""                          //Declaracao da variavel para utilizacao no objeto ListBox.
		
	//Tela de operacoes Tef
	DEFINE MSDIALOG Self:oDlgTef TITLE STR0001 + Space(1) + "(" + Self:cVersao + ")" FROM 000,000 TO 453,637 PIXEL OF GetWndDefault() COLOR CLR_BLUE,CLR_WHITE ;
	STYLE DS_MODALFRAME STATUS //T.E.F. - Transfer๊ncia Eletr๔nica de Fundos
	
	//Desabilita o esc da tela
	Self:oDlgTef:lEscClose := .F.	
	
	//Define as fontes
	DEFINE FONT Self:oFontMens	NAME "Arial" SIZE 10,25 BOLD
	DEFINE FONT Self:oFontList NAME "Arial" SIZE 09,20 BOLD
	DEFINE FONT Self:oFontSolic NAME "Arial" SIZE 07,17 BOLD
		
	//Titulo da transacao
	@ 001,001 SAY If(Empty(Self:cTitulo), STR0003, STR0003 + Space(1) + "(" + Self:cTitulo + ")") COLOR CLR_GRAY SIZE 250,10 OF Self:oDlgTef PIXEL //Mensagem Sitef

	//Box - Mensagens recebidas do sitef
	@ 010,002 TO 055,318 PIXEL

	//Mensagens recebidas do sitef
	@ 028,005 SAY Self:oMsgTef VAR Self:cMsgSitef FONT Self:oFontMens COLOR CLR_GREEN SIZE 300,40 OF Self:oDlgTef PIXEL
	
	//"SolicitaวรO SITEF"
	@ 057,001 SAY STR0007 FONT Self:oFontSolic COLOR CLR_GRAY SIZE 250,10 OF Self:oDlgTef PIXEL
	
	//Box - Solicitacao Sitef
	@ 065,002 TO 208,318 PIXEL
	
	//Entrada de dados solicitado pelo sitef
	@ 075,005 MSGET Self:oGetDados VAR Self:cGetDados SIZE 070,10 OF Self:oDlgTef PIXEL WHEN Self:lGetEnable
	Self:oGetDados:bLostFocus := { ||Self:oBtnCont:SetFocus() }
		
	//Listbox para tela de confirmacao do operador
	@ 067,004 LISTBOX Self:oListConf VAR cVar SIZE 312, 139 PIXEL OF Self:oDlgTef
	Self:oListConf:SetFont(::oFontList)
	Self:oListConf:aItems := {}
	Self:oListConf:bLDBLClick := { || Self:oBtnCont:SetFocus() }
	
	//Listbox para exibicao de lista de opcoes
	@ 067,004 LISTBOX Self:oListSel VAR Self:cListBox FIELDS HEADER SPACE(10) , "" SIZE 312, 139 PIXEL OF Self:oDlgTef
	Self:oListSel:SetFont(::oFontList)
	Self:oListSel:SetArray(alist)
	Self:oListSel:bLine := {|| {alist[Self:oListSel:nat][1], alist[Self:oListSel:nat][2]}}
	Self:oListSel:bLDBLClick := { || Self:oBtnCont:SetFocus()  }

	//Botao continuar
	@ 210,194 BUTTON Self:oBtnCont PROMPT STR0004 SIZE 40,15 OF Self:oDlgTef PIXEL ACTION Self:ContinFunc(0) //"&Continuar"
	//Botao voltar
	@ 210,236 BUTTON Self:oBtnVoltar PROMPT STR0005 SIZE 40,15 OF Self:oDlgTef PIXEL ACTION Self:ContinFunc(1)//"&Voltar" 
	//Botao encerrar
	@ 210,278 BUTTON Self:oBtnCanc PROMPT STR0006 SIZE 40,15 OF Self:oDlgTef PIXEL ACTION Self:ContinFunc(-1)//"&Encerrar"
	
	//Prepara objetos da tela	
	Self:PrepObjeto(_VISOR)
	
	ACTIVATE MSDIALOG Self:oDlgTEF CENTERED ON INIT oObj:ContinFunc()
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณQuestionar       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe uma tela para obter a resposta de sim ou nao 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem do questionamento				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Questionar(cMensagem) Class LJCFrmTef
	
	Local cRetorno 	:= ""						//Retorno do metodo
	Local lRet		:= .F.						//Retorno do MsgYesNo	
	
	// Se for homologacao TEF chamar MsgYeNo direto. 
	// pois o do STFMessage nao respeita as quebras de linha
	If SuperGetMV("MV_LJHMTEF", ,.F.)
		lRet := MsgYesNo(cMensagem)
	Else
		STFMessage("SiTEF", "YESNO", cMensagem)   
		lRet := STFShowMessage("SiTEF")
	EndIf	
	
	//Atribui retorno
	If lRet
		cRetorno := "0"
	Else
		cRetorno := "1"
	EndIf
	
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMsgVisor         บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe uma mensagem no visor						 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem do visor							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MsgVisor(cMensagem) Class LJCFrmTef

	Default cMensagem := ""

 	Self:PrepObjeto(_VISOR , AllTrim(cMensagem) ) 
 	
 	Self:cMsgSitef := AllTrim(cMensagem)
 	
 	Self:oMsgTef:cCaption := Self:cMsgSitef
  	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLimpaVisor       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpar a mensagem do visor							 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LimpaVisor() Class LJCFrmTef
	
	Self:PrepObjeto(_VISOR)
	
	Self:cMsgSitef := ""
 	
 	Self:oMsgTef:cCaption := Self:cMsgSitef
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConfirmar        บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe uma mensagem e aguardar a confirmacao do operador.	 		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem									 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Confirmar(cMensagem) Class LJCFrmTef

	Local aLista := {}										//Utilizado no listbox
	
	Default cMensagem := ""
		
	cMensagem := StrTran(cMensagem, Chr(13), "")
		
	//Separa a string pelo delimitador ";" e retorna um array
	aLista := StrTokArr(cMensagem, Chr(10))
	
	Self:MsgVisor(aLista[1])
	
	Self:PrepObjeto(_CONFIRMACAO)
	
	//Seta as propriedades do listbox
	Self:oListConf:aItems := aLista
	Self:oListConf:Refresh()
	
	Self:oBtnCont:SetFocus()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCapturar         บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCaptura uma informacao atraves do operador			 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTipo) - Tipo do campo (N - Numerico ; A - Alfanumerico)บฑฑ	
ฑฑบ			 ณEXPN1 (2 - nMin) - Tamanho minimo do campo						 บฑฑ
ฑฑบ			 ณEXPN2 (3 - nMax) - Tamanho maximo do campo						 บฑฑ
ฑฑบ			 ณEXPC2 (4 - cValor) - Valor do campo								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Capturar(cTipo, nMin, nMax, cValor, lPassword, lEnable) Class LJCFrmTef
    
    Local nSize := GetTextWidth(0, Repl("M", nMax))		//Dimensiona o tamanho do campo para digitacao
	
	DEFAULT lPassword := .F. 
	DEFAULT lEnable := .T.
	
	Self:lCaptura := .T.
	
	//Acertar o tamanho da Get
	If nSize > 600 
		nSize := 600
	ElseIf nSize < 20
		nSize := 20
	EndIf 
	
	Self:oGetDados:lPassword := lPassword
	Self:lGetEnable := lEnable
		
	//Caracter	
	If cTipo == "A"
		
		If ValType(cValor) <> "C"
			cValor := Space(nMax) 		
		EndIf
		
		Self:oGetDados:Picture	:= "@!"	    
	
	//Numerico	
	ElseIf cTipo == "N"

		If ValType(cValor) <> "N"
			cValor := Round(0, 2) 		
		EndIf
		
		Self:oGetDados:Picture	:= "@E 999,999,999.99"

	EndIf
	
	Self:PrepObjeto(_CAPTURA)
	
	Self:cGetDados := cValor
	Self:oGetDados:nWidth	:= nSize
	Self:oGetDados:SetFocus()	
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFechar           บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFechar o formulario												 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Fechar() Class LJCFrmTef
	
	Self:oDlgTef:End()
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMenuOpcoes       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe um menu de opcoes para selecao do operador					 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cOpcoes) - Lista de opcoes								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MenuOpcoes(cOpcoes, nTipoTrans) Class LJCFrmTef
	
	Local aAux1 	:= {}								//Utilizado para separar o ; da string
	Local aAux2 	:= {}								//Utilizado para separar o : da string
	Local aLista 	:= {}								//Utilizado no listbox
	Local nCount 	:= 0								//Variavel contador
	
	Default nTipoTrans := 0 //tipo da transa็ใo
	Self:lSelecao := .T.
	
	
	//Separa a string pelo delimitador ";" e retorna um array 
	aAux1 := StrTokArr(cOpcoes, ";")
	
	//Prepara o array com a lista de opcoes
	For nCount := 1 To Len(aAux1) 
		If !Empty(aAux1[nCount])
			//Separa a string pelo delimitador ":" e retorna um array
			aAux2 := StrTokArr(aAux1[nCount],":")
			//Carrega o array do listbox
			AADD(aLista, {aAux2[1], aAux2[2]})
		EndIf
	Next

	Self:PrepObjeto(_SELECAO)
	
	//Seta as propriedades do listbox
	Self:oListSel:SetArray(aLista)
	Self:oListSel:bLine := {|| {aLista[Self:oListSel:nAt][1], aLista[Self:oListSel:nAt][2]}}
	Self:oListSel:Refresh()
	Self:oListSel:SetFocus()
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณContinFunc       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณContinua com o fluxo da transacao	    						 	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nContinua)-Indica se o fluxo da transacao vai continuar บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ContinFunc(nContinua) Class LJCFrmTef

	Default nContinua := 0

   	//Tela de captura
	If Self:lCaptura

		Self:lCaptura := .F.
		
		If ValType(Self:cGetDados) == "N"
			Self:cGetDados := AllTrim(Str(Self:cGetDados))
		EndIf
		
		Self:oComSitef:ContinFunc(Self:cGetDados, nContinua)

	//Tela de selecao
	ElseIf Self:lSelecao
		
		Self:lSelecao := .F.
		Self:oComSitef:ContinFunc(Self:oListSel:aArray[Self:oListSel:nAt][1], nContinua)

	Else
		Self:oComSitef:ContinFunc("", nContinua)
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepObjeto       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreparar os objetos da tela    					 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTipo) - Tipo da tela (1 - Visor ; 2 - Captura ; 		 บฑฑ
ฑฑบ			 ณ									3 - Lista de selecao)			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepObjeto( cTipo , cMensagem ) Class LJCFrmTef

Default cTipo		:= ""
Default cMensagem 	:= ""

Do Case

	Case cTipo == _VISOR
		
		Self:oListSel:lVisible		:= .F.
		Self:oListConf:lVisible		:= .F.
		Self:oGetDados:lActive		:= .F.
		Self:oGetDados:lVisible		:= .F.
		Self:oBtnCont:lActive		:= .F.
		Self:oBtnVoltar:lActive		:= .F.
		Self:oBtnCanc:lActive		:= .F.
			
	Case cTipo == _CONFIRMACAO

		Self:oListSel:lVisible		:= .F.
		Self:oListConf:lVisible		:= .T.
		Self:oGetDados:lActive		:= .F.
		Self:oGetDados:lVisible		:= .T.
		Self:oBtnCont:lActive		:= .T.
		Self:oBtnVoltar:lActive		:= .F.
		Self:oBtnCanc:lActive		:= .F.

	Case cTipo == _CAPTURA
	    
		Self:oListSel:lVisible		:= .F.
		Self:oListConf:lVisible		:= .F.
		Self:oGetDados:lActive		:= .T.
		Self:oGetDados:lVisible		:= .T.
		Self:oBtnCont:lActive		:= .T.
		Self:oBtnVoltar:lActive		:= .T.
		Self:oBtnCanc:lActive		:= .T.
		
	Case cTipo == _SELECAO
		
		Self:oListSel:lVisible		:= .T.
		Self:oListConf:lVisible		:= .F.
		Self:oGetDados:lActive		:= .F.
		Self:oGetDados:lVisible		:= .T.
		Self:oBtnCont:lActive		:= .T.
		Self:oBtnVoltar:lActive		:= .T.
		Self:oBtnCanc:lActive		:= .T.				

EndCase	
	
Return Nil
