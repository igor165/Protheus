#INCLUDE "PLSMGER.CH"

/*/{Protheus.doc} PLSM220
Reconsolida um unico BDH  
@type function
@author plsteam
@since 128.08.2005
@version 1.0
/*/
Function PLSM220
Local aCores    	:= {}
PRIVATE	aRotina   := MenuDef()
PRIVATE cCadastro := "Reconsolidacao individual"
//Define as cores das legendas
aCores    	:= {	{ 'BDH_STATUS = "0"',"BR_VERMELHO"},;
					{ 'BDH_STATUS = "1"',"BR_VERDE"},;
					{ 'BDH_STATUS = "2"',"BR_AZUL"}}

//Executa browse do bdh...                                            
BDH->(mBrowse(06,01,22,75,"BDH",,,20,,,aCores))

Return

/*/{Protheus.doc} PLSM220PRO
Reconsolida um unico BDH 
@type function
@author plsteam
@since 128.08.2005
@version 1.0
/*/
Function PLSM220Pro(cAlias,nReg,nOpc)                    
LOCAL cMatricUsr ,nFor
LOCAL cSQL2    := "" 
LOCAL aPtoEnt  := {} 
LOCAL aRecBD6   := {}
LOCAL aErro		:= {}
LOCAL lPLCONGUI := Existblock("PLCONGUI")

//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
If PLVLDBLQCO(dDataBase, {"PLS012"}, .T.)  

	//Testa se BDH pode ser refeito...                                    
	If BDH->BDH_STATUS == "0"
	   MsgStop("Registro ja faturado. Nao e possivel reconsolidar.")
	   Return
	Endif           
	
	//Monta matricula completa do usuario...                              
	BA1->(DbSetOrder(2))
	If ! BA1->(DbSeek(xFilial("BA1")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG)))
	   MsgStop("Usuario desta consolidacao nao encontrado.")
	   Return
	Endif   
	
	cMatricUsr := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	
	//Ponto de entrada depois de limpar o BD6_SEQPF, mas antes de excluir a BDH e recriá-la.
	If ExistBlock("PLS220IN")
		ExecBlock("PLS220IN",.F.,.F.)
	EndIf

	//Limpa seqpf de todas as guias referentes a esta bdh...              
	BD6->(DbSetOrder(12))
	If BD6->(MsSeek(xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)))
	   
	   While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF) == ;
	           xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)               
	                                     
	         BD6->(DbSkip())
	         nRegProx := BD6->(Recno())
	         BD6->(DbSkip(-1)) 
	   	
	   		 //Este pto de entrada pode ser utilizado da seguinte forma:			 
			 //Sempre que uma guia nao precisar ser consolidada deve ser           
			 //adicionado no array a chave da guia e o pto de entrada deve retornar
			 //.F., ao contrario basta retornar .T. e nao mexer no array			
	         If !lPLCONGUI .or. ( lPLCONGUI .and. ExecBlock("PLCONGUI", .F., .F., {@aPtoEnt,'1'}) )  
	         	 
	         	 aadd(aRecBD6,BD6->(Recno()))                            
		         
		         BD6->(RecLock("BD6",.F.))
		         BD6->BD6_SEQPF := ""
		         BD6->(MsUnLock())
		                           
		         If !(BD6->BD6_TIPGUI $ "03,05")
		            BD5->(DbSetOrder(1))
		            If BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)))
		               BD5->(RecLock("BD5",.F.))
		               BD5->BD5_SEQPF := ""
		               BD5->(MsUnLock())                   
		            Endif
		         Else
		            BE4->(DbSetOrder(1))
		            If BE4->(MsSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
		               BE4->(RecLock("BE4",.F.))
		               BE4->BE4_SEQPF := ""
		               BE4->(MsUnLock())
		            Endif
		         Endif      
		                           
	   		 Endif                  
	   		 BD6->(DbGoTo(nRegProx))
	   Enddo      
	Endif   

	//Exclui BDH...                                                       
	BDH->(RecLock("BDH",.F.))
	BDH->(DbDelete())
	BDH->(MsUnLock())
	For nFor := 1 To Len(aRecBD6)
	  	
	  	BD6->(DbGoto(aRecBD6[nFor]))
	 	
	 	If lPLCONGUI .and. ExecBlock("PLCONGUI", .F., .F., {@aPtoEnt,'2'}) 
	    	Loop
	    Endif
	    
	 	cSQL2 := " SELECT COUNT(*) CONTADOR FROM "+RetSqlName("BD7")
	 	cSQL2 += " WHERE "
	 	cSQL2 += " BD7_FILIAL = '"+BD6->BD6_FILIAL+"' AND "
	 	cSQL2 += " BD7_CODOPE = '"+BD6->BD6_CODOPE+"' AND "
	 	cSQL2 += " BD7_CODLDP = '"+BD6->BD6_CODLDP+"' AND "
	 	cSQL2 += " BD7_CODPEG = '"+BD6->BD6_CODPEG+"' AND "
	 	cSQL2 += " BD7_NUMERO = '"+BD6->BD6_NUMERO+"' AND "
	 	cSQL2 += " BD7_ORIMOV = '"+BD6->BD6_ORIMOV+"' AND "
	 	cSQL2 += " BD7_SEQUEN = '"+BD6->BD6_SEQUEN+"' AND "
	 	cSQL2 += " BD7_BLOPAG <> '1' AND "
	 	cSQL2 += " D_E_L_E_T_ <> '*'" 
	 	PLSQuery(cSQL2,"TrbFase")
	 					  
	 	If (TrbFase->CONTADOR == 0)
			TrbFase->(DbCloseArea())
		 	BD6->(DbSkip())
		 	Loop
	 	Else              
	 		TrbFase->(DbCloseArea())
	 	Endif

	    //Se houve participipacao financeira esta ativa e pronta calculo BDH  
	    If BD6->BD6_VLRTPF > 0 .And. BD6->BD6_FASE $ "3,4" .And. BD6->BD6_SITUAC == "1" .And. Empty(BD6->BD6_SEQPF)
	      	cAlias := IIF(BD6->BD6_TIPGUI $ "03,05","BE4","BD5")
	                  
	        If cAlias == "BD5"
	            BD5->(DbSetorder(1))
	        	If BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
	            	grvPFBDH(BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG),"1",BD6->BD6_ANOPAG,BD6->BD6_MESPAG,cAlias,aErro,IIf(Alltrim(BD5->BD5_TIPPAC)=='1','1','2'))
	            Endif
	        Else
	            BE4->(DbSetorder(1))
	        	If BE4->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
	            	grvPFBDH(BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG),"1",BD6->BD6_ANOPAG,BD6->BD6_MESPAG,cAlias,aErro)
	        	Endif
	        Endif     
	    Endif   
	                                     
	Next 
	   
	If FindFunction("PlDelCons")
		PlDelCons(aErro)
	Endif
	
	MsgInfo("Consolidacao Individual Concluida!")
EndIf

Return

/*/{Protheus.doc} PLSM220Vis

@type function
@author plsteam
@since 128.08.2005
@version 1.0
/*/
Function PLSM220Vis
LOCAL aRes := {}
BD6->(DbSetOrder(12))
If BD6->(DbSeek(xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)))
   
   While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF) == ;
                               xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)
         aadd(aRes,{BD6->BD6_NUMIMP,BD6->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO+"-"+BD6_SEQUEN),BD6->BD6_QTDPRO,BD6->BD6_VLRBPF,BD6->BD6_VLRTAD,BD6->BD6_VLRTPF,X3COMBO("BD6_TPPF",bd6->bd6_tppf)})
   
   BD6->(DbSkip())
   Enddo
   
Endif    

If Len(aRes) > 0
   PLSCRIGEN(aRes,{ {"Numero Impresso","@C",100},{"Guia","@C",100},{"Qtd.","999999.99",50},{"Valor Base","@E 999,999.99",100},{"Taxa Adm.","@E 999,999.99",100},{"Valor Total","@E 999,999.99",100},{"Tipo PF","@C",100} },"Evento relacionados a consolidacao")
Endif

Return   

/*/{Protheus.doc} MenuDef

@type function
@author plsteam
@since 128.08.2005
@version 1.0
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01     			, 'AxPesqui'   , 0, K_Pesquisar		, 0, .F.},;
               	       	{ STRPL02    			, 'AxVisual'   , 0, K_Visualizar	, 0, Nil},;
                      	{ "Reconsolidar"  	 	, 'PLSM220Pro' , 0, K_Incluir   	, 0, Nil},;
                      	{ "Vis.Eventos Cons."	, 'PLSM220Vis' , 0, K_Alterar   	, 0, Nil},; 
						{ "Legenda"	 			, 'PLSM220Leg' , 0, K_Incluir   	, 0, Nil} }
Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao³ PLSA260LEG ³ Autor ³Victor Alves dos Santos ³ Data ³ 21.02.2020³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Aiciona o campo de legenda.                                ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM220Leg()
Local aCdCores := {}

aCdCores  	:= {	{ 'BR_VERMELHO'	,"Faturado"},;
					{ 'BR_VERDE'	,"Aberto"},; 
					{ 'BR_AZUL'   	,"Gratuidade"} }

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return

