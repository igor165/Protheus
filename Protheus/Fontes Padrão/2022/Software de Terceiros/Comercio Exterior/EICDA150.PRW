#INCLUDE "EICDA150.CH"
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "AVPRINT.CH"

/*
±±³Fun‡ao    ³ EICDA150 ³ Autor ³ Luiz Claudio Barbosa  ³ Data ³ 18.08.00 ³±±
±±³Descri‡ao ³ Zera o saldo de nacionalização de PO, quando houver nacio- ³±±
±±³          ³ nalização parcial.                                         ³±±
*/
*-----------------------------------------------*
Function EICDA150()
*-----------------------------------------------*
Private lSubstituido:=.F.

IF(EasyEntryPoint("EICDA150"),ExecBlock("EICDA150",.F.,.F.,"SUBSTITUI_TUDO"),)

IF lSubstituido
   RETURN .F.
ENDIF

Private cTitDA :=AVSX3("W6_DI_NUM",5)
Private cTitPro:=AVSX3("W6_NR_PRO",5)
Private cArqTrb
Private cArmazem := Space(Len(SW2->W2_ARMAZEM))
Private cCod_I   := Space(Len(SW3->W3_COD_I))
Private cForn    := Space(Len(SW2->W2_FORN))
Private cImport  := Space(Len(SW2->W2_IMPORT))
Private cCodDA   := Space(Len(SW2->W2_HAWB_DA))
Private dVencDe  := AVCTOD("")
Private dVencAte := AVCTOD("")
Private cTipo    := STR0015
Private nPos_SLD := 0
Private nPos_QTD := 0
Private lValid   := .T.
Private nLinFim,nColFim //LRS - 21/11/2014
Private oDlg //LRS - 21/11/2014

Private cCombo1  := STR0007// "Armazem"
Private cCombo2  := STR0014// "Sem quebra"
Private cCombo3  := STR0014// "Sem quebra"
Private cCombo4  := STR0014// "Sem quebra"
Private cCombo5  := STR0014// "Sem quebra"
Private cCombo6  := STR0014// "Sem quebra"
Private cCombo7  := STR0014// "Sem quebra"


//   		           Titulo    Campo            Compara com
Private aChave   := { {STR0007, "ARMAZEM"      },;      // "Armazem"
                      {STR0008, "Dtos(VENCDA)" },;      // "Vencto DA"
                      {STR0009, "COD_I"        },;      // "Produto"
                      {STR0010, "FORNEC"       },;      // "Fornecedor"
                      {STR0011, "IMPORT"       },;      // "Importador"
                      {cTitDA , "DI_NUM"       },;
                      {cTitPRO, "NR_PRO"       },;
                      {STR0014, ""             } }      // "Sem quebra"

Private aCombo   := { STR0007,;      // "Armazem"
					  STR0008,;      // "Vencto DA"
					  STR0009,;      // "Produto"
					  STR0010,;      // "Fornecedor"
					  STR0011,;      // "Importador"														
					  cTitDA ,;
					  cTitPRO,;
					  STR0014 }      // "Sem quebra"

DO WHILE .T.

	nOpca := 0
    nColS := 02
    nCol1 := 60
    nLarg := 55
    
    nLinFim := 34
    nColFim := 65
        
	DEFINE MSDIALOG oDlg TITLE STR0004 From 6,0 To nLinFim,nColFim OF oMainWnd  // "Relatório de Saldo de Armazens"
	
	oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

			@ 20,nColS SAY STR0007        SIZE 70,8 OF oPanel PIXEL                    // "Armazem"
			@ 20,nCol1 MSGET cArmazem F3 "SJA" PICTURE "@!" SIZE nLarg,8 OF oPanel PIXEL Valid DA150ValSeek(cArmazem,"SJA")

			@ 35,nColS SAY STR0010        SIZE 70,8 OF oPanel PIXEL                    // "Fornecedor"
			@ 35,nCol1 MSGET cForn    F3 "SA2" PICTURE "@!" SIZE nLarg,8 OF oPanel PIXEL Valid DA150ValSeek(cForn,"SA2")

			@ 50,nColS SAY STR0011        SIZE 70,8 OF oPanel PIXEL                    // "Importador"
			@ 50,nCol1 MSGET cImport  F3 "SYT" PICTURE "@!" SIZE nLarg,8 OF oPanel PIXEL Valid DA150ValSeek(cImport,"SYT")

			@ 65,nColS SAY STR0012        SIZE 70,8 OF oPanel PIXEL                    // "De  Vencto DA"
			@ 65,nCol1 MSGET dVencDe  Valid DA150Data()     SIZE nLarg,8 OF oPanel PIXEL

			@ 80,nColS SAY STR0013        SIZE 70,8 OF oPanel PIXEL                    // "Até Vencto DA"
			@ 80,nCol1 MSGET dVencAte Valid DA150Data()     SIZE nLarg,8 OF oPanel PIXEL

			@ 95,nColS SAY STR0017       SIZE 70,8 OF oPanel PIXEL                    // "Até Vencto DA"
			@ 95,nCol1 COMBOBOX cTipo    ITEMS {STR0015, STR0016} SIZE 45,25 OF oPanel PIXEL// {"Analitico", "Sintetico"}
			
			@ 115,nColS SAY STR0009        SIZE 70,8 OF oPanel PIXEL                    // "Produto"
			@ 115,30 MSGET cCod_I   F3 "SB1" PICTURE "@!" SIZE 102,8 OF oPanel PIXEL Valid DA150ValSeek(cCod_I,"SB1")
			
			@ 130,nColS SAY "Número DA"        SIZE 70,8 OF oPanel PIXEL                    // "Numero DA"
			@ 130,30 MSGET cCodDA   F3 "SW2DA" PICTURE "@!" SIZE 102,8 OF oPanel PIXEL Valid DA150ValSeek(cCodDA,"SW2")

			@ 30,150 COMBOBOX oCb1 Var cCombo1  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@ 47,150 COMBOBOX oCb2 Var cCombo2  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@ 64,150 COMBOBOX oCb3 Var cCombo3  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@ 81,150 COMBOBOX oCb4 Var cCombo4  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@ 98,150 COMBOBOX oCb5 Var cCombo5  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@115,150 COMBOBOX oCb6 Var cCombo6  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			@132,150 COMBOBOX oCb7 Var cCombo7  ITEMS aCombo	SIZE 75,30 OF oPanel PIXEL
			
			@ 20,135 TO 150, 235 LABEL STR0020 OF oPanel  PIXEL //"Seleção"
            
          IF(EasyEntryPoint("EICDA150"),ExecBlock("EICDA150",.F.,.F.,"FILTRO_QUEBRA"),) //LRS - 21/11/2014  - Editar oDlg
			
	ACTIVATE MSDIALOG oDlg ON INIT ;
             EnchoiceBar(oDlg,{|| IF(DA150VALTUDO(),(nOpca:=1,oDlg:End()),)},;
                              {||nOpca:=0,oDlg:End()}) CENTERED

	IF nOpca = 1
       // Cria arquivo temporario    
	   Processa({|| DA150GRVWORK()} )
       TRB->(dbGoTop())
       If TRB->(Eof()) .AND. TRB->(Bof())
          Help(" ", 1, "SEMDADOS")  
          LOOP
       ENDIF
	   
       IF(EasyEntryPoint("EICDA150"),ExecBlock("EICDA150",.F.,.F.,"POS_GER_TRB"),)
	   
	   // Imprime dados do arquivo temporario
	   Processa({|| DA150IMPRIME()})
	ElseIf nOpca == 0
       Exit
	EndIf
ENDDO

If Select("TRB") > 0
   TRB->(E_ERASEARQ(cArqTrb))
ENDIF

RETURN .T.
*-----------------------------------------------*
Function DA150ValSeek(cCampo,cAlias)
*-----------------------------------------------*
DBSELECTAREA(cAlias)                         
DBSETORDER(1)
IF !EMPTY(cCampo) .AND. !ExistCpo(cAlias,cCampo)
   Return .f.
ENDIF

RETURN .T.
*-----------------------------------------------*
Function DA150VALTUDO()
*-----------------------------------------------*
Local nX := 1, lRet:=.F.
Local nTamCom:=Len(aCombo)-1

//Verifica se todos estao sem quebra
For nX := 1 To nTamCom
   If &("cCombo"+StrZero(nX,1)) # STR0014//"Sem Quebra"
      lRet := .T.
      EXIT
   ENDIF   
Next
IF !lRet
   Help("",1,"AVG0000241")
   RETURN .F.
ENDIF

//Verifica se tem algum repetido
aRep:={}
For nX := 1 To nTamCom
   cConteudo:=&("cCombo"+StrZero(nX,1))
   If cConteudo # STR0014//"Sem Quebra"
      IF ASCAN(aRep,cConteudo) = 0
         AADD(aRep,cConteudo)
      ELSE
         Help(" ", 1, "AVG0000105")        
         RETURN .F.
      ENDIF
   ENDIF
NEXT

RETURN .T.

*-----------------------------------------------*
Function DA150GRVWORK()
*-----------------------------------------------*
Local cCondSW2 := cCondSW3 := ".T.", cCombo, nScan, nA, nRecSW3 := 0
Local cChave, cFiltro, cTexto, cFornec, nQtde, nSaldo, cProduto
Local aStru := { ;
			{"PO_NUM" , AVSX3("W2_PO_NUM" , 2), AVSX3("W2_PO_NUM" , 3), 0},;
			{"VENCDA" , AVSX3("W2_VENCDA" , 2), AVSX3("W2_VENCDA" , 3), 0},;
			{"COD_I"  , AVSX3("W3_COD_I"  , 2), AVSX3("W3_COD_I"  , 3), 0},;
			{"DESCRI" , AVSX3("W3_COD_I"  , 2), AVSX3("B1_VM_P"   , 3), 0},;
			{"HAWB_DA", AVSX3("W2_HAWB_DA", 2), AVSX3("W2_HAWB_DA", 3), 0},;
			{"ARMAZEM", AVSX3("W2_ARMAZEM", 2), AVSX3("W2_ARMAZEM", 3), 0},;
			{"FORNEC" , AVSX3("W3_FORN"   , 2), AVSX3("W3_FORN"   , 3), 0},;
			{"PARTNUM", AVSX3("A5_CODPRF" , 2), AVSX3("A5_CODPRF" , 3), 0},;			
			{"IMPORT" , AVSX3("W2_IMPORT" , 2), AVSX3("W2_IMPORT" , 3), 0},;
			{"QTDE"   , AVSX3("W3_QTDE"   , 2), AVSX3("W3_QTDE"   , 3), AVSX3("W3_QTDE"   , 4)},;
			{"SALDO_Q", AVSX3("W3_SALDO_Q", 2), AVSX3("W3_SALDO_Q", 3), AVSX3("W3_SALDO_Q", 4)},;
			{"PRECO"  , AVSX3("W3_PRECO"  , 2), AVSX3("W3_PRECO"  , 3), AVSX3("W3_PRECO"  , 4)},;
			{"DI_NUM" , "C",AVSX3("W6_DI_NUM",3),0},;
			{"NR_PRO" , "C",AVSX3("W6_NR_PRO",3),0},;
			{"LOTE"   , "C",AVSX3("WV_LOTE"  ,3),0},;
			{"SLDXPRC", "N",12,2}}//SVG - 13/08/08 Inclusão de Campo Saldo Qtde x Preco Unitario
			
Private bCondSW3 //LRS 21/11/2014

cFilSA5:=xFilial("SA5")
cFilSW2:=xFilial("SW2")
cFilSW3:=xFilial("SW3")
cFilSW5:=xFilial("SW5")
cFilSW6:=xFilial("SW6")
cFilSWV:=xFilial("SWV")

If Select("TRB") > 0
   DBSelectAREA("TRB")
   TRB->(E_ERASEARQ("TRB"))
EndIf

cArqTrb := E_CriaTrab(,aStru,,,.F.)

cChave := ""
For nA := 1 To Len(aCombo)
	If aCombo[nA] != STR0014
       cCombo := "cCombo"+StrZero(nA,1)
	   cCombo := &cCombo
	   nScan  := Ascan(aChave, {|x| x[1] == cCombo})
	   cChave := If(nScan > 0, cChave+If(Empty(cChave) .Or. nScan == Len(aCombo),"","+")+aChave[nScan,2], cChave)
    EndIf
Next
cFiltro := Nil
cTexto  := STR0001                                // "Organizando arquivo temporário"

IndRegua("TRB", cArqTrb, cChave, , cFiltro, cTexto)

ProcRegua(SW2->(LastRec()))

bCondSW2:={|| (!Empty(cArmazem) .AND. cArmazem # SW2->W2_ARMAZEM) .OR.;
			  (!Empty(cImport)  .AND. cImport  # SW2->W2_IMPORT ) .OR.;
			  (!Empty(cCodDA)   .AND. Alltrim(cCodDA) # Alltrim(SW2->W2_HAWB_DA)) .OR.;			  
			  (!Empty(dVencDe)  .AND. SW2->W2_VENCDA < dVencDE  ) .OR.;
			  (!Empty(dVencAte) .AND. SW2->W2_VENCDA > dVencAte ) }

bCondSW3:={|| (!Empty(cCod_I) .AND. cCod_I # SW3->W3_COD_I) .OR.;
			  (!Empty(cForn)  .AND. cForn  # SW3->W3_FORN ) }
			  
IF(EasyEntryPoint("EICDA150"),ExecBlock("EICDA150",.F.,.F.,"PONTO_COND"),) //LRS - 21/11/2014	- Editar bCondSW3		  

lTemLOTE:=EasyGParam("MV_LOTEEIC") $ cSim     
nTamReg :=AVSX3("WV_REG",3)
cFilSB1 :=xFilial("SB1")
nTam    :=AVSX3("B1_VM_P",3)
SW6->(dbSetOrder(1))
SW3->(dbSetOrder(8))
SW5->(dbSetOrder(8))
SA5->(dbSetOrder(3))

SW2->(DBSEEK(xFilial()))

DO While !(SW2->(Eof())) .AND. SW2->W2_FILIAL == cFilSW2

   IncProc(STR0002+" "+SW2->W2_HAWB_DA)// "Lendo processo de nacionalização"

   If EVAL(bCondSW2) .Or. EMPTY(SW2->W2_HAWB_DA)
      SW2->(dbSkip())
      Loop
   EndIf

   SW3->(dbSeek(cFilSW3+SW2->W2_PO_NUM))

   DO While !(SW3->(Eof())) .And. cFilSW3+SW2->W2_PO_NUM == ;
            SW3->W3_FILIAL+SW3->W3_PO_NUM

      If EVAL(bCondSW3)
         SW3->(dbSkip())
         Loop
      EndIf

      SA5->(dbseek(cFilSA5+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
      cPosicao := SW3->W3_POSICAO
      cProduto := SW3->W3_COD_I
      cFornec  := SW3->W3_FORN
      nQtde    := SW3->W3_QTDE
      nSaldo   := 0
      nRecno   := 0
      nPreco   := SW3->W3_PRECO
      cPartNum := ""
      
      DO While !(SW3->(Eof())) .And. cFilSW3+SW2->W2_PO_NUM == ;
                              SW3->W3_FILIAL+SW3->W3_PO_NUM .And.;
                              cPosicao == SW3->W3_POSICAO
         If SW3->W3_SEQ == 0
            nSaldo := nSaldo + SW3->W3_SALDO_Q
            nRecSW3:= SW3->(RECNO())  //TRP-29/06/07
            SW3->(dbSkip())
            Loop
         EndIf

         If SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N)//ASK 08/10/2007
            cPartNum := SW3->W3_PART_N
         Else
            cPartNum := SA5->A5_CODPRF 
         EndIf
         SW5->(dbSeek(cFilSW5+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO))
         DO While !(SW5->(Eof())) .And. cFilSW5+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO ==;
                                 SW5->W5_FILIAL+SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO

           If SW5->W5_SEQ == 0
              nSaldo := nSaldo + SW5->W5_SALDO_Q
              nRecno := SW5->(RECNO())
           EndIf

            SW5->(dbSkip())
         EndDo
         nRecSW3:= SW3->(RECNO()) //LAM - 03/04/2006
         SW3->(dbSkip())
      EndDo

      If nSaldo # 0

         SW6->(DBSEEK(cFilSW6+SW2->W2_HAWB_DA))
         TRB->(DBAPPEND())
         TRB->PO_NUM  := SW2->W2_PO_NUM
         TRB->VENCDA  := SW2->W2_VENCDA
         TRB->COD_I   := cProduto
         TRB->HAWB_DA := SW2->W2_HAWB_DA
         TRB->ARMAZEM := SW2->W2_ARMAZEM
         TRB->FORNEC  := cFornec
         TRB->IMPORT  := SW2->W2_IMPORT
         TRB->QTDE    := nQtde
         TRB->SALDO_Q := nSaldo
         //TRB->PARTNUM := SA5->A5_CODPRF 
         TRB->PARTNUM := cPartNum  //ASK 08/10/2007
         TRB->DI_NUM  := SW6->W6_DI_NUM 
         TRB->NR_PRO  := SW6->W6_NR_PRO
         TRB->PRECO   := nPreco
         SB1->(dbSeek(cFilSB1+TRB->COD_I))
         IF !EMPTY(SB1->B1_DESC_P)
            TRB->DESCRI:=ALLTRIM(MSMM(SB1->B1_DESC_P,nTam,1))
         ENDIF
         
         IF(EasyEntryPoint("EICDA150"),ExecBlock("EICDA150",.F.,.F.,"ORGANI_WORK"),) //LRS - 21/11/2014 - Editar Work TRB

         IF lTemLOTE .AND. nRecno # 0
            SW5->(DBGOTO(nRecno))
            IF SWV->(dbSeek(cFilSWV+SPACE(LEN(SW6->W6_HAWB))+SW5->(W5_PGI_NUM+W5_PO_NUM+W5_CC+W5_SI_NUM+W5_COD_I+STR(W5_REG,nTamReg)) ))
               TRB->LOTE := SWV->WV_LOTE
            ENDIF
         ENDIF

         TRB->SLDXPRC := nSaldo * nPreco //SVG - 13/08/08 Adicionando na Work
       ENDIF
		 IF nRecSW3<>0
		 	SW3->(DBGOTO(nRecSW3)) //LAM - 03/04/2006
		 ENDIF
       SW3->(dbSkip())

   EndDo
   
   SW2->(dbSkip())
EndDo
SW3->(dbSetOrder(1))
SW5->(dbSetOrder(1))
SA5->(dbSetOrder(1))
Return(Nil)

*--------------------------*
Function DA150IMPRIME()
*--------------------------*
Local cLinha := ""

Private cLinCab  , cLinDet  , cParam
Private cQuebra1 , cQuebra2 , cQuebra3 , cQuebra4 , cQuebra5
Private cQuebra6 , cQuebra7
Private xQuebra1 , xQuebra2 , xQuebra3 , xQuebra4 , xQuebra5
Private xQuebra6 , xQuebra7
Private xQueb1   , xQueb2   , xQueb3   , xQueb4   , xQueb5
Private xQueb6   , xQueb7
Private cVarQueb1, cVarQueb2, cVarQueb3, cVarQueb4, cVarQueb5
Private cVarQueb6, cVarQueb7
Private nQtde1   , nQtde2   , nQtde3   , nQtde4   , nQtde5
Private nQtde6   , nQtde7
//SVG - 13/08/08
Private nSldPrc1   , nSldPrc2   , nSldPrc3   , nSldPrc4   , nSldPrc5
Private nSldPrc6   , nSldPrc7
Private nSld1    , nSld2    , nSld3    , nSld4    , nSld5
Private nSld6    , nSld7
Private lFirst1  , lFirst2  , lFirst3  , lFirst4  , lFirst5  , lTotal := .F.
Private lFirst6  , lFirst7
Private nTotSld  := nTotQtd :=nSldxPrc:= 0

// Variaveis utilizadas na impressão
Private nLinha  := 9999, nPagina := 0
Private nColIni := 0, nColFim := 3300

nPagina := 0
 
#Define COURIER_NEW_08        oFont1
#Define COURIER_NEW_10        oFont2

#COMMAND TRACO_NORMAL  => oSend(oPrn,"Line", nLinha  ,  nColIni, nLinha  , nColFim ) ;
                          ;  oSend(oPrn,"Line", nLinha+1,  nColIni, nLinha+1, nColFim )

#COMMAND COMECA_PAGINA => nLinha := 180                            ;
                          ;  nPagina := nPagina+ 1                    ;
                          ;  DA150Cabec()

ProcRegua(TRB->(LastRec()))
oPrn:= Nil

oPrn := PrintBegin("",.F.,.F.)
oSend( oPrn, "SetLandScape" )
PrintEnd()

AVPRINT oPrn NAME STR0004     // "Relatório de Saldo de armazens"

DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
DEFINE FONT oFont2  NAME "Courier New" SIZE 0,07 OF  oPrn
						
AVPAGE
DA150Detalhe()
dbSelectArea("TRB")
dbGoTop()
DA150QUEBRA() //LRS - 29/01/2016
			
Do While !(TRB->(Eof()))
   &xQuebra1
   nQtde1 := 0
   nSld1  := 0
   nSldPrc1:=0
   lFirst1:= .T.
   Do While !(TRB->(Eof())) .And. &cQuebra1
      &xQuebra2
      nQtde2 := 0
      nSld2  := 0
      nSldPrc2:=0
      lFirst2:= .T.
      Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2
         &xQuebra3
         nQtde3 := 0
         nSld3  := 0
         nSldPrc3:= 0
         lFirst3:= .T.
         Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2 .And. &cQuebra3
            &xQuebra4
            nQtde4 := 0
            nSld4  := 0
            nSldPrc4 :=0
            lFirst4:= .T.
            Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2 .And. &cQuebra3 .And. &cQuebra4
               &xQuebra5
               nQtde5 := 0
               nSld5  := 0
               nSldPrc5:=5
               lFirst5:= .T.
               Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2 .And. &cQuebra3 .And. &cQuebra4 .And. &cQuebra5
                  &xQuebra6
                  nQtde6 := 0
                  nSld6  := 0
                  nSldPrc6:=0
                  lFirst6:= .T.
                  Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2 .And. &cQuebra3 .And. &cQuebra4 .And. &cQuebra5 .And. &cQuebra6
                     &xQuebra7
                     nQtde7 := 0
                     nSld7  := 0
                     nSldPrc7:=0
                     lFirst7:= .T.

                     Do While !(TRB->(Eof())) .And. &cQuebra1 .And. &cQuebra2 .And. &cQuebra3 .And. &cQuebra4 .And. &cQuebra5 .And. &cQuebra6 .And. &cQuebra7

                        IncProc(STR0005) // Atualiza barra de progresso

                        If nLinha >= 2100
                           COMECA_PAGINA
                        EndIf
                  
                        If cTipo == STR0015      // Analitico
                           DA150TITULO()
                           xx:="{|| "+cLinDet+"}"
                           bLinDet:=&xx
                           oPrn:Say( nLinha, nColIni+50, Eval(bLinDet), COURIER_NEW_08)
                           nLinha := nLinha+40
                           If !Empty(TRB->DESCRI)
                              oPrn:Say( nLinha, nColIni+50, TRB->DESCRI , COURIER_NEW_08)
                              nLinha := nLinha+40
                           EndIf
                        EndIf

                        DA150SOMA()
                        TRB->(dbSkip())
                     EndDo

                     DA150TOTALIZA(7)      // Analitico
                  EndDo
                  DA150TOTALIZA(6)      // Analitico
               EndDo
               DA150TOTALIZA(5)      // Analitico
            EndDo
            DA150TOTALIZA(4)      // Analitico
         EndDo
         DA150TOTALIZA(3)      // Analitico
      EndDo
      DA150TOTALIZA(2)      // Analitico
   EndDo
   DA150TOTALIZA(1)      // Analitico
EndDo
DA150TOTALIZA(9)

AVENDPAGE

oSend(oFont1,"End")
oSend(oFont2,"End")

AVENDPRINT

Return .T.


*-------------------*
Function DA150Cabec()
*-------------------*

If nPagina > 1
			AVNEWPAGE
EndIf

TRACO_NORMAL 
nLinha := nLinha+50   
oPrn:Say( nLinha, 2800, STR0006+StrZero(nPagina, 3), COURIER_NEW_08)
oPrn:Say( nLinha, 0150, STR0025+Time(), COURIER_NEW_08, , , , 2)
nLinha := nLinha+30

oPrn:Say( nLinha, 1550, STR0004, COURIER_NEW_10, , , , 2)
oPrn:Say( nLinha, 2800, STR0026+TRANS(Date(),"@E"), COURIER_NEW_08) 
nLinha := nLinha+80

oPrn:Say( nLinha, 1550, cParam, COURIER_NEW_08, , , , 2)
nLinha := nLinha+50

TRACO_NORMAL

nLinha := nLinha+20
TRACO_NORMAL
nLinha := nLinha+20

oPrn:Say( nLinha, nColIni+50, cLinCab, COURIER_NEW_08)

nLinha := nLinha+50

TRACO_NORMAL

nLinha := nLinha+10

RETURN NIL

*----------------------*
Function DA150Detalhe()
*----------------------*
Local nA, cQuebra := "", cLinha := "", xValor
Local nSpaceCab   := nSpaceDet := 1

Local aImprime := { ;
			{ ""    , "PO_NUM" , "Ped.Nacionali."      , "TransForm( PO_NUM, AVSX3('W2_PO_NUM' , 6))"  },;
			{STR0008, "VENCDA" , AVSX3("W2_VENCDA" , 5), "DTOC(VENCDA)"                                },;
			{STR0009, "COD_I"  , AVSX3("W3_COD_I"  , 5), "COD_I"                                       },;
			{ ""    , "HAWB_DA", AVSX3("W2_HAWB_DA", 5), "HAWB_DA"                                     },;
			{STR0007, "ARMAZEM", AVSX3("W2_ARMAZEM", 5), "ARMAZEM"                                     },;
			{STR0010, "FORNEC" , AVSX3("W3_FORN"   , 5), "FORNEC"                                      },;
			{STR0027, "PARTNUM", STR0027, "PARTNUM"                                      },;
			{STR0011, "IMPORT" , AVSX3("W2_IMPORT" , 5), "IMPORT"                                      },;
			{ ""    , "QTDE"   , AVSX3("W3_QTDE"   , 5), "TransForm( QTDE   , AVSX3('W3_QTDE'   , 6))" },;   // Não inverter a ordem das 
			{ ""    , "SALDO_Q", AVSX3("W3_SALDO_Q", 5), "TransForm( SALDO_Q, AVSX3('W3_SALDO_Q', 6))" },;   // colunas QTDE e Saldo
			{ ""    , "PRECO"  , "Preco Unitario"      , "TransForm( PRECO  , AVSX3('W3_PRECO'  , 6))" } ;
							}
IF EasyGParam("MV_LOTEEIC") $ cSim
   AADD(aImprime,{"","LOTE",AVSX3("WV_LOTE",5),"LOTE"})
ENDIF
//SVG - 13/08/08
AADD(aImprime,{"","SLDXPRC","Sld Q.xPrc.","Transform(SLDXPRC, '@E 9,999,999.99' )"})

cLinCab  := ""
cLinDet  := ""
For nA := 1 To Len(aCombo)
    If aCombo[nA] # STR0014 // Sem Quebra
       cCombo := "cCombo"+StrZero(nA,1)
       cCombo := &cCombo                                 
       nScan  := Ascan(aImprime, {|x| x[1] == cCombo})       
       If cCombo # STR0014 .AND. nScan # 0 // Sem Quebra
			
          cLinha  := aImprime[nScan, 4]
          If "TRANS"$cLinha .OR. "CTOD"$cLinha
              cLinha := Eval("{|| "+cLinha+"}") + Space(01)
          Else
              cLinha := &cLinha + Space(01)
          EndIf
          xValor  := aImprime[nScan, 2]
          xValor  := &xValor
			
          aImprime[nScan,1] := "XX.XX"
          If Len(aImprime[nScan, 3]) > Len(cLinha)
             nSpaceCab := 1
             nSpaceDet := Len(aImprime[nScan, 3]) - Len(cLinha) + 2
          Else
             nSpaceCab := Len(cLinha) - Len(aImprime[nScan, 3]) + 1
             nSpaceDet := 2
          EndIf
			
          If ValType(xValor) == "N"
             cLinCab := cLinCab + Space(nSpaceCab-2)+ aImprime[nScan, 3]+Space(2)
          Else
             cLinCab := cLinCab + aImprime[nScan, 3]+Space(nSpaceCab)
          EndIf
          cLinDet := cLinDet + If(!Empty(cLinDet), "+", "")
          cLinDet := cLinDet + aImprime[nScan, 4]+"+Space("+AllTrim(Str(nSpaceDet))+")"
       EndIf
    EndIf
Next

For nA := 1 To Len(aImprime)
    If aImprime[nA,1] # "XX.XX"
       If aImprime[nA,2] == "QTDE"
          nPos_QTD := Len(cLinCab)
       ElseIf aImprime[nA,2] == "SALDO_Q"
          nPos_SLD := Len(cLinCab)
       EndIf

       cLinha  := aImprime[nA, 4]
       If "TRANS"$cLinha .OR. "CTOD"$cLinha
           cLinha := Eval("{|| "+cLinha+"}") + Space(01)
       Else
           cLinha := &cLinha + Space(01)
       EndIf

       xValor  := aImprime[nA, 2]
       xValor  := &xValor
       
       If Len(aImprime[nA, 3]) > Len(cLinha)
          nSpaceCab := 1
          nSpaceDet := Len(aImprime[nA, 3]) - Len(cLinha) + 2
       Else
          nSpaceCab := Len(cLinha) - Len(aImprime[nA, 3]) + 1
          nSpaceDet := 2
       EndIf

       If ValType(xValor) == "N"
          cLinCab := cLinCab + Space(nSpaceCab-2)+ aImprime[nA, 3]+Space(2)
       Else
          cLinCab := cLinCab + aImprime[nA, 3]+Space(nSpaceCab)
       EndIf
       cLinDet := cLinDet + If(!Empty(cLinDet), "+", "")
       cLinDet := cLinDet + aImprime[nA, 4]+"+Space("+AllTrim(Str(nSpaceDet))+")"
    EndIf
Next

For nA := 1 To Len(aCombo)
    If aCombo[nA] != STR0014
       cCombo   := "cCombo"+StrZero(nA,1)
       cCombo   := &cCombo
       cQuebra  := "cQuebra"+StrZero(nA,1)
       xQuebra  := "xQuebra"+StrZero(nA,1)
       nScan    := Ascan(aChave, {|x| x[1] == cCombo})
       If nScan > 0 .And. cCombo != STR0014
          &cQuebra := aChave[nScan,2] +" == xQueb"+StrZero(nA,1)
          &xQuebra := "xQueb"+StrZero(nA,1) + " := " + aChave[nScan,2]
       Else
          &cQuebra := ".T."
          &xQuebra := ".T."
       EndIf
    EndIf
Next
cParam  := ""
cParam  := cParam + STR0007+" == "+AllTrim(If(Empty(cArmazem), STR0022, cArmazem      ))+"  /  "  // "Armazem" # "Todos"
cParam  := cParam + STR0009+" == "+AllTrim(If(Empty(cCod_I)  , STR0022, cCod_I        ))+"  /  "
cParam  := cParam + STR0010+" == "+AllTrim(If(Empty(cForn)   , STR0022, cForn         ))+"  /  "
cParam  := cParam + STR0011+" == "+AllTrim(If(Empty(cImport) , STR0022, cImport       ))+"  /  "
cParam  := cParam + STR0012+" == "+AllTrim(If(Empty(dVencDe) , STR0022, Dtoc(dVencDe) ))+"  /  "
cParam  := cParam + STR0013+" == "+AllTrim(If(Empty(dVencAte), STR0022, Dtoc(dVencAte)))+"  /  "
cParam  := cParam + If(cTipo==STR0015,STR0015,STR0016)

Return(Nil)

*-------------------*
Function DA150Data()
*-------------------*
Local lRet := .T., cVar := ReadVar(), dConteudo := &(ReadVar())

If !Empty(dVencDe) .And. !Empty(dVencAte)
   If dVencDe > dVencAte
      Help("", 1, "AVG0000242")//MSGINFO(STR0023,STR0024)
      lRet := .F.
   EndIf
EndIf
Return(lRet)

*------------------------------*
Function DA150TOTALIZA(nQuebra)
*------------------------------*
Local cQuebra, cCombo, nQtde, nSaldo, cVarQueb, nScan ,nSldPrc

If nQuebra == 9
   cTexto := STR0021      // "TOTAL GERAL"
   cTexto := cTexto+Space(nPos_QTD-Len(cTexto))+TransForm( nTotQtd , AVSX3('W3_QTDE', 6))
   cTexto := cTexto+Space(2)+TransForm( nTotSld , AVSX3('W3_SALDO_Q', 6))
   cTexto := cTexto+Space(19)+TransForm( nSldxPrc , '@E 999,999,999.99') //SVG - 13/08/08   
   oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
Else
   cQuebra  := "cQuebra"+StrZero(nQuebra,1)
   cQuebra  := &cQuebra
   cCombo   := "cCombo"+StrZero(nQuebra,1)
   cCombo   := &cCombo
   nQtde    := "nQtde"+StrZero(nQuebra,1)
   nQtde    := &nQtde
   nSaldo   := "nSld"+StrZero(nQuebra,1)
   nSaldo   := &nSaldo
   nSldPrc :="nSldPrc"+StrZero(nQuebra,1)  //SVG - 13/08/08
   nSldPrc := &nSldPrc                     //SVG - 13/08/08
   cVarQueb := "cVarQueb"+StrZero(nQuebra,1)
   cVarQueb := &cVarQueb

   If cQuebra != ".T."
      cTexto := If(cTipo == STR0015, STR0019, "")// Analitico # Total
      cTexto := cTexto+If(!Empty(cTexto)," - "+cCombo, cCombo)+": "+cVarQueb
      cTexto := cTexto+Space(nPos_QTD-Len(cTexto))+TransForm( nQtde , AVSX3('W3_QTDE', 6))
      cTexto := cTexto+Space(2)+TransForm( nSaldo , AVSX3('W3_SALDO_Q', 6))
      cTexto := cTexto+Space(19)+TransForm( nSldPrc , '@E 999,999,999.99') //SVG - 13/08/08
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha := nLinha+40
      lTotal := .T.
   EndIf
EndIf
Return(Nil)

*-------------------*
Function DA150SOMA()
*-------------------*
nQtde1 += QTDE
nQtde2 += QTDE
nQtde3 += QTDE
nQtde4 += QTDE
nQtde5 += QTDE
nQtde6 += QTDE
nQtde7 += QTDE
nTotQtd+= QTDE

nSld1  += SALDO_Q
nSld2  += SALDO_Q
nSld3  += SALDO_Q
nSld4  += SALDO_Q
nSld5  += SALDO_Q
nSld6  += SALDO_Q
nSld7  += SALDO_Q
nTotSld+= SALDO_Q
//SVG - 13/08/08
nSldPrc1+=SLDXPRC
nSldPrc2+=SLDXPRC
nSldPrc3+=SLDXPRC
nSldPrc4+=SLDXPRC
nSldPrc5+=SLDXPRC
nSldPrc6+=SLDXPRC
nSldPrc7+=SLDXPRC
nSldxPrc+=SLDXPRC

nScan     := Ascan(aChave, {|x| x[1] == cCombo1})
cVarQueb1 := aChave[nScan, 2]
cVarQueb1 := If(cCombo1 == STR0014, "", &cVarQueb1)
nScan     := Ascan(aChave, {|x| x[1] == cCombo2})
cVarQueb2 := aChave[nScan, 2]
cVarQueb2 := If(cCombo2 == STR0014, "", &cVarQueb2)
nScan     := Ascan(aChave, {|x| x[1] == cCombo3})
cVarQueb3 := aChave[nScan, 2]
cVarQueb3 := If(cCombo3 == STR0014, "", &cVarQueb3)
nScan     := Ascan(aChave, {|x| x[1] == cCombo4})
cVarQueb4 := aChave[nScan, 2]
cVarQueb4 := If(cCombo4 == STR0014, "", &cVarQueb4)
nScan     := Ascan(aChave, {|x| x[1] == cCombo5})
cVarQueb5 := aChave[nScan, 2]
cVarQueb5 := If(cCombo5 == STR0014, "", &cVarQueb5)
nScan     := Ascan(aChave, {|x| x[1] == cCombo6})
cVarQueb6 := aChave[nScan, 2]
cVarQueb6 := If(cCombo5 == STR0014, "", &cVarQueb6)
nScan     := Ascan(aChave, {|x| x[1] == cCombo7})
cVarQueb7 := aChave[nScan, 2]
cVarQueb7 := If(cCombo7 == STR0014, "", &cVarQueb7)

Return(Nil)

*----------------------*
Function DA150TITULO()
*----------------------*
Local cCombo, cVarQueb, cTexto

If cTipo == STR0015 .And. lTotal      // Analitico
   nLinha := nLinha+40   
   lTotal := .F.
EndIf

If lFirst1
   If cCombo1 != STR0014
      cCombo   := cCombo1
      cVarQueb := cVarQueb1
      cTexto   := cCombo+": "+xQueb1
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst1  := .F.
EndIf

If lFirst2
   If cCombo2 != STR0014
      cCombo   := cCombo2
      cVarQueb := cVarQueb2
      cTexto   := cCombo+": "+xQueb2
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst2  := .F.
EndIf

If lFirst3
   If cCombo3 != STR0014
      cCombo   := cCombo3
      cVarQueb := cVarQueb3
      cTexto   := cCombo+": "+xQueb3
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst3  := .F.
EndIf

If lFirst4
   If cCombo4 != STR0014
      cCombo   := cCombo4
      cVarQueb := cVarQueb1
      cTexto   := cCombo+": "+xQueb4
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst4  := .F.
EndIf

If lFirst5
   If cCombo5 != STR0014
      cCombo   := cCombo5
      cVarQueb := cVarQueb5
      cTexto   := cCombo+": "+xQueb5
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst5  := .F.
EndIf

If lFirst6
   If cCombo6 != STR0014
      cCombo   := cCombo6
      cVarQueb := cVarQueb6
      cTexto   := cCombo+": "+xQueb6
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst6  := .F.
EndIf

If lFirst7
   If cCombo7 != STR0014
      cCombo   := cCombo7
      cVarQueb := cVarQueb7
      cTexto   := cCombo+": "+xQueb7
      oPrn:Say( nLinha, nColIni+50, cTexto, COURIER_NEW_08)
      nLinha   := nLinha+40
   EndIf
   lFirst7  := .F.
EndIf

Return(Nil)
*----------------------*
//LRS - 29/01/2016 - Function criada para contorno de um erro na consulta logica usando & em variaveis 
//String, ondena versão 12.1.7 não retorna nenhum resultado booleano, ocasionando um loop infinito na
// Rotina onde é montado quebras para o Relatorio
*----------------------*
Function DA150QUEBRA()
Local cTrue := ".T."

If cQuebra1 == cTrue
   cQuebra1 := ".T. == .T."
EndIF
if cQuebra2 == cTrue
   cQuebra2 := ".T. == .T."
EndIF
if cQuebra3 == cTrue
   cQuebra3 := ".T. == .T."
EndIF
if cQuebra4 == cTrue
   cQuebra4 := ".T. == .T."
EndIF
if cQuebra5 == cTrue
   cQuebra5 := ".T. == .T."
EndIF
if cQuebra6 == cTrue
   cQuebra6 := ".T. == .T."
EndIF
if cQuebra7 == cTrue
   cQuebra7 := ".T. == .T."
EndIF

Return Nil
