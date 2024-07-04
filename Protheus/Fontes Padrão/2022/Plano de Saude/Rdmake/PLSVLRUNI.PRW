
#include "PLSMCCR.CH"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETRA   Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida REA                              Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETREA()

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRetExp    := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL aRetRea    := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no nivel Prestador x Tabela de Preco        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BC6->(DbSetOrder(3))
If BC6->(DbSeek(xFilial("BC6")+cCodInt+cCodRDA+cCodPad+cCodPro)) .And. BC6->BC6_VRPCO > 0
   nRet := BC6->BC6_VRPCO
Endif

aadd(aRetRea,{nRef,"",0})

Return({.T.,"",aRetRea,""})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETCH   Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida CH                               Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETCH()       

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRetExp    := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nFor       := 1
LOCAL nVlr       := 0          
LOCAL cAlias     := ""
LOCAL aNiveis    := PLSESPNIV("01")
LOCAL nNiveis    := (aNiveis[1]+1)     
LOCAL cNameBC0   := RetSQLName("BC0")
LOCAL lRet       := .T.
LOCAL lOk        := .F.
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL cSQL       := ""
LOCAL aRetUS     := {}

If nVlrUS <> 0
   nVlr   := nVlrUS
   cAlias := ""
   lOk    := .T.
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for pacote, verifico a quantidade de CH           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cPacote)
   BLE->(DBSetOrder(1))
   If BLE->(DBSeek(xFilial("BLE")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro))
      
      cAlias := "BLE"
      lOk    := .T.
   
      If BLE->BLE_FORMUL == "1" .And. BLE->BLE_VALCH > 0
         nVlr := BLE->BLE_VALCH
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Verifico a consistencia da expressao                 Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды      
         aCop := {}
         aCop := PLSParAna(BLE->BLE_EXPRES)
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao tiver nenhum problema com a expressao, calculo o valor da US  Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         If Empty(aCop[1])
            nVlr := &(BLE->BLE_EXPRES)
         Else
            lRet := .F.              
//            cMsg := "A expressao para o Calculo da US em Pacote, nao foi informado corretamente."
            PLSPOSGLO(PLSINTPAD(),__aCdCri033[1])
            cMsg    := PLSBCTDESC()
            cCodCri := __aCdCri033[1]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no nivel Prestador x Tabela de Preco        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BC6->(DbSetOrder(3))
If BC6->(DbSeek(xFilial("BC6")+cCodInt+cCodRDA+cCodPad+cCodPro)) .And. BC6->BC6_USPCO > 0
   nVlr := BC6->BC6_USPCO
   cAlias := "BC6"       
   lOk    := .T.
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Especialidades da RDA/Planos                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBI->(DBSetOrder(1))
If BBI->(DBSeek(xFilial("BBI")+cCodRDA+cCodInt+cCodLoc+cEspec+cCodPla)) .And. !lOk  .And. BBI->BBI_VALCH > 0
   nVlr   := BBI->BBI_VALCH
   cAlias := "BBI"
   lOk    := .T.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Especialidades da RDA/Procedimentos Autorizados      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lOk
   While nFor <= nNiveis .And. !lOk
       cSQL := "SELECT BC0_NIVEL,BC0_FORMUL,BC0_VALCH,BC0_EXPRES,BC0_NIVVAL FROM "+cNameBC0+" WHERE "
       cSQL += "BC0_FILIAL = '"+xFilial("BC0")+"' AND "
       cSQL += "BC0_CODIGO = '"+cCodRDA+"' AND "
       cSQL += "BC0_CODINT = '"+cCodInt+"' AND "
       cSQL += "BC0_CODLOC = '"+SUBS(cCodLoc,1,3)+"' AND "
       cSQL += "BC0_CODESP = '"+cEspec+"' AND "
       cSQL += "BC0_CODSUB = '"+cSubEsp+"' AND "
 
       If nFor == 1
          cSQL += "BC0_CODOPC = '"+AllTrim(cCodPro)+"' AND "
       Else
          cSQL += "BC0_CDNV0"+StrZero(nFor-1,1)+" = '"+Subs(cCodPro,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])+"' AND "
          cSQL += "BC0_NIVEL = '"+aNiveis[2,(nFor-1),3]+"' AND "
       Endif

       cSQL +=  cNameBC0+".D_E_L_E_T_ = ''"
       PLSQuery(cSQL,"PLSAUTPDIR")
       If !PLSAUTPDIR->(Eof())
          
          If PLSAUTPDIR->BC0_FORMUL == "1"
             If PLSAUTPDIR->BC0_VALCH == 0
                If PLSAUTPDIR->BC0_NIVVAL == "1"
                   nVlr   := 0
                   cAlias := "BC0"
                   lOk    := .T.
                Endif
             Else                            
                nVlr   := PLSAUTPDIR->BC0_VALCH
                cAlias := "BC0"
                lOk    := .T.
             Endif
          Else                                          
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Verifico a consistencia da expressao                 Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
             aCop := PLSParAna(PLSAUTPDIR->BC0_EXPRES)
             lOk  := .T.                            
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Se nao tiver nenhum problema com a expressao, calculo o valor da US  Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             If Empty(aCop[1])
                nVlr   := &(PLSAUTPDIR->BC0_EXPRES)
                cAlias := "BC0"
             Else             
                lRet    := .F.
//                cMsg    := "A expressao para o Calculo da US em Procedimentos Autorizados na Especialidade da RDA, nao foi informado corretamente."
                PLSPOSGLO(PLSINTPAD(),__aCdCri029[1])
                cMsg    := PLSBCTDESC()
                cCodCri := __aCdCri029[1]
             Endif
          Endif
       Endif
       PLSAUTPDIR->(DbCloseArea())
   nFor ++
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Especialidade da RDA                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAX->(DBSetOrder(1))
If BAX->(DBSeek(xFilial("BAX")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp)) .And. !lOk
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verificacao da Data de vigencia da US                Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If dDatPro >= BAX->BAX_VIGDE .And. !Empty(dtos(BAX->BAX_VIGDE))
   
      cAlias := "BAX"
      lOk    := .T.

      If BAX->BAX_FORMUL == "1" .And. BAX->BAX_VALCH > 0
         nVlr  := BAX->BAX_VALCH
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Verifico a consistencia da expressao                 Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aCop := {}
         aCop := PLSParAna(BAX->BAX_EXPRES)
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao tiver nenhum problema com a expressao, calculo o valor da US  Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         If Empty(aCop[1])
            nVlr  := &(BAX->BAX_EXPRES)
         Else
            lRet := .F.
//            cMsg := "A expressao para o Calculo da US em Especialidades na RDA, nao foi informado corretamente."
            PLSPOSGLO(PLSINTPAD(),__aCdCri030[1])
            cMsg    := PLSBCTDESC()
            cCodCri := __aCdCri030[1]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Historico de US da Especialidade da Rede de Atd.     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNO->(DBSetOrder(1))
If BNO->(DBSeek(xFilial("BNO")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp)) .And. !lOk
   While !BNO->(EOF()) .And. xFilial("BNO")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp ==;
                               BNO->(BNO_FILIAL+BNO_CODIGO+BNO_CODINT+BNO_CODLOC+BNO_CODESP+BNO_SUBESP) .And. !lOk
         If dDatPro >= BNO->BNO_DATDE .And. (If(!Empty(dtos(BNO->BNO_DATATE)),dDatPro <= BNO->BNO_DATATE,.T.)) .And.  BNO->BNO_VALUS > 0
            nVlr   := BNO->BNO_VALUS
            cAlias := "BNO"
            lOk    := .T.
         Endif
   BNO->(DBSkip())
   Enddo
Endif
                                     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Local de atendimento da RDA                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды                                 
BB8->(DBSetOrder(1))
If BB8->(DBSeek(xFilial("BB8")+cCodRDA+cCodInt+cCodLoc)) .And. !lOk
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verificacao da Data de vigencia da US                Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды   
   If dDatPro >= BB8->BB8_VIGUS .And. !Empty(dtos(BB8->BB8_VIGUS))

   
      If BB8->BB8_FORMUL == "1" .Or. Empty(BB8->BB8_FORMUL) .And. BB8->BB8_VALCH > 0
         cAlias := "BB8"
         lOk    := .T.   
         nVlr := BB8->BB8_VALCH
      ElseiF BB8->BB8_FORMUL == "2"
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Verifico a consistencia da expressao                 Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aCop := {}
         aCop := PLSParAna(BB8->BB8_EXPRES)
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao tiver nenhum problema com a expressao, calculo o valor da US  Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды         
         If Empty(aCop[1])
            cAlias := "BB8"
            lOk    := .T.   
            nVlr  := &(BB8->BB8_EXPRES)
         Else
            lRet := .F.
//            cMsg := "A expressao para o Calculo da US no Local de Atendimento na RDA, nao foi informado corretamente."
            PLSPOSGLO(PLSINTPAD(),__aCdCri031[1])
            cMsg    := PLSBCTDESC()
            cCodCri := __aCdCri031[1]
         Endif
      Endif
   Endif
Endif                          

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Historico de US do Local de Atendimento x RDA        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BN8->(DBSetOrder(1))
If BN8->(DBSeek(xFilial("BN8")+cCodRDA+cCodInt+cCodLoc)) .And. !lOk
   While !BN8->(EOF()) .And. xFilial("BN8")+cCodRDA+cCodInt+cCodLoc ==;
                               BN8->(BN8_FILIAL+BN8_CODIGO+BN8_CODINT+BN8_CODLOC) .And. !lOk
         If dDatPro >= BN8->BN8_DATDE .And. (If(!Empty(dtos(BN8->BN8_DATATE)),dDatPro <= BN8->BN8_DATATE,.T.)) .And. BN8->BN8_VLRUS > 0
            nVlr   := BN8->BN8_VLRUS
            cAlias := "BN8"
            lOk    := .T.
         Endif
   BN8->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Operadora da RDA                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAW->(DBSetOrder(1))
If BAW->(DBSeek(xFilial("BAW")+cCodRDA+cCodInt)) .And. !lOk
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verificacao da Data de vigencia da US                Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды   
   If dDatPro >= BAW->BAW_VIGDE .And. !Empty(dtos(BAW->BAW_VIGDE))
   
      cAlias := "BAW"
      lOk    := .T.
   
      If (BAW->BAW_FORMUL == "1" .Or. Empty(BAW->BAW_FORMUL)) .And. BAW->BAW_VALCH > 0
         nVlr := BAW->BAW_VALCH
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Verifico a consistencia da expressao                 Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды      
         aCop := {}
         aCop := PLSParAna(BAW->BAW_EXPRES)
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao tiver nenhum problema com a expressao, calculo o valor da US  Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         If Empty(aCop[1])
            nVlr := &(BAW->BAW_EXPRES)
         Else
            lRet := .F.              
//            cMsg := "A expressao para o Calculo da US em Operadoras na RDA, nao foi informado corretamente."
            PLSPOSGLO(PLSINTPAD(),__aCdCri032[1])
            cMsg    := PLSBCTDESC()
            cCodCri := __aCdCri032[1]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Historico de US da Operadora x RDA                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды   
BNG->(DBSetOrder(1))
If BNG->(DBSeek(xFilial("BNG")+cCodRDA+cCodInt)) .And. !lOk
   While !BNG->(EOF()) .And. xFilial("BNG")+cCodRDA+cCodInt ==;
                               BNG->(BNG_FILIAL+BNG_CODIGO+BNG_CODINT) .And. !lOk
         If dDatPro >= BNG->BNG_DATDE .And. (If(!Empty(dtos(BNG->BNG_DATATE)),dDatPro <= BNG->BNG_DATATE,.T.)) .And. BNG->BNG_VALCH > 0 
            nVlr   := BNG->BNG_VALCH
            cAlias := "BNG"
            lOk    := .T.
         Endif
   BNG->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Especialidade                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAQ->(DBSetOrder(1))
If BAQ->(DBSeek(xFilial("BAQ")+cCodInt+cEspec)) .And. !lOk .And. BAQ->BAQ_VALCH > 0
   nVlr   := BAQ->BAQ_VALCH
   cAlias := "BAQ"
   lOk    := .T.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valores mensais da US                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BFM->(DBSetOrder(1))
If BFM->(DBSeek(xFilial("BFM")+cCodInt+cAno+cMes)) .And. !lOk .And. BFM->BFM_VALRDA > 0
   nVlr   := BFM->BFM_VALRDA
   cAlias := "BFM"
   lOk    := .T.
Endif


If lOk .And. nVlr > 0
   nVlr := nVlr * nQtd * nRef
   aadd(aRetUS,{nVlr,cAlias,0})
Else  
   If Empty(cMsg)
     lRet := .F.
//     cMsg := "Nao foi informado nenhum valor para a US."
     PLSPOSGLO(PLSINTPAD(),__aCdCri034[1])
     cMsg    := PLSBCTDESC()
     cCodCri := __aCdCri034[1]
   Endif
   aadd(aRetUS,{0,"",0})
Endif

Return({lRet,cMsg,aRetUS,cCodCri})



/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETM2   Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida M2                               Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function XXXPLSRETM2()

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nFor       := 1
LOCAL nVlr       := 0          
LOCAL cAlias     := ""
LOCAL lRet       := .T.
LOCAL lOk        := .F.
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL aRetFil    := {}
LOCAL aRetExp    := {}
LOCAL lPadrao    := .F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no nivel de Especialidade x RDA                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPQ->(DBSetOrder(1))
If BPQ->(DBSeek(xFilial("BPQ")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodFil))
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao existir um filme especifico, utilizo o que for padrao            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If Empty(cCodFil)
      While !BPQ->(EOF()) .And. !lPadrao
           If BPQ->BPQ_PADRAO == "1"
              lPadrao := .T.
           Else
              BPQ->(DBSkip())
           Endif
      Enddo
   Else
      lPadrao := .T.
   Endif

   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica o valor do Filme                                               Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If dDatPro >= BPQ->BPQ_VIGDE .And. lPadrao
      If BPQ->BPQ_VLRFIL == 0
         If BPQ->BPQ_PERFIL == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPQ->BPQ_NIVVAL == "1"
               nVlr    := 0
               cAlias  := "BPQ"
               lOk     := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do filme no nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BP8->(DBSetOrder(3))
            If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BPQ->BPQ_SEQFIL))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды               
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr   := (BPQ->BPQ_PERFIL/100) * nVlr
                  cAlias := "BPQ"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPQ->BPQ_CODDOC,{nQtd,BPQ->BPQ_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            cAlias  := "BPI"
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Filme x Especialidade x RDA                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNQ->(DBSetOrder(1))
If BNQ->(DBSeek(xFilial("BNQ")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodFil)) .And. !lOk
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao existir um filme especifico, utilizo o que for padrao            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   While !BNQ->(EOF()) .And. xFilial("BNQ")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodFil ==;
                               BNQ->(BNQ_FILIAL+BNQ_CODIGO+BNQ_CODINT+BNQ_CODLOC+BNQ_CODESP+BNQ_CODSUB+If(!Empty(cCodFil),BNQ_CODFIL,"")) .And. !lOk
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Verifica o valor do Filme                                               Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         If BNQ->BNQ_PADRAO == "1" .And. dDatPro >= BNQ->BNQ_DATDE .And.;
           (If(!Empty(dtos(BNQ->BNQ_DATATE)),dDatPro <= BNQ->BNQ_DATATE,.T.))
            If BNQ->BNQ_VLRFIL == 0
               If BNQ->BNQ_PERFIL == 0
                  If BNQ->BNQ_NIVVAL == "1"
                     nVlr    := 0
                     cAlias  := "BNQ"
                     lOk     := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor do filme no nivel mais alto              Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                  BP8->(DBSetOrder(3))
                  If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BNQ->BNQ_SEQFIL))
                     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
                     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nInd := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nInd,1]
                        Next
                        nVlr   := (BNQ->BNQ_PERFIL/100) * nVlr
                        cAlias := "BNQ"
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BNQ->BNQ_CODDOC,{nQtd,BNQ->BNQ_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  cAlias  := "BNQ"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BNQ->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no nivel de Local de Atendimento x RDA                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
BPI->(DBSetOrder(1))
If BPI->(DBSeek(xFilial("BPI")+cCodRDA+cCodInt+cCodLoc+cCodFil)) .And. !lOk
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao existir um filme especifico, utilizo o que for padrao            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   lPadrao := .F.
   If Empty(cCodFil)
      While !BPI->(EOF()) .And. !lPadrao
           If BPI->BPI_PADRAO == "1"
              lPadrao := .T.
           Else
              BPI->(DBSkip())
           Endif
      Enddo
   Else
      lPadrao := .T.
   Endif

   If dDatPro >= BPI->BPI_VIGDE .And. lPadrao
      If BPI->BPI_VLRFIL == 0
         If BPI->BPI_PERFIL == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё' Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPI->BPI_NIVVAL == "1"
               nVlr    := 0
               cAlias  := "BPI"
               lOk     := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do filme no nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BP8->(DBSetOrder(3))
            If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BPI->BPI_SEQFIL))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды               
               aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды               
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr   := (BPI->BPI_PERFIL/100) * nVlr
                  cAlias := "BPI"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPI->BPI_CODDOC,{nQtd,BPI->BPI_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            cAlias  := "BPI"
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Filme x Local de Atendimento x RDA          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                 
BN9->(DBSetOrder(1))
If BN9->(DBSeek(xFilial("BN9")+cCodRDA+cCodInt+cCodLoc+cCodFil)) .And. !lOk
   While !BN9->(EOF()) .And. xFilial("BN9")+cCodRDA+cCodInt+cCodLoc+cCodFil ==;
                               BN9->(BN9_FILIAL+BN9_CODIGO+BN9_CODINT+BN9_CODLOC+If(!Empty(cCodFil),BN9_CODFIL,"")) .And. !lOk
         If BN9->BN9_PADRAO == "1" .And. dDatPro >= BN9->BN9_DATDE .And.;
            (If(!Empty(dtos(BN9->BN9_DATATE)),dDatPro <= BN9->BN9_DATATE,.T.))
            If BN9->BN9_VLRFIL == 0
               If BN9->BN9_PERFIL == 0
                  If BN9->BN9_NIVVAL == "1"
                     nVlr    := 0
                     cAlias  := "BN9"
                     lOk     := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor do filme no nivel mais alto              Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                  BP8->(DBSetOrder(3))
                  If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BN9->BN9_SEQFIL))
                     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
                     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nInd := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nInd,1]
                        Next
                        nVlr   := (BN9->BN9_PERFIL/100) * nVlr
                        cAlias := "BN9"
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BN9->BN9_CODDOC,{nQtd,BN9->BN9_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  cAlias  := "BN9"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BN9->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no nivel de Operadora                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
BPB->(DBSetOrder(1))
If BPB->(DBSeek(xFilial("BPB")+cCodRDA+cCodInt+cCodFil)) .And. !lOk
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao existir um filme especifico, utilizo o que for padrao            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   lPadrao := .F.
   If Empty(cCodFil)
      While !BPB->(EOF()) .And. !lPadrao
           If BPB->BPB_PADRAO == "1"
              lPadrao := .T.
           Else
              BPB->(DBSkip())
           Endif
      Enddo
   Else
      lPadrao := .T.
   Endif

   If dDatPro >= BPB->BPB_VIGDE .And. lPadrao
      If BPB->BPB_VLRFIL == 0
         If BPB->BPB_PERFIL == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPB->BPB_NIVVAL == "1"
               nVlr    := 0
               cAlias  := "BPB"
               lOk     := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do filme no nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BP8->(DBSetOrder(3))
            If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BPB->BPB_SEQFIL))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr   := (BPB->BPB_PERFIL/100) * nVlr
                  cAlias := "BPB"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPB->BPB_CODDOC,{nQtd,BPB->BPB_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            cAlias  := "BPB"
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Filme x Operadora                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                 
BNC->(DBSetOrder(1))
If BNC->(DBSeek(xFilial("BNC")+cCodRDA+cCodInt+cCodFil)) .And. !lOk
   While !BNC->(EOF()) .And. xFilial("BNC")+cCodRDA+cCodInt+cCodFil ==;
                               BNC->(BNC_FILIAL+BNC_CODIGO+BNC_CODINT+If(!Empty(cCodFil),BNC_CODFIL,"")) .And. !lOk
         If BNC->BNC_PADRAO == "1" .And. dDatPro >= BNC->BNC_DATDE .And.;
            (If(!Empty(dtos(BNC->BNC_DATATE)),dDatPro <= BNC->BNC_DATATE,.T.))
            If BNC->BNC_VLRFIL == 0
               If BNC->BNC_PERFIL == 0
                  If BNC->BNC_NIVVAL == "1"
                     nVlr    := 0
                     cAlias  := "BNC"
                     lOk     := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor do filme no nivel mais alto              Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                  BP8->(DBSetOrder(3))
                  If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BNC->BNC_SEQFIL))
                     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
                     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nInd := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nInd,1]
                        Next
                        nVlr   := (BNC->BNC_PERFIL/100) * nVlr
                        cAlias := "BNC"
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BNC->BNC_CODDOC,{nQtd,BNC->BNC_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  cAlias  := "BNC"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BNC->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no nivel de Classificacao da RDA                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
BQE->(DBSetOrder(1))
If BQE->(DBSeek(xFilial("BQE")+cCodInt+cClaRDA+cCodFil)) .And. !lOk
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao existir um filme especifico, utilizo o que for padrao            Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   lPadrao := .F.
   If Empty(cCodFil)
      While !BQE->(EOF()) .And. !lPadrao
           If BQE->BQE_PADRAO == "1"
              lPadrao := .T.
           Else
              BQE->(DBSkip())
           Endif
      Enddo
   Else
      lPadrao := .T.
   Endif

   If dDatPro >= BQE->BQE_VIGDE .And. lPadrao
      If BQE->BQE_VLRFIL == 0
         If BQE->BQE_PERFIL == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BQE->BQE_NIVVAL == "1"
               nVlr    := 0
               cAlias  := "BQE"
               lOk     := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do filme no nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BP8->(DBSetOrder(3))
            If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BQE->BQE_SEQFIL))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr   := (BQE->BQE_PERFIL/100) * nVlr
                  cAlias := "BQE"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BQE->BQE_CODDOC,{nQtd,BQE->BQE_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            cAlias  := "BQE"
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Filme x Classificacao da                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                 
BSE->(DBSetOrder(1))
If BSE->(DBSeek(xFilial("BSE")+cCodInt+cClaRDA+cCodFil)) .And. !lOk
   While !BSE->(EOF()) .And. xFilial("BSE")+cCodInt+cClaRDA+cCodFil ==;
                               BSE->(BSE_FILIAL+BSE_CODINT+BSE_CODIGO+If(!Empty(cCodFil),BSE_CODFIL,"")) .And. !lOk
         If BSE->BSE_PADRAO == "1" .And. dDatPro >= BSE->BSE_DATDE .And.;
            (If(!Empty(dtos(BSE->BSE_DATATE)),dDatPro <= BSE->BSE_DATATE,.T.))
            If BSE->BSE_VLRFIL == 0
               If BSE->BSE_PERFIL == 0
                  If BSE->BSE_NIVVAL == "1"
                     nVlr    := 0
                     cAlias  := "BSE"
                     lOk     := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor do filme no nivel mais alto              Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                  BP8->(DBSetOrder(3))
                  If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil+BSE->BSE_SEQFIL))
                     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
                     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nInd := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nInd,1]
                        Next
                        nVlr   := (BSE->BSE_PERFIL/100) * nVlr
                        cAlias := "BSE"
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BSE->BSE_CODDOC,{nQtd,BSE->BSE_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  cAlias  := "BSE"
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BSE->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no nivel mais alto que e o cadastro de valor do Filme(BP8)  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP8->(DBSetOrder(1))
If BP8->(DBSeek(xFilial("BP8")+cCodInt+cCodFil)) .And. !lOk
   While !BP8->(EOF()) .And. xFilial("BP8")+cCodInt == BP8->(BP8_FILIAL+BP8_CODINT) .And. !lOk
         If BP8->BP8_PADRAO == "1" .And. dDatPro >= BP8->BP8_VIGDE .And.;
            (If(!Empty(dtos(BP8->BP8_VIGATE)),dDatPro <= BP8->BP8_VIGATE,.T.))
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Calculo o valor do filme, baseado na Unidade de Medida Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            nSalveReg := BP8->(Recno())
            nOrdReg   := BP8->(IndexOrd())
            aRetExp := PLSUNIMED(BP8->BP8_CODDOC,{nQtd,BP8->BP8_VLRFIL,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            lOk   := .T.
            If aRetExp[1]
               nVlr := 0
               For nInd := 1 To Len(aRetExp[3])
                   nVlr  += aRetExp[3,nInd,1]
               Next
               cAlias := "BP8"
            Else
               lRet    := .F.
               cMsg    := aRetExp[2]
               cCodCri := aRetExp[4]
            Endif
         Endif
         BP8->(DbGoTo(nSalveReg))
         BP8->(DbSetOrder(nOrdReg))

    BP8->(DBSkip())
    Enddo
Endif

If lOk .And. nVlr > 0
   nVlr := nVlr * nRef * nQtd
   aadd(aRetFil,{nVlr,cAlias,0})   
Else
   If Empty(cMsg)
      lRet := .F.
//      cMsg := "Nao foi informado nenhum valor para o Filme."
      PLSPOSGLO(PLSINTPAD(),__aCdCri035[1])
      cMsg    := PLSBCTDESC()
      cCodCri := __aCdCri035[1]
   Endif
   aadd(aRetFil,{0,"",0})
Endif

Return({lRet,cMsg,aRetFil,cCodCri})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETPA   Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida PA                               Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETPA()

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nVlr       := 0          
LOCAL cAlias     := ""
LOCAL cRdmake    := ""
LOCAL lRet       := .T.
LOCAL lOk        := .F.
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL aRetPA     := {}
LOCAL aRetExp    := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao da Especialidade x RDA                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPU->(DBSetOrder(1))
If BPU->(DBSeek(xFilial("BPU")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+AllTrim(Str(nRef,2))))
   If dDatPro >= BPU->BPU_VIGDE
      If BPU->BPU_VLRPOR == 0
         If BPU->BPU_PERPOR == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPU->BPU_NIVVAL == "1"
               aadd(aRetPA,{0,"BPU",0})
               lOk  := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do porte do nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BKF->(DBSetOrder(2))
            If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2))+BPU->BPU_SEQPOR))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr  := (BPU->BPU_PERPOR/100) * nVlr
                  aadd(aRetPA,{nVlr,"BPU",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPU->BPU_CODDOC,{nQtd,BPU->BPU_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            aadd(aRetPA,{nVlr,"BPU",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico Especialidade x RDA         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNU->(DBSetOrder(1))
If BNU->(DBSeek(xFilial("BNU")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+AllTrim(Str(nRef,2)))) .And. !lOk
   While !BNU->(EOF()) .And. xFilial("BNU")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+AllTrim(Str(nRef,2)) ==;
         BNU->(BNU_FILIAL+BNU_CODIGO+BNU_CODINT+BNU_CODLOC+BNU_CODESP+BNU_CODSUB+AllTrim(Str(BNU_CODPOR,2)))
       If dDatPro >= BNU->BNU_DATDE
          If BNU->BNU_VLRPOR == 0
             If BNU->BNU_PERPOR == 0
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Verifica se o zero e valido                                          Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                If BNU->BNU_NIVVAL == "1"
                   aadd(aRetPA,{0,"BNU",0})
                   lOk  := .T.
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Busca o valor do porte do nivel mais alto              Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                BKF->(DBSetOrder(2))
                If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2))+BNU->BNU_SEQPOR))
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.
                   If aRetExp[1]
                      nVlr := 0
                      For nInd := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nInd,1]
                      Next
                      nVlr  := (BNU->BNU_PERPOR/100) * nVlr
                      aadd(aRetPA,{nVlr,"BNU",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
             Endif
          Else
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             aRetExp := PLSUNIMED(BNU->BNU_CODDOC,{nQtd,BNU->BNU_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                   cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
             //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
             //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             lOk   := .T.
             If aRetExp[1]
                nVlr := 0
                For nInd := 1 To Len(aRetExp[3])
                    nVlr  += aRetExp[3,nInd,1]
                Next
                aadd(aRetPA,{nVlr,"BNU",0})
             Else
                lRet    := .F.
                cMsg    := aRetExp[2]
                cCodCri := aRetExp[4]
             Endif
          Endif
       Endif
   BNU->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao do Local de Atendimento x RDA            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPN->(DBSetOrder(1))
If BPN->(DBSeek(xFilial("BPN")+cCodRDA+cCodInt+cCodLoc+AllTrim(Str(nRef,2)))) .And. !lOk
   If dDatPro >= BPN->BPN_VIGDE
      If BPN->BPN_VLRPOR == 0
         If BPN->BPN_PERPOR == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPN->BPN_NIVVAL == "1"
               aadd(aRetPA,{0,"BPN",0})
               lOk  := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do porte do nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BKF->(DBSetOrder(2))
            If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2))+BPN->BPN_SEQPOR))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr  := (BPN->BPN_PERPOR/100) * nVlr
                  aadd(aRetPA,{nVlr,"BPN",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPN->BPN_CODDOC,{nQtd,BPN->BPN_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            aadd(aRetPA,{nVlr,"BPN",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Local de Atd x RDA       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNM->(DBSetOrder(1))
If BNM->(DBSeek(xFilial("BNM")+cCodRDA+cCodInt+cCodLoc+AllTrim(Str(nRef,2)))) .And. !lOk
   While !BNM->(EOF()) .And. xFilial("BNM")+cCodRDA+cCodInt+cCodLoc+AllTrim(Str(nRef,2)) == BNM->(BNM_FILIAL+BNM_CODIGO+BNM_CODINT+BNM_CODLOC+AllTrim(Str(BNM_CODPOR,2)))
       If dDatPro >= BNM->BNM_DATDE
          If BNM->BNM_VLRPOR == 0
             If BNM->BNM_PERPOR == 0
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Verifica se o zero e valido                                          Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                If BNM->BNM_NIVVAL == "1"
                   aadd(aRetPA,{0,"BNM",0})
                   lOk  := .T.
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Busca o valor do porte do nivel mais alto              Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                BKF->(DBSetOrder(2))
                If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2))+BNM->BNM_SEQPOR))
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.
                   If aRetExp[1]
                      nVlr := 0
                      For nInd := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nInd,1]
                      Next
                      nVlr  := (BNM->BNM_PERPOR/100) * nVlr
                      aadd(aRetPA,{nVlr,"BNM",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
             Endif
          Else
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             aRetExp := PLSUNIMED(BNM->BNM_CODDOC,{nQtd,BNM->BNM_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                   cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
             //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
             //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             lOk   := .T.
             If aRetExp[1]
                nVlr := 0
                For nInd := 1 To Len(aRetExp[3])
                    nVlr  += aRetExp[3,nInd,1]
                Next
                aadd(aRetPA,{nVlr,"BNM",0})
             Else
                lRet    := .F.
                cMsg    := aRetExp[2]
                cCodCri := aRetExp[4]
             Endif
          Endif
       Endif
   BNM->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao de Operadora x RDA                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPF->(DBSetOrder(1))
If BPF->(DBSeek(xFilial("BPF")+cCodRDA+cCodInt+AllTrim(Str(nRef,2)))) .And. !lOk
   If dDatPro >= BPF->BPF_VIGDE
      If BPF->BPF_VLRPOR == 0
         If BPF->BPF_PERPOR == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BPF->BPF_NIVVAL == "1"
               aadd(aRetPA,{0,"BPF",0})
               lOk  := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do porte do nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BPF->(DBSetOrder(2))
            If BPF->(DBSeek(xFilial("BPF")+cCodInt+Alltrim(Str(nRef,2))+BPF->BPF_SEQPOR))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BPF->BPF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr  := (BPF->BPF_PERPOR/100) * nVlr
                  aadd(aRetPA,{nVlr,"BPF",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPF->BPF_CODDOC,{nQtd,BPF->BPF_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            aadd(aRetPA,{nVlr,"BPF",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Operadora x RDA          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNH->(DBSetOrder(1))
If BNH->(DBSeek(xFilial("BNH")+cCodRDA+cCodInt+AllTrim(Str(nRef,2)))) .And. !lOk
   While !BNH->(EOF()) .And. xFilial("BNM")+cCodRDA+cCodInt+AllTrim(Str(nRef,2)) ==;
                               BNM->(BNM_FILIAL+BNM_CODIGO+BNM_CODINT+AllTrim(Str(BNM_CODPOR,2))) .And. !lOk
       If dDatPro >= BNH->BNH_DATDE
          If BNH->BNH_VLRPOR == 0
             If BNH->BNM_PERPOR == 0
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Verifica se o zero e valido                                          Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                If BNM->BNM_NIVVAL == "1"
                   aadd(aRetPA,{0,"BNM",0})
                   lOk  := .T.
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Busca o valor do porte do nivel mais alto              Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                BKF->(DBSetOrder(2))
                If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2))+BNM->BNM_SEQPOR))
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.                   
                   If aRetExp[1]
                      nVlr := 0
                      For nInd := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nInd,1]
                      Next
                      nVlr  := (BNM->BNM_PERPOR/100) * nVlr
                      aadd(aRetPA,{nVlr,"BNM",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
             Endif
          Else
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             aRetExp := PLSUNIMED(BNM->BNM_CODDOC,{nQtd,BNM->BNM_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                   cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
             //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
             //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             lOk   := .T.
             If aRetExp[1]
                nVlr := 0
                For nInd := 1 To Len(aRetExp[3])
                    nVlr  += aRetExp[3,nInd,1]
                Next
                aadd(aRetPA,{nVlr,"BNM",0})
             Else
                lRet    := .F.
                cMsg    := aRetExp[2]
                cCodCri := aRetExp[4]
             Endif
          Endif
       Endif
   BNM->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao de Classificacao x RDA                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BQI->(DBSetOrder(1))
If BQI->(DBSeek(xFilial("BQI")+cCodInt+cClaRDA+AllTrim(Str(nRef,2)))) .And. !lOk
   If dDatPro >= BQI->BQI_VIGDE
      If BQI->BQI_VLRPOR == 0
         If BQI->BQI_PERPOR == 0
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se o zero e valido                                          Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If BQI->BQI_NIVVAL == "1"
               aadd(aRetPA,{0,"BQI",0})
               lOk  := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor do porte do nivel mais alto              Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BQI->(DBSetOrder(2))
            If BQI->(DBSeek(xFilial("BQI")+cCodInt+Alltrim(Str(nRef,2))+BQI->BQI_SEQPOR))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BPF->BPF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nInd := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nInd,1]
                  Next
                  nVlr  := (BQI->BQI_PERPOR/100) * nVlr
                  aadd(aRetPA,{nVlr,"BQI",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BQI->BQI_CODDOC,{nQtd,BQI->BQI_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nInd := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nInd,1]
            Next
            aadd(aRetPA,{nVlr,"BQI",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificacao no historico de Classificacao x RDA      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
BSK->(DBSetOrder(1))
If BSK->(DBSeek(xFilial("BSK")+cCodInt+cClaRDA+AllTrim(Str(nRef,2)))) .And. !lOk
   While !BSK->(EOF()) .And. xFilial("BSK")+cCodInt+cClaRDA+AllTrim(Str(nRef,2)) ==;
                               BSK->(BSK_FILIAL+BSK_CODINT+BSK_CODIGO+AllTrim(Str(BSK_CODPOR,2))) .And. !lOk
       If dDatPro >= BSK->BSK_DATDE
          If BSK->BSK_VLRPOR == 0
             If BSK->BSK_PERPOR == 0
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Verifica se o zero e valido                                          Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                If BSK->BSK_NIVVAL == "1"
                   aadd(aRetPA,{0,"BSK",0})
                   lOk  := .T.
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Busca o valor do porte do nivel mais alto              Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                BKF->(DBSetOrder(2))
                If BKF->(DBSeek(xFilial("BSK")+cCodInt+Alltrim(Str(nRef,2))+BSK->BSK_SEQPOR))
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.                   
                   If aRetExp[1]
                      nVlr := 0
                      For nInd := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nInd,1]
                      Next
                      nVlr  := (BSK->BSK_PERPOR/100) * nVlr
                      aadd(aRetPA,{nVlr,"BSK",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
             Endif
          Else
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Calculo o valor do porte, baseado na Unidade de Medida Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             aRetExp := PLSUNIMED(BSK->BSK_CODDOC,{nQtd,BSK->BSK_VLRPOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                   cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
             //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
             //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             lOk   := .T.
             If aRetExp[1]
                nVlr := 0
                For nInd := 1 To Len(aRetExp[3])
                    nVlr  += aRetExp[3,nInd,1]
                Next
                aadd(aRetPA,{nVlr,"BSK",0})
             Else
                lRet    := .F.
                cMsg    := aRetExp[2]
                cCodCri := aRetExp[4]
             Endif
          Endif
       Endif
   BSK->(DBSkip())
   Enddo
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Faz o calculo do porte anestesico                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BKF->(DBSetOrder(1))
If BKF->(DBSeek(xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2)))) .And. !lOk
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Busca o valor do porte do nivel mais alto              Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   While !BKF->(EOF()) .And. xFilial("BKF")+cCodInt+Alltrim(Str(nRef,2)) == BKF->(BKF_FILIAL+BKF_CODINT+AllTrim(STR(BKF_PORTE,2))) .And. !lOk
        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Verifico a unidade de medida do Porte Anestesico(BKF)  Ё
        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        If Empty(dtos(BKF->BKF_VIGATE))
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Calculo o valor do porte baseado na unidade de medida  Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           aRetExp := PLSUNIMED(BKF->BKF_CODDOC,{nQtd,BKF->BKF_COEFIC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
           //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
           //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           lOk   := .T.
           If aRetExp[1]
              nVlr := 0
              For nInd := 1 To Len(aRetExp[3])
                  nVlr  += aRetExp[3,nInd,1]
              Next
              aadd(aRetPA,{nVlr,"BKF",0})
           Else
              lRet    := .F.
              cMsg    := aRetExp[2]
              cCodCri := aRetExp[4]
           Endif
        Endif
   BKF->(DBSkip())
   Enddo
Endif

If Len(aRetPA) == 0
   If Empty(cMsg)
      lRet := .F.
//      cMsg := "Nao foi informado nenhum valor para o Porte Anestesico."
      PLSPOSGLO(PLSINTPAD(),__aCdCri036[1])
      cMsg    := PLSBCTDESC()
      cCodCri := __aCdCri036[1]
   Endif
   aadd(aRetPA,{0,"",0})
Endif

Return({lRet,cMsg,aRetPA,cCodCri})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETAUX  Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida AUX                              Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETAUX()

LOCAL nQtd       := paramixb[1]
LOCAL nQtdAux    := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nInd       := 1
LOCAL nVlrCH     := 0          
LOCAL lRet       := .T.
LOCAL lOk        := .F.
LOCAL cMsg       := "" 
LOCAL cCodCri    := ""
LOCAL aRetAux    := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Faz um somatorio dos CH que ja foram calculados                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nVlrCH := 0
For nInd := 1 To Len(aRet)
    If aRet[nInd,2] == "CH"
       nVlrCH += aRet[nInd,5,1,1]
    Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o valor do Auxiliar                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nInd := 1
For nInd := 1 To nQtdAux
    lOk := .F.
    
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao da Especialidade x RDA                   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BPR->(DBSetOrder(1))
    If BPR->(DBSeek(xFilial("BPR")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodTab+Str(nInd,1)))
       If dDatPro >= BPR->BPR_VIGDE
          If BPR->BPR_PERCAX == 0
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Verifica se o zero e valido                                          Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             If BPR->BPR_NIVVAL == "1"
                aadd(aRetAux,{0,"BPR",nInd})
                lOk     := .T.
             Else
                BP1->(DBSetOrder(2))
                If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BPR->BPR_SEQAUX))
                   nVlr := nVlrCH * (BPR->BPR_PERCAX/100)
                   aadd(aRetAux,{nVlr,"BPR",nInd})
                   lOk  := .T.
                Endif
             Endif
          Else
             nVlr := nVlrCH * (BPR->BPR_PERCAX/100)
             aadd(aRetAux,{nVlr,"BPR",nInd})
             lOk  := .T.
          Endif
       Endif
    Endif

    
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao no historico da Especialidade x RDA      Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BNR->(DBSetOrder(1))
    If BNR->(DBSeek(xFilial("BNR")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+Alltrim(Str(nInd,1)))) .And. !lOk
       While !BNR->(EOF()) .And. xFilial("BNR")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+Alltrim(Str(nInd,1)) ==;
                                   BNR->(BNR_FILIAL+BNR_CODIGO+BNR_CODINT+BNR_CODLOC+BNR_CODESP+BNR_CODSUB)+AllTrim(Str(BNR->BNR_NUMAUX,1));
                                   .And. !lOk
           If dDatPro >= BNR->BNR_DATDE .And. (If(!Empty(dtos(BNR->BNR_DATATE)),dDatPro <= BNR->BNR_DATATE,.T.))
              If BNR->BNR_PERCAX == 0
                 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                 //Ё Verifica se o zero e valido                                          Ё
                 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                 If BNR->BNR_NIVVAL == "1"
                    aadd(aRetAux,{0,"BNR",nInd})
                    lOk     := .T.
                 Else
                    BP1->(DBSetOrder(2))
                    If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BNR->BNR_SEQAUX))
                       nVlr := nVlrCH * (BNR->BNR_PERCAX/100)
                       aadd(aRetAux,{nVlr,"BNR",nInd})
                       lOk  := .T.
                    Endif
                 Endif
              Else
                 nVlr := nVlrCH * (BNR->BNR_PERCAX/100)
                 aadd(aRetAux,{nVlr,"BNR",nInd})
                 lOk  := .T.
              Endif
           Endif
       BNR->(DBSkip())
       Enddo
    Endif

    //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao do Local de Atendimento x RDA            Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BPK->(DBSetOrder(1))
    If BPK->(DBSeek(xFilial("BPK")+cCodRDA+cCodInt+cCodLoc+cCodTab+Str(nInd,1))) .And. !lOk
       If dDatPro >= BPK->BPK_VIGDE
          If BPK->BPK_PERCAX == 0
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Verifica se o zero e valido                                          Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             If BPK->BPK_NIVVAL == "1"
                aadd(aRetAux,{0,"BPK",nInd})
                lOk     := .T.
             Else
                BP1->(DBSetOrder(2))
                If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BPK->BPK_SEQAUX))
                   nVlr := nVlrCH * (BPK->BPK_PERCAX/100)
                   aadd(aRetAux,{nVlr,"BPK",nInd})
                   lOk  := .T.
                Endif
             Endif
          Else
             nVlr := nVlrCH * (BPK->BPK_PERCAX/100)
             aadd(aRetAux,{nVlr,"BPK",nInd})
             lOk  := .T.
          Endif
       Endif
    Endif
    
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao do historico do Local de Atendimento x RDA  Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BP2->(DBSetOrder(1))
    If BP2->(DBSeek(xFilial("BP2")+cCodRDA+cCodInt+cCodLoc+Alltrim(Str(nInd,1)))) .And. !lOk
       While !BP2->(EOF()) .And. xFilial("BP2")+cCodRDA+cCodInt+cCodLoc+Alltrim(Str(nInd,1)) ==;
                                   BP2->(BP2_FILIAL+BP2_CODIGO+BP2_CODINT+BP2_CODLOC)+AllTrim(Str(BP2->BP2_NUMAUX,1));
                                   .And. !lOk
           If dDatPro >= BP2->BP2_DATDE .And. (If(!Empty(dtos(BP2->BP2_DATATE)),dDatPro <= BP2->BP2_DATATE,.T.))
              If BP2->BP2_PERCAX == 0
                 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                 //Ё Verifica se o zero e valido                                          Ё
                 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                 If BP2->BP2_NIVVAL == "1"
                    aadd(aRetAux,{0,"BP2",nInd})
                    lOk     := .T.
                 Else
                    BP1->(DBSetOrder(2))
                    If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BP2->BP2_SEQAUX))
                       nVlr := nVlrCH * (BP2->BP2_PERCAX/100)
                       aadd(aRetAux,{nVlr,"BP2",nInd})
                       lOk  := .T.
                    Endif
                 Endif
              Else
                 nVlr := nVlrCH * (BP2->BP2_PERCAX/100)
                 aadd(aRetAux,{nVlr,"BP2",nInd})
                 lOk  := .T.
              Endif
           Endif
       BP2->(DBSkip())
       Enddo
    Endif
    
    
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao do historico da Operadora x RDA             Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BND->(DBSetOrder(1))
    If BND->(DBSeek(xFilial("BND")+cCodRDA+cCodInt+cCodTab+Alltrim(Str(nInd,1)))) .And. !lOk
       While !BND->(EOF()) .And. xFilial("BND")+cCodRDA+cCodInt+cCodTab+Alltrim(Str(nInd,1)) ==;
                                   BND->(BND_FILIAL+BND_CODIGO+BND_CODINT+BND_CODTAB)+AllTrim(Str(BND->BND_NUMAUX,1));
                                   .And. !lOk
           If dDatPro >= BND->BND_DATDE .And. (If(!Empty(dtos(BND->BND_DATATE)),dDatPro <= BND->BND_DATATE,.T.))
              If BND->BND_PERCAX == 0
                 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                 //Ё Verifica se o zero e valido                                          Ё
                 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                 If BND->BND_NIVVAL == "1"
                    aadd(aRetAux,{0,"BND",nInd})
                    lOk     := .T.             
                 Else
                    BP1->(DBSetOrder(2))
                    If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BND->BND_SEQAUX))
                       nVlr := nVlrCH * (BND->BND_PERCAX/100)
                       aadd(aRetAux,{nVlr,"BND",nInd})
                       lOk  := .T.
                    Endif
                 Endif
              Else
                 nVlr := nVlrCH * (BND->BND_PERCAX/100)
                 aadd(aRetAux,{nVlr,"BND",nInd})
                 lOk  := .T.
              Endif
           Endif
       BND->(DBSkip())
       Enddo
    Endif    

    //здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao da Classificacao x RDA                   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BQF->(DBSetOrder(1))
    If BQF->(DBSeek(xFilial("BQF")+cCodInt+cClaRDA+cCodTab+Str(nInd,1))) .And. !lOk
       If dDatPro >= BQF->BQF_VIGDE
          If BQF->BQF_PERCAX == 0
             //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
             //Ё Verifica se o zero e valido                                          Ё
             //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
             If BQF->BQF_NIVVAL == "1"
                aadd(aRetAux,{0,"BQF",nInd})
                lOk     := .T.
             Else
                BP1->(DBSetOrder(2))
                If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BQF->BQF_SEQAUX))
                   nVlr := nVlrCH * (BQF->BQF_PERCAX/100)
                   aadd(aRetAux,{nVlr,"BQF",nInd})
                   lOk  := .T.
                Endif
             Endif
          Else
             nVlr := nVlrCH * (BQF->BQF_PERCAX/100)
             aadd(aRetAux,{nVlr,"BQF",nInd})
             lOk  := .T.
          Endif
       Endif
    Endif
    
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao do historico da Classificacao x RDA         Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BSH->(DBSetOrder(1))
    If BSH->(DBSeek(xFilial("BSH")+cCodInt+cClaRDA+cCodTab+Alltrim(Str(nInd,1)))) .And. !lOk
       While !BSH->(EOF()) .And. xFilial("BSH")+cCodInt+cClaRDA+cCodTab+Alltrim(Str(nInd,1)) ==;
                                   BSH->(BSH_FILIAL+BSH_CODINT+BSH_CODIGO+BSH_CODTAB)+AllTrim(Str(BSH->BSH_NUMAUX,1));
                                   .And. !lOk
           If dDatPro >= BSH->BSH_DATDE .And. (If(!Empty(dtos(BSH->BSH_DATATE)),dDatPro <= BSH->BSH_DATATE,.T.))
              If BSH->BSH_PERCAX == 0
                 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                 //Ё Verifica se o zero e valido                                          Ё
                 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                 If BSH->BSH_NIVVAL == "1"
                    aadd(aRetAux,{0,"BSH",nInd})
                    lOk     := .T.             
                 Else
                    BP1->(DBSetOrder(2))
                    If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Str(nInd,1)+BND->BND_SEQAUX))
                       nVlr := nVlrCH * (BSH->BSH_PERCAX/100)
                       aadd(aRetAux,{nVlr,"BSH",nInd})
                       lOk  := .T.
                    Endif
                 Endif
              Else
                 nVlr := nVlrCH * (BSH->BSH_PERCAX/100)
                 aadd(aRetAux,{nVlr,"BSH",nInd})
                 lOk  := .T.
              Endif
           Endif
       BSH->(DBSkip())
       Enddo
    Endif

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Verificacao no nivel mais alto que e o cadastro de Auxiliar(BP1)        Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BP1->(DBSetOrder(1))
    If BP1->(DBSeek(xFilial("BP1")+cCodInt+cCodTab+Alltrim(Str(nInd,1)))) .And. !lOk
       While !BP1->(EOF()) .And. xFilial("BP1")+cCodInt+cCodTab+Alltrim(Str(nInd,1)) ==;
                                   BP1->(BP1_FILIAL+BP1_CODINT+BP1_CODTAB)+AllTrim(Str(BP1->BP1_NUMAUX,1));
                                   .And. !lOk
             If dDatPro >= BP1->BP1_VIGDE .And. (If(!Empty(dtos(BP1->BP1_VIGATE)),dDatPro <= BP1->BP1_VIGATE,.T.))
                nVlr := nVlrCH * (BP1->BP1_PERCAX/100)
                aadd(aRetAux,{nVlr,"BP1",nInd})
             Endif
       BP1->(DBSkip())
       Enddo
    Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o valor do Auxiliar                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aRetAux) == 0
   If Empty(cMsg)
      lRet := .F.
//      cMsg := "Nao foi informado nenhum valor para o auxiliar."
      PLSPOSGLO(PLSINTPAD(),__aCdCri037[1])
      cMsg    := PLSBCTDESC()
      cCodCri := __aCdCri037[1]
   Endif
   aadd(aRetAux,{0,"",0})   
Endif

Return({lRet,cMsg,aRetAux,cCodCri})

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETMED  Ё Autor Ё Michele Tatagiba     Ё Data Ё 02.09.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Retorna o valor do Medicamentos                               Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETMED()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Conteudo do vetor aMedicam                                           Ё
//Ё 1 => Codigo da Tabela de Medicamento                                 Ё
//Ё 2 => Codigo do Medicamento                                           Ё
//Ё 3 => Codigo da Apresentacao                                          Ё
//Ё 4 => Codigo do Laboratorio                                           Ё
//Ё 5 => Quantidade de utilizacao                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

LOCAL nQtd       := paramixb[1]
LOCAL aMedicam   := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nInd       := 1
LOCAL nCont      := 1
LOCAL lOk        := .F.
LOCAL lRet       := .T.
LOCAL cRdmake    := ""
LOCAL cAlias     := ""
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL nVlr       := 0 
LOCAL aRetExp    := {}
LOCAL aRetMed    := {}

If Len(aMedicam) <> 0
   For nInd := 1 To Len(aMedicam)
       lOk := .F.
            
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Se existir pacote, entao verifico o valor dos medicamentos       Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If !Empty(cPacote)
          nVlr := 0
          BLF->(DBSetOrder(1))
          If BLF->(DBSeek(xFilial("BLF")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]))
             While !BLF->(EOF()) .And. BLF->(BLF_FILIAL+BLF_CODINT+BLF_CODPRO+BLF_CODPAC+BLF_CODTAB+BLF_CODOPC+BLF_TABMED+BLF_PREMED+BLF_PREAPR+BLF_PRELAB) ==;
                                  xFilial("BLF")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] .And. !lOk

                   If BLF->BLF_VLRMED == 0
                      If BLF->BLF_PERMED == 0
                         If BLF->BLF_NIVVAL == "1"
                            aadd(aRetMed,{0,"BLF",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do medicamento no nivel mais alto        Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS4->(DBSetOrder(2))
                         If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BLF->BLF_SEQMED))
                            aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BLF->BLF_PERMED/100) * nVlr)* aMedicam[nInd,5]
                               aadd(aRetMed,{nVlr,"BLF",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BLF->BLF_CODDOC,{nQtd,BLF->BLF_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BLF",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif

             BLF->(DBSkip())
             Enddo
          Endif
       Endif
   
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Especialidade x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPT->(DBSetOrder(1))
       If BPT->(DBSeek(xFilial("BPT")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          If dDatPro >= BPT->BPT_VIGDE
             If BPT->BPT_VLRMED == 0
                If BPT->BPT_PERMED == 0
                   If BPT->BPT_NIVVAL == "1"
                      aadd(aRetMed,{0,"BPT",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do medicamento no nivel mais alto        Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS4->(DBSetOrder(2))
                   If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BPT->BPT_SEQMED))
                      aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPT->BPT_PERMED/100) * nVlr) * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BPT",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPT->BPT_CODDOC,{nQtd,BPT->BPT_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMedicam[nInd,5]
                   aadd(aRetMed,{nVlr,"BPT" ,0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Especialidade x RDA                     Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNT->(DBSetOrder(1))
       If BNT->(DBSeek(xFilial("BNT")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          While !BNT->(EOF()) .And. xFilial("BNT")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] ==;
                                      BNT->(BNT_FILIAL+BNT_CODIGO+BNT_CODINT+BNT_CODLOC+BNT_CODESP+BNT_CODSUB+BNT_CODTAB+BNT_PREMED+BNT_PREAPR+BNT_PRELAB) .And. !lOk
                                      
                If dDatPro >= BNT->BNT_DATDE .And. (If(!Empty(dtos(BNT->BNT_DATATE)),dDatPro <= BNT->BNT_DATATE,.T.))
                   If BNT->BNT_VLRMED == 0
                      If BNT->BNT_PERMED == 0
                         If BNT->BNT_NIVVAL == "1"
                            aadd(aRetMed,{0,"BNT",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do medicamento no nivel mais alto        Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS4->(DBSetOrder(2))
                         If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BNT->BNT_SEQMED))
                            aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNT->BNT_PERMED/100) * nVlr) * aMedicam[nInd,5]
                               aadd(aRetMed,{nVlr,"BNT",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNT->BNT_CODDOC,{nQtd,BNT->BNT_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BNT",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNT->(DBSkip())
          Enddo
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Local de Atendimento x RDA                  Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPM->(DBSetOrder(1))
       If BPM->(DBSeek(xFilial("BPM")+cCodRDA+cCodInt+cCodLoc+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          If dDatPro >= BPM->BPM_VIGDE
             If BPM->BPM_VLRMED == 0
                If BPM->BPM_PERMED == 0
                   If BPM->BPM_NIVVAL == "1"
                      aadd(aRetMed,{0,"BPM",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do medicamento no nivel mais alto        Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS4->(DBSetOrder(2))
                   If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BPM->BPM_SEQMED))
                      aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPM->BPM_PERMED/100) * nVlr) * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BPM",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPM->BPM_CODDOC,{nQtd,BPM->BPM_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMedicam[nInd,5]
                   aadd(aRetMed,{nVlr,"BPM",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
              
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Local de Atendimento x RDA              Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNL->(DBSetOrder(1))
       If BNL->(DBSeek(xFilial("BNL")+cCodRDA+cCodInt+cCodLoc+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          While !BNL->(EOF()) .And. xFilial("BNL")+cCodRDA+cCodInt+cCodLoc+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] ==;
                                      BNL->(BNL_FILIAL+BNL_CODIGO+BNL_CODINT+BNL_CODLOC+BNL_CODTAB+BNL_PREMED+BNL_PREAPR+BNL_PRELAB) .And. !lOk
                                      
                If dDatPro >= BNL->BNL_DATDE .And. (If(!Empty(dtos(BNL->BNL_DATATE)),dDatPro <= BNL->BNL_DATATE,.T.))
                   If BNL->BNL_VLRMED == 0
                      If BNL->BNL_PERMED == 0
                         If BNL->BNL_NIVVAL == "1"
                            aadd(aRetMed,{0,"BNL",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do medicamento no nivel mais alto        Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS4->(DBSetOrder(2))
                         If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BNL->BNL_SEQMED))
                            aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNL->BNL_PERMED/100) * nVlr) * aMedicam[nInd,5]
                               aadd(aRetMed,{nVlr,"BNL",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNL->BNL_CODDOC,{nQtd,BNL->BNL_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BNL",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNL->(DBSkip())
          Enddo
       Endif       

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Operadora x RDA                             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPE->(DBSetOrder(1))
       If BPE->(DBSeek(xFilial("BPE")+cCodRDA+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          If dDatPro >= BPE->BPE_VIGDE
             If BPE->BPE_VLRMED == 0
                If BPE->BPE_PERMED == 0
                   If BPE->BPE_NIVVAL == "1"
                      aadd(aRetMed,{0,"BPE",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do medicamento no nivel mais alto        Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS4->(DBSetOrder(2))
                   If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BPE->BPE_SEQMED))
                      aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPE->BPE_PERMED/100) * nVlr) * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BPE",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPE->BPE_CODDOC,{nQtd,BPE->BPE_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMedicam[nInd,5]
                   aadd(aRetMed,{nVlr,"BPE",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Operadora x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNF->(DBSetOrder(1))
       If BNF->(DBSeek(xFilial("BNF")+cCodRDA+cCodInt+cCodLoc+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          While !BNF->(EOF()) .And. xFilial("BNF")+cCodRDA+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] ==;
                                      BNF->(BNF_FILIAL+BNF_CODIGO+BNF_CODINT+BNF_CODTAB+BNF_PREMED+BNF_PREAPR+BNF_PRELAB) .And. !lOk
                                      
                If dDatPro >= BNF->BNF_DATDE .And. (If(!Empty(dtos(BNF->BNF_DATATE)),dDatPro <= BNF->BNF_DATATE,.T.))
                   If BNF->BNF_VLRMED == 0
                      If BNF->BNF_PERMED == 0
                         If BNF->BNF_NIVVAL == "1"
                            aadd(aRetMed,{0,"BNF",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do medicamento no nivel mais alto        Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS4->(DBSetOrder(2))
                         If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BNF->BNF_SEQMED))
                            aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNF->BNF_PERMED/100) * nVlr) * aMedicam[nInd,5]
                               aadd(aRetMed,{nVlr,"BNF",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNF->BNF_CODDOC,{nQtd,BNF->BNF_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BNF",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNF->(DBSkip())
          Enddo
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Classificacao x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BQH->(DBSetOrder(1))
       If BQH->(DBSeek(xFilial("BQH")+cCodInt+cClaRDA+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          If dDatPro >= BQH->BQH_VIGDE
             If BQH->BQH_VLRMED == 0
                If BQH->BQH_PERMED == 0
                   If BQH->BQH_NIVVAL == "1"
                      aadd(aRetMed,{0,"BQH",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do medicamento no nivel mais alto        Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS4->(DBSetOrder(2))
                   If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BQH->BQH_SEQMED))
                      aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BQH->BQH_PERMED/100) * nVlr) * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BQH",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BQH->BQH_CODDOC,{nQtd,BQH->BQH_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMedicam[nInd,5]
                   aadd(aRetMed,{nVlr,"BQH",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Operadora x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BSJ->(DBSetOrder(1))
       If BSJ->(DBSeek(xFilial("BSJ")+cCodInt+cClaRDA+cCodLoc+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          While !BSJ->(EOF()) .And. xFilial("BSJ")+cCodInt+cClaRDA+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] ==;
                                      BSJ->(BSJ_FILIAL+BSJ_CODINT+BSJ_CODIGO+BSJ_CODTAB+BSJ_PREMED+BSJ_PREAPR+BSJ_PRELAB) .And. !lOk
                                      
                If dDatPro >= BSJ->BSJ_DATDE .And. (If(!Empty(dtos(BSJ->BSJ_DATATE)),dDatPro <= BSJ->BSJ_DATATE,.T.))
                   If BSJ->BSJ_VLRMED == 0
                      If BSJ->BSJ_PERMED == 0
                         If BSJ->BSJ_NIVVAL == "1"
                            aadd(aRetMed,{0,"BSJ",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do medicamento no nivel mais alto        Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS4->(DBSetOrder(2))
                         If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4]+BSJ->BSJ_SEQMED))
                            aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BSJ->BSJ_PERMED/100) * nVlr) * aMedicam[nInd,5]
                               aadd(aRetMed,{nVlr,"BSJ",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Medicamento baseado na Unidade de Medida      Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BSJ->BSJ_CODDOC,{nQtd,BSJ->BSJ_VLRMED,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMedicam[nInd,5]
                         aadd(aRetMed,{nVlr,"BSJ",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BSJ->(DBSkip())
          Enddo
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel mais alto que e o cadastro de Medicamento      Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BS4->(DBSetOrder(1))
       If BS4->(DBSeek(xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4])) .And. !lOk
          While !BS4->(EOF()) .And. xFilial("BS4")+cCodInt+aMedicam[nInd,1]+aMedicam[nInd,2]+aMedicam[nInd,3]+aMedicam[nInd,4] ==;
                                      BS4->(BS4_FILIAL+BS4_CODINT+BS4_TABMED+BS4_PREMED+BS4_PREAPR+BS4_PRELAB) .And. !lOk
                                      
                If dDatPro >= BS4->BS4_VIGDE .And. (If(!Empty(dtos(BS4->BS4_VIGATE)),dDatPro <= BS4->BS4_VIGATE,.T.))
                   aRetExp := PLSUNIMED(BS4->BS4_CODDOC,{nQtd,BS4->BS4_PREPRE,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.
                   If aRetExp[1]
                      nVlr := 0
                      For nCont := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nCont,1]
                      Next
                      nVlr   := nVlr * aMedicam[nInd,5]
                      aadd(aRetMed,{nVlr,"BS4",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
          BS4->(DBSkip())
          Enddo
       Endif
   Next
   
   If Len(aRetMed) == 0
      If Empty(cMsg)
         lRet := .F.
//         cMsg := "Nao foi informado nenhum valor para o Medicamento."
         PLSPOSGLO(PLSINTPAD(),__aCdCri038[1])
         cMsg    := PLSBCTDESC()
         cCodCri := __aCdCri038[1]
      Endif
      aadd(aRetMed,{0,"",0})
   Endif
Endif

Return({lRet,cMsg,aRetMed,cCodCri})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETMAT  Ё Autor Ё Michele Tatagiba     Ё Data Ё 25.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Retorna o valor dos Materiais                                 Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETMAT()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Conteudo do vetor aMaterial                                          Ё
//Ё 1 => Codigo da Tabela de Material                                    Ё
//Ё 2 => Codigo do Material                                              Ё
//Ё 3 => Quantidade de utilizacao                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

LOCAL nQtd       := paramixb[1]
LOCAL aMaterial  := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL nInd       := 1
LOCAL nCont      := 1
LOCAL lOk        := .F.
LOCAL lRet       := .T.
LOCAL cRdmake    := ""
LOCAL cAlias     := ""
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL nVlr       := 0 
LOCAL aRetExp    := {}
LOCAL aRetMat    := {}

If Len(aMaterial) <> 0
   For nInd := 1 To Len(aMaterial)
       lOk := .F.
            
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Se existir pacote, entao verifico o valor dos Materiais          Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If !Empty(cPacote)
          nVlr := 0
          BLN->(DBSetOrder(1))
          If BLN->(DBSeek(xFilial("BLN")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aMaterial[nInd,1]+aMaterial[nInd,2]))
             While !BLN->(EOF()) .And. BLN->(BLN_FILIAL+BLN_CODINT+BLN_CODPRO+BLN_CODPAC+BLN_CODTAB+BLN_CODOPC+BLN_TABMAT+BLN_CODMAT) ==;
                                  xFilial("BLN")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aMaterial[nInd,1]+aMaterial[nInd,2] .And. !lOk

                   If BLN->BLN_VLRMAT == 0
                      If BLN->BLN_PERMAT == 0
                         If BLN->BLN_NIVVAL == "1"
                            aadd(aRetMat,{0,"BLN",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do Material no nivel mais alto           Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS6->(DBSetOrder(4))
                         If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BLN->BLN_SEQMAT))
                            aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BLN->BLN_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                               aadd(aRetMat,{nVlr,"BLN",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BLN->BLN_CODDOC,{nQtd,BLN->BLN_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BLN",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif

             BLN->(DBSkip())
             Enddo
          Endif
       Endif
   
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Especialidade x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPS->(DBSetOrder(1))
       If BPS->(DBSeek(xFilial("BPS")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          If dDatPro >= BPS->BPS_VIGDE
             If BPS->BPS_VLRMAT == 0
                If BPS->BPS_PERMAT == 0
                   If BPS->BPS_NIVVAL == "1"
                      aadd(aRetMat,{0,"BPS",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do material no nivel mais alto           Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS6->(DBSetOrder(4))
                   If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BPS->BPS_SEQMAT))
                      aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPS->BPS_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BPS",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPS->BPS_CODDOC,{nQtd,BPS->BPS_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMaterial[nInd,3]
                   aadd(aRetMat,{nVlr,"BPS",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Especialidade x RDA                     Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNS->(DBSetOrder(1))
       If BNS->(DBSeek(xFilial("BNS")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          While !BNS->(EOF()) .And. xFilial("BNS")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aMaterial[nInd,1]+aMaterial[nInd,2] ==;
                                      BNS->(BNS_FILIAL+BNS_CODIGO+BNS_CODINT+BNS_CODLOC+BNS_CODESP+BNS_CODSUB+BNS_CODTAB+BNS_CODMAT) .And. !lOk
                                      
                If dDatPro >= BNS->BNS_DATDE .And. (If(!Empty(dtos(BNS->BNS_DATATE)),dDatPro <= BNS->BNS_DATATE,.T.))
                   If BNS->BNS_VLRMAT == 0
                      If BNS->BNS_PERMAT == 0
                         If BNS->BNS_NIVVAL == "1"
                            aadd(aRetMat,{0,"BNS",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do Material no nivel mais alto           Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS6->(DBSetOrder(4))
                         If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BNS->BNS_SEQMAT))
                            aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNS->BNS_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                               aadd(aRetMat,{nVlr,"BNS",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNS->BNS_CODDOC,{nQtd,BNS->BNS_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BNS",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNS->(DBSkip())
          Enddo
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Local de Atendimento x RDA                  Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPL->(DBSetOrder(1))
       If BPL->(DBSeek(xFilial("BPL")+cCodRDA+cCodInt+cCodLoc+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          If dDatPro >= BPL->BPL_VIGDE
             If BPL->BPL_VLRMAT == 0
                If BPL->BPL_PERMAT == 0
                   If BPL->BPL_NIVVAL == "1"
                      aadd(aRetMat,{0,"BPL",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do material no nivel mais alto           Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS6->(DBSetOrder(4))
                   If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BPL->BPL_SEQMAT))
                      aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPL->BPL_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BPL",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPL->BPL_CODDOC,{nQtd,BPL->BPL_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMaterial[nInd,3]
                   aadd(aRetMat,{nVlr,"BPL",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
              
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Local de Atendimento x RDA              Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNK->(DBSetOrder(1))
       If BNK->(DBSeek(xFilial("BNK")+cCodRDA+cCodInt+cCodLoc+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          While !BNK->(EOF()) .And. xFilial("BNK")+cCodRDA+cCodInt+cCodLoc+aMaterial[nInd,1]+aMaterial[nInd,2] ==;
                                      BNK->(BNK_FILIAL+BNK_CODIGO+BNK_CODINT+BNK_CODLOC+BNK_CODTAB+BNK_CODMAT) .And. !lOk
                                      
                If dDatPro >= BNK->BNK_DATDE .And. (If(!Empty(dtos(BNK->BNK_DATATE)),dDatPro <= BNK->BNK_DATATE,.T.))
                   If BNK->BNK_VLRMAT == 0
                      If BNK->BNK_PERMAT == 0
                         If BNK->BNK_NIVVAL == "1"
                            aadd(aRetMat,{0,"BNK",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do Material no nivel mais alto           Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS6->(DBSetOrder(4))
                         If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BNK->BNK_SEQMAT))
                            aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNK->BNK_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                               aadd(aRetMat,{nVlr,"BNK",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNK->BNK_CODDOC,{nQtd,BNK->BNK_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BNK",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNK->(DBSkip())
          Enddo
       Endif       

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Operadora x RDA                             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPD->(DBSetOrder(1))
       If BPD->(DBSeek(xFilial("BPD")+cCodRDA+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          If dDatPro >= BPD->BPD_VIGDE
             If BPD->BPD_VLRMAT == 0
                If BPD->BPD_PERMAT == 0
                   If BPD->BPD_NIVVAL == "1"
                      aadd(aRetMat,{0,"BPD",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do Material no nivel mais alto           Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS6->(DBSetOrder(4))
                   If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BPD->BPD_SEQMAT))
                      aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPD->BPD_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BPD",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Material baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPD->BPD_CODDOC,{nQtd,BPD->BPD_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMaterial[nInd,3]
                   aadd(aRetMat,{nVlr,"BPD",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Operadora x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNE->(DBSetOrder(1))
       If BNE->(DBSeek(xFilial("BNE")+cCodRDA+cCodInt+cCodLoc+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          While !BNE->(EOF()) .And. xFilial("BNE")+cCodRDA+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2] ==;
                                      BNE->(BNE_FILIAL+BNE_CODIGO+BNE_CODINT+BNE_CODTAB+BNE_CODMAT) .And. !lOk
                                      
                If dDatPro >= BNE->BNE_DATDE .And. (If(!Empty(dtos(BNE->BNE_DATATE)),dDatPro <= BNE->BNE_DATATE,.T.))
                   If BNE->BNE_VLRMAT == 0
                      If BNE->BNE_PERMAT == 0
                         If BNE->BNE_NIVVAL == "1"
                            aadd(aRetMat,{0,"BNE",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do Material no nivel mais alto           Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS6->(DBSetOrder(4))
                         If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BNE->BNE_SEQMAT))
                            aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNE->BNE_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                               aadd(aRetMat,{nVlr,"BNE",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNE->BNE_CODDOC,{nQtd,BNE->BNE_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BNE",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNE->(DBSkip())
          Enddo
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Classificacao x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BQG->(DBSetOrder(1))
       If BQG->(DBSeek(xFilial("BQG")+cCodInt+cClaRDA+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          If dDatPro >= BQG->BQG_VIGDE
             If BQG->BQG_VLRMAT == 0
                If BQG->BQG_PERMAT == 0
                   If BQG->BQG_NIVVAL == "1"
                      aadd(aRetMat,{0,"BQG",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor do Material no nivel mais alto           Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BS6->(DBSetOrder(4))
                   If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BQG->BQG_SEQMAT))
                      aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BQG->BQG_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BQG",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor do Material baseado na Unidade de Medida      Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BQG->BQG_CODDOC,{nQtd,BQG->BQG_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aMaterial[nInd,3]
                   aadd(aRetMat,{nVlr,"BQG",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Operadora x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BSI->(DBSetOrder(1))
       If BSI->(DBSeek(xFilial("BSI")+cCodInt+cClaRDA+cCodLoc+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          While !BSI->(EOF()) .And. xFilial("BSI")+cCodInt+cClaRDA+aMaterial[nInd,1]+aMaterial[nInd,2] ==;
                                      BSI->(BSI_FILIAL+BSI_CODINT+BSI_CODIGO+BSI_CODTAB+BSI_CODMAT) .And. !lOk
                                      
                If dDatPro >= BSI->BSI_DATDE .And. (If(!Empty(dtos(BSI->BSI_DATATE)),dDatPro <= BSI->BSI_DATATE,.T.))
                   If BSI->BSI_VLRMAT == 0
                      If BSI->BSI_PERMAT == 0
                         If BSI->BSI_NIVVAL == "1"
                            aadd(aRetMat,{0,"BSI",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor do Material no nivel mais alto           Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BS6->(DBSetOrder(4))
                         If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2]+BSI->BSI_SEQMAT))
                            aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BSI->BSI_PERMAT/100) * nVlr) * aMaterial[nInd,3]
                               aadd(aRetMat,{nVlr,"BSI",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor do Material baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BSI->BSI_CODDOC,{nQtd,BSI->BSI_VLRMAT,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aMaterial[nInd,3]
                         aadd(aRetMat,{nVlr,"BSI",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BSI->(DBSkip())
          Enddo
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel mais alto que e o cadastro de Material         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BS6->(DBSetOrder(1))
       If BS6->(DBSeek(xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2])) .And. !lOk
          While !BS6->(EOF()) .And. xFilial("BS6")+cCodInt+aMaterial[nInd,1]+aMaterial[nInd,2] ==;
                                      BS6->(BS6_FILIAL+BS6_CODINT+BS6_CODTAB+BS6_MACODI) .And. !lOk
                                      
                If dDatPro >= BS6->BS6_VIGDE .And. (If(!Empty(dtos(BS6->BS6_VIGATE)),dDatPro <= BS6->BS6_VIGATE,.T.))
                   aRetExp := PLSUNIMED(BS6->BS6_CODDOC,{nQtd,BS6->BS6_MAPREC,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.
                   If aRetExp[1]
                      nVlr := 0
                      For nCont := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nCont,1]
                      Next
                      nVlr   := nVlr * aMaterial[nInd,3]
                      aadd(aRetMat,{nVlr,"BS6",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
          BS6->(DBSkip())
          Enddo
       Endif
   Next
   
   If Len(aRetMat) == 0
      If Empty(cMsg)
         lRet := .F.
//         cMsg := "Nao foi informado nenhum valor para o Material."
         PLSPOSGLO(PLSINTPAD(),__aCdCri039[1])
         cMsg    := PLSBCTDESC()
         cCodCri := __aCdCri039[1]
      Endif
      aadd(aRetMat,{0,"",0})
   Endif
Endif

Return({lRet,cMsg,aRetMat,cCodCri})
               

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETDIA  Ё Autor Ё Michele Tatagiba     Ё Data Ё 11.09.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Calcula o valor da diaria                                     Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETDIA()

LOCAL nQtdDia    := paramixb[1]
LOCAL cCodDia    := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL lOk        := .F.
LOCAL lRet       := .T.
LOCAL cRdmake    := ""
LOCAL cAlias     := ""
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL nVlr       := 0 
LOCAL aRetDia    := {}
LOCAL cAcomod    := ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi preenchido o campo de Cod. Diaria     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cCodDia)
   lOk := .T.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica qual acomodacao e permitida para o usuario   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAcomod := PLSRETACOM(cCodInt,cCodPla,cVerPla)
   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a diaria existe                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP9->(DBSetOrder(1))
If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia)) .And. !lOk
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifico se no cadastro da diaria existe acomodacao   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !Empty(BP9->BP9_CODACO)
      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Se a acomodacao for diferente, verifico se existe acomocadacoes relacionadas          Ё
      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If BP9->BP9_CODACO <> cAcomod
         BIR->(DBSetOrder(1))
         If !BIR->(DBSeek(xFilial("BIR")+cAcomod+BP9->BP9_CODACO))
            lOk  := .T.
            lRet := .F.              
//            cMsg := "A acomodacao que o Plano desse usuario permite e diferente da prevista para a diaria."
            PLSPOSGLO(PLSINTPAD(),__aCdCri040[1])
            cMsg    := PLSBCTDESC()
            cCodCri := __aCdCri040[1]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso seja pacote, verifico o valor das diarias                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cPacote)
   BLQ->(DBSetOrder(1))
   If BLQ->(DBSeek(xFilial("BLQ")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+cCodDia)) .And. !lOk
      While !BLQ->(EOF()) .And. xFilial("BLQ")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+cCodDia ==;
                               BLQ->(BLQ_FILIAL+BLQ_CODINT+BLQ_CODPRO+BLQ_CODPAC+BLQ_CODTAB+BLQ_CODOPC+BLQ_CODDIA) .And. !lOk
                                    
         If dDatPro >= BLQ->BLQ_DATDE .And. (If(!Empty(dtos(BLQ->BLQ_DATATE)),dDatPro <= BLQ->BLQ_DATATE,.T.))
            If BLQ->BLQ_VLRMAT == 0
               If BLQ->BLQ_PERMAT == 0
                  If BLQ->BLQ_NIVVAL == "1"
                     aadd(aRetDia,{0,"BLQ",0})
                     lOk := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor da Diaria no nivel maisl alto            Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                  BP9->(DBSetOrder(4))
                  If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BLQ->BLQ_SEQDIA))
                     aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nCont := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nCont,1]
                        Next
                        nVlr   := ((BLQ->BLQ_PERDIA/100) * nVlr) * nQtdDia
                        aadd(aRetDia,{nVlr,"BLQ",0})
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BLQ->BLQ_CODDOC,{nQtd,BLQ->BLQ_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr := nVlr * nQtdDia
                  aadd(aRetDia,{nVlr,"BLQ",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      BLQ->(DBSkip())
      Enddo
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico no nivel de Especialidade x RDA                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPP->(DBSetOrder(1))
If BPP->(DBSeek(xFilial("BPP")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodDia)) .And. !lOk
   If dDatPro >= BPP->BPP_VIGDE
      If BPP->BPP_VLRDIA == 0
         If BPP->BPP_PERDIA == 0
            If BPP->BPP_NIVVAL == "1"
               aadd(aRetDia,{0,"BPP",0})
               lOk := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor da Diaria no nivel mais alto             Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
            BP9->(DBSetOrder(4))
            If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BPP->BPP_SEQDIA))
               aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr   := ((BPP->BPP_PERDIA/100) * nVlr) * nQtdDia
                  aadd(aRetDia,{nVlr,"BPP",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPP->BPP_CODDOC,{nQtd,BPP->BPP_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nCont := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nCont,1]
            Next
            nVlr := nVlr * nQtdDia
            aadd(aRetDia,{nVlr,"BPP",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico no historico de Especialidade x RDA                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNP->(DBSetOrder(1))
If BNP->(DBSeek(xFilial("BNP")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodDia)) .And. !lOk
   While !BNP->(EOF()) .And. xFilial("BNP")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+cCodDia ==;
                               BNP->(BNP_FILIAL+BNP_CODIGO+BNP_CODINT+BNP_CODLOC+BNP_CODESP+BNP_CODSUB+BNP_CODDIA) .And. !lOk
                                    
         If dDatPro >= BNP->BNP_DATDE .And. (If(!Empty(dtos(BNP->BNP_DATATE)),dDatPro <= BNP->BNP_DATATE,.T.))
            If BNP->BNP_VLRMAT == 0
               If BNP->BNP_PERMAT == 0
                  If BNP->BNP_NIVVAL == "1"
                     aadd(aRetDia,{0,"BNP",0})
                     lOk := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor da Diaria no nivel maisl alto            Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                  BP9->(DBSetOrder(4))
                  If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BNP->BNP_SEQDIA))
                     aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nCont := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nCont,1]
                        Next
                        nVlr   := ((BNP->BNP_PERDIA/100) * nVlr) * nQtdDia
                        aadd(aRetDia,{nVlr,"BNP", 0})
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BNP->BNP_CODDOC,{nQtd,BNP->BNP_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr := nVlr * nQtdDia
                  aadd(aRetDia,{nVlr,"BNP",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BNP->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico no nivel de Local de Atendimento x RDA                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPH->(DBSetOrder(1))
If BPH->(DBSeek(xFilial("BPH")+cCodRDA+cCodInt+cCodLoc+cCodDia)) .And. !lOk
   If dDatPro >= BPH->BPH_VIGDE
      If BPH->BPH_VLRDIA == 0
         If BPH->BPH_PERDIA == 0
            If BPH->BPH_NIVVAL == "1"
               aadd(aRetDia,{0,"BPH",0})
               lOk := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor da Diaria no nivel mais alto             Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
            BP9->(DBSetOrder(4))
            If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BPH->BPH_SEQDIA))
               aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr   := ((BPH->BPH_PERDIA/100) * nVlr) * nQtdDia
                  aadd(aRetDia,{nVlr,"BPH",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BPH->BPH_CODDOC,{nQtd,BPH->BPH_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nCont := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nCont,1]
            Next
            nVlr := nVlr * nQtdDia
            aadd(aRetDia,{nVlr,"BPH",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no historico de Local de Atendimento x RDA              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNJ->(DBSetOrder(1))
If BNJ->(DBSeek(xFilial("BNJ")+cCodRDA+cCodInt+cCodLoc+cCodDia)) .And. !lOk
   While !BNJ->(EOF()) .And. xFilial("BNJ")+cCodRDA+cCodInt+cCodLoc+cCodDia ==;
                               BNJ->(BNJ_FILIAL+BNJ_CODIGO+BNJ_CODINT+BNJ_CODLOC+BNJ_CODDIA) .And. !lOk
                                    
         If dDatPro >= BNJ->BNJ_DATDE .And. (If(!Empty(dtos(BNJ->BNJ_DATATE)),dDatPro <= BNJ->BNJ_DATATE,.T.))
            If BNJ->BNJ_VLRMAT == 0
               If BNJ->BNJ_PERMAT == 0
                  If BNJ->BNJ_NIVVAL == "1"
                     aadd(aRetDia,{0,"BNJ",0})
                     lOk := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor da Diaria no nivel maisl alto            Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                  BP9->(DBSetOrder(4))
                  If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BNJ->BNJ_SEQDIA))
                     aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nCont := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nCont,1]
                        Next
                        nVlr   := ((BNJ->BNJ_PERDIA/100) * nVlr) * nQtdDia
                        aadd(aRetDia,{nVlr,"BNJ", 0})
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BNJ->BNJ_CODDOC,{nQtd,BNJ->BNJ_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr := nVlr * nQtdDia
                  aadd(aRetDia,{nVlr,"BNJ",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BNJ->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico no nivel de Operadora x RDA                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP7->(DBSetOrder(1))
If BP7->(DBSeek(xFilial("BP7")+cCodRDA+cCodInt+cCodDia)) .And. !lOk
   If dDatPro >= BP7->BP7_VIGDE
      If BP7->BP7_VLRDIA == 0
         If BP7->BP7_PERDIA == 0
            If BP7->BP7_NIVVAL == "1"
               aadd(aRetDia,{0,"BP7",0})
               lOk := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor da Diaria no nivel mais alto             Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
            BP9->(DBSetOrder(4))
            If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BP7->BP7_SEQDIA))
               aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr   := ((BP7->BP7_PERDIA/100) * nVlr) * nQtdDia
                  aadd(aRetDia,{nVlr,"BP7",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BP7->BP7_CODDOC,{nQtd,BP7->BP7_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nCont := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nCont,1]
            Next
            nVlr := nVlr * nQtdDia
            aadd(aRetDia,{nVlr,"BP7",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no historico de Operadora x RDA                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BNB->(DBSetOrder(1))
If BNB->(DBSeek(xFilial("BNB")+cCodRDA+cCodInt+cCodDia)) .And. !lOk
   While !BNB->(EOF()) .And. xFilial("BNB")+cCodRDA+cCodInt+cCodDia ==;
                               BNB->(BNB_FILIAL+BNB_CODIGO+BNB_CODINT+BNB_CODDIA) .And. !lOk
                                    
         If dDatPro >= BNB->BNB_DATDE .And. (If(!Empty(dtos(BNB->BNB_DATATE)),dDatPro <= BNB->BNB_DATATE,.T.))
            If BNB->BNB_VLRMAT == 0
               If BNB->BNB_PERMAT == 0
                  If BNB->BNB_NIVVAL == "1"
                     aadd(aRetDia,{0,"BNB",0})
                     lOk := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor da Diaria no nivel maisl alto            Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                  BP9->(DBSetOrder(4))
                  If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BNB->BNB_SEQDIA))
                     aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nCont := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nCont,1]
                        Next
                        nVlr   := ((BNB->BNB_PERDIA/100) * nVlr) * nQtdDia
                        aadd(aRetDia,{nVlr,"BNB", 0})
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BNB->BNB_CODDOC,{nQtd,BNB->BNB_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr := nVlr * nQtdDia
                  aadd(aRetDia,{nVlr,"BNB",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BNB->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico no nivel de Classificacao x RDA                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP5->(DBSetOrder(1))
If BP5->(DBSeek(xFilial("BP5")+cCodInt+cClaRDA+cCodDia)) .And. !lOk
   If dDatPro >= BP5->BP5_VIGDE
      If BP5->BP5_VLRDIA == 0
         If BP5->BP5_PERDIA == 0
            If BP5->BP5_NIVVAL == "1"
               aadd(aRetDia,{0,"BP5",0})
               lOk := .T.
            Endif
         Else
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Busca o valor da Diaria no nivel mais alto             Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
            BP9->(DBSetOrder(4))
            If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BP5->BP5_SEQDIA))
               aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr   := ((BP5->BP5_PERDIA/100) * nVlr) * nQtdDia
                  aadd(aRetDia,{nVlr,"BP5",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
      Else
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         aRetExp := PLSUNIMED(BP5->BP5_CODDOC,{nQtd,BP5->BP5_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                               cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         lOk   := .T.
         If aRetExp[1]
            nVlr := 0
            For nCont := 1 To Len(aRetExp[3])
                nVlr  += aRetExp[3,nCont,1]
            Next
            nVlr := nVlr * nQtdDia
            aadd(aRetDia,{nVlr,"BP5",0})
         Else
            lRet    := .F.
            cMsg    := aRetExp[2]
            cCodCri := aRetExp[4]
         Endif
      Endif
   Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no historico de Operadora x RDA                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BSF->(DBSetOrder(1))
If BSF->(DBSeek(xFilial("BSF")+cCodInt+cClaRDAt+cCodDia)) .And. !lOk
   While !BSF->(EOF()) .And. xFilial("BSF")+cCodInt+cClaRDA+cCodDia ==;
                               BSF->(BSF_FILIAL+BSF_CODINT+BSF_CODIGO+BSF_CODDIA) .And. !lOk
                                    
         If dDatPro >= BSF->BSF_DATDE .And. (If(!Empty(dtos(BSF->BSF_DATATE)),dDatPro <= BSF->BSF_DATATE,.T.))
            If BSF->BSF_VLRMAT == 0
               If BSF->BSF_PERMAT == 0
                  If BSF->BSF_NIVVAL == "1"
                     aadd(aRetDia,{0,"BSF",0})
                     lOk := .T.
                  Endif
               Else
                  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                  //Ё Busca o valor da Diaria no nivel maisl alto            Ё
                  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                  BP9->(DBSetOrder(4))
                  If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia+BSF->BSF_SEQDIA))
                     aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                           cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                     //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                     lOk   := .T.
                     If aRetExp[1]
                        nVlr := 0
                        For nCont := 1 To Len(aRetExp[3])
                            nVlr  += aRetExp[3,nCont,1]
                        Next
                        nVlr   := ((BFS->BSF_PERDIA/100) * nVlr) * nQtdDia
                        aadd(aRetDia,{nVlr,"BSF", 0})
                     Else
                        lRet    := .F.
                        cMsg    := aRetExp[2]
                        cCodCri := aRetExp[4]
                     Endif
                  Endif
               Endif
            Else
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Calculo o valor da Diaria baseado na Unidade de Medida           Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRetExp := PLSUNIMED(BSF->BSF_CODDOC,{nQtd,BSF->BSF_VLRDIA,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                     cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
               //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               lOk   := .T.
               If aRetExp[1]
                  nVlr := 0
                  For nCont := 1 To Len(aRetExp[3])
                      nVlr  += aRetExp[3,nCont,1]
                  Next
                  nVlr := nVlr * nQtdDia
                  aadd(aRetDia,{nVlr,"BSF",0})
               Else
                  lRet    := .F.
                  cMsg    := aRetExp[2]
                  cCodCri := aRetExp[4]
               Endif
            Endif
         Endif
   BSF->(DBSkip())
   Enddo
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica no nivel mais alto da Diaria                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BP9->(DBSetOrder(1))
If BP9->(DBSeek(xFilial("BP9")+cCodInt+cCodDia)) .And. !lOk
   While !BP9->(EOF()) .And. xFilial("BP9")+cCodInt+cCodDia ==;
                               BP9->(BP9_FILIAL+BP9_CODINT+BP9_CODIGO) .And. !lOk
                                      
         If dDatPro >= BP9->BP9_VIGDE .And. (If(!Empty(dtos(BP9->BP9_VIGATE)),dDatPro <= BP9->BP9_VIGATE,.T.))
            aRetExp := PLSUNIMED(BP9->BP9_CODDOC,{nQtd,BP9->BP9_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            lOk   := .T.
            If aRetExp[1]
               nVlr := 0
               For nCont := 1 To Len(aRetExp[3])
                   nVlr  += aRetExp[3,nCont,1]
               Next
               nVlr   := nVlr * nQtdDia
               aadd(aRetDia,{nVlr,"BP9",0})
            Else
               lRet    := .F.
               cMsg    := aRetExp[2]
               cCodCri := aRetExp[4]
            Endif
         Endif
   BP9->(DBSkip())
   Enddo
Endif

If Len(aRetDia) == 0
   If Empty(cMsg)
      lRet := .F.
//      cMsg := "Nao foi informado nenhum valor para a Diaria."
      PLSPOSGLO(PLSINTPAD(),__aCdCri041[1])
      cMsg    := PLSBCTDESC()
      cCodCri := __aCdCri041[1]
   Endif
   aadd(aRetDia,{0,"",0})
Endif

Return({lRet,cMsg,aRetDia,cCodCri})

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETTAX  Ё Autor Ё Michele Tatagiba     Ё Data Ё 11.09.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Calcula o valor das Taxas                                     Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETTAX()

LOCAL nQtd       := paramixb[1]
LOCAL aTaxas     := paramixb[2]
LOCAL aRet       := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL lOk        := .F.
LOCAL lRet       := .T.
LOCAL cRdmake    := ""
LOCAL cAlias     := ""
LOCAL cMsg       := ""
LOCAL cCodCri    := ""
LOCAL nVlr       := 0 
LOCAL aRetTax    := {}
      
If Len(aTaxas) <> 0
   For nInd := 1 To Len(aTaxas)
       lOk := .F.
            
       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Se for pacote, verifico a valorizacao das Taxas                     Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If !Empty(cPacote)
          nVlr := 0
          BLO->(DBSetOrder(1))
          If BLO->(DBSeek(xFilial("BLO")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aTaxas[nInd,1]))
             While !BLO->(EOF()) .And. BLO->(BLO_FILIAL+BLO_CODINT+BLO_CODPRO+BLO_CODPAC+BLO_CODTAB+BLO_CODOPC+BLO_CODTAX) ==;
                                  xFilial("BLO")+cCodInt+cProPrinc+cPacote+cCodTab+cCodPro+aTaxas[nInd,1]

                   If BLO->BLO_VLRMAT == 0
                      If BLO->BLO_PERMAT == 0
                         If BLO->BLO_NIVVAL == "1"
                            aadd(aRetTax,{0,"BLO",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor da Taxa no nivel mais alto               Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BLP->(DBSetOrder(3))
                         If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BLO->BLO_SEQTAX))
                            aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BLO->BLO_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                               aadd(aRetTax,{nVlr,"BLO",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor das Taxas   baseado na Unidade de Medida         Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BLO->BLO_CODDOC,{nQtd,BLO->BLO_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BLO",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif

             BLO->(DBSkip())
             Enddo
          Endif
       Endif
   
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Especialidade x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPO->(DBSetOrder(1))
       If BPO->(DBSeek(xFilial("BPO")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aTaxas[nInd,1]))
          If dDatPro >= BPO->BPO_VIGDE
             If BPO->BPO_VLRTAX == 0
                If BPO->BPO_PERTAX == 0
                   If BPO->BPO_NIVVAL == "1"
                      aadd(aRetTax,{0,"BPO",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor das Taxas no nivel mais alto             Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BLP->(DBSetOrder(3))
                   If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BPO->BPO_SEQTAX))
                      aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPO->BPO_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BPO",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor da Taxa baseado na Unidade de Medida             Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPO->BPO_CODDOC,{nQtd,BPO->BPO_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aTaxas[nInd,2]
                   aadd(aRetTax,{nVlr,"BPO",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Especialidade x RDA                     Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNN->(DBSetOrder(1))
       If BNN->(DBSeek(xFilial("BNN")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aTaxas[nInd,1])) .And. !lOk
          While !BNN->(EOF()) .And. xFilial("BNN")+cCodRDA+cCodInt+cCodLoc+cEspec+cSubEsp+aTaxas[nInd,1] ==;
                                      BNN->(BNN_FILIAL+BNN_CODIGO+BNN_CODINT+BNN_CODLOC+BNN_CODESP+BNN_CODSUB+BNN_CODTAX) .And. !lOk
                                      
                If dDatPro >= BNN->BNN_DATDE .And. (If(!Empty(dtos(BNN->BNN_DATATE)),dDatPro <= BNN->BNN_DATATE,.T.))
                   If BNN->BNN_VLRTAX == 0
                      If BNN->BNN_PERTAX == 0
                         If BNN->BNN_NIVVAL == "1"
                            aadd(aRetTax,{0,"BNN",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor da Taxas no nivel mais alto              Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BLP->(DBSetOrder(3))
                         If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BNN->BNN_SEQTAX))
                            aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNN->BNN_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                               aadd(aRetTax,{nVlr,"BNN",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor das Taxas baseado na Unidade de Medida           Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNN->BNN_CODDOC,{nQtd,BNN->BNN_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BNN",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNN->(DBSkip())
          Enddo
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Local de Atendimento x RDA                  Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BPG->(DBSetOrder(1))
       If BPG->(DBSeek(xFilial("BPG")+cCodRDA+cCodInt+cCodLoc+aTaxas[nInd,1])) .And. !lOk
          If dDatPro >= BPG->BPG_VIGDE
             If BPG->BPG_VLRTAX == 0
                If BPG->BPG_PERTAX == 0
                   If BPG->BPG_NIVVAL == "1"
                      aadd(aRetTax,{0,"BPG",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor das Taxas no nivel mais alto             Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BLP->(DBSetOrder(3))
                   If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BPG->BPG_SEQTAX))
                      aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BPG->BPG_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BPG",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor da Taxa baseado na Unidade de Medida             Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BPG->BPG_CODDOC,{nQtd,BPG->BPG_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aTaxas[nInd,2]
                   aadd(aRetTax,{nVlr,"BPG",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Local de Atendimento x RDA              Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNI->(DBSetOrder(1))
       If BNI->(DBSeek(xFilial("BNI")+cCodRDA+cCodInt+cCodLoc+aTaxas[nInd,1])) .And. !lOk
          While !BNI->(EOF()) .And. xFilial("BNI")+cCodRDA+cCodInt+cCodLoc+aTaxas[nInd,1] ==;
                                      BNI->(BNI_FILIAL+BNI_CODIGO+BNI_CODINT+BNI_CODLOC+BNI_CODTAX) .And. !lOk
                                      
                If dDatPro >= BNI->BNI_DATDE .And. (If(!Empty(dtos(BNI->BNI_DATATE)),dDatPro <= BNI->BNI_DATATE,.T.))
                   If BNI->BNI_VLRTAX == 0
                      If BNI->BNI_PERTAX == 0
                         If BNI->BNI_NIVVAL == "1"
                            aadd(aRetTax,{0,"BNI",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor da Taxas no nivel mais alto              Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BLP->(DBSetOrder(3))
                         If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BNI->BNI_SEQTAX))
                            aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNI->BNI_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                               aadd(aRetTax,{nVlr,"BNI",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor das Taxas baseado na Unidade de Medida           Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNI->BNI_CODDOC,{nQtd,BNI->BNI_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BNI",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNI->(DBSkip())
          Enddo
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Operadora x RDA                             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BP6->(DBSetOrder(1))
       If BP6->(DBSeek(xFilial("BP6")+cCodRDA+cCodInt+aTaxas[nInd,1])) .And. !lOk
          If dDatPro >= BP6->BP6_VIGDE
             If BP6->BP6_VLRTAX == 0
                If BP6->BP6_PERTAX == 0
                   If BP6->BP6_NIVVAL == "1"
                      aadd(aRetTax,{0,"BP6",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor das Taxas no nivel mais alto             Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BLP->(DBSetOrder(3))
                   If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BP6->BP6_SEQTAX))
                      aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BP6->BP6_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BP6",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor da Taxa baseado na Unidade de Medida             Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BP6->BP6_CODDOC,{nQtd,BP6->BP6_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aTaxas[nInd,2]
                   aadd(aRetTax,{nVlr,"BP6",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Operadora x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BNI->(DBSetOrder(1))
       If BNI->(DBSeek(xFilial("BNI")+cCodRDA+cCodInt+aTaxas[nInd,1])) .And. !lOk
          While !BNI->(EOF()) .And. xFilial("BNI")+cCodRDA+cCodInt+aTaxas[nInd,1] ==;
                                      BNI->(BNI_FILIAL+BNI_CODIGO+BNI_CODINT+BNI_CODTAX) .And. !lOk
                                      
                If dDatPro >= BNI->BNI_DATDE .And. (If(!Empty(dtos(BNI->BNI_DATATE)),dDatPro <= BNI->BNI_DATATE,.T.))
                   If BNI->BNI_VLRTAX == 0
                      If BNI->BNI_PERTAX == 0
                         If BNI->BNI_NIVVAL == "1"
                            aadd(aRetTax,{0,"BNI",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor da Taxas no nivel mais alto              Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BLP->(DBSetOrder(3))
                         If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BNI->BNI_SEQTAX))
                            aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BNI->BNI_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                               aadd(aRetTax,{nVlr,"BNI",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor das Taxas baseado na Unidade de Medida           Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BNI->BNI_CODDOC,{nQtd,BNI->BNI_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BNI",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BNI->(DBSkip())
          Enddo
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel de Classificacao x RDA                         Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BP4->(DBSetOrder(1))
       If BP4->(DBSeek(xFilial("BP4")+cCodInt+cClaRDA+aTaxas[nInd,1])) .And. !lOk
          If dDatPro >= BP4->BP4_VIGDE
             If BP4->BP4_VLRTAX == 0
                If BP4->BP4_PERTAX == 0
                   If BP4->BP4_NIVVAL == "1"
                      aadd(aRetTax,{0,"BP4",0})
                      lOk := .T.
                   Endif
                Else
                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Busca o valor das Taxas no nivel mais alto             Ё
                   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                   BLP->(DBSetOrder(3))
                   If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BP4->BP4_SEQTAX))
                      aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr   := ((BP4->BP4_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BP4",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
             Else
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Calculo o valor da Taxa baseado na Unidade de Medida             Ё
                //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                aRetExp := PLSUNIMED(BP4->BP4_CODDOC,{nQtd,BP4->BP4_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                      cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                lOk   := .T.
                If aRetExp[1]
                   nVlr := 0
                   For nCont := 1 To Len(aRetExp[3])
                       nVlr  += aRetExp[3,nCont,1]
                   Next
                   nVlr := nVlr * aTaxas[nInd,2]
                   aadd(aRetTax,{nVlr,"BP4",0})
                Else
                   lRet    := .F.
                   cMsg    := aRetExp[2]
                   cCodCri := aRetExp[4]
                Endif
             Endif
          Endif
       Endif
       
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no historico de Classificacao x RDA                     Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BSG->(DBSetOrder(1))
       If BSG->(DBSeek(xFilial("BSG")+cCodInt+cClaRDA+aTaxas[nInd,1])) .And. !lOk
          While !BSG->(EOF()) .And. xFilial("BSG")+cCodInt+cClaRDA+aTaxas[nInd,1] ==;
                                      BSG->(BSG_FILIAL+BSG_CODINT+BSG_CODIGO+BSG_CODTAX) .And. !lOk
                                      
                If dDatPro >= BSG->BSG_DATDE .And. (If(!Empty(dtos(BSG->BSG_DATATE)),dDatPro <= BSG->BSG_DATATE,.T.))
                   If BSG->BSG_VLRTAX == 0
                      If BSG->BSG_PERTAX == 0
                         If BSG->BSG_NIVVAL == "1"
                            aadd(aRetTax,{0,"BSG",0})
                            lOk := .T.
                         Endif
                      Else
                         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                         //Ё Busca o valor da Taxas no nivel mais alto              Ё
                         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
                         BLP->(DBSetOrder(3))
                         If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1]+BSG->BSG_SEQTAX))
                            aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                                  cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                            //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                            lOk   := .T.
                            If aRetExp[1]
                               nVlr := 0
                               For nCont := 1 To Len(aRetExp[3])
                                   nVlr  += aRetExp[3,nCont,1]
                               Next
                               nVlr   := ((BSG->BSG_PERTAX/100) * nVlr) * aTaxas[nInd,2]
                               aadd(aRetTax,{nVlr,"BSG",0})
                            Else
                               lRet    := .F.
                               cMsg    := aRetExp[2]
                               cCodCri := aRetExp[4]
                            Endif
                         Endif
                      Endif
                   Else
                      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Calculo o valor das Taxas baseado na Unidade de Medida           Ё
                      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      aRetExp := PLSUNIMED(BSG->BSG_CODDOC,{nQtd,BSG->BSG_VLRTAX,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                            cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                      //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                      //Ё Se nao ocorreu nenhum erro no calculo verifico o valor                  Ё
                      //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                      lOk   := .T.
                      If aRetExp[1]
                         nVlr := 0
                         For nCont := 1 To Len(aRetExp[3])
                             nVlr  += aRetExp[3,nCont,1]
                         Next
                         nVlr := nVlr * aTaxas[nInd,2]
                         aadd(aRetTax,{nVlr,"BSG",0})
                      Else
                         lRet    := .F.
                         cMsg    := aRetExp[2]
                         cCodCri := aRetExp[4]
                      Endif
                   Endif
                Endif
          BSG->(DBSkip())
          Enddo
       Endif
            
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica no nivel mais alto que e o cadastro de Taxas            Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BLP->(DBSetOrder(1))
       If BLP->(DBSeek(xFilial("BLP")+cCodInt+aTaxas[nInd,1])) .And. !lOk
          While !BLP->(EOF()) .And. xFilial("BLP")+cCodInt+aTaxas[nInd,1] ==;
                                      BLP->(BLP_FILIAL+BLP_CODINT+BLP_CODTAX) .And. !lOk
                                      
                If dDatPro >= BLP->BLP_VIGDE .And. (If(!Empty(dtos(BLP->BLP_VIGATE)),dDatPro <= BLP->BLP_VIGATE,.T.))
                   aRetExp := PLSUNIMED(BLP->BLP_CODDOC,{nQtd,BLP->BLP_VALOR,aRet,dDatPro,cCodRDA,cCodInt,cCodLoc,cCodTab,;
                                                         cCodPad,cCodPro,cCodPla,cVerPla,cMes,cAno,cEspec,cSubEsp,cCodFil,cPacote,cProPrinc,cClaRDA,nVlrUS})
                   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
                   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                   lOk   := .T.
                   If aRetExp[1]
                      nVlr := 0
                      For nCont := 1 To Len(aRetExp[3])
                          nVlr  += aRetExp[3,nCont,1]
                      Next
                      nVlr   := nVlr * aTaxas[nInd,2]
                      aadd(aRetTax,{nVlr,"BLP",0})
                   Else
                      lRet    := .F.
                      cMsg    := aRetExp[2]
                      cCodCri := aRetExp[4]
                   Endif
                Endif
          BLP->(DBSkip())
          Enddo
       Endif
   Next
   
   If Len(aRetTax) == 0
      If Empty(cMsg)
         lRet := .F.
//         cMsg := "Nao foi informado nenhum valor para a Taxa."
         PLSPOSGLO(PLSINTPAD(),__aCdCri042[1])
         cMsg    := PLSBCTDESC()
         cCodCri := __aCdCri042[1]
      Endif
      aadd(aRetTax,{0,"",0})
   Endif
Endif

Return({lRet,cMsg,aRetTax,cCodCri})
               
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSUNIMED  Ё Autor Ё Michele Tatagiba     Ё Data Ё 19.10.2002 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a unidade de medida                                  Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus 7.10                                        Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSUNIMED(cCodDoc,aParam)

LOCAL aRetExp := {}
LOCAL cMsg    := ""
LOCAL cCodCri := ""

BD3->(DBSetOrder(1))
If BD3->(DBSeek(xFilial("BD3")+cCodDoc))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Calculo o valor do porte baseado na unidade de medida  Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   aRetExp  := ExecBlock(BD3->BD3_RDMAKE,.F.,.F.,aParam)
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se nao ocorreu nenhum erro no calculo, verifico a porcentagem do valor  Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Endif

If Len(aRetExp) == 0
   PLSPOSGLO(PLSINTPAD(),__aCdCri043[1])
   cMsg    := PLSBCTDESC()
   cCodCri := __aCdCri043[1]
   aRetExp := {.F.,cMsg,{0,"",0},cCodCri}
Endif

Return(aRetExp)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETIN   Ё Autor Ё Tulio Cesar          Ё Data Ё 24.02.2003 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a Incidencia                                         Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus                                             Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETIN()

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRetExp    := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL aRetRea    := {}

aadd(aRetRea,{0,"",0})

Return({.T.,"",aRetRea,""})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠Ё Objeto     Ё PLSRETIN   Ё Autor Ё Tulio Cesar          Ё Data Ё 24.02.2003 Ё╠╠
╠╠цддддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠Ё Descri┤└o  Ё Valoriza a Incidencia                                         Ё╠╠
╠╠цддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso        Ё Advanced Protheus                                             Ё╠╠
╠╠цддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL               Ё╠╠
╠╠цдддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                         Ё╠╠
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSRETM2()

LOCAL nQtd       := paramixb[1]
LOCAL nRef       := paramixb[2]
LOCAL aRetExp    := paramixb[3]
LOCAL dDatPro    := paramixb[4]
LOCAL cCodRDA    := paramixb[5]
LOCAL cCodInt    := paramixb[6]
LOCAL cCodLoc    := paramixb[7]
LOCAL cCodTab    := paramixb[8]
LOCAL cCodPad    := paramixb[9]
LOCAL cCodPro    := paramixb[10]
LOCAL cCodPla    := paramixb[11]
LOCAL cVerPla    := paramixb[12]
LOCAL cMes       := paramixb[13]
LOCAL cAno       := paramixb[14]
LOCAL cEspec     := paramixb[15]
LOCAL cSubEsp    := paramixb[16]
LOCAL cCodFil    := paramixb[17]
LOCAL cPacote    := paramixb[18]
LOCAL cProPrinc  := paramixb[19]
LOCAL cClaRDA    := paramixb[20]
LOCAL nVlrUS     := paramixb[21]
LOCAL aRetRea    := {}

aadd(aRetRea,{0,"",0})


Return({.T.,"",aRetRea,""})
