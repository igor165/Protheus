#Include "PanelOnLine.ch"
#Include "PlsPgOnL.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FATPGONL  ³ Autor ³ Marco Bianchi         ³ Data ³ 18/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Painel de Gestao.                                             ³±±
±±³          ³Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FATPGONL(oPGOnline)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSPGONL(oPGOnline)

Local aToolBar  := {}
Local cString   := "" 
Local aPainel	:= {}
Local cStrFun	:= ""  
Local nI		:= 0


cStrFun	:= FUNNAME() // Verificação se esta sendo chamado de dentro ou de fora do modulo

If "10" $ GetVersao(.F.) // caso seja versão 10 pode verificar ser existe a tabela
	If !HS_ExisDic({{"T", "GTA"}},.F.)
		Return
	EndIf                    
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ,¿
//³Montagem dos paineis cadastrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ,Ù
If Empty(cStrFun)
	aPainel := HS_RTPGON()
else
	aPainel := HS_2RTPGON()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre os tipos cadastrados e monta conforme respectiva rotina           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Botao de Help do Painel
//1=Simples;2=Grafico Pizza;3-Grafico Barra;4-Grafico Linha
For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "1" // Tipo simples
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 2 ;	
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;
		DEFAULT 1 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3];
		TITLECOMBO IIf(!Empty(aPainel[nI,7]),aPainel[nI,7],STR0003) 
	EndIf
Next nI
                                        

For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "2" .OR. aPainel[nI,8] == "3"// Grafico pizza / Barra
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		Aadd( aToolBar, { "S4WB010N",cString,"{ || HSPPO020(" + aPainel[nI,3] + ",.T.) }" } )		
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 2 ;
		PARAMETERS "HSPPO020";
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;                                                   
		DEFAULT 3 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3]
		
	EndIf
Next nI

For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "4" // Grafico linha/comparativo
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 4 ;
		PARAMETERS "HSPPO030";
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;
		DEFAULT 1 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3]
		
	EndIf
Next nI	
	
Return                                   
