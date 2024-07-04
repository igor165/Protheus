/*
                              
Programa        : AVCADGE.PRW
Objetivo        :
Autor           : Average Tecnologia S/A
Data/Hora       : 05/04/99 16:17
Obs.            :
*/

#include "EEC.CH" // definicoes para rotinas de Exportacao    
#include "EFF.CH" // definicoes para rotinas do Financiamento 
                  // ja inclui o Average.ch/FiveWin.ch

#include  "AVCADGE.ch"
#include  "Average.ch"
#INCLUDE "FWMVCDEF.CH"

/*
Funcao          : I60TIPO(cTipo)
Parametros      : cTipo:= tipo de condicao de pagto
Retorno         : Nenhum
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            : retirada da EICCAD00.PRW
*/
Function I60Tipo(cTipo)
If cTipo == NIL
   DO CASE
      CASE  M->Y6_TIPO == "2"   ; M->Y6_DIAS_PA:=-1
      CASE  M->Y6_TIPO == "3"   ; M->Y6_DIAS_PA:=901
      CASE  M->Y6_TIPO == "1"   ; M->Y6_DIAS_PA:=0
   ENDCASE
EndIf
Return .T.

/*
Funcao     : EICCambAut()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Varifica se a despesa está configurada para gerar automaticamente ou manualmente
Autor      : Miguel Prado Gontijo
Data/Hora  : 19/11/2019
*/
Function EICCambAut(cDesp)
Local cAux := ""
Local lRet := .F.
Default cDesp := ""

cAux := EasyGParam("MV_CAMBAUT",,"NNN")

If !empty(cDesp) .and. !empty(cAux)
   if cDesp == "701"
      if Substr(cAux,1,1) == "S"
         lRet := .T.
      endif
   elseif cDesp == "702"
      if Substr(cAux,2,1) == "S"
         lRet := .T.
      endif
   elseif cDesp == "703"
      if Substr(cAux,3,1) == "S"
         lRet := .T.
      endif
   endif
endif

Return lRet

/*
Funcao          : EA060VDIAS(nFlag)
Parametros      : nFlag := ?
Retorno         : .T./.F.
Objetivos       : verifica os dias nas parcelas
Autor           : Victor
Data/Hora       :
Revisao         :
Obs.            :
*/
Function EA060VDias(nFlag) // Verifica os dias nas parcelas (Victor)
Local nInd:=0,cCampo:="M->Y6_DIAS_"
Local nParcs := 0

//ER - 04/12/2007 - Verifica se existe mais que 10 parcelas de cambio.
SX3->(DbSetOrder(2))
If SX3->(DbSeek("Y6_PERC_01"))
   While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
      nParcs ++
      SX3->(DbSkip())
   EndDo
EndIf

FOR nInd:=nFlag TO 2 Step -1
   // IF !(nInd=10 .AND. &(cCampo+PADL(nInd,2,'0'))=0)
   IF !(nInd== nParcs .AND. &(cCampo+PADL(nInd,2,'0'))=0) //ER - 04/12/2007
       IF &(cCampo+PADL(nInd,2,'0')) <= &(cCampo+PADL(nInd-1,2,'0')) .AND. ;
          !(&(cCampo+PADL(nInd,2,'0'))=0 .AND. &(cCampo+PADL(nInd+1,2,'0'))=0)
          Help(" ",1,"A110DIAS")
          RETURN .F.
       ENDIF
    ENDIF
NEXT

//FOR nInd:=nFlag TO 9
FOR nInd:=nFlag TO (nParcs-1)
    IF &(cCampo+PADL(nInd,2,'0')) >= &(cCampo+PADL(nInd+1,2,'0')) .AND. ;
       &(cCampo+PADL(nInd+1,2,'0')) # 0
       Help(" ",1,"A110DIAS2")
       RETURN .F.
    ENDIF
NEXT

RETURN .T.

/*
Funcao          : A060MODINS(cFlag)
Parametros      :
Retorno         :
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
Function A060MODINS(cFlag)
IF M->Y6_TIPOCOB='3' .AND. cFlag = 'MODPAG'
   Help(" ",1,"A110NaoPag")
   RETURN .F.
ELSEIF M->Y6_TIPOCOB#'3' .AND. cFlag = 'INSFIN'
   Help(" ",1,"A110NaoFin")
   RETURN .F.
ENDIF
RETURN .T.

/*
Funcao          : EA060VALID()
Parametros      :
Retorno         :
Objetivos       : validar inclusao e alteracao de condicoes de pagamento
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
Function EA060Valid(cFlag)

LOCAL nRec:=SY6->(RECNO()), nInd, nValor:=0, cCampo:="M->Y6_PERC_", cCamp2:="M->Y6_DIAS_"
LOCAL lFlag:=.t.,nValor2:=0
Local nParcs := 0

//ER - 04/12/2007 - Verifica se existe mais que 10 parcelas de cambio.
SX3->(DbSetOrder(2))
If SX3->(DbSeek("Y6_PERC_01"))
   While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
      nParcs ++
      SX3->(DbSkip())
   EndDo
EndIf

IF ! ExistChav("SY6",M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO),0))
   RETURN .F.
ENDIF

IF AT(M->Y6_TIPO,'123') == 0
   Help(" ",1,"A110TipCon")
   RETURN .F.
ENDIF

IF cPaisLoc == "BRA"

DO CASE
   CASE M->Y6_TIPOCOB == '1' .OR. M->Y6_TIPOCOB == '2'
        IF EMPTY(ALLTRIM(M->Y6_TABELA))
           Help(" ",1,"A110ModPag")
           RETURN .F.
        ENDIF
        M->Y6_INST_FI:='  '
        M->Y6_MOTIVO :='  '
   CASE M->Y6_TIPOCOB == '3'
        M->Y6_TABELA :='  '
        M->Y6_MOTIVO :='  '
        IF EMPTY(ALLTRIM(M->Y6_INST_FI))
           Help(" ",1,"A110InsFin")
           RETURN .F.
        ENDIF
   CASE M->Y6_TIPOCOB == '4'
        M->Y6_TABELA :='  '
        M->Y6_INST_FI:='  '
        IF EMPTY(ALLTRIM(M->Y6_MOTIVO))
           HELP("", 1, "AVG0000159") //MSGINFO(STR0001,STR0002) //"Motivo deve ser preenchido"###"Informação"
           RETURN .F.
        ENDIF
ENDCASE

Endif

IF ! I60Tipo(cFlag)
   RETURN .F.
ENDIF

IF ! I60Valid()
   RETURN .F.
ENDIF

IF SY6->(DBSEEK(xFilial("SY6")+M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO),0))) .AND. SY6->(RECNO()) <> nRec
   SY6->(DBGOTO(nRec))
   RETURN .F.
ENDIF

SY6->(DBGOTO(nRec))

IF M->Y6_TIPO <> "3"
   RETURN .T.
ENDIF

//FOR nInd:=1 TO 10
FOR nInd:=1 TO nParcs //ER - 04/12/2007
    IF nInd # 1 .AND. ;
       &(cCamp2+PADL(nInd,2,'0'))=0 .AND. &(cCampo+PADL(nInd,2,'0'))>0 .AND.;
       &(cCamp2+PADL(nInd-1,2,'0'))>=0
       Help(" ",1,"A110DIAS3")
       RETURN .F.
    ENDIF
    nValor+=&(cCampo+PADL(nInd,2,'0'))
    IF &(cCampo+PADL(nInd,2,'0')) = 0
       lFlag:=.f.
    ENDIF
    IF lFlag
       nValor2+=&(cCampo+PADL(nInd,2,'0'))
    ENDIF
NEXT

IF nValor > 100 .or. nValor2 > 100
   Help(" ",1,"A110PERC")
   If type("lValPerc") == "L"
      lValPerc := .F.
   EndIf
   RETURN .F.
ELSEIF nValor < 100 .or. nValor2 < 100
   MsgInfo(STR0120, STR0004)//("A somatória das porcentagens está abaixo de 100%","Atenção!")   //ASK - 07/05/2007
   If type("lValPerc") == "L"
      lValPerc := .F.
   EndIf
   RETURN .F.   
ENDIF

//FOR nInd:=1 TO 10
FOR nInd:=1 TO nParcs //ER - 04/12/2007
    nValor+=&(cCampo+PADL(nInd,2,'0'))
    IF &(cCampo+PADL(nInd,2,'0')) = 0
    &(cCamp2+PADL(nInd,2,'0')) := 0
    ENDIF
NEXT

RETURN .T.

/*
Funcao          : I60Valid()
Parametros      :
Retorno         :
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
Function I60Valid()
*-----------------*
DO CASE
   CASE M->Y6_TIPO == "2"  .AND. M->Y6_DIAS_PA <> -1
        Help(" ",1,"EA200DAV")
        RETURN .F.
   CASE M->Y6_TIPO == "3"  .AND. M->Y6_DIAS_PA <900
        Help(" ",1,"EA200DPA")
        RETURN .F.
   CASE M->Y6_TIPO == "1"  .AND. (M->Y6_DIAS_PA<=-1 .OR. M->Y6_DIAS_PA >900)
        Help(" ",1,"EA200DNO")
        RETURN .F.
ENDCASE
RETURN .T.

/*
Funcao          : SJ5Valid()
Parametros      :
Retorno         :
Objetivos       : validar unidades
Autor           : AVERAGE
Data/Hora       :
Revisao         : Heder 15/12/98 14:13
Obs.            : copia EICCADGE.PRW
*/
Function SJ5Valid(cChave)

   Local lRet:=.T.,nOldArea:=select(),nRec:=SJ5->(RecNo()),nOrderSX3:=SX3->(IndexOrd())
   LOCAL cProcura:=xFilial("SJ5")+M->J5_DE+M->J5_PARA
   If(cChave==nil,cChave := M->J5_PARA,)
   

   SX3->(DBSETORDER(2))
   lExistY5CODI := SX3->(dbSeek("Y5_COD_I"))
   SX3->(DBSETORDER(nOrderSX3))
   
   IF lExistY5CODI
      cProcura+=IF(!EMPTY(M->J5_COD_I),M->J5_COD_I,"")
   ENDIF
   Begin sequence

      If M->J5_DE==M->J5_PARA
         HELP("", 1, "AVG0000160")//MSGINFO(OemToAnsi(STR0003),STR0004) //"Unidades sÆo iguais !"###"Atenção"
         lRet:=.F.
         BREAK
      EndIf

      If !empty(M->J5_PARA)
         If SJ5->(DbSeek(cProcura))
            If Inclui .Or. nRec#SJ5->(RecNo())
               SJ5->(DbGoTo(nRec))
               Help(" ",1,"JAGRAVADO")
               lRet:=.F.
               BREAK
            EndIf
         EndIf
      EndIf

      SJ5->(DbGoTo(nRec))
      lRet:=ExistCpo("SAH",cChave)

   End Sequence

   dbselectarea(nOldArea)

Return lRet

/*
Funcao          : A060TIPOCOB()
Parametros      :
Retorno         :
Objetivos       :
Autor           : Heder M Oliveira
Data/Hora       :
Revisao         :
Obs.            :
*/

Function A060TIPOCOB()

IF UPPER(READVAR()) == "M->Y6_MOTIVO"
   IF !EMPTY(M->Y6_MOTIVO).AND.!SJ8->(DBSEEK(xFilial("SJ8")+M->Y6_MOTIVO))
      HELP("", 1, "AVG0000161")//MSGINFO(OemToAnsi(STR0005),STR0006) //"Motivo nÆo cadastrado"###"Informação"
      RETURN .F.
   ENDIF
   IF M->Y6_TIPOCOB # '4'.AND.!EMPTY(M->Y6_MOTIVO)
      HELP("", 1, "AVG0000162")//MSGINFO(OemToAnsi(STR0007),STR0008)   //"Motivo nÆo pode ser preenchido"###"Informação"
      RETURN .F.
   ENDIF
   RETURN .T.
ENDIF

IF M->Y6_TIPOCOB#'3'
   IF ! EMPTY(ALLTRIM(M->Y6_INST_FI))
      M->Y6_INST_FI:='  '
      M->Y6_INS_DES:=''      
   ENDIF
ELSE
   IF ! EMPTY(ALLTRIM(M->Y6_TABELA))
      M->Y6_TABELA:='  '
      M->Y6_TAB_DES:=''
   ENDIF
ENDIF

IF M->Y6_TIPOCOB # '4'
   M->Y6_MOTIVO := "  "
   M->Y6_MOT_DES:= "  "
ENDIF

lRefresh:=.t.

RETURN .T.


/*
Funcao          : DI400D_VALID()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Validar cadastro de despesas
Autor           : AVERAGE
Data/Hora       :
*/
FUNCTION DI400D_Valid()
LOCAL lRdmake:=EasyEntryPoint("AVCADGE").AND.cModulo=="EIC"
LOCAL aDespVarCamb := {}
LOCAL nPosDesp := 0
PRIVATE lRET:=.T.

// Alterado por Heder M Oliveira - 7/13/1999
BEGIN SEQUENCE

  IF ( nMODULO#29 )//EXPORTACAO NAO USA

     IF M->WD_DESPESA == "101" .OR. M->WD_DESPESA == "104"
        Help(" ",1,"E_DDFOBREG")
        lRET:=.F.
        BREAK
     ENDIF
     
     IF AvFlags("EIC_EAI") //EasyGParam("MV_EIC_EAI",,.F.) 
        
        IF M->WD_DESPESA $ '901 902'   //igor chiba
           MsgInfo(STR0128+; //"Não é possível inserir as despesas de adiantamento através desta funcionalidade."
                   STR0129) //"Para usar as despesas de adiantamento no processo, deve ser utilizada a rotina de Solicitação de Numerários."
        
           lRET:=.F. 
           BREAK
            
         ELSEIF  M->WD_DESPESA == "903"
                     
            M->WD_PAGOPOR := '1'
            M->WD_GERFIN  := '2'
            
         ENDIF  
     ENDIF
          
     IF TRB->(DBSEEK(SW6->W6_HAWB+M->WD_DESPESA))
        IF SUBST(TRB->WD_DESPESA,1,1) < '3'
           Help(" ",1,"E_DDJAHAWB")
           lRET:= .F.
           BREAK
        ENDIF
     ENDIF

     If M->WD_DESPESA $ "701|702|703"
         if EICCambAut(Alltrim(M->WD_DESPESA))
            aDespVarCamb := {{"701","Variação Cambial FOB"},{"702","Variação Cambial FRETE"},{"703","Variação Cambial SEGURO"}}
            nPosDesp     := aScan( aDespVarCamb , {|x| x[1] == Alltrim(M->WD_DESPESA) } )
            MsgInfo( STR0170 + aDespVarCamb[nPosDesp][1] + STR0171 + aDespVarCamb[nPosDesp][2]  )  //Não é possível utilizar o código de despesa ###  
            lRet := .F.                                                                            //uma vez que as mesma é utilizada internamente pelo sistema para registro de ###
            BREAK
         endif
     EndIf                                                                                     

     IF lRdmake
        EXECBLOCK("AVCADGE",.F.,.F.,"VALID_DESPESA")
     ENDIF

  ENDIF

END SEQUENCE

Return lRET

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA060  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Condicoes de Pagto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA060
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SY6" //mjb150999 , nOldArea:=Select()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef("EICA060")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0014        //"Condições de Pagto"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,cAlias)
//mjb150999 DbSelectArea(nOldArea)
Return .T.

*---------------------------------------------------------------------------
Function EA060Manut(cAlias,nReg,nOpc)
*---------------------------------------------------------------------------
// AxInclui(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk,lF3)
// AxAltera(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk)

PRIVATE aMemos:={{"Y6_DESC_P","Y6_VM_DESP"},{"Y6_DESC_I","Y6_VM_DESI"}}

IF nOpc = 3
   AxInclui(cAlias,nReg,nOpc,,,,"EA060Valid('*')")
ELSE
   AxAltera(cAlias,nReg,nOpc,,,,,"EA060Valid('*')")
ENDIF

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³I60Deleta ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Condicoes de Pagto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ I60Deleta(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION I60Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg, oEnch

#IFDEF TOP

   //TRP-30/04/08
   If AvTotReg() > 0
      HELP(" ",1,"EIC060TPO")   
      Return .F.
   Endif

#ELSE
   SW2->(DBSETORDER(3))
   If SW2->(DBSEEK(xFilial("SW2")+SY6->Y6_COD))
      HELP(" ",1,"EIC060TPO")
      SW2->(DBSETORDER(1))
      Return .F.
   EndIf

#ENDIF

SW2->(DBSETORDER(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Envia para processamento dos Gets          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nOpcA:=0
        aTela := {}
        aGets := {}

        RecLock(cAlias,.F.,.t.)

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
        oEnCh:=MsMGet():New( cAlias, nReg, nOpc,,,,,PosDlg(oDlg)) //LRL 20/04/04
        nOpca:= 1
		oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        ACTIVATE MSDIALOG oDlg ON INIT ;
       (EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)) //LRL 20/04/04 - Alinhamento de Telas MDI. //BCO 09/12/11 - Tratamento para acesso ActiveX

        dbSelectArea(cAlias)

        IF nOpcA == 2

           Begin Transaction

                MSMM(SY6->Y6_DESC_P,,,,2)
                MSMM(SY6->Y6_DESC_I,,,,2)
                (cAlias)->(dbDelete())
                (cAlias)->(MsUnlock())
           End Transaction
        Else
                (cAlias)->(MsUnlock())
        EndIf
        Exit
End

dbSelectArea(cAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA150  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do Cadastro de Moedas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA150
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SYF"
Local aFixe 

PRIVATE aRotina := MenuDef("EICA150")

PRIVATE cDelFunc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0020)  //"Cadastro de Moedas"

/*ISS - 21/05/10 - Troca da rotina de cadastro de moedas, da do EIC para a do EEC para que
                   na do EIC seja incluso o idioma da moeda. */
//NOPADO por RRC - 18/04/2013 - Caso queira utilizar o cadastro de moedas da exportação na importação, basta colocar no menu
/*If cPaisLoc == "BRA"
   Return EECAT135()
Endif*/                    

// AST - 14/01/09 - Inclusão do campo YF_MOEFAT quando o SIGAEIC está integrado com SIGACOM
If EasyGParam("MV_EASY") == "S" .Or. EasyGParam("MV_AVG0226",,.F.) //RRC - 01/03/2013 - Verifica parâmetro da Integração do Easy Siscoserv x Financeiro 
   aFixe := {{"MOEDA SIGACOM","YF_MOEFAT"}}
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1, 22, 75 , cAlias , aFixe)
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³I150Deleta³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ I150Deleta(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION I150Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod ,oDlg ,oEnch
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

SYE->(DBSETORDER(2))

If SYE->(DBSEEK(xFilial()+SYF->YF_MOEDA))
   HELP(" ",1,"EIC150TTX")
   SYE->(DBSETORDER(1))
   Return .F.
EndIf

SYE->(DBSETORDER(1))

While .T.
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Envia para processamento dos Gets          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nOpcA:=0
        aTela := {}
        aGets := {}

        RecLock(cAlias,.F.,.t.)

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
        oEnCh:=MsMGet():New( cAlias, nReg, nOpc,,,,,PosDlg(oDlg)) //LRL 02/05/04
        nOpca:= 1
		oEnCh:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        ACTIVATE MSDIALOG oDlg ON INIT ;
        (EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)) //LRL 02/05/04  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

        dbSelectArea(cAlias)

        IF nOpcA == 2

           Begin Transaction

                (cAlias)->(dbDelete())

           End Transaction
           (cAlias)->(MsUnlock())
        Else
           (cAlias)->(MsUnlock())
        EndIf
        Exit
End

dbSelectArea(cAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA160  ³ Autor ³ ALEX WALLAUER         ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de complementos do produto                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION EICA160()
//Parametros: 3o:Validacao no OK da exclusao, 4o:Validacao no OK da alterao e da inclusao
axCadastro("SB5",STR0009,,)//"Atualiza‡Æo de Produtos"
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA030  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Centros de Custo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA030
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SY3"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef("EICA030")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0026)  //"Unidade Requisitante"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,cAlias)
Return .T.

/*---------------------------------------------------------------------------*/
// ACSJ - 14/01/2004
// Grava automaticamente as unidades requisitantes incluidas no SY3 no ECC
Function EICA030Manut(cAlias,nReg,nOpc)
/*---------------------------------------------------------------------------*/
LOCAL cAliasOld := Alias(), lAbre:=.T., nRet

If nOpc == 3
   nRet := AxInclui(cAlias,nReg,nOpc)
Else
   nRet := AxAltera(cAlias,nReg,nOpc)
Endif
  
if nRet == 1
   IF SELECT("ECC") = 0
      IF !ChkFile("ECC",.F.)
         HELP("", 1, "AVG0005369")   //MSGINFO(OemToAnsi(STR0036),STR0037) //"NÆo foi poss¡vel abrir o Arquivo ECC"###"Informação"
         lAbre:=.F.
      ENDIF
   ENDIF
   
   IF lAbre 
      if !ECC->( DBSEEK( xFilial("ECC") + SY3->Y3_COD ) )
         ECC->(RECLOCK("ECC",.T.))
      
         ECC->ECC_FILIAL := xFilial("ECC")
         ECC->ECC_IDENTC := SY3->Y3_COD
         ECC->ECC_DESCR  := SY3->Y3_DESC
         ECC->(MSUNLOCK())
         ECC->(DbCloseArea())
      Endif
   ENDIF

   dbSelectArea(cAliasOld)

ENDIF

Return nOpc
//-------------------------- Fim da Função  ACSJ - 14/01/2004

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EA030Del  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Centros de Custo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EA030Del(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION EA030Del(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod , oDlg

If SW0->(DBSEEK(xFilial("SW0")+SY3->Y3_COD))
   HELP(" ",1,"EIC030TSI")
   Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Envia para processamento dos Gets          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nOpcA:=0
        aTela := {}
        aGets := {}

        RecLock(cAlias,.F.,.T.)

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
	    oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,,,PosDlg(oDlg))
        nOpca:= 1
		oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT 
        ACTIVATE MSDIALOG oDlg ON INIT ;
        (EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


        IF nOpcA == 2

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Antes de deletar eu vou verificar se existe S.I.             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Begin Transaction

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Apos passar por todas as verificacoes , deleta o registro    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                dbDelete()

                (cAlias)->(MsUnlock())
                End Transaction
        Else
                MsUnLock()
        EndIf
        Exit
End

dbSelectArea(cAlias)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICY0100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 28/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Manutencao de Documentos Impressos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICY0100
Local cFiltro := Nil
Local cAlias := "SY0"                         
// ALTERADO POR LUCIANO C.SANTANA - 11/03/2004
// TROCAR A FUNCAO DE PESQUISA DE AVPESQDOC PARA AXPESQUISA
//
// Alterado por Jeferson Barros Jr. - 11/06/2001
// Chamada de AvTipoDoc e AvDocView de acordo com o modulo em execucao 

// ** By JBJ - 01/08/02
//LOCAL cROTDOC:=IF(cMODULO=="EEC","AvTipoDoc","AvDocView")
//LOCAL cROTDOC:=IF(cMODULO=="EEC","EECHistDoc","AvDocView")
//ASK - 30/01/07 Alterado a variavel cROTDOC de LOCAL para PRIVATE para uso do Menu Funcional.
Private cROTDOC:=IF(cMODULO=="EEC","EECHistDoc","AvDocView")

/// LCS-11/03/2004
///PRIVATE aRotina := {{ STR0027 ,"AvPesqDoc" , 0 , 1},;     //"Pesquisar"
///                    { STR0028 , cROTDOC    , 0 , 2}}      //"Visualizar"
PRIVATE aRotina := MenuDef("EICY0100")
PRIVATE cCadastro := OemtoAnsi(STR0029)    //Hist¢rico de Documentos Impressos"
Private lEmbarque := .F.
                   
//***0000000000000000000000000000000***//
DbSelectArea(cAlias)

E_ARQCRW(.T.)//RMD - 25/08/05 - Abre os arquivos necessários para a geração de documentos

//JVR - 20/08/09 - Filtra pelo processo de embarque posicionado quando for chamado do EECAE100.
If "EECAE100" $ PROCNAME(9)              
   //Definição de Filtro
   cFiltro := "Y0_PROCESS = '" + EEC->EEC_PREEMB + "'"
   //Indica que a rotina foi chamada do EECAE100
   lEmbarque := .T.
EndIf

//mBrowse( 6, 1,22,75,"SY0")
mBrowse( 6, 1,22,75,cAlias,,,,,,,,,,,,,,cFiltro)

DbSelectArea("SX3")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA140  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Taxas de Conversao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA140(xaCabAuto, xPar2, nOpcAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SYE"
Private lExecAuto := ValType(xaCabAuto) == "A" .And. ValType(nOpcAuto) == "N" .And. Len(xaCabAuto) > 0 .And. (nOpcAuto == 3 .Or. nOpcAuto == 4)
Private aAutoCab
PRIVATE aRotina := MenuDef("EICA140")
PRIVATE lAlteraSM2 := .T.

PRIVATE cDelFunc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0035  //"Taxas de Conversao"
PRIVATE lTelaContent := .F.

If lExecAuto
   aAutoCab   := xaCabAuto
   If nOpcAuto == 4  
      SYE->(DbSetOrder(1))
      SYE->(DbSeek(xFilial("SYE")+AvKey(aAutoCab[1][2],"YE_DATA")+AvKey(aAutoCab[2][2],"YE_MOEDA")))
   EndIf
   RegToMemory(cAlias, nOpcAuto == 3)   
   MBrowseAuto(nOpcAuto,aAutoCab,cAlias,.F.)
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Endereca a funcao de BROWSE                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   mBrowse( 6, 1,22,75,cAlias)
EndIf

Return .T.


*---------------------------------------------------------------------------*
Function EICA140Manut(cAlias,nReg,nOpc)
*---------------------------------------------------------------------------*
LOCAL cAliasOld := Alias(), lAbre:=.T.
Local cValidOk := "A140Valid("+cValToChar(nOpc)+")"
Local lOk 
Local lIntERP:= ((EasyGParam("MV_EEC0055") $ cSim .Or. Empty(EasyGParam("MV_EEC0055"))) .And. IsIntEnable("001")) .Or. ((EasyGParam("MV_EIC0067",,"N") $ cSim .Or. Empty(EasyGParam("MV_EIC0067",,"N"))) .And. (EasyGParam("MV_EASY",,"N") $ cSim .Or. EasyGParam("MV_EASYFIN",,"N") $ cSim))
Local cEic0067 := AllTrim(EasyGParam("MV_EIC0067",,"")) //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas

If lExecAuto
   If lOk := EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4])
      AxIncluiAuto(cAlias,cValidOk,,nOpc,(cAlias)->(Recno()))//O AxIncluiAuto faz inclusão e alteração, de acordo com nOpc
   EndIf                                                                                                                      
Else
   lOk := ((nOpc=3 .and. AxInclui(cAlias,nReg,nOpc,,,,cValidOk) = 1 ) .or.;
           (nOpc=4 .and. AxAltera(cAlias,nReg,nOpc,,,,,cValidOk) = 1))
EndIf

If lOk

   If EasyEntryPoint("AVCADGE")
      ExecBlock("AVCADGE", .F., .F., {"LOK_VALID"})
   EndIf
   
    IF EasyGParam("MV_ATUTX")
        IF SELECT("ECB") = 0
            IF !ChkFile("ECB",.F.) .And. !lExecAuto
                HELP("", 1, "AVG0000163")//MSGINFO(OemToAnsi(STR0036),STR0037) //"NÆo foi poss¡vel abrir o Arquivo ECB"###"Informação"
                lAbre:=.F.
            ENDIF
        ENDIF
        IF lAbre .and. (SYE->YE_VLCON_C+SYE->YE_TX_COMP) > 0
           If !ECB->(DBSEEK(xFilial("ECB")+DTOS(SYE->YE_DATA)+SYE->YE_MOEDA)) .or. ECB->ECB_TX_CTB = 0 .or. ECB->ECB_TX_EXP = 0
              ECB->(RECLOCK("ECB",ECB->(EOF())))
              ECB->ECB_FILIAL := xFilial("ECB")
              ECB->ECB_DATA   := SYE->YE_DATA
              ECB->ECB_MOEDA  := SYE->YE_MOEDA
              If ECB->ECB_TX_CTB = 0
                 ECB->ECB_TX_CTB := SYE->YE_VLCON_C
              EndIF
              If ECB->ECB_TX_EXP = 0
                 ECB->ECB_TX_EXP := SYE->YE_TX_COMP
              EndIf
              ECB->(MSUNLOCK())
              ECB->(DbCloseArea())
           EndIf
        ENDIF
    ENDIF
    dbSelectArea(cAliasOld)
    

    lAlteraSM2 := if (Upper(cEic0067) == 'N', .F., lAlteraSM2) //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
    
   	If lAlteraSM2 //MCF-30/12/2014 - Variável que determina se Insere na SM2.
   		If lIntERP .And. !EicGrvInt(nOpc = EXCLUIR) //LRS - 19/09/2014 - Replica alterações na tabela SM2
   			MsgInfo(STR0130, STR0110)//"Erro na gravação da taxa na tabela SM2."###"Aviso"
   				While __lSX8
   					RollBackSX8()
   				Enddo
   		Endif
   	Endif
      
	//MCF-30/12/2014 - Sempre passo o valor .T. para manter a variavel
	lAlteraSM2 := If (!lAlteraSM2,.T.,lAlteraSM2)         
ENDIF

Return nOpc

*---------------------------------------------------------------------------------------------*
Function A140Valid(nOpc)
*---------------------------------------------------------------------------------------------*
Local lRet:=.T.

Begin Sequence

   If nOpc=INCLUIR .or. nOpc=ALTERAR
      If M->YE_VLCON_C = 0 .and. M->YE_TX_COMP = 0 .and. M->YE_VLFISCA = 0
         EasyHelp(STR0114) //"Cotação não pode ser salva sem nenhuma taxa. Informe pelo menos uma taxa para cotação." //HELP("", 1, "AVG0005284")
         lRet:=.F.
         Break
      EndIf
      If !Empty(Val(M->YE_MOE_FIN))
         IF (lRet := At140Val(.T.)) //LRS 28/08/2014
      	   lAlteraSM2 := .T.
         Else
      	   lAlteraSM2 := .F.
         EndIf   
      Else 
         lAlteraSM2 := .F.
      ENDIF
   EndIf

End Sequence

Return lRet

/*
Funcao          : AC170DCTPEM()
Parametros      : Nenhum
Objetivos       : Retornar descricao de tipo de agente (SY4)
Autor           : Heder M Oliveira
Data/Hora       : 13/11/98 16:15
Revisao         :
Obs                     :
*/
Function AC170DCTPEM()
    Local lRet:=.T.,cOldArea:=select()
    Begin sequence
                M->EE6_DCTPEM:=AvTabela("Y9",M->EE6_TIPO)
    Endsequence
    dbselectarea(cOldArea)
Return lRet


/*
Funcao          : ValidSYR(lOrigem)
Parametros      : lOrigem:= .T. : valida se origem eh igual a destino jah gravado no TRB
                                            .F. : valida se destino eh igual a destino jah gravado no TRB
Retorno         : .T. se validacao OK
Objetivos       : Nao permitir que Origem e Destino de rotas de vias sejam iguais
Autor           : MJB
Data/Hora       :
Revisao         : HMO 04/12/98
Obs.            : Retirado do EICCV100 (Function CV100VALIDSYR())
*/
Function ValidSYR(lOrigem)
        Local lAchou, lRet:=.T.,nRec,cOldArea:=select()
        default lOrigem := .F.
        Begin sequence

                If lOrigem
                        lAchou := M->YR_DESTINO == M->YR_ORIGEM
                Else
                        lAchou := M->YR_DESTINO == M->YR_ORIGEM
                EndIf

                If lAchou
                        HELP(" ",1,"EA200ORIDE")
                        lRet:=.F.
                        break
                EndIf

                If TRB->(EasyRecCount("TRB")) > 1

                        nRec:=TRB->(RECNO())

                        If lOrigem
                                lAchou := TRB->(DBSEEK(M->YR_ORIGEM+TRB->YR_DESTINO)) .AND. TRB->(RECNO()) # nRec .AND. !TRB->(DELETED())
                        Else
                                lAchou := TRB->(DBSEEK(TRB->YR_ORIGEM+M->YR_DESTINO)) .AND. TRB->(RECNO()) # nRec .AND. !TRB->(DELETED())
                        EndIf
                        
                        TRB->(DBGOTO(nRec))
                        
                        If lAchou
                                HELP(" ",1,"EA200EXIST")
                                lRet:=.F.
                                break
                        EndIf
                EndIf
        End Sequence
        dbselectarea(cOldArea)
Return lRet



/*
Funcao          : DSCSITEE7(lDBF)
Parametros      : lDBF := .T. pesquisar/retornar de DBF
                  cPRC:=OC_EM - EMBARQUE
                        OC_PE - PROCESSO
Objetivos       : Retornar descricao de situacao de processo de exportacao EE7->EE7_STATUS
Autor           : Heder M Oliveira
Data/Hora       : 14/12/98 16:55
Revisao         :
Obs                     :
*/
Function DSCSITEE7(lDBF,cPRC)
    Local cRet:="", cOldArea:=select()
    Local aOrd:=SaveOrd("SX5"), cAlias, cChave

    DEFAULT lDBF := .F.,cPRC:=OC_PE

    Begin sequence

       /* by jbj - 21/06/04 13:44 - Antes da chamada da função Tabela, verifica se a chave existe no sx5,
                                    caso a chave não exista exibe msg de alerta ao usuário. */
       cAlias := If(cPrc==OC_PE,"EE7","EEC")
       cChave := If(!lDbf,M->&(cAlias+"_STATUS"),(cAlias)->&(cAlias+"_STATUS"))

       SX5->(DbSetOrder(1))
       If !SX5->(DbSeek(xFilial("SX5")+"YC"+AvKey(cChave,"X5_CHAVE")))
          EECMsg(STR0105+Replic(ENTER,2)+; //"Problema:"
                  STR0115+AllTrim(cChave)+STR0116+Replic(ENTER,2)+; //"A chave '"###"' não existe para a tabela 'YC' no dicionário SX5."
                  STR0117+Replic(ENTER,2)+; //"Solução: "
                  STR0118+ENTER+; //"A tabela 'YC' deverá ser atualizada no dicionário SX5, com a(s) "
                  STR0119,STR0085) //"chave(s) faltante(s) "###"Atenção"

          If !lDbf
             M->&(cAlias+"_STTDES") := ""
             cRet := ""
          Else
             (cAlias)->&(cAlias+"_STTDES") := ""
             cRet := ""
          EndIf
          Break
       EndIf

       If !lDBF
          IF cPRC=OC_PE
             M->EE7_STTDES:=AvTabela("YC",M->EE7_STATUS)
             cRET:=M->EE7_STTDES
          ELSE
             M->EEC_STTDES:=AvTabela("YC",M->EEC_STATUS)
             cRET:=M->EEC_STTDES
          ENDIF
       Else
          //Considera que registro esta lock
          IF cPRC=OC_PE
             EE7->EE7_STTDES:=AvTabela("YC",EE7->EE7_STATUS)
             cRET:=EE7->EE7_STTDES
          ELSE
             EEC->EEC_STTDES:=AvTabela("YC",EEC->EEC_STATUS)
             cRET:=EEC->EEC_STTDES
          ENDIF
       EndIf
       If EE7->EE7_STATUS == "E" 
          If !Empty(EE7->EE7_FIM_PE)
             
             EE7->(RecLock("EE7",.F.))
                EE7->EE7_FIM_PE := CTOD ("  /  /  ")
             EE7->(MsUnlock())
                
          EndIf
       EndIf   
    End Sequence
    RestOrd(aOrd)
    DbSelectArea(cOldArea)  
Return cRet


/*
Funcao          : AT115EE4()
Parametros      : Nenhum
Objetivos       : Retornar descricao de tipo de mensagem
Autor           : Heder M Oliveira
Data/Hora       : 09/11/98 11:44
Revisao         :
Obs                     :
*/
Function AT115EE4(cREGRA)
    LOCAL lRet:=.T.,nOldArea:=select(),cX5_DESC
    DEFAULT cREGRA:=2
    Begin sequence
        DO CASE
            CASE cREGRA=2
                If ! EMPTY(cX5_DESC:=AvTabela('Y8',Left(M->EE4_TIPMEN,1)))
                    M->EE4_TIPMEN:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
                Else
                    M->EE4_TIPMEN:=SPACE(AVSX3("EE4_TIPMEN",AV_TAMANHO))
                    lRet:=.F.
                EndIf
            CASE cREGRA=1
                If !EECDSIDIOMA("M->EE4_IDIOMA")
                   lRET:=.F. 
                EndIf
        END
    Endsequence
    lRefresh:=.T.
    dbselectarea(nOldArea)
Return lRet


/*
    Funcao   : EECDSIDIOMA()
    Autor    : Heder M Oliveira    
    Data     : 30/05/99 18:16
    Revisao  : 30/05/99 18:16
    Uso      : Retornar descricao idioma
    Recebe   : cCAMPO := campo/identificador que recebe/contem codigo idioma
    Retorna  :

*/
Function EECDSIDIOMA(cCAMPO)
   Local lRet:=.T.,cOldArea:=select()
   Local cField := if(At("->",cCampo) == 0, cCampo, SubStr(cCampo,At("->",cCampo)+2))
   Local cX5_DESC
   Begin sequence
          
      If ! EMPTY(cX5_DESC:=AvTabela('ID',AVKey(&cCAMPO,"X5_CHAVE")))
         cIDCAPA := AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField)
         &cCAMPO := cIDCAPA
      Else
         &cCAMPO := AVKey("",cField)
         lRet:=.F.
      EndIf
      
      // BAK - Alteração realizada para dar refresh na tela quando for MVC nos campos de idioma - 03/12/2012
      EECMVCIdioma(cCAMPO,cX5_DESC,cField)

   End Sequence
   
   lRefresh:=.T.
   dbselectarea(cOldArea)
   
Return lRET

Function EECMVCIdioma(cCAMPO,cX5_DESC,cField)
Local oModel := FWModelActive()
Local oView := FWViewActive()
Local cRet := ""
Local oModelEEA
Local oModelEEG
Local oModelEEH
Local oModelSYC011
Local oModelSYC029

   If Valtype(oModel) == "O"  // GFP - 27/10/2015
      IF oModel:cId == "EXPP018"
         oModelEEA := oModel:GetModel("EECP018_EEA") //LRS - 21/08/2018
      ENDIF
      IF oModel:cId == "EXPP013
         oModelEEG := oModel:GetModel("EECP013_EEG")
      EndIF
      IF oModel:cId == "EXPP012
         oModelEEH := oModel:GetModel("EECP012_EEH")
      ENDIF
      IF oModel:cId == "EXPP011
         oModelSYC011 := oModel:GetModel("EECP011_SYC")
      ENDIF
      IF oModel:cId == "IMPP029
         oModelSYC029 := oModel:GetModel("EICP029_SYC")
      ENDIF
   EndIf

   If Valtype(oModel) == "O" .And. !Empty(cX5_DESC) .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
      If "EEA" $ cCAMPO .And. Valtype(oModelEEA) == "O" .And. !Empty(oModel:GetValue('EECP018_EEA',"EEA_IDIOMA"))
         oModel:SetValue("EECP018_EEA","EEA_IDIOMA", AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField))
         cRet := oModel:GetValue("EECP018_EEA","EEA_IDIOMA")
      ElseIf "EEG" $ cCAMPO .And. Valtype(oModelEEG) == "O" .And. !Empty(oModel:GetValue('EECP013_EEG',"EEG_IDIOMA"))
         oModel:SetValue('EECP013_EEG',"EEG_IDIOMA", AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField))         
         cRet := oModel:GetValue('EECP013_EEG',"EEG_IDIOMA")
      ElseIf "EEH" $ cCAMPO .And. Valtype(oModelEEH) == "O" .And. !Empty(oModel:GetValue('EECP012_EEH',"EEH_IDIOMA"))
         oModel:SetValue('EECP012_EEH',"EEH_IDIOMA", AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField))
         cRet := oModel:GetValue('EECP012_EEH',"EEH_IDIOMA")
      ElseIf "YC" $ cCAMPO 
         If nModulo == 29 .And. Valtype(oModelSYC011) == "O" .AND. !Empty(oModel:GetValue('EECP011_SYC',"YC_IDIOMA"))  // GFP - 30/01/2014 - Tratamento para EIC e EEC.
            oModel:SetValue('EECP011_SYC',"YC_IDIOMA", AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField))
            cRet := oModel:GetValue('EECP011_SYC',"YC_IDIOMA")
         ElseIf nModulo == 17 .And. Valtype(oModelSYC029) == "O" .AND. !Empty(oModel:GetValue('EICP029_SYC',"YC_IDIOMA"))
            oModel:SetValue('EICP029_SYC',"YC_IDIOMA", AVKey(SX5->X5_CHAVE+"-"+cX5_DESC,cField))
            cRet := oModel:GetValue('EICP029_SYC',"YC_IDIOMA")
         EndIf
      EndIF
   EndIf

   If !Empty(cRet) .And. Valtype(oView) == "O" .And. Valtype(oModel) == "O"
      oView:Refresh()
   EndIf

Return cRet

/*
    Funcao   : WGSTATBR(cWG_STATUS)
    Autor    : Heder M Oliveira    
    Data     : 25/05/1999
    Revisao  : 25/05/1999
    Uso      : Retornar descricao STATUS do SWG
    Recebe   :
    Retorna  :

*/
FUNCTION WGSTATBR(cWG_STATUS)     
    Local aWG_STATUS:={STR0038,STR0039,STR0040,STR0041,STR0042} //"ERRO!"###"Cancelado"###"Não Iniciado"###"Em Andamento"###"Concluída"
RETURN aWG_STATUS[VAL(cWG_STATUS)+2]

                                            
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AVMATA060V³ Autor ³ Cristiano A. Ferreira ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencias dos campos exclusivos da AVERAGE no Link     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Validacao do SX3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION AVMATA060Val(cCampo)

LOCAL lRet := .T.                   
Local oModel	 := FWModelActive()
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061" //LRS - 25/09/2013 - Foi trocado o oModel para Mata061, o novo fonte MVC
 
   
DO CASE 
   CASE !l060MVC .AND. cCampo == "A5_VLCOTUS" .Or. cCampo == "A5_MOE_US"
       If Empty(M->A5_MOE_US) .And. !Empty(A5_VLCOTUS) 
          Help(" ",1,"EMATA060")
          lRet := .f.
       Endif
   CASE l060MVC .AND. cCampo == "A5_VLCOTUS" .Or. cCampo == "A5_MOE_US"
       If Empty(FwFldGet("A5_MOE_US")) .And. !Empty(FwFldGet("A5_VLCOTUS"))
          Help(" ",1,"EMATA060")
          lRet := .f.
       Endif   
ENDCASE

RETURN (lRet)


/*
    Funcao   : E_TUDOK
    Autor    : AVERAGE    
    Data     : 
    Revisao  : 
    Uso      : Validar vias de transporte
    Recebe   :
    Retorna  :

*/
FUNCTION E_TUDOK( )
RETURN .T.

// GFP - 22/07/2016 - Tratamento de edição de campos - Cadastro de Despesas
*-----------------------------*
FUNCTION EA110WHEN(cCampo)
*-----------------------------*
#DEFINE VALOR      "1"
#DEFINE PERCENTUAL "2"
#DEFINE QUANTIDADE "3"
#DEFINE PESO       "4"
#DEFINE CONTEINER  "5"

Local lRet := .T.

Do Case
   Case cCampo == "YB_KILO1"  .OR. cCampo == "YB_KILO2"  .OR. cCampo == "YB_KILO3"  .OR. cCampo == "YB_KILO4"  .OR. cCampo == "YB_KILO5"  .OR. cCampo == "YB_KILO6"  .OR.;
        cCampo == "YB_VALOR1" .OR. cCampo == "YB_VALOR2" .OR. cCampo == "YB_VALOR3" .OR. cCampo == "YB_VALOR4" .OR. cCampo == "YB_VALOR5" .OR. cCampo == "YB_VALOR6"
      lRet := M->YB_IDVL == PESO
   Case cCampo == "YB_CON20"   .OR. cCampo == "YB_CON40"   .OR. cCampo == "YB_CON40H"  .OR. cCampo == "YB_CONOUT"
      lRet := M->YB_IDVL == CONTEINER
   
   Case cCampo == "YB_PERCAPL" .OR. cCampo == "YB_DESPBAS"
      lRet := M->YB_IDVL == PERCENTUAL
   
   Case cCampo == "YB_VALOR"
      lRet := M->YB_IDVL == VALOR .OR. M->YB_IDVL == QUANTIDADE
   
   Case  cCampo == "YB_MOEDA"   .OR. cCampo == "YB_QTDEDIA" .OR. cCampo == "YB_VAL_MAX" .OR.;
         cCampo == "YB_VAL_MIN" .OR. cCampo == "YB_BASECUS" .OR. cCampo == "YB_BASEIMP"
      lRet := lNaoAltera
      
   Case  cCampo == "YB_GERPRO"
      lRet := EasyGParam("MV_EASYFIN",,"N") == "S" .AND. (EasyGParam("MV_EASYFPO",,"N") == "S" .OR. EasyGParam("MV_EASYFDI",,"N") == "S")
      
End Case

Return lRet

*----------------------------------------------------------------------------
Function EA110Valid(cNomeCampo)
*----------------------------------------------------------------------------
#DEFINE VALOR      "1"
#DEFINE PERCENTUAL "2"
#DEFINE QUANTIDADE "3"
#DEFINE PESO       "4"
#DEFINE CONTEINER  "5"

LOCAL aDesp:={ "MV_D_FRETE","MV_D_SEGUR","MV_D_II","MV_D_IPI","MV_D_ICMS" }
LOCAL bBlock1, bBlock2, I, lExisteCampos

IF GetNewPar("MV_ALTDESP","N") == "S"
   RETURN .T.
ENDIF

DEFAULT cNomeCampo:=READVAR()

If cNomeCampo == 'BROWSE' // \\\\////AWR 21/10/1999
       If SYB->YB_IDVL == "1" ; Return STR0050 //"Valor"
   ElseIf SYB->YB_IDVL == "2" ; Return STR0051 //"Percentual"
   ElseIf SYB->YB_IDVL == "3" ; Return STR0052 //"Quantidade"
   ElseIf SYB->YB_IDVL == "4" ; Return STR0053 //"Peso"
   Endif
Endif
SX3->(DBSETORDER(2))
lExisteCampos:=SX3->(DBSEEK("YB_KILO1")).AND.SX3->(DBSEEK("YB_VALOR1"))
SX3->(DBSETORDER(1))

If(Left(cNomeCampo,3)="M->",cNomeCampo:=Subs(cNomeCampo,4),)

If cNomeCampo == 'YB_DESP' .OR. cNomeCampo="*"

   IF AT(LEFT(M->YB_DESP,1),'T') <> 0
      FOR I:=1 TO LEN(aDesp)
          lAchou:=.F.
          
          IF (M->YB_DESP $ "204,205")     // RS - 15/05/06 PIS-COFINS
             lAchou:=.T.
             EXIT
          ENDIF

          IF EasyGParam(aDesp[I]) == M->YB_DESP
             lAchou:=.T.
             EXIT
          ENDIF
          
          /*Quando o parâmetro MV_ALTDESP está desabilitado, restringe os campos que podem ser editados
          para despesas do tipo adiantamento*/
          If Left(M->YB_DESP, 1) == "9" .And. ALTERA
             lAchou:=.T.
             Exit
          EndIf
      NEXT
      IF ! lAchou
         Help(" ",1,"A110TipInv")
         RETURN .F.
      ENDIF
   ENDIF
   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif

If cNomeCampo == 'YB_IDVL' .OR. cNomeCampo = "*"

   If M->YB_IDVL     == "1" //Valor
      M->YB_PERCAPL := 0
      M->YB_DESPBAS := Space(9)
      M->YB_KILO1   := 0
      M->YB_KILO2   := 0
      M->YB_KILO3   := 0
      M->YB_KILO4   := 0
      M->YB_KILO5   := 0
      M->YB_KILO6   := 0
      M->YB_VALOR1  := 0
      M->YB_VALOR2  := 0
      M->YB_VALOR3  := 0
      M->YB_VALOR4  := 0
      M->YB_VALOR5  := 0
      M->YB_VALOR6  := 0
      If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0
         M->YB_CON20   := 0
         M->YB_CON40   := 0
         M->YB_CON40H  := 0
         M->YB_CONOUT  := 0
      EndIf
      
   ElseIf M->YB_IDVL == "2" //Percentual
      M->YB_VALOR   := 0
      M->YB_KILO1   := 0
      M->YB_KILO2   := 0
      M->YB_KILO3   := 0
      M->YB_KILO4   := 0
      M->YB_KILO5   := 0
      M->YB_KILO6   := 0
      M->YB_VALOR1  := 0
      M->YB_VALOR2  := 0
      M->YB_VALOR3  := 0
      M->YB_VALOR4  := 0
      M->YB_VALOR5  := 0
      M->YB_VALOR6  := 0
      If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0
         M->YB_CON20   := 0
         M->YB_CON40   := 0
         M->YB_CON40H  := 0
         M->YB_CONOUT  := 0
      EndIf
      
   ElseIf M->YB_IDVL == "3" //Quantidade
      M->YB_PERCAPL := 0
      M->YB_DESPBAS := Space(9)
      M->YB_KILO1   := 0
      M->YB_KILO2   := 0
      M->YB_KILO3   := 0
      M->YB_KILO4   := 0
      M->YB_KILO5   := 0
      M->YB_KILO6   := 0
      M->YB_VALOR1  := 0
      M->YB_VALOR2  := 0
      M->YB_VALOR3  := 0
      M->YB_VALOR4  := 0
      M->YB_VALOR5  := 0
      M->YB_VALOR6  := 0
      If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0
         M->YB_CON20   := 0
         M->YB_CON40   := 0
         M->YB_CON40H  := 0
         M->YB_CONOUT  := 0
      EndIf
      
   ElseIf M->YB_IDVL == "4" //Peso \\\\////AWR 21/10/1999
      M->YB_PERCAPL := 0
      M->YB_VALOR   := 0
      M->YB_DESPBAS := Space(9)
      If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0
         M->YB_CON20   := 0
         M->YB_CON40   := 0
         M->YB_CON40H  := 0
         M->YB_CONOUT  := 0
      EndIf
   ElseIf M->YB_IDVL == "5" //Conteiner
      M->YB_PERCAPL := 0
      M->YB_VALOR   := 0
      M->YB_DESPBAS := Space(9)
      M->YB_KILO1   := 0
      M->YB_KILO2   := 0
      M->YB_KILO3   := 0
      M->YB_KILO4   := 0
      M->YB_KILO5   := 0
      M->YB_KILO6   := 0
      M->YB_VALOR1  := 0
      M->YB_VALOR2  := 0
      M->YB_VALOR3  := 0
      M->YB_VALOR4  := 0
      M->YB_VALOR5  := 0
      M->YB_VALOR6  := 0
   Endif

   If lExisteCampos .AND. M->YB_IDVL # "4" // \\\\////AWR 21/10/1999
      FOR I := 1 TO 6
         bBlock1:=MEMVARBLOCK( "YB_KILO" +STR(I,1) )
         bBlock2:=MEMVARBLOCK( "YB_VALOR"+STR(I,1) )
         IF(VALTYPE(bBlock1) = "B",EVAL(bBlock1,0),)
         IF(VALTYPE(bBlock2) = "B",EVAL(bBlock2,0),)
      NEXT
   ENDIF

   lRefresh := .T.

   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif

If cNomeCampo == 'YB_PERCAPL' .OR. cNomeCampo="*"

   IF M->YB_IDVL == PERCENTUAL
      IF Empty(M->YB_PERCAPL)
         Help(" ",1,"TC210PBRAN")
         RETURN .F.
      ENDIF
   ELSE
      IF !Empty(M->YB_PERCAPL)
         Help(" ",1,"TC210PERC")
         RETURN .F.
      ENDIF
   ENDIF

   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif

If cNomeCampo == 'YB_DESPBAS' .OR. cNomeCampo="*"

   IF M->YB_IDVL == PERCENTUAL
      IF Empty(M->YB_DESPBAS)
         Help(" ",1,"EA110DESPB")
         RETURN .F.
      ENDIF
      If ! EA110DespBase()
         RETURN .F.
      Endif
   ELSE
      IF !Empty(M->YB_DESPBAS)
         Help(" ",1,"EA110NVZDB")
         RETURN .F.
      ENDIF
   ENDIF

   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif


If cNomeCampo == 'YB_MOEDA' .OR. cNomeCampo="*"

   IF Empty(M->YB_MOEDA)
      Help(" ",1,"EA110NOMOE")
      RETURN .F.
   ENDIF
   IF ! ExistCpo("SYF",M->YB_MOEDA, 1) //YF_FILIAL+YF_MOEDA
      RETURN .F.
   ENDIF

   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif

If cNomeCampo == 'YB_VALOR' .OR. cNomeCampo="*"

   IF M->YB_IDVL == VALOR .OR. M->YB_IDVL == QUANTIDADE
      IF Empty(M->YB_VALOR)
         Help(" ",1,"TC210VBRAN")
         RETURN .F.
      ENDIF
   ELSE
      IF !Empty(M->YB_VALOR)
         Help(" ",1,"TC210VL")
         RETURN .F.
      ENDIF
   ENDIF
   If !cNomeCampo == '*'
      Return .T.
   Endif

Endif

If cNomeCampo == 'YB_VAL_MAX' .OR. cNomeCampo = "*"
   IF M->YB_VAL_MAX < M->YB_VAL_MIN
      Help(" ",1,"A110MXME")
      RETURN .F.
   ENDIF
   If !cNomeCampo == '*'
      Return .T.
   Endif

Endif

If cNomeCampo == 'YB_VAL_MIN' .OR. cNomeCampo = "*"
   IF M->YB_VAL_MIN > M->YB_VAL_MAX
      Help(" ",1,"A110MIMA")
      RETURN .F.
   ENDIF
   If !cNomeCampo == '*'
      Return .T.
   Endif

Endif

//LGS-28/02/2014 - Não permite alteração das despesas 102 e 103 se o campo Base Imposto = SIM
If cNomeCampo == 'YB_BASEIMP' .OR. cNomeCampo = "*"
	If M->YB_BASEIMP = "1" .And. M->YB_DESP $ '102,103'
		MsgInfo(STR0122)
		M->YB_BASEIMP := ""
		RETURN .F.
	EndIf
EndIf
		
IF SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0 //LRS - 22/08/2016
	If cNomeCampo == 'YB_CON20' .OR. cNomeCampo == 'YB_CON40' .OR. cNomeCampo == 'YB_CON40H' .OR. cNomeCampo == 'YB_CONOUT' .OR. cNomeCampo="*"

	   IF !(Positivo(M->YB_CON20) .AND. Positivo(M->YB_CON40) .AND. Positivo(M->YB_CON40H) .AND. Positivo(M->YB_CONOUT))//M->YB_CON20 < 0 .AND. M->YB_CON40 < 0 .AND. M->YB_CON40H < 0 .AND. M->YB_CONOUT < 0
		  Return .F.
	   EndIf
	   If !cNomeCampo == '*'
		  Return .T.
	   Endif
	Endif
EndIF

If cNomeCampo == "YB_GERPRO"
   IF (M->YB_GERPRO == "1" .OR. M->YB_GERPRO == "3") .AND. !(EasyGParam("MV_EASYFPO",,"N") == "S") // Somente PR ### PR e PRE
      HELP("", 1, "EICA11001")  //Não é possível utilizar a opção Somente PR pois o parâmetro MV_EASYFPO = F. Ajustar a opção selecionada ou habilitar o parâmetro MV_EASYPO"
      Return .F.
   ElseIf (M->YB_GERPRO == "2" .OR. M->YB_GERPRO == "3") .AND. !(EasyGParam("MV_EASYFDI",,"N") == "S") // Somente PRE ### PR e PRE
      HELP("", 1, "EICA11002")  //Não é possível utilizar a opção Somente PRE pois o parâmetro MV_EASYFDI = F. Ajustar a opção selecionada ou habilitar o parâmetro MV_EASYFDI"
      Return .F.
   EndIf
   If !cNomeCampo == '*'
      Return .T.
   Endif
Endif


IF cNomeCampo="*" // \\\\////AWR 06/12/2000
   SX3->(DBSETORDER(2))
   IF SX3->(DBSEEK("YB_BASEICM")) .AND.;
      M->YB_BASEICM = "1" .AND. M->YB_BASEIMP = "1" 
      HELP("", 1, "AVG0000164")//MSGINFO(STR0098,STR0083) //"Despesa não pode ser Base de I.C.M.S. quando já é Base de Impostos"
      SX3->(DBSETORDER(1))
      RETURN .F.
   ENDIF
   SX3->(DBSETORDER(1))
ENDIF ////\\\\AWR 06/12/2000

If lExisteCampos .AND. cNomeCampo="*"  .AND. M->YB_IDVL == PESO// \\\\////AWR 21/10/1999

   FOR I := 1 TO 6
       bBlock1:=MEMVARBLOCK( "YB_KILO" +STR(I,1) )
       bBlock2:=MEMVARBLOCK( "YB_VALOR"+STR(I,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF !Empty( EVAL(bBlock1) ) .OR. !Empty( EVAL(bBlock1) ) 
             EXIT  
          ENDIF
       ENDIF
   NEXT

   IF I == 7
      HELP("", 1, "AVG0000165")//MSGINFO(OemToAnsi(STR0054),OemToAnsi(STR0049)) //"NÆo h  Pesos e Valores p/ Kg informados"###"Aten‡Æo"
      lRefresh := .T.
      Return .F.
   ENDIF

   FOR I := 1 TO 6
       bBlock1:=MEMVARBLOCK( "YB_KILO" +STR(I,1) )
       bBlock2:=MEMVARBLOCK( "YB_VALOR"+STR(I,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF (!Empty( EVAL(bBlock1) ) .AND.  Empty( EVAL(bBlock2) )) .OR.;
             ( Empty( EVAL(bBlock1) ) .AND. !Empty( EVAL(bBlock2) ))
             HELP("", 1, "AVG0000166",,STR(I,1)+" nao esta correta",1,17)//MSGINFO(OemToAnsi(STR0056+STR(I,1)+STR0057),OemToAnsi(STR0058)) //"A faixa de peso "###" nÆo esta correta"###"Aten‡Æo"
             lRefresh := .T.
             Return .F.
             EXIT  
          ENDIF
       ENDIF
   NEXT

   FOR I := 2 TO 6
       bBlock1:=MEMVARBLOCK( "YB_KILO" +STR(I-1,1) )
       bBlock2:=MEMVARBLOCK( "YB_KILO" +STR(I  ,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF !EMPTY( EVAL(bBlock2) )
             IF IF(I=6,EVAL(bBlock2) < EVAL(bBlock1),EVAL(bBlock2) <= EVAL(bBlock1))
                HELP("", 1, "AVG0000284",,STR(I,1)+" menor ou igual ao Kilo" + STR(I-1,1),1,6)//MSGINFO(STR0059+STR(I,1)+STR0060+STR(I-1,1),OEMTOANSI(STR0061)) //"Kilo "###" menor ou igual que o Kilo "###"ATEN€ÇO"
                lRefresh := .T.
                Return .F.
             ENDIF
          ENDIF
       ENDIF
    NEXT
    IF EasyGParam(aDesp[1]) == M->YB_DESP
       HELP("", 1, "AVG0000167")//MSGINFO(STR0099,OEMTOANSI("ATEN€AO")) //"Preencha o Cadastro de Vias de Transportes"
       M->YB_KILO1:=M->YB_VALOR1:=0
       M->YB_KILO2:=M->YB_VALOR2:=0
       M->YB_KILO3:=M->YB_VALOR3:=0
       M->YB_KILO4:=M->YB_VALOR4:=0
       M->YB_KILO5:=M->YB_VALOR5:=0
       M->YB_KILO6:=M->YB_VALOR6:=0
    ENDIF
Endif

RETURN .T.

*----------------------------------------------------------------------------
Function EA110DespBase(cCampo)
*----------------------------------------------------------------------------
LOCAL I, nRecno:=SYB->(RECNO()), aDesp:={}, lRet:=.T.
DEFAULT cCampo:=M->YB_DESPBAS
AADD(aDesp,SUBS(cCampo,1,3))
AADD(aDesp,SUBS(cCampo,4,6))
AADD(aDesp,SUBS(cCampo,7,9))

FOR I:=1 TO LEN(aDesp)
    IF ! EMPTY(aDesp[I])
       IF ! SYB->(DBSEEK(xFilial("SYB")+aDesp[I]))
          lRet:=.F.
       ENDIF
    ENDIF
NEXT

If ! lRet
   Help(" ",1,"EA100NODES")
Endif

SYB->(DBGOTO(nRecno))

RETURN lRet


*---------------------*
FUNCTION BuscaPPCC()
*---------------------*
LOCAL nRet
SX3->(DBSETORDER(2))
IF SX3->(DBSEEK("W6_FREPPCC")) .AND. !EMPTY(SW6->W6_FREPPCC)
  nRet:= SW6->W6_FREPPCC
ELSE
  nRet:= SW2->W2_FREPPCC
ENDIF
SX3->(DBSETORDER(1))
RETURN nRet

*---------------------*
FUNCTION BuscaIncoterm(lParounoW4)
*---------------------*
LOCAL nRet
lParounoW4:= IF(lParounoW4==NIL,.F.,.T.)
SX3->(DBSETORDER(2))
IF SX3->(DBSEEK("W6_INCOTER")) .AND. !EMPTY(SW6->W6_INCOTER)
  nRet:= SW6->W6_INCOTER
ELSEIF lParounoW4 .AND. !EMPTY(SW4->W4_INCOTER) 
  nRet := SW4->W4_INCOTER
ELSE  
  nRet:= SW2->W2_INCOTER
ENDIF
SX3->(DBSETORDER(1))
RETURN nRet

*-------------------------------------------------------------------------------*
FUNCTION TR350Arquivo(cWorkArea,cWork2Area,aTitulos,cTit,aDeletados,lForcExcel)
*-------------------------------------------------------------------------------*
LOCAL cFileAux:=cFile:=SPACE(07),nOpcA:=0,nOldRecno:=(cWorkArea)->(RECNO()),cFile2 :=SPACE(7)
LOCAL cFile2Aux:=SPACE(07),xFile:=SPACE(7)
LOCAL bArqValid:={||IF(TR350VALID(2,cFile).AND.TR350VALID(3,cDir),MsgYesNo(STR0072,STR0073),.F.)} //'Confirma Geração ?'###'Arquivo'
LOCAL oDlg, lConfirma//,cTipo:=""
LOCAL nSelect := Select(), cDirStart:=Upper(GetSrvProfString("STARTPATH",""))
Local aStruct := {}                    
Local lExcel  := .F.
Local aCols1:= {}
Local aCols2:= {}
//Local aTit1 := {}
//Local aTit2 := {}

LOCAL lNewExcel := .F.
Local nPos
Local nI

DEFAULT aTitulos:= NIL
DEFAULT cTit:= ""
DEFAULT lForcExcel := .F.
Default aDeletados := {}
PRIVATE cTipoArq := ""

PRIVATE cDir:=SPACE(30) // POR CAUSA DO RDMAKE QUE MODIFICA O PATH 

PRIVATE lValExcel:= aTitulos <> Nil
Private cArqAvCadge 
IF(Right(cDirStart,1) != "\", cDirStart += "\",)

IF Empty((cDir:=ALLTRIM(EasyGParam("MV_PATH_IN"))))
   cDir := Padr(CurDir(),30)
ENDIF                       
IF RIGHT(cDir,1) # "\"
   cDir := cDir+"\"
ENDIF
cDir := Alltrim(cDir)+Space(30-Len(Alltrim(cDir)))

IF(EasyEntryPoint("ICPADGR1"),Execblock("ICPADGR1",.F.,.F.,"PATH"),) // RDMAKE QUE MODIFICA O PATH

If lForcExcel
   cTipoArq := "EXCEL"
   IF(EVAL(bArqValid),nOpcA:=1,nOpcA:=0)
Else
   DEFINE MSDIALOG oDlg TITLE STR0062 From 9,0 To 20,50 OF oMainWnd //"Gera Arquivo"

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  

   @ 10,03 SAY STR0063 OF oPanel PIXEL //"Tipo de Arquivo"
   @ 23,03 SAY STR0064 OF oPanel PIXEL //"Nome Arquivo"
   @ 36,03 SAY STR0065 OF oPanel PIXEL //"Diretorio"

   IF GetRemoteType() == 2 // Se for Client Unix permite apenas criação de arquivos em TXT
      @ 10,45 COMBOBOX cTipoArq ITEMS {"TXT"} SIZE 35,10 OF oPanel PIXEL
   ELSE
      //@ 10,45 COMBOBOX cTipoArq ITEMS {"TXT","DBF","EXCEL"} SIZE 35,10 OF oPanel PIXEL   
      @ 10,45 COMBOBOX cTipoArq ITEMS {"TXT","EXCEL"} SIZE 35,10 OF oPanel PIXEL //THTS - 27/09/2017 - TE-6431 - Temporario no Banco de Dados - Retirada a opcao de DBF
   ENDIF   
   @ 23,45 MSGET cFile SIZE 30,7 PICTURE Replicate("N",Len(cFile)) When cTipoArq <> "EXCEL" VALID TR350VALID(2,cFile) OF oPanel PIXEL
   @ 36,45 MSGET cDir  SIZE 95,8 PICTURE '@!' VALID TR350VALID(3,cDir) OF oPanel PIXEL WHEN .F.
   @ 35,150 BUTTON "Alterar" SIZE 38,12 When cTipoArq <> "EXCEL" ACTION If(!Empty(cNewDir := ChooseFile()), cDir := cNewDir, ) OF oPanel Pixel

   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||nOpcA:=1,IF(EVAL(bArqValid),oDlg:End(),nOpcA:=0)},;
                             {||oDlg:End()}) CENTERED
EndIf

DBSELECTAREA(cWorkArea)

//wfs 23/09/2017 - atribuir um nome aleatório ao arquivo, quando não informado
If Empty(cFile) .And. cTipoArq <> "EXCEL"
   cFile:= CriaTrab(, .F.)
EndIf

xFile := cFile
IF nOpcA == 1 // Ok
   //SVG - 03/05/2010 - #### THTS - 28/09/2017 - Tratamento para nao gerar mais DBF
   If cTipoArq == "EXCEL"
        If Empty(cWork2Area)
            lNewExcel := .T.
        Else            
            lExcel:= .T.
        EndIf
   EndIf 

   lConfirma := .T.  
   
   cFileAux := Alltrim(cDirStart)+AllTrim(cFile)
  
   //wfs - 23/06/2017 - Tratar arquivos txt gerados no servidor: assume o diretório temporário
   If cTipoArq == "TXT" .And. Left(cDir, 1) == "\"
      cDir:= GetTempPath() 
   EndIf
   cFile    := Alltrim(cDir)+If(Right(Alltrim(cDir),1)="\","","\")+AllTrim(cFile)

   IF FILE(cFile+"."+cTipoArq)
      lConfirma:=MsgYesNo(STR0066,STR0067)  //'Arquivo jÁ existe, deseja sobrepor ?'###'Arquivo'
   ENDIF

   If lConfirma 
      IF FILE(cFileAux+"."+cTipoArq)
         ERASE(cFileAux+"."+cTipoArq)
      ENDIF
      
      ERASE(cFile+"."+cTipoArq)

      IF cTipoArq == "TXT" 
         COPY TO (cFileAux+"."+cTipoArq) SDF
         If cFileAux <> cFile
            If !CpyS2T(cFileAux+"."+cTipoArq,cDir)
               MsgInfo(STR0104+cFile+"."+cTipoArq+". (AVCPYFILE)") //"Problemas na cópia do arquivo "
            Else
               ERASE(cFileAux+"."+cTipoArq)
            EndIf
         EndIf
         IF GetRemoteType() <> 5
            ShellExecute("open", Alltrim(cFile)+"."+cTipoArq,"","", 1)
         ENDIF
      
      ELSEIF cTipoArq == "EXCEL" .AND. lNewExcel
         aAdd(aDeletados, "DBDELETE")
         aAdd(aDeletados, "DELETE")
         aCols:= GeraDados(cWorkArea,aDeletados)

         If aTitulos = Nil
            aTitulos := (cWorkArea)->(dbStruct())
            For nI := 1 To Len(aDeletados)
                If (nPos := aScan(aTitulos, {|x| Alltrim(x[1]) == aDeletados[nI] })) > 0
                    aDel(aTitulos, nPos)
                    aSize(aTitulos, Len(aTitulos)-1)
                EndIf
            Next
         EndIf

         /* 
          * EJA - 31/07/2018 - Correção para preencher a última coluna do excel, utilizando a forma mais recente da TOTVS (FWMsExcel).
          */
        toExcel({{"GETDADOS",cTit, aTitulos, aCols}})
      
      EndIf
      //THTS - 27/09/2017 - TE-6431 - Temporario no Banco de Dados - Retirada a opcao de DBF
/*    ELSE
         IF "CTREE" $ RealRDD()
            IF ISSRVUNIX()
               If !AvCpyFile(cFileAux+".dtc",cFile+"."+cTipoArq,.T.) // TDF - 12/11/2010
                  MsgInfo(STR0104+cFile+GetDBExtension()+". (AVCPYFILE)") //"Problemas na cópia do arquivo "
               Else
                  WaitRun("AvgXML2DBF.exe "+cDir+"\")
                  ERASE(cFileAux+"."+cTipoArq)
               EndIf      
            ELSE                   
               aStruct := (cWorkArea)->(dbStruct())
               cFileAux := cFileAux+".dtc"
               // LRS- 18/04/2017 - Na versão 12 em ambientes CTREE, é necessario passar o RDD usado em CTREE

               dbCreate(cFileAux,aStruct,"CTREECDX")
               dbUseArea(.T.,"CTREECDX",cFileAux,"TRB_TEMP",.F.,.F.)
               
               (cWorkArea)->(dbGoTop())
               While (cWorkArea)->(!EOF())
                  RecLock("TRB_TEMP",.T.)
                  AVReplace(cWorkArea,"TRB_TEMP")
                  MsUnlock("TRB_TEMP")
                  (cWorkArea)->(dbSkip())
               enddo
                
               TRB_TEMP->(dbCloseArea())                 
            ENDIF           
                             
         ELSE
            cFileAux := cFileAux+".dbf" // AST - 13/08/08 - Caso o servidor seja Windows e dbf, adiciona a extensão no final do arquivo
            COPY TO (cFileAux)
            
         ENDIF
         if !ISSRVUNIX()
            If cFileAux <> cFile
               If !AvCpyFile(cFileAux,cFile+"."+cTipoArq,.T.)
                  MsgInfo(STR0104+cFile+GetDBExtension()+". (AVCPYFILE)") //"Problemas na cópia do arquivo "
               Else
                  ERASE(cFileAux)
               EndIf
            EndIf
         Endif   
      EndIf*/
   ENDIF
ENDIF   
//MFR 18/12/2018 OSSME-1974
//apagado bloco comentado abaixo conf. orientação do Alessandro

(cWorkArea)->(DBGOTO(nOldRecno))
Select(nSelect)                                                   

RETURN NIL

Static Function toExcel(aSheets)
Local cTableTit
Local aHeads
Local aRows
Local oExcel := FWMsExcel():New()
Local cFileName := "excelfile.xml"
Local i
FErase(cFileName)
For i := 1 to Len(aSheets)
    cTableTit :=  aSheets[i][2] // Título da tabela. Esse título vai ser localizado na primeira célula do excel (primeira linha e coluna)
    aHeads := aSheets[i][3]    // Array com o nome das colunas
    aRows := aSheets[i][4]    // Array contendo os dados
    oExcel:AddWorkSheet(cTableTit) // Adiciona uma aba
    oExcel:AddTable(cTableTit, cTableTit) // Adiciona uma tabela para a aba criada
    fillHeads(oExcel, cTableTit, aHeads) // Preenche com nome das colunas
    fillData(oExcel, cTableTit, aRows) // Preenche com dados
Next
oExcel:Activate()
oExcel:GetXMLFile(cFileName)
oExcel:DeActivate()
FreeObj(oExcel)
openExcel(cFileName)
Return

Static Function openExcel(cFileName)
    Local oExcelApp
    Local cFileTMP := GetTempPath()
    CpyS2T(cFileName, cFileTMP)

    IF GetRemoteType() <> 5 
      oExcelApp := MsExcel():New()
      oExcelApp:WorkBooks:Open(cFileTMP + cFileName) // Abre uma planilha
      oExcelApp:SetVisible(.T.)
      oExcelApp:Destroy()
    ENDIF
Return

Static Function fillHeads(oExcel, cTableTit, aHeads)
    Local cHeadTitle
    Local i
    For i := 1 To Len(aHeads)
        cHeadTitle := aHeads[i][1]
        oExcel:AddColumn(cTableTit, cTableTit, cHeadTitle)
    Next
Return 

Static Function fillData(oExcel, cTableTit, aRows)
    Local i
    For i := 1 To Len(aRows)
        oExcel:AddRow(cTableTit,cTableTit,aRows[i])
    Next

Return 


*-----------------------------*
FUNCTION IPIPauta(lEmbarque, nIPIPauta)
*-----------------------------*
LOCAL nOrdSX3 := SX3->(INDEXORD())
LOCAL nRet := IF(lEmbarque # NIL,0,.F.)
LOCAL lB1_TAB_IPI := .F., lEI6_IPIUNI := .F., lW7_VLR_IPI := .F.

//wfs - out/2019: ajustes de performance - campos encorporados ao dicionário padrão
//SX3->(DBSETORDER(2))
lB1_TAB_IPI := .T.//SX3->(DBSEEK("B1_TAB_IPI"))
lEI6_IPIUNI := .T.//SX3->(DBSEEK("EI6_IPIUNI"))
lW7_VLR_IPI := .T.//SX3->(DBSEEK("W7_VLR_IPI"))
//SX3->(DBSETORDER(nOrdSX3))
DEFAULT nIPIPauta := IF(lW7_VLR_IPI, SW7->W7_VLR_IPI, 0)

//LOCAL lIPIPauta:=SX6->(DBSEEK(xFilial()+"MV_IPIPAUT" )).AND.EasyGParam("MV_IPIPAUT")

IF lEmbarque # NIL                      
   IF lEmbarque .AND. lW7_VLR_IPI .AND. !EMPTY(nIPIPauta)
      nRet := nIPIPauta
   ELSE
     IF lEI6_IPIUNI .AND. lB1_TAB_IPI .AND. !EMPTY(SB1->B1_TAB_IPI)
        IF EI6->(DBSEEK(xFilial("EI6")+SB1->B1_TAB_IPI))
           // SVG - 31/07/2009
           If EI6->(FieldPos("EI6_CALIPI")) > 0 .AND. EI6->EI6_CALIPI == "2"
              nRet := EI6->EI6_IPIUNI 
           Else 
              IF !EMPTY(EI6->EI6_QTD_EM)
                 nRet := EI6->EI6_TOTAL
              ELSE
                 nRet := EI6->EI6_IPIUNI
              ENDIF
           EndIf
        ENDIF
     ENDIF
   ENDIF
ELSE
   nRet := IF(lB1_TAB_IPI .AND. lEI6_IPIUNI .AND. !EMPTY(SB1->B1_TAB_IPI), .T., .F. )
ENDIF
RETURN nRet

*-----------------------------*
FUNCTION TR350VALID(pTipo,File)
*-----------------------------*
PRIVATE cVarPath := " MV_PATH_IN"
IF(EasyEntryPoint("ICPADGR1"),Execblock("ICPADGR1",.F.,.F.,"VARPATH"),) // RDMAKE QUE MODIFICA A VARIAVEL DO PATH

DO CASE

   CASE  pTipo = 1
         IF ! EMPTY(cComprador)
            IF ! SY1->(DBSEEK(xFilial()+cComprador))
               HELP("", 1, "AVG0000168")//MsgInfo(STR0068,STR0069) //"Código do Comprador não cadastrado"###"Informação"
               RETURN .F.
            ELSE
               TAutor := SY1->Y1_NOME
               oAutor:Refresh()
            ENDIF
         ELSE
            TAutor := SPACE(40)
         ENDIF

   CASE  pTipo = 2
         IF lValExcel .AND. cTipoArq == "EXCEL"
            Return .T.   
         /*ELSE   
            IF EMPTY(File)
               HELP("", 1, "AVG0000169")//MsgInfo(STR0070,STR0071) //"Arquivo não informado."###"Informação"
               RETURN .F.
            ENDIF */
         ENDIF
   CASE pTipo = 3
        IF ! AvIsDir(AllTrim(File))
           HELP("", 1, "AVG0000170",,STR0100,1,33) //MsgInfo(STR0100 + cvarPath ,STR0071) //"Informação") //"Diretorio especificado inválido. Coloque um diretório válido na variável do SX6: MV_PATH_IN"
           RETURN .F. 
        ENDIF
        
ENDCASE

RETURN .T.

*-----------------------------*
Function AvIsDir(cCaminho)
*-----------------------------*
Local lIsDirRet := .F. 
Local cDirFile  := cCaminho+If(Right(cCaminho,1)="\","","\")+"EXISTE.DIR"
Local nHdl      := EasyCreateFile(cDirFile)
		
If !empty(cCaminho) 
	If nHdl > 0
       lIsDirRet := .T.	
       Fclose(nHdl)
       Ferase(cDirFile)
	Endif
EndIf
Return lIsDirRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA300  ³ Autor ³ AVERAGE-RHPEREZ       ³ Data ³ 28/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao da Tabela de IPI de Pauta          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA300
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL lExisteGarrafa := .T.
LOCAL cAlias:="EI6"
SX3->(DBSETORDER(2))
lExisteGarrafa := SX3->(DBSEEK("EI6_FILIAL"))
SX3->(DBSETORDER(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef("EICA300")
PRIVATE cDelFunc
Private lCalcIPI := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0101 //"Tabela para IPI de Pauta"
IF ! lExisteGarrafa
  RETURN .F.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,cAlias)
Return .T.
/*
Função      : EICA300Del
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : não permitir a exclusão da tabela de ipi de pauta que estaja sendo utilizada em um produto.
Autor       : André Ceccheto Balieiro
Data/Hora   : 29/12/2010
*/
function EICA300Del(cAlias,nReg,nOpc) 
Local cAliasTABIPI := "TABIPI"
Local lRet:= .T.

Begin Sequence  

   If select(cAliasTABIPI) > 0
      (cAliasTABIPI)->(dbClosearea())
   EndIf

   #IfDef TOP      
   
      cQuery := "Select * From " + RetSqlName("SB1") + " where D_E_L_E_T_ <> '*' And B1_TAB_IPI <> '' order by B1_TAB_IPI"
      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "TABIPI", .T., .T.) 
      
      TABIPI->(DBGotop())

      Do while TABIPI->(!EOF())
         
         If AllTrim(TABIPI->B1_TAB_IPI) ==  AllTrim(EI6->EI6_CODIGO)
            MsgInfo(STR0121,STR0004)
            lRet:= .F.
            Exit
         EndIf
         
         TABIPI->(DbSkip())
      EndDo 

      TABIPI->(DBCloseArea())
      
   #Else
   
      SB1->(Dbgotop())
      
      Do while SB1->(!EOF()) 
         If SB1->B1_TAB_IPI == EI6->EI6_CODIGO
            MsgInfo(STR0121,STR0004)
            lRet:= .F.
            Exit
         EndIf
         SB1->(DbSkip())
      EndDo
    
   #EndIf 
End Sequence

If lRet
   AxDeleta(cAlias,nReg,nOpc)
EndIf
Return lRet


/*
Funcao    : AC102ROF()
Parametros: Nenhum
Objetivos : Chamar a fun‡Æo EFFAC102(cOpcao)
Autor     : Heder M Oliveira
Data/Hora : 18/09/98 09:12
Obs.      : cOpcao := "2", identificando que a opcao escolhida foi ROF
*/
//AAF 21/08/2006 - Este cadastro não é mais utilizado.
//function AC102ROF()
//return EFFAC102("2")

/*
Funcao    : EFFAC102(cOpcao)
Parametros: Nenhum
Objetivos : Manutencao dos contratos de rof e l/c
Autor     : Heder M Oliveira
Data/Hora : 18/09/98 18:03
Obs.      : cOpcao:=1 - linha de credito
                  :=2 - ROF
            Foi necessaria definir uma aRotina especifica pois eh necessaria
            a manutencao do campo WM_RC
Alteracao : Cristiano A. Ferreira 29/03/2000 - Protheus
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
function EFFAC102(cOpcao)
local cTitulo:=STR0074+if(cOpcao=="2",STR0075,STR0076) //"Contratos de "###"ROF"###"Linha de Crédito"
local cOldArea:=select(),lRet:=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := { { STR0077, "AC102PES"  , 0 , 1},; //"Pesquisar"
                     { STR0078,"AC102MAN"  , 0 , 2},; //"Visualizar"
                     { STR0079,   "AC102MAN"  , 0 , 3,57},; //"Incluir"
                     { STR0080,   "AC102MAN"  , 0 , 4,58},; //"Alterar"
                     { STR0081,   "AC102MAN"  , 0 , 5,59} } //"Excluir"

PRIVATE cCadastro := cTitulo //identificador necessario em funcoes com browse
private cWM_RC:=if(cOpcao=="1","2","1") //definir tipo de registro para filtrar no browse
mBrowse( 6, 1,22,75,"SWM", , , , , , ,"AC102FILTRO()","AC102FILTRO()")  //executar browse
dbselectarea(cOldArea)  //retornar area antes da chamada da funcao
return lRet
*/

/*
Funcao    : AC102FILTRO()
Parametros: Nenhum
Objetivos : Definir condicao de filtro para mBrowse da EFCA003()
Autor     : Heder M Oliveira
Data/Hora : 18/09/98 15:07
Obs.      :
*/
//AAF 21/08/2006 - Este cadastro não é mais utilizado.
//function AC102FILTRO()
//return (xFilial("SWM")+cWM_RC)

/*
Funcao    : AC102MAN(cAlias,nReg,nOpc)
Parametros: cAlias := alias do arquivo
            nReg   := recno()
            nOpc   := opcao definica dentre: 1 - Pesquisar
                                             2 - Visualizar
                                             3 - Incluir
                                             4 - Alterar
                                             5 - Deletar
            Este parametros sao definicos pela mBrowse
Objetivos : Rotinas para Visualizar,Incluir, Alterar e Deletar usadas por EFFCA003
Autor     : Heder M Oliveira
Data/Hora : 23/09/98 16:07
Obs.      : Usada no modulo de manutencao de contratos
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
function AC102MAN(cAlias,nReg,nOpc)

local lRet:=.T.,cOldArea:=select(),oDlg,nOpca:=0,nInc
local aSWMEnchoice:={"WM_ROFLC" ,"WM_CODEMP","WM_BANCO","WM_DESCBAN",;
                     "WM_VINCUL","WM_CONTPR","WM_DESBPR",;
                     "WM_DTINIC","WM_DTFINA","WM_VALOR" ,;
                     "WM_DSBMIN","WM_IR"    ,"WM_ENCERR",;
                     "WM_AGENCIA","WM_DESCEMP","WM_SALDO","WM_MOEDA"}
Local aPos:= { 15,  1, 142, 315 }

Private cOld_LC  := Space(Len(SWM->WM_LC))
Private nOld_Sld := 0

private aTela[0][0],aGets[0]      //declaracao obrigatoria para usar enchoice

IF nOpc != INCLUIR
   cOld_LC  := SWM->WM_LC
   nOld_Sld := SWM->WM_VALOR
Endif

IF cWM_RC == "1" 
   // Cadastro de ROF ...
   
   // *** Variaveis para a Consulta Padrao SWM ...
   PRIVATE cROF_LC := '2'
   // Alterado por Heder M Oliveira - 10/8/1999
   PRIVATE cEMPRESA:= Space(AVSX3("WM_CODEMP",3))//Len(SWM->WM_CODEMP))
   PRIVATE cBANCO  := Space(AVSX3("WM_BANCO",3)) //Len(SWM->WM_BANCO))
   PRIVATE cMOEDA  := SPACE(AVSX3("WM_MOEDA",3)) 
   
   PRIVATE lInverte := .F., cMarca := GetMark()
   
   // *** Criar variavel para informar que a consulta padrao foi chamada
   // do Cadastro de ROF.
   PRIVATE lCad_ROF := .T.
   
   aAdd( aSWMEnchoice, "WM_LC" )
Endif

Begin sequence
   //criar variaveis de memoria sobre o SWM
   dbselectarea("SWM")
   IF nOpc = 2  //visualizar
      bVal_OK:={||oDlg:End()}
   ELSEIF nOpc==3 //incluir
      If SUBSTR(cACESSO,4+nSUMACES,1)#"S"
         HELP(" ",1,"SEMPERM")
         lRET:=.F.
         BREAK
      EndIf
      bVal_OK:={||If(AC102SWMLinOk(),(nOpcA:=1,oDlg:End()),nOpca:=0)}

   ELSEIF nOpc==4 //alterar
      If SUBSTR(cACESSO,5+nSUMACES,1)#"S"
         HELP(" ",1,"SEMPERM")
         lRET:=.F.
         BREAK
      EndIf
      bVal_OK:={||If(AC102SWMLinOk(),(nOpcA:=2,oDlg:End()),nOpca:=0)}
   ELSEIF nOpc = 5 //excluir
      If SUBSTR(cACESSO,6+nSUMACES,1)#"S"
         HELP(" ",1,"SEMPERM")
         lRET:=.F.
         BREAK
      EndIf
      bVal_OK:={||nOpca:=0,AC102MANE(),oDlg:End()}
   ENDIF

   if nOpc ==3
      FOR nInc := 1 TO SWM->(FCount())
         M->&(SWM->(FIELDNAME(nInc))) := CRIAVAR(SWM->(FIELDNAME(nInc)))
      NEXT
      M->WM_IR := EasyGParam("MV_IR_FF")
   else
      FOR nInc := 1 TO SWM->(FCount())
         M->&(SWM->(FIELDNAME(nInc))) := SWM->(FIELDGET(nInc))
      NEXT
   endif
   
   While .T.
      aTela := {}
      aGets := {}
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
   
      oEnch1 := MsMGet():New(cAlias,nReg,nOpc,,,,aSWMEnchoice,PosDlg(oDlg))
      oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT    
	  
      ACTIVATE MSDIALOG oDlg ON INIT ( (EFFATELA(oDlg),;
          EnchoiceBar(oDlg,{||EVAL(bVal_OK)},{||nOpca:=0,oDlg:End()})))  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      
      IF nOpca == 1 .Or. nOpca == 2     
         IF !Empty(M->WM_LC)
            IF ! AC102Crit("WM_LC",.F.)
               LOOP
            Endif 
         Endif
      Endif
      
      Exit
   Enddo
   
   *--------------------------------------------------------*
   * INICIA TRANSACAO
   *--------------------------------------------------------*
   Begin Transaction
   
      // *** by CAF 29/03/2000 17:17
      //if nOpca == 1 .Or. nOpca == 2
      //   if ! Empty(M->WM_LC)
      //      SWM->(Reclock("SWM",.F.))
      //      SWM->WM_SALDO -= M->WM_VALOR
      //      SWM->(MSUnlock())
      //   endif
      //endif
           
      do Case
         Case nOpca==1 .and. Obrigatorio(aGets,aTela)
              AC102MANI(.T.)
              
         Case nOpca==2 .and. Obrigatorio(aGets,aTela)
              IF !Empty(cOld_LC) .And. !Empty(nOld_Sld)
                 IF SWM->(dbSeek(xFilial()+"2"+cOld_LC))
                    SWM->(RecLock("SWM",.F.))
                    SWM->WM_SALDO += nOld_Sld
                    SWM->(MSUnLock())
                 Endif
              Endif
            
              SWM->(dbGoto(nReg))
              AC102MANI(.F.)
              
      End Case
     
   End Transaction
   *--------------------------------------------------------*
   * FINALIZA TRANSACAO
   *--------------------------------------------------------*
   
endsequence

dbselectarea(cOldArea)  //retornar area anterior

return lRet
*/

/*
Funcao    : AC102MANE()
Parametros: Nenhum
Objetivos : Excluir um registro de contrato/rof
Autor     : Heder M Oliveira
Data/Hora : 23/09/98 15:50
Obs.      : Chamada pela enchoicebar da AC102MAN()
             quando manutencao de processos estiver pronto,
             validar se este contrato nao esta sendo usado antes de deleta-lo
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
function AC102MANE()
local lRet:=.T.
local nRecno := SWM->(Recno())
local nValor := SWM->WM_VALOR


*--------------------------------------------------------*
* INICIA TRANSACAO
*--------------------------------------------------------*
Begin Transaction

begin sequence
   if Msgnoyes(STR0082,Oemtoansi(STR0083)) //"Confirma Exclusão?"###"Aten‡Æo"
       SWG->(DBSETORDER(If(cWM_RC="1",4,5)))  //2 = LINHA CREDITO : ORDEM 5 / 1 = ROF : ORDEM 4
       IF SWG->(DBSEEK(XFILIAL("SWG")+SWM->WM_ROFLC))
           WHILE ( XFILIAL("SWG")+If(cWM_RC="1",SWG->WG_ROF,SWG->WG_LC) == XFILIAL("SWM")+SWM->WM_ROFLC)
               IF ( SWG->WG_STATUS#"0" ) //CANCELADO
                   lRET:=.F.
                   HELP("", 1, "AVG0000171")//MSGSTOP(STR0084,STR0085) //"ROF/LC Vinculado à Processos. Não é possível eliminá-lo"###"Atenção"
                   BREAK
               ENDIF
               SWG->(DBSKIP(1))
           END
       ENDIF
     
       IF !Empty(SWM->WM_LC)
          nRecno := SWM->(RecNo())
          IF SWM->(dbSeek(xFilial()+"2"+M->WM_LC))
             SWM->(RecLock("SWM",.F.))
             SWM->WM_SALDO += nValor
             SWM->(MSUNLOCK())
          Endif
          SWM->(dbGoTo(nRecno))
       Endif
       Reclock("SWM",.F.)
       SWM->(dbdelete())
       SWM->(MSUNLOCK())
   endif
endsequenc

End Transaction
*--------------------------------------------------------*
* FINALIZA TRANSACAO
*--------------------------------------------------------*

return lRet
/*

/*
Funcao    : AC102MANI(lModo)
Parametros: lModo := .T. - Inclusao
                     .F. - Alteracao
Objetivos : Incluir/Alterar um registro de contrato/rof
Autor     : Heder M Oliveira
Data/Hora : 23/09/98 16:04
Obs.      : Chamada pela enchoicebar da AC102MAN()
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
Function AC102MANI(lModo)
local lRet:=.T.
begin sequence
   E_Grava("SWM",lModo)
   if lModo
      RECLOCK("SWM",.F.)
      SWM->WM_RC:=cWM_RC
      SWM->(MSUNLOCK())
   endif
Endsequence
Return lRet
*/

/*
Funcao      : EFFATELA(oMSMGet)
Parametros  : oMSMGet := nome do objeto
Retorno     : .T.
Objetivos   : Alterar titulo
Autor       : Heder M Oliveira
Data/Hora   : 19/02/99 18:40
Revisao     :
Obs.        :
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
Function  EFFATELA(oMSMGet)
    Local lRet:=.T.,cOldArea:=select(),nInd:=0
    Begin sequence
        nInd := aScan(aGets,{|x| Substr(x,9,10)="WM_ROFLC"})
        aTELA[1][1]:=If(cWM_RC=="1",STR0086,STR0087)    //"Nr. R.O.F."###"Nr.Contrato"
        oMSMGet:aControls[2]:cTitle := aTela[1][1]
        //oMSMGet:aControls[2]:cCaption:=aTela[1][1]
        //by CAF 28/03/2000 16:47 oMSMGet:aControls[nInd*2-1]:Refresh() 
        oMSMGet:Refresh() 
    End Sequence
    dbselectarea(cOldArea)
Return lRet
*/

/*
    Funcao   : AC102SWMLINOK()
    Autor    : Heder M Oliveira    
    Data     : 26/05/1999
    Revisao  : 26/05/1999
    Uso      : Criticar Campos do SWM
    Recebe   :
    Retorna  :

*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
Function AC102SWMLinOk()
    
   Local lRet := .T.
    
   BEGIN SEQUENCE
      lRet := Obrigatorio(aGets,aTela)
   END
    
Return( lRet )
*/

/*
    Funcao   : AC102CRIT(cCAMPO)
    Autor    : Heder M Oliveira    
    Data     : 26/05/1999
    Revisao  : 26/05/1999
    Uso      : Criticar campos do AC102CRIT
    Recebe   :
    Retorna  :
    Revisao  : Cristiano A. Ferreira 29/03/2000 (Protheus)

*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
FUNCTION AC102CRIT(cCAMPO,xWhen)
   Local lRET:=.T.
   Local aOrd := SaveOrd("SWM",1)
   
   Default xWhen := 0
   
   Begin Sequence
      DO CASE
         CASE cCAMPO="WM_VALOR" .AND. M->WM_VINCUL $ cSim
             HELP(" ",1,"AVG0000052")
             lRET:=.F.
         CASE cCampo == "WM_LC" .And. !Empty(xWhen)
             // Chamado pelo When
             IF Empty(M->WM_VALOR)
                //HELP(" ",1,"AVG0000053")
                lRet := .F.
                Break
             Endif
             
             IF ! Empty(cOld_LC)
                lRet := .F.
             Endif
             
             cEMPRESA := M->WM_CODEMP
             cBANCO   := M->WM_BANCO
             cMOEDA   := M->WM_MOEDA
             
         CASE cCampo == "WM_LC" .And. Empty(xWhen) .AND. M->WM_VINCUL $ cSim
             // Chamado pelo Valid
             IF Empty(M->WM_LC)
                HELP(" ",1,"AVG0000054")
                lRet := .F.
                Break
             Endif
             
             IF ! SWM->(dbSeek(xFilial()+"2"+M->WM_LC)) .OR. M->WM_MOEDA#SWM->WM_MOEDA
                HELP(" ",1,"AVG0000055")
                lRet := .F.
                Break
             Endif
             
             // by CAF 29/03/2000 17:19 IF cOld_LC != M->WM_LC
             IF M->WM_VALOR > SWM->WM_SALDO
                HELP(" ",1,"AVG0000056")
                lRet := .F.
                Break
             Endif
             // Endif
                         
             M->WM_VINCUL := SIM
             lRefresh := .T.             
         CASE cCampo = 'WB_NR_ROF'  //SIGAEIF
            If ! EMPTY(M->WB_NR_ROF) .AND. ! SWM->(DBSEEK(xFilial('SWM')+'1'+M->WB_NR_ROF))
               Help(" ",1,"REGNOIS")
               lRetorno:=.F.
            ElseIf ! EMPTY(M->WB_NR_ROF) .AND. (SWM->(DBSEEK(xFilial('SWM')+'1'+M->WB_NR_ROF)).AND.SWM->WM_ENCERR $ cSim.AND.INCLUI)
               HELP(" " ,1,"AVG0000012")
               lRetorno:=.F.
            EndIf
      END CASE
   End Sequence
   
   RestOrd(aOrd)

Return lRet
*/

/*
Funcao      : ROFLCF3(cTIPO,cEmpresa,cBANCO,cMOEDA)
Parametros  : cTIPO :=  "2" - L/C
                        "1" - ROF
Retorno     : Numero do ROF ou L/C
Objetivos   : Consulta padrao com filtro
Autor       : Heder M Oliveira
Data/Hora   : 22/04/99-09:01
Revisao     :
Obs.        :
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
FUNCTION ROFLCF3(cTipo,cEMPRESA,cBANCO,cMOEDA)

Local lRet := .f.
Local oDlg, FileWork, Tb_Campos:={}, OldArea:=SELECT(), OldOrd:=SWM->(INDEXORD())
Local cTitulo, cCampo,cTit1,bReturn,bSetF3 := SetKey(VK_F3)
Local oSeek,cSeek:=SPACE(AVSX3("WM_ROFLC")[3]),oOrdem,cOrd,nOrdem,aOrdem:={}
Local nRec

DEFAULT cBANCO:=NIL
DEFAULT cMOEDA:=NIL

Private cWM_RC:=cTIPO,cWMEMP:=cEMPRESA,cWMBANCO:=cBANCO,cWMMOEDA:=IF(cMOEDA==NIL,"",cMOEDA)

BEGIN SEQUENCE
    //evitar recursividade
    Set Key VK_F3 TO
    IF ( empty(cEMPRESA)) // .OR. EMPTY(cMOEDA))
        HELP("", 1, "AVG0000172")//MSGSTOP(STR0088,STR0085) //"Informar Empresa e MOEDA para criar vínculo."###"Atenção"
        BREAK
    ENDIF
    
    bReturn:=IF(UPPER(cTipo)=="1",{||M->WG_ROF:=SWM->WM_ROFLC,oDlg:End()},{||M->WG_LC:=SWM->WM_ROFLC,oDlg:End()})
    
    IF Type("lCad_ROF") == "L"
       // Foi chamada do Cadastro de ROF ...
       bReturn := {|| M->WM_LC := SWM->WM_ROFLC, oDlg:End() }
    Endif
    
    cTit1 :=IF(UPPER(cTipo)=="1",STR0089,STR0076) //"R.O.F."###"Linha de Crédito"

    AADD(aORDEM,cTIT1)
    AADD(aORDEM,STR0090) //"Código Empresa"

    AADD(Tb_Campos,{"WM_ROFLC" ,,cTit1})
    AADD(Tb_Campos,{{||BuscaBanco(FieldGet(FieldPos("WM_BANCO")))},,STR0091}) //"Banco"
    AADD(Tb_Campos,{"WM_MOEDA",,STR0092}) //"Moeda"
    AADD(Tb_Campos,{"WM_VALOR",,STR0093}) //"Valor"
    AADD(TB_CAMPOS,{"WM_SALDO",,STR0094}) //"Saldo"
    
    DBSELECTAREA("SWM")
    cWMFILIAL:=XFILIAL("SWM")
    // Alterado por Heder M Oliveira - 10/8/1999
    //constatou-se que o ROF tem relacao com a Empresa e nao necessariamente com o Banco
    IF Type("lCad_ROF") == "L"
       // Foi chamada do Cadastro de ROF ...
       SET FILTER TO cWMFILIAL+cWM_RC+cWMEMP+cWMMOEDA==SWM->WM_FILIAL+SWM->WM_RC+SWM->WM_CODEMP+SWM->WM_MOEDA
    ELSE
       SET FILTER TO cWMFILIAL+cWM_RC+cWMEMP==SWM->WM_FILIAL+SWM->WM_RC+SWM->WM_CODEMP
    ENDIF
    /*
    IF (cBANCO=NIL)
        SET FILTER TO cWMFILIAL+cWM_RC+cWMEMP==SWM->WM_FILIAL+SWM->WM_RC+SWM->WM_CODEMP
    ELSE
        SET FILTER TO cWMFILIAL+cWM_RC+cWMEMP+cWMBANCO==SWM->WM_FILIAL+SWM->WM_RC+SWM->WM_CODEMP+SWM->WM_BANCO
    ENDIF
    
    
    cTitulo:=STR0095+cTit1 //"Consulta de Número de "


    DEFINE MSDIALOG oDlg TITLE cTitulo FROM 62,15 TO 310,460 OF oMainWnd PIXEL
            
            oMark:= MsSelect():New("SWM",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
            oMark:baval:={||nRec:=SWM->(RecNo()),lRet:=.t.,Eval(bReturn)}
            @ 091, 14 SAY STR0096 SIZE 42,7 OF oDLG PIXEL //"Pesquisar por:"
            @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlg PIXEL
            @ 104, 14 SAY STR0097 SIZE 32, 7 OF oDlg PIXEL //"Localizar"
            @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlg PIXEL 
            SWM->(DBSETORDER(oORDEM:nAT))
            oSeek:bChange := {|x| PosSeek(x,oSeek,"SWM",oMARK,"SWM")}
            DEFINE SBUTTON FROM 10,187 TYPE 1  ACTION (Eval(oMark:baval)) ENABLE OF oDlg PIXEL
            DEFINE SBUTTON FROM 25,187 TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
             
    ACTIVATE MSDIALOG oDlg
    SET FILTER TO
    DBSELECTAREA(OldArea)
    
    IF !Empty(nRec)
       SWM->(dbGoTo(nRec))
    Endif

END SEQUENCE
SetKey(VK_F3,bSetF3)

RETURN lRet
*/

/*
Funcao      :   PosSeek(nCHAR,oSeek,cALIAS,oBROWSE,cTABELA)}
Parametros  :
Retorno     :
Objetivos   :
Autor       :   HEDER M OLIVEIRA
Data/Hora   :   22/04/99 17:07
Revisao     :
Obs.        :
*/
/* AAF 21/08/2006 - Este cadastro não é mais utilizado.
Static Function POSSEEK(nChar,oSeek,cAlias,oMSBROWSE,cTabela)
Local nReg := Recno()
IF !(Alias() $ "SX1/SX2/SX3/SX4/SX6/SX7/SX9/SM2/SM0/SX5")
    dbSeek (XFILIAL(cALIAS)+cWM_RC+Trim(oSeek:oGet:Buffer)+if(nChar!=nil,Chr(nChar),""))
ElseIF Alias() == "SX5"
    dbSeek (XFILIAL(cALIAS)+cWM_RC+cTabela+Trim(oSeek:oGet:Buffer)+if(nChar!=nil,Chr(nChar),""))
    IF X5_TABELA != cTabela
        dbSeek("zzzzz")
    Endif
Endif
IF Eof() 
    dbgoto(nReg)
Endif
oMSBROWSE:oBrowse:Refresh()
Return .t.
*/

/*
Funcao      : AC102PES(cAlias,nReg,nOpcb)
Parametros  :
Retorno     :
Objetivos   :
Autor       :
Data/Hora   :
Revisao     :
Obs.        :
*/
//AAF 21/08/2006 - Este cadastro não é mais utilizado.
//Function AC102PES(cALIAS,nREG,nOPCB)
//Return AE103PESQUI(cALIAS,nReg,nOpcb,cWM_RC)


/*
Funcao          : AE103PESQUI(cALIAS,nREG,nOPC,cFILTRO)
Parametros      : 
Retorno         : 
Objetivos       : Personlizar seek do botao Pesquisa da mbrowse
Autor           : Heder M Oliveira
Data/Hora       : 15/03/99 16:06
Revisao         :
Obs.            :
*/
/*
Function AE103PESQUI(cAlias,nReg,nOpcb,cFILTRO)
    Local nRet:=1,nOldArea:=select(),nALIASORD:=(cALIAS)->(INDEXORD())
        Local cFILALIAS:=PREFIXOCPO(cALIAS)+"_FILIAL",oDLGPSQ,oCBX
        Local nOPC:=1,cORDEM,cCAMPO:=SPACE(40),nOPCA:=0
        Private aOrd:={}  //PesqOrd usa esta Private
    Begin sequence
       //na chave atual, verifica se existem registros
       If cFILALIAS $ (cALIAS)->(Indexkey())
               (cALIAS)->(DBSEEK(&cFILALIAS))
       Else
               (cALIAS)->(DBGOTOP())
       EndIf
       If (cALIAS)->(Eof())
               Help(" ",1,"A000FI")
               nRet:=3
               BREAK
       EndIf                   
       //carrega vetor aOrd baseado no SINDEX
       PesqOrd(cAlias)
       cORDEM:=aORD[1]
       
       If (cALIAS)->(IndexOrd()) >= Len(aOrd)
                cORDEM := aOrd[Len(aOrd)]
                nOPC   := Len(aOrd)
       ElseIf (cALIAS)->(IndexOrd()) <= 1
               cORDEM  := aOrd[1]
               nOPC    := 1
       Else
               cORDEM := aOrd[(cALIAS)->(IndexOrd())]
               nOPC   := (cALIAS)->(IndexOrd())
       EndIf
       
       DEFINE MSDIALOG oDLGPSQ FROM 5, 5 TO 14, 50 TITLE STR0077 //"Pesquisar"

               @ 0.6,1.3       COMBOBOX oCBX VAR cORDEM ITEMS aOrd  SIZE 165,44 ON CHANGE (nOPC:=oCBX:nAt) OF oDLGPSQ FONT oDLGPSQ:oFont
               @ 2.1,1.3       MSGET cCAMPO SIZE 165,10
               DEFINE SBUTTON FROM 055,122       TYPE 1 ACTION (nOpca := 1,oDLGPSQ:End()) ENABLE OF oDLGPSQ
               DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION oDLGPSQ:End() ENABLE OF oDLGPSQ
       ACTIVATE MSDIALOG oDLGPSQ CENTERED
       If nOpca == 0
               nRET:=0
               BREAK
       EndIf
       If nOPC==1
               cCAMPO:=cFILTRO+cCAMPO
       ElseIf nOPC==2
               cCAMPO:=LEFT(cCAMPO,2)+SUBSTR(cCAMPO,3,5)+;
                               cFILTRO+SUBSTR(cCAMPO,8)
       Else
               cCAMPO:=LEFT(cCAMPO,2)+cFILTRO+SUBSTR(cCAMPO,8)
       EndIf
       Set Softseek On
       (cALIAS)->(dbSetOrder(nOPC))
       If ("DTOS" $ Upper((cALIAS)->(IndexKey(nOPC)))) .or. ("DTOC" $ Upper((cALIAS)->(IndexKey(nOPC))))
               cCampo := ConvData((cALIAS)->(IndexKey(nOPC)),cCampo)
       EndIf
       If !(cALIAS)->(dbSeek(&cFILALIAS+TRIM(cCampo)))
               Help(" ",1,"PESQ01")
               nRET:=0
               BREAK
       EndIf
       Set SoftSeek Off
       lRefresh := .t.
    Endsequence
    If nRET==0
        (cALIAS)->(DBSETORDER(nALIASORD))
        (cALIAS)->(DBGOTO(nREG))
     EndIf
    dbselectarea(nOldArea)
Return nRet
*/

/*
    Funcao   : EECMEND(cALIAS,nORDEM,cCHAVE,lVET)
    Autor    : Heder M Oliveira    
    Data     : 12/07/99 14:19
    Revisao  : 12/07/99 14:19
    Uso      : Montar endereço em linha
    Recebe   :
    Retorna  :

*/
FUNCTION EECMEND(cALIAS,nORDEM,cCHAVE,lVET,nTAM,nRet)
    //Local pRET - variável declarada com private para ser tratada pelo ponto de entrada
    Local nSelect := Select()
    Local aOrd
    Local cAux := ""  // NCF - 22/05/2013
    
    Private pRET
    
    DEFAULT cALIAS:="",cCHAVE:="",nORDEM:=1,lVET:=.F.,nTAM:=60
    
    pRet:=if(lVET,{},"")
    
    BEGIN SEQUENCE
        IF ( EMPTY(cALIAS).OR.EMPTY(cCHAVE) )
            BREAK       
        ENDIF
        
        // Salva a Ordem e o Registro atuais ...
        aOrd := saveOrd(cAlias)
        
        (cALIAS)->(DBSETORDER(nORDEM))
        IF (cALIAS)->(DBSEEK(XFILIAL(cALIAS)+cCHAVE))
            DO CASE
                CASE cALIAS="SA1"
                
                   //LRS - 24/05/2016 - Tratamento para campos endereço opcionais
                   EXJ->(dbSetOrder(1))
                   EXJ->(dbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
                
                   If SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !Empty(SA1->A1_COMPLEM)
                      cAux := ALLTRIM(SA1->A1_COMPLEM)
                      cAux += " - "
                   EndIf

                   IF EXJ->(FieldPos("EXJ_BAIRRO")) > 0 .AND. !Empty(EXJ->EXJ_BAIRRO)
                      cAux += ALLTRIM(EXJ->EXJ_BAIRRO)
                      IF !Empty(EXJ->EXJ_BAIRRO)
	                      cAux += " - "
	                   Endif
                   ELSE
	                   cAux += ALLTRIM(SA1->A1_BAIRRO)
	                   IF !Empty(SA1->A1_BAIRRO)
	                      cAux += " - "
	                   Endif
                   ENDIF
                   
                   IF EXJ->(FieldPos("EXJ_COD_MU")) > 0 .AND. !Empty(EXJ->EXJ_COD_MU)
                      cAux += ALLTRIM(EXJ->EXJ_COD_MU)
                      IF !Empty(EXJ->EXJ_COD_MU)
	                      cAux += " - "
	                   Endif
                   ELSE
                   cAux += ALLTRIM(SA1->A1_MUN)
                   IF !Empty(SA1->A1_MUN)
                      cAux += " - "
                   Endif
                   ENDIF
                   
                   IF EXJ->(FieldPos("EXJ_CEP")) > 0 .AND. !Empty(EXJ->EXJ_CEP)
                      cAux += ALLTRIM(EXJ->EXJ_CEP)
                      IF !Empty(EXJ->EXJ_CEP)
	                      cAux += " - "
	                   Endif                      
                   ELSE
	                   cAux += ALLTRIM(SA1->A1_CEP)
	                   IF !Empty(SA1->A1_CEP)
	                      cAux += " - "
	                   Endif
                   ENDIF
                   
                   IF EXJ->(FieldPos("EXJ_COD_ES")) > 0 .AND. !Empty(EXJ->EXJ_COD_ES)
                      cAux += ALLTRIM(EXJ->EXJ_COD_ES)
                      IF !Empty(EXJ->EXJ_COD_ES)
	                      cAux += " - "
	                   Endif                   
                   ELSE
	                   cAux += ALLTRIM(SA1->A1_ESTADO)
	                   IF !Empty(SA1->A1_ESTADO)
	                      cAux += " - "
	                   Endif
                   ENDIF
                   
                   IF EXJ->(FieldPos("EXJ_EST")) > 0 .AND. !Empty(EXJ->EXJ_EST)
                      cAux += ALLTRIM(EXJ->EXJ_EST)
                      IF !Empty(EXJ->EXJ_EST)
	                      cAux += " - "
	                   Endif                   
                   ENDIF
                   
                   cAux += ALLTRIM(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_NOIDIOM"))
                   
                   IF EXJ->(FieldPos("EXJ_END")) > 0 .AND. !Empty(EXJ->EXJ_END)
	                   IF ( lVET)
	                      AADD(pRET,INCSPACE(ALLTRIM(EXJ->EXJ_END),nTAM,.F.))
	                      AADD(pRET,INCSPACE(cAux,nTAM,.F.))
	                   ELSE
	                      pRET:=INCSPACE(ALLTRIM(EXJ->EXJ_END)+" - "+cAux,nTam,.F.)
	                   ENDIF                      
                   Else
	                   IF ( lVET)
	                      AADD(pRET,INCSPACE(ALLTRIM(SA1->A1_END),nTAM,.F.))
	                      AADD(pRET,INCSPACE(cAux,nTAM,.F.))
	                   ELSE
	                      pRET:=INCSPACE(ALLTRIM(SA1->A1_END)+" - "+cAux,nTam,.F.)
	                   ENDIF
                   ENDIF
                   
                CASE cALIAS="SA2"
                           
                   If SA2->(FieldPos("A2_COMPLEM")) > 0 .And. !Empty(SA2->A2_COMPLEM)
                      cAux := ALLTRIM(SA2->A2_COMPLEM)
                      cAux += " - "
                   EndIf
                   
                   cAux += ALLTRIM(SA2->A2_BAIRRO)
                   IF !Empty(SA2->A2_BAIRRO)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(SA2->A2_MUN)
                   IF !Empty(SA2->A2_MUN)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(SA2->A2_EST)
                   IF !Empty(SA2->A2_EST)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_NOIDIOM"));
                          +IF(!EMPTY(SA2->A2_CX_POST)," - Cx.Post. "+SA2->A2_CX_POST,"");
                          +IF(!EMPTY(SA2->A2_CEP)," - C.E.P. "+SA2->A2_CEP,"")
                   
                   IF ( lVET )
                      AADD(pRET,INCSPACE(ALLTRIM(SA2->A2_END),nTAM,.F.))
                      AADD(pRET,INCSPACE(cAux,nTam,.F.))
                   ELSE
                      pRET:=ALLTRIM(SA2->A2_END)+" - "+cAux
                      pRET:=INCSPACE(pRET,nTAM,.F.)
                   ENDIF
                
                CASE cAlias=="SY5" // by CAF 27/09/1999 11:02
                
                   cAux := ALLTRIM(SY5->Y5_BAIRRO)
                   IF !Empty(SY5->Y5_BAIRRO)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(SY5->Y5_CIDADE)
                   IF !Empty(SY5->Y5_CIDADE)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(SY5->Y5_EST)
                   IF !Empty(SY5->Y5_EST)
                      cAux += " - "
                   Endif
                   
                   cAux += ALLTRIM(Posicione("SYA",1,xFilial("SYA")+SY5->Y5_PAIS,"YA_NOIDIOM"));
                          +IF(!EMPTY(SY5->Y5_CX_POST)," - Cx.Post. "+SY5->Y5_CX_POST,"");
                          +IF(!EMPTY(SY5->Y5_CEP)," - C.E.P. "+SY5->Y5_CEP,"")
                      
                   If lVet
                      aAdd(pRet,IncSpace(AllTrim(SY5->Y5_END),nTam,.F.))
                      aAdd(pRet,IncSpace(cAux,nTam,.F.))
                   Else
                      pRet:=AllTrim(SY5->Y5_END)+" - "+cAux
                      pRet:=IncSpace(pRet,nTam,.F.)
                   Endif
            ENDCASE
        ENDIF
        
        // Restaura Ordem e o Registro ...
        restOrd(aOrd)
        
    END SEQUENCE
    
    Select(nSelect)
    
    If EasyEntryPoint("AVCADGE")//JPM - ponto de entrada para customização do retorno da função
       ExecBlock("AVCADGE",.f.,.f.,{"EECMEND",{cAlias,nOrdem,cChave,lVet,nTam,nRet}})
    EndIf
    
    If lVet
       IF Len(pRET)==0
          IF nRet == Nil
             pRET:={"",""}
          Else
             pRet:=""
          Endif
       Else
          IF nRet != nil .and. nRet <= Len(pRet) .And. nRet > 0
             pRet := pRet[nRet]
          Endif
       Endif
    ENDIF
    
RETURN pRET
//=========================================
FUNCTION INCSPACE(pCAMPO,nINCSPACE,lLR)
   // Alterado por Heder M Oliveira - 12/27/1999
   LOCAL cRET:=""
   DEFAULT nINCSPACE:=0,lLR:=.T. //SE lLR:=.T., SPACE NO LEFT, SENAO SPACE NO RIGHT
   BEGIN SEQUENCE
      IF ( LEN(pCAMPO)<nINCSPACE )
         IF ( lLR )
            cRET:=SPACE(nINCSPACE-LEN(pCAMPO))+pCAMPO
         ELSE
            cRET:=pCAMPO+SPACE(nINCSPACE-LEN(pCAMPO))        
         ENDIF
      ELSE
         cRet:=Left(pCampo,nIncSpace)
      ENDIF
   END SEQUENCE
RETURN cRET

/*
Funcao   : EECTrocaId
Autor    : Cristiano A. Ferreira
Data     : 09/09/1999 10:03
Revisao  : 
Uso      : Consistir a troca de idioma
Recebe   : 
Retorna  : .T./.F.
*/
Function EECTrocaId

Local lRet := .T.
Local cMsg := STR0102+CRLF+; //"Atenção os documentos/mensagens serão perdidos."
              STR0103 //"Confirma alteração do idioma ?"

Begin Sequence

   IF Type("cOldIdioma") <> "C"
      Break
   Endif
   
   IF cOldIdioma != M->YA_IDIOMA
      IF !Empty(cOldIdioma)
         IF ! IsVazio("Work1") .Or. ! IsVazio("Work3")
            IF ! MsgNoYes(cMsg,"Aviso")
               M->YA_IDIOMA := cOldIdioma
               Break
            Endif
      
            Work1->(avzap())
            Work2->(avzap())
            Work3->(avzap())
         
            Eval(bEndDialog)
         Else
            IF lGrvWork
               Work2->(avzap())
               Eval(bEndDialog)
            Endif
         Endif
      Endif
      
      cOldIdioma := M->YA_IDIOMA
   Endif

End Sequence

lRefresh := .T.
SysRefresh()

Return lRet

/*
Funcao    : EECHistDoc(cAlias,nReg,nOpc)
Parametros: cAlias := alias do arquivo
            nReg   := recno()
            nOpc   := opcao 3 - Incluir
                            4 - Alterar
                            5 - Deletar
Objetivos : Cadastrar documento no histórico manualmente, anexando um arquivo de imagem (.jpeg e .bmp)
Autor     : Jeferson Barros Jr.
Data/Hora : 31/07/02 10:38
Obs.      : Usada no modulo EEC
*/        
*--------------------------------------------*
Function EECHistDoc(cAlias,nReg,nOpc,cRotina)
*--------------------------------------------*
Local lRet:=.t., cFase, oDlg, aShow:={}
Local nOpca:=0,i,nPos:=0
Local bCancel:= {|| oDlg:End()}
Local nInc
Local aOrd := SaveOrd({"SX3"})
local aCpoEdit  := {}
local cTempPath := GetTempPath()

Private aTela[0][0],aGets[0], cNmFile:=Space(300)
Private cNameAux := cFileName := cDirName := "" //LGS-01/09/2015 - Alterado para private para utilizar no FIERGS
Private aSelecao := {}, aFiles := {}            //LGS-01/09/2015 - Alterado para private para utilizar no FIERGS
Private cDir     := "\HistDoc\"
Default cAlias := "SY0"
Default nReg   := 0
Default nOpc   := 3
Default cRotina:="" //LGS - 27/08/2015 - Utilizado para verificar se foi chamado pela rotina FIERGS

Begin Sequence

   If nOpc == 4
      IF cRotina == "FIERGS"
         SY0->( DBGOTO(nReg) )
      EndIf
      IF SY0->Y0_CODRPT <> "** USER **"
         MsgStop(STR0105+ENTER+; //"Problema:"
                 STR0106+Replic(ENTER,2)+; //"Este item não pode ser excluído."
                 STR0107+ENTER+; //"Solução:"
                 STR0108,STR0085) //"Só podem ser excluídos os itens que foram incluídos pelo usuário."###"Atenção"
         Break
      EndIf
   EndIf

   If nOpc == 2 // Visualizar
      
      IF cRotina == "FIERGS"
         SY0->( DBGOTO(nReg) )
      EndIf
      if SY0->(FieldPos("Y0_APTHTML")) # 0 .And. !Empty(SY0->Y0_APTHTML)
         EasyCallAph(,rTrim(SY0->Y0_DOC),,.F.,rTrim(SY0->Y0_PROCESS),SY0->Y0_CODRPT,SY0->Y0_APTHTML)   
      Else        
         If AllTrim(SY0->Y0_CODRPT) <> "** USER **"
            AvTipoDoc()
            Break
         EndIf

         If (EECFlags("VISUALIZA_PDF") .And. !Empty(SY0->Y0_ARQPDF)) .or. cRotina == "FIERGS"
            cFileName := AllTrim(SY0->Y0_ARQPDF)
         Else
            cFileName := AllTrim(SY0->Y0_ARQWMF)
         EndIf

         // ** Carrega nome do arquivo já tratado para procura das sequências...
         cNameAux  := if( cRotina == "FIERGS" , if(empty(cFileName),"*.pdf",cFileName), AllTrim(TrataFileName(cFileName))+"*.*"  )
         aFiles    := Directory(cDir + cNameAux )

         For i:=1 To Len(aFiles)
            If !File(cTempPath+aFiles[i][1])
               AvCpyFile(cDir+aFiles[i][1],cTempPath+aFiles[i][1])
            EndIf
         Next

         For i:=1 To Len(aFiles)
            If File(cDir+aFiles[i][1])
               If Upper(Right(aFiles[i][1], 4)) == ".PDF"
                  ShellExecute("open",cTempPath + aFiles[i][1],"","", 1)
                  /*If EECFlags("VISUALIZA_PDF")
                     ShellExecute("open",GetTempPath() + aFiles[i][1],"","", 1)
                     //WinExec("AcroRd32" + " " + GetTempPath() + aFiles[i][1])
                  Else
                     MsgInfo(STR0133, STR0004) //"Erro nas configurações para visualização de arquivos do tipo PDF", "Atenção"
                  EndIf*/
               Else
                  nExec := WinExec("MsPaint "+GetTempPath()+aFiles[i][1])
                  If nExec == 2
                     WinExec("Paint "+GetTempPath()+aFiles[i][1])
                  EndIf
               EndIf
            EndIf
         Next
      EndIf
      Break

   ElseIf nOpc == 3 // Inclusão...

      bOk := {|| If(Obrigatorio(aGets,aTela) .and. if(cRotina == "FIERGS" , VldPDF(aSelecao[3]) , .T. ) ,(nOpca:=1, oDlg:End()),Nil)}
      
      If Type("aHistDocAuto") == "A"
         If aScan(aHistDocAuto, {|a| a[1] == "aSelecao" }) > 0
            aSelecao := aHistDocAuto[aScan(aHistDocAuto, {|a| a[1] == "aSelecao" })][2]
         EndIf
      Else
         If cRotina == "FIERGS"  //LGS - 27/08/2015
            aSelecao := {"3", M->EEC_PREEMB,""}
         Else
            aSelecao:=EECSelFase(lEmbarque,cRotina)
         EndIf
      EndIf
      
      If Len(aSelecao) == 0
         lRet := .F.
         Break
      EndIf

      If (Empty(aSelecao[2]) .Or. Empty(aSelecao[3])) .And. cRotina <> "FIERGS"
         MsgInfo(STR0134, STR0110) //"Favor preencher todos os campos.", "Aviso"
         lRet := .F.
         Break
      EndIf

      For i := 1 TO SY0->(FCount())
         M->&(SY0->(FieldName(i))) := CriaVar(SY0->(FieldName(i)))
      Next

      M->Y0_FASE    := aSelecao[1]
      M->Y0_PROCESS := aSelecao[2]

      EECAtuHistDoc() //LGS-01/09/2015

      If (EECFlags("VISUALIZA_PDF") .And. Upper(Right(AllTrim(cFileName), 4)) == ".PDF") .Or. cRotina == "FIERGS"
         M->Y0_ARQPDF  := AvKey(AllTrim(cFileName),"Y0_ARQPDF")
      Else
         M->Y0_ARQWMF  := AvKey(AllTrim(cFileName),"Y0_ARQWMF")
      EndIf
      
      M->Y0_HORA    := Time()
      M->Y0_DATA    := dDataBase
      M->Y0_USUARIO := AllTrim(cUserName)
      M->Y0_CODRPT  := "** USER **"
      M->Y0_CHVDTHR := Str(AVCTOD("31/12/2999") - dDataBase,6,0) + Str( 86400 - SECONDS(),6,0)
      M->Y0_PAGINAS := 0
      M->Y0_SEQREL  := ""
      
      If cRotina == "FIERGS" //LGS-28/08/2015
         M->Y0_ROTINA := "FIERGS"
      EndIf

      If Type("aHistDocAuto") == "A"
         aEval(aHistDocAuto, {|a| If("S" + Left(a[1], 2) == cAlias, &(a[1]) := a[2], ) })
      EndIf

   ElseIf nOpc == 4                                                      

      bOk:={|| If(MsgYesNo(STR0109,STR0110),(nOpca:=1, oDlg:End()),Nil)} //"Confirma a exclusão?"###"Aviso"

      For i := 1 TO SY0->(FCount())
          M->&(SY0->(FieldName(i))) := SY0->(FieldGet(i))
      Next
   Endif
   
   If cRotina == "FIERGS"
      aShow := {"Y0_PROCESS","Y0_FASE","Y0_DOC","Y0_DATA","Y0_HORA"}
      if nOpc == 3 
         aCpoEdit := {"Y0_DOC","Y0_DATA","Y0_HORA"}
      endif
   Else
      aShow:={"Y0_PROCESS","Y0_FASE","Y0_DOC","Y0_DATA","Y0_HORA","Y0_PAGINAS"}
   EndIf
   
   If (EECFlags("VISUALIZA_PDF") .And. Upper(Right(AllTrim(cFileName), 4)) == ".PDF") .Or. cRotina == "FIERGS"
      aAdd(aShow, "Y0_ARQPDF")
   Else
      aAdd(aShow, "Y0_ARQWMF")
   EndIf
   
   If Type("lHistDocAuto") == "L" .And. lHistDocAuto
      For nInc := 1 To Len(aShow)
         SX3->(DbSetOrder(2))
         If SX3->(DbSeek(IncSpace(aShow[nInc], Len(SX3->X3_CAMPO), .F.)))
            If X3Uso(SX3->X3_CAMPO) .And. X3Obrigat(SX3->X3_CAMPO) .And. SX3->X3_CONTEXT <> "V" .And. Empty(M->&(SX3->X3_CAMPO))
               lRet := .F.
               Break
            EndIf
         EndIf
      Next
      nOpca := 1
      cChaveDoc := M->Y0_CHVDTHR
   Else
      DEFINE MSDIALOG oDlg TITLE STR0135 FROM 0,0 TO 410,688 OF oMainWnd PIXEL //"Histórico de Documentos"
         oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         
         aPos := PosDlg(oDlg)
         
         EnChoice("SY0",nReg,nOpc,,,,aShow,{aPos[1],aPos[2],aPos[3]-19,aPos[4]},If(cRotina == "FIERGS" ,aCpoEdit,),,,,,oPanel )
         
         If cRotina == "FIERGS" .And. nOpc <> 4
            @ 108,250 BUTTON "..." SIZE 13,13 ACTION Eval( {|| aSelecao[3]:=EECChoseFile(cRotina), EECAtuHistDoc(cRotina)} ) OF oPanel PIXEL
         EndIf

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   EndIf

   If nOpca == 1
      Begin Transaction
         If nOpc == 3
            If !lIsDir(cDir)
               MakeDir(cDir)
            Endif

            aFiles:=Directory(cDirName+cNameAux+"*.*")
            // aFiles:=Directory(cDirName+"\"+cFileName+"*.*")

            For i:=1 To Len(aFiles)
               If !File(cDir+aFiles[i][1])
                  AvCpyFile(cDirName+aFiles[i][1],cDir+aFiles[i][1])
               EndIf
            Next

            SY0->(RecLock("SY0",.t.))
            AvReplace("M","SY0")

         Elseif nOpc == 4 // Exclusao ...
            If (EECFlags("VISUALIZA_PDF") .And. !Empty(SY0->Y0_ARQPDF)) .or. cRotina == "FIERGS"
               cFileName := AllTrim(SY0->Y0_ARQPDF)
            Else
               cFileName := AllTrim(SY0->Y0_ARQWMF)
            EndIf

            // ** Carrega nome do arquivo já tratado para procura das sequências...
            cNameAux  := if( cRotina == "FIERGS" , if(empty(cFileName),"*.pdf",cFileName), AllTrim(TrataFileName(cFileName))+"*.*"  )
            aFiles    := Directory(cDir + cNameAux )

            For i:=1 To Len(aFiles)
               If File(cDir+aFiles[i][1])
                  fErase(cDir+aFiles[i][1])
               EndIf
               If File(cTempPath+aFiles[i][1])
                  fErase(cTempPath+aFiles[i][1])
               EndIf
            Next

            SY0->(RecLock("SY0",.f.))
            SY0->(DbDelete())
         EndIf
      End Transaction
   EndIf
   
   If cRotina == "FIERGS"
      Ae108Y0Work(.T.)
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao    : VldPDF()
Objetivos : Validar o arquivo PDF do certificado de origem FIERGS
Autor     : Bruno Akyo Kubagawa
Data/Hora : 
Obs.      : 
*/
static function VldPDF( cDirFile )
   local lRet     := .T.
   local nTamanho := 0
   local cFile    := ""
   local cBarra   := "\"

   default cDirFile := ""

   if !empty(cDirFile)
      cBarra := "\" //if(IsSrvUNIX(), "/", "\" )
      cFile := substr( cDirFile, rat(cBarra,cDirFile) + 1 )
      nTamanho := getSX3Cache("Y0_ARQPDF", "X3_TAMANHO")

      if len(alltrim(cFile)) > nTamanho
         lRet := .F.
         EasyHelp(STR0180 + CRLF + StrTran( STR0181, '####', cValtoChar(len(alltrim(cFile)))), STR0004, StrTran( STR0182, '####', cValtoChar(nTamanho) )) // "Informe um arquivo válido." "Atenção" "O arquivo informado contem #### caracteres." "O nome do arquivo pdf deverá conter até #### caracteres."
      endif

   endif

return lRet

/*
Funcao    : EECSelFase()
Parametros: lEmbarque - Indica que a rotina já foi chamada da fase de embarque e o embarque está posicionado
Objetivos : Tela de seleção da fase do documento (Auxiliar a função EECHistDoc)
Autor     : Jeferson Barros Jr.
Data/Hora : 31/07/02 11:00
Obs.      : 
*/
*--------------------------------------------*
Static Function EECSelFase(lEmbarque,cRotina)
*--------------------------------------------*
Local aRet:={}, oDlg, nOpca:=0, cTipo:=""
Local bOk     := {|| nOpca:=1,oDlg:End()}
Local bCancel := {|| oDlg:End()}
Local bActBt  := {|| cNmFile:=EECChoseFile(cRotina)}
Local lWhen   := .T.
Local lFiergs := .F.
Local cTitulo := "", aTipo := {}

Private cProcesso:=CriaVar("EE7_PEDIDO")
Default lEmbarque := .F.
Default cRotina   := "" //LGS - 27/08/2015

Begin Sequence

	If cRotina == "FIERGS" .And. EasyGParam("MV_FIERGS",,.F.)
	   lFiergs   := .T.
	   cTitulo   := STR0140 //"Inclusão do Anexo da Fatura em PDF"
	   cProcesso := M->EEC_PREEMB
	   aTipo     := {STR0142}
	Else
	   cTitulo := STR0111
	   aTipo   := {STR0141,STR0142} //{"Pedido","Embarque"} 
	EndIf

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 26,IF(!SetMDIChild(),37,50) OF oMainWnd //"Histórico Documentos - Inclusão"
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 11/09/2015
	  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      // NCF-25/06/09- Verificação de uso no modo MDI para acerto da tela e exibição dos botões de "OK" e "CANCEL"
      IF !SetMDIChild()
      
      @ 15,04 TO 47,123 LABEL "Fase" PIXEL OF oPanel
      @ 25,09 COMBOBOX cTipo ITEMS aTipo SIZE 110,20 PIXEL OF oPanel

      @ 49,04 TO 80,123 LABEL STR0143 PIXEL OF oPanel
      If lFiergs
         @ 59,09 MSGET cProcesso Size 110,07 PIXEL OF oPanel
      Else
         @ 59,09 MSGET cProcesso Size 110,07 F3 "EYC" VALID ValFaseProc(cTipo,cProcesso) PIXEL OF oPanel
      End

      @ 82,04 TO 110,123 LABEL STR0144 PIXEL OF oPanel
      @ 92,09 GET cNmFile Size 99,07 PIXEL OF oPanel

      @ 90,107 BUTTON "..." SIZE 13,13 ACTION Eval(bActBt) PIXEL OF oPanel
         
	  ELSE
	  
         @ 15,29 TO 47,148 LABEL STR0145 PIXEL OF oPanel
         @ 25,34 COMBOBOX cTipo ITEMS aTipo SIZE 110,20 PIXEL OF oPanel

         @ 49,29 TO 80,148 LABEL "Processo" PIXEL OF oPanel
         If lFiergs
            @ 59,34 MSGET cProcesso Size 110,07 PIXEL OF oPanel
         Else
            @ 59,34 MSGET cProcesso Size 110,07 F3 "EYC" VALID ValFaseProc(cTipo,cProcesso) PIXEL OF oPanel
         EndIf

         @ 82,29 TO 110,148 LABEL STR0144 PIXEL OF oPanel
         @ 92,34 GET cNmFile Size 99,07 PIXEL OF oPanel

         @ 90,132 BUTTON "..." SIZE 13,13 ACTION Eval(bActBt) PIXEL OF oPanel 
          
      ENDIF

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nOpca == 1
      aRet:={If(cTipo=="Pedido","2","3"),cProcesso,cNmFile}
   EndIf

End Sequence

Return aRet

/*
Funcao    : EECChoseFile()
Parametros: Nenhum
Objetivos : Tela de seleção da fase do documento (Auxiliar a função EECHistDoc)
Autor     : Jeferson Barros Jr.
Data/Hora : 31/07/02 11:00
Obs.      : 
*/
*----------------------*
Function EECChoseFile(cRotina)
*----------------------*
Local cTitle:= STR0112 //"Arquivos"
Local cMask:="Formato bmp|*.bmp|Formato jpeg|*.jpg"
Local cFile:=""
Local nDefaultMask:= 1
Local cDefaultDir:= ""
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

Default cRotina := "" //LGS - 28/08/2015

If EECFlags("VISUALIZA_PDF")
   cMask += "|Formato pdf|*.pdf"
EndIf

If cRotina == "FIERGS"
   cMask := "Formato pdf|*.pdf"
EndIf

cFile:= cGetFile( cMask,;
		cTitle,;
		nDefaultMask,;
		cDefaultDir,;
		,;
		nOptions)

Return cFile            

/*
Funcao    : ValFaseProc(cTipo,cProc)
Parametros: cTipo => Fase
            cProc => Processo
Objetivos : Validar Processo. (Auxiliar a função EECHistDoc)
Autor     : Jeferson Barros Jr.
Data/Hora : 31/07/02 15:57
Obs.      : 
*/
*-------------------------------*
Function ValFaseProc(cTipo,cProc)
*-------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE7","EEC"})

Begin Sequence

   If cTipo == "Pedido"
      EE7->(DbSetOrder(1))
      If !EE7->(DbSeek(xFilial("EE7")+cProc))
         lRet:=.f.
      EndIf
   ElseIf cTipo == "Embarque"
      EEC->(DbSetOrder(1))
      If !EEC->(DbSeek(xFilial("EEC")+cProc))
         lRet:=.f.
      EndIf
   EndIf

   If !lRet
      MsgStop(STR0113,STR0085) //"Processo inválido para a fase selecionada."###"Atenção"
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao    : TrataFileName(cFileName).
Parametros: cFileName - Nome do arquivo.
Objetivos : Tratar nome do arquivo para buscar a sequência de arquivos/(Auxiliar a função EECHistDoc).
Retorno   : cRet = File name tratado.
Autor     : Jeferson Barros Jr.
Data/Hora : 01/08/03 14:47.
Obs.      : 
*/
*--------------------------------------*
Static Function TrataFileName(cFileName)
*--------------------------------------*
Local cRet := cFileName, nPos := 0

Begin Sequence

   cFileName := AllTrim(cFileName)
   nPos := At("-",cFileName)

   If nPos <> 0
      cRet := Left(cFileName,nPos-1)
   EndIf
   
End Sequence

Return cRet                          

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 30/01/07 - 11:20
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Local aComexContent := {}  // GFP - 18/03/2015
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case
   
      Case cOrigem $ "EICA150" //Cadastro de Moedas
           Aadd(aRotina, {STR0015,   "AxPesqui"   , 0 , 1})      //"Pesquisar"
           Aadd(aRotina, { STR0016,   "AxVisual"  , 0 , 2})      //"Visualizar"
           Aadd(aRotina, { STR0017,   "AxInclui"  , 0 , 3})      //"Incluir"
           Aadd(aRotina, { STR0018,   "AxAltera"  , 0 , 4})      //"Alterar"
           Aadd(aRotina, { STR0019,   "I150Deleta", 0 , 5,3})    //"Excluir"
      
           If EasyEntryPoint("IA150MNU")
	          aRotAdic := ExecBlock("IA150MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      
      Case cOrigem $ "EICA140" //Taxas de Conversão

           Aadd(aRotina, { STR0030,  "AxPesqui"     , 0 , 1})      //"Pesquisar"
           Aadd(aRotina, { STR0031,   "AxVisual"    , 0 , 2})      //"Visualizar"
           Aadd(aRotina, { STR0032,   "EICA140Manut", 0 , 3})      //"Incluir"
           Aadd(aRotina, { STR0033,   "EICA140Manut", 0 , 4})      //"Alterar"
           Aadd(aRotina, { STR0034,   "AxDeleta"    , 0 , 5,3} )   //"Excluir"
           If FindFunction("EICCD100") //.AND. FindFunction("EasyComexDataQA")   // GFP - 18/03/2015
              aAdd(aComexContent,{ STR0146  , "CD100MenuCnt" , 0 , 3})  // "Configurações" // GFP - 18/03/2015
              aAdd(aComexContent,{ STR0147  , "CD100IntTx"   , 0 , 3})  // "TOTVS Comex Conteúdo - Taxas" //GFP - 18/03/2015
              Aadd(aRotina, { STR0138, aComexContent , 0 , 0})      //"ComexContent"
           EndIf
           
           If EasyEntryPoint("IA140MNU")
	          aRotAdic := ExecBlock("IA140MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf               
   
      Case cOrigem $ "EICA060" // Condição de Pagamento
           Aadd(aRotina, {STR0009,    "AxPesqui"   , 0 , 1})         //"Pesquisar"
           Aadd(aRotina, { STR0010,   "AxVisual"   , 0 , 2})         //"Visualizar"
           Aadd(aRotina, { STR0011,   "EA060Manut" , 0 , 3})         //"Incluir"
           Aadd(aRotina, { STR0012,   "EA060Manut" , 0 , 4})         //"Alterar"
           Aadd(aRotina, { STR0013,   "I60Deleta"  , 0 , 5,3})       //"Excluir"
           
           If EasyEntryPoint("IA060MNU")
	          aRotAdic := ExecBlock("IA060MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf           
           
      Case cOrigem $ "EICA030" //Unidade Requisitante
           Aadd(aRotina, { STR0021,  "AxPesqui"        , 0 , 1})        //"Pesquisar"
           Aadd(aRotina, { STR0022,   "AxVisual"       , 0 , 2})        //"Visualizar"
           Aadd(aRotina, { STR0023,   "EICA030MANUT"   , 0 , 3})        //"Incluir"
           Aadd(aRotina, { STR0024,   "EICA030MANUT"   , 0 , 4})        //"Alterar"
           Aadd(aRotina, { STR0025,   "EA030Del"       , 0 , 5,3} )     //"Excluir"
           
           If EasyEntryPoint("IA030MNU")
	          aRotAdic := ExecBlock("IA030MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      
      Case cOrigem $ "EICA300" // IPI de Pauta
           Aadd(aRotina, { "Pesquisar", "AxPesqui"  , 0 , 1})
           Aadd(aRotina, { "Visualizar","AxVisual"  , 0 , 2})
           Aadd(aRotina, { "Incluir",   "AxInclui"  , 0 , 3})
           Aadd(aRotina, { "Alterar",   "AxAltera"  , 0 , 4})
          // Aadd(aRotina, { "Excluir",   "AxDeleta"  , 0 , 5,3} )
           Aadd(aRotina, { "Excluir",   "EICA300Del"  , 0 , 5,3} )//ACB - 29/12/2010
           
           If EasyEntryPoint("IA300MNU")
	          aRotAdic := ExecBlock("IA300MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      
      Case cOrigem $ "EICY0100"
           Aadd(aRotina, { STR0027 ,"AXPESQUI", 0 , 1} )     //"Pesquisar"          
           
           //AAF 03/12/2007 - Removida variável cROTDOC.
           //Aadd(aRotina, { STR0028 , cROTDOC  , 0 , 2} )     //"Visualizar"
           
           If nModulo == 29
              aAdd(aRotina,{ STR0028,"EECHistDoc",0,2})   //"Visualizar"
              aAdd(aRotina,{ STR0023,"EECHistDoc",0,3})   // Incluir
              aAdd(aRotina,{ STR0025,"EECHistDoc",0,5,3}) // Excluir
           Else
              aAdd(aRotina,{ STR0028,"AvDocView",0,2})   //"Visualizar"
           EndIf
           
           If EasyEntryPoint("EY0100MNU")
	          aRotAdic := ExecBlock("EY0100MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      OtherWise
           aRotina := StaticCall(MATXATU,MENUDEF)
     
   End Case

End Sequence   

Return aRotina
/*
Funcao     : EI6Valid()
Parametros : cCampo
Retorno    : 
Objetivos  : Validação da Tabela EI6
Autor      : Saimon Vinicius Gava	
Data/Hora  : 30/07/2009
*/
Function EI6Valid(cCampo)

Do Case
   Case cCampo == "EI6_CALIPI"
      If M->EI6_CALIPI == "2"
         lCalcIpi := .F.
      Else
         lCalcIpi := .T.
      EndIf
EndCase

Return


/*
Função     : CallHistProc()
Parâmetros : cFilial = Filial do processo
             cChave  = Chave de busca do documento.
Retorno    : 
Objetivos  : Exibir documento quando chamado de outra rotina.
Autor      : Jean Victor Rocha
Data/Hora  : 20/08/2009
*/                                                
*-----------------------------------*
Function AvCallHistProc(cFil, cChave)
*-----------------------------------*
Local lRet   := .T.
Local cAlias := "SY0"
Local nOpc   := VISUALIZAR
Local nReg

(cAlias)->(DbSetOrder(1))
If (cAlias)->(DbSeek(cFil + cChave))
   nReg := SY0->(Recno())
   EECHistDoc(cAlias, nReg, nOpc)
EndIf

Return lRet

/*
Funcao     : GeraDados()
Parametros : cAlias, aDeletados
Retorno    : aRet - array com os dados
Objetivos  : Gerar os dados para exportar para Excel
Autor      : Tamires Daglio Ferreira	
Data/Hora  : 19/05/2010
*/
*--------------------------------*
Function GeraDados(cAlias, aDeletados)    
*--------------------------------*
Local aRet:= {}
Local nCont, i
Local aTemp:= {}
Local nTamArray
Local nTamWork
Local aCabecalho := {}
Default aDeletados := {}

(cAlias)->(DbGotop())
nTamWork:= (cAlias)->(FCount())

If Len(aDeletados) # 0  // GFP - 22/05/2014
   For nCont:= 1 to nTamWork
      aAdd(aCabecalho, (cAlias)->(Field(nCont)))
   Next
EndIf

Do While (cAlias)->(!EOF())
   For nCont:= 1 to nTamWork
       Aadd(aTemp,(cAlias)->(FieldGet(nCont)))
   Next
   Aadd(aRet, aTemp)
   aTemp:= {}   
   (cAlias)->(Dbskip())
EndDo
 
nCont:= 0
nTamArray:= Len(aRet)
/*
//Acrescenta último campo - Deletados - TDF - 13/08/2010 -- nopado por MPG 29/01/2019 ... não se deve mais olhar para esse parâmetro.
If !EasyGParam("MV_EASYTMP",,.F.)
    If (cAlias)->(FieldPos("DELETE")) == 0 .And. (cAlias)->(FieldPos("DBDELETE")) == 0
    For nCont:= 1 to nTamArray 
        Aadd(aRet[nCont],{})
        If !(cAlias)->(DELETED())
            aRet[nCont][nTamWork + 1]:= .F.
        EndIf
    Next 
    EndIf
Endif
*/
If Len(aDeletados) # 0  // GFP - 22/05/2014
   For nCont := 1 to Len(aDeletados)
      If (nPos := aScan(aCabecalho, {|x| x == aDeletados[nCont]})) # 0
         For i := 1 to Len(aRet)
            aDel(aRet[i], nPos)
            aSize(aRet[i], Len(aRet[i])-1)
         Next
         aDel(aCabecalho, nPos)
         aSize(aCabecalho, Len(aCabecalho)-1)
      EndIf
   Next
EndIf

Return aRet

Static Function ChooseFile()

Local cTitle:= STR0136 //"Selecione o diretório para gravação do arquivo."
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
Local cFile := cGetFile(,cTitle,nDefaultMask,cDefaultDir,,nOptions)

Return cFile  

/*
Funcao    : At140ValInt
Parametros: lGrava - Indica se a função foi chamada na gravação das taxas.
Objetivos : Validar a moeda correspondente na tabela SM2, quando o sistema estiver integrado com o módulo SIGAFIN
Autor     : Lucas Raminelli
Data/Hora : 28/08/2014
Obs.      : 
*/
*---------------------------*
Function At140Val(lGrava)
*---------------------------*
Local lRet := .T.
Local lAutoTxMoeda := .F.
Local cEic0067 := AllTrim(EasyGParam("MV_EIC0067",,"")) //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
Local nTaxa:= 0
Private lAtuTaxaMoe //MCF - 16/01/2017
Default lGrava     := .F.

Begin Sequence
   //MFR 17/12/2109 OSSME-4061
   If EasyGParam("MV_EASY",,"N") = "S" .OR. EasyGParam("MV_EASYFIN",,"N") == "S"   // GFP - 26/06/2015
      Do Case

         Case ReadVar() == "M->YE_MOE_FIN"

            If Empty(Val(M->YE_MOE_FIN))
               EasyHelp(STR0123, STR0110) //"Número da moeda inválido", "Aviso" 
               lRet := .F.
            EndIf

         Case ReadVar() == "M->YE_MOEDA"
            //MFR 17/12/2019 OSSME-4061
            M->YE_MOE_FIN := STR(Posicione("SYF", 1, xFilial("SYF") + M->YE_MOEDA, "YF_MOEFAT"), AVSX3('YE_MOE_FIN', 3))
            If Empty(val(M->YE_MOE_FIN))
               M->YE_MOE_FIN := Str(SimbToMoeda(M->YE_MOEDA),AVSX3('YE_MOE_FIN', 3)) // STR(Posicione("SYF", 1, xFilial("SYF") + M->YE_MOEDA, "YF_MOEFAT"), AVSX3('YE_MOE_FIN', 3))
            EndIf   

            /*MFR 17/12/2019 OSSME-4061
            If Empty(Val(M->YE_MOE_FIN))               
               EasyHelp(STR0127, STR0110)  //"Numero da moeda siga não cadastrado na tabela de moedas. Cadastre esta informação para prosseguir.","Aviso"
               lRet:= .F.
               Break
            EndIf
            */

            If SM2->(DBSeek(M->YE_DATA)) .AND. !Empty(Val(M->YE_MOE_FIN))
               nTaxa:= RecMoeda(M->YE_DATA, M->YE_MOE_FIN)
            EndIf
			
            If !Empty(nTaxa) .AND. !Empty(Val(M->YE_MOE_FIN))
			      lAutoTxMoeda:= (Type("lExecAuto") == "L" .And. lExecAuto) .Or. MsgYesNo(STR0124, STR0110) //Foi encontrada taxa para esta moeda no módulo financeiro. Deseja carregar esta cotação?, Aviso
			   EndIf
            
            If lAutoTxMoeda .AND. !Empty(Val(M->YE_MOE_FIN))
               M->YE_VLCON_C := nTaxa
            EndIf

         Otherwise
            /*MFR 17/12/2019 OSSME-4061
            If (Empty(M->YE_MOE_FIN) .Or. Val(M->YE_MOE_FIN) == 0 ) .And. lGrava 
               EasyHelp(STR0125, STR0026)//"Para ambientes com a integração com o módulo SigaFin habilitada é necessário informar a moeda correspondente no SigaFin."###"Aviso"
               lRet := .F.
            EndIf
            */
            
            If(EasyEntryPoint("AVCADGE"),ExecBlock("AVCADGE",.F.,.F.,"ATUALIZA_TAXA"),) //LRS- 12/09/2016
            
            //MCF  - 16/01/2017 //LRS - 12/09/2016 - Controle para alterar o lRet para .F. se o ponto de entrada retorna .F.
            IF lRet .And. Type("lAtuTaxaMoe") == "L"
               lRet :=  lAtuTaxaMoe
            EndIf
            
            If lGrava .And. lRet	.AND. !Empty(Val(M->YE_MOE_FIN))
               If RecMoeda(M->YE_DATA, M->YE_MOE_FIN) <> M->YE_VLCON_C //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
               	if empty(cEic0067)
                		lRet:= (Type("lExecAuto") == "L" .And. lExecAuto) .Or. MsgYesNo(strtran(STR0139, "###", alltrim(Str(M->YE_VLCON_C))), STR0110)//LGS-09/04/2015 - //"A taxa informada nesta cotação diverge da taxa informada no módulo financeiro. Ao confirmar esta gravação, a cotação informada no módulo financeiro será atualizada. Deseja prosseguir?"
                	elseIf Upper(cEic0067) == "S"
               		MsgInfo(STR0168,STR0110)
               	endIf
               EndIf
            EndIf
      End Case
   EndIf

End Sequence

Return lRet  

/*
Funcao    : EicGrvInt
Parametros: lExclui - Indica se foi chamada a partir da exclusão de uma taxa
Objetivos : Sincronizar as taxas cadastradas na tabela SYE com as cadastradas na tabela SM2
Autor     : Lucas Raminelli
Data/Hora : 19/09/2014
Obs.      : 
*/
*---------------------------*
Function EicGrvInt(lExclui)
*---------------------------*
Local lRet    := .T.
Local lAppend := .T.
Local cCpo    := ""
Local nInc
Local nTaxa   := If(EasyGParam("MV_EXP_TX",,"1") == "1", SYE->YE_VLCON_C, SYE->YE_TX_COMP)

Begin Sequence
   ChkFile("SM2")
   
   If Select("SM2") == 0
      lRet := .F.
      Break
   EndIf
   
   If FieldPos("M2_MOEDA" + AllTrim(SYE->YE_MOE_FIN)) == 0
      cCpo := "M2_MOEDA" + AllTrim(SYE->YE_MOE_FIN)
   ElseIf FieldPos("M2_MOED" + AllTrim(SYE->YE_MOE_FIN)) == 0
      cCpo := "M2_MOED" + AllTrim(SYE->YE_MOE_FIN)
   EndIf
   
   If Len(cCpo) == 0
     lRet := .F.
     Break
   EndIf
   
   If !SM2->(DbSeek(SYE->YE_DATA))
      If lExclui
         Break
      EndIf
   Else
      lAppend := .F.
   EndIf
   
   SM2->(RecLock("SM2", lAppend))
   
   If lExclui
      Break
   EndIf
   
   SM2->M2_DATA       := SYE->YE_DATA
   SM2->&(("SM2")->(cCpo)) := nTaxa
   SM2->(MsUnLock())
   
End Sequence

Return lRet

Static Function EECAtuHistDoc(cRotina)
Local i, nPos := 0
Default cRotina := ""
 
	// ** Gravar o nome e diretório do arquivo de imagem.
	For i:=1 To Len(aSelecao[3])
	    If Right(aSelecao[3],i) = "\"
	       Exit
	    EndIf
	    nPos++
	Next
	cDirName  := SubStr(aSelecao[3],1,(Len(aSelecao[3])-(nPos)))
	cFileName := AllTrim(SubStr(aSelecao[3],(Len(aSelecao[3])-(nPos-1))))
	
	// ** Carrega nome do arquivo já tratado para procura das sequências...
	cNameAux  := TrataFileName(cFileName)
	aFiles    := Directory(cDir+AllTrim(cNameAux)+"*.*")
	
	If cRotina == "FIERGS"	
	   M->Y0_ARQPDF  := AvKey(AllTrim(cFileName),"Y0_ARQPDF")
	EndIf

Return

/*
Funcao     : CD100MenuCnt()
Parametros : cAlias, nReg, nOp
Retorno    : Nenhum
Objetivos  : Tratamento para utilização da opção 3, devido a "loop" da inserção automatica
Autor      : Marcos R. R. Cavini Filho - MCF
Data/Hora  : 26/04/2016 - 07:53
*/

Function CD100MenuCnt(cAlias,nReg,nOp)
Default nOp := 0

	If lTelaContent
		nOp := 0
		lTelaContent := .F.
	EndIf

	If nOp == 1
	   CD100CFCONT()
	   lTelaContent := .T.
	EndIf

Return

/*
Funcao     : Easy010NVE()
Parametros : cAlias,nReg,nOpc
Retorno    : NIL
Objetivos  : Função do MATA010 (Produtos) para vinculação de NVE
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 25/10/2016 :: 10:29
*/
*-------------------------------------*
Function Easy010NVE(cAlias,nReg,nOpc)
*-------------------------------------*
Local aOrd := SaveOrd({"SB1","SJL","EIM","EYJ"}), nSelOp := 0
Local oDlgNVE, oMarkEI, cFileWkGEIM,cFileWK_01, cFileWK_02
Local bOk := {|| If(EasyValNVE("OK") .AND. MsgYesNo(STR0155,STR0085),(nSelOp:=1,oDlgNVE:End()),)}, bCancel := {|| (nSelOp:=0,oDlgNVE:End())}
Private aCampos := array(EIM->(fcount())), aSemSX3GEIM := {{"WK_RECNO" , "N", 10,0 },{ "EIM_ALI_WT", "C", 3,0 },{ "EIM_REC_WT", "N", 10,0 }}, aHeader[0], aCols[0]
Private cClassif := ""
PRIVATE bAtributo:={|| Work_EIM->EIM_ATRIB == SJL->JL_ATRIB }
Private aRotina := MenuDef()

SJL->(DbSetOrder(1))
SJK->(DbSetOrder(1))
EIM->(DbSetOrder(3))

Begin Sequence
   If EYJ->(FieldPos("EYJ_NVE")) == 0
      Alert(STR0164 + ENTER + STR0166) //"Seu ambiente não está preparado para executar esta funcionalidade." ## "Esta funcionalidade estará disponível a partir do release 12.1.17."
      Break
   EndIf
   If Empty(SB1->B1_POSIPI)
      Alert(STR0148)  //"Produto não possui NCM vinculada. Não será possível utilizar a classificação NVE."
      Break
   EndIf
   If !SJL->(DBSEEK(xFilial("SJL")+SB1->B1_POSIPI)) .OR. !SJK->(DBSEEK(xFilial("SJK")+SB1->B1_POSIPI))
      Alert(STR0149)  //"Produto não possui NCM válida para utilização da classificação NVE."
      Break
   Else
      cClassif := SJL->JL_NIVEL
   EndIf

   If Select("Work_EIM") # 0
      Work_EIM->(DbCloseArea())
   EndIf
   
   aAdd(aSemSX3GEIM,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
   cFileWkGEIM := E_CriaTrab("EIM",aSemSX3GEIM,"Work_EIM",,)

   cFileWK_01 := E_Create(,.F.)
   IndRegua("Work_EIM" ,cFileWK_01+TEOrdBagExt() ,"EIM_ADICAO+EIM_NIVEL+EIM_ATRIB+EIM_ESPECI")   
   cFileWK_02 := E_Create(,.F.)
   IndRegua("Work_EIM" ,cFileWK_02+TEOrdBagExt() ,"EIM_CODIGO")       
   SET INDEX TO (cFileWK_01+TEOrdBagExt()),(cFileWK_02+TEOrdBagExt())

   aHeader := {}
   //aAdd(aHeader,{AvSx3("EIM_NIVEL",5) ,"EIM_NIVEL"  ,AvSx3("EIM_NIVEL" ,6),AvSx3("EIM_NIVEL",3),0,"",Posicione("SX3",2,"EIM_NIVEL","X3_USADO") ,AvSx3("EIM_NIVEL",2),"EIT"})
   aAdd(aHeader,{AvSx3("EIM_ATRIB",5) ,"EIM_ATRIB"  ,AvSx3("EIM_ATRIB" ,6),AvSx3("EIM_ATRIB",3),0,"",Posicione("SX3",2,"EIM_ATRIB","X3_USADO") ,AvSx3("EIM_ATRIB",2),"EIT"})
   aAdd(aHeader,{AvSx3("EIM_DES_AT",5),"EIM_DES_AT" ,AvSx3("EIM_DES_AT",6),AvSx3("EIM_DES_AT",3),0,"",Posicione("SX3",2,"EIM_DES_AT","X3_USADO") ,AvSx3("EIM_DES_AT",2),"EIT"})
   aAdd(aHeader,{AvSx3("EIM_ESPECI",5),"EIM_ESPECI" ,AvSx3("EIM_ESPECI",6),AvSx3("EIM_ESPECI",3),0,"",Posicione("SX3",2,"EIM_ESPECI","X3_USADO") ,AvSx3("EIM_ESPECI",2),"EIT"})
   aAdd(aHeader,{AvSx3("EIM_DES_ES",5),"EIM_DES_ES" ,AvSx3("EIM_DES_ES",6),AvSx3("EIM_DES_ES",3),0,"",Posicione("SX3",2,"EIM_DES_ES","X3_USADO") ,AvSx3("EIM_DES_ES",2),"EIT"})
   //aAdd(aHeader,{AvSx3("EIM_CODIGO",5),"EIM_CODIGO" ,AvSx3("EIM_CODIGO",6),AvSx3("EIM_CODIGO",3),0,"",Posicione("SX3",2,"EIM_DES_ES","X3_USADO") ,AvSx3("EIM_CODIGO",2),"EIT"})

//   MFR 23/11/2018   
//   If EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))
     If EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))

//   MFR 23/11/2018
//   Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SB1->B1_COD,"EIM_HAWB")
     Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == GetFilEIM("CD") .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SB1->B1_COD,"EIM_HAWB")
         Work_EIM->(DBAPPEND())
         AvReplace("EIM","Work_EIM")
         Work_EIM->EIM_FASE := "CD"
        // Work_EIM->EIM_FILIAL := GetFilEIM("CD")
         cClassif           := EIM->EIM_NIVEL
         Work_EIM->EIM_NCM  := SB1->B1_POSIPI
         EIM->(DbSkip())
      EndDo
   ENDIF

   DEFINE MSDIALOG oDlgNVE TITLE STR0150 FROM 0,0 TO 28,If(SetMDIChild(),109,99) Of oMainWnd //"Manutenção de NVE"
          
      nMeio :=400
      nLinha:=35

      @ nLinha+1,05 SAY "Cod. Produto" OF oDlgNVE PIXEL //"Cod. Produto"
      @ nLinha  ,55 MSGET SB1->B1_COD PICTURE AVSX3("B1_COD",6) SIZE 50,08 PIXEL WHEN .F.
      
      @ nLinha+1,105 SAY "Descrição" OF oDlgNVE PIXEL  //"Descrição"
      @ nLinha  ,135 MSGET SB1->B1_DESC PICTURE AVSX3("B1_DESC",6) SIZE 120,08 PIXEL WHEN .F.
      
      @ nLinha+1,275 SAY STR0151 OF oDlgNVE PIXEL //"N.C.M."
      @ nLinha  ,305 MSGET SB1->B1_POSIPI PICTURE AVSX3("W3_TEC",6) F3 "SJ_" SIZE 45,08 PIXEL WHEN .F.
      
      @ nLinha+1,375 SAY "Nível Classif." OF oDlgNVE PIXEL  //"Nível Classif."
      @ nLinha  ,410 COMBOBOX oClassif VAR cClassif ITEMS StrTokArr(AllTrim(Posicione("SX3",2,"EIM_NIVEL","X3_CBOX")),";") SIZE 75,08 PIXEL WHEN .F.
      
      Work_EIM->(DbSetOrder(0))
      
      oMarkEI:=MsGetDB():New(nLinha+15,1,oDlgNVE:nClientHeight-30,oDlgNVE:nClientWidth+295,If(Work_EIM->(EasyRecCount("Work_EIM")) == 0, 3, 4),'EasyValNVE("LINHA")','EasyValNVE("OK")',"",.T.,,,.F.,,"Work_EIM",'EasyValNVE("CAMPO")',.F.,,oDlgNVE,.T.)
      oMarkEI:ForceRefresh()

      oDlgNVE:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlgNVE ON INIT (EnchoiceBar(oDlgNVE,bOk,bCancel)) CENTERED //"Confirma a gravação?" ## "Atenção"

   If nSelOp == 1
      GravaNVE()
   EndIf
   
   If Select("Work_EIM") # 0
      Work_EIM->(DbCloseArea())
   EndIf
   
End Sequence

RestOrd(aOrd,.T.)
Return

*-------------------------------------*
Function EasyExcNVE(cCod_I)
*-------------------------------------*
EIM->(DbSetOrder(3))
If EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(cCod_I,"EIM_HAWB")))
   Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(cCod_I,"EIM_HAWB")
      EIM->(RecLock("EIM",.F.))
      EIM->(DbDelete())
      EIM->(MsUnlock())
      EIM->(DbSkip())
   EndDo
EndIf
Return .T.

*-------------------------------------*
Function EasyNVEChk(lVal)
*-------------------------------------*
Static lExcNVE

    If lVal <> Nil
        lExcNVE := lVal
    EndIf

Return lExcNVE


*-------------------------------------*
Function EasyValNVE(cTipo)
*-------------------------------------*
Local aOrd := SaveOrd({"SJL","SJK"}), T, cTECSeek := "", cCodigo := "", nTamTEC := 0, cCampo, nRecWk, cChave

Do Case
   Case cTipo == "CAMPO"
      cCampo := SubStr(ReadVar(),4,Len(ReadVar()))
      If cCampo == "EIM_ATRIB"
         If Work_EIM->EIM_ATRIB # M->EIM_ATRIB
            Work_EIM->EIM_ESPECI := ""
            Work_EIM->EIM_DES_ES := ""
         EndIf
         SJK->(DbSetOrder(1))
         If SJK->(DBSEEK(xFilial("SJK")+AvKey(SB1->B1_POSIPI,"JK_NCM")+AvKey(M->EIM_ATRIB,"JK_ATRIB")))
            Work_EIM->EIM_NIVEL := If(Empty(Work_EIM->EIM_NIVEL),SJK->JK_NIVEL,Work_EIM->EIM_NIVEL)
            Work_EIM->EIM_DES_AT := SJK->JK_DES_ATR
         Else
            Alert(STR0157)//"Atributo não localizado para essa NVE."
            Work_EIM->EIM_DES_AT := ""
            Work_EIM->(DbSetOrder(0))
            Return .F.
         EndIf
         nRecWk := Work_EIM->(Recno())
         cChave := Work_EIM->EIM_NIVEL+M->EIM_ATRIB
         Work_EIM->(DbGoTop())
         Do While Work_EIM->(!Eof())
            If Work_EIM->(Recno()) <> nRecWk .AND. Work_EIM->EIM_NIVEL+Work_EIM->EIM_ATRIB == cChave .And. Posicione('SJK',1,xFilial("SJK")+AvKey(SB1->B1_POSIPI,"JK_NCM")+AvKey(M->EIM_ATRIB,"JK_ATRIB"),'JK_MULTIPL') == 'N'
               Alert(STR0163) //"Atributo não pode ser duplicado."  
               Work_EIM->(DbGoTo(nRecWk))
               Work_EIM->(DbSetOrder(0))
               Return .F.
            EndIf
            Work_EIM->(DbSkip())
         EndDo
         SJL->(DbSetOrder(1))
         If !SJL->(DBSEEK(xFilial("SJL")+AvKey(SB1->B1_POSIPI,"JL_NCM")+AvKey(M->EIM_ATRIB,"JL_ATRIB")))
            Alert(STR0177) //"Não existem especificações cadastradas para este atributo!"
            Work_EIM->(DbGoTo(nRecWk))
            Return .F.      
         EndIF
         Work_EIM->(DbGoTo(nRecWk))
      ElseIf cCampo == "EIM_ESPECI"
         SJL->(DbSetOrder(1))
         If SJL->(DBSEEK(xFilial("SJL")+AvKey(SB1->B1_POSIPI,"JL_NCM")+AvKey(Work_EIM->EIM_ATRIB,"JL_ATRIB")+AvKey(M->EIM_ESPECI,"JL_ESPECIF")))
            Work_EIM->EIM_NIVEL := If(Empty(Work_EIM->EIM_NIVEL),SJL->JL_NIVEL,Work_EIM->EIM_NIVEL)
            Work_EIM->EIM_DES_ES := SJL->JL_DES_ESP
         Else
            Alert(STR0158)//"Especificação para Valoração não localizada para essa NVE."
            Work_EIM->EIM_DES_ES := ""
            Work_EIM->(DbSetOrder(0))
            Return .F.
         EndIf
         nRecWk := Work_EIM->(Recno())
         cChave := Work_EIM->EIM_NIVEL+Work_EIM->EIM_ATRIB+M->EIM_ESPECI
         Work_EIM->(DbGoTop())
         Do While Work_EIM->(!Eof())
            If Work_EIM->(Recno()) <> nRecWk .AND. Work_EIM->EIM_NIVEL+Work_EIM->EIM_ATRIB+Work_EIM->EIM_ESPECI == cChave
               Alert(STR0176) //"Especificação não pode ser duplicada para um mesmo atributo." 
               Work_EIM->(DbGoTo(nRecWk))
               Work_EIM->EIM_DES_ES := If(Empty(Work_EIM->EIM_ESPECI),"",Posicione("SJL",1,xFilial()+cTECSeek+Work_EIM->EIM_ATRIB+Work_EIM->EIM_ESPECI,"JL_DES_ESP"))
               Return .F.
            EndIf
            Work_EIM->(DbSkip())
         EndDo
         Work_EIM->(DbGoTo(nRecWk))
      EndIf
   Case cTipo == "OK"
      Work_EIM->(DbGoTop())
      Do While Work_EIM->(!Eof())
         If !EasyValNVE("LINHA")
            Work_EIM->(DbSetOrder(0))
            Return .F.
         EndIf
         //If Empty(Work_EIM->EIM_CODIGO)
            Work_EIM->EIM_CODIGO := "001"
         //EndIf
         Work_EIM->(DbSkip())
      EndDo
      ConfirmSX8()
      Work_EIM->(DbGoTop())
   Case cTipo == "LINHA"
      IF Work_EIM->DBDELETE
         RETURN .T.
      ENDIF   
      IF /*EMPTY(Work_EIM->EIM_NIVEL) .OR. */EMPTY(Work_EIM->EIM_ATRIB) .OR. EMPTY(Work_EIM->EIM_ESPECI)
         Alert(STR0152)//"Campos obrigatórios não preenchidos"
         Work_EIM->(DbSetOrder(0))
         Return .F.
      ENDIF
      SJL->(DBSETORDER(1))//JL_FILIAL+JL_NCM+JL_ATRIB+JL_ESPECIF
      cTECSeek := SB1->B1_POSIPI
      nTamTEC := LEN(SB1->B1_POSIPI)
      FOR T := 1 TO nTamTEC
         IF !SJL->(DBSEEK(xFilial("SJL")+cTECSeek))
            cTECSeek := LEFT(SB1->B1_POSIPI,nTamTEC-T)+SPACE(T)
         ELSE
            Work_EIM->EIM_NIVEL := If(Empty(Work_EIM->EIM_NIVEL),SJK->JK_NIVEL,Work_EIM->EIM_NIVEL)
            EXIT
         ENDIF
      NEXT
      IF !SJL->(DBSEEK(xFilial("SJL")+cTECSeek+AvKey(Work_EIM->EIM_ATRIB,"JL_ATRIB")+AvKey(Work_EIM->EIM_ESPECI,"JL_ESPECIF")))
         Alert(STR0153)//"NCM nao possui essa NVE no Cadastro de Especificações para Valoração."
         Work_EIM->(DbSetOrder(0))
         Return .F.
      ELSE
         Work_EIM->EIM_NIVEL := If(Empty(Work_EIM->EIM_NIVEL),SJK->JK_NIVEL,Work_EIM->EIM_NIVEL)
         IF SJL->JL_NIVEL # Work_EIM->EIM_NIVEL
            Alert(STR0154 + SJL->JL_NIVEL)//"NCM atual, Atributo e Especificacao nao possui este Nível. Nível da NCM atual: "
            Work_EIM->(DbSetOrder(0))
            Return .F.
         EndIf
      ENDIF
      SJK->(DBSETORDER(1))
      If !SJK->(DBSEEK(xFilial("SJK")+AvKey(SB1->B1_POSIPI,"JK_NCM")+AvKey(Work_EIM->EIM_ATRIB,"JK_ATRIB")))
         Alert(STR0156)//"NCM nao possui essa NVE no Cadastro de Atributos."
         Work_EIM->(DbSetOrder(0))
         Return .F.
      EndIf
   Case cTipo == "MATA010"
      ExcluiNVE()
   Case cTipo == "EIM_ATRIB"
      If "MATA011" $ FUNNAME()
         If Empty(M->EIM_ATRIB)
            M->EIM_DES_AT := ""
         Else
            SJK->(DbSetOrder(1))
            If !SJK->(DBSEEK(xFilial("SJK")+AvKey(SB1->B1_POSIPI,"JK_NCM")+AvKey(M->EIM_ATRIB,"JK_ATRIB")))
               Alert(STR0159)  //"NCM atual nao possui esse Atributo."
               Work_EIM->(DbSetOrder(0))
               Return .F.
            ElseIf SJK->JK_NIVEL # M->EIM_NIVEL
               Alert(STR0160)  //"NCM atual e Atributo nao possuem esse Nivel."
               Work_EIM->(DbSetOrder(0))
               Return .F.
            Else
                M->EIM_DES_AT := SJK->JK_DES_ATR
            EndIf
         EndIf
      ElseIf "EICDI5" $ FUNNAME()
         Return DI_VAL_EIJ()
      Else
         Return GI400NVEVAL("EIM_ATRIB")
      EndIf 
   Case cTipo == "EIM_ESPECI"
      If "MATA011" $ FUNNAME()
         If Empty(M->EIM_ATRIB)
            M->EIM_DES_ES := ""
         Else
            SJL->(DbSetOrder(1))
            If !SJL->(DBSEEK(xFilial("SJL")+AvKey(SB1->B1_POSIPI,"JL_NCM")+AvKey(M->EIM_ATRIB,"JL_ATRIB")+AvKey(M->EIM_ESPECI,"JL_ESPECIF")))
               Alert(STR0161)  //"NCM atual e Atributo nao possui essa Especificacao."
               Work_EIM->(DbSetOrder(0))
               Return .F.
            ElseIf SJL->JL_NIVEL # M->EIM_NIVEL
               Alert(STR0162)  //"NCM atual, Atributo e Especificação nao possuem esse Nivel."
               Work_EIM->(DbSetOrder(0))
               Return .F.
            Else
                M->EIM_DES_ES := SJL->JL_DES_ESP
            EndIf
         EndIf
      ElseIf "EICDI5" $ FUNNAME()
         Return DI_VAL_EIJ()
      Else
         Return GI400NVEVAL("EIM_ESPECI")
      EndIf 
End Case

DbSelectArea("SB1")

RestOrd(aOrd,.T.)
Return .T.

*--------------------------*
Static Function GravaNVE()
*--------------------------*
Local lSeek := .F.

EYJ->(DbSetOrder(1))
EIM->(DbSetOrder(3))

//MFR 23/22/2018
//EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))

EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))
DO While !EIM->(Eof()) .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SB1->B1_COD,"EIM_HAWB")
   IF EIM->(RECLOCK("EIM",.F.))
      EIM->(DBDELETE())
      EIM->(MSUNLOCK())
   ENDIF
   EIM->(dbSkip())
ENDDO

/*If EYJ->(DbSeek(xFilial("EYJ") + AvKey(SB1->B1_COD,"EYJ_COD") ))
   IF EYJ->(RECLOCK("EYJ",.F.))
      EYJ->EYJ_NVE := ""
      EYJ->(MSUNLOCK())
   ENDIF
EndIf*/

Work_EIM->(DbGoTop())
Do While Work_EIM->(!Eof())
   If Work_EIM->DBDELETE
      Work_EIM->(DbSkip())
      Loop
   EndIf
   If RecLock("EIM",.T.)
      AvReplace("Work_EIM","EIM")
      EIM->EIM_HAWB := SB1->B1_COD
      EIM->EIM_NCM  := SB1->B1_POSIPI
      EIM->EIM_FASE := "CD"
      EIM->EIM_FILIAL := GetFilEIM("CD")
      EIM->(MsUnlock())
   EndIf
   Work_EIM->(DbSkip())
EndDo
Return .T.

*--------------------------*
Static Function ExcluiNVE()
*--------------------------*
EIM->(DbSetOrder(3))
EYJ->(DbSetOrder(1))
//MFR 23/11/2018
//If EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))
//   Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SB1->B1_COD,"EIM_HAWB")
  If EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")))
   Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == GetFilEIM("CD") .AND. EIM->EIM_FASE == AvKey("CD","EIM_FASE") .AND. EIM->EIM_HAWB == AvKey(SB1->B1_COD,"EIM_HAWB")
      If RecLock("EIM",.F.)
         EIM->(DbDelete())
         EIM->(MsUnlock())
      EndIf
      EIM->(DbSkip())
   EndDo
EndIf

Return NIL

Function EasyNVESXB(cAlias)
Local xRet := .T., bAtributo

Do Case
   Case cAlias == "SJK"
      If "MATA010" $ FUNNAME()
         xRet := SJK->JK_NCM == SB1->B1_POSIPI
      ElseIf "EICGI400" $ FUNNAME()
         xRet := SJK->JK_NCM == M->W5_TEC
      Else
         xRet := SJK->JK_NCM == M->EIJ_TEC
      EndIf
   Case cAlias == "SJL"
      If "MATA010" $ FUNNAME()
         bAtributo := {|| Work_EIM->EIM_ATRIB == SJL->JL_ATRIB }
         xRet := SB1->B1_POSIPI == SJL->JL_NCM .And. EVAL(bAtributo)
      Else
         bAtributo := {|| Work_GEIM->EIM_ATRIB == SJL->JL_ATRIB }
         xRet := WORK->WKTEC == SJL->JL_NCM  .And. EVAL(bAtributo)
      EndIf
End Case
Return xRet

/*
Função     : EA110RefCirc
Objetivo   : Verificar se determinada despesa base dos impostos(II,ICMS) na tabela de pré-cálculo possui
             tais impostos como base ou outras despesas base que possuam tais impostos na sua base (ref. circular)
Parametros : cOpccImpVal -> Tipo do Imposto a verificar (II ou ICMS)
             cDespAnt -> A despesa atual que referencia a primeira despesa verificada
             cDespAtu -> A despesa atual sendo verificada
             cListDspBs -> despesas base da despesa atual
             cAlias -> Alias do arquivo a ser verificado (TRB ou SWI)
             cViaTPC -> Via de Transporte para posicionamento da tabela
             cTabPC -> Cod. da tabela de pré-cálculo para posicionamento
             lRaiz -> .T. determina que a despesa é a primeira despesa base de imposto para referência na busca
             lMsg -> Determina se exibe mensagens de alerta caso encontre referências circulares.
             cOrig -> "CAD" quando for chamada do cadastro da tabela ou "PROC" quando for processamento (Pre-Calculo/Ger.Titulos/Prev.Desembolso)
             cCodImp -> Código do importador (somente necessário quando cOrig por "PROC" e se tratar de verificar UF do ICMS) 
Retorno    : aRet[1] -> .T. caso exista referencia circular na relação entre as despesas base
             aRet[2] -> .T. caso haja algum problema na relação que se seja impeditivo de continuidade na função chamada
Autor      : Nilson César
Data/Hora  : Jan/2018
*/
*---------------------------------------------------------------------------------------------------------------------
Function EA110RefCirc(cImpVal,cDespAnt,cDespAtu,cListDspBs,cAlias,cViaTPC,cTabTPC,lRaiz,lMsg,cOrig,cCodImp,lValSoDspB)
*---------------------------------------------------------------------------------------------------------------------
Local aDesp := {}
Local lRet := .F., lImpeditivo := .F.
Local I, bAval_II, bAval_ICMS, bAval_Desps  
Local aOrdTabs
Local aRet := {lRet,lImpeditivo}
Local cMsgGet := ""
Local nOrdWI, nRecWI
Default cListDspBs := ""
Default cOrig := "CAD" 
Default lValSoDspB := .T.
If cAlias == "SWI"
   nOrdWI := SWI->(IndexOrd())
   nRecWI := SWI->(Recno())
   SWI->(DbSetOrder(2))
   If SWI->(DbSeek(xFilial("SWI")+cViaTPC+cTabTPC+cDespAtu))
      If Empty(cListDspBs)
         cListDspBs := SWI->WI_DESPBAS   
      EndIf
   Else
      SWI->(DbSetOrder(nOrdWI))
      SWI->(DbGoTo(nRecWI))
      aRet := {.F.,.T.} //Não é possível definir sem a despesa principal não posicionada
      Return aRet
   EndIf   
EndIf

AADD(aDesp,SUBSTR(cListDspBs,1,3))
AADD(aDesp,SUBSTR(cListDspBs,4,3))
AADD(aDesp,SUBSTR(cListDspBs,7,3))

If lRaiz
   bAval_II   := {||  !(Left(cDespAtu,1) $ "129") .And. If(lValSoDspB,IsDspBasIm("II"  ,cDespAtu,cOrig        ),.T.)  .And. If(lValSoDspB, (nPos := aScan(aDesp,{|x| x $ "104|201"}) ), (Left(cDespAtu,1) $ "129") )   }
   bAval_ICMS := {||  !(Left(cDespAtu,1) $ "129") .And. If(lValSoDspB,IsDspBasIm("ICMS",cDespAtu,cOrig,cCodImp),.T.)  .And. If(lValSoDspB, (nPos := aScan(aDesp,{|x| x $ "203"    }) ), (Left(cDespAtu,1) $ "129") )   } 
   bAval_Desps:= {||  !(Left(cDespAtu,1) $ "129") .And. If(lValSoDspB,If( cImpVal == "II", IsDspBasIm("II"  ,cDespAtu,cOrig) , IsDspBasIm("ICMS",cDespAtu,cOrig,cCodImp) ),.T.) }
Else
   bAval_II   := {||   If(lValSoDspB, cDespAtu $ "201" , Left(cDespAtu,1) $ "129") } //{||   cDespAtu $ "201" .Or. !(Left(cDespAtu,1) $ "129")    }   
   bAval_ICMS := {||   If(lValSoDspB, cDespAtu $ "203" , Left(cDespAtu,1) $ "129") } //{||   cDespAtu $ "203" .Or. !(Left(cDespAtu,1) $ "129")    }   
   bAval_Desps:= {||   !(Left(cDespAtu,1) $ "129")  }
EndIf

If cImpVal == "II"
   If Eval(bAval_II)//!(Left(cDespAtu,1) $ "129") .And. ( IsDspBasIm("II",cDespAtu,"CAD") .And. (nPos := aScan(aDesp,{|x| x $ "104|201"})) > 0 ) 
      If lMsg
         If lRaiz
            cMsgGet := STRTRAN(STR0169,"<COD.DESP.EDIC>",cDespAnt) //"A despesa <COD.DESP.EDIC> possui o imposto <COD.DESP.BASE> em sua base de calculo e está configurada como despesa base de <TIPO.IMP>. A mesma não será considerada no calculo dos impostos!"
            cMsgGet := STRTRAN(cMsgGet,"<COD.DESP.BASE>",aDesp[nPos])
            cMsgGet := STRTRAN(cMsgGet,"<TIPO.IMP>"     ,"Imposto(I.I)")
         Else
            cSTR0170 := "A despesa <COD.IMP> foi encontrada como despesa base de uma das dependências (Despesa: <COD.DEP> ) para cálculo desta despesa. Portanto, esta despesa não será calculada com o valor destas dependências na base de cálculo!"
            cMsgGet := STRTRAN(cSTR0170,"<COD.IMP>","201(I.I)")
            cMsgGet := STRTRAN(cMsgGet ,"<COD.DEP>",cDespAnt)
         EndIf
         MsgAlert(cMsgGet,STR0004)
      EndIf
      aRet := { lRet := .T. , lImpeditivo := .F.} 
   ElseIf Eval(bAval_Desps)
      aOrdTabs := If(cAlias == "TRB", SaveOrd("TRB"), SaveOrd("SWI"))
      FOR I:=1 TO LEN(aDesp)
         If !Empty(aDesp[I])
            If If(cAlias == "TRB", TRBPosDspTPC(aDesp[I]) , SWI->(DbSeek( xFilial("SWI")+cViaTPC+cTabTPC+aDesp[I] )) ) 
               aRet := EA110RefCirc(cImpVal,cDespAtu,(cAlias)->WI_DESP,(cAlias)->WI_DESPBAS,cAlias,cViaTPC,cTabTPC,.F.,lMsg,cOrig)
            Else
               If lMsg
                  MsgAlert("A Despesa '"+aDesp[I]+"' não foi encontrada entre as despesas relacionadas da tabela atual!")
               EndIf
               aRet := { lRet := .F. , lImpeditivo := .T.} 
            EndIf
            If aRet[1]
               EXIT     //Se encontrada a referencia circular, sai do loop
            EndIf
         EndIf
      NEXT I
      RestOrd(aOrdTABs,.T.)
   EndIf
ElseIf cImpVal == "ICMS" 
   If Eval(bAval_ICMS)//!(Left(cDespAtu,1) $ "129") .And. ( IsDspBasIm("ICMS",cDespAtu,"CAD") .And. (nPos := aScan(aDesp,{|x| x $ "203"})) > 0 )
      If lMsg
         If lRaiz
            cMsgGet := STRTRAN(STR0169,"<COD.DESP.EDIC>",cDespAnt) //"A despesa <COD.DESP.EDIC> possui o imposto <COD.DESP.BASE> em sua base de calculo e está configurada como despesa base de <TIPO.IMP>. A mesma não será considerada no calculo dos impostos!"
            cMsgGet := STRTRAN(cMsgGet,"<COD.DESP.BASE>",aDesp[nPos])
            cMsgGet := STRTRAN(cMsgGet,"<TIPO.IMP>"     ,"I.C.M.S")
         Else
            cSTR0170 := "A despesa <COD.IMP> foi encontrada como despesa base de uma das dependências (Despesa: <COD.DEP> ) para cálculo desta despesa. Portanto, esta despesa não será calculada com o valor destas dependências na base de cálculo!"
            cMsgGet := STRTRAN(cSTR0170,"<COD.IMP>","203(I.C.M.S)")
            cMsgGet := STRTRAN(cMsgGet ,"<COD.DEP>",cDespAnt)
         EndIf
         MsgAlert(cMsgGet,STR0004)
      EndIf
      aRet := { lRet := .T. , lImpeditivo := .F.}
   ElseIf Eval(bAval_Desps)
      aOrdTabs := If(cAlias == "TRB", SaveOrd("TRB"), SaveOrd("SWI"))
      FOR I:=1 TO LEN(aDesp)
         If !Empty(aDesp[I])
            If If(cAlias == "TRB", TRBPosDspTPC(aDesp[I]) , SWI->(DbSeek( xFilial("SWI")+cViaTPC+cTabTPC+aDesp[I] )) ) 
               aRet := EA110RefCirc(cImpVal,cDespAtu,(cAlias)->WI_DESP,(cAlias)->WI_DESPBAS,cAlias,cViaTPC,cTabTPC,.F.,lMsg)
            Else
               If lMsg
                  MsgAlert("A Despesa '"+aDesp[I]+"' não foi encontrada entre as despesas relacionadas da tabela atual!")
               EndIf
               aRet := { lRet := .F. , lImpeditivo := .T.} 
            EndIf
            If aRet[1]
               EXIT     //Se encontrada a referencia circular, sai do loop
            EndIf           
         EndIf
      NEXT I
      RestOrd(aOrdTABs,.T.) 
   EndIf 
EndIf

If cAlias == "SWI"
   SWI->(DbSetOrder(nOrdWI))
   SWI->(DbGoTo(nRecWI))
EndIf

Return aRet

*----------------------------------
Static Function TRBPosDspTPC(cDesp)
*----------------------------------
Local lAchou := .F.

TRB->(DbGotop())
Do While TRB->(!Eof())
   If TRB->WI_DESP == cDesp .and. !TRB->WI_FLAG
      lAchou := .T.
      EXIT
   EndIf
   TRB->(DbSkip())
EndDo

Return lAchou

/*
Função     : DI501NVEF3()
Objetivo   : Monta a consulta especifica - Classif NVE
             
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Ramon Prado
Data       : Dez/2019
Revisão    :
*/
Function DI501NVEF3() 
Local nCont
Local oDlg, oBrowse
Local aSeek 	:= {}
Local bOk		:= {|| lRet:= .T.,  oDlg:End()}
Local bCancel:= {|| lRet:= .F.,  oDlg:End()}
Local lRet		:= .F.
Local cCpo   	:= AllTrim(Upper(ReadVar()))
Local aColunas	:= If('EIM_ESPECI' $ cCpo, AvGetCpBrw("SJL",,.T. /*desconsidera virtual*/), If('EIM_ATRIB' $ cCpo, AvGetCpBrw("SJK",,.T. /*desconsidera virtual*/),{}))
Local cAliasV  := If('EIM_ESPECI' $ cCpo, "SJL", If('M->EIM_ATRIB' $ cCpo, "SJK",""))
Local nX		:= 1
Private cCadastro	:= ""
Private aCampos:= {}
Private aFilter:= {} 

Begin Sequence           
   For nX := 1 to Len(aColunas)
   	  /* Campos usados na pesquisa */
      AAdd(aSeek, {AvSx3(aColunas[nX]   , AV_TITULO), {{"", AvSx3(aColunas[nX]  , AV_TIPO), AvSx3(aColunas[nX]   , AV_TAMANHO), AvSx3(aColunas[nX]   , AV_DECIMAL), AvSx3(aColunas[nX]    , AV_TITULO)}}})
      /* Campos usados no filtro */
      AAdd(aFilter, {AvSx3(aColunas[nX]    , AV_TITULO)  , AvSx3(aColunas[nX]    , AV_TITULO) , AvSx3(aColunas[nX]    , AV_TIPO) , AvSx3(aColunas[nX]    , AV_TAMANHO) , AvSx3(aColunas[nX]    , AV_DECIMAL), ""})      
   Next nX
     
   Define MsDialog oDlg Title IF(cAliasV == 'SJK',STR0172,STR0173) From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel

   oBrowse:= FWBrowse():New(oDlg)
   
   If cAliasV == 'SJL'
      oBrowse:SetDataTable("SJL")
      oBrowse:SetAlias("SJL")
   Else
      oBrowse:SetDataTable("SJK")
      oBrowse:SetAlias("SJK")
   EndIf    

   oBrowse:bLDblClick:= {|| lRet:= .T.,  oDlg:End()}
   
   
    		
   For nCont:= 1 To Len(aColunas)
      If aColunas[nCont] <> "R_E_C_N_O_"          
         ADD COLUMN oColumn DATA &("{ ||" + aColunas[nCont] + " }") TITLE AvSx3(aColunas[nCont], AV_TITULO) SIZE AvSx3(aColunas[nCont], AV_TAMANHO) OF oBrowse           
      EndIf
   Next
          
   /* Pesquisa */
   oBrowse:SetSeek(, aSeek)
	
   /* Filtro */	
   oBrowse:SetUseFilter()
   oBrowse:SetFieldFilter(aFilter)

   Do Case
      Case cAliasV == "SJK"
		cCadastro := STR0174
		If "MATA010" $ FUNNAME()
			oBrowse:AddFilter('Default',"SJK->JK_NCM == '"+ SB1->B1_POSIPI +"' ",.F.,.T.)
		ElseIf "EICGI400" $ FUNNAME()         
			oBrowse:AddFilter('Default',"SJK->JK_NCM == '"+ M->W5_TEC +"' ",.F.,.T.)
		Else         
			oBrowse:AddFilter('Default',"SJK->JK_NCM == '"+ M->EIJ_TEC +"' ",.F.,.T.)
		EndIf
      Case cAliasV == "SJL"
		cCadastro := STR0175
		If "MATA010" $ FUNNAME()            
			oBrowse:AddFilter('Default',"SJL->JL_NCM == '"+ SB1->B1_POSIPI +"' .And. SJL->JL_ATRIB == '" + Work_EIM->EIM_ATRIB + "' ",.F.,.T.) 
      ElseIf "EICGI400" $ FUNNAME() 
         oBrowse:AddFilter('Default'," SJL->JL_NCM == '"+ M->W5_TEC +"' .And. SJL->JL_ATRIB == '" + Work_GEIM->EIM_ATRIB + "' ",.F.,.T.)                       		              
		Else            
		  	oBrowse:AddFilter('Default'," SJL->JL_NCM == '"+ M->EIJ_TEC +"' .And. SJL->JL_ATRIB == '" + Work_GEIM->EIM_ATRIB + "' ",.F.,.T.)             
		EndIf
   EndCase
      
   oBrowse:Activate()
   
   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	
	
End Sequence

Return lRet

//*---------------------------------------------------------------------------*
//*                         FIM DO PROGRAMA AVCADGE.PRW                       *
//*---------------------------------------------------------------------------*
