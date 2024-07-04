#INCLUDE "EicFi400.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"
//Funcao    : EICFI400()
//Autor     : ALEX WALLAUER (AWR)
//Data      : 21 Nov 2000
//Descricao : Ponto de entrada Antes e Depois das gravacoes do PO e da DI
//Cliente   : America Latina menos o Brasil

#DEFINE	G_NAO_MOEDA			    1
#DEFINE	G_TITULO_EXISTE	        2
#DEFINE ERROTAMLOG              100
//Codigos de retorno da delecao

//** GFC - 07/03/06 - Eventos de cambio
#define PRINCIPAL    "101"
#define FRETE        "102"
#define SEGURO       "103"
#define COM_REMETER  "120"
#define COM_CTAGRAF  "121"
#define COM_ADEDUZIR "122"

#define EV_EMBARQUE  "600"
#define TIPO_MODULO  "IMPORT"
//**

STATIC lAlteraDup, aPos, nSld_Atual,  nSld_Agerar,cMsgLogDup, lBaixada:=.F.,aAlterados,lForcaGerar
STATIC lTitFreteIAE,lTitSeguroIAE,aTitInvoiceIAE,lHEADERAberto
STATIC lAltFrete,lAltSeguro,aAltInvoice,lAltodasInvoice,aSWBChavesTit,aSWBCampos
STATIC oIntProv

*-------------------------------------------*
FUNCTION EICFI400(cParamIXB,xParamAux)
*-------------------------------------------*
Local nOldRecDI
Local lBaixa := .T., aTab := {}, wind := 0, nTab, L, I
Local lTemAdto										//TRP - 20/03/09
Local aOrdSE2Frete := {}  							//TRP - 04/08/2011
Local cChaveW6     := ""							//TRP - 04/08/2011
Private lSair      := .F., cParametro := cParamIXB	//AWR - 25/10/2004 - Variaveis usadas no Rdmake
Private cForn      := ''
Private lWB_ALTERA := SWB->(FieldPos("WB_ALTERA")) > 0  //TRP-29/04/08
Private dDtEmis    := FI400DtEmInvCpo()//Iif(Empty(EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")),"SW9->W9_DT_EMIS",EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS"))     //NCF - 09/04/2010 - Caso cliente deixe conteúdo do parâmetro em branco //04/08/17
Private dDtEmiPA   := FI400DtEmAdiCpo() //Iif(Empty(EasyGParam("MV_DTEMIPA",,"SWB->WB_DT_DESE")),"SWB->WB_DT_DESE",EasyGParam("MV_DTEMIPA",,"SWB->WB_DT_DESE"))//04/08/17
Private lAvIntDesp := AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC")
Private lMicrosiga := EasyGParam("MV_EASYFIN",,"N") $ cSim //!(GetNewPar("MV_EASYFIN","N") = "N" .OR. EasyGParam("MV_EASY",,"N") = "N")
Private oIntPr
Private lCposAdto  := .T./*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
Private nAutoNum := 0 // GFP - 06/09/2013
Private cUltParc := ""  // GFP - 20/01/2014
Private lAltera  := .F. // LGS-24/09/2014

IF !lMicrosiga .AND. !lAvIntDesp
   lSairFI400:=.F.
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

IF !lAvIntDesp .AND. EasyGParam("MV_EASYFIN",,"N") $ cNao
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"INICIO"),) //AWR - 25/10/2004

IF lSair //AWR - 25/10/2004
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

//**IGOR CHIBA 29/09/09 verificando se integra dados parar ERP financeiro
Private LCAMBIO_EIC:= AVFLAGS('AVINT_CAMBIO_EIC')
//**

Private cNaoGera   := "1,5"
Private cTipAuto   := "1"+IF(cPaisLoc == "CHI", ',2', '')
Private lGeraPO    := IF(GetNewPar("MV_EASYFPO","S") == "S", .T., .F.) .OR. lAvIntDesp
Private lGerPrDI   := IF(GetNewPar("MV_EASYFDI","S") == "S", .T., .F.) .OR. lAvIntDesp
Private c_DuplDoc  := GetNewPar("MV_DUPLDOC", " ")
Private cTipo_Adt  := ""
Private lAlteraSE2 := .F.	// GFP - 08/03/2013 - Variavel para PE
PRIVATE lDespesa   := .F.	// LGS - 11/10/13
PRIVATE lFilDa :=EasyGParam("MV_FIL_DA")  // GFP - 11/12/2013
Private lReturn := .T.

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ANTES_DEL_DUP_PA"),)

IF TYPE("MOpcao") = "U"
   MOpcao:=""
ENDIF
IF lAlteraDup = NIL
   lAlteraDup:=.T.
ENDIF

/* Abortar a execução do EICFI400 quando for inclusão automática do Purchase Order via Solicitação de Importação.
   Rotina de inclusão automática está disponível para cenários de integração EAI. */
If GerAutoSI()
   Return .T.
EndIf
DO CASE

   CASE lMicrosiga .AND. cParamIXB == "ESTORNO_DESPESA_DI" //EICDI500.PRW - AWR - 19/11/2004

      lReturn := FI400TITFIN("SWD_ESTORNA","4",.T.)// Exclusao

   CASE lMicrosiga .AND. "EICPO430" $ cParamIXB //EICPO430.PRW e EICPO400.PRW

        IF lGets .AND. EasyGParam("MV_GER_PA",,.F.)
           // AWR - 20/05/2004 - MP135
           IF SW2->(FIELDPOS("W2_CHAVEFI")) = 0
              MSGSTOP(STR0098) //STR0098 "Campo W2_CHAVEFI nao existe no Dicionario."
              RETURN .T.
           ENDIF

           IF LEN(SW2->W2_CHAVEFI) # LEN(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
              MSGSTOP(STR0099+STR(LEN(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)),2)) //STR0099 "Campo W2_CHAVEFI deve ser do tamanho de: "
              RETURN .T.
           ENDIF

           IF "EICPO430_VAL" $ cParamIXB
              SE2->(DBSETORDER(1))
              IF !SE2->(DBSEEK(xFilial()+SW2->W2_CHAVEFI))
                 RETURN .T.
              ENDIF
              IF FI400ParcBaixada(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_PARCELA)
                 lPABaixada:=.T.       //Usado no programa EICPO400.PRW
              ENDIF
              RETURN .T.
           ENDIF

           IF EMPTY(dDtLiquidado) .OR. EMPTY(SW2->W2_RECCCAM)
              IF EMPTY(dDtLiquidado)
                 FI400Titulo("BAIXA_TIT_PO430","EICPO430")
              ENDIF

              lPO430Sair:= .F.
              cIniDocto := SW2->W2_PO_SIGA             //M->E2_NUM
              cTIPO_Tit := "NF"                        //M->E2_TIPO
              cCodFor   := SW2->W2_FORN                //M->E2_FORNECE
              cLojaFor  := SA2->A2_LOJA                //M->E2_LOJA
              nMoedSubs := SimbToMoeda(SW2->W2_MOEDA)  //M->E2_MOEDA
              nValorS   := nVlAntecipado               //M->E2_VLCRUZ
              cEMISSAO  := dDtProforma                 //M->E2_EMISSAO
              cDtVecto  := dDtLiquidado                //M->E2_VENCTO
              nTxMoeda  := nTxCambio                   //M->E2_TXMOEDA
//              cHistorico:= "PO: "+ALLTRIM(SW2->W2_PO_NUM)+" PI: "+ALLTRIM(SW2->W2_NR_PRO)
              cHistorico:= AvKey("PO: "+ALLTRIM(SW2->W2_PO_NUM)+" PI: "+ALLTRIM(SW2->W2_NR_PRO),"E2_HIST") //Acb - 15/09/2010
              cParcela  := "1"                         //M->E2_PARCELA

              // Bete - 28/07/05 - Se o retorno da SimbToMoeda for 0, significa que a moeda nao esta cadastrada em um dos MV_SIMBs.
              IF nMoedSubs == 0
                 MSGSTOP(STR0100 + SW2->W2_MOEDA + STR0101) //STR0100 "Não foi possível gerar o título! A moeda: " //STR0101 " não está configurada no Financeiro!"
                 lPO430Sair := .T.
              ELSEIF !FI400TITFIN("SW2",IF(EMPTY(SW2->W2_CHAVEFI),"2","3"))
                 lPO430Sair := .T.
              ENDIF

           ENDIF

           IF !lPO430Sair .AND. !EMPTY(dDtLiquidado)
              FI400Titulo("BAIXA_TIT_PO430","EICPO430")
           ENDIF

        ENDIF

   CASE lMicrosiga .AND. cParamIXB $ "VAL_SY5,VAL_SA6,VAL_SY4,VAL_SYW,VALSA6" //Chamado do 'X3_WHEN' dos respectivos campos abaixo
        If nModulo == 29
           Return .T.
        EndIf
        IF !Inclui
           DO CASE
              CASE cParamIXB == "VAL_SY5"
                   cForn:=SY5->Y5_FORNECE
                   cLoja:=SY5->Y5_LOJAF

              CASE cParamIXB == "VAL_SA6"
                   cForn:=SA6->A6_CODFOR
                   cLoja:=SA6->A6_LOJFOR

              CASE cParamIXB == "VAL_SY4"
                   cForn:=SY4->Y4_FORN
                   cLoja:=SY4->Y4_LOJA

              CASE cParamIXB == "VAL_SYW"
                   cForn:=SYW->YW_FORN
                   cLoja:=SYW->YW_LOJA

              CASE cParamIXB == "VALSA6"
                   cForn:=SA6->A6_CODFOR
                   cLoja:=SA6->A6_LOJFOR
           ENDCASE
           SE2->(DBSETORDER(6))
           IF SE2->(DBSEEK(xFilial("SE2")+cForn+cLoja+"EIC"))
              IF cParamIXB == "VALSA6"
                 M->A6_LOJFOR:=SA6->A6_LOJFOR
                 Help(" ",1,"AVG0000668")
              ENDIF
              SE2->(DBSETORDER(1))
              RETURN .F.
           ENDIF
           SE2->(DBSETORDER(1))
        ENDIF
        RETURN .T.

   CASE lMicrosiga .AND. cParamIXB $ "VAL_SW6_1,VAL_SW6_2" //Chamado do EICDI500.PRW na validacao do  Campo 'W6_VL_FRET'

        IF MOpcao # "3" //FECHTO_NACIONALIZACAO

           IF cParamIXB == "VAL_SW6_1"
              IF EMPTY(M->W6_HOUSE)
//               MsgInfo(STR0033,STR0004) //"BL do frete nao informado."
                 Help(" ",1,"AVG0000661")
                 RETURN .F.
              ENDIF
              IF !AvFlags("GERACAO_CAMBIO_FRETE") .And. EMPTY(M->W6_VENCFRE).AND. cPaisLoc # "PAR"
//               MsgInfo(STR0034,STR0004) //"Vencimento do frete nao informado."
                 Help(" ",1,"AVG0000662")
                 RETURN .F.
              ENDIF

           ELSEIF cParamIXB == "VAL_SW6_2"
              IF ! EMPTY(M->W6_NF_SEG)

              IF !AvFlags("GERACAO_CAMBIO_SEGURO") .And. EMPTY(M->W6_VENCSEG) .AND. cPaisLoc # "PAR"
//               MsgInfo(STR0035,STR0004) //"Vencimento do seguro nao informado."
                 Help(" ",1,"AVG0000664")
                 RETURN .F.
              ENDIF

              IF EMPTY(M->W6_CORRETO)
//               MsgInfo(STR0036,STR0004) //"Corretor do seguro nao informado."
                 Help(" ",1,"AVG0000663")
                 RETURN .F.
              ENDIF

           ENDIF
           ENDIF
        ENDIF

        RETURN .T.

   CASE lMicrosiga .AND. cParamIXB == "BAIXA_TIT_LO100"//EICLO100

        if ! FI400Titulo(cParamIXB,, "WORK1")
         return .F.
        endif

   CASE lMicrosiga .AND. cParamIXB == "BAIXA_PA_LO100"

        if ! FI400Titulo(cParamIXB,"EICLO100", "WORK1")
         return .F.
        endif
   CASE lMicrosiga .AND. (cParamIXB == "BAIXA_TITULO"  .OR.;
                          cParamIXB == "EXCLUI_TITULO" .OR.;
                          cParamIXB == "INCLUI_TITULO" .OR.; //.AND. EasyGParam("MV_EASYFPO",,"N") == "S") //EICAP100 //ASR - 16/09/2005 - GERA TITULOS DE PREVISÃO DE DESPESAS NO FINANCEIRO SE FOR IGUAL "S"
						  cParamIXB == "COMP_TITULO"       ) // EOB - 03/2009 - inclusão de tratamento de compensação de títulos

        IF xParamAux == "FORCA_CANCELAR"
           lReturn := FI400Titulo("BAIXA_TITULO","FORCA_CANCELAR")
        ELSEIF xParamAux == "FORCA_CANCELAR_LO100"
           lReturn := FI400Titulo("BAIXA_TITULO","FORCA_CANCELAR_LO100", "WORK1")
        ELSEIF cParamIXB == "COMP_TITULO"
           lReturn := FI400Titulo(cParamIXB,xParamAux)
        ELSE
           lReturn := FI400Titulo(cParamIXB,"EICAP100")
        ENDIF
        IF cParamIXB == "EXCLUI_TITULO" .OR. xParamAux == "FORCA_CANCELAR" .OR. xParamAux == "FORCA_CANCELAR_LO100"
           RETURN lReturn
        ENDIF

   Case AvFlags("EIC_EAI") .And. cParamIXB == "EXCLUI_TITULO"

      Return FI400EAITitAnt()

   CASE lMicrosiga .AND. cParamIXB == "FECHA_CONTABIL" //EICAP100

        FIContabEIC('FOOTER',,.T.)// AWR

   CASE lMicrosiga .AND. cParamIXB == "PERG_GERA" //EICAP100

//      IF !(M->WB_TIPOREG $ cNaoGera)//"1,5"
//         TRB->TRB_GERA:=MSGNOYES(STR0008,STR0009)//"Deseja Gerar Titulo no Financeiro?"###"Geração de Título"
           M->TRB_GERA:=TRB->TRB_GERA:=.T.// AWR - 1/6/4 - Gera no financeiro p/ qq Tiporeg
//      ENDIF
        RETURN .T.

   CASE lMicrosiga .AND. cParamIXB == "VALTIPO" //EICAP100
        //Serve para desabilitar os campos (Valor e Tipo) das parcelas geradas automaticamente
        IF !EMPTY(TRB->WB_RECNO) //TRB->WB_TIPOREG $ cTipAuto .AND.
           SWB->(DBGOTO(TRB->WB_RECNO))
           RETURN EMPTY(SWB->WB_NUMDUP)
        ENDIF

        RETURN .T.//TRB->WB_TIPOREG # "1" .OR. EMPTY(TRB->WB_RECNO)

   CASE lMicrosiga .AND. cParamIXB == "VALFOB" //EICAP100

        IF !EMPTY(TRB->WB_RECNO) //TRB->WB_TIPOREG $ cTipAuto .AND.
           SWB->(DBGOTO(TRB->WB_RECNO))
           RETURN EMPTY(SWB->WB_NUMDUP)
        ENDIF

        RETURN .T.//TRB->WB_TIPOREG # "1" .OR. EMPTY(TRB->WB_RECNO)

   CASE lMicrosiga .AND. cParamIXB == "ALTERA_ESTRUTURA"//EICCA150

        AADD(aCampos,{"SWDRECNO" ,"C",07 , 0 })
        AADD(aCampos,{"TRNUMDUP2","C",AVSX3("WD_CTRFIN2",3) , 0 })
        AADD(aCampos,{"TRNUMDUP3","C",AVSX3("WD_CTRFIN3",3) , 0 })
        AADD(aCampos,{"TRSLDODUP","N",15 , 2 })

        nSld_Atual:= 0
        nSld_Agerar:= 0

   CASE lMicrosiga .AND. cParamIXB == "GRAVA_CAMPOS1"//EICCA150

        IF EMPTY(THouse)
           RETURN .T.
        ENDIF
        IF !EMPTY(SWD->WD_CTRFIN2)
           IF SWD->WD_DESPESA == "903"
              nSld_Atual -= SWD->WD_VALOR_R
           ELSEIF SWD->WD_DESPESA == "902" .OR. SWD->WD_DESPESA == "901"
              nSld_Atual += SWD->WD_VALOR_R
           ELSEIF SWD->WD_BASEADI $ '1,Y,S' .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
              nSld_Atual -= SWD->WD_VALOR_R
           ENDIF
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "GRAVA_CAMPOS2"//EICCA150

        IF ( SWD->WD_BASEADI $ '1,Y,S' .AND. !(SUBST(SWD->WD_DESPESA,1,1)== '9')) .OR.;
           SUBST(SWD->WD_DESPESA,1,1) == '9'
           Work->SWDRECNO :=STRZERO(SWD->(RECNO()),7)
           Work->TRNUMDUP2:=SWD->WD_CTRFIN2
           Work->TRNUMDUP3:=SWD->WD_CTRFIN3
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "GRAVA_CAMPOS3"//EICCA150

        IF EMPTY(THouse)
           RETURN .T.
        ENDIF
//      IF MV_PAR04 == 1 .AND. EMPTY(Work->TRNUMDUP2)
        IF nTipRel == 1 .AND. EMPTY(Work->TRNUMDUP2)
	       IF Work->ADIANTA > 0

              IF nSld_Atual >= 0
                 nSld_Agerar += Work->ADIANTA
              ELSEIF  nSld_Atual < 0
	             IF (nSld_Atual + Work->ADIANTA) = 0
	                nSld_Atual:= 0
	             ELSEIF (nSld_Atual + Work->ADIANTA) > 0
                    nSld_Agerar += ( nSld_Atual + Work->ACERTO )
	                nSld_Atual:= 0
	             ELSEIF (nSld_Atual + Work->ACERTO) < 0
	                nSld_Atual += Work->ACERTO
	             ENDIF
              ENDIF

           ELSEIF Work->DESPESA > 0

              IF nSld_Atual > 0
                 IF (nSld_Atual - Work->DESPESA) = 0
                    nSld_Atual :=0
                 ELSEIF (nSld_Atual - Work->DESPESA) < 0
                    nSld_Agerar += ( nSld_Atual - Work->DESPESA )
                    nSld_Atual :=0
                 ELSEIF (nSld_Atual - Work->DESPESA) > 0
                    nSld_Atual -= Work->DESPESA
                 ENDIF
              ELSEIF nSld_Atual <= 0
                 nSld_Agerar -= Work->DESPESA
              ENDIF

           ELSEIF Work->ACERTO # 0

              IF nSld_Atual > 0
                 IF Work->ACERTO < 0
	                IF (nSld_Atual + Work->ACERTO) = 0//OK
	                   nSld_Atual:= 0
	                ELSEIF (nSld_Atual + Work->ACERTO) < 0//OK
	                   nSld_Agerar += ( nSld_Atual + Work->ACERTO )
	                   nSld_Atual:= 0
	                ELSEIF (nSld_Atual + Work->ACERTO) > 0  //OK
	                   nSld_Atual += Work->ACERTO
	                ENDIF
                 ELSE//OK
                    nSld_Agerar+=Work->ACERTO
                ENDIF
              ELSEIF  nSld_Atual <= 0
                 IF Work->ACERTO > 0
	                IF (nSld_Atual + Work->ACERTO) = 0 //OK
	                   nSld_Atual:= 0
	                ELSEIF (nSld_Atual + Work->ACERTO) > 0 //OK
	                   nSld_Agerar += ( nSld_Atual + Work->ACERTO )
	                   nSld_Atual:= 0
	                ELSEIF (nSld_Atual + Work->ACERTO) < 0 //OK
	                   nSld_Atual += Work->ACERTO
	                ENDIF
                 ELSE //OK
                    nSld_Agerar+=Work->ACERTO
                ENDIF
              ENDIF

           ENDIF
           Work->TRSLDODUP:=nSld_Agerar
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "PRESTACAO_DE_CONTAS_1" //Chamado do EICDI500.PRW
        SY5->(dbSetOrder(1))
        TRB->(dbSetOrder(1))
        IF !TRB->(DBSEEK(SW6->W6_HAWB+"901"))
           MSGSTOP(STR0040) //"Nao existe adiantamentos: Despesa 90?."
           RETURN .F.
        ENDIF
        IF !SY5->(dbSeek(xFilial()+SW6->W6_DESP))
           MSGSTOP(STR0041+SW6->W6_DESP) //"Despachante nao Cadastrado: "
           RETURN .F.
        EndIf
        RETURN .T.

   CASE lMicrosiga .AND. cParamIXB == "PRESTACAO_DE_CONTAS_2" //Chamado do EICDI500.PRW
        nRecSW6:=SW6->(RECNO())
        nOrdSW6:=SW6->(IndexOrd())
        nOrdSWD:=SWD->(IndexOrd())
        SY5->(dbSetOrder(1))
        SY5->(dbSeek(xFilial()+SW6->W6_DESP))
        PRIVATE dDataIni := CTOD('01/01/1950')
        PRIVATE dDataFim := CTOD('31/12/2049')
        PRIVATE nDespesa :=1
        PRIVATE nTipRel  :=1
        PRIVATE lEmail   := .F.
//        MV_PAR03 := 1
//        MV_PAR04 := 1
        THouse   :=SW6->W6_HAWB
        lDeleta  := .F.

        IF Select("WORK") > 0  // JBS - 07/05/2004 - Fecha temporarios criados no DI500, se não dá erro na func. CA150Cons()
           lCriouOK := .F.     // Falso para o Di500 criar novamente os temp. caso venha a precisar.
           DI500Final()
           aDelFile := {}
        ENDIF

        CA150Cons("SY5",SY5->(RECNO()),2,,.T.)

        SW6->(dbSetOrder(nOrdSW6))
        SWD->(dbSetOrder(nOrdSWD))
        SW6->(DBGOTO(nRecSW6))
        IF SELECT("WORK") > 0
           Work->(dbCloseArea())
        ENDIF

        RETURN .T.

   CASE lMicrosiga .AND. cParamIXB == "EICCA150" //EICCA150

//      If xParamAux==2 .AND. mv_par03==1 .AND. mv_par04==1 .AND. !EMPTY(THouse)
      If xParamAux==2 .AND. nDespesa==1 .AND. nTipRel==1 .AND. !EMPTY(THouse)
	     lExibButtons := .T. //LRS
           /* //LRS - 28/08/2015 - Nopado, colocado na EnchoiceBar no fonte EICCA150
           IF cPaisLoc # "BRA"
              @ 3,79 BUTTON STR0043 SIZE 37,14 ACTION (Processa({|| FI400Gera()})) //"Gera Titulos"
           ELSE
              @ 3,70 BUTTON STR0074 SIZE 70,14 ACTION (Processa({|| FI400BaixaPA() })) //"Gera NFs p/ baixa do PA"
              @ 3,90 BUTTON STR0096 SIZE 70,14 ACTION (Processa({|| FI400EstBxPA() })) //"Estorna NFs de baixa do PA" //NCF - 08/12/2010 - Botão para estorno
           ENDIF
           */
        Endif
        IF cPaisLoc # "BRA"
           AADD(aTB_Campos,{"TRSLDODUP" ,,STR0042,'@E 999,999,999,999.99'}) //"Saldo Titulo"
           AADD(aTB_Campos,{"TRNUMDUP2",,STR0044}) //"Nro Titulo"
        ENDIF

   CASE cParamIXB == "ANT_GRV_PO" //.and. lGeraPO
        nRecno:=SW2->(RECNO())
        cPoNum:= IF(xParamAux="E",SW2->W2_PO_NUM,M->W2_PO_NUM)
        cPoNum:= Alltrim(cPONum)+SPACE(LEN(SW2->W2_PO_NUM)-Len(Alltrim(cPONum)))
        cPoSiga:=IF(xParamAux="E",SW2->W2_PO_SIGA,M->W2_PO_SIGA)
        cDesp := IF(xParamAux="E",SW2->W2_DESP,M->W2_DESP)

        If lAvIntDesp
           If Type("oDI500IntProv") == "O"
              oIntProv:= oDI500IntProv
           Else
              oIntProv := AvIntProv():New()
           EndIf
        EndIf

      IF (lAlteraDup:=(lAvIntDesp .AND. Type("lRecalcProv") == "L" .AND. lRecalcProv .OR. xParamAux = "I" .OR. FI400POAlterou(cPoNum,xParamAux))) // AWR - 08/07/2004
           IF (Type("Inclui") <> "L" .Or. !Inclui) .Or. FunName() <> "EICPO400" //wfs - inclusão do câmbio antecipado deve permitir
              lBaixada:=.F.

              If lAvIntDesp //AvFlags("AVINT_PR_EIC") - NOPADO POR AOM - 23/04/2012 - Deve -se testar a variavel pois o PR pode ser gerado quando estiver habilitado o parametro para gerar titulos no embarque.
                 oIntProv:DelAllProv(cPoNum,,"PR")
              Else
					  	If ( Type("lPOAuto") == "U" .OR. !lPOAuto )  .And. !IsBlind()
                 		Processa({|| FI400ANT_PO(cPoNum,.T.,@lBaixada),DeleImpDesp(cPoSiga,"PR","PO")})
					  	Else
							FI400ANT_PO(cPoNum,.T.,@lBaixada)
							DeleImpDesp(cPoSiga,"PR","PO")
						EndIf
              EndIf

           ENDIF
        ENDIF
        SW2->(DBGOTO(nRecno))

   CASE cParamIXB == "POS_GRV_PO" .AND. lAlteraDup .AND. lGeraPO
        IF xParamAux == "E"
           cPoNum:=TPO_NUM
        ELSE
           cPoNum:=M->W2_PO_NUM
        ENDIF
        cPoNum:= Alltrim(cPONum)+SPACE(LEN(SW2->W2_PO_NUM)-Len(Alltrim(cPONum)))

        If lAvIntDesp
           oIntPr := oIntProv
        EndIf
        //TDF - 25/04/11
        SW3->(DBSETORDER(1))
        IF SW3->(DBSEEK(XFILIAL("SW3")+cPoNum))
				If ( Type("lPOAuto") == "U" .OR. !lPOAuto ) .And. !IsBlind()
			  		Private lPOAuto := .T.
               Processa({|| FI400POS_PO(cPoNum,lBaixada) })   // SEMPRE GERA PR DO FOB
               lPOAuto := .F.
				Else
					FI400POS_PO(cPoNum,lBaixada)
				EndIf
        	   //SÓ GERA PR DAS DESPESAS QUANDO MV_EASYFPO = S
        	   If Empty(SW2->W2_HAWB_DA) //.AND. lGeraPO //AAF 26/11/09 - Provisórios já foram gerados no pedido da DA.
        		   If ( Type("lPOAuto") == "U" .OR. !lPOAuto ) .And. !IsBlind()
                  lPOAuto := .T.
					   Processa({|| AVPOS_PO(cPoNum,"PO") })  // S.A.M. 26/03/2001
                  lPOAuto := .F.
				   Else
   					AVPOS_PO(cPoNum,"PO")
	   			EndIf
           	EndIf
       	EndIf


        If lAvIntDesp
           oIntProv:Grava()
           oIntProv := NIL
        EndIf

   CASE cParamIXB == "ANT_GRV_DI" //.AND. MOpcao  # "1"//FECHTO_EMBARQUE //ASR - 20/09/2005 - MOpcao # "1" NÃO PERMITE A EXCLUSãO DOS TíTULOS PROVISóRIOS DO PO (PR)
        aPos := {}
        lAltFrete := lAltSeguro := .F.// Controla se vai deletar e gerar os Titulos de Frete e Seguro
        aAltInvoice := {}                // Controla se vai deletar e gerar os Titulos da Invoice
        lAltodasInvoice := .F.           // Controla se vai deletar e gerar os Titulos de todas as Invoices
        lTitFreteIAE := lTitSeguroIAE:=.F.// Controla se foi gerado os Titulos de Frete e Seguro
        aTitInvoiceIAE := {}                // Controla se foi gerado os Titulos de Invoices
        aSWBChavesTit := {}                // Guarda as chaves dos titulos excluidos
        aSWBCampos := {}

        If lAvIntDesp
           IF Type("oDI500IntProv") # "O"
              oIntProv := AvIntProv():New()
           ELSE
              oIntProv := oDI500IntProv
           ENDIF
        EndIf

        // GFP - 22/03/2013
        If Type("M->W6_CONDP_F") == "U" .OR. SW6->W6_CONDP_F # M->W6_CONDP_F
           If !FI400SetCPag("FRETE")
              DeleDupEIC("EIC",;   //Prefixo do titulo
              SW6->W6_NUMDUPF,;    //Numero das duplicatas
              -1,;                 //Numero de parcela.
              SW6->W6_TIPOF ,;     //Tipo do titulo
              SW6->W6_FORNECF,;    //Fornecedor
              SW6->W6_LOJAF ,;     //Loja
              "SIGAEIC")           //Origem da geracao da duplicata (Nome da rotina)
           EndIf
        EndIf
        If Type("M->W6_CONDP_F") == "U" .OR. SW6->W6_CONDP_S # M->W6_CONDP_S
           If !FI400SetCPag("SEGURO")
              DeleDupEIC("EIC",;   //Prefixo do titulo
              SW6->W6_NUMDUPS,;    //Numero das duplicatas
              -1,;                 //Numero de parcela.
              SW6->W6_TIPOS ,;     //Tipo do titulo
              SW6->W6_FORNECS,;    //Fornecedor
              SW6->W6_LOJAS ,;     //Loja
              "SIGAEIC")           //Origem da geracao da duplicata (Nome da rotina)
           EndIf
        EndIf

//      IF (lAlteraDup:=(xParamAux == "I" .OR. FI400DIAlterou(M->W6_HAWB,xParamAux)))
        IF (lAlteraDup:=(/*lAvIntDesp .AND.*/ Type("lRecalcProv") == "L" .AND. lRecalcProv .OR. Inclui .OR. FI400DIAlterou(M->W6_HAWB,xParamAux)))
           IF Inclui
              lAltodasInvoice:=.T. //lAltFrete:=lAltSeguro:=.T.

              // GFP - 22/03/2013
              lAltFrete  := FI400SetCPag("FRETE")   // Condição de Pagamento - Frete
              lAltSeguro := FI400SetCPag("SEGURO")  // Condição de Pagamento - Seguro

              FIContabEIC('HEADER',,.T.)//Depende do OFF-LINE ou ON-LINE para criar o "\cProva"
           ELSE
              If !lAvIntDesp//AWR - 2011/06/01
                 If IsInCallStack("DI500_Grava") .OR. IsInCallStack("DI600_Grava") .OR. IsInCallStack("DI500GrvCapa") //AAF 06/07/2017 - Regerar titulos da invoice apenas na DI, unico ponto onde é possível dar manutenção na invoice.
                    Processa({|| FI400ANT_DI(M->W6_HAWB,.F.)})
                 EndIf
              ENDIF
              FI400SW7(M->W6_HAWB)

              If lAvIntDesp //AvFlags("AVINT_PR_EIC") - NOPADO POR AOM - 23/04/2012 - Deve -se testar a variavel pois o PR pode ser gerado quando estiver habilitado o parametro para gerar titulos no embarque.
                 oIntProv:DelAllProv(,M->W6_HAWB,"PRE")
              Else
                 IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'ALTERA_SE2'),)// GFP - 08/03/2013
                 If !lAlteraSE2
                    DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",,lAltFrete,lAltSeguro)
                 EndIf
              EndIf
              FIContabEIC('HEADER',,.F.)//Forca abrir o cProva
              FI400MOVCONT('DEL_CONTABIL')
           ENDIF
        ELSEIF xParamAux == "A" .AND. !EMPTY(M->W6_DT_ENCE)
          FI400SW7(M->W6_HAWB)
          // EOS 03/06/04 - Passagem do 4º par. p/ ignorar a delecao dos titulos de frete e seguro pois neste
          // momento apesar de estar numa alteracao, nao foi alterado cpos que necessitem regerar tais titulos e
          // como o processo está encerrado é necessario deletar somente os titulos provisorios.
          If AvFlags("AVINT_PRE_EIC")
             oIntProv:DelAllProv(,M->W6_HAWB,"PRE")
          Else
             DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
          EndIf
        ENDIF

   CASE cParamIXB == "POS_GRV_DI" .AND. lAlteraDup //.AND. MOpcao  # "1"//FECHTO_EMBARQUE //ASR - 20/09/2005 - MOpcao # "1" NÃO PERMITE A GERAÇãO DOS TíTULOS PROVISóRIOS DO PO (PR)
        //If Type("aPos") == "U" .OR. Len(aPos) == 0        // GFP - 15/10/2013 - Sistema não estava gerando PR ao estornar desembaraço. //comentado por WFS
        If ValType(aPOs) <> "A" //wfs 22/06/2017 - variável statica do programa, sempre existirá
           aPos := {} //RRV - 22/02/2013
        EndIf
        FI400SW7(M->W6_HAWB)
        SW9->( DBSetOrder(3) )

        If lAvIntDesp
           If Type("oIntProv") <> "O"
              If Type("oDI500IntProv") == "O"
                 oIntProv:= oDI500IntProv
              Else
                 oIntProv := AvIntProv():New()
              EndIf
           EndIf
           oIntPr := oIntProv
        EndIf

        IF lGeraPO .Or.  SW9->( !DBSeek(xFilial("SW9")+M->W6_HAWB) ) .And. lGerPrDi //ASK 27/06/07
           FOR nTab := 1 TO LEN(aPos)
               If lAvIntDesp //AvFlags("AVINT_PR_EIC") - NOPADO POR AOM - 23/04/2012 - Deve -se testar a variavel pois o PR pode ser gerado quando estiver habilitado o parametro para gerar titulos no embarque.
                  oIntProv:DelAllProv(aPos[nTab],,"PR")
               Else
                  Processa({|| FI400ANT_PO(aPos[nTab])})
               EndIf
               //Processa({|| FI400POS_PO(aPos[nTab])})
               nOrderSW2:=SW2->(INDEXORD())
               SW2->(DBSETORDER(1))
               SW2->(DBSEEK(XFILIAL("SW2")+aPos[nTab]))
               If !lAvIntDesp/*!AvFlags("AVINT_PR_EIC")*/ .And. SW6->W6_TIPOFEC <> "DIN" .OR. Empty(SW2->W2_HAWB_DA)  //- NOPADO POR AOM - 23/04/2012
                  Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
               EndIf

               //TDF - 25/04/11
               If lGeraPO .AND. (SW6->W6_TIPOFEC <> "DIN" .OR. Empty(SW2->W2_HAWB_DA))
                  Processa({|| AVPOS_PO(aPos[nTab],"DI") })
               EndIf

               SW2->(DBSETORDER(nOrderSW2))
           NEXT
        Endif

        //TDF - 25/04/11
        IF SW9->(DBSeek(xFilial("SW9")+M->W6_HAWB))// .AND. !lGeraPO
           Processa({|| FI400ANT_PO(SW2->W2_PO_NUM)})
        EndIf
        //LGS-16/07/2014 - Força recriar os titulos na fase do PO como PR
        If Len(aPos) == 0 .And. xParamAux="E"
	       Processa({|| AVPOS_PO(SW2->W2_PO_NUM, "PO") })
        EndIf

        SW7->(DBSETORDER(1))
        IF SW7->(DBSEEK(xFilial("SW7")+M->W6_HAWB))

           IF cPaisLoc = "BRA"
              lTitFreteIAE:=lTitSeguroIAE:=.F.// Controla se foi gerado os Titulos de Invoice
           ENDIF
           aTitInvoiceIAE:={}
           
           
           If !lAvIntDesp //AWR - 2011/06/01
              If IsInCallStack("DI500_Grava") .OR. IsInCallStack("DI600_Grava") .OR. IsInCallStack("DI500GrvCapa") //AAF 06/07/2017 - Regerar titulos da invoice apenas na DI, unico ponto onde é possível dar manutenção na invoice.
                 lReturn := Processa({|| FI400POS_DI(M->W6_HAWB) },"Invoices")
              EndIf
           ENDIF
           lFazPrDesp:=.T.

           //TRP - 04/08/2011 - Não gerar título de Frete caso já exista título baixado. Chamado 088421 - Descarpack
           aOrdSE2Frete := SaveOrd("SE2")
           cChaveW6:=SW6->W6_PREFIXF+SW6->W6_NUMDUPF+SW6->W6_PARCELF+SW6->W6_TIPOF+SW6->W6_FORNECF+SW6->W6_LOJAF
           SE2->(DbSetOrder(1))
           If SE2->(DbSeek(xFilial()+cChaveW6))
              If !EMPTY(SE2->E2_BAIXA)
                 lAltFrete:= .F.
              EndIf
           EndIf
           RestOrd(aOrdSE2Frete,.T.)

           IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"GERA_PRE"),)
           lGerPrDI := lGerPrDI .And. Empty(M->W6_DT_ENCE)
           //If SW6->W6_TIPOFEC <> "DIN" // SVG - 20/10/2010 - Tratamento para geração de titulos mesmo em nacionalização
           If !lAlteraSE2  //RCR - Alteração chamado 098703 - Toyota 15/03/2013
              Processa({|| AVPOS_DI(M->W6_HAWB,(lFazPrDesp .AND. lGerPrDI),.T.,lAltFrete,lAltSeguro) },STR0102) //STR0102 "Frete, Seguro e Provisorios"
           EndIf
           //EndIf

           //ISS - 30/12/10 - Alteração para a geração dos PRE's da DI ao incluir uma nova DIN
           If SW6->W6_TIPOFEC == "DIN"

              SW6->(nOldRecDI := RecNo())
              aDAs := FI400GetDAS()

              if Len(aDAs) > 0
                 SW6->(dbClearFilter())
              EndIf
              For i := 1 To Len(aDAs)
                 SW6->(dbSetOrder(1),dbSeek(xFilial("SW6")+aDAs[i]))
                 DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
                 AVPOS_DI(SW6->W6_HAWB, lFazPrDesp .AND. lGerPrDI)
              Next i
              if Len(aDAs) > 0
                 DI500Fil(.T.)
              EndIf
              SW6->(dbGoTo(nOldRecDI))

           EndIf

           Processa({|| FI400MOVCONT("GRV_CONTABIL") },STR0103) //STR0103 "Contabilidade"

        Endif
                                                                       //MFR 16/08/2021 OSSME-6070
        IF lGeraPO  .And. SW9->( !DBSeek(xFilial("SW9")+M->W6_HAWB) ) //.and. lGerPrDi // GFP - 20/10/2015
	        FOR nTab := 1 TO LEN(aPos)
    	        Processa({|| FI400POS_PO(aPos[nTab],,, .T.)})
        	NEXT
        ENDIF

        IF Inclui
           FIContabEIC('FOOTER',,.T.)//Depende do OFF-LINE ou ON-LINE
        ELSE
           FIContabEIC('FOOTER',,.F.)//Forca fechar o cProva
        ENDIF
        aSWBChavesTit :={}
        aSWBCampos := {}

        If lAvIntDesp  .AND. Type("oDI500IntProv") # "O" //AWR - 2011/06/01 - O AVINTEG deve ser executado fora do Begin Transaction
           oIntProv:Grava()
           oIntProv := NIL
        EndIf
   CASE cParamIXB == "VAL_PARC_EXCLUI" //.OR. cParamIXB == "VAL_PARC_ALTERA"//EICAP100

        IF EMPTY(TRB->WB_RECNO)
           lSairFI400:=.F.
           RETURN .F.
        ENDIF
        SWB->(DBGOTO(TRB->WB_RECNO))
        IF EMPTY(SWB->WB_NUMDUP)
           lSairFI400:=.F.
           RETURN .F.
        ENDIF
        cForn:=SWB->WB_FORN
        IF EICLOJA()
           cLoja:= SWB->WB_LOJA
        ENDIF

        IF EMPTY(cForn)
           SW9->(DBSETORDER(1))
           cFilSW9:=xFilial("SW9")
           //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
           SW9->(DBSEEK(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB", "WB_LOJA")+SWB->WB_HAWB))
           cForn:=SW9->W9_FORN
           IF EICLOJA()
              cLoja := SW9->W9_FORLOJ
           ENDIF
//         IF SWB->WB_TIPOREG $ cTipAuto
              DO WHILE SW9->(!EOF()) .AND.;
                    SW9->W9_FILIAL  == cFilSW9 .AND.;
                    SW9->W9_INVOICE == SWB->WB_INVOICE
                 IF SW9->W9_NUM == SWB->WB_NUMDUP
                    cForn:=SW9->W9_FORN
                    IF EICLOJA()
                       cLoja:= SW9->W9_FORLOJ
                    ENDIF
                    EXIT
                 ENDIF
                 SW9->(DBSKIP())
              ENDDO
//         ENDIF
        ENDIF

        cPrefixo := "   "
        cTipoDup := "   "
        cLojaFor := "  "
        cParcela := SWB->WB_PARCELA
        lExisCpoSWB:= SWB->(FIELDPOS("WB_LOJA" )) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_PREFIXO")) # 0
        IF lExisCpoSWB .AND. cPaisLoc == "BRA"
           cTipoDup:=SWB->WB_TIPOTIT
           cLojaFor:=SWB->WB_LOJA
           cPrefixo:=SWB->WB_PREFIXO
        ENDIF
        IF EMPTY(cTipoDup)
           cTipoDup:=FI400TipoDup(Left(SWB->WB_TIPOREG,1))
           SA2->(DBSETORDER(1))
           SA2->(DBSEEK(xFilial("SA2")+cForn+IF(EICLOJA(),cLoja,"")))
           cLojaFor:=SA2->A2_LOJA
           cPrefixo:="EIC"
        ENDIF

        IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"VAL_PARC_EXCLUI_001"),) // Jonato 10-Fev-2005

        IF FI400ParcBaixada(cPrefixo,SWB->WB_NUMDUP,cTipoDup,cForn,cLojaFor,SWB->WB_PARCELA)
//         IF cParamIXB == "VAL_PARC_ALTERA"
//            Help("",1,"AVG0000389",,"alterada",1,21)//"Parcela não pode ser excluida, pois há Título Baixado"###"Informação"
//         ELSE
              HELP("",1,"AVG0000389")//"Parcela não pode ser excluida, pois há Título Baixado"###"Informação"
//         ENDIF
           lSairFI400:=.T.
           RETURN .T.
        ELSE
           lSairFI400:=.F.
           RETURN .F.
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "PA_BAIXADA"

        lPABaixada:=.F.
        lGets:=.T.
        //IF !Inclui
//      IF !Inclui .AND. EasyGParam("MV_GER_PA",,.F.)
//         FI400ANT_PO(SW2->W2_PO_NUM,.T.,@lPABaixada,.T.)
           //EICFI400("EICPO430_VAL_PA") TLM 14/01/2008 Parâmetro EICPO430_VAL_PA não é tratado em nenhum fonte padrão. Chamado 056399
        //ENDIF

        RETURN lPABaixada

   CASE lMicrosiga .AND. cParamIXB == "TUDO_OK"

        lPABaixada:=.F.
        EICFI400("PA_BAIXADA")
        IF lPABaixada
           IF M->W2_INLAND+M->W2_PACKING-M->W2_DESCONT # SW2->W2_INLAND+SW2->W2_PACKING-SW2->W2_DESCONT
              cMsg:=STR0075 //"Campos: Inland, Packing e Desconto nao podem serem alterados, pois ha"
              Help("",1, "AVG0000399",,cMsg,1,0)
              lTudo_OK:=.F.
              RETURN .F.
           ENDIF
           IF !lBotaoCapa
              EICFI400("MENSAGEM")
              lTudo_OK:=.F.
              RETURN .F.
           ENDIF
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "VAL_CPO_DI"

        Processa({||lBaixa:=FI400ANT_DI(SW6->W6_HAWB,.T.)})

        RETURN !lBaixa

   CASE lMicrosiga .AND. cParamIXB == "VAL_EXCLUI" //EICAP100.PRW
        lBaixa := .F.
        //TRP- 20/03/09- Validar o estorno do câmbio quando os mesmo possuir parcelas de adiantamento.
        lTemAdto := .F.
        //IF !lCposAntecip //.OR. SWA->WA_PO_DI == "D"
           cFilSWB := xFilial("SWB")
		   SWB->(dbSetorder(1))
		   SWB->(DBSEEK(cFilSWB + SWA->WA_HAWB + "D"))
		   DO WHILE !SWB->(eof()) .AND. SWB->WB_FILIAL==cFilSWB .AND. SWB->WB_HAWB==SWA->WA_HAWB .AND. SWB->WB_PO_DI=="D"
		      IF Left(SWB->WB_TIPOREG,1) == "P"
		         lTemAdto := .T.
		         EXIT
		      ENDIF
		      SWB->(dbSkip())
		   ENDDO
           Processa({||lBaixa:=FI400ANT_DI(SWA->WA_HAWB,.T.)})//Teste dos Titulos gerados automaticos
       // ENDIF
        IF !lBaixa
           SW9->(DBSETORDER(1))
           SA2->(DBSETORDER(1))
           cFil:=xFilial("SWB")

           cChavSWB := cFil + SWA->WA_HAWB + SWA->WA_PO_DI
           bWhileBai:={||cFil==SWB->WB_FILIAL .AND. SWA->WA_HAWB ==SWB->WB_HAWB ;
                                              .AND. SWA->WA_PO_DI==SWB->WB_PO_DI}

           lExisCpoSWB:= SWB->(FIELDPOS("WB_LOJA" )) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_PREFIXO")) # 0
           IF lExisCpoSWB .AND. cPaisLoc == "BRA"
              bBaixa:={|| lBaixa:=FI400ParcBaixada(SWB->WB_PREFIXO,SWB->WB_NUMDUP,SWB->WB_TIPOTIT,;
                                                   SWB->WB_FORN   ,SWB->WB_LOJA  ,SWB->WB_PARCELA)}
           ELSE
              bBaixa:={|| SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA"))),;
                          lBaixa:=FI400ParcBaixada("EIC",SWB->WB_NUMDUP,;
                          FI400TipoDup(Left(SWB->WB_TIPOREG,1)),;
                          SWB->WB_FORN,SA2->A2_LOJA,SWB->WB_PARCELA)}
           ENDIF
//         bForBai:={||!SWB->WB_TIPOREG $ cTipAuto }
           SWB->(DBSEEK(cChavSWB))
           Processa({||SWB->(DBEVAL(bBaixa,,bWhileBai)) })//Teste dos Titulos gerados manuais //
        ENDIF
        IF lBaixa
           HELP("",1,"AVG0000393") //"Cambio não pode ser excluida, pois há Título Baixado"###"Informação"
        ENDIF
        IF lTemAdto
           MSGINFO(STR0104) //STR0104 "Atenção! Existem adiantamentos vinculados para este processo no câmbio"
        ENDIF
        lOutFI400:=lTemAdto
        lSairFI400:=lBaixa
        IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,cParamIXB),) // Bete 06/09/05
        RETURN lBaixa


   CASE lMicrosiga .AND. cParamIXB == "MENSAGEM"

        IF !Inclui .AND. EasyGParam("MV_GER_PA",,.F.) .AND. (cCpo:=Readvar()) = "M->"
           cMsg:=AVSX3(RTRIM(SUBSTR(cCpo,4)),5)+STR0076 //" nao pode ser alterada, pois ha   "
           Help("",1, "AVG0000399",,cMsg,1,0)
        ELSE
           HELP("",1,"AVG0000399") //"Itens não podem ser alterados, pois há Títulos Baixados"###"Informação"
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "TES"  .OR. cParamIXB == "TES_SYB"
        IF cParamIXB == "TES_SYB"
           cTES:=M->YB_TES
        ELSE
           cTES:=M->YD_TES
        ENDIF
        IF !EMPTY(cTES)
           IF !EXISTCPO("SFC",cTES)
              RETURN .F.
           ENDIF
           SFC->(DBSETORDER(1))
           IF SFC->(DBSEEK((cFil:=xFilial("SFC"))+cTES))
              DO WHILE SFC->(!EOF()) .AND. cTES == SFC->FC_TES .AND. cFil == SFC->FC_FILIAL
                 IF SFC->FC_INTEIC $ "1,Y,S"
                    RETURN .T.
                 ENDIF
                 SFC->(DBSKIP())
              ENDDO
              HELP("",1,"AVG0000400")//"Não há impostos de importação cadastrados para essa TES"
              RETURN .F.
           ENDIF
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "ANT_TELA_DESP"
        aAlterados:={}
        lBaixaDesp:=.F.// Verifica se esta baixado a Despesa no financeiro
        lnoEnvFin :=.T.
        lAltForn  :=.T.
        lForcaGerar:=.T.

   CASE lMicrosiga .AND. cParamIXB == "ANT_GET_DESP"
        lValid:=.T.
        IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,cParamIXB),)
        IF xParamAux=="N"
           If lValid .AND. TRB->WD_DESPESA == "901" .AND. !EMPTY(TRB->WD_CTRFIN1)
              MSGINFO(STR0090,STR0002)//"Despesa possui titulo no financeiro, cancele o titulo p/ poder Alterar/Excluir a desepesa."
              lSair:=.T.
              Return .F.
           Endif
        ENDIF
        lAltForn:=.T.
        IF aAlterados = NIL
           aAlterados:={}
        ENDIF
        IF xParamAux=="S"
           lBaixaDesp:=.F.
           lnoEnvFin:=.T.
        ELSE
           IF !EMPTY(TRB->WD_CTRFIN1).AND.;
              (TRB->WD_DESPESA$'901/902/903/701/702/703' .or. TRB->WD_BASEADI='2')
              IF !EMPTY(TRB->WD_FORN)
                 cForn:=TRB->WD_FORN
                 cLoja:=TRB->WD_LOJA
              ELSE
                 SY5->(DBSEEK(XFILIAL("SY5")+SW6->W6_DESP))
                 cForn:=SY5->Y5_FORNECE
                 cLoja:=SY5->Y5_LOJAF
              ENDIF
              cTipo:= "NF"
              IF TRB->WD_DESPESA="901"
                 cTipo:= IF(!Empty(cTipo_Adt) .And. FI400ValTpO(cTipo_Adt),cTipo_Adt,"PA")  //NCF - 07/07/2010 - Verificar títulos incluídos como "SA" (Melhoria para permitir a inclusão o tipo de título "SA" na Solic. de Numerário via RdMake
              ENDIF

              SWD->(dbGoTo(TRB->RECNO))
              lBaixaDesp:=IsBxE2Eic("EIC",;
                       TRB->WD_CTRFIN1,;
                       cTipo,;
                       cForn,;
                       cLoja)
           ELSE
              lBaixaDesp:=.F.
           ENDIF

           IF !EMPTY(TRB->WD_CTRFIN1)
              lnoEnvFin:=.F.
           ELSE
              lnoEnvFin:=.T.
           ENDIF

        ENDIF

        IF lBaixaDesp

           lAltForn:=.F.

        ELSEIF !lNoEnvFin
           lAltForn:=.F.
           nRecTrb := TRB->(RECNO())
           cCtrFin1:= TRB->WD_CTRFIN1
           TRB->(DBGOTOP())
           DO WHILE !TRB->(EOF())
              IF TRB->WD_CTRFIN1==cCtrFin1 .AND. TRB->WD_DESPESA='901'
                 lAltForn:=.T.
                 Exit
              ENDIF
              TRB->(DBSKIP())
           ENDDO
           TRB->(DBGOTO(nRecTrb))
        ENDIF

   CASE lMicrosiga .AND. cParamIXB == "POS_GET_DESP" //DESPESAS DI500
         If M->WD_GERFIN='1' .AND. ;
            ( EMPTY(M->WD_FORN) .OR. EMPTY(M->WD_LOJA) )
            MSGINFO(STR0013,STR0002)//"Despesa sem Fornecedor, nao pode ser gerada no financero."
            RETURN .F.
         Endif

         IF M->WD_DESPESA='102'
            nValFret:=Round((SW6->W6_VLFRECC+SW6->W6_VLFREPP)*SW6->W6_TX_FRET,2)//ValorFrete(SW6->W6_HAWB,,,1) //AWR 10/09/2004 //MCF - 10/01/2017 - Incluído arrdondamento
                                                           // 10/08/2021 OSSME-6060 MFR
            IF STR(M->WD_VALOR_R,17,2) # STR(nValFret,17,2) .And. nValFret != 0
               MSGINFO(StrTran(STR0014, "###", Alltrim(STR(nValFret,17,2))),STR0004) //"Valor da Despesa nao e igual ao do processo:  " //MCF - 17/09/2015
               RETURN .F.
            ENDIF
         Endif

         IF M->WD_DESPESA='103'
            nValseg:=0
            DO CASE
            CASE !EMPTY(SW6->W6_TX_SEG)     // RAD ARG 06/04/03 - existe o campo na 710 !
                 nValSeg := (SW6->W6_VL_USSE * SW6->W6_TX_SEG)
            Otherwise
                 IF SW6->W6_SEGMOED == BuscaDolar()/*EasyGParam("MV_SIMB2")*/ .AND. SW6->W6_TX_US_D != 0
                    nValSeg := SW6->W6_VL_USSE * SW6->W6_TX_US_D
                 ELSE
                    nValSeg := SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,SW6->W6_DT,.T.,.F.,.T.)
                 ENDIF
            ENDCASE
                                                           // 10/08/2021 OSSME-6060 MFR
            IF STR(M->WD_VALOR_R,17,2) # STR(nValSeg,17,2) .And. nValSeg != 0
               MSGINFO(StrTran(STR0014, "###", AllTrim(STR(nValSeg,17,2))),STR0004) //"Valor da Despesa nao e igual ao do processo: " //MCF - 17/09/2015
               RETURN .F.
            ENDIF
         Endif
         IF !EMPTY(TRB->RECNO)
            SWD->(dbGoTo(TRB->RECNO))
            IF !lBaixaDesp .AND. !EMPTY(SWD->WD_CTRFIN1) .AND. ASCAN(aAlterados,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA) = 0
               AADD(aAlterados,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA)
            ENDIF
         ENDIF

   CASE lMicrosiga .AND. cParamIXB == "ANT_GRV_DESP"//DESPESAS DI500

        lForcaGerar:=.F.
        For L:=1 To Len(aDeletados)
           SWD->(dbGoTo(aDeletados[L]))
           IF SWD->WD_DESPESA=='901' .AND. !EMPTY(SWD->WD_DTLANC)
              lForcaGerar:=.T.
              EXIT
           ENDIF
        Next
        IF lForcaGerar
           FIContabEIC('HEADER',,.F.)//Forca abrir o cProva
        ELSE
           FIContabEIC('HEADER',,.T.)//Depende do Pergunte p/ abrir o cProva
        ENDIF
        TRB->(dbGoTop())
        DO While TRB->(!Eof())
           IF !EMPTY(TRB->RECNO)
              SWD->(dbGoTo(TRB->RECNO))
              IF ASCAN(aAlterados,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA) # 0
                 EICFI400("ANT_DEL_DESP")
              ENDIF
           ENDIF
           TRB->(dbSkip())
        ENDDO

   CASE lMicrosiga .AND. cParamIXB == "POS_GRV_DESP"//DESPESAS DI500

        //** AAF 30/11/09 - Atualização dos PREs da DA
        SW6->(nOldRecDI := RecNo())
        aDAs := FI400GetDAS()

        if Len(aDAs) > 0
           SW6->(dbClearFilter())
        EndIf
        For i := 1 To Len(aDAs)
           SW6->(dbSetOrder(1),dbSeek(xFilial("SW6")+aDAs[i]))
           DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
           AVPOS_DI(SW6->W6_HAWB, .T.)
        Next i
        if Len(aDAs) > 0
           DI500Fil(.T.)
        EndIf
        SW6->(dbGoTo(nOldRecDI))
        //**

        FIContabEIC('FOOTER',,.F.)

        IF cPaisLoc = "BRA"// AWR - 28/6/2004 - A contabilizacao é chamasa das novas funcoes
           RETURN .T.
        ENDIF

         nRegSWDd := SWD->(recno())
         nOrdSWDd := SWD->(INDEXORD())
         nOrdSYBd := SYB->(INDEXORD())
         nOrdSY5d := SY5->(INDEXORD())
         cTipo := SPACE(1)
         SYB->(DBSETORDER(1))
         SY5->(DBSETORDER(1))
         SWD->(DBSETORDER(1))
         aDespOut := {}
         TRB->(dbGoTop())
         DO While TRB->(!Eof())
            IF SW6->W6_TIPOFEC = 'DIN' .AND. TRB->WD_DESPESA $ '102,103'
               TRB->(dbSkip())
               LOOP
            ENDIF
            IF EMPTY(TRB->WD_CTRFIN1)  .AND.;
               !(TRB->WD_DESPESA$'101,901').AND.; // AWR - 8/8/03 - "901" nao gera mais por aqui
               TRB->WD_GERFIN =='1'    .AND.;
               !EMPTY(TRB->WD_FORN)    .AND.;
               !EMPTY(TRB->WD_LOJA)
               // Grava no Array as Despesas
               AADD(aDespOut,{TRB->WD_DESPESA,;
                              TRB->WD_VALOR_R,;
                              TRB->WD_FORN   ,;
                              TRB->WD_LOJA   ,;
                              TRB->RECNO     })
            ENDIF
            TRB->(dbSkip())

         EndDO
         aAlterados:={}
         nValorSld:=0
         IF LEN(aDespOut) > 0
            DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.F.)
         ENDIF
         FIContabEIC('HEADER',,.T.) // Jonato Ocorrência 0111/03
         IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
			 For I:=1 to Len(aDespOut)
				 nTaxa:= 0
				 IF aDespOut[I][1] $ '102,103'
					DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
				 ENDIF
				 SWD->(DBGOTO(aDespOut[I][5]))
				 If cPaisLoc == "ARG"
					If AVSX3("WD_VALOR_M",,,.t.) .and. ! EMPTY(SWD->WD_VALOR_M)
					   nValorSld:=SWD->WD_VALOR_M
					Else
					   nValorSld:=aDespOut[I][2]
					Endif
					nTaxa:=If(AVSX3("WD_TX_MOE",,,.t.),SWD->WD_TX_MOE,0)
				 Else
					nValorSld=aDespOut[I][2]
				 Endif
				 cNroDupl := " "
				 IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(SWD->WD_DOCTO)
					cNroDupl := SWD->WD_DOCTO
				 ELSE
					IF aDespOut[I][1] $ '102'
					   cNroDupl := SW6->W6_HOUSE
					ELSEIF aDespOut[I][1] $ '103'
					   cNroDupl := SW6->W6_NF_SEG
					ENDIF
				 ENDIF
				 IF Empty(cNroDupl)
					/*IF FindFunction("AvgNumSeq")//AVGERAL.PRW
					   cNroDupl := AvgNumSeq("SWD","WD_CTRFIN1")
					ELSE
					   cNroDupl := GetSXENum("SWD","WD_CTRFIN1")
					   ConfirmSx8()
					ENDIF*/
					cNroDupl := NumTit("SWD","WD_CTRFIN1")
				 ENDIF
				 SYB->(DBSEEK(XFILIAL("SYB")+aDespOut[I][1]))
				 SWD->(DBGOTO(aDespOut[I][5]))
				 SWD->(RECLOCK("SWD",.F.))
				 SWD->WD_CTRFIN1:=cNroDupl
				 SWD->WD_DTENVF :=dDataBase

	//           IF SWD->WD_DESPESA="901"
	//              FI400MOVCONT('DESPACHANTE','I')
	//              cTipo:= "PA"
	//              SWD->WD_DTLANC :=CTOD('')
	//           ELSE
					cTipo:= IF(nValorSld < 0, "NCP","NF")
	//           ENDIF
				 SWD->(MSUNLOCK())

				 FI400MOVCONT("DESPACHANTE",'I')   // Jonato Ocorrência 0111/03


				 nValorSld:= If( nValorSld <0,nValorSld*-1,nValorSld )

				 SA2->(DBSETORDER(1))
				 SA2->(DBSEEK(XFILIAL("SA2")+aDespOut[I][3]+aDespOut[I][4]))
				 If cPaisLoc <> "BRA" .AND. ! SA2->(EOF())
					aTab:=CalcImpGer( If(empty(SWD->WD_TES),SYB->YB_TES,SWD->WD_TES),,,nValorSld,,,,{},,nValorSld,.t.)
					For wind:=1 to len(aTab[6])
					   if subst(aTab[6,wind,5],1,1) == "1" // essa posicao corresponde ao conteudo do campo SFC->FC_INCDUPL, que diz se o valor deve ser somado na duplicata
						  nValorSld+= aTab[6,wind,4]  // valor do imposto
					   endif
					next
				 Endif

				 nErroDup:=1
				 IF ! SA2->(EOF())
					cMoeda:= EasyGParam("MV_SIMB1")
					If cPaisLoc <> "BRA"
					   If AVSX3("WD_MOEDA",,,.t.) .and. ! EMPTY(SWD->WD_MOEDA)
						  cMoeda:= SWD->WD_MOEDA
					   Endif
					Endif
					dData_Emis:=IF(!AVSX3("WD_DT_EMIS",,,.t.),dDataBase,SWD->WD_DT_EMIS)
					dData_Emis:=If (dData_Emis > SWD->WD_DES_ADI,SWD->WD_DES_ADI,dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
					nErroDup:=GeraDupEic(SWD->WD_CTRFIN1,;     //Numero das duplicatas
							  nValorSld  ,;   //Valor da duplicata
							  dData_Emis,;              //data de emissao
							  SWD->WD_DES_ADI,;     //Data de vencimento
							  cMoeda,;
							  "EIC",;                  //Prefixo do titulo
							  cTipo ,;                  //Tipo do titulo
							  1,;                   //Numero de parcela.
							  aDespOut[I][3],;                //Fornecedor
							  aDespOut[I][4],;                 //Loja
							  "SIGAEIC",;              //Origem da geracao da duplicata (Nome da rotina)
							  "P: "+ALLTRIM(SW6->W6_HAWB)+' '+ ;
							  SYB->YB_DESCR,;
							  nTaxa,.T.,SW6->W6_HAWB)
				  // RAD 02/04/03            0)                       //Taxa da moeda (caso usada uma taxa diferente a
				 ENDIF
			 Next I
		 EndIF
         FIContabEIC('FOOTER',,.T.)    // Jonato Ocorrência 0111/03
         SYB->(DBSETORDER(nOrdSYBd))
         SY5->(DBSETORDER(nOrdSY5d))
         SWD->(DBSETORDER(nOrdSWDd))
         SWD->(DBGOTO(nRegSWDd))

   CASE  lMicrosiga .AND. "FI400MOVCONT" $ cParamIXB //AWR - 30/06/2004 Contab

         IF cParamIXB == "FI400MOVCONT_E"    //E-EXCLUSAO
            FIContabEIC('HEADER',,.T.)
            FI400MOVCONT("DESPACHANTE","E")
         ENDIF

         IF cParamIXB == "FI400MOVCONT_I"    //I-INCLUSAO
            FIContabEIC('HEADER',,.T.)
            FI400MOVCONT("DESPACHANTE","I")
         ENDIF

   CASE  lMicrosiga .AND. cParamIXB == "ANT_DEL_DESP"

         IF !EMPTY(SWD->WD_CTRFIN1)
            nValorSld:=SWD->WD_VALOR_R
            If cPaisLoc == "ARG" .AND. AVSX3("WD_VALOR_M",,,.t.)
               nValorSld:=SWD->WD_VALOR_M
            ENDIF
            cTipoTit:=IF(SWD->WD_DESPESA='901',IF(!Empty(cTipo_Adt) .And. FI400ValTpO(cTipo_Adt),cTipo_Adt,"PA"),IF(nValorSld < 0, "NCP","NF")) //NCF - 06/07/2010 - Verificar títulos incluídos como "SA" (Melhoria para permitir a inclusão o tipo de título "SA" na Solic. de Numerário via RdMake
            DeleDupEIC("EIC",;    //Prefixo do titulo
               SWD->WD_CTRFIN1,;  //Numero das duplicatas
               -1,;               //Numero de parcela.
               cTipoTit ,;        //Tipo do titulo
               SWD->WD_FORN,;     //Fornecedor
               SWD->WD_LOJA ,;    //Loja
               "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
            nRecnoTRB:=TRB->(RECNO())
            TRB->(dbGoTop())
            TRB->(DBEval({|| TRB->WD_CTRFIN1:='' },{|| TRB->WD_CTRFIN1+TRB->WD_FORN+TRB->WD_LOJA+cTipoTit == SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA+cTipoTit }))
            TRB->(DBGOTO(nRecnoTRB))
         ENDIF
         IF !EMPTY(SWD->WD_DTLANC) // Jonato ocorrência 0111/03
            FIContabEIC('HEADER',,.F.)//Forca abrir o cProva
            FI400MOVCONT("DESPACHANTE",'E')
            FIContabEIC('FOOTER',,.F.)//Forca fechar o cProva
         ENDIF

   CASE  lMicrosiga .AND. cParamIXB == "MAN_EXC_DESP"
         If lBaixaDesp
            MSGINFO(STR0012,STR0002)//"Despesa nao pode ser alterada, pois o titulo esta pago no financeiro."
            lSair:=.T.
            Return .F.
         Endif
         lValid:=.T.
         IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,cParamIXB),)

         If lValid .AND. TRB->WD_DESPESA == "901" .AND. !EMPTY(TRB->WD_CTRFIN1)
            MSGINFO(STR0090,STR0002)//"Despesa possui titulo no financeiro, cancele o titulo p/ poder excluir a desepesa."
            lSair:=.T.
            Return .F.
         Endif

   CASE  lMicrosiga .AND. cParamIXB == "VER_FRETSEG"
         If '102'$xParamAux .OR. '103'$xParamAux
            IF SWD->(DBSEEK(XFILIAL("SWD")+xParamAux))
               IF !EMPTY(SWD->WD_CTRFIN1)
                  IF IsBxE2Eic("EIC",;
                         SWD->WD_CTRFIN1,;
                         "NF",;
                         SWD->WD_FORN,;
                         SWD->WD_LOJA )

                     RETURN .F.
                  ENDIF
               ENDIF
            ENDIF
         ENDIF

	CASE lMicrosiga .AND. cParamIXB == "INTEG_DESP"
    	 nOrderSW2 := SW2->(INDEXORD())
   		 SW2->(DBSETORDER(1))
   		 aPos := {}
	     FI400SW7(SW6->W6_HAWB)
         IF lGeraPO
            FOR i := 1 TO LEN(aPos)
	            SW2->(DBSEEK(xFilial("SW2")+aPos[I]))
    	        Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
        	    Processa({|| AVPOS_PO(aPos[I],"DI") })  // S.A.M. 26/03/2001
		    NEXT
         ENDIF
         SW2->(DBSETORDER(nOrderSW2))

         DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
         Processa({|| AVPOS_DI(SW6->W6_HAWB, lGerPrDI) })

//AWR-27/5/4
// CASE  cParamIXB == "NUMERARIO" // Chamado do EICNU400
//   aPos:={}
//   FI400SW7(SW6->W6_HAWB)
//   IF lGeraPO
//      FOR I := 1 TO LEN(aPos)
//          Processa({|| FI400ANT_PO(aPos[I])})
//          Processa({|| FI400POS_PO(aPos[I])})
//          nOrderSW2:=SW2->(INDEXORD())
//          SW2->(DBSETORDER(1))
//          SW2->(DBSEEK(XFILIAL("SW2")+aPos[I]))
//          Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
//          Processa({|| AVPOS_PO(aPos[I],"DI") })  // S.A.M. 26/03/2001
//          SW2->(DBSETORDER(nOrderSW2))
//      NEXT
//  Endif
//  Processa({|| AV POS_DI(SW6->W6_HAWB,.T.) })

ENDCASE

// E necessario voltar as configuracoes da tecla e variaveis porque as funcoes da Microsiga alteradam
//SetKey(VK_F11,bSet_F11_Key)
//SetKey(VK_F12,bSet_F12_Key)

RETURN lReturn

*---------------------------------------------------------*
FUNCTION FI400ANT_PO(cPO_Num,lTemPA,lBaixada,lVal,cParcela,cCondTipo)
*---------------------------------------------------------*
LOCAL nAlias:=SELECT(), nInd:=SW2->(INDEXORD())
LOCAL cTipoPar:="PR",nQtde:=1,nDel
DEFAULT lTemPA:=.F.
DEFAULT lVal  :=.F.
PRIVATE cForn:=cLoja:=''
If Type("cUltParc") == "U"  // GFP - 19/03/2014
   Private cUltParc := ""
EndIf

If !lVal
   ProcRegua(2)
   IncProc()
EndIf

SW2->(DBSETORDER(1))
IF SW2->(DBSEEK(xFilial("SW2")+cPO_Num))
   SA2->(DBSETORDER(1))
   SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
   IF lTemPA
      nQtde:=2
   ENDIF
   FOR nDel := 1 TO nQtde

       cForn:=SW2->W2_FORN
       cLoja:=SA2->A2_LOJA
       IF FI400FornBanco(SW2->W2_PO_NUM)//Reposiciona o SA2 com o fornecedor do Banco
          cForn:=SA6->A6_CODFOR
          cLoja:=SA6->A6_LOJFOR
       ENDIF

       IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400ANT_PO_001"),) // Jonato 10-Fev-2005

       IF nDel = 2 .OR. lVal
          cTipoPar:="PA"
          IF (lBaixada:=IsBxE2Eic("EIC",SW2->W2_PO_SIGA,cTipoPar,cForn,cLoja))
             EXIT
          ENDIF
          IF lVal
             EXIT
          ENDIF
       ENDIF

       cTipoPar := Iif(Empty(cCondTipo),"PR",cTipoPar)     //NCF - 07/04/2010

       DeleDupEIC("EIC",;            //Prefixo do titulo
                  SW2->W2_PO_SIGA,;  //Numero das duplicatas
                  -1,;               //Numero de parcela.
                  cTipoPar,;         //Tipo do titulo
                  cForn,;            //Fornecedor
                  cLoja,;            //Loja
                  "SIGAEIC")         //Origem da geracao da duplicata (Nome da rotina)
   NEXT

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400ANT_PO'),)

EndIf


IF !lVal
   IncProc()
ENDIF
SELECT(nAlias)
SW2->(DBSETORDER(nInd))

RETURN .T.

*----------------------------------------------------------------*
Static FUNCTION MinData(cPoNum)
*----------------------------------------------------------------*
Local cTrbSw3 := getNextAlias()
Local dData   := CToD("  /  /  ")

   BeginSql alias cTrbSw3
      column W3_DT_EMB as Date
      SELECT
         MIN(SW3.W3_DT_EMB) MIN_DATA
      FROM
         %table:SW3% SW3
      LEFT JOIN %table:SW8% SW8 ON W8_FILIAL = SW3.W3_FILIAL AND 
         SW3.W3_PO_NUM = SW8.W8_PO_NUM AND
         SW3.W3_COD_I = SW8.W8_COD_I AND SW3.W3_POSICAO = SW8.W8_POSICAO AND
         SW8.%notDel%
      WHERE
         SW3.W3_FILIAL= %xfilial:SW3% AND
         SW3.W3_PO_NUM = %exp:cPoNum% AND
         SW3.%notDel% AND W8_INVOICE IS NULL
   EndSql
   dData := SToD((cTrbSw3)->MIN_DATA)
   (cTrbSw3)->(dbCloseArea())

Return dData

*----------------------------------------------------------------*
FUNCTION FI400POS_PO(cPO_Num,lLoop,lEICPO430, lCallPOS_GRV_DI)
*----------------------------------------------------------------*
LOCAL Wind, _Dias, _Perc
LOCAL _SmAux := 0, _LenTab := 0
LOCAL _Valor
LOCAL nFobTot:= 0 //TDF - 16/10/12
LOCAL dDtEMB := ""
LOCAL TFobMoe, TInvoice
LOCAL cNum, xPerc:=0, nParc
LOCAL nAlias := SELECT(), nInd := SW2->(INDEXORD())
LOCAL cTpPar
Local cAdt
LOCAL nCOUNT := 0
Local nParcs := FI400Parcs()
Local lExistCpoSWB := SWB->(FIELDPOS("WB_PREFIXO"))       # 0;
					  .AND. SWB->(FIELDPOS("WB_NUMDUP"))  # 0;
					  .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0;
					  .AND. SWB->(FIELDPOS("WB_FORN"))    # 0;
					  .AND. SWB->(FIELDPOS("WB_LOJA"))    # 0;
					  .AND. SWB->(FIELDPOS("WB_PARCELA")) # 0 .and. cPaisLoc == "BRA"
Local nValFre := nValseg := 0 //NCF - 04/01/2017					
Local dVencimentoProv
Local lOIntPr:= .F.
PRIVATE nValPO := 0, nValPOusado := 0, nValINV := 0, nValADTO := 0, aSW7HAWB := {} //ASR 20/09/2005 - VARIAVEIS PARA O TRATAMENTO DOS TITULOS PROVISÓRIOS E EFETIVOS
PRIVATE aTabInv := {}, aFornPOCC := {}, lGeraParcAnt := EasyGParam("MV_GER_PA",,.F.), aCambPO := {}
PRIVATE cForn := '', cLoja := '', lGeraPR := .T.
PRIVATE nValorRdm:= 0  //TRP - 09/03/2010 - Variável utilizada em rdmake
PRIVATE cDespRdm
Private dDataEmbarque:= CtoD("")
If Type("cUltParc") == "U"  // GFP - 19/03/2014
   Private cUltParc := ""
EndIf
DEFAULT lEICPO430 := .F.
DEFAULT lLoop := .F.
Default lCallPOS_GRV_DI:= .F.

//AvStAction("207",.F.)  // JWJ 05/06/09
//OAP - Substituição feita no antigo EICPOCO
IF EasyGParam("MV_EIC_PCO",,.F.)   //Importação por Conta e Ordem
   IF EasyGParam("MV_PCOIMPO",,.T.) .AND. EasyGParam("MV_PCOFOB",,.F.) == .F. .AND. SW2->W2_IMPCO == '1'
      lGeraPR := .F.
   ENDIF
ENDIF

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_PO'),)  // Bete 06/09/05
IF !lGeraPR
   RETURN .T.
ENDIF

If Type("oIntPr") == "O"
   lOIntPr:= .T.
EndIf

SA2->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SY6->(DBSETORDER(1))

SW2->(DBSEEK(xFilial("SW2")+cPO_Num))
SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
ProcRegua(3)

//ASR 20/09/2005 - VALORIZAÇÃO DAS VARIAVEIS DE TRATAMENTO DOS TITULOS
SW3->(DBSETORDER(7))
SW3->(DBSEEK(xFilial("SW3")+cPO_Num))
//MFR 12/08/2021 OSSME-6070

//dDtEMB := SW3->W3_DT_EMB
dDtEMB := MinData(cPO_Num)

//wfs - Alterado via ponto de entrada
If !Empty(dDataEmbarque)
   dDtEMB:= dDataEmbarque
EndIf

//CCH - 29/01/09 - Se for selecionado Frete Incluso = Não, o valor do frete W2_FRETEIN será somado ao FOB para envio ao Financeiro
//Apenas nos casos dos Incoterms "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"

//TDF - 16/10/12
//nFobTot:= If(SW3->(FieldPos("W3_SLD_ELI")) > 0, FI400CalculaFOB(cPO_Num), SW2->W2_FOB_TOT)   // GFP - 24/10/2012   //NCF - 04/02/2017 - Tratar no bloco abaixo

If SW3->(FieldPos("W3_SLD_ELI")) > 0
   nFobTot:= FI400CalculaFOB(cPO_Num) //NCF - 04/01/2017 - A função está ajustada para tratar Frete e seguro no valor do PO
   nValPO := nFobTot  //AQUI CALCULA O VALRO DO PO
Else
   nFobTot := SW2->W2_FOB_TOT   // GFP - 24/10/2012 
   /*
   IF Type("M->W2_FREINC") <> "U" .and. SW2->(FieldPos("W2_FREINC")) > 0 .AND. M->W2_FREINC $ "2" .AND. AvRetInco(M->W2_INCOTER,"CONTEM_FRETE")//FDR - 28/12/10  //M->W2_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
      nValPO := (nFobTot + SW2->W2_INLAND + SW2->W2_PACKING + SW2->W2_OUT_DES + SW2->W2_FRETEIN) - SW2->W2_DESCONT
   Else
      nValPO := (nFobTot + SW2->W2_INLAND + SW2->W2_PACKING + SW2->W2_OUT_DES) - SW2->W2_DESCONT
   EndIf
   */
   IF Type("M->W2_FREINC") <> "U" .and. SW2->(FieldPos("W2_FREINC")) > 0 .AND. M->W2_FREINC $ "2" .AND. AvRetInco(M->W2_INCOTER,"CONTEM_FRETE")
      If SW2->(FieldPos("W2_FRETEIN")) > 0
         nValFre := SW2->W2_FRETEIN
      EndIf
   ENDIF   
   IF Type("M->W2_SEGINC") <> "U" .and. SW2->(FieldPos("W2_SEGINC")) > 0 .AND. M->W2_SEGINC $ "2" .AND. AvRetInco(M->W2_INCOTER,"CONTEM_SEGURO")
      If SW2->(FieldPos("W2_SEGURIN")) > 0
         nValSeg := SW2->W2_SEGURIN
      EndIf
   ENDIF
    
   nValPO := (nFobTot + SW2->W2_INLAND + SW2->W2_PACKING + SW2->W2_OUT_DES + nValFre + nValSeg) - SW2->W2_DESCONT
EndIf

SW7->(DBSETORDER(2))//FILIAL+PO_NUM+HAWB
SW7->(DBSEEK(xFilial("SW7")+cPO_Num))
//GUARDO O NUMERO DOS PROCESSO DO PO
DO WHILE SW7->(!EOF()) .AND. SW7->W7_PO_NUM == cPO_Num
	IF ASCAN(aSW7HAWB,SW7->W7_HAWB) == 0
		AADD(aSW7HAWB,SW7->W7_HAWB)
	ENDIF
	SW7->(DBSkip())
ENDDO

SWB->(DBSETORDER(1))//FILIAL+HAWB
SW8->(DBSETORDER(1))//FILIAL+HAWB+INVOICE+FORN

//WFS
If Type("lAvIntDesp") <> "L"
   lAvIntDesp := AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC")
EndIf
FOR nCOUNT := 1 TO LEN(aSW7HAWB)
   If SW8->(DBSEEK(xFilial("SW8")+aSW7HAWB[nCOUNT]))
      DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB = aSW7HAWB[nCOUNT]
   	  IF SW8->W8_PO_NUM == cPO_Num .AND. SWB->(DBSEEK(xFilial("SWB")+aSW7HAWB[nCOUNT]+"D"+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")))
            IF lExistCpoSWB .AND. !Empty(SWB->WB_PREFIXO);
                     .AND. !Empty(SWB->WB_NUMDUP );
                     .AND. !Empty(SWB->WB_TIPOTIT);
                     .AND. !Empty(SWB->WB_FORN   );
                     .AND. !Empty(SWB->WB_LOJA   );
                     .AND. !Empty(SWB->WB_PARCELA)
                       nValINV += DI500RetVal("ITEM_INV", "TABPR", .T. )//LGS-04/02/2016 // EOB - 28/05/08 - chamada da função DI500RetVal
            ELSEIF !lExistCpoSWB .OR. lAvIntDesp
	   		        nValINV += DI500RetVal("ITEM_INV", "TABPR", .T. ) // EOB - 28/05/08 - chamada da função DI500RetVal
            ENDIF
         ENDIF
         SW8->(DBSkip())
      ENDDO
   Else
      nRecW6:= SW6->(RecNo())
      nRecW7:= SW7->(RecNo())

      If SW6->(dbSeek(xFilial("SW6")+aSW7HAWB[nCOUNT])) .AND. !Empty(SW6->W6_DT_ENCE)

         SW7->(dbSetOrder(1))
         SW7->(DBSEEK(xFilial("SW7")+aSW7HAWB[nCOUNT]))
         Do While SW7->( !EoF()  .And.  W7_FILIAL+W7_HAWB == xFilial("SW7")+aSW7HAWB[nCOUNT] )
            nValINV += SW7->( W7_PRECO * W7_QTDE )
            SW7->( DBSkip() )
         EndDo

      EndIf

      SW6->(dbGoTo(nRecW6))
      SW7->(dbSetOrder(2),dbGoTo(nRecW7))
   EndIf
NEXT

//JAP - 15/09/06
// SVG - 08/09/2010 - Tratamento para excluir o provisório referente ao ant. no PO.
If EasyGParam("MV_EIC0003",,"1") == "2" .OR. EasyGParam("MV_EIC0003",,"1") == "3" //AAF 15/03/2017 - Novo tratamento para considerar as parcelas definidas no cambio antecipado para os provisórios do tipo ANTECIPADO.
   SWB->(DBSETORDER(1))//FILIAL+HAWB
   SWB->(DBSEEK(xFilial("SWB")+cPO_Num))

  // GCC - 21/10/2013 - Tratamento para as novas modalidades de pagamentos antecipados
   If Left(SWB->WB_PO_DI,1) == "A"
		cAdt := "A"
   ElseIf Left(SWB->WB_PO_DI,1) == "F"
		cAdt := "F"
   ElseIf Left(SWB->WB_PO_DI,1) == "C"
		cAdt := "C"
   EndIf

   DO WHILE !SWB->(EOF()) .AND. ALLTRIM(SWB->WB_HAWB) == ALLTRIM(cPO_Num)
       IF (lExistCpoSWB .AND. !Empty(SWB->WB_PREFIXO);
         					                  .AND. !Empty(SWB->WB_NUMDUP );
	        				                  .AND. !Empty(SWB->WB_TIPOTIT);
		       	     		                  .AND. !Empty(SWB->WB_FORN   );
			       	     	                  .AND. !Empty(SWB->WB_LOJA   );
				    	                      .AND. !Empty(SWB->WB_PARCELA);
				    	                     .AND. Left(SWB->WB_PO_DI,1) == cAdt;
   	      .OR. lAvIntDesp) .AND. EasyGParam("MV_EIC0003",,"1") == "2"

          nValADTO += SWB->WB_PGTANT
       ElseIf EasyGParam("MV_EIC0003",,"1") == "3"//AAF 15/03/2017 - Novo tratamento para considerar as parcelas definidas no cambio antecipado para os provisórios do tipo ANTECIPADO.
         /* wfs 19/07/2017 - quando o câbio estiver liquidado e o vencimento for menor que a data base (data de emissão), assumir a data base
            como vencimento. Se o câmbio não estiver liquidado, assumir que o usuário está alterando a parcela de câmbio e ele é quem deve ajustar
            o vencimento que será considerado pelo sistema.
         */
         dVencimentoProv:= SWB->WB_DT_VEN
         If !Empty(SWB->WB_CA_DT)
            If dVencimentoProv < dDataBase
               dVencimentoProv:= dDataBase
            EndIf
         EndIf
         //aAdd(aCambPO,SWB->({WB_INVOICE,WB_PGTANT ,WB_DT_VEN, "ANTECIPADO", cNum ,"",0}))
         aAdd(aCambPO,SWB->({WB_INVOICE,WB_PGTANT ,dVencimentoProv, "ANTECIPADO", cNum ,"",0}))
	   ENDIF
	   SWB->(DbSkip())
   ENDDO
EndIf

nValPOusado := DI500Trans(nValInv) + nValADTO //LRS - 26/06/2018

BEGIN SEQUENCE

IF SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))

   IF SY6->Y6_TIPOCOB == "4"
//      MSGINFO("Nao houve geracao de titulos, porque a condicao de pagamento nao tem cobertura.")//ASR 21/09/2005 - ESTA LINHA ESTAVA COMENTADA
      BREAK
   ENDIF

   IncProc()
   IF SY6->Y6_DIAS_PA >= 900
      xPerc := 0
      FOR Wind := 1 TO nParcs

          _Dias := "Y6_DIAS_" + STRZERO(Wind,2)
          _Dias := SY6->(FIELDGET( FIELDPOS(_Dias) ))
          _Perc := "Y6_PERC_" + STRZERO(Wind,2)
          _Perc := SY6->(FIELDGET( FIELDPOS(_Perc) ))

          IF _Dias < 0
             xPerc+=_Perc
          ENDIF
      NEXT
      IncProc()
      IF xPerc = 100 .AND. !lGeraParcAnt .and. lEICPO430
         BREAK
      ENDIF
   ENDIF

   ProcRegua(5)
   DBSELECTAREA('SW2')

   _Valor := nValPO//_Valor := 0//ASR 20/09/2005 - ALTERADO PARA O TRATAMENTO DOS TITULOS PROVISÓRIOS E EFETIVOS

   IncProc()

   IF _Valor <= 0 .AND. !lEICPO430//ASR 20/09/2005 - ALTERADO PARA O TRATAMENTO DOS TITULOS PROVISÓRIOS E EFETIVOS
      BREAK
   ENDIF


   IF EasyGParam("MV_NRPO") $ cSim 
      If Empty(SW2->W2_PO_SIGA)
         SW2->(RECLOCK("SW2",.F.))
         SW2->W2_PO_SIGA := SW2->W2_PO_NUM
         SW2->(MSUNLOCK()) 
      EndIf   
   ElseIf Empty(SW2->W2_PO_SIGA)        
           SW2->(RECLOCK("SW2",.F.))
           SW2->W2_PO_SIGA := GetNumSC7(.T.)
           SW2->(MSUNLOCK())  
   ENDIF     
   cNum:= SW2->W2_PO_SIGA
   

   EicCalcPagto(SW2->W2_PO_NUM,_Valor,dDtEMB,dDtEMB,,aTabInv,cNum) //gera pelo PO

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_PO_1'),)

ENDIF

If EasyGParam("MV_EIC0003",,"1") == "3" .AND. Len(aCambPO) > 0 //AAF 15/03/2017 - Novo tratamento para considerar as parcelas definidas no cambio antecipado para os provisórios do tipo ANTECIPADO.
   aNewTabInv := aClone(aCambPO)

   //Preencher com a numercao correta.
   For Wind := 1 To Len(aNewTabInv)
      aNewTabInv[Wind][5] := cNum
   Next Wind

   //Carregar as parcelas nao antecipadas
   For Wind := 1 To Len(aTabInv)
      If !aTabInv[Wind,4] == 'ANTECIPADO'
         aAdd(aNewTabInv,aTabInv[Wind])
      EndIf
   Next Wind

   //substituir o array de parcelas da condicao de pagamento
   aTabInv := aNewTabInv
EndIf

_LenTab  := LEN( aTabInv )

TInvoice := ""
cTpPar   := ""
Wind := 1
nParc:= 1
IF _LenTab # 0 .AND. LEN( aTabInv[1] ) # NIL
   ProcRegua(_LenTab+1)
ELSE
   IncProc()
   BREAK
ENDIF
IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	FOR Wind := 1 TO _LenTab

	   IncProc()

	   IF lGeraParcAnt .AND. lEICPO430 .AND. aTabInv[Wind,4] == 'ANTECIPADO'
		  cTipoParc := "PA"
	   ELSE
		  cTipoParc := "PR"
	   ENDIF
	   IF lLoop .OR. EMPTY(aTabInv[Wind,3])
		  _SmAux += aTabInv[Wind,2] //Valor
		  LOOP
	   ENDIF
	   IF TInvoice # aTabInv[Wind,1] .OR. cTipoParc # cTpPar
		  cTpPar:=cTipoParc
		  nParc:= 1
	   ELSE
		  nParc++
	   ENDIF
	   TFobMoe  := aTabInv[Wind,2] //Valor
	   _SmAux   += TFobMoe

	   IF Wind = _LenTab .AND. (_Valor - _SmAux) # 0
		  aTabInv[Wind,2]:= TFobMoe + ( _Valor - _SmAux )
	   ENDIF

	   cForn := SW2->W2_FORN     //Fornecedor
	   cLoja := SA2->A2_LOJA     //Loja

	   IF FI400FornBanco(SW2->W2_PO_NUM)
		  cForn := SA6->A6_CODFOR
		  cLoja := SA6->A6_LOJFOR
	   ENDIF

	//ASR 21/09/2005 - VERIFICAR A NECESSIDADE DESTE BLOCO
	   IF nValPOusado > 0
		  IF TFobMoe == nValPOusado
			 TFobMoe := nValPOusado := 0
		  ELSEIF TFobMoe < nValPOusado
			 nValPOusado := nValPOusado - TFobMoe
			 TFobMoe := 0
		  ELSEIF TFobMoe - nValPOusado <= SW2->W2_INLAND + SW2->W2_PACKING + SW2->W2_OUT_DES - SW2->W2_DESCONT //ASR 17/01/2006
			 TFobMoe := nValPOusado := 0
		  ELSE
			 TFobMoe := TFobMoe - nValPOusado
			 nValPOusado := 0
		  ENDIF
	   ENDIF

	   //TFobMoe := Round(TFobMoe,2) LRS - 26/06/2018

	   cDespRdm := "101"
	   nValorRdm:=TFobMoe  //TRP - 09/03/2010
	   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400POS_PO_001"),) // Jonato 10-Fev-2005

	   nErroDup:=1
	   SA2->(DBSETORDER(1))
	   IF SA2->(DBSEEK(XFILIAL("SA2")+cForn+cLoja)) .AND. TFobMoe > 0
		  TInvoice := aTabInv[Wind,1] //Chave

		  dData_Emis:= SW2->W2_PO_DT  //dDataBase - NOPADO - AOM - 24/06/2010 - pois a alteração deve buscar a data do PO nao a data de alteração.
		  dData_Emis:=If (dData_Emis > aTabInv[Wind,3],aTabInv[Wind,3],dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
		If AllTrim(cTipoParc) == "PR" .AND. lAvIntDesp .AND. lOIntPr //NOPADO POR AOM - 23/04/2012 - O titulo PR pode ser gerado quando o parametro de gerar titulos no embarque estiver habilitado.
		   If !Empty(SW2->W2_TAB_PC) .Or. AvFlags("EIC_EAI") // RRV 08/08/2012 - Sem tabela de pré-calculo não gera PR do FOB.//regerar quando integração EAI - tratamento para previsão de antecipado
				oIntPr:GeraProv(TFobMoe,;           //Valor da duplicata
					dData_Emis,;             //data de emissao
					aTabInv[Wind,3],;        //Data de vencimento
					SW2->W2_MOEDA,;          //Simbolo da moeda
					"PR",;                   //Tipo do titulo
					1,;                      //Numero de parcela
					cFORN,;                  //Fornecedor
					cLOJA,;                  //Loja
					"",;
					"",;                     //Processo
					SW2->W2_PO_NUM,;         //Pedido
					"101",;                  //Despesa
					TInvoice,;               //Invoice
					"",;
					If( AvFlags("EIC_EAI") .And. aTabInv[Wind,4] == 'ANTECIPADO' .And. (nParcAdLiq := AP100PAdLq(SW2->W2_PO_NUM)) > 0 , EasyGParam( "MV_EIC0066", .T. , "" , ) ,"") ) //NCF - 24/10/2016 - Verificar na função AP100PAdLq(SW2->W2_PO_NUM) se existe
		   EndIf                                                                                                                                                                    //                   parc. adiant. liquidada e caso exista, envia a natureza
		Else                                                                                                                                                                         //                  do parâmetro MV_EIC0066 que deve corresponder à um tipo de título                  
			 nErroDup:=GeraDupEic(aTabInv[Wind,5],;  //Numero das duplicatas                                                                                                        //                   que não movimente o fluxo de caixa no ERP 
					 TFobMoe,;          //Valor da duplicata
					 dData_Emis,;       //Data de emissao
					 aTabInv[Wind,3],;  //Data de vencimento
					 SW2->W2_MOEDA,;    //Simbolo da moeda
					 "EIC",;            //Prefixo do titulo
					 cTipoParc,;        //Tipo do titulo
					 nParc,;            //Numero de parcela
					 cFORN,;            //Fornecedor
					 cLOJA,;            //Loja
					 "SIGAEIC",;        //Origem da geracao da duplicata (Nome da rotina)
					 STR0031+TInvoice,; //Historico da geracao
					 RecMoeda(dData_Emis,SimbToMoeda(SW2->W2_MOEDA)),,,SW2->W2_PO_NUM)//Taxa da moeda (caso usada uma taxa diferente a
										//               cadastrada no SM2.
		  EndIf
	   ENDIF
	   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_PO_2'),)

	NEXT
EndIF

END SEQUENCE

IncProc()

SELECT(nAlias)
SW2->(DBSETORDER(nInd))

Return .T.

*-------------------------------------------*
FUNCTION FI400ANT_DI(cHawb,lVal,lGRV_FIN_EIC)
*-------------------------------------------*
LOCAL cFilSW9:=xFilial("SW9"),lBaixa:=.F.//, lCambLiq:=.F.
LOCAL nInd:=SW9->(INDEXORD()), nAlias:=SELECT()
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilSWB:=xFilial("SWB")
Local lExistEZZ  := SX2->(dbSeek("EZZ"))
Local lExisCpoSWB:= SWB->(FIELDPOS("WB_LOJA" )) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_PREFIXO")) # 0
Local aOrdE2 := {}   //TRP- 02/02/2010
LOCAL cSQLChv    := ""
Local lAltCambFS := .F.  // GFP - 23/06/2015
Local nCont := 0
Local lAchouSWB := .F.
Private lCambLiq:=.F.  // PLB 11/08/10
Private lDel_SWB := .T. //RMD - 01/08/13
Private lLoop102 := lLoop103 := .F. //LGS-26/11/2015
Private lAltdInv, aAltInv

//LGS-23/11/2015 - Executa a função para verificar as despesas 102 e 103
NU400Desp('SWB')

IF lGRV_FIN_EIC = NIL
   lGRV_FIN_EIC:=.F.
ENDIF

//WFS
If Type("lCambio_eic") <> "L"
   lCambio_eic:= AVFLAGS("AVINT_CAMBIO_EIC")
EndIf

ProcRegua(4)
IncProc()

bWhilSWB := {|| SWB->WB_PO_DI == "D" }

If Type("lEncDesemb") == "U"
   lEncDesemb:= .F.
EndIf

If Type("aSWBUserCps") == "U" 
   aSWBUserCps:= Nil
EndIf

SW9->(DBSETORDER(3))
IF SW9->(DBSEEK(cFilSW9+cHawb))

   IncProc()
   DO WHILE ! SW9->(EOF()) .AND. cHawb == SW9->W9_HAWB .AND.;
                               cFilSW9 == SW9->W9_FILIAL

      SA2->(DBSEEK(cFilSA2+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))

      lAchouSWB := SWB->(dbSeek(cFilSWB+SW9->W9_HAWB+"D"+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))

      cTipo:="INV"
      cLoja:=SA2->A2_LOJA
      cPref:="EIC"

      IF lVal .And. lAchouSWB

         IF !lBaixa

            IF cPaisLoc == "BRA"

               DO While SWB->(!Eof()) .And. SWB->WB_FILIAL  == cFilSWB         .AND.;
                                            SWB->WB_HAWB    == SW9->W9_HAWB    .AND.;
                                            SWB->WB_INVOICE == SW9->W9_INVOICE .AND.;
                                            SWB->WB_FORN    == SW9->W9_FORN    .AND. (!EICLOJA() .OR. SWB->WB_LOJA  == SW9->W9_FORLOJ) .AND. EVAL(bWhilSWB) .AND.;
                                            !lBaixa  // Bete - 30/07/04 - Se encontrar uma parcela baixada, encerra While

                  IF lExisCpoSWB .AND. !EMPTY(SWB->WB_TIPOTIT)
                     cTipo := SWB->WB_TIPOTIT
                     cLoja := SWB->WB_LOJA
                     cPref := SWB->WB_PREFIXO
                  ENDIF

                  cForn:= SWB->WB_FORN
                  cParcela := SWB->WB_PARCELA
                  IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400ANT_DI_001"),) // Jonato 10-Fev-2005

                  lBaixa:=IsBxE2Eic(cPref,SWB->WB_NUMDUP,cTipo,cForn,cLoja,,cParcela)

                  SWB->(DBSKIP())

               ENDDO

            ELSE

               lBaixa:=IsBxE2Eic("EIC",SW9->W9_NUM,"INV",SW9->W9_FORN,SA2->A2_LOJA)
               IF !lBaixa .AND. cPaisLoc == "CHI"
                  lBaixa:=IsBxE2Eic("EIC",SW9->W9_NUM,"JR ",SW9->W9_FORN,SA2->A2_LOJA)
               ENDIF

            ENDIF

         ENDIF

      ElseIf lAchouSWB

         lAltCambFS := (lAltFrete .AND. AvFlags("GERACAO_CAMBIO_FRETE")) .OR. (lAltSeguro .AND. AvFlags("GERACAO_CAMBIO_SEGURO"))  // GFP - 23/06/2015
         IF !lEncDesemb .AND. !lAltodasInvoice .AND.;
            ASCAN(aAltInvoice, SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") ) = 0 .AND.;
            ASCAN(aDeletados , {|D| D[1] = "SW9" .AND. D[2] = SW9->(RECNO()) }  ) = 0 .AND. !lAltCambFS  // GFP - 23/06/2015
            SW9->(DBSKIP())
            LOOP
         ENDIF

         IF cPaisLoc = "BRA"
            // EOB - 22/08/08 - Verifique se existe alguma parcela de câmbio liquidada para a invoice
			// lCambLiq := .F. - CCM 19/02/2009
			nRecSWB  := SWB->(recno())
            aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
            DO While SWB->(!Eof()) .And. SWB->WB_FILIAL  == cFilSWB         .AND.;
                                         SWB->WB_HAWB    == SW9->W9_HAWB    .AND.;
                                         If(AvFlags("GERACAO_CAMBIO_FRETE") .OR. AvFlags("GERACAO_CAMBIO_SEGURO"), .T., SWB->WB_INVOICE == SW9->W9_INVOICE) .AND.;
                                         If(AvFlags("GERACAO_CAMBIO_FRETE") .OR. AvFlags("GERACAO_CAMBIO_SEGURO"), .T., SWB->WB_FORN == SW9->W9_FORN .AND. (!EICLOJA() .OR. SWB->WB_LOJA == SW9->W9_FORLOJ)) .AND.;
                                         EVAL(bWhilSWB)  // GFP - 23/06/2015
			   IF !EMPTY(SWB->WB_CA_DT)
			      lCambLiq := .T.
			      EXIT
			   ENDIF

			   //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
	           SE2->(DbSetOrder(6))
               If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                  If SE2->E2_VALOR <> SE2->E2_SALDO
		             lCambLiq := .T.
                     Exit
		          Endif
		       Endif

			   SWB->(dbSkip())
			ENDDO
 		    SWB->(dbgoto(nRecSWB))
 		    RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010

            //* PLB 11/08/10 - Verifica se alguma foi baixada contra Pagamento Antecipado
            //IF LCAMBIO_EIC  .AND.  lGravaFin_EIC
			IF lGravaFin_EIC
			   nRecSWB  := SWB->(recno())

               IF !LCAMBIO_EIC
                  SWB->(DbSeek(xFilial("SWB")+cHawb+"D"))
               ENDIF

               DO While SWB->(!Eof()) .And. SWB->WB_FILIAL  == cFilSWB         .AND.;
                                            SWB->WB_HAWB    == SW9->W9_HAWB    .AND.  ;
                                            EVAL(bWhilSWB)
                  If Left(SWB->WB_TIPOREG,1) == "P"
                     lCambLiq := .T.
                     EXIT
                  EndIf
                  SWB->(dbSkip())
               ENDDO

			   SWB->(dbgoto(nRecSWB))
			Endif
            lAltdInv := lAltodasInvoice
            aAltInv  := aClone(aAltInvoice )
            IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'POS_VER_LIQ'),)
            If type("lAltdInv") == "L"
               lAltodasInvoice := lAltdInv
            ENDIF
            If type("aAltInv") == "A"
               aAltInvoice     := aClone(aAltInv)
            EndIf
			//**
 		    // Só irá deletar o título no financeiro, se não tiver nenhuma parcela baixada
 		    //IF !lCambLiq                                    //NCF - 14/03/2019 - Invoice deletada
            If lAltodasInvoice .Or. Len(aAltInvoice) > 0 .Or. aScan(aDeletados,{|x| x[1] == "SW9" .And. x[2] == SW9->(Recno()) }) > 0
               DO While SWB->(!Eof()) .And. SWB->WB_FILIAL  == cFilSWB         .AND.;
                                            SWB->WB_HAWB    == SW9->W9_HAWB    .AND.;
                                            SWB->WB_INVOICE == SW9->W9_INVOICE .AND.;
                                            SWB->WB_FORN    == SW9->W9_FORN  .AND. (!EICLOJA() .OR. SWB->WB_LOJA  == SW9->W9_FORLOJ) .AND. EVAL(bWhilSWB)
                                                                                                                                        //NCF - 14/03/2019 - Invoice deletada com título INV gerado.
                  If !lAltodasInvoice .And. ASCAN(aAltInvoice, SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") ) = 0 .And. !(  aScan(aDeletados,{|x| x[1] == "SW9" .And. x[2] == SW9->(Recno()) }) > 0 .And. !Empty(SWB->WB_NUMDUP)  )
                    SWB->(dbSkip())
                    Loop
                  EndIf

                  IF lExisCpoSWB .AND. !EMPTY(SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT)
                     AADD(aSWBChavesTit,{SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,""),SWB->WB_PREFIXO,SWB->WB_NUMDUP,SWB->WB_TIPOTIT,SWB->WB_PARCELA})
                  ENDIF

                  AADD( aSWBCampos, {SWB->WB_INVOICE+SWB->WB_FORN+IF(EICLOJA(),SWB->WB_LOJA,""),SWB->WB_BANCO,SWB->WB_AGENCIA,SWB->WB_NUM,SWB->WB_DT,SWB->WB_LC_NUM,SWB->WB_NR_ROF,SWB->WB_DT_ROF,SWB->WB_DT_CONT,SWB->WB_CA_NUM,SWB->WB_LIM_BAC,SWB->WB_ENV_BAC } )
       		      IF SWB->(FIELDPOS("WB_CONTA")) # 0
       		         AADD( aSWBCampos[LEN(aSWBCampos)], SWB->WB_CONTA )
       		      ENDIF

       		      // GFP - 07/11/2013 - Tratamento para recuperação de campos de usuário
       		      IF VALTYPE(aSWBUserCps) == "A"
       		         SX3->(DbSetOrder(1))
                     SX3->(dbSeek("SWB"))
                     While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWB"
                        If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V" //LRS - 06/02/2015 - Ignorar campos de Usuario do tipo Virtual no Câmbioadmin
                           AADD(aSWBUserCps,{SWB->WB_INVOICE+SWB->WB_FORN+IF(EICLOJA(),SWB->WB_LOJA,""),SWB->WB_LINHA,SX3->X3_CAMPO,SWB->(&(SX3->X3_CAMPO))})  // GFP - 28/11/2013
                        EndIf
                        SX3->(DbSkip())
                     EndDo
                  ENDIF

       		    IF !Empty(SWB->WB_CA_DT) .OR. !Empty(SWB->WB_PGTANT)  // GFP - 02/12/2015
       		       SWB->(DBSKIP())
       		       Loop
       		    ENDIF

       		    lDel_SWB := .T. //RMD - 01/08/13

                  IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'ANT_DEL_SWB'),)//JVR - 22/09/09

                  //** igor chiba integrar exclusao da parcela automatica 29/09/09
                  IF LCAMBIO_EIC
                     IF lGravaFin_EIC
                        If !Empty(SWB->WB_TITERP)  // PLB 15/04/10 - Verifica Existencia de Título para enviar Operação
                           cChave:= SWB->WB_FILIAL+SWB->WB_HAWB+SWB->WB_INVOICE+SWB->WB_LINHA
                           cSQLChv:= "WB_FILIAL = '"+SWB->WB_FILIAL+"' AND "+;
                                     "WB_HAWB = '"+SWB->WB_HAWB+"' AND "+;
                                     "WB_INVOICE = '"+SWB->WB_INVOICE+"' AND "+;
                                     "WB_LINHA = '"+SWB->WB_LINHA+"' " 
                           If FindFunction("EICINTEI17") 
                              EasyExRdm("EICINTEI17", 'E','CBO',cChave,'EX',cSQLChv)                              
                           EndIf   
                        EndIf
                     ENDIF
                  ENDIF
                  //**

                  //RMD - 01/08/13
                  IF lDel_SWB .And. (lGrv_Fin_EIC .Or. FI400TITFIN("SWB","4",.T.))
                     //WFS 04/12/14
                     If AvFlags("EIC_EAI")
                        AAdd(aEAIDeletados, {"SWB", SWB->(RecNo())})
                     Else
                        SWB->(RecLock("SWB",.F.))
                        SWB->(dbDelete())
                        SWB->(MSUNLOCK())
                     EndIf
                  ENDIF

                  SWB->(DBSKIP())
               ENDDO
            EndIf
               // GFP - 02/06/2015 - Tratamento de exclusão de titulos de contas a pagar referente a frete gerados pelo cambio
               nRecnoSWB := SWB->(Recno())
               If AvFlags("GERACAO_CAMBIO_FRETE") .And. lAltFrete
                  If SWB->(dbSeek(cFilSWB+SW9->W9_HAWB+"D"))
                     Do While SWB->(!Eof()) .And. SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB == SW9->W9_HAWB .And. SWB->WB_PO_DI == "D"
                        If Left(SWB->WB_TIPOREG,1) == "A"
                           If lLoop102 //LGS-01/12/2015 - Frete deve deletar da SWB, mas a despesa foi originada no numerario, portanto nao tem SE2
                              SWB->(RecLock("SWB",.F.))
                              SWB->(dbDelete())
                              SWB->(MSUNLOCK())
                           Else
                              If GeraTitCamb(AllTrim(SWB->WB_INVOICE),"4")
                                 SWB->(RecLock("SWB",.F.))
                                 SWB->(dbDelete())
                                 SWB->(MSUNLOCK())
                              EndIf
                           EndIf
                        EndIf
                        SWB->(DbSkip())
                     EndDo
                  EndIf
               EndIf
               // GFP - 02/06/2015 - Tratamento de exclusão de titulos de contas a pagar referente a seguro gerados pelo cambio
               If AvFlags("GERACAO_CAMBIO_SEGURO") .And. lAltSeguro
                  If SWB->(dbSeek(cFilSWB+SW9->W9_HAWB+"D"))
                     Do While SWB->(!Eof()) .And. SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB == SW9->W9_HAWB .And. SWB->WB_PO_DI == "D"
                        If Left(SWB->WB_TIPOREG,1) == "B"
                           If lLoop103 //LGS-01/12/2015 - Seguro deve deletar da SWB, mas a despesa foi originada no numerario, portanto nao tem SE2
                              SWB->(RecLock("SWB",.F.))
                              SWB->(dbDelete())
                              SWB->(MSUNLOCK())
                           Else
                              If GeraTitCamb(AllTrim(SWB->WB_INVOICE),"4")
                                 SWB->(RecLock("SWB",.F.))
                                 SWB->(dbDelete())
                                 SWB->(MSUNLOCK())
                              EndIf
                           EndIf
                        EndIf
                        SWB->(DbSkip())
                     EndDo
                  EndIf
               EndIf
               //WFS 04/12/14
               If AvFlags("EIC_EAI") .And. lDel_SWB
                  If !EICAP110(.T., 5, cHawb, "D")
                     lTitEAI_OK:= .F. //wfs
                     lCambLiq:= .T.
                  Else
                     For nCont:= 1 To Len(aEAIDeletados)
                        If aEAIDeletados[nCont][1] == "SWB"
                           SWB->(DBGoTo(aEAIDeletados[nCont][2]))
                           SWB->(RecLock("SWB",.F.))
                           SWB->(DBDelete())
                           SWB->(MsUnlock())
                        EndIf
                     Next
                  EndIf
               EndIf

               IF !SWB->(dbSeek(cFilSWB+SW9->W9_HAWB+"D"))
                  SWA->(DBSETORDER(1))
                  IF SWA->(DBSEEK(xFilial("SWA")+SW9->W9_HAWB+"D"))
                     SWA->(RecLock("SWA",.F.))
                     SWA->(dbDelete())
                     SWA->(MSUNLOCK())
                  ENDIF
               ENDIF
			//ELSE //alterado por WFS, para contemplar o cenário de integração com o Logix.
			//EndIf

          IF lCambLiq
				n := ASCAN(aAltInvoice, SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") )
				IF n > 0
				   ADEL(aAltInvoice, n)
				   ASIZE( aAltInvoice, LEN(aAltInvoice)-1 )
				ENDIF
			ENDIF

         ELSE

            DeleDupEIC("EIC",SW9->W9_NUM,-1,"INV",SW9->W9_FORN,SA2->A2_LOJA,"SIGAEIC")
            IF cPaisLoc == "CHI"
               DeleDupEIC("EIC",SW9->W9_NUM,-1,"JR ",SW9->W9_FORN,SA2->A2_LOJA,"SIGAEIC")
            ENDIF
            SW8->(DBSEEK(xFilial("SW8")+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
            IF FI400FornBanco(SW8->W8_PO_NUM,SW8->W8_PGI_NUM)   //Reposiciona o SA2 com o fornecedor do cadastro de Banco
               DeleDupEIC("EIC",SW9->W9_NUM,-1,"INV",SA6->A6_CODFOR,SA6->A6_LOJFOR,"SIGAEIC")
               IF cPaisLoc == "CHI"
                  DeleDupEIC("EIC",SW9->W9_NUM,-1,"JR ",SA6->A6_CODFOR,SA6->A6_LOJFOR,"SIGAEIC")
               ENDIF
            ENDIF
            IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") } ) = 0
               AADD(aTitInvoiceIAE,{ SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,""), .T. } )
            ENDIF

         ENDIF

         IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400ANT_DI'),)
      
      ENDIF
      SW9->(DBSKIP())
   ENDDO

   IF !lVal
      IncProc()
      IF cPaisLoc # "BRA"
         FI400ManutCambio('ESTORNA',cHawb)
      ENDIF
   ENDIF
   IF lGRV_FIN_EIC .AND. IF(lVal, !lBaixa, !lCambLiq) .And. lAltodasInvoice  //** BHF - Bete - 09/12/08
      FI400ManutCambio('ESTORNA',cHawb)
   ENDIF

ELSEIF !lVal //AWR - 23/06/2006 - Nao pode fazer isso quando tiver validando

   SWB->(dbSeek(cFilSWB+SW6->W6_HAWB+'D'))

   DO While SWB->(!Eof()) .And. SWB->WB_FILIAL  == cFilSWB         .AND.;
            SWB->WB_HAWB  == SW6->W6_HAWB .AND.;
            SWB->WB_PO_DI == "D"

//      IF lExisCpoSWB .AND. !EMPTY(SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT)
//         AADD(aSWBChavesTit,{SWB->WB_INVOICE+SWB->WB_FORN,SWB->WB_PREFIXO,SWB->WB_NUMDUP,SWB->WB_TIPOTIT,SWB->WB_PARCELA})
//      ENDIF

      IF lFinanceiro .And. FI400TITFIN("SWB","4",.T.)//Exclusao
         SWB->(RecLock("SWB",.F.))
         SWB->(dbDelete())
         SWB->(MSUNLOCK())
      ENDIF

      SWB->(DBSKIP())
   ENDDO

   IF !SWB->(dbSeek(cFilSWB+SW6->W6_HAWB+"D"))
     SWA->(DBSETORDER(1))
     IF SWA->(DBSEEK(xFilial("SWA")+SW6->W6_HAWB+"D"))
       SWA->(RecLock("SWA",.F.))
       SWA->(dbDelete())
       SWA->(MSUNLOCK())
     ENDIF
   ENDIF
Else // SVG - 04/05/2011 - Verificação se existe PA baixado e não permite a exclusão.
   cTipo := ""
   cLoja := ""
   cPref := ""
   cFilSWB := xFilial("SWB")
   SWB->(dbSetorder(1))
   If SWB->(DBSEEK(cFilSWB + cHawb /*SW6->W6_HAWB*/ )) //LGS-05/08/2014
      While SWB->(!EOF()) .And. /*SW6->W6_HAWB*/cHawb == SWB->WB_HAWB .And. !lBaixa
         IF lExisCpoSWB .AND. !EMPTY(SWB->WB_TIPOTIT)
            cTipo := SWB->WB_TIPOTIT
            cLoja := SWB->WB_LOJA
            cPref := SWB->WB_PREFIXO
         ENDIF
         cForn:= SWB->WB_FORN
         cParcela := SWB->WB_PARCELA

         lBaixa:=IsBxE2Eic(cPref,SWB->WB_NUMDUP,cTipo,cForn,cLoja,,cParcela)

         SWB->(dbSkip())
      EndDo
   Endif
ENDIF

// EOS - 06/10/03
IF cPaisLoc # "BRA" .AND. lExistEZZ
   cFilEZZ:=xFilial("EZZ")
   EZZ->(DBSETORDER(1))
   EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB))
   DO WHILE !EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ ;
                          .AND. EZZ->EZZ_HAWB   == SW6->W6_HAWB
      SA2->(DBSEEK(cFilSA2+EZZ->EZZ_FORN+EICRetLoja("EZZ","EZZ_FORLOJ")))
      IF lVal
         IF !lBaixa
            lBaixa:=IsBxE2Eic("EIC",EZZ->EZZ_NUM,"INV",EZZ->EZZ_FORN,SA2->A2_LOJA)
         ENDIF
      ELSE
          DeleDupEIC("EIC",EZZ->EZZ_NUM,-1,"INV",EZZ->EZZ_FORN,SA2->A2_LOJA,"SIGAEIC")
      ENDIF
      EZZ->(dbSkip())
   ENDDO
ENDIF

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400ANT_DI_2'),)

//AWR - 17/08/2004 - As alterações no desembaraço independe dos titulos das despesas estarem baixados
//IF lVal .and. !lBaixa
//   lBaixa:=FI400Baixou(cHawb)
//ENDIF

IncProc()
SW9->(DBSETORDER(nInd))
SELECT(nAlias)

RETURN lBaixa

*------------------------------------------------------------------*
FUNCTION FI400POS_DI(cHawb,lGRV_FIN_EIC,cAliasSW9,cAliasSW6,cAltera)
*------------------------------------------------------------------*
LOCAL WWind, cChave, TFobMoe, TInvoice
LOCAL nValor_Inv:=_LenTab:=nCont:=0
LOCAL nParc
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilSW2:=xFilial("SW2")
LOCAL cFilSW8:=xFilial("SW8")
LOCAL cFilSW9:=xFilial("SW9")
LOCAL aJurosInv:={}
LOCAL lIgnoraPO:=.t.,cNroDupl:=""    , xpInv
Local lExistEZZ  := SX2->(dbSeek("EZZ")) // EOS - 07/10/03
//Local nChr:=Asc(Alltrim(EasyGParam("MV_1DUP"))) - 1

Local cMensInv := ""

//** GFC - 03/03/06 - Cambio de Comissão, Frete e Seguro
Local /*cAliasSW8:="",*/ ni, lRetorno:=.F.
Local aJaCom:={}, nJaCom:=0, nJaFrete:=0, nJaSeg:=0
Local aInvDel:={}, aInvDif:={}, aAltCamb:={}
LOCAL cSQLChv:=""
LOCAL lTaxaEmissaoInvoice:= EasyGParam("MV_EIC0013",,.F.) //TDF - 30/08/11
//**

Local nParFret:= 0
Local nParSeg := 0
Local lRet := .T.
Local lGeraFreWB := lGeraFrete
Local lGeraSegWB := lGeraSeg
Local dDtCot := CTOD("")
Private lAltdInv, aAltInv

If AvFlags("EIC_EAI") .AND. Empty(cAltera) .AND. lGravaFin_EIC .AND. Altera
   If EasyGParam("MV_CAMBFRE",,.F.) .and.;
   (M->W6_FORNECF <> SW6->W6_FORNECF .OR.;
   M->W6_FREMOED <> SW6->W6_FREMOED .OR.;
   M->W6_VLFRECC <> SW6->W6_VLFRECC .OR.;
   M->W6_VENCFRE <> SW6->W6_VENCFRE .OR.;
   M->W6_CONDP_F <> SW6->W6_CONDP_F .OR. M->W6_DIASP_F <> SW6->W6_DIASP_F .OR. Type("lAltFreEAI") == "L" .AND. lAltFreEAI)//Necessaria variavel lAltFreEAI devido a existencia de uma var. static lAltFrete neste fonte
      cAltera := "2"
   EndIf

   If EasyGParam("MV_CAMBSEG",,.F.) .AND.;
   (M->W6_FORNECS <> SW6->W6_FORNECS .OR.;
   M->W6_SEGMOED <> SW6->W6_SEGMOED .OR.;
   M->W6_VL_USSE <> SW6->W6_VL_USSE .OR.;
   M->W6_VENCSEG <> SW6->W6_VENCSEG .OR.;
   M->W6_CONDP_S <> SW6->W6_CONDP_S .OR. M->W6_DIASP_S <> SW6->W6_DIASP_S .OR. Type("lAltSeg") == "L" .AND. lAltSeg)
      cAltera := if(cAltera == "2", "1", If( cAltera == Nil,"","3") )
   EndIf
EndIf

PRIVATE cAltValid := cAltera//JVR - 15/09/09
PRIVATE lWB_ALTERA := SWB->(FieldPos("WB_ALTERA")) > 0  // TLM 14/05/2008
PRIVATE cForn:='',cLoja:='', nPos
lSair:=.F.

//AvStAction("208",.F.)  // JWJ 05/06/09
//OAP - Substituição feita no antigo EICPOCO
IF EasyGParam("MV_EIC_PCO",,.F.)
   IF EasyGParam("MV_PCOIMPO",,.T.) .AND. EasyGParam("MV_PCOFOB",,.F.) == .F. .AND. SW6->W6_IMPCO == '1'
      lSair := .T.
   ENDIF
ENDIF

lAltdInv := lAltodasInvoice
aAltInv  := aClone(aAltInvoice )
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400POS_DI_INICIO"),)
If type("lAltdInv") == "L"
   lAltodasInvoice := lAltdInv
ENDIF
If type("aAltInv") == "A"
   aAltInvoice     := aClone(aAltInv)
EndIf
		
IF lSair
   RETURN .F.
ENDIF
PRIVATE aTabInv:={},aFornPOCC:={},aTotInv:={}
PRIVATE dDtaVista,dDtEMB:= CtoD("") ,  Wind
Private cAliasSW8:=""
//SVG - 18/03/2011 -
If Type("cAliasSW9") != "U"
   cAlSW9rdm:= cAliasSW9
EndIf
//** GFC - 06/03/06
Private aJaPrinc:={}, nJaPrinc:=0

Private oErrorFin  := AvObject():New() //AOM - 28/07/2011 - Mensagens de Erros
Private cUltParc := ""  // GFP - 20/01/2014

//**

//WFS
If Type("lCambio_eic") <> "L"
   lCambio_eic:= AVFLAGS("AVINT_CAMBIO_EIC")
EndIf

ProcRegua(4)

IF lGRV_FIN_EIC = NIL
   lGRV_FIN_EIC:=.F.
ENDIF

//** GFC - 03/03/06 - Cambio de Comissão, Frete e Seguro
If cAltera = NIL
   cAltera := ""
EndIf

If cAliasSW6 = NIL
   cAliasSW6 := "SW6"
EndIf
If cAliasSW9 = NIL
   cAliasSW9 := "SW9"
EndIf
If cAliasSW9 == "SW9"
   cAliasSW8 := "SW8"
Else
   cAliasSW8 := "Work_SW8"
EndIf
//**

SA2->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SY6->(DBSETORDER(1))
SW4->(DBSETORDER(1))

If cAliasSW6 == "SW6"
   SW6->(DBSEEK(xFilial("SW6")+cHawb))
EndIf

/*IF !lDataEMB
   cDatEmb := cAliasSW6+"->W6_DT_EMB"
ELSE
   cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD",cAliasSW6+"->W6_DT_EMB"))
ENDIF*/
PRIVATE lGeraTitInv := .T. // MCF - 03/10/08 - Variável utilizada para validar geração de Titulos INV
PRIVATE lLoop102 := lLoop103 := .F. //LGS-26/11/2015

IncProc()


SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
EC6->(dbSetOrder(1))

If cAliasSW9 == "SW9"
   SW9->(DBSEEK(cFilSW9+cHawb))
Else
   Work_SW9->(dbGoTop())
EndIf

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_DI_0'),)
ProcRegua(10)
nCont:=0
//ISS-08/12/2010 - Tratamento para a variável cDatEmb e dDtEmb colocado novamente dentro do loop da SW9, pois assim a
//                 variável dDtEmb vai ser atualizada de acordo com a invoice corrente.
//NCF-08/06/2010 - Os blocos com tratamento das variáveis de data de embarque foram movidos para fora do Loop da SW9
//                 uma vez que a data era enviada nula (quando não há invoice no embarque) ocasionando error.log
/*
IF !lDataEMB//Ask 17/07/2007 - Tratamento do parâmetro MV_DTB_APD
   cDatEmb := "SW6->W6_DT_EMB"
ELSE
   cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
ENDIF

if "W6_DT_EMB" $ cDatEmb
   if EMPTY(&cDatEmb)
      cDatEmb := "SW6->W6_DT_ETD" // NCF 13/05/09  - Pega a data ETD se a data de Embarque não
   EndIf
EndIf
*/

nValor_Inv:= 0

/*
If SubStr(cDatEmb,4,2) == "->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
   If Left(cDatEmb,3) == "SW6"
      dDtEMB:= &(cAliasSW6 + "->" + Right(cDatEmb,Len(cDatEmb)-5))
   ElseIf Left(cDatEmb,3) == "SW9"
      dDtEMB:= &(cAliasSW9 + "->" + Right(cDatEmb,Len(cDatEmb)-5))
   EndIf
ElseIf SubStr(cDatEmb,3,1) == "_" //Caso o conteúdo do parâmentro possuir apenas o campo
   If Left(cDatEmb,2) == "W6"
      dDtEMB := &(cAliasSW6 + "->" + cDatEmb )
   ElseIf Left(cDatEmb,2) == "W9"
      dDtEMB := &(cAliasSW9 + "->" + cDatEmb )
   EndIf
EndIf
*/

dDtEMB:= FI400DTRefTaxa(cAliasSW6, cAliasSW9,,.F.)
dDtaVista:=IF(!EMPTY(&(cAliasSW6+"->W6_DT_DESEM")),&(cAliasSW6+"->W6_DT_DESEM"),dDtEMB)

lSegInv := .F.  // EOB - 30/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
DO WHILE !(cAliasSW9)->(EOF()) .AND. If(cAliasSW9=="SW9", AvKey(cHawb,"W9_HAWB")==SW9->W9_HAWB .AND. cFilSW9==SW9->W9_FILIAL, .T.)

   nValor_Inv := 0
   nVlr_Item  := 0
   
   /* wfs - movido para a função FI400DTRefTaxa(), evitando duplicação de código
   IF !lDataEMB//Ask 17/07/2007 - Tratamento do parâmetro MV_DTB_APD
      cDatEmb := "SW6->W6_DT_EMB"
   ELSE
      cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
   ENDIF

   if "W6_DT_EMB" $ cDatEmb
      if EMPTY(&cDatEmb)
         cDatEmb := "SW6->W6_DT_ETD" // NCF 13/05/09  - Pega a data ETD se a data de Embarque não
      EndIf
   EndIf

   If SubStr(cDatEmb,4,2) == "->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
      If Left(cDatEmb,3) == "SW6"
         dDtEMB:= &(cAliasSW6 + "->" + Right(cDatEmb,Len(cDatEmb)-5))
      ElseIf Left(cDatEmb,3) == "SW9"
         dDtEMB:= &(cAliasSW9 + "->" + Right(cDatEmb,Len(cDatEmb)-5))
      EndIf
   ElseIf SubStr(cDatEmb,3,1) == "_" //Caso o conteúdo do parâmentro possuir apenas o campo
      If Left(cDatEmb,2) == "W6"
         dDtEMB := &(cAliasSW6 + "->" + cDatEmb )
      ElseIf Left(cDatEmb,2) == "W9"
         dDtEMB := &(cAliasSW9 + "->" + cDatEmb )
      EndIf
   EndIf

   IF EMPTY(dDtEMB)
      dDtEMB := &(cAliasSW6+"->W6_DT_EMB")
      IF EMPTY(dDtEMB)
         dDtEMB := &(cAliasSW6+"->W6_DT_ETA")
         IF EMPTY(dDtEMB)
            dDtEMB := dDataBase
         ENDIF
      ENDIF
   ENDIF
   */
   
   dDtEMB:= FI400DTRefTaxa(cAliasSW6, cAliasSW9)

   dDtaVista:=IF(!EMPTY(&(cAliasSW6+"->W6_DT_DESEM")),&(cAliasSW6+"->W6_DT_DESEM"),dDtEMB)

   // EOB - 30/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF AvRetInco((cAliasSW9)->W9_INCOTER,"CONTEM_SEG")/*FDR - 28/12/10*/  //(cAliasSW9)->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
      lSegInv := .T.
      lAltSeguro := .F.
   ENDIF
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_DI_dDtEMB'),)//SVG - 18/03/2011 -
   If Empty(cAltera) .or. (cAltera == "4" .and. Work_SW9->W9_ALTCAMB == "1") // --> GFC - 06/03/06

      IF !lAltodasInvoice .AND.;
         ASCAN(aAltInvoice, SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") ) = 0 .AND. !lGRV_FIN_EIC
         SW9->(DBSKIP())
         LOOP
      ENDIF

      If cAliasSW8 == "SW8"
         SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
      Else
         Work_SW8->(dbSetOrder(1))
         Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9","W9_FORLOJ")))
      EndIf

      IF !lGRV_FIN_EIC
         ////ASK 12/09/2007 - Quando Brasil, só trata invoice se a terceira letra for "I", ou seja
         // só gerará o N° do titulo com o N° da invoice se a 3ª letra for "I", senão gera só das despesas do PA.
         //IF cPaisLoc # "BRA" .AND. SUBSTR(c_DuplDoc,1,1) == "S"
         If SUBSTR(c_DuplDoc,1,1) == "S" .and. (cPaisLoc == "BRA" .and. SUBSTR(c_DuplDoc,3,1) == "I") .or. ;
            cPaisLoc <> "BRA"
            IF SUBSTR(c_DuplDoc,2,1) == "R"
               cNroDupl := RIGHT(ALLTRIM(SW8->W8_INVOICE),LEN(SE2->E2_NUM))
            ELSE
               cNroDupl := LEFT(ALLTRIM(SW8->W8_INVOICE),LEN(SE2->E2_NUM))
            ENDIF
         ELSE
            /*IF FindFunction("AvgNumSeq")//AVGERAL.PRW
               cNroDupl :=AvgNumSeq("SW9","W9_NUM")
            ELSE
               cNroDupl :=GetSXENum("SW9","W9_NUM")
               ConfirmSX8()
            ENDIF*/
            cNroDupl := If(!Empty(SW9->W9_NUM),SW9->W9_NUM,NumTit("SW9","W9_NUM"))  // GFP - 07/12/2015
         ENDIF
        	  //JAP - 03/07/06 - Acerto no tamanho alterável do numero do título gerado no financeiro.
        	  IF Len(cNroDupl) < Len(SE2->E2_NUM)
                 nTam := Len(SE2->E2_NUM) - Len(cNroDupl)
                 cNroDupl := cNroDupl + Space(nTam)
              ENDIF
      ENDIF
      lPrimItem:=.T.
      DO WHILE !(cAliasSW8)->(EOF()) .AND. If (cAliasSW9=="SW9",SW8->W8_FILIAL==cFilSW8 .and. SW9->W9_HAWB==SW8->W8_HAWB .and. (cAliasSW9)->W9_INVOICE == SW8->W8_INVOICE .and. (cAliasSW9)->W9_FORN == SW8->W8_FORN .AND. (!EICLOJA() .OR. (cAliasSW9)->W9_FORLOJ == SW8->W8_FORLOJ),(cAliasSW9)->W9_INVOICE == Work_SW8->WKINVOICE .AND. (cAliasSW9)->W9_FORN == Work_SW8->WKFORN .AND. (!EICLOJA() .OR. (cAliasSW9)->W9_FORLOJ == Work_SW8->W8_FORLOJ) )

         IF nCont=10
            ProcRegua(10);nCont:=0
         ELSE
            IncProc();nCont++
         ENDIF

         If SW2->(W2_FILIAL + W2_PO_NUM) <> cFilSW2 + If(cAliasSW8 == "SW8", SW8->W8_PO_NUM, Work_SW8->WKPO_NUM) //wfs - out/2019: ajustes de performance
            SW2->(DBSEEK(cFilSW2+If(cAliasSW8=="SW8", SW8->W8_PO_NUM, Work_SW8->WKPO_NUM)))
         EndIf

         //TRP-28/10/08 - Acumulação dos valores das invoices para que o "rateio" seja feito apenas uma vez, evitando problemas de arredondamento.
         If cAliasSW8 == "SW8"
            // SVG - 30/11/2010 - Inserido array com o valor das parcelas separadas devido a problemas de arredondamento
			nVlr_Item  := DI500TRANS(DI500RetVal("ITEM_INV", "TAB", .T.))  // EOB - 28/05/08 - chamada da função DI500RetVal
            nValor_Inv += nVlr_Item //aqui pega o valor
            aAdd(aTotInv,nVlr_Item)
			//*** SVG - 30/11/2010 -
         Else
		    // SVG - 30/11/2010 - Inserido array com o valor das parcelas separadas devido a problemas de arredondamento
            nVlr_Item  := DI500TRANS(DI500RetVal("ITEM_INV", "WORK", .T.))  // EOB - 28/05/08 - chamada da função DI500RetVal
            nValor_Inv += nVlr_Item
            aAdd(aTotInv,nVlr_Item)
			//*** SVG - 30/11/2010 -
         EndIf

         IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_DI_1'),)
         //lPrimItem:=.F.               	//NCF - 28/05/09 - Nopado por não estar permitindo a geração
         (cAliasSW8)->(DBSKIP())            //                 do câmbio de comissão no desembaraço
      ENDDO
     //LRS - 13/07/2015 - Retirado a validação de dentro do while para não gerar valor errado.
     If EasyGParam("MV_IN327" ,,.F.) .AND. !Empty((cAliasSW9)->W9_DESCONT)  // GFP - 23/06/2015
        nValor_Inv -= (cAliasSW9)->W9_DESCONT
     EndIf
//aqui talvez seja um ponto pra gera o segundo câmbio
      If cAliasSW9 == "SW9" //gera pelo desembaraço
         EicCalcPagto((cAliasSW9)->W9_INVOICE+(cAliasSW9)->W9_FORN+IF(EICLOJA(),(cAliasSW9)->W9_FORLOJ,""),nValor_Inv,dDtEMB,dDtaVista,(cAliasSW9)->W9_COND_PA+STR((cAliasSW9)->W9_DIAS_PA,3) ,aTabInv,cNroDupl ,, ,lIgnoraPO,If(lGRV_FIN_EIC .and. lGeraCom .AND. lPrimItem,(cAliasSW9)->W9_VALCOM,0),,aTotInv)// .and. nCont=1
      Else
         EicCalcPagto(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,""),nValor_Inv,dDtEMB,dDtaVista,(cAliasSW9)->W9_COND_PA+STR((cAliasSW9)->W9_DIAS_PA,3),aTabInv,cNroDupl,, ,lIgnoraPO,If(lGRV_FIN_EIC .and. lGeraCom .AND. lPrimItem,(cAliasSW9)->W9_VALCOM,0),,aTotInv)// .and. nCont=1
      EndIf

      //** GFC - 06/03/06
      //ASK - 23/07/07 - Ajustes na alteração do câmbio quando lWB_TP_CON = .F.
     If lGRV_FIN_EIC .and. cAltera == "4" .and. Work_SW9->W9_ALTCAMB == "1"
        aAdd(aAltCamb,{Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,IF(EICLOJA(),Work_SW9->W9_FORLOJ,"")})
     EndIf
     If lWB_TP_CON
        IF !EMPTY(Work_SW9->W9_FORNECC)
           aAdd(aAltCamb,{Work_SW9->W9_INVOICE,Work_SW9->W9_FORNECC,IF(EICLOJA(),Work_SW9->W9_LOJAC,"")})
        ENDIF
      EndIf

      IF LEN(aTabInv) > 0 .AND. ASCAN(aTabInv,{|aInv|aInv[5]==cNroDupl}) # 0 .AND. !lGRV_FIN_EIC
         SW9->(RECLOCK("SW9",.F.))

         SW9->W9_NUM := cNroDupl
         SW9->(MSUNLOCK())

         IF cPaisLoc='CHI' .AND. SW9->W9_JUROS # 0
            For xpInv:=1 to Len(aTabInv)
                nParInv:=0
                IF aTabInv[xpInv,1]==SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"")
                   nFatorInv:=aTabInv[xpInv,2]/ DI500RetVal("TOT_INV", "TAB", .T.)  // EOB - 28/05/08 - chamada da função DI500RetVal
                   AADD(aJurosInv,{SW9->W9_INVOICE,;
                                   SW9->W9_JUROS*nFatorInv,;
                                   aTabInv[xpInv,3],;//Data
                                   aTabInv[xpInv,5],;//Duplicata
                                   xPInv})
                Endif
            Next xpInv
         ENDIF

      ENDIF
   EndIf

   RollBackSX8()
   (cAliasSW9)->(DBSKIP())

ENDDO
SW9->(DBSETORDER(1))

//** GFC - 06/03/06
//If lWB_TP_CON .and. SWB->(dbSeek(xFilial("SWB")+&(cAliasSW6+"->W6_HAWB")+If(lCposAdto,"D","")))
//ASK - 23/07/07 - Ajustes na alteração do câmbio quando lWB_TP_CON = .F.
If SWB->(dbSeek(xFilial("SWB")+&(cAliasSW6+"->W6_HAWB")+If(lCposAdto,"D","")))
   Do While !SWB->(EOF()) .and. SWB->WB_FILIAL == xFilial("SWB") .and. SWB->WB_HAWB==&(cAliasSW6+"->W6_HAWB") .and.;
   If(lCposAdto,SWB->WB_PO_DI=="D",.T.)
      If Left(SWB->WB_TIPOREG,1) == "A"
         If cAltera $ ("1/2") //.AND. lWB_ALTERA .AND. SWB->WB_ALTERA <> "1"
            If aScan(aInvDel,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
               aAdd(aInvDel,{SWB->WB_INVOICE,SWB->WB_FORN,"",IF(EICLOJA(),SWB->WB_LOJA,"")})
            EndIf
            SWB->(RecLock("SWB",.F.,.T.))
            SWB->(DBDELETE())
            SWB->(MSUnlock())
         Else
            If cAltera $ ("1/2") .and. aScan(aInvDif,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
               aAdd(aInvDif,{SWB->WB_INVOICE,SWB->WB_FORN,"",IF(EICLOJA(),SWB->WB_LOJA,"")})
            EndIf
            nJaFrete += SWB->WB_FOBMOE
         EndIf
      ElseIf Left(SWB->WB_TIPOREG,1) == "B"
         If cAltera $ ("1/3") //.AND. lWB_ALTERA .AND. SWB->WB_ALTERA <> "1"
            If aScan(aInvDel,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
               aAdd(aInvDel,{SWB->WB_INVOICE,SWB->WB_FORN,"",IF(EICLOJA(),SWB->WB_LOJA,"")})
            EndIf
            SWB->(RecLock("SWB",.F.,.T.))
            SWB->(DBDELETE())
            SWB->(MSUnlock())
         Else
            If cAltera $ ("1/3") .and. aScan(aInvDif,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
               aAdd(aInvDif,{SWB->WB_INVOICE,SWB->WB_FORN,"",IF(EICLOJA(),SWB->WB_LOJA,"")})
            EndIf
            nJaSeg   += SWB->WB_FOBMOE
         EndIf
      ElseIf Left(SWB->WB_TIPOREG,1) == "C"
         If (cAltera=="4" .and. aScan(aAltCamb,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"") }) > 0) .or.;
         Empty(cAltera)
            If cAltera == "4" .AND. lWB_ALTERA .AND. SWB->WB_ALTERA <> "1"
               If aScan(aInvDel,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
                  aAdd(aInvDel,{SWB->WB_INVOICE,SWB->WB_FORN,STR0105,IF(EICLOJA(),SWB->WB_LOJA,"")}) //STR0105 "Comissão"
               EndIf
               SWB->(RecLock("SWB",.F.,.T.))
               SWB->(DBDELETE())
               SWB->(MSUnlock())
            Else
               If cAltera == "4" .and. aScan(aInvDif,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
                  aAdd(aInvDif,{SWB->WB_INVOICE,SWB->WB_FORN,STR0105,IF(EICLOJA(),SWB->WB_LOJA,"")}) //STR0105 "Comissão"
               EndIf
               If (nPos:=aScan(aJaCom,{|x| x[1]==SWB->WB_INVOICE})) > 0
                  aJaCom[nPos,2] += SWB->WB_FOBMOE
               Else
                  aAdd(aJaCom,{SWB->WB_INVOICE,SWB->WB_FOBMOE})
               EndIf
            EndIf
         EndIf
      ElseIf Left(SWB->WB_TIPOREG,1) == "1"
         If (cAltera=="4" .and. aScan(aAltCamb,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"") }) > 0) .or.;
         Empty(cAltera)
            If cAltera == "4" .AND. lWB_ALTERA .AND. SWB->WB_ALTERA <> "1"
               If aScan(aInvDel,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
                  aAdd(aInvDel,{SWB->WB_INVOICE,SWB->WB_FORN,STR0106,IF(EICLOJA(),SWB->WB_LOJA,"")}) //STR0106 "Principal"
               EndIf
               SWB->(RecLock("SWB",.F.,.T.))
               SWB->(DBDELETE())
               SWB->(MSUnlock())
            Else
               If cAltera == "4" .and. aScan(aInvDif,{|x| x[1]==SWB->WB_INVOICE .and. x[2]==SWB->WB_FORN .and. IF(EICLOJA(),x[4]==SWB->WB_LOJA,"")}) = 0
                  aAdd(aInvDif,{SWB->WB_INVOICE,SWB->WB_FORN,STR0106,IF(EICLOJA(),SWB->WB_LOJA,"")}) //STR0106 "Principal"
               EndIf
               If (nPos:=aScan(aJaPrinc,{|x| x[1]==SWB->WB_INVOICE})) > 0
                  aJaPrinc[nPos,2] += ( SWB->WB_FOBMOE + SWB->WB_PGTANT )            //NCF - 11/01/2017 - Considerar o valor antecipado que pode estar ou não já vinculado à câmbio de Adiantamento Liquidado
               Else
                  aAdd(aJaPrinc,{SWB->WB_INVOICE, SWB->WB_FOBMOE + SWB->WB_PGTANT }) //NCF - 11/01/2017
               EndIf
            EndIf
         EndIf
      EndIf
      SWB->(dbSkip())
   EndDo
EndIf
//**

//DFS - Criação de ponto de entrada para alterar o array referente a tabela de invoice através de customização
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'ALTERA_TABINV'),)

_LenTab := LEN( aTabInv )
TInvoice:= cNroDupl:=""
WWind := 1
nParc:= 1
IF _LenTab # 0 .AND. LEN( aTabInv[1] ) # NIL
   ProcRegua(_LenTab+2)
ELSE
   If lGRV_FIN_EIC .OR. AvFlags("GERACAO_CAMBIO_FRETE") .OR. AvFlags("GERACAO_CAMBIO_SEGURO")
      lRetorno := .T.
   Else
      IncProc()
      Return .F.
   EndIf
ENDIF
nLinha:=1
IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	FOR WWind := 1 TO _LenTab
	   Wind := WWind
	   IncProc()

	   SW9->(DBSETORDER(1)) //FDR-26/11/2014

	   IF TInvoice # aTabInv[Wind,1] .OR. cNroDupl # aTabInv[Wind,5]
		  nParc:= 1
	   ELSE
		  nParc++
	   ENDIF
	   TInvoice := aTabInv[Wind,1]//Chave
	   cNroDupl := aTabInv[Wind,5]//Numero da duplicata
	   TFobMoe  := aTabInv[Wind,2]//Valor

	   (cAliasSW9)->(DBSEEK(If(cAliasSW9=="SW9",xFilial("SW9"),"")+TInvoice))
	   If cAliasSW9 == "SW9"
		  DO WHILE !SW9->(EOF()) .AND. ;
					SW9->W9_FILIAL  == xFilial("SW9") .AND. ;
					ALLTRIM(SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"")) == ALLTRIM(TInvoice)
			 IF SW9->W9_HAWB == SW6->W6_HAWB
				EXIT
			 ENDIF
			 SW9->(DBSKIP())
		  ENDDO
	   EndIf

	   nRecnoSW9:=(cAliasSW9)->(RECNO())

	   IF !lGRV_FIN_EIC
		  SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB+TInvoice))//O fornecedor eh do Pedido da Invoice
		  SA2->(DBSEEK(cFilSA2+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")))
		  cForn:=SW8->W8_FORN
		  cLoja:=SA2->A2_LOJA

		  IF FI400FornBanco(SW8->W8_PO_NUM,SW8->W8_PGI_NUM)
			 cForn:= SA6->A6_CODFOR
			 cLoja:= SA6->A6_LOJFOR
		  ENDIF

		  IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400POS_DI_001"),) // Jonato 10-Fev-2005

		  IF cPaisLoc = "BRA"
			 cPrefixo  := ""                          //M->E2_PREFIXO
			 cIniDocto := cNroDupl                    //M->E2_NUM
			 cTIPO_Tit := "INV"                       //M->E2_TIPO
			 cCodFor   := cFORN                       //M->E2_FORNECE
			 cLojaFor  := cLOJA                       //M->E2_LOJA
			 nMoedSubs := SimbToMoeda(SW9->W9_MOE_FOB)//M->E2_MOEDA
			 nValorS   := TFobMoe                     //M->E2_VLCRUZ
			 //cEMISSAO  := SW9->W9_DT_EMIS             //M->E2_EMISSAO
			 cEMISSAO  := &(dDtEmis)
			 cDtVecto  := If(Empty(aTabInv[Wind,3]),SW9->W9_DT_EMIS,aTabInv[Wind,3]) //M->E2_VENCTO
			 IF cEMISSAO > cDtVecto
				cEMISSAO:=cDtVecto                    //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
			 ENDIF
			 If lTaxaEmissaoInvoice

				//TDF - 13/11/12 - Trecho substituido pela função BuscaTaxa
            dDtCot := &(FI400DtEmInvCpo())
				nTxMoeda  := BuscaTaxa(SW9->W9_MOE_FOB,dDtCot,,.T.,.T.)

				/*If SYE->(DBSEEK(xFilial("SYE")+AVKEY(SW9->W9_DT_EMIS,"YE_DATA")+AVKEY(SW9->W9_MOE_FOB,"YE_MOEDA")))
				   nTxMoeda  := SYE->YE_VLFISCA       //M->E2_TXMOEDA
				Else
				   MsgInfo(STR0107) //STR0107 "Não foi encontrada cotação da moeda na data de emissão da Invoice"
				   nTxMoeda  := SW9->W9_TX_FOB
				EndIf */
			 Else
				nTxMoeda  := SW9->W9_TX_FOB           //M->E2_TXMOEDA
			 EndIF


			 //cHistorico:= "P: "+ALLTRIM(cHawb)+" I: "+ALLTRIM(TInvoice)//M->E2_HIST
			 cHistorico:= AvKey("P: "+ALLTRIM(cHawb)+" I: "+ALLTRIM(TInvoice),"E2_HIST")//acb - 15/09/2010
			 /*If nParc > 0  // GFP - 22/01/2014
				cParcela := FI400TamCpoParc(nChr,nParc)
			 EndIf*/
			 If nParc > 0   // GFP - 12/03/2014
				cParcela := EasyGetParc(nParc)
			 EndIf
			 IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ANTES_INC_TIT_INV"),)

			 IF (nPosTit:=ASCAN(aSWBChavesTit, { |aTit| aTit[1] == SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") } )) # 0
				cPrefixo := aSWBChavesTit[nPosTit,2]
	//            cIniDocto:= aSWBChavesTit[nPosTit,3] //SVG - 25/03/2011 - cInidocto ja preechido, e dados gravados na base, causava inconsistencia entre SW9 e SE2
				cTIPO_Tit:= If(!Empty(aSWBChavesTit[nPosTit,4]),aSWBChavesTit[nPosTit,4],"INV") // RRV - Ajuste para preenchimento correto do tipo do título na tela de contas a pagar quando o mesmo não está gravado na SWB.
				cParcela := aSWBChavesTit[nPosTit,5]
				ADEL(aSWBChavesTit,nPosTit)
				ASIZE(aSWBChavesTit,LEN(aSWBChavesTit)-1)
			 ENDIF

			 // Bete - 28/07/05 - Se o retorno da SimbToMoeda for 0, significa que a moeda nao esta cadastrada em um dos MV_SIMBs.
			 IF nMoedSubs == 0
				IF nParc == 1
				   MSGSTOP(STR0108 + TInvoice + CHR(13)+CHR(10)+; //STR0108 "Nao e possivel a geracao dos titulo referentes a invoice: "
						   STR0109 + SW9->W9_MOE_FOB + STR0110) //STR0109 "A moeda: " //STR0110 " não esta configurada no Financeiro!"
				ENDIF
			 ELSEIF lGeraTitInv .AND. !lAlteraSE2 .AND. !FI400TITFIN("SWB","2",,nParc,cParcela)// Inclusao      // GFP - 22/01/2014
				EXIT
			 ENDIF

		  ELSE
			 //dData_Emis:= SW9->W9_DT_EMIS
			 dData_Emis:= &(dDtEmis)
			 dData_Emis:=If (dData_Emis > aTabInv[Wind,3],aTabInv[Wind,3],dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
			 nErroDup:=GeraDupEic(aTabInv[Wind,5],;  //Numero das duplicatas
					 TFobMoe,;          //Valor da duplicata
					 dData_Emis,;       //dDataBase,;        //data de emissao, Jonato em 09/05/2003
					 aTabInv[Wind,3],;  //Data de vencimento
					 SW2->W2_MOEDA,;    //Simbolo da moeda
					 "EIC",;            //Prefixo do titulo
					 "INV",;            //Tipo do titulo
					 nParc,;            //Numero de parcela.
					 cFORN,;            //Fornecedor
					 cLOJA,;            //Loja
					 "SIGAEIC",;        //Origem da geracao da duplicata (Nome da rotina)
					 "P: "+ALLTRIM(cHawb)+" I: "+ALLTRIM(TInvoice),;//Historico da geracao
				  SW9->W9_TX_FOB,,SW6->W6_HAWB)   //Taxa da moeda (caso usada uma taxa diferente a
										//               cadastrada no SM2.

			 IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") } ) = 0
				AADD(aTitInvoiceIAE,{ SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,""), .T. } )
			 ENDIF

			 IF cPaisLoc = "CHI" .AND. SW6->W6_PER_JUR # 0 .AND. ASCAN(aJurosInv,{|J| J[1]==TInvoice }) = 0

				IF SW6->W6_DIA_JUR = 0
				   TFobMoe:=((aTabInv[Wind,2] * (SW6->W6_PER_JUR/100)) / 360 ) * (aTabInv[Wind,3]-dDtEmb)
				   dDataVenc:=aTabInv[Wind,3]//Data de Vencimento
				ELSE
				   TFobMoe:=((aTabInv[Wind,2] * (SW6->W6_PER_JUR/100)) / 360 ) * SW6->W6_DIA_JUR
				   dDataVenc:=dDtEmb+SW6->W6_DIA_JUR
				ENDIF
				dData_Emis:= dDataBase
				dData_Emis:=If (dData_Emis > dDataVenc,dDataVenc,dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
				nErroDup:=GeraDupEic(aTabInv[Wind,5],;//Numero das duplicatas
					 TFobMoe,;                   //Valor da duplicata
					 dData_Emis,;                 //data de emissao
					 dDataVenc,;                 //Data de vencimento
					 SW2->W2_MOEDA,;             //Simbolo da moeda
					 "EIC",;                     //Prefixo do titulo
					 "JR ",;                     //Tipo do titulo
					 nParc,;                     //Numero de parcela.
					 cFORN,;                     //Fornecedor
					 cLOJA,;                     //Loja
					 "SIGAEIC",;                 //Origem da geracao da duplicata (Nome da rotina)
					 "P: "+ALLTRIM(cHawb)+" I: "+ALLTRIM(TInvoice),;//Historico da geracao
				  0,,SW6->W6_HAWB)            //Taxa da moeda (caso usada uma taxa diferente a

			 ENDIF

			 IF cPaisLoc = "CHI" .AND. ASCAN(aJurosInv,{|J| J[1]==TInvoice }) # 0
				nPosJur:= ASCAN(aJurosINV,{|x| x[5]==wind  })
				If nPosJur#0
					 dData_Emis:= dDataBase
					 dData_Emis:=If (dData_Emis > aTabInv[Wind,3],aTabInv[Wind,3],dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
					 GeraDupEic(aJurosInv[nPosJur,4],;//Numero das duplicatas
					 aJurosInv[nPosJur,2],;      //Valor da duplicata
					 dData_Emis,;                 //data de emissao
					 aTabInv[Wind,3],;           //Data de vencimento
					 SW2->W2_MOEDA,;             //Simbolo da moeda
					 "EIC",;                     //Prefixo do titulo
					 "JR ",;                     //Tipo do titulo
					 nParc,;                     //Numero de parcela.
					 cFORN,;                     //Fornecedor
					 cLOJA,;                     //Loja
					 "SIGAEIC",;                 //Origem da geracao da duplicata (Nome da rotina)
					 "P: "+ALLTRIM(cHawb)+" I: "+ALLTRIM(TInvoice),;//Historico da geracao
					 0,,SW6->W6_HAWB)            //Taxa da moeda (caso usada uma taxa diferente a*/
				ENDIF
			 ENDIF
			 FI400ManutCambio('GRVPARCELA',cHawb,aTabInv[Wind],SE2->E2_PARCELA,dDtEMB)
		  ENDIF
		  
	   ELSE
		  cForn := RIGHT(aTabInv[Wind,1],LEN(SA2->A2_COD))
		  SA2->(DBSEEK(cFilSA2+cForn+IF(EICLOJA(),cLoja,"")))
		  cLoja := SA2->A2_LOJA

		  //Principal - Controle de alteração -> GFC - 06/03/06
		  If (nPos:=aScan(aJaPrinc,{|x| x[1]==LEFT(aTabInv[Wind,1],LEN(SWB->WB_INVOICE)) })) > 0
			 nJaPrinc := aJaPrinc[nPos,2]
		  Else
			 nJaPrinc := 0
		  EndIf
		  If aTabInv[Wind,2] > nJaPrinc
			 FI400ManutCambio('GRVPARCELA',cHawb,aTabInv[Wind],STR(nParc),dDtEMB,lGRV_FIN_EIC,cAliasSW9)
			 //** GFC - 07/03/06
			 If lWB_TP_CON
				SWB->(RecLock("SWB",.F.))
				SWB->WB_FOBMOE  := aTabInv[Wind,2] - If(nJaPrinc>=0, nJaPrinc, 0)
				nJaPrinc := 0
				If nPos > 0
				   aJaPrinc[nPos,2] := 0
				EndIf
				SWB->WB_TIPO    := aTabInv[Wind,4]
				SWB->WB_INVOICE := LEFT(aTabInv[Wind,1],LEN(SW9->W9_INVOICE))
				SWB->WB_FORN := Substr(aTabInv[Wind,1],LEN(SWB->WB_INVOICE)+1,LEN(SA2->A2_COD)) //RIGHT(aTabInv[Wind,1],LEN(SW9->W9_FORN))  TRP - 29/12/2011 - Acerto na gravação do campo Fornecedor.
				IF SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
				   SWB->WB_BCO_REC := SA2->A2_BANCO
				   SWB->WB_AGENREC := SA2->A2_AGENCIA
				   SWB->WB_SWIFT   := SA2->A2_SWIFT
				   SWB->WB_CON_REC := SA2->A2_NUMCON
				ENDIF
				SWB->WB_MOEDA   := (cAliasSW9)->W9_MOE_FOB
				SWB->WB_TP_CON  := "2"
				SWB->WB_TIPOCOM := (cAliasSW9)->W9_TIPOCOM
				SWB->WB_EVENT   := PRINCIPAL
				If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+PRINCIPAL))
				   SWB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
				EndIf
				SWB->(msUnlock())
			 EndIf
			 //**
		  ElseIf aTabInv[Wind,2] <= nJaPrinc
			 nJaPrinc -= aTabInv[Wind,2]
			 If nPos > 0
				aJaPrinc[nPos,2] -= aTabInv[Wind,2]
			 EndIf
		  EndIf

		  IF(EasyEntryPoint("EICDI500"),Execblock("EICDI500",.F.,.F.,"GRV_CAMBIO_PRINCIPAL"),)

		  //DFS - 06/12/11 - Adequação do layout do ponto de entrada. Conforme acima, era chamado o EICDI500. O correto é EICFI400, deixaremos o antigo para não apresentar
		  //nenhum problema aos clientes que já utilizam o ponto de entrada antigo.
		  IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"GRV_CAMBIO_PRINCIPAL"),)

		  //Comissão - GFC - 06/03/06
		  If lWB_TP_CON
			 If (nPos:=aScan(aJaCom,{|x| x[1]==LEFT(aTabInv[Wind,1],LEN(SWB->WB_INVOICE)) })) > 0
				nJaCom := aJaCom[nPos,2]
			 Else
				nJaCom := 0
			 EndIf
			 If aTabInv[Wind,7] > 0 .and. aTabInv[Wind,7] > nJaCom
				SWB->(RecLock("SWB",.T.))
				SWB->WB_FILIAL  := xFilial("SWB")
				SWB->WB_HAWB    := &(cAliasSW6+"->W6_HAWB")
				SWB->WB_DT_VEN  := aTabInv[Wind,3]
				SWB->WB_FOBMOE  := aTabInv[Wind,7] - If(nJaCom>=0, nJaCom, 0)
				nJaCom := 0
				If nPos > 0
				   aJaCom[nPos,2] := 0
				EndIf
				SWB->WB_TIPO    := aTabInv[Wind,4]
				SWB->WB_INVOICE := LEFT(aTabInv[Wind,1],LEN(SWB->WB_INVOICE))
				SWB->WB_FORN    := (cAliasSW9)->W9_FORNECC
				SWB->WB_TIPOREG := 'C'  //Comissão
				SWB->WB_DT_DIG  := dDataBase
				IF SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
				   IF EICLOJA()
					  SWB->WB_LOJA:= SA2->A2_LOJA
				   ENDIF
				   SWB->WB_BCO_REC := SA2->A2_BANCO
				   SWB->WB_AGENREC := SA2->A2_AGENCIA
				   SWB->WB_SWIFT   := SA2->A2_SWIFT
				   SWB->WB_CON_REC := SA2->A2_NUMCON
				ENDIF
				SWB->WB_MOEDA   := (cAliasSW9)->W9_MOE_FOB
				SWB->WB_TP_CON  := "4"
				SWB->WB_TIPOCOM := (cAliasSW9)->W9_TIPOCOM
				SWB->WB_PO_DI   := "D"
				If (cAliasSW9)->W9_TIPOCOM == "1" //A remeter
				   SWB->WB_EVENT   := COM_REMETER
				ElseIf (cAliasSW9)->W9_TIPOCOM == "2" //A deduzir da fatura
				   SWB->WB_EVENT   := COM_ADEDUZIR
				Else //Conta Gráfica
				   SWB->WB_EVENT   := COM_CTAGRAF
				EndIf
				If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+SWB->WB_EVENT))
				   SWB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
				EndIf
				SWB->WB_LINHA := PADL(nlinha,4,"0")
				SWB->(msUnlock())
				nLinha += 1
			 ElseIf aTabInv[Wind,7] <= nJaCom
				nJaCom -= aTabInv[Wind,7]
				If nPos > 0
				   aJaCom[nPos,2] -= aTabInv[Wind,7]
				EndIf
			 EndIf
		  EndIf
	   ENDIF

	   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_DI_2'),)

	NEXT
EndIF
//** GFC - 06/03/06
If (lWB_TP_CON .and. lGRV_FIN_EIC) .OR. AvFlags("GERACAO_CAMBIO_FRETE") .OR. AvFlags("GERACAO_CAMBIO_SEGURO")  // GFP - 02/06/2015

   //LGS-23/11/2015 - Executa a função para verificar as despesas 102 e 103
   //THTS - 09/04/2019 - lGeraFreWB e lGeraSegWB servem para verificar se existe numerário de frete e seguro. Se existir, não deve gerar câmbio na SWB.
   NU400Desp('SWB',@lGeraFreWB,@lGeraSegWB)

   //Frete
   //**BHF-26/05/09
   If !Empty(&(cAliasSW6+"->W6_FORNECF")) .And. lGeraFrete
      IF SA2->(DBSEEK(xFilial("SA2")+&(cAliasSW6+"->W6_FORNECF")+&(cAliasSW6+"->W6_LOJAF")))
         SX5->(DbSetOrder(1))
         //DFS - Nova validação para que seja verificada pelo seguro da moeda e não pelo estado do fornecedor
          If (Alltrim(&(cAliasSW6+"->W6_FREMOED")) == (Alltrim(EasyGParam("MV_SIMB1"))))
            //If SX5->(DbSeek(xFilial("SX5")+"12"+SA2->A2_EST)) .and. SX5->X5_CHAVE # "EX"
            MsgInfo(STR0111,STR0004) //STR0111 "Não foi possível gerar o câmbio. Moeda do Frete não é estrangeira." //STR0004 := "Atenção"
            Return .F.
         EndIf
      EndIf
   EndIf
   //**BHF
   If lGeraFreWB .And. lGeraFrete .And. AvValidFre(,,cAliasSW6) .And. (Empty(cAltera) .or. cAltera $ ("1/2")) .and. !Empty(&(cAliasSW6+"->W6_FORNECF")) .and.;
   !Empty(&(cAliasSW6+"->W6_FREMOED"))
      aTabInv:={}
      EicCalcPagto("FRETE"+&(cAliasSW6+"->W6_FORNECF")+&(cAliasSW6+"->W6_LOJAF"),&(cAliasSW6+"->W6_VLFRECC"),dDtEMB,dDtaVista,(&(cAliasSW6+"->W6_CONDP_F")+STR(&(cAliasSW6+"->W6_DIASP_F"),3)),aTabInv,,,,,,.F.) //OS 0639/01

      nParFret:= 1

      FOR ni:=1 TO Len(aTabInv)
         IF EMPTY(aTabInv[ ni,3 ])//Data
            LOOP
         ENDIF

         (cAliasSW9)->(DBSEEK(If(cAliasSW9=="SW9",xFilial("SW9"),"")+aTabInv[ni,1]))
         If aTabInv[ni,2] > nJaFrete
            SWB->(RecLock("SWB",.T.))
            SWB->WB_FILIAL  := xFilial("SWB")
            SWB->WB_HAWB    := &(cAliasSW6+"->W6_HAWB")
            SWB->WB_DT_VEN  := aTabInv[ni,3]
            SWB->WB_FOBMOE  := aTabInv[ni,2] - If(nJaFrete>=0, nJaFrete, 0)
            nJaFrete := 0
            SWB->WB_TIPO    := aTabInv[ni,4]
            SWB->WB_INVOICE := "FRETE"
            SWB->WB_FORN    := SA2->A2_COD //RIGHT(aTabInv[ni,1],LEN(SA2->A2_COD))
            If AvFlags("GERACAO_CAMBIO_FRETE")  // GFP - 02/06/2015
               SWB->WB_LOJA := SA2->A2_LOJA
            EndIf
            SWB->WB_TIPOREG := 'A'
            SWB->WB_DT_DIG  := dDataBase
            IF SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
               IF EICLOJA()
                  SWB->WB_LOJA:= SA2->A2_LOJA
               ENDIF
               SWB->WB_BCO_REC := SA2->A2_BANCO
               SWB->WB_AGENREC := SA2->A2_AGENCIA
               SWB->WB_SWIFT   := SA2->A2_SWIFT
               SWB->WB_CON_REC := SA2->A2_NUMCON
            ENDIF

            SWB->WB_PARCELA:= Alltrim(Str(nParFret))

            nParFret := nParFret+1

            SWB->WB_MOEDA   := &(cAliasSW6+"->W6_FREMOED")
            If lWB_TP_CON
               SWB->WB_TP_CON  := "4"
            EndIf
            SWB->WB_PO_DI   := "D"
            SWB->WB_EVENT   := FRETE
            If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+FRETE))
               SWB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
            EndIf
            SWB->WB_LINHA := PADL(nlinha,4,"0")
            SWB->(msUnlock())
            If lFinanceiro .And. AvFlags("GERACAO_CAMBIO_FRETE") .And. !lLoop102 //LGS-01/12/2015 // GFP - 02/06/2015 - Tratamento de geração de titulos de contas a pagar referente ao frete originados pelo cambio
               lRet := GeraTitCamb(AllTrim(SWB->WB_INVOICE),"2")
            EndIf
            nLinha += 1                   //NCF - 08/07/2010 - Desnopado para pre-encher o WB_LINHA para frete e seguro - Ch. 082180
            //wfs - gravação da capa do câmbio quando não há invoice para o processo, somente frete e/ ou seguro
            If !SWA->(DBSeek(xFilial() + AvKey(cHawb, "WA_HAWB") + "D"))
               FI400ManutCambio('GRVCAPA',cHawb)
            EndIf
         ElseIf aTabInv[ni,2] <= nJaFrete
            nJaFrete -= aTabInv[ni,2]
         EndIf
      Next ni
   EndIf

   //Seguro
   //**BHF-28/05/09
   If !Empty(&(cAliasSW6+"->W6_FORNECS")) .And. lGeraSeg
      IF SA2->(DBSEEK(xFilial("SA2")+&(cAliasSW6+"->W6_FORNECS")+&(cAliasSW6+"->W6_LOJAS")))
         SX5->(DbSetOrder(1))
//         If SX5->(DbSeek(xFilial("SX5")+"12"+SA2->A2_EST)) .and. SX5->X5_CHAVE # "EX"
         //DFS - Nova validação para que seja verificada pelo seguro da moeda e não pelo estado do fornecedor
         If (Alltrim(&(cAliasSW6+"->W6_SEGMOED")) == (Alltrim(EasyGParam("MV_SIMB1"))))
            MsgInfo(STR0112,STR0004) //STR0112 "Não foi possível gerar o câmbio. Moeda de Seguro não é estrangeira."  //STR0004 := "Atenção"
            Return .F.
         EndIf
      EndIf
   EndIf
   //**BHF
   If lGeraSegWB .And. lGeraSeg .And. AvValidSeg(,,cAliasSW6) .And. (Empty(cAltera) .or. cAltera $ ("1/3")) .and. !Empty(&(cAliasSW6+"->W6_FORNECS")) .and.;
   !Empty(&(cAliasSW6+"->W6_SEGMOED")) .AND. !lSegInv  // EOB - 30/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      aTabInv:={}
      EicCalcPagto("SEGURO"+&(cAliasSW6+"->W6_FORNECS")+&(cAliasSW6+"->W6_LOJAS"),&(cAliasSW6+"->W6_VL_USSE"),dDtEMB,dDtaVista,(&(cAliasSW6+"->W6_CONDP_S")+STR(&(cAliasSW6+"->W6_DIASP_S"),3)),aTabInv,,,,,,.F.) //OS 0639/01

      nParSeg:= 1

      FOR ni:=1 TO Len(aTabInv)
         IF EMPTY(aTabInv[ ni,3 ])//Data
            LOOP
         ENDIF

         (cAliasSW9)->(DBSEEK(If(cAliasSW9=="SW9",xFilial("SW9"),"")+aTabInv[ni,1]))
         If aTabInv[ni,2] > nJaSeg
            SWB->(RecLock("SWB",.T.))
            SWB->WB_FILIAL  := xFilial("SWB")
            SWB->WB_HAWB    := &(cAliasSW6+"->W6_HAWB")
            SWB->WB_DT_VEN  := aTabInv[ni,3]
            SWB->WB_FOBMOE  := aTabInv[ni,2] - If(nJaSeg>=0, nJaSeg, 0)
            nJaSeg := 0
            SWB->WB_TIPO    := aTabInv[ni,4]
            SWB->WB_INVOICE := "SEGURO"
            SWB->WB_FORN    := SA2->A2_COD //RIGHT(aTabInv[ni,1],LEN(SA2->A2_COD))
            If AvFlags("GERACAO_CAMBIO_SEGURO")  // GFP - 02/06/2015
               SWB->WB_LOJA := SA2->A2_LOJA
            EndIf
            SWB->WB_TIPOREG := 'B'
            SWB->WB_DT_DIG  := dDataBase
            IF SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
               IF EICLOJA()
                  SWB->WB_LOJA := SA2->A2_LOJA
               ENDIF
               SWB->WB_BCO_REC := SA2->A2_BANCO
               SWB->WB_AGENREC := SA2->A2_AGENCIA
               SWB->WB_SWIFT   := SA2->A2_SWIFT
               SWB->WB_CON_REC := SA2->A2_NUMCON
            ENDIF

            SWB->WB_PARCELA:= Alltrim(Str(nParSeg))

            nParSeg := nParSeg+1

            SWB->WB_MOEDA   := &(cAliasSW6+"->W6_SEGMOED")
            If lWB_TP_CON
               SWB->WB_TP_CON  := "4"
            EndIf
            SWB->WB_PO_DI   := "D"
            SWB->WB_EVENT   := SEGURO
            If EC6->(dbSeek(xFilial("EC6")+"IMPORT"+SEGURO))
               SWB->WB_TIPOC := If(EC6->EC6_RECDES=="1","R","P")
            EndIf
            SWB->WB_LINHA := PADL(nlinha,4,"0")               //NCF - 08/07/2010 - Desnopado para pre-encher o WB_LINHA para frete e seguro - Ch. 082180
            SWB->(msUnlock())
            If lFinanceiro .And. AvFlags("GERACAO_CAMBIO_SEGURO") .And. !lLoop103 //LGS-01/12/2015 // GFP - 02/06/2015 - Tratamento de geração de titulos de contas a pagar referente ao seguro originados pelo cambio
               lRet := GeraTitCamb(AllTrim(SWB->WB_INVOICE),"2")
            EndIf
            nLinha += 1
            //wfs - gravação da capa do câmbio quando não há invoice para o processo, somente frete e/ ou seguro
            If !SWA->(DBSeek(xFilial() + AvKey(cHawb, "WA_HAWB") + "D"))
               FI400ManutCambio('GRVCAPA',cHawb)
            EndIf
         ElseIf aTabInv[ni,2] <= nJaSeg
            nJaSeg -= aTabInv[ni,2]
         EndIf
      Next ni
   EndIf

   cMensInv := ""

   If (Len(aInvDel) > 0 .or. Len(aInvDif) > 0) .AND. !AvFlags("EIC_EAI")
      For ni:=1 to Len(aInvDel)
         If ni = 1
            cMensInv := STR0113+Chr(13)+Chr(10) //STR0113 "Relação de Invoices Recalculadas: "
         EndIf
         cMensInv += If(!Empty(aInvDel[ni,3]), aInvDel[ni,3]+" - ", "")
         cMensInv += "Inv.: "+Alltrim(aInvDel[ni,1])+", Forn.: "+Alltrim(aInvDel[ni,2])
         cMensInv += Chr(13)+Chr(10)
      Next ni

      For ni:=1 to Len(aInvDif)
         If ni = 1
            If !Empty(cMensInv)
               cMensInv += Chr(13)+Chr(10)
            EndIf
            cMensInv += STR0114+Chr(13)+Chr(10) //STR0114 "Relação de Invoices com Diferença: "
         EndIf
         cMensInv += If(!Empty(aInvDif[ni,3]), aInvDif[ni,3]+" - ", "")
         cMensInv += "Inv.: "+Alltrim(aInvDif[ni,1])+", Forn.: "+Alltrim(aInvDif[ni,2])
         cMensInv += Chr(13)+Chr(10)
      Next ni

      MsgInfo(cMensInv)
   EndIf
EndIf
//**

//FI400ManutCambio('GRVCAPA',cHawb)

//** GFC - 07/03/06
SWA->(dBSETORDER(1))
If lWB_TP_CON .and. lGRV_FIN_EIC .and. SWA->(DBSEEK(xFilial("SWA")+cHawb+"D"))
   If SWB->(DBSEEK(xFilial("SWB")+cHawb))
      SWA->(RecLock("SWA",.F.))
      If SA2->(dbSeek(xFilial("SA2")+(cAliasSW9)->W9_FORN+EICRetLoja(cAliasSW9,"W9_FORLOJ")))
         SWA->WA_CEDENTE := SA2->A2_NREDUZ
         SWA->WA_FB_NOME := SA2->A2_NREDUZ
      EndIf
      SWA->WA_DI_NUM  := &(cAliasSW6+"->W6_DI_NUM")
      SWA->WA_DTREG_D := &(cAliasSW6+"->W6_DTREG_D")

      SY6->(DBSETORDER(1))
      IF SY6->(DBSEEK(xFilial("SY6")+(cAliasSW9)->W9_COND_PA+STR((cAliasSW9)->W9_DIAS_PA,3)))
         SWA->WA_CPAGTO :=TRAN(SY6->Y6_COD,'@R 9.9.999')+SPACE(01)+MSMM(SY6->Y6_DESC_P,42,1)
      EndIf
      SWA->(msUnlock())
   Else
      SWA->(RecLock("SWA",.F.))
      SWA->(dbDelete())
      SWA->(MSUNLOCK())
   EndIf
EndIf
//**

//JVR - 15/09/09
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400DEPOCAMB'),)

//WFS
If Type("lCambio_eic") <> "L"
   lCambio_eic:= AVFLAGS("AVINT_CAMBIO_EIC")
EndIf
//**  igor chiba 290/09/09
IF LCAMBIO_EIC
   cFilSWB:= XFILIAL('SWB')
   cFilEW4:= XFILIAL('EW4')
   SWB->(DBSETORDER(1))
   EW4->(DBSETORDER(1))

   IF lGravaFin_EIC
      IF cAltValid == '4'//nao gerar toda hora o cambio
         RETURN .T.
      ENDIF
      SWB->(DBSEEK(cFilSWB+M->W6_HAWB+AVKEY('D','WB_PO_DI')))

      DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL == cFilSWB ;
                             .AND. SWB->WB_HAWB   == M->W6_HAWB ;
                             .AND. SWB->WB_PO_DI  == AVKEY('D','WB_PO_DI')

         IF EW4->(DBSEEK(cFilEW4+SWB->WB_INVOICE+SWB->WB_FORN))
            SWB->(RECLOCK('SWB',.F.))
            SWB->WB_TITERP:= EW4->EW4_TITERP
            SWB->WB_TITRET:= "1"  // PLB 15/04/10 - Status de Retorno do ERP
            SWB->(MSUNLOCK())
            SWB->(DBCOMMIT())
         ENDIF

         cChave  := SWB->WB_FILIAL+SWB->WB_HAWB+SWB->WB_INVOICE+SWB->WB_LINHA
         cSQLChv := "WB_FILIAL = '"+SWB->WB_FILIAL+"' AND "+;
                    "WB_HAWB = '"+SWB->WB_HAWB+"' AND "+;
                    "WB_INVOICE = '"+SWB->WB_INVOICE+"' AND "+;
                    "WB_LINHA = '"+SWB->WB_LINHA+"' "
         If FindFunction("EICINTEI17")
            EasyExRdm("EICINTEI17", 'I','CBO',cChave,'AB',cSQLChv)            
         EndIf   
         SWB->(DBSKIP())
      ENDDO
   ENDIF
ENDIF
//**

//AOM - 28/07/2011 - Apresenta as mensagens de erro.
If Type("oErrorFin") == "O" .And. oErrorFin:lError
   oErrorFin:ShowErrors()
EndIf

IncProc()

If lRetorno
   Return .F.
EndIf

// EOS - 06/10/03
IF cPaisLoc # "BRA" .AND. lExistEZZ
   Processa({|| FI400Proc_EZZ()})
ENDIF

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POS_DI_3'),)

Return lRet
/*
*--------------------------------------------------*
FUNCTION FI400SW3(cPO_Num,dDtEMB,_Valor)
*--------------------------------------------------*
LOCAL nInd:=SW3->(INDEXORD()), nAlias:=SELECT()
LOCAL cFilSW3:=xFilial("SW3"),nQtde:=0

SW3->(DBSETORDER(7))
SW3->(DBSEEK(cFilSW3+cPO_Num))
dDtEMB:=SW3->W3_DT_EMB
DO WHILE ! SW3->(EOF()) .AND. alltrim(cPO_Num) == alltrim(SW3->W3_PO_NUM) .AND.;
                              cFilSW3 == SW3->W3_FILIAL

   IF SW3->W3_SEQ # 0
      EXIT
   ENDIF

   nSld_Gi:= 0
   nQtd_Gi:= 0
   TPO_NUM:= cPO_Num
   Po420_IgPos("3")
   IF SW3->W3_FLUXO == "7"
      nQtde := nSld_Gi
   ELSE
      nQtde := SW3->W3_SALDO_Q + nSld_Gi
   ENDIF

   IF SW3->W3_DT_EMB > dDtEMB
      dDtEMB:=SW3->W3_DT_EMB
   ENDIF

   _Valor+=(nQtde*SW3->W3_PRECO)

   SW3->(DBSKIP())
ENDDO

SW3->(DBSETORDER(nInd))
SELECT(nAlias)

RETURN .T.
*/
*--------------------------------------------------*
FUNCTION FI400POAlterou(cPO_Num,cTipo)
*--------------------------------------------------*
LOCAL nAlias:=SELECT(), nInd2:=SW2->(INDEXORD())
LOCAL nInd3:=SW3->(INDEXORD())
PRIVATE lRETURN:= .F.
lSair:=.F.
BEGIN SEQUENCE

   IF cTipo = "I"
      lRETURN:= .T.
      BREAK
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400POAlterou'),)
   IF lSair
      BREAK
   ENDIF

   SW3->(DBSETORDER(1))
   IF cTipo = "E"
      IF SW3->(DBSEEK(xFilial("SW3")+cPO_Num))
         lRETURN:= .T.
      ENDIF
      BREAK
   ENDIF

   SW2->(DBSETORDER(1))
   SW2->(DBSEEK(xFilial("SW2")+cPO_Num))
   IF SW2->W2_COND_PA # M->W2_COND_PA .OR.;
      SW2->W2_DIAS_PA # M->W2_DIAS_PA
      lRETURN:= .T.
      BREAK
   ENDIF

   IF SW2->W2_DESP # M->W2_DESP
      lRETURN:= .T.
      BREAK
   ENDIF

   IF SW2->W2_AGENTE # M->W2_AGENTE
      lRETURN:= .T.
      BREAK
   ENDIF

   IF SW2->W2_MOEDA # M->W2_MOEDA
     lRETURN :=  .T.
     BREAK
   ENDIF

   IF SW2->W2_TAB_PC # M->W2_TAB_PC
      lRETURN:= .T.
      BREAK
   ENDIF
   IF SW2->W2_CONTA20 # M->W2_CONTA20 .OR. SW2->W2_CONTA40 # M->W2_CONTA40 .OR. SW2->W2_CONTA40 # M->W2_CONTA40 .OR.;
      SW2->W2_CONTA40HC # M->W2_CONTA40HC .OR. SW2->W2_OUTROS # M->W2_OUTROS
      lRETURN:= .T.
      BREAK
   ENDIF
   IF SW2->W2_E_LC # M->W2_E_LC  // CARTA DE CREDITO
      lRETURN:= .T.
      BREAK
   ENDIF


   nValorG:= (SW2->W2_FOB_TOT+SW2->W2_INLAND+SW2->W2_PACKING+SW2->W2_FRETEIN)-SW2->W2_DESCONT
   nValorM:= (M->W2_FOB_TOT+M->W2_INLAND+M->W2_PACKING+M->W2_FRETEIN)-M->W2_DESCONT
   IF nValorG # nValorM
      lRETURN:= .T.
      BREAK
   ENDIF

END SEQUENCE

SW2->(DBSETORDER(nInd2))
SW3->(DBSETORDER(nInd3))
SELECT(nAlias)

RETURN lRETURN
*--------------------------------------------------*
FUNCTION FI400DIAlterou(cHAWB,cTipo)
*--------------------------------------------------*
LOCAL nAlias:=SELECT(), nInd6:=SW6->(INDEXORD()), nInd9:=SW9->(INDEXORD())
LOCAL nInd7:=SW7->(INDEXORD())
LOCAL ldataEMB := !EMPTY(GetNewPar("MV_DTB_APD",""))
LOCAL lSW9 := .F.
LOCAL dDtEmbG := CTOD("")
LOCAL dDtEmbM := CTOD("")
LOCAL nIndiceRecSWB
LOCAL aOrdE2 := {}    //TRP - 02/02/2010
LOCAL lAltInvoice:= .F. //LRS - 24/10/2016
PRIVATE lRETURN:= .F.
Private dDtEmis := FI400DtEmInvCpo()//Iif(Empty(EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")),"SW9->W9_DT_EMIS",EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS"))//04/08/17
dDtEmis := Iif(Empty(dDtEmis),"SW9->W9_DT_EMIS",dDtEmis) //NCF - 09/04/2010 - Caso cliente deixe conteúdo do parâmetro em branco
lSair:=.F.
//** BHF 08/12/08
If (aPos = NIL .And. lAltFrete = NIL .And. lAltSeguro = NIL .And. aAltInvoice = NIL .And. lAltodasInvoice = NIL .And.;
   lTitFreteIAE = NIL .And. lTitSeguroIAE = NIL .And. aTitInvoiceIAE = NIL .And. aSWBChavesTit = NIL .And. aSWBCampos = NIL)

   aPos := {}
   lAltFrete := lAltSeguro := .F.// Controla se vai deletar e gerar os Titulos de Frete e Seguro
   aAltInvoice := {}                // Controla se vai deletar e gerar os Titulos da Invoice
   lAltodasInvoice := .F.           // Controla se vai deletar e gerar os Titulos de todas as Invoices
   lTitFreteIAE := lTitSeguroIAE:=.F.// Controla se foi gerado os Titulos de Frete e Seguro
   aTitInvoiceIAE := {}                // Controla se foi gerado os Titulos de Invoices
   aSWBChavesTit := {}                // Guarda as chaves dos titulos excluidos
   aSWBCampos := {}

EndIf

If AVFLAGS("INV_ANT_GERA_CAMB_FIN")  //NCF - 26//11/2015
   EW4->(DbSetOrder(2))
EndIf
//** BHF
BEGIN SEQUENCE

   //NCF - 23/10/2019 - Verificação de encerramento do processo para evitar processamento e integração desnecessária com o Financeiro.
   If SW6->(Eof()) .Or. SW6->(Bof()) .Or. SW6->W6_HAWB <> cHAWB
      SW6->(DbSeek( xfilial("SW6") + cHAWB  )) 
   EndIf
   If SW6->(!Eof()) .And. !Empty(SW6->W6_DT_ENCE)
      lRETURN:=.F.
      BREAK
   ENDIF

   SW7->(DBSETORDER(1))
   IF cTipo = "E"
      IF SW7->(DBSEEK(xFilial("SW7")+cHAWB))
         //** BHF - 11/12/08 -> Verificação para alteração das parcelas de cambio.
		 nIndiceRecSWB := SaveOrd("SWB")
   	 	 aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
   	 	 SWB->(DbSetOrder(1))
    	 If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
      	    // - Caso tenha titulo liquidado, não altera invoices.
            While !SWB->(EOF()) .And. (SWB->WB_HAWB == SW6->W6_HAWB)
               If !Empty(SWB->WB_CA_DT) //Tem que estar liquidada a parcela
                  lAltodasInvoice:=.F.
                  Exit
               Else //Ainda nao esta liquidado
                  lAltodasInvoice :=.T.
	           EndIf

      	       //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
	           SE2->(DbSetOrder(6))
               If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                  If SE2->E2_VALOR <> SE2->E2_SALDO
		             lAltodasInvoice:=.F.
                     Exit
		          Endif
		       Endif

      	       SWB->(dbSkip())

      	    EndDo
         EndIf
         RestOrd(nIndiceRecSWB,.T.)
         RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
         //** BHF
         lRETURN:= .T.
      ENDIF
      lAltFrete := .T.
      lAltSeguro:= .T.
      TRB->(DBGOTOP())
      Do While !TRB->(EOF())
         IF EMPTY(TRB->WK_OK)
            lAltFrete := .F.
            lAltSeguro:= .F.
            EXIT
         ENDIF
         TRB->(dbSkip())
      ENDDO
      BREAK
   ENDIF

   FI400VAlInv()  // GFP - 25/11/2013

   lRDAltInvoice  :=lAltodasInvoice
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400DIAlterou"),)
   lAltodasInvoice:=lRDAltInvoice

   IF lSair
      BREAK
   ENDIF

   IF Findfunction("AVImpostos")//AWR - 25/10/2004 - Funcao do programa AVFLUXO.PRW
      AVImpostos("201","ANTES_GRV",@lRETURN)
      AVImpostos("202","ANTES_GRV",@lRETURN)
      AVImpostos("204","ANTES_GRV",@lRETURN)
      AVImpostos("205","ANTES_GRV",@lRETURN)
      cMV_CODTXSI:=EasyGParam("MV_CODTXSI",,"415")
      IF !EMPTY(cMV_CODTXSI)
         AVImpostos(cMV_CODTXSI,"ANTES_GRV",@lRETURN)
      ENDIF
   ENDIF

   SW6->(DBSETORDER(1))
   SW6->(DBSEEK(xFilial("SW6")+cHAWB))

   /// INVOICE Individual
   Work_SW9->(DBGOTOP())
   lAVista := .F.  // Bete 06/02/06
   lSegInv := .F.  // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF Work_SW9->(EOF())
      // Na gravaçao da capa, a Work das invoices nao esta preenchida, portanto será verificado o proprio SW9
      SW9->(dbSetOrder(3))
      SW9->(DBSEEK(xFilial("SW9")+cHAWB))
      DO WHILE !SW9->(EOF()) .AND. SW9->W9_HAWB == cHAWB
         // Bete 06/02/06 - verifica se a condição de pagamento é a vista
         IF SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0))) .AND. SY6->Y6_DIAS_PA = -1
            lAVista := .T.
         ENDIF
         // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF AvRetInco(SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 28/12/10*/  //SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            lSegInv := .T.
         ENDIF
         SW9->(dbSkip())
      ENDDO
      SW9->(dbSetOrder(nInd9))
   ELSE
      Do While !Work_SW9->(EOF())

         IF EMPTY(Work_SW9->WK_RECNO)// Invoices incluidas
            AADD(aAltInvoice, Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,"") )
            Work_SW9->(dbSkip())
            LOOP
         ENDIF

         IF cPaisLoc # "BRA" .AND. SX2->(dbSeek("EZZ"))
            IF Work_SW9->WK_TPINV == 2
               EZZ->(DBGOTO(WORK_SW9->WK_RECNO))
               IF EZZ->EZZ_INLAND+EZZ->EZZ_PACKIN-EZZ->EZZ_DESCON+EZZ->EZZ_OUTDES+EZZ->EZZ_FRETEI # ;
                  WORK_SW9->W9_INLAND+WORK_SW9->W9_PACKING-WORK_SW9->W9_DESCONT+WORK_SW9->W9_OUTDESP+WORK_SW9->W9_FRETEIN .OR.;
                  EZZ->EZZ_CONDPA+STR(EZZ->EZZ_DIASPA,3) # WORK_SW9->W9_COND_PA+STR(WORK_SW9->W9_DIAS_PA,3)// Invoices alteradas
                                                               //EW4_FILIAL + EW4_HAWB + EW4_INVOIC + EW4_FORN + EW4_FORLOJ
                  If( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' .Or. !EW4->(DbSeek( xfilial("EW4") + Work_SW9->W9_HAWB + Work_SW9->W9_INVOICE + Work_SW9->W9_FORN + Work_SW9->W9_FORLOJ)) )  //NCF - 18/11/2015
                     AADD(aAltInvoice, Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,"") )
                  EndIf

               ENDIF
               Work_SW9->(dbSkip())
               LOOP
            ENDIF
         ENDIF

         SW9->(DBGOTO(WORK_SW9->WK_RECNO))

         IF DI500RetVal("TOT_INV", "TAB", .T.) # DI500RetVal("TOT_INV", "WORK", .T. ).OR.;  // EOB - 28/05/08 - chamada da função DI500RetVal
            SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3) # WORK_SW9->W9_COND_PA+STR(WORK_SW9->W9_DIAS_PA,3)  .OR.;
            SW9->W9_FREINC  # WORK_SW9->W9_FREINC ;// Invoices alteradas
            //.Or. SW9->W9_TX_FOB # WORK_SW9->W9_TX_FOB CCH - 18/09/2008 - Nopado para permitir a alteração da taxa da invoice mesmo quando houver título INV com baixa.  // PLB 18/09/07 - Ao alterar a taxa da Invoice alterar os títulos no SigaFIN

            If( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' .Or. !EW4->(DbSeek( xfilial("EW4") + SW9->W9_HAWB + SW9->W9_INVOICE + SW9->W9_FORN + SW9->W9_FORLOJ)) )  //NCF - 18/11/2015
               AADD(aAltInvoice, Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,"") )
            EndIf

         ENDIF

         //SVG - 06/01/08 - Verificação caso a Taxa da invoice tenha sofrido alteração regera o título no financeiro desde que não haja baixa para os títulos desta invoice.
         If EasyGParam("MV_EASYFIN",,"N") $ cSim .AND. (SW9->W9_TX_FOB # WORK_SW9->W9_TX_FOB .OR. SW9->W9_DESCONT # WORK_SW9->W9_DESCONT) //LRS - 11/10/2016 - Alterar o titulo quando alterar o desconto
            aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
            SWB->(DbSetOrder(1))
            lAltInvoice:=.T.
    	      If SWB->(dbSeek(xFilial("SWB")+SW9->W9_HAWB+'D'+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
      	       // - Caso tenha titulo liquidado, não altera invoices.            
               While !SWB->(EOF()) .And. (SWB->WB_HAWB+SWB->WB_INVOICE+SWB->WB_FORN == SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN) .AND. (!EICLOJA() .OR. SWB->WB_LOJA == SW9->W9_FORLOJ)
                  If !Empty(SWB->WB_CA_DT) .OR. EasyGParam("MV_EIC0020",,.F.) //RRV - 17/12/2012 - Incluido parametro que trata se o título INV deve ou não ser regerado caso exista alteração da taxa da invoice.
                     lAltInvoice:=.F.
                     Exit
                  Else
                     If( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' .Or. !EW4->(DbSeek( xfilial("EW4") + SW9->W9_HAWB + SW9->W9_INVOICE + SW9->W9_FORN + SW9->W9_FORLOJ)) )  //NCF - 18/11/2015
                        lAltInvoice:=.T.
                     EndIf
	               EndIf

	               //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
	               SE2->(DbSetOrder(6))
                  If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                     If SE2->E2_VALOR <> SE2->E2_SALDO
		                lAltInvoice:=.F.
                        Exit
		               Endif
		            Endif
                  SWB->(dbSkip())
      	      EndDo
      	      RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
      	   EndIf  
            If lAltInvoice
     	         AADD(aAltInvoice, SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") )
     	      EndIF
         EndIf
         
         // Bete 06/02/06 - verifica se a condição de pagamento é a vista
         IF SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0))) .AND. SY6->Y6_DIAS_PA = -1
            lAVista := .T.
         ENDIF

         // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF AvRetInco(Work_SW9->W9_INCOTER,"CONTEM_SEG")/*FDR - 28/12/10*/  //Work_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
            lSegInv := .T.
         ENDIF

         Work_SW9->(dbSkip())
      EndDo
   ENDIF

   IF !EMPTY(aAltInvoice)
      lRETURN:= .T.
   ENDIF
   IF ASCAN(aDeletados , {|D| D[1] = "SW9" }  ) # 0 .OR. ASCAN(aDeletados , {|D| D[1] = "EZZ" }  ) # 0
      lRETURN:= .T.
   ENDIF
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'ARRAY_AALTINVOICE'),)

   IF !lDataEMB//Ask 27/07/2007 - Tratamento do parâmetro MV_DTB_APD
      cDatEmb := "SW6->W6_DT_EMB"
   ELSE
      cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
   ENDIF

   if "W6_DT_EMB" $ cDatEmb
      if EMPTY(&cDatEmb)
         cDatEmb := "SW6->W6_DT_ETD" // NCF 13/05/09  - Pega a data ETD se a data de Embarque não
      EndIf
   EndIf

   If Left(cDatEmb,5) == "SW6->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
      dDtEmbG:= &(cDatEmb)
      dDtEmbM:= &("M->" + Right(cDatEmb,Len(cDatEmb)-5))
   ElseIf Left(cDatEmb,3) == "W6_" // Ou só o campo
      dDtEmbG := &("SW6->" + cDatEmb )
      dDtEmbM := &("M->" + cDatEmb )
   Else
      lSW9 := .T.
   EndIf

   Work_SW9->(DbGoTop())

   Begin Sequence
   //Se o campo do parametro for da tabela SW9, verifica-se invoice por invoice até achar uma alteração
   SW9->(DbSetOrder(3))
   SW9->(DBSEEK(xFilial("SW9")+cHAWB))
   Do While !Work_SW9->(EOF()) .And. lSW9
      Do WHILE SW9->W9_HAWB == cHAWB .AND. SW9->W9_INVOICE = Work_SW9->W9_INVOICE

         If Left(cDatEmb,5) == "SW9->" //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
            dDtEmbG:= &(cDatEmb)
            dDtEmbM:= &("Work_SW9->" + Right(cDatEmb,Len(cDatEmb)-5))
         ElseIf Left(cDatEmb,3) == "W9_" //Ou só o campo
            dDtEmbG := &("SW9->" + cDatEmb )
            dDtEmbM := &("Work_SW9->" + cDatEmb )
         EndIf
         IF dDtEmbG # dDtEmbM
            //** BHF - 11/12/08 -> Verificação para alteração das parcelas de cambio.
		    nIndiceRecSWB := SaveOrd("SWB")
   	 	    aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
   	 	    SWB->(DbSetOrder(1))
    	    If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
      	       // - Caso tenha titulo liquidado, não altera invoices.
               While !SWB->(EOF()) .And. (SWB->WB_HAWB == SW6->W6_HAWB)
                  If !Empty(SWB->WB_CA_DT)
                     lAltodasInvoice:=.F.
                     Exit
                  Else
                     lAltodasInvoice:=.T.
	              EndIf

	              //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
	              SE2->(DbSetOrder(6))
                  If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                     If SE2->E2_VALOR <> SE2->E2_SALDO
		                lAltodasInvoice:=.F.
                        Exit
		             Endif
		          Endif

	           SWB->(dbSkip())
      	       EndDo
            EndIf
            RestOrd(nIndiceRecSWB,.T.)
            RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
            //** BHF
            lRETURN:= .T.
            Break
         ENDIF
      SW9->(DbSkip())
      EndDo
      Work_SW9->(DbSkip())
   EndDo
   End Sequence

   SW9->(DbSetOrder(1))

   IF !lSW9 .OR. !(Work_SW9->(EOF()) .OR. Work_SW9->(BOF()) )//LRS - 04/07/2018
        IF EMPTY(dDtEmbG)
            dDtEmbG  := SW6->W6_DT_EMB
            dDtEmbM  := M->W6_DT_EMB
            IF EMPTY(dDtEmbG)
                dDtEmbG  := SW6->W6_DT_ETA
                dDtEmbM  := M->W6_DT_ETA
            ENDIF
        ENDIF

        IF dDtEmbG # dDtEmbM
            //** BHF - 11/12/08 -> Verificação para alteração das parcelas de cambio.
            nIndiceRecSWB := SaveOrd("SWB")
            aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
            SWB->(DbSetOrder(1))
            If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
                // - Caso tenha titulo liquidado, não altera invoices.
                While !SWB->(EOF()) .And. (SWB->WB_HAWB == SW6->W6_HAWB)
                    If !Empty(SWB->WB_CA_DT)
                    lAltodasInvoice:=.F.
                    Exit
                    Else
                    lAltodasInvoice:=.T.
                    EndIf

                    //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
                    SE2->(DbSetOrder(6))
                    If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                    If SE2->E2_VALOR <> SE2->E2_SALDO
                        lAltodasInvoice:=.F.
                        Exit
                    Endif
                    Endif

                    SWB->(dbSkip())
                EndDo
            EndIf
            RestOrd(nIndiceRecSWB,.T.)
            RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
            //** BHF
            lRETURN:= .T.
        ENDIF
    ENDIF

   IF SW6->W6_DT_DESEM # M->W6_DT_DESEM .AND. lAVista ; // Bete 06/02/06 - Somente serão regerados os titulos, se alguma invoice for a vista
   .AND. "W6_DT_DESEM" $ dDtEmis //AAF - 08/07/08 - Atualiza os titulos apenas caso haja mudança na data de emissao.
      lAltodasInvoice:=.T.
      lRETURN:= .T.
   ENDIF

   SWB->(DBSETORDER(1))
   SW9->( DBSetOrder(3) )
   IF SW9->( DBSeek(xFilial("SW9")+SW6->W6_HAWB) )  .And.  !SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB))
      lAltodasInvoice:=.T.
      lRETURN:= .T.
   ENDIF

   //** PLB 05/03/07 - Caso haja alteracao nos itens
   If !lReturn  .And.  !Work->( BoF()  .And.  EoF() )
      nValorSW7  := 0
      nValorWork := 0
      SW7->(DBSEEK(xFilial("SW7")+cHAWB))
      Do While SW7->( !EoF()  .And.  W7_FILIAL+W7_HAWB == xFilial("SW7")+cHawb )
         nValorSW7 += SW7->( W7_PRECO * W7_QTDE )
         SW7->( DBSkip() )
      EndDo
      Work->( DBGoTop() )
      Do While Work->( !EoF() )
         nValorWork += Work->( WKPRECO * WKQTDE )
         Work->( DBSkip() )
      EndDo
      If nValorSW7 != nValorWork .and. ( !AVFLAGS("INV_ANT_GERA_CAMB_FIN") .Or. M->W6_TITINAN <> '1' )
         //** BHF - 11/12/08 -> Verificação para alteração das parcelas de cambio.
	     nIndiceRecSWB := SaveOrd("SWB")
   	     aOrdE2 := SaveOrd("SE2")   //TRP- 02/02/2010
   	     SWB->(DbSetOrder(1))
         If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
            // - Caso tenha titulo liquidado, não altera invoices.
            While !SWB->(EOF()) .And. (SWB->WB_HAWB == SW6->W6_HAWB)
               If !Empty(SWB->WB_CA_DT)
                  lAltodasInvoice:=.F.
                  Exit
               Else
                  lAltodasInvoice:=.T.
	           EndIf

	           //TRP - 02/02/2010 - Valida a compensação de parcelas no financeiro.
	           SE2->(DbSetOrder(6))
               If SE2->(dbSeek(xFilial("SE2")+SWB->(WB_FORN+WB_LOJA+WB_PREFIXO+WB_NUMDUP+WB_PARCELA)))
                  If SE2->E2_VALOR <> SE2->E2_SALDO
		             lAltodasInvoice:=.F.
                     Exit
		          Endif
		       Endif

	           SWB->(dbSkip())
      	    EndDo
         EndIf
         RestOrd(nIndiceRecSWB,.T.)
         RestOrd(aOrdE2, .F.)   //TRP- 02/02/2010
         //** BHF
         lReturn         := .T.
      EndIf
   EndIf
   //**

   SW7->(DBSEEK(xFilial("SW7")+cHAWB))
   SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))

   /// FRETE
   IF FI400SetCPag("FRETE") .AND. (SW6->W6_VLFRECC # M->W6_VLFRECC .OR. ;         // GFP - 22/03/2013
                                   SW6->W6_FREMOED # M->W6_FREMOED .OR. ;
                                   SW6->W6_TX_FRET # M->W6_TX_FRET .OR. ;
                                   SW6->W6_VENCFRE # M->W6_VENCFRE .OR. ;
                                   SW6->W6_HOUSE   # M->W6_HOUSE   .OR. ;
                                   SW6->W6_AGENTE  # M->W6_AGENTE  .OR. ;
                                   SW6->W6_FORNECF # M->W6_FORNECF .OR. ;  //LRS - 26/11/2015
                                   SW6->W6_LOJAF   # M->W6_LOJAF   .OR. ;
                                   SW6->W6_CONDP_F # M->W6_CONDP_F .OR. ;
                                   Empty(SW6->W6_NUMDUPF))
      lAltFrete := .T.
      IF cPaisLoc # "BRA"
         lTitFreteIAE :=.T.
      ENDIF
      lRETURN:= .T.
   ENDIF

   /// SEGURO
   IF FI400SetCPag("SEGURO") .AND. (SW6->W6_VL_USSE # M->W6_VL_USSE   .OR. ;        // GFP - 22/03/2013
                                    SW6->W6_SEGMOED # M->W6_SEGMOED   .OR. ;
                                    SW6->W6_NF_SEG  # M->W6_NF_SEG    .OR. ;
                                    SW6->W6_VENCSEG # M->W6_VENCSEG   .OR. ;
                                    SW6->W6_TX_SEG  # M->W6_TX_SEG    .OR. ;
                                    SW6->W6_CORRETO # M->W6_CORRETO   .OR. ;
                                    SW6->W6_FORNECS # M->W6_FORNECS   .OR. ;  //LRS - 26/11/2015
                                    SW6->W6_LOJAS   # M->W6_LOJAS     .OR. ;
                                    SW6->W6_CONDP_S # M->W6_CONDP_S   .OR. ;
                                    Empty(SW6->W6_NUMDUPS))
      // EOB - 29/05/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF !lSegInv .OR. cPaisLoc # "BRA"
         lAltSeguro := .T.
         lTitSeguroIAE:=.T.
      ENDIF
      lRETURN:= .T.
   ENDIF

   // Provisorios
   IF SW6->W6_CONTA20 # M->W6_CONTA20 .OR. SW6->W6_CONTA40   # M->W6_CONTA40   .OR.;
      SW6->W6_CONTA40 # M->W6_CONTA40 .OR. SW6->W6_CONTA40HC # M->W6_CONTA40HC .OR.;
      SW6->W6_OUTROS  # M->W6_OUTROS
      lRETURN:= .T.
   ENDIF

   If EasyGParam("MV_ESS0022",,.F.) .and. SWD->( dbsetorder(1), dbseek( xFilial("SWD")+M->W6_HAWB ) )
      while SWD->( ! eof() ) .and. SWD->(WD_FILIAL+WD_HAWB)==M->(W6_FILIAL+W6_HAWB) //.and. SWD->WD_DESPESA $ &(FRETE+"|"+SEGURO)
         if FRETE $ SWD->WD_DESPESA .And. !Empty(EICTemNBS(SWD->WD_DESPESA,M->W6_VIA_TRA)) .and. SWD->WD_MOEDA # M->W6_FREMOED .and. SWD->WD_TX_MOE # M->W6_TX_FRET .and. SWD->WD_VL_MOE <> M->W6_VLFRECC
            lRETURN:= .T.
            lAltFrete := .T.
            BREAK
         elseif SEGURO $ SWD->WD_DESPESA .And. !Empty(EICTemNBS(SWD->WD_DESPESA,M->W6_VIA_TRA)) .and. SWD->WD_MOEDA  # M->W6_SEGMOED .and. SWD->WD_TX_MOE # M->W6_TX_SEG .and. SWD->WD_VL_MOE <> M->W6_VL_USSE
            lRETURN:= .T.
            lAltSeguro := .T.
            BREAK
         endif
         SWD->( dbskip() )
      enddo
   endif

   FI400VAlInv()  // GFP - 25/11/2013 - Validações movidas para função separada para atender o Ponto de Entrada FI400DIAlterou

   IF SW6->W6_TAB_PC # M->W6_TAB_PC //ASK 28/06/2007 - Gera novos títulos caso altere a tabela de pré-calculo.
      lRETURN:= .T.
      BREAK
   ENDIF
END SEQUENCE

SW6->(DBSETORDER(nInd6))
SW7->(DBSETORDER(nInd7))
SELECT(nAlias)

RETURN lRETURN

*--------------------------------------------------*
FUNCTION FI400SW7(cHAWB)
*--------------------------------------------------*
LOCAL cFilSW7:=xFiliaL("SW7")

/* wfs - out/2019: ajustes de performance */
BeginSQL Alias "SQLAUX"
   Select W7_PO_NUM From %table:SW7%
   Where %NotDel% And W7_FILIAL = %exp:cFilSW7% And W7_HAWB = %exp:AvKey(cHAWB,"W7_HAWB")% And W7_SEQ = 0
   Group By W7_PO_NUM
EndSql

If SQLAUX->(!Eof() .And. !Bof())     
   SQLAUX->(DBGoTop())
   While SQLAUX->(!Eof())
      If AScan(aPos, SQLAUX->W7_PO_NUM) == 0
         AAdd(aPos, SQLAUX->W7_PO_NUM)
      EndIf
      SQLAUX->(DBSkip())
   EndDo
EndIf
  
SQLAUX->(DbCloseArea())

RETURN .T.
*--------------------------------------------------*
FUNCTION FI400Gera()
*--------------------------------------------------*
LOCAL nCont :=0, cNumOld, nSaldo := 0, aTitulo
LOCAL cDesp :=Work->DESP
LOCAL cHawb :=Work->HAWB
LOCAL nRecno:=Work->(Recno())
LOCAL cMoeda:=EasyGParam("MV_SIMB1")
LOCAL cFornec,cLojaF,cCliente,cLojaCli,cNatureza
LOCAL MV_OLD01,MV_OLD02,MV_OLD03,MV_OLD04
Private cUltParc := ""  // GFP - 20/01/2014

ProcRegua(10)
IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(Work->DOCTO)
   cNroDupl := Work->DOCTO
ELSE
   /*IF FindFunction("AvgNumSeq")//AVGERAL.PRW
      cNroDupl := AvgNumSeq("SWD","WD_CTRFIN1")
   ELSE
      cNroDupl := GetSXENum("SWD","WD_CTRFIN1")
      ConfirmSX8()
   ENDIF*/
   cNroDupl := NumTit("SWD","WD_CTRFIN1")
ENDIF

Work->(DBSEEK(cDesp+cHawb))
cNumOld:=Work->TRNUMDUP2
DO WHILE Work->(!EOF()) .AND. cDesp == Work->DESP .AND. cHawb == Work->HAWB
   IncProc()
   nCont++
   IF EMPTY(Work->TRNUMDUP2) .AND. EMPTY(Work->TRNUMDUP3)
      IF EMPTY(cNumOld)
         nSaldo:=Work->SALDO
         Work->TRNUMDUP2:=cNroDupl
      ELSE
         Work->TRNUMDUP2:=cNroDupl
         Work->TRNUMDUP3:=cNumOld
         nSaldo:=Work->TRSLDODUP
      ENDIF
   ENDIF
   Work->(DBSKIP())
ENDDO

IF nSaldo = 0
   RollBackSX8()
   HELP("",1,"AVG0000401")//"Não há saldo para geracao de Titulos"
   Work->(DBGOTO(nRecno))
   RETURN .F.
ENDIF

SY5->(DBSEEK(XFILIAL("SY5")+cDesp))
IF EMPTY(SY5->Y5_FORNECE)
   cFornec:=EasyGParam("MV_FORDESP")
   cLojaF :=EasyGParam("MV_LOJDESP")
ELSE
   cFornec:=SY5->Y5_FORNECE
   cLojaF :=SY5->Y5_LOJAF
ENDIF
IF EMPTY(SY5->Y5_CLIENTE)
   cCliente:=EasyGParam("MV_CLIDESP")
   cLojaCli:=EasyGParam("MV_CLODESP")
ELSE
   cCliente:=SY5->Y5_CLIENTE
   cLojaCli:=SY5->Y5_LOJACLI
ENDIF
IF EMPTY(SY5->Y5_NATUREZ)
   cNatureza:=EasyGParam("MV_NATDESP")
ELSE
   cNatureza:=SY5->Y5_NATUREZ
ENDIF

IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	IF nSaldo < 0
	   nErroDup:=1
	   SA2->(DBSETORDER(1))
	   IF SA2->(DBSEEK(XFILIAL("SA2")+cFornec+cLojaF))

		  nErroDup:=GeraDupEic(cNroDupl,;             //Numero das duplicatas
			   (nSaldo*(-1)),;       //Valor da duplicata
			   dDataBase,;           //data de emissao
			   dDataBase,;           //Data de vencimento
			   cMoeda,;              //Simbolo da moeda
			   "EIC",;               //Prefixo do titulo
			   "NF" ,;               //Tipo do titulo
			   1,;                   //Numero de parcela.
			   cFornec,;             //Fornecedor
			   cLojaF,;              //Loja
			   "SIGAEIC",;           //Origem da geracao da duplicata (Nome da rotina)
			   "P: "+ALLTRIM(cHawb)+STR0038,;//Historico da geracao //" Despesas Despachante"
			   0,.F.,SW6->W6_HAWB)   //Taxa da moeda (caso usada uma taxa diferente a
	   ENDIF

	ELSEIF nSaldo > 0

	   MV_OLD01:=mv_par01
	   MV_OLD02:=mv_par02
	   MV_OLD03:=mv_par03
	   MV_OLD04:=mv_par04

	   PRIVATE lMsHelpAuto := .T.
	   PRIVATE lMsErroAuto := .F.

	   aTitulo:={}
	   AADD(aTitulo,{"E1_PREFIXO","EIC",})
	   AADD(aTitulo,{"E1_NUM"    ,cNroDupl ,})
	   AADD(aTitulo,{"E1_PARCELA","0"  ,})
	   AADD(aTitulo,{"E1_TIPO"   ,"NF" ,})
	   AADD(aTitulo,{"E1_NATUREZ",cNatureza,})
	   AADD(aTitulo,{"E1_CLIENTE",cCliente ,})
	   AADD(aTitulo,{"E1_LOJA"   ,cLojaCli ,})
	   AADD(aTitulo,{"E1_EMISSAO",dDataBase,})
	   AADD(aTitulo,{"E1_VENCTO" ,dDataBase,})
	   AADD(aTitulo,{"E1_VENCREA",DataValida(dDataBase,.T.),})
	   AADD(aTitulo,{"E1_VALOR"  ,nSaldo   ,})
	   AADD(aTitulo,{"E1_ORIGEM" ,"SIGAEIC",})
	   MsExecAuto({|x,y| FINA040(x,y)},aTitulo,3)

	   MV_PAR01:=mv_OLD01
	   MV_PAR02:=mv_OLD02
	   MV_PAR03:=mv_OLD03
	   MV_PAR04:=mv_OLD04

	ENDIF
EndIF

ProcRegua(nCont)

Work->(DBSEEK(cDesp+cHawb))
DO WHILE  Work->(!EOF()) .AND. cDesp == Work->DESP .AND. cHawb == Work->HAWB
   IncProc()
   SWD->(DBGOTO(VAL(Work->SWDRECNO)))
   SWD->(RECLOCK("SWD",.F.,))
   SWD->WD_CTRFIN2:=Work->TRNUMDUP2
   SWD->WD_CTRFIN3:=Work->TRNUMDUP3
   SWD->(MSUNLOCK())
   Work->(DBSKIP())
ENDDO

Work->(DBGOTO(nRecno))
oMark:oBrowse:ReFresh()

Return .T.

*--------------------------------------------------*
FUNCTION FI400BaixaPA()
*--------------------------------------------------*
LOCAL cFilSA2:=xFilial('SA2')
LOCAL cFilSWD:=xFilial('SWD')
LOCAL cFilSYB:=xFilial('SYB')
LOCAL aDespesas:={},nCont:=0, lErro:=.T.
LOCAL cMoeda  :=EasyGParam("MV_SIMB1"),I,D
Private cUltParc := ""  // GFP - 20/01/2014
ProcRegua(4)
SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SA2->(DBSETORDER(1))

lDespDA := IF(TYPE("lDespDA")<>"L",.T.,lDespDA) //LGS-25/05/2016 //LRS - 06/04/2016

SWD->(DBSEEK(cFilSWD+SW6->W6_HAWB))
DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
         SWD->WD_HAWB == SW6->W6_HAWB

   IF nCont > 4
      ProcRegua(4)
   ENDIF
   nCont++
   IncProc()

//   IF SWD->WD_DESPESA $ '101,102,103,901,902,903' // LDR - 27/05/04
   IF SWD->WD_DESPESA $ '101,901,902,903'
      SWD->(dbSkip())
      LOOP
   ENDIF

   //LRS - 06/04/2016
   IF SWD->WD_DA == "1" .AND. (!lDespDA  .OR. ValPresCont(Alltrim(SW6->W6_TIPOFEC))) //LRS - 10/10/2018
      SWD->(dbSkip())
      LOOP
   EndIF

   IF EMPTY(SWD->WD_CTRFIN1) .AND.;
      !EMPTY(SWD->WD_FORN)   .AND.;
      !EMPTY(SWD->WD_LOJA)   .AND.;
      SWD->WD_BASEADI $ cSim
      AADD(aDespesas, SWD->(RECNO()) )
   ENDIF

   SWD->(dbSkip())

ENDDO

ProcRegua(LEN(aDespesas)+1)
IncProc()

IF LEN(aDespesas) > 0
   DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.F.)
ENDIF

IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	FOR I := 1 TO LEN(aDespesas)
	  IncProc()
	  SWD->(DBGOTO(aDespesas[I]))
	  IF !SA2->(DBSEEK(cFilSA2+SWD->WD_FORN+SWD->WD_LOJA))
		 LOOP
	  ENDIF
	  SYB->(DBSEEK(cFilSYB+SWD->WD_DESPESA))

	  // JBS - 27/04/2004 - OS 0028/04 - 0655/04
	  IF cPaisLoc == "BRA" // Sempre é Brasil
		 FOR D := 1 TO SWD->(FCount())// AWR - 13/05/2004
			 SWD->( M->&(FIELDNAME(D)) := FieldGet(D) )
		 NEXT

		 cIniDocto := SWD->WD_DOCTO
		 cTIPO_Tit := "NF"
		 cCodFor   := SWD->WD_FORN
		 cLojaFor  := SWD->WD_LOJA
		 nMoedSubs := 1
		 nValorS   := SWD->WD_VALOR_R
		 cEMISSAO  := dDataBase //RRV - 24/10/2012 - Gera o titulo com data de emissão de acordo com a data base do sistema.
		 cParcela  := SWD->WD_PARCELA
		 //cHistorico:="P: "+ALLTRIM(SW6->W6_HAWB)+' '+SYB->YB_DESCR//"Proc."
		 cHistorico:=AvKey("P: "+ALLTRIM(SW6->W6_HAWB)+' '+SYB->YB_DESCR,"E2_HIST")//"Proc."

		 //ISS - 06/01/11 - Ponto de entrada para alterar os valores iniciais da tela para inclusão de títulos no contas a pagar
		 If EasyEntryPoint("EICFI400")
			Execblock("EICFI400",.F.,.F.,"FI400BAIXAPA_ALTCPO")
		 EndIf

		 If FI400TITFIN("SWD_ADI","2") // Inclusao
			M->WD_GERFIN := "1"
			// EOS - 21/05/04 - Pode acontecer de ter duas despesas iguais para diferentes fornecedores, portanto
			//                  nao basta o seek por despesa e sim checar se bate os recnos entre SWD e TRB
			FIContabEIC('HEADER',,.T.)
			TRB->(dbseek(SWD->WD_HAWB+SWD->WD_DESPESA))
			DO WHILE !TRB->(eof()) .AND. TRB->WD_HAWB    == SWD->WD_HAWB ;
								   .AND. TRB->WD_DESPESA == SWD->WD_DESPESA
			   IF TRB->RECNO == SWD->(RECNO())
				  DI500GrvDESP("3",.F.)// Alteracao
				  FI400MOVCONT("DESPACHANTE","I")
				  lErro := .F.
				  EXIT
			   ENDIF
			   TRB->(dbSkip())
			ENDDO
		 Endif
	  ELSE
		 IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(SWD->WD_DOCTO)
			cNroDupl := SWD->WD_DOCTO
		 ELSE
			/*IF FindFunction("AvgNumSeq")//AVGERAL.PRW
			   cNroDupl := AvgNumSeq("SWD","WD_CTRFIN1")
			ELSE
			   cNroDupl := GetSXENum("SWD","WD_CTRFIN1")
			   ConfirmSx8()
			ENDIF*/
			cNroDupl := NumTit("SWD","WD_CTRFIN1")
		 ENDIF

		 lErro:=.F.
		 SWD->(RECLOCK("SWD",.F.))
		 SWD->WD_CTRFIN1:=cNroDupl
		 SWD->WD_DTENVF :=dDataBase
		 SWD->(MSUNLOCK())

		 dData_Emis:= dDataBase
		 dData_Emis:=If (dData_Emis > SWD->WD_DES_ADI,SWD->WD_DES_ADI,dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
		 GeraDupEic(SWD->WD_CTRFIN1,;        //Numero das duplicatas
					SWD->WD_VALOR_R  ,;      //Valor da duplicata
					dData_Emis,;              //data de emissao
					SWD->WD_DES_ADI,;        //Data de vencimento
					cMoeda,;                 //Simbolo da moeda
					"EIC",;                  //Prefixo do titulo
					"NF" ,;                  //Tipo do titulo
					1,;                      //Numero de parcela.
					SWD->WD_FORN,;           //Fornecedor
					SWD->WD_LOJA,;           //Loja
					"SIGAEIC",;              //Origem da geracao da duplicata (Nome da rotina)
					"P: "+ALLTRIM(SW6->W6_HAWB)+' '+SYB->YB_DESCR,;
					0,.T.,SW6->W6_HAWB)      //Taxa da moeda (caso usada uma taxa diferente a
	  ENDIF
	NEXT
EndIF
IF LEN(aDespesas) > 0
   FIContabEIC('FOOTER',,.F.)//Forca fechar o cProva
ENDIF

IF lErro
   MSGINFO(STR0077) //"Nao houve Geracao de Titulos."
ELSE
   If(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,{"FI400_POS_BAIXA_PA_OK", aDespesas}),) 
   MSGINFO(STR0078) //"Geracao Concluida."
ENDIF

RETURN .T.

*--------------------------------------------------------------------------------------*
FUNCTION FI400ManutCambio(cManut,cHawb,aTabInv,cParc,dDtEMB,lGRV_FIN_EIC,cAliasSW9)
*--------------------------------------------------------------------------------------*
LOCAL cFilSWB:=xFilial("SWB"), cFilSWA:=xFilial("SWA"), cChavSWA, cChavSWB, bWhilSWB, i, nPosCpoUsr := 0
PRIVATE lGravaCamb := .T. //TRP - 02/08/2011 - Variável para ser utilizada em rdmake. Desviar gravação do Câmbio.
IF lGRV_FIN_EIC = NIL
   lGRV_FIN_EIC:=.F.
ENDIF
IF cAliasSW9 = NIL
   cAliasSW9 := "SW9"
ENDIF

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"GERA_CAMBIO"),)  //TRP - 02/08/2011 - Ponto de Entrada para não gravar o câmbio

If lGravaCamb

   DO CASE
      CASE cManut == 'ESTORNA'

           cChavSWA := cFilSWA + cHawb + "D"
           cChavSWB := cFilSWB + cHawb + "D"
           bWhilSWB := {|| SWB->WB_FILIAL == cFilSWB .AND. SWB->WB_HAWB  == cHawb ;
                        .AND. SWB->WB_PO_DI == "D" }

           SWA->(dBSETORDER(1))
           IF SWA->(DBSEEK(cChavSWA))
              SWA->(RecLock("SWA",.F.))
              SWA->(dbDelete())
              SWA->(MSUNLOCK())
           ENDIF
           SWB->(dBSETORDER(1))
           SWB->(dbSeek(cChavSWB))
           DO While SWB->(!Eof()) .And. EVAL(bWhilSWB)
              SWB->(RecLock("SWB",.F.))
              SWB->(dbDelete())
              SWB->(MSUNLOCK())
              SWB->(dbSkip())
           EndDo

      CASE cManut == 'GRVCAPA'

           //SWB->(dBSETORDER(1))
           //IF SWB->(DBSEEK(xFilial("SWB")+cHawb))
           SWA->(dBSETORDER(1))
           IF !SWA->(DBSEEK(xFilial("SWA")+cHawb+"D"))
              SWA->(RecLock("SWA",.T.))
           ELSE
              SWA->(RecLock("SWA",.F.))
           ENDIF
           SWA->WA_FILIAL := xFilial("SWA")
           SWA->WA_HAWB   := cHawb
           SWA->WA_CODCEDE:= '1'
           SWA->WA_CEDENTE:= SA2->A2_NREDUZ
           SWA->WA_FB_NOME:= SA2->A2_NREDUZ
           SWA->WA_DI_NUM:= SW6->W6_DI_NUM //MCF-10/07/2014
           IF cPaisLoc = "CHI" .AND. SW6->W6_PER_JUR # 0
              SWA->WA_PER_JUR:= SW6->W6_PER_JUR
              SWA->WA_DIA_JUR:= SW6->W6_DIA_JUR
           ENDIF
           //MCF-10/07/2014 - Força gravar o número da DI no câmbio caso o campo W6_DI_NUM esteja vazio.
           IF Empty(SWA->WA_DI_NUM)
           	  SWA->WA_DI_NUM:= SW6->W6_DI_NUM
           ENDIF
           SWA->WA_PO_DI := "D"
           SWA->(MSUNLOCK())
        //ENDIF

      CASE cManut == 'GRVPARCELA'

         //SW9->(DBGOTO(nRecnoSW9))
         (cAliasSW9)->(DBGOTO(nRecnoSW9))

         // EOB - 22/08/08 - Verifica se já já existia o câmbio
         nPosCpo := 0
         IF VALTYPE(aSWBCampos) == "A"
            nPosCpo:=ASCAN(aSWBCampos, { |aCpo| aCpo[1] == (cAliasSW9)->W9_INVOICE+(cAliasSW9)->W9_FORN+IF(EICLOJA(),(cAliasSW9)->W9_FORLOJ,"") } )
         ENDIF
         // GFP - 07/11/2013 - Tratamento de recuperação de campos de usuario
         IF TYPE("aSWBUserCps") <> "U" .And. VALTYPE(aSWBUserCps) == "A"
            nPosCpoUsr:=ASCAN(aSWBUserCps, { |aCpo| aCpo[1] == (cAliasSW9)->W9_INVOICE+(cAliasSW9)->W9_FORN+IF(EICLOJA(),(cAliasSW9)->W9_FORLOJ,"") } )
         ENDIF
         SWA->(dBSETORDER(1))
         IF !SWA->(DBSEEK(xFilial("SWA")+AvKey(cHawb, "WA_HAWB")+"D"))
            FI400ManutCambio('GRVCAPA',cHawb)
         EndIf
         SWB->(RecLock("SWB",.T.))
         SWB->WB_FILIAL := cFilSWB
         SWB->WB_HAWB   := cHawb //M->W6_HAWB
         SWB->WB_DT_DIG := dDataBase
         SWB->WB_TIPOREG:= '1'
         SWB->WB_INVOICE:= (cAliasSW9)->W9_INVOICE  //SW9->W9_INVOICE
         SWB->WB_MOEDA  := (cAliasSW9)->W9_MOE_FOB  //SW9->W9_MOE_FOB
         SWB->WB_PO_DI  := "D"
         If lWB_TP_CON
            SWB->WB_TP_CON  := "2"
         EndIf
         IF lGRV_FIN_EIC
            SWB->WB_DT_VEN := aTabInv[3]
            SWB->WB_FOBMOE := aTabInv[2]
            SWB->WB_NUMDUP := aTabInv[5]
            SWB->WB_PARCELA:= Alltrim(cParc)   //TRP - 24/10/2011 - Utilização da função Alltrim() pois o campo Parcela estava sendo gravado em branco.
            SWB->WB_FORN   := (cAliasSW9)->W9_FORN //SW9->W9_FORN
            IF EICLOJA()
               SWB->WB_LOJA:= (cAliasSW9)->W9_FORLOJ
            ENDIF
         ELSE

            IF cPaisLoc = "BRA"
               SWB->WB_FOBMOE := M->E2_VALOR
               SWB->WB_DT_VEN := M->E2_VENCTO
               SWB->WB_NUMDUP := M->E2_NUM
               SWB->WB_PARCELA:= M->E2_PARCELA
               SWB->WB_FORN   := M->E2_FORNECE
               IF SWB->(FIELDPOS("WB_LOJA"))#0 .AND. SWB->(FIELDPOS("WB_TIPOTIT"))#0 .AND. SWB->(FIELDPOS("WB_PREFIXO"))#0
                  SWB->WB_PREFIXO:=M->E2_PREFIXO
                  SWB->WB_TIPOTIT:=M->E2_TIPO
                  SWB->WB_LOJA   :=M->E2_LOJA
               ENDIF
               SW9->( RecLock("SW9",.F.) )
               SW9->W9_NUM := M->E2_NUM
               SW9->(MsUnlock())
            ELSE
               SWB->WB_FOBMOE := aTabInv[2]
               SWB->WB_DT_VEN := aTabInv[3]
               SWB->WB_NUMDUP := aTabInv[5]
               SWB->WB_PARCELA:= Alltrim(cParc)  //TRP - 24/10/2011 - Utilização da função Alltrim() pois o campo Parcela estava sendo gravado em branco.
               SWB->WB_FORN   := (cAliasSW9)->W9_FORN //SW9->W9_FORN
               IF EICLOJA()
                  SWB->WB_LOJA:= (cAliasSW9)->W9_FORLOJ
               ENDIF
            ENDIF
         ENDIF
         IF nPosCpo # 0
            SWB->WB_BANCO  := aSWBCampos[nPosCpo,2]
            SWB->WB_AGENCIA:= aSWBCampos[nPosCpo,3]
            SWB->WB_NUM    := aSWBCampos[nPosCpo,4]
            SWB->WB_DT     := aSWBCampos[nPosCpo,5]
            SWB->WB_LC_NUM := aSWBCampos[nPosCpo,6]
            SWB->WB_NR_ROF := aSWBCampos[nPosCpo,7]
            SWB->WB_DT_ROF := aSWBCampos[nPosCpo,8]
            SWB->WB_DT_CONT:= aSWBCampos[nPosCpo,9]
		    SWB->WB_CA_NUM := aSWBCampos[nPosCpo,10]
		    SWB->WB_LIM_BAC:= aSWBCampos[nPosCpo,11]
		    SWB->WB_ENV_BAC:= aSWBCampos[nPosCpo,12]
  		    IF SWB->(FIELDPOS("WB_CONTA")) # 0
               SWB->WB_CONTA  := aSWBCampos[nPosCpo,13]
            ENDIF
            ADEL( aSWBCampos, nPosCpo )
            ASIZE( aSWBCampos, LEN(aSWBCampos)-1 )

           //CCH - 17/08/2009 - Nopado pois o banco para pagamento não pode ser carregado automaticamente. Deverá ser escolhido pelo próprio usuário

		/*ELSE
           IF SA2->(DBSEEK(xFilial()+SWB->WB_FORN+IF(SWB->(FIELDPOS("WB_LOJA"))#0,SWB->WB_LOJA,""))) .AND. !EMPTY(SA2->A2_BANCO)//AWR - 20/06/2006
              SWB->WB_BANCO  := SA2->A2_BANCO
              SWB->WB_AGENCIA:= SA2->A2_AGENCIA
              IF SWB->(FIELDPOS("WB_CONTA")) # 0
                 SWB->WB_CONTA  := SA2->A2_NUMCON
              ENDIF
           ENDIF*/
        ENDIF
        SWB->WB_LINHA := PADL(nlinha,4,"0")
        // GFP - 07/11/2013 - Tratamento de recuperação de campos de usuario.
        IF nPosCpoUsr # 0
            FOR i := 1 To Len(aSWBUserCps)
               If SWB->WB_LINHA == aSWBUserCps[i,2]  // GFP - 28/11/2013
                  SWB->(&(aSWBUserCps[i,3]))  := aSWBUserCps[i,4]
               EndIf
            NEXT
        ENDIF
        If SWB->(FieldPos("WB_EVENT")) > 0
           SWB->WB_EVENT := PRINCIPAL
        EndIf

        nLinha += 1
        SWB->(MSUNLOCK())

        IF cPaisLoc = "CHI" .AND. SW6->W6_PER_JUR # 0
           SWB->(RecLock("SWB",.T.))
           SWB->WB_FILIAL := cFilSWB
           SWB->WB_HAWB   := cHawb
           SWB->WB_DT_DIG := dDataBase
           SWB->WB_TIPOREG:= '2'
           SWB->WB_INVOICE:= aTabInv[1]
           SWB->WB_FOBMOE := ((aTabInv[2] * (SW6->W6_PER_JUR/100)) / 360 ) * SW6->W6_DIA_JUR
           SWB->WB_DT_VEN := dDtEmb + SW6->W6_DIA_JUR
           SWB->WB_TIPO   := aTabInv[4]
           SWB->WB_NUMDUP := aTabInv[5]
           SWB->WB_PARCELA:= Alltrim(cParc)  //TRP - 24/10/2011 - Utilização da função Alltrim() pois o campo Parcela estava sendo gravado em branco.
           SWB->WB_FORN   := SW9->W9_FORN
           IF EICLOJA()
              SWB->WB_LOJA:= SW9->W9_FORLOJ
           ENDIF
           SWB->WB_MOEDA  := SW9->W9_MOE_FOB
           SWB->WB_PO_DI  := "D"
           SWB->(MSUNLOCK())
        ENDIF

ENDCASE
Endif
RETURN .T.

*--------------------------------------------------*
FUNCTION FI400Baixou(cHawb,cCod)
*--------------------------------------------------*
LOCAL lBaixa:=.F.

nOrdSWD:=SWD->(INDEXORD())
nOrdSW6:=SW6->(INDEXORD())
nOrdSY5:=SY5->(INDEXORD())

SW6->(DBSETORDER(1))
SW6->(DBSEEK(XFILIAL("SW6")+cHawb))
SWD->(DBSETORDER(1))
SWD->(DBSEEK(XFILIAL("SWD")+cHawb))
DO WHILE !SWD->(EOF()) .AND. XFILIAL("SWD")+cHawb == SWD->WD_FILIAL  + SWD->WD_HAWB
   //ASK - 23/01/2008 Inserido o parâmetro cCod para as despesas do Numerário (função chamada no EICNU400)
   If cCod <> Nil
      If Empty(cCod) .Or. cCod <> SWD->WD_CODINT
         SWD->(DbSkip())
         LOOP
      EndIf
   EndIf
   If !lBaixa
      lBaixa:=IsBxE2Eic("EIC",;
         SWD->WD_CTRFIN1,;
         "NF",;
         SWD->WD_FORN,;
         SWD->WD_LOJA)
   Endif
   SWD->(DBSKIP())
END
SWD->(DBSETORDER(nOrdSWD))
SW6->(DBSETORDER(nOrdSW6))
SY5->(DBSETORDER(nOrdSY5))

RETURN lBaixa
*--------------------------------------------------------------------------------------*
FUNCTION FI400Titulo(cParamIXB,cOrigem, cAliasWork, cIniParam)//EICAP100 E EICPO430
*--------------------------------------------------------------------------------------*
LOCAL cFilSW9
Local lExisCpoSWB:= SWB->(FIELDPOS("WB_LOJA" )) # 0 .AND. SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->(FIELDPOS("WB_PREFIXO")) # 0 //EOS - 30/04/04
//Local nChr
Local lMvEasy := EasyGParam("MV_EASY") == "S"

PRIVATE cDtBxCmp := EasyGParam("MV_DTBXCMP",," ")
PRIVATE dDtBxCmp := CTOD("")
PRIVATE nRecTrb  := 0
PRIVATE nValComp := 0
PRIVATE cForn:=""
PRIVATE nBaixar:=0
DEFAULT cOrigem := ""
Default cAliasWork := "TRB"
Default cIniParam  := ""
Private cUltParc := ""  // GFP - 20/01/2014
// SVG - 18/02/2010 -
//*** Verifica se existe o tratamento para vinculação direta de adiantamento com parcelas a pagar (1:1)
Private lAdVinculado := SWB->(FieldPos("WB_CHAVE")) > 0
//***
SA2->(DBSETORDER(1))
SW9->(DBSETORDER(1))

//cAliasWB := If(cOrigem == "EICAP100" .Or. cOrigem == "FORCA_CANCELAR" .Or. cOrigem == "SEM_BAIXA" .Or. cOrigem == "EICFI400","TRB","WORK1")
cAliasWB := cAliasWork

IF cParamIXB == "BAIXA_TITULO" .OR. cParamIXB == "BAIXA_PA_LO100"

   //ja esta posicionado no SWB, na inclusao de titulo os 2 campos do SWB ja estao preenchidos
   cForn:=SWB->WB_FORN
   cLoja:=SWB->WB_LOJA
   cFilSW9:=xFilial("SW9")
   SW9->(DBSEEK(cFilSW9+SWB->WB_INVOICE))
   IF EMPTY(cForn)
      DO WHILE SW9->(!EOF()) .AND.;
               SW9->W9_FILIAL  == cFilSW9 .AND.;
               SW9->W9_INVOICE == SWB->WB_INVOICE
         IF SW9->W9_HAWB == SWB->WB_HAWB
            cForn:=SW9->W9_FORN
            IF EICLOJA()
               cLoja:= SW9->W9_FORLOJ
            ENDIF
            EXIT
         ENDIF
         SW9->(DBSKIP())
      ENDDO
   ENDIF

   // EOS 30/04/04 - carrega c/ os cpos novos, se estiverem brancos, faz como era antes
   cPrefixo := "   "
   cTipoDup := "   "
   cLojaFor := "  "
   cParcela := SWB->WB_PARCELA
   IF lExisCpoSWB .AND. cPaisLoc == "BRA"
      cTipoDup:=SWB->WB_TIPOTIT
      cLojaFor:=SWB->WB_LOJA
      cPrefixo:=SWB->WB_PREFIXO
   ENDIF
   IF EMPTY(cTipoDup)
      cTipoDup:=FI400TipoDup(Left(SWB->WB_TIPOREG,1))
      SA2->(DBSEEK(xFilial("SA2")+cForn+IF(EICLOJA(),cLoja,"")))
      cLojaFor:=SA2->A2_LOJA
      cPrefixo:="EIC"
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400TITULO_001"),) // Jonato 10-Fev-2005

   // EOB - 03/2009 - incluso último parâmetro, indicando que se for para baixar o título, deve-se verificar se o título está baixado totalmente (E2_SALDO == 0)
   // e quando for para cancelar a liquidação, não necessita verificar a baixa total, pois pode haver compensacao,
   // portanto deve-se ver se há baixa parcial (E2_VALOR <> E2_SALDO)
   lBaixa:=FI400ParcBaixada(cPrefixo,SWB->WB_NUMDUP,cTipoDup,cForn,cLojaFor,SWB->WB_PARCELA,,IF(cOrigem == "FORCA_CANCELAR" .OR. cOrigem == "FORCA_CANCELAR_LO100",.F.,.T.))

   IF cOrigem == "EICAP100" .OR. cOrigem == "EICLO100"
      //ACB - 15/12/2010 - Acerto na sintaxe do parênteses
      IF cPaisLoc = "BRA" .AND. ((cAliasWB)->(FIELDPOS("TRB_ALT")) == 0 .OR. (cAliasWB)->TRB_ALT)

         IF (cAliasWB)->(FIELDPOS("TRB_ALT")) > 0
            TRB->TRB_GERA:=.T.
         ENDIF

         IF lBaixa
            IF !FI400Titulo("BAIXA_TITULO",IF(cOrigem == "EICAP100","FORCA_CANCELAR","FORCA_CANCELAR_LO100"), cAliasWB)
               RETURN .F.
            ENDIF
         ENDIF
         //JAP - 25/08/06
         /*
         IF LEFT(M->WA_PO_DI,1) == "D" .AND. SWB->WB_TIPOREG <> "P" .AND. SWB->WB_PGTANT > 0
            IF !BuscaSWB()
               RETURN .F.
            ENDIF
         ENDIF
         */
         IF !EMPTY(SWB->WB_NUMDUP+SWB->WB_PARCELA) .AND. !FI400Titulo("EXCLUI_TITULO",, cAliasWB)
            RETURN .F.
         ENDIF

         If cOrigem == "EICAP100"
            SWB->(DBGOTO(TRB->WB_RECNO))
         Else
            SWB->(DBGOTO(WORK1->WKREC_SWB))
         EndIf

         SWB->(RecLock("SWB",.F.))
         //IF TRB->WB_FOBMOE > 0  //AWR - 30/06/2006 - Dentro da funcao (FI400Titulo("INCLUI_TITULO","SEM_BAIXA")) ja verifica se o valor esta zerado // Bete - 29/07/04 - Só regerar o título se tiver valor, pois pode estar zerado numa compensacao de pagto antecipado
         // Tratamento para não gerar PR quando o MV_EASYFPO = N - TDF 19/08/10
         //SVG - 17/09/2010 - Não devera gerar PR de adiantamento no estorno do PA.
//         IF left(SWA->WA_PO_DI,1) <> "A" .or. !EMPTY(SWB->WB_CA_DT) .or. EasyGParam("MV_EASYFCA",,"N") == "S"
         IF left(SWA->WA_PO_DI,1) == "D" .or. !EMPTY(SWB->WB_CA_DT) .or. EasyGParam("MV_EASYFCA",,"N") == "S"	// GCC - 27/08/2013
            IF !FI400Titulo("INCLUI_TITULO","SEM_BAIXA", cAliasWb, cParamIXB)
               RETURN .F.
            ENDIF
         ENDIF
         lBaixa:=.F.
      ENDIF
   ENDIF

   IF EMPTY((cAliasWB)->WB_CA_TX) .AND. EMPTY((cAliasWB)->WB_CA_DT) .AND. lBaixa
      nBaixar:=5//para cancelar a baixa.
   ENDIF


   //JAP - 25/08/06
   IF !EMPTY((cAliasWB)->WB_CA_TX) .AND. !EMPTY((cAliasWB)->WB_CA_DT)   .AND.;
      !EMPTY((cAliasWB)->WB_BANCO) .AND. !EMPTY((cAliasWB)->WB_AGENCIA) .AND.;
      !lBaixa 															.AND.;
      ((Left(M->WA_PO_DI,1) <> "A" .And. Left(M->WA_PO_DI,1) <> "F" .And. Left(M->WA_PO_DI,1) <> "C" ).OR. ((Left(M->WA_PO_DI,1) == "A" .Or. Left(M->WA_PO_DI,1) == "F" .Or. Left(M->WA_PO_DI,1) == "C") .AND. (cAliasWB)->WB_TIPOTIT = "INV"))	// GCC - 27/08/2013
      nBaixar:=3	//para baixar.
   ENDIF

   IF (cOrigem == "FORCA_CANCELAR" .OR. cOrigem == "FORCA_CANCELAR_LO100") .AND. lBaixa//AWR - 19/06/2006 - Só vai cancelar a baixa se tiver baixado
      nBaixar:=5//para cancelar a baixa.
   ENDIF

ELSEIF cParamIXB ==  "BAIXA_TIT_PO430"

   SE2->(DBSETORDER(1))
   IF !SE2->(DBSEEK(xFilial()+SW2->W2_CHAVEFI))
      RETURN .T.
   ENDIF

   lBaixa:=FI400ParcBaixada(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_PARCELA)

   SE2->(DBSEEK(xFilial()+SW2->W2_CHAVEFI))// A funcao FI400ParcBaixada desposiciona o SE2

   IF EMPTY(dDtLiquidado) .AND. lBaixa
      nBaixar:=5//para cancelar a baixa.
   ENDIF

   IF !EMPTY(dDtLiquidado) .AND. !lBaixa
      nBaixar:=3//para baixar.
   ENDIF

ELSEIF cParamIXB == "BAIXA_TIT_LO100"

   //ja esta posicionado no SWB, na inclusao de titulo os 2 campos do SWB ja estao preenchidos
   cFilSW9:=xFilial("SW9")
   cForn:=SWB->WB_FORN
   IF EMPTY(cForn)
      SW9->(DBSEEK(cFilSW9+SWB->WB_INVOICE))
      DO WHILE SW9->(!EOF()) .AND.;
               SW9->W9_FILIAL  == cFilSW9 .AND.;
               SW9->W9_INVOICE == SWB->WB_INVOICE
         IF SW9->W9_HAWB == SWB->WB_HAWB
            cForn:=SW9->W9_FORN
            IF EICLOJA()
               cLoja:= SW9->W9_FORLOJ
            ENDIF
            EXIT
         ENDIF
         SW9->(DBSKIP())
      ENDDO
   ENDIF

   // EOS 30/04/04 - carrega c/ os cpos novos, se estiverem brancos, faz como era antes
   cPrefixo := "   "
   cTipoDup := "   "
   cLojaFor := "  "
   cParcela := SWB->WB_PARCELA
   IF lExisCpoSWB .AND. cPaisLoc == "BRA"
      cTipoDup:=SWB->WB_TIPOTIT
      cLojaFor:=SWB->WB_LOJA
      cPrefixo:=SWB->WB_PREFIXO
   ENDIF
   IF EMPTY(cTipoDup)
      cTipoDup:=FI400TipoDup(Left(SWB->WB_TIPOREG,1))
      SA2->(DBSEEK(xFilial("SA2")+cForn+IF(EICLOJA(),cLoja,"")))
      cLojaFor:=SA2->A2_LOJA
      cPrefixo:="EIC"
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400TITULO_002"),) // Jonato 10-Fev-2005

   lBaixa:=FI400ParcBaixada(cPrefixo,SWB->WB_NUMDUP,cTipoDup,cForn,cLojaFor,SWB->WB_PARCELA,,,SWB->WB_FILIAL)

   IF EMPTY(SWB->WB_CA_TX) .AND. EMPTY(SWB->WB_CA_DT) .AND. lBaixa
      nBaixar:=5//para cancelar a baixa.
   ENDIF

   IF !EMPTY(SWB->WB_CA_TX) .AND. !EMPTY(SWB->WB_CA_DT) .AND.;
      !EMPTY(SWB->WB_BANCO) .AND. !EMPTY(SWB->WB_AGENCIA) .AND. !lBaixa
      nBaixar:=3//para baixar.
   ENDIF

// EOB - 03/2009 - Inclusão de tratamento de compensação de títulos
ELSEIF cParamIXB == "COMP_TITULO"
   IF lExisCpoSWB
      PERGUNTE("AFI340",.F.)

      lContabiliza 	:= MV_PAR11 == 1
      lAglutina	 	:= MV_PAR08 == 1
      lDigita		:= MV_PAR09 == 1

      nIndRecSE2 := SaveOrd("SE2")
      nIndRecSWB := SaveOrd("SWB")

  	  SE2->(DBSETORDER(1))
      cFilSE2 := xFilial("SE2")
 
         //*** Novo tratamento para vinculação direta de adiantamento
         If lAdVinculado
/*            //Neste ponto, as tabelas SWB e TRB estão posicionadas no título INV a compensar.
*/
            If cOrigem == "ESTORNO"
               If !FI400Comp(cOrigem)
                  Return .F.
               EndIf
            Else
               //Neste ponto, as tabelas SWB e TRB estão posicionadas no título INV a compensar.
               nRecTrb := TRB->(Recno())
               //cChave:= TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)
               cChave:= SWB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA)//JVR - 13/03/10 - WB_chave na trb so é preenchido se for tipo Adiantamento
               //Posiciona a TRB no adiantamento que foi vinculado
               TRB->(DbGoTop())
               While TRB->(!Eof())
                  If AllTrim(TRB->WB_CHAVE) == cChave
                     nValComp := TRB->WB_PGTANT
                     If !FI400Comp(cOrigem)
                        Return .F.
                     EndIf
                  EndIf
                  TRB->(DbSkip())
               EndDo
               TRB->(dbGoto(nRecTrb))
            EndIf
         Else
            //JVR - 15/03/10
            IF !FI400Comp(cOrigem)
               Return .F.
            EndIf
	     EndIf

      //ENDIF

      RestOrd(nIndRecSE2,.T.)
      RestOrd(nIndRecSWB,.T.)
   ENDIF

ENDIF

//LGS-14/11/2014 - Sempre validar o MV_PAR01 antes de fazer inclusão, alteração da parcela de cambio.
cAutMotbx:="NOR" //NORMAL
IF SX1->(DBSEEK("EICTMB"+Space(4)))
	Pergunte("EICTMB",.F.)
	IF !EMPTY(MV_PAR01)
		cAutMotbx:=ALLTRIM(MV_PAR01)
	ENDIF
ENDIF

IF nBaixar # 0

   If AvFlags("SIGAEFF_SIGAFIN") .AND.;
      EF3->(dbSetOrder(7),dbSeek(xFilial("EF3")+"I"+SWB->(WB_HAWB+WB_FORN+WB_LOJA+WB_INVOICE+WB_LINHA)+"600")) .AND.;
      EF1->(dbSetOrder(1),dbSeek(xFilial("EF1")+EF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)))

      cAutMotbx := Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_MOTBXI")
   EndIf
   If SWB->(FieldPos("WB_MOTBX")) > 0 .And. !Empty(SWB->WB_MOTBX)
      cAutMotbx := SWB->WB_MOTBX
   EndIf
   Private lMsHelpAuto := .t.
   Private lMsErroAuto := .f.
   aBaixa:={}
   AADD(aBaixa,{"E2_PREFIXO" ,""                ,Nil})//01
   AADD(aBaixa,{"E2_NUM"     ,""                ,Nil})//02
   AADD(aBaixa,{"E2_PARCELA" ,""                ,Nil})//03
   AADD(aBaixa,{"E2_TIPO"    ,""                ,Nil})//04
   AADD(aBaixa,{"E2_FORNECE" ,""                ,Nil})//05
   AADD(aBaixa,{"E2_LOJA"    ,""                ,Nil})//06
   AADD(aBaixa,{"AUTMOTBX"   ,cAutMotbx         ,Nil})//07
   AADD(aBaixa,{"AUTBANCO"   ,""                ,Nil})//08
   AADD(aBaixa,{"AUTAGENCIA" ,""                ,Nil})//09
   AADD(aBaixa,{"AUTCONTA"   ,""                ,Nil})//10
   AADD(aBaixa,{"AUTDTBAIXA" ,CTOD("")          ,Nil})//11
   AADD(aBaixa,{"AUTHIST"    ,STR0039,Nil})//12 //'Baixa Automatica'
   AADD(aBaixa,{"AUTDESCONT" ,0                 ,Nil})//13
   AADD(aBaixa,{"AUTMULTA"   ,0                 ,Nil})//14
   AADD(aBaixa,{"AUTJUROS"   ,0                 ,Nil})//15
   AADD(aBaixa,{"AUTOUTGAS"  ,0                 ,Nil})//16
   //AADD(aBaixa,{"AUTVLRPG"   ,0                 ,Nil})//17
   AADD(aBaixa,{"AUTVLRME"   ,0                 ,Nil})//17
   AADD(aBaixa,{"AUTCHEQUE"  ,""                ,Nil})//18
   AADD(aBaixa,{"AUTTXMOEDA" ,0                 ,Nil})//19
   AADD(aBaixa,{"AUTDTDEB"   ,CTOD("")          ,Nil})//20
   SA6->(DBSETORDER(1))

   IF cParamIXB ==  "BAIXA_TIT_PO430"
      SA6->(DBSEEK(xFilial("SA6")+cBanco_Agencia))
      aBaixa[01,2]:=SE2->E2_PREFIXO
      aBaixa[02,2]:=SE2->E2_NUM
      aBaixa[03,2]:=SE2->E2_PARCELA
      aBaixa[04,2]:=SE2->E2_TIPO
      aBaixa[05,2]:=SE2->E2_FORNECE
      aBaixa[06,2]:=SE2->E2_LOJA
      aBaixa[08,2]:=Substr(cBanco_Agencia,1,3)//""//Banco
      aBaixa[09,2]:=Substr(cBanco_Agencia,4)//""//Agencia
      aBaixa[10,2]:=SA6->A6_NUMCON//""//Conta
      aBaixa[11,2]:=dDataBase
     // aBaixa[17,2]:=SE2->E2_VLCRUZ
      aBaixa[17,2]:=SE2->E2_VALOR
      aBaixa[19,2]:=SE2->E2_TXMOEDA
   ELSE
      If SWB->(FieldPos("WB_CONTA")) # 0 //DRL - 02/10/08
      //ja esta posicionado no SWB, na inclusao de titulo os 2 campos do SWB ja estao preenchidos
         SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA+SWB->WB_CONTA))
      Else
         SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA))
      EndIF
      aBaixa[01,2]:=cPrefixo
      aBaixa[02,2]:=SWB->WB_NUMDUP+SPACE(LEN(SE2->E2_NUM)-LEN(SWB->WB_NUMDUP))
      aBaixa[03,2]:=SWB->WB_PARCELA
      aBaixa[04,2]:=cTipoDup
      aBaixa[05,2]:=cForn//SW9->W9_FORN
      aBaixa[06,2]:=cLojaFor
      aBaixa[08,2]:=SWB->WB_BANCO
      aBaixa[09,2]:=SWB->WB_AGENCIA
      aBaixa[10,2]:=IF(SWB->(FIELDPOS("WB_CONTA")) # 0,SWB->WB_CONTA,SA6->A6_NUMCON)	//ASR 16/11/2005 - SA6->A6_NUMCON - GRAVA O NUMERO DA CONTA ESCOLHIDA NÃO MAIS A PRIMEIRA
      aBaixa[11,2]:= IF(!EMPTY(SWB->WB_DT_DESE),SWB->WB_DT_DESE,SWB->WB_CA_DT) // ASK 09/11/2007 - Data da Baixa (A5_BAIXA)

	   If SWB->(FieldPos("WB_DESCO")) > 0 .AND. SWB->WB_DESCO > 0 //AAF 22/06/2015 - Tratamento do desconto no cambio de importação
         aBaixa[13,2]:= Round(SWB->WB_DESCO*GetTaxa(cAutMotbx), 2) //LRS - 30/07/2015 - Conta para mandar o desconto em R$ corretamente.
        // aBaixa[13,2]:= SWB->WB_DESCO                 //MFR - 08/05/2020 - Alterado para enviar o desconto na própria moeda OSSME-4648 DTRADE-4332
	   EndIf

	  //aBaixa[17,2]:=SWB->WB_FOBMOE*SWB->WB_CA_TX
      If SWB->(FieldPos("WB_DESCO")) > 0 .AND. SWB->WB_DESCO > 0 //AAF 22/06/2015 - Tratamento do desconto no cambio de importação
	     aBaixa[17,2]:=SWB->WB_FOBMOE-SWB->WB_DESCO
	  Else
	     aBaixa[17,2]:=SWB->WB_FOBMOE
	  EndIf

      //aBaixa[17,2]:=SWB->WB_FOBMOE*SWB->WB_CA_TX
      //aBaixa[17,2]:=SWB->WB_FOBMOE
      aBaixa[19,2]:=SWB->WB_CA_TX // Solicitado por Wagner em 02/09/03
    //aBaixa[21,2]:=SWB->WB_CA_DT // Data de Liquidação
      aBaixa[20,2]:= IF(!EMPTY(SWB->WB_DT_DESE),SWB->WB_DT_DESE,SWB->WB_CA_DT) //ASK 09/11/2007 - Data de Disponib.(A5_DTDISPO)
      
      //AAF 03/11/2017 - Tratamento para movimentação em moeda estrangeira.
      If !Empty(SA6->A6_MOEDA) .AND. SA6->A6_MOEDA > 1
         AADD(aBaixa,{"AUTVLRPG"   ,0                 ,Nil})//21

         If SimbToMoeda(SWB->WB_MOEDA) <> SA6->A6_MOEDA
            aBaixa[21,2]:= Round(aBaixa[17,2]*aBaixa[19,2]/RecMoeda(aBaixa[11,2],SA6->A6_MOEDA),AVSX3("WB_FOBMOE",AV_DECIMAL))
         Else
            aBaixa[21,2]:= Round(aBaixa[17,2],AVSX3("WB_FOBMOE",AV_DECIMAL))
         EndIf
      EndIf
   ENDIF
   //RMD - 19/09/12 - Declaradas as variáveis pois a Totvs tornou esta declaração obrigatória na função FA050NUM(), sem motivo específico.
   RegToMemory("SE2",,,.F.) //MCF 23/09/2014
   aEval(aBaixa, {|x| M->&(x[1]) := x[2] })
   Private LF080AUTO := .T.
   Private LF050AUTO := .T.

   /* Verifica a filial a ser usada, quando for ambiente multi-filial. */
   If Type("lMultiFil") <> "U" .And. lMultiFil
      AAdd(aBaixa, {"E2_FILIAL", MultxFil("SE2", SWB->WB_FILIAL), Nil})
   EndIf
   //NCF - 09/05/2020 - Não envia o valor quando o motivo de baixa não movimenta banco.
   If !MovBcoBx(substr(cAutMotbx,1,3))                                       
      aDel(  aBaixa, aScan(aBaixa,{|x|x[1] == "AUTVLRME"}) )
      aSize( aBaixa, Len(aBaixa) - 1 )
   EndIf

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400ARRAY_BAIXA'),)
   MSExecAuto({|x,y|FINA080(x,y)},aBaixa,nBaixar)//3 para baixar ou 5 para cancelar a baixa.
   IF SX1->(DBSEEK("EICTMB"+Space(4)))
      SetKey (VK_F12,{|| Pergunte("EICTMB",.T.) })
      mv_par01:=cAutMotbx
   ENDIF

   IF lMSErroAuto
      MostraErro()
      RETURN .F.
   ELSE
      IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'FI400_BAIXAOK'),)
   ENDIF

ELSEIF cParamIXB == "EXCLUI_TITULO"
   //ja esta posicionado no SWB
   cFilSW9:=xFilial("SW9")
   SW9->(DBSEEK(xFilial("SW9")+SWB->WB_INVOICE))
   cForn:=SWB->WB_FORN
   cLoja:=SWB->WB_LOJA
   IF EMPTY(cForn)
      DO WHILE SW9->(!EOF()) .AND.;
               SW9->W9_FILIAL  == cFilSW9 .AND.;
               SW9->W9_INVOICE == SWB->WB_INVOICE
         IF SW9->W9_NUM == SWB->WB_NUMDUP
            cForn:=SW9->W9_FORN
            IF EICLOJA()
               cLoja:= SW9->W9_FORLOJ
            ENDIF
            EXIT
         ENDIF
         SW9->(DBSKIP())
      ENDDO
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"EXCLUI_TITULO_001"),) // Jonato 10-Fev-2005

   SA2->(DBSEEK(xFilial("SA2")+cForn+IF(EICLOJA(),cLoja,"")))
   IF EMPTY(cLoja)
      cLoja:=SA2->A2_LOJA
   ENDIF
   nParc := 1

   IF cPaisLoc == "BRA" .AND. SWB->WB_TIPOTIT <> "PR"
      IF !FI400TITFIN("SWB_AP100","4",.T.)//Exclusao
         SE2->(DBSETORDER(1))
         IF SE2->(DBSEEK(xFilial()+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+cForn+cLoja))
            RETURN .F. //So retorna .f. se acha a chave pois se nao achar tem que gerar outro titulo por cima - AWR
         ENDIF
      ENDIF
   ELSE
      DeleDupEIC("EIC",;                     //Prefixo do titulo
              SWB->WB_NUMDUP,;               //Numero das duplicatas
              nParc,;                        //Numero de parcela.
              IF(SWB->(FIELDPOS("WB_TIPOTIT")) # 0 .AND. SWB->WB_TIPOTIT == AVKEY("PR","WB_TIPOTIT"),"PR",FI400TipoDup(Left(SWB->WB_TIPOREG,1))),;
              cForn,;                        //Fornecedor
              SA2->A2_LOJA,;                 //Loja
              "SIGAEIC",,;                   //Origem da geracao da duplicata (Nome da rotina)
              SWB->WB_PARCELA)
   ENDIF

ELSEIF cParamIXB == "INCLUI_TITULO" .AND. ( (cAliasWB)->(FieldPos("TRB_GERA")) == 0 .OR. TRB->TRB_GERA)

   IF M->WA_PO_DI == "A"  // Bete 29/07/04 - Tratamento diferenciado para parcela de adiantamento
      SW2->(DBSEEK(xFilial("SW2")+LEFT(SWA->WA_HAWB,LEN(SW2->W2_PO_NUM))))
      SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
      nMoedSubs := SimbToMoeda(SW2->W2_MOEDA)//M->E2_MOEDA
      //nValorS   := (cAliasWB)->WB_PGTANT            //M->E2_VLCRUZ
      nValorS   := (cAliasWB)->WB_PGTANT + (cAliasWB)->WB_FOBMOE//JVR - 13/03/10 - acerto do valor para integração.
      IF LEFT(dDtEmiPA,5) == "SWB->"
         dDtEmiPA := dtOverTrb(cAliasWB, dDtEmiPA)
      ENDIF
      cEMISSAO  := &(dDtEmiPA)
      IF EMPTY(cEMISSAO)
         cEMISSAO  := dDataBase                 //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
      ENDIF
      cMoeda    := SW2->W2_MOEDA             // Bete 28/07/05
//      cHistorico:= "PO: "+ALLTRIM(M->WA_HAWB)+" PI: "+ALLTRIM((cAliasWB)->WB_INVOICE)//M->E2_HIST
      cHistorico:= Avkey("PO: "+ALLTRIM(M->WA_HAWB)+" PI: "+ALLTRIM((cAliasWB)->WB_INVOICE),"E2_HIST")//Acb - 15/09/2010
      nTxMoeda  := SWB->WB_CA_TX               //M->E2_TXMOEDA // SVG - 30/11/10 - Pegar a informação da taxa da tabela SWB
                                               //NCF - 14/05/2020
   ElseIf M->WA_PO_DI == "F" .Or. M->WA_PO_DI == "C" // GCC - 20/09/2013 - Tratamento para nova modalidade de pagamento antecipado vinculado a fornecedor
      nMoedSubs := SimbToMoeda((cAliasWB)->WB_MOEDA)
      nValorS   := (cAliasWB)->WB_PGTANT + (cAliasWB)->WB_FOBMOE
      dDtEmiPA  := dtOverTrb(cAliasWB, dDtEmiPA)
      cEMISSAO  := &(dDtEmiPA)
      IF Empty(cEMISSAO)
         cEMISSAO := dDataBase		// M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
      EndIf
      cMoeda    := (cAliasWB)->WB_MOEDA
      If M->WA_PO_DI == "F"
	      cHistorico:= Avkey("AF: "+ALLTRIM(M->WA_HAWB)+" AFI: "+ALLTRIM((cAliasWB)->WB_INVOICE),"E2_HIST")
      Else
         cHistorico:= Avkey("CF: "+ALLTRIM(M->WA_HAWB)+" CFI: "+ALLTRIM((cAliasWB)->WB_INVOICE),"E2_HIST")
      EndIf
      nTxMoeda  := SWB->WB_CA_TX	//M->E2_TXMOEDA // SVG - 30/11/10 - Pegar a informação da taxa da tabela SWB

   ELSE
      SW2->(DBSETORDER(1))
      SW7->(DBSETORDER(1))
      SW9->(DBSEEK(xFilial("SW9")+(cAliasWB)->WB_INVOICE+(cAliasWB)->WB_FORN+EICRetLoja(cAliasWB,"WB_LOJA")+(cAliasWB)->WB_HAWB))
      SA2->(DBSEEK(xFilial("SA2")+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
      SW7->(DBSEEK(xFilial("SW7")+SWA->WA_HAWB))
      SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
      nMoedSubs := SimbToMoeda(SW9->W9_MOE_FOB)//M->E2_MOEDA
      //nValorS   := (cAliasWB)->WB_FOBMOE              //M->E2_VLCRUZ
      nValorS   := (cAliasWB)->WB_FOBMOE + (cAliasWB)->WB_PGTANT//JVR - 13/03/10 - acerto do valor para integração.
      /*If (cAliasWB)->WB_FOBMOE == 0
         nValorS := (cAliasWB)->WB_PGTANT
      EndIf*/
      cEMISSAO  := &(dDtEmis)
      //cEMISSAO  := SW9->W9_DT_EMIS             //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
      cMoeda    := SW9->W9_MOE_FOB             // Bete 28/07/05
      //cHistorico:= "P: "+ALLTRIM(M->WA_HAWB)+" I: "+ALLTRIM((cAliasWB)->WB_INVOICE)//M->E2_HIST
      cHistorico:= AvKey("P: "+ALLTRIM(M->WA_HAWB)+" I: "+ALLTRIM((cAliasWB)->WB_INVOICE),"E2_HIST")
      nTxMoeda  := SW9->W9_TX_FOB
   ENDIF

   IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	   IF cPaisLoc = "BRA"
		  IF nValorS == 0
			 RETURN .F.
		  EndIf
		  If M->WA_PO_DI $ "AD"
			 cCodFor   := SA2->A2_COD			//M->E2_FORNECE
			 cLojaFor  := SA2->A2_LOJA			//M->E2_LOJA
		  Else
			 cCodFor   := (cAliasWB)->WB_FORN	//M->E2_FORNECE
			 cLojaFor  := (cAliasWB)->WB_LOJA	//M->E2_LOJA
		  EndIf

	//    cEMISSAO  := dDataBase                   //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
		  // SVG - 21/09/2010 - Movimentação bancaria correta quando PA.
		  cDtVecto  := (cAliasWB)->WB_DT_VEN              //M->E2_VENCTO  //NCF - 14/05/2020
		  IF M->WA_PO_DI == "A" .Or. M->WA_PO_DI == "F" .Or. M->WA_PO_DI == "C" 	// GCC - 27/08/2013
			 IF cEMISSAO > (cAliasWB)->WB_DT_VEN
				cDtVecto:=cEMISSAO              //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
			 ENDIF
		  Else
			 cDtVecto  := (cAliasWB)->WB_DT_VEN              //M->E2_VENCTO
			 //nTxMoeda  := (cAliasWB)->WB_CA_TX               //M->E2_TXMOEDA

			 IF cEMISSAO > (cAliasWB)->WB_DT_VEN
				cEMISSAO:= (cAliasWB)->WB_DT_VEN              //M->E2_EMISSAO - Atencao: a data de emissao nao pode ser maior que a de vencimento
			 ENDIF
		  EndIf
		  IF cOrigem # "SEM_BAIXA" .AND. (cAliasWB)->(FieldPos("WB_PARCELA")) > 0 .And. Empty((cAliasWB)->WB_PARCELA)
			 cParcela:=SPACE(LEN(SE2->E2_PARCELA))   //M->E2_PARCELA
		  ENDIF

		  IF lExisCpoSWB .AND. !EMPTY(SWB->WB_PREFIXO) .AND. !EMPTY(SWB->WB_NUMDUP) .AND. !EMPTY(SWB->WB_PARCELA) .AND. !EMPTY(SWB->WB_TIPOTIT)
			 cPrefixo  := SWB->WB_PREFIXO
			 cIniDocto := SWB->WB_NUMDUP
			 cTIPO_Tit := SWB->WB_TIPOTIT
			 cParcela  := SWB->WB_PARCELA
		  ELSE

			  //TRP-02/09/08 - Incrementa o valor da parcela no financeiro.
			 IF cOrigem # "SEM_BAIXA" .AND. (cAliasWB)->(FieldPos("WB_PARCELA")) > 0 .And. !Empty((cAliasWB)->WB_PARCELA)  //acb - 21/05/2010
				cParcela:= (cAliasWB)->WB_PARCELA
			 ENDIF

			 cPrefixo  := ""                          //M->E2_PREFIXO
			 cTIPO_Tit := "INV"                       //M->E2_TIPO

			 If !Empty((cAliasWB)->WB_NUMDUP)
				cIniDocto := (cAliasWB)->WB_NUMDUP
			 Else
				cIniDocto := NumTit("SW9","W9_NUM")//RMD - 07/07/08
			 Endif
		  ENDIF
		  //JAP - Verifica se a parcela é de adiantamento.
		  IF LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" .Or. LEFT(M->WA_PO_DI,1) == "C"		// GCC - 27/08/2013

              IF !EMPTY(SWB->WB_CA_TX) .AND. !EMPTY(SWB->WB_CA_DT) .AND. !EMPTY(SWB->WB_BANCO) .AND. !EMPTY(SWB->WB_AGENCIA)
			  	     cTipo_Tit := If( LEFT(SWB->WB_PO_DI,1) <> 'C' , "PA" , "NCF") 
			     ELSE
				      cTipo_Tit := "PR"
                  If lMvEasy
                     cIniDocto := If( LEFT(SWB->WB_PO_DI,1) <> 'C' , "AD" , "CF") + RIGHT(SW2->W2_PO_SIGA,LEN(SE2->E2_NUM)-2)
                  Else
                     cIniDocto := NumTit("SWB","WB_NUMDUP")
                  EndIf 
			     ENDIF
			     //MCF-18/12/2014
			     IF LEFT(M->WA_PO_DI,1) == "F" .AND. EMPTY(SW2->W2_PO_SIGA) .AND. ALLTRIM(cIniDocto) == "AD"
				     cIniDocto := "AD"+RIGHT(ALLTRIM(M->WA_HAWB),LEN(SE2->E2_NUM)-2)
              ELSEIF LEFT(M->WA_PO_DI,1) == "C" .AND. EMPTY(SW2->W2_PO_SIGA) .AND. ALLTRIM(cIniDocto) == "CF" //NCF - 05/06/2020
                 cIniDocto := "CF"+RIGHT(ALLTRIM(M->WA_HAWB),LEN(SE2->E2_NUM)-2)
			     ENDIF

			 cPrefixo := "EIC"
			 nParcela := 0
			 nRecnoSE2 := SE2->(Recno())

			 //JAP - 19/09/06 - Verifica se a parcela já existe na geração automática e gera as parcelas de acordo com as existentes.
			 IF Type("cParcela") <> "C" .OR. EMPTY(cParcela)
					SE2->(DbSetOrder(1))
				IF SE2->(dbSeek(xFilial("SE2") + cPrefixo + cIniDocto))  //14/05/2020
				   DO While SE2->(!EOF()) .AND. SE2->E2_TIPO = "PA" .OR. SE2->E2_TIPO = "NCF" .OR. (SE2->E2_TIPO = "PR";
																		 .AND. LEFT(SE2->E2_NUM,2) == "AD")

					  IF !EMPTY(SE2->E2_PARCELA)
						 nParcela := nParcela+1
					  ENDIF
					  SE2->(DbSkip())
				   ENDDO
				   /*IF nParcela = 0   // GFP - 22/01/2014
					  cParcela := Chr(nChr)
				   ELSE
					  cParcela := FI400TamCpoParc(nChr,nParc)
				   ENDIF*/
				ENDIF
				SE2->(DbGoto(nRecnoSE2))
			 ENDIF
		  ENDIF

		  // Bete - 28/07/05 - Se o retorno da SimbToMoeda for 0, significa que a moeda nao esta cadastrada em um dos MV_SIMBs.
		  IF nMoedSubs == 0
			 MSGSTOP(STR0100 + cMoeda + STR0101) //STR0100 "Não foi possível gerar o título! A moeda: " //STR0101 " não está configurada no Financeiro"
			 RETURN .F.
		  ELSEIF !FI400TITFIN("SWB_AP100","2",,,cParcela, cIniParam)// Inclusao   // GFP - 28/01/2014
			 RETURN .F.
		  ENDIF

		  //TRP - 27/04/09 - Atualizar o campo Número do Título na Invoice após geração do Título no Financeiro.
		  SW9->(DbSetOrder(1))
		  //If SW9->(DbSeek(xFilial("SW9") + SWB->WB_INVOICE))
		  If SW9->(dbSeek(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB", "WB_LOJA")+SWB->WB_HAWB))
			 Reclock("SW9",.F.)
			 SW9->W9_NUM := cIniDocto
			 SW9->(MsUnlock())
		  Endif
	   ELSE

            /*IF FindFunction("AvgNumSeq")//AVGERAL.PRW
                SWB->WB_NUMDUP:=AvgNumSeq("SW9","W9_NUM")
            ELSE
                SWB->WB_NUMDUP:=GetSXENum("SW9","W9_NUM")
                ConfirmSX8()
            ENDIF*/
            //SWB->WB_NUMDUP := NumTit("SWD","W9_NUM")
            SWB->WB_NUMDUP := NumTit("SW9","W9_NUM")//RMD - 07/07/08
            dData_Emis:= dDataBase
            dData_Emis:=If (dData_Emis > (cAliasWB)->WB_DT_VEN,(cAliasWB)->WB_DT_VEN,dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
            nErroDup:=GeraDupEic(SWB->WB_NUMDUP,;   //Numero das duplicatas
                    (cAliasWB)->WB_FOBMOE,;   //Valor da duplicata
                    dData_Emis,;        //data de emissao
                    (cAliasWB)->WB_DT_VEN,;   //Data de vencimento
                    SW2->W2_MOEDA,;    //Simbolo da moeda
                    "EIC",;            //Prefixo do titulo
                    "INV",;            //Tipo do titulo
                    1,;                //Numero de parcela.
                    SW9->W9_FORN,;     //Fornecedor
                    SA2->A2_LOJA,;     //Loja
                    "SIGAEIC",;        //Origem da geracao da duplicata (Nome da rotina)
                    "P: "+ALLTRIM(SWA->WA_HAWB)+" I: "+ALLTRIM((cAliasWB)->WB_INVOICE),;//Historico da geracao
                    0,,SWA->WA_HAWB)   //Taxa da moeda (caso usada uma taxa diferente a

            SWB->WB_PARCELA := SE2->E2_PARCELA//Por que o GeraDupEic pode converter para "A".

            if valtype(aTitInvoiceIAE) == "U" // MPG - 14/09/2018 -- CASO DE INCLUSÃO DE CÂMBIO DIRETAMENTE PELA TELA DE CONTROLE DE CÂMBIO DE LOCALIZAÇÕES E A VARIÁVEL DECLARADA COMO NULO
                aTitInvoiceIAE := {}
            endif
            
            IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SWB->WB_INVOICE+SWB->WB_FORN } ) = 0
                AADD(aTitInvoiceIAE,{ SWB->WB_INVOICE+SWB->WB_FORN, .T. } )
            ENDIF

	   ENDIF
   EndIF

   IF cOrigem # "SEM_BAIXA"
      //JAP
      IF LEFT(M->WA_PO_DI,1) <> "A" .And. LEFT(M->WA_PO_DI,1) <> "F" .And. LEFT(M->WA_PO_DI,1) <> "C"	// GCC - 27/08/2013
         IF !FI400Titulo("BAIXA_TITULO","EICFI400", cAliasWb)//EICAP100
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF

ENDIF

RETURN .T.
//EICAP100,EICDI500,EICPO400,EICCA150,EICNU400,AVFLUXO,EICDI154,EICCAD00,ICPADDI0_AP5,EICFI400

Static Function GetTaxa(cAutMotbx)
Local nRet := 1
SA6->(dbSeek(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA+SWB->WB_CONTA))
nMoedaBco:= Max(SA6->A6_MOEDA,1)
if nMoedaBco == 1 .or. !MovBcoBx(substr(cAutMotbx,1,3))
   nRet := SWB->WB_CA_TX
EndIf
Return nRet
   

Static Function dtOverTrb(cAliasTRB, dDate)
If (cAliasTRB)->(FieldPos(dDate)) > 0
    Return cAliasTRB+"->"+SUBSTR(dDate,6)
EndIf
Return dDate

*--------------------------------------------------------------------------------------*
Function FI400TipoDup(cTipoReg)
*--------------------------------------------------------------------------------------*
RETURN IF(cTipoReg ='2' .AND. cPaisLoc == 'CHI',"JR ","INV")

*--------------------------------------------------------------------------------------*
Function FI400ParcBaixada(cPrefixo,cNum,cTipo,cFornece,cLoja,cParc,lExiste,lBxTotal, cFilMulti)
*--------------------------------------------------------------------------------------*
Local lBaixa:=	.F., cFil:=xFilial("SE2")
DEFAULT lExiste := .F.
DEFAULT lBxTotal := .F.
Default cFilMulti:= cFil
cNum:=ALLTRIM(cNum)
cNum:= avkey(cNum,"E2_NUM") //cNum+SPACE( LEN(SE2->E2_NUM)-LEN(cNum) )

/* Verifica a filial a ser usada, quando for ambiente multi-filial. */
cFil:= MultxFil("SE2", cFilMulti)

SE2->(DbSetOrder(6))
If SE2->(dbSeek(cFil+cFornece+cLoja+cPrefixo+cNum))
   DO While SE2->(!EOF()) .And.;
            cFil+cFornece+cLoja+cPrefixo+cNum == ;
   		    SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) ;
            .And. !lBaixa
      IF lExiste
         If cTipo = SE2->E2_TIPO .AND.;
            (cParc=NIL .OR. SE2->E2_PARCELA == cParc)
            lBaixa := .T.
         Endif
      ELSE
         If cTipo = SE2->E2_TIPO .AND.;
            IF(lBxTotal,SE2->E2_SALDO == 0, .T.) .AND.;
            SE2->E2_PARCELA == cParc .AND.;
            (SE2->E2_SALDO == 0 .Or. SE2->E2_VALOR <> SE2->E2_SALDO)
            lBaixa := .T.
         Endif
      Endif
	  SE2->(DbSkip())
	Enddo
Endif
SE2->(DbSetOrder(1))

Return lBaixa

*--------------------------------------------------------------------------------------*
Function FI400VALDESP()
*--------------------------------------------------------------------------------------*
Local cCampo:=alltrim(subst(readvar(),4))

IF GetNewPar("MV_EASYFIN","N") = "N"
   RETURN .T. //RETORNAR SEMPRE VERDADEIRO
ENDIF

DO CASE
   //CASE cCampo=="WD_BASEADI"
   //     M->WD_PAGOPOR := IF(M->WD_BASEADI$'S,Y,1','1',IF(M->WD_BASEADI$'N,2','2',' '))
   CASE cCampo=="WD_GERFIN"
        IF !lBaixaDesp .AND. M->WD_DESPESA$'102/103'
           IF getnewpar("MV_CAMBIL",.F.)
              M->WD_GERFIN:='2'
              RETURN .F.
           ENDIF
        ENDIF
ENDCASE

RETURN !lBaixaDesp//(!lBaixaDesp.AND.lnoEnvFin)

*-----------------------------------------------*                 
FUNCTION FI400MOVCONT(cTipoMov,cAux)
*-----------------------------------------------*
Local nOrdSw7, nOrdSw2,nOrdSw9
Local lExistEZZ  := SX2->(dbSeek("EZZ"))

IF GetNewPar("MV_EICCONT","N") $ cNao // AWR - 28/05/2004
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

IF EasyGParam("MV_EASYFIN",,"N") $ cNao
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

DO CASE
   CASE cTipoMov == "GRV_CONTABIL"
        nOrdSw7:=SW7->(INDEXORD())
        nOrdSw2:=SW2->(INDEXORD())
        nOrdSw9:=SW9->(INDEXORD())
        SW7->(DBSETORDER(1))
        SW2->(DBSETORDER(1))
        SW7->(DBSEEK(XFILIAL("SW7")+SW6->W6_HAWB))
        SW2->(DBSEEK(XFILIAL("SW2")+SW7->W7_PO_NUM))

//      IF !EMPTY(SW6->W6_VLFRECC)//BuscaPPCC()='CC'
        IF lTitFreteIAE
           SY4->(DBSEEK(XFILIAL("SY4")+SW6->W6_AGENTE))
           SA2->(DBSEEK(xFilial("SA2")+SY4->Y4_FORN+SY4->Y4_LOJA))
           FI400ContabEIC('DETAIL','992',.T.,.F.) // FRETE INCLUSAO
           SW6->(RECLOCK("SW6",.F.))
           SW6->W6_DTLANCF:=CTOD('')//Forca branco p/ a funcao ContabEIC('FOOTER',,.F.) preencher
           SW6->(MSUNLOCK())
        ENDIF

        IF lTitSeguroIAE
           SYW->(DBSEEK(xFilial("SYW")+SW6->W6_CORRETO))
           SA2->(DBSEEK(xFilial("SA2")+SYW->YW_FORN+SYW->YW_LOJA))
           FI400ContabEIC('DETAIL','993',.T.,.F.) // SEGURO INCLUSAO
           SW6->(RECLOCK("SW6",.F.))
           SW6->W6_DTLANCS:=CTOD('')//Forca branco p/ a funcao ContabEIC('FOOTER',,.F.) preencher
           SW6->(MSUNLOCK())
        ENDIF

        SW9->(DBSETORDER(3))
        SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
        DO WHILE !SW9->(EOF()) .AND. SW6->W6_HAWB == SW9->W9_HAWB .AND.;
                 xFilial("SW9") == SW9->W9_FILIAL

           IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") .AND. T[2] } ) = 0
              SW9->(DBSKIP())
              LOOP
           ENDIF

           FI400MOVCONT("INVOICE","I")
           SW9->(RECLOCK("SW9",.F.))
           SW9->W9_DTLANC:=CTOD('')//Forca branco p/ a funcao ContabEIC('FOOTER',,.F.) preencher
           SW9->(MSUNLOCK())
           SW9->(DBSKIP())
        ENDDO

        SW7->(DBSETORDER(nOrdSW7))
        SW2->(DBSETORDER(nOrdSW2))
        SW9->(DBSETORDER(nOrdSW9))

		// EOS - 06/10/03
        IF cPaisLoc # "BRA" .AND. lExistEZZ
           cFilEZZ := xFilial("EZZ")
           EZZ->(DBSETORDER(1))
           EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB))
           DO WHILE !EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ;
                                  .AND. EZZ->EZZ_HAWB   == SW6->W6_HAWB
              FI400MOVCONT("INVOICE2","I")
              EZZ->(DBSKIP())
           ENDDO
        ENDIF

        lTitFreteIAE:=lTitSeguroIAE:=.F.
        aTitInvoiceIAE:={}
        IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'GRV_CONTABIL'),)

   CASE cTipoMov == "DEL_CONTABIL"
        nOrdSw9:=SW9->(INDEXORD())

        IF lTitFreteIAE
//      IF !EMPTY(SW6->W6_DTLANCF) .AND.
           SY4->(DBSEEK(XFILIAL("SY4")+SW6->W6_AGENTE))
           SA2->(DBSEEK(xFilial("SA2")+SY4->Y4_FORN +SY4->Y4_LOJA))
           FI400ContabEIC('DETAIL',;//Movimento contabil
                     '996',;        //Tipo de Contabilizacao // FRETE, EXCLUSAO
                     .T.,.T.)       //Processo Online
        ENDIF

        IF lTitSeguroIAE
//      IF !EMPTY(SW6->W6_DTLANCS) .AND.
           SYW->(DBSEEK(xFilial("SYW")+SW6->W6_CORRETO))
           SA2->(DBSEEK(xFilial("SA2")+SYW->YW_FORN+SYW->YW_LOJA))
           FI400ContabEIC('DETAIL','997',.T.,.T.)   // SEGURO -  EXCLUSÃO
        ENDIF
        SW9->(DBSETORDER(3))
        SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
        DO WHILE !SW9->(EOF()) .AND. SW6->W6_HAWB == SW9->W9_HAWB .AND.;
                                     xFilial("SW9") == SW9->W9_FILIAL

           IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SW9->W9_INVOICE+SW9->W9_FORN+IF(EICLOJA(),SW9->W9_FORLOJ,"") .AND. T[2]} ) = 0 .AND.;
              ASCAN(aDeletados , {|D| D[1] = "SW9" .AND. D[2] = SW9->(RECNO()) }  ) = 0
              SW9->(DBSKIP())
              LOOP
           ENDIF

           FI400MOVCONT("INVOICE","E")
           SW9->(DBSKIP())
        ENDDO
        SW9->(DBSETORDER(nOrdSW9))

        // EOS - 06/10/03
        IF cPaisLoc # "BRA" .AND. lExistEZZ
           cFilEZZ := xFilial("EZZ")
           EZZ->(DBSETORDER(1))
           EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB))
           DO WHILE !EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ;
                                  .AND. EZZ->EZZ_HAWB   == SW6->W6_HAWB
              FI400MOVCONT("INVOICE2","E")
              EZZ->(DBSKIP())
           ENDDO
        ENDIF

        IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'DEL_CONTABIL'),)

   CASE cTipoMov == "INVOICE"
        IF (cAux=='E'.AND. !EMPTY(SW9->W9_DTLANC)).OR.cAux=='I'
           nRecSW8 := SW8->(RECNO())
           nOrdSW8:= SW8->(INDEXORD())

           SW8->(DBSETORDER(1))
           SW8->(DBSEEK(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
           IF !FI400FornBanco(SW8->W8_PO_NUM,SW8->W8_PGI_NUM)
              IF !(SW2->W2_E_LC $ cSim)
                 SA2->(DBSEEK(xFilial("SA2")+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
              ELSE
                 SA2->(DBSEEK(xFilial("SA2")+SPACE(LEN(SA6->A6_CODFOR+SA6->A6_LOJFOR))))
             ENDIF
           ENDIF

           SW8->(DBSETORDER(nOrdSW8))
           SW8->(DBGOTO(nRecSW8))

           FI400ContabEIC('DETAIL',; //Movimento contabil
                     IF(cAux=="E",'995','991'),; //INVOICE' //Tipo de Contabilizacao
                     .T.,cAux=="E")       //Processo Online
        ENDIF

   CASE cTipoMov == "INVOICE2"
        // EOS - 06/10/03
        IF cPaisLoc # "BRA" .AND. lExistEZZ
           IF (cAux=='E'.AND. !EMPTY(EZZ->EZZ_DTLANC)) .OR. cAux=='I'
              SA2->(DBSEEK(xFilial("SA2")+EZZ->EZZ_FORN+EICRetLoja("EZZ","EZZ_FORLOJ")))

              FI400ContabEIC('DETAIL',; //Movimento contabil
                              IF(cAux=="E",'EZE','EZI'),; //Tipo de Contabilizacao=invoice sem itens
                              .T.,cAux=="E")       //Processo Online
           ENDIF
        ENDIF

       IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'INVOICE2'),)

   CASE cTipoMov == "DESPACHANTE"

        IF (cAux=='E'.AND. !EMPTY(SWD->WD_DTLANC)).OR.cAux=='I'
           SA2->(dbSeek(xFilial("SA2")+SWD->WD_FORN+SWD->WD_LOJA))
           FI400ContabEIC('DETAIL',; //Movimento contabil
                  IF(cAux == "E",'998','994'),;//     'DESPACHANTE'Tipo de Contabilizacao
                  .T.,cAux == "E")       //Processo Online
           IF cAux == 'I'
              SWD->(RECLOCK("SWD",.F.))
              SWD->WD_DTLANC:=CTOD('')//Forca branco p/ a funcao ContabEIC('FOOTER',,.F.) preencher
              SWD->(MSUNLOCK())
           ENDIF
        ENDIF

ENDCASE
RETURN
*-------------------------------------------------------*
FUNCTION FI400FornBanco(cPedido,cPGI)
*-------------------------------------------------------*
LOCAL lRet:=.F.
cPGI := IF (cPgi==NIL,cPedido ,cPgi)
nOrdSW2:=SW2->(INDEXORD())
SW2->(DBSETORDER(1))
IF SW2->(DBSEEK(XFILIAL("SW2")+cPedido)) .AND. SW2->W2_E_LC='1'

   nOrdSYH:=SYH->(INDEXORD())
   SYH->(DBSETORDER(2))
   IF SYH->(DBSEEK( XFILIAL("SYH")+cPedido )) .OR.;
      SYH->(DBSEEK( XFILIAL("SYH")+cPgi ))

      nOrdSWC:=SWC->(INDEXORD())
      SWC->(DBSETORDER(1))
      IF SWC->(DBSEEK(XFILIAL('SWC')+SYH->YH_LC_NUM))

         nOrdSA6:=SA6->(INDEXORD())
         SA6->(DBSETORDER(1))
         IF SA6->(DBSEEK(XFILIAL("SA6")+SWC->WC_BANCO+SWC->WC_AGENCIA))

            nOrdSA2:=SA2->(INDEXORD())
            SA2->(DBSETORDER(1))
            IF SA2->(DBSEEK(xFilial("SA2")+SA6->A6_CODFOR+SA6->A6_LOJFOR))
               lRet:=.T.
            ENDIF
            SA2->(DBSETORDER(nOrdSA2))

         ENDIF
         SA6->(DBSETORDER(nOrdSA6))

      ENDIF
      SWC->(DBSETORDER(nOrdSWC))

   ENDIF
   SYH->(DBSETORDER(nOrdSYH))

ENDIF
SW2->(DBSETORDER(nOrdSW2))

RETURN lRet
*------------------------------------------------------------------*
FUNCTION FI400ContabEIC(cRotina,cIdent,lOnLine,lEstorno)
*------------------------------------------------------------------*
IF lEstorno
   lOnLine:=.F.//Forca gerar o lancamento
ENDIF

RETURN ContabEic(cRotina,cIdent,lOnLine)

*------------------------------------------------------------------*
FUNCTION FIContabEIC(cRotina,cIdent,lOnLine)
*------------------------------------------------------------------*
IF GetNewPar("MV_EICCONT","N") $ cNao // AWR - 28/05/2004
   RETURN .T.
ENDIF

IF lHEADERAberto # NIL // AWR - 29/06/2004
   IF cRotina == 'HEADER' .AND. lHEADERAberto
      RETURN .T.
   ENDIF
   IF cRotina == 'FOOTER' .AND. !lHEADERAberto
      RETURN .T.
   ENDIF
ELSEIF cRotina == 'FOOTER'//AWR - Para quando ele chama o 'FOOTER' e nao abriu o 'HEADER' e a variavel esta lHEADERAberto = NIL
   RETURN .T.
ENDIF

IF cRotina == 'HEADER'// AWR - 29/06/2004
   lHEADERAberto:=.T.
ENDIF
IF cRotina == 'FOOTER'// AWR - 29/06/2004
   lHEADERAberto:=.F.
ENDIF

RETURN ContabEic(cRotina,cIdent,lOnLine)

*------------------------------------------------------------------*
FUNCTION FI400HelpTMB()
*------------------------------------------------------------------*
//T.M.B. = Tipo de Movimentacao Bancaria
LOCAL oDlg, Tb_Campos:={}, lRet:=.F.
LOCAL bAction:={|| lRet:=.T. , MV_PAR01:=TRB->DESCR , oDlg:End() }
LOCAL aSemSX3:={;
{"SIGLA"   ,"C",03,0},;
{"DESCR"   ,"C",10,0},;
{"CARTEIRA","C",01,0},;
{"MOVBANC" ,"C",01,0},;
{"COMIS"   ,"C",01,0},;
{"CHEQUE"  ,"C",01,0}}
Local lMtBxEsp	:= .F.
Local nHdlMot	:= 0

IF !File("SIGAADV.MOT")
   MSGINFO(STR0079) //"Arquivo SIGAADV.MOT nao existe"
   RETURN .F.
Else
	nHdlMot := FOPEN("SIGAADV.MOT",0)
	lMtBxEsp := ( FSEEK(nHdlMot,0,2) % 19 ) != 0 //VerIfica tamanho do arquivo
Endif

If lMtBxEsp
	aAdd(aSemSX3,{"ESPECIE"  ,"C",01,0})
EndIf

aCampos:={}
aHeader:={}
cArqTmp:=E_CriaTrab(,aSemSX3)
aCampos:=Nil //THTS - 07/02/2018 - Apos a chamada do E_CriaTrab, limpa o aCampos para que nao seja utilizado de forma errada em outra chamada do E_CriaTrab
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

APPEND FROM SIGAADV.MOT SDF

dbGoTop()

AADD(Tb_Campos,{"SIGLA"   ,,STR0115 }) //"Sigla"
AADD(Tb_Campos,{"DESCR"   ,,STR0080 }) //"Descricao"
AADD(Tb_Campos,{"CARTEIRA",,STR0081 }) //"Carteira"
AADD(Tb_Campos,{"MOVBANC" ,,STR0082 }) //"Mov. Bancaria"
AADD(Tb_Campos,{"COMIS"	  ,,STR0083 }) //"Comissao"
AADD(Tb_Campos,{"CHEQUE"  ,,STR0084 }) //"Cheque"
If lMtBxEsp
	AADD(Tb_Campos,{"ESPECIE"  ,,STR0168 }) //"Especie"
EndIf

DEFINE MSDIALOG oDlg TITLE STR0085 FROM 0,0 TO 15,70 OF oMainWnd //"Consulta Tipo de Movimentacao Bancaria"

   oMark:=MsSelect():New("TRB",,,TB_Campos,.T.,"XX", {20,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2} )
   oMark:baval:=bAction

   DEFINE SBUTTON FROM 02,190 TYPE 1 ACTION (EVAL(bAction)) ENABLE OF oDlg PIXEL
   DEFINE SBUTTON FROM 02,225 TYPE 2 ACTION (lRet:=.F.,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

TRB->(E_EraseArq(cArqTmp))

RETURN lRet

*------------------------------------------------------------------*
FUNCTION FI400GerPA()// Chamado do Menu
*------------------------------------------------------------------*
LOCAL cCamposErro:=''

If AvFlags("EIC_EAI") //AHAC 07/07/2014 - Integrado com Logix
   EasyHelp(STR0157) //"Funcionalidade não disponível para este cenário de negócio."
   RETURN .T.
EndIf

IF GetNewPar("MV_EASYFIN","N") = "N"
   MSGSTOP(STR0089,"MV_EASYFIN = N")//"Sistema nao esta integrado com o Financeiro."
   RETURN .T.
Else 								// CDS 12/01/05
   If Select("__SUBS")==0           // Essa rotina foi inclusa para não dar erro qdo ADS
      ChkFile("SE2",.F.,"__SUBS")
     Else
      DbSelectArea("__SUBS")
   EndIf
ENDIF

PRIVATE lTemWDCampos:=.T.
IF SWD->(FIELDPOS("WD_PREFIXO")) = 0 .OR.;
   SWD->(FIELDPOS("WD_PARCELA")) = 0 .OR.;
   SWD->(FIELDPOS("WD_TIPO"   )) = 0
   lTemWDCampos:=.F.
   MSGSTOP(STR0086) //"Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao existe."
ENDIF

IF lTemWDCampos
   IF(LEN(SWD->WD_PREFIXO) # LEN(SE2->E2_PREFIXO),cCamposErro+="WD_PREFIXO,E2_PREFIXO e ",)
   IF(LEN(SWD->WD_PARCELA) # LEN(SE2->E2_PARCELA),cCamposErro+="WD_PARCELA,E2_PARCELA e ",)
   IF(LEN(SWD->WD_TIPO)    # LEN(SE2->E2_TIPO)   ,cCamposErro+="WD_TIPO,E2_TIPO e ",)
ENDIF
IF(LEN(SWD->WD_CTRFIN1) # LEN(SE2->E2_NUM) ,cCamposErro+="WD_CTRFIN1,E2_NUM e ",)
IF(LEN(SWD->WD_FORN) # LEN(SE2->E2_FORNECE),cCamposErro+="WD_FORN,E2_FORNECE e ",)

IF !EMPTY(cCamposErro)
   cCamposErro:=LEFT(cCamposErro,LEN(cCamposErro)-3)
    MSGSTOP(STR0095 + Chr(13) + Chr(10) + ; //Campos necessarios para Integração com o Financeiro estão com tamanhos diferentes.
            STR0045 + cCamposErro + Chr(13) + Chr(10) + ;  //"Campo(s) "###" com tamanho diferente."
            STR0094) //"Favor contatar o Depto de Suporte."

   lTemWDCampos:=.F.
ENDIF

PRIVATE cFile:="", cCadastro := STR0087 //"Despachantes"
PRIVATE aRotina := MenuDef()
Private cControle := "" //RRV - 22/02/2013

mBrowse(,,,,"SA2",,,,,,,,,,,,,,filtroForn())

IF SELECT("TRB") # 0
   TRB->(E_ERASEARQ(cFile))
ENDIF

Return .T.

/**
 * EJA - 08/01/2019 - Filtro para exibir apenas fornecedores com pelo menos uma despesa do tipo 901
 */
Static Function filtroForn()

    
    Local cFilter := "R_E_C_N_O_ in ("
    Local cQuery  := ""


    cQuery += " SELECT DISTINCT A2.R_E_C_N_O_ "
    cQuery += " FROM "+ RetSqlName("SA2") +" A2 "
    cQuery += " INNER JOIN " + RetSqlName("SWD") + " SWD ON (A2_COD  = WD_FORN "
    cQuery += "                       AND A2_LOJA = WD_LOJA) "
    cQuery += " WHERE A2_FILIAL		= '" + xFilial("SA2") + "' "
    cQuery += "   AND WD_FILIAL		= '" + xFilial("SWD") + "' "
    cQuery += "   AND WD_DESPESA	= '901' "
    cQuery += "   AND SWD.D_E_L_E_T_= ' ' "
    cQuery += "   AND A2.D_E_L_E_T_	= ' ' "

    cQuery := ChangeQuery(cQuery)
    cFilter += cQuery + ")"

Return cFilter

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 27/01/07 - 10:54
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0047, "AxPesqui"       , 0 , 1},; //"Pesquisar"
                    { STR0048, "FI400VerDesp901", 0 , 4},; //"Gera PA"
                    { STR0049, "FI400VerDesp901", 0 , 4},; //"Cancela PA"
                    { STR0116, "AxVisual"       , 0 , 2}}  //STR0116 "Visualizar"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPA400MNU")
	aRotAdic := ExecBlock("IPA400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*------------------------------------------------------------------*
FUNCTION FI400VerDesp901(cAlias,nReg,nOpc)
*------------------------------------------------------------------*
LOCAL C,aSemSX3,oDlgPA,nOpcao:=0,nTipo:=2
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE lGeraPA   := (nOpc == 2)
PRIVATE lCancelPA := (nOpc == 3)
PRIVATE aBotoes:={}

lDespAtual := (nTipo == 2)

IF SELECT("TRB") = 0
   aHeader:={}
   aCampos:={}
   FOR C := 1 TO SWD->(FCOUNT())
       AADD(aCampos,SWD->(FIELD(C)))
   NEXT
   aSemSX3:={}
   AADD(aSemSX3,{"WKFLAG"    ,"C",02,0})
   AADD(aSemSX3,{"WKRECNO"   ,"N",10,0})
   //TRP - 30/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

   aSemSx3:= addWkCpoUser(aSemSx3,"SWD")

   cFile:=E_CRIATRAB(,aSemSX3)
   aCampos := Nil //THTS - 07/02/2018 - Apos a chamada do E_CriaTrab, limpa o aCampos para que nao seja utilizado de forma errada em outra chamada do E_CriaTrab
   IF !USED()
      Help(" ",1,"E_NAOHAREA")
      RETURN .F.
   ENDIF
   IndRegua("TRB",cFile+TEOrdBagExt(),"WD_FORN+WD_LOJA+WD_DOCTO")
   //TRP-18/09/08- Criação de índice a ser utilizado na busca de PAs para efetuar o Cancelamento de uma PA.
   cFile2:=E_Create(,.F.)
   IndRegua("TRB",cFile2+TEOrdBagExt(),"WD_HAWB")

   Set Index to (cFile+TEOrdBagExt()),(cFile2+TEOrdBagExt())
ENDIF

IF TRB->(FIELDPOS("WD_PREFIXO")) = 0 .OR.;
   TRB->(FIELDPOS("WD_PARCELA")) = 0 .OR.;
   TRB->(FIELDPOS("WD_TIPO"   )) = 0 .AND. lTemWDCampos
   lTemWDCampos:=.F.
   MSGSTOP(STR0088) //"Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao estao como 'USADO' no dicionario."
ENDIF

Processa({||  FI400LerSWD() }, STR0054) //"Lendo Despesas..."
SA2->(DBGOTO(nReg))

TRB->(DBGOTOP())
IF TRB->(BOF()) .AND. TRB->(EOF())
   MSGSTOP(STR0055) //"Nao foram encontradas despesas de adiantamento."
   RETURN .F.
ENDIF

TB_Campos:=ArrayBrowse("SWD","TRB",{"WD_BASEADI"})

IF lCancelPA
   FI400AADD(TB_Campos, {"WD_LOJA"   ,,AVSX3("WD_LOJA"   ,5)} )//11
   FI400AADD(TB_Campos, {"WD_FORN"   ,,AVSX3("WD_FORN"   ,5)} )//10
   FI400AADD(TB_Campos, {"WD_TIPO"   ,,AVSX3("WD_TIPO"   ,5)} )//9
   FI400AADD(TB_Campos, {"WD_PARCELA",,AVSX3("WD_PARCELA",5)} )//8
ENDIF
FI400AADD(TB_Campos, {"WD_CTRFIN1",,AVSX3("WD_CTRFIN1",5)} )//7
IF lCancelPA
   FI400AADD(TB_Campos, {"WD_PREFIXO",,AVSX3("WD_PREFIXO",5)} )//6
ENDIF
IF cPaisLoc == "ARG"
   FI400AADD(TB_Campos, {"WD_DOCTO"  ,,AVSX3("WD_DOCTO",5)} )//4
ENDIF
IF lGeraPA
   FI400AADD(TB_Campos, {"WD_LOJA"   ,,AVSX3("WD_LOJA" ,5)} )//3
   FI400AADD(TB_Campos, {"WD_FORN"   ,,AVSX3("WD_FORN" ,5)} )//2
ENDIF
FI400AADD(TB_Campos, {"WD_HAWB" ,,AVSX3("WD_HAWB" ,5)} ) // BHF - 04/08/08
FI400AADD(TB_Campos, {"WKFLAG"    ,,""} )//1

nOpcao:=0

IF lGeraPA
   AADD(aBotoes,{'EDIT'    ,{|| MSAguarde( {|| FI400IncPA(oMark)    } )},STR0048}) //"Gera PA"
   AADD(aBotoes,{"RESPONSA",{|| Processa ( {|| FI400Marca(oMark,.T.)} )},STR0052}) //STR0052 "Todos"
ELSE
   AADD(aBotoes,{'EXCLUIR',{|| MSAguarde( {|| FI400ExcPA(oMark) } )},STR0049}) //"Cancela PA"
   AADD(aBotoes,{'PESQUISA',{|| MSAguarde( {|| FI400PesqPA() } )},STR0047})
ENDIF
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400GERAPA"),) //CCH - 13/04/09 - Ponto de Entrada para adição de novos botões em aBotoes
PRIVATE nValorS:=0
PRIVATE lLerWD_VALOR_M:=TRB->(FIELDPOS("WD_VALOR_M")) # 0 .AND. cPaisLoc == "ARG"
PRIVATE lLerWD_MOEDA  :=TRB->(FIELDPOS("WD_MOEDA"  )) # 0 .AND. cPaisLoc == "ARG"
PRIVATE cNumEICTit :=""
PRIVATE cPrefEICTit:=""
PRIVATE cParcEICTit:=""
PRIVATE cTipoEICTit:=""
PRIVATE cFornEICTit:=""
PRIVATE cLojaEICTit:=""

SA2->(DBGOTO(nReg))
oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlgPA TITLE STR0056+IF(lDespAtual,STR0057+SA2->A2_COD+"-"+ALLTRIM(SA2->A2_NOME),'') ; //"Despesa de Adiantamento"###" - Despachante: "
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

   TRB->(DBGOTOP())

   //by GFP - 13/10/2010 - 14:40
   TB_Campos := AddCpoUser(TB_Campos,"SWD","2")

   oMark:=MsSelect():New("TRB","WKFLAG",,TB_Campos,lInverte,cMarca,{18,1,(oDlgPA:nClientHeight-4)/2,(oDlgPA:nClientWidth-4)/2})
   oMark:baval:={||  FI400Marca(oMark,.F.) }
   oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgPA ON INIT EnchoiceBar(oDlgPA,If(lGeraPA,{|| MSAGUARDE( {|| FI400INCPA(OMARK) , ODLGPA:END()   } )},{|| MSAguarde( {|| FI400ExcPA(oMark), oDlgPA:End() } )}),;
                                             {||nOpcao:=0,oDlgPA:End()},,aBotoes)

SA2->(DBGOTO(nReg))

Return .T.
*-------------------------------------------------------------------*
FUNCTION FI400AADD(TB_Campos,aCampo)
*-------------------------------------------------------------------*
ASIZE(TB_Campos,LEN(TB_Campos)+1)
AINS(TB_Campos,1)
TB_Campos[1]:=aCampo
Return .t.
*-------------------------------------------------------------------*
FUNCTION FI400ExcPA(oMark)
*-------------------------------------------------------------------*
LOCAL aRotOld:=ACLONE(aRotina),lMarcados:=.F.,aOrd:=SaveOrd({"SE2","SE5"})
LOCAL nRecno:=TRB->(RECNO()),lGravou:=.F., aHawbs:={}, I, nInd, nWk
LOCAL lGeraPO  := IF(GetNewPar("MV_EASYFPO","S")="S",.T.,.F.)
LOCAL lGerPrDI := IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)
Local lBxConc     := EasyGParam("MV_BXCONC",.T.,.F.) == "1"  //GFP - 27/08/2014
Local cChaveSWD := "" //MCF - 15/07/2016
Local aTit := {}
Private lMSErroAuto := .f.
cControle  := "ExcluiPA" //RRV - 22/02/2013

IF !lTemWDCampos
   MSGSTOP(STR0058) //"Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao esta correto."
   RETURN .F.
ENDIF

MsProcTxt(STR0059) //"Iniciando Cancelamento..."

TRB->(DBGOTOP())
DO WHILE !TRB->(EOF())
   IF !EMPTY(TRB->WKFLAG)
      lMarcados:=.T.
      EXIT
   ENDIF
   TRB->(DBSKIP())
ENDDO

IF !lMarcados
   TRB->(DBGOTOP())
//   MSGSTOP(STR0060) //"Nao existe registros marcados."
   oMark:oBrowse:ReFresh()
   RETURN .F.
ENDIF

SWD->(DBGOTO(TRB->WKRECNO))  //tabela se2 conta swd
cChaveSWD :=SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA //MCF - 18/07/2016
//MFR 10/09/2021 ossme-6178 subsitituído o fina050 pelo execauto         
      AADD(aTit,{"E2_PREFIXO",SWD->WD_PREFIXO,NIL})
      AADD(aTit,{"E2_NUM"    ,SWD->WD_CTRFIN1,NIL})      
      AADD(aTit,{"E2_PARCELA",SWD->WD_PARCELA,NIL})    
      AADD(aTit,{"E2_TIPO"   ,SWD->WD_TIPO,NIL})    
      AADD(aTit,{"E2_FORNECE",SWD->WD_FORN,NIL})    
      AADD(aTit,{"E2_LOJA"   ,SWD->WD_LOJA,NIL})    
cCodFor :=TRB->WD_FORN
cLojaFor:=TRB->WD_LOJA

DBSELECTAREA("SE2")

SE2->(DBSETORDER(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
IF SE2->(DBSEEK(xFilial()+cChaveSWD)) //MCF - 18/07/2016
   //GFP - 27/08/2014 - Tratamento para não permitir alteração no câmbio quando o parâmetro MV_BXCONC = 2 e a parcela já foi conciliada no financeiro.
   SE5->(DbSetOrder(2))
   If SE5->(dbSeek(xFilial("SE5")+"PA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA))
      If !lBxConc .And. !Empty(SE5->E5_RECONC)
         MsgInfo(STR0150,STR0128) //STR0150 "Pagamento Antecipado não pode ser alterado pois foi conciliado/reconciliado no financeiro - Verifique o parâmetro MV_BXCONC" //STR0128  "Aviso"
         Return .F.
      Endif
   EndIf
    //MFR 10/09/2021 ossme-6178 subsitituído o fina050 pelo execauto   
//   bExecuta:={||nPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Delet")}) ,;
//                lGravou:=FA050Delet("SE2",SE2->(RECNO()),IF(nPosRot=0,5,nPosRot)), If(ValType(lGravou) <> "L", lGravou := .F., ) }
                 
//   SE2->(Fina050(,,,bExecuta))
   
   MSExecAuto({|a,b,c| FINA050(a,b,c)}, aTit, nil,5)
   lGravou :=  !lMsErroAuto
   if !lGravou
      mostraErro() 
   EndIf
ELSE
   lGravou:=MSGNOYES(STR0061+; //"Lancamento no Finaceiro nao encontrado,"
                    STR0062,STR0063+cChaveSWD) //" Deseja Liberar Despesa p/ nova geracao."###"Chave: "
ENDIF

IF lGravou

   MsProcTxt(STR0064) //"Atualizando Despesa..."
   TRB->(DBSETORDER(1))
   TRB->(DBSEEK(cCodFor+cLojaFor))

   DO WHILE !TRB->(EOF()) .AND.;
      TRB->(WD_FORN+WD_LOJA) == cCodFor+cLojaFor
      MsProcTxt(STR0064) //"Atualizando Despesa..."
      IF !EMPTY(TRB->WKFLAG)
         if ascan(aHawbs,TRB->WD_HAWB)==0  // Jonato Ocorrência 0110/03
            AADD(aHawbs,TRB->WD_HAWB)
         endif
         SWD->(DBGOTO(TRB->WKRECNO))
         IF cChaveSWD == SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA //MCF - 18/07/2016
            TRB->WKFLAG    :=""
            TRB->WD_CTRFIN1:=""
            SWD->(DBGOTO(TRB->WKRECNO))
            SWD->(RECLOCK("SWD",.F.))
            SWD->WD_CTRFIN1:=""
            SWD->WD_DTENVF :=CTOD('')
            IF lTemWDCampos
               TRB->WD_PREFIXO:=""
               TRB->WD_PARCELA:=""
               TRB->WD_TIPO   :=""
               SWD->WD_PREFIXO:=""
               SWD->WD_PARCELA:=""
               SWD->WD_TIPO   :=""
               SWD->WD_GERFIN :="2"  //ASK 16/10/2007 - Volta o campo como "2" Gera Fin. = Não , conforme o padrão
            ENDIF
            SWD->(MSUNLOCK())
         ENDIF
      ENDIF
      TRB->(DBSKIP())

   ENDDO

   IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0110/03
      axFl2DelWork:={}
      for nInd :=1 to len(aHawbs)
          SW6->(DBSETORDER(1))
          IF SW6->(DBSEEK(xfilial("SW6")+aHawbs[nind]))
             aPos:={}
             FI400SW7(SW6->W6_HAWB)
	          IF lGeraPO
	              FOR I := 1 TO LEN(aPos)
	                  SW2->(DBSETORDER(1))
	                  SW2->(DBSEEK(XFILIAL("SW2")+aPos[I]))
	                  Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
	                  Processa({|| AVPOS_PO(aPos[I],"DI") })  // S.A.M. 26/03/2001
	              NEXT
             Endif
	             DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)  //ASR - 28/09/2005 - CANCELANDO PA DO DESPACHANTE
             Processa({|| AVPOS_DI(SW6->W6_HAWB, lGerPrDI) })
          ENDIF
      next
      // ***** DELETAR ARQUIVO DA FUNCAO AV POS_DI() - AWR - 27/05/2004
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
                FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
            NEXT
         ENDIF
      ENDIF
      // *****
   ENDIF

ENDIF

// GFP - 06/10/2012
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,'EXC_PA'),)

aRotina:=ACLONE(aRotOld)

TRB->(DBGOTO(nRecno))

oMark:oBrowse:ReFresh()
RestOrd(aOrd,.T.)  //GFP - 27/08/2014

RETURN .T.
*-------------------------------------------------------------------*
FUNCTION FI400IncPA(oMark)
// Inseri as funcoes que tratam a geração de PA
*-------------------------------------------------------------------*
LOCAL aRotOld:=ACLONE(aRotina),lMarcados:=.F.
LOCAL nRecno:=TRB->(RECNO()),I,nind,nWk
LOCAL lOkSE2:=.f., lContabilizou, aHawbs:={} // Jonato Ocorrência 0110/03
LOCAL lGeraPO := IF(GetNewPar("MV_EASYFPO","S")="S",.T.,.F.)
LOCAL lGerPrDI := IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)
Local aOrdTRB :=SaveOrd({"TRB"})
PRIVATE cIniNatur:=SPACE(LEN(SE2->E2_NATUREZ)),cIniSerie:=""
cControle  := "GeraPA" //RRV - 22/02/2013
Inclui := .T. //RNLP - 10/01/2020 DTRADE-3698

IF !lTemWDCampos
   MSGSTOP(STR0058) //"Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao esta correto."
   RETURN .F.
ENDIF

MsProcTxt(STR0065) //"Iniciando Valores..."

cHistorico := "" //RNLP 27/11/20 - OSSME-5370 - Inicializa a variável
TRB->(DBGOTOP())
DO WHILE !TRB->(EOF())
    IF EMPTY(TRB->WKFLAG)
       TRB->(DBSKIP())
       LOOP
    ENDIF

    aOrdTRB :=SaveOrd({"TRB"})
    lMarcados:=.T.

    SWD->(DBGOTO(TRB->WKRECNO))

    IF EasyGParam("MV_EASYFIN",,"N") == "S" .AND. EMPTY(TRB->WD_FORN) //MCF - 16/09/2015
    MSGSTOP(STR0158) // "O campo Fornecedor não foi preenchido no cadastro do Despachante."
    RETURN .F.
    ENDIF

    cCodFor  :=TRB->WD_FORN
    cLojaFor :=TRB->WD_LOJA  
    cIniDocto:= NumTit("SWD","WD_CTRFIN1")    
    IF TRB->(FieldPos("WD_NATUREZ")) # 0
    cIniNatur:=TRB->WD_NATUREZ
    EndIf
    If TRB->(FieldPos("WD_SE_DOC")) > 0
    cIniSerie:=TRB->WD_SE_DOC
    EndIf

    nMoedSubs:= 1
    IF cPaisLoc == "ARG"
    IF lLerWD_MOEDA .AND. !EMPTY(TRB->WD_MOEDA)
        nMoedSubs:= SimbToMoeda(TRB->WD_MOEDA)
        nMoedSubs:= IF(nMoedSubs=0,1,nMoedSubs)
    ENDIF
    ENDIF

    nValorS:=0

   TRB->(DBSEEK(cCodFor+cLojaFor))
   cHistorico := "Proc.: "
   DO WHILE !TRB->(EOF()) .AND.;
      TRB->(WD_FORN+WD_LOJA) == cCodFor+cLojaFor

      IF !EMPTY(TRB->WKFLAG)
         IF lLerWD_VALOR_M .AND. !EMPTY(TRB->WD_VALOR_M)
            nValorS+=TRB->WD_VALOR_M
         Else
            nValorS+=TRB->WD_VALOR_R
         Endif
         cHistorico += ALLTRIM(TRB->WD_HAWB) + " | "  //RNLP 27/11/20 - OSSME-5370
      ENDIF
      TRB->(DBSKIP())
   ENDDO
   cHistorico := Avkey(cHistorico,"E2_HIST")

    //ISS - 06/01/11 - Ponto de entrada para alterar os valores iniciais da tela para inclusão de títulos no contas a pagar
    IF EasyEntryPoint("EICFI400")
    Execblock("EICFI400",.F.,.F.,"FI400INCPA_ALTCPO")
    EndIf

    cValidaOK:=" .AND. FI400IniValPA('V') "

    bIniciaVal:={|| FI400IniValPA('I') }
    lGravou:=.F.

    MsProcTxt(STR0066) //"Iniciando Inclusao..."

    DBSELECTAREA("SE2")
    bExecuta:={||nPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Inclu")}) ,;
                lGravou:=FA050Inclu("SE2",SE2->(RECNO()),IF(nPosRot=0,3,nPosRot) ), If(ValType(lGravou) <> "N", lGravou := .F., lGravou := (lGravou == 1)) }
    
    Fina050(,,,bExecuta)
  
    IF lGravou
    MsProcTxt(STR0067) //"Gravando Titulo..."
    TRB->(DBSEEK(cCodFor+cLojaFor))
    cChave:=""
    lContabilizou:=.f.
    DO WHILE !TRB->(EOF()) .AND.;
        TRB->(WD_FORN+WD_LOJA) == cCodFor+cLojaFor

        MsProcTxt(STR0067) //"Gravando Titulo..."
        IF !EMPTY(TRB->WKFLAG)
            if ascan(aHawbs,TRB->WD_HAWB)==0  // Jonato Ocorrência 0110/03
                AADD(aHawbs,TRB->WD_HAWB)
            endif
            TRB->WKFLAG    :=""
            TRB->WD_CTRFIN1:=cNumEICTit
            SWD->(DBGOTO(TRB->WKRECNO))
            SWD->(RECLOCK("SWD",.F.))
            SWD->WD_CTRFIN1:=cNumEICTit
            IF lTemWDCampos
                SWD->WD_PREFIXO:=cPrefEICTit
                SWD->WD_PARCELA:=cParcEICTit
                SWD->WD_TIPO   :=cTipoEICTit
            ENDIF
            SWD->WD_FORN   :=cFornEICTit
            SWD->WD_LOJA   :=cLojaEICTit
            SWD->WD_DTENVF :=dDataBase
            SWD->WD_GERFIN :="1"
            SWD->(MSUNLOCK())
            cChave:=SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
            IF !lOkSE2
                SE2->(DBSETORDER(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                IF SE2->(DBSEEK(xFilial()+cChave))
                SE2->(RECLOCK("SE2",.F.))
                SE2->E2_ORIGEM:="SIGAEIC"
                SE2->(MSUNLOCK())
                lContabilizou:= IF(EMPTY(SE2->E2_LA),.f.,.t.)
                lOkSE2:=.t.
                ENDIF
            ENDIF
            IF lContabilizou
                SWD->(RECLOCK("SWD",.F.))
                SWD->WD_DTLANC:=dDataBase
                SWD->(MSUNLOCK())
            ENDIF
            // Jonato Ocorrência 0110/03 --> fim
        ENDIF
        TRB->(DBSKIP())

    ENDDO

    IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0110/03
        axFl2DelWork:={}
        for nInd :=1 to len(aHawbs)
            SW6->(DBSETORDER(1))
            IF SW6->(DBSEEK(xfilial("SW6")+aHawbs[nind]))
                aPos:={}
                FI400SW7(SW6->W6_HAWB)
                IF lGeraPO
                    FOR I := 1 TO LEN(aPos)
                        nOrderSW2:=SW2->(INDEXORD())
                        SW2->(DBSETORDER(1))
                        SW2->(DBSEEK(XFILIAL("SW2")+aPos[I]))
                        Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
                        Processa({|| AVPOS_PO(aPos[I],"DI") })  // S.A.M. 26/03/2001
                        SW2->(DBSETORDER(nOrderSW2))
                    NEXT
                Endif
                DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
                Processa({|| AVPOS_DI(SW6->W6_HAWB, lGerPrDI) })	//ASR - 28/09/2005 - GERANDO O PA DO DESPACHANTE
            ENDIF
        next
        // ***** DELETAR ARQUIVO DA FUNCAO AV POS_DI() - AWR - 27/05/2004
        If Select("WorkTP") # 0
            IF LEN(axFl2DelWork) > 0
                WorkTP->(E_EraseArq(axFl2DelWork[1]))
                FOR nWk:=2 TO LEN(axFl2DelWork)
                    FERASE(axFl2DelWork[nWk]+TEOrdBagExt())
                NEXT
            ENDIF
        ENDIF
        //*******************

    ENDIF
    // Jonato ocorrência 0110/03 --> fim
    ENDIF

    IF !empty(aOrdTRB)
       RestOrd(aOrdTRB,.T.)
    EndIF 

    TRB->(DBSKIP())
ENDDO

IF !lMarcados
    TRB->(DBGOTOP())
    //   MSGSTOP(STR0060) //"Nao existe registros marcados."
    oMark:oBrowse:ReFresh()
    RETURN .F.
ENDIF

aRotina:=ACLONE(aRotOld)

TRB->(DBGOTO(nRecno))

oMark:oBrowse:ReFresh()

Return .T.
*-------------------------------------------------------------------*
FUNCTION FI400IniValPA(cExe)
*-------------------------------------------------------------------*
LOCAL c_DuplDoc
Private cTipoAdnt := ""

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ANTES_VAL_TIPO_PA"),)

IF cExe = 'V'

   IF !(ALLTRIM(M->E2_TIPO) $ AvKey("PA","WD_TIPO")+IF(!Empty(cTipoAdnt) .And. FI400ValTpO(cTipoAdnt),"/"+AvKey(cTipoAdnt,"WD_TIPO"),""))
      MSGSTOP(STR0068+"PA"+IF(!Empty(cTipoAdnt),"/"+cTipoAdnt,""),STR0069) //"Tipo deve ser igual a "###"Verificao Importacao"
      Return .F.
   ENDIF

   IF cCodFor # M->E2_FORNECE .OR. cLojaFor # M->E2_LOJA
      MSGSTOP(STR0070+cCodFor+"-"+cLojaFor,STR0069) //"Fornecedor nao pode ser diferente de: "###"Verificao Importacao"
      Return .F.
   ENDIF

   IF M->E2_VALOR != nValorS .Or. M->E2_VLCRUZ != nValorS .Or. M->E2_SALDO != nValorS .Or. M->E2_MOEDA != nMoedSubs
      MSGSTOP(STR0169, STR0069)
      Return .F.
   EndIf
   
   If M->E2_PREFIXO <> 'EIC'
       MSGSTOP(STR0171, STR0069) //"Não é permitido alterar o prefixo do Título"
      Return .F.
   EndIf

   cPrefEICTit:=M->E2_PREFIXO
   cParcEICTit:=M->E2_PARCELA
   cTipoEICTit:=M->E2_TIPO
   cNumEICTit :=M->E2_NUM
   cFornEICTit:=M->E2_FORNECE
   cLojaEICTit:=M->E2_LOJA

ELSEIF cExe = 'I'

   If !Empty(cIniNatur)
      M->E2_NATUREZ:=cIniNatur
   EndIf

   M->E2_FORNECE := AvKey(cCodFor,"E2_FORNECE")
   M->E2_LOJA 	:=  AvKey(cLojaFor,"E2_LOJA")
   If SA2->(DbSeek(xFilial("SA2")+AvKey(cCodFor,"E2_FORNECE")+AvKey(cLojaFor,"E2_LOJA")))
      M->E2_NATUREZ := SA2->A2_NATUREZ
   EndIf

   c_DuplDoc := GetNewPar("MV_DUPLDOC"," ")
   IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(cIniDocto)
      M->E2_NUM:=cIniDocto
   ENDIF

   M->E2_PREFIXO := "EIC"
   M->E2_TIPO    := AvKey("  ","E2_TIPO")
   M->E2_HIST    := cHistorico   // BHF - 04/08/08
   If cPaisLoc == "ARG"
      M->E2_PREFIXO := &(EasyGParam("MV_2DUPREF"))
      If !Empty(cIniSerie)
         M->E2_PREFIXO:=cIniSerie
      EndIf
   EndIf

   // GCC - 09/08/2013 - Passar a data base do sistema como default na geração de pagamento antecipado
   M->E2_VENCTO   := dDataBase
   M->E2_VENCREA  := DataValida(M->E2_VENCTO,.T.)
      
   If type("nValDig") == "N" .And. INCLUI //RNLP - 10/01/2020 DTRADE-3698   
      nValDig := M->E2_VALOR
   Endif   

EndIf

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400INIVALPA"),) // LDR
Return .T.

*-------------------------------------------------------------------*
FUNCTION FI400Marca(oMark,lTodos)   // Jonato Ocorrência 0110/03
*------------------------------------------------------------------*
LOCAL cMarcaNew:=IF(EMPTY(TRB->WKFLAG),cMarca,"")
LOCAL cForn :=TRB->WD_FORN
LOCAL cLoja :=TRB->WD_LOJA
LOCAL cDocto:=TRB->WD_DOCTO
LOCAL cMoeda:="   "
LOCAL nRecno:=TRB->(RECNO())
LOCAL cChave:=""

IF !lTodos
   IF !EMPTY(TRB->WD_CTRFIN1) .AND. lGeraPA
      MSGSTOP(STR0071+MVPagAnt,STR0069) //"Despesa ja possui "###"Verificao Importacao"
      Return .F.
   ENDIF

   IF EMPTY(TRB->WD_CTRFIN1) .AND. lCancelPA
      MSGSTOP(STR0072+MVPagAnt,STR0069) //"Despesa nao possui "###"Verificao Importacao"
      Return .F.
   ENDIF
ENDIF

IF lDespAtual .AND. cPaisLoc # "ARG" .AND. !lTodos .AND. !lCancelPA
   TRB->WKFLAG:=cMarcaNew
   oMark:oBrowse:ReFresh()
   Return .T.
ENDIF

IF lTemWDCampos
   SWD->(DBGOTO(TRB->WKRECNO))
   cChave:=SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
ENDIF

If cPaisLoc == "ARG"
   If lLerWD_MOEDA .AND. !EMPTY(TRB->WD_MOEDA)
      cMoeda:=TRB->WD_MOEDA
   Endif
Endif

TRB->(DBGOTOP())

DO WHILE !TRB->(EOF())

   TRB->WKFLAG:=""

   IF lTodos
      IF !EMPTY(TRB->WD_CTRFIN1) .AND. lGeraPA
         TRB->(DBSKIP())
         LOOP
      ENDIF
      IF EMPTY(TRB->WD_CTRFIN1) .AND. lCancelPA
         TRB->(DBSKIP())
         LOOP
      ENDIF
      TRB->WKFLAG:=cMarcaNew
      TRB->(DBSKIP())
      LOOP
   ENDIF

   IF (lTemWDCampos .AND. lCancelPA)//Cancelamento

      SWD->(DBGOTO(TRB->WKRECNO))
      IF cChave == SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
         TRB->WKFLAG:=cMarcaNew
      ENDIF

   ELSE

      IF TRB->(WD_FORN+WD_LOJA)        == cForn+cLoja    .AND.;
         (cPaisLoc # "ARG" .OR. cDocto == TRB->WD_DOCTO) .AND.;
         (!lLerWD_MOEDA    .OR. cMoeda == TRB->WD_MOEDA)
         TRB->WKFLAG:=cMarcaNew
      ENDIF

   ENDIF

   TRB->(DBSKIP())

ENDDO

TRB->(DBGOTO(nRecno))

oMark:oBrowse:ReFresh()

Return .T.

// GFP - 14/10/2015 - Alterado a função FI400LerSWD() para busca de adiantamentos via Query, melhorando performance.
*------------------------------------------------------------------*
FUNCTION FI400LerSWD()
*------------------------------------------------------------------*
LOCAL cQuery := ""
Local lMultiFil  := VerSenha(115) .and. FWModeAccess("SWD") == "E"
Local aFilSel,cFilSel := ""
Private cTipoAd := ""
If Type("cTipoAdnt") == "U"
   cTipoAdnt:= ""
EndIf

IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ANTES_LER_SWD_PA"),)

ProcRegua(10)

DBSELECTAREA("TRB")
AvZap()

If Select("WKSWDPA") > 0
   WKSWDPA->(dbClosearea())
EndIf

If lMultiFil
   aFilSel:=AvgSelectFil(.T.,"SWD")
   If Len(aFilSel) > 1 .Or. aFilSel[1] <> "WND_CLOSE" // Clicou em Cancelar na tela de seleção de filiais
      aEval( aFilSel , {|x| cFilSel += " '"+x+"' "+If( aScan(aFilSel,x) < Len(aFilSel) ,",","") } , 1 , Len(aFilSel) )
   Else
      cFilSel := " '"+xFilial("SWD")+"' "
   EndIf
Else
   cFilSel := " '"+xFilial("SWD")+"' "
EndIf

cQuery += " SELECT SWD.*,SWD.R_E_C_N_O_ AS NUNREC FROM " + RetSqlName("SWD") + " SWD "
cQuery += " INNER JOIN " + RetSqlName("SW6") + " SW6 ON SW6.W6_FILIAL = '" + xFilial("SW6") + "' AND SW6.W6_HAWB = SWD.WD_HAWB "
cQuery += " WHERE SWD.WD_DESPESA = '901'"/* AND SW6.W6_TIPOFEC <> 'DIN' "*/ // LRS - 22/01/2015 - Permite a geração de PA para despesas gerado no desembaraço Nacional

cQuery += " AND SWD.WD_FILIAL IN ("+cFilSel+")"

IF SWD->(FieldPos("WD_DA_ORI")) > 0 //LRS - 04/01/2017 - Para não trazer as despesas copiadas do processo original para nacionalização
   cQuery += " AND SWD.WD_DA_ORI <> '1'"
ENDIF 

If lGeraPA
   cQuery += " AND SWD.WD_CTRFIN1 = '' "
Else
   cQuery += " AND SWD.WD_CTRFIN1 <> '' "
EndIf

If lCancelPA
   cQuery += " AND (SWD.WD_TIPO LIKE '%PA%' "
   If !Empty(cTipoAd) .And. FI400ValTpO(cTipoAd)
      cQuery += " OR SWD.WD_TIPO LIKE '" + AvKey(cTipoAdnt,"WD_TIPO") + "' )"
   Else
      cQuery += ") "
   EndIf
EndIf
//LRS - 01/12/2015 - Correção do cQuery para Bancos DB2
If lDespAtual
   cQuery += " AND SWD.WD_FORN = '" + SA2->A2_COD + "'"
   cQuery += " AND SWD.WD_LOJA = '" + SA2->A2_LOJA + "'"
EndIf

If TcSrvType() <> "AS/400" //.AND. TcSrvType() <> "iSeries"
    cQuery += " AND SWD.D_E_L_E_T_ <> '*' AND SW6.D_E_L_E_T_ <> '*'"
Else
    cQuery += "SWD.@DELETED@ <> '*' AND SW6.@DELETED@ <> '*'"
EndIf

cQuery:= ChangeQuery(cQuery)
TcQuery cQuery ALIAS "WKSWDPA" NEW
TCSetField( "WKSWDPA", "WD_INTEGRA", AVSX3("WD_INTEGRA",2), AVSX3("WD_INTEGRA",3), AVSX3("WD_INTEGRA",4))
TCSetField( "WKSWDPA", "WD_NUMERA" , AVSX3("WD_NUMERA",2), AVSX3("WD_NUMERA",3), AVSX3("WD_NUMERA",4))

WKSWDPA->(DbGoTop())
Do While WKSWDPA->(!Eof())
   TRB->(DBAPPEND())
   AVREPLACE("WKSWDPA","TRB")
   TRB->WKRECNO    := WKSWDPA->NUNREC //LRS - 16/08/2018
   TRB->TRB_ALI_WT := "SWD"
   TRB->TRB_REC_WT := WKSWDPA->NUNREC //LRS - 16/08/2018
   WKSWDPA->(DbSkip())
EndDo

If Select("WKSWDPA") > 0
   WKSWDPA->(dbClosearea())
EndIf

Return .T.

*-------------------------------------------*
FUNCTION FI400PROC_EZZ()  // EOS - 06/10/03
*-------------------------------------------*
LOCAL cFilEZZ:=xFilial("EZZ"),Wind
LOCAL cFilSA2:=xFilial("SA2")
Private cUltParc := ""  // GFP - 20/01/2014
aTabInv:={}

SA2->(DBSETORDER(1))
EZZ->(DBSETORDER(1))
ProcRegua(10)

EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB))
nCont:=0
DO WHILE !EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ ;
                       .AND. EZZ->EZZ_HAWB   == SW6->W6_HAWB
   IF nCont=10
      ProcRegua(10);nCont:=0
   ELSE
      IncProc();nCont++
   ENDIF

   cNum := RIGHT(ALLTRIM(EZZ->EZZ_INVOIC),LEN(SE2->E2_NUM))

   nValor_Inv := EZZ->EZZ_INLAND+EZZ->EZZ_PACKIN+EZZ->EZZ_OUTDES+;
                 EZZ->EZZ_FRETEI-EZZ->EZZ_DESCON

   EicCalcPagto(EZZ->EZZ_INVOIC,nValor_Inv,dDtEMB,dDtaVista,EZZ->EZZ_CONDPA+STR(EZZ->EZZ_DIASPA,3),aTabInv,cNum,"")

   IF LEN(aTabInv) > 0 .AND. ASCAN(aTabInv,{|aInv|aInv[5]==cNum}) # 0
      EZZ->(RECLOCK("EZZ",.F.))
      EZZ->EZZ_NUM := cNum
      EZZ->(MSUNLOCK())
   ENDIF

   EZZ->(DBSKIP())
ENDDO

TInvoice:= cNum:=""
Wind := 1
nParc:= 1

IF LEN( aTabInv ) > 0
   ProcRegua(LEN( aTabInv )+1)
ENDIF

IF AVDTFINVAL() //LRS - 17/04/2018 - Validacao MV_DATAFIN
	FOR Wind := 1 TO LEN( aTabInv )
		IncProc()
		IF TInvoice # aTabInv[Wind,1] .OR. cNum # aTabInv[Wind,5]
		   nParc:= 1
		ELSE
		   nParc++
		ENDIF
		TInvoice := aTabInv[Wind,1]//Chave
		cNum     := aTabInv[Wind,5]//Numero da duplicata
		TFobMoe  := aTabInv[Wind,2]//Valor

		EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB+TInvoice))
		SA2->(DBSEEK(cFilSA2+EZZ->EZZ_FORN+EICRetLoja("EZZ","EZZ_FORLOJ")))
		cForn:=EZZ->EZZ_FORN
		cLoja:=SA2->A2_LOJA

		dData_Emis:= dDataBase
		dData_Emis:=If (dData_Emis > aTabInv[Wind,3],aTabInv[Wind,3],dData_Emis) //TRP-07/12/2007-Verifica se a data de emissão é maior que a data de vencimento.Caso seja, utilizar a data de vencimento para a data de emissão.
		nErroDup:=GeraDupEic(aTabInv[Wind,5],;  //Numero das duplicatas
							 TFobMoe,;          //Valor da duplicata
							 dData_Emis,;        //data de emissao
							 aTabInv[Wind,3],;  //Data de vencimento
							 EZZ->EZZ_MOEDA,;   //Simbolo da moeda
							 "EIC",;            //Prefixo do titulo
							 "INV",;            //Tipo do titulo
							 nParc,;            //Numero de parcela.
							 cFORN,;            //Fornecedor
							 cLOJA,;            //Loja
							 "SIGAEIC",;        //Origem da geracao da duplicata (Nome da rotina)
							 "P: "+ALLTRIM(SW6->W6_HAWB)+"I S/P:"+ALLTRIM(TInvoice),;//Historico da geracao
							 EZZ->EZZ_TX_FOB,,SW6->W6_HAWB)
							 // RAD 06/04/03  ARG 0)                 //Taxa da moeda (caso usada uma taxa diferente a
														 //cadastrada no SM2.

	NEXT
EndIF
RETURN NIL

*-----------------------------------------------------------------------*
FUNCTION FI400TitFin(cLOrigem,cLOperacao,lAutoFina,nParc,cParcParam,cIniParam) // JBS - 23/04/2004
*-----------------------------------------------------------------------*
Local lTemWDCampos  := .T., lTemW6Campos := .T. // JBS - 30/04/2004
Local cCamposErro   := ''
Local aOrdSX1       := {}
Local lLocSE5       := .F.	    //LGS - 22/12/2014
Local aOrdSE5       := {}       //LRS
Local nTxMoeE2      := 1        //THTS - 10/05/2017
Local lAchouSE2     := .F.
Local aOrdSE2       := {}
Local aAutoFina     := {}
Local nAutoOper     := 0

Private cParcela    := cParcParam  // GFP - 07/03/2014
PRIVATE cOperacao   := cLOperacao
PRIVATE cOrigem     := cLOrigem
PRIVATE nAtomatico  := 2
PRIVATE cNatureza   := ""
Private aOrdSE2_Aux := {}		//NCF - 16/02/2011
Private lGravaTit	  := .T.		//TRP - 02/08/2011 - Variável para ser utilizada em rdamke. Desviar inclusão de título no módulo Financeiro.
Private n050ValBru  := 0		//TRP - 10/01/2012 - Variável calculada no fonte F INA050.PRX para retornar o valor bruto do título
Private aFIN050     := {}       //LGS - 24/04/2015
Private cOriRdm     := ""
Private cTipoRdm    := ""
Private lAutRdm     := .T.
Private cSeqtit     :="" //THTS - Utilizada para armazenar o numero do tit a ser gerado no financeiro na rotina de Despesas. Evita o lock na transação, o que gerava erro ao incluir duas despesas ao mesmo tempo, mesmo em processos diferentes
Private lAutomatico
DEFAULT lAutoFina := .F.
Default nParc       := 1
Default cIniParam   := ""
lAutomatico := lAutoFina //THTS - 23/11/2021 - Alterada a lAutomatico para private, pois ela e utilizada na execucao do bloco de codigo dentro do FINA

   IF "SWD" $ cOrigem

      //TDF - 26/07/11 - Verifica se a natureza foi preenchida pelo parâmetro do F11
      aOrdSX1:= SaveOrd({"SX1"})
      IF SX1->(DbSeek(IncSpace("EICFI5", Len(X1_GRUPO),.F.)+"02"))
         If EMPTY(SX1->X1_CNT01)
            cIniNatur:=SPACE(LEN(SE2->E2_NATUREZ))
         Else
            cIniNatur:= SX1->X1_CNT01
         EndIf
      ELSE
         cIniNatur:=SPACE(LEN(SE2->E2_NATUREZ))
      ENDIF
      RestOrd(aOrdSX1,.T.)

      cIniSerie:=""

      IF SWD->(FIELDPOS("WD_PREFIXO")) = 0 .OR.;
         SWD->(FIELDPOS("WD_PARCELA")) = 0 .OR.;
         SWD->(FIELDPOS("WD_TIPO"   )) = 0
            lTemWDCampos:=.F.
            MSGSTOP(STR0086) //"Campo WD_PREFIXO ou WD_PARCELA ou WD_TIPO nao existe."
            Return(.f.)
      ENDIF

      IF lTemWDCampos
         IF(LEN(SWD->WD_PREFIXO) # LEN(SE2->E2_PREFIXO),cCamposErro+="WD_PREFIXO,E2_PREFIXO e ",)
         IF(LEN(SWD->WD_PARCELA) # LEN(SE2->E2_PARCELA),cCamposErro+="WD_PARCELA,E2_PARCELA e ",)
         IF(LEN(SWD->WD_TIPO)    # LEN(SE2->E2_TIPO)   ,cCamposErro+="WD_TIPO,E2_TIPO e ",)
      ENDIF

      IF(LEN(SWD->WD_CTRFIN1) # LEN(SE2->E2_NUM)    ,cCamposErro+="WD_CTRFIN1,E2_NUM e " ,)
      IF(LEN(SWD->WD_FORN)    # LEN(SE2->E2_FORNECE),cCamposErro+="WD_FORN,E2_FORNECE e ",)

      IF !EMPTY(cCamposErro)
         cCamposErro:=LEFT(cCamposErro,LEN(cCamposErro)-3)
         //MSGSTOP(STR0045+cCamposErro+STR0046) //"Campo(s) "###" com tamanho diferente." //ASK 26/02/2008
         MSGSTOP(STR0095 + Chr(13) + Chr(10) + ; //Campos necessarios para Integração com o Financeiro estão com tamanhos diferentes.
                  STR0045 + cCamposErro + Chr(13) + Chr(10) + ;  //"Campo(s) "###" com tamanho diferente."
                  STR0094) //"Favor contatar o Depto de Suporte."
         lTemWDCampos:=.F.
         Return(.f.)
      ENDIF

      lSair:=.F.
      IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,cOrigem),)
      IF lSair
         Return(.f.)
      ENDIF

   ELSEIF "SW6" $ cOrigem
      IF SW6->(FIELDPOS("W6_PREFIXF")) == 0 .OR.;
         SW6->(FIELDPOS("W6_NUMDUPF")) == 0 .OR.;
         SW6->(FIELDPOS("W6_PARCELF")) == 0 .OR.;
         SW6->(FIELDPOS("W6_TIPOF"))   == 0 .OR.;
         SW6->(FIELDPOS("W6_FORNECF")) == 0 .OR.;
         SW6->(FIELDPOS("W6_LOJAF"))   == 0 .OR.;
         SW6->(FIELDPOS("W6_PREFIXS")) == 0 .OR.;
         SW6->(FIELDPOS("W6_NUMDUPS")) == 0 .OR.;
         SW6->(FIELDPOS("W6_PARCELS")) == 0 .OR.;
         SW6->(FIELDPOS("W6_TIPOS"))   == 0 .OR.;
         SW6->(FIELDPOS("W6_FORNECS")) == 0 .OR.;
         SW6->(FIELDPOS("W6_LOJAS"))   == 0
         lTemW6Campos:=.F.

         MSGSTOP(STR0093 + chr(13)+ chr(10)+ STR0094)    //ASK 26/02/2008
         //MSGSTOP("Campos necessarios p/ Integracao com o Financeiro nao existem!"+chr(13)+chr(10)+;
         //        "Favor contatar o Depto de Suporte!")
         Return(.f.)
      ENDIF

      IF lTemW6Campos
         IF(LEN(SW6->W6_PREFIXF) # LEN(SE2->E2_PREFIXO),cCamposErro+="W6_PREFIXF,E2_PREFIXO e ",)
         IF(LEN(SW6->W6_NUMDUPF) # LEN(SE2->E2_NUM)    ,cCamposErro+="W6_NUMDUPF,E2_NUM e "    ,)
         IF(LEN(SW6->W6_PARCELF) # LEN(SE2->E2_PARCELA),cCamposErro+="W6_PARCELF,E2_PARCELA e ",)
         IF(LEN(SW6->W6_TIPOF)   # LEN(SE2->E2_TIPO)   ,cCamposErro+="W6_TIPOF,E2_TIPO e "     ,)
         IF(LEN(SW6->W6_FORNECF) # LEN(SE2->E2_FORNECE),cCamposErro+="W6_FORNECF,E2_FORNECE e ",)
         IF(LEN(SW6->W6_LOJAF)   # LEN(SE2->E2_LOJA)   ,cCamposErro+="W6_LOJAF,E2_LOJA e "     ,)
         IF(LEN(SW6->W6_PREFIXS) # LEN(SE2->E2_PREFIXO),cCamposErro+="W6_PREFIXS,E2_PREFIXO e ",)
         IF(LEN(SW6->W6_NUMDUPS) # LEN(SE2->E2_NUM)    ,cCamposErro+="W6_NUMDUPS,E2_NUM e "    ,)
         IF(LEN(SW6->W6_PARCELS) # LEN(SE2->E2_PARCELA),cCamposErro+="W6_PARCELS,E2_PARCELA e ",)
         IF(LEN(SW6->W6_TIPOS)   # LEN(SE2->E2_TIPO)   ,cCamposErro+="W6_TIPOS,E2_TIPO e "     ,)
         IF(LEN(SW6->W6_FORNECS) # LEN(SE2->E2_FORNECE),cCamposErro+="W6_FORNECS,E2_FORNECE e ",)
         IF(LEN(SW6->W6_LOJAS)   # LEN(SE2->E2_LOJA)   ,cCamposErro+="W6_LOJAS,E2_LOJA e "     ,)
      ENDIF

      IF !EMPTY(cCamposErro)
         cCamposErro:=LEFT(cCamposErro,LEN(cCamposErro)-3)
         //MSGSTOP(STR0045+cCamposErro+STR0046) //"Campo(s) "###" com tamanho diferente." //ASK 26/02/2008
         MSGSTOP(STR0095 + Chr(13) + Chr(10) + ; //Campos necessarios para Integração com o Financeiro estão com tamanhos diferentes.
               STR0045 + cCamposErro + Chr(13) + Chr(10) + ;  //"Campo(s) "###" com tamanho diferente."
               STR0094) //"Favor contatar o Depto de Suporte."

         Return(.f.)
      ENDIF

   ELSEIF "SWB" $ cOrigem

      IF SWB->(FIELDPOS("WB_LOJA"   )) == 0 .OR.;
         SWB->(FIELDPOS("WB_TIPOTIT")) == 0 .OR.;
         SWB->(FIELDPOS("WB_PREFIXO")) == 0 //AWR - Os outros campos já existiam da versão anterior
         lTemW6Campos:=.F.
         MSGSTOP(STR0093 + chr(13)+ chr(10)+ STR0094) //ASK 26/02/2008
         //MSGSTOP("Campos necessarios p/ Integracao com o Financeiro nao existem!"+chr(13)+chr(10)+;
         //        "Favor contatar o Depto de Suporte!")

         Return(.f.)
      ENDIF

      IF lTemW6Campos
         IF(LEN(SWB->WB_PREFIXO) # LEN(SE2->E2_PREFIXO),cCamposErro+="WB_PREFIXO, E2_PREFIXO e ",)
         IF(LEN(SWB->WB_NUMDUP)  # LEN(SE2->E2_NUM)    ,cCamposErro+= "WB_NUMDUP, E2_NUM e "    ,)
         IF(LEN(SWB->WB_PARCELA) # LEN(SE2->E2_PARCELA),cCamposErro+="WB_PARCELA, E2_PARCELA e ",)
         IF(LEN(SWB->WB_TIPOTIT) # LEN(SE2->E2_TIPO)   ,cCamposErro+="WB_TIPOTIT, E2_TIPO e "   ,)
         IF(LEN(SWB->WB_FORN)    # LEN(SE2->E2_FORNECE),cCamposErro+=   "WB_FORN, E2_FORNECE e ",)
         IF(LEN(SWB->WB_LOJA)    # LEN(SE2->E2_LOJA)   ,cCamposErro+=   "WB_LOJA, E2_LOJA e "   ,)
      ENDIF

      IF !EMPTY(cCamposErro)
         cCamposErro:=LEFT(cCamposErro,LEN(cCamposErro)-3)
         //MSGSTOP(STR0045+cCamposErro+STR0046) //"Campo(s) "###" com tamanho diferente." //ASK 26/02/2008
         MSGSTOP(STR0095 + Chr(13) + Chr(10) + ; //Campos necessarios para Integração com o Financeiro estão com tamanhos diferentes.
               STR0045 + cCamposErro + Chr(13) + Chr(10) + ;  //"Campo(s) "###" com tamanho diferente."
               STR0094) //"Favor contatar o Depto de Suporte."

         Return(.f.)
      ENDIF

   ENDIF

   lRetF050 := .F.
   IF "SW6_102" == cOrigem
      lTitFreteIAE  :=.F.
   ENDIF
   IF "SW6_103" == cOrigem
      lTitSeguroIAE :=.F.
   ENDIF

   lSair:=.F.
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"EXECUTA_INTEGRACAO"),)
   IF lSair
      RETURN lRetF050
   ENDIF

   Do Case
      Case cOperacao == "2" // INCLUSAO

         IF "SWD" $ cOrigem
            lIncAux  := IF(TYPE("lIncAux")<>"L",.T.,lIncAux)

            IF cOrigem == "SWD_ADI" // Geracao dos titulos base de adiantamento == "S" pelo botao prestacao de contas
               lIncAux := .F.
               M->WD_DESPESA := SWD->WD_DESPESA
               // A natureza carregada pela tela de F11 do desembaraço é valido para os títulos de frete e seguro
               // e quando não a despesa deve carregar a natureza do fornecedor
               IF ! SWD->WD_DESPESA $ "101|102|103"
                  cIniNatur := SA2->A2_NATUREZ
               EndIF
               //ISS - 19/05/2010 - Validação para que não seja incluido um título com um tipo diferente de "NF".
               cValidaOK:= " .AND. FI400ValSWD() "
            ELSEIF cOrigem == "SWD_INT" // AST - 09/09/08 - Chama a validação ao clicar em OK na tela de Compras a pagar
               cValidaOK:= " .AND. FI400ValFin(.T.) "
            ELSE
               cIniNatur := ""
               cValidaOK := " .AND. FI400ValFin(.F.,.T.) "
            ENDIF
         ELSE
            lIncAux  := .F.
            cIniNatur:= ""
            cIniSerie:= ""
            cValidaOK:= " .AND. FI400ValFin(.T.) "
            nAtomatico:=2
            cNatureza :=""
            // AWR - 03/06/2004 - Inclusao Automatica
            IF "SW6" $ cOrigem .OR. "SWB" $ cOrigem
               IF SX1->(DBSEEK("EICFI5"+Space(4)))
                  Pergunte("EICFI5",.F.)
                  IF(!EMPTY(MV_PAR01), nAtomatico:=MV_PAR01 ,)
                  IF(!EMPTY(MV_PAR02), cNatureza :=MV_PAR02 ,)
               ENDIF
            ENDIF
            lAutomatico:= (nAtomatico = 1) .Or. cIniParam == "BAIXA_PA_LO100" //Quando for FFC, assumir rotina automatica sempre
            // AWR - 03/06/2004 - Inclusao Automatica
            //IF cOrigem = "SWB_AP100" .AND. ALLTRIM(cTipo_Tit) = "PA" .AND. LEFT(M->WA_PO_DI,1) == "A"//AWR - 18/04/2007 - Quando é "PA" deve apresentar a tela para digitacao do Banco/Agencia/Conta
            //IF cOrigem = "SWB_AP100" .AND. ALLTRIM(cTipo_Tit) = "PA" .AND. (LEFT(M->WA_PO_DI,1) == "A" .Or. LEFT(M->WA_PO_DI,1) == "F" /*.Or. LEFT(M->WA_PO_DI,1) == "C"*/ )	// GCC - 27/08/2013  // GFP - 18/09/2014
            //   lAutomatico:= .F.
            //ENDIF
            cOriRdm:= cOrigem
            cTipoRdm:= cTipo_Tit
            lAutRdm:= lAutomatico

            IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ADIANT"),)

            lAutomatico:= lAutRdm
         ENDIF
         INCLUI := .T.
         ALTERA := .F.
         bIniciaVal:={|| Fi400IncTit(IF(lIncAux,"I","A"))}
         bExecuta := {|| nPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Inclu")}) ,;
                           lRetF050:=FA050Inclu("SE2",SE2->(RECNO()),IF(nPosRot=0,3,nPosRot) ),;
                           If(ValType(lRetF050) <> "N", lRetF050 := .F., lRetF050 := (lRetF050 == 1)), IF(lRetF050, nRecSE2 := SE2->(RECNO()), nRecSE2 := 0) } //ASR	08/02/2006 - GUARDA A POSICAO DA SE2 PARA RECUPERAR O NUMERO DA DUPLICATA

      Case cOperacao == "3"// ALTERACAO

         If "SWD" $ cOrigem

            //LGS-28/10/13 - Quando o titulo no financeiro foi gerado a partir de uma alteração em uma despesa já gravada e com NF gerada
            //na despesa ainda nao foi feito a gravação das informações do titulo, nesse caso tenho que usar as variaveis de memoria para criar a chave de pesquisa na SE2.
            lDespesa  := IF(TYPE("lDespesa")<>"L",.F.,lDespesa)
            If lDespesa// == .T.
               cChave  := M->WD_PREFIXO+M->WD_CTRFIN1+M->WD_PARCELA+M->WD_TIPO+M->WD_FORN+M->WD_LOJA

            Else
               SWD->(DBGOTO(TRB->RECNO))
               IF !EMPTY(SWD->WD_TIPO)
                  cChave  := SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
                  lBaixado:= IsBxE2Eic(SWD->WD_PREFIXO,SWD->WD_CTRFIN1,SWD->WD_TIPO,SWD->WD_FORN,SWD->WD_LOJA,,SWD->WD_PARCELA)//ASR 17/10/2005
               ELSE
                  cChave  := "EIC"+SWD->WD_CTRFIN1+"ANF "+SWD->WD_FORN+SWD->WD_LOJA
                  lBaixado:= IsBxE2Eic("EIC",SWD->WD_CTRFIN1,"NF ",SWD->WD_FORN,SWD->WD_LOJA,,SWD->WD_PARCELA)//ASR 17/10/2005
               ENDIF
               If lBaixado
                  MSGINFO(STR0091) // "Titulo nao pode ser Alterado por haver baixa no Financeiro!"
                  RETURN .F.
               EndIf
            EndIf

         ELSEIf cOrigem == "SW2"// AWR - 20/05/2004 - MP135

            IF SW2->(FIELDPOS("W2_CHAVEFI")) # 0
               cChave:=SW2->W2_CHAVEFI
            ELSE
               RETURN .T.
            ENDIF

         EndIf

         DBSELECTAREA("SE2")
         SE2->(DBSETORDER(1))
         IF !SE2->(DBSEEK(xFilial()+cChave))
            MSGINFO(STR0061)//"Lancamento no Finaceiro nao encontrado,"
            If cOrigem=="SW2" .AND. SW2->(FIELDPOS("W2_CHAVEFI")) # 0 // AWR - 20/05/2004 - MP135
               SW2->(RecLock("SW2",.F.))
               SW2->W2_CHAVEFI := ""
               SW2->(MSUNLOCK())
            ENDIF
            RETURN .F.
         Else
            If !("SWD" $ cOrigem)
               aAdd(aAutoFina,{"E2_FILIAL",  SE2->E2_FILIAL,   Nil})
               aAdd(aAutoFina,{"E2_PREFIXO", SE2->E2_PREFIXO,  Nil})
               aAdd(aAutoFina,{"E2_NUM",     SE2->E2_NUM,      Nil})
               aAdd(aAutoFina,{"E2_PARCELA", SE2->E2_PARCELA,  Nil})
               aAdd(aAutoFina,{"E2_TIPO",    SE2->E2_TIPO,     Nil})
               aAdd(aAutoFina,{"E2_FORNECE", SE2->E2_FORNECE,  Nil})
               aAdd(aAutoFina,{"E2_LOJA",    SE2->E2_LOJA,     Nil})
               nAutoOper := 4
            EndIf
         ENDIF
         INCLUI := .F.
         ALTERA := .T.
         bExecuta := {|| nPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Alter")}) ,;
                     lRetF050:=FA050Alter("SE2",SE2->(RECNO()),IF(nPosRot=0,4,nPosRot)), If(ValType(lRetF050) <> "N", lRetF050:=.F., lRetF050 := (lRetF050 == 1)) }

      Case cOperacao == "4"// Exclusao

         If "SWD" $ cOrigem
            IF cOrigem # "SWD_ESTORNA" .AND. SELECT("TRB") > 0
               SWD->(DBGOTO(TRB->RECNO))
            ENDIF
            // EOS - 03/05/04 - Qdo for alterar um titulo antigo, os campos de prefixo, tipo e loja do SWD nao
            //                  estarao preenchidos e p/ posicionar no título deveremos utilizar estas  informacoes
            //                  fixas, como era feito antes.
            IF !EMPTY(SWD->WD_TIPO)
               cChave := SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
               lBaixado := IsBxE2Eic(SWD->WD_PREFIXO,SWD->WD_CTRFIN1,SWD->WD_TIPO,SWD->WD_FORN,SWD->WD_LOJA,,SWD->WD_PARCELA)//ASR 17/10/2005
            ELSE
               cChave := "EIC"+SWD->WD_CTRFIN1+"ANF "+SWD->WD_FORN+SWD->WD_LOJA
               lBaixado := IsBxE2Eic("EIC",SWD->WD_CTRFIN1,"NF ",SWD->WD_FORN,SWD->WD_LOJA,,SWD->WD_PARCELA)//ASR 17/10/2005
            ENDIF
            If lBaixado
               IF lAutomatico = NIL .OR. !lAutomatico
                  MSGINFO(STR0092) // "Titulo nao pode ser Excluido por haver baixa no Financeiro!"
               ENDIF
               RETURN .F.
            EndIf

         ELSEIf "SWB" $ cOrigem
            SWB->(DBSETORDER(1))
            IF SWB->(FIELDPOS("WB_LOJA"))#0    .AND. !EMPTY(SWB->WB_LOJA)    .AND.;
               SWB->(FIELDPOS("WB_TIPOTIT"))#0 .AND. !EMPTY(SWB->WB_TIPOTIT) .AND. ;
               SWB->(FIELDPOS("WB_PREFIXO"))#0
               cChave:=SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA
            ELSE
               SA2->(DBSETORDER(1))
               SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN))
               cChave:="EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SA2->A2_LOJA
            ENDIF

            IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400TITFIN_EXCLUSAO"),) // Jonato 10-Fev-2005

         ELSEIf cOrigem=="SW6_102" // Frete
            cChave:=SW6->W6_PREFIXF+SW6->W6_NUMDUPF+SW6->W6_PARCELF+SW6->W6_TIPOF+SW6->W6_FORNECF+SW6->W6_LOJAF
            // EOS - 03/05/04 - Qdo for excluir um titulo antigo, os campos acima nao estarao preenchidos, portanto
            //                  o titulo devera ser deletado pela forma antiga, pois nao tenho como posicionar
            //                  chamando a rotina F INA050 pois nao sei com qual parcela foi gerado o titulo, visto que
            //                  os titulos provisorios, o titulo do frete e do seguro eram criados com o mesmo numero.
            IF EMPTY(cChave)
               SY4->(DBSEEK(XFILIAL("SY4")+SW6->W6_AGENTE))
               IF SA2->(DBSEEK(XFILIAL('SA2')+SY4->Y4_FORN+SY4->Y4_LOJA))
                  DeleDupEIC("EIC",;            // Prefixo do titulo
                              SW6->W6_NUMDUP,;   // Numero das duplicatas
                              -1,;               // Numero de parcela.
                              "NF" ,;            // Tipo do titulo
                              SY4->Y4_FORN,;     // Fornecedor
                              SY4->Y4_LOJA,;     // Loja
                              "SIGAEIC")         // Origem da geracao da duplicata (Nome da rotina)
                  lTitFreteIAE  :=.T.
               ENDIF
               RETURN .T.
            ENDIF

         ELSEIf cOrigem=="SW6_103" // Seguro
            cChave:=SW6->W6_PREFIXS+SW6->W6_NUMDUPS+SW6->W6_PARCELS+SW6->W6_TIPOS+SW6->W6_FORNECS+SW6->W6_LOJAS
            // EOS - 03/05/04 - Qdo for excluir um titulo antigo, os campos acima nao estarao preenchidos, portanto
            //                  o titulo devera ser deletado pela forma antiga, pois nao tenho como posicionar
            //                  chamando a rotina F INA050 pois nao sei com qual parcela foi gerado o titulo, visto que
            //                  os titulos provisorios, o titulo do frete e do seguro eram criados com o mesmo numero.
            IF EMPTY(cChave)
               SYW->(DBSEEK(XFILIAL("SYW")+SW6->W6_CORRETO))
               IF SA2->(DBSEEK(XFILIAL('SA2')+SYW->YW_FORN+SYW->YW_LOJA))
                  DeleDupEIC("EIC",;           // Prefixo do titulo
                              SW6->W6_NUMDUP,;   // Numero das duplicatas
                              -1,;               // Numero de parcela.
                              "NF" ,;            // Tipo do titulo
                              SYW->YW_FORN,;     // Fornecedor
                              SYW->YW_LOJA,;     // Loja
                              /*"SIGAEIC"*/"")   // Origem da geracao da duplicata (Nome da rotina)  // GFP - 20/05/2015
                  lTitSeguroIAE :=.T.
               ENDIF
               RETURN .T.
            ENDIF
         ELSEIf cOrigem=="SW6_IMP"
            cChave:=SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA

         ELSEIf cOrigem=="SW2"// AWR - 20/05/2004 - MP135

            IF SW2->(FIELDPOS("W2_CHAVEFI")) # 0
               cChave:=SW2->W2_CHAVEFI
            ELSE
               RETURN .T.
            ENDIF

         EndIf

         SE2->(DBSETORDER(1))
         IF !SE2->(DBSEEK(xFilial()+cChave))
            If Upper(AllTrim(cOrigem)) == "SWD" .And. Select("TRB") > 0
               //ASK 16/10/2007 - Exclui despesa 901, adiantamentos que tiveram PA cancelado.
               If TRB->WD_DESPESA == "901" .And. TRB->WD_GERFIN == "1"
                  Return .T.
               EndIf
            EndIf
            IF lAutomatico = NIL .OR. !lAutomatico
               MSGINFO(STR0061)//"Lancamento no Finaceiro nao encontrado,"
               If cOrigem=="SW2" .AND. SW2->(FIELDPOS("W2_CHAVEFI")) # 0 // AWR - 20/05/2004 - MP135
                  SW2->(RecLock("SW2",.F.))
                  SW2->W2_CHAVEFI := ""
                  SW2->(MSUNLOCK())
               ENDIF
            ENDIF
            RETURN .F.
         Else
            If !("SWD" $ cOrigem)
               aAdd(aAutoFina,{"E2_FILIAL",  SE2->E2_FILIAL,   Nil})
               aAdd(aAutoFina,{"E2_PREFIXO", SE2->E2_PREFIXO,  Nil})
               aAdd(aAutoFina,{"E2_NUM",     SE2->E2_NUM,      Nil})
               aAdd(aAutoFina,{"E2_PARCELA", SE2->E2_PARCELA,  Nil})
               aAdd(aAutoFina,{"E2_TIPO",    SE2->E2_TIPO,     Nil})
               aAdd(aAutoFina,{"E2_FORNECE", SE2->E2_FORNECE,  Nil})
               aAdd(aAutoFina,{"E2_LOJA",    SE2->E2_LOJA,     Nil})
               nAutoOper := 5
            EndIf
         ENDIF
         IF GetNewPar("MV_EICCONT","N") $ cSim // AWR - 28/05/2004
            SE2->(RecLock("SE2",.F.))
            SE2->E2_LA:=""// AWR - 01/07/2004 - Para nao rodar as rotinas do Contabil no FA050Delet
            SE2->(MSUNLOCK())
         ENDIF
         DBSELECTAREA("SE2")
         INCLUI := .F.
         ALTERA := .F.
         bExecuta := {|| nPosRot  :=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Delet")}) ,;
                           lF050Auto:=IF(lAutomatico==NIL,.F.,lAutomatico),;
                           lRetF050 :=FA050Delet("SE2",SE2->(RECNO()),IF(nPosRot=0,5,nPosRot) ), If(ValType(lRetF050) <> "L", lRetF050 := .F., ) }

   EndCase
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"ANTES_GRAVACAO_TIT"),)

   DBSELECTAREA("SE2")
   IF lAutomatico .AND. cOperacao == "2" // INCLUSAO
      // AWR - 03/06/2004 - Inclusao Automatica

      //** AAF 12/09/07 - Inicialização da Natureza.
      If Empty(cNatureza) .AND. !Empty(cCodFor)
         SA2->(nRec := RecNo(), nOrd:= IndexOrd(), dbSetOrder(1))
         If SA2->( dbSeek(xFilial("SA2")+cCodFor+cLojaFor) )
            cNatureza := SA2->A2_NATUREZ
         EndIf
         SA2->(dbSetOrder(nOrd),dbGoTo(nRec))
      EndIf

      If Empty(cParcela)
         cParcela := EasyGetParc(nParc)  // GFP - 20/01/2014
      EndIf
   
      cPrefixo := IF(EMPTY(cPrefixo),"EIC",cPrefixo)
      IF Empty(cInidocto) //LRS - 15/08/2018
         cIniDocto := BuscaE2Num( cIniDocto,cCodFor,cLojaFor,cTipo_Tit,cPrefixo,cParcela,cOrigem )
      EndIF

      aTit:={}
      AADD(aTit,{"E2_NUM"    ,cIniDocto                        ,NIL})
      AADD(aTit,{"E2_PREFIXO",IF(EMPTY(cPrefixo),"EIC",cPrefixo),NIL})
      AADD(aTit,{"E2_PARCELA",cParcela                         ,NIL})
      AADD(aTit,{"E2_TIPO"   ,cTipo_Tit                        ,NIL})
      AADD(aTit,{"E2_NATUREZ",cNatureza                        ,NIL})
      AADD(aTit,{"E2_FORNECE",cCodFor                          ,NIL})
      AADD(aTit,{"E2_LOJA"   ,cLojaFor                         ,NIL})
      AADD(aTit,{"E2_EMISSAO",cEmissao                         ,NIL})
      AADD(aTit,{"E2_VENCTO" ,cDtVecto                         ,NIL})
      AADD(aTit,{"E2_VENCREA",DataValida(cDtVecto,.T.)         ,NIL})//AWR - 09/11/2006 - ANTES: cDtVecto
      AADD(aTit,{"E2_VENCORI",cDtVecto                         ,NIL})
      AADD(aTit,{"E2_VALOR"  ,nValorS                          ,NIL})
      IF AllTrim(cTipo_Tit) == "PA" //LGS-06/04/2015 //MCF - 12/03/2015
         AADD(aTit,{"AUTBANCO"  ,SWB->WB_BANCO                 ,NIL})
         AADD(aTit,{"AUTAGENCIA",SWB->WB_AGENCIA               ,NIL})
         AADD(aTit,{"AUTCONTA"  ,SWB->WB_CONTA                 ,NIL})
      ENDIF
      AADD(aTit,{"E2_EMIS1"  ,Ddatabase                        ,NIL})
      AADD(aTit,{"E2_MOEDA"  ,nMoedSubs                        ,NIL})
      AADD(aTit,{"E2_VLCRUZ" ,Round(NoRound(xMoeda(nValorS,nMoedSubs,1,cEmissao,3,nTxMoeda),3),2),NIL})
      AADD(aTit,{"E2_TXMOEDA",nTxMoeda                         ,NIL})
      AADD(aTit,{"E2_HIST"   ,cHistorico                       ,NIL})
      If FindFunction("F050EasyOrig")
         AADD(aTit,{"E2_ORIGEM" ,"SIGAEIC"                        ,NIL})  // LGS - 16/05/2016
      Else
         AADD(aTit,{"E2_ORIGEM" ,/*"SIGAEIC"*/""                  ,NIL})  // GFP - 11/05/2015
      EndIf
      lMsErroAuto:=.F.
      lRetF050   :=.T.
      DBSELECTAREA("SE2")
      IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"DEP_GRAVACAO_TIT"),)//igor chiba 26/08/2010

      aOrdSE2 := SaveOrd("SE2")
      SE2->(DBSETORDER(1))
      If SE2->(DBSEEK(xFilial()+cPrefixo+cIniDocto+avkey(cParcela,"E2_PARCELA")+cTipo_Tit+cCodFor+cLojaFor))
         lAchouSE2 := .T.
      EndIf      
      restOrd(aOrdSE2)

      //WFS 30/12/10
      //Lançamentos online
      //Function F inA050(aRotAuto,nOpcion, nOpcAuto,bExecuta, aDadosBco,lExibeLanc,lOnline)
      If lGravaTit .And. !lAchouSE2  //TRP - 02/08/2011 - Variável para ser utilizada em rdmake.
         FI400ExecutaValid(1) //LGS - 24/04/2015
         Pergunte("EICFI4",.F.)
         //MSExecAuto({|x,y| F INA050(x,y)}, aTit, 3) nopado por WFS 30/12/10
         MSExecAuto({|a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)}, aTit, 3, Nil, Nil, Nil,MV_PAR02 == 1, MV_PAR01 == 1)
         If Len(aFIN050)<>0 //LGS - 24/04/2015
            FI400ExecutaValid(2)
         EndIf
         If lMsErroAuto
            If type("oErrorFin") == "O" //AOM - 28/07/2011 - Adiciona os Erros
               If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
                  oErrorFin:Error(MemoRead(NomeAutoLog()))
               EndIf
            Else
               lRetF050:=.F.
               MOSTRAERRO()
            EndIf
         Else
            cAutMotbx := If(Type("cAutMotbx")<>"C", "", cAutMotbx)
            If SE5->(DbSeek(xFilial("SE5")+cPrefixo+cIniDocto+cParcela)) //LGS-22/12/2014
               If IsLocked("SE5")
                  lLocSE5 := .F.
               Else
                  lLocSE5 := .T.
                  RecLock("SE5",.F.)
               EndIf
               If !Empty(cAutMotbx) .And. cAutMotbx != "NORMAL"
                  SE5->E5_MOTBX := cAutMotbx
               EndIf
               If SWB->WB_NUMDUP == SE5->E5_NUMERO .AND. nAtomatico == 1
                  SE5->E5_BANCO   := SWB->WB_BANCO
                  SE5->E5_AGENCIA := SWB->WB_AGENCIA
                  SE5->E5_CONTA   := SWB->WB_CONTA
               EndIf
               If lLocSE5
                  SE5->(MSUnLock())
               EndIf
            EndIf
         EndIf
      ElseIf lAchouSE2
         lRetF050 := .F.
      EndIf
   // AWR - 03/06/2004 - Inclusao Automatica
   ELSE
      //TRP - 30/08/12
      IF lGravaTit
         DBSELECTAREA("SE2")
         //LRS - 08/04/2016
         If Empty(cParcela)
            cParcela := EasyGetParc(nParc)
         EndIf
         //MFR 02/12/2020
         cParcela:=avkey(cParcela,"E2_PARCELA") 
         If IsMemVar("cIniDocto") .And. !Empty(cIniDocto)
            cSeqTit := cIniDocto
         ElseIf cOperacao == "2" //Inclusão
            cSeqTit := NumTit("SWD","WD_CTRFIN1")
         EndIf
         //THTS - 13/06/2022 - OSSME-6864
         If !Empty(aAutoFina) .And. nAutoOper > 0 .And. (cOperacao == "3" .Or. cOperacao == "4") //Ateracao ou Exclusao
            lMsErroAuto := .F.
            lRetF050 := .T.
            MSExecAuto({|a,b,c| FINA050(a,b,c)}, aAutoFina, nil,nAutoOper)
            If lMsErroAuto
               MostraErro()
               lRetF050:=.F.
            EndIf
         Else
            Fina050(,,,bExecuta)
         EndIf
           
         cSeqTit := Nil
         If !lRetF050 //Se Falso, ocorreu algum problema na integracao com o Financeiro
            If cOrigem == "SW6_102" //FRETE
                  lAltFrete := .F.
            ElseIf cOrigem == "SW6_103" //SEGURO
                  lAltSeguro := .F.
            EndIf
            RollBackSX8()
         Else
            ConfirmSX8()   
         EndIf
         
         If cOperacao == "2" //MCF - 31/03/2016
            If lRetF050
               cAutMotbx := If(Type("cAutMotbx")<>"C", "", cAutMotbx)
               cParcela  := If(Type("cParcela")<>"C" , "", cParcela)
               cIniDocto := If(Type("cIniDocto")<>"C", "", cIniDocto)
               cPrefixo  := If(Type("cPrefixo")<>"C" , "EIC", cPrefixo)

               aOrdSE5 :=SaveOrd("SE5")
               SE5->(DbSetOrder(7))
               If SE5->(DbSeek(xFilial("SE5")+cPrefixo+cIniDocto+cParcela))
                  If IsLocked("SE5")
                     lLocSE5 := .F.
                  Else
                     lLocSE5 := .T.
                     RecLock("SE5",.F.)
                  EndIf
                  If !Empty(cAutMotbx) .And. cAutMotbx != "NORMAL"
                     SE5->E5_MOTBX := cAutMotbx
                  EndIf
                  If lLocSE5
                     SE5->(MSUnLock())
                  EndIf
               EndIf
               RestOrd(aOrdSE5,.T.)
            EndIf
         EndIf
      ENDIF
   ENDIF

   //LGS-22/10/13 - Verifica se teve alteração do valor da despesa e chama novamente a tela do financeiro.
   if cOperacao == "3"
      If lRetF050 .And. !Empty(TRB->WD_NF_COMP)
         If !Empty(TRB->WD_VALOR_R)
            If SE2->E2_MOEDA <> 1 //THTS - 10/05/2017
               If Empty(SE2->E2_TXMOEDA)
                  nTxMoeE2 := RecMoeda(SE2->E2_EMISSAO, SE2->E2_MOEDA)
               Else
                  nTxMoeE2 := SE2->E2_TXMOEDA
               EndIf
            EndIf
            Do While Round(SE2->E2_VALOR * nTxMoeE2,MsDecimais(1)) # TRB->WD_VALOR_R
               cValorrr := ALLTRIM(Trans(TRB->WD_VALOR_R,'@E 999,999,9999.99'))
               MsgInfo(STR0143 + STR0145 + CHR(13)+CHR(10) +STR0146 + cValorrr + STR0147, STR0004)
               Fina050(,,,bExecuta)
            EndDo
         EndIf
      EndIf
   EndIf

   //LGS-28/10/13 - Verifica se houve alteração do valor do titulo no processo gerado a partir da alteração de uma despesa.
   lDespesa  := IF(TYPE("lDespesa")<>"L",.F.,lDespesa)
   If lDespesa == .T.
      If lRetF050 .And. !Empty(TRB->WD_NF_COMP)
      If !Empty(TRB->WD_VALOR_R)
         Do While M->WD_VALOR_R # TRB->WD_VALOR_R
            cValorrr := ALLTRIM(Trans(TRB->WD_VALOR_R,'@E 999,999,9999.99'))
            MsgInfo(STR0143 + STR0145 + CHR(13)+CHR(10) + STR0146 + cValorrr + STR0147, STR0004)
            FI400TITFIN("SWD","3")
         EndDo
      EndIf
      EndIf
   EndIf

   IF lRetF050 // AWR - 28/06/2004
      IF "SWB" == cOrigem
         IF VALTYPE(aTitInvoiceIAE) == "A"
            IF ASCAN(aTitInvoiceIAE,{ |T| T[1] == SWB->WB_INVOICE+SWB->WB_FORN } ) = 0
               AADD(aTitInvoiceIAE,{ SWB->WB_INVOICE+SWB->WB_FORN, .T. } )
            ENDIF
         ENDIF
      ENDIF
      IF "SW6_102" == cOrigem
         lTitFreteIAE  :=.T.
      ENDIF
      IF "SW6_103" == cOrigem
         lTitSeguroIAE :=.T.
      ENDIF
      IF "SWD" == cOrigem
         //NCF - 08/06/2011 - Deduções de IRRF, ISS, INSS, PIS, COFINS e CSLL do valor do título
         //                    não devem ser deduzidas do valor da despesa do SIGAEIC.
         //Obs: Na Alteração de título, o ISS não somado na inclusão é incorporado ao valor do título
         //IF SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_PIS+E2_COFINS+E2_CSLL) # SE2->E2_VALOR
         //DFS - 18/01/12 - Variável calculada no fonte F INA050.PRX para retornar o valor bruto do título.
         IF n050ValBru <> 0 //FDR - 09/02/12 - Somente atualizar o valor da despesa quando n050ValBru <> 0
            M->WD_VALOR_R := n050ValBru //SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_PIS+E2_COFINS+E2_CSLL)
         ENDIF
         //ENDIF
      ENDIF
   ELSE
      IF "SWB" == cOrigem
         IF VALTYPE(aTitInvoiceIAE) == "A"
            IF (nPosT:=ASCAN(aTitInvoiceIAE,{ |T| T[1] == SWB->WB_INVOICE+SWB->WB_FORN } )) # 0
               aTitInvoiceIAE[nPosT,2] := .F.
            ELSE
               AADD(aTitInvoiceIAE,{ SWB->WB_INVOICE+SWB->WB_FORN, .F. } )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"APOS_GRAVACAO_TIT"),)

Return lRetF050
/*---------------------------------------------------------------------------------
// BuscaE2Num()
// Miguel Gontijo
// Função para buscar o último número de título válido e salvar o mesmo
---------------------------------------------------------------------------------*/
Function BuscaE2Num( cNumSE2,cForSE2,cLojaSE2,cTipoSE2,cPrefSE2,cParcSE2,cOrigemSE2 )
   Local cCampoSeq     := ""
   Local cAlias        := ""

   // para o mesmo fornecedor(NF de frete e seguro gerado no embarque)
   IF cOrigemSE2 $ "SW6_102/SW6_103"
         cAlias := "SW6"
         IF cOrigemSE2 $ "SW6_102"
               cCampoSeq := "W6_NUMDUPF"
         ELSE
               cCampoSeq := "W6_NUMDUPS"
         ENDIF
   ElseIf cOrigemSE2 $ "SW9" 
      cAlias      := "SW9"
      cCampoSeq   := "W9_NUM"
   ElseIf cOrigemSE2 $ "SWD"
      cAlias      := "SWD"
      cCampoSeq   := "WD_CTRFIN1"
   ElseIf cOrigemSE2 $ "SWB"
      cAlias      := "SWB"
      cCampoSeq   := "WB_NUMDUP"
   Else
      cAlias      := "SE2"
      cCampoSeq   := "E2_NUM"
   ENDIF

Return NumTit(cAlias, cCampoSeq)//cNumSE2

*-------------------------------------------------------------------*
FUNCTION FI400ValFin(lValida,lOk) // JBS - 23/04/2004
*-------------------------------------------------------------------*
LOCAL cFilSYB:=xFilial('SYB') // JBS - 28/04/2004
Local aOrd   := SaveOrd({"SYB","SB5"}) //RRC - 26/11/2013 - Integração SIGAEIC x SIGAESS
Local cItem  := ""
Local cNBS   := ""
Local nVlrDigDesp //LGS-07/11/2014
Local lMvEasy := EasyGParam("MV_EASY") == "S"

DEFAULT lValida := .F.
DEFAULT lOk := .F.
//DFS - 14/06/10 - Fazer a verificação se a Tabela SE2 está alocada e caso não esteja alocar essa tabela para que o erro não ocorra.
ChkFile("SE2")

IF TYPE("cOrigem") # "C" .Or. IsInCallStack("F050DELRTD")
   RETURN .F.
ENDIF
	//JAP
IF cOrigem == "SWB_AP100" .AND. LEFT(M->WA_PO_DI,1) == "A" .AND. lValida
    nRecSE2 := SE2->(Recno())
    SE2->(DBSETORDER(1))
    IF SE2->(DBSEEK(xFilial()+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+AVKEY(M->E2_TIPO,"E2_TIPO")+M->E2_FORNECE+M->E2_LOJA))
       MSGINFO(STR0117) //STR0117 "Título já existe no financeiro!"
       SE2->(DbGoto(nRecSE2))
       Return .F.
    ENDIF
    IF cTipo_Tit <> Alltrim(M->E2_TIPO)
       MSGINFO(STR0118+cTipo_Tit) //STR0118 "Tipo de título deve ser "
       Return .F.
    ELSEIF cTipo_Tit = "PR" .AND. cIniDocto <> Alltrim(M->E2_NUM)
      If lMvEasy      
         MSGINFO(STR0119) //STR0119 "Número do título deve ser o número do pedido de compras"
         M->E2_NUM := cIniDocto
         Return .F.
      EndIf       
    ENDIF
    SE2->(DbGoto(nRecSE2))
ENDIF

// TDF - 25/04/11 - Verifica se o valor do título foi alterado na inclusão
IF cOrigem == "SWB_AP100"
nValFOBMOE := M->E2_VALOR - (SWB->WB_FOBMOE + SWB->WB_PGTANT)
   If nValFOBMOE <> 0
      MSGSTOP(STR0097)
      Return .F.
   EndIf
EndIf

If lValida //Validar se a data de vencimento não é menor que a data de emissao
   If M->E2_VENCTO < M->E2_EMISSAO
      Help(" ",1,"FANODATA")
      Return .F.
   EndIF
EndIf

// AST - 09/09/08
If lOk
   If alltrim(M->E2_TIPO) == "PR" .OR. alltrim(M->E2_TIPO) == "PRE"
      Alert(STR0120) //STR0120 "O título não pode ser provisório."
      Return .F.
   Else
      If FindFunction("F050EasyOrig") //LGS - 17/05/2016
         M->E2_ORIGEM := If(Empty(M->E2_ORIGEM), "SIGAEIC", M->E2_ORIGEM)
      EndIf
      Return .T.
   EndIf
EndIf

IF lValida .AND. ("SWB" $ cOrigem .OR. cOrigem == "SW2")// AWR - 20/05/2004 - MP135
   // Se a variavel nMoedSubs = 0 significa que a moeda nao esta cadastrada p/ nenhum MV_SIMB?
   IF nMoedSubs # 0 .AND. M->E2_MOEDA # nMoedSubs
      MSGSTOP(STR0121+STR(nMoedSubs,2),STR0069)//"Verificao Importacao" //STR0121 "Moeda do titulo deve ser: "
      Return .F.
   ENDIF

   IF cCodFor # M->E2_FORNECE .OR. cLojaFor # M->E2_LOJA
      MSGSTOP(STR0070+cCodFor+"-"+cLojaFor,STR0069) //"Fornecedor nao pode ser diferente de: "###"Verificao Importacao"
      Return .F.
   ENDIF
   IF cOrigem == "SWB_INT"
      IF nValorS # M->E2_VALOR
         IF M->E2_ISS == 0 .AND. M->E2_IRRF == 0 .AND. M->E2_INSS == 0 .AND. M->E2_COFINS == 0 .AND. M->E2_PIS == 0 .AND. M->E2_CSLL == 0 //Tratamento para retenção de impostos na natureza no título.
            MSGSTOP(STR0122+ALLTRIM(TRANSFORM(nValorS, "@E 999,999,999.99"))) //STR0122 "Valor do titulo deve corresponder ao valor da parcela do câmbio = "
            Return .F.
         ENDIF
      ENDIF
   ENDIF

   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400VALFIN_1"),) // Bete 06/09/05
   //MFR 27/11/2019 OSSME-3915
   IF M->E2_IRRF # 0 
      EasyHelp(STR0170) //"A natureza informada nesta operação não pode ser usada pois realiza a retenção de impostos para um fornecedor estrangeiro. Corrija a natureza para prosseguir com a operação.")
      RETURN .F.
   EndIf
   RETURN .T.
ENDIF

IF lValida .AND. cOrigem == "SWD_INT"
   IF M->E2_VALOR <> Int_DspDe->NDDVALOR
   		IF M->E2_ISS == 0 .AND. M->E2_IRRF == 0 .AND. M->E2_INSS == 0 .AND. M->E2_COFINS == 0 .AND. M->E2_PIS == 0 .AND. M->E2_CSLL == 0 //LRS - 10/10/2014 - Caso Exista retenção de impostos na integração e o valor  ser diferente da parcela do cambio, deixa seguir o processo.
	      MSGSTOP(STR0122+ALLTRIM(TRANSFORM(Int_DspDe->NDDVALOR, "@E 999,999,999.99"))) //STR0122 "Valor do titulo deve corresponder ao valor da parcela do câmbio = "
	      Return .F.
	   ENDIF
   ENDIF
   Return .T.
ENDIF

IF "SWD" $ cOrigem

   SYB->(dbSeek(cFilSYB+M->WD_DESPESA)) // JBS - 28/04/2004

   M->WD_PREFIXO  := M->E2_PREFIXO
   M->WD_DOCTO    := M->E2_NUM
   M->WD_CTRFIN1  := M->E2_NUM
   M->WD_PARCELA  := M->E2_PARCELA
   M->WD_TIPO     := M->E2_TIPO
   M->WD_FORN     := M->E2_FORNECE
   M->WD_LOJA     := M->E2_LOJA

   //RRC - 26/11/2013 - Integração SIGAEIC x SIGAESS
   If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0
      SYB->(DbSetOrder(1)) //YB_FILIAL+YB_DESP
      SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
	  //If SYB->(DbSeek(xFilial("SYB")+M->WD_DESPESA) //RMD - 31/08/17 - Verifica primeiro se o produto está preenchido no SWD
      If !Empty(cItem := SWD->WD_PRDSIS) .Or. (SYB->(DbSeek(xFilial("SYB")+M->WD_DESPESA)) .And. !Empty(cItem := SYB->YB_PRODUTO))
         //cItem := SYB->YB_PRODUTO
         If SB5->(DbSeek(xFilial("SB5")+cItem))
            cNBS := SB5->B5_NBS
         EndIf
      EndIf
      If !Empty(cNBS)
         M->WD_MOEDA  := Left(EasyGParam("MV_SIMB"+Alltrim(Str(M->E2_MOEDA))),AvSX3("EJW_MOEDA",AV_TAMANHO))
         M->WD_VL_MOE := M->E2_VALOR
         M->WD_TX_MOE := If(Empty(M->E2_TXMOEDA),BuscaTaxa(M->WD_MOEDA,M->E2_EMISSAO,,.F.),M->E2_TXMOEDA)
      EndIf
      RestOrd(aOrd,.T.)
   EndIf

   //** AAF - 22/02/2007 - Utilizar o valor bruto do titulo. Variavel nValBruto é gravada no F INA050.
   //** LGS - 07/11/2014 - So deve atualizar o valor qdo o campo E2_VALOR for alterado pelo cliente, o valor da variavel é atribuido no F INA050.
   nVlrDigDesp := If( Type("n050ValBru") == "N", n050ValBru, 0 )
   If !Empty(nVlrDigDesp)
	  If Type("nValBruto") == "N"
	     M->WD_VALOR_R  := nValBruto
	  Else
	     M->WD_VALOR_R  := /*M->E2_VLCRUZ*/n050ValBru //LRS - 30/07/2015
	  EndIf
   EndIf
   //**

   M->WD_DES_ADI  := M->E2_EMISSAO
   M->WD_DTENVF   := dDataBase
   M->WD_DESCDES  := SYB->YB_DESCR  // JBS - 28/04/2004
   IF GetNewPar("MV_EICCONT","N") $ cSim // AWR - 28/05/2004
      SE2->E2_LA  := "S"
   ENDIF

   SE2->E2_ORIGEM:= IF(!EMPTY(SE2->E2_ORIGEM),SE2->E2_ORIGEM,"SIGAEIC")  // GFP - 03/06/2015

   IF SELECT("TRB") > 0 .AND. TRB->(FieldPos("WD_NATUREZ")) # 0
      M->WD_NATUREZ := M->E2_NATUREZ
   EndIf

  IF SE2->(FIELDPOS("E2_HAWBEIC")) # 0//AWR - 22/10/2004
     SE2->E2_HAWBEIC:=M->WD_HAWB // RRV - 17/09/2012 - Olha a memória do campo WD_HAWB para carregar o código do processo.
  Endif

ELSEIF "SWB" $ cOrigem

    SE2->E2_ORIGEM:="SIGAEIC"

    IF cOrigem == "SWB_AP100"
       SWB->(Reclock("SWB", .F.)) 
       SWB->WB_DT_VEN := M->E2_VENCTO
       SWB->WB_NUMDUP := M->E2_NUM
       SWB->WB_PARCELA:= M->E2_PARCELA
       SWB->WB_FORN   := M->E2_FORNECE
       IF SWB->(FIELDPOS("WB_LOJA"))#0 .AND. SWB->(FIELDPOS("WB_TIPOTIT"))#0 .AND. SWB->(FIELDPOS("WB_PREFIXO"))#0
          SWB->WB_PREFIXO:=M->E2_PREFIXO
          SWB->WB_TIPOTIT:=M->E2_TIPO
          SWB->WB_LOJA   :=M->E2_LOJA
       ENDIF
       SWB->(MsUnlock()) 
       IF Select("TRB") > 0
          TRB->WB_RECNO:=SWB->(RECNO())
       EndIf
    ELSEIF cOrigem <> "SWB_INT"
       IF GetNewPar("MV_EICCONT","N") $ cSim // AWR - 28/05/2004
          SE2->E2_LA:="S"
       ENDIF
       FI400ManutCambio('GRVPARCELA',M->W6_HAWB)
    ENDIF
    IF SE2->(FIELDPOS("E2_HAWBEIC")) # 0//AWR - 22/10/2004
       SE2->E2_HAWBEIC:=SWB->WB_HAWB
    Endif


ELSEIF cOrigem == "SW2"// AWR - 20/05/2004 - MP135

    nVlAntecipado := SE2->E2_VALOR
    dDtProforma   := SE2->E2_EMISSAO
    nTxCambio     := SE2->E2_TXMOEDA
    SW2->(RecLock("SW2",.F.))
    SW2->W2_FOB_ANTE:= nVlAntecipado
    SW2->W2_CHAVEFI := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
    SW2->(MSUNLOCK())
    IF SE2->(FIELDPOS("E2_PO_EIC")) # 0//AWR - 22/10/2004
       SE2->E2_PO_EIC :=SW2->W2_PO_NUM
	Endif

ELSEIF !lValida .AND. "SW6" $ cOrigem// AWR - 11/11/2004

    IF SE2->(FIELDPOS("E2_HAWBEIC")) # 0
       SE2->E2_HAWBEIC:=SW6->W6_HAWB
    Endif

ENDIF

IF !lValida .AND. ("SW6_102" == cOrigem .OR. "SW6_103" == cOrigem)
   nRecSE2 := SE2->(RECNO())//AWR - 21/06/2006 - Guarda o registro do SE2 na inclusao pq antes de sair da inclusao automatica do titulo desposiciona
   IF GetNewPar("MV_EICCONT","N") $ cSim // AWR - 28/05/2004
      SE2->E2_LA:="S"
   ENDIF
ENDIF

Return .T.

*-------------------------------------------------------------------*
FUNCTION FI400IncTit(nTipOp) // EOS - 25/04/2004
*-------------------------------------------------------------------*
Local cCheque  := EasyGParam("MV_EIC0001",,"SWB->WB_CA_NUM") //TDF-06/08/10
Local lGerChqAdt,lMovBcoSCh 
Local lInclui := Inclui
Private cCampoBnf
Private lBenef := !Empty(cCampoBnf := EasyGParam("MV_AVG0195",,""))
//MFR 27/11/2019 OSSME-3915
Inclui := .T.
//NCF - 08/03/2019
FA050VALOR()
lGerChqAdt := mv_par05 == 1  //Gera Chq. p/ Adiant?
lMovBcoSCh := mv_par09 == 1  //Mov. Banc. Sem Cheque?
lNGerChqAd := !lGerChqAdt .And. lMovBcoSCh

IF EMPTY(M->E2_PREFIXO)
   M->E2_PREFIXO := "EIC"
ENDIF

IF FindFunction("F050EasyOrig") //LGS-19/05/2016
   M->E2_ORIGEM := "SIGAEIC"
ENDIF

//TDF - 07/07/11 - Inicializa a numeração do título
IF EMPTY(M->E2_NUM)
   If IsMemVar("cSeqTit") .And. ValType(cSeqTit) == "C"
      M->E2_NUM := cSeqTit
   Else
      M->E2_NUM := NumTit("SWD","WD_CTRFIN1")
   EndIf
ENDIF

IF cOrigem = "SWD_INT"
   M->E2_HIST := cHistorico
ENDIF

If !Empty(cIniNatur)
   M->E2_NATUREZ:=cIniNatur
EndIf

if type("nValDig") == "N" .and. INCLUI
    nValDig := M->E2_VALOR
endif

IF nTipOp == "A"
   //** AAF 12/09/07 - Inicialização da Natureza.
   If Empty(M->E2_NATUREZ) .AND. !Empty(cCodFor)
      SA2->(nRec := RecNo(), nOrd:= IndexOrd(), dbSetOrder(1))
      If SA2->( dbSeek(xFilial("SA2")+cCodFor+cLojaFor) )
         M->E2_NATUREZ := SA2->A2_NATUREZ
      EndIf
      SA2->(dbSetOrder(nOrd),dbGoTo(nRec))
   EndIf
   //**

   c_DuplDoc := GetNewPar("MV_DUPLDOC"," ")
   IF SUBSTR(c_DuplDoc,1,1) == "S" .AND. !EMPTY(cIniDocto)
      M->E2_NUM:=cIniDocto
   ENDIF

   M->E2_PARCELA := cParcela

   IF ALLTRIM(cTipo_Tit) # "PA" .OR. "SWB" $ cOrigem //AWR 17/04/2007 - Nao iniciar para obrigar a digitacao
      M->E2_TIPO := AvKey(cTipo_Tit,"E2_TIPO") //AAF 02/03/2007 - Evita falhas gravando sempre mesma qtd. de caracteres.
   ENDIF
   M->E2_FORNECE := cCodFor
   M->E2_LOJA    := cLojaFor
   M->E2_EMISSAO := cEmissao

   IF "SW6" $ cOrigem .OR. "SWB" $ cOrigem .OR. cOrigem == "SW2"// AWR - 20/05/2004 - MP135
      IF "SW6" $ cOrigem .OR. "SWB" $ cOrigem
         IF !EMPTY(cPrefixo)
            M->E2_PREFIXO := cPrefixo
         ENDIF
      ENDIF
      M->E2_NUM    := cIniDocto
      M->E2_MOEDA  := nMoedSubs
      M->E2_EMISSAO:= cEMISSAO
      M->E2_VENCTO := cDtVecto
      M->E2_VENCREA:= DataValida(cDtVecto,.T.)//AWR - 09/11/2006 - ANTES: cDtVecto
      If FindFunction("F050EasyOrig")
         M->E2_ORIGEM := "SIGAEIC"        // LGS - 17/05/2016
      Else
         M->E2_ORIGEM := /*"SIGAEIC"*/""  // GFP - 20/05/2015
      EndIf                                         //NCF - 11/12/2017
      M->E2_TXMOEDA:= xMoeda(1,nMoedSubs,1,cEmissao,IF("SW6" $ cOrigem .OR. "SWB" $ cOrigem,TamSX3("E2_TXMOEDA")[2],3),nTxMoeda) //LRS - 28/06/2017
      M->E2_HIST   := cHistorico
      M->E2_VALOR  := nValorS //* nTxMoeda                              //NCF - 11/12/2017
      M->E2_VLCRUZ := Round(NoRound(xMoeda(nValorS,nMoedSubs,1,cEmissao,IF("SW6" $ cOrigem .OR. "SWB" $ cOrigem,TamSX3("E2_TXMOEDA")[2],3),nTxMoeda),3),2)
//    M->E2_VLCRUZ := nValorS * IF(nTxMoeda>0,nTxMoeda,1)
   ELSE
      M->E2_VLCRUZ := nValorS
   ENDIF
   IF cOrigem == "SWD_ADI" // Geracao dos titulos base de adiantamento == "S" pelo botao prestacao de contas
      M->E2_HIST   := cHistorico
   ENDIF
   If !Empty(cNatureza) .And. Empty(M->E2_NATUREZ)//NCF - 27/04/2010 - (Se atribuir vazio, não é possível digitar a natureza)
      M->E2_NATUREZ := cNatureza // ACB - 10/02/2010 - chamado 717096
   EndIf
   //NCF - 09/06/2010
   If "SWB" $ cOrigem .AND. ALLTRIM(cTipo_Tit) == "PA"
      cBancoAdt	  := SWB->WB_BANCO
      cAgenciaAdt := SWB->WB_AGENCIA
      cNumCon	  := SWB->WB_CONTA
      If Empty(cCheque) .Or. lNGerChqAd 
         cChequeAdt  := "" /*SWB->WB_CA_NUM TDF-06/08/10*/
      Else
         cChequeAdt  := &cCheque
      EndIf
      cHistor	  := cHistorico
      If lBenef .And. !lNGerChqAd
         SW2->(dbSetOrder(1),dbSeek(xFilial("SW2")+AvKey(AllTrim(SWB->WB_HAWB),"W2_PO_NUM")))
         cBenef	:= &cCampoBnf
      EndIf
   EndIf

ENDIF

//LGS-28/10/13 - Quando a Inclusão do Titulo for a partir de uma alteração na despesa, as informações da despesa levo para o titulo.
lDespesa  := IF(TYPE("lDespesa")<>"L",.F.,lDespesa)
If nTipOp == "I" .And. "SWD" $ cOrigem  
   If lDespesa == .T.
      M->E2_EMISSAO := M->WD_EMISSAO
      M->E2_VALOR   := M->WD_VALOR_R
      M->E2_FORNECE := M->WD_FORN
      M->E2_LOJA    := M->WD_LOJA
      M->E2_NATUREZ := If( Empty(M->E2_NATUREZ) .and. ! empty(M->E2_FORNECE) ,Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_NATUREZ"),M->E2_NATUREZ) //NCF - 08/09/2017 - Inicializa a Natureza do Fornecedor se estiver em branco.
   Else   //NCF - 30/06/2020 - Na inclusão de despesa pelo rotina de despesas do desembaraço, reinicializar os campos carregados na f ina050.
      M->E2_MOEDA   := 1
      M->E2_TXMOEDA := 0
      M->E2_VENCTO  := cToD("  /  /  ")
      M->E2_VENCREA := cToD("  /  /  ")
   EndIf
EndIf

FI400ExecutaValid() //TDF - 22/08/11
IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400INCTIT"),) // Jonato
Inclui := lInclui
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsBxE2Eic ºAutor  ³Bruno Sobieski      º Data ³  11/14/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se alguma das parcelas de um titulo foi baixada      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPrefixo : Prefixo do titulo                               º±±
±±º          ³ cNum 		:	Numero das duplicatas                          º±±
±±º          ³ cTipo    : Tipo do titulo                                  º±±
±±º          ³ cFornece : Fornecedor                                      º±±
±±º          ³ cLoja    : Loja                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEIC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IsBxE2Eic(cPrefixo,cNum,cTipo,cFornece,cLoja,lSWD,cParcela)//ASR 17/10/2005
Local aArea	:=	GetArea()
Local lBaixa:=	.F.
DEFAULT lSWD := .F.
//Acertar tamahos dos STR
cNum		:=	Alltrim(cNum)		+Replicate(" ",TamSX3("E2_NUM"		)[1]	- Len(Alltrim(cNum    )))
cPrefixo	:=	Alltrim(cPrefixo)	+Replicate(" ",TamSX3("E2_PREFIXO"	)[1] 	- Len(Alltrim(cPrefixo)))
cTipo		:=	Alltrim(cTipo)		+Replicate(" ",TamSX3("E2_TIPO"		)[1]	- Len(Alltrim(cTipo   )))
cFornece 	:=	Alltrim(cFornece)	+Replicate(" ",TamSX3("A2_COD"		)[1]	- Len(Alltrim(cFornece)))
cLoja 		:=	Alltrim(cLoja)		+Replicate(" ",TamSX3("A2_LOJA"		)[1]	- Len(Alltrim(cLoja   )))
cParcela	:=	Alltrim(cParcela)	+Replicate(" ",TamSX3("E2_PARCELA"	)[1]	- Len(Alltrim(cParcela)))//ASR 17/10/2005

If cPaisLoc == "ARG" .AND. cTipo # "PR" .AND. cTipo # "PRE"//AWR 08/07/2003
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Se exitir o campo WD_SE_DOC igualar ao campo E2_PREFIXO                     ³
	//³	Caso tipo do titulo "INV" o campo E2_PREFIXO deve ser vazio	  			   ³
	//³ Itens 51, 52 e 53 da planilha de pendentes da Filial Argentina.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrefixo == "EIC"
       cPrefixo := &(EasyGParam("MV_2DUPREF"))
       IF cPrefixo = NIL // AWR
          cPrefixo := ""
       ENDIF
	EndIf
	// AWR - O SWD TEM QUE ESTAR POSICIONADO CERTO
	If lSWD .AND. SWD->(FieldPos("WD_SE_DOC")) > 0
	   If !Empty(SWD->WD_SE_DOC)
	      cPrefixo := SWD->WD_SE_DOC
	   EndIf
	EndIf
	If cTipo == "INV"
       cPrefixo := Space(LEN(SE2->E2_PREFIXO))
	EndIf
EndIf

DbSelectArea("SE2")
DbSetOrder(6)

If SE2->(dbSeek(xFilial()+cFornece+cLoja+cPrefixo+cNum))
   While SE2->(!EOF()).And. xFilial("SE2")+cFornece+cLoja+cPrefixo+cNum+cPArcela == ;//ASR 17/10/2005
					SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA) ;//ASR 17/10/2005
					.And. !lBaixa
		If cTipo	==	SE2->E2_TIPO	.And. SE2->E2_VALOR <> SE2->E2_SALDO
			lBaixa	:=	.T.
		Endif
		//SVG - 03/05/2011 -
		If cTipo ==	SE2->E2_TIPO .And. AllTrim(cTipo) == "PA"
           //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
           SE5->(dbSetOrder(7))
           If SE5->(dbSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
    	      If !Empty(SE2->E2_BAIXA) //DFS - 13/10/11 - Inclusão de tratamento para verificar se o título foi baixado no Financeiro.
    	         lBaixa :=	.T.
    	      EndIf
           EndIf
        EndIf
   		SE2->(DbSkip())
	Enddo
Endif

RestArea(aArea)
Return lBaixa

*************************************
Static Function NumTit(cAlias,cCampo)
*************************************
Local cNum := ""

IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"
   cNum:=AvgNumSeq(cAlias,cCampo)
ELSE
   If EasyGParam("MV_EICNUMT",,"1") == "2"
      cNum:=GetSXENum("SE2","E2_NUM")
   Else
      cNum:=GetSXENum(cAlias,cCampo)
   EndIf

   ConfirmSX8()
ENDIF

Return cNum

//TRP-17/09/08- Função responsável pela busca de PA(s), para realizar o cancelamento das mesmas.
*----------------------------*
Static Function FI400PesqPA()
*----------------------------*
Local oDlg, oCmb1
Local nLin := 5, nInc
Local cInd := Space(200), cChave := FI400SetChave(Nil, "TRB")
Local aInd := {}
Local lSetOrder := .T.
Local cAlias := "TRB"

Local aIndex := {}

   //aAdd(aIndex, {"WD_FORN+WD_LOJA+WD_DOCTO", "Fornecedor+Loja+Documento", 1})
   aAdd(aIndex, {"WD_HAWB", "Processo", 2})

   For nInc := 1 To Len(aIndex)
      aAdd(aInd, aIndex[nInc][2])
   Next

   Define MsDialog oDlg Title STR0123 From 0,0 To 100,407 Of oMainWnd Pixel //STR0123 "Pesquisa"

   @ nLin+1, 03 Say STR0124 Pixel Size 170,6 //STR0124 "Ordem:"
   @ nLin, 30 ComboBox oCmb1 Var cInd Items aInd On Change cChave := FI400SetChave(cChave, cAlias, cInd, aIndex) Pixel Size 170,6
   nLin+= 15
   @ nLin+1, 03 Say STR0125 Pixel Size 170,6 //STR0125 "Chave:"
   @ nLin, 30 MsGet cChave Pixel Size 170,6
   nLin+= 15

   Define SButton oButton1 From nLin,03 Type 1 Action (FI400PesqReg(cAlias, cChave, cInd, lSetOrder, aIndex), oDlg:End()) Enable
   Define SButton oButton2 From nLin,35 Type 2 Action oDlg:End() Enable

   @ nLin, 70 CheckBox lSetOrder Prompt STR0126 Size 120, 08 Pixel Of oDlg //STR0126 "Aplicar a ordem selecionada na tabela"

   Activate MsDialog oDlg Centered

Return Nil

//TRP-17/09/08- Função responsável pelos índices utilizados na busca.
*----------------------------------------------------------*
Static Function FI400SetChave(cChave, cAlias, cInd, aIndex)
*----------------------------------------------------------*
Local nPos, nLen := 200
Default cChave := ""

   If ValType(cInd) == "C"
      If (nPos := aScan(aIndex, {|a| a[2] == cInd })) > 0
         nLen := Len((cAlias)->&(aIndex[nPos][1]))
      EndIf
   ElseIf Len((cAlias)->(IndexKey())) > 0
      nLen := Len((cAlias)->&(IndexKey()))
   EndIf
   cChave := IncSpace(cChave, nLen, .F.)

Return cChave

//TRP-17/09/08- Função responsável pelo retorno do registro buscado.
*--------------------------------------------------------------------*
Static Function FI400PesqReg(cAlias, cChave, cInd, lSetOrder, aIndex)
*--------------------------------------------------------------------*
Local aOrd := SaveOrd(cAlias)
Local nRecno := (cAlias)->(Recno())

   (cAlias)->(FI400OrderByDesc(cInd, aIndex))
   If !(cAlias)->(DbSeek(AllTrim(cChave)))
      MsgInfo(STR0127, STR0128) //STR0127 "Registro não encontrado" //STR0128 "Aviso"
      (cAlias)->(DbGoTo(nRecno))
   EndIf

If !lSetOrder
   RestOrd(aOrd, .F.)
EndIf
Return Nil

//TRP-17/09/08- Função responsável pela ordenação a partir do índice selecionado.
*----------------------------------------------*
Static Function FI400OrderByDesc(cDesc, aIndex)
*----------------------------------------------*
Local nPos
Default cDesc := ""

   If (nPos := aScan(aIndex, {|aOrders| aOrders[2] == cDesc })) > 0
      (Alias())->(DbSetOrder(aIndex[nPos][3]))
   EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------//
//   Função      : BuscaPA()                                                                                          //
//   Objetivo    : Localiza o título PA para o mesmo FORN+MOEDA                                                       //
//   Autor       : EOB                                                                                               //
//   Data        : 03/2009                                                                                        //
//--------------------------------------------------------------------------------------------------------------------//
*-------------------------------------------*
Function BuscaPA(cforn,cmoeda,nRegTRB,cLoja,cFilSWB,cPoNum)
*-------------------------------------------*
Local nRecTRB  := TRB->(Recno())
Local nOrdTRB  := TRB->(IndexOrd())
//Local cFilSWB  := xFilial("SWB")
Local lRetorno := .F., nI:= 0
DEFAULT nRegTRB := 0
DEFAULT cLoja := ""
DEFAULT cFilSWB  := xFilial("SWB")
DEFAULT cPoNum := ""
BEGIN SEQUENCE

IF nRegTRB > 0
   TRB->(dbGoto(nRegTRB))
ELSE
   TRB->(dbgotop())
ENDIF

DO WHILE TRB->(!EOF())
   //NCF - 04/06/2020 - Posiciona o tipo de Adiant 
   IF Left(TRB->WB_TIPOREG,1) == "P" .AND. TRB->WB_MOEDA == cMoeda .AND. TRB->WB_FORN == cForn .AND. (!EICLOJA() .OR. TRB->WB_LOJA == cLoja)
      cPoNum := If(Empty(cPoNum),TRB->WB_NUMPO,cPoNum)
      IF SWB->(dbSeek( cFilSWB + cPoNum + "A" + TRB->WB_INVOICE + TRB->WB_FORN + TRB->WB_LOJA + TRB->WB_LINHA  ))
	      lRetorno := .T.
         BREAK
      ElseIf SWB->(dbSeek(cFilSWB + cPoNum + "F" + TRB->WB_INVOICE + TRB->WB_FORN + TRB->WB_LOJA + TRB->WB_LINHA ))
	      lRetorno := .T.
         BREAK
      ElseIf SWB->(dbSeek(cFilSWB + cPoNum + "C" + TRB->WB_INVOICE + TRB->WB_FORN + TRB->WB_LOJA + TRB->WB_LINHA ))
	      lRetorno := .T.
         BREAK
      EndIf
   EndIf
   TRB->(dbSkip())
ENDDO

IF !lRetorno .AND. TYPE("aParcAdi") == "A"
   FOR nI:=1 TO LEN(aParcAdi)
       IF aParcAdi[nI,1] == cForn .AND. aParcAdi[nI,2] == cMoeda .AND. (!EICLOJA() .OR. aParcAdi[nI,6] == cLoja)
          cNumPO := aParcAdi[nI,3]
          cLinha := aParcAdi[nI,4]
          cContrat := aParcAdi[nI,5]
     	  IF SWB->(dbSeek(cFilSWB+cNumPO))
	         DO WHILE SWB->WB_FILIAL == cFilSWB .AND. ALLTRIM(SWB->WB_HAWB) == ALLTRIM(cNumPO)
//	            IF SWB->WB_PO_DI == "A" .AND. SWB->WB_LINHA == cLinha .AND. SWB->WB_CA_NUM == cContrat
	            IF (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C") .AND. SWB->WB_LINHA == cLinha .AND. SWB->WB_CA_NUM == cContrat	// GCC - 28/08/2013
   	               lRetorno := .T.
                   BREAK
	            ENDIF
	            SWB->(dbSkip())
             ENDDO
          ENDIF
       ENDIF
   NEXT
ENDIF

END SEQUENCE

TRB->(DbGoto(nRecTRB))
TRB->(dbSetOrder(nOrdTRB))
Return lRetorno

/*
Funcao....: FI400GetDAS()
Objetivo..: Retornar o numero da DAs que estão sendo nascionalizadas
            através da DI de Nascionalização.
Parêmetros: cDINasc = Código do Processo da DI de Nascionalização.
Autor.....: Alessandro Alves Ferreira
Data......: 30/11/2009
*/
*****************************
Function FI400GetDAS(cDINasc)
*****************************
Local aDAs := {}
Local aPOs := {}
Local cAliasQry, cQuery, cOldAlias
Local i
Local lTop
Default cDINasc := SW6->W6_HAWB

#IFDEF TOP
   lTop := .T.
#ENDIF

If lTop
   cOldAlias := Alias()
   cAliasQry := "EIC_DAS"
   If Select(cAliasQry) > 0
      (cAliasQry)->(dbCloseArea())
   EndIf

   cQuery:= "select distinct W2_HAWB_DA HAWB_DA "+;
            "from "+RetSqlName("SW2")+" SW2 inner join "+RetSqlName("SW7")+" SW7 on W2_PO_NUM = W7_PO_NUM "+;
            "where W7_HAWB = '"+cDINasc+"' and not W2_HAWB_DA = '"+space(len(SW2->W2_HAWB_DA))+"' "

   dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)

   Do While !Eof()
      aAdd(aDAs,HAWB_DA)
      dbSkip()
   EndDo

   (cAliasQry)->(dbCloseArea())

   If !Empty(cOldAlias)
      dbSelectArea(cOldAlias)
   EndIf
Else
   SW7->(dbSetOrder(1))// TDF - 23/10/2010
   SW7->(dbSeek(xFilial("SW7")+AvKey(cDINasc,"W7_HAWB")))//TDF - 23/10/2010
   Do While SW7->(!Eof()) .AND. Left(SW7->W7_HAWB,Len(cDINasc)) == cDINasc//TDF - 23/10/2010

      If SW7->(aScan(aPOs,{|X| X == W7_PO_NUM})) == 0
         aAdd(aPOs,SW7->W7_PO_NUM)
      EndIf

      SW7->(AvSeekLast(xFilial("SW7")+cDINasc+SW7->W7_PO_NUM))

      SW7->(dbSkip())
   EndDo

   SW2->(dbSetOrder(1))
   For i := 1 To Len(aPOs)
      If SW2->(dbSeek(xFilial("SW2")+aPOs[i])) .AND. SW2->(aScan(aDAs,{|X| X == W2_HAWB_DA})) == 0
         aAdd(aDAs,SW2->W2_HAWB_DA)
      EndIf
   Next i
EndIf

Return aClone(aDAs)

/*
Funcao....: FI400GetDIsNa()
Objetivo..: Retornar o numero da DIs de nascionalização
            que utilizam determinada DA.
Parêmetros: cHawbDA = Código do Processo da DA.
Autor.....: Alessandro Alves Ferreira
Data......: 30/11/2009
*/
Function FI400GetDIsNa(cHawbDA)
Local aDIsNasc := {}
Local cAliasQry, cQuery, cOldAlias

SW6->(dbSetOrder(1),dbSeek(xFilial("SW6")+cHawbDA))
cNumDA := "DA"+SW6->W6_DI_NUM+"/"

#IFDEF TOP
   cOldAlias := Alias()
   cAliasQry := "EIC_DI_NAS"
   If Select(cAliasQry) > 0
      (cAliasQry)->(dbCloseArea())
   EndIf

   cQuery:= "select distinct W7_HAWB HAWB_DINAS "+;
            "from "+RetSqlName("SW7")+" SW7 "+;
            "where W7_FILIAL = '"+xFilial("SW7")+"' AND W7_PO_NUM like '"+cNumDA+"%' and D_E_L_E_T_ = ' ' "

   dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)

   Do While !Eof()
      aAdd(aDIsNasc,HAWB_DINAS)
      dbSkip()
   EndDo

   (cAliasQry)->(dbCloseArea())

   If !Empty(cOldAlias)
      dbSelectArea(cOldAlias)
   EndIf
#ELSE
   SW7->(dbSetOrder(2))//W7_FILIAL+W7_PO_NUM+W7_HAWB
   SW7->(dbSeek(xFilial("SW7")+cNumDA))
   Do While SW7->(!Eof() .AND. Left(W7_PO_NUM,Len(cNumDA)) == cNumDA)

      If SW7->(aScan(aDIsNasc,{|X| X == W7_HAWB})) == 0
         aAdd(aDIsNasc,SW7->W7_HAWB)
      EndIf

      SW7->(AvSeekLast(xFilial("SW7")+W7_PO_NUM+W7_HAWB))

      SW7->(dbSkip())
   EndDo
#ENDIF

Return aClone(aDIsNasc)

/*
Funcao     : FI400Comp()
Parametros : cOrigem
Retorno    :
Objetivos  :
Autor      : Jean Victor Rocha
Data/Hora  : 15/02/2010
*/
*--------------------------------*
Static Function FI400Comp(cOrigem)
*--------------------------------*
Local aOrd   := SaveOrd("SWB")
Local nRecPA := 0
Local nInc   := 0
Local lSair  := .F.
Local nTaxaCM:= 0
Local dDtCot := CTOD("")
Local nRecInv
Local aRecPA := {}
Private nTaxaPE := 0 //LRS 12/11/2014

//LRS - 11/05/2017
cDtBxCmp := EasyGParam("MV_DTBXCMP",," ")
dDtBxCmp := CTOD("")

If cOrigem == "ESTORNO" .And. lAdVinculado .And. Type("aEstComp") == "A"
//Ao chegar aqui, o sistema está com a TRB posicionada sempre em uma parcela INV
//Esta função é chamada uma vez para cada INV

   For nInc := 1 To Len(aEstComp)
      //Verifica todos os PAs excluidos
      //Se um PA relacionado ao INV atual tiver sido excluido, estorna a compensação
      If AllTrim(aEstComp[nInc][1]) == AllTrim(TRB->(WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA))
         If SE2->(dbSeek(MultxFil("SE2", aEstComp[nInc][5]) + aEstComp[nInc][3]))
            aAdd(aRecPA,{SE2->(Recno())})
         EndIf
         nRecInv := aEstComp[nInc][2]
      EndIf
   Next
   If Len(aRecPA) > 0
      SE2->(DbGoTo(nRecInv)) //SE2 do INV
      If !FinCmpAut({nRecInv},,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,aRecPA) //estorno da vinculacao
         Return .F.
      EndIf
   EndIf
   lSair := .T.
EndIf

//Busca o título INV no SE2
IF !lSair .and. ;
    SE2->(DBSEEK(MultxFil("SE2", SWB->WB_FILIAL)+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA))   
   If cOrigem == "ESTORNO"
      nRecEst := SE2->(RECNO())
      IF BuscaPA(SWB->WB_FORN,SWB->WB_MOEDA)
         cPAEst := AvKey(SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA,"E5_DOCUMEN")
         //MFR  OSSME-3726 02/09/2019
		 If findfunction('FINCMPAUT')
			If !FinCmpAut({nRecEst},,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,{{cPAEst}})
            Return .F.
         EndIf
		 Else
			If !MaIntBxCP(2,{nRecEst},,/**/,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,{{cPAEst}})
            Return .F.
         EndIf
		 EndIf
      ENDIF
   Else
      SW6->(DBSetOrder(1))//W6_FILIAL+W6_HAWB
      SW9->(DBSetOrder(1))//W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
      SW6->(DBSeek(xFilial("SW6") + SWB->WB_HAWB))
      SW9->(dbSeek(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB", "WB_LOJA")+SWB->WB_HAWB))        
      nTaxaCM  := SW9->W9_TX_FOB  
      if EasyGParam("MV_EIC0013")
         dDtCot := &(FI400DtEmInvCpo())
         nTaxaCM  := BuscaTaxa(TRB->WB_MOEDA,dDtCot)
         //nTaxaCM  := BuscaTaxa(TRB->WB_MOEDA,&(EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")))
      EndIf   
      IF !EMPTY(cDtBxCmp) // param MV_DTBXCMP
         dDtBxCmp := &(cDtBxCmp)
      ENDIF
      IF EMPTY(dDtBxCmp)
         //dDtBxCmp := dDatabase
         //TDF - 03/04/12 - Enviar data de emissao da Invoice, eu não enviar a data base (Ajuste feito para variação cambial)
		   // GCC - 23/12/2013 - Quando parâmetro estiver .T. irá trazer a data base para baixa do titulo, caso contrário data de emissão da invoice
		   If EasyGParam("MV_EIC0040",,.F.)
		 	   dDtBxCmp := dDataBase
         Else
         	dDtBxCmp := &(FI400DtEmInvCpo())
         EndIf             
      ENDIF
      nRecSe2  := SE2->(RECNO())
      IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400Comp_dDtBxCmp"),) // SVG - 11/08/2011 -
      nValComp :=  xMoeda( IF(lAdVinculado, nValComp, SWB->WB_PGTANT), SE2->E2_MOEDA, 1, dDtBxCmp)
      nTaxaPE := nTaxaCM

	  IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,{"MUDA_TAXA",nTaxaPE}),)// LRS 05/11/2014

	  nTaxaCM := nTaxaPE

      If lAdVinculado
         //Posiciona o SWB no adiantamento
         //If SWB->(dbSeek(xFilial("SWB")+TRB->WB_NUMPO+"A"+TRB->WB_INVOICE+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_LINHA))
         //If SWB->(dbSeek(If(Type("lAdtMultfil")=="L" .And. lAdtMultfil,TRB->WB_FILORI,xFilial("SWB"))+TRB->WB_NUMPO+SWA->WA_PO_DI+TRB->WB_INVOICE+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_LINHA))
		 IF BuscaPA(TRB->WB_FORN,TRB->WB_MOEDA,TRB->(RecNo()),TRB->WB_LOJA,If(Type("lAdtMultfil")=="L" .And. lAdtMultfil,TRB->WB_FILORI,xFilial("SWB")),TRB->WB_NUMPO)
		       //Posiciona no título do adiantamento
                If SE2->(DBSEEK(MultxFil("SE2", SWB->WB_FILIAL)+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA))
			        nRecPA := SE2->(Recno())
					//MFR  OSSME-3726 02/09/2019
					If findfunction('FINCMPAUT')
						If !FinCmpAut({nRecSE2},{nRecPA},{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,TRB->WB_PGTANT,dDtBxCmp,SWB->WB_CA_TX,nTaxaCM)
                     Return .F.
                  EndIf        
					Else
						If !MaIntBxCP(2,{nRecSE2},,{nRecPA},,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,/*nValComp*/,dDtBxCmp,nTaxaCM)
                     Return .F.
                  EndIf
					EndIf
			    EndIf
         EndIf
      Else
         If BuscaPA(SWB->WB_FORN,SWB->WB_MOEDA) .AND. SE2->(DBSEEK(xFilial("SE2")+SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA))
            nRecPA := SE2->(Recno())
            //MFR  OSSME-3726 02/09/2019
			If findfunction('FINCMPAUT')
				If !FinCmpAut({nRecSE2},{nRecPA},{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,dDtBxCmp,SWB->WB_CA_TX,nTaxaCM)
               Return .F.
            EndIf
			Else
				If !MaIntBxCP(2,{nRecSE2},,{nRecPA},,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,/*nValComp*/,dDtBxCmp,nTaxaCM)
               Return .F.
            EndIf
			EndIf
         EndIf
      EndIf
   EndIf
ENDIF

RestOrd(aOrd, .T.)
Return .T.

/*
Funcao     : FI400ValSWD()
Parametros :
Retorno    : Logico, referente a validação do tipo do título, .T. caso o tipo título seja "NF" e
             .F. caso o tipo do título seja diferente disto.
Objetivos  : Validar o tipo do titulo do financeiro (contas a pagar), inclusão feita na rotina "Despesas-
             Prestação de Contas (botão) - Gera NF's para a baixa do PA"
Autor      : Ivo Santana Santos
Data/Hora  : 19/05/2010
*/
*--------------------------------*
FUNCTION FI400ValSWD()
*--------------------------------*

   If AllTrim(M->E2_TIPO) $ "PA" .Or. FI400ValTpO(M->E2_TIPO)
      MsgInfo(STR0129, STR0128) //STR0129 "Tipo do Título inválido." //STR0128 "Aviso"
      Return .F.
   EndIf

Return .T.

/*
Funcao     : FI400ValTpT()
Parametros :
Retorno    : Logico, referente a validação do tipo do título, .T. caso o tipo original do título não seja "PA" e
             .F. caso contrário. A verificação é feita na tabela "Tipos de Título" do Financeiro.
Objetivos  : Validar o tipo original do titulo do financeiro (contas a pagar), inclusão feita na rotina "Despesas-
             Prestação de Contas (botão) - Gera NF's para a baixa do PA"
Autor      : Nilson César C. Filho
Data/Hora  : 07/07/2010
*/
*-----------------------------*
FUNCTION FI400ValTpO(cTipoTitl)
*-----------------------------*

Local aOrdSES := SaveOrd({"SES"})
Local lRet := .F.
Private lTipoValido := .F.  // RMD - 01/11/2012

   SES->(DbSetOrder(2))
   IF SES->(DbSeek(xFilial()+AvKey("PA","ES_TIPO")))
      IF SES->ES_TIPO $ AvKey(cTipoTitl,"ES_TIPO")
         lRet := .T.
      ENDIF
   ENDIF
   //MFR OSSME-3823 09/10/2019
   If !lRet 
      lRet := (Alltrim(cTipoTitl) $ "PR,PRE")
   EndIf   

   If EasyEntryPoint("EICFI400")
      lTipoValido := lRet
      Execblock("EICFI400",.F.,.F.,"VAL_TIPO_PA")
      lRet := lTipoValido
   EndIf
   RestOrd(aOrdSES)
Return lRet

/******************************************************************************************
FUNÇÃO     : FI400EstBxPA()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Permitir o Estorno da Prestação de Contas no Financeiro(Títulos NF)
Autor      : Nilson César C. Filho
Data/Hora  : 09:00 - 08/02/2010
*******************************************************************************************/
*--------------------------------------------------*
FUNCTION FI400EstBxPA()
*--------------------------------------------------*

LOCAL cFilSWD:=xFilial('SWD')
LOCAL nCont:=0
LOCAL I
LOCAL aDesp_Est := {}
LOCAL cPrefix, cTipo
LOCAL cNumDup, cParc_WD, cForn, cLoja
LOCAL aOrdSE2 := {}
LOCAL cMsgGer  := cMsgEst := cMsgEst2 := ""
LOCAL cMsgEst3 := cMsg_Est4:= ""
Local cTexto       := ''
Local cFile        := ""
Local cMask        := "Arquivos Texto (*.TXT) |*.txt|"
Local cLogNF       := ""
Local nVlEstrFin   := 0
Local lGravou      := .T.   //TRP-TDF - 25/11/11
Local nInd         :=0

IF MsgYesNo(STR0130) //STR0130 "Deseja estornar as despesas de adiantamento ?"

   ProcRegua(4)
   SYB->(DBSETORDER(1))
   SWD->(DBSETORDER(1))
   SA2->(DBSETORDER(1))

   SWD->(DBSEEK(cFilSWD+SW6->W6_HAWB))
   DO While SWD->(!Eof()) .AND. cFilSWD == SWD->WD_FILIAL .AND.;
            SWD->WD_HAWB == SW6->W6_HAWB

      IF nCont > 4
         ProcRegua(4)
      ENDIF
      nCont++
      IncProc()

      IF SWD->WD_DESPESA $ '101,901,902,903'
         SWD->(dbSkip())
         LOOP
      ENDIF

      IF !EMPTY(SWD->WD_CTRFIN1) .AND.;
         !EMPTY(SWD->WD_FORN)   .AND.;
         !EMPTY(SWD->WD_LOJA)   .AND.;
         SWD->WD_BASEADI $ cSim
         AADD(aDesp_Est, {SWD->(RECNO()),SWD->WD_CTRFIN1,.T.} )
      ENDIF

      SWD->(dbSkip())
   ENDDO

   ProcRegua(LEN(aDesp_Est)+1)
   IncProc()

   FOR I := 1 TO LEN(aDesp_Est)

      SWD->(DBGOTO(aDesp_Est[I][1]))
      cChave  :=SWD->WD_PREFIXO+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
      cCodFor :=TRB->WD_FORN
      cLojaFor:=TRB->WD_LOJA

      DBSELECTAREA("SE2")

      SE2->(DBSETORDER(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
      IF SE2->(DBSEEK(xFilial()+cChave))
         //DeleDupEIC(cPrefixo,cNum,nParcela,cTipo,cFornece,cLoja,cOrigem,lSWD,cParcela)
         //MFR OSSME-3823 09/10/2109 
         IF (Alltrim(SE2->E2_TIPO) $ "PR,PRE")
            aRet := DeleDupEIC(SE2->E2_PREFIXO,SE2->E2_NUM,1,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_ORIGEM,.F.,SE2->E2_PARCELA)
            FOR nInd:=1 TO len(aRet)
                if aRet[nInd,2] # 0
                   lGravou := .f.
                   exit
                EndIf   
            Next
         Else   
            bExecuta:={||nPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Delet")}) ,;
                       lGravou:=FA050Delet("SE2",SE2->(RECNO()),IF(nPosRot=0,5,nPosRot)), If(ValType(lGravou) <> "L", lGravou := .F., ) }
            SE2->(Fina050(,,,bExecuta))
         EndIf

         //TRP-TDF - 25/11/11
         If !lGravou
            aDesp_Est[I][3]:= .F.
         Endif

      ELSE
        cMsg_Est4 += STR0131+; //STR0131 "Despesa não encontrada no Financeiro:"
                     STR0132+SWD->WD_CTRFIN1+CHR(13)+CHR(10)+; //STR0132 "Título No:"
                     STR0133+SWD->WD_TIPO+CHR(13)+CHR(10)+; //STR0133 "Tipo.....:"
                     STR0134+SWD->WD_PARCELA+CHR(13)+CHR(10)+; //STR0134 "Parcela..:"
                     STR0135+SWD->WD_DESPESA+CHR(13)+CHR(10)+; //STR0135 "Despesa..:"
                     STR0136+Alltrim(STR(SWD->WD_VALOR_R))+CHR(13)+CHR(10) //STR0136 "Valor....:" //FDR - 09/10/12 - Convertido valor do campo para caracter
      ENDIF

      //FDR - 04/04/2013
      IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400Est_Desp"),)

   NEXT I

   aOrdSE2 := SaveOrd({"SE2"})

   cMsgEst  := STR0137+CHR(13)+CHR(10) //STR0137 "As Despesas de Adiantamento:"
   cMsgEst2 := ""
   FOR I := 1 TO LEN(aDesp_Est)
      SWD->(DbGoTo(aDesp_Est[I][1]))
      cPrefix := AvKey("EIC"  ,"E2_PREFIXO")
      cTipo   := AvKey("NF"   ,"E2_TIPO")
      cNumDup := AvKey(SWD->WD_DOCTO  ,"E2_NUM")
      cParc_WD:= AvKey(SWD->WD_PARCELA,"E2_PARCELA")
      cForn   := AvKey(SWD->WD_FORN   ,"E2_FORNECE")
      cLoja   := AvKey(SWD->WD_LOJA   ,"E2_LOJA")
      SE2->(DbSetOrder(1))
      IF SE2->(DbSeek( xFilial("SE2")+cPrefix+cNumDup+cParc_WD+cTipo+cForn+cLoja ))
         IF SE2->E2_TIPO == AvKey("NF","E2_TIPO") .And. SE2->E2_SALDO <> SE2->E2_VALOR
            cMsgEst3 += STR0073+SWD->WD_DESPESA+STR0138+CHR(13)+CHR(10)//STR0073  "Despesa: " //STR0138 " Não Estornada: Possui baixa no Financeiro"
         ENDIF
      ELSE

         //TRP-TDF - 25/11/11
         If aDesp_Est[I][3] == .T.
            SWD->(RECLOCK("SWD",.F.))
            SWD->WD_PARCELA:= Space(Len(SWD->WD_PARCELA))
            SWD->WD_TIPO   := Space(Len(SWD->WD_TIPO))
            SWD->WD_PREFIXO:= Space(Len(SWD->WD_PREFIXO))
            SWD->WD_CTRFIN1:= Space(Len(SWD->WD_CTRFIN1))
            SWD->WD_DOCTO  := Space(Len(SWD->WD_DOCTO))
            SWD->WD_DTENVF := CTOD("  /  /  ")
            SWD->WD_GERFIN := "2"                         //NCF - 19/08/2011 - Permitir alteração da despesa após estorno
            SWD->(MSUNLOCK())

            cMsgEst2 += SWD->WD_DESPESA+" / "


            TRB->(DBSEEK(SWD->WD_HAWB+SWD->WD_DESPESA))
            DO WHILE !TRB->(eof()) .AND. TRB->WD_HAWB == SWD->WD_HAWB .AND. TRB->WD_DESPESA == SWD->WD_DESPESA
               IF TRB->RECNO == SWD->(RECNO())
                  TRB->WD_PARCELA:= Space(Len(SWD->WD_PARCELA))
                  TRB->WD_TIPO   := Space(Len(SWD->WD_TIPO))
                  TRB->WD_PREFIXO:= Space(Len(SWD->WD_PREFIXO))
                  TRB->WD_CTRFIN1:= Space(Len(SWD->WD_CTRFIN1))
                  TRB->WD_DOCTO  := Space(Len(SWD->WD_DOCTO))
                  TRB->WD_DTENVF := CTOD("  /  /  ")
                  TRB->WD_GERFIN := "2"                  //NCF - 19/08/2011 - Permitir alteração da despesa após estorno
                  nVlEstrFin += TRB->WD_VALOR_R
               ENDIF
               TRB->(DBSkip())
            ENDDO
         ENDIF
      ENDIF
   NEXT I

   IF LEN(cMsgEst2) > 0
      If(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,{"FI400_ESTORNO_BAIXA_PA", aDesp_Est}),)  
      cMsgEst += cMsgEst2
      cMsgEst += CHR(13)+CHR(10)+STR0139 //STR0139 "Foram estornadas do Financeiro"
   ELSE
      cMsgEst := STR0140 //STR0140 "Nenhuma Despesa foi Estornada"
   ENDIF

   RestOrd(aOrdSE2)

   cLogNF := cMsgGer+CHR(13)+CHR(10)+cMsgEst+CHR(13)+CHR(10)+;
             cMsgEst3+CHR(13)+CHR(10)+cMsg_Est4

   cTexto := STR0141+CHR(13)+CHR(10)+cTexto //STR0141 "Log da Geração"
   __cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

   Define FONT oFont NAME "Mono AS" Size 6,12   //6,15
      Define MsDialog oDlg Title STR0142 From 3,0 to 340,417 Pixel //STR0142 "Log do Estorno"

      @ 5,5 Get oMemo  Var cLogNF MEMO Size 200,145 Of oDlg Pixel
      oMemo:bRClicked := {||AllwaysTrue()}
      oMemo:oFont:=oFont

      Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
      Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
   Activate MsDialog oDlg Center
ENDIF

RETURN .T.

/******************************************************************************************
FUNÇÃO     : FI400InfoTit(cPrefixTit,cNumTit,cFornTit,cLojaTit,cTipoTit)
Parametros : cPrefixTit - Prefixo do Titulo
             cNumTit    - Numero do Titulo
             cFornTit   - Fornecedor do titulo
             cLojaTit   - Loja do Titulo
             cTipoTit   - Tipo do Titulo
Retorno    : aInfoTit - Array contendo informações do título
             aInfoTit[1] -> "EU" - Existe Título de parcela única
                            "EP" - Existe e possui mais de uma parcela
                            "NE" - Não existe o título referente a chave
             aInfoTit[2] -> Última parcela do título quando aInfoTit[1] -> "EP"
                            Caso contrário, retorna NIL nesta posição
Objetivos  : Retornar se o título existe, se é unico e possui parcelas bem como a ultima parcela
Autor      : Nilson César C. Filho
Data/Hora  : 09:00 - 08/02/2010
*******************************************************************************************/
FUNCTION FI400InfoTit(cPrefixTit,cNumTit,cFornTit,cLojaTit,cTipoTit)

Local aInfoTit   := {}
Local cPrefixo   := AvKey(cPrefixTit,"E2_PREFIXO")
Local cNumero    := AvKey(cNumTit, "E2_NUM")
Local cFornecedor:= AvKey(cFornTit,"E2_FORNECE")
Local cLoja      := AvKey(cLojaTit,"E2_LOJA")
Local cTipo      := AvKey(cTipoTit,"E2_TIPO")
Local nParcela   := 0

SE2->(DbSetOrder(1))
IF SE2->(DbSeek(  xFilial("SE2")+cPrefixo+cNumero   ))
   WHILE SE2->(!EOF()) .AND. SE2->E2_PREFIXO == cPrefixo .AND. SE2->E2_NUM == cNumero
      IF SE2->E2_TIPO <> cTipo
         SE2->(DBSKIP())
         LOOP
      ENDIF
      IF SE2->E2_FORNECE <> cFornecedor
         SE2->(DBSKIP())
         LOOP
      ENDIF
      IF SE2->E2_LOJA <> cLoja
         SE2->(DBSKIP())
         LOOP
      ENDIF
      nParcela++
      aInfoTit := {"EU",SE2->E2_PARCELA,1}
      IF nParcela > 1
         aInfoTit := {"EP",SE2->E2_PARCELA,nParcela}
      ENDIF
      SE2->(DBSKIP())
   ENDDO

   IF LEN(aInfoTit) == 0
      aInfoTit := {"NE",NIL}
   ENDIF
ELSE
   aInfoTit := {"NE",NIL}
ENDIF

Return aInfoTit


/*
Funcao  : FI400Parcs()
Autor   : Diogo Felipe dos Santos
Data    : 03/06/11
Objetivo: Verificar o número de parcelas na condição de pagamento e tratar os possíveis envios.
*/

*--------------------*
Function FI400Parcs()
*--------------------*
Local nParcs := 0

SX3->(DbSetOrder(2))
If SX3->(DbSeek("Y6_PERC_01"))
   While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
      nParcs ++
      SX3->(DbSkip())
   EndDo
EndIf

Return nParcs

/*
Funcao  : FI400ExecutaValid()
Autor   : Tamires Daglio Ferreira
Data    : 22/08/11
Objetivo: Executa as funçoes chamadas no X3_VALID do campo E2_VALOR. Desta forma, atualiza os valores na tela de inclusão do título.
*/
*-----------------------------------------*
Function FI400ExecutaValid(nOpc)
*-----------------------------------------*
Local lGeraMovimentoPA:= EasyGParam("MV_EIC0019",,.T.)//TDF - 29/10/2012 - Permite configurar geração de movimento bancário para PA
Local nValor := 0
Local nValTit:= 0 // LGS - 29/06/2016
Local aPFin050 := {}
Default nOpc := 0

Private nX1Altera := nOpc //THTS - 01/08/2017

If Type("lMicrosiga") <> "L" //LGS-01/02/2016
   lMicrosiga := EasyGParam("MV_EASYFIN",,"N") $ cSim
EndIF

If nOpc == 0
   nValor := M->E2_VLCRUZ // GFP - 12/11/2013
   nValTit:= M->E2_VALOR  // LGS - 29/06/2016
   FA050NAT2() //aqui calcula o IR na inclusao
   FA050VALOR()
   //TRP - 15/09/2011 - Chamado 088466 - Não gerar Movimentação Bancária para um PA que esteja vinculado a um contrato de financiamento.
   If "SWB" $ cOrigem .AND. ALLTRIM(cTipo_Tit) == "PA"
      If lEFFTpMod .and. lEIC_EFF .and. lWB_EVENT .and. Select("TRB") > 0 .and. EF3->(dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+TRB->WB_HAWB+TRB->WB_FORN+TRB->WB_LOJA+TRB->WB_INVOICE+If(Empty(TRB->WB_PARFIN),TRB->WB_LINHA,TRB->WB_PARFIN)+EV_EMBARQUE))
         //Pergunte(SX1) - FIN050
         mv_par05 := 2  //Gera Chq. p/ Adiant? - Não
         mv_par09 := 2  //Mov. Banc. Sem Cheque? - Não
         cChequeAdt:= ""  //Caso o número do Cheque esteja preenchido sempre será gerada Movimentação Bancária de um PA.
      ElseIF lMicrosiga .and. lGeraMovimentoPA
         //TDF - 31/05/2012 - Para toda inclusão de PA vindo do EIC os parâmetros do contas a pagar no financeiro devem estar configurados conforme abaixo.
         mv_par05 := 2  //Gera Chq. p/ Adiant? - Não
         mv_par09 := 1  //Mov. Banc. Sem Cheque? - Sim
      EndIf
   EndIf
   If M->E2_VLCRUZ <> nValor  // GFP - 12/11/2013
      M->E2_VLCRUZ := nValor
   EndIf
   If M->E2_VALOR == 0 .And. M->E2_VALOR <> nValTit  // LGS - 29/06/2016
      M->E2_VALOR := nValTit
   EndIf
   If M->E2_SALDO <> nValTit //MCF - 15/08/2016      
      M->E2_SALDO := nValTit       
   EndIF
//MPG - 11/09/2015
ElseIf nOpc == 1 .And. lMicrosiga .And. lGeraMovimentoPA //.And. SX1->(DbSeek("FIN050"))
   Pergunte("FIN050",.F.,,,,, @aPFin050)
   aFIN050 := aClone(aPFin050)
   
   MV_PAR05 := 2
   MV_PAR09 := 1

   __SaveParam("FIN050", aPFin050)

ElseIf nOpc == 2 .And. lMicrosiga .And. lGeraMovimentoPA //.And. SX1->(DbSeek("FIN050"))
   //THTS - 01/08/2017
   Pergunte("FIN050",.F.,,,,, @aPFin050)

   MV_PAR05 :=  aFin050[ascan(aFin050, {|x| upper(alltrim(x[14])) == "MV_PAR05" })][5]
   MV_PAR09 :=  aFin050[ascan(aFin050, {|x| upper(alltrim(x[14])) == "MV_PAR09" })][5]

   __SaveParam("FIN050", aPFin050)
EndIf
Return .T.

/*
Funcao      : UPDX1FI400
Objetivos   : Ajustar o X1_PRESEL
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data 	    : 01/08/2017
Obs         :
*/
Static Function UPDX1FI400(o)
Local nI

If nX1Altera == 1
    o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_PRESEL'  })
    o:TableData('SX1'  ,{'FIN050'  ,"05"      ,"2"          })
    o:TableData('SX1'  ,{'FIN050'  ,"09"      ,"1"          })
ElseIf nX1Altera == 2
    o:TableStruct('SX1'  ,{'X1_GRUPO','X1_ORDEM'    ,'X1_PRESEL'   })
    For nI := 1 To Len(aFIN050)
        o:TableData('SX1',{'FIN050'  ,aFIN050[nI,1] ,aFIN050[nI,2] })
    Next
EndIf

Return

/*
Funcao  : FI400CalculaFOB()
Autor   : TAMIRES DAGLIO FERREIRA
Data    : 15/10/12
Objetivo: Recalcula o FOB do PO, verificando os itens com saldo eliminado e abatendo do total.
*/
*----------------------------------------------------*
Function FI400CalculaFOB(cPO_Num)
*----------------------------------------------------*
Local nFob:= 0
Local nVlEliminado:= 0
Local nValFre := nValSeg := 0

IF SW2->(FieldPos("W2_FREINC")) > 0 .AND. SW2->W2_FREINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE") //"CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
   If SW2->(FieldPos("W2_FRETEIN")) > 0
      nValFre := SW2->W2_FRETEIN
   EndIf
EndIF
IF SW2->(FieldPos("W2_SEGINC")) > 0 .AND. SW2->W2_SEGINC $ "2" .AND. AvRetInco(SW2->W2_INCOTER,"CONTEM_SEGURO")
   If SW2->(FieldPos("W2_SEGURIN")) > 0
      nValSeg := SW2->W2_SEGURIN
   EndIf
ENDIF
                                                            // 10/08/2021 OSSME-6096 MFR
nFob:= ( SW2->W2_FOB_TOT + SW2->W2_INLAND + SW2->W2_PACKING + SW2->W2_OUT_DES + nValFre + nValSeg ) - SW2->W2_DESCONT //NCF - 04/01/2016

SW3->(DBGOTOP())
SW3->(dbSeek(xFilial("SW3")+cPO_Num))
While SW3->(!Eof()) .And. SW3->W3_FILIAL == xFilial("SW2") .And. SW3->W3_PO_NUM == cPO_Num

   nVlEliminado:= SW3->W3_SLD_ELI * SW3->W3_PRECO

   nFob-= nVlEliminado

   SW3->(DbSkip())

EndDo

Return nFob

/*
Funcao  : FI400SetCPag()
Autor   : Guilherme Fernandes Pilan - GFP
Data    : 22/03/2013 - 14:35
Objetivo: Sistema deve verificar se Cond. Pagamento de Frete e Seguro possui cobertura cambial para gerar titulos NF.
*/
*-----------------------------*
Static Function FI400SetCPag(cDesp)
*-----------------------------*
Local lRet := .T.
Local cCondPag := If(cDesp == "FRETE", "W6_CONDP_F", If(cDesp == "SEGURO", "W6_CONDP_S", "") )

Begin Sequence

if Type("M->"+cCondPag) == "U"
   if SW6->(FieldPos(cCondPag)) > 0
      cCondpag := "SW6->"+cCondPag
   Else
      BREAK
   EndIf
Else
   cCOndPag := "M->"+cCondPag
Endif

SY6->(DbSetOrder(1))
If SY6->(DBSEEK(xFilial("SY6")+&(cCondPag)))
   lRet := !SY6->Y6_TIPOCOB == "4"       // Sem Cobertura Cambial
EndIf

End Sequence

Return lRet

/*
Funcao  : FI400VAlInv()
Autor   : Guilherme Fernandes Pilan - GFP
Data    : 25/11/2013 :: 18:00
Objetivo: Função para preenchimento das variaveis lAltodasInvoice e lReturn após passagem no ponto de entrada FI400DIAlterou
*/
*-----------------------------*
Static Function FI400VAlInv()
*-----------------------------*
   //ASK- 30/07/07 - Verifica se foi alterada a Data de Vencimento do título, conforme sua ordem de preenchimento
   //** PLB 19/09/07 - Adição de campos para Data de vencimeento de título
   If SW6->W6_DT_ENTR # M->W6_DT_ENTR  // Data da Entrega
      lReturn := .T.
   ElseIf SW6->W6_PRVENTR # M->W6_PRVENTR  // Previsão de Entrega
      lReturn := .T.
   //**
   ElseIf SW6->W6_DT_DESE # M->W6_DT_DESE //Data do Desembaraço
      lReturn := .T.
   ElseIf SW6->W6_PRVDESE # M->W6_PRVDESE // Previsão do Desembaraço
      lReturn := .T.
   ElseIf SW6->W6_CHEG # M->W6_CHEG // Data de Atracação
      lReturn := .T.
   ElseIf SW6->W6_DT_ETA # M->W6_DT_ETA // Data Prevista de Atracação
      lReturn := .T.
   ElseIf SW6->W6_DT_EMB # M->W6_DT_EMB // Data de Embarque
      lAltodasInvoice:=.T. // SVG - 03/03/2011 - Para a geração das parcelas de cambio, pois afeta na data de vencimento do titulo no financeiro.
      lReturn := .T.
   ElseIf SW6->W6_DT_ETD # M->W6_DT_ETD // Data Prevista de Embarque
      lReturn := .T.
   EndIf
   IF SW6->W6_DESP # M->W6_DESP
      lRETURN:= .T.
   ENDIF

Return NIL

/*
Funcao     : GeraTitCamb()
Parametros : cTipo - Frete ou Seguro, cOperacao - nOpc
Retorno    : NIL
Objetivos  : Geração de titulos de contas a pagar referente as parcelas de cambio de frete e seguro do processo.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 01/06/2015 :: 11:29
/*/
*--------------------------------------------*
Static Function GeraTitCamb(cTipo,cOperacao)
*--------------------------------------------*
Local aOrd := SaveOrd({"SWB","SA2","SE2"}), aRetInfTit := {}
Local nOrd := SA2->(IndexOrd()), nRec := SA2->(Recno())
Local cNatureza := "", cParcela := "", cIniDocto := "", cHistorico := ""
Local nMoedSubs := SimbToMoeda(SWB->WB_MOEDA), nTxMoeda := 0, nValorS := SWB->WB_FOBMOE
Local lRetF050 := .F.
Local dDtEmiss
Private aFIN050 := {}
Private lMsErroAuto := .F., lF050Auto := .T.
Private aTit := {} //LRS - 30/03/2016

Pergunte("EICFI5",.F.)
IF(!EMPTY(MV_PAR02), cNatureza  := MV_PAR02 ,)

Begin Sequence

   If Empty(cNatureza)
      SA2->(dbSetOrder(1))
      If SA2->(dbSeek(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))
         cNatureza := SA2->A2_NATUREZ
      EndIf
      SA2->(dbSetOrder(nOrd),dbGoTo(nRec))
   EndIf
   IF SX1->(DBSEEK("EICTMB"+Space(4)))
	   Pergunte("EICTMB",.F.)
	   IF !EMPTY(MV_PAR01)
		   cAutMotbx := ALLTRIM(MV_PAR01)
	   ENDIF
   ENDIF
   If cTipo == "FRETE"
      nTxMoeda := SW6->W6_TX_FRET
   ElseIf cTipo == "SEGURO"
      nTxMoeda := SW6->W6_TX_SEG
   EndIf
   cIniDocto := SWB->WB_NUMDUP

   If Empty(cIniDocto)
      cIniDocto := NumTit("SW9","W9_NUM")
   EndIf   

   aRetInfTit := FI400InfoTit("EIC",cIniDocto,SWB->WB_FORN,SWB->WB_LOJA,"INV")
   If aRetInfTit[1] <> "NE"
      If aRetInfTit[1] == "EU"
         IF FindFunction("AvgNumSeq") .AND. EasyGParam("MV_EICNUMT",,"1") == "1"
            IF cTipo == "FRETE"
               cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPF")) # 0, AvgNumSeq("SW6","W6_NUMDUPF"), " ")  //M->E2_NUM
            ELSEIf cTipo == "SEGURO"
               cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPS")) # 0, AvgNumSeq("SW6","W6_NUMDUPS"), " ")  //M->E2_NUM
            ENDIF
         ELSE
             IF cTipo == "FRETE"
                cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPF")) # 0, GetSXENum("SW6","W6_NUMDUPF"), " ")  //M->E2_NUM
             ELSEIf cTipo == "SEGURO"
                cIniDocto := IF(SW6->(FieldPos("W6_NUMDUPS")) # 0, GetSXENum("SW6","W6_NUMDUPS"), " ")  //M->E2_NUM
             ENDIF
             ConfirmSX8()
         ENDIF
      Else
         cParcela := EasyGetParc(aRetInfTit[3])
      EndIf
   EndIf
   If Empty(cParcela)
      cParcela := EasyGetParc(1)
   EndIf

   cHistorico := "P: " + AllTrim(SWB->WB_HAWB) + " " + AllTrim(SWB->WB_INVOICE)
	dDtEmiss := FI400DTRefTaxa(,,.F.,.F.) //THTS - 14/08/2019 - Data de Emissao
   aTit:={}
   If cOperacao == "2" // INCLUSAO
      nOpcAu := 3
      AADD(aTit,{"E2_NUM"    ,cIniDocto                        ,NIL})
      AADD(aTit,{"E2_PREFIXO","EIC"                            ,NIL})
      AADD(aTit,{"E2_PARCELA",cParcela                         ,NIL})
      AADD(aTit,{"E2_TIPO"   ,"INV"                            ,NIL})
      AADD(aTit,{"E2_NATUREZ",cNatureza                        ,NIL})
      AADD(aTit,{"E2_FORNECE",SWB->WB_FORN                     ,NIL})
      AADD(aTit,{"E2_LOJA"   ,SWB->WB_LOJA                     ,NIL})
      AADD(aTit,{"E2_EMISSAO",dDtEmiss                        	,NIL})
      AADD(aTit,{"E2_VENCTO" ,SWB->WB_DT_VEN                   ,NIL})
      AADD(aTit,{"E2_VENCREA",DataValida(SWB->WB_DT_VEN,.T.)   ,NIL})
      AADD(aTit,{"E2_VENCORI",SWB->WB_DT_VEN                   ,NIL})
      AADD(aTit,{"E2_VALOR"  ,nValorS                          ,NIL})
      AADD(aTit,{"E2_EMIS1"  ,dDataBase                        ,NIL})
      AADD(aTit,{"E2_MOEDA"  ,nMoedSubs                        ,NIL})
      AADD(aTit,{"E2_VLCRUZ" ,Round(NoRound(xMoeda(nValorS,nMoedSubs,1,dDtEmiss,3,nTxMoeda),3),2),NIL})
      AADD(aTit,{"E2_TXMOEDA",nTxMoeda                         ,NIL})
      AADD(aTit,{"E2_HIST"   ,cHistorico                       ,NIL})
      AADD(aTit,{"E2_ORIGEM" ,"SIGAEIC"                        ,NIL})
   ElseIf cOperacao == "4" // EXCLUSAO
      nOpcAu := 5
      SWB->(DBSETORDER(1))
      IF SWB->(FIELDPOS("WB_LOJA"))#0    .AND. !EMPTY(SWB->WB_LOJA)    .AND.;
        SWB->(FIELDPOS("WB_TIPOTIT"))#0 .AND. !EMPTY(SWB->WB_TIPOTIT) .AND. ;
         SWB->(FIELDPOS("WB_PREFIXO"))#0
         cChave := SWB->WB_PREFIXO+SWB->WB_NUMDUP+SWB->WB_PARCELA+SWB->WB_TIPOTIT+SWB->WB_FORN+SWB->WB_LOJA
      ELSE
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN))
         cChave := "EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SA2->A2_LOJA
      ENDIF

      SE2->(DBSETORDER(1))
      SE2->(DBSEEK(xFilial("SE2")+cChave))

      AADD(aTit,{"E2_NUM"    ,SE2->E2_NUM               ,NIL})
      AADD(aTit,{"E2_PREFIXO",SE2->E2_PREFIXO           ,NIL})
      AADD(aTit,{"E2_PARCELA",SE2->E2_PARCELA           ,NIL})
      AADD(aTit,{"E2_TIPO"   ,SE2->E2_TIPO              ,NIL})
      AADD(aTit,{"E2_NATUREZ",SE2->E2_NATUREZ           ,NIL})
      AADD(aTit,{"E2_FORNECE",SE2->E2_FORNECE           ,NIL})
      AADD(aTit,{"E2_LOJA"   ,SE2->E2_LOJA              ,NIL})
      AADD(aTit,{"E2_EMISSAO",SE2->E2_EMISSAO           ,NIL})
      AADD(aTit,{"E2_VENCTO" ,SE2->E2_VENCTO            ,NIL})
      AADD(aTit,{"E2_VENCREA",SE2->E2_VENCREA           ,NIL})
      AADD(aTit,{"E2_VENCORI",SE2->E2_VENCORI           ,NIL})
      AADD(aTit,{"E2_VALOR"  ,SE2->E2_VALOR             ,NIL})
      AADD(aTit,{"E2_EMIS1"  ,SE2->E2_EMIS1             ,NIL})
      AADD(aTit,{"E2_MOEDA"  ,SE2->E2_MOEDA             ,NIL})
      AADD(aTit,{"E2_VLCRUZ" ,SE2->E2_VLCRUZ            ,NIL})
      AADD(aTit,{"E2_TXMOEDA",SE2->E2_TXMOEDA           ,NIL})
      AADD(aTit,{"E2_HIST"   ,SE2->E2_HIST              ,NIL})
      AADD(aTit,{"E2_ORIGEM" ,SE2->E2_ORIGEM            ,NIL})

   EndIf
   //LRS - 30/03/2016 - Ponto de entrada para editar o aTit
   IF(EasyEntryPoint("EICFI400"),Execblock("EICFI400",.F.,.F.,"FI400EDIT_ATIT"),)

   lMsErroAuto:=.F.
   
   FI400ExecutaValid(1)
   Pergunte("EICFI4",.F.)
   MSExecAuto({|a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)}, aTit, 3, nOpcAu, Nil, Nil,MV_PAR02 == 1, MV_PAR01 == 1)
   If Len(aFIN050) <> 0
      FI400ExecutaValid(2)
   EndIf
   If lMsErroAuto
      If type("oErrorFin") == "O"
         If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
            oErrorFin:Error(MemoRead(NomeAutoLog()))
         EndIf
      Else
         MOSTRAERRO()
      EndIf
      If cTipo == "FRETE"
         lAltFrete := .F.
      ElseIf cTipo == "SEGURO"
         lAltSeguro := .F.
      EndIf
   Else
      lRetF050 := .T.
      If cOperacao == "2"
         cAutMotbx := If(Type("cAutMotbx")<>"C", "", cAutMotbx)
         If SWB->(RecLock("SWB",.F.))
            SWB->WB_NUMDUP  := cIniDocto
            SWB->WB_PARCELA := cParcela
            SWB->WB_TIPOTIT := "INV"
            SWB->WB_PREFIXO  := "EIC"
            SWB->(MsUnlock())
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)
Return lRetF050
/*
Programa   : FI400EAITitulo()
Objetivo   : Excluir as parcelas de câmbio antecipado via EAI
Parâmetros :
Retorno    : Lógico - indica se os títulos no ERP foram excluídos (.T.).
Autor      : WFS
Data       : 01/2015
Observação :
*/
Function FI400EAITitAnt()
Local lRet:= .T.

Begin Sequence

   /* tratar somente a exclusão do câmbio antecipado */
   If M->WA_PO_DI <> "A"
      Break
   EndIf

   TRB->(DBGoTop())
   aEAIDeletados:= {}

   While TRB->(!Eof())

      If !Empty(TRB->WB_NUMDUP)
         AAdd(aEAIDeletados, {"SWB", TRB->WB_RECNO})
      EndIf

      TRB->(DBSkip())
   EndDo

   If Len(aEAIDeletados) > 0
      lRet:= EICAP110(.T., 5, SWA->WA_HAWB, "A",, .T.)
   EndIf

End Sequence

Return lRet
/*
Funcao                     : MultxFil
Parametros                 : Alias, filial de origem
Retorno                    : filial de destino
Objetivos                  : verificar a filial para uso em cenários com multi-filial
Autor       			      : wfs
Data/Hora   			      : mar/2016
Revisao                    :
Obs.                       :
*/
Static Function MultxFil(cAlias, cFilOrigem)
Local cFilDestino:= ""

Begin Sequence

   If FWModeAccess(cAlias, 3) == "E" .AND. !Empty(cFilOrigem)
    //If Type("lMultiFil") <> "U" .And. lMultiFil
        cFilDestino:= cFilOrigem
        Break
   // EndIf
   EndIf

   cFilDestino := xFilial(cAlias)

   /*
   If Type("lMultiFil") <> "U" .And. !lMultiFil
      cFilDestino:= cFilOrigem
      Break
   EndIf

   If Posicione("SX2", 1, cAlias, "X2_MODO") == "E"
      cFilDestino := cFilOrigem
   Else
      cFilDestino := xFilial(cAlias)
   EndIf
   */

End Sequence

Return cFilDestino

/*
Funcao                     : GerAutoSI
Parametros                 :
Retorno                    : lógico
Objetivos                  : Verificar se a chamada tem origem na inclusão de um P.O. via geração automática pela S.I.
                             Funcionalidade disponível quando habilitada a integração EAI.
                             Neste momento não haverá tabela de pré-cálculo a ser considerada.
Autor                      : wfs
Data/Hora                  : mar/2017
Revisao                    :
Obs.                       :
*/
Static Function GerAutoSI()
Local lRet:= .F.
Static lCallSI410

Begin Sequence

   If ValType(lCallSI410) <> "L"
      lCallSI410:= IsInCallStack("EICSI410")
   EndIf

   //Se é inclusão e a chamada foi a partir da Solicitação de Importação
   lRet:= Type("INCLUI") == "L" .And. INCLUI .And. lCallSI410

End Sequence

Return lRet

/*
Funcao                     : FI400DTRefTaxa
Parametros                 :
Retorno                    : Data de referência para apuração da taxa do câmbio da invoice
Objetivos                  : Verificar qual é o campo de referência, com base no parâmetro MV_DTB_APD, para definição da data
                             a ser considerada na apuração da taxa do câmbio da invoice.                                                          
Autor                      : wfs
Data/Hora                  : 09/jun/2017
Revisao                    :
Obs.                       : O tratamento foi movido para esta função, evitando duplicação de código
*/
Function FI400DTRefTaxa(cAliasSW6, cAliasSW9, lDataBase, lDataSW9)
Local cDatEmb:= ""
Local dDtEMB
Default cAliasSW6:= "SW6"
Default cAliasSW9:= "SW9"
Default lDataBase:= .T.
Default lDataSW9 := .T.

Begin Sequence

   cDatEmb := AllTrim(EasyGParam("MV_DTB_APD",, "SW6->W6_DT_EMB"))
   If Empty(cDatEmb)
      cDatEmb:= "SW6->W6_DT_EMB"
   EndIf
   
   //se o conteúdo do parâmetro MV_DTB_APD estiver vazio, assume a data do embarque
   If "W6_DT_EMB" $ cDatEmb
      If Empty(&cDatEmb)
         cDatEmb := "SW6->W6_DT_ETD" // NCF 13/05/09  - Pega a data ETD se a data de Embarque não
      EndIf
   EndIf
   If lDataSW9
        If SubStr(cDatEmb, 4, 2) == "->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
            If Left(cDatEmb, 3) == "SW6"
                dDtEMB:= &(cAliasSW6 + "->" + Right(cDatEmb, Len(cDatEmb)-5))
            ElseIf Left(cDatEmb,3) == "SW9"
                dDtEMB:= &(cAliasSW9 + "->" + Right(cDatEmb, Len(cDatEmb)-5))
            EndIf
        ElseIf SubStr(cDatEmb, 3, 1) == "_" //Caso o conteúdo do parâmentro possuir apenas o campo
            If Left(cDatEmb, 2) == "W6"
                dDtEMB := &(cAliasSW6 + "->" + cDatEmb )
            ElseIf Left(cDatEmb,2) == "W9"
                dDtEMB := &(cAliasSW9 + "->" + cDatEmb )
            EndIf
        EndIf
   Else
		If SubStr(cDatEmb, 4, 2) == "->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
			If Left(cDatEmb, 3) == "SW6"
				dDtEMB:= &(cAliasSW6 + "->" + Right(cDatEmb, Len(cDatEmb)-5))
			EndIf
		ElseIf SubStr(cDatEmb, 3, 1) == "_" //Caso o conteúdo do parâmentro possuir apenas o campo
			If Left(cDatEmb, 2) == "W6"
					dDtEMB := &(cAliasSW6 + "->" + cDatEmb )
			EndIf
		EndIf
	EndIf

   If Empty(dDtEMB)
      dDtEMB:= &(cAliasSW6 + "->W6_DT_EMB")
      //Se a data do embarque não tiver sido informada, assume a previsão de embarque
      If Empty(dDtEMB)
         dDtEMB:= &(cAliasSW6 + "->W6_DT_ETD")
         //Se a previsão de embarque estiver vazia, assume a data base
         If Empty(dDtEMB) .And. lDataBase
            dDtEMB:= dDataBase
         EndIf
      EndIf
   EndIf

End Sequence

Return dDtEMB


/*
Funcao                     : FI400DtEmInvCpo()
Parametros                 :
Retorno                    : Campo que será usado como data de emissão do título do câmbio da invoice
Objetivos                  : Verificar o campo parametrizado como data de emissão do título da invoice
Autor                      : wfs
Data/Hora                  : ago/2017
Revisao                    :
Obs.                       : Usado na integração com o SIGAFIN e via mensagem única - EAI
*/
Function FI400DtEmInvCpo()
Local cCpoData:= ""
Local cAliasCpoData:= ""

Begin Sequence

   cCpoData:= AllTrim(EasyGParam("MV_DTEMIS",, "SW9->W9_DT_EMIS"))
   If Empty(cCpoData)
      cCpoData:= "SW9->W9_DT_EMIS"
   EndIf

   /* Caso o campo não seja referenciado pelo Alias, acrescenta antes de retornar */
   If SubStr(cCpoData, 4, 2) <> "->"
      cAliasCpoData:= RetornaAlias(cCpoData)
      If hasField(cAliasCpoData, cCpoData)
        cCpoData:= cAliasCpoData + "->" + cCpoData
      EndIf
   EndIf

   validMcDt(cCpoData, "MV_DTEMIS", "SW9->W9_DT_EMIS", {|| cCpoData :=  "SW9->W9_DT_EMIS" })

End Sequence

Return cCpoData

Static Function hasField(cAlias, cField)
If(select(cAlias) > 0)
   If (cAlias)->(FieldPos(cField)) > 0
      Return .T.
   EndIf
EndIf
Return .F.

/*
Funcao                     : FI400DtEmAdiCpo()
Parametros                 :
Retorno                    : Campo que será usado como data de emissão do título do câmbio antecipado (câmbio de adiantamento)
Objetivos                  : Verificar o campo parametrizado como data de emissão do título do câmbio antecipado (câmbio de adiantamento)
Autor                      : wfs
Data/Hora                  : ago/2017
Revisao                    :
Obs.                       : Usado na integração com o SIGAFIN e via mensagem única - EAI
*/
Function FI400DtEmAdiCpo()
Local cCpoData:= ""
Local cAliasCpoData:= ""

Begin Sequence

   cCpoData:= AllTrim(EasyGParam("MV_DTEMIPA",, "SWB->WB_DT_DESE"))
   If Empty(cCpoData)
      cCpoData:= "SWB->WB_DT_DESE"
   EndIf

   /* Caso o campo não seja referenciado pelo Alias, acrescenta antes de retornar */
   If SubStr(cCpoData, 4, 2) <> "->"
      cAliasCpoData:= RetornaAlias(cCpoData)
      If hasField(cAliasCpoData, cCpoData)
        cCpoData:= cAliasCpoData + "->" + cCpoData
      EndIf
   EndIf

   validMcDt(cCpoData, "MV_DTEMIPA", "SWB->WB_DT_DESE", {|| cCpoData :=  "SWB->WB_DT_DESE" })
    
End Sequence

Return cCpoData

/*
Funcao                     : RetornaAlias()
Parametros                 : Nome do campo
Retorno                    : Alias do campo
Objetivos                  : Retornar o Alias do campo
Autor                      : wfs
Data/Hora                  : ago/2017
*/
Static Function RetornaAlias(cCampo)
Local cRet:= ""

Begin Sequence

   If Left(cCampo, 1) == "S"
      cRet:= SubStr(cCampo, 1, 3)
   Else
      cRet:= "S" + SubStr(cCampo, 1, 2)
   EndIf

End Sequence

Return cRet

// Validar data e macro expressão
/* Se caso ocorrer erro ao executar a macro &(cCpoData), será exibida uma mensagem
 * que o parâmetro cParam está inválida e o campo padrão será o cField. Ao ocorrer um erro,
 * será executado o bloco de código bError, após exibir a mensagem de erro.
 */
Static Function validMcDt(cCpoData, cParam, cField, bError)
   Local dDataConv
   Local lError

    // Se o bloco do primeiro parâmetro estiver erro na macro expressão, será executado o bloco do terceiro parâmetro
    // Caso ocorra erro de execução no primeiro parâmetro, será exibida uma mensagem
    // Será executado quando ocorrer um erro no bloco do primeiro parâmetro
    lError := custErrBk({||dDataConv := &(cCpoData)}, msgErrBk(cParam, cField), bError)
        
    If !lError .And. ValType(dDataConv) != "D"
        //EasyHelp("O conteúdo do parâmetro " + cParam + " não é do tipo data." + Chr(13) + Chr(10) + "Será utilizado o conteúdo do campo " + cField + ".")
        Eval(bError)
    EndIf
Return

Static Function custErrBk(bBlock, cMsgError, bError)
Local defBlock := ErrorBlock()
Local lError := .T.
ErrorBlock({|e| onError(cMsgError, bError) })
Begin Sequence
    Eval(bBlock)
    lError := .F.
End Sequence
ErrorBlock(defBlock)
Return lError

Static Function msgErrBk(paramName, cField)
Local cMsgError := "ATENÇÃO: A expressão do parâmetro " + paramName + " é inválida." + Chr(13) + Chr(10)
cMsgError += "Será utilizado o conteúdo do campo " + cField + "."
Return cMsgError

Static Function onError(msgError, bError)
Eval(bError)
Return .F.

/*
Função: EICEmpFLogix
Objetivo: Retorna o código da empresa a ser usada nas integrações financeiras com o Logix
Autor: Rodrigo Mendes Diaz
Data: 17/12/20
*/
Function EICEmpFLogix(lContab)
Local cEmpFLogix := SM0->M0_CODIGO
Local cParam, nPosDiv
Default lContab := .F.


   If !Empty(cParam := Alltrim(EasyGParam(If(lContab, "MV_EEC0034", "MV_EEC0036"),,"")))
      If (nPosDiv := At('/',cParam)) > 0
         cEmpFLogix := Substr(cParam,1,nPosDiv-1)
      Else
         cEmpFLogix := cParam
      EndIf  
   EndIf

Return cEmpFLogix

/*
Função: EICFilFLogix
Objetivo: Retorna o código da filial a ser usada nas integrações financeiras com o Logix
Autor: Rodrigo Mendes Diaz
Data: 17/12/20
*/
Function EICFilFLogix(lContab, cDefFil)
Local cFilFLogix := If(cDefFil == Nil, FWFilial(), cDefFil)
Local cParam, nPosDiv
Default lContab := .F.

   If !Empty(cParam := Alltrim(EasyGParam(If(lContab, "MV_EEC0034", "MV_EEC0036"),,"")))
      If (nPosDiv := At('/',cParam)) > 0
         cFilFLogix := Substr(cParam,nPosDiv+1,Len(cParam))
      Else
         cFilFLogix := cParam       
      EndIf  
   EndIf

Return cFilFLogix


//-------------------------------------------------------------------------------------*
//                            FIM DO PROGRAMA EICFI400.PRW
//-------------------------------------------------------------------------------------*
