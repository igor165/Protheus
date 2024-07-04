#INCLUDE "TMKA061C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA061C  บAutor  ณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFonte com as funcoes de TELA da Lista de Contato.           บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061Trans บAutor ณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard de transferencia de Listas                           บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TK061Trans(cAlias,nReg,nOpc)

Local oWizTrans  											// Wizard
Local oListas	  											// Objeto para Listas
Local aListas		:= {} 									// Array com as listas para altera็ใo
Local oOperad												// Objeto para get do operador
Local cOperad		:= Criavar("U4_OPERAD",.F.)				// Descricao do operador
Local oSay													// Objeto com say para operador.
Local cSay			:= STR0001	//"Operador"				// Descricao do operador
Local cForma		:= ""									// Forma de contato
Local oOk       	:= LoaDbitmap(GetResources(),"LBOK") 	// Objeto para selecao do operador.
Local oNo        	:= LoaDbitmap(GetResources(),"LBNO") 	// Objeto para selecao do operador.
Local oData													// Data para transferencia
Local dData			:= CTOD("//")							// Data
Local oResumo												// Resumo da transferencia
Local cResumo												// Resumo da transferencia
Local oSDat													// Objeto do say para data.
Local cSDat			:= ""									// Say para data
Local oInverte
Local lInverte		:= .F.									// Controla a marcacao do listbox.
Local oAllMark
Local lAllMark		:= .F.									// Seleciona todos os itens.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena Listas para transfe๊ncia.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
DbSeek(xFilial("SU4"))
While !EOF() .AND. xFilial("SU4") == SU4->U4_FILIAL
	
	If (SU4->U4_TIPO == "2") .OR. (SU4->U4_STATUS == "2") // Cobranca e encerrado.
		DbSkip()
		Loop
	Endif
	
	Do Case
		Case SU4->U4_FORMA = "1"
			cForma:= STR0002 //"Voz"               
			
		Case SU4->U4_FORMA = "2"
			cForma:= STR0003 //"Fax"
			
		Case SU4->U4_FORMA = "3"
			cForma:= STR0004 //"Cross Posting"
			
		Case SU4->U4_FORMA = "4"
			cForma:= STR0005 //"Mala Direta"
			
		Case SU4->U4_FORMA = "5"
			cForma:= STR0006 //"Pend๊ncia"
			
		Case SU4->U4_FORMA = "6"
			cForma:= STR0007 //"WebSite"
	EndCase
	
	Aadd(aListas,{	.F.,;																// 1 - Legenda
					SU4->U4_LISTA,;                             						// 2 - Lista
					SU4->U4_DESC,;                              						// 3 - Nome
					DTOC(SU4->U4_DATA),;                        						// 4 - Data
					SU4->U4_OPERAD,;                         							// 5 - Opeador
					IIF(SU4->U4_TIPO = "1",STR0008,STR0009),;//"Marketing" "Vendas"	    // 6 - Tipo
					cForma	})            												// 7 - Forma
	
	DbSkip()
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a lista estiver vazia avisa o Usuario e fecha a transferenciaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aListas) == 0 
	Help(" ",1,"TK061STRAN")
    Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard	 ณ
//ภฤฤฤฤฤฤฤฤฤฤู
DEFINE WIZARD oWizTrans TITLE STR0010 HEADER STR0011 ; //"Assistente para Transfer๊ncia de Lista de Contatos" "Selecione as Listas para Transfer๊ncia."
		MESSAGE STR0012  TEXT " "; //"Quais listas serใo alteradas? "
		NEXT {||Tk061ValP1(aListas)} ;
		FINISH {||.F.} PANEL NOFIRSTPANEL 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPanel 1.					   ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oWizTrans:GETPANEL(1)
	@ 05,00 TO 90,280 LABEL "" OF OWizTrans:GETPANEL(1) PIXEL	              
	
	@ 09,02 LISTBOX oListas FIELDS ;
		HEADER ;
			"",;		// 1 - Legenda
			STR0013,;	// 2 - "Lista"
			STR0014,;	// 3 - "Nome"		
			STR0015,;	// 4 - "Data"
			STR0016,;	// 5 - "Operador Atual"
			STR0017,;	// 6 - "Tipo "
			STR0018 ;	// 7 - "Forma"
		ON DbLCLICK (aListas[oListas:nAt,1]:= !aListas[oListas:nAt,1], oListas:Refresh());
		SIZE 276,77 OF oWizTrans:GETPANEL(1) PIXEL NOSCROLL 
		
		oListas:SetArray(aListas)
		oListas:bLine:={||{IIF(aListas[oListas:nAt,1],oOk,oNo),;		
							   aListas[oListas:nAt,2],;		
						 	   aListas[oListas:nAt,3],;		
						 	   aListas[oListas:nAt,4],; 
						 	   aListas[oListas:nAt,5],;
						 	   aListas[oListas:nAt,6],;
						 	   aListas[oListas:nAt,7]}}              		

		oListas:Refresh()
		oListas:bLDbLClick	:= { || (aListas[oListas:nAt][1] := !aListas[oListas:nAt][1], oListas:Refresh()) }        
		
		@ 125,02 CheckBox oInverte Var lInverte Size 130,9 Pixel Of oWizTrans:GetPanel(1) Prompt STR0035 On Change Tk061Tool( 1,oListas,lInverte) //"Inverte e Retorna Sele็ใo"
		@ 125,92 CheckBox oAllMark Var lAllMark Size 130,9 Pixel Of oWizTrans:GetPanel(1) Prompt STR0036 On Change Tk061Tool( 2,oListas,lAllMark) //"Seleciona todos"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPanel 2.					   ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizTrans  HEADER STR0019 MESSAGE STR0020  BACK {||.T.}; //"Operador " "Informe o Operador e a Data para transferencia."
						  NEXT {|| Tk061TResumo(aListas,dData,cOperad,@cResumo,@oResumo),Tk061ValP2(dData,cOperad)};
						  FINISH {||.F.} PANEL
	oWizTrans:GETPANEL(2)
   	
	@ 05,00 TO 90,280 LABEL "" OF oWizTrans:GETPANEL(2) PIXEL	              
	@ 10,20 SAY STR0021 OF OWizTrans:GETPANEL(2) PIXEL SIZE 210,9 //"Selecione o Operador para esta lista."
	@ 25,20 MSGET oOperad VAR cOperad SIZE 35, 10 F3 "SU7" OF OWizTrans:GETPANEL(2) VALID(cSay := Posicione("SU7",1,xFilial("SU7")+cOperad,"U7_NOME"),oSay:Refresh()) PIXEL    
	@ 27,60 SAY oSay Var FATPDObfuscate(cSay,"U7_NOME") OF oWizTrans:GETPANEL(2) PIXEL SIZE 210,9    

	@ 40,20 SAY STR0022 OF OWizTrans:GETPANEL(2) PIXEL SIZE 210,9 //"Selecione a nova data para execu็ใo da Lista."
	@ 55,20 MSGET oData VAR dData SIZE 35, 10 OF oWizTrans:GETPANEL(2) VALID(cSDat :=Tk_DiaSemana( dData,,0) ,oSDat:Refresh()) PIXEL    
	@ 57,65 SAY oSDat Var cSDat OF oWizTrans:GETPANEL(2) PIXEL SIZE 210,9 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPanel 3.					   ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizTrans  HEADER STR0023 MESSAGE STR0024  BACK {||.T.};//"Resumo " "Resultado para tranfer๊ncia."
						  NEXT {|| .F.};
						  FINISH {|| TK061GRVTRANS(aListas,dData,cOperad)} PANEL
	oWizTrans:GETPANEL(3)

	@ 05,00 TO 90,280 LABEL "" OF oWizTrans:GETPANEL(3)  PIXEL
	@ 06,01 GET oResumo VAR cResumo MULTILINE SIZE 277,83 OF oWizTrans:GETPANEL(3) PIXEL READONLY

FATPDLogUser('TK061TRANS')	// Log de Acesso LGPD

ACTIVATE WIZARD oWizTrans CENTERED  WHEN {||.T.} 
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061ValP1 บAutor ณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da selecao de listas para transferenncia          บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061ValP1(aListas)

Local lRet 	:= .F.
Local nI	:= 0

For  nI := 1 To Len(aListas)
	If aListas[nI][1]
		lRet := .T.
		Exit
	Endif
Next nI

If !lRet
	Help(" ",1,"TK061NSELI")
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061ValP2 บAutor ณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da selecao de listas para transferenncia          บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061ValP2(dData,cOperad)

Local lRet := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida preenchimento das informa็๕esณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(dData) .AND. !Empty(cOperad)
	lRet := .T.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se a data para transferencia esta corretaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (dData < dDataBase)        
	Help(" ",1,"TK061INV_D")  //Data Invalida
	lRet := .F.
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061TResumoบAutorณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResumo das informacoes de transferencia de Lista.           บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061TResumo(aListas,dData,cOperad,cResumo,oResumo)

Local nI 	:= 0
Local cNome := ""

cResumo		:= ""

cResumo += STR0025 + CRLF //"Listas Selecionadas: "
For nI := 1 To Len(aListas)
	If aListas[nI][1]
		cResumo += aListas[nI][2] + " - " + aListas[nI][3] + CRLF
	Endif	
Next nI                  

cNome 	:= Posicione("SU7",1,xFilial("SU7")+cOperad,"U7_NOME") 
cResumo += CRLF
cResumo += STR0026 + DTOC(dData)+ CRLF //"Nova Data: "
cResumo += STR0027 + cOperad+ " - " + FATPDObfuscate(cNome,"U7_NOME") + CRLF //"Novo Operador: "

Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณTk_DiaSemanaณAutorณRafael M. Quadrotti    ณ Data ณ23/09/2003ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna a descricao do dia da semana conforme nTam         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ uso      ณ Lista de Contatos                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Tk_DiaSemana( dData , nTam , nDia )

Local aDia		:= Array( 7 , 2 )
Local cReturn	:= ""
Local nPosDia	:= 0.00

DEFAULT nTam 	:= 7.00

aDia[ 01 , 01 ] := STR0028 ; aDia[ 01 , 02 ] :=  1	// "Domingo"
aDia[ 02 , 01 ] := STR0029 ; aDia[ 02 , 02 ] :=  2	// "Segunda"
aDia[ 03 , 01 ] := STR0030 ; aDia[ 03 , 02 ] :=  3	// "Terca"
aDia[ 04 , 01 ] := STR0031 ; aDia[ 04 , 02 ] :=  4	// "Quarta"
aDia[ 05 , 01 ] := STR0032 ; aDia[ 05 , 02 ] :=  5	// "Quinta"
aDia[ 06 , 01 ] := STR0033 ; aDia[ 06 , 02 ] :=  6	// "Sexta"
aDia[ 07 , 01 ] := STR0034 ; aDia[ 07 , 02 ] :=  7	// "Sabado"

IF Empty( dData )
	IF !Empty( nDia )
		IF ( ( nPosDia := aScan( aDia , { |x| x[ 2 ] == nDia } ) ) > 0.00 )
			cReturn := Left( aDia[ nPosDia , 01 ] + Space( nTam ) , nTam )
		Else
			cReturn := Space( nTam )
		Endif
	Else
		cReturn := Space( nTam )
	Endif	
Else
	cReturn := Left( aDia[ Dow( dData ) , 01 ] + Space( nTam ) , nTam )
Endif

Return( cReturn )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk061Tool บAutor  ณRafael M. Quadrotti บ Data ณ  01/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para inversao da selecao das listas de contatos      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061Tool( nAction ,oLbx, lCheck)

Local nI	:= 0		// Variavel de Controle

If nAction == 1
	
	For nI := 1 To Len(oLbx:aArray)
		If oLbx:aArray[nI][1]
			oLbx:aArray[nI][1] := .F.
		Else
			oLbx:aArray[nI][1] := .T.
		Endif
		oLbx:Refresh()
	Next nI

Else

	If lCheck
		For nI := 1 To Len(oLbx:aArray)
			oLbx:aArray[nI][1] := .T.
			oLbx:Refresh()
		Next nI
	Else
		For nI := 1 To Len(oLbx:aArray)
			oLbx:aArray[nI][1] := .F.
			oLbx:Refresh()
		Next nI
	Endif

EndIf

Return(.T.)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
