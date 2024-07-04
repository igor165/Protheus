/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICLO150 ³ Autor ³ Cristiano A. Ferreira ³ Data ³ 05.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posicao de Diaria de FFC.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICLO151()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "avprint.ch"
#INCLUDE "Eiclo151.ch"

#xTranslate NomeBanco(<Cod>) => If(SA6->(dbSeek(xFilial()+<Cod>)),SA6->A6_NREDUZ," ")
#xTranslate NomeCorr(<Cod>) =>  If(SYW->(dbSeek(xFilial()+<Cod>)),SYW->YW_NOME," ")

#define COURIER_NEW_08       oFont1
#define COURIER_NEW_08_BOLD  oFont2
#define COURIER_NEW_10_BOLD  oFont3

#define ALTURA_LINHA   40
#define COL_INICIAL    0
#define LAST_LINE      2200
#define LAST_COL       3150

#define COLUNA1        COL_INICIAL //Proc
#define COLUNA2        COLUNA1+380 //Fecha
#define COLUNA3        COLUNA2+230 //Cont
#define COLUNA4        COLUNA3+350 //Banco
#define COLUNA5        COLUNA4+430 //Corr
#define COLUNA6        COLUNA5+790 //Corretagem
#define COLUNA7        COLUNA6+100 //Moeda
#define COLUNA8        COLUNA7+500 //Valor

#xtranslate SomaLinha([<n>]) => (nLinhas += ALTURA_LINHA[*<n>])

#define ARRAY_TIPOS {STR0001, STR0002} //"Pagos"###"Abertos"

*------------------*
Function EICLO151()
*------------------*
Local nArea_Old := Select()
Local cFileWork, oDlg

Local aStrWork := { ;
             {"WKFFC"     , "C", 10, 0},;
             {"WK_HAWB"   , "C", AVSX3("W8_HAWB",AV_TAMANHO), 0 },;
             {"WK_CA_DT"  , "D",  8, 0 },;
             {"WK_CA_NUM" , "C", 15, 0 },;
             {"WK_BANCO"  , "C",  3, 0 },;
             {"WK_CORRETO", "C",  3, 0 },;
             {"WK_VL_CORR", "N", 15, 2 },;
             {"WK_MOEDA"  , "C",  3, 0 },;
             {"WK_VL_REAL", "N", 15, 2 },;
             {"WK_FORMPAG", "C", 20, 0 },;
             {"WK_VALOR"  , "N", 15, 4 } }

Local aCampos := { { {||Transf(Work->WKFFC,AllTrim(X3Picture("WB_LOTE")))},,STR0003 },; //"FFC"
                   { {||Work->WK_HAWB} ,,STR0004 },; //"Processo"
                   { {||Work->WK_CA_DT}  ,,STR0005 },; //"Fechamento"
                   { {||Work->WK_CA_NUM} ,,STR0006 },; //"Nro. Contrato"
                   { {||Work->WK_BANCO+" "+NomeBanco(Work->WK_BANCO)}  ,,STR0007 },; //"Banco"
                   { {||Work->WK_CORRETO+" "+NomeCorr(Work->WK_CORRETO)},,STR0008 },; //"Corretor"
                   { {||Transf(Work->WK_VL_CORR,cPictCorr)},,STR0009 },; //"Vl.Corretagem"
                   { {||Transf(Work->WK_VL_REAL,cPictFob)},,STR0010 },; //"Valor (R$)"
                   { {||Work->WK_MOEDA},,STR0011 },; //"Moeda"
                   { {||Transf(Work->WK_VALOR,cPictFob)},,STR0012} } //"Valor"

// *** Variaveis para MSSELECT
Local lInverte := .F., cMarca := GetMark()
Local oSelect, oPanel
// ***

Local nOpcao := 0

Private cFfc := Space(Len(SWB->WB_LOTE)), dIni_Fechamento:=AVCTOD(""), dFim_Fechamento:= AVCTOD("")
Private cCorretor := Space(Len(SWB->WB_CORRETO))
Private cPictCorr:=AllTrim(X3Picture("WB_VL_CORR"))
Private cPictFob :=AllTrim(X3Picture("WB_FOBMOE"))
Private cTipo := ARRAY_TIPOS[1], aTotais:={}, aTotMoedas:={}

// variavel p/ verificar se existem os cpos p/ o tratamento do pgto antecipado.
Private lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

//GFP 19/10/2010
aStrWork := AddWkCpoUser(aStrWork,"SWB")
cWorkFile := E_CriaTrab(,aStrWork,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! Used()
   Help("", 1, "AVG0000292")//MsgStop(STR0013) //"Não foi possível abrir o arquivo temporario !"
   E_EraseArq(cWorkFile) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados
   RETURN (NIL)
ENDIF

IndRegua("Work",cWorkFile+TEOrdBagExt(),"WKFFC+WK_HAWB",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0014) //"Processando Arquivo Temporario..."

SWB->(dbSetOrder(4)) // FILIAL+LOTE
SWB->(dbSeek(xFilial()))

DO WHILE (.T.)
   nOpcao := 0

   IF ! lo151Gets()
      // clicou no Cancelar
      EXIT
   ENDIF

   lo151Grava()

   Work->(dbGoTop())

   If ( Work->(Easyreccount("Work")) == 0 )
      Help("", 1, "AVG0000293")//MsgInfo(STR0015, STR0016) //"Não há registros para a seleção !"###"Atenção"
      Loop
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0017+cTipo FROM 09,00 TO 28,80 OF GetWndDefault() //"Posição Diaria de FFC - "
   @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 23/04/04 Painel para alinhamento MDI
   
   //GFP 19/10/2010
   aCampos := AddCpoUser(aCampos,"SWB","2")
   
   oSelect :=MsSelect():New("Work",,,aCampos,@lInverte,@cMarca,{35,5,140,315})

   DEFINE SBUTTON FROM 4,285 TYPE 6 ACTION Processa({|lEnd|lo151Imprime(@lEnd)},,STR0018,.T.) ; //"Imprimindo"
                                     ENABLE OF oPanel
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oSelect:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()})) CENTERED //LRL 23/04/04 Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If ( nOpcao = 0 )
       Exit
   EndIf

ENDDO

Work->(dbCloseArea())
//fErase(cWorkFile+GetDBExtension())
E_EraseArq(cWorkFile) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

SWB->(dbSetOrder(1))
SWB->(dbSeek(xFilial()))

Select(nArea_Old)

RETURN ( Nil )

*--------------------------*
Static Function lo151Gets()
*--------------------------*
Local oDlg, nOpca, oRadMenu
Local cForn_Nome := " ", cCorr_Nome := " "
Local aValid := {"INI_FECHAMENTO", "FIM_FECHAMENTO",;
                 "FFC", "CORRETOR" }
Local aObjs[7]
Private oGetCorretor

DEFINE MSDIALOG oDlg TITLE STR0019 FROM 08,15 TO 30, 65 OF GetWndDefault() //"Posição Diaria de FFC"

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 95, 165) //MCF - 21/07/2015
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT


@ 1.4, 2 SAY "Tipo:" OF oPanel
@ 1.4, 8.5 COMBOBOX cTipo ITEMS ARRAY_TIPOS SIZE 40,25 OF oPanel ;
   ON CHANGE If(cTipo=ARRAY_TIPOS[2], aEval(aObjs,{|x|x:Disable()}), aEval(aObjs,{|x|x:Enable()}) )

@ 3.8, 2 SAY aObjs[2] VAR STR0021 OF oPanel //"Inicial:"
@ 4.8, 2 SAY aObjs[3] VAR STR0022 OF oPanel //"Final:"

@ 6.5, 2 SAY  STR0023 OF oDlg //"FFC:"
@ 7.5, 2 SAY aObjs[4] VAR STR0024 OF oPanel //"Corretor: "

@ 3.8, 8.5 MSGET aObjs[5] VAR dIni_Fechamento VALID (lo151Valid("INI_FECHAMENTO"));
         SIZE 40,8 OF oPanel

@ 4.8, 8.5 MSGET aObjs[6] VAR dFim_Fechamento VALID (lo151Valid("FIM_FECHAMENTO"));
         SIZE 40,8 OF oPanel
@ 2.8, 1 GROUP aObjs[1] TO 5.6, 23 LABEL STR0020 OF oPanel //"Fechamento:"

@ 6.5, 8.5 MSGET cFFC F3 "FFC" PICTURE (AllTrim(X3Picture("WB_LOTE"))) VALID (lo151Valid("FFC"));
         SIZE 25,8 OF oPanel

@ 7.5, 8.5 MSGET aObjs[7] VAR cCorretor F3 "SYW" PICTURE (AllTrim(X3Picture("WB_CORRETO"))) ;
        VALID (lo151Valid("CORRETOR")) SIZE 5,8 OF oPanel

@ 7.5, 12 MSGET oGetCorretor  VAR cCorr_nome  SIZE 85,8 OF oPanel

oGetCorretor:Disable()
If cTipo=ARRAY_TIPOS[2]
   aEval(aObjs,{|x|x:Disable()})
ELSE
   aEval(aObjs,{|x|x:Enable()})
ENDIF

ACTIVATE MSDIALOG oDlg ;
            ON INIT  EnchoiceBar(oDlg,{||IF(aScan(aValid,{|x| lo151Valid(x,.T.)=.F.})=0, (nOpca:=1,oDlg:End()),)},;
                                      {||nOpca:=0,oDlg:End()}) CENTERED


RETURN ( nOpca == 1 )

*----------------------------------------------------
Static Function lo151Valid( cArg, lOk )
*----------------------------------------------------
Local lRet := .T.

DEFAULT lOk := .F.

DO CASE
   CASE cArg = "INI_FECHAMENTO"
      If dIni_Fechamento > dFim_Fechamento .And. IF(!lOk,!Empty(dFim_Fechamento),.T.)
         Help("", 1, "AVG0000297")//MsgInfo(STR0025,STR0016) //"Data Inicial deve ser maior que a Final!"###"Atenção"
         lRet := .F.
      EndIf

   CASE cArg = "FIM_FECHAMENTO"
      If dIni_Fechamento > dFim_Fechamento
         Help("", 1, "AVG0000297")//MsgInfo(STR0025,STR0016) //"Data Inicial deve ser maior que a Final!"###"Atenção"
         lRet := .F.
      EndIf

   CASE cArg = "FFC"
      SWB->(dbSetOrder(4))

      If !Empty(cFFc) .And. !SWB->(dbSeek(xFilial()+cFFc))
         Help("", 1, "AVG0000292")//MsgInfo(STR0026,STR0016) //"FFC não cadastrado !"###"Atenção"
         lRet := .F.
      EndIf

   Case cArg = "CORRETOR"
      If !Empty(cCorretor) .And. !SYW->(dbSeek(xFilial()+cCorretor))
         Help("", 1, "AVG0000299")//MsgInfo(STR0027,STR0016) //"Corretor não cadastrado !"###"Atenção"
         lRet := .F.
      Elseif !Empty(cCorretor)
         oGetCorretor:cText(SYW->YW_NOME)
      EndIf

ENDCASE

Return ( if(!lOk,.T.,lRet) )


*------------------------------------------------
Static Function lo151Grava()
*------------------------------------------------
Local nCount := 0, nRec_SWB := 0
Local bCorretor := {||Empty(cCorretor) .Or. cCorretor == SWB->WB_CORRETO}

Private bWhile := {|| .t. }
Private bFor   := {|| .t. }

SWB->( dbSetOrder(4)) // FILIAL+LOTE+FECHAMENTO

If cTipo = ARRAY_TIPOS[1] // Pagos
   bFor := {|| Eval(bCorretor)}
   If !Empty(cFFc) .And. !Empty(dFim_Fechamento)
      SWB->( dbSeek(xFilial()+cFFc+Dtos(dIni_Fechamento),.T.) )
      bWhile := {|| SWB->(WB_LOTE+DTOS(WB_CA_DT)) <= cFfc+Dtos(dFim_Fechamento) }

   Elseif !Empty(cFFc)
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Seek na primeira data nao branca.                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SWB->( dbSeek(xFilial()+cFFc+CHR(33),.T.) )
      bWhile := {|| SWB->(WB_LOTE) = cFfc .And. !Empty(SWB->WB_CA_DT) }

   Elseif !Empty(dFim_Fechamento)
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Seek no primeiro lote nao branco.                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SWB->( dbSeek(xFilial()+CHR(33),.T.) )
      bFor   := {||Eval(bCorretor) .And.;
                !Empty(SWB->WB_CA_DT) .And.;
                SWB->WB_CA_DT >= dIni_Fechamento .And. SWB->WB_CA_DT <= dFim_Fechamento}

   Else
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Seek no primeiro lote nao branco.                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SWB->( dbSeek(xFilial()+CHR(33),.T.) )
      bFor := {|| Eval(bCorretor) .And. !Empty(SWB->WB_CA_DT) }

   EndIf
Else // Abertos
   If !Empty(cFFc)
      SWB->( dbSeek(xFilial()+cFFc,.T.) )
      bWhile := {|| SWB->(WB_LOTE) == cFfc .And. Empty(SWB->WB_CA_DT) }
   Else
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Seek no primeiro lote nao branco.                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SWB->( dbSeek(xFilial()+CHR(33),.T.) )
      bFor := {|| Empty(SWB->WB_CA_DT) }
   EndIf
Endif

nRec_SWB := SWB->(Recno())
SWB->( dbEval({|| ++nCount},bFor,;
       {|| WB_FILIAL = xFilial("SWB") .And. Eval(bWhile)  }) )
SWB->(dbGoTo(nRec_SWB))

Processa( {|| ProcRegua( nCount ) ,;
              lo151Grv() } )

SWB->(dbSetOrder(4))
SWB->(dbSeek(xFilial()))

RETURN (NIL)

*-------------------------*
Static Function lo151Grv()
*-------------------------*
Local nInd, cDias, cFFc_Old, aFFC, i

Work->(avzap())
aTotais:={0,0,0}
aTotMoedas:={}

DO WHILE !SWB->(EOF()) .And. SWB->WB_FILIAL == xFilial("SWB") .And.;
         Eval(bWhile)

   cFfc_Old  := SWB->WB_LOTE
   aFFC      := {}

   Do while !SWB->(EOF()) .And. SWB->WB_FILIAL == xFilial("SWB") .And.;
            Eval(bWhile)  .And. cFfc_Old  == SWB->WB_LOTE

      If !Eval(bFor)
         SWB->(dbSkip())
         Loop
      EndIf

      cHawb := SWB->WB_HAWB                           
      // Se for adiantamento, coloca um * na frente do cpo WB_HAWB
      // para identificar que refere-se a um pagto antecipado e que o conteudo da coluna
      // processo e'o numero da PO.
      IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 30/08/2013
         cHawb := "* "+LEFT(cHawb,LEN(cHawb)-2)
      ENDIF
      IF (nInd:=aScan( aFfc, {|x| x[1] = cHawb })) = 0
         // Nos casos de adiantamento o seek e' direcionado p/ o SW2,
         // pois no cpo WB_HAWB ja esta o numero da PO.  
         IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 30/08/2013
            SW2->(dbSeek(xFilial()+SWB->WB_HAWB))         
         ELSE
            SW7->(dbSeek(xFilial()+SWB->WB_HAWB))     
            SW2->(dbSeek(xFilial()+SW7->W7_PO_NUM))   
         ENDIF
         aAdd( aFfc, { cHawb          ,;
                       SWB->WB_CA_DT  ,;
                       SWB->WB_CORRETO,;
                       /*SWB->WB_VL_CORR*/0,;//JVR - 12/05/09
                       SW2->W2_MOEDA  ,;
                       0              ,;
                       SWB->WB_BANCO  ,;
                       SWB->WB_CA_NUM ,;
                       0              ,;
                       SWB->WB_FORMPAG })
         nInd := Len(aFfc)
      ENDIF                               
      
      aFFc[nInd][4] += SWB->WB_VL_CORR  //JVR - 12/05/09 - Somar valor total para corretagem.

      // Nos casos de adiantamento, o campo que contem o valor e' o 
      // WB_PGTANT e nas DI's o campo e' o WB_FOBMOE
      IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 30/08/2013
         aFFc[nInd][6] +=  SWB->WB_PGTANT
         aFFc[nInd][9] += (SWB->WB_PGTANT * SWB->WB_CA_TX)
      ELSE
      aFFc[nInd][6] +=  SWB->WB_FOBMOE
      aFFc[nInd][9] += (SWB->WB_FOBMOE * SWB->WB_CA_TX)
      ENDIF

      IncProc(STR0028+SWB->WB_HAWB) //"Gravando Processo: "
      SWB->(dbSkip())

   ENDDO

   For I := 1  to Len(aFfc)

      Work->(dbAppend())
      Work->WKFFC      := cFfc_Old
      Work->WK_HAWB    := aFfc[I][1]
      Work->WK_CA_DT   := aFfc[I][2]
      Work->WK_CORRETO := aFfc[I][3]
      Work->WK_VL_CORR := aFfc[I][4]
      Work->WK_MOEDA   := aFfc[I][5]
      Work->WK_VALOR   := aFfc[I][6]
      Work->WK_BANCO   := aFfc[I][7]
      Work->WK_CA_NUM  := aFfc[I][8]
      Work->WK_VL_REAL := aFfc[I][9]
      Work->WK_FORMPAG := aFfc[I][10]

      // Diferencia seeks e variaveis conforme tipo (DI ou adiantamento)     
      IF LEFT(Work->WK_HAWB,1)=="*"
         SW2->(dbSeek(xFilial()+Alltrim(SUBSTR(WORK->WK_HAWB,3))))
         cDias:=SW2->W2_DIAS_PA
      ELSE       
      SW6->(dbSeek(xFilial()+Work->WK_HAWB))
      SW7->(dbSeek(xFilial()+Work->WK_HAWB))
      SW2->(dbSeek(xFilial()+SW7->W7_PO_NUM))

      cDias:=IF(!EMPTY(SW6->W6_DIAS_PA),SW6->W6_DIAS_PA,SW2->W2_DIAS_PA)
      ENDIF

      If (nInd := aScan(aTotMoedas,{|x| x[1] = Work->WK_MOEDA}))==0
          aAdd( aTotMoedas, { Work->WK_MOEDA, 0, 0} )
          nInd := Len(aTotMoedas)
      Endif

      IF cDias = -1
         aTotMoedas[nInd][2] += Work->WK_VALOR
         aTotais[2] += Work->WK_VL_REAL
      ELSE
         aTotMoedas[nInd][3] += Work->WK_VALOR
         aTotais[3] += Work->WK_VL_REAL
      ENDIF

   Next

   IF !EMPTY(aFfc)
      aTotais[1]+= aFfc[1][4]
   ENDIF

ENDDO

RETURN (NIL)

*-----------------------------------------*
Static Function lo151Imprime(lEnd,aCampos)
*-----------------------------------------*
Local nRec_Old := Work->(Recno()), cMoeda:="", cForPag:=""
Local nInd, cLote:="", lPassou:=.T., nTotalMoeda:=0 
Private oPrn, oFont1, oFont2, nLinhas := 10000, nPage:=0, lImpObs := .F.

PRINT oPrn NAME ""
   oPrn:SetLandScape()
// oPrn:SetPortraid()
ENDPRINT

AVPRINT oPrn NAME "Posição Diária de FFC"
   ProcRegua( Work->(Easyreccount("Work")) )

   DEFINE FONT oFont1  NAME "Courier New"    SIZE 0,08       OF oPrn
   DEFINE FONT oFont2  NAME "Courier New"    SIZE 0,08  BOLD OF oPrn
   DEFINE FONT oFont3  NAME "Courier New"    SIZE 0,10  BOLD OF oPrn

   AVPAGE
     Work->(dbGoTop())
     While Work->(!Eof()) .And. !lEnd

         lPassou := .F.
         If ( nLinhas > LAST_LINE )
            LO151Cabecalho()
            oPrn:Say(nLinhas,COLUNA1,STR0029+Trans(Work->WKFFC,AllTrim(X3Picture("WB_LOTE"))),COURIER_NEW_08_BOLD) //"FFC: "
            SomaLinha()
            lPassou:=.T.
         EndIf

         IF cLote # Work->WKFFC
            IF !lPassou
               oPrn:Box(nLinhas,COL_INICIAL,nLinhas+1,LAST_COL)
               nLinhas += Int(ALTURA_LINHA/2)
               oPrn:Say(nLinhas,COLUNA1,STR0029+Transf(Work->WKFFC,AllTrim(X3Picture("WB_LOTE"))),COURIER_NEW_08_BOLD) //"FFC: "
               SomaLinha()
            ENDIF
            cLote   := Work->WKFFC
            cMoeda  := Work->WK_MOEDA
            cForPag := Work->WK_FORMPAG
         EndIf

         IF LEFT(Work->WK_HAWB,1)=="*"  
            lImpObs := .T.
         ENDIF
         oPrn:Say(nLinhas,COLUNA1,Work->WK_HAWB,COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA2,DTOC(Work->WK_CA_DT),COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA3,Work->WK_CA_NUM,COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA4,Work->WK_BANCO+" "+NomeBanco(Work->WK_BANCO),COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA5,Work->WK_CORRETO+" "+Substr(NomeCorr(Work->WK_CORRETO),1,19),COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA6,Trans(Work->WK_VL_CORR,cPictCorr),COURIER_NEW_08,,,,1)
         oPrn:Say(nLinhas,COLUNA7+20,Work->WK_MOEDA,COURIER_NEW_08)
         oPrn:Say(nLinhas,COLUNA8 ,Trans(Work->WK_VALOR,cPictFob),COURIER_NEW_08,,,,1)
         oPrn:Say(nLinhas,LAST_COL,Trans(Work->WK_VL_REAL,cPictFob),COURIER_NEW_08,,,,1)
         SomaLinha()

         nTotalMoeda+=Work->WK_VALOR

         Work->(dbSkip())

         IF cLote # Work->WKFFC
            oPrn:Say(nLinhas,COLUNA1,STR0030+cForPag,COURIER_NEW_08) //"Forma de Pagamento: "
            oPrn:Say(nLinhas,COLUNA8,STR0031+Trans(nTotalMoeda,cPictFob),COURIER_NEW_08_BOLD,,,,1) //"Total Moeda: "
            nTotalMoeda:=0
            SomaLinha()
         EndIf

         IncProc()
      ENDDO

      nLinhas += (ALTURA_LINHA*4)
      IF nLinhas > LAST_LINE
         lo151Cabecalho(.T.)
      ELSE
         nLinhas -= (ALTURA_LINHA*4)
      ENDIF

      LO151CabTotais()

      oPrn:Say( nLinhas, LAST_COL,STR0032+; //"Corretagem (R$) "
                REPL(" ",LEN(cPictFob)-3)+" "+;
                REPL(" ",LEN(cPictFob)-3)+" "+;
                Trans(aTotais[1],cPictFob),;
                COURIER_NEW_08,,,,1)
      SomaLinha()

      IF nLinhas > LAST_LINE; lo151Cabecalho(.T.); LO151CabTotais(); ENDIF

      oPrn:Say( nLinhas, LAST_COL,STR0033+; //"Valor (R$) "
                Trans( aTotais[2],cPictFob)+" "+;
                Trans( aTotais[3],cPictFob)+" "+;
                Trans((aTotais[2]+aTotais[3]),cPictFob),;
                COURIER_NEW_08,,,,1)
      SomaLinha()

      IF nLinhas > LAST_LINE; lo151Cabecalho(.T.); LO151CabTotais(); ENDIF

      For nInd:= 1 to Len(aTotMoedas)

          oPrn:Say(nLinhas, LAST_COL,aTotMoedas[nInd][1]+" "+;
                   Trans( aTotMoedas[nInd][2],cPictFob) +" "+;
                   Trans( aTotMoedas[nInd][3],cPictFob) +" "+;
                   Trans((aTotMoedas[nInd][2]+aTotMoedas[nInd][3]),cPictFob),;
                   COURIER_NEW_08,,,,1)
          SomaLinha()

          IF nLinhas > LAST_LINE; lo151Cabecalho(.T.); LO151CabTotais(); ENDIF

      Next
      IF lImpObs
         IF nLinhas > LAST_LINE
            lo151Cabecalho(.T.)
         ENDIF
         Somalinha()
         Somalinha()
         oPrn:Say(nLinhas,COLUNA1,STR0043, COURIER_NEW_08)//"Os processos iniciados com * referem-se a Adiantamentos - Numero do Pedido"      
      ENDIF         

   AVENDPAGE

   oFont1:End()
   oFont2:End()
   oFont3:End()

AVENDPRINT

Work->(dbGoTo(nRec_Old))
Return (NIL)
*-----------------------------------------
Static Function LO151CabTotais()
*-----------------------------------------
SomaLinha()
oPrn:Say( nLinhas, LAST_COL,STR0034, COURIER_NEW_08,,,,1) //"Totais          A Vista             A Prazo             Geral       "
SomaLinha()
oPrn:Say( nLinhas, LAST_COL,;
          REPL("=",LEN(STR0035))+" "+; //"Corretagem (R$)"
          REPL("=",LEN(cPictFob)-3)       +" "+;
          REPL("=",LEN(cPictFob)-3)       +" "+;
          REPL("=",LEN(cPictFob)-3),           ;
          COURIER_NEW_08,,,,1)
SomaLinha()
RETURN
*-----------------------------------------
Static Function lo151Cabecalho(lFinal)
*-----------------------------------------
Local  cAux

IF nPage != 0
   AVNEWPAGE
ENDIF

nLinhas := 100
nPage++

oPrn:Box(nLinhas,COL_INICIAL,nLinhas+1,LAST_COL)
nLinhas += Int(ALTURA_LINHA/2)

oPrn:Say(nLinhas,COL_INICIAL,SM0->M0_NOME,COURIER_NEW_10_BOLD)

cAux := cTipo
If cTipo = ARRAY_TIPOS[1]
   If !Empty(dFim_Fechamento)
      cAux += STR0036+Dtoc(dIni_Fechamento)+STR0037+Dtoc(dFim_Fechamento) //" - Intervalo: "###" a "
   Endif
Endif
oPrn:Say(nLinhas,Int(LAST_COL/2),STR0038+cAux,COURIER_NEW_10_BOLD,,,,2) //"Posição Diária de FFC - "

oPrn:Say(nLinhas,LAST_COL-7,STR0039+STR(nPage,8),COURIER_NEW_10_BOLD,,,,1) //"Pagina..: "
SomaLinha()

oPrn:Say(nLinhas,COL_INICIAL,'SIGAEIC',COURIER_NEW_10_BOLD)
oPrn:Say(nLinhas,LAST_COL-7,STR0040+DTOC(dDataBase),COURIER_NEW_10_BOLD,,,,1) //"Emissao.: "
SomaLinha()

oPrn:Box(nLinhas,COL_INICIAL,nLinhas+1,LAST_COL)
SomaLinha()

If !Empty(cFFc)
   oPrn:Say( nLinhas, COLUNA1, STR0029+Transf(cFFc,AllTrim(X3Picture("WB_LOTE"))), COURIER_NEW_08 ) //"FFC: "
   SomaLinha()
Endif

If cTipo = ARRAY_TIPOS[1] .And. !Empty(cCorretor)
   oPrn:Say( nLinhas, COLUNA1, STR0024+cCorretor+" "+NomeCorr(cCorretor), COURIER_NEW_08 ) //"Corretor: "
   SomaLinha()
ENDIF

IF lFinal = NIL
   oPrn:Say( nLinhas, COLUNA1, STR0004       , COURIER_NEW_08 ) //"Processo"
   oPrn:Say( nLinhas, COLUNA2, STR0041        , COURIER_NEW_08 ) //"Fecham."
   oPrn:Say( nLinhas, COLUNA3, STR0006  , COURIER_NEW_08 ) //"Nro. Contrato"
   oPrn:Say( nLinhas, COLUNA4, STR0007          , COURIER_NEW_08 ) //"Banco"
   oPrn:Say( nLinhas, COLUNA5, STR0008       , COURIER_NEW_08 ) //"Corretor"
   oPrn:Say( nLinhas, COLUNA6, STR0035, COURIER_NEW_08,,,,1) //"Corretagem (R$)"
   oPrn:Say( nLinhas, COLUNA7, STR0011          , COURIER_NEW_08 ) //"Moeda"
   oPrn:Say( nLinhas, COLUNA8, STR0042    , COURIER_NEW_08,,,,1) //"Valor Moeda"
   oPrn:Say( nLinhas, LAST_COL, STR0010    , COURIER_NEW_08,,,,1) //"Valor (R$)"
   SomaLinha()

   oPrn:Say( nLinhas, COLUNA1, Repl("=", 17), COURIER_NEW_08 )
   oPrn:Say( nLinhas, COLUNA2, Repl("=", 08), COURIER_NEW_08 )
   oPrn:Say( nLinhas, COLUNA3, Repl("=", 15), COURIER_NEW_08 )
   oPrn:Say( nLinhas, COLUNA4, Repl("=", 19), COURIER_NEW_08 )
   oPrn:Say( nLinhas, COLUNA5, Repl("=", 23), COURIER_NEW_08 )
   oPrn:Say( nLinhas, COLUNA6, Repl("=",LEN(cPictCorr)-3), COURIER_NEW_08,,,,1)
   oPrn:Say( nLinhas, COLUNA7, "====="                   , COURIER_NEW_08)
   oPrn:Say( nLinhas, COLUNA8, Repl("=",LEN(cPictFob)-3) , COURIER_NEW_08,,,,1)
   oPrn:Say( nLinhas, LAST_COL,Repl("=",LEN(cPictFob)-3) , COURIER_NEW_08,,,,1)
   SomaLinha()
ENDIF

Return ( NIL )

*---------------------------------------------------------------------------
* FIM DO PROGRAMA EICLO151.PRW
*---------------------------------------------------------------------------
