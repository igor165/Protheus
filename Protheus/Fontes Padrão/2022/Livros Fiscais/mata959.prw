#INCLUDE "mata959.ch"
#include "FIVEWIN.CH"
 
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³MATA959   ºAutor  ³Angelica N. Rabelo  º Data ³  03/03/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Rotina que vai realizar o calculo/controle do Credito ICMS  º±±
//±±º          ³Nao Destacado conf. art. 271 do RICMS                       º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍdÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ Livros Fiscais                                             º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
//±±º Variaveis utilizadas para parametros                         		    º±±         
//±±ºÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
//±±º mv_par01  // Data de ? 	     										º±±
//±±º mv_par02  // Data Ate ?                                       		º±±     
//±±º mv_par03  // Reprocessa tudo ?(Nao/Sim)                               º±±      
//±±º mv_par04  // Considera Transferencia de filias ?(Nao/Sim)             º±±      
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
           		           
Function MATA959(lAutomato)      

Local cText1 :=	STR0016 // "Esta rotina irá calcular o valor do crédito do ICMS a ser apropriado nos termos do artigo"                                                                                                                                                                                                                                                                                                                                                                                                                     
Local cText2 :=	STR0017 // "271 do Regulamento do ICMS do estado de São Paulo de 30/11/2000."                                                                                                                                                                                                                                                                                                                                                                                                                                                      
Local cText3 :=	STR0018 // "Atenção!!!"
Local cText4 :=	STR0019 // "Este crédito se aplica aos contribuintes do ICMS do estado de São Paulo e"                                                                                                                                                                                                                                                                                                                                                                                                                                      
Local cText5 :=	STR0020 // "e dentre estes os que se subsumam ao previsto no artigo mencionado" 
Local cText6 :=	STR0036 // "Controle para Restituição do ICMS-ST."                                                                                                                                                                                                                                                                                                                                                                                                                     
Local cCadastro := STR0021 //"Cálculo Créd.ICMS ST"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca 	:= 0
Local lICMDes 	:= GetNewPar("MV_ICMS271",.F.)// Indica se havera o calculo do CREDITO ICMS
Local IResicmst := GetNewPar("MV_ICMST23",.F.)
Local lMvestado	:= SuperGetMv("MV_ESTADO") 

Default lAutomato := .F.

Private cPerg   :=	"MTA959"      	                              	            

if lMvestado == "SP" .And. !lICMDes  
	Alert(STR0028) //"Para utilizacao habilitar parametros da rotina segundo Boletim tecnico Calculo Credito ICMS conf. Art.271 RICMS/SP"      	                        
	Return
Elseif lMvestado <> "SP" .And. !IResicmst
	Alert(STR0035) 
	Return
endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro indica se vai haver o controle do CREDITO.NAO DESTACADO ICMS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

While .T.

	Do Case
		Case lMvestado == "SP"
			AADD(aSays,OemToAnsi( ctext1 ) )
			AADD(aSays,OemToAnsi( cText2 ) )
			AADD(aSays,OemToAnsi( cText3 ) )
			AADD(aSays,OemToAnsi( cText4 ) )
			AADD(aSays,OemToAnsi( cText5 ) )
		OtherWise
			AADD(aSays,OemToAnsi( ctext6 ) )
	EndCase
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	
	If lAutomato
		nOpca := 1
	Else
		FormBatch( cCadastro, aSays, aButtons )
	EndIf
 	
 	Do Case
		Case nOpca ==1
			Processa({||CalcCred(lMVEstado,lAutomato)})
		Case nOpca==3
			Pergunte(cPerg,.t.)
			Loop
	EndCase
	Exit

EndDo    

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Funcao    ³CalcCred  ³ Autor ³Angelica N. Rabelo     ³ Data ³03/03/2009 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Desc.     ³Efetua todos os calculos baseados nos movimentos Entrada,    ³±±
//±±³Desc.     ³Saidas a fim de apurar valor do credito do ICMS ST		     ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³Nenhum                                                       ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³ 															 ³±±
//±±³          |						                                     ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß	
Function CalcCred(cMVEstado,lAutomato)

#IFDEF TOP
	Local cFilBack	:= cFilAnt
	Local nForFilial:= 0
	Local aFilsCalc	:= MatFilCalc( (MV_PAR05 == 1), , , (MV_PAR05 == 1 .and. MV_PAR06 == 1), , 2 )
#ENDIF
	Local lProc	:=	.F.
	
	Default lAutomato	 := .F.
	
	Private nAlqInt := SuperGetMv("MV_ICMPAD")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente ira executar caso o cliente tenha optado atraves do parametro MV_ICMS271 por utilizar o Calc.Cred.ICMS Nao Destacado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If month(mv_par01) <> month(mv_par02)
		Alert(STR0030)
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VerIfica se eh Reprocessamento Total ('2') ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If mv_par03 == 2
		
		If lAutomato
			lProc := .T.
		ElseIf MsgYesNo(STR0003,STR0004)               //"Deseja realmente reprocessar tudo ?","ATENCAO !!!!"
			lProc := .T.
		EndIf
		
		If lProc
			MsAguarde({||EstCDM(mv_par01,mv_par02,aFilsCalc)},STR0005,STR0006)					//"Reprocessando toda movimentacao do periodo selecionado","Aguarde...."
		Else
			Return
		EndIf
		
	EndIf

#IFDEF TOP	
For nForFilial := 1 to Len( aFilsCalc )
	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf	
	cFilAnt := aFilsCalc[ nForFilial, 2 ]
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CREDCAT17 (somente ira incluir em CDM os itens de SFK ainda nao existentes na mesma) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    	    	
    MsAguarde({||CredCat17(mv_par01,mv_par02,cMVEstado)},STR0007,STR0006) //"Processando Saldos iniciais CAT 17","Aguarde...."
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CREDICMSD1 (somente ira incluir em CDM as NF's Entrada ainda nao existentes na mesma)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde({||CredICMSD1(mv_par01,mv_par02,cMVEstado)},STR0008,STR0006)//"Processando Documentos de Entrada",'Aguarde...."	        	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³DEVCOMPR (vai checar as Devol.Compras para abater SALDOS gerados na CDM              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	             
    MsAguarde({||DEVCOMPR(mv_par01,mv_par02,cMVEstado)},STR0022,STR0006)  //"Processando Devolucoes de Compras",'Aguarde...."	        		            	    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³AJUSTCPR (vai ajustar BASE ICMS para NF's Entrada que tiveram COMPL.PRECOS   )       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde({||AJUSTCPR(mv_par01,mv_par02,cMVEstado)},STR0027,STR0006)  //"Processando Complementos Precos","Aguarde...."	               	    	     	  	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³AJUSTRE4(vai reajustar SALDOS das NF's Entr.que tiveram seu Saldo diminuido devido Requisicoes (RE4)³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde({||AJUSTRE4(mv_par01,mv_par02,cMVEstado)},STR0031,STR0006)  //"Processando Ajuste Transferencias-Requisicoes","Aguarde...."	               	    	     	  	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³CREDICMSD2 (somente ira incluir em CDM as NF's Saida ainda nao existentes na mesma)  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	MsAguarde({||CredICMSD2(mv_par01,mv_par02,cMVEstado)},STR0009,STR0006)//"Processando Documentos de Saida","Aguarde...."	               
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³DEVVENDAS (vai checar as Devol.Vendas para estornar as associacoes feitas, i.e.,     |
    //|estornar o CREDITO ja calculado e apresentar esse valor na APURACAO ICMS             |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	             
   	MsAguarde({||DEVVENDAS(mv_par01,mv_par02,cMVEstado)},STR0023,STR0006) //"Processando Devolucoes de Vendas",'Aguarde...."	        		            		

#IFDEF TOP
Next
cFilAnt	:= cFilBack
#ENDIF

	MsgInfo(STR0029) //"Processamento Concluido !"	    	
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Funcao    ³CredCat17 ³ Autor ³Angelica N. Rabelo     ³ Data ³03/03/2009 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Desc.     ³Funcao de processamento dos saldos existentes na  SFK (CAT17)³±±
//±±³          |e Saldos de Transferencias						             ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³Nenhum                                                       ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³ dDtIni/dDtFim:periodo a ser considerados para gerar os      ³±±
//±±³          |               Saldos ST (SFK) 							     ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
Static Function CredCat17(dDtIni,dDtFim,cMVEstado)

Local cAliasSFK:= "SFK"
Local lQuery   := .f.
Local aAreaAtu := GetArea()
		                          
#IFDEF TOP
	
	If TcSrvType()<>"AS/400"							          		 
 		cFiltro := "%"	
		If cMVEstado <> "SP"// "RS/SC/PR/GO/BA/ES"
			cFiltro += " SB1.B1_CRICMST= '" +%Exp:("1")% +"'  	
		Else
			cFiltro += " SB1.B1_CRICMS= '" +%Exp:("1")% +"'	
		EndIf		
		cFiltro += "%"
    	lQuery    :=.t.   
        cAliasSFK := GetNextAlias()   
    	
    	BeginSql Alias cAliasSFK
			 COLUMN FK_DATA AS DATE
	    	 SELECT SFK.FK_FILIAL, SFK.FK_DATA, SFK.FK_PRODUTO, SFK.FK_QTDE, SFK.FK_BRICMS,
		    	    SFK.FK_BASEICM, SFK.FK_AICMS, SFK.FK_TRFENT, SFK.FK_TRFSAI
	    	 FROM %table:SFK% SFK, %table:SB1% SB1
	    	 WHERE SFK.FK_FILIAL = %xFilial:SFK% AND	               
	    	       SFK.FK_DATA >= %Exp:dDtIni% AND
	    	       SFK.FK_DATA <= %Exp:dDtFim% AND    	    	      
	    	       SFK.FK_SALDO = '1' AND
	    		   SFK.%NotDel% AND	          		   
	    		   SB1.B1_COD = SFK.FK_PRODUTO AND
	               SB1.%NotDel% AND
				  (%Exp:cFiltro%)
		EndSql
        		
		dbSelectArea(cAliasSFK)         
		 
	Else
		                  
#ENDIF 
	                    	
	  cSFK :=	CriaTrab(Nil,.F.)
	  cChave	:=  SFK->(IndexKey())
	  cCondicao := "FK_FILIAL == '" + xFilial("SFK") + "' .AND. " 
  	  cCondicao += "dtos(FK_DATA) >= '" + dtos(dDtIni) + "' .AND. "	  	  	  
	  cCondicao += "dtos(FK_DATA) <= '" + dtos(dDtFim) + "' .AND. "
	  cCondicao += "FK_SALDO == '1'"

	  IndRegua(cAliasSFK,cSFK,cChave,,cCondicao,STR0010) //"Selecionado registros"  	  	  
  	  
	  #IFNDEF TOP
		DbSetIndex(cSFK+OrdBagExt())
	  #ENDIF 
	  dbselectarea(cAliasSFK)               
	  (cAliasSFK)->(dbGotop())			
    
#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())                	                       	    	                                      

While (cAliasSFK)->(!Eof())  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra apenas aqueles Produtos/TES configurados para tal operacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !lQuery    
	   If cMVEstado <> "SP" // $ "RS/SC/PR/GO/BA/ES" 
		   SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))				
		   if SB1->B1_CRICMST<>'1'  
			  (cAliasSFK)->(dbSkip())
			  Loop			
		   endif
	   Else
		   SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))				
		   If SB1->B1_CRICMS<>'1'  
			  (cAliasSFK)->(dbSkip())
			  Loop			
		   Endif	   
	   Endif	  	  	    
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RECENTCDM : Funcao que vai gerar registro na tabela CDM com o Saldo ST cadastrado em SFK     |
	//|            (Livros Fiscais) e Saldos de Transferencias tbme cadastrados na SFK              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (cAliasSFK)->FK_QTDE<>0 // Eh saldo CAT
       (cAliasSFK)->(RecEntCDM(Padr('000000',Len(CDM->CDM_DOCENT)),Padr("CAT",TamSx3("CDM_SERIEE")[1]),lastday(FK_DATA),lastday(FK_DATA),;
	                 Space(Len(CDM->CDM_FORNEC)),	Space(Len(CDM->CDM_LJFOR)),StrZero(1,Len(CDM->CDM_ITENT)),;
	                 FK_PRODUTO,FK_QTDE,FK_BASEICM,0,SFK->FK_AICMS,'  ',Space(Len(CDM->CDM_NSEQE)),FK_BRICMS,;
	                 FK_TRFENT,FK_TRFSAI))
    endif
     
    if (cAliasSFK)->FK_TRFENT<>0 // Tambem possui saldo Transferencias - Entradas   
       (cAliasSFK)->(RecEntCDM(Padr('000000',Len(CDM->CDM_DOCENT)),Padr("CAT",TamSx3("CDM_SERIEE")[1]),lastday(FK_DATA),lastday(FK_DATA),;
	                 Space(Len(CDM->CDM_FORNEC)),	Space(Len(CDM->CDM_LJFOR)),StrZero(1,Len(CDM->CDM_ITENT)),;
	                 FK_PRODUTO,0,FK_BASEICM,0,SFK->FK_AICMS,'  ',Space(Len(CDM->CDM_NSEQE)),FK_BRICMS,;
	                 FK_TRFENT,FK_TRFSAI))        		    			
    endif
    	                 
	(cAliasSFK)->(dbSkip())   
	
EndDo

(cAliasSFK)->(dbCloseArea())

RestArea(aAreaAtu)

Return       

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Funcao    ³EstCDM    ³ Autor ³Angelica N. Rabelo     ³ Data ³03/03/2009 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Desc.     ³Estorna TODOS os registros da tabela CDM 				     ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³Nenhum                                                       ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function EstCDM(dDtIni,dDtFim,aFilsCalc) 

#IFDEF TOP	
Local cFilBack	:= cFilAnt                                        
Local nForFilial:= 0
#ENDIF
Default dDtIni := CtoD("")
Default aFilsCalc	:= MatFilCalc(.F.)

#IFDEF TOP	
For nForFilial := 1 to Len( aFilsCalc )
	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf	
	cFilAnt := aFilsCalc[ nForFilial, 2 ]
#ENDIF

    dbSelectArea("CDM")				  
    dbGoTop()
	Do while !eof()      
		If !Empty(dDtIni) .And. CDM->CDM_DTENT >= dDtIni .And. CDM->CDM_DTENT <= dDtFim .and. xfilial("CDM")==CDM->CDM_FILIAL
		   RecLock("CDM",.F.)
		   dbDelete()		
		   MsUnlock()
		   FkCommit()                    
		   dbSelectArea("CDM")				  
	   EndIf
	   dbSkip()
	Enddo   

#IFDEF TOP   
Next
cFilAnt	:= cFilBack
#ENDIF
Return                                                    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡„o    ³ RecEntCDM  ³Autor  ³ Angelica N. Rabelo    ³ Data ³ 03/03/09 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡„o ³ Funcao de Gravacao da tabela CDM c/ Saldos Iniciais ST (SFK) ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³ cDoc        - Numero do Documento (fixo string 000000)       ³±±
//±±³          ³ cSerie      - Serie do Documento (fixo string CAT)			  ³±±
//±±³          ³ dEmissao    - Data Saldo ST (SFK)							  ³±±
//±±³          ³ dDtDigi     - Data Saldo ST (SFK)		                      ³±±
//±±³          ³ cFornec     - brancos 										  ³±±
//±±³          ³ cLoja       - brancos                                        ³±±
//±±³          ³ cItem       - 0001     		                              ³±±
//±±³          ³ cProduto    - Codigo do Produto                              ³±±
//±±³          ³ nQtd        - Quantidade Saldo	                              ³±±
//±±³          ³ nBase       - zeros	                                      ³±±
//±±³          ³ nICMS       - zeros	                                      ³±±
//±±³          ³ nAliq       - zeros					                      ³±±
//±±³          ³ cUF         - brancos						                  ³±±
//±±³          ³ cNumSeq     - Sequencia de Movimento (DOCSEQ)                ³±±
//±±³          ³ nBsRet      - Base ICMS 									  ³±±
//±±³          ³ nTrfEnt     - Total ENTRADAS provenientes Transf.(DESTINO)   ³±±
//±±³          ³ nTrfSai     - Total SAIDAS provenientes Transf.(ORIGEM)      ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³ NIL                                                          ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Uso       ³ Controle de Credito de ICMS nao destacado                    ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
       
Static Function RecEntCDM(cDoc,cSerie,dEmissao,dDtDigi,cFornec,cLoja,cItem,cProduto,nQtd,nBase,nIcms,nAliq,cUf,cNumSeq,nBsRet,nTrfEnt,nTrfSai)

dbSelectArea("CDM")  
dbSetOrder(3)                      

if nQtd<>0
   dbSeek(xFilial("CDM")+'000000   '+Padr("CAT",TamSx3("CDM_SERIEE")[1])+cProduto+dtos(dEmissao)+'S')
else
   dbSeek(xFilial("CDM")+'000000   '+Padr("CAT",TamSx3("CDM_SERIEE")[1])+cProduto+dtos(dEmissao)+'T')
endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se ja existe Saldo Inicial para esse Produto (000000+CAT+DATA+TIPO), nao vai incluir novamente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if eof()
	RecLock("CDM",.T.)
	CDM->CDM_FILIAL := xFilial("CDM")
	CDM->CDM_DOCENT := cDoc
	SerieNfId("CDM",1,"CDM_SERIEE",,,,cSerie)
	CDM->CDM_DTENT  := dEmissao    
	CDM->CDM_DTSAI  := dEmissao
	CDM->CDM_DTDGEN := dDtDigi  
	CDM->CDM_FORNEC := cFornec
	CDM->CDM_LJFOR  := cLoja
	CDM->CDM_ITENT  := cItem  
	
    if nQtd<>0
       CDM->CDM_QTDENT := nQtd
	   CDM->CDM_SALDO  := nQtd
	   CDM->CDM_TIPO  := 'S' // Saldos de CAT
    else
       CDM->CDM_QTDENT := nTrfEnt
	   CDM->CDM_SALDO  := nTrfEnt
	   CDM->CDM_TIPO  := 'T' // Saldos de Transferencias
   	   CDM->CDM_BSENT := nBase
	   CDM->CDM_ICMENT:= ((nBase * nAliq) /100 ) / nTrfEnt
	   CDM->CDM_ALQENT:= nAliq
    endif
	
	CDM->CDM_UFENT  := cUF
	CDM->CDM_NSEQE  := cNumSeq
	CDM->CDM_PRODUT := cProduto
	CDM->CDM_BSERET := nBsRet		

	CDM->(MsUnLock())            
endif
	
Return 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³CredICMSD1ºAutor  ³ Angelica N. Rabelo º Data ³  03/03/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Funcao onde sera realizada a selecao/gravacao das NF's Entr.º±±
//±±º          ³em CDM de acordo com os parametros passados.                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±³Parametros³dDtIni/dDtFim: periodo no qual serao consideradas as NF's   ³±±
//±±³          |     	       Entrada p/ gravar em CDM e posteriormente cal³±±
//±±³          |     	       culado o credito.						    ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function CredICMSD1(dDtIni,dDtFim,cMVEstado)

Local cAliasSD1:= "SD1"
Local cEst := ""
Local aAreaAtu := GetArea()
Local lQuery   := .f.

#IFDEF TOP
	
	If TcSrvType()<>"AS/400"							          		 
 		cFiltro := "%"	
	
		If cMVEstado <> "SP"  // $ "RS/SC/PR/GO/BA/ES"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND (SD1.D1_ICMSRET > 0 OR (SD1.D1_BASNDES > 0  AND SD1.D1_ICMNDES >= 0) OR SD1.D1_CF IN " +%Exp:("('1408','1409')")%+")"    	
		Else
			cFiltro += " SF4.F4_CRICMS= '" +%Exp:("1")% +"' AND SB1.B1_CRICMS= '" +%Exp:("1")% +"' AND ((SD1.D1_VALICM > 0 AND SD1.D1_ICMSRET > 0) OR (SD1.D1_BASNDES > 0  AND SD1.D1_ICMNDES >= 0) OR SD1.D1_CF IN " +%Exp:("('1408','1409')")%+")" 				
		EndIf		
		
		cFiltro += "%"
    	lQuery    :=.t.   
        cAliasSD1 := GetNextAlias()   
        BeginSql Alias cAliasSD1
			COLUMN D1_DTDIGIT AS DATE   
			COLUMN D1_EMISSAO AS DATE 
			SELECT SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_NUMSEQ, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, 
			       SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM, SD1.D1_QUANT,  SD1.D1_EMISSAO, SD1.D1_PICM, SD1.D1_VALICM, 
			       SD1.D1_BASEICM, SD1.D1_ICMNDES, SD1.D1_BASNDES, SD1.D1_TOTAL, SD1.D1_VALFRE, SD1.D1_SEGURO, 
			       SD1.D1_DESPESA, SD1.D1_VALDESC, SD1.D1_TIPO, SD1.D1_BRICMS, SD1.D1_CF, SD1.D1_TES, SF1.F1_EST
   		    FROM %table:SD1% SD1, %table:SF1% SF1, %table:SF4% SF4, %table:SB1% SB1      
	        WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
		          SD1.D1_DTDIGIT >=%Exp:dDtIni% AND
       			  SD1.D1_DTDIGIT <=%Exp:dDtFim% AND
	    	      SD1.D1_TIPO IN('N','C') AND 
	    	      SD1.D1_LOTECTL = ' ' AND
	    	      SD1.D1_NUMLOTE = ' ' AND
	        	  SD1.%NotDel% AND
		          SF1.F1_FILIAL  = %xFilial:SF1% AND
		          SF1.F1_DOC     = SD1.D1_DOC AND
		          SF1.F1_SERIE   = SD1.D1_SERIE AND
        	      SF1.F1_FORNECE = SD1.D1_FORNECE AND
            	  SF1.F1_LOJA    = SD1.D1_LOJA AND
		          SF1.F1_TIPO    = SD1.D1_TIPO AND
	              SF1.%NotDel% AND
		          SF4.F4_FILIAL = %xFilial:SF4% AND
	    	      SF4.F4_CODIGO = SD1.D1_TES AND
      	    	  SF4.%NotDel% AND
	              SB1.B1_FILIAL = %xFilial:SB1% AND					  
				  SB1.B1_COD = D1_COD AND
				  SB1.%NotDel% AND
				  (%Exp:cFiltro%)
		    ORDER BY 1,2 DESC
    	EndSql
        		
		dbSelectArea(cAliasSD1)         

	Else
		                  
#ENDIF                                                       
                     		
		cSD1    :=	CriaTrab(Nil,.F.)
	    cChave      :="D1_FILIAL+dtos(D1_DTDIGIT)"
		cCondicao 	:= "D1_FILIAL == '" + xFilial("SD1") + "' .AND. "  
		cCondicao 	+= "dtos(D1_DTDIGIT) >= '"+DToS (dDtIni)+"' .AND. " 
		cCondicao 	+= "dtos(D1_DTDIGIT) <= '"+DToS (dDtFim)+"' .AND. " 
		cCondicao 	+= "empty(D1_LOTECTL) .AND. " 
		cCondicao 	+= "empty(D1_NUMLOTE) .AND. " 
		cCondicao 	+= "D1_TIPO $ 'NC' 	"	
	 	
	    IndRegua(cAliasSD1,cSD1,cChave,,cCondicao,STR0002) //"Selecionado registros"  	  	  
	    DbGoBottom()  
	    
		#IFNDEF TOP
			DbSetIndex(cSD1+OrdBagExt())
			dbSelectarea(cAliasSD1)       
			(cAliasSD1)->(dbGoBottom())
		#ELSE     
			dbSelectarea(cAliasSD1)           
			(cAliasSD1)->(dbGotop())
		#ENDIF   

#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())
	                      
While (cAliasSD1)->(!Eof()) .And. !(cAliasSD1)->(Bof())    

	   if !lQuery   	        
          
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³Filtra apenas aqueles Produtos/TES configurados para tal operacao³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	          	      
 	       	If cMVEstado <> "SP" //$ "RS/SC/PR/GO/BA/ES"
 	       		  SF4->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
		  	      if SF4->F4_CRICMST <> '1'
		  	         dbSelectarea(cAliasSD1)
		  	         (cAliasSD1)->(DbSkip(-1))
					 Loop   	        	      
		  	      endif
		
		  	      SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))	  	      
			      if SB1->B1_CRICMST <> '1'  	        
		  	         dbSelectarea(cAliasSD1)
		  	         (cAliasSD1)->(DbSkip(-1))
					 Loop   	        	      
		  	      endif  
 			Else
		  	      SF4->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
		  	      if SF4->F4_CRICMS <> '1'
		  	         dbSelectarea(cAliasSD1)
		  	         (cAliasSD1)->(DbSkip(-1))
					 Loop   	        	      
		  	      endif

		  	      SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))	  	      
			      if SB1->B1_CRICMS <> '1'  	        
		  	         dbSelectarea(cAliasSD1)
		  	         (cAliasSD1)->(DbSkip(-1))
					 Loop   	        	      
		  	      endif  
		  	Endif
		  	         
 	      SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))
 	   
 	      cEst:=SF1->F1_EST 	      
 	        	        	      
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³Se a NFE ja existe em CDM, nao vai gerar novamente (registro de Saldos sera unico)³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  	      dbSelectArea("CDM")				  
          dbSetOrder(1)
          If CDM->(DbSeek(xFilial("CDM")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+;
                                          (cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD+;
                                          (cAliasSD1)->D1_NUMSEQ+"S"))                           
               dbSelectarea(cAliasSD1)
               (cAliasSD1)->(DbSkip(-1))
               Loop                                                            
          endif                       
                     
       else
	   	   
	   	   cEst := 	F1_EST  
	   
	   endif     	      
          
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Funcao de gravacao da NFEntrada em CDM p/ utilizacao das mesmas como Saldos a realizar amarracao | 
	   //|das NF's Saida e calculo dos creditos.														   ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		(cAliasSD1)->(RecEntSD1(D1_DOC,D1_SERIE,D1_EMISSAO,D1_DTDIGIT,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD,D1_QUANT,;
	                            D1_BASEICM,D1_VALICM,D1_PICM,cEst,D1_NUMSEQ,D1_ICMNDES,D1_BASNDES,D1_TOTAL,;
	                            D1_VALFRE,D1_SEGURO,D1_DESPESA,D1_VALDESC,D1_TIPO,D1_BRICMS,D1_CF,D1_TES)) 	     	                                                      
	   
	   if lQuery
	      (cAliasSD1)->(dbSkip())						  
	   else
	      dbSelectarea(cAliasSD1)
	      (cAliasSD1)->(DbSkip(-1))
	   endif   

EndDo
                          
(cAliasSD1)->(dbCloseArea())

RestArea(aAreaAtu)

Return       

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³RecEntSD1 ºAutor  ³ Angelica N.Rabelo  º Data ³  03/03/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Vai gerar as ocorrencias das NF's Entrada na CDM (caso aindaº±±
//±±º          ³ nao existam na mesma)                                      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
//±±³Parametros³ cDoc        - Numero do Documento Entrada					³±±
//±±³          ³ cSerie      - Serie do Documento Entrada      			    ³±±
//±±³          ³ dEmissao    - Data Emissao NFE						        ³±±
//±±³          ³ dDtDigi     - Data Digitacao NFE 		                    ³±±
//±±³          ³ cFornec     - Fornecedor  								    ³±±
//±±³          ³ cLoja       - Loja                                         ³±±
//±±³          ³ cItem       - Item do Produto na NFE     		            ³±±
//±±³          ³ cProduto    - Codigo do Produto                            ³±±
//±±³          ³ nQtd        - Quantidade Comprada	                        ³±±
//±±³          ³ nBase       - Base ICMS da NFE	                            ³±±
//±±³          ³ nICMS       - Valor ICMS                                   ³±±
//±±³          ³ nAliq       - Aliquota ICMS					            ³±±
//±±³          ³ cUF         - UF   						                ³±±
//±±³          ³ cNumSeq     - Sequencia de Movimento (DOCSEQ)              ³±±
//±±³          ³ nVlrIC      - Valor ICMS incluido Manualmente na NFE       ³±±
//±±³          ³ nBsIC       - Base ICMS incluido Manualmente na NFE        ³±±
//±±³          ³ nTotal      - Valor Total do Item						    ³±±
//±±³          ³ nFret       - Valor do frete						  	    ³±±
//±±³          ³ nSegur      - Valor Seguro 			   				    ³±±
//±±³          ³ nDesps      - Valor Despesas								³±±
//±±³          ³ nDesc       - Valor Descontos								³±±
//±±³          ³ cTipo       - Tipo do Documento							³±±
//±±³          ³ nBseRet     - Base ICMS Retido								³±±
//±±³          ³ cCF         - CFOP Entrada									³±±
//±±³          ³ cTESE       - TES Entrada									³±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function RecEntSD1(cDoc,cSerie,dEmissao,dDtDigi,cFornec,cLoja,cItem,cProduto,nQtd,nBase,nIcms,nAliq,cUf,cNumSeq,;
                   nVlrIC,nBsIC,nTotal,nFret,nSegur,nDesps,nDesc,cTipo,nBseRet,cCF,cTESE,nEstorno)                                                 
                                                        	
DEFAULT nEstorno := 0 
           
IF !empty(cDoc)
  
  dbSelectArea("CDM")
  dbSetOrder(1) 	
 
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Se a NFE ja existe em CDM, nao vai gerar novamente³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  If !(CDM->(DbSeek(xFilial("CDM")+cDoc+cSerie+cFornec+cLoja+cItem+cProduto+cNumSeq)))  
	RecLock("CDM",.T.)
	CDM->CDM_FILIAL := xFilial("CDM")
	CDM->CDM_DOCENT := cDoc
	SerieNfId("CDM",1,"CDM_SERIEE",,,,cSerie)
	CDM->CDM_DTENT  := dEmissao 
	CDM->CDM_DTSAI  := dEmissao
	CDM->CDM_DTDGEN := dDtDigi
	CDM->CDM_FORNEC := cFornec
	CDM->CDM_LJFOR  := cLoja
	CDM->CDM_ITENT  := cItem
	CDM->CDM_QTDENT := nQtd
	CDM->CDM_SALDO  := nQtd		
	CDM->CDM_ALQENT := nAliq	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Determina Aliq.Interna Estado a ser aplicada nos calculos abaixo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SB1->(dbSeek(xFilial("SB1")+cProduto))  
    if SB1->B1_PICM<>0 	
       nAlqInt := SB1->B1_PICM    
    endif                   
    
    If !(cTipo $ ('C','D'))   // 'C' - Compl. Precos, 'D' - Devolução de  Vendas
       CDM->CDM_TIPO := "S"   // Saldos em NF Entrada
    Else
       CDM->CDM_TIPO := cTipo
    Endif                  

   	CDM->CDM_BSENT  := IIf(nBase == 0 .And. nBsIC > 0, nBsIC, nBase)
	CDM->CDM_ICMENT := ((IIf(CDM->CDM_BSENT==0 .And. nBsIC > 0, nBsIC,CDM->CDM_BSENT) * nAliq) /100) / nQtd
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BASE, VALOR ICMS ST (informados manualmente no SD1-recolhido anteriormente)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CDM->CDM_BASMAN := nBsIC     
	CDM->CDM_ICMMAN := ((nBsIC * nAlqInt) /100) / nQtd 
           	
	CDM->CDM_UFENT  := cUF
	CDM->CDM_NSEQE  := cNumSeq
	CDM->CDM_PRODUT := cProduto
	CDM->CDM_BSERET := nBseRet	
	CDM->CDM_TIPODB := cTipo
	CDM->CDM_CFENT  := cCF
	CDM->CDM_TES    := cTESE
	
	if cTipo $ ('D') 
  	   CDM->CDM_ESTORN := nEstorno
    endif
  
	CDM->(MsUnLock())  
	          
  endif  
  
Endif
	
Return


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³CredICMSD2ºAutor  ³ Angelica N. Rabelo º Data ³  03/03/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Funcao de processamento das NF's Saida do periodo sobre     º±±
//±±º          ³as quais havera calculo do credito ICMS.                    º±±
//±±º          ³Sera realizada a amarracao entre SAIDASxENTRADAS variando   º±±
//±±º          ³a forma de realizar dependendo da configuracao do Produto	º±±
//±±º          ³quanto ao Lote/Sub-Lote (B1_RASTRO)							º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ dDtDe/dDtAte - Periodo que sera considerado p/ NF's Saida  ³±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        
Static Function CredICMSD2(dDtDe,dDtAte,cMVEstado)

Local cAliasSD2 	:= "SD2"  
Local aAreaAtu 	:= GetArea()                  
Local aStruSD2 	:= {}
Local aNFOrig  	:= {}      
Local nPos 		:= 1
Local lSerieId 		:= SerieNfId("SD2",3,"D2_SERIE") == "D2_SDOC"

#IFDEF TOP
	
	If TcSrvType()<>"AS/400"	 
	 	cFiltro := "%"	
		If cMVEstado == "RS"  
			cFiltro += " SF4.F4_LFICM = '" +%Exp:("I")% +"' OR SF4.F4_SITTRIB IN " +%Exp:("('00','10','30')")% +" AND SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"'  	
		ElseIf cMVEstado == "SC"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND ((substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"') OR (SD2.D2_VALICM > 0 AND SA1.A1_SIMPNAC=" +%Exp:("1")% +")"+")"
		ElseIf cMVEstado == "PR"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND (SD2.D2_VALICM > 0 AND substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"' AND SA1.A1_CONTRIB=" +%Exp:("1")% +")"  	
		ElseIf cMVEstado == "GO"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND (SD2.D2_ICMSRET > 0 AND substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"')"    	
		ElseIf cMVEstado == "BA"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND (SD2.D2_ICMSRET > 0 AND substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"')"    	
		ElseIf cMVEstado == "ES"  
			cFiltro += " SF4.F4_LFICM = '" +%Exp:("I")% +"' OR SF4.F4_SITTRIB IN " +%Exp:("('10','30')")% +" AND SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"'
		ElseiF cMVEstado == "RJ"
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND ((substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"'))"
		ElseIf cMVEstado == "SP"  
			cFiltro += "  substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"' AND SF4.F4_CRICMS= '" +%Exp:("1")% +"' AND SB1.B1_CRICMS= '" +%Exp:("1")% +"'
			if mv_par04 == 2 
				cFiltro += " OR SD2.D2_CF IN " +%Exp:("('5408','5409')")% 
			EndIf		
		Else
			cFiltro += " SF4.F4_CRICMST= '" +%Exp:("1")% +"' AND SB1.B1_CRICMST= '" +%Exp:("1")% +"' AND ((substring(SD2.D2_CF,1,1)= '" +%Exp:("6")% +"') OR (SD2.D2_VALICM > 0 AND SA1.A1_SIMPNAC=" +%Exp:("1")% +")"+")"
		EndIf		
		cFiltro += "%"
       	lQuery    :=.t.   
        cAliasSD2 := GetNextAlias()       	
        BeginSql Alias cAliasSD2
				COLUMN D2_EMISSAO AS DATE   
				COLUMN D2_DTVALID AS DATE   
		  	 	SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM, SD2.D2_NUMSEQ, 
				       SD2.D2_CF, SD2.D2_QUANT, SD2.D2_EMISSAO, SD2.D2_PICM, SD2.D2_VALICM, SD2.D2_BASEICM, 
				       SD2.D2_EST, SD2.D2_TIPO, SD2.D2_BRICMS, SD2.D2_TES, SD2.D2_LOTECTL, SD2.D2_NUMLOTE, 
				       SD2.D2_DTVALID, SD2.D2_ICMSRET, SD2.D2_VALICM 
				FROM %table:SD2% SD2,%table:SF4% SF4,%table:SB1% SB1,%table:SA1% SA1
		        WHERE SD2.D2_FILIAL = %xFilial:SD2% AND	  
		              SD2.D2_EMISSAO >=%Exp:dDtDe% AND
        			  SD2.D2_EMISSAO <=%Exp:dDtAte% AND		        	                     
					  SD2.D2_TIPO = 'N' AND
					  SD2.%NotDel% AND
					  SF4.F4_FILIAL = %xFilial:SF4% AND
				      SF4.F4_CODIGO = D2_TES AND
					  SF4.%NotDel% AND
				      SB1.B1_FILIAL = %xFilial:SB1% AND
				      SB1.B1_COD = D2_COD AND
				      SB1.%NotDel% AND
				      SA1.A1_FILIAL = %xFilial:SA1% AND
				      SA1.A1_COD = D2_CLIENTE AND
				      SA1.A1_LOJA = D2_LOJA AND
				      SA1.%NotDel% AND
				      (%Exp:cFiltro%) 

    	EndSql
    	 
		dbSelectArea(cAliasSD2)         
		 
	Else
		                  
#ENDIF                   
        
		cSD2    :=	CriaTrab(Nil,.F.)
	    cChave	:=  SD2->(IndexKey())
		cCondicao 	:= "D2_FILIAL == '" + xFilial("SD2") + "' .AND. "						
		cCondicao 	+= "dtos(D2_EMISSAO) >= '"+DToS(dDtDe)+"' .AND. " 
		cCondicao 	+= "dtos(D2_EMISSAO) <= '"+DToS(dDtAte)+"' .AND. " 
		cCondicao 	+= "D2_TIPO == 'N' "  	
		IndRegua(cAliasSD2,cSD2,cChave,,cCondicao,STR0010) //"Selecionado registros"  	  	  		
		#IFNDEF TOP
			DbSetIndex(cSD2+OrdBagExt())
		#ENDIF     
		dbselectarea(cAliasSD2)             
		(cAliasSD2)->(dbGotop())

#IFDEF TOP
    Endif    
#ENDIF 

If !lQuery  
    AADD(aStruSD2,{"D2_FILIAL","C",TamSX3("D2_FILIAL")[1],TamSX3("D2_FILIAL")[2]})
    AADD(aStruSD2,{"D2_DOC","C",TamSX3("D2_DOC")[1],TamSX3("D2_DOC")[2]})
    AADD(aStruSD2,{"D2_SERIE","C",TamSX3("D2_SERIE")[1],TamSX3("D2_SERIE")[2]})
    AADD(aStruSD2,{"D2_CLIENTE","C",TamSX3("D2_CLIENTE")[1],TamSX3("D2_CLIENTE")[2]})    
    AADD(aStruSD2,{"D2_LOJA","C",TamSX3("D2_LOJA")[1],TamSX3("D2_LOJA")[2]})
    AADD(aStruSD2,{"D2_ITEM","C",TamSX3("D2_ITEM")[1],TamSX3("D2_ITEM")[2]})
    AADD(aStruSD2,{"D2_COD","C",TamSX3("D2_COD")[1],TamSX3("D2_COD")[2]})
	 AADD(aStruSD2,{"D2_TES","C",TamSX3("D2_TES")[1],TamSX3("D2_TES")[2]})    
    AADD(aStruSD2,{"D2_LOCAL","C",TamSX3("D2_LOCAL")[1],TamSX3("D2_LOCAL")[2]})    	
    AADD(aStruSD2,{"D2_EMISSAO","D",TamSX3("D2_EMISSAO")[1],TamSX3("D2_EMISSAO")[2]})    	    
    AADD(aStruSD2,{"D2_QUANT","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]})    	    
	 AADD(aStruSD2,{"D2_BASEICM","N",TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]})    	    
	 AADD(aStruSD2,{"D2_VALICM","N",TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]})    	    
	 AADD(aStruSD2,{"D2_PICM","N",TamSX3("D2_PICM")[1],TamSX3("D2_PICM")[2]})    	    
	 AADD(aStruSD2,{"D2_EST","C",TamSX3("D2_EST")[1],TamSX3("D2_EST")[2]})    	                
    AADD(aStruSD2,{"D2_NUMSEQ","C",TamSX3("D2_NUMSEQ")[1],TamSX3("D2_NUMSEQ")[2]})
    AADD(aStruSD2,{"D2_CF","C",TamSX3("D2_CF")[1],TamSX3("D2_CF")[2]})
    AADD(aStruSD2,{"D2_TIPO","C",TamSX3("D2_TIPO")[1],TamSX3("D2_TIPO")[2]})
    AADD(aStruSD2,{"D2_BRICMS","N",TamSX3("D2_BRICMS")[1],TamSX3("D2_BRICMS")[2]})       	                     	              	              	   
    AADD(aStruSD2,{"D2_LOTECTL","C",TamSX3("D2_LOTECTL")[1],TamSX3("D2_LOTECTL")[2]})       	                     	              	              	   
    AADD(aStruSD2,{"D2_NUMLOTE","C",TamSX3("D2_NUMLOTE")[1],TamSX3("D2_NUMLOTE")[2]})       	                     	              	              	   
    AADD(aStruSD2,{"D2_DTVALID","D",TamSX3("D2_DTVALID")[1],TamSX3("D2_DTVALID")[2]})   
    
   	 If lSerieId
   		AADD(aStruSD2,{"D2_SDOC","C",TamSX3("D2_SDOC")[1],TamSX3("D2_SDOC")[2]})
    EndIf 
       	                     	              	              	               
	cArqSD2	:=	CriaTrab(aStruSD2)
	dbUseArea(.T.,__LocalDriver,cArqSD2,"TRR")
	IndRegua("TRR",cArqSD2,"D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM")
                       
    dbselectarea(cAliasSD2)               
    (cAliasSD2)->(dbGotop())
    
    dbselectarea("TRR")               
    dbGotop()
    
    While (cAliasSD2)->(!Eof())     
   		RecLock("TRR",.T.)
      	TRR->D2_FILIAL := (cAliasSD2)->D2_FILIAL
      	TRR->D2_DOC    := (cAliasSD2)->D2_DOC   
		TRR->D2_SERIE  := (cAliasSD2)->D2_SERIE 		
		TRR->D2_CLIENTE:= (cAliasSD2)->D2_CLIENTE
		TRR->D2_LOJA   := (cAliasSD2)->D2_LOJA
		TRR->D2_ITEM   := (cAliasSD2)->D2_ITEM
		TRR->D2_COD    := (cAliasSD2)->D2_COD   
		TRR->D2_LOCAL  := (cAliasSD2)->D2_LOCAL 
		TRR->D2_EMISSAO:= (cAliasSD2)->D2_EMISSAO
		TRR->D2_TES    := (cAliasSD2)->D2_TES  
		TRR->D2_QUANT  := (cAliasSD2)->D2_QUANT
		TRR->D2_BASEICM:= (cAliasSD2)->D2_BASEICM
		TRR->D2_VALICM := (cAliasSD2)->D2_VALICM	
		TRR->D2_PICM   := (cAliasSD2)->D2_PICM 
    	TRR->D2_EST    := (cAliasSD2)->D2_EST  				
		TRR->D2_NUMSEQ := (cAliasSD2)->D2_NUMSEQ
		TRR->D2_CF     := (cAliasSD2)->D2_CF
		TRR->D2_TIPO   := (cAliasSD2)->D2_TIPO
		TRR->D2_BRICMS := (cAliasSD2)->D2_BRICMS
		TRR->D2_TES    := (cAliasSD2)->D2_TES 
		TRR->D2_LOTECTL:= (cAliasSD2)->D2_LOTECTL
		TRR->D2_NUMLOTE:= (cAliasSD2)->D2_NUMLOTE
		TRR->D2_DTVALID:= (cAliasSD2)->D2_DTVALID		
		If lSerieId
			TRR->D2_SDOC  := (cAliasSD2)->D2_SERIE
		EndIF				
		msUnlock()	 
		dbselectarea(cAliasSD2)    	
		(cAliasSD2)->(dbSkip())
    Enddo  
      
    (cAliasSD2)->(dbCloseArea())
    cAliasSD2 := "TRR"
   
	dbselectarea(cAliasSD2)               
	(cAliasSD2)->(dbGotop())

Endif

ProcRegua(LastRec())    

While (cAliasSD2)->(!Eof())   
                          
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Filtra apenas aqueles Produtos/TES configurados para tal operacao³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                               
   	   If !lQuery	            								  
	  	    If cMVEstado <> "SP" // $ "RS/SC/PR/GO/ES" 
	  	    	  SF4->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		  	      if SF4->F4_CRICMST <> '1'
		  	        (cAliasSD2)->(dbSkip())
					 Loop   	        	      
		  	      endif
		  	  
			  	  SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			      if SB1->B1_CRICMST <> '1'
		 	         (cAliasSD2)->(dbSkip())
				     Loop   	        	      
		  	      Endif 
			Else 
		  	      SF4->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		  	      If SF4->F4_CRICMS <> '1'
		  	        (cAliasSD2)->(dbSkip())
					 Loop   	        	      
		  	      endif
		  	  
			  	  SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			      If SB1->B1_CRICMS <> '1'
		 	         (cAliasSD2)->(dbSkip())
				     Loop   	        	      
		  	      Endif  
		 	Endif 	        
  	   Endif
  	   
  	 
  	     	     	           
                                             
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Verifica se NFSaida ja existe em CDM. Em caso afirmativo, nao grava novamente.                            |
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       dbSelectArea("CDM")		
       dbSetOrder(2)  
       (CDM->(dbSeek(xFilial("CDM")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+;
                                     (cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM+(cAliasSD2)->D2_COD+;
                                     (cAliasSD2)->D2_NUMSEQ)))
                                 
       if eof()   
                   	        	                                                                   
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 		 //³ Se Produto nao usa LOTE:funcao RECSAICDM (onde buscas SALDOS 'S' provenientes de NF's Entrada e 'T'   |
 		 //|                         provenientes de Transferencias)											   |
		 //³ Se Produto usa LOTE    :funcao RECCDMLOTE (amarracao Entradas X Saidas atraves de RASTRONFOR que      |
		 //|                         busca as NF'S origem atraves dos LOTES informados Entrada/Saida)              |
		 //|                         Caso nao encontre NF's origem prlo Lote/Sub-Lote, busca Movimentacoes Internas|
		 //|                         no SD3 a fim de determinar origem e valores para calcular o credito           |
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       		              
        dbSelectarea("SB1")
        dbSetOrder(1)
        dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
        
		if !eof() .and. SB1->B1_RASTRO $ 'LS'    // Produtos com controle de Lote/Sub-Lote
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Funcao que vai trazer em ALOTE as NF's origem da NF Saida em questao (de acordo com Lote/Sub-Lote  |
			 //| utilizado nos documentos)																			³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 aLote := RASTRONFOR((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA)			 		     
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Determina posicao (ALOTE) em que se encontra a NF Saida em questao p/ gerar associacao em  |
			 //| RECCDMLOTE                                                                                 |
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	     nPos:= Ascan(aLote, { |x| x[26] + x[27] + x[28] + x[29] + x[25] + x[03] == (cAliasSD2)->D2_DOC + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA + (cAliasSD2)->D2_ITEM + (cAliasSD2)->D2_COD })

             if nPos<>0   
               
            	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Grava na CDM a NF Entrada origem   |			  	
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            			   
			   RecEntSD1(aLote[nPos][1],aLote[nPos][2],aLote[nPos][11],aLote[nPos][7],aLote[nPos][8],;
			   			 aLote[nPos][9],aLote[nPos][10],aLote[nPos][3],aLote[nPos][6],aLote[nPos][12],;
			   			 aLote[nPos][13],aLote[nPos][14],aLote[nPos][16],aLote[nPos][15],aLote[nPos][17],;
			   			 aLote[nPos][18],aLote[nPos][19],aLote[nPos][20],aLote[nPos][21],aLote[nPos][22],;
			   			 aLote[nPos][23],aLote[nPos][32],aLote[nPos][33],aLote[nPos][31],aLote[nPos][37])                                                                                                  		                  
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Grava na CDM NF Saida ja relacionada com a NF Entrada origem - no mesmo registro da Entrada (gerado acima) |			  	
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     			   			                
			   RecCDMLote((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_CLIENTE,;
		     	          (cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_ITEM,(cAliasSD2)->D2_COD,(cAliasSD2)->D2_QUANT,;
		     	          (cAliasSD2)->D2_BASEICM,(cAliasSD2)->D2_VALICM,(cAliasSD2)->D2_PICM,(cAliasSD2)->D2_EST,;
		     	          (cAliasSD2)->D2_NUMSEQ,aLote[nPos][1],aLote[nPos][2],aLote[nPos][11],aLote[nPos][7],;
		     	          aLote[nPos][8],aLote[nPos][9],aLote[nPos][10],aLote[nPos][3],aLote[nPos][6],aLote[nPos][12],;
		     	          aLote[nPos][13],aLote[nPos][14],aLote[nPos][16],aLote[nPos][15],aLote[nPos][17],aLote[nPos][18],;
		     	          aLote[nPos][19],aLote[nPos][20],aLote[nPos][21],aLote[nPos][22],aLote[nPos][23],aLote[nPos][24],;
		     	          aLote[nPos][25],(cAliasSD2)->D2_TIPO,aLote[nPos][34],aLote[nPos][35],aLote[nPos][30],aLote[nPos][31],aLote[nPos][33], cMVEstado)
		     Else  
		     
		       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ PRODUTO VENDIDO COM LOTE e SEM NF Compras na CDM para associar: 							   |			  	
			   //| Caso nao tenha encontrado NF Compras para o Produto Vendido (nPos==0) deve verificar se ha  |
			   //| TRANSFERENCIAS (DE4) ocorridas de Produto SIMILAR (ORIGEM) para o PRODUTO VENDIDO (Destino) |
			   //| que esta sendo passado como parametro.(Nesse caso DEVE haver controle Lote/Sub-Lote         |
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     			   			                		                                        		       
                
		        aNFOrig := montaSD3((cAliasSD2)->D2_COD,(cAliasSD2)->D2_LOTECTL,(cAliasSD2)->D2_NUMLOTE,(cAliasSD2)->D2_DTVALID)  
			    													
				For nPos:=1 to len(aNFOrig)					
					If Len(aNFOrig[nPos]) > 0					   
					    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Grava na CDM a NF Entrada do Produto ORIGEM da Transferencia entre PRODUTOS (DE4-RE4)   |			  	
				        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
					    RecEntSD1(aNFOrig[nPos][1][1],aNFOrig[nPos][1][2],aNFOrig[nPos][1][3],;
					              aNFOrig[nPos][1][4],aNFOrig[nPos][1][5],aNFOrig[nPos][1][6],;
					              aNFOrig[nPos][1][7],aNFOrig[nPos][1][8],aNFOrig[nPos][1][9],;
					              aNFOrig[nPos][1][10],aNFOrig[nPos][1][11],aNFOrig[nPos][1][12],;
					    	      aNFOrig[nPos][1][13],aNFOrig[nPos][1][14],aNFOrig[nPos][1][15],;
					    	      aNFOrig[nPos][1][16],aNFOrig[nPos][1][17],aNFOrig[nPos][1][18],;
					    	      aNFOrig[nPos][1][19],aNFOrig[nPos][1][20],aNFOrig[nPos][1][21],;
					    	      aNFOrig[nPos][1][22],aNFOrig[nPos][1][23],aNFOrig[nPos][1][24],;
					    	      aNFOrig[nPos][1][25])                                                                                                  		                  
	                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Grava na CDM NF Saida (Produto Destino) ja relacionada com a NF Entrada.                |			  	
				        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     	      
					    RecCDMLote((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_EMISSAO,;
					    		   (cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_ITEM,;
					    		   (cAliasSD2)->D2_COD,(cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_BASEICM,;
					    		   (cAliasSD2)->D2_VALICM,(cAliasSD2)->D2_PICM,(cAliasSD2)->D2_EST,;
					    		   (cAliasSD2)->D2_NUMSEQ,;		     	               
			     	               aNFOrig[nPos][1][1],aNFOrig[nPos][1][2],aNFOrig[nPos][1][3],; 		     	               		     	               
			     	               aNFOrig[nPos][1][4],aNFOrig[nPos][1][5],aNFOrig[nPos][1][6],;		     	                                                                		     	               		     	               		     	               
			     	               aNFOrig[nPos][1][7],aNFOrig[nPos][1][8],aNFOrig[nPos][1][9],;		     	               
			     	               aNFOrig[nPos][1][10],aNFOrig[nPos][1][11],aNFOrig[nPos][1][12],;		     	               
			     	               aNFOrig[nPos][1][13],aNFOrig[nPos][1][14],aNFOrig[nPos][1][15],;
			     	               aNFOrig[nPos][1][16],aNFOrig[nPos][1][17],aNFOrig[nPos][1][18],;
			     	               aNFOrig[nPos][1][19],aNFOrig[nPos][1][20],aNFOrig[nPos][1][21],0,;		     	               
			     	               (cAliasSD2)->D2_ITEM,(cAliasSD2)->D2_TIPO,(cAliasSD2)->D2_CF,;
			     	               (cAliasSD2)->D2_BRICMS,(cAliasSD2)->D2_TES, cMVEstado)
			        EndIF
		     	Next           
		     Endif
		                   
		Else   
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Busca associacoes para NF Saida com tipo 'S': Saldos de CAT ou SD1                 |			  	
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		     
		     RecSaiCDM((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_EMISSAO,;
			 	       (cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_ITEM,;
				 	   (cAliasSD2)->D2_COD,(cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_BASEICM,;
				 	   (cAliasSD2)->D2_VALICM,(cAliasSD2)->D2_PICM,(cAliasSD2)->D2_EST,;
			 		   (cAliasSD2)->D2_NUMSEQ,(cAliasSD2)->D2_TIPO,(cAliasSD2)->D2_BRICMS,;
			 		   (cAliasSD2)->D2_CF,(cAliasSD2)->D2_TES,'S',cMVEstado)    
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Busca associacoes para NF Saida com tipo 'T': Saldos de Transferencias            |			  	
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
			 RecSaiCDM((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_EMISSAO,;
			 	       (cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_ITEM,;
				 	   (cAliasSD2)->D2_COD,(cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_BASEICM,;
				 	   (cAliasSD2)->D2_VALICM,(cAliasSD2)->D2_PICM,(cAliasSD2)->D2_EST,;
			 		   (cAliasSD2)->D2_NUMSEQ,(cAliasSD2)->D2_TIPO,(cAliasSD2)->D2_BRICMS,;
			 		   (cAliasSD2)->D2_CF,(cAliasSD2)->D2_TES,'T')			 		   
		endif
						 	 		        	     
       endif                                     

	   (cAliasSD2)->(dbSkip())
	
EndDo

(cAliasSD2)->(dbCloseArea())

RestArea(aAreaAtu)

Return() 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³RecSaiSD2 ºAutor  ³ Natalia Antonucci  º Data ³  26/09/11   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Vai gerar as ocorrencias das NF's Entrada na CDM (caso aindaº±±
//±±º          ³ nao existam na mesma)                                      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
//±±³Parametros³ cDoc        - Numero do Documento 							³±±
//±±³          ³ cSerie      - Serie do Documento      			 		    ³±±
//±±³          ³ dEmissao    - Data Emissao  						        ³±±
//±±³          ³ cClient     - Cliente  								    ³±±
//±±³          ³ cLoja       - Loja                                         ³±±
//±±³          ³ cItem       - Item do Produto   	     		            ³±±
//±±³          ³ cTipo       - Tipo do Documento					   		³±±          
//±±³          ³ nEstorno	 - Estorno de Debito    			   			³±±          
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Function RecSaiSD2(cDoc,cSerie,dEmissao,cClient,cLoja,cItem,cTipo,nEstorno,nQtd)
  	                                                  	                                                                                                 
IF !empty(cDoc)

  	RecLock("CDM",.F.)
  
	CDM->CDM_DOCSAI := cDoc
	CDM->CDM_SERIES := cSerie
	CDM->CDM_DTENT  := dEmissao 
	CDM->CDM_CLIENT := cClient
	CDM->CDM_LJCLI  := cLoja
	CDM->CDM_ITSAI  := cItem              
	CDM->CDM_TIPODB := cTipo 
	
	if cTipo $ ('D')
  	   CDM->CDM_ESTDEB := nEstorno
  	   CDM->CDM_QTDVDS := nQtd
    endif
  
	CDM->(MsUnLock())  
	          
Endif

Return            

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡„o    ³ RecSaiCDM  ³Autor  ³ Angelica N. Rabelo    ³ Data ³ 03/03/09 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡„o ³ Funcao de Gravacao da tabela CDM - Saidas                    ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³ cDoc        - Numero do Documento Saida  				      ³±±
//±±³          ³ cSerie      - Serie do Documento Saida        			      ³±±
//±±³          ³ dEmissao    - Data Emissao NFS						          ³±±
//±±³          ³ cCliente    - Cliente  								      ³±±
//±±³          ³ cLoja       - Loja                                           ³±±
//±±³          ³ cItem       - Item do Produto na NFS     		              ³±±
//±±³          ³ cProduto    - Codigo do Produto                              ³±±
//±±³          ³ nQtd        - Quantidade Vendida	                          ³±±
//±±³          ³ nBase       - Base ICMS da NFS	                              ³±±
//±±³          ³ nICMS       - Valor ICMS                                     ³±±
//±±³          ³ nAliq       - Aliquota ICMS					              ³±±
//±±³          ³ cUF         - UF   						                  ³±±
//±±³          ³ cNumSeq     - Sequencia de Movimento (DOCSEQ)                ³±±
//±±³          ³ cTpNF       - Tipo do Documento							  ³±±
//±±³          ³ nBrICM      - Base ICMS Retido					 			  ³±±
//±±³          ³ cCFSai      - CFOP do Item									  ³±±
//±±³          ³ cTESS       - Tes Saida							 		  ³±±
//±±³          ³ cTipoSFK    - Tipo Saldo que sera utilizado na amarracao(S/T)³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³ NIL                                                          ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Uso       ³ Controle de Credito de ICMS nao destacado                    ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
     
Static Function RecSaiCDM(cDoc,cSerie,dEmissao,cCliente,cLoja,cItem,cProduto,nQtd,nBase,nIcms,nAliq,cUf,cNumSeq,cTpNF,nBrICM,cCFSai,cTESS,cTipoSFK,cMVEstado)

Local nSaldo  := nQtd
Local nQtdCont:= nQtd
Local nQtdAux := 0  
Local cDocEnt := CDM->CDM_DOCENT
Local cSerieE := CDM->CDM_SERIEE
Local dDtEnt  := CDM->CDM_DTENT
Local dDtDGEN := CDM->CDM_DTDGEN
Local cFornec := CDM->CDM_FORNEC
Local cLJFor  := CDM->CDM_LJFOR
Local cItEnt  := CDM->CDM_ITENT
Local nQtdEnt := nQtdAux
Local nBsEnt  := CDM->((CDM_BSENT/CDM_QTDENT)*nQtdAux)
Local nIcmEnt := CDM->((CDM_ICMENT/CDM_QTDENT)*nQtdAux)
Local nAlqEnt := CDM->CDM_ALQENT
Local cUfEnt  := CDM->CDM_UFENT
Local cnSeqE  := CDM->CDM_NSEQE
Local nIcmst  := CDM->CDM_BSERET
Local nBasMan := CDM->CDM_BASMAN 
Local nIcmMan := CDM->CDM_ICMMAN
Local lQuery  := .F.
Local QCDM     := "CDM"
Local aAreaAtu := GetArea()
Local nTotSld  := 0
Local aStruCDM := {} 
Local lSerieId := SerieNfId("CDM",3,"CDM_SERIEE") == "CDM_SDOCE" 

#IFDEF TOP
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Seleciona Saldos existentes para o produto CPRODUTO de acordo com o Tipo passado (cTipoSFK) |
    //| na CDM para gravar as amarracoes e calcular o Credito.                                      |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If TcSrvType()<>"AS/400"  
    	lQuery    :=.t.       
        QCDM := GetNextAlias()
    	BeginSql Alias QCDM
			COLUMN CDM_DTDGEN AS DATE   
			COLUMN CDM_DTENT AS DATE   
			SELECT CDM.CDM_FILIAL, CDM.CDM_PRODUT, CDM.CDM_DTDGEN, CDM.CDM_DOCENT, CDM.CDM_SERIEE,
			       CDM.CDM_FORNEC, CDM.CDM_LJFOR, CDM.CDM_ITENT, CDM.CDM_TIPO, CDM.CDM_DTENT, CDM.CDM_SALDO,
			       CDM.CDM_DTENT, CDM.CDM_NSEQE 
		    FROM %table:CDM% CDM
	        WHERE CDM.CDM_FILIAL = %xFilial:CDM% AND
		          CDM.CDM_PRODUT = %Exp:cProduto% AND
		          CDM.CDM_SALDO > 0 AND
		          CDM.CDM_TIPO = %Exp:cTipoSFK% AND 		          
		          CDM.CDM_DTDGEN <= %Exp:dEmissao% AND
		          CDM.%NotDel%
			ORDER BY 1,2,3 DESC
			
        EndSql                       
                        	
	Else
		                  
#ENDIF                                                       
                       
    cAliasCDM  := CriaTrab(Nil,.F.)       
	cChave	   := "dtos(CDM_DTDGEN)+CDM_PRODUT+CDM_FILIAL"
	cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
	cCondicao  += "CDM_PRODUTO == '"+cProduto+"' .AND. " 
	cCondicao  += "CDM_SALDO > 0 .AND. "
	cCondicao  += "CDM_TIPO == '"+cTipoSFK+"' .AND. " 
	cCondicao  += "DTOS(CDM_DTDGEN) <= '"+ DTOS(dEmissao) + "'"
	IndRegua(QCDM,cAliasCDM,cChave,,cCondicao,STR0002) //"Selecionado registros"  
        
   	#IFNDEF TOP
		dbSetIndex(cAliasCDM+OrdBagExt())
	#ENDIF 
	  
#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe Saldo em CDM (total) p/ associar na NF Saida em questao. Caso não haja, nao gera registro  |
//|dessa NF na CDM, consequentemente nao calcula o Credito para essa NF Saida                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  
dbselectarea(QCDM)               
(QCDM)->(dbGotop())  

While !eof()    
    nTotSld := nTotSld + (QCDM)->CDM_SALDO  
	(QCDM)->(dbSkip())
Enddo   

dbselectarea(QCDM)               
(QCDM)->(dbGotop())  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ NQTD   : Qtde Vendida a associar e calcular Credito    |
//| NTOTSLD: Total de Saldo desse Produto existente na CDM ³
//| Caso exista SALDO ('S' OU 'T') em CDM para associar    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                     

IF nQtd >= nTotSld  
	nQtd   := nTotSld   
	nSaldo := nQtd
Endif


  	If !lQuery      
		AADD(aStruCDM,{"CDM_FILIAL","C",TamSX3("CDM_FILIAL")[1],TamSX3("CDM_FILIAL")[2]})
		AADD(aStruCDM,{"CDM_DOCENT","C",TamSX3("CDM_DOCENT")[1],TamSX3("CDM_DOCENT")[2]})
		AADD(aStruCDM,{"CDM_SERIEE","C",TamSX3("CDM_SERIEE")[1],TamSX3("CDM_SERIEE")[2]})
		AADD(aStruCDM,{"CDM_DTENT","D",TamSX3("CDM_SERIEE")[1],TamSX3("CDM_SERIEE")[2]})
		AADD(aStruCDM,{"CDM_FORNEC","C",TamSX3("CDM_FORNEC")[1],TamSX3("CDM_FORNEC")[2]})
		AADD(aStruCDM,{"CDM_LJFOR","C",TamSX3("CDM_LJFOR")[1],TamSX3("CDM_LJFOR")[2]})
		AADD(aStruCDM,{"CDM_ITENT","C",TamSX3("CDM_ITENT")[1],TamSX3("CDM_ITENT")[2]})
		AADD(aStruCDM,{"CDM_PRODUT","C",TamSX3("CDM_PRODUT")[1],TamSX3("CDM_PRODUT")[2]})
		AADD(aStruCDM,{"CDM_NSEQE","C",TamSX3("CDM_NSEQE")[1],TamSX3("CDM_NSEQE")[2]})
		AADD(aStruCDM,{"CDM_TIPO","C",TamSX3("CDM_TIPO")[1],TamSX3("CDM_TIPO")[2]})
		AADD(aStruCDM,{"CDM_DTDGEN","D",TamSX3("CDM_DTDGEN")[1],TamSX3("CDM_DTDGEN")[2]})
		AADD(aStruCDM,{"CDM_SALDO","N",TamSX3("CDM_SALDO")[1],TamSX3("CDM_SALDO")[2]})
  
		If lSerieId
			AADD(aStruCDM,{"CDM_SDOCE","C",TamSX3("CDM_SDOCE")[1],TamSX3("CDM_SDOCE")[2]})
		EndIf
		
		cArqCDM	:=	CriaTrab(aStruCDM)
		dbUseArea(.T.,__LocalDriver,cArqCDM,"TRB")
		IndRegua("TRB",cArqCDM,"CDM_FILIAL+CDM_PRODUT+DTOS(CDM_DTDGEN)+CDM_NSEQE")
		
		dbselectarea(QCDM)
		(QCDM)->(dbGoBottom())

	    While (QCDM)->(!Bof())     
			recLock("TRB",.T.)
        	TRB->CDM_FILIAL := (QCDM)->CDM_FILIAL
		   TRB->CDM_DOCENT := (QCDM)->CDM_DOCENT
			TRB->CDM_SERIEE := (QCDM)->CDM_SERIEE
			TRB->CDM_DTENT  := (QCDM)->CDM_DTENT
			TRB->CDM_FORNEC := (QCDM)->CDM_FORNEC
			TRB->CDM_LJFOR  := (QCDM)->CDM_LJFOR
			TRB->CDM_ITENT  := (QCDM)->CDM_ITENT
			TRB->CDM_PRODUT := (QCDM)->CDM_PRODUT
			TRB->CDM_NSEQE  := (QCDM)->CDM_NSEQE
			TRB->CDM_TIPO   := (QCDM)->CDM_TIPO  
			TRB->CDM_DTDGEN := (QCDM)->CDM_DTDGEN

		    If lSerieId
		    	TRB->CDM_SDOCE := (QCDM)->CDM_SERIEE
		    EndIf			
			
			msUnlock()	 
			dbselectarea(QCDM)    	
			(QCDM)->(dbSkip(-1))
   		Enddo  
      
	    (QCDM)->(dbCloseArea())
   		QCDM := "TRB"
   
		dbselectarea(QCDM)               
		(QCDM)->(dbGoBottom())
	
  Else
	
		dbselectarea(QCDM)               
		(QCDM)->(dbGoTop())
	
  Endif                    
	               
  While nSaldo > 0 .And. nSaldo <= nTotSld  .And. ((QCDM)->(!Eof()) .And. !(QCDM)->(Bof()))
      dbSelectArea("CDM")    
      if cTipoSFK='S'            
         dbSetOrder(1)       	  
         CDM->(dbSeek((QCDM)->CDM_FILIAL+(QCDM)->CDM_DOCENT+(QCDM)->CDM_SERIEE+(QCDM)->CDM_FORNEC+(QCDM)->CDM_LJFOR+(QCDM)->CDM_ITENT+(QCDM)->CDM_PRODUT+(QCDM)->CDM_NSEQE+(QCDM)->CDM_TIPO))                   
      else   
	     dbSetOrder(3)       	  
	     CDM->(dbSeek((QCDM)->CDM_FILIAL+(QCDM)->CDM_DOCENT+(QCDM)->CDM_SERIEE+(QCDM)->CDM_PRODUT+dtos((QCDM)->CDM_DTENT)+(QCDM)->CDM_TIPO))                   
	  endif
	  
	  cDocEnt := CDM->CDM_DOCENT     
	  cSerieE := CDM->CDM_SERIEE
	  dDtEnt  := CDM->CDM_DTENT
	  dDtDGEN := CDM->CDM_DTDGEN
	  cFornec := CDM->CDM_FORNEC
	  cLJFor  := CDM->CDM_LJFOR
	  cItEnt  := CDM->CDM_ITENT
	  nQtdEnt := CDM->CDM_QTDENT

	  nBsEnt  := CDM->CDM_BSENT
	  nIcmEnt := CDM->CDM_ICMENT
	
	  nBasMan := CDM->CDM_BASMAN
	  nIcmMan := CDM->CDM_ICMMAN
	
	  nAlqEnt := CDM->CDM_ALQENT
	  cUfEnt  := CDM->CDM_UFENT
	  cNSeqE  := CDM->CDM_NSEQE	
	  If cMVEstado <> "SP" //$ "RS/SC/PR/GO/ES/BA"
	  	nIcmst  := CDM->CDM_BSERET
	  Endif	 	  	
	  nSaldo  := CDM->CDM_SALDO - nSaldo   
 	                                                       
      dbSelectArea("CDM") 
	  RecLock("CDM",.F.)
	  CDM->CDM_SALDO := If(nSaldo > 0,nSaldo,0)
	  If CDM->CDM_ESTDEB > 0
		  CDM->CDM_TIPO := CDM->CDM_TIPODB
		  CDM->CDM_DOCENT := ""
		  CDM->CDM_SERIEE := ""		
		  CDM->CDM_FORNEC := ""
		  CDM->CDM_LJFOR  := ""
		  CDM->CDM_ITENT  := ""
		  CDM->CDM_QTDENT := 0
		  CDM->CDM_SALDO  := 0		
		  CDM->CDM_ALQENT := 0
		  CDM->CDM_BSENT  := 0
		  CDM->CDM_ICMENT := 0
		  If lSerieId
		  	  CDM->CDM_SDOCE := ""
		  EndIf
	 Endif	    
	  CDM->(MsUnLock())	    	                  
	    
	  If nSaldo < 0
  	  	  nSaldo := ABS(nSaldo)  
	  	  nQtdAux := nQtdCont - nSaldo    

		  nQtdCont -= nQtdAux
		  nSaldo   := nQtdCont
	  Else
	  	  nQtdAux := nQtdCont
	  	  nSaldo  := 0
	  Endif
	
	  dbSelectArea("CDM") 
	  RecLock("CDM",.T.)   
	  CDM->CDM_FILIAL := xFilial("CDM")
	  CDM->CDM_DOCSAI := cDoc
	  SerieNfId("CDM",1,"CDM_SERIES",,,,cSerie) 
	  CDM->CDM_CLIENT := cCliente
	  CDM->CDM_LJCLI  := cLoja
	  CDM->CDM_ITSAI  := cItem
	  CDM->CDM_PRODUT := cProduto
	  CDM->CDM_QTDVDS := nQtdAux 	  	  	  
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³CALCULA O VALOR UNITARIO DO IMPOSTO 	  ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  CDM->CDM_BSSAI  := (nBase/nQtd)*nQtdAux  
	  CDM->CDM_ICMSAI := (nIcms/nQtd)*nQtdAux	  
	  CDM->CDM_ALQSAI := nAliq
	  CDM->CDM_UFSAI  := cUF
	  CDM->CDM_DTSAI  := dEmissao
	  CDM->CDM_NSEQS  := cNumSeq
	  CDM->CDM_DOCENT := cDocEnt  
	  SerieNfId("CDM",1,"CDM_SERIEE",,,,cSerieE)  
	  CDM->CDM_DTENT  := dDtENT
	  CDM->CDM_DTDGEN := dDtDGEN
	  CDM->CDM_FORNEC := cFornec
	  CDM->CDM_LJFOR  := cLJFor
	  CDM->CDM_ITENT  := cItEnt
	  CDM->CDM_QTDENT := nQtdEnt
	  CDM->CDM_BSENT  := nBsEnt
	
	  If SubStr(ALLTRIM(cCFSai),1,4)$'5408/5409'
	  	If nIcmMan <> 0 
	  		CDM->CDM_ESTORN := nIcmMan * nQtdAux  
	  	else  
		    CDM->CDM_ESTORN := nIcmEnt * nQtdAux            	    
		endif 
	  else
		  if nIcmMan <> 0 
		     CDM->CDM_ICMENT := nIcmMan * nQtdAux
		  else  
		     CDM->CDM_ICMENT := nIcmEnt * nQtdAux            	    
		  endif 
	  endif
	  	
	  CDM->CDM_ALQENT := nAlqEnt
	  CDM->CDM_UFENT  := cUFEnt
	  CDM->CDM_NSEQE  := cNSeqE
	 If cMVEstado <> "SP" //$ "RS/SC/PR/GO/ES/BA"
	 	CDM->CDM_BSERET := nIcmst
	 	CDM->CDM_BASMAN := nBasMan  
	 	CDM->CDM_ICMMAN := nIcmMan 	  
	 Endif	  
	    
	  if cTipoSFK='S'
         CDM->CDM_TIPO   := 'M'
      else
         CDM->CDM_TIPO   := 'E'
      endif 
      CDM->CDM_TIPODB := cTpNF
      CDM->CDM_CFSAI  := cCFSai
      CDM->CDM_BSSRET := nBrICM
      CDM->CDM_TES    := cTESS
          
	  MsUnLock()  
	  
	  If !lQuery    	  
	      (QCDM)->(dbSkip(-1))	  
	  else	    	  
  	      (QCDM)->(dbSkip())	  
	  endif
	
  EndDo
			   

(QCDM)->(dbCloseArea())
               
RestArea(aAreaAtu)

Return()           

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡„o    ³ RecCDMLote ³Autor  ³ Angelica N. Rabelo    ³ Data ³ 03/03/09 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡„o ³ Funcao de Gravacao da tabela CDM - NF Entrada Origem e res-  ³±±
//±±³          | pectiva NF Saida ja calculando a Qtde associada e Saldo da NF³±±
//±±³          | Entrada p/ futuras associacoes/calculo credito ICMS Nao Dest.³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³ cDoc        - Numero do Documento Saida  				      ³±±
//±±³          ³ cSerie      - Serie do Documento Saida        			      ³±±
//±±³          ³ dEmissao    - Data Emissao NFS						          ³±±
//±±³          ³ cCliente    - Cliente  								      ³±±
//±±³          ³ cLoja       - Loja                                           ³±±
//±±³          ³ cItem       - Item do Produto na NFS     		              ³±±
//±±³          ³ cProduto    - Codigo do Produto                              ³±±
//±±³          ³ nQtd        - Quantidade Vendida	                          ³±±
//±±³          ³ nBase       - Base ICMS da NFS	                              ³±±
//±±³          ³ nICMS       - Valor ICMS                                     ³±±
//±±³          ³ nAliq       - Aliquota ICMS					              ³±±
//±±³          ³ cUF         - UF   						                  ³±±
//±±³          ³ cNumSeq     - Sequencia de Movimento (DOCSEQ)                ³±±
//±±³          ³ cDocE       - Numero do Documento Entrada 				      ³±±
//±±³          ³ cSerieE     - Serie do Documento Saida        			      ³±±
//±±³          ³ dEmisE      - Data Emissao NFE						          ³±±
//±±³          ³ dDtDigE     - Data Digitacao NFE					          ³±±
//±±³          ³ cFornec     - Fornecedor									  ³±±
//±±³          ³ cLjFor      - Loja											  ³±±
//±±³          ³ cItemE      - Item NFE										  ³±±
//±±³          ³ cProd       - Produto										  ³±±
//±±³          ³ nQtdE       - Qtde											  ³±±
//±±³          ³ BsIcmE      - Base ICMS Entrada							  ³±±
//±±³          ³ nVlIcmE     - Vlr ICMS Entrada								  ³±±
//±±³          ³ nAliqIE     - % ICMS Entrada								  ³±±
//±±³          ³ cUFE        - UF Entrada									  ³±±
//±±³          ³ cNumSeqE    - Sequencial									  ³±±
//±±³          ³ nVlrIN      - Valor ICMS Nao destacado (Manual)			  ³±±
//±±³          ³ nBsIcmN     - Base ICMS Nao Destacado (Manual)				  ³±±
//±±³          ³ nTotE       - Total NFE								      ³±±
//±±³          ³ nFretE      - Vlr Frete									  ³±±
//±±³          ³ SegE        - Sequencial									  ³±±
//±±³          ³ nDespE      - Despesas Entrada								  ³±±
//±±³          ³ nDescE      - Descontos									  ³±±
//±±³          ³ nAliqSE     - UF Entrada									  ³±±
//±±³          ³ cItemS      - Item de Venda na NF Saida				      ³±±
//±±³          ³ cTpNF       - Tipo Documento Saida				   			  ³±±
//±±³          ³ cCF         - CFOP							   	   			  ³±±
//±±³          ³ nBrSai      - Base ICMS Retido					 			  ³±±
//±±³          ³ cTesS	 	 - TES Saida 									  ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³ NIL                                                          ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Uso       ³ Controle de Credito de ICMS nao destacado                    ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                             		   		   		   		  		 	     
							     							    							     
Static Function RecCDMLote(cDoc,cSerie,dEmissao,cCliente,cLoja,cItem,cProduto,nQtd,nBase,nIcms,nAliq,cUf,cNumSeq,;
                           cDocE,cSerieE,dEmisE,dDtDigE,cFornec,cLjFor,cItemE,cProd,nQtdE,BsIcmE,nVlIcmE,nAliqIE,;
                           cUFE,cNumSeqE,nVlrIN,nBsIcmN,nTotE,nFretE,SegE,nDespE,nDescE,nAliqSE,cItemS,cTpNF,cCF,;
                           nBrSai,cTesS, cCFE, nBseRet, cMVEstado)
Default cCFE := ""
Default nBseRet := 0

dbSelectArea("CDM")
dbSetOrder(1)

If MV_PAR04 == 2 .AND. (SubStr(ALLTRIM(cCFE),1,4)$'1408/1409')
	
	CDM->(DbSeek(xFilial("CDM")+cDocE+cSerieE+cFornec+cLjFor+cItemE+cProd+cNumSeqE+"S"))
	
	BsIcmE 	:= CDM->CDM_BSENT
	nVlIcmE	:= CDM->CDM_ICMENT
	nAliqIE	:= CDM->CDM_ALQENT
	nBrSai	:= CDM->CDM_BSERET
	nBsIcmN := CDM->CDM_BASMAN
	nVlrIN 	:= CDM->CDM_ICMMAN
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abate Saldo da NFE no registro inicial da mesma em CDM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSetOrder(1)
CDM->(DbSeek(xFilial("CDM")+cDocE+cSerieE+cFornec+cLjFor+cItemE+cProd+cNumSeqE+"S"))
if !eof()
	RecLock("CDM",.F.)
	CDM->CDM_SALDO  := CDM->CDM_SALDO-nQtd
	msUnlock()
Endif

dbSelectArea("CDM")
RecLock("CDM",.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava os campos de CDM referentes a NF Entrada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CDM->CDM_FILIAL := xFilial("CDM")
CDM->CDM_DOCENT := cDocE
SerieNfId("CDM",1,"CDM_SERIEE",,,,cSerieE)
CDM->CDM_DTENT  := dEmisE
CDM->CDM_DTDGEN := dDtDigE
CDM->CDM_FORNEC := cFornec
CDM->CDM_LJFOR  := cLjFor
CDM->CDM_ITENT  := cItemE
CDM->CDM_QTDENT := nQtdE
CDM->CDM_ALQENT := nAliqIE
CDM->CDM_UFENT  := cUFE
CDM->CDM_NSEQE  := cNumSeqE
CDM->CDM_PRODUT := cProduto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina Aliq.Interna Estado a ser aplicada nos calculos abaixo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->(dbSeek(xFilial("SB1")+cProduto))
if SB1->B1_PICM<>0
	nAliqIE := SB1->B1_PICM
endif

if (SubStr(ALLTRIM(cCFE),1,4)$'1408/1409')
	CDM->CDM_BSENT  := BsIcmE
	CDM->CDM_ICMENT := nVlIcmE
else
	CDM->CDM_BSENT  := BsIcmE
	CDM->CDM_ICMENT := ((CDM->CDM_BSENT * nAliqIE) /100) / nQtdE
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³BASE, VALOR ICMS ST (informados manualmente no SD1-recolhido anteriormente)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù

If (SubStr(ALLTRIM(cCFE),1,4)$'1408/1409')
	CDM->CDM_BASMAN := nBsIcmN
	CDM->CDM_ICMMAN := nVlrIN
Else
	CDM->CDM_BASMAN := nBsIcmN
	CDM->CDM_ICMMAN := ((nBsIcmN * nAliqIE) /100) / nQtdE
Endif

If SubStr(ALLTRIM(cCF),1,4)$'5408/5409'
	if CDM->CDM_ICMMAN <> 0 .and. CDM->CDM_ICMMAN < CDM->CDM_ICMENT
		CDM->CDM_ESTORN := CDM->CDM_ICMMAN * nQtd
	else
		CDM->CDM_ESTORN := CDM->CDM_ICMENT * nQtd
	endif
	CDM->CDM_ICMENT := 0
Else
	if CDM->CDM_ICMMAN <> 0 .and. CDM->CDM_ICMMAN < CDM->CDM_ICMENT
		CDM->CDM_ICMENT := CDM->CDM_ICMMAN * nQtd
	else
		CDM->CDM_ICMENT := CDM->CDM_ICMENT * nQtd
	endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava os campos de CDM referentes a NF Saida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CDM->CDM_DOCSAI := cDoc
SerieNfId("CDM",1,"CDM_SERIES",,,,cSerie)
CDM->CDM_CLIENT := cCliente
CDM->CDM_LJCLI  := cLoja
CDM->CDM_ITSAI  := cItemS
CDM->CDM_QTDVDS := nQtd
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CALCULA O VALOR UNITARIO DO IMPOSTO 	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CDM->CDM_BSSAI  := (nBase/nQtd)*nQtd
CDM->CDM_ICMSAI := (nIcms/nQtd)*nQtd
CDM->CDM_ALQSAI := nAliq
CDM->CDM_UFSAI  := cUF
CDM->CDM_DTSAI  := dEmissao
CDM->CDM_NSEQS  := cNumSeq
CDM->CDM_TIPO   := "L"       	// 'L' qdo vier de amarracao por LOTE-SubLote
CDM->CDM_TIPODB := cTpNF
CDM->CDM_CFSAI  := cCF
CDM->CDM_BSSRET := nBrSai
CDM->CDM_TES    := cTesS
If cMVEstado <> "SP" //$ "RS/SC/PR/GO/ES"
	CDM->CDM_BSERET := nBseRet
Endif

CDM->(MsUnLock())

Return()

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³DevCompr  ºAutor  ³ Angelica N. Rabelo º Data ³  16/07/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Funcao de processamento das notas fiscais de DEVOLUCAO DE   º±±
//±±º          ³COMPRAS a fim de estornar SALDOS CDM para que nao sejam uti-º±±
//±±º          ³lizadas qtdes indevidas nos proximos calculos de Credito.   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ cDtPer - Periodo que sera considerado p/ NF's Saida	    º±±
//±±³          | dDtDe,dDtAte - Periodo considerado para REPROCESSAMENTO    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        
Static Function DevCompr(dDtDe,dDtAte,cMVEstado)

Local cAliasSD2 := "SD2"
Local aAreaAtu 	:= GetArea()
Local aStruSD2 	:= {}
Local nEstDeb 	:= 0
Local lSerieId 	:= SerieNfId("SD2",3,"D2_SERIE") == "D2_SDOC"

#IFDEF TOP
	
	If TcSrvType()<>"AS/400"
		cFiltro := "%"
		If cMVEstado <> "SP" //"RS/SC/PR/GO/ES"
			cFiltro += " SB1.B1_CRICMST= '" +%Exp:("1")% +"'
		Else
			cFiltro += " SB1.B1_CRICMS= '" +%Exp:("1")% +"'
		EndIf
		cFiltro += "%"
		lQuery    :=.t.
		cAliasSD2 := GetNextAlias()
		
		BeginSql Alias cAliasSD2
			COLUMN D2_EMISSAO AS DATE
			SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM, SD2.D2_NUMSEQ, SD2.D2_CF,
			SD2.D2_QUANT, SD2.D2_EMISSAO, SD2.D2_PICM, SD2.D2_VALICM, SD2.D2_BASEICM, SD2.D2_EST, SD2.D2_TIPO,
			SD2.D2_NFORI, SD2.D2_SERIORI, SD2.D2_ITEMORI
			FROM %table:SD2% SD2,%table:SF4% SF4,%table:SB1% SB1
			WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
			SD2.D2_EMISSAO >=%Exp:dDtDe% AND
			SD2.D2_EMISSAO <=%Exp:dDtAte% AND
			SD2.D2_TIPO IN('D','B') AND
			SD2.%NotDel% AND
			SF4.F4_FILIAL = %xFilial:SF4% AND
			SF4.F4_CODIGO = D2_TES AND
			SF4.%NotDel% AND
			SB1.B1_FILIAL = %xFilial:SB1% AND
			SB1.B1_COD = D2_COD AND
			SB1.%NotDel% AND
			(%Exp:cFiltro%)
		EndSql
		
		dbSelectArea(cAliasSD2)
		
	Else
		
	#ENDIF
	
	cSD2    :=	CriaTrab(Nil,.F.)
	cChave	:=  SD2->(IndexKey())
	cCondicao 	:= "D2_FILIAL == '" + xFilial("SD2") + "' .AND. "
	cCondicao 	+= "dtos(D2_EMISSAO) >= '"+DToS(dDtDe)+"' .AND. "
	cCondicao 	+= "dtos(D2_EMISSAO) <= '"+DToS(dDtAte)+"' .AND. "
	cCondicao 	+= "D2_TIPO == 'D'"
	
	IndRegua(cAliasSD2,cSD2,cChave,,cCondicao,STR0010) //"Selecionado registros"
	#IFNDEF TOP
		DbSetIndex(cSD2+OrdBagExt())
	#ENDIF
	dbselectarea(cAliasSD2)
	(cAliasSD2)->(dbGotop())
	
	#IFDEF TOP
	Endif
#ENDIF

If !lQuery
	
	AADD(aStruSD2,{"D2_FILIAL","C",TamSX3("D2_FILIAL")[1],TamSX3("D2_FILIAL")[2]})
	AADD(aStruSD2,{"D2_DOC","C",TamSX3("D2_DOC")[1],TamSX3("D2_DOC")[2]})
	AADD(aStruSD2,{"D2_SERIE","C",TamSX3("D2_SERIE")[1],TamSX3("D2_SERIE")[2]})
	AADD(aStruSD2,{"D2_CLIENTE","C",TamSX3("D2_CLIENTE")[1],TamSX3("D2_CLIENTE")[2]})
	AADD(aStruSD2,{"D2_LOJA","C",TamSX3("D2_LOJA")[1],TamSX3("D2_LOJA")[2]})
	AADD(aStruSD2,{"D2_ITEM","C",TamSX3("D2_ITEM")[1],TamSX3("D2_ITEM")[2]})
	AADD(aStruSD2,{"D2_COD","C",TamSX3("D2_COD")[1],TamSX3("D2_COD")[2]})
	AADD(aStruSD2,{"D2_TES","C",TamSX3("D2_TES")[1],TamSX3("D2_TES")[2]})
	AADD(aStruSD2,{"D2_LOCAL","C",TamSX3("D2_LOCAL")[1],TamSX3("D2_LOCAL")[2]})
	AADD(aStruSD2,{"D2_EMISSAO","D",TamSX3("D2_EMISSAO")[1],TamSX3("D2_EMISSAO")[2]})
	AADD(aStruSD2,{"D2_QUANT","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]})
	AADD(aStruSD2,{"D2_BASEICM","N",TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]})
	AADD(aStruSD2,{"D2_VALICM","N",TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]})
	AADD(aStruSD2,{"D2_PICM","N",TamSX3("D2_PICM")[1],TamSX3("D2_PICM")[2]})
	AADD(aStruSD2,{"D2_EST","C",TamSX3("D2_EST")[1],TamSX3("D2_EST")[2]})
	AADD(aStruSD2,{"D2_NUMSEQ","C",TamSX3("D2_NUMSEQ")[1],TamSX3("D2_NUMSEQ")[2]})
	AADD(aStruSD2,{"D2_NFORI","C",TamSX3("D2_NFORI")[1],TamSX3("D2_NFORI")[2]})
	AADD(aStruSD2,{"D2_SERIORI","C",TamSX3("D2_SERIORI")[1],TamSX3("D2_SERIORI")[2]})
	AADD(aStruSD2,{"D2_ITEMORI","C",TamSX3("D2_ITEMORI")[1],TamSX3("D2_ITEMORI")[2]})
	
	If lSerieId
		AADD(aStruSD2,{"D2_SDOC","C",TamSX3("D2_SDOC")[1],TamSX3("D2_SDOC")[2]})
		AADD(aStruSD2,{"D2_SDOCORI","C",TamSX3("D2_SDOCORI")[1],TamSX3("D2_SDOCORI")[2]})
	EndIf
	
	cArqSD2	:=	CriaTrab(aStruSD2)
	dbUseArea(.T.,__LocalDriver,cArqSD2,"TRR")
	IndRegua("TRR",cArqSD2,"D2_FILIAL+D2_NFORI+D2_SERIORI+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEMORI")
	
	dbselectarea(cAliasSD2)
	(cAliasSD2)->(dbGotop())
	
	dbselectarea("TRR")
	dbGotop()
	
	While (cAliasSD2)->(!Eof())
		RecLock("TRR",.T.)
		TRR->D2_FILIAL := (cAliasSD2)->D2_FILIAL
		TRR->D2_DOC    := (cAliasSD2)->D2_DOC
		TRR->D2_SERIE  := (cAliasSD2)->D2_SERIE
		TRR->D2_CLIENTE:= (cAliasSD2)->D2_CLIENTE
		TRR->D2_LOJA   := (cAliasSD2)->D2_LOJA
		TRR->D2_ITEM   := (cAliasSD2)->D2_ITEM
		TRR->D2_COD    := (cAliasSD2)->D2_COD
		TRR->D2_LOCAL  := (cAliasSD2)->D2_LOCAL
		TRR->D2_EMISSAO:= (cAliasSD2)->D2_EMISSAO
		TRR->D2_TES    := (cAliasSD2)->D2_TES
		TRR->D2_QUANT  := (cAliasSD2)->D2_QUANT
		TRR->D2_BASEICM:= (cAliasSD2)->D2_BASEICM
		TRR->D2_VALICM := (cAliasSD2)->D2_VALICM
		TRR->D2_PICM   := (cAliasSD2)->D2_PICM
		TRR->D2_EST    := (cAliasSD2)->D2_EST
		TRR->D2_NUMSEQ := (cAliasSD2)->D2_NUMSEQ
		TRR->D2_NFORI  := (cAliasSD2)->D2_NFORI
		TRR->D2_SERIORI:= (cAliasSD2)->D2_SERIORI
		TRR->D2_ITEMORI:= (cAliasSD2)->D2_ITEMORI
		
		If lSerieId
			TRR->D2_SDOC  := (cAliasSD2)->D2_SERIE
			TRR->D2_SDOCORI:= (cAliasSD2)->D2_SERIORI
		EndIf
		
		msUnlock()
		dbselectarea(cAliasSD2)
		(cAliasSD2)->(dbSkip())
	Enddo
	
	(cAliasSD2)->(dbCloseArea())
	cAliasSD2 := "TRR"
	
	dbselectarea(cAliasSD2)
	(cAliasSD2)->(dbGotop())
	
Endif

ProcRegua(LastRec())

While (cAliasSD2)->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra apenas aqueles Produtos/TES configurados para tal operacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lQuery
		If cMVEstado <> "SP" //"RS/SC/PR/GO/ES"
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			if SB1->B1_CRICMST <> '1'
				(cAliasSD2)->(dbSkip())
				Loop
			endif
		Else
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			if SB1->B1_CRICMS <> '1'
				(cAliasSD2)->(dbSkip())
				Loop
			endif
		Endif
	Endif
	
	dbSelectArea("CDM")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se NF. Devolucao Compras (NF Saida) existe em CDM.                                    |
	//³ Em caso afirmativo, estorna SALDO CDM da qtde. que esta sendo devolvida.      	 		      ³
	//| Obs.: vai posicionar apenas nas ocorrencias em CDM que sejam SALDOS INICIAIS DA NFE            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if (CDM->(dbSeek(xFilial("CDM")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+;
			(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD)))
		
		Do while CDM->CDM_DOCENT==(cAliasSD2)->D2_NFORI .and. CDM->CDM_SERIEE==(cAliasSD2)->D2_SERIORI .and.;
				CDM->CDM_FORNEC==(cAliasSD2)->D2_CLIENTE .and. CDM->CDM_LJFOR==(cAliasSD2)->D2_LOJA
			
			if !eof() .and. CDM->CDM_SALDO<>0 .and. CDM->CDM_TIPO=='S'
				
				if (CDM->CDM_SALDO - (cAliasSD2)->D2_QUANT) < 0
					nNewSld := 0
				else
					nNewSld := CDM->CDM_SALDO - (cAliasSD2)->D2_QUANT
					nEstDeb := IIf(CDM->CDM_ICMENT > 0, CDM->CDM_ICMENT * (cAliasSD2)->D2_QUANT, CDM->CDM_ICMMAN * (cAliasSD2)->D2_QUANT)
					If nEstDeb > 0
						RecSaiSd2((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_ITEM,"D",nEstDeb,(cAliasSD2)->D2_QUANT)
					Endif
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Nao pode abater de CDM_SALDO qtde JA ASSOCIADA em NF's Saida, i.e., ja utilizadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("CDM",.F.)
				CDM->CDM_SALDO  := nNewSld
				MsUnlock()
				FkCommit()
			endif						
			(cAliasSD2)->(dbSkip())			
		Enddo		
	Else		
		(cAliasSD2)->(dbSkip())		
	Endif
	
EndDo

(cAliasSD2)->(dbCloseArea())

RestArea(aAreaAtu)


Return()             

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³DevVendas ºAutor  ³ Angelica N. Rabelo º Data ³  17/07/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Funcao de processamento das notas fiscais de DEVOLUCAO DE   º±±
//±±º          ³VENDAS a fim de estornar os SALDOS CDM para que nao sejam   º±±
//±±º          ³utilizadas qtdes indevidas no calculo do Credito.           º±±
//±±º          ³Vai processar o ESTORNO de creditos ja calculados anterior- º±±
//±±º          ³mente e apresentar da APURACAO ICMS 					    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ dDtIni/dDtFim - Periodo que sera considerado p/ NF's Saida º±±
//±±³          | Devolucao Vendas.                                          º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        
Static Function DevVendas(dDtDe,dDtAte,cMVEstado)
 
Local cAliasSD1 := "SD1"
Local aAreaAtu  := GetArea()
Local nNewSld   := 0             

#IFDEF TOP
	
	If TcSrvType()<>"AS/400"							          		 
    	cFiltro := "%"	
		If cMVEstado <> "SP" // "RS/SC/PR/GO/ES"
			cFiltro += " SB1.B1_CRICMST= '" +%Exp:("1")% +"'  	
		Else	
			cFiltro += " SB1.B1_CRICMS= '" +%Exp:("1")% +"'
		EndIf		
		cFiltro += "%"
    	lQuery    :=.t.   
        cAliasSD1 := GetNextAlias()   
        cChave := SD1->(IndexKey(6))
        
	    BeginSql Alias cAliasSD1
				COLUMN D1_DTDIGIT AS DATE   
				COLUMN D1_EMISSAO AS DATE 
				SELECT SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_NUMSEQ, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, 
				       SD1.D1_COD, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_EMISSAO, SD1.D1_PICM, SD1.D1_VALICM, SD1.D1_TES,  
				       SD1.D1_BASEICM, SD1.D1_ICMNDES, SD1.D1_BASNDES, SD1.D1_TOTAL, SD1.D1_VALFRE, SD1.D1_SEGURO, 
				       SD1.D1_DESPESA, SD1.D1_VALDESC, SD1.D1_NFORI, SD1.D1_SERIORI,  SD1.D1_ITEMORI, SD1.D1_CF, SF1.F1_EST 
			    FROM %table:SD1% SD1, %table:SF1% SF1, %table:SF4% SF4, %table:SB1% SB1
	        	WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
			          SD1.D1_DTDIGIT >=%Exp:dDtDe% AND
    	    		  SD1.D1_DTDIGIT <=%Exp:dDtAte% AND
			          SD1.D1_TIPO IN('D','B') AND
		    	      SD1.%NotDel% AND
		        	  SF1.F1_FILIAL  = %xFilial:SF1% AND
			          SF1.F1_DOC     = SD1.D1_DOC AND
			          SF1.F1_SERIE   = SD1.D1_SERIE AND
	    	          SF1.F1_FORNECE = SD1.D1_FORNECE AND
	        	      SF1.F1_LOJA    = SD1.D1_LOJA AND
		        	  SF1.F1_TIPO    = SD1.D1_TIPO AND
		              SF1.%NotDel% AND
			          SF4.F4_FILIAL = %xFilial:SF4% AND
			          SF4.F4_CODIGO = SD1.D1_TES AND
	            	  SF4.%NotDel% AND
			          SB1.B1_FILIAL = %xFilial:SB1% AND
		              SB1.B1_COD    = SD1.D1_COD AND		   
			          SB1.%NotDel% AND
				      (%Exp:cFiltro%)		          		
		        ORDER BY 1,2,3 DESC
    	EndSql        
                
		dbSelectArea(cAliasSD1)         
		 
	Else
		                  
#ENDIF                                                       
                     		
		cSD1    :=	CriaTrab(Nil,.F.)
	    cChave	:=  SD1->(IndexKey(6))		
		cCondicao 	:= "D1_FILIAL == '" + xFilial("SD1") + "' .AND. "  
		cCondicao 	+= "dtos(D1_DTDIGIT) >= '"+DToS (dDtDe)+"' .AND. " 
		cCondicao 	+= "dtos(D1_DTDIGIT) <= '"+DToS (dDtAte)+"' .AND. " 
		cCondicao 	+= "D1_TIPO = 'D'"	  		  

	    IndRegua(cAliasSD1,cSD1,cChave,,cCondicao,STR0002) //"Selecionado registros"  	  	  
	    DbGoBottom()  
	    
		#IFNDEF TOP
			DbSetIndex(cSD1+OrdBagExt())
		#ENDIF     
		dbSelectarea(cAliasSD1)           
		(cAliasSD1)->(dbGotop())

#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())                	                       	    	                                                                		

While (cAliasSD1)->(!Eof())     
	   
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Filtra apenas aqueles Produtos/TES configurados para tal operacao³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                
  	   
  	   if !lQuery	        
  	     If cMVEstado <> "SP" //$ "RS/SC/PR/GO/ES"
  	      	 SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))	
		  	 if SB1->B1_CRICMST <> '1'
	  	         (cAliasSD1)->(dbSkip())
			     Loop   	        	      
	  	     Endif
	     Else
	  	     SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))	
		     if SB1->B1_CRICMS <> '1'
	  	         (cAliasSD1)->(dbSkip())
			     Loop   	        	      
	  	     endif      	         								     
  	     Endif 	  	    
  	   Endif
  	                                                          
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica se NF.Devolucao Vendas (NF Saida Origem) existe na CDM.                                  |	                                                                       |
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   
	   
	   dbSelectArea("CDM")				  
       dbSetOrder(2)
       (CDM->(dbSeek(xFilial("CDM")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+;
                                     (cAliasSD1)->D1_LOJA+substr((cAliasSD1)->D1_ITEMORI,1,2)+(cAliasSD1)->D1_COD)))                                            
       If !eof()                  
                  	       	  
  		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³Busca NFEntrada correspondente para SOMAR Qtde Devolvida ao SALDO³
	      //|CDM e assim disponibiliza-lo para novo calculo de credito em     |
	      //|futuras Vendas p/ Fora Estado                                    |	      
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	       
	           	       	
     	  dbSelectArea("CDM")				  
          dbSetOrder(1)                                                                                                
          (CDM->(dbSeek(xFilial("CDM")+CDM->CDM_DOCENT+CDM->CDM_SERIEE+CDM->CDM_FORNEC+CDM->CDM_LJFOR+;
                                        CDM->CDM_ITENT+CDM->CDM_PRODUT+CDM->CDM_NSEQE+"S")))
     		     	       	  
     	  if !eof()                                     
	          RecLock("CDM",.F.)   	                     	          	          	          	          	             
	          nNewSld := CDM->CDM_SALDO + (cAliasSD1)->D1_QUANT   	      	 
	          if nNewSld <= CDM->CDM_QTDENT
    	         CDM->CDM_SALDO := nNewSld	      	 
    	      endif   
		  	  MsUnlock()
	   		  FkCommit()           
	   	  endif                                                 		  		  		   		         	                                           	          
	      
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  	   	    	   	  	   	  
	      //³ Posiciona NF Origem para calcular valor a estornar de Credito   |
	      //³ de acordo com qtde devolvida                                    |
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  	   	    	   	  	   	      
	      
	      dbSelectArea("CDM")				  
          dbSetOrder(2)      	   
          (CDM->(dbSeek(xFilial("CDM")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+;
                                     (cAliasSD1)->D1_LOJA+substr((cAliasSD1)->D1_ITEMORI,1,2)+(cAliasSD1)->D1_COD)))
                    
	      nSldEst := (CDM->CDM_ICMENT / CDM->CDM_QTDVDS) * (cAliasSD1)->D1_QUANT // Calcula VALOR CREDITO A ESTORNAR na CDM	                	  
	   	  
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  	   	    	   	  	   	  
	      //³ Grava NF Devolucao em CDM para demonstrar no relatorio e ser      |
	      //³ considerado na Apuracao p/estornar valores do Crédito na Apur.ICMS|                              
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  	   	    	   	  	   	      	      	   
	   	  
	   	  RecEntSD1((cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_EMISSAO,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_FORNECE,;
	   	            (cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_ITEM,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_QUANT,0,0,0,,(cAliasSD1)->D1_NUMSEQ,,0,0,0,0,0,0,"D",0,(cAliasSD1)->D1_CF,(cAliasSD1)->D1_TES,nSldEst)	   	            	   	            	  	   	            
	   	             	   	             	   	  	   	  	   	  	  
       Endif
       
	   dbSelectarea(cAliasSD1)     	  
	   (cAliasSD1)->(dbSkip())                                                     		  		  		   		         	                                           	          	   
	   	   		      
EndDo  	 
                          
(cAliasSD1)->(dbCloseArea())

RestArea(aAreaAtu)

Return    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³AJUSTCPR  ºAutor  ³ Angelica N. Rabelo º Data ³  17/07/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ Ajusta CDM baseado nos Complementos de Precos			    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ dDtDe,dDtAte (Periodo a considerar)						º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        
Static Function AjustCPR(dDtDe,dDtAte)

Local QCDM     	:= "CDM"
Local aAreaAtu 	:= GetArea()
Local aStruCDM 	:= {}
Local lQuery   	:= .F.
Local QQRY     	:= "SD1"
Local lSerieId  	:= SerieNfId("CDM",3,"CDM_SERIEE") == "CDM_SDOCE"

#IFDEF TOP
	
	If TcSrvType()<>"AS/400"
		lQuery :=.t.
		QCDM   := GetNextAlias()
		BeginSql Alias QCDM
			COLUMN CDM_DTDGEN AS DATE
			COLUMN CDM_DTENT AS DATE
			SELECT CDM.CDM_FILIAL, CDM.CDM_PRODUT, CDM.CDM_DTDGEN, CDM.CDM_FILIAL, CDM.CDM_DOCENT, CDM.CDM_SERIEE,
			CDM.CDM_FORNEC, CDM.CDM_LJFOR, CDM.CDM_ITENT, CDM.CDM_NSEQE, CDM.CDM_TIPO, CDM.CDM_DTENT,
			CDM.CDM_SALDO, CDM.CDM_DTENT, CDM.CDM_BSENT
			FROM %table:CDM% CDM
			WHERE CDM.CDM_FILIAL = %xFilial:CDM% AND
			CDM.CDM_DTENT >=%Exp:dDtDe% AND
			CDM.CDM_DTENT <=%Exp:dDtAte% AND
			CDM.CDM_TIPO = 'C' AND
			CDM.%NotDel%
			ORDER BY 1,2,3 DESC			
		EndSql
		
	Else
		
	#ENDIF
	cAliasCDM  := CriaTrab(Nil,.F.)
	cChave	   := "dtos(CDM_DTDGEN)+CDM_PRODUT+CDM_FILIAL"
	cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
	cCondicao  += "dtos(CDM_DTENT) >= '" + dtos(dDtDe) + "' .AND. "
	cCondicao  += "dtos(CDM_DTENT) <= '" + dtos(dDtAte) + "' .AND. "
	cCondicao  += "CDM_TIPO == 'C'"
	IndRegua(QCDM,cAliasCDM,cChave,,cCondicao,STR0002) //"Selecionado registros"
	
	DbGoBottom()
	#IFNDEF TOP
		dbSetIndex(cAliasCDM+OrdBagExt())
	#ENDIF
	dbselectarea(QCDM)
	(QCDM)->(dbGotop())
	
	#IFDEF TOP
	Endif
#ENDIF

ProcRegua(LastRec())

If !lQuery
	AADD(aStruCDM,{"CDM_FILIAL","C",TamSX3("CDM_FILIAL")[1],TamSX3("CDM_FILIAL")[2]})
	AADD(aStruCDM,{"CDM_DOCENT","C",TamSX3("CDM_DOCENT")[1],TamSX3("CDM_DOCENT")[2]})
	AADD(aStruCDM,{"CDM_SERIEE","C",TamSX3("CDM_SERIEE")[1],TamSX3("CDM_SERIEE")[2]})
	AADD(aStruCDM,{"CDM_DTENT","D",TamSX3("CDM_DTENT")[1],TamSX3("CDM_DTENT")[2]})
	AADD(aStruCDM,{"CDM_FORNEC","C",TamSX3("CDM_FORNEC")[1],TamSX3("CDM_FORNEC")[2]})
	AADD(aStruCDM,{"CDM_LJFOR","C",TamSX3("CDM_LJFOR")[1],TamSX3("CDM_LJFOR")[2]})
	AADD(aStruCDM,{"CDM_ITENT","C",TamSX3("CDM_ITENT")[1],TamSX3("CDM_ITENT")[2]})
	AADD(aStruCDM,{"CDM_PRODUT","C",TamSX3("CDM_PRODUT")[1],TamSX3("CDM_PRODUT")[2]})
	AADD(aStruCDM,{"CDM_QTDENT","N",TamSX3("CDM_QTDENT")[1],TamSX3("CDM_QTDENT")[2]})
	AADD(aStruCDM,{"CDM_QTDVDS","N",TamSX3("CDM_QTDVDS")[1],TamSX3("CDM_QTDVDS")[2]})
	AADD(aStruCDM,{"CDM_SALDO","N",TamSX3("CDM_SALDO")[1],TamSX3("CDM_SALDO")[2]})
	AADD(aStruCDM,{"CDM_NSEQE","C",TamSX3("CDM_NSEQE")[1],TamSX3("CDM_NSEQE")[2]})
	AADD(aStruCDM,{"CDM_NSEQS","C",TamSX3("CDM_NSEQS")[1],TamSX3("CDM_NSEQS")[2]})
	AADD(aStruCDM,{"CDM_DOCSAI","C",TamSX3("CDM_DOCSAI")[1],TamSX3("CDM_DOCSAI")[2]})
	AADD(aStruCDM,{"CDM_SERIES","C",TamSX3("CDM_SERIES")[1],TamSX3("CDM_SERIES")[2]})
	AADD(aStruCDM,{"CDM_CLIENT","C",TamSX3("CDM_CLIENT")[1],TamSX3("CDM_CLIENT")[2]})
	AADD(aStruCDM,{"CDM_LJCLI","C",TamSX3("CDM_LJCLI")[1],TamSX3("CDM_LJCLI")[2]})
	AADD(aStruCDM,{"CDM_ITSAI","C",TamSX3("CDM_ITSAI")[1],TamSX3("CDM_ITSAI")[2]})
	AADD(aStruCDM,{"CDM_TIPO","C",TamSX3("CDM_TIPO")[1],TamSX3("CDM_TIPO")[2]})
	AADD(aStruCDM,{"CDM_DTDGEN","D",TamSX3("CDM_DTDGEN")[1],TamSX3("CDM_DTDGEN")[2]})
	AADD(aStruCDM,{"CDM_BSENT","N",TamSX3("CDM_BSENT")[1],TamSX3("CDM_BSENT")[2]})
	AADD(aStruCDM,{"CDM_ICMENT","N",TamSX3("CDM_ICMENT")[1],TamSX3("CDM_ICMENT")[2]})
	AADD(aStruCDM,{"CDM_BSSAI","N",TamSX3("CDM_BSSAI")[1],TamSX3("CDM_BSSAI")[2]})
	AADD(aStruCDM,{"CDM_ICMSAI","N",TamSX3("CDM_ICMSAI")[1],TamSX3("CDM_ICMSAI")[2]})
	AADD(aStruCDM,{"CDM_ALQSAI","N",TamSX3("CDM_ALQSAI")[1],TamSX3("CDM_ALQSAI")[2]})
	AADD(aStruCDM,{"CDM_UFSAI","C",TamSX3("CDM_UFSAI")[1],TamSX3("CDM_UFSAI")[2]})
	AADD(aStruCDM,{"CDM_DTSAI","D",TamSX3("CDM_DTSAI")[1],TamSX3("CDM_DTSAI")[2]})
	AADD(aStruCDM,{"CDM_ALQENT","N",TamSX3("CDM_ALQENT")[1],TamSX3("CDM_ALQENT")[2]})
	AADD(aStruCDM,{"CDM_UFENT","C",TamSX3("CDM_UFENT")[1],TamSX3("CDM_UFENT")[2]})
	AADD(aStruCDM,{"CDM_BASMAN","N",TamSX3("CDM_BASMAN")[1],TamSX3("CDM_BASMAN")[2]})
	AADD(aStruCDM,{"CDM_ICMMAN","N",TamSX3("CDM_ICMMAN")[1],TamSX3("CDM_ICMMAN")[2]})
	
	If lSerieId
		AADD(aStruCDM,{"CDM_SDOCE","C",TamSX3("CDM_SDOCE")[1],TamSX3("CDM_SDOCE")[2]})
		AADD(aStruCDM,{"CDM_SDOCS","C",TamSX3("CDM_SDOCS")[1],TamSX3("CDM_SDOCS")[2]})
	EndIf
	
	cArqCDM	:=	CriaTrab(aStruCDM)
	dbUseArea(.T.,__LocalDriver,cArqCDM,"TRB")
	IndRegua("TRB",cArqCDM,"CDM_FILIAL+CDM_PRODUT+DTOS(CDM_DTDGEN)+CDM_NSEQE")
	
	dbselectarea(QCDM)
	(QCDM)->(dbGotop())
	
	dbselectarea("TRB")
	dbGotop()
	
	While (QCDM)->(!Eof())
		RecLock("TRB",.T.)
		TRB->CDM_FILIAL := (QCDM)->CDM_FILIAL
		TRB->CDM_DOCENT := (QCDM)->CDM_DOCENT
		TRB->CDM_SERIEE := (QCDM)->CDM_SERIEE
		TRB->CDM_FORNEC := (QCDM)->CDM_FORNEC
		TRB->CDM_LJFOR  := (QCDM)->CDM_LJFOR
		TRB->CDM_ITENT  := (QCDM)->CDM_ITENT
		TRB->CDM_PRODUT := (QCDM)->CDM_PRODUT
		TRB->CDM_QTDENT := (QCDM)->CDM_QTDENT
		TRB->CDM_QTDVDS := (QCDM)->CDM_QTDVDS
		TRB->CDM_DOCSAI := (QCDM)->CDM_DOCSAI
		TRB->CDM_SERIES := (QCDM)->CDM_SERIES
		TRB->CDM_CLIENT := (QCDM)->CDM_CLIENT
		TRB->CDM_LJCLI  := (QCDM)->CDM_LJCLI
		TRB->CDM_ITSAI  := (QCDM)->CDM_ITSAI
		TRB->CDM_NSEQS  := (QCDM)->CDM_NSEQS
		TRB->CDM_SALDO  := (QCDM)->CDM_SALDO
		TRB->CDM_NSEQE  := (QCDM)->CDM_NSEQE
		TRB->CDM_TIPO   := (QCDM)->CDM_TIPO
		TRB->CDM_DTDGEN := (QCDM)->CDM_DTDGEN
		TRB->CDM_BSENT	:= (QCDM)->CDM_BSENT
		TRB->CDM_ICMENT := (QCDM)->CDM_ICMENT
		TRB->CDM_BSSAI	:= (QCDM)->CDM_BSSAI
		TRB->CDM_ICMSAI := (QCDM)->CDM_ICMSAI
		TRB->CDM_ALQSAI := (QCDM)->CDM_ALQSAI
		TRB->CDM_UFSAI	:= (QCDM)->CDM_UFSAI
		TRB->CDM_DTSAI  := (QCDM)->CDM_DTSAI
		TRB->CDM_ALQENT := (QCDM)->CDM_ALQENT
		TRB->CDM_UFENT  := (QCDM)->CDM_UFENT
		TRB->CDM_BASMAN := (QCDM)->CDM_BASMAN
		TRB->CDM_ICMMAN := (QCDM)->CDM_ICMMAN
		
		If lSerieId
			TRB->CDM_SDOCE := (QCDM)->CDM_SDOCE
			TRB->CDM_SDOCS := (QCDM)->CDM_SDOCS
		EndIf
		
		msUnlock()
		dbselectarea(QCDM)
		(QCDM)->(dbSkip())
	Enddo
	
	(QCDM)->(dbCloseArea())
	QCDM := "TRB"
	
	dbselectarea(QCDM)
	(QCDM)->(dbGotop())
	
Endif

lQuery := .F.

dbselectarea(QCDM)
(QCDM)->(dbGotop())

While !eof()
	
	cDocEnt := (QCDM)->CDM_DOCENT
	cSerieE := (QCDM)->CDM_SERIEE
	cFornec := (QCDM)->CDM_FORNEC
	cLoj    := (QCDM)->CDM_LJFOR
	cProdt  := (QCDM)->CDM_PRODUT
	cItem   := (QCDM)->CDM_ITENT
	
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery    :=.t.
			QQRY := GetNextAlias()
			BeginSql Alias QQRY
				SELECT SD1.D1_FILIAL, SD1.D1_NFORI, SD1.D1_SERIORI, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_ITEMORI, SD1.D1_COD,
				SD1.D1_BASEICM, CDM.CDM_BSENT, CDM.CDM_ICMENT, CDM.CDM_ALQENT, CDM.CDM_QTDENT, CDM.CDM_TIPO,
				CDM.CDM_DOCENT, CDM.CDM_SERIEE, CDM.CDM_FORNEC, CDM.CDM_LJFOR,CDM.CDM_PRODUT, CDM.CDM_ITENT,
				CDM.CDM_NSEQE
				FROM %table:SD1% SD1, %table:CDM% CDM
				WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
				SD1.D1_DOC = %Exp:cDocEnt% AND
				SD1.D1_SERIE = %Exp:cSerieE% AND
				SD1.D1_FORNECE = %Exp:cFornec% AND
				SD1.D1_LOJA = %Exp:cLoj% AND
				SD1.D1_COD = %Exp:cProdt% AND
				SD1.D1_ITEM = %Exp:cItem% AND
				SD1.%NotDel% AND
				CDM.CDM_DOCENT = SD1.D1_NFORI AND
				CDM.CDM_SERIEE = SD1.D1_SERIORI AND
				CDM.CDM_FORNEC = SD1.D1_FORNECE AND
				CDM.CDM_LJFOR = SD1.D1_LOJA AND
				CDM.CDM_ITENT = SD1.D1_ITEMORI AND
				CDM.CDM_PRODUT = SD1.D1_COD AND
				CDM.CDM_TIPO = 'S' AND
				CDM.%NotDel%
				ORDER BY 1,2,3,4,5
			EndSql
			
		Else
			
		#ENDIF
		cAliasQQRY  := CriaTrab(Nil,.F.)
		cChave	   := "D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_ITEMORI+D1_COD"
		cCondicao  := "D1_FILIAL == '"+xFilial("SD1")+"' .AND. "
		cCondicao  += "D1_DOC  == '" + cDocEnt + "' .AND. "
		cCondicao  += "D1_SERIE == '" + cSerieE + "' .AND. "
		cCondicao  += "D1_FORNECE == '" + cFornec + "' .AND. "
		cCondicao  += "D1_LOJA == '" + cLoj + "' .AND. "
		cCondicao  += "D1_COD == '" + cProdt + "' .AND. "
		cCondicao  += "D1_ITEM == '" + cItem + "' "
		IndRegua(QQRY,cAliasQQRY,cChave,,cCondicao,STR0002) //"Selecionando registros"
		DbGoBottom()
		#IFNDEF TOP
			dbSetIndex(cAliasQQRY+OrdBagExt())
		#ENDIF
		dbselectarea(QQRY)
		(QQRY)->(dbGotop())
		
		#IFDEF TOP
		Endif
	#ENDIF
	
	ProcRegua(LastRec())
	
	dbselectarea(QQRY)
	(QQRY)->(dbGotop())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aqui vai fazer o reajuste de Valores (de acordo com o Complemen-|
	//| to nas NF's gravadas em CDM.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !eof()
		
		if !lQuery
			dbSelectarea("CDM")
			dbsetorder(1)
			dbSeek(xFilial("CDM")+(QQRY)->D1_NFORI+(QQRY)->D1_SERIORI+(QQRY)->D1_FORNECE+(QQRY)->D1_LOJA+(QQRY)->D1_ITEMORI+(QQRY)->D1_COD)
			
			do while CDM->CDM_TIPO<>'S' .and. !eof()
				dbSelectarea("CDM")
				dbSkip()
			enddo
			dbSelectarea("CDM")
			reclock("CDM",.F.)
			CDM->CDM_BSENT  += (QQRY)->D1_BASEICM
			CDM->CDM_ICMENT := ((CDM->CDM_BSENT * CDM->CDM_ALQENT) /100) / CDM->CDM_QTDENT
			msUnlock()
			
		else
			
			dbSelectarea("CDM")
			dbsetorder(1)
			dbseek(xFilial("CDM")+(QQRY)->CDM_DOCENT+(QQRY)->CDM_SERIEE+(QQRY)->CDM_FORNEC+(QQRY)->CDM_LJFOR+(QQRY)->CDM_ITENT+(QQRY)->CDM_PRODUT+(QQRY)->CDM_NSEQE+(QQRY)->CDM_TIPO)
			if !eof()
				reclock("CDM",.F.)
				CDM->CDM_BSENT  += (QQRY)->D1_BASEICM
				CDM->CDM_ICMENT := ((CDM->CDM_BSENT * (QQRY)->CDM_ALQENT) /100) / (QQRY)->CDM_QTDENT
				msUnlock()
			endif
			
		endif
		
		dbselectarea(QQRY)
		dbSkip()
		
	Enddo
	
	dbselectarea(QCDM)
	dbSkip()
	
Enddo

RestArea(aAreaAtu)

(QCDM)->(dbCloseArea())
(QQRY)->(dbCloseArea())


Return    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³MONTASD3  ºAutor  ³ Angelica N. Rabelo º Data ³  14/10/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Pesquisa Movim. Internas a fim de checar TRANSFERENCIAS     º±±
//±±º          ³entre Produtos Similares, onde o Produto DESTINO eh vendido º±±
//±±º          |e cujo credito vai se basear no Doc.Entr.do Produto ORIGEM  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ cProd    - Codigo Produto 									º±±
//±±³          | cLoteCtl -	Lote											º±±
//±±³          | cNumLote - Sub-Lote							   	  		º±±
//±±³          | dDtVal   - Data Validade Lote					   	 		º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function MontaSD3(cProd,cLoteCtl,cNumLote,dDtVal)

Local aLote1   := {}         
Local cCond    := ""
Local QSD3     := "SD3"
Local QSD3Ori  := "SD3Ori"
Local cAliasSD3:= "SD3"
Local cNSQ     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movim.Interna (Transferencia Entrada DE4) do Produto VENDIDO (DESTINO) com         |
//| respectivos Lote/Sub-Lote/Dt.Valid indicados no Documento de Saida (passados como parametros)|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                             

#IFDEF TOP	  
	If TcSrvType()<>"AS/400"  
    	lQuery    :=.t.       
        QSD3 := GetNextAlias()
    	BeginSql Alias QSD3		  
			SELECT MAX(SD3.D3_NUMSEQ) AS D3_NUMSEQ
		    FROM %table:SD3% SD3, %table:SB1% SB1
	        WHERE SD3.D3_FILIAL = %xFilial:SD3% AND
	 	          SD3.D3_CF = 'DE4' AND
		  	      SD3.D3_COD = %Exp:cProd% AND
		  	      SD3.D3_LOTECTL = %Exp:cLoteCtl% AND
		  	      SD3.D3_NUMLOTE = %Exp:cNumLote% AND
		  	      SD3.D3_DTVALID = %Exp:dDtVal% AND		  	      		  	      
				  SD3.%NotDel% AND
	              SB1.B1_COD = SD3.D3_COD AND
				  SB1.%NotDel%		        			
        EndSql                       
               
	Else
		                  
#ENDIF                                                                                           
      	cAliasSD3  := CriaTrab(Nil,.F.)       
		cChave	   := SD3->(IndexKey(4))		
		cCondicao  := "D3_FILIAL == '"+xFilial("SD3")+"' .AND. "
	    cCondicao  += "D3_CF  == 'DE4' .AND. "
	 	cCondicao  += "D3_COD == '" + cProd + "' .AND. "	  	  	  
		cCondicao  += "D3_LOTECTL == '" + cLoteCtl + "' .AND. "	 
		cCondicao  += "D3_NUMLOTE == '" + cNumLote + "' .AND. "	 
		cCondicao  += "dtos(D3_DTVALID) == '" + dtos(dDtVal) + "' "	 		
		IndRegua(QSD3,cAliasSD3,cChave,,cCondicao,STR0002) //"Selecionado registros"  
        DbGoBottom()        
   		#IFNDEF TOP
			dbSetIndex(cAliasSD3+OrdBagExt())
	    #ENDIF 
	    dbselectarea(QSD3)               
	    (QSD3)->(dbGotop())			                            
    
#IFDEF TOP
    Endif    
#ENDIF    

ProcRegua(LastRec())    

dbselectarea(QSD3)               
(QSD3)->(dbGotop())

While !eof()

   cNSQ := cNSQ + (QSD3)->D3_NUMSEQ + '/'
		
   dbselectarea(QSD3) 
   dbSkip()        
    
Enddo

cCond := " AND D3_NUMSEQ IN " + FisxForm(cNSQ,"/") + " "    

If Empty(cCond)
	cCond := "%%"
Else                
	cCond := "% " + cCond + " %" 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movim.Internas de Transferencia Saida:        									 |
//| (RE4) do Produto Similar (ORIGEM)- esse Produto REQUER que haja controle de LOTE para que,   |
//| a partir desse, sejam selecionadas os Doc.Entrada do ORIGEM cujos valores serao utilizados no| 
//| calculo do credito do DESTINO (Produto Vendido).                                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

#IFDEF TOP	 	 
 If TcSrvType()<>"AS/400"      
	 lQuery    :=.t.       
     QSD3Ori  := GetNextAlias()     		        
  	 cDtLote:= Space(TamSx3("D3_DTVALID")[01])
   	 cLote  := Space(TamSx3("D3_LOTECTL")[01])    	                             	       	    	
   	 BeginSql Alias QSD3Ori
	     COLUMN D3_EMISSAO AS DATE   
	     COLUMN D3_DTVALID AS DATE
		 SELECT SD3.D3_FILIAL, SD3.D3_NUMSEQ, SD3.D3_CF, SD3.D3_CHAVE, SD3.D3_COD, SD3.D3_EMISSAO, SD3.D3_DOC, 
   		        SD3.D3_LOTECTL, SD3.D3_NUMLOTE, SD3.D3_DTVALID, SD3.D3_LOCAL, SD3.D3_QUANT   		        
		 FROM %table:SD3% SD3, %table:SB1% SB1
		 WHERE SD3.D3_FILIAL = %xFilial:SD3% AND
		 	   SD3.D3_CF ='RE4' AND			   		        		 	   		 	   
	  	 	   SD3.%NotDel% AND			   
   		       SD3.D3_COD = SB1.B1_COD AND
			   SB1.%NotDel%
		   	   %Exp:cCond%					 
		 ORDER BY D3_FILIAL, D3_NUMSEQ, D3_CF, D3_CHAVE, D3_COD                         	             
     EndSql	 			 	               	 
        		
 Else		  	                  
#ENDIF     

        cAliasSD3  := CriaTrab(Nil,.F.)       
		cChave	   := "D3_FILIAL+D3_NUMSEQ+D3_CF+D3_CHAVE+D3_COD"
		cCondicao  := "D3_FILIAL == '"+xFilial("SD3")+"' .AND. "
	    cCondicao  += "D3_CF  == 'RE4' .AND. "
	 	cCondicao  += "D3_NUMSEQ $ '" + cNSQ + "'" 	  	  		
		IndRegua(QSD3Ori,cAliasSD3,cChave,,cCondicao,STR0002) //"Selecionado registros"  
        DbGoBottom()        
   		#IFNDEF TOP
			dbSetIndex(cAliasSD3+OrdBagExt())
	    #ENDIF 
	    dbselectarea(QSD3Ori)               
	    (QSD3Ori)->(dbGotop())			                            
    
#IFDEF TOP
    Endif    
#ENDIF        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De posse das Movimentacoes Internas (Transferencia do Produto ORIGEM para Produto VENDIDO-   |
//| DESTINO), busca as NF's Entrada (SD1) do Produto ORIGEM para gravar esses documentos na CDM, |
//| fazer amarracao com a NF Saida.                                                              |
//| Obs.:o calculo do CREDITO do produto Destino sera feito com base na NFEntrada co Prod.ORIGEM.| 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

Do While (QSD3Ori)->(!Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Passa campos do registro RE4 (Requisicao) para determinar NF's Entrada do PRODUTO ORIGEM:    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

   	 AADD(aLote1,RetNFOrig((QSD3Ori)->D3_COD,(QSD3Ori)->D3_LOCAL,(QSD3Ori)->D3_LOTECTL,(QSD3Ori)->D3_NUMLOTE,(QSD3Ori)->D3_DTVALID))
     
     dbselectarea(QSD3Ori)   
     (QSD3Ori)->(dbSkip())
   
Enddo		  

(QSD3)->(dbCloseArea())
(QSD3Ori)->(dbCloseArea())

Return aLote1   

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³AJUSTRE4  ºAutor  ³ Angelica N. Rabelo º Data ³  04/11/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Busca SFK (registros tipo SAIDAS) para abater das ENTRADAS  º±±
//±±º          ³ja gravadas na CDM o SALDO transferido para outros Produtos º±±
//±±º          |                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ dDtDe,dDtAte (Periodo a ser considerado)					º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function AJUSTRE4(dDtDe,dDtAte,cMVEstado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona SFK - SAIDAS por Transferencias do periodo    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                         
      
Local cAliasSFK:= "SFK"
Local lQuery   := .f.
		                          
#IFDEF TOP
	
	If TcSrvType()<>"AS/400"							          		 
    	cFiltro := "%"	
		If cMVEstado <> "SP" //$ "RS/SC/PR/GO/ES"
			cFiltro += " SB1.B1_CRICMST= '" +%Exp:("1")% +"'  	
		Else 
			cFiltro += " SB1.B1_CRICMS= '" +%Exp:("1")% +"'
		EndIf		
		cFiltro += "%"
    	lQuery    :=.t.   
        cAliasSFK := GetNextAlias()   	
    	BeginSql Alias cAliasSFK
			 COLUMN FK_DATA AS DATE
	    	 SELECT SFK.FK_FILIAL, SFK.FK_DATA, SFK.FK_PRODUTO, SFK.FK_QTDE, SFK.FK_BRICMS,
		    	    SFK.FK_BASEICM, SFK.FK_AICMS, SFK.FK_TRFENT, SFK.FK_TRFSAI
	    	 FROM %table:SFK% SFK, %table:SB1% SB1
	    	 WHERE SFK.FK_FILIAL = %xFilial:SFK% AND	               
	    	       SFK.FK_DATA >= %Exp:dDtDe% AND
	    	       SFK.FK_DATA <= %Exp:dDtAte% AND    	    	      
	    	       SFK.FK_SALDO = '1' AND
				   SFK.FK_TRFSAI <> 0 AND
	    		   SFK.%NotDel% AND	          		   
	    		   SB1.B1_COD = SFK.FK_PRODUTO AND
	               SB1.%NotDel% AND
				   (%Exp:cFiltro%)
	               ORDER BY FK_FILIAL, FK_PRODUTO
		EndSql
        		
		dbSelectArea(cAliasSFK)
		 
	Else
		                  
#ENDIF 
	                    	
	  cSFK :=	CriaTrab(Nil,.F.)
	  cChave	:=  SFK->(IndexKey())
	  cCondicao := "FK_FILIAL == '" + xFilial("SFK") + "' .AND. " 
  	  cCondicao += "dtos(FK_DATA) >= '" + dtos(dDtDe) + "' .AND. "	  	  	  
	  cCondicao += "dtos(FK_DATA) <= '" + dtos(dDtAte) + "' .AND. "
	  cCondicao += "FK_SALDO == '1'.AND. "
	  cCondicao += "FK_TRFSAI <> 0 "
	  IndRegua(cAliasSFK,cSFK,cChave,,cCondicao,STR0010) //"Selecionado registros"  	  	  
	  	  
	  #IFNDEF TOP
		DbSetIndex(cSFK+OrdBagExt())
	  #ENDIF 
	  dbselectarea(cAliasSFK)               
	  (cAliasSFK)->(dbGotop())			
    
#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())                	                       	    	                                      

While (cAliasSFK)->(!Eof())        
   
	If !lQuery 		     
		If cMVEstado <> "SP"  //$ "RS/SC/PR/GO/ES" 
		   	SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))				
    		If SB1->B1_CRICMST<>'1'  
	 	    	(cAliasSFK)->(dbSkip())
	  			Loop
 			Endif
		Else
     		SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))				
    		If SB1->B1_CRICMS<>'1'  
	 	    	(cAliasSFK)->(dbSkip())
	  			Loop			
   	 		Endif	
		Endif		   	  	 
	Endif   
      
    ajustEntr((cAliasSFK)->FK_PRODUTO,(cAliasSFK)->FK_TRFSAI)
      
    dbselectarea(cAliasSFK)  
    (cAliasSFK)->(dbSkip())	 
       
Enddo

(cAliasSFK)->(dbCloseArea())

Return 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³AJUSTENTR ºAutor  ³ Angelica N. Rabelo º Data ³  05/11/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Busca CDM para abater Saldos das Requisicoes RE4.           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ cProd - Codigo Produto									    º±±
//±±³          | nQtd  - Quantidade a ajustar								º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function AJUSTENTR(cProd,nQtd)

Local nSaldo  := nQtd
Local nQtdCont:= nQtd
Local nTotSld :=0
Local nQtdAux := 0
Local aAreaAtu := GetArea()
Local QCDM := "CDM"
Local aStruCDM := {}
Local cArqCDM := "CDM"
Local lSerieId  	:= SerieNfId("CDM",3,"CDM_SERIEE") == "CDM_SDOCE"
Local cSerieId	:= Padr("CAT",TamSx3("CDM_SERIEE")[1])

#IFDEF TOP
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona ocorrencias do Produto cProduto existentes em CDM (gerando QCDM) provenientes de  |
	//| Doc.Entrada para iniciar as associacoes (calculo Credito ICMS) ENTRADA x SAIDA.             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If TcSrvType()<>"AS/400"
		lQuery    :=.t.
		QCDM := GetNextAlias()
		BeginSql Alias QCDM
			COLUMN CDM_DTDGEN AS DATE
			COLUMN CDM_DTENT AS DATE
			SELECT CDM.CDM_FILIAL, CDM.CDM_PRODUT, CDM.CDM_DTDGEN, CDM.CDM_DOCENT, CDM.CDM_SERIEE,
			CDM.CDM_FORNEC, CDM.CDM_LJFOR, CDM.CDM_ITENT, CDM.CDM_TIPO, CDM.CDM_DTENT, CDM.CDM_SALDO,
			CDM.CDM_DTENT, CDM.CDM_NSEQE
			FROM %table:CDM% CDM
			WHERE CDM.CDM_FILIAL = %xFilial:CDM% AND
			CDM.CDM_PRODUT = %Exp:cProd% AND
			CDM.CDM_SALDO > 0 AND
			CDM.CDM_TIPO = 'S' AND
			CDM.CDM_SERIEE <> cSerieId AND
			CDM.%NotDel%
			ORDER BY 1,2,3 DESC
			
		EndSql
		
	Else
		
	#ENDIF
	
	cAliasCDM  := CriaTrab(Nil,.F.)
	cChave	   := "dtos(CDM_DTDGEN)+CDM_PRODUT+CDM_FILIAL"
	cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
	cCondicao  += "CDM_PRODUTO == '"+cProd+"' .AND. "
	cCondicao  += "CDM_SALDO > 0 .AND. "
	cCondicao  += "CDM_TIPO == 'S'.AND. "
	cCondicao  += "CDM_SERIEE <> 'CAT'"
	IndRegua(QCDM,cAliasCDM,cChave,,cCondicao,STR0002) //"Selecionado registros"
	
	#IFNDEF TOP
		dbSetIndex(cAliasCDM+OrdBagExt())
	#ENDIF
	
	#IFDEF TOP
	Endif
#ENDIF

ProcRegua(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe Saldo em CDM (total) p/ ABATER NQTD de suas NFE's |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbselectarea(QCDM)
(QCDM)->(dbGotop())

While !eof()
	nTotSld := nTotSld + (QCDM)->CDM_SALDO
	(QCDM)->(dbSkip())
Enddo

dbselectarea(QCDM)
(QCDM)->(dbGotop())

IF nQtd >= nTotSld
	nQtd   := nTotSld
	nSaldo := nQtd
Endif

If !lQuery
	AADD(aStruCDM,{"CDM_FILIAL","C",TamSX3("CDM_FILIAL")[1],TamSX3("CDM_FILIAL")[2]})
	AADD(aStruCDM,{"CDM_DOCENT","C",TamSX3("CDM_DOCENT")[1],TamSX3("CDM_DOCENT")[2]})
	AADD(aStruCDM,{"CDM_SERIEE","C",TamSX3("CDM_SERIEE")[1],TamSX3("CDM_SERIEE")[2]})
	AADD(aStruCDM,{"CDM_FORNEC","C",TamSX3("CDM_FORNEC")[1],TamSX3("CDM_FORNEC")[2]})
	AADD(aStruCDM,{"CDM_LJFOR","C",TamSX3("CDM_LJFOR")[1],TamSX3("CDM_LJFOR")[2]})
	AADD(aStruCDM,{"CDM_ITENT","C",TamSX3("CDM_ITENT")[1],TamSX3("CDM_ITENT")[2]})
	AADD(aStruCDM,{"CDM_PRODUT","C",TamSX3("CDM_PRODUT")[1],TamSX3("CDM_PRODUT")[2]})
	AADD(aStruCDM,{"CDM_NSEQE","C",TamSX3("CDM_NSEQE")[1],TamSX3("CDM_NSEQE")[2]})
	AADD(aStruCDM,{"CDM_TIPO","C",TamSX3("CDM_TIPO")[1],TamSX3("CDM_TIPO")[2]})
	AADD(aStruCDM,{"CDM_DTDGEN","D",TamSX3("CDM_DTDGEN")[1],TamSX3("CDM_DTDGEN")[2]})
	AADD(aStruCDM,{"CDM_SALDO","N",TamSX3("CDM_SALDO")[1],TamSX3("CDM_SALDO")[2]})
	AADD(aStruCDM,{"CDM_DTENT","D",TamSX3("CDM_DTENT")[1],TamSX3("CDM_DTENT")[2]})
	
	If lSerieId
		AADD(aStruCDM,{"CDM_SDOCE","C",TamSX3("CDM_SDOCE")[1],TamSX3("CDM_SDOCE")[2]})
	EndIf
	
	cArqCDM	:=	CriaTrab(aStruCDM)
	dbUseArea(.T.,__LocalDriver,cArqCDM,"TRB")
	IndRegua("TRB",cArqCDM,"CDM_FILIAL+CDM_PRODUT+DTOS(CDM_DTDGEN)+CDM_NSEQE")
	
	dbselectarea(QCDM)
	(QCDM)->(dbGoBottom())
	
	While (QCDM)->(!Bof())
		recLock("TRB",.T.)
		TRB->CDM_FILIAL := (QCDM)->CDM_FILIAL
		TRB->CDM_DOCENT := (QCDM)->CDM_DOCENT
		TRB->CDM_SERIEE := (QCDM)->CDM_SERIEE
		TRB->CDM_DTENT  := (QCDM)->CDM_DTENT
		TRB->CDM_FORNEC := (QCDM)->CDM_FORNEC
		TRB->CDM_LJFOR  := (QCDM)->CDM_LJFOR
		TRB->CDM_ITENT  := (QCDM)->CDM_ITENT
		TRB->CDM_PRODUT := (QCDM)->CDM_PRODUT
		TRB->CDM_NSEQE  := (QCDM)->CDM_NSEQE
		TRB->CDM_TIPO   := (QCDM)->CDM_TIPO
		TRB->CDM_DTDGEN := (QCDM)->CDM_DTDGEN
		
		If lSerieId
			TRB->CDM_SDOCE := (QCDM)->CDM_SDOCE
		EndIf
		
		msUnlock()
		dbselectarea(QCDM)
		(QCDM)->(dbSkip(-1))
	Enddo
	
	(QCDM)->(dbCloseArea())
	QCDM := "TRB"
	
	dbselectarea(QCDM)
	(QCDM)->(dbGoBottom())
	
Else
	
	dbselectarea(QCDM)
	(QCDM)->(dbGoTop())
	
Endif

While nSaldo > 0 .And. nSaldo <= nTotSld  .And. ((QCDM)->(!Eof()) .And. !(QCDM)->(Bof()))
	
	nSaldo  := (QCDM)->CDM_SALDO - nSaldo
	
	dbSelectArea("CDM")
	dbSetOrder(1)
	If CDM->(DbSeek(xFilial("CDM")+(QCDM)->CDM_DOCENT+(QCDM)->CDM_SERIEE+(QCDM)->CDM_FORNEC+(QCDM)->CDM_LJFOR+;
			(QCDM)->CDM_ITENT+(QCDM)->CDM_PRODUT+(QCDM)->CDM_NSEQE+"S"))
		RecLock("CDM",.F.)
		CDM->CDM_SALDO := If(nSaldo > 0,nSaldo,0)
		CDM->(MsUnLock())
		
		If nSaldo < 0
			nSaldo := ABS(nSaldo)
			nQtdAux := nQtdCont - nSaldo
			
			nQtdCont -= nQtdAux
			nSaldo   := nQtdCont
		Else
			nQtdAux := nQtdCont
			nSaldo  := 0
		Endif
		
	Endif
	
	If !lQuery
		(QCDM)->(dbSkip(-1))
	else
		(QCDM)->(dbSkip())
	endif
	
EndDo


(QCDM)->(dbCloseArea())

RestArea(aAreaAtu)

                                        
Return
         
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³RETNFORIG ºAutor  ³ Angelica N. Rabelo º Data ³  14/10/09   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Pesquisa Requis. por Lote a fim de determinar os Documentos º±±
//±±º          ³Entrada do Produto Origem e grava-los na CDM para proceder  º±±
//±±º          |o calculo do credito do produto Destino - Vendido           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±³Parametros³ cCod : Produto Origem (comprado)							º±±
//±±³          | cLocal : Armazem											º±±
//±±³          | cLoteCtl : Lote											º±±
//±±³		   | cNumLote : Sub-Lote										º±±
//±±³		   | dDtVal   : Data Validade									º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function RetNFOrig(cCod,cLocal,cLoteCtl,cNumLote,dDtVal)

Local cAliasSD5:= 'SD5'
Local cDoc     := CriaVar("D5_DOC"    ,.F.)
Local cFornece := CriaVar("D5_CLIFOR" ,.F.)
Local cLoja    := CriaVar("D5_LOJA"   ,.F.)
Local aDocto   := {}

#IFNDEF TOP
    Local cChave	:=	""
	Local cIndex    :=	""
	Local cFiltro 	:=	""
#ENDIF

Default cCod     := ''
Default cLocal   := ''
Default cLoteCtl := ''
Default cNumLote := ''

#IFDEF TOP	 	 
 If TcSrvType()<>"AS/400"
     cAliasSD5 := GetNextAlias()       	  	                           	       	    	
   	 BeginSql Alias cAliasSD5	 	     
   	     COLUMN D1_EMISSAO AS DATE   
	     COLUMN D1_DTDIGIT AS DATE   	    	 
		 SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_EMISSAO, SD1.D1_DTDIGIT, SD1.D1_FORNECE, 
		        SD1.D1_LOJA, SD1.D1_ITEM, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_BASEICM, SD1.D1_VALICM, SD1.D1_PICM, 
		        SD1.D1_NUMSEQ, SD1.D1_ICMNDES, SD1.D1_BASNDES, SD1.D1_TOTAL, SD1.D1_VALFRE, SD1.D1_SEGURO, 
		        SD1.D1_DESPESA, SD1.D1_VALDESC, SD1.D1_TIPO, SD1.D1_BRICMS, SD1.D1_CF, SD1.D1_TES, SF1.F1_EST
		 FROM %table:SD5% SD5, %table:SB1% SB1, %table:SD1% SD1, %table:SF1% SF1
		 WHERE SD5.D5_FILIAL = %xFilial:SD5% AND
		 	   SD5.D5_PRODUTO = %Exp:cCod% AND 
			   SD5.D5_LOCAL = %Exp:cLocal% AND  		  
			   SD5.D5_LOTECTL = %Exp:cLoteCtl% AND  
			   SD5.D5_NUMLOTE = %Exp:cNumLote% AND
			   SD5.D5_DTVALID = %Exp:dDtVal% AND
			   SD5.D5_ORIGLAN = SD1.D1_TES AND
			   SD5.D5_ESTORNO = ' ' AND
			   SD5.D5_DATA   >= %Exp:DTOS(MV_PAR01)% AND  
			   SD5.D5_DATA   <= %Exp:DTOS(MV_PAR02)% AND 		   
			   SD5.%NotDel% AND
			   SD1.D1_DOC = SD5.D5_DOC AND  
			   SD1.D1_SERIE = SD5.D5_SERIE AND  
			   SD1.D1_FORNECE = SD5.D5_CLIFOR AND
			   SD1.D1_LOJA = SD5.D5_LOJA AND			   			   			   
			   SF1.F1_FILIAL  = %xFilial:SF1% AND
		       SF1.F1_DOC     = SD1.D1_DOC AND
		       SF1.F1_SERIE   = SD1.D1_SERIE AND
        	   SF1.F1_FORNECE = SD1.D1_FORNECE AND
               SF1.F1_LOJA    = SD1.D1_LOJA AND
		       SF1.F1_TIPO    = SD1.D1_TIPO AND
		       SF1.F1_TIPO NOT IN ('D','B') AND
	           SF1.%NotDel%	AND 		   			   			   	   			   
	           SB1.B1_COD = SD1.D1_COD AND			   
	           SB1.%NotDel%			   			   			   	   			   				  				  
	     ORDER BY D5_FILIAL, D5_NUMSEQ
	 EndSql
		
 Else              
#ENDIF              
	cIndex  := CriaTrab(Nil,.F.)
	cChave	:= SD5->(IndexKey())
	cFiltro	:= "D5_FILIAL == '" + xFilial("SD5") + "' .AND. "
	cFiltro	+= "D5_PRODUTO == '" + cCod + "' .AND. "
	cFiltro	+= "D5_LOCAL == '" + cLocal + "' .AND. "
	cFiltro	+= "D5_LOTECTL == '" + cLoteCtl + "' .AND. "
	cFiltro	+= "D5_NUMLOTE == '" + cNumLote + "'  .AND."
	cFiltro	+= "dtos(D5_DTVALID) =='" + dtos(dDtVal) + "'  .AND."		
	cFiltro	+= "D5_ORIGLAN <= '499' .AND. D5_ESTORNO == ' ' .AND. "
	cFiltro	+= "D5_DOC <> '" + cDoc + "' .AND. D5_CLIFOR <> '" + cFornece + "' .AND. D5_LOJA <> '"+cLoja+"' "
	IndRegua(cAliasSD5,cIndex,cChave,,cFiltro)
	DbGoBottom()   
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
    #ENDIF 
    dbselectarea(cAliasSD5)               
    (cAliasSD5)->(dbGotop())			                                

#IFDEF TOP
    Endif    
#ENDIF          

Do While (cAliasSD5)->(!Eof())        
   
    if lQuery
	   AADD(aDocto,{(cAliasSD5)->D1_DOC,(cAliasSD5)->D1_SERIE,(cAliasSD5)->D1_EMISSAO,(cAliasSD5)->D1_DTDIGIT,;
	 		 	    (cAliasSD5)->D1_FORNECE,(cAliasSD5)->D1_LOJA,(cAliasSD5)->D1_ITEM,(cAliasSD5)->D1_COD,;
					(cAliasSD5)->D1_QUANT,(cAliasSD5)->D1_BASEICM,(cAliasSD5)->D1_VALICM,(cAliasSD5)->D1_PICM,;
					(cAliasSD5)->F1_EST,(cAliasSD5)->D1_NUMSEQ,(cAliasSD5)->D1_ICMNDES,(cAliasSD5)->D1_BASNDES,;
					(cAliasSD5)->D1_TOTAL,(cAliasSD5)->D1_VALFRE,(cAliasSD5)->D1_SEGURO,(cAliasSD5)->D1_DESPESA,;
					(cAliasSD5)->D1_VALDESC,(cAliasSD5)->D1_TIPO,(cAliasSD5)->D1_BRICMS,(cAliasSD5)->D1_CF,;
					(cAliasSD5)->D1_TES})
	else           

	   dbselectarea("SD1") 
	   dbSetOrder(1)
	   dbSeek(xFilial("SD1")+(cAliasSD5)->D5_DOC+(cAliasSD5)->D5_SERIE+(cAliasSD5)->D5_CLIFOR+(cAliasSD5)->D5_LOJA)

	   if !eof() .and. SD1->D1_TES==(cAliasSD5)->D5_ORIGLAN
	                     
   	       SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
	       
		   aAdd(aDocto,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,SD1->D1_DTDIGIT,;
		 		 	    SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM,SD1->D1_COD,;
						SD1->D1_QUANT,SD1->D1_BASEICM,SD1->D1_VALICM,SD1->D1_PICM,;
						SF1->F1_EST,SD1->D1_NUMSEQ,SD1->D1_ICMNDES,SD1->D1_BASNDES,;
						SD1->D1_TOTAL,SD1->D1_VALFRE,SD1->D1_SEGURO,SD1->D1_DESPESA,;
					    SD1->D1_VALDESC,SD1->D1_TIPO,SD1->D1_BRICMS,SD1->D1_CF,SD1->D1_TES})

       endif

	endif				 
					 					 
	(cAliasSD5)->(dbSkip())

EndDo									
			
#IFDEF TOP
	dbSelectArea(cAliasSD5)
	dbCloseArea(cAliasSD5)
#ELSE
	dbSelectArea(cAliasSD5)
	RetIndex(cAliasSD5)
#ENDIF
			
Return aDocto     
  
