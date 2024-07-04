#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"
#INCLUDE "ECF.CH"

//Compatibiliza็ใo de fontes 30/05/2018

Static __lDefTop	:= IfDefTopCTB()
Static __nLayout	:= 8
Static aLoadRes   	:= Array(ECF_NUMCOLS) //Tamanho do array definido no ECF.CH para salvar as perguntas informadas no wizard 


Function CTBS101(cEmp , cModEsc, bIncTree)
Local aArea    		:= GetArea()
Local aHeader		:= {}
Local aFils			:= {}	
Local lFWCodFil		:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local lFim    		:= .F.
Local oFil 			:= Nil		//Objeto Filiais
Local oWzrdEcf		:= Nil		//Objeto Wizard
Local oOk			:= Nil		//Botใo OK				
Local oNo			:= Nil		//Botใo No
Local cMatriz		:= Space(CtbTamFil("033",2))	//Filial Centralizadora

Private aPerWiz2	:= {}		//Parametros Wizard 2 
Private aPerWiz3	:= {}		//Parametros Wizard 3 
Private aPerWiz4	:= {}		//Parametros Wizard 4
Private aPerWiz5	:= {}		//Parametros Wizard 5
Private aPerWiz6	:= {}		//Parametros Wizard 6
Private aPerWiz7	:= {}		//Parametros Wizard 7
Private aPerWiz8	:= {}		//Parametros Wizard 8
Private aPerWiz9	:= {}		//Parametros Wizard 9
Private aPerWiz10	:= {}		//Parametros Wizard 10
Private aResWiz2	:= {}		//Respostas Wizard 2 
Private aResWiz3	:= {}		//Respostas Wizard 3
Private aResWiz4	:= {}		//Respostas Wizard 4
Private aResWiz5	:= {}		//Respostas Wizard 5
Private aResWiz6	:= {}		//Respostas Wizard 6
Private aResWiz7	:= {}		//Respostas Wizard 7
Private aResWiz8	:= {}		//Respostas Wizard 8
Private aResWiz9	:= {}		//Respostas Wizard 9
Private aResWiz10	:= {}		//Respostas Wizard 10
Private aRespFils := {}

//Variaveis de Controle
Private lVis		:= .T.
Private lEcfPais 	:= .T.

Default cEmp		:= ""	//C๓digo da Emp
Default bIncTree := {||.T.}

//---------------------------------------------
//Limpa o array de respostas
//---------------------------------------------
aLoadRes   := Array(ECF_NUMCOLS)

//---------------------------------------------
//Continua somente se for ECF
//---------------------------------------------
If !(cModEsc == "ECF")
	Return
Else
	If !ECFLayout()
		Return
	EndIf
EndIf

//---------------------------------------------
//Verifica ambiente
//---------------------------------------------
If !__lDefTop
	Alert('Rotina disponํvel somemente para ambiente TOPCONNECT')
	Return
EndIf


//---------------------------------------------
//Carrega todas as filiais existentes
//---------------------------------------------
aHeader	:= ARRAY(5)
aHeader[1]	:= ""  		
aHeader[2]	:= IIF(lGestao,"Filial","Empresa/Unidade/Filial")
aHeader[3]	:= "Razใo Social"
aHeader[4]	:= "CNPJ"
aHeader[5]	:= ""
aFils		:= GetEmpEcd( cEmp )

//---------------------------------------------
//Carrega imagens dos botoes
//---------------------------------------------
oOk 		:= LoadBitmap( GetResources(), "LBOK")
oNo			:= LoadBitmap( GetResources(), "LBNO")

//---------------------------------------------
//ณ Montagem da Wizard                      
//---------------------------------------------
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Wizard1
DEFINE WIZARD oWzrdEcf ;
	TITLE "Passo 01 - Assistente de Importa็ใo de Dados de Escritura็ใo Contแbil - Empresa: " + cEmp;
	HEADER "Aten็ใo";
	MESSAGE "" ;
	TEXT "Essa rotina tem como objetivo ajudแ-lo na Escritura็ใo Contแbil Fiscal - ECF" + CRLF + "Siga atentamente os passos, pois iremos efetuar a exporta็ใo dos seus dados contแbeis." ;
	NEXT 	{||.T.} ;
	FINISH {||.T.}
	
// Wizard2
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 02 - Escolha qual o tipo de escritura็ใo que irแ efetuar.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz2,aResWiz2) } ;
	PANEL   
	
	//Define os Paremtros
	ParamECF( "02", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz2,"", @aResWiz2,,,,,,oWzrdEcf:GetPanel(2))  

// Wizard3
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 03 - Quais sใo as filiais que essa empresa centralizadora?";
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaEmpEcd(aFils,,aResWiz2,cMatriz)} ;
	PANEL

	oFil := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader, Nil, oWzrdEcf:GetPanel(3), Nil, Nil, Nil,Nil,;
					      {|| aFils := EmpTrocEcd( oFil:nAt, aFils, .T., cModEsc ), oFil:Refresh() })      

	oFil:SetArray( aFils )

	oFil:bHeaderClick := { |o , nCol | CtbsInvtFl( o , nCol , aFils , .T. , cModEsc ) }

	oFil:bLine := {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4],;
						aFils[oFil:nAt,5];
					}}
   
	//-----------------------------------------------
	// Campo utilizado para preenchimento da matriz	
	// caso a escritura็ใo seja com centraliza็ใo	
	//-----------------------------------------------						
	@ 110,005 SAY "Matriz"  SIZE 070,010 PIXEL OF oWzrdEcf:GetPanel(3)
	@ 110,025 MSGET cMatriz SIZE 015,005 PIXEL OF oWzrdEcf:GetPanel(3) F3 "SM0_01" 
	
// Wizard4
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 04 - Informe os dados da empresa escolhida para escritura็ใo.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValdPas04(aPerWiz4,aResWiz4)} ;
	PANEL   
	
	//Define os Paremtros
	ParamECF( "04", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz4,"", @aResWiz4,,,,,,oWzrdEcf:GetPanel(4))

// Wizard5
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 05 - Informe os Parโmetros de Tributa็ใo.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValdPas05(aPerWiz5,aResWiz5,aResWiz4)} ;
	PANEL   
	
	//Define os Paremtros
	ParamECF( "05", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz5,"", @aResWiz5,,,,,,oWzrdEcf:GetPanel(5))
	
// Wizard6
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 06 - Informe os Parโmetros de Tributa็ใo.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValdPas06(aPerWiz6,aResWiz6)} ; 
	PANEL   
	
	//Define os Paremtros
	ParamECF( "06", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz6,"", @aResWiz6,,,,,,oWzrdEcf:GetPanel(6))	

// Wizard7
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 07 - Informe os Parโmetros de Filtro.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz7,aResWiz7)} ; 
	PANEL   
	
	//Define os Paremtros
	ParamECF( "07", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz7,"", @aResWiz7,,,,,,oWzrdEcf:GetPanel(7))
	
// Wizard8
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 08 - Informe os Parโmetros de Filtro.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz8,aResWiz8)} ; 
	PANEL   
	
	//Define os Paremtros
	ParamECF( "08", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz8,"", @aResWiz8,,,,,,oWzrdEcf:GetPanel(8))		
	
// Wizard9
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 09 - Informa็๕es Economicas/Gerais.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz9,aResWiz9) .And. ECFY671(aResWiz9) } ; 
	PANEL   
	
	//Define os Paremtros
	ParamECF( "09", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz9,"", @aResWiz9,,,,,,oWzrdEcf:GetPanel(9))		

// Wizard10
CREATE PANEL oWzrdEcf  ;
	HEADER "Etapa de Configura็ใo Finalizada!";
	MESSAGE ""	;
	BACK {|| .T.} ;
	FINISH {|| ECFProcessa( cEmp,aFils,cMatriz,cModEsc,bIncTree,aResWiz2,aResWiz4,aResWiz5,aResWiz6,aResWiz7,aResWiz8,aResWiz9)  };
	PANEL

	@ 050,010 SAY "Clique no botใo finalizar para fechar o wizard e iniciarmos a exporta็ใo dos dados para ECF." SIZE 270,020 FONT oBold PIXEL OF oWzrdEcf:GetPanel(10)


/*
CREATE PANEL oWzrdEcf  ;
	HEADER "Passo 07 - Valida Conexใo";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| .T.} ;
	FINISH {|| TestaConexao()} ;
	PANEL   
	
	//Define os Paremtros
	ParamECF( "07", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz7,"", @aResWiz7,,,,,,oWzrdEcf:GetPanel(7))
*/	 	 	 	  	                                                                                 
		
ACTIVATE WIZARD oWzrdEcf CENTERED

RestArea( aArea )

Return lFim

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณParamSped    บAutor  ณMicrosiga		 	บ Data ณ28/01/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณDefine as perguntas e respostas especificas do Sped         บฑฑ
ฑฑบ          ณ														      บฑฑ
ฑฑบ          ณExemplo:												      บฑฑ
ฑฑบ          ณaRet[1]-> retorna as perguntas						      บฑฑ
ฑฑบ          ณaRet[2]-> retorna as respostas 						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function ParamECF( cPasso, cModEsc )
Local aArea    		:= GetArea()
Local nCont 		:= 0

Local aCentraliza	:= {"Com Centraliza็ใo (Escritura็ใo Centralizada)", "Sem Centraliza็ใo (Escritura็ใo Descentralizada)"}
Local aEscrit		:= {"ECD","FCONT","ECF"}
Local aLayout		:= ECF_Leiaute()
//Wizard4
Local aIndIniPer	:= {"0 - Regular","1 - Abertura","2 - Resultante Cisao/Fusao ou remanescente...","3 - Resultante de Mudan็a de Qualifica็ใo da Pessoa Jurํdica","4 - Inํcio de obrigatoriedade da entrega no curso do ano calendแrio"}
Local aSitEspeci 	:= {"0 - Normal","1 - Extin็ใo","2 - Fusใo","3 - Incorporada","4 - Incorporadora","5 - Cisใo Total","6 - Cisใo Parcial","7 - Mudan็a de Qualifica็ใo da Pessoa Jurํdica","8 - Desenquadramento Imune/Isenta","9 - Inclusใo Simples Nacional" }
Local aTipECF		:= {"0 - ECF de empresa nใo participante como s๓cio Ostensivo","1 - ECF de empresa participante como s๓cio Ostensivo","2 - ECF da SCP"}
Local aRetif		:= {"S - ECF Retificadora","N - ECF Original","F - ECF Original com mudan็a de forma de tributa็ใo"}
Local aMetod		:= {"1 - Custo M้dio Ponderado", "2 - PEPS", "3 - Arbitramento", "4 – Custo Especํfico", "5 – Valor Realizแvel Lํquido", "6 - Inventแrio Peri๓dico","7 - Outros","8 - Nใo hแ"}

//Wizard5
Local aOpta		:= {"S - Sim", "N - Nใo"}
Local aForTrib	:= {"1 - Lucro Real","2 - Lucro Real/Arbitrado","3 - Lucro Presumido/Real","4 - Lucro Presumido/Real/Arbitrado","5 - Lucro Presumido","6 - Lucro Arbitrado","7 - Lucro Presumido/Arbitrado","8 - Imune de IRPJ","9 - Isento de IRPJ"}
Local aForApur	:= {"T - Trimestral","A - Anual"}
Local aQualifPJ	:= {"01 - PJ em Geral","02 - PJ Componente do Sistema Financeiro","03 - Sociedades Seguradoras, de Capitaliza็ใo ou Entidade Aberta de Previd๊ncia Complementar"}
//Local aForTribP	:= {"0 - Nใo Informado","R - Real","P - Presumido","A - Arbitrado","E - Real Estimativa"}
//Local aMesBal	:= {"0 - Fora do Perํodo","E - Receita Bruta","B - Balan็o/Balancete"}
Local aTipEscr	:= {"L - Livro Caixa" , "C - Contแbil"}
Local aTipoEnt	:= {"01 - Assistencia Social","02 - Educacional","03 - Sindicato de Trabalhadores","04 - Associa็ใo Civil","05 - Cultural","06 - Entidade Fechada de Pr๊videncia Complementar","07 - Filantr๓pica","08 - Sindicato","09 - Recreativa","10 - Cientํfica","11 - Associa็ใo de Poupanใ e Empr้stimo","12 - Entidade Aberta de Prov๊ncia Complementar}", "13 - FIFA e Entidades Relacionadas", "14 - CIO e Entidades Relacionadas","15 – Partidos Polํticos","99 - Outras"}  
Local aApurCSLL	:= {"A - Anual", "T - Trimestral", "D - Desobrigada"}
Local aTpCaixa	:= {"1 - Regime de Caixa" , "2 - Regime de Competencia"}

//Wizard6
Local aCsll		:= {"09%", "17%", "20%","15%"}

//Wizard7
Local nTamCalend:= Space(CTG->(TamSx3("CTG_CALEND")[1]))
Local nTamMoeda	:= Space(CTO->(TamSx3("CTO_MOEDA" )[1])) 
Local nTamConta := Space(CT1->(TamSx3("CT1_CONTA")[1]))
Local cCodPla	:= Space(CS0->(TamSx3("CS0_CODPLA")[1]))
Local nVerPla	:= Space(CS0->(TamSx3("CS0_VERPLA")[1]))
                 
//Wizard8
Local nTamVis 	:= Space(CTN->(TamSx3("CTN_CODIGO")[1])) + " "                 


If aLoadRes[1] == nil //Se o array estiver com seu conte๚do nulo
	For nCont := 1 to Len(aLoadRes) //Adiciono as ๚ltimas informa็๕es salvas
		aLoadRes[nCont] := EcdLoad('RESPECF',"",nCont) //A fun็ใo EcdLoad(CTBSFUN.PRW) resgata as informa็๕es salvas no arquivo txt na pasta profile
	Next
EndIf

//---------------------------------------------
//Wizard1 - Tela de Apresenta็ใo
//---------------------------------------------


//---------------------------------------------
//Wizard 02 - Define as op็๕es do Modo de Escritura็ใo
//---------------------------------------------
If cPasso = '02'	
	//Cria Perguntas
	aAdd(aPerWiz2 ,{3,"Centraliza็ใo"					,1,aCentraliza	,140,"",.T.,.T.})
	aAdd(aPerWiz2 ,{3,"Qual o Tipo de Escritura็ใo?"	,3,aEscrit		,90,"",.T.,.F.})
	aAdd(aPerWiz2 ,{3,"Informe o leiaute da ECF?"		,__nLayout,aLayout		,90,"",.T.,.F.}) 
	
	//Seta a resposta padrใo
	aResWiz2	:= Array(Len(aPerWiz2))

	aResWiz2[1]	:= 1
	aResWiz2[2]	:= 3
	aResWiz2[3]	:= __nLayout
EndIf

//---------------------------------------------
//Wizard3 - Define as empresas/filiais
//---------------------------------------------


//---------------------------------------------
//Wizard 04 - 
//---------------------------------------------
If cPasso = '04'
	If __nLayout < 7   //para leiautes anteriores a 7 preserva o que estava nos arrays das versoes anteriores
		aIndIniPer	:= {"0 - Regular","1 - Abertura","2 - Resultante Cisao/Fusao ou remanescente...","3 - Resultante de Transforma็ใo","4 - Inํcio de obrigatoriedade da entrega no curso do ano calendแrio"}
		aSitEspeci 	:= {"0 - Normal","1 - Extin็ใo","2 - Fusใo","3 - Incorporada","4 - Incorporadora","5 - Cisใo Total","6 - Cisใo Parcial","7 - Transforma็ใo - OBSOLETO ","8 - Isenta","9 - Inclusใo Simples Nacional" }
	EndIf
	//Cria Perguntas
	aAdd(aPerWiz4,{3,"Indicador Inicio de Periodo"			,,aIndIniPer		,200,"",.T.	,.T.})
	aAdd(aPerWiz4,{3,"Indicador de Situa็ใo Especial"		,,aSitEspeci		,200,"",.T.	,.T.})	
	aAdd(aPerWiz4,{1,"Patr. Remanescente de Cisใo(%)"		,Space(005)			,""	,"",""	,,60,.T.})
	aAdd(aPerWiz4,{3,"Retificadora"							,,aRetif			,200,"",.T.	,.T.})
	aAdd(aPerWiz4,{1,"N๚mero do Recibo Anterior"			,Space(041)			,""	,"",""	,,60,.F.})
	aAdd(aPerWiz4,{3,"Tipo da ECF"							,,aTipECF			,200,"",.T.	,.T.})
	aAdd(aPerWiz4,{1,"Identifica็ใo da SCP"					,Space(014)			,""	,"",""	,,60,.F.})	
	aAdd(aPerWiz4,{1,"Data Situa็ใo Especial/Evento"		,CTOD("20140101")	,""	,"",""	,,60,.F.})	
	aAdd(aPerWiz4,{3,"M้todo de Avalia็ใo de Estoque Final"	,,aMetod			,200,"",.F.,.T.})
	
	//Seta a resposta padrใo
	aResWiz4	:= Array(Len(aPerWiz4))
	
	aResWiz4[1]	:= iif(!empty(aLoadRes[ECF_IND_SIT_INI_PER]),val(aLoadRes[ECF_IND_SIT_INI_PER]),1)	
    aResWiz4[2]	:= iif(!empty(aLoadRes[ECF_SIT_ESPECIAL])	,val(aLoadRes[ECF_SIT_ESPECIAL])   ,1)
    aResWiz4[3]	:= iif(!empty(aLoadRes[ECF_PAT_REMAN_CIS])	,aLoadRes[ECF_PAT_REMAN_CIS]	   ,'00000')
    aResWiz4[4]	:= iif(!empty(aLoadRes[ECF_RETIFICADORA])	,val(aLoadRes[ECF_RETIFICADORA])   ,2)		
    aResWiz4[5]	:= iif(!empty(aLoadRes[ECF_NUM_REC])		,aLoadRes[ECF_NUM_REC]			   ,Space(41))	
    aResWiz4[6]	:= iif(!empty(aLoadRes[ECF_TIP_ECF])		,val(aLoadRes[ECF_TIP_ECF])		   ,1)	
    aResWiz4[7]	:= iif(!empty(aLoadRes[ECF_COD_SCP])		,aLoadRes[ECF_COD_SCP]			   ,Space(14))	
    aResWiz4[8]	:= iif(!empty(aLoadRes[ECF_DATA_SIT])		,CTOD(aLoadRes[ECF_DATA_SIT])	   ,CTOD(""))
    aResWiz4[9]	:= iif(!empty(aLoadRes[ECF_AVAL_ESTOQUE])	,val(aLoadRes[ECF_AVAL_ESTOQUE])   ,0) 	

EndIf

//---------------------------------------------
//Wizard 05 - 
//---------------------------------------------
If cPasso = '05'
	//Cria Perguntas
	aAdd(aPerWiz5,{3,"Indicador de Optante pelo Refis"				,,aOpta		,100,"",.T.,.T.})
	aAdd(aPerWiz5,{3,"Indicador de Optante pelo Paes"				,,aOpta		,100,"",.T.,Layt7ECF()})	
	aAdd(aPerWiz5,{3,"Forma de Tributa็ใo do Lucro"					,,aForTrib	,100,"",.T.,.T.})
	aAdd(aPerWiz5,{3,"Perํodo de Apura็ใo do IRPJ e CSLL"			,,aForApur	,100,"",.F.,.T.})
	aAdd(aPerWiz5,{3,"Qualifica็ใo da Pessoa Jurํdica"				,,aQualifPJ	,100,"",.F.,.T.})
	aAdd(aPerWiz5,{1,"Forma de Trib. no Perํodo"					,Space(4)	,"","","",,50,.F.})
	aAdd(aPerWiz5,{1,"Forma de Apur. da Estimativa "				,Space(12)	,"","","",,50,.F.})	
	aAdd(aPerWiz5,{3,"Tipo de Escritura็ใo"							,,aTipEscr		,100,"",.F.,.T.})
	aAdd(aPerWiz5,{3,"Tipo de Pessoa Jur. Imune ou Isenta"			,,aTipoEnt	,100,"",.F.,.T.}) 	
	aAdd(aPerWiz5,{3,"Apura็ใo do IRPJ para Imunes ou Isentas"		,,aApurCSLL	,100,"",.F.,.T.})
	aAdd(aPerWiz5,{3,"Apura็ใo da CSLL para Imunes e Isentas"		,,aApurCSLL	,100,"",.F.,.T.})
	aAdd(aPerWiz5,{3,"Optante pela Extin็ใo do RTT em 2014"			,,aOpta		,100,"",.F.,"!LeiEcf3()"})
	aAdd(aPerWiz5,{3,"Dif. entre Contabilidade Societaria e FCONT"	,,aOpta		,100,"",.F.,"!LeiEcf3()"})
	aAdd(aPerWiz5,{3,"Crit้rio de reconhecimento de receitas"	    ,,aTpCaixa		,100,"",.F.,"LeiEcf3()"})
	aAdd(aPerWiz5,{3,"Declara็ใo Paํs a Paํs"	    				,,aOpta		,100,"",.F.,"LeiEcf3()"})
	aAdd(aPerWiz5,{1,"Codigo Identif. Bloco W"				        ,Space(06)	,"","Empty(aResWiz5[16]).or. ExistCpo('CQM',aResWiz5[16])","CQM","LeiEcf3()",50,.F.})

	aAdd(aPerWiz5,{3,"DEREX"	    								,,aOpta		,100,"",.F.,"LeiEcf3()"})


	//------------------------------------------
	//Seta a resposta padrใo
	//------------------------------------------
	// ATENCAO
	// Se atentar as respostas padr๕es, pois 
	//   podem impactar na extra็ใo incorreta
	//   dos dados. Principalmente quando a extra็ใo
	//   ้ para empresas enquadradas como
	//   IMUNES e ISENTAS.
	//------------------------------------------
	aResWiz5	:= Array(Len(aPerWiz5))
	
	aResWiz5[1]	:= iif(!empty(aLoadRes[ECF_OPT_REFIS])		 ,val(aLoadRes[ECF_OPT_REFIS])	  	 ,2)
    aResWiz5[2]	:= iif(!empty(aLoadRes[ECF_OPT_PAES])		 ,iif(!Layt7ECF(),2,val(aLoadRes[ECF_OPT_PAES])),2)
    aResWiz5[3]	:= iif(!empty(aLoadRes[ECF_FORMA_TRIB]) 	 ,val(aLoadRes[ECF_FORMA_TRIB])	  	 ,1)
    aResWiz5[4]	:= 0
    aResWiz5[5]	:= 0
    aResWiz5[6]	:= iif(!empty(aLoadRes[ECF_FORMA_TRIB_PER])  ,Padr(aLoadRes[ECF_FORMA_TRIB_PER],4),Space(4))
    aResWiz5[7]	:= iif(!empty(aLoadRes[ECF_MES_BAL_RED])     ,Padr(aLoadRes[ECF_MES_BAL_RED],12),Space(12))
    aResWiz5[8] := 0 
    aResWiz5[9] := 0 
    aResWiz5[10]:= 0
    aResWiz5[11]:= 0
    aResWiz5[12]:= iif(!empty(aLoadRes[ECF_OPT_EXT_RTT])     ,val(aLoadRes[ECF_OPT_EXT_RTT])   	 ,0) 		
    aResWiz5[13]:= iif(!empty(aLoadRes[ECF_DIF_CONT_SOC_FCO]),val(aLoadRes[ECF_DIF_CONT_SOC_FCO]),0)
    aResWiz5[14]:= 0
    aResWiz5[15]:= iif(!empty(aLoadRes[ECF_DEC_PAIS_PAIS])   ,val(aLoadRes[ECF_DEC_PAIS_PAIS])   ,2)
    aResWiz5[16]:= iif(!empty(aLoadRes[ECF_COD_IDENT_BLO_W]) ,aLoadRes[ECF_COD_IDENT_BLO_W] 	 ,Space(06))
    
	aResWiz5[17]:= iif(!empty(aLoadRes[ECF_DEREX])			 ,val(aLoadRes[ECF_DEREX])			 ,2)
	
EndIf

//---------------------------------------------
//Wizard 06 - Parametro Complementares
//---------------------------------------------
If cPasso = '06'
	aAdd(aPerWiz6,{3,"PJ Sujeita a Aliquota de CSLL"																			,,aCsll,50,"",.F.,.T.})
	aAdd(aPerWiz6,{1,"Quantidade de SCP da PJ"																					,Space(3)	,"","","",,50,.T.})
	aAdd(aPerWiz6,{3,"Administradora de Fundos e Clubes de Investimento"														,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Participa็๕es em Cons๓rcios de Empresas"																	,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Opera็๕es com o Exterior"																					,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Opera็๕es com pessoa Vinculada/Interposta Pessoa/Pais com Tributa็ใo Favorecida"							,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"PJ Enquadrada nos artigos 48 ou 49 da Instru็ใo Normativa RFB nบ 1.312/2012"								,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Participa็๕es no Exterior"																				,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Atividade Rural"																							,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Lucro da Explora็ใo"																						,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Isen็ใo e Redu็ใo do Imposto para Lucro Presumido"														,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"FINOR/FINAM/FUNRES"																						,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Doa็๕es a Campanhas Eleitorais"																			,,aOpta,50,"",.T.,Layt7ECF()})
	aAdd(aPerWiz6,{3,"Participa็ใo Permanente em Coligadas ou Controladas"														,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"PJ Efetuou Vendas a Empresa Comercial Exportadora com Fim Especํfico de Exporta็ใo"						,,aOpta,50,"",.T.,Layt7ECF()})
	aAdd(aPerWiz6,{3,"Recebimentos do Exterior ou de Nใo Residentes"															,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Ativos no Exterior"																						,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"PJ Comercial Exportadora"																					,,aOpta,50,"",.T.,Layt7ECF()})
	aAdd(aPerWiz6,{3,"Pagamentos ao Exterior ou nใo Residentes"																	,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Com้rcio Eletronico e Tecnologia da Informa็ใo"															,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Royalties Recebidos do Brasil e do Exterior"																,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Royalties Pagos a beneficiแrios do Brasil e do Exterior"													,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Rendimentos Relativos a Servi็os, Juros e Dividendos Recebidos do Brasil e do Exterior"					,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Pagamentos ou Remessas a Titulos de Servi็os, Juros e Dividendos a Beneficiarios do Brasil e do Exterior"	,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Inova็ใo Tenol๓gica e Desenvolvimento Tecnol๓gico"														,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Capacita็ใo de Informแtica e Inclusใo Digital"																,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"PJ Habilitada"																							,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"P๓lo INdustrial de Manaus e Amaz๔nia Ocidental"															,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"Zonas de Processamento de Exporta็ใo"																		,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{3,"มreas de Livre Com้rcio"																					,,aOpta,50,"",.T.,.T.})
	aAdd(aPerWiz6,{1,"Codigo Identif. Registro 0021"				       														,Space(06)	,"","Empty(aResWiz6[31]).or. ExistCpo('CQL',aResWiz6[31])","CQL","LeiEcf3()",50,.F.})
	aAdd(aPerWiz6,{1,"Cod.Identif. Bloco V - DEREX"				       														    ,Space(10)	,"","Empty(aResWiz6[32]).or. ExistCpo('CSU',aResWiz6[32])","CSU","aResWiz5[17]==1 .And. LeiEcf3()",50,.F.})

	
	aResWiz6	:= Array(Len(aPerWiz6))
	aResWiz6[1]	:= 0 
	aResWiz6[2]	:= iif(!empty(aLoadRes[ECF_IND_QTE_SCP])      ,aLoadRes[ECF_IND_QTE_SCP]         ,'000') 	
	aResWiz6[3]	:= iif(!empty(aLoadRes[ECF_IND_ADM_FUN_CLU])  ,val(aLoadRes[ECF_IND_ADM_FUN_CLU]),2) 	
	aResWiz6[4]	:= iif(!empty(aLoadRes[ECF_IND_PART_CONS])    ,val(aLoadRes[ECF_IND_PART_CONS])  ,2) 
	aResWiz6[5]	:= iif(!empty(aLoadRes[ECF_IND_OP_EXT])       ,val(aLoadRes[ECF_IND_OP_EXT])     ,2) 
	aResWiz6[6]	:= iif(!empty(aLoadRes[ECF_IND_OP_VINC])      ,val(aLoadRes[ECF_IND_OP_VINC])    ,2) 	
	aResWiz6[7]	:= iif(!empty(aLoadRes[ECF_IND_PJ_ENQUAD])    ,val(aLoadRes[ECF_IND_PJ_ENQUAD])  ,2) 
	aResWiz6[8]	:= iif(!empty(aLoadRes[ECF_IND_PART_EXT])     ,val(aLoadRes[ECF_IND_PART_EXT])   ,2) 
	aResWiz6[9]	:= iif(!empty(aLoadRes[ECF_IND_ATIV_RURAL])   ,val(aLoadRes[ECF_IND_ATIV_RURAL]) ,2) 
	aResWiz6[10]:= iif(!empty(aLoadRes[ECF_IND_LUC_EXP])      ,val(aLoadRes[ECF_IND_LUC_EXP])    ,2) 	
	aResWiz6[11]:= iif(!empty(aLoadRes[ECF_IND_RED_ISEN])     ,val(aLoadRes[ECF_IND_RED_ISEN])   ,2) 
	aResWiz6[12]:= iif(!empty(aLoadRes[ECF_IND_FIN])          ,val(aLoadRes[ECF_IND_FIN])        ,2) 	
	aResWiz6[13]:= iif(!empty(aLoadRes[ECF_IND_DOA_ELEIT])    ,iif(!Layt7ECF(),2,val(aLoadRes[ECF_IND_DOA_ELEIT]))  ,2) 
	aResWiz6[14]:= iif(!empty(aLoadRes[ECF_IND_PART_COLIG])   ,val(aLoadRes[ECF_IND_PART_COLIG]) ,2) 
	aResWiz6[15]:= iif(!empty(aLoadRes[ECF_IND_VEND_EXP])     ,iif(!Layt7ECF(),2,val(aLoadRes[ECF_IND_VEND_EXP]))   ,2) 
	aResWiz6[16]:= iif(!empty(aLoadRes[ECF_IND_REC_EXT])      ,val(aLoadRes[ECF_IND_REC_EXT])    ,2) 	
	aResWiz6[17]:= iif(!empty(aLoadRes[ECF_IND_ATIV_EXT])     ,val(aLoadRes[ECF_IND_ATIV_EXT])   ,2) 
	aResWiz6[18]:= iif(!empty(aLoadRes[ECF_IND_COM_EXP])      ,iif(!Layt7ECF(),2,val(aLoadRes[ECF_IND_COM_EXP]))    ,2) 	
	aResWiz6[19]:= iif(!empty(aLoadRes[ECF_IND_PAGTO_EXT])    ,val(aLoadRes[ECF_IND_PAGTO_EXT])  ,2) 
	aResWiz6[20]:= iif(!empty(aLoadRes[ECF_IND_ECOM_TI])      ,val(aLoadRes[ECF_IND_ECOM_TI])    ,2) 	
	aResWiz6[21]:= iif(!empty(aLoadRes[ECF_IND_ROY_REC])      ,val(aLoadRes[ECF_IND_ROY_REC])    ,2) 	
	aResWiz6[22]:= iif(!empty(aLoadRes[ECF_IND_ROY_PAG])      ,val(aLoadRes[ECF_IND_ROY_PAG])    ,2) 	
	aResWiz6[23]:= iif(!empty(aLoadRes[ECF_IND_REND_SERV])    ,val(aLoadRes[ECF_IND_REND_SERV])  ,2) 
	aResWiz6[24]:= iif(!empty(aLoadRes[ECF_IND_PAGTO_REM])    ,val(aLoadRes[ECF_IND_PAGTO_REM])  ,2) 
	aResWiz6[25]:= iif(!empty(aLoadRes[ECF_IND_INOV_TEC])     ,val(aLoadRes[ECF_IND_INOV_TEC])   ,2) 
	aResWiz6[26]:= iif(!empty(aLoadRes[ECF_IND_CAP_INF])      ,val(aLoadRes[ECF_IND_CAP_INF])    ,2) 	
	aResWiz6[27]:= iif(!empty(aLoadRes[ECF_IND_PJ_HAB])       ,val(aLoadRes[ECF_IND_PJ_HAB])     ,2) 
	aResWiz6[28]:= iif(!empty(aLoadRes[ECF_IND_POLO_AM])      ,val(aLoadRes[ECF_IND_POLO_AM])    ,2) 	
	aResWiz6[29]:= iif(!empty(aLoadRes[ECF_IND_ZON_EXP])      ,val(aLoadRes[ECF_IND_ZON_EXP])    ,2) 	
	aResWiz6[30]:= iif(!empty(aLoadRes[ECF_IND_AREA_COM])     ,val(aLoadRes[ECF_IND_AREA_COM])   ,2) 
	aResWiz6[31]:= iif(!empty(aLoadRes[ECF_COD_IDENT_REG21])  ,aLoadRes[ECF_COD_IDENT_REG21]     ,Space(06)) 	
	aResWiz6[32]:= iif(!empty(aLoadRes[ECF_COD_ID_BL_V_DEREX]),aLoadRes[ECF_COD_ID_BL_V_DEREX]   ,space(10))
	
EndIf

//---------------------------------------------
//Wizard 07
//---------------------------------------------
If cPasso = '07'
	aAdd(aPerWiz7,{1,"Data Inicial"							,CTOD("20140101")	,""	 ,""  				,""   	,		,60	,.T.})
	aAdd(aPerWiz7,{1,"Data Final"						 	,CTOD("20141231")	,""	 ,""  				,"" 	,		,60	,.T.})
	aAdd(aPerWiz7,{1,"Apura็ใo do Exercicio(L/P)"		 	,CTOD("20140101")	,""	 ,""  				,"" 	,		,60 ,.F.})
	aAdd(aPerWiz7,{1,"Calendแrio"						 	,nTamCalend	  		,"@!","ExistCpo('CTG',aResWiz7[4])"	,"CTG" 	,		,03 ,.T.}) 
	aAdd(aPerWiz7,{1,"Moeda"							 	,nTamMoeda 	  		,"@!","ExistCpo('CTO',aResWiz7[5])"	,"CTO" 	,		,05 ,.T.}) 
	aAdd(aPerWiz7,{1,"Tipo de Saldo"					 	,Space(1)		  	,"@!","ExistCpo('SX5','SL'+ aResWiz7[6])","SLD" 	,    	,05 ,.T.})
	aAdd(aPerWiz7,{1,"Plano de Contas De"				 	,nTamConta		  	,"@!",""				,"CT1" 	,    	,50 ,.F.}) 
	aAdd(aPerWiz7,{1,"Plano de Contas At้"				 	,nTamConta		  	,"@!",""				,"CT1" 	,    	,50 ,.F.})	
	aAdd(aPerWiz7,{1,"Conta Patrimonio De"				 	,nTamConta		  	,"@!",""				,"CT1" 	, "" 	,50 ,.F.}) 
	aAdd(aPerWiz7,{1,"Conta Patrimonio At้"				 	,nTamConta		 	,"@!",""				,"CT1" 	, "" 	,50 ,.F.})
	aAdd(aPerWiz7,{1,"Conta Resultado De"				 	,nTamConta		  	,"@!",""				,"CT1" 	, "" 	,50 ,.F.}) 
	aAdd(aPerWiz7,{1,"Conta Resultado At้"				 	,nTamConta		  	,"@!",""				,"CT1" 	, "" 	,50 ,.F.})
	aAdd(aPerWiz7,{3,"Considera Vis. p/ Bal. Patrim. e DRE"	,2					,{"1 = Sim"				, "2 = Nใo"}	,50,"EcfVldVis(1)",.T.,.T.})
	aAdd(aPerWiz7,{1,"Cod. Conf. Bal. Patrim"			 	,nTamVis  		  	,"@!",""	 			,"CTN" 	,"lVis"	,   ,.F.})
	aAdd(aPerWiz7,{1,"Cod. Conf. Dem. Resul"			 	,nTamVis  		  	,"@!",""	 			,"CTN" 	,"lVis"	,   ,.F.})
	aAdd(aPerWiz7,{3,"Processa C. Custo ?"				 	,2 			  ,aOpta,65,"",.T.})
	aAdd(aPerWiz7,{1,"Plan. Conta Ref.  "				 	,cCodPla			,"@!","ExistCpo('CVN')" ,"CVN1"	,		,50	,.F.})
	aAdd(aPerWiz7,{1,"Versใo" 								,nVerPla			,"@!",""				," "   	,		,50	,.F.})
	
	aResWiz7	:= Array(Len(aPerWiz7))
	aResWiz7[1]	:= iif(!empty(aLoadRes[ECF_DATA_INI])		,CTOD(aLoadRes[ECF_DATA_INI])	,CTOD("")) 
	aResWiz7[2]	:= iif(!empty(aLoadRes[ECF_DATA_FIM])		,CTOD(aLoadRes[ECF_DATA_FIM])	,CTOD(""))
	aResWiz7[3]	:= iif(!empty(aLoadRes[ECF_DATA_LP])		,CTOD(aLoadRes[ECF_DATA_LP])	,CTOD(""))
	aResWiz7[4]	:= iif(!empty(aLoadRes[ECF_CALENDARIO])		,aLoadRes[ECF_CALENDARIO]		,Space(CTG->(TamSx3("CTG_CALEND")[1])))
	aResWiz7[5]	:= iif(!empty(aLoadRes[ECF_MOEDA])			,aLoadRes[ECF_MOEDA]			,Space(CTO->(TamSx3("CTO_MOEDA" )[1])))
	aResWiz7[6]	:= iif(!empty(aLoadRes[ECF_TIPO_SALDO])		,aLoadRes[ECF_TIPO_SALDO]		,Space(1))
	aResWiz7[7]	:= iif(!empty(aLoadRes[ECF_CONTA_INI])		,Padr(aLoadRes[ECF_CONTA_INI]	  ,Len(CT1->CT1_CONTA))	,nTamConta)
	aResWiz7[8]	:= iif(!empty(aLoadRes[ECF_CONTA_FIM])		,Padr(aLoadRes[ECF_CONTA_FIM]	,Len(CT1->CT1_CONTA))	,nTamConta)	
	aResWiz7[9]	:= iif(!empty(aLoadRes[ECF_CONTA_PATR_INI]) ,Padr(aLoadRes[ECF_CONTA_PATR_INI],Len(CT1->CT1_CONTA))	,nTamConta)
	aResWiz7[10]:= iif(!empty(aLoadRes[ECF_CONTA_PATR_FIM]) ,Padr(aLoadRes[ECF_CONTA_PATR_FIM],Len(CT1->CT1_CONTA))	,nTamConta)
	aResWiz7[11]:= iif(!empty(aLoadRes[ECF_CONTA_RESU_INI]) ,Padr(aLoadRes[ECF_CONTA_RESU_INI],Len(CT1->CT1_CONTA))	,nTamConta)
	aResWiz7[12]:= iif(!empty(aLoadRes[ECF_CONTA_RESU_FIM]) ,Padr(aLoadRes[ECF_CONTA_RESU_FIM],Len(CT1->CT1_CONTA))	,nTamConta)
	aResWiz7[13]:= iif(!empty(aLoadRes[ECF_CON_VISAO])		,val(aLoadRes[ECF_CON_VISAO])	,2)	
	aResWiz7[14]:= iif(!empty(aLoadRes[ECF_COD_BALPAT])		,Padr(aLoadRes[ECF_COD_BALPAT],Len(CTN->CTN_CODIGO))	,nTamVis)
	aResWiz7[15]:= iif(!empty(aLoadRes[ECF_COD_DRE])		,Padr(aLoadRes[ECF_COD_DRE],Len(CTN->CTN_CODIGO))		,nTamVis)
	aResWiz7[16]:= iif(!empty(aLoadRes[ECF_PROC_CUSTO])		,val(aLoadRes[ECF_PROC_CUSTO])	,2)
	aResWiz7[17]:= iif(!empty(aLoadRes[ECF_COD_PLA])		,Padr(aLoadRes[ECF_COD_PLA],Len(CVD->CVD_CODPLA))		,cCodPla)
	aResWiz7[18]:= iif(!empty(aLoadRes[ECF_VER_PLA])		,Padr(aLoadRes[ECF_VER_PLA],Len(CVD->CVD_VERSAO))		,nVerPla)	

EndIf

//---------------------------------------------
//Wizard 08 
//---------------------------------------------
If cPasso = '08'
	aAdd(aPerWiz8,{1,"L210 - Informa. Comp.Custos"	,nTamVis  	,"@!","","CTN",,,.F.})
	
	aAdd(aPerWiz8,{1,"P130 - Dem. Receitas Incent."	,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"P200 - Apur. da Base Cแlculo"	,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"P230 - Calc. Isen็ใo e Redu."	,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"P300 - Cแlculo do IRPJ"		,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"P400 - Apur Base de Calc.CSLL",nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"P500 - Calculo do CSLL"		,nTamVis  	,"@!","","CTN",,,.F.})	
	
	aAdd(aPerWiz8,{1,"T120 - Apur. da Base Cแlculo"	,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"T150 - Cแlculo do IRPJ"		,nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"T170 - Apur Base de Calc.CSLL",nTamVis  	,"@!","","CTN",,,.F.})
	aAdd(aPerWiz8,{1,"T181 - Calculo do CSLL"		,nTamVis  	,"@!","","CTN",,,.F.})
	
	aAdd(aPerWiz8,{1,"U180 - Cแlculo do IRPJ"		,nTamVis  	,"@!","","CTN",,,.F.})	
	aAdd(aPerWiz8,{1,"U182 - Cแlculo do CSLL"		,nTamVis 	,"@!","","CTN",,,.F.})	

	aResWiz8	:= Array(Len(aPerWiz8))
	aResWiz8[01]:= nTamVis
	aResWiz8[02]:= nTamVis
	aResWiz8[03]:= nTamVis
	aResWiz8[04]:= nTamVis
	aResWiz8[05]:= nTamVis
	aResWiz8[06]:= nTamVis
	aResWiz8[07]:= nTamVis
	aResWiz8[08]:= nTamVis
	aResWiz8[09]:= nTamVis
	aResWiz8[10]:= nTamVis
	aResWiz8[11]:= nTamVis
	aResWiz8[12]:= nTamVis
	aResWiz8[13]:= nTamVis	
EndIf

//---------------------------------------------
//Wizard 09 - Dados DIPJ
//---------------------------------------------
If cPasso = '09'
	aAdd(aPerWiz9,{3,"Posi็ใo Anterior L/P",1,aOpta,50,"",.F.,.T.})
	//aAdd(aPerWiz9,{1,"Reg X291"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X292"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X300"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X310"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X320"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X330"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X340"	,nTamVis,"@!","","CTN",,50,.F.})
	//aAdd(aPerWiz9,{1,"Reg X350"	,nTamVis,"@!","","CTN",.F.,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X390"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X400"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X460"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X470"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X480"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X490"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X500"	,nTamVis,"@!","","CTN",,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg X510"	,nTamVis,"@!","","CTN",,50,.F.}) //**	
	aAdd(aPerWiz9,{1,"Reg Y671"	,nTamVis,"@!","","CTN",,50,.F.}) //**	
	aAdd(aPerWiz9,{1,"Reg Y672"	,nTamVis,"@!","","CTN",.F.,50,.F.}) //**
	aAdd(aPerWiz9,{1,"Reg Y681"	,nTamVis,"@!","","CTN",.F.,50,.F.}) //**	
	aAdd(aPerWiz9,{1,"Reg Y800"	,Space(500) ,"@!",,"DIR",,100,.F.}) //	
	
	aResWiz9	:= Array(Len(aPerWiz9))
	aResWiz9[01]:= iif(!empty(aLoadRes[ECF_POSANTLP]),val(aLoadRes[ECF_POSANTLP]),2)
	//aResWiz9[2]	:= nTamVis
	//aResWiz9[3]	:= nTamVis
	//aResWiz9[4]	:= nTamVis
	//aResWiz9[5]	:= nTamVis
	//aResWiz9[6]	:= nTamVis
	//aResWiz9[7]	:= nTamVis
	//aResWiz9[8]	:= nTamVis
	aResWiz9[02]:= nTamVis
	aResWiz9[03]:= nTamVis
	aResWiz9[04]:= nTamVis
	aResWiz9[05]:= nTamVis
	aResWiz9[06]:= nTamVis
	aResWiz9[07]:= nTamVis
	aResWiz9[08]:= nTamVis
	aResWiz9[09]:= nTamVis
	aResWiz9[10]:= nTamVis
	aResWiz9[11]:= nTamVis
	aResWiz9[12]:= nTamVis
	aResWiz9[13]:= Space(500)
EndIf

//---------------------------------------------
//Wizard 10 - Testa Conexใo
//---------------------------------------------
If cPasso = '10'
	//Cria Perguntas
	aAdd(aPerWiz10,{1,"Conexao: ",Space(50),"","","",,200,.F.})
	aAdd(aPerWiz10,{1,"Server: " ,Space(50),"","","",,200,.F.})
	aAdd(aPerWiz10,{1,"Porta: "  ,Space(50),"","","",,200,.F.})
	
	aResWiz10	:= Array(Len(aPerWiz10))
	aResWiz10[1]	:= Space(50)
	aResWiz10[2]	:= Space(50)
	aResWiz10[3]	:= Space(50)
EndIf

RestArea( aArea )
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbTamFil บAutor  ณFelipe Cunha			 บ Data ณ  23/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o tamanho do campo 							      บฑฑ
ฑฑบ          ณ                                                   		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbTamFil(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfVldVis	    บAutor  ณFelipe Cunha	'	บ Data ณ  26/08/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os parametros de conta do BP e DRE, se por visao    บฑฑ
ฑฑบDesc.     ณ  ou se por range de contas								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EcfVldVis(nOpc)

Default nOpc := 1 

If Len(aResWiz7) > 0
	If nOpc == 1
		If ( aResWiz7[13] == 2 )
			lVis := .F. //Desabilita o modo por Visใo Gerencial
		Else
			lVis := .T. //Habilita o modo por Visใo Gerencial
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeiEcf3	    บAutor  ณEduardo.FLima		บ Data ณ  12/05/17บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o leiaute e superior ao 3                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ    ECF                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LeiEcf3()
Local lRet
	lRet:= aResWiz2[3]>=3

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValdPas04	    บAutor  ณJulyane Vale		บ Data ณ  02/05/19บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do passo 4										 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ   CTBS101                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValdPas04(aPerWiz4,aResWiz4)

Local lRet:=.T.

If __nLayout < 7 .And. aResWiz4[2]==8 
	Help(NIL, NIL, "Indicador de Situa็ใo Especial", NIL, "A op็ใo TRANSFORMAวรO estแ obsoleta e nใo poderแ ser mais utilizada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecionar outra op็ใo no combo 'Indicador de Situa็ใo Especial'."})
	lRet:=.F.
Endif 

If lRet
	lRet:= ValidaParam(aPerWiz4,aResWiz4)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValdPas05	    บAutor  ณEduardo.FLima		บ Data ณ  12/05/17บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do passo 5											 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ   CTBS101                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValdPas05(aPerWiz5,aResWiz5,aResWiz4)
Local lRet:=.T.

If aResWiz5[15]==1 .and. empty(aResWiz5[16])
	Help('',1,'Paํs a Paํs',,'Ao selecionar que a declara็ใo ้ paํs a paํs ้ necessario preencher o c๓digo identificador do Bloco W',1,0)
	lRet:=.F.
Endif 

If aResWiz5[15]==2 .and. !empty(aResWiz5[16])
	Help('',1,'Paํs a Paํs',,'Ao selecionar que a declara็ใo nใo ้ paํs a paํs ้ necessario que o c๓digo identificador do Bloco W esteja em Branco',1,0)
	lRet:=.F.
Endif

If aResWiz4[6]==3 .And. aResWiz5[15]!=2   //ECF DA SCP NAO TEM DECLARACAO PAIS A PAIS
	Help('',1,'Paํs a Paํs',,'Ao selecionar que a ECF ้ da SCP deve se responder declara็ใo paํs a paํs igual a Nใo.',1,0)
	lRet:=.F.
Endif

If __nLayout >= 7
	//valid para quando informar na tela de indicador de situa็ใo especial - (Desenquadramento de imune/isenta) 
	//nใo permitir selecionar itens 8 e 9 da forma de tributacao do lucro.
	If aResWiz4[2]==9 .And. aResWiz5[3]>=8 .And. aResWiz5[3]<=9
		Help('',1,'TRIB_IMUNE_ISENTO',,'Ao selecionar o indicador de situacao especial igual a Desenquadramento de Imune/Isenta nao permitido selecionar itens 8 e 9.',1,0)
		lRet:=.F.
	EndIf
EndIf	

If lRet
	lRet:= ValidaParam(aPerWiz5,aResWiz5)
Endif
If lRet .And. aResWiz5[17]==2  //se resposta for nao sempre limpar o campo Identif Derex
 	 aResWiz6[32] := Space(10)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValdPas06	    บAutor  ณEduardo.FLima		บ Data ณ  12/05/17บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do passo 6											 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ   CTBS101                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValdPas06(aPerWiz6,aResWiz6)
Local lRet:=.T.

If  aResWiz2[3] >= 6 // layout 6 e acima
	If aResWiz6[1] == 2 .or. aResWiz6[1] == 3
		Help('',1,'Aliquota Incorreta',,'A partir de 1บ de janeiro de 2019, a aliquota usada deve ser 9% ou 15%',1,0)
		lRet:=.F.
	EndIf
ElseIf 	aResWiz2[3] < 6 // layout 5 e abaixo
	If aResWiz6[1] == 4
		Help('',1,'Aliquota Incorreta',,'Entre 1บ de outubro de 2015 e 31 de dezembro de 2018, deve ser usada a aliquota de 17%',1,0)
		lRet:=.F.
	EndIf
EndIf

If aResWiz6[27]==1 .and. empty(aResWiz6[31])
	Help('',1,'Pj Habilitada',,'Ao selecionar que a op็ใo Pj Hbilitada Igual a sim ้ necessario preencher o c๓digo identificador do Registro 0021',1,0)
	lRet:=.F.
Endif 
If aResWiz6[27]==2 .and. !empty(aResWiz6[31])
	Help('',1,'Pj Habilitada',,'Ao selecionar que a op็ใo Pj Hbilitada igual a nใo ้ necessario que o c๓digo identificador do Registro 0021 esteja em branco',1,0)
	lRet:=.F.
Endif
If aResWiz5[17]==1 .and. empty(aResWiz6[32])
	Help('',1,'DEREX',,'Ao selecionar que a declara็ใo ้ obrigatoria, necessario informar o identificador do Bloco V - DEREX.',1,0)
	lRet:=.F.
Endif
If lRet
	lRet:= ValidaParam(aPerWiz6,aResWiz6)
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ECFY671

Valida a partir do leiaute 7 nao preencher visao referente registro Y671

@author Totvs
@since 18-02-2021
@version P12.1.33
/*/
//-------------------------------------------------------------------
Static Function ECFY671(aResWiz9)
Local lRet := .T.

If __nLayout >= 7
	If !Empty(aResWiz9[10])
		Help('',1,'Y671_INV',,'A partir do leiaute 7 visao do registro Y671 nใo deve ser informada.',1,0)
		lRet:=.F.
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ECFLayout
Parambox com retorno do leiaute da ECF a incluir

@author Totvs
@since 18-02-2021
@version P12.1.33
/*/
//-------------------------------------------------------------------
Static Function ECFLayout()
Local lRet := .T.
Local aParLeiaute
Local aRespLeiaute
Local aECFLeiaute := ECF_Leiaute()

aParLeiaute := {} 
aAdd(aParLeiaute ,{3,"Informe o leiaute da ECF?",__nLayout,aECFLeiaute,90,"",.T.,.T.}) 
aRespLeiaute := {__nLayout}

If ParamBox( aParLeiaute," [ ECF ] - Selecione o leiaute da ECF.", @aRespLeiaute)
	__nLayout	:= aRespLeiaute[1]
Else
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ECF_Leiaute
Retorna array com a lista de leiautes da ECF


@author Totvs
@since 18-02-2021
@version P12.1.33
/*/
//-------------------------------------------------------------------
Static Function ECF_Leiaute()

Local aLeiaute := {"Leiaute 1.0" , "Leiaute 2.0","Leiaute 3.0","Leiaute 4.0","Leiaute 5.0","Leiaute 6.0","Leiaute 7.0","Leiaute 8.0"}

Return(aLeiaute)

//-------------------------------------------------------------------
/*/{Protheus.doc} Layt7ECF
Retorna .F. para perguntas a ser desabilitada a partir do leiaute 7


@author Totvs
@since 18-02-2021
@version P12.1.33
/*/
//-------------------------------------------------------------------
Static Function Layt7ECF()
Local lRet := .T.

If __nLayout >= 7
	lRet := .F.
EndIf

Return(lRet)
