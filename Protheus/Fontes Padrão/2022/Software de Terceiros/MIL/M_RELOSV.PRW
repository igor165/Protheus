/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M_RELOSV   Autor ³ Thiago             º Data ³  04/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Os + Tipo de Tempo                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M_RELOSV     

Local cAlias := "VO1"
Local cDesc3 :=""

//Variaveis padrao de relatorio
Private cDesc1   := "Relatorio por Order de Servico" 
Private cabec1   := ""
Private cDesc2   := ""
Private cabec2   := ""
Private aReturn  := { "", 1,"", 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private cTitulo  := ""
Private cNomProg := "M_RELOSV 
Private cNomeRel := "M_RELOSV 
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg    := "RELOSV"
  
set printer to &cNomeRel
set printer on
set device to printer       

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf     

PERGUNTE(cPerg,.f.)

SetDefault(aReturn,cAlias)

RptStatus({|lEnd| ImpOSInt(@lEnd,cNomeRel,cAlias)},cTitulo)

Return

*******************************************
Static Function ImpOSInt(lEnd,wNRel,cAlias)

M_PAG  := 1     

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1

dbSelectArea("VO1")
dbSetOrder(1)
dbSeek(xFilial("VO1")+mv_par01,.t.)

nTotPad := 0
nTotTra := 0
nTotCob := 0
nTotVen := 0
                    
SetRegua( RecCount() )

@ nLin++, 001 pSay "OS Inicial  "+mv_par01+"    OS Final  "+mv_par02+"     Tipo Tempo "+mv_par03+"        Produtivo  "+mv_par04
nLin++
@ nLin++,001 pSay "Nro OS   S T  Cod Servico     Descricao            Tp  Padrao   Trab   Cobr   Vend Dt Inici  Hr In Dt Final  Hr Fi Chassi"
nLin+=2

cNumOsv := ""
cCodSer := ""
nTemPad := 99999
nTemVen := 99999
         
Do While !Eof() .and. VO1->VO1_FILIAL == xFilial("VO1") 
   IncRegua()                  
   
   if !Empty(mv_par01) .and. !Empty(mv_par02)
      if VO1->VO1_NUMOSV < mv_par01 .or. VO1->VO1_NUMOSV > mv_par02
         dbSelectArea("VO1")
         dbSkip()
         Loop
      Endif
   Endif
      
   DbSelectArea("VO2")
   DbSetOrder(1)
   DbSeek( xFilial("VO2")+VO1->VO1_NUMOSV)
   
   Do While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .and. VO1->VO1_NUMOSV == VO2->VO2_NUMOSV 
    
      dbSelectArea("VO4")  
      dbSetOrder(1)
      dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
      
      Do While !Eof() .and. VO4->VO4_FILIAL == xFilial("VO4") .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM 
         
         If nLin >= 60
            nLin := 1
            nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
         Endif          

         if !Empty(mv_par03)
            if VO4->VO4_TIPTEM <> mv_par03
               dbSelectArea("VO4")
               dbSkip()
               Loop
            Endif    
         Endif   
         
         if !Empty(mv_par04)
            if VO4->VO4_CODPRO <> mv_par04
               dbSelectArea("VO4")
               dbSkip()
               Loop
            Endif
         Endif      
             
         dbSelectArea("VOK")  
         dbSetOrder(1)
         dbSeek(xFilial("VOK")+VO4->VO4_TIPSER) 
         
         @ nLin++,001 pSay VO1->VO1_NUMOSV+" "+VO1->VO1_STATUS+" "+VO4->VO4_TIPTEM+"  "+VO4->VO4_CODSER+" "+VOK->VOK_DESSER+" "+VO4->VO4_TIPSER+" "+transform(VO4->VO4_TEMPAD,"999:99")+" "+transform(VO4->VO4_TEMTRA,"999:99")+" "+transform(VO4->VO4_TEMCOB,"@E 999:99")+" "+transform(VO4->VO4_TEMVEN,"@E 999:99")+" "+transform(VO4->VO4_DATINI,"@D")+" "+ transform(VO4->VO4_HORINI,"@E 999:99")+" "+transform(VO4->VO4_DATFIN,"@D")+" "+transform(VO4->VO4_HORFIN,"@E 999:99")+" "+VO1->VO1_CHASSI       

         if VO1->VO1_NUMOSV <> cNumOsv .or. VO4->VO4_CODSER <> cCodSer .or. VO4->VO4_TEMPAD <> nTemPad .or. VO4->VO4_TEMVEN <> nTemVen
            nTotPad += VO4->VO4_TEMPAD
            nTotVen += VO4->VO4_TEMVEN
         Endif
         nTotTra += VO4->VO4_TEMTRA
         nTotCob += VO4->VO4_TEMCOB

         cNumOsv := VO1->VO1_NUMOSV
         cCodSer := VO4->VO4_CODSER
         nTemPad := VO4->VO4_TEMPAD
         nTemVen := VO4->VO4_TEMVEN
         
         dbSelectArea("VO4")
         dbSkip()
      
      Enddo
        
      dbSelectArea("VO2")
      dbSkip()
      
   Enddo
        
   dbSelectArea("VO1")
   dbSkip()
      
Enddo

@ nLin++, 001 pSay space(55)+"------ ------ ------ ------"
@ nLin++, 001 pSay space(55)+transform(nTotPad,"@E 999:99")+" "+transform(nTotTra,"@E 999:99")+" "+transform(nTotCob,"@E 999:99")+" "+transform(nTotVen,"999:99")
@ nLin++, 001 pSay space(55)+"------ ------ ------ ------"

Set Printer to
Set device to Screen

MS_FLUSH()

If aReturn[5] == 1

   OurSpool(cNomeRel)
   
EndIf   
 
Return      
