#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APDXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ APDPGOnl ³ Autor ³ Joeudo Santana        ³ Data ³ 23/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definicao dos paineis on-line para modulo Avaliacao e      ³±±
±±³          ³ Pesquisa de Desempenho                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APDPGOnl                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAAPD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³04/07/14³TPZWF1³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APDPGOnl(oPGOnline)
     
Local aToolBar  := {}                          
Local nTempo   	:= SuperGetMV("MV_PGORFSH", .F., 60)//Tempo para atualizacao do painel

//-------------------------------------------------------------------------------
// PAINEL 1 - AVALIACOES RESPONDIDAS E PENDENTES
//-------------------------------------------------------------------------------               

//Botao de Help do Painel
 	Aadd( aToolBar, { "S4WB016N","Help",  { || ApdHelpPnl(1) }})   

PANELONLINE oPgOnLine ADDPANEL;
	TITLE	 	STR0001;			  //"avaliações respondidas e pendentes "
	DESCR		STR0002;			  //"Numero de avaliações respondidas e pendentes por tipo de avaliação (auto-avaliação, Avaliador e Consenso) "
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
	TITLE 		STR0003;    		//"resultados das avaliações por competência"
	DESCR 		STR0004;    		//"Médias dos resultados das avaliações por competência por tipo de avaliação"
	TYPE 		2;	
	ONLOAD		"APDPGOL002";
	REFRESH 	nTempo;
	TOOLBAR 	aToolBar ;	
	NAME 		"APDPGOL002"; 
	PARAMETERS 	"APDP2R";   
	DEFAULT 	3
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ APDPGOL001 ³ Autor ³ Joeudo Santana		  ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alimenta painel 1 (tipo 2) - Numero de avaliacoes respondidas	³±± 
±±³          ³e pendentes por tipo de avaliação (auto-avaliação, 			³±±
±±³          ³Avaliador e Consenso) 										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ APDPGOL001													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 2 padrao 3 )			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAAPD	 			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Codigo da Avaliacao  -(Parametro tipo Range)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
	aEixoX		:=	{STR0007}	//"Não há dados a serem exibidos"	
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ APDPGOL002 ³ Autor ³ Joeudo Santana		  ³ Data ³ 23/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Painel 2 (Tipo 2) - Media dos resultados das 		³±±
±±³			 ³ avaliacoes por competencia por tipo de avaliacao	 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CSAPGOL002													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetorno (Array com formato painel tipo 2 padrao 3 )			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAAPD  			   										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Codigo da Avaliacao  -	(Parametro tipo Range)   ³
//³ mv_par02 - Situacao			    - 	1 Aberto			     ³ 
//³ 						  	 		2 Fechado				 ³
//³								 		3 Todos				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
	aEixox		:=  {STR0007}	//"Não há dados a serem exibidos"   
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SepString ºAutor  ³Joeudo Santana	     º Data ³  26/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria um array baseando-se em uma string delimitada por um  º±± 
±±º          ³ caracter pre-definido                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PAINEL SIGAAPD                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SepString( cString, cDelim )
             
Local aPartes := {}
Local nProc
Default cString := ""
Default cDelim  := "/"
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o delimitador ao final da string 			         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += if( len(cString)==0, "", cDelim )
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1 - Procura a posicao do delimitador                         ³
//³ 2 - Adiciona ao array o elemento delimitado                  ³
//³ 3 - Elimina da string o elemento adicionado                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do while ! empty( cString )
	If ( nProc := at( cDelim, cString ) ) <> 0		
		aadd( aPartes, substr( cString, 1, nProc - 1 ) )
		cString := substr( cString, nProc + len( cDelim ) )
	Endif
Enddo

Return aPartes 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³APDPOFltr ³ Autor ³ Joeudo Santana		³ Data ³ 23/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria filtro para query atraves do parametro de usuario do  º±± 
±±º          ³ do tipo range		                                      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ APDPOFltr(cPar1, cPar2)							   	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cParametr = Range do pergunte                              ³±± 
±±³			 ³ cCampo    = Nome do campo                       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cFiltro                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAAPD  			   									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ApdHelpPnlºAutor  ³Joeudo Santana	     º Data ³  09/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta Helps dos paineis do APD                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PAINEL SIGAAPD                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ApdHelpPnl(nPainel) 
   If nPainel = 1
   		MsgInfo(STR0009) //"Neste Painel são apresentados os números de avaliações respondidas e pendentes por tipo de avaliação (auto-avaliação, Avaliador e Consenso)."
   Else	
   		MsgInfo(STR0010) //"Neste Painel são apresentadas as médias de cada competência da avaliação."
   EndIf			
Return
