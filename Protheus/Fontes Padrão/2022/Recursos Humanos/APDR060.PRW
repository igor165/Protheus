#Include "PROTHEUS.CH"
#Include "apdr060.ch" 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ APDR060 ³ Autor ³Joeudo Santana Ferreira ³ Data ³22/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatório de Resultado de Avaliação                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAAPD                                                    ³±±
±±³Program.r ³ Data   ³ FNC  ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.³04/07/14³TPZWHD³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³          ³        ³      ³a limpeza.                                  ³±±
±±³Matheus M.³19/09/16³TVYADL³Ajuste para permitir impressão com várias   ³±±
±±³          ³        ³      sessões.                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/   

Function APDR060()
Local oReport
Private cPerg := "APD60R"
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= ReportDef()
oReport:PrintDialog()
Return  
                                      
                                                                 
/*     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Joeudo Santana Ferreira³Data  ³22/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Resultado de Avaliação		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                         
Static Function ReportDef()
Local oReport        
Local oAvaliaSection
Local oCompetSection    
Local oIteCompSection 
Local oQuestSection 
Local oAlterSection 
Local cTitle := OemToAnsi(STR0001) //"Relatório de Resultado de Avaliação"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01  -		Avaliacao  ?                                           ³
//³ mv_par02  -		Competencia ?                                          ³
//³ mv_par03  -		Item Competencia ?                                     ³
//³ mv_par04  -		Questoes  ?                                            ³
//³ mv_par05  -		Inicio da Avaliacao ?                                  ³
//³ mv_par06  -		Final da Avaliacao ?                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("APDR060",cTitle,"APD60R",{|oReport| ReportPrint(oReport)},STR0001)  //"Relatório de Resultado de Avaliação"
oReport:SetLandscape() 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ AVALIACAO							  						³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
oAvaliaSection:= TRSection():New(oReport,STR0002,{"RDB"},/*aOrdem*/)  //'Avaliacao'
TRCell():New(oAvaliaSection,"RDB_CODAVA","RDB"		,/*"Titulo"*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oAvaliaSection,"QTDAVALIA",/*"Alias"*/	,STR0003		,/*Picture*/,10			,/*lPixel*/,/*{|| code-block de impressao }*/)   //Quant. Avaliados
TRCell():New(oAvaliaSection,"QTDRESPON",/*"Alias"*/	,STR0004		,/*Picture*/,10			,/*lPixel*/,/*{|| code-block de impressao }*/)   //Quant. Respondidos
   
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ COMPETENCIA						  						³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
oCompetSection:= TRSection():New(oAvaliaSection,STR0005,{"RDB","RDM"},/*aOrdem*/)  //'Estrurura de competencias'
                                                                                                                                                                        
TRCell():New(oCompetSection,"RDB_CODCOM","RDB"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oCompetSection,"RDM_DESC"	,"RDM"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
    
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ ITENS DE COMPETENCIA				  						³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
oIteCompSection:= TRSection():New(oCompetSection,STR0006,{"RDB","RD2"},/*aOrdem*/)  //'Itens de Estrutura'
oIteCompSection:SetLeftMargin(2)	//Identacao da Secao                     
TRCell():New(oIteCompSection,"RDB_ITECOM","RDB"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oIteCompSection,"RD2_DESC","RD2"	,/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ QUESTOES							  						³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
oQuestSection:= TRSection():New(oIteCompSection,STR0007,{"RDB","SQO"},/*aOrdem*/)  //'Questoes'
oQuestSection:SetLeftMargin(6)	//Identacao da Secao  
TRCell():New(oQuestSection,"RDB_CODQUE"	,	"RDB",/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oQuestSection,"QO_QUEST"	,	"SQO",/*"Titulo"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

TRCell():New(oQuestSection,"QP_DESCRIC"	,	"SQP"	,STR0008		,/*Picture*/,30			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Alternativa"
TRCell():New(oQuestSection,"QUANT"		,/*"Alias"*/,STR0009		,/*Picture*/,12			,/*lPixel*/,/*{|| code-block de impressao }*/) //Quantidade 
TRCell():New(oQuestSection,"PERCENT"	,/*"Alias"*/,STR0010 		,/*Picture*/,16			,/*lPixel*/,/*{|| code-block de impressao }*/) //Porcentagem

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ TOTALIZADORES DE ALTERNATIVAS								³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
oAlterSection:= TRSection():New(oIteCompSection,STR0011,{""},/*aOrdem*/)  //'Totais de Alterativas'
oAlterSection:SetLeftMargin(6)	//Identacao da Secao  
TRCell():New(oAlterSection,"ALTERNAT"		,/*"Alias"*/,STR0008	,/*Picture*/,5			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Alternativa" 
TRCell():New(oAlterSection,"TOTALALT" 		,/*"Alias"*/,STR0012 	,/*Picture*/,12			,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total da Alternativa do Item" 
      
Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor ³Joeudo Santana Ferreira º Data ³ 22/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query de impressao do relatorio                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAAPD                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	FROM %Table:RDB% RDB				// Itens Respostas de Avaliações
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
	   
	   	// - Variáveis auxiliares
	   	// - São utilizadas para adequar o relatório a exibir mais de uma sessão de avaliação.
	   	// - Uso: Validações das condições dos WHILE's.
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
		// Caso um dos parametros de data estiverem vazios não considera a agenda, incrementa para todos os registros
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