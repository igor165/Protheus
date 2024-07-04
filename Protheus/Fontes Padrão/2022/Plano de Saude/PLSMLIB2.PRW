#INCLUDE "PLSMLIB2.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#define __aCdCri115 {"549",STR0001}   //"Nao foi possivel localizar o lancamento de debito/credito."

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLAXCAD ³ Autor ³ Tulio Cesar          ³ Data ³ 23.02.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AxCadastro do Plano de Saude.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLAXCAD(cAlias,cTitulo)
PRIVATE aRotina      := { { STRPL01 ,'AxPesqui' , 0 ,K_Pesquisar  },;
                          { STRPL02 ,'PLAXCDMV' , 0 ,K_Visualizar },;
       		 	          { STRPL03 ,'PLAXCDMV' , 0 ,K_Incluir    },;
					      { STRPL04 ,'PLAXCDMV' , 0 ,K_Alterar    },;
                          { STRPL05 ,'PLAXCDMV' , 0 ,K_Excluir    } }
PRIVATE cCadastro 	:= cTitulo        

If Type("bDelLine") <> "B"
   bDelLine := { || .T. }
Endif

If Type("bEdit") <> "B"
   bEdit := { || .T. }
Endif      

If Type("bVisual") <> "B"
   bVisual := { || .T. }
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao de Browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(06,01,22,75,cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLAXCDMV ³ Autor ³ Tulio Cesar           ³ Data ³ 23.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao, Inclusao, Alteracao e Exclusao de PLAXCAD    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLAXCDMV(cAlias,nReg,nOpc,bAfter)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso na enchoice...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpca    := 0
LOCAL bOK      := {|| nOpca := 1,If(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel  := {||oDlg:End()}
LOCAL bOKAuto  := {|| nOpca := 1,if(.T.,Nil,nOpca:=2),If(nOpca==1,nil,.F.) }
LOCAL oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da Enchoice...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Genericos...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOpcx	    := nOpc
PRIVATE lExc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para rotinas automaticas...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("bDelLine") <> "B"
   bDelLine := { || .T. }
Endif

If Type("bEdit") <> "B"
   bEdit := { || .T. }
Endif      

If Type("bVisual") <> "B"
   bVisual := { || .T. }
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa edicao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Visualizar
   If nOpc <> K_Incluir
      If ! Eval(bEdit)
         Return
      Endif   
   Endif   
Else
   If ! Eval(bVisual)
      Return
   Endif   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialogo...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSISAUTO()
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ENCHOICE (BD1)                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSISAUTO()
   If nOpcx == K_Incluir
      Copy cAlias TO Memory Blank
   Else
      Copy cAlias TO Memory
   Endif
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MSMGET -> CONTRATO                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSISAUTO()
   MSMGet():New(cAlias,nReg,nOpcx,,,,,{,,(oDlg:nClientHeight - 4)/2,},,,,,,oDlg,,,.F.)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSISAUTO()
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel)
Else
   Eval(bOKAuto)
Endif   

If PLSISAUTO()
   nOpca := K_OK
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Rotina de Gravacao dos Dados...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	nOpca == K_OK
      If     nOpcx <> K_Visualizar
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Trato parametro cDel da funcao PLAXCAD...                           ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If nOpcx == K_Excluir .And. ValType(bDelLine) == "B"
                lExc := Eval(bDelLine)
             Endif                  
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Somente atualizo se for alteracao, inclusao e no exclusao testo cDel³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If ! (nOpcx == K_Excluir .And. ! lExc)
                DbSelectArea(cAlias)
                DbGoTo(nReg)
             
                PLUPTENC(cAlias,nOpcx)
             Endif
             
             // inicio  - EDUARDO MOTTA - 26/09/2001
             // code block que sera executado apos a manutencao nos dados, passo como parametro a opcao
             If ValType(bAfter) == "B"
                Eval(bAfter,nOpcx)
             EndIf
             // fim
             
             If nOpc == K_Incluir
                ConfirmSX8()
             Endif   
      Endif    
Else
   If nOpc == K_Incluir
      RollBackSX8()
   Endif   
   FreeUsedCodes()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal de Movimentacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return nOpca  // mudado por EDUARDO MOTTA - verificar com o Tulio

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PlAtuRda ³ Autor ³ Daher		            ³ Data ³ 23.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao, Inclusao, Alteracao e Exclusao de PLAXCAD    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlAtuRda()
LOCAL lRet    := .T.
LOCAL nI	  := 1

If Type('oEncBD5') <> 'U' .and. Type('cOldRda') <> 'U'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Majoracao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If BD5->(FieldPos("BD5_TIPMAJ")) > 0
		DbSelectArea("BAU")
		If (Posicione("BAU",1,xFilial("BAU")+M->BD5_CODRDA,"BAU->BAU_TIPPRE") <> GetNewPar("MV_PLSTPIN","OPE"))
			M->BD5_TIPMAJ := IIF(BAU->BAU_TIPPE == "F","1",IIF(BAU->BAU_TIPPE=="J","2",""))
		Else
			M->BD5_TIPMAJ := ""
		Endif
	EndIf

	If cOldRda <> M->BD5_CODRDA       
		If Type('oBrwBD7') <> 'U'
			For nI:=1 to Len(oBrwBD7:aCols)
				If oBrwBD7:FieldGet("BD7_CODRDA",nI) == cOldRda
					oBrwBD7:FieldPut("BD7_CODRDA",M->BD5_CODRDA,nI)
					oBrwBD7:FieldPut("BD7_NOMRDA",BAU->(Posicione("BAU",1,xFilial("BAU")+M->BD5_CODRDA,"BAU_NOME")),nI)
				Endif
			Next
		Else             //guia de consulta
			If BCI->BCI_TIPGUI == '01' 
				BD6->(DbSetOrder(1))
	        	If BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
	           		While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
	                                       		xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
					    
					    BD6->(Reclock("BD6",.F.))
					    BD6->BD6_CODRDA = M->BD5_CODRDA
					    BD6->BD6_NOMRDA = BAU->(Posicione("BAU",1,xFilial("BAU")+M->BD5_CODRDA,"BAU_NOME"))
					    BD6->(Msunlock())
						
						BD7->(DbSetOrder(1))
	                    If BD7->(MsSeek(xFilial("BD7")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+BD6->BD6_SEQUEN))
	                       	While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
	                                                   xFilial("BD7")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+BD6->BD6_SEQUEN
	                        	BD7->(Reclock("BD7",.F.))
					    		BD7->BD7_CODRDA = M->BD5_CODRDA
					    		BD7->BD7_NOMRDA = BAU->(Posicione("BAU",1,xFilial("BAU")+M->BD5_CODRDA,"BAU_NOME"))
					    		BD7->(Msunlock())
						    	BD7->(DbSkip())
				    	   	Enddo
				  		Endif
						BD6->(DbSkip())
					Enddo
				Endif
			Endif
		Endif
	Endif
	cOldRda := M->BD5_CODRDA
ElseIf Type('oEncBE4') <> 'U' .and. Type('cOldRda') <> 'U'
	If cOldRda <> M->BE4_CODRDA
		If cOldRda <> M->BE4_CODRDA
			If Type('oBrwBD7') <> 'U'
				For nI:=1 to Len(oBrwBD7:aCols)
					If oBrwBD7:FieldGet("BD7_CODRDA",nI) == cOldRda
						oBrwBD7:FieldPut("BD7_CODRDA",M->BE4_CODRDA,nI)
						oBrwBD7:FieldPut("BD7_NOMRDA",BAU->(Posicione("BAU",1,xFilial("BAU")+M->BE4_CODRDA,"BAU_NOME")),nI)
					Endif
				Next
			Endif
		Endif
	Endif
	cOldRda := M->BE4_CODRDA
Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlRetDeCre ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Dado o codigo da RDA e a matricula do usuario 			  ³±± 
±±³			 ³ eu retorno o lancamento de debito credito correspondente	  ³±± 
±±³			 ³ Esta funcao deve ser executada para cada BD7!! 			  ³±±
±±³			 ³ cDebCre = 2 -> Credito 									  ³±±
±±³			 ³ cDebCre = 1 -> Debito                           			  ³±±
±±³			 ³ para usar esta funcao o BD6 deve estar posicionado 		  ³±±
±±³			 ³ para usar esta funcao o BD7 deve estar posicionado 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PlRetDeCre(cCodRda,cMatric,aLanPag,aLanCob,cDebCre)
LOCAL cAto 	  	 := ""
LOCAL cTipoVlr	 := ""
LOCAL aAux    	 := {}
LOCAL nPosCob    := 0
LOCAL nPosPag    := 0
LOCAL cTipPe	 := ""
LOCAL cCopCre	 := ""
LOCAL nRecBA1    := BA1->(Recno())
LOCAL nOrdBA1    := BA1->(IndexOrd())
LOCAL nRecBAU    := BAU->(Recno())
LOCAL nOrdBAU    := BAU->(IndexOrd())                              
LOCAL nRecBD6	 := BD6->(Recno())                              
LOCAL nOrdBD6    := BD6->(IndexOrd())                              
LOCAL nRecBD7    := BD7->(Recno())                                
LOCAL nOrdBD7    := BD7->(IndexOrd())                              
LOCAL bRest      := { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRecBA1)),;
						  BAU->(DbSetOrder(nOrdBAU)), BAU->(DbGoTo(nRecBAU)),;
						  BD6->(DbSetOrder(nOrdBD6)), BD6->(DbGoTo(nRecBD6)),;
						  BD7->(DbSetOrder(nOrdBD7)), BD7->(DbGoTo(nRecBD7)) }
LOCAL cTipCon    := ""         
LOCAL aRet		 := {{.F.,{},{}},; //[1] Parametros da cobranca - [1][1] achei ? - [1][2] - parametros achados [1][3] criticas
					 {.F.,{},{}}}   //[2] Parametros do pagamento - [1][1] achei ? - [1][2] - parametros achados [1][3] criticas

DEFAULT aLanPag := {}
DEFAULT aLanCob := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto os lancamentos de pagamento e suas propriedades				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLanPag) == 0
   MonLanPag(aLanPag)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto os lancamentos de pagamento e suas propriedades				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLanCob) == 0
   MonLanCob(aLanCob)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciono na RDA em questão											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCodRDA <> BAU->BAU_CODIGO
	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU")+cCodRDA))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciono no usuario em questão										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMatric <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+cMatric))                                           
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este trecho aqui esta certo, ou seja, o valor do cTipoVlr eh 		³
//| diferente do BD6_TPPF												|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BD6->BD6_TPPF == "1" //co-Participacao
	cTipoVlr := '2'//co-participacao
Else
	cTipoVlr := '1'//custo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco o tipo do ato													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BAU->BAU_COPCRE == "1" //Cooperado, e um servico medico...
	cAto := "1"
Else //Nao e cooperado, e um servico acessorio...
	cAto := "0"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se tiver o ponto de entrada eu pego o ato informado nele			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
If  Existblock("PLTIPATO")
	aAux := Execblock("PLTIPATO",.F.,.F.,{cAto, BD6->BD6_CODPAD, BD6->BD6_CODPRO,{0,0,0,0,0,0,0,0,0,0,0,0},0,0, BD6->BD6_DATPRO, cTipoVlr})
	cAto := aAux[1] 	        
Endif                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco outros parametros												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipPe	 := BAU->BAU_TIPPE     //tipo de prestador - PF,PJ
cTipCon  := BD6->BD6_TIPUSR    //tipo contrato - PF,PJ    
cCopCre	 := BAU->BAU_COPCRE    //tipo de prestador - cooperado,credenciado...
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco os parametros de cobranca										³     
//| Para mim, o vazio significa ambos									|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosCob := Ascan(aLanCob,{|x| x[7] == cAto .And. x[21] == cTipPe .And. x[22] == cCopCre .and. cDebCre == x[4]})
If nPosCob == 0
	nPosCob := Ascan(aLanCob,{|x| x[7] == cAto .And. x[21] == 'A' .And. x[22] == cCopCre .and. cDebCre == x[4]})
	If nPosCob == 0
		nPosCob := Ascan(aLanCob,{|x| x[7] == cAto .And. Empty(x[21]) .And. x[22] == cCopCre .and. cDebCre == x[4]})
		If nPosCob == 0
			nPosCob := Ascan(aLanCob,{|x| x[7] == cAto .And. x[21] == cTipPe .And. Empty(x[22])  .and. cDebCre == x[4]})
			If nPosCob == 0
				nPosCob := Ascan(aLanCob,{|x| x[7] == cAto .And. Empty(x[21]) .And. Empty(x[22]) .and. cDebCre == x[4]})
			Endif            
		Endif            
	Endif                
Endif                

If nPosCob > 0
	aRet[1] := {.T.,aLanCob[nPosCob],{}}
Else
	PLSPOSGLO(PLSINTPAD(),__aCdCri115[1],__aCdCri115[2],'','','','') 
 	AaDd(aRet[1][3],{__aCdCri115[1],PLSBCTDESC(),'','','',''})
  	AaDd(aRet[1][3],{""  			,STR0002,STR0003+X3COMBO("BFQ_ATOCOO",cAto),STR0004+X3COMBO("BSQ_TIPO",cDebCre),STR0005+X3COMBO("BAU_TIPPE",cTipPe),STR0006+X3COMBO("BAU_COPCRE",cCopCre)})   //"Registro nao localizado na tabela de debitos/creditos para cobranca [BSP]."###"Tipo Servico - "###"Tipo - "###"Tipo RDA - "###"Tipo Prestador - "
	AaDd(aRet[1][3],{""  			,STR0007,BD7->(BD7_CODOPE+'.'+BD7_CODLDP+'.'+BD7_CODPEG+'.'+BD7_NUMERO+'.'+BD7_ORIMOV+'.'+BD7_SEQUEN+'.'+BD7_CODUNM),'','',''})   //"Chave do subitem [BD7] referente ao lançamento nao localizado."
Endif    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco os parametros de pagamento									³ 
//| Para mim, o vazio significa ambos									|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosPag := Ascan(aLanPag,{|x| x[6] == cTipCon .And. x[18] == cTipPe .And. x[19] == cCopCre .and. cDebCre == x[5]})
If nPosPag == 0
	nPosPag := Ascan(aLanPag,{|x| x[6] == cTipCon .And. x[18] == 'A' .And. x[19] == cCopCre .and. cDebCre == x[5]})
	If nPosPag == 0
		nPosPag := Ascan(aLanPag,{|x| x[6] == cTipCon .And. Empty(x[18]) .And. x[19] == cCopCre .and. cDebCre == x[5]})
		If nPosPag == 0
			nPosPag := Ascan(aLanPag,{|x| x[6] == cTipCon .And. x[18] == cTipPe .And. Empty(x[19]) .and. cDebCre == x[5]})				
			If nPosPag == 0
				nPosPag := Ascan(aLanPag,{|x| x[6] == cTipCon .And. Empty(x[18]) .And. Empty(x[19]) .and. cDebCre == x[5]})
			Endif
		Endif
	Endif
Endif

If nPosPag > 0
	aRet[2] := {.T.,aLanPag[nPosPag],{}}
Else
	PLSPOSGLO(PLSINTPAD(),__aCdCri115[1],__aCdCri115[2],'','','','') 
 	aadd(aRet[2][3],{__aCdCri115[1],PLSBCTDESC(),'','','',''})
  	aadd(aRet[2][3],{""  			,STR0008,STR0009+X3COMBO("BD6_TIPUSR",cTipCon),STR0004+X3COMBO("BGQ_TIPO",cDebCre),STR0005+X3COMBO("BAU_TIPPE",cTipPe),STR0006+X3COMBO("BAU_COPCRE",cCopCre)})   //"Registro nao localizado na tabela de debitos/creditos para RDA [BBB]."###"Tipo Contrato - "###"Tipo - "###"Tipo RDA - "###"Tipo Prestador - "
  	aadd(aRet[2][3],{""  			,STR0007,BD7->(BD7_CODOPE+'.'+BD7_CODLDP+'.'+BD7_CODPEG+'.'+BD7_NUMERO+'.'+BD7_ORIMOV+'.'+BD7_SEQUEN+'.'+BD7_CODUNM),'','',''})   //"Chave do subitem [BD7] referente ao lançamento nao localizado."
Endif    

Eval(bRest)

Return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MonLanCob  ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

Static Function MonLanCob(aLanCob)

BSP->(DbSetOrder(1))
BSP->(MsSeek(xFilial("BSP")))
While !BSP->(Eof()) .and. xFilial("BSP") == BSP->BSP_FILIAL

	aadd(aLanCob,{	BSP->BSP_CODSER,;//[1]
					BSP->BSP_DESCRI,;//[2]
					BSP->BSP_VLRSER,;//[3]
					BSP->BSP_TIPSER,;//[4]
					BSP->BSP_CODLAN,;//[5]
					BSP->BSP_COMISS,;//[6]
					BSP->BSP_ATOCOO,;//[7]
					BSP->BSP_INCIR ,;//[8]
					BSP->BSP_REGCIR,;//[9]
					BSP->BSP_INCISS,;//[10]
					BSP->BSP_REGCIS,;//[11]
					BSP->BSP_INCCON,;//[12]
					BSP->BSP_REGCCO,;//[13]
					BSP->BSP_INCPIS,;//[14]
					BSP->BSP_REGCPI,;//[15]
					BSP->BSP_INCCSL,;//[16]
					BSP->BSP_REGCCS,;//[17]
					BSP->BSP_INCINS,;//[18]
					BSP->BSP_REGCIN,;//[19]
					BSP->BSP_REGCI1,;//[20]
					BSP->BSP_TIPPE,;//[21]
					BSP->BSP_COPCRE})//[22]
									
	BSP->(DbSkip())
Enddo

Return                           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MonLanPag  ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function MonLanPag(aLanPag)

BBB->(DbSetOrder(1))
BBB->(MsSeek(xFilial("BBB")))
While !BBB->(Eof()) .and. xFilial("BBB") == BBB->BBB_FILIAL

	aadd(aLanPag,{	BBB->BBB_CODSER,;//[1]
					BBB->BBB_DESCRI,;//[2]
					BBB->BBB_VLRSER,;//[3]
					BBB->BBB_QTDCH ,;//[4]
					BBB->BBB_TIPSER,;//[5]
					BBB->BBB_TIPOCT,;//[6]
					BBB->BBB_INCIR ,;//[7]
					BBB->BBB_INCINS,;//[8]
					BBB->BBB_INCPIS,;//[9]
					BBB->BBB_INCCOF,;//[10]
					BBB->BBB_INCCSL,;//[11]
					BBB->BBB_VERBA ,;//[12]
					BBB->BBB_CODANT,;//[13]
					BBB->BBB_CONTA ,;//[14]
					BBB->BBB_HISTC ,;//[15]
					BBB->BBB_CONMFT,;//[16]
					BBB->BBB_DIRF,; //[17]
					BBB->BBB_TIPPE,;//[18]
					BBB->BBB_COPCRE,;//[19]
					IIF(BBB->(FieldPos("BBB_INCISS")) > 0,BBB->BBB_INCISS," ") })//[20]
					
	BBB->(DbSkip())
Enddo

Return          


                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlReChvEst ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PlReChvEst(cAlias,lUsuario,lRDA,lMovto,lFatur,lIndRegua,lWhile)
LOCAL aRet 	 	 := {"",.F.}
DEFAULT lUsuario := .F.
DEFAULT lRDA	 := .F.                  
DEFAULT lMovto	 := .F.
DEFAULT lFatur	 := .F.                                
DEFAULT lIndRegua:= .F.
DEFAULT lWhile   := .F.
                 
If &(cAlias+"->(FieldPos('"+cAlias+"_CONCOB'))") > 0 .and. &(cAlias+"->(FieldPos('"+cAlias+"_CONPAG'))") > 0 .and. ;
   &(cAlias+"->(FieldPos('"+cAlias+"_CONMUS'))") > 0 .and. &(cAlias+"->(FieldPos('"+cAlias+"_CONMRD'))") > 0 
	
		If lUsuario    
			If lMovto
				aRet[1] += " ( "+cAlias+"_CONMUS = '1' OR "+cAlias+"_CONMUS = ' ' ) AND "
				If lWhile
					If &(cAlias+"->"+cAlias+"_CONMUS") == '0'  
						aRet[2] := .T. //indica que tem que desconsiderar a guia
					Endif
				Endif
			Endif
			If lFatur
				aRet[1] += " ( "+cAlias+"_CONCOB = '1' OR "+cAlias+"_CONCOB = ' ' ) AND "
				If lWhile
					If &(cAlias+"->"+cAlias+"_CONCOB") == '0'  
						aRet[2] := .T.//indica que tem que desconsiderar a guia
					Endif
				Endif
			Endif
		Endif
		If lRDA
			If lMovto
				aRet[1] += " ( "+cAlias+"_CONMRD = '1' OR "+cAlias+"_CONMRD = ' ' ) AND "
				If lWhile
					If &(cAlias+"->"+cAlias+"_CONMRD") == '0'  
						aRet[2] := .T.//indica que tem que desconsiderar a guia
					Endif
				Endif
			Endif
			If lFatur
				aRet[1] += " ( "+cAlias+"_CONPAG = '1' OR "+cAlias+"_CONPAG = ' ' ) AND "
				If lWhile
					If &(cAlias+"->"+cAlias+"_CONPAG") == '0'  
						aRet[2] := .T.//indica que tem que desconsiderar a guia
					Endif
				Endif
			Endif
		Endif
	
	If lIndRegua
		aRet[1] := strtran(aRet[1],"OR",".OR.")
		aRet[1] := strtran(aRet[1],"AND",".AND.")
	Endif
		
Endif

If ExistBlock("PLRECEST")
	aRet := Execblock("PLRECEST",.F.,.F.,{cAlias,lUsuario,lRDA,lMovto,lFatur,lIndRegua,lWhile,aRet})
Endif     

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlValRDA   ³ Autor ³ Daher		        | Data ³ 08.08.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PlValRDA(cAlias)

LOCAL cCodRDA := &("M->"+cAlias+"_RDACON")
LOCAL cCdPfSo := PLSSolCon()
LOCAL lRet	  := .T.

BAU->(DbSetOrder(1))
BC1->(DbSetOrder(4))
If !Empty(cCodRDA)
	BAU->(MsSeek(xFilial()+cCodRDA))
	IF BAU->BAU_TIPPE == 'F'	//	Pessoa Fisica
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ele nao eh corpo clinico de alguma RDA					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cCdPfSo) .and. SXB->(MsSeek("B1HPLS201")) .and. 'PLSSolCon' $ SXB->XB_CONTEM .and. !BC1->(MsSeek(xFilial()+cCodRDA+cCdPfSo))
			lRet := .F.
		Endif
	ENDIF
	If lRet
		If !BAU->(EOF())
			&("M->"+cAlias+"_DRDACO") := BAU->BAU_NOME
		Else
			lRet := ExistCpo("BAU",cCodRDA,1)
			&("M->"+cAlias+"_DRDACO") := ""
		Endif
	Endif
Else
	&("M->"+cAlias+"_DRDACO") := ""
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSSolCon  ³ Autor ³ Daher		        | Data ³ 08.08.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSSolCon()

LOCAL cCdPfSo := ""

If type("M->BE1_CDPFSO") <> "U"
	cCdPfSo := M->BE1_CDPFSO
Endif
If type("M->BE4_CDPFSO") <> "U"
	cCdPfSo := M->BE4_CDPFSO
Endif
If type("M->BEA_CDPFSO") <> "U"
	cCdPfSo := M->BEA_CDPFSO
Endif
If type("M->BD5_CDPFSO") <> "U"
	cCdPfSo := M->BD5_CDPFSO
Endif

Return cCdPfSo
