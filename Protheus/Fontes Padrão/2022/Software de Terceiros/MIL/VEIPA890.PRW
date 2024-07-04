#INCLUDE "veipa890.ch"

#Include "protheus.ch"
#Include "Fileio.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ VEIPA890 ≥ Autor ≥ AndrÇ                 ≥ Data ≥ 25/10/99 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Recebimento Rapido das Parcelas                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function VEIPA890

Private oGrupo1,oCota1,oParc1,oData1,oValor1,dParc,oNroBol
Private cGrupo1  := "     "
Private cCota1   := "    "
Private cParc1   := "   "
Private dData1   := dDataBase
Private nValor1  := 0
Private cCodCli  := ""
Private cLoja    := ""
Private nOpca    := 0
Private cNroBol  := space(15)
Private dValor   := 0
Private dDespe   := 0
Private dDtVen   := ctod(" ")
Private dGrupo
Private dCota

aTipBaixa := {STR0001,STR0002} //"1=Normal (Manual)"###"2=Francesinha (Automatico)"
cTipBaixa := "1"

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0003) FROM  02,04 TO 08,28 OF oMainWnd //"Tipo de Recebimento"

   @  02, 02 TO 22,086 LABEL OemToAnsi(STR0004) OF oDlg PIXEL //"Baixar"

   @  07, 04 MSCOMBOBOX oTipBaixa VAR cTipBaixa SIZE 80,50 COLOR CLR_BLACK;
                                  ITEMS aTipBaixa OF oDlg PIXEL

   DEFINE SBUTTON FROM 27,24 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
   DEFINE SBUTTON FROM 27,55 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

if nOpca == 2
   Return .f.
Endif

nOpca   := 0

if cTipBaixa == "1"
   DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0005) FROM  02,04 TO 12,59 OF oMainWnd //"Recebimento de Parcelas"

   @ 01,005 SAY STR0006 SIZE 25,6 of oDlg PIXEL  //"Grupo" //"Grupo:"
   @ 15,005 SAY STR0007 SIZE 25,6 of oDlg PIXEL  //"Cota" //"Cota:"
   @ 30,005 SAY STR0008 SIZE 25,6 of oDlg PIXEL  //"Parcela" //"Parcela:"
   @ 45,005 SAY STR0009 SIZE 25,6 of oDlg PIXEL  // //"Data:"
   @ 60,005 SAY STR0010 SIZE 25,6 of oDlg PIXEL  // //"Valor:"

   @ 01,068 SAY dGrupo  SIZE 110,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 15,068 SAY dCota   SIZE 110,6 of oDlg PIXEL COLOR CLR_BLUE

   @ 30,060 SAY STR0011 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK  //"Vencimento" //"Vencto"
   @ 30,090 SAY STR0012 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK  // //"Valor"
   @ 30,120 SAY STR0013 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK  // //"Despesa"

   @ 37,060 SAY dDtVen                         SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 37,090 SAY dValor PICTURE "@E 999,999.99" SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 37,120 SAY dDespe PICTURE "@E 999,999.99" SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE
                                                                                                       
   @ 01,032 MSGET oGrupo1 VAR cGrupo1                           VALID FS_GRUPO()          F3 "VP3"      SIZE 26,4 OF oDlg PIXEL
   @ 15,032 MSGET oCota1  VAR cCota1                            VALID FS_COTA()           F3 "P11"      SIZE 23,4 OF oDlg PIXEL
   @ 30,032 MSGET oParc1  VAR cParc1                            VALID FS_PARCELA()                      SIZE 20,4 OF oDlg PIXEL
   @ 45,032 MSGET oData1  VAR dData1  PICTURE "@D"              VALID (dtos(dData1)<=dtos(dDatabase)) SIZE 40,4 OF oDlg PIXEL
   @ 60,032 MSGET oValor1 VAR nValor1 PICTURE "@E 9999,9999.99" VALID nValor1 > 0                       SIZE 40,4 OF oDlg PIXEL

   DEFINE SBUTTON FROM 01,178 TYPE 1  ACTION (nOpca := 1,oDlg:End()) TOOLTIP STR0014                ENABLE OF oDlg //"Ok"
   DEFINE SBUTTON FROM 15,178 TYPE 2  ACTION (nOpca := 2,oDlg:End()) TOOLTIP STR0015          ENABLE OF oDlg //"Cancelar"
   DEFINE SBUTTON FROM 30,178 TYPE 14 ACTION (FS_LISTPAR())          TOOLTIP STR0016 ENABLE OF oDlg //"Consulta Parcelas"

   ACTIVATE MSDIALOG oDlg CENTER
Else
   DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0005) FROM  02,04 TO 08,49 OF oMainWnd    // //"Recebimento de Parcelas"

   @ 01,005 SAY STR0017 SIZE 40,6 of oDlg PIXEL   //"Nro do Boleto:" //"Francesinha:"
   @ 01,042 GET oNroBol VAR cNroBol VALID FS_NROBOLETO() SIZE 55,4 OF oDlg PIXEL

   @ 12,005 SAY STR0006 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK   //"Grupo" //"Grupo:"
   @ 20,005 SAY STR0007 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK   //"Cota" //"Cota:"

   @ 12,035 SAY dGrupo  SIZE 110,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 20,035 SAY dCota   SIZE 110,6 of oDlg PIXEL COLOR CLR_BLUE

   @ 27,005 SAY STR0011 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK   //"Vencimento" //"Vencto"
   @ 27,035 SAY STR0012 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK   // //"Valor"
   @ 27,065 SAY STR0013 SIZE 25,6 of oDlg PIXEL COLOR CLR_BLACK   // //"Despesa"
       
   @ 37,005 SAY dDtVen                            SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 37,035 SAY dValor  PICTURE "@E 999,999.99"   SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE
   @ 37,065 SAY dDespe  PICTURE "@E 999,999.99"   SIZE 40,6 of oDlg PIXEL COLOR CLR_BLUE

   @ 27,100 SAY STR0009 SIZE 25,6 of oDlg PIXEL  // //"Data:"
   @ 35,100 MSGET oData1  VAR dData1  PICTURE "@D" VALID (dtos(dData1)<=dtos(dDatabase)) SIZE 40,4 OF oDlg PIXEL

   DEFINE SBUTTON FROM 00,115 TYPE 1  ACTION (if(!Empty(dData1).and.dtos(dData1)<=dtos(dDataBase),(nOpca := 1,oDlg:End()),.f.)) ENABLE OF oDlg
   DEFINE SBUTTON FROM 00,145 TYPE 2  ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTER
Endif

if nOpca == 1

   FS_BAIXARPD()

Endif

Return


*******************
Function FS_NROBOLETO()

   DbSelectArea("VP2")
   DbSetOrder(2)
   DbGotop()
   if DbSeek(xFilial("VP2")+cNroBol)
      cGrupo1 := VP2->VP2_CODGRU
      cCota1  := VP2->VP2_NUMCOT
      cParc1  := VP2->VP2_NUMPAR
      FS_GRUPO()
      FS_COTA()
      FS_PARCELA()
   Else
      MsgInfo(STR0018,STR0019) //"Francesinha nao encontrada..."###"Atencao!"
      Return .f.
   Endif

Return .t.


*******************
Function FS_GRUPO()

   cGrupo1 := STRZERO(val(cGrupo1),5)
   DbSelectArea("VP3")
   DbGotop()
   if DbSeek(xFilial("VP3")+cGrupo1)
      dGrupo := VP3_DESGRU
   Else
      Return .f.
   Endif

Return .t.


******************
Function FS_COTA()

   cCota1 := STRZERO(val(cCota1),4)
   DbSelectArea("VP1")
   DbGotop()
   if DbSeek(xFilial("VP1")+cGrupo1+cCota1)
      DbSelectArea("SA1")
      DbGotop()
      if DbSeek(xFilial("SA1")+VP1->VP1_CODCLI)
         dCota := A1_NOME
         cCodCli := VP1->VP1_CODCLI
         cLoja   := VP1->VP1_LOJA
      Else
         Return .f.
      Endif
   Else
      Return .f.
   Endif

   FG_GERPAR(cGrupo1+cCota1+VP1->VP1_CODCLI+VP1->VP1_LOJA,2,.f.)

   DbSelectArea("VP2")
   DbGotop()
   if DbSeek(xFilial("VP2")+cGrupo1+cCota1+VP1->VP1_CODCLI+VP1->VP1_LOJA)
      Do While !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU == cGrupo1 .and. VP2_NUMCOT == cCota1
         if Empty(VP2->VP2_DATPAG)
            cParc1:= VP2->VP2_NUMPAR
            Exit
         Endif
         DbSkip()
      Enddo
   Endif
Return .t.


*********************
Function FS_PARCELA()

   if STRZERO(val(cParc1),3) # "001"
      cParcAnt := STRZERO(val(cParc1)-1,3)
      DbSelectArea("VP2")
      DbSetOrder(1)
      DbGotop()
      if DbSeek(xFilial("VP2")+cGrupo1+cCota1+cCodCli+cLoja+cParcAnt)
         if Empty(VP2->VP2_DATPAG)
            HELP("PARNAOPAG")  //"Parcela anterior nao paga"
            Return .f.
         Endif
      Else
         HELP("PARNAOGER2")    //"Parcela nao Existente"
         Return .f.
      Endif
   Endif

   cParc1 := STRZERO(val(cParc1),3)
   DbSelectArea("VP2")
   DbSetOrder(1)
   DbGotop()
   if DbSeek(xFilial("VP2")+cGrupo1+cCota1+cCodCli+cLoja+cParc1)
      if !Empty(VP2->VP2_DATPAG)
         HELP("PARJAPAG")
         Return .f.
      Endif
   Else
      MsgInfo(STR0020,STR0019) //"Parcela inexistente!"###"Atencao!"
      Return .f.
   Endif

   nValor1:= VP2_VALPAR+VP2_VALDES
   dParc  := VP2_NUMPAR
   dValor := VP2_VALPAR
   dDespe := VP2_VALDES
   dDtVen := VP2_DATPAR

Return .t.


**********************
Function FS_BAIXARPD()

   wPIdeal := VP1->VP1_PERIDE

   wValorBem := 0
   wPerSaldo := 0

   dbSelectArea("VP6")
   if VP6->(DbSeek(xFilial("VP6")+VP1->VP1_CODBEM))
      wValorBem := VP6->VP6_VALBEM
   Endif

   RecLock("VP2",.f.)

   VP2_PARPAG := VP2_PARPAG + nValor1 - dDespe
   VP2_DESPAG := dDespe
   VP2_TOTPAG := VP2_PARPAG + VP2_DESPAG
   VP2_DATPAG := dData1

   VP2_PERPAG := VP2_PERPAG + ((nValor1-dDespe)/wValorBem)*100
   if VP2_PERPAG < wPIDEAL
      VP2_PERDIF := wPIDEAL - VP2_PERPAG
   Else
      VP2_PERDIF := 0
   Endif

   MsUnlock()

   wPerSaldo   := (wPerSaldo + VP2_PERPAG) - VP2_PERDIF

   Do while !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU == cGrupo1 .and. VP2_NUMCOT == cCota1
      RecLock("VP2",.f.)
      VP2_PERSAL := VP2_PERSAL - wPerSaldo
      MsUnlock()
      DbSkip()
   Enddo

   FG_GERPAR(cGrupo1+cCota1+VP1->VP1_CODCLI+VP1->VP1_LOJA,2,.f.)

Return .t.


*********************
Function FS_LISTPAR()
               
   Local aArea := GetArea()
   Private oDlgLayOut
   Private oGetH
   Private oGetD
   Private oGetT
   Private oLbHeader
   Private oLbDetail
   Private oLbTrail
   Private oBarHeader
   Private oBarDetail
   Private oBarTrail
   Private nHeader := 0
   Private nTree := 0
   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private aTELA[0][0],aGETS[0]
   Private aItem2 := {}

   cPic  := "@E 999,999,999.99"

   DbSelectArea("VP2")
   DbGotop()
   if DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT)
      Do While !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2")
         if VP1->VP1_CODGRU+VP1->VP1_NUMCOT == VP2_CODGRU+VP2_NUMCOT
            aadd(aItem2,{VP2_NUMPAR,DTOC(VP2_DATPAR),TRANS(VP2_VALBEM,cPic),TRANS(VP2_VALPAR,cPic),TRANS(VP2_VALDES,cPic),TRANS(VP2_VALLAN,cPic),TRANS(VP2_PERLAN,"@E 999.9999"),TRANS(VP2_PARPAG,cPic),TRANS(VP2_DESPAG,cPic),TRANS(VP2_TOTPAG,cPic),DTOC(VP2_DATPAG),TRANS(VP2_PERPAG,"@E 999.9999"),TRANS(VP2_PERDIF,"@E 999.9999"),TRANS(VP2_PERSAL,"@E 999.9999")})
         Else
            Exit
         Endif
         DbSkip()
      Enddo
   Else
      aadd(aItem2,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "})
   Endif

   nOpca2 := 0

   DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0005) From 2,0 to 23,80 of oMainWnd  // //"Recebimento de Parcelas"

   @ 012, 000 LISTBOX oLbHeader2 FIELDS HEADER	OemToAnsi(STR0021),;  //"Parcela" //"Parcela   "
                                                OemToAnsi(STR0022),;  //"Data" //"Data      "
                             					OemToAnsi(STR0023),;  //"Credito" //"Credito   "
           				   						OemToAnsi(STR0024),;  //"Sd Parc" //"Sd Parc   "
												OemToAnsi(STR0025),;  //"Vl Desp" //"Vl Desp   "
												OemToAnsi(STR0026),;  // //"Vl Lan/Ant"
												OemToAnsi(STR0027),;  //"% Lance" //"% Lance   "
												OemToAnsi(STR0028),;  //"Pg Parc" //"Pg Parc   "
												OemToAnsi(STR0029),;  //"Pg Desp" //"Pg Desp   "
												OemToAnsi(STR0030),;  //"Pg Total" //"Pg Total  "
												OemToAnsi(STR0031),;  //"Data Pg" //"Data Pg   "
												OemToAnsi(STR0032),;  //"% Pago" //"% Pago    "
												OemToAnsi(STR0033),;  //"% Difer" //"% Difer   "
					       						OemToAnsi(STR0034);  //"% Saldo" //"% Saldo   "
   COLSIZES 28,48,48,48,48,48,48,48,48,48,48,48,48;
   SIZE 318,147 OF odlg2 PIXEL

   oLbHeader2:SetArray(aItem2)
   oLbheader2:bLine := { || {aItem2[oLbHeader2:nAt,1] ,;
  		                      aItem2[oLbHeader2:nAt,2] ,;
                              aItem2[oLbHeader2:nAt,3] ,;
		               		  aItem2[oLbHeader2:nAt,4] ,;
    	              		  aItem2[oLbHeader2:nAt,5] ,;
	                  		  aItem2[oLbHeader2:nAt,6] ,;
        	          		  aItem2[oLbHeader2:nAt,7] ,;
            	      		  aItem2[oLbHeader2:nAt,8] ,;
                	  		  aItem2[oLbHeader2:nAt,9] ,;
                  			  aItem2[oLbHeader2:nAt,10] ,;
                  			  aItem2[oLbHeader2:nAt,11] ,;
	                  		  aItem2[oLbHeader2:nAt,12] ,;
    	              		  aItem2[oLbHeader2:nAt,13] ,;
        	          		  aItem2[oLbHeader2:nAt,14] }}

   ACTIVATE MSDIALOG oDlg2 ON INIT FG_EnchoiceBar(oDlg2,{||nOpca2:=1,If(!obrigatorio(aGets,aTela),nOpca2 := 0,odlg2:End())},{||odlg2:End()},1) CENTER

RestArea(aArea)
Return .t.
