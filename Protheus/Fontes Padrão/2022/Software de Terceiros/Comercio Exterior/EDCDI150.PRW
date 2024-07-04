#INCLUDE "EDCDI150.ch"
#INCLUDE "AVERAGE.CH"

/*
Funcao      : EDCDI150.PRW
Parametros  : 
Retorno     : 
Objetivos   : Gerar Carta informando as DI utilizadas em outros Processos
Autor       : Sandra Yuriko
Data/Hora   : 12/12/2002
Revisao     : Gustavo Carreiro - 21/08/03
Obs.        : 3M - Drawback
*/

#define ENTER CHR(13)+CHR(10)
#define TAM 80

*-----------------------*
Function EDCDI150()
*-----------------------*
Local lRet := .F., aGrv:={}, i
Local aOrd := SaveOrd({"ED0","ED1","ED2"})
Local nAlias := Select(),cHawb:="", cRpt:= "EDCDI150.RPT", cDI:=""

Private cPedDraw:=Space(13),cMemo:="", cPictDi:= "@R 99/9999999-9"
Private cPictAC:="@R 9999-99/999999-9", cPictPd:= AVSX3("ED2_PD",6)

If Select("HEADER_P") = 0

   E_ARQCRW(.T.,,.T.)

EndIf

Begin Sequence
   
   // *** Cria Arquivo de Trabalho ...
   aFields := {{"WKPD"    ,"C",AVSX3("ED2_PD"    ,3),0},;
               {"WKDI"    ,"C",AVSX3("ED2_DI_NUM",3),0},;
               {"WKHAWB"  ,"C",AVSX3("ED2_HAWB"  ,3),0},;
               {"WKADICAO","C",AVSX3("ED2_ADICAO",3),0},;
               {"WKAC"    ,"C",AVSX3("ED2_AC"    ,3),0},;
               {"WKITEM"  ,"C",AVSX3("ED2_ITEM"  ,3),0},;
               {"WKPO"    ,"C",AVSX3("ED2_PO_NUM",3),0},;
               {"WKPGI"   ,"C",AVSX3("ED2_PGI_NU",3),0},;
               {"WKINVOIC","C",AVSX3("ED2_INVOIC",3),0},;
               {"WKPOSICA","C",AVSX3("ED2_POSICA",3),0}}
            
   cFile := E_CriaTrab(,aFields,"Work")
   IndRegua("Work",cFile+TEOrdBagExt(),"WKPD+WKHAWB")
   
   //rotina principal
   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()
   
   IF !TelaGets()
      lRet := .F.
      Break
   Endif

   //PLB 31/01/06 - Verifica Cidade do Importador
   ED0->( DBSetOrder(1) )
   ED0->( DBSeek(xFilial("ED0")+cPedDraw) )
   SYT->( DBSetOrder(1) )
   SYT->( DBSeek(xFilial("SYT")+ED0->ED0_IMPORT) )

   cMemo := Replicate(ENTER,3)
   cMemo := cMemo + AllTrim(SYT->YT_CIDADE) +", "+Str(Day(dDataBase),2)+STR0001+Upper(MesExtenso(Month(dDataBase)))+STR0001+Str(Year(dDataBase),4)+ENTER //" DE "
   cMemo := cMemo + ENTER + ENTER
   cMemo := cMemo + STR0002 + ENTER //"Ao Banco do Brasil S.A."
   cMemo := cMemo + STR0003 + ENTER //"SECEX"
   cMemo := cMemo + ENTER + ENTER
   cMemo := cMemo + STR0004 + ENTER //"Prezados Senhores,"
   cMemo := cMemo + ENTER+ ENTER
   cMemo := cMemo + STR0005+ENTER //"Vimos através desta informar que as declarações de Importação, abaixo"
   cMemo := cMemo + STR0006+ENTER //"relacionadas, foram parcialmente utilizadas em outros Atos Concessórios. "
   cMemo := cMemo + STR0007+ENTER //"Portanto, solicitamos especial autorização para utilizarmos o saldo "
   cMemo := cMemo + STR0008+ENTER //"remanescente neste novo pleito."
   cMemo := cMemo + ENTER
   
   ED2->(DbSetOrder(1))
   ED2->(DbSeek(xFilial("ED2")+cPedDraw))
   Do While ED2->(!Eof()) .And. xFilial("ED2") == ED2->ED2_FILIAL .and. cPedDraw == ED2->ED2_PD
      If !Empty(ED2->ED2_DI_NUM) .and. aScan(aGrv,{|x| x[1]==ED2->ED2_PD .and. x[2]==ED2->ED2_DI_NUM .and. x[3]==ED2->ED2_PO_NUM .and.;
      x[4]==ED2->ED2_PGI_NU .and. x[5]==ED2->ED2_POSICA}) = 0
         Work->(dbAppend())
         Work->WKPD    := ED2->ED2_PD
         Work->WKDI    := ED2->ED2_DI_NUM
         Work->WKHAWB  := ED2->ED2_HAWB
         Work->WKAC    := ED2->ED2_AC
         Work->WKADICAO:= ED2->ED2_ADICAO
         Work->WKITEM  := ED2->ED2_ITEM
         Work->WKPO    := ED2->ED2_PO_NUM
         Work->WKPGI   := ED2->ED2_PGI_NU
         Work->WKINVOIC:= ED2->ED2_INVOIC
         Work->WKPOSICA:= ED2->ED2_POSICA
         aAdd(aGrv,{ED2->ED2_PD,ED2->ED2_DI_NUM,ED2->ED2_PO_NUM,ED2->ED2_PGI_NU,ED2->ED2_POSICA})
      EndIf
      ED2->(DbSkip())
   EndDo
   aGrv:={}
   Work->(DbGotop())

   IF Work->(EasyRecCount()) <> 0
      Processa({||GrvMemo() } ,STR0014) //"Gerando Dados da Carta"
   
   
      cMemo := Left(cMemo,Len(cMemo)-2)                          	
      cMemo := cMemo + ENTER + ENTER
      cMemo := cMemo + STR0009 //"Atenciosamente"
   
   Else    
      Help(" ",1,"AVG0005190") //MsgInfo(STR0019) //"Nao Ha Dados para Impressao !!!"
      Break
   Endif
      
   IF !TelaGets1()
      lRet := .F.
      Break
   Endif
   
   For i:=1 To MlCount(cMemo)
       DETAIL_P->(DbAppend())
       DETAIL_P->AVG_C01120 := MemoLine(cMemo,TAM,i)
   Next i

   IF !(lRet := AvgCrw32(cRpt,"Carta",cSeqRel))
      Break
   Endif
End Sequence
Work->(E_EraseArq(cFile))
Select(nAlias)
RestOrd(aOrd)

Return(lRet)

*-------------------------------------------------------------------------------------------------*
Static Function Telagets()
*-------------------------------------------------------------------------------------------------*

Local lRet := .F.,oDlg,nOpc
Local bOk     := {||nOpc:=1,oDlg:End()}
Local bCancel := {||nOpc:=0,oDlg:End()}

Begin Sequence
   //AOM - 25/07/11 - Reajusto no tamanho da tela 11.5
   DEFINE MSDIALOG oDlg TITLE STR0010 FROM 7,10 TO 20,60 OF oMainWnd //"Carta com DI duplicado"
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 20,05 SAY STR0011 SIZE 100,08 OF oPanel PIXEL //"Informe o Pedido:"
      @ 20,60 MSGET cPedDraw F3 "E30" SIZE 80,08 Valid(ExistCpo("ED0")) of oPanel PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOk,bCancel))

   IF nOpc == 0 .Or. nOpc == Nil
      Break
   Endif

   lRet := .T.
      
End Sequence

Return lRet

*-------------------------------------------------------------------------------------------------*
Static Function Telagets1()
*-------------------------------------------------------------------------------------------------*

Local lRet := .F.,oDlg,nOpc
Local bOk     := {||nOpc:=1,oDlg:End()}
Local bCancel := {||nOpc:=0,oDlg:End()}

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE STR0012 FROM 7,10 TO 35,80 OF oMainWnd //"Carta"

      @ 15,05 GET cMemo MEMO SIZE 270,195 OF oDlg PIXEL HSCROLL

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOk,bCancel))

   IF nOpc == 0 .Or. nOpc == Nil
      Break
   Endif

   lRet := .T.

End Sequence

Return lRet

*----------------------------------------------------------------------------------------------*
Static Function GrvMemo()
*----------------------------------------------------------------------------------------------*
Local aUso:={}

ProcRegua(Work->(EasyRecCount()))

ED2->(dbSetOrder(7))
Do While Work->(!Eof())
   IncProc(STR0013+Alltrim(Work->WKDI)) //"Lendo DI nro.: "
   ED2->(DbSeek(xFilial("ED2")+Work->WKDI+Work->WKITEM))
   Do While !ED2->(Eof()) .and. xFilial("ED2")==ED2->ED2_FILIAL .and. Work->WKDI==ED2->ED2_DI_NUM .and. Work->WKITEM==ED2->ED2_ITEM
      /*If Work->WKPD = ED2->ED2_PD
         ED2->(DbSkip())
         Loop
      EndIf*/
      If Work->WKPD <> ED2->ED2_PD .and. Work->WKADICAO == ED2->ED2_ADICAO .and. Work->WKINVOIC==ED2->ED2_INVOIC .and.;
      Work->WKPO==ED2->ED2_PO_NUM .and. Work->WKPOSICA==ED2->ED2_POSICA .and. Work->WKPGI==ED2->ED2_PGI_NUM .and.;
      aScan(aUso,{|x| x[1]==ED2->ED2_PD .and. x[2]==ED2->ED2_DI_NUM .and. x[3]==ED2->ED2_PO_NUM .and.;
      x[4]==ED2->ED2_PGI_NU .and. x[5]==ED2->ED2_POSICA}) == 0   //Work->WKHAWB = ED2->ED2_HAWB .And. 
         cMemo := cMemo+Alltrim(Transform(ED2->ED2_DI_NUM,cPictDi))+If(!Empty(ED2->ED2_AC), " A.C. "+Alltrim(Transform(ED2->ED2_AC, cPictAC)), " Ped. "+Alltrim(Transform(ED2->ED2_PD, cPictPd)))+" Adic. "+Alltrim(ED2->ED2_ADICAO)+ENTER
         aAdd(aUso,{ED2->ED2_PD,ED2->ED2_DI_NUM,ED2->ED2_PO_NUM,ED2->ED2_PGI_NU,ED2->ED2_POSICA})
      EndIf
      ED2->(DbSkip())
   EndDo
   Work->(DbSkip())
EndDo
ED2->(DbSetOrder(1))

aUso:={}

Return .T.
