#INCLUDE "PROTHEUS.CH"   
#INCLUDE "gpem883.ch"  
#DEFINE   nColMax	2450   
#DEFINE   nLinMax	2900   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEM883   ºAutor  ³Ivan M. Gomez       º Data ³  26/07/16       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera el Informe Anual de Ganancias                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Generico                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³    ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador  ³ Data    ³FNC/PLANO³  Motivo da Alteracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º				³		  ³         ³									      º±±
±±º				³		  ³			³										  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
*/      

Function GPEM883()       
                            
Local aArea		:= GetArea()
Local bProc := {|oSelf| fGPR883(oSelf) }    

oProcess := tNewProcess():New("GPEM883",OemtoAnsi(STR0037),bProc,OemtoAnsi(STR0036),"GPEM883",,,,,.T.,.T. ) 
RestArea(aArea)

Return          



Static Function fGPR883(oProcess)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
?Define Variaveis Private(Basicas)                            ?
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cPerg   	:= "GPEM883"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
?Variaveis Utilizadas na funcao IMPR                          ?
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cProcedi	:= ""
Private cProcesso	:= ""
Private cPeriodo	:= ""
Private cNumdPago	:= ""
Private cMatDe	:= ""
Private cMatAte	:= "" 
Private cLugar	:= ""
Private dFecha	:= ""
Private cCargo	:= ""
Private cDeclaJu	:= ""
Private cTipoDe	:= ""
Private cFilialDe   := "" 

pergunte(cPerg,.F.)  


cProcesso		:= mv_par01
cProcedi		:= mv_par02
cPeriodo		:= mv_par03
cNumdPago		:= mv_par04
cMatDe			:= mv_par05
cMatAte		:= mv_par06
cLugar			:= mv_par07
dFecha			:= mv_par08
cCargo			:= mv_par09
cDeclaJu		:= mv_par10
cTipoDe		:= mv_par11





//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( oemtoansi(STR0001))					//"AFIP - Impuesto a Las Ganancias Regimen de Retencion"

oPrint:SetPortrait()

IMPBOL883(oProcess) 
oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir
                                                                       
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³IMPBOL    ºAutor  ³Erika Kanamori      ?Data ? 01/03/08   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?                                                           º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?AP                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
 
Static Function IMPBOL883(oProcess) 

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPEM883" , "SRA", "2" ) + " } " )     
Local cFilAnt		:= "" 
Local nAux, nPos	:= 0     
Local aEmpresas		:= {}
Local nEmpDe
Local cProcFunc		:= ""
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
?Variaveis para controle em ambientes TOP.                    ?
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 

Local cQuery
Local aPerAbe		:= {}
Local aPerFec 	:= {}
Local aPerTodos 	:= {}   

Private cQrySRA := "SRA"    
Private cAlias	:= "SRA"                          
Private n1a := n1b := n1c := n1d := 0				//Variaveis que serao impressas na secao 1
Private n2a := n2b := n2c := n2d := 0				//Variaveis que serao impressas na secao 2
Private n2e := n2f := n2g := n2h := 0				//Variaveis que serao impressas na secao 2
Private n2a := n2i := n2j := n2k := 0				//Variaveis que serao impressas na secao 2
Private n2l := n2m := n2n := n2o := 0				//Variaveis que serao impressas na secao 2
Private n2p := n2q := 0	       					//Variaveis que serao impressas na secao 2
Private n3a := n3b := n3c := n3d := n3e := 0		//Variaveis que serao impressas na secao 3
Private n4a := n4b := n4c := n4d := n4e := 0	   //Variaveis que serao impressas na secao 4

Private nSum1 := 0		// Suma Sección 1
Private nSum2 := 0		// Suma Sección 2
Private nSum3 := 0		// Suma Sección 3

Private aInfo			:= {} 
Private aVerbas		:= {}
Private aVerbasFunc	:= {} 
Private aEntidades	:= {}
Private aEntidad2		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private  oFont09, oFont25n, oFont11n, oFont12n, oFont09num, oFont20n 

oFont09		:= TFont():New("Arial",10,09,,.F.,,,,.T.,.F.) 
oFont11		:= TFont():New("Arial",11,10,,.F.,,,,.T.,.F.) 

oFont09num	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.) 	//Fonte exclusiva para valores e manter o alinhamento dos mesmos
oFont11n	:= TFont():New("Arial",11,9.5,,.T.,,,,.T.,.F.)     	//Negrito//
oFont12n	:= TFont():New("Arial",12,11,,.T.,,,,.T.,.F.)     	//Negrito//
oFont20n	:= TFont():New("Arial",20,19,,.T.,,,,.T.,.F.)     	//Negrito//
oFont25n	:= TFont():New("Arial",25,24,,.T.,,,,.T.,.F.)     	//Negrito//


	aEmpresas	:= FwAllFilial(,,,.F.)	// seleção de todas filiais de todas empresas
	nEmpDe		:= iif(aScan(aEmpresas,cFilialDe)==0,1,aScan(aEmpresas,cFilialDe))  
	cFilialDe	:= aEmpresas[nEmpDe]
	
		//parametro periodo
	cMes := Substr( alltrim(cPeriodo),5,2)
	cAno := Substr( alltrim(cPeriodo),1,4)
		
		fRetPerComp( 	cMes		  	,;		// Obrigatorio - Mes para localizar as informacoes
						cAno		  	,;		// Obrigatorio - Ano para localizar as informacoes
						xFilial("RCH")	,;		 // Opcional - Filial a Pesquisar
						  		,;		// Opcional - Filtro por Processo
				    	          		,;		// Opcional - Filtro por Roteiro
						@aPerAbe	  	,;		// Por Referencia - Array com os periodos Abertos
						@aPerFec, 		;		// Por Referencia - Array com os periodos Fechados
						@aPerTodos   	;		// Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente
				 )

	
	If (len(aPerTodos) <= 0)
		Alert(OemToAnsi(STR0038)+ " " + OemToAnsi(STR0039))			//"Não existem períodos válidos para a data informada." #### "O relatório não poder?ser gerado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		return 
	Endif   
	
		/*  
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	?Carrega CUIT e nome das entidades de deduccion               ?
	?aEntidades: 1- codigo  2- entidade   3- CUIT                 ?
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

	dbSelectArea("RCC")    
   	dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
	dbSeek(xFilial("RCC")+"S043")  
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S043" 
		IF  (RCC->RCC_CODIGO == "S043" ) .And. (RCC->RCC_FILIAL == XFilial() ) 
			aAdd(aEntidad2, {alltrim(Substr(RCC->RCC_CONTEU,4,150))} )
		ENDIF
	dbSkip()	
	EndDo
	
	If (len(aEntidad2) <= 0)
		Alert(OemToAnsi(STR0040)+ " " + OemToAnsi(STR0039))			//"Verifique, no hay datos de la tabla S043" #### "O relatório não poder?ser gerado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		return 
	Endif 


	cProcFunc := "(" + "'"+alltrim(cProcesso)+"'"+")"		
		//montagem da query
	cQuery := "SELECT "
    cQuery += " RA_FILIAL,RA_CIC,RA_NOME,RA_MAT,"
  	cQuery += " RA_ENDEREC,RA_CEP,RA_LOCALID,RA_ESTADO,RA_PROCES "
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_PROCES IN " + cProcFunc
	
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
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Carrega Regua de Processamento                               ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetPrc(0,0)      

	nCountSRA := (cQrySRA)->(RecCount())
	oProcess:SetRegua1(nCountSRA)
		 
	While (cQrySRA)->(!Eof()) 
	  
		 n1a := n1b := n1c := n1d := 0				//Variaveis que serao impressas na secao 1
		 n2a := n2b := n2c := n2d := 0				//Variaveis que serao impressas na secao 2
		 n2e := n2f := n2g := n2h := 0				//Variaveis que serao impressas na secao 2
		 n2a := n2i := n2j := n2k := 0				//Variaveis que serao impressas na secao 2
		 n2l := n2m := n2n := n2o := 0				//Variaveis que serao impressas na secao 2
		 n2p := n2q := 0	       					//Variaveis que serao impressas na secao 2
		 n3a := n3b := n3c := n3d := n3e := 0		//Variaveis que serao impressas na secao 3
		 n4a := n4b := n4c := n4d := n4e := 0	   //Variaveis que serao impressas na secao 4
		nSum1 := 0		// Suma Sección 1
		nSum2 := 0		// Suma Sección 2
		nSum3 := 0		// Suma Sección 3
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Consiste Parametrizacao do Intervalo de Impressao            ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 
		If  (((cQrySRA)->RA_MAT < cMatDe)   .Or. ((cQrySRA)->RA_MAT > cMatAte))

			(cQrySRA)->(dbSkip())		
			Loop
		EndIf     
		 
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		³Consiste Filiais e Acessos                                             ?
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?*/
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
											cProcedi				        ,; 	// Retorna todos os Roteiro 
											aVerbas 	  					,; 	// Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
											aPerAbe		  					,; 	// Array com os Periodos e Numero de pagamento abertos
											aPerFec		 	 				,;  // Array com os Periodos e Numero de pagamento fechados
											cNumdPago						)  //Pago 

		If Len(aVerbasFunc) < 1 
 			(cQrySRA)->( dbSkip() )
 	    	Loop
 		Endif
 		 
 		lAcrGan := .F.
		
		//busca verbas acumuladas para cada funcionário	   
		cProcesso := (cQrySRA)->RA_PROCES 			
     
        //calcula os valores a serem impressos no relatorio
        For nAux := 1 to len(aVerbasFunc) 
        
       	    //TOTALES RUBRO 1 	    
       	If UPPER(alltrim(aVerbasFunc[nAux][20])) == "1A"        	    
       	       n1a += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "1B"        
       	    	n1b += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "1C"		
       	    	n1c += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "1D"		
       	    	n1d += aVerbasFunc[nAux][7]
    	    	
			
			//TOTALES RUBRO 2
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2A"        	    
       	       n2a += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2B"        
       	    	n2b += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2C"		
       	    	n2c += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2D"		
       	    	n2d += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2E"        	    
       	       n2e += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2F"        
       	    	n2f += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2G"		
       	    	n2g += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2H"		
       	    	n2h += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2I"        	    
       	       n2i += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2J"        
       	    	n2j += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2K"		
       	    	n2k += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2L"		
       	    	n2l += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2M"        	    
       	       n2m += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2N"        
       	    	n2n += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2O"		
       	    	n2o += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2P"		
       	    	n2p += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "2Q"		
       	    	n2q += aVerbasFunc[nAux][7]
       	    	
			//TOTALES RUBRO 3
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "3A"        	    
       	       n3a += aVerbasFunc[nAux][7] 
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "3B"        
       	    	n3b += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "3C"		
       	    	n3c += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "3D"		
       	    	n3d += aVerbasFunc[nAux][7]
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "3E"		
       	    	n3e += aVerbasFunc[nAux][7]
       	    	
       	 //TOTALES RUBRO 4
   			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "4B"        
       	    	n4b += aVerbasFunc[nAux][7]      	    	
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "4C"		
       	    	n4c += aVerbasFunc[nAux][7]
       	ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "4D"		
       	    	n4d += aVerbasFunc[nAux][7]
			ElseIf UPPER(alltrim(aVerbasFunc[nAux][20])) == "4E"		
       	    	n4e += aVerbasFunc[nAux][7]
     		 EndIf      

        Next nAux 

        
        //TOTALES DEL RUBRO 1
       	nSum1    := n1a + n1b + n1c + n1d 
        
		//TOTALES DEL RUBRO 2
			nSum2	:= n2a + n2b + n2c + n2d + n2e 
			nSum2	+= n2f + n2g + n2h + n2i + n2j 
			nSum2	+= n2k + n2l + n2m + n2n + n2o 
			nSum2	+= 	n2p + n2q  
		
	
		//TOTALES DEL RUBRO 3
			nSum3 := n3a + n3b + n3c + n3d + n3e 
			
			n4a := (nSum1 - nSum2) - nSum3

		GerAFIP883()
		(cQrySRA)->(dbSkip())
	End
	
	If Select(cQrySRA) > 0
	 (cQrySRA)->(dbCloseArea())
	Endif  

Return

Static Function GerAFIP883()


Local nPosCant := 2100
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?                                                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oPrint:StartPage() 			//Inicia uma nova pagina   

	oPrint:say ( 0135, 0210, OemToAnsi(STR0001), oFont25n ) 							//"AFIP"
 
oPrint:Box ( 0120, 0135, 0300, 0500 ) //BOX AFIP
oPrint:Box ( 0120, 0505, 0300, nColMax ) //BOX F.649
oPrint:say ( 0125, 0900, OemToAnsi(STR0002), oFont20n )
oPrint:say ( 0185, 0900, OemToAnsi(STR0003), oFont20n ) 


oPrint:Box ( 0340, 0135, 0580, nColMax )   //BOX Datos del Empleado
oPrint:say ( 0355, 0950, OemToAnsi(STR0004), oFont12n )//"DATOS DEL EMPLEADO"
//Primera Linea 
oPrint:line ( 0395, 0135, 0395, nColMax )  //horizontal
oPrint:say ( 0400, 0150, OemToAnsi(STR0005), oFont09 ) //"Código Único de Identificación Laboral"
oPrint:say ( 0445, 0150, (cQrySRA)->RA_CIC, oFont09 )
 
oPrint:line ( 0395, 0750, 0480, 0750 ) // Vertical
oPrint:say ( 0400, 0800, OemToAnsi(STR0006), oFont09 )//"Apellido y Nombres"
oPrint:say ( 0445, 0800, (cQrySRA)->RA_NOME, oFont09 )

oPrint:line ( 0395, 2050, 0580, 2050 ) // Vertical
oPrint:say ( 0400, 2100, OemToAnsi(STR0007), oFont09 )//"Legajo"
oPrint:say ( 0445, 2100, (cQrySRA)->RA_MAT, oFont09 )
 
//Segunda Linea
oPrint:line ( 0480, 0135, 0480, nColMax )  //horizontal
oPrint:say ( 0490, 0150, OemToAnsi(STR0008), oFont09 )//"Domicilio"
oPrint:say ( 0535, 0150, (cQrySRA)->RA_ENDEREC  , oFont09 ) 

oPrint:line ( 0480, 1450, 0580, 1450 ) // Vertical
oPrint:say ( 0490, 1500, OemToAnsi(STR0009), oFont09 )//"Código"
oPrint:say ( 0535, 1500, (cQrySRA)->RA_CEP, oFont09 )
 
oPrint:line ( 0480, 1750, 0580, 1750 ) // Vertical
oPrint:say ( 0490, 1800, OemToAnsi(STR0010), oFont09 )//"Localidad"
oPrint:say ( 0535, 1800, (cQrySRA)->RA_LOCALID, oFont09 )

oPrint:say ( 0490, 2100, OemToAnsi(STR0011), oFont09 )//Provincia
oPrint:say ( 0535, 2100, (cQrySRA)->RA_ESTADO, oFont09 )

oPrint:Box ( 0600, 0135, 0800, nColMax )   //BOX Datos del Agente de Retención
oPrint:say ( 0615, 0950, OemToAnsi(STR0012), oFont12n )//"DATOS DEL Agente de _Retención
oPrint:line ( 0670, 0135, 0670, nColMax )  //horizontal
oPrint:say ( 0680, 0150, OemToAnsi(STR0013), oFont09 ) //"Clave Única de Identificación Tributaria"
oPrint:say ( 0750, 0150, Alltrim(SM0->M0_CGC), oFont09 ) 

oPrint:line ( 0670, 0840, 0800, 0840 ) // Vertical
oPrint:say ( 0680, 0850, OemToAnsi(STR0014), oFont09 )//"Apellido y Nombres o Razón Social"
oPrint:say ( 0750, 0850, Alltrim(SM0->M0_NOMECOM), oFont09 )

oPrint:Box ( 0820, 0135, 1040, nColMax )   //BOX Datos dela declaración
oPrint:say ( 0835, 1150, OemToAnsi(STR0015), oFont12n )//"DATOS DE la declaracion
oPrint:line ( 0900, 0135, 0900, nColMax )  //horizontal
oPrint:say ( 0930, 0150, OemToAnsi(STR0016), oFont09 ) //"Fecha de Emisión"
oPrint:say ( 0980, 0150, cValToChar(dFecha), oFont09 )
 
oPrint:line ( 0900, 0500, 1040, 0500 ) // Vertical
oPrint:say ( 0930, 0550, OemToAnsi(STR0017), oFont09 )//Periodo
oPrint:say ( 0980, 0550, cPeriodo, oFont09 )

oPrint:line ( 0900, 0820, 1040, 0820 ) // Vertical
oPrint:say ( 0930, 1350, OemToAnsi(STR0018), oFont09 ) //"DDJJ"
If cDeclaJu == 1
	oPrint:say ( 0980, 1350, OemToAnsi(STR0032), oFont09 )
Else
	oPrint:say ( 0980, 1350, OemToAnsi(STR0033), oFont09 )
EndIf 
oPrint:line ( 0900, 1650, 1040, 1650 ) // Vertical
oPrint:say ( 0930, 1850, OemToAnsi(STR0019), oFont09 )//"Tipo de DDJJ"
If cTipoDe == 1
	oPrint:say ( 0980, 1850, OemToAnsi(STR0034), oFont09 )
Else
	oPrint:say ( 0980, 1850, OemToAnsi(STR0035), oFont09 )
EndIf
oPrint:Box ( 1100, 0135, 2700, nColMax )   //BOX Datos Importes
oPrint:line ( 1150, 0135, 1150, nColMax )  //horizontal
oPrint:line ( 1150, 0250, 2700, 0250 ) // Vertical
oPrint:line ( 1150, 0340, 2700, 0340 ) // Vertical
oPrint:line ( 1150, 2150, 2700, 2150 ) // Vertical


oPrint:say ( 1115, 2151, OemToAnsi(STR0020), oFont11n )//Importes
oPrint:say ( 1155, 0200, "1", oFont12n )//1
oPrint:say ( 1155, 0350, OemToAnsi(STR0021), oFont11n )//Remuneraciones
	oPrint:line ( 1190, 0340, 1190, nColMax )  //horizontal
	oPrint:say ( 1195, 0275, "a", oFont11 )//a
	////If n1a > 0
		oPrint:say ( 1195, 1800, aEntidad2[1][1], oFont09 )//Remuneración Bruta
		oPrint:say ( 1195, nPosCant, Transform( n1a, "99,999,999,999.99"), oFont09num )//a14
	//EndIf
	oPrint:line ( 1240, 0340, 1240, nColMax )  //horizontal
	oPrint:say ( 1245, 0275, "b", oFont11 )//b
	////If n1b > 0	
		oPrint:say ( 1245, 1700, aEntidad2[2][1], oFont09 )//Remuneración no alcanzada
		oPrint:say ( 1245, nPosCant, Transform( n1b, "99,999,999,999.99"), oFont09num )//b14
	//Endif
	oPrint:line ( 1280, 0340, 1280, nColMax )  //horizontal
	oPrint:say ( 1285, 0275, "c", oFont11 )//C
	//If n1c > 0
		oPrint:say ( 1285, 1800, aEntidad2[3][1], oFont09 )//Remuneración exenta
		oPrint:say ( 1285, nPosCant, Transform( n1c, "99,999,999,999.99"), oFont09num )//c14
	//EndIf
	oPrint:line ( 1320, 0340, 1320, nColMax )  //horizontal
	oPrint:say ( 1325, 0275, "d", oFont11 )//D
	//If n1d > 0
		oPrint:say ( 1325, 1700, aEntidad2[4][1], oFont09 )//Remuneracion otros empleos
		oPrint:say ( 1325, nPosCant, Transform( n1d, "99,999,999,999.99"), oFont09num )//D14
	//EndIf
	oPrint:line ( 1370, 0340, 1370, nColMax )  //horizontal
	oPrint:say ( 1375, 1150, OemToAnsi(STR0022), oFont11n )//Remuneraciones computables
	oPrint:say ( 1375, nPosCant, Transform( nSum1, "99,999,999,999.99"), oFont09num )//15
	
oPrint:say ( 1415, 0200, "2", oFont12n )//2
oPrint:line ( 1410, 0340, 1410, nColMax )  //horizontal
oPrint:say ( 1415, 0350, OemToAnsi(STR0023), oFont11n )//Deducciones
	oPrint:line ( 1450, 0340, 1450, nColMax )  //horizontal
	oPrint:say ( 1455, 0275, "a", oFont11 )//A
	//If n2a > 0
		oPrint:say ( 1455, 0390,aEntidad2[5][1], oFont09 )//
		oPrint:say ( 1455, nPosCant, Transform( n2a, "99,999,999,999.99"), oFont09num )//A14
	//EndIf
	oPrint:line ( 1490, 0340, 1490, nColMax )  //horizontal
	oPrint:say ( 1495, 0275, "b", oFont11 )//B
	//If n2b > 0
		oPrint:say ( 1495, 1800, aEntidad2[6][1], oFont09 )// Aportes Obra Social
		oPrint:say ( 1495, nPosCant, Transform( n2b, "99,999,999,999.99"), oFont09num )//B14
	//EndIf
	oPrint:line ( 1530, 0340, 1530, nColMax )  //horizontal
	oPrint:say ( 1535, 0275, "c", oFont11 )//C
	//If n2c > 0
		oPrint:say ( 1535, 1880, aEntidad2[7][1], oFont09 )// Cuota Sindical
		oPrint:say ( 1535, nPosCant, Transform( n2c, "99,999,999,999.99"), oFont09num )//C14 
	//EndIf
	oPrint:line ( 1570, 0340, 1570, nColMax )  //horizontal
	oPrint:say ( 1575, 0275, "d", oFont11 )//D
	//If n2d > 0
		oPrint:say ( 1575, 1550, aEntidad2[8][1], oFont09 )//Aportes Jubilatorios Otros Empleados
		oPrint:say ( 1575, nPosCant, Transform( n2d, "99,999,999,999.99"), oFont09num )//D14
	//EndIf
	oPrint:line ( 1610, 0340, 1610, nColMax )  //horizontal
	oPrint:say ( 1615, 0275, "e", oFont11 )//E
	//If n2e > 0
		oPrint:say ( 1615, 1500, aEntidad2[9][1], oFont09 )// Aportes Obras Sociales Otros Empleados
		oPrint:say ( 1615, nPosCant, Transform( n2e, "99,999,999,999.99"), oFont09num )//E14
	//EndIf
	oPrint:line ( 1650, 0340, 1650, nColMax )  //horizontal
	oPrint:say ( 1655, 0275, "f", oFont11 )//F
	//If n2f > 0
		oPrint:say ( 1655, 1650, aEntidad2[10][1], oFont09 )// Cuota Sindical Otros Empleos
		oPrint:say ( 1655, nPosCant, Transform( n2f, "99,999,999,999.99"), oFont09num )//F14
	//EndIf
	oPrint:line ( 1700, 0340, 1700, nColMax )  //horizontal
	oPrint:say ( 1705, 0275, "g", oFont11 )//G
	//If n2g > 0
		oPrint:say ( 1705, 1670, aEntidad2[11][1], oFont09 )//Cuotas Medico Asistenciales
		oPrint:say ( 1705, nPosCant, Transform( n2g, "99,999,999,999.99"), oFont09num )//G14
	//EndIf
	oPrint:line ( 1740, 0340, 1740, nColMax )  //horizontal
	oPrint:say ( 1745, 0275, "h", oFont11 )//H
	//If n2h > 0
		oPrint:say ( 1745, 1400, aEntidad2[12][1], oFont09 )//Primas del Seguro de Vida para caso de muerte
		oPrint:say ( 1745, nPosCant, Transform( n2h, "99,999,999,999.99"), oFont09num )//H14
	//EndIf
	oPrint:line ( 1780, 0340, 1780, nColMax )  //horizontal
	oPrint:say ( 1785, 0275, "i", oFont11 )//I
	//If n2i > 0 
		oPrint:say ( 1785, 1800, aEntidad2[13][1], oFont09 )// Gastos de Sepelio
		oPrint:say ( 1785, nPosCant, Transform( n2i, "99,999,999,999.99"), oFont09num )//I14
	//EndIf
	oPrint:line ( 1820, 0340, 1820, nColMax )  //horizontal
	oPrint:say ( 1825, 0275, "j", oFont11 )//J
	//If n2j > 0
		oPrint:say ( 1825, 1250, aEntidad2[14][1], oFont09 )// Gastos estimativos para corredores y viajantes de comercio
		oPrint:say ( 1825, nPosCant, Transform( n2j, "99,999,999,999.99"), oFont09num )//J14
	//EndIf
	oPrint:line ( 1860, 0340, 1860, nColMax )  //horizontal
	oPrint:say ( 1865, 0275, "k", oFont11 )//K
	//If n2k > 0
		oPrint:say ( 1865, 0385, aEntidad2[15][1], oFont09 )//
		oPrint:say ( 1865, nPosCant, Transform( n2k, "99,999,999,999.99"), oFont09num )//K14
	//EndIf
	oPrint:line ( 1900, 0340, 1900, nColMax )  //horizontal
	oPrint:say ( 1905, 0275, "l", oFont11 )//L
	//If n2L > 0
		oPrint:say ( 1905, 0980, aEntidad2[16][1], oFont09 )// Descuentos Obligatorios establecidos por Ley Nacional, Provincial o Municipal
		oPrint:say ( 1905, nPosCant, Transform( n2l, "99,999,999,999.99"), oFont09num )//L14 
	//EndIf
	oPrint:line ( 1940, 0340, 1940, nColMax )  //horizontal
	oPrint:say ( 1945, 0275, "m", oFont11 )//M
	//If n2m > 0
		oPrint:say ( 1945, 1100, aEntidad2[17][1], oFont09 )// Honorarios por servicios de Asistencia sanitaria, médica y paramédica 
		oPrint:say ( 1945, nPosCant, Transform( n2m, "99,999,999,999.99"), oFont09num )//M14
	//EndIf
	oPrint:line ( 1980, 0340, 1980, nColMax )  //horizontal
	oPrint:say ( 1985, 0275, "n", oFont11 )//N
	//If n2n > 0
		oPrint:say ( 1985, 1650, aEntidad2[18][1], oFont09 )// Intereses Créditos Hipotecarios
		oPrint:say ( 1985, nPosCant, Transform( n2n, "99,999,999,999.99"), oFont09num )//N14
	//EndIf
	oPrint:line ( 2020, 0340, 2020, nColMax )  //horizontal
	oPrint:say ( 2025, 0275, "o", oFont11 )//O
	//If n2o > 0
		oPrint:say ( 2025, 0640, aEntidad2[19][1], oFont09 )// Aportes al capital social o al fondo de riesgo de socios protectores de sociedades de garantia reciproca
		oPrint:say ( 2025, nPosCant, Transform( n2o, "99,999,999,999.99"), oFont09num )//O14
	//EndIf
	oPrint:line ( 2060, 0340, 2060, nColMax )  //horizontal
	oPrint:say ( 2065, 0275, "p", oFont11 )//P
	//If n2p > 0
		oPrint:say ( 2065, 1320, aEntidad2[20][1], oFont09 )// Empleados del servicio doméstico (Ley 26.063, art 16)
		oPrint:say ( 2065, nPosCant, Transform( n2p, "99,999,999,999.99"), oFont09num )//P14
	//EndIf
	oPrint:line ( 2100, 0340, 2100, nColMax )  //horizontal
	oPrint:say ( 2105, 0275, "q", oFont11 )//Q
	//If n2Q > 0
		oPrint:say ( 2105, 0700, aEntidad2[21][1], oFont09 )// Aportes a cajas Complemetarias de Previsión, fondos compensadores de previsión o similares
		oPrint:say ( 2105, nPosCant, Transform( n2q, "99,999,999,999.99"), oFont09num )//Q14
	//EndIf
	oPrint:line ( 2151, 0340, 2151, nColMax )  //horizontal
	oPrint:say ( 2155, 1260, OemToAnsi(STR0024), oFont11n )//TOTAL DEDUCCIONES
	oPrint:say ( 2155, nPosCant, Transform( nSum2, "99,999,999,999.99"), oFont09num )// 16
		 
oPrint:say ( 2195, 0200, "3", oFont12n )//3
oPrint:line ( 2190, 0340, 2190, nColMax )  //horizontal
oPrint:say ( 2195, 0350, OemToAnsi(STR0025), oFont11n )//Deducciones ART23
	oPrint:line ( 2230, 0340, 2230, nColMax )  //horizontal
	oPrint:say ( 2235, 0275, "a", oFont11 )//A
	//If n3a > 0
		oPrint:say ( 2235, 1750, aEntidad2[22][1], oFont09 )// Ganancia NO Imponible
		oPrint:say ( 2235, nPosCant,Transform( n3a, "99,999,999,999.99"), oFont09num )//A14
	//EndIf
	oPrint:line ( 2270, 0340, 2270, nColMax )  //horizontal
	oPrint:say ( 2275, 0275, "b", oFont11 )//B
	//If n3b > 0
		oPrint:say ( 2275, 1800, aEntidad2[23][1], oFont09 )// Deducción Especial
		oPrint:say ( 2275, nPosCant, Transform( n3b, "99,999,999,999.99"), oFont09num )//B14
	//EndIf
	oPrint:line ( 2310, 0340, 2310, nColMax )  //horizontal
	oPrint:say ( 2315, 0350, OemToAnsi(STR0026), oFont11n )//cARGAS DE FAMILIA
	oPrint:say ( 2315, 0275, "c", oFont11 )//C
	//If n3c > 0
		oPrint:say ( 2315, 1950, aEntidad2[24][1],oFont09  )//Cónyuge
		oPrint:say ( 2315, nPosCant, Transform( n3c, "99,999,999,999.99"), oFont09num )//C14
	//EndIf
	oPrint:line ( 2350, 0340, 2350, nColMax )  //horizontal
	oPrint:say ( 2355, 0275, "d", oFont11 )//D
	//If n3d > 0
		oPrint:say ( 2355, 2000,aEntidad2[25][1], oFont09 )// "Hijos"
		oPrint:say ( 2355, nPosCant, Transform( n3d, "99,999,999,999.99"), oFont09num )//D14
	//EndIf
	oPrint:line ( 2390, 0340, 2390, nColMax )  //horizontal
	oPrint:say ( 2395, 0275, "e", oFont11 )//E
	//If n3e > 0
		oPrint:say ( 2395, 1900, aEntidad2[26][1], oFont09 )// Otras Cargas
		oPrint:say ( 2395, nPosCant, Transform( n3e, "99,999,999,999.99"), oFont09num )//E14
	//EndIF
	oPrint:line ( 2430, 0340, 2430, nColMax )  //horizontal
	oPrint:say ( 2435, 0800, OemToAnsi(STR0027), oFont11n )//TOTAL DEDDUCION ART 23
	oPrint:say ( 2435, nPosCant, Transform( nSum3, "99,999,999,999.99"), oFont09num )//17
	
oPrint:say ( 2435, 0200, "4", oFont12n )//4
	oPrint:line ( 2470, 0340, 2470, nColMax )  //horizontal
	oPrint:say ( 2475, 0275, "a", oFont11 )//A
		oPrint:say ( 2475, 0500, aEntidad2[27][1], oFont11n )//
		oPrint:say ( 2475, nPosCant, Transform( n4a, "99,999,999,999.99"), oFont09num )//A14
	
	oPrint:line ( 2515, 0340, 2515, nColMax )  //horizontal
	oPrint:say ( 2515, 0275, "b", oFont11 )//B
		oPrint:say ( 2515, 1680, aEntidad2[28][1], oFont11n )//
		oPrint:say ( 2515, nPosCant, Transform( n4b, "99,999,999,999.99"), oFont09num )//B14

	oPrint:line ( 2550, 0340, 2550, nColMax )  //horizontal
	oPrint:say ( 2555, 0275, "c", oFont11 )//C
		oPrint:say ( 2555, 1750,aEntidad2[29][1], oFont11n )//
		oPrint:say ( 2555, nPosCant, Transform( n4c, "99,999,999,999.99"), oFont09num )//C14

	oPrint:line ( 2590, 0340, 2590, nColMax )  //horizontal
	oPrint:say ( 2595, 0275, "d", oFont11 )//D
		oPrint:say ( 2595, 1800, aEntidad2[30][1], oFont11n )//
		oPrint:say ( 2595, nPosCant, Transform( n4d, "99,999,999,999.99"), oFont09num )//D14
	
	oPrint:line ( 2630, 0340, 2630, nColMax )  //horizontal
	oPrint:say ( 2635, 0275, "e", oFont11 )//E
		oPrint:say ( 2635, 1950,aEntidad2[31][1], oFont11n )//
		oPrint:say ( 2635, nPosCant, Transform( n4e, "99,999,999,999.99"), oFont09num )//E14

oPrint:say ( 2850, 0200, STR0029, oFont09 )//E14
oPrint:say ( 2950, 0200, cLugar + ", " + cValToChar(dFecha), oFont09 )//E14

oPrint:say ( 2850, 1900, STR0030, oFont09 )//E14
oPrint:say ( 2950, 1900, cCargo, oFont09 )//E14cCargo
oPrint:EndPage()

Return         