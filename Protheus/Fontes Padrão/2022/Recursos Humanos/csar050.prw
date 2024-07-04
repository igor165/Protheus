#INCLUDE "Protheus.ch"
#INCLUDE "CSAR050.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CSAR050  ³ Autor ³ Eduardo Ju            ³ Data ³  09/08/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Aumento Programado dos funcionarios             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAR050(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³30/07/2014³TPZVV4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³          ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

Function CSAR050()

Local oReport
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
Pergunte("CSR50R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 09.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Componente de Impressao do Relatorio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oSection1	
Local oSection2
Local aOrdem    := {}  
Local cAliasQry := GetNextAlias() 
Local cAliAsRB7 := cAliasQry
Local cAliasSRA := cAliasQry  
Local cAliasSRJ := cAliasQry
Local cAliasCTT := cAliasQry
Local cAliasSQ3 := cAliasQry 
Local cAliasSX5 := cAliasQry    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("CSAR050",STR0009,"CSR50R",{|oReport| PrintReport(oReport,cAliasQry)},STR0002+" "+STR0003)	// "Aumentos Salariais Programado"#"Será impresso de acordo com os parametros solicitados pelo usuario"
Pergunte("CSR50R",.F.)

Aadd( aOrdem, STR0004)	// "Matricula"
Aadd( aOrdem, STR0005)	// "Funcao"                 
Aadd( aOrdem, STR0006)	// "Centro de Custo"         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: "Pontuacao do Funcionario" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1 := TRSection():New(oReport,STR0020,{cAliasSRA,cAliasSRJ,cAliasCTT},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//Funcionario	
oSection1:SetTotalInLine(.T.)  
oSection1:SetHeaderBreak(.T.)   

TRCell():New(oSection1,"RA_FILIAL",cAliasSRA)					//Filial do Funcionario
TRCell():New(oSection1,"RA_MAT",cAliasSRA)						//Matricula do Funcionario
TRCell():New(oSection1,"RA_NOME",cAliasSRA,"")					//Nome do Funcionario
TRCell():New(oSection1,"RA_SALARIO",cAliasSRA)					//Salario do Funcionario
TRCell():New(oSection1,"RA_CATFUNC",cAliasSRA,STR0021)	   		//Categoria Funcional do Funcionario
TRCell():New(oSection1,"RA_CODFUNC",cAliasSRA,STR0022)			//Funcao do Funcionario
TRCell():New(oSection1,"RJ_DESC",cAliasSRJ,"")					//Descricao da Funcao do Funcionario   
TRCell():New(oSection1,"RA_CC",cAliasSRA)						//Centro De Custo do Funcionario
TRCell():New(oSection1,"CTT_DESC01",cAliasCTT,"") 		   		//Descricao do CC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Aumento Programado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0009,{cAliasRB7,cAliasSX5},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Aumento Programado
oSection2:SetTotalInLine(.T.)  
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(3)	//Identacao da Secao
       
TRCell():New(oSection2,"RB7_DATALT","RB7",STR0023)				//Data da Alteracao Salarial
TRCell():New(oSection2,"RB7_TPALT","RB7",STR0024)				//Tipo da Alteracao Salarial 
TRCell():New(oSection2,fDescSX5(2),"SX5","",,20)				//Descricao do Tipo da Alteracao Salarial 
TRCell():New(oSection2,"RB7_PERCEN","RB7")						//Aumento em %
TRCell():New(oSection2,"RB7_SALARI","RB7")						//Salario 
TRCell():New(oSection2,"RB7_CATEG","RB7",STR0021)				//Categoria Funcional   
TRCell():New(oSection2,"RB7_FUNCAO","RB7",STR0022)				//Codigo da Funcao
TRCell():New(oSection2,"RJ_DESC","SRJ","")						//Descricao da Funcao 
TRCell():New(oSection2,"RB7_CARGO","RB7",STR0025)				//Codigo do Cargo
TRCell():New(oSection2,"Q3_DESCSUM","SQ3","")					//Descricao do Cargo
TRCell():New(oSection2,"RB7_ATUALI","RB7")						//Atualizado (Sim ou Nao)
         
oSection2:Cell("RJ_DESC"):SetBlock( {|| DescFun( (cAliasQry)->RB7_FUNCAO,(cAliasQry)->RA_FILIAL) } )

Return oReport 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 09.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local nOrdem  	:= osection1:GetOrder()      
Local cCampo  := "%" + fDescSX5(2) + "%"   
Local lQuery    := .F. 
Local cOrder	:= "" 
Local cSitQuery	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                          ³
//³ mv_par01        //  Filial?                                                   ³
//³ mv_par02        //  Centro de Custo ?                                         ³
//³ mv_par03        //  Funcao?                                                   ³
//³ mv_par04        //  Dt.Admissao?                                              ³
//³ mv_par05        //  Periodo?                                                  ³
//³ mv_par06        //  Listar? 1-Ja atualizados; 2-Não atualizados; 3-Ambos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transforma parametros Range em expressao SQL ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr("CSR50R")    
	
	//-- Filtragem do relatório
	//-- Query do relatório da secao 1
	lQuery := .T.         

	If nOrdem == 1  
		cOrder := "%RA_FILIAL,RA_MAT%" 
	ElseIf nOrdem == 2		
		cOrder := "%RA_FILIAL,RA_CODFUNC%" 	       
	ElseIf nOrdem == 3
		cOrder := "%RA_FILIAL,RA_CC,RA_MAT%"
	EndIf		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do Funcionario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cSitQuery += "%' ','A','F'%" 
		                                           
	oReport:Section(1):BeginQuery()	

	BeginSql Alias cAliasQry	
		SELECT	RA_FILIAL,RA_MAT,RA_NOME,RA_SALARIO,RA_CATFUNC,RA_CODFUNC,RJ_DESC,
				RA_CC,RA_CARGO,CTT_DESC01,RB7_DATALT,RB7_FILIAL,RB7_MAT,RB7_TPALT,%exp:cCampo%,RB7_PERCEN,RB7_SALARI,
				RB7_CATEG,RB7_FUNCAO,RJ_DESC,RB7_ATUALI,RB7_CARGO,Q3_DESCSUM
		FROM 	%table:SRA% SRA
		LEFT JOIN %table:SRJ% SRJ
			ON RJ_FILIAL = %xFilial:SQ3%
			AND RJ_FUNCAO = RA_CODFUNC
			AND SRJ.%NotDel%			
		LEFT JOIN %table:CTT% CTT
			ON CTT_FILIAL = %xFilial:CTT%
			AND CTT_CUSTO = RA_CC
			AND CTT.%NotDel%
		LEFT JOIN %table:RB7% RB7
			ON RB7_FILIAL = RA_FILIAL
			AND RB7_MAT = RA_MAT
			AND RB7.%NotDel% 
		LEFT JOIN %table:SQ3% SQ3
			ON Q3_FILIAL = %xFilial:SQ3%
			AND Q3_CARGO = RB7_CARGO
			AND Q3_CC = RA_CC
			AND SQ3.%NotDel% 			
		LEFT JOIN %table:SX5% SX5
			ON X5_FILIAL = %xFilial:SX5%
			AND X5_TABELA = '41'
			AND X5_CHAVE = RB7_TPALT
			AND SX5.%NotDel%		
			
		WHERE SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND  
			SRA.%NotDel%   													
		ORDER BY %Exp:cOrder%                 				
	EndSql
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery({mv_par01,mv_par02,mv_par03,mv_par04,mv_par05})	/*Array com os parametros do tipo Range*/
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da impressao do fluxo do relatório ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(SRA->(LastRec()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza a query do Pai  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2:SetParentQuery()                              
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listar: 1-Ja atualizados; 2-Não atualizados; 3-Ambos  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 == 1	
   		oSection2:SetLineCondition({|| (cAliasQry)->RB7_ATUALI == "S" }) 
   	ElseIf mv_par06 == 2	
   		oSection2:SetLineCondition({|| (cAliasQry)->RB7_ATUALI == "N" }) 	
   	EndIf			
	 	
	oSection2:SetParentFilter({|cParam| (cAliasQry)->RB7_FILIAL+(cAliasQry)->RB7_MAT == cParam},{|| (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
	
	oSection1:Print()	 //Imprimir
Return Nil