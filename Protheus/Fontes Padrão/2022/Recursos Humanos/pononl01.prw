#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONONL01.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PonPOnl01 � Autor � Mauricio MR           � Data � 15/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quantidade de Horas no m�s por filial                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PonPOnl01                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aPainel[n]:= Dados da Quantidad de Horas                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PonOnL01                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programador  � Data   � FNC  �  Motivo da Alteracao                    ���
�������������������������������������������������������������������������ĳ��
���Cecilia C.   �21/05/14�TPQAN3�Incluido o fonte da 11 para a 12 e efetu-��� 
���             �        �      �tuada a limpeza.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function	PONONL01()   
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
���Fun��o	 �PonOnLPrep� Autor � Mauricio MR           � Data � 21/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara Montagem inicial do Painel               		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PonOnLPrep()										   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRetQuery = dados staticos do Painel					      ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONONL01  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PonOnLPrep(aRetQuery)

Local aAreaSm0 	
Local aCodigos  	:= {}   
Local aIndicadores	:= {}   
Local aItensPainel	:= {}

Local aRetSP9	   := {}
Local aSP9Cpos	:= {}  


Local cAliasQry 
Local cAliasSP9   

Local cFilDe	
Local cFilAte	

Local cFiltro  	:= ""
Local cOrdem

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
Local nPosSP4Aut	:= 0
Local nPosSP4Naut	:= 0     
Local nX

Local cQuery  

Local cTamFil

Local aIDEventos	:= {'001A', '026A', '005A', '006A', '007N', '008A', '009N',;
						'010A', '011N', '012A', '013N', '014A', '019N', '020A'} 
                                                                                 

Local aDesc			:=	{;	
							STR0003	,; // "H.NORMAIS"
							STR0004 ,; // "H.NORMAIS NOTURNAS"
							STR0005 ,; //"H.NORM.NAO REALIZ."
							STR0006 ,; //"H.NOT. NAO REALIZ."
							STR0007 ,; //"1/2 FALTA NAO AUT."
							STR0008 ,; //"1/2 FALTA AUTORIZ."
							STR0009 ,; //"FALTA NAO AUTORIZ."
							STR0010 ,; //"FALTA AUTORIZADA"
							STR0011 ,; //"ATRASO NAO AUTORIZ."
							STR0012 ,; //"ATRASO AUTORIZ."
							STR0013 ,; //"S.ANTC.NAO AUTORIZ."
							STR0014 ,; //"S.ANTC.AUTORIZADA"
							STR0015 ,; //"S.EXPD.NAO AUTORIZ."
							STR0016 ; //"S.EXPD.AUTORIZADA" 
					 	}	
						
Static lSPOCompart	:= (Len(Alltrim(xFilial( "SPO"))) < FWGETTAMFILIAL)   	 


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
	           aRetQuery[nPosFil,5]	:=	Nil       //Query para recuperar as informacoes de cada filial
	           aRetQuery[nPosFil,6]	:=	Nil       //Indicadores da Filial 
 	           aRetQuery[nPosFil,7]	:=	Nil       //Eventos de HExtras da Filial 
	           aRetQuery[nPosFil,8]	:=	Nil       //Se a Query ja foi Executada no Carregamento 
	           aRetQuery[nPosFil,9]	:=	Nil       //Itens a serem apresentados

          EndIF
       EndIF
    EndIF   
	
	//-- Se a filial ainda nao foi processada Acrescenta-a
	IF Empty(nPosFil)
       //-- Acrescenta novas informacoes para a aRetQuery
       AADD(aRetQuery, {FWGETCODFILIAL,  SM0->M0_FILIAL, dPerIni, dPerFim, Nil, Nil, Nil, Nil, Nil } )   
       nPosFil:=Len(aRetQuery)
	EndIF

	//-- Carrega Dados na primeira vez ou na alteracao do periodo de apontamento    
    If lCarregaDados 
        //-- Inicializa as variaveis para cada carrregamento
        aCodigos  		:= {}   
		aIndicadores	:= {}   
		aItensPainel	:= {}
    
    
	    //-- Converte as datas do Periodo de Apontamento para uso na Query
		cPerIni		:= dtos(dPerIni)
		cPerFim		:= dtos(dPerFim)
	    
		 /*/
		��������������������������������������������������������������Ŀ
		� Obtem os eventos dos Identificadores do Ponto				   �
		����������������������������������������������������������������/*/		
	 	nLoops	:= Len(aIDEventos)

		aSp9Cpos 	:={'P9_CODIGO'}
		For nLoop:= 1 To nLoops     
			aRetSP9	:= PosSP9(aIDEventos[nLoop]	,cFilSP9		  ,aSp9Cpos,  02, .F.) //Ordem de Identificador do Ponto     
			//-- Garante que seja impresso qtde nula para Filial sem algum evento  
			If Empty(aRetSP9[1]) 
			   aRetSP9[1] := aIDEventos[nLoop]
			   AADD( aRetSP9, NIL )
			   aRetSP9[2] := STR0001 //"IDENTIFICADOR SEM EVENTO"
			Endif
			Aadd( aIndicadores, { 	aIDEventos[nLoop]		,;  //Id Ponto
				  		   		 	aRetSP9[1]				,;  //Codigo do Evento
								 	aDesc[nLoop]			,;  //Descricao do Evento
							 		0 						;   //Qtde
								 };
				) 
			Aadd( aItensPainel, { 	aRetSP9[1] + " - "	+ 	aDesc[nLoop]	,;  //Codigo do Evento   + " - " + Descricao do Evento 
							 	"" 						,;  //Qtde
							 	CLR_BLACK				,;  //Cor
							 	NIL;                        //Reservado
							 };
				)    				
		Next nLoop	
		
		
		/*/
		��������������������������������������������������������������Ŀ
		� Obtem os Eventos de Horas Extras							   �
		����������������������������������������������������������������/*/
		
		cOrdem	:= '% '+SqlOrder( SP4->( IndexKey(1) ) )+' %'
				    
		cAliasQry := GetNextAlias() 
		
		cTamFil := Space(FWGETTAMFILIAL)
			
		BeginSql Alias cAliasQry
			SELECT 	SP4.P4_FILIAL, SP4.P4_CODAUT, SP4.P4_CODNAUT, SP9.P9_CODIGO
			FROM %table:SP4% SP4 
			INNER JOIN %table:SP9% SP9 
			ON  (( SP4.P4_CODAUT = SP9.P9_CODIGO  ) OR ( SP4.P4_CODNAUT = SP9.P9_CODIGO  )) AND
				( (SP4.P4_FILIAL = SP9.P9_FILIAL) OR (SP9.P9_FILIAL = %exp:cTamFil%) )
			WHERE 	SP4.P4_FILIAL =   %xFilial:SP4% AND
					SP9.%NotDel% AND 
					SP4.%NotDel%  	
			ORDER BY %exp:cOrdem%
		EndSql 
		
		While (cAliasQry)->( (!Eof()) .And.  ( P4_FILIAL == cFilSP4 ) )
			// Procura pelo Evento HE Autorizadas
		 	If ( nPosSP4Aut	:= Ascan(aCodigos, {|x|( x == (cAliasQry)->P4_CODAUT  )  } ) ) == 0 
		 			Aadd( aCodigos, (cAliasQry)->P4_CODAUT + 'A' )	
		 	Endif  
		 	
	 		// Procura pelo Evento HE Nao Autorizadas
			If (nPosSP4Naut := Ascan(aCodigos, {|x|( x == (cAliasQry)->P4_CODNAUT )  } )	) == 0
	 			Aadd( aCodigos, (cAliasQry)->P4_CODNAUT + 'N' )
			Endif
				 
			(cAliasQry)->(DbSkip())
					
		End While  
		
		PonInicInd(@aIndicadores, @aItensPainel)
		

		//-- Fecha a Query sobre as Horas Extras
		(cAliasQry)->(DbCloseArea())	 
        
        If !Empty(cAlias)
			DbSelectArea(cAlias)
		Endif
       	
	   	/*/
		��������������������������������������������������������������Ŀ
		� Monta a Query de carregamento dos eventos					   �
		� Nao foi utilizada a Embeded pois reutilizamos a Query  	   �
		����������������������������������������������������������������/*/	
		
		//-- Cria Query para Banco de Dados
		
		//-- Se existir Codigos de Eventos para Horas Extras  ajusta condicao de Query
	   	cFiltro	:= ""
		If ( !Empty(aCodigos) )
			cFiltro	:=" ( "   
		Endif
		cFiltro	+=" ("    

		//-- Considera os identificadores conforme os arrays de eventos
		For nLoop := 1 To nLoops
			cFiltro += 	" SP9.P9_IDPON  =  '"+ aIDEventos[nLoop]+ "' OR "
		Next nLoop	
		cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  	cFiltro +=" )"
	
		//-- Considera os Eventos de Horas Extras
		If (	nLoops	:= Len(aCodigos) ) > 0
			cFiltro += 		 " OR " 
			cFiltro+=" ("
	
			For nLoop := 1 To nLoops
				cFiltro += 	" SP9.P9_CODIGO  =  '"+ SUBSTR(aCodigos[nLoop],1,3)+ "' OR "
			Next nLoop
				
			cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  		cFiltro +=" ) )"
	  	Endif	
				                                                 
		cFiltro += 		 " AND "
			         
		cFiltro += 		"( "
		cFiltro +=			"SPC.PC_DATA >=  '" + cPerIni + "' AND "
		cFiltro += 			"SPC.PC_DATA <=  '" + cPerFim + "' "
		cFiltro += 		" )"
		
		cFiltro += 		 " AND "
						
		cFiltro += 		"SPC.PC_FILIAL =  '" + cFilAnt + "' AND "
		cFiltro += 		"SP9.P9_FILIAL =  '" + cFilSP9 + "' "
						
	    cFilSP9Cond	:= "SP9.P9_FILIAL = " +  If(Empty(cFilSP9), "'"+Space(FWGETTAMFILIAL)+"'", "SPC.PC_FILIAL") + " "

		cOrdem	:= SqlOrder( SPC->( IndexKey(1) ) )
		cQuery	:= "SELECT 	SPC.PC_FILIAL, SPC.PC_MAT, SPC.PC_DATA, SPC.PC_PD, SPC.PC_PDI,SPC.PC_ABONO, SPC.PC_QUANTC, " 
		cQuery	+= "SPC.PC_QUANTI, SPC.PC_QTABONO, SP9.P9_CODIGO, SP9.P9_IDPON "
		cQuery	+= "FROM "+ RetSqlName("SPC") + " SPC "
		cQuery	+= "INNER JOIN "+ RetSqlName("SP9") + " SP9 "
	    cQuery	+= "ON ( SPC.PC_PD = SP9.P9_CODIGO ) AND "
		cQuery	+= cFilSP9Cond
	    cQuery	+= "WHERE 	SP9.D_E_L_E_T_  = ' ' " + " AND "
	    cQuery	+= "SPC.D_E_L_E_T_  = ' ' " + " AND "
	    cQuery	+= cFiltro
   	    cQuery	+= "ORDER BY " + cOrdem
   	    
   	    cQuery := ChangeQuery(cQuery)

	   	  
		/*/
		��������������������������������������������������������������Ŀ
		� Carrega dados para apresentacao do Indicador				   �
		����������������������������������������������������������������/*/
   		CarregaDados(cQuery, aIndicadores, aCodigos, @aItensPainel, cFilAnt )
   		
  		/*/
		��������������������������������������������������������������Ŀ
		� Transfere as informacoes da filial para o array da empresa   �
		����������������������������������������������������������������/*/
	                             
		aRetQuery[nPosFil,5]:= cQuery				   	// Ultima Query Executada
		aRetQuery[nPosFil,6]:= aClone(aIndicadores)   	// Indicadores 
		aRetQuery[nPosFil,7]:= aClone(aCodigos)   		// Eventos de Horas Extras
		aRetQuery[nPosFil,8]:= aClone(aItensPainel)		// Itens a serem apresentados
		aRetQuery[nPosFil,9]:= .T.				   		// Se a Query ja foi executada 	
		
	Else
		/*/
		��������������������������������������������������������������Ŀ
		� Forca que uma nova leitura seja feita conforme a ultima      �
		� query executada para a Filial								   �
		����������������������������������������������������������������/*/
		aRetQuery[nPosFil,9]:= .F.
	EndIF    
	
	SM0->(DbSkip())
	
End While        

SM0->(RestArea(aAreaSm0))
cFilAnt:= cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif



Return (Nil) 
 

Function PonInicInd(aIndicadores, aItensPainel)
		//-- Garante que seja impresso qtde nula para Filial sem algum evento  
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HEXTRASAUTO"			,;  //Codigo do Evento
							 	STR0017 				,;  //"H.EXTR.AUTORIZ."
								0 						;   //Qtde							 			
							 };
		)     
		     
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"HEXTRASNAUTO"			,;  //Codigo do Evento
							 	STR0018 				,;  //"H.EXTR.NAO AUT."
								0 						;   //Qtde							 			
							 };
		)    
		Aadd( aIndicadores, { 	""						,;  //Id Ponto
			  		   		 	"TOTFUNC"				,;  //Codigo do Evento
							 	STR0019 				,;  //"TOTAL FUNC."	
								0 						;   //Qtde							 			
							 };
		)                      
		
		Aadd( aItensPainel, { 	Space(5) + " - "	+ 	STR0017	,;  //Codigo do Evento   + " - " + "H.EXTR.AUTORIZ."
							 	"" 								,;  //Qtde
							 	CLR_BLUE						,;  //Cor
							 	NIL;                        		//Reservado
							 };
			)                                                      
		Aadd( aItensPainel, { 	Space(5) + " - "	+ 	STR0018	,;  //Codigo do Evento   + " - " + "H.EXTR.NAO AUT."
							 	"" 								,;  //Qtde
							 	CLR_RED							,;  //Cor
							 	NIL;                        		//Reservado
							 };
			) 
		Aadd( aItensPainel, { 	Space(5) + " - "	+ 	STR0019	,;  //Codigo do Evento   + " - " + "TOTAL FUNC."	
							 	"" 								,;  //Qtde
							 	CLR_GREEN						,;  //Cor
							 	NIL;                        		//Reservado
							 };
			) 			                                                    			
Return (Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CarregaDados� Autor � Mauricio MR         � Data � 21/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Soma as horas dos eventos e carrega os indicadores		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CarregaDados(cAliasSPC, cFilAnt,aEventos )		   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aItens do do Painel por referencia						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONONL01  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarregaDados( cQuery, aIndicadores, aCodigos, aItensPainel, cFil  )
Local aStruSPC	:= SPC->(DbStruct())    
Local cAlias	:= Alias()
Local cAliasSPC := GetNextAlias()
Local cEvento   
Local nLoops
Local nLoop
Local nPos1   

Local nTotFunc	:= 0
Local cFilMat	:= Replicate("!", FWGETTAMFILIAL + GetSx3Cache("RA_MAT", "X3_TAMANHO"))

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
	While (cAliasSPC)->( (!Eof()) .And.  ( PC_FILIAL == cFil ) )  
	    
	    If cFilMat <> (cAliasSPC)->(PC_FILIAL+PC_MAT)
		    cFilMat:= (cAliasSPC)->(PC_FILIAL+PC_MAT)
		    nTotFunc ++
	    Endif
		
		// Procura pelo Evento de HExtras  
		If ( nPos1:= Ascan(aCodigos, {|x|(SUBSTR(x,1,3) == (cAliasSPC)->PC_PD ) } ) )  > 0
		   If Substr(aCodigos[nPos1],1,3) == 'A'
			   cEvento:= "HEXTRASAUTO"
			Else                      
			  cEvento:= "HEXTRASNAUTO"
			Endif	   
		Else
			cEvento:= (cAliasSPC)->PC_PD
		Endif
		
	 	If ( nPos1:= Ascan(aIndicadores, {|x|(x[02] == cEvento) } ) )  > 0
	        //Soma as Horas do Evento
	   		aIndicadores[nPos1, 4]:=SomaHoras(aIndicadores[nPos1,4],(cAliasSPC)->PC_QUANTC)	
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

//-- Total de Funcionarios processados
If ( nPos1:= Ascan(aIndicadores, {|x|(x[02] == "TOTFUNC") } ) )  > 0
    //Soma as Horas do Evento
	aIndicadores[nPos1, 4]:=nTotFunc
EndIF  
		
//-- Reposiciona para a area de entrada da funcao
If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif           


//Formata dados para exibicao       
FormataPainel(aIndicadores, @aItensPainel)

Return (Nil)   



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
Local nLoops	:= Len(aIndicadores)

//Formata dados para exibicao       
//-- Corre todos os Eventos de Cada Filial 
For nLoop:=1 to nLoops  
    //-- Formata totalizador  
    If "TOTFUNC"  == aIndicadores[nLoop, 2]
	    aItensPainel[nLoop,2]:= Transform(aIndicadores[nLoop, 4], "@E 999,999,9999")	 //Qtde de Funcionarios
   	Else
	   	aItensPainel[nLoop,2]:= Transform(aIndicadores[nLoop, 4], "@E 999,999,999.99")	 //Qtde Horas Previstas
	Endif   	
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
��� Uso		 � PONONL01  			   									  ���
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
aIndicadores:= aClone(aRetQuery[1,6] )
aEval(aIndicadores,{ |x| x[4] := 0 } )
aItensPainel:= aClone(aRetQuery[1,8] )
aEval(aItensPainel,{ |x| x[2] := " ", x[1]:=Substr(x[1],AT("-", x[1]) + 2) } )
    
nLoops := Len(aRetQuery)
For  nLoop:= 1 to nLoops
	
	//-- Corre todos os indicadores de cada filial
    nLoops1	:= Len(aRetQuery[nLoop,6])
	For nLoop1:=1 to nLoops1 -1
	     aIndicadores[nLoop1, 4]:=SomaHoras( aIndicadores[nLoop1, 4], aRetQuery[nLoop,6, nLoop1, 4] )
	Next nLoop1                                                            

	//-- Soma o total de funcionarios
    aIndicadores[nLoops1, 4]:=( aIndicadores[nLoops1, 4] + aRetQuery[nLoop,6, nLoops1, 4] )

Next nLoop                            

                                         
//-- Formata Saida do Total de Filiais
FormataPainel(aIndicadores, @aItensPainel) 

//-- Cria o Primeiro elemento para conter o total das filiais
AADD(aPainel,{ STR0002, aClone(aItensPainel ) } )  //"TODAS"	

//-- Transfere os indicadores do Painel formatados
aPainel[1,2]:= aClone(aItensPainel ) 

//Formata dados para exibicao       
//-- Corre todas as Filiais 
nLoops	:= Len(aRetQuery)  
For nLoop:=1 to nLoops  
    //-- Carrega os indicadores se para a filial nao foram carregados
    If !aRetQuery[nLoop,9]
    	/*/
		��������������������������������������������������������������Ŀ
		� Carrega dados para apresentacao do Indicador				   �
		����������������������������������������������������������������/*/
		//-- Reinicializa o totalizador de horas
		Aeval(aRetQuery[nLoop, 6],{|x| x[4]:= 0})
   		CarregaDados( aRetQuery[nLoop, 5], aRetQuery[nLoop, 6], aRetQuery[nLoop, 7], @aRetQuery[nLoop, 8], aRetQuery[nLoop, 1]  )
   		aRetQuery[nLoop,9]:= .T.				   		// Indica que a Query ja foi executada 	
    Endif
   	
   	AADD(aPainel,{ aRetQuery[nLoop,1] + "-" + aRetQuery[nLoop,2], aClone(aRetQuery[nLoop,8] ) } ) 	

Next nLoop

Return (Nil)



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



	/*/
		��������������������������������������������������������������Ŀ
		� Carrega Demais eventos segundo os Identificadores do Ponto   �
		����������������������������������������������������������������/*/    
		
        /*
		//-- Cria Query para Banco de Dados
		cFiltro:=" ("
		//-- Considera os identificadores conforme os arrays de eventos
		For nLoop := 1 To nLoops
			cFiltro += 	" SP9.P9_IDPON  =  '"+ aIDEventos[nLoop]+ "' OR "
		Next nLoop	
		cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  	cFiltro += 		" )"
	
		//-- Considera os Eventos de Horas Extras
		If (	nLoops	:= Len(aCodigos) ) > 0
			cFiltro += 		 " OR " 
			cFiltro+=" ("
	
			For nLoop := 1 To nLoops
				cFiltro += 	" SP9.P9_CODIGO  =  '"+ aCodigos[nLoop]+ "' OR "
			Next nLoop
				
			cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
			
	  		cFiltro +=" )"
	  	Endif	
			                                                 
		cFiltro += 		 " AND "
			         
		cFiltro += 		"( "
		cFiltro +=			"SPC.PC_DATA >=  '" + cPerIni + "' AND "
		cFiltro += 			"SPC.PC_DATA <=  '" + cPerFim + "' "
		cFiltro += 		" )"
		
		cFiltro += 		 " AND "
						
		cFiltro += 		"SPC.PC_FILIAL =  '" + cFilAnt + "' AND "
		cFiltro += 		"SP9.P9_FILIAL =  '" + cFilSP9 + "'"
						
		cFiltro := "%" + cFiltro + "%" 
		
		cOrdem	:= '% '+SqlOrder( SPC->( IndexKey(1) ) )+' %'
				    
		cAliasQry := GetNextAlias()
			
		BeginSql Alias cAliasQry
			COLUMN PC_QUANTC 	as Numeric(nTamQuantC,nDecQuantC) 
	        COLUMN PC_QUANTI 	as Numeric(nTamQuantI,nDecQuantI)
	        COLUMN PC_QTABONO 	as Numeric(nTamQtAbono,nDecQtAbono)
	        COLUMN PC_DATA 		as Date
			SELECT 	SPC.PC_FILIAL, SPC.PC_DATA, SPC.PC_PD, SPC.PC_PDI,SPC.PC_ABONO, SPC.PC_QUANTC, 
					SPC.PC_QUANTI, SPC.PC_QTABONO, SP9.P9_CODIGO, SP9.P9_IDPON
			FROM %table:SPC% SPC 
			INNER JOIN %table:SP9% SP9 
			ON SPC.PC_PD = SP9.P9_CODIGO  
			WHERE 	SP9.%NotDel% AND 
					SPC.%NotDel% AND
					%Exp:cFiltro% 	
			ORDER BY %exp:cOrdem%					
		EndSql

*/ 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PonPOnl01 � Autor � Mauricio MR           � Data � 15/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quantidade de Horas no m�s por filial               		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PonPOnl01  										   	  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRet[n][1] = Quantidade de bens nao classificados          ���
���          � aRet[n][2] = Valor dos bens nao classificados              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONLPG1  			   									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function	XPONONL01() 
Local aAreaSm0 	:= SM0->(GetArea())
Local aCodigos  := {}
Local aRet 		:= {}
Local aRetPainel:= {} 
Local aRetSP9	:= {}

Local aSP9Cpos	:= {}

Local cAliasQry 
Local cAliasSPC	
Local cAliasSP9  

Local aIDEventos:= {'001A', '026A', '005A', '006A', '007N', '008A', '009N', '010A', '011N', '012A', '013N', '014A', '019N', '020A'} 
Local cFilDe	:= "" 	// MV_PAR01
Local cFilAte	:= Replicate("Z", FWGETTAMFILIAL) // MV_PAR02

Local cFilSP9	 
Local lSPOCompart	:= (Len(Alltrim(xFilial( "SPO"))) < FWGETTAMFILIAL)

Local cAlias	:= Alias()
Local cFilOld 	:= cFilAnt
                                
LocaL cPerIni	
Local cPerFim	

Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")   

Local lTemDados	:= .F.

Local nLoop
Local nLoops

Local nPos
Local nPos1   

Local nTamQuantC 	:= TamSx3("PC_QUANTC")[1]
Local nDecQuantC 	:= TamSx3("PC_QUANTC")[2]
Local nTamQuantI 	:= TamSx3("PC_QUANTI")[1]
Local nDecQuantI 	:= TamSx3("PC_QUANTI")[2]
Local nTamQtAbono 	:= TamSx3("PC_QTABONO")[1]
Local nDecQTAbono	:= TamSx3("PC_QTABONO")[2]

Local nQtde 	:= 0
LocaL nPerc 	:= 0
Local cQuery

// Processa todo o arquivo de filiais ou apenas a filial atual
SM0->(MsSeek(cEmpAnt+cFilDe,.T.))

While !SM0->(Eof()) .And.(	SM0->M0_CODIGO == cEmpAnt .And. FWGETCODFILIAL <= cFilAte )
	cFilAnt := FWGETCODFILIAL
    cFilSP9	:= xFilial('SP9', cFilAnt)  
                                              
    //-- Se o cadastro de periodos for Exclusivo ou eh a primeira vez
    If !lSPOCompart .OR. dPerIni == Ctod("//")
	    dPerIni   := Ctod("//")
	    dPerFim   := Ctod("//")
		//-- Obtem o periodo aberto
		IF !GetPonMesDat( @dPerIni , @dPerFim , cFilAnt )
		   Exit
		EndIF   
	EndIF
	
	cPerIni		:= dtos(dPerIni)
	cPerFim		:= dtos(dPerFim)

	
 	nLoops	:= Len(aIDEventos)
	//Formata dados para exibicao
	aRet		:= { FWGETCODFILIAL + "-" + SM0->M0_FILIAL, {}} 
	aSp9Cpos	:= {'P9_CODIGO','P9_DESC'}
	For nLoop:= 1 To nLoops     
		aRetSP9	:= PosSP9(aIDEventos[nLoop], cFilSP9, aSp9Cpos, 02, .F.) //Ordem de Identificador do Ponto     
		//-- Garante que seja impresso qtde nula para Filial sem algum evento  
		If Empty(aRetSP9[1]) 
		   aRetSP9[1]	:= aIDEventos[nLoop]
		   aRetSP9[2]	:= STR0001 //"IDENTIFICADOR SEM EVENTO"			
		Endif
		
		Aadd( aRet[2], 	{ 	aIDEventos[nLoop]		,;  //Id Ponto
						 	aRetSP9[1]				,;  //Codigo do Evento
						 	aRetSP9[2]				,;  //Descricao do Evento
						 	0 						,;  //Qtde
						 	CLR_RED					,;  //Cor
						 	NIL;                        //Reservado
						 };
			) 
	Next nLoop	
	
	//-- Cria Query para Banco de Dados		
	cFiltro:=" ("
	
	//-- Considera os identificadores conforme os arrays de eventos
	For nLoop := 1 To nLoops
		cFiltro += 	" SP9.P9_IDPON  =  '"+ aIDEventos[nLoop]+ "' OR "
	Next nLoop	
	cFiltro := Substr(cFiltro,1,Len(cFiltro) -4 )
  	cFiltro += 		" )"
	cFiltro += 		 " AND "
	cFiltro += 		"( "
	cFiltro +=			"SPC.PC_DATA >=  '" + cPerIni + "' AND "
	cFiltro += 			"SPC.PC_DATA <=  '" + cPerFim + "' "
	cFiltro += 		" )"
	cFiltro += 		 " AND "
	cFiltro += 		"SPC.PC_FILIAL =  '" + cFilAnt + "' AND "
	cFiltro += 		"SP9.P9_FILIAL =  '" + cFilSP9 + "'"
			
	cFiltro := "%" + cFiltro + "%" 

	cOrdem	:= '% '+SqlOrder( SPC->( IndexKey(1) ) )+' %'
	    
	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		COLUMN PC_QUANTC 	as Numeric(nTamQuantC,nDecQuantC) 
        COLUMN PC_QUANTI 	as Numeric(nTamQuantI,nDecQuantI)
        COLUMN PC_QTABONO 	as Numeric(nTamQtAbono,nDecQtAbono)
        COLUMN PC_DATA 		as Date
		SELECT 	SPC.PC_FILIAL, SPC.PC_DATA, SPC.PC_PD, SPC.PC_PDI,SPC.PC_ABONO, SPC.PC_QUANTC, 
				SPC.PC_QUANTI, SPC.PC_QTABONO, SP9.P9_CODIGO, SP9.P9_IDPON
		FROM %table:SPC% SPC 
		INNER JOIN %table:SP9% SP9 
		ON SPC.PC_PD = SP9.P9_CODIGO  
		WHERE 	SP9.%NotDel% AND 
				SPC.%NotDel% AND
				%Exp:cFiltro% 	
	EndSql

   	cAliasSPC	:= 	cAliasQry
	cAliasSP9	:= 	cAliasQry

	While (cAliasSPC)->( (!Eof()) .And.  ( PC_FILIAL == cFilAnt ) )
			// Procura pelo Evento 
   	 	If ( nPos1:= Ascan(aRet[2], {|x|(x[02] == (cAliasSPC)->PC_PD ) } ) )  > 0
   	        //Soma as Horas de um elemento anterior de uma filial ja existente
    		aRet[2, nPos1, 4]:=SomaHoras(aRet[2, nPos1,4],(cAliasSPC)->PC_QUANTC)	
       	EndIF				 

		(cAliasSPC)->(DbSkip())
			
	End                  
	//-- Alimenta o retorno para Painel

	nLoops	:= Len(aRet[2])
	//Formata dados para exibicao       
	//-- Corre todos os Eventos de Cada Filial 
	For nLoop:=1 to nLoops
		aRet[2,nLoop]:= { aRet[2, nLoop, 2] + " - " + aRet[2, nLoop, 3]	, 	; //Id do Ponto
							Transform(aRet[2, nLoop, 4], "@E 999999,999,999,999"),	; //Qtde Horas
							CLR_RED,;
							NIL 	;
						  }
	Next nLoop
	
	AADD(aRetPainel,aRet) 	

	SM0->(DbSkip())
	(cAliasQry)->(DbCloseArea())

End         

SM0->(RestArea(aAreaSm0))
cFilAnt := cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return aRetPainel