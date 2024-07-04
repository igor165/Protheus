#INCLUDE "PROTHEUS.CH"  
#INCLUDE "PONONL02.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PonPOnl02 ³ Autor ³ Mauricio MR           ³ Data ³ 23/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indicador Nivel do Banco de Horas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PonPOnl02                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPainel                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PonOnL02                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador  ³ Data   ³ FNC  ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Cecilia C.   ³21/05/14³TPQAN3³Incluido o fonte da 11 para a 12 e efetu-³±± 
±±³             ³        ³      ³tuada a limpeza.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function	PONONL02()   

Local aAreaSm0 			:= SM0->(GetArea())
Local aPainel  			:= {}	     
Local aRetPainel		   := {}
Local aItensPainel

Local cAliasQry 

Local cFilDe			:= "" 	
Local cFilAte			:= Replicate("Z", FWGETTAMFILIAL)

Local cFilSPI
Local cFilSP9  
Local cFilSP9Cond		:=""	 
Local cFilSPICond		:=""	 

Local cAlias			:= Alias()
Local cFilOld 			:= cFilAnt

Local cOrdem

//-- Totalizadores por Filial
Local nProvNormais 		:=0
Local nProvValorizadas 	:=0
Local nDescNormais 		:=0
Local nDescValorizadas 	:=0 
Local nSaldo			:=0
Local nSaldoValorizado	:=0 

//-- Totalizadores Gerais
Local nTProvNormais 	:=0
Local nTProvValorizadas :=0
Local nTDescNormais 	:=0
Local nTDescValorizadas :=0  


 
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Corre todas as Filiais da Empresa							   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/		

SM0->(MsSeek(cEmpAnt+cFilDe,.T.)) 

While !SM0->(Eof()) .And.(	SM0->M0_CODIGO == cEmpAnt .And. FWGETCODFILIAL <= cFilAte )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera a referencia a Filial de Entrada conforme a filial    ³
	//³ lida.														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := FWGETCODFILIAL
    cFilSP9	:= xFilial('SP9', cFilAnt)  
    cFilSPI	:= xFilial('SPI', cFilAnt)  
    
    aItensPainel		:= {}
    
    nProvNormais 		:=0
	nProvValorizadas 	:=0
	nDescNormais 		:=0
	nDescValorizadas 	:=0 
 	nSaldo				:=0
 	nSaldoValorizado	:=0 	

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Obtem os Eventos de Horas Extras							   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	
	cFilSP9Cond	:= "% SP9.P9_FILIAL = " + IIf(Empty(cFilSP9), "'"+Space(FWGETTAMFILIAL)+"'", "SPI.PI_FILIAL") + "%"
	cFilSPICond	:= "% SPI.PI_FILIAL = '" + cFilSPI + "' %"
	
	cOrdem		:= '% '+SqlOrder( SPI->( IndexKey(1) ) )+' %'
			    
	cAliasQry 	:= GetNextAlias()
		
	BeginSql Alias cAliasQry
		SELECT 	SPI.PI_FILIAL, SP9.P9_TIPOCOD, SPI.PI_QUANT, SPI.PI_QUANTV, SPI.PI_STATUS
		FROM %table:SPI% SPI 
		INNER JOIN %table:SP9% SP9 
		ON  (		( SPI.PI_PD = SP9.P9_CODIGO  )   AND
			 		(	 %Exp:cFilSP9Cond% )
			 )
		WHERE   %exp:cFilSPICond% AND 
				SPI.PI_STATUS = ' ' AND
				SP9.%NotDel% AND 
				SPI.%NotDel% 
 		ORDER BY %exp:cOrdem%					 					  
			 
	EndSql 
	
	While (cAliasQry)->( (!Eof()) .And.  ( PI_FILIAL == cFilSPI ) )
		
	//-- Obtem o tipo do evento (Provento ou Desconto)

	   //-- Provento
	   IF (cAliasQry)->P9_TIPOCOD $'1.3'
	   		nProvNormais 		:=SomaHoras(nProvNormais		, (cAliasQry)->PI_QUANT		)
	   		nPovValorizadas 	:=SomaHoras(nProvValorizadas	, (cAliasQry)->PI_QUANTV	) 			   		
	   Else         
	   		//-- Desconto
	   		nDescNormais 		:=SomaHoras(nDescNormais		, (cAliasQry)->PI_QUANT		)
	   		nDescValorizadas 	:=SomaHoras(nDescValorizadas	, (cAliasQry)->PI_QUANTV	) 			   		
	   EndIF

		(cAliasQry)->(DbSkip())
				
	End While  
	
	 nTProvNormais 		:=SomaHoras( nTProvNormais		, nProvNormais		)
	 nTProvValorizadas 	:=SomaHoras( nTProvValorizadas	, nProvValorizadas	)
	 nTDescNormais 		:=SomaHoras( nTDescNormais		, nDescNormais		)
	 nTDescValorizadas 	:=SomaHoras( nTDescValorizadas	, nDescValorizadas	)  

	//-- Fecha a Query sobre as Horas Extras
	(cAliasQry)->(DbCloseArea())	 
                 
        If !Empty(cAlias)
		DbSelectArea(cAlias)
	Endif                   
	
	Aadd( aItensPainel, { 	STR0001				   								,;  //"Provento Normal"
				 			Transform(nProvNormais	, "@E 999999,999,999.99") 	,;  //Qtde
						 	CLR_BLACK											,;  //Cor
						 	NIL													;  	//Reservado
						 };
		)  	
	Aadd( aItensPainel, { 	STR0002				   								,;  //"Provento Valorizado"
				 			Transform(nProvValorizadas	, "@E 999999,999,999.99") 	,;  //Qtde
						 	CLR_BLUE											,;  //Cor
						 	NIL													;  	//Reservado
						 };
		) 
	      
	Aadd( aItensPainel, { 	STR0003				   								,;  //"Desconto Normal"
				 			Transform(nDescNormais	, "@E 999999,999,999.99") 	,;  //Qtde
						 	CLR_GRAY											,;  //Cor
						 	NIL													;  	//Reservado
						 };
		) 
	Aadd( aItensPainel, { 	STR0004				   								,;  //"Desconto Valorizado"		
				 			Transform(nDescValorizadas, "@E 999999,999,999.99"),;  //Qtde
						 	CLR_RED												,;  //Cor
						 	NIL													;  	//Reservado
						 };
		) 	

	Aadd( aItensPainel, { 	STR0006				   								,;  //"Saldo Normal"		
				 			Transform(SubHoras(	nProvNormais					,;
				 								 nDescNormais)					,;
				 					 "@E 999999,999,999.99")					,;  //Qtde
						 	CLR_HBLUE											,;  //Cor
						 	NIL													;  	//Reservado
						 };
		) 					
		
	Aadd( aItensPainel, { 	STR0007				   								,;  //"Saldo Valorizado"		
				 			Transform(SubHoras(nProvValorizadas, 				;
				 								nDescValorizadas)				,;
				 					 "@E 999999,999,999.99")					,;  //Qtde
						 	CLR_HGREEN											,;  //Cor
						 	NIL													;  	//Reservado
						 };
		) 					

	AADD(aPainel, { FWGETCODFILIAL + " - " + SM0->M0_FILIAL, aClone(aItensPainel) } ) 	 	   

	SM0->(DbSkip())
	
End While      

aRetPainel	:= { aClone( aPainel[1] ) }

aRetPainel[1, 1 ]    	:=  STR0005 // "TODAS"
aRetPainel[1,2,1,2]    	:= 	Transform( nTProvNormais		,"@E 999999,999,999.99")
aRetPainel[1,2,2,2]   	:= 	Transform( nTProvValorizadas    ,"@E 999999,999,999.99")
aRetPainel[1,2,3,2]   	:= 	Transform( nTDescNormais        ,"@E 999999,999,999.99")                  
aRetPainel[1,2,4,2]  	:= 	Transform( nTDescValorizadas    ,"@E 999999,999,999.99")
aRetPainel[1,2,5,2]  	:= 	Transform( SubHoras(nTProvNormais,;
										 nTDescNormais)    ,"@E 999999,999,999.99")
aRetPainel[1,2,6,2]  	:= 	Transform( SubHoras(nTProvValorizadas,;
										 nTDescValorizadas) ,"@E 999999,999,999.99")

aEVAL(aPainel,{|x| AADD(aRetPainel, x)  } )

SM0->(RestArea(aAreaSm0))
cFilAnt:= cFilOld

If !Empty(cAlias)
	DbSelectArea(cAlias)
Endif

Return (aRetPainel) 