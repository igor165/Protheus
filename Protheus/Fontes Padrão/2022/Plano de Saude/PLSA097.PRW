#include "PLSA097.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA097 ³ Autor ³ Tulio Cesar            ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Confirmaca de liberacoes p/ autorizacao                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA097()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL cCadastro := STR0001 //"Confirmacao de Liberacao"
LOCAL cSQL2     := ""
LOCAL cSQL 		:= ""
LOCAL oEnc
LOCAL aCols     := {}
LOCAL aHeader   := {}
LOCAL aDadBEA   := {} 
LOCAL aChaveGen := {} 
LOCAL nOpca     := 0
LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEnc:aGets,oEnc:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := {||oDlg:End()}
LOCAL aButtons  := {}
LOCAL nFor      := 0  
LOCAL nH        := 0
LOCAL nPosSta   := 0
LOCAL cAno      := ""
LOCAL cMes      := ""
LOCAL cOpeMov   := ""     
LOCAL cNumLib   := ""
LOCAL _nH  
LOCAL lFlag     := .F.  
LOCAL aSlvTrb   := {}
LOCAL aSlvCols  := {}
LOCAL aSlvHead  := {}
LOCAL aVetTrab  := {}
LOCAL lConsulta := .F.
LOCAL aTexto  	:={}
LOCAL cTexto    := ""
LOCAL cFile     := ""
LOCAL cMask     := STR0002+" (*.TXT) |*.txt|" //"Arquivos Texto"
LOCAL nI  		:= 0
PRIVATE lRefresh:= .F.
PRIVATE oBrowse  
PRIVATE Inclui  := .T. 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define enchoice...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("BEN",.T.)
oEnc := MSMGet():New("BEN",0,K_Incluir,,,,nil,aPosObj[1],nil,,,,,oDlg,,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define getdados...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BEP" TO aHeader For .T.
Store COLS Blank "BEP" TO aCols FROM aHeader

@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL	PROMPTS	"Liberações"

oBrowse := MsNewGetDados():New(3,3,aPosObj[1][3]-30,aPosObj[1][4]-7,K_Incluir,"PLS097LOk()","PLS097LOk()",,,,120,,,,oFolder:aDialogs[1],aHeader,aCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ativa dialogo...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSlvTrb  := aClone(aVetTrab)
aSlvCols := aClone(aCols)
aSlvHead := aClone(aHeader)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata a confirmacao....                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

If nOpca == K_OK 
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Analisa cada numero da liberacao e atualiza o status...                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BEA->(DbSetOrder(1))     
   Store Header "BE2" TO aHeader For .T.
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Abre semaforo...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
   Processa( {|| _nH := PL097SMF() }, STR0003 ) //"Confirmação de Liberação"

   Begin Transaction
   
   nPosSta   := PLRETPOS("BEP_IMAGE",oBrowse:aHeader,.F.)                                                                                             
   
   cOpeRDA := M->BEN_OPERDA
   cCodRDA := M->BEN_CODRDA
   cOpeMov := M->BEN_CODOPE
   
   PLSDADRDA(cOpeRDA,cCodRDA,"1",dDatabase)
      
   For nFor := 1 To Len(oBrowse:aCols)
       If ! oBrowse:aCols[nFor,Len(oBrowse:aHeader)+1] .And. AllTrim(oBrowse:aCols[nFor,nPosSta]) == "ENABLE"
          cNumLib := oBrowse:aCols[nFor,PLRETPOS("BEP_NUMLIB",oBrowse:aHeader)]
          cCid    := oBrowse:aCols[nFor,PLRETPOS("BEP_CID",oBrowse:aHeader)]
          dDatPro := oBrowse:aCols[nFor,PLRETPOS("BEP_DATPRO",oBrowse:aHeader)]
          cLocAte := oBrowse:aCols[nFor,PLRETPOS("BEP_LOCATE",oBrowse:aHeader)]
          cCodEsp := oBrowse:aCols[nFor,PLRETPOS("BEP_CODESP",oBrowse:aHeader)]
          
          aRetAux := PLSXVLDCAL(dDatPro,cOpeMov,.T.,"","")
         
		  If Len(aRetAux) >= 4 
   			cAno := aRetAux[4]
          	cMes := aRetAux[5]
          Endif            
          
		  If BEA->( DbSeek(xFilial("BEA")+cNumLib) ) .And. BEA->BEA_ORIGEM == "2"
			                               
			  PLSATUCS()
		      				
		  	  cSQL := "SELECT R_E_C_N_O_ REG FROM "+BE2->(RetSQLName("BE2"))+" WHERE "
		  	  cSQL += "BE2_FILIAL = '"+xFilial("BE2")+"' AND "
		  	  cSQL += "BE2_OPEMOV = '"+BEA->BEA_OPEMOV+"' AND "
		  	  cSQL += "BE2_ANOAUT = '"+BEA->BEA_ANOAUT+"' AND "
		      cSQL += "BE2_MESAUT = '"+BEA->BEA_MESAUT+"' AND "
		      cSQL += "BE2_NUMAUT = '"+BEA->BEA_NUMAUT+"' AND "
		      cSQL += "D_E_L_E_T_ = ' '"
		  	  PLSQuery(cSQL,"TrbLIBBe2")
		      
			  
		  	  cSQL2 := "SELECT COUNT(*) TOTAL FROM "+BE2->(RetSQLName("BE2"))+" WHERE "
		  	  cSQL2 += "BE2_FILIAL = '"+xFilial("BE2")+"' AND "
		  	  cSQL2 += "BE2_OPEMOV = '"+BEA->BEA_OPEMOV+"' AND "
		  	  cSQL2 += "BE2_ANOAUT = '"+BEA->BEA_ANOAUT+"' AND "
		      cSQL2 += "BE2_MESAUT = '"+BEA->BEA_MESAUT+"' AND "
		      cSQL2 += "BE2_NUMAUT = '"+BEA->BEA_NUMAUT+"' AND "
		      cSQL2 += "D_E_L_E_T_ = ' '"
		  	  PLSQuery(cSQL2,"TrbLIBCO")
		      
		      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³ Atualiza a liberacao															    ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  aVetTrab := {}
			  aCols    := {}
			 
			  PLSA090MDA(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"1",aHeader,aVetTrab,aCols)
			  
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³ Grava os valores para fazer a BAIXA da liberacao								    ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  cMatricLib  := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)

			  If ! TrbLIBBe2->(Eof())
			      While ! TrbLIBBe2->(Eof()) 
			            BE2->(DbGoTo(TrbLIBBe2->REG))
			            
			            PLSATUSS( BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) + BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO) )
			            
			            If PLSISCON(BE2->BE2_CODPAD,BE2->BE2_CODPRO) .And. !TrbLIBCO->(Eof()) .And. TrbLIBCO->TOTAL == 1
			            	lConsulta := .T.
			            Endif
			      TrbLIBBe2->(DbSkip())
			      Enddo      
			  Endif
			  
			  TRBLIBBE2->(DbCloseArea())
     		  TrbLIBCO->(DbCloseArea())
     		 
			  aDadBEA := {}
     		  PLSCABBEA(aDadBEA,cAno,cMes,cOpeRDA,cCodRDA,cCid,cCodEsp,cLocAte,dDatPro,cOpeMov,cNumLib)
     		  
     	      aChaveGen := {}
     	      PLSCABBE2(aChaveGen,cOpeRDA,cCodRDA,cCid,cCodEsp,cLocAte,dDatPro)
              
			  // Atualiza o usuario.
			  PLSDADUSR(cMatricLib,"1",.F.,dDatabase)
			  
     		  //criar uma nova guia no atendimento
     		  PLSA090Grv(   aCols,aHeader,aDadBEA,K_Incluir,aVetTrab,aChaveGen,cMatricLib,BEA->BEA_DATPRO,BEA->BEA_HORPRO,"1",BEA->BEA_ANOPAG,BEA->BEA_MESPAG,;
							If(!lConsulta,GetNewPar("MV_PLSTPGS","02"),GetNewPar("MV_PLSTPGC","01")),.F.,NIL,NIL,NIL,.T.,;
							"1",Nil,.T.,Nil,Nil,Nil,.F.,.F.,Nil,Nil,.T.,.F.,{},.F.,.F.,Nil,Nil,Nil,Nil,.T.,Nil,Nil,Nil,;
							,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,cNumLib)
			    
			  //             1           2            3             4              5     6      7
			  //aTexto{NumAutGerada,NumLiberação,MatricUsuario,NomeUsuário,Cod RDA,Nome RDA,NumeroImpresso}       
			  Aadd(aTexto,{BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),cNumLib,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->BEA_NOMUSR,BEA->BEA_CODRDA,BEA->BEA_NOMRDA,BEA->BEA_NUMIMP})
			  lFlag:=.T.
     	  Endif   
       Endif
   Next
     
   End Transaction
    
	
   If lFlag                                                     
   		
  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe resultado do processamento                 				           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTexto :=  CHR(13) + CHR(10) 
		cTexto += STR0004+"    :  " + Str(Len(aTexto)) + CHR(13) + CHR(10) //"Quantidade Liberação Confirmada"
		cTexto +=  CHR(13) + CHR(10) 
		For nI:=1 to Len(aTexto)
			cTexto += Replicate("-",100) 									+ CHR(13) + CHR(10) 
			cTexto +=  STR0005+" 	:  " 				   				  	+ aTexto[nI,1]      	+ CHR(13) + CHR(10)  //"Número da Autorização Gerada"
			cTexto +=  STR0006+"                                    :  " 	+ dtoc(date())  + "  " + time()  + CHR(13) + CHR(10)  //"Data Autorização"
			cTexto +=  STR0007+"     	:  " 						 		+ aTexto[nI,2]      	+ CHR(13) + CHR(10)  //"Número da Liberação Origem"
			cTexto +=  STR0008+"                                            :  "   	+ aTexto[nI,5] 	+ CHR(13) + CHR(10) 	 //"Código RDA"
			cTexto +=  STR0009+"                                              :  " 	+ aTexto[nI,6] 	+ CHR(13) + CHR(10) 	 //"Nome RDA"
			cTexto +=  STR0010+"              	             :  " 					+ aTexto[nI,3] 	+ CHR(13) + CHR(10)  //"Matrícula Usuário"
			cTexto +=  STR0011+"  		             :  " 							+ aTexto[nI,4] 	+ CHR(13) + CHR(10)  //"Nome Usuário"
			cTexto +=  STR0012+"                	             :  " 				+ aTexto[nI,7] 	+ CHR(13) + CHR(10)  //"Número Impresso"
		    cTexto +=  CHR(13) + CHR(10) 
		Next nI  
				
		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		DEFINE FONT oFont NAME "Arial" SIZE 7,15
		DEFINE MSDIALOG oDlg TITLE STR0013 From 0,0 to 420,680 PIXEL //"Confirmação Liberação concluida com sucesso."
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 330,185 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont 
		oMemo:lReadOnly:=.T.
		DEFINE SBUTTON  FROM 195,270 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //"Salvar Como..."
		DEFINE SBUTTON  FROM 195,300 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Sai
		ACTIVATE MSDIALOG oDlg CENTER 
   Else
      MsgInfo(STR0014) //"Nenhuma Liberação para Confirmar !!!"
   Endif 
    
Endif

aVetTrab := aClone(aSlvTrb) 
aCols    := aClone(aSlvCols)
aHeader  := aClone(aSlvHead) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA097NUM ³ Autor ³ Tulio Cesar         ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida o numero da guia de liberacao digitada...           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA097NUM()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             
LOCAL nPosCid  := PLRETPOS("BEP_CID",oBrowse:aHeader,.F.)              
LOCAL nPosUsr  := PLRETPOS("BEP_NOMUSR",oBrowse:aHeader,.F.) 
LOCAL nPosLoc  := PLRETPOS("BEP_LOCATE",oBrowse:aHeader,.F.) 
LOCAL nPosDesL := PLRETPOS("BEP_DESLOC",oBrowse:aHeader,.F.)     
LOCAL nPosEsp  := PLRETPOS("BEP_CODESP",oBrowse:aHeader,.F.) 
LOCAL nPosDesE := PLRETPOS("BEP_DESESP",oBrowse:aHeader,.F.) 
LOCAL nPosLib  := PLRETPOS("BEP_NUMLIB",oBrowse:aHeader,.F.) 
LOCAL nI       := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na guia...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEA->(DbSetOrder(1)) 

If Len(aCols) > 1
	For nI:=1 to Len(aCols)
		If M->BEP_NUMLIB = oBrowse:aCols[nI,nPosLib]
				MsgAlert(STR0015) //"Número de Liberação já incluído para ser liberado"
				Return(.F.)
		Endif 
	Next nI
Endif

If BEA->(DbSeek(xFilial("BEA")+M->BEP_NUMLIB)) .And. BEA->BEA_ORIGEM=="2" .And. ((BEA->BEA_OPERDA==M->BEN_OPERDA .And. BEA->BEA_CODRDA==M->BEN_CODRDA) .OR. (BEA->BEA_CODRDA == GetMv("MV_PLSRDAG"))) .And. BEA->BEA_STALIB=="1"
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Se a guia e valida verifica se ela e do mesmo prestador...               ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If nPosCid > 0
         oBrowse:aCols[n,nPosCid] := BEA->BEA_CID
      Endif   

      If nPosUsr > 0
         oBrowse:aCols[n,nPosUsr] := BEA->BEA_NOMUSR                                                
      Endif
	      
      If nPosLoc > 0
         oBrowse:aCols[n,nPosLoc] := BEA->(BEA_CODLOC+BEA_LOCAL) 
         oBrowse:aCols[n,nPosDesL] :=BB8->(Posicione("BB8",1,xFilial("BB8")+M->(BEN_CODRDA+BEN_CODOPE)+BEA->(BEA_CODLOC+BEA_LOCAL), "BB8_DESLOC" ))
      Endif                                          
            
      If nPosEsp > 0
         oBrowse:aCols[n,nPosEsp] := BEA->BEA_CODESP 
         oBrowse:aCols[n,nPosDesE] :=BAQ->(Posicione("BAQ",1,xFilial("BAQ")+M->BEN_CODOPE+BEA->BEA_CODESP,"BAQ_DESCRI"))                                               
      Endif    
                           
Else
   	MsgAlert(STR0016) //"Número Liberação Inválido !!!"
   	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSCABBEA ³ Autor ³Luciano Aparecido 		³ Data ³ 25.12.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche Dados do cabeçalho ...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSCABBEA(aDadBEA,cAno,cMes,cOpeRDA,cCodRDA,cCid,cCodEsp,cLocAte,dDatPro,cOpeMov,cNumLib)
	                                
BAU->(DbSetOrder(1))	                                        
BAU->(MsSeek(xFilial("BAU")+cCodRDA))                      

BA9->(DbSetOrder(1))
BA9->(MsSeek(xFilial("BA9")+cCid))

DbSelectArea("BEA")                 
AaDd(aDadBEA,{"BEA_CDPFSO",BEA_CDPFSO})
AaDd(aDadBEA,{"BEA_ESTSOL",BEA_ESTSOL})
AaDd(aDadBEA,{"BEA_OPESOL",""})
AaDd(aDadBEA,{"BEA_REGSOL",BEA_REGSOL})
AaDd(aDadBEA,{"BEA_NOMSOL",BEA_NOMSOL})
AaDd(aDadBEA,{"BEA_SIGLA" ,BEA_SIGLA})
AaDd(aDadBEA,{"BEA_SOLORI",BEA_SOLORI})	
AaDd(aDadBEA,{"BEA_ESTEXE",BEA_ESTEXE})
AaDd(aDadBEA,{"BEA_REGEXE",BEA_REGEXE})
AaDd(aDadBEA,{"BEA_NOMEXE",BEA_NOMEXE})
AaDd(aDadBEA,{"BEA_SIGEXE",BEA_SIGEXE})
AaDd(aDadBEA,{"BEA_CDPFRE",BEA_CDPFRE})
AaDd(aDadBEA,{"BEA_OPEEXE",BEA_OPEEXE})
AaDd(aDadBEA,{"BEA_CANCEL",BEA_CANCEL})
AaDd(aDadBEA,{"BEA_TPGRV" ,BEA_TPGRV})
AaDd(aDadBEA,{"BEA_HORSOL",BEA_HORSOL})
AaDd(aDadBEA,{"BEA_DATSOL",BEA_DATSOL})
AaDd(aDadBEA,{"BEA_INDCLI",BEA_INDCLI})	 
If BEA->( FieldPos("BEA_GUIPRI") ) > 0    
	AaDd(aDadBEA,{"BEA_GUIPRI",BEA_GUIPRI})
Endif
If BEA->( FieldPos("BEA_TRACON") ) > 0    
	AaDd(aDadBEA,{"BEA_TRACON",BEA_TRACON})	
Endif
AaDd(aDadBEA,{"BEA_TIPATE",BEA_TIPATE})	
AaDd(aDadBEA,{"BEA_TIPDOE",BEA_TIPDOE})
AaDd(aDadBEA,{"BEA_UTPDOE",BEA_UTPDOE})
AaDd(aDadBEA,{"BEA_INDACI",BEA_INDACI})
If BEA->( FieldPos("BEA_TIPCON") ) > 0    
	AaDd(aDadBEA,{"BEA_TIPCON",BEA_TIPCON})
Endif
AaDd(aDadBEA,{"BEA_TIPSAI",BEA_TIPSAI})
AaDd(aDadBEA,{"BEA_VALSEN",BEA_VALSEN})
AaDd(aDadBEA,{"BEA_STALIB",BEA_STALIB})
AaDd(aDadBEA,{"BEA_TIPATE",BEA_TIPATE})
AaDd(aDadBEA,{"BEA_PAGATO",BEA_PAGATO})
Aadd(aDadBEA,{"BEA_NRLBOR",cNumLib})
AaDd(aDadBEA,{"BEA_STATUS","1"})
AaDd(aDadBEA,{"BEA_NUMIMP",BEA_NUMIMP})
AaDd(aDadBEA,{"BEA_TIPPAC",BEA_TIPPAC})
AaDd(aDadBEA,{"BEA_OPEMOV",BEA_OPEMOV})
AaDd(aDadBEA,{"BEA_CID"   ,cCid})
AaDd(aDadBEA,{"BEA_CIDSEC",BEA_CIDSEC})
AaDd(aDadBEA,{"BEA_CID3"  ,BEA_CID3})
AaDd(aDadBEA,{"BEA_CID4"  ,BEA_CID4})
AaDd(aDadBEA,{"BEA_CID5"  ,BEA_CID5})
AaDd(aDadBEA,{"BEA_DESCID",BA9->BA9_DOENCA})
AaDd(aDadBEA,{"BEA_MATUSA",BEA_MATUSA})
AaDd(aDadBEA,{"BEA_TIPO"  ,BEA_TIPO})
AaDd(aDadBEA,{"BEA_NRAOPE",BEA_NRAOPE})
AaDd(aDadBEA,{"BEA_MSG01" ,BEA_MSG01})
AaDd(aDadBEA,{"BEA_MSG02" ,BEA_MSG02})
AaDd(aDadBEA,{"BEA_MSG03" ,BEA_MSG03})
AaDd(aDadBEA,{"BEA_NRTROL",BEA_NRTROL})
If BEA->( FieldPos("BEA_COMUNI") ) > 0   
	AaDd(aDadBEA,{"BEA_COMUNI",BEA_COMUNI})
Endif
AaDd(aDadBEA,{"BEA_VIACAR",BEA_VIACAR})
aadd(aDadBEA,{"BEA_HHDIGI",StrTran(Time(),":","")})
aadd(aDadBEA,{"BEA_DTDIGI",Date()})
aadd(aDadBEA,{"BEA_USUOPE",PLSRtCdUsr()})
aadd(aDadBEA,{"BEA_DESOPE",PLRETOPE()})
AaDd(aDadBEA,{"BEA_CODLOC",subs(cLocAte,1,3)})
AaDd(aDadBEA,{"BEA_LOCAL" ,subs(cLocAte,4,3)})
AaDd(aDadBEA,{"BEA_DESLOC",Posicione("BB8",1,xFilial("BB8")+cCodRDA+cOpeMov+cLocAte, "BB8_DESLOC" )})
AaDd(aDadBEA,{"BEA_ENDLOC",Posicione("BB8",1,xFilial("BB8")+cCodRDA+cOpeMov+cLocAte, "BB8_END" )})
AaDd(aDadBEA,{"BEA_CODESP",cCodEsp})
AaDd(aDadBEA,{"BEA_DESESP",BAQ->(Posicione("BAQ",1,xFilial("BAQ")+cOpeMov+cCodEsp,"BAQ_DESCRI"))})
AaDd(aDadBEA,{"BEA_DATPRO",dDatPro})
AaDd(aDadBEA,{"BEA_CODRDA",cCodRDA})
AaDd(aDadBEA,{"BEA_OPERDA",cOpeRDA})
AaDd(aDadBEA,{"BEA_TIPPRE",BAU->BAU_TIPPRE})
AaDd(aDadBEA,{"BEA_NOMRDA",BAU->BAU_NOME})
AaDd(aDadBEA,{"BEA_MATANT",BEA->BEA_MATANT})
AaDd(aDadBEA,{"BEA_NOMUSR",BEA->BEA_NOMUSR})
AaDd(aDadBEA,{"BEA_TIPUSR",BEA->BEA_TIPUSR})
AaDd(aDadBEA,{"BEA_CPFUSR",BEA->BEA_CPFUSR})
AaDd(aDadBEA,{"BEA_IDUSR" ,BEA->BEA_IDUSR})
AaDd(aDadBEA,{"BEA_DATNAS",BEA->BEA_DATNAS})
AaDd(aDadBEA,{"BEA_CONEMP",BEA->BEA_CONEMP})
AaDd(aDadBEA,{"BEA_VERCON",BEA->BEA_VERCON})
AaDd(aDadBEA,{"BEA_SUBCON",BEA->BEA_SUBCON})
AaDd(aDadBEA,{"BEA_VERSUB",BEA->BEA_VERSUB})
AaDd(aDadBEA,{"BEA_MATVID",BEA->BEA_MATVID})
AaDd(aDadBEA,{"BEA_ATERNA",BEA->BEA_ATERNA})

If BEA->( FieldPos("BEA_GUIACO") ) > 0    
    AaDd(aDadBEA,{"BEA_GUIACO",BEA->BEA_GUIACO})
	AaDd(aDadBEA,{"BEA_QUACOB",BEA->BEA_QUACOB})
EndIf	   

AaDd(aDadBEA,{"BEA_OPEUSR",BEA->BEA_OPEUSR})
AaDd(aDadBEA,{"BEA_CODEMP",BEA->BEA_CODEMP})
AaDd(aDadBEA,{"BEA_MATRIC",BEA->BEA_MATRIC})
AaDd(aDadBEA,{"BEA_TIPREG",BEA->BEA_TIPREG})
AaDd(aDadBEA,{"BEA_DIGITO",BEA->BEA_DIGITO})
AaDd(aDadBEA,{"BEA_HORPRO",BEA->BEA_HORPRO})
AaDd(aDadBEA,{"BEA_OPEINT",BEA->BEA_OPEINT})
AaDd(aDadBEA,{"BEA_NOMTIT",BEA->BEA_NOMTIT})
AaDd(aDadBEA,{"BEA_ATEAMB",BEA->BEA_ATEAMB})
AaDd(aDadBEA,{"BEA_ANOPAG",cAno})
AaDd(aDadBEA,{"BEA_MESPAG",cMes})
AaDd(aDadBEA,{"BEA_ANOAUT",cAno})
AaDd(aDadBEA,{"BEA_MESAUT",cMes})
AaDd(aDadBEA,{"BEA_ORIMOV",BEA->BEA_ORIMOV})           
AaDd(aDadBEA,{"BEA_TIPADM",BEA->BEA_TIPADM})

If BEA->(Fieldpos("BEA_ARQIMP"))>0
	AaDd(aDadBEA,{"BEA_ARQIMP",BEA->BEA_ARQIMP})
Endif

If BEA->(Fieldpos("BEA_LOTGUI"))>0
	AaDd(aDadBEA,{"BEA_LOTGUI",BEA->BEA_LOTGUI})
Endif 


If BEA->(Fieldpos("BEA_SENHA"))>0
	AaDd(aDadBEA,{"BEA_SENHA",BEA->BEA_SENHA})
Endif 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSCABBE2 ³ Autor ³Luciano Aparecido 		³ Data ³ 25.12.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche Dados do item ...                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSCABBE2(aChaveGen,cOpeRDA,cCodRDA,cCid,cCodEsp,cLocAte,dDatPro)

BAU->(DbSetOrder(1))	                                        
BAU->(MsSeek(xFilial("BAU")+cCodRDA))                      

BA9->(DbSetOrder(1))
BA9->(MsSeek(xFilial("BA9")+cCid))

DbSelectArea("BE2")     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                          ³
//³ << BE2 BE2 BE2 BE2 >> Monta dados dos ITENS PROCEDIMENTOS...             ³
//³                                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_DATPRO",dDatPro})
   aadd(aChaveGen,{"BE2_HORPRO",BE2_HORPRO})
   aadd(aChaveGen,{"BE2_TPGRV" ,"1"})
   aadd(aChaveGen,{"BE2_CDPFSO",BE2_CDPFSO})
   aadd(aChaveGen,{"BE2_TIPRDA",BAU->BAU_TIPPE})
   aadd(aChaveGen,{"BE2_IDUSR",BA1->BA1_DRGUSR})
   aadd(aChaveGen,{"BE2_ENDLOC",BE2_ENDLOC})
   aadd(aChaveGen,{"BE2_DESLOC",BE2_DESLOC})
   aadd(aChaveGen,{"BE2_ATEAMB",BE2_ATEAMB})
   aadd(aChaveGen,{"BE2_CID",cCid})
   aadd(aChaveGen,{"BE2_DATNAS",BE2_DATNAS})
   aadd(aChaveGen,{"BE2_CPFRDA",BAU->BAU_CPFCGC})
   aadd(aChaveGen,{"BE2_NUMIMP",BE2_NUMIMP})
   If BE2->( FieldPos("BE2_GUIACO") ) > 0    
	   aadd(aChaveGen,{"BE2_GUIACO",BE2_GUIACO})
   	   aadd(aChaveGen,{"BE2_QUACOB",BE2_QUACOB})
   EndIf	   
   
   aadd(aChaveGen,{"BE2_NUMAUT",BE2_NUMAUT})

   If BE2->( FieldPos("BE2_TIPCON") ) > 0    
	   aadd(aChaveGen,{"BE2_TIPCON",BE2_TIPCON})
   EndIf
   	   
   If BE2->(FieldPos("BE2_NRAOPE")) > 0
      aadd(aChaveGen,{"BE2_NRAOPE",BE2_NRAOPE})
   Endif                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario...                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_OPEUSR",BE2_OPEUSR})
   aadd(aChaveGen,{"BE2_CODEMP",BE2_CODEMP})
   aadd(aChaveGen,{"BE2_MATRIC",BE2_MATRIC})
   aadd(aChaveGen,{"BE2_TIPREG",BE2_TIPREG})
   aadd(aChaveGen,{"BE2_CONEMP",BE2_CONEMP})
   aadd(aChaveGen,{"BE2_VERCON",BE2_VERCON})
   aadd(aChaveGen,{"BE2_SUBCON",BE2_SUBCON})
   aadd(aChaveGen,{"BE2_VERSUB",BE2_VERSUB})
   aadd(aChaveGen,{"BE2_MATVID",BE2_MATVID})
   aadd(aChaveGen,{"BE2_DIGITO",BE2_DIGITO})
   aadd(aChaveGen,{"BE2_MATANT",BE2_MATANT})
   aadd(aChaveGen,{"BE2_ATEAMB",BE2_ATEAMB})
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Procedimentos...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_PRFATD",BE2_PRFATD})
   aadd(aChaveGen,{"BE2_OPERDA",cOpeRDA})
   aadd(aChaveGen,{"BE2_CODRDA",cCodRDA})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Local de Atendimento...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_CODLOC",Subs(cLocAte,1,3)})
   aadd(aChaveGen,{"BE2_LOCAL ",Subs(cLocAte,4,3)})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especialidade...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_CODESP",cCodEsp}) 
   
   
   aadd(aChaveGen,{"BE2_DNIVAU",""})
   aadd(aChaveGen,{"BE2_DNIVCR",""})

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLLCBEP³ Autor ³ Daher					³ Data ³ 10.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do local de atendimento...                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLLCBEP()

LOCAL aRetFun 
LOCAL lRet := .T. 
LOCAL nPosDat := PLRETPOS("BEP_DATPRO",oBrowse:aHeader,.F.)              

If !Empty(M->BEP_LOCATE)
		aRetFun := PLSVDLOCRD(M->BEN_CODRDA,M->BEN_OPERDA,oBrowse:aCols[n,nPosDat],Subs(M->BEP_LOCATE,1,3),"","")
      	If ! aRetFun[1]
      	lRet := .F.
      		If Len(aRetFun) >= 2
        		 PLSMOVCRI("3",{},aRetFun[2])      
      		Endif
      	Endif   
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLESBEP³ Autor ³ Luciano Aparecido     ³ Data ³ 10.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da especialidade...                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLESBEP()

LOCAL aRetFun 
LOCAL lRet		:= .T.
LOCAL nPosDat := PLRETPOS("BEP_DATPRO",oBrowse:aHeader,.F.) 
LOCAL nPosLoc := PLRETPOS("BEP_LOCATE",oBrowse:aHeader,.F.)      

BB8->(DbSetOrder(1))	//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL

BB8->(MsSeek(xFilial("BB8")+M->BEN_CODRDA+M->BEN_OPERDA+Subs(oBrowse:aCols[n,nPosLoc],1,3)))

IF !Empty(M->BEP_CODESP)
	aRetFun := PLSVDESPRD(M->BEN_CODRDA,M->BEN_OPERDA,Subs(oBrowse:aCols[n,nPosLoc],1,3),M->BEP_CODESP,oBrowse:aCols[n,nPosDat],"","")
	If ! aRetFun[1]
   		lRet := .F.
   		Help("",1,"PLSA090ESP")
	Endif
Endif

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLS097LOk ºAutor  ³Luciano Aparecido   º Data ³  21/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a linha da msGetdados                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS097LOk                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS097LOk()

Local lRet     := .T. //Retorno da funcao

Local nPosLib := aScan(aHeader,{|x| AllTrim(x[2])=="BEP_NUMLIB"})

if Empty(oBrowse:aCols[n,nPosLib]) 
	MsgAlert(STR0017) //"O número da Liberação não pode estar em Branco !"
	lRet:=.F.
Endif

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL097SMF  ºAutor  ³Luciano Aparecido   º Data ³  03/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre semaforo ...         				                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PL097SMF()


IncProc(STR0018+STR0019) //"Analisando Liberação ... "###"Por favor, aguarde !!! "


Return(0)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLDTBEP³ Autor ³ Luciano Aparecido     ³ Data ³ 26.12.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Data...                             		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDTBEP()

LOCAL lRet		:= .T.
LOCAL nPosLib  := PLRETPOS("BEP_NUMLIB",oBrowse:aHeader,.F.)    

BEA->(DbSetOrder(1))
If BEA->(DbSeek(xFilial("BEA")+oBrowse:aCols[n,nPosLib]))
	IF BEA->BEA_DATPRO > M->BEP_DATPRO 
   		MsgAlert(STR0020) //"A Data não pode ser menor que a data da liberação !"
	   	lRet := .F.
   	Endif
Endif

Return(lRet) 

