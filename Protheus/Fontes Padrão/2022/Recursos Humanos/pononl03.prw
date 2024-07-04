#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONONL03.CH"
#INCLUDE "PONCALEN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PonPOnl03 � Autor � Mauricio MR           � Data � 26/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Horas Trabalhadas X Previstas                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PonPOnl03                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aPainel[n]:= Dados da Quantidad de Horas	/ Percentuais     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PonOnL03                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programador  � Data   � FNC  �  Motivo da Alteracao                    ���
�������������������������������������������������������������������������ĳ��
���Cecilia C.   �21/05/14�TPQAN3�Incluido o fonte da 11 para a 12 e efetu-��� 
���             �        �      �tuada a limpeza.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function	PONONL03()   
Local aPainel		:= {}

Static aRetQuery	:= {} 

//-- Inicializa o Painel do SIGAPON
PonOnLPrep( @aRetQuery)

//-- Monta array de dados do Painel
PonOnLMonta(@aPainel, @aRetQuery)

Return (aPainel) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PonOnLPrep� Autor � Mauricio MR           � Data � 26/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara Montagem inicial do Painel               		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PonOnLPrep()										   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRetQuery = dados staticos do Painel					      ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONONL03  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PonOnLPrep(aRetQuery)

Local aAreaSm0 	
Local aCodDesc  	   := {}   
Local aCodHE        := {}   
Local aIndicadores	:= {}   
Local aItensPainel	:= {}

Local aRetSP9		:= {}
Local aSP9Cpos		:= {}   

Local aTabPadrao	:= {}
Local aTabCalend	:= {}

Local cAliasQry 
Local cAliasSP9    

Local cFilDe	
Local cFilAte	

Local cFiltro  	:= ""
Local cOrdem    
Local cTipoCod

Local cFilSP4
Local cFilSP9	 

Local cFilSP9Cond	:=""
Local lSPOCompart	

Local cAlias	
Local cFilOld 	
                                
LocaL cPerIni	
Local cPerFim	

Local dPerIni   	:= Ctod("//")
Local dPerFim   	:= Ctod("//")   

Local lCarregaDados	:= .T.      

Local nLoop
Local nLoops
Local nPosFil		:= 0
Local nPosSP4		:= 0
Local nX                 
Local cTamFil

Local cQueryDados
Local cQueryCalend


Static lSPOCompart	:= ( Len(Alltrim(xFilial( "SPO"))) < FWGETTAMFILIAL )   	 

aAreaSm0 			:= SM0->(GetArea())
cAlias				:= Alias()
cFilOld 			:= cFilAnt
	
cFilDe				:= "" 	
cFilAte				:= Replicate("Z", FWGETTAMFILIAL)
	
 
/*/
��������������������������������������������������������������Ŀ
� Corre todas as Filiais da Empresa							   �
����������������������������������������������������������������/*/		

SM0->(MsSeek(cEmpAnt+cFilDe,.T.))
While !SM0->(Eof()) .And.(	SM0->M0_CODIGO == cEmpAnt .And. FWGETCODFILIAL <= cFilAte )
	cFilAnt := FWGETCODFILIAL
    cFilSP4	:= xFilial('SP4', cFilAnt)  
    cFilSP9	:= xFilial('SP9', cFilAnt)  
   
    /*/
	��������������������������������������������������������������Ŀ
	� Obtem o Periodo de Apontamento da Filial					   �
	����������������������������������������������������������������/*/		                                          
   	//-- Se o cadastro de periodos for Exclusivo ou eh a primeira vez
    IF !lSPOCompart .OR. dPerIni == Ctod("//")
	    dPerIni   := Ctod("//")
	    dPerFim   := Ctod("//")
		//-- Obtem o periodo aberto
		GetPonMesDat( @dPerIni , @dPerFim , cFilAnt ) 
	EndIF
    
    /*/
	��������������������������������������������������������������Ŀ
	� Verifica se a Query devera ser remontada devido a alteracao  �
	� do Periodo de Apontamento anterior ou se for a 1a vez.       �
	����������������������������������������������������������������/*/		                                          

    lCarregaDados 	:= .T.
	    
    //-- Verifica se deve recarregar as Variaveis conforme a alteracao do periodo de apontamento
    IF !Empty(aRetQuery)   
    	//-- Verifica se a filial ja foi processada antes
       IF !Empty(nPosFil	:=	Ascan(aRetQuery,{|x|  FWGETCODFILIAL + SM0->M0_FILIAL ==  ( x[1] + x[2] ) })) 
          //-- Verifica se o periodo de apontamento mudou
          IF (lCarregaDados	:= ( ( aRetQuery[nPosFil,3] <> dPerIni ) .or. ( aRetQuery[nPosFil,4] <> dPerFim ) ) )   
               //-- Reinicializa informacoes
	           aRetQuery[nPosFil,3]	:=	dPerIni
	           aRetQuery[nPosFil,4]	:=	dPerFim
	           aRetQuery[nPosFil,5]	:=	Nil       //Query para recuperar as informacoes de eventos de cada filial
	           aRetQuery[nPosFil,6]	:=	Nil       //Query para recuperar as informacoes de calendario de cada filial
	           aRetQuery[nPosFil,7]	:=	Nil       //Indicadores da Filial 
 	           aRetQuery[nPosFil,8]	:=	Nil       //Eventos de HExtras da Filial 
   	           aRetQuery[nPosFil,9]	:=	Nil       //Eventos de Descontos
	           aRetQuery[nPosFil,10]:=	Nil       //Itens a serem apresentados
	           aRetQuery[nPosFil,11]:=	Nil       //Se a Query ja foi Executada no Carregamento 
          EndIF
       EndIF
    EndIF   
	
	//-- Se a filial ainda nao foi processada Acrescenta-a
	IF Empty(nPosFil)
       //-- Acrescenta novas informacoes para a aRetQuery
       AADD(aRetQuery, { FWGETCODFILIAL,  SM0->M0_FILIAL, dPerIni, dPerFim, Nil, Nil, Nil, Nil, Nil, Nil, Nil } )   
	   nPosFil:=Len(aRetQuery) 
	EndIF
    
	//-- Converte as datas do Periodo de Apontamento para uso na Query
	cPerIni		:= dtos(dPerIni)
	cPerFim		:= dtos(dPerFim)

	//-- Carrega Dados na primeira vez ou na alteracao do periodo de apontamento    
    If lCarregaDados 
        //-- Inicializa as variaveis para cada carrregamento
        aCodDesc  		:= {}   
        aCodHE  		:= {}   
		aIndicadores	:= {}   
		aItensPainel	:= {}
        
		/*/
		��������������������������������������������������������������Ŀ
		� Obtem os Eventos de Descontos								   �
		����������������������������������������������������������������/*/
		cOrdem	:= '% '+SqlOrder( SP9->( IndexKey(1) ) )+' %'
		cTipoCod:= '2'		    		    
		cAliasQry := GetNextAlias()
			
		BeginSql Alias cAliasQry
			SELECT 	SP9.P9_FILIAL, SP9.P9_CODIGO
			FROM %table:SP9% SP9 
			WHERE 	SP9.P9_FILIAL =   %xFilial:SP9% AND  
					SP9.P9_TIPOCOD	=  %exp:cTipoCod%  AND
					SP9.%NotDel% 
			ORDER BY %exp:cOrdem%					
		EndSql 
		
		While (cAliasQry)->( (!Eof()) .And.  ( P9_FILIAL == cFilSP9 ) )
			// Procura pelo Evento de DescontO
		 	If ( nPosSP9Aut	:= Ascan(aCodDesc, {|x|( x == (cAliasQry)->P9_CODIGO  )  } ) ) == 0 
		 			Aadd( aCodDesc, (cAliasQry)->P9_CODIGO )	
		 	Endif  
	 
			(cAliasQry)->(DbSkip())
					
		End While  		
		
		//-- Fecha a Query 
		(cAliasQry)->(DbCloseArea())	 
        
        If !Empty(cAlias)
			DbSelectArea(cAlias)
		Endif
		
		/*/
		��������������������������������������������������������������Ŀ
		� Obtem os Eventos de Horas Extras							   �
		����������������������������������������������������������������/*/
		
		cTamFil := Space(FWGETTAMFILIAL)
		
		cOrdem	:= '% '+SqlOrder( SP4->( IndexKey(1) ) )+' %'
		
		cAliasQry := GetNextAlias()
			
		BeginSql Alias cAliasQry
			SELECT 	SP4.P4_FILIAL, SP4.P4_CODAUT, SP4.P4_CODNAUT, SP9.P9_CODIGO
			FROM %table:SP4% SP4 
			INNER JOIN %table:SP9% SP9 
			ON  (( SP4.P4_CODAUT = SP9.P9_CODIGO  ) OR ( SP4.P4_CODNAUT = SP9.P9_CODIGO  )) AND
				( (SP4.P4_FILIAL = SP9.P9_FILIAL) OR (SP9.P9_FILIAL = %exp:cTamFil% ) )
			WHERE 	SP4.P4_FILIAL =   %xFilial:SP4% AND
					SP9.%NotDel% AND 
					SP4.%NotDel%  	
			ORDER BY %exp:cOrdem%					
		EndSql 
		
		While (cAliasQry)->( (!Eof()) .And.  ( P4_FILIAL == cFilSP4 ) )
			// Procura pelo Evento HE Autorizadas
		 	If ( nPosSP4	:= Ascan(aCodHE, {|x|( ( x == (cAliasQry)->P4_CODAUT )  )  } ) ) == 0 
		 			Aadd( aCodHE, (cAliasQry)->P4_CODAUT )	
		 	Endif  
			       
		 	If ( nPosSP4	:= Ascan(aCodHE, {|x|( (x == (cAliasQry)->P4_CODNAUT) )  } ) ) == 0 
	 				Aadd( aCodHE, (cAliasQry)->P4_CODNAUT  )	
		 	Endif  
			(cAliasQry)->(DbSkip())
					
		End While  
		
		
		//-- Fecha a Query 
		(cAliasQry)->(DbCloseArea())	 
        
        If !Empty(cAlias)
			DbSelectArea(cAlias)
		Endif
		
		
		//-- PERCENTUAL HORAS X PREVISTAS
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"PHEXTRAS"				,;  //Codigo do Evento
							 	STR0005 				,;  //"% HE X PREVISTAS"
								0 						;   //Qtde							 			
							 };
			)  

		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"PHREALIZADAS"			,;  //Codigo do Evento
							 	STR0006 				,;  //"% REALIZADAS X PREVISTAS"	
								0 						;   //Qtde							 			
							 };
			)			
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"PHNAOREALIZADAS"		,;  //Codigo do Evento
							 	STR0007 				,;  //"% NAO REALIZADAS X PREVISTAS"	
								0 						;   //Qtde							 			
							 };
			) 
		
		
		//-- TOTAL DE HORAS 
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HPREVISTAS"			,;  //Codigo do Evento
							 	STR0001 				,;  //"HORAS PREVISTAS"
								0 						;   //Qtde							 			
							 };
			)     

		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HEXTRAS"				,;  //Codigo do Evento
							 	STR0002 				,;  //"HORAS EXTRAS"
								0 						;   //Qtde							 			
							 };
			)  

		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HREALIZADAS"			,;  //Codigo do Evento
							 	STR0003 				,;  //"HORAS REALIZADAS"
								0 						;   //Qtde							 			
							 };
			)			
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HNAOREALIZADAS"		,;  //Codigo do Evento
							 	STR0004 				,;  //"HORAS NAO REALIZADAS"
								0 						;   //Qtde							 			
							 };
			)  			   

	 	

        //-- INDICADORES A SEREM DEMONSTRADOS    
        
        //- PERCENTUAIS
		Aadd( aItensPainel, { 	STR0006					,;  //"% HE X PREVISTAS"	
							 	"" 						,;  //Qtde
							 	CLR_GREEN				,;  //Cor
							 	NIL;                    	//Reservado
							 };
			)  			                                                    
		Aadd( aItensPainel, { 	STR0007					,;  //"% REALIZADAS X PREVISTAS"		
							 	"" 						,;  //Qtde
							 	CLR_HGRAY				,;  //Cor
							 	NIL;                    	//Reservado
							 };
			) 
		Aadd( aItensPainel, { 	STR0008					,;  //"% NAO REALIZADAS X PREVISTAS"	
							 	"" 						,;  //Qtde
							 	CLR_RED					,;  //Cor
							 	NIL;                    	//Reservado
							 };
			) 
        //- HORAS
		Aadd( aItensPainel, { 	STR0001					,;  //"HORAS PREVISTAS"
							 	"" 						,;  //Qtde
							 	CLR_BLUE					,;  //Cor
							 	NIL;                    	//Reservado
							 };
			)  
		Aadd( aItensPainel, { 	STR0002					,;  //"HORAS EXTRAS"
							 	"" 						,;  //Qtde
							 	CLR_GREEN				,;  //Cor
							 	NIL;                    	//Reservado
							 };
			)  			                                                    
		Aadd( aItensPainel, { 	STR0003					,;  //"HORAS REALIZADAS"
							 	"" 						,;  //Qtde
							 	CLR_HGRAY				,;  //Cor
							 	NIL;                    	//Reservado
							 };
			) 
		Aadd( aItensPainel, { 	STR0004					,;  //"HORAS NAO REALIZADAS"
							 	"" 						,;  //Qtde
							 	CLR_RED					,;  //Cor
							 	NIL;                    	//Reservado
							 };
			) 		   
				                                                    			
  	
       	
	   	/*/
		��������������������������������������������������������������Ŀ
		� Monta a Query de carregamento dos eventos					   �
		� Nao foi utilizada a Embeded pois reutilizamos a Query  	   �
		����������������������������������������������������������������/*/		
		
		//-- Se existir Codigos de Eventos para Horas Extras  ajusta condicao de Query
	   	cFiltro	:= " "
		If ( !Empty(aCodHE) )
			cFiltro	:=" ( "   
		Endif
		cFiltro	+=" ("

		//-- Considera os eventos de DESCONTOS
		nLoops	:= Len(aCodDesc)
		For nLoop := 1 To nLoops
			cFiltro += 	" SP9.P9_CODIGO  =  '"+ SUBSTR(aCodDesc[nLoop],1,3)+ "' OR "
		Next nLoop	
		cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  	cFiltro +=" )"
	
		//-- Considera os eventos de HORAS EXTRAS
		If (	nLoops	:= Len(aCodHE) ) > 0
			cFiltro += 		 " OR " 
			cFiltro+=" ("
	
			For nLoop := 1 To nLoops
				cFiltro += 	" SP9.P9_CODIGO  =  '"+ SUBSTR(aCodHE[nLoop],1,3)+ "' OR "
 	   		Next nLoop
				
			cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  		cFiltro +=" ) )"
	  	Endif	
				                                                 
		If (Empty(aCodHe) .and. Empty(aCodDesc), cFiltro := "", cFiltro += " AND ")
			         
		cFiltro += 		" ( "
		cFiltro +=			"SPC.PC_DATA >=  '" + cPerIni + "' AND "
		cFiltro += 			"SPC.PC_DATA <=  '" + cPerFim + "' "
		cFiltro += 		" ) "
		
		cFiltro += 		 " AND "
						
		cFiltro += 		"SPC.PC_FILIAL =  '" + cFilAnt + "' AND "
		cFiltro += 		"SP9.P9_FILIAL =  '" + cFilSP9 + "' "
						
	    cFilSP9Cond	:= "SP9.P9_FILIAL = " + IIf(Empty(cFilSP9),  "'"+Space(FWGETTAMFILIAL)+"'", "SPC.PC_FILIAL") + " "
			
		cOrdem		:= SqlOrder( SPC->( IndexKey(1) ) )
		cQueryDados	:= "SELECT 	SPC.PC_FILIAL, SPC.PC_MAT, SPC.PC_DATA, SPC.PC_PD, SPC.PC_PDI,SPC.PC_ABONO, SPC.PC_QUANTC, " 
		cQueryDados	+= "SPC.PC_QUANTI, SPC.PC_QTABONO, SP9.P9_CODIGO "
		cQueryDados	+= "FROM "+ RetSqlName("SPC") + " SPC "
		cQueryDados	+= "INNER JOIN "+ RetSqlName("SP9") + " SP9 "
	    cQueryDados	+= "ON ( SPC.PC_PD = SP9.P9_CODIGO ) AND "
		cQueryDados	+= cFilSP9Cond
	    cQueryDados	+= "WHERE 	SP9.D_E_L_E_T_  = ' ' " + " AND "
	    cQueryDados	+= "SPC.D_E_L_E_T_  = ' ' " + " AND "
	    cQueryDados	+= cFiltro
   	    cQueryDados	+= "ORDER BY " + cOrdem
   	    
   	    cQueryDados := ChangeQuery(cQueryDados)

	   	  
		/*/
		��������������������������������������������������������������Ŀ
		� Carrega dados de Apontamento para apresentacao do Indicador  �
		����������������������������������������������������������������/*/
   		CarregaDados(cQueryDados, @aIndicadores, aCodHE, aCodDesc, cFilAnt )
   		
   		/*/
		��������������������������������������������������������������Ŀ
		� Monta a Query de carregamento dos Calendarios dos Turnos	   �
		����������������������������������������������������������������/*/		
		cQueryCalend	:= "SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_TNOTRAB, SRA.RA_SEQTURN , COUNT(SRA.RA_MAT) AS NumFunc "
		cQueryCalend	+= "FROM "+ RetSqlName("SRA") + " SRA "  
	    cQueryCalend	+= "WHERE 	SRA.D_E_L_E_T_  = ' ' " + " AND SRA.RA_FILIAL =   '"+ cFilAnt + "' AND "   
	   	cQueryCalend	+= "( ( SRA.RA_SITFOLH IN ('D','T') AND " + " '" + cPerIni + "' "+" < SRA.RA_DEMISSA )  OR 	( SRA.RA_SITFOLH = ' ') )" 
	    cQueryCalend	+= "GROUP BY SRA.RA_FILIAL, SRA.RA_TNOTRAB, SRA.RA_SEQTURN "
	    cQueryCalend	+= "ORDER BY SRA.RA_FILIAL, SRA.RA_TNOTRAB, SRA.RA_SEQTURN " 
   	    cQueryCalend 	:= ChangeQuery(cQueryCalend)

   		/*/
		������������������������������������������������������������������������������Ŀ
		� Carrega dados do Calendario (Horas Previstas) para apresentacao do Indicador �
		��������������������������������������������������������������������������������/*/   
	   	CarregaCalend( cQueryCalend, dPerIni, dPerFim, @aIndicadores, cFilAnt )
   		
   		
		/*/
		��������������������������������������������������������������Ŀ
		� Formata saida de Itens do Painel							   �
		����������������������������������������������������������������/*/
	   	FormataPainel(aIndicadores, @aItensPainel)
   		
  		/*/
		��������������������������������������������������������������Ŀ
		� Transfere as informacoes da filial para o array da empresa   �
		����������������������������������������������������������������/*/
	                             
		aRetQuery[nPosFil,5]:= cQueryDados			   	// Ultima Query Executada para obter dados
		aRetQuery[nPosFil,6]:= cQueryCalend			   	// Ultima Query Executada para obter calendario
		aRetQuery[nPosFil,7]:= aClone(aIndicadores)   	// Indicadores 
		aRetQuery[nPosFil,8]:= aClone(aCodHE)   		// Eventos de Horas Extras
		aRetQuery[nPosFil,9]:= aClone(aCodDesc)   		// Eventos de Descontos
		aRetQuery[nPosFil,10]:= aClone(aItensPainel)	// Itens a serem apresentados
		aRetQuery[nPosFil,11]:= .T.				   		// Se a Query ja foi executada 	
		
	Else
		/*/
		��������������������������������������������������������������Ŀ
		� Forca que uma nova leitura seja feita conforme a ultima      �
		� query executada para a Filial								   �
		����������������������������������������������������������������/*/
		aRetQuery[nPosFil,11]:= .F.
	EndIF    
	

	
	SM0->(DbSkip())
	
End While        

SM0->(RestArea(aAreaSm0))
cFilAnt:= cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif


Return (Nil) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CarregaDados� Autor � Mauricio MR         � Data � 21/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Soma as horas dos eventos e carrega os indicadores		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CarregaDados( cQuery, aIndicadores, aCodHE, aCodDesc )  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aItens do do Painel por referencia						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PonOnL03  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarregaDados( cQuery, aIndicadores, aCodHE, aCodDesc, cFil )
Local aStruSPC	:= SPC->(DbStruct())    
Local cAlias	:= Alias()
Local cAliasSPC := GetNextAlias()
Local cEvento 
Local nQuant  
Local nLoops
Local nLoop
Local nPos1   
Local nPosExtras := GetPosInd("HEXTRAS"			, aIndicadores)
Local nPosDesc   := GetPosInd("HNAOREALIZADAS"	, aIndicadores)
Local nTotFunc	 := 0
Local cFilMat	 := Replicate("!", FWGETTAMFILIAL + GetSx3Cache("RA_MAT", "X3_TAMANHO"))
Local cFilOld	 := cFilAnt 

//-- Variaveis para tratamento do Fechamento Mensal
Local aFilesOpen :={"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }

//-- Verifica se foi possivel abrir os arquivos sem exclusividade
If Pn090Open()
	//Executa a Query
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSPC,.T.,.T.)
	aEval(aStruSPC, { |e|	If(e[2] <> "C" .And. FieldPos(e[1]) > 0, ;
		TcSetField(cAliasSPC,e[1],e[2],e[3],e[4]),) } )	
	
	// Obtem as informacoes dos lancamentos dos eventos	  
	cFilAnt	:= cFil
	While (cAliasSPC)->( (!Eof()) .And.  ( PC_FILIAL == cFilAnt ) )  
	    
	    If cFilMat <> (cAliasSPC)->(PC_FILIAL+PC_MAT)
		    cFilMat:= (cAliasSPC)->(PC_FILIAL+PC_MAT)
		    nTotFunc ++
	    Endif
		//-- Obtem o Evento valido para o lancamento (prioriza o informado)
		cEvento := If( Empty( (cAliasSPC)->PC_PDI ),(cAliasSPC)->PC_PD ,(cAliasSPC)->PC_PDI )
	
	    //-- Obtem as horas do Evento correspondente
		nQuant := If(Empty( (cAliasSPC)->PC_PDI ),(cAliasSPC)->PC_QUANTC,(cAliasSPC)->PC_QUANTI)
		
		// Procura pelo Evento de HExtras  
		IF ( Ascan(aCodHE, {|x|X == cEvento  } ) )  > 0
		   	aIndicadores[nPosExtras, 4]:=SomaHoras(aIndicadores[nPosExtras,4],nQuant)  
	
		// Procura pelo Evento de Descontos  	   		
		ElseIF( Ascan(aCodDesc, {|x|X == cEvento } ) )  > 0
		  	aIndicadores[nPosDesc, 4]:=SomaHoras(aIndicadores[nPosDesc,4],nQuant)	
	
		EndIF
		
		(cAliasSPC)->(DbSkip())
				
	End While    
	
	//-- Fecha Query 
	(cAliasSPC)->(DbCloseArea())
	
	/*
	��������������������������������������������������������������Ŀ
	� Apos a obtencao da consulta solicitada fecha os arquivos     �
	� utilizados no fechamento mensal para abertura exclusiva      �
	����������������������������������������������������������������*/
    Aeval(aFilesOpen, bCloseFiles)

Endif
		
//-- Reposiciona para a area de entrada da funcao
If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif           

cFilAnt	:= cFilOld
Return (Nil)   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CarregaCalend � Autor � Mauricio MR       � Data � 21/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculas as horas previstas conforme calendario			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CarregaCalend									   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aItens do do Painel por referencia						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONONL03  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarregaCalend( cQuery, dPerIni, dPerFim, aIndicadores, cFil )
Local aStruSRA	:= SRA->(DbStruct())
Local aTabPadrao:= {}        
Local aTabCalend:= {}
Local cAlias	:= Alias()    
Local cAliasQry := GetNextAlias() 
Local cFilSRA	:= xFilial('SRA', cFil)  
Local nHrsPrev	:=0
Local nLoops
Local nLoop
Local nPos1    
Local nPosPrev  := GetPosInd("HPREVISTAS"		, aIndicadores)    

Local cFilOld	:= cFilAnt 

//-- Variaveis para tratamento do Fechamento Mensal
Local aFilesOpen :={"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }


//-- Verifica se foi possivel abrir os arquivos sem exclusividade
If Pn090Open()

	//Executa a Query
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	aEval(aStruSRA, { |e|	If(e[2] <> "C" .And. FieldPos(e[1]) > 0, ;
		TcSetField(cAliasQry,e[1],e[2],e[3],e[4]),) } )	
	
	cFilAnt:=cFil
	
	While (cAliasQry)->( (!Eof()) .And.  ( RA_FILIAL == cFilSRA ) ) 
		  
		  aTabCalend	:= {}
		  //-- Monta Calendario para cada Filial + Turno
			  IF (cAliasQry)->( CriaCalend(		dPerIni		,;
												dPerFim		,;
												RA_TNOTRAB	,;
												RA_SEQTURN	,;
												@aTabPadrao	,;
												@aTabCalend	,;
												RA_FILIAL	 ;
											);
							  )	
		      // Calcula o total de horas do calendario pelo total de funcionarios relacionados             
			  nHrsPrev:= SomaHoras(nHrsPrev, fHrsPrev(aTabCalend) * NumFunc  )
			  
		  EndIF
		(cAliasQry)->(DbSkip())
	End While  
	
	//-- Fecha a Query 
	(cAliasQry)->(DbCloseArea())	 

	/*
	��������������������������������������������������������������Ŀ
	� Apos a obtencao da consulta solicitada fecha os arquivos     �
	� utilizados no fechamento mensal para abertura exclusiva      �
	����������������������������������������������������������������*/
    Aeval(aFilesOpen, bCloseFiles)

Endif
	        
If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif 
                                                         
//Alocar as Horas Previstas 
aIndicadores[nPosPrev, 4]:=nHrsPrev

cFilAnt	:= cFilOld
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fHrsPrev � Autor � Mauricio MR		    � Data � 26/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PonOnL03                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function fHrsPrev(aTabCalend)

Local nHrsPrev := 0
Local nX       := 0
Local dData    := 0

For nX := 1 To Len(aTabCalend)
    
	dData := aTabCalend[nX,CALEND_POS_DATA]      
     
    //-- Descarta as Horas da Tabela para Dias diferentes de Trabalhado
    If aTabCalend[ nX , CALEND_POS_TIPO_DIA ] !='S'                                                 
       Loop
    Endif

	//-- Verifica o total de horas trabalhadas da jornada
	If !Empty(aTabCalend[nX,CALEND_POS_HRS_TRABA])
		nHrsPrev := SomaHoras(nHrsPrev,aTabCalend[nX,CALEND_POS_HRS_TRABA])
	Endif

Next nX
Return nHrsPrev

           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FormataPainel� Autor � Mauricio MR	    � Data � 26/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formata Saida de Dados para exibi��o de painel             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FormataPainel(aIndicadores, aItensPainel)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PonOnL03                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/      
Static Function FormataPainel(aIndicadores, aItensPainel)
Local nLoop
Local nLoops		:= Len(aIndicadores)                          
Local nPosPrev   	:= GetPosInd("HPREVISTAS"		, aIndicadores)    
Local nPosExtras 	:= GetPosInd("HEXTRAS"			, aIndicadores)
Local nPosRealiz   	:= GetPosInd("HREALIZADAS"		, aIndicadores)
Local nPosNoRealiz 	:= GetPosInd("HNAOREALIZADAS"	, aIndicadores)
Local nPosPRealiz  	:= GetPosInd("PHREALIZADAS"		, aIndicadores)
Local nPosPExtras  	:= GetPosInd("PHEXTRAS"			, aIndicadores)
Local nPosPNoRealiz	:= GetPosInd("PHNAOREALIZADAS"	, aIndicadores)

//Alocar as Horas Realizadas (Horas Previstas - Horas Nao Realizadas)
aIndicadores[nPosRealiz, 4]:=SubHoras(aIndicadores[nPosPrev, 4],aIndicadores[nPosNoRealiz, 4])

//-"% HE X PREVISTAS"		
aIndicadores[nPosPExtras, 4]:=( fConvHr(aIndicadores[nPosExtras, 4],"D") / fConvHr(aIndicadores[nPosPrev, 4],"D") ) * 100

//- "% REALIZADAS X PREVISTAS"		
aIndicadores[nPosPRealiz, 4]:=( fConvHr(aIndicadores[nPosRealiz, 4],"D") / fConvHr(aIndicadores[nPosPrev, 4],"D") ) * 100 

//- "% NAO REALIZADAS X PREVISTAS"			
aIndicadores[nPosPNoRealiz, 4]:=( fConvHr(aIndicadores[nPosNoRealiz, 4],"D") / fConvHr(aIndicadores[nPosPrev, 4],"D") ) * 100 

//Formata dados para exibicao       
//-- Corre todos os Eventos de Cada Filial 
For nLoop:=1 to nLoops  
    //-- Formata totalizador
   	aItensPainel[nLoop,2]:= Transform(aIndicadores[nLoop, 4], "@E 999,999,999.99")	 //Qtde Horas Previstas
Next nLoop
Return (Nil) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PonOnLMonta � Autor � Mauricio MR         � Data � 21/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta array para demonstracao dos indicadores			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PonOnLMonta(aPainel)								   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aPainel = Dados do painel formatados para exibicao		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PonOnL03  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function PonOnLMonta(aPainel, aRetQuery)
Local aIndicadores	:= {}
Local aItensPainel	:= {}
Local nLoop
Local nLoops			
Local nLoop1
Local nLoops1			 

//-- Cria variaveis acumuladoras baseadas nos identificadores da primeira filial
aIndicadores:= aClone(aRetQuery[1,7] )
aEval(aIndicadores,{ |x| x[4] := 0 } )
aItensPainel:= aClone(aRetQuery[1,10] )
aEval(aItensPainel,{ |x| x[2] := " " } )

//-- Cria o Primeiro elemento para conter o total das filiais
AADD(aPainel,{ STR0005, aClone(aItensPainel ) } ) 

//-- Corre todas as Filiais 
nLoops	:= Len(aRetQuery) 
For  nLoop:= 1 to nLoops
	
	//-- Corre todos os indicadores de cada filial
    nLoops1	:= Len(aRetQuery[nLoop,7])
	For nLoop1:=1 to nLoops1 
	     aIndicadores[nLoop1, 4]:=SomaHoras( aIndicadores[nLoop1, 4], aRetQuery[nLoop,7, nLoop1, 4] )
	Next nLoop1                                                            

Next nLoop  
 
//-- Formata Saida do Total de Filiais
FormataPainel(aIndicadores, @aItensPainel) 
//-- Transfere os indicadores do Painel formatados
aPainel[1,2]:= aClone(aItensPainel ) 

//Formata dados para exibicao       
//-- Corre todas as Filiais 
nLoops	:= Len(aRetQuery) 
For nLoop:=1 to nLoops  
    //-- Carrega os indicadores se para a filial nao foram carregados
    If !aRetQuery[nLoop,11]
    	/*/
		��������������������������������������������������������������Ŀ
		� Carrega dados para apresentacao do Indicador				   �
		����������������������������������������������������������������/*/
		//-- Reinicializa o totalizador de horas
		Aeval(aRetQuery[nLoop, 7],{|x| x[4]:= 0})
   		
   		CarregaDados( aRetQuery[nLoop, 5], @aRetQuery[nLoop, 7], aRetQuery[nLoop, 8], aRetQuery[nLoop, 9], aRetQuery[nLoop, 1] )
		/*/
		������������������������������������������������������������������������������Ŀ
		� Carrega dados do Calendario (Horas Previstas) para apresentacao do Indicador �
		��������������������������������������������������������������������������������/*/   
	   	CarregaCalend( aRetQuery[nLoop, 6], aRetQuery[nLoop, 3], aRetQuery[nLoop, 4], @aRetQuery[nLoop, 7], aRetQuery[nLoop, 1] )                     
	   	
	   	/*/
		��������������������������������������������������������������Ŀ
		� Formata saida de Itens do Painel							   �
		����������������������������������������������������������������/*/
    	FormataPainel(aRetQuery[nLoop, 7], @aRetQuery[nLoop, 10])                   
	   	
   		aRetQuery[nLoop,11]:= .T.				   		// Indica que a Query ja foi executada 	
    Endif
   	  		  	
   	AADD(aPainel,{ aRetQuery[nLoop,1] + "-" + aRetQuery[nLoop,2], aClone(aRetQuery[nLoop,10] ) } ) 	

Next nLoop

Return (Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �GetPosInd   � Autor � Mauricio MR         � Data � 09/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Posicao de um Indicador						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetPosInd(cInd, aIndicadores)					   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � nPosInd = Posicao do Indicador							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PonOnL03  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/   
Static Function GetPosInd(cInd, aIndicadores)
Local nPosInd
nPosInd:=Ascan(aIndicadores,{|x| x[2] == Alltrim(Upper(cInd)) } )
Return (nPosInd)

/*
001A	HORAS NORMAIS
002A	D.S.R.
003N	HORA NOTURNA NAO AUTORIZADA
004A	HORA NOTURNA AUTORIZADA
005A	HORAS NORMAIS NAO REALIZADAS
006A	HORAS NOTURNAS NAO REALIZADAS
007N	FALTA 1/2 PERIODO NAO AUTORIZADA
008A	FALTA 1/2 PERIODO AUTORIZADA
009N	FALTA INTEGRAL NAO AUTORIZADA
010A	FALTA INTEGRAL AUTORIZADA
011N	ATRASO NAO AUTORIZADO
012A	ATRASO AUTORIZADO
013N	SAIDA ANTECIPADA NAO AUTORIZADA
014A	SAIDA ANTECIPADA AUTORIZADA
//015A	REFEICAO PARTE EMPRESA
//016A	REFEICAO PARTE FUNCIONARIO
//017N	DESCONTO DE D.S.R. NAO AUTORIZADO
//018A	DESCONTO DE D.S.R. AUTORIZADO
019N	SAIDA NO EXPEDIENTE NAO AUTORIZADO
020A	SAIDA NO EXPEDIENTE AUTORIZADO
//021N	ATRASOS NO PERIODO ANTERIOR NAO AUTORIZADO
//022A	ATRASOS NO PERIODO ANTERIOR AUTORIZADO
//023A	RESULTADO DO BANCO DE HORAS - PROVENTO
//024A	RESULTADO DO BANCO DE HORAS - DESCONTO
025A	NONA HORA
026A	HORAS NORMAIS NOTURNAS
//027N	ADICIONAL H.EXTRAS NAO AUTORIZADA
//028A	ADICIONAL H.EXTRAS AUTORIZADA
//029A	HORA EXTRA INTER JORNADA AUTORIZADA
//030A	HORAS DE INTERVALO
//031A	HORAS DE INTERVALO NOTURNAS
//032A	FALTAS HORAS DE INTERVALO
//033N	FALTAS HORAS DE INTERVALO NAO AUTORIZADA
//034A	FALTAS HORAS DE INTERVALO NOTURNAS
//035N	FALTAS HORAS DE INTERVALO NOTURNAS NAO AUTORIZADAS
//036N	DSR AUTOMATICO PERIODO ANTERIOR
//037A	ACRESCIMO NOTURNO AUTORIZADO
//038N	HORA EXTRA INTERJORNADA NAO AUTORIZADA

*/

/*
* Horas Trabalhadas                          '
001A	HORAS NORMAIS
026A	HORAS NORMAIS NOTURNAS

* Horas Nao realizadas
005A	HORAS NORMAIS NAO REALIZADAS
006A	HORAS NOTURNAS NAO REALIZADAS

* Faltas 
007N	FALTA 1/2 PERIODO NAO AUTORIZADA
008A	FALTA 1/2 PERIODO AUTORIZADA
009N	FALTA INTEGRAL NAO AUTORIZADA
010A	FALTA INTEGRAL AUTORIZADA

* Atrasos
011N	ATRASO NAO AUTORIZADO
012A	ATRASO AUTORIZADO

* Saidas
013N	SAIDA ANTECIPADA NAO AUTORIZADA
014A	SAIDA ANTECIPADA AUTORIZADA
019N	SAIDA NO EXPEDIENTE NAO AUTORIZADO
020A	SAIDA NO EXPEDIENTE AUTORIZADO

*/


/*
* Horas Trabalhadas
001A	HORAS NORMAIS
026A	HORAS NORMAIS NOTURNAS

* Horas Nao realizadas
005A	HORAS NORMAIS NAO REALIZADAS
006A	HORAS NOTURNAS NAO REALIZADAS

* Faltas 
007N	FALTA 1/2 PERIODO NAO AUTORIZADA
008A	FALTA 1/2 PERIODO AUTORIZADA
009N	FALTA INTEGRAL NAO AUTORIZADA
010A	FALTA INTEGRAL AUTORIZADA

* Atrasos
011N	ATRASO NAO AUTORIZADO
012A	ATRASO AUTORIZADO

* Saidas
013N	SAIDA ANTECIPADA NAO AUTORIZADA
014A	SAIDA ANTECIPADA AUTORIZADA
019N	SAIDA NO EXPEDIENTE NAO AUTORIZADO
020A	SAIDA NO EXPEDIENTE AUTORIZADO
*/
