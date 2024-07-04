/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICLO150 ³ Autor ³AVERAGE/CRISTIANO A.F. ³ Data ³ 29.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Previsão de Caixa                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICLO150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "avprint.ch"
#INCLUDE "Eiclo150.ch"

#define COURIER_NEW_08       oFont1
#define COURIER_NEW_10_BOLD  oFont2

#define ALTURA_LINHA   50   
#define COL_INICIAL    0
#define LAST_LINE      2100
#define LAST_COL       3180

#define COLUNA         200
#define COL_FORN       510
/*  
#define COLUNA1        COL_INICIAL
#define COLUNA2        COL_FORN+COLUNA1                                  
#define COLUNA3        COLUNA+COLUNA2
#define COLUNA4        COLUNA+COLUNA3
#define COLUNA5        COLUNA+COLUNA4
#define COLUNA6        COLUNA+COLUNA5
#define COLUNA7        COLUNA+COLUNA6
#define COLUNA8        COLUNA+COLUNA7
#define COLUNA9        COLUNA+COLUNA8
#define COLUNAA        COLUNA+COLUNA9
#define COLUNAB        COLUNA+COLUNAA
#define COLUNAC        COLUNA+COLUNA11
#define COLUNAD        COLUNA+COLUNA12
#define COLUNAE        COLUNA+COLUNA13
*/  
#xtranslate SomaLinha([<n>]) => (nLinhas += ALTURA_LINHA[*<n>])
#xtranslate DtInicial() => AVCTOD("01/"+cIni_MesAno)

Function EICLO150()

EICLO150R3(.T.)
Return .t.

*-----------------------------------------------
Function EICLO150R3(p_R4)
*-----------------------------------------------
Local nArea_Old := Select()
Local cFileWork, oDlg , oPanel

Local aStrWork := ;
	   { ;
	     {"WKFORN", "C", 27, 0},;
	     {"WKMES01" , "N", 12, 0 },; 
	     {"WKMES02" , "N", 12, 0 },;                           
	     {"WKMES03" , "N", 12, 0 },;
	     {"WKMES04" , "N", 12, 0 },;
	     {"WKMES05" , "N", 12, 0 },;                           
	     {"WKMES06" , "N", 12, 0 },;
	     {"WKMES07" , "N", 12, 0 },;
	     {"WKMES08" , "N", 12, 0 },;                           
	     {"WKMES09" , "N", 12, 0 },;
	     {"WKMES10" , "N", 12, 0 },;
	     {"WKMES11" , "N", 12, 0 },;                           
	     {"WKMES12" , "N", 12, 0 },;
	     {"WKTOTAL" , "N", 12, 0 } }

// *** Variaveis para MSSELECT
Local lInverte := .F., cMarca := GetMark()
Local aCampos, oSelect
// ***

Local nOpcao := 0
Local i, nMes, nAno, cData := "",j

Private cIni_MesAno  := "01/"+Right(Dtoc(dDataBase),2)
Private cFim_MesAno  := "12/"+Right(Dtoc(dDataBase),2)
Private dDataCotacao := dDataBase
Private cImportador  := Space(Len(SYT->YT_COD_IMP))
Private cFornecedor  := Space(Len(SA2->A2_COD))
Private cLoja        := Space(Len(SA2->A2_LOJA))
Private lCposAdto    := .T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
//PRIVATE lExisteRdmake:=EasyEntryPoint("EICLO150")// TDF - 17/03/10
EICAddWkLoja(aStrWork, "WB_LOJA", "WKFORN")

cWorkFile := E_CriaTrab(,aStrWork,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! Used()
   Help("", 1, "AVG0000292")//MsgStop(STR0001) //"Não foi possível abrir o arquivo temporario !"
   E_EraseArq(cWorkFile) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados 
   RETURN (NIL)
ENDIF

DO WHILE (.T.)
   nOpcao := 0
   aCampos := { { {||Work->WKFORN }, "" , STR0002 },; //"Fornecedor"
		  { {|_Pict|PoePict(Work->WKMES01,_Pict)}, "" , STR0003    },; //"#Mes01#"
		  { {|_Pict|PoePict(Work->WKMES02,_Pict)}, "" , STR0004    },; //"#Mes02#"
		  { {|_Pict|PoePict(Work->WKMES03,_Pict)}, "" , STR0005    },; //"#Mes03#"
		  { {|_Pict|PoePict(Work->WKMES04,_Pict)}, "" , STR0006    },; //"#Mes04#"
		  { {|_Pict|PoePict(Work->WKMES05,_Pict)}, "" , STR0007    },; //"#Mes05#"
		  { {|_Pict|PoePict(Work->WKMES06,_Pict)}, "" , STR0008    },; //"#Mes06#"
		  { {|_Pict|PoePict(Work->WKMES07,_Pict)}, "" , STR0009    },; //"#Mes07#"
		  { {|_Pict|PoePict(Work->WKMES08,_Pict)}, "" , STR0010    },; //"#Mes08#"
		  { {|_Pict|PoePict(Work->WKMES09,_Pict)}, "" , STR0011    },; //"#Mes09#"
		  { {|_Pict|PoePict(Work->WKMES10,_Pict)}, "" , STR0012    },; //"#Mes10#"
		  { {|_Pict|PoePict(Work->WKMES11,_Pict)}, "" , STR0013    },; //"#Mes11#"
		  { {|_Pict|PoePict(Work->WKMES12,_Pict)}, "" , STR0014    },; //"#Mes12#"
		  { {|_Pict|PoePict(Work->WKTOTAL,_Pict)}, "" , STR0015      } } //"Total"

   IF ! lo150Gets()
      // clicou no Cancelar
      EXIT
   ENDIF
  
   //If lR4
   //TRP - 02/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
      //oReport := ReportDef()
   //EndIf


   lo150Grava()
   
   Work->(dbGoTop())
   If ( Work->(Easyreccount("Work")) == 0 )
      Help("", 1, "AVG0000293")//MsgInfo(STR0016, STR0017) //"Não há registros para a seleção !"###"Atenção"
	  Loop 
   EndIf
   
   For i:=0 to 11
      nMes := /*Val(Left(cIni_MesAno,2))*/1+i //TDF - 08/08/2012
	  
	  If nMes > 12
	     nMes := nMes-12
         nAno := Val(Right(cIni_MesAno,2))+1
         If ( nAno > 99 )
		    nAno := 00
		 EndIf
      Else
	     nAno := Val(Right(cIni_MesAno,2))
	  EndIf
	  
      cData := "01/"+StrZero(nMes,2)+"/"+StrZero(nAno,2)
      aCampos[i+2][3] := cMes(AVCTOD(cData))+" "+StrZero(Year(AVCTOD(cData)),4)
	  
	  If Right(cData,5) = cFim_MesAno
	     Exit
	  EndIf
   Next
   
   If Right(cData,5) != cFim_MesAno
  	  aCampos[13][3] := "... "+cMes(DtFinal())+"/"+Right(cFim_MesAno,2)
   Else
	  aSize( aCampos, i+2 )
      aAdd( aCampos, { {|_Pict|PoePict(Work->WKTOTAL,_Pict)}, "", STR0015} ) //"Total"
   EndIf
								 
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE STR0018 ; //"Previsão de Caixa"
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          
   @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 23/04/04 - Painel para alinhamento MDI.
   oSelect :=MsSelect():New("Work",,,aCampos,@lInverte,@cMarca,{35,5,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2})
   
   DEFINE SBUTTON FROM 04,(oDlg:nClientWidth-2)/2-30 TYPE 6 ACTION Processa(If(lR4, {||(oReport := ReportDef(),oReport:PrintDialog())},{|lEnd|lo150Imprime(@lEnd,aCampos)}),,STR0019,.T.) ; //"Imprimindo"
   ENABLE OF oPanel
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oSelect:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()})) //LRL 23/04/04 - Painel para Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   If ( nOpcao = 0 )
       Exit
   EndIf
   
ENDDO

Work->(dbCloseArea())
//fErase(cWorkFile+GetDBExtension())
E_EraseArq(cWorkFile) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

Select(nArea_Old)

RETURN ( Nil )

*---------------------------------------------
Static Function lo150Gets()
*---------------------------------------------
Local oDlg, nOpca
Local cForn_Nome := " ", cImp_Nome := " "
Local aValid := {"INI_MESANO", "FIM_MESANO", "IMPORTADOR", "FORNECEDOR", "DATA_COTACAO"}
Private oGetForn, oGetImp, oGetLoja

DEFINE MSDIALOG oDlg TITLE STR0018 FROM 05,15 TO 22,65 OF GetWndDefault() //"Previsão de Caixa"

//FDR - 08/08/12 - Criação do oPanel para ajuste da tela de filtro
oPanel:= TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@ 12, 8 TO 52,184 LABEL STR0020 OF oPanel PIXEL //" Vencimento Mes/Ano: "

@ 26,16 SAY STR0021 OF oPanel SIZE 30,8 PIXEL //"Inicial:"
@ 39,16 SAY STR0022 OF oPanel SIZE 30,8 PIXEL //"Final:"

@ 58,16 SAY STR0023 OF oPanel SIZE 60,8 PIXEL //"Data da Cotação:"
@ 71,16 SAY STR0024 OF oPanel SIZE 30,8 PIXEL //"Importador: "
@ 84,16 SAY STR0025 OF oPanel SIZE 30,8 PIXEL //"Fornecedor: "

@ 26,60 MSGET cIni_MesAno PICTURE "99/99";
              VALID (lo150Valid("INI_MESANO")) SIZE 20,8 OF oPanel FONT oDlg:oFont PIXEL

@ 39,60 MSGET cFim_MesAno PICTURE "99/99";
              VALID (lo150Valid("FIM_MESANO")) SIZE 20,8 OF oPanel PIXEL

@ 58,60 MSGET dDataCotacao PICTURE "@D";
              VALID (lo150Valid("DATA_COTACAO")) SIZE 45,8 OF oPanel PIXEL

@ 71,60 MSGET cImportador PICTURE AllTrim(X3Picture("YT_COD_IMP")) F3 "SYT";
              VALID (lo150Valid("IMPORTADOR")) SIZE 10,8 OF oPanel PIXEL

@ 84,60 MSGET cFornecedor PICTURE AllTrim(X3Picture("A2_COD")) F3 "FOR";
              VALID (lo150Valid("FORNECEDOR")) SIZE 15, 8 OF oPanel PIXEL

IF EICLOJA()
   @ 97,60 MSGET oGetLoja VAR cLoja SIZE 15,8 OF oPanel PIXEL
ENDIF

@ 71,110 MSGET oGetImp  VAR cImp_Nome  SIZE 85,8 OF oPanel PIXEL
@ 84,110 MSGET oGetForn VAR cForn_Nome SIZE 85,8 OF oPanel PIXEL

oGetImp:Disable()
oGetForn:Disable()

ACTIVATE MSDIALOG oDlg ;
	    ON INIT  EnchoiceBar(oDlg,{||IF(aScan(aValid,{|x| lo150Valid(x,.T.)=.F.})=0, (nOpca:=1,oDlg:End()),)},;
				      {||nOpca:=0,oDlg:End()}) CENTERED

RETURN ( nOpca == 1 )

*----------------------------------------------------
Static Function lo150MesAno(cMesAno, lOk)
*----------------------------------------------------
DEFAULT lOk := .F.

IF Val(Substr(cMesAno,1,2)) > 0 .And. Val(Substr(cMesAno,1,2)) < 13 
   Return (.T.)
ENDIF

Help("", 1, "AVG0000294")//MsgInfo(STR0026,STR0017) //"Mes inválido !"###"Atenção"

Return (If(!lOk,.T.,.F.))

*----------------------------------------------------
Static Function lo150Valid( cArg, lOk )
*----------------------------------------------------
Local lRet := .T.

DEFAULT lOk := .F.

DO CASE
   CASE cArg = "INI_MESANO"
        lRet := lo150MesAno(cIni_MesAno, lOk)
  
        If AVCTOD("01/"+cIni_MesAno) > AVCTOD("01/"+cFim_MesAno)
	       Help("", 1, "AVG0000295")//MsgInfo(STR0027, STR0028) //"Mes/Ano inicial deve ser menor ou igual ao Mes/Ano final !"###"Atencao"
	       lRet := .F.
        Endif
   
   CASE cArg = "FIM_MESANO"
        lRet := lo150MesAno(cFim_MesAno, lOk)

        If AVCTOD("01/"+cIni_MesAno) > AVCTOD("01/"+cFim_MesAno)
	       Help("", 1, "AVG0000295")//MsgInfo(STR0027, STR0028) //"Mes/Ano inicial deve ser menor ou igual ao Mes/Ano final !"###"Atencao"
           lRet := .F.
        Endif

   CASE cArg = "IMPORTADOR"
        IF ! SYT->(dbSeek(xFilial()+cImportador)) .And. ! Empty(cImportador) 
	       Help("", 1, "AVG0000138")//MsgInfo(STR0029, STR0017) //"Importador não cadastrado !"###"Atenção"
	       lRet := .F.
        ENDIF
        oGetImp:cText( SYT->YT_NOME_RE )

   CASE cArg = "FORNECEDOR"
        IF ! SA2->(dbSeek(xFilial()+cFornecedor+IF(EICLOJA(),cLoja,""))) .And.  ! Empty(cFornecedor)  .And. IF(EICLOJA(), ! Empty(cLoja), .T.)
           Help("", 1, "AVG0000141")//MsgInfo(STR0030, STR0017) //"Fornecedor não cadastrado !"###"Atenção"
		   lRet := .F.
        ENDIF
        oGetForn:cText( SA2->A2_NREDUZ )
        If EICLoja()
          oGetLoja:cText( SA2->A2_LOJA )
        EndIf
   
   Case cArg = "DATA_COTACAO"
	    If Empty(dDataCotacao)
		   Help("", 1, "AVG0000296")//MsgInfo(STR0031, STR0017)  //"A Data da Cotação deve ser preenchida !"###"Atenção"
		   lRet := .F.
	    EndIf
ENDCASE
Return ( if(!lOk,.T.,lRet) )

*------------------------------------------------
Static Function lo150Grava()
*------------------------------------------------
Local nCount := 0

SWB->(dbSetOrder(3))
SWB->( dbSeek(xFilial()+DTOS(AVCTOD(""))+DTOS(DtInicial()),.T.) )
SWB->( dbEval({|| ++nCount},,;
       {|| WB_FILIAL = xFilial("SWB") .And. EMPTY(WB_CA_DT) .And.;
	   DtInicial() <= WB_DT_VEN .And. DtFinal() >= WB_DT_VEN  }) )

Processa( {|| ProcRegua( nCount ), lo150Grv() } )
RETURN (NIL)

*------------------------------------------------------
Static Function lo150Grv()
*------------------------------------------------------
Local aMes := {}, i, j, nInd, nTotal,cImp,cMoeda 
PRIVATE nValSWB:=0 // TDF - 17/03/10
// Itens de aMes[n][1]  -> Codigo do fornecedor
//          aMes[n][2] a aMes[n][13] -> Meses

Work->(avzap())

SW9->(DBSETORDER(1))
SWB->( dbSeek(xFilial()+DTOS(AVCTOD(""))+DTOS(DtInicial()),.T.) )
DO WHILE !SWB->(EOF()) .And. SWB->WB_FILIAL = xFilial("SWB") .And.;
   EMPTY(SWB->WB_CA_DT) .And.;
   DtInicial() <= SWB->WB_DT_VEN .And. DtFinal() >= SWB->WB_DT_VEN

   IncProc(STR0032+SWB->WB_HAWB) //"Lendo Processo: "

   IF lCposAdto .AND. SWB->WB_PO_DI == "A"
      SW2->(dbSeek(xFilial()+Alltrim(SWB->WB_HAWB)))
      nValSWB := SWB->WB_PGTANT
      cImp:=SW2->W2_IMPORT
      cMoeda:=SW2->W2_MOEDA        
      SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
//      Work->WKFORN  := SWB->WB_FORN+" "+SA2->A2_NREDUZ
      // TDF - 17/03/10 - PONTO DE ENTRADA PARA CUSTOMIZAR A VARIÁVEL NVALSWB
      /*IF lExisteRdmake
         ExecBlock("EICLO150",.F.,.F.,"GRV_WK_SWB")
      ENDIF*/
   ELSE
      SW6->(dbSeek(xFilial()+SWB->WB_HAWB))
      SW7->(dbSeek(xFilial()+SWB->WB_HAWB))
      SW2->(dbSeek(xFilial()+SW7->W7_PO_NUM))
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA 
      SW9->(DBSEEK(xFilial("SW9")+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")+SWB->WB_HAWB))
      
      nValSWB := SWB->WB_FOBMOE
      cImp:=SW6->W6_IMPORT
      cMoeda:=SW9->W9_MOE_FOB

      // O While é mantido, pois nem todos possuem a alteração no índice 1 da SW9 (FILIAL+INVOICE+FORNECEDOR+HAWB)
      // A alteração do índice 1 da SW9 é disponibilizada através do update UIINVOICE
      lTemHawb:=.T.
      DO WHILE ! SW9->(EOF()) .AND. SW9->W9_INVOICE == SWB->WB_INVOICE .AND.  ;
         SW9->W9_FORN == SWB->WB_FORN .AND. (!EICLOJA() .OR. SW9->W9_FORLOJ == SWB->WB_LOJA)
         IF SW9->W9_HAWB == SW6->W6_HAWB
            lTemHawb:=.t.
            EXIT
         ENDIF
         SW9->(DBSKIP())
      ENDDO   
      IF ! lTemHawb
         SWB->(DBSKIP())
         LOOP
      ENDIF
   
   ENDIF
   
   //TDF - 17/03/10 - PONTO DE ENTRADA PARA CUSTOMIZAR A VARIÁVEL NVALSWB
   If EasyEntryPoint("EICLO150")   
      ExecBlock("EICLO150",.F.,.F.,"WHILE_SWB")
   EndIf
   IF ! Empty(cImportador) .And. cImportador # cImp
      SWB->(dbSkip())
      LOOP
   ENDIF

   IF ! Empty(cFornecedor) .And. cFornecedor != SWB->WB_FORN
      SWB->(dbSkip())
      LOOP
   ENDIF

   IF (nInd:=aScan( aMes, {|x| x[1] = SWB->WB_FORN })) = 0
      aAdd( aMes, {SWB->WB_FORN,0,0,0,0,0,0,0,0,0,0,0,0,IF(EICLOJA(),SWB->WB_LOJA,"")} )
	  nInd := Len(aMes)
   ENDIF
   
   If ( Qual_Mes()+1 > 13 )
	  aMes[nInd][13] += nValSWB * BuscaTaxa(cMoeda,dDataCotacao)
   Else
      aMes[nInd][Qual_Mes()+1] += nValSWB * BuscaTaxa(cMoeda,dDataCotacao) //TDF - 08/08/2012 //RRV - 15/01/2013
   EndIf
   
   SWB->(dbSkip())
ENDDO
   
For i:= 1 To Len(aMes)
   nTotal := 0
   Work->(dbAppend())
   
   SA2->(dbSeek(xFilial()+aMes[i][1]+IF(EICLOJA(),aMes[i][14],"")))
   Work->WKFORN  := aMes[i][1]+/*IF(EICLOJA(),aMes[i][14],"")+*/" "+SA2->A2_NREDUZ
   
   IF EICLOJA()
      Work->WB_LOJA:= aMes[i][14]
   ENDIF
   
   For j:=2 To Len(aMes[i])
      If j <> 14
         Work->( FieldPut(FieldPos("WKMES"+Padl(AllTrim(Str(j-1)),2,"0")), Int(aMes[i][j])) )
         nTotal += Int(aMes[i][j])
      Endif
   Next

   Work->WKTOTAL := nTotal
Next i

RETURN (NIL)

*-----------------------------------------------
Static Function cMes ( dData )
*-----------------------------------------------  
Local aMeses := {STR0033, STR0034, STR0035, STR0036, STR0037, STR0038,; //"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"
                 STR0039, STR0040, STR0041, STR0042, STR0043, STR0044," "}; //"Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"
                 
Return (aMeses[IF(Month(dData)=0,13,Month(dData))])

*--------------------------------------------
Static Function DtFinal()
*--------------------------------------------
Local xMes, xAno, cData

xMes := StrZero(Val(Left(cFim_MesAno,2))+1,2)

If Val(xMes)>12
   xMes := "01"
   xAno := StrZero(Val(Right(cFim_MesAno,2))+1,2)
   If ( Val(xAno) > 99 )
	   xAno := StrZero(0,2)
   EndIf
Else   
   xAno := Right(cFim_MesAno,2)
EndIf                

cData := "01/"+xMes+"/"+xAno

Return( AVCTOD(Left(Dtoc(AVCTOD(cData)-1),2)+"/"+cFim_MesAno)  )

*-------------------------------------------
Static Function Qual_Mes()
*-------------------------------------------
#xtranslate Mes(<dArg1>) => Substr(DTOC(<dArg1>),4,2)
Local nItem := 0, nDif_Ano

nItem := 1+Val(Mes(SWB->WB_DT_VEN))-Val(Left(cIni_MesAno,2))

If (nDif_Ano := Year(SWB->WB_DT_VEN) - Year(AVCTOD("01/"+cIni_MesAno))) != 0
   nItem += nDif_Ano*12
EndIf

Return ( nItem )

*-----------------------------------------------
Static Function lo150Imprime(lEnd,aCampos)
*-----------------------------------------------
// *** Dimensoes do array aColunas
#define COL    1    // Posicao da coluna na impressao
#define TITLE  2    // Titulo da coluna
#define VALOR  3    // Code block com o valor da coluna
#define TOTAL  4    // Total acumulado da coluna
// ***

Local aColunas := {}, i

Local nRec_Old := Work->(Recno())

Private COLUNA1:= COL_INICIAL
Private COLUNA2:= COL_FORN+COLUNA1                                  
Private COLUNA3:= COLUNA+COLUNA2
Private COLUNA4:= COLUNA+COLUNA3
Private COLUNA5:= COLUNA+COLUNA4
Private COLUNA6:= COLUNA+COLUNA5
Private COLUNA7:= COLUNA+COLUNA6
Private COLUNA8:= COLUNA+COLUNA7
Private COLUNA9:= COLUNA+COLUNA8
Private COLUNAA:= COLUNA+COLUNA9
Private COLUNAB:= COLUNA+COLUNAA
Private COLUNAC:= COLUNA+COLUNAB 
Private COLUNAD:= COLUNA+COLUNAC 
Private COLUNAE:= COLUNA+COLUNAD 

aCols := { COLUNA1, COLUNA2, COLUNA3, COLUNA4, COLUNA5, COLUNA6,;
           COLUNA7, COLUNA8, COLUNA9, COLUNAA,COLUNAB,COLUNAC,;
           COLUNAD, COLUNAE }

Private oPrn, oFont1, oFont2, nLinhas := 10000, nPage:=0

For i:=1 To Len(aCampos)
    Aadd(aColunas, { aCols[i], aCampos[i][3], aCampos[i][1], 0 } )
Next

PRINT oPrn NAME ""
   oPrn:SetLandScape()
ENDPRINT

AVPRINT oPrn NAME STR0018 //"Previsão de Caixa"
   ProcRegua( Work->(Easyreccount("Work")) )

   DEFINE FONT oFont1  NAME "Courier New"    SIZE 0,08         OF oPrn
   DEFINE FONT oFont2  NAME "Courier New"    SIZE 0,10  BOLD   OF oPrn

   AVPAGE
	  Work->(dbGoTop())
	  While Work->(!Eof()) .And. !lEnd
		 If ( nLinhas > LAST_LINE )
		    lo150Cabecalho(aColunas)
         EndIf
		 
         For i:=1 To Len( aColunas )
			If ( i>1 )
	           oPrn:Say( nLinhas, aColunas[i][COL], Eval(aColunas[i][VALOR]), COURIER_NEW_08 )
	           aColunas[i][TOTAL] += VAL(Eval(aColunas[i][VALOR],'x'))
			Else
			   oPrn:Say( nLinhas, aColunas[i][COL], Eval(aColunas[i][VALOR]), COURIER_NEW_08 )
			EndIf
         Next 
		 
		 SomaLinha() 
		 Work->(dbSkip())         
		 IncProc(STR0045+Work->WKFORN) //"Imprimindo Forn.: "
	  End
	  
	  For i:=Len(aColunas) To 1 Step -1
          If ( i = 1 )
             oPrn:Box( nLinhas, aColunas[i][COL], nLinhas+1, aColunas[i][COL]+COL_FORN-20 )
          Else    
             oPrn:Box( nLinhas, aColunas[i][COL], nLinhas+1, aColunas[i][COL]+COLUNA-20 )
          EndIf
      Next
  
	  oPrn:Say( SomaLinha(.5), COLUNA1, STR0015, COURIER_NEW_08 ) //"Total"
	  For i:=2 to Len( aColunas )
	      oPrn:Say( nLinhas, aColunas[i][COL], Transf(aColunas[i][TOTAL],"@E 99,999,999"), COURIER_NEW_08 )
	  Next
   AVENDPAGE
   
   oFont1:End()
   oFont2:End()

AVENDPRINT

Work->(dbGoTo(nRec_Old))
Return (NIL)

*-----------------------------------------
Static Function lo150Cabecalho(aColunas)
*-----------------------------------------
Local i

IF nPage != 0
   AVNEWPAGE
ENDIF

nLinhas := 100
nPage++

oPrn:Box(nLinhas,COL_INICIAL,nLinhas+1,LAST_COL)
nLinhas += Int(ALTURA_LINHA/2)

oPrn:Say(nLinhas,COL_INICIAL,SM0->M0_NOME,COURIER_NEW_10_BOLD)
oPrn:Say(nLinhas,Int(LAST_COL/2),STR0018,COURIER_NEW_10_BOLD,,,,2) //"Previsão de Caixa"
oPrn:Say(nLinhas,LAST_COL-7,STR0046+STR(nPage,8),COURIER_NEW_10_BOLD,,,,1) //"Pagina..: "
SomaLinha()

oPrn:Say(nLinhas,COL_INICIAL,'SIGAEIC',COURIER_NEW_10_BOLD)
oPrn:Say(nLinhas,LAST_COL-7,STR0047+DTOC(dDataBase),COURIER_NEW_10_BOLD,,,,1) //"Emissao.: "
SomaLinha()

oPrn:Box(nLinhas,COL_INICIAL,nLinhas+1,LAST_COL)
SomaLinha()

For i:=Len(aColunas) To 1 Step -1
   oPrn:Say( nLinhas, aColunas[i][COL], aColunas[i][TITLE], COURIER_NEW_08 )
   If ( i = 1 )
      oPrn:Box( nLinhas+ALTURA_LINHA  , aColunas[i][COL],;
                nLinhas+ALTURA_LINHA+1, aColunas[i][COL]+COL_FORN-20 )
   Else    
      oPrn:Box( nLinhas+ALTURA_LINHA  , aColunas[i][COL],;
                nLinhas+ALTURA_LINHA+1, aColunas[i][COL]+COLUNA-20 )
   EndIf
Next

SomaLinha(1.5)

Return ( NIL )


Function PoePict(valor,Pict)

If Pict != nil
   RETURN Str(Valor,15,0)
else
   RETURN TRANS(Valor,'@E 99,999,999')
Endif


//TRP - 02/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SA2"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICLO150",STR0018,"",{|oReport| ReportPrint(oReport)},STR0018)

oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Previsões de Caixa",aTabelas,aOrdem)

cAnoIni := STR(YEAR( CTOD('01/01/'+Right(cIni_MesAno,2)) ),4)
cAnoFim:=  STR(YEAR( CTOD('01/01/'+Right(cFim_MesAno,2)) ),4)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKFORN"            ,"Work"         ,STR0002                                     ,/*Picture*/                 ,27            ,/*lPixel*/,/*{|| code-block de impressao }*/)

If EICLOJA()
   TRCell():New(oSecao1,"WB_LOJA"            ,"Work"         ,"Loja"                                    ,/*Picture*/                 ,02            ,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif

// TDF - 08/08/2012 - Ajuste a impressão do relatório
//If Val(Left(cIni_MesAno,2)) <= 1
   TRCell():New(oSecao1,"WKMES01"        ,"Work"         ,STR0033+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf                                                                                                                           
//If Val(Left(cIni_MesAno,2)) <= 2
   TRCell():New(oSecao1,"WKMES02"        ,"Work"         ,STR0034+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 3
   TRCell():New(oSecao1,"WKMES03"        ,"Work"         ,STR0035+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 4
   TRCell():New(oSecao1,"WKMES04"        ,"Work"         ,STR0036+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 5
   TRCell():New(oSecao1,"WKMES05"        ,"Work"         ,STR0037+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 6
   TRCell():New(oSecao1,"WKMES06"        ,"Work"         ,STR0038+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 7
   TRCell():New(oSecao1,"WKMES07"        ,"Work"         ,STR0039+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 8
   TRCell():New(oSecao1,"WKMES08"        ,"Work"         ,STR0040+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 9
   TRCell():New(oSecao1,"WKMES09"        ,"Work"         ,STR0041+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 10
   TRCell():New(oSecao1,"WKMES10"        ,"Work"         ,STR0042+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 11
   TRCell():New(oSecao1,"WKMES11"        ,"Work"         ,STR0043+" "+cAnoIni                         ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
//If Val(Left(cIni_MesAno,2)) <= 12
   TRCell():New(oSecao1,"WKMES12"        ,"Work"         ,"..."+STR0044+"/"+cAnoFim                   ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf
TRCell():New(oSecao1,"WKTOTAL"           ,"Work"         ,STR0015                                     ,"@E 99,999,999"             ,12            ,/*lPixel*/,/*{|| code-block de impressao }*/) 


oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Total")

oTotal:= TRFunction():New(oSecao1:Cell("WKMES01"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES01 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES02"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES02 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES03"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES03 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES04"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES04 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES05"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES05 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES06"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES06 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES07"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES07 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES08"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES08 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES09"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES09 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES10"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES10 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES11"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES11 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKMES12"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKMES12 },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("WKTOTAL"),NIL,"SUM",/*oBreak*/,"","@E 99,999,999",{|| Work->WKTOTAL },.T.,.F.)
oTotal:SetTotalInLine(.F.)


//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.) TLM 07/11/07 - Nenhum pergunte está sendo passado no TReport 

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Previsões de Caixa"),"SA2",1,{|| xFilial("SA2") + SA2->A2_COD})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Previsões de Caixa"):Init()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Previsões de Caixa"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Previsões de Caixa"):Finish() 

Return .T. 

*---------------------------------------------------------------------------
* FIM DO PROGRAMA EICLO150.PRW
*--------------------------------------------------------------------------- 
