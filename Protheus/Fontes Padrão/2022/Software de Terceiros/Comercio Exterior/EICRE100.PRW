#DEFINE   K_ESC             27

#DEFINE   STATUS            STR( IF( TTipo == 2, 1, 2 ), 1, 0 )
#include "EICRE100.ch"
#Include "AVERAGE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICRE100 ³ Autor ³ AVERAGE/MJB/RSD       ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validade das L.I.s                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICRE100()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function EICRE100()

LOCAL nOldArea:=SELECT("SX2")

// incluir variaveis para o relatorio padrao

LOCAL aDados :={"SWQ",;
                STR0001,;  //"Este relatorio ira imprimir o RETORNO DA PLI"
                "",;
                "",;
                "M",;
               140,;
                "",;
                "",;
                STR0002,;  //"Retorno da PLI"
                {STR0003 , 1,STR0004, 2, 2, 1, "",1 },;  //"Zebrado"###"Importa‡Æo"
                "EICRE100",;
                { {|| .T. } , {|| .T. }  }  }

LOCAL aRCampos := {}

// incluir variaveis do programa

LOCAL FileWork, ind, FileIndex, s1OrdName, s2OrdName, lCriouIndice
LOCAL nLinha, nPrazoMed, nMTotal, nParam:=2
LOCAL _PictPGI := ALLTRIM(X3PICTURE("W4_PGI_NUM"))

LOCAL aDbf     :=  { { "WKTIPO_REG", "C",  02, 0 },;
                     { "WKIMPORT"  , "C",  14, 0 },;
                     { "WKPLI_EASY", "C",  10, 0 },;
                     { "WKINSC_SUF", "C",  09, 0 },;
                     { "WKNR_ALI"  , "C",  08, 0 },;
                     { "WKNCM"     , "C",  08, 0 },;
                     { "WKNR_LI"   , "C",  10, 0 },;
                     { "WK_MSG"    , "C", 130, 0 } }

LOCAL TB_Campos:=  { { {||TRANS(WQ_PGI_NUM,_PictPGI )+' - '+WQ_SEQ_PLI}  ,, STR0005 },;  //"PLI(EASY)"
                     { {||Ret100cli(4) }                   ,, STR0006       },;           //"PLI(SUFRAMA)"
                     { {||Ret100CLI(1) }                   ,, STR0007        },;          //"Nro. A.L.I."
                     { {||Ret100CLI(2) }                   ,, STR0008          },;        //"Nro. L.I."
                     { "WQ_NCM"                            ,, STR0009             },;      //"N.C.M."
                     { {||Ret100CLI(3) }                   ,, STR0010          },;        //"Dt. Envio"
                     { "WQ_DATA"                           ,, STR0011            , '@R 9999.99.99' },; //"Retorno"
                     { {||IF(WQ_STATUS='1','ERRO','OK  ')} ,, STR0012             },;     //"Status"
                     { {||SUBSTR(WQ_MSG,1,65) }            ,, STR0013         },;         //"Observacao"
                     { {||SUBSTR(WQ_MSG,66) }              ,, STR0014 } }                 //"Observacao cont..."

LOCAL aOpcoes   := { STR0015 ,;                                    //"1-Atualizacao de Arquivo Retorno PLI"
                     STR0016 ,;                                    //"2-PLI'S Nao Aprovadas               " 
                     STR0017 ,;                                    //"3-PLI'S Aprovadas                   "
                     STR0018  }                                    //"4-Consulta por PLI                  "

PRIVATE R_Dados:={}, R_Campos:={}, R_Funcoes:={{||.T.},{||.T.}}

aRCampos := E_CriaRCampos(TB_Campos,"C")

// aRotina declarada apenas para compatibilizar com GetDadDB
PRIVATE aRotina := { { STR0019       , "AxPesqui"  , 0 , 1} ,;     //"Pesquisar"
                     { STR0020           , "C210Impor" , 0 , 2} ,;  //"Atual"
                     { STR0021           , "C210Impor" , 0 , 3} }   //"Todos"

// definir sempre - inicio

DBSELECTAREA("SX3")
PRIVATE cMarca := GetMark(), lInverte := .F.

Private aHeader[0],nUsado:=0, aCampos:={}, nOpcao:=1, Valor[0], nOpcA:=0

PRIVATE TTipo, TDt_I, TDt_F, TNome_Arq, cIndex, cAlias

FileWork := E_CriaTrab(,aDBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

IndRegua("Work",FileWork+TEOrdBagExt(),"WKTIPO_REG+WKIMPORT+WKPLI_EASY")

WHILE .T.
   lCriouIndice := .F.

   SWQ->( DBSETORDER( 1 ) )

   SW6->( DBSETORDER( 2 ) )

   IF ! Pergunte( 'EICRET', .t. )
      Exit
   ENDIF
   tTipo := MV_PAR01

   DO CASE
      CASE TTipo = 1                  // Atualizacao de Arquivo Retorno PLI.
           IF !Pergunte( 'EIRE01', .t. )
              Loop
           ENDIF
           tNome_Arq := mv_par01

         IF ! FILE( TNome_Arq )
            Help("", 1, "AVG0000523")//"Arquivo Retorno não encontrado"###"Atenção"
            LOOP
         ENDIF

         IF ! LOG100_AtuRet()
            Help("", 1, "AVG0000524")//"Arquivo Retorno não integrado ao EASY"###"Atenção"
            LOOP
         ENDIF

      CASE TTipo = 2 .OR. TTipo = 3   //  PLI'S Nao Aprovadas  ou  PLI'S Aprovadas.
           IF !Pergunte( 'EIC010', .t. )
              Loop
           ENDIF
           TDt_I  := mv_par01
           TDt_F  := mv_par02

         SWQ->( DBSETORDER( 1 ) )
         SWQ->( DBSEEK( xFilial()+STATUS+DTOS( TDt_I ), .T. ) )

         IF SWQ->WQ_STATUS # STATUS .OR. SWQ->WQ_DATA > TDt_F
            Help("", 1, "AVG0000474")//"Não existem registros para este período"###"Informação"
            LOOP
         ENDIF

         lCriouIndice := .T.
         cIndex     := E_CREATE( {}, .F. )
         cAlias     := 'SWQ'

         IndRegua(cAlias,cIndex+TEOrdBagExt(),"WQ_FILIAL+WQ_STATUS",,;
                  "WQ_STATUS==STATUS.AND.WQ_DATA<=TDT_F.AND.WQ_FILIAL==xFilial('SWQ')",;
                  STR0028)     //"Selecionando PLI's...."

         nIndex:=RetIndex(cAlias)            // restaura indices
         DBSELECTAREA(cAlias)

         #IFNDEF TOP
            DBSETINDEX(cIndex+TEOrdBagExt())
         #ENDIF

         DBSETORDER(nIndex+1)

      CASE TTipo = 4                  // Consulta por PLI.
           IF !Pergunte( 'EIRE02', .t. )
              Loop
           ENDIF
           cPli_Num    := mv_par01

         SWQ->( DBSETORDER( 1 ) )

         IF ! EMPTY( cPli_Num )
            lCriouIndice := .T.

            IF ! SWQ->( DBSEEK( xFilial()+cPli_Num ) )
               Help("", 1, "AVG0000525")//"P.L.I. não cadastrada "###"Informação" 
               LOOP                                                 
            ENDIF

            cIndex:= E_CREATE( {}, .F. )
            cAlias:= 'SWQ'

            IndRegua(cAlias,cIndex+TEOrdBagExt(),;
                     "WQ_FILIAL+WQ_PGI_NUM",,;
                     "WQ_PGI_NUM=cPli_Num.AND.WQ_FILIAL==xFilial('SWQ')",;
                     STR0031)  //"Selecionando PLI's...."

            nIndex:=RetIndex(cAlias)            // restaura indices
            DBSELECTAREA(cAlias)

            #IFNDEF TOP
               DBSETINDEX(cIndex+TEOrdBagExt())
            #ENDIF

            DBSETORDER(nIndex+1)
         ENDIF
   ENDCASE

   oMainWnd:ReadClientCoors()

   DEFINE MSDIALOG oDlg TITLE STR0037 ;  //'RETORNO DE PLI'
         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

   DEFINE SBUTTON FROM 16,285 TYPE 6 ACTION (E_Report(aDados,aRCampos)) ENABLE OF oDlg

   oMark:= MsSelect():New("SWQ",,,Tb_Campos,@lInverte,@cMarca,{30,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

   oMark:bAval:={||Allwaystrue()}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                             {||oDlg:End()},{||oDlg:End()})

   IF lCriouIndice
      // ---> Fechar e apaga somente o indice condicional (Ativo).
      Set Filter To                    //topconnect
      nIndex:=RetIndex(cAlias )        // restaura indices do arquivo
      SWQ->( DbSetOrder( 1 ) )
      FErase(cIndex+TEOrdBagExt())
   ENDIF
ENDDO

Work->(E_EraseArq(FileWork))
SW6->( DBSETORDER( 1 ) )

RETURN NIL

*-----------------------*
FUNCTION ret100CLI(pTipo)
*-----------------------*
LOCAL rRet
SWP->( DBSETORDER( 1 ) )
SWP->( DBSEEK( XFILIAL()+SWQ->WQ_PGI_NUM+SWQ->WQ_SEQ_PLI ) )
IF pTipo = 1
   rRet := SWP->WP_NR_ALI
ELSEIF pTipo = 2
   rRet := TRANS(SWP->WP_REGIST,'@R !!/!!!!!!!-!')
ELSEIF pTipo = 3
   rRet := SWP->WP_TRANSM
ELSEIF pTipo = 4
   rRet := SWP->WP_SUFRAMA
ENDIF
RETURN rRet


*----------------------*
FUNCTION LOG100_AtuRet()
*----------------------*
LOCAL cCgcOk:=.F.

IF MsgYesNO(STR0032,STR0033) # .T.  //'Confirma Atualização do Arquivo Retorno ?'###"Confirmação"
  Return .F.
ENDIF

DBSELECTAREA("Work")
ZAP

APPEND FROM (TNome_Arq) SDF

IF EasyRecCount() = 0
   Help("", 1, "AVG0000526")//"Arquivo de retorno sem registros para atualização"###"Informação"
   RETURN .F.
ENDIF

Work->( DBGOTOP() )
SYT->(DBSEEK( xFilial() ))
WHILE !SYT->(EOF()) .AND. xFilial("SYT") == SYT->YT_FILIAL
  IF Work->WKIMPORT == SYT->YT_CGC
     cCgcOk:=.T.
     EXIT
  ENDIF
  SYT->( DBSKIP() )
ENDDO

SWP->( DBSETORDER( 1 ) )

Processa( { |lEnd| GravaMesmo() },STR0038 ) //'Gravando Arquivo'

SWP->( DBSETORDER( 1 ) )

Return .t.


*-------------------*
Function GravaMesmo()
*-------------------*
LOCAL cPgi_Num, cSeq_li, cMesage, cTipoReg

ProcRegua( Work->( Lastrec() ) )

WHILE ! Work->( EOF() )
  IncProc( STR0039+Alltrim( Work->WKNCM ) )  //'Processando NCM: '
  cPgi_Num := SPACE( 10 )
  cSeq_Li  := SPACE( 03 )
  cMesage  := Work->WK_MSG
  cTipoReg := IF( Work->WKTIPO_REG # "01", "1", "2" )

  IF !SWP->( DBSEEK( xFilial()+Work->WKPLI_EASY ) )
     cMesage :=STR0036 //"PLI-NAO EXISTE NO EASY"
     cTipoReg := "1"
  ELSE
     RecLock( 'SWP', .F. )
     SWP->WP_NR_ALI  :=  Work->WKNR_ALI
     SWP->WP_REGIST  :=  Work->WKNR_LI
     SWP->( MSUNLOCK() )
     cMesage  := Work->WK_MSG
     cPgi_Num := SWP->WP_PGI_NUM
     cSeq_Li  := SWP->WP_SEQ_LI
  ENDIF

  RecLock( "SWQ" , .T. )
  SWQ->WQ_FILIAL  := xFilial("SWQ")
  SWQ->WQ_STATUS  := cTipoReg
  SWQ->WQ_NR_SUFR := Work->WKPLI_EASY
  SWQ->WQ_PGI_NUM := cPgi_Num
  SWQ->WQ_SEQ_PLI := cSeq_Li
  SWQ->WQ_DATA    := dDataBase//DATE()
  SWQ->WQ_TIPOREG := Work->WKTIPO_REG
  SWQ->WQ_NCM     := Work->WKNCM
  SWQ->WQ_MSG     := cMesage
  SWQ->( MSUNLOCK() )

  Work->( DBSKIP() )
ENDDO

SWP->( DBSETORDER( 1 ) )

RETURN .T.

