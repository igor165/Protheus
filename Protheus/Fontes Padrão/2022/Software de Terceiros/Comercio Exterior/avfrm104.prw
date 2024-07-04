#INCLUDE "Protheus.ch"
#INCLUDE "EEC.ch"
#INCLUDE "AVFRM104.CH"
#Define AV_FOLDER 15

#Define ITRECEBIDOS   "A"
#Define ITENVIADOS    "B"
#Define ITNAOENVIADOS "C"
#Define ITPROCESSADOS "D"
#Define ITBUSCA       "E"

*----------------------------------------------------------*
Function Frm104SolInt(cAction, cService, cEmbarque, cOpcao)
*----------------------------------------------------------*
Local lRet := .F., nInc
Local cMark := "", nMarks := 0
Local lContinua := .T.
Private cPreemb := cEmbarque
Private cDtS6H4    := "", cDtS8H4   := "", cPtOriLC   := "", cPtOriNM   := "", cPtOriETD  := "",;
        cLcOriLC   := "", cLcOriNM  := "", cLcOriETD  := "", cLcOriReti := "", cPtDesLC   := "", cPtDesNM   := "",;
        cPtDesETA  := "", cLcDesLC  := "", cLcDesNM   := "", cLcDesETA  := "", cNvNome    := "", cNvViagem  := "",;
        cCodMoeISO := "", cLCDtVen  := "", cLcFreLC   := "", cLcFreNM   := "", cDespCodIn := "", cFFref     := "",;
        cVolume    := "", cPesoBRKG := "", cTotEmb    := "", cTotCon    := ""
        

//Parties        
Private cContRespN := "", cContRespT 	:= "", cContRespV	:= "", cPushNT  	:= "", cPushNV  	:= "",;
        cPartID	   := "", cPartName1	:= "",                     cPartEnd1	:= "", cPartEnd2	:= "", cPartEnd3	:= "", cPartEnd4	:= "", cContPartN	:= "", cContPartT	:= "", cContPartV	:= "",;
        cConsID    := "", cConsName1	:= "", cConsName2	:= "", cConsEnd1	:= "", cConsEnd2	:= "", cConsEnd3	:= "", cConsEnd4	:= "", cConsPartN	:= "", cConsPartT	:= "", cConsPartV	:= "",;
        cNot1ID	   := "", cNot1Name1	:= "", cNot1Name2	:= "", cNot1End1	:= "", cNot1End2	:= "", cNot1End3	:= "", cNot1End4	:= "", cNot1PartN	:= "", cNot1PartT	:= "", cNot1PartV	:= "",;
        cNot2ID	   := "", cNot2Name1	:= "", cNot2Name2	:= "", cNot2End1	:= "", cNot2End2	:= "", cNot2End3	:= "", cNot2End4	:= "", cNot2PartN	:= "", cNot2PartT	:= "", cNot2PartV	:= "",;
        cNot3ID	   := "", cNot3Name1	:= "", cNot3Name2	:= "", cNot3End1	:= "", cNot3End2	:= "", cNot3End3	:= "", cNot3End4	:= "", cNot3PartN	:= "", cNot3PartT	:= "", cNot3PartV	:= "",;
        cArmID	   := "", cArmName1	    := "", cContArm     := "", cFFName1		:= "", cFFEnd1		:= "", cFFEnd2		:= "", cFFEnd3		:= "", cFFEnd4		:= "", cFFPartN		:= "", cFFPartT		:= "",;
        cFFPartV   := "", cContFF       := "", cPartID_     := "", cPartName1_	:= "", cPartEnd1_	:= "", cPartEnd2_	:= "", cPartEnd3_	:= "", cPartEnd4_	:= "", cContPartN_	:= "", cContPartT_	:= "",;
        cContPartV_	:= "", cEnum_HlgArr := "", cMdlFrete    := "", cCrtFrete    := ""        

Private cChargeType := ""

Private cTipoBl := "", cImpFre := "", cQtdBl := "", cQtdBlC := "", lInfoSI := .F.
Private aMarks := {}
     
//Verificar variáveis não mais utilizadas para notify
Private aContainer := {}, aInvoices := {}, aPedidos := {}, aEmbalagens := {}, aDetContainer := {}, aPackages := {}, aSICont := {}
Private cXml_BK := ""
Begin Sequence
   
   cPreemb := AvKey(cPreemb, "EEC_PREEMB")
   
   If cService == "SI"
      If Len(aSiCont := Frm102SICont(cPreemb, cSeqSI, cOpcao)) == 0
         MsgInfo(STR0002,STR0001)
         Break
      EndIf
   EndIf

   //Posiciona no embarque informado
   If EEC->EEC_PREEMB <> cPreemb
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial()+cPreemb))
   EndIf

   //Posiciona a tabela de complementos do embarque
   If EXL->EXL_PREEMB <> cPreemb
      EXL->(DbSetOrder(1))
      EXL->(DbSeek(xFilial()+cPreemb))
   EndIf
   
   //Monta a data no formato AAMMDDHHMM
   cDtS6H4 := Right(DToS(dDatabase), 6) + Left(StrTran(Time(), ":", ""), 4)
   cDtS8H4 := DToS(dDatabase)			+ Left(StrTran(Time(), ":", ""), 4)
   
   //Carrega os participantes do processo
   GetParties()
   
   //Busca o código ISO da moeda
   SYF->(DbSetOrder(1))
   If SYF->(DbSeek(xFilial()+EEC->EEC_MOEDA))
      cCodMoeISO := AllTrim(SYF->YF_ISO)
   EndIf
   
   //Caso tenha carta de crédito, busca a data de vencimento
   EEL->(DbSetOrder(1))
   If !Empty(EEC->EEC_LC_NUM) .And. EEL->(DbSeek(xFilial()+EEC->EEC_LC_NUM))
      cLCDtVen := DToSEEL->EEL_DT_VEN
   EndIf
   
   //*** Informações referentes às localidades
   //Porto de origem
   SY9->(DbSetOrder(2))
   SY9->(DbSeek(xFilial("SY9")+EEC->EEC_ORIGEM))
   cPtOriLC  := AllTrim(SY9->Y9_UNCODE)
   cPtOriNM  := AllTrim(SY9->Y9_DESCR)
   cPtOriETD := DTOS(EEC->EEC_ETD)

   //Local de Retirada
   If !Empty(EXL->EXL_LOCREC) .And. !(EXL->EXL_TIPMOV $ "1/3")
      SY9->(DbSetOrder(2))
      SY9->(DbSeek(xFilial("SY9")+EXL->EXL_LOCREC))
      cLcOriLC  := AllTrim(SY9->Y9_UNCODE)
      cLcOriNM  := AllTrim(SY9->Y9_DESCR)
      cLcOriETD := DTOS(EXL->EXL_ETDORI)
      cLcOriReti := DTOS(EXL->EXL_DTRETI)
   ElseIf EXL->EXL_TIPMOV $ "1/3"
      //Local de retirada é o porto
      cLcOriLC  := cPtOriLC
      cLcOriNM  := cPtOriNM
      cLcOriETD := cPtOriETD
   EndIf
   
   //Porto de Destino
   SY9->(DbSetOrder(2))
   SY9->(DbSeek(xFilial("SY9")+EEC->EEC_DEST))
   cPtDesLC  := AllTrim(SY9->Y9_UNCODE)
   cPtDesNM  := AllTrim(SY9->Y9_DESCR)
   cPtDesETA := DTOS(EEC->EEC_ETADES)
   
   //Local de Destino
   If !Empty(EXL->EXL_LOCENT) .And. !(EXL->EXL_TIPMOV $ "1/2")
      SY9->(DbSetOrder(2))
      SY9->(DbSeek(xFilial("SY9")+EXL->EXL_LOCENT))
      cLcDesLC   := AllTrim(SY9->Y9_UNCODE)
      cLcDesNM   := AllTrim(SY9->Y9_DESCR)
      cLcDesETA  := DTOS(EEC->EEC_ETADES)
   ElseIf EXL->EXL_TIPMOV $ "1/2"
      //Local de destino é o porto de destino
      cLcDesLC   := cPtDesLC
      cLcDesNM   := cPtDesNM
      cLcDesETA  := cPtDesETA
   EndIf

   //Local de pagamento do frete
   If !Empty(EXL->EXL_LOCFRE)
      SY9->(DbSetOrder(2))
      SY9->(DbSeek(xFilial("SY9")+EXL->EXL_LOCFRE))
      cLcFreLC   := AllTrim(SY9->Y9_UNCODE)
      cLcFreNM   := AllTrim(SY9->Y9_DESCR)
   EndIf
   //***
        
   //Busca de informações embarcação
   If !Empty(EEC->EEC_EMBARC)
      cNvViagem := AllTrim(Left(EEC->EEC_VIAGEM,35))
      EE6->(DbSetOrder(1))
      If EE6->(DbSeek(xFilial("EE6")+AvKey(EEC->EEC_EMBARC,"EE6_COD")))
         cNvNome := AllTrim(Left(EE6->EE6_NOME,35))
      EndIf 
   ElseIf Empty(EEC->EEC_VIAGEM) .and. !Empty(EEC->EEC_EMBARC)
      cNvViagem := AllTrim(Left(EE6->EE6_VIAGEM,35))
   EndIf  
   
   //Busca as invoices do processo
   EXP->(DbSetOrder(1))
   EXP->(DbSeek(xFilial("EXP")+EEC->EEC_PREEMB))
   While EXP->(EXP->(!EOF() .And. EXP_FILIAL+EXP_PREEMB == xFilial()+EEC->EEC_PREEMB))
      aAdd(aInvoices, AllTrim(Left(EXP->EXP_NRINVO,35)))
      EXP->(DbSkip())
   EndDo
   
   aPedidos := DetPedidos(EEC->EEC_PREEMB)
   cTotCon := Str(TotEquipment(EEC->EEC_PREEMB))
   cTotEmb := Str(TotPackages(EEC->EEC_PREEMB))
   If cService == "BK"
      aEmbalagens := DetPackages(EEC->EEC_PREEMB)
      aDetContainer := DetBkEquipment(EEC->EEC_PREEMB)
      If Len(aDetContainer) == 0
         MsgInfo(STR0003, STR0001)
         Break
      EndIf
   Else
      aPackages := AvSiPackages(EEC->EEC_PREEMB)
   EndIf
   
   //Informações do BL   
   cImpFre := If(EXL->EXL_IMPFRE=="1", "True", "False")
   EX9->(DbSetOrder(1))
   For nInc := Len(aSICont) To 1 Step -1 
      If EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB+aSICont[nInc]))
         If !lInfoSI .And. (EX9->EX9_INFOSI $ cSim .Or. nInc == 1)
            lInfoSI  := .T.
            cTipoBl  := If(EX9->EX9_TIPOBL == "1", "BillOfLadingOriginal", "SeaWayBill")
            cQtdBl   := Str(EX9->EX9_QTDBL)
            cQtdBlC  := Str(EX9->EX9_QTDBLC)
            cSICOM   := EX9->(MSMM(EX9_CSICOM,AVSX3("EX9_SICOM",3),,,3))
            cBlCla1  := EX9->EX9_BLCLA1
            cBlCla1C := EX9->(MSMM(EX9_CBLCL1,AVSX3("EX9_BLCLM1",3),,,3))
            cBlCla2  := EX9->EX9_BLCLA2
            cBlCla2C := EX9->(MSMM(EX9_CBLCL2,AVSX3("EX9_BLCLM2",3),,,3))
            cBlCla3  := EX9->EX9_BLCLA3
            cBlCla3C := EX9->(MSMM(EX9_CBLCL3,AVSX3("EX9_BLCLM3",3),,,3))
            If !(EX9->EX9_INFOSI $ cSim)
               EX9->(RecLock("EX9", .F.))
               EX9->EX9_INFOSI := "1"
               EX9->(MsUnlock())
            EndIf
         Else
            If lInfoSI .And. EX9->EX9_INFOSI $ cSim
               EX9->(RecLock("EX9", .F.))
               EX9->EX9_INFOSI := "2"
               EX9->(MsUnlock())
            EndIf
         EndIf
      EndIf
   Next
                                    
   EX9->(DbSetOrder(1))
   EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   While EX9->(EX9->(!EOF() .And. EX9_FILIAL+EX9_PREEMB == xFilial("EX9")+EEC->EEC_PREEMB))
   
      If aScan(aSICont, EX9->EX9_CONTNR) == 0
         EX9->(DbSkip())
         Loop
      EndIf

      aAdd(aContainer, {If(EX9->EX9_FORCTR == "A","Carrier","Shipper"),;//Fornecedor do Container
                        AllTrim(Left(EX9->EX9_CONTNR,17)),;//Número do container
                        AllTrim(EX9->EX9_TIPO),;//Tipo do container (Cód. Inttra)
                        AllTrim(Posicione("EYG", 1, xFilial("EYG")+EX9->EX9_TIPO, "EYG_DESCON")),;
                        AllTrim(If(!Empty(EEC->EEC_UNIDAD) .Or. EEC->EEC_UNIDAD <> "KG", Transform(AvTransUnid(EEC->EEC_UNIDAD,"KG","",Frm102PesCont(EX9->EX9_CONTNR),.F.),"99999999999999.999"), Transform(Frm102PesCont(EX9->EX9_CONTNR),"99999999999999.999"))),;//Peso Bruto
                        AllTrim(EX9->EX9_ENVTMP),;//Envia temperatura? (1/2)
                        AllTrim(Transform(EX9->EX9_TEMP,"99.9")),;//Temperatura
                        AllTrim(Transform(EX9->EX9_VENT,"99.999")),;//Ventilação
                        If(EX9->EX9_FORLCR == "A","Carrier","Shipper"),;//Fornecedor do lacre
                        AllTrim(Left(EX9->EX9_LACRE,15)),;//Numero do Lacre
                        AllTrim(EX9->(MSMM(EX9->EX9_OBS,AVSX3("EX9_VM_OBS",3),,,3))),;//Comentários gerais do container
                        AllTrim(EX9->(MSMM(EX9->EX9_CCOTEM,AVSX3("EX9_COMTEM",3),,,3))),;
                        "TARE ",;
                        AllTrim(Transform(EX9->EX9_CUBAGE,"999999999999999.99"));//Volume     NCF - 31/07/2012 - Alteração na picture de volume da embalagem
                        })
      EX9->(DbSkip())
   EndDo

   //Peso Bruto Total (Soma o peso dos containers)
   cPesoBrKg := 0
   aEval(aContainer, {|x| cPesoBrKg += Val(x[5]) })
   cPesoBrKg := AllTrim(Transform(cPesoBrKg,"99999999999999.999"))

   cVolume := AllTrim(Transform(GetTotVolume(EEC->EEC_PREEMB),"999999999999999.99"))
   
   //*** Marcação
   If !Empty(cMark := EEC->(MSMM(EEC_CODMAR,AVSX3("EEC_MARCAC",3),,,3)))
      aAdd(aMarks, {})
      While !Empty(cMark) .And. nMarks <= 50
         If At(ENTER, cMark) > 0 .And. At(ENTER, cMark) < 35
            If !Empty(Left(cMark, At(ENTER, cMark) - 1))
               aAdd(aMarks[Len(aMarks)], Left(cMark, At(ENTER, cMark) - 1))
            EndIf
            nPos := At(ENTER, cMark) + 2
         Else
            aAdd(aMarks[Len(aMarks)], Left(cMark, 35))
            nPos := 35 + 1
         EndIf
         If Len(aMarks[Len(aMarks)]) == 10
            aAdd(aMarks, {})
         EndIf
         cMark := SubStr(cMark, nPos)
         ++nMarks
      EndDo
   EndIf
   //*** 
   
   //NCF - 31/10/2012 - Booking 2.0
   If EXL->EXL_TIPMOV == "1"
      cEnum_HlgArr := "CarrierExportHaulageCarrierImportHaulage"
   ElseIf EXL->EXL_TIPMOV == "2"
      cEnum_HlgArr := "CarrierExportHaulageMerchantImportHaulage"   
   ElseIf EXL->EXL_TIPMOV == "3"
      cEnum_HlgArr := "MerchantExportHaulageCarrierImportHaulage"
   ElseIf EXL->EXL_TIPMOV == "4"
      cEnum_HlgArr := "MerchantExportHaulageMerchantImportHaulage"         
   EndIf 


   //AAF 03/07/2015 - Deve preencher a modalidade de frete mesmo na versão 1.0
   If !Empty(EXL->EXL_MODLFR)
      If EXL->EXL_MODLFR == "1"
         cMdlFrete := "PrePaid"
      ElseIf EXL->EXL_MODLFR == "2"
         cMdlFrete := "Collect"
      ElseIf EXL->EXL_MODLFR == "3"
      	 cMdlFrete := "ThirdParty"
      EndIf 
   EndIf
   
   //NCF - 28/05/2013 - Campos referente ao Frete da Solicitação de Booking e Shipping Instructions 2.0   
   If cService $ "BK/SI"
      If !Empty(EXL->EXL_CATFRE)
         Do Case
            Case EXL->EXL_CATFRE == "1"
               cChargeType := "AdditionalCharges"
            Case EXL->EXL_CATFRE == "2"
               cChargeType := "OceanFreight"
            Case EXL->EXL_CATFRE == "3"
               cChargeType := "DestinationHaulageCharges"
            Case EXL->EXL_CATFRE == "4"
               cChargeType := "DestinationTerminalHandling"
            Case EXL->EXL_CATFRE == "5"
               cChargeType := "OriginHaulageCharges"
            Case EXL->EXL_CATFRE == "6"
               cChargeType := "OriginTerminalHandling"
         EndCase
      Else
      	cChargeType := "OceanFreight"
      EndIf
         
      cCrtFrete := ALLTRIM(EXL->EXL_CRTTFR)
            
      If Empty(cCrtFrete) .And. (cOpcao <> EXCLUIR)
         If MsgYesNo("O Nro. do contrato de frete não foi informado na aba 'INTTRA' do processo de Embarque"+CHR(13)+CHR(10)+;
                  "Deseja prosseguir com a geração da Solicitação de Booking?")
            lContinua := .T.
         Else
            lContinua := .F.
         EndIf
      Else
         lContinua := .T.         
      EndIf

   EndIf

   If lContinua   
      //JVR - Tratamento de validação de variaveis usadas no XML.
      aLog := Frm104Valid(cOpcao)
      If Len(aLog) == 0
         If cService == "BK"
            lRet := .T.
         Else 
            lRet := AvStAction(cAction)
         EndIf
      Else
         lRet := .F.
      EndIf 
   EndIf
   
   If lRet .And. cService == "SI"
      EX9->(DbSeek(xFilial()+cPreemb))
      While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+cPreemb)
         If cOpcao <> EXCLUIR .And. aScan(aSICont, EX9->EX9_CONTNR) > 0
            If EX9->EX9_SEQSI <> cSeqSI
               EX9->(RecLock("EX9", .F.))
               EX9->EX9_SEQSI := cSeqSI
               EX9->(MsUnlock())
            EndIf
         Else
            If EX9->EX9_SEQSI == cSeqSI
               EX9->(RecLock("EX9", .F.))
               EX9->EX9_SEQSI := ""
               EX9->(MsUnlock())
            EndIf
         EndIf
         EX9->(DbSkip())
      EndDo
   EndIf
   
   IF cService == "BK" .And. lRet
      cXml_BK := EECBKRIN2()                                //NCF - 14/03/2012 - Chamada da Função para geração do Xml Booking request (IN) versão 2.0
      Frm103FLMan("BK", 3, cXml_BK, cProcesso, cNomFile)    //NCF - 14/03/2012 - Envio do Xml Booking request (IN) versão 2.0 para o diretório "Não enviados"  
   ENDIF

   
End Sequence

Return Nil

Static Function GetParties()

   //Busca o contato do responsável do embarque
   If !Empty(EEC->EEC_RESPON)
      EE3->(DbSetOrder(2))
      If EE3->(DbSeek(xFilial("EE3")+AvKey(EEC->EEC_RESPON,"EE3_NOME")))
         cContRespN := AllTrim(Left(EE3->EE3_NOME,35))
         If !Empty(EE3->EE3_EMAIL)
            cContRespT := "Email"
            cContRespV := AllTrim(EE3->EE3_EMAIL)
            If EE3->EE3_INTTRA == "1" .And. !Empty(EE3->EE3_EMAIL)
               cPushNT := "Email"
               cPushNV := Alltrim(EE3->EE3_EMAIL)
            EndIf
         ElseIf !Empty(EE3->EE3_FONE)
            cContRespT := "Telephone"
            cContRespV := AllTrim(EE3->EE3_FONE)
         ElseIf !Empty(EE3->EE3_FAX)
            cContRespT := "Fax"
            cContRespV := AllTrim(EE3->EE3_FAX)
         EndIf
      EndIf
   EndIf

   //Busca Informações do Parceiro Inttra (Partner e Shipper)
   SA2->(DbSetOrder(1))
   If SA2->(DbSeek(xFilial("SA2")+EEC->(EEC_FORN+EEC_FOLOJA)))   
      cPartEnd1 := AllTrim(Left(SA2->A2_END, 35)) + " " + AllTrim(SA2->A2_NR_END)
      cPartEnd2 := AllTrim(SA2->A2_MUN) + " " + AllTrim(SA2->A2_CEP)
      cPartEnd3 := AllTrim(SA2->A2_EST) + "-" + AllTrim(CriaVar("A2_PAISDES"))
      cPartEnd4 := Alltrim(SA2->A2_COMPLEM)
   EndIf
   EYI->(DbSetOrder(1))
   If EYI->(DbSeek(xFilial("EYI")+SA2->(A2_COD+A2_LOJA)))
      cPartId	:= AllTrim(Left(EYI->EYI_CODIN,	35))
      cPartName1:= AllTrim(Left(EYI->EYI_NOMEIN,35))
   EndIf
   //Busca o contato do responsável pela comunicação com o Inttra para o exportador      
   EE3->(DbSetOrder(1))
   If EE3->(DbSeek(xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL"))))
      While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL")))
         If EE3->EE3_INTTRA == "1"
            cContPartN := Left(EE3->EE3_NOME,35)
            If !Empty(EE3->EE3_EMAIL)
               cContPartT := "Email"
               cContPartV := AllTrim(EE3->EE3_EMAIL)
            ElseIf !Empty(EE3->EE3_FONE)
               cContPartT := "Telephone"
               cContPartV := AllTrim(EE3->EE3_FONE)
            ElseIf !Empty(EE3->EE3_FAX)
               cContPartT := "Fax"
               cContPartV := AllTrim(EE3->EE3_FAX)
            EndIf
            Exit
         EndIf
         EE3->(DbSkip())
      EndDo
   EndIf
   
   //Busca informações para BookingParty e Shipper - JVR 18/12/09
   SA2->(DbSetOrder(1))
   If SA2->(DbSeek(xFilial("SA2")+EEC->(EEC_FORN+EEC_FOLOJA)))
      cPartEnd1_ := AllTrim(Left(SA2->A2_END, 35)) + " " + AllTrim(SA2->A2_NR_END)
      cPartEnd2_ := AllTrim(SA2->A2_MUN) + " " + AllTrim(SA2->A2_CEP)
      cPartEnd3_ := AllTrim(SA2->A2_EST) + "-" + AllTrim(CriaVar("A2_PAISDES"))
      cPartEnd4_ := Alltrim(SA2->A2_COMPLEM)
   EndIf
   If EYI->(DbSeek(xFilial("EYI")+SA2->(A2_COD+A2_LOJA)))
      cPartId_	 := AllTrim(Left(EYI->EYI_CODIN,	35))
      cPartName1_:= AllTrim(Left(EYI->EYI_NOMEIN,35))
   EndIf
   EE3->(DbSetOrder(1))
   If EE3->(DbSeek(xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL"))))
      While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL")))
         If EE3->EE3_INTTRA == "1"
            cContPartN_    := Left(EE3->EE3_NOME,35)
            If !Empty(EE3->EE3_EMAIL)
               cContPartT_ := "Email"
               cContPartV_ := AllTrim(EE3->EE3_EMAIL)
            ElseIf !Empty(EE3->EE3_FONE)
               cContPartT_ := "Telephone"
               cContPartV_ := AllTrim(EE3->EE3_FONE)
            ElseIf !Empty(EE3->EE3_FAX)
               cContPartT_ := "Fax"
               cContPartV_ := AllTrim(EE3->EE3_FAX)
            EndIf
            Exit
         EndIf
         EE3->(DbSkip())
      EndDo
   EndIf 

   //*** Busca dados do Consignatário
   SA1->(DbSetOrder(1))
   If SA1->(DbSeek(xFilial('SA1')+IF(!Empty(EEC->EEC_CONSIG),EEC->(EEC_CONSIG+EEC_COLOJA), EEC->(EEC_IMPORT+EEC_IMLOJA))))
      If EEC->(FieldPos("EEC_CONSDE")) > 0
         cConsName1 := AllTrim(EEC->EEC_CONSDE)
         cConsName2 := ""
      Else
         cConsName1 := AllTrim(Left(SA1->A1_NOME, 35))
         cConsName2 := AllTrim(Left(SA1->A1_NREDUZ, 35))
      EndIf
      If EEC->(FieldPos("EEC_ENDCON")) > 0 .And. !Empty(EEC->EEC_ENDCON)
         cConsEnd1 := Left(EEC->EEC_ENDCON, 35)
         cConsEnd2 := SubStr(EEC->EEC_ENDCON, 36, 35)
         cConsEnd3 := Left(EEC->EEC_END2CO, 35)
         cConsEnd4 := SubStr(EEC->EEC_END2CO, 36, 35)
      Else
         cConsEnd1 := AllTrim(Left(SA1->A1_END, 35))
         cConsEnd2 := AllTrim(SA1->A1_ESTADO)
         cConsEnd3 := AllTrim(SA1->A1_MUN) + AllTrim(CriaVar("A1_PAISDES"))
         cConsEnd4 := Alltrim(SA1->A1_COMPLEM)
      EndIf
      EXJ->(DbSetOrder(1))
      If EXJ->(DbSeek(xFilial("EXJ")+If(!Empty(EEC->EEC_CONSIG),EEC->(EEC_CONSIG+EEC_COLOJA),EEC->(EEC_IMPORT+EEC_IMLOJA))))
         If !Empty(EXJ->EXJ_INTTRA)
            cConsID := AllTrim(EXJ->EXJ_INTTRA)
         EndIf
      EndIf
   EndIf
   EE3->(DbSetOrder(1))
   If EE3->(DbSeek(xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL"))))
      While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL")))
         If EE3->EE3_INTTRA == "1"
            cConsPartN := Left(EE3->EE3_NOME,35)
            If !Empty(EE3->EE3_EMAIL)
               cConsPartT := "Email"
               cConsPartV := AllTrim(EE3->EE3_EMAIL)
            ElseIf !Empty(EE3->EE3_FONE)
               cConsPartT := "Telephone"
               cConsPartV := AllTrim(EE3->EE3_FONE)
            ElseIf !Empty(EE3->EE3_FAX)
               cConsPartT := "Fax"
               cConsPartV := AllTrim(EE3->EE3_FAX)
            EndIf
            Exit
         EndIf
         EE3->(DbSkip())
      EndDo
   EndIf
   //***

   //*** Busca Empresas do processo
   EEB->(DbSetOrder(1))
   EEB->(DbSeek(xFilial("EEB")+EEC->EEC_PREEMB+"Q"))
   While EEB->(EEB->(!EOF()) .and. EEB->(EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE)== xFilial("EEB")+EEC->EEC_PREEMB+"Q")
      //*** Despachante
      If Left(EEB->EEB_TIPOAG,1)=='6'
         cDespCodIn := AllTrim(EEB->EEB_REFAGE)
      EndIf
      //***
      //*** Armador
      If Left(EEB->EEB_TIPOAG,1)=='4'
         cContArm := Left(EEB->EEB_CONTR,35)
         //Busca o código do Armador no Inttra
         SY5->(DbSetOrder(1))
         If SY5->(DbSeek(xFilial("SY5")+AvKey(EEB->EEB_CODAGE,"Y5_COD")))
            cArmName1 := AllTrim(Left(SY5->Y5_NOME,35))
            cArmID := AllTrim(SY5->Y5_SCAC)
         EndIf
      EndIf
      //***
      //*** FreightForwarder
      If Left(EEB->EEB_TIPOAG,1)=='C'
         cContFF := AllTrim(Left(EEB->EEB_CONTR,35))
         cFFref := AllTrim(Left(EEB->EEB_REFAGE,35))
         SY5->(DbSetOrder(1))
         If SY5->(DbSeek(xFilial("SY5")+AvKey(EEB->EEB_CODAGE,"Y5_COD")))
            cFFName1 := AllTrim(Left(SY5->Y5_NOME,35))
            cFFEnd1 := AllTrim(Left(SY5->Y5_END, 35))
            cFFEnd2 := AllTrim(SY5->Y5_CIDADE)
            cFFEnd3 := AllTrim(SY5->Y5_CEP)
            cFFEnd4 := AllTrim(SY5->Y5_EST) + "-" + AllTrim(CriaVar("Y5_DESCPAI"))
            If EE3->(DbSeek(xFilial()+"E"+SY5->(AvKey(Y5_COD, "EE3_CONTAT")+AvKey("", "EE3_COMPL"))))
               While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial()+"E"+SY5->(AvKey(Y5_COD, "EE3_CONTAT")+AvKey("", "EE3_COMPL")))
                  If EE3->EE3_INTTRA == "1"
                     cFFPartN := Left(EE3->EE3_NOME,35)
                     If !Empty(EE3->EE3_EMAIL)
                        cFFPartT := "Email"
                        cFFPartV := AllTrim(EE3->EE3_EMAIL)
                     ElseIf !Empty(EE3->EE3_FONE)
                        cFFPartT := "Telephone"
                        cFFPartV := AllTrim(EE3->EE3_FONE)
                     ElseIf !Empty(EE3->EE3_FAX)
                        cFFPartT := "Fax"
                        cFFPartV := AllTrim(EE3->EE3_FAX)
                     EndIf
                     Exit
                  EndIf
                  EE3->(DbSkip())
               EndDo
            EndIf
         EndIf 
      EndIf
      //***
      EEB->(DbSkip())
   EndDo
   //***
   
   //Busca os dois primeiros notifys do processo
   nNotify := 0
   EEN->(DbSetOrder(1))
   EEN->(DbSeek(xFilial("EEN")+EEC->EEC_PREEMB+"Q"))
   While EEN->(!Eof() .and. EEN_FILIAL+EEN_PROCES+EEN_OCORRE == xFilial("EEN")+EEC->EEC_PREEMB+"Q")
      If nNotify > 2
         Exit
      EndIf
      EXJ->(DbSetOrder(1))
      If SA1->(DbSeek(xFilial("SA1")+EEN->(EEN_IMPORT+EEN_IMLOJA)))
         EXJ->(DbSeek(xFilial("EXJ")+EEN->(EEN_IMPORT+EEN_IMLOJA)))
         ++nNotify
         If nNotify == 1
            cNot1Name1 := AllTrim(Left(SA1->A1_NOME, 35))
            cNot1Name2 := AllTrim(Left(SA1->A1_NREDUZ, 35))
            /*
            cNot1End1 := AllTrim(Left(SA1->A1_END, 35))
            cNot1End2 := AllTrim(SA1->A1_ESTADO)
            cNot1End3 := AllTrim(SA1->A1_MUN) + "-" + AllTrim(CriaVar("A1_PAISDES"))
            cNot1End4 := Alltrim(SA1->A1_COMPLEM)
            */
            cNot1End1 := Left(EEN->EEN_ENDIMP, 35)
            cNot1End2 := SubStr(EEN->EEN_ENDIMP, 36, 35)
            cNot1End3 := Left(EEN->EEN_END2IM, 35)
            cNot1End4 := SubStr(EEN->EEN_END2IM, 36, 35)
            If !Empty(EXJ->EXJ_INTTRA)
               cNot1ID := AllTrim(EXJ->EXJ_INTTRA)
            EndIf
            If EE3->(DbSeek(xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL"))))
               While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL")))
                  If EE3->EE3_INTTRA == "1"
                     cNot1PartN := Left(EE3->EE3_NOME,35)
                     If !Empty(EE3->EE3_EMAIL)
                        cNot1PartT := "Email"
                        cNot1PartV := AllTrim(EE3->EE3_EMAIL)
                     ElseIf !Empty(EE3->EE3_FONE)
                        cNot1PartT := "Telephone"
                        cNot1PartV := AllTrim(EE3->EE3_FONE)
                     ElseIf !Empty(EE3->EE3_FAX)
                        cNot1PartT := "Fax"
                        cNot1PartV := AllTrim(EE3->EE3_FAX)
                     EndIf
                     Exit
                  EndIf
                  EE3->(DbSkip())
               EndDo
            EndIf
         ElseIf nNotify == 2
            cNot2Name1 := AllTrim(Left(SA1->A1_NOME, 35))
            cNot2Name2 := AllTrim(Left(SA1->A1_NREDUZ, 35))
            /*
            cNot2End1 := AllTrim(Left(SA1->A1_END, 35))
            cNot2End2 := AllTrim(SA1->A1_ESTADO)
            cNot2End3 := AllTrim(SA1->A1_MUN) + "-" + AllTrim(CriaVar("A1_PAISDES"))
            cNot2End4 := Alltrim(SA1->A1_COMPLEM)
            */
            
            cNot2End1 := Left(EEN->EEN_ENDIMP, 35)
            cNot2End2 := SubStr(EEN->EEN_ENDIMP, 36, 35)
            cNot2End3 := Left(EEN->EEN_END2IM, 35)
            cNot2End4 := SubStr(EEN->EEN_END2IM, 36, 35)
            
            If !Empty(EXJ->EXJ_INTTRA)
               cNot2ID := AllTrim(EXJ->EXJ_INTTRA)
            EndIf
            If EE3->(DbSeek(xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL"))))
               While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL")))
                  If EE3->EE3_INTTRA == "1"
                     cNot2PartN := Left(EE3->EE3_NOME,35)
                     If !Empty(EE3->EE3_EMAIL)
                        cNot2PartT := "Email"
                        cNot2PartV := AllTrim(EE3->EE3_EMAIL)
                     ElseIf !Empty(EE3->EE3_FONE)
                        cNot2PartT := "Telephone"
                        cNot2PartV := AllTrim(EE3->EE3_FONE)
                     ElseIf !Empty(EE3->EE3_FAX)
                        cNot2PartT := "Fax"
                        cNot2PartV := AllTrim(EE3->EE3_FAX)
                     EndIf
                     Exit
                  EndIf
                  EE3->(DbSkip())
               EndDo
            EndIf
         ElseIf nNotify == 3
            cNot3Name1 := AllTrim(Left(SA1->A1_NOME, 35))
            cNot3Name2 := AllTrim(Left(SA1->A1_NREDUZ, 35))
            /*
            cNot3End1 := AllTrim(Left(SA1->A1_END, 35))
            cNot3End2 := AllTrim(SA1->A1_ESTADO)
            cNot3End3 := AllTrim(SA1->A1_MUN) + AllTrim(CriaVar("A1_PAISDES"))
            cNot3End4 := Alltrim(SA1->A1_COMPLEM)
            */

            cNot3End1 := Left(EEN->EEN_ENDIMP, 35)
            cNot3End2 := SubStr(EEN->EEN_ENDIMP, 36, 35)
            cNot3End3 := Left(EEN->EEN_END2IM, 35)
            cNot3End4 := SubStr(EEN->EEN_END2IM, 36, 35)

            If !Empty(EXJ->EXJ_INTTRA)
               cNot3ID := AllTrim(EXJ->EXJ_INTTRA)
            EndIf
            If EE3->(DbSeek(xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL"))))
               While EE3->(!EOF() .and. EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL == xFilial()+"I"+SA1->(AvKey(A1_COD, "EE3_CONTAT")+AvKey(A1_LOJA, "EE3_COMPL")))
                  If EE3->EE3_INTTRA == "1"
                     cNot3PartN := Left(EE3->EE3_NOME,35)
                     If !Empty(EE3->EE3_EMAIL)
                        cNot3PartT := "Email"
                        cNot3PartV := AllTrim(EE3->EE3_EMAIL)
                     ElseIf !Empty(EE3->EE3_FONE)
                        cNot3PartT := "Telephone"
                        cNot3PartV := AllTrim(EE3->EE3_FONE)
                     ElseIf !Empty(EE3->EE3_FAX)
                        cNot3PartT := "Fax"
                        cNot3PartV := AllTrim(EE3->EE3_FAX)
                     EndIf
                     Exit
                  EndIf
                  EE3->(DbSkip())
               EndDo
            EndIf
         EndIf
      EndIf
      EEN->(DbSkip())
   EndDo

Return Nil
          
/*
Função     : Frm104RecInt()
Parâmetros : cAction
             oProcess
Retorno    : 
Objetivos  : Trava as tabelas de acordo com o tipo de Doc e Inicia uma ação do EasyLink.
Autor      : Jean Victor Rocha
Data/Hora  : 21/08/2009
*/
*------------------------------------------------*
Function Frm104RecInt(cAction, oProcess)
*------------------------------------------------*
Local lRet
Local cMsg := "", cHistorico
Local aOrd := SaveOrd("EEC")

   //Carrega as variáveis de memória para que o serviço grave as informações nelas primeiro, e depois 
   //compare as alterações com a base de dados.
   RegToMemory("EEC", .T.,,.F.)
   RegToMemory("EXL", .T.,,.F.)

   Begin Transaction

      lRet := AvStAction(cAction,, oProcess)

      If lRet
         EEC->(DbSetOrder(1))
         Do Case
            //Booking
            Case cAction == "301"
               cMsg := STR0004
               cMsg := StrTran(cMsg, "XXX", AllTrim(EYM->EYM_BOOK))
               cMsg := StrTran(cMsg, "YYY", AllTrim(EYM->EYM_PROC))
               If !EEC->(DbSeek(xFilial()+AvKey(EYM->EYM_PROC, "EEC_PREEMB")))
                  cMsg += STR0005
               Else
                  cMsg += STR0006 + AllTrim(Posicione("SA1", 1, xFilial("SA1")+EEC->(EEC_CLIENT+EEC_CLLOJA), "A1_NOME")) + " "
                  cMsg += STR0007 + AllTrim(EEC->EEC_EMBARC) + " "
                  cMsg += STR0008 + AllTrim(EEC->EEC_VIAGEM) + " "
                  cMsg += STR0009 + DToC(EEC->EEC_ETD) + " "
                  /* Registra o histórico das alterações comparando as variáveis de memória (situação anterior)
                     com a base de dados (já atualizada pelo serviço).
                  */
                  cHistorico := Ae110MonHistProc("EEC", "M", "EEC")
                  cHistorico += Ae110MonHistProc("EXL", "M", "EXL")
                  If !Empty(Alltrim(cHistorico))
                     Ae110CadHistProc(OC_EM, EYM->EYM_PROC, STR0010, cHistorico)
                  EndIf
               EndIf
               
            Case cAction == "303"
               cMsg := STR0011
               cMsg := StrTran(cMsg, "XXX", AllTrim(EYN->EYN_ID_SI))
               cMsg := StrTran(cMsg, "YYY", AllTrim(EYN->EYN_PROC))
               If !EEC->(DbSeek(xFilial()+AvKey(EYN->EYN_PROC, "EEC_PREEMB")))
                  cMsg += STR0005
               Else
                  cMsg += STR0006 + AllTrim(Posicione("SA1", 1, xFilial("SA1")+EEC->(EEC_CLIENT+EEC_CLLOJA), "A1_NOME")) + " "
                  cMsg += STR0007 + AllTrim(EEC->EEC_EMBARC) + " "
                  cMsg += STR0008 + AllTrim(EEC->EEC_VIAGEM) + " "
                  cMsg += STR0009 + DToC(EEC->EEC_ETD) + " "
               EndIf

            Case cAction == "304"
               cMsg := STR0012
               cMsg := StrTran(cMsg, "YYY", AllTrim(EYO->EYO_PROC))
               If !EEC->(DbSeek(xFilial()+AvKey(EYO->EYO_PROC, "EEC_PREEMB")))
                  cMsg += STR0005
               Else
                  cMsg += STR0006 + AllTrim(Posicione("SA1", 1, xFilial("SA1")+EEC->(EEC_CLIENT+EEC_CLLOJA), "A1_NOME")) + " "
                  cMsg += STR0007 + AllTrim(EEC->EEC_EMBARC) + " "
                  cMsg += STR0008 + AllTrim(EEC->EEC_VIAGEM) + " "
                  cMsg += STR0009+ DToC(EEC->EEC_ETD) + " "
               EndIf
            
            Case cAction == "305"
               cMsg := STR0013
               cMsg := StrTran(cMsg, "YYY", AllTrim(EYP->EYP_PROC))
               If !EEC->(DbSeek(xFilial()+AvKey(EYP->EYP_PROC, "EEC_PREEMB")))
                  cMsg += STR0005
               Else
                  cMsg += STR0006 + AllTrim(Posicione("SA1", 1, xFilial("SA1")+EEC->(EEC_CLIENT+EEC_CLLOJA), "A1_NOME")) + " "
                  cMsg += STR0007 + AllTrim(EEC->EEC_EMBARC) + " "
                  cMsg += STR0008 + AllTrim(EEC->EEC_VIAGEM) + " "
                  cMsg += STR0009 + DToC(EEC->EEC_ETD) + " "
               EndIf

         EndCase
      Else
         While __lSX8
            RollBackSX8()
         Enddo
      EndIf

   End Transaction

RestOrd(aOrd, .T.)
Return cMsg

/*
Função     : Frm104Valid()
Parâmetros :
Retorno    : 
Objetivos  : Validação das variaveis que serão usadas.
Autor      : Jean Victor Rocha
Data/Hora  : 26/08/2009
*/
*--------------------*
Function Frm104Valid(cOpcao)
*--------------------*
Local nInc1, nInc2, nCont := 0
Local cLog := "", aLog := {}
Local aVars := {}

aAdd(aVars, {"cContRespN", STR0015, ""})
aVars[Len(aVars)][3] := STR0016 + ENTER +"#EEC_RESPON#"

aAdd(aVars, {"cContRespV", STR0017, ""})
aVars[Len(aVars)][3] := STR0023 + ENTER +;
                        "#EE3_EMAIL#" + ENTER +;
                        ENTER +;
                        "#EE3_FONE#" + ENTER +;
                        ENTER +;
                        "#EE3_FAX#" + ENTER

aAdd(aVars, {"cPartId", STR0018, ""})
aVars[Len(aVars)][3] := STR0019 + ENTER +;
                        "#EYI_CODIN#"

aAdd(aVars, {"cPartName1", STR0020, ""})
aVars[Len(aVars)][3] := STR0021 + ENTER +;
                        "#EYI_NOMEIN#"

aAdd(aVars, {"cPartEnd1", STR0021, ""})
aVars[Len(aVars)][3] := STR0022 + ENTER +;
                        "#A2_END#"

aAdd(aVars, {"cContPartN", STR0024, ""})
aVars[Len(aVars)][3] := STR0025 + ENTER +;
                        "#EE3_INTTRA#"

aAdd(aVars, {"cContPartV", "Contato Exportador", ""})
aVars[Len(aVars)][3] := STR0026 + ENTER +;
                        "#EE3_EMAIL#" + ENTER +;
                        ENTER +;
                        "#EE3_FONE#" + ENTER +;
                        ENTER +;
                        "#EE3_FAX#" + ENTER

aAdd(aVars, {"cPushNV", STR0027, ""})
aVars[Len(aVars)][3] := STR0028 + ENTER +;
                        "#EEC_RESPON#" + ENTER

//aAdd(aVars, {"cNot1Name1", "Notify", ""})
//aVars[Len(aVars)][3] := "Acesse o botão 'Notifys' na rotina de Embarque e insira um Notify do processo." + ENTER

aAdd(aVars, {"cArmID", STR0029, ""})
aVars[Len(aVars)][3] := STR0030 + ENTER +;
                        "#Y5_SCAC#" + ENTER

aAdd(aVars, {"cArmName1", STR0031, ""})
aVars[Len(aVars)][3] := STR0032 + ENTER

/*
aAdd(aVars, {"cContArm", "Contrato com o Armador", ""})
aVars[Len(aVars)][3] := "Identifique o contrato com o Armador acessando o botão 'Despesas Nacionais' no processo de embarque e clicando em 'Alterar' sobre o registro do Armador. Deve ser informado o seguinte campo:" + ENTER +;
                        "#EEB_CONTR#" + ENTER

aAdd(aVars, {"cFFName1", "Freight Forwarder" , ""})
aVars[Len(aVars)][3] := "Acesse o botão 'Despesas Nacionais' na rotina de embarque e insira uma empresa do tipo 'C-Freight Forwarder'" + ENTER

aAdd(aVars, {"cFFEnd1", "Endereço do Freight Forwarder" , ""})
aVars[Len(aVars)][3] := "Acesse o Cadastro de Empresas e insira a informação no campo abaixo no registro relacionado ao Freight Forwarder:" + ENTER +;
                        "#Y5_END#"

aAdd(aVars, {"cFFPartN", "Nome contato Freight Forwarder" , ""})
aVars[Len(aVars)][3] := "Acesse o Cadastro de Empresas, cadastre um contato para o Freight Forwawrder e marque o campo abaixo com o conteúdo 'Sim'" + ENTER +;
                        "#EE3_INTTRA#"

aAdd(aVars, {"cFFPartV", "Contato no Freight Forwarder" , ""})
aVars[Len(aVars)][3] := "No Cadastro do Freight Forwarder, insira ao menos uma das informações abaixo no cadastro do Contato na Empresa:" + ENTER +;
                        "#EE3_EMAIL#" + ENTER +;
                        ENTER +;
                        "#EE3_FONE#" + ENTER +;
                        ENTER +;
                        "#EE3_FAX#" + ENTER
*/
aAdd(aVars, {"cPtOriLC", STR0033, ""})
aVars[Len(aVars)][3] := STR0034 + ENTER +;
                        "#Y9_UNCODE#" + ENTER

If (cOpcao <> EXCLUIR)
	aAdd(aVars, {"cMdlFrete", "Modalidade de Pagamento do Frete", ""})                        
	aVars[Len(aVars)][3] :=  "Informe o campo 'Modal. Frete' na aba 'INTTRA' do processo de embarque " + ENTER +;
	                         "#EXL_MODLFR#" + ENTER
EndIf

//** Início da validação
For nInc1 := 1 To Len(aVars)
   If Empty(&(aVars[nInc1][1]))
      ++nCont
      cLog += AllTrim(Str(nCont)) + ")"+ STR0035 + ENTER + aVars[nInc1][2] + ENTER
      cLog += STR0036 + ENTER
      cLog += ChangeTags(aVars[nInc1][3]) + ENTER
      cLog += ENTER
   EndIf
Next

//Valida do navio
If (Empty(cNvNome) .And. Empty(cNvViagem)) .And. Empty(cLcOriETD) .And. Empty(cLcOriReti)
   cLog += STR0037 + ENTER
   cLog += STR0038
   cLog += ENTER
EndIf
//**

If !Empty(cLog)
   aAdd(aLog, {STR0039 + ENTER, .T.})
   aAdd(aLog, {STR0040 + ENTER, .T.})
   aAdd(aLog, {ENTER, .T.})
   While (nPos := At(ENTER, cLog)) > 0 .And. nPos < Len(cLog)
      aAdd(aLog, {Left(cLog, nPos += 1), .T.})
      ++nPos
      cLog := SubStr(cLog, nPos)
   EndDo
   EECView(aLog, "Aviso")
EndIf

Return aLog

Static Function ChangeTags(cTexto)
Local nPos1, nPos2

   While (nPos1 := At("#", cTexto)) > 0
      If (nPos2 := At("#", SubStr(cTexto, nPos1 + 1, 11))) > 0
         cCampo := SubStr(cTexto, nPos1 + 1, nPos2 - 1)
         cTexto := StrTran(cTexto, "#" + cCampo + "#", FieldInfo(cCampo))
      Else
         Exit
      EndIf
   EndDo

Return cTexto

Static Function FieldInfo(cField)
Local cInfo := ""
Local cTable := Posicione("SX3", 2, IncSpace(cCampo, 10, .F.), "X3_ARQUIVO")

   cInfo := "Nome   : " + AvSx3(cField, AV_TITULO) + ENTER +;
            "Tabela : " + Posicione("SX2", 1, cTable, "X2_NOME") + ENTER +;
            "Pasta  : " + AvSx3(cField, AV_FOLDER)

Return cInfo

/*
Função     : AVVisXML()
Parâmetros :
Retorno    : 
Objetivos  : Visualização dos arquivos XML.
Autor      : Jean Victor Rocha
Data/Hora  : 31/08/2009
*/
*-----------------------------------------*
Function AVVisXML(cAction, cArqXML, cStatus)
*-----------------------------------------*
Local i, aDirectory := {}
Local cXml := ""
Local cXSlAdd := "", cArqXSL := ""
Local cTemp := GetTempPath()
Local cDestTemp := cTemp + "imonitor\"
Local cNewXML
Local cOrigemXSL := "\Comex\easylink\inttra\resources\"

//Verifica se ja existe o diretorio Imonitor na pasta Temp, caso exista limpa o diretorio.
If !lIsDir(cDestTemp)
   nRet := MakeDir(cDestTemp)
   If nRet < 0
      Alert(STR0041)
      Return .F.
   EndIf
Else 
   //Apaga os arquivos do diretorio na pasta temp.
   aDirectory := DIRECTORY(cDestTemp + "*.*",)
   For i:=1 to len(aDirectory)
      FERASE(cDestTemp + aDirectory[i][1])
   Next i
EndIf

If Upper(Right(cArqXML, 3)) == ".XM"
   cArqXML += "l"
EndIf

If Upper(Right(cArqXML, 2)) == ".X"
   cArqXML += "ml"
EndIf

cNewXML := cDestTemp + cArqXML

//Faz a leitura do arquivo XML.
If (cStatus == ITENVIADOS)
   cXml := MemoRead("\Comex\easylink\inttra\outbound\sent\" + cArqXML)
ElseIf (cStatus == ITNAOENVIADOS)
   cXml := MemoRead("\Comex\easylink\inttra\outbound\" + cArqXML)
ElseIf (cStatus == ITRECEBIDOS) .Or. (cStatus == ITPROCESSADOS)
   cXml := MemoRead("\Comex\easylink\inttra\inbound\" + cArqXML)
EndIf

If cXml == ""
   Alert(STR0042)
   Return .F.
EndIf

//verifica se é BK ou se é SI.
Do CASE
   CASE cAction == "301"
      cXslAdd := '<?xml-stylesheet type="text/xsl" href="bk_layouthtml.xsl"?>'
      cArqXSL += "bk_layouthtml.xsl"
   CASE cAction == "303"
      cXslAdd := '<?xml-stylesheet type="text/xsl" href="si_layouthtml.xsl"?>'
      cArqXSL += "si_layouthtml.xsl"
EndCASE

//conteudo do arquivo XML com a definição do arquivo XSL

//cXml := cXslAdd + cXml

cXML := StrTran(cXML, "?>", "?>" + cXslAdd)

Begin Sequence
   //Cria o XML na pasta temp com a definição da linha que ira conter o XSL.
   If !MemoWrite(cNewXML, cXml)
      Alert(STR0043)
      Break
   EndIf
                        
   //copia o XSL para a pasta temp
   If !CpyS2T( cOrigemXSL + cArqXSL, cDestTemp)
      Alert(STR0044)
      Break
   EndIf

   //Executa o arquivo XML com o layout ja definido.     
   nRet := ShellExecute("open",cNewXML,"","", 1)
   If nRet <= 32
      Alert(STR0045)
      Break
   EndIf
End Sequence

Return Nil

/*
Funcao          : VLDNumCont()
Parametros      : cNumCont = Numero COntainer.
                  lVAlid   = Ativa Validação da numeração.
Retorno         : lRet
Objetivos       : Validar o Digito verificador do Container
Autor           : Jean Victor Rocha
Data/Hora       : 21/09/2009
Revisao         :
Obs.            :
*/
*-----------------------------------*
Function VLDNumCont(cNumCont, lValid)
*-----------------------------------*
Local   i, lRet   := .F.
Local   cValCont := ""
Local   nSubDig := 0, nPos := 0, nSomaTot := 0, nDig := 0

Default lValid := .T.

Private aTabVal := {{"A", 10},  {"B", 12},; //Tabela de Valores.
                    {"C", 13},  {"D", 14},;
                    {"E", 15},  {"F", 16},;
                    {"G", 17},  {"H", 18},;
                    {"I", 19},  {"J", 20},;
                    {"K", 21},  {"L", 23},;
                    {"M", 24},  {"N", 25},;
                    {"O", 26},  {"P", 27},;
                    {"Q", 28},  {"R", 29},;
                    {"S", 30},  {"T", 31},;
                    {"U", 32},  {"V", 34},;
                    {"W", 35},  {"X", 36},;
                    {"Y", 37},  {"Z", 38} }

//Verifica tamanho da Numeração
If Len(AllTrim(cNumCont)) > 11
   If MsgYesNo(STR0046 + ENTER +;
               STR0047)
      Return .T.
   EndIf
ElseIf !lValid
   lRet := .T.
EndIf

If lValid
   //Calculo de DV do container
   For i:=1 to Len(cNumCont)-1
      cValCont := SUBS(cNumCont, i, 1)                               //Subtrai um valor da string.
      nPos     := aScan(aTabVal, { |x| x[1] == cValCont })           //localiza o valor da string na tabela de valores.
      nSomaTot += 2^(i-1) * If(nPos>0,aTabVal[nPos][2],Val(cValCont))//Se valor da string é igual a Caracter utiliza tab. valores, senão proprio valor
   Next i
   nDig := nSomaTot-(int(nSomaTot/11)*11)
   If(nDig==10,nDig:=0,)//Validação caso o DV ficar em 10.

   //validação de DV do container.
   If nDig == VAL(SUBSTR(cNumCont,11,1)) 
      lret := .T.
   Else
      If MsgYesNo(STR0048 + Alltrim(cNumCont) + STR0049 + ENTER +;
                  STR0047)
         lRet := .T.
      EndIf
   EndIf
EndIf
Return lRet   

/*
Funcao          : FRM104MEMOBL()
Parametros      :
Retorno         : cRet
Objetivos       : Preencher o conteudo do campo memo "EXL_MEMOBL"
Autor           : Jean Victor Rocha
Data/Hora       : 16/10/2009
Revisao         :
Obs.            :
*/
*---------------------*
Function FRM104MEMOBL()              
*---------------------*
Local cRet := ""
Local aBL := {}
Local nInc

EX9->(DbSetOrder(1))
If EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   While EX9->(!EOF()) .And. EX9->EX9_FILIAL == xFilial("EX9") .And. EX9->EX9_PREEMB == EEC->EEC_PREEMB
      If aScan(aBL, EX9->EX9_BLNUM) == 0
         aAdd(aBL, EX9->EX9_BLNUM)
      EndIf
      EX9->(DbSkip())
   EndDo
EndIf

For nInc := 1 To Len(aBL)
   cRet += aBL[nInc] + If(nInc <> Len(aBL), ENTER, "")
Next

Return cRet

/*
Funcao          : FRM104MEMOSI()
Parametros      :
Retorno         : cRet
Objetivos       : Preencher o conteudo do campo memo "EXL_MEMOSI"
Autor           : Jean Victor Rocha
Data/Hora       : 16/10/2009
Revisao         :
Obs.            :
*/
*---------------------*
Function FRM104SIMEMO()
*---------------------*
Local cRet := ""
Local aSI := {}
Local nInc

EX9->(DbSetOrder(1))
If EX9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   While EX9->(!EOF()) .And. EX9->EX9_FILIAL == xFilial("EX9") .And. EX9->EX9_PREEMB == EEC->EEC_PREEMB
      If aScan(aSI, EX9->EX9_SINUM) == 0
         aAdd(aSI, EX9->EX9_SINUM)
      EndIf
      EX9->(DbSkip())
   EndDo
EndIf

For nInc := 1 To Len(aSI)
   cRet += aSI[nInc] + If(nInc <> Len(aSI), ENTER, "")
Next

Return cRet

Static Function GetTotVolume(cPreemb)
Local nVolume := 0

   cPreemb := AvKey(cPreemb, "EX9_PREEMB")
   EX9->(DbSeek(xFilial()+cPreemb))
   While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+cPreemb)
      nVolume += EX9->EX9_CUBAGE
      EX9->(DbSkip())
   EndDo

Return nVolume

//Copia o registro para a memória, considerando que as variáveis de memória já existem (private).
Function FRM104RToM(cAlias)
Local nInc

   For nInc := 1 To (cAlias)->(FCount())
      &("M->" + (cAlias)->(FieldName(nInc))) := &(cAlias + "->" + (cAlias)->(FieldName(nInc)))
   Next

Return Nil


Function Frm104RelBk()
Local oReport := TReport():New("AVFRM10401", STR0050, "", {|oReport| ReportPrint(oReport) }, STR0050)
Local oSecao1 := TRSection():New(oReport, "Teste1", {"EYM"})

oReport:PrintDialog()

Return Nil

Static Function ReportPrint(oReport)

   oReport:Print()

Return Nil    

Function ConvDateTime(xInfo)    

Local dRet

If !Empty(xInfo)
   dRet := SToD(StrTransf( SubStr(xInfo , 1, At("T", UPPER(xInfo))-1 ),"-",""))
EndIf 

Return dRet

Function EasyDT2D(cDateTime)
Return SToD(SubStr(cDateTime, 1, 4)+SubStr(cDateTime, 6, 2)+SubStr(cDateTime, 9, 2))

Function ProcRetBooking()
Local nInc, i, nCT, nT
Local aTipo_Loc := {}, aTipo_Cod_Loc := {}, aCod_Loc := {}, aData_Loc := {}
Local nProperties, oNod, lCarrier := .F.
Local oXMLEX := XMLParserFile("comex\easylink\inttra\inbound\" + EYM->EYM_FILE, "_", "", "")

	EYM->(RecLock("EYM", .F.))
	EYM->EYM_STATUS := "D"
	EYM->EYM_ID_DOC := oXMLEX:_N1_MESSAGE:_Header:_DocumentIdentifier:Text
	//EYM->EYM_PROC := oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties:_ShipmentID:Text
	
	aReference := oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties:_ReferenceInformation
	
	If ValType(aReference) == "O"
		aReference := {aReference}
	EndIf
	
	For nInc := 1 To Len(aReference)
		If aReference[nInc]:_Type:Text == "INTTRAReferenceNumber"
			EYM->EYM_BKINTT := aReference[nInc]:_Value:Text
		EndIf
		If aReference[nInc]:_Type:Text == "BookingNumber"
			EYM->EYM_BOOK := aReference[nInc]:_Value:Text
		EndIf
		If aReference[nInc]:_Type:Text == "ShipperReferenceNumber"
			EYM->EYM_PROC := aReference[nInc]:_Value:Text
		EndIf
	Next
	
	EYM->EYM_ST_MES := oXMLEX:_N1_MESSAGE:_Header:_TransactionStatus:Text
    EYM->EYM_DATABK := dDataBase
    EYM->EYM_HORABK := Time()
	
	EEC->(DbSetOrder(1))
	EXL->(DbSetOrder(1))
	If AllTrim(EYM->EYM_ST_MES) != 'Rejected' .And. !Empty(EYM->EYM_PROC) .And.;
	   EEC->(DbSeek(xFilial("EEC")+AvKey(EYM->EYM_PROC, "EEC_PREEMB"))) .And.;
	   EXL->(DbSeek(xFilial()+EEC->EEC_PREEMB))

		EEC->(RecLock("EEC", .F.))
		EXL->(RecLock("EXL", .F.))

		//Copia os campos da base para as variaveis de memoria criadas antes da chamada do servico, para comparacao das alteracoes
		FRM104RToM("EEC")
		FRM104RToM("EXL")
			
		EXL->EXL_BKRFIN := EYM->EYM_BKINTT
		EXL->EXL_BOOK 	:= EYM->EYM_BOOK

		aReference := oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties:_DateTime
               
		If ValType(aReference) == "O"
			aReference := {aReference}
		EndIf

		For nInc := 1 To Len(aReference)
			If aReference[nInc]:_DateType:Text == 'TransactionDate'
				EEC->EEC_DTFCPR := EasyDT2D(aReference[nInc]:Text)
			EndIf
		Next
		
		nProperties := XMLChildCount(oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties)
		For i := 1 To nProperties
			oNod := XMLGetChild(oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties, i)
			If (ValType(oNod) == "O" .And. AllTrim(Upper(oNod:Realname)) == "CARRIERCOMMENTS") .Or.;
			   (ValType(oNod) == "A" .And. ValType(oNod[1]) == "O" .And. AllTrim(Upper(oNod[1]:Realname)) == "CARRIERCOMMENTS")
			   
			   If ValType(oNod) == "O"
			      oNod := {oNod}
			   EndIf
			   
			   cComents := ""
			   aEval(oNod, {|o| cComents += o:_Category:Text + ENTER + o:_Text:Text + ENTER })
			
			   Frm102AtuBkCom(cComents)
			EndIf
			If (ValType(oNod) == "O" .And. AllTrim(Upper(oNod:Realname)) == "TRANSPORTATIONDETAILS") .Or.;
			   (ValType(oNod) == "A" .And. ValType(oNod[1]) == "O" .And. Upper(oNod[1]:Realname) == "TRANSPORTATIONDETAILS")

				aTransportDet := oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties:_TransportationDetails
		
				If ValType(aTransportDet) == "O"
					aTransportDet := {aTransportDet}
				EndIf
		
				oTransporte := EECLocInttra():New()
				
				oTransporte:SetTipo(oXMLEX:_N1_MESSAGE:_MessageBody:_MessageProperties:_MovementType:Text)
				
				For nT := 1 To Len(aTransportDet)
					
					oLocal := oTransporte:AddVia()
					
					oXTransport := aTransportDet[nT]
					
					nChildT := XMLChildCount(oXTransport)
					For nCT := 1 To nChildT
						oChildT := XMLGetChild(oXTransport, nCT)
		
						If ValType(oChildT) == "O"
							If Upper(oChildT:Realname) == "TRANSPORTSTAGE"
								oLocal:SetTipo(Upper(oChildT:Text))
							EndIf
							If Upper(oChildT:Realname) == "CONVEYANCEINFORMATION"
								//Informações do Navio
								InfoNavio(oChildT, oLocal)
							EndIf
							If Upper(oChildT:Realname) == "LOCATION"
								//Localidade
								InfoLocation(oChildT, oLocal)
							EndIf
						ElseIf ValType(oChildT) == "A" .and. Len(oChildT) > 0
							If ValType(oChildT[1]) == "O" .And. Upper(oChildT[1]:Realname) == "LOCATION"
								//Lista de Localidades
								aEval(oChildT, {|oChildT| InfoLocation(oChildT, oLocal)})
							EndIf
						EndIf
					Next
				Next
				
				oTransporte:InttraAtuVia()
			EndIf
		Next
            
		EEC->(MsUnlock())
		EXL->(MsUnlock())
    EndIf
	EYM->(MsUnlock())

Return


Static Function InfoNavio(oNavio, oLocal)
Local i
Local nChild
Local aIdentifier := {}

Local cTipo, cNavio, cViagem

	nChild := XMLChildCount(oNavio)
	For i := 1 To nChild
		oChild := XMLGetChild(oNavio, i)
		
		If ValType(oChild) == "O"
			Do Case
				Case Upper(oChild:Realname) == "TYPE"
					cTipo := Upper(oChild:Text)
				Case Upper(oChild:Realname) == "IDENTIFIER"
					aAdd(aIdentifier, oChild)
			EndCase
		ElseIf ValType(oChild) == "A"
			If ValType(oChild[1]) == "O" .And. Upper(oChild[1]:Realname) == "IDENTIFIER"
				aIdentifier := oChild
			EndIf
		EndIf
	Next
	
	For i := 1 To Len(aIdentifier)
		Do Case
			Case Upper(aIdentifier[i]:_Type:Text) == "VESSELNAME"
				cNavio := aIdentifier[i]:TEXT
			Case Upper(aIdentifier[i]:_Type:Text) == "VOYAGENUMBER"
				cViagem := aIdentifier[i]:TEXT
		EndCase
	Next
	
	oLocal:SetNavio(cNavio, cViagem, cTipo)

Return Nil

Static Function InfoLocation(oInfoLocation, oVia)
Local i, j, nChild
Local oChild, aDatas := {}
Local oLocal, oData

	nChild := XMLChildCount(oInfoLocation)
	For i := 1 To nChild
		oChild := XMLGetChild(oInfoLocation, i)
		
		If ValType(oChild) == "O"
			Do Case
				Case Upper(oChild:Realname) == "IDENTIFIER"
					If oChild:_Type:Text == "UNLOC"
						cCodLoc := oChild:Text
					EndIf
				Case Upper(oChild:Realname) == "NAME"
					cLoc := oChild:Text
				Case Upper(oChild:Realname) == "TYPE"
					cType := Upper(oChild:Text)
				Case Upper(oChild:Realname) == "DATETIME"
					aAdd(aDatas, {EasyDt2D(oChild:Text), Upper(oChild:_DateType:Text)})
			EndCase
		ElseIf ValType(oChild[1]) == "O" .And. Upper(oChild[1]:Realname) == "DATETIME"
			For j := 1 To Len(oChild)
				aAdd(aDatas, {EasyDt2D(oChild[j]:Text), Upper(oChild[j]:_DateType:Text)})
			Next
		EndIf
	Next
	
	oLocal := oVia:AddVia()
	oLocal:SetLocal(cCodLoc)
	oLocal:SetTipo(cType)
	
	For i := 1 To Len(aDatas)
		oData := oLocal:AddVia()
		oData:SetData(aDatas[i][1])
		oData:SetTipo(aDatas[i][2])
	Next
	
Return
