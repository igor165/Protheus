#Include "PanelOnLine.ch"
#Include "PonPgOnL.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PONPGOnl � Autor � MICROSIGA             � Data �   /  /   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao dos paineis on-line para modulo Ponto Eletronico ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PONPGOnl                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAPON                                                    ���
�������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.         ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.  �21/05/14�TPQAN3�Incluido o fonte da 11 para a 12 e efetua-��� 
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function PONPGOnl(oPgOnLine)

Local nTempo   	:= SuperGetMV("MV_PGORFSH", .F., 500)//Tempo para atualizacao do painel
aToolBar		:= {}
Aadd( aToolBar, { "S4WB016N","Help",{ || PONPGHLP("001") } } )

 
PANELONLINE oPgOnLine 		;
	ADDPANEL TITLE STR0001	; 	// "Quantidade de Horas no m�s"
		DESCR STR0002 		; 	// "Quantidade de Horas no m�s por filial"
		TYPE 2				   ;
 	    ONLOAD "PonOnl01"   ;
 	    REFRESH nTempo		; 	
   	    DEFAULT 1			   ;
	   	TOOLBAR aToolBar    ;
	 	NAME	"PonOnl01"	  ;              
 	    TITLECOMBO STR0003 		// "Filial "	 	 

     
aToolBar	:={}

Aadd( aToolBar, { "S4WB016N",STR0044 ,{ || PONPGHLP("002") } } )

PANELONLINE oPgOnLine 		;
	ADDPANEL TITLE STR0004	; 	// "N�vel do Banco de Horas"
		DESCR STR0005 		; 	// "N�vel do Banco de Horas por filial"
		TYPE 2				;
 	    ONLOAD "PonOnl02"   ;
	    REFRESH nTempo		; 	
   	    DEFAULT 1			;
		TOOLBAR aToolBar    ;   	    
	 	NAME	"PonOnl02"	;
 	    TITLECOMBO STR0003 		// "Filial "	 
 	    
       
aToolBar	:={}

Aadd( aToolBar, { "S4WB016N",STR0044 ,{ || PONPGHLP("003") } } )  

PANELONLINE oPgOnLine 		;
	ADDPANEL TITLE STR0006	; 	// "Quantidade de Horas no M�s"
		DESCR STR0007 		; 	// "Horas Previstas X Realizadas"
		TYPE 2				;
 	    ONLOAD "PonOnl03"   ;
        REFRESH nTempo		; 	
   	    DEFAULT 1			;
		TOOLBAR aToolBar    ;      	    
	 	NAME	"PonOnl03"	;              
 	    TITLECOMBO STR0003 		// "Filial "	 	
      
    
Return	
                                


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PONPGHLP �Autor  �MAURICIO MR         � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de Help para os paineis de gestao.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Paineis de Gestao                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PONPGHLP(cPainel)


If cPainel == '001'

	MsgInfo( STR0008+CHR(13)+CHR(10)+;  //"ESSE PAINEL DEMONSTRA INDICADORES BASEADOS NOS SEGUINTES IDENTIFICADORES:+CHR(13)+CHR(10)+;  //"
			 STR0009+CHR(13)+CHR(10)+;  //"* HORAS TRABALHADAS"
			 STR0010+CHR(13)+CHR(10)+;  //"001A	HORAS NORMAIS"
			 STR0011+CHR(13)+CHR(10)+;  //"026A	HORAS NORMAIS NOTURNAS"
			 STR0012+CHR(13)+CHR(10)+;  //"* HORAS NAO REALIZADAS"
			 STR0013+CHR(13)+CHR(10)+;  //"005A	HORAS NORMAIS NAO REALIZADAS"
			 STR0014+CHR(13)+CHR(10)+;  //"006A	HORAS NOTURNAS NAO REALIZADAS"
			 STR0015+CHR(13)+CHR(10)+;  //"* FALTAS+CHR(13)+CHR(10)+;  //"
			 STR0016+CHR(13)+CHR(10)+;  //"007N	FALTA 1/2 PERIODO NAO AUTORIZADA"
			 STR0017+CHR(13)+CHR(10)+;  //"008A	FALTA 1/2 PERIODO AUTORIZADA"
			 STR0018+CHR(13)+CHR(10)+;  //"009N	FALTA INTEGRAL NAO AUTORIZADA"
			 STR0019+CHR(13)+CHR(10)+;  //"010A	FALTA INTEGRAL AUTORIZADA"
			 STR0020+CHR(13)+CHR(10)+;  //"* ATRASOS"
			 STR0021+CHR(13)+CHR(10)+;  //"011N	ATRASO NAO AUTORIZADO"
			 STR0022+CHR(13)+CHR(10)+;  //"012A	ATRASO AUTORIZADO"
			 STR0023+CHR(13)+CHR(10)+;  //"* SAIDAS"
			 STR0024+CHR(13)+CHR(10)+;  //"013N	SAIDA ANTECIPADA NAO AUTORIZADA"
			 STR0025+CHR(13)+CHR(10)+;  //"014A	SAIDA ANTECIPADA AUTORIZADA"
			 STR0026+CHR(13)+CHR(10)+;  //"019N	SAIDA NO EXPEDIENTE NAO AUTORIZADO"
			 STR0027+CHR(13)+CHR(10)+;  //"020A	SAIDA NO EXPEDIENTE AUTORIZADO" 
			 STR0028+CHR(13)+CHR(10)+;  //"1) S�O CONSIDERADAS APENAS AS HORAS APURADAS NO PER�ODO DE APONTAMENTO"
		   	 STR0029+CHR(13)+CHR(10)+;  //"   ABERTO."    
			 STR0030+CHR(13)+CHR(10)+;  //"2) SE A RELA��O ENTRE IDENTIFICADORES E SEUS EVENTOS FOR MODIFICADA,+CHR(13)+CHR(10)+;  //"
			 STR0031+CHR(13)+CHR(10)+;  //"   A ALTERA��O SOMENTE SERA CONSIDERADA EM UM NOVO ACESSO AO SISTEMA"
			 STR0032+CHR(13)+CHR(10)+;  //"4) AS HORAS EXTRAS S�O IDENTIFICADAS CONFORME OS EVENTOS DA TABELA DE+CHR(13)+CHR(10)+;  //"
			 STR0033+CHR(13)+CHR(10)+;  //"   HORAS EXTRAS."
			 STR0034+CHR(13)+CHR(10)+;  //"5) O TOTAL DE FUNCION�RIOS CORRESPONDE AO TOTAL DE MATR�CULAS QUE POSSUEM"
			 STR0035+CHR(13)+CHR(10)+;  //"   LAN�AMENTOS PARA O PER�ODO DE APONTAMENTO ABERTO. SE UM TURNO N�O FOI+CHR(13)+CHR(10)+;  //"
			 STR0036+CHR(13)+CHR(10)+;  //"   APONTADO, OS FUNCION�RIOS CORRESPONDENTES N�O ESTAR�O COMPUTADOS NESSE"
			 STR0037+CHR(13)+CHR(10)+;  //"   INDICADOR."
			 STR0038+CHR(13)+CHR(10)+;  //"6) OS EVENTOS ABONADOS E INFORMADOS N�O S�O CONSIDERADOS NOS C�LCULOS DOS+CHR(13)+CHR(10)+;  //"
			 STR0039+CHR(13)+CHR(10)+;  //"   INDICADORES, SOMENTE OS EVENTOS DE APONTAMENTO APURADOS PELO SISTEMA.+CHR(13)+CHR(10)+;  //"
			 STR0040+CHR(13)+CHR(10)+;  //"7) O MODO COMO AS REGRAS DE APONTAMENTO FORAM DEFINIDAS INFLUENCIAM OS+CHR(13)+CHR(10)+;  //"
			 STR0041+CHR(13)+CHR(10)+;  //"   VALORES DOS INDICADORES. POR EXEMPLO, SE EM PARTE DAS REGRAS EST�+CHR(13)+CHR(10)+;  //"
			 STR0042+CHR(13)+CHR(10)+;  //"   DETERMINADO A N�O APURA��O DE HORAS NORMAIS, ESSE INDICADOR APRESENTAR�+CHR(13)+CHR(10)+;  //"
			 STR0043+CHR(13)+CHR(10),;
		     STR0044;  //"EXPLICA��O"
			)
ElseIf cPainel == '002'
	MsgInfo(; 
			STR0045+CHR(13)+CHR(10)+;  // "S�O DEMONSTRADOS NESSE PAINEL TODOS OS LAN�AMENTOS EM BANCO DE HORAS AINDA "
			STR0046+CHR(13)+CHR(10)+;  // "N�O BAIXADOS: "
			STR0047+CHR(13)+CHR(10)+;  // "1) OS TOTAIS DE HORAS DE PROVENTOS E DESCONTOS N�O VALORIZADOS."
			STR0048+CHR(13)+CHR(10),;  // "2) OS TOTAIS DE HORAS DE PROVENTOS E DESCONTOS VALORIZADOS. "
			STR0044;  //"EXPLICA��O"
			)

ElseIf cPainel == '003'		
	MsgInfo(; 
			  STR0049+CHR(13)+CHR(10)+;  //"ESSE PAINEL DEMONSTRA OS SEGUINTES INDICADORES:+CHR(13)+CHR(10);  //"
			  STR0050+CHR(13)+CHR(10)+;  //"* HORAS PREVISTAS"
			  STR0051+CHR(13)+CHR(10)+;  //"  CORRESPONDEM AO TOTAL DE HORAS TRABALHADAS PREVISTAS PARA FUNCIONARIOS+CHR(13)+CHR(10);  //"
			  STR0052+CHR(13)+CHR(10)+;  //"  ATIVOS CONFORME OS CALEND�RIOS PADR�ES DE SEUS TURNOS.+CHR(13)+CHR(10);  //"
			  STR0053+CHR(13)+CHR(10)+;  //"  N�O S�O CONSIDERADAS AS EXECE��ES DOS FUNCION�RIOS."
			  STR0054+CHR(13)+CHR(10)+;  //"  AS HORAS PREVISTAS DE FUNCION�RIOS AFASTADOS OU EM F�RIAS N�O S�O "
			  STR0055+CHR(13)+CHR(10)+;  //"  CONSIDERADAS."
			  STR0056+CHR(13)+CHR(10)+;  //"* HORAS EXTRAS" 
			  STR0057+CHR(13)+CHR(10)+;  //"  CORRESPONDEM AO TOTAL DE HORAS DOS EVENTOS DEFINIDOS NA TABELA DE HORAS+CHR(13)+CHR(10);  //"
			  STR0058+CHR(13)+CHR(10)+;  //"  EXTRAS (CONSIDERANDO TODOS OS EVENTOS AUTORIZADOS E N�O AUTORIZADOS)."
			  STR0059+CHR(13)+CHR(10)+;  //"* HORAS REALIZADAS"
			  STR0060+CHR(13)+CHR(10)+;  //"  AS HORAS REALIZADAS CORRESPONDEM A DIFEREN�A ENTRE AS HORAS PREVISTAS E+CHR(13)+CHR(10);  //"
			  STR0061+CHR(13)+CHR(10)+;  //"  AS HORAS N�O REALIZADAS."
			  STR0062+CHR(13)+CHR(10)+;  //"* HORAS N�O REALIZADAS"
			  STR0063+CHR(13)+CHR(10)+;  //"  AS HORAS REALIZADAS S�O O RESULTADO DA SOMA DE HORAS DOS EVENTOS DEFINIDOS"
			  STR0064+CHR(13)+CHR(10),;  //"  COMO DESCONTOS NA TABELA DE EVENTOS."
		 	  STR0044;  //"EXPLICA��O"
		)							 	

Endif

Return
