#INCLUDE "EDCIN100.CH"
#include "AVERAGE.CH"  
#INCLUDE "FILEIO.CH"
   
#DEFINE say_tit 1           
#DEFINE say_det 2
#DEFINE say_rep 3
#define GENERICO     "06"
#define NCM_GENERICA "99999999"

/*
Funcao    ³ EDCIN100
Autor     ³ VICTOR IOTTI
Data      ³ 17.01.02                                    
Descricao ³ Importacao de Arquivos
Sintaxe   ³ IN100()
Uso       ³ SIGAEDC
*/

*-----------------------*
FUNCTION EDCIN100Param()
*-----------------------*
PRIVATE oDlg5, oGet, nVolta, cAlias:=ALIAS(),N_TAMTELAP := 300
PRIVATE TULT_EP, TULT_CI, TULT_UC, TULT_IT, TULT_NB
PRIVATE TARQ_EP, TARQ_CI, TARQ_UC, TARQ_IT, TARQ_NB, TARQ_ID
PRIVATE nEDCLinha:=8,nEDCPula:=14,nEDCBotao:=185

TULT_EP :=Int_Param->NPAULT_EP
TULT_CI :=Int_Param->NPAULT_CI
TULT_UC :=Int_Param->NPAULT_UC
TULT_IT :=Int_Param->NPAULT_IT
TULT_NB :=Int_Param->NPAULT_NB
TULT_CE :=Int_Param->NPAULT_CE

TARQ_EP :=Int_Param->NPAARQ_EP
TARQ_CI :=Int_Param->NPAARQ_CI
TARQ_UC :=Int_Param->NPAARQ_UC
TARQ_IT :=Int_Param->NPAARQ_IT
TARQ_NB :=Int_Param->NPAARQ_NB
TARQ_ID :=Int_Param->NPAARQ_ID
TARQ_CE :=Int_Param->NPAARQ_CE

//*** GFP 26/08/2011 - Integração Forn/Fabr
TULT_FF :=Int_Param->NPAULT_FF
TARQ_FF :=Int_Param->NPAARQ_FF

IF lTemED9Cpos//AWR - 07/04/2009
   TULT_NR :=Int_Param->NPAULT_NR
   TARQ_NR :=Int_Param->NPAARQ_NR
   N_TAMTELAP+=30
   nEDCBotao:=200 //185
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMEDC")
EndIf

DEFINE MSDIALOG oDlg5 FROM  40,   0 TO N_TAMTELAP,515 TITLE STR0001 PIXEL OF oMainWnd // Parâmetros da Integração

@ nEDCLinha, 080 SAY STR0002      SIZE 66,  7 OF oDlg5 PIXEL // Ultimo Processamento
@ nEDCLinha, 151 SAY STR0003      SIZE 84,  7 OF oDlg5 PIXEL // Arquivos de Entrada (.TXT)
nEDCLinha+=16

@ nEDCLinha, 006 SAY STR0005             SIZE 74,  7 OF oDlg5 PIXEL // Itens da Importacao
@ nEDCLinha, 096 MSGET oGet VAR TULT_CI  SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_CI  SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula

@ nEDCLinha, 006 SAY STR0006             SIZE 74,  7 OF oDlg5 PIXEL // NCMs
@ nEDCLinha, 096 MSGET oGet VAR TULT_NB  SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_NB  SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula

@ nEDCLinha, 006 SAY STR0007             SIZE 74,  7 OF oDlg5 PIXEL // Estrutura de Produtos
@ nEDCLinha, 096 MSGET oGet VAR TULT_EP  SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_EP  SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula

@ nEDCLinha, 006 SAY STR0008             SIZE 74,  7 OF oDlg5 PIXEL // Conversão de Unid. Med.
@ nEDCLinha, 096 MSGET oGet VAR TULT_UC  SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_UC  SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula

@ nEDCLinha, 006 SAY STR0073             SIZE 74,  7 OF oDlg5 PIXEL // Solidário/Intermediário
@ nEDCLinha, 096 MSGET oGet VAR TULT_CE  SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_CE  SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula

//*** GFP 26/08/2011 - Integração Fabr/Forn
@ nEDCLinha, 006 SAY STR0154 SIZE 74,  7 OF oDlg5 PIXEL // Fabricantes/Fornecedores
@ nEDCLinha, 096 MSGET oGet VAR TULT_FF         SIZE 32, 10 OF oDlg5 PIXEL
@ nEDCLinha, 151 MSGET oGet VAR TARQ_FF         SIZE 47, 10 OF oDlg5 PIXEL
nEDCLinha+=nEDCPula


IF lTemED9Cpos//AWR - 07/04/2009
   @ nEDCLinha, 006 SAY STR0155       SIZE 74,  7 OF oDlg5 PIXEL //"RE Externos"
   @ nEDCLinha, 096 MSGET oGet VAR TULT_NR  SIZE 32, 10 OF oDlg5 PIXEL
   @ nEDCLinha, 151 MSGET oGet VAR TARQ_NR  SIZE 47, 10 OF oDlg5 PIXEL
   nEDCLinha+=nEDCPula
ENDIF

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMGETEDC")
EndIf

DEFINE SBUTTON FROM N_TAMTELAP-nEDCBotao,090 TYPE 1 ACTION (nVolta:=1,oDlg5:End()) ENABLE OF oDlg5
DEFINE SBUTTON FROM N_TAMTELAP-nEDCBotao,140 TYPE 2 ACTION (oDlg5:End())           ENABLE OF oDlg5

oGet:bGotFocus = { || oGet:SetPos( 0 ), nil }
nVolta = 0

ACTIVATE MSDIALOG oDlg5 CENTERED

IF nVolta = 1
   Reclock("Int_Param",.F.)
   DBSELECTAREA(cAlias)
   Int_Param->NPAULT_EP := TULT_EP 
   Int_Param->NPAULT_CI := TULT_CI 
   Int_Param->NPAULT_UC := TULT_UC 
   Int_Param->NPAULT_IT := TULT_IT 
   Int_Param->NPAULT_NB := TULT_NB 
   Int_Param->NPAULT_CE := TULT_CE 
   Int_Param->NPAARQ_EP := TARQ_EP 
   Int_Param->NPAARQ_CI := TARQ_CI 
   Int_Param->NPAARQ_UC := TARQ_UC 
   Int_Param->NPAARQ_IT := TARQ_IT 
   Int_Param->NPAARQ_NB := TARQ_NB 
   Int_Param->NPAARQ_ID := TARQ_ID 
   Int_Param->NPAARQ_CE := TARQ_CE 
   
   //*** GFP 26/08/2011 - Integração Fabr/Forn
   Int_Param->NPAULT_FF := TULT_FF
   Int_Param->NPAARQ_FF := TARQ_FF

   IF lTemED9Cpos//AWR - 07/04/2009
      Int_Param->NPAULT_NR:=TULT_NR
      Int_Param->NPAARQ_NR:=TARQ_NR
   ENDIF

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"PARAMGRAVAEDC")
   EndIf   
   DBCOMMIT()
ENDIF

RETURN .T.

*----------------------*
FUNCTION IN100ESTPROD()
*----------------------*

Local nIndex := 0

AADD(TB_Cols,{{||NEPPROD}                  ,"",STR0009 }) //Produto
AADD(TB_Cols,{{||NEPUMP}                   ,"",STR0010 }) //Unidade de Medida do Produto
AADD(TB_Cols,{{||NEPQTDBASE}               ,"",STR0011 }) //Qtd Base
AADD(TB_Cols,{{||NEPSEQ}                   ,"",STR0013 }) //Sequencia
AADD(TB_Cols,{{||NEPITEM}                  ,"",STR0012 }) //Item/Componente
AADD(TB_Cols,{{||NEPQTDITEM}               ,"",STR0014 }) //Qtd Componente
AADD(TB_Cols,{{||NEPUMITEM}                ,"",STR0026 }) //UM do Componente
AADD(TB_Cols,{{||NEPPERDA}                 ,"",STR0015 }) //"% Perda

//** AAF 02/06/05 - Valor comercial a Perda
If SG1->( FieldPos("G1_VLCOMPE") ) > 0 .AND. aScan(aEstruDef,{|X| X[1] == "NEPVLCOMPE"}) > 0
   AADD(TB_Cols,{{||If(NEPVLCOMPE<>"1","Não","Sim")}            ,"","Valor Comercial a Perda"})
Endif
//**

AADD(TB_Cols,{{||IN100CTD(NEPDTINIVA)}     ,"",STR0016 }) //DT Inicial de Validade
AADD(TB_Cols,{{||IN100CTD(NEPDTFIMVA)}     ,"",STR0017 }) //DT Final de Validade
AADD(TB_Cols,{{||NEPOBS}                   ,"",STR0018 }) //Obs

ASIZE(TBRCols,0)
AADD(TBRCols,{{||IN100Status()}            , STR0019 }) //Status
AADD(TBRCols,{{||IN100TIPO() }             , STR0020 }) //Tipo
AADD(TBRCols,{{||IN100CTD(EVAL(bDtInteg))} , STR0021 }) //Dt Integ
AADD(TBRCols,{{||NEPPROD}                  , STR0009 }) //Produto
AADD(TBRCols,{{||NEPUMP}                   , STR0010 }) //Unidade de Medida do Produto
AADD(TBRCols,{{||NEPQTDBASE}               , STR0011 }) //Qtd Base
AADD(TBRCols,{{||NEPSEQ}                   , STR0013 }) //Sequencia
AADD(TBRCols,{{||NEPITEM}                  , STR0012 }) //Item/Componente
AADD(TBRCols,{{||NEPQTDITEM}               , STR0014 }) //Qtd Componente
AADD(TBRCols,{{||NEPPERDA}                 , STR0015 }) //% Perda

//** AAF 02/06/05 - Valor comercial a Perda
If SG1->( FieldPos("G1_VLCOMPE") ) > 0 .AND. aScan(aEstruDef,{|X| X[1] == "NEPVLCOMPE"}) > 0
   AADD(TBRCols,{{||If(NEPVLCOMPE<>"1","Não","Sim")},"Valor Comercial a Perda"})
Endif
//**

AADD(TBRCols,{{||NEPUMITEM}                , STR0026 }) //UM do Componente
AADD(TBRCols,{{||IN100CTD(NEPDTINIVA)}     , STR0016 }) //DT Inicial de Validade
AADD(TBRCols,{{||IN100CTD(NEPDTFIMVA)}     , STR0017 }) //DT Final de Validade
AADD(TBRCols,{{||NEPOBS}                   , STR0018 }) //Obs

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLEP")
ENDIF
AADD(TBRCols,{{||IN100E_MSG(.T.)}          ,STR0022      }) //Mensagem
AADD(TB_Cols,{{||IN100E_Msg(.T.)}          ,"",STR0022   }) //Mensagem

//ER - 01/11/2007
dbSelectArea("SAH")
cIndexSAH:=CriaTrab(,.f.)
//ASK 08/11/07
IndRegua("SAH",cIndexSAH,"AH_FILIAL+AH_COD_SIS")
nIndex:=RetIndex("SAH")

#IFNDEF TOP
   dbSetIndex(cIndexSAH+TEOrdBagExt())
#ENDIF
dbSetorder(1)

ED8->(dbsetorder(1))
SGA->(DBSETORDER(1))
SG1->(DBSETORDER(1))
RETURN .T.

*--------------------*
FUNCTION IN100LerEP()
*--------------------*
LOCAL lDtIni := .F., lDtFim := .F., nRecno, cProdExp

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LEREP")
ENDIF     

IF Len(Int_EP->NEPPROD) > Len((cAliasSB1)->B1_COD)
   cProdExp := Left(Int_EP->NEPPROD,Len((cAliasSB1)->B1_COD))
Else
   cProdExp := Int_EP->NEPPROD+Space(Len((cAliasSB1)->B1_COD)-Len(Int_EP->NEPPROD))
Endif

If EMPTY(Int_EP->NEPPROD)
   EVAL(bmsg,STR0009+STR0027)  // PRODUTO NAO INFORMADO
ElseIf ! (cAliasSB1)->(DBSEEK(cFilSB1Aux+cProdExp)) .And. ;
!SB1->(DBSEEK(cFilSB1+AVKEY(Int_EP->NEPPROD,"B1_COD")))
   EVAL(bmsg,STR0009+STR0030)  // PRODUTO SEM CADASTRO
Else
   If EMPTY(Int_EP->NEPUMP)
      EVAL(bmsg,STR0010+STR0027)  // UM Produto NAO INFORMADO
   ElseIf ! SAH->(DBSEEK(cFilSAH+AVKEY(Int_EP->NEPUMP,"AH_UNIMED")))
      EVAL(bmsg,STR0010+STR0030)  // UM Produto SEM CADASTRO
   ElseIf If((cAliasSB1)->(!EOF()), Alltrim(Int_EP->NEPUMP) # Alltrim((cAliasSB1)->B1_UM), Alltrim(Int_EP->NEPUMP) # Alltrim(SB1->B1_UM))
      EVAL(bmsg,STR0010+STR0036)  // UM Produto difere do cadastro
   ENDIF
ENDIF

IF Len(Int_EP->NEPITEM) > Len((cAliasSB1)->B1_COD)
   cProdExp := Left(Int_EP->NEPITEM,Len((cAliasSB1)->B1_COD))
Else
   cProdExp := Int_EP->NEPITEM+Space(Len((cAliasSB1)->B1_COD)-Len(Int_EP->NEPITEM))
Endif

If EMPTY(Int_EP->NEPITEM)
   EVAL(bmsg,STR0012+STR0027)  // ITEM NAO INFORMADO
ElseIf ! (cAliasSB1)->(DBSEEK(cFilSB1Aux+cProdExp)) .And. ;
! SB1->(DBSEEK(cFilSB1+AVKEY(Int_EP->NEPITEM,"B1_COD")))
   EVAL(bmsg,STR0012+STR0030)  // ITEM SEM CADASTRO
Else
   If EMPTY(Int_EP->NEPUMITEM)
      EVAL(bmsg,STR0026+STR0027)  // UM Componente NAO INFORMADO
   ElseIf ! SAH->(DBSEEK(cFilSAH+AVKEY(Int_EP->NEPUMITEM,"AH_UNIMED")))
      EVAL(bmsg,STR0026+STR0030)  // UM Componente SEM CADASTRO
   ElseIf If((cAliasSB1)->(!EOF()), Alltrim(Int_EP->NEPUMITEM) # Alltrim((cAliasSB1)->B1_UM), Alltrim(Int_EP->NEPUMITEM) # Alltrim(SB1->B1_UM))
      EVAL(bmsg,STR0026+STR0036)  // UM Componente difere do cadastro
   ENDIF
ENDIF

IF ! SG1->(DBSEEK(cFilSG1+AVKEY(Int_EP->NEPPROD,"G1_COD")+AVKEY(Int_EP->NEPITEM,"G1_COMP")+AVKEY(Int_EP->NEPSEQ,"G1_TRT"))) .and.;
Int_EP->NEPTIPO = EXCLUSAO
   EVAL(bmsg,STR0007+STR0030)  // Estrutura de Produtos sem cadastro
ENDIF

// Verifica e nao deixa permitir se um produto PAI sera cadastrado como componente de seu FILHO
If Int_EP->NEPTIPO = INCLUSAO .or. Int_EP->NEPTIPO = ALTERACAO
   nRecno := SG1->(Recno())
   IF SG1->(DBSEEK(cFilSG1+AVKEY(Int_EP->NEPITEM,"G1_COMP")+AVKEY(Int_EP->NEPPROD,"G1_COD")+AVKEY(Int_EP->NEPSEQ,"G1_TRT")))
      EVAL(bmsg,STR0007+STR0047)  // Um produto 'PAI' nao pode ser componente de seu 'FILHO'
   Endif
   SG1->(DbGoto(nRecno))
Endif

IF Int_EP->NEPTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALEP")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_EP->NEPINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN
ENDIF                

If EMPTY(Int_EP->NEPQTDBASE)
   EVAL(bmsg,STR0037+STR0027)  // Qtd Base NAO INFORMADO
ElseIf Val(Int_EP->NEPQTDBASE) < 0
   EVAL(bmsg,STR0037+STR0039)  // Qtd Base negativa
ElseIf IN100NaoNum(Int_EP->NEPQTDBASE)
   EVAL(bmsg,STR0037+STR0034)  // Qtd Base Invalido
ENDIF

If EMPTY(Int_EP->NEPQTDITEM)
   EVAL(bmsg,STR0046+STR0027)  // Qtd Item/Componente NAO INFORMADO
ElseIf Val(Int_EP->NEPQTDITEM) < 0
   EVAL(bmsg,STR0046+STR0039)  // Item/Componente negativa
ElseIf IN100NaoNum(Int_EP->NEPQTDITEM)
   EVAL(bmsg,STR0046+STR0034)  // Item/Componente Invalido
ENDIF

If !Empty(Int_EP->NEPPERDA)
   If Val(Int_EP->NEPPERDA) < 0
      EVAL(bmsg,STR0038+STR0039)  // % Perda negativa
   ENDIF
EndIf

If EMPTY(Int_EP->NEPDTINIVA)
   EVAL(bmsg,STR0040+STR0027)  // Dt Ini. Validade NAO INFORMADO
ElseIf ! IN100CTD(Int_EP->NEPDTINIVA,.T.)
   EVAL(bmsg,STR0040+STR0034)  // Dt Ini. Validade INVALIDA
Else
   lDtIni := .T.
ENDIF

If EMPTY(Int_EP->NEPDTFIMVA)
   EVAL(bmsg,STR0041+STR0027)  // Dt Final Validade NAO INFORMADO
ElseIf ! IN100CTD(Int_EP->NEPDTFIMVA,.T.)
   EVAL(bmsg,STR0041+STR0034)  // Dt Final Validade INVALIDA
Else
   lDtFim := .T.
ENDIF

If lDtIni .and. lDtFim .and. IN100CTD(Int_EP->NEPDTFIMVA) < IN100CTD(Int_EP->NEPDTINIVA)
   EVAL(bmsg,STR0045)  // Dt Final maior que Dt Inicial de Validade
EndIf

Int_EP->NEPTIPOQTD := Upper(Int_EP->NEPTIPOQTD)
If Int_EP->NEPTIPO = INCLUSAO .AND. EMPTY(Int_EP->NEPTIPOQTD) 
   EVAL(bmsg,STR0042+STR0027)  // Tipo da quantidade NAO INFORMADO
ElseIf ! Int_EP->NEPTIPOQTD $ "FV"
   EVAL(bmsg,STR0042+STR0034)  // Tipo da quantidade NAO INFORMADO
EndIf

If ! EMPTY(Int_EP->NEPGRUPO) .AND. ! SGA->(DBSEEK(cFilSGA+AVKEY(Int_EP->NEPGRUPO,"GA_GROPC")))
   EVAL(bmsg,STR0043+STR0030)  // Grupo de opcionais sem cadastro
EndIf

If ! EMPTY(Int_EP->NEPGRUPO) .AND. ! EMPTY(Int_EP->NEPOPCACAB) .AND. ! SGA->(DBSEEK(cFilSGA+AVKEY(Int_EP->NEPGRUPO,"GA_GROPC")+AVKEY(Int_EP->NEPGRUPO,"GA_OPC")))
   EVAL(bmsg,STR0044+STR0030)  // Opcional de acabamento sem cadastro
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALEP")
ENDIF

IN100VerErro(cErro,cAviso)
IF Int_EP->NEPINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
Return .T.

*--------------------*
FUNCTION IN100GrvEP()
*--------------------*
Local cProdExp, lFind := .F.

lFind := SG1->(DBSEEK(cFilSG1+AVKEY(Int_EP->NEPPROD,"G1_COD")))
cAlias:=ALIAS()

DBSELECTAREA(cAlias)
IF Int_EP->NEPTIPO = EXCLUSAO .AND. lFind
   SG1->(RecLock("SG1",.F.))
   SG1->(DBDELETE())
   SG1->(DBCOMMIT())
   SG1->(MSUNLOCK())
   RETURN
ENDIF

IF Int_EP->NEPTIPO = INCLUSAO .or. Int_EP->NEPTIPO = ALTERACAO
   If lFind .and. aScan(aEstProd,Int_EP->NEPPROD) = 0
      SG1->(DBSEEK(cFilSG1+AVKEY(Int_EP->NEPPROD,"G1_COD")))
      Do While !SG1->(EOF()) .and. SG1->G1_COD=AVKEY(Int_EP->NEPPROD,"G1_COD")
         SG1->(RecLock("SG1",.F.))
         SG1->(DBDELETE())
         SG1->(DBCOMMIT())
         SG1->(MSUNLOCK())
         SG1->(dbSkip())
      EndDo
   EndIf
   If aScan(aEstProd,Int_EP->NEPPROD) = 0
      aAdd(aEstProd,Int_EP->NEPPROD)
   EndIf
   IN100RecLock('SG1')
   SG1->G1_FILIAL := cFilSG1
   SG1->G1_COD    := Int_EP->NEPPROD
   SG1->G1_COMP   := Int_EP->NEPITEM
   SG1->G1_TRT    := Int_EP->NEPSEQ
ENDIF

IF Len(Int_EP->NEPPROD) > Len((cAliasSB1)->B1_COD)
   cProdExp := Left(Int_EP->NEPPROD,Len((cAliasSB1)->B1_COD))
Else
   cProdExp := Int_EP->NEPPROD+Space(Len((cAliasSB1)->B1_COD)-Len(Int_EP->NEPPROD))
Endif

If VAL(Int_EP->NEPQTDBASE)#0 .and. ((cAliasSB1)->(DBSEEK(cFilSB1Aux+cProdExp)) .Or. ;
									SB1->(DBSEEK(cFilSB1+AVKEY(Int_EP->NEPPROD,"B1_COD"))))				
   cAlias:=ALIAS()
   DBSELECTAREA(cAlias)
   If (cAliasSB1)->(!Eof())
      Reclock(cAliasSB1,.F.)
      (cAliasSB1)->B1_QB := Val(Int_EP->NEPQTDBASE)
      (cAliasSB1)->(msUnlock())
   Else
      Reclock('SB1',.F.)
      SB1->B1_QB := Val(Int_EP->NEPQTDBASE)
      SB1->(MSUNLOCK())
   Endif   
EndIf

IF(VAL(Int_EP->NEPQTDITEM)#0          ,SG1->G1_QUANT      := Val(Int_EP->NEPQTDITEM),)
IF(VAL(Int_EP->NEPPERDA)  #0          ,SG1->G1_PERDA      := Val(Int_EP->NEPPERDA),)

//** AAF 02/06/05 - Valor comercial a Perda
If SG1->( FieldPos("G1_VLCOMPE") ) > 0
   If Int_EP->( FieldPos("NEPVLCOMPE") ) > 0
      SG1->G1_VLCOMPE := If(Int_EP->NEPVLCOMPE <> "1","N","S")
   Else
      SG1->G1_VLCOMPE := "N"
   Endif
Endif
//**

IF(!Empty(Int_EP->NEPOBS)             ,SG1->G1_OBSERV     := Int_EP->NEPOBS,)
IF(!Empty(Int_EP->NEPTIPOQTD)         ,SG1->G1_FIXVAR     := Int_EP->NEPTIPOQTD,)
IF(!Empty(Int_EP->NEPGRUPO)           ,SG1->G1_GROPC      := Int_EP->NEPGRUPO,)
IF(!Empty(Int_EP->NEPOPCACAB)         ,SG1->G1_OPC        := Int_EP->NEPOPCACAB,)
IF(!Empty(Int_EP->NEPREVINI)          ,SG1->G1_REVINI     := Int_EP->NEPREVINI,)
IF(!Empty(Int_EP->NEPREVFIM)          ,SG1->G1_REVFIM     := Int_EP->NEPREVFIM,)
IF(!EMPTY(ALLTRIM(Int_EP->NEPDTINIVA)),SG1->G1_INI        := IN100CTD(Int_EP->NEPDTINIVA),)
IF(!EMPTY(ALLTRIM(Int_EP->NEPDTFIMVA)),SG1->G1_FIM        := IN100CTD(Int_EP->NEPDTFIMVA),)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVEP")
EndIf

// DEVE SER GRAVADO A REVISAO

SG1->(MSUNLOCK())
Return .T. 

*** Integração Solidário / Intermediário
*----------------------*
FUNCTION IN100COMPEXT()
*----------------------*

Local nIndex := 0

AADD(TB_Cols,{{||If(Int_CE->NCETIPOIE=="I",STR0049,if(Int_CE->NCETIPOIE=="M",STR0050,STR0116))},"",STR0048 }) //Tipo do Registro # Importação # Compra Nacional
//AADD(TB_Cols,{"NCERE"                                      ,"",STR0051 }) //RE
AADD(TB_Cols,{"NCELINUM"                                     ,"",STR0052 }) //Número da PLI
//AADD(TB_Cols,{"NCEDTLI"                                   ,"",STR0080 }) //"Dt.Reg da LI"
AADD(TB_Cols,{{||IN100CTD(Int_CE->NCEDTLI)}               ,"",STR0080 }) //"Dt.Reg da LI"
AADD(TB_Cols,{"NCEDINUM"                                  ,"",STR0053 }) //Número da DI
//AADD(TB_Cols,{"NCEDTDI"                                   ,"",STR0081 }) //"Dt.Reg da DI"
AADD(TB_Cols,{{||IN100CTD(Int_CE->NCEDTDI)}            ,"",STR0081 }) //"Dt.Reg da DI"
AADD(TB_Cols,{"NCEAD"                                  ,"",STR0054 }) //Adição
AADD(TB_Cols,{"NCEAC"                                      ,"",STR0055 }) //Ato Concessório
AADD(TB_Cols,{"NCESEQS"                                      ,"",STR0082 }) //"Seq.AC"
//AOM - 08/12/2011
If AVFLAGS("SEQMI")
   AADD(TB_Cols,{"NCESEQMI"                                      ,"",AVSX3("ED8_SEQMI",5) }) //"Seq.MI"
EndIf

//AOM - 21/10/10
AADD(TB_Cols,{"NCEPED"                                      ,"",STR0138 }) //"Pedido"

AADD(TB_Cols,{"NCEPOSDI"                                     ,"",STR0083 }) //"Posicao"
AADD(TB_Cols,{"NCECODI"                                   ,"",STR0084 }) //"Cod Item"
AADD(TB_Cols,{"NCEDESC"                                    ,"",STR0057 }) //Descrição da Mercadoria
AADD(TB_Cols,{"NCEPESO"                                   ,"",STR0085 }) //"Peso[Kg]"
AADD(TB_Cols,{"NCEQTDN"                                   ,"",STR0086}) //"Qtd. U.M. NCM"
AADD(TB_Cols,{"NCEUMN"                                   ,"",STR0087}) //"U.M. NCM"
AADD(TB_Cols,{"NCEQTD"                                   ,"",STR0088})
AADD(TB_Cols,{"NCEUM"                                   ,"",STR0089}) //"U.M. Compra"
AADD(TB_Cols,{"NCENCM"                                   ,"",STR0090}) //"NCM"
AADD(TB_Cols,{"NCEVLEMB"                                   ,"",STR0091}) //"Valor FOB em US$"
AADD(TB_Cols,{"NCETXUSS"                                   ,"",STR0092}) //"Taxa da moeda na DI"
AADD(TB_Cols,{"NCEINV"                                   ,"",STR0093}) //"Invoice"
AADD(TB_Cols,{"NCEFR"                                   ,"",STR0094}) //"Valor do Frete"
AADD(TB_Cols,{"NCEMOEFR"                                   ,"",STR0095}) //"Moeda do Frete"
AADD(TB_Cols,{"NCETXFR"                                   ,"",STR0096}) //"Taxa do Frete"
AADD(TB_Cols,{"NCESE"                                   ,"",STR0097}) //"Valor do Seguro"
AADD(TB_Cols,{"NCEMOESE"                                   ,"",STR0098}) //"Moeda do Seguro"
AADD(TB_Cols,{"NCETXSE"                                   ,"",STR0099})
AADD(TB_Cols,{"NCESEUSS"                                   ,"",STR0100}) //"Valor do Seguro US$"
AADD(TB_Cols,{"NCENF"                                      ,"",STR0101}) //"NF. de Entrada"
AADD(TB_Cols,{"NCESERIE"                                      ,"",STR0102}) //"Nº.Serie"
AADD(TB_Cols,{"NCEEMISSA"                                      ,"",STR0103}) //"Data da NFE"
AADD(TB_Cols,{"NCEMOEDA"                                      ,"",STR0104}) //"Moeda"
AADD(TB_Cols,{"NCEVALORI"                                      ,"",STR0105}) //"Valor FOB na Moeda"
AADD(TB_Cols,{"NCETXMOE"                                      ,"",STR0106}) //"Taxa na Moeda"
AADD(TB_Cols,{"NCEMRD"                                      ,"",STR0135}) //"Desp.Marinha.Merc"
AADD(TB_Cols,{"NCEARMD"                                      ,"",STR0130}) //"Desp.com armazenagem"
AADD(TB_Cols,{"NCEINLAN"                                      ,"",STR0131}) //"Inland Charges"
AADD(TB_Cols,{"NCEOUTD"                                      ,"",STR0132}) //"Outras Despesas"
AADD(TB_Cols,{"NCEPACK"                                      ,"",STR0133}) //"Packing Charges"
AADD(TB_Cols,{"NCEDESCT"                                      ,"",STR0134}) //"Desconto"
//AOM - 21/10/10
AADD(TB_Cols,{"NCEFORN"                                      ,"",STR0139 }) //"Fornecedor"
AADD(TB_Cols,{"NCELOJA"                                      ,"",STR0140 }) //"Loja"
//*** GFP - 24/08/2011 - Campos Impostos
If ChkFile("ED8")
   If(ED8->(FieldPos("ED8_VLII"))   > 0, aAdd(TB_Cols,{"NCEVLII"   ,"",STR0156  }),) //"Valor I.I."
   If(ED8->(FieldPos("ED8_VLIPI"))  > 0, aAdd(TB_Cols,{"NCEVLIPI"  ,"",STR0157  }),) //"Valor IPI"
   If(ED8->(FieldPos("ED8_VLICMS")) > 0, aAdd(TB_Cols,{"NCEVLICMS" ,"",STR0158  }),) //"Valor ICMS"
   If(ED8->(FieldPos("ED8_VLRPIS")) > 0, aAdd(TB_Cols,{"NCEVLPIS"  ,"",STR0159  }),) //"Valor PIS"
   If(ED8->(FieldPos("ED8_VLRCOF")) > 0, aAdd(TB_Cols,{"NCEVLCOF"  ,"",STR0160  }),) //""Valor COFINS"  
EndIf 
//*** Fim GFP - 24/08/2011

ASIZE(TBRCols,0)
AADD(TBRCols,{{||IN100Status()}                    , STR0019 }) //Status
AADD(TBRCols,{{||IN100TIPO() }                     , STR0020 }) //Tipo
AADD(TBRCols,{{||IN100CTD(EVAL(bDtInteg))}         , STR0021 }) //Dt Integ
AADD(TBRCols,{{||If(Int_CE->NCETIPOIE=="I",STR0049,STR0050)} , STR0048 }) //Tipo do Registro # Importação # Exportação
//AADD(TBRCols,{"NCERE"                              , STR0051 }) //RE
AADD(TBRCols,{"NCELINUM"                             , STR0052 }) //Número da PLI
AADD(TBRCols,{"NCEDINUM"                          , STR0053 }) //Número da DI
AADD(TBRCols,{"NCEAD"                          , STR0054 }) //Adição
AADD(TBRCols,{"NCEAC"                              , STR0055 }) //Ato Concessório
AADD(TBRCols,{"NCEPOSDI"                             , STR0056 }) //Posição no A.C.
AADD(TBRCols,{"NCEDESC"                            , STR0057 }) //Descrição da Mercadoria

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLCE")
ENDIF

AADD(TBRCols,{{||IN100E_MSG(.T.)}          ,STR0022      }) //Mensagem
AADD(TB_Cols,{{||IN100E_Msg(.T.)}          ,"",STR0022   }) //Mensagem
SYT->(DBSETORDER(3))
SYD->(dbSetOrder(1))

//ER - 01/11/2007
dbSelectArea("SAH")
cIndexSAH:=CriaTrab(,.f.)
//ASK 08/11/07
IndRegua("SAH",cIndexSAH,"AH_FILIAL+AH_COD_SIS")

#IFNDEF TOP
   dbSetIndex(cIndexSAH+TEOrdBagExt())
#ENDIF
   dbSetorder(1)

SYF->(dbSetOrder(1))
ED4->(dbSetOrder(2))
ED3->(dbSetOrder(2))
SA2->(dbSetOrder(3))
ED0->(dbSetOrder(2))

RETURN .T.

*--------------------*
FUNCTION IN100LerCE()
*--------------------*

Local lMUserEDC := FindFunction("EDCMultiUser")
Local oMUserEDC

Private lPE_Val := .T.

If lMUserEDC
   oMUserEDC := EDCMultiUser():Novo()  // PLB 06/12/06
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERCE")
ENDIF
If Int_CE->NCETIPO <> EXCLUSAO
   If IN100NaoNum(Int_CE->NCEPESO)
      EVAL(bmsg,STR0107) //"Peso (Kg) unitário não informado"
   ElseIf Val(Int_CE->NCEPESO) = 0
      EVAL(bmsg,STR0107)   //"Peso (Kg) unitário não informado"
   ElseIf Val(Int_CE->NCEPESO) < 0
      EVAL(bmsg,STR0108) //"Peso (Kg) unitário negativo" 
   EndIf

   If Empty(INT_CE->NCENCM)
      EVAL(bmsg,STR0059+STR0027)  // NCM NAO INFORMADO
   ElseIf !SYD->(DBSEEK(cFilSYD+AVKEY(Int_CE->NCENCM,"YD_TEC")))
      EVAL(bmsg,STR0059+STR0030)  // NCM SEM CADASTRO
   EndIf

   If IN100NaoNum(Int_CE->NCEQTDN)
      EVAL(bmsg,STR0060+STR0034)  // Quantidade U.M. NCM Invalido
   ElseIf Val(Int_CE->NCEQTDN) = 0
      EVAL(bmsg,STR0060+STR0027)  // Quantidade U.M. NCM NAO INFORMADO
   ElseIf Val(Int_CE->NCEQTDN) < 0
      EVAL(bmsg,STR0060+STR0039)  // Quantidade U.M. NCM negativa
   EndIf

   If IN100NaoNum(Int_CE->NCEQTD)
      EVAL(bmsg,STR0110) //"Quantidade U.M. NCM de venda Invalido"
   ElseIf Val(Int_CE->NCEQTD) = 0
      EVAL(bmsg,STR0110)  //"Quantidade U.M. NCM de venda Invalido"
   ElseIf Val(Int_CE->NCEQTD) < 0
      EVAL(bmsg,STR0111) //"Quantidade U.M. NCM de venda negativa"
   EndIf


   If EMPTY(Int_CE->NCEPOSDI)
     EVAL(bmsg,STR0115)    //"Posição da DI não informada"
   ENDIF

   if empty(Int_CE->NCEUMN)
      EVAL(bmsg,STR0117)  //UM NCM VAZIA
   else
            
      //ER - 31/10/2007
      SAH->(DbSetOrder(1))
      If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUMN,"AH_UNIMED")))
         SAH->(dbSetOrder(0)) //Índice Temporário
         If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUMN,"AH_COD_SIS")))
            EVAL(bmsg,STR0061+STR0030)  // UM NCM SEM CADASTRO
         EndIf
      EndIf
      
   ENDIF
   
   if empty(Int_CE->NCEUM)
      EVAL(bmsg,STR0118)  // UM NCM de compra vazia
   else
          
      //ER - 31/10/2007
      SAH->(DbSetOrder(1))
      If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUM,"AH_UNIMED")))
         SAH->(dbSetOrder(0)) //Índice Temporário
         If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUM,"AH_COD_SIS")))
            EVAL(bmsg,STR0061+STR0030)  // UM NCM SEM CADASTRO
         EndIf
      EndIf
      
   endif
   
   If IN100NaoNum(Int_CE->NCEVLEMB)
      EVAL(bmsg,STR0062+STR0034)  // Valor FOB US$ Invalido
   ElseIf Val(Int_CE->NCEVLEMB) = 0
      EVAL(bmsg,STR0062+STR0027)  // Valor FOB US$ NAO INFORMADO
   ElseIf Val(Int_CE->NCEVLEMB) < 0
      EVAL(bmsg,STR0062+STR0039)  // Valor FOB US$ negativa
   EndIf
   
   
   //ER - 31/10/2007
   If !Empty(Int_CE->NCEMOEDA)
      SYF->(DbSetOrder(1))      
      If !SYF->(DbSeek(cFilSYF+AVKEY(Int_CE->NCEMOEDA,"YF_MOEDA")))
         SYF->(DbSetOrder(3))
         If !SYF->(DbSeek(cFilSYF+AVKEY(Int_CE->NCEMOEDA,"YF_COD_GI")))
            EVAL(bmsg,STR0063+STR0030)  // Moeda SEM CADASTRO
         EndIf
      EndIf
   EndIf
      

   
   If IN100NaoNum(Int_CE->NCEVALORI)
      EVAL(bmsg,STR0064+STR0034)  // Valor Moeda Invalido
   ElseIf !EMPTY(Int_CE->NCEMOEDA) .and. Val(Int_CE->NCEVALORI) = 0
      EVAL(bmsg,STR0064+STR0027)  // Valor Moeda NAO INFORMADO
   ElseIf Val(Int_CE->NCEVALORI) < 0
      EVAL(bmsg,STR0064+STR0039)  // Valor Moeda negativa
   EndIf
   
EndIf

If Empty(INT_CE->NCETIPOIE) .or. !(INT_CE->NCETIPOIE$("I/N/M"))  //!(INT_CE->NCETIPOIE$("I/E/N"))  - AOM - 21/10/10
   EVAL(bmsg,STR0120)  //Tipo do registro não informado
end if

If Int_CE->NCETIPOIE == "I" .or. Int_CE->NCETIPOIE == "N"  .or. Int_CE->NCETIPOIE == "M"

   If !Int_CE->NCETIPOIE == "M" //AOM - 21/10/10
      If EMPTY(Int_CE->NCEDINUM)
         EVAL(bmsg,STR0067+STR0027)  // Nr DI NAO INFORMADO
      ENDIF
      If !EMPTY(Int_CE->NCEDTDI) .and. !IN100CTD(Int_CE->NCEDTDI,.T.)
         EVAL(bmsg,STR0068+STR0034)  // // Data da DI INVÁLIDA
      ENDIF
      If EMPTY(Int_CE->NCEAD)
         EVAL(bmsg,STR0069+STR0027)  // Adição NAO INFORMADO
     ENDIF
   
      If Empty(INT_CE->NCEINV)
         EVAL(bmsg,STR0109)  //"Nr. da Invoice não preenchida"
      ENDIF
      
      //AOM - 12/12/2011
      IF AVFLAGS("SEQMI") .And. !Empty(Int_CE->NCESEQMI)
         EVAL(bmsg,STR0161)//"Não é necessario informar seqmi de Compras Nacionais para importação."
      ENDIF
      
   Else
      //AOM - 12/12/2011
      IF AVFLAGS("SEQMI") .And. !Empty(Int_CE->NCESEQS)
         EVAL(bmsg,STR0162)//"Não é necessario informar seqsis de importação para Compras Nacionais."
      ENDIF
      
      If !EMPTY(Int_CE->NCEDINUM)
         EVAL(bmsg,STR0141) //"Numero da DI não pode ser informada para Compras Nacionais." 
      ENDIF
      If !EMPTY(Int_CE->NCEDTDI) 
         EVAL(bmsg,STR0142) //"Data da DI não pode ser informada para Compras Nacionais."  
      ENDIF
      If !EMPTY(Int_CE->NCEAD)
         EVAL(bmsg,STR0143) //"Adição não pode ser informada para Compras Nacionais" 
     ENDIF
   
      If !Empty(INT_CE->NCEINV)
         EVAL(bmsg,STR0144) //"Invoice não pode ser informada para Compras Nacionais." 
      ENDIF
      
      If Empty(INT_CE->NCEPED)
         EVAL(bmsg,STR0145) //"O pedido deve ser preenchido quando for utilizada Compras Nacionais" 
      ENDIF
      
      If Empty(INT_CE->NCEPOSDI)
         EVAL(bmsg,STR0146) //"A posição do Pedido deve ser preenchida nas Compras Nacionais" 
      ENDIF
      
      If INT_CE->NCETIPO == INCLUSAO
         ED8->(DbSetOrder(5))
         If ED8->(DbSeek(xFilial("ED8") + AvKey(INT_CE->NCEPED,"ED8_PEDIDO") + AvKey(INT_CE->NCEPOSDI,"ED8_POSDI")))
            EVAL(bmsg,STR0153)//"Já existe Pedido e posição para Compra Nacional."   
         EndIf
      EndIf
      
      If INT_CE->NCETIPO == INCLUSAO
      
         ED8->(DbSetOrder(6))
         If ED8->(DbSeek(xFilial("ED8") + AvKey(INT_CE->NCENF,"ED8_NF") + AvKey(INT_CE->NCESERIE,"ED8_SERIE")))
            If AllTrim(ED8->ED8_FORN) == AllTrim(INT_CE->NCEFORN) .And. AllTrim(ED8->ED8_LOJA) == AllTrim(INT_CE->NCELOJA)
               EVAL(bmsg,STR0147)  //"Ja existe cadastrada a Nota Fiscal e serie para este fornecedor "
            EndIf
         EndIf
      
      EndIf
      
      If INT_CE->NCEMOEDA <> "R$"
         EVAL(bmsg,STR0148)  //"Moeda utilizada para Compras Nacionais dever ser Real."
      EndIf
      
      If Val(INT_CE->NCETXMOE) <> 1
        EVAL(bmsg,STR0149)  //"Taxa da moeda nacional deve ser sempre 1,00000000"
      EndIf 
      
      SA2->(DbSetOrder(1))
      If !(SA2->(DbSeek(xFilial("SA2") + AvKey(INT_CE->NCEFORN,"A2_COD") + AvKey(INT_CE->NCELOJA,"A2_LOJA"))))
         EVAL(bmsg,STR0150)  //"Fornecedor ou Loja informado não está cadastrado."
      EndIf
      
      
      If INT_CE->NCETIPO <> EXCLUSAO .And. !Empty(INT_CE->NCEAC) .And. IF(AVFLAGS("SEQMI"),!Empty(INT_CE->NCESEQMI),!Empty(INT_CE->NCESEQS))//AOM - 06/12/2011
      
         DbSelectArea("ED0")
            ED0->(DbSetOrder(2))
            If ED0->(DbSeek(xFilial("ED0") + AvKey(INT_CE->NCEAC,"ED0_AC")))
              If ED0->ED0_MODAL == "2"
                 EVAL(bmsg,STR0151)//"Ato Concessório informado do tipo isenção, para Compras Nacionais só é permitido o tipo Suspensão"
              EndIf 
            EndIf
            
            //AOM - 06/12/2011
            If AVFLAGS("SEQMI") .And. !Empty(INT_CE->NCESEQMI)
               ED4->(DbSetOrder(8))
            Else
               ED4->(DbSetOrder(2))
            EndIf
            If ED4->(DbSeek(xFilial("ED4") + AvKey(INT_CE->NCEAC,"ED4_AC") + If(AVFLAGS("SEQMI"),AvKey(INT_CE->NCESEQMI,"ED4_SEQMI"),AvKey(INT_CE->NCESEQS,"ED4_SEQSIS"))))//AOM - 06/12/2011
                If Empty(INT_CE->NCECODI)
                   EVAL(bmsg,STR0128)//"Código do Item não informado"  
                ElseIf AllTrim(INT_CE->NCECODI) <> AllTrim(ED4->ED4_ITEM)
                   EVAL(bmsg,STR0152)//"O item do Ato Concessório deve ser o mesmo que o da Compra Nacional."
                EndIf
            EndIf
      EndIf
      
   EndIf
   
   
   
   If Int_CE->NCETIPOIE == "I"
      If EMPTY(Int_CE->NCELINUM)
          EVAL(bmsg,STR0065+STR0027)  // Nr PLI NAO INFORMADO
      ENDIF
      If !EMPTY(Int_CE->NCEDTLI) .and. !IN100CTD(Int_CE->NCEDTLI,.T.)
         EVAL(bmsg,STR0066+STR0034)  // // Data da PLI INVÁLIDA
      ENDIF
      

      ED8->(DBSETORDER(1))
      If ED8->(dbSeek(xFilial("ED8")+Int_CE->NCELINUM+Int_CE->NCEDINUM+Int_CE->NCEAD+Int_CE->NCEAC+Int_CE->NCESEQS))
         If lMUserEDC  .And.  !oMUSerEDC:Reserva("INTEGRACAO","EFETIVA_DI")  // PLB 06/12/06
            EVAL(bmsg,STR0136+STR0137)  //"Registro" " em uso por outro processo."
         EndIf
      EndIf
   elseIf Int_CE->NCETIPOIE == "N" 
      ED8->(DBSETORDER(4))
      ED8->(dbSeek(xFilial("ED8")+Int_CE->NCEDINUM+Int_CE->NCEAD+Int_CE->NCEPOSDI))
   ElseIf Int_CE->NCETIPOIE == "M" //AOM - 21/10/10
      ED8->(DBSETORDER(5))
      ED8->(dbSeek(xFilial("ED8")+Int_CE->NCEPED+Int_CE->NCEPOSDI))      
   EndIf
   if !ed8->(EOF())
      If Int_CE->NCETIPO = INCLUSAO
         EVAL(bmsg,STR0070+STR0074)  // A.C. JA INFORMADO
      EndIf
   endif

   IF Int_CE->NCETIPOIE == "I"
      //NOPADO POR AOM - 01/09/2011
      /*If EMPTY(Int_CE->NCESEQS)
          EVAL(bmsg,STR0121)  //"Sequencia A.C. não informada"
      ENDIF      
      If EMPTY(Int_CE->NCEAC) 
         EVAL(bmsg,STR0070+STR0027)  // A.C. NAO INFORMADO
      endif*/
      
      If !EMPTY(Int_CE->NCEAC) .And. Empty(Int_CE->NCESEQS) //AOM - 01/09/2011
          ED4->(dbSetOrder(7))
          If !ED4->(dbSeek(xFilial("ED4")+Int_CE->NCEAC+Int_CE->NCENCM+Int_CE->NCECODI+Int_CE->NCEUMN))
             EVAL(bmsg,STR0070+" + "+STR0071+STR0030)  // A.C. + Posição SEM CADASTRO
             IF EasyEntryPoint("IN100CLI")
                ExecBlock("IN100CLI",.F.,.F.,"VALCE")
             ENDIF
             IN100VerErro(cErro,cAviso)
             IF Int_CE->NCEINT_OK = "T"
                nResumoCer+=1
             ELSE
                nResumoErr+=1
             ENDIF
             If lMUserEDC
                oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
             EndIf
             RETURN
          Else
            If Int_CE->NCETIPO <> EXCLUSAO .and. !ACContSaldo("V","ED8") //Valida Saldos
               EVAL(bmsg,STR0075+STR0034)  // Saldo Inválido
            EndIf
          endif
      ElseIf !EMPTY(Int_CE->NCEAC) //AOM - 06/12/2011

         ED4->(dbSetOrder(2))
         If !ED4->(dbSeek(xFilial("ED4")+Int_CE->NCEAC+Int_CE->NCESEQS))
             EVAL(bmsg,STR0070+" + "+STR0071+STR0030)  // A.C. + Posição SEM CADASTRO
             IF EasyEntryPoint("IN100CLI")
                ExecBlock("IN100CLI",.F.,.F.,"VALCE")
             ENDIF
             IN100VerErro(cErro,cAviso)
             IF Int_CE->NCEINT_OK = "T"
                nResumoCer+=1
             ELSE
                nResumoErr+=1
             ENDIF
             If lMUserEDC
                oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
             EndIf
             RETURN
         Else
            If Int_CE->NCETIPO <> EXCLUSAO .and. !ACContSaldo("V","ED8") //Valida Saldos
               EVAL(bmsg,STR0075+STR0034)  // Saldo Inválido
            EndIf
            If lMUserEDC  .And.  !oMUserEDC:Reserva("INTEGRACAO","EFETIVA_ATO")  // PLB - 06/12/06
               EVAL(bmsg,STR0070+" "+AllTrim(ED4->ED4_AC)+STR0137)  // "A.C. " ### " em uso por outro processo."
            EndIf
         endif
      endif
   
   ELSEIF Int_CE->NCETIPOIE == "N"
      
      If lPe_Val
         If !EMPTY(Int_CE->NCEAC)
             EVAL(bmsg,STR0122) //"A.C. não deve ser informada para registros de integracao de DI"
         ENDIF
         If !EMPTY(Int_CE->NCESEQS)
             EVAL(bmsg,STR0123)   //"Sequencia A.C. não deve ser informada para registros de integracao de DI"
         ENDIF      
      EndIf

      If IN100NaoNum(Int_CE->NCETXUSS)
         EVAL(bmsg,STR0124)  //"Taxa da moeda US$ na DI inválida"
      ElseIf Val(Int_CE->NCETXUSS) = 0
         EVAL(bmsg,STR0124) //"Taxa da moeda US$ na DI inválida"
      ElseIf Val(Int_CE->NCETXUSS) < 0
         EVAL(bmsg,STR0125)  //"Taxa da moeda US$ na DI negativa"
      EndIf

      If IN100NaoNum(Int_CE->NCETXMOE)
         EVAL(bmsg,STR0126) //"Taxa da moeda inválida"
      ElseIf Val(Int_CE->NCETXMOE) = 0
         EVAL(bmsg,STR0126) //"Taxa da moeda inválida"
      ElseIf Val(Int_CE->NCETXMOE) < 0
         EVAL(bmsg,STR0127)  //"Taxa da moeda negativa"
      EndIf

      If Empty(Int_CE->NCECODI)
         EVAL(bmsg,STR0128)  //"Código do item não informado"
      EndIf
      SB1->(DBSETORDER(1))
      IF !SB1->(DBSEEK(XFILIAL("SB1")+Int_CE->NCECODI))
         EVAL(bmsg,STR0129)  //"Produto não existe no cadatro do easy"
      ELSE
        if Empty(Int_CE->NCEDESC)
           INT_CE->NCEDESC:=sb1->b1_desc             
        endif
      ENDIF
      
   ELSEIF Int_CE->NCETIPOIE == "M"
   
      If !Empty(Int_CE->NCEAC) .And. IF(AVFLAGS("SEQMI"),Empty(Int_CE->NCESEQMI),Empty(Int_CE->NCESEQS)) //AOM - 06/12/2011
          ED4->(dbSetOrder(7))
          If !ED4->(dbSeek(xFilial("ED4")+Int_CE->NCEAC+Int_CE->NCENCM+Int_CE->NCECODI+Int_CE->NCEUMN))
             EVAL(bmsg,STR0070+" + "+STR0071+STR0030)  // A.C. + Posição SEM CADASTRO
             IF EasyEntryPoint("IN100CLI")
                ExecBlock("IN100CLI",.F.,.F.,"VALCE")
             ENDIF
             IN100VerErro(cErro,cAviso)
             IF Int_CE->NCEINT_OK = "T"
                nResumoCer+=1
             ELSE
                nResumoErr+=1
             ENDIF
             If lMUserEDC
                oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
             EndIf
             RETURN
          Else
            If Int_CE->NCETIPO <> EXCLUSAO .and. !ACContSaldo("V","ED8") //Valida Saldos
               EVAL(bmsg,STR0075+STR0034)  // Saldo Inválido
            EndIf
          endif
      ElseIf !Empty(Int_CE->NCEAC) .And. IF(AVFLAGS("SEQMI"),!Empty(Int_CE->NCESEQMI),!Empty(Int_CE->NCESEQS)) //AOM - 06/12/2011 
      
         If AVFLAGS("SEQMI")
            ED4->(dbSetOrder(8))
         Else
            ED4->(dbSetOrder(2))
         EndIf
         If !ED4->(dbSeek(xFilial("ED4")+Int_CE->NCEAC+If(AVFLAGS("SEQMI"),Int_CE->NCESEQMI,Int_CE->NCESEQS))) //AOM - 06/12/2011 
             EVAL(bmsg,STR0070+" + "+STR0071+STR0030)  // A.C. + Posição SEM CADASTRO
             IF EasyEntryPoint("IN100CLI")
                ExecBlock("IN100CLI",.F.,.F.,"VALCE")
             ENDIF
             IN100VerErro(cErro,cAviso)
             IF Int_CE->NCEINT_OK = "T"
                nResumoCer+=1
             ELSE
                nResumoErr+=1
             ENDIF
             If lMUserEDC
                oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
             EndIf
             RETURN
         Else
            If Int_CE->NCETIPO <> EXCLUSAO .and. !ACContSaldo("V","ED8") //Valida Saldos
               EVAL(bmsg,STR0075+STR0034)  // Saldo Inválido
            EndIf
            If lMUserEDC  .And.  !oMUserEDC:Reserva("INTEGRACAO","EFETIVA_ATO")  // PLB - 06/12/06
               EVAL(bmsg,STR0070+" "+AllTrim(ED4->ED4_AC)+STR0137)  // "A.C. " ### " em uso por outro processo."
            EndIf
         endif
      endif
   
   ENDIF

   if Empty(ALLTRIM(INT_CE->NCEDESC))
     SB1->(DBSETORDER(1))
     IF SB1->(DBSEEK(XFILIAL("SB1")+INT_CE->NCECODI))
           INT_CE->NCEDESC:=sb1->b1_desc             
     endif
   ENDIF

   SYT->(DBSETORDER(3))
   If EMPTY(INT_CE->NCECNPJ) .and. INT_CE->NCETIPO <> EXCLUSAO
      EVAL(bmsg,STR0076+STR0027)  // CNPJ Importador NAO INFORMADO
   ElseIf !SYT->(dbSeek(cFilSYT+INT_CE->NCECNPJ))
      EVAL(bmsg,STR0076+STR0030)  // CNPJ Importador SEM CADASTRO
   ENDIF
   
   if empty(INT_CE->NCEUMN)
      EVAL(bmsg,"UM NCM VAZIA")  // UM NCM SEM CADASTRO   
   else
      
      //ER - 31/10/2007
      SAH->(DbSetOrder(1))
      If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUMN,"AH_UNIMED")))
         SAH->(dbSetOrder(0)) //Índice Temporário
         If !SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUMN,"AH_COD_SIS")))
            EVAL(bmsg,STR0061+STR0030)  // UM NCM SEM CADASTRO
         EndIf
      EndIf
      
   ENDIF
   
   
   
/*Else
   
   If EMPTY(INT_CE->NCEAC)
      EVAL(bmsg,STR0070+STR0027)  // A.C. NAO INFORMADO
   ElseIf Empty(INT_CE->NCEPOSDI)
      EVAL(bmsg,STR0071+STR0027)  // Posição NAO INFORMADO
   ElseIf !ED3->(dbSeek(xFilial("ED3")+INT_CE->NCEAC+INT_CE->NCEPOSDI))
      EVAL(bmsg,STR0070+" + "+STR0071+STR0030)  // A.C. + Posição SEM CADASTRO
      
      IF EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"VALCE")
      ENDIF
      IN100VerErro(cErro,cAviso)
      IF INT_CE->NCEINT_OK = "T"
         nResumoCer+=1
      ELSE
         nResumoErr+=1
      ENDIF
      If lMUserEDC
         oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
      EndIf
      RETURN .T.
   ENDIF

   If EMPTY(INT_CE->NCECNPJ) .and. INT_CE->NCETIPO <> EXCLUSAO
      EVAL(bmsg,STR0077+STR0027)  // CNPJ Exp/Forn NAO INFORMADO
   ElseIf !SA2->(dbSeek(cFilSA2Aux+INT_CE->NCECNPJ))
      EVAL(bmsg,STR0077+STR0030)  // CNPJ Exp/Forn SEM CADASTRO
   ElseIf ED3->ED3_CNPJIM <> Left(INT_CE->NCECNPJ,8)
      EVAL(bmsg,STR0078+STR0070)  // CNPJ diferente do A.C.
   ENDIF*/

EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALCE")
ENDIF

IN100VerErro(cErro,cAviso)
IF INT_CE->NCEINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

If lMUserEDC
   oMUserEDC:Fim()  // PLB 06/12/06 - Solta registros presos e reinicializa objeto
EndIf

Return .T.

*--------------------*
FUNCTION IN100GrvCE()
*--------------------*
//Local cAliasDR:=If(INT_CE->NCETIPOIE = "I", "ED8", "ED9")
lFlagED8 := .F.  //Verifica se o ato foi alterado  AOM - 21/10/10

If INT_CE->NCETIPOIE == "M" .And. AVFLAGS("SEQMI") //AOM - 21/10/10

   If Empty(INT_CE->NCESEQMI)
      ED4->(dbSetOrder(7))
      ED4->(dbSeek(xFilial("ED4")+INT_CE->NCEAC+INT_CE->NCENCM+INT_CE->NCECODI+INT_CE->NCEUMN))
   Else
      ED4->(dbSetOrder(8))
      ED4->(dbSeek(xFilial("ED4")+INT_CE->NCEAC+INT_CE->NCESEQMI))
   ENDIF 

Else

   If Empty(INT_CE->NCESEQS)
      ED4->(dbSetOrder(7))
      ED4->(dbSeek(xFilial("ED4")+INT_CE->NCEAC+INT_CE->NCENCM+INT_CE->NCECODI+INT_CE->NCEUMN))
   Else
      ED4->(dbSetOrder(2))
      ED4->(dbSeek(xFilial("ED4")+INT_CE->NCEAC+INT_CE->NCESEQS))
   ENDIF 

EndIf       


IF INT_CE->NCETIPO # INCLUSAO
   If INT_CE->NCETIPOIE == "I"
      ED8->(DBSETORDER(1))
      ED8->(dbSeek(xFilial("ED8")+INT_CE->NCELINUM+INT_CE->NCEDINUM+INT_CE->NCEAD+INT_CE->NCEAC+INT_CE->NCESEQS))
   elseIf INT_CE->NCETIPOIE == "N"
      ED8->(DBSETORDER(4))
      ED8->(dbSeek(xFilial("ED8")+INT_CE->NCEDINUM+INT_CE->NCEAD+INT_CE->NCEPOSDI))
   ElseIf INT_CE->NCETIPOIE == "M"
      ED8->(DBSETORDER(5))
      If ED8->(dbSeek(xFilial("ED8")+Int_CE->NCEPED+Int_CE->NCEPOSDI))
         If !Empty(ED8->ED8_AC)
            //AOM - 06/12/2011
            If AVFLAGS("SEQMI") 
               If Empty(ED8->ED8_SEQMI)
                  ED4->(dbSetOrder(7))
                  ED4->(dbSeek(xFilial("ED4")+ED8->ED8_AC+ED8->ED8_NCM+ED8->ED8_COD_I+ED8->ED8_UMNCM))
               Else
                  ED4->(dbSetOrder(8))
                  ED4->(dbSeek(xFilial("ED4")+ED8->ED8_AC+ED8->ED8_SEQMI))
               ENDIF 
            
            Else
               If Empty(ED8->ED8_SEQSIS)
                  ED4->(dbSetOrder(7))
                  ED4->(dbSeek(xFilial("ED4")+ED8->ED8_AC+ED8->ED8_NCM+ED8->ED8_COD_I+ED8->ED8_UMNCM))
               Else
                  ED4->(dbSetOrder(2))
                  ED4->(dbSeek(xFilial("ED4")+ED8->ED8_AC+ED8->ED8_SEQSIS))
               ENDIF 
            EndIf
         EndIf   
      EndIf
      
   EndIf
   DBSELECTAREA("ED8")
   IF INT_CE->NCETIPO == EXCLUSAO .AND. !ED8->(EOF())
      if INT_CE->NCETIPOIE == "I" .or. (INT_CE->NCETIPOIE == "M" .And. !Empty(ED8->ED8_AC)) //AOM - 21/10/10
         ACContSaldo("D","ED8")    
      endif
      Reclock("ED8",.F.)
      ED8->(DBDELETE())
      ED8->(DBCOMMIT())
      ED8->(MSUNLOCK())
      RETURN .F.
   ENDIF
EndIf

   IF INT_CE->NCETIPO = INCLUSAO
      ED8->(Reclock("ED8",.T.))
   ELSE
      IF ED8->(EOF())
         RETURN .F.
      ELSE
         ED8->(Reclock("ED8",.F.))
      ENDIF
   ENDIF
   
   Begin Transaction 
   
   If !Empty(ED8->ED8_AC) //.or. !Empty(INT_CE->NCEAC)
      lFlagED8 := .T. 
   EndIf
   
   If INT_CE->NCETIPOIE == "I" .or. INT_CE->NCETIPOIE == "M"  //AOM - 21/10/10
      IF INT_CE->NCETIPO = ALTERACAO .And. lFlagED8
         ACContSaldo("D","ED8")
      EndIf
   EndIf
   
   //AOM - 22/10/10 - Grava Filial
   ED8->ED8_FILIAL := xFilial("ED8")

   //IN100CTD(INT_CE->NCEDTDI)
   //IN100RecLock("ED8")  
   ED8->ED8_DT_INT:=IN100CTD(INT_CE->NCEINT_DT)
   
   //AAF - 10/01/05 - Grava o Código do Importador.
   ED8->ED8_IMPORT:=SYT->YT_COD_IMP
   
   ED8->ED8_CNPJIM:=INT_CE->NCECNPJ
   ED8->ED8_LI_NUM:=INT_CE->NCELINUM
   ED8->ED8_DI_NUM:=INT_CE->NCEDINUM
   ED8->ED8_ADICAO:=INT_CE->NCEAD
   ED8->ED8_AC:=INT_CE->NCEAC
   ED8->ED8_DTREG:=IN100CTD(INT_CE->NCEDTDI)
   ED8->ED8_DTLI:=IN100CTD(INT_CE->NCEDTLI)
   ED8->ED8_COD_I:=INT_CE->NCECODI
   ED8->ED8_SEQSIS:=INT_CE->NCESEQS 
   //AOM 05/12/2011
   If AVFLAGS("SEQMI")
      ED8->ED8_SEQMI:=INT_CE->NCESEQMI
   EndIf
   ED8->ED8_DESC:=INT_CE->NCEDESC
   ED8->ED8_PESO:=VAL(INT_CE->NCEPESO)
   ED8->ED8_QTDNCM:=VAL(INT_CE->NCEQTDN)

   
   /*
   if SAH->(DBSEEK(cFilSAH+AVKEY(Int_CE->NCEUMN,"AH_UNIMED"))) //HVR 13/03/2006 - Substituido Else para ver se existe Unidade de Medida comum
      ED8->ED8_UMNCM:=INT_CE->NCEUMN
      ED8->ED8_UM   :=INT_CE->NCEUM
      ED8->ED8_MOEDA:=INT_CE->NCEMOEDA
   Else
      SAH->(dbSetOrder(0))
      if SAH->(DBSEEK(cFilSAH+AVKEY(INT_CE->NCEUMN,"AH_COD_SIS")))  //HVR 13/03/2006 - Substituido if isSISCOM, dbSeek para ver se encontra unidade de medida Siscomex
         ED8->ED8_UMNCM:=SAH->AH_UNIMED
         ED8->ED8_UM   :=SAH->AH_UNIMED
         ED8->ED8_MOEDA:=SYF->YF_MOEDA
      ENDIF
      SAH->(dbSetOrder(1))
   endif
   */
    
   //ER - 01/11/2007
   ED8->ED8_UMNCM:=INT_CE->NCEUMN
   ED8->ED8_UM   :=INT_CE->NCEUM
   ED8->ED8_MOEDA:=INT_CE->NCEMOEDA

   ED8->ED8_QTD:=VAL(INT_CE->NCEQTD)   
   ED8->ED8_NCM:=INT_CE->NCENCM
   ED8->ED8_VALEMB:=VAL(INT_CE->NCEVLEMB)
   ED8->ED8_TX_USS:=VAL(INT_CE->NCETXUSS)
   ED8->ED8_INVOIC:=INT_CE->NCEINV
   ED8->ED8_FRETE:=VAL(INT_CE->NCEFR)
   ED8->ED8_MOE_FR:=INT_CE->NCEMOEFR
   ED8->ED8_TX_FR:=VAL(INT_CE->NCETXFR)
   ED8->ED8_SEGURO:=VAL(INT_CE->NCESE)
   ED8->ED8_MOE_SE:=INT_CE->NCEMOESE
   ED8->ED8_TX_SE:=VAL(INT_CE->NCETXSE)
   ED8->ED8_SE_USS:=VAL(INT_CE->NCESEUSS)
   ED8->ED8_NF:=INT_CE->NCENF
   //ED8->ED8_SERIE:=INT_CE->NCESERIE
   SerieNfId("ED8",1,"ED8_SERIE",IN100CTD(INT_CE->NCEEMISSA),EasyGParam("MV_ESPEIC",,'NFE'),INT_CE->NCESERIE)
   
   ED8->ED8_EMISSA:=IN100CTD(INT_CE->NCEEMISSA)

   ED8->ED8_VALORI:=VAL(INT_CE->NCEVALORI)
   ED8->ED8_TX_MOE:=VAL(INT_CE->NCETXMOE)
   ED8->ED8_POSDI:=INT_CE->NCEPOSDI

   ED8->ED8_MRCDES:=INT_CE->NCEMRD
   ED8->ED8_ARMDES:=INT_CE->NCEARMD
   ED8->ED8_INLAND:=INT_CE->NCEINLAN
   ED8->ED8_OUTDES:=INT_CE->NCEOUTD
   ED8->ED8_PACKIN:=INT_CE->NCEPACK
   ED8->ED8_DESCNT:=INT_CE->NCEDESCT
   
   If ED8->(FieldPos("ED8_PEDIDO")) > 0
      ED8->ED8_PEDIDO := INT_CE->NCEPED
   EndIf
   
   If ED8->(FieldPos("ED8_FORN")) > 0
      ED8->ED8_FORN := INT_CE->NCEFORN
   EndIf 
   
   If ED8->(FieldPos("ED8_LOJA")) > 0
      ED8->ED8_LOJA := INT_CE->NCELOJA
   EndIf
   
   //*** GFP 26/08/2011 - Integração Fabricantes/Fornecedores.
   If(ED8->(FieldPos("ED8_VLII"))   > 0, ED8->ED8_VLII    := INT_CE->NCEVLII  ,) //"I.I. R$"
   If(ED8->(FieldPos("ED8_VLIPI"))  > 0, ED8->ED8_VLIPI   := INT_CE->NCEVLIPI ,) //"IPI R$"
   If(ED8->(FieldPos("ED8_VLICMS")) > 0, ED8->ED8_VLICMS  := INT_CE->NCEVLICMS,) //"I.C.M.S. R$"
   If(ED8->(FieldPos("ED8_VLRPIS")) > 0, ED8->ED8_VLRPIS  := INT_CE->NCEVLPIS ,) //"Valor PIS"
   If(ED8->(FieldPos("ED8_VLRCOF")) > 0, ED8->ED8_VLRCOF  := INT_CE->NCEVLCOF ,) //"Valor COFINS"

   //ED8->ED8_ACISEN:=INT_CE->NCEACISEN
   //ED8->ED8_QT_AC2:=INT_CE->NCEQTAC2
   //ED8->ED8_ISETOT:=INT_CE->NCEISETOT
   //ED8->ED8_SALISE:=INT_CE->NCESALISE
   //ED8->ED8_FASEDR:=INT_CE->NCEFASEDR

   IF SB1->(DBSEEK(cFilSB1+AVKEY(INT_CE->NCECODI,"B1_COD")))
      //ED8->ED8_DES_VM:=SB1->B1_DESC_GI
      MSMM(ED8->ED8_DES_DI,,,MSMM(SB1->B1_DESC_GI),1,,,"ED8","ED8_DES_DI")
   ENDIF
   
   ED8->(MSUNLOCK())
   
   End Transaction
   
   If INT_CE->NCETIPOIE == "I" .or. INT_CE->NCETIPOIE == "M"  //AOM - 21/10/10 
     If  !Empty(INT_CE->NCEAC)
        ACContSaldo("B","ED8")
     EndIf
   EndIf
   
   
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVCE")
   EndIf
   
Return .T.

*-------------------------------------------------------------------------------------------------*
Static Function ACContSaldo(cOpca,cAlias)
*-------------------------------------------------------------------------------------------------*
Local lReto := .T., nQtdAux:=0, nValAux:=0, nQtdOld:=0, nPos 
Local cSequencia := IF(AVFLAGS("SEQMI") .and. Empty(ED4->ED4_SEQSIS),ED4->ED4_SEQMI,ED4->ED4_SEQSIS) //AOM - 06/12/2011

ED0->(dbSeek(xFilial("ED0")+INT_CE->NCEAC))
If cOpca == "V" 
   If !Empty(ED0->ED0_DT_ENC)
      EVAL(bmsg,STR0070+STR0079)  // A.C. Encerrado
      Return lReto
   EndIf
EndIf

If cAlias == "ED8"
   If cOpca == "V"          //Valida
      if ed4->(eof())
         return .f.
      endif
      If AvVldUn(ED4->ED4_UMITEM) // -- MPG - 06/02/2018 
         nQtdAux := VAL(INT_CE->NCEQTD) * VAL(INT_CE->NCEPESO)//ED8->ED8_PESO
      Else
         nQtdAux := AVTransUnid(INT_CE->NCEUMN,ED4->ED4_UMITEM,ED4->ED4_ITEM,Val(INT_CE->NCEQTDN),.F.)
      EndIf
      nValAux := Val(INT_CE->NCEVLEMB)

      nPos := ASCAN(aSaldoAC,{|X| X[1]==ED4->ED4_AC .and. X[2]==cSequencia .and. X[5]==cAlias})
      If nPos > 0
         nQtdAux += aSaldoAC[nPos,3]
         nValAux += aSaldoAC[nPos,4]
      EndIf

      If INT_CE->NCETIPO = INCLUSAO
         If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and.;
         (ED4->ED4_QT_LI < nQtdAux .or. ED4->ED4_QT_DI < nQtdAux)
            lReto :=.F.
         ElseIf ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and.;
         (ED4->ED4_VL_LI < nValAux .or. ED4->ED4_VL_DI < nValAux)
            lReto :=.F.
         EndIf
      Else
         nQtdOld := ED8->ED8_QTDNCM  
         If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and.;
         ((ED4->ED4_QT_LI + nQtdOld) < nQtdAux .or. (ED4->ED4_QT_DI +nQtdOld) < nQtdAux)
            lReto :=.F.
         ElseIf ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and.;
         ((ED4->ED4_VL_LI + ED8->ED8_VALORI)< nValAux .or. (ED4->ED4_VL_DI + ED8->ED8_VALORI) < nValAux)
            lReto :=.F.
         EndIf
      EndIf
      If lReto
         If INT_CE->NCETIPO = ALTERACAO
            nQtdAux -= nQtdOld
            nValAux -= ED8->ED8_VALORI
         EndIf
         If nPos > 0
            If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA)
               aSaldoAC[nPos,3] := nQtdAux
            EndIf
            aSaldoAC[nPos,4] := nValAux
         Else
            If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA)
               AADD(aSaldoAC,{ED4->ED4_AC,cSequencia,nQtdAux,nValAux,cAlias})
            Else
               AADD(aSaldoAC,{ED4->ED4_AC,cSequencia,0      ,nValAux,cAlias})
            EndIf
         EndIf
      EndIf
   ElseIf cOpca == "D"      //Devolve
      if ed4->(eof())
         return .f.
      endif
      If AvVldUn(ED4->ED4_UMITEM) // -- MPG - 06/02/2018
         nQtdAux := VAL(INT_CE->NCEQTD) * VAL(INT_CE->NCEPESO)//ED8->ED8_PESO
      Else
         nQtdAux := AVTransUnid(ED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,ED8->ED8_QTDNCM,.F.)
                    //AVTransUnid(INT_CE->NCEUMN,ED4->ED4_UMITEM,ED4->ED4_ITEM,Val(INT_CE->NCEQTDN),.F.) - NOPADO POR AOM - 22/10/10 
      EndIf
                  
      ED4->(RECLOCK("ED4",.F.))
      ED4->ED4_VL_LI  +=  ED8->ED8_VALEMB //VALOR EM DOLAR
      ED4->ED4_VL_DI  +=  ED8->ED8_VALEMB //VALOR EM DOLAR
      If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
         ED4->ED4_QT_LI  += nQtdAux
         ED4->ED4_QT_DI  += nQtdAux
         If AvVldUn(ED4->ED4_UMNCM) // -- MPG - 06/02/2018
            ED4->ED4_SNCMLI += ED8->ED8_QTD * ED8->ED8_PESO
            ED4->ED4_SNCMDI += ED8->ED8_QTD * ED8->ED8_PESO
            
            //AOM - 21/10/10
            If ED4->(FieldPos("ED4_SNCMEX")) > 0
               ED4->ED4_SNCMEX-= ED8->ED8_QTD * ED8->ED8_PESO
            EndIf
            
            If ED4->(FieldPos("ED4_SQTDEX")) > 0 
               ED4->ED4_SQTDEX-= ED8->ED8_QTD * ED8->ED8_PESO
            EndIf
         Else
            ED4->ED4_SNCMLI += ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
            ED4->ED4_SNCMDI += ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
            
            //AOM - 21/10/10
            If ED4->(FieldPos("ED4_SNCMEX")) > 0
               ED4->ED4_SNCMEX-= ED8->ED8_QTDNCM
            EndIf
            
            If ED4->(FieldPos("ED4_SQTDEX")) > 0 
               ED4->ED4_SQTDEX-= ED8->ED8_QTDNCM
            EndIf 
            
         EndIf
         Reclock("ED8",.F.)         
         ED8->ED8_VL_AC  :=0 //VALOR EM DOLAR
         ED8->ED8_QT_AC := 0 //QUANTIDADE DE COMPRA
         ED8->ED8_QT_AC2:= 0 //QUANTIDADE DE COMPRA
         ED8->(MSUNLOCK())
      Else 
         Reclock("ED8",.F.)         
         ED8->ED8_VL_AC  := 0 //VALOR EM DOLAR
         ED8->(MSUNLOCK())
      EndIf
      ED4->(msUnlock())
      
      ED0->( dbSetOrder(1) )
      ED0->( dbSeek(xFilial("ED0")+ED4->ED4_PD) )
      If ED0->ED0_MODAL == "1"
      
         If (Int_CE->NCETIPOIE == "I" .or.  Int_CE->NCETIPOIE == "N") .And.  !EMPTY(ED8->ED8_AC) //AOM - 21/10/10
         
            If EasyGParam("MV_ANT_IMP",,"1") == "2"
               MN400GrvAnt(2,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC,ED8->ED8_DTREG)
            ElseIf EasyGParam("MV_ANT_IMP",,"1") == "1"
               If !Empty(ED8->ED8_EMISSA) //Estorno da Comprovação.
                  MN400GrvAnt(2,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC,ED8->ED8_EMISSA)
               EndIf
            EndIf
            
         ElseIf Int_CE->NCETIPOIE == "I" .And. !EMPTY(ED8->ED8_AC)
            
            If Int_CE->NCETIPOIE == "M" .And. ED8->( FieldPos("ED8_PEDIDO") ) > 0    //AOM - 21/10/10
               MN400GrvAnt(2,/*Hawb*/,ED8->ED8_PEDIDO,/*Invoice*/,ED8->ED8_COD_I,ED8->ED8_POSDI,/*PGI*/,ED8->ED8_QTD,/*DataReg*/)
            EndIf
            
         EndIf
         
      EndIf 
           
      
   ElseIf cOpca == "B"      //Baixa
      if ed4->(eof())
         return .f.
      endif
      If AvVldUn(ED4->ED4_UMITEM) // -- MPG - 06/02/2018
         nQtdAux := VAL(INT_CE->NCEQTD) * VAL(INT_CE->NCEPESO)//ED8->ED8_PESO
      Else
         nQtdAux := AVTransUnid(ED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,ED8->ED8_QTDNCM,.F.)
                    //AVTransUnid(INT_CE->NCEUMN,ED4->ED4_UMITEM,ED4->ED4_ITEM,Val(INT_CE->NCEQTDN),.F.) - NOPADO POR AOM - 22/10/10              
      EndIf
            
      ED4->(RECLOCK("ED4",.F.))
      ED4->ED4_VL_LI  -=  ED8->ED8_VALEMB //VALOR EM DOLAR
      ED4->ED4_VL_DI  -=  ED8->ED8_VALEMB //VALOR EM DOLAR
      If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
         ED4->ED4_QT_LI  -= nQtdAux
         ED4->ED4_QT_DI  -= nQtdAux
         If AvVldUn(ED4->ED4_UMNCM) // -- MPG - 06/02/2018
            ED4->ED4_SNCMLI -= ED8->ED8_QTD * ED8->ED8_PESO
            ED4->ED4_SNCMDI -= ED8->ED8_QTD * ED8->ED8_PESO
            
            //AOM - 21/10/10
            If ED4->(FieldPos("ED4_SNCMEX")) > 0
               ED4->ED4_SNCMEX+= ED8->ED8_QTD * ED8->ED8_PESO
            EndIf
            
            If ED4->(FieldPos("ED4_SQTDEX")) > 0 
               ED4->ED4_SQTDEX+= ED8->ED8_QTD * ED8->ED8_PESO
            EndIf 
            
         Else
            ED4->ED4_SNCMLI -= ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
            ED4->ED4_SNCMDI -= ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
            
            
            //AOM - 21/10/10
            If ED4->(FieldPos("ED4_SNCMEX")) > 0
               ED4->ED4_SNCMEX+= ED8->ED8_QTDNCM
            EndIf
            
            If ED4->(FieldPos("ED4_SQTDEX")) > 0 
               ED4->ED4_SQTDEX+= ED8->ED8_QTDNCM
            EndIf
            
         EndIf
         Reclock("ED8",.F.)         
         ED8->ED8_VL_AC  := ED8->ED8_VALEMB //VALOR EM DOLAR
         ED8->ED8_QT_AC := ED8->ED8_QTD //QUANTIDADE DE COMPRA
         ED8->ED8_QT_AC2:= ED8->ED8_QTDNCM //QUANTIDADE DE COMPRA
         ED8->(MSUNLOCK())         
      Else
         Reclock("ED8",.F.)         
         ED8->ED8_VL_AC  := ED8->ED8_VALEMB //VALOR EM DOLAR
         ED8->(MSUNLOCK())         
      EndIf
      ED4->(msUnlock())
      
      ED0->( dbSetOrder(1) )
      ED0->( dbSeek(xFilial("ED0")+ED4->ED4_PD) )      
      If ED0->ED0_MODAL == "1"
       
         If (Int_CE->NCETIPOIE == "I" .or.  Int_CE->NCETIPOIE == "N") .And.  !EMPTY(Int_CE->NCEAC)  //AOM - 09/12/2011
         
            If EasyGParam("MV_ANT_IMP",,"1") == "2"
               MN400GrvAnt(1,Int_CE->NCEDINUM+Int_CE->NCEAD,""/*PONUM*/,Int_CE->NCEINV,Int_CE->NCECODI,Int_CE->NCEPOSDI,Int_CE->NCELINUM,Val(Int_CE->NCEQTD),IN100CTD(INT_CE->NCEDTDI))
            ElseIf EasyGParam("MV_ANT_IMP",,"1") == "1"
               MN400GrvAnt(1,Int_CE->NCEDINUM+Int_CE->NCEAD,""/*PONUM*/,Int_CE->NCEINV,Int_CE->NCECODI,Int_CE->NCEPOSDI,Int_CE->NCELINUM,Val(Int_CE->NCEQTD),IF(!Empty(INT_CE->NCEEMISSA),IN100CTD(INT_CE->NCEEMISSA),dDataBase))
            EndIf
            
         ElseIf Int_CE->NCETIPOIE == "M" .And. !EMPTY(Int_CE->NCEAC) .And. ED8->( FieldPos("ED8_PEDIDO") ) > 0 //AOM - 09/12/2011
         
            MN400GrvAnt(1,/*Hawb*/,Int_CE->NCEPED,/*Invoice*/,Int_CE->NCECODI,Int_CE->NCEPOSDI,/*PGI*/,Val(Int_CE->NCEQTD),IF(!Empty(INT_CE->NCEEMISSA),IN100CTD(INT_CE->NCEEMISSA),dDataBase))
            
         EndIf
   
      EndIf
      
   EndIf
Else
   If cOpca == "V"          //Valida
      If AvVldUn(ED3->ED3_UMPROD) // -- MPG - 06/02/2018
         nQtdAux := ED9->ED9_PESO
      Else
         nQtdAux := AVTransUnid(INT_CE->NCEUMN,ED3->ED3_UMPROD,ED3->ED3_PROD,Val(INT_CE->NCEQTDN),.F.)
      EndIf
      nValAux := Val(INT_CE->NCEVLEMB)

      nPos := ASCAN(aSaldoAC,{|X| X[1]==ED3->ED3_AC .and. X[2]==ED3->ED3_SEQSIS .and. X[5]==cAlias})
      If nPos > 0
         nQtdAux += aSaldoAC[nPos,3]
         nValAux += aSaldoAC[nPos,4]
      EndIf

      If INT_CE->NCETIPO = INCLUSAO
         If ED3->ED3_SALDO < nQtdAux
            lReto :=.F.
         EndIf
      Else
         nQtdOld := ED9->ED9_QT_AC
         If (ED3->ED3_SALDO + nQtdOld) < nQtdAux
            lReto :=.F.
         EndIf
      EndIf
      If lReto
         If(INT_CE->NCETIPO = ALTERACAO, nQtdAux-=nQtdOld, )
         If nPos > 0
            aSaldoAC[nPos,3] := nQtdAux
            aSaldoAC[nPos,4] := nValAux
         Else
            AADD(aSaldoAC,{ED3->ED3_AC,ED3->ED3_SEQSIS,nQtdAux,nValAux,cAlias})
         EndIf
      EndIf
   ElseIf cOpca == "D"      //Devolve
      ED3->(RecLock("ED3",.F.))
      ED3->ED3_SALDO += ED9->ED9_QT_AC
      If AvVldUn(ED9->ED9_UM) // -- MPG - 06/02/2018
         ED3->ED3_SALNCM += ED9->ED9_PESO
      Else
         ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,ED9->ED9_QT_AC)
      EndIf
      //If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)
      ED3->(msUnlock())
      ED9->ED9_QT_AC := 0
      ED9->ED9_VL_AC := 0
   ElseIf cOpca == "B"      //Baixa
      If AvVldUn(ED3->ED3_UMPROD) // -- MPG - 06/02/2018
         nQtdAux := ED9->ED9_PESO
      Else
         nQtdAux := AVTransUnid(INT_CE->NCEUMN,ED3->ED3_UMPROD,ED3->ED3_PROD,Val(Int_CE->NCEQTDN),.F.)
      EndIf
      ED3->(RECLOCK("ED3",.F.))
      //Saldo Valor
      ED3->ED3_SALDO -= nQtdAux
      If AvVldUn(ED9->ED9_UM) // -- MPG - 06/02/2018 
         ED3->ED3_SALNCM -= ED9->ED9_PESO
      Else
         ED3->ED3_SALNCM -= AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,nQtdAux)
      EndIf
      ED9->ED9_QT_AC  := nQtdAux
      ED3->(msUnlock())
   EndIf
EndIf

Return lReto


*----------------------*
FUNCTION IN100RE_Externos()//AWR - 08/04/2009
*----------------------*
AADD(TB_Cols,{"NNREXPORT"                    ,"",AVSX3("ED9_EXPORT",5)})                        //CNPJ Exportador
AADD(TB_Cols,{"NNRRE"                        ,"",AVSX3("ED9_RE",5)})                            //R.E.
AADD(TB_Cols,{"NNRPOSICA"                    ,"",AVSX3("ED9_POSICA",5)})                        //Posicao
AADD(TB_Cols,{{||IN100CTD(INT_NR->NNRDTRE)}  ,"",AVSX3("ED9_DTRE",5)})                          //Data R.E.
AADD(TB_Cols,{{||IN100CTD(INT_NR->NNRDTEMB)} ,"",AVSX3("ED9_DTEMB",5)})                         //Data Emb.
AADD(TB_Cols,{"NNRPROD"                      ,"",AVSX3("ED9_PROD",5)})                          //Produto Exportação
AADD(TB_Cols,{"NNRDESC"                      ,"",AVSX3("ED9_DESC",5)})                          //Descricao
AADD(TB_Cols,{{||VAL(INT_NR->NNRPESO)}       ,"",AVSX3("ED9_PESO",5),AVSX3("ED9_PESO",6)})      //Peso Unit. (KG)
AADD(TB_Cols,{{||VAL(INT_NR->NNRQTD)}        ,"",AVSX3("ED9_QTD",5),AVSX3("ED9_QTD",6)})        //Quantidade unidade venda
AADD(TB_Cols,{"NNRUM"                        ,"",AVSX3("ED9_UM",5)})                            //Unid. Medida venda
AADD(TB_Cols,{{||VAL(INT_NR->NNRVL_FOB)}     ,"",AVSX3("ED9_VL_FOB",5),AVSX3("ED9_VL_FOB",6)})  //Valor FOB em US$
AADD(TB_Cols,{{||VAL(INT_NR->NNRTX_MOE)}     ,"",AVSX3("ED9_TX_MOE",5),AVSX3("ED9_TX_MOE",6)})  //Taxa Moeda venda
AADD(TB_Cols,{{||VAL(INT_NR->NNRVALMOE)}     ,"",AVSX3("ED9_VALMOE",5),AVSX3("ED9_VALMOE",6)})  //Vl. FOB Moeda venda
AADD(TB_Cols,{"NNRMOEDA"                     ,"",AVSX3("ED9_MOEDA",5)})                         //Moeda venda
AADD(TB_Cols,{"NNRNF"                        ,"",AVSX3("ED9_NF",5)})                            //Nota Fiscal
AADD(TB_Cols,{"NNRSERIE"                     ,"",AVSX3("ED9_SERIE",5)})                         //Serie
AADD(TB_Cols,{{||IN100CTD(INT_NR->NNREMISSA)},"",AVSX3("ED9_EMISSA",5)})                        //DT Emissao
AADD(TB_Cols,{"NNRNCM"                       ,"",AVSX3("ED9_NCM",5)})                           //NCM
AADD(TB_Cols,{{||VAL(INT_NR->NNRVAL_SE)}     ,"",AVSX3("ED9_VAL_SE",5),AVSX3("ED9_VAL_SE",6)})  //Valor s/ cobertura (US$)
AADD(TB_Cols,{{||VAL(INT_NR->NNRVALCOM)}     ,"",AVSX3("ED9_VALCOM",5),AVSX3("ED9_VALCOM",6)})  //Valor comissao agente
AADD(TB_Cols,{{||VAL(INT_NR->NNRVALORI)}     ,"",AVSX3("ED9_VALORI",5),AVSX3("ED9_VALORI",6)})  //Valor na Cond. Venda
AADD(TB_Cols,{"NNRUMNCM"                     ,"",AVSX3("ED9_UMNCM",5)})                         //Unid. Medida NCM
AADD(TB_Cols,{{||VAL(INT_NR->NNRQTDNCM)}     ,"",AVSX3("ED9_QTDNCM",5),AVSX3("ED9_QTDNCM",6)})  //Qtd. Unid. NCM
AADD(TB_Cols,{{||VAL(INT_NR->NNRTX_USS)}     ,"",AVSX3("ED9_TX_USS",5),AVSX3("ED9_TX_USS",6)})  //Taxa US$ Dt. Emb.
AADD(TB_Cols,{{||IN100CTD(INT_NR->NNRDTAVRB)},"",AVSX3("ED9_DTAVRB",5)})                        //Data Averbação S.D.

// BAK - Integração de RE`s Externos - 24/08/2011
AADD(TB_Cols,{{|| ConvInfo("ED9_AC",INT_NR->NNRAC)},"",AVSX3("ED9_AC",5)})                        //Ato Concessório
AADD(TB_Cols,{{|| ConvInfo("ED9_SEQSIS",INT_NR->NNRSEQSIS)},"",AVSX3("ED9_SEQSIS",5)})            //Seq. Ato Concessório 


TBRCols:={}
AADD(TBRCols,{{||IN100Status()}           ,STR0019 }) //Status
AADD(TBRCols,{{||IN100TIPO() }            ,STR0020 }) //Tipo
AADD(TBRCols,{{||IN100CTD(EVAL(bDtInteg))},STR0021 }) //Dt Integ
AADD(TBRCols,{"NNREXPORT"                 ,AVSX3("ED9_EXPORT",5)})  //CNPJ Exportador
AADD(TBRCols,{"NNRRE"                     ,AVSX3("ED9_RE",5)})      //R.E.
AADD(TBRCols,{"NNRPOSICA"                 ,AVSX3("ED9_POSICA",5)})  //Posicao
AADD(TBRCols,{{||IN100CTD(INT_NR->NNRDTRE)} ,AVSX3("ED9_DTRE",5)})  //Data R.E.
AADD(TBRCols,{{||IN100CTD(INT_NR->NNRDTEMB)},AVSX3("ED9_DTEMB",5)}) //Data Emb.
AADD(TBRCols,{"NNRPROD"                     ,AVSX3("ED9_PROD",5)})  //Produto Exportação
AADD(TBRCols,{"NNRDESC"                     ,AVSX3("ED9_DESC",5)})  //Descricao

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLNR")
ENDIF

AADD(TBRCols,{{||IN100E_MSG(.T.)}   ,STR0022}) //Mensagem
AADD(TB_Cols,{{||IN100E_Msg(.T.)},"",STR0022}) //Mensagem

RETURN .T.

*--------------------*
FUNCTION IN100LerNR()//AWR - 08/04/2009
*--------------------*
LOCAL lPreenchido:=.T.,lAchou
// BAK - Integração de RE`s Externos - 24/08/2011
// Campos calculados na função Re400Vinc
// ED9_QT_AC
// ED9_VL_AC
Local aCposIntED9 := {}
Private lMsErroAuto := .F. 

If !AvFlags("INDICEED9")
   Return .F.
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERNR")
ENDIF     

IF Empty(INT_NR->NNRRE)
   EVAL(bmsg,"R.E. nao preenchida")
   lPreenchido:=.F.
ENDIF

IF Empty(INT_NR->NNRPOSICA)
   EVAL(bmsg,"Posicao do produto do RE nao preenchida")
   lPreenchido:=.F.
ENDIF

ED9->(DBSETORDER(4)) // ED9_FILIAL+ED9_RE+ED9_POSICA 
lAchou:= ED9->(DBSEEK(cFilED9+INT_NR->NNRRE+INT_NR->NNRPOSICA))

//Não pode ser integrada uma alteração nem uma exclusão quando o registro já possuir o campo ED9_AC ou o campo ED9_SALISE preenchido.
IF lAchou
   IF !EMPTY(ED9->ED9_AC)
      EVAL(bmsg,STR0163)//"RE + Posicao ja tem ato concessorio"
   ENDIF
   IF !EMPTY(ED9->ED9_SALISE)
      EVAL(bmsg,STR0164)//"RE + Posicao ja tem saldo insencao preenchido"
   ENDIF
ENDIF

If Int_NR->NNRTIPO = INCLUSAO

   IF lAchou
      EVAL(bmsg,STR0165)//"RE + Posicao ja cadastrados"
   ENDIF

ELSEIF Int_NR->NNRTIPO = ALTERACAO

   IF !lAchou .AND. lPreenchido
      EVAL(bmsg,STR0166)//"RE + Posicao nao cadastrados"
   ENDIF

ELSEIF Int_NR->NNRTIPO == EXCLUSAO

   IF !lAchou .AND. lPreenchido
      EVAL(bmsg,STR0167)//"RE + Posicao nao cadastrados"
   ENDIF

   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALNR")
   ENDIF

   IN100VerErro(cErro,cAviso)
   IF Int_NR->NNRINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF

   RETURN .F.

ENDIF                

IF Empty(INT_NR->NNREXPORT)
   EVAL(bmsg,STR0168)//"CNPJ Exportador nao preenchido"
ELSE
   SA2->(DBSETORDER(3))
   IF !SA2->(DBSEEK(cFilSA2+INT_NR->NNREXPORT))
      EVAL(bmsg,STR0169)//"CNPJ Exportador nao encontrado"
   ENDIF
ENDIF

IF !IN100CTD(INT_NR->NNRDTRE,.T.)
   EVAL(bmsg,STR0170)//"Data do RE invalida"
ENDIF
IF !IN100CTD(INT_NR->NNRDTEMB,.T.)
   EVAL(bmsg,STR0171)//"Data do Embarque invalida"
ENDIF
IF Empty(INT_NR->NNRPROD)
   EVAL(bmsg,STR0172)//"Codigo Produto Exportacao nao preenchida"
ELSE
   SB1->(DBSETORDER(1))
   IF !SB1->(DBSEEK(cFilSB1+RTRIM(INT_NR->NNRPROD)))
      EVAL(bmsg,STR0173)//"Codigo Produto Exportacao nao encontrado"
   ENDIF
ENDIF
IF Empty(INT_NR->NNRDESC)
   EVAL(bmsg,STR0174)//"Descricao do Produto Exportacao nao preenchida"
ENDIF
IF VAL(INT_NR->NNRPESO) <= 0
   EVAL(bmsg,STR0175)//"Peso invalido"
ENDIF
IF VAL(INT_NR->NNRQTD) <= 0
   EVAL(bmsg,STR0176)//"Quantidade invalida"
ENDIF
IF Empty(INT_NR->NNRUM)
   EVAL(bmsg,STR0177)//"Unidade Medida de venda nao preenchida"
ELSE
   SAH->(DBSETORDER(1))
   IF !SAH->(DBSEEK(cFilSAH+INT_NR->NNRUM))
      EVAL(bmsg,STR0178)//"Unidade Medida de venda nao encontrada"
   ENDIF
ENDIF
IF VAL(INT_NR->NNRVL_FOB) <= 0
   EVAL(bmsg,STR0179)//"Valor FOB em US$ invalido"
ENDIF
IF VAL(INT_NR->NNRTX_MOE) <= 0
   EVAL(bmsg,STR0180)//"Taxa da Moeda de venda invalida"
ENDIF
IF VAL(INT_NR->NNRVALMOE) <= 0
   EVAL(bmsg,STR0181)//"Valor FOB da Moeda de venda invalida"
ENDIF
IF Empty(INT_NR->NNRMOEDA)
   EVAL(bmsg,STR0182)//"Moeda de venda nao preenchida"
ELSE
   SYF->(DBSETORDER(1))
   IF !SYF->(DBSEEK(cFilSYF+INT_NR->NNRMOEDA))
      EVAL(bmsg,STR0183)//"Moeda nao encontrada"
   ENDIF
ENDIF

//IF Empty(INT_NR->NNRNF)   // Campo nao é obrigatorio
//IF Empty(INT_NR->NNRSERIE)// Campo nao é obrigatorio
IF !Empty(INT_NR->NNREMISSA)// Campo nao é obrigatorio, só valido se preenchido
   IF !IN100CTD(INT_NR->NNREMISSA,.T.)
      EVAL(bmsg,STR0184)//"Data da Emissao da NF invalida"
   ENDIF
ENDIF

IF Empty(INT_NR->NNRNCM)
   EVAL(bmsg,STR0185)//"NCM nao preenchida"
ELSE
   SYD->(DBSETORDER(1))
   IF !SYD->(DBSEEK(cFilSYD+INT_NR->NNRNCM))
      EVAL(bmsg,STR0186)//"NCM nao encontrada"
   ENDIF
ENDIF

IF VAL(INT_NR->NNRVAL_SE) < 0// Campo nao é obrigatorio
   EVAL(bmsg,STR0187)//"Valor s/ cobertura (US$) negativo"
ENDIF
IF VAL(INT_NR->NNRVALCOM) < 0// Campo nao é obrigatorio
   EVAL(bmsg,STR0188)//"Valor da comissao do agente negativo"
ENDIF

IF VAL(INT_NR->NNRVALORI) <= 0
   EVAL(bmsg,STR0189)//"Valor na Condicao de venda invalido"
ENDIF
IF Empty(INT_NR->NNRUMNCM)
   EVAL(bmsg,STR0190)//"Unidade Medida da NCM nao preenchida"
ELSE
   SAH->(DBSETORDER(1))
   IF !SAH->(DBSEEK(cFilSAH+INT_NR->NNRUMNCM))
      EVAL(bmsg,STR0191)//"Unidade Medida da NCM nao encontrada"
   ENDIF
ENDIF
IF VAL(INT_NR->NNRQTDNCM) <= 0
   EVAL(bmsg,STR0192)//"Quantidade Unidade NCM invalido"
ENDIF
IF VAL(INT_NR->NNRTX_USS) <= 0
   EVAL(bmsg,STR0193)//"Taxa US$ Dt. Emb. invalida"
ENDIF
IF !IN100CTD(INT_NR->NNRDTAVRB,.T.)
   EVAL(bmsg,STR0194)//"Data de Averbacao S.D. invalida"
ENDIF

// BAK - Integração de RE`s Externos - 24/08/2011
If !Empty(INT_NR->NNRAC) .And. !Empty(INT_NR->NNRSEQSIS)
   If INT_NR->NNRTIPO == INCLUSAO
      Aadd(aCposIntED9,{"ED9_DT_INT" , ConvInfo("ED9_DT_INT",INT_NR->NNRINT_DT)})
      Aadd(aCposIntED9,{"ED9_EXPORT" , ConvInfo("ED9_EXPORT",INT_NR->NNREXPORT)})
      Aadd(aCposIntED9,{"ED9_RE"     , ConvInfo("ED9_RE",INT_NR->NNRRE)})
      Aadd(aCposIntED9,{"ED9_POSICA" , ConvInfo("ED9_POSICA",INT_NR->NNRPOSICA)})
      Aadd(aCposIntED9,{"ED9_DTRE"   , ConvInfo("ED9_DTRE",INT_NR->NNRDTRE)})
      Aadd(aCposIntED9,{"ED9_DTEMB"  , ConvInfo("ED9_DTEMB",INT_NR->NNRDTEMB)})
      Aadd(aCposIntED9,{"ED9_PROD"   , ConvInfo("ED9_PROD",INT_NR->NNRPROD)})
      Aadd(aCposIntED9,{"ED9_DESC"   , ConvInfo("ED9_DESC",INT_NR->NNRDESC)})
      Aadd(aCposIntED9,{"ED9_PESO"   , ConvInfo("ED9_PESO",INT_NR->NNRPESO)})
      Aadd(aCposIntED9,{"ED9_QTD"    , ConvInfo("ED9_QTD",INT_NR->NNRQTD)})
      Aadd(aCposIntED9,{"ED9_UM"     , ConvInfo("ED9_UM",INT_NR->NNRUM)})
      Aadd(aCposIntED9,{"ED9_VL_FOB" , ConvInfo("ED9_VL_FOB",INT_NR->NNRVL_FOB)})
      Aadd(aCposIntED9,{"ED9_TX_MOE" , ConvInfo("ED9_TX_MOE",INT_NR->NNRTX_MOE)})
      Aadd(aCposIntED9,{"ED9_VALMOE" , ConvInfo("ED9_VALMOE",INT_NR->NNRVALMOE)})
      Aadd(aCposIntED9,{"ED9_MOEDA"  , ConvInfo("ED9_MOEDA",INT_NR->NNRMOEDA)})
      Aadd(aCposIntED9,{"ED9_NF"     , ConvInfo("ED9_NF",INT_NR->NNRNF)})
      Aadd(aCposIntED9,{"ED9_SERIE"  , ConvInfo("ED9_SERIE",INT_NR->NNRSERIE)})
      Aadd(aCposIntED9,{"ED9_EMISSA" , ConvInfo("ED9_EMISSA",INT_NR->NNREMISSA)})
      Aadd(aCposIntED9,{"ED9_NCM"    , ConvInfo("ED9_NCM",INT_NR->NNRNCM)})
      Aadd(aCposIntED9,{"ED9_VAL_SE" , ConvInfo("ED9_VAL_SE",INT_NR->NNRVAL_SE)})
      Aadd(aCposIntED9,{"ED9_VALCOM" , ConvInfo("ED9_VALCOM",INT_NR->NNRVALCOM)})
      Aadd(aCposIntED9,{"ED9_VALORI" , ConvInfo("ED9_VALORI",INT_NR->NNRVALORI)})
      Aadd(aCposIntED9,{"ED9_UMNCM"  , ConvInfo("ED9_UMNCM",INT_NR->NNRUMNCM)})
      Aadd(aCposIntED9,{"ED9_QTDNCM" , ConvInfo("ED9_QTDNCM",INT_NR->NNRQTDNCM)})
      Aadd(aCposIntED9,{"ED9_TX_USS" , ConvInfo("ED9_TX_USS",INT_NR->NNRTX_USS)})
      Aadd(aCposIntED9,{"ED9_DTAVRB" , ConvInfo("ED9_DTAVRB",INT_NR->NNRDTAVRB)})
      Aadd(aCposIntED9,{"ED9_AC"     , ConvInfo("ED9_AC",INT_NR->NNRAC)})
      Aadd(aCposIntED9,{"ED9_SEQSIS" , ConvInfo("ED9_SEQSIS",INT_NR->NNRSEQSIS)})

      MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.T.,.T.,6)

   // Caso seja alteração ou exclusao os campos do Ato Concessório e SeqSis não devem ser passados no array aCposIntED9
   ElseIf INT_NR->NNRTIPO == ALTERACAO .Or. Int_NR->NNRTIPO == EXCLUSAO
      
      Aadd(aCposIntED9,{"ED9_DT_INT" , ConvInfo("ED9_DT_INT",INT_NR->NNRINT_DT)})
      Aadd(aCposIntED9,{"ED9_EXPORT" , ConvInfo("ED9_EXPORT",INT_NR->NNREXPORT)})
      Aadd(aCposIntED9,{"ED9_RE"     , ConvInfo("ED9_RE",INT_NR->NNRRE)})
      Aadd(aCposIntED9,{"ED9_POSICA" , ConvInfo("ED9_POSICA",INT_NR->NNRPOSICA)})
      Aadd(aCposIntED9,{"ED9_DTRE"   , ConvInfo("ED9_DTRE",INT_NR->NNRDTRE)})
      Aadd(aCposIntED9,{"ED9_DTEMB"  , ConvInfo("ED9_DTEMB",INT_NR->NNRDTEMB)})
      Aadd(aCposIntED9,{"ED9_PROD"   , ConvInfo("ED9_PROD",INT_NR->NNRPROD)})
      Aadd(aCposIntED9,{"ED9_DESC"   , ConvInfo("ED9_DESC",INT_NR->NNRDESC)})
      Aadd(aCposIntED9,{"ED9_PESO"   , ConvInfo("ED9_PESO",INT_NR->NNRPESO)})
      Aadd(aCposIntED9,{"ED9_QTD"    , ConvInfo("ED9_QTD",INT_NR->NNRQTD)})
      Aadd(aCposIntED9,{"ED9_UM"     , ConvInfo("ED9_UM",INT_NR->NNRUM)})
      Aadd(aCposIntED9,{"ED9_VL_FOB" , ConvInfo("ED9_VL_FOB",INT_NR->NNRVL_FOB)})
      Aadd(aCposIntED9,{"ED9_TX_MOE" , ConvInfo("ED9_TX_MOE",INT_NR->NNRTX_MOE)})
      Aadd(aCposIntED9,{"ED9_VALMOE" , ConvInfo("ED9_VALMOE",INT_NR->NNRVALMOE)})
      Aadd(aCposIntED9,{"ED9_MOEDA"  , ConvInfo("ED9_MOEDA",INT_NR->NNRMOEDA)})
      Aadd(aCposIntED9,{"ED9_NF"     , ConvInfo("ED9_NF",INT_NR->NNRNF)})
      Aadd(aCposIntED9,{"ED9_SERIE"  , ConvInfo("ED9_SERIE",INT_NR->NNRSERIE)})
      Aadd(aCposIntED9,{"ED9_EMISSA" , ConvInfo("ED9_EMISSA",INT_NR->NNREMISSA)})
      Aadd(aCposIntED9,{"ED9_NCM"    , ConvInfo("ED9_NCM",INT_NR->NNRNCM)})
      Aadd(aCposIntED9,{"ED9_VAL_SE" , ConvInfo("ED9_VAL_SE",INT_NR->NNRVAL_SE)})
      Aadd(aCposIntED9,{"ED9_VALCOM" , ConvInfo("ED9_VALCOM",INT_NR->NNRVALCOM)})
      Aadd(aCposIntED9,{"ED9_VALORI" , ConvInfo("ED9_VALORI",INT_NR->NNRVALORI)})
      Aadd(aCposIntED9,{"ED9_UMNCM"  , ConvInfo("ED9_UMNCM",INT_NR->NNRUMNCM)})
      Aadd(aCposIntED9,{"ED9_QTDNCM" , ConvInfo("ED9_QTDNCM",INT_NR->NNRQTDNCM)})
      Aadd(aCposIntED9,{"ED9_TX_USS" , ConvInfo("ED9_TX_USS",INT_NR->NNRTX_USS)})
      Aadd(aCposIntED9,{"ED9_DTAVRB" , ConvInfo("ED9_DTAVRB",INT_NR->NNRDTAVRB)})

      MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.T.,.F.,6)

   EndIf
EndIf

// BAK - Integração de RE`s Externos - 24/08/2011
If lMsErroAuto .And. ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
   Eval(bmsg,MemoRead(NomeAutoLog()))
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALNR")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_NR->NNRINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

Return .T.

*--------------------*
FUNCTION IN100GrvNR()//AWR - 08/04/2009
*--------------------*
Local lAchou:= .F.

// BAK - Integração de RE`s Externos - 24/08/2011
Local aCposIntED9 := {}
Local nPos := 0
Private lMsErroAuto := .F. 

Aadd(aCposIntED9,{"ED9_DT_INT" , ConvInfo("ED9_DT_INT",INT_NR->NNRINT_DT)})
Aadd(aCposIntED9,{"ED9_EXPORT" , ConvInfo("ED9_EXPORT",INT_NR->NNREXPORT)})
Aadd(aCposIntED9,{"ED9_RE"     , ConvInfo("ED9_RE",INT_NR->NNRRE)})
Aadd(aCposIntED9,{"ED9_POSICA" , ConvInfo("ED9_POSICA",INT_NR->NNRPOSICA)})
Aadd(aCposIntED9,{"ED9_DTRE"   , ConvInfo("ED9_DTRE",INT_NR->NNRDTRE)})
Aadd(aCposIntED9,{"ED9_DTEMB"  , ConvInfo("ED9_DTEMB",INT_NR->NNRDTEMB)})
Aadd(aCposIntED9,{"ED9_PROD"   , ConvInfo("ED9_PROD",INT_NR->NNRPROD)})
Aadd(aCposIntED9,{"ED9_DESC"   , ConvInfo("ED9_DESC",INT_NR->NNRDESC)})
Aadd(aCposIntED9,{"ED9_PESO"   , ConvInfo("ED9_PESO",INT_NR->NNRPESO)})
Aadd(aCposIntED9,{"ED9_QTD"    , ConvInfo("ED9_QTD",INT_NR->NNRQTD)})
Aadd(aCposIntED9,{"ED9_UM"     , ConvInfo("ED9_UM",INT_NR->NNRUM)})
Aadd(aCposIntED9,{"ED9_VL_FOB" , ConvInfo("ED9_VL_FOB",INT_NR->NNRVL_FOB)})
Aadd(aCposIntED9,{"ED9_TX_MOE" , ConvInfo("ED9_TX_MOE",INT_NR->NNRTX_MOE)})
Aadd(aCposIntED9,{"ED9_VALMOE" , ConvInfo("ED9_VALMOE",INT_NR->NNRVALMOE)})
Aadd(aCposIntED9,{"ED9_MOEDA"  , ConvInfo("ED9_MOEDA",INT_NR->NNRMOEDA)})
Aadd(aCposIntED9,{"ED9_NF"     , ConvInfo("ED9_NF",INT_NR->NNRNF)})
Aadd(aCposIntED9,{"ED9_SERIE"  , ConvInfo("ED9_SERIE",INT_NR->NNRSERIE)})
Aadd(aCposIntED9,{"ED9_EMISSA" , ConvInfo("ED9_EMISSA",INT_NR->NNREMISSA)})
Aadd(aCposIntED9,{"ED9_NCM"    , ConvInfo("ED9_NCM",INT_NR->NNRNCM)})
Aadd(aCposIntED9,{"ED9_VAL_SE" , ConvInfo("ED9_VAL_SE",INT_NR->NNRVAL_SE)})
Aadd(aCposIntED9,{"ED9_VALCOM" , ConvInfo("ED9_VALCOM",INT_NR->NNRVALCOM)})
Aadd(aCposIntED9,{"ED9_VALORI" , ConvInfo("ED9_VALORI",INT_NR->NNRVALORI)})
Aadd(aCposIntED9,{"ED9_UMNCM"  , ConvInfo("ED9_UMNCM",INT_NR->NNRUMNCM)})
Aadd(aCposIntED9,{"ED9_QTDNCM" , ConvInfo("ED9_QTDNCM",INT_NR->NNRQTDNCM)})
Aadd(aCposIntED9,{"ED9_TX_USS" , ConvInfo("ED9_TX_USS",INT_NR->NNRTX_USS)})
Aadd(aCposIntED9,{"ED9_DTAVRB" , ConvInfo("ED9_DTAVRB",INT_NR->NNRDTAVRB)})
Aadd(aCposIntED9,{"ED9_AC"     , ConvInfo("ED9_AC",INT_NR->NNRAC)})
Aadd(aCposIntED9,{"ED9_SEQSIS" , ConvInfo("ED9_SEQSIS",INT_NR->NNRSEQSIS)})

ED9->(DBSETORDER(4))
lAchou:= ED9->(DBSEEK(cFilED9+INT_NR->NNRRE+INT_NR->NNRPOSICA))

IF Int_NR->NNRTIPO = EXCLUSAO
   // BAK - Integração de RE`s Externos - 24/08/2011
   If (nPos := aScan(aCposIntED9, {|x| "ED9_AC" == AllTrim(Upper(x[1]))})) > 0
      aDel(aCposIntED9, nPos)
      aSize(aCposIntED9, Len(aCposIntED9)-1)
   EndIf
   If (nPos := aScan(aCposIntED9, {|x| "ED9_SEQSIS" == AllTrim(Upper(x[1]))})) > 0
      aDel(aCposIntED9, nPos)
      aSize(aCposIntED9, Len(aCposIntED9)-1)
   EndIf
   MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.F.,.F.,6)

   IF lAchou .And. lMsErroAuto
      ED9->(RecLock("ED9",.F.))
      ED9->(DBDELETE())
   ENDIF

   RETURN .F.
ENDIF

IF Int_NR->NNRTIPO = ALTERACAO .And. !lAchou
   RETURN .F.
ENDIF

Begin Transaction

IF Int_NR->NNRTIPO = INCLUSAO

   IN100RecLock("ED9")
   ED9->ED9_FILIAL := cFilED9

ELSEIF Int_NR->NNRTIPO = ALTERACAO

   ED9->(RecLock("ED9",.F.))

ENDIF

IF(!Empty(INT_NR->NNREXPORT     ),ED9->ED9_EXPORT := INT_NR->NNREXPORT     ,)//CNPJ Exportador
IF(!Empty(INT_NR->NNRRE         ),ED9->ED9_RE     := INT_NR->NNRRE         ,)//R.E.
IF(!Empty(INT_NR->NNRPOSICA     ),ED9->ED9_POSICA := INT_NR->NNRPOSICA     ,)//Posicao
IF(!Empty(INT_NR->NNRDTRE       ),ED9->ED9_DTRE   := IN100CTD(INT_NR->NNRDTRE) ,)//Data R.E.
IF(!Empty(INT_NR->NNRDTEMB      ),ED9->ED9_DTEMB  := IN100CTD(INT_NR->NNRDTEMB),)//Data Emb.
IF(!Empty(INT_NR->NNRPROD       ),ED9->ED9_PROD   := INT_NR->NNRPROD       ,)//Produto Exportação
IF(!Empty(INT_NR->NNRDESC       ),ED9->ED9_DESC   := INT_NR->NNRDESC       ,)//Descricao
IF(!Empty(VAL(INT_NR->NNRPESO)  ),ED9->ED9_PESO   := VAL(INT_NR->NNRPESO)  ,)//Peso Unit. (KG)
IF(!Empty(VAL(INT_NR->NNRQTD)   ),ED9->ED9_QTD    := VAL(INT_NR->NNRQTD)   ,)//Quantidade unidade venda
IF(!Empty(INT_NR->NNRUM         ),ED9->ED9_UM     := INT_NR->NNRUM         ,)//Unid. Medida venda
IF(!Empty(VAL(INT_NR->NNRVL_FOB)),ED9->ED9_VL_FOB := VAL(INT_NR->NNRVL_FOB),)//Valor FOB em US$
IF(!Empty(VAL(INT_NR->NNRTX_MOE)),ED9->ED9_TX_MOE := VAL(INT_NR->NNRTX_MOE),)//Taxa Moeda venda
IF(!Empty(VAL(INT_NR->NNRVALMOE)),ED9->ED9_VALMOE := VAL(INT_NR->NNRVALMOE),)//Vl. FOB Moeda venda
IF(!Empty(INT_NR->NNRMOEDA      ),ED9->ED9_MOEDA  := INT_NR->NNRMOEDA      ,)//Moeda venda
IF(!Empty(INT_NR->NNRNF         ),ED9->ED9_NF     := INT_NR->NNRNF         ,)//Nota Fiscal
IF(!Empty(INT_NR->NNRSERIE      ),ED9->ED9_SERIE  := INT_NR->NNRSERIE      ,)//Serie
IF(!Empty(INT_NR->NNREMISSA     ),ED9->ED9_EMISSA := IN100CTD(INT_NR->NNREMISSA),)//DT Emissao
IF(!Empty(INT_NR->NNRNCM        ),ED9->ED9_NCM    := INT_NR->NNRNCM        ,)//NCM
IF(!Empty(VAL(INT_NR->NNRVAL_SE)),ED9->ED9_VAL_SE := VAL(INT_NR->NNRVAL_SE),)//Valor s/ cobertura (US$)
IF(!Empty(VAL(INT_NR->NNRVALCOM)),ED9->ED9_VALCOM := VAL(INT_NR->NNRVALCOM),)//Valor comissao agente
IF(!Empty(VAL(INT_NR->NNRVALORI)),ED9->ED9_VALORI := VAL(INT_NR->NNRVALORI),)//Valor na Cond. Venda
IF(!Empty(INT_NR->NNRUMNCM      ),ED9->ED9_UMNCM  := INT_NR->NNRUMNCM      ,)//Unid. Medida NCM
IF(!Empty(VAL(INT_NR->NNRQTDNCM)),ED9->ED9_QTDNCM := VAL(INT_NR->NNRQTDNCM),)//Qtd. Unid. NCM
IF(!Empty(VAL(INT_NR->NNRTX_USS)),ED9->ED9_TX_USS := VAL(INT_NR->NNRTX_USS),)//Taxa US$ Dt. Emb.
IF(!Empty(INT_NR->NNRDTAVRB     ),ED9->ED9_DTAVRB := IN100CTD(INT_NR->NNRDTAVRB),)//Data Averbação S.D.
IF(!Empty(INT_NR->NNRINT_DT     ),ED9->ED9_DT_INT := IN100CTD(INT_NR->NNRINT_DT),)//Data da Integracao

SerieNfId("ED9",1,"ED9_SERIE",IN100CTD(INT_NR->NNREMISSA),EasyGParam("MV_ESPEIC",,'NFE'),INT_NR->NNRSERIE)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVNR")
EndIf

ED9->(MSUNLOCK())

// BAK - Integração de RE`s Externos - 24/08/2011
If !Empty(INT_NR->NNRAC) .And. !Empty(INT_NR->NNRSEQSIS)

   If INT_NR->NNRTIPO == INCLUSAO
      MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.F.,.T.,6)

   ElseIf INT_NR->NNRTIPO == ALTERACAO

      // Primeira chamada - lCompr := .F. 
      If (nPos := aScan(aCposIntED9, {|x| "ED9_AC" == AllTrim(Upper(x[1]))})) > 0
         aDel(aCposIntED9, nPos)
         aSize(aCposIntED9, Len(aCposIntED9)-1)
      EndIf
      If (nPos := aScan(aCposIntED9, {|x| "ED9_SEQSIS" == AllTrim(Upper(x[1]))})) > 0
         aDel(aCposIntED9, nPos)
         aSize(aCposIntED9, Len(aCposIntED9)-1)
      EndIf
      MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.F.,.F.,6)   

      // Segunda chamada -lCompr := .T.
      Aadd(aCposIntED9,{"ED9_AC"     , ConvInfo("ED9_AC",INT_NR->NNRAC)})
      Aadd(aCposIntED9,{"ED9_SEQSIS" , ConvInfo("ED9_SEQSIS",INT_NR->NNRSEQSIS)})      
      MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aCposIntED9,.F.,.T.,6)
   EndIf

   If lMsErroAuto
      DisarmTransaction()
   Else
      ED9->(DBSETORDER(4))
      If ED9->(DBSEEK(cFilED9+INT_NR->NNRRE+INT_NR->NNRPOSICA))
         If ED9->(RecLock("ED9",.F.))
            ED9->ED9_AC     := INT_NR->NNRAC
            ED9->ED9_SEQSIS := INT_NR->NNRSEQSIS
            ED9->(MSUNLOCK())
         EndIf
      EndIf
   EndIf
 
EndIf 

End Transaction

Return .T. 

Static Function ConvInfo(cCampo,cInfo)
Local xRet 

xRet := AvConvert("C",AvSx3(cCampo,2),AvSx3(cCampo,3),cInfo)

Return xRet
