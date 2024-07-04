#INCLUDE "Eicgi600.ch" 
#include "AVERAGE.CH"
//#include "FiveWin.ch"                                               
#COMMAND E_RESET_AREA => SW5->(DBSETORDER(1)) ; SW3->(DBSETORDER(1)) ;
                       ; SA5->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ;
                       ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICGI600 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 02.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Follow-up Fase GI                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICGI600()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// EOS - OS 626/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICGI600
// um parametro como .T. identificando que é schedulado 
*--------------------------*
FUNCTION EICGI600S()
*--------------------------*
E_Init()
EICGI600(.T.)
RETURN NIL

Function EICGI600(lSXD)

EICGI600R3(lSXD,.T.)
Return .t.
*--------------------------*
Function EICGI600R3(lSXD,p_R4)
*--------------------------*
LOCAL   nOldArea  := Select()
PRIVATE cCadastro, MFlag_Fase, lEMail:=!lSXD = Nil
//Local oReport
//Local aArea := GetArea()
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

If Pergunte(IF(!lEmail,"EIG600","EIG601"), IF(!lEmail,.T.,.F.))
   Return GI600Main()
Endif
DbSelectArea(nOldArea)
RETURN NIL 

*----------------------------------------------------------------------------
FUNCTION GI600Main()
*----------------------------------------------------------------------------
LOCAL nPos := 0                    
Local oDlg //RRV - 05/12/2012
PRIVATE WorkFile, nOldArea:=SELECT()
PRIVATE _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC")[5]),ALLTRIM(EasyGParam("MV_LITRCC")))
PRIVATE _PictItem := ALLTRIM(X3PICTURE("B1_COD")) , _PictPGI := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
PRIVATE _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
PRIVATE cSaveMenuh, nCnt, cTitulo, oGet, nOpcA:=0, bMsg, TPO_NUM:=SW5->W5_PO_NUM,T_PROC:=SPACE(17)

PRIVATE  aDados :={"Work",;
                STR0021,; //"Emissao dos itens com Follow-up de Embarque"
                "",;
                "",;
                "G",;
                132,;
                "",;
                "",;
                STR0022,; //"Follow-up de Embarque"
                { STR0023, 1,STR0024, 1, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICGI600",;
                { {|| .T. } , {|| .T. }  }  }

PRIVATE  aRCampos:={}
PRIVATE lMostra := .T.
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
PRIVATE aDBF_Stru:= {;
                   {"WKFLAG","L",01,0},{"WKFLAGWIN","C",AVSX3("W2_OK",3),0},; //SO.:0026 OS.: 0230/02 FCD
                   {"WKCOD_I"   ,"C",AVSX3("W5_COD_I",AV_TAMANHO),0}  ,;                  
                   {"WKDESCR","C",36,0},{"WKFABR" ,"C",AVSX3("W5_FABR",3),0},;//SO.:0026 OS.: 0230/02 FCD
                   {"WKNOME_FAB","C",15,0},{"WKFORN" ,"C",AVSX3("W5_FORN",3),0},;//SO.:0026 OS.: 0230/02 FCD
                   {"WKNOME_FOR","C",15,0},{"WKREG"  ,"N",AVSX3("W1_REG",3),0},;
                   {"WKFLUXO","C",1,0},;           
                   {"WKQTDE"   ,"N",AVSX3("W5_QTDE",3)   ,AVSX3("W5_QTDE",4)},;
                   {"WKPRECO"  ,"N",AVSX3("W5_PRECO",3 ) ,AVSX3("W5_PRECO",4)},;
                   {"WKSALDO_Q","N",AVSX3("W5_SALDO_Q",3),AVSX3("W5_SALDO_Q",4)},;
                   {"WKSALDO_O","N",AVSX3("W5_SALDO_Q",3),AVSX3("W5_SALDO_Q",4)},;
                   {"WKCC","C",AVSX3("W5_CC",3),0}       ,;
                   {"WKSI_NUM","C",AVSX3("W5_SI_NUM",AV_TAMANHO),0}     ,; //SO.:0026 OS.: 0230/02 FCD
                   {"WKPO_NUM","C",AvSx3("W2_PO_NUM",AV_TAMANHO),0}  , {"WKDT_EMB","D",8,0}     ,;
                   {"WKDT_ENTR","D",8,0}  , {"WKDTENTR_S","D",8,0}   ,;
                   {"WKNBM","C",10,0}     , {"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0}   ,;//AWR 11/02/99
                   {"WKPESO_L","N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)},;
                   {"WKPGI_NUM","C",AVSX3("W5_PGI_NUM",AV_TAMANHO),0},;
                   {"WK_HAWB","C",AVSX3("W5_HAWB",AV_TAMANHO),0}     ,;
                   {"WKDOCTO","C",15,0}   , ;
                   {"WK_SEQ","N",2,0}     , ;
                   {"WKDEF_REQ","C",1,0}    ,;
                   {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} }
                                         
PRIVATE TB_Campos:={}
      aAdd(TB_Campos,{"WKFLAGWIN"  ,"","     "            })
      aAdd(TB_Campos,{"WKCC"       ,"", _LIT_R_CC         })
      aAdd(TB_Campos,{"WKSI_NUM"   ,"", STR0003,_PictSI   }) //"N§ S.I."
      aAdd(TB_Campos,{"WKPOSICAO"  ,"", STR0004           })//AWR 11/02/99 //"Posicao"
      aAdd(TB_Campos,{"WKCOD_I"    ,"", STR0005,_PictItem }) //"Item"
      aAdd(TB_Campos,{"WKDT_EMB"   ,"", STR0006           }) //"Embarque"
      aAdd(TB_Campos,{"WKDT_ENTR"  ,"", STR0007           }) //"Entrega"
      aAdd(TB_Campos,{"WKDOCTO"    ,"", STR0008           }) //"Documento"
      aAdd(TB_Campos,{"WKQTDE"     ,"", STR0009,_PictQtde }) //"Qtde Original"
      aAdd(TB_Campos,{"WKSALDO_Q"  ,"", STR0010,_PictQtde }) //"Saldo Qtde"
      
      //*** GFP 16/07/2011 - Ajuste de relatorio
      If EICLOJA()
         aAdd(TB_Campos,{ {||Alltrim(Work->WKFABR)+"/"+Work->WKFABLOJ+"/"+Work->WKNOME_FAB}     ,"", STR0012  }) //"Fabricante"
      Else
         aAdd(TB_Campos,{ {||Alltrim(Work->WKFABR)+"/"+Work->WKNOME_FAB}     ,"", STR0012               }) //"Fabricante"
      EndIf
      
      If EICLOJA()
         aAdd(TB_Campos,{ {||Alltrim(Work->WKFORN)+"/"+Work->WKFORLOJ+"/"+Work->WKNOME_FOR}   ,"", STR0014     }) //"Fornecedor"
      Else
         aAdd(TB_Campos,{ {||Alltrim(Work->WKFORN)+"/"+Work->WKNOME_FOR}   ,"", STR0014                  }) //"Fornecedor"   
      EndIf
      
      //*** Fim GFP 16/07/2011
         
      aAdd(TB_Campos,{"WKPART_N"   ,"", STR0015           }) //"Part Number"
      aAdd(TB_Campos,{{||IF(LEFT(Work->WKPGI_NUM,1)='*','',TRANS(Work->WKPGI_NUM,_PictPGI))},"", STR0016}) //"N§ P.L.I."
      aAdd(TB_Campos,{"WK_HAWB"    ,"", STR0017           }) //"Processo"
      aAdd(TB_Campos,{{||IF(Work->WKDEF_REQ="S",STR0018,STR0019)},"",STR0020}) //"Sim"###"Nao"###"Ag. Def."



IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"ESTRU_WORK"),) 

PRIVATE cPictPeso:= ALLTRIM(X3Picture("B1_PESO"))
PRIVATE cMarca := ""/*GetMark(,"Work","WKFLAGWIN")*/, lInverte := .F.  //LGS-06/03/2015 //SO.:0026 OS.:0230/02
Private aHeader[0],nUsado:=0
Private aFlwButtons:= {}

//Adiciona na estrutura do aDBF_Stru
If EICLOJA() .And. (nPos := aScan(aDBF_Stru, {|x| x[1] == "WKFABR" })) > 0
   aAdd(aDBF_Stru, Nil)
   aIns(aDBF_Stru, nPos + 1)
   aDBF_Stru[nPos+1] := {"WKFABLOJ", "C", AvSx3("W5_FABLOJ", AV_TAMANHO),0}
EndIf

If EICLOJA() .And. (nPos := aScan(aDBF_Stru, {|x| x[1] == "WKFORN" })) > 0
   aAdd(aDBF_Stru, Nil)
   aIns(aDBF_Stru, nPos + 1)
   aDBF_Stru[nPos+1] := {"WKFORLOJ", "C", AvSx3("W5_FORLOJ", AV_TAMANHO),0}
EndIf 

bCampo  := {|nCPO| Field(nCPO) }

WorkFile := E_CriaTrab(,aDBF_Stru,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

If EICLoja()
   IndRegua("Work",WorkFile+TEOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFABLOJ+WKFORN+WKFORLOJ+STR(WKREG,"+Alltrim(Str(AVSX3("W1_REG",3)))+",0)")
Else
   IndRegua("Work",WorkFile+TEOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Alltrim(Str(AVSX3("W1_REG",3)))+",0)")
EndIf
aRCampos:=E_CriaRCampos(TB_Campos,,2)

cMarca := GetMark(,"Work","WKFLAGWIN") //LGS-06/03/2015


SW2->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SA5->(DBSETORDER(3))

IF !lEmail
   bMsg:={|msg| MsProcTxt(msg)}
ENDIF   

IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"INIT_VAR"),)


/* wfs - 03/07/2017
           Identidade visual */
// EJA - 22/09/2017 - Adicionar botões fora do laço
AAdd(aFlwButtons, {"", {|| (GI600Marca(),oMark:oBrowse:Refresh())}, STR0059 + "/" + STR0058 + " " + STR0071}) //Marcar/Desmarcar Todos
AAdd(aFlwButtons, {"", {|| (nOpca:=1,Gi600_Alt())}, STR0028}) //Altera Data
AAdd(aFlwButtons, {"", {|| (nOpca:=2,If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),GI600Rel(aDados,aRCampos)))}, STR0072}) //"Imprimir"

WHILE .T.
  IF !lEmail
     IF !GI600GetPO(@TPO_NUM)
        E_RESET_AREA
        RETURN .F.
     ENDIF
  ELSE 
     aReturn   := aDados[10]
     aDados[11]:= SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
     TPO_NUM := MV_PAR02
  ENDIF
  
  cCadastro := IF( mv_par01==1, STR0001, STR0002 )
  MFlag_Fase:= IF( mv_par01==1, "G", "D")
  
  Work->(avzap())

  cTitulo:=""
  IF !lEmail
     MsAguarde({||GI600Work(bMsg,TPO_NUM)},STR0026) //"Pesquisando informações..."
  ELSE
     GI600Work(bMsg,TPO_NUM)
     IF Work->(Easyreccount("Work")) > 0
        E_Report(aDados,aRCampos,,.F.)     
     ENDIF 
     EXIT       
  ENDIF

  IF Work->(Easyreccount("Work")) > 0
     DO WHILE .T.
        
        nOpca:= 0
        oMainWnd:ReadClientCoors()
        DEFINE MSDIALOG oDlg TITLE cCadastro;               
               FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM; //FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ; wfs 23/07/2017 - ajuste de tela
        	           OF oMainWnd PIXEL  
            @00,00 MsPanel oPanel Prompt "" Size 60,18 of oDlg  //LRL 02/04/04 - Paninel para Alinhamento MDI.
         
         
            IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"COND_MOSTRA_PO"),)           
          
            IF lMostra := .T.
               @05,6  SAY STR0027 SIZE 32,8 of oPanel PIXEL //"No P.O.:"
               @04,40 MSGET TPO_NUM  SIZE 65,8  WHEN .F. of oPanel PIXEL
            Endif
          
            IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"COND_COLUNA"),) 
          
            oMark:= MsSelect():New("Work","WKFLAGWIN",,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
	   	  
            IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"COND_REFRESH"),) 
          
            //@2,(oDlg:nClientWidth-4)/2-110 BUTTON STR0071 SIZE 34,11 ACTION (GI600Marca(),oMark:oBrowse:Refresh())       OF oPanel PIXEL //"&Todos" //comentado por wfs 03/07/2017 - identidade visual
            //@2,(oDlg:nClientWidth-4)/2-070 BUTTON STR0028 SIZE 34,11 ACTION (nOpca:=1,Gi600_Alt())                       OF oPanel PIXEL //"&Altera Data" //comentado por wfs 03/07/2017 - identidade visual
          
            //DEFINE SBUTTON FROM 2,(oDlg:nClientWidth-4)/2-30 TYPE 6  ACTION (nOpca:=2,If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),GI600Rel(aDados,aRCampos))) ENABLE  OF oPanel //comentado por wfs 03/07/2017 - identidade visual
          
		      oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		  
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
                                    {||nOpca:=0,oDlg:End()},;//{||If(GI600Grava(),oDlg:End(),)},;
                                    {||nOpca:=0,oDlg:End()},,aFlwButtons))//LRL 02/04/04 -Alinhamento MDI       //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                     
        If nOpca == 0
           EXIT
        Endif
     enddo
  ELSE
     Help("", 1, "AVG0003063",,IF(MFlag_Fase = "G", STR0031,STR0032),2,1)//"P.O. não possui Itens na fase de "Guia"###"Desembaraço"###"Atenção"
  ENDIF

ENDDO

RETURN NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GI600Work ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 02.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GI600Work()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION GI600Work(bMsg,TPO_NUM)
*----------------------------------------------------------------------------
LOCAL lTem_LI := .F.//FDR - 02/02/13
PRIVATE V_WORK:=.F.
IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRAVA_WORK"),) 
IF V_WORK==.T.
	RETURN .T.
ENDIF

PRIVATE cFilialAtu:=xFilial("SW6"), cFilSW5:=xFilial("SW5"), cFilSW3:=xFilial("SW3")
GI600GrvWk(TPO_NUM) //LGS-04/07/2016
//SW5->(DBSETORDER(3))
//FDR - 02/03/13   
/*IF SW5->(DBSEEK(cFilSW5+TPO_NUM))
   lTem_LI := .T.
   GI600GrvWk(TPO_NUM, lTem_LI)
ELSE
   GI600GrvWk(TPO_NUM, lTem_LI)
ENDIF*/

DBSELECTAREA("Work")
DBGOTOP()
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION Gi600_Alt()
*----------------------------------------------------------------------------
LOCAL cTitulo:=STR0035, /*oDlg,*/ nOpcA:=0, lValid:=.T. //"Altera‡ao de Datas"
LOCAL nL1, nL2, nL3, nL4, nL5, nL6, nL7:=15, nL8, nL9, nL10:=19, nL11:=20,;
      nL12, nC0, nC1, nC2, nC3, nC4, nC5, nC6
LOCAL OldTela, nRec, aValid:={'Emb','Ent','Req'}
LOCAL bValid:={||lValid:=.T.,;
                 AEVAL(aValid,{|campo|If(lValid,lValid:=GI600Val(campo,,.T.),)}),;
                 lValid }
LOCAL cExecuta:="", nMarcados:=.F.
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))

PRIVATE TDef_Req, TDtEmbarque, TDtEntrega, TDocto, oDtEntrega
Private oDlg //ASK 29/08/2007 15:35 - Para uso em Ponto de Entrada.   
Private lMostraMem := .T. //GFP - 19/04/2012 - Para uso em Ponto de Entrada.

DBSELECTAREA("Work")
nRec:=RECNO()

Work->(DBGOTOP())
Work->(DBEVAL( {||IF(IsMark("WKFLAGWIN"),nMarcados:=.T.,)} ))

IF ! nMarcados
   Help("", 1, "AVG0003064")//"Não existem registros marcados p/ gravação"###"Informação"
   Work->(DBGOTO(nRec))
   RETURN .F.
ENDIF

DBGOTOP()  
If EICLoja()
   DBEVAL({||cExecuta:=WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFABLOJ+WKFORN+WKFORLOJ+STR(WKREG,AVSX3("W1_REG",3),0)},{||Work->WKFLAGWIN = cMarca},{||EMPTY(cExecuta)})
Else
   DBEVAL({||cExecuta:=WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,AVSX3("W1_REG",3),0)},{||Work->WKFLAGWIN = cMarca},{||EMPTY(cExecuta)})
EndIf
DBSEEK(cExecuta) //Para posicionar no primeiro marcado

IF EMPTY(cExecuta)
   Help("", 1, "AVG0003065")//"NÆo h  registros Marcados"###"Atenção"
   DBGOTO(nRec)
   RETURN NIL
ENDIF

DEFINE MSDIALOG oDlg TITLE cTitulo From 09,05 To 38,70 OF oMainWnd

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  

//*** GFP 16/07/2011 - Alteração de tamanho de tela.
// nL1:=18 ; nL2:=28 ; nL3:=39   ; nL4:=49   ; nL5:=59 ; nL6:=70 ; nL7:=80
// nL8:=96 ; nL9:=96 ; nL10:=109 ; nL11:=126 ; nL12:=143

   nL1:=8 ; nL2:=18 ; nL3:=29   ; nL4:=39   ; nL5:=49 ; nL6:=60 ; nL7:=70
   nL8:=86 ; nL9:=86 ; nL10:=99 ; nL11:=116 ; nL12:=133
   nC1:=6  ; nC2:=48 ; nC3:=96   ; nC4:=144  ; nC5:=184 ; nC6:=232

// @ 12,03 TO  91,250 OF oDlg PIXEL
   @ 2,03  TO  81,250 OF oDlg PIXEL
//*** Fim GFP 16/07/2011

   TDEF_REQ   := IF(EMPTY(WKDEF_REQ),"N",WKDEF_REQ)
   TDtEntrega := WKDT_ENTR
   TDtEmbarque:= WKDT_EMB
   TDocto     := WKDOCTO
   
   IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"DT_ENTREGA"),) // JBS - 15/07/2003

   @nL1,nC1  SAY STR0037               SIZE 60,08 OF oPanel PIXEL //"Cod. Item"
   @nL2,nC1  SAY STR0038               SIZE 60,08 OF oPanel PIXEL //"Descrição"
   @nL3,nC1  SAY STR0012               SIZE 60,08 OF oPanel PIXEL //"Fabricante"
   @nL4,nC1  SAY STR0014               SIZE 60,08 OF oPanel PIXEL //"Fornecedor"
   @nL5,nC1  SAY STR0010               SIZE 60,08 OF oPanel PIXEL //"Saldo Qtde"
   @nL5,nC4  SAY STR0039               SIZE 60,08 OF oPanel PIXEL //"Peso L¡quido"
   @nL6,nC1  SAY STR0040               SIZE 60,08 OF oPanel PIXEL //"FOB Unit rio"
   @nL7,nC1  SAY STR0041               SIZE 60,08 OF oPanel PIXEL //"FOB Total"

   @nL9,nC3  SAY STR0042               SIZE 60,08 OF oPanel PIXEL //"Atual"
   @nL9,nC4  SAY STR0043				    SIZE 60,08 OF oPanel PIXEL //"Follow-up"
   @nL10,nC1 SAY STR0044               SIZE 90,08 OF oPanel PIXEL //"Data Prevista de Embarque"
   @nL11,nC1 SAY STR0045               SIZE 65,08 OF oPanel PIXEL //"Data Prevista de Entrega"
   @nL12,nC1 SAY STR0008				    SIZE 60,08 OF oPanel PIXEL //"Documento"
   @nL12,nC4 SAY STR0046               SIZE 90,08 OF oPanel PIXEL //"Ag. Defini‡ao Requisitante ? (S/N)"

   @nL1,nC2  SAY TRAN(WKCOD_I,_PictItem)                         SIZE 150,07 OF oPanel PIXEL
   @nL2,nC2  SAY ALLTRIM(WKDESCR)                                SIZE 150,07 OF oPanel PIXEL
   
   //*** GFP 15/07/2011 :: 15h58
   @nL3,nC2  SAY WKFABR+" "+Alltrim(WKNOME_FAB)+If(EICLoja()," - "+WKFABLOJ,"")   SIZE 150,07 OF oPanel PIXEL
   @nL4,nC2  SAY WKFORN+" "+Alltrim(WKNOME_FOR)+If(EICLoja()," - "+WKFABLOJ,"")   SIZE 150,07 OF oPanel PIXEL
   //*** Fim GFP
   
   @nL5,nC2  SAY WKSALDO_Q PICTURE _PictQtde                     SIZE 040,07 OF oPanel PIXEL
   @nL5,nC5  SAY WKPESO_L  PICTURE cPictPeso                     SIZE 040,07 OF oPanel PIXEL
   @nL6,nC2  SAY WKPRECO             PICTURE _PictPrUn           SIZE 040,07 OF oPanel PIXEL
   @nL7,nC2  SAY WKSALDO_Q * WKPRECO PICTURE _PictPrUn           SIZE 040,06 OF oPanel PIXEL

   @nL10,nC3 SAY WKDT_EMB  SIZE 50,8 OF oPanel PIXEL
   @nL11,nC3 SAY WKDT_ENTR SIZE 50,8 OF oPanel PIXEL

   @nL10,nC4 MSGET TDtEmbarque VALID  GI600Val('Emb',TDtEntrega)  SIZE 60,10 OF oPanel PIXEL
   @nL11,nC4 MSGET oDtEntrega  Var TDtEntrega  VALID  GI600Val('Ent',TDtEmbarque) SIZE 60,10 OF oPanel PIXEL WHEN lMostraMem //GFP - 19/04/2012 - Inserido condição WHEN para que usuario customize a alteração do campo.
   @nL12,nC3 MSGET TDocto      VALID  GI600Val('Doc',TDocto)      SIZE 40,10 OF oPanel PIXEL
   @nL12,nC6 MSGET TDEF_REQ    PICTURE "@!"  VALID  GI600Val('Req') SIZE 10,8 OF oPanel PIXEL
   IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GET_VAL_TELA"),)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
         {|| nOpcA:=1,If(EVAL(bValid),oDlg:End(),)},;
         {|| nOpcA:=0, oDlg:End()}) CENTERED

If nOpcA = 1
   IF MsgYesNo(STR0064,STR0065) //"Confirma a gravação dos dados?"###"Gravação"
      Processa({||GI600Atu()} )
   ENDIF
Endif
Work->(DBGOTO(nRec))
oMark:oBrowse:Refresh()
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION GI600Atu()
*----------------------------------------------------------------------------
LOCAL nTot:=Work->(Easyreccount("Work")), MOcor //, nMarcados:=.F.
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
PRIVATE TDtPrvEntr

ProcRegua(nTot)

IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"ANTES_ATU_WORK"),) // JBS - 15/07/2003

Work->(DBGOTOP())
WHILE ! Work->(EOF())
   IncProc(STR0047+ALLTRIM(Work->WKCOD_I)) //"Gravando Item: "

   IF !IsMark("WKFLAGWIN")
      dbSkip();Loop
   Endif

   IF Work->WKDT_EMB <> TDtEmbarque
      MOcor:=  STR0048+ TRANS(Work->WKCOD_I,_PictItem) + ; //"F.U. EMBARQUE "
               STR0049 + DTOC(Work->WKDT_EMB) + ' P/ ' + DTOC(TDtEmbarque) //" DE "

      Grava_Ocor(Work->WKPO_NUM,dDataBase,MOcor)
   ENDIF

   IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRV_WORK"),) // JBS - 15/07/2003

   IF Work->WKDT_ENTR <> TDtEntrega
      MOcor:=  STR0050+ TRANSF(Work->WKCOD_I,_PictItem) + ; //"F.U. ENTREGA "
               STR0049 + DTOC(Work->WKDT_ENTR) + ' P/ ' + DTOC(TDtEntrega) //" DE "

      Grava_Ocor(Work->WKPO_NUM,dDataBase,MOcor)
   ENDIF

   DBSELECTAREA("Work")
   REPLACE Work->WKDT_EMB    WITH    TDtEmbarque ,;
           Work->WKDT_ENTR   WITH    TDtEntrega  ,;
           Work->WKDOCTO     WITH    TDocto      ,;
           Work->WKDEF_REQ   WITH    TDEF_REQ

    IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRV_TELA_WORK"),)
   Work->(DBSKIP())
ENDDO                  
GI600AtuDatas()
recalcFin() // EJA - 04/07/2019 - Ao alterar as datas, deve ser recriado contas a pagar no SIGAFIN.
RETURN .T.

Static Function recalcFin()
    If !EasyGParam("MV_AVG0170") .Or. SW2->W2_CONAPRO != "B"
      TPO_NUM := SW2->W2_PO_NUM
      Inclui := .F.
      EICFI400("ANT_GRV_PO","E")
      EICFI400("POS_GRV_PO","E")
    EndIf
Return

*---------------------------------------------------------------------------
FUNCTION GI600Val( PPar,dData,lOk )
*---------------------------------------------------------------------------
DEFAULT lOk := .F.
IF PPar = "Emb"
   IF EMPTY(TDtEmbarque)
      Help("", 1, "AVG0003066")//"Data de embarque não preenchida"###"Atenção"
      RETURN .F.
   ENDIF
   IF EasyEntryPoint("EICTGI01")
      EXECBLOCK("EICTGI01",.F.,.F.,"1")
   ENDIF   
   IF !lOk .AND. (EMPTY(TDtEntrega) .OR. TDtEmbarque <> Work->WKDT_EMB)
      SY9->(dbSetOrder(2))
      TDtEntrega:= TDtEmbarque + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+SW2->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
      SY9->(dbSetOrder(1))
   ENDIF             
        
   IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"RECALC_DT_ENTREGA"),)
ELSEIF PPar = "Ent"
   IF EMPTY(TDtEntrega)
      Help("", 1, "AVG0003067")//"Data de entrega não preenchida"###"Atenção"
      RETURN .F.
   ELSEIF TDtEntrega < IF(dData#NIL,dData,TDtEmbarque)
      Help("", 1, "AVG0003068")//"Data de entrega menor que a data de embarque "###"Atenção"
      RETURN .F.
   ENDIF
ENDIF

IF PPar = "Req"
   IF AT(TDef_Req,"SN") = 0
      Help("", 1, "AVG0003069")//'Definição do requisitante não pode ser diferenre de "S" OU "N" '###"Atenção"
      RETURN .F.
   ENDIF
ENDIF

RETURN .T.
*---------------------------------------------------------------------------
FUNCTION GI600Marca()
*---------------------------------------------------------------------------
LOCAL nOp, aOpcoes:={STR0056,STR0057}, Ind ,  nMarca, nRecno ,; //"1-Atual"###"2-Todos"
b_Grava:={||IF(nMarca,(Work->WKFLAG:=.T.,Work->WKFLAGWIN:=cMarca),;
                      (Work->WKFLAG:=.F.,Work->WKFLAGWIN:=SPACE(AVSX3("W2_OK",3))  ))} //SO.:0026/02 OS.:0230/02 FCD

//LOCAL cTitulo:=IF(Work->WKFLAG .OR. IsMark("WKFLAGWIN"),STR0058,STR0059) //"Desmarcar"###"Marcar"

//  DEFINE MSDIALOG oDlg TITLE cTitulo From 9,20 To 16,50 OF oMainWnd 

//  @  7,05 TO 45,70 OF oDlg PIXEL

//  @ 18,10 RADIO oRad VAR nOP ITEMS OemToAnsi(STR0060),; //"Item &Atual"
//                                   OemToAnsi(STR0061); //"&Todos os Ötens"
//  												         3D SIZE 49,12 PIXEL

//  DEFINE SBUTTON FROM 11,78 TYPE 1 ACTION (oDlg:End())        ENABLE OF oDlg
  
//  DEFINE SBUTTON FROM 27,78 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg

//  ACTIVATE MSDIALOG oDlg CENTERED

//IF nOP = 0
//   RETURN NIL
//ENDIF

nMarca:=IF(Work->WKFLAG .OR. IsMark("WKFLAGWIN"),.F.,.T.)

//IF nOp = 1
//   EVAL(b_Grava,1)
//ELSE
   nRecno:=Work->(RECNO())
   Work->(DBGOTOP())
   DBEVAL(b_Grava)
   Work->(DBGOTO(nRecno))
///ENDIF
RETURN .T.

*----------------------------------------------------------------------------
//FUNCTION GI600Grava()
*----------------------------------------------------------------------------
//LOCAL MSEQ, nRecno:=Work->(RECNO())//, nMarcados:=.F.

//Work->(DBGOTOP())
//Work->(DBEVAL( {||IF(IsMark("WKFLAGWIN"),nMarcados:=.T.,)} ))
//Work->(DBGOTO(nRecno))

//IF ! nMarcados
//   MsgInFo(STR0062,STR0063) //"Não existem registros marcados p/ gravação"###"Informação"
//   RETURN .F.
//ENDIF

//IF MsgYesNo(STR0064,STR0065) # .T. //"Confirma a gravação dos dados?"###"Gravação"
//   RETURN .F.
//ENDIF

//Processa({||GI600AtuDatas()} )
//GI600AtuDatas()

//Work->(DBGOTO(nRecno))
//RETURN .T.

*----------------------------------------------------------------------------
FUNCTION GI600AtuDatas()
*----------------------------------------------------------------------------
LOCAL nTot:=Work->(Easyreccount("Work")*2), nRec:=0, lValor

ProcRegua(nTot)

Work->(DBGOTOP())

WHILE ! Work->(EOF())

  IncProc(STR0047+ALLTRIM(Work->WKCOD_I)) //"Gravando Item: "

  IF Work->WKFLAGWIN <> cMarca
     Work->(DBSKIP()) ; LOOP
  ENDIF

  //PosO2_ItPedidos(Work->WKPGI_NUM,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I,Work->WKFABR,Work->WKFORN,Work->WKREG)
  
  SW3->(DBSETORDER(1))
  SW3->(DBSEEK(xFilial("SW3")+Work->WKPO_NUM))
  
  //DO WHILE .NOT. EOF() .AND. W3_PGI_NUM == Work->WKPGI_NUM .AND. W3_FILIAL == xFilial("SW3")
  DO WHILE .NOT. SW3->(EOF()) .AND. SW3->W3_PO_NUM == Work->WKPO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3")   
     IF SW3->W3_CC     <> Work->WKCC     .OR. SW3->W3_SI_NUM <> Work->WKSI_NUM .OR.;
        (SW3->W3_FABR  <> Work->WKFABR .AND. IIF(EICLoja(),SW3->W3_FABLOJ   <> Work->WKFABLOJ,.T.)) .OR.;
        (SW3->W3_FORN  <> Work->WKFORN .AND. IIF(EICLoja(),SW3->W3_FORLOJ   <> Work->WKFORLOJ,.T.)) .OR.;
        SW3->W3_REG    <> Work->WKREG    .OR. SW3->W3_PO_NUM <> Work->WKPO_NUM .OR.;
        SW3->W3_COD_I  <> Work->WKCOD_I

        SW3->(DBSKIP())  
        LOOP
     ENDIF
     RecLock("SW3",.F.)

     REPLACE SW3->W3_DT_EMB   WITH  Work->WKDT_EMB ,;
             SW3->W3_DT_ENTR  WITH  Work->WKDT_ENTR
     IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRV_WORK_SW3"),)
     SW3->(MsUnlock())

     IF EasyEntryPoint("IC023PO1")         
        EasyExRdm("U_IC023PO1","Int100Solic_W3", {.T.,.F.})       
     ENDIF

     SW3->(DBSKIP()) 
  ENDDO
  Work->(DBSKIP())
END

Work->(DBGOTOP())

WHILE ! Work->(EOF())

  IncProc(STR0047+ALLTRIM(Work->WKCOD_I)) //"Gravando Item: "

  IF Work->WKFLAGWIN <> cMarca
     Work->(DBSKIP()) ; LOOP
  ENDIF

  SW5->(DBSETORDER(3))
  SW5->(DBSEEK(xFilial("SW5")+Work->WKPO_NUM))

  IF MFlag_Fase = "G"
     MSEQ:=0
  ELSE
     MSEQ:=Work->WK_SEQ
  ENDIF
  DO WHILE .NOT. SW5->(EOF()) .AND. Work->WKPO_NUM == SW5->W5_PO_NUM ;
                              .AND. SW5->W5_FILIAL == xFilial("SW5")
     IF Work->WKCC      <> SW5->W5_CC       .OR. ;
        Work->WKSI_NUM  <> SW5->W5_SI_NUM   .OR. ;
        (Work->WKFABR   <> SW5->W5_FABR .AND. IIF(EICLoja(),Work->WKFABLOJ <> SW5->W5_FABLOJ,.T.)).OR.;
        (Work->WKFORN   <> SW5->W5_FORN .AND. IIF(EICLoja(),Work->WKFORLOJ <> SW5->W5_FORLOJ,.T.)).OR.;
        Work->WKREG     <> SW5->W5_REG      .OR. ;
        SW5->W5_SEQ     <> MSeq             .OR. ;
        SW5->W5_PGI_NUM <> Work->WKPGI_NUM  .OR. ;
        Work->WKCOD_I   <> SW5->W5_COD_I
        SW5->(DBSKIP())
        LOOP
     ENDIF
     RecLock("SW5",.F.)
     REPLACE SW5->W5_DT_EMB   WITH  Work->WKDT_EMB ,;
             SW5->W5_DT_ENTR  WITH  Work->WKDT_ENTR,;
             SW5->W5_DOCTO_FU WITH  Work->WKDOCTO  ,;
             SW5->W5_DEF_REQ  WITH  Work->WKDEF_REQ
     IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRV_WORK_SW5"),)
      SW5->(MsUnlock())
      SW5->(DBSKIP())
  END
  Work->(DBSKIP())
END

IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"POS_GRV_SW3_SW5"),)
Work->(DBGOTOP())
Work->(DBEVAL( {||Work->WKFLAGWIN:='  '} ))

DBSELECTAREA("Work")
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION GI600GetPO(TPO_NUM,cTitulo)
*----------------------------------------------------------------------------
LOCAL   oDlg, lValid:=.F., nOpca:= 0
PRIVATE cArqF3:="SW2", cCampoF3:="W2_PO_NUM"
IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"PONTO_08"),)
IF TPO_NUM = NIL .OR. EMPTY(TPO_NUM)
   TPO_NUM:=SW2->W2_PO_NUM
ENDIF

//cTitulo:=IF(cTitulo = NIL .and. mv_par01 == 1,"Follow-up fase embarque", "Follow-up fase despacho") //"Sele‡ao de P.O."
If cTitulo == NIL 
   If mv_par01 == 1
      cTitulo := "Follow-up fase embarque"
   Else
      cTitulo := "Follow-up fase despacho"
   EndIf
Else
   cTitulo := "Follow-up fase despacho"
EndIf 

IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"PONTO_TITULO"),)

/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 To 18,45 OF oMainWnd */
DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 To 15,50 OF oMainWnd //DEFINE MSDIALOG oDlg TITLE cTitulo From 15,10 To 30,50 OF oMainWnd //wfs 27/03/2017 - ajuste de tela
IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"PONTO_09"),)
  
  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 30, 50)
  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
  
  @ 18,6   SAY STR0067 SIZE 32,8 OF oPanel PIXEL //" N§ do P.O. "
  @ 18,48  MSGET TPO_NUM F3 cArqF3 SIZE 65,10 VALID (lValid:=GI600ValPO(TPO_NUM)) OF oPanel PIXEL

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,If(lValid .OR. GI600ValPO(TPO_NUM),oDlg:End(),)},;
                          {||nOpca:=0,oDlg:End()},,,,,,,.F.) CENTERED
Return (nOpca <> 0)

*----------------------------------------------------------------------------
FUNCTION GI600Rel(aDados,aRCampos)
*----------------------------------------------------------------------------
LOCAL lExecuta:=.F.

DBSELECTAREA("Work")
DBGOTOP()
DBEVAL({||lExecuta:=.T.},{||Work->WKFLAGWIN = cMarca},{||!lExecuta})
DBGOTOP()

IF lExecuta
   E_Report(aDados,aRCampos)
ELSE
   Help("", 1, "AVG0003070")//"NÆo h  registros a serem listados"###"Informação"
ENDIF

RETURN NIL                  
/*
Revisão: wfs 03/07/2017
Posicionamento das tabelas; validação do pedido digitado*/
*----------------------------------------------------------------------------
FUNCTION GI600ValPO(TPO_NUM)
*----------------------------------------------------------------------------
private V_VAL_PO:=.F.
IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"VERIFICA_VAL_PO"),)

If V_VAL_PO==.T.
     return .t.
endif	
SW2->(DBSetOrder(1)) //W2_FILIAL+W2_PO_NUM
SW3->(dbSetOrder(1)) //W3_FILIAL+W3_COD_I
SW5->(dbSetOrder(3)) //W5_FILIAL+W5_PO_NUM+W5_COD_I

/* comentado por wfs 03/07/2017
IF !SW3->(DBSEEK(xFilial()+TPO_NUM)) .AND. !SW5->(DBSEEK(xFilial()+TPO_NUM))
   Help("", 1, "AVG0003071")//"NÆo h  LI's para este pedido"###"Informação"	
   Return .F.
ENDIF*/
/*SW5->(dbSetOrder(3))
IF !SW5->(DBSEEK(xFilial()+TPO_NUM))
   Help("", 1, "AVG0003071")//"NÆo h  LI's para este pedido"###"Informação"	
   Return .F.
ENDIF*/

If !SW2->(DBSEEK(xFilial()+TPO_NUM))
   EasyHelp(STR0073, STR0066) //"O número do Purchase Order informado não foi encontrado. Informe um novo número."#"Seleção de P.O."
   Return .F.
EndIf
SW3->(DBSEEK(xFilial()+TPO_NUM))

If SW5->(DBSEEK(xFilial()+TPO_NUM))
   SW4->(DBSEEK(xFilial()+SW5->W5_PGI_NUM))
   IF SW4->W4_FLUXO = "5"//wfs o que é o fluxo 5? customização??
      MsgInfo(STR0070,STR0063) //"Fluxo igual 5 na P.L.I."###"Informação"
      Return .F.
   ENDIF
   SY9->(DBSEEK(xFilial()+SW4->W4_COD_DES))
EndIf
//SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
Return .T.

//TRP - 20/06/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW5","SA5","SB1"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICGI600",STR0022,"EIG600",{|oReport| ReportPrint(oReport)},STR0021)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Embarques",aTabelas,aOrdem)

//Códigos de bloco para impressão de campos calculados
bWKPGI_NUM := {||IF(LEFT(Work->WKPGI_NUM,1)='*','',(TRANS(Work->WKPGI_NUM,_PictPGI)))}      
bWKDEF_REQ := {||IF(Work->WKDEF_REQ="S",STR0018,STR0019)}

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKCC"         ,"Work",   _LIT_R_CC    ,/*Picture*/                       ,AVSX3("W5_CC",3)       ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKSI_NUM"     ,"Work",   STR0003      ,_PictSI                           ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPOSICAO "   ,"Work",   STR0004      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCOD_I"      ,"Work",   STR0005      ,_PictItem                         ,AVSX3("W5_COD_I",3)    ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_EMB"     ,"Work",   STR0006      ,/*Picture*/                       ,15 /*Tamanho*/         ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012
TRCell():New(oSecao1,"WKDT_ENTR"    ,"Work",   STR0007      ,/*Picture*/                       ,15 /*8*/               ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012
TRCell():New(oSecao1,"WKDOCTO"      ,"Work",   STR0008      ,/*Picture*/                       ,15                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKQTDE"       ,"Work",   STR0009      ,_PictQtde                         ,AVSX3("W5_QTDE",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKSALDO_Q"    ,"Work",   STR0010      ,_PictQtde                         ,AVSX3("W5_SALDO_Q",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKFABR"       ,"Work",   STR0011      ,/*Picture*/                       ,AVSX3("W5_FABR",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
If EICLoja()
   TRCell():New(oSecao1,"WKFABLOJ"       ,"Work",   "Loja Fabr."      ,/*Picture*/                       ,AVSX3("W5_FABLOJ",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oSecao1,"WKNOME_FAB"   ,"Work",   STR0012      ,/*Picture*/                       ,15                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKFORN "      ,"Work",   STR0013      ,/*Picture*/                       ,AVSX3("W5_FORN",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
If EICLoja()
   TRCell():New(oSecao1,"WKFORLOJ"       ,"Work",   "Loja Forn."      ,/*Picture*/                       ,AVSX3("W5_FORLOJ",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oSecao1,"WKNOME_FOR"   ,"Work",   STR0014      ,/*Picture*/                       ,15                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPART_N "    ,"Work",   STR0015      ,/*Picture*/                       ,20                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPGI_NUM"    ,"Work",   STR0016      ,/*Picture*/                       ,10                     ,/*lPixel*/,bWKPGI_NUM)
TRCell():New(oSecao1,"WK_HAWB"      ,"Work",   STR0017      ,/*Picture*/                       ,17                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDEF_REQ"    ,"Work",   STR0020      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,bWKDEF_REQ)
//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SW5",3,{|| xFilial("SW5") + Work->WKPO_NUM})

TRPosition():New(oReport:Section("Embarques"),"SA5",3,{|| xFilial("SA5") + SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN})

TRPosition():New(oReport:Section("Embarques"),"SB1",1,{|| xFilial("SB1") + Work->WKCOD_I})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Embarques"):Init()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Embarques"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Embarques"):Finish() 
Work->( dbGoTop() )

Return .T.

/*
Funcao     : GI600GrvWk()
Parametros : TPO_NUM - Numero do PO
             lTem_LI - .T. processo com LI / .F. processo sem LI
Retorno    : Lógico
Objetivos  : Gravar os dados do processo na Work para impressão do relatório
Autor      : Flavio D. Ricardo 
Data/Hora  : 02/03/2013 - 14:00hs
*/
*----------------------------------------------------------------------------
FUNCTION GI600GrvWk(TPO_NUM)
*----------------------------------------------------------------------------
Local lTem_LI := .F.
Local aOrd := SaveOrd({"SW3","SW5"})

SW3->(DbSetOrder(1)) //W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
SW3->(DbSeek(xFilial("SW3")+AvKey(TPO_NUM,"W3_PO_NUM")))

//LGS-04/07/2016 - Efetuado alteração para validar item a item do PO
Do While SW3->(!Eof()) .And. SW3->W3_FILIAL == cFilSW3 .And. SW3->W3_PO_NUM == AvKey(TPO_NUM,"W3_PO_NUM")
   SW5->(DbSetOrder(3))
   //lTem_LI := SW5->(DbSeek(xFilial("SW5")+SW3->W3_PO_NUM+SW3->W3_COD_I+AvKey(SW3->W3_SEQ,"W5_SEQ"))) //comentado por wfs 03/07/2017 - erro quando o mesmo produto está em mais de uma S.I., no mesmo P.O.
   lTem_LI:= .F.
   SW5->(DbSeek(xFilial("SW5")+SW3->W3_PO_NUM+SW3->W3_COD_I+AvKey(SW3->W3_SEQ,"W5_SEQ")))
   While SW5->(!Eof()) .And. SW5->W5_FILIAL == SW5->(xFilial()) .And.;
         SW5->W5_PO_NUM + SW5->W5_COD_I == SW3->W3_PO_NUM + SW3->W3_COD_I .And. SW5->W5_SEQ == SW3->W3_SEQ
      
      If SW5->W5_SI_NUM == SW3->W3_SI_NUM .And. SW5->W5_POSICAO == SW3->W3_POSICAO
         lTem_LI:= .T.
         Exit
      EndIf

      SW5->(DBSkip())
   EndDo
   
   If lTem_LI
      
      //SW5->(DbSetOrder(10))
      //SW5->(DbSeek(xFilial("SW5")+SW3->W3_PO_NUM+SW3->W3_COD_I+AvKey(SW3->W3_SEQ,"W5_SEQ")))
      
      IF !lEmail
         Eval(bMsg,STR0034+ALLTRIM(SW5->W5_COD_I)) //"Processando Item "
      ENDIF
      
      IF MFlag_Fase = "G"                       
         IF SW3->W3_SEQ <> 0 //WHRS TE-3944 497527/MTRADE-78 - Follow up de embarque duplicado
            SW3->(DBSKIP()) ; LOOP
         ENDIF

         IF SW5->W5_SALDO_Q <= 0 // JBS - 23/12/2004 16:57
            SW3->(DBSKIP()) ; LOOP
         ENDIF
      ELSE
         IF SW5->W5_SEQ = 0
            SW3->(DBSKIP()) ; LOOP
         ENDIF

         IF EMPTY(SW5->W5_HAWB)
            SW3->(DBSKIP()) ; LOOP
         ENDIF

         SW6->(DBSETORDER(1))
         IF ! SW6->(DBSEEK(cFilialAtu+SW5->W5_HAWB))
            SW3->(DBSKIP()) ; LOOP
         ELSEIF ! EMPTY(SW6->W6_DT_ENTR)
            SW3->(DBSKIP()) ; LOOP
         ENDIF
      ENDIF

      //SA5->(DBSEEK(xFilial()+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
      EICSFabFor(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))

      Work->(DBAPPEND())
      Work->WKCOD_I    :=  SW5->W5_COD_I
      Work->WKFABR     :=  SW5->W5_FABR
      Work->WKNOME_FAB :=  BuscaFabr_Forn(SW5->W5_FABR+EICRetLoja("SW5","W5_FABLOJ"))
      Work->WKPRECO    :=  SW5->W5_PRECO
      Work->WKFLUXO    :=  SW5->W5_FLUXO
      Work->WKQTDE     :=  SW5->W5_QTDE
      Work->WKSALDO_Q  :=  SW5->W5_SALDO_Q
      Work->WKSI_NUM   :=  SW5->W5_SI_NUM
      Work->WKPO_NUM   :=  SW5->W5_PO_NUM
      Work->WKCC       :=  SW5->W5_CC
      Work->WKDT_ENTR  :=  SW5->W5_DT_ENTR
      Work->WKDT_EMB   :=  SW5->W5_DT_EMB
      Work->WKREG      :=  SW5->W5_REG
      Work->WKPGI_NUM  :=  SW5->W5_PGI_NUM //AWR 05/10/98 Para executar o Seek certo
      Work->WKDOCTO    :=  SW5->W5_DOCTO_FU
      Work->WK_HAWB    :=  SW5->W5_HAWB
      Work->WK_SEQ     :=  SW5->W5_SEQ
      Work->WKDEF_REQ  :=  SW5->W5_DEF_REQ
      //Work->WKPART_N   :=  SA5->A5_CODPRF
      Work->WKFORN     :=  SW5->W5_FORN
      Work->WKNOME_FOR :=  BuscaFabr_Forn(SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ"))
      Work->WKPOSICAO  :=  SW5->W5_POSICAO //AWR 11/02/99
      Work->WKNBM := Busca_NCM("SW5" ,"NCM")
      
      If EICLoja()
         Work->WKFABLOJ:= SW5->W5_FABLOJ
         Work->WKFORLOJ:= SW5->W5_FORLOJ
      EndIf
                                      
      If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 08/10/2007
         //SW3->(DbSetOrder(8))
         //SW3->(DbSeek(xFilial("SW3") + SW5->W5_PO_NUM + SW5->W5_POSICAO ))
         If !Empty(SW3->W3_PART_N)
            Work->WKPART_N := SW3->W3_PART_N
         Else                            
            Work->WKPART_N := SA5->A5_CODPRF
         EndIf
      Else   
         Work->WKPART_N := SA5->A5_CODPRF
      EndIf      

      E_ItFabFor() // posiciona SB1 atualiza descricao do item p/ gi, nome
               // reduzido do fabricante e do fornecedor
      IF !FINDFUNCTION("B1PESO")  //LDR
         Work->WKPESO_L := If(SW5->W5_PESO==0,SB1->B1_PESO,SW5->W5_PESO) //FCD 04/07/2001
      ELSE
         Work->WKPESO_L := If(SW5->W5_PESO==0,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) // RA - 11/11/2003 - O.S. 1193/03
      ENDIF
      Work->WKDESCR :=  MSMM( SB1->B1_DESC_GI,36,1 )

      IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"WORK"),)

      IF(EasyEntryPoint("EICGI600"),ExecBlock("EICGI600",.F.,.F.,"GRV_SW5_WORK"),)
      //SW3->(DbSkip())            
   Else
      IF !lEmail
         Eval(bMsg,STR0034+ALLTRIM(SW3->W3_COD_I)) //"Processando Item "
      ENDIF

      IF MFlag_Fase = "G"
         IF SW3->W3_SEQ <> 0
            SW3->(DBSKIP()) ; LOOP
         ENDIF

         IF SW3->W3_SALDO_Q <= 0 // JBS - 23/12/2004 16:57
            SW3->(DBSKIP()) ; LOOP
         ENDIF
      ELSE
         IF SW3->W3_SEQ = 0
            SW3->(DBSKIP()) ; LOOP
         ENDIF
      ENDIF

      //SA5->(DBSEEK(xFilial()+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
      EICSFabFor(xFilial("SA3")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))

      Work->(DBAPPEND())
      Work->WKCOD_I    :=  SW3->W3_COD_I
      Work->WKFABR     :=  SW3->W3_FABR
      Work->WKNOME_FAB :=  BuscaFabr_Forn(SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ"))
      Work->WKPRECO    :=  SW3->W3_PRECO
      Work->WKFLUXO    :=  SW3->W3_FLUXO
      Work->WKQTDE     :=  SW3->W3_QTDE
      Work->WKSALDO_Q  :=  SW3->W3_SALDO_Q
      Work->WKSI_NUM   :=  SW3->W3_SI_NUM
      Work->WKPO_NUM   :=  SW3->W3_PO_NUM
      Work->WKCC       :=  SW3->W3_CC
      Work->WKDT_ENTR  :=  SW3->W3_DT_ENTR
      Work->WKDT_EMB   :=  SW3->W3_DT_EMB
      Work->WKREG      :=  SW3->W3_REG
      Work->WKPGI_NUM  :=  SW3->W3_PGI_NUM //AWR 05/10/98 Para executar o Seek certo
      Work->WK_SEQ     :=  SW3->W3_SEQ
   // Work->WKPART_N   :=  SA5->A5_CODPRF
      Work->WKFORN     :=  SW3->W3_FORN
      Work->WKNOME_FOR :=  BuscaFabr_Forn(SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ"))
      Work->WKPOSICAO  :=  SW3->W3_POSICAO //AWR 11/02/99
      Work->WKNBM := Busca_NCM("SW3" ,"NCM")
   
      If EICLoja()
         Work->WKFABLOJ:= SW3->W3_FABLOJ
         Work->WKFORLOJ:= SW3->W3_FORLOJ
      EndIf
                                      
      If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 08/10/2007
         If !Empty(SW3->W3_PART_N)
            Work->WKPART_N := SW3->W3_PART_N
         Else                            
            Work->WKPART_N := SA5->A5_CODPRF
         EndIf
      Else   
         Work->WKPART_N := SA5->A5_CODPRF
      EndIf                    
   
      E_ItFabFor() // posiciona SB1 atualiza descricao do item p/ gi, nome
               // reduzido do fabricante e do fornecedor

      IF SW3->(FieldPos("W3_PESOL")) # 0
         IF !FINDFUNCTION("B1PESO")  //LDR
            Work->WKPESO_L := If(SW3->W3_PESOL==0,SB1->B1_PESO,SW3->W3_PESOL) //FCD 04/07/2001
         ELSE
            Work->WKPESO_L := If(SW3->W3_PESOL==0,B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")),SW3->W3_PESOL) // RA - 11/11/2003 - O.S. 1193/03
         ENDIF
         Work->WKDESCR :=  MSMM( SB1->B1_DESC_GI,36,1 )
      ENDIF   
      //SW3->(DbSkip())   
   EndIf
   
   SW3->(DbSkip())  
EndDo
RestOrd(aOrd,.T.)
Return .T.