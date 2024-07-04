#INCLUDE "HSPAHM32.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM32  º Autor ³ Manoel             º Data ³  13/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atendimento de Solicitacoes de Produtos                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Robson Ramiro³07/07/04³      ³                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM32()                        
 Local bKeyF12 := SetKey(VK_F12, {|| FS_M32Fil()})
 
 Local aCores := {{"GAI->GAI_FLGATE == ' '", 'BR_VERDE'  },;
	            					{"GAI->GAI_FLGATE == '1'", 'BR_AMARELO'},;
	            					{"GAI->GAI_FLGATE == '0'", 'BR_VERMELHO'}}
	
                                        
 Private cFilM32 := ""
 Private cCadastro := STR0061  //"Atendimento a Solicitacao"
 Private aRotina := {	{OemtoAnsi(STR0062),	"axPesqui"   , 0, 1}, ; //"Pesquisar"
                   	 	{OemToAnsi(STR0063),	"HS_M32Ate()", 0, 4}, ; //"Atendimento"
             	       	{OemtoAnsi(STR0064),	"HS_M32Leg()", 0, 1} } //"Legenda"

             	       	
 DbSelectArea("GAI")
                 
 If FS_FilM32()
  mBrowse(06, 01, 22, 75, "GAI",,,,,, aCores)
  HS_DtvFilt("GAI")
 Endif
 
 SetKey(VK_F12, bKeyF12)  
Return(Nil)            	

Function HS_M32Ate()
 Local bKeyF4 := SetKey(VK_F4, {|| HS_LstLote()})
 Local bKeyF5 := SetKey(VK_F5, {|| HS_LProAlt()})
 Local _ni := 0, lHSALTDLD := ExistBlock("HSALTDLD")
 Local aArea := {}

 Private bCampo   := { |nCPO| Field(nCPO) }
 Define  FONT oFont NAME "Arial" BOLD

 aGets := {}  // matriz que contem os campos que vao receber digitacao na enchoice
 aTela := {}  // matriz que contem os campos que vao aparecer na enchoice

 SetPrvt("wVar")
 Private aTELA[0][0],aGETS[0], oCodBar
 Private AHEADER := {}, ACOLS := {}
 Private dHSDataLD := dDataBase
	Private nGaj_QAtend := 0, nGaj_QtdSol := 0, nGaj_QtdAte := 0, nGaj_ProSol := 0
	Private nGaj_DesPro := 0, nGaj_CodJus := 0, nGaj_Justif := 0, nGaj_LoteFo := 0
	Private nGaj_LoteCt := 0, nGaj_NumLot := 0, nGaj_DtVali := 0, nGaj_PerTro := 0
	Private nGaj_OriSol := 0, nGaj_ProAlt := 0, nGaj_DPrAlt := 0, nGaj_CodTes := 0
	Private nGAJ_CODCRM := 0, nGAJ_NOMMED := 0

 
 PRIVATE cCusMed := GetMv("MV_CUSMED"), lMV_ProdAlt := GetMV("MV_PRODALT")
 PRIVATE aRegSD3  := {}, oCodLote, cCodLote := Space(Len(SB8->B8_NUMLOTE) + Len(SB8->B8_LOTECTL))

 SetPrvt("NOPCE,NOPCG,NUSADO")
 SetPrvt("CTITULO")
 SetPrvt("NREG,NOPC")
 
aRotina := {{"", '', 0, 1},;    && Pesquisar
             {"", '', 0, 2},;    && Visualizar
             {"", '', 0, 3},;    && Incluir
             {"", '', 0, 4, 2},; && Alterar
             {"", '', 0, 5, 1} } && Excluir 

 nOpcE  := 4
 nOpcG  := 4
             
 DbSelectArea("GAI")
 RegToMemory("GAI",.F.)
 
	DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY")+GAI->GAI_REGATE)
 If GCY->GCY_TPALTA == "99"
  HS_MsgInf(STR0060,STR0014,STR0001) //"Atendimento ja foi cancelado","Atenção","Atendimento de Solicitacoes de Produtos"
  Return(.T.)
 EndIf 
 
	//HS_AheadM5()
	//HS_AcolsM5()
	//Usar HS_BDADOS
	
 
 If Len(aCols) == 0
  HS_MsgInf(STR0065,STR0014,STR0001) //"Solicitação invalida","Atenção","Atendimento a Solicitacoes de Produtos"
 Else
  If Len(aHeader) > 0 
   cTitulo       := OemToAnsi(STR0001) //"Atendimento de Solicitacoes de Produtos"
   cAliasEnchoice:= "GAI"
   cAliasGetd    := "GAJ"
   cAlias        := "GAJ"
  
   cGai_CodBar   := Space(17)
   nGai_QtdAde   := 1           
   nOpcaP        := 0
  
   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 42,80	of oMainWnd   
    If lHSALTDLD
     Execblock("HSALTDLD", .F., .F.)
    EndIf
                                     
    @ 104, 004 Say OemToAnsi(STR0010) OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"Quantidade"
    @ 102, 040 MSGet oQtdade var nGai_QtdAde Picture "@E 99,999.9999" Valid HS_VldM32(3) OF oDlg PIXEL COLOR CLR_BLACK
    
    @ 104, 097 Say OemToAnsi(STR0011) OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"Codigo de Barras"
    @ 102, 148 MSGet oCodBar var cGai_CodBar Valid HS_VldM32(2) Size 60, 10 OF oDlg PIXEL COLOR CLR_BLACK
                                         
    @ 104, 219 Say OemToAnsi(STR0076) OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"Lote"
    @ 102, 235 MSGet oCodLote var cCodLote When AllTrim(GetMV("MV_RASTRO")) == "S" Valid HS_VldM32(3) Size 60, 10 OF oDlg PIXEL COLOR CLR_BLACK
    
    aGets := {}
    aTela := {}             

    EnChoice("GAI", nReg, 4,,,,, {IIf(lHSALTDLD, 030, 015), 001, 100, 315},, 2,,,,,, .F.)
    oGetDados := MsGetDados():New(118, 001, 250, 315, 4,"HS_M32LINOK",, .T., .T.,{"GAJ_CODJUS","GAJ_CODCRM"},,, Len(aCols),,,,, oDlg)

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| nOpcAP := IIf(Obrigatorio(aGets, aTela) .And. FS_M32TOK(), 1, 0), IIf(nOpcaP == 1, oDlg:End(), .F.)}, ;
                                                             {|| nOpcAP := 0, oDlg:End()}))
  EndIf
 
  If  nOpcaP == 1
   HS_GrvM32()
   hspahr03(M->GAI_SOLICI)
  Endif
 EndIf
 
 SetKey(VK_F4, bKeyF4)
 SetKey(VK_F5, bKeyF5)
Return(Nil)
                                    
Function HS_GrvM32(lAutoM5)
 Local cHspPre := GetMv("MV_HSPPRE") // Codigo de Prestador do Hospital
 Local lParcial := .F., lTotal := .F., lNaoAtendida := .F.
 Local nSeqDes := "", nQtdSB2 := 0, cCodPMov := "", cDPrPMov := ""
 Local i := 0  
 Local nStatus := 0
 Local nQtAnt  := 0

	Default lAutoM5 := .F.

	If lAutoM5
		Private DHSDATALD := dDataBase
 	Private cCusMed 		:= GetMv("MV_CUSMED"), lMV_ProdAlt := GetMV("MV_PRODALT")
 	Private aRegSD3			:= {}, cCodLote := Space(Len(SB8->B8_NUMLOTE) + Len(SB8->B8_LOTECTL))
	Endif
 
 If nOpcG # 2 // nao e' consulta
  // Posiciona no Registro de Atendimento
  HS_SeekRet("GCY","GAI->GAI_REGATE",1,.f.)

  // Posiciona no Cadastro de Convênios
  HS_SeekRet("GA9","GCY->GCY_CODCON",1,.f.)
     	  
  // Posiciona no Leito
  HS_SeekRet("GAV","GCY->GCY_REGATE",2,.f.)

  For i:=1 to len(aCols)
   If aCols[i, nGaj_QAtend] > 0                   
    
    cCodPMov := PadR(AllTrim(aCols[i, IIf(lMV_ProdAlt .And. !Empty(aCols[i, nGaj_ProAlt]), nGaj_ProAlt, nGaj_ProSol)]), Len(SB1->B1_COD))
    cDPrPMov := aCols[i, IIf(lMV_ProdAlt .And. !Empty(aCols[i, nGaj_ProAlt]), nGaj_DPrAlt, nGaj_DesPro)]
   
    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek(xFilial("SB1") + cCodPMov)
		                             
				DbSelectArea("GBI")
    DbSetOrder(1)
    DbSeek(xFilial("GBI") + PadR(AllTrim(SB1->B1_COD), Len(GBI->GBI_PRODUT)))
    
    DbSelectArea("SB1")
   		 
    nQuant := aCols[i, nGaj_QAtend]

    If nQuant > 0
     DbSelectArea("SB2")
     DbSetOrder(1)
     If DbSeek(xFilial("SB2") + SB1->B1_COD + M->GAI_ALMORI)
      If M->GAI_REQUIS $ "34"
       nQtdSb2 := SB2->B2_QATU
      Else 
       nQtdSb2 := IIf(SB1->B1_CONV > 1, SB2->B2_QTSEGUM, SB2->B2_QATU)
      EndIf 
      
	     If nQtdSb2 < nQuant
	      HS_MsgInf(STR0012 + cCodPMov + " " + cDPrPMov + STR0013, STR0014,STR0001) //"O Produto "###" não tem Estoque Disponível e não será atendido nesta Solicitação!"###,"Atenção","Atendimento de Solicitacoes de Produtos"
      Else   
       DbSelectArea("GAJ")
       wProcura := DbSeek(xFilial("GAJ") + M->GAI_SOLICI + aCols[i,nGaj_ProSol])
	      RecLock("GAJ", IIf(wProcura, .F., .T.))
	       nSavRec := recno()
	       HS_GRVCPO("GAJ", aCols, aHeader, i) 
	       GAJ->GAJ_FILIAL := xFilial("GAJ")
	       GAJ->GAJ_SOLICI := M->GAI_SOLICI
	       GAJ->GAJ_MOVEST := "1" // Movimenta Estoque
	       GAJ->GAJ_LOGATE := HS_LogArq()
	      MsUnlock()       
			     
	      //Se o Requisitante For 1-Paciente
	      If GAI->GAI_REQUIS == '1'   
	       DbSelectArea("GAK")
   		   DbSetOrder(6)
		      If DbSeek(xFilial("GAK") + GAJ->GAJ_SEQDES + GAJ->GAJ_REGATE + GAJ->GAJ_PROSOL)
		      	nStatus := 4
			      nQtAnt  := GAK->GAK_QTDMAT	
		      Else    
		      	nStatus := 3
		      	nQtAnt  := 0
		      EndIf	
        
	       // So grava Itens que Movimentam Estoque
	       DbSelectArea("GO1")
   		   DbSetOrder(3)
		      If DbSeek(xFilial("GO1") + M->GAI_SOLICI + aCols[i, nGaj_OriSol] + aCols[i, nGaj_ProSol])
         HS_LDManut("P", nStatus, 2, {{"CODMAT", aCols[i, nGaj_ProSol], .T.},;
                            							    {"QTDMAT", nQuant + nQtAnt      , .F.},;
							                                {"DATMAT", dHSDataLD            , .F.},;
       							                         {"VALREA", GO1->GO1_VALUNI      , .F.},;
              							                  {"SOLICI", M->GAI_SOLICI        , .F.},;
                     							           {"CODPRE", cHspPre              , .F.},;
                            							    {"FLGDCI", M->GAI_FLGDCI        , .F.},;
							                                {"DSPBER", M->GAI_DSPBER        , .F.}}, .T., @nSeqDes, .T.)
        Else                                                                 
     		  HS_LDManut("P", nStatus, 2, {{"CODMAT", aCols[i, nGaj_ProSol], .T.},;
							                                {"QTDMAT", nQuant + nQtAnt      , .F.},;
       							                         {"DATMAT", dHSDataLD            , .F.},;
              							                  {"SOLICI", M->GAI_SOLICI        , .F.},;
                     							           {"CODPRE", cHspPre              , .F.},;
                            							    {"FLGDCI", M->GAI_FLGDCI        , .F.},;
							                                {"DSPBER", M->GAI_DSPBER        , .F.}}, .T., @nSeqDes, .T.)
        EndIf    

        DbSelectArea("GAJ")	              
	       DbGoto(nSavRec)
	       RecLock("GAJ",.F.)
	       GAJ->GAJ_SEQDES := nSeqDes
        MsUnlock()
	      Endif
       
       If GAI->GAI_REQUIS $ "12" .And. !Empty(GAI->GAI_REGATE)
	       //Se For Antibiótico... Grava Dados para o CCIH
        DBSelectArea("GA0")
        DBSetOrder(1)
        DBSeek(xFilial("GA0") + GBI->GBI_FARMAC)
        If Found()
         If GA0->GA0_ANTIB == '1'
          DBSelectArea('GBV')
          DBSetOrder(1)
          DBSeek(xFilial("GBV") + GAI->GAI_REGATE + aCols[i, nGaj_ProSol] + GAI->GAI_CODCCU + Dtos(GAI->GAI_DATSOL) + "1")
          If !Found()
           RecLock("GBV",.T.)
	           GBV->GBV_FILIAL := xFilial("GBV")
	           GBV->GBV_REGATE := GAI->GAI_REGATE
	           GBV->GBV_CODANT := aCols[i, nGaj_ProSol]
	           GBV->GBV_CODCCU := GAI->GAI_CODCCU    
	           GBV->GBV_QUANT  := nQuant
	           GBV->GBV_DATANT := GAI->GAI_DATSOL
	           GBV->GBV_LOGARQ := HS_LogArq()
	           MSUnlock()
	          Else
	           RecLock("GBV",.F.)
	            GBV->GBV_QUANT  := GBV->GBV_QUANT + nQuant
	            GBV->GBV_DATANT := GAI->GAI_DATSOL
	            GBV->GBV_LOGARQ := HS_LogArq()
	           MSUnlock()
	         Endif   
         Endif
        Endif
       EndIf
       	         
   	   If     GAI->GAI_REQUIS == "4" // Transferencia entre armazens
  	     a260Processa(cCodPMov, M->GAI_ALMORI, nQuant, "", dDataBase, HS_UnCons(cCodPMov, nQuant), ;
                     aCols[i, nGaj_NumLot], aCols[i, nGaj_LoteCt], aCols[i, nGaj_DtVali], SB1->B1_SERIE, SB1->B1_LOCPAD, ;
       	             cCodPMov, M->GAI_ALMSOL, SB1->B1_LOCPAD, .F.,,, "MATA260")
	      ElseIf GAI->GAI_REQUIS == "3" // Transferencia pra centro de custo consumo próprio                                                                                               
 	      HS_MovEst("C", cCodPMov, nQuant, M->GAI_ALMORI, STR0015 + M->GAI_SOLICI, GAI->GAI_CODCCU, "", aCols[i, nGaj_NumLot], aCols[i, nGaj_LoteCt], aCols[i, nGaj_DtVali])
	      Else
        HS_MovEst("S", cCodPMov, nQuant, M->GAI_ALMORI, STR0015 + M->GAI_SOLICI, GAI->GAI_CODCCU, "", aCols[i, nGaj_NumLot], aCols[i, nGaj_LoteCt], aCols[i, nGaj_DtVali])
	      EndIf
	     EndIf 
	    Else
	     HS_MsgInf(STR0037 + SB1->B1_COD + " - " + Alltrim(SB1->B1_DESC) + STR0038, STR0014,STR0001)  //"Não existe cadastro do Produto "###" no SB2","Atenção","Atendimento de Solicitacoes de Produtos"
	    Endif    
	   Endif
   EndIf
   
   If     (aCols[i, nGaj_QtdSol] > aCols[i, nGaj_QtdAte]) .And. (aCols[i, nGaj_QtdAte] > 0)
    lParcial     := .T.
   ElseIf (aCols[i, nGaj_QtdSol] <= aCols[i, nGaj_QtdAte])
    lTotal       := .T.
   ElseIf (aCols[i, nGaj_QtdAte] == 0)
    lNaoAtendida := .T.
   EndIf
  Next           
  
  If     lNaoAtendida .And. !lParcial .And. !lTotal   
   M->GAI_FLGATE := " " // Não Atendida
  ElseIf lTotal .And. !lParcial .And. !lNaoAtendida
   M->GAI_FLGATE := "0" // Atendimento Total          
  Else
   M->GAI_FLGATE := "1" // Atendimento Parcial
  EndIf
     
  DbSelectArea("GAI")
  If dbseek(xFilial("GAI") + M->GAI_SOLICI)
   RecLock("GAI",.F.)
    HS_GRVCPO("GAI")
    GAI->GAI_FILIAL := xFilial("GAI")
    GAI->GAI_LOGARQ := HS_LogArq()
    ConfirmSX8()
   MsUnLock()
  Endif           
                                    
  // Caso a solicitação ja tenha sido atendida pela farmacia e possua registro de atendimento 
  // e requisitada para centro de custo, grava arquivo de solicitações pendentes
  If M->GAI_FLGATE $ "01" .And. !Empty(M->GAI_REGATE) .And. M->GAI_REQUIS == "2"
   DbSelectArea("GCL")
   If !DbSeek(xFilial("GCL") + M->GAI_SOLICI)
    RecLock("GCL", .T.)
    GCL->GCL_FILIAL := xFilial("GCL")
    GCL->GCL_SOLICI := M->GAI_SOLICI
    GCL->GCL_REGATE := M->GAI_REGATE
    GCL->GCL_NOMPAC := M->GAI_NOMPAC
    GCL->GCL_CODCCU := M->GAI_CODCCU
    GCL->GCL_DATSOL := M->GAI_DATSOL
    GCL->GCL_FLGPOS := "0" 
    MsUnLock()
   EndIf 
   DbSelectArea("GAI")
  EndIf
 Endif   
Return(.T.)

/////////////////////////
Static Function HS_VldM32(cVar)
 Local cCodPro := ""
 
 If cVar == 2 // Codigo de Barras do Produto
  If Empty(cGai_CodBar)
   Return(.T.)
  EndIf
  	                 
  IF SUBSTR(cGai_CodBar,1,3)=="170"
   HS_MsgInf(STR0018, STR0014,STR0077) //"UCC-128: Identificador de Aplicação (AI) inválido"###"Atenção" //"Codigo de Barras do Produto"
   Return(.F.)
  ENDIF
	
  IF SUBSTR(cGai_CodBar,1,3)=="010"
   cGai_CodBar := SUBSTR(cGai_CodBar, 4, 13)
  ELSE
   cGai_CodBar := SUBSTR(cGai_CodBar, 1, 13)
  ENDIF                  
  
  DBSelectArea("SB1")
  DBSetOrder(5)
  DBSeek(xFilial("SB1") + cGai_CodBar)
  If !Found()
   DBSelectArea("GAP")
   DBSetOrder(1)
   DBSeek(xFilial("GAP")+cGai_CodBar)
   If !Found()
    HS_MsgInf(STR0019,STR0014,STR0077) //"Não existe produto com este Código de Barras!"###"Atenção" //"Codigo de Barras do Produto"
    Return(.F.)
   Else
    cCodPro := PadR(AllTrim(GAP->GAP_CODIGO), Len(SB1->B1_COD))
   Endif
  Else
   cCodPro := SB1->B1_COD
  Endif

  If !FS_VldProd(cCodPro, "P")
   Return(.F.)
  EndIf
  
  cGai_CodBar := Space(17)
  oGetDados:oBrowse:Refresh()
  oCodBar:Refresh()
  Return(.F.) // Para manter o fóco no campo do código de barras
 ElseIf cVar == 3 // Validação do Lote
  If Empty(cCodLote)
   Return(.T.)
  EndIf
  
  DbSelectArea("SB8")
  DbSetOrder(2)
  If !DbSeek(xFilial("SB8") + cCodLote)
   HS_MsgInf(STR0066, STR0014,STR0077) //"Atenção" //"Lote invalido" //"Codigo de Barras do Produto"
   Return(.F.)
  EndIf
  
  DbSelectArea("SB1")
  DbSetOrder(1)
  If !DbSeek(xFilial("SB1") + SB8->B8_PRODUTO)
   HS_MsgInf(STR0048 + SB8->B8_PRODUTO + STR0067 + cCodLote + STR0068, STR0014,STR0077) //"Atenção" //"Produto "###" contido no lote "###" não foi encontrado no cadastro de produtos (SB1)" //"Codigo de Barras do Produto"
   Return(.F.)
  EndIf
  	                 
  If !FS_VldProd(SB8->B8_PRODUTO, "L")
   Return(.F.)
  EndIf 
  
  cCodLote := Space(Len(SB8->B8_NUMLOTE) + Len(SB8->B8_LOTECTL))
  oGetDados:oBrowse:Refresh()
  oCodLote:Refresh()
  Return(.F.) // Para manter o fóco no campo do código de barras do lote
 ElseIf cVar == 4 // Validação e Descrição do Almoxarifado
  If Empty(M->GAI_ALMORI)
   HS_MsgInf(STR0044,STR0014,STR0077) //"O Almoxarifado é Obrigatório !"###"Atenção" //"Codigo de Barras do Produto"
   Return .f.                              
  EndIf
    
  If HS_SeekRet("SX5","'AL'+M->GAI_ALMORI",1,.f.,,,.t.) .and. !Empty(M->GAI_ALMORI)
   HS_MsgInf(STR0045,STR0014,STR0077) //"Código de Almoxarifado Inválido!"###"Atenção" //"Codigo de Barras do Produto"
   Return(.F.)
  Endif
          
  If !Empty(M->GAI_ALMORI)
   M->GAI_DESALM := SX5->X5_DESCRI
  Else
   M->GAI_DESALM := Space(55)
  Endif     
 Endif
Return(.T.)

Static Function FS_M32TOK()
 Local lRet := .T., nItem := 0
 Local cCodPMov := ""
 
 If AllTrim(GetMV("MV_RASTRO")) # "S"
  Return(.T.)
 EndIf 
 
 For nItem := 1 To Len(aCols) 
  If aCols[nItem, nGaj_QAtend] > 0  
   cCodPMov := aCols[nItem, IIf(lMV_ProdAlt .And. !Empty(aCols[nItem, nGaj_ProAlt]), nGaj_ProAlt, nGaj_ProSol)]
   If Rastro(cCodPMov)
    If     !Empty(AllTrim(aCols[nItem, nGaj_LoteFo]))
     lRet := HS_VldLote(PadR(AllTrim(aCols[nItem, nGaj_LoteFo]), Len(SB8->B8_LOTEFOR)) + ;
                        PadR(AllTrim(cCodPMov)                 , Len(SB8->B8_PRODUTO)) + ;
                        PadR(AllTrim(M->GAI_ALMORI            ), Len(SB8->B8_LOCAL  )), 4, ;
                        STR0048 + AllTrim(cCodPMov) + STR0049)[1] //"Produto "###", Código do Lote do fornecedor invalido"
    ElseIf !Empty(AllTrim(aCols[nItem, nGaj_LoteCt]))
     lRet := HS_VldLote(PadR(AllTrim(cCodPMov)                 , Len(SB8->B8_PRODUTO)) + ;
                        PadR(AllTrim(M->GAI_ALMORI            ), Len(SB8->B8_LOCAL  )) + ;
                        PadR(AllTrim(aCols[nItem, nGaj_LoteCt]), Len(SB8->B8_LOTECTL)), 3, ;
                        STR0050 + AllTrim(cCodPMov) + STR0051)[1] //"Código do Lote do produto "###", invalido"
    Else 
     HS_MsgInf(STR0052 + AllTrim(cCodPMov) + STR0053, STR0014,STR0077) //"Lote do Produto "###", não foi informado" //"Codigo de Barras do Produto"
     lRet := .F.
    EndIf                      
   EndIf
  
   If !lRet
    Exit
   EndIf
  EndIf 
 Next
Return(lRet)             


Function FS_M32COK()
 Local lRet := .T., aRet := {}
 Local cCodPMov := aCols[n, IIf(lMV_ProdAlt .And. !Empty(aCols[n, nGaj_ProAlt]), nGaj_ProAlt, nGaj_ProSol)]
 
 If !Rastro(aCols[cCodPMov])
  Return(.T.)
 EndIf 
 
 If     ReadVar() == "M->GAJ_LOTEFO"
  aRet := HS_VldLote(PadR(AllTrim(M->GAJ_LOTEFO), Len(SB8->B8_LOTEFOR)) + ;
                     PadR(AllTrim(cCodPMov     ), Len(SB8->B8_PRODUTO)) + ;
                     PadR(AllTrim(M->GAI_ALMORI), Len(SB8->B8_LOCAL  )), 4)
 ElseIf ReadVar() == "M->GAJ_LOTECT"
  aRet := HS_VldLote(PadR(AllTrim(cCodPMov     ), Len(SB8->B8_PRODUTO)) + ;
                     PadR(AllTrim(M->GAI_ALMORI), Len(SB8->B8_LOCAL  )) + ;
                     PadR(AllTrim(M->GAJ_LOTECT), Len(SB8->B8_LOTECTL)), 3)
 EndIf 
 
 If Len(aRet) > 0
  lRet := aRet[1]
  If     lRet .And. ReadVar() == "M->GAJ_LOTEFO"
   aCols[n, nGaj_NumLot] := aRet[2]
   aCols[n, nGaj_LoteCt] := aRet[4]
   aCols[n, nGaj_DtVali] := aRet[5]
  ElseIf lRet .And. ReadVar() == "M->GAJ_LOTECT"
   aCols[n, nGaj_NumLot] := aRet[2]
   aCols[n, nGaj_LoteFo] := aRet[3]
   aCols[n, nGaj_DtVali] := aRet[5] 
  EndIf                                     
 EndIf 
Return(lRet)

Function HS_M32Leg()
 BrwLegenda(cCadastro, STR0064, {{"BR_VERDE"   , STR0073}, ; //"Legenda"###"Não Atendida"
                                 {"BR_AMARELO" , STR0074}, ; //"Atendimento Parcial (Farmacia)"
                                 {"BR_VERMELHO", STR0075}})  //"Atendimento Total (Farmacia)"
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_M32LINOK ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 12.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M32LINOK                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M32LINOK

Local nPosDel		:= Len(aHeader) + 1
Local nPosCODCRM	:= aScan(aHeader, { |x| AllTrim(x[2]) == "GAJ_CODCRM" })
Local nPosPROSOL	:= aScan(aHeader, { |x| AllTrim(x[2]) == "GAJ_PROSOL" })
Local lRetorno		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o CRM foi preenchido          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosCODCRM]) .and. !aCols[n, nPosDel]
 GBI->(DbSetOrder(1))
 If GBI->(DbSeek(xFilial("GBI") + aCols[n, nPosPROSOL]))
  If GBI->GBI_CTRPSC$"0_1"
   lRetorno := .F.
	 HS_MsgInf(STR0059,STR0014,STR0078) //"Medicamento controlado, necessario informar o medico!" //"Atenção"###"Consistencia para mudanca/inclusao de linha"
  Endif
 Endif
Endif

Return lRetorno

Static Function FS_FilM32()
 Local lRet := .F., cAliasOld := Alias()
         
 DbSelectArea("GAI")
 
 FS_Sx1M32("HSPM32")
 
 If (lRet := Pergunte("HSPM32"))
  If MV_PAR01 == 1
   cFilM32 := "GAI->GAI_FLGATE $ '1/0'"
  ElseIf MV_PAR01 == 2
   cFilM32 := "GAI->GAI_FLGATE $ ' '"
  Else
   cFilM32 := "GAI->GAI_FLGATE $ ' /1/0'"
  Endif
 
  HS_AtvFilt("GAI", cFilM32)

  DbSeek(xFilial("GAI"))
 EndIf                                                                  
 
 DbSelectArea(cAliasOld)
Return(lRet)      

Static Function FS_Sx1M32(cPerg)                                       
 Local aHelpPor := {}
 Local aHelpSpa := {}
 Local aHelpEng := {}
 Local aPergs   := {}

 aHelpPor := {STR0079} //"Selecione o tipo de atendimento"
 aHelpSpa := {STR0079} //"Selecione o tipo de atendimento"
 aHelpEng := {STR0079} //"Selecione o tipo de atendimento"
 AADD(aPergs,{STR0080   , STR0080   , STR0080 ,"mv_ch1","N",1,0,0,"C","","mv_par01",STR0081,STR0081,STR0081,"","",STR0082,STR0082,STR0082,"","",STR0083,STR0083,STR0083,"","","","","","","","","","","","","N","","",aHelpPor,aHelpEng,aHelpSpa}) //"Solicitacoes"###"Solicitacoes"###"Solicitacoes"###"Atendidas"###"Atendidas"###"Atendidas"###"Nao Atendidas"###"Nao Atendidas"###"Nao Atendidas"###"Todas"###"Todas"###"Todas"
 
 AjustaSx1(cPerg, aPergs)
Return(Nil)