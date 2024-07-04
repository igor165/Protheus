/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSU100 ³ Autor ³ AVERAGE/MJB/RSD/CRO   ³ Data ³ 18.08.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Integracao com a SUFRAMA                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICSU100()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira - Reestruturacao do Programa         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "Average.ch"
#INCLUDE "Eicsu100.ch"
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

Static nTotSWP, nParSWP

FUNCTION EICSU100()

LOCAL nOldArea:=SELECT()
LOCAL bMarca  := {|lTodos| SUF100Marca(lTodos),;
                           oMark:oBrowse:Refresh() }
LOCAL bPrint  := {|| Processa({||ORI100RET('SWP')},STR0001) } //"Imprimindo ..."
LOCAL cWorkFile
LOCAL cCampoAux

Local nOpcao := 0, _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM"))

LOCAL TB_Campos := { { "WP_FLAGWIN"                                     ,,  "  "      }                       ,;
                     { {||TRANS(TRB->WP_PGI_NUM,_PictPGI)+' - '+TRB->WP_SEQ_LI }  ,, "LI (EASY)"              }         ,;
                     { "WP_SUFRAMA"                                     ,, "PLI(SUFRAMA)"           }         ,;
                     { {||SUF100DATA(TRB->WP_PGI_NUM ) }                     ,, STR0002       }         ,; //"LIberado p/Envio"
                     { "WP_ENV_ORI"                                     ,, STR0003    } ,; //"Envio ao SISCOMEX / SUFRAMA"
                     { "WP_ARQ"                                         ,, STR0004        }         ,; //"Nome do Arquivo"
                     { "WP_NCM"                                         ,, STR0005                   ,'@R 9999.99.99'  } ,; //"N.C.M."
                     { {||SUF100Fabricante() }                          ,, STR0006             }         ,; //"Fabricante"
                     { "WP_NALADI"                                      ,, STR0007                 }         ,; //"NALADI"
                     { "WP_ALADI"                                       ,, STR0008                  }  } //"ALADI"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cVarWhile, cData:=dDataBase//Date()
PRIVATE cArq_Dest, cArq_Sisc:=Space(40), nTipo , cNomeArq := SPACE(12)
PRIVATE TLi, TSeq,  TDt_I, TDt_F
PRIVATE lVazia
PRIVATE lHunter  := EasyEntryPoint("IC010DI1")
PRIVATE mMemoresumo:=" "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis para MSSELECT                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cMarca := GetMark(), lInverte := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis para criacao do TRB                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader := {}, aCampos := Array( SWP->(FCount()) )
// VARIAVEIS PARA O RELATORIO - VEM DO ORI100
PRIVATE aMaquinas:={}, nTotalMarca:=0, nColExtra:=0,TOTLIN:=2000

// PLB 06/08/07 - Variaveis referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
Private lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Private lW4_Fre_Inc := SW4->( FieldPos("W4_FREINC" ) ) > 0
Private lSegInc := SW4->(FIELDPOS("W4_SEGINC")) # 0 .AND. SW4->(FIELDPOS("W4_SEGURO")) # 0 // EOB - 14/07/08 - Inclusão do tratamento de incoterm com seguro
Private lPLI50 := .F.

IF cData >= CToD("15/07/13") 
   lPLI50 := .T.
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo TRB                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cWorkFile := E_CriaTrab("SWP",{{"RECNO","N",6,0}})
cWorkFile := E_CriaTrab("SWP",{{"RECNO","N",6,0},{"WP_FLAGWIN","C",2,0} }) //RA
IF ! USED()
   HELP("",1,"AVG0000535") //"Não foi possível abrir o arquivo de trabalho"
   DBSELECTAREA(nOldArea)
   RETURN .F.
ENDIF
IndRegua("TRB", cWorkFile+TEOrdBagExt(), "WP_PGI_NUM+WP_SEQ_LI")

SW5->(DBSETORDER(7))
SJ5->(DBSETORDER(1))
SYX->(DBSETORDER(3))

dbSelectArea("SWP")
SWP->(dbSetOrder(1))

Begin Sequence
   DO WHILE .T.
      lVazia := .T.
      cTitulo:= STR0011 //"Extração de Dados para o Siscomex / Suframa"

      IF ! Pergunte('EICSUF',.T.)
         Break
      ENDIF

      IF !SUF100Val("*")
         Loop
      ENDIF

      IF !  Empty(left(cVarWhile,10))
         lVazia := .F.
      ENDIF

      IF lVazia
         SWP->(dbSetOrder(4))
      Endif

      IF lVazia
         IF nTipo == 1
            SWP->(DBSEEK(xFilial()))
         ELSE
            SWP->(DBSEEK(xFilial()+Dtos(TDt_I),.T.))
         ENDIF
         Processa( {|| Suf100Wrk1(), FinalProgresso(nParSWP,nTotSWP) },;
                   STR0012 ) //"Selecionando registros da PLI ..."
      ELSE
         Processa( {|| Suf100Wrk2(), FinalProgresso(nParSWP,nTotSWP) },;
                   STR0012 ) //"Selecionando registros da PLI ..."
      ENDIF

      IF TRB->(Easyreccount("TRB")) == 0
         HELP("",1,"AVG0000538")//"Não existem registros para esta seleção !"
         Loop
      ENDIF

      Exit
   ENDDO

   SWP->(dbSetOrder(1))

   WHILE .T.
      nOpcao := 0

      DbSelectArea('TRB')
      TRB->(dbGoTop())
      
      oMainWnd:ReadClientCoords()
      
      //FDR - 05/05/2011                            
      TB_Campos:= AddCpoUser(TB_Campos,"SWP","2")

      DEFINE MSDIALOG oDlg TITLE cTitulo ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
         OF oMainWnd PIXEL  
         
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT   

      @02,155 BUTTON STR0014 SIZE 34,11  FONT oDlg:oFont OF oPanel PIXEL ; //"Marca/Des"
              ACTION ( EVAL(bMarca, .f. ) )

      @02,195 BUTTON STR0015     SIZE 34,11  FONT oDlg:oFont OF oPanel PIXEL ; //"Todos"
              ACTION (EVAL(bMarca,.T.))

      @02,235 BUTTON STR0016     SIZE 34,11  FONT oDlg:oFont OF oPanel PIXEL; //"Envio"
              ACTION (nOpcao:=2,oDlg:End())

      @02,275 BUTTON STR0017 SIZE 34,11  FONT oDlg:oFont OF oPanel PIXEL; //"Relatório"
              ACTION (nOpcao:=3,oDlg:End())

      oMark:= MsSelect():New("TRB",'WP_FLAGWIN',,Tb_Campos,@lInverte,@cMarca,{50,1,FINAL_SELECT,COLUNA_FINAL})

      oMark:bAval := {|| EVAL(bMarca,.f.) }
       oDlg:lMaximized := .T.

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                                   {||oDlg:End()},{||oDlg:End()})

      IF nOpcao == 2
         SUf100Env()
         Exit
      ELSEIF nOpcao == 3
         EVAL(bPrint)
         LOOP
      ENDIF

      Exit
   ENDDO
End Sequence

TRB->(E_EraseArq(cWorkFile))

SW5->(DBSETORDER(1))
SJ5->(DBSETORDER(1))
SYX->(DBSETORDER(1))

DBSELECTAREA(nOldArea)

RETURN NIL

*------------------------*
FUNCTION SUF100Val(cCampo)
*------------------------*

TLi   := mv_par01
TSeq  := mv_par02
nTipo := mv_par03
TDt_I := mv_par04
TDt_F := mv_par05

lVazia := .T.



IF cCampo == "LI" .Or. cCampo=="SEQ" .Or. cCampo == "*"
   IF ! EMPTY(TLi) .AND. ! EMPTY(TSeq)
      lVazia := .F.
      IF ! SWP->(DBSEEK(xFilial("SWP")+TLi+TSeq))
         HELP("",1,"AVG0000541")
         RETURN .F.
      ELSE
         IF ! EMPTY(SWP->WP_RET_ORI) .AND. SWP->WP_ERRO = "1"
            HELP("",1,"AVG0000544")  //NÚMERO DA LI NO EASY JÁ ENVIADO E APROVADO 

         ELSEIF ! EMPTY(SWP->WP_RET_ORI) .AND. SWP->WP_ERRO = "2"
            HELP("",1,"AVG0000548") //"NÚMERO DA LI NO EASY JÁ ENVIADO E NÃO APROVADO"
         ENDIF
      ENDIF
   ELSEIF ! EMPTY(TLi) .AND. EMPTY(TSeq)
      IF ! SWP->(DBSEEK(xFilial()+TLi))
         HELP("",1,"AVG0000549") //"NÚMERO DA LI NO EASY NÃO CADASTRADO "

         RETURN .F.
      ENDIF
   ENDIF

   cVarWhile := TLi+TSeq
ENDIF

IF cCampo == "DT_F" .Or. cCampo == "DT_I" .Or. cCampo == "*"
   IF nTipo == 2 // Enviados
      IF TDt_F < TDt_I .And. cCampo == "*"
         HELP("",1,"AVG0000550") //"Data final é menor que a data inicial"
         RETURN .F.
      ENDIF
   ENDIF
ENDIF

RETURN .T.

*------------------------------------------------------*
FUNCTION SUF100Wrk1() // by CAF 03/02/1999
*------------------------------------------------------*
Local nRecno := SWP->(Recno())

If nTotSWP == nil
   nTotSWP := 0
   SWP->(dbEval({||nTotSWP++},,{|| WP_FILIAL == xFilial("SWP")}))
   SWP->(dbGoTo(nRecno))
Endif

ProcRegua(nTotSWP)
nParSWP := 0

While !SWP->(Eof()) .And. SWP->WP_FILIAL == xFilial("SWP")

   IncProc()
   nParSWP ++

   If Empty(SWP->WP_PGI_NUM)
      SWP->(dbSkip())
      Loop
   Endif

   If ! SUF100VerGI(SWP->WP_PGI_NUM)
      SWP->(dbSkip())
      Loop
   Endif

   IF nTipo == 1 // Processos Nao Enviados
      If ! Empty(SWP->WP_ENV_ORI)
         Exit
      Endif

   ElseIf nTipo == 2 // Processos ja Enviados
      If ! Empty(TDt_F)
         If SWP->WP_ENV_ORI > TDt_F
            Exit
         Endif
      Endif

      If ! Empty(SWP->WP_NR_MAQ)
         SWP->(dbSkip())
         Loop
      Endif
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava informacoes no arquivo de trabalho                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   TRB->(dbAppend())
   AVReplace("SWP","TRB")
   TRB->RECNO := SWP->(Recno())

   SWP->(dbSkip())
End

RETURN (Nil)

*------------------------------------------------------*
FUNCTION SUF100Wrk2() // by CAF 03/02/1999
*------------------------------------------------------*
Local nRecno := SWP->(Recno())

If nTotSWP == nil
   nTotSWP := 0
   SWP->(dbEval({||nTotSWP++},,{|| WP_FILIAL == xFilial("SWP") }))
   SWP->(dbGoTo(nRecno))
Endif

ProcRegua(nTotSWP)
nParSWP := 0

While !SWP->(Eof()) .And. SWP->WP_FILIAL == xFilial("SWP")

   IncProc()
   nParSWP ++

   If Empty(Right(cVarWhile,3))
      // Enquanto for a mesma LI
      If SWP->WP_PGI_NUM != LEFT(cVarWhile,10)
         Exit
      Endif
   Else
      // Enquanto for a mesma LI+SEQ
      If SWP->WP_PGI_NUM+SWP->WP_SEQ_LI != cVarWhile
         Exit
      Endif
   Endif

   If Empty(SWP->WP_PGI_NUM)
      SWP->(dbSkip())
      Loop
   Endif

   If ! SUF100VerGI(SWP->WP_PGI_NUM)
      SWP->(dbSkip())
      Loop
   Endif

   IF nTipo == 1 // Processos Nao Enviados
      If ! Empty(SWP->WP_ENV_ORI)
         SWP->(dbSkip())
         Loop
      Endif

   ElseIf nTipo == 2 // Processos ja Enviados
      If ! EMPTY(TDt_F) .AND. SWP->WP_ENV_ORI > TDt_F
         SWP->(dbSkip())
         Loop
      Endif

      If ! Empty(SWP->WP_NR_MAQ)
         SWP->(dbSkip())
         Loop
      Endif
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava informacoes no arquivo de trabalho                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   TRB->(dbAppend())
   AVReplace("SWP","TRB")
   TRB->RECNO := SWP->(Recno())

   SWP->(dbSkip())
End

RETURN (Nil)

*---------------------------------------------------------*
FUNCTION FinalProgresso(nParcial,nTotal) // by CAF 04/02/99
*---------------------------------------------------------*
/* Funcao destina a completar 100% na barra de progresso */
LOCAL nIncr := 0

For nIncr:=nParcial To nTotal
   IncProc()
Next i

Return (nil)

*------------------------------------------------------*
FUNCTION SUF100Env()                     // LAB 13.06.97
*------------------------------------------------------*
LOCAL OldAlias := SELECT()
LOCAL aCapaLi:={},aItemLi:={},aNcmLi:={}
LOCAL cMaquina,cDespachante,Primeiro:=.T.
LOCAL cFile
LOCAL lMarcado := .F. 
LOCAL cData := DATE(),cHoras := TIME() //LRS
Local oUpdSU100 //THTS - 31/07/2017
Local nHandle  := 0, nTamTab := 0, cTexto := "", aTamTab := {{"01", 0343},;
                                                             {"08", 0401},;
                                                             {"09", 0135},; 
                                                             {"03", 4193},;
                                                             {"04", 0070},; 
                                                             {"05", 0043},; 
                                                             {"07", 4088},;
                                                             {"10", 0075}} // GFP - 30/07/2013

TRB->( dbEval({||IF(WP_FLAGWIN==cMarca,lMarcado:=.T.,)}) )

IF ! lMarcado
   HELP("",1,"AVG0000551")//"Não existem registros marcados para o envio !"
   RETURN
ENDIF

PRIVATE tBate1vez:=.T.,nPesTotPLI:=0,MDesFrePLI:=0,;
        PGI_Chave:= SWP->WP_PGI_NUM
//, cCampoAux := CAMPO

//THTS - 31/07/2017
If FindFunction("AvUpdate01")
   oUpdSU100 := AvUpdate01():New()
   oUpdSU100:aChamados := {{nModulo,{|o| UPDX1SU100(o)}}}
   oUpdSU100:Init(,.T.)
EndIf

WHILE .T.
   IF ! Pergunte( 'EISU01', .t. )
        RETURN NIL
   ENDIF
   
   cDir := If(Left(AllTrim(mv_par01),1) == "\",AllTrim(GetSrvProfString("ROOTPATH","") + AllTrim(mv_par01)),AllTrim(mv_par01))  // GFP - 21/05/2014
   
   //AOM - 10/08/2011
   If !File(If(Right(AllTrim(cDir),1)=="\",Left(cDir,Len(cDir)-1),cDir))
      MsgInfo('O diretório "'+ cDir + '" não foi encontrado. Verifique se o diretório existe ou informar outro diretório.' , "Aviso")
      SUF100Env()
   EndIf 

   EXIT
Enddo

cDir := ALLTRIM(cDir)

AADD( aCapaLi,{"SUFTEXTO","C",4300,0 } )   // GFP - 30/07/2013

cFile := E_CriaTrab(,aCapaLI,"Suframex") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

IF !MsgYesNo(STR0024,STR0016) //'Confirma o envio dos registros ?'###"Envio"
   Suframex->(E_ERASEARQ(cFile))

   DBSELECTAREA('SWP')
   		RETUR .T.
   ENDIF

DBSELECTAREA('SWP')
//LRS - 11/09/2014 - Validação para Nova nomenclatura para o arquivo SUFRAMA 
SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST))
SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))
SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
 
cData := DTOC(cData)
cHoras := SUBSTR(cHoras, 1, 2)+SUBSTR(cHoras, 4, 2)+SUBSTR(cHoras, 7, 2)
cData  := SUBSTR(cData, 1, 2)+SUBSTR(cdata, 4, 2)+SUBSTR(cdata, 7, 4)

cNumero   := Seq_Arq_Sis() // JA esta com zeros na frente 

IF !lPLI50
	cNomeArq := "E"+Right(Str(Year(dDataBase),4),2)+cNumero+".PLI" 
Else
	cNomeArq := Alltrim(SYT->YT_INS_SUF)+"_EIC_"+cData+"_"+cHoras+".PL5" 
EndIF

cArq_Sisc := cDir+cNomeArq //LRS - 11/09/2014

Processa( { |lEnd| GravaSuf() },STR0025 ) //'Gerando Arquivo Para Suframa'

DBSELECTAREA("Suframex")
nHandle := EasyCreateFile(cArq_Sisc)  // GFP - 30/07/2013
Suframex->(DBGOTOP())
IF !Suframex->(EOF())
//   COPY TO (cArq_Sisc) SDF  // Nopado por GFP - 30/07/2013 - Geração do arquivo foi alterada porque na versão 5.0 cada linha tem um tamanho diferente.
   // GFP - 30/07/2013
   Do While Suframex->(!EOF())
      nTamTab := aScan(aTamTab, {|x| x[1] == Left(Suframex->SUFTEXTO,2)})
      cTexto := AllTrim(Suframex->SUFTEXTO) + Space(aTamTab[nTamTab][2]-Len(AllTrim(Suframex->SUFTEXTO)))
      FWRITE(nHandle, cTexto + chr(13)+chr(10))
      Suframex->(DbSkip())
   EndDo
   FCLOSE(nHandle)  
   
   If Empty (Alltrim(SYT->YT_INS_SUF))   //LRS - 23/09/2014
      If MsgYesNo(STR0030+'""'+cArq_Sisc+'"',STR0029)//Campo Numero de inscrição SUFRAMA não preenchido, deseja gerar o arquivo com o nome :
         MsgInfo(STR0026+cArq_Sisc+'"',STR0010) //'Atenção o nome do arquivo gerado é "'###"Informação" 
	  EndIF
   Else
      MsgInfo(STR0026+cArq_Sisc+'"',STR0010) //'Atenção o nome do arquivo gerado é "'###"Informação" 
   EndIF
ENDIF    

Suframex->(E_EraseArq(cFile))

IF EasyEntryPoint("ICPADSUF") 
  EXECBLOCK("ICPADSUF",.F.,.F.,"DISPLAYLOG")
ENDIF

DBSELECTAREA('SWP')
RETURN .T.

*-------------------------------------------------*
Static Function GravaSuf()
*-------------------------------------------------*
LOCAL nCont := 0, nOrderSX3:=(IndexOrd())        
SX3->(DbSetOrder(2))
Private lExisteWP_AC := SX3->(DbSeek("WP_AC"))
SX3->(DBSETORDER(nOrderSX3))

ProcRegua(TRB->(Easyreccount("TRB")))
TRB->(dbGoTop())

While ! TRB->(Eof())
   IncProc(STR0027+Alltrim(Str(++nCont,5))) //'Processando Registro Nr '

   IF ! Empty(TRB->WP_FLAGWIN)
      SWP->(dbGoTo(TRB->RECNO))

      IF ! SUF100Grv()
        TRB->(DBSKIP())
        LOOP
      ENDIF  
      SWP->(RecLock('SWP',.F.))
      SWP->WP_ENV_ORI := dDataBase//DATE()
      SWP->WP_ARQ     := cNomeArq  //cArq_Sisc
      SWP->WP_FLAGWIN := Space( 02 )
      SWP->(MsUnlock())
   ENDIF

   TRB->( DbSkip() )
ENDDO


RETURN

*---------------------------------------------------------------------*
FUNCTION SUF100Grv()
*---------------------------------------------------------------------*
LOCAL MSeq,MAusenciafa,Testa,aGrv_Gip:={},Alias_Proc,;
      OldArea,AreaPrincipal,aFabr:={},Inclui_Forn,Vlr_Usd,I,cAl_II_Ncm

LOCAL nPesTotLI:=0,nPesTotItem:=0,MDesFreLI:=0
LOCAL nPesTotPODI:=0,MDesFrePODI:=0 , nRecSW5 

LOCAL nWP_FOB_TOT := 0, nQtde, nPreco, cCod_I
LOCAL nRatDesp := nRatFre := 0

LOCAL lIndus := .F. //JVR - 10/03/10 - tratamento para produtos de industrialização.
LOCAL MFabr_Loj:= ""
PRIVATE cDescr := SPACE(254)  //igor chiba passagem para private 08/03/2010
PRIVATE cTexto,cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
PRIVATE cUnid_Item:="",nTx_Conv:=0, Qtde_Est, Vlr_Moeda, Vlr_MoeCtx

SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST))
SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))
SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))

MSeq := 0   ; MAusenciafa := "1"  ;  Testa := .T.
Peso_L := Qtde_Est := Vlr_Moeda := Vlr_MoeCtx := Vlr_Usd := 0
nPeso_Un :=0 
IF EasyEntryPoint("ICPADSUF") 
  IF !EXECBLOCK("ICPADSUF",.F.,.F.,"GRVLOG")
    RETURN .F.
  ENDIF   
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava variavel no SX6                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
sNumero := EasyGParam("MV_NR_SUFR")+1
IF sNumero > 99999
   sNumero := 1
ENDIF
SETMV("MV_NR_SUFR",sNumero)

cCod_Suf := strzero(YEAR(dDataBase),4)+'/'+strzero(sNumero,5)

If !lPLI50   // GFP - 26/07/2013
   cTexto := SPACE( 604 )
Else
   cTexto := SPACE( 343 )
EndIf
cTexto := STUFF( cTexto, 001, 002, "01")    && REGISTRO NUMERO 01
cTexto := STUFF( cTexto, 003, 010, cCod_Suf)
cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )          
cTexto := STUFF( cTexto, 022, 001, '1' )
cTexto := STUFF( cTexto, 023, 014, SYT->YT_CGC )
cTexto := STUFF( cTexto, 037, 003, "105" ) // "000"
cTexto := STUFF( cTexto, 040, 060, IF(!EMPTY( SYT->YT_NOME ), SYT->YT_NOME,"."))
cTexto := STUFF( cTexto, 100, 015, IF(!EMPTY( SYT->YT_TEL_IMP ), SYT->YT_TEL_IMP,"."))
cTexto := STUFF( cTexto, 115, 040, IF(!EMPTY( SYT->YT_ENDE ), SubStr( SYT->YT_ENDE, 1, 40 ), "." ) )
cTexto := STUFF( cTexto, 155, 006, STRZERO( SYT->YT_NR_END, 6 ) )
cTexto := STUFF( cTexto, 161, 021, STR0028 ) //"DISTRITO INDUSTRIAL"
cTexto := STUFF( cTexto, 182, 025, STR0028 ) //"DISTRITO INDUSTRIAL"
cTexto := STUFF( cTexto, 207, 025, IF( ! EMPTY( SYT->YT_CIDADE), SYT->YT_CIDADE, "." ) )
cTexto := STUFF( cTexto, 232, 002, IF( ! EMPTY( SYT->YT_ESTADO), Alltrim(SYT->YT_ESTADO), "." ) )
cTexto := STUFF( cTexto, 234, 008, SYT->YT_CEP )
cTexto := STUFF( cTexto, 242, 004, SYT->YT_COD_ATV )
cTexto := STUFF( cTexto, 246, 011, SYT->YT_CPF_REP )
cTexto := STUFF( cTexto, 257, 001, SW4->W4_TIPO_DOC ) &&  TIPO DE DOCUMENTO
cTexto := STUFF( cTexto, 258, 008, SPACE( 08 ) )
cTexto := STUFF( cTexto, 266, 002, left(SW4->W4_TIPOAPL,2) )  &&  TIPO DE APLICACAO
If alltrim(SW4->W4_TIPOAPL) == "01" //JVR - 10/03/10 - tratamento para produtos de tipo industrialização.
   lIndus := .T. 
EndIF
cTexto := STUFF( cTexto, 268, 010, SWP->WP_SUBST )
cTexto := STUFF( cTexto, 278, 008, "00000000" )
cTexto := STUFF( cTexto, 286, 004, "0000" )
cTexto := STUFF( cTextO, 290, 050, SYT->YT_E_MAIL) 
//FDR - 23/04/13
If !lPLI50
   cTexto := STUFF( cTextO, 340, 003, "300")
Else
   cTexto := STUFF( cTextO, 340, 003, "500")          //NCF-19/05/2010-PLI 5.0-Versão (VERSAO)
   cTexto := STUFF( cTexto, 343, 001, SPACE( 01 ))    //GFP - 26/07/2013    //"S")            //NCF-19/05/2010-PLI 5.0-Indicação de LI em Exigência (INDLI)
EndIf

AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

If !lPLI50   // GFP - 26/07/2013
   cTexto  := SPACE( 604 )
Else
   cTexto  := SPACE( 135 )
EndIf
cTexto  := STUFF( cTexto, 001, 002, "09" )   && REGISTRO  NUMERO 09
cTexto  := STUFF( cTexto, 003, 010, cCod_Suf )
cTexto  := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )
cTexto  := STUFF( cTexto, 022, 008, SWP->WP_NCM )
cTexto  := STUFF( cTexto, 030, 011, strzero( VAL( SW4->W4_PROD_SU ), 11 ) )
cTexto  := STUFF( cTexto, 041, 008, strzero( VAL( SWP->WP_NAL_SH ), 8 ) )
*cTexto := STUFF( cTexto, 046, 015, )  SERA GRAVADO MAIS ABAIXO PESO LIQUIDO
*cTexto := STUFF( cTexto, 061, 014, )  QTDE NA MEDIDA ESTATISTICA

PesquisaClassificacao( SW5->W5_CC, SW5->W5_SI_NUM, SW5->W5_COD_I,;
                       SW5->W5_PO_NUM, SW5->W5_REG )

cTexto  := STUFF( cTexto, 078, 001, "0" )
cTexto  := STUFF( cTexto, 079, 003, IF( SYF->( DBSEEK( xFilial()+SW2->W2_MOEDA ) ),SYF->YF_COD_GI,'000') )
cTexto  := STUFF( cTexto, 082, 003, IF( EMPTY( SW4->W4_INCOTERM ),SW2->W2_INCOTERM, SW4->W4_INCOTERM ) )
*cTexto := STUFF( cTexto, 085, 015, )  VLR MERCADORIA NA MOEDA NEGOCIADA

// cTexto  := STUFF( cTexto, 100, 001, SPACE( 01 ) )
// cTexto  := STUFF( cTexto, 102, 001, SPACE( 01 ) )
cTexto := STUFF(cTexto,100,002,IF(SW4->W4_COND_ME="3","TF",;
                               IF(SW4->W4_COND_ME="2","FT", SPACE(2) )))
     // Posicao 097 = MATERIAL USADO, posicao 098 = BEM ENCOMENDA
     // Cond.Mercadoria = 3 ==>> Mat.Usado = "T" (true) e Bem/Encomenda = "F"
     //   "      "      = 2 ==>> Mat.Usado = "F"        e Bem/Encomenda = "T"
     //   "      "      = 1 ==>> NORMAL (posicao 097 e 098 em branco)

cTexto  := STUFF( cTexto, 102, 013, SW4->W4_COMUNICA )
cTexto  := STUFF( cTexto, 115, 007, AVPadl( ALLTRIM(SW4->W4_URF_CHE), 7, "0" ) )
*cTexto := STUFF( cTexto, 119, 003, AVPADL( SYR->YR_PAIS_ORI, 3, "0" ) ) && FALAR COM SERGIO PAIS DE PROCEDENCIA
*cTexto := STUFF( cTexto, 119, 003, AVPadl( SWP->WP_PAIS_PR,3,"0" ) )

cTexto := STUFF( cTexto, 122, 003,;
AVPADL( IF( EMPTY( SWP->WP_PAIS_PR ), SYR->YR_PAIS_ORI, SWP->WP_PAIS_PR ), 3, "0" ) )
cAl_II_Ncm := Posicione("SYD",1,xFilial("SYD")+SWP->WP_NCM,"YD_PER_II") 
//FDR - 24/04/13
If !lPLI50
   cTexto := STUFF( cTexto, 125, 007,AVPadl( ALLTRIM(SW4->W4_URF_DES), 7, "0" ) )
Else
   cTexto := STUFF( cTexto, 125, 007,AVPadl( ALLTRIM(SW4->W4_URF_DES), 7, "0" ) )  // GFP - 30/07/2013 - Ajustado posição
   //cTexto := STUFF( cTexto, 132, 004, If(cAl_II_Ncm > 0, ORI100Numero( cAl_II_Ncm, 02, 02 ), strzero( cAl_II_Ncm, AvSx3("YD_PER_II",AV_TAMANHO))))    && ALIQUOTA SOBRE II //NCF-19/05/2010-PLI 5.0-Aliquota sobre o II - (ALIQ-CRAII) // GFP - 26/07/2013
   cTexto := STUFF( cTexto, 132, 004, If(cAl_II_Ncm > 0, ORI100Numero( cAl_II_Ncm, 02, 02 ), StrZero( cAl_II_Ncm, 4)))    && ALIQUOTA SOBRE II //FSY 14/10/2013 - Ajuste para preencher com 4 zeros respeitando o layout suframa 5.0
End If   
AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

If !lPLI50   // GFP - 26/07/2013
   cTexto := SPACE( 604 )
Else
   cTexto := SPACE( 401 )
EndIf
cTexto := STUFF( cTexto, 001, 002, "08" )   && REGISTRO  NUMERO 08
cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUFR )
cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
cTexto := STUFF( cTexto, 030, 011, strzero( VAL( SW4->W4_PROD_SU ), 11 ) )

SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))

cTexto  := STUFF( cTexto, 041, 060, SA2->A2_NOME )
cTexto  := STUFF( cTexto, 101, 040, SA2->A2_END )
cTexto  := STUFF( cTexto, 141, 006, AVPADL(IF(!EMPTY(SA2->A2_NR_END),ALLTRIM(SA2->A2_NR_END),0),6,"0") )
cTexto  := STUFF( cTexto, 147, 021, "." + SPACE( 20 ) )
cTexto  := STUFF( cTexto, 168, 025, SA2->A2_ESTADO )
cTexto  := STUFF( cTexto, 193, 025, SA2->A2_MUN )
cTexto  := STUFF( cTexto, 218, 003, AVPadl( SA2->A2_PAIS, 3, "0" ) )
cTexto  := STUFF( cTexto, 221, 001, If(SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ") == SWP->WP_FABR+EICRetLoja("SWP","WP_FABLOJ"),"1","2"))  // GFP - 09/08/2013

// GFP - 07/08/2013 - Tratamento de Fabricante
If SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ") <> SWP->WP_FABR+EICRetLoja("SWP","WP_FABLOJ")  // GFP - 29/08/2013
   SA2->(DBSEEK(xFilial("SA2")+SWP->WP_FABR+EICRetLoja("SWP","WP_FABLOJ")))

   cTexto  := STUFF( cTexto, 222, 060, SA2->A2_NOME )
   cTexto  := STUFF( cTexto, 282, 040, SA2->A2_END )
   cTexto  := STUFF( cTexto, 322, 006, AVPADL(IF(!EMPTY(SA2->A2_NR_END),ALLTRIM(SA2->A2_NR_END),0),6,"0") )
   cTexto  := STUFF( cTexto, 328, 021, "." + SPACE( 20 ) )
   cTexto  := STUFF( cTexto, 349, 025, SA2->A2_ESTADO + SPACE(25-Len(SA2->A2_ESTADO)) )  // GFP - 09/08/2013
   cTexto  := STUFF( cTexto, 374, 025, SA2->A2_MUN + SPACE(25-Len(SA2->A2_MUN)) )  // GFP - 09/08/2013
   cTexto  := STUFF( cTexto, 399, 003, AVPadl( SA2->A2_PAIS, 3, "0" ) )
EndIf
AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

SY8->(DBSEEK(xFilial()+SW4->W4_REGIMP))

IF EMPTY(SW4->W4_COND_PAG)
   SY6->(DBSEEK(xFilial()+SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PAG,3)))
ELSE
   SY6->(DBSEEK(xFilial()+SW4->W4_COND_PAG+STR(SW4->W4_DIAS_PAG,3)))
ENDIF

If !lPLI50   // GFP - 26/07/2013
   cTexto := SPACE( 604 )
Else
   cTexto := SPACE( 75 )
EndIf
cTexto := STUFF( cTexto, 001, 002, "10" )   && REGISTRO  NUMERO 10
cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUFR )
cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
cTexto := STUFF( cTexto, 030, 011, strzero( VAL( SW4->W4_PROD_SU ), 11 ) )
cTexto := STUFF( cTexto, 041, 001, IF( !EMPTY( SW4->W4_ACO_TAR ), SW4->W4_ACO_TAR, '0' ) )
cTexto := STUFF( cTexto, 042, 003, IF( EMPTY( SWP->WP_ALADI ), SPACE( 03 ), AVPadl( SWP->WP_ALADI, 3, "0" ) ) )
cTexto := STUFF( cTexto, 045, 001, IF( !EMPTY( SY8->Y8_REG_TRIB), SY8->Y8_REG_TRIB, '0' ) )
cTexto := STUFF( cTexto, 046, 002, IF( SW4->W4_REGIMP == 'A9', "00", IF( !EMPTY( SW4->W4_REGIMP ), SW4->W4_REGIMP, "00" ) ) )
cTexto := STUFF( cTexto, 048, 001, IF( !EMPTY( SY6->Y6_TIPOCOB ), SY6->Y6_TIPOCOB, "0" ) )
cTexto := STUFF( cTexto, 049, 002, IF( SY6->Y6_TIPOCOB == "1".OR. SY6->Y6_TIPOCOB == "2",AVPadl( SY6->Y6_TABELA, 2, "0" ), "00" ) )
cTexto := STUFF( cTexto, 051, 003, STRZERO( SY6->Y6_DIAS, 3))
cTexto := STUFF( cTexto, 054, 002, IF( SY6->Y6_TIPOCOB == "3", AVPadl( SY6->Y6_INST_FI, 2, "0" ), "00") )
cTexto := STUFF( cTexto, 056, 002, IF( SY6->Y6_TIPOCOB == "4", AVPadl( SY6->Y6_MOTIVO, 2, "0" ), "00") )
cTexto := STUFF( cTexto, 058, 005, SW4->W4_AGSECEX )
cTexto := STUFF( cTexto, 063, 013, If(lExisteWP_AC, SUBSTR( SWP->WP_AC, 1, 13 ), SUBSTR( SW4->W4_ATO_CONC, 1, 13 ) ) )
AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

MDespesas := 0

IF EasyGParam("MV_RATEIO") $ cSim
   MDespesas  := SW4->W4_INLAND + SW4->W4_PACKING - SW4->W4_DESCONTO
   IF SW4->(FIELDPOS("W4_OUT_DES")) # 0 
      MDespesas+=SW4->W4_OUT_DES
   ENDIF                           
   // EOB - 14/07/08 - Tratamento de incoterms com seguro
   IF lSegInc .AND. SW4->W4_SEGINC $ cNao .AND. AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_SEG")/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"  // GFP - 19/09/2013
      MDespesas+=SW4->W4_SEGURO
   ENDIF     
ENDIF

IF lW4_Fre_Inc  .Or.  EasyGParam("MV_RAT_FRE") $ cSim
   IF PGI_Chave # SWP->WP_PGI_NUM .OR. tBate1vez
      nPesTotPLI:=0

      WHILE ! SW5->(EOF()) .And. SW5->W5_FILIAL == xFilial("SW5") .And.;
            SW5->W5_PGI_NUM == SWP->WP_PGI_NUM

         IF SW5->W5_SEQ # 0
            SW5->( DBSKIP() )
            LOOP
         ENDIF

         SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))
         //nPeso_Un := If(!Empty(SW5->W5_PESO),SW5->W5_PESO,SB1->B1_PESO) //FCD 05/07/2001
         nPeso_Un := If(!Empty(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))) // RA - 11/11/2003 - O.S. 1192/03
         nPesTotPLI += SW5->W5_QTDE *  nPeso_un //  SB1->B1_PESO    // << PESO

         IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESO"),)

         SW5->( DBSKIP() )
      ENDDO

      PGI_Chave := SWP->WP_PGI_NUM
      tBate1vez := .F.
   ENDIF

   MDesFrePLI := SW4->W4_FRETEINT            //<< PESO

   SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
ENDIF

cFob_Cli := 0

WHILE ! SW5->(EOF()) .AND. SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == ;
                           SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .And. ;
                           SW5->W5_FILIAL == xFilial("SW5")

   IF SW5->W5_SEQ # 0
      SW5->( DBSKIP() )
      LOOP
   ENDIF

   SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))
   //nPeso_Un := If(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,SB1->B1_PESO) //FCD 05/07/2001
   nPeso_Un := If(!Empty(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))) // RA - 11/11/2003 - O.S. 1192/03

   nPesTotLI+= SW5->W5_QTDE * nPeso_Un  //SB1->B1_PESO            //<< PESO
   cFob_Cli += SW5->W5_QTDE * SW5->W5_PRECO

   IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESO"),)

   SW5->(DBSKIP())
ENDDO

// SWP->(RecLock('SWP',.F.))
// SWP->WP_FOB_TOT := cFob_Cli
// SWP->( MsUnlock() )
nWP_FOB_TOT := cFob_Cli

MDesFreLI := ( MDesFrePLI * ( NPesTotLI/IF(NPesTotPLI<=0,1,NPesTotPLI) ))//<< PESO
MDespesas := ( MDespesas * ( cFob_Cli / SW4->W4_FOB_TOT ) )
//cFob_Cli  += MDespesas + MDesFreLI

//** PLB 06/08/07
cFob_Cli  += MDespesas
If !lW4_Fre_Inc  .Or.  ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE") )/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
   cFob_Cli += MDesFreLI
EndIf
//**

SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))

MFabr_Primeiro := SW5->W5_FABR
mSeqAtivoFixo  := 1
cValor_Uni     := 0

If EICLoja()
   MFabr_Loj   := SW5->W5_FABLOJ 
EndIf

WHILE ! SW5->(EOF()) .AND. SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == ;
                           SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .And. ;
                           SW5->W5_FILIAL == xFilial("SW5")

   IF SW5->W5_SEQ # 0
      SW5->( DBSKIP() )
      LOOP
   ENDIF

   nQtde  := 0
   cCod_I := SW5->W5_COD_I
   nPreco := SW5->W5_PRECO

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Sumaliza qtde para o mesmo item e mesmo preco                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nRecSW5:= SW5->(RECNO())
   While ! SW5->(EOF()) .AND. SW5->W5_FILIAL == xFilial("SW5") .AND.;
      SW5->W5_PGI_NUM+SW5->W5_SEQ_LI == SWP->WP_PGI_NUM+SWP->WP_SEQ_LI .AND.;
      SW5->W5_COD_I == cCod_i .AND. SW5->W5_PRECO == nPreco .AND. SW5->W5_SEQ == 0

      nQtde += SW5->W5_QTDE
      nRecSW5:= SW5->(RECNO())

      SW5->(dbSkip())
   End
   //SW5->(dbSkip(-1)) // Volta para um registro com PGI+SEQ_LI a do SWP
   SW5->(DBGOTO(nRecSW5))
   SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
   SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))

   nOrd := SA5->(INDEXORD())
   SA5->(DBSETORDER(3))
   //SA5->(DBSEEK(xFilial()+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
   EICSFabFor(xFilial("SA5")+ SW5->W5_COD_I + SW5->W5_FABR+ SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
   cUnid_Item:=BUSCA_UM(SW5->W5_COD_I+SW5->W5_FABR +SW5->W5_FORN,SW5->W5_CC+SW5->W5_SI_NUM,,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
   SAH->(DBSEEK(xFILIAL("SAH")+cUnid_Item)) 
   SA5->(DBSETORDER(nOrd))

   nTx_Conv:= 1
   IF AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
      // SVG - 12/02/09
      IF !EMPTY(SW5->W5_PESO)
         nTx_Conv :=SW5->W5_PESO
      ELSE
         IF !FINDFUNCTION("B1PESO")
            nTx_Conv:=SB1->B1_PESO
         ELSE
            nTx_Conv:=B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
         ENDIF
      ENDIF
   ELSE
      IF Left(Alltrim(SAH->AH_COD_SIS),2) # Left(Alltrim(SWP->WP_UNID),2) // MPG - 06/02/2018
         IF LEN(SJ5->J5_DE) > LEN(cUnid_Item)
            cUnid_Item:=cUnid_Item+SPACE(LEN(SJ5->J5_DE)-LEN(cUnid_Item))
         ENDIF
         IF SJ5->(DBSEEK(xFilial()+cUnid_Item +SWP->WP_UNID)) 
            nTx_Conv := SJ5->J5_COEF
         ENDIF                          
      ENDIF
   ENDIF

//* SOL

  IF SW5->W5_FABR # SW5->W5_FORN .And. IIF(EICLoja(),SW5->W5_FABLOJ # SW5->W5_FORLOJ,.T.)
     IF MAusenciafa="1"
        MAusenciafa:="2"
     ENDIF
     IF (!EMPTY(SW5->W5_FABR_01).AND. !EICEmptyLJ("SW5","W5_FAB1LOJ") .AND. SW5->W5_FABR_01 # SW5->W5_FABR .AND. IIF(EICLoja(),SW5->W5_FAB1LOJ # SW5->W5_FABLOJ,.T.)) ;
        .OR. (MFabr_Primeiro <> SW5->W5_FABR .And. IIF(EICLoja(),MFabr_Loj <> SW5->W5_FABLOJ,.T.))
        MAusenciafa:="3"
     ENDIF
   ENDIF

   cDescr := STRTRAN(MSMM(SB1->B1_DESC_GI,254),CHR(13)+CHR(10),Space(1))// FSY - 14/10/2013 - Ajustada para substituir ENTER pelo espaço.
   
   If !lPLI50   // GFP - 26/07/2013
      cTexto := SPACE( 604)
   Else
      cTexto := SPACE( 4193)
   EndIf
   cTexto := STUFF( cTexto, 001, 002, "03")   && REGISTRO  NUMERO 03
   cTexto := STUFF( cTexto, 003, 010, cCod_Suf)
   cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUFR )
   cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )

   SYX->(DBSETORDER(3))
   IF ! SYX->(DBSEEK(xFilial()+SW4->W4_PROD_SU+SW5->W5_COD_I))  // Ativo Fixo
      cTexto := STUFF( cTexto, 030, 004, STRZERO( mSeqAtivoFixo,4) )
      mSeqAtivoFixo += 1
   ELSE
     cDescr := SYX->YX_DES_ZFM
      cTexto := STUFF( cTexto, 030, 004, AVPadl(IF(!EMPTY(SYX->YX_INSUMO),ALLTRIM(SYX->YX_INSUMO),0), 4, "0" ) )
   ENDIF
   SYX->(DBSETORDER(1))
   cTexto := STUFF( cTexto, 034, 011, STRZERO( VAL( SW4->W4_PROD_SU ), 11) )
   cTexto := STUFF( cTexto, 045, 014, ORI100Numero( nQtde, 09, 5 ) )
   cTexto := STUFF( cTexto, 059, 020, SUBSTR( SAH->AH_DESCPO, 1, 20 ) )
   //nPeso_Un := IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,SB1->B1_PESO) // FCD 05/07/2001
   nPeso_Un := If(!Empty(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))) // RA - 11/11/2003 - O.S. 1192/03

   IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOESTUFF"),)

   nPesTotItem:= nQtde * nPeso_Un  //SB1->B1_PESO       //<< PESO
   nFob       := nQtde * SW5->W5_PRECO
   nRatDesp := MDespesas * ( nFob / nWP_FOB_TOT )
   cValor_Tot := nFob+nRatDesp

   //nRatDesp := MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI)) //<< PESO
   //cValor_Tot += nRatDesP

   //** PLB 06/08/07
   If !lW4_Fre_Inc .Or. ( SW4->W4_FREINC $ cNao  .And. AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE") )/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
      nRatFre := MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI)) //<< PESO
      cValor_Tot += nRatFre
   EndIf
   //**

   IF nRatDesp + nRatFre # 0
      cValor_Uni := cValor_Tot / nQtde
   ELSE
      cValor_UnI := SW5->W5_PRECO
   ENDIF
   cFob_Cli   -= nQtde * cValor_Uni

   cTexto := STUFF( cTexto, 079, 018, ORI100Numero( cValor_Uni, 11, 7 ) )
   //cTexto := STUFF( cTexto, 094, 254, MSMM( SB1->B1_DESC_GI, 254, 1 ) )
   cTexto := STUFF( cTexto, 097, 254, cDescr )
   //JVR - 10/03/10 - variavel lIndus para tratamento dos produtos de tipo industrialização, Imprimir somente se for industrialização.
   If !lPLI50 //FDR - 23/04/13
      cTexto := STUFF( cTexto, 351, 080, IF(lIndus, SB1->B1_ESPECIF, space(80)) ) 
      cTexto := STUFF( cTexto, 451, 020, IF(lIndus, SA5->A5_PARTOPC, space(20)) )    
      cTexto := STUFF( cTexto, 471, 020, IF(lIndus, SB1->B1_MAT_PRI, space(20)) )                          
   Else
      //cTexto := STUFF( cTexto, 351, 020, IF(lIndus, SA5->A5_CODPRF , space(20)) ) //NCF-20/05/2010 - PLI 5.0  
      
      //*FSY - 14/10/2013 - Ajustada conforme o layout PLI 5.0
      cTexto := STUFF( cTexto, 351, 020, IF(lIndus, SA5->A5_CODPRF , space(20)) )
      cTexto := STUFF( cTexto, 371, 020, IF(lIndus, SA5->A5_PARTOPC, space(20)) )
      cTexto := STUFF( cTexto, 391, 020, IF(lIndus, SB1->B1_MAT_PRI, space(20)) )
      //*FSY - 14/10/2013
            
      //NCF-19/05/2010-PLI 5.0- Complemento da Descrição (TX_ESPEC_COMPLEM)
      If lIndus
      /* cTexto := STUFF( cTexto, 491, 3723, SB1->B1_ESPECIF+Space(80-LEN(SB1->B1_ESPECIF))+;                //NCF-20/05/2010 - PLI 5.0
                                             SA5->A5_CODPRF +Space(20-LEN(SA5->A5_CODPRF))+;
                                             SA5->A5_PARTOPC+Space(20-LEN(SA5->A5_PARTOPC))+;
                                             SB1->B1_MAT_PRI+Space(20-LEN(SB1->B1_MAT_PRI)) )*/ 
      /*SB1->B1_ESPECIFMSMM(SB1->B1_DESC_P,AVSX3("B1_VM_P",3))+Space(1)+SA5->A5_CODPRF +Space(1)+SA5->A5_PARTOPC+Space(1)+SB1->B1_MAT_PRI+;
      Space(3723-Len(SA5->A5_CODPRF +Space(1)+SA5->A5_PARTOPC+Space(1)+SB1->B1_MAT_PRI)))*/  // GFP - 19/09/2013

         //*FSY - 14/10/2013 - Ajuste para substituir espaço no lugar do ENTER e ajustada a posição onde ira incluir o conteudo da cDescProd     
         cDescProd := Left(MSMM(SB1->B1_DESC_P,AVSX3("B1_VM_P",3)),3783)
         cDescProd := StrTran(cDescProd, chr(13)+chr(10), Space(1))
         cTexto := STUFF( cTexto, 411, 4193, cDescProd)
         //*FSY - 14/10/2013 
                                    
      EndIf 
   EndIF

   
   //nPeso_Un := IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,SB1->B1_PESO) //FCD 05/07/2001
   nPeso_Un := If(!Empty(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))) // RA - 11/11/2003 - O.S. 1192/03

   IF EasyEntryPoint("ICPADSUF")
      EXECBLOCK("ICPADSUF",.F.,.F.,"ENVIO")
   ENDIF
   
   AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

   Peso_L   += nQtde * nPeso_Un   //SB1->B1_PESO
   Qtde_Est += nQtde * nTx_Conv
   Vlr_Moeda+= nQtde * cValor_Uni
   Vlr_MoeCtx+= nQtde * cValor_Uni
   Vlr_Usd  += ( nQtde * cValor_Uni ) * BuscaTaxa( SW2->W2_MOEDA, SW4->W4_PGI_DT ) / BuscaTaxa( cMoedaDolar,SW4->W4_PGI_DT )
   
   IF EasyEntryPoint("ICPADSUF")
      EXECBLOCK("ICPADSUF",.F.,.F.,"TOTAIS")
   ENDIF
   
   SW5->( DBSKIP() )
ENDDO

IF ROUND( cFob_Cli, 2 ) # 0
   //FDR - 23/04/13
   IF !lPLI50
      Vlr_Moeda-= nQtde  * cValor_Uni   
   ELSE   
      Vlr_MoeCtx -= nQtde  * cValor_Uni //NCF-20/05/2010-PLI 5.0 - Deve ser calculada o Valor da mercadoria com taxas e sem as taxas
   ENDIF
   Vlr_Usd    -= ( nQtde * cValor_Uni) * BuscaTaxa( SW2->W2_MOEDA, SW4->W4_PGI_DT ) / BuscaTaxa( cMoedaDolar,SW4->W4_PGI_DT )
   Vlr_MoeCtx += nQtde  * ( cValor_Uni+ cFob_Cli )
   Vlr_Usd    += ( nQtde * ( cValor_Uni + cFob_Cli ) ) * BuscaTaxa( SW2->W2_MOEDA, SW4->W4_PGI_DT ) / BuscaTaxa(cMoedaDolar,SW4->W4_PGI_DT )
ENDIF

SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))
SY8->(DBSEEK(xFilial()+SW4->W4_REGIMP))

IF EMPTY(SW4->W4_COND_PAG)
   SY6->(DBSEEK(xFilial()+SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PAG,3)))
ELSE
   SY6->(DBSEEK(xFilial()+SW4->W4_COND_PAG+STR(SW4->W4_DIAS_PAG,3)))
ENDIF

//LGS-17/12/2014 - Monta Registro numero 04
dbSelectArea("EIT")
EIT->(dbSetOrder(1))
IF EIT->(DbSeek(xFilial("EIT")+SW4->W4_PGI_NUM)) .AND. lPLI50
   Do While EIT->(!EOF()) .AND. EIT->EIT_PGI_NU == SW4->W4_PGI_NUM
   	  cTexto := SPACE( 70)
   	  cTexto := STUFF( cTexto, 001, 002, "04" )   && REGISTRO  NUMERO 04
   	  cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
   	  cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )
   	  cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
   	  cTexto := STUFF( cTexto, 030, 020, EIT->EIT_PGI_NU )
   	  cTexto := STUFF( cTexto, 050, 010, EIT->EIT_ORGAO )
   	  cTexto := STUFF( cTexto, 060, 011, STRZERO( VAL( SW4->W4_PROD_SU ), 11 ) )
   	  AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA
   	  EIT->(DbSkip())
   EndDo
ENDIF

Inicio := 1
FOR I=1 TO 10
   IF Empty( SubStr( SWP->WP_DESTAQ, Inicio, 3 ) )
      Inicio+=3
      Loop
   Endif
   
   If !lPLI50   // GFP - 26/07/2013
      cTexto := SPACE( 604)
   Else
      cTexto := SPACE( 43)
   EndIf
   cTexto := STUFF( cTexto, 001, 002, "05" )   && REGISTRO  NUMERO 05
   cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
   cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )
   cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
   cTexto := STUFF( cTexto, 030, 003, SUBSTR( SWP->WP_DESTAQ, Inicio, 3 ) )
   cTexto := STUFF( cTexto, 033, 011, STRZERO( VAL( SW4->W4_PROD_SU ), 11 ) )
   AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

   Inicio+=3
NEXT

IF EMPTY( SWP->WP_DESTAQ )
   cTexto := SPACE( 604)
   cTexto := STUFF( cTexto, 001, 002, "05" )   && REGISTRO  NUMERO 05
   cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
   cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )
   cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
   cTexto := STUFF( cTexto, 030, 003, '000' )
   cTexto := STUFF( cTexto, 033, 011, STRZERO( VAL( SW4->W4_PROD_SU ), 11 ) )
   AADD( aGrv_Gip, cTexto)  && GRAVACAO NA TABELA
ENDIF

If !lPLI50   // GFP - 26/07/2013
   cTexto := SPACE( 604)
Else
   cTexto := SPACE( 4088)
EndIf
cTexto := STUFF( cTexto, 001, 002, "07" )   && REGISTRO  NUMERO 07
cTexto := STUFF( cTexto, 003, 010, cCod_Suf )
cTexto := STUFF( cTexto, 013, 009, SYT->YT_INS_SUF )
cTexto := STUFF( cTexto, 022, 008, SWP->WP_NCM )
cTexto := STUFF( cTexto, 030, 011, STRZERO( VAL( SW4->W4_PROD_SU ), 11 ) )
If !lPLI50
   cTexto := STUFF( cTexto, 041, 254, StrTran( MSMM( SW4->W4_DESC_GER, 254, 1 ), Space(1) ) )//FSY - 14/10/2013 - Ajustada substituir o ENTER pelo espaço
   cTexto := STUFF( cTexto, 351, 254, StrTran( MSMM( SW4->W4_DESC_GER, 254, 2 ), Space(1) ) )//FSY - 14/10/2013 - Ajustada substituir o ENTER pelo espaço
Else   
   /*If lIndus  // Nopado por GFP - 24/09/2013 - Sistema deve permitir Informações Complementares mesmo sem Industrialização.
      cTexto := STUFF( cTexto, 491, 4048, SB1->B1_ESPECIF+Space(80-LEN(SB1->B1_ESPECIF))+;    //NCF-20/10/2010 - PLI 5.0
                                          SA5->A5_CODPRF +Space(20-LEN(SA5->A5_CODPRF))+;
                                          SA5->A5_PARTOPC+Space(20-LEN(SA5->A5_PARTOPC))+;
                                          SB1->B1_MAT_PRI+Space(20-LEN(SB1->B1_MAT_PRI))) 
   EndIf*/
   /*If SY6->Y6_TIPOCOB == "4"  // Sem cobertura cambial.
      cTexto := STUFF( cTexto, 491, 4048, Posicione("SJ8",1,xFilial("SJ8")+SY6->Y6_MOTIVO,"J8_DESC"))  // GFP - 30/09/2013 - Informar motivo de pagamento sem cobertura cambial.
   EndIf*/
   cTexto := STUFF( cTexto, 041, 254, MSMM( SW4->W4_DESC_GER, 254, 1 ) ) //LGS-17/12/2014 - Sempre deve enviar a descrição ao arquivo gerado.
EndIf
AADD( aGrv_Gip, cTexto )  && GRAVACAO NA TABELA

IF (cPosicao:=ASCAN(aGrv_Gip,{|registro| SUBSTR(registro,1,2) == "09" })) # 0
    cTexto := aGrv_Gip[cPosicao]
    cTexto := STUFF( cTexto, 049, 015, ORI100Numero( Peso_L    , 10, 05 ) )  && PESO LIQUIDO
    cTexto := STUFF( cTexto, 064, 014, ORI100Numero( Qtde_Est  , 09, 05 ) )  && QTDE NA MEDIDA ESTATISTICA
    //FDR - 23/04/13
    IF !lPLI50
       cTexto := STUFF( cTexto, 085, 015, ORI100Numero( Vlr_Moeda, 13, 02 ) )  && VLR MERCADORIA NA MOEDA NEGOCIADA
    ELSE
       cTexto := STUFF( cTexto, 085, 015, ORI100Numero( Vlr_MoeCtx, 13, 02 ) )  && VLR MERCADORIA NA MOEDA NEGOCIADA (Todas as Taxas)  - NCF-20/10/2010 - PLI 5.0
       //cTexto := STUFF( cTexto, 100, 015, ORI100Numero( Vlr_Moeda , 13, 02 ) )  && VLR MERCADORIA NA MOEDA NEGOCIADA (Nenhuma Taxa)    - NCF-20/10/2010 - PLI 5.0   // GFP - 19/09/2013
    ENDIF
    aGrv_Gip[cPosicao] := cTexto
ENDIF

IF (cPosicao:=ASCAN(aGrv_Gip,{|registro| SUBSTR(registro,1,2) == "08" })) # 0
    cTexto := aGrv_Gip[ cPosicao ]
**  cTexto := STUFF( cTexto, 218, 001, IF( MAusenciafa="1","0",IF(MAusenciafa="2","1","2"))) && AUSENCIA FABRICANTE
    //cTexto := STUFF( cTexto, 221, 001, MAusenciafa) && AUSENCIA FABRICANTE    // NOPADO POR GFP - 09/08/2013

    IF MAusenciafa = "2"
       SA2->(DBSEEK(xFilial()+SWP->WP_FABR+EICRetLoja("SWP","WP_FABLOJ")))

       cTexto := STUFF( cTexto, 222, 060, SA2->A2_NOME )
       cTexto := STUFF( cTexto, 282, 040, SA2->A2_END )
       cTexto := STUFF( cTexto, 322, 006, AVPadl( SA2->A2_NR_END, 6, "0" ) )
       cTexto := STUFF( cTexto, 328, 021, "." + SPACE( 20 ) )
       cTexto := STUFF( cTexto, 349, 025, SA2->A2_ESTADO )
       cTexto := STUFF( cTexto, 374, 025, SA2->A2_MUN )
       cTexto := STUFF( cTexto, 399, 003, IF(!empty(SA2->A2_PAIS).AND.LEN(ALLTRIM(SA2->A2_PAIS)) < 3,REPL("0",3-LEN(ALLTRIM(SA2->A2_PAIS)))+ALLTRIM(SA2->SA2_PAIS),SA2->A2_PAIS)) //AVPadl( SA2->A2_PAIS, 3, "0" ) )
    ENDIF
    aGrv_Gip[ cPosicao ] := cTexto
ENDIF

AEVAL( aGrv_Gip, {|texto| Suframex->(DBAPPEND()),;
                          Suframex->SUFTEXTO := texto} )
SWP->(RecLock( 'SWP',.F.))
SWP->WP_SUFRAMA := cCod_Suf
SWP->(MsUnlock())

RETURN .T.

*-------------------------------------*
FUNCTION SUF100VerGI(PPgi_Num)
*-------------------------------------*
LOCAL lRet := .T.

IF ! SW4->(DBSEEK(xFilial()+PPgi_Num))
   lRet := .F.
ELSE
   IF SW4->W4_SUFRAMA  $ cSim
      IF EMPTY( SW4->W4_DTLIBSU )
         lRet := .F.
      ENDIF
   ELSE
      lRet := .F.
   ENDIF
ENDIF

RETURN (lRet)

*-----------------------------*
Function SUF100DATA( nPgi_Num )
*-----------------------------*
SW4->(DBSEEK(xFilial()+nPgi_Num))
Return( SW4->W4_DTLIBSUF )

*--------------------------*
Function SUF100Fabricante()
*--------------------------*
RETURN BuscaFabr_Forn( TRB->WP_FABR + EICRetLoja("TRB","WP_FABLOJ") )

*--------------------------*
Function SUF100Marca(lTodos)
*--------------------------*
LOCAL cChar:=cMarca, nRecno:=TRB->(RECNO())

IF TRB->WP_FLAGWIN == cMarca
   cChar:=SPACE(02)
ENDIF

IF lTodos
   TRB->( DBEVAL({|| TRB->WP_FLAGWIN := cChar,;
                     SWP->(dbGoTo(TRB->RECNO)),;
                     SWP->(RecLock("SWP",.F.)),;
                     SWP->WP_FLAGWIN  := cChar,;
                     SWP->(MSUnlock()) }) )
   TRB->(DBGOTO(nRecno))
ELSE
   TRB->WP_FLAGWIN := cChar

   SWP->(dbGoTo(TRB->RECNO))
   SWP->(RecLock("SWP",.F.))
   SWP->WP_FLAGWIN := cChar // Atualiza flag no SWP, por causa do ORI100Ret
   SWP->(MSUnlock())
ENDIF

RETURN .T.

*--------------------------------------------*
FUNCTION AVPadl( xTexto, nLen, cChar )
*--------------------------------------------*
LOCAL cRet,cTexto

IF ValType(xTexto) == "N"
   cTexto := Str(xTexto)
ELSEIF ValType(xTexto) == "C"
   cTexto := xTexto
ELSE
   RETURN
ENDIF

cRet := LTrim(cTexto) // tira espacos a esquerda
cRet := Replic(cChar,nLen-Len(cRet))+cRet // coloca zeros a esquerda

Return cRet


/*
Funcao      : UPDX1SU100
Objetivos   : Ajustar o X1_CNT01
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data 	      : 31/07/2017
Obs         :
*/
Static Function UPDX1SU100(o)

o:TableStruct ('SX1',{'X1_GRUPO','X1_ORDEM','X1_CNT01'                        })
o:TableData   ('SX1',{'EISU01'  ,'01'      ,AllTrim(EasyGParam("MV_DIR_SUF")) })

Return
*----------------------------------------------------------------------------*
*                     FIM DO PROGRAMA EICSU100.PRW
*----------------------------------------------------------------------------*
