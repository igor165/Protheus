#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

#DEFINE NUM_PICT "@E 999,999,999"
#DEFINE VAL_PICT "@E 999,999,999.99"
#DEFINE PER_PICT "@E 999,999"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TRMPGOnl ³ Autor ³ Rogerio Ribeiro       ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definicao dos paineis on-line para modulo TREINAMENTO      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRMPGOnl                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATRM                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³28/07/14³TPZWA0³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMPGOnl(oPGOnline)
Local aToolBar  := {}  
Local nTempo	:= SuperGetMV("MV_PGORFSH", .F., 60)//Tempo para atualizacao do painel

//-------------------------------------------------------------------------------
// PAINEL 1 - INDICATIVO DE CURSOS
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
 	Aadd( aToolBar, { "S4WB016N","Help","{ || MsgInfo("+TrmHelpPnl(1)+") }"})  
  
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE	 	STR0001;  //"Indicativo de Cursos"
		DESCR 		STR0001;  //""Indicativo de Cursos"
		TYPE 		1;
		ONLOAD 		"TRMPGOL001";
		REFRESH		nTempo;            
		TOOLBAR		aToolBar ;	
		NAME		"TRMPGOL001";  
		PARAMETERS	"TRMPG1";
		                       
//-------------------------------------------------------------------------------
// PAINEL 2 - COLABORADORES CAPACITADOS
//-------------------------------------------------------------------------------		                              
	//Botao de Help do Painel
	aToolBar  := {}  
	Aadd( aToolBar, { "S4WB016N","Help","{ || MsgInfo("+TrmHelpPnl(2)+") }"}) 		
	PANELONLINE oPgOnLine ADDPANEL ;
		TITLE		STR0002; // "Colaboradores Capacitados"
		DESCR		STR0002; // "Colaboradores Capacitados"
		TYPE		4;
		ONLOAD		"TRMPGOL002";
		REFRESH		nTempo;         
		TOOLBAR		aToolBar ;	
		NAME		"TRMPGOL002";
		PARAMETERS	"TRMPG2"
 
//-------------------------------------------------------------------------------
// PAINEL 3 - INDICE DE APROVACOES DOS CURSOS
//-------------------------------------------------------------------------------  
	//Botao de Help do Painel
	aToolBar  := {}
	Aadd( aToolBar, { "S4WB016N","Help","{ || MsgInfo("+TrmHelpPnl(3)+") }"}) 	 
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0003;  //"indice de aprovações dos cursos"
		DESCR		STR0003;  //"indice de aprovações dos cursos"
		TYPE 		3;
		ONLOAD 		"TRMPGOL003";
		REFRESH		nTempo;
		TOOLBAR		aToolBar ;	
		NAME		"TRMPGOL003";
		PARAMETERS	"TRMPG3"

//-------------------------------------------------------------------------------
// PAINEL 4 - INDICE EFICACIA DOS CURSOS
//-------------------------------------------------------------------------------
	//Botao de Help do Painel
	aToolBar  := {}	
	Aadd( aToolBar, { "S4WB016N","Help","{ || MsgInfo("+TrmHelpPnl(4)+") }"})  			
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE		STR0004; //"Índice Eficácia dos cursos"
		DESCR		STR0004; //"Índice Eficácia dos cursos"
		TYPE		3;
		ONLOAD		"TRMPGOL004";
		REFRESH		nTempo;    
		TOOLBAR		aToolBar ;			
		NAME		"TRMPGOL004";
		PARAMETERS	"TRMPG4"
Return


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TRMPGOL001 ³ Autor ³ Joeudo Santana		  ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Painel 1 (Tipo 1) - Indicativo sobre colaboradores  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TRMPGOL001													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMPGOL001

Local aRetorno		:=	{}	  
Local aCursPlan		:=	{}
Local aCursRealiz	:=	{}
Local aCurPlanRlz	:=	{}
Local nCursosPlan	:=	0  
Local nValCurs		:=	0 
Local nCursosReal	:=	0
Local nValRealiz	:=	0 
Local nHorasReal	:=	0
Local nIndRlzPlan	:=	0
Local nIndValRzPl	:=	0  
Local nMedia		:=	0   
Local cSimb			:=	getmv("MV_SIMB1")           

Pergunte("TRMPG1", .F.)
// Quantidade e valor dos cursos planejados no periodo determinado pelo usuario
aCursPlan	:=	CursPlanej()
nCursosPlan	:=	aCursPlan[1]  // Quantidade de cursos planejados para o periodo                  
nValCurs	:=	aCursPlan[2]  // Valor total dos cursos planejados para o periodo
                          
// Quantidade, valor e horas dos cursos realizados no periodo determinado pelo usuario
aCursRealiz	:=	CursRealiz()                                                         
nCursosReal	:=	aCursRealiz[1] // Quantidade de cursos realizados no periodo
nValRealiz	:=	aCursRealiz[2] // Valor total dos cursos realizados no periodo	
nHorasReal	:=	aCursRealiz[3] // Quantidade de horas dos cursos realizados no periodo
           
// Quantidade e valor dos cursos planejados que foram realizados no periodo determinado pelo usuario
aCurPlanRlz	:=	CurPlanRlz()
nIndRlzPlan	:= Round((aCurPlanRlz[1]/nCursosPlan)*100,0)  // percentual referente a quantidade de cursos realizados que foram planejados (Cursos realizados que foram planejados X Cursos planejado)
nIndValRzPl	:= Round((aCurPlanRlz[2]/nValCurs)*100,0)     // percentual referente ao valor dos cursos realizados que foram planejados (Valor gasto dos cursos realizados que foram planejados X Valor planejado)
          
// Media das notas de todos os funcionarios nos cursos realizados no periodo 
nMedia	:= Round(IndAvaliaCur(),0)                                                                                                    	    
                         
aRetorno:=	{;  
				{ STR0005, 			Transform(nCursosPlan, NUM_PICT)	,	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(5)+") }" },; //"Planejados"    
				{ STR0006, 			Transform(nCursosReal, NUM_PICT)	,	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(6)+") }" },;	//"Realizados"  				
				{ STR0005+cSimb,	Transform(nValCurs   , VAL_PICT)	,	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(7)+") }" },;	//"Planejados R$" 
				{ STR0006+cSimb,	Transform(nValRealiz , VAL_PICT)	,	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(8)+") }" },;	//"Realizados R$"	
				{ STR0007, 			Transform(nHorasReal , NUM_PICT)	,	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(9)+") }" },;	//"Horas realizados"
				{ STR0008,			Transform(nIndRlzPlan, PER_PICT)+"%",	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(10)+") }" },;//"Planejado vs. Realizados"  
				{ STR0008+" "+cSimb,Transform(nIndValRzPl, PER_PICT)+"%",	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(11)+") }" },;//"Planejado vs. Realizados (R$)"	
				{ STR0009,			Transform(nMedia	 , PER_PICT)+"%",	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(12)+") }" };	 //"Médias Capacitações"  
			}
Return aRetorno	 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TRMPGOL002 ³ Autor ³ Joeudo Santana		  ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Painel 2 (Tipo 4) - Indicativo sobre colaboradores  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TRMPGOL002													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMPGOL002            

Local aRetorno		:=	{}
Local nQuantPlan	:=	0
Local nQuantCapc	:=	0 
      
Pergunte("TRMPG2", .F.)
	                         
// Quantidade de colaboradores que serao capacitados no periodo determinado pelo usuario de acordo com planejamento	     
nQuantPlan	:=	PlanColaborad() 
// Quantidade de colaboradores que foram capacitados no periodo
nQuantCapc	:=	CapcColaborad()
				
aRetorno:=	{"" , 0, 100,; 
				{;
					{ Alltrim(Transform(nQuantPlan,NUM_PICT)), STR0005, CLR_BLACK, "{ || MsgInfo("+TrmHelpPnl(13)+") }", nQuantPlan },;  //"Planejados"  
					{ Alltrim(Transform(nQuantCapc,NUM_PICT)), STR0006, CLR_BLACK, "{ || MsgInfo("+TrmHelpPnl(14)+") }", nQuantCapc };   //"Capacitados"  
				};
			}   				
Return aRetorno                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TRMPGOL003 ³ Autor ³ Joeudo Santana		  ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 3 (tipo 3) - Indice de aprovacoes do curso	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TRMPGOL003													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMPGOL003

Local aRetorno	:= {}	
Local aAprovac	:= {}
Local nAprovac	:= 0   
Local nCursos	:= 0

Pergunte("TRMPG3", .F.)

// Indice de aprovacao dos cursos no periodo determinado pelo usuario 
aAprovac:= IndAprovac()
nCursos	:= aAprovac[1]   
nAprovac:= aAprovac[2]        
                                             
//Local aRetPanel:= { "Eficiencia","20%","% Mes", CLR_RED,Nil,0,100,20 }    			
aRetorno:= 	{If(nCursos > 0,"",STR0010), Alltrim(Transform(nAprovac,PER_PICT))+"%", "", CLR_BLACK, Nil, 0, 100, nAprovac} // "Não há dados a serem exibidos" 

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TRMPGOL004 ³ Autor ³ Joeudo Santana		  ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta painel 4 (tipo 3) - Indice de aproveitamento dos	³±± 
±±³          ³ cursos														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TRMPGOL004													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TRMPGOL004
Local aRetorno	:= {}	
Local aAproveit	:= {}
Local nAproveit := 0

Pergunte("TRMPG4", .F.)	
// Indice de aproveitamento dos cursos no periodo determinado pelo usuario       
aAproveit	:=	IndAproveit()
nQuant		:=	aAproveit[1]  
nAproveit	:=	aAproveit[2]  
aRetorno:= 	{If(nQuant>0,"",STR0010),Alltrim(Transform(nAproveit,PER_PICT))+"%" , "", CLR_BLACK, Nil, 0, 100, nAproveit} // "Não há dados a serem exibidos"

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CursPlanej		³ Autor ³ Joeudo Santana	  ³ Data ³ 23/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade e valor dos cursos planejados	no periodo	  	  ³±±    
±±³			 ³ determinado pelo usuario										  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CursPlanej()	   													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(quantidade e valor)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CursPlanej()               
Local nCursos	:= 0
Local nValCurs	:= 0                      
Local cAliasQry := GetNextAlias()      
Local cWhere  	:= "" 
Local aRetorno	:={}
                         
cWhere  	:=" RA8.RA8_FILIAL = '"+ xFilial("RA8")+ "' AND RA8.D_E_L_E_T_ ='' " 
If !Empty(mv_par02)                    
	cWhere +=  "AND RA8.RA8_DATADE >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA8.RA8_DATAAT <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                         
EndIf   
cWhere	:=	"%"+cWhere+"%"  
                                                 
BeginSql Alias cAliasQry
	SELECT COUNT(*) AS CURSOS, SUM(RA8_VALOR) AS VALOR
	FROM %table:RA8% RA8
	WHERE 
	%Exp:cWhere%  
EndSql
nCursos	 := (cAliasQry)->CURSOS // Quantidade de Cursos  
nValCurs := (cAliasQry)->VALOR  // Valor dos cursos
(cAliasQry)->(DbCloseArea())
			
aRetorno:= {nCursos,nValCurs}				
Return aRetorno                      



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CursRealiz		³ Autor ³ Joeudo Santana	  ³ Data ³ 23/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade, valor e horas dos cursos Realizados no periodo ³±±  
±±³          ³ determinado pelo usuario											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CursRealiz()	   													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(quantidade,valor e horas)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CursRealiz()
Local nCursos	:= 0
Local nValCurs	:= 0
Local nValHoras	:= 0                      
Local cAliasQry := GetNextAlias()      
Local cWhere	:=""
Local aRetorno  := {}

cWhere	:=" RA4.RA4_FILIAL = '"+ xFilial("RA4") +"' AND RA4.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                    
EndIf              
cWhere	:=	"%"+cWhere+"%" 
                                   
BeginSql Alias cAliasQry
	SELECT SUM(RA4_VALOR) AS VALOR, SUM (RA4_HORAS) AS HORAS  
	FROM %table:RA4% RA4
	WHERE 
	%Exp:cWhere%       
	GROUP BY RA4_CALEND, RA4_CURSO
EndSql

Dbselectarea(cAliasQry) 
While !(cAliasQry)->(eof())     
	nCursos++	// Quantidade de cursos
	nValCurs	+= (cAliasQry)->VALOR		// Valor dos cursos
	nValHoras	+= (cAliasQry)->HORAS		// Quantidade de horas
	(cAliasQry)->(dbskip())               
Enddo   
(cAliasQry)->(DbCloseArea())   

			
aRetorno:= {nCursos,nValCurs,nValHoras}				
Return aRetorno                      

             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CurPlanRlz		³ Autor ³ Joeudo Santana	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade e valor dos cursos Realizados que foram		  ³±±    
±±³			 ³ planejados														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CursRealiz()	   													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(quantidade e valor)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CurPlanRlz()
 
Local nCursos	:= 0
Local nValCurs	:= 0                   
Local cAliasQry := GetNextAlias()      
Local cWhere	:= ""
Local aRetorno
                
cWhere	:=" RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                      
EndIf        
cWhere	:=	"%"+cWhere+"%"                                          

BeginSql Alias cAliasQry
	SELECT SUM(RA4_VALOR) AS VALOR   
	FROM %table:RA4% RA4
	INNER JOIN %table:RA2% RA2 ON
		RA4.RA4_CALEND = RA2.RA2_CALEND AND	 
		RA2.RA2_FILIAL = %xFilial:RA2%  AND   
		RA2.%notDel%  
	INNER JOIN %table:RA8% RA8 ON 
		RA2.RA2_PLANEJ = RA8.RA8_PLANEJ AND	    
		RA8.RA8_FILIAL = %xFilial:RA8%  AND	
		RA8.%notDel%  
	WHERE 
		%Exp:cWhere%  	
	GROUP BY RA4_CALEND, RA4_CURSO
EndSql       
      
Dbselectarea(cAliasQry) 
While !(cAliasQry)->(eof())     
	nCursos++								// Quantidade de cursos realizados que foram planejados
	nValCurs+= (cAliasQry)->VALOR 	  		// Valor dos cursos realizados que foram planejados
	(cAliasQry)->(dbskip())               
Enddo   
(cAliasQry)->(DbCloseArea())                                       
			
aRetorno:= {nCursos,nValCurs}	                                	    
Return aRetorno



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ IndAvaliaCur		³ Autor ³ Joeudo Santana	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna media das notas nos cursos realizados no periodo			  ³±±  
±±³          ³ determinado pelo usuario											  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ IndAvaliaCur()	   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(media das notas)								   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IndAvaliaCur()
 
Local nMedia	:= 0                 
Local cAliasQry := GetNextAlias()      
Local cWhere	:= ""
                                                                                       
cWhere	:=" RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                     
EndIf    
cWhere	:=	"%"+cWhere+"%" 
                                             
BeginSql Alias cAliasQry 
	COLUMN NOTAS	AS NUMERIC(12,2)
	COLUMN QUANT	AS NUMERIC(12,2)
	
	SELECT  SUM(RA4_NOTA) AS NOTAS, Count(*) AS QUANT  
	FROM %table:RA4% RA4
	WHERE 
	%Exp:cWhere%   
EndSql	

nMedia := (cAliasQry)->NOTAS/(cAliasQry)->QUANT   // Media das notas de todos os funcionarios nos cursos realizados no periodo

(cAliasQry)->(DbCloseArea())	                          
      
Return nMedia
             



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PlanColaborad	³ Autor ³ Joeudo Santana	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade de colaboradores que serao capacitados		  ³±±  
±±³          ³ no periodo determinado pelo usuario de acordo com planejamento 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PlanColaborad()	   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(Quantidade de colaboradores)					   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PlanColaborad()            

Local nQuantColab	:= 0                 
Local cAliasQry 	:= GetNextAlias()      
Local cWhere		:= ""

cWhere		:= " RA3.RA3_FILIAL = '" + xFilial("RA3") + "' AND RA3.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA3_DATA between '"+ %Exp:DTOS(mv_par01)% + "' AND '" + %Exp:DTOS(mv_par02)% + "'"  		                                        
EndIf     
cWhere	:=	"%"+cWhere+"%"                                             

BeginSql Alias cAliasQry 
	SELECT  COUNT(RA3_MAT) AS COLABOR 
	FROM %table:RA3% RA3
	WHERE 
	%Exp:cWhere%   
EndSql	               

nQuantColab := (cAliasQry)->COLABOR   // Quantidade de colaboradores que serao capacitados de acordo com planejamento

(cAliasQry)->(DbCloseArea())	                          
  
Return nQuantColab
                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CapcColaborad	³ Autor ³ Joeudo Santana 	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade de colaboradores que foram capacitados		  ³±±  
±±³          ³ no periodo determinado pelo usuario							 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CapcColaborad()	   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(Quantidade de colaboradores)					   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CapcColaborad()            

Local nQuantColab	:= 0                 
Local cAliasQry := GetNextAlias()      
Local cWhere	:= ""
       
cWhere	:= " RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                       
EndIf  
cWhere	:=	"%"+cWhere+"%"                       
                               
BeginSql Alias cAliasQry 
	SELECT  COUNT(RA4_MAT) AS COLABOR 
	FROM %table:RA4% RA4
	WHERE 
	%Exp:cWhere%   
EndSql	
nQuantColab := (cAliasQry)->COLABOR // Quantidade de colaboradores que foram capacitados no periodo

(cAliasQry)->(DbCloseArea())	                          
  
Return nQuantColab
     
                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ IndAprovac		³ Autor ³ Joeudo Santana 	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna indice de aprovacao dos cursos no periodo determinado 	  ³±±  
±±³			 ³ pelo usuario													 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ IndAprovac()	   													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(Indice de Aprovacao)					   			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function IndAprovac() 
      
Local nIndAprovac	:=	0
Local nQuant		:=	0     
Local nAprovad		:=	0        
Local cAliasQry 	:=	GetNextAlias()      
Local cWhere		:=	"" 
Local cExpre		:= "%SRA.RA_CARGO = ''%"   
Local aRetorno		:= {}              

cWhere		:=	" RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ ='' "
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                       
EndIf  

cWhere	:=	"%"+cWhere+"%"      
   
// Tabelas utilizadas: RA4 (Cursos do funcionario) - SRA(Funcionarios) - SRJ(Cadastro de Funcoes)  - RA5(Cursos do Cargo)   

// Comparacao das notas dos testes dos funcionarios(RA4_NOTA) com notas esperadas para o curso(RA5_NOTA).    

// Para cada funcionario(SRA) pode ser cadastrado um cargo e para esse cargo pode haver exigencia de algum(uns) curso(s)(RA5). 
// Na tabela curso do cargo (RA5) existe nota minima para cada curso.
// Os cursos estao amarrados ao cargo do funcionario e o cargo pode ser obtido diretamente do cadastro de funcionario(RA_CARGO)
// ou, caso nao haja cargo cadastrado na tabela SRA e verificado o cargo da funcao do funcionario(RJ_CARGO).       

// Atraves das notas obtidas e esperadas, e verificada a quantidade de funcionarios que foram aprovados . (RA4_NOTA x RA5_NOTA).

// Sao considerados os testes dos funcionarios cujo curso seja exigencia do cargo do funcionario(resultado:QUANT) e          
// considerada a quantidade de testes dos cursos realizados no periodo que ficaram com notas maior ou igual a nota esperada(resultado:APROVADOS).
                       
BeginSql Alias cAliasQry
	SELECT SUM (CASE WHEN RA4_NOTA >= (CASE WHEN RA5A.RA5_NOTA IS NOT NULL THEN (RA5A.RA5_NOTA) ELSE (RA5B.RA5_NOTA) END)
	THEN (1) ELSE 0 END) AS APROVADOS,
	COUNT(RA5A.RA5_NOTA)+COUNT(RA5B.RA5_NOTA) AS QUANT	
	FROM %table:RA4% RA4  

	INNER JOIN %table:SRA% SRA ON
	RA4.RA4_MAT = SRA.RA_MAT 
    AND SRA.RA_FILIAL = %xFilial:SRA% 
	AND SRA.%notDel%      
	
	LEFT JOIN %table:RA5% RA5A ON
	SRA.RA_CARGO = RA5A.RA5_CARGO
	AND SRA.RA_CC = RA5A.RA5_CC
	AND RA4.RA4_CURSO = RA5A.RA5_CURSO  
	AND RA5A.RA5_FILIAL = %xFilial:RA5% 
	AND RA5A.%notDel%    
	
	LEFT JOIN %table:SRJ% SRJ ON  
        SRA.RA_CODFUNC = SRJ.RJ_FUNCAO		
	AND SRJ.RJ_FILIAL = %xFilial:SRJ% 
	AND SRJ.%notDel% 
  
	LEFT JOIN %table:RA5% RA5B ON  
	SRJ.RJ_CARGO = RA5B.RA5_CARGO
	AND RA4.RA4_CURSO = RA5B.RA5_CURSO 
	AND SRA.RA_CC = RA5B.RA5_CC
        AND %Exp:cExpre%
	AND RA5B.RA5_FILIAL = %xFilial:RA5% 
	AND RA5B.%notDel% 
   
	WHERE 
	%Exp:cWhere%  
EndSql	

nQuant	:=	(cAliasQry)->QUANT   	//Quantidade de testes cujos cursos sao exigencia do cargo do funcionario.  
nAprovad:=	(cAliasQry)->APROVADOS	//Quantidade de testes com notas iguais ou superiores a nota minima do curso.  

If ( nAprovad > 0)      
	nIndAprovac:= (nAprovad /nQuant) *100   // Indice de aprovacoes nos cursos
EndIf  
(cAliasQry)->(DbCloseArea())	                          
               
aRetorno := {nQuant,nIndAprovac}
Return aRetorno                      
  
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ IndAproveit		³ Autor ³ Joeudo Santana 	  ³ Data ³ 26/02/07	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Indice de aproveitamento dos Cursos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ IndAproveit()	   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno(Valor - Indice de aproveitamento)			   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATRM  			   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function IndAproveit()
      
Local nIndAproveit	:= 0  
Local nQuant		:= 0
Local nEficacia		:= 0
Local cAliasQry 	:= GetNextAlias()      
Local cWhere		:= "" 
Local cExpre		:= "%SRA.RA_CARGO = ''%"   
Local aRetorno		:= {}             

cWhere		:= " RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ ='' " 
If !Empty(mv_par02)                    
	cWhere +=  "AND RA4.RA4_DATAIN >= '"+ %Exp:DTOS(mv_par01)% + "'"
	cWhere +=  "AND RA4.RA4_DATAFI <= '" + %Exp:DTOS(mv_par02)% + "'" 	  		                                       
EndIf         
cWhere	:=	"%"+cWhere+"%"  

// Comparacao da avaliacao de eficacia de cada funcionarios(RA4_EFICAC) com eficacia esperada para o curso(RA5_EFICAC).    

// Para cada funcionario(SRA) pode ser cadastrado um cargo e para esse cargo pode haver exigencia de algum(uns) curso(s)(RA5). 
// Na tabela curso do cargo (RA5) existe o campo eficacia minima para cada curso.
// Os cursos estao amarrados ao cargo do funcionario e o cargo pode ser obtido diretamente do cadastro de funcionario(RA_CARGO)
// ou, caso nao haja cargo cadastrado na tabela SRA e verificado o cargo da funcao do funcionario(RJ_CARGO).       

// Atraves da pontuacao da eficacia obtida e a esperada, e calculado o indice de aproveitamento dos cursos. (RA4_EFICAC x RA5_EFICAC).

// Sao consideradas as avalicoes de eficacia dos funcionarios cujo curso seja exigencia do cargo do funcionario(resultado:QUANT) e          
// considerada a quantidade de avalicoes de eficacia dos cursos realizados no periodo que tiveram pontuacao maior ou igual a eficacia esperada(resultado:APROVADOS).
                                                   
	BeginSql Alias cAliasQry
		SELECT  SUM(CASE WHEN RA4_EFICAC >= (CASE WHEN RA5A.RA5_EFICAC IS NOT NULL THEN (RA5A.RA5_EFICAC) ELSE (RA5B.RA5_EFICAC) END)  
		THEN (1) ELSE 0 END) AS EFICACIA, count(RA5A.RA5_EFICAC)+count(RA5B.RA5_EFICAC) AS QUANT
		FROM %table:RA4% RA4  

		INNER JOIN %table:SRA% SRA ON
		RA4.RA4_MAT = SRA.RA_MAT 
	    AND SRA.RA_FILIAL = %xFilial:SRA% 
		AND SRA.%notDel%       
		
		LEFT JOIN %table:RA5% RA5A ON
		SRA.RA_CARGO = RA5A.RA5_CARGO
		AND SRA.RA_CC = RA5A.RA5_CC
		AND RA4.RA4_CURSO = RA5A.RA5_CURSO  
		AND RA5A.RA5_FILIAL = %xFilial:RA5% 
		AND RA5A.%notDel%    
		
		LEFT JOIN %table:SRJ% SRJ ON  
        SRA.RA_CODFUNC = SRJ.RJ_FUNCAO		
		AND SRJ.RJ_FILIAL = %xFilial:SRJ% 
		AND SRJ.%notDel% 
  
		LEFT JOIN %table:RA5% RA5B ON  
		SRJ.RJ_CARGO = RA5B.RA5_CARGO
		AND RA4.RA4_CURSO = RA5B.RA5_CURSO 
		AND SRA.RA_CC = RA5B.RA5_CC
        AND %Exp:cExpre%
		AND RA5B.RA5_FILIAL = %xFilial:RA5% 
		AND RA5B.%notDel% 
	   
		WHERE 
		%Exp:cWhere%  
	EndSql	
		
nEficacia	:=	(cAliasQry)->EFICACIA 
nQuant		:=	(cAliasQry)->QUANT 
	    
If nEficacia > 0 
	nIndAproveit := (nEficacia/nQuant) *100  // Percentual referente ao aproveitamento dos cursos   
EndIf		
(cAliasQry)->(DbCloseArea())	                          

aRetorno:= {nQuant,nEficacia}		
Return aRetorno
                
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TrmHelpPnlºAutor  ³Joeudo Santana	     º Data ³  09/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta Helps dos paineis do TRM                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PAINEL SIGATRM                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TrmHelpPnl(nPainel) 
Local cHelp := ""

   Do Case
   		Case nPainel = 1
   			cHelp := "'"+STR0011+"'" //"Neste painel são apresentados os indicadores de planejamento de cursos conforme período configurado."
   		Case nPainel = 2
   			cHelp := "'"+STR0012+"'" //"Neste painel são apresentados os indicadores de colaboradores capacitados."
   		Case nPainel = 3
   			cHelp := "'"+STR0013+"'" //"Neste painel é apresentado o índice de aproveitamento dos cursos realizados pelos colaboradores em função da expectativa dos cursos dos cargos."
   		Case nPainel = 4
   			cHelp := "'"+STR0014+"'" //"Neste painel é apresentado o índice de eficácia dos cursos realizados pelos colaboradores em função da expectativa dos cursos dos cargos. Avaliação efetuada pelos avaliadores."
   		Case nPainel = 5
   			cHelp := "'"+STR0015+"'" //"Quantidade de cursos planejados para período." 
   		Case nPainel = 6
   			cHelp := "'"+STR0016+"'" //"Todos os cursos realizados no período, ou seja, planejado e não planejados."
   		Case nPainel = 7
   			cHelp := "'"+STR0017+"'" //"Valor dos cursos planejados para o período."
   		Case nPainel = 8
   			cHelp := "'"+STR0018+"'" //"Valor dos cursos planejados para o período."
   		Case nPainel = 9
   			cHelp := "'"+STR0019+"'" //"Valor de todos os cursos realizados no período, planejado e não planejados."
   		Case nPainel = 10
   			cHelp := "'"+STR0020+"'" //"Índice da quantidade de cursos realizados que estavam planejados em função da quantidade de cursos planejados."
   		Case nPainel = 11
   			cHelp := "'"+STR0021+"'" //"Índice do valor dos cursos realizados que estavam planejados em função do valor dos cursos planejados."
   		Case nPainel = 12
   			cHelp := "'"+STR0022+"'" //"Média das notas apuradas das avaliações dos cursos realizados pelos funcionários no período configurado."
   		Case nPainel = 13
   			cHelp := "'"+STR0023+"'" //"Quantidade de colaboradores planejados para capacitação no período configurado."
   		Case nPainel = 14
   			cHelp := "'"+STR0024+"'" //"Quantidade de colaboradores capacitados no período configurado."
     EndCase			
Return cHelp
