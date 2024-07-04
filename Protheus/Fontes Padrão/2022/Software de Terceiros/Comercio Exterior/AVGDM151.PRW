/*
Função    : AVGDM151()   
Autor     : Lucas Rolim Rosa Lopes
Data      : 03/03/2005
Descrição : Função que gera relatorio em Crystal
Revisão   : 01/04/2005 - Alessandro Alves Ferreira - Acertos na Impressão do Debit Note.
*/
*---------------------------*
Function AVGDM151()
*---------------------------*
//Local cObs,ni,i
Local cNavio
Local dBl                                                    
Local Ni

If Select("HEADER_P") = 0
   E_ARQCRW(.T.,,.T.)
EndIf

Private cSeqRel := GetSXENum("SY0","Y0_SEQREL")              
Private lFilOri := EG1->( FieldPos( "EG0_FILORI" ) ) > 0
chkfile("SB1",.F.)
chkfile("SY9",.F.)
chkfile("EE6",.F.)
chkfile("EEC",.F.)
chkfile("SA2",.F.)
chkfile("SW6",.F.)
Private cFilEG0 := xFilial("EG0")
Private cFilEG1 := xFilial("EG1")
Private cFilSB1 := xFilial("SB1")                    
Private cFilEE6 := xFilial("EE6")                                                     
Private cFilEEC := xFilial("EEC")
Private cFilSA2 := xFilial("SA2")
Private cFilSW6 := xFilial("SW6")
Private cFilSY9 := xFilial("SY9")

//AAF 01/04/05 - Picture para o campo Quantity e Rate L/D
Private cPictQt := SubStr( AVSX3("EG1_QTDMT",6), 1, rAt(".",AVSX3("EG1_QTDMT",6)) )+"999"
Private cPictRt := SubStr( AVSX3("EG1_QTDMT",6), 1, rAt(".",AVSX3("EG1_QTDMT",6))-1 )

ConfirmSX8()
HEADER_P->(DbAppend())
HEADER_P->AVG_FILIAL := cFilEG0
HEADER_P->AVG_SEQREL := cSeqRel
HEADER_P->AVG_CHAVE  := cSeqRel

HEADER_P->AVG_C01_20 := EG0->EG0_DEMURR
HEADER_P->AVG_C02_20 := Cmonth(dDataBase) + ", " + Transform(Day(dDataBase),"99") + "th , " + Transform(Year(dDataBase),"9999") 
SA2->(DbSeek(cFilSA2+EG0->EG0_FORNEC+EG0->EG0_FORLOJ))
HEADER_P->AVG_C06_10 := SA2->A2_NOME
HEADER_P->AVG_C01_60 := SA2->A2_NOME
HEADER_P->AVG_C01100 := AllTrim(  SA2->A2_NR_END)+", "+AllTrim( SA2->A2_END ) 
HEADER_P->AVG_C04_60 := AllTrim( Padl( SA2->A2_CEP,10 ) ) + ", "+AllTrim( SA2->A2_MUN )+" "+AllTrim( SA2->A2_EST )
HEADER_P->AVG_C03_20 := AllTrim( SA2->A2_BAIRRO )
cNavio := AllTrim( Posicione( "EE6",1,cFilEE6+EG0->EG0_NAVIO,"EE6_NOME" ) )
HEADER_P->AVG_C01150 := cNavio + "  " + AllTrim( EG0->EG0_CHART ) + "  " + "  " + DTOC(EG0->EG0_DT_CP)
HEADER_P->AVG_C02_30 := Posicione("SY9",2,cFilSY9+EG0->EG0_DEST,"Y9_DESCR")
EG1->( DbSeek( cFilEG1+if( nModulo ==17,"I","E" )+EG0->EG0_DEMURR ) )
dBl := IF( nModulo == 29 ,Posicione("EEC",1,if(lFilOri,EG1->EG1_FILORI,cFilEEC)+AvKey(EG1->EG1_EMBARQ,"EEC_PREEMB"),"EEC_DTCONH");
                         ,Posicione("SW6",1,if(lFilOri,EG1->EG1_FILORI,cFilSW6)+AvKey(EG1->EG1_EMBARQ,"W6_HAWB"),"W6_DT_EMB" ) )
If Empty(HEADER_P->AVG_C02_30)
   HEADER_P->AVG_C02_30 := IF( nModulo == 29 ,Posicione("SY9",2,cFilSY9+EEC->EEC_DEST,"Y9_DESCR"),Posicione("SY9",2,cFilSY9+SW6->W6_DEST,"Y9_DESCR") )
EndIf
HEADER_P->AVG_C03_60 := IF( nModulo == 29 ,EEC->EEC_RESPON,"")
If !Empty(dBL)
   HEADER_P->AVG_C07_20 := Cmonth(dBL) + ", " + Transform(Day(dBl),"99") + "th, " + Transform(Year(dBl),"9999") 
Endif
HEADER_P->AVG_C02_60 := cNavio
HEADER_P->AVG_C04_20 := Alltrim( Transform( EG0->EG0_RAT_LD, cPictRt ) )//AAF 01/04/05 - Alteração na Picture
HEADER_P->AVG_C03_10 := EG0->EG0_USED
HEADER_P->AVG_C04_10 := EG0->EG0_MOEDA
HEADER_P->AVG_C05_20 := AllTrim( Transform( EG0->EG0_DEM_V , Avsx3( "EG0_DEM_V", 6  ) ) )
HEADER_P->AVG_C06_20 := AllTrim( Transform( EG0->EG0_NEG_VL, Avsx3( "EG0_NEG_VL", 6 ) ) )
HEADER_P->AVG_N01_04 := Val(EG0->EG0_RAT_HD)
HEADER_P->AVG_C08_20 := SM0->M0_NOME

If EasyEntryPoint("AVGDM151")
   ExecBlock("AVGDM151",.F.,.F.,"ANTES_GRV_HEADER")
EndIf

HEADER_P->(dbUnlock())
//--------------------------------------------------------------------------
Do While EG1->(!EOF()) .AND. EG1->EG1_FILIAL+EG1->EG1_DEMURR == cFilEG1+EG0->EG0_DEMURR
   DETAIL_P->(DbAppend())
   DETAIL_P->AVG_FILIAL := cFilEG1
   DETAIL_P->AVG_SEQREL := cSeqRel
   DETAIL_P->AVG_CHAVE  := cSeqRel
   DETAIL_P->AVG_C01_60 := Posicione( "SB1",1,cFilSB1+EG1->EG1_COD_I,"B1_DESC")
   DETAIL_P->AVG_C02_60 := Alltrim( Transform( EG1->EG1_QTDMT , cPictQt ) ) //AAF 01/04/05 - Avsx3( "EG1_QTDMT", 6 )
   DETAIL_P->AVG_N01_04 := 1
   If EasyEntryPoint("AVGDM151")
      ExecBlock("AVGDM151",.F.,.F.,"ANTES_GRV_DETAIL")
   EndIf
   DETAIL_P->(dbUnlock())
   EG1->( DbSkip () )
EndDo

HEADER_H->(dbAppend())
AvReplace("HEADER_P","HEADER_H") 
cObs := MSMM(EG0->EG0_BANCO,AVSX3("EG0_VM_BCO",3))
Do While At("  ",cObs) > 0
  cObs := StrTran( cObs, "  " , " " )
EndDo
For ni:=1 to MlCount(cObs,100)
   DETAIL_P->(dbAppend())
   DETAIL_P->AVG_FILIAL := cFilEG1
   DETAIL_P->AVG_SEQREL := cSeqRel
   DETAIL_P->AVG_CHAVE  := cSeqRel
   DETAIL_P->AVG_C01100 := MemoLine(cObs,100,ni)
   DETAIL_P->AVG_N01_04 := 2
   DETAIL_P->(dbUnlock())
Next ni
DETAIL_P->(DBSETORDER(0),DbGoTop())
Do While ! DETAIL_P->(Eof())
   DETAIL_H->(DbAppend())
   AvReplace("DETAIL_P","DETAIL_H")
   DETAIL_P->(DbSkip())
EndDo
HEADER_P->(DBCOMMIT())
DETAIL_P->(DBCOMMIT())
AvgCrw32("AVGDM151.RPT","DEBIT NOTE NBR")
E_HISTDOC(,"Debit Note",dDataBase,,,"AVGDM151.RPT",cSeqrel)
Return .t.
