#Include "PanelOnLine.ch"
#Include "PlsPgOnL.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FATPGONL  � Autor � Marco Bianchi         � Data � 18/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao.                                             ���
���          �Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FATPGONL(oPGOnline)                                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function PLSPGONL(oPGOnline)

Local aToolBar  := {}
Local cString   := "" 
Local aPainel	:= {}
Local cStrFun	:= ""  
Local nI		:= 0


cStrFun	:= FUNNAME() // Verifica��o se esta sendo chamado de dentro ou de fora do modulo

If "10" $ GetVersao(.F.) // caso seja vers�o 10 pode verificar ser existe a tabela
	If !HS_ExisDic({{"T", "GTA"}},.F.)
		Return
	EndIf                    
EndIf

//���������������������������������,�
//�Montagem dos paineis cadastrados�
//���������������������������������,�
If Empty(cStrFun)
	aPainel := HS_RTPGON()
else
	aPainel := HS_2RTPGON()
EndIf
//������������������������������������������������������������������������Ŀ
//�Varre os tipos cadastrados e monta conforme respectiva rotina           �
//��������������������������������������������������������������������������
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
