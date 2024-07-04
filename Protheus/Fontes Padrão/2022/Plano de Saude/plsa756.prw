#INCLUDE "COLORS.CH" 
#INCLUDE "plsa756.ch"
#Include "Protheus.Ch"
#include "PLSMGER.CH"
                                  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA756 ³ Autor ³ Wagner Mobile Costa    ³ Data ³ 10.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Lancamentos de Debito/Credito para composicao da Cobranca  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA756()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa756
PRIVATE aRotina  	:= MenuDef()
PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    , STR0030 },;
							{ 'BR_VERMELHO' , STR0031 }}
							
PRIVATE	aCores := 	{ { "BSQ->BSQ_NUMTIT= ' ' .And. BSQ->BSQ_NUMCOB= ' '",  'BR_VERDE'    },;
                      { "BSQ->BSQ_NUMTIT<>' ' .Or. BSQ->BSQ_NUMCOB<>' '", 'BR_VERMELHO' }}



Private cCadastro 	:= STR0001 //"Debitos/Creditos para Composicao Cobranca"
             
BSQ->(DbSetOrder(1))
BSQ->(DbSeek(xFilial("BSQ")))
BSQ->(mBrowse(06,01,22,75,'BSQ',,,,,,aCores)) 

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA756Mov ³ Autor ³ Wagner Mobile Costa ³ Data ³ 01.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama funcao para efetuar alteracao/exclusao de Lancamentos³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA756Mov(cAlias, nReg, nOpc)

If nOpc = K_Incluir 
	If  BSQ->(FieldPos("BSQ_NPARCE") ) == 0 .or. ! PLSALIASEX("B1Q") 
    	AxInclui(cAlias,nReg,nOpc,nil,nil,nil,"PLS756TOk()",nil,"PLS756Grv()")          
    else
	    PLSA756Par(cAlias, nReg, nOpc)
	endif
ElseIf nOpc = K_Alterar
	If BSQ->BSQ_NUMTIT <> ' '
		MsgAlert(STR0002, STR0003) //"Lancamento ja faturado. Somente podera ser visualizado !"###"Atencao"		
		AxVisual(cAlias,nReg,K_Visualizar)
	ElseIf Alltrim(BSQ->BSQ_TIPORI) == "PS" 
		MsgAlert(STR0004, STR0003) //"Lancamento gerado pela Integração SIGAPLS x Template Drogaria. Somente podera ser visualizado !"###"Atencao"
		AxVisual(cAlias,nReg,K_Visualizar)
	Else    
		AxAltera(cAlias,nReg,nOpc,nil,nil,nil,nil,"PLS756Alt()","PLS756Grv()")
	Endif
ElseIf nOpc = K_Excluir
	cDelFunc := "PLS756Del()"
	RegToMemory(cAlias)
	AxDeleta(cAlias,nReg,nOpc)
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS756Vld  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 10.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao dos campos chaves do Lancamento Cobranca  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS756Vld()

Local lRet 	:= .T.
LOCAL cMsg := ""

// Validacao do preenchimento dos campos que chamam a funcao

If ReadVar() = "M->BSQ_CODEMP" .And. ! Empty(M->BSQ_CODEMP)
	lRet := ExistCpo("BG9",M->BSQ_CODINT+M->BSQ_CODEMP)
	M->BSQ_CONEMP := Space(Len(M->BSQ_CONEMP))
	M->BSQ_VERCON := Space(Len(M->BSQ_VERCON))
	M->BSQ_SUBCON := Space(Len(M->BSQ_SUBCON))
	M->BSQ_VERSUB := Space(Len(M->BSQ_VERCON))
ElseIf ReadVar() = "M->BSQ_CONEMP" .And. ! Empty(M->BSQ_CONEMP)
	lRet := ExistCpo("BT5",M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_CONEMP)
	If lRet		// Gatilho o campo
		M->BSQ_VERCON := BT5->BT5_VERSAO
		M->BSQ_SUBCON := Space(Len(M->BSQ_SUBCON))
		M->BSQ_VERSUB := Space(Len(M->BSQ_VERCON))
	Endif
ElseIf ReadVar() = "M->BSQ_VERCON" .And. ! Empty(M->BSQ_VERCON)
	lRet := ExistCpo("BT5",M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_CONEMP+M->BSQ_VERCON)
ElseIf ReadVar() = "M->BSQ_SUBCON" .And. ! Empty(M->BSQ_SUBCON)
	lRet := ExistCpo("BQC",M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_CONEMP+M->BSQ_VERCON+M->BSQ_SUBCON)
	If lRet		// Gatilho o campo
		M->BSQ_VERSUB := BQC->BQC_VERSUB
	Endif
ElseIf ReadVar() = "M->BSQ_VERSUB" .And. ! Empty(M->BSQ_VERSUB)
	lRet := ExistCpo("BQC",M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_CONEMP+M->BSQ_VERCON+M->BSQ_SUBCON+M->BSQ_VERSUB)
	
Elseif ReadVar() = "M->BSQ_CODLAN" .And. ! Empty(M->BSQ_CODLAN)
	
Elseif ReadVar() = "M->BSQ_COBATO" .And. M->BSQ_COBATO == "1"
	If BSQ->(FieldPos("BSQ_COBATO")) > 0
		If !Empty(M->BSQ_USUARI)
			BA3->(dbSetorder(01))
			If BA3->(dbSeek(xFilial("BA3")+M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_MATRIC))
				If BSP->(dbSeek(xFilial("BSP")+M->BSQ_CODLAN))
					// Se for credito, tem que ter um fornecedor cadastrado na familia.
					If BA3->BA3_COBNIV == "1"
						If BSP->BSP_TIPSER == "1" // Debito.
						
							lRet := .F.
							cMsg := STR0032								
						Elseif  BSP->BSP_TIPSER == "2" // Credito, verifica integridade do nivel de cobranca.
							// Regra: se for para gerar titulo a pagar, o fornecedor será criado em tempo de execução, por isso, 
							// não precisa veririfar a existecia do fornecedor na familia.
	
							// Mas se for para gerar titulo NCC, o nível de cobrança precisa ser verificado. 
							If GetNewPar("MV_PLDBSE1","1") == "1"
									// Vai gerar NCC, então tem que ter cliente. 
								If (!Empty(BA3->BA3_CODCLI) .and.;
										!Empty(BA3->BA3_VENCTO) .and.;
										!Empty(BA3->BA3_NATURE))
								 
									// Nad nivel de cobrança válido para cobrança.
									lRet := .T.
								Else
									lRet := .F.
									cMsg := STR0034
								Endif
							Endif
						Endif
					Else
						lRet := .F.
						cMsg := STR0034
					Endif
				Endif
			Endif
		Else
			lRet := .F.
			cMsg := STR0035
		Endif
	Else
		lRet := .T.
	Endif
	
	If !lRet .and. !Empty(cMsg)
		MsgAlert(cMsg)
	Endif
Endif


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS756Alt  ³ Autor ³ Patricia Duca       ³ Data ³ 07.12.09 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao da alteracao do lancamento de deb/crd     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS756Alt()
Local lRet := .T.
	// Ponto de entrada para validacao de usuarios.
If ExistBlock("PLS756VU") 
	lRet:= Execblock("PLS756VU",.F.,.F.,{4})
EndIf   

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS756Del  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 10.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao da exclusao do lancamento de deb/crd      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS756Del()
Local lRet := .T.
LOCAL cChavTit := ""

If BSQ->BSQ_NUMCOB <> ' '
	MsgAlert(STR0002, STR0003) //"Lancamento ja faturado. Somente podera ser visualizado !"###"Atencao"
	lRet := .F.
ElseIf Alltrim(BSQ->BSQ_TIPORI) == "PS" 
	MsgAlert(STR0004, STR0003) //"Lancamento gerado pela Integração SIGAPLS x Template Drogaria. Somente podera ser visualizado !"###"Atencao"
	lRet := .F.
Endif
                   
If lRet                
	If BSQ->(FieldPos("BSQ_COBATO")) > 0
		lFaturado := .F.	
		If BSQ->BSQ_COBATO == "1" .and.;
			!Empty(BSQ->BSQ_PREFIX) .and.;
		 	!Empty(BSQ->BSQ_NUMTIT)
		 
		 	lFaturado := .T.
		Endif
		
		If lFaturado
			cChavTit := BSQ->(BSQ_PREFIX+BSQ_NUMTIT+BSQ_PARCEL+BSQ_TIPTIT)
     		DbSelectArea("SE1")
		   	SE1->(DbSetOrder(1))
		   	BBT->(DbSetOrder(7))
			BM1->(dbSetorder(4))
		    If GetNewPar("MV_PLDBSE1","1") == "0"//trato a exlusao do remebolso no se2
		    	SE2->(DbSetORder(1))
		    	If SE2->(MsSeek(xFilial("SE2")+cChavTit))
		    		If PLCANCRE()[1]  // se autorizado, excluo o titulo e segue excluindo os demais registros.
		    			If BBT->(dbSeek(xFilial("BBT")+cChavTit+BSQ->BSQ_RECPAG))
		    				BBT->(RecLock("BBT", .F.))
		    					BBT->(dbDelete())
		    				BBT->(MsUnlock())		    			
		    			Endif
		    			
		    			If BM1->(dbSeek(xFilial("BM1")+cChavTit+BSQ->(BSQ_CODINT+BSQ_CODEMP+BSQ_MATRIC)))
		    				While !BM1->(Eof()) .and. BM1->(BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC) ==;
		    											 xFilial("BM1")+cChavTit+BSQ->(BSQ_CODINT+BSQ_CODEMP+BSQ_MATRIC)
		    											 
		    					BM1->(RecLock("BM1", .F.))
		    						BM1->(dbDelete())
		    					BM1->(MsUnlock())
		    					
		    					BM1->(dbSkip())
		    				Enddo
		    			Endif
		    		Else
		    			lRet := .F.		    			
		    		Endif
		    	Endif
				
		    Else	

				If SE1->(MsSeek(xFilial("SE1")+cChavTit))

					//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
					aRetASE1 := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

					//[1] - Calendario contabil (.T./.F.)
					//[2] - Movimentado (.T./.F.)
					
					If aRetASE1[1] .and. aRetASE1[2]
						Help("",1,"PL001010")
						Return .f.
					Endif

     			Endif

			    If SE1->(MsSeek(xFilial("SE1")+cChavTit)) .And. BBT->(MsSeek(xFilial("BBT")+cChavTit))
				
					BDC->(DbSetOrder(1))
					If BDC->(DbSeek(xFilial("BDC")+BBT->(BBT_NUMCOB)))
						PL627MOV("BDC",BDC->(Recno()),K_Excluir,.T.)
					Endif   

    		   	Endif

    		Endif    
		Endif
	Endif
Endif	  

// Ponto de entrada para validacao de usuarios.
If lRet .and. ExistBlock("PLS756VU") 
	lRet := Execblock("PLS756VU",.F.,.F.,{5})
EndIf                        

Return lRet   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS756TOk  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 17.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao da inclusao do lancamento de deb/crd      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±³16/11/2004³      ³ Geraldo Jr  ³Validar nivel de cobranca              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS756TOk(cTipo, nOpc)

LOCAL lRet    := .T.
LOCAL nH   	  := PLSAbreSem("PL756GRV.SMF")
LOCAL aRet    := {}
DEFAULT cTipo := "1"
DEFAULT nOpc  := 3 // Padrao eh incluir.

BM1->(DbSetOrder(3))
If 	BM1->(DbSeek(xFilial("BM1") + M->BSQ_CODINT + M->BSQ_CODEMP + M->BSQ_CONEMP +;
	M->BSQ_VERCON + M->BSQ_SUBCON + M->BSQ_VERSUB + Subs(M->BSQ_USUARI,;
	Len(BSQ->BSQ_CODINT + BSQ->BSQ_CODEMP) + 1,;
	Len(BA1->BA1_MATRIC + BA1->BA1_TIPREG)) + Space(3) + M->BSQ_ANO + M->BSQ_MES))
	MsgAlert(STR0005, STR0003) //"Faturamento do mes para o usuario ja foi gerado. Lancamento nao podera ser efetuado !"###"Atencao"
	lRet := .F.
	
Endif	
BM1->(DbSetOrder(1))	

// Valida o nivel de cobranca!
If (!Empty(M->BSQ_MATRIC) .and. Empty(M->BSQ_USUARI)) .or. (!Empty(M->BSQ_MATRIC) .and. !Empty(M->BSQ_USUARI))
	BA3->( dbSetorder(01) )
	If BA3->( dbSeek(xFilial("BA3")+M->(BSQ_CODINT+BSQ_CODEMP+BSQ_MATRIC)) ) 

		aRet := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC)

		If !aRet[1]
			Aviso(STR0006,STR0006,{"OK"}) //"Nivel de cobranca invalido!"###"Nivel de cobranca invalido!"
			lRet := .F.
		Endif
	Else
		Aviso(STR0007,STR0008,{"OK"}) //"Familia invalida!"###"A familia informada nao existe!"
		lRet := .F.
	Endif
	
Elseif !Empty(M->BSQ_SUBCON)
	BQC->( dbSetorder(01) )
	If BQC->( dbSeek(xFilial("BQC")+M->(BSQ_CODINT+BSQ_CODEMP+BSQ_CONEMP+BSQ_VERCON+BSQ_SUBCON+BSQ_VERSUB)) )
		If BQC->BQC_COBNIV <> '1'
			Aviso(STR0006,STR0006,{"OK"}) //"Nivel de cobranca invalido!"###"Nivel de cobranca invalido!"
			lRet := .F.
		Endif
	Else
		Aviso(STR0009,STR0010,{"OK"}) //"Sub contrato invalido!"###"O sub contrato informado nao existe!"
		lRet := .F.				
	Endif

Elseif !Empty(M->BSQ_CONEMP)
	BT5->( dbSetorder(01) )
	If BT5->( dbSeek(xFilial("BT5")+M->(BSQ_CODINT+BSQ_CODEMP+BSQ_CONEMP+BSQ_VERCON)) )
		If BT5->BT5_COBNIV <> '1'
			Aviso(STR0006,STR0006,{"OK"}) //"Nivel de cobranca invalido!"###"Nivel de cobranca invalido!"
			lRet := .F.
		Endif
	Else
		Aviso(STR0011,STR0012,{"OK"}) //"Contrato invalido!"###"O Contrato informado nao existe!"
		lRet := .F.				
	Endif			

Elseif !Empty(M->BSQ_CODEMP)
	BG9->( dbSetorder(01) )
	If BG9->( dbSeek(xFilial("BG9")+M->(BSQ_CODINT+BSQ_CODEMP)) )
		If BG9->BG9_TIPO == '2'
			If Empty(BG9->BG9_CODCLI)
				Aviso(STR0006,STR0013,{"OK"}) //"Nivel de cobranca invalido!"###"Cliente invalido!"
				lRet := .F.
			Endif
		Else
			If BA3->( dbSeek(xFilial("BA3")+M->(BSQ_CODINT+BSQ_CODEMP+BSQ_MATRIC)) ) 			
				If Empty(BA3->BA3_CODCLI)
					Aviso(STR0006,STR0013,{"OK"}) //"Nivel de cobranca invalido!"###"Cliente invalido!"
					lRet := .F.
				Endif			
			Else
				Aviso(STR0007,STR0008,{"OK"}) //"Familia invalida!"###"A familia informada nao existe!"
				lRet := .F.
			Endif				
		Endif
	Else
		Aviso(STR0014,STR0015,{"OK"}) //"Grupo empresa invalido!"###"O grupo empresa informado nao existe!"
		lRet := .F.				
	Endif

Endif

// Nao pode informar uma maticula se a familia nao possuir um titular.
// O campo usuario eh preenchido por meio de gatilho, se nao foi preenchido eh porque
// a familia esta sem o titular.
If !Empty(M->BSQ_MATRIC) .and. Empty(M->BSQ_USUARI) 
	Aviso(STR0016,STR0017,{"OK"})	 //"Matricula invalida"###"A matricula informada nao possui um titular valido!"
	lRet := .F.
Endif

// Regras para geração de titulo no ato.
If BSQ->(FieldPos("BSQ_COBATO")) > 0 .AND. M->BSQ_COBATO == "1"
	If !Empty(M->BSQ_USUARI)
		BA3->(dbSetorder(01))
		If BA3->(dbSeek(xFilial("BA3")+M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_MATRIC))
			If BSP->(dbSeek(xFilial("BSP")+M->BSQ_CODLAN))
					// Se for credito, tem que ter um fornecedor cadastrado na familia.
				If BA3->BA3_COBNIV == "1"
					If BSP->BSP_TIPSER == "1" // Debito.
						
						Aviso(STR0033,STR0034,{"OK"}) //"Grupo empresa invalido!"###"O grupo empresa informado nao existe!"
						lRet := .F.
					Endif
				Endif
			Endif
		Endif
	Endif
	
	If lRet
		If Val(M->BSQ_NPARCE) > 1
			Aviso(STR0033,"O pagamento no ato só pode ser realizado em uma única parcela.",{"OK"}) //"Grupo empresa invalido!"###"O grupo empresa informado nao existe!"
			lRet := .F.
		Endif
	Endif
			
Endif

If lRet .and. cTipo == "1"
	M->BSQ_CODSEQ := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")
Endif 
                        
// Ponto de entrada para validacao de usuarios.
If lRet .and. ExistBlock("PLS756VU") 
	lRet := Execblock("PLS756VU",.F.,.F.,{nOpc})
EndIf                        

PLSFechaSem(nH,"PL756GRV.SMF")

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS756Grv  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 14.10.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua flag do lancamento no usuario/familia               ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS756Grv(cTipo)

LOCAL cNivel    := ''    
LOCAL aCliente  := {}
LOCAL cCodInt 	:= ''
LOCAL cCodEmp	:= ''
LOCAL cMat		:= ''
LOCAL cTipReg	:= ''
LOCAL lCobAto := .F.
LOCAL cDescri := ""
LOCAL aBanco	:= {}
LOCAL lValid  := .F.
LOCAL cNat 	:= ""
LOCAL cTipTit := ""
LOCAL cPrefixo:= ""
LOCAL cNumTit := ""
LOCAL dVencto := cTod("")			
LOCAL cMesAut := ""
LOCAL cAnoAut := ""
LOCAL cBanco  := ""
LOCAL cAgencia:= ""
LOCAL cConta  := ""
LOCAL nOrdBa1O:= 0
LOCAL nRecBa1O:= 0
LOCAL cMatric := ""
LOCAL cConEmp := ""
LOCAL cVerCon := ""
LOCAL cSubCon := ""
LOCAL cVerSub := ""
LOCAL aRetPto := {}
LOCAL lFoundSA2:= .F.
LOCAL cCliFor := ""
LOCAL cLoja    := ""
LOCAL nVlrPag  := ""
LOCAL lRetorno := .T.				
DEFAULT cTipo  := "1"

BA1->(DbSetOrder(2))
BA3->(DbSetOrder(1))
If At(" ", M->BSQ_USUARI) = 0 .And. BA1->(DbSeek(xFilial("BA1") + M->BSQ_USUARI))
	RecLock("BA1", .F.)
	BA1->BA1_OUTLAN := "1"
	BA1->(MsUnLock())
ElseIf 	BA3->(DbSeek(xFilial("BA3") + AllTrim(M->BSQ_USUARI) + M->BSQ_CONEMP +;
		M->BSQ_VERCON + M->BSQ_SUBCON + M->BSQ_VERSUB))
	RecLock("BA3", .F.)
	BA3->BA3_OUTLAN := "1"
	BA3->(MsUnLock())
Endif

BA1->(DbSetOrder(1))       
If !Empty(M->BSQ_USUARI)                                 
	
	cCodInt := Subs(M->BSQ_USUARI,atCodOpe[1],atCodOpe[2])
	cCodEmp := Subs(M->BSQ_USUARI,atCodEmp[1],atCodEmp[2])
	cMatric := Subs(M->BSQ_USUARI,atMatric[1],atMatric[2])
	cTipReg := Subs(M->BSQ_USUARI,atTipReg[1],atTipReg[2])

 	aCliente := PLSAVERNIV(cCodInt,cCodEmp,cMatric,M->BSQ_TIPEMP,M->BSQ_CONEMP,M->BSQ_VERCON,;
							M->BSQ_SUBCON,M->BSQ_VERSUB,nil,cTipReg,.F.,nil)     							
							
	If Len(aCliente[1]) > 17  
		cNivel := aCliente[1,18]
	Else
		cNivel := '5'
	EndIf
Elseif !Empty(M->BSQ_MATRIC)                          
	cNivel := '4'
	
Elseif !Empty(M->BSQ_SUBCON)
	cNivel := '3'
	
Elseif !Empty(M->BSQ_CONEMP)
	cNivel := '2'
	
Elseif !Empty(M->BSQ_CODEMP)
	cNivel := '1'	
Endif
If !BSQ->( Eof() )
	BSQ->(RecLock("BSQ", .F.) )
		BSQ->BSQ_COBNIV := cNivel				                       
	BSQ->( MsUnlock() )
Endif                                        

If BSQ->(FieldPos("BSQ_COBATO")) > 0
	lCobAto := .F.
	If BSQ->BSQ_CODLAN <> M->BSQ_CODLAN
		If !BSP->(dbSeek(xFilial("BSP")+M->BSQ_CODLAN))
			Return .T.
		endif
	Endif
	
	cDescri := BSP->BSP_DESCRI
		
	// Extentendo a utilidade da melhoria: qualquer debito / credito poderá gerar um titulo no ato.
	If M->BSQ_COBATO == '1'
		
		If MsgYesNo(STR0036)
			lValid := .F.
			While !lValid
				If Pergunte("PLCBDB", .T.)
					dVencto := MV_PAR01
				
					If dVencto >= dDataBase
						lValid := .T.
					Else
						MsgAlert(STR0037)
					Endif
				Else
					lValid := .F.
					Exit
				EndIf
			Enddo
	
			If !lValid
				MsgAlert(STR0038)
				
				Return (.T.)
			Endif
		Else
			MsgAlert(STR0038)				
			Return (.T.)			
		Endif
		

		// Se a forma de pagamento for no ato
		//Gera a NCC                                              	
		lAprova := .T.
		If ExistBlock("PLSCOBDB")
			lAprova := ExecBlock("PLSCOBDB",.F.,.F.,{cProtoc,dAprov,dVencto})
		Endif
	
		If GetNewPar("MV_PLDBSE1","0") == "1" .and. lAprova
			BA3->(dbSetorder(01))
			If BA3->(dbSeek(xFilial("BA3")+M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_MATRIC))
				cNat := BA3->BA3_NATURE
				cTipTit  := GetNewPar("MV_PLSNCDB","NCC")
				cPrefixo := GetNewPar("MV_PLSPFDB",'"DBC"')
				cPrefixo := Eval({|| &cPrefixo })
				cNumTit  := PLSE1NUM(cPrefixo)
				
				cCliFor  := BA3->BA3_CODCLI
				cLoja    := BA3->BA3_LOJA
				nVlrPag  := M->BSQ_VALOR
				cCodInt  := M->BSQ_CODINT
				cCodEmp  := M->BSQ_CODEMP
				cMatric  := M->BSQ_MATRIC
				cConEmp  := M->BSQ_CONEMP
				cVerCon  := M->BSQ_VERCON
				cSubCon  := M->BSQ_SUBCON
				cVerSub  := M->BSQ_VERSUB
				
				If ExistBlock("PLS756CLI")
					aRetPto := ExecBlock("PLS756CLI",.F.,.F.,{cCliFor,cLoja,cNat,cPrefixo,cNumTit,cTipTit,dVencto})
					cCliFor := aRetPto[1]
					cLoja   := aRetPto[2]
					cNat    := aRetPto[3]
					cPrefixo:= aRetPto[4]
					cNumTit := aRetPto[5]
					cTipTit := aRetPto[6]					
				EndIf
			
				aBanco := {}
				aAdd(aBanco,BA3->BA3_BCOCLI) //Numero Banco
				aAdd(aBanco,BA3->BA3_AGECLI) //Numero Agencia
				aAdd(aBanco,BA3->BA3_CTACLI) //Numero Conta
					
				PLSGRVREM(cPrefixo,cNumTit,cCliFor,cLoja,cTipTit,dVencto,cCodInt,;
					cCodEmp,cMatric,3,nVlrPag,cConEmp,cVerCon,cSubCon,;
					cVerSub,cTipReg,cNat,aBanco,M->BSQ_ANO,M->BSQ_MES,cDescri,"PLSA756",BSP->BSP_CODLAN)
				
				//Atualiza os dados dos títulos no protocolo
				BSQ->(RecLock('BSQ',.F.))
					BSQ->BSQ_PREFIX := cPrefixo
					BSQ->BSQ_NUMTIT := cNumTit
					BSQ->BSQ_TIPTIT := cTipTit
					BSQ->BSQ_PARCEL := ''
					If BSQ->(FieldPos("BSQ_RECPAG")) > 0
						BSQ->BSQ_RECPAG := "1"
					Endif
				BSQ->( MsUnlock() )
								
				APROVFIN(Alltrim(BA1->BA1_NOMUSR), cPrefixo+cNumTit+cTipTit+BSQ->BSQ_PARCEL, cDescri)				
			Else
				MsgAlert("Geração do título foi abortada porque não foi possível localizar a família para validar o nível de cobrança.")
			Endif
		ElseIf GetNewPar("MV_PLDBSE1","0") == "0" .and. lAprova
			BA3->(dbSetorder(01)) 	
			If BA3->(dbSeek(xFilial("BA3")+M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_MATRIC))
				cNat 	  := BA3->BA3_NATURE
				cTipTit  := GetNewPar("MV_PLSNCDB","DP")
				cPrefixo := GetNewPar("MV_PLSPFDB",'"PDB"')
				cPrefixo := Eval({|| &cPrefixo })
				cNumTit  := PLSREMSE2(cPrefixo)

				cMesAut  := M->BSQ_MES
				cAnoAut  := M->BSQ_ANO			 			 
				cBanco   := BA3->BA3_BCOCLI
				cAgencia := BA3->BA3_AGECLI
				cConta   := BA3->BA3_CTACLI
			
				cCodInt  := M->BSQ_CODINT
				cCodEmp  := M->BSQ_CODEMP
				cMatric  := M->BSQ_MATRIC
				cConEmp  := M->BSQ_CONEMP
				cVerCon  := M->BSQ_VERCON
				cSubCon  := M->BSQ_SUBCON
				cVerSub  := M->BSQ_VERSUB
				
				//Armazenar Referencia Arquivo BA1 ...
				nOrdBa1O  := BA1->(IndexOrd())
				nRecBa1O  := BA1->(Recno())
	                        
				//Forcar Buscar Registro Beneficiario Titular ...
				BA1->(DbSetOrder(2))
				BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+"00"))
	
				//Setar Ordem Arquivo SA2 - Cadastro Fornecedores (SA2) ...
				If !Empty(BA3->BA3_CODFOR) .and. !Empty(BA3->BA3_LOJFOR)
					SA2->(dbSetorder(01))
					If SA2->(dbSeek(xFilial("SA2")+BA3->BA3_CODFOR + BA3->BA3_LOJFOR))
						cCliFor := SA2->A2_COD
						cLoja   := SA2->A2_LOJA
					Endif
				Endif
				
				If Empty(cCliFor)
					SA2->(DbSetOrder(3))
			
					//Verifico Se Eh Beneficiario Titular ...
					If AllTrim(BA1->BA1_TIPUSU) $ "T" // Titular ????
						lFoundSA2 := (!Empty(BA1->BA1_CPFUSR) .And. SA2->(DbSeek(xFilial("SA2")+BA1->BA1_CPFUSR)))  //1a Vez .F. e na 2a Vez .T.
					Else //Se Nao Eh Titular
						lFoundSA2 := .T. //Para nao acessar Area Criacao Cadastro SA2.
					EndIf
			
					//pode ter cliente que quer usar a busca por nome
					If GetNewPar("MV_PLRENOM","1") == "1"
						SA2->(DbSetOrder(2))
						lFoundSA2 := SA2->(dbSeek(xFilial("SA2")+SA2->A2_NOME))
					Endif
		    
		    		//busco o banco caso nao tenha sido informado ainda
					If !(lFoundSA2)
						SA2->(RecLock("SA2",.T.))
						SA2->A2_FILIAL	:= xFilial("SA2")
						SA2->A2_COD		:= GetSX8Num("SA2","A2_COD")
						SA2->A2_LOJA	   	:= '01'
						SA2->A2_NOME	   	:= BA1->BA1_NOMUSR
						SA2->A2_CGC		:= BA1->BA1_CPFUSR
						SA2->A2_TEL		:= BA1->BA1_TELEFO
						SA2->A2_FAX      	:= BA1->BA1_TELEFO
						SA2->A2_NREDUZ	:= BA1->BA1_NOMUSR
						SA2->A2_BAIRRO	:= BA1->BA1_BAIRRO
						SA2->A2_MUN		:= BA1->BA1_MUNICI
						SA2->A2_EST		:= BA1->BA1_ESTADO
						SA2->A2_END		:= BA1->BA1_ENDERE
						SA2->A2_TIPO 	 	:= "F"
						SA2->A2_EMAIL    	:= BA1->BA1_EMAIL
						SA2->A2_BANCO    	:= cBanco
						SA2->A2_AGENCIA  	:= cAgencia
						SA2->A2_NUMCON   	:= cConta
						SA2->(MsUnlock())
						SA2->(ConfirmSX8())
					EndIf
					
					//Atualizo Variaveis do Fornecedor ...
					cCliFor := SA2->A2_COD
					cLoja   := SA2->A2_LOJA
				Endif
				
				//Reposicionar Beneficiario ...
				BA1->(DbSetOrder(nOrdBa1O))
				BA1->(DbGoTo(nRecBa1O))
	
				nVlrPag  := M->BSQ_VALOR		
				If ExistBlock("PLS002FOR")
					aRetPto  := ExecBlock("PLS002FOR",.F.,.F.,{cCliFor,cLoja,cNat,cPrefixo,cNumTit,cTipo,dVencto,cCodInt,cCodEmp,cMatric})
					cCliFor  := aRetPto[1]
					cLoja    := aRetPto[2]
					cNat     := aRetPto[3]
					cPrefixo := aRetPto[4]
					cNumTit  := aRetPto[5]
					cTipo    := aRetPto[6]
					dVencto  := aRetPto[7]
				EndIf
				
				aBanco := {}
				aAdd(aBanco,cBanco) //Numero Banco
				aAdd(aBanco,cAgencia) //Numero Agencia
				aAdd(aBanco,cConta) //Numero Conta
					
				lRet := PLSGRVREM(cPrefixo,cNumTit,cCliFor,cLoja,cTipTit,dVencto,cCodInt,;
					cCodEmp,cMatric,3,nVlrPag,cConEmp,cVerCon,cSubCon,cVerSub,cTipReg,cNat,;
					aBanco,M->BSQ_ANO,M->BSQ_MES,cDescri,"PLSA756",BSP->BSP_CODLAN,"2","0",BSQ->BSQ_CODSEQ)
				
				If lRet
					//Atualiza os dados dos títulos no protocolo
					BSQ->(RecLock('BSQ',.F.))
						BSQ->BSQ_PREFIX := cPrefixo
						BSQ->BSQ_NUMTIT := cNumTit
						BSQ->BSQ_TIPTIT := cTipTit
						BSQ->BSQ_PARCEL := ''
						If BSQ->(FieldPos("BSQ_RECPAG")) > 0
							BSQ->BSQ_RECPAG := "2"
						Endif
					BSQ->( MsUnlock() )
					
					APROVFIN(Alltrim(BA1->BA1_NOMUSR), cPrefixo+cNumTit+cTipTit+BSQ->BSQ_PARCEL, cDescri)
				Endif				
			EndIf
		Endif
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA756LEG ³ Autor ³ Wagner Mobile Costa ³ Data ³ 01.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA756Leg()

Local aLegenda := { 	{ aCdCores[1,1],aCdCores[1,2] },;
                     	{ aCdCores[2,1],aCdCores[2,2] } }

BrwLegenda(cCadastro,STR0018 ,aLegenda) //"Status"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS756MAT ºAutor  ³Geraldo Felix Juniorº Data ³  11/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho do campo BSQ_MATRIC que leva para o campo USUARIO a º±±
±±º          ³matricula do titular da familia informada 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS756MAT()
LOCAL cRetMat 	:= ''
LOCAL lRet 		:= .F.

BA1->( dbSetorder(02) )
If BA1->( dbSeek(xFilial("BA1")+M->BSQ_CODINT+M->BSQ_CODEMP+M->BSQ_MATRIC) )
	If BA1->BA1_TIPREG == '00'
		cRetMat := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		lRet := .T.
	Endif
Endif

If !lRet
	MsgAlert(STR0019) //"A familia informada nao possui um titular valido!"
Endif                            

Return(cRetMat)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA756Par ³ Autor ³ Daher				³ Data ³ 25.04.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Inclui debito/credito 									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                              
Function PLSA756Par(cAlias,nReg,nOpc)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpca	    := 0
LOCAL oDlg
LOCAL cCadastro := STR0020  //"Debito/Credito"
LOCAL i 	 := 1                    
LOCAL j 	 := 1                     
LOCAL cChave := ""
LOCAL cChaMe := "" 
LOCAL aHeadBSQ := {}
LOCAL nH	 
LOCAL nSeq
LOCAL cCodSeq
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
			 
PRIVATE oEnchoice
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE nOpcx  := nOpc
PRIVATE aCols
PRIVATE aHeader     
PRIVATE oGetDados
PRIVATE aButtons := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, aSize[4] * 0.25, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "BSQ" TO Memory Blank
Zero();oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "B1Q" TO Memory Blank
Store Header "B1Q" TO aHeader For .T.
Store COLS Blank "B1Q" TO aCols FROM aHeader
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"AllwaysTrue","AllwaysTrue",,.T.,,,,,,,,,oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela) .and. PLS756TOk("2", nOpc),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons)  }) Center
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK                                       
    Store header "BSQ" to aHeadBSQ for .T.      
    nH  := PLSAbreSem("PL756PAR.SMF")
    while i <= len(aCols)            
	    cCodSeq := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")
		BSQ->(Reclock("BSQ",.T.))		                               
			// Grava a filial, pois o campo filial nao esta no aheader.
			BSQ->BSQ_FILIAL := xFilial("BSQ")
			
			while j <= len(aHeadBSQ) 
				if aHeadBSQ[j][10] == 'V'
				     j++       
				     loop
				endif
				cChave := "BSQ->"+aHeadBSQ[j][2]
			    cChaMe := "M->"+aHeadBSQ[j][2]
			    &cChave:= &cChaMe
				if "BSQ_ANO" $ aHeadBSQ[j][2]
				    nPos := PLRETPOS("B1Q_ANO",aHeader)                     
					&cChave:= aCols[i][nPos]
				elseif "BSQ_MES" $ aHeadBSQ[j][2]
					nPos := PLRETPOS("B1Q_MES",aHeader)
					&cChave:= aCols[i][nPos]
				elseif "BSQ_VALOR" $ aHeadBSQ[j][2]
					nPos := PLRETPOS("B1Q_VALOR",aHeader)
					&cChave:= aCols[i][nPos]    
				elseif "BSQ_CODSEQ" $ aHeadBSQ[j][2]
					&cChave:= cCodSeq
				endif 
			    j++		                         
			enddo
		BSQ->(MsUnLock())
	    i++ 
	    j:=1             
	    PLS756Grv()
	enddo          
	PLSFechaSem(nH,"PL756PAR.SMF")             
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA756Ger ³ Autor ³ Daher				³ Data ³ 25.04.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Gera as parcelas											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                        
Function PLSA756Ger(ret)                                          

LOCAL lBranco
LOCAL nCont 
LOCAL aTrab
LOCAL cAnoAux
LOCAL cMesAux
LOCAL nMaxPar   := getnewpar("MV_PLNMADI",8)
LOCAL nVlMinPar := getnewpar("MV_PLVLMPA",10)                   

If Type("aHeader") <> 'A'
	Return(ret)
Endif

If val(M->BSQ_NPARCE) > nMaxPar
   MsgStop(STR0021+Chr(13)+STR0022+Str(nMaxPar,2)) //"A quantidade de parcela supera o limite parametrizado no parametro MV_PLNMADI"###"que indica "
   Return(ret)
Endif           

If (M->BSQ_VALOR/val(M->BSQ_NPARCE)) < nVlMinPar
   MsgStop(STR0023+Chr(13)+STR0022+Str(nVlMinPar,17,2)) //"O Valor da prestacao supera o valor minino parametrizado no parametro MV_PLVLMPA"###"que indica "
   Return(ret)
Endif   

//lBranco := Eval( { || nPos := PLRETPOS("B1Q_CODPAR",aHeader), Empty(aCols[1,nPos]) } )
cAnoAux := M->BSQ_ANO
cMesAux := M->BSQ_MES

/*If ! lBranco
   If ! MsgYesNo("As parcelas ja foram geradas. Gerar novamente ?")
      Return(ret)
   Endif
Endif*/

aCols := {}

If lBranco
   aCols := {}
   Store COLS Blank "B1Q" TO aCols FROM aHeader      
Endif   

For nCont := 1 To val(M->BSQ_NPARCE)
    If nCont > Len(aCols)
       Store COLS Blank "BSQ" TO aTrab FROM aHeader          
       aadd(aCols,aTrab[1])
    Endif
    
    nPos := PLRETPOS("B1Q_CODSEQ",aHeader)                     
    aCols[nCont,nPos] := M->BSQ_CODSEQ
    
    nPos := PLRETPOS("B1Q_CODPAR",aHeader)                     
    aCols[nCont,nPos] := alltrim(strzero(nCont,2))
    
    nPos := PLRETPOS("B1Q_ANO",aHeader)                     
    aCols[nCont,nPos] := cAnoAux
    
    nPos := PLRETPOS("B1Q_MES",aHeader)                     
    aCols[nCont,nPos] := cMesAux
    
    nPos := PLRETPOS("B1Q_VALOR",aHeader)
    aCols[nCont,nPos] := M->BSQ_VALOR/val(M->BSQ_NPARCE)
    
    If cMesAux == "12"
       cMesAux := "01"
       cAnoAux := alltrim(Str(Val(cAnoAux)+1))
    Else
       cMesAux := StrZero(Val(cMesAux)+1,2)
    Endif   
Next   

GetdRefresh()

Return(ret)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PlsValBsq  ³ Autor ³ Daher				³ Data ³ 25.04.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 	Valid do campo											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                       
Function PLSVALBSQ()                          

LOCAL cMatric := alltrim(M->BSQ_USUARI)
LOCAL lRet    := .F.
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())    
LOCAL bRest   := {|| BA1->(DbSetOrder(nOrdBA1)),BA1->(DbGoTo(nRecBA1)) }

If !Empty(cMatric)
	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+cMatric))
		// Pede confirmacao em caso de usuarios bloqueados...
		If !Empty(BA1->BA1_MOTBLO) .and. !Empty(BA1->BA1_DATBLO)
			If !MsgYesNo(STR0024) //"O usuario selecionado esta bloqueado... Deseja continuar ?"
				Return(lRet)
			Endif
		Endif
						
		M->BSQ_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		If Type("M->BSQ_MATANT") <> 'U'
			M->BSQ_MATANT := BA1->(BA1_MATANT)
		Endif                        
		M->BSQ_CODINT := BA1->BA1_CODINT
		M->BSQ_CODEMP := BA1->BA1_CODEMP
		M->BSQ_CONEMP := BA1->BA1_CONEMP
		M->BSQ_VERCON := BA1->BA1_VERCON
		M->BSQ_SUBCON := BA1->BA1_SUBCON
		M->BSQ_VERSUB := BA1->BA1_VERSUB
		M->BSQ_MATRIC := BA1->BA1_MATRIC		
		lRet := .T.
	Else
		BA1->(DbSetOrder(5))
		If BA1->(MsSeek(xFilial("BA1")+cMatric))
			// Pede confirmacao em caso de usuarios bloqueados...
			If !Empty(BA1->BA1_MOTBLO) .and. !Empty(BA1->BA1_DATBLO)
				If !MsgYesNo(STR0024) //"O usuario selecionado esta bloqueado... Deseja continuar ?"
					Return(lRet)
				Endif
			Endif		
			
			M->BSQ_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			If Type("M->BSQ_MATANT") <> 'U'
				M->BSQ_MATANT := BA1->(BA1_MATANT)
			Endif
			M->BSQ_CODINT := BA1->BA1_CODINT
			M->BSQ_CODEMP := BA1->BA1_CODEMP
			M->BSQ_CONEMP := BA1->BA1_CONEMP
			M->BSQ_VERCON := BA1->BA1_VERCON
			M->BSQ_SUBCON := BA1->BA1_SUBCON
			M->BSQ_VERSUB := BA1->BA1_VERSUB
			M->BSQ_MATRIC := BA1->BA1_MATRIC					
			lRet := .T.	
		Endif
	Endif
Else
	lRet := .T.
Endif      

Eval(bRest)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa??o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {   	{ STRPL01	, 'AxPesqui'   	, 0 , K_Pesquisar  	, 0, .F.},;
						{ STR0025	, 'AxVisual' 	, 0 , K_Visualizar 	, 0, Nil},; //"Visualizar"
						{ STR0026	, 'PLSA756Mov'	, 0 , K_Incluir    	, 0, Nil},; //"Incluir"
						{ STR0027	, 'PLSA756Mov' 	, 0 , K_Alterar    	, 0, Nil},; //"Alterar"
						{ STR0028	, 'PLSA756Mov' 	, 0 , K_Excluir    	, 0, Nil},; //"Excluir"
						{ STR0029	, "PLSA756LEG"	, 0 , K_Incluir     , 0, .F.} } //"Legenda"
Return(aRotina)


