#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

#DEFINE NUM_PICT "@E 999,999,999"
#DEFINE VAL_PICT "@E 999,999,999.99"
#DEFINE PER_PICT "@E 999,999"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMPGOnl � Autor � Rogerio Ribeiro       � Data � 30/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao dos paineis on-line para modulo TREINAMENTO      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMPGOnl                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATRM                                                    ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.          ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�28/07/14�TPZWA0�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
		TITLE		STR0003;  //"indice de aprova��es dos cursos"
		DESCR		STR0003;  //"indice de aprova��es dos cursos"
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
		TITLE		STR0004; //"�ndice Efic�cia dos cursos"
		DESCR		STR0004; //"�ndice Efic�cia dos cursos"
		TYPE		3;
		ONLOAD		"TRMPGOL004";
		REFRESH		nTempo;    
		TOOLBAR		aToolBar ;			
		NAME		"TRMPGOL004";
		PARAMETERS	"TRMPG4"
Return


/* 
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � TRMPGOL001 � Autor � Joeudo Santana		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Alimenta Painel 1 (Tipo 1) - Indicativo sobre colaboradores  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � TRMPGOL001													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL															���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
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
				{ STR0009,			Transform(nMedia	 , PER_PICT)+"%",	CLR_BLACK,	"{ || MsgInfo("+TrmHelpPnl(12)+") }" };	 //"M�dias Capacita��es"  
			}
Return aRetorno	 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � TRMPGOL002 � Autor � Joeudo Santana		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Alimenta Painel 2 (Tipo 4) - Indicativo sobre colaboradores  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � TRMPGOL002													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL															���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � TRMPGOL003 � Autor � Joeudo Santana		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Alimenta painel 3 (tipo 3) - Indice de aprovacoes do curso	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � TRMPGOL003													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL															���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
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
aRetorno:= 	{If(nCursos > 0,"",STR0010), Alltrim(Transform(nAprovac,PER_PICT))+"%", "", CLR_BLACK, Nil, 0, 100, nAprovac} // "N�o h� dados a serem exibidos" 

Return aRetorno

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � TRMPGOL004 � Autor � Joeudo Santana		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Alimenta painel 4 (tipo 3) - Indice de aproveitamento dos	��� 
���          � cursos														���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � TRMPGOL004													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL															���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Function TRMPGOL004
Local aRetorno	:= {}	
Local aAproveit	:= {}
Local nAproveit := 0

Pergunte("TRMPG4", .F.)	
// Indice de aproveitamento dos cursos no periodo determinado pelo usuario       
aAproveit	:=	IndAproveit()
nQuant		:=	aAproveit[1]  
nAproveit	:=	aAproveit[2]  
aRetorno:= 	{If(nQuant>0,"",STR0010),Alltrim(Transform(nAproveit,PER_PICT))+"%" , "", CLR_BLACK, Nil, 0, 100, nAproveit} // "N�o h� dados a serem exibidos"

Return aRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � CursPlanej		� Autor � Joeudo Santana	  � Data � 23/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna quantidade e valor dos cursos planejados	no periodo	  	  ���    
���			 � determinado pelo usuario										  	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CursPlanej()	   													  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(quantidade e valor)										  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � CursRealiz		� Autor � Joeudo Santana	  � Data � 23/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna quantidade, valor e horas dos cursos Realizados no periodo ���  
���          � determinado pelo usuario											  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CursRealiz()	   													  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(quantidade,valor e horas)								  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � CurPlanRlz		� Autor � Joeudo Santana	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna quantidade e valor dos cursos Realizados que foram		  ���    
���			 � planejados														  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CursRealiz()	   													  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(quantidade e valor)										  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � IndAvaliaCur		� Autor � Joeudo Santana	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna media das notas nos cursos realizados no periodo			  ���  
���          � determinado pelo usuario											  ���    
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � IndAvaliaCur()	   												  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(media das notas)								   			  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � PlanColaborad	� Autor � Joeudo Santana	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna quantidade de colaboradores que serao capacitados		  ���  
���          � no periodo determinado pelo usuario de acordo com planejamento 	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PlanColaborad()	   												  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(Quantidade de colaboradores)					   			  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � CapcColaborad	� Autor � Joeudo Santana 	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna quantidade de colaboradores que foram capacitados		  ���  
���          � no periodo determinado pelo usuario							 	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CapcColaborad()	   												  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(Quantidade de colaboradores)					   			  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � IndAprovac		� Autor � Joeudo Santana 	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna indice de aprovacao dos cursos no periodo determinado 	  ���  
���			 � pelo usuario													 	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � IndAprovac()	   													  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(Indice de Aprovacao)					   			          ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/

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
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � IndAproveit		� Autor � Joeudo Santana 	  � Data � 26/02/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Indice de aproveitamento dos Cursos						  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � IndAproveit()	   												  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum															  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � Retorno(Valor - Indice de aproveitamento)			   			  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGATRM  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TrmHelpPnl�Autor  �Joeudo Santana	     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta Helps dos paineis do TRM                         ���
�������������������������������������������������������������������������͹��
���Uso       � PAINEL SIGATRM                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TrmHelpPnl(nPainel) 
Local cHelp := ""

   Do Case
   		Case nPainel = 1
   			cHelp := "'"+STR0011+"'" //"Neste painel s�o apresentados os indicadores de planejamento de cursos conforme per�odo configurado."
   		Case nPainel = 2
   			cHelp := "'"+STR0012+"'" //"Neste painel s�o apresentados os indicadores de colaboradores capacitados."
   		Case nPainel = 3
   			cHelp := "'"+STR0013+"'" //"Neste painel � apresentado o �ndice de aproveitamento dos cursos realizados pelos colaboradores em fun��o da expectativa dos cursos dos cargos."
   		Case nPainel = 4
   			cHelp := "'"+STR0014+"'" //"Neste painel � apresentado o �ndice de efic�cia dos cursos realizados pelos colaboradores em fun��o da expectativa dos cursos dos cargos. Avalia��o efetuada pelos avaliadores."
   		Case nPainel = 5
   			cHelp := "'"+STR0015+"'" //"Quantidade de cursos planejados para per�odo." 
   		Case nPainel = 6
   			cHelp := "'"+STR0016+"'" //"Todos os cursos realizados no per�odo, ou seja, planejado e n�o planejados."
   		Case nPainel = 7
   			cHelp := "'"+STR0017+"'" //"Valor dos cursos planejados para o per�odo."
   		Case nPainel = 8
   			cHelp := "'"+STR0018+"'" //"Valor dos cursos planejados para o per�odo."
   		Case nPainel = 9
   			cHelp := "'"+STR0019+"'" //"Valor de todos os cursos realizados no per�odo, planejado e n�o planejados."
   		Case nPainel = 10
   			cHelp := "'"+STR0020+"'" //"�ndice da quantidade de cursos realizados que estavam planejados em fun��o da quantidade de cursos planejados."
   		Case nPainel = 11
   			cHelp := "'"+STR0021+"'" //"�ndice do valor dos cursos realizados que estavam planejados em fun��o do valor dos cursos planejados."
   		Case nPainel = 12
   			cHelp := "'"+STR0022+"'" //"M�dia das notas apuradas das avalia��es dos cursos realizados pelos funcion�rios no per�odo configurado."
   		Case nPainel = 13
   			cHelp := "'"+STR0023+"'" //"Quantidade de colaboradores planejados para capacita��o no per�odo configurado."
   		Case nPainel = 14
   			cHelp := "'"+STR0024+"'" //"Quantidade de colaboradores capacitados no per�odo configurado."
     EndCase			
Return cHelp
