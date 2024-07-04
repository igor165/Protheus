#INCLUDE "PROTHEUS.CH"   
#INCLUDE "GPER830.ch"  
#DEFINE   nColMax	2350   
#DEFINE   nLinMax	2900      

/*                                                                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER830   ºAutor  ³Erika Kanamori         º Data ³  09/16/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imposto sobre Ganancias                                        º±±
±±º          ³F. 649                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºProgramad ³ Data   ³ BOPS     ³  Motivo da Alteracao                      º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºRenata E. ³12/01/09³00894/2009|Ajuste em IMPBOL(), para antes da chamada  º±±
±±º          ³        ³          ³fBuscaAcmPer(),  posicionar no SRA, na     º±±
±±º          ³        ³          ³ mesma filial\mat do cQrySRA().            º±±
±±ºAlceu P.  ³24/03/09³6142/2009 ³Feito ajuste de impressao para a coluna de º±±
±±º			 ³		  ³	         ³descricao e os campos de datas no final do º±± 
±±º			 ³		  ³	         ³relatorio.Tambem foram traduzidas novamenteº±±
±±º			 ³		  ³	         ³as Strings.Foi retirado o CH responsavel   º±±
±±º			 ³		  ³	         ³pelos nomes dos campos, chumbado no codigo º±±
±±º			 ³		  ³			 ³os nomes dos campos.						 º±±
±±ºAdemar Jr ³27/05/09³          ³Ajuste da passagem de parametro pra funcao º±±
±±º          ³        ³          ³fBuscaAcmPer().                            º±±
±±ºAlceu P.  ³05/06/09³          ³Ajuste feito para verificar o campo        º±±
±±º			 ³        ³			 ³RV_CODIGRR                                 º±±
±±º          ³        ³          ³verificacao da quantidade de dependentes   º±±    
±±º          ³        ³          ³para calculo das cargas familiares.		 º±±
±±ºSilvia    ³17/08/09³0214032009³Tratamento Valor Imposto Determinado.      º±±  
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºProgramador ³ Data   ³FNC/PLANO       ³  Motivo da Alteracao              º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºAlceu P.    ³17/09/09³00000023069/2009³Correcao para o valor de n310 e    º±±
±±º			   ³		³				 ³para comparacao do periodo anteriorº±±
±±ºAlceu P.    ³11/12/09³00000027101/2009³Ajuste para que possa considerar   º±±
±±º			   ³		³				 ³deduciones ref a reliquidacao de   º±±
±±º			   ³		³				 ³Ganancias. Ajustada a Data de      º±±
±±º			   ³		³				 ³impressao de demonstrativo do perioº±±
±±º			   ³		³				 ³do de liquidacao anual.	         º±±
±±ºAlceu P.    ³11/12/09³00000027101/2009³Ajuste para que possa considerar   º±±
±±º			   ³		³				 ³deduciones ref a reliquidacao de   º±±
±±º			   ³		³				 ³Ganancias. Ajustada a Data de      º±±
±±º			   ³		³				 ³impressao de demonstrativo do perioº±±
±±º			   ³		³				 ³do de liquidacao anual.	         º±±
±±ºFrancisco Jr³11/02/10³00000002526/2010³Tratamento de Filial para uso na   º±±
±±º			   ³		³				 ³Gestao Corporativa.                º±±
±±º			   ³		³				 ³                                   º±±
±±º			   ³		³				 ³                                   º±±
±±º			   ³		³				 ³                                   º±±
±±ºTiago Malta ³23/02/10³00000027101/2009³Ajustes para despresar registros   º±±
±±º			   ³		³				 ³deletados e alteração no valor     º±±
±±º			   ³		³				 ³da posição 191.                    º±±
±±ºTiago Malta ³27/05/10³00000027101/2009³Ajustes nos valores das linhas 027/º±±
±±º			   ³		³				 ³035/043/078/418/426/507/515/604/612º±±
±±º			   ³		³				 ³/701/728/809/817/825/833.          º±±
±±ºL.Trombini  ³02/05/11³00000001231/2011³Ajustes nos valores das linhas 132/º±±
±±º			   ³		³				 ³140/213/221/256/418/426/507/515/604º±±
±±º			   ³		³				 ³/612/701/728/809/817/825/833       º±±
±±ºGlaucia M.  ³02/02/12³REQ0008 ARG11.6 ³Ajustes Modelo2					 º±±
±±ºGlaucia M.  ³02/02/12³REQ0007 ARG11.6 ³Ajustes conforme nova especificaçãoº±±
±±ºGlaucia M.  ³28/03/12³REQ0007 ARG11.6 ³Nova especificação 26/03/12	 	 º±±
±±ºGlaucia M.  ³29/03/12³REQ0007 ARG11.6 ³Nova especificação 29/03/12	 	 º±±
±±ºGlaucia M.  ³27/04/12³REQ0007 ARG11.6 ³Ajusta de consulta SQL RG1 p/ DB2. º±±
±±ºM.Camargo   ³13/04/18³DMINA-2720      ³Declaración de variables en nXXX   º±±
±±º			   ³		³				 ³en vertical función IMPBOL         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

Function GPER830()       
                            
Local aArea		:= GetArea()
Local bProc := {|oSelf| fGPR830(oSelf) }    

oProcess := tNewProcess():New("GPER830",OemtoAnsi(STR0001),bProc,OemtoAnsi(STR0002),"GPR830",,,,,.T.,.T. ) 
RestArea(aArea)

Return          



Static Function fGPR830(oProcess)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private aReturn 	:={ , 1,, 2, 2, 1,"",1 }
Private cPerg   	:= "GPR830"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao IMPR                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cProcesso	:= ""
Private cRoteiro	:= ""
Private cPeriodo	:= ""
Private cPago		:= ""
Private cFilialDe   := "" 
Private cFilialAte  := ""
Private cMatDe      := ""
Private cMatAte     := "" 
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cSit        := ""
Private nTipoRel	
Private cDGIFunc	:= ""
Private cDGIEmp		:= ""
Private cNumResol	:= ""   
Private cRepLegal	:= ""
Private cCargoRep   := ""
Private cObserva1	:= ""
Private cObserva2	:= ""
Private oPrint    
Private cAnoPos		:= ""		
Private cAnoAnt		:= ""	

pergunte(cPerg,.F.)  


cProcesso	:= mv_par01
cRoteiro	:= mv_par02
cPeriodo	:= mv_par03
cPago		:= mv_par04
cFilialDe   := mv_par05
cFilialAte  := mv_par06
cMatDe      := mv_par07
cMatAte     := mv_par08
cCustoDe    := mv_par09
cCustoAte   := mv_par10
cSit        := mv_par11
nTipoRel	:= mv_par12
cDGIFunc	:= mv_par13
cDGIEmp		:= mv_par14
cNumResol	:= mv_par15
cRepLegal	:= mv_par16
cCargoRep	:= mv_par17
cObserva1	:= mv_par18            
cObserva2   := mv_par19


//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( oemtoansi(STR0001))					//"AFIP - Impuesto a Las Ganancias Regimen de Retencion"

oPrint:SetPortrait()

IMPBOL(oProcess) 

oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir
                                                                       
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPBOL    ºAutor  ³Erika Kanamori      º Data ³  01/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
Static Function IMPBOL(oProcess) 

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER830" , "SRA", "2" ) + " } " )     
lOCAL cQryRG1		:="QRG1"
Local cFim			:= "" 
Local cFilAnt		:= "" 
Local nAux, nPos	:= 0     
Local aVerbasAcum 	:= {} 
                         
Local cProcFunc		:= ""
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 

Local cAliasRG1		:= "RG1"  
Local cQuery        
Local aPerAbe		:= {}
Local aPerFec 		:= {}
Local aPerTodos 	:= {}
Local lAcrGan		:= .F.
Local aEmpresas		:= {}
Local nEmpDe 
Local cIGRR 		:= "('" 
Local cRub11_418	:= "'"  
Local cRub11_426 	:= "'" 
Local cRub12_507 	:= "'" 
Local cRub13_604 	:= "'" 
Local cRub13_612	:= "'"  
Local cRub14_701 	:= "'" 
Local cRub14_728 	:= "'" 
Local cRub15_809	:= "'" 
Local cRub15_817 	:= "'" 	
Local cRub15_825  	:= "'" 	
Local cGravaF649	:= "" 
Local cAllIGRR		:= ""
Local cIGR2 		:= "('" 
Local cRub21_418	:= "'"  
Local cRub21_426 	:= "'" 
Local cRub22_507 	:= "'" 
Local cRub23_604 	:= "'" 
Local cRub24_701 	:= "'" 
Local cRub25_809	:= "'" 
Local cRub25_817 	:= "'" 	
Local cRub25_825  	:= "'"
Local cRub25_826  	:= "'" 	
Local cAllIGR2		:= ""
Local lEntidade		:= .F. 
Local nValor		:=  0


Local cFiltro		:= ""   
Local nCountSRA		:= 0


Private cQrySRA := "SRA"    
Private cAlias	:= "SRA"                          
Private n019 := 0
Private n027 := 0
Private n035 := 0
Private n043 := 0
Private n078 := 0
Private n094 := 0				//Variaveis que serao impressas na secao 1
Private n116 := 0
Private n124 := 0
Private n132 := 0
Private n140 := 0
Private n159 := 0
Private n167 := 0
Private n175 := 0 		//Variaveis que serao impressas na secao 2
Private n183 := 0                                                		//Variaveis que serao impressas na secao 3
Private n191 := 0                                                		//Variaveis que serao impressas na secao 4
Private n205 := 0                                                		//Variaveis que serao impressas na secao 5
Private n213 := 0 
Private n221 := 0
Private n256 := 0
Private n264 := 0
Private n272 := 0
Private n302 := 0       		//Variaveis que serao impressas na secao 6
Private n310 := 0                                                		//Variaveis que serao impressas na secao 7
Private n329 := 0                                                		//Variaveis que serao impressas na secao 8
Private n345 := 0
Private n346 := 0
Private n347 := 0
Private n353 := 0
Private n361 := 0               		//Variaveis que serao impressas na secao 9
Private n388 := 0
Private n393 := 0                                        		//Variaveis que serao impressas na secao 10
Private n418 := 0
Private n426 := 0
Private n434 := 0                                		//Variaveis que serao impressas na secao 11 
Private n507 := 0
Private n515 := 0										 		//Variaveis que serao impressas na secao 12
Private n604 := 0
Private n612 := 0
Private n620 := 0								 		//Variaveis que serao impressas na secao 13
Private n701 := 0
Private n728 := 0
Private n736 := 0 								 		//Variaveis que serao impressas na secao 14	 
Private n809 := 0
Private n817 := 0
Private n825 := 0
Private n833 := 0						 		//Variaveis que serao impressas na secao 15
Private dDataIni	
Private dDataFim	  
Private cFigura		:= "AFIP.bmp"
Private aInfo		:= {} 
Private aVerbas		:= {} 
Private aEntidades	:= {}
Private aEntidad2	:= {}
Private aF649		:={}                                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont08, oFont09, oFont07n, oFont10n, oFont12n, oFont09num   

oFont05		:= TFont():New("Arial",05,06,,.F.,,,,.T.,.F.)
oFont06		:= TFont():New("Arial",06,05,,.F.,,,,.T.,.F.)
oFont07		:= TFont():New("Arial",07,06,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,07,,.F.,,,,.T.,.F.)
oFont09		:= TFont():New("Arial",10,09,,.F.,,,,.T.,.F.) 

oFont10		:= TFont():New("Arial",10,09,,.F.,,,,.T.,.F.) 
oFont11		:= TFont():New("Arial",11,10,,.F.,,,,.T.,.F.) 


oFont07n	:= TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
oFont09num	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.) 	//Fonte exclusiva para valores e manter o alinhamento dos mesmos
oFont10n	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)     	//Negrito//
oFont11n	:= TFont():New("Arial",11,9.5,,.T.,,,,.T.,.F.)     	//Negrito//
oFont12n	:= TFont():New("Arial",12,11,,.T.,,,,.T.,.F.)     	//Negrito//
oFont17n	:= TFont():New("Arial",17,16,,.T.,,,,.T.,.F.)     	//Negrito//
oFont25n	:= TFont():New("Arial",25,24,,.T.,,,,.T.,.F.)     	//Negrito//

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS 
SET CENTURY ON 

	aEmpresas	:= FwAllFilial(,,,.F.)	// seleção de todas filiais de todas empresas
	nEmpDe		:= iif(aScan(aEmpresas,cFilialDe)==0,1,aScan(aEmpresas,cFilialDe))  
	cFilialDe	:= aEmpresas[nEmpDe]

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao e Categoria em formato para SQL              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
	cSitu   := "(" 
	For nAux := 1 To Len(cSit)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu 	:= Substr(cSitu,1,len(cSitu)-2) + "')" 
      
	
	//parametro periodo
	cMes := Substr( alltrim(MV_PAR03),5,2)
	cAno := Substr( alltrim(MV_PAR03),1,4)

	fRetPerComp( 	cMes		  	,;		// Obrigatorio - Mes para localizar as informacoes
					cAno		  	,;		// Obrigatorio - Ano para localizar as informacoes
					xFilial("RCH")	,;		 // Opcional - Filial a Pesquisar
							  		,;		// Opcional - Filtro por Processo
			    	          		,;		// Opcional - Filtro por Roteiro
					@aPerAbe	  	,;		// Por Referencia - Array com os periodos Abertos
					@aPerFec, 		;		// Por Referencia - Array com os periodos Fechados
					@aPerTodos    	;		// Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente
			 )
	
	If (len(aPerTodos) <= 0)
		Alert(OemToAnsi(STR0134)+ " " + OemToAnsi(STR0132))			//"Não existem períodos válidos para a data informada." #### "O relatório não poderá ser gerado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		return 
	Endif   


	/*  
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega CUIT e nome das entidades de deduccion               ³
	³ aEntidades: 1- codigo  2- entidade   3- CUIT                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   	dbSelectArea("RCC")
   	dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
	dbSeek(xFilial("RCC")+"S025")  
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S025"       		
		aAdd(aEntidades, {Substr(RCC->RCC_CONTEU,1,3), Substr(RCC->RCC_CONTEU,4,30), Substr(RCC->RCC_CONTEU,34,14)} )
		("RCC")->(dbSkip())
	End 
	
	If (len(aEntidades) <= 0) 
		lEntidade := .F. 			//Tabela entidades S025-Vazia, então asientos fijos não serão considerados
	Else
		lEntidade := .T. 
	Endif
		

    cAllIGRR	:= '|019|027|035|043|078|116|124|132|140|159|167|191'
    cAllIGRR	+= '|213|221|256|264|272|329|345|346|347|353|388|393|418|426|434'
    cAllIGRR	+= '|507|515|604|620|701|728|736|809|817|825|833'
	cAllIGR2	:= '|418|426|507|604|701|809|817|825|826'    
    dbSelectArea("RCC")    
   	dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
	dbSeek(xFilial("RCC")+"S030")  
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S030" 
		IF   (Substr (  RCC->RCC_CONTEU, 1, 3)  $ (cAllIGR2)) .and. (RCC->RCC_CODIGO == "S030" ) .And. (RCC->RCC_FILIAL == XFilial() ) 
			aAdd(aEntidad2, {Substr(RCC->RCC_CONTEU,4,30)} )
		ENDIF
	dbSkip()	
	EndDo
	/*  
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Verbas que possuem o campo RV_CODIGRR preenchido	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DbSelectArea("SRV")
	DbSetOrder(1)  
	dbSeek(xFilial("SRV"))
	While (!Eof()) .And. (SRV->RV_FILIAL == xFilial("SRV") )
		//Condicao para separar todas as verbas que serão utilizadas no relatório
		if 	!empty(SRV->RV_CODIGRR)  .AND. 	(SRV->RV_CODIGRR $ (cAllIGRR)) 
			
			Aadd(aVerbas,{SRV->RV_COD,0}) 
			
			//Condicao para separar todas as verbas que usarao Entidades de lançamentos fixos
			IF (SRV->RV_CODIGRR $ '|418|426|507|604|612|701|728|809|817|825')
				cIGRR += SRV->RV_COD + "','"
			EndIf
			
			If SRV->RV_CODIGRR $ '418'
				cRub11_418 +=  SRV->RV_COD + "|" 
			ElseIf SRV->RV_CODIGRR $ '426'
				cRub11_426 +=  SRV->RV_COD + "|" 		
			ElseIf SRV->RV_CODIGRR $ '507'
				cRub12_507 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '604'
				cRub13_604 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '612'
				cRub13_612 +=  SRV->RV_COD + "|" 
			ElseIf SRV->RV_CODIGRR $ '701'
				cRub14_701 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '728'
				cRub14_728 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '809'
				cRub15_809 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '817'
				cRub15_817 += SRV->RV_COD + "|"
			ElseIf SRV->RV_CODIGRR $ '825'
				cRub15_825 += SRV->RV_COD + "|"				
			EndIf
		Endif
		IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
			if 	!empty(SRV->RV_CODIGR2)  .AND. 	(SRV->RV_CODIGR2 $ (cAllIGR2))
			 	if Ascan( aVerbas, { |X| X[1] = SRV->RV_COD } ) == 0 
					Aadd(aVerbas,{SRV->RV_COD,0}) 
				EndIf
				IF (SRV->RV_CODIGR2 $ '|418|426|507|604|701|809|817|825|826')
					cIGR2 += SRV->RV_COD + "','"
				EndIf			
				If SRV->RV_CODIGR2 $ '418'
					cRub21_418 +=  SRV->RV_COD + "|" 
				ElseIf SRV->RV_CODIGR2 $ '426'
					cRub21_426 +=  SRV->RV_COD + "|" 		
				ElseIf SRV->RV_CODIGR2 $ '507'
					cRub22_507 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '604'
					cRub23_604 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '701'
					cRub24_701 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '809'
					cRub25_809 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '817'
					cRub25_817 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '825'
					cRub25_825 += SRV->RV_COD + "|"
				ElseIf SRV->RV_CODIGR2 $ '826'
					cRub25_826 += SRV->RV_COD + "|"					
				EndIf
			EndIf
		EndIf
		dbSkip()
	EndDo
	
	If (len(aVerbas) <= 0) 
		alert(OemtoAnsi(STR0132)+" "+ OemtoAnsi(STR0133))								//"Não existem Verbas para os parâmetros informados. ### O relatório não poderá ser gerado."			 							//"Não existem Verbas para os parâmetros informados."
		Return .F.
	EndIf
	
	cIGRR		:= Iif ( len(cIGRR) > 2 ,substr(cIGRR,1,(len(cIGRR))-2) + ")","") 
	
	cRub11_418 	:= Iif ( len(cRub11_418) > 2 ,substr(cRub11_418,1,(len(cRub11_418))-1) + "'","") 
	cRub11_426 	:= Iif ( len(cRub11_426) > 2 ,substr(cRub11_426,1,(len(cRub11_426))-1) + "'","") 
	
	cRub12_507 	:= Iif ( len(cRub12_507) > 2 ,substr(cRub12_507,1,(len(cRub12_507))-1) + "'","") 
	
	cRub13_604 	:= Iif ( len(cRub13_604) > 2 ,substr(cRub13_604,1,(len(cRub13_604))-1) + "'","") 
	cRub13_612 	:= Iif ( len(cRub13_612) > 2 ,substr(cRub13_612,1,(len(cRub13_612))-1) + "'","") 

	cRub14_701 	:= Iif ( len(cRub14_701) > 2 ,substr(cRub14_701,1,(len(cRub14_701))-1) + "'","") 
	cRub14_728 	:= Iif ( len(cRub14_728) > 2 ,substr(cRub14_728,1,(len(cRub14_728))-1) + "'","") 
	
	cRub15_809 	:= Iif ( len(cRub15_809) > 2 ,substr(cRub15_809,1,(len(cRub15_809))-1) + "'","") 
	cRub15_817 	:= Iif ( len(cRub15_817) > 2 ,substr(cRub15_817,1,(len(cRub15_817))-1) + "'","") 
	cRub15_825 	:= Iif ( len(cRub15_825) > 2 ,substr(cRub15_825,1,(len(cRub15_825))-1) + "'","") 			

	IF SRV->(fieldPOS("RV_CODIGR2")) > 0
	cIGR2		:= Iif ( len(cIGR2) > 2 ,substr(cIGR2,1,(len(cIGR2))-2) + ")","") 
	
	cRub21_418 	:= Iif ( len(cRub21_418) > 2 ,substr(cRub21_418,1,(len(cRub21_418))-1) + "'","") 
	cRub21_426 	:= Iif ( len(cRub21_426) > 2 ,substr(cRub21_426,1,(len(cRub21_426))-1) + "'","") 
	
	cRub22_507 	:= Iif ( len(cRub22_507) > 2 ,substr(cRub22_507,1,(len(cRub22_507))-1) + "'","") 
	
	cRub23_604 	:= Iif ( len(cRub23_604) > 2 ,substr(cRub23_604,1,(len(cRub23_604))-1) + "'","") 
	
	cRub24_701 	:= Iif ( len(cRub24_701) > 2 ,substr(cRub24_701,1,(len(cRub24_701))-1) + "'","") 
		
	cRub25_809 	:= Iif ( len(cRub25_809) > 2 ,substr(cRub25_809,1,(len(cRub25_809))-1) + "'","") 
	cRub25_817 	:= Iif ( len(cRub25_817) > 2 ,substr(cRub25_817,1,(len(cRub25_817))-1) + "'","") 
	cRub25_825 	:= Iif ( len(cRub25_825) > 2 ,substr(cRub25_825,1,(len(cRub25_825))-1) + "'","") 			
	cRub25_826 	:= Iif ( len(cRub25_826) > 2 ,substr(cRub25_826,1,(len(cRub25_826))-1) + "'","") 
	EndIf
	

			
	cProcFunc := "(" + "'"+alltrim(MV_PAR01)+"'"+")"		
	//montagem da query
	cQuery := "SELECT "
    cQuery += " RA_FILIAL, RA_MAT, RA_CC, RA_NOME, RA_ADMISSA, RA_DEMISSA, "
  	cQuery += " RA_CATFUNC, RA_SITFOLH, RA_CIC, RA_ENDEREC, RA_PISO, "
  	cQuery += " RA_LOCALID, RA_ESTADO, RA_CEP, RA_COMPLEM, RA_PROCES " 		
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_PROCES IN " + cProcFunc
	cQuery += "  AND "
	cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"                          	
	cQuery += "  AND "
	cQuery += " RA_SITFOLH IN " + cSitu 
	
	If TcSrvType() == "AS/400"
		cQuery += " AND @DELETED@ = ' ' "
	Else
		cQuery += " AND D_E_L_E_T_ = ' ' "
	Endif 
	
	cQuery += " ORDER BY RA_FILIAL, RA_MAT "
          
	
	cQuery := ChangeQuery(cQuery)      
	
	If select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	EndIf
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
	(cQrySRA)->(dbGoTop())
	
	
	 

	cFim     := cFilialAte + cMatAte
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua de Processamento                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetPrc(0,0)      

	nCountSRA := (cQrySRA)->(RecCount())
	oProcess:SetRegua1(nCountSRA)
		 
	While (cQrySRA)->(!Eof()) .And. ((cQrySRA)->(RA_FILIAL+RA_MAT) <= cFim )
	  
		n019 := n027 := n035 := n043 := n078 := n094 := 0        //Variaveis que serao impressas na secao 1
		n116 := n124 := n132 := n140 := n159 := n167 := n175 := 0 //Variaveis que serao impressas na secao 2
		n183 := 0                                                //Variaveis que serao impressas na secao 3
		n191 := 0                                                //Variaveis que serao impressas na secao 4
		n205 := 0                                                //Variaveis que serao impressas na secao 5
		n213 := n221 := n256 := n264 := n272 := n302 := 0        //Variaveis que serao impressas na secao 6
		n310 := 0                                                //Variaveis que serao impressas na secao 7
		n329 := 0                                                //Variaveis que serao impressas na secao 8
		n345 := n353 := n361 := 0                                //Variaveis que serao impressas na secao 9
		n388 := n393 := 0                                        //Variaveis que serao impressas na secao 10
		n418 := n426 := n434 := 0                                //Variaveis que serao impressas na secao 11
		n507 := n515 := 0										 //Variaveis que serao impressas na secao 12
		n604 := n612 := n620 := 0								 //Variaveis que serao impressas na secao 13
		n701 := n728 := n736 := 0 								 //Variaveis que serao impressas na secao 14
		n809 := n817 := n825 := n833 := n826 := 0								 //Variaveis que serao impressas na secao 15
		
		n2_418 := n2_426 := n2_434 := 0
		n2_507 := n2_515 := 0
		n2_604 := n2_612 := n2_620 := 0
		n2_701 := N2_728 := n2_736 := 0
		n2_809 := n2_817 := n2_825 := n2_826 := n2_833 := 0 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 
		If  (((cQrySRA)->RA_MAT < cMatDe)   .Or. ((cQrySRA)->RA_MAT > cMatAte)    .Or. ;
			((cQrySRA)->RA_CC  < cCustoDe)  .Or. ((cQrySRA)->RA_CC  > cCustoAte)  .Or. ;
			!((cQrySRA)->RA_SITFOLH $ cSit))
			(cQrySRA)->(dbSkip())		
			Loop
		EndIf     
		 
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Consiste Filiais e Acessos                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( (cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
	      	(cQrySRA)->( dbSkip() )
	       	Loop
		Endif            
		

	   	If cFilAnt <> (cQrySRA)->RA_FILIAL       //se filial eh diferente da anterior 
			 
			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)

			cFilAnt:= (cQrySRA)->RA_FILIAL 
				
		Endif    
		
		oProcess:IncRegua1((cQrySRA)->RA_MAT) 
		//Carrega os periodos abertos e fechados do trimestre               
		aVerbasFunc	:= {}
		
		aVerbasFunc	:= RetornaVerbasFunc(	(cQrySRA)->RA_FILIAL			,; 	// Filial do funcionario corrente
											(cQrySRA)->RA_MAT	  			,,; 	// Matricula do funcionario corrente												NIL),; 	// 
											MV_PAR02				        ,; 	// Retorna todos os Roteiro 
											aVerbas 	  					,; 	// Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
											aPerAbe		  					,; 	// Array com os Periodos e Numero de pagamento abertos
											aPerFec		 	 				,;  // Array com os Periodos e Numero de pagamento fechados
											MV_PAR04						)  //Pago 

		If Len(aVerbasFunc) < 1 
 			(cQrySRA)->( dbSkip() )
 	    	Loop
 		Endif
 		 
 		lAcrGan := .F.
		
		//busca verbas acumuladas para cada funcionário	   
		cProcesso := (cQrySRA)->RA_PROCES 			
     
        //calcula os valores a serem impressos no relatorio
        For nAux := 1 to len(aVerbasFunc) 
        
       	    //TOTALES RUBRO 1 - SOMA 094	    
       	    If aVerbasFunc[nAux][18] == "019"        	    
       	       	n019 += aVerbasFunc[nAux][7] 
   			ElseIf aVerbasFunc[nAux][18] == "027"        
       	    	n027 += aVerbasFunc[nAux][7]      	    	
			ElseIf aVerbasFunc[nAux][18] == "035"		
       	    	n035 += aVerbasFunc[nAux][7]
       	    ElseIf aVerbasFunc[nAux][18] == "043"		
       	    	n043 += aVerbasFunc[nAux][7]
			ElseIf aVerbasFunc[nAux][18] == "078"		
     	    	n078 += aVerbasFunc[nAux][7]        	    	
			
			//TOTALES RUBRO 2 - SOMA 175
			ElseIf aVerbasFunc[nAux][18] == "116"		
      	    	n116 += aVerbasFunc[nAux][7]       	    	
			ElseIf aVerbasFunc[nAux][18] == "124"		
       	    	n124 += aVerbasFunc[nAux][7]
			ElseIf aVerbasFunc[nAux][18] == "132"		
       	    	n132 += aVerbasFunc[nAux][7] 
		 	ElseIf aVerbasFunc[nAux][18] == "140"		
       	    	n140 += aVerbasFunc[nAux][7]
  			ElseIf aVerbasFunc[nAux][18] == "159"		
       	    	n159 += aVerbasFunc[nAux][7]     	    	
	     	ElseIf aVerbasFunc[nAux][18] == "167"		
       	    	n167 += aVerbasFunc[nAux][7]
   	     	
   	     	//DONACIONES (hasta el limite del 5% del rubro 3)
   	     	ElseIf aVerbasFunc[nAux][18] == "191"		
       	    	n191 += aVerbasFunc[nAux][7] 
			
			//TOTALES RUBRO 6 - SOMA 302
			ElseIf aVerbasFunc[nAux][18] == "213"		
       	    	n213 += aVerbasFunc[nAux][7]
    		ElseIf aVerbasFunc[nAux][18] == "221"		
       	    	n221 += aVerbasFunc[nAux][7]
       	    ElseIf aVerbasFunc[nAux][18] == "256"		
       	    	n256 += aVerbasFunc[nAux][7] 
       	  	ElseIf aVerbasFunc[nAux][18] == "264"		
       	    	n264 += aVerbasFunc[nAux][7] 
      		ElseIf aVerbasFunc[nAux][18] == "272"		
       	    	n272 += aVerbasFunc[nAux][7]
       	    	
       		//TOTAL DEL IMPUESTO DETERMINADO - 329
       		ElseIf aVerbasFunc[nAux][18] == "329"		
       	    	n329 += aVerbasFunc[nAux][7]


     	    //TOTALES RUBRO 9 - SOMA 361	    
      	    
 	    	ElseIf aVerbasFunc[nAux][18] == "345"		//TOTALES PARA ITEM 345 
       	    	n345 += aVerbasFunc[nAux][7]
   	    	ElseIf aVerbasFunc[nAux][18] == "346"		//TOTALES PARA ITEM 345 
       	    	n346 += aVerbasFunc[nAux][7]
 			ElseIf aVerbasFunc[nAux][18] == "347"		//TOTALES PARA ITEM 345 
       	    	n347 += aVerbasFunc[nAux][7]

  	    	ElseIf aVerbasFunc[nAux][18] == "353"	
       	    	n353 += aVerbasFunc[nAux][7] 
 			
 			//TOTALES RUBRO 10 
 			ElseIf aVerbasFunc[nAux][18] == "388" 		
       	    	n388 += aVerbasFunc[nAux][7]
			ElseIf aVerbasFunc[nAux][18] == "393" 		
				n393 += aVerbasFunc[nAux][7]      
 			
 			//TOTALES RUBRO 11 - SOMA 434
 			ElseIf aVerbasFunc[nAux][18] == "434" 		
       	    	n434 += aVerbasFunc[nAux][7]
   	        	    	
			
			//TOTALES RUBRO 12 - SOMA 515
			ElseIf aVerbasFunc[nAux][18] == "515" 		
				n515 += aVerbasFunc[nAux][7]       	    	        	    	
				
			//TOTALES RUBRO 13 - SOMA 620
			ElseIf aVerbasFunc[nAux][18] == "620"		
				n620 += aVerbasFunc[nAux][7]        	    	        	    	
       	    	
		    
		   //TOTALES RUBRO 14 - SOMA 736
		    ElseIf aVerbasFunc[nAux][18] == "736" 		
  				n736 += aVerbasFunc[nAux][7]        	    	        	    	
  			
  			//TOTALES RUBRO 15 - SOMA 833
  			ElseIf aVerbasFunc[nAux][18] == "833"		
  				n833 += aVerbasFunc[nAux][7]
     		Endif  
    	 	IF SRV->(fieldPOS("RV_CODIGR2")) > 0
				//TOTALES RUBRO 11 - SOMA 418
				If aVerbasFunc[nAux][19] == "418" 		
					n2_418 += aVerbasFunc[nAux][7]
		
				ElseIf aVerbasFunc[nAux][19] == "426" 		
					n2_426 += aVerbasFunc[nAux][7]       	    	        	    	
					
				//TOTALES RUBRO 12 - SOMA 620
				
				ElseIf aVerbasFunc[nAux][19] == "507" 		
					n2_507 += aVerbasFunc[nAux][7]
				
				//TOTALES RUBRO 13 - SOMA 736
				
				ElseIf aVerbasFunc[nAux][19] == "507"		
					n2_620 += aVerbasFunc[nAux][7]        	    	        	    	
								
				ElseIf aVerbasFunc[nAux][19] == "604" 		
					n2_604 += aVerbasFunc[nAux][7]        	    	        	    	
				
				//TOTALES RUBRO 14 - SOMA 833
				ElseIf aVerbasFunc[nAux][19] == "701"		
					n2_701 += aVerbasFunc[nAux][7]
						 
				//TOTALES RUBRO 15 - SOMA 434
				ElseIf aVerbasFunc[nAux][19] == "809" 		
				n2_809 += aVerbasFunc[nAux][7]
				ElseIf aVerbasFunc[nAux][19] == "817" 		
					n2_817 += aVerbasFunc[nAux][7]       	    	        	    	
				ElseIf aVerbasFunc[nAux][19] == "825"		
					n2_825 += aVerbasFunc[nAux][7]        	    	        	    	
				ElseIf aVerbasFunc[nAux][19] == "826" 		
					n2_826 += aVerbasFunc[nAux][7]   
				
				EndIf     	    	        	    	
     		 EndIf      
		Next nAux 

        
        //TOTALES DEL RUBRO 1
       	n094    := n019 + n027 + n035 + n043 + n078 
        
		//TOTALES DEL RUBRO 2
		n124	:= n124 + n434
		n132	:= n132 + n515
		n140	:= n140 + n620
		n167	:= n167 + n833
		n175	:= n116 + n124 + n132 + n140 + n159 + n167
		
		//RESULTADO NETO 
		n183	:= n094 - n175
				      		
		//DIFERENCIA
		n205	:= n183 - n191
		
		//TOTALES DEL RUBRO 6
		n302	:= n213 + n221 + n256 + n264 + n272
		
		//GANACIAS NETAS SUJETAS A IMPUESTO		
		n310	:= n205 - n302 
		
		//TOTALES DEL RUBRO 9 
		n345	:= n345 + n346 + n347
		n361	:= n345 + n353
		
		//388-A favor DGI --- 393 A FAVOR BENEFICIARIO
		nImporte:= n329 - n345
		If nImporte >= 0
			n388	:= nImporte
			n393	:= 0
		Else
			n388	:= 0
			n393	:= abs(nImporte)
		EndIf 

	    n2_434 := n2_418 + n2_426
	    n2_515 := n2_507
	    n2_620 := n2_604
	    n2_736 := n2_701
	    n2_833 := n2_809 + n2_817 + n2_825 + n2_826
	    
	    If	lEntidade == .T.  .and. !empty(cIGRR) 
	        /*
	        //Carrega informacoes DETERMINACION COMPLEMENTARIA da tabela de valores fixos.
	        */
	        cRG1_DFIMP := CtoD("01/01/"+cAno)
	        cRG1_LIBPA := CtoD("31/12/"+cAno)
	        
	 		cQuery := "SELECT "
		    cQuery += " RG1_FILIAL, RG1_MAT, RG1_PD, RG1_DFIMPG, RG1_LIBPAG, RG1_ENTIDA, RG1_IMP649, RG1_TPCALC " 
			cQuery += " FROM " + RetSqlName(cAliasRG1)
			cQuery += " WHERE "
			cQuery += " RG1_FILIAL = '"+ (cQrySRA)->RA_FILIAL + "'"
			cQuery += "  AND "
			cQuery += " RG1_MAT = '" + (cQrySRA)->RA_MAT + "'"
			cQuery += "  AND "
			cQuery += " RG1_PD IN " + cIGRR 
			cQuery += "  AND "
			cQuery += "  RG1_TPCALC IN ('1','4') "
			cQuery += "  AND "
			cQuery += " RG1_ENTIDA > SPACE(0) "
			cQuery += "  AND "
			cQuery += " ( RG1_DFIMPG >= '" + DtoS(cRG1_DFIMP) + "' "                          	
		  	cQuery += "  OR "
			cQuery += " ( RG1_DFIMPG = SPACE(0)  AND  (RG1_LIBPAG < '" + DtoS(cRG1_LIBPA) + "')) )" 
			
			If TcSrvType() == "AS/400"
				cQuery += " AND @DELETED@ = ' ' "
			Else
				cQuery += " AND D_E_L_E_T_ = ' ' "
			Endif 
			
			cQuery += " ORDER BY RG1_PD, RG1_DFIMPG DESC" 
			cQuery := ChangeQuery(cQuery)      




				
			If select(cQryRG1) > 0
					(cQryRG1)->(dbCloseArea())
			EndIf
				
			dbUseArea(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQryRG1,.T.,.T.)
			
			(cQryRG1)->(dbGoTop())
			
			/* detalhamento da colunas do array aF649
					[1]Id Rubro
					[2]Descricao Entidade
					[3]CUIT Entidade
					[4]Importe
					[5]Codigo Entidade*/

	
			//E necessario limpar o array a cada funcinario
			aF649	:= {}
				            
				
			While (cQryRG1)->(!Eof())
			    cGravaF649	:= ""
			    nPos 		:= 0
			    
				If 	((cQryRG1)->RG1_PD $ cRub11_418) 
					cGravaF649 := f830AFijo(aF649,"418", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub11_426) 
					cGravaF649 := f830AFijo(aF649,"426", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub12_507) 
					cGravaF649 := f830AFijo(aF649,"507", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub13_604) 
					cGravaF649 := f830AFijo(aF649,"604", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub13_612) 
					cGravaF649 := f830AFijo(aF649,"612", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub14_701) 
					cGravaF649 := f830AFijo(aF649,"701", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub14_728) 
					cGravaF649 := f830AFijo(aF649,"728", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub15_809) 
					cGravaF649 := f830AFijo(aF649,"809", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub15_817) 
					cGravaF649 := f830AFijo(aF649,"817", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				
				ElseIf 	((cQryRG1)->RG1_PD $ cRub15_825) 
					cGravaF649 := f830AFijo(aF649,"825", (cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA)				
				EndIf
	
				If 	!EMPTY((cQryRG1)->RG1_ENTIDAD) .and. cGravaF649 <> ""
					nPos := Ascan( aEntidades, { |X| X[1] = (cQryRG1)->RG1_ENTIDA } ) 
					If nPos <> 0 
						aAdd(aF649,{cGravaF649 , aEntidades[nPos,2],aEntidades[nPos,3],(cQryRG1)->RG1_IMP649,(cQryRG1)->RG1_ENTIDA })
					Endif
				Endif    
					
				(cQryRG1)->(dbSkip())			
		   EndDo
	    EndIf
	        
        If Select(cQryRG1) > 0
		 (cQryRG1)->(dbCloseArea())
		Endif	 
        
        
        //carrega data para ser impressa em LIQUIDACION: ANUAL/FINAL
        If StoD((cQrySRA)->RA_ADMISSA) > CtoD("01/01/" + cAno) 
        	dDataIni:= stod((cQrySRA)->RA_ADMISSA)
        Else
        	dDataIni:= CtoD("01/01/" + cAno)
        Endif
        
        If  !Empty((cQrySRA)->RA_DEMISSA) .And. StoD((cQrySRA)->RA_DEMISSA) < CtoD("31/12/" + cAno) 
        	dDataFim:= stod((cQrySRA)->RA_DEMISSA)
        Else
        	dDataFim:= CtoD("31/12/" + cAno)
        Endif  
        
		GeraAFIP() //gera primeira via
		GeraAFIP() //gera segunda via

		(cQrySRA)->(dbSkip())	
	End	

	If Select(cQrySRA) > 0
	 (cQrySRA)->(dbCloseArea())
	Endif  
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f830AFijo		³ Autor ³  Equipe RH	           ³ Data ³ 29/03/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a verificação no array de asientos fijos: 					   ³±±
±±³			 ³1- Se há necessidade de incluir um novo rubro  					   ³±±
±±³			 ³2- Se o rubro já foi gravado no array, verifica se ha necessidade de ³±±
±±³			 ³		adicionar mais valores (nValor), para compor aF649[nPos,4]	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³ExpA1 - Array com os asientos fijos, que serao impressos			   ³±±
±±³			 ³ExpC1 - Indica qual rubro sera verificado							   ³±±
±±³			 ³ExpN1 - caso necessario qual valor sera adicionado a aF649[nPos,4]   ³±±
±±³			 ³ExpC2 - Qual Entidade que estamos avaliando, para atender descricao 2³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Retorno	 ³cRet1 - Se retornar com conteudo, indica que o Array aF649 tera novo ³±±
±±³			 ³		item														   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER830															   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function f830AFijo(aF649,cRubro,  nValor, cEntidade)

Local nPos	:= aScan(aF649,{|X|X[1] == cRubro}) 
Local cGrava:=""

If (nPos = 0)	
	cGrava := cRubro
ElseIf aF649[nPos,5] == cEntidade
	aF649[nPos,4] := aF649[nPos,4]+ nValor
EndIf

Return (cGrava)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraAFIP  ºAutor  ³Erika Kanamori      º Data ³  12/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        

Static Function GeraAFIP()

Local X 			:= 0  
Local nPosImport    := 1995
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oPrint:StartPage() 			//Inicia uma nova pagina   

If File(cFigura)                               
	oPrint:SayBitmap( 0030, 0045, cFigura, 0350, 0090,,.F.) // Tem que estar abaixo do RootPath
Else
	oPrint:say ( 0035, 0110, OemToAnsi(STR0005), oFont25n ) 							//"AFIP"
endif   

oPrint:Box ( 0020, 0035, 0380, 0400 ) //BOX AFIP

oPrint:line ( 0130, 0035, 0130, 0400 )  //horizontal
oPrint:say ( 0140, 0075, "IMPUESTO A LAS", oFont11n ) 
oPrint:say ( 0170, 0100, Upper(OemToansi(STR0007))	, oFont11n )  					//"GANANCIAS"
oPrint:say ( 0200, 0090, Upper(OemToansi(STR0008))	, oFont11n ) 					//"REGIMEN DE"
oPrint:say ( 0230, 0100, Upper(OemToansi(STR0009))	, oFont11n ) 					//"RETENCION"
oPrint:say ( 0270, 0045, OemToansi(STR0010)			, oFont07n  )					//"Sueldos, Jubilaciones, etc."
oPrint:line ( 0310, 0035, 0310, 0400 )  //horizontal
oPrint:say ( 0322, 0060, Upper(OemToansi(STR0011))	, oFont08  )					//"DECLARACION JURADA"
oPrint:say ( 0347, 0060, OemToansi(STR0012)			, oFont08  )					//"En pesos con ctvs."

oPrint:Box ( 0020, 0405, 0380, 0800) //BOX Sello 
oPrint:say ( 0350, 0415, "Sello fechador de recepción", oFont06  ) 

oPrint:Box ( 0020, 0805, 0380, nColMax ) //BOX F.649
oPrint:say ( 0030, 0815, OemToansi(STR0014)			, oFont17n ) 					//"F.649"
oPrint:line ( 0020, 1000, 0100, 1000 )   //vertical
oPrint:say ( 0030, 1070, cAno, oFont11 )
oPrint:line ( 0020, 1250, 0100, 1250 )   //vertical
oPrint:say ( 0030, 1300, Upper(OemToansi(STR0015)), oFont08  ) 					//"ORIGINAL"
oPrint:Box ( 0030, 1450, 0060, 1500 )   
oPrint:say ( 0030, 1800, "RECTIFICATIVA", oFont08  ) 
oPrint:Box ( 0030, 2050, 0060, 2100 )
oPrint:say ( 0065, 1400, "(Marcar con <<X>> el cuadro que correspondiente)", oFont07  )

If nTipoRel = 1
	oPrint:say ( 0033, 1470, "X", oFont08  )
Else
	oPrint:say ( 0033, 2070, "X", oFont08  )
Endif         

oPrint:line ( 0100, 0805, 0100, nColMax )  //horizontal
oPrint:say ( 0100, 0815, OemToansi(STR0034), oFont08  )							//"Clave Única de Identificación Tributaria: "
oPrint:line ( 0100, 1610, 0170, 1610 )   //vertical
oPrint:say ( 0100, 1620, OemToansi(STR0019), oFont08  )							//"Codigo Unico de Identicacion Laboral:"
oPrint:say ( 0130, 1630, (cQrySRA)->RA_CIC, oFont10 ) 

oPrint:line ( 0170, 0805, 0170, nColMax )  //horizontal
oPrint:say ( 0170, 0815, OemToansi(STR0020)	, oFont08  )							//"Apellido y Nombres del Beneficiario:"
oPrint:say ( 0200, 0815, (cQrySRA)->RA_NOME, oFont10 )

oPrint:line ( 0240, 0805, 0240, nColMax )  //horizontal
oPrint:say ( 0240, 0815, OemToansi(STR0021), oFont08  ) 							//"Domicilio - Calle: "     
oPrint:say ( 0270, 0815, (cQrySRA)->RA_ENDEREC, oFont10 )
oPrint:line ( 0240, 1870, 0310, 1870 )   //vertical 
oPrint:line ( 0270, 1870, 0270, nColMax )  //horizontal
oPrint:say ( 0240, 1880, Upper(OemToansi(STR0022)), oFont08  ) 					//"NUMERO"
oPrint:say ( 0270, 1880, Transform(Val((cQrySRA)->RA_ENDEREC),"9999"), oFont10 )
oPrint:line ( 0240, 2010, 0310, 2010 )   //vertical
oPrint:say ( 0240, 2020, Upper(OemToansi(STR0023)), oFont08  )						//"PISO"
oPrint:say ( 0270, 2020, (cQrySRA)->RA_PISO, oFont10 )
oPrint:line ( 0240, 2140, 0310, 2140 )   //vertical
oPrint:say ( 0240, 2150, "DPTO", oFont08  )
oPrint:say ( 0270, 2150, Transform(Val((cQrySRA)->RA_COMPLEM), "9999"), oFont10 ) 

oPrint:line ( 0310, 0805, 0310, nColMax )  //horizontal
oPrint:say ( 0310, 0815, OemToansi(STR0025), oFont08  )     						//"Localidad: "
oPrint:say ( 0340, 0815, (cQrySRA)->RA_LOCALID, oFont10 )
oPrint:line ( 0310, 1450, 0380, 1450 )   //vertical
oPrint:say ( 0310, 1455, OemToansi(STR0026), oFont08  )							//"Provincia: "
oPrint:say ( 0340, 1455, FDESC("SX5","12"+(cQrySRA)->RA_ESTADO,"X5DESCRI()"), oFont10 )
oPrint:line ( 0310, 2120, 0380, 2120 )   //vertical

oPrint:say ( 0310, 2129, OemToansi(STR0027) , oFont08  ) 							//"Código Postal"
oPrint:line ( 0340, 2120, 0340, nColMax )  //horizontal
oPrint:say ( 0343, 2135, Substr(AllTrim((cQrySRA)->RA_CEP),1,1), oFont10  )
oPrint:line ( 0340, 2177, 0380, 2177 )   //vertical  
oPrint:say ( 0343, 2185, Substr(AllTrim((cQrySRA)->RA_CEP),2,1), oFont10  )
oPrint:line ( 0340, 2235, 0380, 2235 )   //vertical 
oPrint:say ( 0343, 2250, Substr(AllTrim((cQrySRA)->RA_CEP),3,1), oFont10  )
oPrint:line ( 0340, 2292, 0380, 2292 )   //vertical                         
oPrint:say ( 0343, 2310, Substr(AllTrim((cQrySRA)->RA_CEP),4,1), oFont10  )
  

oPrint:Box ( 0390, 0035, 0480, nColMax )   //BOX dependencia DGI
oPrint:say ( 0390, 0045, OemToansi(STR0028), oFont09  ) 							//"Dependencia DGI en la que se halla inscripto: "  
oPrint:say ( 0430, 0045, cDGIFunc, oFont10  )
oPrint:line ( 0390, 2090, 0480, 2090 )   //vertical
oPrint:say ( 0400, 2100, Upper(OemToansi(STR0029)), oFont10n  )					//"USO"
oPrint:say ( 0435, 2100, Upper(OemToansi(STR0030)), oFont10n  )					//"DGI"
                                               
oPrint:say ( 0390, 2200, Upper(OemToansi(STR0031)), oFont09  ) 					//"CODIGO"
oPrint:line ( 0430, 2177, 0430, nColMax )  //horizontal
oPrint:line ( 0390, 2177, 0480, 2177 )   //vertical
oPrint:line ( 0430, 2235, 0480, 2235 )   //vertical
oPrint:line ( 0430, 2292, 0480, 2292 )   //vertical

oPrint:Box ( 0490, 0035, 0750, nColMax )   //BOX DATOS
oPrint:say ( 0500, 1000, Upper(OemToansi(STR0032)), oFont12n  )  					//"DATOS DEL AGENTE DE RETENCION"

oPrint:line ( 0550, 0035, 0550, nColMax )  //horizontal
oPrint:say ( 0560, 0045, "Apellido y Nombres o Razón Social: ", oFont09  )
oPrint:say ( 0600, 0045, aInfo[3], oFont10  )
     
oPrint:line ( 0550, 0900, 0750, 0900 )   //vertical
oPrint:say ( 0560, 0910, OemToansi(STR0018), oFont09  )							//"Clave Única de Identificación Tributaria: "
oPrint:say ( 0600, 0910, aInfo[8], oFont10  )

oPrint:line ( 0550, 2070, 0750, 2070 )   //vertical
oPrint:say ( 0560, 2080,"Pagos Extraord(4)", oFont07  )  
oPrint:line ( 0600, 2070, 0600, nColMax )  //horizontal 
oPrint:say ( 0610, 2110, Upper(OemToansi(STR0037)), oFont10  )                     //"SI"
oPrint:line ( 0600, 2177, 0750, 2177 )   //vertical 
oPrint:say ( 0610, 2210, Upper(OemToansi(STR0038)), oFont10  )						//"NO"


oPrint:line ( 0660, 0900, 0660, nColMax )  //horizontal  
oPrint:say ( 0670, 0910, OemToansi(STR0035), oFont09  )							//"Dependencia DGI en la que se encuentra inscripto:"
oPrint:say ( 0710, 0910, cDGIEmp, oFont10  )

oPrint:say ( 0665, 2095, Upper(OemToansi(STR0029)), oFont10n  )                   	//"USO"
oPrint:say ( 0700, 2095, Upper(OemToansi(STR0030)), oFont10n  ) 					//"DGI"
                                               
oPrint:say ( 0668, 2200, Upper(OemToansi(STR0031)), oFont09  )						//"CODIGO"
oPrint:line ( 0700, 2177, 0700, nColMax )  //horizontal
oPrint:line ( 0700, 2235, 0750, 2235 )   //vertical
oPrint:line ( 0700, 2292, 0750, 2292 )   //vertical 
                 
oPrint:Box ( 0760, 0035, 0890, nColMax )                     
oPrint:say ( 0770, 0042, "ESTA DECLARACION JURADA DEBERA SER CONFECCIONADA POR EL AGENTE DE RETENCION, CONFORME LO DISPUESTO POR", oFont10n  )
oPrint:say ( 0800, 0042, "EL ARTICULO 18 DE LA RESOLUCION GENERAL NRO. 4139 Y DEBERA SER PRESENTADA CUANDO EL IMPORTE DEL RUBRO 3", oFont10n  ) 
oPrint:say ( 0830, 0042, "DE ESTE FORMULARIO SEA IGUAL O SUPERIOR AL IMPORTE QUE A DICHOS EFECTOS, ESTABLECE EL ART.21 DE LA MISMA.", oFont10n  ) 

oPrint:Box ( 0900, 0035, 2510, nColMax )//BOX LIQUIDACION ANUAL/FINAL
oPrint:say ( 0910, 0045, "LIQUIDACION: ANUAL/FINAL(1) Comprendida entre el", oFont10   )
oPrint:Box ( 0908, 1130, 0945, 1370 )           
oPrint:say ( 0910, 1150, Transform(Day(dDataIni),"99"), oFont10   )
oPrint:line ( 0908, 1210, 0945, 1210 )   //vertical
oPrint:say ( 0910, 1230, Transform(Month(dDataIni),"99"), oFont10   )
oPrint:line ( 0908, 1290, 0945, 1290 )   //vertical
oPrint:say ( 0910, 1310, Right(DtoC(dDataIni),2), oFont10   )

oPrint:say ( 0910, 1390, "y el", oFont10   )
oPrint:Box ( 0908, 1560, 0945, 1800 )  
oPrint:say ( 0910, 1580, Transform(Day(dDataFim),"99"), oFont10   )
oPrint:line ( 0908, 1640, 0945, 1640 )   //vertical
oPrint:say ( 0910, 1660, Transform(Month(dDataFim),"99"), oFont10   )
oPrint:line ( 0908, 1720, 0945, 1720 )   //vertical
oPrint:say ( 0910, 1740, Right(DtoC(dDataFim),2), oFont10   )


oPrint:line ( 0950, 0035, 0950, nColMax )  //horizontal
oPrint:say ( 0960, 0040, OemToansi(STR0044), oFont05   )								//"Rub."
oPrint:line ( 0950, 0085, 2510, 0085 )   //vertical  
oPrint:say ( 0960, 0090, OemToansi(STR0045), oFont05   )								//"Inc."
oPrint:line ( 0950, 0135, 2510, 0135 )   //vertical  
oPrint:say ( 0955, 0140, Upper(OemToansi(STR0046)) , oFont10 ) 						//"DETERMINACION DE LA GANANCIA NETA Y LIQUIDACION DEL IMPUESTO"
oPrint:line ( 0950, 1790, 2510, 1790 )   //vertical
oPrint:say ( 0955, 1810, Upper(OemToansi(STR0047)), oFont10   )						//"COD"
oPrint:line ( 0950, 1920, 2510, 1920 )   //vertical
oPrint:say ( 0955, 2050, "IMPORTES", oFont10   )   

oPrint:line ( 0990, 0135, 0990, nColMax )  //horizontal  
oPrint:say ( 0995, 0045, "1", oFont10   ) 
oPrint:say ( 0995, 0140, "IMPORTE BRUTO DE LAS GANANCIAS", oFont10 )
oPrint:line ( 1030, 0135, 1030, nColMax )  //horizontal
oPrint:say ( 1035, 0105, "a", oFont09   )
						
oPrint:say ( 1035, 0140, OemToansi(STR0050) , oFont09   )								//"Liquidadas por la entidad que actúa como agente de retención"
oPrint:say ( 1035, 1810, "019", oFont10   )
oPrint:say ( 1035, nPosImport, Transform(n019, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1070, 0135, 1070, nColMax )  //horizontal
oPrint:say ( 1075, 0105, "b", oFont09   ) 
oPrint:say ( 1075, 0140, OemToansi(STR0051), oFont09   ) 								//"Liquidadas por otras personas o entidades"
oPrint:line ( 1110, 0135, 1110, nColMax )  //horizontal


oPrint:say ( 1115, 0140, "Apellido y Nombres o denominación y domicilio", oFont09   )
oPrint:say ( 1155, nPosImport,Transform(n027, "99,999,999,999.99") , oFont09num   ) 

oPrint:line ( 1110, 1290, 1310, 1290 )   //vertical
oPrint:say ( 1115, 1330, "Nro. de C.U.I.T.", oFont09   ) 	
oPrint:line ( 1150, 0135, 1150, nColMax )  //horizontal 
oPrint:say ( 1155, 1810, "027", oFont10   )     

oPrint:line ( 1190, 0135, 1190, nColMax )  //horizontal
oPrint:say ( 1195, nPosImport, Transform(n035, "99,999,999,999.99") , oFont09num   )
oPrint:say ( 1195, 1810, "035", oFont10   )

oPrint:line ( 1230, 0135, 1230, nColMax )  //horizontal

oPrint:say ( 1235, nPosImport, Transform(n043, "99,999,999,999.99") , oFont09num   )	
oPrint:say ( 1235, 1810, "043", oFont10   )

oPrint:line ( 1270, 0135, 1270, nColMax )  //horizontal

oPrint:say ( 1275, nPosImport, Transform(n078, "99,999,999,999.99") , oFont09num   )
oPrint:say ( 1275, 1810, "078", oFont10   )

oPrint:line ( 1310, 0135, 1310, nColMax )  //horizontal
                                                                           
oPrint:say ( 1315, 0140, Upper(OemToansi(STR0054)), oFont10 )   						//"TOTALES DEL RUBRO 1"
oPrint:say ( 1315, 1810, "094", oFont10   )                                
oPrint:say ( 1315, nPosImport, Transform( n094, "99,999,999,999.99") , oFont09num   )    

oPrint:line ( 1350,0135, 1350, nColMax )  //horizontal
oPrint:say ( 1355, 0045, "2", oFont10   ) 
oPrint:say ( 1355, 0140, Upper(OemToansi(STR0055)) , oFont10   )						//"DEDUCCIONES Y DESGRAVACIONES"
oPrint:line ( 1390,0135, 1390, nColMax )  //horizontal
oPrint:say ( 1395, 0105, "a", oFont09   ) 
oPrint:say ( 1395, 0140, OemToansi(STR0056), oFont09   )								//"Aportes Jubilatorios"
oPrint:say ( 1395, 1810, "116", oFont10   )   
oPrint:say ( 1395, nPosImport, Transform( n116, "99,999,999,999.99") , oFont09num   )    
oPrint:line ( 1430,0135, 1430, nColMax )  //horizontal
oPrint:say ( 1435, 0105, "b", oFont09   ) 
oPrint:say ( 1435, 0140, "Aportes para obras sociales y cuotas médico asistenciales (total del rubro 11)", oFont09   )
oPrint:say ( 1435, 1810, "124", oFont10   )
oPrint:say ( 1435, nPosImport, Transform( n124, "99,999,999,999.99") , oFont09num   )    
oPrint:line ( 1470,0135, 1470, nColMax )  //horizontal
oPrint:say ( 1475, 0105, "c", oFont09   ) 
oPrint:say ( 1475, 0140, OemToansi(STR0058), oFont09   )								//"Primas de seguro para el caso de muerte (total del rubro 12)"
oPrint:say ( 1475, 1810, "132", oFont10   )
oPrint:say ( 1475, nPosImport, Transform( n132, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1510, 0135, 1510, nColMax )  //horizontal
oPrint:say ( 1515, 0105, "d", oFont09   ) 
oPrint:say ( 1515, 0140, OemToansi(STR0059), oFont09   ) 								//"Gastos de sepelio (total del rubro 13)"
oPrint:say ( 1515, 1810, "140", oFont10   )
oPrint:say ( 1515, nPosImport, Transform( n140, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1550, 0135, 1550, nColMax )  //horizontal
oPrint:say ( 1555, 0105, "e", oFont09   ) 
oPrint:say ( 1555, 0140, OemToansi(STR0060), oFont09   )								//"Gastos estimativos de corredores y viajantes de comercio (movilidad, etc.)"
oPrint:say ( 1555, 1810, "159", oFont10   )
oPrint:say ( 1555, nPosImport, Transform( n159, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1590, 0135, 1590, nColMax )  //horizontal
oPrint:say ( 1595, 0105, "f", oFont09   ) 
oPrint:say ( 1595, 0140, OemToansi(STR0061), oFont09   )								//"Otras deducciones (total del rubro 15)"
oPrint:say ( 1595, 1810, "167", oFont10   ) 
oPrint:say ( 1595, nPosImport, Transform( n167, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1630, 0135, 1630, nColMax )  //horizontal
oPrint:say ( 1635, 0140,  "TOTAL DEL RUBRO 2", oFont10   )
oPrint:say ( 1635, 0515, "(suma de los incisos a) al f) )", oFont08   ) 
oPrint:say ( 1635, 1810, "175", oFont10   )                          
oPrint:say ( 1635, nPosImport, Transform( n175, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1670, 0135, 1670, nColMax )  //horizontal
oPrint:say ( 1675, 0045, "3", oFont10   ) 
oPrint:say ( 1675, 0140, Upper(OemToansi(STR0063)), oFont10   ) 						//"RESULTADO NETO" 
oPrint:say ( 1675, 0468, "(Diferencia entre el rubro 1 y el rubro 2)", oFont08   )
oPrint:say ( 1675, 1810, "183", oFont10   )
oPrint:say ( 1675, nPosImport, Transform( n183, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1710, 0135, 1710, nColMax )  //horizontal
oPrint:say ( 1715, 0045, "4", oFont10   ) 
oPrint:say ( 1715, 0140, Upper(OemToansi(STR0064)), oFont10   ) 						//"DONACIONES"
oPrint:say ( 1715, 0405, "(Hasta el límite del 5% del rubro 3)", oFont08) 
oPrint:say ( 1715, 1810, "191", oFont10   )
oPrint:say ( 1715, nPosImport, Transform( n191, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1750, 0135, 1750, nColMax )  //horizontal
oPrint:say ( 1755, 0045, "5", oFont10   )
oPrint:say ( 1755, 0140, Upper(OemToansi(STR0065)), oFont10   )						//"DIFERENCIA"
oPrint:say ( 1755, 0405, "(Rubro 3 menos rubro 4)", oFont08   )
oPrint:say ( 1755, 1810, "205", oFont10   )                            
oPrint:say ( 1755, nPosImport, Transform( n205, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1790, 0135, 1790, nColMax )  //horizontal
oPrint:say ( 1795, 0045, "6", oFont10   )
oPrint:say ( 1795, 0140, Upper(OemToansi(STR0066)), oFont10   ) 						//"DEDUCCION ESPECIAL, GANANCIAS NO IMPONIBLES Y CARGAS DE FAMILIA"
oPrint:line ( 1830, 0135, 1830, nColMax )  //horizontal
oPrint:say ( 1835, 0105, "a", oFont09   ) 
oPrint:say ( 1835, 0140, OemToansi(STR0067), oFont09 )									//"Deducción Especial"
oPrint:say ( 1835, 1810, "213", oFont10   )
oPrint:say ( 1835, nPosImport, Transform( n213, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1870, 0135, 1870, nColMax )  //horizontal
oPrint:say ( 1875, 0105, "b", oFont09   ) 
oPrint:say ( 1875, 0140, "Ganancia no imponible", oFont09 ) 
oPrint:say ( 1875, 1810, "221", oFont10   )
oPrint:say ( 1875, nPosImport, Transform( n221, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 1910, 0135, 1910, nColMax )  //horizontal
oPrint:say ( 1915, 0105, "c", oFont09   ) 
oPrint:say ( 1915, 0140, OemToansi(STR0069), oFont09   )								//"Cargas de familia (6)"
oPrint:line ( 1950, 0135, 1950, nColMax )  //horizontal
oPrint:say ( 1955, 0150, OemToansi(STR0070), oFont09   ) 								//"Conyuge"
oPrint:say ( 1955, 1810, "256", oFont10   )
oPrint:say ( 1955, nPosImport, Transform( n256, "99,999,999,999.99") , oFont09num   )    
oPrint:line ( 1990, 0135, 1990, nColMax )  //horizontal
oPrint:say ( 1995, 0150, OemToansi(STR0071), oFont09   )								//"Hijos"
oPrint:say ( 1995, 1810, "264", oFont10   )
oPrint:say ( 1995, nPosImport, Transform( n264, "99,999,999,999.99") , oFont09num )
oPrint:line ( 2030, 0135, 2030, nColMax )  //horizontal
oPrint:say ( 2035, 0140, OemToansi(STR0072), oFont09 )									//"Otras cargas"
oPrint:say ( 2035, 1810, "272", oFont10   )
oPrint:say ( 2035, nPosImport, Transform( n272, "99,999,999,999.99") , oFont09num   )    
oPrint:line ( 2070, 0135, 2070, nColMax )  //horizontal
oPrint:say ( 2075, 0140, Upper(OemToansi(STR0073)), oFont10   ) 						//"TOTALES DEL RUBRO 6"
oPrint:say ( 2075, 0555, "(suma de los incisos a), b) y c))", oFont08   ) 
oPrint:say ( 2075, 1810, "302", oFont10   )                            
oPrint:say ( 2075, nPosImport, Transform( n302, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2110, 0135, 2110, nColMax )  //horizontal
oPrint:say ( 2115, 0045, "7", oFont10   ) 
oPrint:say ( 2115, 0140, "GANANCIAS NETAS SUJETAS A IMPUESTO", oFont10   )
oPrint:say ( 2115, 0885, "(diferencia entre el rubro 5 y 6)", oFont08   )
oPrint:say ( 2115, 1810, "310", oFont10   )
oPrint:say ( 2115, nPosImport, Transform( n310, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2150, 0135, 2150, nColMax )  //horizontal
oPrint:say ( 2155, 0045, "8", oFont10   ) 
oPrint:say ( 2155, 0140, Upper(OemToansi(STR0075)), oFont10   )						//"TOTAL DEL IMPUESTO DETERMINADO"
oPrint:say ( 2155, 1810, "329", oFont10   )
oPrint:say ( 2155, nPosImport, Transform( n329, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2190, 0135, 2190, nColMax )  //horizontal
oPrint:say ( 2195, 0140, "MONTOS COMPUTABLES", oFont10 )  
oPrint:say ( 2195, 0045, "9", oFont10   ) //"MONTOS COMPUTABLES"
oPrint:line ( 2230, 0135, 2230, nColMax )  //horizontal
oPrint:say ( 2235, 0105, "a", oFont09   ) 
oPrint:say ( 2235, 0140, OemToansi(STR0077), oFont09   )								//"Retenciones efectuadas en el periodo fiscal que se liquida"
oPrint:say ( 2235, 1810, "345", oFont10   )                            
oPrint:say ( 2235, nPosImport, Transform( n345, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2270, 0135, 2270, nColMax )  //horizontal
oPrint:say ( 2275, 0140, OemToansi(STR0078), oFont09   ) 								//"Regimenes de promocion (Rebaja de Impuesto, Diferimiento u otros)"
oPrint:say ( 2275, 0105, "b", oFont08   )
oPrint:say ( 2275, 1810, "353", oFont10   )
oPrint:say ( 2275, nPosImport, Transform( n353, "99,999,999,999.99") , oFont09num   )     
oPrint:line ( 2310, 0135, 2310, nColMax )  //horizontal
oPrint:say ( 2315, 0140, Upper(OemToansi(STR0079)) , oFont10 )							//"TOTALES DEL RUBRO 9"
oPrint:say ( 2315, 0588, "(suma de los incisos a) y b))", oFont08) 
oPrint:say ( 2315, 1810, "361", oFont10   )                                    
oPrint:say ( 2315, nPosImport, Transform( n361, "99,999,999,999.99") , oFont09num )
oPrint:line ( 2350, 0135, 2350, nColMax )  //horizontal                        
oPrint:say ( 2355, 0040, "10", oFont10   ) 
oPrint:say ( 2355, 0140, Upper(OemToansi(STR0080)), oFont10) 							//"SALDO DEL IMPUESTO"
oPrint:say ( 2355, 0568, "(Diferencia entre el rubro 8 y rubro 9)", oFont08 )
oPrint:line ( 2390, 0135, 2390, nColMax )  //horizontal
oPrint:say ( 2395, 0105, "a", oFont09   ) 
oPrint:say ( 2395, 0140, OemToansi(STR0081), oFont09 )									//"A favor D.G.I."
oPrint:say ( 2395, 1810, "388", oFont10   )                            
oPrint:say ( 2395, nPosImport, Transform( n388, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2430, 0135, 2430, nColMax )  //horizontal
oPrint:say ( 2435, 0105, "b", oFont09   ) 
oPrint:say ( 2435, 0140, "A favor Beneficiario", oFont09   )
oPrint:say ( 2435, 1810, "393", oFont10   )                            
oPrint:say ( 2435, nPosImport, Transform( n393, "99,999,999,999.99") , oFont09num   )
oPrint:line ( 2470, 0135, 2470, nColMax )  //horizontal
oPrint:say ( 2475, 0140, "O sea pesos", oFont09   )

oPrint:EndPage()
oPrint:StartPage()

oPrint:Box ( 0050, 0035, 1130, nColMax )//BOX
oPrint:say ( 0060, 0040, OemToansi(STR0044), oFont05   )								//"Rub."
oPrint:line ( 0050, 0085, 1130, 0085 )   //vertical  
oPrint:say ( 0060, 0090, OemToansi(STR0045), oFont05   )								//"Inc."
oPrint:line ( 0050, 0135, 1130, 0135 )  //vertical  
oPrint:say ( 0055, 0140, Upper(OemToansi(STR0084)), oFont10 ) 							//"DETERMINACION COMPLEMENTARIA"
oPrint:line ( 0050, 1790, 1130, 1790 )   //vertical
oPrint:say ( 0055, 1810, Upper(OemToansi(STR0047)), oFont10   ) 						//"COD"
oPrint:line ( 0050, 1920, 1130, 1920 )   //vertical
oPrint:say ( 0055, 2050, "IMPORTES", oFont10   )
//oPrint:line ( 0050, nColMax - 80, 1090, nColMax - 80 )   //vertical

oPrint:line ( 0090, 0135, 0090, nColMax )  //horizontal      
oPrint:say ( 0095, 0040, "11", oFont10   ) 
oPrint:say ( 0095, 0140, "CUOTAS MEDICO ASISTENCIALES", oFont10   )
oPrint:line ( 0130, 0135, 0130, nColMax )  //horizontal      
oPrint:say ( 0135, 0140, "Denominación y domicilio de la empresa asistencial", oFont09   )
oPrint:line ( 0135, 1290, 0250, 1290 )   //vertical
oPrint:say ( 0135, 1330, "Nro. de C.U.I.T.", oFont09   )
oPrint:line ( 0170, 0135, 0170, nColMax )  //horizontal      
oPrint:say ( 0175, 0105, "a", oFont09   ) 

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "418" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
oPrint:say ( 0175, nPosImport, Transform( n2_418, "99,999,999,999.99") , oFont09num   ) 
	IF (n2_418 > 0)
		oPrint:say ( 0175, 0140, Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[1][1]),"",aEntidad2[1][1]) , oFont09   )
	EndIf 

ELSEIf (nPos > 0)
	oPrint:say ( 0175, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0175, 1330, aF649[nPos,3] , oFont09   )
Endif

oPrint:say ( 0175, 1810, "418", oFont10   )
oPrint:line ( 0210, 0135, 0210, nColMax )  //horizontal      

oPrint:say ( 0215, 0105, "b", oFont09   ) 


nPos := 0
nPos := ascan(aF649,{|X|X[1] = "426" } )
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
oPrint:say ( 0215, nPosImport, Transform( n2_426, "99,999,999,999.99") , oFont09num   ) 
oPrint:say ( 0255, nPosImport, Transform( n2_434, "99,999,999,999.99") , oFont09num   )
	IF (n2_426 > 0)
			oPrint:say ( 0215, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[2][1]),"",aEntidad2[2][1]) , oFont09   )			
	EndIf 

ELSEIf (nPos > 0)
	oPrint:say ( 0215, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0215, 1330, aF649[nPos,3] , oFont09   )
Endif


oPrint:say ( 0215, 1810, "426", oFont10   ) 

oPrint:line ( 0250, 0135, 0250, nColMax )  //horizontal      
oPrint:say ( 0255, 0140, OemToansi(STR0087), oFont09   ) 								//"Total del rubro 11"
oPrint:say ( 0255, 1810, "434", oFont10   )                         

oPrint:line ( 0290, 0135, 0290, nColMax )  //horizontal      
oPrint:say ( 0295, 0040, "12", oFont10   ) 
oPrint:say ( 0295, 0140, Upper(OemToansi(STR0088)) , oFont10   ) 						//"PRIMAS DE SEGURO"
oPrint:line ( 0330, 0135, 0330, nColMax )  //horizontal      
oPrint:say ( 0335, 0140, OemToansi(STR0086), oFont09   )								//"Denominacion y domicilio de la Cia.Aseguradora"
oPrint:line ( 0335, 1290, 0410, 1290 )   //vertical
oPrint:say ( 0335, 1330, "Nro. de C.U.I.T.", oFont09   )
oPrint:line ( 0370, 0135, 0370, nColMax )  //horizontal      
oPrint:say ( 0375, 0105, "a", oFont09   ) 

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "507" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0375, nPosImport, Transform( n2_507, "99,999,999,999.99") , oFont09num   ) 
	oPrint:say( 0415, nPosImport, Transform( n2_515, "99,999,999,999.99") , oFont09num )
	If (n2_507 >0)
			oPrint:say ( 0375, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[3][1]),"",aEntidad2[3][1]), oFont09   )
	EndIf 

ElseIf (nPos > 0)
	oPrint:say ( 0375, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0375, 1330, aF649[nPos,3] , oFont09   )
Endif

oPrint:say ( 0375, 1810, "507", oFont10   ) 

oPrint:line ( 0410, 0135, 0410, nColMax )  //horizontal      
oPrint:say ( 0415, 0105, "b", oFont09   ) 
oPrint:say ( 0415, 0140, OemToansi(STR0090), oFont09 )									//"Total del rubro 12"
oPrint:say ( 0415, 1810, "515", oFont10   )                            

oPrint:line ( 0450, 0135, 0450, nColMax )  //horizontal      

oPrint:say ( 0455, 0040, "13", oFont10   ) 
oPrint:say ( 0455, 0140, Upper(OemToansi(STR0091)), oFont10 )							//"GASTOS DE SEPELIO"

oPrint:line ( 0490, 0135, 0490, nColMax )  //horizontal      

oPrint:say ( 0495, 0140, "Denominación y domicilio de la Empresa", oFont08)

oPrint:line ( 0490, 0845, 0610, 0845 )   //vertical

oPrint:say ( 0495, 0850, "Nro.de C.U.I.T." 	, oFont08 ) 
oPrint:line ( 0490, 1195, 0610, 1195 )   //vertical Gasto Total
oPrint:say ( 0495, 1200, "Gasto Total", oFont08)

oPrint:line ( 0490, 1555, 0610, 1555 )   //vertical
oPrint:say ( 0495, 1560, OemToansi(STR0094), oFont08  )								//"Importe Diferido"

oPrint:line ( 0530, 0135, 0530, nColMax )  //horizontal   
oPrint:say ( 0535, 0105, "a", oFont09   ) 

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "604" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
oPrint:say ( 0535, nPosImport, Transform( n2_604, "99,999,999,999.99") , oFont09num   ) 
	IF n2_604 > 0
		oPrint:say ( 0535, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[4][1]),"",aEntidad2[4][1]), oFont09   )
	EndIf 

ElseIf (nPos > 0)
	oPrint:say ( 0535, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0535, 0850, aF649[nPos,3] , oFont09   )
	oPrint:say ( 0535, 1285, Transform(aF649[nPos,4], "99,999,999.99") , oFont09num   )
Endif

oPrint:say ( 0535, 1810, "604", oFont10   ) 

oPrint:line ( 0570, 0135, 0570, nColMax )  //horizontal
oPrint:say ( 0575, 0105, "b", oFont09   )   

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "612" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0575, nPosImport, Transform( n2_612, "99,999,999,999.99") , oFont09num   )
	oPrint:say ( 0615, nPosImport, Transform( n2_620, "99,999,999,999.99") , oFont09num   )
ElseIf (nPos > 0)
	oPrint:say ( 0575, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0575, 0850, aF649[nPos,3] , oFont09   )
	oPrint:say ( 0575, 1285, Transform(aF649[nPos,4], "99,999,999.99") , oFont09num   )
Endif


oPrint:say ( 0575, 1810, "612", oFont10   )   

oPrint:line ( 0610, 0135, 0610, nColMax )  //horizontal      
oPrint:say ( 0615, 0140, OemToansi(STR0095), oFont09 )								//"Total del rubro 13"
oPrint:say ( 0615, 1810, "620", oFont10   )                            
oPrint:line ( 0650, 0135, 0650, nColMax )  //horizontal      
oPrint:say ( 0655, 0040, "14", oFont10   )
oPrint:say ( 0655, 0140, UPPER(OemToansi(STR0096)), oFont10   ) 					//"DONACIONES"
oPrint:line ( 0690, 0135, 0690, nColMax )  //horizontal      
oPrint:say ( 0695, 0140, OemToansi(STR0097), oFont08)								//"Entidad Beneficiaria y domicilio"

oPrint:line ( 0690, 0845, 0810, 0845 )   //vertical
oPrint:say ( 0695, 0850, "Nro.de C.U.I.T.", oFont08)  
oPrint:line ( 0690, 1195, 0810, 1195 )   //vertical
oPrint:say ( 0695, 1200, OemToansi(STR0093), oFont08   )							//"Importe Total"

oPrint:line ( 0690, 1555, 0810, 1555 )   //vertical
oPrint:say ( 0695, 1560, OemToansi(STR0094), oFont08   )							//"Importe Diferido"

oPrint:line ( 0730, 0135, 0730, nColMax )  //horizontal      
oPrint:say ( 0735, 0105, "a", oFont09   ) 


nPos := 0
nPos := ascan(aF649,{|X|X[1] = "701" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0735, nPosImport, Transform( n2_701, "99,999,999,999.99") , oFont09num   )
	If n2_701 > 0 
		oPrint:say ( 0735, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[5][1]),"",aEntidad2[5][1]), oFont09   ) 
	EndIf

ElseIf (nPos > 0)
	oPrint:say ( 0735, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0735, 0850, aF649[nPos,3] , oFont09   )
	oPrint:say ( 0735, 1285, Transform(aF649[nPos,4], "99,999,999.99") , oFont09num   )
Endif

oPrint:say ( 0735, 1810, "701", oFont10   ) 

oPrint:line ( 0770, 0135, 0770, nColMax )  //horizontal      
oPrint:say ( 0775, 0105, "b", oFont09   )

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "728" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0770, nPosImport, Transform( n2_728, "99,999,999,999.99") , oFont09num   ) 
	oPrint:say ( 0815, nPosImport, Transform( n2_736, "99,999,999,999.99") , oFont09num   )

ElseIf (nPos > 0)
	oPrint:say ( 0775, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0775, 0850, aF649[nPos,3] , oFont09   )
	oPrint:say ( 0775, 1285, Transform(aF649[nPos,4], "99,999,999.99") , oFont09num   )
Endif

oPrint:say ( 0770, 1810, "728", oFont10   ) 

oPrint:line ( 0810, 0135, 0810, nColMax )  //horizontal      
oPrint:say ( 0815, 0140, OemToansi(STR0098), oFont09   )							//"Total del rubro 14"
oPrint:say ( 0815, 1810, "736", oFont10   )                            
oPrint:line ( 0850, 0135, 0850, nColMax )  //horizontal      
oPrint:say ( 0855, 0040, "15", oFont10   ) 
oPrint:say ( 0855, 0140, UPPER(OemToansi(STR0099)) , oFont10 )						//"OTRAS DEDUCCIONES"
oPrint:line ( 0890, 0135, 0890, nColMax )  //horizontal      
oPrint:say ( 0895, 0140, "Norma Legal y concepto", oFont09   ) 

oPrint:line ( 0890, 1395, 1050, 1395 )   //vertical
oPrint:say ( 0895, 1500, "Monto Total", oFont08 )
	
oPrint:line ( 0930, 0135, 0930, nColMax )  //horizontal      
oPrint:say ( 0935, 0105, "a", oFont09   ) 

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "809" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0935, nPosImport, Transform( n2_809, "99,999,999,999.99") , oFont09num   )
	IF n2_809 > 0
			oPrint:say ( 0935, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[6][1]),"",aEntidad2[6][1]), oFont09   ) 
	EndIf
	     
ELSEIf (nPos > 0)
	oPrint:say ( 0935, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0935, 1480, Transform(aF649[nPos,4], "999,999,999.99") , oFont09num   )
Endif

//oPrint:line ( 0930, 1760, 1050, 1760 )   //vertical
oPrint:say ( 0935, 1810, "809", oFont10   )        

oPrint:line ( 0970, 0135, 0970, nColMax )  //horizontal   
                
oPrint:say ( 0975, 0105, "b", oFont09   ) 

nPos := 0
nPos := ascan(aF649,{|X|X[1] = "817" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 0970, nPosImport, Transform( n2_817, "99,999,999,999.99") , oFont09num   )
	If n2_817 > 0
		oPrint:say ( 0975, 0140, Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[7][1]),"",aEntidad2[7][1]) , oFont09   )
	EndIF 
ElseIf (nPos > 0)
	oPrint:say ( 0975, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 0975, 1480, Transform(aF649[nPos,4], "999,999,999.99") , oFont09num   )
Endif


oPrint:say ( 0970, 1810, "817", oFont10   ) 

oPrint:line ( 1010, 0135, 1010, nColMax )  //horizontal 

oPrint:say ( 1015, 0105, "c", oFont09   )      


nPos := 0
nPos := ascan(aF649,{|X|X[1] = "825" } ) 
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
	oPrint:say ( 1015, nPosImport, Transform( n2_825 , "99,999,999,999.99") , oFont09num   )
	If n2_825 > 0 
		oPrint:say ( 1015, 0140,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[8][1]),"",aEntidad2[8][1]), oFont09   )
	EndIf

elseIf (nPos > 0)
	oPrint:say ( 1015, 0140, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 1015, 1480, Transform(aF649[nPos,4], "999,999,999.99") , oFont09num   )
Endif

oPrint:say ( 1015, 1810, "825", oFont10 )

oPrint:line ( 1050, 0135, 1050, nColMax )  //horizontal  
 nPos := 0
nPos := ascan(aF649,{|X|X[1] = "826" } )
IF SRV->(fieldPOS("RV_CODIGR2")) > 0	
oPrint:say ( 1055, 0105, "d", oFont09   )      
oPrint:say ( 1055, 1810, "826", oFont10 )
oPrint:say ( 1055, nPosImport, Transform( n2_826, "99,999,999,999.99") , oFont09num   )
	If n2_826 > 0
		oPrint:say ( 1055, 0135,Iif(Empty(aEntidad2) .OR. Empty(aEntidad2[9][1]),"",aEntidad2[9][1]), oFont09   )
	EndIf
	
 elseIf (nPos > 0)
	oPrint:say ( 1085, 0135, aF649[nPos,2] , oFont09   ) 
	oPrint:say ( 1085, 1480, Transform(aF649[nPos,4], "999,999,999.99") , oFont09num   )
	
Endif
 //////////////
oPrint:line ( 1090, 0140, 1090, nColMax )  //horizontal 
oPrint:say ( 1095, 0140, "Total del rubro 15 (suma de los inc. a), b), c) y d) )" , oFont09   )
oPrint:say ( 1095, 1810, "833", oFont10   )                                     
oPrint:say ( 1095, nPosImport, Transform( n2_833 , "99,999,999,999.99") , oFont09num   )
oPrint:Box ( 1140, 0035, 1340, nColMax )//BOX observaciones
oPrint:say ( 1150, 0045, "OBSERVACIONES", oFont09   )
oPrint:say ( 1190, 0080, cObserva1, oFont09   )
oPrint:say ( 1230, 0080, cObserva2, oFont09   )

oPrint:Box ( 1350, 0035, 1580, nColMax )//BOX El que suscribe......
oPrint:say ( 1360, 0045, "El que suscribe, Don" + " " + Replicate("_",35) + " " + "en su carácter de (2)" , oFont09 )
oPrint:say ( 1360, 0360, cRepLegal , oFont08   )
oPrint:say ( 1400, 0045, Replicate("_",30) + " " + "de la entidad que actua como agente de retencion,", oFont09   )
oPrint:say ( 1400, 0045, cCargoRep, oFont08   )
oPrint:say ( 1440, 0045, "declara bajo juramento que para el cálculo de las retenciones  relativas  al ", oFont09   )
oPrint:say ( 1480, 0045, "periodo fiscal ________ han sido consideradas las normas legales,reglamentarias y", oFont09   )
oPrint:say ( 1480, 0270, cAno, oFont08   )
oPrint:say ( 1520, 0045, "complementarias en vigencia.", oFont09   )
 
oPrint:line ( 1350, 1730, 1570, 1730 )   //vertical
oPrint:say ( 1360, 1740, "Lugar y fecha: ", oFont08   )
oPrint:say ( 1450, 1740, "Firma y sello del agente de retención: ", oFont08   )

oPrint:Box ( 1580, 0035, 1720, nColMax )//BOX A los efectos...
oPrint:say ( 1590, 0045, "A los efectos de cumplimentar lo dispuesto por el artículo 6 de la Resolución", oFont09   )    
oPrint:say ( 1630, 0045, "General N?_________ el dia ____ del mes ___________ de ______  reintegrare al", oFont09   )
oPrint:say ( 1630, 0220, cNumResol, oFont08   )
oPrint:say ( 1630, 0485, Transform(Day(dDataBase),"99"), oFont08   )
oPrint:say ( 1630, 0685, MesExtenso(Month(dDataBase)), oFont08   )
oPrint:say ( 1630, 0945, Transform(Year(dDataBase),"9999"), oFont08   )
oPrint:say ( 1670, 0045, "agente de retencion, el original y una copia (3) debidamente suscriptas.", oFont09   )

oPrint:line ( 1580, 1730, 1720, 1730 )   //vertical       
oPrint:say ( 1590, 1740, "Firma del beneficiario:", oFont08   )

oPrint:Box ( 1730, 0035, 1910, nColMax )//BOX 
oPrint:say ( 1740, 0045, "Declaro que los datos consignados en este formulario son correctos y completos y", oFont09  )
oPrint:say ( 1780, 0045, "que he confeccionado la  presente  sin  omitir  ni  falsear  dato  alguno  que ", oFont09 )
oPrint:say ( 1820, 0045, "deba contener, siendo fiel expresion de la verdad.", oFont09   )

oPrint:line ( 1730, 1730, 1910, 1730 )   //vertical
oPrint:say ( 1740, 1740, "Lugar y fecha: ", oFont08   )
oPrint:say ( 1805, 1740, "Firma y sello del agente de retención: ", oFont08   )
                                                                
oPrint:say ( 1920, 0045, "(1) Testar lo que no corresponda.", oFont09   )
oPrint:say ( 1960, 0045, "(2) Presidente, gerente u otro responsable.", oFont09   )
oPrint:say ( 2000, 0045, "(3) Testar cuando no corresponda.", oFont09   )
oPrint:say ( 2040, 0045, "(4) Marcar con x el cuadro que responda.", oFont09   )
oPrint:EndPage()  

Return         