#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APDXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APDPGOnl � Autor � Joeudo Santana        � Data � 23/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao dos paineis on-line para modulo Avaliacao e      ���
���          � Pesquisa de Desempenho                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDPGOnl                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.         ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/07/14�TPZWF1�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function APDPGOnl(oPGOnline)
     
Local aToolBar  := {}                          
Local nTempo   	:= SuperGetMV("MV_PGORFSH", .F., 60)//Tempo para atualizacao do painel

//-------------------------------------------------------------------------------
// PAINEL 1 - AVALIACOES RESPONDIDAS E PENDENTES
//-------------------------------------------------------------------------------               

//Botao de Help do Painel
 	Aadd( aToolBar, { "S4WB016N","Help",  { || ApdHelpPnl(1) }})   

PANELONLINE oPgOnLine ADDPANEL;
	TITLE	 	STR0001;			  //"avalia��es respondidas e pendentes "
	DESCR		STR0002;			  //"Numero de avalia��es respondidas e pendentes por tipo de avalia��o (auto-avalia��o, Avaliador e Consenso) "
	TYPE 		2;
	ONLOAD 		"APDPGOL001";
	REFRESH 	nTempo;            
	TOOLBAR 	aToolBar ;	
	NAME		"APDPGOL001";  
	PARAMETERS 	"APDP1R";  
	DEFAULT 	3

//-------------------------------------------------------------------------------
// PAINEL 2 - RESULTADOS DAS AVALIACOES POR COMPETENCIA
//-------------------------------------------------------------------------------		                                 

//Botao de Help do Painel 
aToolBar  := {}	
Aadd( aToolBar, { "S4WB016N","Help",{ || ApdHelpPnl(2) }})  	

PANELONLINE oPgOnLine ADDPANEL;
	TITLE 		STR0003;    		//"resultados das avalia��es por compet�ncia"
	DESCR 		STR0004;    		//"M�dias dos resultados das avalia��es por compet�ncia por tipo de avalia��o"
	TYPE 		2;	
	ONLOAD		"APDPGOL002";
	REFRESH 	nTempo;
	TOOLBAR 	aToolBar ;	
	NAME 		"APDPGOL002"; 
	PARAMETERS 	"APDP2R";   
	DEFAULT 	3
Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � APDPGOL001 � Autor � Joeudo Santana		  � Data � 09/03/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Alimenta painel 1 (tipo 2) - Numero de avaliacoes respondidas	��� 
���          �e pendentes por tipo de avalia��o (auto-avalia��o, 			���
���          �Avaliador e Consenso) 										���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � APDPGOL001													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aRetorno (Array com formato painel tipo 2 padrao 3 )			���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAAPD	 			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/

Function APDPGOL001        
                                
Local aArea	   		:=	GetArea() 
Local cAliasQry		:=	GetNextAlias() 
Local cTipoAvalia	:=	RdcTipoAvBox()                          
Local aRetorno		:=	{}	
Local aTipAval		:=	{}
Local aDescAvalia	:=	{}	  
Local aQuantAval	:=	{}	      
Local aEixoX		:=	{}              
Local aLegenda		:=	{STR0005 ,STR0006}	//"Respondidas" - "Pendentes"   
Local cExp			:=	"%CASE WHEN RDC.RDC_DATRET <> '' THEN 1 ELSE 2 END AS SITUACAO%
Local cExp2			:=	"%CASE WHEN RDC.RDC_DATRET <> '' THEN 1 ELSE 2 END%"         
Local cFiltro		:=	""
Local nX			:=	0   
Local lResult:= 	.F.

Pergunte("APDP1R", .F.)
//��������������������������������������������������������������Ŀ
//� mv_par01 - Codigo da Avaliacao  -(Parametro tipo Range)      �
//����������������������������������������������������������������

// Prepara filtro para query atraves do range do mv_par01
cFiltro:= APDPOFltr(mv_par01,"RDC.RDC_CODAVA")

BeginSql alias cAliasQry  
	SELECT RDC.RDC_TIPOAV, %Exp:cExp% , count(*) AS QUANT 
	FROM %Table:RDC% RDC 
	INNER JOIN %Table:RD6% RD6 ON          
	RD6_CODIGO = RDC_CODAVA 
	AND RD6_STATUS = '1'
	WHERE 
	RDC.RDC_FILIAL =  %xFilial:RDC%	AND
	%exp:cFiltro% 
	RDC.%notDel% 
	GROUP BY RDC.RDC_TIPOAV, %Exp:cExp2% 
	Order By SITUACAO
EndSql                     
           
Dbselectarea(cAliasQry)
                                                                                         
// Separa string e coloca as partes dentro do array aDescAvalia
aDescAvalia := SepString(cTipoAvalia,";") 
// Alimenta array com descricao do tipo de avaliacao (Avaliador, auto-avaliacao e consenso)   
aEval(aDescAvalia,{|x|aadd(aEixoX,Substr(x,3))})
  
// Inicializa vetores com valor zero     
If !(cAliasQry)->(eof()) 
	aQuantAval	:=	Array(len(aEixoX)) 
	aTipAval	:=	Array(len(aLegenda),len(aEixoX))     
	For nx:= 1 to len(aQuantAval)
		aQuantAval[nx]:=0
	Next nx  
	aEval(aTipAval,{|x|x:=aClone(aQuantAval)})  
EndIf	
	  	   
//Adiciona numero de avaliacoes respondidas e pendentes por tipo   
//SITUACAO = 1 : RESPONDIDAS 
//SITUACAO = 2 : PENDENTES 
While !(cAliasQry)->(eof())  
  	aTipAval[(cAliasQry)->SITUACAO][val(alltrim((cAliasQry)->RDC_TIPOAV))]:=	(cAliasQry)->QUANT   
  	lResult:= .T.
	(cAliasQry)->(dbskip())               
Enddo   
(cAliasQry)->(DbCloseArea())       	

// Reinicializa vetores caso query nao traga registro algum
If !lResult
	aTipAval	:=	{{0}}   
	aEixoX		:=	{STR0007}	//"N�o h� dados a serem exibidos"	
	aLegenda	:=	{""}
EndIf

aRetorno:=	{;
				GRP_BAR,;
				NIL,;
				aEixoX,;   //{"","",""}
				aLegenda,; //{"",""} 
				aTipAval;  //{{0,0,0},{0,0,0}}
			}  

RestArea(aArea)  			
Return aRetorno  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � APDPGOL002 � Autor � Joeudo Santana		  � Data � 23/03/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Alimenta Painel 2 (Tipo 2) - Media dos resultados das 		���
���			 � avaliacoes por competencia por tipo de avaliacao	 			���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CSAPGOL002													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aRetorno (Array com formato painel tipo 2 padrao 3 )			���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAAPD  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function APDPGOL002            
     
Local aArea	   		:=	GetArea()   
Local aRetorno		:=	{}	
Local aMediaComp	:=	{}   
Local aLegenda		:=	{}  
Local aEixox		:=	{STR0008}	//"Lista das Competencias"
Local cAliasQry		:=	GetNextAlias()   
Local cFiltro		:=	""   
Local cJoin			:=	" LEFT JOIN "+ RetSqlName("RDM") +" RDM ON RDM_CODIGO =RDD_CODCOM "

Pergunte("APDP2R", .F.)   
//��������������������������������������������������������������Ŀ
//� mv_par01 - Codigo da Avaliacao  -	(Parametro tipo Range)   �
//� mv_par02 - Situacao			    - 	1 Aberto			     � 
//� 						  	 		2 Fechado				 �
//�								 		3 Todos				     �
//����������������������������������������������������������������

// Prepara filtro para query atraves do range do mv_par01
cFiltro:= APDPOFltr(mv_par01,"RDD.RDD_CODAVA")

// Filtro por situacao esolhida no parametro mv_par02
If mv_par02 <> 3
	cJoin+= " INNER JOIN "+ RetSqlName("RD6")+ " RD6 ON"
	cJoin+= " RD6_CODIGO = RDD_CODAVA"
	cJoin+= " AND RD6_STATUS = '"+Alltrim(str(mv_par02))+"' "
EndIf                                                         
cJoin	:=  "%"+cJoin +"%"

// Retorna media das competencias de acordo com parametro range
BeginSql alias cAliasQry           
	COLUMN MEDIA   AS NUMERIC(12,2) 
	SELECT RDD.RDD_CODCOM,RDM_DESC,  AVG(RDD_RESOBT) MEDIA 
	FROM %Table:RDD% RDD                                      
	%exp:cJoin%
	WHERE
	RDD.RDD_FILIAL = %xFilial:RDD% AND 
	%exp:cFiltro% 	
	RDD.%notDel% 
	GROUP BY RDD.RDD_CODCOM, RDM_DESC    
EndSql        

//-- Adiciona media de cada competencia
Dbselectarea(cAliasQry)
While !(cAliasQry)->(eof())  
	aAdd(aMediaComp,{(cAliasQry)->MEDIA}) 	
	aAdd(aLegenda,(cAliasQry)->RDM_DESC) 	
	(cAliasQry)->(dbskip())               
Enddo

// Inicializa vetores caso query nao traga registro algum          
If (len(aMediaComp) == 0)   
	aMediaComp	:=	{{0}}   	
	aEixox		:=  {STR0007}	//"N�o h� dados a serem exibidos"   
	aLegenda	:=	{""} 
EndIf

(cAliasQry)->(DbCloseArea())  
                                 			
aRetorno:=	{;
				GRP_BAR,;
				NIL,;
				aEixox,;   		//"Lista das Competencias"
				aLegenda,;
				aMediaComp;
			}  
			  
RestArea(aArea)			
Return aRetorno                           


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SepString �Autor  �Joeudo Santana	     � Data �  26/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria um array baseando-se em uma string delimitada por um  ��� 
���          � caracter pre-definido                                      ���
�������������������������������������������������������������������������͹��
���Uso       � PAINEL SIGAAPD                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SepString( cString, cDelim )
             
Local aPartes := {}
Local nProc
Default cString := ""
Default cDelim  := "/"
   
//��������������������������������������������������������������Ŀ
//� Adiciona o delimitador ao final da string 			         �
//����������������������������������������������������������������
cString += if( len(cString)==0, "", cDelim )
   
//��������������������������������������������������������������Ŀ
//� 1 - Procura a posicao do delimitador                         �
//� 2 - Adiciona ao array o elemento delimitado                  �
//� 3 - Elimina da string o elemento adicionado                  �
//����������������������������������������������������������������
Do while ! empty( cString )
	If ( nProc := at( cDelim, cString ) ) <> 0		
		aadd( aPartes, substr( cString, 1, nProc - 1 ) )
		cString := substr( cString, nProc + len( cDelim ) )
	Endif
Enddo

Return aPartes 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �APDPOFltr � Autor � Joeudo Santana		� Data � 23/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria filtro para query atraves do parametro de usuario do  ��� 
���          � do tipo range		                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � APDPOFltr(cPar1, cPar2)							   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cParametr = Range do pergunte                              ��� 
���			 � cCampo    = Nome do campo                       			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cFiltro                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAAPD  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function APDPOFltr(cParametr,cCampo)

Local aParams		:=	{} 
Local aFiltroBet	:=	{}
Local cCodAva		:=	""
Local cFiltro		:=	"" 
Local nX			:=	0                     

// Separa partes do string e as coloca dentro do array aParams
aParams:=	SepString(cParametr,";") 
// Carrega Filtro do tipo Range
For nX:= 1 to len(aParams)    
    cCodAva:= Alltrim(aParams[nX])
    If !Empty(cCodAva) 			// Nao vazio   
		If len(cCodAva)>6                     
			// Caso tenha tamanho maior que o campo codigo da avaliacao, 
			// separa partes do string e coloca dentro do array aFiltroBet
			aFiltroBet:= SepString(cCodAva,"-") 
			If len(aFiltroBet) == 2             
				// Caso o string anterior tenha duas partes e estas partes tenham o tamanho 
				// do campo codigo da avaliacao, adiciona partes como um intervalo de avaliacoes (COD = parte1 between parte2)
				If len(aFiltroBet[1])==6 .and. len(aFiltroBet[2]) == 6 //ambas as partes tenham o tamanho do campo codigo de avaliacao
					If (!Empty(cFiltro),	cFiltro+=" OR ",) 
					cFiltro += cCampo+" BETWEEN '" + aFiltroBet[1]+ "' AND '" + aFiltroBet[2]+"'"
				EndIf	
			EndIf
		ElseIf len(cCodAva)== 6	  
			// Caso o string tenha o tamanho do campo codigo da avaliacao, adiciona o string ao filtro (COD = strig)
			If (!Empty(cFiltro),	cFiltro+=" OR ",)
			cFiltro+= cCampo+" = '"+cCodAva+"'"
		EndIf  
	EndIf
Next nX 
 
cFiltro:= If (len(cFiltro)>0,"% "+cFiltro+" AND %",;
							  "%"+cCampo+" = ''"+" AND%" ) 
Return  cFiltro

                                           
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ApdHelpPnl�Autor  �Joeudo Santana	     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta Helps dos paineis do APD                         ���
�������������������������������������������������������������������������͹��
���Uso       � PAINEL SIGAAPD                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ApdHelpPnl(nPainel) 
   If nPainel = 1
   		MsgInfo(STR0009) //"Neste Painel s�o apresentados os n�meros de avalia��es respondidas e pendentes por tipo de avalia��o (auto-avalia��o, Avaliador e Consenso)."
   Else	
   		MsgInfo(STR0010) //"Neste Painel s�o apresentadas as m�dias de cada compet�ncia da avalia��o."
   EndIf			
Return
