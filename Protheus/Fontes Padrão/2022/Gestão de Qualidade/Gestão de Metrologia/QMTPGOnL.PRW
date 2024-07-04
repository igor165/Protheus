#Include "PanelOnLine.ch" 
#Include "QMTPGONL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QMTPGOnl ³ Autor ³ Denis Martins         ³ Data ³ 07/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Ambiente Metrologia             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QMTPGOnl(oPGOnline)
Local aToolBar:= {} 
Local aToolBar2:= {}
Local aToolBar3:= {}
Local aToolBar4:= {}
Local cHelp   := ""
Local cHelp2  := ""
Local cHelp3   := ""
Local cHelp4   := ""
cHelp := STR0006//"O sistema ira validar se a data de calibracao do instrumento, na ultima revisao e "
cHelp += STR0007 //"menor que a database do sistema. Em caso afirmativo, o sistema apresentara o(s) instrumento(s) "
cHelp += STR0008//"alertando a falta de afericao do(s) mesmo(s)."

aToolBar  := {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - Instrumentos com Calibracao Vencida
PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0001; 					//"Instrumentos com calibracao vencida"
	DESCR STR0001+" - "+STR0002; 	//"Instrumentos com calibracao vencida X Metrologia"
	TYPE 5; 				
	PARAMETERS "QMP10";
	ONLOAD "QMTP010"; 		
	REFRESH 600; 			
	TOOLBAR aToolBar ;
	DEFAULT 1; 			
	NAME "1" 				

cHelp2 := STR0003 //"O sistema ira validar se a data de calibracao do instrumento, na ultima revisao e "
cHelp2 += STR0004 //"maior que a data escolhida. Em caso afirmativo, o sistema apresentara o(s) instrumento(s) "
cHelp2 += STR0005 //"alertando a(s) possivel(is) afericao(oes)."

aToolBar2  := {}
Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )

//--Painel 2 - Instrumentos com Calibracao a Vencer
PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0006; 					//Instrumentos com calibracao a vencer
	DESCR STR0006+" - "+STR0002; 	//Instrumentos com calibracao a vencer X Metrologia
	TYPE 5; 				
	PARAMETERS "QMP20";
	ONLOAD "QMTP020"; 		
	REFRESH 600; 			
	TOOLBAR aToolBar2 ;
	DEFAULT 1; 			
	NAME "2" 				

cHelp3 := STR0007 //"O sistema ira verificar todo(s) o(s) instrumento(s) que esta(ão) emprestado(s) dentro dos parametros de "
cHelp3 += STR0008//"data de / ate e que ainda não foi/foram devolvido(s) e apresentará o(s) mesmo(s). "
cHelp3 += STR0009//"alertando a(s) possivel(is) afericao(oes)."

aToolBar3  := {}
Aadd( aToolBar3, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp3+'")) }') } )

//--Painel 3 - Instrumentos emprestados
PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0010; 					//Instrumentos emprestados
	DESCR STR0010+" - "+STR0002; 	//Instrumentos emprestados X Metrologia
	TYPE 5; 				
	PARAMETERS "QMP30";
	ONLOAD "QMTP030"; 		
	REFRESH 600; 			
	TOOLBAR aToolBar3 ;
	DEFAULT 1; 			
	NAME "3" 				 

cHelp4 := STR0011//"O sistema emitira um grafico por status de instrumentos. Exemplo: Ativos - 5 Instrumentos, Inativos - 1 instrumento"

aToolBar4  := {}
Aadd( aToolBar4, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp4+'")) }') } )

//--Painel 4 - Quantidade de Instrumentos x Status
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0012 ; //"O sistema apresentara todos os instrumentos por status"
	DESCR STR0012 ; //"O sistema apresentara todos os instrumentos por status"
	TYPE 2 ; //-- Tipo do Painel
	ONLOAD "QMTP040" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar4 ;
	DEFAULT 3	 ; //-- Default do Combo
	NAME "4" //--Ordem de Exibicao

Return	