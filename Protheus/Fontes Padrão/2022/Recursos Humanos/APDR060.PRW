#Include "PROTHEUS.CH"
#Include "apdr060.ch" 
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � APDR060 � Autor 矹oeudo Santana Ferreira � Data �22/05/2007潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Relat髍io de Resultado de Avalia玢o                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAAPD                                                    潮�
北砅rogram.r � Data   � FNC  �  Motivo da Alteracao                       潮�
北媚哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矯ecilia C.�04/07/14砊PZWHD矷ncluido o fonte da 11 para a 12 e efetuada 潮�
北�          �        �      砤 limpeza.                                  潮�
北矼atheus M.�19/09/16砊VYADL矨juste para permitir impress鉶 com v醨ias   潮�
北�          �        �      sess鮡s.                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/   

Function APDR060()
Local oReport
Private cPerg := "APD60R"
               
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矷nterface de impressao                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport:= ReportDef()
oReport:PrintDialog()
Return  
                                      
                                                                 
/*     
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  � ReportDef矨utor  矹oeudo Santana Ferreira矰ata  �22/05/2007潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Relat髍io de Resultado de Avalia玢o		                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� 															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � oExpO1: Objeto do relatorio                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/                                                                         
Static Function ReportDef()
Local oReport        
Local oAvaliaSection
Local oCompetSection    
Local oIteCompSection 
Local oQuestSection 
Local oAlterSection 
Local cTitle := OemToAnsi(STR0001) //"Relat髍io de Resultado de Avalia玢o"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para parametros                                   �
//媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇
//� mv_par01  -		Avaliacao  ?                                           �
//� mv_par02  -		Competencia ?                                          �
//� mv_par03  -		Item Competencia ?                                     �
//� mv_par04  -		Questoes  ?                                            �
//� mv_par05  -		Inicio da Avaliacao ?                                  �
//� mv_par06  -		Final da Avaliacao ?                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(cPerg,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao do componente de impressao                                      �
//�                                                                        �
//砊Report():New                                                           �
//矱xpC1 : Nome do relatorio                                               �
//矱xpC2 : Titulo                                                          �
//矱xpC3 : Pergunte                                                        �
//矱xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//矱xpC5 : Descricao                                                       �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := TReport():New("APDR060",cTitle,"APD60R",{|oReport| ReportPrint(oReport)},STR0001)  //"Relat髍io de Resultado de Avalia玢o"
oReport:SetLandscape() 


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//砊RSection():New                                                         �
//矱xpO1 : Objeto TReport que a secao pertence                             �
//矱xpC2 : Descricao da se鏰o                                              �
//矱xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se玢o.                   �
//矱xpA4 : Array com as Ordens do relat髍io                                �
//矱xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//矱xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da celulas da secao do relatorio                                �
//�                                                                        �
//砊RCell():New                                                            �
//矱xpO1 : Objeto TSection que a secao pertence                            �
//矱xpC2 : Nome da celula do relat髍io. O SX3 ser� consultado              �
//矱xpC3 : Nome da tabela de referencia da celula                          �
//矱xpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//矱xpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//矱xpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//矱xpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//矱xpB8 : Bloco de c骴igo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
                   
/*
谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� AVALIACAO							  						�
滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/  
oAvaliaSection:= TRSection():New(oReport,STR0002,{"RDB"},/*aOrdem*/)  //'Avaliacao'
TRCell():New(oAvaliaSection,"RDB_CODAVA","RDB"		,/*"Titulo"*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oAvaliaSection,"QTDAVALIA",/*"Alias"*/	,STR0003		,/*Picture*/,10			,/*lPixel*/,/*{|| code-block de impressao }*/)   //Quant. Avaliados
TRCell():New(oAvaliaSection,"QTDRESPON",/*"Alias"*/	,STR0004		,/*Picture*/,10			,/*lPixel*/,/*{|| code-block de impressao }*/)   //Quant. Respondidos
   
/*
谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� COMPETENCIA						  						�
滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/  
oCompetSection:= TRSection():New(oAvaliaSection,STR0005,{"RDB","RDM"},/*aOrdem*/)  //'Estrurura de competencias'
                                                                                                                                                                        
TRCell():New(oCompetSection,"RDB_CODCOM","RDB"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oCompetSection,"RDM_DESC"	,"RDM"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
    
/*
谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� ITENS DE COMPETENCIA				  						�
滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/  
oIteCompSection:= TRSection():New(oCompetSection,STR0006,{"RDB","RD2"},/*aOrdem*/)  //'Itens de Estrutura'
oIteCompSection:SetLeftMargin(2)	//Identacao da Secao                     
TRCell():New(oIteCompSection,"RDB_ITECOM","RDB"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oIteCompSection,"RD2_DESC","RD2"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

/*
谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� QUESTOES							  						�
滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/  
oQuestSection:= TRSection():New(oIteCompSection,STR0007,{"RDB","SQO"},/*aOrdem*/)  //'Questoes'
oQuestSection:SetLeftMargin(6)	//Identacao da Secao  
TRCell():New(oQuestSection,"RDB_CODQUE"	,	"RDB",/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oQuestSection,"QO_QUEST"	,	"SQO",/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

TRCell():New(oQuestSection,"QP_DESCRIC"	,	"SQP"	,STR0008		,/*Picture*/,30			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Alternativa"
TRCell():New(oQuestSection,"QUANT"		,/*"Alias"*/,STR0009		,/*Picture*/,12			,/*lPixel*/,/*{|| code-block de impressao }*/) //Quantidade 
TRCell():New(oQuestSection,"PERCENT"	,/*"Alias"*/,STR0010 		,/*Picture*/,16			,/*lPixel*/,/*{|| code-block de impressao }*/) //Porcentagem

/* 
谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� TOTALIZADORES DE ALTERNATIVAS								�
滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/  
oAlterSection:= TRSection():New(oIteCompSection,STR0011,{""},/*aOrdem*/)  //'Totais de Alterativas'
oAlterSection:SetLeftMargin(6)	//Identacao da Secao  
TRCell():New(oAlterSection,"ALTERNAT"		,/*"Alias"*/,STR0008	,/*Picture*/,5			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Alternativa" 
TRCell():New(oAlterSection,"TOTALALT" 		,/*"Alias"*/,STR0012 	,/*Picture*/,12			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total da Alternativa do Item" 
      
Return(oReport)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯突北
北篜rograma  砇eportPrint篈utor 矹oeudo Santana Ferreira � Data � 22/05/07   罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯凸北
北篋esc.     砆uery de impressao do relatorio                                罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北篣so       � SIGAAPD                                                       罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯图北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/      
 
Static Function ReportPrint(oReport) 
Local oAvaliaSection	:= oReport:Section(1) 
Local oCompetSection	:= oReport:Section(1):Section(1)      
Local oIteCompSection	:= oReport:Section(1):Section(1):Section(1)    
Local oQuestSection		:= oReport:Section(1):Section(1):Section(1):Section(1)    
Local oAlterSection		:= oReport:Section(1):Section(1):Section(1):Section(2)  
Local cCodCom			:= ""
Local cCodItem			:= ""
Local cCodQue			:= "" 
Local cAlter			:= ""
Local cAlterDesc		:= ""  
Local cWhere			:= ""      
Local nCont				:= 0
Local nQuant			:= 0   
Local nAltern			:= 0         
Local nQuantAval		:= 0
Local nQuantResp		:= 0	    
Local nPos				:= 0
Local aTotAlter			:= {}
Local cCodAvalAux		:= ""
Local cCodCompAux		:= ""
Local cCodItCompAux		:= ""
Local cCodQuestAux		:= ""

//Inicializa array de alternativas com alternativa 1 e 0 respostas
Aadd(aTotAlter,{1,0})


cWhere:= " RDB_FILIAL = '"+ xFilial("RDB")+"' AND RDB.D_E_L_E_T_ = ''"    
// Filtrar por avaliacao caso o usuario tenha escolhido atraves do mv_par01                      
If (!Empty(mv_par01), cWhere+= " AND RDB_CODAVA ='"+mv_par01+"'",)         
// Filtrar por agenda caso o usuario tenha escolhido atraves dos parametros de data mv_par05 e  mv_par06
If (!Empty(mv_par05) .and. !Empty(mv_par06), cWhere+= " AND RDB_DTIAVA ='"+dtos(mv_par05)+"' AND RDB_DTFAVA = '" + dtos(mv_par06) +"'",) 
cWhere:= "%"+cWhere+"%"        
                         
//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("APD60R")
	                    
oAvaliaSection:BeginQuery()
BeginSql Alias 'QRYRDB'  
	SELECT RDB_CODAVA, RDB_CODCOM, RDM_DESC, RDB_ITECOM, RD2_DESC, RDB_CODQUE, QO_QUESTAO, RDB_CODALT, QP_DESCRIC, RBL_DESCRI
	FROM %Table:RDB% RDB				// Itens Respostas de Avalia珲es
	LEFT JOIN %Table:RDM% RDM ON		// Competencias
		RDM_CODIGO = RDB_CODCOM    
		AND RDM_FILIAL = %xfilial:RDM%  
		AND RDM.%NotDel%
	LEFT JOIN %table:RD2% RD2 ON		// Itens de Competencias
		RD2_CODIGO = RDB_CODCOM
		AND RD2_ITEM = RDB_ITECOM
		AND RD2_FILIAL = %xfilial:RD2%  
		AND RD2.%NotDel%
	LEFT JOIN %table:SQO% SQO ON     	// Questoes
		QO_QUESTAO = RDB_CODQUE
		AND QO_FILIAL = %xfilial:SQO%  
		AND SQO.%NotDel%
	LEFT JOIN %table:SQP% SQP ON		// Alternativas
		QP_QUESTAO = RDB_CODQUE
		AND QP_ALTERNA = RDB_CODALT
		AND QP_FILIAL = %xfilial:SQP%
		AND SQP.%NotDel% 
	LEFT JOIN %table:RBL% RBL ON		// Alternativas
		QO_ESCALA = RBL_ESCALA
		AND RBL_ITEM = RDB_CODALT
		AND RBL_FILIAL = %xfilial:RBL%
		AND RBL.%NotDel% 
	WHERE
		%Exp:cWhere%
	Order By RDB_CODAVA, RDB_CODCOM, RDB_ITECOM, RDB_CODQUE, RDB_CODALT
EndSql

oAvaliaSection:EndQuery({mv_par02,mv_par03,mv_par04})   
If ('QRYRDB')->(!Eof())
	// Imprime o relatorio de avaliacoes, quebrando por avalicao, competencia, item de competencia e questoes
	('QRYRDB')->(DbGoTop())
	While   !oReport:Cancel() .And. ('QRYRDB')->(!Eof())	
	   nQuantAval := 0
	   nQuantResp := 0
	   
	   Totais(@nQuantAval,@nQuantResp,('QRYRDB')->RDB_CODAVA)
	   
	   	// - Vari醰eis auxiliares
	   	// - S鉶 utilizadas para adequar o relat髍io a exibir mais de uma sess鉶 de avalia玢o.
	   	// - Uso: Valida珲es das condi珲es dos WHILE's.
		cCodAvalAux		:= ('QRYRDB')->RDB_CODAVA
		cCodCompAux		:= ('QRYRDB')->RDB_CODCOM
		cCodItCompAux	:= ('QRYRDB')->RDB_ITECOM
		cCodQuestAux	:= ('QRYRDB')->RDB_CODQUE
	   
		// Imprime  Avaliacao
		oAvaliaSection:init()
		oAvaliaSection:Cell("RDB_CODAVA"):SetValue(('QRYRDB')->RDB_CODAVA) 
	 	oAvaliaSection:Cell("QTDAVALIA"):SetValue(nQuantAval)
		oAvaliaSection:Cell("QTDRESPON"):SetValue(nQuantResp)
		oAvaliaSection:PrintLine()  

		// Imprime  Competencia	
		If cCodCom != ('QRYRDB')->RDB_CODCOM 
			oCompetSection:init()                            
			oCompetSection:Cell("RDB_CODCOM"):SetValue(('QRYRDB')->RDB_CODCOM)	
			oCompetSection:Cell("RDM_DESC"):SetValue(('QRYRDB')->RDM_DESC)	
			oCompetSection:PrintLine()    
			cCodCom := ('QRYRDB')->RDB_CODCOM		
			cCodCompAux		:= ('QRYRDB')->RDB_CODCOM	
		EndIf 	
		
		Do While  !oReport:Cancel() .And. ('QRYRDB')->(!Eof()) .And. cCodAvalAux == ('QRYRDB')->RDB_CODAVA ;
				  .And. cCodCompAux ==  ('QRYRDB')->RDB_CODCOM  
	   		// Imprime Item de Competencia		
	   		If cCodItem != ('QRYRDB')->RDB_ITECOM
				oIteCompSection:init()	                      			
				oIteCompSection:Cell("RDB_ITECOM"):SetValue(('QRYRDB')->RDB_ITECOM)	
				oIteCompSection:Cell("RD2_DESC"):SetValue(('QRYRDB')->RD2_DESC)	
				oIteCompSection:PrintLine()    
				cCodItem := ('QRYRDB')->RDB_ITECOM		
				cCodItCompAux	:= ('QRYRDB')->RDB_ITECOM	
			EndIf 	                 
			
			Do While  !oReport:Cancel() .And. ('QRYRDB')->(!Eof()) .And. cCodAvalAux == ('QRYRDB')->RDB_CODAVA ;
					  .And. cCodCompAux ==  ('QRYRDB')->RDB_CODCOM  ;
					  .And. cCodItCompAux ==  ('QRYRDB')->RDB_ITECOM	  	                              
	     	  
	     	  	// Imprime  Questao   	
	       		If cCodQue != ('QRYRDB')->RDB_CODQUE 
		        	oQuestSection:init()  
					oQuestSection:Cell("RDB_CODQUE"):SetValue(('QRYRDB')->RDB_CODQUE)	
				 	SQO->(DbSetOrder(1))
				 	SQO->(DbSeek(xFilial("SQO")+('QRYRDB')->QO_QUESTAO))
				 	oQuestSection:Cell("QO_QUEST"):SetValue(SQO->QO_QUEST)  
				 	
				 	oQuestSection:Cell("QP_DESCRIC"):SetValue("")       
				 	oQuestSection:Cell("QUANT"):SetValue("")  
				 	oQuestSection:Cell("PERCENT"):SetValue("")
				 	
					oQuestSection:PrintLine()      
					cCodQue := ('QRYRDB')->RDB_CODQUE	
					cCodQuestAux	:= ('QRYRDB')->RDB_CODQUE	
				EndIf   
				
				cAlter:= ('QRYRDB')->RDB_CODALT 
				cAlterDesc:= If(!Empty( ('QRYRDB')->QP_DESCRIC ), ('QRYRDB')->QP_DESCRIC , ('QRYRDB')->RBL_DESCRI )
				
				nQuant:=0
				nAltern:=0
				Do While  !oReport:Cancel() .And. ('QRYRDB')->(!Eof()) .And. cCodAvalAux == ('QRYRDB')->RDB_CODAVA ;
						  .And. cCodCompAux ==  ('QRYRDB')->RDB_CODCOM  ;
					      .And. cCodItCompAux ==  ('QRYRDB')->RDB_ITECOM .And. ;
				          cCodQuestAux ==  ('QRYRDB')->RDB_CODQUE 	  	                              
					  
					//Soma os registros ate mudar a alternativa	                                     	                                        
					If ('QRYRDB')->RDB_CODALT == cAlter      
						nQuant++
			  			('QRYRDB')->(dbSkip())
					Else   //Mudou a alternativa, imprime
					// Imprime  Alternativa	 
						oQuestSection:Cell("RDB_CODQUE"):SetValue("")
						oQuestSection:Cell("QO_QUEST"):SetValue("")	
						
				 		oQuestSection:Cell("QP_DESCRIC"):SetValue(cAlterDesc)       
				 		oQuestSection:Cell("QUANT"):SetValue(nQuant)  
				 		oQuestSection:Cell("PERCENT"):SetValue(transform((nQuant/nQuantResp)*100,'@R 999.99')+"%")
				 		oQuestSection:PrintLine() 
				 	     
				 		//Obtem proxima alternativa
				 		cAlter 		:= 	('QRYRDB')->RDB_CODALT 	
				 		cAlterDesc	:= 	If(!Empty( ('QRYRDB')->QP_DESCRIC ), ('QRYRDB')->QP_DESCRIC , ('QRYRDB')->RBL_DESCRI )
				 	
			 		 	// Incrementa numero da alternativa	 
				 		nAltern++ 
				 		// Se a alternativa nao e encontrada ela e adicionada ao array, caso contrario ela e incrementada
						If (nPos:= aScan(aTotAlter,{| x |,x[1]==nAltern})) == 0                                      
			  				Aadd(aTotAlter,{nAltern,nQuant})
			  			Else
			  				aTotAlter[nPos][2]+= nQuant	 
						EndIf 	     
						nQuant:=0
				   EndIf  
		    	EndDo
		    	     
		    	oReport:IncMeter()     
		    	
		    	// Incrementa numero da alternativa	 
		    	nAltern++ 
		    	// Se a alternativa nao e encontrada ela e adicionada ao array, caso contrario ela e incrementada
				If (nPos:= aScan(aTotAlter,{| x |,x[1]==nAltern})) == 0                                      
			  		Aadd(aTotAlter,{nAltern,nQuant})
			  	Else
			  		aTotAlter[nPos][2]+= nQuant	 
				EndIf 	 
				// Imprime ultima alternativa	         
		    	oQuestSection:Cell("RDB_CODQUE"):SetValue("")
				oQuestSection:Cell("QO_QUEST"):SetValue("")	
				oQuestSection:Cell("QP_DESCRIC"):SetValue(cAlterDesc)       
				oQuestSection:Cell("QUANT"):SetValue(nQuant) 
				oQuestSection:Cell("PERCENT"):SetValue(transform((nQuant/nQuantResp)*100,'@R 999.99')+"%")
				oQuestSection:PrintLine() 
	
	 	  		oQuestSection:finish() 
	 	 	 	oAlterSection:finish() 
	 	 	 	cCodQue :=	""
	    	EndDo     
	    	cCodItem := ""
	    	Asort(aTotAlter,,,{ |x,y| x[1]  < y[1] } )  
	    	oAlterSection:init()  
	    	// Imprime Totais de Alternativas 	
	  	   	For nCont:=	1 to len(aTotAlter)      
	  	    	
	  	    	oAlterSection:Cell("ALTERNAT"):SetValue(aTotAlter[nCont][1])	
				oAlterSection:Cell("TOTALALT"):SetValue(aTotAlter[nCont][2])       
				oAlterSection:PrintLine() 
				
			Next nCont 
			aTotAlter:={}    
			//Inicializa array de alternativas com alternativa 1 e 0 respostas
			Aadd(aTotAlter,{1,0})		
			oAlterSection:finish() 
	 		oIteCompSection:finish()   	
	    EndDo   
	    oCompetSection:finish() 
	    oAvaliaSection:finish() 
	    cCodCom := ""
	EndDo
EndIf	                 
('QRYRDB')->(DbCloseArea())
                          	
Return( NIL )   

Static Function Totais(nQuantAval,nQuantResp,cCodAva)
Local aArea		:= GetArea()
Local cAliasTmp	:= GetNextAlias()

	// Posiciona na tabela RDC(Itens Envio/Retorno Avaliacoes) para obter o numero de participantes que deveriam responder as questoes da avaliacao
	RDC->(DbSetOrder(7))		     
	RDC->(DbSeek(xFilial("RDC")+cCodAva+Alltrim(dtos(mv_par05))))
	While RDC->(!EOF()) .and. RDC->RDC_CODAVA == cCodAva         
		// Caso um dos parametros de data estiverem vazios n鉶 considera a agenda, incrementa para todos os registros
		If (Empty(mv_par05) .or. Empty(mv_par06)) .or. RDC->RDC_DTIAVA == mv_par05
			nQuantAval++   
		EndIf	
		RDC->(dbSkip())	
	EndDo    
	RDC->(DbCloseArea())
		
	//Obtem numero de participantes que responderam a avaliacao      
	BeginSql Alias cAliasTmp
		SELECT   RDB.RDB_CODADO FROM %table:RDB% RDB
		 WHERE RDB.RDB_CODAVA=%Exp:cCodAva%
		 AND RDB.%NotDel% 
		 AND RDB.RDB_FILIAL= %xfilial:RBD%
		 GROUP BY RDB.RDB_CODADO
	EndSql
	
	While  (cAliasTmp)->(!Eof()) 
		nQuantResp++ 
		(cAliasTmp)->(dbSkip())  
	EndDo
(cAliasTmp)->(dbCloseArea())  
RestArea(aArea)
Return 