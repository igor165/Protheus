#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdC

Realiza a Geracao do Bloco C do Sped Fiscal

@param	aWizard	 ->	Wizard de geracao do Arquivo
		cFilSel	 ->	Variavel com as Filiais escolhidas pelo Usuario
		lConv115    -> Informa se a empresa se Enquadra no Convenio
		cPerfilSPD  -> Indica qual o perfil do contribuinte
		cJobAux     -> Nome da variavel responsavel pelo controle de termino do Bloco - Mult Thread
		
@return aTotRegC

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function TafxSpdC( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux ) 

Local cStrTxt	:=	""

Local nlI     := 1    
Local nTotReg := 1

//Bakup da filial antes do inicio do processamento
Local cFilBkp :=	cFilAnt	

Local lSave	 :=	.F.  
Local lGerC001 := .F. 

Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )

Private aTotRegC := {}
Private aInfoGrv := {}

//Deve ser private para geracao dos registros do bloco 0 gerados durante
//o processamento dos movimentos
Private aWizardBc  := aWizard
Private cFilSelBc  := cFilSel
Private cTabSpd    := cTabSped

Default cJobAux := ""

//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
Begin Sequence
	
	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSelBc, 2, 2 )
	
	//Array com as informações a serem geradas na tabela compartilhada
	//Filial + Data Inicio + Data Final + Bloco + Sequencializador
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "C", 0 }
	
	
	//Registro C100
	cStrTxt := ""
	BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C100", @lGerC001 )

	//Registro C300
	cStrTxt := ""   
	BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C300", @lGerC001 )
	
	//Registro C400
	cStrTxt := ""   
	BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C400", @lGerC001 )   

	//Caso Não seja do Convenio 9515 ICMS
	If !lConv115
		
		//Registro C500	
		cStrTxt := ""
		BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C500", @lGerC001 )	   
		
		//Registro C600
		cStrTxt := ""
		BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C600", @lGerC001 )
		 
	Else	
		//Registro C700
		cStrTxt := ""
		BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C700", @lGerC001 )
			 
	EndIf
	
	//Registro C800
	cStrTxt := ""
	BlocoC( aWizardBc, cFilSelBc, @cStrTxt, "C800", @lGerC001 ) 
	
	//Tratamento para quando nao existirem informacoes para o Bloco C
	If !lGerC001
		cStrTxt := ""
		RegC001( cStrTxt, "1" ) 
	EndIf
	
	//Totalizacao dos Registros 
	For nlI := 1 To Len( aTotRegC )
		nTotReg += aTotRegC[nlI][2]
	Next           
	
	//Registro C990
	Reg990Spd( "C", cTabSped, cFilSel, aWizard )                   
	
	//Restauro a Filial salva no inicio do processamento
	cFilAnt	:=	cFilBkp 

Recover
	lFound := .F. 
		
End Sequence

//Tratamento para quando ocorrer erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indico Que ocorreu Erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()
	
Else
	//Status 1 - Indico que o bloco foi encerrado corretamente para processamento Mult Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

	//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
	xTafCtlObr( "2", "C", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
	
EndIf
			
Return ( Nil )              

//-------------------------------------------------------------------
/*{Protheus.doc} BlocoC

Realiza a Geracao do Bloco C

@Param	aWizardBc     -> Wizard de Geracao
		cFilSelBc     -> Filiais para geração
		cStrTxt     -> String para gravacao do Registro 				
		cBlocGer    -> Bloco de Geracao que sera Emitido      
		lGerC001    -> Flag para verificar se ja foi gerado o registro C001
		lConv115    -> Informa se a empresa se Enquadra no Convenio  
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoC( aWizardBc, cFilSelBc, cStrTxt, cBlocGer, lGerC001, lConv115 )  

Local cStrTxt02   := ""   
Local cStrTxt03   := ""       
Local cStrTxt04   := ""

Local cFilBkp     := ""
Local cDtEmiss    := ""
Local cDtEntSai   := "" 
Local cDesComp    := ""  
Local cCodEqp     := "" 
Local cDtMovto    := ""  
Local cCodTot     := "" 
Local cCodClass   := "" 
Local cIndRec     := ""
Local cCodPar     := ""  
Local cCodInf     := ""
Local cCodObs     := ""  
Local cIndFrt     := ""

Local cChvNf      := "" 
Local cChvIte     := ""

Local cChvC495    := ""
Local cChvC600    := "" 
Local cChvC700    := ""
Local cChvC790    := "" 
Local cChvC800    := ""
Local cChvC850    := ""  
Local cChvC860    := ""
Local cChvC890    := ""

Local cNumIni	  := ""
Local cNumFin     := ""  
Local cDtIni      := ""
Local cDtFin      := "" 
Local cCstIcms    := ""
Local cSerie      := ""

Local lC490Cons   := .F.   
Local lC495Cons   := .F.
Local lC700Cons   := .F.
Local lC800Cons   := .F.

Local cMvUF :=  Alltrim( GetNewPar( "MV_TAFUF", "SP" ) )

Local nPosC490  := 0
Local nPosC495  := 0
Local nPosC590  := 0
Local nPosC610  := 0  
Local nPosC690  := 0
Local nPosC790  := 0   
Local nPosC791  := 0   
Local nPosC190  := 0


Local nContNFN  := 0
Local nContNFC  := 0
Local nVlOperIt := 0
Local nVLPIS		:= 0
Local nVLCOF		:= 0
Local nVLICMS 	:= 0
local nVLPISST 	:= 0
Local nVLCOFST 	:= 0

Local nX			:=	0
Local nPos			:=	0

Local aNF         := {} 
Local aItensNF    := {}   
Local aAux        := {}
Local aTrib       := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    
Local aTribNF     := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    
                      
Local aTotRegC300 := {} 
Local aRegC190    := {}
Local aRegC390    := {}
Local aRegC320    := {}
Local aRegC321    := {}  
Local aRegC460    := {}
Local aRegC470    := {}   
Local aRegC490    := {}  
Local aRegC495    := {}  
Local aRegC500    := {}
Local aRegC510    := {}  
Local aRegC590    := {}     
Local aRegC610    := {}  
Local aRegC690    := {}
Local aRegC700    := {}
Local aRegC790    := {}        
Local aRegC791    := {}  
Local aRegC800    := {}     
Local aRegC850    := {}     
Local aRegC860    := {}

Local aParam      := Array( 3 )

Local lNfCanc     := .F.

Local cAliasC32   := "C32"   
Local cAliasC0K   := "C0K"   
Local cAliasC1H   := "C1H"
Local cAliasC3Q   := "C3Q"  
Local cAliasC21   := "C21"    
Local cAliasC2C   := "C2C"
Local cAliasC3R   := "C3R"

Local cAliasC100  := GetNextAlias()    
Local cAliasC300  := GetNextAlias()  
Local cAliasC401  := GetNextAlias()  
Local cAliasC402  := GetNextAlias()  
Local cAliasC403  := GetNextAlias()  
Local cAliasC500  := GetNextAlias()  
Local cAliasC600  := GetNextAlias()  
Local cAliasC700  := GetNextAlias()  
Local cAliasC800  := GetNextAlias()  
Local cDtFinPer   := Dtos(aWizardBc[1][2])   
		        
//Realiza a Geracao do Registro C100 e Filhos
If cBlocGer == "C100"	
        								
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC100, aWizardBc, "C100", cFilSelBc )     
    
    cFilBkp := cFilAnt

    While !(cAliasC100)->( Eof() )                                         
        	          
	    cFilAnt := (cAliasC100)->C20_FILIAL        	                  	    	    		
	    
	    If !lGerC001
			RegC001( cStrTxt, "0" ) 
			
			lGerC001 := .T.
		EndIf
		
		//Verifica se as Notas sao do Tipo Notas Fiscais Canceladas/   
		//Cancelada Extemporaneo/ NFe Denegada Inutilizada Nao Devem   
		//ser gerados Filhos                                           	    	
	    lNfCanc := (cAliasC100)->C02_CODIGO == "02" .Or. (cAliasC100)->C02_CODIGO == "03" .Or. ;
				   (cAliasC100)->C02_CODIGO == "04" .Or. (cAliasC100)->C02_CODIGO == "05"		     							   
		    			
		    			
		//Trato Campos de Data para Geracao dos Registros
		cDtEmiss  := Right( (cAliasC100)->C20_DTDOC, 2 ) + SubStr( (cAliasC100)->C20_DTDOC, 5, 2 ) + Left( (cAliasC100)->C20_DTDOC, 4 )
		cDtEntSai := Right( (cAliasC100)->C20_DTES, 2 ) + SubStr( (cAliasC100)->C20_DTES, 5, 2 ) + Left( (cAliasC100)->C20_DTES, 4 )				   
		
		cCodObs := ""
		
		If (cAliasC2C)->( MsSeek( xFilial(cAliasC2C) + (cAliasC100)->C20_CHVNF ) )
			If (cAliasC3R)->( MsSeek( xFilial(cAliasC3R) + (cAliasC2C)->C2C_CODOBS ) )
				cCodObs := 	(cAliasC3R)->(C3R_CODIGO )			
			EndIf					
		EndIf	
							
		//Neste momento gravo as informacoes da NF que esta sendo processada para
		//abaixo realizar a emissao dos registros do bloco C100 e filhos
		
		If (cAliasC100)->C01_CODIGO == '55'			 
			cSerie := StrZero( val( (cAliasC100)->C20_SERIE),3)			
		Else
			cSerie := (cAliasC100)->C20_SERIE
		EndIf		
		         
		aNF := {}
		Aadd ( aNF, {})				
		aAdd ( aNF[1], (cAliasC100)->C20_CHVNF  )   //01 - Chave da NF
		aAdd ( aNF[1], (cAliasC100)->C30_NUMITE )   //02 - Numero do Item
		aAdd ( aNF[1], (cAliasC100)->C20_INDOPE )   //03 - Indicador de Operacao
		aAdd ( aNF[1], (cAliasC100)->C20_INDEMI )   //04 - Indicador de Emissao
		aAdd ( aNF[1], (cAliasC100)->C01_CODIGO )   //05 - Modelo da NF
		aAdd ( aNF[1], (cAliasC100)->C02_CODIGO )   //06 - Situacao da NF
		aAdd ( aNF[1], cSerie  )  					 //07 - Serie da NF
		aAdd ( aNF[1], (cAliasC100)->C20_NUMDOC )   //08 - Numero da NF
		aAdd ( aNF[1], allTrim( (cAliasC100)->C20_CHVELE ) )   //09 - Chave Eletronica da NF		
		aAdd ( aNF[1], (cAliasC100)->( C1H_CODPAR ) ) //10 - Codigo do PArticipante
		aAdd ( aNF[1], cDtEmiss  )					 //11 - Data de Emissao               	 
		aAdd ( aNF[1], cDtEntSai )					 //12 - Data de Entrada/Saida               	 
		aAdd ( aNF[1], (cAliasC100)->C20_VLDOC  )   //13 - Valor do Documento

		 //Tratamento para geracao do Indicador de pagamento
		 //conforme layout do Sped Fiscal		 
		 If DToS( aWizardBc[01][01] ) >= "20120701"
		 	If AllTrim((cAliasC100)->C20_INDPAG ) $ ( "2|9" )
		 			aAdd ( aNF[1], "2" )   									  //14 - Indicador de Pgto
		 	Else
		 		aAdd ( aNF[1], AllTrim((cAliasC100)->C20_INDPAG ) )   //14 - Indicador de Pgto
		 	EndIf	  		 		 
		 Else
		 	If AllTrim((cAliasC100)->C20_INDPAG ) $ ( "2|9" )
		 			aAdd ( aNF[1], "9" )   									  //14 - Indicador de Pgto
		 	Else
		 		aAdd ( aNF[1], AllTrim((cAliasC100)->C20_INDPAG ) )   //14 - Indicador de Pgto
		 	EndIf		 
		 EndIf
		 
		aAdd ( aNF[1], (cAliasC100)->C20_VLDESC )   //15 - Valor do Desconto
		aAdd ( aNF[1], (cAliasC100)->C20_VLABNT )   //16 - Valor Abatimento/Nao tributado       
		aAdd ( aNF[1], (cAliasC100)->C20_VLMERC )   //17 - Valor Total de Mercadorias
		
		If DToS( aWizardBc[01][01] ) >= "20120101"
			aAdd ( aNF[1], (cAliasC100)->C0X_CODIGO )
		Else
			aAdd ( aNF[1], (cAliasC100)->C0X_CODIGO )   //18 - Indicador do Frete
		EndIF
		
		aAdd ( aNF[1], (cAliasC100)->C20_VLRFRT )   //19 - Valor do Frete
		aAdd ( aNF[1], (cAliasC100)->C20_VLRSEG )   //20 - Valor do Seguro
		aAdd ( aNF[1], (cAliasC100)->C20_VLOUDE )	  //21 - Valor de Outras Despesas	    
		aAdd ( aNF[1], (cAliasC100)->C20_FILIAL )	  //22 - Filial

		aTribNF := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    
				    		                		
		//Neste momento realizo o While pela Chave da NF
		While !(cAliasC100)->( Eof() )	.And. aNf[1][1] == (cAliasC100)->C20_CHVNF 	    	    										   		                                                                                              		   				
            	            		      
			//Zero Array com Informacoes dos tributos referentes ao item da NF
			aTrib     := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    
							
			//Por se tratar de um campo Memo, deve-se retornar na query o RECNO e atraves
			//do Goto posicionar na tabela fisica para obter a informacao                
			cDesComp  := " "
			If (cAliasC100)->C30REC > 0      
				DbSelectArea("C30")
				C30->(MsGoto((cAliasC100)->C30REC))
				cDesComp := STRTRAN(C30->C30_DESCRI, CRLF, "")         
				DbSelectArea(cAliasC100)
			EndIf
	        
	       if empty( cDesComp )
	       	cDesComp := alltrim( (cAliasC100)->C1L_DESCRI )
	       endif
	        
			//Neste momento gravo as informacoes dos itens da NF que sera processada para
			//abaixo realizar a emissao dos registros filhos                             		            
			aItensNF := {}
			
			Aadd ( aItensNF, {})				
			aAdd ( aItensNF[1],  (cAliasC100)->C30_NUMITE ) //01 - Numero do Item
			aAdd ( aItensNF[1],  (cAliasC100)->( C1L_CODIGO ) ) //02 - Codigo do Item
			aAdd ( aItensNF[1],  cDesComp )                  //03 - Descricao Complementar do Item
			aAdd ( aItensNF[1],  (cAliasC100)->C30_QUANT  ) //04 - Quantidade do Item						
			aAdd ( aItensNF[1],  Right( Alltrim( (cAliasC100)->C1J_CODIGO),6) ) //05 - Codigo da Unidade de Medida
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VLOPER )  //06 - Valor da Operacao
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VLDESC ) //07 - Valor do Desconto						
			aAdd ( aItensNF[1],  (cAliasC100)->C30_INDMOV ) //08 - Indicador de Movimento
			aAdd ( aItensNF[1],  (cAliasC100)->C0Y_CODIGO ) //09 - CFOP
			aAdd ( aItensNF[1],  Alltrim( (cAliasC100)->C1N_CODNAT ) ) //10 - Codigo da Natureza da Operacao	 											
			aAdd ( aItensNF[1],  (cAliasC100)->C30_INDAPU ) //11 - Indicador de Apuracao
			aAdd ( aItensNF[1],  (cAliasC100)->( C1O_CODIGO ) ) //12 - Codigo da Conta Contabil								
			aAdd ( aItensNF[1],  (cAliasC100)->C3U_CODIGO ) //13 - Codigo Selo IPI								
			aAdd ( aItensNF[1],  (cAliasC100)->C30_QTDSEL ) //14 - Quantidade Selo IPI														
			aAdd ( aItensNF[1],  (cAliasC100)->C30_QTDPAD ) //15 - Quant Pad																	
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VLUNID ) //16 - Valor Unitario																	
			aAdd ( aItensNF[1],  (cAliasC100)->C3T_CODIGO ) //17 - Cod. Classe Enq IPI       	 
			aAdd ( aItensNF[1],  (cAliasC100)->C30_BSTORI ) //18 - BC ICMS/ST Origem         			
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VSTREP ) //19 - Vlr ICMSST Origem        	 			
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VSTCOM ) //20 - Vlr ICMSST Complementar  	 			
			aAdd ( aItensNF[1],  (cAliasC100)->C30_BCRETQ ) //21 - BC ICMS/ST Retido        	 			
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VLRET  ) //22 - Vlr ICMSST Retido
			aAdd ( aItensNF[1],  (cAliasC100)->C30_VLRET  ) //23 - Vlr ICMSST Retido
			aAdd ( aItensNF[1],  (cAliasC100)->C30_TOTAL  ) //24 - Vlr Total Item
					   		
			//Preencher somente se o campo CST NF COMP esta preenchido
			If !Empty((cAliasC100)->(C14_CODIGO))    	 															
				aAdd ( aItensNF[1],  (cAliasC100)->( C03_CODIGO + C14_CODIGO )  )//23 - CST ICMS Para Notas Fiscais de Complemento
			Else
				aAdd ( aItensNF[1],  ''  )
			EndIf
																																																				
			//O retorno da Query Traz as informacoes a Nivel de tributos de Item, sendo assim     
			//tenho que realizar o While Abaixo para Concatenar os valores de tributos para o Item
			//da NF, estas informacaoes serao necessarias para a geracao dos blocos abaixo        
			While !(cAliasC100)->( Eof() )	.And. aNf[1][1] == (cAliasC100)->C20_CHVNF .And. aItensNf[1][1] == (cAliasC100)->C30_NUMITE
					
				//Funcao que realiza a Soma dos tributos por item
				A117GetTrib( cAliasC100, @aTrib )			    
				A117GetTrib( cAliasC100, @aTribNF )
				
				(cAliasC100)->(DbSkip())					
			EndDo 	 
            			
			//Neste primeiro momento realizarei a emissao dos itens da Nota Fiscal (C170)
			//e seus respectivos Filhos.                                          		  
			                                                     
			//Devem ser gerados apenas para NF que nao estiverem como Canceladas/        
			//Denegadas/Inutilizadas			                                                     
			If !lNfCanc					    				    								    			            			
				
				if Alltrim(aNF[1][5]) <> "65"
					RegC170( @cStrTxt02, aItensNF, aNf, aTrib )
				EndIF
				
				//Se o campo referente ao CST de ICMS para Notas Fiscais de Complemento              
				//nao estiver vazio, utilizo o mesmo para geracao do registro, caso contrario utilizo
				//o CST amarrado natabela C35 ( Tributo do Item )                                    			    
				If Empty( aTrib[10] ) 
					cCstIcms :=  Alltrim( aItensNF[1][25] )
				Else
					cCstIcms :=  Alltrim( aTrib[10] )  		
				EndIf			    
			    
				If Len( aRegC190 ) <= 0 .Or. ( nPosC190 := aScan( aRegC190, { |x| x[2] == cCstIcms .And. x[3] == aItensNF[1][9] .And. ;
																				    x[4] == aTrib[12] } ) ) <= 0 								
				   	
					aAdd ( aRegC190, {} )																		
					nPosC190 := Len( aRegC190 )
					
					aAdd ( aRegC190[nPosC190], "C190"    )       	//01 - REG
					aAdd ( aRegC190[nPosC190], cCstIcms )  		   //02 - CST_ICMS	 		
					aAdd ( aRegC190[nPosC190], aItensNF[1][9] )   //03 - CFOP
					aAdd ( aRegC190[nPosC190], aTrib[12] )         //04 - ALIQ_ICMS
					aAdd ( aRegC190[nPosC190], 0 )    				//05 - VL_OPR
					aAdd ( aRegC190[nPosC190], 0 )                 //06 - VL_BC_ICMS
					aAdd ( aRegC190[nPosC190], 0 )                 //07 - VL_ICMS
					aAdd ( aRegC190[nPosC190], 0 )		            //08 - VL_BC_ICMS_ST																						
					aAdd ( aRegC190[nPosC190], 0 )		            //09 - VL_ICMS_ST
					aAdd ( aRegC190[nPosC190], 0 )         			//10 - VL_RED_BC
					aAdd ( aRegC190[nPosC190], 0 )         			//11 - VL_IPI
					aAdd ( aRegC190[nPosC190], "" )						//12 - COD_OBS												
				
				EndIf      
				
				aRegC190[nPosC190][5]  += aItensNF[1][6]      		//05 - VL_OPR
				aRegC190[nPosC190][6]  += aTrib[1]            		//06 - VL_BC_ICMS   	
				aRegC190[nPosC190][7]  += aTrib[2]            		//07 - VL_ICMS
				aRegC190[nPosC190][8]  += aTrib[3]  		   		//08 - VL_BC_ICMS_ST																						
				aRegC190[nPosC190][9]  += aTrib[4]            		//09 - VL_ICMS_ST
				aRegC190[nPosC190][10] += aTrib[31]           		//10 - VL_RED_BC			    
				aRegC190[nPosC190][11] += aTrib[5]           		//10 - VL_RED_BC			    
							    
			EndIf         
													
	    EndDo  //Final Item da NF                                                                     
    		    	           				
    		    	           							    
		RegC100( aWizardBc, @cStrTxt, @cStrTxt02, @cStrTxt03, aNF, aTribNF, lNfCanc )
		RegC190( @cStrTxt02, aRegC190 )				 
	    	    
		//Neste momento agrupo os complementos da NF com os dados do   
		//item da NF para que sejam gerados na ordem correta no arquivo
	    cStrTxt := ( cStrTxt + cStrTxt02 + cStrTxt03 )  
	    
	    aInfoGrv[5]++	    
	    If !Empty( cStrTxt )
	    	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
	    EndIf	 						                                                       
	    	    
	    cStrTxt   := ""
	    cStrTxt02 := ""     
	    cStrTxt03 := ""     
	    
	    aRegC190 := {}
	    	    														  
	EndDo // Final da Nota Fiscal
    (cAliasC100)->(DbCloseArea())    
    
    cFilAnt := cFilBkp

//Realiza a Geracao do Registro C300 e Filhos   
ElseIf cBlocGer == "C300"	
                        
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC300, aWizardBc, "C300", cFilSelBc )     
	
    cFilBkp := cFilAnt    	

    While !(cAliasC300)->( Eof() )                                         
    
	    cFilAnt := (cAliasC300)->C20_FILIAL    	                  	    	    										   	

		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf
			
		//Trato Campos de Data para Geracao dos Registros
		//Em formato de período MMAAAA
		cDtEmiss  := Right( (cAliasC300)->C20_DTDOC, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 5, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 3, 2 ) 
		
		//Em formato de data DDMMAAAA
		dDtEmiss  := Right( (cAliasC300)->C20_DTDOC, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 5, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 1, 4 ) 
		
		//Neste momento populo o array aTotRegC300 com os valores do periodo
		//para a geracao do registro C300                                   
		aTotRegC300 := {}
		Aadd ( aTotRegC300, {})	

		aAdd ( aTotRegC300[1], (cAliasC300)->C20_SERIE  )   //01 - Serie da NF 
		aAdd ( aTotRegC300[1], (cAliasC300)->C20_SUBSER )   //02 - SubSerie da NF
		aAdd ( aTotRegC300[1], cDtEmiss  )					 //03 - Data de Emissao              			 	 
		aAdd ( aTotRegC300[1], 0  ) 					     //04 - Valor do Documento          
		aAdd ( aTotRegC300[1], 0  ) 					     //05 - Valor do Pis por Registro C300          
		aAdd ( aTotRegC300[1], 0  ) 					     //06 - Valor do Cofins por registro C300
		aAdd ( aTotRegC300[1], (cAliasC300)->( C1O_CODIGO ) )   //07 - Codigo da Conta Contabil   
		aAdd ( aTotRegC300[1], 0 )  						 //08 - Valor Total das Mercadorias
		aAdd ( aTotRegC300[1], 0 )  						 //09 - Valor Total dos Descontos
		aAdd ( aTotRegC300[1], (cAliasC300)->C20_NUMDOC )   //10 - Numero da NF Inicial 
		aAdd ( aTotRegC300[1], (cAliasC300)->C20_CHVNF  )   //11 - Chave da NF
		aAdd ( aTotRegC300[1], ""  ) 						 //12 - Nota Fiscal Inicial
		aAdd ( aTotRegC300[1], ""  )   						 //13 - Nota Fiscal Final
														
		//Atualizo a Variavel de Doc Inicial e Final com o numero da primeira
		//nota fiscal modelo 02 encontrada                                   
		cNumIni := (cAliasC300)->C20_NUMDOC
		cNumFin := (cAliasC300)->C20_NUMDOC  
		
		//Monta Chave para geracao do Registro C300 considerando as 
		//quebras solicitadas pelo Layout                           
		While !(cAliasC300)->( Eof() )	.And. ( aTotRegC300[1][3] + aTotRegC300[1][1] + aTotRegC300[1][2] + aTotRegC300[1][7] ) ==  ;				
												( Right( (cAliasC300)->C20_DTDOC, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 5, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 3, 2 ) + C20_SERIE + C20_SUBSER + C1O_CODIGO ) 
		
																				
			//Atualiza a Chave do Array aNF de acordo com a NF que esta sendo executada
			aTotRegC300[1][10] := (cAliasC300)->C20_NUMDOC
			aTotRegC300[1][11] := (cAliasC300)->C20_CHVNF							
												
			//Tratamento para se verificar a Numeracao da Nota Fiscal Inicial so periodo
            If (cAliasC300)->C20_NUMDOC < cNumIni  
				cNumIni := (cAliasC300)->C20_NUMDOC
			EndIf 
							
			//Tratamento para se verificar a Numeracao da Nota Fiscal Final do Periodo
			If (cAliasC300)->C20_NUMDOC	 > cNumFin 
				cNumFin := (cAliasC300)->C20_NUMDOC
			EndIf 
														
			//Somente deve-se considerar o valor dos Documentos Fiscais com
			//situacao diferente de Cancelado                              
		    If (cAliasC300)->C02_CODIGO == "02" .And. 	SubStr( aWizardBc[2][2], 1, 1 ) == "B"	    		    	            		    		    											    													
			    RegC310( @cStrTxt02, aTotRegC300 )		   			    
			Else
			   aTotRegC300[1][4] += (cAliasC300)->C20_VLDOC							
			EndIf  	
			
			//Neste momento gravo as informacoes da NF que esta sendo processada para
			//abaixo realizar a emissao dos registros do bloco C350 e filhos         				
			aNF := {}
			Aadd ( aNF, {})				
			aAdd ( aNF[1], (cAliasC300)->C20_CHVNF  )   //01 - Chave da NF
			aAdd ( aNF[1], (cAliasC300)->C01_CODIGO )   //02 - Modelo da NF
			aAdd ( aNF[1], (cAliasC300)->C20_SERIE  )   //03 - Serie da NF 
			aAdd ( aNF[1], (cAliasC300)->C20_SUBSER )   //04 - SubSerie da NF
			aAdd ( aNF[1], (cAliasC300)->C20_NUMDOC )   //05 - Numero da NF Inicial 
			aAdd ( aNF[1], "" )    						 //06 - Numero da NF Final 			
			aAdd ( aNF[1], dDtEmiss  )					//07 - Data de Emissao              			 	 
			aAdd ( aNF[1], (cAliasC300)->C20_VLDOC  )   //08 - Valor do Documento          
			aAdd ( aNF[1], 0  ) 					     //09 - Valor do Pis por Registro C300          
			aAdd ( aNF[1], 0  ) 					     //10 - Valor do Cofins por registro C300
			aAdd ( aNF[1], (cAliasC300)->C1O_CODIGO )   //11 - Codigo da Conta Contabil   
			aAdd ( aNF[1], (cAliasC300)->C02_CODIGO )   //12 - Situacao do Documento Fiscal   			
			aAdd ( aNF[1], (cAliasC300)->C1H_CNPJ   )   //13 - CNPJ do Destinatario
			aAdd ( aNF[1], (cAliasC300)->C1H_CPF    )   //14 - CPF do Destinatario
			aAdd ( aNF[1], 0 )  						 //15 - Valor Total das Mercadorias
			aAdd ( aNF[1], 0 )  						 //16 - Valor Total dos Descontos
			aAdd ( aNF[1], 0  ) 					     //17 - Valor do Pis por NF
			aAdd ( aNF[1], 0  ) 					     //18 - Valor do Cofins por NF
			
			nContItNf := 1
																						
			//Neste momento zero a variavel responsavel por aglutinar os Valores
			//dos Itens da NF                                                   
			aTrib     := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }
			
			While !(cAliasC300)->( Eof() )	.And. ( aTotRegC300[1][3] + aTotRegC300[1][1] + aTotRegC300[1][2] + aTotRegC300[1][7] + aTotRegC300[1][11] ) ==  ;				
  	   											  ( Right( (cAliasC300)->C20_DTDOC, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 5, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 3, 2 )+ C20_SERIE + C20_SUBSER + C1O_CODIGO + C20_CHVNF  ) 																		
				
                                              	    								
				//Neste momento eu populo o array de Itens da Nota Fiscal 
				//com o item que sera processado no while abaixo          																
				aItensNF := {}
				Aadd ( aItensNF, {})				
				aAdd ( aItensNF[1], (cAliasC300)->C30_NUMITE ) //01 - Numero do Item				
				aAdd ( aItensNF[1], (cAliasC300)->C0Y_CODIGO ) //02 - CFOP
				aAdd ( aItensNF[1], (cAliasC300)->C30_VLOPER  ) //03 - Valor Total da Operacao
				aAdd ( aItensNF[1], (cAliasC300)->( C1L_CODIGO ) ) //04 - Codigo do Produto
				aAdd ( aItensNF[1], Right( Alltrim( (cAliasC300)->C1J_CODIGO ), 6 )) //05 - Codigo da Unidade de Medida
				aAdd ( aItensNF[1], (cAliasC300)->C30_QUANT  ) //06 - Quantidade
				aAdd ( aItensNF[1], (cAliasC300)->C30_VLRITE ) //07 - Valor Unitario do Item
				aAdd ( aItensNF[1], (cAliasC300)->C30_VLDESC ) //08 - Valor do Desconto
				aAdd ( aItensNF[1], (cAliasC300)->C30_TOTAL ) //08 - Valor do Desconto				 											
									
				//Atualizo o Total de Itens da NF com o total do Item em processamento
				aNf[1][15] += aItensNF[1][3]
				
				//Atualizo o Total de Desconto da NF 
				aNf[1][16] += aItensNF[1][8]					
							
				While !(cAliasC300)->( Eof() )	.And. ( aTotRegC300[1][3] + aTotRegC300[1][1] + aTotRegC300[1][2] + aTotRegC300[1][7] + aTotRegC300[1][11] + aItensNF[1][1] ) ==  ;				
														( Right( (cAliasC300)->C20_DTDOC, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 5, 2 ) + SubStr( (cAliasC300)->C20_DTDOC, 3, 2 )+ C20_SERIE + C20_SUBSER + C1O_CODIGO + C20_CHVNF + C30_NUMITE ) 				
				                     					    
					//Funcao que realiza a Soma dos tributos por item
					A117GetTrib( cAliasC300, @aTrib )			    
																
					(cAliasC300)->(DbSkip())									
											
				EndDo //Item da Nota Fiscal	  	 
				
				//Verifica se a Nota Fiscal nao eh cancelada
				If aNF[1][12] <> "02"				                                                                                                                   												
					
					If SubStr( aWizardBc[2][2], 1, 1 ) == "A"
						
						//Geracao do Registro C370						
						RegC370( @cStrTxt04, aItensNf )		   
					EndIf
					
					If Len( aRegC390 ) <= 0 .Or. ( nPosC390 := aScan( aRegC390, { |x| x[2] == aTrib[10] .And. x[3] == aItensNf[1][2] .And. ;
					                                                                    x[4] == aTrib[12] } ) ) <= 0 								
                        						
						aAdd (aRegC390, {})
						nPosC390 := Len( aRegC390 ) 
 					   
 						aAdd (aRegC390[nPosC390], "C390" ) 			//01 - REG  	 																			
 						aAdd (aRegC390[nPosC390], aTrib[10] ) 	    //02 - CST_ICMS
 						aAdd (aRegC390[nPosC390], aItensNf[1][2] ) //03 - CFOP
 						aAdd (aRegC390[nPosC390], aTrib[12] ) 	    //04 - ALIQ_ICMS
 						aAdd (aRegC390[nPosC390], 0 ) 		        //05 - VL_OPR
 						aAdd (aRegC390[nPosC390], 0 ) 		        //06 - VL_BC_ICMS
 						aAdd (aRegC390[nPosC390], 0 ) 		        //07 - VL_ICMS
 						aAdd (aRegC390[nPosC390], 0 ) 		        //08 - VL_RED_BC
 						aAdd (aRegC390[nPosC390], "" ) 		        //09 - COD_OBS 							 							 							 							 							 							 							 							
					EndIf                                                    
					
					aRegC390[nPosC390][5] += aItensNf[1][3]	   		//05 - VL_OPR
					aRegC390[nPosC390][6] := aTrib[1] 					//06 - VL_BC_ICMS
					aRegC390[nPosC390][7] := aTrib[2]  				//07 - VL_ICMS
					aRegC390[nPosC390][8] := aTrib[31] 		   		//08 - VL_RED_BC						
												
				EndIf  					
																																											
									
				//ATENCAO                                                                                                                                                     
				//Para geracao dos registros C320 e C321 foi necessaria a utilizacao            
				//de arrays pois deve-se aglutinar os valores por registro C300 e posteriormente
				//gerar os registros no Banco de dados.                                         
				//Sendo assim, para este caso foi criada a Relacao Pai/Filho pelo primeiro campo
				//do registro C321                                                              
														
				//Neste momento verifico se existe calculo de ICMS e o CFOP no item
				//que foi processado                                               
				If !Empty( aTrib[10] ) .And. !Empty( aItensNf[1][2] )				
																								
					//Neste Momento eu verifico se a Chave do registro CST_ICM + CFOP + ALQ_ICMS              
					//ja existe no array, se sim populo os valores, caso contrario realizo a inclusao do novo 
					//registro                                                                                
					If Len( aRegC320 ) <= 0 .Or. ( nPosC320 := aScan( aRegC320, { |x| x[2] == aTrib[10] .And. x[3] == aItensNf[1][2] .And.;
					                                                                    x[4] == aTrib[12] } ) ) <= 0 								
						aAdd (aRegC320, {})
						nPosC320 := Len( aRegC320 ) 
						
 						aAdd (aRegC320[nPosC320], "C320" ) 			//01 - REG  	 														
						aAdd (aRegC320[nPosC320], aTrib[10] ) 		//02 - CST_ICMS	 
						aAdd (aRegC320[nPosC320], aItensNf[1][2] ) //03 - CFOP
						aAdd (aRegC320[nPosC320], aTrib[12] )      //04 - ALIQ_ICMS
						aAdd (aRegC320[nPosC320], 0  )             //05 - VL_OPR
						aAdd (aRegC320[nPosC320], 0  )             //06 - VL_BC_ICMS
						aAdd (aRegC320[nPosC320], 0  )             //07 - VL_ICMS
						aAdd (aRegC320[nPosC320], 0  )             //08 - VL_RED_BC
						aAdd (aRegC320[nPosC320], "" ) 	            //09 - COD_OBS
					EndIf     
					
					If aNF[1][12] <> "02"						                  
						aRegC320[nPosC320][5] += aItensNf[1][3]	//05 - VL_OPR
						aRegC320[nPosC320][6] += aTrib[1] 			//06 - VL_BC_ICMS
						aRegC320[nPosC320][7] += aTrib[2]  		//07 - VL_ICMS
						aRegC320[nPosC320][8] += aTrib[31] 		//08 - VL_RED_BC
					EndIf
											    																		
					//Verifico se ja existe a chave COD_ITEM para o registro C321 
					If Len( aRegC321 ) <= 0 .Or. ( nPosC321 := aScan( aRegC321, { |x| x[1] == nPosC320 .And. x[3] == aItensNF[1][4] .And. ;
																						x[5] == aItensNF[1][5] } ) ) <= 0 								
													
						aAdd (aRegC321, {})
						nPosC321 := Len( aRegC321 ) 
						
				   		aAdd (aRegC321[nPosC321], nPosC320 ) 	    //01 - Chave de Relacionamento com o PAI
						aAdd (aRegC321[nPosC321], "C321" ) 		    //02 - REG  	 																											
						aAdd (aRegC321[nPosC321], aItensNF[1][4] ) //03 - COD_ITEM
						aAdd (aRegC321[nPosC321], 0 )     			//04 - QTD
						aAdd (aRegC321[nPosC321], aItensNF[1][5] ) //05 - UNID
						aAdd (aRegC321[nPosC321], 0 )     			//06 - VL_ITEM
						aAdd (aRegC321[nPosC321], 0 )     			//07 - VL_DESC
						aAdd (aRegC321[nPosC321], 0 )           	//08 - VL_BC_ICMS
						aAdd (aRegC321[nPosC321], 0 )           	//09 - VL_ICMS
						aAdd (aRegC321[nPosC321], 0 )           	//10 - VL_PIS
						aAdd (aRegC321[nPosC321], 0 )           	//11 - VL_COFINS      							 			 	 									 							 							 							 							 							 							
					EndIf                                                               

					If aNF[1][12] <> "02"												    
						aRegC321[nPosC321][4]  += aItensNF[1][6]  //04 - QTD
 						aRegC321[nPosC321][6]  += aItensNF[1][9]  //06 - VL_ITEM 						
 						aRegC321[nPosC321][7]  += aItensNF[1][8]  //07 - VL_DESC
 						aRegC321[nPosC321][8]  += aTrib[1]        //08 - VL_BC_ICMS
 						aRegC321[nPosC321][9]  += aTrib[2]        //09 - VL_ICMS
 						aRegC321[nPosC321][10] += aTrib[6]        //10 - VL_PIS
 						aRegC321[nPosC321][11] += aTrib[7]        //11 - VL_COFINS      							 			 	 									 							 							 							 							 							 							
 					EndIf	 																																						                   							
				EndIf			
										    				    					
			EndDo // Nota Fiscal									

			If aNF[1][12] <> "02"								
				//Atualizo o valor de Pis e Cofins do Registro para geracao do registro C300
				aTotRegC300[1][5] += aTrib[6]
				aTotRegC300[1][6] += aTrib[7]																																		    
            EndIf
                                         
			//Atualiza o Valor de Pis e Cofins para a NF
			aNF[1][17] += aTrib[6]
			aNF[1][18] += aTrib[7]						     				 
			
			//Verifica se a Nota Fiscal nao eh cancelada
			If aNF[1][12] <> "02" 			
				If SubStr( aWizardBc[2][2], 1, 1 ) == "A"	    		    	            		    		    											    				                                                                                                                    
					
					//Geracao do Registro C350
					RegC350( @cStrTxt03, @cStrTxt04, aNF, aRegC390 ) 
				EndIf								
			EndIf  				  
			
			//Zero Array Para Gravacao do Registro da Proxima Nota Fiscal
			aRegC390 := {} 				  					  								
			
	    EndDo // Chave do Registro C300 
	    		    
		//Atualiza o Array com as Informacoes de Nota Fiscal Inicial e Final 
		//para o periodo                                                     
	    aTotRegC300[1][12] := cNumIni
	    aTotRegC300[1][13] := cNumFin
	    
	    If SubStr( aWizardBc[2][2], 1, 1 ) == "B"	    		    	            		    		    											    
			
			//Geracao do Registro C300
		    RegC300( @cStrTxt, aTotRegC300, aItensNf, aTrib, aRegC320, aRegC321, cStrTxt02, lNfCanc )		   
	    EndIf
	    
		//Neste momento ordeno a String com os dados do registro C300 e os
		//dados do registro C310 gravados previamente                     
		If SubStr( aWizardBc[2][2], 1, 1 ) == "A"
	   		cStrTxt   := ( cStrTxt + cStrTxt02 + cStrTxt03 ) 
	 	Else 
	 		If SubStr( aWizardBc[2][2], 1, 1 ) == "C"  
	   			cStrTxt   := ( cStrTxt + cStrTxt02 )
	   		EndIf	    
	   	EndIf
	    
	    aInfoGrv[5]++
	    WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )	                           
	    
   		cStrTxt   := ""
		cStrTxt02 := ""
		cStrTxt03 := ""
		cStrTxt04 := ""	
		    	    	    		    		    
		//Zero o Array de geracao do registro C320/C321 
	    aRegC320 := {}
	    aRegC321 := {}
	    					    	    		    			    		    		    		    
	EndDo	
	(cAliasC300)->(DbCloseArea())  
	
	cFilAnt := cFilBkp    	

//Realiza a Geracao do Registro C400 e Filhos	    
ElseIf cBlocGer == "C400"	 

	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC401, aWizardBc, "C400_1", cFilSelBc )                                        

    cFilBkp := cFilAnt    	
    	                  	    	    										   		
    While !(cAliasC401)->( Eof() )                                         
    
        cFilAnt := (cAliasC401)->C6F_FILIAL
         
		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf
		
	    RegC400( @cStrTxt, cAliasC401 )
	    	
		//Guardo o Codigo do Equipamento ECF
		cCodEqp := (cAliasC401)->( C0W_CODIGO )                                         
    	
    	While !(cAliasC401)->( Eof() ) .And. cCodEqp == (cAliasC401)->( C0W_CODIGO )                                         
    		
    		RegC405( @cStrTxt, cAliasC401 )
    	        	    
			//Guardo a Data de Movimento da Reducao Z
    	    cDtMovto := (cAliasC401)->C6G_DTMOV
    	        	    
			//Somente gera-se os registros filhos se o valor Bruto for maior do que 0
    	    If (cAliasC401)->C6G_VLBRU > 0 
	      	     While !(cAliasC401)->( Eof() ) .And. cCodEqp == (cAliasC401)->( C0W_CODIGO ) .And. cDtMovto ==  (cAliasC401)->C6G_DTMOV                                            	     
                    
					//Neste Momento Alimento o Array aParam com as informacoes da                                  
					//filial, codigo do ECF e data do Movimento que esta sendo processado,                         
					//assim sera realizada uma nova query para buscar as informacoes de "Totalizadores Parciais" e 
					//"Itens do Resumo Movimento Diario" / "Nota Fiscal e Respectivos Filhos                       
					aParam[1] := (cAliasC401)->C6F_FILIAL
					aParam[2] := (cAliasC401)->C6F_ID
				    aParam[3] := (cAliasC401)->C6G_DTMOV

					 //Executa a Query para geracao dos registros do Bloco C410 
					 A117QrySpC( cAliasC402, aWizardBc, "C400_4", cFilSelBc, aParam )                                        		      	 	    
					 
					 If (cAliasC402)->(!Eof())
					 
				 		 RegC410( @cStrTxt, cAliasC402 )
						 
						 (cAliasC402)->(DbSkip())
					 EndIf					 					 
					 (cAliasC402)->(DbCloseArea())
					 						
					 //Executa a Query para geracao dos registros do Bloco C420 / C425 
					 A117QrySpC( cAliasC402, aWizardBc, "C400_2", cFilSelBc, aParam )                                        		      	 	    
			 					 					 
					 While (cAliasC402)->(!Eof()) 

						RegC420( @cStrTxt, cAliasC402 )
												
						//Guardo o Codigo do Totalizador
						cCodTot := (cAliasC402)->( C6D_CODIGO )
						    
					    //Mesmo que nao seja gerado o registro C425 o laco deve ser processado para nao repetir a geracao
					    //do C425 				    		    	            		    		    											    													
						While (cAliasC402)->(!Eof()) .And. cCodTot == (cAliasC402)->( C6D_CODIGO )
                            
							If SubStr( aWizardBc[2][2], 1, 1 ) == "B"	                            
                            RegC425( @cStrTxt, cAliasC402 )
                         EndIf															
  							(cAliasC402)->(DbSkip())
						EndDo  //Laco do Resumo de Itens do Movimento Diario												
																	 	 
					 EndDo //Laco dos Totalizadores Parciais Reducao Z              
					 (cAliasC402)->(DbCloseArea())
					 
					//Executa a Query para geracao dos registros do Bloco C490 
					A117QrySpC( cAliasC403, aWizardBc, "C400_7", cFilSelBc, aParam )                                        		      	 	    								 
																		
					//Caso na Reducao Z (Consolidada) exista o cadastro                    
					//do REGC490 buscamos as informacoes de lah ( Tabela C7E), caso       
			       //contrario realizamos a geracao do registro manualmente.             
					If  (cAliasC403)->(!Eof())
						
						lC490Cons := .T.            

						While (cAliasC403)->(!Eof())						

							aAdd ( aRegC490, {})																		
							nPosC490 := Len( aRegC490 )
							 
	                     aAdd ( aRegC490[nPosC490], "C490" )					   				     //01 - REG
	                     aAdd ( aRegC490[nPosC490], '0'+(cAliasC403)->C14_CODIGO )				 //02 - CST_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C0Y_CODIGO )	  				 //03 - CFOP
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7E_ALIQ )  					 //04 - ALIQ_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7E_VLOPR )               	 //05 - VL_OPR
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7E_VLBC )	                 	 //06 - VL_BC_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7E_VL ) 	                   //07 - VL_ICMS
							aAdd ( aRegC490[nPosC490], StrTran( (cAliasC403)->( C3R_CODIGO ), CRLF, "" ) )  //08 - COD_OBS																		
																		 																
							(cAliasC403)->(DbSkip())
						EndDo               						
                     EndIf                  
					(cAliasC403)->(DbCloseArea())					             
					
					//Executa a Query para geracao dos registros do Bloco C490 
					A117QrySpC( cAliasC403, aWizardBc, "C400_5", cFilSelBc, aParam )                                        		      	 	    								 
																		
					//Caso na Reducao Z exista o cadastro do REGC490 buscamos as           
					//informacoes de lah ( Tabela C7G), caso contrario realizamos a geracao
					//do registro manualmente.                                             
					If  (cAliasC403)->(!Eof()) .And. !lC490Cons
						
						lC490Cons := .T.            
						
						While (cAliasC403)->(!Eof())						

							aAdd ( aRegC490, {})																		
							nPosC490 := Len( aRegC490 )
							 
	                        aAdd ( aRegC490[nPosC490], "C490" )					   				 //01 - REG
	                        aAdd ( aRegC490[nPosC490], '0'+(cAliasC403)->C14_CODIGO )  		 //02 - CST_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C0Y_CODIGO )  				 //03 - CFOP
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7G_ALQICM )  				 //04 - ALIQ_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7G_VLOPR )                //05 - VL_OPR
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7G_BCICMS )               //06 - VL_BC_ICMS
							aAdd ( aRegC490[nPosC490], (cAliasC403)->C7G_VLICMS )               //07 - VL_ICMS
							aAdd ( aRegC490[nPosC490], StrTran( (cAliasC403)->( C3R_CODIGO ), CRLF, "" ) ) //08 - COD_OBS																		
																		 																
							(cAliasC403)->(DbSkip())
						Enddo               						
                    EndIf                  
					(cAliasC403)->(DbCloseArea())					                      
                     		
					 //Executa a Query para geracao dos registros do Bloco C460 / C470 / C490 
					 A117QrySpC( cAliasC402, aWizardBc, "C400_3", cFilSelBc, aParam )                                        		      	 	    					
		      	         
		      	                   
					While (cAliasC402)->(!Eof())
					  						 					 
					     cChvNf := (cAliasC402)->( C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + C6I_DTEMIS ) 
						 
						 cDtEmiss  := Right( (cAliasC402)->C6I_DTEMIS , 2 ) + SubStr( (cAliasC402)->C6I_DTEMIS , 5, 2 ) + Left( (cAliasC402)->C6I_DTEMIS , 4 )
	                            
                         aRegC460 := {}
						 aAdd (aRegC460, {})
                            
                         aAdd ( aRegC460[1], "C460" ) 					 //01 - Reg
               			 aAdd ( aRegC460[1], (cAliasC402)->C01_CODIGO ) //02 - Modelo da NF
               			 aAdd ( aRegC460[1], (cAliasC402)->C02_CODIGO ) //03 - Situacao da NF
               			 aAdd ( aRegC460[1], (cAliasC402)->C6I_NUMDOC ) //04 - Numero do Documento Fiscal
               			 aAdd ( aRegC460[1], cDtEmiss                  )//05 - Data de Emissao do Documento Fiscal
               			 aAdd ( aRegC460[1], (cAliasC402)->C6I_VLDOC  ) //06 - Valor do Documento Fiscal
               			 aAdd ( aRegC460[1], 0 )                        //07 - Valor do PIS
               			 aAdd ( aRegC460[1], 0 )						 //08 - Valor do Cofins
               			 aAdd ( aRegC460[1], (cAliasC402)->C6I_CNPJ )   //09 - CPF/CNPJ
               			 aAdd ( aRegC460[1], StrTran( (cAliasC402)->C6I_NOME, CRLF, "" ) )   //10 - Nome do Adquirente               			               			
                   			
                   									 
						 While (cAliasC402)->(!Eof()) .And. cChvNf == (cAliasC402)->( C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + C6I_DTEMIS )  
                                                        
							cChvIte := (cAliasC402)->( C1L_CODIGO ) 
							
	                        aRegC470 := {}
							aAdd (aRegC470, {})
	                            
	                        aAdd ( aRegC470[1], "C470" ) 											//01 - Reg    
	                        aAdd ( aRegC470[1], (cAliasC402)->( C1L_CODIGO ) )   		//02 - COD_ITEM
	                        aAdd ( aRegC470[1], (cAliasC402)->C6J_QTDE )                           //03 - QTD
	                        aAdd ( aRegC470[1], (cAliasC402)->C6J_QTDCAN )                         //04 - QTD_CANC
	                        aAdd ( aRegC470[1], Right( Alltrim( (cAliasC402)->( C1J_CODIGO ) ),6))        //05 - UNID
	                        aAdd ( aRegC470[1], (cAliasC402)->C6J_VLRITE )                         //06 - VL_ITEM
	                        aAdd ( aRegC470[1], "" )                                                //07 - CST_ICMS
	                        aAdd ( aRegC470[1], (cAliasC402)->C0Y_CODIGO )                          //08 - CFOP
	                        aAdd ( aRegC470[1], "" )    						                     //09 - ALIQ_ICMS
	                        aAdd ( aRegC470[1], 0 )                                                 //10 - VL_PIS
	                        aAdd ( aRegC470[1], 0 )  	      		                                 //11 - VL_COFINS                    
							
							
							While (cAliasC402)->(!Eof()) .And. cChvNf == (cAliasC402)->( C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + C6I_DTEMIS )  .And. ;
							       cChvIte == (cAliasC402)->( C1L_CODIGO ) 								
																					                                                 		        					                           	
								//Valores de ICMS    	
								If (cAliasC402)->C3S_CODIGO == "02"	   		  
																											
									//Caso na Reducao Z exista o cadastro de Registro Analitico do Movimento buscamos as   
									//informacoes de lah ( Tabela C7G), caso contrario realizamos a geracao                
									//do registro manualmente.                                                             
									If  !lC490Cons			
			                     	If Len ( aRegC490 ) <= 0 .Or. ( nPosC490 := aScan( aRegC490, { |x| x[2] == (cAliasC402)->( C03_CODIGO + C14_CODIGO ) .And. x[3] == (cAliasC402)->C0Y_CODIGO .And. ;
			                            												     x[4] == (cAliasC402)->C6K_ALQPRD .And. x[8] == (cAliasC402)->( C3R_FILIAL + C3R_CODIGO )} ) ) <= 0 
				                        
											aAdd ( aRegC490, {})																		
											nPosC490 := Len( aRegC490 )
											 
					                     aAdd ( aRegC490[nPosC490], "C490" )					   				     //01 - REG
					                     aAdd ( aRegC490[nPosC490], (cAliasC402)->( C03_CODIGO + C14_CODIGO ) ) //02 - CST_ICMS
											aAdd ( aRegC490[nPosC490], (cAliasC402)->C0Y_CODIGO )  				 //03 - CFOP
											aAdd ( aRegC490[nPosC490], (cAliasC402)->C6K_ALQPRD )  				 //04 - ALIQ_ICMS
											aAdd ( aRegC490[nPosC490], 0 )                         					 //05 - VL_OPR
											aAdd ( aRegC490[nPosC490], 0 )                         					 //06 - VL_BC_ICMS
											aAdd ( aRegC490[nPosC490], 0 )                         					 //07 - VL_ICMS
											aAdd ( aRegC490[nPosC490], StrTran( (cAliasC402)->( C3R_CODIGO ), CRLF, "" ) ) //08 - COD_OBS																		
			                         EndIf                                                                
										
				                      aRegC490[nPosC490][5] += (cAliasC402)->C6J_VLRITE 
			                          aRegC490[nPosC490][6] += (cAliasC402)->C6K_VLRBC
	       	                      aRegC490[nPosC490][7] += (cAliasC402)->C6K_VLRTRB
									EndIf
       	                            	        				   																																																											
									aRegC470[1][7] := (cAliasC402)->( C03_CODIGO + C14_CODIGO )
									aRegC470[1][9] := (cAliasC402)->C6K_ALQPRD      
																		
								//Valor de PIS								
								ElseIf (cAliasC402)->C3S_CODIGO == "06"																									
									aRegC470[1][10] += (cAliasC402)->C6K_VLRTRB   
																	
								//Valor do Cofins
								ElseIf (cAliasC402)->C3S_CODIGO == "07"								    								
									aRegC470[1][11] += (cAliasC402)->C6K_VLRTRB   
																										
								EndIf								
								(cAliasC402)->(DbSkip()) 
							EndDo  							    
							
							If SubStr( aWizardBc[2][2], 1, 1 ) == "A" .And. cMvUF <> "BA"
								RegC470( @cStrTxt02, aRegC470 )    
							EndIf
														
							//Somo valor de Pis e Cofins para a NF
							aRegC460[1][7] += aRegC470[1][10]
							aRegC460[1][8] += aRegC470[1][11]
							
						 EndDo     
						 
						 If SubStr( aWizardBc[2][2], 1, 1 ) == "A" .And. cMvUF <> "BA"						 						 						 
							 RegC460( @cStrTxt, aRegC460 )						 						 
						EndIf
						 						 						 						 						 						 						 						                  
						//Concateno a Informacao do Registro Gerados ate o C460 com 
						//os Itens da NF C470                                       
						cStrTxt := ( cStrTxt + cStrTxt02 )
						 			
						aInfoGrv[5]++
			    	    WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )	     	    					 
			    	     
						cStrTxt   := ""
						cStrTxt02 := "" 
						 
						aRegC460 := {}
						 			    	    						 						 			    	     
					EndDo                         
					(cAliasC402)->(DbCloseArea())
					     	
					RegC490( @cStrTxt, aRegC490 )
					     
					aInfoGrv[5]++					     
					WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
					
					cStrTxt   := ""
					
					lC490Cons := .F.
					
					aRegC490  := {}							      	                                     
							      	     
		      	    (cAliasC401)->(DbSkip())
	      	     
	      	     //Laco da Reducao Z
	      	     EndDo 
    	     Else
   		   	    (cAliasC401)->(DbSkip())
    	     EndIf
    	      
		//Laco do Equipamento ECF    	                		
  		EndDo 
    EndDo                                   
	(cAliasC401)->(DbCloseArea()) 
	
	//Para o Estado da Bahia deve-se gerar o registro C495
	If cMvUF == "BA"
	
		 //Registro C495 Será Válido Até 31/12/2013	
		 If cDtFinPer < "20140101"  
		    
			 //Executa a Query para geracao dos registros do Bloco C495 (CONSOLIDADO) 
			 A117QrySpC( cAliasC403, aWizardBc, "C400_8", cFilSelBc )                                        		      	 	    										 	
			
    	     If  (cAliasC403)->(!Eof())

			 	lC495Cons := .T.		 		 
	       
	    	    While (cAliasC403)->(!Eof())                                                                                                                          
		    
					cChvC495 := (cAliasC403)->( C1L_FILIAL + C1L_CODIGO + Alltrim( Str( C7H_ALIQ ) ) + C1J_FILIAL + C1J_CODIGO ) 				 

					aAdd ( aRegC495, {})																		
					nPosC495 := Len( aRegC495 )
   		    
    		        aAdd ( aRegC495[nPosC495], "C495" )             							   	//01 - REG
        		     aAdd ( aRegC495[nPosC495], (cAliasC403)->C7H_ALIQ )                     	 	//02 - ALIQ_ICMS
	 		 		 aAdd ( aRegC495[nPosC495], (cAliasC403)->( C1L_CODIGO ) )       	//03 - COD_ITEM
	            	 aAdd ( aRegC495[nPosC495], 0 )                                                	//04 - QTD
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                	//05 - QTD_CANC
	           	 aAdd ( aRegC495[nPosC495], Right( Alltrim( (cAliasC403)->( C1J_CODIGO )), 6 ) )        //06 - UNID                        
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //07 - VL_ITEM
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //08 - VL_DESC
	         		 aAdd ( aRegC495[nPosC495], 0 )                                                 //09 - VL_CANC
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //10 - VL_ACMO
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //11 - VL_BC_ICMS
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //12 - VL_ICMS
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //13 - VL_ISEN
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //14 - VL_NT
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //15 - VL_ICMS_ST
                		
                			  
					While (cAliasC403)->(!Eof()) .And. cChvC495 == (cAliasC403)->( C1L_FILIAL + C1L_CODIGO + Alltrim( Str( C7H_ALIQ ) ) + C1J_FILIAL + C1J_CODIGO ) 				 
            
		           	 aRegC495[nPosC495][4]  +=  (cAliasC403)->C7H_QTD 			//04 - QTD
						aRegC495[nPosC495][5]  +=  (cAliasC403)->C7H_QTDCAN      	//05 - QTD_CANC                            			
		    	        aRegC495[nPosC495][7]  +=  (cAliasC403)->C7H_VLITEM 		//07 - VL_ITEM                           
		    	        aRegC495[nPosC495][8]  +=  (cAliasC403)->C7H_VLDESC      	//08 - VL_DESC                           
		       	     aRegC495[nPosC495][9]  +=  (cAliasC403)->C7H_VLCANC      	//09 - VL_CANC                         
		       	     aRegC495[nPosC495][10] +=  (cAliasC403)->C7H_VLACMO		//10 - VL_ACMO                          
		       	     aRegC495[nPosC495][11] +=  (cAliasC403)->C7H_VBCICM      	//11 - VL_BC_ICMS                         
   	        			aRegC495[nPosC495][12] +=  (cAliasC403)->C7H_VLICMS   	//12 - VL_ICMS                             
   	        		    aRegC495[nPosC495][15] +=  (cAliasC403)->C7H_VICMST   	//15 - VL_ICMS_ST		     
    		    	    aRegC495[nPosC495][13] +=  (cAliasC403)->C7H_VLISEN      	//13 - VL_ISEN                          
		           	 aRegC495[nPosC495][14] +=  (cAliasC403)->C7H_VLNT       	//14 - VL_NT                          
	                                                                                                                                                                
		   		  		(cAliasC403)->(DbSkip())
					EndDo 
				EndDo
		 	EndIf	

			 //se nao encontrar na tabela de consolidados (C7H), entao deve procurar na C6G
 		 	If !lC495Cons
				 //Executa a Query para geracao dos registros do Bloco C495 
				 A117QrySpC( cAliasC403, aWizardBc, "C400_6", cFilSelBc )                                        		      	 	    										 	
		 		 
				 While (cAliasC403)->(!Eof())                                                                                                                          
		 
					cChvC495 := (cAliasC403)->( C1L_FILIAL + C1L_CODIGO + Alltrim( Str( C6K_ALQPRD ) ) + C1J_FILIAL + C1J_CODIGO ) 				 

					aAdd ( aRegC495, {})																		
					nPosC495 := Len( aRegC495 )
   		    
    	    	    aAdd ( aRegC495[nPosC495], "C495" )             							   	//01 - REG
	        	    aAdd ( aRegC495[nPosC495], (cAliasC403)->C6K_ALQPRD )                         //02 - ALIQ_ICMS
    	       	 aAdd ( aRegC495[nPosC495], (cAliasC403)->( C1L_CODIGO ) )        //03 - COD_ITEM
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //04 - QTD
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //05 - QTD_CANC
	           	 aAdd ( aRegC495[nPosC495], Right( Alltrim( (cAliasC403)->( C1J_CODIGO )), 6 ) )        //06 - UNID                        
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //07 - VL_ITEM
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //08 - VL_DESC
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //09 - VL_CANC
    	        	aAdd ( aRegC495[nPosC495], 0 )                                                 //10 - VL_ACMO
        	    	aAdd ( aRegC495[nPosC495], 0 )                                                 //11 - VL_BC_ICMS
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //12 - VL_ICMS
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //13 - VL_ISEN
    	       	 aAdd ( aRegC495[nPosC495], 0 )                                                 //14 - VL_NT
	           	 aAdd ( aRegC495[nPosC495], 0 )                                                 //15 - VL_ICMS_ST
                		
                			  
					While (cAliasC403)->(!Eof()) .And. cChvC495 == (cAliasC403)->( C1L_FILIAL + C1L_CODIGO + Alltrim( Str( C6K_ALQPRD ) ) + C1J_FILIAL + C1J_CODIGO ) 				 
            
		           	 aRegC495[nPosC495][4]  +=  (cAliasC403)->C6J_QTDE 		  //04 - QTD
						 aRegC495[nPosC495][5]  +=  (cAliasC403)->C6J_QTDCAN      //05 - QTD_CANC                            			
		               aRegC495[nPosC495][7]  +=  (cAliasC403)->C6J_VLRITE      //07 - VL_ITEM                           
		            	 aRegC495[nPosC495][8]  +=  (cAliasC403)->C6J_VLDESC      //08 - VL_DESC                           
		            	 aRegC495[nPosC495][9]  +=  (cAliasC403)->C6J_VLCAN       //09 - VL_CANC                         
		               aRegC495[nPosC495][10] +=  (cAliasC403)->C6J_VLRACR      //10 - VL_ACMO                          
		               aRegC495[nPosC495][11] +=  (cAliasC403)->C6K_VLRBC       //11 - VL_BC_ICMS                         
            
			        	If (cAliasC403)->C3S_CODIGO == "02"
	            	    	aRegC495[nPosC495][12] +=  (cAliasC403)->C6K_VLRTRB   //12 - VL_ICMS                             
    	        	    Else
    	          	     aRegC495[nPosC495][15] +=  (cAliasC403)->C6K_VLRTRB   //15 - VL_ICMS_ST		     
	        	   		EndIf

	    	       	 aRegC495[nPosC495][13] +=  (cAliasC403)->C6K_VLISEN      //13 - VL_ISEN                          
		           	 aRegC495[nPosC495][14] +=  (cAliasC403)->C6K_VLOUT       //14 - VL_NT                          
	                                                                                                                                                                
	   			  		(cAliasC403)->(DbSkip())
					EndDo 
			 	EndDo		 
		 	EndIf
		 	(cAliasC403)->(DbCloseArea())
		 
			 RegC495( @cStrTxt, aRegC495 )
			 
			 aInfoGrv[5]++
			 WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )							 

		Endif

	EndIf                               
	
	cFilAnt := cFilBkp
	
//Realiza a Geracao do Registro C500 e Filhos
ElseIf cBlocGer == "C500"	
        
	//Posiciono nas tabelas em que serao necessarios os seeks
	DbSelectArea(cAliasC0K)
	(cAliasC0K)->(DbSetOrder(4))  
	
	DbSelectArea( cAliasC1H )
	(cAliasC1H)->(DbSetOrder(5))	
	
	DbSelectArea(cAliasC32)		    
	(cAliasC32)->(DbSetOrder(1))  
		
	DbSelectArea( cAliasC3Q )
	(cAliasC3Q)->(DbSetOrder(3)) 
	
	DbSelectArea(cAliasC21)
	(cAliasC21)->(DbSetOrder(1))	
	
	DbSelectArea(cAliasC2C)
	(cAliasC2C)->(DbSetOrder(1))
	
	DbSelectArea(cAliasC3R)
	(cAliasC3R)->(DbSetOrder(3)) 
						
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC500, aWizardBc, "C500", cFilSelBc )                                        

    cFilBkp := cFilAnt    	
        	                  	    	    										   		
    While !(cAliasC500)->( Eof() )                                         
    
        cFilAnt := (cAliasC500)->C20_FILIAL
              
		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf
		                                                
		//Verifica se a Nota Fiscal eh Cancelada
	    lNfCanc := (cAliasC500)->C02_CODIGO == "02" .Or. (cAliasC500)->C02_CODIGO == "03"		
		
		cCodInf    := "" 
	    cCodObs   := ""
				    			
		//Trato Campos de Data para Geracao dos Registros
		cDtEmiss  := Right( (cAliasC500)->C20_DTDOC, 2 ) + SubStr( (cAliasC500)->C20_DTDOC, 5, 2 ) + Left( (cAliasC500)->C20_DTDOC, 4 )
		cDtEntSai := Right( (cAliasC500)->C20_DTES, 2 ) + SubStr( (cAliasC500)->C20_DTES, 5, 2 ) + Left( (cAliasC500)->C20_DTES, 4 )				   
                		             		
		If (cAliasC21)->( MsSeek( xFilial(cAliasC21) +  (cAliasC500)->C20_CHVNF ) )
			If (cAliasC3Q)->( MsSeek( xFilial(cAliasC3Q) + (cAliasC21)->C21_CODINF ) )
				cCodInf := (cAliasC3Q)->( C3Q_CODINF )	
			EndIf
		EndIf  
		
		If (cAliasC2C)->( MsSeek( xFilial(cAliasC2C) + (cAliasC500)->C20_CHVNF ) )
			If (cAliasC3R)->( MsSeek( xFilial(cAliasC3R) + (cAliasC2C)->C2C_CODOBS ) )
				cCodObs := 	(cAliasC3R)->( C3R_CODIGO )			
			EndIf					
		EndIf			
				
		aRegC500 := {}		        		
		aAdd ( aRegC500, {} )																		
		
		aAdd ( aRegC500[1], "C500" )        					//01 - REG
		aAdd ( aRegC500[1], (cAliasC500)->C20_INDOPE )	    	//02 - IND_OPER
		aAdd ( aRegC500[1], (cAliasC500)->C20_INDEMI )	    	//03 - IND_EMIT 						
		aAdd ( aRegC500[1], (cAliasC500)->( C1H_CODPAR ) )			//04 - COD_PART					
		aAdd ( aRegC500[1], (cAliasC500)->C01_CODIGO )	    	//05 - COD_MOD
		aAdd ( aRegC500[1], (cAliasC500)->C02_CODIGO )	    	//06 - COD_SIT
		aAdd ( aRegC500[1], (cAliasC500)->C20_SERIE )	   		//07 - SER
		aAdd ( aRegC500[1], (cAliasC500)->C20_SUBSER )	    	//08 - SUB

		If ((cAliasC500)->C01_CODIGO $ "06,55") 
		
			aAdd ( aRegC500[1], (cAliasC500)->C0L_CODIGO ) //09 - COD_CONS
		
		ElseIf ((cAliasC500)->C01_CODIGO $ "28,29")
		
			aAdd ( aRegC500[1], (cAliasC500)->C0O_CODIGO ) //09 - COD_CONS
		
		EndIf
		
		aAdd ( aRegC500[1], (cAliasC500)->C20_NUMDOC )			//10 - NUM_DOC
		aAdd ( aRegC500[1], cDtEmiss )		    				//11 - DT_DOC
		aAdd ( aRegC500[1], cDtEntSai )		    				//12 - DT_ES
		aAdd ( aRegC500[1], (cAliasC500)->C20_VLDOC )		   	//13 - VL_DOC
		aAdd ( aRegC500[1], (cAliasC500)->C20_VLDESC )		    //14 - VL_DESC
		aAdd ( aRegC500[1], (cAliasC500)->C2E_VLFORN )		   	//15 - VL_FORN
		aAdd ( aRegC500[1], (cAliasC500)->C2E_VSERNT )			//16 - VL_SERV_NT
		aAdd ( aRegC500[1], (cAliasC500)->C2E_VLTERC )			//17 - VL_TERC
		aAdd ( aRegC500[1], (cAliasC500)->C20_VLRDA )		   	//18 - VL_DA
		aAdd ( aRegC500[1], 0 )		    						//19 - VL_BC_ICMS
		aAdd ( aRegC500[1], 0 ) 		    					//20 - VL_ICMS
		aAdd ( aRegC500[1], 0 ) 		    					//21 - VL_BC_ICMS_ST
		aAdd ( aRegC500[1], 0 )		    						//22 - VL_ICMS_ST
		aAdd ( aRegC500[1], cCodInf )	    					//23 - COD_INF
		aAdd ( aRegC500[1], 0 )		    						//24 - VL_PIS
		aAdd ( aRegC500[1], 0 )		    						//25 - VL_COFINS
		aAdd ( aRegC500[1], (cAliasC500)->C2E_TPLIG )			//26 - TP_LIGACAO																																					
		aAdd ( aRegC500[1], (cAliasC500)->C0N_CODIGO )			//27 - COD_GRUPO_TENSAO	
			                        				
		//Monta Chave da NF para geracao do Registro C500
		cChvNf := (cAliasC500)->( C20_INDOPE + C20_INDEMI + C1H_FILIAL + C1H_CODPAR + C20_SERIE + C20_SUBSER + C20_NUMDOC + cDtEmiss )

		//Somente gero FIlhos para Nota Fiscais com Situacao Normal
		If !lNfCanc
		
														 
			While (cAliasC500)->( !Eof() ) .And. cChvNf == (cAliasC500)->( C20_INDOPE + C20_INDEMI + C1H_FILIAL + C1H_CODPAR + C20_SERIE + C20_SUBSER + C20_NUMDOC + cDtEmiss )
			    
			    cCodClass := ""
			    cIndRec   := ""  
			    cCodPar   := "" 
			    		    
				//Busca as Informacoes da Tabela C32 que nao eh retornada 
				//na query                                                
				If (cAliasC32)->(MsSeek( xFilial(cAliasC32) + ( (cAliasC500)->( C20_CHVNF + C30_NUMITE + C30_CODITE ) ) ) )
					
					If (cAliasC0K)->(MsSeek( xFilial(cAliasC0K) + (cAliasC32)->C32_CCLASS ) )
						cCodClass := (cAliasC0K)->C0K_CODIGO
					EndIf                                   
	
					If (cAliasC1H)->(MsSeek( xFilial(cAliasC1H) + (cAliasC32)->C32_CODPAR ) )
						cCodPar := (cAliasC1H)->( C1H_CODPAR )
					EndIf
					
					cIndRec := (cAliasC32)->C32_INDREC 
					
				EndIf
				
				aRegC510 := {}		    		    		   
				aAdd ( aRegC510, {} )																		
				
				aAdd ( aRegC510[1], "C510" )      						        //01 - REG  
				aAdd ( aRegC510[1], (cAliasC500)->C30_NUMITE  )               //02 - NUM_ITEM  
				aAdd ( aRegC510[1], (cAliasC500)->( C1L_CODIGO ) )                //03 - COD_ITEM
				aAdd ( aRegC510[1], cCodClass )                 			   //04 - COD_CLASS
				aAdd ( aRegC510[1], (cAliasC500)->C30_QUANT )                 //05 - QTD
				aAdd ( aRegC510[1], Right( Alltrim( (cAliasC500)->C1J_CODIGO ), 6 ) )                //06 - UNID
				aAdd ( aRegC510[1], (cAliasC500)->C30_TOTAL )                 //07 - VL_ITEM
				aAdd ( aRegC510[1], (cAliasC500)->C30_VLDESC )                //08 - VL_DESC
				aAdd ( aRegC510[1], "" )                 					   //09 - CST_ICMS
				aAdd ( aRegC510[1], (cAliasC500)->C0Y_CODIGO )                //10 - CFOP
				aAdd ( aRegC510[1], 0  )                 						//11 - VL_BC_ICMS
				aAdd ( aRegC510[1], 0  )                 						//12 - ALQ_ICMS
				aAdd ( aRegC510[1], 0  )                 						//13 - VL_ICMS
				aAdd ( aRegC510[1], 0  )                 						//14 - VL_BC_ICMS_ST
				aAdd ( aRegC510[1], 0  )                 						//15 - ALIQ_ST
				aAdd ( aRegC510[1], 0  )                 						//16 - VL_ICMS_ST
				aAdd ( aRegC510[1], cIndRec )             						//17 - IND_REC	
				aAdd ( aRegC510[1], cCodPar )             						//18 - COD_PART
				aAdd ( aRegC510[1], 0  )                 						//19 - VL_PIS
				aAdd ( aRegC510[1], 0  )                 						//20 - VL_COFINS
				aAdd ( aRegC510[1], StrTran( (cAliasC500)->( C1O_CODIGO ), CRLF, "" ) )   			    //21 - COD_CTA																																																					
				
				nVlOperIt := (cAliasC500)->C30_VLOPER 
										    													        
				//Busco Numero do Item para geracao do Registro C510
				cChvIte := (cAliasC500)->C30_NUMITE
													
				//Zero Array com Informacoes dos tributos referentes ao item da NF
				aTrib     := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    			

				While (cAliasC500)->( !Eof() ) .And. cChvNf == (cAliasC500)->( C20_INDOPE + C20_INDEMI + C1H_FILIAL + C1H_CODPAR + C20_SERIE + C20_SUBSER + C20_NUMDOC + cDtEmiss ) .And. ;
				       cChvIte == (cAliasC500)->C30_NUMITE
				    
					A117GetTrib( cAliasC500, @aTrib )
		
					(cAliasC500)->(DbSkip())			
				EndDo //Laco do Tributo do Item	
				
				If Len( aRegC590 ) <= 0 .Or. ( nPosC590 := aScan( aRegC590, { |x| x[2] == aTrib[10] .And. x[3] == aRegC510[1][10] .And. x[4] == aTrib[12] } ) ) <= 0 								
				    
					aAdd ( aRegC590, {} )																		
					nPosC590 := Len( aRegC590 )
					
					aAdd ( aRegC590[nPosC590], "C590"    )       	//01 - REG
					aAdd ( aRegC590[nPosC590], aTrib[10] )         //02 - CST_ICMS
					aAdd ( aRegC590[nPosC590], aRegC510[1][10] )   //03 - CFOP
					aAdd ( aRegC590[nPosC590], aTrib[12] )         //04 - ALIQ_ICMS
					aAdd ( aRegC590[nPosC590], 0 )    				//05 - VL_OPR
					aAdd ( aRegC590[nPosC590], 0 )                 //06 - VL_BC_ICMS
					aAdd ( aRegC590[nPosC590], 0 )                 //07 - VL_ICMS
					aAdd ( aRegC590[nPosC590], 0 )		            //08 - VL_BC_ICMS_ST																						
					aAdd ( aRegC590[nPosC590], 0 )		            //09 - VL_ICMS_ST
					aAdd ( aRegC590[nPosC590], 0 )         			//10 - VL_RED_BC
					aAdd ( aRegC590[nPosC590], StrTran( cCodObs, CRLF, "" ) )			//11 - COD_OBS												
				
				EndIf      
				
				aRegC590[nPosC590][5]  += nVlOperIt		      		//05 - VL_OPR
				aRegC590[nPosC590][6]  += aTrib[1]            		//06 - VL_BC_ICMS
				aRegC590[nPosC590][7]  += aTrib[2]            		//07 - VL_ICMS
				aRegC590[nPosC590][8]  += aTrib[3]  			   		//08 - VL_BC_ICMS_ST																						
				aRegC590[nPosC590][9]  += aTrib[4]            		//09 - VL_ICMS_ST
				aRegC590[nPosC590][10] += Iif(aTrib[31]== Nil, 0 , aTrib[31])            		//10 - VL_RED_BC
																							
				aRegC510[1][9]  := aTrib[10]        				//09 - CST_ICMS
				aRegC510[1][11] += aTrib[1]         				//11 - VL_BC_ICMS
				aRegC510[1][12] := aTrib[12]        				//12 - ALQ_ICMS
				aRegC510[1][13] += aTrib[2]         				//13 - VL_ICMS
				aRegC510[1][14] += aTrib[3]         				//14 - VL_BC_ICMS_ST
				aRegC510[1][15] := aTrib[13]        				//15 - ALIQ_ST
				aRegC510[1][16] += aTrib[4]         				//16 - VL_ICMS_ST			
				aRegC510[1][19] += aTrib[6]         				//19 - VL_PIS
				aRegC510[1][20] += aTrib[7]         				//20 - VL_COFINS			
				
				aRegC500[1][19] += aRegC510[1][11]	 				//19 - VL_BC_ICMS
				aRegC500[1][20] += aRegC510[1][13]	 				//20 - VL_ICMS
				aRegC500[1][21] += aRegC510[1][14]	 				//21 - VL_BC_ICMS_ST
				aRegC500[1][22] += aRegC510[1][16]	 				//22 - VL_ICMS_ST
				aRegC500[1][24] += aRegC510[1][19]	 				//24 - VL_PIS
				aRegC500[1][25] += aRegC510[1][20]	 				//25 - VL_COFINS
			           			
				//Somente gera o C510 para operacoes de Saida
				If aRegC500[1][2] == "1" .And. SubStr( aWizardBc[2][2], 1, 1 ) == "A" 
					RegC510( @cStrTxt02,  aRegC510 ) 														
				EndIf
				
			EndDo //Laco do Item 	
		
			If !( aRegC500[1][2] == "1" .And. SubStr( aWizardBc[2][2], 1, 1 ) == "B" )	
				RegC590( @cStrTxt03,  aRegC590 )
			EndIf			

		Else                                                                                                                                                        
				
			//Quando a Nota Fiscal eh cancelada nao se pode gerar os registros
			//filhos, sendo assim ando com o While ate a proxima NF valida			
			    
			While (cAliasC500)->( !Eof() ) .And. cChvNf == (cAliasC500)->( C20_INDOPE + C20_INDEMI + C1H_FILIAL + C1H_CODPAR + C20_SERIE + C20_SUBSER + C20_NUMDOC + cDtEmiss )				
				(cAliasC500)->(DbSkip())			
			EndDo
		EndIf		                           
		
		If !( aRegC500[1][2] == "1" .And. SubStr( aWizardBc[2][2], 1, 1 ) == "B" )
			RegC500( @cStrTxt,  aRegC500, lNfCanc ) 																		
		EndIf
		                 
		cStrTxt := ( cStrTxt + cStrTxt02 + cStrTxt03 )                                                                         				 																		
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )

		aRegC590  := {}
		
		cStrTxt   := ""
		cStrTxt02 := ""
		cStrTxt03 := ""	        		
		
    EndDo //Laco da NF
	(cAliasC500)->(DbCloseArea())    

    cFilAnt := cFilBkp

//Realiza a Geracao do Registro C600 e Filhos
ElseIf cBlocGer == "C600"

	//Posiciono nas tabelas em que serao necessarios os seeks
	DbSelectArea(cAliasC0K)
	(cAliasC0K)->(DbSetOrder(4))  
		
	DbSelectArea(cAliasC32)		    
	(cAliasC32)->(DbSetOrder(1)) 
	
	DbSelectArea(cAliasC2C)
	(cAliasC2C)->(DbSetOrder(1))
	
	DbSelectArea(cAliasC3R)
	(cAliasC3R)->(DbSetOrder(3)) 	 
	
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC600, aWizardBc, "C600", cFilSelBc )                                        

    cFilBkp := cFilAnt    	
        	                  	    	    										   		
    While !(cAliasC600)->(Eof())                                         
                		                                                             
        cFilAnt := (cAliasC600)->C20_FILIAL

		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf    
				        
		//Trato Campos de Data para Geracao dos Registros
		cDtEmiss  := Right( (cAliasC600)->C20_DTDOC, 2 ) + SubStr( (cAliasC600)->C20_DTDOC, 5, 2 ) + Left( (cAliasC600)->C20_DTDOC, 4 )
			        						            
		aRegC600 := {}
		aAdd ( aRegC600, {} )																		

		aAdd ( aRegC600[1], "C600" )  							//01 - REG
		aAdd ( aRegC600[1], (cAliasC600)->C01_CODIGO )		    //02 - COD_MOD
		aAdd ( aRegC600[1], (cAliasC600)->( C09_CODIGO + C07_CODIGO ) )         //03 - COD_MUN
		aAdd ( aRegC600[1], (cAliasC600)->C20_SERIE  )         //04 - SER
		aAdd ( aRegC600[1], (cAliasC600)->C20_SUBSER )         //05 - SUB
		aAdd ( aRegC600[1], (cAliasC600)->C0L_CODIGO )         //06 - COD_CONS
		aAdd ( aRegC600[1], 0  )		   						//07 - QTD_CONS	 					
		aAdd ( aRegC600[1], 0  )       					  	    //08 - QTD_CANC
		aAdd ( aRegC600[1], cDtEmiss )	       				    //09 - DT_DOC
		aAdd ( aRegC600[1], 0  )							    //10 - VL_DOC
		aAdd ( aRegC600[1], 0  )		   						//11 - VL_DESC		
		aAdd ( aRegC600[1], 0  )        						//12 - CONS  
		aAdd ( aRegC600[1], 0  )        						//13 - VL_FORN
		aAdd ( aRegC600[1], 0  )        						//14 - VL_SERV_NT
		aAdd ( aRegC600[1], 0  )        						//15 - VL_TERC
		aAdd ( aRegC600[1], 0  )        						//16 - VL_DA
		aAdd ( aRegC600[1], 0  )  						        //17 - VL_BC_ICMS
		aAdd ( aRegC600[1], 0  )        						//18 - VL_ICMS
		aAdd ( aRegC600[1], 0  )        					  	//19 - VL_BC_ICMS_ST
		aAdd ( aRegC600[1], 0  )        					  	//20 - VL_ICMS_ST
		aAdd ( aRegC600[1], 0  )        						//21 - VL_PIS
		aAdd ( aRegC600[1], 0  )		   						//22 - VL_COFINS																
		
		//Monta Chave do Registro para geracao do Registro C600
		cChvC600 := (cAliasC600)->( C01_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER + C0L_CODIGO + C20_DTDOC ) 				
			
					
		While (cAliasC600)->( !Eof() ) .And. cChvC600 == (cAliasC600)->( C01_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER + C0L_CODIGO + C20_DTDOC ) 		
			
			cCodObs := ""
								           
			//Verifica se a Nota Fiscal eh Cancelada
		    lNfCanc := (cAliasC600)->C02_CODIGO == "02" 	    					        
		    
		    nContNFN++ 
		    
			If lNfCanc	
				nContNFC++    		
				
				If SubStr( aWizardBc[2][2], 1, 1 ) == "B" 						
					RegC601( @cStrTxt02, cAliasC600 )
				EndIf
				
			EndIf               
			
			aRegC600[1][10] += (cAliasC600)->C20_VLDOC    	      //10 - VL_DOC
			aRegC600[1][11] += (cAliasC600)->C20_VLDESC 		  //11 - VL_DESC		
			aRegC600[1][12] += (cAliasC600)->C2E_CONS           //12 - CONS  
			aRegC600[1][13] += (cAliasC600)->C2E_VLFORN         //13 - VL_FORN
			aRegC600[1][14] += (cAliasC600)->C2E_VSERNT         //14 - VL_SERV_NT
			aRegC600[1][15] += (cAliasC600)->C2E_VLTERC         //15 - VL_TERC
			aRegC600[1][16] += (cAliasC600)->C20_VLRDA          //16 - VL_DA			
			
			If (cAliasC2C)->( MsSeek( xFilial(cAliasC2C) + (cAliasC600)->C20_CHVNF ) )
				If (cAliasC3R)->( MsSeek( xFilial(cAliasC3R) + (cAliasC2C)->C2C_CODOBS ) )
					cCodObs := 	(cAliasC3R)->( C3R_CODIGO )			
				EndIf					
			EndIf						
		            		            
			cChvNF := (cAliasC600)->( C20_FILIAL + C20_CHVNF )
				
				     			
			While (cAliasC600)->( !Eof() ) .And. cChvC600 == (cAliasC600)->( C01_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER + C0L_CODIGO + C20_DTDOC ) .And. ;
											cChvNF == (cAliasC600)->( C20_FILIAL + C20_CHVNF )
                		
				cCodClass := ""
	
				//Busca as Informacoes da Tabela C32 que nao eh retornada 
				//na query                                                
				If (cAliasC32)->(MsSeek( xFilial(cAliasC32) + ( (cAliasC600)->( C20_CHVNF + C30_NUMITE + C30_CODITE ) ) ) )				
					If (cAliasC0K)->(MsSeek( xFilial(cAliasC0K) + (cAliasC32)->C32_CCLASS ) )
						cCodClass := (cAliasC0K)->C0K_CODIGO
					EndIf                     
				EndIf
						                    																										
				//Zero Array com Informacoes dos tributos referentes ao item da NF
				aTrib := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    			
	                        
				//Neste Momento tenho que gravar as informacoes do Item da NF           
				//para posteriormente utilizar no Ascan do Registro C610 e sua posterior
				//geracao                                                               
	            aAux := Array(8)
	            	            
	            aAux[1] := (cAliasC600)->( C1L_CODIGO )
	            aAux[2] := Right(Alltrim(C1J_CODIGO), 6)
	            aAux[3] := (cAliasC600)->C0Y_CODIGO
	            aAux[4] := (cAliasC600)->( C1O_CODIGO )
	            aAux[5] := (cAliasC600)->C30_QUANT
	            aAux[6] := (cAliasC600)->C30_TOTAL
	            aAux[7] := (cAliasC600)->C30_VLDESC
	            aAux[8] := (cAliasC600)->C30_VLOPER
				 
				//Busco Numero do Item para geracao do Registro C610
				cChvIte := (cAliasC600)->C30_NUMITE 
								            																																																						            			
				//Neste momento para cada Item da NF eu realizo a Busca pelos 
				//valores dos Tributos                                        
				
				While (cAliasC600)->( !Eof() ) .And. cChvC600 == (cAliasC600)->( C01_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER + C0L_CODIGO + C20_DTDOC ) .And. ;		
				       							cChvNF == (cAliasC600)->( C20_FILIAL + C20_CHVNF ) .And. cChvIte == (cAliasC600)->C30_NUMITE 
				    
					 A117GetTrib( cAliasC600, @aTrib )
		
					(cAliasC600)->(DbSkip())			
				EndDo //Laco do Tributo do Item	
							
				//Neste momento Armazeno os valores do Registro C610 com as
				//quebras necessarias                                      
				If Len( aRegC610 ) <= 0 .Or. ( nPosC610 := aScan( aRegC610, { |x| x[2] == cCodClass .And. x[3] == aAux[1] .And. ;
				                                                                    x[5] == aAux[2] .And. x[8] == aTrib[10] .And. ;
				                                                                    x[9] == aAux[3] .And. x[10] == aTrib[12].And. ;
				                                                                    x[17] == aAux[4] } ) ) <= 0 								            
				
					aAdd ( aRegC610, {} )																		
					nPosC610 := Len( aRegC610 )
		
					aAdd ( aRegC610[nPosC610], "C610"    )  						//01 - REG
					aAdd ( aRegC610[nPosC610], cCodClass )	  						//02 - COD_CLASS		
					aAdd ( aRegC610[nPosC610], aAux[1]  )							//03 - COD_ITEM
					aAdd ( aRegC610[nPosC610], 0 )			  						//04 - QTD
					aAdd ( aRegC610[nPosC610], aAux[2] )							//05 - UNID	
					aAdd ( aRegC610[nPosC610], 0 )			  						//06 - VL_ITEM
					aAdd ( aRegC610[nPosC610], 0 )			  						//07 - VL_DESC
					aAdd ( aRegC610[nPosC610], aTrib[10] )			  				//08 - CST_ICMS
					aAdd ( aRegC610[nPosC610], aAux[3] )							//09 - CFOP
					aAdd ( aRegC610[nPosC610], aTrib[12] )			  				//10 - ALIQ_ICMS
					aAdd ( aRegC610[nPosC610], 0 )			  						//11 - VL_BC_ICMS
					aAdd ( aRegC610[nPosC610], 0 )			  						//12 - VL_ICMS
					aAdd ( aRegC610[nPosC610], 0 )			  						//13 - VL_BC_ICMS_ST
					aAdd ( aRegC610[nPosC610], 0 )			  						//14 - VL_ICMS_ST
					aAdd ( aRegC610[nPosC610], 0 )			  						//15 - VL_PIS
					aAdd ( aRegC610[nPosC610], 0 )			  						//16 - VL_COFINS
					aAdd ( aRegC610[nPosC610], aAux[4] )		    				//17 - COD_CTA	
									                                                                            	
				EndIf
			
				aRegC610[nPosC610][4]  +=  aAux[5] 								//04 - QTD
				aRegC610[nPosC610][6]  +=  aAux[6]				  					//06 - VL_ITEM
				aRegC610[nPosC610][7]  +=  aAux[7]									//07 - VL_DESC	  			
							
				aRegC610[nPosC610][11] += aTrib[1]         						//11 - VL_BC_ICMS
				aRegC610[nPosC610][12] += aTrib[2]         						//12 - VL_ICMS
				aRegC610[nPosC610][13] += aTrib[3]         						//13 - VL_BC_ICMS_ST
				aRegC610[nPosC610][14] += aTrib[4]         						//14 - VL_ICMS_ST			
				aRegC610[nPosC610][15] += aTrib[6]         						//15 - VL_PIS
				aRegC610[nPosC610][16] += aTrib[7]         						//16 - VL_COFINS						
				
				aRegC600[1][17] +=  aRegC610[nPosC610][11] 				        //17 - VL_BC_ICMS
				aRegC600[1][18] +=  aRegC610[nPosC610][12]         				//18 - VL_ICMS
				aRegC600[1][19] +=  aRegC610[nPosC610][13]        				  	//19 - VL_BC_ICMS_ST
				aRegC600[1][20] +=  aRegC610[nPosC610][14]        				  	//20 - VL_ICMS_ST
				aRegC600[1][21] +=  aRegC610[nPosC610][15]         				//21 - VL_PIS
				aRegC600[1][22] +=  aRegC610[nPosC610][16]  		   				//22 - VL_COFINS																					    
				
				If Len( aRegC690 ) <= 0 .Or. ( nPosC690 := aScan( aRegC690, { |x| x[2] == aTrib[10] .And. x[3] == aAux[3] .And. ;
                                                                                    x[4] == aTrib[12] .And. x[11] == cCodObs } ) ) <= 0
					aAdd ( aRegC690, {} )																		
					nPosC690 := Len( aRegC690 )
		
					aAdd ( aRegC690[nPosC690], "C690"    ) //01 - REG
					aAdd ( aRegC690[nPosC690], aTrib[10] ) //02 - CST_ICMS
					aAdd ( aRegC690[nPosC690], aAux[3]   ) //03 - CFOP
					aAdd ( aRegC690[nPosC690], aTrib[12] ) //04 - ALIQ_ICMS
					aAdd ( aRegC690[nPosC690], 0 )   		//05 - VL_OPR
					aAdd ( aRegC690[nPosC690], 0 )         //06 - VL_BC_ICMS
					aAdd ( aRegC690[nPosC690], 0 )         //07 - VL_ICMS
					aAdd ( aRegC690[nPosC690], 0 )			//08 - VL_RED_BC																												
					aAdd ( aRegC690[nPosC690], 0 )         //09 - VL_BC_ICMS_ST
					aAdd ( aRegC690[nPosC690], 0 )         //10 - VL_ICMS_ST
					aAdd ( aRegC690[nPosC690], StrTran( cCodObs, CRLF, "" )  )	//11 - COD_OBS												
					
				EndIf								
				
				aRegC690[nPosC690][5]   +=  aAux[8]      //05 - VL_OPR
				aRegC690[nPosC690][6]   +=  aTrib[1]      //06 - VL_BC_ICMS
				aRegC690[nPosC690][7]   +=  aTrib[2]      //07 - VL_ICMS
				aRegC690[nPosC690][8]   +=  aTrib[31]	   //08 - VL_RED_BC																												
				aRegC690[nPosC690][9]   +=  aTrib[3]      //09 - VL_BC_ICMS_ST
				aRegC690[nPosC690][10]  +=  aTrib[4]      //10 - VL_ICMS_ST				
			EndDo 									
		EndDo 
    	          
     	aRegC600[1][7]  += nContNFN    	      				//07 - QTD_CONS
	    aRegC600[1][8]  += nContNFC    	      				//08 - QTD_CANC
		        	  
		If SubStr( aWizardBc[2][2], 1, 1 ) == "B" 
	    	RegC600( @cStrTxt, aRegC600 )
	 	EndIf
    	
		cStrTxt := ( cStrTxt + cStrTxt02 )   	

		If SubStr( aWizardBc[2][2], 1, 1 ) == "B"     	
	    	RegC610( @cStrTxt, aRegC610 )
			RegC690( @cStrTxt, aRegC690 )	    	
	 	EndIf		
		
		aInfoGrv[5]++
    	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
    	    	
    	cStrTxt   := ""
    	cStrTxt02 := ""
    	
		nContNFN  := 0 
		nContNFC  := 0
    	
    	aRegC600  := {}
    	aRegC610  := {}    
    	aRegC690  := {}	    	
    EndDo  
	(cAliasC600)->(DbCloseArea())    

    cFilAnt := cFilBkp   	

//Realiza a Geracao do Registro C700 e Filhos
ElseIf cBlocGer == "C700" 
    
	//Posiciono nas tabelas em que serao necessarios os seeks
	DbSelectArea(cAliasC2C)
	(cAliasC2C)->(DbSetOrder(1))
	
	DbSelectArea(cAliasC3R)
	(cAliasC3R)->(DbSetOrder(3))
                 
	//Executa a Query para geracao dos registros    
    
    A117QrySpC( cAliasC700, aWizardBc, "C700_1", cFilSelBc )                                        

    cFilBkp := cFilAnt    	
        
        	                  	    	    										   		
    While !(cAliasC700)->(Eof())                                         
                        		                                                             
        cFilAnt := (cAliasC700)->C7M_FILIAL
        
        lC700Cons := .T.
        
		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf
        		
		aRegC700 := {}
		aAdd ( aRegC700, {} )
		
		aAdd ( aRegC700[1], "C700" )   						//01 - REG
		aAdd ( aRegC700[1], (cAliasC700)->C01_CODIGO )		//02 - COD_MOD	
		aAdd ( aRegC700[1], (cAliasC700)->C7M_NSER)		//03 - SER
		aAdd ( aRegC700[1], (cAliasC700)->C7M_NORDIN )		//04 - NRO_ORD_INI
		aAdd ( aRegC700[1], (cAliasC700)->C7M_NORDFI )		//05 - NRO_ORD_FIN
		aAdd ( aRegC700[1], Dt2Caract((cAliasC700)->C7M_DTDOCI))		//06 - DT_DOC_INI
		aAdd ( aRegC700[1], Dt2Caract((cAliasC700)->C7M_DTDOCF))		//07 - DT_DOC_FIN
		aAdd ( aRegC700[1], (cAliasC700)->C7M_NODCFI )		//08 - NOM_MEST
		aAdd ( aRegC700[1], (cAliasC700)->C7M_CHVDIG )		//09 - CHV_COD_DIG

	    cChvC700 := (cAliasC700)->( C01_CODIGO + C7M_NSER + C7M_NODCFI + C7M_CHVDIG )


		While !(cAliasC700)->(Eof()) .And. cChvC700 == (cAliasC700)->( C01_CODIGO + C7M_NSER + C7M_NODCFI + C7M_CHVDIG )

			cChvNF := (cAliasC700)->( C7M_FILIAL + C7M_ID )

			While !(cAliasC700)->(Eof()) .And. cChvC700 == (cAliasC700)->( C01_CODIGO + C7M_NSER + C7M_NODCFI + C7M_CHVDIG ) .And. ;
			 								cChvNF == (cAliasC700)->( C7M_FILIAL + C7M_ID )

				aAdd ( aRegC790, {} )
				nPosC790 := Len( aRegC790 )

				aAdd ( aRegC790[nPosC790],  "C790" )  				 		//01 - REG
				aAdd ( aRegC790[nPosC790],  '0'+(cAliasC700)->C14_CODIGO )		//02 - CST_ICMS
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C0Y_CODIGO ) 	//03 - CFOP
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_ALQICM ) 	//04 - ALIQ_ICMS
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VLOPR  )	 	//05 - VL_OPR
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VLBCIC )	 	//06 - VL_BC_ICMS
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VLICMS )		//07 - VL_ICMS
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VBCSTI )		//08 - VL_BC_ICMS_ST
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VLSTIC )		//09 - VL_ICMS_ST
				aAdd ( aRegC790[nPosC790],  (cAliasC700)->C7N_VLREBC )		//10 - VL_RED_BC
				aAdd ( aRegC790[nPosC790],  StrTran( (cAliasC700)->(C3R_CODIGO ), CRLF, "" ) )		//11 - COD_OBS
				
				
				
				If (cAliasC700)->C01_CODIGO = "06"
					aAdd ( aRegC791, {} )																		
					nPosC791 := Len( aRegC791 )

					aAdd ( aRegC791[nPosC791], nPosC790 )    				 //01 - RELACAO COM O PAI
					aAdd ( aRegC791[nPosC791], "C791"   )     				 //02 - REG                  
					aAdd ( aRegC791[nPosC791], (cAliasC700)->C09_UF  )	     //03 - UF     
					aAdd ( aRegC791[nPosC791], (cAliasC700)->C7O_VLBCIC )	 //04 - VL_BC_ICMS_ST				
					aAdd ( aRegC791[nPosC791], (cAliasC700)->C7O_VLSTIC )	 //05 - VL_ICMS_ST	          
				End If                   
				
				(cAliasC700)->(DbSkip())
				
			EndDo
		EndDo    
		RegC700( @cStrTxt, aRegC700 )
		RegC790( @cStrTxt, aRegC790, aRegC791 )
	
	
		aInfoGrv[5]++
    	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'C790' )
	    	
    	aRegC790 := {}
    	aRegC791 := {}
    EndDo
           
	//Executa a Query para geracao dos registros

	//Verifica se ja processou pela tabela dos consolidados.		
	If !lC700Cons

		DbSelectArea(cAliasC2C)
		(cAliasC2C)->(DbSetOrder(1))

		DbSelectArea(cAliasC3R)
		(cAliasC3R)->(DbSetOrder(3))
       
        cAliasC700  := GetNextAlias() 
		A117QrySpC( cAliasC700, aWizardBc, "C700", cFilSelBc )

	    cFilBkp := cFilAnt

	    While !(cAliasC700)->(Eof())

	        cFilAnt := (cAliasC700)->C20_FILIAL

			If !lGerC001
				RegC001( cStrTxt, "0" )
				lGerC001 := .T.
			EndIf

			aRegC700 := {}
			aAdd ( aRegC700, {} )

			aAdd ( aRegC700[1], "C700" )   						//01 - REG
			aAdd ( aRegC700[1], (cAliasC700)->C01_CODIGO )		//02 - COD_MOD
		aAdd ( aRegC700[1], (cAliasC700)->C20_SERIE )		//03 - SER
		aAdd ( aRegC700[1], "" )		   					//04 - NRO_ORD_INI
		aAdd ( aRegC700[1], "" )							//05 - NRO_ORD_FIN
		aAdd ( aRegC700[1], "" )							//06 - DT_DOC_INI
		aAdd ( aRegC700[1], "" )							//07 - DT_DOC_FIN
		aAdd ( aRegC700[1], (cAliasC700)->C20_MESTRE )		//08 - NOM_MEST	
		aAdd ( aRegC700[1], (cAliasC700)->C20_CHVCOD )		//09 - CHV_COD_DIG																					
		
		cNumIni := (cAliasC700)->C20_NUMDOC
		cNumFin := (cAliasC700)->C20_NUMDOC		

		cDtIni  := (cAliasC700)->C20_DTDOC
		cDtFin  := (cAliasC700)->C20_DTDOC
	    
	    cChvC700 := (cAliasC700)->( C01_CODIGO + C20_SERIE + C20_MESTRE + C20_CHVCOD )
	        
		While !(cAliasC700)->(Eof()) .And. cChvC700 == (cAliasC700)->( C01_CODIGO + C20_SERIE + C20_MESTRE + C20_CHVCOD )
		    
			 cCodObs := ""
 	
			//Tratamento para se verificar a Numeracao da Nota Fiscal Inicial so periodo
            If (cAliasC700)->C20_NUMDOC < cNumIni  
				cNumIni := (cAliasC700)->C20_NUMDOC
			EndIf 
							
			//Tratamento para se verificar a Numeracao da Nota Fiscal Final do Periodo
			If (cAliasC700)->C20_NUMDOC	 > cNumFin 
				cNumFin := (cAliasC700)->C20_NUMDOC
			EndIf    
            		
			//Tratamento para se verificar a Emissao da Nota Fiscal Inicial so periodo  			
			If (cAliasC700)->C20_DTDOC < cDtIni
               	cDtIni  := (cAliasC700)->C20_DTDOC
			EndIf
 
			//Tratamento para se verificar a Emissao da Nota Fiscal Final do Periodo  
			If (cAliasC700)->C20_DTDOC > cDtFin
				cDtFin  := (cAliasC700)->C20_DTDOC
			EndIf 
			
			If (cAliasC2C)->( MsSeek( xFilial(cAliasC2C) + (cAliasC700)->C20_CHVNF ) )
				If (cAliasC3R)->( MsSeek( xFilial(cAliasC3R) + (cAliasC2C)->C2C_CODOBS ) )
					cCodObs := 	(cAliasC3R)->( C3R_CODIGO )			
				EndIf					
			EndIf												
			 
			cChvNF := (cAliasC700)->( C20_FILIAL + C20_CHVNF )
			     
                                                                                                           
			While !(cAliasC700)->(Eof()) .And. cChvC700 == (cAliasC700)->( C01_CODIGO + C20_SERIE + C20_MESTRE + C20_CHVCOD ) .And. ;
			 								cChvNF == (cAliasC700)->( C20_FILIAL + C20_CHVNF )
			 								

				//Zero Array com Informacoes dos tributos referentes ao item da NF
				aTrib := { 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "", 0, 0, 0, 0, "", 0, 0, 0, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }                                              	    			

				//Neste Momento tenho que gravar as informacoes do Item da NF           
				//para posteriormente utilizar no Ascan do Registro C790 e sua posterior
				//geracao                                                               
	           aAux := Array(4)
	            	            
	           aAux[1] := (cAliasC700)->C0Y_CODIGO
	           aAux[2] := (cAliasC700)->C30_TOTAL
				 aAux[3] := (cAliasC700)->C09_UF 
				 aAux[4] := (cAliasC700)->C01_CODIGO 

				//Busco Numero do Item para geracao do Registro C610
				cChvIte := (cAliasC700)->C30_NUMITE            								
								            																																																						            			
				//Neste momento para cada Item da NF eu realizo a Busca pelos 
				//valores dos Tributos                                        
				While (cAliasC700)->( !Eof() ) .And. cChvC700 == (cAliasC700)->( C01_CODIGO + C20_SERIE + C20_MESTRE + C20_CHVCOD ) .And. ;		
				       							cChvNF == (cAliasC700)->( C20_FILIAL + C20_CHVNF ) .And. cChvIte == (cAliasC700)->C30_NUMITE 
				       																       															 								
					A117GetTrib( cAliasC700, @aTrib )	 					

					(cAliasC700)->(DbSkip())
				EndDo   
				
				//Neste momento Armazeno os valores do Registro C790 com as
				//quebras necessarias                                      
				If Len( aRegC790 ) <= 0 .Or. ( nPosC790 := aScan( aRegC790, { |x| x[2] == aTrib[10] .And. x[3] == aAux[1] .And. ;
																					x[4] == aTrib[12] .And. x[11] == cCodObs } ) ) <= 0 	
				
					aAdd ( aRegC790, {} )																		
					nPosC790 := Len( aRegC790 )
		
					aAdd ( aRegC790[nPosC790],  "C790" )  	 //01 - REG 					
					aAdd ( aRegC790[nPosC790],  aTrib[10] ) //02 - CST_ICMS			
					aAdd ( aRegC790[nPosC790],  aAux[1]   ) //03 - CFOP			
					aAdd ( aRegC790[nPosC790],  aTrib[12] ) //04 - ALIQ_ICMS			
					aAdd ( aRegC790[nPosC790],  0  )		 //05 - VL_OPR			
					aAdd ( aRegC790[nPosC790],  0  )		 //06 - VL_BC_ICMS			
					aAdd ( aRegC790[nPosC790],  0  )		 //07 - VL_ICMS			
					aAdd ( aRegC790[nPosC790],  0  )		 //08 - VL_BC_ICMS_ST			
					aAdd ( aRegC790[nPosC790],  0  )		 //09 - VL_ICMS_ST			
					aAdd ( aRegC790[nPosC790],  0  )		 //10 - VL_RED_BC			
					aAdd ( aRegC790[nPosC790],  StrTran( cCodObs, CRLF, "" ) )	 //11 - COD_OBS																																																
									
				EndIf
				
				aRegC790[nPosC790][5]    +=	 aAux[2]		//05 - VL_OPR			
				aRegC790[nPosC790][6]    +=	 aTrib[1]		//06 - VL_BC_ICMS			
				aRegC790[nPosC790][7]    +=	 aTrib[2]		//07 - VL_ICMS			
				aRegC790[nPosC790][8]    +=	 aTrib[3]		//08 - VL_BC_ICMS_ST			
				aRegC790[nPosC790][9]    +=	 aTrib[4]		//09 - VL_ICMS_ST			
				aRegC790[nPosC790][10]   +=	 aTrib[31]		//10 - VL_RED_BC							
								
				//Somente se gera o Registro C791 para Notas Fiscais modelo 06
				If aAux[4] == "06"
					
					//Neste momento Armazeno os valores do Registro C790 com as
					//quebras necessarias                                      
					If Len( aRegC791 ) <= 0 .Or. ( nPosC791 := aScan( aRegC791, { |x| x[3] == aAux[3] } ) ) <= 0
																						
	
						aAdd ( aRegC791, {} )																		
						nPosC791 := Len( aRegC791 )
			                                                                 
						aAdd ( aRegC791[nPosC791], nPosC790 )      //01 - RELACAO COM O PAI
						aAdd ( aRegC791[nPosC791], "C791"   )      //02 - REG
						aAdd ( aRegC791[nPosC791], aAux[3]  )	    //03 - UF
						aAdd ( aRegC791[nPosC791], 0 )				//04 - VL_BC_ICMS_ST					
						aAdd ( aRegC791[nPosC791], 0 )				//05 - VL_ICMS_ST																																				
																						
					EndIf				                                                                
					
					aRegC791[nPosC791][4] += aTrib[3] 				//04 - VL_BC_ICMS_ST					
					aRegC791[nPosC791][5] += aTrib[4] 				//05 - VL_ICMS_ST									
					
				EndIf
			EndDo
		EndDo          
		    
		//Trato Campos de Data para Geracao dos Registros
		cDtIni  := Right( cDtIni, 2 ) + SubStr( cDtIni, 5, 2 ) + Left( cDtIni, 4 )
		cDtFin  := Right( cDtFin, 2 ) + SubStr( cDtFin, 5, 2 ) + Left( cDtFin, 4 )		 

		aRegC700[1][4]	:= 	cNumIni   							//04 - NRO_ORD_INI
		aRegC700[1][5]	:=  cNumFin								//05 - NRO_ORD_FIN
		aRegC700[1][6]	:=	cDtIni								//06 - DT_DOC_INI
		aRegC700[1][7]	:= 	cDtFin								//07 - DT_DOC_FIN		
	
		RegC700( @cStrTxt, aRegC700 )
		RegC790( @cStrTxt, aRegC790, aRegC791 )

		aInfoGrv[5]++
    	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,  'C790' )
    	
    	aRegC790 := {}
    	aRegC791 := {}
    	    	    			
   	EndDo
   	
   	(cAliasC700)->(DbCloseArea())     

    cFilAnt := cFilBkp    	    
	EndIf    
	
//Realiza a Geracao do Registro C800 e Filhos
ElseIf cBlocGer == "C800"     
    	
	//Nesta Primeira Query realizo a geracao dos registros C800 e C850
	//por se tratar de Cupom Fiscal e sua respectiva Consolidacao     
	
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC800, aWizardBc, "C800_1", cFilSelBc )                                        

	cFilBkp := cFilAnt
	
	While !(cAliasC800)->(Eof())                                         
                        		                                                             
		cFilAnt := (cAliasC800)->C5S_FILIAL
		aRegC800 := {}
		aRegC850 := {}
		nVLPIS := 0
		nVLCOF := 0
		nVLICMS := 0
		nVLPISST := 0
		nVLCOFST := 0
		
		If !lGerC001
			RegC001( cStrTxt, "0" ) 
			lGerC001 := .T.
		EndIf
	  
		aAdd ( aRegC800, {} )
		aAdd ( aRegC800[1], "C800" )//01 - REGADMIN
		aAdd ( aRegC800[1], "59" ) //02 - COD_MOD      	      	
		aAdd ( aRegC800[1], Alltrim( (cAliasC800)->C02_CODIGO ) )//03 - COD_SIT
		aAdd ( aRegC800[1], Alltrim( (cAliasC800)->C5R_NUMCFE ) )//04 - NUM_CFE
		aAdd ( aRegC800[1], '' ) //05 - DT_DOC  
		aAdd ( aRegC800[1], '' ) //06 - VL_CFE
		aAdd ( aRegC800[1], '' ) //07 - VL_PIS
		aAdd ( aRegC800[1], '' ) //08 - VL_COFINS
		aAdd ( aRegC800[1], '' )	//09 - CNPJ_CPF  																
		aAdd ( aRegC800[1], Alltrim( (cAliasC800)->C0W_ECFFAB ) )//10 - NR_SAT
		aAdd ( aRegC800[1], Alltrim( (cAliasC800)->C5R_CHVCFE ) )//11 - CHV_NFE
		aAdd ( aRegC800[1], '' )//12 - VL_DESC
		aAdd ( aRegC800[1], '' )//13 - VL_MERC
		aAdd ( aRegC800[1], '' )//14 - VL_OUT_DA
		aAdd ( aRegC800[1], '' )//15 - VL_ICMS
		aAdd ( aRegC800[1], '' )//16 - VL_PIS_ST
		aAdd ( aRegC800[1], '' )//17 - VL_COFINS_ST
	  
	  	cChvC800 := (cAliasC800)->( C02_CODIGO + C5R_NUMCFE + C5R_DTDOC + C5R_CNPJ + C5R_CPF + C5R_CHVCFE  )
        
		While !(cAliasC800)->(Eof()) .And. cChvC800 == (cAliasC800)->( C02_CODIGO + C5R_NUMCFE + C5R_DTDOC + C5R_CNPJ + C5R_CPF + C5R_CHVCFE  )       
       
			If (cAliasC800)->C02_CODIGO <> "02" .And. (cAliasC800)->C02_CODIGO <> "03"
		  
				aRegC800[ 1 , 5 ] := Alltrim(  Right( (cAliasC800)->C5R_DTDOC, 2 ) + SubStr( (cAliasC800)->C5R_DTDOC, 5, 2 ) + Left( (cAliasC800)->C5R_DTDOC, 4 ) )  //05 - DT_DOC  
				aRegC800[ 1 , 6 ] := Val2Str( (cAliasC800)->C5R_VLCFE, 16, 2 ) //06 - VL_CFE  
			
				If !Empty( (cAliasC800)->C5R_CNPJ )
					aRegC800[ 1 , 9 ] :=	Alltrim( (cAliasC800)->C5R_CNPJ)  //09 - CNPJ_CPF
				Else                                                       
					aRegC800[ 1 , 9 ] :=	Alltrim( (cAliasC800)->C5R_CPF ) //09 - CNPJ_CPF	
				EndIf						  																
			
				aRegC800[ 1 , 12 ] := Val2Str( (cAliasC800)->C5R_VLDESC, 16, 2 )	 //12 - VL_DESC
				aRegC800[ 1 , 13 ] := Val2Str( (cAliasC800)->C5R_VLMERC, 16, 2 )   //13 - VL_MERC
				aRegC800[ 1 , 14 ] := Val2Str( (cAliasC800)->C5R_VLOUTD, 16, 2 )   //14 - VL_OUT_DA
				
			
				cChvC850 := (cAliasC800)->( CSTICMS + C0Y_CODIGO + Str( C5T_ALIQ ) + C3R_FILIAL + C3R_CODIGO )
		                                                                        
			   	nVLPIS		+= (cAliasC800)->VLPIS
				nVLCOF		+= (cAliasC800)->VLCOF
				nVLICMS	+= (cAliasC800)->VLICMS							
				nVLPISST	+= (cAliasC800)->VLPISST										
				nVLCOFST	+= (cAliasC800)->VLCOFST
					
				//Eh Obrigatorio que exista sempre o calculo de ICMS no Cupom Fiscal, quando isso nao ocorrer o registro C850 nao sera gerado             
				If !Empty( (cAliasC800)->CSTICMS )
			      
				aAdd ( aRegC850, {} )
				nPos := Len( aRegC850 )																	
			                                                                 
				aAdd ( aRegC850[nPos], "C850" )      													//01 - REG
				aAdd ( aRegC850[nPos], (cAliasC800)->ORIGEM + (cAliasC800)->CSTICMS )    		//02 - CST_ICMS
				aAdd ( aRegC850[nPos], (cAliasC800)->C0Y_CODIGO )									//03 - CFOP								
				aAdd ( aRegC850[nPos], (cAliasC800)->C5T_ALIQ )    									//04 - ALIQ_ICMS
				aAdd ( aRegC850[nPos], 0 )                   										//05 - VL_OPR
				aAdd ( aRegC850[nPos], 0 )                   										//06 - VL_BC_ICMS
				aAdd ( aRegC850[nPos], 0 )                   										//07 - VL_ICMS
				aAdd ( aRegC850[nPos], StrTran( (cAliasC800)->( C3R_CODIGO ), CRLF, "" ) )	    //08 - COD_OBS															
	       	        
				While !(cAliasC800)->(Eof()) .And. cChvC800 == (cAliasC800)->( C02_CODIGO + C5R_NUMCFE + C5R_DTDOC + C5R_CNPJ + C5R_CPF + C5R_CHVCFE  ) .And. ;
											       cChvC850 == (cAliasC800)->( CSTICMS + C0Y_CODIGO + Str( C5T_ALIQ ) + C3R_FILIAL + C3R_CODIGO )                                                                		                
					aRegC850[nPos][5] += (cAliasC800)->C5S_VLOPR  						//05 - VL_OPR
					aRegC850[nPos][6] += (cAliasC800)->BCICMS     						//06 - VL_BC_ICMS
					aRegC850[nPos][7] += (cAliasC800)->VLICMS     						//07 - VL_ICMS								
			   			         							   
					(cAliasC800)->(DbSkip() )      			  		  
				EndDo
				 			 	 	
				Endif
	
				aRegC800[ 1 , 7 ] := Val2Str( nVLPIS,   16, 2 ) 
				aRegC800[ 1 , 8 ] := Val2Str( nVLCOF,   16, 2 )	
				aRegC800[ 1 , 15 ] := Val2Str( nVLICMS,  16, 2 )	
				aRegC800[ 1 , 16 ] := Val2Str( nVLPISST, 16, 2 )	
				aRegC800[ 1 , 17 ] := Val2Str( nVLCOFST, 16, 2 )	
			
			   (cAliasC800)->(DbSkip() )   					
			
			Else
			 
				(cAliasC800)->(DbSkip() ) 
				
			Endif
		
		EndDo
		
		If SubStr( aWizardBc[2][2], 1, 1 ) == "A"	
			RegC800( @cStrTxt, aRegC800  )
		EndIf  
	  
		For nX := 1 To len ( aRegC850 )
			If SubStr( aWizardBc[2][2], 1, 1 ) == "A"                                      
				RegC850( @cStrTxt, aRegC850, nX )
			EndIf
		Next nX
					 		
	Enddo
	(cAliasC800)->(DbCloseArea())


	aInfoGrv[5]++    	
	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'C800' )
	
    	
	//Neste segundo momento realiza-se a query para geracao dos Registros
	//C860 e C890 que se trata de um consolidado por Identificacao       
	//do Equipamento SAT CF-E                                            
   	
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC800, aWizardBc, "C800_3", cFilSelBc )                                        
        	                     
    if !(cAliasC800)->(Eof())
	    
	    While !(cAliasC800)->(Eof())
	
		    aRegC860 := {}
			aAdd ( aRegC860, {} )
			lC800Cons := .T.

			aAdd ( aRegC860[1], "C860" ) 						//01 - REG
			aAdd ( aRegC860[1], (cAliasC800)->C01_CODIGO )   	//02 - COD_MOD
			aAdd ( aRegC860[1], (cAliasC800)->C7P_NRSAT )     	//03 - NR_SAT
			aAdd ( aRegC860[1], Dt2Caract((cAliasC800)->C7P_DTDOC ))		//04 - DT_DOC                           
			aAdd ( aRegC860[1], (cAliasC800)->C7P_DOCINI )  	//05 - DOC_INI
			aAdd ( aRegC860[1], (cAliasC800)->C7P_DOCFIM )	 	//06 - DOC      
			
	        cChvC860 := (cAliasC800)->( C7P_NRSAT + C7P_DTDOC )
		
		
			While !(cAliasC800)->(Eof()) .And.  cChvC860 == (cAliasC800)->( C7P_NRSAT + C7P_DTDOC )
			
				cChvC890 := (cAliasC800)->( CSTICMS + CFOP + Str( C7T_ALQICM ) + CODOBS )
	
				If SubStr( aWizardBc[2][2], 1, 1 ) == "B"
					
					While !(cAliasC800)->(Eof()) .And.  cChvC860 == (cAliasC800)->( C7P_NRSAT + C7P_DTDOC ) .And. ;
											              cChvC890 == (cAliasC800)->( CSTICMS + CFOP + Str( C7T_ALQICM ) + CODOBS)
											              
						//Somente gero o Registro C890 quando existir calculo de ICMS        
						//no Cupom Fiscal (Obrigatorio), caso contrario o registro eh omitido
			           If !Empty( (cAliasC800)->C03_CODIGO )
						     RegC890_2( @cStrTxt02, cAliasC800 )
						 EndIf
						(cAliasC800)->(DbSkip())
					EndDo
				Else
					(cAliasC800)->(DbSkip())
				EndIf
            EndDo
			If SubStr( aWizardBc[2][2], 1, 1 ) == "B"		
				RegC860( @cStrTxt, aRegC860 ) 
			EndIf

			cStrTxt := ( cStrTxt + cStrTxt02 )

			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )

			cStrTxt   := ""
			cStrTxt02 := ""
	    EndDo

	EndIf
    If select(cAliasC800) > 0
    	(cAliasC800)->(DbCloseArea())
    Endif

	cFilAnt := cFilBkp
	If !lC800Cons
	
	//Executa a Query para geracao dos registros
	A117QrySpC( cAliasC800, aWizardBc, "C800_2", cFilSelBc )                                        
        	                         	                        	                  	    	    										   		
    
    While !(cAliasC800)->(Eof())                                         
         
		//Trato Campos de Data para Geracao dos Registros
		cDtEmiss  := Right( (cAliasC800)->C5R_DTDOC, 2 ) + SubStr( (cAliasC800)->C5R_DTDOC, 5, 2 ) + Left( (cAliasC800)->C5R_DTDOC, 4 )
		
        aRegC860 := {}	       	 
		aAdd ( aRegC860, {} )																		
                                                                 
		aAdd ( aRegC860[1], "C860" ) 						  //01 - REG
		aAdd ( aRegC860[1], "59"   )       //02 - COD_MOD FISCAL - "chumbado" 59 por ser unico valor valido conforme guia pratico
		aAdd ( aRegC860[1], (cAliasC800)->C0W_ECFFAB )       //03 - NR_SAT
		aAdd ( aRegC860[1], cDtEmiss )					      //04 - DT_DOC
		aAdd ( aRegC860[1], (cAliasC800)->C5T_NUMCFE )  	  //05 - DOC_INI
		aAdd ( aRegC860[1], (cAliasC800)->C5T_NUMCFE )	 	  //06 - DOC_FIM										
        
        cChvC860 := (cAliasC800)->( C0W_ECFFAB + C5R_DTDOC )
        
        
        While !(cAliasC800)->(Eof()) .And.  cChvC860 == (cAliasC800)->( C0W_ECFFAB + C5R_DTDOC )
                         
			//Tratamento para se verificar a Numeracao da Nota Fiscal Inicial so periodo
            If (cAliasC800)->C5T_NUMCFE < aRegC860[1][5]  
				aRegC860[1][5] := (cAliasC800)->C5T_NUMCFE
			EndIf 
							
			//Tratamento para se verificar a Numeracao da Nota Fiscal Final do Periodo
			If (cAliasC800)->C5T_NUMCFE	 > aRegC860[1][6] 
				aRegC860[1][6] := (cAliasC800)->C5T_NUMCFE
			EndIf    			 
            
            cChvC890 := (cAliasC800)->( C14_CODIGO + C0Y_CODIGO + Str( C5T_ALIQ ) + C3R_FILIAL + C3R_CODIGO )              
                                                        
			If SubStr( aWizardBc[2][2], 1, 1 ) == "B"		
				
				While !(cAliasC800)->(Eof()) .And.  cChvC860 == (cAliasC800)->( C0W_ECFFAB + C5R_DTDOC ) .And. ;
										              cChvC890 == (cAliasC800)->( C14_CODIGO + C0Y_CODIGO + Str( C5T_ALIQ ) + C3R_FILIAL + C3R_CODIGO )              			
				
					//Somente gero o Registro C890 quando existir calculo de ICMS        
					//no Cupom Fiscal (Obrigatorio), caso contrario o registro eh omitido
		           If !Empty( (cAliasC800)->C3S_CODIGO )                                                                                         
					 	RegC890( @cStrTxt02, cAliasC800 )
					 EndIf 
				 									              
					(cAliasC800)->(DbSkip())			
				EndDo
			Else
				(cAliasC800)->(DbSkip())			
			EndIf									 	    	
		EndDo     
		        
		If SubStr( aWizardBc[2][2], 1, 1 ) == "B"		
			RegC860( @cStrTxt, aRegC860 ) 
		EndIf
		
		cStrTxt := ( cStrTxt + cStrTxt02 )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
		
		cStrTxt   := ""
		cStrTxt02 := ""
		
    EndDo    
    (cAliasC800)->(DbCloseArea())
    	
	cFilAnt := cFilBkp   	    
    EndIf 	
EndIf

Return  ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC001

Abertura do Bloco C

@Param	cStrTxt -> String para gravacao dos Registros 
		cIndMov -> Indicador de Movimento
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC001( cStrTxt, cIndMov )                                    
    
Local cDelimit  := "|"
				
cStrTxt += cDelimit
cStrTxt += "C001" + cDelimit         //01 - REG  		
cStrTxt += cIndMov + cDelimit  		 //02 - IND_MOV
cStrTxt	+= CRLF	   

//Conta os registros para totalizar no bloco 9
TaFContBlc("C001",aTotRegC)	
			
aInfoGrv[5]++			
WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )	

Return  ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC100

Realiza a Emissao do Registro C100 (Nota Fiscal (Codigo 01), Nota Fiscal
Avulsa (Codigo 1B), Nota Fiscal de Produtor (Codigo 04) e NFe(Codigo 55) 
e seus respectivos filhos

@Param		aWizardBc    -> Wizard com as Parametrizacoes do Usuario
			cStrTxt    -> String para gravacao dos Registros 
			cStrTxt02  -> String Para Gravacao dos Registros
			cStrTxt03  -> String Para Gravacao dos Registros
			aNF         -> Informacoes da Nota Fiscal
			aTrib       -> Valores de Impostos da NF
			lNfCanc     -> Indica se a NF a ser gerada eh Cancelada                        
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC100( aWizardBc, cStrTxt, cStrTxt02, cStrTxt03,  aNF, aTrib, lNfCanc )

Local cDelimit := "|"

Local nlI := 1 

cStrTxt += cDelimit				
cStrTxt += "C100" + cDelimit 					//01 - REG  	 
cStrTxt += Alltrim( aNf[1][3] ) + cDelimit    //02 - IND_OPER
cStrTxt += Alltrim( aNf[1][4] ) + cDelimit    //03 - IND_EMIT
                
//Notas Fiscais Canceladas/Cancelada Extemporaneo/ NFe Denegada
//Inutilizada deve-se preencher apenas os campos acima         
If !lNfCanc                    

	//Geração do Registro 0150/0175	
	If (Alltrim( aNf[1][5] ) != "65") //Caso modelo 65 não gerar o registro 0150 nem o código do participante no registor C100
		xGerBlc0( "0150",  aNf[1][10], cFilSelBc, aWizardBc, cTabSpd )	
		cStrTxt += Alltrim( aNf[1][10] ) + cDelimit    //04 - COD_PART
	Else
		cStrTxt += cDelimit
	End
	  					
	cStrTxt += Alltrim( aNf[1][5] ) + cDelimit     //05 - COD_MOD  	
	cStrTxt += Alltrim( aNf[1][6] ) + cDelimit     //06 - COD_SIT  	
	cStrTxt += Alltrim( aNf[1][7] ) + cDelimit     //07 - SER  	
	cStrTxt += Alltrim( aNf[1][8] ) + cDelimit     //08 - NUM_DOC  		

	If aNf[1][6] <> "05"		
		cStrTxt += Alltrim( aNf[1][9] ) + cDelimit  //09 - CHV_NFE  						
	Else
		cStrTxt += "" + cDelimit                     //09 - CHV_NFE  			
	EndIf

	cStrTxt += Alltrim( aNf[1][11] ) + cDelimit		        //10 - DT_DOC  	
	cStrTxt += Alltrim( aNf[1][12] ) + cDelimit         		//11 - DT_E_S  	
	cStrTxt += Val2Str( aNf[1][13], 16, 2 ) + cDelimit         //12 - VL_DOC  	
	cStrTxt += Alltrim( aNf[1][14] ) + cDelimit         		//13 - IND_PGTO  	
	cStrTxt += Val2Str( aNf[1][15], 16, 2 ) + cDelimit         //14 - VL_DESC  			
	cStrTxt += Val2Str( aNf[1][16], 16, 2 ) + cDelimit         //15 - VL_ABAT_NT
	cStrTxt += Val2Str( aNf[1][17], 16, 2 ) + cDelimit         //16 - VL_MERC
	cStrTxt += Alltrim( aNf[1][18] ) + cDelimit        		//17 - IND_FRT
	cStrTxt += Val2Str(  aNf[1][19], 16, 2 ) + cDelimit        //18 - VL_FRT
	cStrTxt += Val2Str(  aNf[1][20], 16, 2 ) + cDelimit        //19 - VL_SEG
	cStrTxt += Val2Str(  aNf[1][21], 16, 2 ) + cDelimit        //20 - VL_OUT_DA	        
	cStrTxt += Val2Str(  aTrib[1], 16, 2 ) + cDelimit  	     //21 - VL_BC_ICMS
	cStrTxt += Val2Str(  aTrib[2], 16, 2 ) + cDelimit           //22 - VL_ICMS
	
	//Caso modelo 65 não gerar os valores no registor C100
	If (Alltrim( aNf[1][5] ) != "65")
		cStrTxt += Val2Str(  aTrib[3], 16, 2 ) + cDelimit           //23 - VL_BC_ICMS_ST
		cStrTxt += Val2Str(  aTrib[4], 16, 2 ) + cDelimit           //24 - VL_ICMS_ST
		cStrTxt += Val2Str(  aTrib[5], 16, 2 ) + cDelimit           //25 - VL_IPI
		cStrTxt += Val2Str(  aTrib[6], 16, 2 ) + cDelimit           //26 - VL_PIS
		cStrTxt += Val2Str(  aTrib[7], 16, 2 ) + cDelimit           //27 - VL_COFINS
		cStrTxt += Val2Str(  aTrib[8], 16, 2 ) + cDelimit           //28 - VL_PIS_ST
		cStrTxt += Val2Str(  aTrib[9], 16, 2 ) + cDelimit           //29 - VL_COFINS_ST
	Else
		cStrTxt += Replicate(cDelimit, 7)
	EndIf
Else                                                        

	cStrTxt += "" + cDelimit		    	       //04 - COD_PART
	cStrTxt += Alltrim( aNf[1][5] ) + cDelimit    //05 - COD_MOD  	
	cStrTxt += Alltrim( aNf[1][6] ) + cDelimit    //06 - COD_SIT  	
	cStrTxt += Alltrim( aNf[1][7] ) + cDelimit    //07 - SER  	
	cStrTxt += Alltrim( aNf[1][8] ) + cDelimit    //08 - NUM_DOC  		

	If aNf[1][6] <> "05"		
		cStrTxt += Alltrim( aNf[1][9] ) + cDelimit //09 - CHV_NFE  						
	Else
		cStrTxt += "" + cDelimit                	//09 - CHV_NFE  			
	EndIf
			
	//Tratamento para levar os demais campos em Branco para notas
	//fiscais canceladas                                         
    For nlI := 1 To 20
 	  	cStrTxt += "" + cDelimit
    Next nlI	                                        
   
EndIf                           

cStrTxt	+=	CRLF

//Conta os registros para totalizar no bloco 9
TaFContBlc("C100",aTotRegC)	
	                   
//Deve-se apenas realizar a emissao dos registros filhos quando a 
//NF nao for Cancelada/Inutilizada/Denegada                       
If !lNfCanc								
        
    cChvNF  := aNF[1][1]           				
	
	//Deve-se Gerar apenas para modelo 55 de Emissao Propria
	If aNf[1][5] == "55" .And. aNf[1][4] == "0"									
		RegC101( @cStrTxt, cChvNF )
		RegC105( @cStrTxt, cChvNF )
	EndIf
	
	RegC110( @cStrTxt, aNF, cChvNF )
	
	//Grava Registro C120				
	RegC120( @cStrTxt, cChvNF )	


	//Verifica se eh operacao de Saida
	If aNF[1][3] == "1"	 			
		RegC130( @cStrTxt, cChvNF )				
	EndIf                   
		
	//Verifica se o modelo da NF 01
	If aNf[1][5] == "01"					
		RegC140( @cStrTxt, cChvNF )
	EndIf			

	//Verifica se eh operacao de Saida
	If aNF[1][3] == "1"	 				

		//Verifica se o Modelo da NF eh 01|04
		If aNf[1][5] $ "01|04"
  			If SubStr( aWizardBc[2][5], 1, 1 ) == "1"
				RegC160( @cStrTxt, cChvNF )
			Else						
	  			If aNf[1][5] == "01"
					RegC165( @cStrTxt, cChvNF )
				EndIf
		  	EndIf
		EndIf							                                          	
	EndIf

	//Verifica se o modelo da NF eh 01|1B|55
	If aNf[1][5] $ "01|1B|55"

		//Gera-se na String cStrTxt02 pois no arquivo esta informacao eh
		//impressa apos os registros dos itens da nota fiscal           
		RegC195( @cStrTxt03, cChvNF )
	EndIf  
	
EndIf		 
 						 											 				                				       						 										                  										
Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC101

Realiza a Emissao do Registro C101 - Informação Complementar dos Documentos
Fiscais Quando das Operações Interestaduais Destinadas a Consumidor Final
não Contribuinte EC 87/15 (Código 55)

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Paulo Santana
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC101( cStrTxt, cChvNF )

Local cDelimit  := "|"
Local cAliasC2F := "C2F"
Local cIdOrig   := "000020" //ID. do Tributo de ICMS Complementar (DIFAL) - UF ORIGEM   
Local cIdDest   := "000021" //ID. do Tributo de ICMS Complementar (DIFAL) - UF DESTINO
Local cIdFecp   := "000022" //ID. do Tributo de FECP UF DE DESTINO
Local nDifalOri := 0

DbSelectArea( cAliasC2F )
C2F->(DbSetOrder(1))
If C2F->( MsSeek( xFilial( "C2F" ) + cChvNF + cIdOrig ) ) 
	nDifalOri := C2F->C2F_VALOR
	cStrTxt += cDelimit		
	cStrTxt += "C101" + cDelimit																							//01 - REG  	 
	cStrTxt += Val2Str( IIF(C2F->(MsSeek(xFilial( "C2F" )+cChvNF+cIdFecp)),C2F->C2F_VALOR,0), 16, 2 ) + cDelimit																//02 - VL_FCP_UF_DEST
	cStrTxt += Val2Str( IIF(C2F->(MsSeek(xFilial( "C2F" )+cChvNF+cIdDest)),C2F->C2F_VALOR,0), 16, 2 ) + cDelimit	//03 - VL_ICMS_UF_DEST
	cStrTxt += Val2Str( nDifalOri, 16, 2 )+ cDelimit	//04 - VL_ICMS_UF_REM
	cStrTxt += CRLF	   
		
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C101",aTotRegC)	

EndIf                                            
		
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC105

Realiza a Emissao do Registro C105 - Operacoes com ICMS/ST Recolhido para
UF Diversa do Destinatario do Documento Fiscal (Codigo 55)

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC105( cStrTxt, cChvNF )

Local cDelimit  := "|"

Local cAliasC2H := "C2H"    
Local cAliasC09 := "C09"  

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))   

DbSelectArea( cAliasC2H )
(cAliasC2H)->(DbSetOrder(1))
If (cAliasC2H)->( MsSeek( xFilial( "C2H" ) + cChvNF ) )    
	If (cAliasC09)->( MsSeek( xFilial( "C09" ) + (cAliasC2H)->	C2H_UF ) )	    		
		cStrTxt += cDelimit		
		cStrTxt += "C105" + cDelimit 			     			      //01 - REG  	 
		cStrTxt += Alltrim( (cAliasC2H)->C2H_OPER ) + cDelimit      //02 - OPER     
		cStrTxt += Alltrim( (cAliasC09)->C09_UF   ) + cDelimit      //03 - UF   
		cStrTxt	+= CRLF	   
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C105",aTotRegC)	
							            	
	EndIf
EndIf                                            
		
Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC110

Realiza a Emissao do Registro C110 - Informacao Complementar da Nota Fiscal 
(Codigo 01, 1B, 04 e 55 )

@Param		cStrTxt     -> String para gravacao do Registro  
			aNF         -> Informacoes da Nota Fiscal
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC110( cStrTxt, aNF, cChvNF )

Local cChvC21   := ""
Local cDelimit  := "|"                   

Local cAliasC21 := "C21"    
Local cAliasC3Q := "C3Q"      
                                                                                                     
DbSelectArea( cAliasC3Q )
(cAliasC3Q)->(DbSetOrder(3))

DbSelectArea( cAliasC21 )
(cAliasC21)->(DbSetOrder(1))
If (cAliasC21)->( MsSeek( xFilial( "C21" ) + cChvNF ) )    
	While (cAliasC21)->(!Eof()) .And. (cAliasC21)->C21_CHVNF ==  cChvNF
		If (cAliasC3Q)->( MsSeek( xFilial( "C3Q" ) + (cAliasC21)->	C21_CODINF ) )	    		
			
			cStrTxt += cDelimit			                                                			
			cStrTxt += "C110" + cDelimit			           						   //01 - REG  	 		
			
			xGerBlc0( "0450",  Alltrim( (cAliasC3Q)->(C3Q_CODINF) ), cFilSelBc, aWizardBc, cTabSpd )			
			cStrTxt += Alltrim( (cAliasC3Q)->(C3Q_CODINF) ) + cDelimit  //02 - COD_INF
			   
			cStrTxt += Left( Alltrim( StrTran( (cAliasC21)->C21_DESCRI, CRLF, "" ) ), 255 ) + cDelimit                 //03 - TXT_COMPL
			cStrTxt	+= CRLF				
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("C110",aTotRegC)			
							
			//Monta a Chave do Registro C110, para geracao dos Registros Filhos
			cChvC21 := cChvNF + (cAliasC21)->C21_CODINF
			       
			//Grava Registro C111				
			RegC111( @cStrTxt, cChvC21 )
            
			//Grava Registro C112				
			RegC112( @cStrTxt, cChvC21 )

			//Grava Registro C113				
			RegC113( @cStrTxt, cChvC21 )
			
			//Grava Registro C114				
			RegC114( @cStrTxt, cChvC21 )
									            
			//Somente deve-se gerar o Registro C115 para os modelos 01|1B|04
			//e Operacoes de Saida                                          
		   	If aNf[1][5] $ "01|1B|04" .And. aNF[1][3] == "1"
				
				//Grava Registro C115				
				RegC115( @cStrTxt, cChvC21 )
			EndIf                                                                                                                                                   
			
			//Grava Registro C116				
			RegC116( @cStrTxt, cChvC21 )
						
		EndIf          
		(cAliasC21)->(DbSkip())
	EndDo
EndIf    

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC111

Realiza a Emissao do Registro C111 - Processo Referenciado

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC111( cStrTxt, cChvC21 )

Local cDelimit  := "|"

Local cAliasC22 := "C22"    
Local cAliasC1G := "C1G"  

DbSelectArea( cAliasC1G )
(cAliasC1G)->(DbSetOrder(3))

DbSelectArea( cAliasC22 )
(cAliasC22)->(DbSetOrder(1))
If (cAliasC22)->( MsSeek( xFilial( "C22" ) + cChvC21 ) )    
	While (cAliasC22)->(!Eof()) .And. (cAliasC22)->(C22_CHVNF + C22_CODINF ) == cChvC21
		If (cAliasC1G)->( MsSeek( xFilial( "C1G" ) + (cAliasC22)->	C22_NUMERO) )	    					
			cStrTxt += cDelimit
			cStrTxt += "C111" + cDelimit 			           		  //01 - REG  	 		
			cStrTxt += Alltrim( (cAliasC1G)->C1G_NUMPRO ) + cDelimit //02 - NUM_PROC   
			cStrTxt += Alltrim( (cAliasC1G)->C1G_INDPRO ) + cDelimit //03 - IND_PROC
			cStrTxt	+= CRLF			  
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("C111",aTotRegC)			
						
		EndIf   
		(cAliasC22)->(DbSkip())
	EndDo         
EndIf    

Return ( Nil )                 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC112

Realiza a Emissao do Registro C112 - Documento de Arrecadacao Referenciado

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 11/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC112( cStrTxt, cChvC21 )

Local cDelimit  := "|"
                    
Local cAliasC25 := "C25"    
Local cAliasC0R := "C0R"                             
Local cAliasC09 := "C09"

DbSelectArea( cAliasC0R )
(cAliasC0R)->(DbSetOrder(6))

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))

DbSelectArea( cAliasC25 )
(cAliasC25)->(DbSetOrder(1))
If (cAliasC25)->( MsSeek( xFilial( "C25" ) + cChvC21 ) )    
	While (cAliasC25)->(!Eof()) .And. (cAliasC25)->(C25_CHVNF + C25_CODINF ) == cChvC21
		If (cAliasC0R)->( MsSeek( xFilial( "C0R" ) + (cAliasC25)->	C25_IDENTI ) )	    		
			If (cAliasC09)->( MsSeek( xFilial("C09") + (cAliasC0R)->C0R_UF ) )							
				cStrTxt += cDelimit								
				cStrTxt += "C112" + cDelimit		       			 											//01 - REG  	 		
				cStrTxt += Alltrim( (cAliasC0R)->C0R_CODDA ) + cDelimit     									//02 - COD_DA  	 		
				cStrTxt += Alltrim( (cAliasC09)->C09_UF     ) + cDelimit	 									//03 - UF  	 		
				cStrTxt += Alltrim( (cAliasC0R)->C0R_NUMDA  ) + cDelimit    									//04 - NUM_DA  	 		
				cStrTxt += Alltrim( (cAliasC0R)->C0R_CODAUT ) + cDelimit	 									//05 - COD_AUT  	 		
				cStrTxt += Val2Str( (cAliasC0R)->C0R_VLDA, 16, 2  ) + cDelimit									//06 - VL_DA  	 		
				cStrTxt += Alltrim( StrTran( DToC( (cAliasC0R)->C0R_DTVCT  ), "/", "" ) ) + cDelimit  		    //07 - DT_VCTO  	 		
				cStrTxt += Alltrim( StrTran( DToC( (cAliasC0R)->C0R_DTPGT  ), "/", "" ) ) + cDelimit  			//08 - DT_PGTO  	 					
				cStrTxt	+= CRLF	 
				
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("C112",aTotRegC)			
														
			EndIf			
		EndIf   
		(cAliasC25)->(DbSkip())
	EndDo         
EndIf    

Return ( Nil )         

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC113

Realiza a Emissao do Registro C113 - Documento Fiscal Referenciado

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 11/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC113( cStrTxt, cChvC21 )

Local cDelimit  := "|"
                    
Local cAliasC26 := "C26"    
Local cAliasC1H := "C1H"                             
Local cAliasC01 := "C01"

DbSelectArea( cAliasC1H )
(cAliasC1H)->(DbSetOrder(5))

DbSelectArea( cAliasC01 )
(cAliasC01)->(DbSetOrder(3))

DbSelectArea( cAliasC26 )
(cAliasC26)->(DbSetOrder(1))
If (cAliasC26)->( MsSeek( xFilial( "C26" ) + cChvC21 ) )    
	While (cAliasC26)->(!Eof()) .And. (cAliasC26)->(C26_CHVNF + C26_CODINF ) == cChvC21
		If (cAliasC1H)->( MsSeek( xFilial( "C1H" ) + (cAliasC26)->	C26_CODPAR ) )	    		
			If (cAliasC01)->( MsSeek( xFilial("C01") + (cAliasC26)->C26_CODMOD ) )											
				cStrTxt += cDelimit
				cStrTxt += "C113" + cDelimit                        						//01 - REG
				cStrTxt += Alltrim( (cAliasC26)->C26_INDOPE ) + cDelimit                   //02 - IND_OPER
				cStrTxt += Alltrim( (cAliasC26)->C26_INDEMI ) + cDelimit		            //03 - IND_EMIT

				//Geração do Registro 0150/0175
				xGerBlc0( "0150",  (cAliasC1H)->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd )			
				cStrTxt += Alltrim( (cAliasC1H)->( C1H_CODPAR ) ) + cDelimit  //04 - COD_PART  
				
				cStrTxt += Alltrim( (cAliasC01)->C01_CODIGO ) + cDelimit	                //05 - COD_MOD
				cStrTxt += Alltrim( (cAliasC26)->C26_SERIE  ) + cDelimit	                //06 - SER
				cStrTxt += Alltrim( (cAliasC26)->C26_SUBSER ) + cDelimit	                //07 - SUB
				cStrTxt += Alltrim( (cAliasC26)->C26_NUMDOC ) + cDelimit	                //08 - NUM_DOC
				cStrTxt += StrTran(Dtoc( (cAliasC26)->C26_DTDOC  ), "/", "") + cDelimit   //09 - DT_DOC
				If TAFColumnPos( "C26_CHVELE" )				
					cStrTxt += Alltrim( (cAliasC26)->C26_CHVELE ) + cDelimit   				//10 - CHV_DOCe
				EndIf
				cStrTxt	+= CRLF	
				
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("C113",aTotRegC)		
														                                                                   
			EndIf			
		EndIf   
		(cAliasC26)->(DbSkip())
	EndDo         
EndIf    

Return ( Nil )                  

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC114

Realiza a Emissao do Registro C114 - Cupom Fiscal Referenciado

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 11/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC114( cStrTxt, cChvC21 )

Local cDelimit  := "|"
                    
Local cAliasC27 := "C27"    
Local cAliasC01 := "C01"    
Local cAliasC0W := "C0W"                             

DbSelectArea( cAliasC01 )
(cAliasC01)->(DbSetOrder(3))

DbSelectArea( cAliasC0W )
(cAliasC0W)->(DbSetOrder(4))

DbSelectArea( cAliasC27 )
(cAliasC27)->(DbSetOrder(1))
If (cAliasC27)->( MsSeek( xFilial( "C27" ) + cChvC21 ) )    
	While (cAliasC27)->(!Eof()) .And. (cAliasC27)->(C27_CHVNF + C27_CODINF ) == cChvC21      
		If (cAliasC01)->( MsSeek( xFilial("C01") + (cAliasC27)->C27_CODMOD ) )
							    		
			//Apenas deve gerar o registro C114 quando o modelo da NF for 02|2D|2E
			If (cAliasC01)->C01_CODIGO $ "02|2D|2E"
				If (cAliasC0W)->( MsSeek( xFilial( "C0W" ) + (cAliasC27)->	C27_CODECF ) )	    		
										
					cStrTxt += cDelimit
					cStrTxt += "C114" + cDelimit                         							//01 - REG
					cStrTxt += Alltrim( (cAliasC01)->C01_CODIGO ) + cDelimit     				    //02 - COD_MOD
					cStrTxt += Alltrim( (cAliasC0W)->C0W_ECFFAB ) + cDelimit      				    //03 - ECF_FAB
					cStrTxt += Alltrim( (cAliasC0W)->C0W_ECFCX  ) + cDelimit      				    //04 - ECF_CX
					cStrTxt += Alltrim( (cAliasC27)->C27_NUMDOC ) + cDelimit      					//05 - NUM_DOC
					cStrTxt += StrTran( DToC( (cAliasC27)->C27_DTDOC ), "/", "" ) + cDelimit      //06 - DT_DOC
					cStrTxt	+= CRLF	 
					
					//Conta os registros para totalizar no bloco 9
					TaFContBlc("C114",aTotRegC)			
										
				EndIf			
			EndIf
		EndIf   
		(cAliasC27)->(DbSkip())
	EndDo         
EndIf    

Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC115

Realiza a Emissao do Registro C115 - Local da Coleta e/ou Entrega
(Codigo 01, 1B e 04)

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 11/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC115( cStrTxt, cChvC21 )
                    
Local cDelimit  := "|"

Local cAliasC28 := "C28"    
Local cAliasC16 := "C16"    
Local cAliasC1H := "C1H"   
Local cAliasC07 := "C07"                          
Local cAliasC09 := "C09"                          

Local aPartCol := { "", "", "", "" }  
Local aPartEnt := { "", "", "", "" }  

DbSelectArea( cAliasC16 )
(cAliasC16)->(DbSetOrder(3))

DbSelectArea( cAliasC1H )
(cAliasC1H)->(DbSetOrder(5))

DbSelectArea( cAliasC07 )
(cAliasC07)->(DbSetOrder(4))

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))
DbSelectArea( cAliasC28 )
(cAliasC28)->(DbSetOrder(1))
If (cAliasC28)->( MsSeek( xFilial( "C28" ) + cChvC21 ) )    
	While (cAliasC28)->(!Eof()) .And. (cAliasC28)->(C28_CHVNF + C28_CODINF ) == cChvC21          
	    
		aPartCol := { "", "", "", "" }  
		aPartEnt := { "", "", "", "" }  
	
		If (cAliasC16)->( MsSeek( xFilial("C16") + (cAliasC28)->C28_INDCAR ) )			
	
			If (cAliasC1H)->( MsSeek( xFilial( "C1H" ) + (cAliasC28)->	C28_PARCOL ) )	    					
				If (cAliasC07)->( MsSeek( xFilial("C07") + (cAliasC1H)->C1H_UF + (cAliasC1H)->C1H_CODMUN ) ) .And.  ;
					(cAliasC09)->( MsSeek( xFilial("C09") + (cAliasC1H)->C1H_UF ) )
					aPartCol[4] := (cAliasC09)->C09_CODIGO + (cAliasC07)->C07_CODIGO          						
				EndIf
				aPartCol[1] := (cAliasC1H)->C1H_CNPJ
				aPartCol[2] := (cAliasC1H)->C1H_IE
				aPartCol[3] := (cAliasC1H)->C1H_CPF          
			EndIf
				
			If (cAliasC1H)->( MsSeek( xFilial( "C1H" ) + (cAliasC28)->	C28_PARENT ) )	    		
				If (cAliasC07)->( MsSeek( xFilial("C07") + (cAliasC1H)->C1H_UF + (cAliasC1H)->C1H_CODMUN ) ) .And. ;
  				   (cAliasC09)->( MsSeek( xFilial("C09") + (cAliasC1H)->C1H_UF ) )
					aPartEnt[4] := (cAliasC09)->C09_CODIGO + (cAliasC07)->C07_CODIGO          						
				EndIf
				aPartEnt[1] := (cAliasC1H)->C1H_CNPJ
				aPartEnt[2] := (cAliasC1H)->C1H_IE
				aPartEnt[3] := (cAliasC1H)->C1H_CPF          						
			EndIf
			
			//****************************************************************************
			//retirando caracteres como “.”, “/”, “-” dos campos IE_COL, IE_ENTG, CNPJ_COL, CPF_COL, CNPJ_ENTG e CPF_ENTG.			
			//IE_COL
			If aPartCol[2] $ "."
				aPartCol[2] := StrTran( aPartCol[2], ".", "")
			ElseIf aPartCol[2] $ "-"
				aPartCol[2] := StrTran( aPartCol[2], "-", "")
			ElseIf aPartCol[2] $ "/"
				aPartCol[2] := StrTran( aPartCol[2], "/", "")
			ElseIf aPartCol[2] $ "\"
				aPartCol[2] := StrTran( aPartCol[2], "\", "")
			EndIf
			
			//IE_ENTG
			If aPartEnt[2] $ "."
				aPartEnt[2] := StrTran( aPartEnt[2], ".", "")
			ElseIf aPartEnt[2] $ "-"
				aPartEnt[2] := StrTran( aPartEnt[2], "-", "")
			ElseIf aPartEnt[2] $ "/"
				aPartEnt[2] := StrTran( aPartEnt[2], "/", "")
			ElseIf aPartEnt[2] $ "\"
				aPartEnt[2] := StrTran( aPartEnt[2], "\", "")
			EndIf
			
			//CNPJ_COL
			If aPartCol[1] $ "."
				aPartCol[1] := StrTran( aPartCol[1], ".", "")
			ElseIf aPartCol[1] $ "-"
				aPartCol[1] := StrTran( aPartCol[1], "-", "")
			ElseIf aPartCol[1] $ "/"
				aPartCol[1] := StrTran( aPartCol[1], "/", "")
			ElseIf aPartCol[1] $ "\"
				aPartCol[1] := StrTran( aPartCol[1], "\", "")
			EndIf
			
			//CPF_COL
			If aPartCol[3] $ "."
				aPartCol[3] := StrTran( aPartCol[3], ".", "")
			ElseIf aPartCol[3] $ "-"
				aPartCol[3] := StrTran( aPartCol[3], "-", "")
			EndIf
			
			//CNPJ_ENTG
			If aPartEnt[1] $ "."
				aPartEnt[1] := StrTran( aPartEnt[1], ".", "")
			ElseIf aPartEnt[1] $ "-"
				aPartEnt[1] := StrTran( aPartEnt[1], "-", "")
			ElseIf aPartEnt[1] $ "/"
				aPartEnt[1] := StrTran( aPartEnt[1], "/", "")
			ElseIf aPartEnt[1] $ "\"
				aPartEnt[1] := StrTran( aPartEnt[1], "\", "")
			EndIf
				
			//CPF_ENTG
			If aPartEnt[3] $ "."
				aPartEnt[3] := StrTran( aPartEnt[3], ".", "")
			ElseIf aPartEnt[3] $ "-"
				aPartEnt[3] := StrTran( aPartEnt[3], "-", "")
			EndIf
			//############################################################################
			
			cStrTxt += cDelimit
			cStrTxt += "C115" + cDelimit                     			//01 - REG
			cStrTxt += Alltrim( (cAliasC16)->C16_CODIGO ) + cDelimit  	//02 - IND_CARGA
			cStrTxt += Alltrim( aPartCol[1] ) + cDelimit              	//03 - CNPJ_COL
			cStrTxt += Alltrim( aPartCol[2] ) + cDelimit              	//04 - IE_COL
			cStrTxt += Alltrim( aPartCol[3] ) + cDelimit			  		//05 - CPF_COL									                        
			cStrTxt += Alltrim( aPartCol[4] ) + cDelimit              	//06 - COD_MUN_COL
			cStrTxt += Alltrim( aPartEnt[1] ) + cDelimit              	//07 - CNPJ_ENTG
			cStrTxt += Alltrim( aPartEnt[2] ) + cDelimit              	//08 - IE_ENTG
			cStrTxt += Alltrim( aPartEnt[3] ) + cDelimit			   		//09 - CPF_ENTG									                        
			cStrTxt += Alltrim( aPartEnt[4] ) + cDelimit			   		//10 - COD_MUN_ENTG
			cStrTxt	+= CRLF	   
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("C115",aTotRegC)								
								                                                                                                
		EndIf
		(cAliasC28)->(DbSkip())
	EndDo         
EndIf    

Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC116

Realiza a Emissao do Registro C116 - Cupom Fiscal Eletronico Referenciado

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvC21     -> Chave da Tabela PAI C21
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 14/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC116( cStrTxt, cChvC21 )

Local cDelimit  := "|"
                    
Local cAliasC27 := "C27"    
Local cAliasC01 := "C01"    
Local cAliasC0W := "C0W"                             

DbSelectArea( cAliasC01 )
(cAliasC01)->(DbSetOrder(3))

DbSelectArea( cAliasC0W )
(cAliasC0W)->(DbSetOrder(4))

DbSelectArea( cAliasC27 )
(cAliasC27)->(DbSetOrder(1))
If (cAliasC27)->( MsSeek( xFilial( "C27" ) + cChvC21 ) )    
	While (cAliasC27)->(!Eof()) .And. (cAliasC27)->(C27_CHVNF + C27_CODINF ) == cChvC21      
		If (cAliasC01)->( MsSeek( xFilial("C01") + (cAliasC27)->C27_CODMOD ) )
											
			//Apenas devemos gerar o registro C116 para NFs modelo 59 
			If (cAliasC01)->C01_CODIGO == "58"
				If (cAliasC0W)->( MsSeek( xFilial( "C0W" ) + (cAliasC27)->	C27_CODECF ) )	    							
					cStrTxt += cDelimit										
					cStrTxt += "C116" + cDelimit                        						//01 - REG
					cStrTxt += Alltrim( (cAliasC01)->C01_CODIGO ) + cDelimit      				//02 - COD_MOD
					cStrTxt += Alltrim( (cAliasC0W)->C0W_ECFFAB ) + cDelimit     				//03 - NR_SAT
					cStrTxt += Alltrim( (cAliasC27)->C27_CHVCFE ) + cDelimit      				//04 - CHV_CFE
					cStrTxt += Alltrim( (cAliasC27)->C27_NUMDOC ) + cDelimit      				//05 - NUM_CFE
					cStrTxt += StrTran( DToC( (cAliasC27)->C27_DTDOC ), "/", "" ) + cDelimit  //06 - DT_DOC
					cStrTxt	+= CRLF	  
					
					//Conta os registros para totalizar no bloco 9
					TaFContBlc("C116",aTotRegC)		
													
				EndIf			
			EndIf
		EndIf   
		(cAliasC27)->(DbSkip())
	EndDo         
EndIf                               

Return ( Nil )  

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC120

Complemento de Documento - Operacoes de Importacao ( Codigo 01 e 55 )

@Param		cStrTxt     -> String para gravacao do Registro 
			cChvNF      -> Chave da Tabela PAI 
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 14/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC120( cStrTxt, cChvNF )	

Local cDelimit  := "|"
                    
Local cAliasC23 := "C23"          

DbSelectArea( cAliasC23 )
(cAliasC23)->(DbSetOrder(1))
If (cAliasC23)->( MsSeek( xFilial( "C23" ) + cChvNF ) )    
	While (cAliasC23)->(!Eof()) .And. (cAliasC23)->(C23_FILIAL + C23_CHVNF) == xFilial("C23") + cChvNF      
		
		cStrTxt += cDelimit										
		cStrTxt += "C120" + cDelimit                        						
		cStrTxt += Alltrim( (cAliasC23)->C23_TIPO   ) + cDelimit      				
		cStrTxt += Alltrim( (cAliasC23)->C23_NUMDOC ) + cDelimit     				
		cStrTxt += Val2Str( (cAliasC23)->C23_VLRPIS, 16, 2 ) + cDelimit      				
		cStrTxt += Val2Str( (cAliasC23)->C23_VLRCOF, 16, 2 ) + cDelimit      				
		cStrTxt += Alltrim( (cAliasC23)->C23_NDRAW  ) + cDelimit      				
		cStrTxt	+= CRLF	  
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C120",aTotRegC)			
													
		(cAliasC23)->(DbSkip())
	EndDo         
EndIf                               

Return ( Nil )      
         
//-------------------------------------------------------------------
/*/{Protheus.doc} RegC130

Realiza a Emissao do Registro C130 - ISSQN, IRRF e Previdencia Social

@Param		cStrTxt     -> String para gravacao do Registro  
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 14/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC130( cStrTxt, cChvNF )  

Local cChvC130  := ""
Local cDelimit  := "|"

Local cAliasC2F := "C2F"
Local cAliasC3S := "C3S" 

Local nlI 		:= 0

Local lGeraC130 := .F.
                                                                                  
Local aTotImp   := { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }  

//ISSQN|IRRF|PREVIDENCIA
Local aCodImp   := { "01", "12", "13" } 

DbSelectArea( cAliasC3S )
(cAliasC3S)->(DbSetOrder(1))

DbSelectArea( cAliasC2F )
(cAliasC2F)->(DbSetOrder(1))   

//Realizo uma Buca pelos Codigos de Tributos que sao necessarios                   
//para a geracao do Arquivo, para nao executar o While na C2F para todos           
//os tipos de impostos possiveis!                                                                                                                                   
//Como eh possivel se ter o mesmo tributo duas vezes para a mesma NF o laco        
//se torna necessario para aglutinar os valores e posteriormente realizar a geracao
//do Registro C130                                                                 
For nlI := 1 To Len( aCodImp )
	If (cAliasC3S)->( MsSeek( xFilial( "C3S" ) + aCodImp[nlI] ) )    
		If (cAliasC2F)->( MsSeek( xFilial( "C2F" ) + cChvNF + (cAliasC3S)->C3S_ID ) )    
			
			cChvC130  := (cAliasC2F)->(C2F_CHVNF + C2F_CODTRI)
			lGeraC130 := .T.
			
			While (cAliasC2F)->(!Eof()) .And. (cAliasC2F)->(C2F_CHVNF + C2F_CODTRI) == cChvC130
                 
				 aTotImp[nlI,1] += Iif( nlI == 1, (cAliasC2F)->C2F_VLNT, 0 )
				 aTotImp[nlI,2] += (cAliasC2F)->C2F_BASE
				 aTotImp[nlI,3] += (cAliasC2F)->C2F_VALOR
				 				
				(cAliasC2F)->(DbSkip())
			EndDo               					
		EndIf
	EndIf
Next nlI

If lGeraC130                                               	
	cStrTxt += cDelimit
	cStrTxt += "C130" + cDelimit	           				  //01 - REG
	cStrTxt += Val2Str(  aTotImp[1,1],16, 2 ) + cDelimit      //02 - VL_SERV_NT
	cStrTxt += Val2Str(  aTotImp[1,2],16, 2 ) + cDelimit      //03 - VL_BC_ISSQN
	cStrTxt += Val2Str(  aTotImp[1,3],16, 2 ) + cDelimit      //04 - VL_ISSQN
	cStrTxt += Val2Str(  aTotImp[2,2],16, 2 ) + cDelimit      //05 - VL_BC_IRRF
	cStrTxt += Val2Str(  aTotImp[2,3],16, 2 ) + cDelimit      //06 - VL_IRRF
	cStrTxt += Val2Str(  aTotImp[3,2],16, 2 ) + cDelimit      //07 - VL_BC_PREV
	cStrTxt += Val2Str(  aTotImp[3,3],16, 2 ) + cDelimit      //08 - VL_PREV        
	cStrTxt	+= CRLF                     
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C130",aTotRegC)			
				
EndIf

Return ( Nil )           

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC140

Realiza a Emissao do Registro C140 - Fatura ( Codigo 01 )

@Param		cStrTxt     -> String para gravacao do Registro  
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 14/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC140( cStrTxt, cChvNF )  

Local cChvC29   := ""                          
Local cDelimit  := "|" 

Local cAliasC29 := "C29"
                                                                            
DbSelectArea( cAliasC29 )
(cAliasC29)->(DbSetOrder(1))   
If (cAliasC29)->( MsSeek( xFilial( "C29" ) + cChvNF ) )    
                       
	cStrTxt += cDelimit                                                	
	cStrTxt +=  "C140" + cDelimit	        														//01 - REG
	cStrTxt += Alltrim( (cAliasC29)->C29_INDEMI ) + cDelimit   									//02 - IND_EMIT
	cStrTxt += Alltrim( (cAliasC29)->C29_INDTIT ) + cDelimit   									//03 - IND_TIT
	cStrTxt += Alltrim( (cAliasC29)->C29_DESCRI ) + cDelimit										//04 - DESC_TIT
	cStrTxt += Alltrim( (cAliasC29)->C29_NUMTIT ) + cDelimit										//05 - NUM_TIT
	cStrTxt += Val2Str(  (cAliasC29)->C29_QTDPAR, 16, 0 ) + cDelimit		//06 - QTD_PARC
	cStrTxt += Val2Str(  (cAliasC29)->C29_VLRTOT, 16, 2 ) + cDelimit	//07 - VL_TIT
	cStrTxt	+= CRLF	    
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C140",aTotRegC)			
							                                                         	
	cChvC29   := cChvNF + (cAliasC29)->( C29_INDEMI + C29_INDTIT + C29_NUMTIT )
	
	//Grava Registro C141				
	RegC141( @cStrTxt, cChvC29 )  
	
	(cAliasC29)->(DbSkip())					
EndIf

Return ( Nil )        

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC141

Realiza a Emissao do Registro C141 - Vencimento da Fatura ( Codigo 01 )

@Param		cStrTxt     -> String para gravacao do Registro  
			cChvC29     -> Chave do Registro C140
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 14/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC141( cStrTxt, cChvC29 )

Local cDelimit	as character
Local cAliasC2A	as character
Local cDtVenc	as character

cDelimit	:=	"|"
cAliasC2A	:=	"C2A"
cDtVenc		:=	""

DBSelectArea( cAliasC2A )
( cAliasC2A )->( DBSetOrder( 1 ) )
If ( cAliasC2A )->( MsSeek( xFilial( "C2A" ) + cChvC29 ) )
	While ( cAliasC2A )->( !Eof() ) .and. ( cAliasC2A )->( C2A_CHVNF + C2A_INDEMI + C2A_INDTIT + C2A_NUMTIT ) == cChvC29
		cStrTxt += cDelimit
		cStrTxt += "C141" + cDelimit																//01 - REG
		cStrTxt += Right( AllTrim( ( cAliasC2A )->C2A_NUMPAR ), 2 ) + cDelimit						//02 - NUM_PARC

		cDtVenc := DToS( ( cAliasC2A )->C2A_VECTO )
		cStrTxt += Right( cDtVenc, 2 ) + SubStr( cDtVenc, 5, 2 ) + Left( cDtVenc, 4 ) + cDelimit	//03 - DT_VCTO

		cStrTxt += Val2Str( ( cAliasC2A )->C2A_VLRPAR, 16, 2 ) + cDelimit							//04 - VL_PARC
		cStrTxt += CRLF

		//Conta os registros para totalizar no bloco 9
		TAFContBlc( "C141", aTotRegC )

		( cAliasC2A )->( DBSkip() )
	EndDo
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC160

Realiza a Emissao do Registro C160 - Volumes Transportados ( Codigo 01 e 04 ) 
Exceto Combustiveis

@Param		cStrTxt     -> String para gravacao do Registro  
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 15/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC160( cStrTxt, cChvNF )  

Local cCodPar   := "" 
Local cCodVei   := ""    
Local cUF       := ""                                                                           

Local cDelimit  := "|"

Local cAliasC2B := "C2B"
Local cAliasC1H := "C1H"
Local cAliasC0Q := "C0Q"
Local cAliasC09 := "C09"

DbSelectArea( cAliasC1H )
(cAliasC1H)->(DbSetOrder(5))   

DbSelectArea( cAliasC0Q )
(cAliasC0Q)->(DbSetOrder(4))   

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))

DbSelectArea( cAliasC2B )
(cAliasC2B)->(DbSetOrder(1))   
If (cAliasC2B)->( MsSeek( xFilial( "C2B" ) + cChvNF ) )    

	If (cAliasC1H)->(MsSeek( xFilial("C1H") + (cAliasC2B)->C2B_CODPAR ) )

		//Geração do Registro 0150/0175
		xGerBlc0( "0150",  (cAliasC1H)->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd )						    
	    cCodPar := (cAliasC1H)->( C1H_CODPAR )
	    
	EndIf
	
	If (cAliasC0Q)->(MsSeek( xFilial("C0Q") + (cAliasC2B)->C2B_CODVEI ) )
		cCodVei := (cAliasC0Q)->C0Q_PLACA
		
		If (cAliasC09)->(MsSeek( xFilial("C09") + (cAliasC0Q)->C0Q_UF ) )
			cUF := (cAliasC09)->C09_UF
		EndIf
	EndIf

	cStrTxt += cDelimit		
	cStrTxt += "C160" + cDelimit	  																//01 - REG
	cStrTxt += Alltrim( cCodPar ) + cDelimit                   										//02 - COD_PART
	cStrTxt += Alltrim( cCodVei ) + cDelimit                   										//03 - VEIC_ID
	cStrTxt += Val2Str(  (cAliasC2B)->C2B_QTDVOL, 16 ,0 ) + cDelimit										//04 - QTD_VOL	
	cStrTxt += Val2Str(  (cAliasC2B)->C2B_PESBRT, 16, 2 ) + cDelimit	//05 - PESO_BRT	
	cStrTxt += Val2Str(  (cAliasC2B)->C2B_PESLIQ, 16, 2 ) + cDelimit	//06 - PESO_LIQ	
	cStrTxt += Alltrim( cUF ) + cDelimit					    									//07 - UF_ID
	cStrTxt	+= CRLF	   
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C160",aTotRegC)				
			                                                         			
EndIf

Return ( Nil )  

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC165

Realiza a Emissao do Registro C165 - Operacoes com Combustiveis ( Codigo 01 )

@Param		cStrTxt     -> String para gravacao do Registro  
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 15/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC165( cStrTxt, cChvNF )  

Local cCodPar   := "" 
Local cCodVei   := ""    
Local cUF       := ""

Local cDelimit  := "|"

Local cAliasC2B := "C2B"
Local cAliasC1H := "C1H"
Local cAliasC0Q := "C0Q"
Local cAliasC09 := "C09"
                                                                           
DbSelectArea( cAliasC1H )
(cAliasC1H)->(DbSetOrder(5))   

DbSelectArea( cAliasC0Q )
(cAliasC0Q)->(DbSetOrder(4))   

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))

DbSelectArea( cAliasC2B )
(cAliasC2B)->(DbSetOrder(1))   
If (cAliasC2B)->( MsSeek( xFilial( "C2B" ) + cChvNF ) )    
    
	While (cAliasC2B)->(!Eof()) .And. cChvNF == (cAliasC2B)->C2B_CHVNF
		
		If (cAliasC1H)->(MsSeek( xFilial("C1H") + (cAliasC2B)->C2B_CODPAR ) )
		    
			//Geração do Registro 0150/0175
			xGerBlc0( "0150",  (cAliasC1H)->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd )				    
		    cCodPar := (cAliasC1H)->( C1H_CODPAR )
		    
		EndIf
		
		If (cAliasC0Q)->(MsSeek( xFilial("C0Q") + (cAliasC2B)->C2B_CODVEI ) )
			cCodVei := (cAliasC0Q)->C0Q_PLACA
			
			If (cAliasC09)->(MsSeek( xFilial("C09") + (cAliasC0Q)->C0Q_UF ) )
				cUF := (cAliasC09)->C09_UF
			EndIf
		EndIf
		                                              
		cStrTxt += cDelimit
		cStrTxt += "C165" + cDelimit	  																//01 - REG
		cStrTxt += Alltrim( cCodPar )+ cDelimit                              							//02 - COD_PART
		cStrTxt += Alltrim( cCodVei )+ cDelimit                                       					//03 - VEIC_ID
		cStrTxt += Alltrim( (cAliasC2B)->C2B_CODAUT )+ cDelimit                      					//04 - COD_AUT
		cStrTxt += Alltrim( (cAliasC2B)->C2B_PASSE  )+ cDelimit                      				    //05 - NR_PASSE
		cStrTxt += Alltrim( StrTran( (cAliasC2B)-> C2B_HORA, ":", "" )  )+ cDelimit 				    //06 - HORA	
		cStrTxt += Val2Str(  (cAliasC2B)->C2B_TEMPER, 16, 1 )+ cDelimit   //07 - TEMPER
		cStrTxt += Val2Str( (cAliasC2B)->C2B_QTDVOL, 16, 0 ) + cDelimit                      				    			//08 - QTD_VOL
		cStrTxt += Val2Str(  (cAliasC2B)->C2B_PESBRT, 16, 2 )+ cDelimit   //09 - PESO_BRT
		cStrTxt += Val2Str(  (cAliasC2B)->C2B_PESLIQ, 16, 2 )+ cDelimit   //10 - PESO_LIQ
		cStrTxt += Alltrim( (cAliasC2B)->C2B_NOMMOT )+ cDelimit                      					//11 - NOM_MOT
		cStrTxt += Alltrim( (cAliasC2B)->C2B_CPF )+ cDelimit		                   					//12 - CPF
		cStrTxt += Alltrim( cUF )+ cDelimit					                       						//13 - UF_ID
		cStrTxt	+= CRLF			    
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C165",aTotRegC)					
				                                                         
		(cAliasC2B)->(DbSkip())
	EndDo		
EndIf     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC170

Realiza a Emissao do Registro C170 - Itens do Documento ( Codigo 01, 1B, 04 e 55 )
e seus respectivos filhos

@Param		cStrTxt02   -> String para gravacao do Registro 
			aItensNF	-> Array com dados do Item da NF   
			aNF         -> Array Com dados da Nota Fiscal
			aTrib		-> Array com os tributos do item
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 16/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC170( cStrTxt02, aItensNF, aNf, aTrib )

Local cChvPai  := ""  
Local lGerC170 := .F.                   

Local nQtde := Iif( aItensNF[1][4] == 0, 1, aItensNF[1][4] )

Local cDelimit := "|"

Local cDescrComp := STRTRAN(aItensNF[1][3], CRLF, "") //04 - DESCR_COMPL
DbSelectArea("C37")
C37->(DbSetOrder(1))

//Atualizo a Chave de geracao dos registros filhos para Numero da 
//Chave da NF + Numero do Item                                    
cChvPai := ( aNf[1][1] + aItensNf[1][1] )
                      
//Verifico se Existe Item a ser Gravado
If !Empty( aItensNF[1][1] ) .And. !Empty( aItensNF[1][2] ) 
	
	//Para Notas Fiscais modelo 55 ( Nota Fiscal Eletronica ) a informacao do C170 apenas deve ser gerada
	//caso o registro C176 seja gerado tambem, sendo assim verifico se o mesmo sera gerado mais abaixo
	If aNf[1][5] == "55" 
		If aNF[1][4] == "1" //Verifica se o Indicador do emitente do documento fiscal é igual a terceiros
			//If C37->(MsSeek( xFilial("C37") + cChvPai ) )
				lGerC170 := .T.
			//EndIf	
		EndIf
	Else
		lGerC170 := .T.
	EndIf
	
	If lGerC170
		cStrTxt02 += cDelimit			    							
		cStrTxt02 += "C170" + cDelimit 			 	 												  //01 - REG
		cStrTxt02 += Alltrim( aItensNF[1][1] ) + cDelimit	 										  //02 - NUM_ITEM				 	 
		
		//Geração do Registro 0200
		xGerBlc0( "0200",  Alltrim( aItensNF[1][2] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aItensNF[1][5] ) )						
		cStrTxt02 += Alltrim( aItensNF[1][2] ) + cDelimit	 										  //03 - COD_ITEM
						 	 
		cStrTxt02 += Alltrim( cDescrComp ) + cDelimit	 									      //04 - DESCR_COMPL				 	 
		cStrTxt02 += Val2Str( nQtde, 16, 5 ) + cDelimit											  //05 - QTD				 	 
		
		//Geração do Registro 0190
		xGerBlc0( "0190",  Alltrim( aItensNF[1][5] ), cFilSelBc, aWizardBc, cTabSpd )
		cStrTxt02 += Alltrim( aItensNF[1][5] ) + cDelimit	 										  //06 - UNID				 	 
		
		cStrTxt02 += Val2Str( aItensNF[1][24], 16, 2 ) + cDelimit 								      //07 - VL_ITEM					 	 
		cStrTxt02 += Val2Str( aItensNF[1][7], 16, 2 ) + cDelimit      								  //08 - VL_DESC					 	 
		cStrTxt02 += Alltrim( aItensNF[1][8] ) + cDelimit	 										  //09 - IND_MOV				 	 	
	    	
		//Se o campo referente ao CST de ICMS para Notas Fiscais de Complemento              
		//nao estiver vazio, utilizo o mesmo para geracao do registro, caso contrario utilizo
		//o CST amarrado natabela C35 ( Tributo do Item )                                    
		If Empty( aTrib[10]  ) 
			cStrTxt02 += Alltrim( aItensNF[1][25]  ) + cDelimit       									  //10 - CST_ICMS	 	
		Else
			cStrTxt02 += Alltrim( aTrib[10] ) + cDelimit       									  //10 - CST_ICMS	 	
		EndIf
		
		cStrTxt02 += Alltrim( aItensNF[1][9] ) + cDelimit   	 									  //11 - CFOP					 	 
		
		//Geração do Registro 0400
		xGerBlc0( "0400",  Alltrim( aItensNF[1][10] ), cFilSelBc, aWizardBc, cTabSpd )
		cStrTxt02 += Alltrim( aItensNF[1][10]) + cDelimit	     									  //12 - COD_NAT
						 	 
		cStrTxt02 += Val2Str(  aTrib[1], 16, 2 ) + cDelimit			  //13 - VL_BC_ICMS	 
		cStrTxt02 += Val2Str(  aTrib[12], 16, 2 ) + cDelimit			  //14 - ALIQ_ICMS	 
		cStrTxt02 += Val2Str(  aTrib[2], 16, 2 ) + cDelimit			  //15 - VL_ICMS	 
		cStrTxt02 += Val2Str(  aTrib[3], 16, 2 ) + cDelimit			  //16 - VL_BC_ICMS_ST	 
		cStrTxt02 += Val2Str(  aTrib[13], 16, 2 ) + cDelimit			  //17 - ALIQ_ST	 
		cStrTxt02 += Val2Str(  aTrib[4], 16, 2 ) + cDelimit			  //18 - VL_ICMS_ST	 
		cStrTxt02 += Alltrim( aItensNF[1][11] ) + cDelimit	 	 									  //19 - IND_APUR
		cStrTxt02 += Alltrim( aTrib[11] ) + cDelimit	 		 									  //20 - CST_IPI						 	 	
		cStrTxt02 += "" + cDelimit   		    	 	 											  //21 - COD_ENQ					 	 
		cStrTxt02 += Val2Str(  aTrib[14], 16, 2 ) + cDelimit			  //22 - VL_BC_IPI
		cStrTxt02 += Val2Str(  aTrib[15], 16, 2 ) + cDelimit			  //23 - ALIQ_IPI
		cStrTxt02 += Val2Str(  aTrib[5], 16, 2  ) + cDelimit			  //24 - VL_IPI	                   	                                                                     
		cStrTxt02 += Alltrim( aTrib[16] ) + cDelimit		  	 									  //25 - CST_PIS
		
		If aTrib[17] > 0				 	 
			cStrTxt02 += Val2Str(  aTrib[17], 16, 2 ) + cDelimit			//26 - VL_BC_PIS
		Else
			cStrTxt02 += "" + cDelimit										//26 - VL_BC_PIS
		EndIf
		
		If aTrib[18] > 0
			cStrTxt02 += Val2Str(  aTrib[18], 16, 4 ) + cDelimit		  //27 - ALIQ_PIS
		Else
			cStrTxt02 += "" + cDelimit										//27 - ALIQ_PIS
		EndIf
		
		If aTrib[19] > 0
			cStrTxt02 += Val2Str(  aTrib[19], 16, 3 ) + cDelimit		 	  //28 - QUANT_BC_PIS
		Else
			cStrTxt02 += "" + cDelimit										//28 - QUANT_BC_PIS
		EndIf
		
		If aTrib[20] > 0
			cStrTxt02 += Val2Str(  aTrib[20], 16, 4 ) + cDelimit		  //29 - ALIQ_PIS
		Else
			cStrTxt02 += "" + cDelimit										//29 - ALIQ_PIS
		EndIf
		
		cStrTxt02 += Val2Str(  aTrib[6], 16, 2 ) + cDelimit			  //30 - VL_PIS	                    	
		cStrTxt02 += Alltrim( aTrib[22] ) + cDelimit		 	 									  //31 - CST_COFINS	
		
		If aTrib[23] > 0
			cStrTxt02 += Val2Str(  aTrib[23], 16, 2 ) + cDelimit			  //32 - VL_BC_COFINS
		Else
			cStrTxt02 += "" + cDelimit										//32 - VL_BC_COFINS
		EndIf
		
		If aTrib[24] > 0
			cStrTxt02 += Val2Str(  aTrib[24], 16, 4 ) + cDelimit		  //33 - ALIQ_COFINS
		Else
			cStrTxt02 += "" + cDelimit									   //33 - ALIQ_COFINS
		EndIf
		
		If aTrib[25] > 0
			cStrTxt02 += Val2Str(  aTrib[25], 16, 3 ) + cDelimit	   		  //34 - QUANT_BC_COFINS
		Else
			cStrTxt02 += "" + cDelimit									   //34 - QUANT_BC_COFINS
		EndIf
		
		If aTrib[26] > 0
			cStrTxt02 += Val2Str(  aTrib[26], 16, 4 ) + cDelimit		  //35 - ALIQ_COFINS
		Else
			cStrTxt02 += "" + cDelimit									   //35 - ALIQ_COFINS
		EndIf
		
		cStrTxt02 += Val2Str(  aTrib[7], 16, 2 ) + cDelimit			  //36 - VL_COFINS
		
		xGerBlc0( "0500",  Alltrim( aItensNF[1][12] ), cFilSelBc, aWizardBc, cTabSpd)		
		cStrTxt02 += Alltrim( aItensNF[1][12] ) + cDelimit 	 									  //37 - COD_CTA  
		
		cStrTxt02 += CRLF			 
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C170",aTotRegC)		
	EndIf		
									     	
	//Verifica se o Modelo da NF eh 01|55
	If aNf[1][5] $ "01|55" .And. lGerC170												
													
		//Operacao de Entrada
		If aNF[1][3] == "0"   														
			RegC171( @cStrTxt02, cChvPai )  
		EndIf                                                                   
										
		//Operacao de Saidas 				
		If aNF[1][3] == "1"   																			
			
			//Verifica se o modelo da NF eh 01
			If aNf[1][5] == "01"																				
				RegC172( @cStrTxt02, aTrib )  
			EndIf				                    		
		EndIf                                                                   
		
		RegC173( @cStrTxt02, cChvPai )  
            
		//Operacao de Saidas 					
		If aNF[1][3] == "1"  
		 																			
			//Verifica se o modelo da NF eh 01
			If aNf[1][5] == "01"																				
				RegC174( @cStrTxt02, cChvPai )  
			EndIf
		EndIf

		RegC175( @cStrTxt02, cChvPai )  
		
		//Operacao de Saidas 					
		If aNF[1][3] == "1" 				
			RegC176( @cStrTxt02, cChvPai )  
		EndIf	
																	
	EndIf

	//Operacao de Saida  
	If aNF[1][3] == "1" .And. lGerC170		
								
		RegC177( @cStrTxt02, aItensNf )  
								
		RegC178( @cStrTxt02, aItensNf )  
								
		//Verifica se o Modelo da NF eh 01
		If aNf[1][5] == "01"     											
			RegC179( @cStrTxt02, aItensNf )  
		EndIf
	EndIf															
	
EndIf
										
Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC171

Realiza a Emissao do Registro C171 - Armazenamento de Combustiveis( Codigo 01 e 55 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			cChvNF      -> Chave do Registro C170
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 16/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC171( cStrTxt02, cChvNF )  

Local cDelimit  := "|"

Local cAliasC36 := "C36"

DbSelectArea(cAliasC36)
(cAliasC36)->(DbSetOrder(1))
If (cAliasC36)->(MsSeek( xFilial("C36") + cChvNF ) )
	While (cAliasC36)->(!Eof()) .And. cChvNF == (cAliasC36)->( C36_CHVNF + C36_NUMITE )
		
		cStrTxt02 += cDelimit		
		cStrTxt02 += "C171" + cDelimit	        													  		//01 - REG
		cStrTxt02 += Alltrim( (cAliasC36)->C36_NUMTAN ) + cDelimit									   		//02 - NUM_TANQUE
		cStrTxt02 += Val2Str(  (cAliasC36)->C36_QUANT, 16, 3 ) + cDelimit	//03 - QTDE				
		cStrTxt02 += CRLF	          
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C171",aTotRegC)			
					
		(cAliasC36)->(DbSkip())
	EndDo
EndIf

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC172

Realiza a Emissao do Registro C172 - Operacoes com ISSQN ( Codigo 01 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			aTrib       -> Valores de Impostos do Item
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 16/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC172( cStrTxt02, aTrib )  

Local cDelimit := "|"

//Verifico se Existem valores de ISS para geracao do Registro C172
If ( aTrib[28] + aTrib[29] + aTrib[30] ) > 0  
	                              
	cStrTxt02 += cDelimit	
	cStrTxt02 += "C172" + cDelimit     												    //01 - REG	     
	cStrTxt02 += Val2Str(  aTrib[28], 16, 2 ) + cDelimit	//02 - VL_BC_ISSQN     
	cStrTxt02 += Val2Str(  aTrib[29], 16, 2 ) + cDelimit	//03 - ALIQ_ISSQN     
	cStrTxt02 += Val2Str(  aTrib[30], 16, 2 ) + cDelimit  //04 - VL_ISSQN  
	cStrTxt02 += CRLF	
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C172",aTotRegC)				
		
EndIf

Return ( Nil )                              

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC173

Realiza a Emissao do Registro C173 - Operacoes com Medicamentos ( Codigo 01 e 55 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			cChvNF      -> Chave do Registro C170
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC173( cStrTxt02, cChvNF )  

Local cDelimit := "|"

Local cAliasC31 := "C31"
 
DbSelectArea(cAliasC31)
(cAliasC31)->(DbSetOrder(1))
If (cAliasC31)->(MsSeek( xFilial("C31") + cChvNF ) )
	While (cAliasC31)->(!Eof()) .And. cChvNF == (cAliasC31)->( C31_CHVNF + C31_NUMITE ) 
		
		cStrTxt02 += cDelimit
		cStrTxt02 += "C173" + cDelimit     				  		  										  //01 - REG	     
		cStrTxt02 += Alltrim( (cAliasC31)->C31_LOTE    ) + cDelimit 									  //02 - LOTE_MED
		cStrTxt02 += Val2Str(  (cAliasC31)->C31_QUANT, 16, 3 ) + cDelimit //03 - QTD_ITEM
		cStrTxt02 += Alltrim( StrTran( DToC( (cAliasC31)->C31_DTFAB ), "/", "" )) + cDelimit 	      //04 - DT_FAB
		cStrTxt02 += Alltrim( StrTran( DToC( (cAliasC31)->C31_DTVAL ), "/", "" )) + cDelimit 		  //05 - DT_VAL
		cStrTxt02 += Alltrim( (cAliasC31)->C31_INDMED  ) + cDelimit 									  //06 - IND_MED
  		cStrTxt02 += Alltrim( (cAliasC31)->C31_TPPROD  ) + cDelimit 									  //07 - TP_PROD
		cStrTxt02 += Val2Str(  (cAliasC31)->C31_VLTBMX, 16, 2 ) + cDelimit //08 - VL_TAB_MAX
		cStrTxt02 += CRLF	 
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C173",aTotRegC)						
		
		(cAliasC31)->(DbSkip())	
	EndDo

EndIf
	
Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC174

Realiza a Emissao do Registro C174 -Operacoes Com Armas de Fogo ( Codigo 01 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			cChvNF      -> Chave do Registro C170
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC174( cStrTxt02, cChvNF )  

Local cDelimit  := "|"

Local cAliasC33 := "C33"

DbSelectArea(cAliasC33)
(cAliasC33)->(DbSetOrder(1))
If (cAliasC33)->(MsSeek( xFilial("C33") + cChvNF ) )
	While (cAliasC33)->(!Eof()) .And. cChvNF == (cAliasC33)->( C33_CHVNF + C33_NUMITE ) 
	   
		cStrTxt02 += cDelimit		    		
		cStrTxt02 += "C174" + cDelimit     	 							//01 - REG	     
   		cStrTxt02 += Alltrim( (cAliasC33)->C33_INDARM ) + cDelimit 	//02 - IND_ARM		
		cStrTxt02 += Alltrim( (cAliasC33)->C33_NUMARM ) + cDelimit 	//03 - NUM_ARM				
		cStrTxt02 += Alltrim( StrTran( (cAliasC33)->C33_DESCRI, CRLF, "" ) ) + cDelimit 	//04 - DESCR_COMPL				
		cStrTxt02 += CRLF    
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C174",aTotRegC)					
																				
		(cAliasC33)->(DbSkip())	
	EndDo

EndIf
	
Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC175

Realiza a Emissao do Registro C175 - Operacoes com Veiculos Novos ( Codigo 01 e 55 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			cChvNF      -> Chave do Registro C170
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC175( cStrTxt02, cChvNF )  

Local cUf       := ""
Local cDelimit  := "|"

Local cAliasC34 := "C34"                        
Local cAliasC09 := "C09"

DbSelectArea( cAliasC09 )
(cAliasC09)->(DbSetOrder(3))

DbSelectArea(cAliasC34)
(cAliasC34)->(DbSetOrder(1))
If (cAliasC34)->(MsSeek( xFilial("C34") + cChvNF ) )
	While (cAliasC34)->(!Eof()) .And. cChvNF == (cAliasC34)->( C34_CHVNF + C34_NUMITE ) 
			
		If (cAliasC09)->(MsSeek( xFilial("C09") + (cAliasC34)->C34_UF ) )
			cUf := (cAliasC09)->C09_UF
		Else
			cUf := " "	
		EndIf
		
		cStrTxt02 += cDelimit	    		
		cStrTxt02 += "C175" + cDelimit 	 		  							//01 - REG	     
		cStrTxt02 += Alltrim( (cAliasC34)->C34_INDVEI ) + cDelimit 		//02 - IND_VEIC_OPER 			
		cStrTxt02 += Alltrim( (cAliasC34)->C34_CNPJ   ) + cDelimit 		//03 - CNPJ 			
		cStrTxt02 += Alltrim( cUf ) + cDelimit  						   	//04 - UF 			
		cStrTxt02 += Alltrim ( (cAliasC34)->C34_CHASSI  ) + cDelimit 	 	//05 - CHASSI_VEIC		
		cStrTxt02 += CRLF		
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C175",aTotRegC)					
																				
		(cAliasC34)->(DbSkip())	
	EndDo

EndIf
	
Return ( Nil )         

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC176

Realiza a Emissao do Registro C176 - Ressarcimento de ICMS em Operacoes com 
Substituicao Tributaria ( Codigo 01 e 55 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			cChvNF      -> Chave do Registro C170
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC176( cStrTxt02, cChvNF )  

Local cDelimit  := "|"

Local cAliasC37 := "C37"                        
Local cAliasC01 := "C01"
Local cAliasC1H := "C1H"

DbSelectArea( cAliasC01 )
(cAliasC01)->(DbSetOrder(3))

DbSelectArea( cAliasC1H )
(cAliasC1H)->(DbSetOrder(5))

DbSelectArea(cAliasC37)
(cAliasC37)->(DbSetOrder(1))
If (cAliasC37)->(MsSeek( xFilial("C37") + cChvNF ) )
	While (cAliasC37)->(!Eof()) .And. cChvNF == (cAliasC37)->( C37_CHVNF + C37_NUMITE ) 			
		If (cAliasC01)->(MsSeek( xFilial("C01") + (cAliasC37)->C37_CODMOD ) )
			If (cAliasC1H)->(MsSeek( xFilial("C1H") + (cAliasC37)->C37_CODPAR ) )
			    
				cStrTxt02 += cDelimit
				cStrTxt02 += "C176" + cDelimit  	 				   				   					//01 - REG	     
				cStrTxt02 += Alltrim( (cAliasC01)->C01_CODIGO  ) + cDelimit    							//02 - COD_MOD_ULT_E
				cStrTxt02 += Alltrim( (cAliasC37)->C37_NUMDOC  ) + cDelimit    				   			//03 - NUM_DOC_UTL_E
				cStrTxt02 += Alltrim( (cAliasC37)->C37_SERIE   ) + cDelimit    							//04 - SER_UTL_E
				cStrTxt02 += Alltrim( StrTran( DToC( (cAliasC37)->C37_DTDOC ), "/", "" ) ) + cDelimit	//05 - DT_UTL_E
				
				//Geração do Registro 0150/0175
				xGerBlc0( "0150",  (cAliasC1H)->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd )						
				cStrTxt02 += Alltrim( (cAliasC1H)->( C1H_CODPAR )  ) + cDelimit    						//06 - COD_PART_ULT_E
				
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_QUANT, 16, 3 ) + cDelimit    					//07 - QUANT_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLITEM, 16, 3  ) + cDelimit    					//08 - VL_UNIT_UTL_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLBCST, 16, 3  ) + cDelimit    					//09 - VL_UNIT_BC_ST
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_CHVULT  ) + cDelimit    						//10 - CHAVE_NFE_ULT_E																																
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_NUMULT  ) + cDelimit    						//11 - NUM_ITEM_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLBICM, 16, 2  ) + cDelimit    					//12 - VL_UNIT_BC_ICMS_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_ALIQIC, 16, 2  ) + cDelimit    					//13 - ALIQ_ICMS_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLLIMI, 16, 2  ) + cDelimit    					//14 - VL_UNIT_LIMITE_BC_ICMS_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLUICM, 16, 3  ) + cDelimit    					//15 - VL_UNIT_ICMS_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_ALIQST, 16, 2  ) + cDelimit    					//16 - ALIQ_ST_ULT_E
				cStrTxt02 += Val2Str(  (cAliasC37)->C37_VLURES, 16, 3  ) + cDelimit    					//17 - VL_UNIT_RES
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_CODRES ) + cDelimit    							//18 - COD_RESP_RET
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_CODMOT ) + cDelimit    							//19 - COD_MOT_RES
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_CHVRET ) + cDelimit    							//20 - CHAVE_NFE_RET
				cStrTxt02 += Alltrim(  Posicione("C1H",5,xFilial("C1H")+(cAliasC37)->C37_CODPRE,"C1H_CODPAR") ) + cDelimit  //21 - COD_PART_NFE_RET
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_SERNFE ) + cDelimit    							//22 - SER_NFE_RET 
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_NUMNFE ) + cDelimit    							//23 - NUM_NFE_RET
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_NITEMR ) + cDelimit    							//24 - ITEM_NFE_RET
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_CODMDA ) + cDelimit    							//25 - COD_DA
				cStrTxt02 += Alltrim(  (cAliasC37)->C37_NUMDA  ) + cDelimit    							//26 - NUM_DA								
				cStrTxt02 += CRLF	
				
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("C176",aTotRegC)											
																										
            EndIf
    	EndIf	
		(cAliasC37)->(DbSkip())	
	EndDo
EndIf
	
Return ( Nil )       

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC177

Realiza a Emissao do Registro C177 - Operacoes com Produtos Sujeitos a Selo de 
controle de IPI

@Param		cStrTxt02   -> String para gravacao do Registro  
			aItensNf    -> Dados do Item da NF
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC177( cStrTxt02, aItensNf )  

Local cDelimit := "|"

If !Empty( aItensNF[1][13] )		
	cStrTxt02 += cDelimit
	cStrTxt02 +=  "C177" + cDelimit   						//01 - REG	     
	cStrTxt02 +=  Alltrim( aItensNF[1][13] ) + cDelimit  	//02 - COD_SELO_IPI
	cStrTxt02 +=  Alltrim( Val2Str(aItensNF[1][14], 6 , 0) ) + cDelimit    //03 - QT_SELO_IPI		
	cStrTxt02 += CRLF	 
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C177",aTotRegC)			
									
EndIf

Return ( Nil )                                                    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC178

Realiza a Emissao do Registro C178 - Operacoes com produtos sujeitos a tributacao
de IPI por unidade ou Quantidade de Produto

@Param		cStrTxt02   -> String para gravacao do Registro  
			aItensNf    -> Dados do Item da NF
						
@Return ( Nil )

@author Rodrigo Aguilar
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC178( cStrTxt02, aItensNf )  
                     
Local cDelimit := "|"

If !Empty( aItensNF[1][17] )	
	cStrTxt02 += cDelimit	
	cStrTxt02 += "C178" + cDelimit   	  														//01 - REG	     
	cStrTxt02 += Alltrim( aItensNF[1][17] ) + cDelimit									    	//02 - CL_ENQ	
	cStrTxt02 += Val2Str(  aItensNF[1][16], 16, 2 ) + cDelimit  	//03 - VL_UNID
	cStrTxt02 += Val2Str(  aItensNF[1][15], 16, 3 ) + cDelimit	//04 - QUANT_PAD
	cStrTxt02 += CRLF			
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C178",aTotRegC)			
					
EndIf

Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC179

Realiza a Emissao do Registro C179 - Informacoes Complementares ST ( Codigo 01 )

@Param		cStrTxt02   -> String para gravacao do Registro  
			aItensNf    -> Dados do Item da NF
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 18/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC179( cStrTxt02, aItensNf )  

Local cDelimit := "|"

If ( aItensNF[1][18] + aItensNF[1][19] ) > 0
	
	cStrTxt02 += cDelimit
	cStrTxt02 += "C179" + cDelimit  															//01 - REG	     
	cStrTxt02 += Val2Str(  aItensNF[1][18], 16, 2 ) + cDelimit   //02 - BC_ST_ORIG_DEST
	cStrTxt02 += Val2Str(  aItensNF[1][19], 16, 2 ) + cDelimit   //03 - ICMS_ST_REP
	cStrTxt02 += Val2Str(  aItensNF[1][20], 16, 2 ) + cDelimit   //04 - ICMS_ST_COMPL
	cStrTxt02 += Val2Str(  aItensNF[1][21], 16, 2 ) + cDelimit   //05 - BC_RET
	cStrTxt02 += Val2Str(  aItensNF[1][22], 16, 2 ) + cDelimit   //06 - ICMS_RET
	cStrTxt02 += CRLF		 
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C179",aTotRegC)					
																				
EndIf  
	
Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC195

Realiza a Emissao do Registro C195 - Observacoes do Lancamento Fiscal (Codigo 01, 1B e 55 )

@Param		cStrTxt02   -> String para gravacao do Registro 
			cChvNF      -> Chave da NF que sera gerada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 18/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC195( cStrTxt03, cChvNF )  

Local cDelimit  := "|"
          
Local cAliasC2C := "C2C"                                         
Local cAliasC3R := "C3R"                                         

Local cChvC195  := ""

DbSelectArea(cAliasC2C)
(cAliasC2C)->(DbSetOrder(1))

DbSelectArea(cAliasC3R)
(cAliasC3R)->(DbSetOrder(3))

If (cAliasC2C)->(MsSeek( xFilial("C2C") + cChvNF ) )                     
	While (cAliasC2C)->(!Eof()) .And. cChvNF == (cAliasC2C)->C2C_CHVNF 
		If (cAliasC3R)->(MsSeek( xFilial("C3R") + 	(cAliasC2C)->C2C_CODOBS ) )
		    
			cStrTxt03 += cDelimit				
			cStrTxt03 += "C195" + cDelimit 	 						 				       //01 - REG
			
			xGerBlc0( "0460",  Alltrim( (cAliasC3R)->( C3R_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd )			
			cStrTxt03 += Alltrim( (cAliasC3R)->( C3R_CODIGO ) ) + cDelimit  //02 - COD_OBS
			
			cStrTxt03 += Alltrim( StrTran( (cAliasC2C)->C2C_DESCRI, CRLF, "" ) ) + cDelimit 				   //03 - TXT_COMPL													     
			cStrTxt03 += CRLF	
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("C195",aTotRegC)						

			cChvC195 := cChvNF + (cAliasC2C)->C2C_CODOBS
			
			RegC197( @cStrTxt03, cChvC195 )  
		    
	    EndIf
		(cAliasC2C)->(DbSkip())                                  
	EndDo
EndIf				    		
										
Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC197

Realiza a Emissao do Registro C197 - Outras Obrigacoes Tributarias, Ajustes e
informacoes de valores provenientes de Documento Fiscal

@Param		cStrTxt02   -> String para gravacao do Registro 
			cChvC195    -> Chave do Registro C195
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 18/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC197( cStrTxt03, cChvC195 )  

Local cDelimit  := "|"

Local cAliasC2D := "C2D"
Local cAliasC0J := "C0J"
Local cAliasC1L := "C1L"

DbSelectArea(cAliasC0J)
(cAliasC0J)->(DbSetOrder(3))

DbSelectArea(cAliasC1L)
(cAliasC1L)->(DbSetOrder(3))
      
DbSelectArea(cAliasC2D)
(cAliasC2D)->(DbSetOrder(1))
If (cAliasC2D)->(MsSeek( xFilial("C2D") + cChvC195 ) )
	While (cAliasC2D)->(!Eof()) .And. cChvC195 == (cAliasC2D)->(C2D_CHVNF + C2D_CODOBS)
		If (cAliasC0J)->(MsSeek( xFilial("C0J") + 	(cAliasC2D)->C2D_CODAJ ) )
			
			cStrTxt03 += cDelimit				
			cStrTxt03 += "C197" + cDelimit																			//01 - REG
			cStrTxt03 += Alltrim( (cAliasC0J)->C0J_CODIGO ) + cDelimit										  		//02 - COD_AJ		
			cStrTxt03 += Alltrim( (cAliasC2D)->C2D_DESCRI ) + cDelimit								   		  		//03 - DESCR_COMPL_AJ					
			
			If (cAliasC1L)->(MsSeek( xFilial("C1L") + (cAliasC2D)->C2D_CODITE ) )
				
				//Geração do Registro 0200
				xGerBlc0( "0200",  Alltrim( (cAliasC1L)->(C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd )				
				cStrTxt03 += Alltrim( (cAliasC1L)->(C1L_CODIGO ) ) + cDelimit					   		//04 - COD_ITEM
						                   
			Else
				cStrTxt03 += "" + cDelimit  																		//04 - COD_ITEM		                   
            EndIf                                                          
            
			cStrTxt03 += Val2Str(  (cAliasC2D)->C2D_BSICM,16, 2 ) + cDelimit		//05 - VL_BC_ICMS		
			cStrTxt03 += Val2Str(  (cAliasC2D)->C2D_ALQICM, 16, 2 ) + cDelimit		//06 - ALIQ_ICMS
			cStrTxt03 += Val2Str(  (cAliasC2D)->C2D_VLICM,16, 2 ) + cDelimit		//07 - VL_ICMS		
			cStrTxt03 += Val2Str(  (cAliasC2D)->C2D_VLOUTR, 16, 2 ) + cDelimit		//08 - VL_OUTROS																			
			cStrTxt03 += CRLF	     
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("C197",aTotRegC)						
			
		EndIf			
		(cAliasC2D)->(DbSkip())
	EndDo
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC300

Realiza a Emissao do Registro C300 - Resumo Diario Das Notas Fiscais de Venda
a Consumidor ( Codigo 02 ) e Filhos

@Param		cStrTxt     -> String para gravacao do Registro 
			aTotRegC300 -> Array Com Dados da Registro C300
			aItensNf    -> Array com Itens da NF
			aTrib       -> Informacoes de Tributos da NF                                              
			aRegC320    -> Array com os valores garavados para geracao do Registro C320
			aRegC321    -> Array com os valores garavados para geracao do Registro C321
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 21/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC300( cStrTxt, aTotRegC300, aItensNf, aTrib, aRegC320, aRegC321, cStrTxt02 )		   

Local cDelimit  := "|"
				    		
cStrTxt += cDelimit				
cStrTxt += "C300" + cDelimit 				   												//01 - REG  	 
cStrTxt += "02" + cDelimit  		    	   												//02 - COD_MOD  	  	
cStrTxt += Alltrim( aTotRegC300[1][1]  ) + cDelimit     									//03 - SER  	    
cStrTxt += Alltrim( aTotRegC300[1][2]  ) + cDelimit     									//04 - SUB  	    
cStrTxt += Alltrim( aTotRegC300[1][12] ) + cDelimit     									//05 - NUM_DOC_INI  	
cStrTxt += Alltrim( aTotRegC300[1][13] ) + cDelimit     									//06 - NUM_DOC_FIN  	    
cStrTxt += Alltrim( aTotRegC300[1][3]  ) + cDelimit	  								  	//07 - DT_DOC  	
cStrTxt += Val2Str(  aTotRegC300[1][4], 16, 2 ) + cDelimit   //08 - VL_DOC  	
cStrTxt += Val2Str(  aTotRegC300[1][5], 16, 2 ) + cDelimit   //09 - VL_PIS
cStrTxt += Val2Str(  aTotRegC300[1][6], 16, 2 ) + cDelimit   //10 - VL_COFINS

xGerBlc0( "0500",  Alltrim( aTotRegC300[1][7] ), cFilSelBc, aWizardBc, cTabSpd)
cStrTxt += Alltrim( aTotRegC300[1][7] ) + cDelimit									    	//11 - COD_CTA
  
cStrTxt += CRLF               
cStrTxt += cStrTxt02    

//Conta os registros para totalizar no bloco 9
TaFContBlc("C300",aTotRegC)			
	
//Geracao do Registro C320
RegC320( @cStrTxt, aRegC320, aRegC321 )
					
Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC310

Realiza a Emissao do Registro C310 - Documentos Cancelados de Notas Fiscais
de Venda a Consumidor ( Codigo 02 )

@Param		cStrTxt02   -> String para gravacao do Registro 
			aTotRegC300 -> Array Com Totais do Registro C300
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC310( cStrTxt02, aTotRegC300 )		   			    

Local cDelimit := "|"

cStrTxt02 += cDelimit				
cStrTxt02 +=  "C310" + cDelimit 		 				//01 - REG  	 
cStrTxt02 += Alltrim( aTotRegC300[1][10] ) + cDelimit  //02 - NUM_DOC_CANC
cStrTxt02 += CRLF	         

//Conta os registros para totalizar no bloco 9
TaFContBlc("C310",aTotRegC)			
                   									
Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC320

Realiza a Emissao do Registro C320 - Registro Analitico do Resumo Diario
das Notas Fiscais de Venda a Consumidor ( Codigo 02 ) e seus respectivos
filhos

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC320    -> Dados com informacoes do Registro C320
			aRegC321    -> Dados com informacoes do Registro C321
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------                                          
Static Function RegC320( cStrTxt, aRegC320, aRegC321 )
      
Local cDelimit := "|"         
Local nly := 1                

For nly := 1 To Len( aRegC320 )

	cStrTxt += cDelimit 
	cStrTxt += aRegC320[nlY][1] + cDelimit 													//01 - REG
	cStrTxt += Alltrim( aRegC320[nlY][2] ) + cDelimit 										//02 - CST_ICMS
	cStrTxt += Alltrim( aRegC320[nlY][3] ) + cDelimit 										//03 - CFOP
	cStrTxt += Val2Str(  aRegC320[nlY][4], 16, 2 ) + cDelimit //04 - ALIQ_ICMS
	cStrTxt += Val2Str(  aRegC320[nlY][5], 16, 2 ) + cDelimit //05 - VL_OPR
	cStrTxt += Val2Str(  aRegC320[nlY][6], 16, 2 ) + cDelimit //06 - VL_BC_ICMS
	cStrTxt += Val2Str(  aRegC320[nlY][7], 16, 2 ) + cDelimit //07 - VL_ICMS
	cStrTxt += Val2Str(  aRegC320[nlY][8], 16, 2 ) + cDelimit //08 - VL_RED_BC

	xGerBlc0( "0460",  Alltrim( StrTran( aRegC320[nlY][9], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim( StrTran( aRegC320[nlY][9], CRLF, "" ) )+ cDelimit 										//09 - COD_OBS
	
	cStrTxt += CRLF      
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C320",aTotRegC)				
	
	//Geracao do Registro C321
	RegC321( @cStrTxt, aRegC321, nly )		               

Next
								
Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC321

Itens do Resumo Diario dos Documentos ( Codigo 02 )

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC321    -> Dados com informacoes do Registro C321
			nPosC320    -> Relacao com o Registro Pai C320
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC321( cStrTxt, aRegC321, nPosC320 )

Local cDelimit := "|"

Local nlz  := 1

For nlz := 1 To Len( aRegC321 )    
	If aRegC321[nlz][1] == nPosC320
		cStrTxt += cDelimit 
		cStrTxt += aRegC321[nlz][2] + cDelimit 													  			  //01 - REG
		
		//Geração do Registro 0200
		xGerBlc0( "0200",  Alltrim( aRegC321[nlz][3]  ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aRegC321[nlz][5]  ) )		
		cStrTxt += Alltrim( aRegC321[nlz][3]  ) + cDelimit	 										  			  //02 - COD_ITEM
		
		cStrTxt += Val2Str(  aRegC321[nlz][4], 16, 3 ) + cDelimit	  			  //03 - QTD

		//Geração do Registro 0190
		xGerBlc0( "0190",  Alltrim( aRegC321[nlz][5]  ), cFilSelBc, aWizardBc, cTabSpd )		
		cStrTxt += Alltrim( aRegC321[nlz][5]  ) + cDelimit	  										  			  //04 - UNID
	
		cStrTxt += Val2Str(  aRegC321[nlz][6], 16, 2 ) + cDelimit	  			  //05 - VL_ITEM
		cStrTxt += Val2Str(  aRegC321[nlz][7], 16, 2 ) + cDelimit	  			  //06 - VL_DESC
		cStrTxt += Val2Str(  aRegC321[nlz][8], 16, 2 ) + cDelimit	  			  //07 - VL_BC_ICMS
		cStrTxt += Val2Str(  aRegC321[nlz][9], 16, 2 ) + cDelimit	  			  //08 - VL_ICMS
		cStrTxt += Val2Str(  aRegC321[nlz][10],16, 2 ) + cDelimit 				  //09 - VL_PIS	
		cStrTxt += Val2Str(  aRegC321[nlz][11],16, 2 ) + cDelimit 				  //10 - VL_COFINS	
	 	cStrTxt += CRLF  
	 	
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C321",aTotRegC)			
				 	
    EndIf    									
Next				
								
Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC350

Nota Fiscal de Venda a Consumidor ( Codigo 02 )

@Param		cStrTxt03   -> String para gravacao do Registro 
			cStrTxt04   -> String para gravacao do Registro 
			aNF 	    -> Dados com informacoes da Nota Fiscal
			aRegC390    -> Dados com informacoes do Registro C390
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 21/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC350( cStrTxt03, cStrTxt04, aNF, aRegC390 ) 

Local cDelimit := "|"

cStrTxt03 += cDelimit				
cStrTxt03 += "C350" + cDelimit 				   											//01 - REG  	 
cStrTxt03 += Alltrim( aNf[1][3] ) + cDelimit			    							//02 - SER
cStrTxt03 += Alltrim( aNf[1][4] ) + cDelimit			    							//03 - SUB_SER
cStrTxt03 += Alltrim( aNf[1][5] ) + cDelimit			    							//04 - NUM_DOC
cStrTxt03 += Alltrim( aNf[1][7] ) + cDelimit			    //05 - DT_DOC

If !Empty( aNf[1][13] )
	cStrTxt03 += Alltrim( aNf[1][13] ) + cDelimit	    								//06 - CNPJ_CPF
Else
	cStrTxt03 += Alltrim( aNf[1][14] ) + cDelimit	    								//06 - CNPJ_CPF
EndIf                                     

cStrTxt03 += Val2Str(  aNf[1][15], 16, 2) + cDelimit		//07 - VL_MERC
cStrTxt03 += Val2Str(  aNf[1][8] ,16, 2) + cDelimit		//08 - VL_DOC
cStrTxt03 += Val2Str(  aNf[1][16], 16, 2) + cDelimit 		//09 - VL_DESC
cStrTxt03 += Val2Str(  aNF[1][17], 16, 2) + cDelimit		//10 - VL_PIS
cStrTxt03 += Val2Str(  aNF[1][18], 16, 2)	 + cDelimit		//11 - VL_COFINS

xGerBlc0( "0500",  Alltrim( aNF[1][11] ), cFilSelBc, aWizardBc, cTabSpd)
cStrTxt03 += Alltrim( aNF[1][11] ) + cDelimit											//12 - COD_CTA
 
cStrTxt03 += CRLF          

//Conta os registros para totalizar no bloco 9
TaFContBlc("C350",aTotRegC)			

//Concateno as Informacoes dos Registros C350 e C370
cStrTxt03 := ( cStrTxt03 + cStrTxt04 )

cStrTxt04 := ""
	 	                   
//Geracao do Registro C390
RegC390( @cStrTxt03, aRegC390 )
		
Return ( Nil )                        

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC370

Itens do Documento ( Codigo 02 )

@Param		cStrTxt04   -> String para gravacao do Registro 
			aItensNf    -> Array com os dados do Item da NF
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 24/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC370( cStrTxt04, aItensNf )		   

Local cDelimit := "|"				    		                                                                       				    		

cStrTxt04 += cDelimit				
cStrTxt04 +=  "C370" + cDelimit 														  //01 - REG  	  
cStrTxt04 += Alltrim( aItensNF[1][1] ) + cDelimit 									      //02 - NUM_ITEM		  	  

//Geração do Registro 0200
xGerBlc0( "0200",  Alltrim( aItensNF[1][4] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aItensNF[1][5] ) )
cStrTxt04 += Alltrim( aItensNF[1][4] ) + cDelimit	 									  //03 - COD_ITEM  

cStrTxt04 += Val2Str(  aItensNF[1][6], 16, 3 ) + cDelimit  //04 - QTD  

//Geração do Registro 0190
xGerBlc0( "0190",  Alltrim( aItensNF[1][5] ), cFilSelBc, aWizardBc, cTabSpd )
cStrTxt04 += Alltrim( aItensNF[1][5] ) + cDelimit	  									  //05 - UNID  

cStrTxt04 += Val2Str(  aItensNF[1][3], 16, 2 ) + cDelimit	  //06 - VL_ITEM  
cStrTxt04 += Val2Str(  aItensNF[1][8], 16, 2 ) + cDelimit	  //07 - VL_DESC
cStrTxt04 += CRLF        

//Conta os registros para totalizar no bloco 9
TaFContBlc("C370",aTotRegC)			
                   		
Return ( Nil )  

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC390

Registro Analitico das Notas Fiscais de Venda a Consumidor ( Codigo 02 )

@Param		cStrTxt03   -> String para gravacao do Registro 
			aRegC390    -> Dados com informacoes do Registro C390
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 24/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC390( cStrTxt03, aRegC390 )

Local cDelimit := "|"

Local nlY := 1

For nlY := 1 To Len( aRegC390 )
	cStrTxt03 += cDelimit 
	cStrTxt03 += aRegC390[nlY][1] + cDelimit 													  //01 - REG
	cStrTxt03 += Alltrim( aRegC390[nlY][2]  ) + cDelimit	 									  //02 - CST_ICMS
	cStrTxt03 += Alltrim( aRegC390[nlY][3]  ) + cDelimit	  									  //03 - CFOP
	cStrTxt03 += Val2Str( aRegC390[nlY][4], 16, 2 ) + cDelimit	  //04 - ALIQ_ICMS
	cStrTxt03 += Val2Str( aRegC390[nlY][5], 16, 2 ) + cDelimit	  //05 - VL_OPR
	cStrTxt03 += Val2Str( aRegC390[nlY][6], 16, 2 ) + cDelimit	  //06 - VL_BC_ICMS
	cStrTxt03 += Val2Str( aRegC390[nlY][7], 16, 2 ) + cDelimit	  //07 - VL_ICMS
	cStrTxt03 += Val2Str( aRegC390[nlY][8], 16, 2 ) + cDelimit	  //08 - VL_RED_BC
	
	xGerBlc0( "0460",  Alltrim( StrTran( aRegC390[nlY][9], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt03 += Alltrim( StrTran( aRegC390[nlY][9], CRLF, "" ) ) + cDelimit 								    	  //09 - COD_OBS
	
 	cStrTxt03 += CRLF        
 	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C390",aTotRegC)				 	
	
Next				
								
Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC400

Equipamento ECF ( Codigo 02 / 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			cAliasC401  -> Retorno da Query para Geracao do Registro C400
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 31/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC400( cStrTxt, cAliasC401 ) 

Local cDelimit := "|"
Local cModelo  := ""

C6I->(DbSetOrder(1))
C01->(DbSetOrder(3))

/*----------------------------------------------------------------------
Conforme Alinhado com o Gustavo, um ECF pode somente ter um modelo
de Nota Fiscal ( 02 ou 2D ), sendo assim, busco o modelo da primeira 
nota fiscal e assumo para todas as demais
-----------------------------------------------------------------------*/
If C6I->(MsSeek( xFilial("C6I") + (cAliasC401)->( 	C6F_ID + C6G_DTMOV ) ))
	If C01->(MsSeek(xFilial("C01") + C6I->C6I_CMOD ) )
		cModelo := C01->C01_CODIGO
	EndIf
EndIf

cStrTxt += cDelimit
cStrTxt += "C400" + cDelimit      							   		//01 - REG
cStrTxt += Alltrim( cModelo ) + cDelimit							//02 - COD_MOD
cStrTxt += Alltrim( (cAliasC401)->C0W_ECFMOD ) + cDelimit 			//03 - ECF_MOD
cStrTxt += Alltrim( (cAliasC401)->C0W_ECFFAB ) + cDelimit 		    //04 - ECF_FAB
cStrTxt += Alltrim( (cAliasC401)->C0W_ECFCX  ) + cDelimit  	    //05 - ECF_CX
cStrTxt += CRLF                

//Conta os registros para totalizar no bloco 9
TaFContBlc("C400",aTotRegC)			
 	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC405

Reducao Z ( Codigo 02 e 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			cAliasC401  -> Retorno da Query para Geracao do Registro C405
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 31/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC405( cStrTxt, cAliasC401 ) 

Local cDtMov   := ""
Local cDelimit := "|"

If !Empty( (cAliasC401)->C6G_DTMOV )     
	cDtMov  := Right( (cAliasC401)->C6G_DTMOV, 2 ) + SubStr( (cAliasC401)->C6G_DTMOV, 5, 2 ) + Left( (cAliasC401)->C6G_DTMOV, 4 )
EndIf
	
cStrTxt += cDelimit            
cStrTxt += "C405" + cDelimit  																	  //01 - REG
cStrTxt += cDtMov + cDelimit                                               						  //02 - DT_DOC
cStrTxt += Alltrim( (cAliasC401)->C6G_PCREOP ) + cDelimit                 						  //03 - CRO
cStrTxt += Alltrim( (cAliasC401)->C6G_PCREDZ ) + cDelimit                 						  //04 - CRZ
cStrTxt += Alltrim( (cAliasC401)->C6G_NRCOPF ) + cDelimit                 						  //05 - NUM_COO_FIN
cStrTxt += Val2Str(  (cAliasC401)->C6G_VLGRTF, 16, 2 ) + cDelimit  //06 - GT_FIN
cStrTxt += Val2Str(  (cAliasC401)->C6G_VLBRU,16, 2 ) + cDelimit  //07 - VL_BRT
cStrTxt += CRLF           

//Conta os registros para totalizar no bloco 9
TaFContBlc("C405",aTotRegC)			
 	
Return ( Nil )            

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC410

Pis e Cofins Totalizados no Dia ( Codigo 02 / 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			cAliasC402  -> Retorno da Query para Geracao do Registro C410
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 31/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC410( cStrTxt, cAliasC402 ) 

Local cDelimit := "|"

If (cAliasC402)->( PIS + COFINS ) > 0
	cStrTxt += cDelimit            
	cStrTxt += "C410" + cDelimit  		  										 				   //01 - REG
	cStrTxt += Val2Str(  (cAliasC402)->PIS, 16, 2 ) + cDelimit      //02 - VL_PIS
	cStrTxt += Val2Str(  (cAliasC402)->COFINS, 16, 2 ) + cDelimit   //03 - VL_COFINS
	cStrTxt += CRLF      
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C410",aTotRegC)			
				
EndIf
 	
Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC420

Registro dos Totalizadores Parciais da Reducao Z ( Cod 02/ 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			cAliasC402  -> Retorno da Query para Geracao do Registro C420
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC420( cStrTxt, cAliasC402 ) 

Local cDelimit := "|"

cStrTxt += cDelimit            
cStrTxt += "C420" + cDelimit                   											  	      //01 - REG
cStrTxt += Alltrim( (cAliasC402)->( C6D_CODIGO ) ) + cDelimit                      //02 - COD_TOT_PAR
cStrTxt += Val2Str(  (cAliasC402)->C6H_VLRTOT, 16, 2 ) + cDelimit  //03 - VLR_ACUM_TOT
cStrTxt += Alltrim( (cAliasC402)->C6H_NRTOT ) + cDelimit                                        //04 - NR_TOT
cStrTxt += Alltrim( StrTran( (cAliasC402)->C6H_DESST, CRLF, "" ) ) + cDelimit                                        //05 - DESCR_NR_TOT
cStrTxt += CRLF      

//Conta os registros para totalizar no bloco 9
TaFContBlc("C420",aTotRegC)			
 	
Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC425

Resumo de Itens do Movimento Diario ( Codigo 02 / 2D ) 

@Param		cStrTxt 	-> String para gravacao do Registro  
			cAliasC402  -> Retorno da Query para Geracao do Registro C420
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC425( cStrTxt, cAliasC402 ) 

Local cDelimit := "|"

If !Empty( (cAliasC402)->( C1L_FILIAL + C1L_CODIGO ) )
	cStrTxt += cDelimit            
	cStrTxt += "C425" + cDelimit                                    									   //01 - REG
	
	//Geração do Registro 0200
	xGerBlc0( "0200",  Alltrim( (cAliasC402)->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd, Right( Alltrim( (cAliasC402)->( C1J_CODIGO ) ), 6 ) )	
	cStrTxt += Alltrim( (cAliasC402)->( C1L_CODIGO ) ) + cDelimit  						   //02 - COD_ITEM
	
	cStrTxt += Val2Str(  (cAliasC402)->C3O_QTD, 16, 3 ) + cDelimit         //03 - QTD

	//Geração do Registro 0190
	xGerBlc0( "0190",  Alltrim(Right( Alltrim( (cAliasC402)->( C1J_CODIGO ) ), 6 )), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Right( Alltrim( (cAliasC402)->( C1J_CODIGO ) ), 6 ) + cDelimit  						   //04 - UNID

	cStrTxt += Val2Str(  (cAliasC402)->C3O_VLITEM, 16, 2 ) + cDelimit       //05 - VL_ITEM
	cStrTxt += Val2Str(  (cAliasC402)->C3O_VLPIS, 16, 2 ) + cDelimit        //06 - VL_PIS
	cStrTxt += Val2Str(  (cAliasC402)->C3O_VLCOF, 16, 2 ) + cDelimit        //07 - VL_COFINS
	cStrTxt += CRLF              
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C425",aTotRegC)			
				
EndIf
 	
Return ( Nil )                

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC460

Documento Fiscal Emitido por ECF ( Codigo 02 / 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC460    -> Informacoes para geracao do Registro C460
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC460( cStrTxt, aRegC460 )				 

Local cDelimit := "|"

Local nlY      := 0

For nlY := 1 To Len( aRegC460 )           
	cStrTxt += cDelimit 
	cStrTxt += Alltrim( aRegC460[nlY][1] ) + cDelimit     									//01 - REG
	cStrTxt += Alltrim( aRegC460[nlY][2] ) + cDelimit     									//02 - COD_MOD
	cStrTxt += Alltrim( aRegC460[nlY][3] ) + cDelimit     									//03 - COD_SIT
	cStrTxt += Alltrim( aRegC460[nlY][4] ) + cDelimit     									//04 - NUM_DOC
	cStrTxt += Alltrim( aRegC460[nlY][5] ) + cDelimit     									//05 - DT_DOC
	cStrTxt += Val2Str(  aRegC460[nlY][6], 16, 2 ) + cDelimit //06 - VL_DOC
	cStrTxt += Val2Str(  aRegC460[nlY][7], 16, 2 ) + cDelimit //07 - VL_PIS
	cStrTxt += Val2Str(  aRegC460[nlY][8], 16, 2 ) + cDelimit //08 - VL_COFINS
	cStrTxt += Alltrim( aRegC460[nlY][9]  ) + cDelimit 									//09 - CPF_CNPJ
	cStrTxt += Alltrim( aRegC460[nlY][10] ) + cDelimit 									//10 - NOM_ADQ
	cStrTxt += CRLF	              
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C460",aTotRegC)			
				
Next

Return ( Nil )		     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC470

Itens do Documento Fiscal Emitido por ECF ( Codigo 02 / 2D )

@Param		cStrTxt02 	-> String para gravacao do Registro  
			aRegC470    -> Informacoes para geracao do Registro C470
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC470( cStrTxt02, aRegC470 )				 

Local cDelimit := "|"

Local nlY      := 0

For nlY := 1 To Len( aRegC470 )           
	cStrTxt02 += cDelimit 
	cStrTxt02 += Alltrim( aRegC470[nlY][1] ) + cDelimit  											//01 - REG
	
	//Geração do Registro 0200
	xGerBlc0( "0200",  Alltrim( aRegC470[nlY][2] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aRegC470[nlY][5] ) )	
	cStrTxt02 += Alltrim( aRegC470[nlY][2] ) + cDelimit                                            //02 - COD_ITEM
	
	cStrTxt02 += Val2Str(  aRegC470[nlY][3], 16, 3 ) + cDelimit     //03 - QTD
	cStrTxt02 += Val2Str(  aRegC470[nlY][4], 16, 3 ) + cDelimit     //04 - QTD_CANC
	
	//Geração do Registro 0190
	xGerBlc0( "0190",  Alltrim( aRegC470[nlY][5] ), cFilSelBc, aWizardBc, cTabSpd )
	cStrTxt02 += Alltrim( aRegC470[nlY][5] ) + cDelimit                                           //05 - UNID
	
	cStrTxt02 += Val2Str(  aRegC470[nlY][6], 16, 2 ) + cDelimit      //06 - VL_ITEM
	cStrTxt02 += Alltrim( aRegC470[nlY][7] ) + cDelimit                                           //07 - CST_ICMS
	cStrTxt02 += Alltrim( aRegC470[nlY][8] ) + cDelimit                                           //08 - CFOP
	cStrTxt02 += Val2Str(  aRegC470[nlY][9] ,16, 2 ) + cDelimit    //09 - ALIQ_ICMS
	cStrTxt02 += Val2Str(  aRegC470[nlY][10], 16, 2 )  + cDelimit    //10 - VL_PIS
	cStrTxt02 += Val2Str(  aRegC470[nlY][11], 16, 2 )  + cDelimit    //11 - VL_COFINS
	cStrTxt02 += CRLF	      
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C470",aTotRegC)			
				
Next

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC490

Registro Analitico do Movimento Diario (Codigo 02 e 2D )

@Param		cStrTxt02 	-> String para gravacao do Registro  
			aRegC490    -> Informacoes para geracao do Registro C490
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC490( cStrTxt02, aRegC490 )				 

Local cDelimit := "|"

Local nlY      := 0

For nlY := 1 To Len( aRegC490 )           
	cStrTxt02 += cDelimit 
	cStrTxt02 += aRegC490[nlY][1] + cDelimit   												//01 - REG
	cStrTxt02 += Alltrim( aRegC490[nlY][2] ) + cDelimit   										//02 - CST_ICMS
	cStrTxt02 += Alltrim( aRegC490[nlY][3] ) + cDelimit   										//03 - CFOP
	cStrTxt02 += Val2Str(  aRegC490[nlY][4], 16, 2 ) + cDelimit  //04 - ALIQ_ICMS
	cStrTxt02 += Val2Str(  aRegC490[nlY][5], 16, 2 ) + cDelimit  //05 - VL_OPR
	cStrTxt02 += Val2Str(  aRegC490[nlY][6], 16, 2 ) + cDelimit  //06 - VL_BC_ICMS
	cStrTxt02 += Val2Str(  aRegC490[nlY][7], 16, 2 ) + cDelimit  //07 - VL_ICMS
	
	xGerBlc0( "0460",  Alltrim( StrTran( aRegC490[nlY][8], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt02 += Alltrim( StrTran( aRegC490[nlY][8], CRLF, "" ) ) + cDelimit   										//08 - COD_OBS
	
	cStrTxt02 += CRLF	  
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C490",aTotRegC)			
				
Next

Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC495

Resumo Mensal de Itens do ECF por Estabelecimento ( Codigo 02 e 2D )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC495    -> Informacoes para geracao do Registro C495
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC495( cStrTxt, aRegC495 )				 

Local cDelimit := "|"

Local nlY      := 0

For nlY := 1 To Len( aRegC495 )           
	cStrTxt += cDelimit 
	cStrTxt += Alltrim( aRegC495[nlY][1] ) + cDelimit 										  //01 - REG
	cStrTxt += Val2Str(  aRegC495[nlY][2], 16, 2 ) + cDelimit  //02 - ALIQ_ICMS 
	
	//Geração do Registro 0200
	xGerBlc0( "0200",  Alltrim( aRegC495[nlY][3] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aRegC495[nlY][6] ) )	
	cStrTxt += Alltrim( aRegC495[nlY][3] ) + cDelimit 										  //03 - COD_ITEM
	
	cStrTxt += Val2Str(  aRegC495[nlY][4], 16, 3 ) + cDelimit //04 - QTD
	cStrTxt += Val2Str(  aRegC495[nlY][5], 16, 3 ) + cDelimit //05 - QTD_CANC				
	
	//Geração do Registro 0190
	xGerBlc0( "0190",  Alltrim( aRegC495[nlY][6] ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim( aRegC495[nlY][6] ) + cDelimit 										  //06 - UNID
	
	cStrTxt += Val2Str(  aRegC495[nlY][7], 16, 2 )  + cDelimit //07 - VL_ITEM
	cStrTxt += Val2Str(  aRegC495[nlY][8], 16, 2 )  + cDelimit //08 - VL_DESC
	cStrTxt += Val2Str(  aRegC495[nlY][9], 16, 2 )  + cDelimit //09 - VL_CANC
	cStrTxt += Val2Str(  aRegC495[nlY][10], 16, 2 ) + cDelimit //10 - VL_ACMO
	cStrTxt += Val2Str(  aRegC495[nlY][11], 16, 2 ) + cDelimit //11 - VL_BC_ICMS
	cStrTxt += Val2Str(  aRegC495[nlY][12], 16, 2 ) + cDelimit //12 - VL_ICMS
	cStrTxt += Val2Str(  aRegC495[nlY][13], 16, 2 ) + cDelimit //13 - VL_ISEN
	cStrTxt += Val2Str(  aRegC495[nlY][14], 16, 2 ) + cDelimit //14 - VL_NT
	cStrTxt += Val2Str(  aRegC495[nlY][15], 16, 2 ) + cDelimit //15 - VL_ICMS_ST	
	cStrTxt += CRLF	       
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C495",aTotRegC)			
				
Next

Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC500

Nota Fiscal/Conta de Energia Eletrica ( Codigo 06 ), Nota Fiscal/Conta de 
Fornecimento Dagua Canalizada ( Codigo 29 ) e Nota Fiscal Consumo Fornecimento de Gas
(Codigo 28 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC500    -> Informacoes para geracao do Registro C500
			lNfCanc     -> Indica se a NF Que sera gerada eh cancelada
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC500( cStrTxt, aRegC500, lNfCanc )				 

Local cDelimit := "|"                

Local nlY := 1
       
cStrTxt += cDelimit 
cStrTxt += Alltrim( aRegC500[1][1] ) + cDelimit   										//01- REG	 										
cStrTxt += Alltrim( aRegC500[1][2] ) + cDelimit   										//02 - IND_OPER 										
cStrTxt += Alltrim( aRegC500[1][3] ) + cDelimit   										//03 - IND_EMIT 										

If lNfCanc
	cStrTxt += "" + cDelimit 																//04 - COD_PART
Else

	//Geração do Registro 0150/0175
	xGerBlc0( "0150",  Alltrim( aRegC500[1][4] ), cFilSelBc, aWizardBc, cTabSpd )					
	cStrTxt += Alltrim( aRegC500[1][4] ) + cDelimit					 					//04 - COD_PART
	
EndIf
 										
cStrTxt += Alltrim( aRegC500[1][5] ) + cDelimit   										//05 - COD_MOD 										
cStrTxt += Alltrim( aRegC500[1][6] ) + cDelimit   										//06 - COD_SIT 										
cStrTxt += Alltrim( aRegC500[1][7] ) + cDelimit 										//07 - SER 										
cStrTxt += Alltrim( Iif( lNfCanc, "", aRegC500[1][8] ) ) + cDelimit 					//08 - SUB 										
cStrTxt += Alltrim( Iif( lNfCanc, "", aRegC500[1][9] ) ) + cDelimit 					//09 - COD_CONS 										
cStrTxt += Alltrim( aRegC500[1][10] ) + cDelimit 										//10 - NUM_DOC 										
cStrTxt += Alltrim( aRegC500[1][11] ) + cDelimit  										//11 - DT_DOC

If !lNfCanc  										
	cStrTxt += Alltrim( aRegC500[1][12] ) + cDelimit 										//12 - DT_ES 										
	cStrTxt += Val2Str(  aRegC500[1][13], 16, 2 ) + cDelimit 	//13 - VL_DOC 										
	cStrTxt += Val2Str(  aRegC500[1][14], 16, 2 ) + cDelimit 	//14 - VL_DESC 										
	cStrTxt += Val2Str(  aRegC500[1][15], 16, 2 ) + cDelimit 	//15 - VL_FORN 										
	cStrTxt += Val2Str(  aRegC500[1][16], 16, 2 ) + cDelimit 	//16 - VL_SERV_NT 										
	cStrTxt += Val2Str(  aRegC500[1][17], 16, 2 ) + cDelimit 	//17 - VL_TERC 										
	cStrTxt += Val2Str(  aRegC500[1][18], 16, 2 ) + cDelimit 	//18 - VL_DA 										
	cStrTxt += Val2Str(  aRegC500[1][19], 16, 2 ) + cDelimit 	//19 - VL_BC_ICMS 										
	cStrTxt += Val2Str(  aRegC500[1][20], 16, 2 ) + cDelimit 	//20 - VL_ICMS 										
	cStrTxt += Val2Str(  aRegC500[1][21], 16, 2 ) + cDelimit 	//21 - VL_BC_ICMS_ST 										
	cStrTxt += Val2Str(  aRegC500[1][22], 16, 2 ) + cDelimit 	//22 - VL_ICMS_ST 										
	
	xGerBlc0( "0450",  Alltrim( aRegC500[1][23] ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim( aRegC500[1][23] ) + cDelimit 										//23 - COD_INF
	 										
	cStrTxt += Val2Str(  aRegC500[1][24], 16, 2 ) + cDelimit 	//24 - VL_PIS 										
	cStrTxt += Val2Str(  aRegC500[1][25], 16, 2 ) + cDelimit 	//25 - VL_COFINS 										
	cStrTxt += Alltrim( aRegC500[1][26] ) + cDelimit 										//26 - TP_LIGACAO 										
	cStrTxt += Alltrim( aRegC500[1][27] ) + cDelimit 										//27 - COD_GRUPO_TENSAO 										
Else 
	For nlY := 1 To 16
		cStrTxt += "" + cDelimit 		
	Next
EndIf                    

cStrTxt += CRLF	

//Conta os registros para totalizar no bloco 9
TaFContBlc("C500",aTotRegC)			 

Return ( Nil )          

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC510

Itens do Documento Nota Fiscal  / Conta Energia Eletrica ( Codigo 06 ), Nota Fiscal/
Conta de Fornecimento Dgua Canalizada ( Codigo 29 ) e Nota Fiscal/Conta de Fornecimento
de Gas ( Codigo 28 )

@Param		cStrTxt02 	-> String para gravacao do Registro  
			aRegC510    -> Informacoes para geracao do Registro C510
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC510( cStrTxt02, aRegC510 )				 

Local cDelimit := "|"
       
cStrTxt02 += cDelimit 
cStrTxt02 += Alltrim( aRegC510[1][1] ) + cDelimit 	 										//01 - REG									
cStrTxt02 += Alltrim( aRegC510[1][2] ) + cDelimit 	 										//02 - NUM_ITEM									

//Geração do Registro 0200
xGerBlc0( "0200",  Alltrim( aRegC510[1][3] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aRegC510[1][6] ) )
cStrTxt02 += Alltrim( aRegC510[1][3] ) + cDelimit 	 										//03 - COD_ITEM	
								
cStrTxt02 += Alltrim( aRegC510[1][4] ) + cDelimit 	 										//04 - COD_CLASS									
cStrTxt02 += Val2Str(  aRegC510[1][5], 16, 3 ) + cDelimit   //05 - QTD										

//Geração do Registro 0190
xGerBlc0( "0190",  Alltrim( aRegC510[1][6] ), cFilSelBc, aWizardBc, cTabSpd )
cStrTxt02 += Alltrim( aRegC510[1][6] ) + cDelimit 	 										//06 - UNID									

cStrTxt02 += Val2Str(  aRegC510[1][7], 16, 2 ) + cDelimit    //07 - VL_ITEM									
cStrTxt02 += Val2Str(  aRegC510[1][8], 16, 2 ) + cDelimit    //08 - VL_DESC										
cStrTxt02 += Alltrim( aRegC510[1][9] ) + cDelimit 	 										//09 - CST_ICMS									
cStrTxt02 += Alltrim( aRegC510[1][10] ) + cDelimit  										//10 - CFOP										
cStrTxt02 += Val2Str(  aRegC510[1][11], 16, 2 ) + cDelimit   //11 - VL_BC_ICMS 										
cStrTxt02 += Val2Str(  aRegC510[1][12], 16, 2 ) + cDelimit   //12 - ALIQ_ICMS 										
cStrTxt02 += Val2Str(  aRegC510[1][13], 16, 2 ) + cDelimit   //13 - VL_ICMS 										
cStrTxt02 += Val2Str(  aRegC510[1][14], 16, 2 ) + cDelimit   //14 - VL_BC_ICMS_ST										
cStrTxt02 += Val2Str(  aRegC510[1][15], 16, 2 ) + cDelimit   //15 - ALIQ_ST 										
cStrTxt02 += Val2Str(  aRegC510[1][16], 16, 2 ) + cDelimit   //16 - VL_ICMS_ST										
cStrTxt02 += Alltrim( aRegC510[1][17] ) + cDelimit  										//17 - IND_REC										

//Geração do Registro 0150/0175
xGerBlc0( "0150",  Alltrim( aRegC510[1][18] ), cFilSelBc, aWizardBc, cTabSpd )	
cStrTxt02 += Alltrim( aRegC510[1][18] ) + cDelimit  										//18 - COD_PART
										
cStrTxt02 += Val2Str(  aRegC510[1][19], 16, 2 ) + cDelimit   //19 - VL_PIS										
cStrTxt02 += Val2Str(  aRegC510[1][20], 16, 2 ) + cDelimit   //20 - VL_COFINS										

xGerBlc0( "0500",  Alltrim( aRegC510[1][21] ), cFilSelBc, aWizardBc, cTabSpd)
cStrTxt02 += Alltrim( aRegC510[1][21] ) + cDelimit  										//21 - COD_CTA
																								
cStrTxt02 += CRLF	    

//Conta os registros para totalizar no bloco 9
TaFContBlc("C510",aTotRegC)			

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC590

Registro Analitico do Documento - Nota Fiscal / Conta de Energia Eletrica
( Codigo 06 ), Nota Fiscal/Conta de fornecimento Dagua Canalizada ( Codigo 29 )
e Nota Fiscal Consumo Fornecimento de Gas ( Codigo 28 )

@Param		cStrTxt03 	-> String para gravacao do Registro  
			aRegC590    -> Informacoes para geracao do Registro C590
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC590( cStrTxt03, aRegC590 )				 

Local cDelimit := "|"
       
cStrTxt03 += cDelimit 
cStrTxt03 += Alltrim( aRegC590[1][1]  )  + cDelimit   												//01 - REG
cStrTxt03 += Alltrim( aRegC590[1][2]  )  + cDelimit   												//02 - CST_ICMS						
cStrTxt03 += Alltrim( aRegC590[1][3]  )  + cDelimit   												//03 - CFOP						
cStrTxt03 += Val2Str(  aRegC590[1][4],16, 2 )  + cDelimit   		//04 - ALIQ_ICMS						
cStrTxt03 += Val2Str(  aRegC590[1][5],16, 2 )  + cDelimit   		//05 - VL_OPR						
cStrTxt03 += Val2Str(  aRegC590[1][6],16, 2 )  + cDelimit   		//06 - VL_BC_ICMS						
cStrTxt03 += Val2Str(  aRegC590[1][7],16, 2 )  + cDelimit   		//07 - VL_ICMS						
cStrTxt03 += Val2Str(  aRegC590[1][8],16, 2 )  + cDelimit   		//08 - VL_BC_ICMS_ST						
cStrTxt03 += Val2Str(  aRegC590[1][9],16, 2 )  + cDelimit   		//09 - VL_ICMS_ST						
cStrTxt03 += Val2Str(  aRegC590[1][10], 16, 2 )  + cDelimit			//10 - VL_RED_BC							

xGerBlc0( "0460",  Alltrim( StrTran( aRegC590[1][11], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )
cStrTxt03 += Alltrim( StrTran( aRegC590[1][11], CRLF, "" ) )  + cDelimit   												//11 - COD_OBS
							
cStrTxt03 += CRLF	     

//Conta os registros para totalizar no bloco 9
TaFContBlc("C590",aTotRegC)			

Return ( Nil )        

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC190

Registro Analitico do Documento ( Codigo 01, 1B, 04 e 55 )

@Param		cStrTxt02 	-> String para gravacao do Registro  
			aRegC190    -> Informacoes para geracao do Registro C190
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC190( cStrTxt02, aRegC190 )				 

Local cDelimit := "|"            

Local nY := 1

For nY := 1 To Len( aRegC190 )    
	cStrTxt02 += cDelimit 								
	cStrTxt02 += Alltrim( aRegC190[nY][1]  )  + cDelimit				//01 - REG
	cStrTxt02 += Alltrim( aRegC190[nY][2]  )  + cDelimit				//02 - CST_ICMS						
	cStrTxt02 += Alltrim( aRegC190[nY][3]  )  + cDelimit				//03 - CFOP						
	cStrTxt02 += Val2Str(  aRegC190[nY][4],16, 2 )  + cDelimit   		//04 - ALIQ_ICMS						
	cStrTxt02 += Val2Str(  aRegC190[nY][5],16, 2 )  + cDelimit   		//05 - VL_OPR						
	cStrTxt02 += Val2Str(  aRegC190[nY][6],16, 2 )  + cDelimit   		//06 - VL_BC_ICMS						
	cStrTxt02 += Val2Str(  aRegC190[nY][7],16, 2 )  + cDelimit   		//07 - VL_ICMS						
	cStrTxt02 += Val2Str(  aRegC190[nY][8],16, 2 )  + cDelimit   		//08 - VL_BC_ICMS_ST						
	cStrTxt02 += Val2Str(  aRegC190[nY][9],16, 2 )  + cDelimit   		//09 - VL_ICMS_ST						
	cStrTxt02 += Val2Str(  aRegC190[nY][10], 16, 2 )  + cDelimit		//10 - VL_RED_BC							
	cStrTxt02 += Val2Str(  aRegC190[nY][11], 16, 2 )  + cDelimit		//10 - VL_IPI							
	
	xGerBlc0( "0460",  Alltrim( StrTran( aRegC190[nY][12], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )
	cStrTxt02 += Alltrim( StrTran( aRegC190[nY][12], CRLF, "" ) )  + cDelimit   				//11 - COD_OBS
								
	cStrTxt02 += CRLF	     
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C190",aTotRegC)			
Next

Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC600

Consolidacao Diaria de Notas Fiscais / Conta de Energia Eletrica ( Codigo 06 ), 
Nota Fiscal / Conta de Fornecimento Dagua Canalizada ( Codigo 29 ) e Nota Fiscal / 
Conta de Fornecimento de Gas ( Codigo 28 ) ( Empresas nao obrigadas ao Convenio
ICMS 115/03 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC600    -> Informacoes para geracao do Registro C600
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC600( cStrTxt, aRegC600 )				 

Local cDelimit := "|"
 
cStrTxt += cDelimit 
cStrTxt += Alltrim( aRegC600[1][1] ) + cDelimit   										//01 - REG										  
cStrTxt += Alltrim( aRegC600[1][2] ) + cDelimit 										//02 - COD_MOD									  
cStrTxt += Alltrim( aRegC600[1][3] ) + cDelimit 										//03 - COD_MUN									  
cStrTxt += Alltrim( aRegC600[1][4] ) + cDelimit 										//04 - SER									  
cStrTxt += Alltrim( aRegC600[1][5] ) + cDelimit   										//05 - SUB									  
cStrTxt += Alltrim( aRegC600[1][6] ) + cDelimit   										//06 - COD_CONS									  
cStrTxt += Val2Str(  aRegC600[1][7], 16, 0 ) + cDelimit		//07 - QTD_CONS									  
cStrTxt += Val2Str(  aRegC600[1][8], 16, 0 ) + cDelimit		//08 - QTD_CANC									  						
cStrTxt += Alltrim( aRegC600[1][9] ) + cDelimit 										//09 - DT_DOC									  
cStrTxt += Val2Str(  aRegC600[1][10], 16, 2) + cDelimit 	//10 - VL_DOC									  
cStrTxt += Val2Str(  aRegC600[1][11], 16, 2) + cDelimit 	//11 - VL_DESC									  
cStrTxt += Val2Str(  aRegC600[1][12], 16, 0) + cDelimit	//12 - CONS									  				
cStrTxt += Val2Str(  aRegC600[1][13], 16, 2) + cDelimit 	//13 - VL_FORN									  
cStrTxt += Val2Str(  aRegC600[1][14], 16, 2) + cDelimit 	//14 - VL_SERV_NT									  
cStrTxt += Val2Str(  aRegC600[1][15], 16, 2) + cDelimit 	//15 - VL_TERC										  
cStrTxt += Val2Str(  aRegC600[1][16], 16, 2) + cDelimit 	//16 - VL_DA									  
cStrTxt += Val2Str(  aRegC600[1][17], 16, 2) + cDelimit 	//17 - VL_BC_ICMS									  
cStrTxt += Val2Str(  aRegC600[1][18], 16, 2) + cDelimit 	//18 - VL_ICMS									  
cStrTxt += Val2Str(  aRegC600[1][19], 16, 2) + cDelimit 	//19 - VL_BC_ICMS_ST									  
cStrTxt += Val2Str(  aRegC600[1][20], 16, 2) + cDelimit 	//20 - VL_ICMS_ST									  
cStrTxt += Val2Str(  aRegC600[1][21], 16, 2) + cDelimit 	//21 - VL_PIS									  
cStrTxt += Val2Str(  aRegC600[1][22], 16, 2) + cDelimit 	//22 - VL_COFINS									  								
cStrTxt += CRLF	           

//Conta os registros para totalizar no bloco 9
TaFContBlc("C600",aTotRegC)			

Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC601

Documentos Cancelados - Consolidacao Diaria de Notas Fiscais / Conta de Energia Eletrica
( Codigo 06 ), Nota Fiscal / Conta de Fornecimento Dagua Canalizada ( Codigo 29 ) e Nota
Fiscal / Conta de Fornecimento de Gas ( Codigo 28 )


@Param		cStrTxt02 	-> String para gravacao do Registro  
			cAliasC600  -> Informacoes para geracao do Registro C601
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC601( cStrTxt02, cAliasC600 )				 

Local cDelimit := "|"

cStrTxt02 += cDelimit            
cStrTxt02 += "C601" + cDelimit                                    									   
cStrTxt02 += Alltrim( (cAliasC600)->C20_NUMDOC ) + cDelimit                                    									   
cStrTxt02 += CRLF        

//Conta os registros para totalizar no bloco 9
TaFContBlc("C601",aTotRegC)			

Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC610

Itens do Documento Consolidado ( Codigo 06 ), Nota Fiscal / Conta de Fornecimento Dagua 
Canalizada ( Codigo 29 )e Nota Fiscal / Conta de Fornecimento de Gas ( Codigo 28 ) 
(Empresas Nao Obrigadas ao Convenio ICMS 115/03 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC610    -> Informacoes para geracao do Registro C610
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC610( cStrTxt, aRegC610 )				 

Local cDelimit := "|"                                                  

Local nlY := 1

For nlY := 1 To Len( aRegC610 ) 
	cStrTxt += cDelimit 
	cStrTxt += Alltrim( aRegC610[nlY][1] )  + cDelimit   											//01 - REG				
	cStrTxt += Alltrim( aRegC610[nlY][2] )  + cDelimit   											//02 - COD_CLASS				
	
	//Geração do Registro 0200
	xGerBlc0( "0200",  Alltrim( aRegC610[nlY][3] ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( aRegC610[nlY][5] ) )	
	cStrTxt += Alltrim( aRegC610[nlY][3] )  + cDelimit   											//03 - COD_ITEM
					
	cStrTxt += Val2Str(  aRegC610[nlY][4], 16, 3  )  + cDelimit   	//04 - QTD				
	
	//Geração do Registro 0190
	xGerBlc0( "0190",  Alltrim( aRegC610[nlY][5] ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim( aRegC610[nlY][5] )  + cDelimit   											//05 - UNID				
	
	cStrTxt += Val2Str(  aRegC610[nlY][6], 16, 2 )  + cDelimit   		//06 - VL_ITEM				
	cStrTxt += Val2Str(  aRegC610[nlY][7], 16, 2 )  + cDelimit   		//07 - VL_DESC				
	cStrTxt += Alltrim( aRegC610[nlY][8] )  + cDelimit   											//08 - CST_ICMS				
	cStrTxt += Alltrim( aRegC610[nlY][9] )  + cDelimit   											//09 - CFOP				
	cStrTxt += Val2Str(  aRegC610[nlY][10], 16, 2 ) + cDelimit   		//10 - ALQ_ICMS				
	cStrTxt += Val2Str(  aRegC610[nlY][11], 16, 2 ) + cDelimit   		//11 - VL_BC_ICMS				
	cStrTxt += Val2Str(  aRegC610[nlY][12], 16, 2 ) + cDelimit   		//12 - VL_ICMS				
	cStrTxt += Val2Str(  aRegC610[nlY][13], 16, 2 ) + cDelimit   		//13 - VL_BC_ICMS_ST				
	cStrTxt += Val2Str(  aRegC610[nlY][14], 16, 2 ) + cDelimit   		//14 - VL_ICMS_ST																
	cStrTxt += Val2Str(  aRegC610[nlY][15], 16, 2 ) + cDelimit   		//15 - VL_PIS					
	cStrTxt += Val2Str(  aRegC610[nlY][16], 16, 2 ) + cDelimit   		//16 - VL_COFINS				
	
	xGerBlc0( "0500",  Alltrim( aRegC610[nlY][17] ), cFilSelBc, aWizardBc, cTabSpd)
	cStrTxt += Alltrim( aRegC610[nlY][17] ) + cDelimit   	   										//17 - COD_CTA
					
	cStrTxt += CRLF	      
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C610",aTotRegC)			
				
Next

Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC690

Registro Analitico dos Documentos ( Notas Fiscais / Conta de Energia Eletrica 
( Codigo 06 ), Nota Fiscal / Conta de Fornecimento Dagua Canalizada ( Codigo 29 ) 
e Nota Fiscal / Conta de Fornecimento de Gas ( Codigo 28 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC690    -> Informacoes para geracao do Registro C690
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC690( cStrTxt, aRegC690 )				 

Local cDelimit := "|"                                                  

Local nlY := 1

For nlY := 1 To Len( aRegC690 ) 
	cStrTxt += cDelimit 
	cStrTxt += Alltrim( aRegC690[nlY][1] )  + cDelimit   											//01 - REG									
	cStrTxt += Alltrim( aRegC690[nlY][2] )  + cDelimit   											//02 - CST_ICMS									
	cStrTxt += Alltrim( aRegC690[nlY][3] )  + cDelimit   											//03 - CFOP									
	cStrTxt += Val2Str(  aRegC690[nlY][4], 16, 2 )  + cDelimit   		//04 - ALIQ_ICMS									
	cStrTxt += Val2Str(  aRegC690[nlY][5], 16, 2 )  + cDelimit   		//05 - VL_OPR									
	cStrTxt += Val2Str(  aRegC690[nlY][6], 16, 2 )  + cDelimit   		//06 - VL_BC_ICMS									
	cStrTxt += Val2Str(  aRegC690[nlY][7], 16, 2 )  + cDelimit   		//07 - VL_ICMS									
	cStrTxt += Val2Str(  aRegC690[nlY][8], 16, 2 )  + cDelimit   		//08 - VL_RED_BC									
	cStrTxt += Val2Str(  aRegC690[nlY][9], 16, 2 )  + cDelimit   		//09 - VL_BC_ICMS_ST									
	cStrTxt += Val2Str(  aRegC690[nlY][10], 16, 2 )  + cDelimit   	//10 - VL_ICMS_ST									
	
	xGerBlc0( "0460",  Alltrim( StrTran( aRegC690[nlY][11], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim( StrTran( aRegC690[nlY][11], CRLF, "" ) )  + cDelimit   											//11 - COD_OBS
																				
	cStrTxt += CRLF	 
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C690",aTotRegC)			
				
Next

Return ( Nil )          

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC700

Consolidacao dos Documentos NF/Conta Energia Eletrica ( Cod 06 ), Emitidas
em Via Unica ( Empresas Obrigadas a Entrega do Arquivo Previsto no Convenio ICMS 115 / 03 )
e Nota Fiscal / Conta de Fornecimento de Gas Canalizado ( Codigo 28 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC700    -> Informacoes para geracao do Registro C700
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC700( cStrTxt, aRegC700 )				 

Local cDelimit := "|"                                                  

cStrTxt += cDelimit 
cStrTxt += Alltrim( aRegC700[1][1] )  + cDelimit 		//01 - REG  										
cStrTxt += Alltrim( aRegC700[1][2] )  + cDelimit   	//02 - COD_MOD									
cStrTxt += Alltrim( aRegC700[1][3] )  + cDelimit   	//03 - SER									
cStrTxt += Alltrim( aRegC700[1][4] )  + cDelimit   	//04 - NRO_ORD_INI									
cStrTxt += Alltrim( aRegC700[1][5] )  + cDelimit   	//05 - NRO_ORD_FIN									
cStrTxt += Alltrim( aRegC700[1][6] )  + cDelimit   	//06 - DT_DOC_INI									
cStrTxt += Alltrim( aRegC700[1][7] )  + cDelimit   	//07 - DT_DOC_FIN									
cStrTxt += Alltrim( aRegC700[1][8] )  + cDelimit   	//08 - NOM_MEST									
cStrTxt += Alltrim( aRegC700[1][9] )  + cDelimit   	//09 - CHV_COD_DIG									
cStrTxt += CRLF	     

//Conta os registros para totalizar no bloco 9
TaFContBlc("C700",aTotRegC)			

Return ( Nil )           

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC790

Registro Analitico dos Documentos ( Codigo 06 e 28 )

@Param		cStrTxt 	-> String para gravacao do Registro  
			aRegC790    -> Informacoes para geracao do Registro C790
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 01/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC790( cStrTxt, aRegC790, aRegC791 )				 

Local cDelimit := "|"  

Local nlY := 1

For nlY := 1 To Len( aRegC790 )                                                

	cStrTxt += cDelimit 
	cStrTxt += Alltrim( aRegC790[nlY][1] )   + cDelimit 											//01 - REG
	cStrTxt += Alltrim( aRegC790[nlY][2] )   + cDelimit 											//02 - CST_ICMS
	cStrTxt += Alltrim( aRegC790[nlY][3] )   + cDelimit 											//03 - CFOP
	cStrTxt += Val2Str(  aRegC790[nlY][4], 16, 2 )   + cDelimit 		//04 - ALIQ_ICMS
	cStrTxt += Val2Str(  aRegC790[nlY][5], 16, 2 )   + cDelimit 		//05 - VL_OPR
	cStrTxt += Val2Str(  aRegC790[nlY][6], 16, 2 )   + cDelimit 		//06 - VL_BC_ICMS
	cStrTxt += Val2Str(  aRegC790[nlY][7], 16, 2 )   + cDelimit 		//07 - VL_ICMS
	cStrTxt += Val2Str(  aRegC790[nlY][8], 16, 2 )   + cDelimit 		//08 - VL_BC_ICMS_ST
	cStrTxt += Val2Str(  aRegC790[nlY][9], 16, 2 )   + cDelimit 		//09 - VL_ICMS_ST
	cStrTxt += Val2Str(  aRegC790[nlY][10], 16, 2 )  + cDelimit 		//10 - VL_RED_BC	
	
	xGerBlc0( "0460",  Alltrim(  StrTran( aRegC790[nlY][11], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )	
	cStrTxt += Alltrim(  StrTran( aRegC790[nlY][11], CRLF, "" ) )  + cDelimit 											//11 - COD_OBS
								
	cStrTxt += CRLF	
	
	//Conta os registros para totalizar no bloco 9
	TaFContBlc("C790",aTotRegC)				 
	
	//Geracao do Registro C791
	RegC791( @cStrTxt, aRegC791, nly )		               
	
Next

Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC791

Registro de Informacoes de ST por UF ( Cod 06 )

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC791    -> Dados com informacoes do Registro C791
			nPosC790    -> Relacao com o Registro Pai C790
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC791( cStrTxt, aRegC791, nPosC790 )

Local cDelimit := "|"

Local nlz  := 1

For nlz := 1 To Len( aRegC791 )    
	If aRegC791[nlz][1] == nPosC790
		cStrTxt += cDelimit 
		cStrTxt += aRegC791[nlz][2] + cDelimit 													//01 - REG												 
		cStrTxt += Alltrim( aRegC791[nlz][3] ) + cDelimit 											//02 - UF												 		
		cStrTxt += Val2Str(  aRegC791[nlz][4], 16, 2 ) + cDelimit 	//03 - VL_BC_ICMS_ST												 
		cStrTxt += Val2Str(  aRegC791[nlz][5], 16, 2 ) + cDelimit 	//04 - VL_ICMS_ST		
	 	cStrTxt += CRLF  
	 	
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("C791",aTotRegC)			
				 	
    EndIf    									
Next				
								
Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC800

Cupom Fiscal Eletronico ( Codigo 59 )

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC800   -> Informacoes para geracao do Registro C800
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC800( cStrTxt, aRegC800  )

Local cDelimit 	:= "|" 

cStrTxt +=   cDelimit
cStrTxt +=   aRegC800[1 , 1]    + cDelimit	 //01 - REG 
cStrTxt +=   aRegC800[1 , 2]    + cDelimit	 //02 - COD_MOD 
cStrTxt +=   aRegC800[1 , 3]    + cDelimit	 //03 - COD_SIT 
cStrTxt +=   aRegC800[1 , 4]    + cDelimit	 //04 - NUM_CFE 
cStrTxt +=   aRegC800[1 , 5]    + cDelimit	 //05 - DT_DOC 
cStrTxt +=   aRegC800[1 , 6]    + cDelimit	 //06 - VL_CFE 
cStrTxt +=   aRegC800[1 , 7]    + cDelimit	 //07 - VL_PIS 
cStrTxt +=   aRegC800[1 , 8]    + cDelimit	 //08 - VL_COFINS 
cStrTxt +=   aRegC800[1 , 9]    + cDelimit	 //09 - CNPJ_CPF 
cStrTxt +=   aRegC800[1 , 10]   + cDelimit	 //10 - NR_SAT 
cStrTxt +=   aRegC800[1 , 11]   + cDelimit	 //11 - CHV_CFE 
cStrTxt +=   aRegC800[1 , 12]   + cDelimit	 //12 - VL_DESC 
cStrTxt +=   aRegC800[1 , 13]   + cDelimit	 //13 - VL_MERC 
cStrTxt +=   aRegC800[1 , 14]   + cDelimit	 //14 - VL_OUT_DA 
cStrTxt +=   aRegC800[1 , 15]   + cDelimit	 //15 - VL_ICMS 
cStrTxt +=   aRegC800[1 , 16]   + cDelimit	 //16 - VL_PIS_ST 
cStrTxt +=   aRegC800[1 , 17]   + cDelimit	 //17 - VL_COFINS_S
			 
cStrTxt += CRLF       

//Conta os registros para totalizar no bloco 9
TaFContBlc("C800",aTotRegC)			

Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC850

Registro Analitico do CF-E( Codigo 59 )

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC850    -> Informacoes para geracao do Registro C850
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC850( cStrTxt, aRegC850, nX )

Local cDelimit := "|" 

cStrTxt += cDelimit
cStrTxt += Alltrim( aRegC850[nX][1] ) + cDelimit 										//01 - REG
cStrTxt += Alltrim( aRegC850[nX][2] ) + cDelimit 										//02 - CST_ICMS
cStrTxt += Alltrim( aRegC850[nX][3] ) + cDelimit 										//03 - CFOP
cStrTxt += Val2Str(  aRegC850[nX][4], 16, 2 ) + cDelimit  //04 - ALIQ_ICMS
cStrTxt += Val2Str(  aRegC850[nX][5], 16, 2 ) + cDelimit  //05 - VL_OPR
cStrTxt += Val2Str(  aRegC850[nX][6], 16, 2 ) + cDelimit  //06 - VL_BC_ICMS
cStrTxt += Val2Str(  aRegC850[nX][7], 16, 2 ) + cDelimit  //07 - VL_ICMS

xGerBlc0( "0460",  Alltrim( StrTran( aRegC850[nX][8], CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )
cStrTxt += Alltrim( StrTran( aRegC850[nX][8], CRLF, "" ) ) + cDelimit 										//08 - COD_OBS

cStrTxt += CRLF      

//Conta os registros para totalizar no bloco 9
TaFContBlc("C850",aTotRegC)			

Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC860

Identificacao do Equipamento SAT-CF-E

@Param		cStrTxt     -> String para gravacao do Registro 
			aRegC860    -> Array para geracao do Registro C860
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC860( cStrTxt, aRegC860 )

Local cDelimit := "|" 

cStrTxt += cDelimit
cStrTxt += Alltrim( aRegC860[1][1] ) + cDelimit		//01 - REG 								
cStrTxt += Alltrim( aRegC860[1][2] ) + cDelimit 		//02 - COD_MOD						
cStrTxt += Alltrim( aRegC860[1][3] ) + cDelimit 		//03 - NR_SAT						
cStrTxt += Alltrim( aRegC860[1][4] ) + cDelimit 		//04 - DT_DOC						
cStrTxt += Alltrim( aRegC860[1][5] ) + cDelimit 		//05 - DOC_INI						
cStrTxt += Alltrim( aRegC860[1][6] ) + cDelimit 		//06 - DOC_FIM						
cStrTxt += CRLF    

//Conta os registros para totalizar no bloco 9
TaFContBlc("C860",aTotRegC)			

Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC890

Resumo Diario do CF-E ( Codigo 59 ) por equipamento SAT-CF-E

@Param		cStrTxt02   -> String para gravacao do Registro 
			cAliasC800  -> Alias para geracao do Registro C890
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC890( cStrTxt02, cAliasC800 )

Local cDelimit := "|" 

cStrTxt02 += cDelimit
cStrTxt02 += "C890" + cDelimit																	   		//01 - REG 								
cStrTxt02 += Alltrim( (cAliasC800)->C03_CODIGO + (cAliasC800)->C14_CODIGO ) + cDelimit             								//02 - CST_ICMS
cStrTxt02 += Alltrim( (cAliasC800)->C0Y_CODIGO ) + cDelimit             								//03 - CFOP
cStrTxt02 += Val2Str(  (cAliasC800)->C5T_ALIQ, 16, 2) + cDelimit         //04 - ALIQ_ICMS
cStrTxt02 += Val2Str(  (cAliasC800)->C5S_VLOPR, 16, 2) + cDelimit        //05 - VL_OPR
cStrTxt02 += Val2Str(  (cAliasC800)->C5T_BASE, 16, 2) + cDelimit         //06 - VL_BC_ICMS
cStrTxt02 += Val2Str(  (cAliasC800)->C5T_VALOR, 16, 2) + cDelimit        //07 - VL_ICMS

xGerBlc0( "0460",  Alltrim( StrTran( (cAliasC800)->( C3R_CODIGO ), CRLF, "" ) ), cFilSelBc, aWizardBc, cTabSpd )
cStrTxt02 += Alltrim( StrTran( (cAliasC800)->( C3R_CODIGO ), CRLF, "" ) ) + cDelimit             	 			//08 - COD_OBS

cStrTxt02 += CRLF   

//Conta os registros para totalizar no bloco 9
TaFContBlc("C890",aTotRegC)			

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC890_2

Resumo Diario do CF-E ( Codigo 59 ) por equipamento SAT-CF-E

@Param		cStrTxt02   -> String para gravacao do Registro 
			cAliasC890  -> Alias para geracao do Registro C890
			
@Return ( Nil )

@author Gustavo Baptista
@since 04/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegC890_2( cStrTxt02, cAliasC800 )

Local cDelimit := "|" 
         
cStrTxt02 += cDelimit
cStrTxt02 += "C890" + cDelimit																	//01 - REG 								
cStrTxt02 += Alltrim( (cAliasC800)->C03_CODIGO + (cAliasC800)->CSTICMS) + cDelimit 		//02 - CST_ICMS
cStrTxt02 += Alltrim( (cAliasC800)->CFOP ) + cDelimit          							//03 - CFOP
cStrTxt02 += Val2Str( (cAliasC800)->C7T_ALQICM, 16, 2) + cDelimit  						//04 - ALIQ_ICMS
cStrTxt02 += Val2Str( (cAliasC800)->C7T_VLOPR, 16, 2) + cDelimit   						//05 - VL_OPR
cStrTxt02 += Val2Str( (cAliasC800)->C7T_VLBCIC, 16, 2) + cDelimit  						//06 - VL_BC_ICMS
cStrTxt02 += Val2Str( (cAliasC800)->C7T_VLICMS, 16, 2) + cDelimit  						//07 - VL_ICMS
cStrTxt02 += Alltrim( StrTran( (cAliasC800)->CODOBS, CRLF, "" ) ) + cDelimit				//08 - COD_OBS
cStrTxt02 += CRLF

//Conta os registros para totalizar no bloco 9
TaFContBlc("C890",aTotRegC)			

Return ( Nil )   
    
//-------------------------------------------------------------------
/*/{Protheus.doc} A117GetTrib

Esta Funcao realiza a gravacao dos valores de tributos no array aTrib por
NF, assim teremos os valores totalizados para geracao do registro C100

@Param	cAlias    -> Alias da Query do Registro C100
		aTrib 	  -> Array para receber o valor totalizado por NF
					
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------		
Static Function A117GetTrib( cAlias, aTrib )  

Local cAliasC14 := "C14"
Local cAliasC15 := "C15"
Local cAliasC17 := "C17" 
Local cAliasC03 := "C03"

DbSelectArea(cAliasC14)
(cAliasC14)->(DbSetOrder(3))

DbSelectArea(cAliasC15)
(cAliasC15)->(DbSetOrder(3))

DbSelectArea(cAliasC17)
(cAliasC17)->(DbSetOrder(3))

DbSelectArea(cAliasC03)
(cAliasC03)->(DbSetOrder(3))

If !Empty( (cAlias)->C3S_CODIGO )
	 
	//Valores Referentes a ISSQN		
	If (cAlias)->C3S_CODIGO == "01"		
		aTrib[28] += (cAlias)->C35_BASE
		aTrib[29] += (cAlias)->C35_ALIQ
		aTrib[30] += (cAlias)->C35_VALOR	
			
	//Valores Referentes a ICMS Proprio
	ElseIf (cAlias)->C3S_CODIGO == "02" 
		aTrib[1]  += (cAlias)->C35_BASE
		aTrib[2]  += (cAlias)->C35_VALOR
		aTrib[12] := (cAlias)->C35_ALIQ	    
	    
	    If (cAlias)->C35_REDBC > 0 .And. (cAlias)->C35_VLNT > 0 .And. (cAlias)->C35_VLOUTR == 0 
	    	aTrib[31] += (cAlias)->C35_VLNT
	    Else
	    	aTrib[31] += (cAlias)->C35_VLOUTR
	    EndIf 
	    
		If (cAliasC14)->( MsSeek( xFilial("C14") + (cAlias)->C35_CST ) )
			If (cAliasC03)->( MsSeek( xFilial("C03") + (cAlias)->C30_ORIGEM ) )			
				aTrib[10] := ( (cAliasC03)->C03_CODIGO + (cAliasC14)->C14_CODIGO )
			EndIf
		Else
			aTrib[10] := "" 
		EndIf									    
	    	
	//Valores Referentes a ICMS ST     	
	ElseIf (cAlias)->C3S_CODIGO == "04"	
		aTrib[3]  += (cAlias)->C35_BASE
		aTrib[4]  += (cAlias)->C35_VALOR		
		aTrib[13] := (cAlias)->C35_ALIQ	

		If (cAliasC14)->( MsSeek( xFilial("C14") + (cAlias)->C35_CST ) )
			If (cAliasC03)->( MsSeek( xFilial("C03") + (cAlias)->C30_ORIGEM ) )			
				aTrib[10] := ( (cAliasC03)->C03_CODIGO + (cAliasC14)->C14_CODIGO )
			EndIf
		EndIf									    
	    			
	//Valores Referentes a IPI
	ElseIf (cAlias)->C3S_CODIGO == "05"	
		aTrib[5]  += (cAlias)->C35_VALOR
		aTrib[14] += (cAlias)->C35_BASE
		aTrib[15] := (cAlias)->C35_ALIQ	
		
		If (cAliasC15)->( MsSeek( xFilial("C15") + (cAlias)->C35_CST ) )
			aTrib[11] := (cAliasC15)->C15_CODIGO 
		Else
			aTrib[11] := "" 
		EndIf		
	
	//Valores Referentes a PIS
	ElseIf (cAlias)->C3S_CODIGO == "06"	
		aTrib[6]  += (cAlias)->C35_VALOR												
		aTrib[17] += (cAlias)->C35_BASE
		aTrib[18] := (cAlias)->C35_ALIQ	
		aTrib[19] += (cAlias)->C35_BASEQT	
		aTrib[20] := (cAlias)->C35_ALIQQT	
		aTrib[21] += (cAlias)->C35_VLRPAU    
		
		If (cAliasC17)->( MsSeek( xFilial("C17") + (cAlias)->C35_CST ) )
			aTrib[16] := (cAliasC17)->C17_CODIGO  		 
		Else
			aTrib[16] := ""
		EndIf		
	
	//Valores Referentes a COFINS
	ElseIf (cAlias)->C3S_CODIGO == "07"	
		aTrib[7]  += (cAlias)->C35_VALOR							
		aTrib[23] += (cAlias)->C35_BASE
		aTrib[24] := (cAlias)->C35_ALIQ	
		aTrib[25] += (cAlias)->C35_BASEQT	
		aTrib[26] := (cAlias)->C35_ALIQQT	
		aTrib[27] += (cAlias)->C35_VLRPAU    
		
		If (cAliasC17)->( MsSeek( xFilial("C17") + (cAlias)->C35_CST ) )
			aTrib[22] := (cAliasC17)->C17_CODIGO 
		Else
			aTrib[22] := "" 		
		EndIf        		
	
	//Valores Referentes a PIS ST
	ElseIf (cAlias)->C3S_CODIGO == "08"	
		aTrib[8] += (cAlias)->C35_VALOR							
	
	//Valores Referentes a COFINS ST
	ElseIf (cAlias)->C3S_CODIGO == "09"	
		aTrib[9] += (cAlias)->C35_VALOR							
	EndIf
	
EndIf		

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} A117QrySpC
Realiza a Query Principal para a impressao do Bloco C do Sped Fiscal

@Param cAliasQry -> Alias da Query
       aWizardBc   -> Parametros do Sped
       cAlias    -> Define Qual sera a Query que devera ser realizada 
       cFilSelBc   -> Filiais Selecionadas pelo Usuasrio para processamento
       
@Return ( Nil )

@author Rodrigo Aguilar
@since  02/01/2013
@version 1.0
/*/  
//-------------------------------------------------------------------
Static Function A117QrySpC( cAliasQry, aWizardBc, cAlias, cFilSelBc, aParam )                                      	   
                                      	
Local   cWhere 	   := "" 
Local   cWhere02   := ""
Local   cWhere03   := ""
Local   cWhere04   := ""
Local   cWhere05   := ""
Local   cWhere06   := ""
Local   cSelect	   := ""
Local   cJoin      := ""
Local 	cOrderBy   := ""   
Local   cUnion     := "" 
Local   cUnion02   := ""
Local   cUnion03   := ""   
Local   cUnion04   := ""   
Local   cUnion05   := ""   
Local   cGroupBy   := ""

Local   nRet	   := 0 
Local   dDataIni   := aWizardBc[1][1]
Local   dDataFim   := aWizardBc[1][2]   

//Movimentacao de Bloco C100
If cAlias == "C100"                                                      
			
	cSelect := " C20.C20_FILIAL, C20.C20_CHVNF, C20.C20_INDOPE, C20.C20_INDEMI, C20.C20_SERIE, C20.C20_NUMDOC, C20.C20_CHVELE, C20.C20_DTDOC, C20.C20_DTES, "
	cSelect += " C20.C20_VLDOC, C20.C20_INDPAG, C20.C20_VLDESC, C20.C20_VLABNT, C20.C20_VLMERC, C20.C20_VLRFRT, C20.C20_VLRSEG, C20.C20_VLOUDE, "
	cSelect += " C30.C30_VLOPER, C30.C30_NUMITE, C30.R_E_C_N_O_ C30REC, C30.C30_DESCRI, C30.C30_QUANT, C30.C30_TOTAL, C30.C30_VLDESC, C30.C30_INDMOV, C30.C30_INDAPU, "
	cSelect += " C30.C30_QTDSEL, C30.C30_QTDPAD, C30.C30_VLUNID, C30.C30_BSTORI, C30.C30_VSTREP, C30.C30_VSTCOM, C30.C30_BCRETQ, C30.C30_VLRET, C14.C14_CODIGO, C35.C35_CST, "
	cSelect += " C35.C35_ALIQ, C35.C35_BASEQT, C35.C35_ALIQQT, C35.C35_VLRPAU, C35.C35_CODTRI, C35.C35_BASE, C35.C35_VALOR, C35_VLNT,  C35.C35_REDBC, C35.C35_VLOUTR, "
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C1L.C1L_DESCRI, C0Y.C0Y_CODIGO, C1N.C1N_FILIAL, C1N.C1N_CODNAT, C3T.C3T_CODIGO, " 
	cSelect += " C1O.C1O_FILIAL, C1O.C1O_CODIGO, C1H.C1H_FILIAL, C1H.C1H_CODPAR, C01.C01_CODIGO , C02.C02_CODIGO, C0X.C0X_CODIGO, "
	cSelect += " C3S2.C3S_CODIGO, C1J.C1J_FILIAL, C1J.C1J_CODIGO, C3U.C3U_CODIGO, C30.C30_ORIGEM, C03.C03_CODIGO "
		
	cJoin := RetSqlName("C20") + " C20 " 
	cJoin += " LEFT JOIN " + RetSqlName("C30") + " C30 ON ( C30.C30_FILIAL = " + Iif( FWModeAccess( "C30" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C20.C20_FILIAL" ) + " AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_  = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C3U") + " C3U ON ( C3U.C3U_FILIAL = " + Iif( FWModeAccess( "C3U" , 3 ) == "C" , "'" + xFilial( "C3U" ) + "'" , "C30.C30_FILIAL" ) + " AND C3U.C3U_ID = C30.C30_SELO AND C3U.D_E_L_E_T_ = '' )	"
	cJoin += " LEFT JOIN " + RetSqlName("C1O") + " C1O ON ( C1O.C1O_FILIAL = " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C1O" ) + "'" , "C30.C30_FILIAL" ) + " AND C1O.C1O_ID = C30.C30_CTACTB AND C1O.D_E_L_E_T_ = '' )  "
	cJoin += " LEFT JOIN " + RetSqlName("C03") + " C03 ON ( C03.C03_FILIAL = " + Iif( FWModeAccess( "C03" , 3 ) == "C" , "'" + xFilial( "C03" ) + "'" , "C30.C30_FILIAL" ) + " AND C03.C03_ID = C30.C30_ORIGEM AND C03.D_E_L_E_T_ = '' )  "	
	cJoin += " LEFT JOIN " + RetSqlName("C3T") + " C3T ON ( C3T.C3T_FILIAL = " + Iif( FWModeAccess( "C3T" , 3 ) == "C" , "'" + xFilial( "C3T" ) + "'" , "C30.C30_FILIAL" ) + " AND C3T.C3T_ID  = C30.C30_CLENQ   AND C3T.D_E_L_E_T_ = '' ) "				
	cJoin += " LEFT JOIN " + RetSqlName("C1N") + " C1N ON ( C1N.C1N_FILIAL = " + Iif( FWModeAccess( "C1N" , 3 ) == "C" , "'" + xFilial( "C1N" ) + "'" , "C30.C30_FILIAL" ) + " AND C1N.C1N_ID  = C30.C30_NATOPE AND C1N.D_E_L_E_T_ = '' ) "			
	cJoin += " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C30.C30_FILIAL" ) + " AND C0Y.C0Y_ID  = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1L") + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C30.C30_FILIAL" ) + " AND C1L.C1L_ID  = C30.C30_CODITE  AND C1L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C1J") + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C30.C30_FILIAL" ) + " AND C1J.C1J_ID  = C30.C30_UM AND C1J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C14") + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C30.C30_FILIAL" ) + " AND C14.C14_ID  = C30.C30_CSTCOM AND C14.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C35") + " C35 ON ( C35.C35_FILIAL = " + Iif( FWModeAccess( "C35" , 3 ) == "C" , "'" + xFilial( "C35" ) + "'" , "C20.C20_FILIAL" ) + " AND C35.C35_CHVNF = C20.C20_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND "
	cJoin += " 												 C35.C35_CODTRI IN ( '000001', '000002', '000004', '000005', '000006', '000007', '000008', '000009' )  AND C35.D_E_L_E_T_ = ' ' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C35.C35_FILIAL" ) + " AND C3S2.C3S_ID = C35.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName("C1H") + " C1H ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C20.C20_FILIAL" ) + " AND C01.C01_ID    = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C02") + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C20.C20_FILIAL" ) + " AND C02.C02_ID    = C20.C20_CODSIT AND C02.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C0X") + " C0X ON ( C0X.C0X_FILIAL = " + Iif( FWModeAccess( "C0X" , 3 ) == "C" , "'" + xFilial( "C0X" ) + "'" , "C20.C20_FILIAL" ) + " AND C0X.C0X_ID    = C20.C20_INDFRT AND C0X.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C0U") + " C0U ON ( C0U.C0U_FILIAL = " + Iif( FWModeAccess( "C0U" , 3 ) == "C" , "'" + xFilial( "C0U" ) + "'" , "C20.C20_FILIAL" ) + " AND C0U.C0U_ID    = C20.C20_TPDOC AND C0U.D_E_L_E_T_ = '' ) "
	
	cWhere := " ((C20.C20_INDOPE = '0' AND C20.C20_DTES >= '" + DTOS(dDataIni) + "' AND C20.C20_DTES <='"  + DTOS(dDataFim) + "') OR "
	cWhere += " (C20.C20_INDOPE = '1' AND C20.C20_DTDOC >= '" 		 + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='" + DTOS(dDataFim) + "')) "
	cWhere += " AND C20.C20_FILIAL IN (" + cFilSelBc + ") "
	
	//Tratamento para que somente sejam geradas notas nos modelos abaixo e nao seja considerada a NF de Servico
	cWhere += " AND C01.C01_CODIGO IN ( '01', '1B', '04', '55', '65' ) AND C0U.C0U_CODIGO <> '06' "
	cWhere += " AND C20.D_E_L_E_T_ = '' "     	
    	
	cOrderBy := " C20_INDOPE, C20_DTDOC, C20_CHVNF, C20_NUMDOC, C30_NUMITE, C35_CODTRI "  

//Movimentacao do Bloco C300
ElseIf cAlias == "C300"                          

	cSelect := " C20.C20_CHVNF, C20.C20_SERIE, C20.C20_SUBSER, C20.C20_NUMDOC, C20.C20_NDOCF, C20.C20_DTDOC, C20.C20_VLDOC, C20.C20_FILIAL,  " 
	cSelect += " C30.C30_VLOPER, C30.C30_NUMITE, C30.C30_TOTAL, C30.C30_QUANT, C30.C30_VLRITE, C30.C30_VLDESC,  "                                                                                                                           
	cSelect += " C35.C35_ALIQ, C35.C35_BASEQT, C35.C35_ALIQQT, C35.C35_VLRPAU, C35.C35_CODTRI, C35.C35_BASE, C35.C35_VALOR, C35.C35_CST, C35.C35_VLNT, "
	cSelect += " C01.C01_CODIGO, C1O.C1O_FILIAL, C1O.C1O_CODIGO, C3S2.C3S_CODIGO, C02.C02_CODIGO, C0Y.C0Y_CODIGO, "
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C1J.C1J_FILIAL, C1J.C1J_CODIGO, C1H.C1H_CNPJ, C1H.C1H_CPF, C30.C30_ORIGEM "  
			
	cJoin := RetSqlName("C20") + " C20 " 
	cJoin += " LEFT JOIN " + RetSqlName( "C30" ) + " C30 ON ( C30.C30_FILIAL = " + Iif( FWModeAccess( "C30" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C20.C20_FILIAL" ) + " AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_  = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName( "C1O" ) + " C1O ON ( C1O.C1O_FILIAL = " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C1O" ) + "'" , "C20.C20_FILIAL" ) + " AND C1O.C1O_ID = C20.C20_CODCTA AND C1O.D_E_L_E_T_ = '' )  "
	cJoin += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C30.C30_FILIAL" ) + " AND C0Y.C0Y_ID  = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName( "C1L" ) + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C30.C30_FILIAL" ) + " AND C1L.C1L_ID  = C30.C30_CODITE  AND C1L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName( "C1J" ) + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C30.C30_FILIAL" ) + " AND C1J.C1J_ID  = C30.C30_UM AND C1J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C35" ) + " C35 ON ( C35.C35_FILIAL = " + Iif( FWModeAccess( "C35" , 3 ) == "C" , "'" + xFilial( "C35" ) + "'" , "C20.C20_FILIAL" ) + " AND C35.C35_CHVNF = C20.C20_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND "
	cJoin += " 												 C35.C35_CODTRI IN ( '000002', '000006', '000007' ) AND C35.D_E_L_E_T_ = ' ' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C35.C35_FILIAL" ) + " AND C3S2.C3S_ID = C35.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName( "C1H" ) + " C1H ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C01" ) + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C20.C20_FILIAL" ) + " AND C01.C01_ID    = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName( "C02" ) + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C20.C20_FILIAL" ) + " AND C02.C02_ID    = C20.C20_CODSIT AND C02.D_E_L_E_T_ = '' ) "
	
	cWhere := " C20.C20_DTDOC >= '" + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='" + DTOS(dDataFim) + "' AND "
	cWhere += " C20.C20_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C01.C01_CODIGO = '02' "
	cWhere += " AND C20.C20_INDOPE = '1' "
	cWhere += " AND C20.D_E_L_E_T_ = '' "     	
    	
	cOrderBy := " C20_INDOPE, C20_DTDOC, C20_SERIE, C20_SUBSER, C1O_CODIGO, C20_CHVNF, C30_NUMITE "	

//Movimentacao de Bloco C400 ( C400 / C405 )
ElseIf cAlias == "C400_1"                          

	cSelect := " C6F.C6F_FILIAL, C6F.C6F_ID, C6F.C6F_CODECF, C0W.C0W_FILIAL, C0W.C0W_CODIGO, C0W.C0W_ECFMOD, C0W.C0W_ECFFAB, C0W.C0W_ECFCX,  " 
	cSelect += " C6G.C6G_DTMOV, C6G.C6G_PCREOP, C6G.C6G_PCREDZ, C6G.C6G_NRCOPF, C6G.C6G_VLGRTF, C6G.C6G_VLBRU "
	 
	cJoin := RetSqlName( "C6F" ) + " C6F "
	cJoin += " JOIN " + RetSqlName( "C6G" ) + " C6G ON ( C6G.C6G_FILIAL = " + Iif( FWModeAccess( "C6G" , 3 ) == "C" , "'" + xFilial( "C6G" ) + "'" , "C6F.C6F_FILIAL" ) + " AND C6F.C6F_ID = C6G.C6G_ID AND C6G.D_E_L_E_T_ = '' )  "
	cJoin += " JOIN " + RetSqlName( "C6I" ) + " C6I ON ( C6I.C6I_FILIAL = " + Iif( FWModeAccess( "C6I" , 3 ) == "C" , "'" + xFilial( "C6I" ) + "'" , "C6G.C6G_FILIAL" ) + " AND C6G.C6G_ID = C6I.C6I_ID AND C6G.C6G_DTMOV = C6I.C6I_DTMOV AND C6I.D_E_L_E_T_ = '' )   "
	cJoin += " LEFT JOIN " + RetSqlName( "C01" ) + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C6I.C6I_FILIAL" ) + " AND C01.C01_ID = C6I.C6I_CMOD AND C01.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C0W" ) + " C0W ON ( C0W.C0W_FILIAL = " + Iif( FWModeAccess( "C0W" , 3 ) == "C" , "'" + xFilial( "C0W" ) + "'" , "C6F.C6F_FILIAL" ) + " AND C0W.C0W_ID = C6F.C6F_CODECF AND C0W.D_E_L_E_T_ = '' ) "	    

	cWhere := " C6G.C6G_DTMOV >= '" + DTOS( dDataIni ) + "' AND C6G.C6G_DTMOV <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C6F.C6F_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C6F.D_E_L_E_T_ = '' AND C01.C01_CODIGO IN ( '02', '2D', '60' ) "     	
	
	cOrderBy := " C6F_FILIAL, C6F_CODECF, C6G_DTMOV " 

//Movimentacao de Bloco C400 ( C420 / C425 )
ElseIf cAlias == "C400_2"                 

	cSelect := " C6D.C6D_FILIAL, C6D.C6D_CODIGO, C6H.C6H_VLRTOT, C6H.C6H_NRTOT, C6H.C6H_DESST,  " 
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C3O.C3O_QTD, C1J.C1J_FILIAL, C1J.C1J_CODIGO, C3O.C3O_VLITEM, C3O.C3O_VLPIS, C3O.C3O_VLCOF "
 
	cJoin := RetSqlName( "C6H" ) + " C6H "
	cJoin += " LEFT JOIN " + RetSqlName( "C3O" ) + " C3O ON ( C3O.C3O_FILIAL = " + Iif( FWModeAccess( "C3O" , 3 ) == "C" , "'" + xFilial( "C3O" ) + "'" , "C6H.C6H_FILIAL" ) + " AND C6H.C6H_ID = C3O.C3O_ID AND C6H.C6H_DTMOV = C3O.C3O_DTMOV AND C6H.C6H_CDTOT = C3O.C3O_CDTOT AND C3O.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName( "C6D" ) + " C6D ON ( C6D.C6D_FILIAL = " + Iif( FWModeAccess( "C6D" , 3 ) == "C" , "'" + xFilial( "C6D" ) + "'" , "C6H.C6H_FILIAL" ) + " AND C6D.C6D_ID = C6H.C6H_CDTOT AND C6D.D_E_L_E_T_ = '' ) "	    
	cJoin += " LEFT JOIN " + RetSqlName( "C1L" ) + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C3O.C3O_FILIAL" ) + " AND C1L.C1L_ID  = C3O.C3O_CODITE  AND C1L.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName( "C1J" ) + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C3O.C3O_FILIAL" ) + " AND C1J.C1J_ID  = C3O.C3O_UNID AND C1J.D_E_L_E_T_ = '' ) "	

	cWhere += " C6H.C6H_FILIAL = '" + aParam[1] + "' AND C6H.C6H_ID = '" + aParam[2] + "' AND C6H.C6H_DTMOV = '" + aParam[3] + "' AND "
	cWhere += " C6H.D_E_L_E_T_ = '' "     	
	
	cOrderBy := " C6H_CDTOT, C3O_CODITE "

//Movimentacao de Bloco C400 ( C460 / C470 / C490 )
ElseIf cAlias == "C400_3"                 

	cSelect := " C01.C01_CODIGO, C02.C02_CODIGO, C6I.C6I_NUMDOC, C6I.C6I_DTEMIS, C6I_CMOD, C6I_CODSIT , C6I.C6I_VLDOC, C6I.C6I_CNPJ, C6I.C6I_NOME,  " 
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C3S.C3S_CODIGO, C6K.C6K_VLRTRB, C6J.C6J_QTDE, C6J.C6J_QTDCAN, C1J.C1J_FILIAL, C1J.C1J_CODIGO,    "
	cSelect += " C6J.C6J_VLRITE, C14.C14_CODIGO, C0Y.C0Y_CODIGO, C6K.C6K_ALQPRD, C6K.C6K_VLRBC, C3R.C3R_FILIAL, C3R.C3R_CODIGO, C03.C03_CODIGO "   
 
	cJoin := RetSqlName( "C6I" ) + " C6I "
	cJoin += " LEFT JOIN " + RetSqlName( "C6J" ) + " C6J ON ( C6J.C6J_FILIAL = " + Iif( FWModeAccess( "C6J" , 3 ) == "C" , "'" + xFilial( "C6J" ) + "'" , "C6I.C6I_FILIAL" ) + " AND C6I.C6I_ID = C6J.C6J_ID AND C6I.C6I_DTMOV = C6J.C6J_DTMOV AND C6I.C6I_CMOD = C6J.C6J_CMOD AND C6I.C6I_CODSIT = C6J.C6J_CODSIT AND C6I.C6I_NUMDOC = C6J.C6J_NUMDOC AND C6I.C6I_DTEMIS = C6J.C6J_DTEMIS AND C6J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C6K" ) + " C6K ON ( C6K.C6K_FILIAL = " + Iif( FWModeAccess( "C6K" , 3 ) == "C" , "'" + xFilial( "C6K" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C6J.C6J_ID = C6K.C6K_ID AND C6J.C6J_DTMOV = C6K.C6K_DTMOV AND C6J.C6J_CMOD = C6K.C6K_CMOD AND C6J.C6J_CODSIT = C6K.C6K_CODSIT AND C6J.C6J_NUMDOC = C6K.C6K_NUMDOC AND C6J.C6J_DTEMIS = C6K.C6K_DTEMIS AND C6J.C6J_IT = C6K.C6K_IT AND C6K.D_E_L_E_T_ = '' )	             	
	cJoin += " LEFT JOIN " + RetSqlName( "C01" ) + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C6I.C6I_FILIAL" )   + " AND C01.C01_ID = C6I.C6I_CMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName( "C02" ) + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C6I.C6I_FILIAL" ) + " AND C02.C02_ID = C6I.C6I_CODSIT AND C02.D_E_L_E_T_ = '' ) "	
    cJoin += " LEFT JOIN " + RetSqlName( "C1L" ) + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C1L.C1L_ID = C6J.C6J_IT  AND C1L.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName( "C3S" ) + " C3S ON ( C3S.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C6K.C6K_FILIAL" ) + " AND C3S.C3S_ID = C6K.C6K_CODTRI AND C3S.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName( "C1J" ) + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C1J.C1J_ID = C6J.C6J_UNDITE AND C1J.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C0Y.C0Y_ID = C6J.C6J_CFOP AND C0Y.D_E_L_E_T_ = '' ) "			
	cJoin += " LEFT JOIN " + RetSqlName( "C14" ) + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C6K.C6K_FILIAL" ) + " AND C14.C14_ID = C6K.C6K_CST AND C14.D_E_L_E_T_ = '' ) "				
	cJoin += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C6I.C6I_FILIAL" ) + " AND C3R.C3R_ID = C6I.C6I_CODOBS AND C3R.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName( "C03" ) + " C03 ON ( C03.C03_FILIAL = " + Iif( FWModeAccess( "C03" , 3 ) == "C" , "'" + xFilial( "C03" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C03.C03_ID = C6J.C6J_ORIGEM AND C03.D_E_L_E_T_ = '' ) "					
		
	cWhere += " C6I.C6I_FILIAL = '" + aParam[1] + "' AND C6I.C6I_ID = '" + aParam[2] + "' AND C6I.C6I_DTMOV = '" + aParam[3] + "' AND "
	cWhere += " C6I.D_E_L_E_T_ = '' "     	
	
	cOrderBy := " C6I_CMOD, C6I_CODSIT, C6I_NUMDOC, C6I_DTEMIS "

//Movimentacao de Bloco C410 
ElseIf cAlias == "C400_4"   

 	cSelect += "	( SELECT "
 	cSelect += " 		SUM( C7C.C7C_VL ) "
 	cSelect += "	  FROM " + RetSqlName( "C7C" ) + " C7C WHERE C7C.C7C_FILIAL = '" + aParam[1] + "' AND C7C.C7C_ID = '" + aParam[2] + "' AND C7C.C7C_DTMOV = '" + aParam[3] + "' AND C7C.D_E_L_E_T_ = '' " 
 	cSelect += "    ) PIS,
 	cSelect += "	( SELECT "
 	cSelect += " 		SUM( C7D.C7D_VL ) "
 	cSelect += "	  FROM " + RetSqlName( "C7D" ) + " C7D WHERE C7D.C7D_FILIAL = '" + aParam[1] + "' AND C7D.C7D_ID = '" + aParam[2] + "' AND C7D.C7D_DTMOV = '" + aParam[3] + "' AND C7D.D_E_L_E_T_ = '' " 
 	cSelect += "    ) COFINS 	
 	
	cJoin := RetSqlName( "C6F" ) + " C6F "
	
//Movimentacao de Bloco C490 ( Consolidado pelo Cadastro ) 
ElseIf cAlias == "C400_5"   	
	
	cSelect := " C14.C14_CODIGO, C0Y.C0Y_CODIGO, C7G.C7G_ALQICM, C7G.C7G_VLOPR, C7G.C7G_BCICMS, C7G.C7G_VLICMS, C3R.C3R_FILIAL, C3R.C3R_CODIGO " 
 
	cJoin := RetSqlName( "C7G" ) + " C7G "
	cJoin += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C7G.C7G_FILIAL" ) + " AND C0Y.C0Y_ID = C7G.C7G_CFOP AND C0Y.D_E_L_E_T_ = '' ) "			
	cJoin += " LEFT JOIN " + RetSqlName( "C14" ) + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C7G.C7G_FILIAL" ) + " AND C14.C14_ID = C7G.C7G_CSTICM AND C14.D_E_L_E_T_ = '' ) "				
	cJoin += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C7G.C7G_FILIAL" ) + " AND C3R.C3R_ID = C7G.C7G_CODOBS AND C3R.D_E_L_E_T_ = '' ) "					
	
	cWhere += " C7G.C7G_FILIAL = '" + aParam[1] + "' AND C7G.C7G_ID = '" + aParam[2] + "' AND C7G.C7G_DTMOV = '" + aParam[3] + "' AND "
	cWhere += " C7G.D_E_L_E_T_ = '' "     	
	
	cOrderBy := " C14_CODIGO, C0Y_CODIGO, C7G_ALQICM "

//Movimentacao de Bloco C495  
ElseIf cAlias == "C400_6"

	cSelect := " C6G.C6G_FILIAL, C6G.C6G_DTMOV,  C6I.C6I_CMOD, C6I.C6I_CODSIT, C6I.C6I_NUMDOC, C6I.C6I_DTEMIS, C6J.C6J_IT, C3S.C3S_CODIGO, "
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C6K.C6K_ALQPRD, C1J.C1J_FILIAL, C1J.C1J_CODIGO, SUM(C6J.C6J_QTDE) C6J_QTDE, SUM(C6J.C6J_QTDCAN) C6J_QTDCAN, "
	cSelect += " SUM( C6J.C6J_VLRITE ) C6J_VLRITE, SUM( C6J.C6J_VLDESC ) C6J_VLDESC,  SUM( C6J.C6J_VLCAN ) C6J_VLCAN, SUM ( C6J.C6J_VLRACR ) C6J_VLRACR, "
	cSelect += " SUM( C6K.C6K_VLRBC ) C6K_VLRBC, SUM( C6K.C6K_VLRTRB ) C6K_VLRTRB, SUM( C6K.C6K_VLISEN) C6K_VLISEN, SUM( C6K.C6K_VLOUT ) C6K_VLOUT	"	

	cJoin := RetSqlName( "C6G" ) + " C6G "
	cJoin += " LEFT JOIN " + RetSqlName( "C6I" ) + " C6I ON ( C6I.C6I_FILIAL = " + Iif( FWModeAccess( "C6I" , 3 ) == "C" , "'" + xFilial( "C6I" ) + "'" , "C6G.C6G_FILIAL" ) + " AND C6G.C6G_ID = C6I.C6I_ID AND C6G.C6G_DTMOV = C6I.C6I_DTMOV AND C6I.D_E_L_E_T_ = '' )   "
	cJoin += " LEFT JOIN " + RetSqlName( "C6J" ) + " C6J ON ( C6J.C6J_FILIAL = " + Iif( FWModeAccess( "C6J" , 3 ) == "C" , "'" + xFilial( "C6J" ) + "'" , "C6I.C6I_FILIAL" ) + " AND C6I.C6I_ID = C6J.C6J_ID AND C6I.C6I_DTMOV = C6J.C6J_DTMOV AND C6I.C6I_CMOD = C6J.C6J_CMOD AND C6I.C6I_CODSIT = C6J.C6J_CODSIT AND C6I.C6I_NUMDOC = C6J.C6J_NUMDOC AND C6I.C6I_DTEMIS = C6J.C6J_DTEMIS AND C6J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C6K" ) + " C6K ON ( C6K.C6K_FILIAL = " + Iif( FWModeAccess( "C6K" , 3 ) == "C" , "'" + xFilial( "C6K" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C6J.C6J_ID = C6K.C6K_ID AND C6J.C6J_DTMOV = C6K.C6K_DTMOV AND C6J.C6J_CMOD = C6K.C6K_CMOD AND C6J.C6J_CODSIT = C6K.C6K_CODSIT AND C6J.C6J_NUMDOC = C6K.C6K_NUMDOC AND C6J.C6J_DTEMIS = C6K.C6K_DTEMIS AND C6J.C6J_IT = C6K.C6K_IT AND C6K.D_E_L_E_T_ = '' )	     "        	
	cJoin += " LEFT JOIN " + RetSqlName( "C3S" ) + " C3S ON ( C3S.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C6K.C6K_FILIAL" ) + " AND C3S.C3S_ID = C6K.C6K_CODTRI AND C3S.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C1L" ) + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C1L.C1L_ID = C6J.C6J_IT  AND C1L.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C1J" ) + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C6J.C6J_FILIAL" ) + " AND C1J.C1J_ID  = C6J.C6J_UNDITE AND C1J.D_E_L_E_T_ = '' ) "

	cWhere := " C6G.C6G_DTMOV >= '" + DTOS( dDataIni ) + "' AND C6G.C6G_DTMOV <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C6G.C6G_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C6G.D_E_L_E_T_ = '' AND C3S.C3S_CODIGO IN ( '02', '04' ) "    
	
	cGroupBy := " C6G.C6G_FILIAL, C6G.C6G_DTMOV,  C6I.C6I_CMOD, C6I.C6I_CODSIT, C6I.C6I_NUMDOC, C6I.C6I_DTEMIS, C6J.C6J_IT, C3S.C3S_CODIGO, "
	cGroupBy += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C6K.C6K_ALQPRD, C1J.C1J_FILIAL, C1J.C1J_CODIGO "

	cOrderBy := " C1L_FILIAL, C1L_CODIGO, C6K_ALQPRD, C1J_FILIAL, C1J_CODIGO  " 	

//Movimentacao de Bloco C490 ( Consolidado) 				
ElseIf cAlias == "C400_7"   	

	cSelect := " C14.C14_CODIGO, C0Y.C0Y_CODIGO, C7E.C7E_ALIQ, C7E.C7E_VLOPR, C7E.C7E_VLBC, C7E.C7E_VL, C3R.C3R_FILIAL, C3R.C3R_CODIGO " 
 
	cJoin := RetSqlName( "C7E" ) + " C7E "
	cJoin += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C7E.C7E_FILIAL" ) + " AND C0Y.C0Y_ID = C7E.C7E_CFOP 	AND C0Y.D_E_L_E_T_ = '' ) "			
	cJoin += " LEFT JOIN " + RetSqlName( "C14" ) + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C7E.C7E_FILIAL" ) + " AND C14.C14_ID = C7E.C7E_CST 	AND C14.D_E_L_E_T_ = '' ) "				
	cJoin += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C7E.C7E_FILIAL" ) + " AND C3R.C3R_ID = C7E.C7E_CODOBS AND C3R.D_E_L_E_T_ = '' ) "			

	cWhere += " C7E.C7E_FILIAL = '" + aParam[1] + "' AND C7E.C7E_ID = '" + aParam[2] + "' AND C7E.C7E_DTMOV = '" + aParam[3] + "' AND "
	cWhere += " C7E.D_E_L_E_T_ = '' "

	cOrderBy := " C7E.C7E_ID"
	
	cOrderBy := " C14.C14_CODIGO, C0Y.C0Y_CODIGO, C7E.C7E_ALIQ "

//Movimentacao de Bloco C495(Consolidado) 	
ElseIf cAlias == "C400_8"

	cSelect := " C7H.C7H_FILIAL, C7H.C7H_DTMOVI, C1L.C1L_FILIAL, C1L.C1L_CODIGO, C7H.C7H_QTD, C7H.C7H_QTDCAN, C1J.C1J_FILIAL, C1J.C1J_CODIGO, " 
    cSelect += " C7H.C7H_ALIQ, C7H.C7H_VLITEM, C7H.C7H_VLDESC, C7H.C7H_VLCANC, C7H.C7H_VLACMO, C7H.C7H_VBCICM, C7H.C7H_VLICMS, C7H.C7H_VLISEN, "
	cSelect += " C7H.C7H_VLNT, C7H.C7H_VICMST, C7H.C7H_ITEM, C7H.C7H_UNID "

	cJoin := RetSqlName( "C7H" ) + " C7H "
	cJoin += " LEFT JOIN " + RetSqlName( "C1L" ) + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C7H.C7H_FILIAL" ) + " AND C1L.C1L_ID = C7H.C7H_ITEM AND C1L.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName( "C1J" ) + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C7H.C7H_FILIAL" ) + " AND C1J.C1J_ID = C7H.C7H_UNID AND C1J.D_E_L_E_T_ = '' ) "

	cWhere := " C7H.C7H_DTMOVI >= '" + DTOS( dDataIni ) + "' AND C7H.C7H_DTMOVI <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C7H.C7H_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C7H.D_E_L_E_T_ = ''

	cOrderBy := " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C7H.C7H_ALIQ, C1J.C1J_FILIAL, C1J.C1J_CODIGO "
	 	
//Movimentacao de Bloco C500	
ElseIf cAlias == "C500"
			
	cSelect := " C20.C20_FILIAL, C20.C20_CHVNF,  C20.C20_INDOPE, C20.C20_INDEMI, C20.C20_SERIE, C20.C20_SUBSER, C20.C20_NUMDOC, C20.C20_DTDOC, C20.C20_DTES, "
	cSelect += " C20.C20_VLDOC,  C20.C20_VLDESC, C20.C20_VLMERC, C20_VLRDA, C3S2.C3S_CODIGO, "
	cSelect += " C30.C30_VLOPER, C30.C30_NUMITE, C30.C30_QUANT, C30.C30_VLRITE, C30.C30_VLDESC, C30.C30_CODITE, C30.C30_TOTAL, "
	cSelect += " C35.C35_ALIQ, C35.C35_BASEQT, C35.C35_ALIQQT, C35.C35_VLRPAU, C35.C35_CODTRI, C35.C35_BASE, C35.C35_VALOR, C35_VLNT, C35_CST, C35.C35_REDBC, C35.C35_VLOUTR, " 
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C0Y.C0Y_CODIGO, " 
	cSelect += " C1O.C1O_FILIAL, C1O.C1O_CODIGO, C1H.C1H_FILIAL, C1H.C1H_CODPAR, C01.C01_CODIGO , C02.C02_CODIGO, "
	cSelect += " C1J.C1J_FILIAL, C1J.C1J_CODIGO, "
	cSelect += " C0L.C0L_CODIGO, C0N.C0N_CODIGO, C2E.C2E_TPLIG, C2E.C2E_VLTERC, C2E.C2E_VSERNT, C2E.C2E_VLFORN, C30.C30_ORIGEM, C0O.C0O_CODIGO "
		
	cJoin := RetSqlName("C20") + " C20 " 
	cJoin += " LEFT JOIN " + RetSqlName("C30") + " C30 ON ( C30.C30_FILIAL = " + Iif( FWModeAccess( "C30" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C20.C20_FILIAL" ) + " AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_  = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1O") + " C1O ON ( C1O.C1O_FILIAL = " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C30.C30_FILIAL" ) + " AND C1O.C1O_ID = C30.C30_CTACTB AND C1O.D_E_L_E_T_ = '' )  "
	cJoin += " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C30.C30_FILIAL" ) + " AND C0Y.C0Y_ID  = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1L") + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C30.C30_FILIAL" ) + " AND C1L.C1L_ID  = C30.C30_CODITE  AND C1L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C1J") + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C30.C30_FILIAL" ) + " AND C1J.C1J_ID  = C30.C30_UM AND C1J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C35") + " C35 ON ( C35.C35_FILIAL = " + Iif( FWModeAccess( "C35" , 3 ) == "C" , "'" + xFilial( "C35" ) + "'" , "C20.C20_FILIAL" ) + " AND C35.C35_CHVNF = C20.C20_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND "
	cJoin += " 												 C35.C35_CODTRI IN ( '000002','000004','000006','000007') AND C35.D_E_L_E_T_ = ' ' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C35.C35_FILIAL" ) + " AND C3S2.C3S_ID = C35.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName("C1H") + " C1H ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C20.C20_FILIAL" ) + " AND C01.C01_ID    = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C02") + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C20.C20_FILIAL" ) + " AND C02.C02_ID    = C20.C20_CODSIT AND C02.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C2E") + " C2E ON ( C2E.C2E_FILIAL = " + Iif( FWModeAccess( "C2E" , 3 ) == "C" , "'" + xFilial( "C2E" ) + "'" , "C20.C20_FILIAL" ) +	" AND C2E.C2E_CHVNF = C20.C20_CHVNF AND C2E.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0L") + " C0L ON ( C0L.C0L_FILIAL = " + Iif( FWModeAccess( "C0L" , 3 ) == "C" , "'" + xFilial( "C0L" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0L.C0L_ID    = C2E.C2E_CODCON AND C0L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0N") + " C0N ON ( C0N.C0N_FILIAL = " + Iif( FWModeAccess( "C0N" , 3 ) == "C" , "'" + xFilial( "C0N" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0N.C0N_ID    = C2E.C2E_GRPTEN AND C0N.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C0O") + " C0O ON ( C0O.C0O_FILIAL = " + Iif( FWModeAccess( "C0O" , 3 ) == "C" , "'" + xFilial( "C0O" ) + "'" , "C2E.C2E_FILIAL" ) + " AND C0O.C0O_ID = C2E.C2E_CODCON AND C0O.D_E_L_E_T_ = '' ) " 
	
	cWhere := " ((C20.C20_INDOPE = '0' AND C20.C20_DTES >= '" + DTOS(dDataIni) + "' AND C20.C20_DTES <='"  + DTOS(dDataFim) + "') OR "
	cWhere += " (C20.C20_INDOPE = '1' AND C20.C20_DTDOC >= '" + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='" + DTOS(dDataFim) + "')) "
	cWhere += " AND C20.C20_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C01.C01_CODIGO IN ( '06', '28', '29' )
	cWhere += " AND C20.D_E_L_E_T_ = '' "     	
    	
	cOrderBy := " C20_INDOPE, C20_INDEMI, C1H_CODPAR,  C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C30_NUMITE "
	
//Movimentacao de Bloco C600
ElseIf cAlias == "C600"
			
	cSelect := " C20.C20_FILIAL, C20.C20_CHVNF,  C20.C20_INDOPE, C20.C20_INDEMI, C20.C20_SERIE, C20.C20_SUBSER, C20.C20_NUMDOC, C20.C20_DTDOC, C20.C20_DTES, "
	cSelect += " C20.C20_VLDOC,  C20.C20_VLDESC, C20.C20_VLMERC, C20_VLRDA, C3S2.C3S_CODIGO, "
	cSelect += " C30.C30_VLOPER, C30.C30_NUMITE, C30.C30_QUANT, C30.C30_VLRITE, C30.C30_VLDESC, C30.C30_CODITE, C30.C30_TOTAL, "
	cSelect += " C35.C35_ALIQ, C35.C35_BASEQT, C35.C35_ALIQQT, C35.C35_VLRPAU, C35.C35_CODTRI, C35.C35_BASE, C35.C35_VALOR, C35_VLNT, C35_CST,   "
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C0Y.C0Y_CODIGO, " 
	cSelect += " C1O.C1O_FILIAL, C1O.C1O_CODIGO, C1H.C1H_FILIAL, C1H.C1H_CODPAR , C01.C01_CODIGO , C02.C02_CODIGO, C07.C07_CODIGO, "
	cSelect += " C1J.C1J_FILIAL, C1J.C1J_CODIGO, "
	cSelect += " C0L.C0L_CODIGO, C0N.C0N_CODIGO, C2E.C2E_TPLIG, C2E.C2E_VLTERC, C2E.C2E_VSERNT, C2E.C2E_VLFORN, C2E.C2E_CONS, C30.C30_ORIGEM, C09.C09_CODIGO "
		
	cJoin := RetSqlName("C20") + " C20 " 
	cJoin += " LEFT JOIN " + RetSqlName("C30") + " C30 ON ( C30.C30_FILIAL = " + Iif( FWModeAccess( "C30" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C20.C20_FILIAL" ) + " AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_  = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1O") + " C1O ON ( C1O.C1O_FILIAL = " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C30.C30_FILIAL" ) + " AND C1O.C1O_ID = C30.C30_CTACTB AND C1O.D_E_L_E_T_ = '' )  "
	cJoin += " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C30.C30_FILIAL" ) + " AND C0Y.C0Y_ID  = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1L") + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C30.C30_FILIAL" ) + " AND C1L.C1L_ID  = C30.C30_CODITE  AND C1L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C1J") + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C30.C30_FILIAL" ) + " AND C1J.C1J_ID  = C30.C30_UM AND C1J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C35") + " C35 ON ( C35.C35_FILIAL = " + Iif( FWModeAccess( "C35" , 3 ) == "C" , "'" + xFilial( "C35" ) + "'" , "C20.C20_FILIAL" ) + " AND C35.C35_CHVNF = C20.C20_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND "
	cJoin += " 												 C35.C35_CODTRI IN ( '000002', '000004', '000006', '000007' ) AND C35.D_E_L_E_T_ = ' ' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C35.C35_FILIAL" ) + " AND C3S2.C3S_ID = C35.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName("C1H") + " C1H ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C09") + " C09 ON ( C09.C09_FILIAL = " + Iif( FWModeAccess( "C09" , 3 ) == "C" , "'" + xFilial( "C09" ) + "'" , "C1H.C1H_FILIAL" ) + " AND C09.C09_ID    = C1H.C1H_UF AND C09.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C07") + " C07 ON ( C07.C07_FILIAL = " + Iif( FWModeAccess( "C07" , 3 ) == "C" , "'" + xFilial( "C07" ) + "'" , "C1H.C1H_FILIAL" ) + " AND C07.C07_UF    = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C20.C20_FILIAL" ) + " AND C01.C01_ID    = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C02") + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C20.C20_FILIAL" ) + " AND C02.C02_ID    = C20.C20_CODSIT AND C02.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C2E") + " C2E ON ( C2E.C2E_FILIAL = " + Iif( FWModeAccess( "C2E" , 3 ) == "C" , "'" + xFilial( "C2E" ) + "'" , "C20.C20_FILIAL" ) +	" AND C2E.C2E_CHVNF = C20.C20_CHVNF AND C2E.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0L") + " C0L ON ( C0L.C0L_FILIAL = " + Iif( FWModeAccess( "C0L" , 3 ) == "C" , "'" + xFilial( "C0L" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0L.C0L_ID    = C2E.C2E_CODCON AND C0L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0N") + " C0N ON ( C0N.C0N_FILIAL = " + Iif( FWModeAccess( "C0N" , 3 ) == "C" , "'" + xFilial( "C0N" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0N.C0N_ID    = C2E.C2E_GRPTEN AND C0N.D_E_L_E_T_ = '' ) "	
		
	cWhere := " ((C20.C20_INDOPE = '0' AND C20.C20_DTES >= '" + DTOS(dDataIni) + "' AND C20.C20_DTES <='"  + DTOS(dDataFim) + "') OR "
	cWhere += " (C20.C20_INDOPE = '1' AND C20.C20_DTDOC >= '" 		 + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='" + DTOS(dDataFim) + "')) AND "
	cWhere += " C20.C20_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C01.C01_CODIGO IN ( '06', '28', '29' ) "
	cWhere += " AND C20.C20_INDOPE = '1' "
	cWhere += " AND C20.D_E_L_E_T_ = '' "     	
    	
	cOrderBy := " C01_CODIGO, C07_CODIGO, C20_SERIE, C20_SUBSER, C0L_CODIGO, C20_DTDOC, C20_FILIAL, C20_CHVNF, C30_NUMITE "
	
//Movimentacao de Bloco C700
ElseIf cAlias == "C700"	  
    
	cSelect := " C20.C20_FILIAL, C20.C20_CHVNF,  C20.C20_INDOPE, C20.C20_INDEMI, C20.C20_SERIE, C20.C20_SUBSER, C20.C20_NUMDOC, C20.C20_DTDOC, C20.C20_DTES, C20.C20_MESTRE, C20.C20_CHVCOD, " "
	cSelect += " C20.C20_VLDOC,  C20.C20_VLDESC, C20.C20_VLMERC, C20_VLRDA, C3S2.C3S_CODIGO, "
	cSelect += " C30.C30_NUMITE, C30.C30_QUANT, C30.C30_VLRITE, C30.C30_VLDESC, C30.C30_CODITE, C30.C30_TOTAL, "
	cSelect += " C35.C35_ALIQ, C35.C35_BASEQT, C35.C35_ALIQQT, C35.C35_VLRPAU, C35.C35_CODTRI, C35.C35_BASE, C35.C35_VALOR, C35_VLNT, C35_CST,   "
	cSelect += " C1L.C1L_FILIAL, C1L.C1L_CODIGO, C0Y.C0Y_CODIGO, " 
	cSelect += " C1O.C1O_FILIAL, C1O.C1O_CODIGO, C1H.C1H_FILIAL, C1H.C1H_CODPAR, C01.C01_CODIGO , C02.C02_CODIGO, C07.C07_CODIGO, "
	cSelect += " C1J.C1J_FILIAL, C1J.C1J_CODIGO, "
	cSelect += " C0L.C0L_CODIGO, C0N.C0N_CODIGO, C2E.C2E_TPLIG, C2E.C2E_VLTERC, C2E.C2E_VSERNT, C2E.C2E_VLFORN, C2E.C2E_CONS, C09.C09_UF, C30.C30_ORIGEM "
		
	cJoin := RetSqlName("C20") + " C20 " 
	cJoin += " LEFT JOIN " + RetSqlName("C30") + " C30 ON ( C30.C30_FILIAL = " + Iif( FWModeAccess( "C30" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C20.C20_FILIAL" ) + " AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_  = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1O") + " C1O ON ( C1O.C1O_FILIAL = " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C30" ) + "'" , "C30.C30_FILIAL" ) + " AND C1O.C1O_ID = C30.C30_CTACTB AND C1O.D_E_L_E_T_ = '' )  "
	cJoin += " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C30.C30_FILIAL" ) + " AND C0Y.C0Y_ID  = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C1L") + " C1L ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "C30.C30_FILIAL" ) + " AND C1L.C1L_ID  = C30.C30_CODITE  AND C1L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C1J") + " C1J ON ( C1J.C1J_FILIAL = " + Iif( FWModeAccess( "C1J" , 3 ) == "C" , "'" + xFilial( "C1J" ) + "'" , "C30.C30_FILIAL" ) + " AND C1J.C1J_ID  = C30.C30_UM AND C1J.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C35") + " C35 ON ( C35.C35_FILIAL = " + Iif( FWModeAccess( "C35" , 3 ) == "C" , "'" + xFilial( "C35" ) + "'" , "C20.C20_FILIAL" ) + " AND C35.C35_CHVNF = C20.C20_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND "
	cJoin += " 												 C35.C35_CODTRI IN ( '000002', '000004', '000006', '000007' )AND C35.D_E_L_E_T_ = ' ' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C35.C35_FILIAL" ) + " AND C3S2.C3S_ID = C35.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "					
	cJoin += " LEFT JOIN " + RetSqlName("C1H") + " C1H ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C09") + " C09 ON ( C09.C09_FILIAL = " + Iif( FWModeAccess( "C09" , 3 ) == "C" , "'" + xFilial( "C09" ) + "'" , "C1H.C1H_FILIAL" ) + " AND C09.C09_ID    = C1H.C1H_UF AND C09.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C07") + " C07 ON ( C07.C07_FILIAL = " + Iif( FWModeAccess( "C07" , 3 ) == "C" , "'" + xFilial( "C07" ) + "'" , "C1H.C1H_FILIAL" ) + " AND C07.C07_UF    = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C20.C20_FILIAL" ) + " AND C01.C01_ID    = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C02") + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C20.C20_FILIAL" ) + " AND C02.C02_ID    = C20.C20_CODSIT AND C02.D_E_L_E_T_ = '' ) "
	cJoin += " LEFT JOIN " + RetSqlName("C2E") + " C2E ON ( C2E.C2E_FILIAL = " + Iif( FWModeAccess( "C2E" , 3 ) == "C" , "'" + xFilial( "C2E" ) + "'" , "C20.C20_FILIAL" ) +	" AND C2E.C2E_CHVNF = C20.C20_CHVNF AND C2E.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0L") + " C0L ON ( C0L.C0L_FILIAL = " + Iif( FWModeAccess( "C0L" , 3 ) == "C" , "'" + xFilial( "C0L" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0L.C0L_ID    = C2E.C2E_CODCON AND C0L.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C0N") + " C0N ON ( C0N.C0N_FILIAL = " + Iif( FWModeAccess( "C0N" , 3 ) == "C" , "'" + xFilial( "C0N" ) + "'" , "C2E.C2E_FILIAL" ) +	" AND C0N.C0N_ID    = C2E.C2E_GRPTEN AND C0N.D_E_L_E_T_ = '' ) "	
		
	cWhere := " ((C20.C20_INDOPE = '0' AND C20.C20_DTES >= '" + DTOS(dDataIni) + "' AND C20.C20_DTES <='"  + DTOS(dDataFim) + "') OR "
	cWhere += " (C20.C20_INDOPE = '1' AND C20.C20_DTDOC >= '" 		 + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='" + DTOS(dDataFim) + "')) "
	cWhere += " AND C20.C20_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C01.C01_CODIGO IN ( '06', '28' ) "
	cWhere += " AND C20.C20_INDOPE = '1' "
	cWhere += " AND C20.D_E_L_E_T_ = '' "     	
    	
	cOrderBy := " C01_CODIGO, C20_SERIE, C20_MESTRE, C20_CHVCOD, C20_FILIAL, C20_CHVNF, C30_NUMITE  "
	
//Movimentacao de Bloco C700 (Consolidado) 	
ElseIf cAlias == "C700_1"

    cSelect := " C7M.C7M_FILIAL, C7M.C7M_ID, C7M.C7M_CODMOD, C7M.C7M_NSER, C7M.C7M_NORDIN, C7M.C7M_NORDFI, C7M.C7M_DTDOCI, C7M.C7M_DTDOCF, C7M.C7M_NODCFI, C7M.C7M_CHVDIG, "
	cSelect += " C14.C14_CODIGO, C7N.C7N_CFOP, C7N.C7N_ALQICM, C7N.C7N_VLOPR, C7N.C7N_VLBCIC, C7N.C7N_VLICMS, C7N.C7N_VBCSTI,  C7N.C7N_VLSTIC, C7N.C7N_VLREBC, C7N.C7N_CODOBS, "
	cSelect += " C7O.C7O_UF, C7O.C7O_CFOP, C7O.C7O_CSTICM, C7O.C7O_ALQICM, C7O.C7O_VLBCIC, C7O.C7O_VLSTIC, "
	cSelect += " C0Y.C0Y_CODIGO, C01.C01_CODIGO, C09.C09_UF, C3R.C3R_FILIAL, C3R.C3R_CODIGO"
	

	cJoin := RetSqlName("C7M") + " C7M "
	cJoin += " LEFT JOIN " + RetSqlName("C7N") + " C7N ON ( C7N.C7N_FILIAL = " + Iif( FWModeAccess( "C7N" , 3 ) == "C" , "'" + xFilial( "C7N" ) + "'" , "C7M.C7M_FILIAL" ) + " AND C7N.C7N_ID  = C7M.C7M_ID AND C7N.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C7O") + " C7O ON ( C7O.C7O_FILIAL = " + Iif( FWModeAccess( "C7O" , 3 ) == "C" , "'" + xFilial( "C7O" ) + "'" , "C7M.C7M_FILIAL" ) + " AND C7O.C7O_ID  = C7N.C7N_ID AND C7O.C7O_ID = C7N.C7N_ID AND C7O.C7O_ID = C7M.C7M_ID AND C7O.C7O_CSTICM = C7N.C7N_CFOP AND C7O.C7O_CFOP = C7N.C7N_CFOP AND C7O.C7O_ALQICM = C7N.C7N_ALQICM AND C7O.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C7M.C7M_FILIAL" ) + " AND C0Y.C0Y_ID  = C7N.C7N_CFOP AND C0Y.D_E_L_E_T_ = '' ) "		
	cJoin += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C7M.C7M_FILIAL" ) + " AND C01.C01_ID  = C7M.C7M_CODMOD AND C01.D_E_L_E_T_ = '' ) "	
	cJoin += " LEFT JOIN " + RetSqlName("C09") + " C09 ON ( C09.C09_FILIAL = " + Iif( FWModeAccess( "C09" , 3 ) == "C" , "'" + xFilial( "C09" ) + "'" , "C7O.C7O_FILIAL" ) + " AND C09.C09_ID    = C7O.C7O_UF AND C09.D_E_L_E_T_ = '' ) "    
	cJoin += " LEFT JOIN " + RetSqlName("C14") + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C7N.C7N_FILIAL" ) + " AND C14.C14_ID    = C7N.C7N_CSTICM AND C14.D_E_L_E_T_ = '' ) "    
	cJoin += " LEFT JOIN " + RetSqlName("C3R") + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C7N.C7N_FILIAL" ) + " AND C3R.C3R_ID    = C7N.C7N_CODOBS AND C3R.D_E_L_E_T_ = '' ) "    

	cWhere := " C7M.C7M_DTMOV >= '" + DTOS(dDataIni) + "' AND C7M.C7M_DTMOV <='" + DTOS(dDataFim) + "' AND "
	cWhere += " C7M.C7M_FILIAL IN (" + cFilSelBc + ") "
	cWhere += " AND C01.C01_CODIGO IN ( '06', '28' ) "
	cWhere += " AND C7M.D_E_L_E_T_ = '' "
	
	cOrderBy := " C01.C01_CODIGO, C7M.C7M_NSER, C7M.C7M_NORDIN, C7M.C7M_FILIAL, C7M.C7M_CHVDIG "
	
//Movimentacao de Bloco C800		
ElseIf cAlias == "C800_1"     


	cSelect := "	C5S.C5S_FILIAL, C5T.C5T_ID, C0W.C0W_ECFFAB,	C02.C02_CODIGO, C5R.C5R_CODSIT, C5R.C5R_NUMCFE, C5R.C5R_DTDOC, SUM( C5R.C5R_VLCFE ) C5R_VLCFE, C5R.C5R_CNPJ, "
	cSelect += "	C5R.C5R_CPF, C5R.C5R_CHVCFE, SUM( C5R.C5R_VLDESC ) C5R_VLDESC, SUM( C5R.C5R_VLMERC ) C5R_VLMERC, "
	cSelect += "	SUM( C5R.C5R_VLOUTD ) C5R_VLOUTD , C0Y.C0Y_CODIGO, C5T.C5T_CODTRI,C5T.C5T_ALIQ, SUM( C5S.C5S_VLOPR ) C5S_VLOPR, C5S.C5S_CODIGO, C3R.C3R_FILIAL, C3R.C3R_CODIGO, "


	cSelect += "		(	SELECT                                                                                "
	cSelect += "				C03.C03_CODIGO                                                                     "
	cSelect += "				FROM                                                                               "
	cSelect += 						RetSqlName( "C5S" ) + " C5S2 " 
	
	cSelect += "				LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "																C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "										   						C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "										   						C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  				"					   
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C03" ) + " C03  ON ( C03.C03_FILIAL = " + Iif( FWModeAccess( "C03" , 3 ) == "C" , "'" + xFilial( "C03" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C03.C03_ID = C5T2.C5T_ORIGEM AND "
	cSelect += "									   						C03.D_E_L_E_T_ = '' ) "
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND "
	cSelect += "									   						 C3S2.D_E_L_E_T_ = '' ) "

	cSelect += "			WHERE			                                                         "
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '02' AND                "
	cSelect += "				C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''                  "
	cSelect += "		) ORIGEM,	      
	cSelect += "		(	SELECT                                                                                "
	cSelect += "				C14.C14_CODIGO                                                                     "
	cSelect += "				FROM                                                                                "
	cSelect += 						RetSqlName( "C5S" ) + " C5S2 " 
	
	cSelect += "				LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "																C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "										   						C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "										   						C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  				"					   
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C14" ) + " C14  ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C14.C14_ID = C5T2.C5T_CST AND "
	cSelect += "									   						C14.D_E_L_E_T_ = '' ) "
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND "
	cSelect += "									   						 C3S2.D_E_L_E_T_ = '' ) "

	cSelect += "			WHERE			                                                         "
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '02' AND                "
	cSelect += "				C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO  AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''                  "
	cSelect += "		) CSTICMS,	                                                                                                             "
		                                                                                                                                          
	cSelect += "		(	SELECT                                                                                                               "
	cSelect += "			SUM( C5T2.C5T_VALOR )                                                                                                "
	cSelect += "		FROM                                                                                                                     "
	cSelect += 				RetSqlName( "C5S" ) + " C5S2 "
	cSelect += "		LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "														 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "								   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "								   						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  "									   
	
	cSelect += "		LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND "
	cSelect += "								   						 C3S2.D_E_L_E_T_ = '' ) "
	
	cSelect += "		WHERE			                                                         "
	cSelect += "			C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "			C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "			C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '06' AND                "
	cSelect += "			C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''                  "
	cSelect += "		) VLPIS,	                                                                                                       "
	
	cSelect += "		(	SELECT                                                                                                          "
	cSelect += "				SUM( C5T2.C5T_VALOR )                                                                                       "
	cSelect += "			FROM                                                                                                            "
	cSelect += 					RetSqlName( "C5S" ) + " C5S2 "

	cSelect += "			LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "															 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "									   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "									   						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  				"				   

	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND "
	cSelect += "			 					   						     C3S2.D_E_L_E_T_ = '' ) "
	
	cSelect += "			WHERE			
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '07'	AND          "
	cSelect += "				C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''               "
	cSelect += "		) VLCOF,	"
		
	cSelect += "		(	SELECT   "
	cSelect += "				SUM( C5T2.C5T_VALOR ) "
	cSelect += "			FROM                      "
	cSelect += 					RetSqlName( "C5S" ) + " C5S2 "
	cSelect += "				LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "																 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "									   	   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND " 
	cSelect += "									       						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  			"						   
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "

	cSelect += "			WHERE			"
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '02' AND           "
	cSelect += "				C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''             "
	cSelect += "		) VLICMS,	

	cSelect += "		(	SELECT   "
	cSelect += "				SUM( C5T2.C5T_BASE ) "
	cSelect += "			FROM                      "
	cSelect += 					RetSqlName( "C5S" ) + " C5S2 "
	cSelect += "				LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "																 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "									   	   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND " 
	cSelect += "									       						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  			"						   
	
	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "

	cSelect += "			WHERE			"
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND C3S2.C3S_CODIGO = '02' AND           "
	cSelect += "				C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = ''             "
	cSelect += "		) BCICMS,			
	
	cSelect += "		(	SELECT "
	cSelect += "				SUM( C5T2.C5T_VALOR ) "
	cSelect += "			FROM                      "
	cSelect += 					RetSqlName( "C5S" ) + " C5S2 "

	cSelect += "			LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "															 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "									   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "									   						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  				 "					   

	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
   
	cSelect += "			WHERE	 "		
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND "
	cSelect += "				C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND "
	cSelect += "				C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND                                        "
	cSelect += "				C3S2.C3S_CODIGO = '08'	AND C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = '' "
	cSelect += "			) VLPISST,	"
		
	cSelect += "		(	SELECT       "
	cSelect += "				SUM( C5T2.C5T_VALOR ) "
	cSelect += "				FROM                  "
	cSelect += 						RetSqlName( "C5S" ) + " C5S2 "

	cSelect += "			LEFT JOIN " + RetSqlName( "C5T" ) + " C5T2 ON ( C5T2.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S2.C5S_FILIAL" ) + " AND C5T2.C5T_ID = C5S2.C5S_ID AND "
	cSelect += "															 C5T2.C5T_DTDOC = C5S2.C5S_DTDOC AND "
	cSelect += "									   						 C5T2.C5T_CODSIT = C5S2.C5S_CODSIT AND C5T2.C5T_NUMCFE = C5S2.C5S_NUMCFE AND "
	cSelect += "									   						 C5T2.C5T_CODIGO = C5S2.C5S_CODIGO AND C5T2.D_E_L_E_T_ = '' )  "
	cSelect += "										   

	cSelect += "			LEFT JOIN " + RetSqlName( "C3S" ) + " C3S2 ON ( C3S2.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S2.C3S_ID = C5T2.C5T_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
   
	cSelect += "			WHERE			"
	cSelect += "				C5S2.C5S_FILIAL = C5S.C5S_FILIAL AND C5S2.C5S_ID = C5S.C5S_ID AND C5S2.C5S_DTDOC = C5S.C5S_DTDOC AND C5S2.C5S_CODSIT = C5S.C5S_CODSIT AND "
	cSelect += "				C5S2.C5S_NUMCFE = C5S.C5S_NUMCFE AND C5T2.C5T_CODIGO = C5T.C5T_CODIGO AND C5T2.C5T_CFOP = C5T.C5T_CFOP AND C5T2.C5T_ORIGEM = C5T.C5T_ORIGEM AND "
	cSelect += "				C3S2.C3S_CODIGO = '09'	AND C5T2.C5T_CODTRI = C5T.C5T_CODTRI AND C5S2.C5S_CODIGO = C5S.C5S_CODIGO AND C5S2.C5S_CFOP = C5S.C5S_CFOP AND C5S2.C5S_ORIGEM = C5S.C5S_ORIGEM AND C5T2.C5T_CST = C5T.C5T_CST AND C5S2.D_E_L_E_T_ = '' "
	cSelect += "		) VLCOFST			"	
			
	
	cJoin := RetSqlName( "C5Q" ) + " C5Q "

	cJoin += " LEFT JOIN " + RetSqlName( "C5R" ) + " C5R ON ( C5R.C5R_FILIAL = " + Iif( FWModeAccess( "C5R" , 3 ) == "C" , "'" + xFilial( "C5R" ) + "'" , "C5Q.C5Q_FILIAL" ) + " AND C5R.C5R_ID = C5Q.C5Q_ID AND C5R.D_E_L_E_T_  = '' ) 	
	cJoin += " LEFT JOIN " + RetSqlName( "C5S" ) + " C5S ON ( C5S.C5S_FILIAL = " + Iif( FWModeAccess( "C5S" , 3 ) == "C" , "'" + xFilial( "C5S" ) + "'" , "C5R.C5R_FILIAL" ) + " AND C5S.C5S_ID = C5R.C5R_ID AND C5S.C5S_DTDOC = C5R.C5R_DTDOC AND "
	cJoin += " 							  					   C5S.C5S_CODSIT = C5R.C5R_CODSIT AND C5S.C5S_NUMCFE = C5R.C5R_NUMCFE AND "
	cJoin += " 							  					   C5S.D_E_L_E_T_ = '' )                                                 "
								  
	cJoin += " LEFT JOIN " + RetSqlName( "C5T" ) + " C5T ON ( C5T.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C5T.C5T_ID = C5S.C5S_ID AND C5T.C5T_DTDOC = C5S.C5S_DTDOC AND "
	cJoin += "												   C5T.C5T_CODSIT = C5S.C5S_CODSIT AND C5T.C5T_NUMCFE = C5S.C5S_NUMCFE AND "
	cJoin += "												   C5T.C5T_CODIGO = C5S.C5S_CODIGO AND C5T.D_E_L_E_T_ = '' )               "

	cJoin += " LEFT JOIN " + RetSqlName( "C02" ) + " C02 ON ( C02.C02_FILIAL = " + Iif( FWModeAccess( "C02" , 3 ) == "C" , "'" + xFilial( "C02" ) + "'" , "C5R.C5R_FILIAL" ) + " AND C02.C02_ID = C5R.C5R_CODSIT AND C02.D_E_L_E_T_ = '' )   "
	cJoin += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C0Y.C0Y_ID = C5S.C5S_CFOP AND C0Y.D_E_L_E_T_ = '' )     "                 	
	cJoin += " LEFT JOIN " + RetSqlName( "C0W" ) + " C0W ON ( C0W.C0W_FILIAL = " + Iif( FWModeAccess( "C0W" , 3 ) == "C" , "'" + xFilial( "C0W" ) + "'" , "C5Q.C5Q_FILIAL" ) + " AND C0W.C0W_ID = C5Q.C5Q_MODSAT AND C0W.D_E_L_E_T_ = '' ) 	
	cJoin += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C3R.C3R_ID = C5S.C5S_CODOBS AND C3R.D_E_L_E_T_ = '' ) "						

	cWhere := " C5R.C5R_DTDOC >= '" + DTOS( dDataIni ) + "' AND C5R.C5R_DTDOC <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C5Q.C5Q_FILIAL IN (" + cFilSelBc + ") AND "	
	cWhere += " C5Q.D_E_L_E_T_  = ''   "  
		        
	cGroupBy :=	" C0W.C0W_ECFFAB, C02.C02_CODIGO, C5R.C5R_CODSIT, C5R.C5R_NUMCFE, C5R.C5R_DTDOC, C5R.C5R_CNPJ, C5R.C5R_CPF, C5R.C5R_CHVCFE,    "
	cGroupBy +=	" C5S.C5S_FILIAL, C5S.C5S_ID, C5S.C5S_DTDOC, C5S.C5S_CODSIT, C5S.C5S_CODIGO, C5S.C5S_NUMCFE,   "
	cGroupBy +=	" C5T.C5T_ID, C5T.C5T_CODTRI, C5T.C5T_DTDOC, C5T.C5T_CODSIT, C5T.C5T_NUMCFE, C5T.C5T_CODIGO, C5T.C5T_CFOP, C5T.C5T_ORIGEM, "
	cGroupBy +=	" C5T.C5T_CODTRI, C5T.C5T_ALIQ, C0Y.C0Y_CODIGO, C3R.C3R_FILIAL, C3R.C3R_CODIGO, C5S.C5S_CFOP,C5S.C5S_ORIGEM,C5T.C5T_CST "
	
	cOrderBy := " C5T_ID, C5T_CODTRI, C02_CODIGO, C5R_NUMCFE, C5R_DTDOC, C5R_CNPJ, C5R_CPF, C5R_CHVCFE, CSTICMS, C0Y_CODIGO, C5T_ALIQ, C3R_FILIAL, C3R_CODIGO "
	
ElseIf cAlias == "C800_2"

	cSelect := "	C0W.C0W_ECFMOD, C0W.C0W_ECFFAB, C5R.C5R_DTDOC, C14.C14_CODIGO, C0Y.C0Y_CODIGO, C5T.C5T_ALIQ, C3S.C3S_CODIGO, C3R.C3R_FILIAL, C3R.C3R_CODIGO, C5T_NUMCFE, "
	cSelect += "	SUM( C5S.C5S_VLOPR ) C5S_VLOPR, SUM( C5T.C5T_BASE ) C5T_BASE, SUM( C5T.C5T_VALOR) C5T_VALOR, C03.C03_CODIGO  

	cJoin  := 	RetSqlName( "C5Q" ) + " C5Q "
	cJoin  += "	LEFT JOIN " + RetSqlName( "C5R" ) + " C5R ON ( C5R.C5R_FILIAL = " + Iif( FWModeAccess( "C5R" , 3 ) == "C" , "'" + xFilial( "C5R" ) + "'" , "C5Q.C5Q_FILIAL" ) + " AND C5R.C5R_ID = C5Q.C5Q_ID AND C5R.D_E_L_E_T_  = '' ) 	"

	cJoin  += " LEFT JOIN " + RetSqlName( "C5S" ) + " C5S ON ( C5S.C5S_FILIAL = " + Iif( FWModeAccess( "C5S" , 3 ) == "C" , "'" + xFilial( "C5S" ) + "'" , "C5R.C5R_FILIAL" ) + " AND C5S.C5S_ID = C5R.C5R_ID AND C5S.C5S_DTDOC = C5R.C5R_DTDOC AND "
	cJoin  += "					  								C5S.C5S_CODSIT = C5R.C5R_CODSIT AND C5S.C5S_NUMCFE = C5R.C5R_NUMCFE AND "
	cJoin  += "							 					    C5S.D_E_L_E_T_ = '' )               "
								  
	cJoin  += " LEFT JOIN " + RetSqlName( "C5T" ) + " C5T ON ( C5T.C5T_FILIAL = " + Iif( FWModeAccess( "C5T" , 3 ) == "C" , "'" + xFilial( "C5T" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C5T.C5T_ID = C5S.C5S_ID AND C5T.C5T_DTDOC = C5S.C5S_DTDOC AND "
	cJoin  += "													C5T.C5T_CODSIT = C5S.C5S_CODSIT AND C5T.C5T_NUMCFE = C5S.C5S_NUMCFE AND "
	cJoin  += "													C5T.C5T_CODIGO = C5S.C5S_CODIGO AND C5T.D_E_L_E_T_ = '' ) " 
	
	cJoin  += " LEFT JOIN " + RetSqlName( "C3S" ) + " C3S ON ( C3S.C3S_FILIAL = " + Iif( FWModeAccess( "C3S" , 3 ) == "C" , "'" + xFilial( "C3S" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C3S.C3S_ID = C5T.C5T_CODTRI AND  C3S.C3S_CODIGO = '02' AND C3S.D_E_L_E_T_ = '' ) 						  "

	cJoin  += " LEFT JOIN " + RetSqlName( "C0W" ) + " C0W ON ( C0W.C0W_FILIAL = " + Iif( FWModeAccess( "C0W" , 3 ) == "C" , "'" + xFilial( "C0W" ) + "'" , "C5Q.C5Q_FILIAL" ) + " AND C0W.C0W_ID = C5Q.C5Q_MODSAT AND C0W.D_E_L_E_T_ = '' )      "

	cJoin  += " LEFT JOIN " + RetSqlName( "C14" ) + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C5T.C5T_FILIAL" ) + " AND C14.C14_ID = C5T.C5T_CST AND C14.D_E_L_E_T_ = '' )    "

	cJoin  += " LEFT JOIN " + RetSqlName( "C03" ) + " C03 ON ( C03.C03_FILIAL = " + Iif( FWModeAccess( "C03" , 3 ) == "C" , "'" + xFilial( "C03" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C03.C03_ID = C5S.C5S_ORIGEM AND C03.D_E_L_E_T_ = '' )    "

	cJoin  += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C0Y.C0Y_ID = C5S.C5S_CFOP AND C0Y.D_E_L_E_T_ = '' )    "                   

	cJoin  += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C5S.C5S_FILIAL" ) + " AND C3R.C3R_ID = C5S.C5S_CODOBS AND C3R.D_E_L_E_T_ = '' )  "
	
	cWhere := " C5R.C5R_DTDOC >= '" + DTOS( dDataIni ) + "' AND C5R.C5R_DTDOC <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C5Q.C5Q_FILIAL IN (" + cFilSelBc + ") AND "	
	cWhere += " C5Q.D_E_L_E_T_  = ''   "
	
	cGroupBy := " C0W.C0W_ECFMOD, C0W.C0W_ECFFAB, C5R.C5R_DTDOC, C14.C14_CODIGO, C0Y.C0Y_CODIGO, C5T.C5T_ALIQ, C3S.C3S_CODIGO, C3R.C3R_FILIAL, C3R.C3R_CODIGO, C5T_NUMCFE, C03.C03_CODIGO	"
	
	cOrderBy := " C0W_ECFMOD, C0W_ECFFAB, C5R_DTDOC, C14_CODIGO, C0Y_CODIGO, C5T_ALIQ, C3R_FILIAL, C3R_CODIGO "
	
ElseIf cAlias == "C800_3"

	cSelect := " C01.C01_CODIGO, C7P.C7P_NRSAT, C7P.C7P_DTDOC, C7P.C7P_DOCINI, C7P.C7P_DOCFIM,  "
	cSelect += " C7T.C7T_ALQICM, C7T.C7T_VLOPR, C7T.C7T_VLBCIC, C7T.C7T_VLICMS, C3R.C3R_CODIGO CODOBS, C0Y.C0Y_CODIGO CFOP, C14.C14_CODIGO CSTICMS, C03.C03_CODIGO  "

	cJoin  := 	RetSqlName( "C7P" ) + " C7P "
	cJoin  += " LEFT JOIN " + RetSqlName( "C7T" ) + " C7T ON ( C7T.C7T_FILIAL = " + Iif( FWModeAccess( "C7T" , 3 ) == "C" , "'" + xFilial( "C7T" ) + "'" , "C7P.C7P_FILIAL" ) + " AND C7T.C7T_ID = C7P.C7P_ID AND C7T.D_E_L_E_T_ = '' ) 						  "
	cJoin  += " LEFT JOIN " + RetSqlName( "C14" ) + " C14 ON ( C14.C14_FILIAL = " + Iif( FWModeAccess( "C14" , 3 ) == "C" , "'" + xFilial( "C14" ) + "'" , "C7T.C7T_FILIAL" ) + " AND C14.C14_ID = C7T.C7T_CSTICM AND C14.D_E_L_E_T_ = '' )    "
	cJoin  += " LEFT JOIN " + RetSqlName( "C0Y" ) + " C0Y ON ( C0Y.C0Y_FILIAL = " + Iif( FWModeAccess( "C0Y" , 3 ) == "C" , "'" + xFilial( "C0Y" ) + "'" , "C7T.C7T_FILIAL" ) + " AND C0Y.C0Y_ID = C7T.C7T_CFOP AND C0Y.D_E_L_E_T_ = '' )    "                   	
	cJoin  += " LEFT JOIN " + RetSqlName( "C03" ) + " C03 ON ( C03.C03_FILIAL = " + Iif( FWModeAccess( "C03" , 3 ) == "C" , "'" + xFilial( "C03" ) + "'" , "C7T.C7T_FILIAL" ) + " AND C03.C03_ID = C7T.C7T_ORIMER AND C03.D_E_L_E_T_ = '' )    "                   	
	cJoin  += " LEFT JOIN " + RetSqlName( "C01" ) + " C01 ON ( C01.C01_FILIAL = " + Iif( FWModeAccess( "C01" , 3 ) == "C" , "'" + xFilial( "C01" ) + "'" , "C7P.C7P_FILIAL" ) + " AND C01.C01_ID = C7P.C7P_CODMOD AND C01.D_E_L_E_T_ = '' )    "                   	
	cJoin  += " LEFT JOIN " + RetSqlName( "C3R" ) + " C3R ON ( C3R.C3R_FILIAL = " + Iif( FWModeAccess( "C3R" , 3 ) == "C" , "'" + xFilial( "C3R" ) + "'" , "C7T.C7T_FILIAL" ) + " AND C3R.C3R_ID = C7T.C7T_CODOBS AND C3R.D_E_L_E_T_ = '' )    "                   	
	
	cWhere := " C7P.C7P_DTDOC >= '" + DTOS( dDataIni ) + "' AND C7P.C7P_DTDOC <='" + DTOS( dDataFim ) + "' AND "
	cWhere += " C7P.C7P_FILIAL IN (" + cFilSelBc + ") AND "	
	cWhere += " C7P.D_E_L_E_T_  = ''   "
                                                                                
	cGroupBy := " C01.C01_CODIGO, C7P.C7P_NRSAT, C7P.C7P_DTDOC, C7P.C7P_DOCINI, C7P.C7P_DOCFIM, " 
	cGroupBy += " C7T.C7T_ALQICM, C7T.C7T_VLOPR, C7T.C7T_VLBCIC, C7T.C7T_VLICMS, C3R.C3R_CODIGO, C0Y.C0Y_CODIGO, C14.C14_CODIGO, C03.C03_CODIGO  "

	cOrderBy := " C01.C01_CODIGO, C7P.C7P_NRSAT, C7P.C7P_DTDOC, C14.C14_CODIGO, C0Y.C0Y_CODIGO, C7T.C7T_ALQICM "
EndIf

//Execucao da Query
cSelect  := "%" + cSelect  + "%" 
cWhere   := "%" + cWhere   + "%"
cWhere02 := "%" + cWhere02 + "%"
cWhere03 := "%" + cWhere03 + "%"
cWhere04 := "%" + cWhere04 + "%"
cWhere05 := "%" + cWhere05 + "%"
cWhere06 := "%" + cWhere06 + "%"
cJoin    := "%" + cJoin    + "%"
cUnion   := "%" + cUnion   + "%"
cUnion02 := "%" + cUnion02 + "%"
cUnion03 := "%" + cUnion03 + "%"
cUnion04 := "%" + cUnion04 + "%"
cUnion05 := "%" + cUnion05 + "%"
cOrderBy := "%" + cOrderBy + "%" 
cGroupBy := "%" + cGroupBy + "%"

If cUnion == "%%"
	If cWhere == "%%"  
		BeginSql Alias cAliasQry                						
		    SELECT 
			    %Exp:cSelect%	
		    FROM  
			    %Exp:cJoin%
		EndSql                                                     			    
	ElseIf cGroupBy == "%%"	
		BeginSql Alias cAliasQry                
		    SELECT							
			    %Exp:cSelect%
		    FROM 
		        %Exp:cJoin%
			WHERE
				%Exp:cWhere%    
			ORDER BY
				%Exp:cOrderBy%		
		EndSql             
	Else
		BeginSql Alias cAliasQry                
		    SELECT							
			    %Exp:cSelect%
		    FROM 
		        %Exp:cJoin%
			WHERE
				%Exp:cWhere% 
			GROUP BY
				%Exp:cGroupBy%   
			ORDER BY
				%Exp:cOrderBy%		
		EndSql             	                                        
	EndIf
Else 
	If cUnion02 == "%%"      
	   	BeginSql Alias cAliasQry                
		    SELECT							
			    %Exp:cSelect%
		    FROM              	
		        %Exp:cJoin%
			WHERE
				%EXP:cWhere% 
			UNION
			SELECT
				%Exp:cSelect%	 
			FROM
				%Exp:cUnion%
			WHERE
				%EXP:cWhere02%    
			ORDER BY
				%Exp:cOrderBy%	
		EndSql
	Else    
		
		If cUnion03 == "%%"
			BeginSql Alias cAliasQry     
			    SELECT							
				    %Exp:cSelect%
			    FROM              	
			        %Exp:cJoin%
				WHERE
					%EXP:cWhere% 
				UNION
				SELECT
					%Exp:cSelect%	 
				FROM
					%Exp:cUnion%
				WHERE
					%EXP:cWhere02%  		           
				UNION
			    SELECT							
				    %Exp:cSelect%
			    FROM              	
			        %Exp:cUnion02%
				WHERE
					%EXP:cWhere03% 				
				ORDER BY
					%Exp:cOrderBy%					
			EndSql                                                  
		Else
			If cUnion04 == "%%"
				BeginSql Alias cAliasQry     
				    SELECT							
					    %Exp:cSelect%
				    FROM              	
				        %Exp:cJoin%
					WHERE
						%EXP:cWhere% 
					UNION
					SELECT
						%Exp:cSelect%	 
					FROM
						%Exp:cUnion%
					WHERE
						%EXP:cWhere02%  		           
					UNION
				    SELECT							
					    %Exp:cSelect%
				    FROM              	
				        %Exp:cUnion02%
					WHERE
						%EXP:cWhere03% 				
					UNION
				    SELECT							
					    %Exp:cSelect%
				    FROM              	
				        %Exp:cUnion03%
					WHERE
						%EXP:cWhere04% 							
					ORDER BY
						%Exp:cOrderBy%					
				EndSql                                                  		
			Else
				If cUnion05 == "%%"
					BeginSql Alias cAliasQry     
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cJoin%
						WHERE
							%EXP:cWhere% 
						UNION
						SELECT
							%Exp:cSelect%	 
						FROM
							%Exp:cUnion%
						WHERE
							%EXP:cWhere02%  		           
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion02%
						WHERE
							%EXP:cWhere03% 				
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion03%
						WHERE
							%EXP:cWhere04% 							
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion04%
						WHERE
							%EXP:cWhere05% 								
						ORDER BY
							%Exp:cOrderBy%					
					EndSql                                                  					
				Else
					BeginSql Alias cAliasQry     
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cJoin%
						WHERE
							%EXP:cWhere% 
						UNION
						SELECT
							%Exp:cSelect%	 
						FROM
							%Exp:cUnion%
						WHERE
							%EXP:cWhere02%  		           
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion02%
						WHERE
							%EXP:cWhere03% 				
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion03%
						WHERE
							%EXP:cWhere04% 							
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion04%
						WHERE
							%EXP:cWhere05% 								
						UNION
					    SELECT							
						    %Exp:cSelect%
					    FROM              	
					        %Exp:cUnion05%
						WHERE
							%EXP:cWhere06% 															
						ORDER BY
							%Exp:cOrderBy%					
					EndSql     				
				EndIf
			EndIf			
		EndIf
	EndIf
EndIf

//Caso seja solicitado apenas o totalizador eu retorno a quantidade 
//de registros encontrados e em seguida fecho o alias utilizado     
DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())    

Return ( nRet )  
